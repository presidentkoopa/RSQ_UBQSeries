// ============================================================================
// RS_BaronFX.zs -- Baron family: support actors, projectiles, and the
// third-file externals Barons.txt reaches for. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Barons.txt
// (5,021 lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_Baron.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here). Ten of them have Barons.txt itself as their CH source but
// shipped with earlier lanes, per the correct-in-place rule:
//   RS_Zap88 (Barons.txt:2775 -> cacodemon FX),
//   RS_BaronStar3 (Barons.txt:2988 -> hellknight FX),
//   RS_AbyssBaronSoul (:1252) + RS_AbyssBaronHandFire (:1343) -> painelemental FX,
//   RS_BaronCyanBombTrail (:699), RS_SpiralSawAby (:1230), RS_Spspit2 (:2237),
//   RS_SmashBalls2 (:2380), RS_STracerBlue (:2434), RS_STracerPuffBlue (:2466),
//   RS_BaronWave (:2659), RS_Spear11 (:2695), RS_TrailB (:2722),
//   RS_TrailC (:2749), RS_BaronStar (:3023) -> lostsoul FX,
//   RS_Drt1 (:4382) -> shotgunner FX, RS_Drt2 (:4407) + RS_Drt3 (:4432) ->
//   zombieman FX, RS_BaronRing (:3091) + RS_RedBBall (:3523) +
//   RS_BluBBall (:3558) -> imp FX.
// Plus the ordinary shared set: RS_Zom, RS_ZomTierToken, RS_GrowRaisin,
// RS_CHBoner, RS_ThePlanBoner, RS_ColorTierIconCH..CH13, RS_HealthBundle,
// RS_ArmorBundle, RS_BackPackBundle, RS_CH_BlueArmor, RS_CH_GreenArmor,
// RS_CH_MegaSphere, RS_CH_SoulSphere, RS_CH_Berserk, RS_CH_CellPack,
// RS_CH_Cell, RS_CH_Shell, RS_CH_RocketBox, RS_CH_RocketAmmo,
// RS_CH_RocketLauncher, RS_CH_PlasmaRifle, RS_CH_SuperShotgun,
// RS_CH_BFG9000, RS_implyingclip, RS_CH_Cirno, RS_SplashAbyss,
// RS_SplashAbyss2, RS_AbyssShotIdentifier, RS_SplashAbyssBubbleDemon,
// RS_AbyssCacoZap2, RS_ArchRingHelp, RS_SparkPuff1 (shotgunner FX),
// RS_CrackoBallTrail + RS_Blutrail1 (imp FX), RS_RedRevLoad2 +
// RS_HKSplashDed (hellknight FX), RS_ZombieRock + RS_HKRedDeath +
// RS_trail12 (zombieman/chaingunner FX), RS_SpikeCyanRev + RS_WDRock1
// (demon FX), RS_FireSpe1 + RS_FireSpe2 (earlier lanes), and
// RS_HKLead.FireLead (hellknight FX -- the native rebuild of CHACS.acs:54
// "BaronMissile", which CommonBaron calls).
//
// EXTERNALS THIS LANE DEFINES (Barons.txt names them, no earlier family
// shipped them, so per the ownership rule they land here even though CH
// keeps them in another file):
//   RS_VileGroundSpikeBrown  -- CH Archviles.txt:214
//   RS_VileGroundSpikeBrown2 -- CH Archviles.txt:269
//   RS_BrownVileGas          -- CH Archviles.txt:450
//   RS_FireHand1             -- CH Revenants.txt:2556
//   RS_BigBadFire1           -- CH Revenants.txt:2578
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite AZAA frame F (RS_AbyssBaron2 MLeftHand tail, Barons.txt:1126):
//     no AZAA* lump exists anywhere in the CH tree -- a one-character typo
//     for AZEA on a 1-tic A_CheckSight state. Invisible in CH too; kept.
//   * Sounds "satyr/sight" / "satyr/death" (RS_BrownBaron2, Barons.txt:57
//     and :59): CH's SNDINFO defines neither, and neither is a Doom engine
//     name. Both are overridden eighteen lines later in the same actor by
//     "BBARO002"/"BBARO003" (Barons.txt:75,77), so they never play in CH
//     either. Kept verbatim.
//   * Sound "knight/pain" (RS_BrownBaron2 PainSound, Barons.txt:58): CH
//     SNDINFO never defines it -- the same hole the hellknight family
//     flagged. Also overridden at :76 by "brnaby4". Kept verbatim.
//   * DropItem "SchoolGirlTG" (RS_BlackBaron2, Barons.txt:3940) and
//     DropItem "BackBundle" (RS_WhiteBaron2, Barons.txt:4693): neither
//     class is defined ANYWHERE in the CH tree (both are dropped in
//     Barons.txt and MASTERMINDS.txt and defined nowhere). Itemised at
//     their sites as "// CH:" lines rather than silently gutted.
//
// Standing strips, preserved at each site as "// CH:" comments: the ACS
// announcers (AnnounceBaron, AnnounceBaronBlack, AnnounceWhiteBaron); the
// CHRandom_GibGenerator/NashGore gore chain (XDeath animations stay); the
// DRLA RL*/RareArmorPool cross-mod drops; and the one gameplay ACS call in
// this family, "BBaronSlow" -- see RS_BBaronSlowDown below, where CH's own
// script is proven inert.
// ============================================================================


