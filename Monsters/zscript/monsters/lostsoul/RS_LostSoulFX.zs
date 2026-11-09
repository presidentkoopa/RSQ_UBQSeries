// ============================================================================
// RS_LostSoulFX.zs -- Colourful Hell Lost Soul family: support actors,
// projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\lostsouls.txt (3092
// lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_LostSoul.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here): RS_Zom, RS_ZomTierToken, RS_GrowRaisin, RS_CHBoner,
// RS_ColorTierIconCH..CH13, RS_HealthBundle, RS_BackPackBundle,
// RS_implyingclip, RS_CH_Shell, RS_CH_ShellBox, RS_CH_Cell, RS_CH_CellPack,
// RS_CH_MegaSphere, RS_CH_BFG9000, RS_CH_BlueArmor, RS_CH_PlasmaRifle,
// RS_SplashAbyss, RS_AbyssShotIdentifier, RS_WormLewd, RS_SparkPuff1,
// RS_Trail12, RS_HKREDDEATH, RS_REDTHINGSHK, RS_RedRevLoad,
// RS_CrackoBallTrail, RS_Bounc22, RS_Firespe2, RS_RedThingsLS.
// RS_RedThingsLS is special: its CH source is OUR file (lostsouls.txt:1218)
// but it already shipped with the demon family (RS_DemonFX.zs) -- referenced
// read-only, NOT redefined.
//
// CROSS-LANE (parallel cacodemon import, landed mid-session -- resolution
// verified against both trees and against CH on 2026-08-05):
//   * The caco lane's zscript/monsters/cacodemon/RS_CacodemonFX.zs already
//     defines, faithfully to CH (diffed), NINE classes this family fires:
//     RS_Cacospit1 (Cacodemons.txt:1299), RS_CacoFire2 (:1433),
//     RS_Cacofire3 (:1576), RS_Cacofire4 (:1612), RS_SpitFireCaco (:1774),
//     RS_SbombCaco (:1999), RS_CrackodemonBall (:2030), plus the shared
//     third-file externals RS_Zap88 (Barons.txt:2778) and RS_PlasmaBallSP4
//     (Hellknights.txt:2498). A second definition here would be a fatal
//     duplicate, so they are referenced READ-ONLY. THIS FILE HARD-DEPENDS
//     ON RS_CacodemonFX.zs BEING WIRED IN.
//   * RS_Trail11 (Revenants.txt:1625) likewise already ships with the
//     chaingunner family (RS_ChaingunnerFX.zs:69) -- referenced read-only.
//   * Caco BODIES (RS_CommonCaco Cacodemons.txt:1119, RS_BlueCaco :1326,
//     RS_YellowCaco :1640) are the caco lane's own tier members; they are
//     referenced here through runtime-assembled guards (the RS_CommonRevenant
//     idiom, RS_Zombieman.zs:2345) that self-activate the moment that lane's
//     body file compiles in, and through RS_RandomizerArc's runtime-resolved
//     drop names (RS_GreenCaco, RS_PurpleCaco included).
//
// FOREIGN FAMILY BODIES, GUARDED NOT DEFINED (each guard names its CH
// source; all self-activate when their family is imported):
//   Revenants.txt: CommonRevenant :1341, GreenRevenant :1464,
//     PurpleRevenant :1908, RedRevenant :2706.
//   Hellknights.txt: CommonHK :1171, GreenHK :1274, BlueHK :1380,
//     YellowHK :1674.
//   Cacodemons.txt: CommonCaco :1119, BlueCaco :1326, YellowCaco :1640.
//
// VANILLA CLASSES KEPT VANILLA (CH never defines them, so CH itself uses
// the engine's own): RevenantTracer, CacodemonBall, ArchvileFire, Health,
// HealthBonus, BackPack. Also vanilla actions A_BruisAttack and
// A_FatAttack1/2/3 fire vanilla BaronBall / FatShot, as in CH.
//
// RESOLVED 2026-08-06 -- XXBF frame T -> XXBF S, two sites (RS_BigHK2 and
// RS_BigHK3 Spawn, CH Hellknights.txt:1874/:1897). The set is A-S and stops
// there: 19 single-rotation lumps XXBFA0..XXBFS0, the same 19 in
// sprites/rs_lostsoul, sprites/monsters/fx, sprites/monsters/_src,
// Desktop\CH\sprites and ART SOURCE -- and none of them is a mirrored
// 8-character lump, so no later frame is hiding in a second half. CH's own
// "XXBF DEFGHIJKLMNOPQRST 2" therefore rendered nothing on its final 2-tic
// frame. The run is a fireball bloom: it grows to K/N (41x35), then fades
// P 24x33, Q 21x30, R 17x25, S 15x24. S is the last fade frame, so each
// site now reads "...OPQRSS", holding S for T's 2 tics. 17 frames and
// 34 tics per site, unchanged; the line carries no action call.
//
// RESOLVED 2026-08-06 -- MISL frame E -> MISL D, one site (RS_RedDeathRev
// Death, CH Revenants.txt:2946). Vanilla MISL is eight lumps, frames A-D
// (MISLA1, MISLA5, MISLA6A4, MISLA7A3, MISLA8A2, MISLB0, MISLC0, MISLD0),
// byte-identical name set in doom.wad and doom2.wad -- verified by reading
// both IWAD lump directories, nothing extracted -- and CH ships no MISL lump
// of its own beyond the three custom MISLX0/Y0/Z0 already imported. Frame E
// rendered nothing in CH too. This site was visible: 5 Bright tics closing
// the death of a seeking fireball. B->C->D is the vanilla rocket explosion,
// so D, its last frame, is held for E's 5 tics; the tic count and the
// A_Explode call are unchanged. The same MISL E remains at
// RS_ShotgunnerFX.zs:255 and :713 and RS_PainElementalFX.zs:1183, which are
// not this lane's files.
//
// ---------------------------------------------------------------------------
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite SBSI and sprite RMGG -- RESOLVED 2026-08-06, no longer in this
//     list. Both were CH typos with the real prefix already shipping (SBS1
//     and RNGG respectively), and both were corrected at their sites that
//     day under the owner's standing ruling that nothing renders invisible.
//     CH's originals are preserved as "// CH:" comments at each line.
//   * Sound ILLSHEAR (RS_IllHKGhost* SeeSound): CH SNDINFO's
//     $random ILLSHEAR { ILLSHEA1 ILLSHEA2 } names two lumps but CH ships
//     only ILLSHEA1.ogg -- half the roll is silent in CH itself. Our
//     SNDINFO and sounds/ mirror it exactly (ILLSHEA1 resolves here too).
//
// STANDING STRIPS, preserved at each site as "// CH:" comments: ACS
// announcers (AnnounceBlackSoul, AnnounceWhiteSoul); the ACS gameplay
// script BaronMissile (CHACS.acs:54 -- an ACS lead-predicted vanilla
// BaronBall shot; the ACS engine is not ported, 3 sites, flagged for the
// owner); the CHRandom_GibGenerator/NashGore gore chain (owner accepts
// vanilla gore; XDeath ANIMATIONS stay); DRLA RL*/RareArmorPool drops.
// RandomizerArc drop lines for not-yet-imported families are itemised at
// site as "// CH:" comments, restorable when those families land.
// ============================================================================

