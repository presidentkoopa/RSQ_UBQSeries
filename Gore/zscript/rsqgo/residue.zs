// ============================================================================
// RSQGO_ResidueRings -- RSQ Gore PHASE 2: the blood that stays (design/GORE_SYSTEM_DESIGN.md 2.2, 2.3 rows "Ceiling
// blood", "Drips", "Floor spots and pools", "Boot smears"; section 5; the owner's Q3 and Q4 in section 8).
//
// WHAT IT REPLACES. Brutal Doom leaves every floor spot, pool, footprint and ceiling spot as a permanent blockmap
// actor in the corpse queue (8192 on the owner's setup: never cleaned); a ceiling spot thrusts itself every 5 tics
// forever; a pool keeps its actor ticking after its 66-tic grow; every spot with gore spawns a MONSTER thinker
// (BootSmearerRed, 851 tics) to smear the boots of the player it saw; every ceiling spot spawns a drip spawner (771
// tics, 56 drip actors of which 90% die on their first tic).
//
// WHAT IT DOES INSTEAD.
//   - Spots, pools, footprints and ceiling spots are still one actor each (BD's md3 flats need an actor), but
//     +NOBLOCKMAP and PARKED in statnum 26: never ticked, still drawn, still carried by lifts (MOVEWITHSECTOR); the
//     engine clears every actor's interpolation each tic (p_tick.cpp), parked ones included.
//   - THE MERGE GRID: a 64-unit cell hash per layer (floor, ceiling). A new spot that lies inside an existing spot of
//     its colour on the same floor (+-2) adds nothing; one near the centre of a spot of its own class grows that spot
//     (by area, up to GROW_MAX) instead of adding an actor. Pools and footprints never merge (one pool per body, every
//     print kept). rsqgo_merge (server, default on) turns it off for A/B.
//   - THE RINGS: floor (spots, pools, footprints) and ceiling, sized by the owner's budget cvars (rsqgo_floor_* and
//     rsqgo_ceil_*: 512 + 128 on PC, about a third on Quest, Q3). When a ring is full its OLDEST entry is destroyed.
//     Never timed out, except at Blood That Stays None (rsqgo_floor_none_fade seconds, then a 20-tic fade).
//   - SCHEDULES, walked once a tic, no ThinkerIterator, no BlockThingsIterator: reveals (BD shows a spot 0-4 tics
//     after it spawns), pool grows (BD's ramp to the tic), pending placements (a ceiling spot where a launcher meets
//     the ceiling, a floor spot where a drip lands), fades, the ceiling-mover watch, smear zones, drip particles.
//   - SMEAR ZONES replace BootSmearer*, replaying the MONSTER BD spawns tic for tic: it is born where the spot is on
//     its smear tic (still falling, if the spot is); a pool's smearer starts with the pool's killer as target and
//     LastHeard (InitSpawnedItem -> CopyFriendliness), so a pool a monster killed in infighting smears nobody; then
//     A_Look / A_Chase every tic: LastHeard (read from the zone's EAR, the parked actor that spawned the zone, whose
//     LastHeard the engine's noise flood sets exactly as it sets the smearer's), then P_LookForPlayers (rotating start
//     player, isTargetablePlayer's rules, P_CheckSight from the floor point through a probe actor). Once locked, the
//     first A_JumpIfCloser(60) comes after BD's A_Chase tics, the second 8 - (0..3) tics later (Die's pr_killmobj&3),
//     then every 8, 106 checks; it gives BD's own token (BootsSmearedWithRedBlood x8, ...) to the actor it locked
//     (a respawned player's corpse, as in BD), once. rsqgo_smear_all (server, default off; the owner's open Q4)
//     gives it to EVERY player who walks through instead, once each, in BD's window from the zone's birth.
//   - DRIPS: a drip that leaves a spot (BD's DripingBlood*Leaves*Pool) is playsim: its spot is placed where and when
//     it lands (on the highest solid floor under it, 3D floors included; nothing on a sky floor). Every drip is drawn
//     as BD draws it, a falling VisualThinker (RSQGO_ResVT: BD's untranslated frames through BD's class Translation,
//     at BD's scale), then BD's splash flipbook and blooddrop2 where it lands: cosmetic, this machine only, behind
//     Ceiling Drips (rsqgo_drips).
//   - LAUNCHERS (CeilBloodLauncher*) carry BD's Speed (A_CustomMissile sets the velocity from the spawned class) and
//     become line traces along their flight, bouncing off walls as BOUNCEONWALLS does (x0.75 speed, reflected yaw);
//     on a ceiling that is not sky, the ceiling spot is placed on the tic BD's would have landed, at BD's yaw.
//
// NAMED DIFFERENCES FROM BD (also in generated/residue_summary.txt):
//   - spots and pools are placed on their floor at once (BD's fall there first; where they end up is BD's);
//   - smear-zone sight looks are budgeted: zones younger than LOOK_YOUNG look every tic, at most LOOK_BUDGET_YOUNG
//     sight tests a tic; older ones every LOOK_OLD_PERIOD tics, at most LOOK_BUDGET_OLD a tic (BD: every tic, no cap);
//   - at MAX_ZONES live zones a new one evicts the oldest zone that never locked (else the locked one ending first);
//   - a zone whose ear fades away (Blood That Stays None) hears nothing more and looks by sight only;
//   - launchers bounce at most LAUNCH_BOUNCES times (BD: until their 3 or 12 tics run out);
//   - drip particles: at most DRIP_PARTICLES_TIC falls start a tic, none beyond DRIP_FAR of this machine's camera
//     (cosmetic, local); a culled fall shows no splash; its landing sound still plays (BD's always does);
//   - the ceiling-mover watch runs before the movers, so a spot trails its moving ceiling by one tic (BD's: up to 5).
//   - a drip is judged under water once, where it starts (BD's re-tests every 4 tics of its fall: one that falls into
//     deep water vanishes there; ours lands and leaves its spot on the floor beneath).
//
// THE TWO TIERS (design 2.1). Everything that decides an actor or a token (where a spot goes, merges, frames,
// smear locks and gives, drip spots) uses geometry, server cvars and random[RSQGO_Play], identically on every
// machine, and tests every player, never the console player. Drip particles and their sounds use a handler-held
// xorshift and this machine's camera and cvars, and never spawn an actor (except BD's under-water Splash child,
// which is then decided by random[RSQGO_Play]).
//
// HOME. A Thinker in statnum 25 (never ticked by the engine: RSQGO_Manager calls WorldTic once a tic), saved with
// the level, gone with it; one per level, made on the first takeover. Its cards (RSQGO_ResData) are transient and
// rebuilt after a load, like the merge grid.
//
// THE MANAGER'S API (see the phase 2 report for the exact hook lines):
//   RSQGO_ResidueRings.Get(create)       find (or make) this level's residue
//   r.TakeOver(cls)                 BD class -> our class, or null (CheckReplacement, after phase 1's map misses)
//   r.WorldTic()                    once a tic (WorldTick)
//   r.PlaceFloor(bdName, pos, ang)  spawn a BD floor spot class through the takeover (phase 3+ callers)
//   r.PlaceCeil(bdName, pos, ang)   the same on a ceiling
// ============================================================================

// RSQGO_ResidueRings, not RSQGO_Residue: ZScript names ignore case, and a class named like the cvar rsqgo_residue
// hides the cvar ("Invalid global identifier").
class RSQGO_ResidueRings : Thinker
{
	const STAT_RESIDUE = 25;        // this thinker (not ticked; the series' map: 26-30 are taken, 26 by our parking)
	const STAT_PARKED = 26;         // RSQGO_Manager.STAT_PARKED_ACTOR
	const CELL = 64.0;
	const GROW_MAX = 1.6;           // a merged spot grows at most to this times its BD scale
	const MERGE_LOOK = 32;          // candidates examined per merge query
	const ZONE_WHEEL = 64;          // smear-zone timing wheel (a power of two above BD's 8-tic period)
	const JOB_WHEEL = 1024;         // cosmetic drip jobs (BD's longest drip program is 781 tics + the fall)
	// smear-zone looks (BD's smearer looks every tic forever; these are the named budget, deterministic order)
	const LOOK_YOUNG = 700;         // a zone younger than this (20 s) looks every tic
	const LOOK_BUDGET_YOUNG = 128;  // ... at most this many sight tests a tic across young zones
	const LOOK_OLD_PERIOD = 8;      // an older zone looks every this many tics
	const LOOK_BUDGET_OLD = 32;     // ... at most this many sight tests a tic across old zones
	const MAX_ZONES = 8192;         // live zones (about 20 array slots each); a full table evicts, never refuses
	const LAUNCH_BOUNCES = 16;      // wall bounces a launcher trace follows (BD: no limit)
	enum EZonePhase { ZP_BIRTH, ZP_LOOK, ZP_WINDOW }
	const DRIP_PARTICLES_TIC = 32;  // drip particles started per tic, at most
	const DRIP_FAR = 3072.0;        // no drip particle beyond this from this machine's camera
	const DEBUG_EVERY = 350;

	transient RSQGO_ResData data;
	transient CVar cvOn, cvMerge, cvAll, cvDrips;

	// ---- slots: one per live spot actor, floor (layer 0) or ceiling (layer 1). Saved.
	Array<Actor> sA;
	Array<int> sCard;
	Array<int> sLayer;
	Array<int> sSer;                // bumped when a slot is freed, so stale ring and schedule entries are skipped
	Array<bool> sUsed;
	Array<double> sX;
	Array<double> sY;
	Array<double> sZ;
	Array<double> sR;               // the blood's radius now (grows with merges)
	Array<double> sS0;              // BD's scale
	Array<int> sFrame;
	Array<int> sSec;                // sector index (the ceiling-mover watch)
	Array<int> sLink;               // next slot in its grid cell (+1; 0 = end): rebuilt with the grid
	Array<int> sFree;
	int liveFloor, liveCeil;

	// ---- rings, oldest first (slot, serial). Saved.
	Array<int> rfSlot;
	Array<int> rfSer;
	int rfHead;
	Array<int> rcSlot;
	Array<int> rcSer;
	int rcHead;

