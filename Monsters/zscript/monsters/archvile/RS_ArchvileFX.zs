// ============================================================================
// RS_ArchvileFX.zs -- Colourful Hell Archvile family: support actors,
// projectiles, minions and third-file externals. 2026-08-06.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Archviles.txt
// (5,287 lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_Archvile.zs.
//
// ---------------------------------------------------------------------------
// CROSS-LANE OWNERSHIP (parallel swarm, CH file order Archviles < CYBIES <
// MASTERMINDS). This lane is the EARLIEST of the three, so it defers to
// nobody among them: every external Archviles.txt names that does not
// already exist in zscript/ is defined HERE, and the later lanes reference
// these names read-only. Naming is mechanical (CH X -> RS_X).
//
// Nothing in Archviles.txt turned out to need a class that CH defines only
// in CYBIES.txt or MASTERMINDS.txt -- every external resolved either to an
// earlier family already in the repo or to this file. Classes defined here
// that CYBIES/MASTERMINDS may want to reference:
//   RS_WickedTorso, RS_BrownBoiVile, RS_ShieldUpVile, RS_BrownVileRock..4,
//   RS_IceStartVile1..4, RS_IceToMeetVile1/2, RS_IceABVile,
//   RS_AbyssPortalVile, RS_ABVileTentacle, RS_ABVileTend,
//   RS_SplashAbyssVile/2, RS_PsychicTangleAbyVile/2, RS_VileGroundSpike,
//   RS_VileGroundSpikes2, RS_VileGrayDecoy, RS_RockVileDrop,
//   RS_RockDropvile2, RS_ROCKDROPVILE, RS_FireBluVile, RS_Greenening/2,
//   RS_Greenies2, RS_BlueGash2/3, RS_PurpleWorry/2, RS_TheBangers,
//   RS_SpecialRev, RS_ReABreath, RS_DFire, RS_BVileCloud/2, RS_BVileEye/2,
//   RS_BvileDummy, RS_EyeIseeViles, RS_DarkFlameVile,
//   RS_DarkFlameTrailVile, RS_DFlamePuffVile/2, RS_DFlameBoomVile,
//   RS_VBtrail..RS_VBtrail4, RS_WVEyeGo, RS_WVileEye1/2/3, RS_WVileBolt1,
//   RS_WVilequake, RS_BrightUpVile/2, RS_WhiteVileResser, RS_WvileSpot.
//
// ALREADY OWNED -- CH defines these in Archviles.txt but earlier families
// imported them first; referenced READ-ONLY here, never redefined (grep
// confirmed each one before this file was written):
//   RS_VileGroundSpikeBrown (:214), RS_VileGroundSpikeBrown2 (:269),
//   RS_BrownVileGas (:450)                     -> baron/RS_BaronFX.zs
//   RS_FireSGguy2 (:2285)                      -> zombieman/RS_ZombiemanFX.zs
//   RS_BlueGash (:2685), RS_BigBolt2 (:2752),
//   RS_ArcRing1 (:3195), RS_ArcRing2 (:3222),
//   RS_ArchRingHelp (:3277), RS_ArchSpawnerOrb (:3319),
//   RS_RandomizerArc (:3388), RS_ReAComet (:3632),
//   RS_ReATrail (:3669), RS_BVileOrb1 (:4245),
//   RS_BVileOrb2 (:4277)                       -> lostsoul/RS_LostSoulFX.zs
//   RS_SparkPuff1 (:3045)                      -> shotgunner/RS_ShotgunnerFX.zs
//   RS_DFlare (:3927), RS_MFlareFX (:3951)     -> cacodemon/RS_CacodemonFX.zs
// Plus the ordinary shared set, all read-only: RS_Zom, RS_ZomTierToken,
// RS_ColorTierIconCH..CH13, RS_GrowRaisin, RS_CHBoner, RS_ThePlanBoner,
// RS_CH_Cirno, RS_HealthBundle, RS_ArmorBundle, RS_BackPackBundle,
// RS_SplashAbyss, RS_SplashAbyss2, RS_AbyssShotIdentifier, RS_Drt1..3,
// RS_SpikeCyanRev, RS_Trail12, RS_MediCacoBrown, RS_CHBSTarget,
// RS_WDRock4, RS_BaronRing, RS_AbyssBaronRing, RS_AbyssBaronSoul,
// RS_FireHKBall1, RS_MrBones, RS_CommonRevenant, RS_AbyssImp2,
// RS_AbyssDemon2, RS_AbyssCaco2, RS_AbyssRevenant2, RS_CyanLSoul2,
// RS_PurpleLSoul, RS_PurpleRevenant, RS_RedRevenant, the RS_Gray* and
// RS_FireBlu* resurrect-minion sets, and the RS_CH_* pickup set.
//
// ---------------------------------------------------------------------------
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, nothing substituted):
//   * Sprite prefix FBXP -- CH VBtrail (:4532, :4535) and CH WVileBolt1
//     (:4664). `find` over the WHOLE CH tree (sprites/, graphics/, every
//     subfolder) returns zero FBXP lumps, and FBXP is not an IWAD prefix.
//     Those three state lines are the only occurrences of the name in all
//     of CH. CH renders nothing there either; the frames are kept verbatim.
//   * Sprite prefix RMGG -- CH ArchRingHelp (:3302 etc). Zero lumps in CH,
//     zero-tic states, plainly CH's typo for RNGG. That actor is already
//     owned by the lostsoul lane, which flagged it the same way.
//   * Sound "spike/spiked" -- CH IceABVile DeathSound (Archviles.txt:1532).
//     CH's SNDINFO.txt has no `spike/` entry at all (it defines Ice/Hit2,
//     Holy2/holy2, Holy3/holy3 and nothing near this). A Hexen logical name
//     that does not resolve under a Doom IWAD; silent in CH too.
//   * Sound "holy2/holy4" -- CH AbyssPortalVile SeeSound (Archviles.txt:1459).
//     CH's SNDINFO defines Holy2/holy2 and Holy3/holy3, never holy2/holy4.
//   * Sound "Ice/hit" -- CH CyanVile's A_VileAttack (Archviles.txt:1029), in
//     RS_Archvile.zs. CH's SNDINFO defines only `Ice/Hit2 ICEI`.
//   Everything else resolves: 72 of the family's 75 sound names reach a real
//   lump through the repo SNDINFO (following $random members), or are engine
//   /IWAD names. No SNDINFO edit and no new sound lump were needed, and CH's
//   $limit/$volume/$pitchshift lines for every name this family uses are
//   already present in the repo SNDINFO.
//
// IWAD prefixes referenced and deliberately NOT extracted from any wad:
//   VILE, MISL, BAL1, BAL2, BFE1, BFE2, BFS1, PLSS, PLSE, SKUL, PUFF,
//   FIRE, FATB, MANF.
// Every other prefix this family names was already in sprites/ from earlier
// imports -- 725 of CH's 725 lumps across the 36 archvile prefixes are
// present, so nothing was copied and no sprites/rs_archvile/ was created.
//
// ---------------------------------------------------------------------------
// STANDING STRIPS, each preserved at its site as a "// CH:" comment:
//   * ACS announcers (AnnounceVile, AnnounceBVile, AnnounceWVile) -- bodies
//     in RS_Archvile.zs.
//   * DRLA cross-mod drops (RLPlasmaShieldArmorPickup, RareArmorPool,
//     RLDemonicWeaponSpawner, RLUniqueWeaponSpawner, RLLegendaryWeaponSpawner).
//   * No CHRandom_GibGenerator / NashGore chain appears anywhere in
//     Archviles.txt, so there was nothing of that kind to strip.
//
// NOT STRIPPED -- the one gameplay ACS script in this family:
//   ACS_NamedExecuteAlways("BrownVileCommand") on CH ShieldUpVile
//   (Archviles.txt:444). Body is CHSett.acs:193-217. Proof it actually
//   runs: the only guard is `if (CheckFlag(0,"BOSS")) Terminate;` -- the
//   Brown Archvile radius-gives this to ordinary monsters, which are not
//   +BOSS, and `Nope` is a fresh function-local that is always 0 at entry,
//   so the else branch is always taken. It sets APROP_DamageFactor 0.65,
//   thrusts the recipient, waits 300 tics and restores. Rebuilt native as
//   RS_BrownVileBuffCtl below, in exactly the shape the imp lane already
//   used for CH's sibling script "BrownImpCommand" (CHSett.acs:219 ->
//   zscript/monsters/imp/RS_ImpFX.zs:33/51). Existing project idiom, not a
//   new invention; CH has no actor for it because ACS needed none.
//
// CONVERSIONS APPLIED (all from real compile errors on this engine):
//   rolls -> DamageFunction (random(a,b)); bare constant Damage N stays
//   bare; CallACS gates -> RS_Zom.CV('rs_ch_*', CH default); A_SetUserVar
//   -> anon blocks; A_ChangeFlag -> { bFLAG = x; }; ThrustThing angle
//   expressions -> int(); A_Chase "" -> null; A_Warp's statelabel 0 ->
//   null; A_KillChildren's bare `extreme` -> "extreme"; scalex ->
//   scale.x. No static const array literals, no `abstract`.
// ============================================================================

