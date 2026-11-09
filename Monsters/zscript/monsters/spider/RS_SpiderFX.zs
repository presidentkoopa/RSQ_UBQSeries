// ============================================================================
// RS_SpiderFX.zs -- Colourful Hell Arachnotron ("Spiders") family: support
// actors, projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Spiders.txt
// (4,574 lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_Spider.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here -- the compiler names duplicates, and ZScript is
// case-insensitive so a case-variant is a fatal redefinition too):
//   RS_IceOrbCyanAra1 / RS_IceOrbCyanAra2 (Spiders.txt:422/461 -> painelemental
//     FX; this file's own CH source, but shipped with that lane per the
//     correct-in-place rule -- diffed against CH, identical),
//   RS_PlasmaBallSP3 (Spiders.txt:1886 -> zombieman FX, diffed, identical),
//   RS_MediCacoBrown (Cacodemons.txt:148 -> spectre FX),
//   RS_CHBSTarget (Shotgunners.txt:1813 -> shotgunner FX),
//   RS_RedDotSGPuff (Shotgunners.txt:492 -> shotgunner FX),
//   RS_RedMessImp (Imps.txt:1832 -> shotgunner FX),
//   RS_CH_Cirno (-> shotgunner FX),
//   RS_EXPLOSIONSCGuyEXDelayd (Chaingunners.txt:2216 -> chaingunner FX),
//   RS_SlimeBall1..RS_SlimeBall5 (Chaingunners.txt:2927-2955 -> chaingunner FX),
//   RS_Trail12 (Revenants.txt:1677 -> chaingunner FX),
//   RS_FatsoSpikes2 (Fatsos.txt:1148 -> imp FX),
//   RS_BaronStar3 (Barons.txt:2988 -> hellknight FX),
//   RS_BaronCyanBombTrail (Barons.txt:699 -> lostsoul FX),
//   RS_HomingRocketTrailFatso (Fatsos.txt:2201 -> lostsoul FX),
//   RS_HKRedDeath (Hellknights.txt:2231 -> zombieman FX),
//   RS_SplashAbyss / RS_SplashAbyss2 / RS_AbyssShotIdentifier (-> zombieman FX).
// Plus the ordinary shared set: RS_Zom, RS_ZomTierToken, RS_GrowRaisin,
// RS_CHBoner, RS_ThePlanBoner, RS_ColorTierIconCH..CH13, RS_HealthBundle,
// RS_ArmorBundle, RS_BackPackBundle, RS_ImplyingClip, RS_CH_ClipBox,
// RS_CH_RocketAmmo, RS_CH_RocketBox, RS_CH_Cell, RS_CH_CellPack,
// RS_CH_Chainsaw, RS_CH_Berserk, RS_CH_Medikit, RS_CH_Shell,
// RS_CH_SoulSphere.
//
// SHIPPED BY EARLIER LANES IN THIS WAVE (CH file order: Barons < Revenants <
// Fatsos < Spiders), referenced read-only -- all four landed before this file
// did, so they are direct references, not guards:
//   RS_FrostWingBaron  -- Barons.txt:822    -> baron/RS_BaronFX.zs
//   RS_ZapFFAT         -- Fatsos.txt:269    -> revenant/RS_RevenantFX.zs
//   RS_WhiteFatRB      -- Fatsos.txt:3958   -> fatso/RS_FatsoFX.zs
//   RS_WhiteFatRB2     -- Fatsos.txt:4047   -> fatso/RS_FatsoFX.zs
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite SGRN frame A (RS_SpiderStoneRocket Spawn/Death, Spiders.txt
//     :1416-1425; RS_SpRocket3 Spawn, :3536-3537): no SGRN* lump anywhere in
//     the CH tree -- the same hole the shotgunner and hell knight families
//     already proved. Both rockets fly invisible in CH too; their MISL
//     explosions still render.
//   * Sound "grunt/attack" (RS_PurpleSP1 Missile, Spiders.txt:1961): CH's
//     SNDINFO never defines it and no lump matches. Silent in CH, kept
//     verbatim.
//   * Sound "kawai/pain" (every white spider's PainSound, Spiders.txt:3802,
//     4191, 4291, 4364, 4517): CH defines Kawai/sight, Kawai/hurt,
//     Kawai/death and Kawai/active -- never Kawai/pain. Silent in CH, kept
//     verbatim.
//
// Standing strips, preserved at each site as "// CH:" comments: ACS
// announcers (AnnounceBlackSpider, AnnounceWhiteSpider) and the three
// DirectionMind* mind-control scripts; the CHRandom_GibGenerator/NashGore
// gore chain (XDeath ANIMATIONS stay); DRLA RLFireStormModItem /
// RareArmorPool / RLUniqueWeaponSpawner drops.
//
// Sprites shipped in sprites/rs_spider/: ARAG (3), ACNB (20), ACNF (12),
// BSP2 (59), BLST (16), WW3B (2) = 112 lumps. Every other prefix this family
// names already ships with an earlier lane (BSPI, ABSP, TRIT, SPIR, ICEY,
// SSBL, PUFI, RIP1, RED9, BBOM, BOGY, GRFZ, FLUM, GBLL, RCHB, FBRS, MSLH,
// WORM, AYPB, BAL3) or resolves from the IWAD (BAL1, BAL7, PLSS, PLSE, MISL,
// BAR1, APLS, APBX, PUFF).
// ============================================================================

// ---------------------------------------------------------------------------
// Brown recluse kit.  CH: Spiders.txt:162-226.
// ---------------------------------------------------------------------------
class RS_BrownOrbSpiderCH : Actor   // CH Spiders.txt:162
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 28;
		Mass 100;
		Species "Spider1";
		Damage 0;
		Projectile;
		DamageType "Plasma";
		+MTHRUSPECIES
		+THRUGHOST
		+HITTARGET
		SeeSound "baby/attack";
		DeathSound "Litn/litn3";
		Translation "0:255=#[169,232,23]";
		Scale 0.45;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 AB 1 Bright A_BishopMissileWeave;
		TNT1 A 0 A_SpawnItemEx("RS_TrailBrownSP",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	XDeath:
		TNT1 A 0 A_CheckFlag("ismonster","Nah",AAPTR_TARGET);
		TNT1 A 0 { bISMONSTER = true; }   // CH: A_changeflag("ismonster",true)
		TNT1 A 1 A_VileTarget("RS_TrailBrownSP");
		TNT1 A 1 A_VileAttack("weapons/bfgx",random(10,30),random(10,30),64,4,"Plasma");
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-42,42),random(-42,42),random(-8,8),0,0,0,0,SXF_TRANSFERTRANSLATION);   // CH: ZapFFAT, Fatsos.txt:269 -- shipped by the revenant lane
		TNT1 A 0 A_Die();
		Stop;
	Nah:
		TNT1 A 0 { bPAINLESS = true; }   // CH: A_changeflag("Painless",true)
		TNT1 A 1 A_RadiusGive("Health",320,RGF_MONSTERS,200);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(8,64),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die();
		Stop;
	Death:
		RIP1 D 0 A_SetScale(1.0,1.0);
		RIP1 DEFGH 3 Bright A_Explode(random(2,8),64);
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-42,42),random(-42,42),random(-8,8),0,0,0,0,SXF_TRANSFERTRANSLATION);   // CH: ZapFFAT, Fatsos.txt:269 -- shipped by the revenant lane
		Stop;
	}
}

