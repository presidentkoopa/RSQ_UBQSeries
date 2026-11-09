// ============================================================================
// RS_Chaingunner.zs -- Colourful Hell Chaingunner family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Chaingunners.txt (3,169 lines,
// read whole). Every actor cites its CH line. Support: RS_ChaingunnerFX.zs.
// Tier ladder as before: 1 Common .. 13 Brown (CH icon index).
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Chaingunners.txt:1 -- Colourset12 replaces ChaingunGuy.
// Green/Blue/Purple/Yellow/Red have no cvar stub in CH; they enter directly.
// ---------------------------------------------------------------------------
class RS_ChaingunnerColourset : RandomSpawner replaces ChaingunGuy
{
	Default
	{
		DropItem "RS_CommonCGuy", 255, 640;
		DropItem "RS_GreenCGuy", 255, 460;
		DropItem "RS_CyanCGuy", 255, 130;
		DropItem "RS_BlueCGuy", 255, 200;
		DropItem "RS_PurpleCGuy", 255, 100;
		DropItem "RS_GrayCGuy", 255, 35;
		DropItem "RS_BrownCGuy", 255, 35;
		DropItem "RS_AbyssCGuy", 255, 30;
		DropItem "RS_YellowCGuy", 255, 60;
		DropItem "RS_FireBluCGuy", 255, 20;
		DropItem "RS_RedCGuy", 255, 35;
		DropItem "RS_BlackCGuy", 255, 2;
		DropItem "RS_WhiteCGuy", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families.
// ---------------------------------------------------------------------------
class RS_BrownCGuy : Actor   // CH Chaingunners.txt:18
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
		TNT1 A 0 A_SpawnItemEx("RS_ChaingunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanCGuy : Actor   // CH Chaingunners.txt:234
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
		TNT1 A 0 A_SpawnItemEx("RS_ChaingunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssCGuy : Actor   // CH Chaingunners.txt:411
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
		TNT1 A 0 A_SpawnItemEx("RS_ChaingunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayCGuy : Actor   // CH Chaingunners.txt:582
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
		TNT1 A 0 A_SpawnItemEx("RS_ChaingunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluCGuy : Actor   // CH Chaingunners.txt:944
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
		TNT1 A 0 A_SpawnItemEx("RS_ChaingunnerColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackCGuy : Actor   // CH Chaingunners.txt:1873
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
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 1, "EX1");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 2, "EX2");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 3, "EX3");
		TNT1 A 0 A_SpawnItemEx("RS_BlackCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedCGuy",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCGuyEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackCGuyEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackCGuyEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteCGuy : Actor   // CH Chaingunners.txt:2501
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteCguy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCGuy",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN.  CH: Chaingunners.txt:40.  Deploys sandbag cover.
// ---------------------------------------------------------------------------
class RS_BrownCGuy2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 250;
		BloodColor "red";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "BrownCguy";
		Radius 20;
		Height 56;
		Speed 6;
		PainChance 102;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+AVOIDMELEE
		+NOINFIGHTING
		+NOFEAR
		SeeSound "cguy2/see";
		PainSound "form2/hurt";
		DeathSound "cguy2/die";
		ActiveSound "form2/active";
		AttackSound "chainguy/attack";
		Obituary "%o got rolled out by brown chaingunner";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_implyingclip", 128;
		DropItem "RS_ArmorBundle", 64;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "Chaingun";
		DropItem "RS_HealthBundle", 128;
		Translation "96:111=@56[79,39,30]","3:3=74:74","9:12=236:239","82:95=67:79";
		Tag "Brown Noise Maker";
	}
	States
	{
	Spawn:
		CZV1 AB 10 A_Look;
		Loop;
	See:
		CZV1 AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZV1 CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		CZV1 U 5 A_FaceTarget;
		TNT1 A 0 A_CheckProximity("More","Chaingunguy",128,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZV1 UUU 10 A_SpawnItemEx("RS_BrownSandBagCGuy",32,random(-32,32),12,random(3,9),0,random(3,9),random(-9,9),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZV1 U 5 A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(1400,"M1");
		CZV1 F 5 Bright A_CustomBulletAttack(2,2,1,random(2,9),"BulletPuff");
		CZV1 F 5 Bright A_CustomBulletAttack(4,4,1,random(2,9),"BulletPuff");
		CZV1 F 5 Bright A_CustomBulletAttack(6,6,1,random(2,9),"BulletPuff");
		CZV1 F 1 A_CheckSight("See");
		CZV1 F 1 A_MonsterRefire(64,"See");
		Goto Missile+6;
	More:
		CZV1 UUU 10 A_SpawnItemEx("RS_BrownSandBagCGuy",32,random(-64,64),12,random(3,14),0,random(4,14),random(-18,18),SXF_NOCHECKPOSITION);
		CZV1 UUU 10 A_SpawnItemEx("RS_BrownSandBagCGuy",64,random(-64,64),12,random(5,14),0,random(4,14),random(-18,18),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto Missile+6;
	M1:
		CZV1 E 10 Bright;
		CZV1 E 5 A_FaceTarget;
		CZV1 FE 3 A_CustomMissile("RS_BrownOrbCguy",32,-6,random(-5,5),0,random(-1,5));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZV1 FE 3 A_CustomMissile("RS_BrownOrbCguy",32,-6,random(-5,5),0,random(-1,5));
		CZV1 F 1 A_CheckSight("See");
		CZV1 F 1 A_MonsterRefire(64,"See");
		Goto M1+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CZV1 G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZV1 G 3 A_Pain;
		CZV1 G 1;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CZV1 H 5;
		CZV1 I 5 A_Scream;
		CZV1 J 5 A_Fall;
		CZV1 KLM 5;
		CZV1 M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (owner: vanilla gore ok)
		CZV1 NO 5;
		CZV1 P 5 A_XScream;
		CZV1 Q 5 A_Fall;
		CZV1 RS 5;
		CZV1 S -1;
		Stop;
	Raise:
		CZV1 MLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN ("Jetpack Larry").  CH: Chaingunners.txt:256.
// ---------------------------------------------------------------------------
class RS_CyanCGuy2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 125;
		Radius 20;
		Height 56;
		PainChance 88;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_PlasmaRifle", 32;
		DropItem "RS_ArmorBundle", 88;
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_Berserk", 64;
		DropItem "Chaingun";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo", 128;
		Mass 3500;
		Speed 11;
		BloodColor "Cyan";
		DamageFactor "Fire", 1.5;
		DamageFactor "Melee", 1.5;
		DamageFactor "Ice", 0.10;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Falling", 0.0;
		RenderStyle "Add";
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+AVOIDMELEE
		+DONTHARMSPECIES
		+MISSILEMORE
		+NOFEAR
		+NOICEDEATH
		+BRIGHT
		+LAXTELEFRAGDMG
		SeeSound "cguy2/see";
		PainSound "form2/hurt";
		DeathSound "cguy2/die";
		ActiveSound "form2/active";
		AttackSound "chainguy/attack";
		Obituary "%o was frost torn by cyan chaingunner";
		Tag "Jetpack Larry";
		Translation "0:255=%[0.30,0.57,1.22]:[1.01,2.00,2.00]","88:90=%[0.00,0.00,1.76]:[0.43,1.22,2.00]","61:61=%[0.00,0.00,1.59]:[0.52,0.52,2.00]","57:57=%[0.09,0.02,1.35]:[0.03,0.38,1.74]";
	}
	States
	{
	Spawn:
		CPS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CPS2 AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"Dodge1","Dodge2");
		TNT1 A 0 A_Jump(232,"SeeMe","See2");
		Loop;
	See2:
		CPS2 AABBCCDD 1 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	SeeMe:
		CPS2 A 0 A_JumpIfInTargetLOS("Jumpy",0,JLOSF_DEADNOJUMP,750);
		Goto See;
	Jumpy:
		CPS2 A 2 A_FastChase;
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 A 1 ThrustThingZ(0,64,0,0);
		CPS2 A 3 ThrustThing(int(angle-randompick(130,180,230)),12,0,0);   // CH: thrustthing(angle-randompick(130,180,230),12,0,0)
		CPS2 A 1 ThrustThingZ(0,32,0,0);
		CPS2 A 1 ThrustThing(int(angle),24,0,0);   // CH: thrustthing(angle,24,0,0)
		Goto See;
	Dodge1:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");
		TNT1 A 0 ThrustThingZ(0,68,0,0);
		CPS2 A 5 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		Goto See;
	Dodge2:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");
		TNT1 A 0 ThrustThingZ(0,68,0,0);
		CPS2 A 5 ThrustThing(int(angle*256/360+192),20,0,0);   // CH: ThrustThing(angle*256/360+192,20,0,0)
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 E 11 A_FaceTarget;
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-11,11),0,random(-5,5));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-10,10),0,random(-4,4));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-9,9),0,random(-4,4));
		TNT1 A 0 A_CheckSight("See");
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-8,8),0,random(-3,3));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-7,7),0,random(-3,3));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-6,6),0,random(-2,2));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-5,5),0,random(-2,2));
		TNT1 A 0 A_CheckSight("See");
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-4,4),0,random(-1,1));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-3,3),0,random(-1,1));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-2,2));
		TNT1 A 0 A_CheckSight("See");
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,random(-1,1));
		TNT1 A 0 A_CheckSight("See");
	Missile2:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 E 1 A_FaceTarget;
		CPS2 FE 3 A_CustomMissile("RS_IceZombieShot2",32,0,0);
		CPS2 F 1 A_MonsterRefire(64,"See");
		Goto Missile2+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CPS2 G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 G 3 A_Pain;
		CPS2 G 1 A_Jump(128,"Dodge1","Dodge2");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CPS2 H 5;
		CPS2 I 5 A_Scream;
		CPS2 J 5 A_NoBlocking(false);
		CPS2 KLMNO 5;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,254);
		CPS2 P 5 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS ("Abyss Captain").  CH: Chaingunners.txt:434.