// ---------------------------------------------------------------------------
// Brown (tier 13) support.
// ---------------------------------------------------------------------------

class RS_BrownBoiVile : Actor   // CH Archviles.txt:323
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 25;
		Mass 200;
		Health 50;
		DamageFunction (random(10,55));
		DamageType "Melee";
		Monster;
		+FLOAT
		+FLOATBOB
		+NOTARGETSWITCH
		+NOGRAVITY
		+LOOKALLAROUND
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOPAIN
		+NOBLOOD
		+BOUNCEONWALLS
		+BOUNCEONFLOORS
		+BOUNCEONCEILINGS
		+BOUNCEONACTORS
		+USEBOUNCESTATE
		+THRUSPECIES
		-COUNTKILL
		Species "vile1";
		BounceCount 1;
		BounceFactor 0.05;
		WallBounceFactor 0.05;
		XScale 1.6;
		YScale 1.6;
		SeeSound "spit/spit";
		DeathSound "weapons/rocklx";
		Translation "0:255=%[0.19,0.14,0.09]:[1.35,1.17,1.12]";
		Obituary "%o Got rock and rolled by brown archvile";
	}
	States
	{
	Spawn:
		GBLL A 3 Bright;
		Goto See;
	See:
		TNT1 A 0 A_CheckFloor("Death");
		TNT1 A 0 A_CheckFlag("missile","Death",AAPTR_DEFAULT);
		TNT1 A 0 A_JumpIf(scale.x == 0.5, "Death");   // CH: A_jumpif(scalex == 0.5,...)
		GBLL A 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		GBLL B 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		GBLL C 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Goto See;
	Missile:
		GBLL A 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		GBLL B 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_PlaySound("VILEBOI1",0);
		TNT1 A 0 { bIsMonster = false; }
		TNT1 A 0 { bMissile = true; }
		GBLL C 30 Bright A_SkullAttack(45);
		GBLL ABC 6 Bright;
		TNT1 A 0 A_CheckFloor("Death");
		GBLL A 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		GBLL B 6 Bright A_FaceTarget;
		TNT1 A 0 A_CheckFloor("Death");
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_PlaySound("VILEBOI1",0);
		GBLL C 30 Bright A_SkullAttack(45);
		TNT1 A 0 A_CheckFloor("Death");
		GBLL A 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		GBLL B 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_PlaySound("VILEBOI1",0);
		TNT1 A 0 A_CheckFloor("Death");
		GBLL C 30 Bright A_SkullAttack(45);
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_PlaySound("VILEBOI1",0);
		TNT1 A 0 A_CheckFloor("Death");
		GBLL C 60 Bright;
		TNT1 A 0 A_CheckFloor("Death");
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_PlaySound("VILEBOI1",0);
		GBLL C 30 Bright A_SkullAttack(45);
		TNT1 A 0 A_CheckFloor("Death");
		TNT1 A 0 A_SpawnItemEx("RS_Trail12",0,0,5,0,0,0,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_PlaySound("VILEBOI1",0);
		GBLL C 60 Bright;
		TNT1 A 0 A_CheckFloor("Death");
		Goto Death;
	Bounce:
	Bounce.Floor:
	Bounce.Actor:
	Bounce.Wall:
		TNT1 A 0;
		Goto Death;
	XDeath:
	Death:
		MISL B 0 A_SetScale(0.5,0.5);
		MISL B 0 ThrustThingZ(0,12,0,0);
		TNT1 A 0 A_Scream;
		MISL BC 6 Bright A_Explode(random(8,37),64);
		MISL D 5 A_Die;
		Stop;
	}
}

class RS_ShieldUpVile : CustomInventory   // CH Archviles.txt:433
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
		// CH: TNT1 A 0 ACS_NamedExecuteAlways("BrownVileCommand") -- CHSett.acs:193.
		// Gameplay script, not an announcer, and its body DOES run (see header).
		// Rebuilt native below, same shape as the imp lane's RS_BrownImpCommand
		// / RS_BrownImpBuffCtl pair (zscript/monsters/imp/RS_ImpFX.zs:33).
		TNT1 A 0 { if (!bBOSS) A_SpawnItemEx("RS_BrownVileBuffCtl",0,0,0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION); }
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrownVileRock4",0,0,0,0,0,0,0,SXF_SETMASTER,128);
		Stop;
	}
}

// Native rebuild of CHSett.acs:193 "BrownVileCommand": skip bosses; drop the
// recipient's damage taken to 0.65; shove it in a random direction and
// up/down; hold 300 tics; restore. Same carrier shape the imp lane already
// uses for CH's sibling script, so this is the project's existing idiom, not
// a new one.
class RS_BrownVileBuffCtl : Actor   // native rebuild of CHSett.acs:193
{
	double prevFactor;
	bool applied;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
	}

	void RS_ApplyBuff()
	{
		let m = master;
		if (!m || m.bBOSS || m.Health <= 0) return;
		prevFactor = m.DamageFactor;   // CH: int Normal = GetActorProperty(0,APROP_DamageFactor)
		m.DamageFactor = 0.65;         // CH: SetActorProperty(0,APROP_DamageFactor,0.65)
		// CH: ThrustThing(random(0,255),random(1,12),0,0)
		double a = random(0,255) * (360.0 / 256.0);
		m.Vel.XY += AngleToVector(a, random(1,12));
		// CH: ThrustThingZ(0,random(1,12),random(0,1),0) -- speed is in
		// quarter-units, third arg 1 = downward.
		m.Vel.Z += random(1,12) * 0.25 * (random(0,1) ? -1. : 1.);
		applied = true;
	}

	void RS_RevertBuff()
	{
		let m = master;
		if (!applied || !m) return;
		m.DamageFactor = prevFactor;   // CH: SetActorProperty(0,APROP_DamageFactor,normal)
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.RS_ApplyBuff(); }
		TNT1 A 300;   // CH: delay(300)
		TNT1 A 0 { invoker.RS_RevertBuff(); }
		Stop;
	}
}

class RS_BrownVileRock : Actor   // CH Archviles.txt:488
{
	int user_angle;
	int user_pitch;

	Default
	{
		Radius 2;
		Height 2;
		Speed 12;
		Projectile;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		Scale 0.5;
		Translation "0:255=@50[128,64,0]";
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(-2,2),0,0,0,0,SXF_NOCHECKPOSITION,232);
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4");
		Loop;
	A1:
		JUBD A 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,28,0,9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 16; }
		Goto Fly;
	A2:
		JUBD B 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,28,0,9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 16; }
		Goto Fly;
	A3:
		JUBD C 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,28,0,9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 16; }
		Goto Fly;
	A4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,28,0,9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 16; }
		Goto Fly;
	Death:
		TNT1 AA 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		Stop;
	}
}

class RS_BrownVileRock2 : Actor   // CH Archviles.txt:538
{
	int user_angle;
	int user_pitch;

	Default
	{
		Radius 2;
		Height 2;
		Speed 12;
		Projectile;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		Scale 0.3;
		Translation "0:255=@50[128,64,0]";
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(-2,2),0,0,0,0,SXF_NOCHECKPOSITION,232);
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4");
		Loop;
	A1:
		JUBD A 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,21,0,-3,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		Goto Fly;
	A2:
		JUBD B 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,21,0,-3,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		Goto Fly;
	A3:
		JUBD C 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,21,0,-3,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		Goto Fly;
	A4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,21,0,-3,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		Goto Fly;
	Death:
		TNT1 AA 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		Stop;
	}
}

class RS_BrownVileRock3 : Actor   // CH Archviles.txt:588
{
	int user_angle;
	int user_pitch;

	Default
	{
		Radius 2;
		Height 2;
		Speed 12;
		Projectile;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		Scale 0.35;
		Translation "0:255=@50[128,64,0]";
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Flies;
	Flies:
		TNT1 A 0 A_Jump(255,"Fly","Fly2","Fly3","Fly4");
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4");
		Loop;
	A1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly;
	A2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly;
	A3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly;
	A4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly;
	Fly2:
		TNT1 A 0 A_Jump(255,"B1","B2","B3","B4");
		Loop;
	B1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly2;
	B2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly2;
	B3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly2;
	B4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,18,0,-9,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly2;
	Fly3:
		TNT1 A 0 A_Jump(255,"C1","C2","C3","C4");
		Loop;
	C1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly3;
	C2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly3;
	C3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly3;
	C4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly3;
	Fly4:
		TNT1 A 0 A_Jump(255,"D1","D2","D3","D4");
		Loop;
	D1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly4;
	D2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly4;
	D3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly4;
	D4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,32,0,18,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 A_Jump(16,"Death");
		Goto Fly4;
	Death:
		TNT1 AA 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		Stop;
	}
}

class RS_BrownVileRock4 : Actor   // CH Archviles.txt:724
{
	int user_angle;
	int user_pitch;
	int user_timer;

