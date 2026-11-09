// ============================================================================
// RS_Fatso.zs -- Colourful Hell FATSOS (Mancubus) family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Fatsos.txt (4,075 lines,
// 87 actors, read whole). Every actor cites its CH line. Support:
// RS_FatsoFX.zs (see its header for the already-owned list, the two classes
// ceded to the Revenants lane, proven-missing assets, and standing strips).
//
// Tier ladder is CH's icon index, as for every earlier family: 1 Common,
// 2 Green, 3 Blue, 4 Purple, 5 Yellow (Orange Mancubus), 6 Red (Horned),
// 7 FireBlu, 8 Gray, 9 Abyss (Ralph Bluetawn), 10 Black (both the swamp
// thing and the EX bog thing), 11 White (Angry Mama), 12 Cyan (Crystal),
// 13 Brown. The FatsoArmed props, projectiles and summons get no token.
//
// Gate cvars are the existing rs_ch_* set -- brown, cyan, abyss, fireblu,
// gray, blackboss, exboss, whiteboss, cyanbounce. No new cvar is needed.
//
// ACS announcers AnnounceBlackFatso (Fatsos.txt:2627,2867) and
// AnnounceWhiteFatso (:3534) are stripped per the standing order, each kept
// as a "// CH:" comment at its site. The CHRandom_GibGenerator gore chain is
// stripped the same way; the XDeath ANIMATIONS stay. DRLA drops
// (RareArmorPool, RLUniqueWeaponSpawner, RLDemonicWeaponSpawner,
// RLLegendaryWeaponSpawner) are stripped and itemised at their sites.
//
// NOTE ON STATE OFFSETS: CH jumps by offset in eight places
// (Missile+10/+12, missile+2, missile+3, Missile+2, Choice1+3, Death+1).
// Every state line here is frame-for-frame identical to CH so those offsets
// still land where CH meant them to. Do not collapse or add frames.
//
// RESOLVED 2026-08-06 -- HSBT frame A -> HBST frame A, four sites:
// RS_FireBluFatso2 Spawn/See and RS_RedFatso Spawn/See (CH Fatsos.txt:795,
// 804, 2280, 2290). HSBT is a two-character transposition of HBST; no HSBT*
// lump exists in sprites/, in Desktop\CH\sprites or in ART SOURCE, while
// HBST frame A ships with all eight rotations (HBSTA1, HBSTA2A8, HBSTA3A7,
// HBSTA4A6, HBSTA5). Behaviour is untouched -- every one of the four is a
// 0-tic state (never renders) sitting immediately after a "Loop;", so it is
// unreachable dead code here exactly as in CH. No line was added or removed,
// so the state offsets above still land. See RS_FatsoFX.zs's header for the
// rest of the proven-missing register.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Fatsos.txt:1 -- Colourset10 replaces Fatso.
// ---------------------------------------------------------------------------
class RS_Colourset10 : RandomSpawner replaces Fatso
{
	Default
	{
		DropItem "RS_CommonFatso", 255, 400;
		DropItem "RS_GreenFatso", 255, 220;
		DropItem "RS_CyanFatso", 255, 90;
		DropItem "RS_BlueFatso", 255, 130;
		DropItem "RS_PurpleFatso", 255, 50;
		DropItem "RS_GrayFatso", 255, 33;
		DropItem "RS_BrownFatso", 255, 60;
		DropItem "RS_FireBluFatso", 255, 20;
		DropItem "RS_AbyssFatso", 255, 35;
		DropItem "RS_YellowFatso", 255, 30;
		DropItem "RS_RedFatso", 255, 15;
		DropItem "RS_BlackFatso", 255, 4;
		DropItem "RS_WhiteFatso", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  CH's CallACS reads become RS_Zom.CV with CH's exact
// value semantics: 1 = colour off (reroll on the dial), 3 = fifty-fifty.
// ---------------------------------------------------------------------------
class RS_BrownFatso : Actor   // CH Fatsos.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_Jump(128,"Third");
	First:
		TNT1 A 0 A_SpawnItemEx("RS_Colourset10",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanFatso : Actor   // CH Fatsos.txt:299 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset10",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssFatso : Actor   // CH Fatsos.txt:524 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset10",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluFatso : Actor   // CH Fatsos.txt:727 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset10",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayFatso : Actor   // CH Fatsos.txt:965 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset10",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackFatso : Actor   // CH Fatsos.txt:2487 -- gates CH_BlackBossy, CH_ExBoss
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedFatso",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackFatsoEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackFatsoEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackFatsoEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteFatso : Actor   // CH Fatsos.txt:3442 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackFatso",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown ("What big hands you got").  CH: Fatsos.txt:40.
// The whole tesla kit runs on RS_ZapFFAT, which CH defines in Fatsos.txt:269
// but which ships via the Revenants lane (earlier CH file, and Revenants.txt
// spawns it too). Referenced read-only -- see the RS_FatsoFX.zs header.
// ---------------------------------------------------------------------------
class RS_BrownFatso2 : Fatso   // CH Fatsos.txt:40
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Species "Fatso";
		BloodColor "red";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 850;
		Radius 48;
		Height 64;
		Mass 9000;
		Speed 11;
		PainChance 70;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_GreenArmor", 84;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		Obituary "%o was brown noised by brown mancubi";
		Translation "48:79=64:79";
		Tag "What big hands you got";
	}
	States
	{
	Spawn:
		FFAT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FFAT AABBCC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT DDEEFF 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	CloseRaise:
		FFAT G 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT G 1 A_PlaySound("ELECFATT",0);
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,-21,random(-1,5));
		FFAT G 8 Bright A_CustomMissile("RS_ZapFFAT",18,21,random(-5,1));
		FFAT GGGGGGGGG 0 A_SpawnItemEx("RS_ZapFFAT",random(12,252),random(-12,12),random(24,42),3,0,random(-1,1));
		FFAT H 10 Bright A_VileTarget("RS_ZapFFAT2");
		FFAT H 3 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT H 1 A_PlaySound("ELECFATT",0);
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,-21,random(-1,5));
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,21,random(-5,1));
		FFAT GGGGGGGGG 0 A_SpawnItemEx("RS_ZapFFAT",random(12,252),random(-12,12),random(24,42),3,0,random(-1,1));
		FFAT H 10 Bright A_VileTarget("RS_ZapFFAT2");
		FFAT H 1 Bright A_CheckSight("See");
		TNT1 A 0 A_JumpIfCloser(300,"CloseRaise2");
		Goto Missile+10;
	CloseRaise2:
		FFAT I 1 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT I 10 Bright A_VileAttack("weapons/bfgx",random(32,99),random(2,60),32,5,"plasma");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT G 10;
		Goto Missile+12;
	Missile:
		FFAT G 10 A_FatRaise;
		TNT1 A 0 A_JumpIfCloser(300,"CloseRaise");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT G 1 A_PlaySound("ELECFATT",0);
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,-21,random(-1,5));
		FFAT G 8 Bright A_CustomMissile("RS_ZapFFAT",18,21,random(-5,1));
		FFAT G 1 A_PlaySound("ELECFATT",0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,-21,random(-1,5));
		FFAT G 8 Bright A_CustomMissile("RS_ZapFFAT",18,21,random(-5,1));
		FFAT G 1 A_PlaySound("ELECFATT",0);
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,-21,random(-1,5));
		FFAT G 8 Bright A_CustomMissile("RS_ZapFFAT",18,21,random(-5,1));
		FFAT G 1 A_PlaySound("ELECFATT",0);
		FFAT G 0 A_CustomMissile("RS_ZapFFAT",18,-21,random(-1,5));
		FFAT G 8 Bright A_CustomMissile("RS_ZapFFAT",18,21,random(-5,1));
		FFAT G 5 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("BASSFFAT",0);
		FFAT H 0 A_CustomMissile("RS_FatsoSoundWave",18,-21,random(-1,6));
		FFAT H 0 A_CustomMissile("RS_FatsoSoundWave",18,-21,random(-3,3));
		FFAT H 0 A_CustomMissile("RS_FatsoSoundWave",18,-21,random(-13,-6));
		FFAT H 0 A_CustomMissile("RS_FatsoSoundWave",18,-21,random(6,13));
		FFAT H 10 Bright A_CustomMissile("RS_FatsoSoundWave",18,21,random(-6,1));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT I 15;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		FFAT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FFAT J 3 A_Pain;
		Goto See;
	Death:
		FFAT K 6;
		FFAT L 6 A_Scream;
		FFAT M 6 A_NoBlocking;
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",0,0,18,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_USEBLOODCOLOR|SXF_NOCHECKPOSITION) -- gore chain not imported (owner: vanilla gore ok)
		TNT1 AAAAAA 0 A_SpawnParticle("yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FFAT NOPQRS 6;
		FFAT T 1 A_BossDeath;
		FFAT T -1;
		Stop;
	Raise:
		FAT2 H 0 A_RemoveChildren(true,RMVF_EVERYTHING);
		FAT2 HGFEDCBA 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan ("Crystal Fatso").  CH: Fatsos.txt:321.
// ---------------------------------------------------------------------------
class RS_CyanFatso2 : Fatso   // CH Fatsos.txt:321
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Species "Fatso";
		BloodColor "blue";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 720;
		DamageFactor "Melee", 1.5;
		DamageFactor "Fire", 1.25;
		DamageFactor "Ice", 0.1;
		PainChance "Ice", 0;
		PainChance "PLWater", 12;
		PainThreshold 32;
		DamageFactor "Falling", 0;   // CH lists Falling twice, both 0
		DamageFactor "PLWater", 0.25;
		Radius 48;
		Height 64;
		Mass 1000;
		Damage 5;
		Speed 11;
		PainChance 70;
		Monster;
		+LAXTELEFRAGDMG
		+FLOORCLIP
		+BOSSDEATH
		+NOICEDEATH
		+NOFEAR
		+MISSILEMORE
		+BRIGHT
		+DONTHARMSPECIES
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_GreenArmor", 64;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		Obituary "%o got crystalized by cyan mancubi";
		Translation "80:111=%[0.00,0.00,0.64]:[0.00,0.65,1.29]","0:79=%[0.00,0.00,1.01]:[0.00,2.00,2.00]","128:143=%[0.00,0.00,0.42]:[0.40,0.40,2.00]","144:255=%[0.00,0.00,0.42]:[0.00,1.29,1.29]","112:127=%[2.00,0.00,0.00]:[2.00,0.00,0.00]";
		Tag "Crystal Fatso";
	}
	States
	{
	Spawn:
		FATT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FATT AABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"Bon");
		TNT1 A 0 A_Jump(232,"SeeMe","See2");
		Loop;
	See2:
		FATT AABBCC 1 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 1 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	SeeMe:
		FATT A 0 A_JumpIfInTargetLOS("Jumpy",0,JLOSF_DEADNOJUMP,750);
		Goto See;
	Jumpy:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");
		FATT A 2;
		FATT A 1 ThrustThingZ(0,64,0,0);
		FATT A 3 ThrustThing(int(angle - randompick(90,130,180,230,270)),12,0,0);   // CH: thrustthing(angle-randompick(...),12,0,0)
		FATT A 1 ThrustThingZ(0,32,0,0);
		FATT A 1 ThrustThing(int(angle + frandom(120,240)),18,0,0);   // CH: thrustthing(angle+frandom(120,240),18,0,0)
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128,"Butt");
		FATT G 20 A_FatRaise;
		TNT1 A 0 A_Jump(102,"MissAlt");
		FATT H 0 A_CustomMissile("RS_CyanFatBall",18,-21,random(-1,1));
		FATT H 10 Bright A_CustomMissile("RS_CyanFatBall",18,21,random(-1,1));
		FATT H 0 A_CustomMissile("RS_CyanFatBall",18,-21,random(-3,3));
		FATT H 5 Bright A_CustomMissile("RS_CyanFatBall",18,21,random(-3,3));
		FATT IG 5 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		FATT H 0 A_CustomMissile("RS_CyanFatBall",18,-21,random(-3,3));
		FATT H 5 Bright A_CustomMissile("RS_CyanFatBall",18,21,random(-3,3));
		FATT H 0 A_CustomMissile("RS_CyanFatBall",18,-21,random(-5,5));
		FATT H 2 Bright A_CustomMissile("RS_CyanFatBall",18,21,random(-5,5));
		FATT I 15;
		Goto See;
	MissAlt:
		FATT G 5 A_FaceTarget;
		FATT H 0 A_CustomMissile("RS_CyanFatBall",18,21,random(1,11));
		FATT H 0 A_CustomMissile("RS_CyanFatBall",18,21,random(-1,1));
		FATT H 8 Bright A_CustomMissile("RS_CyanFatBall",18,21,random(-11,-1));
		FATT I 0 A_CustomMissile("RS_CyanFatBall",18,-21,random(-11,1));
		FATT I 0 A_CustomMissile("RS_CyanFatBall",18,-21,random(-1,1));
		FATT I 8 Bright A_CustomMissile("RS_CyanFatBall",18,-21,random(1,11));
		Goto See;
	Butt:
		TNT1 A 0 A_JumpIfCloser(500,"Butt2",true);
		Goto Missile+2;
	Butt2:
		FATT J 10 A_FaceTarget;
		FATT J 20 A_SkullAttack(50);
		FATT J 10 A_Stop;
		FATT J 0 A_SetSpeed(10);
		Goto Missile;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		FATT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 A_Pain;
		FATT J 1 A_Jump(64,"Bon");
		Goto See;
	Bon:
		FATT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 ThrustThingZ(0,72,0,0);
		FATT J 6 ThrustThing(int(angle - 180),18,0,0);   // CH: thrustthing(angle-180,18,0,0)
		Goto See;
	Death:
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking(false);
		FATT NOPQRS 6;
		FATT T 1 A_BossDeath;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,250);
		FATT T 1 A_IceGuyDie;
		FATT T -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss ("Ralph Bluetawn").  CH: Fatsos.txt:547.
