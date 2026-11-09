// ============================================================================
// RS_Baron.zs -- Colourful Hell Baron of Hell family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Barons.txt (5,021 lines, read
// whole). Every actor cites its CH line. Support: RS_BaronFX.zs (see its
// header for cross-lane notes, the externals this lane defines, the
// proven-missing assets, and the standing strips).
//
// Tier ladder is CH's icon index: 1 Common, 2 Green, 3 Blue, 4 Purple
// (Royal), 5 Yellow (Grand Orange), 6 Red (all three phases), 7 FireBlu,
// 8 Gray (Statue?), 9 Abyss, 10 Black (Baron from Abyss), 11 White (Slice
// and Dicer), 12 Cyan, 13 Brown (Satyr). Minions -- RS_DeepTentacle,
// RS_RoseTentacle -- get no token.
//
// rs_ch_nerfredboss IS DECLARED -- CVARINFO.txt:1005, default 1.
// CORRECTED 2026-08-07, comment only, no code touched. This used to read
// "NEW CVAR NEEDED (not added here...)", which was true when written and
// false by the time anyone read it; the cvar landed afterwards and nobody
// came back to the comment. CH's "CH_Red" ACS gate is a
// one-line read of CH_NerfRedBoss (CHSett.acs:29-31, CH CVARINFO default
// 1): 1 = the Red Baron spawns as its boss form RedBaron3, 2 = fifty-fifty
// between RedBaron3 and RedBaron1, anything else = plain RedBaron1.
// RS_Zom.CV falls back to the stated default while the cvar is absent, so
// the family behaves exactly as CH's default until it is declared.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Barons.txt:1 -- Colourset13 replaces BaronOfHell.
// ---------------------------------------------------------------------------
class RS_Colourset13 : RandomSpawner replaces BaronOfHell
{
	Default
	{
		DropItem "RS_CommonBaron", 255, 500;
		DropItem "RS_GreenBaron", 255, 400;
		DropItem "RS_BlueBaron", 255, 220;
		DropItem "RS_BrownBaron", 255, 80;
		DropItem "RS_CyanBaron", 255, 135;
		DropItem "RS_PurpleBaron", 255, 145;
		DropItem "RS_FireBluBaron", 255, 35;
		DropItem "RS_GrayBaron", 255, 35;
		DropItem "RS_YellowBaron", 255, 50;
		DropItem "RS_AbyssBaron", 255, 40;
		DropItem "RS_RedBaron", 255, 10;
		DropItem "RS_BlackBaron", 255, 5;
		DropItem "RS_WhiteBaron", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families:
// 1 = colour off (reroll into the main set, CH's default), 3 = fifty-fifty.
// ---------------------------------------------------------------------------

class RS_BrownBaron : Actor   // CH Barons.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset13",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanBaron : Actor   // CH Barons.txt:375 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset13",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssBaron : Actor   // CH Barons.txt:875 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset13",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayBaron : Actor   // CH Barons.txt:1461 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset13",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluBaron : Actor   // CH Barons.txt:1738 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset13",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// CH_Red is CHSett.acs:29 -- a one-line read of the CH_NerfRedBoss cvar
// (CH default 1). rs_ch_nerfredboss is declared at CVARINFO.txt:1005 with
// that same default, so this gate is live and player-tunable. (Comment
// corrected 2026-08-07; it previously said the cvar did not exist yet.)
class RS_RedBaron : Actor   // CH Barons.txt:3118 -- gate CH_Red
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_nerfredboss', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_nerfredboss', 1) == 2, "Second");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_RedBaron3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Second:
		TNT1 A 0 A_Jump(256,"First","Third");
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedBaron1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackBaron : Actor   // CH Barons.txt:3857 -- gate CH_BlackBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedBaron",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteBaron : Actor   // CH Barons.txt:4459 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackBaron",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown ("Brown Baron Boi", the satyr).  CH: Barons.txt:40.
// ---------------------------------------------------------------------------
class RS_BrownBaron2 : Actor   // CH Barons.txt:40
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 2250;
		Species "BaronOfHell";
		BloodColor "Black";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 24;
		Height 64;
		Mass 1500;
		Speed 28;
		PainChance 20;
		DamageFactor "Fire", 0.5;
		XScale 1.15;   // CH lists xScale 1.0 then xscale 1.15; the last wins
		SeeSound "satyr/sight";      // CH:57 -- overridden at :75, see FX header
		PainSound "knight/pain";     // CH:58 -- overridden at :76, see FX header
		DeathSound "satyr/death";    // CH:59 -- overridden at :77, see FX header
		ActiveSound "knight/active";
		MeleeSound "baron/melee";
		HitObituary "%o was mauled by a satyr.";
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		+DONTHARMCLASS
		+MISSILEMORE
		-NORADIUSDMG
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		SeeSound "BBARO002";
		PainSound "brnaby4";
		DeathSound "BBARO003";
		ActiveSound "";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_MegaSphere", 10;
		DropItem "BackPack";
		Translation "0:255=@50[35,17,12]";
		Obituary "%o got grounded to dust by brown baron";
		HitObituary "C'mon and slam, welcome %o to brown baron jam";
		Tag "Brown Baron Boi";
		MeleeRange 64;
		MeleeThreshold 128;
	}
	States
	{
	Spawn:
		STYR AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		STYR AA 8 A_Chase();
		TNT1 A 0 A_PlaySound("brownBaron/step");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		STYR BB 8 A_Chase();
		TNT1 A 0 A_PlaySound("brownBaron/step");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		STYR CC 8 A_Chase();
		TNT1 A 0 A_PlaySound("brownBaron/step");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		STYR DD 8 A_Chase();
		TNT1 A 0 A_PlaySound("brownBaron/step");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		STYR PQ 7 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		STYR R 6 A_CustomMeleeAttack(random(30,80),"skeleton/melee","none");
		TNT1 A 0 A_JumpIfCloser(128,"Slam");
		Goto See;
	Slam:
		TNT1 A 0 A_CustomMissile("RS_BBaronCmonAndSlam",32,0);
		STYR R 1 A_VileAttack("bomb/boom",5,5,128,1.75);
		STYR R 1 A_RadiusThrust(3040,400,RTF_NOTMISSILE);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfInTargetLOS("Spiral",0,JLOSF_DEADNOJUMP,850,100);
		STYR E 1 A_FaceTarget();
		TNT1 A 0 A_CustomMissile("RS_BrownBaronFlame",46,34);
		STYR E 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CustomMissile("RS_BrownBaronFlame",46,34);
		STYR F 12 A_FaceTarget();
		STYR G 6 Bright A_CustomMissile("RS_BaronBrownRock",46,0);
		STYR PQ 3 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		STYR R 5 Bright A_CustomMissile("RS_BaronBrownRock",46,0);
		Goto See;
	Spiral:
		TNT1 A 0 A_Jump(176,"NoSpiral");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		STYR QR 3 A_FaceTarget();
		STYR G 6 Bright A_CustomMissile("RS_BrownBaronSpiral",32,0);
		STYR F 6;
		Goto See;
	NoSpiral:
		TNT1 A 0;
		Goto Missile+2;
	Pain:
		STYR H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		STYR H 2 A_Pain();
		Goto See;
	Death:
		STYR I 5;
		STYR J 5 A_Scream();
		STYR K 6;
		STYR L 7 A_Fall();
		STYR M 4;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),random(1,12),0,random(2,9),random(0,360),SXF_NOCHECKPOSITION);
		STYR N 4;
		STYR O -1;
		Stop;
	Raise:
		STYR ONMLKJI 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan ("Cyanide bitten BaronOfHell").  CH: Barons.txt:397.