// ---------------------------------------------------------------------------
// Third-file externals. CH files: Archviles.txt, Revenants.txt.
// ---------------------------------------------------------------------------

class RS_VileGroundSpikeBrown : Actor   // CH Archviles.txt:214
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
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",0,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",-32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 AAAAA 2 A_SpawnItemEx("RS_VileGroundSpikeBrown2",randompick(-128,-94,-76,-64,-52,-46,-32,32,46,52,64,76,94,128),randompick(-128,-96,-76,-64,-52,-46,-32,32,46,52,64,76,96,128),1,0,0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",0,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",-32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 11 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		SSPK D 8;
		TNT1 A 0 A_PlaySound("ROCKHIT1",0);
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
		SSPK A 16;
		SSPK AAA 8 A_FadeOut(0.33);
		Stop;
	}
}

class RS_VileGroundSpikeBrown2 : Actor   // CH Archviles.txt:269
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
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",0,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",-32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 11 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",0,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",-32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",-32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",0,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt1",32,-32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 1 A_SpawnItemEx("RS_Drt2",32,32,1,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 11 A_SpawnItemEx("RS_Drt3",32,0,1,random(1,5),0,random(1,5),random(0,360));
		SSPK D 8;
		TNT1 A 0 A_PlaySound("ROCKHIT1",0);
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
		SSPK A 16;
		SSPK AAA 8 A_FadeOut(0.33);
		Stop;
	}
}

class RS_BrownVileGas : Actor   // CH Archviles.txt:450
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 0;
		FastSpeed 0;
		Projectile;
		+NOCLIP
		+FLOATBOB
		Scale 0.5;
		Translation "0:255=%[0.18,0.13,0.13]:[1.73,1.51,1.30]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4");
	A1:
		PSBG CDEFGHI 3 Bright;
		Goto Death;
	A2:
		TNT1 A 0 A_SetScale(0.7,0.25);
		PSBG CDEFGHI 3 Bright;
		Goto Death;
	A3:
		TNT1 A 0 A_SetScale(0.3,0.6);
		PSBG CDEFGHI 3 Bright;
		Goto Death;
	A4:
		PSBG IHGFEDCDEFGHI 3 Bright;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_FireHand1 : Actor   // CH Revenants.txt:2556
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		+NOINTERACTION
		RenderStyle "Add";
		SeeSound "fire/fire4";
		Alpha 0.9;
		Scale 1.2;
	}
	States
	{
	Spawn:
		FLUM ABCDE 6 Bright;
		Goto Death;
	Death:
		MISL BCD 6 Bright A_SetScale(0.6);
		Stop;
	}
}

class RS_BigBadFire1 : Actor   // CH Revenants.txt:2578
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		Mass 2;
		RenderStyle "Add";
		Alpha 0.8;
		DeathSound "Fire/fire5";
		DamageType "Fire";
		Scale 1.5;
	}
	States
	{
	Spawn:
		FLUM AB 3 Bright A_Explode(5,25);
		FLUM CD 3 Bright A_Explode(5,25);
		FLUM E 3 Bright A_Jump(104,"Death");
		Loop;
	Death:
		MISL B 5 Bright;
		MISL C 5 Bright A_Explode(random(4,10),64);
		MISL D 5 Bright A_SpawnItemEx("RS_FireSpe1",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_FireSpe1",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_FireSpe1",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_FireSpe1",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_FireSpe1",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 13 -- Brown Baron's kit.  CH: Barons.txt:170-373.
// ---------------------------------------------------------------------------

class RS_BaronBrownRock : Actor   // CH Barons.txt:170
{
	Default
	{
		Radius 7;
		Height 7;
		Speed 28;
		DamageFunction (random(10,40));
		DamageType "Melee";
		Projectile;
		+SEEKERMISSILE
		Scale 0.5;
		SeeSound "monster/hamflr";
		DeathSound "Butcher/melee";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		JUBD AB 3 Bright A_SpawnItemEx("RS_BrownBaronFlame2",1,0,0,1,0,0,0,0,128);
		JUBD B 1 Bright A_SeekerMissile(9,6);
		JUBD CD 3 Bright A_SpawnItemEx("RS_BrownBaronFlame2",1,0,0,1,0,0,0,0,128);
		JUBD D 1 Bright A_SeekerMissile(9,6);
		Loop;
	Death:
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDDDD 0 A_SpawnItemEx("RS_BrownBaronFlame2",random(-2,2),random(-2,2),random(-2,2),3,0,1,random(0,120));
		JUBD DDDDDD 0 A_SpawnItemEx("RS_BrownBaronFlame2",random(-2,2),random(-2,2),random(-2,2),3,0,1,random(120,240));
		JUBD DDDDDD 0 A_SpawnItemEx("RS_BrownBaronFlame2",random(-2,2),random(-2,2),random(-2,2),3,0,1,random(240,360));
		TNT1 A 0 A_Explode(random(10,40),64,0);
		JUBD DDDD 1 Bright A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		Stop;
	}
}

class RS_BrownBaronFlame : Actor   // CH Barons.txt:204
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.9;
		XScale 0.75;   // CH lists xScale 1.0 then xscale 0.75; the last wins
		Translation "0:255=%[0.28,0.16,0.12]:[1.69,1.17,0.83]";
	}
	States
	{
	Spawn:
		FLUM ABCDE 6 Bright;
		Goto Death;
	Death:
		MISL BCD 6 Bright A_SetScale(0.4,0.4);
		Stop;
	}
}

