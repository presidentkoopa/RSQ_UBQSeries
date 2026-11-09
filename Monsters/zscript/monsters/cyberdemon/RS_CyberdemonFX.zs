// ============================================================================
// RS_CyberdemonFX.zs -- Colourful Hell CYBIES family: support actors,
// projectiles, minion kit and third-file externals. 2026-08-06.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\CYBIES.txt
// (6,285 lines, read whole -- the largest CH family file, 140 actors).
// Externals chased to their defining CH file:line. Bodies live in
// RS_Cyberdemon.zs.
//
// ---------------------------------------------------------------------------
// CROSS-LANE OWNERSHIP (parallel swarm, CH file order Archviles < CYBIES <
// MASTERMINDS). Externals CYBIES.txt names that CH defines in a LATER file
// would defer to this lane -- there is exactly one, RS_TrailSP2
// (CH MASTERMINDS.txt), and the zombieman lane already landed it
// (zscript/monsters/zombieman/RS_ZombiemanFX.zs:900), so it is referenced
// READ-ONLY here and NOT redefined.
// Classes built here that the MASTERMINDS lane will reference read-only:
//   RS_AbyssCybieDecoFlame  (CH MASTERMINDS.txt uses it twice)
//
// EXPECTED FROM THE ARCHVILES LANE -- referenced by name here, NOT defined,
// because Archviles.txt defines them and Archviles is the earlier lane:
//   RS_VileGroundSpike    CH Archviles.txt:1926  (RS_GrayCybie2 Missiles2)
//   RS_SplashAbyssVile2   CH Archviles.txt:1674  (RS_AbyssCybRocket Death)
// Until that lane lands, those two spawns produce nothing; every other
// reference in this family resolves today.
//
// ALREADY OWNED -- CH defines these sixteen in CYBIES.txt but earlier
// families imported them; referenced READ-ONLY here, never redefined
// (a duplicate class name is fatal, and ZScript is case-insensitive):
//   RS_MolochQuake (:4005), RS_ZapZapCB (:4410)                 demon FX
//   RS_PlasmaBallSP5 (:2351), RS_MolochNail (:3958),
//   RS_SummonPortalCybie (:3550), RS_PortalSummons (:3535),
//   RS_SpiralSaw5 (:3589), RS_GroundRedCyb (:3637)              cacodemon FX
//   RS_CyanCybieGunFlare (:1037), RS_CybieZappy (:4380),
//   RS_TrailCB (:4428)                                          revenant FX
//   RS_BluCybFX (:2494), RS_SwooshCBTR (:2618),
//   RS_SwooshCBTR2 (:2645), RS_PuffCybieRed (:3988)             earlier lanes
//   RS_Gas14 (:2326)                                            hellknight FX
// Plus the ordinary shared set: RS_Zom, RS_ZomTierToken,
// RS_ColorTierIconCH..CH13, RS_Splash11, RS_Trail12, RS_GreeniesBR,
// RS_GrowRaisin, RS_CH_Cirno, RS_BaronCyanBombTrail, RS_SpikeCyanRev,
// RS_SplashAbyss, RS_SplashAbyss2, RS_SplashAbyssBubbleDemon,
// RS_AbyssShotIdentifier, RS_WhiteFatRB3, RS_WhiteFatRB4, RS_CHBSTarget,
// RS_BaronOfDirtCH3, RS_HKRedDeath, RS_Drt1/2/3, RS_WDRock4,
// RS_FireBluCacoBall, RS_FireBluCacoBall2, RS_FireSGguy2, RS_PlasmaBallSP4,
// RS_PurpleHK, RS_SparkPuff1, RS_YellowHK, RS_CommonBaron, RS_RedThingsLS,
// RS_ZAP88, RS_WhiteFatNukeShow, RS_WhiteFatMark, RS_SpamShotsCguy,
// RS_HomingRocketTrailFatso, RS_implyingclip, RS_HealthBundle,
// RS_ArmorBundle, RS_BackPackBundle, and the RS_CH_* pickup set.
//
// ---------------------------------------------------------------------------
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, nothing substituted):
//   * Sprite SMT1 frame O -- RS_SmithGhost1 Spawn, CYBIES.txt:4524. Zero
//     SMT1* lumps in CH, CHP or here. A slip for BSMT (RS_SmithGhost2 is this
//     class character-for-character but draws BSMT O, which ships). LEFT
//     VERBATIM ON PURPOSE, because the class is dead code and the frame can
//     never render: nothing spawns SmithGhost1 in CH, nothing spawns any of
//     CHP's fifteen SmithGhost1_* variants, and nothing spawns it here.
//     Re-verified 2026-08-06 -- see the note at the class itself.
//
// RESOLVED 2026-08-06 (was listed above as proven-missing; it was neither):
//   * Sprite NULL frame A -- RS_RedSmoke Spawn, CYBIES.txt:3915. NOT a missing
//     sprite: "NULL" is CH's deliberate placeholder for "draw nothing". CH uses
//     it three times and always identically -- "NULL A <n> Bright" as the first
//     state of a Spawn, immediately followed by the real animation (RedSmoke
//     CYBIES.txt:3915, AgauresBallTrail Imps.txt:2530, RedPuff
//     thepains.txt:1763). Now TNT1 A 3 Bright, GZDoom's actual null sprite and
//     what the rest of this tree uses. Same tics, same state count. This one
//     mattered -- RS_RedSmoke is live, spawned three times in this file.
//   * Sprite BRAB frame L -- RS_RomeroBeamCH Death, CYBIES.txt:6121. A
//     transposition of BRBA on one 3-tic frame in a five-frame run whose
//     other four are BRBA. Zero BRAB* lumps in CH. Kept verbatim.
//   * Sound "weapons/onfire" -- RS_PentaFire / RS_PentaFire2, CYBIES.txt:4605
//     and :4718. Not in CH's SNDINFO and no matching lump in CH's sounds/;
//     the pentagram fire is silent in CH too.
//   * Sound "monsters/hamflr" -- RS_SmithHammer DeathSound, CYBIES.txt:4790.
//     A typo for CH's own "monster/hamflr" (SNDINFO.txt:718, singular). The
//     plural is defined nowhere; the falling hammer lands silent in CH.
//   * Sound "CybieLow" -- RS_GrayCybie2 Missiles2, CYBIES.txt:1664. CH's
//     SNDINFO defines "CybLow" (SNDINFO.txt:453) and nothing else; the
//     "CybieLow" spelling appears only at that one call site.
//   * Sound "moloch/wraithmelee" -- RS_MolochWraith Melee, CYBIES.txt:3746.
//     CH defines moloch/wraith, /wraithattack and /wraithdie but never
//     /wraithmelee.
//   * Sound members ROMDESTO and ROMTHAIL of "$random Rome/ATK2" -- CH
//     SNDINFO names them that way, but the lumps CH ships are ROMDEST0
//     (digit zero) and ROMTHATL. Two of the six members of Romero's attack
//     bark are silent in CH itself. The repo carries CH's SNDINFO line and
//     both real lumps verbatim; not touched from here.
//   * Translations BRCybGren01..05 and CYANCYB01/CYANCYB02 -- PRESENT in
//     this repo's TRNSLATE.txt (lines 281-288), and they render.
//
//     CORRECTED 2026-08-07, comment only, no code touched. This block
//     used to say they were "NOT present in this repo's TRNSLATE.txt".
//     That was true when it was written and false by the time anyone
//     read it -- they landed afterwards and nobody came back to the
//     comment. A 2026-08-07 audit read this paragraph instead of the
//     file and reported working art as missing, which is exactly the
//     failure mode this project keeps paying for.
//
//     BBCybGren06 remains a genuine CH typo and is still worth the
//     warning: CYBIES.txt:216 calls "BBCybGren06", TRNSLATE.txt defines
//     "BRCybGren06". Kept as CH wrote it, so that one A_SetTranslation
//     silently no-ops. Deliberate -- verbatim beats visible here.
//
// ---------------------------------------------------------------------------
// STRIPS, each preserved at its site as a "// CH:" comment:
//   * ACS announcers -- AnnounceCybie1, AnnounceCybie2, AnnounceBlackCybie,
//     AnnounceWhiteCybie, CybieSpecialKill (all in RS_Cyberdemon.zs).
//   * DRLA cross-mod drops -- RareArmorPool, RLXaserPowerArmorPickup,
//     RLLavaArmorPickup, RLFireStormModItem, RLDemonicWeaponSpawner,
//     RLLegendaryWeaponSpawner, RLUniqueWeaponSpawner,
//     RLOModGothicArmorPickup, BiggerThickerLonger. Itemised at each site
//     with the CH line so the table is restorable, never silently gutted.
//   * The gore chain is not used by this family at all -- CYBIES.txt names
//     no CHRandom_GibGenerator / NashGore actor. XDeath animations: this
//     family defines none.
//
// GAMEPLAY ACS, NOT AN ANNOUNCER -- proven to run in CH, so flagged loudly
// rather than quietly dropped:
//   * "CybMissile" (CHACS.acs:9) -- RS_CommonCybie Missile, CYBIES.txt:2205.
//     RESOLVED 2026-08-06 from CH's ACS SOURCE (CH\source\), which ships
//     beside the compiled acs\*.o this import originally worked from.
//     ProjInt_Brute is a leading-shot solver, BUT CybMissile passes rand=1,
//     and miscFuncs.acs:114 reads `if(rand){ random(1, sml_t); }` -- the
//     return value is discarded, so the lead time 't' stays 0 and the shot
//     collapses onto the target's CURRENT position. CH's cyberdemon does not
//     lead. The frame now fires a plain aimed Rocket at CH's own offsets,
//     which is faithful rather than a substitution. Full derivation is at
//     the call site in RS_Cyberdemon.zs.
//   * "RawketTypeCH" (CHSett.acs:9) -- RS_Rocket2 Fly, CYBIES.txt:2138. This
//     one IS reimplementable natively and has been: its whole body is
//     "if CH_Rawket == 1, set this projectile's DamageType to Normal".
//     Carried as an rs_ch_rawket read with CH's default of 1
//     (CH CVARINFO.txt:16). rs_ch_rawket is the one genuinely new cvar this
//     family needs; RS_Zom.CV returns the default until CVARINFO lands.
//
// ---------------------------------------------------------------------------
// Conversion rules applied throughout (every one from a real compile error):
// rolls -> DamageFunction (random(a,b)), never flattened, and bare constant
// Damage N stays bare; CallACS -> RS_Zom.CV('rs_ch_*', CH default) with CH's
// value semantics (1 = colour off/reroll, 3 = fifty-fifty); A_SetUserVar ->
// anonymous blocks over real members; A_ChangeFlag -> { bFLAG = x; };
// ThrustThing angle expressions wrapped in int(); +DOOMBOUNCE ->
// BounceType "Doom"; bare DONTHURTSHOOTER -> +DONTHURTSHOOTER; bracket frame
// letters quoted. Deprecation warnings (MISSILEMORE, VelX, A_CustomMissile,
// A_PlaySound, A_ChangeFlag) are CH's idiom kept verbatim, not errors.
// ============================================================================

