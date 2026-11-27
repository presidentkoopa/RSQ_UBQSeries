// RS_TravelBeam: a monster's railgun as a TRAVELLING BEAM (owner 2026-11-17).
//
// "Our bosses cannot fire hitscans. Given that this is an arcadey-type game, we need to be able to see their attacks."
// "if the player engages slomo in any way, insta-hitscan attacks become an issue". No More Hitscans turns the monsters'
// bullets into tracers, but a railgun (A_CustomRailgun) goes through the engine's rail path, not WorldHitscanPreFired,
// so every damaging monster rail now fires through RS_TravelBeam.Fire instead:
//   - the wind-up is the monster's own (its states before the call are unchanged);
//   - the beam HEAD leaves the gun from the rail's own start point, aimed exactly as A_CustomRailgun aims (its offsets,
//     its aim / veleffect / spread, the shadow wobble) and flies at No More Hitscans' nmh_projspeed (80 without NMH).
//     It is a real missile, so RSQ SlowMo slows it like any enemy round;
//   - the stretch from the gun to the head is drawn as the head flies: the rail's own spawn actors where it had them
//     (spaced as the engine spaces them, target / angle / pitch set as the engine sets them, so they look and act as
//     the original beam did), else the rail's own spiral and core particles (its colours, duration, drift, maxdiff),
//     over a held core line in the rail's colour so the whole beam stays lit until it lands;
//   - only the head hurts: the rail's exact damage, damage type (the puff's, else 'Railgun'), puff, blood and flags,
//     dealt as P_RailAttack deals them. Without RGF_NOPIERCING the head rips through everything in its path, each
//     thing hit once. Step out of the path before the head arrives and it misses. (A rail's own spawn actors that
//     burst or burn, the Kamehameha's and the White Mancubus's, still do so where the beam has passed, as they did
//     along the instant rail);
//   - after it lands the full beam holds HOLDTICS, then fades.
// A rail with no damage (the laser sights, A_CustomRailgun(0, ...)) is never sent here.
//
// One line per call site: { RS_TravelBeam.Fire(self, <A_CustomRailgun's own arguments, unchanged>); }
// Stock QuestZDoom 17.3, ZScript only.

class RS_TravelBeam : Actor
{
	const HOLDTICS = 6;       // the landed beam holds this long (world tics: RSQ SlowMo stretches it with the world)
	const FADETICS = 10;      // then fades over this long
	const CORESTEP = 6.0;     // the held core line: a particle every this many units
	const CORETTL = 6;        // and each stretch of it is redrawn this often while the beam lives
	const MAXLIFE = 35 * 20;  // never alive longer than this (a head held still by something else)

	// the rail
	int railDamage, railFlags, railDuration, spiralOfs;
	Color col1, col2, coreCol;
	double maxDiff, sparsity, drift, range;
	class<Actor> puffCls, spawnCls;
	Name dmgType;
	int puffFlags;
	bool stopAtInvul, thruFlags, thruGhosts, thruSpecies, thruActors, useThruBits;
	Name puffSpecies;
	int puffThruBits;
	double beamYaw, beamPitch;
	Vector3 aimDir;           // the rail's line; held through the first tic (see Tick)
	bool aimHeld;

	// the flight
	int phase;                // 0 flying, 1 landed (holding), 2 fading
	Vector3 landPos;
	double travelled, pathLen;
	int age;                  // its own tics, counted only while the world runs (a frozen world freezes its particles too)
	Array<Actor> hitList;

	// the drawing
	double nextSpawn, nextSpiral, nextInner, spawnStep, partStep, spiralDeg;
	Vector3 diff;             // maxdiff's random walk, as P_DrawRailTrail walks it
	Array<double> chA, chB;   // the held core line, in stretches: start / end as path distances
	Array<double> chX0, chY0, chZ0, chX1, chY1, chZ1;
	Array<int> chExp;         // the age each stretch's particles run out at
	transient Service smSvc;
	transient bool smLooked;