class RS_BrownBaronFlame2 : Actor   // CH Barons.txt:227
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		RenderStyle "Add";
		Alpha 0.9;
		DamageFunction (random(5,20));
		Projectile;
		XScale 0.6;   // CH lists xScale 1.25 then xscale 0.6; the last wins
		Translation "0:255=%[0.28,0.16,0.12]:[1.69,1.17,0.83]";
	}
	States
	{
	Spawn:
		FLUM ABCDE 6 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(0.75,0.75);
		MISL BCD 3 Bright A_Explode(random(2,10),64,0);
		Stop;
	}
}

class RS_BrownBaronSpiral : Actor   // CH Barons.txt:252
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 4;
		Projectile;
		+DONTREFLECT
		RenderStyle "Add";
		Scale 0.6;
		Translation "0:255=%[0.28,0.16,0.12]:[1.69,1.17,0.83]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		B5P1 ABCD 2 Bright;
		TNT1 A 0 A_SetScale(0.8,0.8);
		B5P1 ABCD 4 Bright A_RadiusGive("RS_BBaronSlowDown",64,RGF_MISSILES,1);
		TNT1 A 0 A_SetScale(0.9,0.9);
		TNT1 A 0 A_Explode(random(10,20),64,0);
		B5P1 ABCD 6 Bright A_RadiusGive("RS_BBaronSlowDown",84,RGF_MISSILES,1);
		TNT1 A 0 A_SetScale(1.2,1.2);
		TNT1 A 0 A_Explode(random(10,20),94,0);
		B5P1 ABCD 8 Bright A_RadiusGive("RS_BBaronSlowDown",64,RGF_MISSILES,1);
		TNT1 A 0 A_Explode(random(10,20),128,0);
		Goto Death;
	Death:
		TNT1 A 0 A_SpawnItemEx("RS_ReflectorBBaron",-16,0,0);
		TNT1 A 0 A_SetScale(0.9,0.9);
		B5P1 ABCD 2 Bright;
		TNT1 A 0 A_SetScale(0.5,0.5);
		B5P1 ABCD 2 Bright;
		TNT1 A 0 A_SetScale(0.3,0.3);
		B5P1 ABCD 2 Bright;
		Stop;
	}
}

class RS_ReflectorBBaron : Actor   // CH Barons.txt:291
{
	Default
	{
		Radius 32;
		Height 56;
		Speed 0;
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
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 20;
		Goto Death;
	Death:
		TNT1 A 1 Bright A_NoBlocking();
		TNT1 A 0 A_Die();
		Stop;
	}
}

// CH's BBaronSlow (CHSett.acs:249) is INERT in CH itself: its guard reads a
// LOCAL "int Nope;" that is always 0 and is compared against 3, so the body
// never executes and no missile is ever slowed. Kept as a no-op pickup so
// the RadiusGive above still resolves, exactly as it does in CH.
class RS_BBaronSlowDown : CustomInventory   // CH Barons.txt:325
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
		TNT1 A 0;   // CH: ACS_NamedExecuteAlways("BBaronSlow") -- CHSett.acs:249, provably inert (local Nope is 0, guard wants 3)
		Stop;
	}
}

class RS_BBaronCmonAndSlam : Actor   // CH Barons.txt:341
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 1;
		Mass 250;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.75;
		YScale 0.5;
		XScale 0.85;
		Translation "0:255=%[0.54,0.57,0.84]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		RED8 ABC 2 Bright;
		Goto Startle;
	Startle:
		TNT1 A 0 A_SetScale(0.9,0.8);
		RED8 FGH 2 Bright;
		TNT1 A 0 A_SetScale(1.1,1.25);
		RED8 ABC 2 Bright;
		TNT1 A 0 A_SetScale(1.3,1.75);
		RED8 FGH 2 Bright;
		Goto Death;
	Death:
		RED8 ABCD 4 Bright A_FadeOut(0.25);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 12 -- Cyan Baron's kit.  CH: Barons.txt:664-873.
// ---------------------------------------------------------------------------

class RS_IceSeekerBaron : Actor   // CH Barons.txt:664
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 26;
		DamageFunction (random(5,25));
		DamageType "Ice";
		Projectile;
		+SEEKERMISSILE
		RenderStyle "Add";
		Scale 0.45;
		Alpha 0.5;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 2 Bright A_SpawnItemEx("RS_IceSeekerTrailBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		ICEY B 2 Bright A_SeekerMissile(frandom(3,12),frandom(3,12),SMF_PRECISE);
		Loop;
	Death:
		ICEY ABC 1 Bright;
		ICEY A 1 Bright A_Stop();
		ICEY BCA 1 Bright;
		ICEY BCABC 1 Bright;
		ICEY F 3 Bright A_Explode(random(10,50),64);
		ICEY GHI 2 Bright;
		Stop;
	}
}

class RS_BaronStarCyan : Actor   // CH Barons.txt:718
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 38;
		DamageFunction (random(5,25));
		DamageType "Ice";
		Projectile;
		RenderStyle "Add";
		Alpha 1;
		Scale 1.1;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(168,"A1","A3");
		STRS AB 2 Bright;
		STRS CD 2 Bright A_Weave(4,1,6,0);
		Loop;
	A1:
		STRS AB 2 Bright;
		STRS CD 2 Bright ThrustThing(random(0,255),random(1,12),0,0);
		Loop;
	A3:
		STRS ABCD 2 Bright;
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1.0,1.0);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright;
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(89,180));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(181,270));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(271,359));
		BBOM EFG 3 Bright;
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(21,60),0,random(1,15),random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(21,60),0,random(1,15),random(89,180));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(21,60),0,random(1,15),random(181,270));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(21,60),0,random(1,15),random(271,359));
		Stop;
	}
}