	Default
	{
		Radius 2;
		Height 2;
		Speed 12;
		Projectile;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		Scale 0.55;
		Translation "0:255=@50[128,64,0]";
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Flies;
	Flies:
		TNT1 A 0 A_Jump(255,"Fly","Fly2","Fly3","Fly4");
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4");
		Loop;
	A1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly;
	A2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly;
	A3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly;
	A4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 24; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly;
	Fly2:
		TNT1 A 0 A_Jump(255,"B1","B2","B3","B4");
		Loop;
	B1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly2;
	B2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly2;
	B3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly2;
	B4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly2;
	Fly3:
		TNT1 A 0 A_Jump(255,"C1","C2","C3","C4");
		Loop;
	C1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly3;
	C2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly3;
	C3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly3;
	C4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly3;
	Fly4:
		TNT1 A 0 A_Jump(255,"D1","D2","D3","D4");
		Loop;
	D1:
		JUBD A 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly4;
	D2:
		JUBD B 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly4;
	D3:
		JUBD C 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),0,128);
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly4;
	D4:
		JUBD D 2 Bright;
		TNT1 A 0 A_Warp(AAPTR_MASTER,64,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle - 21; }
		TNT1 A 0 { user_timer = user_timer + 1; }
		TNT1 A 0 A_JumpIf(user_timer >= 150, "Death");
		Goto Fly4;
	Death:
		TNT1 AA 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),0,1,0,3,random(0,360),0);
		Stop;
	}
}

