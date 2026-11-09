// ============================================================================
// RS_FatsoFX.zs -- Colourful Hell FATSOS (Mancubus) family: support actors,
// projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Fatsos.txt
// (4,075 lines, 87 actors, read whole). Externals chased to their defining
// CH file:line. Bodies live in RS_Fatso.zs.
//
// ---------------------------------------------------------------------------
// ALREADY OWNED -- CH defines these in Fatsos.txt but earlier families
// imported them first, per the correct-in-place rule. Referenced READ-ONLY,
// never redefined here (a duplicate class name is a fatal compile error):
//   RS_GreenBomb1 (Fatsos.txt:1437), RS_BlueFT (:1611), RS_BlueFT3 (:1640),
//   RS_BlueFT2 (:1666), RS_Bluewave1 (:1699), RS_Bluewave2 (:1742),
//   RS_PurpleBomb1 (:1925), RS_MiniFatsoPurpleBomb (:1972),
//   RS_FatsoShotYE (:2140), RS_RocketShotFatso (:2176),
//   RS_HomingRocketTrailFatso (:2201), RS_Shot2Fatso (:2356)
//     -- all twelve -> zscript/monsters/lostsoul/RS_LostSoulFX.zs
//   RS_FatsoSpikes2 (Fatsos.txt:1148) -> zscript/monsters/imp/RS_ImpFX.zs
//
// ---------------------------------------------------------------------------
// CEDED TO THE REVENANTS LANE (CH file order: Barons < Revenants < Fatsos <
// Spiders -- the earlier file owns a shared class). CH defines both of these
// inside Fatsos.txt, but Revenants.txt references them, so the Revenants
// lane ships them and this lane must not. Both HAVE landed
// (zscript/monsters/revenant/RS_RevenantFX.zs:2070 and :2103) and are
// referenced read-only here:
//   RS_ZapFFAT     -- CH Fatsos.txt:269; Revenants.txt:190,192,194,199,201,
//                     203,211 spawn it. Used here by RS_ZapFFAT2,
//                     RS_FatsoSoundWaveTrail and RS_BrownFatso2.
//   RS_FatsoPuff3  -- CH Fatsos.txt:1880; Revenants.txt:2015-2016 use it as
//                     an A_CustomRailgun pufftype. Used here by
//                     RS_PurpleFatso's Swoosh.
//
// ---------------------------------------------------------------------------
// Ordinary shared set, referenced read-only (defined by earlier families):
//   RS_Zom, RS_ZomTierToken, RS_GrowRaisin, RS_CHBoner, RS_ThePlanBoner,
//   RS_ColorTierIconCH .. RS_ColorTierIconCH13, RS_HealthBundle,
//   RS_ArmorBundle, RS_BackPackBundle, RS_CH_GreenArmor, RS_CH_BlueArmor,
//   RS_CH_Berserk, RS_CH_Cell, RS_CH_CellPack, RS_CH_RocketAmmo,
//   RS_CH_RocketBox, RS_CH_ShellBox, RS_CH_RocketLauncher,
//   RS_CH_PlasmaRifle, RS_CH_BFG9000, RS_CH_MegaSphere, RS_CH_Cirno,
//   RS_SplashAbyss, RS_SplashAbyss2, RS_AbyssShotIdentifier, RS_Splash11,
//   RS_Trail11, RS_Trail12, RS_Gas14, RS_Bounc22, RS_FireSpe2,
//   RS_FrostLong2, RS_SparkPuff1, RS_CGNail, RS_PlasmaBallSP4,
//   RS_CircleDrawMeteorCH .. RS_CircleDrawMeteorCH6.
// Plus vanilla BackPack.
//
// ---------------------------------------------------------------------------
// RESOLVED 2026-08-06 -- BDP2 frame I -> BDP2 H, two sites.
// The set is A-H and nothing more: 20 lumps, identical in sprites/rs_spectre,
// Desktop\CH\sprites and ART SOURCE -- BDP2A1/A2A8/A3A7/A4A6/A5 and the same
// five for B and C (the 8-rotation projectile), then BDP2D0/E0/F0/G0/H0 (the
// 0-rotation blast). Both mirrored halves were parsed; no lump names a frame
// past H. So CH's own "BDP2 GHI 4" rendered nothing on its third frame.
// D..H is a monotonically GROWING blast (25x25, 35x36, 52x49, 64x57, 64x63),
// so H is the final and largest frame; each site now reads "BDP2 GHH 4",
// holding H for I's 4 tics. Three frames, 12 tics and three A_Explode calls
// per site, all unchanged. Sites: RS_ShadowSplash Death (Fatsos.txt:3052),
// RS_BlackFatsoBurp Death (:3192).
//
// RESOLVED 2026-08-06 -- HSBT frame A -> HBST frame A, four sites, all in
// RS_Fatso.zs. HSBT is a two-character transposition of HBST and appears in
// the whole CH tree only at Fatsos.txt:795, 804, 2280 and 2290 -- always the
// same line, always "A_CustomMissile(HBeastSmoke,64,0,0)", always inside an
// actor whose every other line is HBST. HBST frame A ships (HBSTA1/A2A8/
// A3A7/A4A6/A5, 8 rotations, in sprites/rs_lostsoul and Desktop\CH\sprites),
// so the target is provable. Behaviour is unchanged either way: all four
// sites are 0-tic (never rendered) AND sit immediately after a "Loop;", so
// they are unreachable dead code here exactly as in CH. Corrected anyway so
// the tree carries no unresolvable sprite token. Sites: RS_FireBluFatso2
// Spawn/See (Fatsos.txt:795,804), RS_RedFatso Spawn/See (:2280,2290).
//
// ---------------------------------------------------------------------------
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite BDPI frame D -- no BDPI* lump anywhere in the CH tree; it is a
//     one-character typo for BDP1 on a 1-tic state. Sites:
//     RS_ShadowBeast_BallEx3 Fly (Fatsos.txt:3347), RS_ShadowBeast_Ball3
//     Spawn (:3430). Invisible in CH too; kept verbatim.
//   * Sound lump ILLSHEA2 -- CH SNDINFO.txt:439-441 declares
//     "$random ILLSHEAR { ILLSHEA1 ILLSHEA2 }" and an ILLSHEA2 entry, but CH
//     ships only ILLSHEA1.ogg. RS_WhiteFatScatter's SeeSound "ILLSHEAR" is
//     therefore silent half the time in CH as well. Kept verbatim.
//
// ---------------------------------------------------------------------------
// Standing strips, each preserved at its site as a "// CH:" comment:
//   ACS announcers (AnnounceBlackFatso, AnnounceWhiteFatso -- in RS_Fatso.zs)
//   the CHRandom_GibGenerator gore chain (XDeath ANIMATIONS stay)
//   DRLA cross-mod drops (RareArmorPool, RLUniqueWeaponSpawner,
//   RLDemonicWeaponSpawner, RLLegendaryWeaponSpawner)
// No LegenDoom gate appears in this file.
//
// SNDINFO: nothing to add. Every logical name this family uses already
// resolves in the repo SNDINFO (or is a GZDoom built-in), and CH's only two
// directives that touch our names -- "$limit SlimeBall/Splat 0" and
// "$volume SlimeBall/Splat 0.7" -- are already present and identical.
// TRNSLATE: RS_BlackFatsoEX calls A_SetTranslation for BBEASTEX1..6; the
// repo TRNSLATE.txt currently defines BBEASTEX5 only. See the report -- this
// lane does not edit TRNSLATE.txt.
// ============================================================================

