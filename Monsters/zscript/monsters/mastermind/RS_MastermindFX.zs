// ============================================================================
// RS_MastermindFX.zs -- Spider Mastermind family: support actors, projectiles,
// pickups-with-behaviour, and the native rebuilds of this family's two live
// gameplay ACS scripts. 2026-08-06.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\MASTERMINDS.txt
// (5,274 lines, read whole; 108 actors). Externals chased to their defining
// CH file:line. Monster bodies live in RS_Mastermind.zs.
//
// SEVENTEENTH AND LAST CH FAMILY. Everything MASTERMINDS.txt reaches for that
// lives in another CH file was already shipped by an earlier lane -- this file
// defines NO third-file externals. The read-only set, with the CH file:line
// each was imported from:
//   RS_ZombieRock (Zombies.txt:613 -> zombieman), RS_ReflectorBBaron
//   (Barons.txt:290 -> baron FX), RS_Drt1 (Barons.txt:4381 -> shotgunner FX),
//   RS_Drt2 + RS_Drt3 (Barons.txt:4406/4431 -> zombieman FX),
//   RS_CH_BoneGib (revenant FX), RS_MediCacoBrown (Cacodemons.txt:147 ->
//   spectre FX), RS_CH_Cirno (shotgunner FX), RS_BaronCyanBombTrail
//   (Barons.txt:698 -> lostsoul FX), RS_SpiderCyanBomb (Spiders.txt:387 ->
//   spider FX), RS_IceFattTrail (Fatsos.txt:501 -> fatso FX),
//   RS_AbyssCybieDecoFlame (CYBIES.txt:1441 -- see EXPECTED FROM CYBIES),
//   RS_Zap99 (Revenants.txt:2080 -> revenant FX), RS_SplashAbyss
//   (Imps.txt:636 -> zombieman FX), RS_Zap88 (Barons.txt:2774 -> cacodemon
//   FX), RS_AbyssShotIdentifier (Revenants.txt:216 -> zombieman FX),
//   RS_WVileSpot (Archviles.txt:4876 -- see EXPECTED FROM ARCHVILES),
//   RS_BlueSP1 (Spiders.txt -> spider), RS_GrayCGuff (Chaingunners.txt:741 ->
//   chaingunner FX), RS_MolochNail (CYBIES.txt:3957 -> cacodemon FX),
//   RS_HomingRocketTrailFatso (Fatsos.txt:2200 -> lostsoul FX),
//   RS_Gas14 (CYBIES.txt:2325 -> shotgunner FX), RS_SparkPuff1
//   (Archviles.txt:3044 -> shotgunner FX), RS_FireBCGguy (Chaingunners.txt:962
//   -> chaingunner FX), RS_YellowSP1 (Spiders.txt:2015 -> spider),
//   RS_PlasmaBallSP3 (Spiders.txt:1885 -> zombieman FX), RS_AracnorbBall
//   (Spiders.txt:2268 -> spider FX), RS_RedThingsLS (lostsouls.txt:1217 ->
//   demon FX), RS_RedMessImp (Imps.txt:1831 -> shotgunner FX),
//   RS_GroundRedCyb (CYBIES.txt:3636 -> chaingunner FX), RS_HKRedDeath
//   (Hellknights.txt:2230 -> zombieman FX), RS_DflarePE2 (thepains.txt:2947 ->
//   painelemental FX), RS_DeathBreathDI (Imps.txt:2535 -> imp FX),
//   RS_RandomizerArc (Archviles.txt:3387 -> lostsoul FX), and the summon pool
//   RS_CommonRevenant / RS_PurpleRevenant / RS_RedRevenant (revenant),
//   RS_RedLSoul (lostsoul), RS_DeepTentacle + RS_RoseTentacle (baron),
//   RS_RedSpectre (spectre), RS_RedDemon (demon), RS_RedCaco (cacodemon).
// Plus the ordinary shared set: RS_Zom, RS_ZomTierToken,
// RS_ColorTierIconCH..CH13, RS_HealthBundle, RS_ArmorBundle,
// RS_BackPackBundle, RS_CH_BlueArmor, RS_CH_GreenArmor, RS_CH_MegaSphere,
// RS_CH_SoulSphere, RS_CH_Berserk, RS_CH_CellPack, RS_CH_Cell, RS_CH_Shell,
// RS_CH_ClipBox, RS_CH_RocketBox, RS_CH_RocketAmmo, RS_CH_RocketLauncher,
// RS_CH_PlasmaRifle, RS_CH_BFG9000, RS_CH_Medikit, RS_implyingclip.
//
// FROM THE TWO SIBLING LANES (CH file order: Archviles < CYBIES < MASTERMINDS,
// so both own their names; both have landed and both now resolve):
//   RS_WvileSpot -- CH Archviles.txt:4877, in
//                   zscript/monsters/archvile/RS_ArchvileFX.zs:2720.
//                   Referenced once, RS_AbyssMind2 Pain (MASTERMINDS.txt:1323).
//   RS_AbyssCybieDecoFlame -- CH CYBIES.txt:1442, in
//                   zscript/monsters/cyberdemon/RS_CyberdemonFX.zs:948.
//                   Referenced twice, RS_AbyssMindWalk1 (:1639, :1650).
// The other CYBIES/Archviles names MASTERMINDS.txt uses -- RS_Gas14,
// RS_GroundRedCyb, RS_MolochNail, RS_SparkPuff1, RS_RandomizerArc -- shipped
// with earlier families and already resolved before those two lanes landed.
//
// ALREADY OWNED, DELIBERATELY NOT REDEFINED (MASTERMINDS.txt is their CH
// source, but an earlier lane imported them because its own file referenced
// them first; correct-in-place, so they stay put):
//   RS_SpRocket4  -- MASTERMINDS.txt:2014, byte-identical to Spiders.txt's
//                    copy; lives in zscript/monsters/spider/RS_SpiderFX.zs
//   RS_FrostLong  -- MASTERMINDS.txt:2610 -> zscript/monsters/imp/RS_ImpFX.zs
//   RS_FrostLong2 -- MASTERMINDS.txt:2640 -> zscript/monsters/imp/RS_ImpFX.zs
//   RS_TrailSP2   -- MASTERMINDS.txt:3284 ->
//                    zscript/monsters/zombieman/RS_ZombiemanFX.zs
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite AMIN frames K, L, M (RS_AbyssMind2 See/See2/See3, MASTERMINDS.txt
//     :1228, :1242, :1256 -- "AMIN KLMLK 1 a_chase"). CH ships AMINA*-AMINI*
//     only (45 lumps, frames A-I); no AMIN K/L/M lump exists anywhere in the
//     CH tree. Almost certainly a one-character slip for ANIM, which does have
//     J-Y. Invisible in CH too; kept verbatim.
//   * Sprite ARNQ frame P (RS_Blackmind2 RapidFire, MASTERMINDS.txt:4018 --
//     "ARNQ P 0 A_FaceTarget"). CH ships ARNQA*-ARNQM* only (frames A-M). The
//     state is 0 tics, so it never renders in CH either. Kept verbatim.
//   * DropItem "SchoolGirlTG" (RS_Blackmind2, MASTERMINDS.txt:3884): defined
//     NOWHERE in the CH tree -- dropped here and at Barons.txt:3940, declared
//     never. Itemised at its site exactly as the baron lane did.
//   * DropItem "VoidOrb" (RS_Blackmind2 :3883, RS_WhiteMind2 :4979): defined
//     NOWHERE in the CH tree. Itemised at both sites.
//   * DropItem "FinallyFullyCovered" (RS_CyanMind2, MASTERMINDS.txt:850):
//     defined NOWHERE in the CH tree. Itemised at its site.
//   (Absence proof for all three: case-insensitive grep for the name across
//   the whole CH folder returns only the DropItem lines that reference it.)
//
// PICKUP CLASS THAT EXISTS IN CH BUT HAS NOT BEEN IMPORTED HERE YET:
//   * DropItem "CH_Blursphere" (RS_Blackmind2 :3888, RS_WhiteMind2 :4983) --
//     CH DECORATE.txt:663 "Actor CH_BlurSphere : DropBaseItem". No RS_ class
//     for it exists in this tree. Itemised with its CH line at both sites,
//     not silently gutted and not substituted.
//
// Standing strips, each preserved at its site as a "// CH:" comment: the ACS
// announcers (AnnounceSpidie1-4, Announcers.acs:221/229/93/21); the
// CHRandom_GibGenerator/NashGore gore chain (owner accepts vanilla gore --
// XDeath ANIMATIONS stay); the DRLA RL*/RareArmorPool cross-mod drops
// (RLDeathsGazePickup, RareArmorPool, RLDemonicWeaponSpawner,
// RLLegendaryWeaponSpawner, RLUniqueWeaponSpawner, RLMinigunpickup,
// RLNuclearArmorPickup); and the LegenDoom gates (none in this file).
//
// THE TWO GAMEPLAY ACS SCRIPTS ARE **NOT** STRIPPED. Both have live bodies
// that really run in CH, so both are rebuilt native below:
//   "BrownMindCommand" -- CHSett.acs:148, reached from RS_ShieldUpMind.
//     Guard is `if (CheckFlag(0,"BOSS")) Terminate;` and the local `int Nope`
//     is an uninitialised ACS local (always 0), so the body DOES execute for
//     every non-boss monster the shield lands on. See RS_BrownMindShieldBuff.
//   "BrownDinner" -- CHSett.acs:182, reached from RS_BrownWarriorsStrifeFor.
//     No guard at all; body always runs. See RS_BrownDinnerLift.
// ============================================================================


// ---------------------------------------------------------------------------
// BROWN -- the "Death N Decay Master". CH MASTERMINDS.txt:285-750.
// ---------------------------------------------------------------------------

class RS_RedMessMindB : Actor   // CH MASTERMINDS.txt:285
{
	Default
	{
		Radius 6;
		Height 8;
		Mass 5;
		Speed 11;
		Projectile;
		+SEEKERMISSILE
		+NOCLIP
		Scale 0.45;
		Translation "208:223=176:191", "224:231=176:176";
		WeaveIndexXY 16;
		WeaveIndexZ 16;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		BAL1 A 1 A_BishopMissileWeave();
		BAL1 B 1 A_SpawnItemEx("RS_RedMessMindB2",0,0,0,6);
		Goto Death;
	Death:
		BAL1 ABAB 1 A_SetTranslucent(0.35);
		Stop;
	}
}

class RS_RedMessMindB2 : Actor   // CH MASTERMINDS.txt:326
{
	Default
	{
		Radius 6;
		Height 8;
		Mass 5;
		Speed 11;
		Projectile;
		+NOCLIP
		Scale 0.45;
		Translation "208:223=176:191", "224:231=176:176";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 ABAB 1;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BrownOrbMind : Actor   // CH MASTERMINDS.txt:349
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 38;
		ProjectileKickback 333;
		Mass 100;
		DamageFunction (random(3,33));
		Projectile;
		DamageType "Fire";
		+MTHRUSPECIES
		+THRUGHOST
		SeeSound "fire/fire3";
		DeathSound "weapons/boom1";
		Translation "0:255=@74[77,52,26]";
		Scale 0.33;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 AB 4 Bright A_SpawnItemEx("RS_BrownOrbMindTrail",0,0,0);
		Loop;
	Death:
		RIP1 D 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_SetTranslation("BBEASTEX5");
		RIP1 DE 3 Bright A_Explode(random(2,8),64);
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownOrbMind2",0,0,0,random(1,12),0,random(0,12),random(0,120));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownOrbMind2",0,0,0,random(1,12),0,random(0,12),random(120,240));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownOrbMind2",0,0,0,random(1,12),0,random(0,12),random(240,360));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownOrbMind2",0,0,0,random(1,12),0,random(-12,0),random(0,120));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownOrbMind2",0,0,0,random(1,12),0,random(-12,0),random(120,240));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownOrbMind2",0,0,0,random(1,12),0,random(-12,0),random(240,360));
		RIP1 FGH 3 Bright A_Explode(random(2,8),64);
		Stop;
	}
}