class RS_TrailBrownSP : Actor   // CH Spiders.txt:209
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		Projectile;
		+NOCLIP
		Translation "0:255=#[169,232,23]";
		Scale 0.5;
		RenderStyle "Add";
		Alpha 0.45;
	}
	States
	{
	Spawn:
		BAL1 AB 6 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cyan flying spider's ice bomb.  CH: Spiders.txt:388.
// RS_IceOrbCyanAra1 (:422) and RS_IceOrbCyanAra2 (:461) are NOT defined here:
// they already ship in zscript/monsters/painelemental/RS_PainElementalFX.zs.
// ---------------------------------------------------------------------------
class RS_SpiderCyanBomb : Actor   // CH Spiders.txt:388
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 45;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(11,44));   // CH: Damage(random(11,44))
		DamageType "Ice";
		Alpha 0.85;
		Scale 0.33;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RED9 B 2 Bright A_SeekerMissile(1,1);
		RED9 A 3 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);   // CH: FrostWingBaron, Barons.txt:822 -- shipped by the baron lane
		RED9 A 0 A_Explode(random(2,12),32,0);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(0.8,0.8);
		SPIR ABCDEDCBA 1 Bright;
		SPIR E 1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Abyss spider ("Eye see") kit.  CH: Spiders.txt:730-955.
// ---------------------------------------------------------------------------
class RS_PsychicAbyssSP : Actor   // CH Spiders.txt:730
{
	Default
	{
		DamageType "Getoutofmyheadcharles";
		Radius 13;
		Height 9;
		Speed 0;
		DamageFunction (random(2,15));   // CH: Damage(random(2,15))
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+DONTHARMCLASS
		RenderStyle "Stencil";
		StencilColor "Black";
		Scale 0.75;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		BBOM B 1 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
	Death:
		BBOM C 2 Bright A_Explode(random(10,32),64,0);
		Stop;
	}
}

class RS_AbyssSPTrail : Actor   // CH Spiders.txt:758
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 25;
		DamageFunction (random(2,12));   // CH: Damage(random(2,12))
		DamageType "Plasma";
		Projectile;
		+RIPPER
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 0.73;
		Scale 0.15;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
	Death:
		SSBL K 9 Bright A_SetScale(0.1);
		SSBL I 9 Bright A_SetScale(0.2);
		SSBL K 9 Bright A_SetScale(0.3);
		SSBL J 9 Bright A_SetScale(0.4);
		Stop;
	}
}

class RS_AbyssSPBolt : Actor   // CH Spiders.txt:785
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 9;
		Speed 32;
		DamageFunction (random(35,90));   // CH: Damage(random(35,90))
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.75;
		Scale 0.5;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		SSBL ABCDEFGH 3 Bright A_SpawnItemEx("RS_AbyssSPTrail",0,0,1,random(4,24),0,0,random(-359,359),SXF_NOCHECKPOSITION);
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class RS_AbyssSPBreath : Actor   // CH Spiders.txt:815
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 24;
		DamageFunction (random(5,12));   // CH: Damage(random(5,12))
		DamageType "Ice";
		Projectile;
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.75;
		SeeSound "ice/Breath";
		DeathSound "Ice/Splode";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		PUFI AB 3 Bright A_Explode(random(5,15),30);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(0.9,0.9);
		PUFI CD 3 Bright A_Explode(random(5,15),30);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(1.1,1.1);
		PUFI EF 4 Bright A_Explode(random(5,15),30);
		TNT1 A 0 A_SetScale(1.25,1.25);
		PUFI GH 5 Bright A_Explode(random(5,15),30);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-28,28),random(-24,24),random(6,16),16,0,2,random(-16,16),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// Abyss spider's step / muzzle / flinch overlays, four palette variants each.
// CH: Spiders.txt:850-955.
class RS_AbyssSPwalk1norm : Actor   // CH Spiders.txt:850
{
	Default
	{
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.65;
		XScale 2.45;
		YScale 1.75;
	}
	States
	{
	Spawn:
		TRIT ABBC 2;
		Stop;
	}
}

class RS_AbyssSPwalk2norm : Actor   // CH Spiders.txt:865
{
	Default
	{
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.65;
		XScale 2.45;
		YScale 1.75;
	}
	States
	{
	Spawn:
		TRIT CDDEE 2;
		Stop;
	}
}