// ---------------------------------------------------------------------------
// Brown mancubus kit -- the tesla shot.  CH: Fatsos.txt:173-297.
// ---------------------------------------------------------------------------
class RS_FatsoSoundWave : Actor   // CH Fatsos.txt:173
{
	Default
	{
		ProjectileKickBack 9001;
		Radius 12;
		Height 6;
		Speed 56;
		DamageFunction (random(10,55));   // CH: Damage(random(10,55))
		DamageType "Plasma";
		Projectile;
		+MTHRUSPECIES
		+DONTTHRUST
		+DONTBLAST
		RenderStyle "Add";
		Alpha 0.33;
		XScale 2.1;
		YScale 0.65;
		SeeSound "fatso/attack";
		DeathSound "weapons/bfgx";
		Translation "0:255=#[255,255,0]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		GBLL ABC 1 Bright A_SpawnItemEx("RS_FatsoSoundWaveTrail",0,0,0,6,0,0);
		Loop;
	Death:
		GBLL A 6 Bright A_SetScale(2.5,1.2);
		GBLL B 6 Bright A_Explode(random(20,80),128,0);
		GBLL C 6 Bright A_SetScale(3.0,1.5);
		GBLL CC 3 A_FadeOut(0.11);
		Stop;
	}
}

class RS_FatsoSoundWaveTrail : Actor   // CH Fatsos.txt:209
{
	Default
	{
		ProjectileKickBack 500;
		Radius 12;
		Height 6;
		Speed 56;
		DamageFunction (random(10,55));   // CH: Damage(random(10,55))
		DamageType "Plasma";
		Projectile;
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.15;
		XScale 2.0;
		YScale 0.55;
		SeeSound "";
		DeathSound "spit/spit2";
		Translation "0:255=#[255,255,0]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		GBLL A 3 Bright;
		GBLL B 3 Bright A_SetScale(1.5,0.45);
		GBLL C 3 Bright A_SetScale(1.1,0.25);
	Death:
		GBLL C 3 Bright A_SetScale(0.15,0.15);
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-42,42),random(-42,42),random(-8,8));   // RS_ZapFFAT ships via the Revenants lane (CH Fatsos.txt:269)
		LITN ABCD 1 Bright A_Explode(random(8,12),64,0);
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-42,42),random(-42,42),random(-8,8));
		LITN EFG 1 Bright A_Explode(random(8,12),64,0);
		Stop;
	}
}

class RS_ZapFFAT2 : Actor   // CH Fatsos.txt:245
{
	Default
	{
		Speed 1;
		Projectile;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.65;
		Scale 0.9;
		Translation "0:255=#[255,255,0]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-24,24),random(-24,24),random(-2,32));   // RS_ZapFFAT ships via the Revenants lane (CH Fatsos.txt:269)
		LITN ABCD 1 Bright A_Explode(random(1,2),32,0);
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-24,24),random(-24,24),random(-2,32));
		LITN EFG 1 Bright A_Explode(random(1,2),32,0);
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-24,24),random(-24,24),random(-2,32));
		LITN FEDB 1 Bright A_Explode(random(1,2),32,0);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cyan mancubus kit.  CH: Fatsos.txt:474-522.
// ---------------------------------------------------------------------------
class RS_CyanFatBall : Actor   // CH Fatsos.txt:474
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 32;
		Scale 1.1;
		DamageFunction (random(10,80));   // CH: Damage(random(10,80))
		DamageType "Ice";
		Projectile;
		+DONTHARMCLASS
		SeeSound "imp/attack";
		DeathSound "Ice/Hit2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CHCY ABCDFG 2 Bright A_SpawnItemEx("RS_IceFattTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAA 0 A_CustomMissile("RS_FrostLong2",0,0,random(0,359),CMF_OFFSETPITCH,random(-25,-5));
		Stop;
	}
}

