// =====================================================================
// RS_MonsterCatalog -- the monster-side parts bin.
// ---------------------------------------------------------------------
// Exactly the same job RS_Catalog.zs does for weapons, and deliberately
// a SEPARATE file rather than entries bolted into that one:
//   * weapon lookups shouldn't have to wade past monster entries;
//   * monsters need entry kinds weapons don't have -- summon rosters,
//     satellites, portals, morph stages;
//   * it mirrors the subsystem-split convention already in the tree
//     rather than growing one god-file.
//
// THE RULE: no monster file names a raw projectile, minion, satellite,
// or effect class inline. Everything routes through here, so swapping
// what an Archvile summons is a one-line edit in one known place rather
// than a hunt through fifteen monster files.
//
// Also defines the small shared actor bases the primitives depend on
// (RS_MonsterSatellite, RS_SummonPortal) -- they're catalog machinery,
// not monster content.
// =====================================================================

class RS_MonsterCatalog
{
	// =================================================================
	// SUMMON ROSTERS
	// -----------------------------------------------------------------
	// Colourful Hell's summoners don't spawn one fixed thing -- they
	// pick from a table, and the table gets nastier as a charge counter
	// climbs. These return a class by roster + step, so a monster asks
	// for "tier 2 of the archvile roster" and never names a class.
	//
	// Comparison chains, not static const arrays: this engine build
	// doesn't resolve `static const TYPE name[] = {...}` in a class body
	// reliably (three real bugs so far).
	// =================================================================

	// The Archvile's escalating portal roster. CHP's Abyss portal ramps
	// Revenant -> Imp -> Cacodemon as its charge climbs; this is that
	// ladder, widened slightly at the top so a long fight keeps
	// escalating instead of flatlining on Cacodemons.
	static Class<Actor> ROSTER_VilePortal(int step)
	{
		if (step <= 0) return "DoomImp";
		if (step == 1) return "Revenant";
		if (step == 2) return "Cacodemon";
		if (step == 3) return "HellKnight";
		return "BaronOfHell";
	}

	// The Gray Archvile's flat conjure -- CHP picks one of six with
	// equal odds and no escalation. Kept flat on purpose: it's the
	// "wide but shallow" counterpart to the portal's "narrow but
	// deepening" ladder, and the contrast is the design.
	static Class<Actor> ROSTER_VileConjure(int pick)
	{
		if (pick <= 0) return "Demon";
		// [RS_Monsters] was "RS_CG_C0001", from the RS_CG_* chaingunner set that is
		// no longer in the tree. Every other entry in this list is a VANILLA actor,
		// so the chaingunner entry is the vanilla one -- and the chaingunner dial
		// replaces ChaingunGuy, so this still yields one of ours.
		if (pick == 1) return "ChaingunGuy";
		if (pick == 2) return "Revenant";
		if (pick == 3) return "HellKnight";
		if (pick == 4) return "Spectre";
		return "Cacodemon";
	}

	static int ROSTER_VileConjureCount() { return 6; }

	// Baron's tentacle pack -- two different minion shapes from one
	// summoner, a melee rusher and a ranged plinker, so the pack has
	// internal structure rather than being four copies of one thing.
	static Class<Actor> MINION_BaronRusher()  { return null; }
	static Class<Actor> MINION_BaronRanger()  { return null; }

	// Pain Elemental's permanent escort. Small, fast, replaced when it
	// dies -- the thing that makes the White PE fight feel maintained
	// rather than a one-shot summon.
	static Class<Actor> MINION_Sentinel()     { return null; }

	// The Butcher's pack -- fast fragile harassers released by a
	// hit-counter rather than summoned on a timer.
	static Class<Actor> MINION_DemonDog()     { return null; }

	// =================================================================
	// SATELLITES -- orbiting attached children.
	// =================================================================

	static Class<Actor> SAT_VileEye()  { return null; }

	// =================================================================
	// PORTALS / SPAWNERS -- free-standing objects that summon on their
	// own schedule rather than the monster summoning directly.
	// =================================================================

	static Class<Actor> PORTAL_Vile()  { return null; }

