// ============================================================================
// RSQ Gore's emitter (extends RSQGO_Manager): what a card does once its actor has spawned, or once a parent card
// decides it would have spawned (a hit blood's five children never become actors at all).
//
// PLAYSIM PART (every machine, the same): the flight (a ballistic path from the spawn velocity and gravity, clipped
// by ONE line trace along its chord, because VisualThinkers do not collide; a bouncing class reflects and flies on), the
// floor spot BD's drop leaves where it lands (queued for the tic it would have landed), BD actors a blood spawns (wall
// throws, meat at blood level 3+), screen blood, the saw's items and quake. Random numbers: random[RSQGO_Play].
// COSMETIC PART (per machine): which track shows, mirror picks, density by distance to this machine's camera, the
// budget, the frame-time guard, landing splashes and sounds. Random numbers: the handler's xorshift, never a shared
// RNG. A card whose whole tree is cosmetic (RSQGO_Data.cPure) runs nothing in the playsim.
//
// TIME. Tic 0 is a card's first tick, the tic it spawns (BD's actor ticks in that tic too: the fresh-thinker pass).
// "The tick t" of an actor happens after it has moved t+1 times: PosAt(spawn, vel, g, t + 1) is where it does what it
// does in tick t, and where it is drawn at the end of that tic. A VisualThinker spawned this tic is ticked this tic
// too, so it starts at age first-1 and shows keyframe `first` on its first frame (RSQGO_VT.StartTrack).
// ============================================================================