class RS_BrownOrbMindTrail : Actor   // CH MASTERMINDS.txt:387
{
	Default
	{
		Radius 2;
		Height 2;
		Projectile;
		+NOCLIP
		Translation "0:255=@74[77,52,26]";
		Scale 0.15;
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Goto Death;
	Death:
		RIP1 D 0 A_SetScale(0.33,0.33);
		TNT1 A 0 A_SetTranslation("BBEASTEX5");
		RIP1 DEFGH 1 Bright;
		Stop;
	}
}

class RS_BrownOrbMind2 : Actor   // CH MASTERMINDS.txt:408
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 38;
		DamageFunction (random(1,2));
		Projectile;
		DamageType "Fire";
		+MTHRUSPECIES
		+THRUGHOST
		DeathSound "weapons/boom1";
		Translation "0:255=@74[77,52,26]";
		Scale 0.10;
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Goto Death;
	Death:
		RIP1 D 0 A_SetScale(0.5,0.5);
		TNT1 A 0 A_SetTranslation("BBEASTEX5");
		RIP1 DEFGH 3 Bright A_Explode(random(1,2),16);
		Stop;
	}
}

class RS_WindBlastMasterMind : Actor   // CH MASTERMINDS.txt:434
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 15;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.25;
		SeeSound "PUSHBMIN";
		DeathSound "";
		Scale 1.5;
		Translation "0:255=%[0.54,0.59,0.36]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 4 Bright;
		BAL1 B 4 Bright A_SetScale(2.0,2.0);
		TNT1 A 0 A_SpawnItemEx("RS_ReflectorBBaron",-16,0,0);
		BAL1 A 4 Bright A_SetScale(2.5,2.5);
		BAL1 B 4 Bright A_SetScale(3.0,3.0);
		BAL1 A 4 Bright A_SetScale(3.5,3.5);
		TNT1 A 0 A_SpawnItemEx("RS_ReflectorBBaron",-16,0,0);
		TNT1 A 0 A_Stop();
		BAL1 B 4 Bright A_SetScale(4.0,4.0);
		TNT1 A 0 A_Explode(random(10,32),64,0);
		BAL1 B 4 Bright A_SetScale(5.0,5.0);
		TNT1 A 0 A_Explode(random(10,32),82,0);
		BAL1 B 4 Bright A_SetScale(6.0,6.0);
		TNT1 A 0 A_SpawnItemEx("RS_ReflectorBBaron",-16,0,0);
		TNT1 A 0 A_Explode(random(10,32),102,0);
		BAL1 B 4 Bright A_SetScale(7.0,7.0);
		TNT1 A 0 A_Explode(random(20,80),128,0);
		Goto Death;
	Death:
		BAL1 AB 3 Bright A_FadeOut(0.05);
		Stop;
	}
}

class RS_WindBlastMasterMind2 : Actor   // CH MASTERMINDS.txt:477
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 10;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.25;
		SeeSound "";
		DeathSound "";
		Scale 1.5;
		Translation "0:255=%[0.54,0.59,0.36]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BBOM B 2 Bright;
		BBOM B 2 Bright A_SetScale(2.0,2.0);
		BBOM B 2 Bright A_SetScale(2.5,2.5);
		BBOM B 2 Bright A_SetScale(3.0,3.0);
		BBOM B 2 Bright A_SetScale(3.5,3.5);
		BBOM B 2 Bright A_SetScale(4.0,4.0);
		BBOM B 2 Bright A_SetScale(3.0,3.0);
		BBOM B 2 Bright A_SetScale(2.0,2.0);
		BBOM B 2 Bright A_SetScale(1.0,1.0);
		Goto Death;
	Death:
		BBOM BB 3 Bright A_FadeOut(0.05);
		Stop;
	}
}

class RS_WindBlastMasterMind3 : Actor   // CH MASTERMINDS.txt:512
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 20;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.20;
		SeeSound "";
		DeathSound "";
		Scale 1.5;
		Translation "0:255=%[0.54,0.59,0.36]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BBOM B 2 Bright;
		BBOM B 1 Bright A_SetScale(1.0,1.0);
		BBOM B 2 Bright A_SetScale(1.5,1.5);
		BBOM B 1 Bright A_SetScale(2.0,2.0);
		BBOM B 2 Bright A_SetScale(1.5,1.5);
		BBOM B 1 Bright A_SetScale(1.0,1.0);
		BBOM B 2 Bright A_SetScale(1.5,1.5);
		BBOM B 1 Bright A_SetScale(1.0,1.0);
		BBOM B 2 Bright A_SetScale(0.5,0.5);
		Goto Death;
	Death:
		BBOM BB 3 Bright A_FadeOut(0.05);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The two live gameplay ACS scripts, rebuilt native.
//
// A CustomInventory's Pickup/Use chain is run by CallStateChain, which
// executes every action in the chain in a single call and ignores the tic
// durations -- so CH's timing (delay 1 / delay 300 / delay 30) cannot live in
// a state chain here. Each script becomes a tiny Inventory the pickup hands
// to its owner, which counts the same tics in Tick().
// ---------------------------------------------------------------------------

// CH CHSett.acs:148 "BrownMindCommand". Activator is the monster that picked
// the shield up (A_RadiusGive ... RGF_MONSTERS at MASTERMINDS.txt:257).
class RS_BrownMindShieldBuff : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	int rs_shieldtimer;
	double rs_savedfactor;

	override void AttachToOwner(Actor other)
	{
		Super.AttachToOwner(other);
		if (!Owner) { Destroy(); return; }
		// CH: if (CheckFlag(0,"BOSS")) { Terminate; }
		if (Owner.bBOSS) { Destroy(); return; }
		// CH: int Normal = GetActorProperty(0,APROP_DamageFactor);
		rs_savedfactor = Owner.DamageFactor;
		// CH: if (checkflag(0,"ALWAYSFAST")){} else { setActorflag(0,"ALWAYSFAST",TRUE); }
		Owner.bALWAYSFAST = true;
		// CH: SetActorProperty(0,APROP_DamageFactor,0.50);
		Owner.DamageFactor = 0.50;
		// CH: ThrustThing(random(0,255),random(1,12),0,0);
		Owner.Thrust(random(1,12), random(0,255) * (360.0 / 256.0));
		// CH: ThrustThingZ(0,random(1,12),random(0,1),0);  -- ACS force is /4
		Owner.Vel.Z = random(1,12) * 0.25;
		// CH: four delay(1)s then delay(300).
		rs_shieldtimer = 304;
	}

	override void Tick()
	{
		Super.Tick();
		if (!Owner) { Destroy(); return; }
		if (--rs_shieldtimer > 0) return;
		// CH: SetActorProperty(0,APROP_DamageFactor,normal);
		Owner.DamageFactor = rs_savedfactor;
		// CH: if (checkflag(0,"ALWAYSFAST")){setActorflag(0,"ALWAYSFAST",FALSE);}
		if (Owner.bALWAYSFAST) Owner.bALWAYSFAST = false;
		Destroy();
	}
}

// CH CHSett.acs:182 "BrownDinner". Activator is RS_BrownMind2's target, which
// gets the item at MASTERMINDS.txt:238 (A_GiveInventory ... AAPTR_TARGET).
class RS_BrownDinnerLift : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	int rs_lifttimer;

	override void Tick()
	{
		Super.Tick();
		if (!Owner) { Destroy(); return; }
		rs_lifttimer++;
		if (rs_lifttimer == 1)        Owner.bFLOAT = true;      // CH: delay(1); setActorflag(0,"FLOAT",TRUE);
		else if (rs_lifttimer == 3)   Owner.Vel.Z += 30 * 0.25; // CH: delay(2); ThrustThingZ(0,30,0,1);
		else if (rs_lifttimer >= 33) { Owner.bFLOAT = false; Destroy(); }   // CH: delay(30); ...FALSE
	}
}

