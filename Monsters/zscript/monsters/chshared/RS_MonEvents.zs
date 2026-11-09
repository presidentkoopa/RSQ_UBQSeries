// ============================================================================
// RS_CHEvents.zs -- Colourful Hell's bonus / ambush event system, native.
//
// Source of truth: C:\Users\Command\Desktop\CH\DECORATE.txt:904-1694 (the file
// at the CH ROOT, not decorate\*.txt; read whole 2026-08-06). CH's own comment
// banner over this block reads "//#### FUN EXTRA ####" (DECORATE.txt:901).
// 49 classes here; the 2 remaining leftovers from that file are in
// RS_CHShared.zs. 42 of the file's 93 actors were already imported by earlier
// lanes and are referenced read-only, never redefined.
//
// ---------------------------------------------------------------------------
// DORMANT IN CH -- AND KEPT DORMANT. READ THIS BEFORE WIRING ANYTHING.
// ---------------------------------------------------------------------------
// NOTHING in CH fires this system. Proven, not assumed: each of
// CH_RandomEvent, CH_RandomEventGood, CH_RandomEventBad, CH_RandomBoon,
// CH_BadItch, CH_BonusBoon, CH_BonusEnemy1..9, CH_BonusEnemySingle,
// CH_BonusMisc1..4, CH_PackofMedium, CH_PackofMediumLeader, CH_PackofHitScan,
// CH_BossSurprise1, CH_EnemySinglePick, CH_BonusEnemyBaseSpawner,
// SoulHiveCH, TentacleTimeCH, RevenantGraySquad, CommonArch2B,
// CommonRevenant2B, AbyssPE2B, BlackLSoul2B and GrayLSoul2B was grepped
// case-insensitively across the ENTIRE CH tree (DECORATE.txt, decorate\*.txt,
// Gibs.txt, Bloods.txt, SNDINFO.txt, TRNSLATE.txt, MENUDEF.txt, CVARINFO.txt,
// LOADACS.txt, acs\*.o, source\*.acs). Every one of them returns ZERO hits
// outside DECORATE.txt itself. There is no `replaces`, no ACS call, no map
// hook, no MAPINFO handler.
//
// That dormancy is faithful and is preserved verbatim. This file adds NO
// `replaces`, NO spawner hook, NO EventHandler, NO cvar gate that CH does not
// have. The machinery exists and works when called; the owner designs the
// trigger. See the "HOW TO FIRE IT" section at the bottom of this header.
//
// ---------------------------------------------------------------------------
// CONVERSION RULES APPLIED (each from a real compile error on this engine)
// ---------------------------------------------------------------------------
//   * ThrustThing angle expressions wrapped in int(): CH writes
//     ThrustThing(angle*256/(random(1,360)),35,0,0); angle is a double here.
//     The arithmetic is CH's, unchanged -- only the cast is added.
//   * Bouncetype doom -> BounceType "Doom".
//   * RenderStyle Add -> RenderStyle "Add".
//   * a_die -> A_Die(); A_stop -> A_Stop(); a_jump -> A_Jump().
//   * `loop` -> Loop;
//   * No abstract anywhere (it makes actors invisible in this project).
//   * No static const array literals.
//   * No damage rolls exist in this block, so none were flattened.
//   * No CallACS in this block, so no rs_ch_* gate was added. (Cvar proposals
//     for a future options menu are listed at the bottom -- NOT implemented.)
//
// ---------------------------------------------------------------------------
// STRIPS
// ---------------------------------------------------------------------------
// NONE. This block contains no ACS announcer, no CHRandom_GibGenerator /
// NashGore gore chain, no DRLA RL*/RareArmorPool drop, and no LegenDoom gate.
// Nothing was removed. The only commented-out lines below are comments in CH
// ITSELF (CH DECORATE.txt:1208, 1235, 1264, 1351, 1375, 1415, 1450, 1482,
// 1536, 1560, 1594, 1626, 1655, 1689 -- all
// `// BBOM B 1 A_SpawnItemEx("ArchvileFire",...)`), kept as CH wrote them.
//
// ---------------------------------------------------------------------------
// SPRITES -- 2 prefixes, both already in the repo tree. 0 copied.
// ---------------------------------------------------------------------------
//   RED8 frames A B C D E F G H  (8/8)  -> sprites/monsters/fx/RED8[A-H]0.png
//   BBOM frames A B               (2/7)  -> sprites/monsters/fx/BBOM[A-G]0.png
//   No prefix in this block is missing; nothing was extracted from any IWAD.
//
// ---------------------------------------------------------------------------
// SOUNDS -- 0/0.
// ---------------------------------------------------------------------------
// CH DECORATE.txt declares ZERO sound properties and ZERO A_PlaySound /
// A_StartSound calls across all 1694 lines (grep: SeeSound|DeathSound|
// PainSound|ActiveSound|AttackSound|MeleeSound|BounceSound|HowlSound|
// A_PlaySound|A_StartSound|A_PlayWeaponSound|SoundName -> no hits). These
// actors are silent in CH. Verbatim silence is faithful; no sound was
// substituted, no lump was copied, no SNDINFO entry is needed.
// SNDINFO block to report: NONE.  TRNSLATE block to report: NONE
// (CH\TRNSLATE.txt holds only BBEASTEX1-6, CYANCYB01-02, YellowRev01 and
// BRCybGren01-06 -- monster palettes, unreferenced from DECORATE.txt).
//
// ---------------------------------------------------------------------------
// UNRESOLVED, PROVEN ABSENT IN CH -- two, both CH's own quirks, kept verbatim
// ---------------------------------------------------------------------------
//  1. CH_EnemySinglePick (CH DECORATE.txt:1517-1528) drops VANILLA class
//     names: DoomImp, Revenant, Archvile, HellKnight, BaronOfHell, CacoDemon,
//     Spectre, ChaingunGuy, PainElemental, Fatso, CyberDemon. `grep -i
//     "^\s*actor <name>"` over the whole CH tree returns nothing for any of
//     them -- they are GZDoom engine classes, not CH classes. They are kept
//     VERBATIM and deliberately NOT renamed to RS_: in CH those names are
//     intercepted by CH's own coloursets, and here they are intercepted by
//     ours (RS_ImpColourset replaces DoomImp, RS_Colourset1 replaces Revenant,
//     and so on for all eleven). Renaming them would change behaviour;
//     leaving them is what reproduces CH.
//  2. "Zombie" on the same list (CH DECORATE.txt:1525) is a CH TYPO and a
//     dangling reference IN CH. `grep -i "^\s*actor Zombie\b"` over the whole
//     CH tree: no hits. CH's zombie colourset replaces ZombieMan, not Zombie,
//     so this entry never yields a CH zombie in CH either -- at best it hits
//     GZDoom's unrelated Strife `Zombie`. Kept verbatim and flagged rather
//     than "corrected" to ZombieMan: silently fixing it would make our table
//     roll differently from CH's. A RandomSpawner DropItem name is resolved at
//     runtime, so an unknown name is a log line, never a compile or load
//     failure.
//  Nothing else in this block is unresolved. Every other referenced class was
//  chased to its CH file:line and maps to a class we already ship:
//     RS_CommonImp/Green/Blue/Purple/Yellow/RedImp  <- CH Imps.txt:987,1072,
//        1207,1363,1535,1688
//     RS_CommonHK/Green/Blue/Purple/YellowHK        <- CH Hellknights.txt:1171,
//        1274,1380,1518,1674
//     RS_CommonBaron/GreenBaron/PurpleBaron/FireBluBaron
//                                                   <- CH Barons.txt:1947,2040,
//        2524,1738
//     RS_CommonCGuy/GreenCGuy/BlueCGuy/RedCGuy      <- CH Chaingunners.txt:995,
//        1077,1178,1707
//     RS_CommonSG/BlueSG/BlackSG2                   <- CH Shotgunners.txt:813,
//        1033,1994
//     RS_YellowZombie/BlueZombie/PurpleZombie       <- CH Zombies.txt:1275,
//        1013,1125
//     RS_BlackCGuy CH Chaingunners.txt:1873, RS_BlackRevenant CH
//        Revenants.txt:2953, RS_BlackArch CH Archviles.txt:4328, RS_BlackHK CH
//        Hellknights.txt:2254, RS_BlackBaron CH Barons.txt:3857, RS_BlackCaco
//        CH Cacodemons.txt:2073, RS_BlackZombie CH Zombies.txt:1569,
//        RS_BlackPE CH thepains.txt:1958, RS_BlackMind CH MASTERMINDS.txt:3790
//     RS_CommonLSoul/Green/Blue/Purple/Yellow/RedLSoul <- CH lostsouls.txt:722,
//        758,848,928,1003,1085
//     RS_GrayLSoul2 CH lostsouls.txt:552, RS_BlackLSoul2 CH lostsouls.txt:1771
//     RS_AbyssPE2 CH thepains.txt:609, RS_CommonArch CH Archviles.txt:2313,
//        RS_CommonRevenant CH Revenants.txt:1341, RS_GrayRevenant2 CH
//        Revenants.txt:1173, RS_RoseTentacle CH Barons.txt:4268,
//        RS_CH_Cirno CH Gibs.txt:131, RS_SGBurst CH Shotgunners.txt:2513,
//        RS_RandomizerArc CH Archviles.txt:3388
//  Vanilla pickups/weapons in CH_RandomBoon and the misc sneaks (Stimpack,
//  ClipBox, RocketAmmo, RocketBox, Medikit, BlurSphere, BackPack, CellPack,
//  Cell, GreenArmor, BlueArmor, PlasmaRifle, SuperShotgun, Berserk, ChainSaw,
//  Shotgun, SoulSphere, HealthBonus, ArchvileFire) are engine classes and are
//  kept verbatim, exactly as CH writes them.
//
// ---------------------------------------------------------------------------
// TIER
// ---------------------------------------------------------------------------
// These are event actors, not tiered monsters. No RS_Zom.SetTier, no
// RS_ZomTierToken, no colour icon. CH gives them none. The MONSTERS they
// spawn carry their own tiers, set in their own family files.
//
// ---------------------------------------------------------------------------
// HOW TO FIRE IT -- entry points, for whoever designs the trigger
// ---------------------------------------------------------------------------
// Spawn ONE of these three and the whole chain runs itself:
//   RS_Mon_RandomEvent      -- the full table (CH DECORATE.txt:1146)
//   RS_Mon_RandomEventGood  -- boons only  (CH DECORATE.txt:1165)
//   RS_Mon_RandomEventBad   -- ambushes only (CH DECORATE.txt:1174)
// Or spawn RS_CH_BadItch (RS_CHShared.zs) attached to an actor to get a
// self-repeating drip of them.
//
// The chain is always three hops:
//   1. a RandomSpawner picks a SEED  (RS_Mon_BonusEnemy*/Misc*/Boon/Single)
//   2. the seed is a bouncing invisible projectile, RS_Mon_BonusEnemyBaseSpawner
//      -- it ricochets off walls/floors for ~2-3 seconds, self-thrusting, then
//      drops a SNEAK
//   3. the sneak, RS_Mon_BonusEnemyBaseSpawner2, is an invisible floating
//      wanderer that drifts a short way from where the seed landed and then
//      vomits the payload and A_Die()s
// So the payload never lands on the player's head -- it arrives from somewhere
// nearby, which is the whole point of the two-hop delay.
// ---------------------------------------------------------------------------
// ============================================================================