	// ---- the merge grid (transient: rebuilt from the slots after a load)
	transient Map<int, int> grid;   // cell key -> first slot + 1
	transient bool gridOk;

	// ---- schedules (saved)
	Array<int> quSlot;              // BD's A_QueueCorpse, due (the engine's corpse queue, sv_corpsequeuesize)
	Array<int> quSer;
	Array<int> quDue;
	Array<int> rvSlot;              // reveals
	Array<int> rvSer;
	Array<int> rvDue;
	Array<int> gwSlot;              // pool grows
	Array<int> gwSer;
	Array<int> gwT0;
	Array<int> fdSlot;              // fades (Blood That Stays None), in due order
	Array<int> fdSer;
	Array<int> fdDue;
	int fdHead;
	Array<int> pnDue;               // pending placements (BD class by name, through the takeover)
	Array<String> pnCls;
	Array<double> pnX;
	Array<double> pnY;
	Array<double> pnZ;
	Array<double> pnAng;
	Array<int> wSec;                // sectors that hold ceiling spots (the ceiling-mover watch)
	Array<double> wLastZ;           // ... each one's ceiling signature last tic (CeilSig)
	int wRebuilt;

	// ---- smear zones (saved), on a timing wheel by due tic
	Array<bool> zUsed;
	Array<bool> zStale;             // evicted while still linked in the wheel: freed when its bucket comes round
	Array<int> zSer;                // bumped on free (the eviction queue skips stale entries)
	Array<int> zCard;
	Array<double> zX;
	Array<double> zY;
	Array<double> zZ;
	Array<int> zT0;                 // the tic BD's smearer is born
	Array<int> zL0;                 // its first A_Look tic
	Array<int> zPhase;              // ZP_*
	Array<int> zDue;
	Array<int> zEnd;                // the last check tic (set when the zone locks)
	Array<int> zGap;                // tics to the next check (the first gap is shortened like Die's)
	Array<int> zLook;               // LastLookPlayerNumber (P_LookForPlayers starts after it)
	Array<Actor> zTargetMo;         // the actor it locked onto (A_JumpIfCloser / A_GiveToTarget test this one)
	Array<Actor> zPre;              // the target InitSpawnedItem gave it (a pool's killer), chased by A_Chase
	Array<Actor> zEar;              // the parked actor whose LastHeard stands in for the smearer's
	Array<int> zMask;               // players already smeared (every-player mode)
	Array<int> zLink;               // next zone in its wheel bucket (+1; 0 = end)
	Array<int> zFree;
	Array<int> zWheel;              // ZONE_WHEEL bucket heads (+1)
	Array<int> zqZ;                 // zones in birth order (zone, serial): the eviction queue
	Array<int> zqSer;
	int zqHead;
	int zLive;
	Actor probe;                    // RSQGO_ResProbe: P_CheckSight from a zone's point (height 0, like the smearer)
	transient int lookStamp, lookYoung, lookOld;
	transient bool lookRolled, probeSet;

	// ---- cosmetic drip jobs (transient, per machine), on a timing wheel
	enum EJob { J_FALL, J_SPLASH, J_SOUND }
	transient Array<int> jDue;
	transient Array<int> jKind;
	transient Array<int> jCard;
	transient Array<int> jLife;
	transient Array<double> jX;
	transient Array<double> jY;
	transient Array<double> jZ;
	transient Array<double> jVZ;
	transient Array<double> jAcc;
	transient Array<double> jLX;            // where the fall lands (its splash goes there)
	transient Array<double> jLY;
	transient Array<double> jLZ;
	transient Array<bool> jSplash;          // a fall that is drawn schedules its splash
	transient Array<int> jLink;
	transient Array<int> jFree;
	transient Array<int> jWheel;
	transient Array<int> sndCells;
	transient uint rngState;
	transient int dripTic, dripStarted;
	transient Vector3 camPos;
	transient bool camOk;

	// ---- debug counters (transient)
	transient int stTake, stSpots, stMerged, stGrown, stRecycled, stZones, stGives, stDrips, stPend;
	transient double stMs;

	// ================================================================ finding it
	static RSQGO_ResidueRings Get(bool create)
	{
		let it = ThinkerIterator.Create("RSQGO_ResidueRings", STAT_RESIDUE);
		let r = RSQGO_ResidueRings(it.Next());
		if (!r && create)
		{
			r = new("RSQGO_ResidueRings");
			r.ChangeStatNum(STAT_RESIDUE);
		}
		return r;
	}

	bool Ready()
	{
		if (!data)
		{
			data = new("RSQGO_ResData");
			data.Build();
		}
		return data.ok;
	}

	bool IsOn()
	{
		if (!cvOn) cvOn = CVar.FindCVar("rsqgo_on");
		return cvOn && cvOn.GetBool();
	}

	// Optional server cvars (rsqgo_merge, rsqgo_smear_all) are read by name so this file compiles before they exist.
	bool MergeOn()
	{
		if (!cvMerge) cvMerge = CVar.FindCVar("rsqgo_merge");
		return !cvMerge || cvMerge.GetBool();
	}

	bool SmearAll()
	{
		if (!cvAll) cvAll = CVar.FindCVar("rsqgo_smear_all");
		return cvAll && cvAll.GetBool();
	}

	// ================================================================ the takeover (RSQGO_Manager.CheckReplacement)
	Class<Actor> TakeOver(Class<Actor> replacee)
	{
		if (!replacee || !Ready()) return null;
		int c;
		bool has;
		[c, has] = data.byName.CheckValue(replacee.GetClassName());
		if (!has) return null;
		stTake++;
		return data.cCls[c];
	}

	// For later phases: leave a BD floor or ceiling spot class at a point, exactly as if BD had spawned it (through
	// the takeover while rsqgo_on is on, BD's own actor otherwise).
	Actor PlaceFloor(String bdName, Vector3 pos, double ang)
	{
		Class<Actor> cls = bdName;
		if (!cls) return null;
		let a = Actor.Spawn(cls, pos, ALLOW_REPLACE);
		if (a) a.angle = ang;
		return a;
	}

	Actor PlaceCeil(String bdName, Vector3 pos, double ang)
	{
		return PlaceFloor(bdName, pos, ang);
	}

	// For callers that replay a BD missile which dies on the floor and leaves a spot there (Brutal_FlyingBlood's
	// DeathFloor: A_SpawnItemEx at its own z): the spot is born at the MISSILE's floorz, the highest floor its box
	// (spawnerRadius) touches, not the floor under the point. On a step edge or a slope that is above the spot's own
	// smaller box floor, so BD's spot falls, fails its A_CheckFloor and is gone; AdoptFloor replays exactly that.
	Actor PlaceFloorFrom(String bdName, Vector3 pos, double spawnerRadius, double ang)
	{
		double fz;
		bool sky;
		[fz, sky] = BoxFloor(pos, spawnerRadius);
		if (sky) return null;                       // the missile was destroyed on a sky floor: no Death state
		return PlaceFloor(bdName, (pos.x, pos.y, fz), ang);
	}

	// The floorz and sky test an actor of this radius would get at p (P_FindFloorCeiling over its box: the highest
	// floor it touches at or below p.z, 3D floors included), read from the probe moved there.
	bool, double BoxProbe(Vector3 p, double radius)
	{
		if (!probe)
		{
			probe = Actor.Spawn("RSQGO_ResProbe", p);
			if (probe) probe.ChangeStatNum(STAT_PARKED);
		}
		if (!probe) return false, 0;
		probeSet = false;
		if (probe.radius != radius) probe.A_SetSize(max(0.0, radius), -1, false);
		probe.SetOrigin(p, false);
		return true, probe.floorz;
	}

	// The same answer as BoxFloor without any actor: the floorz P_FindFloorCeiling gives an actor of this radius at
	// pos (the sector under the point, then every two-sided line crossing the box: the higher side's floor at the
	// line's point nearest the centre, as P_LineOpening; 3D floors at or below pos.z included; one-sided lines add
	// nothing), and whether that floor is sky. Spawns, moves and changes nothing and uses no RNG, so per-machine
	// cosmetic code may call it (the blockmap walk only bumps the engine's line-visit counter). Not modelled: 3D
	// midtextures and portals (the probe path, BoxFloor, has them).
	static clearscope double, bool BoxFloorPure(Vector3 pos, double radius)
	{
		let s0 = level.PointInSector(pos.xy);
		if (!s0) return pos.z - 4096, false;
		double best;
		bool sky;
		[best, sky] = SectorFloorPure(s0, pos.x, pos.y, pos.z);
		if (radius <= 0) return best, sky;
		double x0 = pos.x - radius, x1 = pos.x + radius, y0 = pos.y - radius, y1 = pos.y + radius;
		let it = BlockLinesIterator.CreateFromPos(pos, 0, radius, s0);
		while (it && it.Next())
		{
			let ln = it.CurLine;
			if (!ln || !ln.backsector || !ln.frontsector) continue;
			// the line's bounding box overlaps ours (bbox: 0 top, 1 bottom, 2 left, 3 right), then the box straddles it
			if (ln.bbox[3] <= x0 || ln.bbox[2] >= x1 || ln.bbox[0] <= y0 || ln.bbox[1] >= y1) continue;
			Vector2 a = ln.v1.p;
			Vector2 dl = ln.delta;
			int pos0 = 0, neg = 0;
			for (int k = 0; k < 4; k++)
			{
				Vector2 c = ((k & 1) ? x1 : x0, (k & 2) ? y1 : y0);
				double cr = (c.x - a.x) * dl.y - (c.y - a.y) * dl.x;
				if (cr > 0) pos0++; else if (cr < 0) neg++;
			}
			if (pos0 == 0 || neg == 0) continue;
			double ll = dl dot dl;
			double t = ll > 0 ? clamp(((pos.xy - a) dot dl) / ll, 0.0, 1.0) : 0.0;
			Vector2 cp = a + dl * t;
			for (int sd = 0; sd < 2; sd++)
			{
				Sector sec = sd == 0 ? ln.frontsector : ln.backsector;
				double fz;
				bool sk;
				[fz, sk] = SectorFloorPure(sec, cp.x, cp.y, pos.z);
				if (fz > best) { best = fz; sky = sk; }
			}
		}
		return best, sky;
	}

