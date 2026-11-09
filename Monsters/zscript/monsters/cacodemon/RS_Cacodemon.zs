// ============================================================================
// RS_Cacodemon.zs -- Colourful Hell Cacodemon family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Cacodemons.txt (3876 lines,
// read whole). Every actor cites its CH line. Support: RS_CacodemonFX.zs
// (see its header for cross-lane notes, proven-missing assets, and standing
// strips).
// Tier ladder as before: CH icon index -- 1 Common, 2 Green, 3 Blue,
// 4 Purple, 5 Yellow (Cacolich), 6 Red, 7 FireBlu, 8 Gray (Stone Cold),
// 9 Abyss, 10 Black boss (SHOCKMASTER, both EX and non-EX), 11 White boss
// (both phases), 12 Cyan (FrostBaller), 13 Brown (Grell). Minions and
// summons (VoidField, RedSpikeCacoEX, WhiteCacoOrb1, BloodRainerCaco,
// WhiteCacoFake, SummonPortalCybie) get no token.
// CyanCaco2 is CH's DOUBLE-LABEL case: Cacodemons.txt defines "See:" twice
// (:320 and :327). DECORATE's last definition wins, so the A_FastChase
// block is the live one; the first block (and its jump to a "See2" label
// that exists nowhere) is orphaned dead code in CH -- preserved as a
// comment at site.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Cacodemons.txt:1 -- Colourset7 replaces Cacodemon.
// ---------------------------------------------------------------------------
class RS_Colourset7 : RandomSpawner replaces Cacodemon
{
	Default
	{
		DropItem "RS_CommonCaco", 255, 700;
		DropItem "RS_GreenCaco", 255, 400;
		DropItem "RS_CyanCaco", 255, 100;
		DropItem "RS_BrownCaco", 255, 130;
		DropItem "RS_BlueCaco", 255, 200;
		DropItem "RS_AbyssCaco", 255, 40;
		DropItem "RS_PurpleCaco", 255, 60;
		DropItem "RS_GrayCaco", 255, 60;
		DropItem "RS_YellowCaco", 255, 40;
		DropItem "RS_RedCaco", 255, 40;
		DropItem "RS_FireBluCaco", 255, 35;
		DropItem "RS_BlackCaco", 255, 3;
		DropItem "RS_WhiteCaco", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// The cvar gate stubs.  CH ran CallACS("CH_*") reads; here they are
// RS_Zom.CV('rs_ch_*', 1) with CH's exact value semantics
// (1 = colour off / reroll into the dial, 3 = fifty-fifty).
// ---------------------------------------------------------------------------

class RS_BrownCaco : Actor   // CH Cacodemons.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset7",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanCaco : Actor   // CH Cacodemons.txt:235 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset7",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssCaco : Actor   // CH Cacodemons.txt:467 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset7",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluCaco : Actor   // CH Cacodemons.txt:777 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset7",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayCaco : Actor   // CH Cacodemons.txt:796 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset7",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackCaco : Actor   // CH Cacodemons.txt:2073 -- gates CH_BlackBossy + CH_ExBoss
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedCaco",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteCaco : Actor   // CH Cacodemons.txt:3191 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackCaco",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN ("Gruelsome").  CH: Cacodemons.txt:40.  The Grell: pack
// healer/buffer that scatters healing motes and hands out the PE speed buff.
// ---------------------------------------------------------------------------
class RS_BrownCaco2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Tag "Gruelsome";
		Health 500;
		Radius 24;
		Height 56;
		Mass 400;
		Speed 18;
		Obituary "%o was dirt written by brown caco";
		SeeSound "grell/sight";
		PainSound "grell/pain";
		DeathSound "grell/death";
		ActiveSound "grell/active";
		Monster;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+MISSILEMORE
		+NOGRAVITY
		+FLOAT
		+FLOATBOB
		+NOFEAR
		+NOTARGET
		PainChance 64;
		Species "Caco";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DropItem "RS_CH_MegaSphere", 12;
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Berserk", 128;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
	}
	States
	{
	Spawn:
		GREL A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		GREL A 0 A_SentinelBob;
		GREL AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GREL B 0 A_SentinelBob;
		GREL BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CheckProximity("Scatter","Cacodemon",600,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		GREL D 0 A_PlaySound("grell/attack");
		GREL D 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GREL E 4 Bright A_FaceTarget;
		GREL F 4 Bright A_CustomMissile("RS_GrellBallBrown",32,0,0);
		Goto See;
	Scatter:
		TNT1 A 0 A_Jump(64,"HealAndBuff");
		Goto Missile+3;
	HealAndBuff:
		GREL D 0 A_PlaySound("Caco/sight");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GREL DDD 2 A_SpawnItemEx("RS_MediCacoBrown",random(-64,64),random(-64,64),random(-16,32),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		GREL E 1 A_RadiusGive("RS_SpeedBuffPE",1200,RGF_MONSTERS,1,null,"Caco");
		GREL E 1 A_RadiusGive("RS_BrownImpCommand",200,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownCaco2","Caco");
		GREL E 1 A_RadiusGive("Health",1200,RGF_MONSTERS,200,null,"Caco");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GREL FFF 2 A_SpawnItemEx("RS_MediCacoBrown",random(-64,64),random(-64,64),random(-16,32),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		GREL E 3 A_RadiusGive("Health",1200,RGF_MONSTERS,200,null,"Caco");
		GREL D 0 A_PlaySound("Caco/sight");
		GREL EDD 3 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(-16,32),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		GREL F 3 A_RadiusGive("Health",1200,RGF_MONSTERS,200,null,"Caco");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GREL FDD 3 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(-16,32),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		GREL E 3 A_RadiusGive("Health",1200,RGF_MONSTERS,200,null,"Caco");
		GREL EDD 3 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(-16,32),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Pain:
		GREL G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		GREL G 3 A_Pain;
		Goto See;
	Death:
		GREL H 5;
		TNT1 A 0 { bFLOATBOB = false; }   // CH: A_changeflag("FLOATBOB",FALSE)
		GREL I 0 A_NoBlocking;
		GREL I -1 A_Scream;
	Crash:
		GREL J 4 A_PlaySound("grell/thud",CHAN_AUTO);
		TNT1 A 0 { bFLOATBOB = false; }
		GREL K 4 A_UnSetSolid;
		GREL LM 4 A_SetFloorClip;
		GREL N -1;
		Stop;
	Raise:
		GREL M 5 A_UnSetFloorClip;
		GREL LKJIH 5;
		TNT1 A 0 { bFLOATBOB = true; }   // CH: A_changeflag("FLOATBOB",TRUE)
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN ("FrostBaller").  CH: Cacodemons.txt:257.  Fast-chasing
// ice thrower; the double-See case documented in the file header.
// ---------------------------------------------------------------------------
class RS_CyanCaco2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		HitObituary "%o was icicled by cyan Cacodemon";
		Health 500;
		Species "Caco";
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 0.2;     // CH lists it twice (bare :265, quoted :268) -- kept once
		DamageFactor "Melee", 2.0;   // CH lists it twice (:266, :269) -- kept once
		DamageFactor "Fire", 1.5;    // CH lists it twice (:267, :270) -- kept once
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 128;
		PainChance "Melee", 128;
		PainThreshold 26;
		Radius 31;
		Height 56;
		Mass 800;
		Speed 24;
		FloatSpeed 24;
		PainChance 110;
		Monster;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+MISSILEMORE
		+NOGRAVITY
		+FLOAT
		+FLOATBOB
		+NOFEAR
		+NOICEDEATH
		Scale 0.8;
		SeeSound "Cracko/See";
		PainSound "cracko/pain";
		DeathSound "caco/death";
		ActiveSound "monster/helact";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		Translation "0:255=%[0.00,0.00,2.00]:[1.01,2.00,2.00]";
		Tag "FrostBaller";
	}
	States
	{
	Spawn:
		HELE A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	// CH: Cacodemons.txt:320-326 defines a FIRST "See:" block here --
	//   HELE AAAAAA 3 a_chase / icon / HELE AAAAAA 3 A_Chase / icon /
	//   TNT1 A 0 A_jump(128,"See2") / Goto See
	// -- overridden by the second "See:" below (DECORATE last-wins), and
	// "See2" exists nowhere in CH. Orphaned dead code, kept as this comment.
	See:
		HELE AAAAA 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE AAAAA 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Melee:
	Missile:
		HELE EF 5 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128,"WaveIt");
		HELE G 3 Bright A_CustomMissile("RS_BigIceCaco",28,0,0,0,0);
		HELE G 3 Bright A_CustomMissile("RS_BigIceCaco",28,0,randompick(-10,10,-7,7,-5,5),0,0);
		HELE FE 8 Bright;
		Goto See;
	WaveIt:
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,randompick(-15,10),0,0);
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,randompick(-10,5),0,0);
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,-5,0,0);
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,0,0,0);
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,5,0,0);
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,randompick(-5,10),0,0);
		HELE G 2 Bright A_CustomMissile("RS_SmallIceCaco",24,0,randompick(15,-10),0,0);
		HELE FE 8 Bright;
		Goto See;
	Pain:
		HELE H 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE H 3 A_Pain;
		HELE H 3;
		Goto Dodge;
	Dodge:
		HELE AAA 1 A_Wander;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE AAA 2 A_FastChase;
		HELE AAA 3 A_Wander;
		HELE AAA 4 A_FastChase;
		Goto See;
	Death:
		HELE I 5 Bright A_Scream;
		HELE JKL 5 Bright;
		HELE M 5 Bright A_NoBlocking(false);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,254);
		HELE M 0 A_IceGuyDie;
		HELE V -1 A_SetFloorClip;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS ("Abyssmal Tomatoe quality").  CH: Cacodemons.txt:490.
