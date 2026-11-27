// ============================================================================
// RSQ Gore PHASE 4: death recipes and wall blood (design/GORE_SYSTEM_DESIGN.md 2.3 rows "Wall blood" and "Death
// groups", section 4, section 7 phase 4). The recipes and cards are GENERATED (zscript/rsqgo/death_cards.zs, by
// Gore/tools/death_gen.py from BD's and XMVE's own DECORATE); this file runs them.
//
// WHAT IT REPLACES. A Brutal Doom death-group launcher (GoreGroups.dec ZombieXDeath, XMVE's DarkImpXDeath ...) is an
// invisible actor that spawns 25-90 actors in one tic: ceiling launchers, wall-blood missiles, mist, flying blood,
// liquid checkers, a floor spot, and the meat and limbs. A wall-blood missile (SuperWallRedBlood ...) flies 5 tics
// only to paint a decal where it meets a wall.
//
// WHAT IT DOES INSTEAD. The launcher's class is swapped (CheckReplacement) for RSQGO_D_<launcher>, which plays BD's
// Spawn sequence entry by entry, on BD's tics, with BD's arguments, routing each entry by what it spawns:
//   - liquid (flying blood, mist, jets, SuperGore spawners, liquid checks): phase 1's RSQGO_Manager.Process, called
//     with the spawn point and velocity A_CustomMissile would give: particles, no actor at all;
//   - ceil (CeilBloodLauncher*): phase 2's RSQGO_ResidueRings.Launch trace: the ceiling spot is placed where BD's
//     launcher would have met the ceiling, no launcher actor;
//   - wall (SuperWallRedBlood ...): one trace along BD's flight (RSQGO_Manager.Fly, BD's speed and gravity, BD's
//     number of moves); where it meets a wall, BD's decal is sprayed there; no missile actor;
//   - recipe (RedBloodCircularWallPainter ...): a painter whose entries are all wall traces runs inline;
//   - chunk (meat, guts, limbs, heads, halves): a REAL actor, spawned by the very engine call BD makes, so phase 3's
//     cards take it over and it stays gameplay (shootable, kickable); rsqgo_amount and the fly cap apply;
//   - actor (floor spots, hit bloods, nested launchers, classes no phase takes): a real actor, BD's own call.
// A wall missile spawned on its own (MuchBlood, a hit blood at blood level 3+, a monster) becomes RSQGO_W_<class>,
// which makes the same trace on its first tic and is gone.
//
// EXACTNESS. Every argument is drawn as BD's DECORATE draws it: random(lo, hi) from the unnamed RNG (DECORATE's
// pr_exrandom; ZScript's unnamed random() is the same RNG and the same call), in argument order, entry by entry, for
// EVERY entry whether or not it is spawned (rsqgo_amount never changes how many numbers a death draws). Entries run on
// the tic BD's launcher runs them (its first state's action never runs: no NoDelay), BD's blood-intensity script acts
// on the tic it would (LowBlood / LotsOfBlood / AbsurdBlood by rsqgo_spray_level, as phase 1's hit blood). The
// generator's summary (generated/death_summary.txt) names every place this is not exact.
//
// TIERS (design 2.1). The recipe actor exists on every machine; everything it decides uses server cvars
// (rsqgo_amount, rsqgo_spray_level, the fly cap), geometry traces and the playsim RNG, never a camera or a user cvar.
// The particles inside Process are phase 1's cosmetic tier. Decals are sprayed on every machine alike.
//
// HOOKS (applied by hand; see the phase 4 report): zscript.txt includes this file and death_cards.zs, and
// RSQGO_Manager.CheckReplacement asks RSQGO_Deaths.Lookup before phase 3's lookup.
// ============================================================================

extend class RSQGO_Manager
{
	transient RSQGO_Deaths deathBook;     // phase 4 (deaths.zs): the recipes, built on the first takeover
}