// ---------------------------------------------------------------------------
// In-file support: the cyan soul's eye glints.  CH: lostsouls.txt:153, :178.
// ---------------------------------------------------------------------------
class RS_CyanSoulEye : Actor   // CH lostsouls.txt:153
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		Scale 0.2;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "0:255=%[0.50,0.00,0.00]:[2.00,0.49,0.49]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BFE1 C 1 Bright A_Warp(AAPTR_TARGET,9,-11,13,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 1 Bright A_Warp(AAPTR_TARGET,9,-11,13,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_CyanSoulEye2 : Actor   // CH lostsouls.txt:178
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		Scale 0.2;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "0:255=%[0.50,0.00,0.00]:[2.00,0.49,0.49]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BFE1 C 1 Bright A_Warp(AAPTR_TARGET,9,11,13,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 1 Bright A_Warp(AAPTR_TARGET,9,11,13,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The abyss beetle's poison spit.  CH: lostsouls.txt:495.
// ---------------------------------------------------------------------------
class RS_BeetleSpitAbyss : Actor   // CH lostsouls.txt:495
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 20;
		DamageFunction (random(1,8));   // CH: Damage(random(1,8))
		PoisonDamage 1;
		RenderStyle "Add";
		Alpha 0.67;
		DamageType "Poison";
		Projectile;
		Gravity 0.02;
		-NOGRAVITY
		+USEBOUNCESTATE
		BounceType "Hexen";
		BounceFactor 1.25;
		BounceCount 4;
		Scale 0.25;
		DeathSound "imp/shotx";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BLVB A 1 Bright A_SpawnParticle("green",SPF_FULLBRIGHT|SPF_RELATIVE,random(25,50),random(1,2),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLVB B 1 Bright;
		Loop;
	Bounce:
		TNT1 A 0 ThrustThingZ(0,9,0,0);
		Goto Fly;
	Death:
		BLVB CDEF 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The green soul's poison splash.  CH: lostsouls.txt:825.
// ---------------------------------------------------------------------------
class RS_SplasherSoul : Actor   // CH lostsouls.txt:825
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 5;
		FastSpeed 5;
		DamageFunction (random(5,15));   // CH: Damage(random(5,15))
		DamageType "Poison";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		Scale 1.6;
		DeathSound "baron/shotx";
	}
	States
	{
	Spawn:
		BAL7 CDE 5 Bright A_Explode(random(5,15),48);   // per-frame explode: CH's lingering poison splash, deliberate
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The red soul's spit bolt.  CH: lostsouls.txt:1191.
// (RedThingsLS, lostsouls.txt:1218, already ships as RS_RedThingsLS with the
// demon family -- referenced read-only.)
// ---------------------------------------------------------------------------
class RS_SpitBoltLS : Actor   // CH lostsouls.txt:1191
{
	Default
	{
		Radius 11;
		Height 11;
		Mass 25;
		Speed 21;
		DamageFunction (random(5,42));   // CH: Damage(random(5,42))
		DamageType "Plasma";
		Projectile;
		Scale 0.60;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "fire/Fire4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 8 A_CustomMissile("RS_REDTHINGSHK",3,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		BAL1 C 4 A_SetTranslucent(0.35);
		BAL1 DE 5;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The queen bee's abdomen bomb glow.  CH: lostsouls.txt:1387.
// ---------------------------------------------------------------------------
class RS_BLSoulAss : Actor   // CH lostsouls.txt:1387
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		Scale 0.33;
		Projectile;
		+NOINTERACTION
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BBOM B 1 Bright A_Warp(AAPTR_MASTER,-2,0,-12,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BBOM B 0 A_SetScale(0.33,0.33);
		BBOM B 1 Bright A_Warp(AAPTR_MASTER,-2,0,-12,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BBOM B 0 A_SetScale(0.38,0.38);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The queen bee's seeker swarm.  CH: lostsouls.txt:1607, :1627, :1667.
// ---------------------------------------------------------------------------
class RS_BSoulHellNo2 : Actor   // CH lostsouls.txt:1607
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 15;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Alpha 1;
		Scale 0.25;
	}
	States
	{
	Spawn:
		WASP AB 2 Bright;
	Death:
		WASP AB 2 A_Stop;
		Stop;
	}
}

class RS_BSoulHellNo : Actor   // CH lostsouls.txt:1627
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 16;
		DamageFunction (random(1,2));   // CH: Damage(random(1,2))
		DamageType "Melee";
		Projectile;
		+SEEKERMISSILE
		Scale 0.45;
		SeeSound "baron/attack";
		DeathSound "baron/shotx";
	}
	States
	{
	Spawn:
		WASP A 2 Bright A_SeekerMissile(10,10,SMF_PRECISE);
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(0,120));
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(120,240));
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(240,359));
		TNT1 AAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		WASP B 2 Bright A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		Loop;
	Death:
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(0,120));
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(120,240));
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(240,359));
		WASP D 0 A_PlaySound("Hornet/Splat");
		Stop;
	XDeath:
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(0,120));
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(120,240));
		WASP BB 0 A_SpawnItemEx("RS_BSoulHellNo2",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(240,359));
		TNT1 A 3 A_Explode(random(10,30),32,0);
		WASP BBB 0 A_SpawnItemEx("RS_BSoulHellNo3",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(0,120));
		WASP BBB 0 A_SpawnItemEx("RS_BSoulHellNo3",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(120,240));
		WASP BBB 0 A_SpawnItemEx("RS_BSoulHellNo3",random(-8,8),random(-8,8),random(-8,8),random(1,9),0,random(-15,15),random(240,359));
		Stop;
	}
}

class RS_BSoulHellNo3 : Actor   // CH lostsouls.txt:1667
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 20;
		DamageFunction (random(1,2));   // CH: Damage(random(1,2))
		Projectile;
		+THRUGHOST
		+SEEKERMISSILE
		+THRUACTORS
		Scale 0.35;
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		WASP A 1 Bright A_SeekerMissile(32,255,SMF_PRECISE|SMF_LOOK,255);
		WASP B 1 Bright A_Explode(1,22);   // per-frame explode: CH's swarm graze DoT, deliberate
		WASP A 1 Bright A_Jump(12,"Death");
		Loop;
	Death:
		CBAL CDEFG 1 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The queen bee's stingers.  CH: lostsouls.txt:1693, :1728.
// ---------------------------------------------------------------------------
class RS_BSoulStinger1 : Actor   // CH lostsouls.txt:1693
{
	Default
	{
		Radius 2;
		Height 2;
		DamageFunction (random(5,25));   // CH: damage(random(5,25))
		DamageType "Melee";
		PoisonDamage 6;
		PoisonDamageType "Poison";
		Speed 35;
		YScale 0.6;
		XScale 1.4;
		Decal "BulletChip";
		Species "Hornet";
		SeeSound "Jam/Jamd";
		AttackSound "moloch/nailhitbleed";
		DeathSound "gas/gas1";
		Projectile;
		+SPAWNSOUNDSOURCE
		+BLOODSPLATTER
		+THRUSPECIES
		Translation "0:255=%[0.00,0.00,0.00]:[0.36,0.36,0.36]";
	}
	States
	{
	Spawn:
		BLAD A 1 Bright;
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,5),64);   // per-frame explode: CH's gas burst, deliberate
		FBL1 EFG 1 Bright A_Explode(random(2,8),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_Trail12",0,0,1);
		Stop;
	}
}