class RS_AbyssSPwalk1Blu   : RS_AbyssSPwalk1norm { Default { Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]"; } }   // CH Spiders.txt:880
class RS_AbyssSPwalk2Blu   : RS_AbyssSPwalk2norm { Default { Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]"; } }   // CH Spiders.txt:881
class RS_AbyssSPwalk1black : RS_AbyssSPwalk1norm { Default { Translation "0:255=0:0"; } }                                  // CH Spiders.txt:882
class RS_AbyssSPwalk2black : RS_AbyssSPwalk2norm { Default { Translation "0:255=0:0"; } }                                  // CH Spiders.txt:883
class RS_AbyssSPwalk1Fuz   : RS_AbyssSPwalk1norm { Default { RenderStyle "Fuzzy"; } }                                      // CH Spiders.txt:884
class RS_AbyssSPwalk2Fuz   : RS_AbyssSPwalk2norm { Default { RenderStyle "Fuzzy"; } }                                      // CH Spiders.txt:885

class RS_AbyssSPWalk1 : RandomSpawner   // CH Spiders.txt:887
{
	Default
	{
		DropItem "RS_AbyssSPwalk1Blu",255,25;
		DropItem "RS_AbyssSPwalk1norm",255,25;
		DropItem "RS_AbyssSPwalk1Black",255,25;
		DropItem "RS_AbyssSPwalk1Fuz",255,25;
	}
}

class RS_AbyssSPWalk2 : RandomSpawner   // CH Spiders.txt:895
{
	Default
	{
		DropItem "RS_AbyssSPwalk2Blu",255,25;
		DropItem "RS_AbyssSPwalk2norm",255,25;
		DropItem "RS_AbyssSPwalk2Black",255,25;
		DropItem "RS_AbyssSPwalk2Fuz",255,25;
	}
}

class RS_AbyssSPShootnorm : Actor   // CH Spiders.txt:903
{
	Default
	{
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.65;
		XScale 2.45;
		YScale 1.75;
	}
	States
	{
	Spawn:
		TRIT E 5 Bright;
		TRIT F 4 Bright;
		Stop;
	}
}

class RS_AbyssSPPainnorm : Actor   // CH Spiders.txt:919
{
	Default
	{
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.65;
		XScale 2.45;
		YScale 1.75;
	}
	States
	{
	Spawn:
		TRIT F 6;
		Stop;
	}
}

class RS_AbyssSPPainBlu    : RS_AbyssSPPainnorm  { Default { Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]"; } }   // CH Spiders.txt:934
class RS_AbyssSPShootBlu   : RS_AbyssSPShootnorm { Default { Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]"; } }   // CH Spiders.txt:935
class RS_AbyssSPPainblack  : RS_AbyssSPPainnorm  { Default { Translation "0:255=0:0"; } }                                  // CH Spiders.txt:936
class RS_AbyssSPShootblack : RS_AbyssSPShootnorm { Default { Translation "0:255=0:0"; } }                                  // CH Spiders.txt:937
class RS_AbyssSPPainFuz    : RS_AbyssSPPainnorm  { Default { RenderStyle "Fuzzy"; } }                                      // CH Spiders.txt:938
class RS_AbyssSPShootFuz   : RS_AbyssSPShootnorm { Default { RenderStyle "Fuzzy"; } }                                      // CH Spiders.txt:939

class RS_AbyssSPShoot : RandomSpawner   // CH Spiders.txt:941
{
	Default
	{
		DropItem "RS_AbyssSPshootBlu",255,25;
		DropItem "RS_AbyssSPshootnorm",255,25;
		DropItem "RS_AbyssSPshootBlack",255,25;
		DropItem "RS_AbyssSPshootFuz",255,25;
	}
}

class RS_AbyssSPPain : RandomSpawner   // CH Spiders.txt:949
{
	Default
	{
		DropItem "RS_AbyssSPpainBlu",255,25;
		DropItem "RS_AbyssSPPainnorm",255,25;
		DropItem "RS_AbyssSPPainBlack",255,25;
		DropItem "RS_AbyssSPPainFuz",255,25;
	}
}

// ---------------------------------------------------------------------------
// FireBlu floater's four plasma balls.  CH: Spiders.txt:1113-1219.
// ---------------------------------------------------------------------------
class RS_PlasmaBallSPFB1 : Actor   // CH Spiders.txt:1113
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 20;
		Damage 5;
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright A_BishopMissileWeave;
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class RS_PlasmaBallSPFB2 : Actor   // CH Spiders.txt:1140
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 20;
		Damage 5;
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
		Translation "192:207=172:191";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright A_BishopMissileWeave;
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class RS_PlasmaBallSPFB3 : Actor   // CH Spiders.txt:1168
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 33;
		Damage 5;
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
		Translation "192:207=172:191";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class RS_PlasmaBallSPFB4 : Actor   // CH Spiders.txt:1195
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 33;
		Damage 5;
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Gray spider's scrap rocket.  CH: Spiders.txt:1399.
// Sprite SGRN ships NOWHERE in CH -- see the header. Invisible in CH too.
// ---------------------------------------------------------------------------
class RS_SpiderStoneRocket : Actor   // CH Spiders.txt:1399
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 83;
		DamageFunction (random(60,95));   // CH: Damage(random(60,95))
		XScale 1.2;
		Projectile;
		+NOGRAVITY
		+ROCKETTRAIL
		SeeSound "fire/fire3";
		DeathSound "fire/fire1";
		DamageType "Melee";
	}
	States
	{
	Spawn:
		HGRN A 1 Bright;   // CH: sprite SGRN ships nowhere in CH -- invisible there too
		Loop;
	Death:
		HGRN A 1 { bNOGRAVITY = false; }   // CH: A_changeflag(nogravity,false)
		HGRN A 9 A_SetScale(1.3,1.2);   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 9 A_SetScale(1.2,1.3);   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 9 A_SetScale(1.3,1.2);   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 9 A_SetScale(1.2,1.3);   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 9 A_SetScale(1.1,1.1);   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 9 A_SetScale(0.9,0.9);   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		MISL B 0 A_Scream;
		TNT1 A 0 A_SetScale(1.3,1.3);
		MISL BCD 5 Bright A_Explode(random(20,60),128);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The vanilla arachnotron plasma replacement.  CH: Spiders.txt:1433.
// ---------------------------------------------------------------------------
class RS_ArachnotronPlasma2 : Actor replaces ArachnotronPlasma   // CH Spiders.txt:1433
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 25;
		Damage 5;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "baby/attack";
		DeathSound "baby/shotx";
	}
	States
	{
	Spawn:
		APLS AB 5 Bright;
		Loop;
	Death:
		APBX ABCDE 5 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The shared arachnotron gib bursts.  CH: Spiders.txt:1547-1609.
// ---------------------------------------------------------------------------
class RS_AraBoom1 : Actor   // CH Spiders.txt:1547
{
	Default
	{
		Radius 10;
		Height 42;
		+NOGRAVITY
		Scale 1.2;
	}
	States
	{
	Spawn:
		BAR1 AB 0;
		Goto Death;
	Death:
		MISL B 8 Bright;
		MISL C 6 Bright A_PlaySound("world/barrelx");
		MISL D 3 Bright;
		Stop;
	}
}

class RS_AraBoom2 : Actor   // CH Spiders.txt:1567
{
	Default
	{
		Radius 10;
		Height 42;
		+NOGRAVITY
		Scale 0.6;
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		BAR1 AB 0 A_PlaySound("weapons/firex4");
		Goto Death;
	Death:
		MISL B 8 Bright;
		MISL C 6 Bright A_PlaySound("weapons/firex4");
		MISL D 3 Bright;
		Stop;
	}
}

class RS_AraBoom3 : Actor   // CH Spiders.txt:1587
{
	Default
	{
		Radius 10;
		Height 42;
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.4;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		ARAG B 7 Bright;
		TNT1 AAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 3;
		ARAG C 6 Bright;
		TNT1 AAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Green arachnotron's acid spit.  CH: Spiders.txt:1721-1774.
// ---------------------------------------------------------------------------
class RS_Spspit : Actor   // CH Spiders.txt:1721
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 20;
		FastSpeed 40;
		DamageFunction (random(8,50));   // CH: Damage(Random(8,50))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "baron/attack";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		BAL7 AB 3 Bright A_SpawnItemEx("RS_Trail12",0,0,8);
		Loop;
	Death:
		BAL7 CD 3 Bright;
		TNT1 AAA 0 A_CustomMissile("RS_SSpit2",0,0,random(0,89));
		TNT1 AAA 0 A_CustomMissile("RS_SSpit2",0,0,random(90,179));
		TNT1 AAA 0 A_CustomMissile("RS_SSpit2",0,0,random(180,269));
		TNT1 AAA 0 A_CustomMissile("RS_SSpit2",0,0,random(270,359));
		BAL7 E 3 Bright;
		Stop;
	}
}

class RS_SSpit2 : Actor   // CH Spiders.txt:1752
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 14;
		DamageFunction (random(1,4));   // CH: damage(random(1,4))
		DamageType "Plasma";
		Projectile;
		SeeSound "None";   // CH: seesound none
		DeathSound "weapons/plasmax";
		Scale 0.35;
		-NOGRAVITY
	}
	States
	{
	Spawn:
		BOGY ABC 2 Bright;
		Loop;
	Death:
		BOGY D 0 A_NoGravity;
		BOGY DEF 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Psychic railgun kit, shared by the orange brainchoton and the abyss spider.
// CH: Spiders.txt:2158-2292.
// ---------------------------------------------------------------------------
class RS_PsychicAra : Actor   // CH Spiders.txt:2158
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+RANDOMIZE
		+PUFFONACTORS
		+BLOODLESSIMPACT
		Projectile;
		RenderStyle "Add";
		DamageType "Getoutofmyheadcharles";
		Alpha 0.95;
		VSpeed 1;
		Scale 2;
		Mass 5;
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright;
	Melee:
		BLST ABCDEFGHJKLMNOP 1 Bright;   // CH skips frame I here
		Stop;
	}
}

// CH: Spiders.txt:2184/2200/2216 -- the three mind-control tokens. Their only
// content is an ACS_NamedExecuteAlways("DirectionMind1..3") call; the
// announcer/ACS strip removes it, so the token is a live pickup that does
// nothing, exactly as an unresolved ACS name would in CH.
class RS_EyeSeePsychic1 : CustomInventory   // CH Spiders.txt:2184
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
		TNT1 A 0;   // CH: ACS_NamedExecuteAlways("DirectionMind1") -- ACS stripped per owner
		Stop;
	}
}