class RS_ShieldUpMind : CustomInventory   // CH MASTERMINDS.txt:547
{
	Default
	{
		Radius 20;
		Height 16;
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
	}
	States
	{
	Pickup:
	Use:
		TNT1 A 0;
		// CH: ACS_NamedExecuteAlways("BrownMindCommand") -- CHSett.acs:148,
		// rebuilt native as RS_BrownMindShieldBuff (the script has a live body).
		TNT1 A 0 A_GiveInventory("RS_BrownMindShieldBuff",1);
		TNT1 AAAA 15 A_SpawnItemEx("RS_BrownMindBone1",0,0,0,0,0,0,0,SXF_SETMASTER);
		Stop;
	}
}

class RS_BrownWarriorsStrifeFor : CustomInventory   // CH MASTERMINDS.txt:564
{
	Default
	{
		Radius 20;
		Height 16;
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
	}
	States
	{
	Pickup:
	Use:
		TNT1 A 0;
		// CH: ACS_NamedExecuteAlways("BrownDinner") -- CHSett.acs:182, rebuilt
		// native as RS_BrownDinnerLift (the script has a live body, no guard).
		TNT1 A 0 A_GiveInventory("RS_BrownDinnerLift",1);
		Stop;
	}
}

class RS_EatableMind : Inventory { Default { Inventory.MaxAmount 1; } }   // CH MASTERMINDS.txt:580

class RS_BrownMindBone1 : Actor   // CH MASTERMINDS.txt:582
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 32;
		DamageType "Dimp";
		Projectile;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		+NOPAIN
		Scale 1.5;
	}

	int user_angle;
	int user_pitch;    // CH declares it (MASTERMINDS.txt:595) and never reads it
	int user_timer;

	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		BBBN A 1 Bright A_Explode(random(1,8),8,0);
		BBBN B 1 A_Warp(AAPTR_MASTER,128,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		BBBN C 1 { user_angle = user_angle - 32; }   // CH: A_SetUserVar("user_angle",user_angle - 32)
		BBBN D 1 { user_timer = user_timer + 1; }    // CH: A_SetUserVar("user_Timer",user_Timer + 1)
		TNT1 A 0 A_JumpIf(user_timer >= 150,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BrownMindBone2 : Actor   // CH MASTERMINDS.txt:615
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 20;
		ProjectileKickback 500;
		Mass 100;
		DamageFunction (random(20,40));
		Projectile;
		DamageType "Melee";
		+MTHRUSPECIES
		+THRUGHOST
		+SEEKERMISSILE
		SeeSound "";
		DeathSound "MEATIMPB";
		Scale 2.25;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(128,"A1");
	A2:
		BBBN ABCD 1 Bright A_SeekerMissile(4,4);
		Loop;
	A1:
		BBBN DCBA 1 Bright A_SeekerMissile(4,4);
		Loop;
	Death:
		TNT1 AAAAAAAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		Stop;
	}
}