// Black-blooded spam boss with the seeking Hidi flame and pack heal.
// ---------------------------------------------------------------------------
class RS_AbyssCaco2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 1100;
		Speed 20;
		FloatSpeed 15;
		Radius 32;
		Height 52;
		PainChance 64;
		BloodColor "Black";
		Species "Caco";
		Mass 100;
		MeleeDamage 12;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "Cracko/See";
		ActiveSound "Caco/Active";
		PainSound "Cracko/Pain";
		DeathSound "Caco/Death";
		MeleeSound "Caco/Melee";
		Obituary "%o was met with deadly force from abyss caco";
		HitObituary "%o became abyss caco's snack";
		DropItem "RS_CH_MegaSphere", 32;
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Berserk", 128;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		Monster;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+MISSILEMORE
		+NOGRAVITY
		+FLOAT
		+FLOATBOB
		+NOFEAR
		Translation "192:207=0:0","160:167=0:0","224:231=0:0","208:223=0:0","248:249=0:0","48:63=0:0","16:31=0:0","232:235=0:0","64:79=0:0","128:151=0:0","112:127=0:0","80:111=%[0.06,0.04,0.09]:[0.31,0.31,0.41]","80:95=%[0.43,0.27,0.50]:[0.71,0.39,0.51]";
		Tag "Abyssmal Tomatoe quality";
	}
	States
	{
	Spawn:
		VCCM A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VCCM AA 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-3,3),random(-3,3),random(5,32));
		Loop;
	Melee:
		VCCM B 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VCCM C 5 Bright A_FaceTarget;
		VCCM D 5 Bright A_MeleeAttack;
		VCCM B 1 A_SpawnItemEx("RS_Zap88",1,3,22,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
		VCCM B 1 A_SpawnItemEx("RS_Zap88",-3,6,22,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
		VCCM B 1 A_SpawnItemEx("RS_Zap88",4,-1,22,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
		VCCM B 1 A_SpawnItemEx("RS_Zap88",3,1,22,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
		VCCM B 2 A_Jump(88,"Missile");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VCCM B 1 A_RadiusGive("RS_SpeedBuffPE",800,RGF_MONSTERS,1,null,"Caco");
		VCCM A 0 A_JumpIfCloser(1000,"Choice");
		Goto Hidious;
	Choice:
		VCCM A 0 A_Jump(255,"Spam","Hidious");
		Goto See;
	Spam:
		VCCM B 5 A_FaceTarget;
		VCCM C 5 Bright A_FaceTarget;
		VCCM D 5 A_FaceTarget;
		VCCM B 0 A_CustomMissile("RS_AbyssCacoBalls",24,0,0,1);
		VCCM B 0 A_CustomMissile("RS_AbyssCacoBalls",24,0,-13,1);
		VCCM B 5 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,13,1);
		VCCM B 5 A_CheckSight("See");
		VCCM C 4 Bright A_FaceTarget;
		VCCM D 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-13,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-10,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-7,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-4,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-1,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,2,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,5,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,8,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,11,1);
		VCCM B 5 A_CheckSight("See");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VCCM C 3 Bright A_FaceTarget;
		VCCM D 3 A_FaceTarget;
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,13,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,10,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,7,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,4,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,1,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-2,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-5,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-8,1);
		VCCM B 1 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,-11,1);
		VCCM B 5 A_CheckSight("See");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VCCM C 2 Bright A_FaceTarget;
		VCCM D 2 A_FaceTarget;
		VCCM BBBBB 0 A_CustomMissile("RS_AbyssCacoBalls",24,random(-23,1),0,1);
		VCCM BBBBB 0 A_CustomMissile("RS_AbyssCacoBalls",24,0,random(-1,23),1);
		VCCM B 5 Bright A_CustomMissile("RS_AbyssCacoBalls",24,0,0,1);
		Goto See;
	Hidious:
		VCCM B 1 A_PlaySound("caco/sight",7,2,false,ATTN_NONE);
		VCCM B 12 Bright A_FaceTarget;
		VCCM CCCC 4 Bright A_SpawnItemEx("RS_Zap88",16,random(-16,16),random(12,42),0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERTRANSLATION);
		VCCM C 8 Bright A_FaceTarget;
		VCCM C 5 Bright A_CustomMissile("RS_AbyssCacoHidi",24,0,0,1);
		VCCM D 5 Bright A_FaceTarget;
		VCCM B 5 Bright;
		Goto See;
	Pain:
		VCCM E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VCCM E 3 A_Pain;
		VCCM E 3 Bright A_RadiusGive("Health",800,RGF_MONSTERS,200,null,"Caco");
		VCCM FFFFFFFF 1 A_Wander;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VCCM G 8 { bFLOATBOB = false; }   // CH: A_ChangeFlag(FLOATBOB,0)
		VCCM H 8 A_Scream;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32),1,1,2,random(-359,359));
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-68,68),random(-68,68),random(5,32),1,1,3,random(-359,359),SXF_NOCHECKPOSITION);
		VCCM IJ 8;
		VCCM K 8 A_NoBlocking;
		VCCM L -1 A_SetFloorClip;
		Stop;
	Raise:
		VCCM L 8 A_UnSetFloorClip;
		VCCM KJIHG 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY ("Stone Cold Cacodemon").  CH: Cacodemons.txt:815.