class RS_EyeSeePsychic2 : CustomInventory   // CH Spiders.txt:2200
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
		TNT1 A 0;   // CH: ACS_NamedExecuteAlways("DirectionMind2") -- ACS stripped per owner
		Stop;
	}
}

class RS_EyeSeePsychic3 : CustomInventory   // CH Spiders.txt:2216
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
		TNT1 A 0;   // CH: ACS_NamedExecuteAlways("DirectionMind3") -- ACS stripped per owner
		Stop;
	}
}

class RS_PsychicPulse : Actor   // CH Spiders.txt:2232
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 11;
		SeeSound "queen/fire";
		RenderStyle "Add";
		Alpha 0.75;
		Projectile;
		+NOCLIP
		+BLOODLESSIMPACT
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4");
	A1:
		BLST ABCDEFGHIIHGEFDCBA 1 Bright;
		Goto Death;
	A4:
		BLST ABCDEFGHHIIIIIIIHHHGEFDCBA 1 Bright;
		Goto Death;
	A2:
		BLST BCDEFGGEFDCB 1 Bright;
		Goto Death;
	A3:
		BLST BCD 1 Bright;
		BLST EFGGEF 2 Bright;
		BLST DCB 1 Bright;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_AracnorbBall : Actor   // CH Spiders.txt:2269
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 11;
		DamageFunction (random(10,50));   // CH: Damage(random(10,50))
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "baby/attack";
		DeathSound "baby/shotx";
		Projectile;
		+STRIFEDAMAGE
		+SEEKERMISSILE
		+RANDOMIZE
	}
	States
	{
	Spawn:
		ACNF AABB 1 Bright A_BishopMissileWeave;
		Loop;
	Death:
		ACNF CDEFG 5 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Red rage arachnotron's cluster bomb.  CH: Spiders.txt:2406-2461.
// ---------------------------------------------------------------------------
class RS_SPShard : Actor   // CH Spiders.txt:2406
{
	Default
	{
		Radius 3;
		Height 4;
		Mass 5;
		Speed 32;
		Projectile;
		+SEEKERMISSILE
		Scale 0.3;
		RenderStyle "Add";
		DamageFunction (random(5,10));   // CH: Damage(random(5,10))
		DamageType "DImp";
		Alpha 0.95;
		SeeSound "imp/attack";
		DeathSound "weapons/firex4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 ABABABABABA 6;
		Goto Death;
	Death:
		BAL1 CDE 1 A_SetTranslucent(0.35);
		Stop;
	}
}

class RS_RedBombSP : Actor   // CH Spiders.txt:2433
{
	Default
	{
		Radius 6;
		Height 8;
		Mass 5;
		Speed 27;
		Projectile;
		+SEEKERMISSILE
		Scale 0.6;
		RenderStyle "Add";
		DamageFunction (random(5,40));   // CH: Damage(random(5,40))
		Alpha 0.95;
		DamageType "Plasma";
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/firex4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 A 1 A_SeekerMissile(3,5);
		BAL1 B 1 A_SpawnItemEx("RS_RedMessImp",0,0,1,0,0,0,0);
		BAL1 B 1 A_Weave(1,1,2,1);
		Loop;
	Death:
		BAL1 C 1 A_SetTranslucent(0.35);
		BAL1 CDDEE 1 A_CustomMissile("RS_SPShard",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black boss EX kit.  CH: Spiders.txt:2939-3166.
// ---------------------------------------------------------------------------
class RS_BlackSpideSpiralShot : Actor   // CH Spiders.txt:2939
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 15;
		DamageFunction (random(20,80));   // CH: Damage(random(20,80))
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		+THRUACTORS
		+ROLLSPRITE
		RenderStyle "Add";
		Alpha 1;
		Scale 1;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		TNT1 A 3;
	Fly:
		GRFZ CBA 4 Bright;
		TNT1 A 0 A_SetScale(0.75,0.75);
		TNT1 A 0 A_SetRoll(70);
		TNT1 A 0 A_Explode(random(10,50),64,0);
		GRFZ BA 4 Bright;
		TNT1 A 0 A_SetScale(0.5,0.5);
		TNT1 A 0 A_SetRoll(140);
		GRFZ BA 4 Bright;
		TNT1 A 0 A_SetScale(0.75,0.75);
		TNT1 A 0 A_Explode(random(10,50),64,0);
		TNT1 A 0 A_SetRoll(210);
		GRFZ BA 4 Bright;
		TNT1 A 0 A_SetRoll(285);
		TNT1 A 0 A_SetScale(0.5,0.5);
		TNT1 A 0 A_SetScale(0.75,0.75);
		TNT1 A 0 A_Explode(random(10,50),64,0);
		GRFZ CBA 4 Bright;
		TNT1 A 0 A_SetRoll(360);
		Loop;
	Death:
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_SetScale(1.0,1.0);
		GRFZ IJ 3 Bright;
		GRFZ K 3 Bright A_Explode(random(33,99),128,0);
		TNT1 AAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-14,28),random(12,99),0,random(-25,25),random(180,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ LMN 2 Bright;
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ OP 3 Bright;
		Stop;
	}
}

class RS_BlackSpideEXShade : Actor   // CH Spiders.txt:2994
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Stencil";
		StencilColor "Red";
		Alpha 0.33;
		YScale 1.75;
		XScale 3.35;
	}
	States
	{
	Spawn:
		FLUM ACDBE 3 Bright;
		Stop;
	}
}