class RS_BSoulStinger2 : Actor   // CH lostsouls.txt:1728
{
	Default
	{
		Radius 2;
		Height 2;
		DamageFunction (random(5,25));   // CH: damage(random(5,25))
		DamageType "Melee";
		PoisonDamage 6;
		PoisonDamageType "Poison";
		Speed 1;
		Species "Hornet";
		YScale 0.6;
		XScale 1.4;
		Decal "BulletChip";
		SeeSound "Jam/Jamd";
		AttackSound "moloch/nailhitbleed";
		DeathSound "gas/gas1";
		Projectile;
		+SPAWNSOUNDSOURCE
		+BLOODSPLATTER
		+THRUSPECIES
		Translation "0:255=%[0.00,0.00,0.00]:[0.36,0.36,0.36]";
	}
	States
	{
	Spawn:
		BLAD A random(12,32) Bright A_Jump(128,"Delay");
		BLAD A 0 A_ScaleVelocity(random(12,83));
		Goto Fly;
	Fly:
		BLAD A 2 Bright;
		Loop;
	Delay:
		BLAD A 12 Bright A_Jump(64,"Delay");
		BLAD A 0 A_ScaleVelocity(random(12,83));
		Goto Fly;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,5),64);   // per-frame explode: CH's gas burst, deliberate
		FBL1 EFG 1 Bright A_Explode(random(2,8),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_Trail12",0,0,1);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The shifter's transformation eggs.  CH: lostsouls.txt:2112, :2158.
// Minion monsters -- no tier, no token.  Their hatch spawns are foreign
// family bodies, runtime-guarded (see file header).
// ---------------------------------------------------------------------------
class RS_HKEgg : Actor   // CH lostsouls.txt:2112
{
	Default
	{
		Health 50;
		Radius 20;
		Height 32;
		Species "whitelsoul";
		Monster;
		+NOPAIN
		+NOTARGET
		+FLOAT
		+FLOATBOB
		+NOGRAVITY
		+LOOKALLAROUND
		-COUNTKILL
		Speed 3;
		DropItem "RS_HealthBundle";
		DropItem "RS_implyingclip", 128, 3;
		DropItem "RS_CH_Shell", 72, 2;
		DropItem "RS_CH_Cell", 32, 2;
		Alpha 0.95;
		Scale 2;
		Translation "168:191=80:95","208:223=80:95","224:231=4:4","232:235=94:94";
	}
	States
	{
	Spawn:
		BAL1 AB 4 A_Look;
		Loop;
	See:
		BAL1 A 16 A_PlaySound("Knight/sight");
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 C 2 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonHK")); if (cls) A_PainAttack(cls,0,PAF_NOSKULLATTACK); }   // CH: A_PainAttack("CommonHK",0,PAF_NOSKULLATTACK) -- HK family (Hellknights.txt:1171) not imported yet; self-activates when RS_CommonHK lands
		Goto Death;
	Death:
		BAL1 DE 3 Bright;
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_RevEgg : Actor   // CH lostsouls.txt:2158
{
	Default
	{
		Health 50;
		Radius 20;
		Height 32;
		Species "whitelsoul";
		Monster;
		+NOPAIN
		+NOTARGET
		+FLOAT
		+FLOATBOB
		+NOGRAVITY
		+LOOKALLAROUND
		-COUNTKILL
		Speed 3;
		DropItem "RS_HealthBundle";
		DropItem "RS_implyingclip", 128, 2;
		DropItem "RS_CH_Shell", 72, 2;
		DropItem "RS_CH_Cell", 32;
		Alpha 0.95;
		Scale 2;
		Translation "168:191=80:95","208:223=80:95","224:231=4:4","232:235=94:94";
	}
	States
	{
	Spawn:
		BAL1 AB 4 A_Look;
		Loop;
	See:
		BAL1 A 16 A_PlaySound("skeleton/sight");
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 C 2 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonRevenant")); if (cls) A_PainAttack(cls,0,PAF_NOSKULLATTACK); }   // CH: A_PainAttack("CommonRevenant",0,PAF_NOSKULLATTACK) -- revenant family (Revenants.txt:1341) not imported yet; self-activates when RS_CommonRevenant lands
		Goto Death;
	Death:
		BAL1 DE 3 Bright;
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The shifter's soul wisps.  CH: lostsouls.txt:2204.
// ---------------------------------------------------------------------------
class RS_WSSmore : Actor   // CH lostsouls.txt:2204
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 12;
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
	}
	States
	{
	Spawn:
		SPIR FGH 4;
		Goto Death;
	Death:
		SPIR IJ 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The EX soul's ice beam chain.  CH: lostsouls.txt:2665, :2697, :2740.
// ---------------------------------------------------------------------------
class RS_SoulexBeam : Actor   // CH lostsouls.txt:2665
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 69;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		DamageType "Ice";
		Projectile;
		+DONTHARMCLASS
		+THRUSPECIES
		+FULLVOLDEATH
		Species "whitelsoul";
		Scale 0.77;
		SeeSound "ILLSHEAR";
		DeathSound "NETHERDE";
		Translation "0:255=%[2.00,2.00,2.00]:[0.42,0.43,0.47]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam2",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*12,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam2",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*16,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam2",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*8,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam2",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*20,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		Loop;
	Death:
		PUFI EFGH 1 A_Explode(random(10,20),64,0);   // per-frame explode: CH's beam impact, deliberate
		Stop;
	}
}

class RS_SoulexBeam2 : Actor   // CH lostsouls.txt:2697
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 69;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		DamageType "Ice";
		Projectile;
		+DONTHARMCLASS
		+THRUSPECIES
		Species "whitelsoul";
		Scale 0.77;
		RenderStyle "Add";
		SeeSound "ILLSHEAR";
		DeathSound "spit/spit";
		Translation "0:255=%[2.00,2.00,2.00]:[0.42,0.43,0.47]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*16,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*24,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*12,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*32,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*24,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*12,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*16,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*28,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*16,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*24,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*12,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*32,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*24,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*12,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 A 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*16,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
		BAL2 B 1 A_SpawnItemEx("RS_SoulexBeam3",cos(pitch)*1,0,sin(pitch)*1,cos(pitch)*28,0,-sin(pitch)*1,0,SXF_TRANSFERPITCH);
	Death:
		BAL2 ABABABABA 1 A_Explode(random(2,12),32,0);   // per-frame explode: CH's beam wash, deliberate
		Stop;
	}
}

class RS_SoulexBeam3 : Actor   // CH lostsouls.txt:2740
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 69;
		DamageFunction (random(10,30));   // CH: Damage(random(10,30))
		DamageType "Ice";
		Projectile;
		+DONTHARMCLASS
		+THRUSPECIES
		Species "whitelsoul";
		RenderStyle "Add";
		Scale 0.77;
		SeeSound "ILLSHEAR";
		DeathSound "spit/spit";
		Translation "0:255=%[2.00,2.00,2.00]:[0.42,0.43,0.47]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 AB 1;
	Death:
		BAL2 ABABABABABABABABABABABABABA 1 A_Explode(random(2,12),32,0);   // per-frame explode: CH's beam wash, deliberate
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The EX soul's charging skull shot and its ground fire.  CH: lostsouls.txt
// :2768, :2800.
// ---------------------------------------------------------------------------
class RS_SOULEXSoulCharge : Actor   // CH lostsouls.txt:2768
{
	Default
	{
		Radius 16;
		Height 8;
		Speed 21;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		+THRUSPECIES
		Species "whitelsoul";
		RenderStyle "Add";
		DamageFunction (random(20,90));   // CH: Damage(random(20,90))
		DamageType "Melee";
		Alpha 0.75;
		Scale 0.5;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		Translation "0:255=%[2.00,2.00,2.00]:[0.42,0.43,0.47]";
	}
	States
	{
	Spawn:
		ETHS E 1 Bright A_SeekerMissile(3,3);
		ETHS FF 1 Bright A_SpawnItemEx("RS_SpiralSawAby",0,0,3,0,0,0,0,SXF_TRANSFERTRANSLATION);
		RED9 A 0 A_CustomMissile("RS_GroundRedLSoul",0,0);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(2);
		SPIR ABCDEDCBAE 5 Bright A_Explode(random(2,20),128);   // per-frame explode: CH's soul detonation, deliberate
		Stop;
	}
}

class RS_GroundRedLSoul : Actor   // CH lostsouls.txt:2800
{
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
		YScale 0.3;
		XScale 0.95;
		Translation "0:255=%[2.00,2.00,2.00]:[0.42,0.43,0.47]";
	}
	States
	{
	Spawn:
		RED8 ABC 3 Bright A_Explode(random(2,10),128);   // per-frame explode: CH's crawling ground fire, deliberate
		RED8 FGH 3 Bright A_Explode(random(2,10),128);
		RED8 D 1 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The EX soul's phase switches.  CH: lostsouls.txt:2833-2836.
// ---------------------------------------------------------------------------
class RS_WhiteSoulAdsOff  : Inventory { Default { Inventory.MaxAmount 1; } }   // CH lostsouls.txt:2833
class RS_WhiteSoulAdsOff2 : Inventory { Default { Inventory.MaxAmount 1; } }   // CH lostsouls.txt:2834
class RS_WhiteSoulAdsOff3 : Inventory { Default { Inventory.MaxAmount 1; } }   // CH lostsouls.txt:2835
class RS_WhiteSoulAdsOff4 : Inventory { Default { Inventory.MaxAmount 1; } }   // CH lostsouls.txt:2836

// ---------------------------------------------------------------------------
// The EX soul's orbiting skulls.  CH: lostsouls.txt:2838, :3011.
// Minion monsters -- no tier, no token.  Their late-phase summons are
// foreign family bodies, runtime-guarded (see file header).
// ---------------------------------------------------------------------------
class RS_SkullWSoulEX1 : Actor   // CH lostsouls.txt:2838
{
	Default
	{
		Radius 16;
		Height 32;
		Mass 50;
		Speed 12;
		Health 80;
		Monster;
		+FLOAT
		+NOGRAVITY
		+NOBLOOD
		+INVULNERABLE
		+NOCLIP
		-COUNTKILL
		+NOTARGET
		+NOINFIGHTING
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+THRUSPECIES
		+NOICEDEATH
		RenderStyle "Subtract";
		Alpha 1.0;
		Species "whitelsoul";
		BloodColor "Black";
		Scale 0.65;
		Obituary "%o was tagged by a skull";
		Translation "176:191=0:0","208:223=0:0","160:167=0:0","48:63=0:0";   // CH carries a commented-out alternate translation after this string
	}
	States
	{
	Spawn:
		SKUL AB 1;
	Fly:
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff",1,"See");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff2",1,"A2");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff3",1,"A3");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff4",1,"A4");
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,0,64,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,12,52,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,24,40,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,36,28,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,24,16,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,12,2,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,0,-10,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff",1,"See");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff2",1,"A2");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff3",1,"A3");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff4",1,"A4");
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,-12,-6,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,-24,2,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,-36,16,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,-24,28,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,-12,40,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,-6,52,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	A2:
		TNT1 A 0 { bINVULNERABLE = false; }   // CH: A_ChangeFlag("Invulnerable",FALSE)
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		SKUL ABC 6 Bright A_Wander;
		SKUL C 1 A_FaceTarget;
		SKUL C 4 ThrustThing(int(angle),13,0,0);   // CH: thrustthing(angle,13,0,0)
		SKUL C 32 Bright;
		TNT1 A 0 { bNOCLIP = false; }   // CH: A_ChangeFlag("Noclip",FALSE)
		SKUL C 6 Bright A_Stop;
		SKUL C 10 Bright A_SetScale(1.0,1.0);
		SKUL DDDDDDDDDDDDDDDDD 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKUL D 10 Bright A_SetScale(1.25,1.25);
		SKUL DDDDDDDDDDDDDDDDD 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKUL D 10 Bright A_SetScale(1.5,1.5);
		SKUL EFGH 10 Bright;
		TNT1 A 0 A_Jump(64,"A21","A22","A23");
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonRevenant")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("CommonRevenant",...) -- Revenants.txt:1341, not imported yet; self-activates when it lands
		SKUL IJK 5;
		Stop;
	A21:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","GreenRevenant")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("GreenRevenant",...) -- Revenants.txt:1464, not imported yet
		SKUL IJK 5;
		Stop;
	A22:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","PurpleRevenant")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("PurpleRevenant",...) -- Revenants.txt:1908, not imported yet
		SKUL IJK 5;
		Stop;
	A23:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","RedRevenant")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("RedRevenant",...) -- Revenants.txt:2706, not imported yet
		SKUL IJK 5;
		Stop;
	A3:
		TNT1 A 0 { bINVULNERABLE = false; }   // CH: A_ChangeFlag("Invulnerable",FALSE)
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		SKUL ABC 6 Bright A_Wander;
		SKUL C 1 A_FaceTarget;
		SKUL C 4 ThrustThing(int(angle),13,0,0);   // CH: thrustthing(angle,13,0,0)
		SKUL C 32 Bright;
		TNT1 A 0 { bNOCLIP = false; }   // CH: A_ChangeFlag("Noclip",FALSE)
		SKUL C 6 Bright A_Stop;
		SKUL C 10 Bright A_SetScale(1.0,1.0);
		SKUL DDDDDDDDDDDDDDDDD 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKUL D 10 Bright A_SetScale(1.25,1.25);
		SKUL DDDDDDDDDDDDDDDDD 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKUL D 10 Bright A_SetScale(1.5,1.5);
		SKUL EFGH 10 Bright;
		TNT1 A 0 A_Jump(64,"A31","A32","A33");
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonHK")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("CommonHK",...) -- Hellknights.txt:1171, not imported yet
		SKUL IJK 5;
		Stop;
	A31:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","BlueHK")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("BlueHK",...) -- Hellknights.txt:1380, not imported yet
		SKUL IJK 5;
		Stop;
	A32:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","GreenHK")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("GreenHK",...) -- Hellknights.txt:1274, not imported yet
		SKUL IJK 5;
		Stop;
	A33:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","YellowHK")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("YellowHK",...) -- Hellknights.txt:1674, not imported yet
		SKUL IJK 5;
		Stop;
	A4:
		TNT1 A 0 { bINVULNERABLE = false; }   // CH: A_ChangeFlag("Invulnerable",FALSE)
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		SKUL ABC 6 Bright A_Wander;
		SKUL C 1 A_FaceTarget;
		SKUL C 4 ThrustThing(int(angle),13,0,0);   // CH: thrustthing(angle,13,0,0)
		SKUL C 32 Bright;
		TNT1 A 0 { bNOCLIP = false; }   // CH: A_ChangeFlag("Noclip",FALSE)
		SKUL C 6 Bright A_Stop;
		SKUL C 10 Bright A_SetScale(1.0,1.0);
		SKUL DDDDDDDDDDDDDDDDD 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKUL D 10 Bright A_SetScale(1.25,1.25);
		SKUL DDDDDDDDDDDDDDDDD 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKUL D 10 Bright A_SetScale(1.5,1.5);
		SKUL EFGH 10 Bright;
		TNT1 A 0 A_Jump(64,"A41","A42","A43");
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonCaco")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("CommonCaco",...) -- Cacodemons.txt:1119, caco lane lands this session; self-activates
		SKUL IJK 5;
		Stop;
	A41:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonCaco")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("CommonCaco",...) -- Cacodemons.txt:1119, caco lane lands this session
		SKUL IJK 5;
		Stop;
	A42:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","BlueCaco")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("BlueCaco",...) -- Cacodemons.txt:1326, caco lane lands this session
		SKUL IJK 5;
		Stop;
	A43:
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","YellowCaco")); if (cls) A_SpawnItemEx(cls,-2,0,3,0,0,1,0,SXF_NOCHECKPOSITION); }   // CH: A_SpawnitemEx("YellowCaco",...) -- Cacodemons.txt:1640, caco lane lands this session
		SKUL IJK 5;
		Stop;
	See:
		TNT1 A 0 { bINVULNERABLE = false; }   // CH: A_ChangeFlag("Invulnerable",FALSE)
		TNT1 A 0 { bNOBLOOD = false; }   // CH: A_ChangeFlag("NoBlood",FALSE)
		SKUL AB 6 Bright A_Chase;
		Loop;
	Missile:
		TNT1 A 0 { bNOCLIP = false; }   // CH: A_ChangeFlag("NoClip",FALSE)
		SKUL C 10 Bright A_FaceTarget;
		SKUL D 4 Bright A_CustomMissile("RS_SoulShotWEX",5,0);
		SKUL CD 4 Bright;
	Pain:   // CH's Missile falls through into Pain, kept
		SKUL E 3 Bright;
		SKUL E 3 Bright A_Pain;
		Goto See;
	Death:
		SKUL F 6 Bright;
		SKUL G 6 Bright A_Scream;
		SKUL H 6 Bright;
		SKUL I 6 Bright A_NoBlocking;
		SKUL JK 6;
		Stop;
	}
}