// ---------------------------------------------------------------------------
class RS_AbyssCGuy2 : Actor
{
	int user_hide;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 500;
		BloodColor "Black";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 8;
		PainChance 80;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		SeeSound "lady/aggro";
		PainSound "science/pain";
		DeathSound "science/die";
		ActiveSound "lady/active";
		Obituary "%o met the nasty abyssal chaingunner";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_PlasmaRifle", 64;
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "Chaingun";
		DropItem "RS_HealthBundle";
		// CH: DropItem "RLOverchargeSystemArmorPickup",46 -- DRLA stripped per owner 2026-08-05
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
		Tag "Abyss Captain";
	}
	States
	{
	Spawn:
		PZOW AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PZOW AABBCCDD 4 A_Chase;
		PZOW A 0 A_Jump(128,"Hide");
		Loop;
	Hide:
		TNT1 A 0 A_JumpIf(user_hide >= 1,"See");
		PZOW A 1 A_SetTranslucent(0.85);
		PZOW A 1 A_SetTranslucent(0.65);
		PZOW A 1 A_SetTranslucent(0.45);
		PZOW A 1 A_SetTranslucent(0.25);
		PZOW A 1 A_SetTranslucent(0.10);
		PZOW A 1 { user_hide = user_hide + 1; }
		Goto See;
	Missile:
		PZOW E 1 A_SetTranslucent(0.33);
		PZOW E 1 A_SetTranslucent(0.66);
		PZOW E 1 A_SetTranslucent(1.00);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW A 1 { user_hide = 0; }   // CH: A_SetUserVar("user_hide",user_hide=0)
		PZOW E 10 A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(700,"Rapids",true);
		PZOW F 4 Bright A_VileTarget("RS_SplashAbyssCguy");
		PZOW E 2 A_FaceTarget;
		PZOW F 4 Bright A_VileTarget("RS_SplashAbyssCguy");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW E 2 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		PZOW E 0 A_MonsterRefire(128,"See");
		Goto Missile+5;
	Rapids:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW F 3 Bright A_CustomMissile("RS_AbyssZShotCH3",31,2,random(-1,1));
		PZOW E 2 A_FaceTarget;
		PZOW F 3 Bright A_CustomMissile("RS_AbyssZShotCH3",31,2,random(-1,1));
		PZOW E 2 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW F 3 Bright A_CustomMissile("RS_AbyssZShotCH3",31,2,random(-1,1));
		PZOW E 2 A_FaceTarget;
		PZOW F 3 Bright A_CustomMissile("RS_AbyssZShotCH3",31,2,random(-1,1));
		PZOW E 2 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		PZOW E 0 A_MonsterRefire(128,"See");
		Goto Missile+5;
	Pain:
		PZOW G 3;
		PZOW E 1 A_SetTranslucent(1.00);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW A 1 { user_hide = 0; }   // CH: A_SetUserVar("user_hide",user_hide=0)
		PZOW G 4 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		PZOW H 5;
		PZOW I 5 A_Scream;
		PZOW J 5 A_Fall;
		PZOW KLM 5;
		PZOW N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		PZOW O 5;
		TNT1 AAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PZOW P 5 A_XScream;
		PZOW Q 5 A_Fall;
		TNT1 AAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PZOW RSTUV 5;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Pantsu",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		PZOW W -1;
		Stop;
	Raise:
		PZOW MLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY ("That is bad camo").  CH: Chaingunners.txt:601.
// ---------------------------------------------------------------------------
class RS_GrayCGuy2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 275;
		BloodColor "white";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 10;
		PainChance 135;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		SeeSound "lady/aggro";
		PainSound "lady/hurt";
		DeathSound "lady/die";
		ActiveSound "lady/active";
		Obituary "%o was sniped by gray chaingunner";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_implyingclip", 128;
		DropItem "RS_ArmorBundle", 64;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "Chaingun";
		DropItem "RS_HealthBundle", 128;
		Translation "160:167=96:108","112:114=90:92","115:117=93:95","118:127=96:111","32:47=104:111","27:31=96:98","186:186=0:0","128:143=104:111";
		Tag "That is bad camo";
	}
	States
	{
	Spawn:
		PZOW AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PZOW AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW E 15 A_FaceTarget;
		PZOW E 5 A_VileTarget("RS_CHBSTarget");
		PZOW E 20 A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(400,"M3");
		TNT1 A 0 A_JumpIfCloser(800,"M2");
		TNT1 A 0 A_JumpIfCloser(1400,"M1");
		PZOW F 5 Bright A_CustomBulletAttack(2,2,1,random(1,6),"RS_GrayCGuff");
		PZOW E 4 A_FaceTarget;
		PZOW F 4 Bright A_CustomBulletAttack(2,2,1,random(1,6),"RS_GrayCGuff");
		PZOW E 3 A_FaceTarget;
		PZOW F 3 Bright A_CustomBulletAttack(2,2,1,random(1,6),"RS_GrayCGuff");
		PZOW E 2 A_FaceTarget;
		PZOW F 2 Bright A_CustomBulletAttack(2,2,1,random(1,6),"RS_GrayCGuff");
		PZOW E 1 A_FaceTarget;
		PZOW F 1 Bright A_CustomBulletAttack(2,2,1,random(1,6),"RS_GrayCGuff");
		Goto See;
	M1:
		PZOW F 5 Bright A_CustomBulletAttack(1,1,1,random(2,9),"RS_GrayCGuff");
		PZOW E 4 A_FaceTarget;
		PZOW F 4 Bright A_CustomBulletAttack(1,1,1,random(2,9),"RS_GrayCGuff");
		PZOW E 3 A_FaceTarget;
		PZOW F 2 Bright A_CustomBulletAttack(1,1,1,random(2,9),"RS_GrayCGuff");
		PZOW E 2 A_FaceTarget;
		PZOW F 2 Bright A_CustomBulletAttack(1,1,1,random(2,9),"RS_GrayCGuff");
		PZOW E 1 A_FaceTarget;
		PZOW F 1 Bright A_CustomBulletAttack(1,1,1,random(2,9),"RS_GrayCGuff");
		Goto See;
	M2:
		PZOW F 5 Bright A_CustomBulletAttack(0,0,1,random(3,10),"RS_GrayCGuff");
		PZOW E 4 A_FaceTarget;
		PZOW F 4 Bright A_CustomBulletAttack(0,0,1,random(3,10),"RS_GrayCGuff");
		PZOW E 3 A_FaceTarget;
		PZOW F 3 Bright A_CustomBulletAttack(0,0,1,random(3,10),"RS_GrayCGuff");
		PZOW E 2 A_FaceTarget;
		PZOW F 2 Bright A_CustomBulletAttack(0,0,1,random(3,10),"RS_GrayCGuff");
		PZOW E 1 A_FaceTarget;
		PZOW F 1 Bright A_CustomBulletAttack(0,0,1,random(3,10),"RS_GrayCGuff");
		Goto See;
	M3:
		PZOW F 5 Bright A_CustomBulletAttack(0,0,1,random(4,12),"RS_GrayCGuff");
		PZOW E 4 A_FaceTarget;
		PZOW F 4 Bright A_CustomBulletAttack(0,0,1,random(4,12),"RS_GrayCGuff");
		PZOW E 3 A_FaceTarget;
		PZOW F 3 Bright A_CustomBulletAttack(0,0,1,random(4,12),"RS_GrayCGuff");
		PZOW E 2 A_FaceTarget;
		PZOW F 2 Bright A_CustomBulletAttack(0,0,1,random(4,12),"RS_GrayCGuff");
		PZOW E 1 A_FaceTarget;
		PZOW F 1 Bright A_CustomBulletAttack(0,0,1,random(4,12),"RS_GrayCGuff");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		PZOW G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW G 3 A_Pain;
		PZOW G 1;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		PZOW H 5;
		PZOW I 5 A_Scream;
		PZOW J 5 A_Fall;
		PZOW KLM 5;
		PZOW N -1;
		Stop;
	XDeath:
		PZOW O 5;
		PZOW P 5 A_XScream;
		PZOW Q 5 A_Fall;
		PZOW RSTUV 5;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Pantsu",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		PZOW W -1;
		Stop;
	Raise:
		PZOW MLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU ("Bad makeup day").  CH: Chaingunners.txt:827.
// ---------------------------------------------------------------------------
class RS_FireBluCGuy2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 450;
		Species "Cguy3";
		BloodColor "Blue";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 18;
		PainChance 135;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "lady/aggro";
		PainSound "lady/hurt";
		DeathSound "lady/die";
		ActiveSound "lady/active";
		Obituary "%o got fireblu'd by fireblu chaingunner";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_PlasmaRifle", 64;
		DropItem "Chaingun";
		DropItem "RS_ArmorBundle", 64;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "RS_HealthBundle", 128;
		Translation "160:162=196:198","163:166=177:183","167:167=205:205","112:114=197:200","115:117=176:179","118:121=200:203","122:125=182:186","126:127=205:207","96:101=200:205","104:111=185:191","99:107=198:204","48:63=175:183","64:79=200:207","19:31=199:207","5:15=201:207","144:159=176:191","128:143=197:207";
		Tag "Bad makeup day";
	}
	States
	{
	Spawn:
		PZOW AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PZOW AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW A 0 A_Jump(88,"Dodge");
		Loop;
	Dodge:
		PZOW AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW A 0 A_Jump(88,"See");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW E 10 A_FaceTarget;
		PZOW F 4 A_CustomMissile("RS_FireBCGguy",31,4,random(-1,1));
		PZOW F 1 A_CustomMissile("RS_FireBCGguy",31,4,random(-15,15));
		PZOW F 1 A_CustomMissile("RS_FireBCGguy",31,4,random(-35,35));
		PZOW E 2 A_FaceTarget;
		PZOW F 4 A_CustomMissile("RS_FireBCGguy",31,4,random(-1,1));
		PZOW E 2 A_FaceTarget;
		PZOW F 3 A_CustomMissile("RS_FireBCGguy",31,4,random(-3,3));
		PZOW F 1 A_CustomMissile("RS_FireBCGguy",31,4,random(-15,15));
		PZOW F 1 A_CustomMissile("RS_FireBCGguy",31,4,random(-35,35));
		PZOW E 2 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW F 3 A_CustomMissile("RS_FireBCGguy",31,4,random(-2,2));
		PZOW E 2 A_FaceTarget;
		PZOW F 2 A_CustomMissile("RS_FireBCGguy",31,4,random(-1,1));
		PZOW F 1 A_CustomMissile("RS_FireBCGguy",31,4,random(-15,15));
		PZOW F 1 A_CustomMissile("RS_FireBCGguy",31,4,random(-35,35));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		PZOW G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW G 3 A_Pain;
		PZOW G 1 A_Jump(128,"Dodge");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		PZOW H 5;
		PZOW I 5 A_Scream;
		PZOW J 5 A_Fall;
		PZOW KLM 5;
		PZOW N -1;
		Stop;
	XDeath:
		PZOW O 5;
		PZOW P 5 A_XScream;
		PZOW Q 5 A_Fall;
		PZOW RSTUV 5;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Pantsu",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		PZOW W -1;
		Stop;
	Raise:
		PZOW MLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON.  CH: Chaingunners.txt:995.
// ---------------------------------------------------------------------------
class RS_CommonCGuy : ChaingunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "CGuy";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+AVOIDMELEE
		+DONTHARMSPECIES
		Tag "Former Captain";
	}
	States
	{
	Spawn:
		CPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		CPOS E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS FE 4 Bright A_CPosAttack;
		CPOS F 1 A_CPosRefire;
		Goto Missile+1;
	Pain:
		CPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CPOS H 5;
		CPOS I 5 A_Scream;
		CPOS J 5 A_NoBlocking;
		CPOS KLM 5;
		CPOS N -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CPOS O 5 A_XScream;
		CPOS P 5 A_NoBlocking;
		CPOS QRS 5;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CPOS T -1;
		Stop;
	Raise:
		CPOS N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		CPOS MLKJIH 5;
		Goto See;
	Grow:
		CPOS MLKJIH 5;
		CPOS A 0 A_SpawnItemEx("RS_GreenCGuy",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN.  CH: Chaingunners.txt:1077.
// ---------------------------------------------------------------------------
class RS_GreenCGuy : ChaingunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 85;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 150;
		BloodColor "Green";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+AVOIDMELEE
		+DONTHARMSPECIES
		SeeSound "chainguy/sight";
		PainSound "chainguy/pain";
		DeathSound "chainguy/death";
		ActiveSound "chainguy/active";
		AttackSound "chainguy/attack";
		Obituary "%o was greenified";
		DropItem "Chaingun";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip", 128;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		Translation "32:47=116:127","31:31=115:115";
		Tag "Green Chaingunner";
	}
	States
	{
	Spawn:
		CPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		CPOS E 12 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS FE 4 Bright A_CustomBulletAttack(random(6,17),random(3,13),random(1,2),random(1,8),"RS_Trail11");
		CPOS F 3 A_MonsterRefire(150,"See");
		Goto Missile+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CPOS H 5;
		CPOS I 5 A_Scream;
		CPOS J 5 A_NoBlocking;
		CPOS KLM 5;
		CPOS N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CGUG O 5;
		CGUG P 5 A_XScream;
		CGUG Q 5 A_NoBlocking;
		CGUG RS 5;
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CGUG T -1;
		Stop;
	Raise:
		CPOS N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		CPOS MLKJIH 5;
		Goto See;
	Grow:
		CPOS MLKJIH 5;
		CPOS A 0 A_SpawnItemEx("RS_BlueCGuy",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE.  CH: Chaingunners.txt:1178.  Railgunner with prox burst.
// ---------------------------------------------------------------------------
class RS_BlueCGuy : ChaingunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 105;
		Species "Cguy";
		BloodColor "blue";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+AVOIDMELEE
		+DONTHARMSPECIES
		SeeSound "cguy2/see";
		PainSound "form2/hurt";
		DeathSound "cguy2/die";
		ActiveSound "form2/active";
		AttackSound "chainguy/attack";
		Obituary "%o was left as blue corpse";
		DropItem "Chaingun";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_ClipBox", 32;
		DropItem "RS_HealthBundle";
		DropItem "ArmorBonus", 128;
		Translation "32:47=197:207","31:31=197:197";
		Tag "Blue Chaingunner";
	}
	States
	{
	Spawn:
		CPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		CPOS E 12 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS E 0 A_JumpIfCloser(600,"Closer",false);
		CPOS E 0 A_JumpIfCloser(1200,"M1",false);
		CPOS E 3 Bright;
		CPOS F 6 Bright A_CustomRailgun(random(1,2),0,"none","Blue",RGF_NOPIERCING);
		CPOS E 0 A_CustomBulletAttack(0,0,1,random(1,4),"RS_BlueChainPuff2");
		CPOS E 5 Bright;
		CPOS F 1 A_MonsterRefire(150,"See");
		Goto Missile+1;
	M1:
		CPOS E 3 Bright;
		CPOS F 6 Bright A_CustomRailgun(random(1,3),0,"none","Blue",RGF_NOPIERCING);
		CPOS E 0 A_CustomBulletAttack(0,0,1,random(2,8),"RS_BlueChainPuff2");
		CPOS E 5 Bright;
		CPOS F 1 A_MonsterRefire(150,"See");
		Goto Missile+1;
	Closer:
		CPOS E 5 Bright;
		CPOS F 7 Bright A_CustomMissile("RS_BlueChainPuff3",28,15,0,0,0);
		CPOS E 0 A_CustomBulletAttack(15,15,6,random(2,8),"RS_BlueChainPuff2",8000);
		CPOS E 5 Bright;
		CPOS F 1 A_MonsterRefire(150,"See");
		Goto Missile+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CPOS H 5;
		CPOS I 5 A_Scream;
		CPOS J 5 A_NoBlocking;
		CPOS KLM 5;
		CPOS N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CGUB O 5;
		CGUB P 5 A_XScream;
		CGUB Q 5 A_NoBlocking;
		CGUB RS 5;
		TNT1 AAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CGUB T -1;
		Stop;
	Raise:
		CPOS N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		CPOS MLKJIH 5;
		Goto See;
	Grow:
		CPOS MLKJIH 5;
		CPOS A 0 A_SpawnItemEx("RS_PurpleCGuy",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE.  CH: Chaingunners.txt:1348.  Seeker boomer volleys.
// ---------------------------------------------------------------------------
class RS_PurpleCGuy : ChaingunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 120;
		Species "Cguy2";
		BloodColor "purple";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+AVOIDMELEE
		+DONTHARMSPECIES
		SeeSound "cguy2/see";
		PainSound "form2/hurt";
		DeathSound "cguy2/die";
		ActiveSound "form2/active";
		AttackSound "";
		Obituary "%o , purple and black was the pile left of them";
		DropItem "Chaingun";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_implyingclip";
		DropItem "RS_CH_ClipBox", 64;
		DropItem "HealthBonus", 128;
		DropItem "RS_HealthBundle";
		DropItem "ArmorBonus", 128;
		DropItem "RS_CH_GreenArmor", 24;
		Translation "48:63=[233,163,248]:[180,24,156]","169:191=0:0","64:79=[226,69,239]:[41,12,13]","128:143=[238,133,250]:[117,23,56]","144:151=[175,16,216]:[125,26,28]","152:159=[176,27,214]:[100,19,21]","160:167=0:2","215:223=106:111","117:125=0:2","21:21=27:31","32:47=240:247","31:31=203:203","9:12=[194,53,230]:[68,13,14]";
		Tag "Purple Chaingunner";
	}
	States
	{
	Spawn:
		CPOS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CPOS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		CPOS E 12 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(650,"M1");
		TNT1 A 0 A_JumpIfCloser(1300,"M2");
		CPOS FE 5 Bright A_CustomMissile("RS_Boomer3",32,-2,random(-1,1));
		CPOS FE 5 Bright A_CustomMissile("RS_Boomer3",32,-2,random(-1,1));
		CPOS F 1 A_MonsterRefire(150,"See");
		Goto Missile+1;
	M2:
		CPOS FE 4 Bright A_CustomMissile("RS_Boomer2",32,-2,random(-1,1));
		CPOS FE 5 Bright A_CustomMissile("RS_Boomer2",32,-2,random(-1,1));
		CPOS F 1 A_MonsterRefire(150,"See");
		Goto Missile+1;
	M1:
		CPOS FE 4 Bright A_CustomMissile("RS_Boomer1",32,-2,random(-1,1));
		CPOS FE 4 Bright A_CustomMissile("RS_Boomer1",32,-2,random(-1,1));
		CPOS F 1 A_MonsterRefire(150,"See");
		Goto Missile+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CPOS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPOS G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CPOS H 5;
		CPOS I 5 A_Scream;
		CPOS J 5 A_NoBlocking;
		CPOS KLM 5;
		CPOS N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CGUP O 5;
		CGUP P 5 A_XScream;
		CGUP Q 5 A_NoBlocking;
		CGUP RS 5;
		TNT1 AAA 0 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CGUP T -1;
		Stop;
	Raise:
		CPOS NMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW ("Orange Former Captain").  CH: Chaingunners.txt:1511.
// ---------------------------------------------------------------------------
class RS_YellowCGuy : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 200;
		Species "Cguy3";
		BloodColor "Yellow";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 10;
		PainChance 135;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		SeeSound "lady/aggro";
		PainSound "lady/hurt";
		DeathSound "lady/die";
		ActiveSound "lady/active";
		Obituary "%o got plasma fried by Orange Former Captain";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_PlasmaRifle", 64;
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_HealthBundle";
		DropItem "Chaingun";
		DropItem "RS_HealthBundle", 128;
		// CH: DropItem "RLOverchargeSystemArmorPickup",32 -- DRLA stripped per owner 2026-08-05
		Translation "112:124=210:223","125:127=189:191","32:47=178:187","168:191=114:127";
		Tag "Orange Former Captain";
	}
	States
	{
	Spawn:
		PZOW AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PZOW AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW A 0 A_Jump(88,"Dodge");
		Loop;
	Dodge:
		PZOW AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW A 0 A_Jump(94,"See");
		Loop;
	Missile:
		PZOW E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(300,"Spam2");
		TNT1 A 0 A_JumpIfCloser(750,"Spam");
		TNT1 A 0 A_JumpIfCloser(1250,"M1");
		TNT1 A 0 A_JumpIfCloser(1900,"M2");
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 5 Bright A_CustomRailgun(random(1,2),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,1,0,"RS_CGRailBuff",2,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 4 A_FaceTarget;
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 5 Bright A_CustomRailgun(random(1,2),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,1,0,"RS_CGRailBuff",3,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 4 A_FaceTarget;
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 5 Bright A_CustomRailgun(random(1,2),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,1,0,"RS_CGRailBuff",3,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 2;
		Goto See;
	M2:
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 4 Bright A_CustomRailgun(random(1,3),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,1,0,"RS_CGRailBuff",1,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 3 A_FaceTarget;
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 4 Bright A_CustomRailgun(random(1,3),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,1,0,"RS_CGRailBuff",2,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 3 A_FaceTarget;
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 4 Bright A_CustomRailgun(random(1,3),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,1,0,"RS_CGRailBuff",2,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 2;
		Goto See;
	M1:
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 4 Bright A_CustomRailgun(random(1,4),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,0,0,"RS_CGRailBuff",0,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 2 A_FaceTarget;
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 4 Bright A_CustomRailgun(random(1,4),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,0,0,"RS_CGRailBuff",0,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 2 A_FaceTarget;
		PZOW F 5 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		PZOW F 4 Bright A_CustomRailgun(random(1,4),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,0,0,"RS_CGRailBuff",0,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		PZOW E 2;
		Goto See;
	Spam:
		PZOW F 4 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-1,1));
		PZOW E 2 A_FaceTarget;
		PZOW F 4 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-1,1));
		PZOW E 2 A_FaceTarget;
		PZOW F 3 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-3,3));
		PZOW E 2 A_FaceTarget;
		PZOW F 3 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-2,2));
		PZOW E 2 A_FaceTarget;
		PZOW F 2 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-1,1));
		PZOW FF 1 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-1,1));
		PZOW FF 1 A_CustomMissile("RS_PlasmaBallSP3",31,4,random(-1,1));
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_Jump(82,"Spam2");
		Goto See;
	Spam2:
		PZOW E 5 A_FaceTarget;
		PZOW F 1 A_CustomMissile("RS_PlasmaBallSP3",31,4,3);
		PZOW F 2 A_CustomMissile("RS_PlasmaBallSP3",31,4,-3);
		PZOW F 2 A_CustomMissile("RS_PlasmaBallSP3",31,4,-6);
		PZOW F 3 A_CustomMissile("RS_PlasmaBallSP3",31,4,-3);
		PZOW F 3 A_CustomMissile("RS_PlasmaBallSP3",31,4,0);
		PZOW F 2 A_CustomMissile("RS_PlasmaBallSP3",31,4,3);
		PZOW F 2 A_CustomMissile("RS_PlasmaBallSP3",31,4,6);
		PZOW F 1 A_CustomMissile("RS_PlasmaBallSP3",31,4,0);
		Goto Dodge;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		PZOW G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PZOW G 3 A_Pain;
		PZOW G 1 A_Jump(128,"Dodge");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		PZOW H 5;
		PZOW I 5 A_Scream;
		PZOW J 5 A_Fall;
		PZOW KLM 5;
		PZOW N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		PZOW O 5;
		TNT1 AAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PZOW P 5 A_XScream;
		PZOW Q 5 A_Fall;
		TNT1 AAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PZOW RSTUV 5;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Pantsu",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		PZOW W -1;
		Stop;
	Raise:
		PZOW MLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED.  CH: Chaingunners.txt:1707.  Detonating bullets by range.
// ---------------------------------------------------------------------------
class RS_RedCGuy : ChaingunGuy
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 300;
		PainChance 88;
		DropItem "RS_CH_ClipBox", 232;
		DropItem "RS_CH_PlasmaRifle", 64;
		DropItem "RS_ArmorBundle", 88;
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_Berserk", 64;
		DropItem "Chaingun";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo", 128;
		Mass 1000;
		Speed 10;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+AVOIDMELEE
		+DONTHARMSPECIES
		+MISSILEMORE
		+NOFEAR
		SeeSound "cguy2/see";
		PainSound "form2/hurt";
		DeathSound "cguy2/die";
		ActiveSound "form2/active";
		AttackSound "chainguy/attack";
		Obituary "%o got rip'd up by the angry Red Chaingunner";
		Decal "Bulletchip";
		Tag "Red Chaingunner";
	}
	States
	{
	Spawn:
		CPS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CPS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Dodge1:
		CPS2 A 5 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		Goto See;
	Dodge2:
		CPS2 A 5 ThrustThing(int(angle*256/360+192),20,0,0);   // CH: ThrustThing(angle*256/360+192,20,0,0)
		Goto See;
	Missile:
		CPS2 E 11 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(500,"M1");
		TNT1 A 0 A_JumpIfCloser(1300,"M2");
		CPS2 FE 4 A_CustomBulletAttack(random(3,14),0,random(1,2),random(1,2),"RS_DetoPuff3");
		CPS2 F 1 A_MonsterRefire(64,"See");
		Goto Missile+1;
	M2:
		CPS2 FE 4 A_CustomBulletAttack(random(2,11),0,random(1,2),random(1,2),"RS_DetoPuff2");
		CPS2 F 1 A_MonsterRefire(64,"See");
		Goto Missile+1;
	M1:
		CPS2 FE 4 A_CustomBulletAttack(random(1,8),0,random(1,3),random(2,4),"RS_DetoPuffCG");
		CPS2 F 1 A_MonsterRefire(64,"See");
		Goto Missile+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCGuy2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CPS2 G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CPS2 G 3 A_Pain;
		CPS2 G 1 A_Jump(128,"Dodge1","Dodge2");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CPS2 H 5;
		CPS2 I 5 A_Scream;
		CPS2 J 5 A_Fall;
		CPS2 KLMNO 5;
		CPS2 P -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CPS2 Q 5;
		CPS2 R 5 A_XScream;
		CPS2 S 5 A_Fall;
		CPS2 TUVW 5;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CPS2 X -1;
		Stop;
	Raise:
		CPS2 PONMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK.  CH: Chaingunners.txt:1909 (EX "WARFACE") / 2280
// ("The General").  Announcers dropped per owner.
// ---------------------------------------------------------------------------
class RS_BlackCGuyEX : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was made to peel potatoes for eternity by Black ChainGunner EX";
		Health 8999;
		Radius 20;
		Height 56;
		Mass 1000;
		Speed 20;
		PainChance 12;
		SeeSound "genEx/see";
		PainSound "genEx/pain";
		DeathSound "GRALDEAD";
		ActiveSound "chainguy/active";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "Chaingun";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: DropItem "RareArmorPool",64 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLRoystensCommandArmorPickup",42 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLBFG10KPickup",32 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",24 -- DRLA stripped per owner 2026-08-05
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+BOSS
		+MISSILEMORE
		+DONTHARMCLASS
		+DONTMORPH
		-NORADIUSDMG
		+FLOORCLIP
		+NOFEAR
		Tag "LET ME SEE YOUR WARFACE";
		Translation "192:247=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","32:47=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","168:191=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","16:31=%[0.00,0.00,0.00]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		BFGZ A 0;
		Goto Scripted;
	Scripted:
		BFGZ A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackCguy") -- announcers dropped per owner
		BFGZ A 0 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		HCPO AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HCPO AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HCPO CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See2:
		HCPO AABB 3 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HCPO CCDD 3 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(5000,"Phase2");
		TNT1 A 0 A_Jump(255,"RedSpam","YellowBomb","BigBomb","RapidFire");
	YellowBomb:
		TNT1 A 0 A_JumpIfCloser(1200,"YE");
		Goto Missile;
	Phase2:
		TNT1 A 0 { bMISSILEEVENMORE = true; }
		TNT1 A 0 { bALWAYSFAST = true; }
		Goto Missile+2;
	YE:
		HCPO E 1 A_FaceTarget;
		TNT1 AA 0 A_CustomMissile("RS_SparkPuff1",40,0,CMF_AIMOFFSET,random(0,360),random(0,360));   // CH arg order kept verbatim
		HCPO E 3 Bright A_FaceTarget;
		HCPO EEEEEEE 1 Bright A_CustomMissile("RS_SparkPuff1",40,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HCPO E 2 Bright A_FaceTarget;
		HCPO F 0 A_Quake(2,12,0,128,"none");
		TNT1 A 0 { bNOPAIN = false; }
		HCPO F 3 Bright A_CustomMissile("RS_YellowBombCGUYEX",40,0,0);
		HCPO E 9 Bright;
		Goto See;
	BigBomb:
		HCPO E 1 A_FaceTarget;
		HCPO F 0 A_CustomMissile("RS_RedRevLoad",40,0,0);
		HCPO E 20 Fast A_FaceTarget;
		HCPO F 0 A_CustomMissile("RS_SpiralLoadGeneEX",40,0,0);
		HCPO E 20 Fast A_FaceTarget;
		HCPO F 0 A_Quake(2,12,0,128,"none");
		TNT1 A 0 { bNOPAIN = false; }
		HCPO F 3 Bright A_CustomMissile("RS_CGBigEx",40,0,0);
		HCPO E 9 Bright;
		Goto See;
	RapidFire:
		HCPO E 20 Fast A_FaceTarget;
		TNT1 A 0 A_PlaySound("prox/beep");
		HCPO E 4 A_FaceTarget;
		HCPO F 0 A_Quake(2,12,0,128,"none");
		TNT1 A 0 { bNOPAIN = false; }
		HCPO FE 4 Bright A_CustomBulletAttack(6,5,random(1,3),random(1,4),"RS_DetoPuffCG");
		HCPO E 2 A_MonsterRefire(188,"See");
		Goto RapidFire+1;
	RedSpam:
		HCPO E 1 A_FaceTarget;
		HCPO F 0 A_CustomMissile("RS_SpiralLoadGeneEX",40,0,0);
		HCPO E 15 Fast A_FaceTarget;
		HCPO F 0 A_CustomMissile("RS_SpiralLoadGeneEX",40,0,0);
		HCPO E 15 Fast A_FaceTarget;
		HCPO F 0 A_Quake(2,12,0,128,"none");
		TNT1 A 0 { bNOPAIN = false; }
		HCPO FEFE 3 Bright A_CustomMissile("RS_SpamShotsCguyEX",40,0,random(-5,5),0,random(-4,4));
		HCPO E 1 A_FaceTarget;
		HCPO FEFE 3 Bright A_CustomMissile("RS_SpamShotsCguyEX2",40,0,random(-9,9),0,random(-4,4));
		HCPO E 1 A_FaceTarget;
		HCPO FE 3 Bright A_CustomMissile("RS_SpamShotsCguyEX",40,0,random(-11,11),0,random(-4,4));
		HCPO E 1 A_FaceTarget;
		HCPO FE 3 Bright A_CustomMissile("RS_SpamShotsCguyEX2",40,0,random(-13,13),0,random(-4,4));
		Goto See;
	Pain:
		HCPO G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HCPO G 3 A_Pain;
		TNT1 A 0 { bNOPAIN = true; }
		HCPO G 3 A_Jump(128,"See2");
		Goto See;
	Death:
		HCPO HHHHHHH 5 A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		HCPO I 5 A_Scream;
		HCPO J 5 A_NoBlocking;
		HCPO KL 5;
		HCPO L -1;
		Stop;
	}
}

