// ============================================================================
// RS_Shotgunner.zs -- Colourful Hell Shotgunner family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Shotgunners.txt (3,102 lines,
// read whole). Every actor cites its CH line. Support classes and import
// rules: RS_ShotgunnerFX.zs (and RS_ZombiemanFX.zs for the shared ones).
//
// Tier ladder (CH icon index), same as the zombieman: 1 Common, 2 Green,
// 3 Blue, 4 Purple, 5 Yellow(Orange), 6 Red, 7 FireBlu, 8 Gray, 9 Abyss,
// 10 Black, 11 White, 12 Cyan, 13 Brown.
//
// Known-absent frame, deliberately NOT remapped (checked 2026-08-06):
//   * SGUP M -- the gib set ships N-U (8 lumps) here AND in CH; M exists in
//     no IWAD and nowhere in CH.  CH's complete zombie sets (CZOW/PZOW/ZUNM)
//     run their XDeath O-W, and CH shifted that 9-frame template down two
//     letters onto SGUP as M-U -- one letter more than the set has.  RS_PurpleSG
//     is the only class that writes it, on a 0-TIC state, so it never renders.
//     RS_GraySG2's XDeath starts at "SGUP N 5 A_XScream" with no M at all
//     (CH Shotgunners.txt:479) -- so N is the set's real first gib frame.
//     Nothing is invisible; kept verbatim.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Shotgunners.txt:1 -- Colourset4 replaces Shotgunguy.
// ---------------------------------------------------------------------------
class RS_ShotgunnerColourset : RandomSpawner replaces ShotgunGuy
{
	Default
	{
		DropItem "RS_CommonSG", 255, 600;
		DropItem "RS_GreenSG", 255, 300;
		DropItem "RS_CyanSG", 255, 200;
		DropItem "RS_BlueSG", 255, 280;
		DropItem "RS_PurpleSG", 255, 60;
		DropItem "RS_GraySG", 255, 60;
		DropItem "RS_AbyssSG", 255, 50;
		DropItem "RS_YellowSG", 255, 60;
		DropItem "RS_BrownSG", 255, 40;
		DropItem "RS_FireBluSG", 255, 43;
		DropItem "RS_RedSG", 255, 33;
		DropItem "RS_BlackSG", 255, 5;
		DropItem "RS_WhiteSG", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the zombieman's.
// ---------------------------------------------------------------------------
class RS_BrownSG : Actor   // CH Shotgunners.txt:18
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_brown', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_brown', 1) == 3, "Fifty");
		Goto Third;
	Fifty:
		TNT1 A 0 A_Jump(128, "Third");
	First:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanSG : Actor   // CH Shotgunners.txt:191
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyan', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyan', 1) == 3, "Fifty");
		Goto Third;
	Fifty:
		TNT1 A 0 A_Jump(128, "Third");
	First:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GraySG : Actor   // CH Shotgunners.txt:345
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_gray', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GraySG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssSG : Actor   // CH Shotgunners.txt:526
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_abyss', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_abyss', 1) == 3, "Fifty");
		Goto Third;
	Fifty:
		TNT1 A 0 A_Jump(128, "Third");
		Goto First;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluSG : Actor   // CH Shotgunners.txt:662
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_fireblu', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackSG : Actor   // CH Shotgunners.txt:1844
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_blackboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSG3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedSG",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteSG : Actor   // CH Shotgunners.txt:2298
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_whiteboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 1, "EX1");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 2, "EX2");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 3, "EX3");
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSG",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSGEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSGEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSGEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN.  CH: Shotgunners.txt:40.  Muddy skull-charger.
// ---------------------------------------------------------------------------
class RS_BrownSG2 : ShotgunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 155;
		Radius 20;
		Height 56;
		Species "SGuy2";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 110;
		Speed 9;
		PainChance 102;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "SSGUNER/sight";
		AttackSound "SSGUNER/SSG";
		PainSound "Form2/Hurt";
		DeathSound "Sguy2/Die";
		ActiveSound "shotguy/active";
		Obituary "%o got mudshotted by brown shotgunner";
		DropItem "Shotgun";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_HealthBundle";
		DropItem "ArmorBonus", 128;
		Translation "0:113=%[0.09,0.09,0.08]:[0.68,0.43,0.28]";
		Tag "Muddy guy";
	}
	States
	{
	Spawn:
		QSZM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		QSZM AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),0,32);
		QSZM CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),0,32);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QSZM E 2 A_JumpIfCloser(400,"Fire1");
		TNT1 A 0 A_JumpIfInTargetLOS("Fire1",0,JLOSF_DEADNOJUMP|JLOSF_CLOSENOSIGHT,1200,700);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QSZM E 2 A_Jump(255,"GetCloser");
		Goto See;
	GetCloser:
		QSZM A 0 A_PlaySound("gas/gas1");
		QSZM A 3 A_SkullAttack(28);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),0,32);
		QSZM B 6 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),0,32);
		TNT1 A 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),0,32);
		QSZM AB 6 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),0,32);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QSZM E 2 A_Stop;
		TNT1 A 0 A_JumpIfInTargetLOS("Fire1",0,JLOSF_DEADNOJUMP|JLOSF_CLOSENOSIGHT,1200,700);
		QSZM A 2 A_SetSpeed(9);
		Goto See;
	Fire1:
		QSZM E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QSZM F 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QSZM FFFFFFFFFF 0 A_CustomMissile("RS_BrownSGshot",32,random(-5,5),random(-15,15),CMF_OFFSETPITCH,random(-9,1));
		QSZM FFFFFFFFFF 0 A_CustomMissile("RS_BrownSGshot",32,random(-5,5),random(-15,15),CMF_OFFSETPITCH,random(-1,9));
		QSZM F 1 A_CustomBulletAttack(11.2,7.1,random(7,17),random(1,3),"BulletPuff");
		TNT1 A 0 A_PlaySound("SSGUNER/SSG");
		QSZM F 4 Bright;
		QSZM E 2 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		QSZM G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QSZM G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		QSZM H 5;
		QSZM I 5 A_Scream;
		QSZM J 5 A_NoBlocking;
		QSZM K 5;
		QSZM L -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (owner: vanilla gore ok)
		QSZM N 5 A_XScream;
		QSZM O 5 A_NoBlocking;
		QSZM PQRST 5;
		QSZM U -1;
		Stop;
	Raise:
		QSZM LKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN.  CH: Shotgunners.txt:213.  Heavy ice trooper, jumps.