class RS_SkullWSoulEX2 : RS_SkullWSoulEX1   // CH lostsouls.txt:3011
{
	States
	{
	Spawn:
		SKUL AB 1;
	Fly:
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff",1,"See");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff2",1,"A2");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff3",1,"A3");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff4",1,"A4");
		SKUL A 5 Bright A_Warp(AAPTR_MASTER,16,0,54,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,-12,42,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 1 Bright A_Warp(AAPTR_MASTER,16,-24,30,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 1 Bright A_Warp(AAPTR_MASTER,16,-36,18,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,-24,6,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,-12,-12,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 3 Bright A_Warp(AAPTR_MASTER,16,0,-20,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff",1,"See");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff2",1,"A2");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff3",1,"A3");
		TNT1 A 0 A_JumpIfInventory("RS_WhiteSoulAdsOff4",1,"A4");
		SKUL B 3 Bright A_Warp(AAPTR_MASTER,16,12,-16,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,24,-2,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 1 Bright A_Warp(AAPTR_MASTER,16,36,6,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 1 Bright A_Warp(AAPTR_MASTER,16,24,18,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL B 2 Bright A_Warp(AAPTR_MASTER,16,12,30,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SKUL A 2 Bright A_Warp(AAPTR_MASTER,16,6,42,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	}
}

// ---------------------------------------------------------------------------
// The orbiting skulls' shot.  CH: lostsouls.txt:3043.
// ---------------------------------------------------------------------------
class RS_SoulShotWEX : Actor   // CH lostsouls.txt:3043
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 24;
		DamageFunction (random(5,33));   // CH: Damage(random(5,33))
		DamageType "Melee";
		Projectile;
		RenderStyle "Subtract";
		Alpha 0.8;
		Scale 0.75;
		SeeSound "skull/melee";
		DeathSound "skull/melee";
		Translation "176:191=0:0","208:223=0:0","160:167=0:0","48:63=0:0";   // CH carries a commented-out alternate translation after this string
	}
	States
	{
	Spawn:
		SKUL CD 1 Bright;
		Loop;
	Death:
		SKUL ABAB 1 A_FadeOut(0.33);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The EX soul's afterimage.  CH: lostsouls.txt:3068.
// ---------------------------------------------------------------------------
class RS_LSoulEXShade : Actor   // CH lostsouls.txt:3068
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
		StencilColor "black";
		Alpha 0.75;
		Scale 1.25;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ETHS A 2 Bright A_SetScale(1.33,1.33);
		ETHS A 2 Bright A_FadeOut(0.25);
		ETHS A 2 Bright A_SetScale(1.5,1.5);
		ETHS A 2 Bright A_FadeOut(0.25);
		ETHS A 2 Bright A_SetScale(1.67,1.67);
		ETHS A 2 Bright A_FadeOut(0.15);
		Stop;
	}
}

// ===========================================================================
// THIRD-FILE EXTERNALS.  Everything below is referenced by lostsouls.txt
// (directly or transitively) and defined elsewhere in CH.  Grouped by CH
// source file.
// ===========================================================================

// ---------------------------------------------------------------------------
// Revenants.txt externals -- the shifter's revenant-form arsenal.
// (RevenantTracer is vanilla; CH never defines it.)
// ---------------------------------------------------------------------------
class RS_PsychPuff : Actor   // CH Revenants.txt:2279 -- blue soul's psychic bullet puff
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+RANDOMIZE
		RenderStyle "Translucent";
		Alpha 0.5;
		VSpeed 1;
		Mass 5;
		Scale 0.3;
	}
	States
	{
	Spawn:
		PLSE A 4 Bright;
		PLSE B 4;
	Melee:
		PLSE CDE 4;
		Stop;
	}
}

class RS_AcidBlast1 : Actor   // CH Revenants.txt:1595
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 14;
		FastSpeed 25;
		DamageFunction (random(5,55));   // CH: Damage (random(5,55))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "baron/attack";
		DeathSound "baron/shotx";
		Decal "BaronScorch";
	}
	States
	{
	Spawn:
		BAL7 A 2 Bright A_SeekerMissile(11,11,SMF_PRECISE);
		BAL7 B 2 Bright A_SpawnItemEx("RS_Trail11",0,3,0);
		Loop;
	Death:
		BAL7 CDE 6 Bright;
		Stop;
	}
}

// RS_Trail11 -- ceded: already defined in RS_ChaingunnerFX.zs (chaingunner family); referenced read-only, see header.
class RS_zap7 : Actor   // CH Revenants.txt:1855
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 15;
		FastSpeed 32;
		DamageFunction (random(20,50));   // CH: Damage (random(20,50))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "weapons/plasmaf";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSE A 2 Bright A_ScaleVelocity(1.15);
		Loop;
	Death:
		PLSE CDE 6 Bright;
		Stop;
	}
}

class RS_Purp1 : Actor   // CH Revenants.txt:2123
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 13;
		FastSpeed 14;
		DamageFunction (random(10,30));   // CH: Damage (random(10,30))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "baron/attack";
		DeathSound "weapons/plasmax";
		Translation "16:47=250:254","48:79=250:254","80:111=250:254","128:143=250:254","144:151=253:254","152:191=250:254";
	}
	States
	{
	Spawn:
		BAL1 AA 1 Bright A_Explode(random(8,18),45);   // per-frame explode: CH's graze aura, deliberate
		BAL1 B 2 Bright A_SpawnItemEx("RS_Trail22",0,3,0);
		BAL1 A 0 A_SeekerMissile(4,5);
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(35,45),64);
		Stop;
	}
}

class RS_Trail22 : Actor   // CH Revenants.txt:2153
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.75;
		Alpha 0.4;
		Translation "16:47=250:254","48:79=250:254","80:111=250:254","128:143=250:254","144:151=253:254","152:191=250:254";
	}
	States
	{
	Spawn:
		BAL1 CDE 6 Bright;
		Goto Death;
	Death:
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_Homer1 : Actor   // CH Revenants.txt:2527
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 11;
		FastSpeed 22;
		DamageFunction (random(8,52));   // CH: Damage (random(8,52))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "fire/fire1";
		DeathSound "fire/fire5";
	}
	States
	{
	Spawn:
		SBS1 A 0 A_PlaySound("Fire/fire3");   // sprite SBSI: proven missing in CH itself (zero-tic, CH typo for SBS1), see header
		SBS1 AB 2 Bright A_SeekerMissile(18,18,SMF_PRECISE);
		SBS1 CD 2 Bright A_SpawnItemEx("RS_SparkPuff1",0,2,10);
		Loop;
	Death:
		MISL BCD 6 Bright A_Explode(random(5,35),64);   // per-frame explode: CH's blast bloom, deliberate
		Stop;
	}
}

class RS_RedDeathRev : Actor   // CH Revenants.txt:2916
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 24;
		FastSpeed 38;
		DamageFunction (random(25,85));   // CH: Damage (random(25,85))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.65;
		SeeSound "Forgotten/Attack";
		DeathSound "spell/Impact1";
		Translation "76:79=44:47","136:143=184:191","128:136=175:183","64:79=176:191","208:223=171:181","161:161=170:170","144:151=180:191";
	}
	States
	{
	Spawn:
		FRGO C 1 Bright A_SeekerMissile(7,12);
		FRGO D 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,4,0,0,0,0,128);
		FRGO C 1 Bright A_SeekerMissile(7,12);
		FRGO D 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,4,0,0,0,0,128);
		Loop;
	Death:
		MISL B 3 Bright A_SetScale(1.4);
		MISL C 3 A_SetTranslucent(0.65);
		MISL D 3 Bright A_Explode(random(5,20),128);
		MISL D 5 Bright A_Explode(random(5,35),128);   // CH: MISL E -- vanilla MISL is eight lumps, frames A-D (MISLA1/A5/A6A4/A7A3/A8A2/B0/C0/D0), identical in doom.wad and doom2.wad, and CH ships no MISL lump of its own; frame E rendered nothing in CH too. This one was VISIBLE -- 5 Bright tics ending the death of a seeking fireball. B->C->D is the vanilla explosion, so held D, its last frame, for E's 5 tics. Tic count and A_Explode unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Barons.txt externals -- cyan trail, abyss saw, and the shifter's