	// =================================================================
	// MORPH STAGES -- the "death is a phase change" chain.
	// =================================================================

	// NOTE: there is no MORPH_CacoReal any more. The old "shell dies and
	// reveals the true form" chain was an RS invention; CHP's Hades
	// (09_K) instead goes NOPAIN below 3000 HP and summons two red
	// cacodemons inline, which is what RS_Cacodemon now implements.
	static Class<Actor> MORPH_PainPilot()  { return null; }
	static Class<Actor> MORPH_BaronFallen(){ return null; }

	// Revenant chain: body -> shade -> (shade brings a bound shadow).
	static Class<Actor> MORPH_RevShade()   { return null; }
	static Class<Actor> MORPH_RevShadow()  { return null; }

	// Arachnotron shrink chain: full -> split -> remnant -> shards.
	static Class<Actor> MORPH_ArachStage2(){ return null; }
	static Class<Actor> MORPH_ArachStage3(){ return null; }

	// EX tier -- the vile boss dies into a phantom rather than ending.
	static Class<Actor> MORPH_ExVilePhantom(){ return null; }

	// =================================================================
	// MONSTER PROJECTILES
	// -----------------------------------------------------------------
	// Every entry below resolves to a real class in
	// zscript/monsters/monsterfx/ -- the 474-entry library extracted per
	// docs/catalog_notes.txt. Nothing here is a placeholder name.
	//
	// The point of routing through these accessors rather than naming
	// the class in the monster file: swapping what the Baron's tendrils
	// throw is one edit here, and the same projectile can be handed to
	// an affix or a weapon later without hunting for it.
	// =================================================================

	// --- Archvile ---
	static Class<Actor> PROJ_VileSpike()     { return "RS_VileGroundSpike"; }
	static Class<Actor> PROJ_VileBolt()      { return "RS_WVileBolt1"; }
	// [RS_Monsters] returned "RS_WVileBolt2", defined in monsterfx/ which is no
	// longer in the tree. NOTHING CALLS THIS, so null cannot change behaviour --
	// naming a lookalike projectile would.
	static Class<Actor> PROJ_VileBoltHeavy() { return null; }
	static Class<Actor> PROJ_VileIce()       { return "RS_IceABVile"; }
	static Class<Actor> PROJ_VileDrop()      { return "RS_RockVileDrop"; }

	// --- Baron / tendrils ---
	// --- Zombieman (family 01) ---
	// First family catalogued under rs_21. Every projectile its tiers
	// fire, so RS_Zombieman.BuildTierAttacks can express them as
	// RS_AttackProfile entries in an RS_AttackSlot rather than naming raw
	// classes inline in state code. That is the difference between 917
	// loose actors and a parts bin something can choose from.
	//
	// TERMINOLOGY, because it drifted once already: an attack is an
	// RS_AttackProfile, held in an RS_AttackSlot whose cursor advances
	// one entry per pull. It is NOT a "socket" -- sockets are the affix
	// BREADTH CAP on a weapon (rs_16: distinct affixes <= sockets, 1..5,
	// read at RS_Upgrade_Slate.zsc:45) and have nothing to do with
	// attacks. PACK is the eight PRESENTATION axes (projectile, casing,
	// muzzleflash, smoke, sound, puff, impact, trail), also a different
	// thing.
	static Class<Actor> PROJ_ZM_Gas()        { return "RS_Gas11"; }
	static Class<Actor> PROJ_ZM_IceBolt()    { return "RS_IceZombieShot"; }
	static Class<Actor> PROJ_ZM_AbyssBolt()  { return "RS_AbyssZshotCH"; }
	static Class<Actor> PROJ_ZM_Rock()       { return "RS_ZombieRock"; }
	static Class<Actor> PROJ_ZM_Bone1()      { return "RS_BoneProjZM"; }
	static Class<Actor> PROJ_ZM_Bone2()      { return "RS_BoneProjZM2"; }
	static Class<Actor> PROJ_ZM_Bone3()      { return "RS_BoneProjZM3"; }
	static Class<Actor> PROJ_ZM_Shovel()     { return "RS_ShoveZM"; }
	static Class<Actor> PROJ_ZM_Tornado()    { return null; }
	static Class<Actor> MINION_ZM_Bones()    { return "RS_MrBones"; }

