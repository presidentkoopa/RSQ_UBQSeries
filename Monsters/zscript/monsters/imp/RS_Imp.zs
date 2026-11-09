// ============================================================================
// RS_Imp.zs -- Colourful Hell Imp family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Imps.txt (3,133 lines, read
// whole). Every actor cites its CH line. Support: RS_ImpFX.zs.
// Tier ladder as before: 1 Common .. 13 Brown (CH icon index).
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Imps.txt:1 -- Colourset3 replaces DoomImp.
// ---------------------------------------------------------------------------
class RS_ImpColourset : RandomSpawner replaces DoomImp
{
	Default
	{
		DropItem "RS_CommonImp", 255, 630;
		DropItem "RS_GreenImp", 255, 360;
		DropItem "RS_BlueImp", 255, 180;
		DropItem "RS_BrownImp", 255, 65;
		DropItem "RS_CyanImp", 255, 120;
		DropItem "RS_AbyssImp", 255, 75;
		DropItem "RS_PurpleImp", 255, 115;
		DropItem "RS_FireBluImp", 255, 75;
		DropItem "RS_GrayImp", 255, 65;
		DropItem "RS_YellowImp", 255, 100;
		DropItem "RS_RedImp", 255, 55;
		DropItem "RS_BlackImp", 255, 2;
		DropItem "RS_WhiteImp", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families.
// ---------------------------------------------------------------------------
class RS_BrownImp : Actor   // CH Imps.txt:18
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
		TNT1 A 0 A_SpawnItemEx("RS_ImpColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanImp : Actor   // CH Imps.txt:275
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
		TNT1 A 0 A_SpawnItemEx("RS_ImpColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssImp : Actor   // CH Imps.txt:491
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
		TNT1 A 0 A_SpawnItemEx("RS_ImpColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluImp : Actor   // CH Imps.txt:707
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
		TNT1 A 0 A_SpawnItemEx("RS_ImpColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayImp : Actor   // CH Imps.txt:835
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
		TNT1 A 0 A_SpawnItemEx("RS_ImpColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackImp : Actor   // CH Imps.txt:1855
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackImp1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedImp",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackImp1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackImpEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackImpEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackImpEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteImp : Actor   // CH Imps.txt:2757
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackImp",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN ("medium evil imp").  CH: Imps.txt:40.  The warlord:
// parries, pulls, spikes, and war-cries the pack.
// ---------------------------------------------------------------------------
class RS_BrownImp2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 215;
		Radius 20;
		Height 56;
		Speed 9;
		PainChance 128;
		Species "Imp";
		BloodColor "red";
		Mass 130;
		DamageFactor "Melee", 0.5;
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+NOFEAR
		DropItem "RS_HealthBundle", 128;
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_implyingclip";
		DropItem "RS_CH_Berserk", 16;
		DropItem "RS_CH_Chainsaw", 32;
		SeeSound "imp/sight";
		PainSound "imp/pain";
		DeathSound "imp/death";
		ActiveSound "imp/active";
		Obituary "%o was out smarted by brown imp";
		HitObituary "%o was beaten to death by a brown imp";
		Tag "medium evil imp";
	}
	States
	{
	Spawn:
		WARI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WARI AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI A 0 A_Jump(32,"MaybeParry");
		WARI CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI A 0 A_Jump(64,"MaybeParry2");
		Loop;
	MaybeParry:
		TNT1 A 0 A_JumpIfInTargetLOS("Parry",0,JLOSF_DEADNOJUMP,1200,200);
		Goto See+5;
	MaybeParry2:
		TNT1 A 0 A_JumpIfInTargetLOS("Parry",0,JLOSF_DEADNOJUMP,1200,200);
		Goto See;
	MaybeParry3:
		TNT1 A 0 A_JumpIfInTargetLOS("Parry",0,JLOSF_DEADNOJUMP,1200,200);
		Goto Missile+4;
	Melee:
		WARI E 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SkelWhoosh;
		WARI F 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI G 5 A_CustomMeleeAttack(random(1,8)*7,"skeleton/melee","none");
		Goto See;
	Missile:
		WARI A 1 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI A 0 A_Jump(32,"MaybeParry3");
		WARI A 1 A_FaceTarget;
		TNT1 A 0 A_CheckProximity("Scatter","DoomImp",200,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
	FireSpike:
		WARI E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI L 6 Bright A_FaceTarget;
		WARI M 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI N 0 A_SpawnItemEx("RS_FatsoSpikes2",12,8,28,random(20,45),0,random(-1,2),frandom(-5,-2));
		WARI N 0 A_SpawnItemEx("RS_FatsoSpikes2",12,8,28,random(20,45),0,random(-1,2),frandom(-1,1));
		WARI N 0 A_CustomMissile("RS_FatsoSpikes2",32,12,0);
		WARI N 3 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,8,28,random(20,45),0,random(-1,2),frandom(2,5));
		WARI G 3;
		WARI A 0 A_Jump(64,"MaybeParry2");
		Goto See;
	Scatter:
		WARI P 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI OOO 6 A_PlaySound("imp/sight",0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI O 12 A_RadiusGive("RS_BrownImpCommand",200,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownImp2","Imp");
		WARI P 3;
		Goto FireSpike;
	Pain:
		WARI H 4 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI H 4 A_Jump(64,"Parry");
		Goto See;
	Parry:
		WARI II 3 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI JJ 3 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WARI K 1 A_FaceTarget;
		WARI K 3 A_SpawnItemEx("RS_BrownImpShieldMini",18,0,24,1,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		WARI K 12 A_RadiusThrust(-420,252,RTF_NOIMPACTDAMAGE|RTF_THRUSTZ|RTF_NOTMISSILE,128);
		WARI K 12;
		WARI JJII 3;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		TNT1 A 0 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_WarlordMace",0,0,32,4,0,0,-90,128);
		WARI R 8 A_SpawnItemEx("RS_WarlordShield",0,0,32,5,0,0,90,128);
		WARI S 8 A_Scream;
		WARI T 6;
		WARI U 6 A_Fall;
		WARI V -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (owner: vanilla gore ok)
		TROO N 5;
		TROO O 5 A_XScream;
		TNT1 AAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO P 5;
		TNT1 A 0 A_SpawnItemEx("RS_WarlordMace",0,0,32,4,0,0,-90,128);
		TNT1 A 0 A_SpawnItemEx("RS_WarlordShield",0,0,32,5,0,0,90,128);
		TROO Q 5 A_NoBlocking;
		TROO RST 5;
		TROO U 45;
		TNT1 AAAAAA 0 A_SpawnParticle("black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO U -1;
		Stop;
	Raise:
		WARI VU 8;
		WARI TSR 6;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN ("Cyanide Imp").  CH: Imps.txt:297.
// ---------------------------------------------------------------------------
class RS_CyanImp2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 125;
		Species "Imp";
		Radius 20;
		Height 56;
		Mass 500;
		Speed 14;
		DamageFactor "Melee", 1.5;
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "Fire", 1.5;
		DamageFactor "Ice", 0.15;
		DamageFactor "DIMp", 0;
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "DIMp", 0;
		PainChance 84;
		PainThreshold 12;
		BloodColor "Blue";
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+QUICKTORETALIATE
		+NOICEDEATH
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		RenderStyle "Add";
		Alpha 0.99;
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		Obituary "%o slipped from cyan imps bolts";
		HitObituary "%o was made blue rare by cyan imp";
		DropItem "RS_HealthBundle", 128;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "Chainsaw", 16;
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
		Tag "Cyanide Imp";
	}
	States
	{
	Spawn:
		CIMP AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetScale(1.0,1.0);
		CIMP AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CIMP CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(232,"SeeMe");
		Loop;
	SeeMe:
		CIMP E 0 A_JumpIfInTargetLOS("Jumpy",0,JLOSF_DEADNOJUMP,650);
		Goto See;
	Jumpy:
		CIMP AA 2 A_FastChase;
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CIMP A 1 ThrustThingZ(0,42,0,0);
		CIMP B 1 ThrustThing(int(angle-randompick(160,180,200)),12,0,0);   // CH: thrustthing(angle-randompick(160,180,200),12,0,0)
		CIMP AB 5;
		CIMP A 1 ThrustThingZ(0,24,0,0);
		CIMP B 1 ThrustThing(int(angle),12,0,0);   // CH: thrustthing(angle,12,0,0)
		Goto See;
	IceWeave:
		TNT1 A 0 A_Jump(102,"Missile2");
		CIMP E 6 A_FaceTarget;
		CIMP F 3 A_CustomMissile("RS_FrostLong2",32,12,-10);
		CIMP F 2 A_CustomMissile("RS_FrostLong2",32,12,-8);
		CIMP F 3 A_CustomMissile("RS_FrostLong2",32,12,-6);
		CIMP F 2 A_CustomMissile("RS_FrostLong2",32,12,-4);
		CIMP F 3 A_CustomMissile("RS_FrostLong2",32,12,-2);
		CIMP G 2 A_CustomMissile("RS_FrostLong2",32,12,0);
		CIMP G 3 A_CustomMissile("RS_FrostLong2",32,12,2);
		CIMP G 2 A_CustomMissile("RS_FrostLong2",32,12,4);
		CIMP G 3 A_CustomMissile("RS_FrostLong2",32,12,6);
		CIMP G 2 A_CustomMissile("RS_FrostLong2",32,12,8);
		CIMP G 3 A_CustomMissile("RS_FrostLong2",32,12,10);
		CIMP FE 4 A_FaceTarget;
		TNT1 A 0 A_Jump(128,"OtherB");
		CIMP A 1 ThrustThingZ(0,64,0,0);
		CIMP B 1 ThrustThing(int(angle-180),12,0,0);   // CH: thrustthing(angle-180,12,0,0)
		CIMP AB 5;
		Goto See;
	Melee:
		CIMP EF 8 A_FaceTarget;
		CIMP G 6 A_CustomMeleeAttack(random(10,38),"imp/melee","","Ice");
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(600,"IceWeave");
	Missile2:
		CIMP EF 3 A_FaceTarget;
		CIMP G 3;
		CIMP G 0 A_CustomMissile("RS_CyanImpBall",32,12,0);
		CIMP E 4 A_SetScale(-1.0,1.0);
		CIMP EF 3 A_FaceTarget;
		CIMP G 2 A_Jump(128,"OtherS");
		CIMP G 0 A_CustomMissile("RS_CyanImpBall",32,12,random(1,15));
		Goto See;
	OtherS:
		CIMP G 0 A_CustomMissile("RS_CyanImpBall",32,12,random(-15,-1));
		Goto See;
	OtherB:
		CIMP E 2 A_SetScale(-1.0,1.0);
		CIMP E 4 A_FaceTarget;
		CIMP F 2 A_CustomMissile("RS_FrostLong2",32,12,10);
		CIMP F 3 A_CustomMissile("RS_FrostLong2",32,12,8);
		CIMP F 2 A_CustomMissile("RS_FrostLong2",32,12,6);
		CIMP F 3 A_CustomMissile("RS_FrostLong2",32,12,4);
		CIMP F 2 A_CustomMissile("RS_FrostLong2",32,12,2);
		CIMP G 3 A_CustomMissile("RS_FrostLong2",32,12,0);
		CIMP G 2 A_CustomMissile("RS_FrostLong2",32,12,-2);
		CIMP G 3 A_CustomMissile("RS_FrostLong2",32,12,-4);
		CIMP G 2 A_CustomMissile("RS_FrostLong2",32,12,-6);
		CIMP G 3 A_CustomMissile("RS_FrostLong2",32,12,-8);
		CIMP G 2 A_CustomMissile("RS_FrostLong2",32,12,-10);
		CIMP FE 4 A_FaceTarget;
		CIMP A 1 ThrustThingZ(0,64,0,0);
		CIMP B 1 ThrustThing(int(angle-180),12,0,0);   // CH: thrustthing(angle-180,12,0,0)
		CIMP AB 5;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		TNT1 A 0 { bNOPAIN = true; }
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CIMP H 3 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CIMP H 3 A_Jump(128,"Jumpy");
		CIMP H 2;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CIMP N 5 A_Fall;
		CIMP O 5 A_XScream;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,254);
		CIMP P 5 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS.  CH: Imps.txt:514.
// ---------------------------------------------------------------------------
class RS_AbyssImp2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 300;
		Species "Imp";
		BloodColor "Black";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 130;
		Speed 11;
		PainChance 120;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMSPECIES
		+MISSILEMORE
		+CANTSEEK
		+QUICKTORETALIATE
		SeeSound "Roach/Sight";
		PainSound "Roach/Pain";
		DeathSound "Roach/death";
		ActiveSound "Roach/active";
		HitObituary "%o was abyssal handled by the abyss imp";
		Obituary "%o drowned in abyss of abyss imp";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_Chainsaw", 16;
		DropItem "RS_CH_Berserk", 32;
		DropItem "RS_CH_BlueArmor", 4;
		MeleeRange 68;
		Tag "Abyss Imp";
	}
	States
	{
	Spawn:
		ROAC AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 { bNOPAIN = false; }
		ROAC AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		ROAC CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		Loop;
	Melee:
		ROAC EF 6;
		ROAC G 5 A_CustomMeleeAttack(random(16,42),"imp/melee");
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 { bNOPAIN = false; }
		TNT1 A 0 A_JumpIfCloser(700,"HM");
		ROAC EF 8 A_FaceTarget;
		ROAC G 6 A_CustomMissile("RS_AbyssBallCH",42,3,random(-1,1));
		ROAC EF 4 A_FaceTarget;
		ROAC GG 1 A_CustomMissile("RS_AbyssBallCH",42,3,random(-9,9));
		Goto See;
	HM:
		TNT1 A 0 A_Jump(64,"HM2");
		Goto Missile+3;
	HM2:
		ROAC EF 9 Bright;
		ROAC G 1 ThrustThingZ(0,16,0,0);
		ROAC G 1 ThrustThing(int(angle),42,0,0);   // CH: thrustthing(angle,42,0,0)
		ROAC G 7;
		ROAC F 5 A_FaceTarget;
		ROAC G 1;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(32,256),random(-252,252),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		ROAC G 2;
		ROAC F 5 A_FaceTarget;
		ROAC G 1;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,328),random(-178,178),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		ROAC G 2;
		Goto Missile;
	Pain:
		ROAC H 1 { bNOPAIN = true; }
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ROAC H 1 A_Pain;
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		ROAC H 1 A_Jump(64,"HM2");
	Agh:
		ROAC AA 3 A_FastChase;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ROAC I 8;
		ROAC J 8 A_Scream;
		ROAC K 6;
		ROAC L 6 A_NoBlocking;
		ROAC M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		TROO N 5;
		TROO O 5 A_XScream;
		TNT1 AAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO P 5;
		TROO Q 5 A_NoBlocking;
		TROO RST 5;
		TROO U 45;
		TNT1 AAAAAA 0 A_SpawnParticle("black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO U -1;
		Stop;
	Raise:
		ROAC ML 8;
		ROAC KJI 6;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU ("Now THATS ugly").  CH: Imps.txt:726.
// ---------------------------------------------------------------------------
class RS_FireBluImp2 : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 125;
		Species "Imp";
		BloodColor "Purple";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Fire", 0.5;
		Radius 20;
		Height 56;
		Mass 130;
		Speed 9;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMSPECIES
		+MISSILEMORE
		+QUICKTORETALIATE
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		Obituary "%o got fireblu imp'd";
		HitObituary "%o was imp scrapped";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_Chainsaw", 12;
		Translation "64:66=198:200","67:69=179:181","70:72=201:203","73:75=176:178","76:78=201:203","79:79=176:176","80:95=193:198","96:111=172:180","208:223=174:179","168:168=202:202";
		MeleeRange 64;
		Tag "Now THATS ugly";
	}
	States
	{
	Spawn:
		TROO AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TROO AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TROO EF 8;
		TROO G 6 A_CustomMeleeAttack(random(10,29),"imp/melee");
		Goto See;
	Missile:
		TROO EF 7 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO G 7 A_CustomMissile("RS_RedBBall",42,3,random(-5,1));
		TROO G 0 A_CheckSight("See");
		TROO EF 7 A_FaceTarget;
		TROO G 7 A_CustomMissile("RS_BluBBall",42,3,random(-1,5));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		TNT1 A 0 { bNOPAIN = true; }
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TROO H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 2 A_Pain;
		Goto See;
	Pain.fire:
		TROO H 1 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 1 Bright A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		IMPP I 8;
		IMPP J 8 A_Scream;
		IMPP K 6;
		IMPP L 6 A_NoBlocking;
		IMPP M -1;
		Stop;
	XDeath:
		ZOMG P 0 A_PlaySound("weapons/rocklx",7,1);
		MISL B 6 Bright A_Explode(random(12,44),84);
		MISL C 6 Bright A_Quake(20,12,0,64,0);
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS AAAAAAAAAA 0 A_SpawnItemEx("RS_FireSGguy2",0,0,3,random(3,9),0,1,random(-359,359));
		// CH: ZOMG U (Imps.txt:825-826) -- frame U ships nowhere: CH's zombieman set stops at ZOMGT0, and CHP keeps the same dangling reference (DECORATE\01\01_G.txt:62). Both states below are 0-tic, so the renderer never displays them and there is nothing invisible to see; the sprite name is a carrier for A_CustomMissile only. Left verbatim on purpose. Verified 2026-08-06 (owner: nothing invisible).
		ZOMG T 0 A_CustomMissile("RS_FireSGguy2",32,7);   // CH: ZOMG U -- 0-tic carrier; ZOMG ships N-T only. Held T to match the zombieman family fix so no unresolvable token remains anywhere. Fixed 2026-08-06.
		ZOMG T 0 A_CustomMissile("RS_FireSGguy2",32,-7);   // CH: ZOMG U -- 0-tic carrier; ZOMG ships N-T only. Held T to match the zombieman family fix so no unresolvable token remains anywhere. Fixed 2026-08-06.
		MISL D 6 A_NoBlocking;
		Stop;
	Raise:
		IMPP MLKJI 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY ("Stoned Imp").  CH: Imps.txt:854.  Nail rings.
// ---------------------------------------------------------------------------
class RS_GrayImp2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 265;
		Species "Imp";
		BloodColor "White";
		Radius 20;
		Height 56;
		Mass 130;
		Speed 8;
		DamageFactor "Melee", 2;
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance 100;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+NOFEAR
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		Obituary "%o got needle'd by Gray Imp";
		DropItem "RS_HealthBundle", 128;
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_implyingclip";
		DropItem "RS_CH_Berserk", 64;
		DropItem "RS_CH_Chainsaw", 64;
		Translation "32:47=96:111","184:184=96:105","184:191=100:105","176:183=90:95","172:175=87:95","160:167=112:117","59:63=119:124","64:79=117:117";
		Tag "Stoned Imp";
	}
	States
	{
	Spawn:
		GIMP AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		GIMP AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GIMP CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		GIMP EF 8 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GIMP G 6;
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,45,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,135,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,225,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,315,0);
		GIMP EF 6 A_FaceTarget;
		GIMP G 5;
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,15,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,75,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,105,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,165,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,195,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,255,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,285,0);
		GIMP D 0 A_CustomMissile("RS_CGNail",32,0,345,0);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		GIMP H 3 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GIMP H 2 A_Jump(128,"Missile");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		GIMP I 5 A_CustomMissile("RS_CGthing3",32,0);
		GIMP J 5 A_XScream;
		GIMP K 5;   // CH: GIMP P -- a typo in CH itself (Imps.txt:949); no GIMPP0 exists anywhere. CHP re-authors this death and writes "GIMP K 5" (ART SOURCE\CHP\DECORATE\03\03_GY.txt:57), and CHP wins. GIMPK0 ships here and is the mid-collapse frame between J (scream) and L (down). Fixed 2026-08-06 (owner: nothing invisible).
		GIMP L 2 A_Fall;
		TNT1 AAAAAAAAAAAAA 0 A_SpawnItemEx("RS_PuffCybieRed",0,0,2,random(3,9),0,random(1,15),random(0,359));
		TROO RSTU 5;
		TROO U -1;
		Stop;
	Raise:
		GIMP LKJI 4;   // CH: GIMP LPJI -- the same GIMP P typo, run backwards (Imps.txt:956). CHP writes "GIMP LKJI 4" (03_GY.txt:64). Fixed 2026-08-06 (owner: nothing invisible).
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON.  CH: Imps.txt:987.  Vanilla stats + CH death web.
// ---------------------------------------------------------------------------
class RS_CommonImp : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "Imp";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 12;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		Tag "Imp";
	}
	States
	{
	Spawn:
		TROO AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TROO AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO EF 8 A_FaceTarget;
		TROO G 6 A_TroopAttack;
		Goto See;
	Pain:
		TROO H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		TROO I 8;
		TROO J 8 A_Scream;
		TROO K 6;
		TROO L 6 A_NoBlocking;
		TROO M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		TROO O 5 A_XScream;
		TROO P 5;
		TROO Q 5 A_NoBlocking;
		TROO RSTU 5;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO U -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Raise:
		TROO M 1 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		TROO MLKJI 8;
		Goto See;
	Grow:
		TROO MLKJI 5;
		TROO A 0 A_SpawnItemEx("RS_GreenImp",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN.  CH: Imps.txt:1072.
// ---------------------------------------------------------------------------
class RS_GreenImp : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 70;
		Species "Imp";
		BloodColor "Green";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 180;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		SeeSound "imp/sight";
		PainSound "imp/pain";
		DeathSound "imp/death";
		ActiveSound "imp/active";
		Obituary "%o got a new splash of green on them";
		HitObituary "%o faced the green slashies";
		Translation "64:79=115:127","58:63=117:119";
		Tag "Green Imp";
	}
	States
	{
	Spawn:
		TROO AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TROO AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TROO EF 8;
		TROO G 6 A_CustomMeleeAttack(random(6,16),"imp/melee");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO EF 8 A_FaceTarget;
		TROO G 6 A_CustomMissile("RS_GreenIBall",42,3);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0;
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TROO H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 2 A_Pain;
		Goto See;
	Pain.fire:
		TROO H 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 1 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		IMPG I 8;
		IMPG J 8 A_Scream;
		IMPG K 6;
		IMPG L 6 A_NoBlocking;
		IMPG M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		IMPG N 5;
		IMPG O 5 A_XScream;
		IMPG P 5;
		IMPG Q 5 A_NoBlocking;
		IMPG RST 5;
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		IMPG U -1;
		Stop;
	Raise:
		IMPG M 1 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		IMPG MLKJI 8;
		Goto See;
	Grow:
		IMPG MLKJI 5;
		IMPG A 0 A_SpawnItemEx("RS_BlueImp",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE.  CH: Imps.txt:1207.
// ---------------------------------------------------------------------------
class RS_BlueImp : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 83;
		Species "Imp";
		BloodColor "blue";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 9;
		PainChance 170;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		DropItem "RS_HealthBundle", 48;
		DropItem "RS_CH_Cell", 18;
		Obituary "%o got blue bibididaad";
		HitObituary "%o scratch wound bleed blue? what";
		Translation "64:79=196:207","58:63=195:198","168:191=1:1","0:0=0:0";
		Tag "Blue Imp";
	}
	States
	{
	Spawn:
		TROO AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TROO AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TROO EF 8;
		TROO G 6 A_CustomMeleeAttack(random(7,19),"imp/melee");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO EF 8 A_FaceTarget;
		TROO G 6 A_CustomMissile("RS_Blufier1",42,3,random(-1,1));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		TNT1 A 0 { bNOPAIN = true; }
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TROO H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 2 A_Pain;
		Goto See;
	Pain.fire:
		TROO H 0;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		IMPB I 8;
		IMPB J 8 A_Scream;
		IMPB K 6;
		IMPB L 6 A_NoBlocking;
		IMPB M -1;
		Stop;
	XDeath:
		TNT1 AAAAA 0 A_SpawnItemEx("RS_Blutrail1",0,0,32,VelX,VelY,VelZ,random(-180,180),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("weapons/plasmax");
		IMPB N 5;
		IMPB O 5 A_XScream;
		IMPB P 5;
		// CH: TNT1 AAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		IMPB Q 5 A_NoBlocking;
		IMPB RST 5;
		TNT1 AAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		IMPB U -1;
		Stop;
	Raise:
		IMPB M 1 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		IMPB MLKJI 8;
		Goto See;
	Grow:
		IMPB MLKJI 5;
		IMPB A 0 A_SpawnItemEx("RS_PurpleImp",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE ("pImp").  CH: Imps.txt:1363.
// ---------------------------------------------------------------------------
class RS_PurpleImp : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 105;
		Species "Imp";
		BloodColor "Purple";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 130;
		Speed 10;
		PainChance 150;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMSPECIES
		+MISSILEMORE
		+QUICKTORETALIATE
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		Obituary "%o got purple imp'd";
		HitObituary "%o was imp slapped";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_Chainsaw", 12;
		Translation "64:79=250:254","59:63=251:251","172:181=225:230","80:95=160:166","96:99=164:167","4:4=224:224";
		MeleeRange 64;
		Tag "pImp";
	}
	States
	{
	Spawn:
		TROO AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TROO AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TROO EF 8;
		TROO G 6 A_CustomMeleeAttack(random(10,29),"imp/melee");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO EF 8 A_FaceTarget;
		TROO G 7 A_CustomMissile("RS_Bounc11",42,3,random(-1,1));
		TROO G 0 A_CheckSight("See");
		TROO EF 8 A_FaceTarget;
		TROO G 7 A_CustomMissile("RS_Bounc11",42,3,random(-9,9));
		Goto See;
	Missile2:
		TROO EF 6 Bright;
		TROO G 6 Bright A_FaceMovementDirection;
		TROO GG 2 Bright A_CustomMissile("RS_Bounc11",42,3,random(-13,13));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		TNT1 A 0 { bNOPAIN = true; }
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TROO H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 2 A_Pain;
		Goto See;
	Pain.fire:
		TROO H 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO H 2 Bright A_Pain;
		TROO H 0 A_Jump(64,"Missile2");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		IMPP I 8;
		IMPP J 8 A_Scream;
		IMPP K 6;
		IMPP L 6 A_NoBlocking;
		IMPP M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		IMPP N 5;
		IMPP O 5 A_XScream;
		TNT1 A 0 A_SpawnItemEx("RS_CHgold_teeth",0,0,32,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,128);
		IMPP P 5;
		IMPP Q 5 A_NoBlocking;
		IMPP RST 5;
		TNT1 AAA 0 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		IMPP U -1;
		Stop;
	Raise:
		IMPP MLKJI 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW ("Orange Imp").  CH: Imps.txt:1535.
// ---------------------------------------------------------------------------
class RS_YellowImp : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 145;
		Species "Imp";
		BloodColor "Yellow";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "PLWater", 1.5;
		DamageFactor "fire", 0.75;
		DamageFactor "ice", 0.85;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 130;
		Speed 10;
		PainChance 120;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMSPECIES
		+MISSILEMORE
		+QUICKTORETALIATE
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		HitObituary "%o got slashed up by orange imps big hands";
		Obituary "%o was burninated by orange imp";
		DropItem "RS_HealthBundle", 128;
		DropItem "HealthBonus";
		DropItem "RS_CH_RocketAmmo", 8;
		DropItem "RS_CH_Chainsaw", 16;
		Translation "64:79=212:223","80:111=171:191","4:4=169:169","168:168=172:174";
		MeleeRange 68;
		Tag "Orange Imp";
	}
	States
	{
	Spawn:
		TRO4 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TRO4 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 A 0 A_Jump(34,"Dodger");
		Loop;
	Dodger:
		TRO4 AABB 3 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 CCDD 3 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 A 0 A_Jump(64,"See");
		Loop;
	Melee:
		TRO4 EF 8;
		TRO4 G 6 A_CustomMeleeAttack(random(10,32),"imp/melee");
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 EF 8 A_FaceTarget;
		TRO4 G 6 A_CustomMissile("RS_SpitFireImp",42,3,random(-1,1));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		TNT1 A 0 { bNOPAIN = true; }
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TRO4 H 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 H 2 A_Pain;
		TRO4 H 1 A_Jump(64,"Firey");
		Goto See;
	Pain.fire:
		TRO4 H 0;
		Goto Dodger;
	Firey:
		TRO4 E 5 Bright;
		TRO4 H 6 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		Goto Dodger;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		TRO4 I 8;
		TRO4 J 8 A_Scream;
		TRO4 K 6;
		TRO4 L 6 A_NoBlocking;
		TRO4 M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		TROO N 5;
		TROO O 5 A_XScream;
		TNT1 AAAAAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO P 5;
		TROO Q 5 A_NoBlocking;
		TROO RST 5;
		TROO U 45;
		TNT1 A 0 A_CustomMissile("ArchvileFire",0,0,0,0);
		TNT1 AAAAAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TROO U -1;
		Stop;
	Raise:
		TRO4 ML 8;
		TRO4 KJI 6;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED.  CH: Imps.txt:1688.  Enrages on pain; red seeker swarms.
// ---------------------------------------------------------------------------
class RS_RedImp : DoomImp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 200;
		Species "Imp";
		Radius 20;
		Height 56;
		Mass 130;
		Speed 10;
		DamageFactor "Melee", 2;
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "ice", 1.45;
		PainChance 100;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+QUICKTORETALIATE
		+NOFEAR
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		Obituary "%o was bloodified by Red Imp";
		HitObituary "%o was made into minced meat by Red Imp";
		DropItem "RS_HealthBundle", 128;
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_Berserk", 64;
		DropItem "RS_CH_Chainsaw", 16;
		Tag "Red Imp";
	}
	States
	{
	Spawn:
		PRIM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PRIM AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PRIM CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		PRIM EF 8 A_FaceTarget;
		PRIM G 6 A_CustomMeleeAttack(random(10,38),"imp/melee");
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PRIM EF 4 A_FaceTarget;
		PRIM G 3;
		PRIM G 0 A_CustomMissile("RS_RedMessImp2",32,12,0);
		PRIM G 0 A_CustomMissile("RS_RedMessImp2",32,4,0);
		PRIM G 0 A_CustomMissile("RS_RedMessImp2",32,20,0);
		PRIM G 0 A_CustomMissile("RS_RedMessImp2",22,12,0);
		PRIM G 0 A_CustomMissile("RS_RedMessImp2",42,12,0);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 A_SetScale(0.8,0.8);
		TNT1 A 0 { bNOPAIN = true; }
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssImp2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		PRIM H 3 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PRIM H 3 { bNOPAIN = true; }
		PRIM H 3 { bMISSILEEVENMORE = true; }
		PRIM H 2 A_PlaySound("imp/pain");
		PRIM H 2 A_SetSpeed(14);
		PRIM H 2;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		PRIM N 5 A_CustomMissile("RS_HKRedDeath",32,0);
		PRIM O 5 A_XScream;
		PRIM P 5;
		PRIM Q 5 A_Fall;
		PRIM RST 5;
		PRIM U -1;
		Stop;
	XDeath:
		TNT1 AAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		PRIM N 5 A_CustomMissile("RS_HKRedDeath",32,0);
		PRIM O 5 A_XScream;
		PRIM P 5;
		TNT1 AAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PRIM Q 5 A_Fall;
		PRIM RST 5 A_CustomMissile("RS_HKRedDeath",random(12,46),random(-15,15));
		PRIM U -1;
		Stop;
	Raise:
		PRIM UTSRQPON 4;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK.  CH: Imps.txt:2085 (Smoking EX) / 2300 (Smoking Black).
// Announcers dropped per owner.
// ---------------------------------------------------------------------------
class RS_BlackImpEX : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was smoked out by the black imp EX";
		Health 8600;
		Radius 20;
		Height 56;
		Mass 5000;
		Speed 19;
		YScale 1.4;
		XScale 1.05;
		Species "Imp";
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		RadiusDamageFactor 0.33;
		DamageFactor "Melee", 1.5;
		DamageFactor "Plasma", 1.1;
		DamageFactor "Heroic", 3.0;
		DamageFactor "PlayerVoid", 0.6;
		PainChance 28;
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+BOSS
		+DONTMORPH
		-NORADIUSDMG
		+MISSILEMORE
		+MISSILEEVENMORE
		+QUICKTORETALIATE
		+NOTARGET
		+NOFEAR
		SeeSound "agaures/sight";
		PainSound "agaures/pain";
		DeathSound "agaures/death";
		ActiveSound "agaures/active";
		MeleeSound "agaures/scratch";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_SoulSphere";
		// CH: DropItem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		Tag "Smoking Black Imp EX";
	}
	States
	{
	Spawn:
		AGUR A 0;
		Goto Scripted;
	Scripted:
		AGUR A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackImp") -- announcers dropped per owner
		AGUR A 0 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		AGUR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		AGUR AA 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR YYY 0 A_SpawnItemEx("RS_DeathBreathDI",-1,random(-18,18),random(2,32),random(1,5),0,1,random(90,270));
		AGUR BB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR YYY 0 A_SpawnItemEx("RS_DeathBreathDI",-2,random(-18,18),random(2,32),random(1,5),0,2,random(90,270));
		AGUR CC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR YYY 0 A_SpawnItemEx("RS_DeathBreathDI",-3,random(-18,18),random(2,32),random(1,5),0,3,random(90,270));
		AGUR DD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR YYY 0 A_SpawnItemEx("RS_DeathBreathDI",-4,random(-18,18),random(2,32),random(1,5),0,4,random(90,270));
		Loop;
	Melee:
	Missile:
		AGUR AAA 0 A_SpawnItemEx("RS_DeathBreathDI",random(-88,88),random(-88,88),random(-6,27),random(1,9),0,1,random(-359,359));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR A 0 A_JumpIfCloser(1300,"Choice");
		AGUR A 0 A_Jump(256,"Kamehameha","SmokeOut");
		Goto See;
	Choice:
		TNT1 A 0 A_Jump(256,"Kamehameha","SmokeOut","OneShot","BigShot","SpamShotRain");
	Kamehameha:
		AGUR W 2 A_PlaySound("agaures/sight",7,2,false,ATTN_NONE);
		AGUR W 2 Bright A_FaceTarget;
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",1,32,42);
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",1,-32,42);
		AGUR W 18 Bright;
		AGUR X 8 A_FaceTarget;
		AGUR Y 9 Bright A_CustomRailgun(random(20,80),-20,"white","white",RGF_NOPIERCING,0,0,"RS_BlackImpBeam1",0,0,0,0,0.4,1.0,"RS_BlackImpBeam2",1);
		AGUR Y 16;
		AGUR YYY 0 A_SpawnItemEx("RS_DeathBreathDI",random(-118,118),random(-118,118),random(-6,32),random(1,9),0,1,random(-359,359));
		Goto See;
	SmokeOut:
		AGUR Y 2;
		AGUR Y 2 A_FaceTarget;
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",16,3,32);
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",16,-3,32);
		AGUR Y 1 A_VileTarget("RS_CHBSTarget");
		AGUR YYY 2 Bright A_SpawnItemEx("RS_DeathBreathDI",-4,random(-18,18),random(2,32),random(1,5),0,1,random(90,270));
		AGUR YYYYYYYY 1 Bright A_SpawnItemEx("RS_DeathBreathDI",-4,random(-18,18),random(2,32),random(1,5),0,1,random(90,270));
		AGUR YYYYY 0 A_SpawnItemEx("RS_DeathBreathDI",-4,random(-18,18),random(2,32),random(1,5),0,1,random(90,270));
		AGUR Y 3 Bright A_CheckSight("See");
		AGUR Y 9 Bright A_FaceTarget;
		AGUR Y 4 Bright A_VileTarget("RS_BlackImpSmokeOut");
		AGUR XW 6;
		Goto See;
	OneShot:
		AGUR EF 12 A_FaceTarget;
		AGUR GGGGGGGGGGGG 1 Bright A_CustomMissile("RS_BlackImpEXBall1",42,0,random(-30,30));
		AGUR G 0 A_FaceTarget;
		AGUR GGGGGGGGG 2 Bright A_CustomMissile("RS_BlackImpEXBall1",42,0,random(-15,15));
		AGUR G 0 A_FaceTarget;
		AGUR GGGGGG 3 Bright A_CustomMissile("RS_BlackImpEXBall1",42,0,random(-7,7));
		AGUR G 0 A_FaceTarget;
		AGUR GGG 4 Bright A_CustomMissile("RS_BlackImpEXBall1",42,0,random(-1,1));
		AGUR GF 6 A_Jump(24,"BigShot");
		Goto See;
	BigShot:
		AGUR E 12 Bright A_FaceTarget;
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",1,32,38);
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",1,-32,38);
		AGUR F 12 Bright A_FaceTarget;
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",1,32,38);
		AGUR A 0 A_SpawnItemEx("RS_BlackImpEXcharge",1,-32,38);
		AGUR F 2 Bright A_CustomMissile("RS_EffectHK",28,0);
		AGUR F 2 Bright A_CustomMissile("RS_EffectHK",32,0);
		AGUR F 2 Bright A_CustomMissile("RS_EffectHK",36,0);
		AGUR G 1 Bright A_FaceTarget;
		AGUR G 8 Bright A_CustomMissile("RS_BlackImpExBigOne",64,0,0,0,0);
		AGUR G 4;
		AGUR A 10;
		Goto See;
	SpamShotRain:
		AGUR EF 8 A_FaceTarget;
		AGUR GGGGG 1 A_CustomMissile("RS_BlackImpExBall2",random(70,90),0,random(-15,15),0,0);
		AGUR GGGGGGG 0 A_CustomMissile("RS_BlackImpExBall2",random(70,90),0,random(-15,15),0,0);
		AGUR G 1 A_FaceTarget;
		AGUR GGGG 2 A_CustomMissile("RS_BlackImpExBall2",random(70,90),0,random(-10,10),0,0);
		AGUR GGGGGGGGGGG 0 A_CustomMissile("RS_BlackImpExBall2",random(70,90),0,random(-15,15),0,0);
		AGUR G 1 A_FaceTarget;
		AGUR GGG 3 A_CustomMissile("RS_BlackImpExBall2",random(70,90),0,random(-5,5),0,0);
		AGUR GGGGGGGGGGGGGG 0 A_CustomMissile("RS_BlackImpExBall2",random(70,90),0,random(-15,15),0,0);
		AGUR GF 6 A_Jump(24,"BigShot");
		Goto See;
	Pain:
		AGUR H 2;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR YYYYYYYYY 0 A_SpawnItemEx("RS_DeathBreathDI",0,random(-18,18),random(2,32),random(3,8),0,1,random(-359,359));
		AGUR H 2 A_Pain;
		TNT1 A 0 A_Jump(64,"Warp");
		Goto See;
	Warp:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetSpeed(99);
		TNT1 AAAA 0 A_Wander;
		TNT1 AA 3 A_Wander;
		TNT1 AAAA 1 A_Wander;
		TNT1 A 0 A_SetSpeed(19);
		TNT1 A 0 { bNOPAIN = false; }
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		Goto See;
	Death:
		AGUR I 12;
		AGUR J 12 A_Scream;
		AGUR KL 12;
		AGUR M 12 A_NoBlocking;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		AGUR N -1;
		Stop;
	}
}

class RS_BlackImp1 : Actor   // CH Imps.txt:2300 -- Smoking Black Imp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o wasn't good enough at dodging black imps spam shots";
		HitObituary "%o was gut'd out by the black imp";
		Health 3800;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 12;
		Scale 1.2;
		Species "Imp";
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		RadiusDamageFactor 0.45;
		DamageFactor "Melee", 1.75;
		DamageFactor "Plasma", 1.1;
		DamageFactor "Heroic", 3.0;
		PainChance 28;
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+BOSS
		-NORADIUSDMG
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTMORPH
		+QUICKTORETALIATE
		+NOTARGET
		+NOFEAR
		SeeSound "agaures/sight";
		PainSound "agaures/pain";
		DeathSound "agaures/death";
		ActiveSound "agaures/active";
		MeleeSound "agaures/scratch";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_SuperShotgun";
		DropItem "RS_CH_ShellBox";
		// CH: DropItem "RareArmorPool",64 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		Tag "Smoking Black Imp";
	}
	States
	{
	Spawn:
		AGUR A 0;
		Goto Scripted;
	Scripted:
		AGUR A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackImp") -- announcers dropped per owner
		Goto Idle;
	Idle:
		AGUR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		AGUR AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		AGUR WX 6 A_FaceTarget;
		AGUR Y 6 A_CustomMeleeAttack(random(20,65),"agaures/swing","none");
		AGUR YYY 0 A_SpawnItemEx("RS_DeathBreathDI",random(-118,118),random(-118,118),random(-6,32),0,0,0,0,128,0);
		AGUR Y 0 A_Jump(88,"Missile");
		Goto See;
	Missile:
		AGUR AAA 0 A_SpawnItemEx("RS_DeathBreathDI",random(-88,88),random(-88,88),random(-6,27),0,0,0,0,128,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR A 0 A_SetTranslucent(1);
		AGUR A 0 A_Jump(256,"OneShot","SpamShots","BigShot");
		Goto See;
	OneShot:
		AGUR EF 12 A_FaceTarget;
		AGUR G 6 A_CustomMissile("RS_AgauresBall1",37,0,0,0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall1",37,0,random(-15,15),0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall1",37,0,random(-25,25),0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall1",37,0,random(-15,15),0,0);
		AGUR G 0 A_Jump(128,"OneShot");
		AGUR G 0 A_Jump(128,"SpamShots");
		Goto See;
	BigShot:
		AGUR EF 12 Bright A_FaceTarget;
		AGUR F 2 Bright A_CustomMissile("RS_EffectHK",28,0);
		AGUR F 2 Bright A_CustomMissile("RS_EffectHK",32,0);
		AGUR F 2 Bright A_CustomMissile("RS_EffectHK",36,0);
		AGUR G 8 Bright A_CustomMissile("RS_DIBigOne",38,0,0,0,0);
		AGUR G 4;
		AGUR A 10;
		Goto See;
	SpamShots:
		AGUR EF 8 A_FaceTarget;
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,-5,0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,0,0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,5,0,0);
		AGUR G 0 A_CheckSight("See");
		AGUR EF 5 A_FaceTarget;
		AGUR G 4 A_CustomMissile("RS_AgauresBall2",37,0,0,0,0);
		AGUR G 0 A_CheckSight("See");
		AGUR EF 4 A_FaceTarget;
		AGUR G 3 A_CustomMissile("RS_AgauresBall2",37,0,0,0,0);
		AGUR G 0 A_CheckSight("See");
		AGUR EF 2 A_FaceTarget;
		AGUR G 1 A_CustomMissile("RS_AgauresBall2",37,0,0,0,0);
		AGUR G 0 A_CheckSight("See");
		AGUR EF 6 A_FaceTarget;
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,-10,0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,0,0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,10,0,0);
		AGUR G 0 A_CheckSight("See");
		AGUR EF 5 A_FaceTarget;
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,-15,0,0);
		AGUR G 0 A_CustomMissile("RS_AgauresBall2",37,0,0,0,0);
		AGUR G 6 A_CustomMissile("RS_AgauresBall2",37,0,15,0,0);
		Goto See;
	Pain:
		AGUR H 2 A_SetTranslucent(1);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AGUR H 2 A_Pain;
		Goto See;
	Pain.DIMp:
		AGUR A 0 A_SetTranslucent(0.5);
		Goto See;
	Death:
		AGUR I 12;
		AGUR J 12 A_Scream;
		AGUR KL 12;
		AGUR M 12 A_NoBlocking;
		AGUR N -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE ("Imp Master") and the ghost imp squad.
// CH: Imps.txt:2568-2979.  Ghosts are minions: no tier tokens.
// ---------------------------------------------------------------------------
class RS_SpecialImp2 : RandomSpawner   // CH Imps.txt:2568
{
	Default
	{
		DropItem "RS_SpecialImp4", 255, 100;
		DropItem "RS_SpecialImp3", 255, 80;
		DropItem "RS_SpecialImp5", 255, 60;
		DropItem "RS_SpecialImp6", 255, 40;
		DropItem "RS_SpecialImp7", 255, 20;
	}
}

class RS_SpecialImp7 : RS_RedImp   // CH Imps.txt:2577 -- Ghost Red Imp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }
	Default
	{
		Species "Imp";
		RenderStyle "Add";
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+NOCLIP
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		Health 80;
		DropItem "RS_HealthBundle", 42;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_implyingclip", 128;
		Obituary "%o met revenge of Red Imps";
		Tag "Ghost Red Imp";
	}
	States
	{
	See:
		PRIM ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PRIM DEEFF 3 A_Chase;
		PRIM A 0 A_JumpIfMasterCloser(800,"See");
		PRIM A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

class RS_SpecialImp6 : RS_YellowImp   // CH Imps.txt:2613 -- Ghost Yellow Imp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }
	Default
	{
		Species "Imp";
		RenderStyle "Add";
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+NOCLIP
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		Health 80;
		DropItem "RS_HealthBundle", 42;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_implyingclip", 128;
		Obituary "%o met revenge of Yellow Imps";
		Tag "Ghost Yellow Imp";
	}
	States
	{
	See:
		TRO4 ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRO4 DEEFF 3 A_Chase;
		TRO4 A 0 A_JumpIfMasterCloser(800,"See");
		TRO4 A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

class RS_SpecialImp5 : RS_PurpleImp   // CH Imps.txt:2649 -- Ghost Purple Imp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }
	Default
	{
		Species "Imp";
		RenderStyle "Add";
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+NOCLIP
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		Health 80;
		DropItem "RS_HealthBundle", 42;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_implyingclip", 128;
		Obituary "%o met revenge of Purple Imps";
		Tag "Ghost Purple Imp";
	}
	States
	{
	See:
		TROO ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO DEEFF 3 A_Chase;
		TROO A 0 A_JumpIfMasterCloser(800,"See");
		TROO A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

class RS_SpecialImp4 : RS_GreenImp   // CH Imps.txt:2685 -- Ghost Green Imp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }
	Default
	{
		Species "Imp";
		RenderStyle "Add";
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+NOCLIP
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		Health 80;
		DropItem "RS_HealthBundle", 42;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_implyingclip", 128;
		Obituary "%o met revenge of Green Imps";
		Tag "Ghost Green Imp";
	}
	States
	{
	See:
		TROO ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO DEEFF 3 A_Chase;
		TROO A 0 A_JumpIfMasterCloser(800,"See");
		TROO A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

class RS_SpecialImp3 : RS_BlueImp   // CH Imps.txt:2721 -- Ghost Blue Imp
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }
	Default
	{
		Species "Imp";
		RenderStyle "Add";
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+NOCLIP
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		Health 80;
		DropItem "RS_HealthBundle", 42;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_implyingclip", 128;
		Obituary "%o met revenge of Blue Imps";
		Tag "Ghost Blue Imp";
	}
	States
	{
	See:
		TROO ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO DEEFF 3 A_Chase;
		TROO A 0 A_JumpIfMasterCloser(800,"See");
		TROO A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

class RS_WhiteImp2 : Actor   // CH Imps.txt:2776 -- Imp Master
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "Look,%o , it's the revenge of the imps!";
		Health 6666;
		Radius 20;
		Height 56;
		Mass 120;
		Speed 18;
		Species "Imp";
		PainChance 24;
		PainChance "DIMp", 0;
		PainChance "fire", 0;
		SeeSound "monster/hlnsit";
		PainSound "monster/hlnpai";
		DeathSound "monster/hlndth";
		ActiveSound "monster/hlnact";
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+BOSS
		-NORADIUSDMG
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTMORPH
		+NOTARGET
		+QUICKTORETALIATE
		Scale 1.25;
		RadiusDamageFactor 0.33;
		DamageFactor "Melee", 3.3;
		DamageFactor "Plasma", 1.1;
		DamageFactor "Heroic", 3.0;
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_Chainsaw";
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_Chainsaw";
		DropItem "RS_CH_ShellBox", 128;
		DropItem "RS_CH_CellPack", 64;
		// CH: DropItem "RLJackhammerPickup",24 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLDemonicWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLLegendaryWeaponSpawner",6 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		Translation "208:223=87:95","232:235=96:100","32:47=102:108","42:47=105:109","187:191=104:110","164:167=99:102","185:188=104:107","170:191=[144,144,144]:[55,55,55]";
		Tag "Imp Master";
	}
	States
	{
	Spawn:
		HELN A 0;
		HELN A 0 A_SpawnItemEx("RS_SpecialImp2",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 1 Bright A_SpawnItemEx("RS_SpecialImp2",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 0 A_SpawnItemEx("RS_SpecialImp2",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 1 Bright A_SpawnItemEx("RS_SpecialImp2",-5,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 0 A_SpawnItemEx("RS_SpecialImp2",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 1 Bright A_SpawnItemEx("RS_SpecialImp2",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 0 A_SpawnItemEx("RS_SpecialImp2",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN A 1 Bright A_SpawnItemEx("RS_SpecialImp2",-5,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto Scripted;
	Scripted:
		HELN A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteImp") -- announcers dropped per owner
		Goto Idle;
	Idle:
		HELN AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HELN AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELN C 0 A_Jump(42,"See2");
		HELN DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELN F 0 A_Jump(64,"See2");
		HELN F 0 A_Jump(8,"Summon");
		Loop;
	See2:
		HELN AABBCC 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELN C 0 A_Jump(84,"See");
		HELN DDEEFF 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELN F 0 A_Jump(128,"See");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELN G 0 A_Jump(255,"ColorBs","Megaball","Summon");
	ColorBs:
		HELN JIG 8 Bright A_FaceTarget;
		HELN H 7 Bright A_PlaySound("monster/hlnsit");
		HELN HJ 5 Bright A_FaceTarget;
		HELN K 1 Bright A_CustomMissile("RS_WimpBall1",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 2 Bright A_CustomMissile("RS_WimpBall2",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN K 1 Bright A_CustomMissile("RS_WimpBall3",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 2 Bright A_CustomMissile("RS_WimpBall4",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN K 1 Bright A_CustomMissile("RS_WimpBall5",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 2 Bright A_CustomMissile("RS_WimpBall1",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN K 1 Bright A_CustomMissile("RS_WimpBall2",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 1 Bright A_CustomMissile("RS_WimpBall3",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN K 2 Bright A_CustomMissile("RS_WimpBall4",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 1 Bright A_CustomMissile("RS_WimpBall5",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 2 Bright A_CustomMissile("RS_WimpBall1",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN K 2 Bright A_CustomMissile("RS_WimpBall2",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 1 Bright A_CustomMissile("RS_WimpBall3",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN K 2 Bright A_CustomMissile("RS_WimpBall4",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 1 Bright A_CustomMissile("RS_WimpBall5",random(15,40),random(-12,12),random(-12,12),0,random(-4,9));
		HELN L 9 A_Jump(84,"NopeNopeNo2");
		Goto See;
	Megaball:
		HELN G 0 A_FaceTarget;
		HELN GGG 1 Bright A_CustomMissile("RS_SparkPuff1",74,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN HHH 1 A_CustomMissile("RS_SparkPuff1",74,random(-2,2),CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN GGG 1 Bright A_CustomMissile("RS_SparkPuff1",64,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN HHH 1 A_CustomMissile("RS_SparkPuff1",74,random(-2,2),CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN GGG 1 Bright A_CustomMissile("RS_SparkPuff1",74,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN HHH 1 A_CustomMissile("RS_SparkPuff1",74,random(-2,2),CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN GGG 1 Bright A_CustomMissile("RS_SparkPuff1",74,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN HHH 1 A_CustomMissile("RS_SparkPuff1",74,random(-2,2),CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN III 2 Bright A_CustomMissile("RS_SparkPuff1",54,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN JJJ 2 Bright A_CustomMissile("RS_SparkPuff1",42,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HELN JK 5 Bright A_FaceTarget;
		HELN L 6 Bright A_CustomMissile("RS_HellionBall",38,0,5,0,2);
		HELN L 0 A_CustomMissile("RS_Hel2",40,0,2,0,5);
		HELN L 2 A_Jump(84,"NopeNopeNo2");
		Goto See;
	Summon:
		HELN H 11 Bright A_CustomMissile("RS_BaronRing",64,0);
		HELN K 9 Bright A_Pain;
		HELN H 10 Bright A_Pain;
		HELN K 8 Bright A_CustomMissile("RS_BaronRing",64,0);
		HELN J 6 Bright A_Pain;
		HELN I 5 Bright A_Pain;
		HELN GGGGG 3 Bright A_SpawnItemEx("RS_SpecialImp2",random(-88,88),random(-88,88),6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		HELN H 12 Bright A_Jump(84,"NopeNopeNo2");
		Goto See;
	NopeNopeNo:
		HELN GGGGGGGGG 1 Bright A_CustomMissile("RS_SparkPuff1",74,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN HHHHHHHHH 1 Bright A_CustomMissile("RS_Hel2",64,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		Goto See;
	NopeNopeNo2:
		HELN GGGGGGGGG 1 Bright A_CustomMissile("RS_SparkPuff1",74,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 1 Bright A_CustomMissile("RS_WimpBall1",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall2",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall3",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall4",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall5",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall1",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall2",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall3",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall4",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall5",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall1",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall2",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall3",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall4",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall5",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall1",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall2",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall3",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall4",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall5",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall1",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall2",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall3",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall4",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall5",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall1",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall2",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall3",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall4",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		HELN H 0 A_CustomMissile("RS_WimpBall5",54,0,random(0,360),CMF_AIMOFFSET,random(0,360));
		Goto See;
	Pain:
		HELN M 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELN M 2 A_Pain;
		HELN M 0 A_Jump(84,"NopeNopeNo");
		Goto See;
	Death:
		HELN N 6;
		HELN O 6 A_Scream;
		HELN PQR 6;
		HELN S 6 A_NoBlocking;
		HELN T -1;
		Stop;
	XDeath:
		HELN U 5;
		HELN V 5 A_XScream;
		HELN W 5;
		HELN X 5 A_NoBlocking;
		HELN YZ 5;
		HEL2 AB 5;
		HEL2 C -1;
		Stop;
	}
}