// ---------------------------------------------------------------------------
class RS_AbyssFatso2 : Fatso   // CH Fatsos.txt:547
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Radius 48;
		Height 64;
		Health 2150;
		Mass 600;
		Speed 11;
		+FLOORCLIP
		+MISSILEMORE
		+NOINFIGHTING
		+DONTHARMCLASS
		+DONTHARMCLASS
		+NOFEAR
		SeeSound "shadowbeast/sight";
		DeathSound "shadowbeast/death";
		ActiveSound "demon/active";
		PainSound "demon/pain";
		PainChance 12;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Fire", 0.45;   // CH lists Fire twice, both 0.45
		DamageFactor "Ice", 0.25;    // CH lists ice twice, both 0.25
		Obituary "%o was pressured crushed by Abyss Mancubus";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 64;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketBox";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_BlueArmor", 64;
		DropItem "RS_CH_Berserk";
		DropItem "RS_HealthBundle";
		Tag "Ralph Bluetawn";
		Translation "0:255=%[0.00,0.00,0.18]:[0.22,0.50,0.44]";
	}
	States
	{
	Spawn:
		UNMB AABB 8 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		UNMB AA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		UNMB BB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		Loop;
	Missile:
		UNMB C 10 A_FatRaise;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		UNMB CD 5 A_FaceTarget;
		UNMB D 0 A_Jump(128,"Missile2");
		UNMB E 0 A_PlaySound("horn/attack",0);
		UNMB EEEE 7 Bright A_CustomMissile("RS_AbyssFatsoBomb",32,32,random(-17,4));
		UNMB D 10 A_FaceTarget;
		UNMB E 0 A_PlaySound("horn/attack",0);
		UNMB EEEE 7 Bright A_CustomMissile("RS_AbyssFatsoBomb",32,-32,random(-4,17));
		UNMB CD 5 A_FaceTarget;
		Goto See;
	Missile2:
		UNMB E 2 Bright A_PlaySound("spit/spit2");
		UNMB EE 0 A_CustomMissile("RS_FatAbysswave",random(16,42),32,random(-18,-10));
		UNMB EE 0 A_CustomMissile("RS_FatAbysswave",random(16,42),32,random(-12,-5));
		UNMB E 9 Bright A_CustomMissile("RS_FatAbysswave",random(16,42),32,random(-7,4));
		UNMB EE 0 A_CustomMissile("RS_FatAbysswave",random(16,42),32,random(10,18));
		UNMB EE 0 A_CustomMissile("RS_FatAbysswave",random(16,42),32,random(5,12));
		UNMB E 9 Bright A_CustomMissile("RS_FatAbysswave",random(16,42),-32,random(-4,7));
		UNMB CD 5 A_FaceTarget;
		Goto See;
	Pain:
		UNMB F 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		UNMB F 4 A_Pain;
		Goto Missile;
	Death:
		UNMB G 7 A_SetFloorClip;
		UNMB H 6 A_Scream;
		UNMB I 6 A_NoBlocking;
		UNMB JKLM 5 A_UnsetSolid;
		UNMB N -1 A_BossDeath;
		Stop;
	Raise:
		UNMB N 6 A_UnSetFloorClip;
		UNMB MLKJIHG 6 A_SetSolid;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu ("Big blob of fireblu").  CH: Fatsos.txt:746.
// ---------------------------------------------------------------------------
class RS_FireBluFatso2 : Actor   // CH Fatsos.txt:746
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Species "Fatso2";
		Health 1400;
		Radius 48;
		Height 64;
		Speed 7;
		YScale 1.2;
		XScale 1.5;
		PainChance 45;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 2000;   // CH sets Mass 1500 then Mass 2000; the later wins
		Monster;
		+FLOORCLIP
		+DONTSQUASH
		+DONTMORPH
		+DONTBLAST
		+DONTHARMCLASS
		+BOSSDEATH
		+NOICEDEATH
		+MISSILEMORE
		+NOFEAR
		DamageFactor "Fire", 0.25;   // CH lists Fire twice, both 0.25
		DamageFactor "Ice", 0.5;     // CH lists ice twice, both 0.5
		SeeSound "horn/sight";
		ActiveSound "demon/active";
		PainSound "demon/pain";
		DeathSound "horn/death";
		Translation "6:6=180:180","5:5=202:202","8:8=47:47","96:111=197:201","160:167=198:206","208:223=176:189","248:249=176:178";
		Obituary "%o was volcano bake meated by fireblu mancubi";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_Berserk";
		Tag "Big blob of fireblu";
	}
	States
	{
	Spawn:
		HBST A 0 A_Jump(81,3);
		HBST A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
		HBST A 0 A_CustomMissile("RS_HBeastSmoke",64,0,0);   // CH: HSBT A -- transposition of HBST; no HSBT* lump exists anywhere, and HBST A ships (HBSTA1/A2A8/A3A7/A4A6/A5). Behaviour identical: 0 tics never renders, and this line sits after the Loop above so it is unreachable here exactly as in CH. Corrected so no unresolvable sprite token remains. Fixed 2026-08-06 (owner: nothing invisible).
		Loop;
	See:
		HBST A 0 A_Jump(81,11);
		HBST AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
		HBST A 0 A_CustomMissile("RS_HBeastSmoke",64,0,0);   // CH: HSBT A -- transposition of HBST; 0-tic and unreachable (sits after the Loop above), same as in CH. Corrected so no unresolvable sprite token remains. Fixed 2026-08-06 (owner: nothing invisible).
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST E 0 A_JumpIfCloser(1800,"Fires");
		HBST E 10 A_FaceTarget;
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,20,random(-1,1));
		HBST E 3 A_CustomMissile("RS_FireBluFatsoBal1",32,-20,random(-1,1));
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,-20);
		HBST E 3 A_CustomMissile("RS_FireBluFatsoBal1",32,20);
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,20,random(-1,1));
		HBST E 3 A_CustomMissile("RS_FireBluFatsoBal1",32,-20,random(-1,1));
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,20);
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,-20);
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,20);
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal1",32,-20);
		HBST E 5 A_FaceTarget;
		Goto See;
	Fires:
		HBST E 12 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal2",32,20,0);
		HBST E 0 A_CustomMissile("RS_FireBluFatsoBal2",32,-20,0);
		HBST E 5 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		HBST F 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST F 5 A_Pain;
		Goto See;
	Pain.Ice:
	Pain.Fire:
		HBST A 5 A_PlaySound("ResistCH",7);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HBST G 8 A_Scream;
		HBST H 7 A_PlaySound("horn/shotx");
		HBST I 6 A_Fall;
		HBST JK 5;
		HBST LMNO 4;
		HBST P 1;
		HBST P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray ("Big Gray and Ugly").  CH: Fatsos.txt:984.