	static Class<Actor> PROJ_BaronStar()     { return "RS_BaronStar"; }
	static Class<Actor> PROJ_BaronRing()     { return "RS_BaronRing"; }
	static Class<Actor> PROJ_BaronBomb()     { return "RS_BaronFbomb"; }
	static Class<Actor> PROJ_TendrilBolt()   { return "RS_Firehand1"; }

	// --- Cacodemon ---
	// [RS_Monsters] returned "RS_CacoBallBase" (monsterfx/, gone). No callers.
	static Class<Actor> PROJ_CacoBall()      { return null; }
	static Class<Actor> PROJ_CacoFire()      { return "RS_CacoFire3"; }
	static Class<Actor> PROJ_CacoIce()       { return "RS_BigIceCaco"; }

	// --- Pain Elemental / sentinels ---
	static Class<Actor> PROJ_SentinelFlare() { return "RS_PlasmaPE"; }
	static Class<Actor> PROJ_PainPulse()     { return "RS_AbyssPEPulse"; }
	static Class<Actor> PROJ_PainStorm()     { return "RS_StormShot1"; }

	// --- Mancubus / Arachnotron ---
	static Class<Actor> PROJ_MancFire()      { return "RS_FatsoShotYE"; }
	// [RS_Monsters] returned "RS_ArachnotronPlasma" (monsterfx/, gone). No callers.
	static Class<Actor> PROJ_ArachPlasma()   { return null; }

	// =================================================================
	// FAMILY 04 -- CHAINGUNNER. Every projectile its fourteen creatures
	// fire, routed through here per THE RULE at the top of this file.
	// The fourteen bodies named these 38 classes inline, which is
	// exactly what this file exists to prevent.
	//
	// Names are CH's own (RS_ + CH's actor name). They are NOT on the
	// numeric tier scheme the bodies use -- the bodies are tiers and
	// belong on a ladder; a projectile is a PART, and parts are named
	// for what they are. Renaming these is a separate decision and is
	// not made here by default.
	// =================================================================

	// --- the common bullets -------------------------------------------
	static Class<Actor> PROJ_CG_SpamShots()    { return "RS_SpamShotsCguy"; }
	static Class<Actor> PROJ_CG_SpamShotsEX()  { return "RS_SpamShotsCGuyEX"; }
	static Class<Actor> PROJ_CG_SpamShotsEX2() { return "RS_SpamShotsCGuyEX2"; }
	static Class<Actor> PROJ_CG_Rail()         { return "RS_CGRailBuff"; }
	static Class<Actor> PROJ_CG_Nail()         { return "RS_CGNail"; }
	static Class<Actor> PROJ_CG_Needle()       { return "RS_NeedlesCg1"; }
	static Class<Actor> PROJ_CG_NeedleTrail()  { return "RS_NeedlesCg2"; }
	static Class<Actor> PROJ_CG_Ice()          { return "RS_IceZombieShot2"; }
	static Class<Actor> PROJ_CG_AbyssShot()    { return "RS_AbyssZShotCH3"; }
	static Class<Actor> PROJ_CG_Fireblu()      { return "RS_FireBCGguy"; }

	// --- the mechanics ------------------------------------------------
	static Class<Actor> PROJ_CG_Cover()        { return "RS_BrownSandBagCGuy"; }
	static Class<Actor> PROJ_CG_Shield()       { return "RS_GenShield"; }
	static Class<Actor> PROJ_CG_Orb()          { return "RS_BrownOrbCguy"; }
	static Class<Actor> PROJ_CG_NailRing()     { return "RS_GrayCGuff"; }
	static Class<Actor> PROJ_CG_NailRingSub()  { return "RS_CGthing3"; }
	static Class<Actor> PROJ_CG_Puddle()       { return "RS_Puddle1"; }
	static Class<Actor> PROJ_CG_PuddleCrawl()  { return "RS_Puddle2"; }
	static Class<Actor> PROJ_CG_Splash()       { return "RS_SplashAbyssCguy"; }
	static Class<Actor> PROJ_CG_BigOne()       { return "RS_CGBigOne"; }
	static Class<Actor> PROJ_CG_BigEX()        { return "RS_CGBigEX"; }
	static Class<Actor> PROJ_CG_Bomb()         { return "RS_YellowBombCGuyEX"; }
	static Class<Actor> PROJ_CG_Mortar()       { return "RS_HKRedDeath"; }