class RS_BaronCyanBomb : Actor   // CH Barons.txt:766
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 38;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(33,99));
		DamageType "Ice";
		Alpha 0.95;
		Scale 0.5;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RED9 B 1 Bright A_SeekerMissile(6,4);
		RED9 AA 1 Bright A_SpawnItemEx("RS_BaronCyanBombTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		RED9 A 0 A_Explode(random(2,12),32,0);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(2.0,2.0);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(6,12),128,0);
		SPIR E 1;
		Stop;
	}
}

class RS_IceSeekerTrailBaron : Actor   // CH Barons.txt:799
{
	Default
	{
		Radius 5;
		Height 5;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.5;
		Scale 0.45;
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY AB 2 Bright;
	Death:
		ICEY A 1 Bright;
		Stop;
	}
}

class RS_FrostWingBaron : Actor   // CH Barons.txt:822
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
		Alpha 0.65;
		Scale 0.55;
	}
	States
	{
	Spawn:
		KIRC ABCD 2 Bright;
		KIRC ABCD 1 Bright;
	Death:
		TNT1 A 0 A_SetScale(0.35,0.35);
		KIRC ABCD 1 Bright;
		TNT1 A 0 A_SetScale(0.15,0.15);
		KIRC ABCD 1 Bright;
		TNT1 A 0 A_SetScale(0.05,0.05);
		KIRC ABCD 1 Bright;
		Stop;
	}
}

class RS_FrostWingBaron2 : Actor   // CH Barons.txt:850
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 1;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.55;
	}
	States
	{
	Spawn:
		KIRC ABCDABCD 1 Bright;
	Death:
		TNT1 A 0 A_Stop();
		TNT1 A 0 A_SetScale(0.65,0.65);
		ICEY FGHI 1 Bright;
		TNT1 A 0 A_SetScale(0.85,0.85);
		ICEY IGHF 1 Bright;
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 9 -- Abyss Baron's kit.  CH: Barons.txt:898-1459.
// ---------------------------------------------------------------------------

class RS_AbyssBaronRing : Actor   // CH Barons.txt:898
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 3;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.75;
		YScale 0.75;
		XScale 2.0;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
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

class RS_AbyssBaronDefile : Actor   // CH Barons.txt:927
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 3;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+FLATSPRITE
		SeeSound "Fire/fire3";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		B5P1 ABCDABCDABCD 3 Bright;
	Fly:
		TNT1 A 0 A_SetScale(1.25,0.75);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		B5P1 ABCDABCDABCD 3 Bright A_Explode(random(2,30),64);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(1.5,0.75);
		B5P1 ABCDABCDABCD 3 Bright A_Explode(random(3,30),96);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(1.75,0.75);
		B5P1 ABCDABCDABCD 3 Bright A_Explode(random(4,30),128);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(2.0,0.75);
		B5P1 ABCDABCDABCD 3 Bright A_Explode(random(5,30),176);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(2.4,0.75);
		B5P1 ABCDABCDABCD 3 Bright A_Explode(random(7,30),232);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(2.7,0.75);
		B5P1 ABCDABCDABCD 3 Bright A_Explode(random(9,30),272);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-128,128),random(-128,128),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(3,8),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Goto Death;
	Death:
		B5P1 ABCD 4 Bright;
		Stop;
	}
}

class RS_AbyssBaronSoulCharge : Actor   // CH Barons.txt:1166
{
	Default
	{
		Radius 16;
		Height 8;
		Speed 17;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(20,90));
		DamageType "Melee";
		Alpha 0.75;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ETHS E 1 Bright A_SeekerMissile(3,3);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		ETHS FF 1 Bright A_SpawnItemEx("RS_SpiralSawAby",0,0,3,0,0,0,0,128);
		RED9 A 0 A_CustomMissile("RS_GroundRedBar",0,0);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(2);
		SPIR ABCDEDCBAE 5 Bright A_Explode(random(2,20),128);
		Stop;
	}
}

class RS_GroundRedBar : Actor   // CH Barons.txt:1198
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
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		RED8 ABCFGH 3 Bright A_Explode(random(2,10),128);
		RED8 D 1 Bright;
		Stop;
	}
}

class RS_AbyssBaronLightning : Actor   // CH Barons.txt:1313
{
	Default
	{
		Radius 16;
		Height 6;
		Speed 76;
		DamageFunction (random(20,125));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "baron/attack";
		DeathSound "Litn/litn3";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		SPER A 1 Bright A_SpawnItemEx("RS_AbyssCacoZap2",0,0,-1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SPER B 1 Bright A_SpawnItemEx("RS_AbyssCacoZap2",0,0,1);
		Loop;
	Death:
		PLSE CDE 2 Bright;
		TNT1 A 0 A_Explode(random(20,120),128);
		TNT1 AAAAAAAAAAAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-128,128),random(-128,128),random(-6,12),random(10,30),0,0,random(-359,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_AbyssBaronHandFire3 : Actor   // CH Barons.txt:1367
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 1;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 1.95;
		XScale 1.25;
		YScale 1.80;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		FRFX ABCD 8 Bright;
		Goto Death;
	Death:
		FRFX HIJKLMNO 1 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronSoul",0,0,32,0,0,0,0);
		Stop;
	}
}

class RS_AbyssBaronHandFire2 : Actor   // CH Barons.txt:1391
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 1;
		Species "BaronOfHell";
		Projectile;
		+DONTHARMCLASS
		+DONTHARMSPECIES
		DamageType "Ice";
		RenderStyle "Add";
		Alpha 1.95;
		XScale 0.75;
		YScale 0.75;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		FRFX ABCD 1 Bright;
		Goto Death;
	Death:
		FRFX HIJKLMNO 1 Bright A_Explode(random(1,7),32,0);
		Stop;
	}
}