class RS_IceFattTrail : Actor   // CH Fatsos.txt:502
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 32;
		Alpha 0.4;
		RenderStyle "Add";
		Projectile;
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CHCY ABCDFGABCDFG 3 Bright A_Jump(32,"Death");
	Death:
		TNT1 A 1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Abyss mancubus kit.  CH: Fatsos.txt:640-725.
// ---------------------------------------------------------------------------
class RS_AbyssFatsoBomb : Actor   // CH Fatsos.txt:640
{
	Default
	{
		Radius 7;
		Height 7;
		Speed 28;
		DamageFunction (random(20,85));   // CH: Damage(random(20,85))
		DamageType "Ice";
		Projectile;
		+USEBOUNCESTATE
		+BOUNCEONWALLS
		BounceFactor 1.1;
		BounceCount 3;
		WallBounceFactor 1.1;
		DeathSound "weapons/bfgx";
		Translation "0:255=%[0.00,0.00,0.18]:[0.22,0.50,0.44]";
	}
	States
	{
	Spawn:
		BFE1 ABCDEF 1 Bright;
	Fly:
		TNT1 A 0 A_SetScale(0.5,0.5);
		BFS1 A 2 Bright A_SetScale(0.7,0.4);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(4,4),random(-4,4),random(-2,2),4,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		BFS1 B 2 Bright A_SetScale(0.4,0.7);
		Loop;
	Bounce:
		TNT1 A 0 A_SetScale(1.5,0.5);
		BFE1 AB 1 Bright;
		TNT1 A 0 A_PlaySound("weapons/bfgx");
		TNT1 AAAAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,15),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BFE1 C 2 Bright A_Explode(random(10,75),128);
		BFE1 DEF 1 Bright;
		TNT1 A 0 A_SetScale(0.5,0.5);
		Goto Fly;
	Death:
		TNT1 A 0 A_SetScale(1.5,0.5);
		BFE1 AB 5 Bright;
		BFE1 C 5 Bright A_Explode(random(5,75),128);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-18,18),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(18,18),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BFE1 DEF 5 Bright;
		Stop;
	}
}

class RS_FatAbysswave : Actor   // CH Fatsos.txt:688
{
	Default
	{
		Radius 20;
		Height 16;
		Speed 25;
		DamageFunction (random(14,60));   // CH: Damage(random(14,60))
		DamageType "Plasma";
		Projectile;
		+MTHRUSPECIES
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.85;
		XScale 1.0;
		YScale 0.25;
		SeeSound "fatso/attack";
		DeathSound "weapons/bfgx";
		Translation "0:255=%[0.00,0.00,0.18]:[0.22,0.50,0.44]";
	}
	States
	{
	Spawn:
		DIS1 AB 1 Bright A_Weave(random(-1,7),random(-1,1),random(-4,4),random(-1,1));
		TNT1 AAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		DIS1 CFE 1 Bright A_Explode(random(7,17),88);
		TNT1 AAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		DIS1 DB 1 Bright A_Weave(random(-1,7),random(-1,1),random(-4,4),random(-1,1));
		TNT1 AAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		DIS1 G 6 Bright A_Explode(random(2,35),128);
		DIS1 H 4 Bright A_Explode(random(2,35),128);
		DIS1 I 2 Bright A_Explode(random(2,35),128);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// FireBlu mancubus kit.  CH: Fatsos.txt:870-963.
// ---------------------------------------------------------------------------
class RS_FireBluFatGround : Actor   // CH Fatsos.txt:870
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 10;
		DamageFunction (random(5,15));   // CH: Damage(random(5,15))
		DamageType "Fire";
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		RenderStyle "Add";
		XScale 1.33;
		YScale 0.9;
		Alpha 0.95;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200","160:160=177:177","162:162=184:184","163:163=204:204","164:164=186:186","165:165=204:204","166:166=189:189","167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 6 Bright;
		Goto Death;
	Death:
		FIRE CD 5 A_Explode(random(3,15),64);
		FIRE DD 1 A_Wander;
		FIRE EE 5 A_Explode(random(3,15),64);
		FIRE EE 1 A_Wander;
		FIRE DC 5 A_Explode(random(3,15),64);
		FIRE DD 1 A_Wander;
		FIRE DE 5 A_Explode(random(3,15),64);
		FIRE EE 1 A_Wander;
		FIRE FGH 4 Bright A_Explode(random(3,15),64);
		Stop;
	}
}

class RS_FireBluFatsoBal2 : Actor   // CH Fatsos.txt:907
{
	Default
	{
		Radius 20;
		Height 20;
		Mass 600;
		Speed 8;
		DamageFunction (random(15,50));   // CH: Damage(random(15,50))
		DamageType "Plasma";
		Projectile;
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
		MANF AB 3 A_SpawnItemEx("RS_FireBluFatGround",random(-32,32),random(-32,32),random(-3,3),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		MISL B 4 A_SetTranslucent(0.35);
		MISL C 1 A_Explode(random(5,20),176);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_FireBluFatGround",random(-128,128),random(-128,128),random(-3,3),0,0,0,0,SXF_NOCHECKPOSITION);
		MISL DDD 2 A_Explode(random(5,10),178);
		Stop;
	}
}

class RS_FireBluFatsoBal1 : Actor   // CH Fatsos.txt:936
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 45;
		DamageFunction (random(10,20));   // CH: Damage(random(10,20))
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.95;
		Scale 0.33;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "208:223=195:207","225:231=192:195";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 4 Bright A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BAL1 B 4 Bright A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(1,7),32);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Gray mancubus kit -- the spike volley.  CH: Fatsos.txt:1116-1146.