// ---------------------------------------------------------------------------
// BROWN CYBIE ("ComposterDemon") kit.  CH: CYBIES.txt:240-735.
// ---------------------------------------------------------------------------
class RS_BrCybCheck : PowerTargeter   // CH CYBIES.txt:240
{
	Default
	{
		+INVENTORY.AUTOACTIVATE
		-INVENTORY.INVBAR
		Powerup.Duration -2;
	}
}

class RS_BCybieGreenExpand : Actor   // CH CYBIES.txt:247
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Projectile;
		+DONTBLAST
		+NOCLIP
		+DONTTHRUST
		SeeSound "";
		DeathSound "";
		RenderStyle "Add";
		Scale 1.3;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	SplashIt:
		// CH translation BRCybGren05 -- see the header: defined at CH
		// TRNSLATE.txt:16, absent from this repo's TRNSLATE.txt.
		TNT1 A 0 A_SetTranslation("BRCybGren05");
		8CYB K 3 Bright;
		8CYB K 3 Bright A_SetScale(1.4,1.4);
		8CYB K 3 Bright A_SetScale(1.5,1.5);
		8CYB K 3 Bright A_SetScale(1.6,1.6);
		8CYB K 3 Bright A_SetScale(1.7,1.7);
		Goto Death;
	Death:
		8CYB KKK 3 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_BCybieGreenWave : Actor   // CH CYBIES.txt:280
{
	Default
	{
		Radius 64;
		Height 12;
		Speed 1;
		DamageFunction (random(9,39));   // CH: Damage(random(9,39))
		DamageType "Plasma";
		Projectile;
		+FLATSPRITE
		+FLOORHUGGER
		+DONTBLAST
		+NOCLIP
		+DONTTHRUST
		SeeSound "";
		DeathSound "";
		Scale 1.5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	SplashIt:
		GR3P ABCDEFGHIJKLM 3 Bright;
		Goto Death;
	Death:
		GR3P M 1 Bright;
		GR3P M 3 Bright A_SetScale(2.0,2.0);
		GR3P M 3 Bright A_SetScale(2.5,2.5);
		GR3P MMM 3 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_BCybExplosionSet : Actor   // CH CYBIES.txt:313
{
	int user_angle;      // CH: var int user_angle;
	int user_further;    // CH: var int user_further;
	Default
	{
		Radius 8;
		Height 8;
		Speed 18;
		RenderStyle "Add";
		DamageType "plasma";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		+THRUACTORS
		+DONTTHRUST
		+DONTBLAST
		SeeSound "";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 { user_angle = user_angle + 12; }
		TNT1 A 0 { user_further = user_further + 12; }
		TNT1 A 1 A_SpawnItemEx("RS_BCybieGreenWave2",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,128);
		TNT1 A 1 Bright A_Warp(AAPTR_MASTER,user_further,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_JumpIf(user_further >= 512,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BCybExplosionSet2 : Actor   // CH CYBIES.txt:346
{
	int user_angle;
	int user_further;
	Default
	{
		Radius 8;
		Height 8;
		Speed 18;
		RenderStyle "Add";
		DamageType "plasma";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		+THRUACTORS
		+DONTTHRUST
		+DONTBLAST
		SeeSound "";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 { user_angle = user_angle - 12; }
		TNT1 A 0 { user_further = user_further + 12; }
		TNT1 A 1 A_SpawnItemEx("RS_BCybieGreenWave2",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,128);
		TNT1 A 1 Bright A_Warp(AAPTR_MASTER,user_further,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_JumpIf(user_further >= 512,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BCybExplosionSet3 : Actor   // CH CYBIES.txt:380
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 18;
		RenderStyle "Add";
		DamageType "plasma";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		+THRUACTORS
		+DONTTHRUST
		+DONTBLAST
		SeeSound "";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 6 A_SpawnItemEx("RS_BCybieGreenWave2",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BCybieGreenWave2 : Actor   // CH CYBIES.txt:408
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 1;
		DamageFunction (random(6,35));   // CH: Damage(random(6,35))
		DamageType "Plasma";
		Projectile;
		+DONTBLAST
		+NOCLIP
		+DONTTHRUST
		SeeSound "weapons/rocklx";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_PlaySound("weapons/rocklx",0);
	SplashIt:
		TNT1 A 0 A_Jump(128,"A1","A2");
		GR3P ABCDEFGHIJKLM 3 Bright A_Explode(random(5,50),128,0);
		Goto Death;
	A1:
		TNT1 A 0 A_SetScale(0.5,0.5);
		GR3P ABCDEFGHIJKLM 3 Bright A_Explode(random(5,50),64,0);
		Goto Death;
	A2:
		TNT1 A 0 A_SetScale(0.75,0.75);
		GR3P ABCDEFGHIJKLM 3 Bright A_Explode(random(5,50),96,0);
		Goto Death;
	Death:
		GR3P MMM 3 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_BCybAcidPuddle : Actor   // CH CYBIES.txt:444
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		DamageType "Plasma";
		Projectile;
		+FLATSPRITE
		+FLOORHUGGER
		+DONTBLAST
		+RIPPER
		+DONTTHRUST
		RenderStyle "Add";
		Translation "0:255=%[0.00,0.28,0.00]:[1.01,2.00,0.00]";
		Alpha 0.6;
		Scale 0.8;
		SeeSound "";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 AA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 10;
		TNT1 A 0 A_PlaySound("brownCybie/DeepShot",0);
		TNT1 AA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 10;
		SSBL A 5;
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",42,14,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",4,42,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",-42,20,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
	SplashIt:
		SSBL AB 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("monster/tenpn2",0);
		TNT1 AA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_Explode(random(1,8),64,0);
		SSBL CD 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",80,-24,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",-78,12,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",46,42,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",20,-65,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		SSBL EF 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("monster/tenpn2",0);
		TNT1 AA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_Explode(random(1,8),64,0);
		SSBL GH 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",172,164,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",162,-170,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",-156,-164,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",182,-164,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",-172,156,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",-112,180,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BCybAcidPuddle2",112,-180,random(6,6),0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death;
	Death:
		SSBL K 4 Bright A_SetScale(0.6);
		SSBL I 4 Bright A_SetScale(0.4);
		SSBL K 4 Bright A_SetScale(0.2);
		SSBL J 4 Bright A_SetScale(0.075);
		TNT1 AAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAA 0 A_SpawnItemEx("RS_GreenBalb",random(-6,6),random(-6,6),random(6,12),random(1,11),0,random(1,11),random(0,120),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_GreenBalb",random(-6,6),random(-6,6),random(6,12),random(1,11),0,random(1,11),random(120,240),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_GreenBalb",random(-6,6),random(-6,6),random(6,12),random(1,11),0,random(1,11),random(240,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_BCybAcidPuddle2 : Actor   // CH CYBIES.txt:514
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		DamageType "Plasma";
		Projectile;
		+FLATSPRITE
		+FLOORHUGGER
		+DONTBLAST
		+RIPPER
		+DONTTHRUST
		RenderStyle "Add";
		Translation "0:255=%[0.00,0.28,0.00]:[1.01,2.00,0.00]";
		Alpha 0.6;
		Scale 0.8;
		SeeSound "DEEPSHO1";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	SplashIt:
		SSBL AB 2 Bright;
		TNT1 A 0 A_PlaySound("brownCybie/DeepShot",0);
		TNT1 AA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("monster/tenpn2",0);
		TNT1 AA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_Explode(random(1,8),64,0);
		SSBL CDEF 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("monster/tenpn2",0);
		TNT1 AA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_Explode(random(1,8),64,0);
		SSBL GH 2 Bright;
		Goto Death;
	Death:
		SSBL K 4 Bright A_SetScale(0.6);
		SSBL I 4 Bright A_SetScale(0.4);
		SSBL K 4 Bright A_SetScale(0.2);
		SSBL J 4 Bright A_SetScale(0.075);
		TNT1 AAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnItemEx("RS_GreenBalb",random(-6,6),random(-6,6),random(6,12),random(1,11),0,random(1,11),random(0,120),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_GreenBalb",random(-6,6),random(-6,6),random(6,12),random(1,11),0,random(1,11),random(120,240),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_GreenBalb",random(-6,6),random(-6,6),random(6,12),random(1,11),0,random(1,11),random(240,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_GreenBalb : Actor   // CH CYBIES.txt:564
{
	Default
	{
		Radius 6;
		Height 4;
		Speed 11;
		Gravity 0.5;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		-NOGRAVITY
		RenderStyle "Add";
		Alpha 1;
		Scale 1.2;
		SeeSound "spit/spit";
		DeathSound "spit/spit2";
		Translation "168:191=112:127","208:223=112:118","250:254=112:118","168:191=112:127","32:47=120:127","144:151=125:127";
	}
	States
	{
	Spawn:
		GBLL ABC 6 Bright A_SpawnItemEx("RS_Trail12",0,0,5);
		Loop;
	Death:
		BAL2 CDE 6 Bright A_Explode(random(15,65),64);
		TNT1 AAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG A 0 A_RadiusGive("RS_GrowRaisin",60,RGF_MONSTERS|RGF_CORPSES,1);
		RNGG A 0 A_RadiusGive("health",128,RGF_MONSTERS|RGF_EXFILTER|RGF_EXSPECIES,100,"RS_BrownCybie2","Cybie");
		Stop;
	}
}

class RS_GreenBalb2 : Actor   // CH CYBIES.txt:596
{
	Default
	{
		Radius 6;
		Height 4;
		Speed 11;
		Gravity 0.2;
		DamageFunction (random(15,30));   // CH: Damage(random(15,30))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		-NOGRAVITY
		RenderStyle "Add";
		Alpha 0.9;
		Scale 0.7;
		SeeSound "spit/spit";
		DeathSound "spit/spit2";
		Translation "168:191=112:127","208:223=112:118","250:254=112:118","168:191=112:127","32:47=120:127","144:151=125:127";
	}
	States
	{
	Spawn:
		GBLL ABC 6 Bright A_SpawnItemEx("RS_Trail12",0,0,5);
		Loop;
	Death:
		BAL2 CDE 6 Bright A_Explode(random(12,24),32);
		TNT1 AAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_BrownCybBasic : Actor   // CH CYBIES.txt:626
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 25;
		DamageFunction (random(60,120));   // CH: Damage(random(60,120))
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		SeeSound "SHARPST1";
		DeathSound "shadowbeast/pr1death";
		Translation "0:255=%[0.13,0.22,0.14]:[0.79,1.34,0.28]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		MANF A 2 Bright;
		TNT1 AAA 0 A_SpawnItemEx("RS_GreeniesBR",random(-3,3),random(-3,3),random(1,3),random(2,8),0,1,random(-359,359));
		MANF B 2 Bright;
		TNT1 AAA 0 A_SpawnItemEx("RS_GreeniesBR",random(-3,3),random(-3,3),random(1,3),random(2,8),0,1,random(-359,359));
		Loop;
	Death:
		TNT1 A 0 A_SetScale(1.2,1.0);
		MISL CC 0 A_SpawnItemEx("RS_Gas14",random(-8,8),random(-8,8),random(-2,2),random(3,28),0,random(-6,6),random(0,120),SXF_NOCHECKPOSITION);
		MISL CC 0 A_SpawnItemEx("RS_Gas14",random(-8,8),random(-8,8),random(-2,2),random(3,28),0,random(-6,6),random(120,240),SXF_NOCHECKPOSITION);
		MISL CC 0 A_SpawnItemEx("RS_Gas14",random(-8,8),random(-8,8),random(-2,2),random(3,28),0,random(-6,6),random(240,359),SXF_NOCHECKPOSITION);
		MISL BCD 3 Bright A_Explode(random(10,80),128,0);
		Stop;
	}
}

class RS_BCybSlimeSet : Actor   // CH CYBIES.txt:659
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 18;
		DamageFunction (random(11,33));   // CH: Damage(random(11,33))
		RenderStyle "Add";
		DamageType "plasma";
		Alpha 0.67;
		Projectile;
		+FLOORHUGGER
		+THRUGHOST
		-NOGRAVITY
		+DONTSPLASH
		SeeSound "";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(128,"A1");
	A2:
		TNT1 A 0 { bFLOORHUGGER = true; }
		TNT1 A 1 Bright { bNOGRAVITY = true; }
		TNT1 A 0 { bFLOORHUGGER = false; }
		TNT1 A 0 { bNOGRAVITY = false; }
		TNT1 AAA 0 A_Wander;
		TNT1 A 1 Bright A_SpawnItemEx("RS_BCybSlimeSpi",0,-1,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Loop;
	A1:
		TNT1 A 0 { bSEEKERMISSILE = true; }
		TNT1 A 0 { bFLOORHUGGER = true; }
		TNT1 A 1 Bright { bNOGRAVITY = true; }
		TNT1 A 0 { bFLOORHUGGER = false; }
		TNT1 A 0 { bNOGRAVITY = false; }
		TNT1 A 1 Bright A_SpawnItemEx("RS_BCybSlimeSpi",0,-1,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		TNT1 A 1 A_SeekerMissile(3,3);
		Loop;
	XDeath:
		TNT1 AAAAA 0 A_SpawnItemEx("RS_BCybSlimeSpi",random(-32,32),random(-32,32),0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BCybSlimeSpi : Actor   // CH CYBIES.txt:707
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		DamageType "plasma";
		Alpha 0.99;
		Projectile;
		+FLOORHUGGER
		-NOGRAVITY
		+NOPAIN
		+DONTSPLASH
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_PlaySound("SWOOP001",0);
		5LPL A 3 A_SetScale(0.7,0.1);
		5LPL A 3 A_SetScale(0.8,0.5);
		5LPL A 3 A_SetScale(0.9,0.7);
		5LPL A 3 A_SetScale(1.0,1.0);
		5LPL ABCDEF 5 Bright A_Explode(random(12,24),32,0);
		5LPL F 3 A_SetScale(0.7,1.0);
		5LPL F 3 A_SetScale(0.4,0.9);
		5LPL F 3 A_SetScale(0.3,0.8);
		5LPL F 3 A_SetScale(0.1,0.7);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// CYAN CYBIE ("Akinator") kit.  CH: CYBIES.txt:944-1058.
// RS_CyanCybieGunFlare (CH :1037) is ALREADY OWNED by the revenant lane.
// ---------------------------------------------------------------------------
class RS_CyanCybieSprayIce : Actor   // CH CYBIES.txt:944
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 42;
		Mass 500;
		DamageFunction (random(3,12));   // CH: Damage(random(3,12))
		Projectile;
		DamageType "Ice";
		+THRUGHOST
		Gravity 1.5;
		Scale 0.33;
		DeathSound "";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		RIP1 ABC 8 Bright;
		Loop;
	Death:
		RIP1 A 0 { bNOGRAVITY = false; }
		RIP1 CBACBA 6 A_Explode(random(3,9),6);
		Stop;
	}
}

class RS_CyanCybieBigIce : Actor   // CH CYBIES.txt:970
{
	Default
	{
		Radius 8;
		Height 4;
		Speed 30;
		Projectile;
		+BRIGHT
		DamageType "Ice";
		DamageFunction (random(20,80));   // CH: Damage(random(20,80))
		Scale 0.15;
		SeeSound "weapons/rocklf";
		DeathSound "Bomb/boom";
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		// CH puts SXF_NOCHECKPOSITION in A_SpawnItemEx's ANGLE slot here
		// (seven numeric args, not eight). Kept exactly as CH wrote it.
		C3BB DEFGHI 2 Bright A_SpawnItemEx("RS_AbyssCybieDecoFlame",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_SetScale(1.33,1.0);
		SSBL ABCD 3 Bright;
		TNT1 A 0 A_Explode(random(20,120),128,0);
		SSBL EFGH 2 Bright;
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(16,60),0,random(2,28),random(0,90));
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(16,60),0,random(2,28),random(89,180));
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(16,60),0,random(2,28),random(181,270));
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(16,60),0,random(2,28),random(271,359));
		Stop;
	}
}

class RS_CyanCybieBigIce2 : RS_CyanCybieBigIce { Default { Speed 20; } }   // CH CYBIES.txt:1005
class RS_CyanCybieBigIce3 : RS_CyanCybieBigIce { Default { Speed 40; } }   // CH CYBIES.txt:1006

class RS_CyanCybieHower : Actor   // CH CYBIES.txt:1008
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Projectile;
		+NOINTERACTION
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.73;
		XScale 0.33;
		YScale 0.10;
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		SSBL I 3 Bright;
	Death:
		SSBL I 3 Bright;
		TNT1 A 0 A_SetScale(0.43,0.10);
		SSBL I 3 Bright A_PlaySound("FLICKER3");
		SSBL J 3 Bright A_SetScale(0.66,0.10);
		TNT1 A 0 A_SetScale(0.89,0.10);
		SSBL KKK 3 Bright A_FadeOut(0.20);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// ABYSS CYBIE ("Unholy diver") kit.  CH: CYBIES.txt:1292-1526.
// ---------------------------------------------------------------------------
class RS_AbyssCybRocket : Actor   // CH CYBIES.txt:1292
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 21;
		Damage 20;   // CH: bare constant, stays bare
		DamageType "Fire";
		Projectile;
		+SEEKERMISSILE
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		MISL A 1 Bright A_SpawnItemEx("RS_SplashAbyss2",0,0,1,3,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		MISL A 1 Bright A_SeekerMissile(2,2);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		MISL A 2 Bright A_SpawnItemEx("RS_AbyssCybieDecoFlame",-1,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		MISL B 8 Bright A_Explode;
		MISL C 6 Bright;
		MISL CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 0 A_SpawnItemEx("RS_SplashAbyss2",random(-252,252),random(-252,252),2,2,0,8,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,12),12,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		MISL D 4 Bright;
		TNT1 A 20 { bSOLID = false; }
		// RS_SplashAbyssVile2 is EXPECTED FROM THE ARCHVILES LANE
		// (CH Archviles.txt:1674).
		TNT1 AAAAA 2 A_SpawnItemEx("RS_SplashAbyssVile2",random(-528,528),random(-528,528),0,0,0,0,0);
		Stop;
	}
}

class RS_AbyCybBubProj : Actor   // CH CYBIES.txt:1327
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 28;
		DamageFunction (random(1,12));   // CH: Damage(random(1,12))
		DamageType "Plasma";
		Projectile;
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.3;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 AA 1 A_SpawnItemEx("RS_AbyCybBub",-2,random(2,64),random(-8,8),15,0,random(-3,3),random(0,90));
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AA 1 A_SpawnItemEx("RS_AbyCybBub",-2,random(-64,-2),random(-8,8),15,0,random(-3,3),random(-90,0));
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_AbyCybBub : Actor   // CH CYBIES.txt:1356
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 12;
		DamageFunction (random(1,8));   // CH: Damage(random(1,8))
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.3;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		BAL1 AB 8 Bright;
		Goto Death;
	Death:
		BAL1 CDE 6 Bright;
		TNT1 A 0 A_Explode(random(5,10),32,0);
		TNT1 AAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_AbyCybWave : Actor   // CH CYBIES.txt:1383
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 28;
		ProjectileKickBack 7000;
		DamageFunction (random(10,40));   // CH: Damage(random(10,40))
		DamageType "Melee";
		Projectile;
		+DONTHARMCLASS
		Species "Cybie";
		RenderStyle "Add";
		Alpha 0.25;
		Scale 0.45;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SSBL KKKKKKKKK 2 Bright A_SpawnItemEx("RS_AbyCybWave2",-2,0,0,16,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SSBL KKKKKKKKK 2 Bright A_SpawnItemEx("RS_AbyCybWave2",-2,0,0,16,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
	Death:
		SSBL IJ 12 Bright;
		Stop;
	}
}

class RS_AbyCybWave2 : Actor   // CH CYBIES.txt:1416
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 20;
		DamageFunction (random(4,16));   // CH: Damage(random(4,16))
		DamageType "Melee";
		Projectile;
		+DONTHARMCLASS
		Species "Cybie";
		RenderStyle "Add";
		Alpha 0.25;
		Scale 0.45;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		SSBL I 6 Bright;
	Death:
		SSBL J 12 Bright;
		Stop;
	}
}

// Referenced by the MASTERMINDS lane too -- built here under the file-order
// rule (Archviles < CYBIES < MASTERMINDS).
class RS_AbyssCybieDecoFlame : Actor   // CH CYBIES.txt:1442
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 18;
		Projectile;
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.55;
		XScale 0.55;
		YScale 0.81;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		FRFX ABCD 3 Bright;
		FRFX HIJKLMNO 2 Bright;
		Stop;
	}
}

class RS_TerminatorArm : Actor   // CH CYBIES.txt:1464
{
	Default
	{
		Radius 12;
		Height 15;
		Speed 3;
		Mass 1000;
		Scale 1.2;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		Translation "32:47=%[0.00,0.00,0.07]:[0.49,0.72,0.74]","16:31=%[0.16,0.24,0.31]:[0.36,0.71,0.72]","185:191=%[0.00,0.00,0.00]:[0.06,0.06,0.06]","80:95=%[0.05,0.15,0.17]:[0.50,0.31,0.76]","96:111=%[0.00,0.00,0.00]:[0.31,0.47,0.65]","168:191=0:0","160:167=96:111","224:231=96:111","48:63=96:111","249:249=3:3","64:79=0:2","208:223=0:0","232:235=0:0","13:15=0:0","236:239=0:0","3:3=0:0","128:143=0:0","1:2=0:0","5:8=0:0";
	}
	States
	{
	Spawn:
		TARM A 5;
		TARM B 5 A_Fall;
		TARM CDE 5;
		TARM F -1;
		Stop;
	}
}

class RS_TerminatorHead : Actor   // CH CYBIES.txt:1484
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		Mass 1000;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		+DROPOFF
		+MISSILE
		Scale 1.2;
		Translation "32:47=%[0.00,0.00,0.07]:[0.49,0.72,0.74]","16:31=%[0.16,0.24,0.31]:[0.36,0.71,0.72]","185:191=%[0.00,0.00,0.00]:[0.06,0.06,0.06]","80:95=%[0.05,0.15,0.17]:[0.50,0.31,0.76]","96:111=%[0.00,0.00,0.00]:[0.31,0.47,0.65]","168:191=0:0","160:167=96:111","224:231=96:111","48:63=96:111","249:249=3:3","64:79=0:2","208:223=0:0","232:235=0:0","13:15=0:0","236:239=0:0","3:3=0:0","128:143=0:0","1:2=0:0","5:8=0:0";
	}
	States
	{
	Spawn:
		THAD DEFGHABC 2;
		Loop;
	Death:
		THAD I -1;
		Loop;
	}
}

class RS_TerminatorShoulder : Actor   // CH CYBIES.txt:1506
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 8;
		Mass 1000;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		+DROPOFF
		+MISSILE
		Scale 1.2;
		Translation "32:47=%[0.00,0.00,0.07]:[0.49,0.72,0.74]","16:31=%[0.16,0.24,0.31]:[0.36,0.71,0.72]","185:191=%[0.00,0.00,0.00]:[0.06,0.06,0.06]","80:95=%[0.05,0.15,0.17]:[0.50,0.31,0.76]","96:111=%[0.00,0.00,0.00]:[0.31,0.47,0.65]","168:191=0:0","160:167=96:111","224:231=96:111","48:63=96:111","249:249=3:3","64:79=0:2","208:223=0:0","232:235=0:0","13:15=0:0","236:239=0:0";
	}
	States
	{
	Spawn:
		TSHO ABCDEFGH 2;
		Loop;
	Death:
		TSHO I -1;
		Loop;
	}
}

// ---------------------------------------------------------------------------
// GRAY CYBIE ("Stoner Cybie") rockslide kit.  CH: CYBIES.txt:1703-1895.
// ---------------------------------------------------------------------------
class RS_RockSlideCH1 : Actor   // CH CYBIES.txt:1703
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
		TNT1 A 2 A_Warp(AAPTR_TRACER,0,0,6,0,WARPF_NOCHECKPOSITION);
		TNT1 AAA 1 A_SpawnItemEx("RS_RockSlideDropCH",0,0,random(128,528),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 2 A_Warp(AAPTR_TRACER,0,0,6,0,WARPF_NOCHECKPOSITION);
		TNT1 AAA 1 A_SpawnItemEx("RS_RockSlideDropCH",0,0,random(128,528),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 2 A_Warp(AAPTR_TRACER,0,0,6,0,WARPF_NOCHECKPOSITION);
		TNT1 AAA 1 A_SpawnItemEx("RS_RockSlideDropCH",0,0,random(128,528),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 2 A_Warp(AAPTR_TRACER,0,0,6,0,WARPF_NOCHECKPOSITION);
		TNT1 AAA 1 A_SpawnItemEx("RS_RockSlideDropCH",0,0,random(128,528),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Jump(40,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_RockSlideCHRand : RandomSpawner   // CH CYBIES.txt:1731
{
	Default
	{
		DropItem "RS_RockSlideCH2", 255, 33;
		DropItem "RS_RockSlideCH3", 255, 33;
		DropItem "RS_RockSlideCH4", 255, 33;
		DropItem "RS_RockSlideCH5", 255, 33;
	}
}

class RS_RockSlideDropCH : Actor   // CH CYBIES.txt:1739
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
		BAL1 A 1 Bright A_SpawnItemEx("RS_RockSlideCHRand",random(-32,32),random(-32,32),-20,1,1,-1,random(-180,180),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_RockSlideCH5 : Actor   // CH CYBIES.txt:1757
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 21;
		DamageFunction (random(40,80));   // CH: Damage(Random(40,80))
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		+TOUCHY
		BounceType "Hexen";
		BounceCount 1;
		BounceFactor 0.7;
		Gravity 1.25;
		Scale 0.5;
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
		JUBD D 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD D 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD D 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		Stop;
	}
}

class RS_RockSlideCH4 : Actor   // CH CYBIES.txt:1791
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 18;
		DamageFunction (random(45,90));   // CH: Damage(Random(45,90))
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		+TOUCHY
		BounceType "Hexen";
		BounceCount 1;
		BounceFactor 0.7;
		Gravity 1.25;
		Scale 0.67;
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
		JUBD DD 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DD 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DD 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		Stop;
	}
}

class RS_RockSlideCH3 : Actor   // CH CYBIES.txt:1825
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 12;
		DamageFunction (random(55,105));   // CH: Damage(Random(55,105))
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		+TOUCHY
		BounceType "Hexen";
		BounceCount 1;
		BounceFactor 0.7;
		Gravity 1.25;
		Scale 0.8;
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
		JUBD D 1 Bright A_Explode(random(30,75),42,0);
		TNT1 AAA 0 A_CustomMissile("RS_WDRock4",32,0,random(-359,359));
		Stop;
	}
}

class RS_RockSlideCH2 : Actor   // CH CYBIES.txt:1861
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 10;
		DamageFunction (random(75,155));   // CH: Damage(Random(75,155))
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		+TOUCHY
		BounceType "Hexen";
		BounceCount 1;
		BounceFactor 0.7;
		Gravity 1.25;
		Scale 1.1;
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
		JUBD D 1 Bright A_Explode(random(60,90),52,0);
		TNT1 AA 0 A_CustomMissile("RS_WDRock4",32,0,random(-359,359));
		Stop;
	}
}

// ---------------------------------------------------------------------------
// FIREBLU CYBIE kit.  CH: CYBIES.txt:2077.
// ---------------------------------------------------------------------------
class RS_FireBluCybMiss : Actor   // CH CYBIES.txt:2077
{
	Default
	{
		Radius 20;
		Height 20;
		Mass 600;
		Speed 20;
		DamageFunction (random(20,90));   // CH: Damage(random(20,90))
		DamageType "Plasma";
		Projectile;
		+SEEKERMISSILE
		Scale 1.5;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "Crack/death";
		Translation "216:223=199:207","208:214=193:201","231:231=194:194","168:175=198:201";
	}
	States
	{
	Spawn:
		MANF A 3 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		MANF B 3 Bright A_SeekerMissile(5,2);
		Loop;
	Death:
		MISL B 4 A_SetTranslucent(0.35);
		MISL C 2 A_Explode(random(5,50),256);
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
		MISL D 3 A_Explode(random(5,50),256);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// CH's global rocket replacement.  CH: CYBIES.txt:2119 -- "Rocket2 replaces
// rocket". Carried verbatim, replaces and all, the same way earlier lanes
// carried RS_DoomImpBall2 / RS_FatShot2 / RS_ArachnotronPlasma2.
// ---------------------------------------------------------------------------
class RS_Rocket2 : Actor replaces Rocket   // CH CYBIES.txt:2119
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 20;
		Damage 20;   // CH: bare constant, stays bare
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+DEHEXPLOSION
		+ROCKETTRAIL
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
		Obituary "$OB_MPROCKET";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		// CH: ACS_NamedExecuteAlways("RawketTypeCH") -- NOT an announcer.
		// CHSett.acs:9, whole body: if CVar CH_Rawket == 1, set this
		// projectile's DamageType to "Normal". Reimplemented natively;
		// CH's default for CH_Rawket is 1 (CH CVARINFO.txt:16).
		TNT1 A 0 { if (RS_Zom.CV('rs_ch_rawket', 1) == 1) DamageType = 'Normal'; }
	Fly2:
		MISL A 1 Bright;
		Loop;
	Death:
		MISL B 8 Bright A_Explode;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// GREEN CYBIE kit.  CH: CYBIES.txt:2297.  RS_Gas14 (CH :2326) and
// RS_PlasmaBallSP5 (CH :2351) are ALREADY OWNED by earlier lanes.
// ---------------------------------------------------------------------------
class RS_SplashRocket : Actor   // CH CYBIES.txt:2297
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 20;
		Damage 17;   // CH: bare constant, stays bare
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+DEHEXPLOSION
		+ROCKETTRAIL
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
		Translation "128:143=113:127","144:151=118:127","168:191=113:127","208:223=112:121","232:235=120:125","121:127=0:0";
	}
	States
	{
	Spawn:
		// CH passes seven numeric args here, so SXF_NOCHECKPOSITION lands in
		// the ANGLE slot. Kept exactly as CH wrote it.
		MISL A 3 Bright A_SpawnItemEx("RS_Gas14",0,0,2,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		MISL B 8 Bright A_Explode;
		MISL C 6 Bright;
		MISL CCCCCCC 0 A_SpawnItemEx("RS_Gas14",random(-8,8),random(-8,8),random(-2,2),random(3,28),0,random(-6,20),random(-359,359),SXF_NOCHECKPOSITION);
		MISL D 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// BLUE CYBIE kit.  CH: CYBIES.txt:2492-2668.  RS_BluCybFX (CH :2494),
// RS_SwooshCBTR (CH :2618) and RS_SwooshCBTR2 (CH :2645) are ALREADY OWNED.
// ---------------------------------------------------------------------------
class RS_SpamComboCB : Inventory   // CH CYBIES.txt:2492
{
	Default { Inventory.MaxAmount 9; }
}

class RS_BluCybArt : Actor   // CH CYBIES.txt:2515
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		DamageFunction (random(10,60));   // CH: Damage(random(10,60))
		DamageType "Plasma";
		Projectile;
		+SEEKERMISSILE
		+EXTREMEDEATH
		+BOUNCEONWALLS
		+USEBOUNCESTATE
		BounceType "Hexen";
		BounceCount 2;
		BounceFactor 1.5;
		Scale 0.65;
		SeeSound "Litn/litn3";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 A 1 Bright A_SpawnItemEx("RS_SwooshCBTR3",0,0,3);
		BFS1 B 1 Bright A_SpawnItemEx("RS_BluCybFX",0,0,3);
		BFS1 A 1 Bright A_SeekerMissile(3,1);
		Loop;
	Bounce:
		BFS1 A 1 Bright A_SpawnItemEx("RS_SwooshCBTR3",0,0,3);
		BFS1 B 1 Bright A_SpawnItemEx("RS_BluCybFX",0,0,3);
		BFS1 A 1 Bright A_SeekerMissile(6,3);
		Loop;
	Death:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_Explode(random(20,60),102);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_SwooshCB : Actor   // CH CYBIES.txt:2555
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 36;
		DamageFunction (random(10,60));   // CH: Damage(random(10,60))
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.75;
		Scale 0.6;
		SeeSound "Litn/litn3";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 AB 1 Bright A_SpawnItemEx("RS_SwooshCBTR",0,0,3);
		Loop;
	Death:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_Explode(random(10,60),124);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_SwooshCB2 : Actor   // CH CYBIES.txt:2584
{
	Default
	{
		Radius 15;
		Height 9;
		Speed 15;
		DamageFunction (random(20,70));   // CH: Damage(random(20,70))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		+EXTREMEDEATH
		RenderStyle "Add";
		Alpha 0.95;
		Scale 0.8;
		SeeSound "Litn/litn3";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 A 1 Bright A_SpawnItemEx("RS_SwooshCBTR3",0,0,3);
		BFS1 B 2 Bright A_SpawnItemEx("RS_BluCybFX",0,0,3);
		BFS1 BBBBBBBBBBBBBBBBBB 0 A_CustomMissile("RS_PlasmaBallSP5",random(-3,3),random(-12,12),random(0,360),CMF_AIMDIRECTION,random(0,360));
		BFS1 A 1 Bright A_SeekerMissile(5,12);
		Loop;
	Death:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_Explode(random(20,70),124);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

// Parent RS_SwooshCBTR is owned by the revenant lane (CH CYBIES.txt:2618).
class RS_SwooshCBTR3 : RS_SwooshCBTR { Default { Speed 13; } }   // CH CYBIES.txt:2643

// ---------------------------------------------------------------------------
// PURPLE CYBIE kit.  CH: CYBIES.txt:2840-2989.
// ---------------------------------------------------------------------------
class RS_PurpleWorryCB : Actor   // CH CYBIES.txt:2840
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
		XScale 1.5;
		YScale 2.3;
		SeeSound "gas/gas1";
		DeathSound "weapons/rocklx";
		Translation "192:207=250:254","168:191=251:254","208:223=250:252","225:229=208:208";
	}
	States
	{
	Spawn:
		SBFX HIJKHIJK 7 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_Scream;
		MISL B 5 Bright A_SetScale(3,0.45);
		MISL C 5 Bright A_Explode(random(40,90),128);
		MISL D 5 Bright;
		Stop;
	}
}

class RS_CBWave : Actor   // CH CYBIES.txt:2869
{
	Default
	{
		Radius 10;
		Height 10;
		Speed 4;
		FastSpeed 4;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		Projectile;
		+DONTHARMCLASS
		+EXPLODEONWATER
		+FLOATBOB
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.85;
		DamageType "Fire";
		SeeSound "Fire/fire4";
		DeathSound "Spell/Impact1";
		Translation "168:223=250:254","224:231=250:250","168:191=250:254";
	}
	States
	{
	Spawn:
		SBS1 ABCD 8 Bright A_ScaleVelocity(1.5);
		Loop;
	Death:
		BAL2 C 2 Bright A_SetScale(1.1);
		BAL2 D 3 Bright A_SetTranslucent(0.4);
		BAL2 E 6 Bright A_Explode(random(5,20),88);
		Stop;
	}
}

class RS_OrbCB : Actor   // CH CYBIES.txt:2901
{
	Default
	{
		Radius 3;
		Height 4;
		Speed 125;
		DamageFunction (random(5,15));   // CH: Damage(random(5,15))
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+SEEKERMISSILE
		RenderStyle "Add";
		DeathSound "Fire/fire5";
		Alpha 0.85;
		Scale 0.3;
		Translation "16:47=250:254","48:79=250:254","80:111=250:254","128:143=250:254","144:151=253:254","152:191=250:254";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 B 0 A_SpawnItemEx("RS_OrbCB2",0,0,1);
		BAL1 A 1 Bright A_SeekerMissile(8,8);
		BAL1 B 0 A_SpawnItemEx("RS_OrbCB2",0,0,1);
		BAL1 B 1 Bright A_Weave(1,1,2,1);
		BAL1 B 0 A_SpawnItemEx("RS_OrbCB2",0,0,1);
		Loop;
	Death:
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_OrbCB2 : Actor   // CH CYBIES.txt:2934
{
	Default
	{
		Radius 3;
		Height 4;
		Speed 128;
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.3;
		Translation "16:47=250:254","48:79=250:254","80:111=250:254","128:143=250:254","144:151=253:254","152:191=250:254";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 4 Bright A_SeekerMissile(8,8);
		BAL1 B 4 Bright A_Weave(1,1,2,1);
		Goto Death;
	Death:
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_Propane : Actor   // CH CYBIES.txt:2961
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 20;
		Damage 18;   // CH: bare constant, stays bare
		Projectile;
		+RANDOMIZE
		+DEHEXPLOSION
		+ROCKETTRAIL
		+SEEKERMISSILE
		DamageType "Fire";
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
		Translation "128:143=250:254","144:151=253:254","125:127=190:191","1:1=47:47","96:96=250:250";
	}
	States
	{
	Spawn:
		MISL A 1 Bright A_SeekerMissile(4,4);
		Loop;
	Death:
		MISL B 8 Bright A_Explode(random(64,128),128);
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// YELLOW CYBIE ("Less cyber yellow Cybie") kit.  CH: CYBIES.txt:3121-3306.
// ---------------------------------------------------------------------------
class RS_CybieRainMaker : Actor   // CH CYBIES.txt:3121
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 15;
		FastSpeed 38;
		Mass 50;
		DamageFunction (random(5,40));   // CH: Damage(random(5,40))
		DamageType "Fire";
		Projectile;
		+CEILINGHUGGER
		+FLOAT
		+NOGRAVITY
		+RANDOMIZE
		+INVISIBLE
		RenderStyle "Add";
		Gravity 7;
		Alpha 1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "fire/fire5";
	}
	States
	{
	Spawn:
		STRS AB 2 Bright A_SpawnItemEx("RS_CybieRain",random(-400,400),random(-400,400),-32,random(-15,15),random(-15,15),1,SXF_NOCHECKPOSITION);
		STRS CD 2 Bright A_SpawnItemEx("RS_CybieRain",random(-700,700),random(-700,700),-32,random(-15,15),random(-15,15),1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(10,40),108);
		BBOM EFG 6 Bright A_Explode(random(10,45),108);
		Stop;
	}
}

class RS_CybieRain : Actor   // CH CYBIES.txt:3158
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		FastSpeed 15;
		Mass 50;
		DamageFunction (random(15,50));   // CH: Damage(random(15,50))
		DamageType "Fire";
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Gravity 5;
		Alpha 1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "fire/fire5";
	}
	States
	{
	Spawn:
		STRS AB 2 Bright A_SeekerMissile(3,3);
		STRS CD 2 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(10,30),108);
		BBOM EFG 6 Bright A_Explode(random(5,30),108);
		Stop;
	}
}

class RS_GlowBack : Actor   // CH CYBIES.txt:3193
{
	Default
	{
		Radius 16;
		Height 12;
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Speed 15;
		FloatSpeed 30;
		Scale 0.65;
		Alpha 0.85;
	}
	States
	{
	Spawn:
		BBOM B 1 Bright;
		BBOM B 3 Bright A_SetScale(0.5);
		BBOM B 2 Bright;
		BBOM B 3 Bright A_SetScale(0.65);
		BBOM B 1 Bright;
		Stop;
	}
}

class RS_Vollrey2 : Actor   // CH CYBIES.txt:3218
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 27;
		FastSpeed 38;
		DamageFunction (random(10,60));   // CH: Damage(random(10,60))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.15;
		SeeSound "Forgotten/Attack";
		DeathSound "spell/Impact1";
		Translation "168:191=220:223";
	}
	States
	{
	Spawn:
		FRGO CC 2 Bright;
		FRGO DD 2 Bright A_CustomMissile("RS_GlowBack",8,0);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1.5);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,25),148);
		BBOM EFG 6 Bright A_Explode(random(5,20),148);
		Stop;
	}
}

