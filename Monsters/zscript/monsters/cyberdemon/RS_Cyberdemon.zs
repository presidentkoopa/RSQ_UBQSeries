// ============================================================================
// RS_Cyberdemon.zs -- Colourful Hell CYBIES family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\CYBIES.txt (6,285 lines, read
// whole -- the largest CH family, 140 actors). Every actor cites its CH line.
// Support: RS_CyberdemonFX.zs (see its header for cross-lane ownership,
// expected-from-Archviles names, proven-missing assets, and standing strips).
//
// Tier ladder is CH's own icon index: 1 Common, 2 Green, 3 Blue, 4 Purple,
// 5 Yellow, 6 Red, 7 FireBlu, 8 Gray, 9 Abyss, 10 Black, 11 White, 12 Cyan,
// 13 Brown. RS_SpecialHK, RS_RomeroBaronsCH and RS_MolochWraith are summoned
// minions and get no token.
//
// LANDING THIS FAMILY CLOSES A DORMANT GUARD:
//   RS_MolochWraith is named as a runtime DropItem inside RS_PortalSummons
//   (zscript/monsters/cacodemon/RS_CacodemonFX.zs) and did not exist until
//   now. CH MolochWraith (CYBIES.txt:3692) -> RS_MolochWraith below, by the
//   mechanical naming rule. That cacodemon file is NOT touched from here.
//   RS_RedCybieSouls (RS_CyberdemonFX.zs) and RS_SummonPortalCybie's
//   pain-attack both reach it as well, so it now has three live callers.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: CYBIES.txt:1 -- Colourset16 replaces CyberDemon.
// ---------------------------------------------------------------------------
class RS_Colourset16 : RandomSpawner replaces Cyberdemon
{
	Default
	{
		DropItem "RS_CommonCybie", 255, 419;
		DropItem "RS_GreenCybie", 255, 250;
		DropItem "RS_CyanCybie", 255, 90;
		DropItem "RS_BlueCybie", 255, 100;
		DropItem "RS_PurpleCybie", 255, 45;
		DropItem "RS_FireBluCybie", 255, 33;
		DropItem "RS_GrayCybie", 255, 25;
		DropItem "RS_BrownCybie", 255, 66;
		DropItem "RS_YellowCybie", 255, 20;
		DropItem "RS_AbyssCybie", 255, 25;
		DropItem "RS_RedCybie", 255, 15;
		DropItem "RS_BlackCybie", 255, 5;
		DropItem "RS_WhiteCybie", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs. CH semantics: 1 = colour off (reroll into the main set,
// CH's default), 3 = fifty-fifty, anything else = the colour spawns.
// CH gives the CYBIES gates a full monster flag block and a BossDeath state
// (unlike some earlier families' gates); carried verbatim, loops and all.
// ---------------------------------------------------------------------------
class RS_BrownCybie : Actor   // CH CYBIES.txt:18 -- gate CH_Brown
{
	Default
	{
		Monster;
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
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
		TNT1 A 0 A_Jump(128,"Third");
	First:
		TNT1 A 30 A_SpawnItemEx("RS_Colourset16",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 30 A_SpawnItemEx("RS_BrownCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

class RS_CyanCybie : RS_BrownCybie   // CH CYBIES.txt:737 -- gate CH_Cyan
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
		TNT1 A 0 A_Jump(128,"Third");
	First:
		TNT1 A 0 A_SpawnItemEx("RS_Colourset16",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

class RS_AbyssCybie : RS_BrownCybie   // CH CYBIES.txt:1060 -- gate CH_Abyssmal
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
		TNT1 A 0 A_Jump(128,"Third");
		Goto First;
	First:
		TNT1 A 30 A_SpawnItemEx("RS_Colourset16",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 30 A_SpawnItemEx("RS_AbyssCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

class RS_GrayCybie : RS_BrownCybie   // CH CYBIES.txt:1528 -- gate CH_Grayscale
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
		TNT1 A 30 A_SpawnItemEx("RS_Colourset16",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 30 A_SpawnItemEx("RS_GrayCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

class RS_FireBluCybie : RS_BrownCybie   // CH CYBIES.txt:1897 -- gate CH_FireBLUES
{
	Default
	{
		+SPECTRAL
		+LAXTELEFRAGDMG
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_fireblu', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 3 A_SpawnItemEx("RS_Colourset16",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 3 A_SpawnItemEx("RS_FireBluCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

class RS_BlackCybie : RS_BrownCybie   // CH CYBIES.txt:4032 -- gate CH_BlackBossy
{
	Default
	{
		+SPECTRAL
		+LAXTELEFRAGDMG
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_blackboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 3 A_SpawnItemEx("RS_BlackCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done2:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 3 A_SpawnItemEx("RS_RedCybie",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
	Done:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

class RS_WhiteCybie : RS_BrownCybie   // CH CYBIES.txt:5170 -- gate CH_WhiteBossy
{
	Default
	{
		+SPECTRAL
		+LAXTELEFRAGDMG
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_whiteboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteCybie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
		TNT1 A 3;
	Done2:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCybie",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER);
		TNT1 A 3;
	Done:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TNT1 A 3 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown Cybie ("ComposterDemon").  CH: CYBIES.txt:69.
// ---------------------------------------------------------------------------
class RS_BrownCybie2 : Actor   // CH CYBIES.txt:69
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Species "Cybie";
		Obituary "%o was recycled into mulch by brown cybie";
		Health 7557;
		Radius 40;
		Height 110;
		Mass 5000;
		Speed 17;
		SeeSound "BROCYBHI";
		PainSound "BROCYBHU";
		DeathSound "BROCYBDD";
		ActiveSound "cyber/active";
		Translation "32:47=112:127","168:191=112:127";
		YScale 1.33;
		XScale 1.25;
		DropItem "RS_CH_SoulSphere";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "RS_CH_GreenArmor";
		RadiusDamageFactor 0.25;
		DamageFactor "PLWater", 1.25;
		DamageFactor "poison", 0.1;
		DamageFactor "Plasma", 0.70;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "poison", 0;
		PainChance 12;
		PainThreshold 200;
		Monster;
		+BOSS
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+FULLVOLDEATH
		+FULLVOLACTIVE
		+MISSILEMORE
		+DONTHARMCLASS
		+NOFEAR
		Tag "ComposterDemon";
	}
	States
	{
	Spawn:
		SUPR A 0;
	KillIt:
		TNT1 A 0;
		Goto Idle;
	Idle:
		8CYB AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		8CYB A 3 A_PlaySound("brownCybie/step",0);
		TNT1 AA 0 A_SpawnItemEx("RS_Splash11",random(-12,12),random(-8,8),random(24,82));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		8CYB ABBCC 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_Splash11",random(-12,12),random(-8,8),random(24,82));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		8CYB D 3 A_PlaySound("brownCybie/step",0);
		8CYB D 3;
		TNT1 AA 0 A_SpawnItemEx("RS_Splash11",random(-12,12),random(-8,8),random(24,82));
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		8CYB A 1 A_JumpIfCloser(1200,"FirstChoice");
	ClassicShot:
		TNT1 A 0 A_Jump(32,"PoolOfGoo");
		8CYB E 2 A_PlaySound("BROCYBA1",0);
		8CYB FFF 0 A_SpawnItemEx("RS_Splash11",random(-8,8),random(2,8),random(48,64),random(2,9),0,random(-3,3),random(-25,25));
		8CYB E 10 A_FaceTarget;
		8CYB FFF 0 A_CustomMissile("RS_GreenBalb2",random(61,63),random(-10,-7),random(-12,12),0,random(-3,3));
		8CYB FFFF 0 A_SpawnItemEx("RS_GreenBalb2",random(-8,8),random(12,18),random(48,64),random(8,33),0,random(1,4),random(-15,15));
		8CYB F 10 Bright A_CustomMissile("RS_BrownCybBasic",66,-15,random(-1,1));
		8CYB E 5 A_FaceTarget;
		8CYB FFF 0 A_CustomMissile("RS_GreenBalb2",random(61,63),random(-10,-7),random(-12,12),0,random(-3,3));
		8CYB FFFF 0 A_SpawnItemEx("RS_GreenBalb2",random(-8,8),random(12,18),random(48,64),random(8,33),0,random(1,4),random(-15,15));
		8CYB F 8 Bright A_CustomMissile("RS_BrownCybBasic",66,-15,random(-4,4));
		8CYB E 5 A_FaceTarget;
		8CYB FFF 0 A_CustomMissile("RS_GreenBalb2",random(61,63),random(-10,-7),random(-12,12),0,random(-3,3));
		8CYB FFFF 0 A_SpawnItemEx("RS_GreenBalb2",random(-8,8),random(12,18),random(48,64),random(8,33),0,random(1,4),random(-15,15));
		8CYB F 8 Bright A_CustomMissile("RS_BrownCybBasic",66,-15,random(-12,12));
		8CYB EA 12;
		Goto See;
	FirstChoice:
		TNT1 A 0 A_JumpIfCloser(600,"BigBoom");
		TNT1 A 0 A_Jump(255,"PoolOfGoo","PoolOfDrill","ClassicShot");
		Goto See;
	PoolOfGoo:
		8CYB A 2 A_FaceTarget;
		8CYB E 2 A_PlaySound("BROCYBA2",0);
		8CYB FGI 10 Bright;
		8CYB FFFFFFFFFFFFF 0 A_SpawnItemEx("RS_Splash11",random(4,8),random(-8,8),random(48,128),random(2,9),0,random(1,7),random(-25,25));
		8CYB FFFFFFFFFFFFF 0 A_SpawnItemEx("RS_Splash11",random(4,8),random(-8,8),random(48,128),random(2,9),0,random(1,7),random(-5,5));
		8CYB FFFFFFFFFFFFF 0 A_SpawnItemEx("RS_Splash11",random(4,8),random(-8,8),random(48,128),random(2,9),0,random(1,7),random(-25,25));
		8CYB FFFFFFFFFFFFF 0 A_SpawnItemEx("RS_Splash11",random(4,8),random(-8,8),random(48,128),random(2,9),0,random(1,7),random(-5,5));
		TNT1 A 0 A_VileTarget("RS_BCybAcidPuddle");
		8CYB HE 8 Bright;
		Goto See;
	PoolOfDrill:
		8CYB A 2 A_FaceTarget;
		8CYB E 2 A_PlaySound("BROCYBA1",0);
		8CYB F 10 Bright A_SpawnItemEx("RS_BCybieGreenWave",0,0,8,0,0,0,0,SXF_NOCHECKPOSITION);
		8CYB GI 10 Bright;
		8CYB K 0 A_CustomMissile("RS_BCybSlimeSet",32,0,0);
		8CYB K 0 A_CustomMissile("RS_BCybSlimeSet",32,0,random(12,20));
		8CYB K 0 A_CustomMissile("RS_BCybSlimeSet",32,0,random(-20,-12));
		8CYB K 0 A_CustomMissile("RS_BCybSlimeSet",32,0,random(20,45));
		8CYB K 0 A_CustomMissile("RS_BCybSlimeSet",32,0,random(-45,-20));
		8CYB HE 8 Bright;
		Goto See;
	Melee:
	BigBoom:
		8CYB A 1 A_RadiusGive("RS_BrCybCheck",500,RGF_PLAYERS|RGF_NOSIGHT,1);
		TNT1 A 0 A_JumpIfInTargetInventory("RS_BrCybCheck",1,"YesBoom");
		TNT1 A 0 A_Jump(255,"PoolOfDrill","ClassicShot");
		Goto Missile;
	YesBoom:
		8CYB A 5 A_FaceTarget;
		TNT1 A 0 A_PlaySound("BROCYBA2",0);
		TNT1 A 0 A_SpawnItemEx("RS_BCybieGreenExpand",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		8CYB GHIJK 5 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_BCybieGreenExpand",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		8CYB K 1 Bright { bNOPAIN = true; }   // CH: a_changeflag("NOPAIN",true)
		// The BRCybGren*/BBEASTEX5/BBCybGren06 names below are CH
		// translations; only BBEASTEX5 exists in this repo's TRNSLATE.txt.
		// See the FX file header. BBCybGren06 is CH's own typo for
		// BRCybGren06 (CH TRNSLATE.txt:17); kept as CH wrote it.
		8CYB K 5 Bright A_SetTranslation("BRCybGren01");
		8CYB K 5 Bright A_SetTranslation("BRCybGren02");
		TNT1 A 0 A_SpawnItemEx("RS_BCybieGreenExpand",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		8CYB K 5 Bright A_SetTranslation("BRCybGren03");
		8CYB K 5 Bright A_SetTranslation("BRCybGren04");
		8CYB K 5 Bright A_SetTranslation("BRCybGren05");
		8CYB K 3 Bright A_SpawnItemEx("RS_BCybieGreenWave",0,0,8,0,0,0,0,SXF_NOCHECKPOSITION);
		8CYB K 9 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("brownCybie/DeepShot",0);
		8CYB K 0 A_SpawnItemEx("RS_BCybExplosionSet2",32,0,16,0,0,0,0,SXF_SETMASTER);
		8CYB K 0 A_SpawnItemEx("RS_BCybExplosionSet",32,0,16,0,0,0,0,SXF_SETMASTER);
		8CYB K 0 A_SpawnItemEx("RS_BCybExplosionSet3",0,0,16,18,0,0,0);
		8CYB K 0 A_SpawnItemEx("RS_BCybExplosionSet3",0,0,16,18,0,0,90);
		8CYB K 0 A_SpawnItemEx("RS_BCybExplosionSet3",0,0,16,18,0,0,180);
		8CYB K 0 A_SpawnItemEx("RS_BCybExplosionSet3",0,0,16,18,0,0,270);
		TNT1 A 0 A_SpawnItemEx("RS_BCybieGreenExpand",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		8CYB K 10 Bright A_SetTranslation("BRCybGren04");
		8CYB K 10 Bright A_SetTranslation("BRCybGren02");
		8CYB K 10 Bright A_SetTranslation("BBEASTEX5");
		8CYB K 10 Bright A_SetTranslation("BBCybGren06");
		8CYB JIHG 8 Bright;
		8CYB A 15 Bright { bNOPAIN = false; }   // CH: a_changeflag("NOPAIN",False)
		TNT1 A 0 A_Jump(64,"PoolOfGoo","PoolOfDrill","ClassicShot");
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		8CYB A 15 A_Pain;
		Goto See;
	Death:
		TNT1 A 0 { bDONTBLAST = true; }    // CH: A_changeflag("dontblast",true)
		TNT1 A 0 { bDONTTHRUST = true; }   // CH: A_changeflag("dontthrust",true)
		8CYB G 1 A_NoBlocking;
		8CYB HHHI 8 A_SpawnItemEx("RS_BCybieGreenWave2",random(-16,16),random(-16,16),random(8,78),0,0,0,0);
		8CYB IIIIJJJJ 7 A_SpawnItemEx("RS_BCybieGreenWave2",random(-16,16),random(-16,16),random(8,78),0,0,0,0);
		8CYB KKKKKKKKKKK 3 A_SpawnItemEx("RS_BCybieGreenWave2",random(-16,16),random(-16,16),random(8,78),0,0,0,0);
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TNT1 A 0 A_Scream;
		CYBR LMNO 6 A_SpawnItemEx("RS_GreenBalb2",random(-8,8),random(-8,8),random(48,64),random(2,9),0,random(1,4),random(0,359));
		CYBR P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan Cybie ("Akinator").  CH: CYBIES.txt:788.
// ---------------------------------------------------------------------------
class RS_CyanCybie2 : Actor   // CH CYBIES.txt:788
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 8083;
		Radius 40;
		Height 110;
		Speed 31;
		FloatSpeed 31;
		BloodColor "cyan";
		Species "Cybie";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		RadiusDamageFactor 0.5;
		DamageFactor "Melee", 2.0;
		DamageFactor "Fire", 2.0;
		DamageFactor "Ice", 0.35;
		DamageFactor "PLWater", 0.5;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance 32;
		Mass 1000;
		Monster;
		+BOSS
		-NOGRAVITY
		-FLOAT
		-FLOATBOB
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+BRIGHT
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "cyber/sight";
		PainSound "AbyCyb/Pain";
		ActiveSound "abydogac";
		DeathSound "cyber/death";
		Obituary "%o took a trip to northpole, thanks Cyan Cybie!";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 32;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_SoulSphere", 64;
		// CH: DropItem "RareArmorPool",64 (CYBIES.txt:839) -- DRLA cross-mod
		// drop, stripped per the standing order.
		DropItem "RS_CH_BFG9000", 64;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		Tag "Akinator";
		Translation "96:111=%[0.00,0.00,1.01]:[1.01,2.00,2.00]","112:127=%[0.00,0.62,0.62]:[1.50,2.00,2.00]";
	}
	States
	{
	Spawn:
		CARD A 1;
		Goto Idle;
	Idle:
		CARD AB 4 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SUPS A 0 { bFLOAT = true; }       // CH: A_Changeflag("FLOAT",TRUE)
		SUPS A 0 { bFLOATBOB = true; }    // CH: A_Changeflag("FLOATBOB",TRUE)
		SUPS A 0 { bNOGRAVITY = true; }   // CH: A_Changeflag("NOGRAVITY",TRUE)
		TNT1 A 0 A_SetTranslation("CYANCYB02");
		TNT1 A 0 A_SpawnItemEx("RS_CyanCybieHower",0,0,46,0,0,-2,0,SXF_NOCHECKPOSITION);
		CARD AB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(12,"Dodge");
		TNT1 A 0 A_SpawnItemEx("RS_CyanCybieHower",0,0,42,0,0,-1,0,SXF_NOCHECKPOSITION);
		CARD AB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(12,"Dodge");
		Loop;
	Dodge:
		TNT1 A 0 A_SpawnItemEx("RS_CyanCybieHower",0,0,42,0,0,-2,0,SXF_NOCHECKPOSITION);
		CARD AB 3 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_CyanCybieHower",0,0,42,0,0,-1,0,SXF_NOCHECKPOSITION);
		CARD AB 3 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+3;
	PhaseBack:
		TNT1 AAAAAAAAAA 0 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,32,random(4,33),0,random(-25,25),random(0,135),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAA 0 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,32,random(4,33),0,random(-25,25),random(135,270),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAA 0 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,32,random(4,33),0,random(-25,25),random(270,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetTranslation("CYANCYB01");
		CARD D 8 ThrustThing(int(angle-randompick(180,200,160)),80,1,0);   // CH: thrustthing(angle-randompick(180,200,160),80,1,0)
		CARD D 8 ThrustThing(int(angle-random(120,240)),80,1,0);
		CARD D 8 ThrustThing(int(angle-random(80,280)),80,1,0);
		CARD D 8 ThrustThing(int(angle-randompick(20,0,40)),34,1,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CARD D 6 { bNOPAIN = true; }   // CH: A_changeflag(NOPAIN,TRUE)
		TNT1 A 0 A_SetTranslation("CYANCYB02");
		Goto See+3;
	Pain:
		CARD A 2 A_SetTranslation("CYANCYB01");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CARD A 2 A_Pain;
		CARD A 2 A_SetTranslation("CYANCYB02");
		Goto PhaseBack;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CARD B 0 A_JumpIfCloser(1500,"MissileBarrage");
	Sprayit:
		CARD C 6 A_FaceTarget;
		CARD C 4 A_CustomMissile("RS_CyanCybieGunFlare",72,-30,0);
		CARD C 1 A_FaceTarget;
		CARD DDDDDDDDDDDD 1 A_CustomMissile("RS_CyanCybieSprayIce",72,-30,random(-4,4),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD DDDDDDDDDDDD 0 A_CustomMissile("RS_CyanCybieSprayIce",72,-30,random(-4,4),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD DDDDDDDDDDDD 1 A_CustomMissile("RS_CyanCybieSprayIce",72,-30,random(-4,4),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD DDDDDDDDDDDD 0 A_CustomMissile("RS_CyanCybieSprayIce",72,-30,random(-4,4),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD C 1 A_FaceTarget;
		CARD DDDDDDDDDD 1 A_CustomMissile("RS_CyanCybieSprayIce",random(69,75),-30,random(-2,2),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD DDDDDDDDDD 0 A_CustomMissile("RS_CyanCybieSprayIce",random(69,75),-30,random(-2,2),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD DDDDDDDDDD 1 A_CustomMissile("RS_CyanCybieSprayIce",random(69,75),-30,random(-2,2),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD DDDDDDDDDD 0 A_CustomMissile("RS_CyanCybieSprayIce",random(69,75),-30,random(-2,2),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-4,4));
		CARD D 0 { bNOPAIN = false; }   // CH: A_changeflag(NOPAIN,FALSE)
		Goto See+3;
	MissileBarrage:
		CARD C 3 A_FaceTarget;
		CARD C 3 A_CustomMissile("RS_CyanCybieGunFlare",72,-30,0);
		CARD D 8 A_CustomMissile("RS_CyanCybieBigIce2",72,-30,0);
		CARD C 3 A_FaceTarget;
		CARD C 3 A_CustomMissile("RS_CyanCybieGunFlare",72,-30,0);
		CARD D 8 A_CustomMissile("RS_CyanCybieBigIce",72,-30,randompick(-5,5));
		CARD C 3 A_FaceTarget;
		CARD C 3 A_CustomMissile("RS_CyanCybieGunFlare",72,-30,0);
		CARD D 8 A_CustomMissile("RS_CyanCybieBigIce",72,-30,randompick(-15,15,7,0,-7));
		TNT1 A 0 A_Jump(32,"Sprayit");
		CARD C 3 A_FaceTarget;
		CARD C 3 A_CustomMissile("RS_CyanCybieGunFlare",72,-30,0);
		CARD D 8 A_CustomMissile("RS_CyanCybieBigIce3",72,-30,randompick(-15,15,7,0,-7));
		CARD D 0 { bNOPAIN = false; }   // CH: A_changeflag(NOPAIN,FALSE)
		Goto See;
	Death:
		CARD E 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag(FLOATBOB,0)
		CARD E 8 Bright;
		CARD F 8 Bright A_Scream;
		CARD G 8 Bright A_NoBlocking;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		CARD H 8 Bright;
		CARD I 8 Bright A_Explode;
		CARD JK 8 Bright;
		CARD L 8 Bright A_BossDeath;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,242);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss Cybie ("Unholy diver").  CH: CYBIES.txt:1112.
// ---------------------------------------------------------------------------
class RS_AbyssCybie2 : Actor   // CH CYBIES.txt:1112
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 12000;
		Species "Cybie";
		BloodColor "Black";
		Radius 40;
		Height 110;
		Mass 3000;
		Speed 15;
		PainChance 8;
		RadiusDamageFactor 0.33;
		DamageFactor "PLWater", 0.4;
		DamageFactor "Melee", 1.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Monster;
		+BOSS
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		+NOPAIN
		+NOFEAR
		YScale 1.45;
		XScale 1.15;
		Obituary "%o was turned into abyssal liquids by the abyss cybie.";
		SeeSound "ABYCYSEE";
		PainSound "AbyCyb/Pain";
		DeathSound "ABYCYDIE";
		ActiveSound "AbyCyb/Act";
		Translation "32:47=%[0.00,0.00,0.07]:[0.49,0.72,0.74]","16:31=%[0.16,0.24,0.31]:[0.36,0.71,0.72]","185:191=%[0.00,0.00,0.00]:[0.06,0.06,0.06]","80:95=%[0.05,0.15,0.17]:[0.50,0.31,0.76]","96:111=%[0.00,0.00,0.00]:[0.31,0.47,0.65]","168:191=0:0","160:167=96:111","224:231=96:111","48:63=96:111","249:249=3:3","64:79=0:2","208:223=0:0","232:235=0:0","248:248=0:0","4:4=2:2","13:15=0:0","236:239=0:0","3:3=0:0","128:143=0:0","1:2=0:0","5:8=0:0";
		Tag "Unholy diver";
		DropItem "RS_CH_SoulSphere";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_MegaSphere", 128;
		DropItem "RS_CH_GreenArmor";
		DropItem "RS_CH_GreenArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	KillIt:
		TNT1 A 0;
	Idle:
		TERM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TERM A 1 A_PlaySound("AbyCyb/step",0);
		TERM A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCybieDecoFlame",random(-16,16),random(-16,16),random(42,66),random(1,2),0,random(1,9),random(-359,359));
		TERM A 4 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(12,76),random(1,6),0,random(1,3),random(-359,359));
		TERM B 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCybieDecoFlame",random(-16,16),random(-16,16),random(42,66),random(1,2),0,random(1,9),random(-359,359));
		TERM B 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(12,76),random(1,6),0,random(1,3),random(-359,359));
		TERM C 1 A_PlaySound("AbyCyb/step",0);
		TERM C 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCybieDecoFlame",random(-16,16),random(-16,16),random(42,66),random(1,2),0,random(1,9),random(-359,359));
		TERM C 4 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(12,76),random(1,6),0,random(1,3),random(-359,359));
		TERM D 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCybieDecoFlame",random(-16,16),random(-16,16),random(42,66),random(1,2),0,random(1,9),random(-359,359));
		TERM D 4 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(12,76),random(1,6),0,random(1,3),random(-359,359));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Splash:
		TNT1 A 0 A_CheckSight("See");
		TNT1 AA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-8,128),random(-8,128),random(5,32),11,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"Missile");
		Goto See;
	Pain:
		TERM L 3 A_JumpIfHealthLower(6000,"Nomore");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TERM L 6 A_Pain;
		Goto See;
	Nomore:
		TERM L 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TERM L 2 { bNOPAIN = true; }            // CH: a_changeflag("NOPAIN",TRUE)
		TERM L 2 A_SetSpeed(20);
		TERM L 2 { bMISSILEEVENMORE = true; }   // CH: a_changeflag("Missileevenmore",TRUE)
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(64,1028),random(-128,128),random(5,32),11,0,2,random(-90,90),SXF_NOCHECKPOSITION);
		TERM E 0 A_Jump(255,"Bubble");
		TNT1 A 0 A_JumpIfCloser(300,"Wave");
		TNT1 A 0 A_JumpIfCloser(1500,"Choices");
	RedDed:
		TERM J 1 A_PlaySound("AbyCyb/Atk",0,2,false,ATTN_NONE);
		TERM J 18 Bright A_FaceTarget;
		TERM K 8 Bright A_CustomRailgun(random(20,80),-20,"white","white",RGF_NOPIERCING,0,0,"RS_WhiteFatRB3",0,0,0,0,0.4,1.0,"RS_WhiteFatRB4",1);
		TERM J 6;
		TERM J 1 A_Jump(64,"Rocket");
		Goto See;
	Wave:
		TERM E 1 A_PlaySound("AbyCyb/Atk",0);
		TERM EF 3 A_FaceTarget;
		TERM F 1 Bright A_CustomMissile("RS_AbyCybWave",32,30,random(5,25));
		TERM F 1 Bright A_CustomMissile("RS_AbyCybWave",44,0,random(-1,1));
		TERM F 1 Bright A_CustomMissile("RS_AbyCybWave",30,-30,random(-25,-5));
		TERM F 1 Bright A_CustomMissile("RS_AbyCybWave",24,0,random(-7,7));
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(12,32),random(-12,12),random(12,42),11,0,4,random(-15,15),SXF_NOCHECKPOSITION);
		TERM EF 2;
		TERM JK 3 A_FaceTarget;
		TERM K 1 Bright A_CustomMissile("RS_AbyCybWave",32,-30,random(10,30));
		TERM K 1 Bright A_CustomMissile("RS_AbyCybWave",44,0,random(-5,5));
		TERM K 1 Bright A_CustomMissile("RS_AbyCybWave",32,30,random(-30,-10));
		TERM K 1 Bright A_CustomMissile("RS_AbyCybWave",24,0,random(-10,10));
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(12,32),random(-12,12),random(12,42),11,0,4,random(-15,15),SXF_NOCHECKPOSITION);
		TERM KJ 2;
		TERM J 1 A_Jump(64,"Choices");
		Goto See;
	Choices:
		TERM E 0 A_Jump(255,"Bubble","Rocket","RedDed","Wave");
		Goto See;
	Rocket:
		TERM E 8 A_FaceTarget;
		TERM F 8 Bright A_CustomMissile("RS_AbyssCybRocket",38,15,0,0);
		TNT1 AA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(32,528),random(-68,68),random(5,32),11,0,2,random(-15,15),SXF_NOCHECKPOSITION);
		TERM E 8 A_FaceTarget;
		TERM F 8 Bright A_CustomMissile("RS_AbyssCybRocket",38,15,random(-8,8),0);
		TNT1 AA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(64,528),random(-68,68),random(5,32),11,0,2,random(-45,45),SXF_NOCHECKPOSITION);
		TERM E 8 A_FaceTarget;
		TERM F 8 Bright A_CustomMissile("RS_AbyssCybRocket",38,15,random(-15,15),0);
		TNT1 AA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(128,756),random(-68,68),random(5,32),11,0,2,random(-65,65),SXF_NOCHECKPOSITION);
		Goto See;
	Bubble:
		TERM G 2 A_FaceTarget;
		TERM H 1 Bright A_CustomMissile("RS_AbyCybBubProj",38,15,random(-9,0));
		TERM H 1 Bright A_PlaySound("AbyCyb/Atk",0);
		TERM G 2 A_FaceTarget;
		TERM I 1 Bright A_CustomMissile("RS_AbyCybBubProj",38,15,random(0,9));
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(12,1028),random(-12,12),random(5,32),11,0,3,random(-32,32),SXF_NOCHECKPOSITION);
		TERM I 1 Bright A_PlaySound("AbyCyb/Atk",0);
		TERM G 0 A_Jump(32,"Choices");
		TERM G 1 A_SpidRefire;
		Goto Bubble;
	Death:
		TERM M 6 A_Scream;
		TERM N 4;
		TERM OPQ 4 Bright;
		TERM R 0 A_FaceTarget;
		TERM R 0 A_SpawnItemEx("RS_TerminatorHead",15,0,90,10,0,0,-170,128);
		TERM R 0 A_SpawnItemEx("RS_TerminatorShoulder",60,0,75,8,0,0,-70,128);
		TERM R 4 Bright A_SpawnItemEx("RS_TerminatorArm",60,0,0,3,0,0,-90,128);
		TERM STUV 4 Bright;
		TERM W 4;
		TERM X 6 A_Fall;
		TERM YZ 6;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TERM "[" -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray Cybie ("Stoner Cybie").  CH: CYBIES.txt:1576.
// ---------------------------------------------------------------------------
class RS_GrayCybie2 : Actor   // CH CYBIES.txt:1576
{
	int User_Doner;   // CH: Var int User_Doner;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Species "Cybie";
		Obituary "Gray Cybie used rockslide! it's super effective! %o fainted!";
		Health 8888;
		Radius 40;
		Height 110;
		Mass 3000;
		Speed 13;
		SeeSound "CybLow";
		PainSound "cyber/pain";
		DeathSound "superdemon/death";
		ActiveSound "cyber/active";
		Translation "64:79=%[0.24,0.24,0.24]:[0.71,0.79,0.94]","48:63=%[1.03,1.03,1.03]:[0.51,0.51,0.51]","32:47=0:0","168:191=0:0","16:31=0:0","1:2=0:0","236:239=0:0","160:167=111:111";
		YScale 1.33;
		XScale 1.5;
		DropItem "RS_CH_SoulSphere";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "RS_CH_GreenArmor";
		RadiusDamageFactor 0.25;
		DamageFactor "PLWater", 1.75;
		DamageFactor "Melee", 1.1;
		DamageFactor "Plasma", 0.90;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Monster;
		+BOSS
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		+NOPAIN
		+NOFEAR
		Tag "Stoner Cybie";
	}
	States
	{
	Spawn:
		SUPR A 0;
	KillIt:
		TNT1 A 0;
		Goto Idle;
	Idle:
		SUPR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SUPR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR D 6 A_Hoof;
		Loop;
	Missile:
		SUPR E 1 A_JumpIfHealthLower(3500,"BuffUP");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR E 1 A_Jump(64,"Missiles1");
		SUPR E 1 A_Jump(64,"Missiles2");
		SUPR E 6 A_FaceTarget;
		SUPR E 8 A_PlaySound("CybLow");
		SUPR EG 8 A_VileTarget("RS_CHBSTarget");
		SUPR G 2 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		SUPR G 12 A_VileTarget("RS_RockSlideCH1");
		SUPR A 8;
		Goto See;
	Missiles1:
		SUPR E 6 A_FaceTarget;
		SUPR F 9;
		SUPR F 0 A_CustomMissile("RS_BaronOfDirtCH3",54,-45,0);
		SUPR F 0 A_CustomMissile("RS_BaronOfDirtCH3",54,-48,-4);
		SUPR F 0 A_CustomMissile("RS_BaronOfDirtCH3",54,-42,4);
		Goto See;
	Missiles2:
		SUPR F 6;
		// RS_VileGroundSpike is EXPECTED FROM THE ARCHVILES LANE
		// (CH Archviles.txt:1926).
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,0);
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,45,CMF_ABSOLUTEANGLE);
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,90,CMF_ABSOLUTEANGLE);
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,135,CMF_ABSOLUTEANGLE);
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,215,CMF_ABSOLUTEANGLE);
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,260,CMF_ABSOLUTEANGLE);
		SUPR F 0 A_CustomMissile("RS_VileGroundSpike",0,0,305,CMF_ABSOLUTEANGLE);
		// PROVEN MISSING IN CH: "CybieLow" -- CH SNDINFO only defines
		// "CybLow" (CH SNDINFO.txt:453). Silent in CH too; kept verbatim.
		SUPR E 8 A_PlaySound("CybieLow");
		Goto See;
	BuffUP:
		SUPR E 0 A_JumpIf(User_Doner >= 1,"Nah");
		SUPR E 8 A_PlaySound("CybLow");
		SUPR G 12 A_Quake(8,90,256,528,"");   // CH: a_quake(8,90,256,528,0)
		SUPR G 12 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenmore",TRUE)
		SUPR B 24;
		SUPR B 2 A_SetSpeed(19);
		SUPR G 1 { User_Doner = User_Doner + 1; }   // CH: A_SetUserVar("User_Doner",User_Doner+1)
		Goto See;
	Nah:
		SUPR E 0;
		Goto Missile+2;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR G 10 A_Pain;
		Goto See;
	Death:
		SUPR H 6 A_PlaySound("superdemon/snarl");
		SUPR H 0 A_CustomMissile("RS_HKRedDeath",90,-10,CMF_AIMOFFSET,2,10);
		SUPR H 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR H 0 A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		SUPR I 6 A_Scream;
		SUPR I 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR I 0 A_CustomMissile("RS_HKRedDeath",70,10,CMF_AIMOFFSET,2,10);
		SUPR J 0 A_CustomMissile("RS_HKRedDeath",20,50,CMF_AIMOFFSET,2,10);
		SUPR KL 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR L 0 A_CustomMissile("RS_HKRedDeath",10,-10,CMF_AIMOFFSET,2,10);
		SUPR M 6 A_PlaySound("superdemon/crash");
		SUPR N 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR OOOOOOOOOOOOOOOOOOOOOO 1 A_CustomMissile("RS_HKRedDeath",random(1,50),random(-10,30),random(0,180),CMF_AIMOFFSET,2,10);
		SUPR O 1 A_NoBlocking;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		SUPR O -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu Cybie.  CH: CYBIES.txt:1947.
// ---------------------------------------------------------------------------
class RS_FireBluCybie2 : Actor   // CH CYBIES.txt:1947
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 7777;
		BloodColor "Blue";
		Scale 1.33;
		Radius 40;
		Height 110;
		Mass 1300;
		Speed 19;
		PainChance 16;
		Species "Cybie";
		MeleeThreshold 200;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MeleeRange 75;
		Monster;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		DamageFunction (random(15,70));   // CH: Damage(random(15,70))
		SeeSound "cyber/sight";
		PainSound "cyber/pain";
		DeathSound "cyber/death";
		ActiveSound "cyber/active";
		Obituary "%o got horrified by fireblu cybie";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_Berserk", 32;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_BFG9000", 32;
		DropItem "RS_CH_BFG9000", 64;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_RocketLauncher";
		Translation "76:79=204:207","72:75=188:191","68:71=199:202","64:67=177:181","58:63=177:185","48:57=197:204","16:31=194:207","144:151=186:191","106:111=202:207","98:105=178:187","96:97=198:201","87:95=173:180","80:86=196:200","168:173=194:198","160:167=199:207","224:231=184:191","232:235=203:207";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	KillIt:
		TNT1 A 0;
	Idle:
		CYBR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CYBR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR D 3 A_Metal;
		CYBR D 3 A_Chase;
		Loop;
	Melee:
		CYBR G 8;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 8 A_CustomMeleeAttack(random(35,90),"skeleton/melee","none");
		CYBR E 1 A_VileAttack("bomb/boom",5,5,128,1.75);
		CYBR E 2 A_RadiusThrust(3040,400);
		Goto Splash;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 0 A_JumpIfCloser(900,"Maybe");
		Goto Missile1;
	Maybe:
		CYBR E 0 A_Jump(256,"Missile1","Missile2");
	Missile2:
		CYBR G 2 Bright;
		CYBR G 2 Bright A_SkullAttack(30);
		CYBR G 1 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		CYBR G 1 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		CYBR G 1 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		CYBR G 1 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		CYBR G 1 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		CYBR G 1 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		CYBR G 2;
		Goto See;
	Missile1:
		CYBR E 6 A_FaceTarget;
		CYBR F 12 Bright A_CustomMissile("RS_FireBluCybMiss",42,-9,random(-1,1));
		Goto See;
	Splash:
		CYBR E 5 Bright;
		CYBR G 0 A_CustomMissile("RS_FireBluCacoBall",0,0,0);
		CYBR G 0 A_CustomMissile("RS_FireBluCacoBall",0,0,120);
		CYBR G 0 A_CustomMissile("RS_FireBluCacoBall",0,0,240);
		CYBR G 3 Bright;
		Goto See;
	Pain:
		CYBR G 10 A_Pain;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR G 1 A_Jump(128,"Splash");
		Goto See;
	Death:
		CYBR H 10;
		CYBR I 10 A_Scream;
		CYBR JKL 10;
		CYBR M 10 A_NoBlocking;
		CYBR NO 10;
		CYBR P 30;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		CYBR P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common Cybie.  CH: CYBIES.txt:2150.
// ---------------------------------------------------------------------------
class RS_CommonCybie : Cyberdemon   // CH CYBIES.txt:2150
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "Cybie";
		MeleeThreshold 200;
		Scale 1.1;
		MeleeRange 75;
		DropItem "RS_CH_RocketLauncher", 128;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		Tag "CyberDemon";
	}
	States
	{
	Spawn:
		CYBR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CYBR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR D 3 A_Metal;
		CYBR D 3 A_Chase;
		Loop;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR G 10 A_Pain;
		Goto See;
	Melee:
		CYBR G 8;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 8 A_CustomMeleeAttack(random(35,90),"skeleton/melee","none");
		CYBR E 1 A_VileAttack("bomb/boom",5,5,128,1.75);
		CYBR E 2 A_RadiusThrust(3040,400,RTF_NOTMISSILE);
		Goto Missile+7;
	Missile:
		CYBR E 6 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR F 12 Bright A_CustomMissile("Rocket",42,-9,random(-1,1));
		CYBR E 12 A_FaceTarget;
		CYBR F 12 Bright A_CustomMissile("Rocket",42,-9,random(-2,2));
		CYBR E 12 A_FaceTarget;
		CYBR E 0 A_JumpIf(RS_Zom.CV('rs_ch_intercept', 0) == 1,"Miss2");
		// CH: ACS_NamedExecuteWithResult("CybMissile",1) -- resolved 2026-08-06
		// from CH's own ACS SOURCE (CH\source\, which ships alongside the
		// compiled acs\*.o the import originally saw).
		//
		// CHACS.acs:9 -- CybMissile(rand): rand is 1 here, so it takes the
		//   else branch: ProjInt_Brute(0,0,20.0,0,-25.0,1.0,60.0,"Rocket",
		//                              0,0,0,0, /*rand=*/1, 0)
		// miscFuncs.acs:112-115 -- with input_t 0 and rand nonzero:
		//     if(rand){ random(1, sml_t); }   // return value DISCARDED
		//     else    { t = sml_t; }
		//   't' is an ACS local, so it stays 0. Every lead term is then
		//   FixedMul(0, targetVel) == 0 and tXf/tYf/tZf collapse back onto
		//   the target's CURRENT position (miscFuncs.acs:117-122). CH's
		//   "rand" branch does not randomise the lead -- it deletes it.
		//
		// So CH's common cyberdemon does NOT lead: it fires a Rocket at the
		// target's present position, speed 20 (== vanilla Rocket speed), from
		// offset (-25 lateral, 1 forward, 60 up), pitch-aimed in 3D. That is
		// exactly a plain aimed A_CustomMissile, which is what this now is --
		// faithful, not a substitution. The lateral -25 and height 60 are
		// CH's; A_CustomMissile aims at the target with pitch by default.
		// (The lead solver RS_HKLead is still correct for the callers that
		// reach the non-buggy branch -- baron and lost souls pass rand=1 to
		// BaronMissile, which inverts the flag and gets a real intercept.)
		CYBR F 12 Bright A_CustomMissile("Rocket",60,-25,0);
		Goto See;
	Miss2:
		CYBR F 12 Bright A_CustomMissile("Rocket",42,-9,random(-4,4));
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green Cybie.  CH: CYBIES.txt:2213.
// ---------------------------------------------------------------------------
class RS_GreenCybie : Cyberdemon   // CH CYBIES.txt:2213
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 5000;
		BloodColor "Green";
		Scale 1.1;
		Radius 40;
		Height 110;
		Mass 1300;
		Speed 16;
		PainChance 16;
		Species "Cybie";
		MeleeThreshold 200;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MeleeRange 75;
		Monster;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "cyber/sight";
		PainSound "cyber/pain";
		DeathSound "cyber/death";
		ActiveSound "cyber/active";
		Obituary "%o was splashtered by green cybie";
		DropItem "RS_CH_GreenArmor", 34;
		DropItem "RS_HealthBundle", 88;
		Translation "168:191=112:127","32:47=123:127","48:79=[167,237,169]:[9,46,7]","128:151=[104,225,83]:[29,52,18]","232:235=124:127","208:223=112:127","164:167=124:127";
		Tag "Green CyberDemon";
	}
	States
	{
	Spawn:
		CYBR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CYBR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR D 3 A_Metal;
		CYBR D 3 A_Chase;
		Loop;
	Melee:
		CYBR G 8;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 8 A_CustomMeleeAttack(random(35,90),"skeleton/melee","none");
		CYBR E 1 A_VileAttack("bomb/boom",5,5,128,1.75);
		CYBR E 2 A_RadiusThrust(3040,400,RTF_NOTMISSILE);
		Goto Missile+6;
	Missile:
		CYBR E 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR F 12 Bright A_CustomMissile("RS_SplashRocket",42,-9,random(-1,1));
		CYBR E 10 A_FaceTarget;
		CYBR F 12 Bright A_CustomMissile("RS_SplashRocket",42,-9,random(-4,4));
		CYBR E 10 A_FaceTarget;
		CYBR F 12 Bright;
		CYBR F 0 A_CustomMissile("RS_SplashRocket",42,-9,random(1,13));
		CYBR F 0 A_CustomMissile("RS_SplashRocket",42,-9,random(-13,-1));
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR G 10 A_Pain;
		Goto See;
	Death:
		CYBR H 10;
		CYBR I 10 A_Scream;
		CYBR JKL 10;
		CYBR M 10 A_NoBlocking;
		CYBR NO 10;
		CYBR P 30;
		CYBR P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue Cybie.  CH: CYBIES.txt:2357.
// ---------------------------------------------------------------------------
class RS_BlueCybie : Cyberdemon   // CH CYBIES.txt:2357
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 5800;
		BloodColor "Blue";
		Scale 1.20;
		Radius 40;
		Height 110;
		Mass 1300;
		Speed 18;
		PainChance 12;
		Species "Cybie";
		MeleeThreshold 200;
		MeleeRange 75;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		DropItem "RS_CH_SoulSphere", 112;
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_HealthBundle";
		// CH: Dropitem "RLXaserPowerArmorPickup",12 (CYBIES.txt:2389) --
		// DRLA cross-mod drop, stripped per the standing order.
		SeeSound "cyber/sight";
		PainSound "cyber/pain";
		DeathSound "cyber/death";
		ActiveSound "cyber/active";
		Obituary "%o met a blue fate in blue cybies hand";
		Translation "64:79=[54,45,238]:[17,11,79]","144:151=240:247","48:63=[145,164,240]:[52,66,231]","208:223=[251,251,251]:[126,136,248]","232:235=203:207","224:231=192:197","168:191=192:207";
		Tag "Blue CyberDemon";
	}
	States
	{
	Spawn:
		CYBR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CYBR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR D 3 A_Metal;
		CYBR D 3 A_Chase;
		Loop;
	Melee:
		CYBR G 8;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 8 A_CustomMeleeAttack(random(35,90),"skeleton/melee","none");
		CYBR E 1 A_VileAttack("bomb/boom",5,5,128,1.65);
		CYBR E 2 A_RadiusThrust(8040,400,RTF_NOTMISSILE);
		Goto Missile;
	Missile:
		CYBR E 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR F 0 A_PlaySound("Spell/Lightn",0,2.7);
		CYBR F 3 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 3 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 0 A_PlaySound("Litn/litn2",1,2.5);
		CYBR F 3 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 4 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR E 3 A_FaceTarget;
		CYBR F 1 Bright A_FaceTarget;
		CYBR F 0 A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 2 Bright A_CustomMissile("RS_SwooshCB",30,-9,random(-4,4));
		CYBR F 5 Bright A_FaceTarget;
		CYBR F 0 A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 2 Bright A_CustomMissile("RS_SwooshCB",30,-9,random(-7,7));
		CYBR F 5 Bright A_FaceTarget;
		CYBR F 0 A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 2 Bright A_CustomMissile("RS_SwooshCB",30,-9,random(-1,1));
		CYBR F 0 A_JumpIfInventory("RS_SpamComboCB",7,"Finish");
		CYBR F 0 A_GiveInventory("RS_SpamComboCB",1);
		CYBR F 1 Bright A_MonsterRefire(80,"See");
		TNT1 A 0 A_Jump(82,"Art");
		Goto Missile+8;
	Art:
		CYBR F 0 A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 6 Bright A_CustomMissile("RS_BluCybFX",54,-9,0);
		CYBR F 5 Bright A_CustomMissile("RS_BluCybFX",58,-9,0);
		CYBR F 4 Bright A_CustomMissile("RS_BluCybFX",62,-9,0);
		CYBR G 3 Bright A_CustomMissile("RS_BluCybFX",66,-9,0);
		CYBR G 3 Bright A_CustomMissile("RS_BluCybFX",68,-9,0);
		CYBR G 2 Bright A_CustomMissile("RS_BluCybFX",74,-9,0);
		CYBR G 2 Bright A_CustomMissile("RS_BluCybFX",78,-9,0);
		CYBR G 0 A_CustomMissile("RS_BluCybArt",64,-9,random(-20,20));
		CYBR G 16 Bright A_CustomMissile("RS_BluCybFX",82,-9,0);
		CYBR F 6 Bright A_FaceTarget;
		Goto See;
	Finish:
		// CH: A_ChangeFlag("Painless",TRUE). There is no PAINLESS flag in
		// GZDoom -- CH's own call is a no-op that logs an unknown-flag
		// warning, so the finisher is not actually pain-proof in CH either.
		// Converting it to a real flag would invent behaviour, so the dud
		// call is kept exactly as CH wrote it.
		CYBR G 0 A_ChangeFlag("Painless",TRUE);
		CYBR G 2 A_PlaySound("cyber/sight");
		CYBR G 11 A_CustomMissile("RS_BluCybFX",54,-17,0);
		CYBR E 9 A_FaceTarget;
		CYBR F 0 A_PlaySound("Spell/Lightn",0,3);
		CYBR F 6 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 6 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 10 Bright A_FaceTarget;
		CYBR F 0 A_PlaySound("Spell/Lightn",0,2.7);
		CYBR F 6 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 6 Bright A_CustomMissile("RS_BluCybFX",42,-9,0);
		CYBR F 2 Bright A_CustomMissile("RS_SwooshCB2",30,-9,0);
		CYBR F 0 A_TakeInventory("RS_SpamComboCB",7);
		CYBR G 0 A_ChangeFlag("Painless",FALSE);   // CH: same dud flag, see above
		Goto See;
	Pain:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR G 10 A_Pain;
		CYBR G 1 A_Jump(64,"Shockwave");
		Goto See;
	Shockwave:
		CYBR GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_PlasmaBallSP5",53,random(-12,12),random(0,360),CMF_AIMDIRECTION,random(0,360));
		CYBR G 4;
		Goto See;
	Death:
		CYBR H 10;
		CYBR I 10 A_Scream;
		CYBR JKL 10;
		CYBR M 10 A_NoBlocking;
		CYBR NO 10;
		CYBR P 30;
		CYBR P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Purple Cybie's escort. Summoned minion -- no tier token.
// CH: CYBIES.txt:2670. Parent RS_PurpleHK is the hellknight lane's.
// ---------------------------------------------------------------------------
class RS_SpecialHK : RS_PurpleHK   // CH CYBIES.txt:2670
{
	Default
	{
		Species "Cybie";
		BloodColor "Blue";
		DamageFactor "Blessed", 3.0;
		Health 500;
		Speed 11;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		+THRUSPECIES
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOFEAR
		+NOTRIGGER
	}
	States
	{
	See:
		BOS2 AABBCCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 A 0 A_JumpIfMasterCloser(1000,"See");
		BOS2 A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		BOS2 A 1;
		Loop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple Cybie.  CH: CYBIES.txt:2699.
// ---------------------------------------------------------------------------
class RS_PurpleCybie : Cyberdemon   // CH CYBIES.txt:2699
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 6400;
		Radius 40;
		Height 110;
		BloodColor "Purple";
		Mass 2500;
		Speed 13;
		PainChance 16;
		Species "Cybie";
		MeleeThreshold 200;
		MeleeRange 86;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		Scale 1.33;
		DropItem "RS_CH_SoulSphere", 188;
		DropItem "RS_CH_CellPack";
		DropItem "BackPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_MegaSphere", 32;
		SeeSound "cyber/sight";
		PainSound "cyber/pain";
		DeathSound "cyber/death";
		ActiveSound "cyber/active";
		Obituary "%o fell in the awe of mighty purple cyberdemon";
		Translation "168:191=250:254","48:79=[255,66,255]:[65,10,14]","254:254=[0,0,0]:[255,255,255]";
		Tag "Purple CyberDemon";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	KillIt:
		TNT1 A 1 A_KillMaster;
		SKUL A 0 A_SpawnItemEx("RS_SpecialHK",0,-5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SKUL A 0 A_SpawnItemEx("RS_SpecialHK",0,5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SKUL A 0 A_SpawnItemEx("RS_SpecialHK",5,-5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SKUL A 0 A_SpawnItemEx("RS_SpecialHK",-5,5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
	Idle:
		CYBR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CYBR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR D 3 A_Metal;
		CYBR D 3 A_Chase;
		Loop;
	Melee:
		CYBR G 8;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 8 A_CustomMeleeAttack(random(45,90),"skeleton/melee","none");
		CYBR E 1 A_VileAttack("bomb/boom",10,10,128,1.75);
		CYBR E 2 A_RadiusThrust(3040,400,RTF_NOTMISSILE);
		Goto RocketCombo;
	Missile:
		CYBR E 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR E 0 A_JumpIfCloser(1200,"BarrageOr");
		CYBR E 0 A_Jump(255,"LongSpam");
		Goto See;
	BarrageOr:
		CYBR E 0 A_Jump(255,"Barrage","RocketCombo");
		Goto See;
	Barrage:
		CYBR F 4 Bright A_FaceTarget;
		CYBR F 0 A_PlaySound("Spell/SpellCast1",4,3.1);
		CYBR FFFF 0 Bright A_CustomMissile("RS_CBWave",42,-9,random(-15,15),0,random(-15,15));
		CYBR F 6 Bright A_CustomMissile("RS_CBWave",42,-9,random(-1,1));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-5,5));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-9,9));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-13,13));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-15,15));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-15,15));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-25,25));
		CYBR G 8;
		CYBR E 6 A_FaceTarget;
		CYBR F 0 A_PlaySound("Spell/SpellCast1",4,3.1);
		CYBR FFFF 0 Bright A_CustomMissile("RS_CBWave",42,-9,random(-15,15),0,random(-15,15));
		CYBR F 6 Bright A_CustomMissile("RS_CBWave",42,-9,random(-1,1));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-5,5));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-9,9));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-13,13));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-15,15));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-15,15));
		CYBR FF 1 Bright A_CustomMissile("RS_CBWave",42,-9,random(-25,25));
		Goto RocketCombo;
	LongSpam:
		CYBR E 22 A_FaceTarget;
		CYBR F 0 A_PlaySound("Spell/SpellCast1",4,3.1);
		CYBR F 3 Bright A_CustomMissile("RS_OrbCB",42,-9,-3);
		CYBR F 2 Bright A_CustomMissile("RS_OrbCB",42,-9,15);
		CYBR F 2 Bright A_CustomMissile("RS_OrbCB",42,-9,-15);
		CYBR F 1 Bright A_CustomMissile("RS_OrbCB",42,-9,11);
		CYBR F 1 Bright A_CustomMissile("RS_OrbCB",42,-9,-11);
		CYBR F 1 Bright A_CustomMissile("RS_OrbCB",42,-9,3);
		CYBR E 4 Bright A_CheckSight("See");
		CYBR G 10 Bright;
		CYBR E 8 Bright A_FaceTarget;
		CYBR E 4 Bright A_CheckSight("See");
		CYBR F 8 Bright A_VileTarget("RS_PurpleWorryCB");
		CYBR E 8 A_MonsterRefire(64,"See");
		Goto LongSpam;
	RocketCombo:
		CYBR E 6 A_FaceTarget;
		CYBR F 8 A_CustomMissile("RS_Propane",42,-9,random(-4,4));
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR G 10 A_Pain;
		Goto See;
	Pain.Fire:
		CYBR G 3 A_PlaySound("ResistCH",7);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYBR G 3 A_Pain;
		Goto See;
	Death:
		CYBR H 10;
		CYBR I 10 A_Scream;
		CYBR JKL 10;
		CYBR M 10 A_NoBlocking;
		CYBR NO 10;
		CYBR P 30;
		CYBR P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 5 -- Yellow Cybie ("Less cyber yellow Cybie").  CH: CYBIES.txt:2991.