class RS_MindGroundSpikeBrown : Actor   // CH MASTERMINDS.txt:649
{
	Default
	{
		Speed 1;
		Radius 24;
		Height 8;
		DamageFunction (random(10,25));
		DamageType "Melee";
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		B0N8 A 3 Radius_Quake(15,15,0,40,0);
		B0N8 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 A 1 A_SpawnItemEx("RS_Drt3",-32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 A 1 A_SpawnItemEx("RS_Drt1",0,-32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 B 1 A_SpawnItemEx("RS_Drt2",-32,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 B 1 A_SpawnItemEx("RS_Drt3",-32,-32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 B 1 A_SpawnItemEx("RS_Drt1",32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 B 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 B 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 C 1 A_SpawnItemEx("RS_Drt1",32,-32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 C 1 A_SpawnItemEx("RS_Drt2",32,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 C 2 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 C 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 C 1 A_SpawnItemEx("RS_Drt3",-32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 D 1 A_SpawnItemEx("RS_Drt1",0,-32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 D 1 A_SpawnItemEx("RS_Drt2",-32,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 D 1 A_SpawnItemEx("RS_Drt3",-32,-32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 D 1 A_SpawnItemEx("RS_Drt1",32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 D 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 E 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 E 1 A_SpawnItemEx("RS_Drt1",32,-32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 E 1 A_SpawnItemEx("RS_Drt2",32,32,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 E 2 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		B0N8 F 10 { bTHRUACTORS = false; }   // CH: a_changeflag("thruactors",FALSE)
		TNT1 A 0 A_PlaySound("ROCKHIT1",0);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,0);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,90);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,180);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,270);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,45);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,135);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,225);
		TNT1 A 0 A_SpawnItemEx("RS_BrownMindStoneThrow",0,0,2,12,0,1,315);
		TNT1 AAAAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		B0N8 F 3;
		TNT1 A 0 A_Explode(random(60,100),32,0);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		B0N8 F 3;
		TNT1 A 0 A_Explode(random(60,100),32,0);
		Goto Death;
	XDeath:
		TNT1 A 0 { bISMONSTER = true; }   // CH: A_changeflag("ismonster",true)
		B0N8 F 1 A_VileTarget("RS_Drt3");
		B0N8 F 1 A_VileAttack("HEAVIMPB",random(20,60),random(20,60),64,4,"Melee");
		TNT1 AAAAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		B0N8 FFF 8 A_FadeOut(0.33);
		TNT1 A 0 A_Die();
		Stop;
	Death:
		B0N8 F 8 A_SetSolid();
		B0N8 F 16;
		B0N8 FFF 8 A_FadeOut(0.33);
		TNT1 A 0 A_Die();
		Stop;
	}
}

class RS_BrownMindStoneThrow : Actor   // CH MASTERMINDS.txt:723
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 12;
		DamageFunction (random(1,2));
		Projectile;
		DamageType "Fire";
		+HITTARGET
		DeathSound "";
		Scale 0.33;
	}
	States
	{
	Spawn:
		JUBD A 4 Bright;
		Goto Death;
	Death:
		RIP1 D 0;
		Stop;
	XDeath:
		TNT1 A 0 { bISMONSTER = true; }   // CH: A_changeflag("ismonster",true)
		TNT1 A 1 A_VileTarget("RS_Drt3");
		TNT1 A 1 A_VileAttack("HEAVIMPB",random(20,60),random(20,60),64,4,"Melee");
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 A 0 A_Die();
		Stop;
	}
}


// ---------------------------------------------------------------------------
// CYAN -- "Cyanide Master(Mind)". CH MASTERMINDS.txt:992-1088.
// ---------------------------------------------------------------------------

class RS_IceOrbCyanMind : Actor   // CH MASTERMINDS.txt:992
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 42;
		DamageFunction (random(5,55));
		DamageType "Ice";
		Projectile;
		+THRUSPECIES
		Alpha 0.85;
		Scale 1.5;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}

	int user_orbit;

	States
	{
	Spawn:
		TNT1 A 0;
	Jumps:
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4","A5","A6");
	A2:
		ICEY A 1 Bright;
		ICEY B 1 Bright A_Warp(AAPTR_TARGET,64,0,24,user_orbit,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_BOB);
		ICEY C 1 Bright { user_orbit = user_orbit + 7; }
		TNT1 A 0 A_Jump(12,"Fly");
		Loop;
	A1:
		ICEY A 1 Bright;
		ICEY B 1 Bright A_Warp(AAPTR_TARGET,64,0,24,user_orbit,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_BOB);
		ICEY C 1 Bright { user_orbit = user_orbit - 7; }
		TNT1 A 0 A_Jump(12,"Fly");
		Loop;
	A3:
		ICEY A 1 Bright;
		ICEY B 1 Bright A_Warp(AAPTR_TARGET,128,0,24,user_orbit,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_BOB);
		ICEY C 1 Bright { user_orbit = user_orbit + 19; }
		TNT1 A 0 A_Jump(12,"Fly");
		Loop;
	A4:
		ICEY A 1 Bright;
		ICEY B 1 Bright A_Warp(AAPTR_TARGET,128,0,24,user_orbit,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_BOB);
		ICEY C 1 Bright { user_orbit = user_orbit - 19; }
		TNT1 A 0 A_Jump(12,"Fly");
		Loop;
	A5:
		ICEY A 1 Bright;
		ICEY B 1 Bright A_Warp(AAPTR_TARGET,88,0,24,user_orbit,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_BOB);
		ICEY C 1 Bright { user_orbit = user_orbit + 12; }
		TNT1 A 0 A_Jump(12,"Fly");
		Loop;
	A6:
		ICEY A 1 Bright;
		ICEY B 1 Bright A_Warp(AAPTR_TARGET,88,0,24,user_orbit,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_BOB);
		ICEY C 1 Bright { user_orbit = user_orbit - 12; }
		TNT1 A 0 A_Jump(12,"Fly");
		Loop;
	Fly:
		// CH passes SXF_NOCHECKPOSITION into A_SpawnItemEx's ANGLE slot here
		// (8th positional). Kept verbatim -- CH's own arity, not a port slip.
		ICEY ABC 2 Bright A_SpawnItemEx("RS_IceFattTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		ICEY FGHI 5 Bright A_Explode(random(5,40),64);
		Stop;
	}
}

class RS_IceOrbCyanMind2 : RS_IceOrbCyanMind   // CH MASTERMINDS.txt:1059
{
	States
	{
	Spawn:
		TNT1 A 0;
	Jumps:
		TNT1 A 0 A_Jump(255,"Fly");
	}
}

class RS_CyanSpidTrail : SpecialSpot   // CH MASTERMINDS.txt:1070
{
	Default
	{
		Radius 32;
		Height 32;
		Speed 8;
		RenderStyle "Add";
		Translation "48:79=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "128:151=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "0:15=%[0.00,0.00,0.58]:[0.00,0.00,0.72]", "4:4=4:4", "80:95=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "152:159=%[0.00,0.00,2.00]:[1.01,2.00,2.00]", "96:111=%[0.00,0.00,2.00]:[1.01,2.00,2.00]", "48:63=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "13:15=203:207", "236:239=202:207", "208:223=192:207", "16:31=192:207", "168:191=0:0", "32:47=195:207", "160:167=192:201", "224:231=192:199", "232:235=200:203", "255:255=201:201", "248:249=192:192", "112:127=192:207";
		Alpha 0.33;
		Projectile;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		SUPS A 18;
		SUPS AAA 3 A_FadeOut(0.10);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// ABYSS -- "Abys$|<%#(currency)e(pound)Mind". CH MASTERMINDS.txt:1353-1669.
// ---------------------------------------------------------------------------

class RS_AbyssMindBigZap : Actor   // CH MASTERMINDS.txt:1353
{
	Default
	{
		Radius 18;
		Height 18;
		Speed 1;
		Projectile;
		+DONTHARMCLASS
		+NOCLIP
		+FLOATBOB
		RenderStyle "Add";
		Alpha 1.95;
		Scale 1.05;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ZPWV ABCBCABCACBABCA 10 Bright;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_AbyssMindWave : Actor   // CH MASTERMINDS.txt:1378
{
	Default
	{
		Radius 18;
		Height 18;
		Speed 34;
		ProjectileKickback 9000;
		DamageFunction (random(30,80));
		DamageType "Melee";
		Projectile;
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 0.25;
		Scale 0.85;
		SeeSound "queen/fire";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ZPWV D 5 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWave2",0,0,3,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		ZPWV D 5 Bright A_SetScale(0.75,0.75);
		ZPWV D 5 Bright A_SetScale(0.60,0.60);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWave2",0,0,3,0,0,0,0);
		ZPWV D 5 Bright A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		ZPWV D 5 Bright A_SetScale(0.75,0.75);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWave2",0,0,3,0,0,0,0);
		ZPWV D 5 Bright A_SetScale(0.85,0.85);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		ZPWV ABC 9 Bright A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(4,14),0,random(-4,4),random(-359,359));
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ZPWV BA 9 Bright A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(4,14),0,random(-4,4),random(-359,359));
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_CrackedAbyssMindFloor : Actor   // CH MASTERMINDS.txt:1420
{
	Default
	{
		Radius 4;
		Species "Revenant";
		Height 4;
		Speed 24;
		DamageFunction (random(10,30));
		DamageType "Plasma";
		Projectile;
		+FLOORHUGGER
		Scale 0.85;
		RenderStyle "Add";
		Alpha 1.95;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "Ice";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A3","A2");
	A1:
		TNT1 A 3 Bright A_CStaffMissileSlither();
		TNT1 A 0 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(4,14),0,random(-4,4),0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	A2:
		TNT1 A 3 Bright A_Weave(random(1,8),0,random(1,12),0);
		TNT1 A 0 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(4,14),0,random(-4,4),0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	A3:
		TNT1 A 3 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(4,14),0,random(-4,4),0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_CrackedAbyssMind : Actor   // CH MASTERMINDS.txt:1462
{
	Default
	{
		Radius 4;
		Species "Revenant";
		Height 4;
		Speed 18;
		DamageFunction (random(1,6));
		DamageType "Plasma";
		Projectile;
		Scale 0.85;
		RenderStyle "Add";
		Alpha 1.95;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "Ice";
	}
	States
	{
	Spawn:
		BLL9 AA 1 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 AA 1 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 BB 2 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 BB 2 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_Zap88",random(-32,32),random(-32,32),random(-32,32),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Explode(random(2,9),64,0);
		BLL9 CDE 6 Bright;
		Stop;
	}
}

class RS_CrackedAbyssMindFall : Actor   // CH MASTERMINDS.txt:1491
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 18;
		DamageFunction (random(10,60));
		DamageType "Plasma";
		Projectile;
		+NOGRAVITY
		+CEILINGHUGGER
		Scale 0.85;
		RenderStyle "Add";
		Alpha 1.95;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "Ice";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 { bCEILINGHUGGER = false; }   // CH: A_changeflag("CeilingHugger",FALSE)
		TNT1 A 0 { bNOGRAVITY = false; }       // CH: A_changeflag("Nogravity",FALSE)
		TNT1 A 2 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),0,0,random(-1,4),0);
		Loop;
	Death:
		BLL9 C 6 Bright;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(6,28),0,random(1,4),random(-359,-180));
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(6,28),0,random(1,4),random(-180,0));
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(6,28),0,random(1,4),random(0,180));
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_CrackedAbyssMind",0,0,random(2,16),random(6,28),0,random(1,4),random(180,359));
		BLL9 DE 6 Bright;
		Stop;
	}
}

class RS_AbyssMindWave2 : Actor   // CH MASTERMINDS.txt:1527
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 34;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.05;
		Scale 1.25;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ZPWV D 3 Bright;
		ZPWV D 3 Bright A_SetScale(1.4,1.4);
		ZPWV D 3 Bright A_SetScale(1.6,1.6);
		ZPWV D 3 Bright A_SetScale(1.8,1.8);
		Stop;
	}
}

class RS_AbyssMindSpike : Actor   // CH MASTERMINDS.txt:1551
{
	Default
	{
		Speed 1;
		DamageFunction (random(1,10));
		DamageType "Getoutofmyheadcharles";
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		RenderStyle "Add";
		Alpha 1.95;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 AA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SSPK D 10;
		SSPK A 3 A_SetScale(1.0,0.3);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 3 A_SetScale(1.0,0.6);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 3 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 8 { bTHRUACTORS = false; }   // CH: a_changeflag("thruactors",FALSE)
		Goto Death;
	Death:
		SSPK A 8 A_SetSolid();
		TNT1 A 0 A_SpawnItemEx("RS_CrackedAbyssMindFall",random(-264,264),random(-264,264),200,random(1,9),0,0,random(-359,359),SXF_NOCHECKPOSITION,128);
		SSPK A 16;
		TNT1 AA 0 A_SpawnItemEx("RS_CrackedAbyssMindFall",random(-764,764),random(-764,764),200,random(1,9),0,0,random(-359,359),SXF_NOCHECKPOSITION,128);
		SSPK AAA 8 A_FadeOut(0.33);
		Stop;
	}
}

class RS_AbyssMindSpike2 : Actor   // CH MASTERMINDS.txt:1588
{
	Default
	{
		Speed 1;
		DamageFunction (random(1,10));
		DamageType "Getoutofmyheadcharles";
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		RenderStyle "Add";
		Alpha 1.95;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 AA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SSPK D 20;
		TNT1 AA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SSPK A 2 A_SetScale(1.0,0.3);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 2 A_SetScale(1.0,0.6);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 2 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 7 { bTHRUACTORS = false; }   // CH: a_changeflag("thruactors",FALSE)
		Goto Death;
	Death:
		SSPK A 8 A_SetSolid();
		SSPK A 16;
		SSPK AAA 8 A_FadeOut(0.33);
		Stop;
	}
}

class RS_AbyssMindWalk1 : Actor   // CH MASTERMINDS.txt:1624
{
	Default
	{
		+NOINTERACTION
		+FLOATBOB
		RenderStyle "Add";
		Alpha 0.5;
		// Scale is set in BeginPlay below: the engine's Default-block
		// 'scale' property takes ONE float and assigns X and Y together
		// (DEFINE_PROPERTY(scale, F, Actor)), so a non-uniform scale like
		// CH's 2.55 x 2.85 cannot be expressed there at all.
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Scale = (2.55, 2.85);   // CH: Scale.X 2.55 / Scale.Y 2.85
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(32,"A3");
		CDW2 ABC 3;
		// RS_AbyssCybieDecoFlame is EXPECTED FROM CYBIES (CH CYBIES.txt:1441).
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCybieDecoFlame",random(-16,16),random(-16,16),random(42,66),random(1,2),0,random(1,9),random(-359,359),0,176);
		TNT1 A 0 A_SpawnItemEx("RS_Zap99",random(-32,32),random(-32,32),random(22,86),random(1,2),0,random(1,9),random(-359,359),0,88);
		CDW2 FED 3;
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(12,76),random(1,6),0,random(1,3),random(-359,359));
		Stop;
	A3:
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(12,76),random(1,6),0,random(1,3),random(-359,359));
		TNT1 A 0 A_SetScale(1.75,1.75);
		OVER ABB 3;
		TNT1 A 0 A_SpawnItemEx("RS_Zap99",random(-32,32),random(-32,32),random(22,86),random(1,2),0,random(1,9),random(-359,359));
		OVER CCA 3;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCybieDecoFlame",random(-16,16),random(-16,16),random(42,66),random(1,2),0,random(1,9),random(-359,359));
		Stop;
	}
}

class RS_AbyssMindWalk2 : RS_AbyssMindWalk1   // CH MASTERMINDS.txt:1655
{
	Default { Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]"; }
}

class RS_AbyssMindWalk3 : RS_AbyssMindWalk1   // CH MASTERMINDS.txt:1656
{
	Default { Translation "0:255=0:0"; }
}

class RS_AbyssMindWalk4 : RS_AbyssMindWalk1   // CH MASTERMINDS.txt:1657
{
	Default
	{
		RenderStyle "Fuzzy";
		Translation "0:255=0:255";
	}
}

class RS_AbyssMindWalk : RandomSpawner   // CH MASTERMINDS.txt:1663
{
	Default
	{
		DropItem "RS_AbyssMindWalk1", 255, 25;
		DropItem "RS_AbyssMindWalk2", 255, 25;
		DropItem "RS_AbyssMindWalk3", 255, 25;
		DropItem "RS_AbyssMindWalk4", 255, 25;
	}
}


// ---------------------------------------------------------------------------
// GRAY -- "Rocky Road Spider". CH MASTERMINDS.txt:1971-2112.
// (RS_SpRocket4, CH MASTERMINDS.txt:2014, is NOT defined here -- the spider
//  family already ships the byte-identical Spiders.txt copy.)
// ---------------------------------------------------------------------------