// Skull-rushing rock spitter with the dash budget (user_nodash3).
// ---------------------------------------------------------------------------
class RS_GrayCaco2 : Cacodemon
{
	int user_nodash3;   // CH: Var int User_nodash3
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 650;
		GibHealth 60;
		BloodColor "White";
		Species "Caco";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 500;
		Speed 9;
		PainChance 90;
		Damage 5;   // bare constant stays bare
		Monster;
		+MISSILEMORE
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "caco/death";
		ActiveSound "caco/active";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_Cell", 72;
		DropItem "RS_CH_Cell", 72;
		DropItem "RS_CH_Cell", 72;
		Obituary "%o was stone cold cacod";
		HitObituary "%o got rolled over like a stone and moss";
		Translation "32:47=96:111","176:186=94:103","189:191=236:239","187:188=236:237","16:31=95:97","168:175=85:87","112:127=0:2","192:207=0:0","240:247=0:0","224:231=0:0","160:167=0:0","248:249=0:0","208:223=0:0","0:0=0:0";
		Tag "Stone Cold Cacodemon";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HEAD A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		HEAD BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD C 0 A_JumpIfCloser(900,"Rusher1");
		HEAD C 0 { user_nodash3 = user_nodash3 - 5; }   // CH: A_setuservar("User_nodash3",User_nodash3-5)
		HEAD C 0 A_Jump(255,"Woosh");
		Goto See;
	Rusher1:
		HEAD C 0 A_JumpIf(user_nodash3 >= 13,"Woosh");
		HEAD C 0 { user_nodash3 = user_nodash3 + 5; }
		HEAD C 2 A_SkullAttack(50);
		Goto Melee;
	Woosh:
		HEAD D 3 Bright A_FaceTarget;
		HEAD D 5 Bright A_CustomMissile("RS_CacoRockBreath",32,0,random(-1,1));
		HEAD D 4 Bright A_CustomMissile("RS_CacoRockBreath",32,0,random(-3,3));
		HEAD D 3 Bright A_CustomMissile("RS_CacoRockBreath",32,0,random(-5,5));
		HEAD D 2 Bright A_CustomMissile("RS_CacoRockBreath",32,0,random(-8,8));
		HEAD D 1 Bright A_CustomMissile("RS_CacoRockBreath",32,0,random(-11,11));
		HEAD D 0 { user_nodash3 = user_nodash3 - 2; }
		Goto See;
	Melee:
		HEAD BC 8 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD D 7 A_CustomMeleeAttack(random(5,50),"bite/bite4");
		HEAD D 4 A_Stop;
		HEAD D 0 A_CheckSight("See");
		Goto Rusher1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		HEAD E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Death:
		TNT1 AAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile("RS_WDRock4",32,0,random(-359,359));
		CACO A 4 A_XScream;
		CACO B 4 A_NoBlocking;
		CACO CD 4;
		CACO E 4 A_SetFloorClip;
		CACO EEE 5 A_FadeOut(0.33);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU ("One Ugly Tomatoe").  CH: Cacodemons.txt:922.
// Bouncing-fireball thrower; its Raise can Grow into Purple.
// ---------------------------------------------------------------------------
class RS_FireBluCaco2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 800;
		GibHealth 58;
		Species "Caco";
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 13;
		PainChance 110;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEEVENMORE
		+MISSILEMORE
		+DONTHARMCLASS
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "caco/death";
		ActiveSound "caco/active";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "RS_CH_BlueArmor", 64;
		Obituary "%o was petted by fireblu cacodemon";
		Translation "16:31=197:207","32:43=240:247","167:167=207:207","127:127=247:247","124:126=46:47","121:123=181:184","118:120=178:180","115:117=174:176","112:114=168:168","106:111=240:247","98:105=202:207","96:97=200:202","91:95=179:184","85:90=174:181","80:85=171:177","0:0=0:0";
		Tag "One Ugly Tomatoe";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HEAD A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		HEAD BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD D 5 Bright A_CustomMissile("RS_FireBluCacoBall",32,0,random(-5,5));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		HEAD E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HEAD G 8;
		HEAD H 8 A_Scream;
		HEAD IJ 8;
		HEAD K 8 A_NoBlocking;
		HEAD L -1 A_SetFloorClip;
		Stop;
	XDeath:
		CACO A 7 A_XScream;
		CACO B 7 A_NoBlocking;
		CACO C 7;
		CACO D 7;
		CACO E -1 A_SetFloorClip;
		Stop;
	Raise:
		HEAD L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		HEAD KJIHG 5;
		Goto See;
	Grow:
		HEAD KJIHG 5;
		HEAD A 0 A_SpawnItemEx("RS_PurpleCaco",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON.  CH: Cacodemons.txt:1119.  The baseline; its Raise can
// Grow into Green.
// ---------------------------------------------------------------------------
class RS_CommonCaco : Cacodemon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "Caco";
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		GibHealth 58;
		MeleeThreshold 80;
		Tag "Cacodemon";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HEAD A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Pain:
		HEAD E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Missile:
		HEAD BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD D 5 Bright A_CustomComboAttack("CacodemonBall",32,10 * random(1,6),"Bite/bite4");   // vanilla class; RS_CacodemonBall2 replaces it at spawn, as in CH
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HEAD G 8;
		HEAD H 8 A_Scream;
		HEAD IJ 8;
		HEAD K 8 A_NoBlocking;
		HEAD L -1 A_SetFloorClip;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported (owner: vanilla gore ok)
		CACO A 7 A_XScream;
		CACO B 7 A_NoBlocking;
		CACO CD 7;
		// CH: TNT1 A 0 A_SpawnItemEx("CHGore_Gib11",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO E -1 A_SetFloorClip;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Raise:
		HEAD L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		HEAD KJIHG 5;
		Goto See;
	Grow:
		HEAD KJIHG 5;
		HEAD A 0 A_SpawnItemEx("RS_GreenCaco",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN.  CH: Cacodemons.txt:1197.  Baron-spit; Grows into Blue.
// ---------------------------------------------------------------------------
class RS_GreenCaco : Cacodemon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 450;
		GibHealth 58;
		Species "Caco";
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 8;
		PainChance 110;
		Monster;
		+FLOAT
		+NOGRAVITY
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "caco/death";
		ActiveSound "caco/active";
		DropItem "HealthBonus";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		Obituary "%o fell to green caco's spit";
		HitObituary "%o got green chomp'd";
		Translation "171:191=112:127","16:31=152:159","32:47=125:127","167:167=127:127","223:223=247:247";
		Tag "Green Cacodemon";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HEAD A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Missile:
		HEAD BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD D 5 Bright A_CustomMissile("RS_Cacospit1",32,0,random(-1,1));
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD BC 8 A_FaceTarget;
		HEAD D 7 A_CustomMeleeAttack(random(5,50),"bite/bite4");
		Goto See;
	Pain:
		HEAD E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HEAD G 8;
		HEAD H 8 A_Scream;
		HEAD IJ 8;
		HEAD K 8 A_NoBlocking;
		HEAD L -1 A_SetFloorClip;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO A 7 A_XScream;
		CACO B 7 A_NoBlocking;
		// CH: TNT1 A 0 A_SpawnItemEx("CHGore_Gib11",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO CD 7;
		CACO E -1 A_SetFloorClip;
		Stop;
	Raise:
		HEAD L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		HEAD KJIHG 5;
		Goto See;
	Grow:
		HEAD KJIHG 5;
		HEAD A 0 A_SpawnItemEx("RS_BlueCaco",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE.  CH: Cacodemons.txt:1326.  Holy-volley thrower; Grows
// into Purple.  lostsouls.txt:2980 spawns it (read-only there).
// ---------------------------------------------------------------------------
class RS_BlueCaco : Cacodemon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 480;
		GibHealth 58;
		Species "Caco";
		Radius 31;
		Height 56;
		Mass 450;
		Speed 10;
		PainChance 100;
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+MISSILEMORE
		+FLOAT
		+NOGRAVITY
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "caco/death";
		ActiveSound "caco/active";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_HealthBundle", 74;
		DropItem "RS_HealthBundle", 32;
		DropItem "RS_HealthBundle", 12;
		Obituary "%o met the big blue head";
		HitObituary "%o was nommed up by Blue Caco";
		Translation "171:191=192:207","16:31=200:207","32:47=244:247","167:167=247:247","223:223=247:247";
		Tag "Blue Cacodemon";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HEAD A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		HEAD BC 8 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD D 7 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-1,1));
		HEAD D 5 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-3,3));
		HEAD D 4 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-5,5));
		HEAD D 2 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-4,4));
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD BC 8 A_FaceTarget;
		HEAD D 7 A_CustomMeleeAttack(random(5,50),"bite/bite4");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		HEAD E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HEAD G 8;
		HEAD H 8 A_Scream;
		HEAD IJ 8;
		HEAD K 8 A_NoBlocking;
		HEAD L -1 A_SetFloorClip;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO A 7 A_XScream;
		CACO B 7 A_NoBlocking;
		// CH: TNT1 A 0 A_SpawnItemEx("CHGore_Gib11",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO CD 7;
		CACO E -1 A_SetFloorClip;
		Stop;
	Raise:
		HEAD L 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		HEAD KJIHG 5;
		Goto See;
	Grow:
		HEAD KJIHG 5;
		HEAD A 0 A_SpawnItemEx("RS_PurpleCaco",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE.  CH: Cacodemons.txt:1461.  Skull-rusher with seekers
// and the dash budget.
// ---------------------------------------------------------------------------
class RS_PurpleCaco : Cacodemon
{
	int user_nodash3;   // CH: Var int User_nodash3
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 528;
		GibHealth 60;
		BloodColor "Blue";
		Species "Caco";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 500;
		Speed 11;
		PainChance 90;
		Damage 3;   // bare constant stays bare
		Monster;
		+MISSILEMORE
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "caco/death";
		ActiveSound "caco/active";
		DropItem "RS_HealthBundle", 128;
		DropItem "HealthBonus";
		DropItem "RS_CH_Cell", 64;
		Obituary "%o turned quite purple themselves";
		HitObituary "%o got too close to Purple Caco";
		Translation "171:191=250:254","16:31=250:254","32:47=254:254","167:167=247:247","223:223=247:247","112:127=160:167";
		Tag "Purple Cacodemon";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HEAD A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		HEAD BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD C 0 A_JumpIfCloser(300,"Rusher1");
		HEAD C 0 { user_nodash3 = user_nodash3 - 3; }   // CH: A_setuservar("User_nodash3",User_nodash3-3)
		HEAD C 0 A_Jump(255,"Woosh");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Rusher1:
		HEAD C 0 A_JumpIf(user_nodash3 >= 11,"Woosh");
		HEAD C 0 { user_nodash3 = user_nodash3 + 5; }
		HEAD C 2 A_SkullAttack(25);
		Goto Melee;
	Woosh:
		HEAD D 0 A_FaceTarget;
		HEAD D 5 Bright A_CustomMissile("RS_Cacofire3",32,0,random(-1,1));
		HEAD D 0 A_CustomMissile("RS_Cacofire4",32,0,8);
		HEAD D 0 A_CustomMissile("RS_Cacofire4",32,0,-8);
		HEAD D 0 { user_nodash3 = user_nodash3 - 2; }
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD BC 8 A_FaceTarget;
		HEAD D 7 A_CustomMeleeAttack(random(5,50),"bite/bite4");
		Goto See;
	Pain:
		HEAD E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HEAD G 8;
		HEAD H 8 A_Scream;
		HEAD IJ 8;
		HEAD K 8 A_NoBlocking;
		HEAD L -1 A_SetFloorClip;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO A 7 A_XScream;
		CACO B 7 A_NoBlocking;
		CACO CD 7;
		// CH: TNT1 A 0 A_SpawnItemEx("CHGore_Gib11",0,0,32,VelX,VelY,VelZ,0,...) -- gore chain not imported
		CACO E -1 A_SetFloorClip;
		Stop;
	Raise:
		HEAD L 8 A_UnSetFloorClip;
		HEAD KJIHG 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW ("Yellow Cacolich").  CH: Cacodemons.txt:1640.  The
// phasing lich: void fields, bouncing flame, stealth wander.
// lostsouls.txt:2984 spawns it (read-only there).
// ---------------------------------------------------------------------------
class RS_YellowCaco : Cacodemon
{
	int user_VoidField;   // CH: Var Int User_VoidField
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 720;
		Speed 12;
		Radius 31;
		Height 56;
		PainChance 80;
		Mass 500;
		BloodColor "Yellow";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "Caco";
		SeeSound "CacoLich/Sight";
		ActiveSound "CacoLich/Active";
		PainSound "CacoLich/Pain";
		DeathSound "CacoLich/Death";
		Obituary "Look, %o !, its a bird! its a plane! no, its Orange Cacodemon!";
		DropItem "RS_CH_MegaSphere", 12;
		DropItem "RS_HealthBundle", 146;
		DropItem "RS_ArmorBundle", 64;
		Monster;
		+DONTHARMSPECIES
		+DONTHARMCLASS
		-NORADIUSDMG
		+MISSILEMORE
		+NOGRAVITY
		+FLOAT
		+NOFEAR
		Translation "112:127=160:167";
		Tag "Yellow Cacolich";
	}
	States
	{
	Spawn:
		CALI A 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CALI A 0 A_SetTranslucent(1);
		CALI A 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Dodge1:
		CALI A 5 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		Goto See;
	Dodge2:
		CALI A 5 ThrustThing(int(angle*256/360+192),20,0,0);
		Goto See;
	Missile:
		CALI B 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CALI B 0 A_JumpIf(user_VoidField == 0,"VoidField");
		CALI B 0 A_JumpIfCloser(1000,"SpitFlame");
		CALI B 0 A_Jump(255,"SeekAndKill");
		Goto See;
	SpitFlame:
		CALI DEF 8 Bright A_FaceTarget;
		CALI G 6 A_CustomMissile("RS_SpitFireCaco",35,0,random(-3,3));
		CALI FED 6 A_FaceTarget;
		CALI E 1 A_JumpIfTargetInLOS("RefireYes");
		Goto See;
	RefireYes:
		CALI F 1 A_Jump(176,"SpitFlame");
		Goto See;
	SeekAndKill:
		CALI A 5 A_SetTranslucent(0.3);
		CALI A 5 A_SetSpeed(42);
		CALI AAAAAAAAAAA 2 A_Wander;
		CALI A 5 A_SetTranslucent(0.1);
		CALI AAAAAAAAAAA 2 A_Wander;
		CALI A 5 A_SetTranslucent(0.3);
		CALI AAAAAAAAAAA 2 A_Wander;
		CALI A 5 A_SetSpeed(12);
		CALI A 2 A_JumpIfCloser(1000,"See");
		CALI A 2 A_Jump(12,"See");
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CALI EF 7 A_FaceTarget;
		CALI G 6 A_CustomMeleeAttack(random(5,64),"bite/bite4");
		CALI FE 6;
		Goto See;
	VoidField:
		CALI EF 8 Bright;
		CALI G 6 A_SpawnItemEx("RS_VoidField",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		CALI G 0 A_SpawnItemEx("RS_VoidField",random(-280,280),random(-280,280),random(-16,32),0,0,0,SXF_NOCHECKPOSITION);
		CALI G 0 A_SpawnItemEx("RS_VoidField",random(-280,280),random(-280,280),random(-16,32),0,0,0,SXF_NOCHECKPOSITION);
		CALI G 0 A_SpawnItemEx("RS_VoidField",random(-380,380),random(-380,380),random(-32,32),0,0,0,SXF_NOCHECKPOSITION);
		CALI G 0 A_SpawnItemEx("RS_VoidField",random(-380,380),random(-380,380),random(-32,32),0,0,0,SXF_NOCHECKPOSITION);
		CALI FE 6 { user_VoidField = user_VoidField + 1; }   // CH: A_SetUserVar("User_VoidField",User_VoidField+1) -- fires once per frame, twice, as in CH
		Goto Missile;
	Pain:
		CALI H 0 A_SetSpeed(12);
		CALI H 0 A_SetTranslucent(1);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CALI H 3 { user_VoidField = (user_VoidField == 0) ? 1 : 0; }   // CH: A_SetUserVar("User_VoidField",User_VoidField==0)
		CALI I 6 A_Pain;
		CALI I 0 A_Jump(128,"Dodge1","Dodge2");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CALI J 0 A_SetFloorClip;
		CALI J 6 A_Scream;
		CALI KLMN 6;
		Wait;
	Crash:
		CALI OP 6;
		CALI Q 6 A_NoBlocking;
		CALI R 6;
		CALI S -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED ("Red Cacodemon").  CH: Cacodemons.txt:1852.  Blood-spam
// thrower with the rage counter (user_Tick2) and the sludge bomb.
// ---------------------------------------------------------------------------
class RS_RedCaco : Actor
{
	int user_Tick2;   // CH: Var Int User_Tick2
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 830;
		Speed 14;
		FloatSpeed 15;
		Radius 32;
		Height 52;
		PainChance 64;
		BloodColor "FF 00 00";
		Species "Caco";
		Mass 1000;
		MeleeDamage 10;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "Cracko/See";
		ActiveSound "Caco/Active";
		PainSound "Cracko/Pain";
		DeathSound "Caco/Death";
		MeleeSound "Caco/Melee";
		Obituary "%o got bloodrocuted by Red Caco";
		HitObituary "%o was eaten by Red Caco";
		DropItem "RS_CH_MegaSphere", 10;
		DropItem "RS_HealthBundle", 162;
		DropItem "RS_ArmorBundle", 88;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Berserk", 82;
		Monster;
		+DONTHARMCLASS
		+MISSILEMORE
		+NOGRAVITY
		+FLOAT
		+FLOATBOB
		+NOFEAR
		Translation "106:111=181:191","192:207=0:0";
		Tag "Red Cacodemon";
	}
	States
	{
	Spawn:
		HED9 A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HED9 A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		HED9 B 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HED9 C 5 Bright A_FaceTarget;
		HED9 D 5 Bright A_MeleeAttack;
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",1,3,22,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",-3,6,22,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",4,-1,22,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 B 3 A_SpawnItemEx("RS_RedThingsLS",3,1,22,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HED9 A 0 A_Jump(255,"Spam","Sludgebomb");
		Goto See;
	Spam:
		HED9 B 5 A_FaceTarget;
		HED9 C 5 Bright A_FaceTarget;
		HED9 D 5 A_FaceTarget;
		HED9 B 0 A_CustomMissile("RS_CrackodemonBall",24,0,0,1);
		HED9 B 0 A_CustomMissile("RS_CrackodemonBall",24,0,-8,1);
		HED9 B 5 Bright A_CustomMissile("RS_CrackodemonBall",24,0,8,1);
		HED9 B 0 A_Jump(128,"MoreSpam");
		Goto See;
	SludgeBomb:
		HED9 B 12 A_FaceTarget;
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",1,3,32,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",-3,6,32,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",4,-1,32,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 B 1 A_SpawnItemEx("RS_RedThingsLS",3,1,32,0,0,0,0,SXF_NOCHECKPOSITION);
		HED9 C 5 Bright A_CustomMissile("RS_SbombCaco",24,0,0,1);
		HED9 D 5 Bright A_FaceTarget;
		HED9 B 5 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCaco2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	MoreSpam:
		HED9 B 5 A_FaceTarget;
		HED9 C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,16,1);
		HED9 C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,12,1);
		HED9 B 0 A_FaceTarget;
		HED9 C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,8,1);
		HED9 C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,4,1);
		HED9 B 0 A_FaceTarget;
		HED9 D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,0,1);
		HED9 D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-4,1);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HED9 B 0 A_FaceTarget;
		HED9 D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-8,1);
		HED9 D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-12,1);
		HED9 B 0 A_FaceTarget;
		HED9 B 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-16,1);
		HED9 B 4 Bright;
		HED9 B 1 Bright A_MonsterRefire(24,"See");
		Goto Spam;
	Pain:
		HED9 E 3 A_JumpIf(user_Tick2 >= 5,"ThatsIt");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HED9 E 3 A_Pain;
		HED9 F 6 { user_Tick2 = user_Tick2 + 1; }   // CH: A_SetUserVar("User_Tick2",User_Tick2+1)
		Goto See;
	ThatsIt:
		HED9 D 4 A_PlaySound("Cracko/See");
		HED9 D 4 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		HED9 D 4 A_CustomMissile("RS_EffectHK",32,0);
		HED9 D 4 A_SetSpeed(34);
		HED9 D 12 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileevenMore",TRUE)
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HED9 G 8 { bFLOATBOB = false; }   // CH: A_ChangeFlag(FLOATBOB,0)
		HED9 H 8 A_Scream;
		HED9 IJ 8;
		HED9 K 8 A_NoBlocking;
		HED9 L -1 A_SetFloorClip;
		Stop;
	Raise:
		HED9 L 8 A_UnSetFloorClip;
		HED9 KJIHG 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK ("SHOCKMASTER").  CH: Cacodemons.txt:2109.