// enum names are EDeath*: ZScript names ignore case, so an enum EGroup clashes with the array eGroup
class RSQGO_Deaths play
{
	enum EDeathMode { DM_MISSILE, DM_ITEM, DM_ITEMEX, DM_NONE }
	enum EDeathRoute { DR_ACTOR, DR_CHUNK, DR_LIQUID, DR_CEIL, DR_WALL, DR_RECIPE, DR_SOUND, DR_FACE }
	enum EDeathGroup { DG_MAIN, DG_LOW, DG_LOTS, DG_ABSURD, DG_ANIMU, DG_COUNT }
	enum EDeathArg { DA_CONST, DA_RANDOM, DA_FRANDOM }
	const NARG = 9;
	const MAX_INLINE = 4;           // painters inside painters: never in BD, a guard only

	bool built;
	bool ok;                        // Brutal Doom is loaded (some launcher class exists)
	Map<Name, int> byName;          // BD class -> index into ours (the takeover)
	Array< Class<Actor> > ours;

	// ---- wall cards
	Array<String> wName;
	Array<double> wSpeed;
	Array<double> wGrav;
	Array<int> wLife;               // moves BD's missile makes on dry land (it moves in the tick it is removed)
	Array<int> wLifeWet;            // ... and under water (a looping one meets its waterlevel jump and vanishes)
	Array<String> wDecal;

	// ---- recipes
	Array<String> rName;
	Array<bool> rMissile;           // BD's launcher is +MISSILE (spawned missiles then belong to its target)
	Array<bool> rNoGrav;            // ... +NOGRAVITY (a launcher given a velocity moves straight)
	Array<double> rRadius;          // BD's Radius (the advance of each missile it spawns: P_CheckMissileSpawn)
	Array<int> rAcs;                // the tic BD's intensity script acts, -1 never (or BD's launcher is gone by then)
	Array<int> rEnd;                // DG_COUNT per recipe: the last tic with an entry, per group (-1 no such label)
	Array<int> rE0;
	Array<int> rEN;

	// ---- entries
	Array<int> eTic;
	Array<int> eGroup;
	Array<int> eMode;
	Array<int> eRoute;
	Array<int> eRef;                // DR_WALL: wall card; DR_RECIPE: recipe
	Array<String> eCls;             // the class BD's call names (DR_SOUND: the sound)
	Array<String> eRouted;          // the class the route reads (after DECORATE `replaces`)
	Array< Class<Actor> > eClsC;
	Array<int> eCard;               // DR_LIQUID / DR_CEIL: the phase 1 / phase 2 card, -2 not looked up yet
	Array<int> aKind;               // NARG per entry
	Array<double> aLo;
	Array<double> aHi;

	// ---- scratch (fields, not out-parameters: an out Vector3 compiles and then aborts the VM)
	double av[NARG];
	Vector3 plPos, plVel;
	double plAng;
	Array<int> subR;
	Array<double> subX;
	Array<double> subY;
	Array<double> subZ;
	Array<double> subA;
	int pendTic, pend;              // chunks spawned this tic (the fly cap counts them only from their first tick)

	// ---- debug (transient with the object)
	int stRuns, stActors, stChunksCut, stTraces, stDecals, stLiquid, stCeil;

	// ================================================================ finding it, the takeover
	static RSQGO_Deaths Of(RSQGO_Manager m)
	{
		if (!m.deathBook) m.deathBook = new('RSQGO_Deaths');
		return m.deathBook;
	}

	static Class<Actor> Lookup(RSQGO_Manager m, Name bd)
	{
		let b = Of(m);
		if (!b.Ready()) return null;
		int i;
		bool has;
		[i, has] = b.byName.CheckValue(bd);
		return has ? b.ours[i] : null;
	}

	bool Ready()
	{
		if (!built) Build();
		return ok;
	}