// ---------------------------------------------------------------------------
class RS_CyanBaron2 : Actor   // CH Barons.txt:397
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 1666;
		Species "BaronOfHell";
		BloodColor "Cyan";
		Radius 24;
		Height 64;
		Mass 3000;
		Speed 18;
		PainChance 64;
		DamageFactor "Plasma", 0.7;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		+DONTHARMCLASS
		+MISSILEMORE
		-NORADIUSDMG
		+NOFEAR
		+BRIGHT
		+NOICEDEATH
		+LAXTELEFRAGDMG
		DamageFactor "Blessed", 3.0;
		DamageFactor "Ice", 0.15;      // CH lists Ice twice, both 0.15
		PainThreshold 32;
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 76;
		PainChance "Melee", 102;
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		DamageFactor "Melee", 1.80;    // CH lists Melee twice, both 1.80
		DamageFactor "fire", 1.50;     // CH lists fire twice, both 1.50; it also
		                               // overrides the earlier Fire,0.7 at CH:408
		RenderStyle "Add";
		Alpha 0.99;
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "baron/death";
		ActiveSound "baron/active";
		DropItem "RS_CH_BlueArmor", 176;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack", 128;
		Obituary "%o was frozen solid by cyan baron";
		Translation "0:111=%[0.00,0.00,0.40]:[0.26,1.35,2.00]","128:207=%[0.00,0.00,0.57]:[1.04,1.04,2.00]","112:127=%[0.00,2.00,2.00]:[1.01,2.00,2.00]","208:223=%[0.00,0.00,1.68]:[0.28,2.00,2.00]","224:255=%[0.00,0.00,0.74]:[0.00,0.00,1.50]";
		Tag "Cyanide bitten BaronOfHell";
	}
	States
	{
	Spawn:
		LOHS AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,8,0,2,-45,SXF_NOCHECKPOSITION);
		LOHS AABB 2 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS CCDD 2 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_Jump(92,"Dodger");
		LOHS A 0 A_Jump(32,"DashBack");
		Loop;
	Dodger:
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,8,0,2,-45,SXF_NOCHECKPOSITION);
		LOHS AABB 2 A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_Jump(64,"See");
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,8,0,2,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,8,0,2,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,8,0,2,-45,SXF_NOCHECKPOSITION);
		LOHS CCDD 2 A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_Jump(128,"See");
		LOHS A 0 A_Jump(64,"DashBack");
		Loop;
	Melee:
		LOHS E 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,5,0,6,-45,SXF_NOCHECKPOSITION);
		LOHS F 8 A_FaceTarget();
		LOHS G 8 A_CustomMeleeAttack(random(10,90),"Baron/melee");
		LOHS A 0 A_Jump(76,"DashBack");
	Missile:
		LOHS A 0;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(1200,"CheckAgain");
		TNT1 A 0 A_Jump(212,"WingBlast");
		TNT1 A 0 A_Jump(128,"BigBlast");
	Stars:
		LOHS E 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,5,0,6,-45,SXF_NOCHECKPOSITION);
		LOHS F 8 A_FaceTarget();
		LOHS G 5 A_CustomMissile("RS_BaronStarCyan",42,0);
		LOHS E 0 A_CheckSight("See");
		LOHS E 0 A_Jump(64,"Missile");
		Goto Stars2;
	Stars2:
		LOHS P 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,9,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,9,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,9,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,9,0,6,-45,SXF_NOCHECKPOSITION);
		LOHS Q 8 A_FaceTarget();
		LOHS R 5 A_CustomMissile("RS_BaronStarCyan",42,0);
		LOHS E 0 A_CheckSight("See");
		LOHS E 0 A_Jump(64,"Missile");
		Goto Stars;
	CheckAgain:
		TNT1 A 0 A_Jump(128,"Stars","BigBlast");
		TNT1 A 0 A_Jump(255,"Stars","BigBlast","WingBlast");
		Goto See;
	BigBlast:
		LOHS E 12 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,9,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,5,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,9,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,9,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,9,0,6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,5,0,6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,9,0,6,-45,SXF_NOCHECKPOSITION);
		LOHS EF 8 A_FaceTarget();
		LOHS G 5 A_CustomMissile("RS_BaronCyanBomb",42,0);
		LOHS G 12;
	WingBlast:
		LOHS H 2 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,-12,42,1,0,4,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,12,42,1,0,4,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,-20,56,1,0,4,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,20,56,1,0,4,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,-28,56,1,0,4,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,28,56,1,0,4,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,-36,68,1,0,4,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron2",-1,36,68,1,0,4,-45,SXF_NOCHECKPOSITION);
		LOHS H 12 A_FaceTarget();
		LOHS H 14 A_FaceTarget();
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",74,15,-9);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",74,-15,9);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",82,-25,-6);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",82,25,6);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",76,-19,5);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",76,19,-5);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",92,12,-7);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",92,12,7);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",74,-29,9);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",74,29,-9);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",64,-32,-14);
		LOHS H 1 A_CustomMissile("RS_IceSeekerBaron",64,32,14);
		LOHS H 8 A_FaceTarget();
		Goto See;
	DashBack:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "Dodger");   // CH: CallACS("CH_CyanBounce") == 1
		LOHS G 3 ThrustThingZ(0,72,0,0);
		TNT1 A 0 A_Jump(102,"Bon");
		LOHS G 3 ThrustThing(int(angle-180),18,0,0);   // CH: thrustthing(angle-180,18,0,0)
		Goto See;
	Bon:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS G 3 ThrustThing(int(angle*256/360),90,1,0);   // CH: ThrustThing(angle*256/360,90,1,0)
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		LOHS H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-12,42,5,0,-6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,12,42,5,0,-6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-20,56,5,0,-6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,20,56,5,0,-6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-28,56,5,0,-6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,28,56,5,0,-6,-45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,-36,68,5,0,-6,45,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_FrostWingBaron",-1,36,68,5,0,-6,-45,SXF_NOCHECKPOSITION);
		LOHS H 2 A_Pain();
		LOHS H 2 A_Jump(128,"Dodger");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		LOHS I 8;
		LOHS J 8 A_Scream();
		LOHS K 8;
		LOHS L 8 A_NoBlocking(false);
		LOHS MN 8;
		LOHS O 10 A_BossDeath();
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,246);
		LOHS O 10 A_IceGuyDie();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss Baron.  CH: Barons.txt:978.
// ---------------------------------------------------------------------------
class RS_AbyssBaron2 : Actor   // CH Barons.txt:978
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 3333;
		Radius 24;
		Height 64;
		Species "BaronOfHell";
		Mass 1500;
		Speed 14;
		PainChance 24;
		Monster;
		DamageFactor "Fire", 0.5;      // CH lists Fire twice, both 0.5
		DamageFactor "ice", 0.15;      // CH lists ice twice, both 0.15
		DamageFactor "plasma", 0.95;
		DamageFactor "Melee", 1.1;
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		+DONTMORPH
		+FLOORCLIP
		+MISSILEMORE
		+MISSILEEVENMORE
		-NORADIUSDMG
		+NOFEAR
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+QUICKTORETALIATE
		Scale 1.1;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_PlasmaRifle", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "RS_CH_MegaSphere", 128;
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		SeeSound "brnaby1";
		PainSound "brnaby4";
		DeathSound "brnaby2";
		ActiveSound "deepone/active";
		Obituary "%o received a demotion to dead from Abyss Baron";
		Translation "32:47=240:247","1:2=0:0","80:111=%[0.02,0.02,0.02]:[0.30,0.39,0.54]","176:191=200:207","32:47=240:247";
	}
	States
	{
	Spawn:
		AZEW A 5 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		AZEW AABB 3 A_VileChase();
		TNT1 A 0 A_Jump(24,"Dodge1","Dodge2");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AZEW CCDD 3 A_VileChase();
		TNT1 A 0 A_Jump(24,"Dodge1","Dodge2");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Heal:
		AZEP A 14 Bright A_SpawnItemEx("RS_AbyssBaronRing",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AZEA FFFF 1 Bright A_SpawnItemEx("RS_ArchRingHelp",random(-128,128),random(-128,128),0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Dodge1:
		TNT1 A 0 A_CheckSight("See");
		AZEW A 1 ThrustThingZ(0,14,0,0);
		AZEW A 1 ThrustThing(int(angle-90),29,0,0);   // CH: thrustthing(angle-90,29,0,0)
		TNT1 A 0 A_Jump(64,"Warp");
		Goto See;
	Warp:
		AZEP A 1;
		AZEP AAAAAAAA 0 A_Wander();
		AZEP AAAA 0 A_Wander();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AZEP A 1;
		Goto See;
	Dodge2:
		TNT1 A 0 A_CheckSight("See");
		AZEW A 1 ThrustThingZ(0,14,0,0);
		AZEW A 1 ThrustThing(int(angle+90),29,0,0);   // CH: thrustthing(angle+90,29,0,0)
		TNT1 A 0 A_Jump(64,"Warp");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(1500,"Choice");
		TNT1 A 0 A_Jump(64,"SoulSummon");
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA A 1 A_FaceTarget();
		AZEA A 1 A_CustomMissile("RS_AbyssBaronHandFire",64,30,0);
		AZEA A 6 A_FaceTarget();
		AZEA A 1 Bright A_CustomMissile("RS_Zap88",64,30,0);
		AZEA A 6 A_FaceTarget();
		AZEA A 6 A_FaceTarget();
		AZEA B 4 Bright A_FaceTarget();
		AZEA C 7 Bright A_CustomMissile("RS_AbyssBaronLightning",38,5,0);
		AZEA C 10;
		AZEP A 5;
		Goto See;
	Choice:
		TNT1 A 0 A_Jump(18,"SoulSummon");
		TNT1 A 0 A_Jump(255,"MLeftHand","Defile","SoulCharge");
		Goto See;
	Defile:
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA D 1 A_FaceTarget();
		AZEA D 1 A_CustomMissile("RS_AbyssBaronHandFire",64,-30,0);
		AZEA D 12 Bright A_FaceTarget();
		AZEA E 3 Bright A_FaceTarget();
		AZEA FCB 3 Bright;
		AZEA A 8 Bright A_VileTarget("RS_AbyssBaronDefile");
		Goto See;
	SoulCharge:
		AZEP A 16 Bright A_FaceTarget();
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",32,-30,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",32,30,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",32,0,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",64,-30,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",64,30,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",64,0,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",0,-30,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",0,30,0);
		AZEP A 1 Bright A_CustomMissile("RS_AbyssBaronHandFire",0,0,0);
		AZEP AA 12 Bright A_FaceTarget();
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEW A 8 Bright A_CustomMissile("RS_AbyssBaronSoulCharge",42,0,0);
		AZEW A 7 ThrustThingZ(0,14,0,0);
		Goto See;
	SoulSummon:
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA D 10 A_FaceTarget();
		AZEA D 1 A_CustomMissile("RS_AbyssBaronHandFire3",64,-30,0);
		AZEA D 10 A_FaceTarget();
		AZEA D 1 A_CustomMissile("RS_AbyssBaronHandFire3",76,0,0);
		AZEA D 10 A_FaceTarget();
		AZEA D 1 A_CustomMissile("RS_AbyssBaronHandFire3",64,30,0);
		AZEA D 10 A_FaceTarget();
		AZEA E 16 Bright;
		Goto See;
	MLeftHand:
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA D 1 A_FaceTarget();
		AZEA D 1 A_CustomMissile("RS_AbyssBaronHandFire",64,-30,0);
		AZEA D 6 A_FaceTarget();
		AZEA E 4 A_FaceTarget();
		AZEA F 7 A_CustomMissile("RS_AbyssBaronFlare",38,-5,0);
		AZEA F 1 A_CheckSight("See");   // CH: sprite AZAA ships nowhere in CH (typo for AZEA); invisible there too
	MRightHand:
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA A 1 A_FaceTarget();
		AZEA A 1 A_CustomMissile("RS_AbyssBaronHandFire",64,30,0);
		AZEA A 6 A_FaceTarget();
		AZEA B 4 A_FaceTarget();
		AZEA C 7 A_CustomMissile("RS_AbyssBaronFlare",38,5,0);
		Goto See;
	Melee:
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA AB 4 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AZEA C 4 A_CustomMeleeAttack(random(42,99),"monster/kntswg","skeleton/swing");
		TNT1 AAAAAAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-25,25),CMF_OFFSETPITCH,random(-25,-5));
		TNT1 A 0 A_PlaySound("brnaby3",0);
		AZEA DE 4 A_FaceTarget();
		AZEA F 4 A_CustomMeleeAttack(random(42,99),"monster/kntswg","skeleton/swing");
		TNT1 AAAAAAAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,-3,random(-25,25),CMF_OFFSETPITCH,random(-25,-5));
		Goto Missile;
	Pain:
		AZEP A 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AZEP A 2 A_Pain();
		AZEP A 4;
		TNT1 A 0 A_Jump(128,"Dodge1","Dodge2","Warp");
		Goto See;
	Death:
		AZED A 5;
		AZED B 5 A_Scream();
		AZED C 5;
		AZED D 4 A_Fall();
		AZED E 4;
		AZED F 3;
		AZED G -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray ("Statue?").  CH: Barons.txt:1480.