	// --- telegraphs and trails (no damage, pure information) ----------
	static Class<Actor> PROJ_CG_ProxBeep()     { return "RS_BlueChainPuff3"; }
	static Class<Actor> PROJ_CG_WindUp()       { return "RS_SpiralLoadGeneEX"; }
	static Class<Actor> PROJ_CG_SelfTrail()    { return "RS_TrailSPCguy"; }
	static Class<Actor> PROJ_CG_Trail11()      { return "RS_Trail11"; }
	static Class<Actor> PROJ_CG_Trail14()      { return "RS_Trail14"; }
	static Class<Actor> PROJ_CG_Puff()         { return "RS_BlueChainPuff2"; }
	static Class<Actor> PROJ_CG_MuzzleGlow()   { return "RS_RedRevLoad"; }
	static Class<Actor> PROJ_CG_Spark()        { return "RS_SparkPuff1"; }
	static Class<Actor> PROJ_CG_Marker()       { return "RS_CHBSTarget"; }

	// --- detonating puff, three range grades --------------------------
	static Class<Actor> PROJ_CG_Deto(int grade)
	{
		// Comparison chain, not an array literal -- CLAUDE.md.
		if (grade <= 0) return "RS_DetoPuffCG";     // splash 42
		if (grade == 1) return "RS_DetoPuff2";      // splash 38
		return "RS_DetoPuff3";                      // splash 32
	}

	// --- seek strength by range band ----------------------------------
	// CH's three Boomers are ONE weapon with three tracking strengths:
	// close seeks hard, mid seeks weakly, far is dumb-fire. The grade IS
	// the mechanic; do not collapse them.
	static Class<Actor> PROJ_CG_Boomer(int band)
	{
		if (band <= 0) return "RS_Boomer1";         // A_SeekerMissile(8,8)
		if (band == 1) return "RS_Boomer2";         // A_SeekerMissile(4,4)
		return "RS_Boomer3";                        // no seek at all
	}

	// --- the white boss's live experiments (summons, not bullets) -----
	static Class<Actor> MINION_CG_Volatile()   { return "RS_VolativeCaco"; }
	static Class<Actor> MINION_CG_Worm()       { return "RS_SlimyWorm"; }
	static Class<Actor> MINION_CG_Splice()     { return "RS_SpliceBaron"; }

	// =================================================================
	// BULLET OPTIONS -- the assemblable set.
	//
	// Not every projectile is worth offering. A reskin of a straight
	// bullet is not an OPTION, it is a palette swap, and padding a
	// selection list with seventeen indistinguishable bullets makes the
	// list worthless. These are the ones that do something a plain
	// bullet does not -- each was read out of CH's own states, not
	// guessed from the name.
	//
	// This is the enumerable set for the affix / attack-profile work:
	// Count + Class + Name + Desc, so a picker or a roll can walk it
	// without any caller hardcoding a class name.
	// =================================================================
	const RS_CG_BULLET_OPTIONS = 17;
	static int BULLET_OptionCount() { return RS_CG_BULLET_OPTIONS; }

	static Class<Actor> BULLET_OptionClass(int i)
	{
		switch (i)
		{
			case 0:  return "RS_BrownSandBagCGuy";
			case 1:  return "RS_GenShield";
			case 2:  return "RS_Puddle1";
			case 3:  return "RS_GrayCGuff";
			case 4:  return "RS_BrownOrbCguy";
			case 5:  return "RS_BlueChainPuff3";
			case 6:  return "RS_YellowBombCGuyEX";
			case 7:  return "RS_CGBigEX";
			case 8:  return "RS_CGBigOne";
			case 9:  return "RS_SpiralLoadGeneEX";
			case 10: return "RS_TrailSPCguy";
			case 11: return "RS_NeedlesCg2";
			case 12: return "RS_Boomer1";
			case 13: return "RS_SplashAbyssCguy";
			case 14: return "RS_CGRailBuff";
			case 15: return "RS_FireBCGguy";
			case 16: return "RS_HKRedDeath";
		}
		return null;
	}