// (RS_FatsoSpikes2, CH Fatsos.txt:1148, shipped with the imp family.)
// ---------------------------------------------------------------------------
class RS_FatsoSpikes : Actor   // CH Fatsos.txt:1116
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 32;
		DamageFunction (random(28,85));   // CH: Damage(random(28,85))
		Projectile;
		DamageType "Melee";
		+NOGRAVITY
		+THRUGHOST
		SeeSound "monster/dknmsl";
		BounceSound "fire/fire3";
		DeathSound "weapons/boom1";
		Translation "144:151=90:95","64:79=96:109","236:239=104:111","1:2=111:111";
	}
	States
	{
	Spawn:
		RIP1 ABC 3 Bright A_SpawnItemEx("RS_FatsoSpikes2",0,0,1,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		RIP1 A 0 { bNOGRAVITY = false; }   // CH: a_changeflag(nogravity,false)
		RIP1 ABCABC 8 A_Explode(random(1,8),16);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,45,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,105,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,165,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,225,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,285,0);
		MISL D 1 A_CustomMissile("RS_CGNail",0,0,345,0);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The dropped weapon props and the replaced vanilla fireball.
// CH: Fatsos.txt:1265, 1283, 1418, 1592, 1906.
// ---------------------------------------------------------------------------
class RS_FatsoArmed : Actor   // CH Fatsos.txt:1265
{
	Default
	{
		Speed 0;
		Mass 50;
		+THRUACTORS
		-NOGRAVITY
	}
	States
	{
	Spawn:
		FAT2 I -1;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_FatShot2 : Actor replaces FatShot   // CH Fatsos.txt:1283
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 20;
		Damage 8;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "fatso/attack";
		DeathSound "fatso/shotx";
	}
	States
	{
	Spawn:
		MANF AB 4 Bright;
		Loop;
	Death:
		MISL B 8 Bright;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

class RS_FatsoArmed2 : Actor   // CH Fatsos.txt:1418
{
	Default
	{
		Speed 0;
		Mass 50;
		+THRUACTORS
		-NOGRAVITY
		Translation "48:63=112:112","64:79=112:127","13:15=125:127","236:239=125:127","144:151=125:127";
	}
	States
	{
	Spawn:
		FAT2 I -1;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_FatsoArmed3 : Actor   // CH Fatsos.txt:1592
{
	Default
	{
		Speed 0;
		Mass 50;
		+THRUACTORS
		-NOGRAVITY
		Translation "48:63=193:193","64:79=193:207","13:15=205:207","236:239=244:247","144:151=244:247";
	}
	States
	{
	Spawn:
		FAT2 I -1;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_FatsoArmed4 : Actor   // CH Fatsos.txt:1906
{
	Default
	{
		Speed 0;
		Mass 50;
		+THRUACTORS
		-NOGRAVITY
		Translation "48:63=250:251","64:79=250:254","13:15=254:254","236:239=254:254","144:151=254:254";
	}
	States
	{
	Spawn:
		FAT2 I -1;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Red (horned) mancubus kit.  CH: Fatsos.txt:2390-2485.
// (RS_Shot2Fatso, CH Fatsos.txt:2356, shipped with the lostsoul family.)
// ---------------------------------------------------------------------------
class RS_HBeastSmoke : Actor   // CH Fatsos.txt:2390
{
	Default
	{
		Radius 0;
		Height 0;
		Speed 0;
		Alpha 0.3;
		Scale 0.55;
		Projectile;
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		BISH QRSTUVW 3;
		BISH W 3 A_FadeOut(0.50);
		Stop;
	}
}

class RS_HBeastShot : Actor   // CH Fatsos.txt:2408
{
	Default
	{
		Radius 2;
		Height 3;
		Speed 23;
		Alpha 0.8;
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		+FLOORHUGGER
		-NOBLOCKMAP
		SeeSound "horn/attack";
		DeathSound "horn/shotx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CFFX N 6 Bright A_CustomMissile("RS_SparkPuff1",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 AAAAA 0 A_CustomMissile("RS_SparkPuff1",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		CFFX O 6 Bright A_CustomMissile("RS_SparkPuff1",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 AAAAA 0 A_CustomMissile("RS_SparkPuff1",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		CFFX P 6 Bright A_CustomMissile("RS_SparkPuff1",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 AAAAA 0 A_CustomMissile("RS_SparkPuff1",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
	Death:
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-130);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,130);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-10);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,10);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-150);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,150);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-30);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,30);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-170);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,170);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-50);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,50);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-60);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,60);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-70);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,70);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-80);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,80);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-95);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,95);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,-110);
		CFFX A 0 A_CustomMissile("RS_HBeastFlame",1,0,110);
		CFCF Q 0 A_Scream;
		CFCF Q 1 Bright A_Explode(random(20,50),128,0,1);
		CFCF QRSTUVXYZ 3 Bright;
		Stop;
	}
}