class RS_GrayMindNeedle : Actor   // CH MASTERMINDS.txt:1971
{
	Default
	{
		Radius 6;
		Height 4;
		DamageFunction (random(10,50));
		DamageType "Melee";
		Speed 5;
		// Scale is set in BeginPlay below: the engine's Default-block
		// 'scale' property takes ONE float and assigns X and Y together
		// (DEFINE_PROPERTY(scale, F, Actor)), so a non-uniform scale like
		// CH's 1.1 x 0.45 cannot be expressed there at all.
		Decal "BulletChip";
		AttackSound "moloch/nailhitbleed";
		DeathSound "spike/spiked";
		Projectile;
		+SPAWNSOUNDSOURCE
		+BLOODSPLATTER
		+SEEKERMISSILE
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Scale = (1.1, 0.45);   // CH: Scale.X 1.1 / Scale.Y 0.45
	}
	States
	{
	Spawn:
		BLAD A 5 Bright;
		BLAD A 1 A_ScaleVelocity(3);
		Goto Fly;
	Fly:
		BLAD A 1 Bright A_SeekerMissile(5,5,SMF_PRECISE);
		BLAD A 1 Bright A_ScaleVelocity(5);
	Fly2:
		BLAD A 1 Bright A_SeekerMissile(5,5,SMF_PRECISE);
		BLAD A 1 Bright A_ScaleVelocity(8);
	Fly3:
		BLAD A 1 Bright A_SeekerMissile(5,5,SMF_PRECISE);
		BLAD A 1 Bright A_ScaleVelocity(10);
	Fly4:
		BLAD A 1 Bright;
		Loop;
	Death:
		"6PUF" A 0 A_PlaySound("moloch/nailhit");
		"6PUF" ABCDEF 1 Bright;
		Stop;
	}
}

class RS_BrainPainGray : Actor   // CH MASTERMINDS.txt:2043
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		Monster;
		+NOTRIGGER
		+NOTARGET
		+DONTTHRUST
		+NOGRAVITY
		+NOCLIP
		-COUNTKILL
		Scale 1.25;
		Alpha 0.5;
		RenderStyle "Translucent";
		Translation "0:255=%[0.14,0.25,0.32]:[0.79,0.79,0.79]", "168:191=0:2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY AAABBBCCC 1 Bright A_Warp(AAPTR_MASTER,random(-8,8),random(-13,13),random(82,102),0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	Death:
		ICEY A 2 Bright A_NoBlocking();
		ICEY B 2 Bright A_SetScale(1);
		ICEY C 2 Bright A_SetScale(0.7);
		ICEY F 2 Bright A_SetScale(0.4);
		Stop;
	}
}

class RS_SpidieShotGray : Actor   // CH MASTERMINDS.txt:2075
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 46;
		DamageFunction (random(1,11));
		Projectile;
		+USEBOUNCESTATE
		BounceType "Hexen";
		BounceCount 3;
		BounceFactor 1;
		WallBounceFactor 1;
		Scale 0.25;
		DamageType "Melee";
		SeeSound "moloch/nailhitbleed";
		DeathSound "spike/spiked";
		Translation "0:255=%[0.14,0.25,0.32]:[0.79,0.79,0.79]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 AB 4 Bright;
		Loop;
	Bounce:
		PUFI ABCD 2 Bright;
		TNT1 A 0 A_Explode(random(1,10),128);
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0;
		Goto Fly;
	Death:
		PUFI ABCD 2 Bright;
		TNT1 A 0 A_Explode(random(1,10),128);
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// FIREBLU -- "It's horrifying!". CH MASTERMINDS.txt:2236-2335.
// ---------------------------------------------------------------------------

class RS_FireBluMindFlame1 : Actor   // CH MASTERMINDS.txt:2236
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 1;
		DamageFunction (random(5,23));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200", "160:160=177:177", "162:162=184:184", "163:163=204:204", "164:164=186:186", "165:165=204:204", "166:166=189:189", "167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 1 Bright;
		Goto Death;
	Death:
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-128,128),random(-128,128),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		FIRE CDEEDCDE 5 A_Explode(random(3,10),64);
		FIRE FGH 4 Bright A_Explode(random(3,10),64);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-128,128),random(-128,128),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		FIRE CDEEDCDE 5 A_Explode(random(3,10),64);
		FIRE FGH 4 Bright A_Explode(random(3,10),64);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-128,128),random(-128,128),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_FireBluMindFlame2 : Actor   // CH MASTERMINDS.txt:2269
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 1;
		DamageFunction (random(5,15));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.5;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200", "160:160=177:177", "162:162=184:184", "163:163=204:204", "164:164=186:186", "165:165=204:204", "166:166=189:189", "167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 1 Bright;
		Goto Death;
	Death:
		FIRE CDEEDCDE 5 A_Explode(random(3,6),32);
		FIRE FGH 4 Bright A_Explode(random(3,6),32);
		Stop;
	}
}

class RS_FireBluMindFlame3 : Actor   // CH MASTERMINDS.txt:2298
{
	Default
	{
		Radius 14;
		Height 14;
		Speed 14;
		DamageFunction (random(5,15));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		+SEEKERMISSILE
		+FLOORHUGGER
		RenderStyle "Add";
		Alpha 0.85;
		// Scale is set in BeginPlay below: the engine's Default-block
		// 'scale' property takes ONE float and assigns X and Y together
		// (DEFINE_PROPERTY(scale, F, Actor)), so a non-uniform scale like
		// CH's 1.5 x 0.7 cannot be expressed there at all.
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200", "160:160=177:177", "162:162=184:184", "163:163=204:204", "164:164=186:186", "165:165=204:204", "166:166=189:189", "167:167=207:207";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Scale = (1.5, 0.7);   // CH: Scale.X 1.5 / Scale.Y 0.7
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		FIRE A 1 Bright A_SeekerMissile(6,3);
		TNT1 AAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-64,64),random(-64,64),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		FIRE B 1 Bright A_Explode(random(3,12),64);
		Loop;
	Death:
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-128,128),random(-128,128),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		FIRE CDEEDCDE 1 A_Explode(random(3,9),64);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-128,128),random(-128,128),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		FIRE FGH 1 Bright A_Explode(random(3,9),64);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_FireBluMindFlame2",random(-128,128),random(-128,128),random(0,12),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// GREEN and BLUE. CH MASTERMINDS.txt:2455-2722.
// (RS_FrostLong / RS_FrostLong2, CH MASTERMINDS.txt:2610 / :2640, are NOT
//  defined here -- the imp family already shipped them.)
// ---------------------------------------------------------------------------