// ---------------------------------------------------------------------------
class RS_YellowCybie : Actor   // CH CYBIES.txt:2991
{
	int User_Doner;   // CH: Var int User_Doner;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Species "Cybie";
		Obituary "Poor %o , not much was left after Legendary Cybie's treatment";
		Health 7777;
		Radius 40;
		Height 110;
		Mass 3000;
		Speed 19;
		SeeSound "cyber/sight";
		PainSound "cyber/pain";
		DeathSound "superdemon/death";
		ActiveSound "cyber/active";
		Translation "48:63=210:219","64:68=219:223","69:74=181:189","76:79=44:47";
		Scale 1.42;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		DropItem "RS_CH_SoulSphere";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "RS_CH_MegaSphere", 24;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Monster;
		+BOSS
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		+NOPAIN
		+NOFEAR
		Tag "Less cyber yellow Cybie";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	KillIt:
		TNT1 A 1 A_KillMaster;
		Goto Announce;
	Announce:
		// CH: SUPR A 2 ACS_NamedExecuteAlways("AnnounceCybie1") -- ACS
		// announcer stripped per the standing order; the 2-tic frame stays.
		SUPR A 2;
		Goto Idle;
	Idle:
		SUPR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SUPR A 3 A_Hoof;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR D 3 A_Hoof;
		SUPR D 3;
		Loop;
	Missile:
		SUPR E 1 A_JumpIfHealthLower(3500,"BuffUP");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR E 1 A_JumpIfCloser(800,"RainOffire");
		SUPR E 1 A_Jump(255,"Missiles1");
	RainOffire:
		SUPR E 6 A_FaceTarget;
		SUPR E 8 A_PlaySound("cyber/sight");
		SUPR GGGGGGGGGG 1 A_CustomMissile("RS_SparkPuff1",78,-56,CMF_AIMOFFSET,random(0,360),random(0,360));
		SUPR E 8;
		SUPR G 12 A_CustomMissile("RS_CybieRainMaker",100,0);
		SUPR G 0 A_CustomMissile("RS_CybieRainMaker",100,0,randompick(-30,30));
		TNT1 AAA 0 A_SpawnItemEx("RS_CybieRain",random(64,128),random(-64,64),552,random(1,15),0,random(-12,1),random(-15,15));
		SUPR GG 1 A_SpawnItemEx("RS_CybieRain",random(64,256),random(-64,64),552,random(1,15),0,random(-12,1),random(-33,33));
		SUPR GG 1 A_SpawnItemEx("RS_CybieRain",random(64,176),random(-84,84),552,random(1,15),0,random(-12,1),random(-15,15));
		SUPR GGG 1 A_SpawnItemEx("RS_CybieRain",random(128,526),random(-88,88),552,random(1,15),0,random(-12,1),random(-21,21));
		SUPR GGG 1 A_SpawnItemEx("RS_CybieRain",random(252,728),random(-94,94),552,random(1,15),0,random(-12,1),random(-26,26));
		SUPR GG 1 A_SpawnItemEx("RS_CybieRain",random(252,528),random(-84,84),552,random(1,15),0,random(-12,1),random(-15,15));
		SUPR GGGG 1 A_SpawnItemEx("RS_CybieRain",randompick(252,528,725,912),random(-64,64),552,random(1,15),0,random(-12,1),random(-15,15));
		SUPR GGG 1 A_SpawnItemEx("RS_CybieRain",randompick(528,725,912,1028),random(-64,64),552,random(1,15),0,random(-12,1),random(-15,15));
		SUPR A 8;
		Goto See;
	Missiles1:
		SUPR E 6 A_FaceTarget;
		SUPR F 9;
		SUPR F 0 A_CustomMissile("RS_Vollrey",54,-45,0);
		SUPR F 0 A_CustomMissile("RS_Vollrey2",54,-48,-2);
		SUPR F 0 A_CustomMissile("RS_Vollrey2",54,-42,2);
		Goto See;
	BuffUP:
		SUPR E 0 A_JumpIf(User_Doner >= 1,"Nah");
		SUPR E 8 A_PlaySound("cyber/sight");
		SUPR G 12 A_CustomMissile("RS_CybieRainMaker",100,0);
		SUPR G 12 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenmore",TRUE)
		SUPR B 2 { bTHRUACTORS = true; }         // CH: A_ChangeFlag("THRUACTORS",TRUE)
		SUPR G 1 A_SpawnItemEx("RS_YellowHK",0,-65,66,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SUPR G 1 A_SpawnItemEx("RS_YellowHK",0,65,-66,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SUPR B 24;
		SUPR B 2 { bTHRUACTORS = false; }        // CH: A_ChangeFlag("THRUACTORS",FALSE)
		SUPR G 1 { User_Doner = User_Doner + 1; }   // CH: A_SetUserVar("User_Doner",User_Doner+1)
		Goto See;
	Nah:
		SUPR E 0 A_JumpIfCloser(700,"Ormaybe");
		SUPR E 0 A_Jump(255,"Missiles1");
		Goto Missile+1;
	Ormaybe:
		SUPR E 0 A_Jump(255,"RainOfFire","Missiles1");
		Goto Missile+1;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPR G 10 A_Pain;
		Goto See;
	Death:
		SUPR H 6 A_PlaySound("superdemon/snarl");
		SUPR H 0 A_CustomMissile("RS_HKRedDeath",90,-10,CMF_AIMOFFSET,2,10);
		SUPR H 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR H 0 A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		SUPR I 6 A_Scream;
		SUPR I 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR I 0 A_CustomMissile("RS_HKRedDeath",70,10,CMF_AIMOFFSET,2,10);
		SUPR J 6 A_CustomMissile("RS_SuperDemonArm",54,-50,-50);
		SUPR J 0 A_CustomMissile("RS_HKRedDeath",20,50,CMF_AIMOFFSET,2,10);
		SUPR KL 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR L 0 A_CustomMissile("RS_HKRedDeath",10,-10,CMF_AIMOFFSET,2,10);
		SUPR M 6 A_PlaySound("superdemon/crash");
		SUPR N 6 A_CustomMissile("Blood",0,0,random(-80,-100),2,random(45,80));
		SUPR O 6 A_NoBlocking;
		SUPR O -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red Cybie ("Red Overlord").  CH: CYBIES.txt:3308.
// ---------------------------------------------------------------------------
class RS_RedCybie : Actor   // CH CYBIES.txt:3308
{
	int User_PhaseIt;   // CH: Var Int User_PhaseIt;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 10000;
		Radius 40;
		Height 110;
		Mass 8000;
		Speed 20;
		Scale 1.25;
		PainChance 15;
		Damage 20;   // CH: bare constant, stays bare
		RadiusDamageFactor 0.25;
		DamageFactor "Moloch", 0;
		Obituary "%o was re defined as corpse by Red Cybie";
		HitObituary "%o got earthquake'd by Red Cybie";
		SeeSound "moloch/sight";
		PainSound "moloch/pain";
		DeathSound "moloch/death";
		ActiveSound "moloch/active";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "ice", 1.35;
		MeleeRange 68;
		MeleeThreshold 128;
		Monster;
		+BOSS
		+QUICKTORETALIATE
		+FLOORCLIP
		-NORADIUSDMG
		+MISSILEMORE
		+DONTMORPH
		+NOICEDEATH
		+DONTHARMCLASS
		+NOTARGET
		+DONTHARMCLASS
		+NOFEAR
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_RocketBox";
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
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_BFG9000", 128;
		DropItem "RS_CH_MegaSphere", 128;
		// CH: the following six are DRLA cross-mod drops, stripped per the
		// standing order and itemised here so the table stays restorable --
		//   DropItem "RLLavaArmorPickup",42          (CYBIES.txt:3365)
		//   DropItem "RLFireStormModItem",72         (CYBIES.txt:3366)
		//   Dropitem "RareArmorPool",64              (CYBIES.txt:3367)
		//   Dropitem "RLDemonicWeaponSpawner",4      (CYBIES.txt:3368)
		//   Dropitem "RLLegendaryWeaponSpawner",2    (CYBIES.txt:3369)
		//   Dropitem "RLUniqueWeaponSpawner",12      (CYBIES.txt:3370)
		Tag "Red Overlord";
	}
	States
	{
	Spawn:
		MOLO A 0;
		Goto Scripted;
	Scripted:
		MOLO A 1 A_KillMaster;
		// CH: MOLO A 2 ACS_NamedExecuteAlways("AnnounceCybie2") -- ACS
		// announcer stripped; the 2-tic frame stays.
		MOLO A 2;
		Goto Idle;
	Idle:
		MOLO AB 10 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		MOLO AA 4 A_Chase;
		MOLO AA 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(15,80),0,0,0,0,SXF_NOCHECKPOSITION);
		MOLO B 0 A_PlaySound("moloch/step");
		MOLO BB 4 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MOLO BB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(15,80),0,0,0,0,SXF_NOCHECKPOSITION);
		MOLO CC 4 A_Chase;
		MOLO CC 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(15,80),0,0,0,0,SXF_NOCHECKPOSITION);
		MOLO D 0 A_PlaySound("moloch/step");
		MOLO DD 4 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MOLO DD 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(15,80),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		MOLO H 10 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MOLO J 4 Radius_Quake(40,60,0,40,0);
		MOLO N 2 A_PlaySound("moloch/thud");
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,0);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,10);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,20);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,30);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,40);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,50);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,60);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,70);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,80);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,90);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,100);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,110);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,120);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,130);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,140);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,150);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,160);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,180);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,190);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,200);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,210);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,220);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,230);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,240);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,250);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,260);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,270);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,280);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,290);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,300);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,310);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,320);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,330);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,340);
		MOLO N 0 A_CustomMissile("RS_MolochQuake",0,-48,350);
		MOLO J 2;
		MOLO A 4;
		Goto See;
	Missile:
		MOLO A 0 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MOLO A 0 A_JumpIf(User_PhaseIt >= 1,"Phase2Jumps");
		MOLO A 0 A_JumpIfHealthLower(5000,"Phase2");   // CH trailing comment: //"moloch/phase2"
		MOLO A 0 A_Jump(256,"Missile1","Missile3","Missile2");
		Goto See;
	Phase2Jumps:
		MOLO A 0 A_Jump(256,"Missile5","Missile3","Missile2","Missile4");
		Goto See;
	Phase2:
		MOLO H 1 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",True)
		MOLO H 10 A_PlaySound("moloch/phase2",0,4);
		MOLO H 12 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenMore",True)
		MOLO H 2 { User_PhaseIt = User_PhaseIt + 1; }   // CH: A_SetUserVar
		MOLO HHHHHHHHH 5 A_CustomMissile("RS_VolcanoBall1",random(20,80),random(-40,40),CMF_AIMOFFSET,random(0,360),random(0,360));
		MOLO I 12 Bright;
		MOLO I 8 A_SetSpeed(28);
		MOLO H 2;
		Goto Melee;
	Missile1:
		MOLO H 0 A_PlaySound("moloch/attack");
		MOLO HH 14 A_FaceTarget;
		MOLO I 10 A_CustomMissile("RS_SoulBomb4",65,0,0,0);
		MOLO I 0 A_Jump(70,"Missile1","Missile2","Missile3","See");
		Goto See;
	Missile2:
		TNT1 A 0 A_CheckSight("See");
		MOLO F 0 A_PlaySound("moloch/attack");
		MOLO F 12 A_FaceTarget;
		MOLO EEEEE 2 A_CustomMissile("RS_VolcanoBall3",60,0,random(-13,13));
		MOLO E 0 A_CustomMissile("RS_VolcanoBall2",60,0,random(-13,13));
		MOLO H 12 A_FaceTarget;
		MOLO H 4 A_PlaySound("moloch/sight");
		MOLO II 6 A_CustomMissile("RS_RedCybieVolcano1",10,0,random(-30,30),2,random(-15,20));
		MOLO F 0 A_Jump(70,"Missile1","Missile2","Missile3","See");
		Goto See;
	Missile3:
		MOLO F 0 A_PlaySound("moloch/attack");
		MOLO F 25 A_FaceTarget;
		MOLO E 1 A_FaceTarget;
		MOLO G 1 A_CustomMissile("RS_MolochNail",55,random(-10,10),random(-3,3),0);
		MOLO G 0 A_PlaySound("moloch/nail");
		MOLO E 1 A_FaceTarget;
		MOLO G 1 A_CustomMissile("RS_MolochNail",55,random(-10,10),random(-9,9),0);
		MOLO G 0 A_PlaySound("moloch/nail");
		MOLO G 0 A_Jump(10,"Missile1","Missile2","Missile3","See");
		MOLO G 1 A_SpidRefire;
		Goto Missile3+5;
	Missile4:
		MOLO H 0 A_PlaySound("moloch/attack");
		MOLO HH 14 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		MOLO I 5 A_FaceTarget;
		MOLO II 0 A_SpawnItemEx("RS_SummonPortalCybie",random(-128,128),random(-128,128),50);
		MOLO I 5 A_FaceTarget;
		MOLO I 0 A_Jump(70,"Missile5","Missile2","Missile3","Missile4","See");
		Goto See;
	Missile5:
		MOLO H 0 A_PlaySound("moloch/attack");
		MOLO HH 14 A_FaceTarget;
		MOLO I 10;
		MOLO I 0 A_CustomMissile("RS_SoulBomb4",65,0,-9,0);
		MOLO I 0 A_CustomMissile("RS_SoulBomb4",65,0,0,0);
		MOLO I 0 A_CustomMissile("RS_SoulBomb4",65,0,9,0);
		MOLO I 0 A_Jump(70,"Missile5","Missile2","Missile3","Missile4","See");
		Goto See;
	Pain:
		MOLO H 0 A_Pain;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MOLO H 0 Radius_Quake(15,15,0,40,0);
		MOLO HHHHH 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(10,80),0,0,0,0,SXF_NOCHECKPOSITION);
		MOLO H 10 A_Jump(74,"Melee");
		Goto See;
	Death:
		MOLO J 14 A_ScreamAndUnblock;
		MOLO K 14 A_KillChildren;
		MOLO L 14;
		MOLO MNONMNONMNO 7 A_SpawnItemEx("RS_RedThingsLS",random(-60,60),random(-60,60),random(5,60),0,0,0,0,SXF_NOCHECKPOSITION);
		MOLO PQ 6;
		MOLO Q 0 Radius_Quake(40,60,0,40,0);
		MOLO Q 0 A_PlaySound("moloch/thud");
		MOLO R -1 A_BossDeath;
		Stop;
	Death.Telefrag:
		MOLO JKLMNOP 8 A_ScreamAndUnblock;
		// CH: MOLO Q 8 ACS_NamedExecuteAlways("CybieSpecialKill") -- ACS
		// announcer stripped; the 8-tic frame stays.
		MOLO Q 8;
		MOLO R -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// RED CYBIE'S WRAITH -- summoned minion, NO tier token.