	void Build()
	{
		built = true;
		BuildCards();
		for (int i = 0; i < eCls.Size(); i++)
		{
			Class<Actor> c = null;
			if (eRoute[i] != DR_SOUND && eRoute[i] != DR_FACE) c = eCls[i];
			eClsC.Push(c);
			eCard.Push(-2);
		}
	}

	private void Take(String bd, String our)
	{
		Class<Actor> b = bd;
		Class<Actor> o = our;
		if (!b || !o) return;
		byName.Insert(bd, ours.Size());
		ours.Push(o);
		ok = true;
	}

	// ---- the generated tables call these (death_cards.zs)
	void Wall(String bd, String our, double speed, double grav, int life, int lifeWet, String decal)
	{
		wName.Push(bd); wSpeed.Push(speed); wGrav.Push(grav); wLife.Push(life); wLifeWet.Push(lifeWet);
		wDecal.Push(decal);
		Take(bd, our);
	}

	void Rec(String bd, String our, bool missile, bool noGrav, double radius, int acsAt, String ends)
	{
		rName.Push(bd); rMissile.Push(missile); rNoGrav.Push(noGrav); rRadius.Push(radius); rAcs.Push(acsAt);
		Array<String> t;
		ends.Split(t, " ", TOK_SKIPEMPTY);
		for (int g = 0; g < DG_COUNT; g++) rEnd.Push(g < t.Size() ? t[g].ToInt() : -1);
		rE0.Push(eTic.Size());
		rEN.Push(0);
		Take(bd, our);
	}

	void E(int tic, int group, int mode, int route, int rf, String cls, String routed, String args)
	{
		eTic.Push(tic); eGroup.Push(group); eMode.Push(mode); eRoute.Push(route); eRef.Push(rf);
		eCls.Push(cls); eRouted.Push(routed);
		Array<String> t;
		args.Split(t, " ", TOK_SKIPEMPTY);
		for (int k = 0; k < NARG; k++)
		{
			String s = k < t.Size() ? t[k] : "0";
			int kind = DA_CONST;
			String c0 = s.Left(1);
			if (c0 == "r") kind = DA_RANDOM;
			else if (c0 == "f") kind = DA_FRANDOM;
			if (kind == DA_CONST)
			{
				double v = s.ToDouble();
				aKind.Push(kind); aLo.Push(v); aHi.Push(v);
				continue;
			}
			String body = s.Mid(1);
			int colon = body.IndexOf(":");
			aKind.Push(kind);
			aLo.Push(body.Left(colon).ToDouble());
			aHi.Push(body.Mid(colon + 1).ToDouble());
		}
		rEN[rEN.Size() - 1]++;
	}

	// ================================================================ which entries run
	// BD_CheckBloodIntensity (Options.acs): 0-1 LowBlood, 2 nothing, 3 LotsOfBlood, 4 AbsurdBlood, 5 AbsurdBlood with
	// AnimuGore given. Read from rsqgo_spray_level (server), as phase 1's hit blood reads it: BD's own option never
	// reaches its actors on this setup (CVARINFO.txt note). A label the launcher lacks: SetActorState does nothing.
	int Group(int r)
	{
		if (rAcs[r] < 0) return DG_MAIN;
		int lvl = clamp(rsqgo_spray_level, 0, 5);
		int g = DG_MAIN;
		if (lvl <= 1) g = DG_LOW;
		else if (lvl == 3) g = DG_LOTS;
		else if (lvl == 4) g = DG_ABSURD;
		else if (lvl >= 5) g = rEnd[r * DG_COUNT + DG_ANIMU] >= 0 ? DG_ANIMU : DG_ABSURD;
		if (g != DG_MAIN && rEnd[r * DG_COUNT + g] < 0) g = DG_MAIN;
		return g;
	}

	int EndTic(int r, int g)
	{
		return max(0, rEnd[r * DG_COUNT + g]);
	}