class RS_YellowBombEXSpidie : Actor   // CH Spiders.txt:3015
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 38;
		DamageFunction (random(20,80));   // CH: Damage(random(20,80))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1;
		Scale 1.25;
		SeeSound "spit/spit";
		DeathSound "spit/spit2";
		Translation "0:255=%[1.29,0.65,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		GBLL ABCABC 6 Bright;
	Fly:
		GBLL ABC 6 Bright A_CStaffMissileSlither;
		Loop;
	Death:
		GBLL A 1 Bright A_SetScale(1.0,1.0);
		GBLL B 1 Bright A_SetScale(0.75,0.75);
		GBLL C 1 Bright A_SetScale(0.5,0.5);
		GBLL A 1 Bright A_SetScale(0.25,0.25);
		GBLL BCABC 1 Bright;
		TNT1 A 0 A_PlaySound("spell/Impact1",0);
		BBOM A 2 Bright A_SetScale(0.5,0.5);
		TNT1 A 0 A_Explode(random(10,20),32,0);
		TNT1 AAAA 0 A_SpawnItemEx("RS_BlackSpideEXScrap",0,0,3,random(6,18),0,random(1,12),random(0,120));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BlackSpideEXScrap",0,0,3,random(6,18),0,random(1,12),random(120,240));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BlackSpideEXScrap",0,0,3,random(6,18),0,random(1,12),random(240,360));
		BBOM B 2 Bright A_SetScale(0.75,0.75);
		TNT1 A 0 A_Explode(random(10,30),64,0);
		BBOM C 2 Bright A_SetScale(1.25,1.25);
		TNT1 A 0 A_Explode(random(20,60),74,0);
		BBOM C 2 Bright A_SetScale(2.0,2.0);
		TNT1 AAAA 0 A_SpawnItemEx("RS_BlackSpideEXScrap",0,0,3,random(6,18),0,random(1,12),random(0,120));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BlackSpideEXScrap",0,0,3,random(6,18),0,random(1,12),random(120,240));
		TNT1 AAAA 0 A_SpawnItemEx("RS_BlackSpideEXScrap",0,0,3,random(6,18),0,random(1,12),random(240,360));
		TNT1 A 0 A_Explode(random(20,80),128,0);
		BBOM C 2 Bright A_SetScale(2.5,2.5);
		TNT1 A 0 A_PlaySound("Bomb/boom",0);
		TNT1 A 0 A_Explode(random(30,90),176,0);
		BBOM C 2 Bright A_SetScale(3.0,3.0);
		TNT1 A 0 A_Explode(random(30,90),256,0);
		BBOM C 2 Bright A_SetScale(3.5,3.5);
		TNT1 A 0 A_Explode(random(30,90),256,0);
		BBOM C 2 Bright A_SetScale(4.0,4.0);
		TNT1 A 0 A_Explode(random(30,90),312,0);
		BBOM CCCBA 4 Bright A_FadeOut(0.20);
		Stop;
	}
}