	Default
	{
		+MISSILE
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTELEPORT
		+FORCEXYBILLBOARD
		+NOTONAUTOMAP
		Radius 2;
		Height 2;
		Speed 80;
		RenderStyle "AddShaded";
		Alpha 1.0;
		Scale 0.13;
	}

	States
	{
	Spawn:
		RSF3 A -1 Bright;
		Stop;
	Hold:
		RSF3 A HOLDTICS Bright;
		TNT1 A 0 { Release(); }
	Fade:
		RSF3 A 1 Bright A_FadeOut(0.2);
		Wait;
	}

	// ---- THE CALL: A_CustomRailgun's own signature, so a call site keeps its arguments as they were ------------------
	static RS_TravelBeam Fire(Actor src, int damage, int spawnofs_xy = 0, color color1 = 0, color color2 = 0, int flags = 0,
		int aim = 0, double maxdiff = 0, class<Actor> pufftype = "BulletPuff", double spread_xy = 0, double spread_z = 0,
		double range = 0, int duration = 0, double sparsity = 1.0, double driftspeed = 1.0, class<Actor> spawnclass = null,
		double spawnofs_z = 0, int spiraloffset = 270, int limit = 0, double veleffect = 3)
	{
		if (!src) return null;
		if (range == 0) range = 8192;
		if (sparsity == 0) sparsity = 1;
		if (aim && !src.target) return null;
		if (src.bSTEALTH) src.visdir = 1;
		src.bAMBUSH = false;

		// THE AIM, as A_CustomRailgun aims (p_actionfunctions.cpp)
		double yaw = src.angle;
		if (aim) yaw = src.AngleTo(src.target);
		FTranslatedLineTarget t;
		double pitch = src.AimLineAttack(yaw, MISSILERANGE, t, 60, 0, aim ? src.target : null);
		if (!t.linetarget && aim)
		{
			Vector2 xyd = src.Vec2To(src.target);
			double zd = (src.target.pos.z + src.target.Height * 0.5) - (src.pos.z + src.Height * 0.5) - src.Floorclip;
			pitch = -VectorAngle(xyd.Length(), zd);
		}
		Vector2 base = src.pos.xy;
		if (aim)
		{
			// the aim trails behind a moving target; the shooter keeps this angle afterwards, as it does for a rail
			yaw = VectorAngle(src.Vec2To(src.target) - src.target.vel.xy * veleffect);
			src.angle = yaw;
			if (aim == 2)   // CRF_AIMDIRECT: offset first, then aim again from there
			{
				base = level.Vec2Offset(src.pos.xy, AngleToVector(yaw, spawnofs_xy));
				spawnofs_xy = 0;
				Vector2 tgt = src.target.pos.xy - src.target.vel.xy * veleffect;
				yaw = VectorAngle(level.Vec2Diff(base, tgt));
			}
			// a partly invisible target spoils the aim, as A_CustomRailgun_ShadowHandling does
			if (src.target.bSHADOW)
			{
				double pen = src.target.ShadowPenaltyFactor;
				yaw += Random2[RSTravelBeam]() * (45. / 256.) * src.ShadowAimFactor * pen;
				if (src.bSHADOWAIMVERT) pitch += Random2[RSTravelBeam]() * (45. / 256.) * src.ShadowAimFactor * pen;
			}
		}
		if (!(flags & RGF_EXPLICITANGLE))
		{
			spread_xy = spread_xy * Random2[RSTravelBeam]() / 255.;
			spread_z = spread_z * Random2[RSTravelBeam]() / 255.;
		}
		double ang = yaw + spread_xy;
		double pit = pitch + spread_z;

		// THE START, as P_RailAttack places it (p_map.cpp): beside the shooter by spawnofs_xy, at its centre less
		// FloatSpeed, plus spawnofs_z, plus the attack height unless RGF_CENTERZ
		Vector2 sxy = level.Vec2Offset(base, AngleToVector(ang - 90, spawnofs_xy));
		double sz = src.pos.z + src.Height * 0.5 - src.FloatSpeed + spawnofs_z - src.Floorclip;
		if (!(flags & RGF_CENTERZ))
		{
			let pp = PlayerPawn(src);
			sz += (src.player && pp) ? pp.AttackZOffset * src.player.crouchfactor : 8;
		}
		Vector3 dir = (cos(pit) * cos(ang), cos(pit) * sin(ang), -sin(pit));

		let b = RS_TravelBeam(Actor.Spawn("RS_TravelBeam", (sxy, sz), NO_REPLACE));
		if (!b) return null;
		b.target = src;
		b.angle = ang;
		b.pitch = pit;
		b.beamYaw = ang;
		b.beamPitch = pit;
		b.aimDir = dir;
		b.railDamage = damage;
		b.railFlags = flags;
		b.col1 = color1;
		b.col2 = color2;
		b.maxDiff = maxdiff;
		b.range = range;
		b.railDuration = duration;
		b.sparsity = sparsity;
		b.drift = driftspeed;
		b.spawnCls = spawnclass;
		b.spiralOfs = spiraloffset;
		b.SetPuff(pufftype, src);
		b.SetLook();

		// the speed: No More Hitscans' tracer speed, so a beam flies like the bullets beside it
		double spd = 80;
		let cv = CVar.FindCVar("nmh_projspeed");
		if (cv && cv.GetFloat() > 0) spd = cv.GetFloat();
		b.Speed = spd;
		b.vel = dir * spd;   // before its first tic, so RSQ SlowMo (WorldThingSpawned) finds its full speed and scales it

		// the rail's sound, from the head (a rail plays it where the trail passes nearest the listener)
		if (!(flags & RGF_SILENT))
		{
			Sound snd = src.AttackSound;
			if (snd == 0) snd = "weapons/railgf";
			b.A_StartSound(snd, CHAN_WEAPON);
		}
		return b;
	}