// baron-form arsenal.
// ---------------------------------------------------------------------------
class RS_BaronCyanBombTrail : Actor   // CH Barons.txt:699 -- cyan soul's rush trail
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		Speed 1;
		RenderStyle "Add";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
		Alpha 0.25;
	}
	States
	{
	Spawn:
		SPIR EDCBA 3 Bright;
		Stop;
	}
}

class RS_SpiralSawAby : Actor   // CH Barons.txt:1230 -- the soul charge's saw wake
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		Speed 1;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.55;
		XScale 1.26;
		YScale 0.75;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		SPIR EDCBA 3 Bright A_Explode(random(2,10),88);   // per-frame explode: CH's saw wake DoT, deliberate
		Stop;
	}
}

class RS_Spspit2 : Actor   // CH Barons.txt:2237
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 25;
		DamageFunction (random(10,72));   // CH: Damage(Random(10,72))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "baron/attack";
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		BAL7 A 2 Bright A_SpawnItemEx("RS_Trail12",0,0,8);
		BAL7 B 2 Bright A_SeekerMissile(2,2);
		Loop;
	Death:
		BAL7 CDE 3 Bright;
		Stop;
	}
}

class RS_SmashBalls2 : Actor   // CH Barons.txt:2380
{
	Default
	{
		Radius 12;
		Height 18;
		Speed 11;
		Mass 4;
		DamageFunction (random(5,35));   // CH: Damage(random(5,35))
		DamageType "Plasma";
		Gravity 0.1;
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
		+BOUNCEONFLOORS
		+USEBOUNCESTATE
		+EXPLODEONWATER
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.88;
		BounceType "Hexen";
		BounceCount 7;
		BounceFactor 2;
		WallBounceFactor 0.1;
		Scale 1.5;
		SeeSound "caco/attack";
		BounceSound "Bomb/bounce";
		DeathSound "caco/shotx";
		Translation "168:191=192:207","208:223=193:202","250:254=197:197","231:231=224:224";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL2 AB 6 Bright;
		Loop;
	Bounce.floor:
		BAL2 A 5 Bright;
		TNT1 AAAAA 0 A_CustomMissile("RS_STracerBlue",0,0,random(1,120),0);
		TNT1 AAAAA 0 A_CustomMissile("RS_STracerBlue",0,0,random(121,240),0);
		TNT1 AAAAA 0 A_CustomMissile("RS_STracerBlue",0,0,random(241,359),0);
		BAL2 B 5 Bright A_Jump(64,"FollowMe");
		TNT1 A 0 A_Jump(12,"Death");
		Goto Fly;
	FollowMe:
		BAL2 AB 3 Bright A_SeekerMissile(2,2);
		TNT1 A 0 A_Jump(12,"Death");
		Goto Fly;
	Death:
		BAL2 C 3 Bright A_SetTranslucent(0.4);
		BAL2 DE 6 Bright A_Explode(random(5,20),128);
		Stop;
	}
}

class RS_STracerBlue : Actor   // CH Barons.txt:2434
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 2;
		DamageFunction (random(5,17));   // CH: Damage(random(5,17))
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Projectile;
		+FLOORHUGGER
		+THRUGHOST
		-NOGRAVITY
		+DONTSPLASH
		SeeSound "weapons/diasht";
		DeathSound "weapons/firex3";
		Translation "0:255=%[0.00,0.00,0.57]:[1.02,1.15,1.99]";
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_CStaffMissileSlither;
		TNT1 A 0 A_SpawnItem("RS_STracerPuffBlue",0,0);
		TNT1 A 0 A_Jump(24,"Death");
		Loop;
	Death:
		FTRA K 4 Bright;
		FTRA L 4 Bright A_Explode(random(5,15),32);
		FTRA MNO 3 Bright;
		Stop;
	}
}

class RS_STracerPuffBlue : Actor   // CH Barons.txt:2466
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
		ExplosionDamage 1;
		+FLOORHUGGER
		-NOGRAVITY
		+DONTSPLASH
		Translation "0:255=%[0.00,0.00,0.57]:[1.02,1.15,1.99]";
	}
	States
	{
	Spawn:
		FTRA ABCDEFGHIJ 3 Bright;
		Stop;
	}
}

class RS_BaronWave : Actor   // CH Barons.txt:2659
{
	Default
	{
		Radius 9;
		Height 10;
		Speed 21;
		FastSpeed 50;
		DamageFunction (random(5,17));   // CH: Damage(random(5,17))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		+EXPLODEONWATER
		RenderStyle "Add";
		Alpha 0.75;
		BounceType "Hexen";
		BounceCount 2;
		WallBounceFactor 0.7;
		Scale 0.7;
		SeeSound "caco/attack";
		BounceSound "Bomb/bounce";
		DeathSound "caco/shotx";
		Translation "168:223=250:254","224:231=250:250","168:191=250:254";
	}
	States
	{
	Spawn:
		SBS1 ABCD 8 Bright;
		Loop;
	Death:
		BAL2 C 2 Bright A_SetScale(1.1);
		BAL2 D 3 Bright A_SetTranslucent(0.4);
		BAL2 E 6 Bright A_Explode(random(3,15),88);
		Stop;
	}
}

class RS_Spear11 : Actor   // CH Barons.txt:2695
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 42;
		FastSpeed 68;
		DamageFunction (random(10,85));   // CH: Damage(Random(10,85))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "baron/attack";
		DeathSound "Litn/litn3";
		Translation "112:127=250:254","0:0=250:254","112:113=224:224","192:193=224:224","192:207=250:254";
	}
	States
	{
	Spawn:
		SPER AB 1 Bright A_SpawnItemEx("RS_TrailB",0,0,2);
		Loop;
	Death:
		PLSE CDE 3 Bright A_SpawnItemEx("RS_Zap88",0,0,2,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_TrailB : Actor   // CH Barons.txt:2722
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 31;
		FastSpeed 52;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.6;
		SeeSound "baron/attack";
		DeathSound "weapons/plasmax";
		Translation "112:127=250:254","0:0=250:254","112:113=224:224","192:193=224:224","192:207=250:254";
	}
	States
	{
	Spawn:
		SPER AB 4 Bright A_SpawnItemEx("RS_TrailC",0,0,1);
		Goto Death;
	Death:
		PLSE CDE 2 Bright A_Explode(7,18);
		Stop;
	}
}

class RS_TrailC : Actor   // CH Barons.txt:2750
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 31;
		FastSpeed 52;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.3;
		SeeSound "baron/attack";
		DeathSound "weapons/plasmax";
		Translation "112:127=250:254","0:0=250:254","112:113=224:224","192:193=224:224","192:207=250:254";
	}
	States
	{
	Spawn:
		BAL2 AB 4 Bright;
		Goto Death;
	Death:
		PLSE CDE 2 Bright;
		Stop;
	}
}

// RS_Zap88 -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
class RS_BaronStar : Actor   // CH Barons.txt:3023
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 28;
		FastSpeed 38;
		DamageFunction (random(5,25));   // CH: Damage(random(5,25))
		DamageType "Fire";
		Species "BaronOfHell";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		STRS AB 2 Bright A_SeekerMissile(3,3);
		STRS CD 2 Bright A_Weave(4,1,6,0);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,25),108);
		BBOM EFG 6 Bright A_Explode(random(5,30),108);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Archviles.txt externals -- the brown soul's heal ring and the shifter's
// archvile-form arsenal.  (ArchvileFire is vanilla; CH never defines it.)
// ---------------------------------------------------------------------------
class RS_BlueGash : Actor   // CH Archviles.txt:2685
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;
		+RANDOMIZE
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.45;
		Scale 2;
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Goto Death;
	Death:
		PLSE ABCDE 4;
		Stop;
	}
}

class RS_BigBolt2 : Actor   // CH Archviles.txt:2752
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 17;
		DamageFunction (random(25,95));   // CH: Damage(random(25,95))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 A 2 Bright A_SpawnItemEx("RS_BlueGash",0,0,6);
		BFS1 B 2 Bright A_SeekerMissile(7,10);
		Loop;
	Death:
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_Explode(random(25,75),128);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_ArcRing1 : Actor   // CH Archviles.txt:3195
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 8;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.75;
		Scale 1;
	}
	States
	{
	Spawn:
		RNGG ABCDABCDABCDABCDABCDABCD 3 Bright;
		Goto Death;
	Death:
		RNGG A 0 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,3);
		RNGG ABCD 4 Bright;
		Stop;
	}
}

