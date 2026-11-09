// ============================================================================
// RS_Spider.zs -- Colourful Hell Arachnotron ("Spiders") family, native
// ZScript. Source: C:\Users\Command\Desktop\CH\decorate\Spiders.txt (4,574
// lines, read whole). Every actor cites its CH line. Support, projectiles and
// third-file externals: RS_SpiderFX.zs (see its header for cross-lane notes,
// expected-from-earlier-lane classes, proven-missing assets, and the
// standing strips).
//
// Tier ladder is CH's own icon index: 1 Common (Arachnotron), 2 Green,
// 3 Blue, 4 Purple, 5 Yellow (Orange Brainchoton), 6 Red (Red Rage),
// 7 FireBlu (Ugly floater), 8 Gray (Metal Spider?), 9 Abyss (Eye see),
// 10 Black (Macross Missile Spam, + EX), 11 White (White Spider, all four
// sizes), 12 Cyan (Cyan Flying Spider), 13 Brown (Brown Recluse).
// Minions -- RS_WhiteSpidegg and RS_MiniSP1 -- get no token.
//
// The colour gates reuse the existing rs_ch_* cvar set; this family adds
// none. CH_Brown -> rs_ch_brown, CH_Cyan -> rs_ch_cyan, CH_Abyssmal ->
// rs_ch_abyss, CH_FireBLUES -> rs_ch_fireblu, CH_Grayscale -> rs_ch_gray,
// CH_BlackBossy -> rs_ch_blackboss, CH_ExBoss -> rs_ch_exboss,
// CH_WhiteBossy -> rs_ch_whiteboss. Value semantics are CH's: 1 = colour
// off (reroll through the spawner), 3 = fifty-fifty, anything else = spawn.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Spiders.txt:1 -- Colourset9 replaces Arachnotron.
// ---------------------------------------------------------------------------
class RS_Colourset9 : RandomSpawner replaces Arachnotron   // CH Spiders.txt:1
{
	Default
	{
		DropItem "RS_CommonSP1", 255, 449;
		DropItem "RS_GreenSP1", 255, 235;
		DropItem "RS_BrownSP1", 255, 60;
		DropItem "RS_CyanSP1", 255, 90;
		DropItem "RS_BlueSP1", 255, 155;
		DropItem "RS_PurpleSP1", 255, 65;
		DropItem "RS_GraySP1", 255, 45;
		DropItem "RS_AbyssSP1", 255, 45;
		DropItem "RS_YellowSP1", 255, 30;
		DropItem "RS_FireBluSP1", 255, 20;
		DropItem "RS_RedSP1", 255, 25;
		DropItem "RS_BlackSP1", 255, 3;
		DropItem "RS_WhiteSP1", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families.
// ---------------------------------------------------------------------------
class RS_BrownSP1 : Actor   // CH Spiders.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset9",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanSP1 : Actor   // CH Spiders.txt:228 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset9",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssSP1 : Actor   // CH Spiders.txt:495 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset9",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluSP1 : Actor   // CH Spiders.txt:957 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset9",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GraySP1 : Actor   // CH Spiders.txt:1221 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset9",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GraySP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackSP1 : Actor   // CH Spiders.txt:2463 -- gates CH_BlackBossy + CH_ExBoss
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSPEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackSPEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackSPEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedSP1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteSP1 : Actor   // CH Spiders.txt:3545 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSP11",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSP1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common ("Arachnotron").  CH: Spiders.txt:1457.
// ---------------------------------------------------------------------------
class RS_CommonSP1 : Arachnotron   // CH Spiders.txt:1457
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "Spider1";
		GibHealth -100;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMSPECIES
		Tag "Arachnotron";
	}
	States
	{
	Spawn:
		BSPI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSPI A 20 Bright A_FaceTarget;
		BSPI G 4 Bright A_BspiAttack;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI H 4 Bright;
		BSPI H 1 Bright A_SpidRefire;
		Goto Missile+1;
	Pain:
		BSPI I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSPI J 20 A_Scream;
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BSPI J 1 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSPI J 20 A_Scream;
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BSPI I 4 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- NashGore chain stripped, animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		ARAG A -1 A_BossDeath;
		Stop;
	Raise:
		BSPI P 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BSPI ONMLKJ 5;
		Goto See+1;
	Grow:
		BSPI ONMLKJ 5;
		BSPI A 0 A_SpawnItemEx("RS_GreenSP1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green ("Green Arachnotron").  CH: Spiders.txt:1611.
// ---------------------------------------------------------------------------
class RS_GreenSP1 : Arachnotron   // CH Spiders.txt:1611
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Species "Spider1";
		BloodColor "Green";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 600;
		GibHealth -100;
		Radius 64;
		Height 64;
		Mass 700;
		Speed 13;
		PainChance 100;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		Obituary "%o met the green spider";
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		Translation "128:143=112:127","144:151=117:127","13:15=125:127","236:239=127:127","192:207=168:191","16:31=112:121","169:191=112:126","32:41=120:127";
		Tag "Green Arachnotron";
	}
	States
	{
	Spawn:
		BSPI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSPI A 8 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI G 7 Bright A_CustomMissile("RS_Spspit",32,0);
		BSPI G 7 Bright A_CustomMissile("RS_Spspit",32,0,random(-1,1));
		BSPI H 2 Bright A_Jump(128,"Missile");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BSPI I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSPI J 20 A_Scream;
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;
	Raise:
		BSPI P 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BSPI ONMLKJ 5;
		Goto See+1;
	Grow:
		BSPI ONMLKJ 5;
		BSPI A 0 A_SpawnItemEx("RS_BlueSP1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BSPI J 1 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSPI J 20 A_Scream;
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BSPI I 4 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		ARAG A -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue ("Blue Arachnotron").  CH: Spiders.txt:1776.
// ---------------------------------------------------------------------------
class RS_BlueSP1 : Arachnotron   // CH Spiders.txt:1776
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Species "Spider1";
		BloodColor "Blue";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 700;
		GibHealth -100;
		Radius 64;
		Height 64;
		Mass 750;
		Speed 14;
		PainChance 80;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		Obituary "%o was melted by familiar plasma";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 64;
		Translation "128:143=192:207","144:151=197:207","13:15=242:247","236:239=247:247","192:207=160:167","32:47=199:207","169:191=192:207","16:31=200:207";
		Tag "Blue Arachnotron";
	}
	States
	{
	Spawn:
		BSPI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSPI A 20 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI G 4 Bright A_CustomMissile("RS_PlasmaBallSP3",22,0,random(-1,1));
		BSPI H 3 Bright A_MonsterRefire(128,"See");
		Goto Missile+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BSPI I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSPI J 20 A_Scream;
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;
	Raise:
		BSPI P 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BSPI ONMLKJ 5;
		Goto See+1;
	Grow:
		BSPI ONMLKJ 5;
		BSPI A 0 A_SpawnItemEx("RS_PurpleSP1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BSPI J 1 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSPI J 20 A_Scream;
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BSPI I 4 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		ARAG A -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple ("Purple Arachnotron").  CH: Spiders.txt:1912.
// ---------------------------------------------------------------------------
class RS_PurpleSP1 : Arachnotron   // CH Spiders.txt:1912
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		BloodColor "Purple";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 800;
		Radius 64;
		Height 64;
		Mass 750;
		Speed 16;
		PainChance 20;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+MISSILEMORE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		Obituary "Purple spiders. Well ok than";
		DropItem "RS_CH_ClipBox", 128;
		DropItem "RS_ImplyingClip", 174;
		DropItem "RS_ImplyingClip", 88;
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_HealthBundle";
		// CH keeps a second, commented-out translation on this same line; not reproduced.
		Translation "128:143=250:254","144:151=250:254","13:15=254:254","236:239=254:254","192:207=112:127","16:31=250:254","169:191=250:254","32:47=254:254";
		Tag "Purple Arachnotron";
	}
	States
	{
	Spawn:
		BSPI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSPI A 20 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI G 0 A_PlaySound("grunt/attack");   // CH: sound "grunt/attack" is in no CH SNDINFO -- silent in CH too
		BSPI G 3 Bright A_CustomBulletAttack(6,4,random(1,4),random(1,3));
		BSPI H 2 Bright A_MonsterRefire(200,"See");
		Goto Missile+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BSPI I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSPI J 20 A_Scream;
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;
	Raise:
		BSPI PONMLKJ 5;
		Goto See+1;
	XDeath:
		BSPI J 1 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSPI J 20 A_Scream;
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BSPI I 4 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		ARAG A -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 5 -- Yellow ("Orange Brainchoton").  CH: Spiders.txt:2016.
// ---------------------------------------------------------------------------
class RS_YellowSP1 : Arachnotron   // CH Spiders.txt:2016
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		BloodColor "Yellow";
		Species "Spider1";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		-NOGRAVITY
		-FLOAT
		-FLOATBOB
		+DONTHARMSPECIES
		+BOSSDEATH
		+MISSILEMORE
		+SEEINVISIBLE
		+NOFEAR
		Health 777;
		Radius 24;
		Height 56;
		Mass 400;
		Speed 18;
		FloatSpeed 18;
		PainChance 150;
		SeeSound "aracnorb/sight";
		ActiveSound "baby/active";
		PainSound "baby/pain";
		DeathSound "aracnorb/death";
		MeleeSound "aracnorb/melee";
		MeleeDamage 6;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_ArmorBundle", 88;
		DropItem "RS_HealthBundle";
		DropItem "HealthBonus";
		DropItem "Backpack", 64;
		Obituary "%o got psych'd by yellow flying arachno";
		HitObituary "%o had %p skull chewed up by the yellow arachno";
		Translation "128:140=212:223","141:143=184:191","13:15=189:191","0:0=189:191","144:151=216:223","235:239=189:191","152:159=188:191","100:111=187:191","80:95=160:167","112:127=240:246";
		Tag "Orange Brainchoton";
	}
	States
	{
	Spawn:
		ACNB A 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ACNB A 0 { bFLOAT = true; }       // CH: A_Changeflag("FLOAT",TRUE)
		ACNB A 0 { bFLOATBOB = true; }    // CH: A_Changeflag("FLOATBOB",TRUE)
		ACNB A 0 { bNOGRAVITY = true; }   // CH: A_Changeflag("NOGRAVITY",TRUE)
		ACNB A 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB AB 5;
		ACNB C 6 A_MeleeAttack;
		Goto See+3;
	Missile:
		ACNB B 12 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB B 0 A_JumpIfCloser(1300,"Psyche1");
		ACNB B 0 A_Jump(255,"Psyche2");
		Goto See+3;
	Psyche2:
		ACNB C 10 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_PlaySound("Vile/Active",7,2,false,ATTN_NONE);
		ACNB C 3 Bright A_CheckSight("See");
		ACNB C 9 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ACNB C 3 Bright A_CheckSight("See");
		ACNB C 1 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ACNB C 3 Bright A_CheckSight("See");
		ACNB C 10 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ACNB C 3 Bright A_CheckSight("See");
		ACNB C 1 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ACNB C 9 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ACNB C 3 Bright A_CheckSight("See");
		ACNB C 10 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ACNB C 3 Bright A_CheckSight("See");
		ACNB C 1 Bright A_FaceTarget;
		ACNB C 3 Bright A_VileTarget("RS_PsychicAra");
		ACNB C 1 Bright A_FaceTarget;
		ACNB C 3 Bright A_VileTarget("RS_PsychicAra");
		ACNB C 1 Bright A_CheckSight("See");
		TNT1 A 0 A_PlaySound("Vile/Active",7,2,false,ATTN_NONE);
		ACNB D 12 Bright A_VileAttack("electricplasma/hit",random(40,80),0,0,0,"getoutofmyheadcharles");
		ACNB B 5;
		Goto Missile;
	Psyche1:
		ACNB C 2 Bright A_CustomMissile("RS_AracnorbBall",36,0,random(-3,3));
		ACNB B 2 Bright;
		ACNB D 0 A_Jump(42,"See");
		ACNB D 0 A_SpidRefire;
		Goto Psyche1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		ACNF I 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNF I 2 A_Pain;
		Goto See+3;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ACNB D 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FLOATBOB",0)
		ACNB D 0 A_Scream;
		ACNB D 6 A_Fall;
		ACNB D 1 A_BossDeath;
		Wait;
	Crash:
		ACNB EFG 6;
		ACNB H -1;
		Stop;
	Raise:
		ACNB HGFEDA 8;
		ACNB A 0 { bFLOATBOB = true; }   // CH: A_ChangeFlag("FLOATBOB",1)
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red ("Red Rage Arachnotron").  CH: Spiders.txt:2294.
// ---------------------------------------------------------------------------
class RS_RedSP1 : Actor   // CH Spiders.txt:2294
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Obituary "%o was toasted by not so tiny red spider";
		Health 1000;
		Radius 64;
		Height 64;
		Mass 600;
		Speed 16;
		Scale 1.2;
		Species "Spider1";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMSPECIES
		+FLOORCLIP
		+BOSSDEATH
		+MISSILEMORE
		+SEEINVISIBLE
		+MISSILEEVENMORE
		+NOFEAR
		PainChance 68;
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		DropItem "RS_CH_Cell", 164;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 88;
		DropItem "Backpack", 64;
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketBox", 128;
		// CH keeps a second, commented-out translation on this same line; not reproduced.
		Translation "208:223=0:2","167:167=0:2","128:143=[181,17,17]:[73,12,13]","144:151=[173,14,14]:[107,20,22]","13:15=[149,19,22]:[84,35,36]","236:239=[141,14,17]:[90,18,20]";
		Tag "Red Rage Arachnotron";
	}
	States
	{
	Spawn:
		BSP2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSP2 A 20;
		BSP2 A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag("NOPAIN",FALSE)
		BSP2 A 3 A_BabyMetal;
		BSP2 ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 D 3 A_BabyMetal;
		BSP2 DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSP2 A 20 Bright A_FaceTarget;
		BSP2 A 5 Bright { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BSP2 G 2 Bright A_CustomMissile("RS_RedBombSP",19,-12);
		BSP2 R 2 Bright;
		BSP2 H 2 Bright A_CustomMissile("RS_RedBombSP",19,12);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 Q 2 Bright A_SpidRefire;
		Goto Missile+2;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BSP2 I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 I 3 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSP2 J 20 A_Scream;
		BSP2 K 7 A_NoBlocking;
		BSP2 LMN 5;
		BSP2 O 5 A_BossDeath;
		BSP2 P -1;
		Stop;
	Raise:
		BSP2 PONMLKJ 5;
		Goto See+1;
	XDeath:
		BSP2 J 1 A_SpawnItemEx("RS_AraBoom3",0,12,26,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSP2 J 20 A_Scream;
		BSP2 JI 4 A_SpawnItemEx("RS_HKRedDeath",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		BSP2 I 4 A_SpawnItemEx("RS_AraBoom3",0,-12,24,0,0,0,0,SXF_NOCHECKPOSITION);
		BSP2 JI 4 A_SpawnItemEx("RS_HKRedDeath",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		BSP2 P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown ("Brown Recluse").  CH: Spiders.txt:40.
// ---------------------------------------------------------------------------
class RS_BrownSP2 : Arachnotron   // CH Spiders.txt:40
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Species "Spider1";
		BloodColor "Brown";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 600;
		GibHealth -100;
		Radius 64;
		Height 64;
		Mass 700;
		Speed 24;
		PainChance 32;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+QUICKTORETALIATE
		+NOTARGET
		+MISSILEMORE
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		Obituary "%o was browned by a brown spider";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_RocketAmmo", 32;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_Chainsaw", 128;
		Translation "0:255=#[134,90,57]";
		Tag "Brown Recluse";
	}
	States
	{
	Spawn:
		BSPI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSPI A 8 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_RadiusGive("Health",320,RGF_MONSTERS,200);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(8,64),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		BSPI GG 2 Bright A_CustomMissile("RS_BrownOrbSpiderCH",32,0,random(-1,1));
		BSPI GG 2 Bright A_CustomMissile("RS_BrownOrbSpiderCH",32,0,random(-7,-2));
		BSPI GH 2 Bright A_CustomMissile("RS_BrownOrbSpiderCH",32,0,random(2,7));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI HH 2 Bright A_CustomMissile("RS_BrownOrbSpiderCH",32,0,random(-1,1));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BSPI I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSPI J 20 A_Scream;
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;
	Raise:
		BSPI P 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BSPI ONMLKJ 5;
		Goto See+1;
	Grow:
		BSPI ONMLKJ 5;
		BSPI A 0 A_SpawnItemEx("RS_YellowSP1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BSPI J 1 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSPI J 20 A_Scream;
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BSPI I 4 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		ARAG A -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan ("Cyan Flying Spider").  CH: Spiders.txt:250.
// Its two ice orbs (RS_IceOrbCyanAra1/2) ship with the pain elemental lane.
// ---------------------------------------------------------------------------
class RS_CyanSP2 : Actor   // CH Spiders.txt:250
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		BloodColor "cyan";
		Species "Spider1";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Ice", 0.15;      // CH lists Ice twice, both 0.15
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 76;
		PainChance "Melee", 102;
		DamageFactor "Melee", 1.25;    // CH lists Melee twice, both 1.25
		DamageFactor "fire", 2.0;      // CH lists fire twice, both 2.0
		Monster;
		-NOGRAVITY
		-FLOAT
		-FLOATBOB
		+DONTHARMSPECIES
		+BOSSDEATH
		+MISSILEMORE
		+NOICEDEATH
		+NOFEAR
		+BRIGHT
		Health 777;
		Radius 24;
		Height 56;
		Mass 400;
		Speed 20;
		FloatSpeed 20;
		PainChance 128;
		RenderStyle "Add";
		Alpha 1.0;
		SeeSound "aracnorb/sight";
		ActiveSound "baby/active";
		PainSound "baby/pain";
		DeathSound "aracnorb/death";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_ArmorBundle", 88;
		DropItem "RS_HealthBundle";
		DropItem "HealthBonus";
		DropItem "Backpack", 128;
		Obituary "Ah, Frozen %o , made with cyan spider juice";
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
		Tag "Cyan Flying Spider";
	}
	States
	{
	Spawn:
		ACNB A 1 A_Look;
		Loop;
	See:
		ACNB A 0 { bFLOAT = true; }       // CH: A_Changeflag("FLOAT",TRUE)
		ACNB A 0 { bFLOATBOB = true; }    // CH: A_Changeflag("FLOATBOB",TRUE)
		ACNB A 0 { bNOGRAVITY = true; }   // CH: A_Changeflag("NOGRAVITY",TRUE)
		ACNB A 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(12,"See2");
		TNT1 A 0 A_Jump(2,"Jumps");
		Loop;
	See2:
		ACNB A 2 A_Chase;
		ACNB A 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB A 2 A_Chase;
		ACNB A 2 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+3;
	Jumps:
		ACNB A 2 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,2,0,0,3,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("Jam/jamd",0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Wander;
		ACNB A 2 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,2,0,0,3,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Melee:
	Missile:
		ACNB B 2 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB C 1 Bright A_Jump(255,"IceBombing","IceOrbs");
		ACNB B 2;
		Goto See;
	IceBombing:
		ACNB BBB 1 Bright A_FaceTarget;
		ACNB C 3 Bright A_CustomMissile("RS_SpiderCyanBomb",32,0,random(-1,1));
		TNT1 A 0 A_CheckSight("See");
		ACNB B 2 Bright A_SpidRefire;
		Goto IceBombing;
	IceOrbs:
		ACNB BBB 6 Bright A_FaceTarget;
		ACNB C 4 Bright;
		ACNB C 0 A_CustomMissile("RS_IceOrbCyanAra1",32,0,0,0,random(-3,3));
		ACNB C 4 Bright A_CustomMissile("RS_IceOrbCyanAra2",32,0,0);
		ACNB C 6 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		ACNF I 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNF I 2 A_Pain;
		TNT1 A 0 A_Jump(64,"Jumps");
		Goto See2;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ACNB D 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FLOATBOB",0)
		ACNB D 0 A_Scream;
		ACNB D 6 A_NoBlocking(false);
		ACNB D 10 A_BossDeath;
		ACNB EFGH 8;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,250);
		ACNB H 1 A_IceGuyDie;
		ACNB H -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu ("Ugly floater").  CH: Spiders.txt:976.
// ---------------------------------------------------------------------------
class RS_FireBluSP2 : Arachnotron   // CH Spiders.txt:976
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		BloodColor "Blue";
		Species "Spider1";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		-NOGRAVITY
		-FLOAT
		-FLOATBOB
		+DONTHARMSPECIES
		+BOSSDEATH
		+MISSILEMORE
		+SEEINVISIBLE
		+NOFEAR
		Health 999;
		Radius 24;
		Height 56;
		Mass 400;
		Speed 11;
		FloatSpeed 11;
		PainChance 150;
		SeeSound "aracnorb/sight";
		ActiveSound "baby/active";
		PainSound "baby/pain";
		DeathSound "aracnorb/death";
		XScale 1.33;
		YScale 0.88;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "Backpack";
		DropItem "RS_CH_Medikit", 128;
		Obituary "%o failed the disco dance of fireblu spider";
		Translation "128:143=176:191","144:151=196:207","13:15=199:205","105:111=200:204","152:159=200:204","80:95=173:177","236:239=203:205","112:127=0:0","96:104=179:180","160:167=192:207","224:231=174:191";
		Tag "Ugly floater";
	}
	States
	{
	Spawn:
		ACNB A 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ACNB A 0 { bFLOAT = true; }       // CH: A_Changeflag("FLOAT",TRUE)
		ACNB A 0 { bFLOATBOB = true; }    // CH: A_Changeflag("FLOATBOB",TRUE)
		ACNB A 0 { bNOGRAVITY = true; }   // CH: A_Changeflag("NOGRAVITY",TRUE)
		ACNB A 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		ACNB B 12 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB B 0 A_JumpIfCloser(1300,"Psyche1");
		ACNB B 0 A_Jump(255,"Psyche2");
		Goto See+3;
	Psyche2:
		ACNB C 2 Bright A_FaceTarget;
		ACNB C 1 Bright A_CustomMissile("RS_PlasmaBallSPFB3",36,0,0);
		ACNB C 1 Bright A_CustomMissile("RS_PlasmaBallSPFB4",36,0,0);
		ACNB C 2 Bright A_CustomMissile("RS_PlasmaBallSPFB3",36,0,0);
		ACNB C 2 Bright A_CustomMissile("RS_PlasmaBallSPFB4",36,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB B 2 A_MonsterRefire(128,"See");
		Goto Psyche2;
	Psyche1:
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB1",20,0,15,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB2",20,0,45,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB1",20,0,75,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB2",20,0,105,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB1",20,0,135,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB2",20,0,165,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB1",20,0,195,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB2",20,0,225,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB1",20,0,255,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB2",20,0,285,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB1",20,0,315,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB2",20,0,345,0);
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB3",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB4",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB3",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB4",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB3",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB4",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB3",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB4",36,0,random(-120,120));
		ACNB C 0 A_CustomMissile("RS_PlasmaBallSPFB3",36,0,random(-12,12));
		ACNB C 1 Bright A_CustomMissile("RS_PlasmaBallSPFB4",36,0,random(-12,12));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNB C 5 Bright;
		ACNB B 2 Bright;
		ACNB D 0 A_Jump(32,"See");
		ACNB D 0 A_SpidRefire;
		Goto Psyche1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		ACNF I 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ACNF I 2 A_Pain;
		Goto See+3;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ACNB D 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FLOATBOB",0)
		ACNB D 0 A_Scream;
		ACNB D 6 A_Fall;
		ACNB D 1 A_BossDeath;
		Wait;
	Crash:
		ACNB EFG 6;
		ACNB H -1;
		Stop;
	Raise:
		ACNB HGFEDA 8;
		ACNB A 0 { bFLOATBOB = true; }   // CH: A_ChangeFlag("FLOATBOB",1)
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray ("Metal Spider?").  CH: Spiders.txt:1240.
// ---------------------------------------------------------------------------
class RS_GraySP2 : Arachnotron   // CH Spiders.txt:1240
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Species "Spider1";
		BloodColor "Black";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "Fire", 1.25;    // CH lists Fire twice, both 1.25
		DamageFactor "Ice", 0.6;      // CH lists Ice twice, both 0.6
		DamageFactor "Plasma", 0.6;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 600;
		GibHealth -100;
		Radius 64;
		Height 64;
		Mass 700;
		Speed 13;
		PainChance 12;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		Obituary "%o met the gray spider";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_RocketAmmo", 32;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_Chainsaw", 128;
		Translation "128:143=93:108","144:151=106:111","236:239=5:7","13:15=5:7","192:207=0:0","32:47=0:0","168:191=0:0","112:127=0:0","160:167=0:0","224:235=0:0","249:249=0:0","240:247=0:0";
		Tag "Metal Spider?";
	}
	States
	{
	Spawn:
		BSPI AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		BSPI A 8 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI A 0 A_JumpIfCloser(500,"Scrap");
		BSPI G 11 Bright A_VileTarget("RS_CHBSTarget");
		BSPI G 11 Bright A_FaceTarget;
		BSPI G 11 Bright A_VileTarget("RS_CHBSTarget");
		BSPI G 7 Bright;
		BSPI GG 2 Bright A_CustomMissile("RS_SpiderStoneRocket",32,0,random(-2,2),0,random(-1,1));
		BSPI G 2 Bright A_CustomMissile("RS_SpiderStoneRocket",32,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI H 2 Bright;
		Goto See;
	Scrap:
		BSPI G 10 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI GGGGG 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-9,9));
		BSPI GGG 0 A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		BSPI GGGGG 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-13,13));
		BSPI GGG 0 A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-9,9));
		BSPI GGGG 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		BSPI GGG 0 A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-11,11));
		BSPI GGGG 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		BSPI H 6 Bright;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BSPI I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3 A_Pain;
		Goto See+1;
	Pain.Fire:
		BSPI I 3 A_Pain;
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 3;
		BSPI I 3 A_Pain;
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		Goto See+1;
	Pain.Plasma:
	Pain.Ice:
		BSPI I 2 A_PlaySound("ResistCH",7);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI I 2;
		BSPI I 2 A_Pain;
		Goto See+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BSPI J 20 A_Scream;
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;
	Raise:
		BSPI P 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BSPI ONMLKJ 5;
		Goto See+1;
	Grow:
		BSPI ONMLKJ 5;
		BSPI A 0 A_SpawnItemEx("RS_YellowSP1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die();
		Stop;
	XDeath:
		BSPI J 1 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		BSPI J 20 A_Scream;
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BSPI I 4 A_SpawnItemEx("RS_AraBoom3",0,0,21,0,0,0,0,SXF_NOCHECKPOSITION);
		BSPI JI 4 A_SpawnItemEx("RS_AraBoom2",random(-5,5),random(-32,32),random(2,42),0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		TNT1 A 8 A_SpawnItemEx("RS_AraBoom1",0,0,30,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		TNT1 AAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 A 3 A_NoBlocking;
		ARAG A -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss ("Eye see").  CH: Spiders.txt:518.
// ---------------------------------------------------------------------------
class RS_AbyssSP2 : Arachnotron   // CH Spiders.txt:518
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Species "Spider1";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "Fire", 0.65;   // CH lists Fire twice, both 0.65
		DamageFactor "Ice", 0.2;     // CH lists Ice twice, both 0.2
		DamageFactor "Plasma", 0.75;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 1850;
		Radius 64;
		Height 64;
		Mass 700;
		Speed 24;
		PainChance 24;
		Monster;
		+FLOORCLIP
		+NOBLOOD
		+BOSSDEATH
		+DONTHARMSPECIES
		+MISSILEMORE
		+NOFEAR
		+NOICEDEATH
		SeeSound "eatiidle";
		PainSound "eatipain";
		DeathSound "queen/death";
		ActiveSound "queen/active";
		Obituary "%o was driven insane by abyss spider";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_Berserk", 76;
		DropItem "Backpack", 64;
		DropItem "Backpack", 128;
		DropItem "RS_CH_Chainsaw", 128;
		Tag "Eye see";
	}
	States
	{
	Spawn:
		ABSP ABCDDDCB 10 A_Look;
		Loop;
	See:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPwalk1",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPwalk1",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABSP A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPwalk2",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABSP A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPwalk2",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(6,"Warp");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP A 3 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP B 3 Bright A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(450,"Choice1",true);
		TNT1 A 0 A_Jump(255,"Choice2");
		Goto See;
	Choice1:
		TNT1 A 0 A_Jump(255,"Breath","Missin");
		Goto See;
	Choice2:
		TNT1 A 0 A_Jump(255,"Voidi","Missin");
		Goto See;
	Missin:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP B 2 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP C 2 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP D 2 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
	Miss2:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP E 2 Bright A_FaceTarget;
		ABSP F 3 Bright A_CustomMissile("RS_AbyssSPBolt",38,0,random(-1,1));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABSP F 1 Bright A_SpidRefire;
		Goto Miss2;
	Voidi:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP B 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP C 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP D 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABSP G 12 Bright A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
	Voidi2:
		ABSP G 5 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 1 Bright A_CheckSight("See");
		ABSP G 7 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_PlaySound("Vile/Active",7,2,false,ATTN_NONE);
		ABSP G 3 Bright A_CheckSight("See");
		ABSP G 6 Bright A_FaceTarget;
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_CheckSight("See");
		ABSP G 1 Bright A_FaceTarget;
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_CheckSight("See");
		ABSP G 7 Bright A_FaceTarget;
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_CheckSight("See");
		ABSP G 1 Bright A_FaceTarget;
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 6 Bright A_FaceTarget;
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_CheckSight("See");
		ABSP G 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 1 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_CustomRailgun(0,0,"white","white",RGF_NOPIERCING,0,0,"RS_PsychicAra",0,0,0,0,0.8,1.0,"RS_PsychicPulse",1);
		ABSP G 3 Bright A_CheckSight("See");
		ABSP G 1 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_VileTarget("RS_PsychicAra");
		ABSP G 1 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright A_VileTarget("RS_PsychicAra");
		ABSP G 1 Bright A_CheckSight("See");
		TNT1 A 0 A_PlaySound("Vile/Active",7,2,false,ATTN_NONE);
		ABSP G 4 Bright A_VileTarget("RS_PsychicAbyssSP");
		ABSP G 8 Bright A_VileAttack("electricplasma/hit",random(60,120),0,0,0,"getoutofmyheadcharles");
		ABSP B 5 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(16,"See");
		ABSP G 1 Bright A_SpidRefire;
		Goto Voidi2;
	Breath:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP B 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP C 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP D 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP G 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP I 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP J 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP H 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
	Breath2:
		ABSP H 2 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP HH 1 Bright A_CustomMissile("RS_AbyssSPBreath",22,0,random(-12,12));
		ABSP HHHHH 1 Bright A_CustomMissile("RS_AbyssSPBreath",22,0,random(-22,22));
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"Warp");
		ABSP H 1 Bright A_SpidRefire;
		Goto Breath2;
	Pain:
		ABSP B 3 A_SpawnItemEx("RS_AbyssSPPain",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPPain",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP C 3 A_Pain;
		ABSP C 0 A_Jump(88,"Warp");
		Goto See;
	Warp:
		TNT1 AAAAAAAAAA 0 A_Wander;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Pain.Ice:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPPain",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP B 2 A_PlaySound("ResistCH",7);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPPain",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ABSP B 1 A_Pain;
		Goto See;
	Death:
		ABSP BCD 15;
		ABSP G 0 A_BossDeath;
		TNT1 A 0 A_Scream;
		ABSP JIGG 15;
		TNT1 A 0 A_NoBlocking;
		ABSP G 10 A_SetScale(1.0,0.7);
		ABSP G 10 A_SetScale(1.0,0.4);
		ABSP G 10 A_SetScale(1.0,0.1);
		ABSP GGG 10 A_FadeOut(0.33);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black boss ("Macross Missile Spam").  CH: Spiders.txt:2499.
// ---------------------------------------------------------------------------
class RS_BlackSP2 : Actor   // CH Spiders.txt:2499
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o got missile spammed the hell out";
		Health 5342;
		Radius 64;
		Height 64;
		Mass 1200;
		Speed 21;
		RadiusDamageFactor 0.25;
		DamageFactor "Plasma", 1.2;   // CH lists Plasma twice, both 1.2
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Scale 1.4;
		Species "Spider1";
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		Monster;
		+LAXTELEFRAGDMG
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+FLOORCLIP
		+DONTMORPH
		+BOSSDEATH
		+BOSS
		-NORADIUSDMG
		+MISSILEMORE
		+SEEINVISIBLE
		+MISSILEEVENMORE
		+NOFEAR
		PainChance 24;
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell", 64;
		DropItem "Backpack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketBox", 64;
		// CH: DropItem "RLFireStormModItem" -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RareArmorPool",64 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		Translation "128:143=101:111","144:151=0:2","13:15=0:2","236:239=0:2","208:223=240:247","160:167=205:207","48:63=197:197","96:111=101:111";
		Tag "Macross Missile Spam";
	}
	States
	{
	Spawn:
		BSP2 A 0;
		Goto Scripted;
	Scripted:
		BSP2 A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackSpider") -- announcers dropped per owner
		Goto Idle;
	Idle:
		BSP2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSP2 A 3 A_BabyMetal;
		BSP2 ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 D 3 A_BabyMetal;
		BSP2 DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 A 0 A_Jump(256,"Miss1","Miss2","Miss3","Miss4");
		Goto See;
	Miss1:
		BSP2 A 20 Bright A_FaceTarget;
		BSP2 G 2 Bright A_CustomMissile("RS_SpRocket3",19,-12,random(-2,2));
		BSP2 R 2 Bright A_FaceTarget;
		BSP2 H 2 Bright A_CustomMissile("RS_SpRocket3",19,12,random(-6,6));
		BSP2 Q 2 Bright A_MonsterRefire(128,"See");
		BSP2 Q 0 A_Jump(12,"Miss3");
		Goto Miss1+1;
	Miss2:
		BSP2 A 6 Bright;
		BSP2 Q 2 A_FaceTarget;
		BSP2 Q 9 A_CustomMissile("RS_SpRocket4",80,-34,random(-6,6));
		BSP2 Q 2 A_FaceTarget;
		BSP2 Q 9 A_CustomMissile("RS_SpRocket4",60,-64,random(-3,9));
		BSP2 Q 2 A_FaceTarget;
		BSP2 Q 9 A_CustomMissile("RS_SpRocket4",80,34,random(-9,3));
		BSP2 Q 2 A_FaceTarget;
		BSP2 Q 9 A_CustomMissile("RS_SpRocket4",60,64,random(-4,7));
		BSP2 Q 2 A_FaceTarget;
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4",90,-14,random(-2,2));
		BSP2 Q 9 A_CustomMissile("RS_SpRocket4",90,14,random(-2,2));
		Goto See;
	Miss3:
		BSP2 A 10 Bright A_FaceTarget;
		BSP2 I 8 Bright ThrustThingZ(0,100,0,0);
		BSP2 I 0 { bFLOAT = true; }       // CH: A_ChangeFlag(FLOAT,TRUE)
		BSP2 I 0 { bNOGRAVITY = true; }   // CH: A_ChangeFlag(NOGRAVITY,TRUE)
		BSP2 I 0 { bNOPAIN = true; }      // CH: A_ChangeFlag(NOPAIN,TRUE)
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-23,23));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",25,-25,random(-41,41));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",19,12,random(-16,16));
		BSP2 Q 1 Bright A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM5",49,32,random(-9,41));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",19,12,random(-61,6));
		BSP2 Q 1 Bright A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM3",39,-32,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",19,-12,random(-34,34));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM4",29,12,random(-16,16));
		BSP2 Q 1 Bright A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM2",19,-12,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM5",59,-12,random(-14,14));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM1",19,32,random(-61,61));
		BSP2 Q 1 Bright A_CustomMissile("RS_SPMM3",19,22,random(-39,39));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-12,12));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",26,-52,random(-4,9));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",1,12,random(-16,16));
		BSP2 Q 1 Bright A_CustomMissile("RS_SPMM2",9,-42,random(-19,19));
		BSP2 A 0 { bFLOAT = false; }       // CH: A_ChangeFlag(FLOAT,FALSE)
		BSP2 A 0 { bNOPAIN = false; }      // CH: A_ChangeFlag(NOPAIN,FALSE)
		BSP2 I 0 { bNOGRAVITY = false; }   // CH: A_ChangeFlag(NOGRAVITY,FALSE)
		Goto See;
	Miss4:
		BSP2 A 9 A_FaceTarget;
		BSP2 I 8 A_CustomMissile("RS_BBSP1",random(12,80),random(-60,60),random(-64,64));
		Goto See;
	Pain:
		BSP2 I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 I 3 A_Pain;
		BSP2 I 0 A_Jump(128,"Miss4","Miss3");
		Goto See+1;
	Death:
		BSP2 J 20 A_Scream;
		BSP2 K 9 A_NoBlocking;
		BSP2 LMN 8;
		BSP2 O 9 A_BossDeath;
		BSP2 P -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black boss EX ("Macross Missile Spam EX").  CH: Spiders.txt:2649.