	// One sector's floor at (x, y) for something at height z (its highest solid floor at or below z), and sky.
	static clearscope double, bool SectorFloorPure(Sector s, double x, double y, double z)
	{
		double fz;
		Sector fs;
		F3DFloor ff;
		[fz, fs, ff] = s.NextLowestFloorAt(x, y, z);
		TextureID pic;
		if (ff) pic = ff.GetTexture(0);
		else if (fs) pic = fs.GetTexture(Sector.floor);
		else pic = s.GetTexture(Sector.floor);
		return fz, pic == skyflatnum;
	}

	double, bool BoxFloor(Vector3 p, double radius)
	{
		bool ok;
		double fz;
		[ok, fz] = BoxProbe(p, radius);
		if (!ok)
		{
			// no probe: the floor under the point (multiple returns are taken, then given back)
			bool sky;
			[fz, sky] = FloorBelow(p);
			return fz, sky;
		}
		return fz, probe.floorpic == skyflatnum;
	}

	// ================================================================ budgets (server cvars: every machine agrees)
	int Cap(int layer)
	{
		int r = rsqgo_residue;
		bool quest = rsqgo_platform == 1;
		int all = layer == 0 ? rsqgo_floor_all : rsqgo_ceil_all;
		int some = layer == 0 ? rsqgo_floor_some : rsqgo_ceil_some;
		int qst = layer == 0 ? rsqgo_floor_quest : rsqgo_ceil_quest;
		int lim;
		if (r == 1) lim = quest ? qst * some / max(1, all) : some;
		else lim = quest ? qst : all;          // All; and None, where fades decide and the ring is only a safety
		return max(0, lim);
	}

	// ================================================================ a residue actor has spawned (its PostBeginPlay)
	// Returns false when the actor is not wanted (it destroys itself then).
	bool Adopt(RSQGO_ResActor a)
	{
		if (!a || !Ready()) return false;
		int c = a.card;
		if (c < 0 || c >= data.cName.Size()) return false;
		int kind = data.cKind[c];
		if (kind == RSQGO_ResData.RK_FLOOR) return AdoptFloor(a, c);
		if (kind == RSQGO_ResData.RK_CEIL) return AdoptCeil(a, c);
		if (kind == RSQGO_ResData.RK_LAUNCH) Launch(a, c);
		else if (kind == RSQGO_ResData.RK_DRIPPER) StartDripper(c, a.pos, a.angle, level.maptime, a.waterlevel > 1);
		else if (kind == RSQGO_ResData.RK_DRIP) Drip(c, a.pos, a.vel, a.angle, level.maptime, a.waterlevel > 1);
		else if (kind == RSQGO_ResData.RK_SMEAR)
		{
			// a smearer spawned directly: InitSpawnedItem already set our target to its originator
			bool ok;
			Actor pre;
			[ok, pre] = SmearOrigin(a.target);
			if (ok) AddZone(c, a.pos, level.maptime, a, pre);
			return KeepEar(a);
		}
		return false;
	}

	// An actor that is a smear zone's ear stays, parked and unseen (it never reached a V label), when it is not
	// wanted as a spot; the zone destroys it when it ends.
	bool KeepEar(RSQGO_ResActor a)
	{
		if (!a || !a.zoneEar) return false;
		a.vel = (0, 0, 0);
		a.ChangeStatNum(STAT_PARKED);
		return true;
	}

	// BD's InitSpawnedItem for a MONSTER smearer whose spawner's target is o (attacks.zs): the originator walks up
	// the missile chain; a monster originator hands over its target as target and LastHeard (CopyFriendliness,
	// unless NOTARGET/NEVERTARGET); a player originator makes the smearer friendly to him, so it never smears a
	// player. Returns (smears at all, the target it starts with).
	static bool, Actor SmearOrigin(Actor o)
	{
		int guard = 0;
		while (o && (o.bMissile || o.default.bMissile) && guard++ < 64) o = o.target;
		if (!o) return true, null;
		if (o.bIsMonster)
		{
			let k = o.target;
			if (k && !k.bNoTarget && !k.bNeverTarget) return true, k;
			return true, null;
		}
		if (o.player) return false, null;
		return true, null;
	}

	// The engine's P_ZMovement over n Ticks for an actor at rest in xy: move, gravity while above floorz + 2, then
	// the floor clip at floorz + 2 (a missile explodes there). Returns the step that first touched the floor (0 =
	// none in n steps) and the height after n steps (at the touch, for a missile).
	static int, double SimFall(double z, double vz, double g, double fz, int n, bool missile)
	{
		int landed = 0;
		for (int i = 1; i <= n; i++)
		{
			if (vz == 0 && z == fz) continue;           // P_ZMovement does not run
			z += vz;
			if (z > fz + 2) vz -= g;
			if (z <= fz + 2)
			{
				z = fz;
				vz = 0;
				if (!landed) landed = i;
				if (missile) break;
			}
		}
		return landed, z;
	}

	// The boot smearer a floor card spawns on its smear tic: born where the card is then, with its originator.
	void FloorSmear(RSQGO_ResActor a, int c, double g, double fz)
	{
		let d = data;
		int st = d.cSmearT[c];
		bool ok = true;
		Actor pre = null;
		if (d.cMissile[c])
		{
			[ok, pre] = SmearOrigin(a.target);
		}
		if (!ok) return;
		int land;
		double sz;
		[land, sz] = SimFall(a.pos.z, a.vel.z, g, fz, st + 1, d.cMissile[c]);
		int mv = land ? land : st + 1;
		Vector3 sp = (a.pos.x + a.vel.x * mv, a.pos.y + a.vel.y * mv, sz);
		AddZone(d.cSmearCard[c], sp, level.maptime + st, a, pre);
	}

	// ---------------------------------------------------------------- floor spots, pools, footprints
	bool AdoptFloor(RSQGO_ResActor a, int c)
	{
		let d = data;
		if (d.cWaterGone[c] && a.waterlevel > 1) return false;  // BD: A_JumpIf(waterlevel > 1, "Splash")
		int now = level.maptime;
		double fz = a.floorz;
		double g = level.gravity * SectorGravity(a.pos) / 800.0;     // BD's spots and pools: Gravity 1
		bool smears = d.cSmearT[c] >= 0 && d.cSmearCard[c] >= 0;
		int stand = d.cStand[c];
		if (stand == RSQGO_ResData.ST_MISSILE)
		{
			// a gravity missile (the growing pools): any z movement at all ends on the floor in P_ExplodeMissile, so
			// only a pool spawned exactly on its floor at rest lives (one dropped by a monster dying in nukage or
			// water spawns Floorclip below it and explodes). Its smearer still spawns if the pool is airborne then.
			if (abs(a.pos.z - fz) >= 1.0 / 65536 || a.vel.z != 0)
			{
				if (smears)
				{
					int land;
					double zz;
					[land, zz] = SimFall(a.pos.z, a.vel.z, g, fz, d.cSmearT[c] + 1, true);
					if (!land) FloorSmear(a, c, g, fz);
				}
				return KeepEar(a);
			}
		}
		else if (stand == RSQGO_ResData.ST_VANISH)
		{
			// BD's A_CheckFloor after cCheckT + 1 movement steps (a spawned actor's 0-tic chain runs inside its first
			// Tick, after one move): the engine clips anything within 2 units onto the floor; off it, the spot is gone
			int land;
			double zc;
			[land, zc] = SimFall(a.pos.z, a.vel.z, g, fz, d.cCheckT[c] + 1, false);
			if (zc > fz) return false;
		}
		Vector3 p = (a.pos.x, a.pos.y, fz);
		// BD's liquid check (BD_CheckIfOverLiquid): over a liquid it checks, the spot is gone or leaves BD's water spot
		if (d.cLMask[c] != 0)
		{
			int bit = d.LiquidBit(a.floorpic);
			if (bit & d.cLMask[c])
			{
				if (d.cLAct[c] == 1 && d.cLCls[c] != "") Pend(d.cLCls[c], p, a.angle, now + d.cShowT[c]);
				return false;
			}
		}
		// the boot smearer: a zone, whatever happens to the actor (merged, recycled, faded)
		if (smears) FloorSmear(a, c, g, fz);
		if (d.cFace[c] && a.target) a.angle = a.AngleTo(a.target);
		// the merge grid (spots only)
		if (d.cSub[c] == RSQGO_ResData.SUB_SPOT && MergeOn())
		{
			int m = Merge(0, c, p, d.cCoverHi[c]);
			if (m != -1) return KeepEar(a);
		}
		a.vel = (0, 0, 0);
		a.SetOrigin(p, false);
		int s = NewSlot(a, c, 0, p, d.cCoverLo[c], d.cScale[c]);
		a.ChangeStatNum(STAT_PARKED);
		Schedule(s, now, d.cShowT[c]);
		QueueLater(s, now);
		if (d.cRampN[c] > 0)
		{
			gwSlot.Push(s); gwSer.Push(sSer[s]); gwT0.Push(now);
		}
		Ring(0, s);
		if (rsqgo_residue <= 0) FadeLater(s, now);
		stSpots++;
		return true;
	}

	// ---------------------------------------------------------------- ceiling spots
	bool AdoptCeil(RSQGO_ResActor a, int c)
	{
		let d = data;
		if (d.cWaterGone[c] && a.waterlevel > 1) return false;
		int now = level.maptime;
		Vector3 p = (a.pos.x, a.pos.y, a.ceilingz - a.height);
		// what BD's ceiling spot leaves (a drip that leaves a floor spot, a drip spawner), even if it merges: BD's
		// dripping density comes from every spot
		for (int k = d.cKid0[c]; k < d.cKid0[c] + d.cKidN[c]; k++)
		{
			int kc = d.kdCard[k];
			if (kc < 0) { Pend(d.kdCls[k], p, a.angle, now + d.kdT[k]); continue; }
			int kk = d.cKind[kc];
			if (kk == RSQGO_ResData.RK_DRIP) Drip(kc, p, (0, 0, 0), a.angle, now + d.kdT[k], false);
			else if (kk == RSQGO_ResData.RK_DRIPPER) StartDripper(kc, p, a.angle, now + d.kdT[k], false);
			else Pend(d.kdCls[k], p, a.angle, now + d.kdT[k]);
		}
		if (MergeOn())
		{
			int m = Merge(1, c, p, d.cCoverHi[c]);
			if (m != -1) return false;
		}
		a.vel = (0, 0, 0);
		a.SetOrigin(p, false);
		int s = NewSlot(a, c, 1, p, d.cCoverLo[c], d.cScale[c]);
		a.ChangeStatNum(STAT_PARKED);
		Schedule(s, now, d.cShowT[c]);
		QueueLater(s, now);
		Ring(1, s);
		Watch(s);
		if (rsqgo_residue <= 0) FadeLater(s, now);
		stSpots++;
		return true;
	}