class RS_ArcRing2 : Actor   // CH Archviles.txt:3222
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 18;
		Mass 999999;
		Gravity 10;
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		+DONTBLAST
		+DONTTHRUST
		BounceCount 999;
		BounceType "Hexen";
		BounceFactor 1;
		WallBounceFactor 0.9;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.75;
		Scale 1;
	}
	States
	{
	Spawn:
		RNGG A 0;
		Goto Fly;
	Fly:
		TNT1 A 0 { bFLOORHUGGER = true; }   // CH: A_changeflag("floorhugger",true)
		RNGG A 1 Bright { bNOGRAVITY = true; }   // CH: A_changeflag("nogravity",true)
		TNT1 A 0 { bFLOORHUGGER = false; }   // CH: A_changeflag("floorhugger",false)
		RNGG A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("nogravity",false)
		TNT1 A 0 A_SetScale(0.7,1.44);
		RNGG BB 1 Bright A_Wander;
		RNGG C 1 Bright A_CustomMissile("RS_FireHKBall1",4,random(-20,20),random(0,360),CMF_AIMOFFSET,random(0,360));
		TNT1 A 0 Bright A_CustomMissile("RS_FireHKBall1",4,random(-20,20),random(0,360),CMF_AIMOFFSET,random(0,360));
		RNGG C 1 Bright A_SpawnItemEx("RS_ArchRingHelp",0,0,3,0,0,0,0,SXF_NOCHECKPOSITION,128);
		TNT1 A 0 { bFLOORHUGGER = true; }   // CH: A_changeflag("floorhugger",true)
		RNGG D 1 Bright { bNOGRAVITY = true; }   // CH: A_changeflag("nogravity",true)
		TNT1 A 0 { bFLOORHUGGER = false; }   // CH: A_changeflag("floorhugger",false)
		RNGG A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("nogravity",false)
		TNT1 A 0 A_SetScale(1.0,1.0);
		RNGG D 1 Bright A_Explode(random(8,18),32);   // per-frame explode in loop: CH's rolling fire ring, deliberate
		RNGG D 0 A_Jump(6,"Death");
		Loop;
	Death:
		TNT1 A 0 A_Stop;
		TNT1 A 0 { bFLOORHUGGER = true; }   // CH: A_changeflag("floorhugger",true)
		RNGG ABCD 4 Bright;
		Stop;
	}
}

class RS_ArchRingHelp : Actor   // CH Archviles.txt:3277 -- the brown soul's death heal ring
{
	Default
	{
		Health 9999;
		Monster;
		Radius 12;
		Height 2;
		-ACTIVATEMCROSS
		-COUNTKILL
		-SHOOTABLE
		+NOTARGET
		+NEVERTARGET
		+THRUACTORS
		+INVISIBLE
		+NOCLIP
		Speed 4;
		Mass 5000;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto See;
	See:
		RNGG A 0 A_RadiusGive("RS_GrowRaisin",60,RGF_MONSTERS|RGF_CORPSES,1);
		RNGG A 3 Bright A_VileChase;
		RNGG A 0 A_CheckSight("Death");   // sprite RMGG: proven missing in CH itself (zero-tic, CH typo for RNGG), see header
		RNGG A 3 Bright A_VileChase;
		RNGG A 0 A_CheckSight("Death");   // CH: RMGG -- CH typo; RNGG is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		RNGG A 3 Bright A_VileChase;
		RNGG A 0 A_CheckSight("Death");   // CH: RMGG -- CH typo; RNGG is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		RNGG A 3 Bright A_VileChase;
		RNGG A 0 A_CheckSight("Death");   // CH: RMGG -- CH typo; RNGG is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Death;
	Heal:
		BBOM CDE 2 Bright;
		Goto Death;
	Death:
		TNT1 A 2;
		Stop;
	}
}

class RS_ArchSpawnerOrb : Actor   // CH Archviles.txt:3319 -- the shifter's summon orb
{
	Default
	{
		Health 13;
		Monster;
		Radius 17;
		Height 13;
		+NOGRAVITY
		+SPAWNFLOAT
		+NOBLOOD
		+NOTRIGGER
		+MISSILEMORE
		+MISSILEEVENMORE
		-ACTIVATEMCROSS
		-COUNTKILL
		+LOOKALLAROUND
		+THRUACTORS
		RenderStyle "Add";
		ActiveSound "vile/active";
		Speed 33;
		FloatSpeed 33;
		Scale 0.75;
		Alpha 0.95;
		Mass 2;
	}
	States
	{
	Spawn:
		VIOB A 1 Bright A_SetScale(0.75,0.65);
		VIOB B 1 Bright A_Wander;
		VIOB C 1 Bright A_Look;
		VIOB D 1 Bright A_SetScale(0.75,0,75);   // CH's own three-arg call (scaley 0 falls back to scalex), kept verbatim
		VIOB E 3 Bright A_Wander;
		VIOB F 1 Bright A_Look;
		VIOB G 1 Bright A_SetScale(0.65,0,75);
		VIOB H 1 Bright A_Wander;
		VIOB I 1 Bright A_Look;
		VIOB J 1 Bright A_SetScale(0.65,0,75);
		Loop;
	See:
		VIOB A 1 Bright A_SetScale(0.75,0.65);
		VIOB B 1 Bright A_Wander;
		VIOB C 1 Bright A_Chase;
		VIOB D 1 Bright A_SetScale(0.75,0,75);
		VIOB E 3 Bright A_Wander;
		VIOB F 1 Bright A_Chase;
		VIOB G 1 Bright A_SetScale(0.65,0,75);
		VIOB H 1 Bright A_Wander;
		VIOB I 1 Bright A_Chase;
		VIOB J 1 Bright A_SetScale(0.65,0,75);
		Loop;
	Missile:
		VIOB A 1 Bright A_SetSpeed(40);
		VIOB A 2 Bright A_Wander;
		VIOB C 2 Bright;
		VIOB E 2 Bright A_CheckSight("FireIt");
		VIOB G 2 Bright A_Wander;
		VIOB I 2 Bright;
		Goto Missile+1;
	FireIt:
		VIOB B 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION);   // vanilla ArchvileFire, as in CH
		VIOB B 1 A_SpawnItemEx("RS_RandomizerArc",0,0,6,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die;
		Stop;
	Death:
		MISL BCD 3 Bright;
		Stop;
	}
}

class RS_RandomizerArc : RandomSpawner   // CH Archviles.txt:3388 -- the summon orb's monster table
{
	Default
	{
		DropItem "RS_CommonImp", 255, 439;
		DropItem "RS_GreenImp", 255, 270;
		DropItem "RS_BlueImp", 255, 120;
		DropItem "RS_PurpleImp", 255, 83;
		DropItem "RS_YellowImp", 255, 47;
		DropItem "RS_CommonZombie", 255, 439;
		DropItem "RS_GreenZombie", 255, 270;
		DropItem "RS_BlueZombie", 255, 120;
		DropItem "RS_PurpleZombie", 255, 83;
		DropItem "RS_YellowZombie", 255, 47;
		DropItem "RS_CommonSG", 255, 439;
		DropItem "RS_GreenSG", 255, 270;
		DropItem "RS_BlueSG", 255, 120;
		DropItem "RS_PurpleSG", 255, 83;
		DropItem "RS_YellowSG", 255, 47;
		DropItem "RS_CommonRevenant", 255, 666;   // restored 2026-08-05 with the revenant import
		DropItem "RS_GreenRevenant", 255, 270;
		DropItem "RS_BlueRevenant", 255, 120;
		DropItem "RS_PurpleRevenant", 255, 90;
		DropItem "RS_CommonBaron", 255, 439;      // restored 2026-08-05 with the baron import
		DropItem "RS_GreenBaron", 255, 270;
		DropItem "RS_BlueBaron", 255, 120;
		DropItem "RS_PurpleBaron", 255, 83;
		DropItem "RS_YellowBaron", 255, 47;
		DropItem "RS_CommonCGuy", 255, 439;
		DropItem "RS_GreenCGuy", 255, 270;
		DropItem "RS_BlueCGuy", 255, 120;
		DropItem "RS_PurpleCGuy", 255, 83;
		DropItem "RS_YellowCGuy", 255, 47;
		DropItem "RS_CommonRevenant", 255, 666;   // CH lists the common revenant twice; both preserved
		DropItem "RS_CommonLSoul", 255, 439;
		DropItem "RS_GreenLSoul", 255, 270;
		DropItem "RS_BlueLSoul", 255, 120;
		DropItem "RS_PurpleLSoul", 255, 83;
		DropItem "RS_YellowLSoul", 255, 47;
		DropItem "RS_CommonCaco", 255, 439;   // caco lane lands this session; DropItem names resolve at runtime
		DropItem "RS_GreenCaco", 255, 270;
		DropItem "RS_BlueCaco", 255, 120;
		DropItem "RS_PurpleCaco", 255, 83;
		DropItem "RS_YellowCaco", 255, 47;
		DropItem "RS_CommonHK", 255, 439;   // restored 2026-08-05: the HK family landed
		DropItem "RS_GreenHK", 255, 270;
		DropItem "RS_BlueHK", 255, 120;
		DropItem "RS_PurpleHK", 255, 83;
		DropItem "RS_YellowHK", 255, 47;
		DropItem "RS_CommonDemon", 255, 439;
		DropItem "RS_GreenDemon", 255, 270;
		DropItem "RS_BlueDemon", 255, 120;
		DropItem "RS_PurpleDemon", 255, 83;
		DropItem "RS_YellowDemon", 255, 47;
		DropItem "RS_CommonArch", 255, 180;       // restored 2026-08-06 with the archvile import
	}
}

class RS_ReAComet : Actor   // CH Archviles.txt:3632
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 28;
		DamageFunction (random(15,88));   // CH: Damage(random(15,88))
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.85;
		Projectile;
		+BOUNCEONWALLS
		BounceType "Doom";
		BounceCount 2;
		BounceFactor 1.05;
		WallBounceFactor 1.1;
		BounceSound "Fire/fire4";
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
		Scale 3;
	}
	States
	{
	Spawn:
		VBA3 AB 3 Bright A_SpawnItemEx("RS_ReATrail",0,2,0,0,0,0,0,128);
		Loop;
	Death:
		CBAL C 0 { bISMONSTER = true; }   // CH: A_changeflag(ismonster,true)
		CBAL C 0 A_Jump(256,"See");
	See:
		CBAL C 0 A_SetSpeed(1);
		CBAL CDEFG 3 Bright A_Chase(null,null,CHF_RESURRECT);   // CH: A_Chase("","",CHF_RESURRECT)
		Stop;
	Heal:
		CBAL CDEFG 1 Bright;
		Stop;
	}
}