class RS_HBeastFlame : Actor   // CH Fatsos.txt:2462
{
	Default
	{
		Radius 5;
		Height 4;
		Speed 20;
		Alpha 0.8;
		Scale 1.25;
		Damage 1;
		Decal "DoomImpScorch";
		DamageType "Fire";
		Projectile;
		RenderStyle "Add";
		+FLOORHUGGER
		+STRIFEDAMAGE
		SeeSound "imp/shotx";
	}
	States
	{
	Spawn:
		CFCF ABCDEFGHIJKLMNOP 2 Bright A_Explode(random(1,5),22);
	Death:
		TNT1 A 1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black mancubus kit.  CH: Fatsos.txt:2523, 3021-3440.
// ---------------------------------------------------------------------------
class RS_BlackFatShotLongRange : Actor   // CH Fatsos.txt:2523
{
	Default
	{
		Radius 7;
		Height 6;
		Speed 42;
		DamageFunction (random(20,80));   // CH: Damage(random(20,80))
		DamageType "Fire";
		Projectile;
		RenderStyle "Add";
		Alpha 1;
		Scale 1.25;
		SeeSound "fatso/attack";
		DeathSound "fatso/shotx";
		Translation "0:255=%[0.00,0.50,0.00]:[0.99,1.99,0.34]";
	}
	States
	{
	Spawn:
		MANF AB 4 Bright A_SpawnItemEx("RS_Trail11",0,0,1);
		Loop;
	Death:
		MISL B 4 Bright A_Explode(random(20,80),128);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_BlackFatSplash",-12,0,0,random(3,21),0,random(1,9),angle*-1 + random(-15,15),SXF_NOCHECKPOSITION);
		MISL CD 4 Bright;
		Stop;
	}
}

class RS_ShadowSplash : Actor   // CH Fatsos.txt:3021
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 23;
		Mass 25;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		BounceCount 999;
		BounceType "Doom";   // CH: Bouncetype doom
		BounceFactor 1;
		DamageType "Plasma";
		WallBounceFactor 1.25;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		DeathSound "shadowbeast/pr1death";
		Alpha 0.75;
		Scale 1;
	}
	States
	{
	Spawn:
		BDP2 EE 1 Bright A_Wander;
		BDP2 FG 1 Bright A_Explode(random(10,35),128);
		BDP2 H 0 A_Jump(6,"Death");
		Loop;
	Death:
		BDP2 EF 4 Bright A_SetScale(1.8);
		BDP2 GHH 4 A_Explode(random(10,80),252);   // CH: BDP2 I -- no BDP2I* lump in the repo, in Desktop\CH\sprites or in ART SOURCE; the set is A-H (20 lumps, A/B/C 8-rot + D-H 0-rot) and CH's own third frame rendered nothing. D..H is a growing blast (25x25 -> 64x63), so held H, the final and largest frame, for I's 4 tics. 3 frames, 12 tics and 3 A_Explode calls all unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_ShadowBombBigEX : Actor   // CH Fatsos.txt:3057
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 38;
		Radius 14;
		Height 9;
		DamageFunction (random(50,200));   // CH: Damage(random(50,200))
		XScale 2.55;
		YScale 1.75;
		DamageType "Plasma";
		Projectile;
		+SPAWNSOUNDSOURCE
		+SEEKERMISSILE
		SeeSound "shadowbeast/pr1sight";
		DeathSound "shadowbeast/pr1death";
	}
	States
	{
	Spawn:
		BDP2 A 1 Bright A_Explode(random(40,60),128,0);
		BDP2 B 1 Bright A_SpawnItemEx("RS_ShadowBeast_BallFire",-12,0,0,random(9,33),0,random(-9,9),random(120,240),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_ShadowBeast_BallFire",0,0,0,random(9,33),0,random(-9,9),random(90,270),SXF_NOCHECKPOSITION);
		BDP2 C 1 Bright A_SeekerMissile(12,9);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(3.5,3.5);
		BDP2 DE 4 Bright A_Explode(random(10,50),258,0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_ShadowBeast_BallFire",0,0,0,random(9,33),0,random(-9,9),random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_ShadowBeast_BallFire",0,0,0,random(9,33),0,random(-9,9),random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_ShadowBeast_BallFire",0,0,0,random(9,33),0,random(-9,9),random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_ShadowBeast_BallFire",0,0,0,random(9,33),0,random(-9,9),random(-359,359),SXF_NOCHECKPOSITION);
		BDP2 FGH 3 Bright A_Explode(random(10,50),258,0);
		Stop;
	}
}

class RS_ShadowBombBig : Actor   // CH Fatsos.txt:3094
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 8;
		Radius 14;
		Height 9;
		DamageFunction (random(20,90));   // CH: Damage(random(20,90))
		Scale 1.8;
		DamageType "Plasma";
		Projectile;
		+SPAWNSOUNDSOURCE
		SeeSound "shadowbeast/pr1sight";
		DeathSound "shadowbeast/pr1death";
	}
	States
	{
	Spawn:
		BDP2 A 1 Bright A_Explode(random(10,30),128);
		BDP2 B 1 Bright A_CustomMissile("RS_ShadowBeast_Ball2",random(2,12),random(-20,20),CMF_AIMDIRECTION|CMF_SAVEPITCH,random(0,360),random(0,360));
		BDP2 C 1 Bright A_SpawnItemEx("RS_Trail11",0,7,0);
		Loop;
	Death:
		BDP2 DE 4 Bright A_Explode(random(10,40),162);
		BDP2 FGH 3 Bright A_Explode(random(10,30),128);
		Stop;
	}
}

class RS_ShadowBeast_BallFireEX : Actor   // CH Fatsos.txt:3123
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 20;
		Radius 10;
		Height 6;
		Damage 3;
		DamageType "Poison";
		Projectile;
		+SPAWNSOUNDSOURCE
		+RIPPER
		+THRUACTORS
		SeeSound "shadowbeast/pr1death";
		Decal "MummyScorch";
	}
	States
	{
	Spawn:
		BDP2 DEF 5 Bright A_Explode(random(5,20),32);
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(1.25,1.25);
		BDP2 G 5 Bright A_Explode(random(5,20),46);
		TNT1 A 0 A_SetScale(1.5,1.5);
		BDP2 H 5 Bright A_Explode(random(5,20),64);
		TNT1 AA 0 A_SpawnItemEx("RS_BlackFatSplash",0,0,0,random(3,21),0,random(1,9),0,SXF_NOCHECKPOSITION,128);
		Stop;
	}
}