class RS_AbyssBaronFlare : Actor   // CH Barons.txt:1417
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 28;
		DamageFunction (random(13,75));
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.85;
		XScale 2.0;
		YScale 1.25;
		Projectile;
		+THRUGHOST
		+DONTHARMCLASS
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		VBA3 AB 3 Bright A_SpawnItemEx("RS_AbyssBaronHandFire2",0,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(2.5,1.75);
		CBAL CD 3 Bright;
		TNT1 A 0 A_Explode(random(20,80),128);
		CBAL EFG 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",232,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",64,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",128,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",-232,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",-64,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",-128,0,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",0,232,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",0,64,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",0,128,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",0,-232,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",0,-64,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaronHandFire2",0,-128,0,0,0,0,0);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 8 -- Gray Baron's dirt kit.  CH: Barons.txt:1621-1735.
// ---------------------------------------------------------------------------

class RS_BaronOfDirtCH : Actor   // CH Barons.txt:1621
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 2;
		FloatSpeed 1;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		Scale 1.5;
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		JUBD A 0 ThrustThingZ(0,1,1,0);
		JUBD A 1 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),128);
		JUBD A 1 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),128);
		JUBD A 1 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),128);
		JUBD A 1 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),128);
		JUBD A 1 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),128);
		JUBD A 1 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),128);
		JUBD A 6 Bright A_PlaySound("moloch/step",7);
		Goto Death;
	Death:
		JUBD AA 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),128);
		JUBD AA 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),128);
		JUBD AA 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),128);
		JUBD AA 2 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),128);
		JUBD AA 2 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),128);
		JUBD AA 2 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),128);
		JUBD A 8 Bright;
		Stop;
	}
}

class RS_BaronOfDirtCH2 : Actor   // CH Barons.txt:1659
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 16;
		Gravity 0.10;
		DamageFunction (random(70,170));
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+SEEKERMISSILE
		BounceType "Hexen";
		BounceCount 6;
		BounceFactor 1.15;
		Scale 1.75;
		SeeSound "monster/hamflr";
		DeathSound "moloch/thud";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		JUBD AAB 2 Bright A_SpawnItemEx("RS_ZombieRock",random(-2,2),random(-2,2),random(-2,2),random(8,18),0,random(-2,9),random(100,220),SXF_NOCHECKPOSITION);
		JUBD B 3 Bright A_SeekerMissile(3,6);
		JUBD CCD 2 Bright A_SpawnItemEx("RS_ZombieRock",random(-2,2),random(-2,2),random(-2,2),random(8,18),0,random(-2,9),random(120,240),SXF_NOCHECKPOSITION);
		JUBD D 3 Bright A_SeekerMissile(6,3);
		Loop;
	Bounce.Floor:
		TNT1 A 0 ThrustThingZ(0,18,0,1);
		Goto Fly;
	Bounce.Wall:
		TNT1 A 0;
		Goto Death;
	Death:
		JUBD DDDDD 0 A_SpawnItemEx("RS_Drt1",random(-24,24),random(-24,24),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDDD 0 A_SpawnItemEx("RS_Drt2",random(-24,24),random(-24,24),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDDD 0 A_SpawnItemEx("RS_Drt3",random(-24,24),random(-24,24),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD 0 A_SpawnItemEx("RS_ZombieRock",random(-2,2),random(-2,2),random(-2,2),random(7,14),0,random(-8,9),random(0,360),SXF_NOCHECKPOSITION);
		JUBD D 1 Bright;
		Stop;
	}
}

class RS_BaronOfDirtCH3 : Actor   // CH Barons.txt:1704
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 20;
		DamageFunction (random(75,155));
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS
		BounceType "Hexen";
		BounceCount 10;
		BounceFactor 0.95;
		Gravity 0.8;
		Scale 1.2;
		SeeSound "monster/hamflr";
		DeathSound "moloch/thud";
	}
	States
	{
	Spawn:
		JUBD ABCD 1 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-3,3),1,0,1,random(0,360),128);
		JUBD A 0 A_PlaySound("Ice/Fly");
		Loop;
	Death:
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD D 1 Bright;
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu Baron's bomb, and the family's BaronBall replacement.
// CH: Barons.txt:1885-1945.
// ---------------------------------------------------------------------------