// Announcers dropped per owner.
// ---------------------------------------------------------------------------
class RS_BlackCaco2 : Actor
{
	int user_DO2;   // CH: Var int User_DO2
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o got extra well bloodcrocuted by Black Cacodemon";
		HitObituary "%o got chomped by a Black Cacodemon";
		Health 5000;
		Radius 31;
		Height 54;
		Mass 800;
		Speed 16;
		Scale 1.25;
		PainChance 32;
		MeleeDamage 10;
		DamageFactor "None", 1.5;
		RadiusDamageFactor 0.33;
		DamageFactor "Plasma", 0.9;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "monster/helsit";
		PainSound "monster/helpai";
		DeathSound "monster/heldth";
		ActiveSound "monster/helact";
		Monster;
		+FLOAT
		+NOGRAVITY
		+BOSS
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		-NORADIUSDMG
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 64;
		DropItem "RS_CH_Cell", 64;
		DropItem "RS_CH_BlueArmor", 128;
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLTorgueBlastplateArmorPickup",32 -- DRLA stripped per owner 2026-08-05
		Translation "128:143=176:191","144:151=187:191","13:15=44:47";
		Tag "SHOCKMASTER";
	}
	States
	{
	Spawn:
		HELE A 0;
		Goto Scripted;
	Scripted:
		HELE A 0;   // CH: ACS_NamedExecuteAlways("AnnounceCaco") -- announcers dropped per owner
		Goto Idle;
	Idle:
		HELE A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HELE A 0 A_SetShootable;
		HELE AAAAAA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE AAAAAA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE A 0 A_Jump(128,"Phase");
		Goto See+1;
	Phase:
		HELE A 1 A_PlaySound("monster/heltel");
		HELE A 1 A_SetTranslucent(0.90);
		HELE A 1 A_SetTranslucent(0.80);
		HELE A 1 A_SetTranslucent(0.70);
		HELE A 1 A_SetTranslucent(0.60);
		HELE A 1 A_SetTranslucent(0.50);
		HELE A 1 A_SetTranslucent(0.40);
		HELE A 1 A_SetTranslucent(0.30);
		HELE A 1 A_SetTranslucent(0.20);
		HELE A 1 A_SetTranslucent(0.10);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Wander;
		HELE A 1 A_PlaySound("monster/heltel");
		HELE A 1 A_SetTranslucent(0.10);
		HELE A 1 A_SetTranslucent(0.20);
		HELE A 1 A_SetTranslucent(0.30);
		HELE A 1 A_SetTranslucent(0.40);
		HELE A 1 A_SetTranslucent(0.50);
		HELE A 1 A_SetTranslucent(0.60);
		HELE A 1 A_SetTranslucent(0.70);
		HELE A 1 A_SetTranslucent(0.80);
		HELE A 1 A_SetTranslucent(0.90);
		HELE A 1 A_SetTranslucent(1.0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE A 0 A_JumpIfHealthLower(3000,"Phase2Jumps");
		HELE A 0 A_Jump(256,"Electro1","Electro5","Electro3");
		Goto See;
	Nah:
		HELE A 0 A_Jump(256,"Electro2","Electro3","Electro4","Electro5");
		Goto See;
	Phase2Jumps:
		HELE A 0 A_JumpIf(user_DO2 >= 1,"Nah");
		HELE A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		HELE BC 8;
		HELE D 8 A_PlaySound("monster/helsit");
		HELE D 12 A_SpawnItemEx("RS_RedCaco",random(-128,128),random(-128,128),0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		HELE D 12 A_SpawnItemEx("RS_RedCaco",random(-128,128),random(-128,128),0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		HELE C 8 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MISSILEEVENMORE",True)
		HELE C 4 { user_DO2 = user_DO2 + 1; }   // CH: A_SetUserVar("User_DO2",User_DO2+1)
		HELE B 4 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		HELE A 8 A_SetSpeed(20);
		Goto See;
	Electro4:
		HELE EF 8 Bright A_FaceTarget;
		HELE G 5 Bright A_CustomMissile("RS_HadesBall2",24,0,0,0,0);
		HELE FE 8 Bright;
		Goto Electro1;
	Electro5:
		HELE BC 5 Bright A_FaceTarget;
		HELE G 5 Bright A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		HELE D 5 Bright A_FaceTarget;
		HELE G 5 Bright A_CustomMissile("RS_HadesBall3",18,0,0,0,0);
		HELE CB 5;
		Goto See+1;
	Electro1:
		HELE EF 5 Bright A_FaceTarget;
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-14,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-7,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,0,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,7,0,0);
		HELE G 5 Bright A_CustomMissile("RS_HadesBall",24,0,14,0,0);
		Goto See+1;
	Electro2:
		HELE E 0 A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		HELE EF 12 Bright A_FaceTarget;
		HELE G 0 A_CustomMissile("RS_HadesBolt",32,0,-16,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBolt",32,0,0,0,0);
		HELE G 5 Bright A_CustomMissile("RS_HadesBolt",32,0,16,0,0);
		Goto See+1;
	Electro3:
		HELE BC 8 Bright A_FaceTarget;
		HELE G 8 Bright A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		HELE D 8 Bright A_FaceTarget;
		HELE G 8 Bright A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		HELE D 8 Bright A_FaceTarget;
		HELE G 0 A_CustomMissile("RS_EyeBeamCaco",32,0,0,0,0);
		HELE G 8 Bright A_CustomBulletAttack(0,0,1,random(1,5),"RS_HadeAra");
		HELE CB 5;
		Goto See+1;
	Melee:
		HELE ABD 5 Bright A_FaceTarget;
		HELE C 5 Bright A_Jump(256,"Electro2");
		Goto See+1;
	Pain:
		HELE H 3 A_SetTranslucent(1.0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE H 3 A_Pain;
		HELE H 6 A_Jump(88,"Phase");
		Goto See;
	Death:
		HELE I 8 Bright A_Scream;
		HELE JKL 8 Bright A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 8 Bright A_NoBlocking;
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE NOP 8 Bright A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE QRSTU 8 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE V -1 A_SetFloorClip;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 EX -- BLACK EX ("SHOCKMASTER RETURNS").  CH: Cacodemons.txt:2348.
// Announcers dropped per owner.
// ---------------------------------------------------------------------------
class RS_BlackCacoEX : Actor
{
	int user_DO2;   // CH: Var int User_DO2
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o got boilingly bloodcrocuted by Black Cacodemon EX";
		HitObituary "%o got chomped by a Black Cacodemon";
		Health 10000;
		Radius 31;
		Height 54;
		Mass 800;
		Speed 21;
		Scale 1.25;
		PainChance 32;
		RadiusDamageFactor 0.5;
		DamageFactor "Plasma", 0.9;
		DamageFactor "Heroic", 3.0;
		DamageFactor "PlayerVoid", 0.6;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "monster/helsit";
		PainSound "monster/helpai";
		DeathSound "monster/heldth";
		ActiveSound "monster/helact";
		Monster;
		+FLOAT
		+NOGRAVITY
		+BOSS
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		-NORADIUSDMG
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 64;
		DropItem "RS_CH_Cell", 64;
		DropItem "RS_CH_BlueArmor", 128;
		// CH: Dropitem "RareArmorPool" -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",32 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLTorgueBlastplateArmorPickup",46 -- DRLA stripped per owner 2026-08-05
		Translation "128:143=176:191","144:151=187:191","13:15=44:47";
		Tag "SHOCKMASTER RETURNS";
	}
	States
	{
	Spawn:
		HELE A 0;
		Goto Scripted;
	Scripted:
		HELE A 0;   // CH: ACS_NamedExecuteAlways("AnnounceCaco") -- announcers dropped per owner
		HELE A 0 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		HELE A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HELE A 0 A_SetShootable;
		HELE AAAAAA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE AAAAAA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE AAAAAA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE A 0 A_Jump(128,"Phase");
		Goto See+1;
	Phase:
		HELE A 1 A_PlaySound("monster/heltel");
		HELE A 1 A_SetTranslucent(0.90);
		HELE A 1 A_SetTranslucent(0.80);
		HELE A 1 A_SetTranslucent(0.70);
		HELE A 1 A_SetTranslucent(0.60);
		HELE A 1 A_SetTranslucent(0.50);
		HELE A 1 A_SetTranslucent(0.40);
		HELE A 1 A_SetTranslucent(0.30);
		HELE A 1 A_SetTranslucent(0.20);
		HELE A 1 A_SetTranslucent(0.10);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Wander;
		HELE A 1 A_PlaySound("monster/heltel");
		HELE A 1 A_SetTranslucent(0.10);
		HELE A 1 A_SetTranslucent(0.20);
		HELE A 1 A_SetTranslucent(0.30);
		HELE A 1 A_SetTranslucent(0.40);
		HELE A 1 A_SetTranslucent(0.50);
		HELE A 1 A_SetTranslucent(0.60);
		HELE A 1 A_SetTranslucent(0.70);
		HELE A 1 A_SetTranslucent(0.80);
		HELE A 1 A_SetTranslucent(0.90);
		HELE A 1 A_SetTranslucent(1.0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		TNT1 AAA 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE A 0 A_JumpIfHealthLower(6500,"Phase2Jumps");
		HELE A 0 A_Jump(256,"Electro1","Electro5","Electro3");
		Goto See;
	Nah:
		HELE A 0 A_Jump(256,"Electro2","Electro3","Electro4","Electro5");
		Goto See;
	Phase2Jumps:
		HELE A 0 A_JumpIf(user_DO2 >= 1,"Nah");
		HELE A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		HELE BC 8;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE D 8 A_PlaySound("monster/helsit");
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE DDD 12 A_SpawnItemEx("RS_RedSpikeCacoEX",12,128,32,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		HELE DDDD 12 A_SpawnItemEx("RS_RedSpikeCacoEX",12,128,32,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE C 8 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MISSILEEVENMORE",True)
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE C 4 { user_DO2 = user_DO2 + 1; }   // CH: A_SetUserVar("User_DO2",User_DO2+1)
		HELE B 4;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE A 8 A_SetSpeed(42);
		Goto See;
	Electro4:
		HELE EF 8 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX4",24,0,0,0,0);
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX4",24,0,-25,0,0);
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX4",24,25,0,0,0);
		HELE FE 8 Bright;
		Goto Electro1;
	Electro5:
		HELE BC 5 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 5 Bright A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		HELE D 5 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX3",18,0,0,0,0);
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX3",18,0,25,0,0);
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX3",18,0,-25,0,0);
		HELE CB 5;
		TNT1 A 0 A_JumpIfHealthLower(5000,"BonusDucks");
		Goto See+1;
	Electro1:
		HELE EF 5 Bright A_FaceTarget;
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-14,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-7,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,0,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,7,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-14,CMF_OFFSETPITCH|CMF_AIMDIRECTION,-4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-7,CMF_OFFSETPITCH|CMF_AIMDIRECTION,-4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,0,CMF_OFFSETPITCH|CMF_AIMDIRECTION,-4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,7,CMF_OFFSETPITCH|CMF_AIMDIRECTION,-4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,14,CMF_OFFSETPITCH|CMF_AIMDIRECTION,-4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-14,CMF_OFFSETPITCH|CMF_AIMDIRECTION,4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,-7,CMF_OFFSETPITCH|CMF_AIMDIRECTION,4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,0,CMF_OFFSETPITCH|CMF_AIMDIRECTION,4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,7,CMF_OFFSETPITCH|CMF_AIMDIRECTION,4);
		HELE G 0 A_CustomMissile("RS_HadesBall",24,0,14,CMF_OFFSETPITCH|CMF_AIMDIRECTION,4);
		HELE G 5 Bright A_CustomMissile("RS_HadesBall",24,0,14,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(5000,"BonusDucks");
		Goto See+1;
	BonusDucks:
		HELE EF 3 Bright A_FaceTarget;
		HELE G 3 Bright A_CustomMissile("RS_HadesBallEX2",18,0,0,0,0);
		Goto See+1;
	Electro2:
		HELE E 0 A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		HELE EF 12 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE DDD 12 A_SpawnItemEx("RS_RedSpikeCacoEX",12,128,32,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE DDD 12 A_SpawnItemEx("RS_RedSpikeCacoEX",12,128,32,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 0 A_CustomMissile("RS_HadesBolt",32,0,-16,0,0);
		HELE G 0 A_CustomMissile("RS_HadesBolt",32,0,0,0,0);
		HELE G 5 Bright A_CustomMissile("RS_HadesBolt",32,0,16,0,0);
		TNT1 A 0 A_JumpIfHealthLower(5000,"BonusDucks");
		Goto See+1;
	Electro3:
		HELE BC 8 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 8 Bright A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE D 8 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 8 Bright A_CustomMissile("RS_HadeLoad1",32,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE D 8 Bright A_FaceTarget;
		HELE G 0 A_CustomMissile("RS_EyeBeamCaco",32,0,0,0,0);
		TNT1 A 0 A_CustomRailgun(random(20,80),-20,"white","white",RGF_NOPIERCING|RGF_SILENT,0,0,"RS_BlackCacoBeam1",0,0,0,0,0.4,1.0,"RS_BlackCacoBeam2",1);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE G 8 Bright A_CustomBulletAttack(0,0,1,random(1,5),"RS_HadeAra");
		HELE CB 5;
		TNT1 A 0 A_JumpIfHealthLower(5000,"BonusDucks");
		Goto See+1;
	Pain:
		HELE H 3 A_SetTranslucent(1.0);
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HELE H 3 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_BlackCacoEXShade",0,0,random(22,44),random(-1,1),0,random(-1,1),random(160,200),SXF_NOCHECKPOSITION);
		HELE H 6 A_Jump(88,"Phase");
		Goto See;
	Death:
		HELE I 8 Bright A_Scream;
		HELE JKL 8 Bright A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 8 Bright A_NoBlocking;
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE M 0 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE NOP 8 Bright A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE QRSTU 8 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		HELE V -1 A_SetFloorClip;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE, PHASE 1 ("PLEASE NO").  CH: Cacodemons.txt:3210.
// Announcers dropped per owner.  Its Death hatches WhiteCacoREAL.
// lostsouls.txt has no claim here.
// ---------------------------------------------------------------------------
class RS_WhiteCaco2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 5000;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 28;
		FloatSpeed 30;
		Species "Caco";
		PainChance 128;
		Monster;   // CH lists "Monster" twice (Cacodemons.txt:3220,3226)
		RadiusDamageFactor 0.33;
		DamageFactor "Plasma", 0.9;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+DONTMORPH
		+BOSS
		+MISSILEMORE
		+DONTHARMCLASS
		-NORADIUSDMG
		+NOFEAR
		+NOICEDEATH
		SeeSound "cacobaldsee";
		PainSound "cacobaldpain";
		DeathSound "cacobalddeath";
		ActiveSound "cacobaldidle";
		Obituary "%o was loved to death by white cacodemon";
		HitObituary "%o was hugged to death by white cacodemon";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack";
		Tag "PLEASE NO";
	}
	States
	{
	Spawn:
		HELE A 0;
		Goto Scripted;
	Scripted:
		HELE A 0;   // CH: ACS_NamedExecuteAlways("AnnounceCaco2") -- announcers dropped per owner
		Goto Idle;
	Idle:
		CACP A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CACP A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(255,"Basic","Wonky","arms");
	Basic:
		CACP BC 4 A_FaceTarget;
		CACP D 4 Bright A_CustomComboAttack("RS_CacobaldBall",32,2,"imp/melee");
		CACP BC 3 A_FaceTarget;
		CACP C 0 A_JumpIfHealthLower(2500,"BasicBITCH");
		CACP D 0 A_CustomMissile("RS_CacobaldBall",32,0,random(-12,-2));
		CACP D 0 A_CustomMissile("RS_CacobaldBall",32,0,random(2,12));
		CACP D 2 Bright A_CustomComboAttack("RS_CacobaldBall",32,2,"imp/melee");
		Goto See;
	BasicBitch:
		CACP DDD 0 A_CustomMissile("RS_CacobaldBall",32,-6,random(-15,-2));
		CACP DDD 0 A_CustomMissile("RS_CacobaldBall",32,8,random(2,15));
		CACP D 2 Bright A_CustomComboAttack("RS_CacobaldBall",32,2,"imp/melee");
		TNT1 A 0 A_Jump(64,"what");
		Goto See;
	Wonky:
		CACP BC 4 A_FaceTarget;
		CACP DDD 1 Bright A_CustomMissile("RS_CacobaldBall2",32,0,random(-3,3));
		CACP DD 2 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-9,9));
		CACP DDD 1 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-15,-5));
		CACP DD 2 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(5,15));
		CACP C 4 A_FaceTarget;
		CACP C 0 A_JumpIfHealthLower(2500,"Wonkier");
		CACP DDDD 1 Bright A_CustomMissile("RS_CacobaldBall2",32,0,random(-3,3));
		CACP DD 2 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-9,9));
		CACP DDDD 0 A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-15,-5));
		CACP DDD 0 A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(5,15));
		CACP D 2 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(5,15));
		Goto See;
	Wonkier:
		CACP DDDD 0 A_CustomMissile("RS_CacobaldBall2",32,0,random(-3,3));
		CACP DD 1 Bright A_CustomMissile("RS_CacobaldBall2",32,0,random(-3,3));
		CACP DDDD 0 A_CustomMissile("RS_CacobaldBall2",32,0,random(-3,3));
		CACP DD 1 Bright A_CustomMissile("RS_CacobaldBall2",32,0,random(-3,3));
		CACP DDDD 0 A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-9,9));
		CACP D 2 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-9,9));
		CACP DDDDDDD 0 A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(-25,-3));
		CACP DDDDDD 0 A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(3,25));
		CACP D 2 Bright A_CustomMissile("RS_CacobaldBall2",random(12,48),random(-16,16),random(3,25));
		TNT1 A 0 A_Jump(64,"what");
		Goto See;
	arms:
		CACP BC 6 A_FaceTarget;
		CACP GH 7;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACP H 7 A_PlaySound("caco/sight",7,2,false,ATTN_NONE);
		TNT1 A 0 A_VileTarget("RS_ArmSpawnerCACO");
		CACP G 7 A_JumpIfHealthLower(2500,"MoreArms");
		Goto See;
	MoreArms:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACP H 9 A_PlaySound("caco/sight",7,2,false,ATTN_NONE);
		CACP G 9 A_VileTarget("RS_ArmSpawnerCACO");
		TNT1 AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACP H 8 A_PlaySound("caco/sight",7,2,false,ATTN_NONE);
		CACP G 8 A_VileTarget("RS_ArmSpawnerCACO");
		TNT1 AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACP H 7 A_PlaySound("caco/sight",7,2,false,ATTN_NONE);
		CACP G 7 A_VileTarget("RS_ArmSpawnerCACO");
		TNT1 A 0 A_Jump(64,"what");
		Goto See;
	Pain:
		CACP E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CACP E 3 A_Pain;
		CACP E 3 A_Jump(64,"what");
		Goto See;
	what:
		CACP AAA 3 A_SpawnItemEx("RS_WhiteCacoFake",random(-64,64),random(-64,64),random(-32,32),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 { bNOPAIN = true; }   // CH: a_changeflag(nopain,true)
		TNT1 AAAA 1 A_Wander;
		TNT1 A 10 A_Wander;
		TNT1 AAAA 1 A_Wander;
		CACP A 3 A_SetScale(0.1,0.1);
		CACP A 3 A_SetScale(0.35,0.35);
		CACP A 3 A_SetScale(0.7,0.7);
		CACP A 3 A_SetScale(1,1);
		TNT1 A 0 { bNOPAIN = false; }
		Goto See;
	XDeath:
	Death:
		CACX A 5 A_Scream;
		CACX B 5 A_XScream;
		CACX CD 5;
		CACX E 5 A_NoBlocking;
		CACX F 90 A_SetFloorClip;
		CACX F 10 A_PlaySound("caco/sight");
		CACX FFFF 6 A_PlaySound("caco/sight");
		CACX F 15 Radius_Quake(15,30,0,40,0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX FFFF 2 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX FFFF 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,36,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX FFFF 2 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,48,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX FFFF 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,60,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX FFFF 2 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,72,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX FFFF 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,84,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		CACX F 15 Radius_Quake(15,30,0,40,0);
		CACX FFFFFFFFFFFFFFF 2;   // CH: each F spawned a CHRandom_GibGenerator -- gore chain not imported (owner: vanilla gore ok)
		// CH: TNT1 AAAAAAFFFFFAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CACX F 1 Radius_Quake(15,30,0,40,0);
		TNT1 A 6 A_SpawnItemEx("RS_WhiteCacoREAL",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		// CH: TNT1 AAAAAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) x2 -- gore chain not imported
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE, PHASE 2 ("Thy flesh consumer").  CH: Cacodemons.txt:3375.
// Invulnerable until all four orbs die (RS_CacoSafety x4 -> Vuln).
// ---------------------------------------------------------------------------
class RS_WhiteCacoREAL : Actor
{
	int user_mad;   // CH: var int user_mad
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 5000;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 16;
		Species "Caco";
		PainChance 128;
		Monster;   // CH lists "Monster" twice (Cacodemons.txt:3384,3392)
		RadiusDamageFactor 0.25;
		DamageFactor "Plasma", 0.85;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "plwater", 0.45;   // CH lists it twice (quoted :3390, bare :3391) -- kept once
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+BOSS
		+MISSILEMORE
		+DONTHARMCLASS
		-NORADIUSDMG
		+NOFEAR
		+DONTMORPH
		+NOICEDEATH
		+NOPAIN
		+INVULNERABLE
		+DONTBLAST
		+DONTTHRUST
		SeeSound "cacobaldsee";
		PainSound "cacobaldpain";
		DeathSound "cacobalddeath";
		ActiveSound "cacobaldidle";
		Obituary "%o couldn't handle the truth of white caco";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		// CH: Dropitem "RareArmorPool" -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",32 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLLegendaryWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",64 -- DRLA stripped per owner 2026-08-05
		Tag "Thy flesh consumer";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Up:
		CDW2 A 4 ThrustThingz(0,8,0,0);
		CDW2 B 4;
		CDW2 C 4 Bright A_Stop;
		Goto Eyes;
	Eyes:
		CDW2 FFED 12 A_SpawnItemEx("RS_WhiteCacoOrb1",64,64,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	Idle:
		CDW2 ABC 2 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_JumpIf(user_mad >= 1,"See2");
		CDW2 ABC 8 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfInventory("RS_CacoSafety",4,"Vuln");
		CDW2 FED 8 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See2:
		CDW2 ABCFED 5 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Vuln:
		CDW2 K 3;
		CDW2 L 3 A_Pain;
		TNT1 A 0 { bNOPAIN = false; }         // CH: A_changeflag("Nopain",false)
		TNT1 A 0 { bINVULNERABLE = false; }   // CH: A_changeflag("Invulnerable",false)
		TNT1 A 0 { bMISSILEEVENMORE = true; } // CH: A_changeflag("MissileEvenMore",true)
		TNT1 A 0 { user_mad = user_mad + 1; } // CH: A_setuservar("User_mad",user_mad+1)
		CDW2 M 3 A_SetSpeed(24);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIf(user_mad >= 1,"Missile2");
		TNT1 A 0 A_Jump(255,"Handy","Bloody");
		Goto See;
	Missile2:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(255,"Handy2","Bloody2","Portal","spikes");
		Goto See;
	Handy:
		CDW2 GHI 5 Bright;
		TNT1 A 0 A_VileTarget("RS_ArmSpawnerCACO2");
		CDW2 J 5 Bright;
		Goto See;
	Bloody:
		CDW2 G 5 Bright;
		CDW2 HHI 5 Bright A_SpawnItemEx("RS_BloodRainerCaco",random(-12,12),random(-12,12),24,0,0,0,0,SXF_NOCHECKPOSITION);
		CDW2 IJ 5 Bright;
		Goto See;
	spikes:
		CDW2 A 3 Bright A_FaceTarget;
		CDW2 GHIJ 3 Bright A_CustomMissile("RS_MolochNail",32,random(-10,10),random(-9,9),0);
		CDW2 GHIJ 3 Bright A_CheckSight("See");
		CDW2 GHIJ 3 Bright A_CustomMissile("RS_MinesRev",24,0,random(-25,25),0);
		CDW2 GHIJ 3 Bright A_CheckSight("See");
		CDW2 GHIJ 3 Bright A_CustomMissile("RS_MolochNail",32,random(-10,10),random(-9,9),0);
		CDW2 GHIJ 3;
		TNT1 A 0 A_MonsterRefire(150,"See");
		Goto See;
	Bloody2:
		CDW2 G 5 Bright;
		CDW2 HHH 3 Bright A_SpawnItemEx("RS_BloodRainerCaco",random(-12,12),random(-12,12),24,0,0,0,0,SXF_NOCHECKPOSITION);
		CDW2 III 3 Bright A_CustomMissile("RS_EyeRocketCaco",12,0,random(-20,20));
		CDW2 J 5 Bright;
		Goto See;
	Handy2:
		CDW2 GHI 5 Bright;
		TNT1 A 0 A_VileTarget("RS_ArmSpawnerCACO2");
		TNT1 AAAA 0 A_SpawnItemEx("RS_CacoARMSU2",random(-528,528),random(-528,528),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		CDW2 J 5 Bright;
		Goto See;
	Portal:
		CDW2 GHI 5 Bright;
		CDW2 J 5 Bright A_SpawnItemEx("RS_SummonPortalCybie",random(-128,128),random(-128,128),12);
		Goto See;
	Pain:
		CDW2 K 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CDW2 L 3 A_Pain;
		CDW2 M 3;
		Goto See;
	Death:
		CDW2 A 3 Bright;
		CDW2 A 3 Bright A_Scream;
		CDW2 A 3 Bright A_NoBlocking;
		CDW2 K 4 Bright A_CustomMissile("RS_HKRedDeath",100,-30,CMF_AIMOFFSET,2,-10);
		CDW2 K 4 Bright A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		CDW2 L 4 Bright A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		CDW2 L 4 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		CDW2 MMMMM 4 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		CDW2 MMMMM 3 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		CDW2 MMMMM 2 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		CDW2 MMMMM 1 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		CDW2 MMM 1 Bright A_FadeOut(0.33);
		Stop;
	}
}