// ===========================================================================
// THE TWO CHASSIS
// ===========================================================================

// CH: DECORATE.txt:904.  Hop 2 -- the "seed". An invisible bouncing projectile
// that scatters itself around the spawn point for ~2.5s, then drops a sneak.
// Every RS_Mon_Bonus* below is this class with a different Death13.
class RS_Mon_BonusEnemyBaseSpawner : Actor   // CH DECORATE.txt:904
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 128;
		Mass 25;
		Projectile;
		+THRUACTORS      // CH lists +ThruActors twice (:911 and :918); once here
		+RANDOMIZE
		+BOUNCEONWALLS
		+INVISIBLE
		+BOUNCEONFLOORS
		+NOTONAUTOMAP
		+CANBOUNCEWATER
		BounceCount 80;
		BounceType "Doom";        // CH: Bouncetype doom
		BounceFactor 1;
		WallBounceFactor 1.5;
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		RED8 ABCCCCCCCCCCC 3 Bright;
		TNT1 A 0 ThrustThing(int(angle*256/(random(1,360))),35,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),35,0,0)
		RED8 CCCCCCCCCCCCCC 3 Bright;
		BBOM B 1 ThrustThingZ(0,9,0,1);
		TNT1 A 0 ThrustThing(int(angle*256/(random(1,360))),35,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),35,0,0)
		RED8 FGHHHHHHHHHHHHHH 3 Bright;
		TNT1 A 0 ThrustThing(int(angle*256/(random(1,360))),35,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),35,0,0)
		RED8 HHHHHHHHHHHHHHHHHHHHHHH 3 Bright;
		RED8 C 0 A_Jump(255,"Death13");
		Goto Death13;
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemyBaseSpawner2",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// CH: DECORATE.txt:945.  Hop 3 -- the "sneak". An invisible wandering monster
// that drifts away from the seed's landing point, hops twice, and then runs
// its Death13 payload. Every RS_Mon_*Sneak* below is this class with a
// different Death13.
// NOTE, CH's own: the A_SpawnItemEx calls in the base Death13 pass only 8
// arguments, so SXF_NOCHECKPOSITION (128) lands in the ANGLE slot and the
// flags slot gets 0. That is what CH ships; it is kept verbatim.
class RS_Mon_BonusEnemyBaseSpawner2 : Actor   // CH DECORATE.txt:945
{
	Default
	{
		Health 1;
		Monster;
		Radius 64;
		Height 42;
		+NOGRAVITY
		+SPAWNFLOAT
		+NOTRIGGER
		+NOTELEPORT
		+NEVERTARGET
		-ACTIVATEMCROSS
		-COUNTKILL
		+NOTONAUTOMAP
		+LOOKALLAROUND
		+INVISIBLE
		+THRUACTORS
		RenderStyle "Add";
		Speed 99;
		FloatSpeed 99;
		Scale 0.4;
		Alpha 0.95;
		Mass 2;
	}
	States
	{
	Spawn:
		BBOM AAA 2;
		TNT1 A 0 A_Stop();
		BBOM BBBBBB 1 Bright A_Wander();
		BBOM BBBBB 2 Bright A_Wander();
		BBOM B 1 ThrustThingZ(0,9,1,0);
		BBOM BBBBBB 1 Bright A_Wander();
		BBOM BBBBBB 2 Bright A_Wander();
		Goto See;
	See:
		BBOM BBBBBBBBBBBB 1 Bright A_Wander();
		BBOM B 1 ThrustThingZ(0,9,1,0);
		BBOM BBBB 2 Bright A_Wander();
		BBOM BBBBB 2 Bright A_Wander();
		Goto Missile2;
	Missile2:
		BBOM BB 1 Bright A_SetSpeed(45);
		BBOM B 1 ThrustThingZ(0,9,1,0);
		BBOM BBBB 1 Bright A_Wander();
		BBOM B 1 ThrustThingZ(0,9,1,1);
		BBOM B 4 Bright A_Wander();
		BBOM BB 1 Bright A_Wander();
		TNT1 A 0 A_CheckCeiling("Missile2");
		RED8 C 0 A_Jump(255,"Death13");
		Goto Death13;
	Death13:
		BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION);
		BBOM B 1 A_SpawnItemEx("RS_RandomizerArc",0,0,6,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	}
}