// ---------------------------------------------------------------------------
class RS_CyanSG2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 60;
		Height 56;
		Radius 20;
		Speed 8;
		PainChance 128;
		Mass 4200;
		DamageFactor "Fire", 1.5;
		DamageFactor "Melee", 2.0;
		DamageFactor "Ice", 0.10;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Falling", 0.0;
		BloodColor "Black";
		Monster;
		+FLOORCLIP
		+NOICEDEATH
		+MISSILEMORE
		+NOFEAR
		+LAXTELEFRAGDMG
		SeeSound "ZSpecOps/Sight";
		ActiveSound "ZSpecOps/Sight";
		PainSound "ZSpecOps/Pain";
		DeathSound "ZSpecOps/Death";
		Obituary "%o was frost bitten by cyan shotgunner";
		DropItem "Shotgun";
		DropItem "RS_ArmorBundle", 12;
		DropItem "RS_HealthBundle", 178;
		Translation "0:255=%[0.30,0.57,1.22]:[1.01,2.00,2.00]","88:90=%[0.00,0.00,1.76]:[0.43,1.22,2.00]","61:61=%[0.00,0.00,1.59]:[0.52,0.52,2.00]","57:57=%[0.09,0.02,1.35]:[0.03,0.38,1.74]";
		Tag "Cyan Shotgun dood";
	}
	States
	{
	Spawn:
		CNSG AAAAAAAAAABBBBBBBBBB 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_Jump(232,"SeeMe");
		CNSG AAAAAAAA 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CNSG BBBBBBBB 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(232,"SeeMe","See2");
		Loop;
	See2:
		CNSG AAAABBBB 1 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	SeeMe:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CNSG A 0 A_JumpIfInTargetLOS("Jumpy",0,JLOSF_CLOSENOJUMP|JLOSF_DEADNOJUMP,750,300);
		Goto See;
	Jumpy:
		CNSG A 2 A_FastChase;
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CNSG A 1 ThrustThingZ(0,48,0,0);
		CNSG A 1 ThrustThing(int(angle-randompick(130,180,230)),12,0,0);   // CH: thrustthing(angle-randompick(130,180,230),12,0,0)
		CNSG A 2;
		CNSG A 1 ThrustThingZ(0,28,0,0);
		CNSG A 1 ThrustThing(int(angle),24,0,0);   // CH: thrustthing(angle,24,0,0)
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CNSG EEE 4 A_FaceTarget;
		CNSG F 0 A_PlayWeaponSound("Weapons/ShotGF");
		TNT1 A 0 A_Jump(128,"Proj");
		CNSG F 0 A_CustomBulletAttack(4,4,1,random(1,5),"RS_CyanSGPuff",8000,CBAF_EXPLICITANGLE);
		CNSG F 0 A_CustomBulletAttack(-4,-4,1,random(1,4),"RS_CyanSGPuff",8000,CBAF_EXPLICITANGLE);
		CNSG F 0 A_CustomBulletAttack(5,5,2,random(1,2),"RS_CyanSGPuff");
		CNSG F 0 A_CustomBulletAttack(4,-4,1,random(1,4),"RS_CyanSGPuff",8000,CBAF_EXPLICITANGLE);
		CNSG F 0 A_CustomBulletAttack(-4,4,1,random(1,5),"RS_CyanSGPuff",8000,CBAF_EXPLICITANGLE);
		CNSG F 2 Bright;
		CNSG EE 2 A_FaceTarget;
		CNSG E 2 A_CheckSight("See");
		CNSG E 0 A_Jump(102,"Missile");
		Goto See;
	Proj:
		CNSG FFFFF 0 A_CustomMissile("RS_IceZombieShot2",32,0,random(-5,5),0,random(-2,2));
		CNSG F 0 A_CustomBulletAttack(-2,2,1,random(1,6),"RS_CyanSGPuff",8000,CBAF_EXPLICITANGLE);
		CNSG F 2 Bright;
		CNSG EE 2 A_FaceTarget;
		CNSG E 2 A_CheckSight("See");
		CNSG E 0 A_Jump(102,"Missile");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Jump:
		CNSG G 2;
		CNSG E 1 ThrustThingZ(0,12,0,0);
		CNSG E 1 ThrustThing(int(angle + randompick(90,180,270)),32,0,0);   // CH: thrustthing(angle + randompick(90,180,270),32,0,0)
		CNSG A 4;
		Goto See;
	Pain:
		CNSG G 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CNSG G 4 A_Pain;
		CNSG G 0 A_Jump(96,"Jump");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CNSG H 5;
		CNSG I 5 A_Scream;
		CNSG J 5;
		CNSG K 5 A_NoBlocking(false);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,254);
		TNT1 A 0 A_IceGuyDie;
		CNSG L -1;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY.  CH: Shotgunners.txt:364.  The sniper.
// ---------------------------------------------------------------------------
class RS_GraySG2 : ShotgunGuy
{
	int user_ready;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 155;
		Radius 20;
		Height 56;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 110;
		Speed 8;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+AVOIDMELEE
		+MISSILEMORE
		+NOFEAR
		SeeSound "SGUY2/See";
		AttackSound "SNPRFIRE";
		PainSound "Form2/Hurt";
		DeathSound "Sguy2/Die";
		ActiveSound "shotguy/active";
		Obituary "one shot, %o kill";
		DropItem "Shotgun";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_Shell";
		DropItem "HealthBonus";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "ArmorBonus", 128;
		Translation "80:111=%[0.07,0.09,0.10]:[0.69,0.69,0.69]","4:4=88:88","16:47=%[0.58,0.58,0.58]:[0.28,0.28,0.28]","5:8=186:191";
		Tag "snipah";
	}
	States
	{
	Spawn:
		GRSH AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		GRSH AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GRSH CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GRSH E 2 A_JumpIfCloser(800,"Fire1");
		GRSH E 2 A_Jump(255,"GetReady");
		Goto See;
	Fire1:
		GRSH E 8 A_FaceTarget;
		GRSH E 8 Bright A_CustomBulletAttack(random(-1,1),0,random(1,2),random(1,9));
		Goto See;
	GetReady:
		TNT1 A 0 A_JumpIf(user_ready >= 1,"Fire2");
		GRSH E 8 A_FaceTarget;
		GRSH E 3 A_SetScale(1.0,0.7);
		GRSH E 3 A_SetScale(1.25,0.5);
		GRSH E 3 A_SetScale(1.5,0.3);
		GRSH E 1 A_SetSpeed(2);
		GRSH E 1 { bNOPAIN = true; }
		GRSH E 3 { user_ready = user_ready + 1; }
		Goto See;
	Fire2:
		GRSH E 6 A_FaceTarget;
		GRSH E 6 A_CustomRailgun(0,0,"none","red",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,"",-12);
		GRSH E 5 A_FaceTarget;
		GRSH E 5 A_CustomRailgun(0,0,"none","red",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,"",-12);
		GRSH E 4 A_FaceTarget;
		GRSH E 4 A_CustomRailgun(0,0,"none","red",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,"",-12);
		GRSH E 3 A_FaceTarget;
		GRSH E 3 A_CustomRailgun(0,0,"none","red",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,"",-12);
		GRSH F 6 Bright A_CustomBulletAttack(0,0,1,random(5,20));
		GRSH E 2 A_FaceTarget;
		GRSH E 24;
		GRSH E 2 A_MonsterRefire(180,"See");
		Goto Fire2;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GRSH G 3;
		GRSH G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+4;
	Death:
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		GRSH H 5;
		GRSH I 5 A_Scream;
		GRSH J 5 A_NoBlocking;
		GRSH K 5;
		GRSH L -1;
		Stop;
	XDeath:
		TNT1 A 0 A_SetScale(1.0,1.0);
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		SGUP N 5 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SGUP O 5 A_NoBlocking;
		SGUP PQRST 5;
		SGUP U -1;
		Stop;
	Raise:
		GRSH LKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS.  CH: Shotgunners.txt:549.
// ---------------------------------------------------------------------------
class RS_AbyssSG2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 300;
		BloodColor "Black";
		Radius 20;
		Height 56;
		Speed 13;
		Scale 0.95;
		PainChance 168;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+NOFEAR
		SeeSound "SGUY2/See";
		AttackSound "asgguy/asgfir";
		PainSound "Form2/Hurt";
		DeathSound "Sguy2/Die";
		ActiveSound "grunt/active";
		Obituary "%o was molded to a blue cheese by cheff abyss shotgunner";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell", 64;
		DropItem "RS_CH_ShellBox", 128;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "RS_CH_GreenArmor", 72;
		DropItem "RS_HealthBundle";
		DropItem "Shotgun";
		DropItem "Shotgun", 128;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
		Tag "Shotgun of the abyss";
	}
	States
	{
	Spawn:
		ABSG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ABSG AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		ABSG CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		Loop;
	Missile:
		ABSG E 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABSG E 1 A_JumpIfCloser(800,"Jumper");
		ABSG E 5 A_FaceTarget;
		ABSG FFF 2 Bright A_CustomMissile("RS_AbyssZShotCH2",36,3,random(-2,2));
		Goto See;
	Jumper:
		ABSG E 5 A_FaceTarget;
		ABSG F 5 Bright A_CustomBulletAttack(6,7,random(2,4),1,"RS_SplashAbyss2",0);
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		ABSG F 1 A_CheckSight("See");
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,328),random(-178,178),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		ABSG E 0 A_FaceTarget;
		ABSG E 1 ThrustThingZ(0,12,0,0);
		ABSG E 1 ThrustThing(int(angle+180),32,0,0);   // CH: thrustthing(angle+180,32,0,0)
		ABSG E 5 A_FaceTarget;
		ABSG F 5 Bright A_CustomBulletAttack(6,7,random(2,4),2,"RS_SplashAbyss2",0);
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		ABSG F 1 A_CheckSight("See");
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,328),random(-178,178),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		ABSG E 0 A_FaceTarget;
		ABSG E 1 ThrustThingZ(0,12,0,0);
		ABSG E 1 ThrustThing(int(angle-180),32,0,0);   // CH: thrustthing(angle-180,32,0,0)
		ABSG E 5 A_FaceTarget;
		ABSG F 5 Bright A_CustomBulletAttack(6,7,random(2,4),2,"RS_SplashAbyss2",0);
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		Goto See;
	Pain:
		ABSG G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABSG G 3 A_Pain;
		ABSG G 3;
		Goto PEP;
	PEP:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetSpeed(21);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ABSG H 5;
		ABSG I 5 A_Scream;
		ABSG J 5 A_Fall;
		ABSG KLM 5;
		ABSG N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		ABSG O 5;
		ABSG P 5 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ABSG Q 5 A_Fall;
		ABSG RSTUV 5;
		TNT1 AAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ABSG W -1;
		Stop;
	Raise:
		ABSG NMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU.  CH: Shotgunners.txt:681.  Flame volley.