	static string BULLET_OptionName(int i)
	{
		switch (i)
		{
			case 0:  return "Deployed Cover";
			case 1:  return "Counter-Fire Shield";
			case 2:  return "Crawling Slime";
			case 3:  return "Nail Ring";
			case 4:  return "Lobbed Orb";
			case 5:  return "Proximity Beep";
			case 6:  return "Cascade Bomb";
			case 7:  return "Seeding Finisher";
			case 8:  return "Pulsing Seeker";
			case 9:  return "Wind-Up Glyph";
			case 10: return "Self-Trailing Bolt";
			case 11: return "Poison Needle";
			case 12: return "Banded Seeker";
			case 13: return "Planted Splash";
			case 14: return "Live Rail";
			case 15: return "Burn Line";
			case 16: return "Placed Detonation";
		}
		return "";
	}

	// One sentence each, describing the MECHANIC -- what it does that a
	// plain bullet does not. Read from CH's states.
	static string BULLET_OptionDesc(int i)
	{
		switch (i)
		{
			case 0:  return "Destructible cover. A health-80 body that inflates, steps once, then blocks. Shoot it down.";
			case 1:  return "A shield that fights back -- popping it launches three live bolts and drops a cell.";
			case 2:  return "Two-stage area denial. The lob sprays crawlers that ricochet, wander, and spit.";
			case 3:  return "Hitscan that plants a twelve-way nail ring at every landing point.";
			case 4:  return "Ballistic arc. It drops over distance, so range becomes a skill check.";
			case 5:  return "Harmless. It beeps twice and shrinks -- pure proximity information.";
			case 6:  return "Eight-stage expanding detonation, radius 32 to 312, escalating rolls.";
			case 7:  return "Trails saws inbound, then lands delayed sub-munitions where you ran to.";
			case 8:  return "Grow-then-shrink seeker that trails saws and leaves ground fire.";
			case 9:  return "No damage at all. A shrinking glyph that makes a wind-up readable.";
			case 10: return "Spawns its own trail actor from every frame of flight.";
			case 11: return "Lays trail in flight, then scatters six more across a two-stage burst.";
			case 12: return "Seek strength banded by range -- tracks hard close, dumb-fires far.";
			case 13: return "Planted under the target, detonates upward and launches what it hits.";
			case 14: return "A rail beam built from live actors, each seeking, shrinking and popping.";
			case 15: return "Passes through bodies and burns a corridor, then detonates on geometry.";
			case 16: return "Not a projectile -- a detonation placed at a coordinate. Mortar or mine.";
		}
		return "";
	}

	// =================================================================
	// SOUNDS
	// =================================================================

	static sound SND_Summon()   { return "vile/firecrkl"; }
	static sound SND_Enrage()   { return "vile/sight"; }
	static sound SND_Morph()    { return "misc/spawn"; }
}

// =====================================================================
// RS_MonsterSatellite -- base for anything that orbits its master.
// ---------------------------------------------------------------------
// The lifecycle CHP arrived at (and R2 of the earlier research pass
// confirmed as the pattern worth adopting): spawn attached via master,
// warp to the master every tic, and die when the master does. The
// master-death check is what stops orphaned satellites hanging in the
// air over a corpse forever.
//
// Cosmetic-only by default -- no damage, no blocking. A subclass that
// wants to be dangerous overrides that itself.
// =====================================================================

class RS_MonsterSatellite : Actor
{
	double OrbitRadius;
	double OrbitHeight;
	double OrbitAngle;
	double OrbitSpeed;