// ===========================================================================
// THE MONSTER-POOL TABLES  (hop 1 helpers -- what a pack is made of)
// ===========================================================================

// CH: DECORATE.txt:1123.  Mid-tier fodder pool.
class RS_Mon_PackofMedium : RandomSpawner   // CH DECORATE.txt:1123
{
	Default
	{
		DropItem "RS_CommonImp", 255, 630;
		DropItem "RS_GreenImp", 255, 360;
		DropItem "RS_BlueImp", 255, 180;
		DropItem "RS_PurpleImp", 255, 150;
		DropItem "RS_YellowImp", 255, 100;
		DropItem "RS_RedImp", 255, 55;
		DropItem "RS_CommonHK", 255, 200;
		DropItem "RS_GreenHK", 255, 100;
		DropItem "RS_BlueHK", 255, 60;
		DropItem "RS_PurpleHK", 255, 50;
	}
}

// CH: DECORATE.txt:1137.  The one heavy that leads a medium pack.
class RS_Mon_PackofMediumLeader : RandomSpawner   // CH DECORATE.txt:1137
{
	Default
	{
		DropItem "RS_YellowHK", 255, 30;
		DropItem "RS_CommonBaron", 255, 30;
		DropItem "RS_GreenBaron", 255, 20;
		DropItem "RS_PurpleBaron", 255, 6;
		DropItem "RS_FireBluBaron", 255, 2;
	}
}