// ---------------------------------------------------------------------------
class RS_GrayFatso2 : Fatso   // CH Fatsos.txt:984
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Species "Fatso";
		BloodColor "White";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 1000;
		GibHealth 70;
		DamageFactor 0.65;   // CH: damagefactor 0.65 -- the unnamed all-types factor, same one-arg form the demon/revenant lanes use
		DamageFactor "Melee", 0.1;
		DamageFactor "PLWater", 1.5;
		Radius 48;
		Height 64;
		Mass 9000;
		Speed 5;
		PainChance 70;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_GreenArmor", 64;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		Obituary "%o was THWOMPED by gray mancubi";
		Translation "48:63=93:98","64:79=99:107","13:15=108:111","16:47=80:111","208:223=96:111","168:191=87:111","144:151=108:111","160:167=0:0","112:127=0:0","224:231=0:0","249:249=0:0","236:240=0:0";
		Tag "Big Gray and Ugly";
	}
	States
	{
	Spawn:
		FATT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FATT AABBCC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FATT G 20 A_FatRaise;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(92,"Miss2");
		FATT H 0 A_CustomMissile("RS_FatsoSpikes",18,-21,random(-1,5));
		FATT H 10 Bright A_CustomMissile("RS_FatsoSpikes",18,21,random(-5,1));
		FATT IG 15 A_FaceTarget;
		TNT1 A 0 A_CheckSight("See");
		FATT H 0 A_CustomMissile("RS_FatsoSpikes",18,-21,random(-1,1));
		FATT H 5 Bright A_CustomMissile("RS_FatsoSpikes",18,21,random(-1,1));
		FATT I 15;
		Goto See;
	Miss2:
		TNT1 A 0 A_JumpIfCloser(1200,"Missile2");
		Goto Missile+3;
	Missile2:
		FATT G 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT I 1 A_FaceTarget;
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHH 0 A_SpawnItemEx("RS_FatsoSpikes2",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT IG 15 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		FATT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 A_Pain;
		Goto See;
	Pain.Melee:
		FATT A 5 A_PlaySound("ResistCH",7);
		Goto See;
	Pain.PLWater:
		FATT J 2 A_Pain;
		// CH: TNT1 J 2 A_SpawnItemEx("CHRandom_GibGenerator",0,0,18,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_USEBLOODCOLOR|SXF_NOCHECKPOSITION) -- gore chain not imported. (That line also carried CH's TNT1 frame-J typo; TNT1 has frame A only.)
		FATT J 2 A_Pain;
		FATT J 5 A_Pain;
		FATT J 5;
		Goto See;
	Death:
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking;
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FATT NOPQRS 6;
		FATT T 1 A_BossDeath;
		FATT T -1;
		Stop;
	Raise:
		FAT2 H 0 A_RemoveChildren(true,RMVF_EVERYTHING);
		FAT2 HGFEDCBA 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common ("Mancubus").  CH: Fatsos.txt:1175.
// ---------------------------------------------------------------------------
class RS_CommonFatso : Fatso   // CH Fatsos.txt:1175
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "Fatso";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		GibHealth 70;
		Monster;
		+DONTHARMSPECIES
		Tag "Mancubus";
	}
	States
	{
	Spawn:
		FATT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FATT AABBCC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FATT G 20 A_FatRaise;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT H 10 Bright A_FatAttack1;
		FATT IG 5 A_FaceTarget;
		FATT H 10 Bright A_FatAttack2;
		FATT IG 5 A_FaceTarget;
		FATT H 10 Bright A_FatAttack3;
		FATT IG 5 A_FaceTarget;
		Goto See;
	Pain:
		FATT J 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		FAT2 A 5;
		FAT2 B 5 A_Scream;
		FAT2 C 5 A_NoBlocking;
		FAT2 DE 5;
		FAT2 F 5 A_SpawnItemEx("RS_FatsoArmed",0,0,3,0,0,0,0,SXF_SETMASTER);
		FAT2 G 5 A_BossDeath;
		FAT2 H -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking;
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (XDeath animation kept)
		TNT1 AAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FATT NOPQRS 6;
		FATT T 1 A_BossDeath;
		FATT T -1;
		Stop;
	Raise:
		FAT2 H 0 A_RemoveChildren(true,RMVF_EVERYTHING);
		FAT2 H 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		FAT2 GFEDCBA 5;
		Goto See;
	Grow:
		FAT2 GFEDCBA 5;
		FAT2 A 0 A_SpawnItemEx("RS_GreenFatso",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green ("Green Mancubus").  CH: Fatsos.txt:1309.
// ---------------------------------------------------------------------------
class RS_GreenFatso : Fatso   // CH Fatsos.txt:1309
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Species "Fatso";
		BloodColor "Green";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 750;
		GibHealth 70;
		Radius 48;
		Height 64;
		Mass 1200;
		Speed 8;
		PainChance 70;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		DropItem "RS_ArmorBundle", 42;
		Obituary "its no boomer even tho its green";
		Translation "48:63=112:112","64:79=112:127","13:15=125:127","236:239=125:127","175:191=112:124";
		Tag "Green Mancubus";
	}
	States
	{
	Spawn:
		FATT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FATT AABBCC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FATT G 20 A_FatRaise;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT H 10 Bright A_CustomMissile("RS_GreenBomb1",20,13,random(-5,6));
		FATT H 0 A_CustomMissile("RS_GreenBomb1",20,-13,random(-6,5));
		FATT IG 5 A_FaceTarget;
		FATT H 10 Bright A_CustomMissile("RS_GreenBomb1",20,13,random(-7,5));
		FATT H 0 A_CustomMissile("RS_GreenBomb1",20,-13,random(-5,7));
		FATT IG 5 A_FaceTarget;
		FATT H 10 Bright A_CustomMissile("RS_GreenBomb1",20,13,random(-8,5));
		FATT H 0 A_CustomMissile("RS_GreenBomb1",20,-13,random(-5,8));
		FATT IG 5;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		FATT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		FAT2 A 5;
		FAT2 B 5 A_Scream;
		FAT2 C 5 A_NoBlocking;
		FAT2 DE 5;
		FAT2 F 5 A_SpawnItemEx("RS_FatsoArmed2",0,0,3,0,0,0,0,SXF_SETMASTER);
		FAT2 G 5 A_BossDeath;
		FAT2 H -1;
		Stop;
	XDeath:
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking;
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (XDeath animation kept)
		TNT1 AAAAAA 0 A_SpawnParticle("green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FATT NOPQRS 6;
		FATT T 1 A_BossDeath;
		FATT T -1;
		Stop;
	Raise:
		FAT2 H 0 A_RemoveChildren(true,RMVF_EVERYTHING);
		FAT2 H 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		FAT2 GFEDCBA 5;
		Goto See;
	Grow:
		FAT2 GFEDCBA 5;
		FAT2 A 0 A_SpawnItemEx("RS_BlueFatso",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue ("Blue Mancubus").  CH: Fatsos.txt:1465.
// Its whole kit -- RS_BlueFT, RS_BlueFT2, RS_Bluewave1 -- shipped with the
// lostsoul family and is referenced read-only.
// ---------------------------------------------------------------------------
class RS_BlueFatso : Fatso   // CH Fatsos.txt:1465
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Species "Fatso";
		BloodColor "Blue";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 850;
		GibHealth 70;
		Radius 48;
		Height 64;
		Mass 1300;
		Speed 7;
		PainChance 60;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		Obituary "%o found the blue fat thing";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_CH_Cell", 128;
		DropItem "RS_ArmorBundle", 72;
		DropItem "RS_HealthBundle", 128;
		Translation "64:79=[49,73,240]:[4,1,61]","205:207=255:255","144:151=243:247","13:15=244:247","236:239=244:247","112:127=[242,238,164]:[109,84,31]","48:63=[159,159,251]:[75,80,241]","175:191=194:207";
		Tag "Blue Mancubus";
	}
	States
	{
	Spawn:
		FATT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FATT AABBCC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FATT G 17 A_FatRaise;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT G 0 A_Jump(256,"Waves","Beam");
	Waves:
		FATT H 8 Bright A_CustomMissile("RS_Bluewave1",20,21,random(-6,1));
		FATT H 0 A_CustomMissile("RS_Bluewave1",20,-21,random(-1,6));
		FATT IG 7;
		FATT H 8 Bright A_CustomMissile("RS_Bluewave1",20,21,random(-1,6));
		FATT H 0 A_CustomMissile("RS_Bluewave1",20,-21,random(-6,1));
		FATT IG 7;
		FATT H 8 Bright A_CustomMissile("RS_Bluewave1",20,21,random(-5,5));
		FATT H 0 A_CustomMissile("RS_Bluewave1",20,-21,random(-8,8));
		FATT IG 7;
		Goto See;
	Beam:
		FATT H 0 A_CustomMissile("RS_BlueFT",12,0);
		FATT H 16 Bright A_FaceTarget;
		FATT I 7 Bright A_FaceTarget;
		FATT G 8 Bright A_CustomMissile("RS_BlueFT2",20,0);
		FATT H 5 Bright A_CustomMissile("RS_BlueFT2",20,0,random(-4,4));
		FATT I 4 Bright A_CustomMissile("RS_BlueFT2",20,0,random(-9,9));
		FATT H 3 Bright A_CustomMissile("RS_BlueFT2",20,0,random(-16,16));
		FATT H 2 Bright A_Jump(128,"Beam","Missile");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		FATT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		FAT2 A 5;
		FAT2 B 5 A_Scream;
		FAT2 C 5 A_NoBlocking;
		FAT2 DE 5;
		FAT2 F 5 A_SpawnItemEx("RS_FatsoArmed3",0,0,3,0,0,0,0,SXF_SETMASTER);
		FAT2 G 5 A_BossDeath;
		FAT2 H -1;
		Stop;
	XDeath:
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking;
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (XDeath animation kept)
		TNT1 AAAAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FATT NOPQRS 6;
		FATT T 1 A_BossDeath;
		FATT T -1;
		Stop;
	Raise:
		FAT2 H 0 A_RemoveChildren(true,RMVF_EVERYTHING);
		FAT2 H 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		FAT2 GFEDCBA 5;
		Goto See;
	Grow:
		FAT2 GFEDCBA 5;
		FAT2 A 0 A_SpawnItemEx("RS_PurpleFatso",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple ("Purple Mancubus").  CH: Fatsos.txt:1764.
// Swoosh's puff RS_FatsoPuff3 (CH Fatsos.txt:1880) ships via the Revenants
// lane and is referenced read-only.
// ---------------------------------------------------------------------------
class RS_PurpleFatso : Fatso   // CH Fatsos.txt:1764
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Species "Fatso";
		BloodColor "Purple";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 950;
		GibHealth 70;
		Radius 48;
		Height 64;
		Mass 1500;
		Speed 6;
		PainChance 20;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOFEAR
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_ArmorBundle", 128;
		Obituary "%o met the big purple and heavy";
		Translation "64:79=[241,48,241]:[54,7,53]","48:63=[242,157,244]:[228,88,218]","174:191=250:254";
		Tag "Purple Mancubus";
	}
	States
	{
	Spawn:
		FATT AB 15 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FATT AABBCC 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT DDEEFF 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FATT G 17 A_FatRaise;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT G 0 A_JumpIfHigherOrLower("Swoosh",null,32,0,true);   // CH: A_JumpIfhigherorlower("Swoosh","",32,0,true)
		FATT G 0 A_JumpIfCloser(1550,"Boing1");
		FATT G 0 A_Jump(255,"Swoosh");
	Boing1:
		FATT H 11 Bright A_CustomMissile("RS_PurpleBomb1",20,13,random(-5,9));
		FATT H 0 A_CustomMissile("RS_PurpleBomb1",20,-13,random(-9,5));
		FATT IG 7 A_FaceTarget;
		FATT H 11 Bright A_CustomMissile("RS_PurpleBomb1",20,13,random(-9,5));
		FATT H 0 A_CustomMissile("RS_PurpleBomb1",20,-13,random(-5,9));
		FATT IG 7 A_FaceTarget;
		FATT H 11 Bright A_CustomMissile("RS_PurpleBomb1",20,13,random(-9,9));
		FATT H 0 A_CustomMissile("RS_PurpleBomb1",20,-13,random(-9,9));
		FATT IG 7;
		Goto See;
	Swoosh:
		FATT H 0 A_PlaySound("Ratata/rata1",0,1.9);
		FATT H 5 Bright A_CustomBulletAttack(15,1,random(1,8),random(1,3),"RS_FatsoPuff3",8000);   // RS_FatsoPuff3 ships via the Revenants lane (CH Fatsos.txt:1880)
		FATT IG 3 A_MonsterRefire(180,"See");
		Goto Missile+2;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		FATT J 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FATT J 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		FAT2 A 5;
		FAT2 B 5 A_Scream;
		FAT2 C 5 A_NoBlocking;
		FAT2 DE 5;
		FAT2 F 5 A_SpawnItemEx("RS_FatsoArmed4",0,0,3,0,0,0,0,SXF_SETMASTER);
		FAT2 G 5 A_BossDeath;
		FAT2 H -1;
		Stop;
	XDeath:
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking;
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (XDeath animation kept)
		TNT1 AAAAAA 0 A_SpawnParticle("purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		FATT NOPQRS 6;
		FATT T 1 A_BossDeath;
		FATT T -1;
		Stop;
	Raise:
		FAT2 H 0 A_RemoveChildren(true,RMVF_EVERYTHING);
		FATT RQPONMLK 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 5 -- Yellow ("Orange Mancubus").  CH: Fatsos.txt:2007.
// Its kit -- RS_RocketShotFatso, RS_FatsoShotYE -- shipped with the lostsoul
// family and is referenced read-only.
// ---------------------------------------------------------------------------
class RS_YellowFatso : Fatso   // CH Fatsos.txt:2007
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Species "Fatso2";
		BloodColor "Purple";
		Health 1250;
		Radius 48;
		Height 64;
		Speed 6;
		PainChance 14;
		ReactionTime 8;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 2000;   // CH sets Mass 1500 then Mass 2000; the later wins
		Monster;
		+FLOORCLIP
		+DONTSQUASH
		+DONTMORPH
		+DONTBLAST
		+NOTELEOTHER
		+DONTHARMCLASS
		+BOSSDEATH
		+NOFEAR
		SeeSound "incubus/sight";
		PainSound "incubus/pain";
		DeathSound "incubus/death";
		ActiveSound "incubus/active";
		Obituary "%o was annihilated by Yellow MANcubi";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_ArmorBundle";
		DropItem "BackPack", 128;
		Translation "64:71=213:220","72:79=184:191","236:239=43:47","184:191=251:254";
		Tag "Orange Mancubus";
	}
	States
	{
	Spawn:
		INCB AD 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		INCB AAABBB 4 A_Chase;
		INCB A 0 A_PlaySound("incubus/walk");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INCB CCCDDD 4 A_Chase;
		INCB C 0 A_PlaySound("incubus/walk");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INCB E 0 A_JumpIfCloser(1750,"Choice");
		INCB E 0 A_Jump(255,"Alternative");
	Choice:
		INCB E 0 A_Jump(255,"Rocketo","Alternative");
	Rocketo:
		INCB E 0 A_PlaySound("incubus/attack1");
		INCB EEE 8 A_FaceTarget;
		INCB F 8 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-3,3),0);
		INCB G 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		INCB E 4 A_FaceTarget;
		INCB G 8 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-3,3),0);
		INCB F 2 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-6,6),0);
		INCB E 4 A_FaceTarget;
		INCB F 8 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-3,3),0);
		INCB G 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		INCB E 4 A_FaceTarget;
		INCB G 8 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-3,3),0);
		INCB F 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		INCB EE 8 A_FaceTarget;
		Goto See;
	Alternative:
		INCB E 0 A_PlaySound("incubus/attack2");
		INCB EEE 8 A_FaceTarget;
		INCB H 0 A_CustomMissile("RS_FatsoShotYE",72,-12,random(-3,3));
		INCB H 5 Bright A_CustomMissile("RS_FatsoShotYE",72,12,random(-3,3));
		INCB E 5 A_FaceTarget;
		INCB H 0 A_CustomMissile("RS_FatsoShotYE",72,-12,random(-3,3));
		INCB H 5 Bright A_CustomMissile("RS_FatsoShotYE",72,12,random(-3,3));
		INCB E 5 A_FaceTarget;
		INCB H 0 A_CustomMissile("RS_FatsoShotYE",72,-12,random(-3,3));
		INCB H 5 Bright A_CustomMissile("RS_FatsoShotYE",72,12,random(-3,3));
		INCB EE 8 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		INCB D 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INCB C 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		INCB I 12 A_Scream;
		INCB J 12;
		INCB K 8 A_Fall;
		INCB LM 8;
		INCB N -1 A_BossDeath;
		Stop;
	XDeath:
		INCB I 12 A_Scream;
		INCB J 12;
		INCB K 2 A_Fall;
		INCB LM 8;
		INCB N -1 A_BossDeath;
		Stop;
	Raise:
		INCB NMLKJI 10;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red ("Red Horned Mancubus").  CH: Fatsos.txt:2223.