class RS_BluPowerBomb : Actor   // CH Barons.txt:1885
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 10;
		DamageFunction (random(10,70));
		DamageType "Plasma";
		Projectile;
		+SEEKERMISSILE
		+EXTREMEDEATH
		+BOUNCEONWALLS
		BounceType "Hexen";
		BounceCount 4;
		BounceFactor 1.25;
		WallBounceFactor 1.25;
		RenderStyle "Add";
		Alpha 2.55;
		Scale 0.55;
		SeeSound "Litn/litn3";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		ZPWV ABCBCABCACBABCA 1 Bright A_SeekerMissile(12,18);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(1.25,0.8);
		BFE1 AB 8 Bright;
		BFE1 C 8 Bright A_Explode(random(40,80),158);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_BaronBall2 : Actor replaces BaronBall   // CH Barons.txt:1921
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 15;
		FastSpeed 20;
		DamageType "Plasma";
		Damage 8;   // CH: bare constant -- engine multiplies missile Damage N by 1d8
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "baron/attack";
		DeathSound "baron/shotx";
		Decal "BaronScorch";
	}
	States
	{
	Spawn:
		BAL7 AB 4 Bright;
		Loop;
	Death:
		BAL7 CDE 6 Bright;
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 2 -- Green Baron's poison kit.  CH: Barons.txt:2168-2235.
// ---------------------------------------------------------------------------

class RS_GreeniesBR : Actor   // CH Barons.txt:2168
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 15;
		Mass 5;
		DamageFunction (random(1,2));
		DamageType "Poison";
		Projectile;
		+RANDOMIZE
		+BOUNCEONFLOORS
		+EXPLODEONWATER
		RenderStyle "Add";
		Alpha 0.75;
		BounceType "Hexen";
		BounceCount 3;
		BounceFactor 1.1;
		WallBounceFactor 1.1;
		Scale 0.25;
		SeeSound "fire/fire1";
		DeathSound "caco/shotx";
		Translation "168:191=112:127","250:254=117:119","208:223=112:124";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Fly;
	Fly:
		BAL2 AB 4 Bright;
		BAL2 A 0 { bNOGRAVITY = false; }   // CH: a_changeflag(Nogravity,false)
		Loop;
	Death:
		BAL2 C 3 Bright A_SetTranslucent(0.4);
		BAL2 DE 2 Bright;
		Stop;
	}
}

class RS_Spspit3 : Actor   // CH Barons.txt:2207
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 12;
		DamageFunction (random(15,60));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		Scale 1.33;
		SeeSound "baron/attack";
		DeathSound "imp/shotx";
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
	Fly:
		BAL1 A 4 Bright A_SpawnItemEx("RS_GreeniesBR",-3,0,0,random(1,9),0,random(-3,9),random(180,210));
		BAL1 B 4 Bright A_SpawnItemEx("RS_GreeniesBR",-3,0,0,random(1,9),0,random(-3,9),random(150,180));
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(1,7),32);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 3 -- Blue Baron's comet.  CH: Barons.txt:2489.
// ---------------------------------------------------------------------------

class RS_SmashBall4 : Actor   // CH Barons.txt:2489
{
	Default
	{
		Radius 12;
		Height 18;
		Speed 24;
		Mass 4;
		DamageFunction (random(5,65));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+EXPLODEONWATER
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		XScale 1.8;
		YScale 1.8;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
		Translation "168:191=192:207","208:223=193:202","250:254=197:197","231:231=224:224";
	}
	States
	{
	Spawn:
		BAL2 A 4 Bright A_SeekerMissile(3,3);
		BAL2 A 0 A_SpawnItemEx("RS_Blutrail1",0,0,5);
		BAL2 B 4 Bright A_SeekerMissile(3,3);
		BAL2 A 0 A_SpawnItemEx("RS_Blutrail1",0,0,5);
		Loop;
	Death:
		BAL2 C 3 Bright A_SetTranslucent(0.4);
		BAL2 DE 6 Bright A_Explode(random(3,20),128);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 5 -- Yellow (Grand Orange) Baron's star kit.  CH: Barons.txt:2943-3055.
// RS_BaronStar3 (:2988) and RS_BaronStar (:3023) shipped with earlier lanes;
// only the second star and the fire bomb land here.
// ---------------------------------------------------------------------------

class RS_BaronFbomb : Actor   // CH Barons.txt:2943
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 19;
		FastSpeed 38;
		DamageFunction (random(10,70));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		Species "BaronOfHell";
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1;
		Scale 1;
		SeeSound "spell/spellcast1";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		BBOM A 1 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM A 1 Bright A_SetScale(1.3);
		BBOM A 1 Bright A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM A 1 Bright A_SetScale(1.0);
		Loop;
	Death:
		BBOM A 4 Bright A_SetScale(1.8);
		BBOM B 5 A_SetTranslucent(0.65);
		BBOM B 1 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM B 1 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM C 5 Bright A_Explode(random(5,30),155);
		BBOM D 4 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM D 1 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM D 1 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM E 6 Bright A_Explode(random(5,30),155);
		BBOM F 4 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM F 1 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM F 1 Bright A_CustomMissile("RS_BaronStar3",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BBOM G 5 Bright A_Explode(random(5,30),155);
		Stop;
	}
}

class RS_BaronStar2 : Actor   // CH Barons.txt:3057
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 28;
		FastSpeed 38;
		DamageFunction (random(5,25));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		Species "BaronOfHell";
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		STRS AB 2 Bright A_SeekerMissile(5,5);
		STRS CD 2 Bright A_Weave(-4,-1,-6,0);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,30),108);
		BBOM EFG 6 Bright A_Explode(random(5,30),108);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 6 -- Red Baron's three phases: rage bomb, archon comet, fallen kit.
// CH: Barons.txt:3141-3855.
// ---------------------------------------------------------------------------