extend class RSQGO_Manager
{
	enum EHit { HIT_NONE, HIT_FLOOR, HIT_WALL, HIT_CEILING }
	enum EJob { J_EMIT, J_TRAIL, J_SOUND }
	const RING_SIZE = 1024;     // track lives are under 1024 tics (BD's longest is 506)
	const MIN_TRACE = 16.0;     // a path shorter than this is not traced (a trail drop falling a few units)
	const MAX_DEPTH = 6;
	const MAX_BOUNCE = 3;       // wall / ceiling bounces followed per flight (each is one more trace)
	const NEAR_CUT = 16.0;      // map units from the eye inside which nothing spawns
	const STEP_FLOOR = 2.0;     // QZD meets the floor within 2 units (p_mobj.cpp P_ZMovement `Z() <= floorz + 2`)
	const WATER_SINK = 0.5;     // p_mobj.cpp WATER_SINK_SPEED

	transient int flySide;              // the side of flyLine the path came from (Fly)
	transient bool flySky;              // Fly's floor landing is on a sky floor (BD destroys the missile: no Death)
	transient bool boxSky;              // FloorFor's last answer was a sky floor
	transient Array<int> jOff;          // J_TRAIL: posOff (where the parent is at a tic: PosAt(p, v, g, tic + off))
	transient Array<bool> jUw;          // J_TRAIL: the parent is under water
	transient Array<int> jDep;          // J_TRAIL: the children's depth. J_EMIT: the track's generation (vtDepth)
	transient int vtDepth;              // the generation of the track about to spawn (0 a hit blood, its children 1...)

	// ================================================================ actors
	void RunActor(RSQGO_Card a)
	{
		if (!Ready()) return;
		int c = a.cardNo;
		if (c < 0 || c >= data.cName.Size()) return;
		if (data.cKind[c] == RSQGO_Data.K_HIT)
		{
			RunHit(RSQGO_HitBlood(a), c);
			return;
		}
		// BD's drops test waterlevel > 1 and go to Splash (an Underblood) instead
		if (a.waterlevel > 1 && HasPath(c, RSQGO_Data.P_WATER))
		{
			RunKids(c, RSQGO_Data.P_WATER, a, a.pos, a.vel, 0, a.angle, 0, 1, 0, 0, -1, 0, false, true);
			return;
		}
		Process(c, a, a.pos, a.vel, a.angle, 0, 0, a.waterlevel >= 1);
	}

	bool HasPath(int c, int path)
	{
		for (int k = data.cKid0[c]; k < data.cKid0[c] + data.cKidN[c]; k++) if (data.kPath[k] == path) return true;
		return false;
	}

	// ================================================================ a hit blood (BD's Brutal_Blood Spawn, path by path)
	// cards.py hit_card has the timing: the chain, then the blood's own path (Spawn2, LowBlood), and only then, in the
	// same tic (cAcsTic), BD's intensity script's level state on top.
	void RunHit(RSQGO_HitBlood a, int c)
	{
		if (!a) return;
		let d = data;
		int adv = a.Advance();
		// A blood P_SpawnBlood starts 1 or 2 states in ran its 0-tic chain inside P_SpawnBlood, before its first tick,
		// at its spawn point; that first tick then counts down BSPR A, so everything after the chain is one tic sooner.
		int sh = adv >= 1 ? 1 : 0;
		Vector3 p0 = a.pos;
		Vector3 v0 = a.vel;
		double ang = a.angle;
		double g = Grav(c, a);
		oneLeft = (LocalI('rsqgo_fx', 2) <= 0) ? 1 : 0;     // Spray And Mist None: the puff and one more track a hit

		// the saw (SawBlood and its colours): A_JumpIfInTargetInventory("HasCutingWeapon", 1, "HitSaw", AAPTR_TARGET)
		// reads the item on the blood's target's target: the victim's target, the attacker holding the saw
		// (checks.zs: target.CheckInventory(item, 1, AAPTR_TARGET); P_BloodSplatter2 sets the blood's target to the victim)
		Actor att = a.target ? a.target.target : null;
		if (d.cSaw[c] && adv <= d.cSawSidx[c] && att && d.invSaw && att.CountInv(d.invSaw) >= 1)
		{
			int sb = d.cSawTic[c];
			RunKids(c, RSQGO_Data.P_SAW, a, p0, v0, g, ang, sb - sh, sb + 1 - sh, 0, 0, -1, adv, false);
			RunGives(c, RSQGO_Data.P_SAW, a, p0, v0, g, sb - sh, sb + 1 - sh, -1, false);
			if (d.cSawSound[c] != "" || d.cQuake0[c] > 0)
			{
				int ft = sb + d.cSawFxTic[c] - sh;
				Vector3 fp = PosAt(p0, v0, g, sb + d.cSawFxTic[c] + 1 - sh);
				if (ft <= 0) SawFx(a, c);
				else QueueActor("RSQGO_SawFx", fp, (0, 0, 0), c, ft);
			}
			oneLeft = 0;
			return;
		}
		// what every path does first (SuperGoreMistTiny), unless the low-damage start skipped its state
		RunKids(c, RSQGO_Data.P_COMMON, a, p0, v0, g, ang, -sh, 1 - sh, 0, 0, -1, adv, false);
		if (a.waterlevel > 1)
		{
			RunKids(c, RSQGO_Data.P_WATER, a, p0, v0, g, ang, -sh, 1 - sh, 0, 0, -1, 0, false, true);
			oneLeft = 0;
			return;
		}
		// SlaughterCounter >= 30 on the blood's target (no forward pointer: Blood.dec): straight to LowBlood
		int route;
		bool low = d.cSlaughter[c] > 0 && a.target && d.invSlaughter && a.target.CountInv(d.invSlaughter) >= d.cSlaughter[c];
		if (low)
		{
			int lb = d.cSlTic[c];
			RunKids(c, RSQGO_Data.P_LOW, a, p0, v0, g, ang, lb - sh, lb + 1 - sh, 0, 0, -1, 0, false);
			RunGives(c, RSQGO_Data.P_LOW, a, p0, v0, g, lb - sh, lb + 1 - sh, -1, false);
			route = RSQGO_Data.R_SLAUGHTER;
		}
		else
		{
			if (d.cSound[c] != "") S_StartSoundAt(PosAt(p0, v0, g, 1 - sh), d.cSound[c], CHAN_BODY);
			// BD_CheckBloodIntensity, with our level (rsqgo_spray_level, a server cvar) instead of BD's ignored option
			int lvl = clamp(rsqgo_spray_level, 0, 5);
			int at = d.cAcsTic[c];
			// the blood's own path always runs; past the script's tic only at level 2 (another level's state replaces it)
			int own = lvl == 2 ? -1 : at + 1;
			RunKids(c, RSQGO_Data.P_LEVEL2, a, p0, v0, g, ang, -sh, 1 - sh, 0, 0, own, 0, false);
			RunGives(c, RSQGO_Data.P_LEVEL2, a, p0, v0, g, -sh, 1 - sh, own, false);
			int lp = -1;
			route = RSQGO_Data.R_LEVEL2;
			if (lvl <= 1) { lp = RSQGO_Data.P_LOW; route = RSQGO_Data.R_LOW; }
			else if (lvl == 3) { lp = RSQGO_Data.P_LOTS; route = RSQGO_Data.R_LOTS; }
			else if (lvl == 4) { lp = RSQGO_Data.P_ABSURD; route = RSQGO_Data.R_ABSURD; }
			else if (lvl >= 5) { lp = RSQGO_Data.P_ABSURD; route = RSQGO_Data.R_ANIMU; }
			if (lp >= 0)
			{
				// level 5: BD gives the blood AnimuGore, so AbsurdBlood throws its walls and then jumps to AnimuGore
				bool animu = lvl >= 5;
				RunKids(c, lp, a, p0, v0, g, ang, at - sh, at + 1 - sh, 0, 0, -1, 0, animu);
				RunGives(c, lp, a, p0, v0, g, at - sh, at + 1 - sh, -1, animu);
				if (animu)
				{
					RunKids(c, RSQGO_Data.P_ANIMU, a, p0, v0, g, ang, at - sh, at + 1 - sh, 0, 0, -1, 0, false);
					RunGives(c, RSQGO_Data.P_ANIMU, a, p0, v0, g, at - sh, at + 1 - sh, -1, false);
				}
			}
		}
		// the puff: BD's blood itself (BSPR), along the route it took
		if (d.cPuffN[c] > 0)
		{
			// P_SpawnBlood / P_BloodSplatter / SXF_USEBLOODCOLOR give the blood the bleeder's BloodTranslation, which is
			// none for a bleeder without BloodColor (then even Green_Blood draws BD's red); a blood DECORATE spawned
			// keeps its class translation. The frames are BD's untranslated ones either way.
			// Our class carries BD's own translation as its default (cards.py), so the actor's Translation is exactly
			// what BD's would have: the bleeder's when the engine spawned it, the class's when DECORATE did.
			TranslationID tr = a.Translation;
			int v = PickPuff(c, route);
			vtDepth = 0;
			if (v >= 0 && Accept(p0, RSQGO_Data.C_HIT, true)) EmitVarT(v, c, p0, v0, g, 0, 0, -1, sh, tr);
		}
		oneLeft = 0;
	}

	// BD's own Translation for card c's class (its DECORATE `translation`; none for red): the engine draws our
	// untranslated frame through it exactly as it draws BD's actor (cards.py Looks.tex_index).
	TranslationID ClassTrans(int c)
	{
		let cls = data.cBDCls[c];
		if (cls) return GetDefaultByType(cls).Translation;
		TranslationID noTr = 0;
		return noTr;
	}

	// The puff track for a route: BD's odds among that route's tracks.
	int PickPuff(int c, int route)
	{
		let d = data;
		double sum = 0;
		for (int i = d.cPuff0[c]; i < d.cPuff0[c] + d.cPuffN[c]; i++)
			if (d.vRoute[i] == route) sum += d.vW[i];
		if (sum <= 0) return -1;
		double r = Rand01() * sum;
		int last = -1;
		for (int i = d.cPuff0[c]; i < d.cPuff0[c] + d.cPuffN[c]; i++)
		{
			if (d.vRoute[i] != route) continue;
			last = i;
			r -= d.vW[i];
			if (r <= 0) return i;
		}
		return last;
	}

	// Gives on `path`: at at0 + its tic, from where the parent is then (PosAt(p0, v0, g, tic + posOff)). maxEnd >= 0:
	// only gives before that tic. animu: level 5 skips AbsurdBlood's gives after its AnimuGore jump.
	void RunGives(int c, int path, Actor src, Vector3 p0, Vector3 v0, double g, int at0, int posOff, int maxEnd, bool animu)
	{
		let d = data;
		for (int i = d.cGive0[c]; i < d.cGive0[c] + d.cGiveN[c]; i++)
		{
			if (d.gPath[i] != path) continue;
			if (animu && d.gAnimuSkip[i]) continue;
			if (maxEnd >= 0 && d.gTic[i] >= maxEnd) continue;
			int t = at0 + d.gTic[i];
			Vector3 p = PosAt(p0, v0, g, d.gTic[i] + posOff);
			if (d.gGate[i] >= 0 && p.z - FloorAt(p) < d.gGate[i]) continue;
			if (d.gScreen[i])
			{
				QueueScreen(d.gCls[i], p, d.gRadius[i], t);
			}
			else if (d.gClsC[i] && (d.gFlags[i] & 3))
			{
				// the saw's ChainsawHit* / Power*OnVisor: BD's own A_RadiusGive, players and monsters, on its tic
				if (t <= 0 && src) DeferredGive(src, i);
				else QueueActor("RSQGO_Giver", p, (0, 0, 0), i, t);
			}
		}
	}

	// BD's A_RadiusGive(cls, radius, flags, 1) for give i, made by `from` (a card, or RSQGO_Giver standing where BD's
	// blood stood on that tic).
	void DeferredGive(Actor from, int i)
	{
		let d = data;
		if (!from || i < 0 || i >= d.gClsC.Size() || !d.gClsC[i]) return;
		int fl = 0;
		if (d.gFlags[i] & 1) fl |= RGF_PLAYERS;
		if (d.gFlags[i] & 2) fl |= RGF_MONSTERS;
		from.A_RadiusGive(d.gClsC[i], d.gRadius[i], fl, 1);
	}

	// Card c's DeathFloor spot at p (the landing point, z its landing height): through the residue, which finds the
	// missile's box floorz there (BD's spot class's own radius decides the rest), or straight as BD's class if the
	// residue is not there.
	void PlaceSpot(Vector3 p, int c, double ang)
	{
		let d = data;
		if (c < 0 || c >= d.cName.Size() || !d.cSpotC[c]) return;
		if (!res) res = RSQGO_ResidueRings.Get(true);
		double rad = d.cBDCls[c] ? GetDefaultByType(d.cBDCls[c]).radius : d.cRadius[c];
		if (res) res.PlaceFloorFrom(d.cSpot[c], p + (0, 0, 0.5), rad, ang);
		else QueueActor(d.cSpotC[c], p, (0, 0, 0), ang, 0);
	}

	// The saw's sound and Radius_Quake (i, dur, damrad, tremrad, 0; radii in 64-unit blocks: p_lnspec.cpp
	// LS_Radius_Quake), from where BD's blood stood on that tic.
	void SawFx(Actor from, int c)
	{
		let d = data;
		if (!from || c < 0 || c >= d.cName.Size()) return;
		if (d.cSawSound[c] != "") S_StartSoundAt(from.pos, d.cSawSound[c], CHAN_BODY);
		if (d.cQuake0[c] > 0) from.A_Quake(d.cQuake0[c], d.cQuake1[c], d.cQuake2[c] * 64, d.cQuake3[c] * 64, "world/quake");
	}

	// ================================================================ one card (a drop, a mist, a spawner, a checker)
	// uw: it spawned under water (BD: waterlevel >= 1), where FallAndSink gives no gravity but a slow, damped sink.
	void Process(int c, Actor src, Vector3 p0, Vector3 v0, double ang, int delay, int depth, bool uw = false)
	{
		if (depth > MAX_DEPTH || !src) return;
		let d = data;
		if (d.cKind[c] == RSQGO_Data.K_LIQUID)
		{
			Liquid(c, src, p0, v0, ang, delay);
			return;
		}
		if (d.cStopMove[c]) v0 = (0, 0, 0);
		double g = Grav(c, src);
		// under water a drop with a Splash branch goes there instead (BD: waterlevel > 1), as RunActor does
		if (uw && HasPath(c, RSQGO_Data.P_WATER))
		{
			RunKids(c, RSQGO_Data.P_WATER, src, p0, v0, g, ang, delay, 1, depth, 0, -1, 0, false, true);
			return;
		}
		bool water = uw && g > 0 && !d.cNoInter[c];
		if (water) g = 0;
		bool pure = d.cPure[c];
		int v = d.cVarN[c] > 0 ? PickTrack(c, uw) : -1;
		bool draw = v >= 0 && Accept(p0, d.cCat[c], false);
		// the flight: only a MISSILE dies where it meets a floor or a wall (SuperGore and the sprays are not missiles;
		// a NOCLIP missile passes walls and is clamped to the floor: p_mobj.cpp P_ZMovement). A culled cosmetic drop
		// still flies when its P_DROP children need to stop where it lands, or when it never draws but paints a decal.
		bool flies = d.cMissile[c] && !d.cNoclip[c] && !d.cNoInter[c] &&
			(!pure || draw || d.cDropKids[c] || (d.cVarN[c] == 0 && d.cDecal[c] != ""));
		double sink = water ? -WATER_SINK * clamp(d.cMass[c], 1, 4000) / 100 : 0;
		Vector3 ps = p0;
		Vector3 vs = v0;
		int tS = 0;                 // the tick this segment starts from ps / vs (after a bounce: the tick after it)
		int bmask = d.cBounce[c];
		int hit = HIT_NONE;
		int tDie = -1;
		Vector3 lp = p0;
		Vector3 ldir = (0, 0, -1);
		bool landSky = false;
		for (int nb = 0; nb <= MAX_BOUNCE; nb++)
		{
			int segEnd = -1;        // the tick this segment's actor stops (bounces or dies there), -1 never
			bool bounced = false;
			Vector3 nps = ps;
			Vector3 nvs = vs;
			if (flies)
			{
				// every drop lands as BD's actor does, on its box's floor (BD's class radius): a playsim card through
				// the residue's probe, a cosmetic-only drop through the probe-free footprint (FloorFor)
				Line ln = Fly(src, ps, vs, g, d.cLife[c] - tS, water, sink, pure ? -max(d.cRadius[c], 0.001) : d.cRadius[c]);
				if (flyHit != HIT_NONE)
				{
					int tHit = tS + max(0, flyT - 1);       // the move that meets the surface is the actor's tick flyT-1
					int bit = flyHit == HIT_WALL ? RSQGO_Data.B_WALLS : (flyHit == HIT_CEILING ? RSQGO_Data.B_CEILINGS : 0);
					if ((bmask & bit) && nb < MAX_BOUNCE && Bounce(c, flyHit, ln, vs, g, bmask))
					{
						nps = bnPos;
						nvs = bnVel;
						bmask = bnMask;
						segEnd = tHit + 1;          // it still shows in the tick it bounces
						bounced = true;
					}
					else
					{
						hit = flyHit;
						tDie = tHit;
						lp = flyPos;
						ldir = flyDir;
						landSky = flySky;
						segEnd = tHit;
					}
				}
			}
			// this segment: its part of the track, and the children BD's actor spawns along it
			vtDepth = depth;
			if (draw) EmitVar(v, c, ps, vs, g, delay, tS, segEnd, 0, water, sink);
			RunKids(c, RSQGO_Data.P_DROP, src, ps, vs, g, ang, delay, 1 - tS, depth, tS, segEnd, 0, false, uw);
			if (!bounced) break;
			ps = nps;
			vs = nvs;
			tS = segEnd;
		}
		// a missile that meets a sky floor is destroyed without its Death state (p_mobj.cpp P_ZMovement): it just ends
		if (hit == HIT_FLOOR && landSky) hit = HIT_NONE;
		if (hit != HIT_NONE)
		{
			bool fx = !pure || draw;
			// the splash BD's Death shows at the scale and mirror the flight left: the group of the track that flew
			int grp = v >= 0 ? v - d.cVar0[c] : -1;
			if (hit == HIT_FLOOR)
			{
				// BD's DeathFloor: its floor spot (Brutal_BloodSpot, ...) where and when the drop lands
				// BD's DeathFloor spot, born at the missile's own floorz: the residue places it by BD's rule
				// (PlaceFloorFrom: on a step edge or slope the spot is above its own floor and BD's falls and vanishes)
				if (d.cSpotC[c] && ResidueKeeps())
				{
					if (delay + tDie <= 0) PlaceSpot(lp, c, ang);
					else QueueActor("RSQGO_SpotFrom", lp, (ang, 0, 0), c, delay + tDie);
					statSpots++;
				}
				if (fx)
				{
					RunKids(c, RSQGO_Data.P_FLOOR, src, lp, (0, 0, 0), 0, ang, delay + tDie, 0, depth, 0, -1, 0, false);
					vtDepth = depth;
					Splash(c, d.cSpl0[c], d.cSplN[c], lp, delay + tDie, grp);
				}
			}
			else
			{
				// a wall: BD's missile paints its Decal there (cosmetic: decals never touch a shared RNG). A spawner
				// that never draws still paints it (BD's SuperGoreSpawner sprays BloodSuper).
				if (hit == HIT_WALL && d.cDecal[c] != "" && (fx || d.cVarN[c] == 0))
					src.A_SprayDecal(d.cDecal[c], 32, level.Vec3Diff(src.pos, lp - ldir * 8), ldir);
				if (fx)
				{
					RunKids(c, RSQGO_Data.P_WALL, src, lp, (0, 0, 0), 0, ang, delay + tDie, 0, depth, 0, -1, 0, false);
					vtDepth = depth;
					Splash(c, d.cWSpl0[c], d.cWSplN[c], lp, delay + tDie, grp);
				}
			}
			if (fx && d.cLandSound[c] != "") PushSound(c, lp, delay + tDie);
		}
		if (!pure) RunGives(c, RSQGO_Data.P_DROP, src, p0, v0, g, delay, 1, tDie >= 0 ? tDie : -1, false);
	}

	// A wall or ceiling bounce, as the engine does it (results in bnPos / bnVel / bnMask). Wall: FSlide::BounceWall
	// (p_map.cpp) mirrors the xy direction about the line, speed x WallBounceFactor (2 if that is under 1), z kept, the
	// actor put a radius off the wall. Ceiling: FloorBounceMissile (p_mobj.cpp) reflects z and scales the whole velocity
	// by BounceFactor, the actor put a height under the ceiling; AutoOff then stops its bouncing (a falling actor).
	transient Vector3 bnPos, bnVel;
	transient int bnMask;

	bool Bounce(int c, int hit, Line ln, Vector3 vs, double g, int bmask)
	{
		let d = data;
		Vector3 vh = (vs.x, vs.y, vs.z - g * max(0, flyT - 1));
		bnMask = bmask;
		if (hit == HIT_WALL)
		{
			if (!ln) return false;
			double la = atan2(ln.delta.y, ln.delta.x) + (flySide == 1 ? 180 : 0);
			double na = 2 * la - atan2(vh.y, vh.x);
			double sp = vh.xy.Length() * d.cWallBF[c];
			if (sp < 1) sp = 2;
			bnVel = (cos(na) * sp, sin(na) * sp, vh.z);
			bnPos = flyPos + (cos(na) * d.cRadius[c], sin(na) * d.cRadius[c], 0);
			return true;
		}
		double bf = d.cBF[c];
		bnVel = (vh.x * bf, vh.y * bf, -vh.z * bf);
		double ht = d.cCls[c] ? GetDefaultByType(d.cCls[c]).Height : 1;
		bnPos = flyPos - (0, 0, ht);
		if ((bmask & RSQGO_Data.B_AUTOOFF) && g > 0) bnMask = 0;
		return true;
	}

	// BD's WaterBloodCHecker: it flies (DOOMBOUNCE: off walls and ceilings) until it lands, and over one of BD's
	// liquid floors (SPLASH.acs) it leaves BD's WaterBloodSpot, 7 tics later and 5 units ahead. Elsewhere nothing.
	void Liquid(int c, Actor src, Vector3 p0, Vector3 v0, double ang, int delay)
	{
		let d = data;
		if (!d.cLSpotC[c] || d.cLFlatN[c] == 0) return;
		double g = Grav(c, src);
		Vector3 ps = p0;
		Vector3 vs = v0;
		int tS = 0;
		int bmask = d.cBounce[c];
		int tLand = -1;
		for (int nb = 0; nb <= MAX_BOUNCE; nb++)
		{
			Line ln = Fly(src, ps, vs, g, 350 - tS, false, 0, d.cRadius[c]);
			if (flyHit == HIT_FLOOR)
			{
				if (flySky) return;         // destroyed on a sky floor: no Death, no liquid test
				tLand = tS + max(0, flyT - 1);
				break;
			}
			if (flyHit == HIT_NONE) return;
			int bit = flyHit == HIT_WALL ? RSQGO_Data.B_WALLS : RSQGO_Data.B_CEILINGS;
			int tHit = tS + max(0, flyT - 1);
			if (!(bmask & bit) || nb == MAX_BOUNCE || !Bounce(c, flyHit, ln, vs, g, bmask)) return;
			ps = bnPos;
			vs = bnVel;
			bmask = bnMask;
			tS = tHit + 1;
		}
		if (tLand < 0) return;
		TextureID ft = flySector ? flySector.GetTexture(Sector.floor) : level.PointInSector(flyPos.xy).GetTexture(Sector.floor);
		bool liquid = false;
		for (int i = d.cLFlat0[c]; i < d.cLFlat0[c] + d.cLFlatN[c]; i++) if (d.lfTex[i] == ft) { liquid = true; break; }
		if (!liquid) return;
		double da = (vs.xy.Length() > 0.001) ? atan2(vs.y, vs.x) : ang;
		QueueActor(d.cLSpotC[c], flyPos + (cos(da) * d.cLDist[c], sin(da) * d.cLDist[c], 0), (0, 0, 0), da, delay + tLand + d.cLDelay[c]);
		statSpots++;
	}

	// Phase 1's Blood That Stays (a server cvar, so every machine agrees): the floor spots OUR drops leave. All keeps
	// them, Some every second one, None none. BD's own residue (death groups, chunks) is phase 2's.
	bool ResidueKeeps()
	{
		int r = rsqgo_residue;
		if (r >= 2) return true;
		if (r <= 0) return false;
		spotCount++;
		return (spotCount & 1) == 0;
	}

	// ================================================================ children
	// Children on `path`: spawned at delay + their tic, where the parent is then (PosAt(p0, v0, g, tic + posOff)).
	// tFrom / tEnd: only children from tic tFrom and before tic tEnd (a flight segment; the parent stops spawning in the
	// tick it dies). adv: a hit blood's low-damage start (skip P_COMMON children whose state came before it). animu:
	// level 5 skips the AbsurdBlood children after its AnimuGore jump.
	void RunKids(int c, int path, Actor src, Vector3 p0, Vector3 v0, double g, double pang, int delay, int posOff, int depth,
		int tFrom, int tEnd, int adv, bool animu, bool uw = false)
	{
		let d = data;
		bool kuw = uw || path == RSQGO_Data.P_WATER;
		for (int k = d.cKid0[c]; k < d.cKid0[c] + d.cKidN[c]; k++)
		{
			if (d.kPath[k] != path) continue;
			if (path == RSQGO_Data.P_COMMON && d.kSidx[k] < adv) continue;
			if (animu && d.kAnimuSkip[k]) continue;
			int child = d.kCard[k];
			bool isPlay = child < 0 || !d.cPure[child];
			int n = d.kCount[k];
			int iv = d.kInterval[k];
			int i0 = 0;
			if (tFrom > d.kTic[k])
			{
				if (iv <= 0) continue;
				i0 = (tFrom - d.kTic[k] + iv - 1) / iv;
			}
			if (i0 >= n) continue;
			if (!isPlay && n - i0 > 1 && iv > 0)
			{
				// a cosmetic trail (LiquidBlood lays one drop a tic): one job, expanded a tic at a time; a drop due now
				// spawns now (a job pushed during the thinkers would wait for the next tic's WorldTick)
				int tic0 = d.kTic[k] + i0 * iv;
				if (tEnd >= 0 && tic0 >= tEnd) continue;
				if (delay + tic0 <= 0)
				{
					KidAt(k, PosAt(p0, v0, g, tic0 + posOff), pang, false);
					statAvoided++;
					Process(child, src, kidPos, kidVel, kidAng, delay + tic0, depth + 1, kuw);
					i0++;
				}
				if (i0 < n && (tEnd < 0 || d.kTic[k] + i0 * iv < tEnd))
					PushTrail(k, child, p0, v0, g, pang, delay, posOff, i0, tEnd, kuw, depth + 1);
				continue;
			}
			// one at a time; BD's zero-tic repeats (TNT1 AAAA 0 A_CustomMissile) all spawn in the same tic
			for (int i = i0; i < n; i++)
			{
				int tic = d.kTic[k] + i * iv;
				if (tEnd >= 0 && tic >= tEnd) break;
				KidAt(k, PosAt(p0, v0, g, tic + posOff), pang, isPlay);
				statAvoided++;
				if (child >= 0) Process(child, src, kidPos, kidVel, kidAng, delay + tic, depth + 1, kuw);
				else QueueActor(d.kClsC[k], kidPos, kidVel, kidAng, delay + tic);
			}
		}
	}

	// Where and how a child spawns, exactly as BD's call would place it: A_CustomMissile (CMF_AIMDIRECTION, its pitch
	// up-positive: compatibility.zs CMF_BADPITCH), A_SpawnItemEx (offsets and velocity turned by the angle unless
	// absolute), A_SpawnItem (distance ahead, no velocity). Results in kidPos / kidVel / kidAng.
	void KidAt(int k, Vector3 p, double pang, bool isPlay)
	{
		let d = data;
		int b = k * RSQGO_Data.NR;
		int mode = d.kMode[k];
		if (mode == RSQGO_Data.M_MISSILE)
		{
			double spd = KidSpeed(k);
			double h = R(b, isPlay);
			double a = pang + R(b + 2, isPlay);
			double pit = R(b + 4, isPlay);
			double cp = abs(cos(pit));	// the engine's A_CustomMissile/A_SpawnProjectile use fabs(cos(pitch)): a pitch over 90 still throws forward
			kidPos = p + (0, 0, h);
			kidVel = (cos(a) * cp * spd, sin(a) * cp * spd, sin(pit) * spd);
			kidAng = a;
			// P_CheckMissileSpawn(missile, shooter's radius) (p_mobj.cpp): the engine moves every A_CustomMissile /
			// A_SpawnProjectile child forward by its velocity, halved (at least once) until its xy part is under the
			// shooter's radius, before the child's first tick
			double r = d.kPRad[k];
			if (r > 0)
			{
				Vector3 adv = kidVel;
				do { adv *= 0.5; } while (adv.xy.LengthSquared() >= r * r);
				kidPos += adv;
			}
		}
		else if (mode == RSQGO_Data.M_ITEMEX)
		{
			double x = R(b, isPlay);
			double y = R(b + 2, isPlay);
			double z = R(b + 4, isPlay);
			double vx = R(b + 6, isPlay);
			double vy = R(b + 8, isPlay);
			double vz = R(b + 10, isPlay);
			double an = R(b + 12, isPlay);
			int fl = d.kFlags[k];
			double da = (fl & SXF_ABSOLUTEANGLE) ? an : pang + an;
			double s = sin(da);
			double co = cos(da);
			double ox = x * co + y * s;
			double oy = x * s - y * co;
			if (fl & SXF_ABSOLUTEPOSITION) { ox = x; oy = y; }
			kidPos = (p.x + ox, p.y + oy, p.z + z);
			if (fl & SXF_ABSOLUTEVELOCITY) kidVel = (vx, vy, vz);
			else kidVel = (vx * co + vy * s, vx * s - vy * co, vz);
			kidAng = da;
		}
		else
		{
			double dist = R(b, isPlay);
			double zh = R(b + 2, isPlay);
			kidPos = p + (cos(pang) * dist, sin(pang) * dist, zh);
			kidVel = (0, 0, 0);
			kidAng = pang;
		}
	}

	double KidSpeed(int k)
	{
		int child = data.kCard[k];
		if (child >= 0) return data.cSpeed[child];
		let cls = data.kClsC[k];
		return cls ? GetDefaultByType(cls).Speed : 0;
	}

	// A random range: the playsim RNG for anything an actor depends on, the handler's xorshift for cosmetics.
	double R(int b, bool isPlay)
	{
		double lo = data.kR[b];
		double hi = data.kR[b + 1];
		if (lo == hi) return lo;
		return isPlay ? frandom[RSQGO_Play](lo, hi) : lo + (hi - lo) * Rand01();
	}

	// ================================================================ the flight
	// Gravity as the engine applies it to the actor (GetGravity: level gravity x sector gravity x Gravity / 800).
	double Grav(int c, Actor src)
	{
		double sg = (src && src.CurSector) ? src.CurSector.gravity : 1.0;
		return data.cGrav[c] * level.gravity * sg * 0.00125;
	}

	// Position after t moves: the engine moves first and then applies gravity, as RSQGO_VT does (pos += vel; vel.z -= g).
	static Vector3 PosAt(Vector3 p0, Vector3 v0, double g, int t)
	{
		return p0 + v0 * t - (0, 0, g * t * (t - 1) * 0.5);
	}

	static double FloorAt(Vector3 p)
	{
		let s = level.PointInSector(p.xy);
		return s ? s.floorplane.ZatPoint(p.xy) : p.z - 4096;
	}

	// The first move count after which the path is at or below height zf, or -1 if not within `limit` moves.
	// The engine tests the floor after each move (P_ZMovement), never before the first: a drop spawned on the floor
	// that rises (BD's arterial sprays fire their drops from the floor) flies on.
	static int TimeToZ(double z0, double vz, double g, double zf, int limit)
	{
		if (limit < 1) return -1;
		if (z0 + vz <= zf) return 1;
		double t;
		if (g <= 0.000001)
		{
			if (vz >= 0) return -1;
			t = (zf - z0) / vz;
		}
		else
		{
			double a = g * 0.5;
			double b = -(vz + g * 0.5);
			double cc = zf - z0;
			double disc = b * b - 4 * a * cc;
			if (disc < 0) return 1;
			t = (-b + sqrt(disc)) / (2 * a);
		}
		int ti = max(1, int(ceil(t)));
		return (ti <= limit) ? ti : -1;
	}

	// Where a missile's path ends within `life` moves: flyHit (floor, wall, ceiling or none), flyT (the moves it makes
	// up to and including the one that meets the surface; its actor dies in its tick flyT-1), flyPos, flyDir,
	// flySector; returns the wall's line (flySide: the side it came from). One trace along the chord from the start to
	// where the path meets the floor under it (within STEP_FLOOR, as the engine) or to its end of life; if that floor
	// is lower where it ends (a ledge), the fall continues to it. Under water (sink < 0) the fall is FallAndSink's: no
	// gravity, a pull toward `sink`, damped by the floor's friction every tic. Geometry only: the same on every machine.
	// boxRad != 0: the floor is the missile's own floorz, the highest floor its box touches (P_FindFloorCeiling), as
	// BD's drop lands (FloorFor: > 0 playsim callers via the probe, < 0 cosmetic callers via the footprint).
	Line Fly(Actor src, Vector3 p0, Vector3 v0, double g, int life, bool water = false, double sink = 0, double boxRad = 0)
	{
		flyHit = HIT_NONE;
		flyT = life;
		flySector = null;
		flySide = 0;
		flySky = false;
		if (life <= 0) return null;
		double fz = FloorFor(p0, boxRad);
		bool sky0 = boxSky;
		int tf;
		Vector3 pT;
		if (water)
		{
			// step it: a few dozen tics at most (BD's Underblood lives 26-52)
			double fr = WaterFriction(p0);
			double z = p0.z;
			double vz = v0.z;
			tf = -1;
			for (int st = 1; st <= life; st++)
			{
				z += vz;
				vz = SinkStep(z, vz, fz, sink) * fr;
				if (z <= fz + STEP_FLOOR) { tf = st; break; }
			}
			int wn = (tf >= 0) ? tf : life;
			pT = (p0.x + v0.x * wn, p0.y + v0.y * wn, (tf >= 0) ? fz : z);
		}
		else
		{
			tf = TimeToZ(p0.z, v0.z, g, fz + STEP_FLOOR, life);
			pT = PosAt(p0, v0, g, (tf >= 0) ? tf : life);
			if (tf >= 0) pT.z = fz;
		}
		int moves = (tf >= 0) ? tf : life;
		flyPos = pT;
		Vector3 dv = level.Vec3Diff(p0, pT);
		double len = dv.Length();
		flyDir = len > 0.001 ? dv / len : (0, 0, -1);
		if (len >= MIN_TRACE)
		{
			FLineTraceData tr;
			src.LineTrace(atan2(dv.y, dv.x), len + 2, -atan2(dv.z, dv.xy.Length()), TRF_THRUACTORS | TRF_ABSPOSITION,
				p0.z, p0.x, p0.y, tr);
			if (tr.HitType != TRACE_HitNone && tr.Distance < len - 1)
			{
				flyT = max(1, int(ceil(moves * tr.Distance / len)));
				flyPos = tr.HitLocation;
				flySector = tr.HitSector;
				if (tr.HitType == TRACE_HitFloor) flyHit = HIT_FLOOR;
				else if (tr.HitType == TRACE_HitWall) flyHit = HIT_WALL;
				else flyHit = HIT_CEILING;
				flySide = tr.LineSide;
				return flyHit == HIT_WALL ? tr.HitLine : null;
			}
		}
		if (tf < 0) return null;
		double fz2 = water ? fz : FloorFor((pT.x, pT.y, p0.z), boxRad);
		bool sky2 = water ? sky0 : boxSky;
		if (fz2 < fz - 2)
		{
			int tf2 = TimeToZ(p0.z, v0.z, g, fz2 + STEP_FLOOR, life);
			if (tf2 < 0) { flyPos = PosAt(p0, v0, g, life); return null; }
			flyT = tf2;
			flyPos = PosAt(p0, v0, g, tf2);
			flyPos.z = fz2;
			flySky = sky2;
		}
		else
		{
			flyT = tf;
			flySky = sky0;
		}
		flyHit = HIT_FLOOR;
		return null;
	}

	// The floor a drop meets at p: its box floorz, the highest floor its box touches (P_FindFloorCeiling). boxRad > 0:
	// a playsim caller, through the residue's probe actor (BoxFloor, 3D floors included); boxRad < 0: a cosmetic-only
	// drop of radius -boxRad, through the probe-free footprint (BoxFloorPure: moves no actor, no RNG, safe per
	// machine); 0: the floor under the point. boxSky: that floor is a sky.
	double FloorFor(Vector3 p, double boxRad)
	{
		boxSky = false;
		if (boxRad < 0)
		{
			double pfz;
			bool psky;
			[pfz, psky] = RSQGO_ResidueRings.BoxFloorPure(p, -boxRad);
			boxSky = psky;
			return pfz;
		}
		if (boxRad > 0)
		{
			if (!res) res = RSQGO_ResidueRings.Get(true);
			if (res)
			{
				double fz;
				bool sky;
				[fz, sky] = res.BoxFloor(p, boxRad);
				boxSky = sky;
				return fz;
			}
		}
		let s = level.PointInSector(p.xy);
		if (!s) return p.z - 4096;
		boxSky = s.GetTexture(Sector.floor) == skyflatnum;
		return s.floorplane.ZatPoint(p.xy);
	}

	// FallAndSink under water for a non-player (p_mobj.cpp): above the floor, a vertical speed below `sink` slows by
	// 2 x sink toward it, one above it falls by sink/3 toward it. The caller multiplies by the friction after.
	static double SinkStep(double z, double vz, double fz, double sink)
	{
		if (z <= fz + STEP_FLOOR) return vz;
		if (vz < sink)
		{
			vz -= max(sink * 2, -8.);
			if (vz > sink) vz = sink;
		}
		else if (vz > sink)
		{
			vz += max(sink / 3, -8.);
			if (vz < sink) vz = sink;
		}
		return vz;
	}

	static double WaterFriction(Vector3 p)
	{
		let s = level.PointInSector(p.xy);
		if (!s) return 0.90625;
		double fr, mf;
		[fr, mf] = s.GetFriction(Sector.floor);
		return fr;
	}

	// ================================================================ what shows (cosmetic)
	// A drop's track by BD's odds among those for its water (a class with no wet tracks shows the same either way).
	int PickTrack(int c, bool uw)
	{
		let d = data;
		int first = d.cVar0[c];
		int n = d.cVarN[c];
		double sum = 0;
		for (int i = first; i < first + n; i++) if (d.vWet[i] == uw) sum += d.vW[i];
		if (sum <= 0)
		{
			// under water with no wet track: the dry ones (the class shows the same either way); on dry land with only
			// wet tracks: nothing (Underblood2's dry Spawn jumps straight to Splash, BLOD A 0, stop)
			return uw ? PickTrack(c, false) : -1;
		}
		double r = Rand01() * sum;
		int last = first;
		for (int i = first; i < first + n; i++)
		{
			if (d.vWet[i] != uw) continue;
			last = i;
			r -= d.vW[i];
			if (r <= 0) return i;
		}
		return last;
	}

	int PickVar(int first, int n)
	{
		if (n <= 1) return first;
		double sum = 0;
		for (int i = 0; i < n; i++) sum += data.vW[first + i];
		double r = Rand01() * sum;
		for (int i = 0; i < n; i++)
		{
			r -= data.vW[first + i];
			if (r <= 0) return first + i;
		}
		return first + n - 1;
	}

	// One TRACK (variant v of card c), the part of BD's actor from tick tS (where it is at ps with velocity vs, before
	// that tick's move) to before tick tE (-1: its life), its actor spawned `delay` tics from now. skip: the track starts
	// that many tics in (a blood whose chain ran before its first tick). Played by a VisualThinker.
	void EmitVar(int v, int c, Vector3 ps, Vector3 vs, double g, int delay, int tS, int tE, int skip, bool water = false, double sink = 0)
	{
		let d = data;
		int start = d.vStart[v];
		int t1 = max(tS, start);
		int tEnd = start + d.vLife[v];
		if (tE >= 0) tEnd = min(tEnd, tE);
		if (tEnd <= t1) return;
		int first = t1 - start + skip;
		int life = tEnd - start;
		if (first >= life) return;
		Vector3 p = PosAt(ps, vs, g, t1 - tS);
		Vector3 vel = vs - (0, 0, g * (t1 - tS));
		int at = delay + t1;
		if (at > 0) PushEmit(v, c, p, vel, g, life, at, first, water, sink);
		else SpawnVT(v, c, p, vel, g, life, first, water, sink);
	}

	// The same with a translation of its own (a hit blood's, from the bleeder; a VisualThinker job cannot carry one):
	// spawned now, hidden until its first visible tic, moving from now on.
	void EmitVarT(int v, int c, Vector3 ps, Vector3 vs, double g, int delay, int tS, int tE, int skip, TranslationID tr)
	{
		let d = data;
		int start = d.vStart[v];
		int t1 = max(tS, start);
		int tEnd = start + d.vLife[v];
		if (tE >= 0) tEnd = min(tEnd, tE);
		if (tEnd <= t1) return;
		int first = t1 - start + skip;
		int life = tEnd - start;
		if (first >= life) return;
		int at = max(0, delay + t1);
		int k = max(0, t1 - tS - at);
		SpawnVT(v, c, PosAt(ps, vs, g, k), vs - (0, 0, g * k), g, life, first - at, false, 0, true, tr);
	}

	// A landing splash: group grp (the flight track that landed) when the card has splashes per flight track.
	void Splash(int c, int first, int n, Vector3 p, int at, int grp)
	{
		if (n <= 0 || !Accept(p, data.cCat[c], false)) return;
		let d = data;
		int v = -1;
		if (d.vGrp[first] >= 0)
		{
			double sum = 0;
			for (int i = first; i < first + n; i++) if (d.vGrp[i] == grp) sum += d.vW[i];
			if (sum > 0)
			{
				double r = Rand01() * sum;
				for (int i = first; i < first + n; i++)
				{
					if (d.vGrp[i] != grp) continue;
					v = i;
					r -= d.vW[i];
					if (r <= 0) break;
				}
			}
		}
		if (v < 0) v = PickVar(first, n);
		EmitVar(v, c, p, (0, 0, 0), 0, at, 0, -1, 0);
	}

	// The VisualThinker that plays track v. It is drawn by the engine's sprite path (hw_sprites.cpp
	// AdjustVisualThinker): the texture's sprite rectangle, offsets included, times Scale, exactly as HWSprite::Process
	// draws an actor's sprite (r.Scale(sprscale.X, sprscale.Y)); lit by its sector unless the frame is Bright; BD's
	// render style. So BD's frame at BD's scale shows at BD's size.
	// own: draw it through tr, else through BD's class translation (ClassTrans).
	void SpawnVT(int v, int c, Vector3 p, Vector3 vel, double g, int life, int first, bool water = false, double sink = 0,
		bool own = false, TranslationID tr = 0)
	{
		let d = data;
		if (!own) tr = ClassTrans(c);
		int k0 = d.vKf0[v];
		if (d.vKfN[v] <= 0) return;
		// Never in the viewer's face (cosmetic, per machine): nothing spawns within NEAR_CUT of this machine's eye.
		CosmeticFrame();
		if (camOk && (p - camPos).Length() < NEAR_CUT)
		{
			statCulled++;
			return;
		}
		// Draw order. BD draws a child over its parent where they stand in the same place (LiquidBlood's trail drops,
		// spawned on it each tic, hide it): the newer actor wins the tie. Our VisualThinkers all go to the engine's
		// translucent list, sorted by distance, where float drift decides a tie. So each generation stands a hair
		// nearer along this machine's line of sight (0.05 units a generation: no visible shift, cosmetic only).
		if (camOk && vtDepth > 0)
		{
			Vector3 dc = camPos - p;
			double dl = dc.Length();
			if (dl > 1) p += dc * (0.05 * min(vtDepth, MAX_DEPTH + 2) / dl);
		}
		int tx = d.fTex[k0];
		TextureID tex = tx >= 0 ? d.tTex[tx] : d.tTex[0];
		let vt = RSQGO_VT(VisualThinker.Spawn("RSQGO_VT", tex, p, vel, 0, 0, 0, (1, 1), (0, 0), d.cStyle[c], tr));
		if (!vt) return;
		// a non-missile (SuperGore) and a NOCLIP missile come to rest on the floor; only a non-missile slides to a stop
		bool rest = (!d.cMissile[c] || d.cNoclip[c]) && !d.cNoInter[c];
		vt.StartTrack(d, v, life, first, g, rest, !d.cMissile[c], water, sink, water ? WaterFriction(p) : 1);
		int left = life - first;
		if (ring.Size() == RING_SIZE && left > 0)
		{
			live++;
			ring[(level.maptime + min(left, RING_SIZE - 1)) % RING_SIZE]++;
		}
		statParticles++;
	}

	// The cosmetic gate for one track: the live budget, then density by distance to this machine's camera (full
	// under 512, half to 1536, a quarter beyond, no mist past 3072), Spray And Mist, and the frame-time guard.
	bool Accept(Vector3 p, int cat, bool puff)
	{
		CosmeticFrame();
		if (live >= capNow) { statCulled++; return false; }
		if (puff) return true;
		double f = densNow;
		if (camOk)
		{
			double dist = (p - camPos).Length();
			if (cat == RSQGO_Data.C_MIST && dist > 3072) f = 0;
			else if (dist >= 1536) f *= 0.25;
			else if (dist >= 512) f *= 0.5;
		}
		if (f >= 1) return true;
		if (f <= 0)
		{
			if (oneLeft > 0) { oneLeft--; return true; }
			statCulled++;
			return false;
		}
		if (Rand01() < f) return true;
		statCulled++;
		return false;
	}

	// The cosmetic settings are user cvars: this machine's own player's values (design 2.1: the cosmetic tier may differ
	// per machine). A user cvar cannot be read by name directly in ZScript.
	static int LocalI(Name n, int def)
	{
		let p = players[consoleplayer];
		let c = CVar.GetCVar(n, p);
		return c ? c.GetInt() : def;
	}

	// Once a tic: the camera, the budget cap and the density factor (rsqgo_fx and the guard).
	void CosmeticFrame()
	{
		if (frameTic == level.maptime && frameOk) return;
		frameTic = level.maptime;
		frameOk = true;
		let cam = players[consoleplayer].camera;
		camOk = cam != null;
		// the eye, not the feet (the near cut and the distance bands are about what the viewer sees)
		if (camOk) camPos = (cam.pos.xy, cam.player ? cam.player.viewz : cam.pos.z + cam.height * 0.5);
		capNow = PartCap();
		int fx = LocalI('rsqgo_fx', 2);
		densNow = fx >= 2 ? 1.0 : (fx == 1 ? 0.5 : 0.0);
		bool guard = rsqgo_platform == 1 ? LocalI('rsqgo_guard_quest', 1) != 0 : LocalI('rsqgo_guard_pc', 0) != 0;
		// the guard sees frames slower than a tic (under 35 fps): then tics arrive in bursts with long gaps between
		if (guard)
		{
			if (gapEma > 40) densNow *= 0.25;
			else if (gapEma > 31) densNow *= 0.5;
		}
	}

	// Live tracks we may have: a share of r_maxparticles (the engine's pool, shared with every other mod).
	int PartCap()
	{
		let mp = CVar.FindCVar("r_maxparticles");
		int maxp = mp ? mp.GetInt() : 4000;
		bool quest = rsqgo_platform == 1;
		int fx = LocalI('rsqgo_fx', 2);
		int pct;
		int pAll = LocalI('rsqgo_part_all', 50), pSome = LocalI('rsqgo_part_some', 25), pQuest = LocalI('rsqgo_part_quest', 25), pNone = LocalI('rsqgo_part_none', 5);
		if (fx >= 2) pct = quest ? pQuest : pAll;
		else if (fx == 1) pct = quest ? pQuest * pSome / max(1, pAll) : pSome;
		else pct = pNone;
		return maxp * clamp(pct, 0, 100) / 100;
	}

	// xorshift32: per machine, never a shared RNG (design 2.1)
	double Rand01()
	{
		uint x = rngState;
		if (x == 0) x = uint(MSTime()) | 1;
		x ^= x << 13;
		x ^= x >>> 17;
		x ^= x << 5;
		rngState = x;
		return (x >>> 8) / 16777216.0;
	}

	// ================================================================ the cosmetic schedule
	// J_EMIT: jA track, jB card, jLife life, jI first, jAcc gravity, jAng the sink speed (0: not under water).
	void PushEmit(int v, int c, Vector3 p, Vector3 vel, double g, int life, int at, int first, bool water, double sink)
	{
		PushJob(J_EMIT, at, v, c, life, p, vel, g, water ? min(sink, -0.000001) : 0, first, 0, 0, 0, false, vtDepth);
	}

	void PushSound(int c, Vector3 p, int at)
	{
		PushJob(J_SOUND, at, 0, c, 0, p, (0, 0, 0), 0, 0, 0, 0, 0, 0, false, 0);
	}

	// J_TRAIL: jA child spawn, jB child card, jLife the tic the parent stops (-1 never), jI the next copy.
	void PushTrail(int k, int child, Vector3 p0, Vector3 v0, double g, double pang, int delay, int posOff, int i0, int tEnd, bool uw,
		int kdepth)
	{
		PushJob(J_TRAIL, delay + data.kTic[k] + i0 * data.kInterval[k], k, child, tEnd, p0, v0, g, pang, i0, data.kCount[k],
			data.kInterval[k], posOff, uw, kdepth);
	}

	private void PushJob(int kind, int at, int a, int b, int life, Vector3 p, Vector3 vel, double acc, double ang, int i, int count,
		int interval, int off, bool uw, int dep)
	{
		jDue.Push(level.maptime + max(0, at)); jKind.Push(kind); jA.Push(a); jB.Push(b); jLife.Push(life);
		jPX.Push(p.x); jPY.Push(p.y); jPZ.Push(p.z); jVX.Push(vel.x); jVY.Push(vel.y); jVZ.Push(vel.z);
		jAcc.Push(acc); jAng.Push(ang); jI.Push(i); jCount.Push(count); jInterval.Push(interval); jOff.Push(off); jUw.Push(uw); jDep.Push(dep);
	}

	// Job r moves to slot w (the one-pass compaction in CosmeticTick).
	private void MoveJob(int w, int r)
	{
		jDue[w] = jDue[r]; jKind[w] = jKind[r]; jA[w] = jA[r]; jB[w] = jB[r]; jLife[w] = jLife[r];
		jPX[w] = jPX[r]; jPY[w] = jPY[r]; jPZ[w] = jPZ[r]; jVX[w] = jVX[r]; jVY[w] = jVY[r]; jVZ[w] = jVZ[r];
		jAcc[w] = jAcc[r]; jAng[w] = jAng[r]; jI[w] = jI[r]; jCount[w] = jCount[r]; jInterval[w] = jInterval[r];
		jOff[w] = jOff[r]; jUw[w] = jUw[r]; jDep[w] = jDep[r];
	}

	private void CutJobs(int at, int n)
	{
		jDue.Delete(at, n); jKind.Delete(at, n); jA.Delete(at, n); jB.Delete(at, n); jLife.Delete(at, n);
		jPX.Delete(at, n); jPY.Delete(at, n); jPZ.Delete(at, n); jVX.Delete(at, n); jVY.Delete(at, n); jVZ.Delete(at, n);
		jAcc.Delete(at, n); jAng.Delete(at, n); jI.Delete(at, n); jCount.Delete(at, n); jInterval.Delete(at, n);
		jOff.Delete(at, n); jUw.Delete(at, n); jDep.Delete(at, n);
	}

	void CosmeticTick()
	{
		int now = level.maptime;
		if (ring.Size() != RING_SIZE)
		{
			ring.Clear();
			for (int i = 0; i < RING_SIZE; i++) ring.Push(0);
			live = 0;
		}
		int slot = now % RING_SIZE;
		live = max(0, live - ring[slot]);
		ring[slot] = 0;
		double ms = MSTimeF();
		double gap = ms - lastMs;
		lastMs = ms;
		if (gap > 2 && gap < 500) gapEma = gapEma * 0.9 + gap * 0.1;
		sndCells.Clear();
		// arrays of an older layout (a save from before jOff / jUw): start the schedule over (it is cosmetic)
		if (jOff.Size() != jDue.Size() || jUw.Size() != jDue.Size() || jDep.Size() != jDue.Size())
		{
			int nOld = jDue.Size();
			if (nOld > 0) CutJobs(0, nOld);
			jOff.Clear();
			jUw.Clear();
			jDep.Clear();
		}
		let tracer = players[consoleplayer].mo;
		// One pass: due jobs run in order, kept ones slide down to w, and the gap [w, n0) is cut once at the end. Jobs
		// pushed while this runs sit past n0 (some due this tic): they slide down with the cut and run next tic.
		int n0 = jDue.Size();
		int w = 0;
		for (int r = 0; r < n0; r++)
		{
			bool keep = true;
			if (jDue[r] <= now)
			{
				keep = false;
				Vector3 p = (jPX[r], jPY[r], jPZ[r]);
				int kind = jKind[r];
				if (kind == J_EMIT)
				{
					double sink = jAng[r];
					vtDepth = jDep[r];
					SpawnVT(jA[r], jB[r], p, (jVX[r], jVY[r], jVZ[r]), jAcc[r], jLife[r], jI[r], sink < 0, sink);
				}
				else if (kind == J_SOUND)
				{
					// landing sounds, one per 128-unit cell a tic (design 5: rate-limited per cell)
					int cell = (int(p.x) >> 7) * 4099 + (int(p.y) >> 7);
					if (sndCells.Find(cell) == sndCells.Size())
					{
						sndCells.Push(cell);
						S_StartSoundAt(p, data.cLandSound[jB[r]], CHAN_BODY);
					}
				}
				else
				{
					// one drop of a trail at the parent's position on its tic
					int k = jA[r];
					int iv = data.kInterval[k];
					int tic = data.kTic[k] + jI[r] * iv;
					int tEnd = jLife[r];
					if ((tEnd < 0 || tic < tEnd) && tracer)
					{
						KidAt(k, PosAt(p, (jVX[r], jVY[r], jVZ[r]), jAcc[r], tic + jOff[r]), jAng[r], false);
						statAvoided++;
						Process(jB[r], tracer, kidPos, kidVel, kidAng, 0, jDep[r], jUw[r]);
					}
					jI[r]++;
					if (jI[r] < jCount[r] && (tEnd < 0 || tic + iv < tEnd))
					{
						jDue[r] = jDue[r] + max(1, iv);
						keep = true;
					}
				}
			}
			if (keep)
			{
				if (w != r) MoveJob(w, r);
				w++;
			}
		}
		if (w < n0) CutJobs(w, n0 - w);
	}
}