	// the puff's say over the hit, as P_RailAttack takes it (the replacement's defaults)
	void SetPuff(class<Actor> pufftype, Actor src)
	{
		if (!pufftype) pufftype = "BulletPuff";
		puffCls = pufftype;
		let rep = GetReplacement(pufftype);
		let pd = GetDefaultByType(rep ? rep : pufftype);
		dmgType = (pd.DamageType == 'None' || pd.DamageType == '') ? Name('Railgun') : pd.DamageType;
		puffFlags = (railFlags & RGF_NORANDOMPUFFZ) ? PF_NORANDOMZ : 0;
		stopAtInvul = !pd.bFOILINVUL;
		thruFlags = pd.bALLOWTHRUFLAGS;
		if (thruFlags)
		{
			thruGhosts = pd.bTHRUGHOST;
			thruSpecies = pd.bTHRUSPECIES;
			thruActors = pd.bTHRUACTORS;
			useThruBits = pd.bALLOWTHRUBITS;
		}
		puffSpecies = pd.Species;
		puffThruBits = pd.ThruBits;
	}

	void SetLook()
	{
		// the core line's colour: the rail's core colour, else its spiral colour, else white
		int c2 = int(col2) & 0xFFFFFF, c1 = int(col1) & 0xFFFFFF;
		coreCol = c2 ? col2 : (c1 ? col1 : Color(255, 255, 255, 255));
		SetShade(coreCol);
		A_AttachLight('RSTravelBeam', DynamicLight.PointLight, coreCol, 48, 48, DynamicLight.LF_ATTENUATE);
		spawnStep = sparsity < 1 ? 32 : sparsity;   // P_DrawRailTrail's spacing for spawn actors
		partStep = max(3 * sparsity, 0.5);         // and for particles (r_rail_spiralsparsity / trailsparsity 1)
		spiralDeg = spiralOfs;
	}

	// RSQ SlowMo's world speed (1 = full), for the particles: SlowMo slows actors, not particles, so slowed
	// particles are spawned slowed (velocity down, life up), as the series' own effects do
	double WorldScale()
	{
		if (!smLooked) { smLooked = true; smSvc = RSQMN_Lookup.Find("RSQSM_Service").Next(); }
		if (!smSvc) return 1.0;
		int s = smSvc.GetInt("scale", "", 0, 0, self);
		if (s <= 0 || s >= 1000) return 1.0;
		return max(s / 1000.0, 0.05);
	}