class RS_WickedTorso : Actor   // CH Archviles.txt:877
{
	Default
	{
		Mass 1000000;
		Radius 1;
		Height 1;
		+ISMONSTER
		+CORPSE
	}
	States
	{
	Spawn:
		WICK Q 5 NoDelay A_PlaySound("monster/tenpn1");
		WICK R 5;
		Wait;
	Crash:
		WICK S 1 A_SetFloorClip;
		WICK S 4 A_PlaySound("monster/tenpn2");
		WICK TUV 5;
		WICK W -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cyan (tier 12) support.
// ---------------------------------------------------------------------------

class RS_IceToMeetVile1 : Actor   // CH Archviles.txt:1080
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 28;
		Alpha 0.67;
		Projectile;
		+THRUACTORS
		+THRUGHOST
		+DONTBLAST
		+MTHRUSPECIES
		-NOGRAVITY
		+USEBOUNCESTATE
		BounceType "Doom";
		BounceCount 99;
		BounceFactor 1.0;
		WallBounceFactor 1.0;
		XScale 0.75;
		YScale 0.75;
		Gravity 5.0;
	}
	States
	{
	Spawn:
		TNT1 A 1;
	Fly:
		TNT1 AA 2 Bright A_CStaffMissileSlither;
		TNT1 A 0 A_SpawnItemEx("RS_IceToMeetVile2",0,0,0);
		Loop;
	Bounce.Floor:
		TNT1 A 0 ThrustThing(int(angle),12,0,0);   // CH: thrustthing(angle,12,0,0)
		Goto Fly;
	Bounce.Wall:
		TNT1 A 0 A_Stop;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_IceToMeetVile2 : Actor   // CH Archviles.txt:1120
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 1;
		XScale 1.25;
		YScale 0.15;
		DamageFunction (random(1,2));
		DamageType "Ice";
		Projectile;
		+FLOORHUGGER
		+DONTHARMCLASS
		+RIPPER
		+DONTHARMSPECIES
		SeeSound "";
		DeathSound "Ice/Hit2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CHCY ABCDFG 5 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		CHCY ABCDFG 5 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		TNT1 A 0 A_Jump(12,"Death");
		CHCY ABCDFG 5 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		TNT1 A 0 A_Jump(12,"Death");
		CHCY ABCDFG 5 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		TNT1 A 0 A_Jump(12,"Death");
		CHCY ABCDFG 5 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		CHCY ABCDFG 4 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		CHCY ABCDFG 3 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		CHCY ABCDFG 2 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
		CHCY ABCDFG 1 Bright A_SpawnItemEx("RS_SpikeCyanRev",0,0,6,random(-2,2),0,random(9,45),random(0,359));
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_IceStartVile1 : Actor   // CH Archviles.txt:1161
{
	Default
	{
		Radius 16;
		Height 4;
		Speed 5;
		FloatSpeed 5;
		+NOGRAVITY
		+FLOAT
		RenderStyle "Add";
		Alpha 0.95;
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		GBLL A 0 ThrustThingZ(0,4,0,0);
		C3BB A 10 Bright A_PlaySound("Ice/Fly");
		C3BB B 10 Bright;
		Goto Death;
	Death:
		C3BB DEFG 10 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_IceStartVile2 : Actor   // CH Archviles.txt:1188
{
	Default
	{
		Radius 16;
		Height 4;
		Speed 5;
		FloatSpeed 5;
		DamageType "Ice";
		+NOGRAVITY
		+FLOAT
		RenderStyle "Add";
		Alpha 0.95;
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		GBLL A 0 ThrustThingZ(0,4,0,0);
		TNT1 A 0 A_PlaySound("Ice/Fly");
		C3BB EF 10 Bright A_Explode(random(1,15),64,0);
		Goto Death;
	Death:
		C3BB GHI 8 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_IceStartVile3 : Actor   // CH Archviles.txt:1216
{
	Default
	{
		Radius 16;
		Height 4;
		Speed 5;
		+THRUACTORS
		DamageType "Ice";
		RenderStyle "Add";
		Alpha 0.95;
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		C3BB IH 10 Bright A_Explode(random(1,15),64,0);
		Goto Death;
	Death:
		C3BB GFE 8 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_IceStartVile4 : Actor   // CH Archviles.txt:1240
{
	Default
	{
		Radius 16;
		Height 4;
		Speed 5;
		Scale 0.5;
		RenderStyle "Add";
		Alpha 0.95;
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		C3BB IH 10 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Abyss (tier 9) support.
// ---------------------------------------------------------------------------

class RS_AbyssPortalVile : Actor   // CH Archviles.txt:1444 -- summon, no tier token
{
	int user_charge;

	Default
	{
		Health 250;
		Radius 20;
		Height 64;
		Monster;
		+NOPAIN
		+NOTARGET
		+FLOAT
		+NOBLOOD
		+FLOATBOB
		+NOGRAVITY
		+LOOKALLAROUND
		Speed 2;
		FloatSpeed 2;
		SeeSound "holy2/holy4";
		DeathSound "wraith/wraith5";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_Cell", 128;
		Scale 0.5;
		Tag "Abyss portal";
	}
	States
	{
	Spawn:
		T4TE ABCDE 7 Bright;
	See:
		T4TE FGHIJKLMFGHIJKLM 8 Bright A_Chase;
		TNT1 A 0 A_JumpIf(user_charge == 7, "Missile");
		TNT1 A 0 A_JumpIf(user_charge == 14, "Missile");
		TNT1 A 0 A_JumpIf(user_charge == 21, "Missile");
		T4TE FGHIJKLMFGHIJKLM 8 Bright A_Chase;
		TNT1 A 0 { user_charge = user_charge + 1; }
		Loop;
	Missile:
		T4TE F 1 Bright;
		T4TE F 1 Bright A_PlaySound("SYNTPORT",7,2,false,ATTN_NONE);
		T4TE MLKJIHGF 4 Bright;
		TNT1 A 0 A_JumpIf(user_charge >= 25, "A5");
		TNT1 A 0 A_JumpIf(user_charge >= 20, "A4");
		TNT1 A 0 A_JumpIf(user_charge >= 15, "A3");
		TNT1 A 0 A_JumpIf(user_charge >= 10, "A2");
		TNT1 A 0 A_JumpIf(user_charge >= 5, "A1");
		T4TE F 1 Bright A_PainAttack("RS_AbyssBaronSoul",1,PAF_NOSKULLATTACK);
		Goto See;
	A1:
		T4TE F 1 Bright A_PainAttack("RS_CommonRevenant",1,PAF_NOSKULLATTACK);
		TNT1 A 0 { user_charge = user_charge + 1; }
		Goto See;
	A2:
		T4TE F 1 Bright A_PainAttack("RS_AbyssImp2",1,PAF_NOSKULLATTACK);
		TNT1 A 0 { user_charge = user_charge + 1; }
		Goto See;
	A3:
		T4TE F 1 Bright A_PainAttack("RS_AbyssDemon2",1,PAF_NOSKULLATTACK);
		TNT1 A 0 { user_charge = user_charge + 1; }
		Goto See;
	A4:
		T4TE F 1 Bright A_PainAttack("RS_AbyssCaco2",1,PAF_NOSKULLATTACK);
		TNT1 A 0 { user_charge = user_charge + 1; }
		Goto See;
	A5:
		T4TE F 1 Bright A_PainAttack("RS_AbyssRevenant2",1,PAF_NOSKULLATTACK);
		TNT1 A 0 { user_charge = user_charge + 1; }
		Goto See;
	Death:
		TNT1 A 2 A_ScreamAndUnblock;
		TNT1 A 0 A_SetScale(1,1);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-2,2),random(-2,2),random(0,12),6,0,2,random(-359,359));
		MISL BCD 6 Bright;
		Stop;
	}
}

class RS_IceABVile : Actor   // CH Archviles.txt:1518
{
	Default
	{
		Radius 5;
		Height 2;
		Speed 46;
		DamageFunction (random(9,45));
		DamageType "Ice";
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
		XScale 1.5;
		YScale 0.25;
		SeeSound "Ice/Hit2";
		DeathSound "spike/spiked";
	}
	States
	{
	Spawn:
		ICEY A 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		ICEY B 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		ICEY C 3 Bright;
		Loop;
	Death:
		ICEY FGHI 5 Bright A_Explode(random(5,12),64);
		Stop;
	}
}

class RS_PsychicTangleAbyVile : Actor   // CH Archviles.txt:1548
{
	Default
	{
		Projectile;
		+NOBLOCKMAP
		+NOGRAVITY
		+INVISIBLE
		RenderStyle "Stencil";
		Alpha 0.95;
		DamageFunction (random(1,10));
		DamageType "Getoutofmyheadcharles";
		Scale 0.4;
		DeathSound "deepone/active";
		Mass 50;
	}
	States
	{
	Spawn:
	Death:
		TNT1 A 0;
		TNT1 A 0 A_Explode(1,32);
		TNT1 A 0 Radius_Quake(9,9,0,30,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SPIR ABCDE 1 Bright A_SpawnItemEx("RS_PsychicTangleAbyVile2",random(1,8),random(-12,12),random(0,3),0,0,0,0,SXF_NOCHECKPOSITION);
		SPIR ABCDEABCDE 1 Bright A_SpawnItemEx("RS_PsychicTangleAbyVile2",random(-12,12),random(-28,28),random(0,12),0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_PsychicTangleAbyVile2 : Actor   // CH Archviles.txt:1575
{
	Default
	{
		Projectile;
		+NOBLOCKMAP
		+NOGRAVITY
		RenderStyle "Stencil";
		StencilColor "black";
		Alpha 0.95;
		XScale 0.2;
		YScale 0.76;
	}
	States
	{
	Spawn:
		T6TE ABCDE 1 Bright;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("RS_ArchRingHelp",random(-24,24),random(-28,28),0,0,0,0,0,SXF_NOCHECKPOSITION);
		T6TE JLMNOP 3 Bright;
		Stop;
	}
}

class RS_SplashAbyssVile : Actor   // CH Archviles.txt:1596
{
	Default
	{
		Radius 12;
		Height 1;
		Speed 1;
		DamageFunction (random(10,30));
		XScale 1.7;
		YScale 0.15;
		+FLOORHUGGER
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		BounceCount 999;
		BounceType "Doom";
		BounceFactor 1;
		WallBounceFactor 1;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BOGY ABC 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ArchRingHelp",random(-24,24),random(-28,28),0,0,0,0,0,SXF_NOCHECKPOSITION);
		BOGY CBA 4 Bright;
		TNT1 A 0 A_SetScale(1.6,0.15);
		BOGY BACBCA 4 Bright;
		TNT1 A 0 A_SetScale(1.5,0.15);
		BOGY ABC 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ArchRingHelp",random(-24,24),random(-28,28),0,0,0,0,0,SXF_NOCHECKPOSITION);
		BOGY CBA 4 Bright;
		TNT1 A 0 A_SetScale(1.6,0.15);
		BOGY BACBCA 4 Bright;
		TNT1 A 0 A_SetScale(1.7,0.15);
		BOGY ABC 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ArchRingHelp",random(-24,24),random(-28,28),0,0,0,0,0,SXF_NOCHECKPOSITION);
		BOGY CBA 4 Bright;
		TNT1 A 0 A_SetScale(1.8,0.15);
		BOGY ABCCBA 4 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_SpawnItemEx("RS_ArchRingHelp",random(-24,24),random(-28,28),0,0,0,0,0,SXF_NOCHECKPOSITION);
		BOGY DEF 6 Bright;
		Stop;
	}
}

class RS_ABVileTend : Actor   // CH Archviles.txt:1645
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		XScale 1.85;
		YScale 0.15;
		+FLOORHUGGER
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		+NOCLIP
		-COUNTKILL
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile2",64,0,1,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile2",0,64,1,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile2",-64,0,1,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile2",0,-64,1,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_SplashAbyssVile2 : Actor   // CH Archviles.txt:1674
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		XScale 1.85;
		YScale 0.15;
		+FLOORHUGGER
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		+NOCLIP
		-COUNTKILL
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BOGY ABC 6 Bright;
		Goto Death;
	Death:
		BOGY DEF 6 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ABVileTentacle",0,0,3,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_ABVileTentacle : Actor   // CH Archviles.txt:1704 -- minion, no tier token
{
	Default
	{
		Obituary "%o was tentacle love'd";
		Health 30;
		Species "vile1";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Radius 32;
		Height 112;
		XScale 0.55;
		YScale 0.75;
		MeleeRange 128;
		Mass 0x7FFFFFFF;
		PainChance 96;
		SeeSound "monster/tensit";
		PainSound "monster/tenpai";
		DeathSound "monster/tendth";
		ActiveSound "monster/tenact";
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+LOOKALLAROUND
		+NOTARGET
		+THRUACTORS
		+MISSILEEVENMORE
		-NORADIUSDMG
		-COUNTKILL
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Look;
	See:
		T6TE ABCDE 6;
	SeeLoop:
		T6TE EFGH 2 A_Chase;
		T5TE F 2 A_Jump(4,"Death");
		Loop;
	Melee:
		T6TE I 2 A_FaceTarget;
		T6TE JLMNOP 2 A_CustomMeleeAttack(random(1,7),"");
		T6TE Q 2 A_FaceTarget;
		T6TE RTS 2 A_CustomMeleeAttack(random(1,7),"");
		T6TE UVWZ 2 A_CustomMissile("RS_SplashAbyss2",64,0,random(-25,25),CMF_OFFSETPITCH,random(-45,-5));
		Goto SeeLoop;
	Missile:
		T5TE ABC 3 A_FaceTarget;
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",64,0,random(-25,25),CMF_OFFSETPITCH,random(-45,-5));
		T5TE DE 3 A_FaceTarget;
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",64,0,random(-15,15),CMF_OFFSETPITCH,random(-45,-5));
		T5TE F 3;
		Goto SeeLoop;
	Pain:
		T6TE E 3;
		T6TE E 3 A_Pain;
		Goto SeeLoop;
	Death:
		T6TE E 4;
		T6TE D 4 A_Scream;
		T6TE C 4 A_NoBlocking;
		T6TE BA 4;
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashAbyssVile",random(-128,128),random(-128,128),0,1,0,1,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-128,128),0,1,0,1,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Gray (tier 8) support.
// ---------------------------------------------------------------------------

class RS_VileGroundSpike : Actor   // CH Archviles.txt:1926
{
	Default
	{
		Speed 24;
		Projectile;
		+THRUACTORS
		+FLOORHUGGER
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 4 Bright A_SpawnItemEx("RS_Drt1",random(-3,4),random(-2,2),random(1,3),1,0,1,random(0,360),128);
		TNT1 A 4 Bright A_SpawnItemEx("RS_VileGroundSpikes2",0,0,random(1,3),0,0,0,0,128);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt2",random(-3,4),random(-2,2),random(1,3),1,0,1,random(0,360),128);
		TNT1 A 4 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-4,3),random(1,3),1,0,1,random(0,360),128);
		TNT1 A 4 Bright A_SpawnItemEx("RS_VileGroundSpikes2",0,0,random(1,3),0,0,0,0,128);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt3",random(-3,4),random(-2,2),random(1,3),1,0,1,random(0,360),128);
		TNT1 A 4 Bright A_SpawnItemEx("RS_Drt3",random(-4,4),random(-4,4),random(1,3),1,0,1,random(0,360),128);
		TNT1 A 4 Bright A_SpawnItemEx("RS_VileGroundSpikes2",0,0,random(1,3),0,0,0,0);
		TNT1 AA 0 A_SpawnItemEx("RS_Drt1",random(-3,4),random(-2,2),random(1,3),1,0,1,random(0,360),128);
		Loop;
	Death:
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-3,3),1,0,1,random(0,360),128);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-3,3),1,0,1,random(0,360),128);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-3,3),1,0,1,random(0,360),128);
		Stop;
	}
}

class RS_VileGrayDecoy : Actor   // CH Archviles.txt:1957 -- decoy, no tier token
{
	Default
	{
		Speed 0;
		Health 99;
		Monster;
		+NOTRIGGER
		-COUNTKILL
		Translation "64:79=96:111","48:63=91:106","128:143=101:111","208:223=91:95","13:15=109:111","144:151=100:105","160:167=240:247","224:231=240:247","248:249=241:242","232:235=243:246";
	}
	States
	{
	Spawn:
		TNT1 A 10 A_Jump(256,"A1","A2","A3","A4");
	A1:
		VILE A 90;
		Goto Death;
	A2:
		VILE B 90;
		Goto Death;
	A3:
		VILE C 90;
		Goto Death;
	A4:
		VILE D 90;
		Goto Death;
	Death:
		VILE GGG 8 A_FadeOut(0.33);
		Stop;
	}
}

class RS_VileGroundSpikes2 : Actor   // CH Archviles.txt:1988
{
	Default
	{
		Speed 1;
		DamageFunction (random(1,10));
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
		SSPK C 30 A_Jump(128,"WaitMore");
		SSPK D 10;
		SSPK A 3 A_SetScale(1.0,0.3);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 3 A_SetScale(1.0,0.6);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 3 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Explode(random(60,100),32,0);
		SSPK A 8 { bThruActors = false; }
		Goto Death;
	WaitMore:
		SSPK C 45;
		TNT1 A 0 A_Jump(8,"WaitMore");
		SSPK D 15;
		Goto Fly+1;
	Death:
		SSPK A 8 A_SetSolid;
		SSPK A 16;
		SSPK AAA 8 A_FadeOut(0.33);
		Stop;
	}
}

class RS_RockVileDrop : Actor   // CH Archviles.txt:2025
{
	Default
	{
		Speed 1;
		Projectile;
		+NOCLIP
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 1 Bright A_SpawnItemEx("RS_RockDropvile2",0,0,126,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_RockDropvile2 : Actor   // CH Archviles.txt:2042
{
	Default
	{
		Speed 1;
		Projectile;
		+NOCLIP
		+CEILINGHUGGER
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 1 Bright A_SpawnItemEx("RS_ROCKDROPVILE",0,0,-20,1,1,1,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_ROCKDROPVILE : Actor   // CH Archviles.txt:2060
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 10;
		DamageFunction (random(75,155));
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		+TOUCHY
		BounceType "Hexen";
		BounceCount 1;
		BounceFactor 0.7;
		Gravity 1.25;
		Scale 1.2;
		SeeSound "monster/hamflr";
		DeathSound "moloch/thud";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		JUBD ABCD 3 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-3,3),1,0,1,random(0,360),128);
		Loop;
	Death:
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD D 1 Bright A_Explode(random(60,115),64,0);
		TNT1 AAAAAAAAAAAAAAAAAAA 0 A_CustomMissile("RS_WDRock4",32,0,random(-359,359));
		Stop;
	}
}

// ---------------------------------------------------------------------------
// FireBlu (tier 7) support.
// ---------------------------------------------------------------------------

class RS_FireBluVile : Actor   // CH Archviles.txt:2244
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 1;
		FastSpeed 1;
		DamageFunction (random(5,23));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200","160:160=177:177","162:162=184:184","163:163=204:204","164:164=186:186","165:165=204:204","166:166=189:189","167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 1 Bright;
		Goto Death;
	Death:
		FIRE CDE 4 A_Explode(random(3,10),64);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,15,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,45,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,75,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,105,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,135,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,165,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,195,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,225,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,255,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,285,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,315,0);
		MISL D 0 A_CustomMissile("RS_FireSGguy2",0,0,345,0);
		FIRE FGH 6 Bright A_Explode(random(3,10),64);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Green (tier 2) support.
// ---------------------------------------------------------------------------

class RS_Greenening : Actor   // CH Archviles.txt:2474
{
	Default
	{
		Radius 32;
		Height 16;
		Speed 5;
		FloatSpeed 5;
		+NOGRAVITY
		+FLOAT
		RenderStyle "Add";
		Alpha 0.85;
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		GBLL A 0 ThrustThingZ(0,8,0,0);
		GBLL A 3 Bright A_SetScale(4.7,4.7);
		GBLL A 0 A_PlaySound("Vile/active",0,1.5);
		GBLL B 3 Bright A_SetScale(4.4,4.4);
		GBLL B 0 A_PlaySound("Vile/active",0,1.5);
		GBLL C 3 Bright A_SetScale(3,3);
		GBLL C 0 A_PlaySound("Vile/active",0,1.5);
		Goto Death;
	Death:
		GBLL C 6 Bright A_SetScale(3.5,3.5);
		GBLL B 6 Bright A_SetScale(3,3);
		GBLL A 6 Bright A_SetScale(2,2);
		Stop;
	}
}

class RS_Greenening2 : Actor   // CH Archviles.txt:2507
{
	Default
	{
		Radius 32;
		Height 16;
		+NOGRAVITY
		+FLOAT
		Speed 5;
		FloatSpeed 5;
		RenderStyle "Add";
		Alpha 0.85;
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		GBLL A 0 ThrustThingZ(0,8,0,0);
		GBLL A 3 Bright A_SetScale(2.5,2.5);
		GBLL A 0 A_PlaySound("Vile/active",0,1.5);
		GBLL B 3 Bright A_SetScale(3.2,3.2);
		GBLL B 0 A_PlaySound("Vile/active",0,1.5);
		GBLL C 3 Bright A_SetScale(3.8,3.8);
		GBLL C 0 A_PlaySound("Vile/active",0,1.5);
		Goto Death;
	Death:
		GBLL C 6 Bright A_SetScale(4.7,4);
		GBLL B 6 Bright A_SetScale(4,4.7);
		GBLL A 6 Bright A_PlaySound("Weapons/bfgx");
		BFE2 BCD 2 Bright A_Explode(random(2,8),32);
		BFE2 D 2 Bright A_Burst("RS_Greenies2");
		Stop;
	}
}

class RS_Greenies2 : Actor   // CH Archviles.txt:2542
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 10;
		FastSpeed 20;
		Mass 5;
		DamageFunction (random(1,2));
		DamageType "Poison";
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
		+BOUNCEONFLOORS
		+EXPLODEONWATER
		RenderStyle "Add";
		Alpha 0.75;
		BounceType "Hexen";
		BounceCount 6;
		BounceFactor 1.3;
		WallBounceFactor 1.1;
		Scale 0.25;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
		Translation "168:191=112:127","250:254=117:119","208:223=112:124";
	}
	States
	{
	Spawn:
		BAL2 AB 6 Bright;
		Loop;
	Death:
		BAL2 C 3 Bright A_SetTranslucent(0.4);
		BAL2 DE 6 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Blue (tier 3) support.
// ---------------------------------------------------------------------------

class RS_BlueGash3 : Actor   // CH Archviles.txt:2707
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.65;
		XScale 2.5;
		YScale 3.8;
	}
	States
	{
	Spawn:
		PLSS AB 4 Bright;
		Goto Death;
	Death:
		PLSE ABCDE 3 Bright A_CustomMissile("RS_BlueGash2",random(2,24),random(-24,24),random(-180,180),CMF_AIMOFFSET,random(45,180));
		PLSE EEEEEEEEEE 0 A_CustomMissile("RS_BlueGash2",random(2,24),random(-24,24),random(-180,180),CMF_AIMOFFSET,random(45,180));
		Stop;
	}
}

class RS_BlueGash2 : Actor   // CH Archviles.txt:2730
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 6;
		+RANDOMIZE
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.55;
		Scale 1.25;
	}
	States
	{
	Spawn:
		PLSS AB 4 Bright;
		Goto Death;
	Death:
		PLSE ABCDE 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Purple (tier 4) support.
// ---------------------------------------------------------------------------

class RS_PurpleWorry : Actor   // CH Archviles.txt:2899
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;
		+RANDOMIZE
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.85;
		Scale 2;
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		SBFX HIJK 6 Bright;
		Goto Death;
	Death:
		SBFX L 0 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,6);
		SBFX LKJKL 6 Bright;
		Stop;
	}
}

class RS_PurpleWorry2 : Actor   // CH Archviles.txt:2923
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;
		+RANDOMIZE
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "Spell/SpellCast1";
		Scale 2;
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		SBFX HI 5 Bright A_CustomMissile("RS_TheBangers",8,0,random(-180,180));
		TNT1 AAAA 0 A_SpawnItemEx("RS_TheBangers",0,0,0,random(5,15),0,0,random(0,90));
		SBFX JK 5 Bright A_CustomMissile("RS_TheBangers",8,0,random(-180,180));
		TNT1 AAAA 0 A_SpawnItemEx("RS_TheBangers",0,0,0,random(5,15),0,0,random(90,180));
		SBFX HI 5 Bright A_CustomMissile("RS_TheBangers",8,0,random(-180,180));
		TNT1 AAAA 0 A_SpawnItemEx("RS_TheBangers",0,0,0,random(5,15),0,0,random(180,270));
		SBFX JK 5 Bright A_CustomMissile("RS_TheBangers",8,0,random(-180,180));
		TNT1 AAAA 0 A_SpawnItemEx("RS_TheBangers",0,0,0,random(5,15),0,0,random(270,359));
		SBFX L 2 Bright A_Jump(65,"Death");
		Loop;
	Death:
		SBFX KLJK 7 Bright;
		SBFX L 7 Bright A_Burst("RS_TheBangers");
		Stop;
	}
}