	// The script acts after the launcher's own tick of that tic: main entries up to and on that tic still run.
	bool Active(int i, int r, int g)
	{
		int eg = eGroup[i];
		if (eg == DG_MAIN) return g == DG_MAIN || eTic[i] <= rAcs[r];
		return eg == g;
	}

	// ================================================================ one tic of a recipe
	void RunTic(RSQGO_DeathRun a, RSQGO_Manager m, int r, int g, int t)
	{
		if (t == 0) stRuns++;
		subR.Clear(); subX.Clear(); subY.Clear(); subZ.Clear(); subA.Clear();
		for (int i = rE0[r]; i < rE0[r] + rEN[r]; i++)
		{
			if (eTic[i] != t || !Active(i, r, g)) continue;
			Exec(a, m, i, a.pos, a.angle, rRadius[r], a.Floorclip, true);
		}
		// painters spawned this tic tick after the launcher in BD (fresh thinkers, in spawn order): theirs come next
		for (int s = 0; s < subR.Size(); s++) RunInline(a, m, subR[s], (subX[s], subY[s], subZ[s]), subA[s], 1);
	}

	// A painter's entries, all wall traces on its first tic, from where BD would have spawned it.
	void RunInline(RSQGO_DeathRun a, RSQGO_Manager m, int r, Vector3 p, double ang, int depth)
	{
		if (r < 0 || r >= rName.Size() || depth > MAX_INLINE) return;
		int n0 = subR.Size();
		for (int i = rE0[r]; i < rE0[r] + rEN[r]; i++)
		{
			if (eTic[i] != 0 || eGroup[i] != DG_MAIN) continue;
			Exec(a, m, i, p, ang, rRadius[r], 0, false);
		}
		// (a painter spawning painters: never in BD's data; run them depth-first, guarded)
		int n1 = subR.Size();
		for (int s = n0; s < n1; s++) RunInline(a, m, subR[s], (subX[s], subY[s], subZ[s]), subA[s], depth + 1);
	}

	// One entry. `own`: the recipe actor's own entry (it stands at p with angle ang); otherwise an inline painter's.
	void Exec(RSQGO_DeathRun a, RSQGO_Manager m, int i, Vector3 p, double ang, double radius, double fclip, bool own)
	{
		Draw(i);
		int route = eRoute[i];
		if (route == DR_FACE)
		{
			if (own) a.A_FaceTarget();
			return;
		}
		if (route == DR_SOUND)
		{
			if (own) a.A_StartSound(eCls[i], int(av[0]), int(av[1]), av[2], av[3]);
			return;
		}
		if (route == DR_LIQUID)
		{
			int c = LiquidCard(m, i);
			if (c >= 0)
			{
				if (Place(i, p, ang, radius, fclip, m.data.cSpeed[c]))
				{
					m.Process(c, a, plPos, plVel, plAng, 0, 0, a.waterlevel >= 1);
					stLiquid++;
				}
				return;
			}
			route = DR_ACTOR;
		}
		else if (route == DR_CEIL)
		{
			let res = m.res ? m.res : RSQGO_ResidueRings.Get(true);
			int c = CeilCard(res, i);
			if (c >= 0)
			{
				if (Place(i, p, ang, radius, fclip, res.data.cSpeed[c]))
				{
					// Launch reads a launcher actor's place, velocity, yaw and waterlevel: lend it ours, then restore
					Vector3 op = a.pos;
					Vector3 ov = a.vel;
					double oa = a.angle;
					a.SetXYZ(plPos);
					a.vel = plVel;
					a.angle = plAng;
					res.Launch(a, c);
					a.SetXYZ(op);
					a.vel = ov;
					a.angle = oa;
					stCeil++;
				}
				return;
			}
			route = DR_ACTOR;
		}
		else if (route == DR_WALL)
		{
			int w = eRef[i];
			if (w >= 0 && w < wName.Size())
			{
				if (Place(i, p, ang, radius, fclip, wSpeed[w])) WallFly(a, m, w, plPos, plVel);
				return;
			}
			route = DR_ACTOR;
		}
		else if (route == DR_RECIPE)
		{
			if (Place(i, p, ang, radius, fclip, 0))
			{
				subR.Push(eRef[i]); subX.Push(plPos.x); subY.Push(plPos.y); subZ.Push(plPos.z); subA.Push(plAng);
			}
			return;
		}
		// a real actor, by BD's own call from where BD's launcher stands (an inline painter has no actor entries)
		if (!own) return;
		if (route == DR_CHUNK && !ChunkOk(a)) return;
		let cls = eClsC[i];
		if (!cls) return;
		int mode = eMode[i];
		if (mode == DM_MISSILE) a.A_SpawnProjectile(cls, av[0], av[1], av[2], int(av[3]), av[4]);
		else if (mode == DM_ITEM) a.A_SpawnItem(cls, av[0], av[1]);
		else if (mode == DM_ITEMEX) a.A_SpawnItemEx(cls, av[0], av[1], av[2], av[3], av[4], av[5], av[6], int(av[7]), int(av[8]));
		stActors++;
	}