// ============================================================================
// RSQGO_VT -- plays one TRACK: BD's actor, tic by tic, as a VisualThinker. Every tic it takes the keyframe for its age
// (texture, x/y scale with BD's mirror, alpha, Bright) and moves by its velocity under its gravity, as BD's actor would;
// a non-missile comes to rest on the floor (BD's SuperGore) and slides to a stop by the floor's friction; under water it
// sinks as FallAndSink makes it. It is gone when BD's actor would be (its life, or the tic its path ends). Cosmetic:
// per machine, never a shared RNG, never an actor. Ticked by the engine (Super.Tick moves it and keeps its sector);
// after a load it finds its data again or leaves.
// ============================================================================
class RSQGO_VT : VisualThinker
{
	int trk, age, life, kf, kfFirst, kfEnd, shown, loopFrom, loopPer;
	double grav, sink, wfric;
	bool rest, slide, water, onFloor;
	transient RSQGO_Data d;

	// first: the track tic it shows on the frame of the tic it spawns (it is ticked that tic too); negative: hidden
	// until then.
	void StartTrack(RSQGO_Data dd, int v, int lf, int first, double g, bool restOnFloor, bool slides, bool uw, double sk,
		double wf)
	{
		d = dd;
		trk = v;
		life = lf;
		grav = g;
		rest = restOnFloor;
		slide = slides;
		water = uw;
		sink = sk;
		wfric = wf;
		kfFirst = d.vKf0[v];
		kfEnd = kfFirst + d.vKfN[v];
		kf = kfFirst;
		shown = -1;
		loopFrom = d.vLoopFrom[v];
		loopPer = d.vLoopPer[v];
		age = first - 1;
		ShowAt(age);
	}