// CH: DECORATE.txt:1384.  Hitscanner pool.
class RS_Mon_PackofHitScan : RandomSpawner   // CH DECORATE.txt:1384
{
	Default
	{
		DropItem "RS_CommonCGuy", 255, 630;
		DropItem "RS_GreenCGuy", 255, 560;
		DropItem "RS_BlueCGuy", 255, 380;
		DropItem "RS_CommonSG", 255, 550;
		DropItem "RS_BlueSG", 255, 300;
		DropItem "RS_RedCGuy", 255, 55;
		DropItem "RS_YellowZombie", 255, 300;
		DropItem "RS_BlueZombie", 255, 400;
		DropItem "RS_PurpleZombie", 255, 350;
		DropItem "RS_BlackSG2", 255, 25;
	}
}

// CH: DECORATE.txt:1490.  One tier-10 black boss, flat 1-in-9.
class RS_Mon_BossSurprise1 : RandomSpawner   // CH DECORATE.txt:1490
{
	Default
	{
		DropItem "RS_BlackCGuy", 255, 25;
		DropItem "RS_BlackRevenant", 255, 25;
		DropItem "RS_BlackArch", 255, 25;
		DropItem "RS_BlackHK", 255, 25;
		DropItem "RS_BlackBaron", 255, 25;
		DropItem "RS_BlackCaco", 255, 25;
		DropItem "RS_BlackZombie", 255, 25;
		DropItem "RS_BlackPE", 255, 25;
		DropItem "RS_BlackMind", 255, 25;
	}
}