	// ---- THE FLIGHT ------------------------------------------------------------------------------------------------
	override void Tick()
	{
		if (isFrozen()) { Super.Tick(); return; }
		age++;
		if (phase == 0)
		{
			// THE RAIL'S LINE. A rail is never turned by the mods that turn a spawning missile (Universal Entropy rotates
			// every monster missile by up to 2.75 degrees in WorldThingSpawned, after the head was aimed), so its first
			// tic puts it back on the line it was fired down, at the speed it was given (Speed: RSQ SlowMo's slowing is
			// kept, it scales Speed with the velocity). Later turns (a parry, a return) are left as they are.
			if (!aimHeld)
			{
				aimHeld = true;
				double s = Speed > 0 ? Speed : vel.Length();
				vel = aimDir * s;
			}
			Vector3 from = pos;
			double step = vel.Length();
			bool landed = false;
			Vector3 stopAt = pos;
			if (step > 0)
			{
				double go = min(step, range - travelled);
				Vector3 u = vel / step;
				[landed, stopAt] = Sweep(from, u, go);
				if (!landed && go < step) { landed = true; stopAt = level.Vec3Offset(from, u * go); }
			}
			if (!landed && age > MAXLIFE) { landed = true; stopAt = pos; }
			if (landed)
			{
				Super.Tick();
				if (bDestroyed) return;
				SetOrigin(stopAt, true);
				Land();
			}
			else
			{
				Super.Tick();
				if (bDestroyed) return;
				travelled += step;
			}
			Grow(from, pos);
		}
		else
		{
			Super.Tick();
			if (bDestroyed) return;
			SetOrigin(landPos, true);
			vel = (0, 0, 0);
		}
		Refresh();
	}

	void Land()
	{
		phase = 1;
		landPos = pos;
		vel = (0, 0, 0);
		SetStateLabel("Hold");
	}

	// the head's path this tic: what it meets, in order; returns whether (and where) it stops
	bool, Vector3 Sweep(Vector3 from, Vector3 u, double dist)
	{
		let tr = new("RS_TravelBeamTracer");
		tr.beam = self;
		tr.Trace(from, CurSector, u, dist, TRACE_HitSky, Line.ML_BLOCKEVERYTHING, false, target);
		for (int i = 0; i < tr.hits.Size(); i++)
		{
			let v = tr.hits[i];
			if (!v) continue;
			hitList.Push(v);
			HitThing(v, (tr.hx[i], tr.hy[i], tr.hz[i]), tr.ha[i]);
		}
		if (tr.stopped)   // on a thing: it stopped there (no piercing, STOPRAILS or invulnerable)
			return true, tr.stopPos;
		int ht = tr.Results.HitType;
		if (ht == TRACE_HitWall || ht == TRACE_HitFloor || ht == TRACE_HitCeiling || ht == TRACE_HasHitSky)
		{
			HitWorld(tr, from, u);
			return true, tr.Results.HitPos;
		}
		return false, from;
	}