class RS_Vollrey : Actor   // CH CYBIES.txt:3250
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 27;
		FastSpeed 38;
		DamageFunction (random(10,50));   // CH: Damage(random(10,50))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.15;
		SeeSound "Forgotten/Attack";
		DeathSound "spell/Impact1";
		Translation "168:191=220:223";
	}
	States
	{
	Spawn:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
		FRGO DD 2 Bright A_CustomMissile("RS_GlowBack",8,0);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1.5);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,25),148);
		BBOM EFG 6 Bright A_Explode(random(5,20),148);
		Stop;
	}
}

class RS_SuperDemonArm : Actor   // CH CYBIES.txt:3283
{
	Default
	{
		Radius 10;
		Height 8;
		Speed 1;
		Damage 1;   // CH: bare constant, stays bare
		Scale 1;
		Projectile;
		-NOGRAVITY
		Gravity 0.125;   // was +LOWGRAVITY (engine sets Gravity = 1/8)
		Translation "48:63=210:219","64:68=219:223","69:74=181:189","76:79=44:47";
	}
	States
	{
	Spawn:
		SUPH A 5 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPH B 5 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPH C 5 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		Goto Death;
	Death:
		SUPH D 5 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPH E -1 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		Stop;
	}
}

// ---------------------------------------------------------------------------
// RED CYBIE ("Red Overlord") kit.  CH: CYBIES.txt:3608-4030.
// RS_PortalSummons (:3535), RS_SummonPortalCybie (:3550), RS_SpiralSaw5
// (:3589), RS_GroundRedCyb (:3637), RS_MolochNail (:3958),
// RS_PuffCybieRed (:3988) and RS_MolochQuake (:4005) are ALREADY OWNED.
// RS_MolochWraith (:3692) is a monster and lives in RS_Cyberdemon.zs.
// ---------------------------------------------------------------------------
class RS_SoulBomb4 : Actor   // CH CYBIES.txt:3608
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 12;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(10,70));   // CH: Damage(random(10,70))
		DamageType "Melee";
		Alpha 0.75;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		RED9 B 1 Bright A_SeekerMissile(1,1);
		RED9 AA 1 Bright A_SpawnItemEx("RS_SpiralSaw5",0,0,0,0,0,0,0,128);
		RED9 A 0 A_CustomMissile("RS_GroundRedCyb",0,0);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(2);
		SPIR ABCDEDCBA 5 Bright A_SpawnItemEx("RS_RedCybieSouls",random(-128,128),random(-128,128),random(-5,20),0,0,0,0,SXF_NOCHECKPOSITION);
		SPIR E 1;
		Stop;
	}
}