class RS_BlackSpideEXScrap : Actor   // CH Spiders.txt:3075
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 38;
		Scale 0.55;
		DamageFunction (random(1,8));   // CH: Damage(random(1,8))
		Projectile;
		+NOGRAVITY
		+BOUNCEONFLOORS
		BounceType "Hexen";
		BounceCount 5;
		BounceFactor 0.75;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "";
		DeathSound "";
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright;
		TNT1 A 0 A_SpawnParticle("Orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PUFF ABA 2 Bright A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnParticle("Orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PUFF AB 2 Bright A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Goto Nyeh;
	Nyeh:
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: a_changeflag(nogravity,false)
		TNT1 A 0 A_SpawnParticle("Orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PUFF ABAB 2 Bright A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Death:
		TNT1 AA 0 A_SpawnParticle("Orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PUFF ABAB 2 Bright A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(1,5),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_ExSpideLaser1 : Actor   // CH Spiders.txt:3114
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 38;
		DamageFunction (random(10,50));   // CH: Damage(Random(10,50))
		DamageType "Plasma";
		Projectile;
		+BOUNCEONWALLS
		BounceType "Doom";
		BounceCount 2;
		XScale 1.1;
		YScale 0.75;
		RenderStyle "Add";
		SeeSound "weapons/plasmaf";
		DeathSound "weapons/plasmax";
		BounceSound "";
	}
	States
	{
	Spawn:
		RCHB AB 1 Bright A_SpawnItemEx("RS_SpideEXTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(0.85,0.85);
		RCHB CD 3 Bright;
		TNT1 A 0 A_SetScale(1.35,1.05);
		RCHB E 3 Bright A_Explode(random(10,40),64,0);
		Stop;
	}
}

class RS_SpideEXTrail : Actor   // CH Spiders.txt:3146
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

class RS_BBSP1 : Actor   // CH Spiders.txt:3168
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 31;
		DamageFunction (random(20,75));   // CH: Damage(random(20,75))
		Projectile;
		-NOGRAVITY
		BounceType "Doom";
		Gravity 0.29;
		BounceCount 19;
		BounceFactor 1.15;
		WallBounceFactor 0.95;
		SeeSound "fire/fire3";
		DeathSound "fire/fire1";
		BounceSound "fire/fire2";
		DamageType "Fire";
	}
	States
	{
	Spawn:
		MISL B 2 Bright A_SpawnItemEx("RS_BaronStar3",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL C 2 Bright A_Jump(12,"Bounce");
		MISL D 2 Bright A_Explode(random(10,30),128);
		Loop;
	Bounce:
		MISL D 2 Bright ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),12,0,0)
		Goto Spawn;
	Death:
		MISL B 8 Bright A_Explode(random(20,50),128);
		MISL CCCC 2 Bright A_SpawnItemEx("RS_BaronStar3",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL DDDD 2 Bright A_SpawnItemEx("RS_BaronStar3",random(-220,220),random(-220,220),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL DDDDDD 0 A_SpawnItemEx("RS_BaronStar3",random(-280,280),random(-280,280),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Macross missile swarm -- five homing missiles and their trails.
// CH: Spiders.txt:3205-3460.
// ---------------------------------------------------------------------------
class RS_SPMM5 : Actor   // CH Spiders.txt:3205
{
	Default
	{
		Radius 9;
		Height 13;
		Speed 28;
		DamageFunction (random(30,65));   // CH: Damage(random(30,65))
		Scale 1.35;
		Projectile;
		+SEEKERMISSILE
		RenderStyle "Normal";
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		DamageType "Fire";   // CH sets DamageType Fire twice
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright A_SeekerMissile(1,4);
		FBRS A 1 Bright A_SpawnItemEx("RS_SPMMTrail5",0,0,0,0,0,0,0,128);
		FBRS A 1 Bright A_Weave(5,4,4,8);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 6 Bright A_SetScale(1.5);
		BAL3 D 6 Bright A_Explode(random(30,75),128,0);
		BAL3 E 6 Bright;
		Stop;
	}
}

class RS_SPMMTrail5 : Actor   // CH Spiders.txt:3237
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 9;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.25;
		DeathSound "weapons/plasmax";
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		PLSE ABCDE 6 Bright;
		Stop;
	}
}

class RS_SPMM4 : Actor   // CH Spiders.txt:3257
{
	Default
	{
		Radius 9;
		Height 13;
		Speed 20;
		DamageFunction (random(30,65));   // CH: Damage(random(30,65))
		Scale 1.35;
		Projectile;
		+SEEKERMISSILE
		RenderStyle "Normal";
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		DamageType "Meelee";   // CH: DamageType Fire then Damagetype Meelee (CH's own typo); last wins
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright A_SeekerMissile(1,4);
		FBRS A 1 Bright A_SpawnItemEx("RS_SPMMTrail4",0,0,0,0,0,0,0,128);
		FBRS A 1 Bright A_Weave(3,6,7,3);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 6 Bright A_SetScale(1.5);
		BAL3 D 6 Bright A_Explode(random(30,75),128,0);
		BAL3 E 6 Bright;
		Stop;
	}
}

class RS_SPMMTrail4 : Actor   // CH Spiders.txt:3289
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 9;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.25;
		DeathSound "weapons/plasmax";
		Translation "192:207=160:167";
	}
	States
	{
	Spawn:
		PLSE ABCDE 6 Bright;
		Stop;
	}
}

class RS_SPMM3 : Actor   // CH Spiders.txt:3309
{
	Default
	{
		Radius 9;
		Height 13;
		Speed 24;
		DamageFunction (random(20,85));   // CH: Damage(random(20,85))
		Scale 1.35;
		Projectile;
		RenderStyle "Normal";
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		DamageType "Plasma";   // CH: DamageType Fire then Damagetype Plasma; last wins
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright;
		FBRS A 2 Bright A_SpawnItemEx("RS_SPMMTrail3",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 6 Bright A_SetScale(1.5);
		BAL3 D 6 Bright A_Explode(random(30,75),128,0);
		BAL3 E 6 Bright;
		Stop;
	}
}

class RS_SPMMTrail3 : Actor   // CH Spiders.txt:3339
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 9;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.25;
		DeathSound "weapons/plasmax";
		Translation "192:207=112:127";
	}
	States
	{
	Spawn:
		PLSE ABCDE 6 Bright;
		Stop;
	}
}

class RS_SPMM2 : Actor   // CH Spiders.txt:3359
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 22;
		DamageFunction (random(20,65));   // CH: Damage(random(20,65))
		Scale 1.15;
		Projectile;
		RenderStyle "Normal";
		+SEEKERMISSILE
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		DamageType "Fire";   // CH sets DamageType Fire twice
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright A_SeekerMissile(7,14);
		FBRS A 1 Bright A_SpawnItemEx("RS_SPMMTrail2",0,0,0,0,0,0,0,128);
		FBRS A 1 Bright A_Weave(2,1,3,1);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 6 Bright A_SetScale(1.5);
		BAL3 D 6 Bright A_Explode(random(20,75),128,0);
		BAL3 E 6 Bright;
		Stop;
	}
}

