// ============================================================================
// RS_Archvile.zs -- Colourful Hell Archvile family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Archviles.txt (5,287 lines,
// read whole). Every actor cites its CH line. Support, projectiles and
// minions live in RS_ArchvileFX.zs -- see its header for the cross-lane
// notes, the already-owned skip list, the proven-missing assets and the
// standing strips.
//
// Tier ladder is CH's own icon index, exactly as CH spawns it:
//   1  Common      ColorTierIconCH     RS_CommonArch
//   2  Green       ColorTierIconCH2    RS_GreenArch
//   3  Blue        ColorTierIconCH3    RS_BlueArch
//   4  Purple      ColorTierIconCH4    RS_PurpleArch
//   5  Yellow      ColorTierIconCH5    RS_YellowArch
//   6  Red         ColorTierIconCH6    RS_RedArch2, RS_RedArch3 (both phases)
//   7  FireBlu     ColorTierIconCH7    RS_FireBluArch2
//   8  Gray        ColorTierIconCH8    RS_GrayArch2
//   9  Abyss       ColorTierIconCH9    RS_AbyssVile
//   10 Black       ColorTierIconCH10   RS_BlackVile
//   11 White       ColorTierIconCH11   RS_Whitevile
//   12 Cyan        ColorTierIconCH12   RS_CyanVile
//   13 Brown       ColorTierIconCH13   RS_BrownVile
// Minions and summons carry NO token: RS_SpecialRev, RS_SpecialVile,
// RS_ABVileTentacle, RS_AbyssPortalVile, RS_VileGrayDecoy, RS_WVileEye2/3,
// RS_WvileSpot, RS_BrownBoiVile.
//
// CVARS: no new ones. Every gate this family reads was already declared by
// an earlier family --
//   CH_Brown      -> rs_ch_brown        (default 1)
//   CH_Cyan       -> rs_ch_cyan         (default 1)
//   CH_CyanBounce -> rs_ch_cyanbounce   (default 0)
//   CH_Abyssmal   -> rs_ch_abyss        (default 1)
//   CH_Grayscale  -> rs_ch_gray         (default 1)
//   CH_FireBLUES  -> rs_ch_fireblu      (default 1)
//   CH_Red        -> rs_ch_nerfredboss  (default 1)
//   CH_BlackBossy -> rs_ch_blackboss    (default 1)
//   CH_WhiteBossy -> rs_ch_whiteboss    (default 1)
// CH's semantics kept exactly: 1 = colour off (reroll into the main set),
// 3 = fifty-fifty, and for CH_Red 1 = boss form, 2 = coin flip, else the
// plain form.
//
// PROVEN MISSING IN CH ITSELF, in this file: the sound "Ice/hit" on
// RS_CyanVile's A_VileAttack (CH Archviles.txt:1029). CH's own SNDINFO.txt
// defines only `Ice/Hit2 ICEI` -- there is no `ice/hit` entry anywhere in
// CH, so the hit is silent in CH too. Kept verbatim, nothing substituted.
// See RS_ArchvileFX.zs's header for the family's other two.
//
// FRAME NOTE, applied at every site: CH writes the archvile heal animation
// as the quoted frame string VILE "[\]" -- three frames, [ then \ then ].
// A quoted frame string containing an escaped character is a hard PARSE
// ERROR on this engine (the spectre lane hit the same thing on SLGM). The
// two frames that need no escape are kept as real frames; only the
// backslash frame becomes a TNT1 of the same duration, so the timing and
// the other two frames survive intact. Marked "// CH: VILE \" at each site.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Archviles.txt:1 -- Colourset11 replaces Archvile.
// ---------------------------------------------------------------------------
class RS_Colourset11 : RandomSpawner replaces Archvile
{
	Default
	{
		DropItem "RS_CommonArch", 255, 420;
		DropItem "RS_GreenArch", 255, 270;
		DropItem "RS_CyanArch", 255, 100;
		DropItem "RS_BrownArch", 255, 70;
		DropItem "RS_BlueArch", 255, 160;
		DropItem "RS_PurpleArch", 255, 80;
		DropItem "RS_YellowArch", 255, 40;
		DropItem "RS_GrayArch", 255, 30;
		DropItem "RS_AbyssArch", 255, 25;
		DropItem "RS_FireBluArch", 255, 30;
		DropItem "RS_RedArch", 255, 10;
		DropItem "RS_BlackArch", 255, 5;
		DropItem "RS_WhiteArch", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.
// ---------------------------------------------------------------------------

class RS_BrownArch : Actor   // CH Archviles.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset11",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanArch : Actor   // CH Archviles.txt:899 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset11",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssArch : Actor   // CH Archviles.txt:1263 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset11",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayArch : Actor   // CH Archviles.txt:1772 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset11",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayArch2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluArch : Actor   // CH Archviles.txt:2096 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset11",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluArch2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_RedArch : Actor   // CH Archviles.txt:3467 -- gate CH_Red
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
		TNT1 A 0 A_SpawnItemEx("RS_RedArch3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Second:
		TNT1 A 0 A_Jump(256,"First","Third");
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedArch2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackArch : Actor   // CH Archviles.txt:4328 -- gate CH_BlackBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedArch",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteArch : Actor   // CH Archviles.txt:4499 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_Whitevile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackArch",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown ("That's a messy vile").  CH: Archviles.txt:40.
// ---------------------------------------------------------------------------
class RS_BrownVile : Actor   // CH Archviles.txt:40
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }

	Default
	{
		Health 1400;
		Species "vile1";
		BloodColor "red";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 21;
		FloatSpeed 20;
		PainChance 12;
		Monster;
		+NOGRAVITY
		+FLOAT
		+NOPAIN
		+FLOATBOB
		+DONTTHRUST
		+NOICEDEATH
		+NODAMAGETHRUST
		Obituary "%o Got rock and rolled by brown archvile";
		SeeSound "monster/wiksit";
		PainSound "MUFFLE01";
		DeathSound "MUFFLE02";
		ActiveSound "monster/wikact";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "RS_CH_Bluearmor", 64;
		DropItem "RS_ArmorBundle";
		Tag "That's a messy vile";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 AAAA 12 A_SpawnItemEx("RS_BrownVileRock",0,0,0,0,0,0,0,SXF_SETMASTER);
		TNT1 AAAA 9 A_SpawnItemEx("RS_BrownVileRock2",0,0,0,0,0,0,0,SXF_SETMASTER);
		TNT1 A 0 { bNoPain = false; }
		Goto Idle;
	Idle:
		WICK ABCD 8 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetSpeed(19);
		WICK AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK CCDD 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_BrownVileRock3",0,0,0,0,0,0,0,SXF_SETMASTER,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK A 0 A_Jump(32,"See2");
		Goto See;
	See2:
		TNT1 A 0 A_SetSpeed(25);
		WICK EEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK GGHH 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_BrownVileRock3",0,0,0,0,0,0,0,SXF_SETMASTER,128);
		WICK E 0 A_Jump(32,"See");
		Goto See2;
	Missile:
		WICK I 1;
		WICK I 1 A_Jump(64,"CheckThem");
		WICK I 1 A_Jump(128,"HereComesThatBoi");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK I 1 A_PlaySound("CASTBROW",7);
		WICK I 4 A_FaceTarget;
		WICK J 5 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK K 6 Bright A_VileTarget("RS_VileGroundSpikeBrown");
		WICK L 4;
		Goto See;
	HereComesThatBoi:
		WICK I 1 A_PlaySound("ATKBROWV",0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK I 3 A_FaceTarget;
		WICK J 4 Bright A_FaceTarget;
		WICK K 9 Bright A_SpawnItemEx("RS_BrownBoiVile",32,76,32,0,0,0,0,SXF_SETTRACER,SXF_NOCHECKPOSITION);
		WICK K 9 Bright A_SpawnItemEx("RS_BrownBoiVile",32,32,46,0,0,0,0,SXF_SETTRACER,SXF_NOCHECKPOSITION);
		WICK K 9 Bright A_SpawnItemEx("RS_BrownBoiVile",32,0,64,0,0,0,0,SXF_SETTRACER,SXF_NOCHECKPOSITION);
		WICK K 9 Bright A_SpawnItemEx("RS_BrownBoiVile",32,-32,46,0,0,0,0,SXF_SETTRACER,SXF_NOCHECKPOSITION);
		WICK K 9 Bright A_SpawnItemEx("RS_BrownBoiVile",32,-76,32,0,0,0,0,SXF_SETTRACER,SXF_NOCHECKPOSITION);
		WICK L 4;
		Goto See;
	CheckThem:
		TNT1 A 0 A_CheckProximity("HealNo","Arachnotron",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","HellKnight",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","CacoDemon",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","Demon",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","Spectre",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","ChainGunGuy",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","DoomImp",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","Fatso",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","Revenant",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","ShotgunGuy",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		TNT1 A 0 A_CheckProximity("HealNo","ZombieMan",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_DEADONLY);
		WICK I 0 A_Jump(128,"CheckThem2");
		TNT1 A 0 A_CheckProximity("FeelIt","Arachnotron",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","HellKnight",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","CacoDemon",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","Demon",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","Spectre",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","ChainGunGuy",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","DoomImp",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","Fatso",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","Revenant",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","ShotgunGuy",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","ZombieMan",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","PainElemental",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
	CheckThem2:
		TNT1 A 0;
		Goto Missile+3;
	FeelIt:
		WICK I 8 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK I 8 Bright;
		WICK J 3 A_RadiusGive("RS_ShieldUpVile",420,RGF_MONSTERS,1);
		WICK JJJJ 1 A_SpawnItemEx("RS_MediCacoBrown",random(-64,64),random(-64,64),random(-16,64),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK K 3 A_RadiusGive("Health",1200,RGF_MONSTERS,500);
		WICK KKKKK 1 A_SpawnItemEx("RS_MediCacoBrown",random(-64,64),random(-64,64),random(-16,64),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK K 2;
		WICK L 5;
		Goto See;
	HealNo:
		DIA2 A 0 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,3);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK I 4 Bright;
		WICK I 1 A_SpawnItemEx("RS_Drt2",0,164,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt3",-164,0,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt1",0,-164,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt2",-164,164,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt3",-164,-164,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt1",164,0,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt2",0,164,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt3",164,0,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt1",164,0,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt2",164,164,-16,random(1,5),0,random(1,5),random(0,360));
		WICK I 1 A_SpawnItemEx("RS_Drt3",164,0,-16,random(1,5),0,random(1,5),random(0,360));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK IIII 1 Bright A_SpawnItemEx("RS_ArchRingHelp",random(-64,64),random(-64,64),3,0,0,0,0);
		WICK IIII 1 Bright A_SpawnItemEx("RS_ArchRingHelp",random(-128,128),random(-128,128),3,0,0,0,0);
		WICK IIIIII 1 Bright A_SpawnItemEx("RS_ArchRingHelp",random(-252,252),random(-252,252),3,0,0,0,0);
		WICK IIIIIIIII 1 Bright A_SpawnItemEx("RS_ArchRingHelp",random(-352,352),random(-352,352),3,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK J 5 Bright;
		WICK K 8 Bright;
		WICK L 5 Bright;
		WICK I 1 A_SpawnItemEx("RS_Drt1",164,0,-16,random(1,5),0,random(1,5),random(0,360));
		Goto FeelIt;
	Pain:
		WICK M 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WICK M 3 A_Pain;
		WICK M 3;
		Goto See;
	Death:
		WICK N 5 A_Scream;
		WICK O 5 { bFloatBob = false; }
		WICK P 5 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		WICK P 0 A_SpawnItemEx("RS_WickedTorso",0,0,48,0,0,0,0,16);
		WICT A 5 A_NoBlocking;
		WICT BCDEF 5;
		WICT G -1 A_SetFloorClip;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan ("Barnie").  CH: Archviles.txt:921.
// ---------------------------------------------------------------------------
class RS_CyanVile : Actor   // CH Archviles.txt:921
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }

	Default
	{
		Obituary "%o got cooled off by cyan vile";
		Health 1200;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 21;
		PainChance 10;
		PainThreshold 34;
		BloodColor "cyan";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Ice", 0.10;
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 32;
		PainChance "Melee", 102;
		DamageFactor "Falling", 0.0;
		DamageFactor "Melee", 2.5;
		DamageFactor "fire", 1.0;
		Monster;
		+FLOORCLIP
		+NOTARGET
		-NORADIUSDMG
		+MISSILEMORE
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOFEAR
		+QUICKTORETALIATE
		+LAXTELEFRAGDMG
		+NOICEDEATH
		SeeSound "Monster/diasit";
		PainSound "Monster/diapai";
		DeathSound "Monster/diadth";
		ActiveSound "Monster/diaact";
		DropItem "RS_CH_SoulSphere", 42;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_Bluearmor", 64;
		Tag "Barnie";
		Translation "168:191=%[0.03,0.23,0.43]:[0.89,2.00,2.00]","32:47=%[0.00,0.00,1.69]:[1.29,2.00,2.00]","0:2=245:247","64:79=192:207","144:151=192:207","128:143=192:207","5:8=202:207","13:15=201:205","236:239=203:207","160:167=%[0.00,1.01,1.51]:[1.01,2.00,2.00]","224:231=%[0.00,1.01,2.00]:[1.61,2.00,2.00]","232:235=%[0.00,1.01,2.00]:[0.00,2.00,2.00]","208:223=%[0.00,1.01,2.00]:[1.47,2.00,2.00]","48:63=%[0.00,1.01,2.00]:[1.01,2.00,2.00]","248:249=%[0.00,2.00,2.00]:[1.56,2.00,2.00]";
	}
	States
	{
	Spawn:
		DIAB AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		DIAB AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_Jump(128,"Dodger");
		LOHS A 0 A_Jump(32,"DashBack");
		Loop;
	DashBack:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "Dodger");
		DIAB G 3 ThrustThingZ(0,72,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB G 3 ThrustThing(int(angle-180),18,0,0);   // CH: thrustthing(angle-180,18,0,0)
		Goto See;
	Dodger:
		DIAB AABB 2 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_Jump(64,"See");
		DIAB CCDD 2 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LOHS A 0 A_Jump(64,"DashBack");
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB A 0 A_JumpIfCloser(900,"Choice");
		Goto Classical;
	Choice:
		DIAB A 0 A_Jump(256,"Classical","Floor");
		Goto See;
	Floor:
		DIAB HH 3 Bright A_FaceTarget;
		DIAB I 6 Bright A_CustomMissile("RS_IceStartVile4",64,0);
		DIAB PON 7 Bright A_FaceTarget;
		DIAB N 0 A_CustomMissile("RS_IceToMeetVile1",32,0);
		DIAB N 0 A_CustomMissile("RS_IceToMeetVile1",32,0,33);
		DIAB N 0 A_CustomMissile("RS_IceToMeetVile1",32,0,-33);
		DIAB N 0 A_CustomMissile("RS_IceToMeetVile1",32,0,66);
		DIAB N 0 A_CustomMissile("RS_IceToMeetVile1",32,0,-66);
		Goto See;
	Classical:
		DIAB G 0 A_FaceTarget;
		DIAB GH 3 Bright A_FaceTarget;
		DIAB I 3 Bright A_VileTarget("RS_IceStartVile1");
		DIAB HG 3 Bright A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		DIAB HIH 3 Bright A_FaceTarget;
		TNT1 A 0 A_CheckSight("Dodger");
		DIAB G 3 Bright A_FaceTarget;
		DIAB H 3 Bright A_VileTarget("RS_IceStartVile2");
		DIAB IH 3 Bright A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		DIAB GHI 3 Bright A_FaceTarget;
		TNT1 A 0 A_CheckSight("Dodger");
		DIAB G 3 Bright A_VileAttack("Ice/hit",random(10,60),random(10,60),64,-5,"ice");
		DIAB H 0 A_VileTarget("RS_IceStartVile3");
		DIAB HI 3 Bright A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		DIAB Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB Q 5 A_Pain;
		DIAB Q 0 A_Jump(128,"DashBack");
		Goto See;
	Heal:
		DIA2 A 0 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,3);
		DIA2 A 10 Bright;
		DIAB B 2 Bright;
		DIA2 BB 5 Bright A_SpawnItemEx("RS_CyanLSoul2",random(-16,16),random(-16,16),random(12,64),0,0,0,0,SXF_NOCHECKPOSITION);
		DIA2 C 4 Bright;
		DIA2 CC 2;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		DIAB Q 7;
		DIAB R 7 A_Scream;
		DIAB S 7 A_NoBlocking(false);
		DIAB TUVW 7;
		DIAB XY 5;
		DIAB Z 10;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,246);
		DIAB Z 1 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss ("Aliens?").  CH: Archviles.txt:1286.
// ---------------------------------------------------------------------------
class RS_AbyssVile : Actor   // CH Archviles.txt:1286
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }

	Default
	{
		Health 2500;
		Species "vile1";
		BloodColor "black";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 800;
		Speed 25;
		PainChance 32;
		YScale 0.95;
		XScale 0.65;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+DONTHARMSPECIES
		SeeSound "queen/sight";
		ActiveSound "deepone/active";
		PainSound "queen/pain";
		DeathSound "queen/death";
		MeleeSound "vile/stop";
		DropItem "RS_ArmorBundle", 72;
		DropItem "RS_CH_GreenArmor";
		DropItem "BackPack";
		DropItem "RS_CH_SoulSphere", 128;
		DropItem "BackPack", 128;
		DropItem "RS_CH_BlueArmor", 64;
		DropItem "RS_CH_CellPack", 64;
		DropItem "BackPack", 128;
		Obituary "%o was alienized by abyss archvile";
		Translation "0:79=%[0.02,0.02,0.02]:[0.26,0.44,0.39]","96:167=%[0.06,0.09,0.21]:[0.06,0.23,0.09]","80:95=0:0","168:191=0:0","192:255=%[0.00,0.00,0.00]:[0.14,0.22,0.28]";
		Tag "Aliens?";
	}
	States
	{
	Spawn:
		DGRD A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		DGRD BBCC 3 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,62));
		DGRD DDEE 3 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,62),1,0,2,random(-359,359));
		Loop;
	See2:
		DGRD BB 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile",-2,0,random(5,24),0,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DGRD CC 2 A_VileChase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,62),1,0,2,random(-359,359));
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile",-2,0,random(5,24),0,0,0,0,0,128);
		DGRD DD 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile",-2,0,random(5,24));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DGRD EE 2 A_VileChase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,62),1,0,2,random(-359,359));
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssVile",-2,0,random(5,24),0,0,0,0,0,128);
		TNT1 A 0 A_CheckSight("See");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DGRD A 1 A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(1500,"Choice");
	DarkTangle:
		DGRD A 5 Bright A_FaceTarget;
		DGRD A 4 Bright A_PlaySound("queen/sight",7,2,false,ATTN_NONE);
	Tangle:
		DGRD K 1 Bright;
		DGRD K 5 Bright A_FaceTarget;
		DGRD K 1 Bright A_CheckSight("See2");
		DGRD K 5 Bright A_VileTarget("RS_PsychicTangleAbyVile");
		DGRD K 2 A_MonsterRefire(128,"See2");
		Goto Tangle;
	Choice:
		TNT1 A 0 A_Jump(255,"Tendrils","DarkTangle","Icicles");
		Goto See2;
	Tendrils:
		DGRD A 5 Bright A_FaceTarget;
		DGRD A 10;
		DGRD J 5 Bright A_VileTarget("RS_ABVileTend");
		DGRD I 5;
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyssVile2",random(32,728),random(-78,78),0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See2;
	Icicles:
		DGRD I 15 Bright A_FaceTarget;
	IceIt:
		DGRD J 2 Bright A_FaceTarget;
		DGRD JJJ 2 Bright A_CustomMissile("RS_IceABVile",random(24,42),0,random(-9,9));
		DGRD J 1 A_CheckSight("See2");
		DGRD J 1 A_MonsterRefire(128,"See2");
		Goto IceIt;
	Melee:
		DGRD F 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DGRD G 6 A_CustomMeleeAttack(random(16,62),"imp/melee");
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,0,random(-25,25),CMF_OFFSETPITCH,random(-25,-5));
		DGRD H 6 A_CustomMeleeAttack(random(16,62),"imp/melee");
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,0,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		TNT1 A 0 A_Jump(32,"Jumpy");
		Goto See2;
	Heal:
		DGRD A 4 Bright A_SpawnItemEx("RS_AbyssBaronRing",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		DGRD A 10 Bright;
		TNT1 AAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyssVile",random(-258,258),random(-258,258),0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(76,"Portal");
		TNT1 A 0 A_Jump(32,"Jumpy");
		Goto See2;
	Portal:
		DGRD A 4 Bright;
		DGRD A 4 Bright A_SpawnItemEx("RS_AbyssPortalVile",0,0,random(64,252),0,0,0,0,SXF_NOCHECKPOSITION);
		DGRD A 2 Bright;
		Goto Jumpy;
	Jumpy:
		DGRD R 6 A_FaceTarget;
		DGRD S 1 ThrustThingZ(0,64,0,0);
		DGRD S 1 ThrustThing(int(angle-180),12,0,0);   // CH: thrustthing(angle-180,12,0,0)
		DGRD S 5;
		DGRD T 12;
		Goto See2;
	Warp:
		DGRD A 1;
		DGRD A 1 { bNoPain = true; }
		DGRD A 1 { bNoGravity = true; }
		DGRD A 1 { bFloat = true; }
		DGRD A 1 A_SetSpeed(99);
		TNT1 A 0 A_SetTranslucent(0.45);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-128,128),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		DGRD BCDEFBCDEFBCDEFBCDEF 1 A_Wander;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-128,128),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		DGRD A 1 A_SetSpeed(25);
		TNT1 A 0 A_SetTranslucent(1);
		DGRD A 1 { bNoGravity = false; }
		DGRD A 1 { bFloat = false; }
		DGRD A 1 { bNoPain = false; }
		Goto See2;
	Pain:
		DGRD L 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DGRD L 3 A_Pain;
		DGRD L 1 A_Jump(64,"Warp");
		TNT1 A 0 A_Jump(32,"Jumpy");
		Goto See2;
	Death:
		DGRD L 6;
		DGRD M 6 A_Scream;
		DGRD N 6 A_Fall;
		DGRD OP 6;
		DGRD Q -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray ("Like a stone").  CH: Archviles.txt:1791.
// ---------------------------------------------------------------------------
class RS_GrayArch2 : Actor   // CH Archviles.txt:1791
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }

	Default
	{
		Health 1400;
		Species "vile1";
		BloodColor "red";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 19;
		PainChance 16;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+DONTHARMSPECIES
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		MeleeSound "vile/stop";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_GreenArmor";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		Obituary "%o was stone hilled by gray archvile";
		Translation "64:79=96:111","48:63=91:106","128:143=101:111","208:223=91:95","13:15=109:111","144:151=100:105","160:167=240:247","224:231=240:247","248:249=241:242","232:235=243:246";
		Tag "Like a stone";
	}
	States
	{
	Spawn:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		VILE G 2 Bright A_VileStart;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 0 A_Jump(128,"GroundSpike");
		VILE G 12 Bright A_FaceTarget;
		VILE G 1 Bright A_PlaySound("vile/sight",9);
		VILE G 6 Bright A_FaceTarget;
		VILE H 5 Bright A_VileTarget("RS_CHBSTarget");
		VILE IJ 5 Bright A_FaceTarget;
		VILE K 5 Bright A_VileTarget("RS_CHBSTarget");
		VILE L 5 Bright A_FaceTarget;
		VILE M 0 A_CheckSight("See");
		VILE M 9 Bright A_VileTarget("RS_RockVileDrop");
		VILE N 3 Bright;
		VILE O 7 Bright;
		VILE P 16 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	GroundSpike:
		VILE G 12 Bright A_FaceTarget;
		VILE G 1 Bright A_PlaySound("vile/sight",9);
		VILE G 6 Bright A_FaceTarget;
		VILE HIJ 4 Bright;
		VILE "[" 4 A_FaceTarget;
		TNT1 A 4 A_FaceTarget;      // CH: VILE \ -- see header frame note
		VILE "]" 4 A_FaceTarget;
		TNT1 A 1;
		VILE "[" 2 Bright A_CustomMissile("RS_VileGroundSpike",0,0,0,0);
		TNT1 A 2 A_CustomMissile("RS_VileGroundSpike",0,0,0,0);   // CH: VILE \
		VILE "]" 2 Bright A_CustomMissile("RS_VileGroundSpike",0,0,0,0);
		VILE "[" 1 Bright A_CustomMissile("RS_VileGroundSpike",0,0,-45,0);
		TNT1 A 1 A_CustomMissile("RS_VileGroundSpike",0,0,-45,0);   // CH: VILE \
		VILE "]" 1 Bright A_CustomMissile("RS_VileGroundSpike",0,0,-45,0);
		VILE "[" 1 Bright A_CustomMissile("RS_VileGroundSpike",0,0,45,0);
		TNT1 A 1 A_CustomMissile("RS_VileGroundSpike",0,0,45,0);   // CH: VILE \
		VILE "]" 1 Bright A_CustomMissile("RS_VileGroundSpike",0,0,45,0);
		TNT1 A 1;
		VILE "[" 4;
		TNT1 A 4;                   // CH: VILE \
		VILE "]" 4;
		Goto See;
	Heal:
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \
		VILE "]" 10 Bright;
		VILE G 0 A_Jump(128,"SG","CG","REV","HK","LSOUL","CACO");
		Goto See;
	SG:
		VILE G 0 A_SpawnItemEx("RS_GrayDemon",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	CG:
		VILE G 0 A_SpawnItemEx("RS_GrayCGuy",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	REV:
		VILE G 0 A_SpawnItemEx("RS_GrayRevenant",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	HK:
		VILE G 0 A_SpawnItemEx("RS_GrayHK",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	LSOUL:
		VILE G 0 A_SpawnItemEx("RS_GraySpectre",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	CACO:
		VILE G 0 A_SpawnItemEx("RS_GrayCaco",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	Pain:
		VILE Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 A_Pain;
		VILE Q 0 A_Jump(128,"Decoy");
		Goto See;
	Decoy:
		VILE A 0 A_SpawnItemEx("RS_VileGrayDecoy",random(-32,32),random(-32,32),3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 AAA 2 A_Wander;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu ("Horrible sight").  CH: Archviles.txt:2115.
// ---------------------------------------------------------------------------
class RS_FireBluArch2 : Actor   // CH Archviles.txt:2115
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }

	Default
	{
		Health 1000;
		Species "vile1";
		BloodColor "Blue";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 19;
		PainChance 4;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+DONTHARMSPECIES
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		MeleeSound "vile/stop";
		DropItem "RS_ArmorBundle";
		DropItem "BackPack";
		DropItem "BackPack", 64;
		DropItem "BackPack", 128;
		DropItem "RS_CH_RocketLauncher", 32;
		Obituary "%o was fireblu fired by fireblu archvile!";
		Translation "48:52=195:199","53:57=177:184","58:61=202:206","62:63=190:191","208:213=176:182","214:223=201:207","64:68=200:203","69:74=180:185","75:79=204:207","135:143=181:188","128:135=201:207","13:14=179:181","15:15=203:203","144:146=199:201","147:149=179:182","150:151=205:207","5:12=186:191","160:162=200:203","163:165=181:184","166:167=205:207","249:249=198:198","226:231=178:183";
		Tag "Horrible sight";
	}
	States
	{
	Spawn:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		VILE G 0 A_VileStart;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 16 Bright A_FaceTarget;
		TNT1 A 3;
		VILE G 3 Bright A_FaceTarget;
		TNT1 A 3 A_CheckSight("See");
		VILE G 2 Bright A_FaceTarget;
		TNT1 A 2 A_CheckSight("See");
		VILE G 2 Bright A_FaceTarget;
		TNT1 A 2;
		VILE G 2 Bright A_FaceTarget;
		TNT1 A 1 A_CheckSight("See");
		VILE G 1 Bright A_FaceTarget;
		TNT1 A 1 A_CheckSight("See");
		VILE G 1 Bright A_FaceTarget;
		TNT1 A 1 A_CheckSight("See");
		VILE G 1 Bright A_PlaySound("vile/sight",9);
		VILE G 6 Bright A_FaceTarget;
		VILE H 5 Bright A_VileTarget("RS_FireBluVile");
		VILE IJKL 5 Bright A_FaceTarget;
		VILE M 0 A_CheckSight("See");
		VILE M 9 Bright A_VileTarget("RS_FireBluVile");
		VILE N 3 Bright;
		VILE O 7 Bright A_VileAttack("vile/stop",random(6,64),random(6,64),128,2,"Fire");
		VILE P 16 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Heal:
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10 Bright;
		VILE G 0 A_Jump(128,"SG","CG","REV","HK","LSOUL","CACO");
		Goto See;
	SG:
		VILE G 0 A_SpawnItemEx("RS_FireBluSG",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	CG:
		VILE G 0 A_SpawnItemEx("RS_FireBluCGuy",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	REV:
		VILE G 0 A_SpawnItemEx("RS_FireBluRevenant",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	HK:
		VILE G 0 A_SpawnItemEx("RS_FireBluHK",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	LSOUL:
		VILE G 0 A_SpawnItemEx("RS_FireBluLSoul",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	CACO:
		VILE G 0 A_SpawnItemEx("RS_FireBluCaco",-1,1,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	Pain:
		VILE Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 A_Pain;
		VILE Q 0 A_Jump(128,"SG","CG","REV");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common ("Archvile").  CH: Archviles.txt:2313.
// ---------------------------------------------------------------------------
class RS_CommonArch : Archvile   // CH Archviles.txt:2313
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }

	Default
	{
		Species "Vile1";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "Fire", 4;
		Monster;
		+DONTHARMCLASS
		Tag "Archvile";
	}
	States
	{
	Spawn:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		VILE G 0 A_VileStart;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 10 Bright A_FaceTarget;
		VILE H 8 Bright A_VileTarget;
		VILE IJKLMN 8 Bright A_FaceTarget;
		VILE O 8 Bright A_VileAttack;
		VILE P 20 Bright;
		Goto See;
	Heal:
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10 Bright;
		Goto See;
	Pain:
		VILE Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green.  CH: Archviles.txt:2384.
// ---------------------------------------------------------------------------
class RS_GreenArch : Archvile   // CH Archviles.txt:2384
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }

	Default
	{
		Health 750;
		Species "vile1";
		BloodColor "Green";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 16;
		PainChance 8;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+DONTHARMSPECIES
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		MeleeSound "vile/stop";
		DropItem "RS_ArmorBundle", 72;
		Obituary "%o got green painted by green archvile";
		Translation "48:63=112:121","64:79=118:127","128:143=120:127","144:151=121:127","208:223=112:127","13:15=124:127","160:167=112:127","249:249=112:112","168:191=112:127";
		Tag "Green Archvile";
	}
	States
	{
	Spawn:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		VILE G 0 A_VileStart;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 16 Bright A_FaceTarget;
		VILE H 5 Bright A_VileTarget("RS_Greenening");
		VILE IJKL 5 Bright A_FaceTarget;
		VILE M 0 A_CheckSight("See");
		VILE M 9 Bright A_VileTarget("RS_Greenening2");
		VILE N 3 Bright;
		VILE O 7 Bright A_VileAttack("vile/stop",random(6,32),random(6,32),64,2,"plasma");
		VILE P 16 Bright;
		Goto See;
	Heal:
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		VILE Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue.  CH: Archviles.txt:2579.
// ---------------------------------------------------------------------------
class RS_BlueArch : Archvile   // CH Archviles.txt:2579
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }

	Default
	{
		Health 860;
		Species "vile1";
		BloodColor "Blue";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 17;
		PainChance 6;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+DONTHARMSPECIES
		+DONTHARMCLASS
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		MeleeSound "vile/stop";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_SoulSphere", 42;
		// CH: Dropitem "RLPlasmaShieldArmorPickup",32 -- DRLA cross-mod drop, stripped
		Obituary "%o was lifted up to the blues";
		Translation "48:63=195:203","64:79=197:207","128:143=200:207","144:151=199:207","208:223=200:207","13:15=243:247","160:167=192:207","249:249=192:192","168:191=192:207";
		Tag "Blue Archvile";
	}
	States
	{
	Spawn:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_SpawnItemEx("RS_BlueGash",0,0,32);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_SpawnItemEx("RS_BlueGash",0,0,32);
		Loop;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 0 A_Jump(255,"Classic1","Boltings2");
	Classic1:
		VILE G 0 A_VileStart;
		VILE G 16 Bright A_FaceTarget;
		VILE H 7 Bright A_VileTarget("RS_BlueGash3");
		VILE IJKL 7 Bright A_FaceTarget;
		VILE MN 4 Bright A_VileTarget("RS_BlueGash3");
		VILE O 6 Bright A_VileAttack("vile/stop",random(12,42),random(12,42),64,10,"plasma");
		VILE P 16 Bright;
		Goto See;
	Boltings2:
		VILE G 5 A_FaceTarget;
		VILE G 5 A_PlaySound("Vile/sight");
		VILE H 4 A_SpawnItemEx("RS_BlueGash",0,0,32);
		VILE IJKLM 8 Bright A_FaceTarget;
		VILE N 1 Bright A_CustomMissile("RS_BigBolt2",32,0);
		VILE O 7 Bright;
		VILE P 8 Bright;
		Goto See;
	Heal:
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		VILE Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 0 A_SpawnItemEx("RS_BlueGash",0,0,32);
		VILE Q 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple.  CH: Archviles.txt:2781.
// ---------------------------------------------------------------------------
class RS_PurpleArch : Archvile   // CH Archviles.txt:2781
{
	int User_Summon;

	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }

	Default
	{
		Health 1001;
		Species "vile1";
		BloodColor "purple";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 18;
		PainChance 4;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+THRUSPECIES
		+DONTHARMCLASS
		+DONTHARMSPECIES
		-NORADIUSDMG
		+NOFEAR
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		MeleeSound "vile/stop";
		DropItem "RS_CH_SoulSphere", 64;
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		Obituary "%o met monarchy of vile kind";
		Translation "48:63=[250,173,250]:[148,23,174]","64:79=[176,19,160]:[89,26,91]","128:143=[183,27,205]:[86,24,85]","208:223=[240,159,226]:[108,19,100]","144:151=[214,63,191]:[89,34,94]","13:15=[184,48,173]:[94,31,99]","249:249=253:253","224:231=250:254","96:96=252:254","160:167=250:254","168:191=250:254";
		Tag "Purple Archvile";
	}
	States
	{
	Spawn:
		SKUL A 0 A_SpawnItemEx("RS_SpecialRev",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialRev",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialRev",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialRev",-5,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Idle:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_Jump(12,"Summon");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 0 A_Jump(64,"Classic2");
		VILE G 0 A_Jump(255,"Classic2","Summon");
		Goto See;
	Classic2:
		VILE G 0 A_VileStart;
		VILE G 13 Bright A_FaceTarget;
		VILE H 8 Bright A_VileTarget("RS_PurpleWorry");
		VILE IJKLM 11 Bright A_FaceTarget;
		VILE N 0 A_CheckSight("See");
		VILE N 9 Bright A_VileTarget("RS_PurpleWorry2");
		VILE O 8 Bright A_VileAttack;
		VILE P 16 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Summon:
		VILE G 1 A_JumpIf(User_Summon == 8, "See");
		VILE G 8 A_FaceTarget;
		VILE G 8 A_PlaySound("Vile/sight");
		VILE H 7;
		VILE IJKH 11 Bright A_FaceTarget;
		VILE G 3 Bright A_SpawnItemEx("RS_SpecialRev",random(-8,8),random(-12,12),6,SXF_SETTARGET|SXF_SETMASTER);
		VILE P 9 Bright { User_Summon = User_Summon + 1; }
		VILE P 2;
		Goto See;
	Heal:
		VILE A 1 A_SpawnItemEx("RS_PurpleWorry",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		VILE A 1 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,3);
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10 Bright;
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 { User_Summon = (User_Summon == 0) ? 1 : 0; }   // CH: A_Setuservar("User_Summon",User_Summon==0)
		VILE Q 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 5 -- Yellow ("Golden Archvile").  CH: Archviles.txt:3065.
// ---------------------------------------------------------------------------
class RS_YellowArch : Archvile   // CH Archviles.txt:3065
{
	int User_Summon2;

	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }

	Default
	{
		Health 1333;
		Species "vile1";
		BloodColor "Yellow";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 18;
		PainChance 4;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+THRUSPECIES
		+DONTHARMCLASS
		+DONTHARMSPECIES
		-NORADIUSDMG
		+NOFEAR
		RenderStyle "Add";
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		MeleeSound "vile/stop";
		DropItem "RS_CH_SoulSphere", 64;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "RS_HealthBundle";
		Obituary "%o met the terror that is the(more yellow than)Orange Archvile";
		Translation "48:63=[255,230,125]:[141,103,33]","64:79=[236,173,79]:[112,62,16]","13:15=[85,67,6]:[140,83,26]","128:143=[241,202,65]:[99,58,18]","144:151=[118,68,22]:[74,41,26]","168:191=160:167";
		Tag "Golden Archvile";
	}
	States
	{
	Spawn:
		SKUL A 0 A_SpawnItemEx("RS_ArchSpawnerOrb",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",-5,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
	Idle:
		VILE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AABBCC 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE DDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_Jump(11,"Summon");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE G 0 A_Jump(64,"Fires");
		VILE G 0 A_Jump(255,"Fires","Summon");
		Goto See;
	Fires:
		VILE G 0 A_VileStart;
		VILE G 13 Bright A_FaceTarget;
		VILE H 6 Bright A_VileTarget("RS_ArcRing1");
		VILE IJKLM 7 Bright A_FaceTarget;
		VILE N 7 Bright A_VileTarget("RS_ArcRing1");
		VILE O 0 A_CheckSight("See");
		VILE O 7 Bright A_VileTarget("RS_ArcRing2");
		VILE O 1 Bright A_VileAttack;
		VILE O 4 Bright A_CustomMissile("RS_ArcRing2",12,0,random(-3,3));
		VILE O 2 Bright A_CustomMissile("RS_ArcRing2",12,0,random(-3,3));
		VILE P 12 Bright;
		Goto See;
	Summon:
		VILE G 1 A_JumpIf(User_Summon2 >= 8, "See");
		VILE G 8 A_FaceTarget;
		VILE G 8 A_PlaySound("Vile/sight");
		VILE H 7 { User_Summon2 = User_Summon2 + 1; }
		VILE IJKH 11 Bright A_FaceTarget;
		VILE G 3 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-24,24),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		VILE G 2 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-24,24),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		VILE G 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-24,24),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		VILE P 2;
		Goto See;
	Heal:
		VILE A 1 A_SpawnItemEx("RS_ArcRing1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		VILE A 1 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,3);
		VILE "[" 10 Bright;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10 Bright;
		VILE A 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-12,12),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain.Fire:
		VILE Q 0 A_Jump(24,"Summon");
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 { User_Summon2 = User_Summon2 - 4; }
		VILE Q 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		VILE Q 7 A_KillChildren;
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		VILE Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Red boss's escort.  CH: Archviles.txt:3443. Summon -- no tier token.
// ---------------------------------------------------------------------------
class RS_SpecialVile : RS_CommonArch   // CH Archviles.txt:3443
{
	// RS_CommonArch's PostBeginPlay sets tier 1; this is a -COUNTKILL escort,
	// so the token is cleared back off per the family rule.
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }

	Default
	{
		Species "Vile1";
		Monster;
		+THRUSPECIES
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		RenderStyle "Add";
		Alpha 1;
		Obituary "%o ala Vile,medium rare.";
		MeleeRange 88;
		Tag "ArchArchvile";
	}
	States
	{
	See:
		VILE AABBCCDDEEFF 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_JumpIfMasterCloser(1000,"See");
		VILE A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red, ordinary phase ("Infernovile").  CH: Archviles.txt:3490.
// ---------------------------------------------------------------------------
class RS_RedArch2 : Actor   // CH Archviles.txt:3490
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }

	Default
	{
		Obituary "%o got fried up nicely by a Red Archvile";
		Health 1480;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 17;
		PainChance 10;
		BloodColor "08 08 08";
		DamageFactor "Extinguishing", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Fire", 0.2;
		Monster;
		+FLOORCLIP
		+NOTARGET
		-NORADIUSDMG
		+MISSILEMORE
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOFEAR
		+QUICKTORETALIATE
		SeeSound "Monster/diasit";
		PainSound "Monster/diapai";
		DeathSound "Monster/diadth";
		ActiveSound "Monster/diaact";
		DropItem "RS_CH_SoulSphere", 68;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_Bluearmor", 74;
		Tag "Infernovile";
	}
	States
	{
	Spawn:
		DIAB AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		DIAB AABBCC 2 A_Chase(null,"Missile",CHF_RESURRECT);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB DDEEFF 2 A_Chase(null,"Missile",CHF_RESURRECT);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB A 0 A_JumpIfCloser(420,"Breath",true);
		DIAB A 0 A_Jump(256,"Classical","Meteorr");
		Goto See;
	Breath:
		DIA2 A 0 A_PlaySound("Spell/SpellCast1");
		DIA2 A 9 A_FaceTarget;
		DIA2 C 5 A_FaceTarget;
		DIAB A 0 A_FaceTarget;
		DIAB ACE 2 A_CustomMissile("RS_ReABreath",38,0,random(-5,5));
		DIAB A 1 A_CheckRange(420,"See",true);
		DIAB A 1 A_MonsterRefire(128,"See");
		Goto Breath+3;
	Meteorr:
		DIAB HH 3 Bright A_FaceTarget;
		DIAB I 6 Bright A_CustomMissile("RS_BaronRing",64,0);
		DIAB PON 7 Bright A_FaceTarget;
		DIAB N 0 A_CustomMissile("RS_ReAComet",42,0);
		Goto See;
	Classical:
		DIAB G 0 A_FaceTarget;
		DIAB GH 3 Bright A_FaceTarget;
		DIAB I 3 A_CustomMissile("RS_DFire",32,0,0);
		DIAB HGHIHGHIHGHIGHI 3 Bright A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNoPain = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssVile",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		Stop;   // CH ends this one WITHOUT the A_die the other tiers have
	Pain:
		DIAB Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB Q 5 A_Pain;
		Goto See;
	Heal:
		DIA2 A 0 A_RadiusGive("RS_GrowRaisin",100,RGF_MONSTERS|RGF_CORPSES,3);
		DIA2 A 10 Bright A_SpawnItemEx("RS_ArcRing1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		DIAB B 2 Bright;
		DIA2 BB 5 Bright;
		DIA2 C 4 Bright;
		DIA2 CC 6 A_SpawnItemEx("RS_ArchSpawnerOrb",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		DIAB Q 7;
		DIAB R 7 A_Scream;
		DIAB S 7 A_NoBlocking;
		DIAB TUVW 7;
		DIAB XY 5;
		DIAB Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red, boss phase ("Grand Redfirevile").  CH: Archviles.txt:3699.
// ---------------------------------------------------------------------------
class RS_RedArch3 : Actor   // CH Archviles.txt:3699
{
	int User_Rage;

	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }

	Default
	{
		Obituary "%o was charred up red by the bossy Red Archvile";
		Health 3200;
		Species "Vile1";
		Radius 20;
		Height 56;
		Mass 500;
		Speed 15;
		PainChance 3;
		BloodColor "08 08 08";
		RadiusDamageFactor 0.33;
		DamageFactor "Fire", 0.5;
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 2.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 0;
		Monster;
		+FLOORCLIP
		+NOTARGET
		+MISSILEMORE
		+DONTMORPH
		+BOSS
		+DONTHARMSPECIES
		+DONTHARMCLASS
		-NORADIUSDMG
		+NOFEAR
		SeeSound "Monster/diasit";
		PainSound "Monster/diapai";
		DeathSound "Monster/diadth";
		ActiveSound "Monster/diaact";
		MeleeSound "vile/stop";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack", 128;
		DropItem "RS_BackPackBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_BFG9000", 24;
		Tag "Grand Redfirevile";
	}
	States
	{
	Spawn:
		SKUL A 1 NoDelay Bright A_SpawnItemEx("RS_SpecialVile",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialVile",0,5,-6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		Goto Scripted;
	Scripted:
		// CH: SKUL A 1 ACS_NamedExecuteAlways("AnnounceVile") -- ACS announcer, stripped
		SKUL A 1;
		Goto Idle;
	Idle:
		DIAB AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		DIAB AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		DIAB G 0 A_JumpIfHealthLower(1650,"AggroUP");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB G 0 A_Jump(60,"Fires");
		DIAB G 0 A_Jump(132,"Fires","SummonSouls","GroundVhirl");
		DIAB G 0 A_FaceTarget;
		DIAB GH 3 Bright A_FaceTarget;
		DIAB I 3 A_CustomMissile("RS_DFire",32,0,0);
		DIAB HGHIHGHIHGHIGHI 3 Bright A_FaceTarget;
		Goto See;
	Fires:
		DIA2 A 2 Bright A_CustomMissile("RS_BaronRing",1,0);
		DIA2 ABC 10 Bright A_PlaySound("Spell/SpellCast1");
		DIAB PON 9 Bright A_FaceTarget;
		DIAB I 6 Bright A_CustomMissile("RS_BaronRing",64,0);
		DIAB IH 7 Bright;
		DIAB GHGH 2 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(-12,12));
		DIAB GHGH 1 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHGH 2 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHGH 1 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHGH 2 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHGH 2 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(-12,12));
		DIAB GHGH 1 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHGH 2 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHGH 1 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB GHI 2 Bright A_CustomMissile("RS_DFlare",random(20,46),0,random(180,-180));
		DIAB I 1 Bright A_Jump(48,"GroundVhirl");
		DIAB I 1 Bright A_Jump(24,"SummonSouls");
		Goto See;
	SummonSouls:
		DIA2 A 10 Bright A_FaceTarget;
		DIAB B 2 Bright A_PlaySound("Forgotten/Pain");
		DIA2 BB 6 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		DIA2 C 4 Bright A_FaceTarget;
		DIA2 CC 6 A_SpawnItemEx("RS_ArchSpawnerOrb",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	GroundVhirl:
		DIA2 A 12 Bright A_FaceTarget;
		DIA2 A 2 Bright A_CustomMissile("RS_BaronRing",64,0);
		DIA2 B 2 Bright A_FaceTarget;
		DIA2 C 5 Bright;
		DIA2 C 0 A_CustomMissile("RS_ArcRing2",12,0,random(-13,-3));
		DIA2 C 0 A_CustomMissile("RS_ArcRing2",12,0,random(3,13));
		Goto See;
	AggroUP:
		DIAB G 1;
		DIAB G 2 A_JumpIf(User_Rage >= 1, "Nah");
		DIAB G 0 { bNoPain = true; }
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 9 A_PlaySound("Monster/diasit");
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		DIAB G 1 { bMissileEvenMore = true; }
		DIAB G 2 { User_Rage = User_Rage + 1; }
		Goto Missile+1;
	Nah:
		DIAB G 1;
		Goto Missile+1;
	Pain:
		DIAB Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DIAB Q 5 A_Pain;
		Goto See;
	Death:
		DIAB Q 7;
		DIAB R 7 A_Scream;
		DIAB S 7 A_NoBlocking;
		DIAB TUVW 7;
		DIAB XY 5;
		DIAB Z -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black ("Void Gazes Back").  CH: Archviles.txt:4347.
// ---------------------------------------------------------------------------
class RS_BlackVile : Actor   // CH Archviles.txt:4347
{
	int user_limit;

	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }

	Default
	{
		Health 7750;
		Species "vile1";
		BloodColor "Black";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 17;
		PainChance 8;
		RenderStyle "Stencil";
		Alpha 0.5;
		Monster;
		+QUICKTORETALIATE
		+FLOORCLIP
		+NOTARGET
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+DONTMORPH
		+DONTDRAIN
		+BOSS
		+CANTSEEK
		+SEEINVISIBLE
		+NOTIMEFREEZE
		+NOFEAR
		-NORADIUSDMG
		SeeSound "Bvile/Air6";
		PainSound "Bvile/Air5";
		DeathSound "Bvile/Air4";
		ActiveSound "Bvile/Air3";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_BFG9000", 128;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 64;
		// CH: Dropitem "RareArmorPool",128         -- DRLA cross-mod drop, stripped
		// CH: Dropitem "RLDemonicWeaponSpawner",12 -- DRLA cross-mod drop, stripped
		// CH: Dropitem "RLUniqueWeaponSpawner",24  -- DRLA cross-mod drop, stripped
		Obituary "%o existence was voided by the Black Vile";
		Tag "Void Gazes Back";
	}
	States
	{
	Spawn:
		VILE A 0;
		Goto Scripted;
	Scripted:
		VILE A 1 A_SpawnItemEx("RS_BVileEye",0,4,64,0,0,0,0,SXF_SETMASTER);
		VILE A 1 A_SpawnItemEx("RS_BVileEye2",0,4,64,0,0,0,0,SXF_SETMASTER);
		// CH: VILE A 1 ACS_NamedExecuteAlways("AnnounceBVile") -- ACS announcer, stripped
		VILE A 1;
		Goto Idle;
	Idle:
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE A 5 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE B 5 A_Look;
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		VILE AA 1 A_Chase;
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE BB 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_CustomMissile("RS_BVileCloud",1,random(-5,5),0,CMF_AIMOFFSET,random(0,90));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE CC 1 A_Chase;
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE DD 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_CustomMissile("RS_BVileCloud",1,random(-5,5),0,CMF_AIMOFFSET,random(0,90));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE EE 1 A_Chase;
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE FF 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 0 A_CustomMissile("RS_BVileCloud",1,random(-5,5),0,CMF_AIMOFFSET,random(0,90));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		Loop;
	Missile:
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE A 8 A_FaceTarget;
		VILE A 0 A_Jump(256,"GroundFlame","Balls","Summon");
	Balls:
		VILE M 6 A_FaceTarget;
		VILE N 5 A_CustomMissile("RS_BVileOrb1",32,0,random(-5,5));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE M 3 A_FaceTarget;
		VILE N 3 A_CustomMissile("RS_BVileOrb1",32,0,random(-12,12));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE M 3 A_FaceTarget;
		VILE N 3 A_CustomMissile("RS_BVileOrb1",32,0,random(-19,19));
		Goto See;
	Summon:
		VILE G 0 A_JumpIf(user_limit >= 1, "Balls");
		VILE G 12 A_PlaySound("Bvile/Air2",7,2,false,ATTN_NONE);
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE GGGGGGGGGGGGG 4 A_CustomMissile("RS_DFlamePuffVile2",random(42,72),random(-34,34),random(-180,180),0,random(-64,64));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE J 15 A_PlaySound("Bvile/Air1",7,2,false,ATTN_NONE);
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE "[" 15;
		TNT1 A 15;                  // CH: VILE \ -- see header frame note
		VILE "]" 15;
		VILE AA 0 A_SpawnItemEx("RS_CommonRevenant",random(-24,24),random(-24,24),6,0,0,0,0,SXF_TRANSFERRENDERSTYLE|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		VILE AAAA 0 A_SpawnItemEx("RS_MrBones",random(-24,24),random(-24,24),6,0,0,0,0,SXF_TRANSFERRENDERSTYLE|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		VILE GGGGGGGGGG 0 A_CustomMissile("RS_DFlamePuffVile2",random(6,32),random(-34,34),random(-180,180),0,random(-64,64));
		VILE A 1 { user_limit = user_limit + 2; }
		Goto See;
	GroundFlame:
		VILE G 8 A_FaceTarget;
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE JJJJJJJJJ 1 A_CustomMissile("RS_DFlamePuffVile2",random(4,42),0,random(-64,64),0,random(-64,64));
		VILE A 0 A_SpawnItemEx("RS_BVileCloud2",random(-7,7),random(-7,7),1,frandom(-1.1,1.1),frandom(-1.1,1.1),0.1,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH);
		VILE "[" 10;
		TNT1 A 10;                  // CH: VILE \ -- see header frame note
		VILE "]" 10;
		VILE A 0 A_CustomMissile("RS_DarkFlameVile",3,23,12,CMF_AIMDIRECTION);
		VILE A 0 A_CustomMissile("RS_DarkFlameVile",3,-23,-12,CMF_AIMDIRECTION);
		Goto See;
	Pain:
		VILE Q 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 5 A_Pain;
		VILE Q 5 A_Jump(88,"Phase");
		Goto See;
	Phase:
		VILE Q 1 A_SetSpeed(99);
		VILE ABCDEF 1 A_Wander;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		VILE Q 1 A_SetSpeed(17);
		VILE Q 1 { user_limit = user_limit - 1; }
		Goto See;
	Death:
		VILE Q 7;
		VILE Q 7 A_Scream;
		VILE Q 7 A_NoBlocking;
		VILE QQ 1 A_RadiusGive("RS_EyeIseeViles",64,RGF_NOSIGHT,2,"RS_BVileEye2");
		VILE QQ 1 A_RadiusGive("RS_EyeIseeViles",64,RGF_NOSIGHT,2,"RS_BVileEye");
		VILE Q 1 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		VILE QQQQQQQ 7 A_FadeOut(0.1);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White ("Here I am").  CH: Archviles.txt:5033.
// ---------------------------------------------------------------------------
class RS_Whitevile : Actor   // CH Archviles.txt:5033
{
	int user_courage;
	int user_hoho;

	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }

	Default
	{
		Obituary "%o was terrified to death by white archvile";
		Health 13000;
		Radius 20;
		Height 56;
		Mass 10;
		Speed 40;
		PainChance 64;
		SeeSound "wizard/sight";
		PainSound "wizard/pain";
		DeathSound "wizard/death";
		ActiveSound "wizard/active";
		Monster;
		+FLOAT
		+QUICKTORETALIATE
		+NOTARGET
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+DONTDRAIN
		+BOSS
		+CANTSEEK
		+SEEINVISIBLE
		+NOTIMEFREEZE
		+DONTMORPH
		+NOFEAR
		+DONTTHRUST
		+AVOIDMELEE
		-NORADIUSDMG
		-NOGRAVITY
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_BlueArmor", 128;
		// CH: Dropitem "RareArmorPool"                -- DRLA cross-mod drop, stripped
		// CH: Dropitem "RLDemonicWeaponSpawner",64    -- DRLA cross-mod drop, stripped
		// CH: Dropitem "RLLegendaryWeaponSpawner",32  -- DRLA cross-mod drop, stripped
		// CH: Dropitem "RLUniqueWeaponSpawner",92     -- DRLA cross-mod drop, stripped
		Translation "48:63=[255,255,255]:[192,192,192]","64:79=[205,205,205]:[13,13,13]","144:151=0:0","128:143=0:0","13:15=0:0";
		Tag "Here I am";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		// CH: TNT1 A 0 ACS_NamedExecuteAlways("AnnounceWVile") -- ACS announcer, stripped
		TNT1 A 0;
		Goto Idle;
	Idle:
		LMWZ E 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		LMWZ EEFF 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ EEFF 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 1 { bNoClip = true; }
		Goto Clippy;
	Clippy:
		LMWZ E 0 A_SpawnItemEx("RS_WhiteVileResser");
		LMWZ E 0 A_JumpIf(user_courage >= 160, "Agro2");
		LMWZ E 0 A_JumpIf(user_courage >= 100, "Agro");
		LMWZ E 0 A_JumpIf(user_courage >= 60, "Approach");
		LMWZ E 1 A_FastChase;
		LMWZ E 1 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.75);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.5);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.25);
		LMWZ E 3 A_Stop;
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.01);
		LMWZ EE 2 A_Chase;
		LMWZ E 0 A_CheckSight("NoWander");
		LMWZ EEEEEE 10 A_Wander;
		LMWZ EEEEEE 10 A_Wander;
		LMWZ EE 2 A_Chase;
		LMWZ E 0 { user_courage = user_courage + 1; }
		LMWZ F 1 A_SetTranslucent(0.25);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.5);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.75);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(1);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 15 A_Stop;
		Loop;
	Approach:
		LMWZ E 0 A_SetSpeed(30);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		LMWZ EE 6 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 0 { user_courage = user_courage + 2; }
		LMWZ E 5 A_FastChase;
		LMWZ E 3 A_Stop;
		Loop;
	NoWander:
		LMWZ EE 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		LMWZ F 1 A_SetTranslucent(0.25);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.5);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(0.75);
		LMWZ E 1 A_Chase;
		LMWZ F 1 A_SetTranslucent(1);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 0 { user_courage = user_courage + 3; }
		LMWZ E 15 A_Stop;
		Goto Clippy;
	Agro:
		LMWZ E 0 A_SetSpeed(30);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		LMWZ E 0 { bMissileMore = true; }
		LMWZ EE 6 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 4 A_FastChase;
		LMWZ E 1 A_Stop;
		LMWZ E 0 { user_courage = user_courage + 4; }
		LMWZ E 5 A_Chase;
		LMWZ E 4 A_FastChase;
		LMWZ E 1 A_Stop;
		Loop;
	Agro2:
		LMWZ E 0 A_SetSpeed(38);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteVileResser");
		LMWZ E 0 { bMissileEvenMore = true; }
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 0 { user_courage = user_courage + 100; }
		LMWZ EEEEE 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		LMWZ E 4 A_Chase;
		LMWZ E 4 A_FastChase;
		LMWZ E 4 A_Chase;
		Loop;
	Missile:
		LMWZ E 0 A_SetTranslucent(1);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 0 A_JumpIf(user_hoho >= 1, "EyeSeekers");
		LMWZ E 0 A_JumpIfCloser(1500,"Choices2",true);
		LMWZ E 0 A_Jump(256,"Choices1");
		Goto Clippy;
	Choices1:
		LMWZ E 0 A_Jump(256,"SpawnEye","EyeSees","Bolts");
		Goto Clippy;
	Choices2:
		LMWZ E 0 A_Jump(256,"Scream","SpawnEye","EyeSees","BoltVolley");
		Goto Clippy;
	SpawnEye:
		LMWZ EF 10 A_FaceTarget;
		LMWZ GGG 5 Bright A_SpawnItemEx("RS_WvileSpot",random(-128,128),random(-128,128),1,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION|SXF_SETMASTER);
		LMWZ HG 12;
		LMWZ E 2 { user_courage = user_courage - 15; }
		TNT1 AAA 0 A_SpawnItemEx("RS_WhiteVileResser",random(-128,128),random(-128,128),1,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto Clippy;
	Bolts:
		LMWZ EF 12 A_FaceTarget;
		LMWZ G 5 Bright A_CustomMissile("RS_WVileBolt1",42,0,random(-1,1));
		LMWZ G 5 Bright A_CustomMissile("RS_WVileBolt1",42,0,0);
		LMWZ G 5 Bright A_CustomMissile("RS_WVileBolt1",42,0,random(-1,1));
		LMWZ G 5 Bright A_CustomMissile("RS_WVileBolt1",42,0,random(-3,3));
		LMWZ HG 12;
		LMWZ E 2 { user_courage = user_courage - 10; }
		Goto Clippy;
	BoltVolley:
		LMWZ EFG 10 Bright A_FaceTarget;
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,6);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,0);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,-6);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,-12);
		LMWZ G 0 A_CustomMissile("RS_WVileBolt1",42,0,12);
		LMWZ HG 12;
		LMWZ E 2 { user_courage = user_courage - 15; }
		Goto Clippy;
	Scream:
		FLWM A 24 Bright;
		FLWM A 0 A_CheckSight("See");
		TNT1 AAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),random(-32,32),random(-32,32),32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FLWM A 24 Bright;
		FLWM A 0 A_CheckSight("See");
		FLWM B 14 Bright A_SpawnItemEx("RS_WVilequake",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		FLWM B 14 Bright A_PlaySound("Wvile/scream",7,2,false,ATTN_NONE);
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_WhiteVileResser",random(-728,728),random(-728,728),1,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrightUpVile2",random(-128,128),random(-128,128),random(1,12),0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		FLWM C 12 Bright;
		LMWZ EEEEEEEEE 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),random(-32,32),random(-32,32),32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAA 0 A_SpawnItemEx("RS_BrightUpVile2",random(-328,328),random(-328,328),random(1,12),0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		FLWM DE 10 Bright;
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_WhiteVileResser",random(-128,128),random(-128,128),1,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		FLWM EDCBA 5 Bright;
		LMWZ E 0 { user_courage = user_courage - 15; }
		Goto Clippy;
	EyeSees:
		LMWZ E 1 A_PlaySound("Forgotten/active");
		LMWZ EFG 10 A_FaceTarget;
		TNT1 A 0 A_CustomMissile("RS_WVileEye1",78,0);
		TNT1 A 0 A_CustomMissile("RS_WVileEye1",64,12);
		TNT1 A 0 A_CustomMissile("RS_WVileEye1",64,-12);
		TNT1 A 0 A_CustomMissile("RS_WVileEye1",48,24);
		TNT1 A 0 A_CustomMissile("RS_WVileEye1",48,-24);
		TNT1 A 0 { user_hoho = user_hoho + 1; }
		LMWZ HG 10;
		LMWZ E 2;
		Goto Clippy;
	EyeSeekers:
		LMWZ G 5 Bright A_FaceTarget;
		TNT1 A 0 A_RadiusGive("RS_WVEyeGo",320,RGF_MISSILES,10);
		LMWZ E 0 { user_courage = user_courage - 10; }
		TNT1 A 0 { user_hoho = user_hoho - 1; }
		Goto Missile;
	Pain:
		LMWZ I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ E 0 { user_courage = user_courage + 5; }
		LMWZ I 5 A_Pain;
		LMWZ I 3 A_Jump(128,"WhatThe");
		Goto Clippy;
	WhatThe:
		LMWZ F 1 { bNoPain = true; }
		LMWZ F 1 A_SetTranslucent(0.66);
		LMWZ F 1 A_SetTranslucent(0.33);
		LMWZ F 1 A_SetTranslucent(0.01);
		LMWZ EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE 1 A_Wander;
		LMWZ F 1 A_SetTranslucent(0.5);
		LMWZ F 1 A_SetTranslucent(1);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LMWZ F 1 { bNoPain = false; }
		LMWZ E 0 { user_courage = user_courage - 15; }
		LMWZ F 4 A_Stop;
		Goto Clippy;
	Death:
		LMWZ J 6 A_Scream;
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		LMWZ K 6 A_NoBlocking;
		LMWZ LMNO 6;
		LMWZ P -1;
		Stop;
	}
}