class RS_ReATrail : Actor   // CH Archviles.txt:3671
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 28;
		FastSpeed 38;
		DamageFunction (random(5,10));   // CH: Damage(random(5,10))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		Scale 0.7;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		STRS A 0;
		Goto Death;
	Death:
		BBOM A 2 Bright;
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 1 Bright A_Explode(random(3,10),88);
		BBOM EFG 6 Bright A_Explode(random(3,10),88);
		Stop;
	}
}

class RS_BVileOrb1 : Actor   // CH Archviles.txt:4245
{
	Default
	{
		Radius 8;
		Height 9;
		Speed 6;
		DamageFunction (random(12,45));   // CH: Damage(Random(12,45))
		DamageType "Fire";
		Projectile;
		+BOUNCEONWALLS
		BounceFactor 1.2;
		BounceType "Hexen";
		WallBounceFactor 1.2;
		BounceCount 6;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
		Translation "32:47=0:0","168:191=5:8","208:223=109:112","231:231=250:250";
	}
	States
	{
	Spawn:
		BAL2 A 6 Bright;
		Goto Fly;
	Fly:
		BAL2 AB 8 Bright A_SpawnItemEx("RS_BVileOrb2",0,0,1);
		Loop;
	Death:
		BAL2 C 6 Bright A_SetScale(2,2);
		BAL2 DE 6 Bright A_Explode(random(12,64),64);
		Stop;
	}
}

class RS_BVileOrb2 : Actor   // CH Archviles.txt:4278
{
	Default
	{
		Radius 8;
		Height 9;
		Speed 2;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.85;
		Translation "32:47=0:0","168:191=5:8","208:223=109:112","231:231=250:250";
	}
	States
	{
	Spawn:
		BAL2 AB 6 Bright;
		Goto Death;
	Death:
		BAL2 A 6 Bright A_SetScale(0.6,0.6);
		BAL2 B 6 Bright A_SetScale(0.35,0.35);
		BAL2 A 6 Bright A_SetScale(0.2,0.2);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Hellknights.txt externals -- the red soul's death burst chain and the
// EX soul's HK-form arsenal.
// ---------------------------------------------------------------------------
class RS_BaronsBlueBalls : Actor   // CH Hellknights.txt:1491
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 18;
		FastSpeed 25;
		DamageFunction (random(10,45));   // CH: Damage(Random(10,45))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "baron/attack";
		DeathSound "weapons/plasmax";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BAL7 AB 4 Bright;
		Loop;
	Death:
		PLSE CDE 3 Bright;
		Stop;
	}
}

class RS_HKBolt2 : Actor   // CH Hellknights.txt:1642
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 19;
		FastSpeed 38;
		DamageFunction (random(10,50));   // CH: Damage(random(10,50))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		Scale 0.7;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
		Translation "168:223=250:254","224:231=250:250","168:191=250:254";
	}
	States
	{
	Spawn:
		SBS1 A 3 Bright A_SeekerMissile(2,2);
		SBS1 B 3 Bright A_Weave(3,1,5,0);
		Loop;
	Death:
		BAL2 C 2 Bright A_SetScale(1.1);
		BAL2 D 3 Bright A_SetTranslucent(0.4);
		BAL2 E 6 Bright A_Explode(random(5,30),88);
		Stop;
	}
}

class RS_FireHKBall1 : Actor   // CH Hellknights.txt:1802 -- fired by RS_ArcRing2
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 15;
		DamageFunction (random(10,40));   // CH: Damage(random(10,40))
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.9;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Decal "BaronScorch";
	}
	States
	{
	Spawn:
		BRB2 AB 6 Bright A_CustomMissile("RS_SparkPuff1",1,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		BRB2 CDEFGHI 3 Bright A_Explode(random(2,6),32);   // per-frame explode: CH's fizzling burst, deliberate
		Stop;
	}
}

class RS_BigHK : Actor   // CH Hellknights.txt:1827
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 18;
		DamageFunction (random(10,77));   // CH: Damage(random(10,77))
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.9;
		Scale 2;
		SeeSound "imp/attack";
		DeathSound "weapons/rocklx";
		Decal "BaronScorch";
	}
	States
	{
	Spawn:
		BRB2 ABABAB 2 Bright A_SpawnItemEx("RS_BigHK2",random(-8,2),random(-12,12),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BRB2 C 1 Bright A_CustomMissile("RS_BigHK3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRB2 D 1 Bright A_CustomMissile("RS_BigHK3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRB2 E 1 Bright A_CustomMissile("RS_BigHK3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRB2 FGHI 3 Bright A_Explode(random(2,6),32);
		Stop;
	}
}

class RS_BigHK2 : Actor   // CH Hellknights.txt:1856
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		DamageFunction (random(15,45));   // CH: Damage(random(15,45))
		Projectile;
		DamageType "Fire";
		RenderStyle "Add";
		Scale 1.33;
		Alpha 0.9;
		+NOCLIP
		SeeSound "fire/fire3";
	}
	States
	{
	Spawn:
		XXBF AB 2 Bright;
		XXBF C 2 Bright A_Explode(random(5,21),100,0);
		XXBF DEFGHIJKLMNOPQRSS 2 Bright;   // CH: XXBF T -- the set is A-S and stops there (19 single-rotation lumps XXBFA0..XXBFS0, identical in sprites/rs_lostsoul, sprites/monsters/fx, Desktop\CH\sprites and ART SOURCE; no mirrored lump hides a later frame). CH's own final 2-tic frame rendered nothing. The run is a fireball bloom that peaks at K/N (41x35) and fades out P 24x33 -> S 15x24, so S is the last fade frame; held S for T's 2 tics. 17 frames, 34 tics unchanged; the line carries no action. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_BigHK3 : Actor   // CH Hellknights.txt:1879
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 12;
		DamageFunction (random(15,45));   // CH: Damage(random(15,45))
		Projectile;
		DamageType "Fire";
		RenderStyle "Add";
		Scale 1.33;
		Alpha 0.9;
		+NOCLIP
		SeeSound "fire/fire3";
	}
	States
	{
	Spawn:
		XXBF AB 2 Bright;
		XXBF C 2 Bright A_Explode(random(5,21),88,0);
		XXBF DEFGHIJKLMNOPQRSS 2 Bright;   // CH: XXBF T -- frame absent from every tree (set is A-S); held S, the last fade frame, for T's 2 tics. 17 frames, 34 tics unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_THEBEEHK : Actor   // CH Hellknights.txt:2131
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 36;
		DamageFunction (random(1,3));   // CH: Damage(random(1,3))
		RenderStyle "Add";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		+SEEKERMISSILE
		Scale 1.7;
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		VBA3 A 1 NoDelay A_SeekerMissile(32,255,SMF_PRECISE);
		VBA3 B 1 Bright A_Explode(random(1,2),42);   // per-frame explode: CH's graze DoT, deliberate
		Loop;
	Death:
		CBAL CCDDEEFFGG 1 Bright A_SpawnItemEx("RS_THEBEEHK2",random(-9,9),random(-9,9),random(-5,5),0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_THEBEEHK2 : Actor   // CH Hellknights.txt:2157
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 23;
		DamageFunction (random(1,2));   // CH: Damage(random(1,2))
		RenderStyle "Add";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		+SEEKERMISSILE
		+THRUACTORS
		Scale 0.35;
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 A 1 Bright A_SeekerMissile(32,255,SMF_PRECISE|SMF_LOOK,255);
		BAL1 B 1 Bright A_Explode(1,22);   // per-frame explode: CH's swarm graze DoT, deliberate
		BAL1 A 1 Bright A_Jump(12,"Death");
		Loop;
	Death:
		CBAL CDEFG 3 Bright;
		Stop;
	}
}

// RS_PlasmaBallSP4 -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// ---------------------------------------------------------------------------
// Fatsos.txt externals -- the EX soul's mancubus-form arsenal.
// ---------------------------------------------------------------------------
class RS_GreenBomb1 : Actor   // CH Fatsos.txt:1437
{
	Default
	{
		Radius 8;
		Height 10;
		Speed 14;
		FastSpeed 16;
		DamageFunction (random(20,75));   // CH: Damage(random(20,75))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		Scale 1.6;
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
		BAL2 CDE 6 Bright A_Explode(random(8,37),64);
		Stop;
	}
}

class RS_BlueFT : Actor   // CH Fatsos.txt:1611
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 0;
		Damage 0;   // bare constant stays bare
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 2;
		SeeSound "Spell/Lightn";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 A 6 Bright;
		Goto Death;
	Death:
		BFS1 A 4 Bright A_SetScale(1.6,1.6);
		BFS1 A 4 Bright A_SetScale(1.2,0.2);
		BFS1 A 4 Bright A_SetScale(0.8,0.8);
		BFS1 A 4 Bright A_SetScale(0.5,0.5);
		BFS1 A 4 Bright A_SetScale(0.1,0.1);
		Stop;
	}
}

class RS_BlueFT3 : Actor   // CH Fatsos.txt:1641
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 25;
		Damage 0;   // bare constant stays bare
		Projectile;
		+NOINTERACTION
		Scale 0.5;
		RenderStyle "Add";
		Alpha 1.25;
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 AB 2 Bright;
		Goto Death;
	Death:
		BFS1 A 2 Bright A_SetScale(0.6,0.6);
		BFS1 B 2 Bright A_SetScale(0.4,0.4);
		BFS1 A 2 Bright A_SetScale(0.2,0.2);
		Stop;
	}
}

class RS_BlueFT2 : Actor   // CH Fatsos.txt:1666
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 50;
		DamageFunction (random(10,70));   // CH: Damage(random(10,70))
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.5;
		SeeSound "fatso/attack";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Fly;
	Fly:
		BFS1 A 1 Bright A_SpawnItemEx("RS_BlueFT3",0,0,1,0,0,0,0);
		BFS1 B 1 Bright A_SpawnItemEx("RS_BlueFT3",0,0,0,0,0,0,0);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(0.3,0.3);
		BFE1 AB 8 Bright;
		TNT1 A 0 A_SetScale(0.1,0.1);
		BFE1 CDEF 8 Bright;
		Stop;
	}
}