// ---------------------------------------------------------------------------
class RS_GrayBaron2 : Actor   // CH Barons.txt:1480
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 2000;
		Radius 24;
		Height 64;
		Species "BaronOfHell";
		Mass 1000;
		Speed 8;
		PainChance 6;
		Monster;
		DamageFactor "Fire", 0.33;   // CH lists Fire twice, both 0.33
		DamageFactor "ice", 0.2;     // CH lists ice twice, both 0.2
		DamageFactor "plasma", 0.75;
		DamageFactor "PLwater", 1.5;
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Obituary "%o got broken down by the stoney baron";
		+FLOORCLIP
		+MISSILEMORE
		+MISSILEEVENMORE
		-NORADIUSDMG
		+NOFEAR
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+QUICKTORETALIATE
		Scale 1.15;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_MegaSphere", 192;
		DropItem "BackPack", 64;
		DropItem "BackPack";
		SeeSound "monster/ar2sit";
		PainSound "baron/pain";
		DeathSound "monster/ar2dth";
		MeleeSound "baron/melee";
		Translation "0:255=%[0.21,0.19,0.28]:[0.57,1.09,0.90]","32:47=236:239","168:191=15:15","16:31=15:15","208:223=100:111","224:231=100:103","112:127=136:143";
		Tag "Statue?";
	}
	States
	{
	Spawn:
		BOS4 AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS4 AABB 6 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("incubus/walk");
		BOS4 CCDD 6 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("incubus/walk");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 B 0 A_Jump(255,"A1","A2");
		Goto See;
	A1:
		BOS4 E 8 Bright A_FaceTarget();
		BOS4 E 8 Bright A_CustomMissile("RS_WDRock1",64,26,0,0);
		BOS4 E 8 Bright;
		BOS4 F 8 Bright A_FaceTarget();
		BOS4 G 6 Bright A_CustomMissile("RS_BaronOfDirtCH3",28,0,0,0);
		BOS4 H 4 Bright A_MonsterRefire(128,"See");
		BOS4 I 8 Bright A_FaceTarget();
		BOS4 I 8 Bright A_CustomMissile("RS_WDRock1",64,-26,0,0);
		BOS4 I 8 Bright;
		BOS4 J 8 Bright A_FaceTarget();
		BOS4 K 6 Bright A_CustomMissile("RS_BaronOfDirtCH3",28,0,0,0);
		BOS4 L 3 Bright A_MonsterRefire(128,"See");
		Goto Missile;
	A2:
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 3 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		TNT1 A 0 Radius_Quake(7,45,0,40,0);
		BOS4 M 6 Bright A_CustomMissile("RS_BaronOfDirtCH",10,0,0,0);
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 MMN 8 Bright A_FaceTarget();
		BOS4 O 6 Bright A_CustomMissile("RS_BaronOfDirtCH2",32,0,0,0);
		BOS4 O 2 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain.Ice:
	Pain.Plasma:
	Pain.Fire:
		BOS4 Q 1 A_PlaySound("ResistCH",7);
		BOS4 Q 2 A_Pain();
		Goto See;
	Pain.Plwater:
		BOS4 Q 4 A_Pain();
		BOS4 Q 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 Q 8 A_Pain();
		Goto See;
	Pain:
		BOS4 Q 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 Q 4 A_Pain();
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS4 R 6 Bright;
		BOS4 S 6 Bright A_Scream();
		BOS4 T 6 Bright;
		BOS4 U 6 Bright A_NoBlocking();
		BOS4 VWXYZ 6 Bright;
		BOS4 "[" 6 Bright;
		PRIM RST 5;
		PRIM U -1;
		Stop;
	Raise:
		PRIM TSR 5;
		BOS4 ZYXWUTSR 6 Bright;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu ("How awkward!").  CH: Barons.txt:1757.
// ---------------------------------------------------------------------------
class RS_FireBluBaron2 : Actor   // CH Barons.txt:1757
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 2300;
		Radius 24;
		Height 64;
		Species "BaronOfHell";
		Mass 1000;
		Speed 20;
		PainChance 32;
		Monster;
		DamageFactor "Fire", 0.5;   // CH lists Fire twice, both 0.5
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Obituary "%o was dunked by FireBlu Baron";
		+FLOORCLIP
		+MISSILEMORE
		-NORADIUSDMG
		+NOFEAR
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+QUICKTORETALIATE
		+NOPAIN
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "RS_CH_MegaSphere", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		SeeSound "monster/ar2sit";
		PainSound "baron/pain";
		DeathSound "monster/ar2dth";
		MeleeSound "baron/melee";
		Translation "176:191=194:205","32:47=205:207","112:127=196:207","212:223=197:204","160:167=199:204","224:231=192:194","232:235=202:206","31:31=201:201","96:111=180:185","5:7=187:191","8:8=247:247","2:2=191:191","1:1=191:191","3:3=189:189","95:95=174:174","0:0=47:47";
		Tag "How awkward!";
	}
	States
	{
	Spawn:
		BOS4 AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS4 AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 B 0 A_Jump(255,"A1","A2","A3");
		Goto See;
	A1:
		BOS4 EF 8 Bright A_FaceTarget();
		BOS4 G 0 A_CustomMissile("RS_RedBBall",28,0,0,0);
		BOS4 G 0 A_CustomMissile("RS_BluBBall",28,0,-4,0);
		BOS4 G 3 Bright A_CustomMissile("RS_RedBBall",28,0,4,0);
		BOS4 H 3 Bright A_MonsterRefire(128,"See");
		BOS4 IJ 8 Bright A_FaceTarget();
		BOS4 K 0 A_CustomMissile("RS_BluBBall",28,0,0,0);
		BOS4 K 0 A_CustomMissile("RS_RedBBall",28,0,-4,0);
		BOS4 K 3 Bright A_CustomMissile("RS_RedBBall",28,0,4,0);
		BOS4 L 3 Bright A_MonsterRefire(128,"See");
		Goto Missile;
	A3:
		BOS4 O 6 Bright A_PlaySound("monster/ar2sit");
		BOS4 O 6 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BOS4 ON 8 Bright;
		BOS4 M 6 Bright A_CustomMissile("RS_BluPowerBomb",40,0,0,0);
		BOS4 MN 2;
		BOS4 M 0 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",False)
		Goto See;
	A2:
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 3 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BOS4 M 6 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 8 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 MN 8 Bright;
		BOS4 O 6 Bright A_CustomMissile("RS_RedPowerBomb",32,0,0,0);
		BOS4 O 2 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",False)
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BOS4 Q 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 Q 4 A_Pain();
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS4 R 6 Bright;
		BOS4 S 6 Bright A_Scream();
		BOS4 T 6 Bright;
		BOS4 U 6 Bright A_NoBlocking();
		BOS4 VWXYZ 6 Bright;
		BOS4 "[" 6 Bright;
		PRIM RST 5;
		PRIM U -1;
		Stop;
	Raise:
		PRIM TSR 5;
		BOS4 ZYXWUTSR 6 Bright;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common Baron.  CH: Barons.txt:1947.
// Its ACS lead-shot (CHACS.acs:54 "BaronMissile") uses the hellknight lane's
// native rebuild, RS_HKLead.FireLead -- same call, same 32-unit z offset, and
// same opt-out gate (rs_ch_intercept, CH default false = lead-predict).
// ---------------------------------------------------------------------------
class RS_CommonBaron : BaronOfHell   // CH Barons.txt:1947
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "Green";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		GibHealth -100;
		Monster;
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		Tag "BaronOfHell";
	}
	States
	{
	Spawn:
		BOSS AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOSS AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Pain:
		BOSS H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS H 2 A_Pain();
		Goto See;
	Melee:
	Missile:
		BOSS EF 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS G 8 A_BruisAttack();
		BOSS PQ 8 A_FaceTarget();
		BOSS Q 0 A_JumpIf(RS_Zom.CV('rs_ch_intercept', 0) == 1, "Miss2");   // CH: CallACS("CH_Intercept") == true (CH default false)
		BOSS R 8 { RS_HKLead.FireLead(self, "BaronBall", 32); }   // CH: ACS_NamedExecuteWithResult("BaronMissile",1) -- CHACS.acs:54, rebuilt native
		BOSS R 0 A_Jump(75,"Missile");
		Goto See;
	Miss2:
		BOSS R 8 A_BruisAttack();
		BOSS R 0 A_Jump(75,"Missile");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOSS I 8;
		BOSS J 8 A_Scream();
		BOSS K 8;
		BOSS L 8 A_NoBlocking();
		BOSS MN 8;
		BOSS O -1 A_BossDeath();
		Stop;
	Raise:
		BOSS O 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BOSS NMLKJI 5;
		Goto See;
	Grow:
		BOSS NMLKJI 5;
		BOSS A 0 A_SpawnItemEx("RS_GreenBaron",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BOSS I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOSS I 0 A_Stop();
		BOSS I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain stripped, animation stays
		HKGB B 0 A_ScreamAndUnblock();
		HKGB B -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green Baron.  CH: Barons.txt:2040.
// ---------------------------------------------------------------------------
class RS_GreenBaron : BaronOfHell   // CH Barons.txt:2040
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		GibHealth -100;
		Health 1170;
		Species "BaronOfHell";
		BloodColor "Green";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 24;
		Height 64;
		Mass 1000;
		Speed 9;
		PainChance 40;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		+MISSILEMORE
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "baron/death";
		ActiveSound "baron/active";
		Obituary "%o met a greener baron";
		DropItem "RS_ArmorBundle", 28;
		DropItem "RS_CH_SuperShotgun", 12;
		HitObituary "%o wasnt touched by just green thumb";
		Translation "16:31=112:120","32:47=122:127";
		Tag "Green BaronOfHell";
	}
	States
	{
	Spawn:
		BOSS AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOSS AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		BOSS EF 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS G 8 A_CustomMeleeAttack(random(10,65),"Baron/melee");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS E 0 A_JumpIfCloser(500,"Spit",true);
		BOSS EF 8 A_FaceTarget();
		BOSS G 8 A_CustomMissile("RS_Spspit2",32,5,random(-1,1));
		BOSS PQ 6 A_FaceTarget();
		BOSS R 6 A_CustomMissile("RS_Spspit2",32,5,random(-1,1));
		Goto See;
	Spit:
		TNT1 A 0 A_JumpIfHigherOrLower(null,"PUKE",0,-32);   // CH: A_JumpIfHigherOrLower("","PUKE",0,-32)
		BOSS HEF 5 A_FaceTarget();
		BOSS G 8 A_CustomMissile("RS_Spspit3",32,0,random(-1,1));
		BOSS HPQ 4 A_FaceTarget();
		BOSS R 6 A_CustomMissile("RS_Spspit3",32,0,random(-1,1));
		Goto See;
	Puke:
		BOSS H 5 Bright A_FaceTarget();
		BOSS H 2 Bright A_CustomMissile("RS_GreeniesBR",56,0,random(-6,6));
		BOSS H 0 A_CustomMissile("RS_GreeniesBR",56,0,random(-6,6));
		BOSS H 2 Bright A_CustomMissile("RS_GreeniesBR",56,0,random(-13,13));
		BOSS H 0 A_CustomMissile("RS_GreeniesBR",56,0,random(-6,6));
		BOSS H 2 Bright A_CustomMissile("RS_GreeniesBR",56,0,random(-14,14));
		BOSS H 0 A_CustomMissile("RS_GreeniesBR",56,0,random(-6,6));
		BOSS H 0 A_CheckSight("See");
		BOSS H 0 A_CheckFlag("SOLID","Missile",AAPTR_TARGET);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BOSS H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS H 2 A_Pain();
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOSS I 8;
		BOSS J 8 A_Scream();
		BOSS K 8;
		BOSS L 8 A_NoBlocking();
		BOSS MN 8;
		BOSS O -1 A_BossDeath();
		Stop;
	Raise:
		BOSS O 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BOSS NMLKJI 5;
		Goto See;
	Grow:
		BOSS NMLKJI 5;
		BOSS A 0 A_SpawnItemEx("RS_BlueBaron",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BOSS I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOSS I 0 A_Stop();
		BOSS I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain stripped, animation stays
		HKGB B 0 A_ScreamAndUnblock();
		HKGB B -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue Baron.  CH: Barons.txt:2264.
// ---------------------------------------------------------------------------
class RS_BlueBaron : BaronOfHell   // CH Barons.txt:2264
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 1309;
		Species "BaronOfHell";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		BloodColor "Blue";
		Radius 24;
		Height 64;
		Mass 1000;
		GibHealth -100;
		Speed 11;
		PainChance 30;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+MISSILEMORE
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "baron/death";
		ActiveSound "baron/active";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_ArmorBundle", 102;
		DropItem "RS_CH_SoulSphere", 8;
		Obituary "%o was smashed by blue baron's great balls";
		Translation "16:31=193:201","112:127=240:247","32:47=201:207";
		Tag "Blue Blood Baron";
	}
	States
	{
	Spawn:
		BOSS AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOSS AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS EF 12 A_FaceTarget();
		BOSS G 2 Bright;
		BOSS G 0 A_JumpIfHigherOrLower("Cometto",null,28,0,true);   // CH: A_JumpIfhigherorlower("Cometto","",28,0,true)
		BOSS G 0 A_JumpIfCloser(1000,"Balls",true);
		BOSS G 0 A_Jump(256,"Cometto");
		Goto See;
	Balls:
		BOSS G 0 A_CustomMissile("RS_SmashBalls2",32,5,random(-5,5));
		BOSS G 0 A_CustomMissile("RS_SmashBalls2",32,5,randompick(random(-15,-5),random(5,15),random(-21,-15),random(15,21)));
		// CH: two further SmashBalls2 lines here are commented out in CH itself
		Goto See;
	Cometto:
		BOSS G 6 A_CustomMissile("RS_SmashBall4",32,5,random(-1,1));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BOSS H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS H 2 A_Pain();
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOSS I 8;
		BOSS J 8 A_Scream();
		BOSS K 8;
		BOSS L 8 A_NoBlocking();
		BOSS MN 8;
		BOSS O -1 A_BossDeath();
		Stop;
	Raise:
		BOSS O 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BOSS NMLKJI 5;
		Goto See;
	Grow:
		BOSS NMLKJI 5;
		BOSS A 0 A_SpawnItemEx("RS_PurpleBaron",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BOSS I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOSS I 0 A_Stop();
		BOSS I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain stripped, animation stays
		HKGB B 0 A_ScreamAndUnblock();
		HKGB B -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple ("Royal BaronOfHell").  CH: Barons.txt:2524.
// ---------------------------------------------------------------------------
class RS_PurpleBaron : BaronOfHell   // CH Barons.txt:2524
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 1500;
		GibHealth -100;
		Species "BaronOfHell";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		BloodColor "Blue";
		Radius 24;
		Height 64;
		Mass 1000;
		Speed 11;
		PainChance 30;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		+MISSILEMORE
		+NOFEAR
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "baron/death";
		ActiveSound "baron/active";
		DropItem "RS_CH_GreenArmor", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_SoulSphere", 10;
		DropItem "RS_CH_Cell", 128;
		Obituary "%o , thee faced the might of royal coloured baron";
		Translation "16:31=[235,156,254]:[207,27,181]","32:47=[194,20,164]:[60,23,30]","144:151=[209,79,227]:[130,47,90]","255:255=254:254","13:15=254:254","0:0=247:247","194:207=174:191";
		Tag "Royal BaronOfHell";
	}
	States
	{
	Spawn:
		BOSS AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOSS AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		BOSS E 8 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS E 0 A_JumpIfHealthLower(900,"Both");
		BOSS E 0 A_JumpIfCloser(800,"Wave1");
		BOSS E 0 A_Jump(255,"Spearthingy");
		Goto See;
	Both:
		BOSS E 0 A_Jump(255,"Spearthingy","Wave1");
		Goto See;
	Wave1:
		BOSS F 6 Bright;
		BOSS G 5 Bright;
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,1);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,3);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-3);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,6);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-6);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,9);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-9);
		BOSS G 0 A_Jump(100,"Wave2");
		Goto See;
	Wave2:
		BOSS PQ 8 A_FaceTarget();
		BOSS R 8 Bright;
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,1);
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,3);
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,-3);
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,6);
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,-6);
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,9);
		BOSS R 0 A_CustomMissile("RS_BaronWave",32,5,-9);
		Goto See;
	Spearthingy:
		BOSS E 0 A_PlaySound("Litn/litn2");
		BOSS E 12 Bright A_CustomMissile("RS_Zap88",48,8);
		BOSS G 5 Bright A_CustomMissile("RS_Spear11",38,5);
		BOSS PQ 5;
		BOSS R 5 Bright A_CustomMissile("RS_Spear11",38,-5);
		BOSS R 0 A_Jump(115,"Missile");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BOSS H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSS H 2 A_Pain();
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOSS I 8;
		BOSS J 8 A_Scream();
		BOSS K 8;
		BOSS L 8 A_NoBlocking();
		BOSS MN 8;
		BOSS O -1 A_BossDeath();
		Stop;
	Raise:
		BOSS NMLKJI 8;
		Goto See;
	XDeath:
		BOSS I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOSS I 0 A_Stop();
		BOSS I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain stripped, animation stays
		HKGB B 0 A_ScreamAndUnblock();
		HKGB B -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 5 -- Yellow ("Grand Orange BaronOfHell").  CH: Barons.txt:2793.