	void ShowAt(int t)
	{
		if (t < 0)
		{
			shown = -1;
			Alpha = 0;
			return;
		}
		if (loopPer > 0 && t >= loopFrom + loopPer) t = loopFrom + (t - loopFrom) % loopPer;
		if (t < d.fTic[kf]) kf = kfFirst;
		while (kf + 1 < kfEnd && d.fTic[kf + 1] <= t) kf++;
		if (kf == shown) return;
		shown = kf;
		int tx = d.fTex[kf];
		if (tx < 0)
		{
			Alpha = 0;
			return;
		}
		Texture = d.tTex[tx];
		// BD's x mirror as the sprite flip; BD's negative y scale as is: the engine's sprite rect scaled by it hangs the
		// sprite below its origin, upside down, exactly as an actor's (hw_sprites.cpp: r.Scale(Scale.X, Scale.Y))
		double sx = d.fSX[kf];
		double sy = d.fSY[kf];
		Scale = (abs(sx), sy);
		bXFlip = sx < 0;
		bYFlip = false;
		Alpha = d.fA[kf];
		Flags = d.fBright[kf] ? SPF_FULLBRIGHT : 0;
	}

	double FloorHere()
	{
		return CurSector ? CurSector.floorplane.ZatPoint(Pos.XY) : Pos.Z - 4096;
	}