class RS_RedPowerBomb : Actor   // CH Barons.txt:3141
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 21;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		+DONTHARMCLASS
		+DONTHARMSPECIES
		Species "BaronOfHell";
		RenderStyle "Add";
		DamageFunction (random(10,80));
		DamageType "Melee";
		Alpha 0.75;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		RED9 B 1 Bright A_SeekerMissile(2,2);
		RED9 AA 3 Bright A_SpawnItemEx("RS_RedRevLoad2",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(2);
		SPIR ABCDEDCBA 5 Bright;
		SPIR E 1;
		Stop;
	}
}

class RS_RedPower : Actor   // CH Barons.txt:3468
{
	Default
	{
		Radius 1;
		Height 1;
		Species "BaronOfHell";
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		RED8 ABCDEEFG 8 Bright A_SpawnItemEx("RS_ArchonSoul",random(-128,128),random(-128,218),random(5,45),0,0,0,0);
		RED8 H 4 A_SetTranslucent(0.3);
		Stop;
	}
}

class RS_ArchonComet : Actor   // CH Barons.txt:3489
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 25;
		Damage 20;   // CH: bare constant -- engine multiplies missile Damage N by 1d8
		Scale 1.0;
		Projectile;
		+THRUGHOST
		+BOUNCEONWALLS
		SeeSound "weapons/firbfi";
		DeathSound "weapons/hellex";
		BounceType "Doom";
		BounceFactor 1;
		BounceCount 4;
		WallBounceFactor 1.2;
		BounceSound "Fire/fire4";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		Translation "112:127=176:191";
		DamageType "Fire";
	}
	States
	{
	Spawn:
		ARCB AAAABBBBCCCC 1 Bright A_SpawnItemEx("RS_ArchonCometTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		ARCB J 0 A_SetTranslucent(0.67,1);
		ARCB J 3 Bright;
		ARCB K 3 Bright A_Explode(random(10,80),128,0);
		ARCB LMN 3 Bright;
		Stop;
	}
}

class RS_ArchonSoul : Actor   // CH Barons.txt:3560
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
		BFX1 ABCD 6 Bright A_Explode(random(5,12),32);
		Stop;
	}
}

class RS_ArchonCometTrail : Actor   // CH Barons.txt:3583
{
	Default
	{
		Radius 3;
		Height 3;
		Scale 0.75;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
		Translation "112:127=176:191";
	}
	States
	{
	Spawn:
		TNT1 A 3 Bright A_CustomMissile("RS_CrackoBallTrail",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ARCB DEFGHI 3 Bright A_CustomMissile("RS_CrackoBallTrail",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Stop;
	}
}

class RS_FallenFX : Actor   // CH Barons.txt:3763
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		Scale 1.0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
	}
	States
	{
	Spawn:
		TNT1 A 3 Bright;
		FBFX ABCDE 3 Bright;
		Stop;
	}
}

class RS_RedBBall2 : Actor   // CH Barons.txt:3781
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 25;
		DamageFunction (random(10,55));
		Scale 0.5;
		Projectile;
		+THRUGHOST
		SeeSound "weapons/firbfi";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		RenderStyle "Add";
		Alpha 0.8;
		Translation "112:127=176:191";
		DamageType "Plasma";
	}
	States
	{
	Spawn:
		RED9 A 3 Bright A_SetScale(0.5);
		RED9 B 3 Bright A_CustomMissile("RS_CrackoBallTrail",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		RED9 C 3 Bright A_SetScale(0.4);
		Loop;
	Death:
		ARCB J 0 A_SetTranslucent(0.67,1);
		ARCB JJJJJJJJJJJJJJJ 1 Bright A_CustomMissile("RS_FallenShot",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ARCB K 3 Bright A_Explode(random(8,20),128,0);
		ARCB LMN 3 Bright;
		Stop;
	}
}

class RS_FallenShot : Actor   // CH Barons.txt:3813
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 16;
		Damage 2;   // CH: bare constant -- engine multiplies missile Damage N by 1d8
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex5";
	}
	States
	{
	Spawn:
		BALF AB 2 Bright A_SpawnItemEx("RS_FallenFX",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BALF CDEF 4 Bright;
		Stop;
	}
}

class RS_FallenSP : Actor   // CH Barons.txt:3837
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		ReactionTime 60;
		Projectile;
		RenderStyle "Normal";
		-NOGRAVITY
	}
	States
	{
	Spawn:
		FBSP AB 3 Bright A_Countdown();
		Loop;
	Death:
		FBSP CDE 3 Bright;
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 10 -- Black Baron's deep-one kit.  CH: Barons.txt:4149-4266.
// ---------------------------------------------------------------------------

class RS_DeepOneBall : Actor   // CH Barons.txt:4149
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 25;
		DamageFunction (random(25,75));
		Projectile;
		+RANDOMIZE
		+ROCKETTRAIL
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.75;
		SeeSound "deepone/fire";
		DeathSound "deepone/firehit";
	}
	States
	{
	Spawn:
		OLDP A 0 A_Tracer();
		OLDP A 0 A_BishopMissileWeave();
		OLDP A 2 Bright A_BishopMissileWeave();
		OLDP B 0 A_Tracer();
		OLDP B 0 A_BishopMissileWeave();
		OLDP B 2 Bright A_BishopMissileWeave();
		Loop;
	Death:
		OLDP C 0 A_Scream();
		OLDP CDEF 4 Bright;
		Stop;
	}
}