// CH: DECORATE.txt:1515.  One ordinary monster. These are VANILLA class names
// on purpose -- our own coloursets replace them, exactly as CH's replace them
// in CH. "Zombie" is CH's own dangling typo (see header, item 2); kept.
class RS_Mon_EnemySinglePick : RandomSpawner   // CH DECORATE.txt:1515
{
	Default
	{
		DropItem "DoomImp", 255, 25;
		DropItem "Revenant", 255, 25;
		DropItem "Archvile", 255, 25;
		DropItem "HellKnight", 255, 25;
		DropItem "BaronOfHell", 255, 25;
		DropItem "CacoDemon", 255, 25;
		DropItem "Spectre", 255, 25;
		DropItem "ChaingunGuy", 255, 25;
		DropItem "Zombie", 255, 25;          // CH DECORATE.txt:1525 -- CH's typo, no such class in CH; NOT "corrected" to ZombieMan
		DropItem "PainElemental", 255, 25;
		DropItem "Fatso", 255, 25;
		DropItem "CyberDemon", 255, 1;
	}
}

// CH: DECORATE.txt:1674.  Lost-soul swarm pool.
class RS_MonSoulHive : RandomSpawner   // CH DECORATE.txt:1674
{
	Default
	{
		DropItem "RS_CommonLSoul", 255, 100;
		DropItem "RS_GreenLSoul", 255, 80;
		DropItem "RS_BlueLSoul", 255, 60;
		DropItem "RS_PurpleLSoul", 255, 40;
		DropItem "RS_YellowLSoul", 255, 20;
		DropItem "RS_RedLSoul", 255, 20;
	}
}

// CH: DECORATE.txt:1435, 1440, 1472, 1579, 1584, 1616, 1645.
// Single-entry RandomSpawner wrappers. CH uses these instead of naming the
// monster directly so the spawn goes through RandomSpawner's placement and
// SXF_SETTARGET handling. The 255/99 weights are CH's; with one entry the
// weight is irrelevant.
class RS_MonGrayLSoul2B : RandomSpawner   // CH DECORATE.txt:1435
{
	Default { DropItem "RS_GrayLSoul2", 255, 99; }
}

class RS_MonBlackLSoul2B : RandomSpawner   // CH DECORATE.txt:1440
{
	Default { DropItem "RS_BlackLSoul2", 255, 99; }
}

class RS_MonAbyssPE2B : RandomSpawner   // CH DECORATE.txt:1472
{
	Default { DropItem "RS_AbyssPE2", 255, 99; }
}

class RS_MonCommonArch2B : RandomSpawner   // CH DECORATE.txt:1579
{
	Default { DropItem "RS_CommonArch", 255, 99; }
}

class RS_MonCommonRevenant2B : RandomSpawner   // CH DECORATE.txt:1584
{
	Default { DropItem "RS_CommonRevenant", 255, 99; }
}

class RS_MonRevenantGraySquad : RandomSpawner   // CH DECORATE.txt:1616
{
	Default { DropItem "RS_GrayRevenant2", 255, 99; }
}

class RS_MonTentacleTime : RandomSpawner   // CH DECORATE.txt:1645
{
	Default { DropItem "RS_RoseTentacle", 255, 99; }
}