	// BD's arguments for entry i, drawn in argument order: DECORATE's random() is the unnamed RNG, integer.
	void Draw(int i)
	{
		int b = i * NARG;
		for (int k = 0; k < NARG; k++)
		{
			int kind = aKind[b + k];
			if (kind == DA_RANDOM) av[k] = random(int(aLo[b + k]), int(aHi[b + k]));
			else if (kind == DA_FRANDOM) av[k] = frandom(aLo[b + k], aHi[b + k]);
			else av[k] = aLo[b + k];
		}
	}

	// Where entry i's actor would appear, its velocity and yaw (plPos / plVel / plAng), as the engine places it.
	// Returns false when BD's call would spawn nothing (A_SpawnItemEx's fail chance).
	//   A_CustomMissile / A_SpawnProjectile with CMF_AIMDIRECTION (p_actionfunctions.cpp A_SpawnProjectile, aimmode 2):
	//     at the shooter + spawnofs_xy to its right + spawnheight (less the shooter's Floorclip), yaw = the shooter's
	//     + angle (or angle with CMF_ABSOLUTEANGLE), xy speed |cos(pitch)| x Speed, z sin(pitch) x Speed
	//     (CMF_BADPITCH, A_CustomMissile's) or -sin; then P_CheckMissileSpawn's advance: half the velocity, halved
	//     again until its xy part is under the shooter's radius.
	//   A_SpawnItem: `distance` ahead, zheight up; A_SpawnItemEx: offsets and velocity turned by the yaw.
	bool Place(int i, Vector3 p, double ang, double radius, double fclip, double speed)
	{
		int mode = eMode[i];
		if (mode == DM_MISSILE)
		{
			int fl = int(av[3]);
			double rgt = ang - 90;
			plPos = p + (av[1] * cos(rgt), av[1] * sin(rgt), av[0] - fclip);
			plAng = (fl & CMF_ABSOLUTEANGLE) ? av[2] : ang + av[2];
			double pit = av[4];
			double xy = abs(cos(pit) * speed);
			double vz = (fl & CMF_BADPITCH) ? sin(pit) * speed : -sin(pit) * speed;
			plVel = (cos(plAng) * xy, sin(plAng) * xy, vz);
			if (radius > 0)
			{
				Vector3 adv = plVel;
				double r2 = radius * radius;
				do
				{
					adv *= 0.5;
				}
				while ((adv.xy dot adv.xy) >= r2);
				plPos += adv;
			}
			return true;
		}
		if (mode == DM_ITEM)
		{
			plPos = p + (cos(ang) * av[0], sin(ang) * av[0], av[1] - fclip);
			plVel = (0, 0, 0);
			plAng = ang;
			return true;
		}
		// A_SpawnItemEx (attacks.zs)
		if (av[8] > 0 && random[spawnitemex]() < av[8]) return false;
		int xfl = int(av[7]);
		double da = (xfl & SXF_ABSOLUTEANGLE) ? av[6] : ang + av[6];
		double s = sin(da);
		double co = cos(da);
		if (xfl & SXF_ABSOLUTEPOSITION) plPos = (p.x + av[0], p.y + av[1], p.z - fclip + av[2]);
		else plPos = (p.x + av[0] * co + av[1] * s, p.y + av[0] * s - av[1] * co, p.z - fclip + av[2]);
		if (xfl & SXF_ABSOLUTEVELOCITY) plVel = (av[3], av[4], av[5]);
		else plVel = (av[3] * co + av[4] * s, av[3] * s - av[4] * co, av[5]);
		plAng = da;
		return true;
	}