class RS_RedCybieSouls : Actor   // CH CYBIES.txt:3668
{
	Default
	{
		Radius 1;
		Height 1;
		Species "BaronOfHell";
		Speed 3;
		Projectile;
		+DONTHARMCLASS
		+DONTHARMSPECIES
		RenderStyle "Add";
		Alpha 0.80;
		DamageType "Plasma";
		Translation "112:127=176:191";
		SeeSound "skull/melee";
		DeathSound "Forgotten/Attack";
	}
	States
	{
	Spawn:
		BFX1 ABCD 6 Bright A_Explode(random(5,15),32);
		BFX1 D 3 A_SpawnItemEx("RS_MolochWraith",0,0,12);
		Stop;
	}
}

class RS_RedCybieVolcano2 : Actor   // CH CYBIES.txt:3759
{
	int user_uptime;   // CH: var int user_uptime;
	Default
	{
		Radius 6;
		Height 8;
		Speed 1;
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
		Alpha 0.95;
		XScale 0.75;
		YScale 1.5;
	}
	States
	{
	Spawn:
		RED8 ABC 8 Bright A_PlaySound("Spell/SpellCast1");
		RED8 FGH 8 Bright;
		Goto Startle;
	Startle:
		RED8 ABC 6 Bright A_CustomMissile("RS_VolcanoBall1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		RED8 FGH 6 Bright A_CustomMissile("RS_VolcanoBall1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		RED8 D 0 { user_uptime = user_uptime + 2; }
		RED8 D 0 A_JumpIf(user_uptime >= 33,"Death");
		RED8 A 1;
		Loop;
	Death:
		RED8 ABCD 4 Bright A_SetScale(1);
		MISL BC 4 A_Explode(random(20,80),128);
		MISL D 2;
		Stop;
	}
}

class RS_VolcanoBall2 : Actor   // CH CYBIES.txt:3803
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 16;
		Scale 1.45;
		DamageFunction (random(10,40));   // CH: Damage(random(10,40))
		Projectile;
		RenderStyle "Add";
		Alpha 0.90;
		Decal "DoomImpScorch";
		DamageType "Fire";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		-NOGRAVITY
		+BOUNCEONWALLS
		+SEEKERMISSILE
		BounceType "Doom";
		BounceCount 7;
		Gravity 0.5;
		BounceFactor 1.1;
		BounceSound "Bomb/bounce";
		SeeSound "imp/attack";
		DeathSound "moloch/emberexp";
	}
	States
	{
	Spawn:
		BAL3 AB 2 Bright A_SpawnItemEx("RS_RedSmoke",0,0,0,0,0,0,0,2);
		BAL2 A 0 A_SeekerMissile(4,8);
		Loop;
	Death:
		BAL3 CDE 4 Bright A_Explode(random(11,33),108);
		Stop;
	}
}