	// ---------------------------------------------------------------- slots
	int NewSlot(RSQGO_ResActor a, int c, int layer, Vector3 p, double r, double s0)
	{
		int s;
		a.slotted = true;
		if (sFree.Size())
		{
			s = sFree[sFree.Size() - 1];
			sFree.Pop();
			sA[s] = a; sCard[s] = c; sLayer[s] = layer; sUsed[s] = true;
			sX[s] = p.x; sY[s] = p.y; sZ[s] = p.z; sR[s] = r; sS0[s] = s0; sFrame[s] = 0; sLink[s] = 0;
		}
		else
		{
			s = sA.Size();
			sA.Push(a); sCard.Push(c); sLayer.Push(layer); sSer.Push(1); sUsed.Push(true);
			sX.Push(p.x); sY.Push(p.y); sZ.Push(p.z); sR.Push(r); sS0.Push(s0); sFrame.Push(0); sLink.Push(0);
			sSec.Push(-1);
		}
		let sec = level.PointInSector(p.xy);
		sSec[s] = sec ? sec.Index() : -1;
		// BD's frame pick (A_Jump(255, ...): a playsim roll in BD too)
		int n = data.cFrN[c];
		if (n > 1)
		{
			double r0 = frandom[RSQGO_Play](0, 1);
			int f0 = data.cFr0[c];
			int pick = n - 1;
			for (int i = 0; i < n; i++)
			{
				r0 -= data.frW[f0 + i];
				if (r0 <= 0) { pick = i; break; }
			}
			sFrame[s] = pick;
		}
		a.slot = s;
		if (layer == 0) liveFloor++; else liveCeil++;
		if (gridOk) Link(s);
		return s;
	}

	void Kill(int s, bool fade)
	{
		if (s < 0 || s >= sA.Size() || !sUsed[s]) return;
		let a = RSQGO_ResActor(sA[s]);
		if (a) a.slotted = false;
		if (a && a.zoneEar && !fade)
		{
			// still a smear zone's ear: it stays, unseen (its Spawn state shows nothing), until the zone ends
			a.SetState(a.SpawnState);
		}
		else if (a)
		{
			if (fade)
			{
				// Blood That Stays None: unpark and fade out over 20 tics (BD's FadeA..D speed)
				a.ChangeStatNum(STAT_DEFAULT);
				let st = a.FindState('RSQGO_Fade');
				if (st) a.SetState(st);
				else a.Destroy();
			}
			else a.Destroy();
		}
		if (gridOk) Unlink(s);
		sUsed[s] = false;
		sSer[s]++;
		sA[s] = null;
		if (sLayer[s] == 0) liveFloor--; else liveCeil--;
		sFree.Push(s);
	}

	bool Live(int s, int ser)
	{
		return s >= 0 && s < sA.Size() && sUsed[s] && sSer[s] == ser;
	}

	// ---------------------------------------------------------------- rings
	void Ring(int layer, int s)
	{
		if (layer == 0) { rfSlot.Push(s); rfSer.Push(sSer[s]); }
		else { rcSlot.Push(s); rcSer.Push(sSer[s]); }
		Trim(layer);
	}

	void Trim(int layer)
	{
		int lim = Cap(layer);
		while ((layer == 0 ? liveFloor : liveCeil) > lim)
		{
			if (!PopOldest(layer)) break;
			stRecycled++;
		}
	}

	bool PopOldest(int layer)
	{
		if (layer == 0)
		{
			while (rfHead < rfSlot.Size())
			{
				int s = rfSlot[rfHead];
				int ser = rfSer[rfHead];
				rfHead++;
				if (Live(s, ser)) { Kill(s, false); CompactRings(); return true; }
			}
		}
		else
		{
			while (rcHead < rcSlot.Size())
			{
				int s = rcSlot[rcHead];
				int ser = rcSer[rcHead];
				rcHead++;
				if (Live(s, ser)) { Kill(s, false); CompactRings(); return true; }
			}
		}
		CompactRings();
		return false;
	}

	void CompactRings()
	{
		if (rfHead > 256 && rfHead * 2 > rfSlot.Size())
		{
			rfSlot.Delete(0, rfHead); rfSer.Delete(0, rfHead); rfHead = 0;
		}
		if (rcHead > 256 && rcHead * 2 > rcSlot.Size())
		{
			rcSlot.Delete(0, rcHead); rcSer.Delete(0, rcHead); rcHead = 0;
		}
	}

	// ---------------------------------------------------------------- the merge grid
	static int CellKey(int layer, double x, double y)
	{
		int cx = clamp(int(floor(x / CELL)) + 2048, 0, 4095);
		int cy = clamp(int(floor(y / CELL)) + 2048, 0, 4095);
		return (cx * 4096 + cy) * 2 + layer;
	}

	void Link(int s)
	{
		int key = CellKey(sLayer[s], sX[s], sY[s]);
		sLink[s] = grid.GetIfExists(key);
		grid.Insert(key, s + 1);
	}

	void Unlink(int s)
	{
		int key = CellKey(sLayer[s], sX[s], sY[s]);
		int h = grid.GetIfExists(key);
		if (h == s + 1)
		{
			if (sLink[s] > 0) grid.Insert(key, sLink[s]);
			else grid.Remove(key);
			sLink[s] = 0;
			return;
		}
		int guard = 0;
		while (h > 0 && guard++ < 4096)
		{
			int cur = h - 1;
			if (sLink[cur] == s + 1)
			{
				sLink[cur] = sLink[s];
				sLink[s] = 0;
				return;
			}
			h = sLink[cur];
		}
	}

	void RebuildGrid()
	{
		grid.Clear();
		for (int s = 0; s < sA.Size(); s++)
		{
			sLink[s] = 0;
			if (sUsed[s]) Link(s);
		}
		gridOk = true;
	}

	// A new spot of card c at p (its blood radius rNew): -1 = place it; -2 = it lies inside a spot of its colour
	// (nothing to add); otherwise the slot that grew instead.
	int Merge(int layer, int c, Vector3 p, double rNew)
	{
		if (!gridOk) RebuildGrid();
		let d = data;
		int colour = d.cColour[c];
		int cx = int(floor(p.x / CELL));
		int cy = int(floor(p.y / CELL));
		int looked = 0;
		int growAt = -1;
		// a spot covers only its own sector (an actor is drawn when its sector is): never merge through a wall
		let ns = level.PointInSector(p.xy);
		int nsi = ns ? ns.Index() : -1;
		for (int ix = -1; ix <= 1; ix++)
		{
			for (int iy = -1; iy <= 1; iy++)
			{
				int key = CellKey(layer, (cx + ix) * CELL + 1, (cy + iy) * CELL + 1);
				int h = grid.GetIfExists(key);
				while (h > 0 && looked < MERGE_LOOK)
				{
					int e = h - 1;
					h = sLink[e];
					looked++;
					if (!sUsed[e] || sLayer[e] != layer) continue;
					// a slot whose actor is gone (destroyed by anything but us: a script, a removal pass, a crusher)
					// covers nothing any more: free it, never let it swallow a new spot
					if (!sA[e]) { Kill(e, false); continue; }
					int ec = sCard[e];
					if (d.cColour[ec] != colour || d.cSub[ec] == RSQGO_ResData.SUB_PRINT) continue;
					// the live height: a parked floor spot rides its lift (MOVEWITHSECTOR) while sZ stays put
					let ea = sA[e];
					double ez = ea.pos.z;
					sZ[e] = ez;
					if (abs(ez - p.z) > 2) continue;
					if (sSec[e] != nsi) continue;
					Vector2 dv = (sX[e] - p.x, sY[e] - p.y);
					double dist = dv.Length();
					if (dist + rNew <= sR[e])
					{
						stMerged++;
						return -2;
					}
					if (growAt < 0 && ec == c && d.cSub[ec] == RSQGO_ResData.SUB_SPOT && dist <= sR[e] * 0.5 && rNew <= sR[e])
						growAt = e;
				}
			}
		}
		if (growAt >= 0)
		{
			let a = sA[growAt];
			if (a)
			{
				double cur = abs(a.scale.y);
				double q = rNew / sR[growAt];
				double ratio = sqrt(1 + q * q);
				if (cur * ratio <= sS0[growAt] * GROW_MAX)
				{
					a.scale = (a.scale.x * ratio, a.scale.y * ratio);
					sR[growAt] *= ratio;
					stGrown++;
					return growAt;
				}
			}
		}
		return -1;
	}

	// ---------------------------------------------------------------- reveals, grows, fades
	void Schedule(int s, int now, int showT)
	{
		if (showT <= 0) { Reveal(s); return; }
		rvSlot.Push(s); rvSer.Push(sSer[s]); rvDue.Push(now + showT);
	}

	// BD's A_QueueCorpse on its tic: our parked spot joins the engine's own corpse queue, shared with every other
	// queued actor, so sv_corpsequeuesize destroys it exactly when it would destroy BD's (the oldest first). The
	// slot is freed by the actor's OnDestroy (SlotGone).
	void QueueLater(int s, int now)
	{
		int qt = data.cQueueT[sCard[s]];
		if (qt < 0) return;
		if (qt == 0) { QueueNow(s); return; }
		quSlot.Push(s); quSer.Push(sSer[s]); quDue.Push(now + qt);
	}

	void QueueNow(int s)
	{
		let a = sA[s];
		if (a) a.A_QueueCorpse();
	}