// CH: DECORATE.txt:1324.  The boon loot table -- vanilla pickups, verbatim.
class RS_Mon_RandomBoon : RandomSpawner   // CH DECORATE.txt:1324
{
	Default
	{
		DropItem "Stimpack", 255, 20;
		DropItem "ClipBox", 255, 13;
		DropItem "RocketAmmo", 255, 9;
		DropItem "RocketBox", 255, 9;
		DropItem "Medikit", 255, 9;
		DropItem "BlurSphere", 255, 3;
		DropItem "BackPack", 255, 8;
		DropItem "CellPack", 255, 8;
		DropItem "Cell", 255, 11;
		DropItem "GreenArmor", 255, 6;
		DropItem "BlueArmor", 255, 2;
		DropItem "PlasmaRifle", 255, 1;
		DropItem "SuperShotgun", 255, 2;
		DropItem "Berserk", 255, 4;
		DropItem "ChainSaw", 255, 4;
	}
}


// ===========================================================================
// THE THREE ENTRY POINTS  (hop 1 -- spawn one of these to fire an event)
// ===========================================================================

// CH: DECORATE.txt:1146.  The full table. Weights sum to 169; a boon is 33/169
// (~20%), a single ordinary monster 67/169 (~40%), and the remaining ~40% is
// spread over the nine ambush packs and four misc events.
class RS_Mon_RandomEvent : RandomSpawner   // CH DECORATE.txt:1146
{
	Default
	{
		DropItem "RS_Mon_BonusBoon", 255, 33;
		DropItem "RS_Mon_BonusEnemySingle", 255, 67;
		DropItem "RS_Mon_BonusMisc1", 255, 3;
		DropItem "RS_Mon_BonusMisc2", 255, 3;
		DropItem "RS_Mon_BonusMisc3", 255, 3;
		DropItem "RS_Mon_BonusMisc4", 255, 3;
		DropItem "RS_Mon_BonusEnemy1", 255, 7;
		DropItem "RS_Mon_BonusEnemy2", 255, 7;
		DropItem "RS_Mon_BonusEnemy3", 255, 3;
		DropItem "RS_Mon_BonusEnemy4", 255, 7;
		DropItem "RS_Mon_BonusEnemy5", 255, 5;
		DropItem "RS_Mon_BonusEnemy6", 255, 7;
		DropItem "RS_Mon_BonusEnemy7", 255, 7;
		DropItem "RS_Mon_BonusEnemy8", 255, 7;
		DropItem "RS_Mon_BonusEnemy9", 255, 7;
	}
}

// CH: DECORATE.txt:1165.  Good outcomes only. Weights sum to 41; a plain boon
// is 33/41 (~80%) and the four misc events split the rest.
class RS_Mon_RandomEventGood : RandomSpawner   // CH DECORATE.txt:1165
{
	Default
	{
		DropItem "RS_Mon_BonusBoon", 255, 33;
		DropItem "RS_Mon_BonusMisc1", 255, 2;
		DropItem "RS_Mon_BonusMisc2", 255, 2;
		DropItem "RS_Mon_BonusMisc3", 255, 2;
		DropItem "RS_Mon_BonusMisc4", 255, 2;
	}
}

// CH: DECORATE.txt:1174.  Bad outcomes only. Weights sum to 145; a single
// ordinary monster is 67/145 (~46%), the nine ambush packs split the rest.
class RS_Mon_RandomEventBad : RandomSpawner   // CH DECORATE.txt:1174
{
	Default
	{
		DropItem "RS_Mon_BonusEnemySingle", 255, 67;
		DropItem "RS_Mon_BonusEnemy1", 255, 10;
		DropItem "RS_Mon_BonusEnemy2", 255, 10;
		DropItem "RS_Mon_BonusEnemy3", 255, 3;
		DropItem "RS_Mon_BonusEnemy4", 255, 10;
		DropItem "RS_Mon_BonusEnemy5", 255, 5;
		DropItem "RS_Mon_BonusEnemy6", 255, 10;
		DropItem "RS_Mon_BonusEnemy7", 255, 10;
		DropItem "RS_Mon_BonusEnemy8", 255, 10;
		DropItem "RS_Mon_BonusEnemy9", 255, 10;
	}
}


// ===========================================================================
// THE MISC EVENTS  (seed / sneak pairs)
// ===========================================================================