	Default
	{
		Radius 8;
		Height 8;
		+NOGRAVITY
		+NOBLOCKMAP
		+NOCLIP
		+DONTSPLASH
		+NOTELEPORT
		RenderStyle "Add";
		Alpha 0.85;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (OrbitRadius <= 0) OrbitRadius = 40;
		if (OrbitHeight <= 0) OrbitHeight = 40;
		if (OrbitSpeed  == 0) OrbitSpeed  = 6.0;
	}

	override void Tick()
	{
		Super.Tick();

		// No master, or the master is dead/gone -- we go too. This is
		// the cleanup that the old DECORATE version did by broadcasting
		// a "GoAway" inventory item; a direct check is cheaper and
		// can't be missed.
		if (!master || master.health <= 0)
		{
			Destroy();
			return;
		}

		OrbitAngle += OrbitSpeed;
		if (OrbitAngle >= 360.0) OrbitAngle -= 360.0;

		Vector3 p = (master.pos.xy + (cos(OrbitAngle), sin(OrbitAngle)) * OrbitRadius,
		             master.pos.z + OrbitHeight);
		SetOrigin(p, true);
		angle = OrbitAngle + 90;
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

// =====================================================================
// RS_VileEye -- the Archvile's orbiting eye.
// Visual tell that the vile is in its summoning phase; the player
// learns "eyes out = adds incoming" without a HUD message.
// =====================================================================

class RS_VileEye : RS_MonsterSatellite
{
	Default
	{
		Scale 0.35;
		Alpha 0.9;
	}

	States
	{
	Spawn:
		PUFI ABCD 3 Bright;
		Loop;
	}
}

// =====================================================================
// RS_VilePortal -- a free-standing summoner.
// ---------------------------------------------------------------------
// CHP's Abyss Archvile doesn't summon directly: it drops one of these
// and the PORTAL does the escalating. That indirection is worth keeping
// because it changes the fight's shape -- the player gets a second
// object worth destroying, and killing it early denies the ramp.
//
// Charge climbs every tic it's alive. At each threshold it spawns the
// next entry from the roster, so leaving it alone is what makes the
// fight get worse.
// =====================================================================

class RS_VilePortal : Actor
{
	int  PortalCharge;
	int  PortalStep;
	int  PortalTier;        // set by whoever spawned it
	int  nextSpawnTic;

	const RS_PORTAL_INTERVAL = 105;   // 3 seconds between escalations
	const RS_PORTAL_MAXSTEP  = 4;

	Default
	{
		Health 120;
		Radius 20;
		Height 56;
		+NOGRAVITY
		+SHOOTABLE
		+NOBLOOD
		+DONTTHRUST
		-COUNTKILL
		RenderStyle "Add";
		Alpha 0.8;
		DeathSound "misc/spawn";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		nextSpawnTic = level.time + RS_PORTAL_INTERVAL;
	}

	override void Tick()
	{
		Super.Tick();

		if (health <= 0 || level.time < nextSpawnTic)
			return;

		nextSpawnTic = level.time + RS_PORTAL_INTERVAL;

		Class<Actor> cls = RS_MonsterCatalog.ROSTER_VilePortal(PortalStep);
		if (cls)
		{
			double ang = random(0, 359);
			Vector3 p = (pos.xy + (cos(ang), sin(ang)) * 64.0, pos.z);
			let mo = Spawn(cls, p, ALLOW_REPLACE);
			if (mo)
			{
				mo.bCOUNTKILL = false;
				mo.master = master;
				mo.target = target;
				let rm = RS_MonsterMaster(mo);
				if (rm)
					rm.SetTier(clamp(PortalTier - 2 + PortalStep, 0, 12), true);
			}
		}

		// Each spawn escalates the next one. This is the whole mechanic:
		// the longer the portal lives, the worse what comes out of it.
		if (PortalStep < RS_PORTAL_MAXSTEP)
			PortalStep++;
	}

	States
	{
	Spawn:
		TFOG ABABCDEFGHIJ 4 Bright;
		Goto Idle;
	Idle:
		TFOG GHIJ 6 Bright;
		Loop;
	Death:
		TFOG JIHG 5 Bright;
		Stop;
	}
}