	// a thing hit: P_RailAttack's own handling of a rail hit, one thing at a time
	void HitThing(Actor victim, Vector3 hp, double hitAngle)
	{
		Actor src = target;
		Actor spawner = src ? src : Actor(self);
		let rep = GetReplacement(puffCls);
		let pd = GetDefaultByType(rep ? rep : puffCls);
		bool spawnpuff;
		bool bleed = false;
		int pf = puffFlags | PF_HITTHING;
		if (victim.bNOBLOOD || victim.bDORMANT || (victim.bINVULNERABLE && !pd.bFOILINVUL))
			spawnpuff = true;
		else
		{
			spawnpuff = pd.bALWAYSPUFF;
			pf |= PF_HITTHINGBLEED;
			if (!pd.bBLOODLESSIMPACT) bleed = true;
		}
		Actor puff;
		if (spawnpuff) puff = spawner.SpawnPuff(puffCls, hp, hitAngle, hitAngle - 90, 1, pf, victim);
		bool temp = false;
		if (!puff)
		{
			// the rail's own inflictor puff (spawned at the shooter, gone once the damage is dealt)
			puff = Actor.Spawn(puffCls, spawner.pos, ALLOW_REPLACE);
			temp = true;
		}
		int df = DMG_INFLICTOR_IS_PUFF | DMG_USEANGLE;
		if (pd.PoisonDamage > 0 && pd.PoisonDuration != int.min)
			victim.PoisonMobj(puff ? puff : spawner, src, pd.PoisonDamage, pd.PoisonDuration, pd.PoisonPeriod, pd.PoisonDamageType);
		if (pd.bFOILINVUL) df |= DMG_FOILINVUL;
		if (pd.bFOILBUDDHA) df |= DMG_FOILBUDDHA;
		int newdam = victim.DamageMobj(puff ? puff : spawner, src, railDamage, dmgType, df, hitAngle);
		if (bleed && victim)
		{
			int bd = newdam > 0 ? newdam : railDamage;
			victim.SpawnBlood(hp, hitAngle, bd);
			victim.TraceBleedAngle(bd, hitAngle, beamPitch);
		}
		if (temp && puff) puff.Destroy();
	}

	// a wall, floor, ceiling or sky: the rail's puff (ALWAYSPUFF only), its decal, an impact line's special
	void HitWorld(RS_TravelBeamTracer tr, Vector3 from, Vector3 u)
	{
		int ht = tr.Results.HitType;
		if (ht == TRACE_HasHitSky) return;
		Actor src = target;
		Actor spawner = src ? src : Actor(self);
		let rep = GetReplacement(puffCls);
		let pd = GetDefaultByType(rep ? rep : puffCls);
		double ha = VectorAngle(-u.x, -u.y);
		if (pd.bALWAYSPUFF)
		{
			let puff = spawner.SpawnPuff(puffCls, tr.Results.HitPos, ha, ha - 90, 1, puffFlags);
			if (puff && ht == TRACE_HitWall && tr.Results.HitLine && tr.Results.HitLine.special == Line_Horizon && !puff.bSKYEXPLODE)
				puff.Destroy();
		}
		if (ht == TRACE_HitWall)
		{
			Name dnn = pd.bFORCEDECAL ? pd.GetDecalName() : spawner.GetDecalName();
			String dn = dnn;
			if (dn != "" && !(dn ~== "none")) A_SprayDecal(dn, tr.Results.Distance + 8, level.Vec3Diff(pos, from), u);
			if (tr.Results.HitLine && src) tr.Results.HitLine.RemoteActivate(src, tr.Results.Side, SPAC_Impact, tr.Results.HitPos);
		}
	}