class RS_TentacleBall1 : Actor   // CH Barons.txt:4181
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 25;
		DamageFunction (random(10,60));
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.75;
		SeeSound "monster/tenatk";
		DeathSound "weapons/plasmax";
		Projectile;
		+RANDOMIZE
	}
	States
	{
	Spawn:
		OLDP AB 3 Bright;
		Loop;
	Death:
		OLDP CDEF 4 Bright;
		Stop;
	}
}

class RS_TentacleBall2 : RS_TentacleBall1   // CH Barons.txt:4205
{
	Default
	{
		Speed 10;
		Damage 5;   // CH: bare constant -- engine multiplies missile Damage N by 1d8
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		OLDP FEDC 3 Bright;
		Loop;
	Death:
		OLDP BA 4 Bright;
		Stop;
	}
}

class RS_DeepCharge1 : Actor   // CH Barons.txt:4222
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 1;
		Projectile;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "deepone/fire";
	}
	States
	{
	Spawn:
		OLDP A 3 Bright A_SetScale(1.5,1.5);
		OLDP B 3 Bright A_SetScale(1.1,1.1);
		OLDP C 3 Bright A_SetScale(0.9,0.9);
		OLDP D 3 Bright A_SetScale(0.5,0.5);
		OLDP E 3 Bright A_SetScale(0.3,0.8);
		OLDP F 3 Bright A_SetScale(0.3,2);
		Stop;
	}
}

class RS_DeepBeam1 : Actor   // CH Barons.txt:4244
{
	Default
	{
		Radius 25;
		Height 13;
		Speed 1;
		DamageFunction (random(10,25));
		Scale 1.5;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.9;
		SeeSound "deepone/fire";
		DeathSound "deepone/firehit";
	}
	States
	{
	Spawn:
		OLDP AB 7 Bright;
		OLDP C 0 A_Scream();
		OLDP CDEF 4 Bright;
		Stop;
	}
}


// ---------------------------------------------------------------------------
// Tier 11 -- White Baron's slice kit.  CH: Barons.txt:4478-4644.
// ---------------------------------------------------------------------------

class RS_WhiteBaronSlice : Actor   // CH Barons.txt:4478
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 38;
		Projectile;
		+NOGRAVITY
		RenderStyle "Add";
		DamageFunction (random(11,44));
		DamageType "Fire";
		Alpha 0.95;
		XScale 0.9;
		YScale 1.1;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BRB2 AB 1 Bright A_SpawnItemEx("RS_WhiteBaronSliceTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BRB2 A 0 A_Explode(random(2,12),16,0);
		Loop;
	Death:
		SPIR A 0 A_SetScale(2.0,2.0);
		BRB2 CDEFGHI 5 Bright;
		Stop;
	}
}

class RS_WhiteBaronSliceTrail : Actor   // CH Barons.txt:4509
{
	Default
	{
		Radius 5;
		Height 5;
		Projectile;
		+NOCLIP
		RenderStyle "Add";
		Alpha 0.9;
		XScale 0.9;
		YScale 1.1;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		VBA3 AB 1 Bright;
	Death:
		VBA3 B 1 Bright;
		Stop;
	}
}

class RS_WhiteBaronSliceHoming : Actor   // CH Barons.txt:4532
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 15;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(5,25));
		DamageType "Fire";
		Alpha 0.95;
		XScale 0.9;
		YScale 1.1;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BRB2 B 1 Bright A_SpawnItemEx("RS_WhiteBaronSliceTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		BRB2 A 1 Bright A_SeekerMissile(12,12);
		BRB2 A 0 A_Explode(random(2,12),16,0);
		Loop;
	Death:
		SPIR A 0 A_SetScale(2.0,2.0);
		BRB2 CDEFGHI 5 Bright;
		Stop;
	}
}

class RS_WhiteBaronStar : Actor   // CH Barons.txt:4565
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 33;
		DamageFunction (random(5,25));
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
		TNT1 A 0;
		TNT1 A 0 A_Jump(128,"Two");
	One:
		STRS AB 2 Bright A_SeekerMissile(3,3);
		STRS CD 2 Bright A_Weave(4,1,6,0);
		Loop;
	Two:
		STRS AB 2 Bright A_SeekerMissile(3,3);
		STRS CD 2 Bright A_Weave(-4,-1,-6,0);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(0.65);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,25),64);
		BBOM EFG 6 Bright A_Explode(random(5,30),64);
		Stop;
	}
}

class RS_WhiteBaronGround : Actor   // CH Barons.txt:4604
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 25;
		Alpha 0.67;
		Projectile;
		+THRUACTORS
		+THRUGHOST
		+DONTBLAST
		+MTHRUSPECIES
		-NOGRAVITY
		+USEBOUNCESTATE
		+SEEKERMISSILE
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
		TNT1 A 1 Bright A_CStaffMissileSlither();
		TNT1 A 0 A_SpawnItemEx("RS_VileGroundSpikeBrown2",0,0,0);
		TNT1 A 1 Bright A_CStaffMissileSlither();
		Loop;
	Bounce.Floor:
		TNT1 A 0 ThrustThing(int(angle+randompick(-5,-4,-3,-2,-1,0,1,2,3,4,5)),12,0,0);   // CH: thrustthing(angle+randompick(...),12,0,0)
		Goto Fly;
	Bounce.Wall:
		TNT1 A 0 A_Stop();
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}