	// ---- the cards the routes read (looked up once; -1: that phase left the class to BD, so it spawns as an actor)
	int LiquidCard(RSQGO_Manager m, int i)
	{
		if (eCard[i] == -2)
		{
			eCard[i] = -1;
			if (m.Ready())
			{
				int c;
				bool has;
				[c, has] = m.data.byName.CheckValue(eRouted[i]);
				if (has && m.data.cKind[c] != RSQGO_Data.K_HIT) eCard[i] = c;
			}
		}
		return (eCard[i] >= 0 && m.data) ? eCard[i] : -1;
	}

	int CeilCard(RSQGO_ResidueRings res, int i)
	{
		if (!res || !res.Ready()) return -1;
		if (eCard[i] == -2)
		{
			eCard[i] = -1;
			int c;
			bool has;
			[c, has] = res.data.byName.CheckValue(eRouted[i]);
			if (has && res.data.cKind[c] == RSQGO_ResData.RK_LAUNCH) eCard[i] = c;
		}
		return eCard[i];
	}

	// ---- chunks: the owner's Gore row and fly cap (server cvars: every machine spawns the same chunks)
	// None: no chunk. Some: every second chunk of a death, in recipe order (design section 6). The fly cap
	// (rsqgo_fly_*: 192 on PC) is the one phase 3 applies on a chunk's first tick (RSQGO_GibRing.Admit); a chunk it
	// would refuse is not spawned at all.
	bool ChunkOk(RSQGO_DeathRun a)
	{
		int amt = rsqgo_amount;
		if (amt <= 0) { stChunksCut++; return false; }
		a.chunkNo++;
		if (amt == 1 && !(a.chunkNo & 1)) { stChunksCut++; return false; }
		let ring = RSQGO_GibRing.Find(false);
		if (ring)
		{
			if (pendTic != level.maptime) { pendTic = level.maptime; pend = 0; }
			if (ring.flying + pend >= ring.FlyCap()) { stChunksCut++; return false; }
			pend++;
		}
		return true;
	}

	// ================================================================ wall blood
	// BD's wall missile (WallRedBlood family): it flies `life` moves under its gravity (MISSILE, THRUACTORS); meeting
	// a wall it explodes and the engine sticks its Decal there (p_mobj.cpp P_ExplodeMissile); meeting the floor or the
	// ceiling it leaves nothing; a Line_Horizon destroys it. One trace along the flight (RSQGO_Manager.Fly).
	void WallFly(Actor a, RSQGO_Manager m, int w, Vector3 p, Vector3 v)
	{
		Sector sec = level.PointInSector(p.xy);
		double g = wGrav[w] * level.gravity * (sec ? sec.gravity : 1.0) * 0.00125;
		int life = a.waterlevel > 1 ? wLifeWet[w] : wLife[w];
		Line ln = m.Fly(a, p, v, g, life);
		stTraces++;
		if (m.flyHit != RSQGO_Manager.HIT_WALL) return;
		if (ln && ln.special == Line_Horizon) return;
		Paint(a, m.flyPos, m.flyDir, wDecal[w]);
	}