	// A slot's actor is being destroyed by something other than Kill (the corpse queue, a script, a crusher): the
	// slot is free at once, so the rings and the merge grid never count a spot that is gone.
	void SlotGone(RSQGO_ResActor a)
	{
		int s = a.slot;
		if (s < 0 || s >= sA.Size() || !sUsed[s] || sA[s] != a) return;
		sA[s] = null;
		Kill(s, false);
	}

	void Reveal(int s)
	{
		let a = sA[s];
		if (!a) return;
		// a Name does not convert to a StateLabel, so the label goes by string (V0..V5)
		String lb = "V0";
		int fr = sFrame[s];
		if (fr >= 1 && fr <= 5) lb = String.Format("V%d", fr);
		let st = a.FindStateByString(lb, true);
		if (!st) st = a.FindStateByString("V0", true);
		if (st) a.SetState(st);
	}

	void FadeLater(int s, int now)
	{
		fdSlot.Push(s); fdSer.Push(sSer[s]); fdDue.Push(now + max(1, rsqgo_floor_none_fade) * TICRATE);
	}

	// ---------------------------------------------------------------- the ceiling-mover watch
	// BD's ceiling spot follows its ceiling (CEILINGHUGGER, ticking: within 5 tics). Ours is parked, so on any tic a
	// ceiling holding spots has changed height since the last (a door, a crusher, a moving 3D floor; also the tic
	// after a mover's last step, when its thinker is already gone), the spots there are set to their own ceiling.
	void Watch(int s)
	{
		int si = sSec[s];
		if (si >= 0 && si < level.Sectors.Size() && wSec.Find(si) == wSec.Size())
		{
			wSec.Push(si);
			wLastZ.Push(CeilSig(level.Sectors[si]));
		}
	}

	// The sector's ceiling and its 3D floors' bottoms at its centre: any plane change moves this.
	static double CeilSig(Sector sec)
	{
		double z = sec.ceilingplane.ZatPoint(sec.centerspot);
		int n = sec.Get3DFloorCount();
		for (int i = 0; i < n; i++) z += (i + 2) * sec.Get3DFloor(i).bottom.ZatPoint(sec.centerspot);
		return z;
	}

	void RunWatch()
	{
		int now = level.maptime;
		if (now - wRebuilt >= 175)
		{
			// rebuild, keeping each kept sector's last signature so a change across the rebuild is still seen
			wRebuilt = now;
			Array<int> oSec;
			Array<double> oZ;
			oSec.Move(wSec);
			oZ.Move(wLastZ);
			wSec.Clear();
			wLastZ.Clear();
			for (int s = 0; s < sA.Size(); s++) if (sUsed[s] && sLayer[s] == 1) Watch(s);
			for (int i = 0; i < wSec.Size(); i++)
			{
				int k = oSec.Find(wSec[i]);
				if (k < oSec.Size()) wLastZ[i] = oZ[k];
			}
		}
		for (int i = 0; i < wSec.Size(); i++)
		{
			int si = wSec[i];
			if (si < 0 || si >= level.Sectors.Size()) continue;
			let sec = level.Sectors[si];
			double sig = CeilSig(sec);
			if (sig == wLastZ[i]) continue;
			wLastZ[i] = sig;
			for (int s = 0; s < sA.Size(); s++)
			{
				if (!sUsed[s] || sLayer[s] != 1 || sSec[s] != si) continue;
				let a = sA[s];
				if (!a) continue;
				// the spot's own ceiling: the sector's, or the bottom of the 3D floor it hangs under
				double cz = sec.NextHighestCeilingAt(sX[s], sY[s], sZ[s], sZ[s] + a.height);
				double z = cz - a.height;
				a.SetZ(z);
				sZ[s] = z;
			}
		}
	}

	// ---------------------------------------------------------------- pending placements (playsim, saved)
	void Pend(String cls, Vector3 p, double ang, int due)
	{
		if (due <= level.maptime)
		{
			PlaceFloor(cls, p, ang);
			return;
		}
		pnDue.Push(due); pnCls.Push(cls); pnX.Push(p.x); pnY.Push(p.y); pnZ.Push(p.z); pnAng.Push(ang);
		stPend++;
	}

	void RunPending()
	{
		int now = level.maptime;
		int i = 0;
		while (i < pnDue.Size())
		{
			if (pnDue[i] > now) { i++; continue; }
			PlaceFloor(pnCls[i], (pnX[i], pnY[i], pnZ[i]), pnAng[i]);
			pnDue.Delete(i); pnCls.Delete(i); pnX.Delete(i); pnY.Delete(i); pnZ.Delete(i); pnAng.Delete(i);
		}
	}

	// ================================================================ ceiling launchers
	// BD's CeilBloodLauncher flies straight (speed 15 from its class, no gravity) for 3 tics (Long: 12), bouncing off
	// walls (BOUNCEONWALLS: FSlide::BounceWall reflects the move angle, sets the yaw to it, scales the xy speed by the
	// default WallBounceFactor 0.75, keeps Vel.Z); where it meets a ceiling that is not sky it leaves a ceiling spot
	// at its yaw. One trace per straight leg, at that leg's speed.
	void Launch(Actor a, int c)
	{
		let d = data;
		if (d.cWaterGone[c] && a.waterlevel > 1) return;
		Vector2 hv = a.vel.xy;
		double vz = a.vel.z;
		double tLeft = d.cLife[c];
		double t = 0;
		double yaw = a.angle;
		Vector3 from = a.pos;
		for (int b = 0; b <= LAUNCH_BOUNCES; b++)
		{
			Vector3 seg = (hv.x, hv.y, vz);
			double sp = seg.Length();
			if (sp < 0.001 || tLeft <= 0) return;
			FLineTraceData tr;
			a.LineTrace(atan2(seg.y, seg.x), sp * tLeft, -atan2(seg.z, seg.xy.Length()), TRF_THRUACTORS | TRF_ABSPOSITION,
				from.z, from.x, from.y, tr);
			if (tr.HitType == TRACE_HitCeiling)
			{
				if (tr.HitTexture == skyflatnum) return;        // BD's launcher is -SKYEXPLODE: it vanishes on sky
				t += tr.Distance / sp;
				Vector3 hp = tr.HitLocation;
				hp.z -= 1;                                      // BD's launcher (height 1) stops under the ceiling
				Pend(d.cSpot[c], hp, yaw, level.maptime + int(ceil(t)) + d.cSpotT[c]);
				return;
			}
			if (tr.HitType == TRACE_HitWall && d.cBounce[c] && tr.HitLine)
			{
				if (tr.HitLine.special == Line_Horizon) return; // BounceWall destroys it there
				double dt = tr.Distance / sp;
				t += dt;
				tLeft -= dt;
				if (tLeft <= 0) return;
				Vector2 ld = tr.HitLine.delta;
				double ll = ld.Length();
				if (ll < 0.001) return;
				Vector2 n = (-ld.y / ll, ld.x / ll);
				double dn = hv dot n;
				hv = (hv - n * (2 * dn)) * 0.75;
				double hl = hv.Length();
				if (hl < 1) hv = hl > 0.000001 ? hv * (2 / hl) : (n * (dn > 0 ? -2.0 : 2.0));
				yaw = atan2(hv.y, hv.x);
				double side = dn > 0 ? -1.0 : 1.0;
				from = tr.HitLocation + (n.x * side, n.y * side, 0);
				continue;
			}
			return;                                             // a floor, sky, an actor or nothing: BD leaves nothing
		}
	}

	// ================================================================ drips
	// One drip of card c from p with velocity v, starting at tic `at`. A drip that leaves a floor spot is playsim (its
	// spot is placed where and when it lands); the falling particle, the splash and the sound are cosmetic.
	void Drip(int c, Vector3 p, Vector3 v, double ang, int at, bool underwater)
	{
		let d = data;
		bool isPlay = d.cDSpot[c] != "" || underwater;
		if (d.cKeep[c] < 1)
		{
			double r = isPlay ? frandom[RSQGO_Play](0, 1) : Rand01();
			if (r >= d.cKeep[c]) return;
		}
		if (underwater)
		{
			// BD's Splash state: the child (Underblood2), through phase 1's takeover
			if (d.cWKid[c] != "") Pend(d.cWKid[c], p, ang, at);
			return;
		}
		// BD's drip is a gravity missile: it explodes within 2 units of its floorz (3D floor tops included), or is
		// destroyed without its Death state (no spot, splash or sound) on a sky floor
		double g = d.cGrav[c] * level.gravity * SectorGravity(p) / 800.0;
		double fz;
		bool sky;
		double rad = d.cBD[c] ? GetDefaultByType(d.cBD[c]).radius : 0;
		[fz, sky] = BoxFloor(p, rad);
		int tl = TimeToZ(p.z, v.z, g, fz + 2, 2100);
		if (tl < 0) return;
		if (v.x != 0 || v.y != 0)
		{
			double fz2;
			bool sky2;
			[fz2, sky2] = BoxFloor((p.x + v.x * tl, p.y + v.y * tl, p.z), rad);
			if (fz2 != fz)
			{
				fz = fz2;
				sky = sky2;
				tl = TimeToZ(p.z, v.z, g, fz + 2, 2100);
				if (tl < 0) return;
			}
		}
		Vector3 lp = (p.x + v.x * tl, p.y + v.y * tl, fz);
		if (!sky && d.cDSpot[c] != "") Pend(d.cDSpot[c], lp, ang, at + tl);
		stDrips++;
		if (!DripsOn()) return;
		// the fall decides its splash (ExecJob schedules it when the fall is drawn); the sound is its own job
		PushJob(J_FALL, at, c, tl, p, v.z, -g, lp, !sky && d.cLookSplash[c] >= 0);
		if (!sky && d.cDSound[c] != "") PushJob(J_SOUND, at + tl, c, 0, lp, 0, 0, lp, false);
	}