class RS_SpidieShot1 : Actor   // CH MASTERMINDS.txt:2455
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 65;
		FastSpeed 80;
		DamageFunction (random(3,8));
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.15;
		DamageType "Poison";
		SeeSound "spider/attack";
		DeathSound "imp/shotx";
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Loop;
	Death:
		BAL1 CD 4 Bright;
		BAL1 D 0 A_Jump(128,"Gas");
		BAL1 E 2 Bright;
		Stop;
	Gas:
		BAL1 E 2 Bright A_SpawnItemEx("RS_Gas14",random(-5,5),random(-8,8),random(-1,7),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_IceOrb : Actor   // CH MASTERMINDS.txt:2652
{
	Default
	{
		Radius 16;
		Height 15;
		Speed 14;
		VSpeed 1.1;
		DamageFunction (random(10,55));
		DamageType "Ice";
		Projectile;
		+SEEKERMISSILE
		+BOUNCEONFLOORS
		+USEBOUNCESTATE
		RenderStyle "Add";
		BounceType "Doom";
		BounceCount 7;
		BounceFactor 1.5;
		WallBounceFactor 0.2;
		Alpha 0.85;
		Scale 2;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		BounceSound "Ice/Splode";
		WeaveIndexXY 9;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 3 Bright A_SeekerMissile(6,6);
		ICEY B 3 Bright A_ScaleVelocity(1.5);
		ICEY C 3 Bright A_Weave(0,3,0,4);
		Loop;
	Bounce.Wall:
		ICEY F 1 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(3.5,3.5);
		TNT1 AAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ICEY FGHI 5 Bright A_Explode(random(6,12),64);
		TNT1 AAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_FrostMind : Actor   // CH MASTERMINDS.txt:2697
{
	Default
	{
		Radius 18;
		Height 18;
		Speed 19;
		DamageFunction (random(5,12));
		DamageType "Ice";
		Projectile;
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		Scale 1.1;
		SeeSound "ice/Breath";
		DeathSound "Ice/Splode";
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		PUFI ABCD 3 Bright A_Explode(random(3,13),20);
		Goto Death;
	Death:
		PUFI EFGH 4 Bright A_Explode(random(3,13),20);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// PURPLE. CH MASTERMINDS.txt:2916-3035.
// ---------------------------------------------------------------------------

class RS_OrbPurpleMind : Actor   // CH MASTERMINDS.txt:2916
{
	Default
	{
		Radius 3;
		Height 2;
		Speed 30;
		DamageFunction (random(10,30));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+FLOATBOB
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.25;
		SeeSound "Weapons/Plasmaf";
		DeathSound "weapons/plasmax";
		Translation "16:47=250:254", "48:79=250:254", "80:111=250:254", "128:143=250:254", "144:151=253:254", "152:191=250:254";
	}
	States
	{
	Spawn:
		BAL1 A 1 Bright A_BishopMissileWeave();
		TNT1 A 0 A_SpawnItemEx("RS_OrbPurpMindTrail",0,0,0);
		BAL1 B 1 Bright A_BishopMissileWeave();
		TNT1 A 0 A_SpawnItemEx("RS_OrbPurpMindTrail",0,0,0);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(0.4,0.4);
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_OrbPurpMindTrail : Actor   // CH MASTERMINDS.txt:2949
{
	Default
	{
		Radius 3;
		Height 3;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.45;
		Scale 0.25;
		Translation "16:47=250:254", "48:79=250:254", "80:111=250:254", "128:143=250:254", "144:151=253:254", "152:191=250:254";
	}
	States
	{
	Spawn:
		BAL1 AB 2 Bright;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_DemoMissile : Actor   // CH MASTERMINDS.txt:2969
{
	Default
	{
		Species "MMind3";
		Radius 11;
		Height 8;
		Speed 17;
		Damage 20;
		DamageType "Fire";
		Projectile;
		+DEHEXPLOSION
		+ROCKETTRAIL
		+THRUSPECIES
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		MISL A 1 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		BBOM A 4 Bright A_SetScale(1.8);
		BBOM B 5 A_SetTranslucent(0.65);
		BBOM B 1 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM B 1 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM C 5 Bright A_Explode(random(5,30),165);
		BBOM D 4 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM D 1 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM D 1 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM E 6 Bright A_Explode(random(15,30),165);
		BBOM E 4 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM E 1 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM E 1 Bright A_CustomMissile("RS_BaronStar4",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM EFG 5 Bright A_Explode(random(10,30),165);
		Stop;
	}
}

class RS_BaronStar4 : Actor   // CH MASTERMINDS.txt:3007
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 22;
		FastSpeed 38;
		DamageFunction (random(5,30));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		Scale 1.2;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		BBOM A 1 Bright;
		Goto Death;
	Death:
		BBOM A 2 Bright A_SetScale(1.7);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(10,30),165);
		BBOM EFG 6 Bright A_Explode(random(10,45),165);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// YELLOW. CH MASTERMINDS.txt:3227-3357.
// (RS_TrailSP2, CH MASTERMINDS.txt:3284, is NOT defined here -- the zombieman
//  family already shipped it.)
// ---------------------------------------------------------------------------

class RS_BuffTrailSP : Actor   // CH MASTERMINDS.txt:3227
{
	Default
	{
		Radius 18;
		Height 18;
		Speed 5;
		DamageType "Ice";
		Projectile;
		+THRUACTORS
		RenderStyle "Add";
		SeeSound "bomb/beep";
		Alpha 0.35;
		Scale 0.75;
	}
	States
	{
	Spawn:
		PUFI ABCD 3 Bright;
		Goto Death;
	Death:
		PUFI EFGH 4 Bright;
		Stop;
	}
}

class RS_RemoteBombV2 : Actor   // CH MASTERMINDS.txt:3251
{
	Default
	{
		Radius 20;
		Height 20;
		Mass 20;
		Speed 15;
		DamageFunction (random(5,45));
		SeeSound "prox/fire";
		AttackSound "prox/beep";
		DeathSound "weapons/rocklx";
		DamageType "Fire";
		Projectile;
		+FLOATBOB
		+SEEKERMISSILE
	}
	States
	{
	Spawn:
		BOMB A 2 A_SeekerMissile(9,18);
		BOMB B 2 A_SpawnItemEx("RS_BuffTrailSP",5,0,2);
		BOMB A 2 A_SeekerMissile(9,18);
		BOMB B 2 A_SeekerMissile(9,18);
		BOMB A 2 A_SeekerMissile(9,18);
		BOMB B 2 A_SeekerMissile(9,18);
		Loop;
	Death:
		MISL B 0 A_PlaySound("prox/beep");
		MISL B 0 A_Explode(random(10,50),128);
		MISL B 5 Bright A_PlaySound("weapons/rocklx");
		MISL CD 5;
		Stop;
	}
}

class RS_TrailSP : Actor   // CH MASTERMINDS.txt:3308
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 22;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.55;
		Decal "ArachnotronScorch";
	}
	States
	{
	Spawn:
		SPPL AB 2 Bright A_SpawnItemEx("RS_TrailSP2",0,0,2);
		Goto Death;
	Death:
		APBX ABCDE 4 Bright A_Explode(10,32);
		Stop;
	}
}

class RS_FiendPlasmaBall : Actor   // CH MASTERMINDS.txt:3332
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 24;
		DamageFunction (random(10,35));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Weapons/Plasmaf";
		DeathSound "Weapons/Plasmax";
		Scale 1.1;
		Decal "ArachnotronScorch";
	}
	States
	{
	Spawn:
		SPPL AB 1 Bright A_CustomMissile("RS_TrailSP",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		APBX ABCDE 4 Bright;
		Stop;
	}
}


// ---------------------------------------------------------------------------
// RED. CH MASTERMINDS.txt:3531-3713.
// ---------------------------------------------------------------------------

class RS_SpiralSawMind1 : Actor   // CH MASTERMINDS.txt:3531
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 18;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(10,60));
		DamageType "Fire";
		Alpha 0.75;
		SeeSound "Weapons/BFGF";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		RED9 B 3 Bright A_SeekerMissile(1,1);
		RED9 AAAAA 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		RED9 ABC 2 Bright A_Weave(5,1,7,1);
		Loop;
	Death:
		SPIR ABCDE 2 Bright A_SpawnItemEx("RS_SpiralSawMind2",random(-128,128),random(-128,128),3,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_RedMindGrounds : Actor   // CH MASTERMINDS.txt:3558
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 14;
		Mass 25;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		BounceCount 999;
		BounceType "Doom";
		DamageType "Fire";
		BounceFactor 1;
		WallBounceFactor 1.5;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.8;
		// Scale is set in BeginPlay below: the engine's Default-block
		// 'scale' property takes ONE float and assigns X and Y together
		// (DEFINE_PROPERTY(scale, F, Actor)), so a non-uniform scale like
		// CH's 1.2 x 0.5 cannot be expressed there at all.
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Scale = (1.2, 0.5);   // CH: Scale.X 1.2 / Scale.Y 0.5
	}
	States
	{
	Spawn:
		RED8 ABC 3 Bright A_Wander();
		RED8 C 1 A_Explode(random(5,20),128);
		RED8 EEDD 1 Bright A_CustomMissile("RS_SpiralSawMind3",4,random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		RED8 FGH 3 Bright A_Wander();
		RED8 H 1 A_Explode(random(5,20),128);
		RED8 D 0 A_Jump(8,"Death");
		Loop;
	Death:
		RED8 ABCD 4 Bright A_SetScale(0.5);
		RED8 CDE 4 A_Explode(random(10,20),64);
		Stop;
	}
}

class RS_RedMindRingNew : Actor   // CH MASTERMINDS.txt:3597
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 1;
		Mass 999999;
		Gravity 10;
		Projectile;
		+BOUNCEONFLOORS
		+THRUACTORS
		+RANDOMIZE
		+DONTBLAST
		+SEEKERMISSILE
		+USEBOUNCESTATE
		+DONTTHRUST
		BounceCount 999;
		BounceType "Hexen";
		BounceFactor 0.5;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		DamageFunction (random(30,90));
		DamageType "Melee";
		Alpha 0.95;
		Scale 1;
	}
	States
	{
	Spawn:
		TNT1 A 1 NoDelay { bFLOORHUGGER = true; }    // CH: A_changeflag("floorhugger",true)
		TNT1 A 0 { bFLOORHUGGER = false; }
		T1RR ABC 3 Bright A_SeekerMissile(99,99);
		MSLH A 0 A_ScaleVelocity(random(8,12));
		Goto Fly;
	Fly:
		T1RR A 2 Bright A_Explode(random(20,60),32,0);
		T1RR B 2 Bright A_CustomMissile("RS_GroundRedCyb",0,0);
		TNT1 A 0 { bFLOORHUGGER = true; }
		T1RR C 1 Bright A_ScaleVelocity(frandom(1.5,2));   // CH: A_ScaleVelocity(random(1.5,2))
		TNT1 A 0 { bFLOORHUGGER = false; }
		T1RR C 1 Bright;
		Loop;
	Bounce.Floor:
		TNT1 A 1 { bFLOORHUGGER = true; }
		TNT1 A 0 { bFLOORHUGGER = false; }
		Goto Fly;
	Bounce.Wall:
		TNT1 A 0;
		Goto Death;
	Death:
		TNT1 A 0 A_Stop();
		RED8 EEDD 1 Bright A_CustomMissile("RS_SpiralSawMind3",4,random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		Stop;
	}
}

class RS_SpiralSawMind3 : Actor   // CH MASTERMINDS.txt:3652
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		Speed 12;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		SPIR ABCDEDCBA 6 Bright A_Explode(random(5,20),88);
		Stop;
	}
}

class RS_SpiralSawMind2 : Actor   // CH MASTERMINDS.txt:3671
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		Speed 2;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.75;
		SeeSound "Weapons/BFGF";
	}
	States
	{
	Spawn:
		SPIR ABCDEDCBA 5 Bright A_Explode(random(10,20),88);
		Stop;
	}
}