// MISC 1 -- a cloud of 60 CH_cirno gibs. CH's joke event.
class RS_Mon_BonusMisc1 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1188
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMiscSneak1",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusMiscSneak1 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1200
{
	States
	{
	Death13:
		TNT1 A 0 A_Stop();
		BBOM B 1 ThrustThingZ(0,35,0,0);
		TNT1 A 10;
		// CH DECORATE.txt:1208, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 3 A_SpawnItemEx("RS_CH_Cirno",0,0,-8,random(2,14),0,random(-15,0),random(0,360),SXF_NOCHECKPOSITION);
		BBOM BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 3 A_SpawnItemEx("RS_CH_Cirno",0,0,-8,random(2,14),0,random(-15,0),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// MISC 2 -- a shotgun rain: 6 SGBursts then 78 Shotgun pickups.
class RS_Mon_BonusMisc2 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1216
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMiscSneak2",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusMiscSneak2 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1228
{
	States
	{
	Death13:
		TNT1 A 0 A_Stop();
		TNT1 A 10;
		// CH DECORATE.txt:1235, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBBBBB 3 A_SpawnItemEx("RS_SGBurst",0,0,0,random(2,14),0,random(-15,33),random(0,360),SXF_NOCHECKPOSITION);
		BBOM BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 1 A_SpawnItemEx("Shotgun",0,0,0,random(8,24),0,random(-15,33),random(0,360),SXF_NOCHECKPOSITION);
		BBOM BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 1 A_SpawnItemEx("Shotgun",0,0,0,random(8,24),0,random(-15,33),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// MISC 3 -- one soulsphere, launched straight up first.
class RS_Mon_BonusMisc3 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1244
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMiscSneak3",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusMiscSneak3 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1256
{
	States
	{
	Death13:
		TNT1 A 0 A_Stop();
		BBOM B 1 ThrustThingZ(0,99,1,0);
		TNT1 A 20;
		// CH DECORATE.txt:1264, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 3 A_SpawnItemEx("SoulSphere",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// MISC 4 -- a fountain of health bonuses (8 x 9 = 72 of them).
class RS_Mon_BonusMisc4 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1271
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMiscSneak4",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusMiscSneak4 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1283
{
	States
	{
	Death13:
		TNT1 A 0 A_Stop();
		BBOM B 1 ThrustThingZ(0,99,1,0);
		TNT1 A 20;
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBBBBB 0 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		BBOM BBB 1 A_SpawnItemEx("HealthBonus",0,0,6,random(2,12),0,random(1,12),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	}
}


// ===========================================================================
// THE BOON  (seed / sneak pair -> one roll on RS_Mon_RandomBoon)
// ===========================================================================

class RS_Mon_BonusBoon : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1312
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusBoonSneak",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusBoonSneak : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1343
{
	States
	{
	Death13:
		TNT1 A 0 A_Stop();
		BBOM B 1 ThrustThingZ(0,99,1,0);
		TNT1 A 20;
		// CH DECORATE.txt:1351, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 3 A_SpawnItemEx("RS_Mon_RandomBoon",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	}
}


// ===========================================================================
// THE NINE AMBUSH PACKS  (seed / sneak pairs)
// ===========================================================================

// PACK 1 -- 6 mediums + 1 leader.
class RS_Mon_BonusEnemy1 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1358
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak1",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak1 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1370
{
	States
	{
	Death13:
		// CH DECORATE.txt:1375, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBB 5 A_SpawnItemEx("RS_Mon_PackofMedium",8,12,6,random(7,14),0,random(5,12),random(0,120),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM BBB 5 A_SpawnItemEx("RS_Mon_PackofMedium",0,-12,6,random(7,14),0,random(5,12),random(120,240),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 3 A_SpawnItemEx("RS_Mon_PackofMediumLeader",-8,0,6,random(1,5),0,random(1,5),random(240,360),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 2 -- 8 hitscanners.
class RS_Mon_BonusEnemy2 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1398
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak2",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak2 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1410
{
	States
	{
	Death13:
		// CH DECORATE.txt:1415, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBBB 5 A_SpawnItemEx("RS_Mon_PackofHitScan",6,6,6,random(7,14),0,random(5,12),random(0,120),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM BBBB 5 A_SpawnItemEx("RS_Mon_PackofHitScan",-6,-6,6,random(7,14),0,random(5,12),random(120,240),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 3 -- the lost-soul storm: 3 gray + 63 black lost souls. The rarest
// ambush on the table (weight 3).
class RS_Mon_BonusEnemy3 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1423
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak3",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak3 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1445
{
	States
	{
	Death13:
		// CH DECORATE.txt:1450, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 3 A_SpawnItemEx("RS_MonGrayLSoul2B",0,-12,6,0,0,random(5,12),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 3 A_SpawnItemEx("RS_MonGrayLSoul2B",12,6,6,0,0,random(5,12),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 3 A_SpawnItemEx("RS_MonGrayLSoul2B",-12,0,6,0,0,random(5,12),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 5 A_SpawnItemEx("RS_MonBlackLSoul2B",randompick(-8,0,8,-16,16),randompick(-8,0,8,-16,16),0,random(7,14),0,random(5,12),random(0,360),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 4 -- two abyss pain elementals.
class RS_Mon_BonusEnemy4 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1460
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak4",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak4 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1477
{
	States
	{
	Death13:
		// CH DECORATE.txt:1482, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 5 A_SpawnItemEx("RS_MonAbyssPE2B",8,12,6,random(7,14),0,random(5,12),random(0,180),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 5 A_SpawnItemEx("RS_MonAbyssPE2B",-8,-12,6,random(7,14),0,random(5,12),random(180,359),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 5 -- one tier-10 black boss.
class RS_Mon_BonusEnemy5 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1543
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak5",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak5 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1555
{
	States
	{
	Death13:
		// CH DECORATE.txt:1560, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 5 A_SpawnItemEx("RS_Mon_BossSurprise1",0,0,6,random(7,14),0,random(5,12),random(0,359),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 6 -- 3 archviles behind 32 revenants.
class RS_Mon_BonusEnemy6 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1567
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak6",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak6 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1589
{
	States
	{
	Death13:
		// CH DECORATE.txt:1594, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 3 A_SpawnItemEx("RS_MonCommonArch2B",0,-12,6,0,0,random(5,12),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 3 A_SpawnItemEx("RS_MonCommonArch2B",12,6,6,0,0,random(5,12),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 3 A_SpawnItemEx("RS_MonCommonArch2B",-12,0,6,0,0,random(5,12),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 5 A_SpawnItemEx("RS_MonCommonRevenant2B",8,12,6,random(7,14),0,random(5,12),random(0,360),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 7 -- 7 gray revenants.
class RS_Mon_BonusEnemy7 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1604
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak7",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak7 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1621
{
	States
	{
	Death13:
		// CH DECORATE.txt:1626, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBBBBBB 5 A_SpawnItemEx("RS_MonRevenantGraySquad",0,0,6,random(7,14),0,random(5,12),random(0,359),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 8 -- 10 rose tentacles.
class RS_Mon_BonusEnemy8 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1633
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak8",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak8 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1650
{
	States
	{
	Death13:
		// CH DECORATE.txt:1655, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBBBBBBBBB 5 A_SpawnItemEx("RS_MonTentacleTime",0,0,6,random(7,14),0,random(5,12),random(0,359),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// PACK 9 -- 11 lost souls from the hive, plus a soulsphere as an apology.
class RS_Mon_BonusEnemy9 : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1662
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneak9",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneak9 : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1684
{
	States
	{
	Death13:
		// CH DECORATE.txt:1689, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM BBBBBBBBBBB 5 A_SpawnItemEx("RS_MonSoulHive",0,0,6,random(7,14),0,random(5,12),random(0,359),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		BBOM B 5 A_SpawnItemEx("SoulSphere",0,0,6,0,0,random(-9,-1),0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}


// ===========================================================================
// THE SINGLE  (seed / sneak pair -> one ordinary monster)
// ===========================================================================
// NOTE, CH's own naming: the seed is CH_BonusEnemySingle but its sneak is
// called CH_BonusEnemySneakSG, not ...Single. Kept as CH named it.

class RS_Mon_BonusEnemySingle : RS_Mon_BonusEnemyBaseSpawner   // CH DECORATE.txt:1503
{
	States
	{
	Death13:
		RED8 ABCD 4 Bright A_Stop();
		RED8 CDE 1;
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySneakSG",-16,0,0,random(8,10),0,random(-25,5),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Mon_BonusEnemySneakSG : RS_Mon_BonusEnemyBaseSpawner2   // CH DECORATE.txt:1531
{
	States
	{
	Death13:
		// CH DECORATE.txt:1536, commented out in CH itself:
		// BBOM B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION)
		BBOM B 5 A_SpawnItemEx("RS_Mon_EnemySinglePick",0,0,6,random(7,14),0,random(5,12),random(0,359),SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}