class RS_TheBangers : Actor   // CH Archviles.txt:2956
{
	Default
	{
		Radius 8;
		Height 10;
		Speed 32;
		FastSpeed 54;
		Mass 2;
		DamageFunction (random(1,8));
		DamageType "Plasma";
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
		+DONTHARMCLASS
		+BOUNCEONFLOORS
		+EXPLODEONWATER
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		BounceType "Hexen";
		BounceCount 4;
		BounceFactor 1;
		WallBounceFactor 1.1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
		Translation "168:223=250:254","224:231=250:250";
		Obituary "%o met monarchy of vile kind";
	}
	States
	{
	Spawn:
		SBS4 ABCABC 8 Bright A_SeekerMissile(4,5);
		Goto Death;
	Death:
		BAL2 C 1 Bright A_SetTranslucent(0.4);
		BAL2 C 0 A_SetSpeed(1);
		BAL2 C 0 { bIsMonster = true; }
		BAL2 C 0 { bNoTarget = true; }
		BAL2 C 0 A_Jump(256,"See");
		Stop;
	See:
		BAL2 CC 2 Bright A_Chase(null,null,CHF_RESURRECT);
		Stop;
	Heal:
		BAL2 DE 4 Bright A_Explode(random(2,8),88);
		Stop;
	}
}