class RS_RedMessMind : Actor   // CH MASTERMINDS.txt:3691
{
	Default
	{
		Radius 5;
		Height 5;
		Mass 7;
		Speed 4;
		Projectile;
		+THRUACTORS
		Scale 1.75;
		RenderStyle "Add";
		Alpha 0.5;
		Translation "208:223=176:191", "224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 A 5;
		BAL1 B 5 A_SetTranslucent(0.4);
		Goto Death;
	Death:
		BAL1 A 2 A_SetTranslucent(0.22);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// BLACK -- "Pseudo Old God". CH MASTERMINDS.txt:4094-4424.
// ---------------------------------------------------------------------------

class RS_PortalSummons2 : RandomSpawner   // CH MASTERMINDS.txt:4094
{
	Default
	{
		DropItem "RS_CommonRevenant", 255, 100;
		DropItem "RS_PurpleRevenant", 255, 100;
		DropItem "RS_RedRevenant", 255, 120;
		DropItem "RS_RedLSoul", 255, 100;
		DropItem "RS_DeepTentacle", 255, 350;
		DropItem "RS_RoseTentacle", 255, 800;
		DropItem "RS_YellowSP1", 255, 180;
		DropItem "RS_RedSpectre", 255, 120;
		DropItem "RS_RedDemon", 255, 150;
		DropItem "RS_RedCaco", 255, 120;
	}
}

class RS_PsychicAra2 : Actor   // CH MASTERMINDS.txt:4108
{
	Default
	{
		Projectile;
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		RenderStyle "Stencil";
		Alpha 0.95;
		DamageFunction (random(2,12));
		DamageType "Getoutofmyheadcharles";
		Scale 1.8;
		DeathSound "deepone/active";   // CH: //"queen/active"
		Mass 50;
	}
	States
	{
	Spawn:
	Death:
		ARNQ C 1;
		ARNQ B 2 Bright Radius_Quake(9,9,0,30,0);
		ARNQ C 1 Bright A_RadiusGive("RS_DarknessCallwithnewphone",72,RGF_PLAYERS,1);
		ARNQ B 1;
		Stop;
	}
}

class RS_DarknessCallwithnewphone : Powerup   // CH MASTERMINDS.txt:4133
{
	Default
	{
		Powerup.Color "00 00 00", 0.85;
		Powerup.Duration 120;
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.ADDITIVETIME
		+INVENTORY.NOSCREENBLINK
	}
	States
	{
	Pickup:
		TNT1 A 0 A_Light(-20);
		TNT1 A 0 A_Light(-30);
		TNT1 A 0 A_Light(-25);
		Stop;
	}
}

class RS_BlackSpidShade : SpecialSpot   // CH MASTERMINDS.txt:4151
{
	Default
	{
		Radius 32;
		Height 32;
		Speed 8;
		DamageFunction (random(10,58));
		DamageType "Melee";
		+FLOATBOB
		RenderStyle "Translucent";
		Translation "48:63=[124,124,124]:[2,2,2]", "16:31=[121,121,121]:[2,2,2]", "64:79=[88,88,88]:[2,2,2]", "128:144=[91,91,91]:[48,48,48]", "236:239=0:2", "13:15=0:2", "144:151=104:111", "208:223=96:111", "32:47=96:111", "232:235=108:111", "112:127=46:47", "80:95=144:151", "224:227=103:107", "168:173=96:96", "192:196=236:239", "96:101=236:239", "208:210=102:104", "152:159=106:111";
		Alpha 0.5;
		Scale 1.5;
		Projectile;
	}
	States
	{
	Spawn:
		ARNQ A 24;
		TNT1 A 0 A_RadiusGive("RS_DarknessCallwithnewphone",22,RGF_PLAYERS,1);
		ARNQ A 0 A_Jump(88,"What","What2");
		ARNQ D 3 A_FadeOut(0.10);
		Goto Spawn+1;
	What:
		ARNQ A 3 A_SetScale(1.5,1.5);
		ARNQ D 2 A_FadeOut(0.10);
		ARNQ A 3 A_SetScale(1.75,1.75);
		ARNQ D 2 A_FadeOut(0.10);
		ARNQ A 3 A_SetScale(2,2);
		ARNQ D 2 A_FadeOut(0.10);
		Goto Spawn+1;
	What2:
		ARNQ A 3 A_SetScale(1.25,1.25);
		ARNQ D 2 A_FadeOut(0.10);
		ARNQ A 3 A_SetScale(1,1);
		ARNQ D 2 A_FadeOut(0.10);
		ARNQ A 3 A_SetScale(0.75,0.75);
		ARNQ D 2 A_FadeOut(0.10);
		Goto Spawn+1;
	}
}

class RS_QueenPlasmaBlast : Actor   // CH MASTERMINDS.txt:4191
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 32;
		DamageFunction (random(8,45));
		Projectile;
		DamageType "Plasma";
		Scale 0.75;
		+RANDOMIZE
		+BLOODLESSIMPACT
		+NOEXTREMEDEATH
		+BOUNCEONFLOORS
		+USEBOUNCESTATE
		BounceType "Doom";
		BounceCount 3;
		BounceFactor 1.25;
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "electricplasma/shoot";
		DeathSound "electricplasma/hit";
		Decal "SwordLightning";
		WeaveIndexXY 61;
		WeaveIndexZ 23;
		Translation "0:255=%[0.00,0.00,0.00]:[0.00,0.50,0.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(255,"A2","A3","A1");
	A1:
		EBLT GH 0 A_CustomMissile("RS_QueenPlasmaBlastTrail",0,0,0);
		EBLT GH 2 Bright A_BishopMissileWeave();
		TNT1 A 0 A_ScaleVelocity(1.05);
		Loop;
	A2:
		EBLT GH 0 A_CustomMissile("RS_QueenPlasmaBlastTrail",0,0,0);
		EBLT GH 2 Bright A_CStaffMissileSlither();
		TNT1 A 0 A_ScaleVelocity(1.10);
		Loop;
	A3:
		EBLT GH 0 A_CustomMissile("RS_QueenPlasmaBlastTrail",0,0,0);
		EBLT G 2 Bright ThrustThing(random(0,255),random(1,12),0,0);
		EBLT H 2 Bright ThrustThingZ(0,random(1,50),random(0,1),0);
		Loop;
	Bounce.Wall:
		TNT1 A 0;
		Goto Death;
	Death:
		EBLT IJK 3 Bright;
		Stop;
	}
}

class RS_QueenPlasmaBlastTrail : Actor   // CH MASTERMINDS.txt:4246
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;    // CH: Speed 0//35
		Damage 0;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		EBLT ABC 3 Bright A_BishopMissileWeave();
		Goto Death;
	Death:
		EBLT DEF 4 Bright A_FadeOut(0.25);
		Loop;
	}
}

class RS_QueenPainPlasmaBlast : RS_QueenPlasmaBlast   // CH MASTERMINDS.txt:4267
{
	Default { Speed 15; }
}

class RS_QueenMindWave : Actor   // CH MASTERMINDS.txt:4269
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 24;
		DamageFunction (random(30,80));
		Projectile;
		+SEEKERMISSILE
		DamageType "Plasma";
		RenderStyle "Add";
		SeeSound "queen/fire";
		DeathSound "queen/hit";
		Decal "SwordLightning";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 2 Bright A_SeekerMissile(3,6);   // CH: //(1,90)
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 B 2 Bright A_SeekerMissile(4,8);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 C 2 Bright A_SeekerMissile(4,8);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 D 2 Bright A_SeekerMissile(4,8);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 E 2 Bright A_SeekerMissile(3,9);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 F 2 Bright A_SeekerMissile(4,8);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 G 2 Bright A_SeekerMissile(6,6);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 H 2 Bright A_SeekerMissile(6,6);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 I 2 Bright A_SeekerMissile(6,12);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		TNT1 J 2 Bright A_SeekerMissile(6,12);
		TNT1 A 0 A_SpawnItemEx("RS_ZWAVE",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BLST A 0 Radius_Quake(15,15,0,40,0);
		BLST A 1 Bright A_SetScale(1.2,1.2);
		BLST B 1 Bright A_Explode(random(11,50),110);
		BLST CDEF 1 Bright A_SetScale(1.4,1.4);
		BLST F 0 A_Explode(random(9,40),130);
		BLST FGHI 1 Bright A_SetScale(1.7,1.7);
		BLST I 0 A_Explode(random(7,30),150);
		BLST JKLM 1 Bright A_SetScale(2,2);
		BLST OP 1 Bright A_Explode(random(5,20),170);
		Stop;
	}
}

class RS_ZWAVE3 : Actor   // CH MASTERMINDS.txt:4322
{
	Default
	{
		Radius 10;
		Height 10;
		Speed 15;
		SeeSound "queen/fire";
		Projectile;
		DamageFunction (random(10,30));
		DamageType "Melee";
		RenderStyle "Stencil";
		Alpha 0.65;
		Scale 0.3;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto SpeedUp;
	Fly:
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST ABCD 1 Bright;
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST EFGHI 1 Bright;
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST JKLMN 1 Bright;
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST OP 1 Bright;
		TNT1 A 0 A_Explode(random(2,7),64);
		TNT1 A 0 A_RadiusGive("RS_DarknessCallwithnewphone",24,RGF_PLAYERS,1);
		Goto SpeedUp;
	SpeedUp:
		TNT1 A 0 A_Jump(128,"Spd1","Spd2","Spd3","Spd4","Spd5");
		Goto Fly;
	Spd1:
		TNT1 A 0 A_ScaleVelocity(1.15);
		Goto Fly;
	Spd2:
		TNT1 A 0 A_ScaleVelocity(1.33);
		Goto Fly;
	Spd3:
		TNT1 A 0 A_ScaleVelocity(0.80);
		Goto Fly;
	Spd4:
		TNT1 A 0 A_ScaleVelocity(1.5);
		Goto Fly;
	Spd5:
		TNT1 A 0 A_ScaleVelocity(0.65);
		Goto Fly;
	Death:
		TNT1 A 0 A_RadiusGive("RS_DarknessCallwithnewphone",42,RGF_PLAYERS,1);
		BLST A 1 Bright A_SetScale(0.4,0.4);
		BLST B 1 Bright A_Explode(random(4,14),64);
		BLST CDEF 1 Bright A_SetScale(0.6,0.6);
		BLST F 0 A_Explode(random(6,16),78);
		BLST FGHI 1 Bright A_SetScale(0.8,0.8);
		BLST I 0 A_Explode(random(8,18),94);
		BLST JKLM 1 Bright A_SetScale(1.0,1.0);
		BLST OP 1 Bright A_Explode(random(10,20),108);
		Stop;
	}
}

class RS_ZWAVE : Actor   // CH MASTERMINDS.txt:4383
{
	Default
	{
		Radius 10;
		Height 10;
		Speed 0;
		SeeSound "queen/fire";
		+NOCLIP
		+RIPPER
		Projectile;
		DamageFunction (random(1,3));
		DamageType "Plasma";
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		TNT1 A 4 A_Explode(random(2,7),64);
		BLST ABCD 1 Bright A_FadeOut(0.0625);
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST EFGHI 1 Bright A_FadeOut(0.0625);
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST JKLMN 1 Bright A_FadeOut(0.0625);
		TNT1 A 0 A_Explode(random(2,7),64);
		BLST OP 1 Bright A_FadeOut(0.0625);
		TNT1 A 0 A_Explode(random(2,7),64);
		Stop;
	}
}