	// BD's drip spawners (CeilBlood*BloodSpawner): their whole program at once. A drip that leaves a spot is decided
	// now in the playsim; the others are cosmetic and only the ones BD lets live are scheduled.
	void StartDripper(int c, Vector3 p, double ang, int t0, bool underwater)
	{
		let d = data;
		bool drips = DripsOn();
		for (int r = d.cRun0[c]; r < d.cRun0[c] + d.cRunN[c]; r++)
		{
			int dc = d.ruCard[r];
			if (dc < 0 || d.cKind[dc] != RSQGO_ResData.RK_DRIP) continue;
			bool isPlay = d.cDSpot[dc] != "" || underwater;
			if (!isPlay && !drips) continue;
			int b = r * RSQGO_ResData.NRUN;
			for (int i = 0; i < d.ruCount[r]; i++)
			{
				int at = t0 + d.ruT[r] + i * d.ruInterval[r];
				Vector3 kp;
				Vector3 kv;
				if (d.ruMode[r] == 0)
				{
					// A_SpawnItemEx: offsets turned by the angle, velocity likewise
					double ox = RR(b, isPlay), oy = RR(b + 2, isPlay), oz = RR(b + 4, isPlay);
					double vx = RR(b + 6, isPlay), vy = RR(b + 8, isPlay), vz = RR(b + 10, isPlay);
					double s = sin(ang), co = cos(ang);
					kp = (p.x + ox * co + oy * s, p.y + ox * s - oy * co, p.z + oz);
					kv = (vx * co + vy * s, vx * s - vy * co, vz);
				}
				else
				{
					double dist = RR(b, isPlay), zh = RR(b + 4, isPlay);
					kp = (p.x + cos(ang) * dist, p.y + sin(ang) * dist, p.z + zh);
					kv = (0, 0, 0);
				}
				Drip(dc, kp, kv, ang, at, underwater);
			}
		}
	}

	bool DripsOn()
	{
		if (!cvDrips) cvDrips = CVar.GetCVar("rsqgo_drips", players[consoleplayer]);
		return !cvDrips || cvDrips.GetBool();
	}

	double RR(int b, bool isPlay)
	{
		double lo = data.ruR[b];
		double hi = data.ruR[b + 1];
		if (lo == hi) return lo;
		// BD's random(-5, 5) is an integer roll
		if (lo == floor(lo) && hi == floor(hi))
			return isPlay ? random[RSQGO_Play](int(lo), int(hi)) : int(lo) + int(Rand01() * (hi - lo + 1));
		return isPlay ? frandom[RSQGO_Play](lo, hi) : lo + (hi - lo) * Rand01();
	}

	// The floor a missile falling from p lands on (the highest solid floor at or below p, 3D floor tops included, as
	// a missile's floorz is built), and whether it is sky.
	static double, bool FloorBelow(Vector3 p)
	{
		let s = level.PointInSector(p.xy);
		if (!s) return p.z - 4096, false;
		double fz;
		Sector fs;
		F3DFloor ff;
		[fz, fs, ff] = s.NextLowestFloorAt(p.x, p.y, p.z);
		TextureID pic;
		if (ff) pic = ff.GetTexture(0);
		else if (fs) pic = fs.GetTexture(Sector.floor);
		else pic = s.GetTexture(Sector.floor);
		return fz, pic == skyflatnum;
	}

	static double SectorGravity(Vector3 p)
	{
		let s = level.PointInSector(p.xy);
		return s ? s.gravity : 1.0;
	}

	// The first tic the path is at or below zf (the engine moves, then applies gravity), or -1 past `limit`.
	static int TimeToZ(double z0, double vz, double g, double zf, int limit)
	{
		if (z0 <= zf) return 0;
		double t;
		if (g <= 0.000001)
		{
			if (vz >= 0) return -1;
			t = (zf - z0) / vz;
		}
		else
		{
			double qa = g * 0.5;
			double qb = -(vz + g * 0.5);
			double qc = zf - z0;
			t = (-qb + sqrt(qb * qb - 4 * qa * qc)) / (2 * qa);
		}
		int ti = int(ceil(t));
		return (ti <= limit) ? ti : -1;
	}

	// ---------------------------------------------------------------- cosmetic drip jobs (per machine)
	void PushJob(int kind, int at, int c, int life, Vector3 p, double vz, double acc, Vector3 lp, bool splash)
	{
		if (jWheel.Size() != JOB_WHEEL)
		{
			jWheel.Clear();
			for (int i = 0; i < JOB_WHEEL; i++) jWheel.Push(0);
		}
		int now = level.maptime;
		if (at <= now)
		{
			CamUpdate();
			ExecJob(kind, c, life, p, vz, acc, lp, splash);
			return;
		}
		if (at - now >= JOB_WHEEL) return;
		int j;
		if (jFree.Size())
		{
			j = jFree[jFree.Size() - 1];
			jFree.Pop();
			jDue[j] = at; jKind[j] = kind; jCard[j] = c; jLife[j] = life; jX[j] = p.x; jY[j] = p.y; jZ[j] = p.z;
			jVZ[j] = vz; jAcc[j] = acc; jLX[j] = lp.x; jLY[j] = lp.y; jLZ[j] = lp.z; jSplash[j] = splash;
		}
		else
		{
			j = jDue.Size();
			jDue.Push(at); jKind.Push(kind); jCard.Push(c); jLife.Push(life); jX.Push(p.x); jY.Push(p.y); jZ.Push(p.z);
			jVZ.Push(vz); jAcc.Push(acc); jLX.Push(lp.x); jLY.Push(lp.y); jLZ.Push(lp.z); jSplash.Push(splash);
			jLink.Push(0);
		}
		int b = at % JOB_WHEEL;
		jLink[j] = jWheel[b];
		jWheel[b] = j + 1;
	}

	void RunJobs()
	{
		if (jWheel.Size() != JOB_WHEEL) return;
		int now = level.maptime;
		int b = now % JOB_WHEEL;
		int h = jWheel[b];
		jWheel[b] = 0;
		CamUpdate();
		while (h > 0)
		{
			int j = h - 1;
			h = jLink[j];
			// a job from a whole wheel later cannot exist (PushJob refuses them): anything not due now is dropped
			if (jDue[j] == now)
				ExecJob(jKind[j], jCard[j], jLife[j], (jX[j], jY[j], jZ[j]), jVZ[j], jAcc[j], (jLX[j], jLY[j], jLZ[j]), jSplash[j]);
			jFree.Push(j);
		}
	}

	void CamUpdate()
	{
		int now = level.maptime;
		if (dripTic == now) return;
		dripTic = now;
		dripStarted = 0;
		sndCells.Clear();
		let cam = players[consoleplayer].camera;
		camOk = cam != null;
		if (camOk) camPos = cam.pos;
	}

	void ExecJob(int kind, int c, int life, Vector3 p, double vz, double acc, Vector3 lp, bool splash)
	{
		if (kind == J_SOUND)
		{
			// one landing sound per 128-unit cell a tic (design 5), none beyond earshot
			int cell = (int(p.x) >> 7) * 4099 + (int(p.y) >> 7);
			if (sndCells.Find(cell) == sndCells.Size() && (!camOk || (p - camPos).Length() < 2048))
			{
				sndCells.Push(cell);
				S_StartSoundAt(p, data.cDSound[c], CHAN_BODY);
			}
			return;
		}
		if (kind == J_SPLASH)
		{
			// scheduled by its drawn fall: no second cull, not counted against the falls
			DripVT(data.cLookSplash[c], c, p, 0, 0, life);
			return;
		}
		// the named local limits (cosmetic, this machine): falls started a tic, distance from this camera
		if (!camOk || (p - camPos).Length() > DRIP_FAR || dripStarted >= DRIP_PARTICLES_TIC) return;
		dripStarted++;
		DripVT(data.cLookFall[c], c, p, vz, -acc, life);
		if (splash) PushJob(J_SPLASH, level.maptime + life, c, data.cSplashLife[c], lp, 0, 0, lp, false);
	}