class RS_BlackFatsoBurp : Actor   // CH Fatsos.txt:3154
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 23;
		Mass 25;
		Projectile;
		+NOGRAVITY
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		BounceCount 999;
		BounceType "Doom";   // CH: Bouncetype doom
		BounceFactor 1;
		DamageType "Plasma";
		WallBounceFactor 1.25;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		DeathSound "shadowbeast/pr1death";
		Alpha 0.75;
		Scale 1;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BDP2 EEFGH 3 Bright;
		BDP2 E 1 Bright { bNOGRAVITY = false; }      // CH: a_changeflag("NOGRAVITY",FALSE)
		BDP2 E 1 Bright { bFLOORHUGGER = true; }     // CH: a_changeflag("FLOORHUGGER",TRUE)
	Crawl:
		BDP2 EE 1 Bright A_SpawnItemEx("RS_BlackFatSplash",0,0,0,random(3,21),0,random(1,9),random(-359,359),SXF_NOCHECKPOSITION,232);
		BDP2 FG 1 Bright A_Explode(random(10,35),128);
		BDP2 H 0 A_Jump(6,"Death");
		Loop;
	Death:
		BDP2 EF 4 Bright A_SetScale(1.8);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_BlackFatSplash",0,0,0,random(3,21),0,random(1,9),random(-359,359),SXF_NOCHECKPOSITION,232);
		BDP2 GHH 4 A_Explode(random(10,80),252);   // CH: BDP2 I -- frame absent everywhere (set is A-H); held H, the final and largest blast frame, for I's 4 tics. 3 frames, 12 tics, 3 A_Explode calls unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_ShadowBeast_Ballex1 : Actor   // CH Fatsos.txt:3197
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 15;
		Radius 10;
		Height 6;
		DamageFunction (random(20,50));   // CH: Damage(random(20,50))
		DamageType "Poison";
		Projectile;
		+SPAWNSOUNDSOURCE
		SeeSound "shadowbeast/pr1sight";
		DeathSound "shadowbeast/pr1death";
	}
	States
	{
	Spawn:
		BDP2 ABC 4 Bright;
		Loop;
	Death:
		BDP2 DE 4 Bright A_Explode(random(10,40),102);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_BlackFatSplash",0,0,0,random(3,21),0,random(1,9),random(-359,359),SXF_NOCHECKPOSITION);
		BDP2 FGH 3 Bright A_Explode(random(10,30),88);
		Stop;
	}
}

class RS_BlackFatSplash : Actor   // CH Fatsos.txt:3224
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 12;
		Damage 2;
		PoisonDamage 12;
		SeeSound "none";
		Alpha 0.75;
		RenderStyle "Add";
		PoisonDamageType "Poison";
		DeathSound "slimeball/splat";
		BounceSound "slimeball/splat";
		Scale 0.75;
		Projectile;
		-NOGRAVITY
		+BOUNCEONWALLS
		+BOUNCEONFLOORS
		+USEBOUNCESTATE
		BounceType "Hexen";
		BounceCount 7;
		WallBounceFactor 1.1;
		BounceFactor 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BOGY ABC 2 Bright;
		Loop;
	Bounce:
		BOGY A 1 Bright;
		BOGY B 2 Bright ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),12,0,0)
		TNT1 A 0 A_SpawnItemEx("RS_Gas14",random(-20,20),random(-20,20),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		BOGY C 1 Bright;
		Goto Fly;
	Death:
		BOGY DEF 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_Gas14",random(-120,120),random(-120,120),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_ShadowBeast_BallFire : Actor   // CH Fatsos.txt:3267
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 15;
		Radius 10;
		Height 6;
		Damage 3;
		DamageType "Poison";
		Projectile;
		+SPAWNSOUNDSOURCE
		+RIPPER
		+THRUACTORS
		SeeSound "shadowbeast/pr1death";
		Decal "MummyScorch";
	}
	States
	{
	Spawn:
		BDP2 DEFGH 5 Bright A_Explode(random(5,20),26);
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_ShadowBeast_BallEx2 : Actor   // CH Fatsos.txt:3294
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Radius 16;
		Height 9;
		DamageType "Plasma";
		DamageFunction (random(16,60));   // CH: Damage(random(16,60))
		Speed 21;
		Scale 2.5;
		Projectile;
		+RANDOMIZE
		SeeSound "shadowbeast/pr2sight";
		DeathSound "shadowbeast/pr2death";
		Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
	Fly:
		BDP1 D 1 A_SpawnItemEx("RS_ShadowBeast_BallFire",random(0,-24),0,0,0,0,0,0,SXF_NOCHECKPOSITION,164);
		BDP1 E 1 A_Jump(8,"BB");
		Loop;
	BB:
		TNT1 A 0 ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),12,0,0)
		Goto Fly;
	Death:
		BDP1 FGHI 3 A_Explode(random(10,30),64,0);
		Stop;
	}
}

class RS_ShadowBeast_BallEx3 : Actor   // CH Fatsos.txt:3325
{
	Default
	{
		Alpha 1.0;
		Scale 2.4;
		RenderStyle "Add";
		Radius 12;
		Height 8;
		DamageFunction (random(20,60));   // CH: Damage(random(20,60))
		DamageType "Plasma";
		Speed 8;
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		SeeSound "shadowbeast/pr2sight";
		DeathSound "shadowbeast/pr2death";
		Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BDP1 E 1 A_SetTranslucent(0.25);
		BDP1 D 1 A_SetTranslucent(0.5);   // CH: BDPI -- typo for BDP1, no BDPI lump ships in CH; invisible there too
		BDP1 DEDEDED 2 A_BishopMissileWeave;
		BDP1 E 1 A_SetTranslucent(0.5);
		BDP1 D 1 A_SetTranslucent(0.25);
		BDP1 ED 2 A_BishopMissileWeave;
		TNT1 A 0 A_SeekerMissile(30,30);
		Loop;
	Death:
		BDP1 FGHI 3;
		Stop;
	}
}