// ---------------------------------------------------------------------------
class RS_FireBluSG2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 225;
		Radius 20;
		Height 56;
		Scale 0.9;
		Speed 12;
		Mass 5000;
		PainChance 110;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "SSGUNER/sight";
		AttackSound "SSGUNER/SSG";
		PainSound "grunt/pain";
		DeathSound "SSGUNER/death";
		ActiveSound "SSGUNER/idle";
		Obituary "%o got flamed by fireblu shotgunner";
		DropItem "RS_CH_SuperShotgun", 72;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_ShellBox", 128;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_GreenArmor", 34;
		DropItem "RS_HealthBundle", 128;
		Decal "Bulletchip";
		Translation "117:127=198:207","152:159=180:191","9:12=187:191","104:111=183:191","96:105=195:203","3:3=198:198","144:151=200:205","128:143=175:186","64:79=32:47","48:63=198:207","208:223=179:191","13:15=181:184","9:12=205:207","0:3=243:246","236:239=44:47";
		Tag "Gun guy with skin condition";
	}
	States
	{
	Spawn:
		GPOS A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		GPOS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GPOS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GPOS E 10 Bright A_FaceTarget;
		GPOS F 0 A_CustomMissile("RS_FireSGguy",34,-2,0);
		GPOS F 0 A_CustomMissile("RS_FireSGguy",34,6,8);
		GPOS F 0 A_CustomMissile("RS_FireSGguy",34,9,13);
		GPOS F 0 A_CustomMissile("RS_FireSGguy",34,-13,-13);
		GPOS F 8 Bright A_CustomMissile("RS_FireSGguy",34,-10,-8);
		GPOS E 8 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		GPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GPOS G 3 A_Pain;
		GPOS G 3 { bNOPAIN = true; }
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		GPOS H 7;
		GPOS I 7 A_Scream;
		GPOS J 7 A_NoBlocking;
		GPOS KLM 7;
		GPOS N -1;
		Stop;
	XDeath:
		GPOS O 5;
		GPOS P 5 A_XScream;
		GPOS Q 5 A_NoBlocking;
		GPOS RS 5;
		GPOS T -1;
		Stop;
	Raise:
		GPOS NMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON.  CH: Shotgunners.txt:813.  Vanilla stats + CH web.
// ---------------------------------------------------------------------------
class RS_CommonSG : ShotgunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "SGuy";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMSPECIES
		+AVOIDMELEE
		Tag "Former Sergeant";
	}
	States
	{
	Spawn:
		SPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS E 10 A_FaceTarget;
		SPOS F 10 Bright A_SPosAttackUseAtkSound;
		SPOS E 10;
		Goto See;
	Pain:
		SPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SPOS H 5;
		SPOS I 5 A_Scream;
		SPOS J 5 A_NoBlocking;
		SPOS K 5;
		SPOS L -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		SPOS M 5;
		SPOS N 5 A_XScream;
		SPOS OP 5;
		SPOS Q 5 A_NoBlocking;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SPOS RST 5;
		SPOS U -1;
		Stop;
	Raise:
		SPOS L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SPOS KJIH 5;
		Goto See;
	Grow:
		SPOS JIH 5;
		SPOS A 0 A_SpawnItemEx("RS_GreenSG",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN.  CH: Shotgunners.txt:897.  Plasma pellet spread.
// ---------------------------------------------------------------------------
class RS_GreenSG : ShotgunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 45;
		Radius 20;
		Height 56;
		Species "SGuy3";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 100;
		Speed 8;
		PainChance 160;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+AVOIDMELEE
		SeeSound "shotguy/sight";
		AttackSound "shotguy/attack";
		PainSound "shotguy/pain";
		DeathSound "shotguy/death";
		ActiveSound "shotguy/active";
		Obituary "%o got green splash'd";
		DropItem "Shotgun";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell", 64;
		DropItem "RS_CH_Shell", 128;
		Translation "48:63=[85,255,85]:[0,106,0]","16:31=[128,255,128]:[0,128,0]","64:79=[0,174,0]:[0,64,0]","32:47=[0,128,0]:[0,64,0]","208:223=112:118","164:167=119:123","0:0=0:0";
		Tag "Green Former Sergeant";
	}
	States
	{
	Spawn:
		SPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS E 12 A_FaceTarget;
		SPOS F 5 Bright;
		SPOS F 0 A_PlaySound("shotguy/attack");
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,1);
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,0);
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,-1);
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,2);
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,-2);
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,3);
		SPOS F 0 A_CustomMissile("RS_SGshot1",34,-2,-3);
		SPOS E 9;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SPOS H 5;
		SPOS I 5 A_Scream;
		SPOS J 5 A_NoBlocking;
		SPOS K 5;
		SPOS L -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		SGUG N 3;
		SGUG N 2 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SGUG O 5 A_NoBlocking;
		SGUG PQRST 5;
		SGUG U -1;
		Stop;
	Raise:
		SPOS L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SPOS KJIH 5;
		Goto See;
	Grow:
		SPOS JIH 5;
		SPOS A 0 A_SpawnItemEx("RS_BlueSG",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE.  CH: Shotgunners.txt:1033.  Rail volleys, plasma lance.
// ---------------------------------------------------------------------------
class RS_BlueSG : ShotgunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 55;
		Radius 20;
		Height 56;
		Species "SGuy";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 110;
		Speed 9;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+AVOIDMELEE
		AttackSound "shotguy/attack";
		SeeSound "SGUY2/See";
		PainSound "Form2/Hurt";
		DeathSound "Sguy2/Die";
		ActiveSound "shotguy/active";
		Obituary "%o got overdrastic blues relief";
		DropItem "Shotgun";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "HealthBonus";
		DropItem "HealthBonus", 64;
		DropItem "HealthBonus", 128;
		DropItem "RS_CH_ShellBox", 42;
		Translation "16:31=[100,100,255]:[0,0,119]","48:63=[79,79,255]:[0,0,136]","64:79=[0,0,128]:[0,0,34]","32:47=199:207","208:223=240:247","160:167=192:207","168:178=0:0","0:0=0:0","96:111=240:247";
		Tag "Blue Former Sergeant";
	}
	States
	{
	Spawn:
		SPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS E 10 A_FaceTarget;
		SPOS E 5 A_JumpIfCloser(350,"Lance");
		SPOS F 5;
		SPOS F 0 A_CustomRailgun(random(2,8),1,"none","White",RGF_NOPIERCING,1,25,"none",0,0,0,0,3);
		SPOS F 0 A_CustomRailgun(random(2,8),1,"none","Blue",RGF_NOPIERCING,1,12,"none",0,0,0,0,1);
		SPOS F 0 A_CustomRailgun(random(2,8),1,"none","White",RGF_NOPIERCING,1,33,"none",0,0,0,0,1);
		SPOS E 9;
		Goto See;
	Lance:
		SPOS F 2 Bright A_FaceTarget;
		SPOS F 4 Bright A_CustomMissile("RS_SGLance1",34,-2);
		SPOS E 9;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SPOS H 5;
		SPOS I 5 A_Scream;
		SPOS J 5 A_NoBlocking;
		SPOS K 5;
		SPOS L -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		SGUB N 6 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SGUB O 6 A_NoBlocking;
		SGUB PQRST 6;
		SGUB U -1;
		Stop;
	Raise:
		SPOS L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SPOS KJIH 5;
		Goto See;
	Grow:
		SPOS JIH 5;
		SPOS A 0 A_SpawnItemEx("RS_PurpleSG",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE.  CH: Shotgunners.txt:1262.  Charges and burns.
// ---------------------------------------------------------------------------
class RS_PurpleSG : ShotgunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 75;
		Radius 20;
		Height 56;
		Species "SGuy2";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 110;
		Speed 9;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "SGUY2/See";
		AttackSound "none";
		PainSound "Form2/Hurt";
		DeathSound "Sguy2/Die";
		ActiveSound "shotguy/active";
		Obituary "%o was roasted nicely";
		DropItem "Shotgun";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_CellPack", 32;
		DropItem "RS_CH_Shell";
		DropItem "RS_HealthBundle";
		DropItem "ArmorBonus", 128;
		Translation "4:4=250:250","80:95=251:254","96:111=184:191","192:207=250:254";
		Tag "Purple Former Sergeant";
	}
	States
	{
	Spawn:
		HMZP AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HMZP AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HMZP CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HMZP E 2 A_JumpIfCloser(300,"Fire1");
		HMZP E 2 A_Jump(255,"GetCloser");
		Goto See;
	GetCloser:
		HMZP A 0 A_PlaySound("gas/gas1");
		HMZP AB 3 A_SkullAttack(12);
		Goto See;
	Fire1:
		HMZP E 2 A_JumpIfCloser(300,"Fire2");
		HMZP E 2 A_Jump(255,"See");
		Goto See;
	Fire2:
		HMZP E 2 A_FaceTarget;
		HMZP F 1 Bright A_CustomMissile("RS_Purpfire2",42,1,random(-1,-1));
		HMZP E 2 A_FaceTarget;
		HMZP F 1 Bright A_CustomMissile("RS_Purpfire2",42,1,random(-1,-1));
		HMZP E 2 A_FaceTarget;
		HMZP F 1 Bright A_CustomMissile("RS_Purpfire2",42,1,random(-1,-1));
		HMZP E 2 A_MonsterRefire(180,"See");
		Goto Fire1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		HMZP G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HMZP G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HMZP H 5;
		HMZP I 5 A_Scream;
		HMZP J 5 A_NoBlocking;
		HMZP K 5;
		HMZP L -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		SGUP N 0;   // CH: SGUP M -- 0-tic carrier; SGUP ships N-U only, in CH too. Held N so no unresolvable token remains. Nothing changes on screen. Fixed 2026-08-06.
		SGUP N 5 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SGUP O 5 A_NoBlocking;
		SGUP PQRST 5;
		SGUP U -1;
		Stop;
	Raise:
		HMZP LKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW (Orange Sergeant).  CH: Shotgunners.txt:1401.
// Autoshotgun with a 16-shell magazine and a reload.
// ---------------------------------------------------------------------------
class RS_YellowSG : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 85;
		BloodColor "Yellow";
		Radius 20;
		Height 56;
		Speed 9;
		PainChance 128;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+NOFEAR
		SeeSound "SGUY2/See";
		AttackSound "asgguy/asgfir";
		PainSound "Form2/Hurt";
		DeathSound "Sguy2/Die";
		ActiveSound "grunt/active";
		Obituary "%o was made into fine swiss cheese by Orange Sergeant";
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_CH_ShellBox";
		DropItem "HealthBonus";
		DropItem "RS_CH_GreenArmor", 64;
		DropItem "RS_HealthBundle", 128;
		DropItem "Shotgun";
		Tag "Yellow Former Sergeant";
	}
	States
	{
	Spawn:
		ASGZ AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Dodger:
		ASGZ AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ASGZ CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ASGZ A 0 A_Jump(88,"See");
		Loop;
	See:
		ASGZ AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ASGZ CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ASGZ A 0 A_Jump(88,"Dodger");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfInventory("RS_ASGZAmmo",16,"Reload");
		TNT1 A 0 A_Stop;
		ASGZ E 5 A_FaceTarget;
		TNT1 A 0 A_GiveInventory("RS_ASGZAmmo",1);
		ASGZ F 5 Bright A_CustomBulletAttack(5,4,3,3,"BulletPuff",0);
		ASGZ E 7;
		TNT1 A 0 A_JumpIfInventory("RS_ASGZAmmo",16,"Reload");
		TNT1 A 0 A_PlaySound("asgguy/asgld1");
		ASGZ E 5 A_CPosRefire;
		TNT1 A 0 A_GiveInventory("RS_ASGZAmmo",1);
		ASGZ F 5 Bright A_CustomBulletAttack(5,4,3,3,"BulletPuff",0);
		ASGZ E 7;
		TNT1 A 0 A_JumpIfInventory("RS_ASGZAmmo",16,"Reload");
		TNT1 A 0 A_PlaySound("asgguy/asgld1");
		ASGZ E 5 A_CPosRefire;
		TNT1 A 0 A_GiveInventory("RS_ASGZAmmo",1);
		ASGZ F 5 Bright A_CustomBulletAttack(5,4,3,3,"BulletPuff",0);
		ASGZ E 7;
		TNT1 A 0 A_JumpIfInventory("RS_ASGZAmmo",16,"Reload");
		TNT1 A 0 A_PlaySound("asgguy/asgld1");
		ASGZ E 5 A_CPosRefire;
		TNT1 A 0 A_GiveInventory("RS_ASGZAmmo",1);
		ASGZ F 5 Bright A_CustomBulletAttack(5,4,3,3,"BulletPuff",0);
		ASGZ E 7;
		TNT1 A 0 A_PlaySound("asgguy/asgld1");
		TNT1 A 0 A_JumpIfInventory("RS_ASGZAmmo",16,"Reload");
		Goto See;
	Reload:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_PlaySound("asgguy/asgout");
		ASGZ E 60 A_TakeInventory("RS_ASGZAmmo",16);
		ASGZ E 8 A_PlaySound("asgguy/asgin");
		TNT1 A 0 { bNOPAIN = false; }
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		ASGZ G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ASGZ G 3 A_Pain;
		ASGZ G 3 A_Jump(88,"Dodger");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ASGZ H 5;
		ASGZ I 5 A_Scream;
		ASGZ J 5 A_Fall;
		ASGZ KLM 5;
		ASGZ N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		ASGZ O 5;
		ASGZ P 5 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ASGZ Q 5 A_Fall;
		ASGZ RSTUV 5;
		TNT1 AAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ASGZ W -1;
		Stop;
	Raise:
		ASGZ NMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED.  CH: Shotgunners.txt:1555.  RNG seeker storm + SSG.
// ---------------------------------------------------------------------------
class RS_RedSG : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 150;
		Radius 20;
		Height 56;
		Scale 0.9;
		Speed 9;
		Mass 5000;
		PainChance 110;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+NOFEAR
		SeeSound "SSGUNER/sight";
		AttackSound "SSGUNER/SSG";
		PainSound "grunt/pain";
		DeathSound "SSGUNER/death";
		ActiveSound "SSGUNER/idle";
		Obituary "%o got splattered by the deadly force of Red Shotgunner";
		DropItem "RS_CH_SuperShotgun", 128;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_CH_ShellBox";
		DropItem "Shotgun";
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_GreenArmor", 34;
		DropItem "RS_HealthBundle";
		Decal "Bulletchip";
		Translation "112:127=175:191";
		Tag "Red RNG Former Sergeant";
	}
	States
	{
	Spawn:
		GPOS A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		GPOS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GPOS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GPOS E 0 A_JumpIfCloser(650,"Shotgunned");
		GPOS E 10 Bright A_FaceTarget;
		GPOS G 0 A_CustomMissile("RS_RedMessImp3",42,12,0);
		GPOS G 0 A_CustomMissile("RS_RedMessImp3",32,random(4,8),0);
		GPOS G 0 A_CustomMissile("RS_RedMessImp3",22,random(14,26),0);
		GPOS G 0 A_CustomMissile("RS_RedMessImp3",22,12,0);
		GPOS G 0 A_CustomMissile("RS_RedMessImp3",42,random(6,18),0);
		GPOS E 8 Bright;
		Goto See;
	Shotgunned:
		GPOS E 5 Bright A_FaceTarget;
		PLAY F 0 A_JumpIfInventory("RS_ShotgunWhere",1,"Jammed");
		GPOS E 5 Bright A_FaceTarget;
		GPOS F 8 Bright A_CustomBulletAttack(11.2,7.1,random(15,20),random(1,3),"BulletPuff");
		GPOS E 8 Bright;
		PLAY F 0 A_GiveInventory("RS_ShotgunWhere",1);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Jammed:
		GPOS E 8 Bright;
		GPOS G 2 A_PlaySound("weapons/sshotl");
		GPOS G 10 A_TakeInventory("RS_ShotgunWhere",1);
		Goto Missile;
	Pain:
		GPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GPOS G 3 A_Pain;
		GPOS G 3 { bNOPAIN = true; }
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		GPOS H 7;
		GPOS I 7 A_Scream;
		GPOS J 7 A_NoBlocking;
		GPOS KLM 7;
		GPOS N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		GPOS O 5;
		GPOS P 5 A_XScream;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GPOS Q 5 A_NoBlocking;
		GPOS RS 5;
		TNT1 AAA 0 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GPOS T -1;
		Stop;
	Raise:
		GPOS NMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK.  CH: Shotgunners.txt:1863 (commander) / 1994 (troop).
// The Crew Commander summons troops; each troop rolls a five-stance brain.
// ---------------------------------------------------------------------------
class RS_BlackSG3 : Actor   // Shotgun Crew Commander
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 1950;
		Height 56;
		Radius 20;
		RadiusDamageFactor 0.33;
		DamageFactor "Plasma", 1.1;
		DamageFactor "Heroic", 3.0;
		Speed 16;
		PainChance 96;
		Species "BlackSG";
		Monster;
		+BOSS
		-NORADIUSDMG
		+FLOORCLIP
		+DONTMORPH
		+NOINFIGHTING
		+MISSILEMORE
		+THRUSPECIES
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "ZSpecOps/Sight";
		ActiveSound "ZSpecOps/Sight";
		PainSound "ZSpecOps/Pain";
		DeathSound "ZSpecOps/Death";
		Obituary "%o was gunned down by the Leader of black shotgun crew";
		Decal "BulletChip";
		DropItem "Shotgun";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_Medikit";
		DropItem "Backpack";
		DropItem "RS_BackPackBundle";
		// CH: DropItem "RLAssaultShotgunPickup",102 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLSteelBeastPickup",24 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RareArmorPool",32 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		Translation "0:255=%[0.00,0.00,0.00]:[0.67,0.39,0.71]","175:191=112:127","32:47=119:127";
		RenderStyle "SoulTrans";
		Alpha 1.50;
		Scale 1.1;
		Tag "Shotgun Crew Commander";
	}
	States
	{
	Spawn:
		ZSP1 A 0;
		ZSP1 A 0 A_SpawnItemEx("RS_BlackSG2",0,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		ZSP1 A 0 A_SpawnItemEx("RS_BlackSG2",0,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		Goto Scripted;
	Scripted:
		ZSP1 A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackSG") -- announcers dropped per owner
		Goto Idle;
	Idle:
		ZSP1 AAAAAAAAAABBBBBBBBBB 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ZSP1 ABCD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZSP1 A 0 A_Jump(64,"Odd");
		Loop;
	Odd:
		ZSP1 A 2 A_Wander;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZSP1 BC 3 A_FastChase;
		ZSP1 D 2 A_Wander;
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZSP1 A 0 A_JumpIfCloser(500,"Shotgunned");
		ZSP1 A 0 A_Jump(128,"AirStrike","Snipe");
		ZSP1 A 0 A_Jump(255,"Summon","AirStrike","Snipe");
		Goto See;
	Summon:
		ZSP1 G 3 Bright A_PlaySound("ZSpecOps/Sight",7,2,false,ATTN_NONE);
		ZSP1 G 3 Bright A_PlaySound("ZSpecOps/Sight",7,2,false,ATTN_NONE);
		ZSP1 G 3 Bright A_PlaySound("ZSpecOps/Sight",7,2,false,ATTN_NONE);
		ZSP1 A 9 Bright A_FaceTarget;
		ZSP1 A 0 A_SpawnItemEx("RS_BlackSG2",0,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		ZSP1 A 1 Bright A_SpawnItemEx("RS_BlackSG2",0,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		ZSP1 A 1 Bright A_SpawnItemEx("RS_BlackSG2",5,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		ZSP1 A 1 Bright A_SpawnItemEx("RS_BlackSG2",-5,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		Goto See;
	Shotgunned:
		ZSP1 EEE 4 A_FaceTarget;
		ZSP1 F 0 A_PlayWeaponSound("Weapons/ShotGF");
		ZSP1 F 2 Bright A_CustomBulletAttack(random(1,12),random(1,12),random(3,9),random(1,8),"RS_DetoPuffCG");
		ZSP1 F 0 A_Jump(64,"Nadetoss");
		ZSP1 EE 2 A_FaceTarget;
		ZSP1 E 2 A_CheckSight("See");
		ZSP1 E 0 A_JumpIfCloser(450,"Missile");
		Goto See;
	Snipe:
		ZSP1 EEE 8 Bright A_FaceTarget;
		ZSP1 E 1 A_CheckSight("See");
		ZSP1 E 5 Bright A_PlaySound("ZSpecOps/Sight",7,2,false,ATTN_NONE);
		ZSP1 E 1 A_CheckSight("See");
		ZSP1 E 1 A_FaceTarget;
		ZSP1 F 0 A_PlayWeaponSound("Weapons/ShotGF");
		ZSP1 F 4 Bright A_VileTarget("RS_DetoPuffCG2");
		Goto See;
	AirStrike:
		ZSP1 GG 6 Bright A_FaceTarget;
		ZSP1 E 8 Bright A_VileTarget("RS_CHBSTarget");
		ZSP1 EF 5 Bright;
		ZSP1 F 4 Bright A_CustomMissile("RS_AirStrikeCHBS",64,0,1);
		ZSP1 E 2;
		Goto See;
	Nadetoss:
		ZSP1 E 8 A_FaceTarget;
		ZSP1 E 2 A_PlaySound("fire/fire4");
		ZSP1 E 4 A_CustomMissile("RS_SGGasNade",48,0,random(-3,3),0,random(3,12));
		Goto See;
	Pain:
		ZSP1 G 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZSP1 G 4 A_Pain;
		ZSP1 G 0 A_Jump(96,"See");
		Goto Odd;
	Death:
		ZSP1 H 5;
		ZSP1 I 5 A_Scream;
		ZSP1 J 5;
		ZSP1 K 5 A_NoBlocking;
		ZSP1 L -1;
		Stop;
	}
}

class RS_BlackSG2 : Actor   // CH Shotgunners.txt:1994 -- the spec-ops troop.
// No tier icon in CH and none here; squad minion, no tier token (like MrBones).
{
	Default
	{
		Health 280;
		Height 56;
		Radius 20;
		Speed 13;
		PainChance 96;
		DamageFactor "Fire", 0.8;
		DamageFactor "Plasma", 0.8;
		DamageFactor "BFGSplash", 0.7;
		DamageFactor "Heroic", 3.0;
		Species "BlackSG";
		Monster;
		-NORADIUSDMG
		+FLOORCLIP
		+DONTHARMSPECIES
		+NOINFIGHTING
		+THRUSPECIES
		+MISSILEMORE
		-ACTIVATEMCROSS
		+NOFEAR
		SeeSound "ZSpecOps/Sight";
		ActiveSound "ZSpecOps/Sight";
		PainSound "ZSpecOps/Pain";
		DeathSound "ZSpecOps/Death";
		Obituary "%o was gunned down by the black shotgun crew";
		Decal "BulletChip";
		DropItem "Shotgun";
		DropItem "RS_ArmorBundle", 84;
		DropItem "RS_HealthBundle", 178;
		DropItem "RS_CH_ShellBox", 64;
		DropItem "RS_CH_Medikit", 34;
		Tag "Black Shotgunner troop";
	}
	States
	{
	Spawn:
		ZSP1 AAAAAAAAAABBBBBBBBBB 1 A_Look;
		Loop;
	See:
		ZSP1 A 0 A_TakeInventory("RS_ZSpecOpAggressive",1);
		ZSP1 A 0 A_TakeInventory("RS_ZSpecOpSprint",1);
		ZSP1 A 0 A_TakeInventory("RS_ZSpecOpWander",1);
		ZSP1 A 0 A_TakeInventory("RS_ZSpecOpCreep",1);
		ZSP1 A 0 A_TakeInventory("RS_ZSpecOpBerserk",1);
		ZSP1 A 0 { bMISSILEMORE = false; }
		ZSP1 A 0 { bMISSILEEVENMORE = false; }
		ZSP1 A 0 { bAVOIDMELEE = false; }
		ZSP1 A 0 { bNOPAIN = false; }
		ZSP1 A 0 A_GiveInventory("RS_ZSpecOpsSGSitRep",1);
		ZSP1 A 0 A_JumpIfInventory("RS_ZSpecOpAggressive",1,"AggressiveSwitch");
		ZSP1 A 0 A_JumpIfInventory("RS_ZSpecOpSprint",1,"SprintSwitch");
		ZSP1 A 0 A_JumpIfInventory("RS_ZSpecOpWander",1,"WanderSwitch");
		ZSP1 A 0 A_JumpIfInventory("RS_ZSpecOpCreep",1,"CreepSwitch");
		ZSP1 A 0 A_JumpIfInventory("RS_ZSpecOpBerserk",1,"BerserkSwitch");
		ZSP1 A 0 A_JumpIfMasterCloser(1000,"See");   // CH's own ZPS1 typo for ZSP1; 0-tic, renders nothing either way
		ZSP1 A 0 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
	AggressiveSwitch:
		ZSP1 A 0 { bMISSILEMORE = true; }
		ZSP1 A 0 { bMISSILEEVENMORE = true; }
		Goto AggressiveSee;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSG2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		Stop;
	AggressiveSee:
		ZSP1 A 3 A_Chase(null,"AggressiveMissile");
		ZSP1 A 0 A_Jump(192,2);
		ZSP1 A 0 A_JumpIfHealthLower(50,"See");
		ZSP1 A 0 A_Jump(32,2);
		ZSP1 A 0 A_JumpIfCloser(768,1);
		ZSP1 A 0 A_JumpIfMasterCloser(1000,"See");   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		ZSP1 A 0 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto See;
		ZSP1 A 3 A_Chase(null,"AggressiveMissile");
		ZSP1 A 0 A_Jump(192,2);
		ZSP1 A 0 A_JumpIfHealthLower(50,"See");
		ZSP1 A 0 A_Jump(32,2);
		ZSP1 A 0 A_JumpIfCloser(768,1);
		ZSP1 A 0 A_JumpIfMasterCloser(1000,"See");   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		ZSP1 A 0 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto See;
		ZSP1 B 3 A_Chase(null,"AggressiveMissile");
		ZSP1 B 0 A_Jump(192,2);
		ZSP1 B 0 A_JumpIfHealthLower(50,"See");
		ZSP1 B 0 A_Jump(32,2);
		ZSP1 B 0 A_JumpIfCloser(768,1);
		Goto See;
		ZSP1 B 3 A_Chase(null,"AggressiveMissile");
		ZSP1 B 0 A_Jump(192,2);
		ZSP1 B 0 A_JumpIfHealthLower(50,"See");
		ZSP1 B 0 A_Jump(32,2);
		ZSP1 B 0 A_JumpIfCloser(768,1);
		ZSP1 A 0 A_JumpIfMasterCloser(1000,"See");   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		ZSP1 A 0 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);   // CH: ZPS1 -- CH typo; ZSP1 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto See;
		ZSP1 C 3 A_Chase(null,"AggressiveMissile");
		ZSP1 C 0 A_Jump(192,2);
		ZSP1 C 0 A_JumpIfHealthLower(50,"See");
		ZSP1 C 0 A_Jump(32,2);
		ZSP1 C 0 A_JumpIfCloser(768,1);
		Goto See;
		ZSP1 C 3 A_Chase(null,"AggressiveMissile");
		ZSP1 C 0 A_Jump(192,2);
		ZSP1 C 0 A_JumpIfHealthLower(50,"See");
		ZSP1 C 0 A_Jump(32,2);
		ZSP1 C 0 A_JumpIfCloser(768,1);
		Goto See;
		ZSP1 D 3 A_Chase(null,"AggressiveMissile");
		ZSP1 D 0 A_Jump(192,2);
		ZSP1 D 0 A_JumpIfHealthLower(50,"See");
		ZSP1 D 0 A_Jump(32,2);
		ZSP1 D 0 A_JumpIfCloser(768,1);
		Goto See;
		ZSP1 D 3 A_Chase(null,"AggressiveMissile");
		ZSP1 D 0 A_Jump(192,2);
		ZSP1 D 0 A_JumpIfHealthLower(50,"See");
		ZSP1 D 0 A_Jump(32,2);
		ZSP1 D 0 A_JumpIfCloser(768,1);
		Goto See;
		ZSP1 A 0;
		Loop;
	AggressiveMissile:
		ZSP1 EEE 4 A_FaceTarget;
		ZSP1 F 0 A_PlayWeaponSound("Weapons/ShotGF");
		ZSP1 F 2 Bright A_CustomBulletAttack(8,6,7,4,"RS_DetoPuffCG");
		ZSP1 F 0 A_Jump(64,"NadeToss");
		ZSP1 EEE 2 A_FaceTarget;
		Goto AggressiveSee;
	NadeToss:
		ZSP1 E 8 A_FaceTarget;
		ZSP1 E 2 A_PlaySound("fire/fire4");
		ZSP1 E 4 A_CustomMissile("RS_SGGasNade",48,0,random(-3,3),0,random(3,12));
		Goto AggressiveSee;
	SprintSwitch:
		ZSP1 A 0 { bNOPAIN = true; }
		Goto SprintSee;
	SprintSee:
		ZSP1 A 2 A_Chase(null,null);
		ZSP1 A 0 A_JumpIfCloser(384,"See");
		ZSP1 A 2 A_Chase(null,null);
		ZSP1 A 0 A_JumpIfCloser(384,"See");
		ZSP1 B 2 A_Chase(null,null);
		ZSP1 B 0 A_JumpIfCloser(384,"See");
		ZSP1 B 2 A_Chase(null,null);
		ZSP1 B 0 A_JumpIfCloser(384,"See");
		ZSP1 C 2 A_Chase(null,null);
		ZSP1 C 0 A_JumpIfCloser(384,"See");
		ZSP1 C 2 A_Chase(null,null);
		ZSP1 C 0 A_JumpIfCloser(384,"See");
		ZSP1 D 2 A_Chase(null,null);
		ZSP1 D 0 A_JumpIfCloser(384,"See");
		ZSP1 D 2 A_Chase(null,null);
		ZSP1 D 0 A_JumpIfCloser(384,"See");
		Loop;
	WanderSwitch:
		ZSP1 A 0 A_ClearTarget;
		Goto WanderSee;
	WanderSee:
		ZSP1 A 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 A 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 B 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 B 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 C 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 C 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 D 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		ZSP1 D 4 A_Wander;
		ZSP1 A 0 A_LookEx(10,0,0,0,360,"See");
		Loop;
	CreepSwitch:
		ZSP1 A 0 { bMISSILEMORE = true; }
		ZSP1 A 0 { bAVOIDMELEE = true; }
		Goto CreepSee;
	CreepSee:
		ZSP1 A 0 A_CheckSight("CreepCheck");
		ZSP1 A 0 A_JumpIfHealthLower(50,"See");
		ZSP1 AABBCCDD 5 A_Chase(null,"CreepMissile",2);
		Loop;
	CreepCheck:
		ZSP1 A 0 A_Jump(32,"See");
		Goto CreepSee+1;
	CreepMissile:
		ZSP1 EEE 4 A_FaceTarget;
		ZSP1 F 0 A_PlayWeaponSound("Weapons/ShotGF");
		ZSP1 F 2 Bright A_CustomBulletAttack(8,6,7,4,"RS_DetoPuffCG");
		ZSP1 EEE 2 A_FaceTarget;
		Goto CreepSee;
	BerserkSwitch:
		ZSP1 A 0 { bMISSILEMORE = true; }
		ZSP1 A 0 { bMISSILEEVENMORE = true; }
		ZSP1 A 0 { bNOPAIN = true; }
		Goto BerserkSee;
	BerserkSee:
		ZSP1 AABBCCDD 3 A_Chase(null,"BerserkMissile");
		ZSP1 A 0 A_JumpIfCloser(768,1);
		Goto See;
		ZSP1 A 0;
		Loop;
	BerserkMissile:
		ZSP1 EE 4 A_FaceTarget;
		ZSP1 F 0 A_PlayWeaponSound("Weapons/ShotGF");
		ZSP1 F 2 Bright A_CustomBulletAttack(8,6,7,4,"RS_DetoPuffCG");
		ZSP1 EEE 2 A_FaceTarget;
		ZSP1 F 0 A_Jump(192,"BerserkSee");
		ZSP1 F 0 A_MonsterRefire(40,"BerserkSee");
		Loop;
	Pain:
		ZSP1 G 4;
		ZSP1 G 4 A_Pain;
		ZSP1 G 0 A_Jump(96,"See");
		Goto WhatPainState;
	WhatPainState:
		ZSP1 G 0 A_JumpIfInventory("RS_ZSpecOpAggressive",1,"AggressiveSee");
		ZSP1 G 0 A_JumpIfInventory("RS_ZSpecOpSprint",1,"SprintSee");
		ZSP1 G 0 A_JumpIfInventory("RS_ZSpecOpWander",1,"WanderSee");
		ZSP1 G 0 A_JumpIfInventory("RS_ZSpecOpCreep",1,"CreepSee");
		ZSP1 G 0 A_JumpIfInventory("RS_ZSpecOpBerserk",1,"BerserkSee");
		Goto AggressiveSee;
	Death:
		ZSP1 H 5;
		ZSP1 I 5 A_Scream;
		ZSP1 J 5;
		ZSP1 K 5 A_NoBlocking;
		ZSP1 L -1;
	Raise:
		ZSP1 LKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE.  CH: Shotgunners.txt:2334 (Benellus) / 2532 (EX).
// The LegenDoom "Easter" gate is stripped like DRLA (cross-mod):
// CH: Missile first line was A_JumpIfInventory("LDLegendaryMonsterTransformed",1,"Easter")
// CH: Easter played "Bene/Song" once, then fell through to Missile+1.
// ---------------------------------------------------------------------------
class RS_WhiteSG2 : Actor   // BENELLUS, GOD OF SHOTGUNS
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Monster;
		+NOGRAVITY
		+FLOAT
		+FLOATBOB
		+DONTMORPH
		+BOSSDEATH
		+SEEINVISIBLE
		+NOBLOOD
		+NOFEAR
		+LOOKALLAROUND
		+MISSILEMORE
		+MISSILEEVENMORE
		+BOSS
		-NORADIUSDMG
		Health 5000;
		DamageFactor "None", 0.75;
		DamageFactor "Fire", 2.0;
		DamageFactor "Plasma", 1.2;
		DamageFactor "Melee", 2.0;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		RadiusDamageFactor 1.5;
		Radius 20;
		PainChance 8;
		Height 56;
		Mass 400;
		Speed 28;
		FloatSpeed 28;
		SeeSound "weapons/sshotl";
		ActiveSound "weapons/sshotf";
		PainSound "weapons/sshotf";
		DeathSound "weapons/sshotf";
		AttackSound "shotguy/attack";
		DropItem "RS_SGBurst", 255, 8;
		DropItem "InvulnerabilitySphere";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "Shell";
		DropItem "Shell";
		DropItem "Shell";
		DropItem "Shell";
		DropItem "Shell";
		// CH: DropItem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLDemonicWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLLegendaryWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",24 -- DRLA stripped per owner 2026-08-05
		DropItem "SuperShotgun";
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_SuperShotgun";
		// CH: DropItem "RLQuadShotgunPickup",88 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLSteelBeastPickup",72 -- DRLA stripped per owner 2026-08-05
		Obituary "%o never even had a chance against Benellus, God of Shotguns";
		Tag "BENELLUS,GOD OF SHOTGUNS";
	}
	States
	{
	Spawn:
		BENE A 1;
		Goto Scripted;
	Scripted:
		BENE A 1;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSG") -- announcers dropped per owner
		Goto Idle;
	Idle:
		BENE ABCD 5 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BENE ABCD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE A 0 A_Jump(128,"See2");
		Loop;
	See2:
		BENE ABCD 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE A 0 A_Jump(128,"See2");
		Loop;
	Pain:
		BENE D 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE D 5 A_Pain;
		BENE D 2 A_Jump(128,"Gifts");
		Goto See2;
	Missile:
		// CH: A_JumpIfInventory("LDLegendaryMonsterTransformed",1,"Easter") -- LegenDoom cross-mod, stripped
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE A 0 A_Jump(256,"SG","Gifts","Punisher");
		Goto See;
	Gifts:
		BENE A 8 Bright A_PlaySound("DSDBLOAD",0,2,false,ATTN_NONE);
		BENE A 8 Bright A_PlaySound("DSDBCLS",0,2,false,ATTN_NONE);
		BENE ABCD 1 Bright A_CustomMissile("RS_MineShotgun",random(20,60),random(-15,15),random(-20,20),0);
		Goto See;
	Punisher:
		BENE A 10 Bright A_PlaySound("DSDSHTGN",7,2,false,ATTN_NONE);
		BENE A 8 Bright;
		BENE K 2 Bright A_VileTarget("RS_Shotgunpunishernerfed");
		Goto See;
	SG:
		BENE A 2 A_FaceTarget;
		BENE AAA 7 Bright A_PlaySound("DSSGCOCK",0,2,false,ATTN_NONE);
		BENE KBJCGDF 6 Bright A_CustomBulletAttack(random(5,180),random(0,50),random(5,30),random(1,3),"BulletPuff",0);
		BENE K 0 A_CheckSight("See");
		BENE K 0 A_CheckRange(1250,"See");
		BENE KB 2 Bright A_CustomBulletAttack(22.5,0,random(5,18),random(1,5),"BulletPuff",0);
		BENE EAHBICLD 6 Bright A_CustomBulletAttack(random(5,180),random(0,50),random(5,30),random(1,3),"BulletPuff",0);
		BENE A 1 A_MonsterRefire(128,"See");
		Goto SG;
	Death:
		BENE AAAAAA 1 A_Scream;
		BENE A 8 A_Fall;
		BENE AAABCDDDD 6 A_CustomMissile("RS_HKRedDeath",random(0,80),random(-30,50),CMF_AIMOFFSET,2,-10);
		BENE DDDDDDDDDDDDDDDDDDDD 1 A_SpawnItemEx("Shotgun",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		BENE D 8 Radius_Quake(40,60,0,40,0);
		BENE DDDDDDDDDDDDDDDDDDDD 1 A_SpawnItemEx("Shotgun",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		BENE D 6 A_SetTranslucent(0.75);
		BENE D 6 A_SetTranslucent(0.5);
		BENE D 6 A_SetTranslucent(0.25);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cactus",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,232);
		Stop;
	}
}

class RS_WhiteSGEX : Actor   // CH Shotgunners.txt:2532 -- BENELLUS, ANGRIER
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Monster;
		+NOGRAVITY
		+FLOAT
		+FLOATBOB
		+BOSSDEATH
		+SEEINVISIBLE
		+NOBLOOD
		+DONTMORPH
		+NOFEAR
		+NOTIMEFREEZE
		+LOOKALLAROUND
		+MISSILEMORE
		+MISSILEEVENMORE
		+THRUSPECIES
		+BOSS
		-NORADIUSDMG
		Health 12537;
		DamageFactor "None", 0.75;
		DamageFactor "Fire", 2.0;
		DamageFactor "Plasma", 1.25;
		DamageFactor "Melee", 2.0;
		DamageFactor "PlayerVoid", 0.5;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		RadiusDamageFactor 2.0;
		Species "BENE";
		Radius 20;
		PainChance 14;
		Height 56;
		Mass 400;
		Speed 31;
		FloatSpeed 31;
		Scale 1.25;
		SeeSound "weapons/sshotl";
		ActiveSound "weapons/sshotf";
		PainSound "weapons/sshotf";
		DeathSound "weapons/sshotf";
		AttackSound "shotguy/attack";
		DropItem "RS_SGBurst", 255, 8;
		DropItem "InvulnerabilitySphere";
		DropItem "Shell";
		DropItem "Shell";
		DropItem "Shell";
		DropItem "Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		DropItem "RS_CH_Shell";
		// CH: DropItem "RareArmorPool" -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLDemonicWeaponSpawner",24 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLLegendaryWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",32 -- DRLA stripped per owner 2026-08-05
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_SuperShotgun";
		DropItem "SuperShotgun";
		DropItem "SuperShotgun";
		// CH: DropItem "RLQuadShotgunPickup",128 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLSteelBeastPickup",128 -- DRLA stripped per owner 2026-08-05
		Obituary "%o never even had a chance against more seriously fighting Benellus, God of Shotguns";
		Tag "BENELLUS,GOD OF SHOTGUNS,ANGRIER";
	}
	States
	{
	Spawn:
		BENE A 1;
		Goto Scripted;
	Scripted:
		BENE A 1;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSG") -- announcers dropped per owner
		BENE A 1 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		BENE ABCD 5 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BENE AB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		BENE CD 2 A_Chase;
		TNT1 AAAAA 0 A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE A 0 A_Jump(128,"See2");
		Loop;
	See2:
		BENE ABCD 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE A 0 A_Jump(128,"See2");
		Loop;
	Pain:
		BENE D 2 A_SpawnItemEx("Shell",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		BENE D 2 A_SpawnItemEx("RS_ShotgunShrine",random(-128,128),random(-128,128),0,0,0,0,0,SXF_NOCHECKPOSITION,176);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE D 2 A_Pain;
		BENE D 2 A_Jump(128,"Tele");
		Goto See2;
	Tele:
		BENE DDDD 1 A_Wander;
		Goto See2;
	Missile:
		// CH: A_JumpIfInventory("LDLegendaryMonsterTransformed",1,"Easter") -- LegenDoom cross-mod, stripped
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BENE A 0 A_JumpIfCloser(1500,"OtherM");
		BENE A 0 A_Jump(128,"FocusedHitScan");
	ShotgunRounded:
		BENE ABCD 2;
		BENE AAAAAAAAAAAAAAAAAAAA 1 Bright A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		TNT1 AAAAAAAAA 0 A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		BENE K 2 Bright A_Jump(64,"Shrines");
		BENE K 2 Bright A_VileTarget("RS_Shotgunpunisher");
		BENE D 3 A_SpawnItemEx("RS_ShotgunShrine",random(-128,128),random(-1,178),0,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE D 3 A_SpawnItemEx("RS_ShotgunShrine",random(-128,128),random(-178,1),0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Shrines:
		BENE K 2 Bright A_VileTarget("RS_Shotgunpunisher2");
		BENE D 3 A_SpawnItemEx("RS_ShotgunShrine",random(-128,128),random(-1,178),0,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE D 3 A_SpawnItemEx("RS_ShotgunShrine",random(-128,128),random(-178,1),0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	FocusedHitScan:
		BENE A 1 Bright A_FaceTarget;
		TNT1 AAAAA 0 A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		BENE AAAAAA 1 Bright A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		BENE A 8 Bright A_FaceTarget;
		BENE KBJCGDF 5 Bright A_CustomBulletAttack(2,2,random(3,12),random(1,6),"BulletPuff",0);
		BENE KD 3;
		Goto See;
	FocusedFire:
		BENE AAAAAA 1 Bright A_CustomMissile("RS_SparkPuff1",42,0,random(0,360),CMF_AIMOFFSET,random(-150,150));
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,-62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,-62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,62,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,62,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,-62,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,-62,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",31,62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-31,62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",31,-62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-31,-62,62,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,31,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,31,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,-31,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,-31,-22,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",75,75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-75,75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",75,-75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-75,-75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",75,75,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-75,75,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",75,-75,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-75,-75,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",32,75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-32,75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",32,-75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-32,-75,42,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",75,32,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-75,32,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",75,-32,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-75,-32,-2,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,-62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,-62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",32,62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-32,62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",32,-62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-32,-62,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,32,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,32,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",62,-32,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 0 A_SpawnItemEx("RS_SparkShieldBen",-62,-32,20,0,0,0,0,SXF_NOCHECKPOSITION);
		BENE A 6 Bright A_FaceTarget;
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_ABSOLUTEPITCH,random(1,5));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_ABSOLUTEPITCH,random(-9,8));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_AIMOFFSET,random(3,9));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_AIMOFFSET,random(1,4));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_ABSOLUTEPITCH,random(-9,4));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_AIMOFFSET,random(-3,3));
		BENE A 6 Bright A_FaceTarget;
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_AIMOFFSET,random(-3,5));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_ABSOLUTEPITCH,random(-9,8));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_AIMOFFSET,random(-1,7));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_ABSOLUTEPITCH,random(-9,6));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_AIMOFFSET,random(-2,6));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_ABSOLUTEPITCH,random(-9,7));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE A 8 Bright A_FaceTarget;
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_ABSOLUTEPITCH,random(-9,4));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_AIMOFFSET,random(-2,2));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_ABSOLUTEPITCH,random(-9,9));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_AIMOFFSET,random(-1,1));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_AIMOFFSET,random(-2,2));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_ABSOLUTEPITCH,random(-5,6));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE A 8 Bright A_FaceTarget;
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_AIMOFFSET,random(-1,1));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_ABSOLUTEPITCH,random(-5,1));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_ABSOLUTEPITCH,random(-8,5));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-1,1),CMF_AIMOFFSET,random(-1,1));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-8,8),CMF_ABSOLUTEPITCH,random(-9,5));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-12,12));
		BENE KBJCGDF 1 Bright A_CustomMissile("RS_SparkFireBen",52,0,random(-5,5),CMF_AIMOFFSET,random(-3,3));
		BENE A 10 Bright;
		Goto See;
	OtherM:
		BENE A 0 A_Jump(256,"SG","Gifts","FocusedFire","ShotgunRounded");
		Goto See;
	Gifts:
		BENE ABCD 1 Bright A_CustomMissile("RS_MineShotgun",random(20,60),random(-15,15),random(-20,20),0);
		Goto See;
	SG:
		BENE A 2 A_FaceTarget;
		BENE KBJCGDF 4 Bright A_CustomBulletAttack(random(5,180),random(0,50),random(5,30),random(1,3),"BulletPuff",0);
		BENE K 0 A_CheckSight("See");
		BENE K 0 A_CheckRange(1250,"See");
		BENE KB 2 Bright A_CustomBulletAttack(22.5,0,random(5,18),random(1,5),"BulletPuff",0);
		BENE EAHBICLD 4 Bright A_CustomBulletAttack(random(5,180),random(0,50),random(5,30),random(1,3),"BulletPuff",0);
		BENE A 1 A_MonsterRefire(128,"See");
		Goto SG;
	Death:
		BENE AAAAAA 1 A_Scream;
		BENE A 8 A_Fall;
		BENE AAABCDDDD 6 A_CustomMissile("RS_HKRedDeath",random(0,80),random(-30,50),CMF_AIMOFFSET,2,-10);
		BENE DDDDDDDDDDDDDDDDDDDD 1 A_SpawnItemEx("Shotgun",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		BENE D 8 Radius_Quake(40,60,0,40,0);
		BENE DDDDDDDDDDDDDDDDDDDD 1 A_SpawnItemEx("Shotgun",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		BENE D 6 A_SetTranslucent(0.75);
		BENE D 6 A_SetTranslucent(0.5);
		BENE D 6 A_SetTranslucent(0.25);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cactus",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,128);
		Stop;
	}
}