// RS_Shot2Fatso shipped with the lostsoul family; referenced read-only.
// ---------------------------------------------------------------------------
class RS_RedFatso : Actor   // CH Fatsos.txt:2223
{
	int user_Rage5;   // CH: Var Int User_Rage5

	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Species "Fatso2";
		Health 1600;
		Radius 48;
		Height 64;
		Speed 8;
		Scale 1.4;
		PainChance 34;
		ReactionTime 8;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "PLWater", 2.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 2000;   // CH sets Mass 1500 then Mass 2000; the later wins
		Monster;
		+FLOORCLIP
		+DONTSQUASH
		+DONTMORPH
		+DONTBLAST
		+NOTELEOTHER
		+DONTHARMCLASS
		+BOSSDEATH
		+NOICEDEATH
		+MISSILEMORE
		+NOFEAR
		PainChance "PLWater", 172;
		PainChance "Fire", 1;
		DamageFactor "Fire", 0.25;   // CH lists Fire twice, both 0.25
		SeeSound "horn/sight";
		ActiveSound "demon/active";
		PainSound "demon/pain";
		DeathSound "horn/death";
		Translation "5:5=190:190","96:111=176:185","3:3=175:175","8:8=191:191";
		RenderStyle "SoulTrans";
		Alpha 0.85;
		Obituary "%o got charcoaled by Red Mancubi";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_Berserk", 128;
		Tag "Red Horned Mancubus";
	}
	States
	{
	Spawn:
		HBST A 0 A_Jump(81,2);
		HBST A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
		HBST A 0 A_CustomMissile("RS_HBeastSmoke",64,0,0);   // CH: HSBT A -- transposition of HBST; no HSBT* lump exists anywhere, and HBST A ships (HBSTA1/A2A8/A3A7/A4A6/A5). Behaviour identical: 0 tics never renders, and this line sits after the Loop above so it is unreachable here exactly as in CH. Corrected so no unresolvable sprite token remains. Fixed 2026-08-06 (owner: nothing invisible).
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HBST A 0 A_Jump(81,11);
		HBST AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
		HBST A 0 A_CustomMissile("RS_HBeastSmoke",64,0,0);   // CH: HSBT A -- transposition of HBST; 0-tic and unreachable (sits after the Loop above), same as in CH. Corrected so no unresolvable sprite token remains. Fixed 2026-08-06 (owner: nothing invisible).
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST E 0 A_JumpIfCloser(700,"Fires");
		HBST E 10 A_FaceTarget;
		HBST E 0 A_CustomMissile("RS_Shot2Fatso",32,20,random(-1,1));
		HBST E 0 A_CustomMissile("RS_Shot2Fatso",32,-20,random(-1,1));
		HBST E 5 A_FaceTarget;
		Goto See;
	Fires:
		HBST EEEEE 0 A_CustomMissile("RS_SparkPuff1",42,random(-12,12),CMF_AIMOFFSET,random(0,360),random(0,360));
		HBST E 12 A_FaceTarget;
		HBST E 0 A_CustomMissile("RS_HBeastShot",32,20,0);
		HBST E 0 A_CustomMissile("RS_HBeastShot",32,-20,0);
		HBST E 5 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssFatso2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HBST F 3 A_JumpIf(user_Rage5 >= 5,"Buffs");
		HBST F 3 A_Pain;
		HBST F 2 { user_Rage5 = user_Rage5 + 1; }   // CH: A_SetUserVar("User_Rage5",User_Rage5+1)
		Goto See;
	Pain.Fire:
		HBST A 5 A_PlaySound("ResistCH",7);
		Goto See;
	Buffs:
		HBST F 1 Bright A_PlaySound("Horn/Sight");
		HBST F 12 Bright { bNOPAIN = true; }             // CH: A_ChangeFlag("NOPAIN",TRUE)
		HBST F 12 Bright { bMISSILEEVENMORE = true; }    // CH: A_ChangeFlag("MISSILEEVENMORE",TRUE)
		HBST F 9 Bright A_SetSpeed(16);
		HBST F 5 { user_Rage5 = user_Rage5 - 50; }       // CH: A_SetUserVar("User_Rage5",User_Rage5-50)
		HBST A 1;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HBST G 8 A_Scream;
		HBST H 7 A_PlaySound("horn/shotx");
		HBST I 6 A_Fall;
		HBST JK 5;
		HBST LMNO 4;
		HBST P 1;
		HBST P -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black EX ("The thing from the bog").  CH: Fatsos.txt:2550.
// Black bosses take token 10, as in every earlier family.
// ---------------------------------------------------------------------------
class RS_BlackFatsoEX : Actor   // CH Fatsos.txt:2550
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was killed by the absolutely furious dark beast";
		BloodColor "70 AC 00";
		Health 18000;
		Radius 48;
		Height 64;
		Mass 1500;
		Speed 16;
		PainChance 32;
		RadiusDamageFactor 0.5;
		DamageFactor "Plasma", 0.80;   // CH lists Plasma twice, both 0.80
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 2.0;      // CH lists Fire twice, both 2.0
		DamageFactor "PlayerVoid", 0.6;
		PainChance "PLWater", 12;
		PainChance "Ice", 4;
		PainChance "Fire", 32;
		PainChance "Plasma", 12;
		PainChance "PlayerVoid", 4;
		PainChance "DIMp", 0;
		YScale 1.45;
		XScale 2.15;
		SeeSound "shadowbeast/sight";
		PainSound "shadowbeast/pain";
		DeathSound "shadowbeast/death";
		ActiveSound "shadowbeast/active";
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+BOSS
		+DONTMORPH
		-NORADIUSDMG
		+DONTHARMCLASS
		+QUICKTORETALIATE
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_PlasmaRifle", 128;
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
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
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_ShellBox", 174;
		DropItem "RS_CH_ShellBox", 88;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_BFG9000", 128;
		DropItem "RS_CH_BFG9000", 128;
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		Tag "The thing from the bog";
	}
	States
	{
	Spawn:
		BDEM A 0;
		Goto Scripted;
	Scripted:
		BDEM A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackFatso") -- announcers dropped per owner
		BDEM A 0 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		BDEM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BDEM A 0 A_SetTranslation("BBEASTEX1");
		BDEM A 3 A_Chase;
		BDEM B 0 A_SetTranslation("BBEASTEX2");
		BDEM B 3 A_Chase;
		BDEM C 0 A_SetTranslation("BBEASTEX3");
		BDEM C 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BDEM DD 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76),1,0,1,random(-359,359));
		BDEM D 0 A_SetTranslation("BBEASTEX4");
		BDEM D 3 A_Chase;
		BDEM E 0 A_SetTranslation("BBEASTEX5");
		BDEM E 3 A_Chase;
		BDEM F 0 A_SetTranslation("BBEASTEX6");
		BDEM F 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BDEM AA 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76),1,0,1,random(-359,359));
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(5500,"Phase2");
		TNT1 A 0 A_JumpIfCloser(500,"Breath");
		TNT1 A 0 A_JumpIfCloser(2000,"Choose");
		TNT1 A 0 A_Jump(256,"BiggerBomb");
		Goto See;
	Choose:
		TNT1 A 0 A_Jump(256,"BigBombs","Weave1","Weave2");
		Goto See;
	Phase2:
		TNT1 A 0 A_SetSpeed(21);
		TNT1 A 0 A_JumpIfCloser(500,"Breath");
		TNT1 A 0 A_JumpIfCloser(2000,"Choose2");
		TNT1 A 0 A_Jump(256,"BiggerBomb");
		Goto See;
	LongRange:
		TNT1 A 0 A_JumpIfCloser(1000,"Missile");
		BDEM H 12 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 8 A_CustomMissile("RS_BlackFatShotLongRange",56,0,0);
		BDEM H 6 A_FaceTarget;
		BDEM II 3 A_CustomMissile("RS_BlackFatShotLongRange",56,0,randompick(-3,3,1,-1,0,-5,5));
		BDEM I 0 A_CheckSight("See");
		BDEM I 2 A_Jump(212,"LongRange");
		Goto See;
	Choose2:
		TNT1 A 0 A_Jump(256,"GroundSplashes","BiggerBomb","Weave1","Burp");
		Goto See;
	GroundSplashes:
		BDEM G 12 A_PlaySound("shadowbeast/sight");
		BDEM HH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM HI 6 A_FaceTarget;
		BDEM IIII 1 A_CustomMissile("RS_ShadowSplash",12,0,random(-60,60));
		BDEM A 6 A_Jump(88,"Weave1");
		Goto See;
	BiggerBomb:
		BDEM H 12 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 8 A_CustomMissile("RS_ShadowBombBigEX",56,0,0);
		BDEM I 0 A_CheckSight("See");
		BDEM I 2 A_Jump(174,"BigBombs");
	BigBombs:
		BDEM H 6 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,-8);
		BDEM I 6 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,8);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,0);
		BDEM H 1 A_CheckSight("See");
		BDEM H 8 A_FaceTarget;
		BDEM HH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(-14,-7));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(-14,-7));
		BDEM I 5 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(7,14));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(7,14));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(-26,26));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(-26,26));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex1",56,0,random(-26,26));
		Goto See;
	Weave1:
		BDEM H 4 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ballex2",56,0,-16);
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ballex2",56,0,-8);
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ballex2",56,0,0);
		BDEM II 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ballex2",56,0,8);
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ballex2",56,0,16);
		BDEM III 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ballex2",56,0,32);
		BDEM I 0 A_Jump(128,"Weave2");
		Goto See;
	Burp:
		BDEM GGG 4 A_Pain;
		BDEM H 12 A_FaceTarget;
		BDEM I 2 Bright;
		BDEM IIIIIIIII 3 Bright A_CustomMissile("RS_BlackFatsoBurp",56,0,random(-30,30));
		BDEM I 12;
		Goto See;
	Breath:
		BDEM H 6 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-12,12));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-12,12));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-15,15));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-25,25));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-15,15));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-12,12));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-12,12));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFireEX",56,0,random(-8,8));
		BDEM I 0 A_Jump(128,"Weave1");
		Goto See;
	Weave2:
		BDEM H 16 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-64);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,64);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-56);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,56);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-48);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,48);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-40);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,40);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-32);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,32);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-24);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,24);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-16);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,16);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,-8);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,8);
		BDEM I 6 A_CustomMissile("RS_ShadowBeast_Ballex3",56,0,0);
		BDEM I 0 A_Jump(64,"BigBombs");
		BDEM I 0 A_Jump(128,"Weave1");
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(16,"Weave2");
		BDEM GG 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM G 4 A_Pain;
		Goto See;
	Pain.Plasma:
		BDEM G 3 A_PlaySound("ResistCH",7);
		TNT1 A 0 A_Jump(32,"Weave2");
		BDEM G 1 A_Pain;
		Goto See;
	Pain.Fire:
		BDEM G 3 A_Pain;
		BDEM GGG 1 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM G 3 A_Pain;
		BDEM GGG 1 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		Goto See;
	Death:
		BDEM R 8;
		BDEM S 8 A_Scream;
		BDEM TUVWX 6;
		BDEM Y 6 A_NoBlocking;
		BDEM Z 1;
		BDEM Z -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black ("The thing from the swamp").  CH: Fatsos.txt:2805.