	override void Tick()
	{
		if (!d)
		{
			let m = RSQGO_Manager.Get();
			if (!m || !m.Ready()) { Destroy(); return; }
			d = m.data;
			if (trk >= d.vW.Size()) { Destroy(); return; }
		}
		if (IsFrozen()) { Super.Tick(); return; }
		age++;
		if (age >= life) { Destroy(); return; }
		ShowAt(age);
		// the engine's order for an actor: xy friction on the floor (P_XYMovement, not for a missile), the move, then
		// gravity (p_mobj.cpp); the same as cards.py's track timing
		if (onFloor && slide)
		{
			if (abs(Vel.X) < 1. / 16 && abs(Vel.Y) < 1. / 16) { Vel.X = 0; Vel.Y = 0; }
			else
			{
				double fr = 0.90625;
				double mf;
				if (CurSector) { [fr, mf] = CurSector.GetFriction(Sector.floor); }
				Vel.X *= fr;
				Vel.Y *= fr;
			}
		}
		Super.Tick();
		if (water)
		{
			Vel.Z = RSQGO_Manager.SinkStep(Pos.Z, Vel.Z, FloorHere(), sink) * wfric;
		}
		else if (grav != 0)
		{
			if (rest)
			{
				double fz = FloorHere();
				if (Pos.Z <= fz + RSQGO_Manager.STEP_FLOOR)
				{
					Pos.Z = fz + 1;
					if (Vel.Z < 0) Vel.Z = 0;
					onFloor = true;
				}
				else
				{
					Vel.Z -= grav;
					onFloor = false;
				}
			}
			else Vel.Z -= grav;
		}
	}
}