class RS_BlackCGuy2 : Actor   // CH Chaingunners.txt:2280 -- The General
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was vapourized by The General";
		Health 4500;
		Radius 20;
		Height 56;
		Mass 1000;
		Speed 10;
		PainChance 25;
		SeeSound "gen/see";
		PainSound "gen/hurt";
		DeathSound "gen/huh";
		ActiveSound "chainguy/active";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "Chaingun";
		// CH: DropItem "RareArmorPool",64 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLRoystensCommandArmorPickup",42 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLBFG10KPickup",32 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+BOSS
		+MISSILEMORE
		+DONTHARMCLASS
		+DONTMORPH
		-NORADIUSDMG
		+FLOORCLIP
		+NOFEAR
		Tag "ITS MR GENERAL TO YOU,MAGGOT";
	}
	States
	{
	Spawn:
		BFGZ A 0;
		Goto Scripted;
	Scripted:
		BFGZ A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackCguy") -- announcers dropped per owner
		Goto Idle;
	Idle:
		BFGZ AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BFGZ AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BFGZ CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BFGZ E 0 A_Jump(256,"SpamShots","ShieldBlast","BigOne");
	SpamShots:
		BFGZ E 14 A_FaceTarget;
		BFGZ FEF 5 Bright A_CustomMissile("RS_SpamShotsCguy",26,8,random(-7,7));
		BFGZ E 0 A_CheckSight("See");
		BFGZ FEF 5 Bright A_CustomMissile("RS_SpamShotsCguy",26,8,random(-15,15));
		BFGZ E 0 A_CheckSight("See");
		BFGZ FEF 5 Bright A_CustomMissile("RS_SpamShotsCguy",26,8,random(-20,20));
		BFGZ E 8 A_CheckSight("See");
		BFGZ E 0 A_Jump(128,"SpamShots");
		Goto See;
	Shield:
		BFGZ E 8 A_FaceTarget;
		BFGZ E 0 { bNOPAIN = true; }
		BFGZ E 0 A_SetReflectiveInvulnerable;
		BFGZ E 2 A_CustomMissile("RS_GenShield",20,0,random(-7,7));
		BFGZ E 46;
		BFGZ E 1 A_FaceTarget;
		BFGZ FEFEFE 3 Bright A_CustomMissile("RS_TrailSPCguy",32,0,random(-7,7));
		BFGZ E 1 A_UnSetReflectiveInvulnerable;
		BFGZ A 1 A_Jump(64,"SpamShots","BigOne");
		Goto See;
	ShieldBlast:
		BFGZ E 6;
		Goto Shield+6;
	BigOne:
		BFGZ E 20 A_FaceTarget;
		BFGZ E 15 Bright A_FaceTarget;
		BFGZ F 5 Bright A_CustomMissile("RS_RedRevLoad",32,8,0);
		BFGZ E 8 Bright A_FaceTarget;
		BFGZ F 5 Bright A_CustomMissile("RS_RedRevLoad",32,8,0);
		BFGZ E 8 Bright A_FaceTarget;
		BFGZ F 8 Bright A_CustomMissile("RS_CGBigOne",32,8,0);
		BFGZ E 2;
		Goto See;
	Pain:
		BFGZ G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BFGZ G 3 A_Pain;
		BFGZ G 3 A_Jump(128,"Shield");
		Goto See;
	Death:
		BFGZ HHH 8 A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BFGZ I 5 A_Scream;
		BFGZ J 5 A_NoBlocking;
		BFGZ KLM 5;
		BFGZ N -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE ("The crazy lady scientist").  CH: Chaingunners.txt:2520.
// ---------------------------------------------------------------------------
class RS_WhiteCguy2 : Actor
{
	int User_Ph2;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "%o fell to the power of science";
		Health 7777;
		Species "Science";
		RadiusDamageFactor 0.5;
		DamageFactor "Melee", 3.75;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 90;
		Speed 14;
		Radius 19;
		Height 52;
		PainChance 20;
		SeeSound "science/devi";
		PainSound "science/pain";
		DeathSound "science/die";
		ActiveSound "lady/active";
		Monster;
		+FLOORCLIP
		+THRUSPECIES
		+DONTHARMSPECIES
		+BOSS
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		+NOFEAR
		DropItem "RS_CH_SoulSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack", 174;
		DropItem "RS_CH_CellPack", 174;
		DropItem "RS_CH_CellPack", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_BFG9000", 64;
		DropItem "RS_CH_Chainsaw", 128;
		DropItem "RS_CH_BlueArmor", 128;
		// CH: DropItem "RLPrototypeAssaultShieldArmorPickup",32 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLMedicalPowerArmorPickup",32 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLLegendaryWeaponSpawner",4 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		DropItem "LewdLabCoat";   // defined nowhere in CH -- silent no-op there too, kept verbatim
		DropItem "Chaingun";
		Tag "The crazy lady scientist";
	}
	States
	{
	Spawn:
		FSZS A 0;
		Goto Scripted;
	Scripted:
		FSZS A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteCG") -- announcers dropped per owner
		Goto Idle;
	Idle:
		FSZS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FSZS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FSZS A 0 A_Jump(64,"See2");
		FSZS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FSZS A 0 A_Jump(64,"See2");
		Loop;
	See2:
		FSZS AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FSZS A 0 A_Jump(64,"See");
		FSZS CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FSZS A 0 A_Jump(64,"See");
		Loop;
	Missile:
		FSZS E 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FSZS E 0 A_JumpIfHealthLower(5555,"Phase2");
		FSZS E 0 A_Jump(256,"Puddle","Summon1","Darts","Summon2");
		Goto See;
	Puddle:
		FSZS E 8 A_FaceTarget;
		FSZS F 9 Bright;
		FSZS FF 0 A_CustomMissile("RS_Puddle1",40,0,random(-60,60),2,random(10,30));
		Goto See;
	Puddle2:
		FSZS E 8 A_FaceTarget;
		FSZS F 9 Bright;
		FSZS FFFF 0 A_CustomMissile("RS_Puddle1",56,0,random(-80,80),2,random(12,35));
		Goto See;
	Darts:
		FSZS E 1 A_FaceTarget;
		FSZS F 6 Bright;
		FSZS F 1 Bright A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-5,5));
		FSZS E 1 A_FaceTarget;
		FSZS E 0 A_CheckSight("See");
		FSZS F 1 Bright A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-15,15));
		FSZS E 1 A_FaceTarget;
		FSZS E 0 A_CheckSight("See");
		FSZS F 1 Bright A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-25,25));
		FSZS E 2 A_MonsterRefire(128,"See");
		Goto Darts;
	DartStorm:
		FSZS E 1 A_FaceTarget;
		FSZS F 6 Bright;
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-15,15));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-35,35));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-25,25));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-35,35));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-15,15));
		FSZS F 1 Bright A_CustomMissile("RS_NeedlesCg2",random(32,42),7,random(-5,5));
		FSZS E 6 A_FaceTarget;
		FSZS E 0 A_CheckSight("See");
		FSZS F 8 Bright A_CustomMissile("RS_NeedlesCg2",random(32,42),7,random(-5,5));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-15,15));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-35,35));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg1",random(32,42),7,random(-25,25));
		FSZS E 6 A_FaceTarget;
		FSZS E 0 A_CheckSight("See");
		FSZS F 8 Bright A_CustomMissile("RS_NeedlesCg2",random(32,42),7,random(-5,5));
		FSZS F 0 A_CustomMissile("RS_NeedlesCg2",random(32,42),7,random(-25,25));
		FSZS E 6 A_FaceTarget;
		FSZS E 2 A_Jump(128,"DartStorm");
		FSZS E 2 A_Jump(64,"Darts");
		Goto See;
	Summon1:
		FSZS E 3 A_FaceTarget;
		FSZS F 2 A_PlaySound("Science/Atk");
		FSZS F 2 A_PainAttack("RS_VolativeCaco");
		FSZS FA 2;
		Goto See;
	Summon2:
		FSZS E 3 A_FaceTarget;
		FSZS F 2 A_PlaySound("Science/Atk");
		FSZS FFF 3 A_SpawnItemEx("RS_SlimyWorm",random(-64,64),random(-64,64),random(5,15),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		FSZS FA 2;
		Goto See;
	Summon3:
		FSZS E 12 A_FaceTarget;
		FSZS E 12 A_PlaySound("Science/Atk");
		FSZS F 12;
		FSZS F 8 A_SpawnItemEx("RS_SpliceBaron",random(-64,64),random(-64,64),random(5,15),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		FSZS F 12;
		FSZS A 8;
		Goto See;
	Phase2:
		FSZS E 0 { bNOPAIN = true; }
		FSZS E 0 A_JumpIf(User_Ph2 >= 1,"Nah");
		FSZS E 20;
		FSZS G 8 A_PlaySound("Science/Enuff");
		FSZS G 7 A_SetSpeed(19);
		FSZS E 8 { User_Ph2 = User_Ph2 + 1; }
		FSZS F 12;
		FSZS FF 0 A_SpawnItemEx("RS_SpliceBaron",random(-64,64),random(-64,64),random(5,15),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		FSZS A 5;
		Goto See;
	Nah:
		FSZS E 0 A_Jump(256,"Summon1","Puddle2","DartStorm","Summon2","Summon3");
		Goto See;
	Pain:
		FSZS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FSZS G 3 A_Pain;
		Goto See;
	Death:
		FSZS H 11;
		FSZS I 11 A_Scream;
		FSZS J 11 A_NoBlocking;
		FSZS KLM 11;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cactus",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,128);
		FSZS N -1;
		Stop;
	}
}