// ---------------------------------------------------------------------------
class RS_BlackFatso2 : Actor   // CH Fatsos.txt:2805
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was killed by the angry dark beast";
		BloodColor "70 AC 00";
		Health 9001;
		Radius 48;
		Height 64;
		Mass 1500;
		Speed 14;
		PainChance 24;
		RadiusDamageFactor 0.5;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 2.0;   // CH lists Fire twice, both 2.0
		PainChance "DIMp", 0;
		PainChance "PLWater", 12;
		PainChance "Ice", 4;
		PainChance "Fire", 32;
		PainChance "Plasma", 12;
		Scale 1.33;
		XScale 1.88;
		SeeSound "shadowbeast/sight";
		PainSound "shadowbeast/pain";
		DeathSound "shadowbeast/death";
		ActiveSound "shadowbeast/active";
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+BOSS
		+DONTMORPH
		-NORADIUSDMG
		+DONTHARMCLASS
		+QUICKTORETALIATE
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_PlasmaRifle", 128;
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_ShellBox", 174;
		DropItem "RS_CH_ShellBox", 88;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_BFG9000", 64;
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		Tag "The thing from the swamp";
	}
	States
	{
	Spawn:
		BDEM A 0;
		Goto Scripted;
	Scripted:
		BDEM A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackFatso") -- announcers dropped per owner
		Goto Idle;
	Idle:
		BDEM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BDEM ABC 4 A_Chase;
		BDEM DD 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BDEM DEF 4 A_Chase;
		BDEM AA 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(5500,"Phase2");
		TNT1 A 0 A_JumpIfCloser(500,"Breath");
		TNT1 A 0 A_Jump(256,"BigBombs","Weave1","Weave2","LongRange");
		Goto See;
	Phase2:
		TNT1 A 0 A_SetSpeed(21);
		TNT1 A 0 A_JumpIfCloser(500,"Breath");
		TNT1 A 0 A_Jump(256,"GroundSplashes","BiggerBomb","Weave1","LongRange");
		Goto See;
	LongRange:
		TNT1 A 0 A_JumpIfCloser(1000,"Missile");
		BDEM H 12 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 8 A_CustomMissile("RS_BlackFatShotLongRange",56,0,0);
		BDEM I 0 A_CheckSight("See");
		BDEM I 2 A_Jump(212,"LongRange");
		Goto See;
	GroundSplashes:
		BDEM G 12 A_PlaySound("shadowbeast/sight");
		BDEM HH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM HI 6 A_FaceTarget;
		BDEM IIII 1 A_CustomMissile("RS_ShadowSplash",12,0,random(-60,60));
		BDEM A 6 A_Jump(88,"Weave1");
		Goto See;
	BiggerBomb:
		BDEM H 12 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 8 A_CustomMissile("RS_ShadowBombBig",56,0,0);
		BDEM I 0 A_CheckSight("See");
		BDEM I 2 A_Jump(174,"BigBombs");
	BigBombs:
		BDEM H 6 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,-8);
		BDEM I 6 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,8);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,0);
		BDEM H 1 A_CheckSight("See");
		BDEM H 8 A_FaceTarget;
		BDEM HH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(-14,-7));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(-14,-7));
		BDEM I 5 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(7,14));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(7,14));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(-26,26));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(-26,26));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball1",56,0,random(-26,26));
		Goto See;
	Weave1:
		BDEM H 4 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ball2",56,0,-16);
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ball2",56,0,-8);
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ball2",56,0,0);
		BDEM II 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ball2",56,0,8);
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ball2",56,0,16);
		BDEM III 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_FaceTarget;
		BDEM I 4 A_CustomMissile("RS_ShadowBeast_Ball2",56,0,32);
		BDEM I 0 A_Jump(128,"Weave2");
		Goto See;
	Burp:
		BDEM GGG 4 A_Pain;
		BDEM H 10 A_FaceTarget;
		BDEM I 1 Bright;
		BDEM I 12 Bright;
	Breath:
		BDEM H 6 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 2 A_CustomMissile("RS_ShadowBeast_BallFire",56,0,random(-8,8));
		BDEM I 0 A_Jump(128,"Weave1");
		Goto See;
	Weave2:
		BDEM H 16 A_FaceTarget;
		BDEM HHH 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-64);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,64);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-56);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,56);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-48);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,48);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-40);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,40);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-32);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,32);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-24);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,24);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-16);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,16);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,-8);
		BDEM I 0 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,8);
		BDEM I 6 A_CustomMissile("RS_ShadowBeast_Ball3",56,0,0);
		BDEM I 0 A_Jump(64,"BigBombs");
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(16,"Weave2");
		BDEM GG 0 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM G 4 A_Pain;
		Goto See;
	Pain.Plasma:
		BDEM G 3 A_PlaySound("ResistCH",7);
		TNT1 A 0 A_Jump(32,"Weave2");
		BDEM G 1 A_Pain;
		Goto See;
	Pain.Fire:
		BDEM G 3 A_Pain;
		BDEM GGG 1 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		BDEM G 3 A_Pain;
		BDEM GGG 1 A_SpawnItemEx("RS_Splash11",random(-20,20),random(-20,20),random(5,76));
		Goto See;
	Death:
		BDEM R 8;
		BDEM S 8 A_Scream;
		BDEM TUVWX 6;
		BDEM Y 6 A_NoBlocking;
		BDEM Z 1;
		BDEM Z -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White ("Angry Mama").  CH: Fatsos.txt:3462.