// ---------------------------------------------------------------------------
class RS_YellowBaron : BaronOfHell   // CH Barons.txt:2793
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 1888;
		Species "BaronOfHell";
		BloodColor "Yellow";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 24;
		Height 64;
		Mass 1500;
		Speed 15;
		PainChance 20;
		DamageFactor "Fire", 0.7;
		DamageFactor "Plasma", 0.7;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		+DONTHARMCLASS
		+MISSILEMORE
		-NORADIUSDMG
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "baron/death";
		ActiveSound "baron/active";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 10;
		DropItem "BackPack";
		Obituary "%o was annihilated by orange baron and its not so tiny wings";
		Translation "112:127=208:223";
		Tag "Grand Orange BaronOfHell";
	}
	States
	{
	Spawn:
		LOHS AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		LOHS A 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS B 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS D 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS A 0 A_Jump(48,"Dodger");
		Loop;
	Dodger:
		LOHS A 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS AABB 3 A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS B 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS CCDD 3 A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS D 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS A 0 A_Jump(128,"See");
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS EF 8;
		LOHS G 8 A_CustomMeleeAttack(random(10,90),"Baron/melee");
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS E 8 A_FaceTarget();
		LOHS E 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS E 0 A_JumpIfCloser(1000,"RumbleIT");
		LOHS E 0 A_JumpIfCloser(1500,"Dash");
		LOHS E 0 A_Jump(255,"FireSummon");
		Goto See;
	Dash:
		LOHS G 5 ThrustThing(int(angle*256/360),90,1,0);   // CH: ThrustThing(angle*256/360,90,1,0)
		Goto See;
	RumbleIT:
		LOHS E 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LOHS E 0 A_Jump(255,"StarShot","FireBlast");
		Goto See;
	StarShot:
		LOHS EF 6 Bright A_FaceTarget();
		LOHS G 6 Bright A_CustomMissile("RS_BaronStar",32,3,1);
		LOHS G 2 A_MonsterRefire(80,"See");
		Goto StarShot2;
	StarShot2:
		LOHS PQ 8 Bright A_FaceTarget();
		LOHS R 6 Bright A_CustomMissile("RS_BaronStar2",32,3,1);
		LOHS R 2 A_MonsterRefire(80,"See");
		Goto StarShot;
	FireBlast:
		LOHS E 12 Bright A_CustomMissile("RS_BaronRing",80,0,0);
		LOHS E 12 Bright A_FaceTarget();
		LOHS F 9 Bright;
		LOHS G 6 Bright A_CustomMissile("RS_BaronFBomb",32,3,0);
		LOHS G 6;
		Goto See;
	FireSummon:
		LOHS P 14 Bright A_CustomMissile("RS_FireHand1",46,-26);
		LOHS Q 12 Bright A_FaceTarget();
		LOHS R 13 Bright A_VileTarget("RS_BigBadFire1");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		LOHS H 2 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS H 2 A_Pain();
		LOHS H 2 A_Jump(128,"Dodger");
		Goto See;
	Pain.Fire:
		LOHS H 2 A_Pain();
		Goto Dodger;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		LOHS I 8;
		LOHS J 8 A_Scream();
		LOHS K 8;
		LOHS L 8 A_NoBlocking();
		LOHS MN 8;
		LOHS O -1 A_BossDeath();
		Stop;
	Raise:
		LOHS NMLKJI 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red, phase one ("Red Rage Baron").  CH: Barons.txt:3172.
// ---------------------------------------------------------------------------
class RS_RedBaron1 : Actor   // CH Barons.txt:3172
{
	int user_rageup2;   // CH: Var int User_RageUP2
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 2000;
		Radius 24;
		Height 64;
		Species "BaronOfHell";
		Mass 1000;
		Speed 10;
		PainChance 20;
		Monster;
		MeleeDamage 10;
		DamageFactor "Fire", 0.75;   // CH lists Fire twice, both 0.75
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Obituary "%o was firepowered by Red Baron";
		HitObituary "%o got maimed by Red Baron";
		+FLOORCLIP
		+MISSILEMORE
		-NORADIUSDMG
		+NOFEAR
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+QUICKTORETALIATE
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_CellPack", 128;
		// CH: Dropitem "RLDemonicCarapaceArmorPickup",12 -- DRLA cross-mod drop stripped
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 24;
		DropItem "BackPack", 88;
		SeeSound "monster/ar2sit";
		PainSound "baron/pain";
		DeathSound "monster/ar2dth";
		MeleeSound "baron/melee";
		Translation "112:127=176:191";
		Tag "Red Rage Baron";
	}
	States
	{
	Spawn:
		BOS4 AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS4 AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		BOS4 A 1 A_Jump(128,"Trio");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 B 0 A_Jump(255,"Trio","Bomb");
		Goto See;
	Trio:
		BOS4 EF 8 Bright A_FaceTarget();
		BOS4 G 0 A_CustomMissile("RS_RedBBall",28,0,0,0);
		BOS4 G 0 A_CustomMissile("RS_RedBBall",28,0,-4,0);
		BOS4 G 3 Bright A_CustomMissile("RS_RedBBall",28,0,4,0);
		BOS4 H 3 Bright A_MonsterRefire(128,"See");
		Goto Trio2;
	Trio2:
		BOS4 IJ 8 Bright A_FaceTarget();
		BOS4 K 0 A_CustomMissile("RS_RedBBall",28,0,0,0);
		BOS4 K 0 A_CustomMissile("RS_RedBBall",28,0,-4,0);
		BOS4 K 3 Bright A_CustomMissile("RS_RedBBall",28,0,4,0);
		BOS4 L 3 Bright A_MonsterRefire(128,"See");
		Goto Missile;
	Bomb:
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 3 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BOS4 M 6 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 8 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 MN 8 Bright;
		BOS4 O 6 Bright A_CustomMissile("RS_RedPowerBomb",10,0,0,0);
		BOS4 O 2 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 EF 8 Bright A_FaceTarget();
		BOS4 G 3 Bright A_MeleeAttack();
		BOS4 H 3 Bright;
		BOS4 H 0 A_Jump(128,1);
		Goto See;
		BOS4 IJ 8 Bright A_FaceTarget();
		BOS4 K 3 Bright A_MeleeAttack();
		BOS4 L 3 Bright;
		BOS4 L 0 A_Jump(64,1);
		Goto See;
		BOS4 MN 8 Bright A_FaceTarget();
		BOS4 O 0 A_MeleeAttack();
		BOS4 O 3 Bright A_MeleeAttack();
		BOS4 P 3 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssBaron2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BOS4 Q 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 Q 2 A_Pain();
		BOS4 Q 2 A_Jump(32,"Rage");
		Goto See;
	Rage:
		BOS4 B 0 A_JumpIf(user_rageup2 >= 1, "NAH");
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 1 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BOS4 M 8 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 M 3 Bright { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenMore",TRUE)
		BOS4 MN 5 Bright;
		BOS4 O 5 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 O 2 Bright A_SetSpeed(28);
		BOS4 O 4 { user_rageup2 += 1; }   // CH: A_SetUserVar("User_RageUP2",User_RageUP2+1)
		Goto See;
	NAH:
		TNT1 A 0;
		Goto Missile+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS4 R 6 Bright;
		BOS4 S 6 Bright A_Scream();
		BOS4 T 6 Bright;
		BOS4 U 6 Bright A_NoBlocking();
		BOS4 VWXYZ 6 Bright;
		BOS4 "[" 6 Bright;
		PRIM RST 5;
		PRIM U -1;
		Stop;
	Raise:
		PRIM TSR 5;
		BOS4 ZYXWUTSR 6 Bright;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red, boss phase one ("Power Baron of Red").  CH: Barons.txt:3326.
// Its death spawns RS_RedBaron2, the flying phase.
// ---------------------------------------------------------------------------
class RS_RedBaron3 : Actor   // CH Barons.txt:3326
{
	int user_buildup;   // CH: Var Int User_BuildUP
	int user_rageup;    // CH: Var Int User_RageUP
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 2100;
		Radius 24;
		Height 64;
		Species "BaronOfHell";
		Mass 1000;
		Speed 8;
		PainChance 20;
		Monster;
		MeleeDamage 10;
		RadiusDamageFactor 0.33;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Obituary "%o was shot down by Red Baron";
		HitObituary "%o got maimed by Red Baron";
		+FLOORCLIP
		+MISSILEMORE
		+BOSS
		-NORADIUSDMG
		+DONTMORPH
		+NOFEAR
		+DONTHARMSPECIES
		+NOICEDEATH
		+DONTHARMCLASS
		+QUICKTORETALIATE
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "BackPack", 128;
		// CH: Dropitem "RLDemonicCarapaceArmorPickup",32 -- DRLA cross-mod drop stripped
		SeeSound "monster/ar2sit";
		PainSound "baron/pain";
		DeathSound "monster/ar2dth";
		MeleeSound "baron/melee";
		Translation "112:127=176:191";
		Tag "Power Baron of Red";
	}
	States
	{
	Spawn:
		BOS4 A 0;
		Goto Scripted;
	Scripted:
		BOS4 A 1;   // CH: ACS_NamedExecuteAlways("AnnounceBaron") -- announcer stripped
		Goto Idle;
	Idle:
		BOS4 AB 10 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS4 AABB 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 CCDD 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		BOS4 A 1 A_JumpIfHealthLower(1250,"BUFF");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 B 0 A_JumpIf(user_buildup >= 6, "Bomb");
		BOS4 B 0 A_Jump(255,"Trio");
		Goto See;
	Trio:
		BOS4 EF 8 Bright A_FaceTarget();
		BOS4 G 0 A_CustomMissile("RS_RedBBall",28,0,0,0);
		BOS4 G 0 A_CustomMissile("RS_RedBBall",28,0,-4,0);
		BOS4 G 3 Bright A_CustomMissile("RS_RedBBall",28,0,4,0);
		BOS4 G 0 { user_buildup += 1; }   // CH: A_SetUserVar("User_BuildUP",User_BuildUP+1)
		BOS4 H 3 Bright A_MonsterRefire(128,"See");
		Goto Trio2;
	Trio2:
		BOS4 IJ 8 Bright A_FaceTarget();
		BOS4 K 0 A_CustomMissile("RS_RedBBall",28,0,0,0);
		BOS4 K 0 A_CustomMissile("RS_RedBBall",28,0,-4,0);
		BOS4 K 3 Bright A_CustomMissile("RS_RedBBall",28,0,4,0);
		BOS4 G 0 { user_buildup += 1; }   // CH: A_SetUserVar("User_BuildUP",User_BuildUP+1)
		BOS4 L 3 Bright A_MonsterRefire(128,"See");
		Goto Missile;
	Bomb:
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 1 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BOS4 M 8 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 MN 12 Bright A_FaceTarget();
		BOS4 O 6 Bright A_CustomMissile("RS_ArchonComet",28,0,0,0);
		BOS4 O 0 { user_buildup -= 5; }   // CH: A_SetUserVar("User_BuildUP",User_BuildUP-5)
		BOS4 P 5 Bright { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		Goto See;
	BUFF:
		BOS4 B 0 A_JumpIf(user_rageup >= 1, "NAH");
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 1 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BOS4 M 8 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 M 4 Bright A_PlaySound("monster/ar2sit");
		BOS4 M 2 Bright A_Quake(10,30,0,256,"");   // CH: A_Quake(10,30,0,256,0)
		BOS4 M 8 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 M 3 Bright { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenMore",TRUE)
		BOS4 MN 8 Bright;
		BOS4 O 6 Bright A_CustomMissile("RS_RedPower",10,0,0,0);
		BOS4 O 2 Bright A_SetSpeed(28);
		BOS4 O 4 { user_rageup += 1; }   // CH: A_SetUserVar("User_RageUP",User_RageUP+1)
		Goto See;
	NAH:
		TNT1 A 0;
		Goto Missile+1;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 EF 8 Bright A_FaceTarget();
		BOS4 G 3 Bright A_MeleeAttack();
		BOS4 H 3 Bright;
		BOS4 H 0 A_Jump(128,1);
		Goto See;
		BOS4 IJ 8 Bright A_FaceTarget();
		BOS4 K 3 Bright A_MeleeAttack();
		BOS4 L 3 Bright;
		BOS4 L 0 A_Jump(64,1);
		Goto See;
		BOS4 MN 8 Bright A_FaceTarget();
		BOS4 O 0 A_MeleeAttack();
		BOS4 O 3 Bright A_MeleeAttack();
		BOS4 P 3 Bright;
		Goto See;
	Pain:
		BOS4 Q 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS4 Q 2 A_Pain();
		BOS4 Q 2 { user_buildup += 1; }   // CH: A_SetUserVar("User_BuildUP",User_BuildUP+1)
		Goto See;
	Death:
		BOS4 R 6 Bright;
		BOS4 S 6 Bright A_Scream();
		BOS4 T 6 Bright;
		BOS4 U 6 Bright A_NoBlocking();
		BOS4 VW 6 Bright;
		BOS4 X 6 Bright A_SpawnItemEx("RS_RedBaron2",0,0,82,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		BOS4 YZ 6 Bright;
		BOS4 "[" 6 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red, boss phase two ("Flying Red Baron").  CH: Barons.txt:3602.
// CH's See and Missile both jump by numeric offset (A_Jump(96,12),
// A_Jump(128,13), A_Jump(64,1)), so the state entries below are transcribed
// one-for-one: reordering or merging any line would move the landing spot.
// ---------------------------------------------------------------------------
class RS_RedBaron2 : Actor   // CH Barons.txt:3602
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 1250;
		Radius 24;
		Height 48;
		Species "BaronOfHell";
		Mass 200;
		Speed 20;
		FloatSpeed 25;
		PainChance 128;
		RadiusDamageFactor 0.33;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Melee", 5.0;   // CH lists Melee twice, both 5.0
		Monster;
		+BOSS
		+NOGRAVITY
		+FLOAT
		+DONTHARMCLASS
		+MISSILEMORE
		+DONTMORPH
		+QUICKTORETALIATE
		-NORADIUSDMG
		+DONTHARMSPECIES
		+NOFEAR
		Obituary "%o got tailgunnered by RedBaron's final form";
		SeeSound "monster/falsit";
		PainSound "monster/falpai";
		DeathSound "monster/faldth";
		ActiveSound "monster/falact";
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_Berserk", 128;
		DropItem "RS_CH_BFG9000", 34;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_MegaSphere", 34;
		// CH: DropItem "RLFireStormModItem",128 -- DRLA cross-mod drop stripped
		Translation "208:223=176:191","165:167=43:47","232:235=41:47";
		Tag "Flying Red Baron";
	}
	States
	{
	Spawn:
		FALN ABCDB 8 Bright A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FALN A 0 A_Jump(96,12);
		FALN A 1 Bright A_PlaySound("monster/falwng");
		FALN AABBC 2 Bright A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN CDDBB 2 Bright A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
		FALN B 2 Bright A_FastChase();
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN B 2 Bright A_FastChase();
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN B 2 Bright A_FastChase();
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN B 2 Bright A_FastChase();
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN B 0 A_Jump(64,1);
		Loop;
		FALN B 2 Bright A_FastChase();
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN B 2 Bright A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN B 2 Bright A_FastChase();
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN B 2 Bright A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN B 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN C 0 A_Jump(128,13);
		FALN CE 2 Bright A_FaceTarget();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN E 2 Bright A_FaceTarget();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN E 2 Bright A_FaceTarget();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN E 2 Bright A_FaceTarget();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN E 2 Bright A_FaceTarget();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN E 5 Bright;
		Goto See;
		FALN C 0 A_FastChase();
		FALN C 2 Bright A_FaceTarget();
		FALN E 0 A_FastChase();
		FALN E 2 Bright A_FaceTarget();
		FALN F 0 A_FastChase();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN F 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN C 0 A_FastChase();
		FALN C 2 Bright A_FaceTarget();
		FALN E 0 A_FastChase();
		FALN E 2 Bright A_FaceTarget();
		FALN F 0 A_FastChase();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN F 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN C 0 A_FastChase();
		FALN C 5 Bright A_FaceTarget();
		FALN E 0 A_FastChase();
		FALN E 2 Bright A_FaceTarget();
		FALN F 0 A_FastChase();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN F 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN C 0 A_FastChase();
		FALN C 2 Bright A_FaceTarget();
		FALN E 0 A_FastChase();
		FALN E 2 Bright A_FaceTarget();
		FALN F 0 A_FastChase();
		FALN F 3 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN F 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		FALN C 0 A_FastChase();
		FALN C 2 Bright A_FaceTarget();
		FALN E 0 A_FastChase();
		FALN E 3 Bright A_FaceTarget();
		FALN F 0 A_FastChase();
		FALN F 2 Bright A_CustomMissile("RS_RedBBall2",40,0,0);
		FALN F 0 A_SpawnItemEx("RS_FallenFX",0,0,40,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN E 5 Bright;
		Goto See;
	Pain:
		FALN E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FALN E 3 Bright A_Pain();
		FALN E 3 Bright;
		Goto See;
	Death:
		FALN G 5 Bright;
		FALN H 5 Bright A_Scream();
		FALN IIIJJJKKK 2 Bright A_CustomMissile("RS_HKRedDeath",random(5,70),random(5,35),CMF_AIMOFFSET,2,-10);
		FALN L 5 Bright A_NoBlocking();
		FALN M -1 A_SetFloorClip();
		Stop;
	Raise:
		FALN M 5 A_UnSetFloorClip();
		FALN LKJIHG 5 Bright;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black ("Baron from Abyss").  CH: Barons.txt:3876.
// ---------------------------------------------------------------------------
class RS_BlackBaron2 : Actor   // CH Barons.txt:3876
{
	int user_uhoh;   // CH: var int user_uhoh
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was crafted into lore by the Black Baron";
		HitObituary "%o got kinky with Black Baron";
		Species "BaronOfHell";
		Health 8907;
		Radius 24;
		Height 64;
		Mass 2000;
		Scale 1.25;
		Speed 13;
		BloodColor "purple";
		DamageFactor "Melee", 1.5;
		DamageFactor "Fire", 0.7;
		DamageFactor "plasma", 0.8;
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 0.5;   // CH lists ice twice, both 0.5
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 12;
		PainChance "ice", 4;
		PainChance "Fire", 32;
		PainChance "Plasma", 24;
		PainChance "PlayerVoid", 12;
		PainChance "Melee", 68;
		PainChance 42;
		MeleeRange 88;
		SeeSound "deepone/sight";
		PainSound "deepone/pain";
		DeathSound "deepone/death";
		ActiveSound "deepone/active";
		MeleeSound "deepone/melee";
		Translation "84:95=99:105","113:124=102:111","124:127=5:8","152:159=107:111","160:167=250:254","231:231=250:250";
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+THRUSPECIES
		+BOSS
		+DONTHARMCLASS
		+DONTMORPH
		+MISSILEMORE
		+QUICKTORETALIATE
		-NORADIUSDMG
		+DONTHARMSPECIES
		+NOFEAR
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk", 128;
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		// CH: DropItem "SchoolGirlTG" -- class defined NOWHERE in the CH tree
		//     (dropped here and in MASTERMINDS.txt:3884, never declared).
		//     Itemised, not silently gutted; restore if CH's source turns up.
		DropItem "RS_CH_BFG9000", 128;
		DropItem "RS_CH_MegaSphere", 128;
		DropItem "RS_CH_SoulSphere", 188;
		DropItem "RS_CH_GreenArmor";
		// CH: DropItem "RLOnyxModItem",164 / Dropitem "RLParticleBeamCannonPickup",42 /
		//     Dropitem "RareArmorPool",128 / Dropitem "RLDemonicWeaponSpawner",16 /
		//     Dropitem "RLLegendaryWeaponSpawner",2 / Dropitem "RLUniqueWeaponSpawner",24
		//     -- DRLA cross-mod drops stripped
		Tag "Baron from Abyss";
	}
	States
	{
	Spawn:
		CUTH A 0;
		Goto Scripted;
	Scripted:
		CUTH A 1;   // CH: ACS_NamedExecuteAlways("AnnounceBaronBlack") -- announcer stripped
		Goto Idle;
	Idle:
		CUTH DD 6 A_Look();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CUTH ABCD 6 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		CUTH E 0 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CUTH E 4 A_PlaySound("deepone/meleegrowl");
		CUTH F 4 A_FaceTarget();
		CUTH G 2 A_CustomMeleeAttack(random(42,99),"monster/kntswg","skeleton/swing");
		CUTH HI 2;
		CUTH I 0 A_Jump(128,"Missile");
		Goto See;
	Missile:
		CUTH J 0 A_JumpIfCloser(32,"Melee");
		CUTH J 0 A_JumpIfHealthLower(4500,"AggroUP");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CUTH J 0 A_Jump(255,"Basic","BeamThing","TentacleBashers");
		Goto See;
	TentacleBashers:
		CUTH I 8 A_PlaySound("deepone/active");
		CUTH IIII 2 Bright A_SpawnItemEx("RS_RoseTentacle",0,random(-65,66),random(-65,66),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		CUTH L 8;
		CUTH H 5;
		Goto See;
	TentacleRangers:
		CUTH F 12 A_PlaySound("deepone/active");
		CUTH II 2 Bright A_SpawnItemEx("RS_DeepTentacle",0,random(-65,66),random(-65,66),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		CUTH L 8;
		CUTH H 5 A_Jump(88,"TentacleBashers");
		Goto See;
	Beamthing:
		CUTH J 4 A_FaceTarget();
		CUTH J 1 Bright A_CustomMissile("RS_DeepCharge1",42,25);
		CUTH K 18 Bright A_FaceTarget();
		CUTH K 0 A_CustomRailgun(random(25,75),25,"white","white",RGF_FULLBRIGHT,1,0,"RS_DeepBeam1",0,0,0,35,0.1,0.1,"RS_DeepBeam1",0,0);
		CUTH K 8 Bright A_CheckSight("See");
		CUTH K 0 A_Jump(88,"BeamThing");
		Goto See;
	Basic:
		CUTH J 8 A_FaceTarget();
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,20);
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,5,random(-13,-5));
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,35,random(5,13));
		CUTH K 8 Bright;
		CUTH K 0 A_CheckSight("See");
		CUTH K 0 A_Jump(168,"Basic");
		Goto See;
	Basic2:
		CUTH J 8 A_FaceTarget();
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,20);
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,5,random(-13,-5));
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,35,random(5,13));
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,-5,random(-20,-13));
		CUTH K 0 A_CustomMissile("RS_DeepOneBall",42,45,random(13,20));
		CUTH K 8 Bright;
		CUTH K 0 A_CheckSight("See");
		CUTH K 0 A_Jump(168,"Basic2");
		Goto See;
	AggroUp:
		CUTH D 0 A_JumpIf(user_uhoh >= 1, "Nah");
		CUTH DDDDD 1 Bright A_CustomMissile("RS_DeepCharge1",random(5,76),random(-88,88));
		CUTH D 1 Bright { bNOPAIN = true; }            // CH: A_ChangeFlag("NoPain",TRUE)
		CUTH D 1 Bright { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("Missileevenmore",TRUE)
		CUTH D 1 Bright A_SetSpeed(17);
		CUTH D 8 Bright A_PlaySound("deepone/pain");
		CUTH D 1 { user_uhoh += 1; }   // CH: A_SetUserVar("User_uhoh",User_uhoh+1)
		CUTH D 0 A_SpawnItemEx("RS_DeepTentacle",0,88,-88,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		CUTH D 2 A_SpawnItemEx("RS_DeepTentacle",0,-88,88,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		Goto See;
	Nah:
		CUTH J 0 A_Jump(255,"Basic2","BeamThing","TentacleBashers","TentacleRangers");
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CUTH L 2;
		CUTH L 2 A_Pain();
		Goto See;
	Death:
		CUTH M 0 A_Jump(128,"AltDeath");
		CUTH M 10;
		CUTH N 10 A_Scream();
		CUTH O 10;
		CUTH P 10 A_NoBlocking();
		CUTH Q -1;
		Stop;
	AltDeath:
		CUTH R 5;
		CUTH S 5 A_Scream();
		CUTH T 5;
		CUTH U 5 A_NoBlocking();
		CUTH V 5;
		CUTH W -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black Baron's minions -- summoned, so NO tier token.
// CH: Barons.txt:4061 and :4268.
// ---------------------------------------------------------------------------
class RS_DeepTentacle : Actor   // CH Barons.txt:4061
{
	Default
	{
		Obituary "%o was tentacle stared";
		Health 500;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Radius 40;
		Height 112;
		Scale 0.75;
		Mass 0x7FFFFFFF;   // CH: [Blue Shadow] "infinite" mass
		Species "BaronOfHell";
		PainChance 96;
		SeeSound "monster/tensit";
		PainSound "monster/tenpai";
		DeathSound "monster/tendth";
		ActiveSound "monster/tenact";
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+LOOKALLAROUND
		+THRUSPECIES
		+NOTARGET
		+MISSILEEVENMORE
		-NORADIUSDMG
		Translation "231:231=112:112","161:162=115:117","163:165=119:122","166:167=125:127","16:31=98:109","32:42=105:111","43:46=9:11","47:47=0:0","255:255=103:103","65:76=100:105","128:134=96:101","144:151=104:111";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 174;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 44;
	}
	States
	{
	Spawn:
		TNT1 R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		TNT1 R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		TNT1 R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		TNT1 R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		TNT1 R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		TNT1 R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		TNT1 A 10 A_Look();
		Loop;
	See:
		TEN1 ABCD 4;
	SeeLoop:
		TEN1 EFGH 4 A_Chase();
		Loop;
	Missile:
		TEN1 F 5 A_FaceTarget();
		TNT1 A 0 A_Jump(96,"Missile2");
	Missile1:
		TEN1 I 8 A_FaceTarget();
		TEN1 J 9 Bright A_CustomMissile("RS_TentacleBall1",100);
		TEN1 I 8 A_FaceTarget();
		TEN1 J 9 Bright A_CustomMissile("RS_TentacleBall1",100);
		TEN1 I 8 A_FaceTarget();
		TEN1 J 9 Bright A_CustomMissile("RS_TentacleBall1",100);
		TEN1 I 8;
		Goto SeeLoop;
	Missile2:
		TEN1 I 8 A_FaceTarget();
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",10);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",20);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",30);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",40);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",50);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",60);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",70);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",80);
		TNT1 A 0 A_CustomMissile("RS_TentacleBall2",90);
		TEN1 K 9 Bright A_CustomMissile("RS_TentacleBall2",100);
		Goto SeeLoop;
	Pain:
		TEN1 L 3;
		TEN1 L 3 A_Pain();
		Goto SeeLoop;
	Death:
		TEN1 M 4;
		TEN1 N 4 A_Scream();
		TEN1 O 4 A_NoBlocking();
		TEN1 PQRS 4;
		TEN1 T -1;
		Stop;
	Raise:
		TEN1 ABCD 4;
		Goto SeeLoop;
	}
}

// CH's See and Melee both jump by numeric offset (Goto See+30, Goto Melee+17,
// A_Jump(64,6)), so every state entry below is transcribed one-for-one.
class RS_RoseTentacle : Actor   // CH Barons.txt:4268
{
	Default
	{
		Height 64;
		Radius 20;
		Speed 22;
		Health 50;
		Mass 5000;
		MeleeDamage 3;
		Species "BaronOfHell";
		MeleeRange 52;
		BloodColor "0 50 0";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance 128;
		Translation "64:79=112:127","144:151=118:127","236:239=124:127","164:167=124:127","40:47=121:127","13:15=125:127";
		Monster;
		-SHOOTABLE
		-SOLID
		-COUNTKILL
		+NOTARGETSWITCH
		+THRUSPECIES
		+NOICEDEATH
		+FLOORCLIP
		+LOOKALLAROUND
		HitObituary "%o was tentacle styled";
		DropItem "HealthBonus", 88;
		DropItem "RS_implyingclip", 78;
		DropItem "RS_CH_Shell", 42;
		DropItem "RS_CH_Cell", 24;
		DropItem "RS_CH_RocketAmmo", 12;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_UnsetShootable();
		TNT1 A 0 A_UnsetSolid();
		ROSX RST 4 A_Look();
		Loop;
	See:
		ROSX RS 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX TR 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX ST 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX RS 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX TR 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX ST 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX RS 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX TR 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX ST 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX RS 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX TR 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX ST 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX RS 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX TR 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX ST 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX RS 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX TR 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX ST 3 A_Chase();
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		Goto Melee;
	Melee:
		TNT1 A 0 A_SetShootable();
		TNT1 A 0 A_SetSolid();
		ROSX RQ 4;
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),128);
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),128);
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),128);
		ROSX P 4 A_MeleeAttack();
		ROSX ONMLABC 4;
		ROSX D 0 A_FaceTarget();
		ROSX D 3 A_MeleeAttack();
		ROSX A 0 A_Jump(64,6);
		ROSX EF 5;
		ROSX G 0 A_FaceTarget();
		ROSX G 3 A_MeleeAttack();
		ROSX G 0 A_CPosRefire();
		Goto Melee+17;
		ROSX JKL 4;
		ROSX H 3 A_MeleeAttack();
		ROSX H 0 A_CPosRefire();
		Goto Melee+17;
	Pain:
		ROSX LMNOPQR 3;
		TNT1 A 0 A_UnSetSolid();
		TNT1 A 0 A_UnsetShootable();
		Goto See+30;
	Death:
		ROSX U 5;
		ROSX V 5 A_Scream();
		ROSX W 5 A_Fall();
		ROSX XRR 5;
		ROSX RRRRRRRRR 2 A_FadeOut(0.1);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White ("Hell's Slice and Dicer").  CH: Barons.txt:4646.