class RS_Bluewave1 : Actor   // CH Fatsos.txt:1699
{
	Default
	{
		Radius 16;
		Height 8;
		Speed 14;
		DamageFunction (random(10,69));   // CH: Damage(random(10,69))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.75;
		YScale 0.4;
		SeeSound "fatso/attack";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SetScale(0.33,0.1);
		DIS1 A 3 Bright;
		DIS1 C 3 Bright A_SetScale(0.55,0.2);
		DIS1 F 3 Bright A_SetScale(0.75,0.3);
		DIS1 D 3 Bright A_ScaleVelocity(1.5);
	Fly2:
		DIS1 A 1 Bright A_SpawnItemEx("RS_Bluewave2",-1,0,3,3,0,0);
		DIS1 CFEDB 2 Bright A_Explode(random(7,17),72,0);   // per-frame explode: CH's rolling wave, deliberate
		DIS1 B 1 Bright A_SpawnItemEx("RS_Bluewave2",-1,0,3,3,0,0);
		Loop;
	Death:
		DIS1 G 6 Bright A_Explode(random(5,19),72);
		DIS1 H 4 Bright A_Explode(random(5,19),72);
		DIS1 I 2 Bright A_Explode(random(5,19),72);
		BFS1 BBBBBB 0 A_SpawnItemEx("RS_PlasmaBallSP4",random(-8,8),random(-8,20),0,random(15,60),0,random(-33,33),random(0,120));
		BFS1 BBBBBB 0 A_SpawnItemEx("RS_PlasmaBallSP4",random(-8,8),random(-8,20),0,random(15,60),0,random(-33,33),random(120,240));
		BFS1 BBBBBB 0 A_SpawnItemEx("RS_PlasmaBallSP4",random(-8,8),random(-8,20),0,random(15,60),0,random(-33,33),random(240,359));
		Stop;
	}
}

class RS_Bluewave2 : Actor   // CH Fatsos.txt:1742
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 17;
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.35;
		Scale 0.66;
		YScale 0.2;
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		DIS1 ACFEDB 5 Bright;
		Stop;
	}
}

class RS_PurpleBomb1 : Actor   // CH Fatsos.txt:1925
{
	Default
	{
		Radius 7;
		Height 7;
		Speed 18;
		FastSpeed 32;
		Mass 23;
		Gravity 0.3;
		DamageFunction (random(10,65));   // CH: Damage(random(10,65))
		DamageType "Fire";
		Projectile;
		-NOGRAVITY
		+RANDOMIZE
		+BOUNCEONFLOORS
		+USEBOUNCESTATE
		+EXPLODEONWATER
		RenderStyle "Add";
		Alpha 0.88;
		BounceType "Hexen";
		BounceCount 8;
		BounceFactor 1.25;
		WallBounceFactor 1.1;
		Scale 1;
		SeeSound "caco/attack";
		BounceSound "Bomb/bounce";
		DeathSound "Bomb/boom";
		Translation "168:191=250:254";
	}
	States
	{
	Spawn:
		SBS1 ABCD 6 Bright;
		Loop;
	Bounce.Wall:
		SBS4 DE 6 Bright A_SetTranslucent(0.4);
		TNT1 AAAA 0 A_SpawnItemEx("RS_MiniFatsoPurpleBomb",random(-1,1),random(-1,1),random(-1,1),random(-3,12),random(-1,1),random(-25,45),random(0,120));
		TNT1 AAAA 0 A_SpawnItemEx("RS_MiniFatsoPurpleBomb",random(-1,1),random(-1,1),random(-1,1),random(-3,12),random(-1,1),random(-25,45),random(120,240));
		TNT1 AAAA 0 A_SpawnItemEx("RS_MiniFatsoPurpleBomb",random(-1,1),random(-1,1),random(-1,1),random(-3,12),random(-1,1),random(-25,45),random(240,359));
		TNT1 A 0 A_Stop;
		Goto Death+2;
	Death:
		SBS4 DE 6 Bright A_SetTranslucent(0.4);
		SBS4 FGH 6 Bright A_Explode(random(5,28),88);
		Stop;
	}
}

class RS_MiniFatsoPurpleBomb : Actor   // CH Fatsos.txt:1971
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 18;
		Scale 0.5;
		DamageFunction (random(5,20));   // CH: Damage(random(5,20))
		DamageType "Fire";
		Projectile;
		+BOUNCEONWALLS
		RenderStyle "Add";
		Alpha 0.75;
		BounceType "Hexen";
		WallBounceFactor 0.7;
		BounceFactor 0.7;
		BounceCount 4;
		BounceSound "Bomb/bounce";
		SeeSound "imp/attack";
		DeathSound "weapons/plasmax";
		Translation "168:191=250:254","208:223=250:254";
	}
	States
	{
	Spawn:
		SBS1 ABCD 6 Bright A_CustomMissile("RS_Bounc22",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 A 0 A_Jump(8,"Death");
		Loop;
	Death:
		BAL1 CD 3 Bright A_Explode(random(2,10),42);
		TNT1 AAAAAAAAA 0 A_CustomMissile("RS_Bounc22",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BAL1 E 3 Bright A_Explode(random(2,10),42);
		Stop;
	}
}

class RS_FatsoShotYE : Actor   // CH Fatsos.txt:2140
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 14;
		FastSpeed 19;
		DamageFunction (random(10,40));   // CH: Damage(random(10,40))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		Scale 0.65;
		SeeSound "spell/spellcast1";
		DeathSound "weapons/flameballexplode";
	}
	States
	{
	Spawn:
		BBOM A 1 Bright A_SetScale(0.65);
		BBOM A 1 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM A 1 Bright A_SeekerMissile(8,12,SMF_PRECISE);
		BBOM A 1 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM A 1 Bright A_SetScale(0.5);
		Loop;
	Death:
		BBOM A 4 Bright A_SetScale(1);
		BBOM B 5 A_Explode(random(3,15),115);
		BBOM C 5 Bright A_Explode(random(3,15),115);
		BBOM DE 6 Bright A_Explode(random(3,15),115);
		BBOM G 5 Bright A_Explode(random(3,15),115);
		Stop;
	}
}

class RS_RocketShotFatso : Actor   // CH Fatsos.txt:2176
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 28;
		DamageFunction (random(10,40));   // CH: Damage(random(10,40))
		DamageType "Fire";
		Projectile;
		Scale 0.7;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/homingexplode";
	}
	States
	{
	Spawn:
		MSLH A 2 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		MISL B 4 Bright A_Explode(random(5,35),88);
		MISL C 5 Bright;
		MISL D 6 Bright;
		Stop;
	}
}

class RS_HomingRocketTrailFatso : Actor   // CH Fatsos.txt:2202
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 1;
		+NOGRAVITY
		+NOTELEPORT
		RenderStyle "Translucent";
		Alpha 0.33;
		Scale 0.7;   // CH lists Scale twice (0.6 then 0.7); the later one wins, kept
	}
	States
	{
	Spawn:
		MTRL A 2;
		MTRL BCD 3;
		MTRL E 4 A_SetTranslucent(0.2);
		MTRL F 5 A_SetTranslucent(0.1);
		Stop;
	}
}

class RS_Shot2Fatso : Actor   // CH Fatsos.txt:2356
{
	Default
	{
		Radius 7;
		Height 9;
		Scale 1.15;
		Speed 24;
		Damage 8;   // bare constant stays bare (engine rolls 8*1d8)
		Projectile;
		DamageType "Fire";
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "fatso/attack";
		DeathSound "fatso/shotx";
	}
	States
	{
	Spawn:
		MANF AB 3 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		MISL BC 4 Bright A_Explode(random(10,40),128);
		MISL D 2 Bright A_SetScale(2);
		MISL DDDD 1 Bright A_CustomMissile("RS_SparkPuff1",0,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		MISL DDDDDD 1 Bright A_CustomMissile("RS_SparkPuff1",random(-84,84),random(-84,84),CMF_AIMOFFSET,random(-180,180),random(-180,180));
		MISL DDDDDD 0 A_CustomMissile("RS_SparkPuff1",random(-84,84),random(-84,84),CMF_AIMOFFSET,random(-180,180),random(-180,180));
		MISL DD 0 A_SpawnItemEx("RS_Firespe2",2,-2,1,random(2,21),0,random(-1,3),random(1,180),SXF_NOCHECKPOSITION);
		MISL DDD 1 Bright A_SpawnItemEx("RS_Firespe2",-2,2,1,random(2,21),0,random(-1,3),random(1,180),SXF_NOCHECKPOSITION);
		MISL DD 0 A_SpawnItemEx("RS_Firespe2",-2,2,1,random(2,21),0,random(-1,3),random(180,359),SXF_NOCHECKPOSITION);
		MISL DDD 1 Bright A_SpawnItemEx("RS_Firespe2",2,-2,1,random(2,21),0,random(-1,3),random(180,359),SXF_NOCHECKPOSITION);
		MISL DDDDDDD 0 A_SpawnItemEx("RS_Firespe2",0,0,1,random(12,21),0,random(-1,3),random(1,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cacodemons.txt externals -- the EX soul's caco-form arsenal.  All seven
// landed with the caco lane's RS_CacodemonFX.zs before this file did, so
// they live THERE and are referenced read-only here (see file header).
// (CacodemonBall is vanilla; CH never defines it.)
// ---------------------------------------------------------------------------
// RS_Cacospit1 -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// RS_CacoFire2 -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// RS_CacoFire3 -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// RS_CacoFire4 -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// RS_SpitFireCaco -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// RS_SBombCaco -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.
// RS_CrackodemonBall -- ceded: already defined in RS_CacodemonFX.zs (caco lane); referenced read-only, see header.