// ---------------------------------------------------------------------------
class RS_BlackSPEX : Actor   // CH Spiders.txt:2649
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was missile spammed even after beging already dead by black spider EX";
		Health 12000;
		Radius 64;
		Height 64;
		Mass 1200;
		Speed 21;
		RadiusDamageFactor 0.2;
		DamageFactor "Plasma", 1.5;   // CH lists Plasma twice, both 1.5
		DamageFactor "Heroic", 3.0;
		DamageFactor "Ice", 1.8;      // CH lists Ice twice, both 1.8
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Scale 1.15;
		Species "Spider1";
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		Monster;
		+LAXTELEFRAGDMG
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+FLOORCLIP
		+DONTMORPH
		+BOSSDEATH
		+BOSS
		-NORADIUSDMG
		+MISSILEMORE
		+SEEINVISIBLE
		+MISSILEEVENMORE
		+NOFEAR
		PainChance 24;
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_Cell", 64;
		DropItem "Backpack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketBox", 64;
		// CH: DropItem "RLFireStormModItem" -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RareArmorPool",102 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		// CH keeps the tier-10 black translation commented out below this one; not reproduced.
		Translation "0:255=%[0.00,0.00,0.00]:[0.24,0.24,0.27]","208:223=%[0.25,0.00,0.50]:[1.26,0.72,1.38]","147:147=47:47","144:144=191:191","149:149=191:191";
		Tag "Macross Missile Spam EX";
	}
	States
	{
	Spawn:
		BSP2 A 0;
		Goto Scripted;
	Scripted:
		BSP2 A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackSpider") -- announcers dropped per owner
		BSP2 A 0 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		BSP2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSP2 A 2 A_BabyMetal;
		BSP2 AB 2 A_Chase;
		BSP2 B 2 A_BabyMetal;
		BSP2 CC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 D 2 A_BabyMetal;
		BSP2 DE 2 A_Chase;
		BSP2 E 2 A_BabyMetal;
		BSP2 FF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 A 0 A_JumpIfHealthLower(7000,"ChoicesMore");
		BSP2 A 0 A_Jump(256,"Miss1","Miss2","Miss3","Miss4");
		Goto See;
	ChoicesMore:
		BSP2 A 0 A_Jump(256,"Miss5","Miss6","Miss7","Miss8","Miss9");
		Goto See;
	Miss5:
		BSP2 A 10 Bright A_FaceTarget;
		BSP2 I 8 Bright ThrustThingZ(0,100,0,0);
		BSP2 I 0 { bFLOAT = true; }       // CH: A_ChangeFlag(FLOAT,TRUE)
		BSP2 I 0 { bNOGRAVITY = true; }   // CH: A_ChangeFlag(NOGRAVITY,TRUE)
		BSP2 I 0 { bNOPAIN = true; }      // CH: A_ChangeFlag(NOPAIN,TRUE)
		BSP2 R 2 Bright A_FaceTarget;
		BSP2 G 3 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-2,2));
		BSP2 H 3 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-2,2));
		BSP2 G 2 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-5,5));
		BSP2 H 2 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-5,5));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-8,8));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-8,8));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-5,5));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-5,5));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-3,3));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-3,3));
		BSP2 R 1 Bright A_FaceTarget;
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-3,3));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-3,3));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-3,3));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-3,3));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-3,3));
		BSP2 H 0 A_CustomMissile("RS_ExSpideLaser1",19,12,random(-6,6));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-6,6));
		BSP2 H 0 A_CustomMissile("RS_ExSpideLaser1",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-9,9));
		BSP2 H 0 A_CustomMissile("RS_ExSpideLaser1",19,12,random(-13,13));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-17,17));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-17,17));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-9,9));
		BSP2 H 0 A_CustomMissile("RS_ExSpideLaser1",19,12,random(-13,13));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-17,17));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-17,17));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-9,9));
		BSP2 H 0 A_CustomMissile("RS_ExSpideLaser1",19,12,random(-13,13));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-17,17));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-17,17));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-9,9));
		BSP2 H 0 A_CustomMissile("RS_ExSpideLaser1",19,12,random(-13,13));
		BSP2 G 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-17,17));
		BSP2 H 1 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-17,17));
		BSP2 R 5 Bright A_FaceTarget;
		BSP2 R 5 Bright A_Jump(64,"Miss33");
		BSP2 A 20 Bright A_FaceTarget;
		BSP2 A 0 { bFLOAT = false; }       // CH: A_ChangeFlag(FLOAT,FALSE)
		BSP2 A 0 { bNOPAIN = false; }      // CH: A_ChangeFlag(NOPAIN,FALSE)
		BSP2 I 0 { bNOGRAVITY = false; }   // CH: A_ChangeFlag(NOGRAVITY,FALSE)
		Goto See;
	Miss8:
		BSP2 A 0 A_Jump(128,"Miss1","Miss2","Miss3","Miss4");
		BSP2 A 10 Bright A_FaceTarget;
		BSP2 G 2 Bright A_FaceTarget;
		BSP2 R 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING|RGF_SILENT);
		TNT1 A 0 A_FaceTarget;
		BSP2 H 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING|RGF_SILENT);
		TNT1 A 0 A_FaceTarget;
		BSP2 Q 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING|RGF_SILENT);
		TNT1 A 0 A_FaceTarget;
		BSP2 R 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING|RGF_SILENT);
		TNT1 A 0 A_FaceTarget;
		BSP2 H 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING|RGF_SILENT);
		TNT1 A 0 A_FaceTarget;
		BSP2 Q 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING|RGF_SILENT);
		BSP2 GGGGGG 10 Bright A_CustomMissile("RS_YellowBombEXSpidie",random(34,50),random(-10,10),random(-3,3));
		Goto See;
	Miss7:
		BSP2 A 10 Bright A_FaceTarget;
		BSP2 G 6 Bright A_FaceTarget;
		BSP2 R 6 Bright A_CustomMissile("RS_BlackSpideSpiralShot",32,0,0);
		BSP2 HQ 6 Bright;
		Goto See;
	Miss9:
		BSP2 A 10 Bright A_FaceTarget;
		BSP2 G 2 Bright;
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",60,15,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",60,-15,random(-2,2));
		BSP2 G 8 Bright A_CustomMissile("RS_SpRocket4EX",70,0,random(-2,2));
		BSP2 R 4 Bright A_FaceTarget;
		BSP2 H 2 Bright;
		Goto See;
	Miss33:
		TNT1 A 0;
		Goto Miss3+5;
	Miss1:
		BSP2 A 20 Bright A_FaceTarget;
		BSP2 G 2 Bright A_CustomMissile("RS_ExSpideLaser1",19,-12,random(-2,2));
		BSP2 R 2 Bright A_FaceTarget;
		BSP2 H 2 Bright A_CustomMissile("RS_ExSpideLaser1",19,12,random(-2,2));
		BSP2 Q 2 Bright A_MonsterRefire(128,"See");
		BSP2 Q 0 A_Jump(12,"Miss3");
		Goto Miss1+1;
	Miss6:
		BSP2 A 20 Bright A_FaceTarget;
		BSP2 G 2 Bright;
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",80,-14,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",60,-14,random(-2,2));
		BSP2 G 2 Bright A_CustomMissile("RS_SpRocket4EX",70,-10,random(-2,2));
		BSP2 R 6 Bright A_FaceTarget;
		BSP2 H 6 Bright;
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",80,14,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",60,14,random(-2,2));
		BSP2 H 2 Bright A_CustomMissile("RS_SpRocket4EX",70,10,random(-2,2));
		BSP2 Q 2 Bright A_MonsterRefire(128,"See");
		Goto Miss6+1;
	Miss2:
		BSP2 A 6 Bright;
		BSP2 Q 2 Bright A_FaceTarget;
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,-34,random(-6,6));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",80,-14,random(-6,6));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",90,0,random(-6,6));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",80,14,random(-6,6));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,34,random(-6,6));
		BSP2 Q 4 Bright A_FaceTarget;
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,-58,random(-3,9));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,-78,random(-3,9));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,-86,random(-3,9));
		BSP2 Q 4 Bright A_FaceTarget;
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,58,random(-9,3));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,78,random(-9,3));
		BSP2 Q 2 Bright A_CustomMissile("RS_SpRocket4",60,86,random(-9,3));
		BSP2 QQ 6 Bright A_FaceTarget;
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",80,-24,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",80,24,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",60,-24,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",60,24,random(-2,2));
		BSP2 Q 0 A_CustomMissile("RS_SpRocket4EX",70,-20,random(-2,2));
		BSP2 Q 12 A_CustomMissile("RS_SpRocket4EX",70,20,random(-2,2));
		Goto See;
	Miss3:
		BSP2 A 10 Bright A_FaceTarget;
		BSP2 I 8 Bright ThrustThingZ(0,100,0,0);
		BSP2 I 0 { bFLOAT = true; }       // CH: A_ChangeFlag(FLOAT,TRUE)
		BSP2 I 0 { bNOGRAVITY = true; }   // CH: A_ChangeFlag(NOGRAVITY,TRUE)
		BSP2 I 0 { bNOPAIN = true; }      // CH: A_ChangeFlag(NOPAIN,TRUE)
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-23,23));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",25,-25,random(-41,41));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",19,12,random(-16,16));
		BSP2 Q 0 A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM5",49,32,random(-9,41));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",19,12,random(-61,6));
		BSP2 Q 0 A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM3",39,-32,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",19,-12,random(-34,34));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM4",29,12,random(-16,16));
		BSP2 Q 0 A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM2",19,-12,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM5",59,-12,random(-14,14));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM1",19,32,random(-61,61));
		BSP2 Q 0 A_CustomMissile("RS_SPMM3",19,22,random(-39,39));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-12,12));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",26,-52,random(-4,9));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",1,12,random(-16,16));
		BSP2 Q 0 A_CustomMissile("RS_SPMM2",9,-42,random(-19,19));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-23,23));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",25,-25,random(-41,41));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",19,12,random(-16,16));
		BSP2 Q 0 A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM1",19,-12,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM5",49,32,random(-9,41));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM3",19,12,random(-61,6));
		BSP2 Q 0 A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM3",39,-32,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM2",19,-12,random(-34,34));
		BSP2 H 1 Bright A_CustomMissile("RS_SPMM4",29,12,random(-16,16));
		BSP2 Q 0 A_CustomMissile("RS_SPMM4",19,12,random(-9,9));
		BSP2 G 1 Bright A_CustomMissile("RS_SPMM2",19,-12,random(-22,22));
		BSP2 R 1 Bright A_CustomMissile("RS_SPMM5",59,-12,random(-14,14));
		BSP2 A 0 { bFLOAT = false; }       // CH: A_ChangeFlag(FLOAT,FALSE)
		BSP2 A 0 { bNOPAIN = false; }      // CH: A_ChangeFlag(NOPAIN,FALSE)
		BSP2 I 0 { bNOGRAVITY = false; }   // CH: A_ChangeFlag(NOGRAVITY,FALSE)
		Goto See;
	Miss4:
		BSP2 AG 9 A_FaceTarget;
		BSP2 I 8 A_CustomMissile("RS_YellowBombEXSpidie",random(34,50),random(-40,40),random(-18,-4));
		BSP2 I 8 A_CustomMissile("RS_YellowBombEXSpidie",random(34,50),random(-40,40),random(0,0));
		BSP2 I 8 A_CustomMissile("RS_YellowBombEXSpidie",random(34,50),random(-40,40),random(4,18));
		Goto See;
	Pain:
		BSP2 I 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSP2 I 3 A_Pain;
		BSP2 I 0 A_Jump(128,"Miss4","Miss3");
		Goto See+1;
	Death:
		BSP2 J 20 A_Scream;
		BSP2 K 9 A_NoBlocking;
		BSP2 LMN 8;
		BSP2 O 9 A_BossDeath;
		BSP2 P -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White boss ("White Spider").  CH: Spiders.txt:3765.