class RS_VolcanoBall3 : Actor   // CH CYBIES.txt:3839
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 16;
		Scale 1.45;
		DamageFunction (random(10,40));   // CH: Damage(random(10,40))
		Projectile;
		RenderStyle "Add";
		Alpha 0.90;
		Decal "DoomImpScorch";
		DamageType "Fire";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		-NOGRAVITY
		+BOUNCEONWALLS
		BounceType "Doom";
		BounceCount 7;
		Gravity 0.5;
		BounceFactor 1.1;
		BounceSound "Bomb/bounce";
		SeeSound "imp/attack";
		DeathSound "moloch/emberexp";
	}
	States
	{
	Spawn:
		BAL3 AB 2 Bright A_SpawnItemEx("RS_RedSmoke",0,0,0,0,0,0,0,2);
		Loop;
	Death:
		BAL3 CDE 4 Bright A_Explode(random(12,45),108);
		Stop;
	}
}

class RS_VolcanoBall1 : Actor   // CH CYBIES.txt:3873
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 18;
		DamageFunction (random(5,35));   // CH: Damage(random(5,35))
		Projectile;
		RenderStyle "Add";
		Alpha 0.90;
		Decal "DoomImpScorch";
		DamageType "Fire";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		-NOGRAVITY
		+BOUNCEONWALLS
		BounceType "Doom";
		BounceCount 4;
		BounceFactor 0.85;
		SeeSound "imp/attack";
		DeathSound "moloch/emberexp";
	}
	States
	{
	Spawn:
		BAL3 AB 2 Bright A_SpawnItemEx("RS_RedSmoke",0,0,0,0,0,0,0,2);
		Loop;
	Death:
		BAL3 CDE 4 Bright A_Explode(random(5,10),88);
		Stop;
	}
}