	// One drip look played by a VisualThinker, as BD's drip actor is drawn: BD's untranslated frames through BD's class
	// Translation (the engine palette-squashes them as it does BD's sprite, with the PLAYPAL the rotation loads), BD's
	// scale, alpha and render style; it falls from p (move, then gravity, as the engine moves BD's actor).
	void DripVT(int look, int c, Vector3 p, double vz, double grav, int life)
	{
		let d = data;
		if (look < 0 || look >= d.lFr0.Size() || d.lFrN[look] <= 0 || life <= 0) return;
		TextureID tex = d.lfTex[d.lFr0[look]];
		if (!tex.IsValid()) return;
		TranslationID tr = 0;
		let bd = d.cBD[c];
		if (bd) tr = GetDefaultByType(bd).Translation;
		let vt = RSQGO_ResVT(VisualThinker.Spawn("RSQGO_ResVT", tex, p, (0, 0, vz), d.cAlpha[c], 0, 0,
			(abs(d.cDSX[c]), d.cDSY[c]), (0, 0), d.cDStyle[c], tr));
		if (!vt) return;
		if (d.cDSX[c] < 0) vt.bXFlip = true;
		vt.Start(d, look, life, grav);
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

	// ================================================================ smear zones (BootSmearer*)
	// One zone per BD smearer: born at t0 at p, with the target InitSpawnedItem gave it (pre) and the parked actor
	// whose LastHeard stands in for its own (ear). Every decision uses playsim pointers, geometry, server cvars and
	// random[RSQGO_Play], tests every player in BD's order, never the console player.
	void AddZone(int c, Vector3 p, int t0, Actor ear, Actor pre)
	{
		let d = data;
		if (c < 0 || d.cKind[c] != RSQGO_ResData.RK_SMEAR || !d.cItemC[c]) return;
		if (zWheel.Size() != ZONE_WHEEL)
		{
			zWheel.Clear();
			for (int i = 0; i < ZONE_WHEEL; i++) zWheel.Push(0);
		}
		if (zLive >= MAX_ZONES) Evict();
		int z;
		if (zFree.Size())
		{
			z = zFree[zFree.Size() - 1];
			zFree.Pop();
		}
		else
		{
			z = zUsed.Size();
			zUsed.Push(false); zStale.Push(false); zSer.Push(0); zCard.Push(0); zX.Push(0); zY.Push(0); zZ.Push(0);
			zT0.Push(0); zL0.Push(0); zPhase.Push(0); zDue.Push(0); zEnd.Push(0); zGap.Push(0); zLook.Push(0);
			zTargetMo.Push(null); zPre.Push(null); zEar.Push(null); zMask.Push(0); zLink.Push(0);
		}
		zUsed[z] = true; zStale[z] = false; zCard[z] = c; zX[z] = p.x; zY[z] = p.y; zZ[z] = p.z;
		zT0[z] = t0;
		// BD: Spawn = TNT1 A 0, TNT1 A 1 A_Look (its first look the tic after birth), See = A_Chase x cChase, then
		// A_Die runs the first check: cFirst (from the walk) = first look + cChase
		zL0[z] = t0 + max(0, d.cFirst[c] - d.cChase[c]);
		zPhase[z] = ZP_BIRTH;
		zEnd[z] = t0 + d.cFirst[c] + (d.cCount[c] - 1) * d.cPeriod[c];
		zGap[z] = d.cPeriod[c];
		zLook[z] = random[RSQGO_Play](0, MAXPLAYERS - 1);   // a MONSTER's LastLookPlayerNumber at spawn
		zTargetMo[z] = null;
		zPre[z] = pre;
		zEar[z] = ear;
		let ra = RSQGO_ResActor(ear);
		if (ra) ra.zoneEar = true;
		zMask[z] = 0;
		zqZ.Push(z); zqSer.Push(zSer[z]);
		WheelIn(z, max(level.maptime + 1, t0));
		if (t0 <= level.maptime) Birth(z);
		zLive++;
		stZones++;
	}

	// BD's smearer appears: its LastHeard is what InitSpawnedItem gave it (CopyFriendliness), not whatever the ear
	// heard before the smear tic.
	void Birth(int z)
	{
		if (zPhase[z] != ZP_BIRTH) return;
		zPhase[z] = ZP_LOOK;
		let e = zEar[z];
		if (e) e.LastHeard = zPre[z];
	}

	void WheelIn(int z, int due)
	{
		zDue[z] = due;
		int b = due % ZONE_WHEEL;
		zLink[z] = zWheel[b];
		zWheel[b] = z + 1;
	}

	// A zone being walked (out of the wheel): its slot is free at once. An evicted one is still linked: stale.
	void FreeZone(int z, bool linked = false)
	{
		if (!zUsed[z]) return;
		zUsed[z] = false;
		zSer[z]++;
		let e = RSQGO_ResActor(zEar[z]);
		zEar[z] = null;
		zTargetMo[z] = null;
		zPre[z] = null;
		if (e)
		{
			e.zoneEar = false;
			if (!e.slotted) e.Destroy();
		}
		if (linked) zStale[z] = true;
		else zFree.Push(z);
		zLive--;
	}

	// The table is full: drop the oldest zone that never locked (the blood no player has come near longest), else
	// the locked zone whose window ends first. Birth order is the eviction queue.
	void Evict()
	{
		int pick = -1;
		int lockPick = -1;
		for (int i = zqHead; i < zqZ.Size(); i++)
		{
			int z = zqZ[i];
			if (!zUsed[z] || zSer[z] != zqSer[i])
			{
				if (i == zqHead) zqHead++;
				continue;
			}
			if (zPhase[z] != ZP_WINDOW) { pick = z; break; }
			if (lockPick < 0 || zEnd[z] < zEnd[lockPick]) lockPick = z;
		}
		if (pick < 0) pick = lockPick;
		if (pick >= 0) FreeZone(pick, true);
		CompactZoneQueue();
	}

	void CompactZoneQueue()
	{
		if (zqHead > 1024 && zqHead * 2 > zqZ.Size())
		{
			zqZ.Delete(0, zqHead); zqSer.Delete(0, zqHead); zqHead = 0;
		}
		if (zqZ.Size() > 4 * zLive + 4096)
		{
			Array<int> nz;
			Array<int> ns;
			for (int i = zqHead; i < zqZ.Size(); i++)
			{
				int z = zqZ[i];
				if (zUsed[z] && zSer[z] == zqSer[i]) { nz.Push(z); ns.Push(zqSer[i]); }
			}
			zqZ.Move(nz); zqSer.Move(ns); zqHead = 0;
		}
	}

	void RunZones()
	{
		if (zWheel.Size() != ZONE_WHEEL) return;
		let d = data;
		int now = level.maptime;
		if (lookStamp != now) { lookStamp = now; lookYoung = 0; lookOld = 0; }
		int b = now % ZONE_WHEEL;
		int h = zWheel[b];
		zWheel[b] = 0;
		bool everyone = SmearAll();
		// walk the bucket; entries not due this tic (a later lap) go back in
		while (h > 0)
		{
			int z = h - 1;
			h = zLink[z];
			if (zStale[z]) { zStale[z] = false; zFree.Push(z); continue; }
			if (!zUsed[z]) continue;
			if (zDue[z] != now) { WheelIn(z, zDue[z]); continue; }
			int c = zCard[z];
			int period = d.cPeriod[c];
			Vector3 p = (zX[z], zY[z], zZ[z]);
			if (now >= zT0[z]) Birth(z);
			if (everyone)
			{
				// rsqgo_smear_all (Q4): every player who comes close, once each, in BD's window from the zone's birth
				int f0 = zT0[z] + d.cFirst[c];
				if (now < f0) { WheelIn(z, f0); continue; }
				for (int i = 0; i < MAXPLAYERS; i++)
				{
					if (!playeringame[i] || (zMask[z] & (1 << i))) continue;
					let mo = players[i].mo;
					if (mo && Closer(p, mo, d.cDist[c]))
					{
						mo.GiveInventory(d.cItemC[c], d.cAmount[c]);
						zMask[z] |= (1 << i);
						stGives++;
					}
				}
				if (now >= f0 + (d.cCount[c] - 1) * period) FreeZone(z);
				else WheelIn(z, now + period);
				continue;
			}
			if (zPhase[z] == ZP_BIRTH) { WheelIn(z, max(now + 1, zT0[z])); continue; }
			if (zPhase[z] == ZP_LOOK)
			{
				if (now < zL0[z]) { WheelIn(z, zL0[z]); continue; }
				LookTic(z, p, now);
				continue;
			}
			// ZP_WINDOW: BD's A_JumpIfCloser(60) against the actor it locked (a null target never jumps)
			let tmo = zTargetMo[z];
			if (tmo && Closer(p, tmo, d.cDist[c]))
			{
				tmo.GiveInventory(d.cItemC[c], d.cAmount[c]);          // BD: A_GiveToTarget(token, 8), then it ends
				stGives++;
				FreeZone(z);
				continue;
			}
			if (now >= zEnd[z]) { FreeZone(z); continue; }
			WheelIn(z, now + zGap[z]);
			zGap[z] = period;
		}
	}

	// One tic of BD's unlocked smearer. The first look tic is A_Look alone (LastHeard, then P_LookForPlayers); every
	// later tic is See's A_Chase (its target, then P_LookForPlayers) and, when that finds nobody, SetIdle's A_Look in
	// the same tic. Whatever locks on tic L puts the first check at L + cChase.
	void LookTic(int z, Vector3 p, int now)
	{
		bool first = now == zL0[z];
		bool young = now - zT0[z] < LOOK_YOUNG;
		if (!first)
		{
			// A_Chase keeps a living, shootable target (a pool's killer)
			let pre = zPre[z];
			if (pre && pre.health > 0 && pre.bShootable) { LockOn(z, pre, now); return; }
			zPre[z] = null;
		}
		if (young ? lookYoung >= LOOK_BUDGET_YOUNG : lookOld >= LOOK_BUDGET_OLD)
		{
			WheelIn(z, now + (young ? 1 : LOOK_OLD_PERIOD));
			return;
		}
		probeSet = false;
		int pn = -1;
		bool rolled = false;
		if (!first)
		{
			pn = LookForPlayers(z, p, young);
			rolled = lookRolled;
		}
		if (pn < 0)
		{
			// A_Look: LastHeard first
			bool skipSight = false;
			Actor targ = null;
			if (level.compatflags & COMPATF_SOUNDTARGET)
			{
				let ss = level.PointInSector(p.xy);
				if (ss) targ = ss.SoundTarget;
			}
			else if (zEar[z]) targ = zEar[z].LastHeard;
			if (targ && targ.health <= 0) targ = null;
			if (targ && targ.player && ((targ.player.cheats & CF_NOTARGET) || !targ.bFriendly)) skipSight = true;
			else if (targ && targ.bShootable) { LockOn(z, targ, now); return; }
			// then its own P_LookForPlayers (a second pass in the same tic only differs by the invisibility roll)
			if (!skipSight && (first || rolled)) pn = LookForPlayers(z, p, young);
		}
		if (pn >= 0 && players[pn].mo) { LockOn(z, players[pn].mo, now); return; }
		WheelIn(z, now + (young ? 1 : LOOK_OLD_PERIOD));
	}

	// The smearer has a target: a monster (infighting, or the noise of one) means it smears no player's boots.
	void LockOn(int z, Actor mo, int now)
	{
		if (!mo.player) { FreeZone(z); return; }
		let d = data;
		int c = zCard[z];
		int period = d.cPeriod[c];
		zTargetMo[z] = mo;
		zPhase[z] = ZP_WINDOW;
		int f = now + d.cChase[c];
		// A_Die's Die(): the first 8-tic death frame loses pr_killmobj() & 3 tics
		int r = (period > 1) ? random[RSQGO_Play](0, 3) : 0;
		if (period - r < 1) r = period - 1;
		zGap[z] = period - r;
		zEnd[z] = d.cCount[c] > 1 ? f + (d.cCount[c] - 1) * period - r : f;
		WheelIn(z, max(now + 1, f));
	}

	// BD's P_LookForPlayers + isTargetablePlayer for the smearer (MONSTER, LOOKALLAROUND, -FRIENDLY, no
	// SEEINVISIBLE): from the player after LastLookPlayerNumber, each in-game player once, remembering each one
	// tested. Returns the player it targets, or -1.
	int LookForPlayers(int z, Vector3 p, bool young)
	{
		lookRolled = false;
		int pn = zLook[z];
		for (int k = 0; k < MAXPLAYERS; k++)
		{
			pn = (pn + 1) & (MAXPLAYERS - 1);
			if (!playeringame[pn]) continue;
			zLook[z] = pn;
			let pl = players[pn];
			let mo = pl.mo;
			if (!mo || !mo.bShootable) continue;
			if (pl.cheats & CF_NOTARGET) continue;
			if (pl.health <= 0) continue;
			if (young) lookYoung++; else lookOld++;
			if (!SightFrom(p, mo)) continue;
			if ((mo.bShadow && !(level.compatflags & COMPATF_INVISIBILITY)) || mo.bGhost)
			{
				if ((mo.pos.xy - p.xy).Length() > 128 && mo.vel.xy.LengthSquared() < 25) continue;   // sneaking
				lookRolled = true;
				if (random[RSQGO_Play](0, 255) < 225) continue;
			}
			return pn;
		}
		return -1;
	}

	// P_CheckSight(smearer, player, SF_SEEPASTSHOOTABLELINES) from the zone's point: the probe stands there with
	// height 0, as BD's smearer does (REJECT, BLOCKSIGHT and the player's full height, exactly as the engine tests).
	bool SightFrom(Vector3 p, Actor mo)
	{
		if (!probe)
		{
			probe = Actor.Spawn("RSQGO_ResProbe", p);
			if (probe) probe.ChangeStatNum(STAT_PARKED);
		}
		if (!probe) return false;
		if (!probeSet)
		{
			probe.SetOrigin(p, false);
			probeSet = true;
		}
		return probe.CheckSight(mo, SF_SEEPASTSHOOTABLELINES);
	}

	// BD's A_JumpIfCloser (checks.zs CheckIfCloser) from a smearer at p with height 0
	static bool Closer(Vector3 p, Actor targ, double dist)
	{
		if ((targ.pos.xy - p.xy).Length() >= dist) return false;
		if (p.z > targ.pos.z) return p.z - targ.pos.z - targ.height < dist;
		return targ.pos.z - p.z < dist;
	}

	// ================================================================ once a tic (RSQGO_Manager.WorldTick)
	void WorldTic()
	{
		if (!Ready()) return;
		double t0 = rsqgo_debug ? MSTimeF() : 0;
		int now = level.maptime;
		// reveals
		int i = 0;
		while (i < rvDue.Size())
		{
			if (rvDue[i] > now) { i++; continue; }
			if (Live(rvSlot[i], rvSer[i])) Reveal(rvSlot[i]);
			rvSlot.Delete(i); rvSer.Delete(i); rvDue.Delete(i);
		}
		// pool grows: BD's A_SetScale steps, to the tic
		i = 0;
		while (i < gwSlot.Size())
		{
			int s = gwSlot[i];
			if (!Live(s, gwSer[i])) { gwSlot.Delete(i); gwSer.Delete(i); gwT0.Delete(i); continue; }
			int c = sCard[s];
			int t = now - gwT0[i];
			int r0 = data.cRamp0[c];
			int rn = data.cRampN[c];
			let a = sA[s];
			for (int k = r0; k < r0 + rn; k++)
			{
				if (data.rpT[k] == t && a) a.scale = (data.rpS[k], data.rpS[k]);
			}
			if (rn == 0 || t >= data.rpT[r0 + rn - 1]) { gwSlot.Delete(i); gwSer.Delete(i); gwT0.Delete(i); continue; }
			i++;
		}
		// BD's A_QueueCorpse, on its tic
		i = 0;
		while (i < quDue.Size())
		{
			if (quDue[i] > now) { i++; continue; }
			if (Live(quSlot[i], quSer[i])) QueueNow(quSlot[i]);
			quSlot.Delete(i); quSer.Delete(i); quDue.Delete(i);
		}
		// fades (Blood That Stays None): due order, so only the head is tested
		while (fdHead < fdDue.Size() && fdDue[fdHead] <= now)
		{
			if (Live(fdSlot[fdHead], fdSer[fdHead])) Kill(fdSlot[fdHead], true);
			fdHead++;
		}
		if (fdHead > 256 && fdHead * 2 > fdDue.Size())
		{
			fdSlot.Delete(0, fdHead); fdSer.Delete(0, fdHead); fdDue.Delete(0, fdHead); fdHead = 0;
		}
		if (pnDue.Size()) RunPending();
		if (wSec.Size() || now - wRebuilt >= 175) RunWatch();
		RunZones();
		RunJobs();
		// a budget lowered from the menu takes effect without waiting for the next spot
		if (now % TICRATE == 0) { Trim(0); Trim(1); }
		if (rsqgo_debug)
		{
			stMs += MSTimeF() - t0;
			if (now % DEBUG_EVERY == DEBUG_EVERY / 2) DebugLine();
		}
	}

	private void DebugLine()
	{
		Console.Printf("\cfRSQ Gore residue\c- t%d: %d takeovers | floor %d/%d, ceiling %d/%d | %d new, %d merged, %d grown, %d recycled | %d zones live (+%d, %d smeared) | %d drips, %d pending | %.3f ms",
			level.maptime, stTake, liveFloor, Cap(0), liveCeil, Cap(1), stSpots, stMerged, stGrown, stRecycled, zLive, stZones,
			stGives, stDrips, pnDue.Size(), stMs / DEBUG_EVERY);
		stTake = stSpots = stMerged = stGrown = stRecycled = stZones = stGives = stDrips = stPend = 0;
		stMs = 0;
	}
}

// ============================================================================
// The actors the takeover spawns instead of BD's residue classes. Generated subclasses (residue_cards.zs,
// RSQGO_R_<BD class>) set the card and, for visible ones, BD's Translation, Scale, Alpha, RenderStyle and model
// frames (V0..Vn). Each does its work in PostBeginPlay (after its spawner has set its velocity, angle and target):
// a spot parks itself and stays; everything else hands its job to the residue and is gone before it ever ticks.
// ============================================================================

class RSQGO_ResActor : Actor
{
	int card;
	property Card: card;
	bool zoneEar;       // a smear zone reads this actor's LastHeard (the engine's noise flood sets it)
	bool slotted;       // a live floor or ceiling slot owns this actor
	int slot;           // ... that slot

	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOBLOODDECALS
		+THRUACTORS
		-SOLID
		Radius 1;
		Height 1;
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		// the manager's cached holder (EventHandler.Find allocates nothing); the iterator only when it is empty
		let m = RSQGO_Manager.Get();
		RSQGO_ResidueRings r = m ? m.res : null;
		if (!r)
		{
			r = RSQGO_ResidueRings.Get(true);
			if (m) m.res = r;
		}
		if (!r || !r.Adopt(self)) Destroy();
	}