class RS_SpecialRev : RS_CommonRevenant   // CH Archviles.txt:3005 -- summon, no tier token
{
	// RS_CommonRevenant's PostBeginPlay sets tier 1; this is a -COUNTKILL
	// summon, so the token is cleared back off per the family rule.
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }

	Default
	{
		Species "Vile1";
		Health 80;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 11;
		PainChance 100;
		RenderStyle "Add";
		Monster;
		MeleeThreshold 236;
		+MISSILEMORE
		+FLOORCLIP
		+DONTHARMSPECIES
		+THRUSPECIES
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o was agitated by a revenant.";
		Obituary "%o had a meeting with purple archviles personal assistants";
		MeleeRange 88;
		Tag "Ghost agitation";
	}
	States
	{
	See:
		SKEL AABBCCDDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL A 0 A_JumpIfMasterCloser(1000,"See");
		SKEL A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

// ---------------------------------------------------------------------------
// Red (tier 6) support.
// ---------------------------------------------------------------------------

class RS_ReABreath : Actor   // CH Archviles.txt:3607
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 18;
		DamageFunction (random(5,25));
		DamageType "Fire";
		Projectile;
		RenderStyle "Add";
		SeeSound "CacoFlame/Attack";
		DeathSound "Fire/fire5";
		Scale 1.7;
	}
	States
	{
	Spawn:
		FLUM ABCDE 2 Bright;
		Goto Death;
	Death:
		BBOM ABC 2 Bright A_SetScale(0.6,0.6);
		BBOM DEFG 2 Bright A_Explode(random(1,5),64);
		Stop;
	}
}

class RS_DFire : Actor   // CH Archviles.txt:3848
{
	Default
	{
		Obituary "%o was charred up red by Red Archvile";
		Radius 0;
		Height 1;
		Speed 0;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 1.00;
		+NOGRAVITY
		+SEEKERMISSILE
		+NOTARGET
		+NODAMAGETHRUST
	}
	States
	{
	Spawn:
		HLFR A 2 Bright A_StartFire;
		TNT1 A 0 A_Explode(4,32);
		HLFR B 2 Bright A_Fire;
		TNT1 A 0 A_Explode(4,32);
		HLFR A 2 Bright A_Fire;
		TNT1 A 0 A_Explode(4,32);
		HLFR B 2 Bright A_Fire;
		TNT1 A 0 A_Explode(4,32);
		HLFR C 2 Bright A_FireCrackle;
		TNT1 A 0 A_Explode(4,32);
		HLFR B 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR C 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR B 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR C 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR D 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR C 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR D 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR C 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR D 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR E 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR D 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR E 2 Bright A_Fire;
		TNT1 A 0 A_Explode(5,32);
		HLFR D 2 Bright A_Fire;
		TNT1 A 0 A_Explode(4,32);
		HLFR E 2 Bright A_FireCrackle;
		TNT1 A 0 A_Explode(4,32);
		HLFR F 2 Bright A_Fire;
		TNT1 A 0 A_Explode(3,32);
		HLFR E 2 Bright A_Fire;
		TNT1 A 0 A_Explode(3,32);
		HLFR F 2 Bright A_Fire;
		TNT1 A 0 A_Explode(3,32);
		HLFR E 2 Bright A_Fire;
		TNT1 A 0 A_Explode(2,32);
		HLFR F 2 Bright A_Fire;
		TNT1 A 0 A_Explode(2,32);
		HLFR G 2 Bright A_Fire;
		TNT1 A 0 A_Explode(2,32);
		HLFR H 2 Bright A_Fire;
		TNT1 A 0 A_Explode(1,32);
		HLFR G 2 Bright A_Fire;
		TNT1 A 0 A_Explode(1,32);
		HLFR H 2 Bright A_Fire;
		TNT1 A 0 A_Explode(1,32);
		HLFR G 2 Bright A_Fire;
		TNT1 A 0 A_Explode(1,32);
		HLFR H 2 Bright A_Fire;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black (tier 10) support.
// ---------------------------------------------------------------------------

class RS_BVileCloud : Actor   // CH Archviles.txt:3967
{
	Default
	{
		Radius 20;
		Height 56;
		Speed 14;
		DamageFunction (random(1,2));
		DamageType "Melee";
		RenderStyle "Stencil";
		Alpha 1;
		Projectile;
		+NOCLIP
	}
	States
	{
	Spawn:
		VILE A 1 A_SetSpeed(12);
		VILE B 1 A_FadeOut(0.25);
		VILE C 1 A_SetSpeed(8);
		VILE D 1 A_FadeOut(0.25);
		VILE E 1 A_FadeOut(0.25);
		Goto Death;
	Death:
		VILE F 1 A_SpawnItemEx("RS_ArchRingHelp",0,0,3,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_BVileCloud2 : Actor   // CH Archviles.txt:3993
{
	Default
	{
		Radius 20;
		Height 56;
		Speed 2;
		RenderStyle "Stencil";
		Alpha 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
	}
	States
	{
	Spawn:
		VILE A 1;
		VILE B 1 A_FadeOut(0.15);
		VILE C 1;
		VILE D 1 A_FadeOut(0.15);
		VILE C 1;
		VILE E 1 A_FadeOut(0.15);
		VILE E 1;
		VILE F 1 A_FadeOut(0.15);
		VILE F 1;
		Stop;
	}
}

class RS_EyeIseeViles : Inventory   // CH Archviles.txt:4019
{
	Default { Inventory.MaxAmount 1; }
}

class RS_BVileEye : Actor   // CH Archviles.txt:4021
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.1;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "112:127=250:254";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BFE1 C 1 Bright A_Warp(AAPTR_TARGET,9,5,60,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 0 A_SpawnItemEx("RS_BvileDummy",0,0,1,0,0,0,0);
		BFE1 B 1 Bright A_Warp(AAPTR_TARGET,9,5,60,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 0 A_SpawnItemEx("RS_BvileDummy",0,0,1,0,0,0,0);
		BFE1 B 0 A_JumpIfInventory("RS_EyeIseeViles",1,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BVileEye2 : Actor   // CH Archviles.txt:4051
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.1;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "112:127=250:254";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BFE1 C 1 Bright A_Warp(AAPTR_TARGET,9,-5,60,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 0 A_SpawnItemEx("RS_BvileDummy",0,0,1,0,0,0,0);
		BFE1 B 1 Bright A_Warp(AAPTR_TARGET,9,-5,60,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 0 A_SpawnItemEx("RS_BvileDummy",0,0,1,0,0,0,0);
		BFE1 B 0 A_JumpIfInventory("RS_EyeIseeViles",1,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BvileDummy : Actor   // CH Archviles.txt:4081
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		Projectile;
		+NOINTERACTION
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		TNT1 A 1 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,50,5,0,0,0,0,frandom(0.01,0.02),frandom(0.01,0.02),frandom(0.01,0.02),0,0,0.0,0.98,-1);
		TNT1 A 1 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,50,5,0,0,0,0,frandom(0.01,0.02),frandom(0.01,0.02),frandom(0.01,0.02),0,0,0.0,0.98,-1);
		Stop;
	}
}

class RS_DarkFlameVile : Actor   // CH Archviles.txt:4101
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 7;
		DamageType "Fire";
		Projectile;
		+FLOORHUGGER
		-NOGRAVITY
		+DONTSPLASH
		+THRUACTORS
		+SEEKERMISSILE
		Translation "32:47=0:0","176:191=5:8","208:223=104:111","224:231=105:105","160:167=103:103";
		Scale 1.5;
		SeeSound "Bvile/Air1";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Fly;
	Fly:
		FTRA C 1 Bright A_SeekerMissile(0,1);
		FTRA C 1 Bright A_Explode(random(4,20),32);
		FTRA C 0 A_SpawnItemEx("RS_DarkFlameTrailVile",0,0,1,0,0,0,0);
		FTRA C 0 A_SpawnItemEx("RS_DFlamePuffVile",random(-16,16),random(-16,16),1,0,0,0,random(-180,180),SXF_NOCHECKPOSITION);
		FTRA C 1 Bright A_SeekerMissile(1,3);
		FTRA D 1 Bright A_Explode(random(4,20),32);
		FTRA C 0 A_SpawnItemEx("RS_DarkFlameTrailVile",0,0,1,0,0,0,0);
		FTRA C 0 A_SpawnItemEx("RS_DFlamePuffVile",random(-16,16),random(-16,16),1,0,0,0,random(-180,180),SXF_NOCHECKPOSITION);
		FTRA E 1 Bright A_SeekerMissile(1,3);
		FTRA F 1 Bright A_Explode(random(4,20),32);
		FTRA C 0 A_SpawnItemEx("RS_DarkFlameTrailVile",0,0,1,0,0,0,0);
		FTRA C 0 A_SpawnItemEx("RS_DFlamePuffVile",random(-16,16),random(-16,16),1,0,0,0,random(-180,180),SXF_NOCHECKPOSITION);
		FTRA E 1 Bright A_SeekerMissile(1,3);
		FTRA D 1 Bright A_Explode(random(4,20),32);
		FTRA C 0 A_SpawnItemEx("RS_DarkFlameTrailVile",0,0,1,0,0,0,0);
		FTRA C 0 A_SpawnItemEx("RS_DFlamePuffVile",random(-16,16),random(-16,16),1,0,0,0,random(-180,180),SXF_NOCHECKPOSITION);
		FTRA C 1 Bright A_SeekerMissile(1,3);
		FTRA C 1 Bright A_Explode(random(4,20),32);
		FTRA C 0 A_SpawnItemEx("RS_DarkFlameTrailVile",0,0,1,0,0,0,0);
		FTRA C 0 A_SpawnItemEx("RS_DFlamePuffVile",random(-16,16),random(-16,16),1,0,0,0,random(-180,180),SXF_NOCHECKPOSITION);
		Loop;
	Death:
		FTRA GHIJ 2 Bright A_SpawnItemEx("RS_DFlameBoomVile",random(-128,128),random(-128,128),random(1,32),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_DarkFlameTrailVile",random(-32,32),random(-32,32),1,0,0,0,0);
		Stop;
	}
}

class RS_DarkFlameTrailVile : Actor   // CH Archviles.txt:4150
{
	Default
	{
		Health 9999;
		Monster;
		Radius 12;
		Height 1;
		Gravity 5;
		-ACTIVATEMCROSS
		-COUNTKILL
		-SHOOTABLE
		+LOOKALLAROUND
		+NOTARGET
		+NEVERTARGET
		+THRUACTORS
		+NOCLIP
		Damage 2;
		DamageType "Fire";
		Speed 2;
		Scale 1.25;
		RenderStyle "Translucent";
		Alpha 0.65;
		Mass 90000;
		Translation "32:47=0:0","176:191=5:8","208:223=104:111","224:231=105:105","160:167=103:103";
	}
	States
	{
	Spawn:
		RNGG A 0;
		Goto See;
	See:
		FTRA C 0 A_SpawnItemEx("RS_DFlamePuffVile",random(-16,16),random(-16,16),1,0,0,0,0);
		FTRA C 0 A_RadiusGive("RS_GrowRaisin",60,RGF_MONSTERS|RGF_CORPSES,1);
		FTRA CDEFGH 8 Bright A_VileChase;
		FTRA IJ 3 A_FadeOut(0.25);
		Goto Death;
	Death:
		TNT1 A 0 A_Die;
		Stop;
	Heal:
		FTRA IJ 1 Bright;
		Goto Death;
	}
}

class RS_DFlamePuffVile : Actor   // CH Archviles.txt:4194
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 8;
		RenderStyle "Add";
		Alpha 1.25;
		Projectile;
		+FLOORHUGGER
		-NOGRAVITY
		+DONTSPLASH
		+NOINTERACTION
		+THRUACTORS
		Scale 1;
		Translation "32:47=0:0","176:191=5:8","208:223=104:111","224:231=105:105","160:167=103:103";
	}
	States
	{
	Spawn:
		FTRA A 0;
		Goto Fly;
	Fly:
		FTRA ABCDEFGHIJ 4 Bright A_SetAngle(random(-360,360));
		Stop;
	}
}

class RS_DFlameBoomVile : Actor   // CH Archviles.txt:4220
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 4;
		DamageType "Fire";
		Projectile;
		+FLOATBOB
		+THRUACTORS
		Translation "32:47=0:0","176:191=5:8","208:223=104:111","224:231=105:105","160:167=103:103";
		Scale 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		MISL B 8 Bright A_Explode(random(12,42),42);
		MISL C 6 Bright A_PlaySound("weapons/rocklx");
		MISL D 4 Bright;
		Stop;
	}
}

class RS_DFlamePuffVile2 : Actor   // CH Archviles.txt:4302
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 7;
		RenderStyle "Add";
		Alpha 1.25;
		Projectile;
		-NOGRAVITY
		+FLOATBOB
		+DONTSPLASH
		+NOINTERACTION
		+THRUACTORS
		Scale 1;
		Translation "32:47=0:0","176:191=5:8","208:223=104:111","224:231=105:105","160:167=103:103";
	}
	States
	{
	Spawn:
		FTRA A 0;
		Goto Fly;
	Fly:
		FTRA ABCDEFGHIJ 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White (tier 11) support.
// ---------------------------------------------------------------------------

class RS_VBtrail : Actor   // CH Archviles.txt:4518
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 18;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.75;
		Alpha 0.6;
		Translation "168:191=80:95","32:47=80:80","208:223=168:168","231:231=168:168","160:167=80:95","224:230=4:4";
	}
	States
	{
	Spawn:
		// sprite FBXP ships nowhere in CH -- see the header's proven-missing
		// list. Kept verbatim; CH draws nothing here either.
		FBXP ABC 3 Bright;
		Goto Death;
	Death:
		FBXP CBA 3 Bright;
		Stop;
	}
}