class RS_RedSmoke : Actor   // CH CYBIES.txt:3904
{
	Default
	{
		Radius 0;
		Height 1;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
	}
	States
	{
	Spawn:
		// CH: NULL A -- deliberate placeholder meaning "draw nothing", not a
		// missing sprite. CH uses the idiom exactly three times and always
		// identically: "NULL A <n> Bright" as the FIRST state of a Spawn,
		// immediately followed by the real animation -- here (CYBIES.txt:3915),
		// AgauresBallTrail (Imps.txt:2530) and RedPuff (thepains.txt:1763).
		// It is a lead-in delay so the puff lags a beat behind its spawner.
		// TNT1 A is GZDoom's actual null sprite and what the rest of this tree
		// uses for invisible frames. Same tic count, same state count.
		// Fixed 2026-08-06 (owner: nothing invisible).
		TNT1 A 3 Bright;
		FBL1 CDEFG 1 Bright;
		Stop;
	}
}

class RS_RedCybieVolcano1 : Actor   // CH CYBIES.txt:3921
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		Mass 25;
		Projectile;
		+FLOORHUGGER
		+BOUNCEONACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		+INVISIBLE
		BounceCount 999;
		BounceType "Doom";
		DamageType "Fire";
		BounceFactor 1;
		WallBounceFactor 1.5;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.8;
		XScale 1.2;
		YScale 0.5;
	}
	States
	{
	Spawn:
		RED8 ABCFGH 3 Bright A_Wander;
		RED8 A 1 A_Jump(24,"Death");
		Loop;
	Death:
		RED8 ABCD 4 Bright A_SetScale(0.5);
		RED8 CDE 4 A_SpawnItemEx("RS_RedCybieVolcano2",random(-328,328),random(-328,328),3,0,0,0);
		RED8 CDE 1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// BLACK CYBIE ("He Will Smith You") kit.  CH: CYBIES.txt:4454-5166.
// RS_CybieZappy (:4380), RS_ZapZapCB (:4410) and RS_TrailCB (:4428) are
// ALREADY OWNED by the revenant and demon lanes.
// ---------------------------------------------------------------------------
class RS_ZappersCB : Actor   // CH CYBIES.txt:4454
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 15;
		FastSpeed 38;
		Mass 50;
		DamageFunction (random(5,35));   // CH: Damage(random(5,35))
		DamageType "Plasma";
		Projectile;
		+CEILINGHUGGER
		+FLOAT
		+NOGRAVITY
		+RANDOMIZE
		+INVISIBLE
		RenderStyle "Add";
		Gravity 7;
		Alpha 1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "fire/fire5";
	}
	States
	{
	Spawn:
		STRS AAAAAA 0 A_Wander;
		STRS AA 1 Bright A_SpawnItemEx("RS_CybieZappy",random(-400,400),random(-400,400),-32,random(-15,15),random(-15,15),1,SXF_NOCHECKPOSITION);
		STRS AA 1 Bright A_SpawnItemEx("RS_CybieZappy",random(-700,700),random(-700,700),-32,random(-15,15),random(-15,15),1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(3,21),108);
		BBOM EFG 6 Bright A_Explode(random(3,21),108);
		Stop;
	}
}

class RS_SmithFire : Actor   // CH CYBIES.txt:4492
{
	Default
	{
		Radius 2;
		Height 2;
		Damage 0;   // CH: bare constant, stays bare
		+NOCLIP
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "Weapons/hellex";
	}
	States
	{
	Spawn:
		MNSM ABCDEFGHIJKLMNOPQ 3 Bright;
		Stop;
	}
}

// DEAD CODE -- DOCUMENTED, NOT FIXED. Re-verified 2026-08-06.
// SMT1 has zero lumps in CH, in CHP and in this repo. It is a slip for BSMT:
// RS_SmithGhost2 below is this class character-for-character except that it
// draws "BSMT O", and BSMT ships O1-O8 (sprites/monsters/Cyberdemon/T11,
// CH sprites/WillSmith). But the frame can never render, because nothing
// spawns this class:
//   * CH -- "SmithGhost1" occurs exactly once in the whole tree, its own
//     definition line (CYBIES.txt:4511). SmithGhost2 is what the black boss
//     actually spawns, eight times (CYBIES.txt:4218-4225).
//   * CHP -- defines fifteen SmithGhost1_* colour variants
//     (DECORATE/17/17_K.txt:5243+) and spawns none of them; its spawn calls
//     are all SmithGhost2_C/_G/_B.
//   * here -- RS_SmithGhost1 appears only at its own definition.
// So SMT1 is left verbatim ON PURPOSE. Retargeting it to BSMT would be an
// unverifiable guess about art that never reaches the screen, and it would
// erase the evidence that CH's own actor was never wired up. If anything ever
// spawns RS_SmithGhost1, change SMT1 -> BSMT at that point and not before.
class RS_SmithGhost1 : Actor   // CH CYBIES.txt:4511
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		DamageFunction (random(12,34));   // CH: Damage(random(12,34))
		DamageType "Melee";
		RenderStyle "Translucent";
		Alpha 0.5;
		Projectile;
	}
	States
	{
	Spawn:
		SMT1 O 35;
		SMT1 O 2 A_FadeOut(0.10);
		Goto Spawn+1;
	}
}

class RS_SmithGhost2 : Actor   // CH CYBIES.txt:4530
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		DamageFunction (random(12,34));   // CH: Damage(random(12,34))
		DamageType "Melee";
		RenderStyle "Translucent";
		Alpha 0.5;
		Projectile;
	}
	States
	{
	Spawn:
		BSMT O 35;
		BSMT O 2 A_FadeOut(0.10);
		Goto Spawn+1;
	}
}

class RS_PentaLine1 : Actor   // CH CYBIES.txt:4549
{
	Default
	{
		Radius 0;
		Height 32;
		Speed 200;
		RenderStyle "None";
		Alpha 0.85;
		Projectile;
		+FLOORHUGGER
		+NOCLIP
		SeeSound "weapons/diasht";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A 0 A_CustomMissile("RS_PentaLine2",0,0,-198,2);
		TNT1 A 0 A_CustomMissile("RS_PentaLine2",0,0,198,2);
		Stop;
	}
}

class RS_PentaLine2 : Actor   // CH CYBIES.txt:4570
{
	Default
	{
		Radius 0;
		Height 32;
		Speed 16;
		RenderStyle "None";
		Alpha 0.85;
		Projectile;
		+FLOORHUGGER
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 AAAAAAAAAAAAAAAA 1 A_SpawnItem("RS_PentaFire",0,0);
		Stop;
	}
}

class RS_PentaFire : Actor   // CH CYBIES.txt:4588
{
	Default
	{
		Radius 0;
		Height 32;
		Speed 0;
		DamageType "fire";
		RenderStyle "Add";
		Alpha 0.85;
		ReactionTime 2;
		Projectile;
		+FLOORHUGGER
		+DONTSPLASH
		-NOGRAVITY
	}
	States
	{
	Spawn:
		CFCF A 1 Bright A_Explode(1,32,1);
		// PROVEN MISSING IN CH: "weapons/onfire" is in no CH SNDINFO entry and
		// no CH lump. Silent in CH too; kept verbatim.
		CFCF A 2 Bright A_PlaySound("weapons/onfire");
		CFCF BCDEFGHIJKLM 3 Bright A_Explode(1,32,1);
		CFCF A 0 A_CountDown;
		Loop;
	Death:
		CFCF NOP 3 Bright A_Explode(2,32,1);
		Stop;
	}
}

class RS_SmithDFSpawner : Actor   // CH CYBIES.txt:4615
{
	Default
	{
		Radius 0;
		Height 1;
		Speed 0;
		Damage 0;   // CH: bare constant, stays bare
		RenderStyle "None";
		ReactionTime 300;
		Alpha 0.5;
		Projectile;
		+NOEXPLODEFLOOR
	}
	States
	{
	Spawn:
		TNT1 A 1 A_CustomMissile("RS_SmithDeathFire",0,0,0,2,90);
		TNT1 A 0 A_CountDown;
		Loop;
	Death:
		TNT1 A 1;
		Stop;
	}
}