// ---------------------------------------------------------------------------
class RS_WhiteFatso2 : Actor   // CH Fatsos.txt:3462
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 15000;
		Mass 9750;
		Radius 48;
		Height 64;
		YScale 1.05;
		XScale 1.25;
		RadiusDamageFactor 0.5;
		DamageFactor "Plasma", 0.60;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 64;
		PainChance "Ice", 4;
		PainChance "Fire", 6;
		PainChance "Plasma", 12;
		BloodColor "White";
		Speed 13;
		PainChance 32;
		Monster;
		+DONTMORPH
		+FLOORCLIP
		+MISSILEMORE
		+BOSS
		-NORADIUSDMG
		+DONTHARMCLASS
		+QUICKTORETALIATE
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
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
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_ShellBox";
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "RS_CH_BFG9000", 128;
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLLegendaryWeaponSpawner",6 -- DRLA stripped per owner 2026-08-05
		SeeSound "WFATAGRO";
		PainSound "WFATHURT";
		DeathSound "WFATDEAD";
		ActiveSound "WFATACTI";
		Obituary "%o got turned into yo mama joke by white mancubi.";
		Translation "48:63=[255,255,255]:[154,154,154]","64:79=[201,201,201]:[62,71,83]","13:15=[173,173,173]:[55,55,55]","0:2=[96,99,115]:[54,54,54]","5:8=[102,102,102]:[34,36,47]","208:223=201:206","32:47=240:246","168:191=240:246","84:84=0:0","232:235=240:242","164:167=242:246";
		Tag "Angry Mama";
	}
	States
	{
	Spawn:
		QUEE A 0;
		Goto Scripted;
	Scripted:
		QUEE A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteFatso") -- announcers dropped per owner
		Goto Idle;
	Idle:
		QUEE AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		QUEE AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QUEE CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(2000,"Choice1");
	QueenRail:
		QUEE E 3 A_FaceTarget;
		QUEE E 3 Bright A_PlaySound("WFATATTACK",7,2,false,ATTN_NONE);
		QUEE EFEFG 9 Bright;
		QUEE F 9 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("WFATCRIT",7,2,false,ATTN_NONE);
		QUEE G 3 Bright A_CustomRailgun(random(40,90),0,"white","white",RGF_NOPIERCING,1,0,"RS_WhiteFatRB",0,0,0,0,0.4,1.0,"RS_WhiteFatRB2",0);
		QUEE E 3 Bright;
		Goto See;
	RapidRail:
		QUEE E 3 A_FaceTarget;
		QUEE E 3 Bright A_PlaySound("WFATCRIT");
		QUEE EFEFG 3 Bright;
		QUEE EF 7 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("WFATATTACK");
		QUEE G 5 Bright A_CustomRailgun(random(20,40),0,"white","white",RGF_NOPIERCING,0,0,"RS_WhiteFatRB3",0,0,0,0,0.4,1.0,"RS_WhiteFatRB4",4);
		QUEE E 3 Bright;
		QUEE FF 7 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("WFATATTACK");
		QUEE G 5 Bright A_CustomRailgun(random(20,40),0,"white","white",RGF_NOPIERCING,0,0,"RS_WhiteFatRB3",0,0,0,0,0.4,1.0,"RS_WhiteFatRB4",4);
		QUEE E 3 Bright;
		QUEE EF 7 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("WFATCRIT");
		QUEE G 5 Bright A_CustomRailgun(random(20,40),0,"white","white",RGF_NOPIERCING,0,0,"RS_WhiteFatRB3",0,0,0,0,0.4,1.0,"RS_WhiteFatRB4",4);
		QUEE E 6 Bright;
		QUEE S 6;
		Goto See;
	Choice2:
		TNT1 A 0 A_Jump(255,"BallBarrage","GroundNuke","RapidRail","SpreadShot");
		Goto See;
	Choice1:
		TNT1 A 0 A_JumpIfCloser(300,"Zap");
		TNT1 A 0 A_JumpIfHealthLower(9000,"Choice2");
		TNT1 A 0 A_Jump(255,"BallBarrage","GroundNuke","SpreadShot");
		QUEE S 8 A_FaceTarget;
		Goto See;
	SpreadShot:
		QUEE S 6 A_FaceTarget;
		QUEE S 6 Bright;
		QUEE E 9 A_FaceTarget;
		QUEE F 6 A_PlaySound("WFATATTACK");
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatScatter",42,0,random(-28,28),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-10,10));
		QUEE G 9 Bright;
		QUEE S 9;
		Goto See;
	GroundNuke:
		QUEE E 3 A_FaceTarget;
		QUEE E 3 Bright A_PlaySound("WFATCRIT");
		QUEE EFEFG 2 Bright;
		QUEE S 9 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("WFATATTACK");
		QUEE SSSSSSSSSS 2 Bright A_SpawnItemEx("RS_WhiteFatNukeShow",random(-24,24),random(-24,24),64,0,0,12,0,SXF_NOCHECKPOSITION);
		QUEE SSSSSSSSSS 2 Bright A_SpawnItemEx("RS_WhiteFatMark",random(-1524,1524),random(-1524,1524),6,0,0,0,0,SXF_NOCHECKPOSITION);
		QUEE S 10;
		Goto See;
	BallBarrage:
		QUEE S 4 A_FaceTarget;
		QUEE S 4 Bright;
		QUEE E 6 A_FaceTarget;
		QUEE F 3 A_PlaySound("WFATATTACK");
		QUEE G 1 A_Jump(256,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 6;
		Goto See;
	A1:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall1",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	A2:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall2",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	A3:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall3",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	A4:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall4",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	A5:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall5",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	A6:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall6",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	A7:
		QUEE G 1;
		QUEE G 1 A_FaceTarget;
		QUEE G 3 Bright A_CustomMissile("RS_WhiteFatBall7",46,0,random(-5,5));
		QUEE G 1 A_CheckSight("See");
		QUEE G 1 A_Jump(232,"A1","A2","A3","A4","A5","A6","A7");
		QUEE S 9;
		Goto See;
	Zap:
		TNT1 A 0 A_Jump(128,"Zap7");
		Goto Choice1+3;
	Zap7:
		QUEE E 3 A_FaceTarget;
		QUEE E 3 Bright A_PlaySound("WFATATTACK",0);
		QUEE EFG 3 Bright;
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,15,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,45,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,75,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,105,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,135,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,165,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,195,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,225,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,255,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,285,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,315,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,345,0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,random(10,170),0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,random(190,260),0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,random(280,340),0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoGroundZap",0,0,random(-50,50),0);
		QUEE EFG 3 Bright;
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",0,0,15,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,45,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,75,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,105,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,135,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,165,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,195,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,225,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,255,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,285,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,315,0);
		QUEE G 0 A_CustomMissile("RS_WhiteFatsoAirZap",48,0,345,0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoAirZap",32,0,random(10,170),0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoAirZap",32,0,random(190,260),0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoAirZap",32,0,random(280,340),0);
		QUEE GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_CustomMissile("RS_WhiteFatsoAirZap",32,0,random(-50,50),0);
		QUEE S 6;
		Goto See;
	Pain:
		QUEE S 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		QUEE S 3 A_Pain;
		Goto See;
	Death:
		QUEE H 6;
		QUEE I 6 A_Scream;
		QUEE J 6 A_Fall;
		QUEE KLMNOP 6;
		QUEE Q -1;
		Stop;
	}
}