	// ---- THE BEAM --------------------------------------------------------------------------------------------------
	// the head went from a to b this tic: the stretch gets the rail's own trail (spawn actors or particles) and a held
	// stretch of the core line
	void Grow(Vector3 a, Vector3 b)
	{
		Vector3 seg = level.Vec3Diff(a, b);
		double len = seg.Length();
		if (len <= 0.001) return;
		Vector3 u = seg / len;
		double d0 = pathLen, d1 = pathLen + len;
		double k = WorldScale();
		if (spawnCls)
		{
			while (nextSpawn < d1)
			{
				WalkDiff();
				let th = Actor.Spawn(spawnCls, level.Vec3Offset(a, u * (nextSpawn - d0)) + diff, ALLOW_REPLACE);
				if (th)
				{
					th.target = target;
					th.pitch = beamPitch;
					th.angle = beamYaw;
				}
				nextSpawn += spawnStep;
			}
		}
		else
		{
			bool full = (railFlags & RGF_FULLBRIGHT) != 0;
			int pfl = full ? SPF_FULLBRIGHT : 0;
			// the outer spiral (color1; 0 = the engine's blues)
			Vector3 ext = SpiralArm(u);
			int sttl = railDuration == 0 ? TICRATE : railDuration;
			int c1 = int(col1) & 0xFFFFFF;
			while (nextSpiral < d1)
			{
				Vector3 rv = Rotate(ext, u, spiralDeg);
				Vector3 p = level.Vec3Offset(a, u * (nextSpiral - d0)) + rv;
				Color pc = c1 ? col1 : RandomBlue();
				Particle(pc, pfl, sttl, 3, p, rv * drift / 16., (0, 0, 0), k);
				spiralDeg += 14;
				nextSpiral += partStep;
			}
			// the inner trail (color2; 0 = the engine's greys), jittered as JitterParticle jitters
			int ittl = railDuration == 0 ? 33 : railDuration;
			int c2 = int(col2) & 0xFFFFFF;
			while (nextInner < d1)
			{
				WalkDiff();
				Vector3 p = level.Vec3Offset(a, u * (nextInner - d0)) + diff;
				Vector3 jv = ((Random[RSTravelBeam]() - 128) / 4096., (Random[RSTravelBeam]() - 128) / 4096., (Random[RSTravelBeam]() - 128) / 4096.) * drift;
				Vector3 ja = ((Random[RSTravelBeam]() - 128) / 16384., (Random[RSTravelBeam]() - 128) / 16384., (Random[RSTravelBeam]() - 128) / 16384.) * drift;
				if (c1) ja.z -= 1. / 4096;
				Color pc = c2 ? col2 : RandomGrey();
				Particle(pc, pfl, ittl, 2, p, jv, ja, k);
				nextInner += partStep;
			}
		}
		// the held core line
		chA.Push(d0); chB.Push(d1);
		chX0.Push(a.x); chY0.Push(a.y); chZ0.Push(a.z);
		chX1.Push(b.x); chY1.Push(b.y); chZ1.Push(b.z);
		chExp.Push(0);
		pathLen = d1;
	}

	// keep the core line lit while the beam lives; once released, it fades out in one last drawing
	void Refresh()
	{
		if (phase >= 2) return;
		int ttl = phase == 0 ? CORETTL : 2;
		for (int i = 0; i < chA.Size(); i++)
		{
			if (chExp[i] > age + 1) continue;
			DrawCore(i, ttl, false, 1.0);
			chExp[i] = age + ttl;
		}
	}

	void DrawCore(int i, int ttl, bool fading, double k)
	{
		Vector3 a = (chX0[i], chY0[i], chZ0[i]);
		Vector3 b = (chX1[i], chY1[i], chZ1[i]);
		Vector3 seg = level.Vec3Diff(a, b);
		double len = seg.Length();
		if (len <= 0.001) return;
		Vector3 u = seg / len;
		// steps on the whole path's grid, so stretches join without a seam
		double s = ceil(chA[i] / CORESTEP) * CORESTEP;
		int life = fading ? int(ceil(ttl / k)) : ttl;
		double fs = fading ? 1.0 / life : 0.0;
		for (; s < chB[i]; s += CORESTEP)
		{
			Vector3 off = level.Vec3Diff(pos, level.Vec3Offset(a, u * (s - chA[i])));
			A_SpawnParticle(coreCol, SPF_FULLBRIGHT, life, 3.5, 0, off.x, off.y, off.z, 0, 0, 0, 0, 0, 0, 0.9, fs);
		}
	}

	// the hold is over: the whole line fades
	void Release()
	{
		phase = 2;
		double k = WorldScale();
		for (int i = 0; i < chA.Size(); i++) DrawCore(i, FADETICS, true, k);
		A_RemoveLight('RSTravelBeam');
	}

	void Particle(Color c, int flags, int ttl, double size, Vector3 p, Vector3 v, Vector3 acc, double k)
	{
		Vector3 off = level.Vec3Diff(pos, p);
		int life = max(1, int(ceil(ttl / k)));
		v *= k;
		acc *= k * k;
		A_SpawnParticle(c, flags, life, size, 0, off.x, off.y, off.z, v.x, v.y, v.z, acc.x, acc.y, acc.z, 1.0, -1);
	}