// ---------------------------------------------------------------------------
class RS_WhiteSP11 : Actor   // CH Spiders.txt:3765
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		BloodColor "White";
		Health 7000;
		Radius 64;
		Height 64;
		Mass 1500;
		Speed 28;
		PainChance 32;
		YScale 1.3;
		XScale 2.3;
		Species "WhiteSP";
		DamageFactor "fire", 1.2;
		DamageFactor "ice", 0.5;   // CH lists ice twice, both 0.5
		DamageFactor "Plasma", 0.85;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		RadiusDamageFactor 0.5;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+BOSS
		-NORADIUSDMG
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+DONTMORPH
		+MISSILEMORE
		+LAXTELEFRAGDMG
		+NOFEAR
		+NOICEDEATH
		Damage 5;
		SeeSound "kawai/sight";
		PainSound "kawai/pain";   // CH: SNDINFO has Kawai/hurt, never Kawai/pain -- silent in CH too
		DeathSound "kawai/death";
		ActiveSound "kawai/active";
		Obituary "%o was eliminated by the white spider of terror";
		DropItem "RS_CH_SoulSphere";
		DropItem "Backpack";
		DropItem "RS_BackPackBundle";
		Translation "0:249=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","128:143=80:95","144:151=87:95","13:15=93:95","96:111=80:95","236:239=95:95","152:159=80:89","5:12=85:95","0:2=92:95","168:191=0:2","192:207=0:0","32:47=0:0";
		Tag "White Spider";
	}
	States
	{
	Spawn:
		TRIT A 0;
		Goto Scripted;
	Scripted:
		TRIT A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSpider") -- announcers dropped per owner
		Goto Idle;
	Idle:
		TRIT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BSP2 I 0 { bFLOAT = false; }       // CH: A_ChangeFlag(FLOAT,FALSE)
		BSP2 I 0 { bNOGRAVITY = false; }   // CH: A_ChangeFlag(NOGRAVITY,FALSE)
		BSP2 I 0 { bNOPAIN = false; }      // CH: A_ChangeFlag(NOPAIN,FALSE)
		TRIT AABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT DDEE 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT A 0 A_JumpIfHealthLower(4000,"Set2");
		TRIT A 0 A_Jump(256,"Atk1","Atk2","Web","Atk5","Atk6","Atk7");
		Goto See;
	Set2:
		TRIT A 0 A_Jump(256,"Atk1","Atk2","Atk3","Web","Atk5","Atk6","Atk7","Atk8");
		Goto See;
	Web:
		TRIT A 12 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT E 12 Bright A_FaceTarget;
		TRIT E 5 Bright A_CustomMissile("RS_WHITESPIDERWEBSHOTNOTLEWD",42,0,random(-1,1));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT E 12 Bright A_FaceTarget;
		TRIT E 5 Bright A_CustomMissile("RS_WHITESPIDERWEBSHOTNOTLEWD",42,0,randompick(-18,-12,12,18));
		TRIT F 12 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT A 12 Bright;
		Goto See;
	SpawnSpiders:
		TRIT E 12 Bright A_FaceTarget;
		TRIT E 8 Bright A_PainAttack("RS_MiniSP1");
		TRIT F 4 Bright A_DualPainAttack("RS_MiniSP1");
		Goto See;
	Atk1:
		TRIT A 2 Bright A_FaceTarget;
		BSP2 I 0 { bFLOAT = true; }       // CH: A_ChangeFlag(FLOAT,TRUE)
		BSP2 I 0 { bNOGRAVITY = true; }   // CH: A_ChangeFlag(NOGRAVITY,TRUE)
		BSP2 I 0 { bNOPAIN = true; }      // CH: A_ChangeFlag(NOPAIN,TRUE)
		TRIT A 1 Bright ThrustThingZ(0,40,0,0);
		TRIT A 0 ThrustThing(int(angle),32,0,0);   // CH: thrustthing(angle,32,0,0)
		TRIT A 1 Bright;
		TRIT EF 8 Bright;
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-1,1));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(3,12));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-12,-3));
		TRIT F 20 Bright A_FaceTarget;
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-1,1));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(3,12));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-12,-3));
		BSP2 I 0 { bFLOAT = false; }       // CH: A_ChangeFlag(FLOAT,FALSE)
		BSP2 I 0 { bNOGRAVITY = false; }   // CH: A_ChangeFlag(NOGRAVITY,FALSE)
		TRIT F 24 Bright { bNOPAIN = false; }   // CH: A_ChangeFlag(NOPAIN,FALSE)
		TNT1 A 0 A_Jump(64,"Web","SpawnSpiders");
		Goto See;
	Atk2:
		TNT1 A 0 A_JumpIfCloser(400,"Atk4",true);
		TRIT A 12 Bright;
		TRIT E 12 Bright A_FaceTarget;
		TRIT E 6 Bright A_CustomRailgun(0,0,"none","white",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,null,-12);
		TRIT E 12 Bright A_PlaySound("SHARPST1",7,2,false,ATTN_NONE);
		TRIT E 12 Bright A_FaceTarget;
		TRIT E 6 Bright A_CustomRailgun(0,0,"none","white",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,null,-12);
		TRIT E 6 Bright A_CustomRailgun(0,0,"none","white",RGF_FULLBRIGHT|RGF_SILENT,0,0,"RS_RedDotSGPuff",0,0,0,15,0.5,0.5,null,-12);
		TRIT E 6 Bright;
		// CH: WhiteFatRB / WhiteFatRB2, Fatsos.txt:3958/4047 -- shipped by the fatso lane.
		TRIT E 12 Bright A_CustomRailgun(random(40,90),0,"white","white",RGF_NOPIERCING,1,0,"RS_WhiteFatRB",0,0,0,0,0.4,1.0,"RS_WhiteFatRB2",0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSPShoot",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TRIT E 32 Bright;
		TRIT A 2 Bright A_PlaySound("kawai/sight",0);
		TNT1 A 0 A_Jump(64,"SpawnSpiders");
		Goto See;
	Atk5:
		TRIT E 8 Bright;
		TRIT F 8 Bright A_FaceTarget;
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-1,1));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-3,3));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-5,5));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-7,7));
		TNT1 A 0 A_Jump(64,"Web");
		TRIT F 20 Bright A_FaceTarget;
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-1,1));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-2,2));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-3,3));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-1,1));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-2,2));
		TRIT E 5 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,random(-3,3));
		TNT1 A 0 A_Jump(64,"Web","SpawnSpiders");
		Goto See;
	Atk6:
		TRIT E 8 Bright;
		TRIT F 12 Bright A_FaceTarget;
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-15);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-11);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-7);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-3);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-1);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,1);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,3);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,7);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,11);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,15);
		TNT1 A 0 A_Jump(64,"Web","Atk7");
		Goto See;
	Atk7:
		TRIT E 8 Bright;
		TRIT F 12 Bright A_FaceTarget;
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,15);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,11);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,7);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,3);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,1);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-1);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-3);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-7);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-11);
		TRIT E 2 Bright A_CustomMissile("RS_WhiteSpiderPBolt",42,0,-15);
		TNT1 A 0 A_Jump(64,"Web","Atk6");
		Goto See;
	Atk8:
		TRIT A 12 Bright;
		TRIT E 17 Bright A_FaceTarget;
		WORM F 0 A_CustomMissile("RS_WhiteSpiderHomer",28,0,0);
		TRIT F 12 Bright A_FaceTarget;
		TRIT A 12 Bright;
		TNT1 A 0 A_Jump(64,"SpawnSpiders");
		Goto See;
	Atk4:
		TRIT A 12 Bright;
		TRIT E 17 Bright A_FaceTarget;
		WORM F 0 A_CustomMissile("RS_SlimeBall1",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall2",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall3",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall4",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall5",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall1",40,0,random(-12,-10),2,random(13,30));
		WORM F 0 A_CustomMissile("RS_SlimeBall2",40,0,random(-10,-8),2,random(13,30));
		WORM F 0 A_CustomMissile("RS_SlimeBall3",40,0,random(-10,10),2,random(13,30));
		WORM F 0 A_CustomMissile("RS_SlimeBall4",40,0,random(8,10),2,random(13,30));
		WORM F 0 A_CustomMissile("RS_SlimeBall5",40,0,random(10,12),2,random(13,30));
		TRIT F 12 Bright A_FaceTarget;
		TRIT A 12 Bright;
		TNT1 A 0 A_Jump(64,"Web","SpawnSpiders");
		Goto See;
	Atk3:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag(NOPAIN,TRUE)
		TNT1 A 0 A_SetSpeed(45);
		TRIT AAA 3 Bright A_Wander;
		TRIT AAAAAAAAAA 1 Bright A_Wander;
		TRIT E 1 Bright A_FaceTarget;
		TRIT E 5 Bright A_PainAttack("RS_WhiteSpidegg");
		TRIT AAA 3 Bright A_Wander;
		TRIT AAAAAAAAAA 1 Bright A_Wander;
		TRIT F 1 Bright A_FaceTarget;
		TRIT E 8 Bright A_PainAttack("RS_WhiteSpidegg");
		TRIT F 1 Bright A_PainAttack("RS_WhiteSpidegg");
		TRIT AAA 3 Bright A_Wander;
		TRIT AAAAAAAAAA 1 Bright A_Wander;
		TNT1 A 0 A_SetSpeed(28);
		TNT1 A 0 { bNOPAIN = false; }   // CH: A_changeflag(NOPAIN,FALSE)
		TNT1 A 0 A_Jump(64,"SpawnSpiders");
		Goto See;
	Pain:
		TRIT F 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT F 3 A_Pain;
		TRIT F 3;
		Goto See+1;
	Death:
		TRIT G 12 A_ScreamAndUnblock;
		TRIT HIJ 10;
		TRIT H 0 A_BossDeath;
		MISL BCD 10;
		TNT1 A -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The white boss's egg sac -- a minion, so no tier token.
// CH: Spiders.txt:4002.
// ---------------------------------------------------------------------------
class RS_WhiteSpidegg : Actor   // CH Spiders.txt:4002
{
	Default
	{
		Health 50;
		Radius 20;
		Height 32;
		Species "WhiteSP";
		Monster;
		+NOPAIN
		+NOTARGET
		+FLOAT
		+FLOATBOB
		+NOGRAVITY
		+LOOKALLAROUND
		Speed 7;
		DropItem "RS_HealthBundle";
		DropItem "RS_ImplyingClip", 128, 3;
		DropItem "RS_CH_Shell", 72, 2;
		DropItem "RS_CH_Cell", 32, 2;
		Alpha 0.95;
		Scale 2;
		DeathSound "weapons/rocklx";
		Translation "168:191=80:95","208:223=80:95","224:231=4:4","232:235=94:94";
	}
	States
	{
	Spawn:
		BAL1 AB 4 A_Look;
		Loop;
	See:
		BAL1 A 16;
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 ABABABABABABABABABABABABABABABABABABABABABA 1 A_Wander;
		TNT1 A 0 A_FaceTarget;
		TNT1 AAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(12,64),random(-28,28),random(1,8));
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 ABABABABABABABABABABABABABABABABABABABABABA 1 A_Wander;
		TNT1 A 0 A_FaceTarget;
		TNT1 AAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(12,64),random(-28,28),random(1,8));
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 ABABABABABABABABABABABABABABABABABABABABABA 1 A_Wander;
		TNT1 A 0 A_FaceTarget;
		TNT1 AAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(12,82),random(-28,28),random(1,8));
		BAL1 A 12 A_SetScale(2,1.5);
		BAL1 B 12 A_SetScale(1.5,2);
		BAL1 ABABABABABABABABABABABABABABABABABABABABABA 1 A_Wander;
		TNT1 A 0 A_FaceTarget;
		TNT1 AAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(12,82),random(-28,28),random(1,8));
		BAL1 A 12 A_SetScale(2,1.5);
		Goto Death;
	Death:
		TNT1 A 0 A_ScreamAndUnblock;
		MISL B 4 Bright;
		MISL C 4 Bright A_Explode(random(10,80),64,0);
		MISL D 4 Bright;
		TNT1 AAAAAAAAA 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_WhiteSPWebWeb",random(-64,64),random(-64,64),random(-8,26));
		TNT1 A 1 A_Die();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- the older white boss CH keeps alongside the current one.