class RS_ShadowBeast_Ball1 : Actor   // CH Fatsos.txt:3360
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 15;
		Radius 10;
		Height 6;
		DamageFunction (random(20,50));   // CH: Damage(random(20,50))
		DamageType "Poison";
		Projectile;
		+SPAWNSOUNDSOURCE
		SeeSound "shadowbeast/pr1sight";
		DeathSound "shadowbeast/pr1death";
	}
	States
	{
	Spawn:
		BDP2 ABC 4 Bright;
		Loop;
	Death:
		BDP2 DE 4 Bright A_Explode(random(10,40),102);
		BDP2 FGH 3 Bright A_Explode(random(10,30),88);
		Stop;
	}
}

class RS_ShadowBeast_Ball2 : Actor   // CH Fatsos.txt:3386
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Radius 8;
		Height 6;
		DamageType "Plasma";
		DamageFunction (random(10,45));   // CH: Damage(random(10,45))
		Speed 16;
		Projectile;
		+RANDOMIZE
		SeeSound "shadowbeast/pr2sight";
		DeathSound "shadowbeast/pr2death";
		Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
		BDP1 DE 1 A_BishopMissileWeave;
		Loop;
	Death:
		BDP1 FGHI 3;
		Stop;
	}
}

class RS_ShadowBeast_Ball3 : Actor   // CH Fatsos.txt:3411
{
	Default
	{
		Alpha 1.0;
		Scale 1.4;
		RenderStyle "Add";
		Radius 8;
		Height 6;
		DamageFunction (random(20,60));   // CH: Damage(random(20,60))
		DamageType "Plasma";
		Speed 20;
		Projectile;
		+RANDOMIZE
		SeeSound "shadowbeast/pr2sight";
		DeathSound "shadowbeast/pr2death";
		Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
		BDP1 E 1 A_SetTranslucent(0.55);
		BDP1 D 1 A_SetTranslucent(0.7);   // CH: BDPI -- typo for BDP1, no BDPI lump ships in CH; invisible there too
		BDP1 DEDEDED 2 A_BishopMissileWeave;
		BDP1 E 1 A_SetTranslucent(0.55);
		BDP1 D 1 A_SetTranslucent(0.3);
		BDP1 ED 2 A_BishopMissileWeave;
		Loop;
	Death:
		BDP1 FGHI 3;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White mancubus ("Angry Mama") kit.  CH: Fatsos.txt:3725-4075.
// ---------------------------------------------------------------------------
class RS_WhiteFatsoGroundZap : Actor   // CH Fatsos.txt:3725
{
	Default
	{
		Radius 12;
		Species "Fatso";
		Height 16;
		Speed 18;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+THRUSPECIES
		+FLOORHUGGER
		RenderStyle "Add";
		Alpha 1.75;
		Translation "Ice";
	}
	States
	{
	Spawn:
	Death:
		TNT1 A 1 NoDelay A_PlaySound("prieinfu");
		LITN ABCDEFGOPABCDEFGOPABCDEFGOP 2 Bright A_Explode(random(2,9),64,0);
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_WhiteFatsoAirZap : Actor   // CH Fatsos.txt:3752
{
	Default
	{
		Radius 8;
		Species "Fatso";
		Height 8;
		Speed 17;
		DamageFunction (random(1,2));   // CH: Damage(random(1,2))
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+SEEKERMISSILE
		+THRUSPECIES
		+RIPPER
		RenderStyle "Add";
		Alpha 1.75;
		Translation "Ice";
	}
	States
	{
	Spawn:
	Death:
		TNT1 A 1 NoDelay A_PlaySound("prieinfu");
		LITN ABCDEFGOPABCDEFGOPABCDEFGOPABCDEFGOP 2 Bright A_Weave(3,2,5,2);
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_WhiteFatScatter : Actor   // CH Fatsos.txt:3780
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 26;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		DamageType "Melee";
		Projectile;
		+DONTHARMCLASS
		XScale 0.77;
		YScale 0.33;
		SeeSound "ILLSHEAR";   // CH: $random ILLSHEAR { ILLSHEA1 ILLSHEA2 } -- CH ships no ILLSHEA2 lump, silent half the time there too
		DeathSound "spit/spit";
		Translation "231:231=4:4","208:223=80:86","168:191=192:196","32:47=4:4","250:254=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 AB 2 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Death:
		BAL2 C 4 A_SetTranslucent(0.55);
		BAL2 D 1;
		BAL2 E 2;
		Stop;
	}
}

class RS_WhiteFatNukeShow : Actor   // CH Fatsos.txt:3809
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 21;
		Projectile;
		XScale 0.55;
		YScale 1.74;
		+NOINTERACTION
		SeeSound "imp/attack";
		Translation "231:231=4:4","208:223=80:86","168:191=192:196","32:47=4:4","250:254=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 B 6 A_SetScale(0.44,1.86);
		BAL2 A 6 A_SetScale(0.33,1.99);
		BAL2 B 6 A_SetScale(0.22,2.22);
		BAL2 A 6 A_SetScale(0.11,2.44);
		Stop;
	}
}

class RS_WhiteFatMark : Actor   // CH Fatsos.txt:3833
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		FloatSpeed 1;
		+NOCLIP
		DeathSound "Juggernaut/Attack";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		TNT1 A 1 A_Scream;
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH",88,0,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH2",-88,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH3",0,88,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH4",-88,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH5",0,46,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH6",-46,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		CHTA A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH5",0,46,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH6",-46,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		CHTA A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH5",0,46,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH6",-46,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		JUBD A 0 A_SpawnItemEx("RS_WhiteFatNuke",0,0,random(128,256),0,0,-2,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	}
}

class RS_WhiteFatNuke : Actor   // CH Fatsos.txt:3881
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 25;
		Mass 8000;
		DamageFunction (random(100,200));   // CH: Damage(random(100,200))
		DamageType "Fire";
		Projectile;
		XScale 1.2;
		YScale 2.6;
		-NOGRAVITY
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.75;
		SeeSound "ARCAZAP7";
		DeathSound "NETHERDE";
		Translation "231:231=4:4","208:223=80:86","168:191=192:196","32:47=4:4","250:254=4:4","112:120=80:88","120:127=192:199","160:167=4:4","224:235=192:192","64:79=192:199","144:151=4:4","128:143=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 AB 1;
		Loop;
	Death:
		TNT1 A 0 A_SetScale(2.5,0.15);
		TNT1 A 0 A_Scream;
		BFE1 AB 3 Bright;
		BFE1 C 8 Bright A_Explode(random(80,155),326);
		TNT1 A 0 Radius_Quake(15,15,0,40,0);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_WhiteFatBall1 : Actor   // CH Fatsos.txt:3917
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 21;
		DamageFunction (random(20,50));   // CH: Damage(random(20,50))
		DamageType "Fire";
		Projectile;
		Scale 1.5;
		+DONTHARMCLASS
		+SEEKERMISSILE
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "231:231=4:4","208:223=80:86","168:191=192:196","32:47=4:4","250:254=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(128,"A2");
	A1:
		BAL2 AB 1 A_Weave(2,0,2,0);
		Loop;
	A2:
		BAL2 AB 1 A_Weave(2,0,-2,0);
		Loop;
	Death:
		BAL2 C 4;
		BAL2 D 1 A_Explode(random(10,25),32,0);
		BAL2 E 2;
		Stop;
	}
}