	// P_DrawRailTrail's maxdiff walk
	void WalkDiff()
	{
		if (maxDiff <= 0) return;
		int rnd = Random[RSTravelBeam]();
		if (rnd & 1) diff.x = clamp(diff.x + ((rnd & 8) ? 1 : -1), -maxDiff, maxDiff);
		if (rnd & 2) diff.y = clamp(diff.y + ((rnd & 16) ? 1 : -1), -maxDiff, maxDiff);
		if (rnd & 4) diff.z = clamp(diff.z + ((rnd & 32) ? 1 : -1), -maxDiff, maxDiff);
	}

	// the spiral's radius vector: perpendicular to the beam, length 3 (P_DrawRailTrail's "extend")
	static Vector3 SpiralArm(Vector3 d)
	{
		Vector3 e;
		double ax = abs(d.x), ay = abs(d.y), az = abs(d.z);
		if (ax <= ay && ax <= az) e = (1, 0, 0);
		else if (ay <= az) e = (0, 1, 0);
		else e = (0, 0, 1);
		return (e - (d dot e) * d) * 3;
	}

	// v turned deg degrees about the unit axis k (v is perpendicular to k)
	static Vector3 Rotate(Vector3 v, Vector3 k, double deg)
	{
		return v * cos(deg) + (k cross v) * sin(deg);
	}

	static Color RandomBlue()
	{
		int r = Random[RSTravelBeam]();
		if (r < 155) return Color(255, 0, 0, 227);
		if (r < 188) return Color(255, 81, 81, 255);
		if (r < 222) return Color(255, 0, 0, 130);
		return Color(255, 0, 0, 80);
	}

	static Color RandomGrey()
	{
		int r = Random[RSTravelBeam]();
		if (r < 85) return Color(255, 210, 210, 210);
		if (r < 170) return Color(255, 171, 171, 171);
		return Color(255, 85, 85, 85);
	}
}

// The head's sweep each tic: P_RailAttack's ProcessRailHit, for one stretch of the path
class RS_TravelBeamTracer : LineTracer
{
	RS_TravelBeam beam;
	Array<Actor> hits;
	Array<double> hx, hy, hz, ha;
	bool stopped;
	Vector3 stopPos;

	override ETraceStatus TraceCallback()
	{
		int ht = Results.HitType;
		if (ht == TRACE_HitActor)
		{
			let a = Results.HitActor;
			if (!a || a == beam || a == beam.target || !a.bSHOOTABLE) return TRACE_Skip;
			if (beam.hitList.Find(a) < beam.hitList.Size()) return TRACE_Skip;   // ripped through already
			if (beam.thruFlags)
			{
				if (beam.thruActors) return TRACE_Skip;
				if (beam.useThruBits && (beam.puffThruBits & a.ThruBits)) return TRACE_Skip;
				if (beam.thruSpecies && a.Species == beam.puffSpecies) return TRACE_Skip;
				if (beam.thruGhosts && a.bGHOST) return TRACE_Skip;
			}
			// invulnerable things block a rail outright (no damage, no puff)
			if (beam.stopAtInvul && a.bINVULNERABLE)
			{
				stopped = true;
				stopPos = Results.HitPos;
				return TRACE_Stop;
			}
			hits.Push(a);
			hx.Push(Results.HitPos.x); hy.Push(Results.HitPos.y); hz.Push(Results.HitPos.z);
			ha.Push(Results.SrcAngleFromTarget);
			if ((beam.railFlags & RGF_NOPIERCING) || a.bSTOPRAILS)
			{
				stopped = true;
				stopPos = Results.HitPos;
				return TRACE_Stop;
			}
			return TRACE_Continue;
		}
		if (ht == TRACE_HitWall || ht == TRACE_HitFloor || ht == TRACE_HitCeiling || ht == TRACE_HasHitSky) return TRACE_Stop;
		return TRACE_Skip;
	}
}