	// Destroyed by anything but the residue's own Kill (which clears slotted first): free the slot now.
	override void OnDestroy()
	{
		if (slotted)
		{
			slotted = false;
			let m = RSQGO_Manager.Get();
			RSQGO_ResidueRings r = m ? m.res : null;
			if (r) r.SlotGone(self);
		}
		Super.OnDestroy();
	}
}

// Floor spots, pools and footprints: carried by moving floors (MOVEWITHSECTOR lets the engine move a NOBLOCKMAP
// actor with its sector: p_map.cpp P_ChangeSector), clipped into liquid floors like BD's (FLOORCLIP).
class RSQGO_ResFloor : RSQGO_ResActor
{
	Default
	{
		+MOVEWITHSECTOR
		+FLOORCLIP
		+FORCEXYBILLBOARD
	}

	States
	{
	RSQGO_Fade:
		#### # 1 A_FadeOut(0.05);
		Loop;
	}
}

// Ceiling spots: kept on their ceiling by the residue's ceiling-mover watch (a parked actor is never ticked, so
// CEILINGHUGGER alone would not follow a moving ceiling).
class RSQGO_ResCeil : RSQGO_ResActor
{
	Default
	{
		+CEILINGHUGGER
	}

	States
	{
	RSQGO_Fade:
		#### # 1 A_FadeOut(0.05);
		Loop;
	}
}

class RSQGO_ResLauncher : RSQGO_ResActor { Default { +NOINTERACTION RenderStyle "None"; } }
class RSQGO_ResDripper : RSQGO_ResActor { Default { +NOINTERACTION RenderStyle "None"; } }
class RSQGO_ResDrip : RSQGO_ResActor { Default { +NOINTERACTION RenderStyle "None"; } }
class RSQGO_ResSmear : RSQGO_ResActor { Default { +NOINTERACTION RenderStyle "None"; } }

// The smear zones' sight probe: stands at a zone's point with height 0 (BD's smearer: Height 0) for CheckSight.
// NOSECTOR keeps its moves out of every sector list; it is parked, never ticked, never drawn.
class RSQGO_ResProbe : Actor
{
	Default
	{
		+NOSECTOR
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+NOTELEPORT
		+NOTONAUTOMAP
		+DONTSPLASH
		RenderStyle "None";
		Radius 0;
		Height 0;
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		ChangeStatNum(RSQGO_ResidueRings.STAT_PARKED);
	}
}

// ============================================================================
// RSQGO_ResVT -- one cosmetic drip look (BD's falling drip, or its landing splash flipbook), drawn by the engine's
// sprite path exactly as BD's actor: its texture's sprite offsets at its Scale, its Translation and render style.
// Steps its own frames at BD's tics (no global ANIMDEFS phase); falls by its velocity, then its gravity, each tic.
// Per machine, never an actor, never a shared RNG; gone after its life (and after a load, which drops the data).
// ============================================================================
class RSQGO_ResVT : VisualThinker
{
	int look, age, life, shown;
	double grav;
	transient RSQGO_ResData d;

	void Start(RSQGO_ResData dd, int lk, int lf, double g)
	{
		d = dd;
		look = lk;
		life = lf;
		grav = g;
		age = 0;
		shown = 0;
	}

	override void Tick()
	{
		if (!d || look < 0 || look >= d.lFr0.Size()) { Destroy(); return; }
		if (IsFrozen()) { Super.Tick(); return; }
		if (age >= life) { Destroy(); return; }
		Super.Tick();
		Vel.Z -= grav;
		age++;
		// BD's frame for this age
		int f0 = d.lFr0[look];
		int n = d.lFrN[look];
		if (n > 1)
		{
			int t = age;
			int k = 0;
			while (k < n - 1 && t >= d.lfTics[f0 + k]) { t -= d.lfTics[f0 + k]; k++; }
			if (k != shown)
			{
				shown = k;
				Texture = d.lfTex[f0 + k];
			}
		}
	}
}