// CH: CYBIES.txt:3692.  THIS CLASS CLOSES THE DORMANT GUARD: it is named as
// a runtime DropItem inside RS_PortalSummons (cacodemon lane) and did not
// exist until now. RS_RedCybieSouls and RS_SummonPortalCybie reach it too.
// ---------------------------------------------------------------------------
class RS_MolochWraith : Actor   // CH CYBIES.txt:3692
{
	int user_letmeget;   // CH: var int user_letmeget;
	Default
	{
		Health 20;
		Radius 12;
		Height 28;
		Mass 10;
		Speed 15;
		Damage 3;   // CH: bare constant, stays bare
		DamageFactor "Moloch", 0.01;
		RenderStyle "Add";
		Obituary "%o fell to an unlucky victim of a sacrifice.";
		HitObituary "%o was slashed by a red wraith.";
		PainChance 200;
		Monster;
		+NOGRAVITY
		+FLOAT
		+DONTFALL
		+DONTHARMCLASS
		+NOBLOOD
		+NOEXPLODEFLOOR
		+MISSILEMORE
		AttackSound "moloch/wraithattack";
		SeeSound "moloch/wraith";
		PainSound "skull/melee";
		DeathSound "moloch/wraithdie";
		DropItem "RS_CH_Cell", 42;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 200;
		DropItem "RS_CH_RocketAmmo", 88;
		DropItem "RS_CH_Berserk", 8;
	}
	States
	{
	Spawn:
		UNHE AB 10 A_Look;
		Loop;
	See:
		UNHE AB 3 A_Chase;
		TNT1 A 0 { user_letmeget = user_letmeget + 1; }   // CH: A_setuservar
		TNT1 A 0 A_JumpIf(user_letmeget >= 20,"PhaseOut");
		Loop;
	PhaseOut:
		TNT1 A 0 { bNOCLIP = true; }   // CH: A_changeflag("NOCLIP",TRUE)
		TNT1 A 0 { user_letmeget = user_letmeget - 18; }
		Goto See;
	Missile:
		TNT1 A 0 { bNOCLIP = false; }   // CH: A_changeflag("NOCLIP",FALSE)
		TNT1 A 0 { user_letmeget = 1; }   // CH: A_setuservar("User_letmeget",user_letmeget = 1)
		UNHE A 10 A_FaceTarget;
		UNHE B 4 A_SkullAttack(45);
		UNHE AB 4;
		Goto Missile+1;
	Melee:
		UNHE A 5 A_FaceTarget;
		// PROVEN MISSING IN CH: "moloch/wraithmelee" is in no CH SNDINFO
		// entry -- CH defines moloch/wraith, /wraithattack and /wraithdie
		// only. Silent in CH too; kept verbatim.
		UNHE B 5 A_CustomMeleeAttack(9,"moloch/wraithmelee","none","Moloch");
		Goto See;
	Pain:
		UNHE A 3;
		UNHE A 3 A_Pain;
		Goto See;
	Death:
		UNHE H 4 A_ScreamAndUnblock;
		UNHE IJKLM 5;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black Cybie ("He Will Smith You").  CH: CYBIES.txt:4082.
// Black bosses are icon 10 in CH's ladder.
// ---------------------------------------------------------------------------
class RS_BlackCybie2 : Actor   // CH CYBIES.txt:4082
{
	int User_OH1;      // CH: Var Int User_OH1;
	int User_DumDum;   // CH: Var Int User_DumDum;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 14500;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Radius 40;
		Height 110;
		Mass 5000;
		Speed 17;
		PainChance 16;
		Monster;
		Obituary "Having fun yet, %o ?";
		HitObituary "%o got hammered by black cybie";
		+FLOORCLIP
		+BOSS
		-NOTARGET
		+DONTHARMCLASS
		+MISSILEEVENMORE
		+QUICKTORETALIATE
		+NOICEDEATH
		+DONTMORPH
		-NORADIUSDMG
		+NOFEAR
		Damage 30;        // CH: bare constant, stays bare
		MeleeDamage 20;
		MeleeRange 86;
		SeeSound "Bcyb/Aggro";
		PainSound "monster/smithp";
		DeathSound "monster/smithd";
		ActiveSound "monster/smitha";
		MeleeSound "monster/hamhit";
		Scale 1.42;
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_BFG9000", 175;
		DropItem "RS_CH_PlasmaRifle", 200;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_MegaSphere", 164;
		// CH: the following six are DRLA cross-mod drops, stripped per the
		// standing order and itemised here so the table stays restorable --
		//   Dropitem "RLOModGothicArmorPickup",128   (CYBIES.txt:4133)
		//   DropItem "RLFireStormModItem",88         (CYBIES.txt:4134)
		//   Dropitem "RareArmorPool",128             (CYBIES.txt:4135)
		//   Dropitem "RLDemonicWeaponSpawner",12     (CYBIES.txt:4136)
		//   Dropitem "RLLegendaryWeaponSpawner",4    (CYBIES.txt:4137)
		//   Dropitem "RLUniqueWeaponSpawner",24      (CYBIES.txt:4138)
		Tag "He Will Smith You";
	}
	States
	{
	Spawn:
		BSMT A 0;
		Goto Scripted;
	Scripted:
		// CH: BSMT A 0 ACS_NamedExecuteAlways("AnnounceBlackCybie") -- ACS
		// announcer stripped per the standing order.
		BSMT A 0;
		Goto Idle;
	Idle:
		BSMT AB 10 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSMT A 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		BSMT A 0 A_UnSetReflectiveInvulnerable;
		BSMT A 0 A_ScaleVelocity(1);
		BSMT A 0 A_SetSpeed(18);
		BSMT A 0 A_CheckBlock("Reposition",CBF_NOLINES);
		BSMT A 3 A_PlaySound("monster/fihoof");
		BSMT ABB 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSMT C 3 A_PlaySound("monster/fihoof");
		BSMT CDD 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		BSMT A 0 A_JumpIfCloser(650,"Charge");
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSMT A 0 { User_DumDum = User_DumDum - 1; }   // CH: A_SetUserVar
		BSMT A 0 A_JumpIfHealthLower(8000,"Phase2");
		BSMT A 0 A_Jump(256,"Missile1","Missile2","LightningCall");
		Goto Charge;
		// CH keeps four unreachable lines here (CYBIES.txt:4174-4177);
		// carried verbatim so the state layout matches CH exactly.
		BSMT A 0;
		Goto Missile1;
		BSMT A 0;
		Goto Missile2;
	PH2:
		BSMT A 0 A_Jump(256,"BigHell","HammerMega","LightningCall","Summons");
		Goto See;
	Phase2:
		BSMT A 0 A_JumpIf(User_OH1 >= 1,"PH2");
		BSMT J 12 A_FaceTarget;
		BSMT J 8 { bMISSILEEVENMORE = true; }   // CH: A_changeFlag("MissileEvenMore",TRUE)
		BSMT JJJJJJ 8 A_SpawnItemEx("RS_PortalSummons",random(-178,178),random(-178,178),random(5,64),0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		BSMT J 2 { User_OH1 = User_OH1 + 1; }   // CH: A_SetUserVar
		Goto See;
	Summons:
		BSMT J 12 A_PlaySound("monster/fihoof");
		BSMT JJJJ 9 A_SpawnItemEx("RS_PortalSummons",random(-178,178),random(-178,178),random(5,64),0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	HammerMega:
		BSMT J 6 A_FaceTarget;
		BSMT K 1 A_PlaySound("monster/hamswg");
		BSMT M 2;
		BSMT NN 3 A_CustomMissile("RS_HammerShot",52,0,random(-8,8));
		BSMT K 5 A_FaceTarget;
		BSMT L 8 A_PlaySound("monster/hamflr");
		BSMT III 4 A_CustomMissile("RS_HammerShot",52,0,random(-14,14));
		Goto See;
	BigHell:
		BSMT J 12 A_FaceTarget;
		BSMT M 6 A_PlaySound("monster/hamswg");
		BSMT N 1 A_PlaySound("weapons/hellfi");
		BSMT N 11 A_CustomMissile("RS_BigHellshot",52,0,0);
		BSMT N 0 A_Jump(128,"Missile1");
		Goto See;
	NoFire:
		BSMT O 0 { User_DumDum = User_DumDum - 2; }   // CH: A_SetUserVar
		Goto Missile+1;
	Charge:
		BSMT O 0 A_JumpIf(User_DumDum >= 11,"NoFire");
		BSMT O 0 { User_DumDum = User_DumDum + 5; }   // CH: A_SetUserVar
		BSMT O 1 A_PlaySound("weapons/suldth");
		BSMT O 2 A_SetReflectiveInvulnerable;
		BSMT O 0 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		BSMT O 12 A_SkullAttack(35);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SpawnItemEx("RS_SmithGhost2",0,0,0,0,0,0,0,128,0);
		BSMT O 1 A_SetSpeed(0);
		BSMT O 1 A_ScaleVelocity(0.05);
		BSMT O 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		Goto Melee;
	Missile1:
		BSMT E 6 A_FaceTarget;
		BSMT H 6 A_PlaySound("monster/hamswg");
		BSMT N 0 A_PlaySound("weapons/hellfi");
		BSMT I 0 A_CustomMissile("RS_Hellshot2",52,0,0);
		BSMT I 0 A_CustomMissile("RS_Hellshot2",52,0,8);
		BSMT I 12 A_CustomMissile("RS_Hellshot2",52,0,-8);
		BSMT B 6 A_CheckSight("See");
		BSMT J 6 A_FaceTarget;
		BSMT M 6 A_PlaySound("monster/hamswg");
		BSMT N 1 A_PlaySound("weapons/hellfi");
		BSMT N 0 A_CustomMissile("RS_Hellshot2",52,0,0);
		BSMT N 0 A_CustomMissile("RS_Hellshot2",52,0,14);
		BSMT N 11 A_CustomMissile("RS_Hellshot2",52,0,-14);
		Goto See;
	Missile2:
		BSMT J 6 A_FaceTarget;
		BSMT K 1 A_PlaySound("monster/hamswg");
		BSMT M 2;
		BSMT N 3 A_CustomMissile("RS_HammerShot",52,0,random(-8,8));
		BSMT K 5 A_FaceTarget;
		BSMT L 10 A_PlaySound("monster/hamflr");
		BSMT I 6 A_CustomMissile("RS_HammerShot",52,0,random(-14,14));
		Goto See;
	LightningCall:
		BSMT P 8 A_PlaySound("Crack/death");
		BSMT J 6 A_FaceTarget;
		BSMT J 8 A_CustomMissile("RS_Zap88",100,-14);
		BSMT J 0 A_PlaySound("Crack/death");
		BSMT J 1 A_CustomMissile("RS_Zap88",120,random(-28,8));
		BSMT J 1 A_CustomMissile("RS_Zap88",135,random(-28,8));
		BSMT J 0 A_PlaySound("Crack/death");
		BSMT J 1 A_CustomMissile("RS_Zap88",150,random(-28,8));
		BSMT J 1 A_CustomMissile("RS_ZappersCB",78,random(-2,28),random(-180,180));
		BSMT J 1 A_CustomMissile("RS_ZappersCB",78,random(-2,28),random(-180,180));
		Goto See;
	Pain:
		BSMT P 0 A_SetSpeed(18);
		BSMT P 0 A_ScaleVelocity(1);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSMT P 10 A_Pain;
		BSMT P 0 A_Jump(64,"Reposition");
		Goto See;
	Reposition:
		BSMT O 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BSMT P 12 Radius_Quake(6,100,2,64,8);
		BSMT P 1 A_SetTranslucent(0.5);
		BSMT P 1 A_SetTranslucent(0.3);
		BSMT P 1 A_SetTranslucent(0.1);
		BSMT P 1 A_SetTranslucent(0);
		BSMT O 0 { bFLOAT = true; }        // CH: A_ChangeFlag("Float",TRUE)
		BSMT O 0 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		BSMT O 0 A_SetFloatSpeed(42);
		BSMT O 0 A_SetSpeed(42);
		BSMT OOOOOO 1 A_Wander;
		BSMT O 0 { bFLOAT = false; }        // CH: A_ChangeFlag("Float",FALSE)
		BSMT O 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		BSMT O 0 A_SetFloatSpeed(18);
		BSMT O 0 A_SetSpeed(18);
		BSMT P 1 A_SetTranslucent(0.1);
		BSMT P 1 Radius_Quake(6,100,2,64,8);
		BSMT P 1 A_SetTranslucent(0.3);
		BSMT P 1 A_SetTranslucent(0.5);
		BSMT P 1 A_SetTranslucent(0.7);
		BSMT P 1 A_SetTranslucent(1);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSMT P 8 { User_DumDum = User_DumDum - 6; }   // CH: A_SetUserVar
		BSMT O 0 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		Goto See;
	Melee:
		BSMT E 0 A_SetSpeed(18);
		BSMT E 6 A_FaceTarget;
		BSMT F 1 A_PlaySound("monster/hamswg");
		BSMT F 5 A_FaceTarget;
		BSMT G 5 A_CustomMeleeAttack(random(50,125));
		BSMT E 0 A_SetReflectiveInvulnerable;
		BSMT E 0 Radius_Quake(40,60,0,40,0);
		BSMT F 0 A_CustomMissile("RS_PentaLine1",0,0,-72,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine1",0,0,-144,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine1",0,0,-216,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine1",0,0,-288,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine1",0,0,0,2);
		BSMT G 1 A_PlaySound("monster/hamflr");
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,0);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,10);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,20);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,30);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,40);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,50);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,60);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,70);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,80);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,90);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,100);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,110);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,120);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,130);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,140);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,150);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,160);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,180);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,190);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,200);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,210);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,220);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,230);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,240);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,250);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,260);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,270);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,280);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,290);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,300);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,310);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,320);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,330);
		BSMT N 0 A_CustomMissile("RS_MolochQuake",0,-48,340);
		BSMT N 70 A_CustomMissile("RS_MolochQuake",0,-48,350);
		Goto See;
	Death:
		BSMT F 0 A_CustomMissile("RS_PentaLine3",0,0,-72,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine3",0,0,-144,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine3",0,0,-216,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine3",0,0,-288,2);
		BSMT F 0 A_CustomMissile("RS_PentaLine3",0,0,0,2);
		BSMT F 0 Radius_Quake(6,250,2,64,8);
		BSMT P 250 A_CustomMissile("RS_SmithDFSpawner",0,0,0,0);
		BSMT Q 6 A_CustomMissile("RS_SmithHammer",128,-40,-30,0);
		BSMT Q 0 A_CustomMissile("RS_SmithFire",0,0,0,2);
		BSMT R 6 A_Scream;
		BSMT R 0 A_CustomMissile("RS_SmithFire",0,0,0,2);
		BSMT STU 6;
		BSMT V 0 A_CustomMissile("RS_SmithFire",0,0,0,2);
		BSMT V 6 A_NoBlocking;
		BSMT VX 6;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TNT1 A 0 A_BossDeath;
		BSMT X 0 A_CustomMissile("RS_SmithFire",0,0,0,2);
		BSMT Y -1;
		Stop;
	Death.Telefrag:
		BSMT PQRSTUV 8 A_ScreamAndUnblock;
		// CH: BSMT X 8 ACS_NamedExecuteAlways("CybieSpecialKill") -- ACS
		// announcer stripped; the 8-tic frame stays.
		BSMT X 8;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TNT1 A 0 A_BossDeath;
		BSMT Y -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White Cybie's escort. Summoned minion -- no tier token.
// CH: CYBIES.txt:5224. Parent RS_CommonBaron is the barons lane's.
// ---------------------------------------------------------------------------
class RS_RomeroBaronsCH : RS_CommonBaron   // CH CYBIES.txt:5224
{
	Default
	{
		Species "Daikatana";
		+NOTRIGGER
		+NOCLIP
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+NOINFIGHTING
		Speed 11;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White Cybie ("It runs doom").  CH: CYBIES.txt:5235.
// ---------------------------------------------------------------------------
class RS_WhiteCybie2 : Actor   // CH CYBIES.txt:5235
{
	int user_phase;   // CH: var int user_phase;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "%o was made into Romero's bitch";
		Health 21000;
		Speed 18;
		Scale 1.25;
		PainChance 20;
		SeeSound "Rome/see";
		PainSound "";
		DeathSound "Rome/ded";
		ActiveSound "Rome/act";
		Monster;
		Species "Daikatana";
		RadiusDamageFactor 0.33;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "PlayerVoid", 0.75;
		DamageFactor "Poison", 0.33;
		Radius 40;
		Height 110;
		Mass 5000;
		DamageFactor "Falling", 0.0;
		+LAXTELEFRAGDMG
		+FLOORCLIP
		+BOSS
		-NOTARGET
		+DONTHARMCLASS
		+MISSILEEVENMORE
		+QUICKTORETALIATE
		+THRUSPECIES
		+NOICEDEATH
		+DONTMORPH
		-NORADIUSDMG
		+NOFEAR
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_MegaSphere";
		// CH: the following six are DRLA cross-mod drops, stripped per the
		// standing order and itemised here so the table stays restorable --
		//   DropItem "RLFireStormModItem"            (CYBIES.txt:5294)
		//   Dropitem "RareArmorPool"                 (CYBIES.txt:5295)
		//   Dropitem "BiggerThickerLonger"           (CYBIES.txt:5296)
		//   Dropitem "RLDemonicWeaponSpawner",20     (CYBIES.txt:5297)
		//   Dropitem "RLLegendaryWeaponSpawner",24   (CYBIES.txt:5298)
		//   Dropitem "RLUniqueWeaponSpawner",46      (CYBIES.txt:5299)
		Tag "It runs doom";
		Translation "64:79=%[0.20,0.20,0.20]:[1.65,1.65,1.65]","128:143=%[0.18,0.18,0.18]:[2.00,2.00,2.00]","144:151=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","13:15=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","5:7=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","236:239=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","1:2=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","96:111=%[0.02,0.02,0.02]:[1.39,1.39,1.39]","32:47=%[0.00,0.17,0.00]:[0.00,2.00,0.00]","168:191=%[0.00,0.35,0.17]:[0.00,1.65,0.83]";
	}
	States
	{
	Spawn:
		BSMT A 0;
		Goto Scripted;
	Scripted:
		// CH: BSMT A 0 ACS_NamedExecuteAlways("AnnounceWhiteCybie") -- ACS
		// announcer stripped per the standing order.
		BSMT A 0;
		Goto Idle;
	Idle:
		MMDR E 10 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSMT A 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		BSMT A 0 A_UnSetReflectiveInvulnerable;
		BSMT A 0 A_ScaleVelocity(1);
		TNT1 A 0 A_SetTranslucent(1);
		BSMT A 0 A_SetSpeed(18);
		BSMT A 0 A_CheckBlock("Reposition");
		MMDR AABB 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MMDR CCDD 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See2:
		BSMT A 0 { bTHRUACTORS = false; }
		BSMT A 0 A_UnSetReflectiveInvulnerable;
		BSMT A 0 A_ScaleVelocity(1);
		TNT1 A 0 A_SetTranslucent(1);
		BSMT A 0 A_SetSpeed(25);
		BSMT A 0 A_CheckBlock("Reposition");
		MMDR AABB 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(82,"Oi");
		MMDR CCDD 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Oi:
		MMDR CCDD 3 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See2;
	Phase2:
		TNT1 A 0 A_JumpIf(user_phase >= 2,"MissileSet");
		MMDR E 0 A_PlaySound("Rome/PH2",CHAN_WEAPON,1,0,0);
		MMDR E 10 Bright A_FaceTarget;
		MMDR Z 8 Bright A_FaceTarget;
		MMDR Y 5 Bright A_FaceTarget;
		MMDR Y 0 A_SpawnItemEx("TeleportFog",0,128,18,0,0,1,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("TeleportFog",0,-128,18,0,0,1,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("RS_RomeroBaronsCH",0,-128,3,0,0,0,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("RS_RomeroBaronsCH",0,128,3,0,0,0,0,SXF_NOCHECKPOSITION);
		MMDR Y 20 Bright A_FaceTarget;
		MMDR E 8 Bright { user_phase = 2; }   // CH: a_setuservar("user_phase",user_phase=2)
		Goto Dukie;
	Phase3:
		TNT1 A 0 A_JumpIf(user_phase >= 3,"MissileSet");
		MMDR E 0 A_PlaySound("Rome/PH3",CHAN_WEAPON,1,0,0);
		MMDR E 10 Bright A_FaceTarget;
		MMDR G 8 Bright A_FaceTarget;
		MMDR I 5 Bright A_FaceTarget;
		MMDR EIEGGIEGIGEIG 3 Bright A_FaceTarget;
		MMDR E 3 Radius_Quake(15,15,0,40,0);
		MMDR E 8 Bright { user_phase = 3; }   // CH: a_setuservar("user_phase",user_phase=3)
		Goto Reposition;
	BaronsPlease:
		MMDR E 10 Bright A_FaceTarget;
		MMDR Z 8 Bright A_FaceTarget;
		MMDR Y 5 Bright A_FaceTarget;
		MMDR Y 0 A_SpawnItemEx("TeleportFog",0,128,18,0,0,1,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("TeleportFog",0,-128,18,0,0,1,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("RS_RomeroBaronsCH",0,-128,3,0,0,0,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("RS_RomeroBaronsCH",0,128,3,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(user_phase >= 3,"BaronMore");
		MMDR Y 10 Bright A_FaceTarget;
		Goto See;
	BaronMore:
		MMDR YY 7 Bright A_FaceTarget;
		MMDR Y 0 A_SpawnItemEx("TeleportFog",0,218,18,0,0,1,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("TeleportFog",0,-218,18,0,0,1,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("RS_RomeroBaronsCH",0,-218,3,0,0,0,0,SXF_NOCHECKPOSITION);
		MMDR Y 0 A_SpawnItemEx("RS_RomeroBaronsCH",0,218,3,0,0,0,0,SXF_NOCHECKPOSITION);
		MMDR Y 20 Bright A_FaceTarget;
		Goto See2;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(8000,"Phase3");
		TNT1 A 0 A_JumpIfHealthLower(15000,"Phase2");
	MissileSet:
		TNT1 A 0 A_JumpIfCloser(200,"Dukie",true);
		TNT1 A 0 A_JumpIfCloser(720,"Close",true);
		TNT1 A 0 A_JumpIfCloser(1500,"Med",true);
		TNT1 A 0 A_JumpIf(user_phase >= 3,"MissileSet3");
		TNT1 A 0 A_JumpIf(user_phase >= 2,"MissileSet2");
		MMDR E 0 A_Jump(256,"ChainMissiles","BigLaser","SideWinder");
		Goto See;
	MissileSet2:
		MMDR E 0 A_Jump(256,"ChainMissiles2","BigLaser","LaserRain","Reposition","SideWinder");
		Goto See;
	MissileSet3:
		MMDR E 0 A_Jump(256,"ChainMissiles3","BigLaser2","LaserRain","FrontWinder","BaronsPlease");
		Goto See;
	Reposition:
		BSMT O 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		MMDR E 12 Radius_Quake(6,100,2,64,8);
		MMDR E 1 A_SetTranslucent(0.5);
		MMDR E 1 A_SetTranslucent(0.3);
		MMDR E 1 A_SetTranslucent(0.1);
		MMDR E 1 A_SetTranslucent(0);
		BSMT O 0 { bFLOAT = true; }        // CH: A_ChangeFlag("Float",TRUE)
		BSMT O 0 { bNOGRAVITY = true; }    // CH: A_ChangeFlag("nogravity",TRUE)
		BSMT O 0 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		BSMT O 0 A_SetFloatSpeed(68);
		BSMT O 0 A_SetSpeed(68);
		MMDR EEEEEEEE 3 A_Wander;
		MMDR EEEEEEEE 2 A_Wander;
		MMDR EEEEEEEE 1 A_Wander;
		BSMT O 0 { bFLOAT = false; }
		BSMT O 0 { bNOGRAVITY = false; }
		BSMT O 0 { bTHRUACTORS = false; }
		BSMT O 0 A_SetFloatSpeed(18);
		BSMT O 0 A_SetSpeed(18);
		MMDR E 1 A_SetTranslucent(0.1);
		MMDR E 1 Radius_Quake(6,100,2,64,8);
		MMDR E 1 A_SetTranslucent(0.3);
		MMDR E 1 A_SetTranslucent(0.5);
		MMDR E 1 A_SetTranslucent(0.7);
		MMDR E 1 A_SetTranslucent(1);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MMDR E 8;
		BSMT O 0 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		TNT1 A 0 A_JumpIf(user_phase >= 3,"See2");
		Goto See;
	Med:
		TNT1 A 0 A_JumpIf(user_phase >= 3,"Med3");
		TNT1 A 0 A_JumpIf(user_phase >= 2,"Med2");
		TNT1 A 0 A_JumpIfCloser(1100,"Rush",true);
		MMDR E 0 A_Jump(256,"ChainMissiles","DualShots","Nukes");
		Goto See;
	Med2:
		MMDR E 0 A_Jump(256,"ChainMissiles2","DualShots","Nukes","SideWinder","ShieldUP","LaserSweeper","LaserRain");
		Goto See;
	Med3:
		TNT1 A 0 A_JumpIfCloser(1100,"Rush",true);
		MMDR E 0 A_Jump(256,"ChainMissiles3","DualShots","SideWinder","LaserSweeper","BigLaser2","BaronsPlease","FrontWinder","LaserRain");
		Goto See;
	Close:
		TNT1 A 0 A_JumpIfCloser(200,"Dukie",true);
		TNT1 A 0 A_JumpIf(user_phase >= 3,"Close3");
		TNT1 A 0 A_JumpIf(user_phase >= 2,"Close2");
		MMDR E 0 A_Jump(256,"Nukes","ShotgunBreath","ChainMissiles");
		Goto See;
	Close2:
		MMDR E 0 A_Jump(256,"Nukes","ShotgunBreath","ChainMissiles2","ShieldUP","LaserSweeper");
		Goto See;
	Close3:
		MMDR E 0 A_Jump(256,"Reposition","LaserSweeper","FrontWinder","ID");
		Goto See;
	ID:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR EEEE 5 A_FaceTarget;
		MMDR E 5 Bright A_FaceTarget;
		MMDR HIJKJHIKJKHMN 1 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",128,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",192,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",256,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",320,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",128,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",192,-0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",256,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",320,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",128,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",192,128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",256,128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",320,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",350,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",414,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",478,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",542,-128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",350,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",414,-0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",478,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",542,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",350,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",414,128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",478,128,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_RomeroGroundCH",542,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR O 3 Bright;
		Goto FrontWinder;
	ShieldUp:
		MMDR E 5 Bright;
		TNT1 A 0 A_JumpIfInventory("RS_RomeroCHProtect",1,"Missile");
		TNT1 A 0 A_GiveInventory("RS_RomeroCHProtect",1);
		MMDR EEEE 11 Bright A_SpawnItemEx("RS_IDShieldWalk",0,4,64,0,0,0,0,SXF_SETMASTER);
		TNT1 A 0 A_Jump(64,"BaronsPlease");
		Goto See;
	FrontWinder:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR E 10 Bright A_FaceTarget;
		MMDR E 8 Bright ThrustThingZ(0,100,0,0);
		MMDR E 0 { bFLOAT = true; }       // CH: A_ChangeFlag(FLOAT,TRUE)
		MMDR E 0 { bNOGRAVITY = true; }   // CH: A_ChangeFlag(NOGRAVITY,TRUE)
		MMDR E 8 Bright A_FaceTarget;
		MMDR F 0 A_CustomMissile("RS_SpamShotsRomeroCH",52,30,1);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,33,1);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,33,-1);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,27,1);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,27,-1);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,27,3);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,27,-3);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,27,5);
		MMDR F 0 A_CustomMissile("RS_RomeroCHSeekBall",52,27,-5);
		MMDR F 10 Bright A_CustomMissile("RS_SpamShotsRomeroCH",52,-30,-1);
		MMDR E 5 A_FaceTarget;
		Goto Reposition;
	SideWinder:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR E 10 Bright A_FaceTarget;
		MMDR Z 8 Bright A_FaceTarget;
		MMDR Z 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",61,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",61,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Z 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Z 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Z 1 Bright A_FaceTarget;
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_FaceTarget;
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_FaceTarget;
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 0 A_CustomMissile("RS_RomeroCHSeekBall",60,50,random(20,50),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_CustomMissile("RS_RomeroCHSeekBall",60,-50,random(-50,-20),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		MMDR Y 1 Bright A_FaceTarget;
		MMDR YZE 10 Bright A_FaceTarget;
		TNT1 A 0 A_Jump(128,"DualShots");
		TNT1 A 0 A_JumpIf(user_phase >= 3,"See2");
		Goto See;
	ShotgunBreath:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR EEEE 5 A_FaceTarget;
		MMDR E 5 Bright A_FaceTarget;
		MMDR HIJKJHIKJKHMN 3 Bright A_FaceTarget;
		MMDR OOOOOOOOOOOOOOOOOOOOOOO 0 A_CustomMissile("RS_RomeroCHScatter",60,0,random(-12,12),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-13,13));
		MMDR O 3 Bright A_CustomMissile("RS_RomeroCHScatter",60,0,random(-12,12),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-13,13));
	DualShots:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR EEEE 5 A_FaceTarget;
		MMDR F 0 A_CustomMissile("RS_SpamShotsRomeroCH",52,30,1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33,1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33,-1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27,1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27,-1);
		MMDR F 10 Bright A_CustomMissile("RS_SpamShotsRomeroCH",52,-30,-1);
		MMDR E 5 A_FaceTarget;
		MMDR F 0 A_CustomMissile("RS_SpamShotsRomeroCH",52,30,2);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33,2);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33,-2);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27,2);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27,-2);
		MMDR F 8 Bright A_CustomMissile("RS_SpamShotsRomeroCH",52,-30,-2);
		MMDR E 4 A_FaceTarget;
		MMDR F 0 A_CustomMissile("RS_SpamShotsRomeroCH",52,30,1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33,1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33,-1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27,1);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27,-1);
		MMDR F 6 Bright A_CustomMissile("RS_SpamShotsRomeroCH",52,-30,-1);
		MMDR E 3 A_FaceTarget;
		MMDR F 0 A_CustomMissile("RS_SpamShotsRomeroCH",52,30);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27);
		MMDR F 4 Bright A_CustomMissile("RS_SpamShotsRomeroCH",52,-30);
		MMDR E 2 A_FaceTarget;
		MMDR F 0 A_CustomMissile("RS_SpamShotsRomeroCH",52,30);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,33);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27);
		MMDR F 0 A_CustomMissile("RS_SpamShotsCguy",52,27);
		MMDR F 2 Bright A_CustomMissile("RS_SpamShotsRomeroCH",52,-30);
		MMDR GG 3 Bright A_FaceTarget;
		TNT1 A 0 A_Jump(32,"Missile");
		TNT1 A 0 A_JumpIf(user_phase >= 3,"See2");
		Goto See;
	Rush:
		TNT1 A 0 A_Jump(32,"BigLaser");
		TNT1 A 0 A_Jump(92,"DualShots");
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR E 1 A_PlaySound("weapons/suldth");
		MMDR E 2 A_SetReflectiveInvulnerable;
		MMDR E 0 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		MMDR E 12 A_SkullAttack(35);
		MMDR E 1 A_SetTranslucent(1);
		MMDR E 1 A_SetTranslucent(0.8);
		MMDR E 1 A_SetTranslucent(0.6);
		MMDR E 1 A_SetTranslucent(0.4);
		MMDR E 1 A_SetTranslucent(0.2);
		MMDR E 1 A_SetTranslucent(0.3);
		MMDR E 1 A_SetTranslucent(0.5);
		MMDR E 1 A_SetTranslucent(0.8);
		MMDR E 1 A_SetTranslucent(1);
		MMDR E 1 A_SetSpeed(0);
		MMDR E 1 A_ScaleVelocity(0.05);
		MMDR E 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		TNT1 A 0 A_JumpIfCloser(200,"Dukie",true);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-64,-64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",64,-64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-64,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 3 A_SpawnItemEx("RS_RomeroGroundCH",64,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-164,-164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",164,-164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-164,164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 3 A_SpawnItemEx("RS_RomeroGroundCH",164,164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-234,-234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",234,-234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-234,234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 3 A_SpawnItemEx("RS_RomeroGroundCH",234,234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(user_phase >= 3,"DukieMore");
		Goto See;
	Dukie:
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-64,-64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",64,-64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-64,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,-64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-64,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",64,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 3 A_SpawnItemEx("RS_RomeroGroundCH",64,64,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,-164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-164,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",164,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-164,-164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",164,-164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-164,164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 3 A_SpawnItemEx("RS_RomeroGroundCH",164,164,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,-234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-234,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",234,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-234,-234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",234,-234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-234,234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 3 A_SpawnItemEx("RS_RomeroGroundCH",234,234,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(user_phase >= 2,"DukieMore");
		TNT1 A 0 A_JumpIf(user_phase >= 3,"DukieMore");
		Goto See;
	DukieMore:
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,-314,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,314,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-314,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",314,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-314,-314,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",314,-314,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-314,314,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 2 A_SpawnItemEx("RS_RomeroGroundCH",314,314,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,-394,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,394,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-394,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",394,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-394,-394,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",394,-394,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-394,394,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 2 A_SpawnItemEx("RS_RomeroGroundCH",394,394,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,-464,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",0,464,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-464,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",464,0,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-464,-464,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",464,-464,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 0 A_SpawnItemEx("RS_RomeroGroundCH",-464,464,0,0,1,0,0,SXF_NOCHECKPOSITION);
		MMDR E 2 A_SpawnItemEx("RS_RomeroGroundCH",464,464,0,0,1,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(user_phase >= 3,"See2");
		Goto See;
	Nukes:
		MMDR E 0 A_PlaySound("Rome/ATK2",0);
		MMDR E 10 Bright A_FaceTarget;
		MMDR H 0 A_PlaySound("");
		MMDR EEEEEEEEE 2 Bright A_SpawnItemEx("RS_WhiteFatNukeShow",random(-24,24),random(-24,24),64,0,0,12,0,SXF_NOCHECKPOSITION);
		MMDR EEEEEEEEE 2 Bright A_SpawnItemEx("RS_WhiteFatMark",random(-1524,1524),random(-1524,1524),6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(user_phase >= 2,"NukieFrontal");
		MMDR A 10 A_Jump(128,"DualShots","ChainMissiles");
		Goto See;
	NukieFrontal:
		MMDR EEEEEEE 1 Bright A_SpawnItemEx("RS_WhiteFatNukeShow",random(-24,24),random(-24,24),64,0,0,12,0,SXF_NOCHECKPOSITION);
		MMDR EEEEEEE 1 Bright A_SpawnItemEx("RS_WhiteFatMark",random(256,1524),random(-524,524),6,0,0,0,0,SXF_NOCHECKPOSITION);
		MMDR A 10 A_Jump(128,"DualShots","ChainMissiles2","SideWinder");
		Goto See;
	ChainMissiles:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR E 10 A_FaceTarget;
		MMDR H 0 A_PlaySound("");
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20);
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20,random(-3,3));
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20);
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20,random(-3,3));
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH3",120,-20);
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_Jump(32,"Missile");
		Goto See;
	ChainMissiles2:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR E 10 A_FaceTarget;
		MMDR H 0 A_PlaySound("");
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20);
		MMDR HI 4 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20,random(-3,3));
		MMDR HI 3 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20);
		MMDR HI 3 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20,random(-3,3));
		MMDR HI 2 Bright A_CustomMissile("RS_RomeroRocketCH3",120,-20);
		MMDR HI 2 Bright A_CustomMissile("RS_RomeroRocketCH3",120,-20);
		MMDR HI 1 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20,random(-6,6));
		MMDR HI 1 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20,random(-6,6));
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_Jump(64,"Missile");
		Goto See;
	ChainMissiles3:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR E 10 A_FaceTarget;
		MMDR H 0 A_PlaySound("");
		MMDR HI 2 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20);
		MMDR HI 2 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20,random(-3,3));
		MMDR HI 2 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20);
		MMDR HI 2 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20,random(-3,3));
		MMDR HI 1 Bright A_CustomMissile("RS_RomeroRocketCH3",120,-20);
		MMDR HI 1 Bright A_CustomMissile("RS_RomeroRocketCH3",120,-20);
		MMDR HI 1 Bright A_CustomMissile("RS_RomeroRocketCH2",120,-20,random(-6,6));
		MMDR HI 1 Bright A_CustomMissile("RS_RomeroRocketCH",120,-20,random(-6,6));
		TNT1 A 0 A_CheckSight("See2");
		TNT1 A 0 A_Jump(64,"Missile");
		Goto See2;
	LaserRain:
		MMDR E 0 A_PlaySound("Rome/ATK1",0);
		MMDR EEEE 3 A_FaceTarget;
		MMDR JKLKJ 2 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
		MMDR MO 3 Bright;
		MMDR O 3 Bright A_VileTarget("RS_RomeroSkyCH");
		Goto Missile;
	BigLaser:
		MMDR EEEE 3 A_FaceTarget;
		MMDR E 0 A_PlaySound("Rome/ATK2",CHAN_WEAPON,1,0,0);
		MMDR JKLKJ 3 Bright A_FaceTarget;
		MMDR JKLKJ 2 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(1000,"SweepBeam",true);
		MMDR M 0 A_PlaySound("Rome/ATK2",CHAN_AUTO,1,0,0);
		MMDR MNOOOOOOOOO 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0);
		TNT1 A 0 A_GiveInventory("RS_RomeroCHWeak",1);
		Goto See;
	BigLaser2:
		MMDR EEEE 2 A_FaceTarget;
		MMDR E 0 A_PlaySound("Rome/ATK2",CHAN_WEAPON,1,0,0);
		MMDR JKLKJ 2 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(1000,"SweepBeam",true);
		MMDR M 0 A_PlaySound("",CHAN_AUTO,1,0,0);
		MMDR MNOOOOOOOOO 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0);
		MMDR O 1 Bright A_FaceTarget;
		MMDR OOO 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0);
		MMDR O 1 Bright A_FaceTarget;
		MMDR OOO 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0);
		MMDR O 1 Bright A_FaceTarget;
		MMDR OOO 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0);
		TNT1 A 0 A_GiveInventory("RS_RomeroCHWeak",1);
		Goto See;
	LaserSweeper:
		MMDR EEE 2 A_FaceTarget;
		MMDR E 0 A_PlaySound("Rome/ATK2",CHAN_WEAPON,1,0,0);
		MMDR JKLKJ 3 Bright A_FaceTarget;
		MMDR JKLKJ 2 Bright A_FaceTarget;
		MMDR JKLKJ 1 Bright A_FaceTarget;
	SweepBeam:
		MMDR M 1 Bright A_FaceTarget;
		MMDR M 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR N 1 Bright A_FaceTarget;
		MMDR N 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-4);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-3);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		MMDR O 1 Bright A_FaceTarget;
		MMDR O 1 Bright A_CustomMissile("RS_RomeroBeamCH",60,0,0,0,-2);
		TNT1 A 0 A_GiveInventory("RS_RomeroCHWeak",1);
		TNT1 A 0 A_JumpIf(user_phase >= 3,"See2");
		Goto See;
	Death:
		TNT1 A 0 A_SetTranslucent(1);
		MMDR P 10 Bright A_Scream;
		MMDR PPPPP 10 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		MMDR QRS 10 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		MMDR T 10 Bright A_NoBlocking;
		MMDR UV 10 Bright;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TNT1 A 0 A_BossDeath;
		MMDR W -1;
		Stop;
	}
}