class RS_VBtrail2 : Actor   // CH Archviles.txt:4540
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 1;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.50;
		Alpha 0.5;
		Translation "168:191=80:95","32:47=80:80","208:223=168:168","231:231=168:168","160:167=80:95","224:230=4:4";
	}
	States
	{
	Spawn:
		MANF ABAB 6 Bright;
		Goto Death;
	Death:
		MANF A 6 Bright A_SetScale(0.5,0.3);
		MANF B 6 Bright A_SetScale(0.4,0.2);
		MANF A 6 Bright A_SetScale(0.3,0.1);
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		MANF B 6 Bright A_SetScale(0.2,0.1);
		Stop;
	}
}

class RS_VBtrail3 : RS_VBtrail2   // CH Archviles.txt:4566
{
	Default { Speed 20; }
}

class RS_VBtrail4 : Actor   // CH Archviles.txt:4568
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 1;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.30;
		Alpha 0.3;
	}
	States
	{
	Spawn:
		MANF AB 6 Bright;
		Goto Death;
	Death:
		MANF B 6 Bright A_SetScale(0.3,0.2);
		MANF A 6 Bright A_SetScale(0.2,0.1);
		MANF B 6 Bright A_SetScale(0.1,0.1);
		Stop;
	}
}

class RS_WVEyeGo : Inventory   // CH Archviles.txt:4591
{
	Default { Inventory.MaxAmount 1; }
}

class RS_WVileEye1 : Actor   // CH Archviles.txt:4593
{
	Default
	{
		Height 6;
		Radius 6;
		DamageFunction (random(10,40));
		Speed 0;
		Projectile;
		+SEEKERMISSILE
		+NOCLIP
		+SCREENSEEKER
		Scale 0.5;
		DeathSound "Forgotten/Attack";
	}
	States
	{
	Spawn:
		WVEY FGO 7;
		Goto Set;
	Set:
		WVEY P 2 A_SetScale(0.3,0.5);
		Goto Seek;
	Seek:
		// CH: A_Warp(...,0,0,0) -- the 7th arg is a statelabel; 0 -> null.
		WVEY P 1 A_Warp(AAPTR_TARGET,2,random(-24,24),random(42,78),0,WARPF_NOCHECKPOSITION|WARPF_COPYVELOCITY,null,0,0);
		WVEY P 3 A_SpawnItemEx("RS_VBtrail4",0,-3,2);
		TNT1 A 0 A_JumpIfInventory("RS_WVEyeGo",1,"Charge");
		Loop;
	Charge:
		WVEY P 1 A_FaceTracer;
		WVEY P 1 { bNoClip = false; }
		WVEY P 2 A_SetSpeed(21);
		Goto Fly;
	Fly:
		WVEY P 1 A_PlaySound("fire/fire1");
		WVEY P 1 A_SpawnItemEx("RS_VBtrail4",0,-3,2);
		WVEY P 2 A_SeekerMissile(21,30,SMF_LOOK);
		WVEY P 1 A_SpawnItemEx("RS_VBtrail4",0,-3,2);
		WVEY P 2 A_Weave(1,1,1,1);
		WVEY P 1 A_SpawnItemEx("RS_VBtrail4",0,-3,2);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(1,1);
		TNT1 AAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SSUL ABCD 4 Bright;
		Stop;
	}
}

class RS_WVileBolt1 : Actor   // CH Archviles.txt:4640
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 21;
		FastSpeed 25;
		DamageFunction (random(10,50));
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 1;
		SeeSound "baron/attack";
		DeathSound "baron/shotx";
		Translation "168:191=80:95","32:47=80:80","208:223=168:168","231:231=168:168","160:167=80:95","224:230=4:4";
	}
	States
	{
	Spawn:
		FATB A 1 Bright A_SpawnItemEx("RS_VBtrail",0,0,-1);
		FATB B 1 Bright;
		Loop;
	Death:
		TNT1 A 0 A_Explode(random(10,25),32);
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// sprite FBXP: proven missing in CH itself, see header.
		FBXP ABC 6 Bright;
		Stop;
	}
}