class RS_SmithDeathFire : Actor   // CH CYBIES.txt:4638
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 16;
		Damage 1;   // CH: bare constant, stays bare
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Scale 2.0;
		SeeSound "weapons/bigbrn";
		+NOCLIP
		+DONTSPLASH
	}
	States
	{
	Spawn:
		FRFX JKLMNOP 2 Bright;
		Stop;
	Death:
		TNT1 A 1;
		Stop;
	}
}

class RS_PentaLine3 : Actor   // CH CYBIES.txt:4663
{
	Default
	{
		Radius 0;
		Height 32;
		Speed 200;
		RenderStyle "None";
		Alpha 0.85;
		Projectile;
		+FLOORHUGGER
		+NOCLIP
		SeeSound "weapons/diasht";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 A 0 A_CustomMissile("RS_PentaLine4",0,0,-198,2);
		TNT1 A 0 A_CustomMissile("RS_PentaLine4",0,0,198,2);
		Stop;
	}
}

class RS_PentaLine4 : Actor   // CH CYBIES.txt:4684
{
	Default
	{
		Radius 0;
		Height 32;
		Speed 16;
		RenderStyle "None";
		Alpha 0.85;
		Projectile;
		+FLOORHUGGER
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 AAAAAAAAAAAAAAAA 1 A_SpawnItem("RS_PentaFire2",0,0);
		Stop;
	}
}

class RS_PentaFire2 : Actor   // CH CYBIES.txt:4702
{
	Default
	{
		Radius 0;
		Height 32;
		Speed 0;
		RenderStyle "Add";
		Alpha 0.85;
		ReactionTime 7;
		Projectile;
		+FLOORHUGGER
		+DONTSPLASH
		-NOGRAVITY
	}
	States
	{
	Spawn:
		CFCF A 1 Bright A_Explode(1,32,1);
		// PROVEN MISSING IN CH: "weapons/onfire", see RS_PentaFire.
		CFCF A 2 Bright A_PlaySound("weapons/onfire");
		CFCF BCDEFGHIJKLM 3 Bright A_Explode(1,32,1);
		CFCF A 0 A_CountDown;
		Loop;
	Death:
		CFCF NOP 3 Bright A_Explode(1,32,1);
		Stop;
	}
}

class RS_STracer : Actor   // CH CYBIES.txt:4728
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 15;
		DamageFunction (random(11,33));   // CH: Damage(random(11,33))
		RenderStyle "Add";
		DamageType "fire";
		Alpha 0.67;
		Projectile;
		+FLOORHUGGER
		+THRUGHOST
		-NOGRAVITY
		+DONTSPLASH
		SeeSound "weapons/diasht";
		DeathSound "weapons/firex3";
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_CStaffMissileSlither;
		TNT1 A 0 A_SpawnItem("RS_STracerPuff",0,0);
		Loop;
	Death:
		FTRA K 4 Bright;
		FTRA L 4 Bright A_Explode(random(5,15),64);
		FTRA MNO 3 Bright;
		Stop;
	}
}

class RS_STracerPuff : Actor   // CH CYBIES.txt:4758
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		RenderStyle "Add";
		DamageType "fire";
		Alpha 0.67;
		Projectile;
		ExplosionRadius 8;
		ExplosionDamage 2;
		+FLOORHUGGER
		-NOGRAVITY
		+DONTSPLASH
	}
	States
	{
	Spawn:
		FTRA ABCDEFGHIJ 3 Bright;
		Stop;
	}
}

class RS_SmithHammer : Actor   // CH CYBIES.txt:4780
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 2;
		Damage 0;   // CH: bare constant, stays bare
		RenderStyle "Normal";
		Projectile;
		-NOGRAVITY
		Gravity 0.125;   // was +LOWGRAVITY (engine sets Gravity = 1/8)
		// PROVEN MISSING IN CH: "monsters/hamflr" (plural) is a typo for CH's
		// own "monster/hamflr" (CH SNDINFO.txt:718). The plural spelling is
		// defined nowhere in CH; the hammer lands silent there too.
		DeathSound "monsters/hamflr";
	}
	States
	{
	Spawn:
		MAUL A 3;
		MAUL B 4;
		MAUL C 5;
		Goto Spawn+2;
	Death:
		MAUL D -1;
		Stop;
	}
}

class RS_BigHellshot : Actor   // CH CYBIES.txt:4804
{
	Default
	{
		Radius 12;
		Height 20;
		Speed 7;
		DamageFunction (random(40,180));   // CH: Damage(random(40,180))
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.95;
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		Decal "Scorch";
		Scale 1.75;
	}
	States
	{
	Spawn:
		HEPA ABCDEF 8 Bright A_SpawnItemEx("RS_RedPuff2",0,0,0,0,0,0,0,8);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,15,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,30,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,45,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,60,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,75,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,90,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,105,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,120,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,135,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,150,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,165,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,180,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,195,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,210,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,225,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,240,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,255,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,270,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,285,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,300,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,315,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,330,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,345,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,0,0);
		Loop;
	Death:
		HELX A 3 Bright;
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,0,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,45,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,90,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,135,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,180,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,225,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,270,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,315,6);
		HELX B 3 Bright A_Explode(random(20,80),128);
		HELX CDEFGHIJ 3 Bright;
		HELX J 0 A_SpawnItemEx("RS_HellWaver2",0,0,0);
		Stop;
	}
}

class RS_HellWaver2 : Actor   // CH CYBIES.txt:4865
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 25;
		DamageFunction (random(40,120));   // CH: Damage(random(40,120))
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.95;
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		Decal "Scorch";
	}
	States
	{
	Spawn:
		HADE LKJI 6;
		Goto WaveIt;
	WaveIt:
		HEPA ABCDE 7;
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,15,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,30,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,45,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,60,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,75,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,90,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,105,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,120,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,135,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,150,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,165,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,180,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,195,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,210,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,225,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,240,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,255,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,270,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,285,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,300,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,315,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,330,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,345,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,0,0);
		HEPA F 5;
		HEPA ABCDE 7;
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,15,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,30,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,45,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,60,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,75,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,90,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,105,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,120,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,135,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,150,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,165,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,180,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,195,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,210,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,225,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,240,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,255,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,270,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,285,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,300,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,315,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,330,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,345,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,0,0);
		HEPA F 5;
		HEPA ABCDE 7;
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,15,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,30,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,45,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,60,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,75,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,90,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,105,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,120,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,135,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,150,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,165,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,180,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,195,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,210,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,225,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,240,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,255,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,270,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,285,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,300,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,315,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,330,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,345,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,0,0);
		HEPA F 5 A_Jump(128,"WaveIt");
		Goto Death;
	Death:
		HADE IJKL 8;
		Stop;
	}
}

class RS_HellWaver : Actor   // CH CYBIES.txt:4970
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 25;
		DamageFunction (random(40,120));   // CH: Damage(random(40,120))
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.95;
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		Decal "Scorch";
	}
	States
	{
	Spawn:
		HADE LKJI 6;
		Goto WaveIt;
	WaveIt:
		HEPA ABCDE 2;
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,15,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,30,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,45,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,60,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,75,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,90,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,105,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,120,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,135,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,150,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,165,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,180,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,195,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,210,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,225,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,240,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,255,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,270,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,285,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,300,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,315,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,330,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,345,0);
		HEPA F 0 A_CustomMissile("RS_STracer",0,0,0,0);
		HEPA F 5 A_Jump(128,"WaveIt");
		Goto Death;
	Death:
		HADE IJKL 8;
		Stop;
	}
}

class RS_HammerShot : Actor   // CH CYBIES.txt:5023
{
	Default
	{
		Radius 9;
		Height 14;
		Speed 32;
		Scale 1.45;
		DamageFunction (random(30,140));   // CH: Damage(random(30,140))
		Projectile;
		DamageType "Fire";
		Alpha 0.95;
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FHFX A 0 A_PlaySound("Ice/Fly");
		FHFX ABCD 2;
		FHFX D 0 A_Jump(64,"Swoop");
		FHFX D 0 A_PlaySound("Ice/Fly");
		FHFX EFGH 2;
		FHFX A 0 A_Jump(32,"Reverse");
		Loop;
	Swoop:
		FHFX BCD 0 A_Stop;
		FHFX BCD 0 A_SetAngle(angle + random(-60,60));
		FHFX BCD 0 ThrustThing(int(angle*256/360),9,0,0);   // CH: ThrustThing(angle*256/360,9,0,0)
		FHFX B 0 A_Jump(34,"Reverse");
		Goto Spawn;
	Reverse:
		FHFX A 0 A_ChangeVelocity(-25,0,-vel.z,CVF_RELATIVE|CVF_REPLACE);
		FHFX A 0 A_PlaySound("Ice/Fly");
		FHFX ABCD 2;
		FHFX D 0 A_PlaySound("Ice/Fly");
		FHFX EFGH 2;
		Goto Whee;
	Whee:
		FHFX A 0 A_PlaySound("Ice/Fly");
		FHFX ABCD 2;
		FHFX D 0 A_PlaySound("Ice/Fly");
		FHFX EFGH 2;
		Loop;
	Death:
		FHFX IJKLMNOPQR 3 Bright A_Explode(random(2,14),128);
		Stop;
	}
}

class RS_Hellshot2 : Actor   // CH CYBIES.txt:5072
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 25;
		DamageFunction (random(40,120));   // CH: Damage(random(40,120))
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.95;
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+THRUGHOST
		Decal "Scorch";
	}
	States
	{
	Spawn:
		HEPA ABCDEF 3 Bright A_SpawnItemEx("RS_RedPuff2",0,0,0,0,0,0,0,8);
		Loop;
	Death:
		HELX A 3 Bright;
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,0,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,45,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,90,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,135,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,180,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,225,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,270,6);
		HELX B 0 A_CustomMissile("RS_HellBoom",0,0,315,6);
		HELX B 3 Bright A_Explode(random(20,80),128);
		HELX CDEFGHIJ 3 Bright;
		HELX J 0 A_SpawnItemEx("RS_HellWaver",0,0,0);
		Stop;
	}
}

class RS_HellBoom : Actor   // CH CYBIES.txt:5108
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 6;
		Damage 0;   // CH: bare constant, stays bare
		Projectile;
		RenderStyle "Add";
		DontHurtShooter true;   // was +DONTHURTSHOOTER -- engine declares it as a PROPERTY (actor.zs:310), not a flag
		+RIPPER
		+THRUGHOST
		+BLOODLESSIMPACT
		SeeSound "weapons/firex3";
		Alpha 0.80;
	}
	States
	{
	Spawn:
		TNT1 AAAAA 6 A_SpawnItem("RS_HellFX",0,0);
		Stop;
	}
}

class RS_HellFX : Actor   // CH CYBIES.txt:5130
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 0;
		Damage 0;   // CH: bare constant, stays bare
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.80;
		SeeSound "weapons/firex3";
	}
	States
	{
	Spawn:
		HELX A 3 Bright;
		HELX B 3 Bright A_Explode(random(5,40),96,0);
		HELX CDEFGHIJ 3 Bright;
		Stop;
	}
}