	// The decal on the wall at the point and height the flight met it: sprayed from 8 units back along the flight's
	// horizontal direction. The actor stands there for the spray (A_SprayDecal traces from the actor's own sector).
	void Paint(Actor a, Vector3 hit, Vector3 dir, String decal)
	{
		Vector3 hd = (dir.x, dir.y, 0);
		double l = hd.Length();
		if (l > 0.001) hd /= l;
		else hd = dir;
		Vector3 op = a.pos;
		a.SetOrigin(hit - hd * 8, false);
		a.A_SprayDecal(decal, 32, (0, 0, 0.0001), hd);     // a non-zero offset: zero means "from mid-height"
		a.SetOrigin(op, false);
		stDecals++;
	}

	// ================================================================ debug (RSQGO_Manager.DebugLine)
	static String DebugText(RSQGO_Manager m)
	{
		let b = m.deathBook;
		if (!b || !b.stRuns && !b.stTraces) return "";
		String s = String.Format("\cfRSQ Gore\c- deaths: %d recipes run | %d actors, %d chunks cut | %d wall traces, %d decals | %d liquid, %d ceiling",
			b.stRuns, b.stActors, b.stChunksCut, b.stTraces, b.stDecals, b.stLiquid, b.stCeil);
		b.stRuns = b.stActors = b.stChunksCut = b.stTraces = b.stDecals = b.stLiquid = b.stCeil = 0;
		return s;
	}
}

// BD's launcher, replaced (death_cards.zs RSQGO_D_<class>). It never moves, animates or touches anything: its Tick
// plays the recipe on BD's tics and it is gone after its last entry (most recipes: on its first tic).
class RSQGO_DeathRun : Actor
{
	int recipe;
	property Recipe: recipe;
	int age;
	int group;
	int endTic;
	int chunkNo;                // chunks this death has offered (rsqgo_amount Some keeps every second one)
	bool started;
	Vector3 home;
	Vector3 homeVel;

	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+NOGRAVITY
		+NOCLIP
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOBLOODDECALS
		RenderStyle "None";
		Height 16;
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// No Super.Tick: nothing to move, no states to run. The first Tick comes in the tic it spawns, after the spawner
	// has set its angle, velocity and target, exactly when BD's launcher runs its first tick.
	override void Tick()
	{
		let m = RSQGO_Manager.Get();
		RSQGO_Deaths b = m ? RSQGO_Deaths.Of(m) : null;
		if (!b || !b.Ready() || recipe < 0 || recipe >= b.rName.Size())
		{
			Destroy();
			return;
		}
		if (!started)
		{
			started = true;
			home = pos;
			homeVel = vel;
			group = b.Group(recipe);
			endTic = b.EndTic(recipe, group);
			bMissile = b.rMissile[recipe];
		}
		else if (b.rNoGrav[recipe] && homeVel != (0, 0, 0))
		{
			SetOrigin(home + homeVel * age, false);    // a NOGRAVITY launcher given a velocity flies straight
		}
		b.RunTic(self, m, recipe, group, age);
		age++;
		if (age > endTic) Destroy();
	}
}

// BD's wall missile, replaced (death_cards.zs RSQGO_W_<class>) when something spawns it on its own: one trace on its
// first tic, from where the spawner put it (P_CheckMissileSpawn's advance included) along the velocity it was given.
class RSQGO_WallRun : Actor
{
	int wall;
	property Wall: wall;

	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+NOGRAVITY
		+NOCLIP
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOBLOODDECALS
		RenderStyle "None";
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	override void Tick()
	{
		let m = RSQGO_Manager.Get();
		RSQGO_Deaths b = m ? RSQGO_Deaths.Of(m) : null;
		if (b && b.Ready() && wall >= 0 && wall < b.wName.Size()) b.WallFly(self, m, wall, pos, vel);
		Destroy();
	}
}