class RS_WVilequake : Actor   // CH Archviles.txt:4669
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 10;
		Mass 9999;
		Projectile;
		-NOGRAVITY
		RenderStyle "Add";
		Scale 1;
		Alpha 0.3;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		TNT1 A 20 Bright Radius_Quake(180,90,0,900,0);
		TNT1 A 0 A_VileTarget("RS_BrightUpVile");
		TNT1 A 20 Bright Radius_Quake(280,90,0,1200,0);
		TNT1 A 0 A_VileTarget("RS_BrightUpVile");
		TNT1 A 20 Bright Radius_Quake(300,90,0,3000,0);
		TNT1 A 0 A_VileTarget("RS_BrightUpVile");
		Stop;
	}
}

class RS_BrightUpVile : Actor   // CH Archviles.txt:4696
{
	Default
	{
		Projectile;
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		RenderStyle "Stencil";
		StencilColor "White";
		Alpha 0.95;
		DamageFunction (random(2,20));
		Scale 2;
		Speed 2;
		DeathSound "deepone/active";
		Mass 50;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto AAA;
	AAA:
		SPIR ABCDE 6 Bright A_Warp(AAPTR_TRACER,2,random(-4,4),random(32,50),0,WARPF_NOCHECKPOSITION|WARPF_COPYVELOCITY,null,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		SPIR ABCDE 6 Bright A_Warp(AAPTR_TRACER,2,random(-4,4),random(32,50),0,WARPF_NOCHECKPOSITION|WARPF_COPYVELOCITY,null,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SPIR ABCDE 6 Bright A_Warp(AAPTR_TRACER,2,random(-4,4),random(32,50),0,WARPF_NOCHECKPOSITION|WARPF_COPYVELOCITY,null,0,0);
		Goto Death;
	Death:
		SPIR ABCDE 6 Bright A_Warp(AAPTR_TRACER,2,random(-4,4),random(32,50),0,WARPF_NOCHECKPOSITION|WARPF_COPYVELOCITY,null,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_BrightUpVile2 : Actor   // CH Archviles.txt:4731
{
	Default
	{
		Projectile;
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		RenderStyle "Stencil";
		StencilColor "White";
		Alpha 0.95;
		DamageFunction (random(5,30));
		Scale 1;
		Speed 2;
		DeathSound "deepone/active";
		Mass 50;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto AAA;
	AAA:
		SPIR ABCDEABCDE 6 Bright A_Explode(random(1,3),32);
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SPIR ABCDE 6 Bright A_Explode(random(1,3),32);
		Goto Death;
	Death:
		SPIR ABCDE 6 Bright A_Explode(random(1,3),32);
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_WhiteVileResser : Actor   // CH Archviles.txt:4762
{
	Default
	{
		Health 9999;
		Monster;
		Radius 32;
		Height 1;
		Gravity 5;
		-ACTIVATEMCROSS
		-COUNTKILL
		-SHOOTABLE
		+LOOKALLAROUND
		+NOTARGET
		+NEVERTARGET
		+THRUACTORS
		+NOCLIP
		+INVISIBLE
		Damage 0;
		Speed 9;
		Scale 1.25;
		RenderStyle "Translucent";
		Alpha 0.01;
		Mass 90000;
		Translation "32:47=0:0","176:191=5:8","208:223=104:111","224:231=105:105","160:167=103:103";
	}
	States
	{
	Spawn:
		RNGG A 0;
		Goto See;
	See:
		FTRA C 0 A_RadiusGive("RS_GrowRaisin",60,RGF_MONSTERS|RGF_CORPSES,1);
		FTRA CDEFGH 12 Bright A_Chase(null,null,CHF_RESURRECT);
		FTRA IJ 3;
		Goto Death;
	Heal:
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FTRA IJ 1 Bright;
		TNT1 AAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_WVileEye2 : Actor   // CH Archviles.txt:4807 -- minion, no tier token
{
	Default
	{
		Height 12;
		Radius 8;
		Health 999;
		Speed 0;
		Monster;
		-ACTIVATEMCROSS
		-COUNTKILL
		+INVULNERABLE
		+NOBLOOD
		+LOOKALLAROUND
		+NOTARGET
		+FLOAT
		+NOGRAVITY
		+FLOATBOB
		+NOCLIP
		SeeSound "vile/active";
	}
	States
	{
	Spawn:
		WVEY FGOP 12;
		Goto Set;
	Set:
		WVEY P 10 A_SetScale(1,1);
		WVEY P 10 A_SetScale(0.9,1.0);
		WVEY P 10 A_SetScale(1,0.9);
		TNT1 A 1;
		Loop;
	Death:
		WVEY OGF 5;
		Stop;
	}
}

class RS_WVileEye3 : Actor   // CH Archviles.txt:4842 -- minion, no tier token
{
	Default
	{
		Height 12;
		Health 999;
		Radius 8;
		Speed 0;
		Monster;
		-ACTIVATEMCROSS
		-COUNTKILL
		+INVULNERABLE
		+NOBLOOD
		+LOOKALLAROUND
		+NOTARGET
		+FLOAT
		+NOGRAVITY
		+FLOATBOB
		+NOCLIP
		SeeSound "vile/active";
	}
	States
	{
	Spawn:
		WVEY ABCD 12;
		Goto Set;
	Set:
		WVEY E 10 A_SetScale(1,1);
		WVEY E 10 A_SetScale(0.9,1.0);
		WVEY E 10 A_SetScale(1,0.9);
		TNT1 A 1;
		Loop;
	Death:
		WVEY DCBA 3;
		Stop;
	}
}

class RS_WvileSpot : Actor   // CH Archviles.txt:4877 -- minion, no tier token
{
	int user_count;
	int user_ded;

	Default
	{
		Radius 12;
		Height 12;
		Health 9999;
		Speed 0;
		Mass 255;
		Monster;
		-ACTIVATEMCROSS
		-COUNTKILL
		-SHOOTABLE
		+INVULNERABLE
		+NOBLOOD
		+LOOKALLAROUND
		+NOTARGET
		+NEVERTARGET
		+THRUACTORS
		+MISSILEMORE
		+MISSILEEVENMORE
		RenderStyle "Stencil";
		StencilColor "black";
		SeeSound "Fire/fire3";
		Alpha 1;
		Scale 0.75;
	}
	States
	{
	Spawn:
		RNGG A 0;
		Goto See;
	See:
		TNT1 A 0;
		Goto Set;
	Set:
		TNT1 A 0 { user_count = (user_count == 0) ? 1 : 0; }   // CH: A_setuservar("user_count",user_count==0)
		Goto Charge;
	Charge:
		RNGG A 5 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG B 5 Bright A_Chase;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG C 5 Bright A_Chase;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG C 5 Bright A_Chase;
		RNGG D 1 Bright A_SpawnItemEx("RS_WhiteVileResser",0,0,3,0,0,0,SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_ded = user_ded + 1; }
		RNGG D 5 Bright A_JumpIf(user_ded >= 20, "Death");
		Loop;
	Missile:
		TNT1 A 0;
		Goto V1;
	V1:
		RNGG D 5 Bright A_JumpIf(user_count == 1, "V2");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye2",2,16,18,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	V2:
		RNGG D 5 Bright A_JumpIf(user_count == 2, "V3");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye3",2,-6,32,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	V3:
		RNGG D 5 Bright A_JumpIf(user_count == 3, "V4");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye2",2,48,46,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	V4:
		RNGG D 5 Bright A_JumpIf(user_count == 4, "V5");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye3",-2,-24,64,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	V5:
		RNGG D 5 Bright A_JumpIf(user_count == 5, "V6");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye2",2,32,78,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	V6:
		RNGG D 5 Bright A_JumpIf(user_count == 6, "V7");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye3",2,-32,78,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	V7:
		RNGG D 5 Bright A_JumpIf(user_count == 7, "Ded7");
		RNGG D 3 Bright A_SpawnItemEx("RS_WVileEye2",2,0,90,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		RNGG D 1 Bright { user_count = user_count + 1; }
		Goto Charge;
	Death:
		RNGG ABCD 4 Bright;
		TNT1 A 0 A_JumpIf(user_count >= 7, "Ded7");
		TNT1 A 0 A_JumpIf(user_count >= 6, "Ded6");
		TNT1 A 0 A_JumpIf(user_count >= 5, "Ded5");
		TNT1 A 0 A_JumpIf(user_count >= 4, "Ded4");
		TNT1 A 0 A_JumpIf(user_count >= 3, "Ded3");
		TNT1 A 0 A_JumpIf(user_count >= 2, "Ded2");
		TNT1 A 0 A_JumpIf(user_count >= 1, "Ded1");
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		RNGG C 0;
		Stop;
	Ded1:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG D 12 Bright A_SpawnItemEx("RS_MrBones",0,0,6);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	Ded2:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG D 12 Bright A_SpawnItemEx("RS_PurpleLSoul",0,0,6);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	Ded3:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,6);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,0);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,-6);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,-12);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,12);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	Ded4:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG D 12 Bright A_SpawnItemEx("RS_CommonRevenant",0,0,6);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	Ded5:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG D 12 Bright A_SpawnItemEx("RS_PurpleRevenant",0,0,6);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	Ded6:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG D 12 Bright A_SpawnItemEx("RS_RedRevenant",0,0,6);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	Ded7:
		RNGG C 12 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,52,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG D 12 Bright A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		RNGG C 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	}
}