class RS_RedPuff2 : Actor   // CH CYBIES.txt:5151
{
	Default
	{
		Radius 0;
		Height 1;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
	}
	States
	{
	Spawn:
		TNT1 A 3 Bright;
		RPUF ABCDE 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// WHITE CYBIE ("It runs doom") kit.  CH: CYBIES.txt:5861-6285.
// ---------------------------------------------------------------------------
class RS_RomeroCHProtect : PowerProtection   // CH CYBIES.txt:5861
{
	Default
	{
		DamageFactor 0.5;
		Powerup.Duration -15;
	}
}

class RS_RomeroCHWeak : PowerProtection   // CH CYBIES.txt:5867
{
	Default
	{
		DamageFactor 1.25;
		Powerup.Duration -3;
	}
}

class RS_RomeroCHScatter : Actor   // CH CYBIES.txt:5873
{
	Default
	{
		Radius 7;
		Height 7;
		Speed 38;
		DamageFunction (random(20,90));   // CH: Damage(random(20,90))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		+THRUSPECIES
		Species "Daikatana";
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.95;
		SeeSound "ELECTRO8";
		DeathSound "Crack/death";
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		SPER A 1 Bright A_SpawnItemEx("RS_TrailSPRomero",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		SPER B 1 Bright;
		Loop;
	Death:
		TNT1 AAAAA 0 A_SpawnItemEx("RS_TrailSPRomero",0,0,0,random(12,33),0,random(-15,15),random(1,135),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_TrailSPRomero",0,0,0,random(12,33),0,random(-15,15),random(136,270),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_TrailSPRomero",0,0,0,random(12,33),0,random(-15,15),random(271,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_RomeroCHSeekBall : Actor   // CH CYBIES.txt:5908
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 30;
		DamageFunction (random(20,90));   // CH: Damage(random(20,90))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		+DONTHARMCLASS
		+THRUSPECIES
		Species "Daikatana";
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.85;
		SeeSound "ELECTRO8";
		DeathSound "Crack/death";
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		SPER AB 10 Bright;
	Fly2:
		SPER A 1 Bright A_SpawnItemEx("RS_TrailSPRomero",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		SPER B 1 Bright A_SeekerMissile(6,12);
		Loop;
	Death:
		TNT1 AAAAA 0 A_SpawnItemEx("RS_TrailSPRomero",0,0,0,random(6,20),0,random(-15,15),random(1,135),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_TrailSPRomero",0,0,0,random(6,20),0,random(-15,15),random(136,270),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_TrailSPRomero",0,0,0,random(6,20),0,random(-15,15),random(271,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_TrailSPRomero : Actor   // CH CYBIES.txt:5946
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 22;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		+THRUSPECIES
		Species "Daikatana";
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.55;
		Decal "ArachnotronScorch";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		SPPL AB 2 Bright A_SpawnItemEx("RS_TrailSP2",0,0,2);
		Goto Death;
	Death:
		APBX ABCDE 4 Bright A_Explode(10,32);
		Stop;
	}
}

class RS_SpamShotsRomeroCH : Actor   // CH CYBIES.txt:5975
{
	Default
	{
		Radius 14;
		Height 10;
		Speed 25;
		DamageFunction (random(50,150));   // CH: Damage(random(50,150))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		+DONTHARMCLASS
		+THRUSPECIES
		Species "Daikatana";
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.82;
		SeeSound "weapons/bfgf";
		DeathSound "weapons/bfgx";
		// CH names the VANILLA ammo classes here, not its own CH_ set. Kept.
		DropItem "Clip", 64;
		DropItem "Shell", 42;
		DropItem "RocketAmmo", 32;
		DropItem "Cell", 12;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BFS1 A 2 Bright A_SpawnItemEx("RS_RomeroBeamCHTrail2",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BFS1 B 2 Bright A_SeekerMissile(7,6);
		Loop;
	Death:
		BFE1 AB 8 Bright A_SetScale(1.45,1.45);
		BFE1 C 8 Bright A_Explode(random(25,80),152);
		TNT1 A 0 A_ScreamAndUnblock;
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_RomeroGroundCH : Actor   // CH CYBIES.txt:6015
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 10;
		DamageFunction (random(20,100));   // CH: Damage(random(20,100))
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 1;
		XScale 2.25;
		YScale 0.15;
		DeathSound "weapons/rocklx";
		Projectile;
		+DONTHARMCLASS
		+FLOORHUGGER
		+DONTHARMSPECIES
		+THRUSPECIES
		Species "Daikatana";
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
		DropItem "RS_implyingclip", 64;
		DropItem "RS_CH_Shell", 42;
		DropItem "RS_CH_RocketAmmo", 32;
		DropItem "RS_CH_Cell", 12;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		TNT1 A 0 A_ScreamAndUnblock;
		BRBA ONMLK 3 Bright A_Explode(random(10,80),64,0);
		BRBA ABCDEFGHIJ 2 Bright;
		Stop;
	}
}

class RS_RomeroSkyCH : Actor   // CH CYBIES.txt:6051
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 10;
		DamageFunction (random(20,100));   // CH: Damage(random(20,100))
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 1;
		XScale 2.95;
		YScale 0.12;
		DeathSound "weapons/rocklx";
		Projectile;
		+DONTHARMCLASS
		+CEILINGHUGGER
		+NOCLIP
		+THRUACTORS
		Species "Daikatana";
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		TNT1 A 8;
		Goto Death;
	Death:
		BRBA OOOOO 2 Bright A_SpawnItemEx("RS_RomeroBeamCHTrail2",random(-64,64),random(-64,64),-24,random(1,8),0,random(-33,-1),random(-359,359),SXF_NOCHECKPOSITION);
		BRBA OOONNNMMMLLLKKK 1 Bright A_SpawnItemEx("RS_RomeroBeamCH",random(-64,64),random(-64,64),-24,random(1,8),0,random(-33,-1),random(-359,359),SXF_NOCHECKPOSITION);
		BRBA ABCDEFGHIJ 2 Bright;
		Stop;
	}
}

class RS_RomeroBeamCH : Actor   // CH CYBIES.txt:6083
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 50;
		DamageFunction (random(20,180));   // CH: Damage(random(20,180))
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 1;
		Scale 2.25;
		SeeSound "ELECTRO7";
		DeathSound "weapons/bfgx";
		Projectile;
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+THRUSPECIES
		Species "Daikatana";
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BRBA O 1 Bright A_Explode(random(10,80),64,0);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroBeamCHTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BRBA N 1 Bright A_Explode(random(10,80),64,0);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroBeamCHTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BRBA M 1 Bright A_Explode(random(10,80),64,0);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroBeamCHTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BRBA L 1 Bright A_Explode(random(10,80),64,0);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroBeamCHTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BRBA K 1 Bright A_Explode(random(10,80),64,0);
		Loop;
	Death:
		BRBA O 3 Bright A_SetScale(3.0,2.5);
		TNT1 A 0 A_Explode(random(60,180),128,0);
		BRBA N 3 Bright A_SetScale(3.8,2.15);
		BRBA M 3 Bright A_SetScale(3.0,1.85);
		// PROVEN MISSING IN CH: sprite BRAB has zero lumps anywhere in CH --
		// a transposition of BRBA on this one frame. Kept verbatim.
		BRBA L 3 Bright A_SetScale(2.5,1.75);   // CH: BRAB -- CH typo; BRBA is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		BRBA K 3 Bright A_SetScale(2.25,2.25);
		BRBA ABCDEFGHIJ 3 Bright;
		Stop;
	}
}

class RS_IDShieldWalk : Actor   // CH CYBIES.txt:6128
{
	int user_angle;   // CH: var int user_angle;
	Default
	{
		Radius 88;
		Height 72;
		Speed 18;
		Species "Daikatana";
		Health 999;
		Monster;
		+NOTRIGGER
		+NOTARGET
		+DONTTHRUST
		+NOGRAVITY
		+INVULNERABLE
		+MTHRUSPECIES
		+REFLECTIVE
		+DEFLECT
		+SHIELDREFLECT
		+THRUSPECIES
		-COUNTKILL
		RenderStyle "Add";
		Alpha 1.75;
		Scale 1.25;
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 { user_angle = user_angle + 8; }
		DKNT Z 1 Bright A_Warp(AAPTR_MASTER,92,0,64,user_angle + 8,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_JumpIf(user_angle >= 1800,"Death");
		Loop;
	Death:
		DKNT Z 2 Bright A_NoBlocking;
		DKNT Z 2 Bright A_SetScale(1);
		DKNT Z 2 Bright A_SetScale(0.7);
		DKNT Z 2 Bright A_SetScale(0.4);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_RomeroBeamCHTrail : Actor   // CH CYBIES.txt:6172
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 50;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.85;
		Scale 2.3;
		Projectile;
		Translation "0:255=%[0.00,0.40,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BRBA ONMLK 1 Bright;
		Goto Death;
	Death:
		BRBA ABCDEFGHIJ 1 Bright;
		Stop;
	}
}

class RS_RomeroBeamCHTrail2 : RS_RomeroBeamCHTrail { Default { Scale 1.45; } }   // CH CYBIES.txt:6196

class RS_RomeroRocketCH : Actor   // CH CYBIES.txt:6198
{
	Default
	{
		Radius 12;
		Height 8;
		Speed 33;
		DamageFunction (random(20,200));   // CH: Damage(random(20,200))
		DamageType "Fire";
		Projectile;
		+DONTHARMCLASS
		+THRUSPECIES
		Species "Daikatana";
		Scale 0.95;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		MSLH A 2 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		TNT1 A 0 A_SetScale(1.45,0.95);
		MISL B 4 Bright A_Explode(random(80,180),128);
		MISL CD 4 Bright;
		Stop;
	}
}

class RS_RomeroRocketCH2 : Actor   // CH CYBIES.txt:6226
{
	Default
	{
		Radius 12;
		Height 8;
		Speed 33;
		DamageFunction (random(20,200));   // CH: Damage(random(20,200))
		DamageType "Fire";
		Projectile;
		+DONTHARMCLASS
		+THRUSPECIES
		Species "Daikatana";
		Scale 0.95;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		MSLH A 1 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		MSLH A 1 Bright A_Weave(3,3,3,3);
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		TNT1 A 0 A_SetScale(1.45,0.95);
		MISL B 4 Bright A_Explode(random(80,180),128);
		MISL CD 4 Bright;
		Stop;
	}
}

class RS_RomeroRocketCH3 : Actor   // CH CYBIES.txt:6257
{
	Default
	{
		Radius 12;
		Height 8;
		Speed 33;
		DamageFunction (random(20,200));   // CH: Damage(random(20,200))
		DamageType "Fire";
		Projectile;
		+SEEKERMISSILE
		+THRUSPECIES
		Species "Daikatana";
		Scale 0.95;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		MSLH A 1 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		MSLH A 2 Bright A_SeekerMissile(4,4);
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		TNT1 A 0 A_SetScale(1.45,0.95);
		MISL B 4 Bright A_Explode(random(80,180),128);
		MISL CD 4 Bright;
		Stop;
	}
}