class RS_ZWAVE2 : RS_ZWAVE   // CH MASTERMINDS.txt:4411
{
	Default
	{
		+NOINTERACTION
		Scale 1.5;
		Alpha 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 2;
		BLST ABCD 1 Bright A_FadeOut(0.0625);
		BLST EFGHIJKLMNOP 1 Bright A_FadeOut(0.0625);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// WHITE -- "Heavily Armed Spidey". CH MASTERMINDS.txt:4518-4923.
// ---------------------------------------------------------------------------

class RS_WhiteMindFlare : Actor   // CH MASTERMINDS.txt:4518
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		Projectile;
		+NOCLIP
		+DONTTHRUST
		+DONTBLAST
		RenderStyle "Add";
		Alpha 0.9;
		Scale 0.4;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		SSBL ABCDEFGH 1 Bright;
		Stop;
	}
}

class RS_WhiteMindshot1 : Actor   // CH MASTERMINDS.txt:4541
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 45;
		DamageFunction (random(10,50));
		DamageType "Plasma";
		Projectile;
		+BOUNCEONWALLS
		BounceType "Doom";
		BounceCount 2;
		// Scale is set in BeginPlay below: the engine's Default-block
		// 'scale' property takes ONE float and assigns X and Y together
		// (DEFINE_PROPERTY(scale, F, Actor)), so a non-uniform scale like
		// CH's 1.1 x 0.75 cannot be expressed there at all.
		RenderStyle "Add";
		SeeSound "weapons/plasmaf";
		DeathSound "weapons/plasmax";
		BounceSound "";
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Scale = (1.1, 0.75);   // CH: Scale.X 1.1 / Scale.Y 0.75
	}
	States
	{
	Spawn:
		// CH passes SXF_NOCHECKPOSITION into the ANGLE slot here too. Verbatim.
		RCHB AB 1 Bright A_SpawnItemEx("RS_SpideMindTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(0.85,0.85);
		RCHB CD 3 Bright;
		TNT1 A 0 A_SetScale(1.35,1.05);
		RCHB E 3 Bright A_Explode(random(10,40),64,0);
		Stop;
	}
}

class RS_WhiteMindRB3 : Actor   // CH MASTERMINDS.txt:4575
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 1;
		DamageFunction (random(30,95));
		DamageType "Plasma";
		Projectile;
		+ALWAYSPUFF
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.33;
		DeathSound "NETHERDE";
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		TNT1 A 0 A_Scream();
		BFE1 AB 5 Bright;
		BFE1 C 8 Bright A_Explode(random(30,95),128);
		TNT1 A 0 Radius_Quake(9,9,0,30,0);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_WhiteMindRB4 : Actor   // CH MASTERMINDS.txt:4604
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 11;
		DamageFunction (random(15,30));
		DamageType "Plasma";
		Projectile;
		Scale 1.33;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "Crack/death";
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 A 3 A_SetScale(1.33,1.33);
		BAL2 B 3 A_SetScale(1.15,1.15);
		BAL2 A 3 A_SetScale(0.85,0.85);
		BAL2 B 3 A_SetScale(1.15,1.15);
	Death:
		BAL2 C 4 A_SetTranslucent(0.55);
		BAL2 D 1 A_Explode(random(10,20),88);
		BAL2 E 2 A_Explode(random(10,20),88);
		Stop;
	}
}

class RS_SpideMindTrail : Actor   // CH MASTERMINDS.txt:4635
{
	Default
	{
		Radius 15;
		Height 9;
		Speed 0;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.8;
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		RCHB AB 3 Bright;
		Goto Death;
	Death:
		RCHB AB 3 Bright;
		Stop;
	}
}

class RS_WhiteMindshoTrail1 : Actor   // CH MASTERMINDS.txt:4658
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 55;
		FastSpeed 80;
		DamageFunction (random(2,6));
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.15;
		Translation "0:255=%[1.01,2.00,2.00]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_WhiteSpidShade : Actor   // CH MASTERMINDS.txt:4681
{
	Default
	{
		Radius 32;
		Height 32;
		Speed 8;
		+NOCLIP
		+DONTTHRUST
		+DONTBLAST
		RenderStyle "Add";
		Translation "0:255=%[1.01,2.00,2.00]:[2.00,2.00,2.00]";
		Alpha 0.5;
		Projectile;
	}
	States
	{
	Spawn:
		W5PD A 12;
		W5PD D 3 A_FadeOut(0.10);
		Goto Spawn+1;
	}
}

class RS_WhiteMindCrackleOrb : Actor   // CH MASTERMINDS.txt:4702
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 9;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		Scale 2.35;
		DamageFunction (random(50,120));
		DamageType "Plasma";
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		DropItem "RS_CH_RocketAmmo";
		Translation "0:255=%[0.21,0.29,0.68]:[1.07,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RED9 B 1 Bright A_Explode(random(4,10),128);
		RED9 B 1 Bright A_SpawnItemEx("RS_CrackedWhiteMind",0,0,0,random(10,20),random(10,20),random(-10,20),random(0,180),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		RED9 A 1 Bright A_SpawnItemEx("RS_CrackedWhiteMind",0,0,0,random(10,20),random(10,20),random(-10,20),random(180,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		RED9 A 1 Bright A_SeekerMissile(2,2);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(4.0,4.0);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(5,50),256);
		SPIR E 1 A_NoBlocking();
		Stop;
	}
}

class RS_WhiteMindCrackleOrb2 : Actor   // CH MASTERMINDS.txt:4736
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 0;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		Scale 1;
		DamageFunction (random(50,120));
		DamageType "Plasma";
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		DropItem "RS_CH_RocketAmmo";
		Translation "0:255=%[0.21,0.29,0.68]:[1.07,2.00,2.00]";
	}
	States
	{
	Spawn:
		RED9 B 2 A_SetScale(1.2,1.2);
		RED9 B 2 A_SetScale(1.5,1.5);
		RED9 B 2 A_SetScale(1.8,1.8);
		RED9 B 2 A_SetScale(2.0,2.0);
		RED9 B 2 A_SetScale(2.2,2.2);
	Fly:
		RED9 B 1 A_SetSpeed(24);
		RED9 A 1 Bright A_SeekerMissile(9,9);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(4.0,4.0);
		RED9 B 1 Bright A_Explode(random(40,100),128);
		RED9 BBBBB 0 Bright A_SpawnItemEx("RS_CrackedWhiteMind",0,0,0,random(10,20),random(10,20),random(-10,20),random(0,180),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		RED9 ABBBB 0 Bright A_SpawnItemEx("RS_CrackedWhiteMind",0,0,0,random(10,20),random(10,20),random(-10,20),random(180,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(5,50),256);
		SPIR E 1 A_NoBlocking();
		Stop;
	}
}

class RS_CrackedWhiteMind : Actor   // CH MASTERMINDS.txt:4776
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 18;
		DamageFunction (random(1,6));
		DamageType "Plasma";
		Projectile;
		Scale 0.5;
		RenderStyle "Add";
		Alpha 1.95;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "0:255=%[0.21,0.29,0.68]:[1.07,2.00,2.00]";
	}
	States
	{
	Spawn:
		BLL9 AA 1 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 AA 1 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 BB 2 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 BB 2 Bright A_SpawnItemEx("RS_Zap88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_Zap88",random(-32,32),random(-32,32),random(-32,32),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Explode(random(2,9),64,0);
		BLL9 CDE 6 Bright;
		Stop;
	}
}

class RS_STracerWhiteSP : Actor   // CH MASTERMINDS.txt:4805
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 20;
		DamageFunction (random(11,33));
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Projectile;
		+FLOORHUGGER
		+THRUGHOST
		-NOGRAVITY
		+DONTSPLASH
		SeeSound "ELECTRO8";
		DeathSound "Crack/death";
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_CStaffMissileSlither();
		TNT1 A 0 A_SpawnItem("RS_STracerPuffSP",0,0);
		Loop;
	Death:
		FTRA K 4 Bright;
		FTRA L 4 Bright A_Explode(random(5,15),64);
		FTRA MNO 3 Bright;
		Stop;
	}
}

class RS_STracerPuffSP : Actor   // CH MASTERMINDS.txt:4837
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Projectile;
		ExplosionRadius 8;
		ExplosionDamage 2;
		+FLOORHUGGER
		-NOGRAVITY
		+DONTSPLASH
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		FTRA ABCDEFGHIJ 3 Bright;
		Stop;
	}
}

class RS_WhiteSpidWave : Actor   // CH MASTERMINDS.txt:4860
{
	Default
	{
		Speed 8;
		DamageFunction (random(5,27));
		DamageType "Plasma";
		Radius 8;
		Height 16;
		RenderStyle "Translucent";
		Alpha 0.9;
		Projectile;
		+DROPOFF
		-NOGRAVITY
		+FORCERADIUSDMG
		+BLOODLESSIMPACT
		+FLOORHUGGER
		SeeSound "";
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		SPER AAAAABBBB 10 Bright A_Explode(random(7,28),32);
	Death:
		SPER B 1 A_Explode(random(7,28),32);
		Stop;
	}
}

class RS_WhiteSpidWinder : Actor   // CH MASTERMINDS.txt:4887
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 30;
		DamageFunction (random(10,70));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		+DONTHARMCLASS
		+THRUSPECIES
		+FLOORHUGGER
		RenderStyle "Add";
		Alpha 0.9;
		Scale 0.85;
		SeeSound "ELECTRO8";
		DeathSound "Crack/death";
		Translation "0:255=%[0.49,0.51,1.52]:[1.10,2.00,1.97]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		SPER AB 1 Bright;
	Fly2:
		SPER A 1 Bright A_SpawnItemEx("RS_WhiteSpidWave",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		SPER B 1 Bright A_SeekerMissile(4,9);
		TNT1 A 0 A_Jump(6,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}