// ---------------------------------------------------------------------------
class RS_WhiteBaron2 : Actor   // CH Barons.txt:4646
{
	int user_rude;   // CH: var int user_rude
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "%o fell to the power of White Baron";
		HitObituary "%o was sliced to pieces by White Baron";
		Species "BaronOfHell";
		Health 13069;
		Radius 24;
		Height 64;
		Mass 500;
		YScale 0.65;
		XScale 0.65;
		Speed 32;
		BloodColor "Black";
		DamageFactor "Melee", 0.5;
		DamageFactor "Fire", 0.5;
		DamageFactor "plasma", 0.5;
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 1.25;   // CH lists ice twice, both 1.25
		DamageFactor "DIMp", 0;
		RadiusDamageFactor 0.25;
		PainChance "DIMp", 0;
		PainChance 42;
		Damage 5;
		SeeSound "Obsidian/Alert";
		PainSound "Obsidian/Pain";
		DeathSound "Obsidian/Death";
		ActiveSound "Obsidian/Idle";
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+THRUSPECIES
		+BOSS
		+DONTHARMCLASS
		+MISSILEMORE
		+MISSILEEVENMORE
		+QUICKTORETALIATE
		-NORADIUSDMG
		+DONTHARMSPECIES
		+NOFEAR
		+NOINFIGHTING
		+NOTARGET
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		// CH: DropItem "BackBundle" -- class defined NOWHERE in the CH tree
		//     (dropped here only, never declared). Itemised, not silently
		//     gutted; restore if CH's source turns up. NOTE: CH's real bundle
		//     is "BackPackBundle" (DECORATE.txt:161), which we DO ship as
		//     RS_BackPackBundle -- but substituting it would be an invention,
		//     so the line stays absent exactly as it behaves in CH.
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_BlueArmor";
		// CH: DropItem "RLOnyxModItem" / Dropitem "RareArmorPool",128 /
		//     Dropitem "RLDemonicWeaponSpawner",128 /
		//     Dropitem "RLLegendaryWeaponSpawner",32 /
		//     Dropitem "RLUniqueWeaponSpawner",64 -- DRLA cross-mod drops stripped
		Tag "Hell's Slice and Dicer";
		Translation "1:4=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","5:10=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","13:15=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","36:37=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","47:63=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","18:21=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","28:31=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","32:35=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","38:41=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","43:43=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","11:11=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","16:16=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","23:23=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","25:25=%[0.00,0.00,0.00]:[2.00,2.00,2.00]";
	}
	States
	{
	Spawn:
		VSTL I 1;
		Goto Scripted;
	Scripted:
		VSTL A 1;
		VSTL A 2;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteBaron") -- announcer stripped
		Goto Idle;
	Idle:
		VSTL IJK 8 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSMT A 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		BSMT A 0 A_UnSetReflectiveInvulnerable();
		BSMT A 0 A_ScaleVelocity(1);
		BSMT A 0 A_SetSpeed(28);
		BSMT A 0 A_CheckBlock("Reposition",CBF_NOLINES);
		VSTL ABCD 5 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL EFGH 5 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128,"See2");
		Loop;
	See2:
		VSTL ABCD 5 A_FastChase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL EFGH 5 A_FastChase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128,"See2");
		Goto See;
	Reposition:
		VSTL O 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		VSTL P 12 Radius_Quake(6,100,2,64,8);
		VSTL P 1 A_SetTranslucent(0.5);
		VSTL P 1 A_SetTranslucent(0.3);
		VSTL P 1 A_SetTranslucent(0.1);
		VSTL P 1 A_SetTranslucent(0);
		VSTL O 0 { bFLOAT = true; }        // CH: A_ChangeFlag("Float",TRUE)
		VSTL O 0 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		VSTL O 0 A_SetFloatSpeed(42);
		VSTL O 0 A_SetSpeed(64);
		VSTL OOOOOO 1 A_Wander();
		VSTL O 0 { bFLOAT = false; }        // CH: A_ChangeFlag("Float",FALSE)
		VSTL O 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		VSTL O 0 A_SetFloatSpeed(18);
		VSTL O 0 A_SetSpeed(32);
		VSTL P 1 A_SetTranslucent(0.1);
		VSTL P 1 Radius_Quake(6,100,2,64,8);
		VSTL P 1 A_SetTranslucent(0.3);
		VSTL P 1 A_SetTranslucent(0.5);
		VSTL P 1 A_SetTranslucent(0.7);
		VSTL P 1 A_SetTranslucent(1);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL P 8;
		VSTL O 0 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		Goto See;
	Melee:
		VSTL L 1 A_FaceTarget();
		VSTL L 1 A_PlaySound("Obsidian/Swipe");
		VSTL L 4 A_FaceTarget();
		VSTL M 6 A_FaceTarget();
		VSTL NNN 2 A_Recoil(-12);
		VSTL O 8 A_CustomMeleeAttack(random(10,15)*7,"Obsidian/Melee");
		VSTL P 7 A_Jump(128,"Slice1","Slice2","Slice3");
		Goto See;
	Missile:
		VSTL U 5 A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL QR 5 A_FaceTarget();
		TNT1 A 0 A_JumpIfCloser(800,"Dash");
	Missile2:
		VSTL S 8 A_PlaySound("Obsidian/Attack");
		VSTL T 5 A_FaceTarget();
		TNT1 A 0 A_Jump(64,"SliceHoming","Stars","Spikes","FloorCrack");
		TNT1 A 0 A_Jump(252,"Slice1","Slice2","Slice3","SpinSlice","SliceHoming","Stars","Spikes","FloorCrack");
		Goto See;
	FloorCrack:
		VSTL R 8 A_FaceTarget();
		VSTL PPP 3 A_CustomMissile("RS_WhiteBaronGround",32,0,randompick(16,8,0,-8,-16));
		TNT1 A 0 A_Jump(252,"Slice1","Slice2","Slice3","SpinSlice","SliceHoming","Stars","Spikes");
		Goto See;
	Spikes:
		VSTL R 5 A_FaceTarget();
		VSTL P 8 A_VileTarget("RS_VileGroundSpikeBrown");
		TNT1 A 0 A_Jump(252,"Slice1","Slice2","Slice3","SpinSlice","SliceHoming","Stars","FloorCrack");
		Goto See;
	Stars:
		VSTL R 8 A_FaceTarget();
		VSTL P 8 A_CustomMissile("RS_WhiteBaronStar",42,0);
		VSTL P 0 A_CustomMissile("RS_WhiteBaronStar",42,16);
		VSTL P 0 A_CustomMissile("RS_WhiteBaronStar",42,-16);
		VSTL R 8 A_FaceTarget();
		VSTL P 8 A_CustomMissile("RS_WhiteBaronStar",42,0);
		VSTL P 0 A_CustomMissile("RS_WhiteBaronStar",42,16);
		VSTL P 0 A_CustomMissile("RS_WhiteBaronStar",42,-16);
		TNT1 A 0 A_Jump(64,"SliceHoming","Stars");
		TNT1 A 0 A_Jump(252,"Slice1","Slice2","Slice3","SpinSlice","SliceHoming","Stars","FloorCrack","Spikes");
		Goto See;
	SliceHoming:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",48,28);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",32,14);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",26,-2);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",18,-14);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",2,-28);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",48,-28);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",32,-14);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",26,2);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSliceHoming",18,14);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSliceHoming",2,28);
		VSTL O 8;
		VSTL P 7;
		Goto See;
	Dash:
		TNT1 A 0 A_Jump(128,"Missile2");
		TNT1 A 0 A_PlaySound("Ice/Fly");
		VSTL T 5 A_SkullAttack(35);
		VSTL L 5 A_Recoil(-20);
		VSTL L 5 A_JumpIfCloser(200,"SpinSlice");
		VSTL L 5 A_JumpIfCloser(250,"SpinSlice");
		VSTL L 5 A_JumpIfCloser(300,"SpinSlice");
		VSTL L 5 A_JumpIfCloser(250,"SpinSlice");
		VSTL L 5 A_JumpIfCloser(200,"SpinSlice");
		VSTL T 5;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL T 5 A_Stop();
		VSTL T 5 A_Jump(128,"Slice1","Slice2","Slice3");
		Goto See;
	Slice1:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",48,24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",40,16);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,8);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",26,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",18,-8);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",10,-16);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSlice",2,-24);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",48,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",40,-16);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-8);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",26,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",18,8);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",10,16);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSlice",2,24);
		VSTL O 12;
		VSTL P 10;
		Goto See;
	Slice2:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",44,44);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",42,33);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",40,22);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",38,11);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",36,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",34,-11);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSlice",32,-22);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",44,-44);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",42,-33);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",40,-22);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",38,-11);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",36,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",34,11);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSlice",32,22);
		VSTL O 12;
		VSTL P 10;
		Goto See;
	Slice3:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,44,-4);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,33,-2);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,22);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,11,2);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,0,4);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-11,6);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSlice",32,-22,8);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL M 6 A_FaceTarget();
		VSTL N 4;
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,44,4);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,33,2);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,22);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,11,-2);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,0,-4);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-11,-6);
		VSTL N 4 A_CustomMissile("RS_WhiteBaronSlice",32,-22,-8);
		VSTL O 12;
		VSTL P 10;
		Goto See;
	SpinSlice:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 6 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-30);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,24);
		VSTL N 2 A_CustomMissile("RS_WhiteBaronSlice",32,1,30);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 2 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-30);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,24);
		VSTL N 2 A_CustomMissile("RS_WhiteBaronSlice",32,1,30);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 2 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-30);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,24);
		VSTL N 2 A_CustomMissile("RS_WhiteBaronSlice",32,1,30);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 2 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-30);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,24);
		VSTL N 2 A_CustomMissile("RS_WhiteBaronSlice",32,1,30);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 2 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-30);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,24);
		VSTL N 2 A_CustomMissile("RS_WhiteBaronSlice",32,1,30);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL L 4 A_FaceTarget();
		VSTL M 2 A_FaceTarget();
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-30);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-24);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,-12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,-6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,0);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,6);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,12);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,18);
		VSTL N 0 A_CustomMissile("RS_WhiteBaronSlice",32,1,24);
		VSTL N 2 A_CustomMissile("RS_WhiteBaronSlice",32,1,30);
		VSTL O 12;
		VSTL P 10;
		Goto See;
	Pain:
		VSTL W 4;
		VSTL X 4 A_Pain();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VSTL YZ 4;
		Goto See;
	Death:
		VSTK A 8;
		VSTK B 8 A_Scream();
		VSTK C 8;
		VSTK D 8 A_NoBlocking();
		VSTK E 8;
		VSTK F -1;
		Stop;
	}
}