class RS_SPMMTrail2 : Actor   // CH Spiders.txt:3391
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 9;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.25;
		DeathSound "weapons/plasmax";
		Translation "192:207=173:191";
	}
	States
	{
	Spawn:
		PLSE ABCDE 6 Bright;
		Stop;
	}
}

class RS_SPMM1 : Actor   // CH Spiders.txt:3411
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 26;
		DamageFunction (random(20,65));   // CH: Damage(random(20,65))
		Scale 1.15;
		Projectile;
		RenderStyle "Normal";
		+SEEKERMISSILE
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		DamageType "Fire";   // CH sets DamageType Fire twice
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright A_SeekerMissile(3,8);
		FBRS A 1 Bright A_SpawnItemEx("RS_SPMMTrail1",0,0,0,0,0,0,0,128);
		FBRS A 1 Bright A_Weave(1,1,1,1);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 6 Bright A_SetScale(1.5);
		BAL3 D 6 Bright A_Explode(random(20,75),128,0);
		BAL3 E 6 Bright;
		Stop;
	}
}

class RS_SPMMTrail1 : Actor   // CH Spiders.txt:3443
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 9;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.25;
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSE ABCDE 6 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The black boss's three rockets.  CH: Spiders.txt:3462-3543.
// ---------------------------------------------------------------------------
class RS_SpRocket4 : Actor   // CH Spiders.txt:3462
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 1;
		DamageFunction (random(10,50));   // CH: Damage(random(10,50))
		DamageType "Fire";
		Projectile;
		Scale 1.25;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/homingexplode";
	}
	States
	{
	Spawn:
		MSLH A 12 Bright;
		MSLH A 0 A_ScaleVelocity(random(12,83));
		Goto Fly;
	Fly:
		MSLH A 2 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		MISL B 2 Bright A_Explode(random(50,90),158);
		MISL CD 3 Bright;
		Stop;
	}
}

class RS_SpRocket4EX : Actor   // CH Spiders.txt:3490
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 1;
		DamageFunction (random(20,80));   // CH: Damage(random(20,80))
		DamageType "Fire";
		Projectile;
		Scale 1.25;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/homingexplode";
	}
	States
	{
	Spawn:
		MSLH A 12 Bright;
		MSLH A 0 A_ScaleVelocity(random(20,83));
		Goto Fly;
	Fly:
		MSLH A 1 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		MSLH A 1 Bright A_BishopMissileWeave;
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		TNT1 A 0 A_SetScale(1.75,1.75);
		MISL B 2 Bright A_Explode(random(50,120),232);
		MISL CD 3 Bright;
		Stop;
	}
}

class RS_SpRocket3 : Actor   // CH Spiders.txt:3520
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 37;
		DamageFunction (random(10,45));   // CH: Damage(random(10,45))
		XScale 1.2;
		Projectile;
		+ROCKETTRAIL
		SeeSound "fire/fire3";
		DeathSound "fire/fire1";
		DamageType "Fire";
	}
	States
	{
	Spawn:
		HGRN A 1 Bright;   // CH: sprite SGRN ships nowhere in CH -- invisible there too
		HGRN A 1;   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		Loop;
	Death:
		MISL BCD 8 Bright A_Explode(random(5,20),128);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White spider kit -- webs, bolts and the two legacy shot types.
// CH: Spiders.txt:3564-3763, 4064-4157, 4418-4497.
// ---------------------------------------------------------------------------
class RS_SPWHII3 : Actor   // CH Spiders.txt:3564
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 29;
		DamageFunction (random(10,60));   // CH: Damage(random(10,60))
		Scale 0.75;
		Projectile;
		+SEEKERMISSILE
		SeeSound "phantom/bomb";
		DeathSound "phantom/explode";
		DamageType "Melee";
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 1 Bright A_SetScale(1);
		PLSE A 1 Bright A_SeekerMissile(1,2);
		PLSE A 1 Bright A_SetScale(0.75);
		Loop;
	Death:
		PLSE BCDE 8 Bright A_Explode(random(1,10),64);
		Stop;
	}
}

class RS_SPWHII2 : Actor   // CH Spiders.txt:3591
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 23;
		DamageFunction (random(10,60));   // CH: Damage(random(10,60))
		Scale 1.15;
		Projectile;
		SeeSound "phantom/bomb";
		DeathSound "phantom/explode";
		DamageType "Melee";
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 1 Bright A_SetScale(1);
		PLSE A 1 Bright A_CStaffMissileSlither;
		PLSE A 1 Bright A_SetScale(0.75);
		Loop;
	Death:
		PLSE BCDE 8 Bright A_Explode(random(1,10),64);
		Stop;
	}
}

class RS_WHITESPIDERWEBSHOTNOTLEWD : Actor   // CH Spiders.txt:3617
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 35;
		DamageFunction (random(1,5));   // CH: Damage(random(1,5))
		Scale 0.75;
		Projectile;
		SeeSound "phantom/bomb";
		DeathSound "phantom/explode";
		DamageType "Melee";
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 1 Bright A_SpawnItemEx("RS_WhiteSPWebTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1);
		Loop;
	Death:
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_WhiteSPWebTrail",random(-32,0),random(0,32),0);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_WhiteSPWebTrail",random(0,32),random(-32,0),0);
		TNT1 AAAAAAAAAAAAA 0 A_SpawnItemEx("RS_WhiteSPWebTrail",random(-32,32),random(-32,32),0);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		TNT1 AAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(-26,26),random(-26,26),random(-8,16));
		TNT1 AAAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(-48,48),random(-48,48),random(-8,16));
		PLSE BCDE 1 Bright;
		Stop;
	}
}

class RS_WHITESPSlowdown : PowerSpeed   // CH Spiders.txt:3647
{
	Default
	{
		+INVENTORY.AUTOACTIVATE
		-INVENTORY.INVBAR
		Powerup.Duration 15;
		Speed 0.2;
	}
}