// Unreferenced by any spawner in CH (the gate points at WhiteSP11); imported
// whole so nothing is silently dropped.  CH: Spiders.txt:4159.
// ---------------------------------------------------------------------------
class RS_WhiteSP11Old : Actor   // CH Spiders.txt:4159
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		BloodColor "White";
		Health 4000;
		Radius 64;
		Height 64;
		Mass 700;
		Speed 25;
		PainChance 128;
		Scale 1.5;
		Species "WhiteSP";
		DamageFactor "fire", 1.2;
		DamageFactor "ice", 0.5;   // CH lists ice twice, both 0.5
		DamageFactor "Plasma", 0.85;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+BOSS
		-NORADIUSDMG
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+DONTMORPH
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOFEAR
		+NOICEDEATH
		SeeSound "kawai/sight";
		PainSound "kawai/pain";   // CH: SNDINFO has Kawai/hurt, never Kawai/pain -- silent in CH too
		DeathSound "kawai/death";
		ActiveSound "kawai/active";
		Obituary "%o was eliminated by the white spider of terror";
		DropItem "RS_CH_SoulSphere";
		DropItem "Backpack";
		DropItem "Backpack";
		Translation "0:249=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","128:143=80:95","144:151=87:95","13:15=93:95","96:111=80:95","236:239=95:95","152:159=80:89","5:12=85:95","0:2=92:95","168:191=0:2","192:207=0:0","32:47=0:0";
		Tag "White Spider";
	}
	States
	{
	Spawn:
		TRIT A 0;
		Goto Scripted;
	Scripted:
		TRIT A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSpider") -- announcers dropped per owner
		Goto Idle;
	Idle:
		TRIT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TRIT A 20;
		TRIT ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT DDEE 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT A 0 A_Jump(256,"Atk1","Atk2","Atk3");
		Goto See;
	Atk1:
		TRIT A 2 Bright A_FaceTarget;
		TRIT E 4 Bright A_PainAttack("RS_MiniSP1");
		TRIT F 2 Bright A_DualPainAttack("RS_MiniSP1");
		Goto See;
	Atk2:
		TRIT A 8 Bright;
		TRIT E 1 Bright A_FaceTarget;
		TRIT E 2 Bright A_CustomBulletAttack(0,0,1,random(3,9),"RS_SPWht");
		TRIT F 1 Bright A_FaceTarget;
		TRIT F 2 Bright A_CustomBulletAttack(0,0,1,random(3,9),"RS_SPWht");
		Goto See;
	Atk3:
		TRIT A 8 Bright A_FaceTarget;
		TRIT E 1 Bright A_FaceTarget;
		TRIT E 5 Bright A_CustomMissile("RS_SPWHI2",42,0,random(-1,1));
		TRIT E 0 A_CustomMissile("RS_SPWHI2",42,0,random(3,12));
		TRIT E 0 A_CustomMissile("RS_SPWHI2",42,0,random(-12,-3));
		TRIT F 1 Bright A_FaceTarget;
		TRIT F 5 Bright A_CustomMissile("RS_SPWHI2",42,0,random(-7,7));
		TRIT F 3 Bright A_CustomMissile("RS_SPWHI2",42,0,random(-17,17));
		TRIT F 1 Bright A_CustomMissile("RS_SPWHI2",42,0,random(-12,12));
		Goto See;
	Pain:
		TRIT F 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT F 3 A_Pain;
		TRIT FFF 1 A_SpawnItemEx("RS_MiniSP1",random(-128,128),random(-128,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64));
		TRIT F 0;
		Goto See+1;
	Death:
		TRIT G 12 A_ScreamAndUnblock;
		TRIT HIJ 10;
		TRIT H 0 A_BossDeath;
		MISL BCD 10 A_Explode(50,128);
		MISL D 0 A_SpawnItemEx("RS_WhiteSP2",random(0,128),random(0,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64),SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_WhiteSP2",random(-128,0),random(-128,0),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White Spider "and half".  CH: Spiders.txt:4335.
// ---------------------------------------------------------------------------
class RS_WhiteSP2 : Actor   // CH Spiders.txt:4335
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		BloodColor "White";
		Health 1250;
		Radius 64;
		Height 64;
		Mass 700;
		Speed 25;
		PainChance 128;
		Scale 1;
		Species "WhiteSP";
		DamageFactor "fire", 0.2;
		DamageFactor "Plasma", 0.85;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+BOSS
		-NORADIUSDMG
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOICEDEATH
		+NOFEAR
		SeeSound "kawai/sight";
		PainSound "kawai/pain";   // CH: SNDINFO has Kawai/hurt, never Kawai/pain -- silent in CH too
		DeathSound "kawai/death";
		ActiveSound "kawai/active";
		Obituary "%o was eliminated by the white spider of terror and half";
		DropItem "Backpack";
		DropItem "Backpack", 128;
		DropItem "SoulSphere", 128;
		Translation "0:249=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","128:143=80:95","144:151=87:95","13:15=93:95","96:111=80:95","236:239=95:95","152:159=80:89","5:12=85:95","0:2=92:95","168:191=0:2","192:207=0:0","32:47=0:0";
		Tag "White Spider";
	}
	States
	{
	Spawn:
		TRIT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TRIT A 20;
		TRIT ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT DDEE 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT A 0 A_Jump(256,"Atk1","Atk3");
		Goto See;
	Atk1:
		TRIT A 6 Bright A_FaceTarget;
		TRIT E 8 Bright A_PainAttack("RS_MiniSP1");
		TRIT F 4 Bright A_DualPainAttack("RS_MiniSP1");
		Goto See;
	Atk3:
		TRIT A 8 Bright A_FaceTarget;
		TRIT E 5 Bright A_FaceTarget;
		TRIT F 5 Bright A_CustomMissile("RS_SPWHI3",42,0,random(-1,1));
		TRIT F 0 A_CustomMissile("RS_SPWHI3",42,0,random(8,24));
		TRIT F 0 A_CustomMissile("RS_SPWHI3",42,0,random(-24,-8));
		Goto See;
	Pain:
		TRIT F 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT F 3 A_Pain;
		TRIT FF 1 A_SpawnItemEx("RS_MiniSP1",random(-128,128),random(-128,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64));
		Goto See+1;
	Death:
		TRIT G 12 A_ScreamAndUnblock;
		TRIT HIJ 12;
		MISL BCD 10 A_Explode(30,88);
		MISL D 0 A_SpawnItemEx("RS_WhiteSP3",random(0,128),random(0,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64),SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_WhiteSP3",random(-128,0),random(-128,0),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White Spider "and 1/4".  CH: Spiders.txt:4264.
// ---------------------------------------------------------------------------
class RS_WhiteSP3 : Actor   // CH Spiders.txt:4264
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		BloodColor "White";
		Health 500;
		Radius 42;
		Height 42;
		Mass 700;
		Speed 25;
		PainChance 128;
		Scale 0.60;
		Species "WhiteSP";
		DamageFactor "fire", 0.2;
		DamageFactor "Plasma", 0.85;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOICEDEATH
		+NOFEAR
		SeeSound "kawai/sight";
		PainSound "kawai/pain";   // CH: SNDINFO has Kawai/hurt, never Kawai/pain -- silent in CH too
		DeathSound "kawai/death";
		ActiveSound "kawai/active";
		Obituary "%o was eliminated by the white spider of terror and 1/4";
		DropItem "Backpack";
		DropItem "Backpack";
		DropItem "Backpack", 128;
		DropItem "RS_CH_SoulSphere", 64;
		Translation "0:249=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","128:143=80:95","144:151=87:95","13:15=93:95","96:111=80:95","236:239=95:95","152:159=80:89","5:12=85:95","0:2=92:95","168:191=0:2","192:207=0:0","32:47=0:0";
		Tag "White Spider";
	}
	States
	{
	Spawn:
		TRIT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TRIT A 20;
		TRIT ABBC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT DDEE 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+1;
	Missile:
		TRIT A 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT E 8 Bright A_PainAttack("RS_MiniSP1");
		TRIT F 4 Bright A_DualPainAttack("RS_MiniSP1");
		Goto See;
	Pain:
		TRIT F 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT F 3 A_Pain;
		TRIT F 1 A_SpawnItemEx("RS_MiniSP1",random(-128,128),random(-128,128),random(8,56),random(0,3),random(0,3),random(0,3),random(0,64));
		Goto See+1;
	Death:
		TRIT G 12 A_ScreamAndUnblock;
		TRIT HIJ 12;
		MISL BCD 10 A_Explode(30,88);
		MISL D 0 A_Burst("RS_MiniSP1");
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The white boss's tiny spiders -- minions, so no tier token.
// CH: Spiders.txt:4499.
// ---------------------------------------------------------------------------
class RS_MiniSP1 : Actor   // CH Spiders.txt:4499
{
	Default
	{
		BloodColor "White";
		Species "WhiteSP";
		Health 15;
		Radius 16;
		Height 32;
		Mass 100;
		Speed 28;
		PainChance 128;
		Scale 0.20;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		SeeSound "kawai/sight";
		PainSound "kawai/pain";   // CH: SNDINFO has Kawai/hurt, never Kawai/pain -- silent in CH too
		DeathSound "kawai/death";
		ActiveSound "kawai/active";
		HitObituary "%o was eaten by tiny spider";
		DropItem "HealthBonus", 64;
		DropItem "RS_ImplyingClip", 54;
		DropItem "RS_CH_Shell", 42;
		DropItem "RS_CH_RocketAmmo", 32;
		DropItem "RS_CH_Cell", 12;
		Translation "0:249=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","128:143=80:95","144:151=87:95","13:15=93:95","96:111=80:95","236:239=95:95","152:159=80:89","5:12=85:95","0:2=92:95","168:191=0:2","192:207=0:0","32:47=0:0";
		Tag "Tiny White Spider";
	}
	States
	{
	Spawn:
		TRIT AB 10 A_Look;
		Loop;
	See:
		TRIT A 20;
		TRIT ABBCC 3 A_Chase("Melee",null,CHF_STOPIFBLOCKED);   // CH: A_Chase("Melee","",CHF_STOPIFBLOCKED)
		TRIT E 0 { bNOCLIP = false; }   // CH: a_changeflag(noclip,false)
		TRIT A 0 A_CheckBlock("IStuck",CBF_DROPOFF);
		TRIT DDEE 3 A_Chase("Melee",null,CHF_STOPIFBLOCKED);
		TRIT A 0 A_CheckBlock("IStuck",CBF_DROPOFF);
		Goto See+1;
	IStuck:
		TRIT A 1;
		TRIT A 1 { bNOCLIP = true; }   // CH: a_changeflag(noclip,true)
		TRIT ABC 1 A_Wander;
		Goto See+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssSP2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		Stop;   // CH ends this one without A_die, unlike every other Pain.AbyssPE
	Melee:
		TRIT E 4 Bright A_FaceTarget;
		TRIT F 2 Bright A_CustomMeleeAttack(random(3,12),"bite/bite4","None");
		Goto See;
	Pain:
		TRIT F 3;
		TRIT F 3 A_Pain;
		Goto See+1;
	Death:
		TRIT J 20 A_ScreamAndUnblock;
		MISL BCD 10 A_Explode(random(1,9),32);
		Stop;
	}
}