class RS_WhiteFatBall2 : RS_WhiteFatBall1 { Default { Speed 11; } }   // CH Fatsos.txt:3951
class RS_WhiteFatBall3 : RS_WhiteFatBall1 { Default { Speed 33; } }   // CH Fatsos.txt:3952
class RS_WhiteFatBall4 : RS_WhiteFatBall1 { Default { Speed 40; } }   // CH Fatsos.txt:3953
class RS_WhiteFatBall5 : RS_WhiteFatBall1 { Default { Speed 8;  } }   // CH Fatsos.txt:3954
class RS_WhiteFatBall6 : RS_WhiteFatBall1 { Default { Speed 16; } }   // CH Fatsos.txt:3955
class RS_WhiteFatBall7 : RS_WhiteFatBall1 { Default { Speed 27; } }   // CH Fatsos.txt:3956

class RS_WhiteFatRB : Actor   // CH Fatsos.txt:3958
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 1;
		DamageFunction (random(30,95));   // CH: Damage(random(30,95))
		DamageType "Plasma";
		Projectile;
		+ALWAYSPUFF
		RenderStyle "Add";
		Alpha 0.75;
		Scale 2.25;
		DeathSound "NETHERDE";
		Translation "112:120=80:88","120:127=192:199","160:167=4:4","224:235=192:192","64:79=192:199","144:151=4:4","128:143=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		TNT1 A 0 A_Scream;
		BFE1 AB 5 Bright;
		BFE1 C 8 Bright A_Explode(random(50,125),252);
		TNT1 A 0 Radius_Quake(15,15,0,40,0);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_WhiteFatRB3 : Actor   // CH Fatsos.txt:3987
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 1;
		DamageFunction (random(30,95));   // CH: Damage(random(30,95))
		DamageType "Plasma";
		Projectile;
		+ALWAYSPUFF
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.33;
		DeathSound "NETHERDE";
		Translation "112:120=80:88","120:127=192:199","160:167=4:4","224:235=192:192","64:79=192:199","144:151=4:4","128:143=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		TNT1 A 0 A_Scream;
		BFE1 AB 5 Bright;
		BFE1 C 8 Bright A_Explode(random(30,95),128);
		TNT1 A 0 Radius_Quake(9,9,0,30,0);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_WhiteFatRB4 : Actor   // CH Fatsos.txt:4016
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 11;
		DamageFunction (random(15,30));   // CH: Damage(random(15,30))
		DamageType "Plasma";
		Projectile;
		Scale 1.33;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "Crack/death";
		Translation "231:231=4:4","208:223=80:86","168:191=192:196","32:47=4:4","250:254=4:4";
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

class RS_WhiteFatRB2 : Actor   // CH Fatsos.txt:4047
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 11;
		DamageFunction (random(30,50));   // CH: Damage(random(30,50))
		DamageType "Plasma";
		Projectile;
		Scale 2;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "Crack/death";
		Translation "231:231=4:4","208:223=80:86","168:191=192:196","32:47=4:4","250:254=4:4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 A 3 A_SetScale(2.0,2.0);
		BAL2 B 3 A_SetScale(1.75,1.75);
		BAL2 A 3 A_SetScale(1.5,1.5);
		BAL2 B 3 A_SetScale(1.75,1.75);
	Death:
		BAL2 C 4 A_SetTranslucent(0.55);
		BAL2 D 1 A_Explode(random(15,30),128);
		BAL2 E 2 A_Explode(random(15,30),128);
		Stop;
	}
}