class RS_WhiteSPWebWeb : Actor   // CH Spiders.txt:3655
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Projectile;
		+NOCLIP
		+DONTTHRUST
		+DONTBLAST
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(128,"A1");
	A2:
		WW3B A 12 Bright;
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		WW3B A 12 Bright A_SetTranslucent(0.7);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		WW3B A 12 Bright A_SetTranslucent(0.4);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		WW3B A 12 Bright A_SetTranslucent(0.2);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		Goto Death;
	A1:
		WW3B B 12 Bright;
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		WW3B B 12 Bright A_SetTranslucent(0.7);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		WW3B B 12 Bright A_SetTranslucent(0.4);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		WW3B B 12 Bright A_SetTranslucent(0.2);
		TNT1 A 0 A_RadiusGive("RS_WHITESPSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		Goto Death;
	Death:
		PLSE A 1;
		Stop;
	}
}

class RS_WhiteSPWebTrail : Actor   // CH Spiders.txt:3695
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Scale 0.66;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 3 Bright;
		PLSE A 6 Bright A_SpawnItemEx("RS_WhiteSPWebTrail2",-1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1);
	Death:
		PLSE A 8;
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(-8,8),random(-12,12),random(-8,8));
		Stop;
	}
}

class RS_WhiteSPWebTrail2 : Actor   // CH Spiders.txt:3718
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Scale 0.66;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 8 Bright;
	Death:
		PLSE A 8;
		Stop;
	}
}

class RS_SPWht2 : Actor   // CH Spiders.txt:3739
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+RANDOMIZE
		+PUFFONACTORS
		Projectile;
		RenderStyle "Add";
		Alpha 0.95;
		VSpeed 1;
		Scale 2;
		SeeSound "imp/shotx";
		Translation "192:207=80:95";
		Mass 5;
	}
	States
	{
	Spawn:
		PLSE AB 1 Bright A_Explode(random(1,20),64);
	Melee:
		PLSE CDE 1 Bright;
		Stop;
	}
}

class RS_WhiteSpiderHomer : Actor   // CH Spiders.txt:4064
{
	Default
	{
		DamageType "Plasma";
		Radius 9;
		Height 9;
		Speed 6;
		DamageFunction (random(35,90));   // CH: Damage(random(35,90))
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		+SEEKERMISSILE
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
		Translation "168:191=80:95","208:223=80:95","224:231=4:4","232:235=94:94";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 2 A_SetScale(1.2,0.8);
		TNT1 AAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BAL1 A 2 A_SetScale(1.0,1.0);
		BAL1 A 2 A_SeekerMissile(72,72,SMF_PRECISE);
		BAL1 B 2 A_SetScale(0.8,1.2);
		TNT1 AAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BAL1 B 2 A_SetScale(1.0,1.0);
		BAL1 B 2 A_SeekerMissile(72,72,SMF_PRECISE);
		Loop;
	Death:
		MISL B 4 Bright;
		MISL C 4 Bright A_Explode(random(10,40),64,0);
		MISL D 4 Bright;
		TNT1 AAAAAAAAA 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(-64,64),random(-64,64),random(-8,26));
		Stop;
	}
}

class RS_WhiteSpiderPBolt : Actor   // CH Spiders.txt:4103
{
	Default
	{
		DamageType "Plasma";
		Radius 9;
		Height 9;
		Speed 8;
		DamageFunction (random(35,90));   // CH: Damage(random(35,90))
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.5;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		SSBL A 2 Bright;
		SSBL B 2 Bright A_ScaleVelocity(random(2,4));
	Fly:
		SSBL ABCDEFGH 2 Bright A_SpawnItemEx("RS_WhiteSpidBoltTrail",-1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1);
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class RS_WhiteSpidBoltTrail : Actor   // CH Spiders.txt:4135
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;
		Projectile;
		+RANDOMIZE
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.75;
		Translation "0:255=80:95";
	}
	States
	{
	Spawn:
		BLST ABCD 1 Bright;
		Goto Death;
	Death:
		BLST EFGHIJKLMN 1 Bright A_FadeOut(0.05);
		Stop;
	}
}

class RS_SPWHI3 : Actor   // CH Spiders.txt:4418
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 29;
		DamageFunction (random(10,75));   // CH: Damage(random(10,75))
		Scale 0.75;
		Projectile;
		+SEEKERMISSILE
		SeeSound "phantom/bomb";
		DeathSound "phantom/explode";
		DamageType "Melee";
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 1 Bright A_SetScale(1);
		PLSE A 1 Bright A_SeekerMissile(1,2);
		PLSE A 1 Bright A_SetScale(0.75);
		Loop;
	Death:
		PLSE BCDE 8 Bright A_Explode(random(5,20),128);
		PLSE E 0 A_SpawnItemEx("RS_MiniSP1",random(-128,128),random(-128,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64));
		Stop;
	}
}

class RS_SPWHI2 : Actor   // CH Spiders.txt:4446
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 23;
		DamageFunction (random(10,75));   // CH: Damage(random(10,75))
		Scale 1.15;
		Projectile;
		SeeSound "phantom/bomb";
		DeathSound "phantom/explode";
		DamageType "Melee";
		Translation "192:207=80:95";
	}
	States
	{
	Spawn:
		PLSE A 1 Bright A_SetScale(1);
		PLSE A 1 Bright A_Weave(1,1,2,1);
		PLSE A 1 Bright A_SetScale(0.75);
		Loop;
	Death:
		PLSE BCDE 8 Bright A_Explode(random(5,20),128);
		PLSE E 0 A_SpawnItemEx("RS_MiniSP1",random(-128,128),random(-128,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64));
		Stop;
	}
}

class RS_SPWht : Actor   // CH Spiders.txt:4473
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+RANDOMIZE
		+PUFFONACTORS
		Projectile;
		RenderStyle "Add";
		Alpha 0.95;
		VSpeed 1;
		Scale 2;
		SeeSound "Vile/Active";
		Translation "192:207=80:95";
		Mass 5;
	}
	States
	{
	Spawn:
		PLSE AB 1 Bright A_Explode(5,32);
	Melee:
		PLSE CDE 1 Bright A_SpawnItemEx("RS_MiniSP1",random(-128,128),random(-128,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64));
		Stop;
	}
}
