// ============================================================================
// RS_PainElemental.zs -- Colourful Hell Pain Elemental family, native
// ZScript. Source: C:\Users\Command\Desktop\CH\decorate\thepains.txt (3,307
// lines, read whole). Every actor cites its CH line. Support:
// RS_PainElementalFX.zs (see its header for cross-lane notes, proven-missing
// assets, and standing strips).
// Tier ladder as before: CH icon index -- 1 Common, 2 Green, 3 Blue,
// 4 Purple, 5 Yellow, 6 Red, 7 FireBlu, 8 Gray (hive), 9 Abyss (spooky
// skull), 10 Black (Hell Soul Elemental), 11 White (the Watcher + its
// Pilot phase), 12 Cyan (ice turtle), 13 Brown (flesh ball).
// Minions (mini sentinels, health fountains, buff droppers, siphon souls)
// get no token.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: thepains.txt:1 -- Colourset15 replaces PainElemental.
// ---------------------------------------------------------------------------
class RS_Colourset15 : RandomSpawner replaces PainElemental
{
	Default
	{
		DropItem "RS_CommonPE", 255, 419;
		DropItem "RS_GreenPE", 255, 230;
		DropItem "RS_BrownPE", 255, 70;
		DropItem "RS_BluePE", 255, 160;
		DropItem "RS_CyanPE", 255, 80;
		DropItem "RS_PurplePE", 255, 80;
		DropItem "RS_YellowPE", 255, 40;
		DropItem "RS_FireBluPE", 255, 30;
		DropItem "RS_RedPE", 255, 18;
		DropItem "RS_GrayPE", 255, 8;
		DropItem "RS_AbyssPE", 255, 20;
		DropItem "RS_BlackPE", 255, 3;
		DropItem "RS_WhitePE", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families
// (1 = colour off / reroll the dial, 3 = fifty-fifty).
// ---------------------------------------------------------------------------
class RS_BrownPE : Actor   // CH thepains.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset15",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownPE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanPE : Actor   // CH thepains.txt:449 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset15",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanPE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssPE : Actor   // CH thepains.txt:586 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset15",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssPE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayPE : Actor   // CH thepains.txt:902 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset15",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayPE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluPE : Actor   // CH thepains.txt:1026 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset15",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluPE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackPE : Actor   // CH thepains.txt:1958 -- gate CH_BlackBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackPE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedPE",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhitePE : Actor   // CH thepains.txt:2659 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhitePE2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackPE",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown ("Ball of fleshy bits").  CH: thepains.txt:40.
// ---------------------------------------------------------------------------
class RS_BrownPE2 : Actor   // CH thepains.txt:40
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Obituary "%o + brown pain elemental = %o dead";
		HitObituary "%o got digested by brown pain elemental";
		Health 800;
		Species "PE";
		Radius 31;
		Height 56;
		Mass 400;
		Speed 12;
		FloatSpeed 12;
		PainChance 128;
		DamageFactor "Fire", 1.25;   // CH lists Fire twice, both 1.25
		DamageFactor "Melee", 0.75;  // CH lists Melee twice, both 0.75
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainThreshold 32;
		Scale 2.0;
		Monster;
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOAT
		+DONTHARMCLASS
		+MISSILEMORE
		+NOFEAR
		+FLOATBOB
		+BRIGHT
		BloodColor "blue";
		AttackSound "flesh/melee";
		SeeSound "flesh/sight";
		PainSound "flesh/pain";
		DeathSound "flesh/death";
		ActiveSound "flesh/active";
		DropItem "RS_CH_SoulSphere", 64;
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		Translation "160:167=0:0","1:2=240:246","41:47=0:2","32:40=73:79","16:31=128:143","176:191=5:7","5:8=201:204","1:2=207:207";
		Tag "Ball of fleshy bits";
	}
	States
	{
	Spawn:
		FLSP AB 8 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 AA 0 A_SpawnItemEx("RS_SplashBrownPE",random(-16,16),random(-16,16),random(5,32));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP AA 2 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_SplashBrownPE",random(-16,16),random(-16,16),random(5,32));
		FLSP BB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"oi","oi2");
		Loop;
	oi:
		FLSP A 15 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP B 6 A_Stop;
		Goto See;
	oi2:
		FLSP A 15 ThrustThing(int(angle*256/360+192),20,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP B 6 A_Stop;
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_SplashBrownPE",random(-8,8),random(-8,8),random(5,32));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP C 8 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_SplashBrownPE",random(-16,16),random(-16,16),random(5,32));
		FLSP G 6 A_FaceTarget;
		TNT1 A 0 A_Jump(176,"Shot");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("ICKYPEBR",0);
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashBrownPE",random(1,8),random(-12,12),random(28,32),random(3,12),0,random(2,6),random(-45,45));
		TNT1 A 0 A_SpawnItemEx("RS_BrownPEDed",12,0,24,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownPEDed",20,-14,12,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 G 8 A_SpawnItemEx("RS_BrownPEDed",16,14,12,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("ICKYPEBR",0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP H 12 Bright A_PainAttack("RS_BrownLSoul2");
		Goto See;
	Shot:
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashBrownPE",random(1,8),random(-8,8),random(28,32),random(3,12),0,random(2,6),random(-45,45));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP H 4 Bright A_CustomMissile("RS_BrownPEShot",32,0,random(-1,1));
		FLSP GC 8 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP CD 3 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP E 3 A_CustomMeleeAttack(random(8,12),"flesh/melee");
		TNT1 AA 0 A_SpawnItemEx("RS_SplashBrownPE",random(1,8),random(-12,12),random(28,32),random(3,12),0,random(2,6),random(-45,45));
		FLSP FE 2 A_CustomMeleeAttack(random(8,12),"flesh/melee");
		TNT1 AA 0 A_SpawnItemEx("RS_SplashBrownPE",random(1,8),random(-12,12),random(28,32),random(3,12),0,random(2,6),random(-45,45));
		FLSP FE 2 A_CustomMeleeAttack(random(8,12),"flesh/melee");
		Goto See;
	Pain:
		FLSP I 3;
		TNT1 AAAA 0 A_SpawnItemEx("RS_SplashBrownPE",random(-8,8),random(-8,8),random(5,32),random(3,12),0,random(-2,12),random(0,360));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FLSP I 3 A_Pain;
		TNT1 A 0 A_Jump(128,"oi","oi2");
		Goto See;
	Death:
		FLSP I 5;
		FLSP J 5 A_Scream;
		FLSP K 5;
		FLSP L 5 A_NoBlocking;
		FLSP MN 5 A_SetFloorClip;
		FLSP OOO 9 A_FadeOut(0.25);
		TNT1 AA 0 A_SpawnItemEx("RS_BrownPEDed",random(-12,12),random(-12,12),random(2,24),random(1,9),0,random(0,3),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 AA 12 A_SpawnItemEx("RS_BrownPEDed",random(-12,12),random(-12,12),random(2,24),random(1,9),0,random(0,5),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_BrownPEDed",random(-12,12),random(-12,12),random(2,24),random(1,9),0,random(0,3),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 AA 12 A_SpawnItemEx("RS_BrownPEDed",random(-12,12),random(-12,12),random(2,24),random(1,9),0,random(0,5),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 A 25 A_PlaySound("ICKYPEBR",0);
		TNT1 A 0 A_PlaySound("ICKYPEBR",0);
		TNT1 AAA 21 A_SpawnItemEx("RS_BrownLSoul2",0,0,16,random(1,9),0,random(8,15),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	XDeath:
		FLSP P 3;
		FLSP Q 0 A_FaceTarget;
		FLSP Q 0 A_SpawnItemEx("RS_FleshSpawnGibs",0,0,0,0,0,0,0,128);
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib1",14,0,random(-180,180),2,random(10,40));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib2",6,2,random(-180,180),2,random(0,25));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib2B",10,-2,random(-180,180),2,random(0,25));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib3",8,0,random(-180,180),2,random(0,35));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib4",12,5,random(-180,180),2,random(-5,40));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib4B",5,-5,random(-180,180),2,random(0,30));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib5",6,3,random(-180,180),2,random(10,60));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib5",8,0,random(-180,180),2,random(-10,55));
		FLSP Q 0 A_CustomMissile("RS_Fleshspawngib6",12,0,0,2,0);
		FLSP Q 3 A_XScream;
		FLSP R 3 A_NoBlocking;
		FLSP STU 3;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan ("Icey weird Pain elemental").  CH: thepains.txt:471.
// ---------------------------------------------------------------------------
class RS_CyanPE2 : Actor   // CH thepains.txt:471
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 963;
		Species "PE";
		BloodColor "Cyan";
		Radius 31;
		Height 56;
		Mass 400;
		Speed 17;
		FloatSpeed 21;
		PainChance 128;
		DamageFactor "Fire", 1.5;    // CH lists Fire twice, both 1.5
		DamageFactor "Melee", 1.5;   // CH lists Melee twice, both 1.5
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 0.2;     // CH lists ice twice, both 0.2
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 128;
		PainChance "Melee", 128;
		PainThreshold 32;
		Monster;
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOAT
		+DONTHARMCLASS
		+MISSILEMORE
		+NOFEAR
		+NOICEDEATH
		+FLOATBOB
		+BRIGHT
		SeeSound "monster/infsit";
		PainSound "monster/infpai";
		DeathSound "monster/infdth";
		ActiveSound "caco/active";
		Obituary "Ice? check! %o ? Check! Cyan Pain Elemental wins";
		DropItem "RS_CH_SoulSphere", 78;
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		Translation "152:159=%[0.00,0.00,0.57]:[0.00,1.71,1.71]","9:12=%[0.00,0.00,0.50]:[0.00,1.01,2.00]","5:8=%[0.00,0.00,0.50]:[0.00,1.01,2.00]","64:79=%[0.00,0.00,1.01]:[0.00,1.39,1.39]","144:151=%[0.00,0.00,1.01]:[0.00,2.00,2.00]","128:143=%[0.00,0.00,1.01]:[0.00,2.00,2.00]","167:167=207:207","32:47=0:0","168:191=0:0","160:166=0:0","232:235=0:0","208:223=0:0","249:249=0:0","224:231=0:0","48:63=0:0","248:248=0:0","16:31=0:0","255:255=0:0";
		Tag "Icey weird Pain elemental";
	}
	States
	{
	Spawn:
		INFR A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		INFR A 2 A_Chase;
		INFR A 2 A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"See2");
		Goto See;
	See2:
		INFR AAAAAAAAAA 1 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Melee:
	Missile:
		INFR BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128,"A1");
		INFR D 5 Bright A_CustomMissile("RS_IceOrbCyanAra1",24,0,0,0,random(-3,3));
		INFR DC 2;
		Goto See;
	A1:
		INFR D 5 Bright A_CustomMissile("RS_IceOrbCyanAra2",24,0,0);
		INFR DC 2;
		Goto See;
	Pain:
		INFR E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR E 6 A_Pain;
		Goto See2;
	Heal:
		INFR BC 5 A_FaceTarget;
		INFR D 5 { bNOPAIN = true; }           // CH: a_changeflag(nopain,TRUE)
		INFR D 0 { bNODAMAGETHRUST = true; }   // CH: a_changeflag(nodamagethrust,TRUE)
		INFR D 0 { bDONTBLAST = true; }        // CH: a_changeflag(dontblast,TRUE)
		INFR D 0 { bNOGRAVITY = false; }       // CH: a_changeflag(nogravity,FALSE)
		INFR D 0 { bDONTTHRUST = true; }       // CH: a_changeflag(dontthrust,TRUE)
		INFR D 10 A_SetScale(1.25,1.0);
		INFR D 10 A_SetScale(1.5,1.25);
		INFR D 10 A_SetScale(1.75,1.5);
		INFR D 10 A_SetScale(2.0,1.5);
		INFR D 3 ThrustThingZ(0,32,1,0);
	Turtle:
		INFR CBABCD 15;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR CBABCD 15;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR DDD 30 A_PainAttack("RS_CyanLSoul2");
		INFR CBABCD 15;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Death:
		INFR G 8;
		INFR H 8 Bright A_Scream;
		INFR I 8 Bright;
		INFR J 8 Bright A_PainDie("RS_CyanLSoul2");
		INFR K 8 Bright A_NoBlocking(false);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		INFR K 1 A_SetFloorClip;
		INFR K 1 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss ("Spooky Skull!").  CH: thepains.txt:609.
// ---------------------------------------------------------------------------
class RS_AbyssPE2 : Actor   // CH thepains.txt:609
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 1600;
		Species "PE";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 50;
		Speed 20;
		PainChance 80;
		Monster;
		+FLOAT
		+NOBLOOD
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEEVENMORE
		+MISSILEMORE
		+FLOATBOB
		+NOTARGETSWITCH
		+NOTARGET
		+DONTHARMCLASS
		SeeSound "aheadsee";
		PainSound "ahead/ow";
		DeathSound "aheadded";
		ActiveSound "ahead/ac";
		DropItem "RS_CH_Medikit";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_BlueArmor", 64;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "RS_CH_SoulSphere", 64;
		Obituary "%o got skulled";
		Tag "Spooky Skull!";
	}
	States
	{
	Spawn:
		AYPE A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		AYPE AA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssPEShadow",3,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AYPE AA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssPEShadow",3,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		AYPE B 1 A_RadiusGive("RS_SpeedBuffPE",700,RGF_MONSTERS);
		AYPE B 1 A_PlaySound("Ahead/at",0);
		AYPE B 1 Bright A_FaceTarget;
		AYPE B 1 A_JumpIfCloser(400,"Pulse");
		AYPE B 1 A_JumpIfCloser(1500,"Choice1");
	MissileSpam:
		AYPE B 1 A_FaceTarget;
		AYPE B 4 A_FaceTarget;
		AYPE AA 2 Bright A_CustomMissile("RS_VollreyAbyPE",32,random(-5,5),random(-8,8));
		AYPE B 2 A_SpidRefire;
		Goto MissileSpam+1;
	Choice1:
		TNT1 A 0 A_Jump(32,"Pulse");
		TNT1 A 0 A_Jump(255,"Pulse","Souls","Coil");
	Souls:
		AYPE B 3 A_FaceTarget;
		AYPE C 8 Bright;
		AYPE C 6 A_SpawnItemEx("RS_AbyssBaronSoul",16,0,32,0,0,0,0);
		AYPE C 6 A_SpawnItemEx("RS_AbyssBaronSoul",16,32,0,0,0,0,0);
		AYPE C 6 A_SpawnItemEx("RS_AbyssBaronSoul",16,-32,0,0,0,0,0);
		Goto See;
	Coil:
		AYPE B 3 A_FaceTarget;
		AYPE D 6 A_FaceTarget;
		AYPE EEE 2 A_CustomMissile("RS_AbyPECoil",32,random(-15,15),random(-18,18));
		AYPE FED 8;
		Goto See;
	Pulse:
		AYPE B 8 Bright A_FaceTarget;
		AYPE A 5 Bright;
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,0);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,10);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,20);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,30);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,40);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,50);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,60);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,70);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,80);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,90);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,100);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,110);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,120);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,130);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,140);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,150);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,160);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,180);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,190);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,200);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,210);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,220);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,230);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,240);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,250);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,260);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,270);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,280);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,290);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,300);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,310);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,320);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,330);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,340);
		AYPE A 0 A_CustomMissile("RS_AbyssPEPulse",12,0,350);
		AYPE A 12 Bright;
		TNT1 A 0 A_Jump(64,"Missile");
		Goto See;
	Death:
		AYPE B 8 Bright A_Stop;
		AYPE B 8 Bright A_Scream;
		TNT1 A 0 { bFLOATBOB = false; }    // CH: A_changeflag("FLOATBOB",FALSE)
		TNT1 A 0 { bFLOAT = false; }       // CH: A_changeflag("FLOAT",FALSE)
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("NOGRAVITY",FALSE)
		AYPE B 8 Bright;
	Crash:
		AYPE B 32 Bright;
		AYPE B 8 Bright A_NoBlocking;
		AYPE B 16;
		AYPE BBB 5 A_FadeOut(0.33);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray ("The nasty hive").  CH: thepains.txt:921.
// ---------------------------------------------------------------------------
class RS_GrayPE2 : Actor   // CH thepains.txt:921
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 1450;
		Species "PE";
		Speed 3;
		FloatSpeed 4;
		Radius 31;
		Height 56;
		PainChance 24;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 1.5;   // CH lists Fire twice, both 1.5
		PainChance "DIMp", 0;
		Mass 800;
		Monster;
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOAT
		+BOSS
		-NORADIUSDMG
		+NOTARGET
		+NOTARGETSWITCH
		+NOFEAR
		Obituary "%o was hive minded";
		SeeSound "slimeworm/pain";
		PainSound "wraith/wraith4";
		DeathSound "wraith/wraith5";
		ActiveSound "slimeworm/sight";
		DropItem "RS_CH_SoulSphere", 128;
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		DropItem "BackPack", 64;
		// CH: Dropitem "RareArmorPool",64 / "RLDemonicWeaponSpawner",4 /
		// "RLUniqueWeaponSpawner",12 -- DRLA cross-mod drops, stripped
		Translation "152:159=94:106","32:47=0:0","168:191=0:0","48:63=0:0","160:167=0:0","208:223=0:0","248:249=0:0","232:235=0:0","0:0=0:0","9:12=0:0","128:143=0:0","80:111=0:0","144:151=0:0","13:15=0:0","64:79=0:0","5:12=0:0";
		Tag "The nasty hive";
	}
	States
	{
	Spawn:
		INFR A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		INFR A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		INFR B 7 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR B 7 A_FaceTarget;
		INFR C 1 A_Jump(255,"Bug1","SoulIt","Bug2");
		Goto See;
	SoulIt:
		INFR C 4 Bright A_SpawnItemEx("RS_GrayLSoul2",0,0,0,random(8,18),0,random(-25,25),random(1,359),SXF_TRANSFERPOINTERS);
		INFR D 5;
		Goto See;
	Bug1:
		// CH: A_PainAttack("GrayDemon2") -- a CH typo, defined nowhere there
		// (Demons.txt:881 spells the body GreyDemon2), so this attack was
		// dead in CH. Healed to RS_GreyDemon2 at the owner's order
		// (2026-08-05): the hive now births gray demon worms as intended.
		INFR C 4 A_PainAttack("RS_GreyDemon2");
		INFR D 5;
		Goto See;
	Bug2:
		INFR C 4 A_SpawnItemEx("RS_GraySpectre2",0,0,0,random(8,18),0,random(-25,25),random(1,359),SXF_TRANSFERPOINTERS);
		INFR D 5;
		Goto See;
	Boom1:
		TORT C 0 A_PlaySound("Wraith/Wraith3");
		TORT C 4 Bright;
		Goto See;
	Pain.fire:
		INFR E 6;
		INFR E 6 Bright A_Pain;
		INFR E 6;
		INFR E 6 Bright A_Pain;
		Goto See;
	Pain:
		INFR E 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR E 3 A_Pain;
		INFR E 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		INFR E 1 A_SpawnItemEx("RS_RedThingsLS",5,1,0,0,0,0,0,SXF_NOCHECKPOSITION);
		INFR E 1 A_SpawnItemEx("RS_RedThingsLS",-3,7,0,0,0,0,0,SXF_NOCHECKPOSITION);
		INFR E 1 A_SpawnItemEx("RS_RedThingsLS",-9,3,0,0,0,0,0,SXF_NOCHECKPOSITION);
		INFR E 1 A_Jump(128,"SoulIt");
		Goto See;
	Death:
		INFR G 8;
		INFR H 8 A_Scream;
		MISL B 8;
		MISL C 2 A_PainDie("RS_BlackLSoul2");
		MISL CCC 2 A_SpawnItemEx("RS_BlackLSoul2",random(-128,128),random(-128,128),0,0,0,0,0,SXF_TRANSFERPOINTERS);
		MISL D 9 A_NoBlocking;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu ("the fuck is that").  CH: thepains.txt:1045.
// ---------------------------------------------------------------------------
class RS_FireBluPE2 : Actor   // CH thepains.txt:1045
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 800;
		Species "PE";
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 50;
		Speed 20;
		PainChance 110;
		Damage 5;   // bare constant stays bare
		SpriteAngle 0;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEEVENMORE
		+MISSILEMORE
		+FLOATBOB
		+NOTARGETSWITCH
		+SPRITEANGLE
		+DONTHARMCLASS
		SeeSound "pain/sight";
		PainSound "pain/pain";
		DeathSound "pain/death";
		ActiveSound "pain/active";
		DropItem "RS_HealthBundle";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		DropItem "RS_CH_BlueArmor", 64;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		Obituary "%o got pained out";
		Translation "70:71=176:182","72:79=201:207","64:69=191:191","13:13=180:180","14:14=204:204","15:15=191:191","140:142=204:206","143:143=187:187","138:140=182:184","133:137=198:201","128:132=176:179","236:239=203:207","5:8=182:190","1:1=199:199","96:111=198:207";
		Tag "the fuck is that";
	}
	States
	{
	Spawn:
		PAIN A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PAIN AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		PAIN DEFE 1 A_FaceTarget;
		// CH: the QuickBoom branch here is commented out in CH itself; kept out
		Goto Missile;
	Missile:
		PAIN D 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN E 5 A_FaceTarget;
		PAIN F 4 Bright A_JumpIfCloser(700,"Breath");
		PAIN F 5 Bright A_SkullAttack(30);
		Goto See;
	Breath:
		PAIN F 1 Bright A_CustomMissile("RS_BoomPEBlu",42);
		Goto See;
	Death:
		PAIN H 8 Bright;
		PAIN I 8 Bright A_Scream;
		PAIN J 8 Bright A_Explode(random(20,80),64,0);
		PAIN K 8 Bright;
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_BoomPEBlu",0,0,0,random(5,25),random(-10,50),random(-10,50),random(0,359),SXF_NOCHECKPOSITION);
		PAIN L 8 Bright A_PainDie("RS_BoomPEBlu");
		PAIN M 8 Bright A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tiers 1-6, the PainElemental-derived bodies.  CH: thepains.txt:1156-1880.
// ---------------------------------------------------------------------------
class RS_CommonPE : PainElemental   // CH thepains.txt:1156
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		GibHealth -90;
		Species "PE";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMSPECIES
		HitObituary "%o got eaten by a pain elemental";
		Tag "Pain elemental";
	}
	States
	{
	Spawn:
		PAIN A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PAIN AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Pain:
		PAIN G 6;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN G 6 A_Pain;
		Goto See;
	Melee:
		PAIN DEFE 3 A_FaceTarget;
		PAIN D 3 A_CustomMeleeAttack(random(8,40),"Bite/bite4");
		Goto See;
	Missile:
		PAIN D 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN E 5 A_FaceTarget;
		PAIN F 4 Bright A_FaceTarget;
		PAIN F 1 Bright A_PainAttack("RS_CommonLSoul");
		Goto See;
	Death:
		PAIN H 8 Bright;
		PAIN I 8 Bright A_Scream;
		PAIN JK 8 Bright;
		PAIN L 8 Bright A_PainDie("RS_CommonLSoul");
		PAIN M 8 Bright;
		Stop;
	XDeath:
		TNT1 AAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN J 7 Bright A_Pain;
		PAIN J 1 Bright A_SetAngle(angle+35);
		PAIN J 7 Bright A_Pain;
		PAIN J 1 Bright A_SetAngle(angle-90);
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- NashGore chain stripped, animation stays
		PAIN K 7 Bright;
		TNT1 AAAAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN L 8 A_PlaySound("weapons/rocklx");
		TNT1 AAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN M 8 Bright;
		TNT1 AAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: A_SpawnItemEx("CH_Soul",...) -- CH_Soul is defined NOWHERE in CH
		// (only CH_SoulSphere exists); dead spawn kept dead via the guard.
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("%s","CH_Soul")); if (cls) A_SpawnItemEx(cls,0,0,32,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION); }
		Stop;
	}
}

class RS_GreenPE : PainElemental   // CH thepains.txt:1223
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 500;
		GibHealth -90;
		BloodColor "Green";
		Species "PE";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 8;
		PainChance 112;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		SeeSound "pain/sight";
		PainSound "pain/pain";
		DeathSound "pain/death";
		ActiveSound "pain/active";
		DropItem "RS_ArmorBundle", 46;
		Obituary "%o fell to the smell of green pain elemental";
		HitObituary "%o was chomped by green pain elemental";
		Translation "32:47=112:127","208:223=112:127","232:235=112:127","168:191=112:127","16:31=112:127","167:167=125:125";
		Tag "Bad Gas Green Pain elemental";
	}
	States
	{
	Spawn:
		PAIN A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PAIN AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		PAIN DEFE 3 A_FaceTarget;
		PAIN D 3 A_CustomMeleeAttack(random(8,40),"Bite/bite4");
		Goto See;
	Missile:
		PAIN D 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN E 5 A_FaceTarget;
		PAIN E 0 A_JumpIfCloser(265,"Fart");
		PAIN E 0 A_Jump(255,"SoulIt");
		Goto See;
	SoulIt:
		PAIN F 4 Bright A_FaceTarget;
		PAIN F 1 Bright A_PainAttack("RS_GreenLSoul");
		Goto See;
	Fart:
		PAIN D 5 A_PlaySound("gas/gas1");
		PAIN G 5 A_SpawnItemEx("RS_Gas13",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 4 A_SpawnItemEx("RS_Gas13",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 3 A_SpawnItemEx("RS_Gas13",random(-220,220),random(-220,220),random(-32,64),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 2 A_SpawnItemEx("RS_Gas13",random(-220,220),random(-220,220),random(-32,64),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 1 A_SpawnItemEx("RS_Gas13",random(-260,260),random(-260,260),random(-64,88),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 0 A_SpawnItemEx("RS_Gas13",random(-260,260),random(-260,260),random(-64,88),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 1 A_SpawnItemEx("RS_Gas13",random(-220,220),random(-220,220),random(-32,64),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 2 A_SpawnItemEx("RS_Gas13",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		PAIN G 3 A_SpawnItemEx("RS_Gas13",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		PAIN A 4 A_PlaySound("Spell/Impact1");
		Goto See;
	Pain:
		PAIN G 6;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN G 6 A_Pain;
		Goto See;
	Death:
		PAIN H 8 Bright;
		PAIN I 8 Bright A_Scream;
		PAIN JK 8 Bright;
		PAIN L 8 Bright A_PainDie("RS_GreenLSoul");
		PAIN M 8 Bright;
		Stop;
	XDeath:
		TNT1 AAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN J 7 Bright A_Pain;
		PAIN J 1 Bright A_SetAngle(angle+35);
		PAIN J 7 Bright A_Pain;
		PAIN J 1 Bright A_SetAngle(angle-90);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		PAIN K 7 Bright;
		TNT1 AAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN L 8 A_PlaySound("weapons/rocklx");
		TNT1 AAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN M 8 Bright;
		TNT1 AAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("%s","CH_Soul")); if (cls) A_SpawnItemEx(cls,0,0,32,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION); }   // CH: CH_Soul, undefined in CH
		Stop;
	Raise:
		PAIN MLKJIH 8;
		Goto See;
	}
}

class RS_BluePE : PainElemental   // CH thepains.txt:1351
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 610;
		GibHealth -90;
		Radius 31;
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "PE";
		Height 56;
		Mass 400;
		Speed 8;
		PainChance 100;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		SeeSound "pe2/see";
		PainSound "pe2/hurt";
		DeathSound "pe2/die";
		ActiveSound "pain/active";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle", 64;
		RenderStyle "SoulTrans";
		Alpha 0.9;
		Obituary "%o didn't dodge blue pain elemental's plasma";
		HitObituary "%o was nommed by blue pain elemental";
		Translation "32:47=195:207","208:223=195:207","232:235=195:207","168:191=196:207","16:31=193:207","167:167=206:207","80:95=192:196","96:111=195:207","0:2=245:247";
		Tag "Blue Pain elemental";
	}
	States
	{
	Spawn:
		PAIN A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PAIN AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		PAIN DEFE 3 A_FaceTarget;
		PAIN D 3 A_CustomMeleeAttack(random(8,40),"Bite/bite4");
		Goto See;
	Missile:
		PAIN D 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN E 5 A_FaceTarget;
		PAIN E 0 A_Jump(255,"SoulIt","Plasma");
		Goto See;
	SoulIt:
		PAIN F 4 Bright A_FaceTarget;
		PAIN F 1 Bright A_PainAttack("RS_BlueLSoul");
		PAIN EDE 8;
		PAIN F 3 Bright A_PainAttack("RS_BlueLSoul",0,PAF_NOSKULLATTACK);
		Goto See;
	Plasma:
		PAIN F 3 Bright;
		PAIN F 0 A_CustomMissile("RS_PlasmaPE",22,0);
		PAIN F 0 A_CustomMissile("RS_PlasmaPE",35,0);
		PAIN F 0 A_CustomMissile("RS_PlasmaPE",12,0);
		PAIN F 0 A_CustomMissile("RS_PlasmaPE",22,-12);
		PAIN F 0 A_CustomMissile("RS_PlasmaPE",22,12);
		Goto See;
	Pain:
		PAIN G 6;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PAIN G 6 A_Pain;
		Goto See;
	Death:
		PAIN H 8 Bright;
		PAIN I 8 Bright A_Scream;
		PAIN JK 8 Bright;
		PAIN L 8 Bright A_PainDie("RS_BlueLSoul");
		PAIN M 8 Bright;
		Stop;
	XDeath:
		TNT1 AAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN J 7 Bright A_Pain;
		PAIN J 1 Bright A_SetAngle(angle+35);
		PAIN J 7 Bright A_Pain;
		PAIN J 1 Bright A_SetAngle(angle-90);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		PAIN K 7 Bright;
		TNT1 AAAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN L 8 A_PlaySound("weapons/rocklx");
		TNT1 AAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		PAIN M 8 Bright;
		TNT1 AAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("%s","CH_Soul")); if (cls) A_SpawnItemEx(cls,0,0,32,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION); }   // CH: CH_Soul, undefined in CH
		Stop;
	Raise:
		PAIN MLKJIH 8;
		Goto See;
	}
}

class RS_PurplePE : Actor   // CH thepains.txt:1481
{
	int user_slowdownbuddy;   // CH: var int user_slowdownbuddy
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 790;
		Species "PE";
		BloodColor "Purple";
		Speed 6;
		Radius 31;
		Height 56;
		PainChance 128;
		Mass 400;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOAT
		Obituary "%o look, ooh purple and nasty";
		SeeSound "wraith/wraith2";
		PainSound "wraith/wraith4";
		DeathSound "wraith/wraith5";
		ActiveSound "wraith/wraith1";
		RenderStyle "Add";
		Alpha 0.9;
		DropItem "RS_CH_SoulSphere", 72;
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		Translation "112:127=250:254","32:47=240:247","174:191=200:207","79:79=12:12","95:95=255:255";
		Tag "Purple Pain elemental";
	}
	States
	{
	Spawn:
		TORT AB 10 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TORT AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT A 0 A_Jump(8,"SoulIt");
		Loop;
	Missile:
		TORT D 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT E 6 A_FaceTarget;
		TORT E 0 A_JumpIfCloser(1200,"Or1");
		TORT E 0 A_Jump(255,"Boom2");
		Goto See;
	Or1:
		TORT E 0 A_Jump(255,"SoulIt","Boom1");
		Goto See;
	SoulIt:
		TORT F 0 A_JumpIf(user_slowdownbuddy > 6,"Maaybe");
		TORT F 7 Bright A_DualPainAttack("RS_PurpleLSoul");
		TORT D 6;
		TORT D 0 { user_slowdownbuddy += 1; }   // CH: A_SetUserVar("user_slowdownbuddy",user_slowdownbuddy+1)
		Goto See;
	Maaybe:
		TORT F 0 A_CheckSight("See");
		Goto Missile+4;
	Boom1:
		TORT E 0 A_PlaySound("Wraith/Wraith3");
		TORT D 5 Bright A_FaceTarget;
		TORT D 0 A_CustomMissile("RS_PurplePE2",40,-8,-2);
		TORT D 0 A_CustomMissile("RS_PurplePE2",40,0,0);
		TORT D 0 A_CustomMissile("RS_PurplePE2",40,8,2);
		Goto See;
	Boom2:
		TORT E 0 A_PlaySound("Spell/SpellCast1");
		TORT D 5 A_CustomMissile("RS_PurplePE1",40,0,0);
		Goto See;
	Pain:
		TORT G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT G 0 { user_slowdownbuddy -= 3; }   // CH: A_SetUserVar("user_slowdownbuddy",user_slowdownbuddy-3)
		TORT G 3 A_Pain;
		Goto See;
	Death:
		TORT H 8;
		TORT I 8 A_Scream;
		TORT JK 8;
		TORT L 8 A_Explode(random(15,35),64);
		TORT M 8 A_NoBlocking;
		TORT N 8;
		Stop;
	}
}

class RS_YellowPE : PainElemental   // CH thepains.txt:1635
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 900;
		Species "PE";
		BloodColor "Yellow";
		Radius 31;
		Height 56;
		Mass 400;
		Speed 11;
		MeleeDamage 8;
		PainChance 128;
		DamageFactor "Fire", 0.5;
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 1.2;   // CH lists ice twice, both 1.2
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOAT
		+DONTHARMCLASS
		+MISSILEMORE
		+NOFEAR
		RenderStyle "SoulTrans";
		Alpha 0.9;
		SeeSound "monster/infsit";
		PainSound "monster/infpai";
		DeathSound "monster/infdth";
		ActiveSound "caco/active";
		MeleeSound "caco/melee2";
		HitObituary "%o met yellow pain elemental.. up close.";
		Obituary "%o met yellow pain elemental.. once.";
		DropItem "RS_CH_SoulSphere", 62;
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		Translation "152:159=213:223","9:12=187:191","5:8=46:47","75:79=190:191","173:191=160:167","0:0=0:0";
		Tag "Volcanic Orange Pain elemental";
	}
	States
	{
	Spawn:
		INFR A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		INFR A 2 A_Chase;
		INFR A 1 A_Jump(8,"Spawns2");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Spawns2:
		INFR BC 5;
		INFR D 5 A_PainAttack("RS_YellowLSoul");
		INFR D 0 A_CheckSight("See");
		Goto Missile;
	Missile:
		INFR BC 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR D 5 Bright A_CustomMissile("RS_LavaballPE",24,0,0,0);
		INFR D 2 A_Jump(64,"Spawns2");
		Goto See;
	Melee:
		INFR ADC 3 A_FaceTarget;
		INFR B 4 A_CustomMeleeAttack(random(9,48),"Caco/Melee2");
		Goto See;
	Pain:
		INFR E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INFR E 3 A_Pain;
		INFR E 6 A_Jump(128,"Spawns2");
		Goto See;
	Death:
		INFR G 8;
		INFR H 8 Bright A_Scream;
		INFR I 8 Bright;
		INFR I 0 A_CustomMissile("RS_LavaballPE",32,0,45,2);
		INFR I 0 A_CustomMissile("RS_LavaballPE",32,0,135,2);
		INFR I 0 A_CustomMissile("RS_LavaballPE",32,0,225,2);
		INFR I 0 A_CustomMissile("RS_LavaballPE",32,0,315,2);
		INFR J 8 Bright A_PainDie("RS_YellowLSoul");
		INFR K 8 Bright A_NoBlocking;
		INFR K 0 A_SetFloorClip;
		Stop;
	}
}

class RS_RedPE : Actor   // CH thepains.txt:1769
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 1111;
		Species "PE";
		Speed 11;
		Radius 31;
		Height 56;
		PainChance 42;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Mass 400;
		Monster;
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOAT
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOFEAR
		Obituary "%o felt a big red raging pain in the ass";
		SeeSound "wraith/wraith2";
		PainSound "wraith/wraith4";
		DeathSound "wraith/wraith5";
		ActiveSound "wraith/wraith1";
		RenderStyle "SoulTrans";
		Scale 1.15;
		Alpha 0.95;
		DropItem "RS_CH_SoulSphere", 74;
		DropItem "RS_CH_Berserk", 128;
		DropItem "RS_ArmorBundle";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		Translation "112:127=0:0","96:111=32:47","3:3=188:188";
		Tag "Red rage elemental";
	}
	States
	{
	Spawn:
		TORT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TORT AAB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT BCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT A 0 A_Jump(34,"SoulIt");
		Loop;
	Missile:
		TORT B 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT B 2 A_FaceTarget;
		TORT B 0 A_JumpIfCloser(450,"BadBreath");
		TORT B 0 A_JumpIfCloser(900,"Or1");
		TORT B 0 A_Jump(255,"DASH");
		Goto See;
	Or1:
		TORT E 0 A_Jump(255,"SoulIt","Boom1");
		Goto See;
	BadBreath:
		TORT C 5 A_FaceTarget;
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,16,1);
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,12,1);
		TORT C 0 A_FaceTarget;
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,8,1);
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,4,1);
		TORT C 0 A_FaceTarget;
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,0,1);
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,-4,1);
		TORT C 0 A_FaceTarget;
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,-8,1);
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,-12,1);
		TORT C 0 A_FaceTarget;
		TORT D 3 Bright A_CustomMissile("RS_CorpseBreathPE",21,0,-16,1);
		TORT C 4 Bright;
		TORT C 1 Bright A_MonsterRefire(84,"See");
		Goto Missile;
	SoulIt:
		TORT C 9 Bright A_PainAttack("RS_RedLSoul");
		TORT D 5;
		Goto See;
	Boom1:
		TORT C 0 A_PlaySound("Wraith/Wraith3");
		TORT C 4 Bright;
		TORT C 0 A_CustomMissile("RS_SbombPE",32,-8,-2);
		TORT C 0 A_CustomMissile("RS_SbombPE",20,0,0);
		TORT C 0 A_CustomMissile("RS_SbombPE",32,8,2);
		Goto See;
	Dash:
		TORT D 0 A_PlaySound("wraith/wraith2");
		TORT D 4 A_SkullAttack(30);
		TORT D 1 Bright A_MonsterRefire(84,"See");
		Goto Missile;
	Pain:
		TORT G 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TORT G 3 A_Pain;
		TORT G 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TORT G 1 A_SpawnItemEx("RS_RedThingsLS",5,1,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TORT G 1 A_SpawnItemEx("RS_RedThingsLS",-3,7,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TORT G 1 A_SpawnItemEx("RS_RedThingsLS",-9,3,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TORT G 1 A_Jump(128,"SoulIt");
		Goto See;
	Death:
		TORT H 8;
		TORT I 8 A_Scream;
		MISL B 8;
		MISL C 8 A_Explode(random(15,65),128);
		MISL D 9 A_NoBlocking;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black boss ("Hell Soul Elemental").  CH: thepains.txt:1977.
// ---------------------------------------------------------------------------
class RS_BlackPE2 : Actor   // CH thepains.txt:1977
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 5000;
		Radius 31;
		Height 56;
		Mass 1000;
		Speed 14;
		PainChance 20;
		DamageType "Normal";
		Monster;
		DamageFactor "lightning", 0.2;
		DamageFactor "hornet", 0;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		RadiusDamageFactor 0.33;
		PainChance "DIMp", 0;
		Obituary "%o was electriminated by Black Pain Elemental";
		HitObituary "The Black Pain Elemental ate %o , yum yum";
		+FLOORCLIP
		+BOSS
		-NORADIUSDMG
		+NOFEAR
		+NOTARGET
		+MISSILEEVENMORE
		+DONTMORPH
		+FLOAT
		+DONTHARMCLASS
		+NOGRAVITY
		+DONTFALL
		+NOICEDEATH
		MeleeDamage 20;
		MeleeRange 68;
		SeeSound "monster/ovlsit";
		PainSound "monster/ovlpai";
		DeathSound "monster/ovldth";
		ActiveSound "monster/ovlact";
		MeleeSound "caco/melee";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "RS_CH_PlasmaRifle", 128;
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "RS_CH_PlasmaRifle", 128;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		// CH: Dropitem "RareArmorPool",128 / "RLDemonicWeaponSpawner",12 /
		// "RLUniqueWeaponSpawner",24 -- DRLA cross-mod drops, stripped
		Tag "Hell Soul Elemental";
	}
	States
	{
	Spawn:
		OVER A 1;
		Goto Scripted;
	Scripted:
		OVER A 1;
		OVER A 2;   // CH: ACS_NamedExecuteAlways("AnnounceBlackPE") -- announcer stripped
	Idle:
		OVER A 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		OVER AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		OVER AACC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		OVER D 0 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		OVER D 0 A_JumpIfHealthLower(2500,"Phase2");
		OVER D 0 A_Jump(256,"Missile2","Missile3","Missile1");
		Stop;
	Phase2:
		OVER D 0 A_Jump(256,"Missile4","Missile2","Missile5");
	Missile1:
		OVER DE 8 A_FaceTarget;
		OVER FF 5 Bright A_CustomMissile("RS_SkullBundle3",32,0,random(-10,10));
		Goto See;
	Missile2:
		OVER GH 8 Bright A_FaceTarget;
		OVER H 1 Bright A_PlaySound("weapons/shock");
		OVER H 7 Bright A_CustomMissile("RS_StormShot1",43,0,0,0,0);
		Goto See;
	Missile3:
		OVER JJJJJJJJ 1 A_FaceTarget;
		OVER K 0 A_CustomMissile("RS_HadesBall4",92,-40,random(-3,3),0,random(-3,3));
		OVER K 0 A_CustomMissile("RS_HadesBall4",8,-40,random(-3,3),0,random(-3,3));
		OVER K 0 A_CustomMissile("RS_HadesBall4",92,40,random(-3,3),0,random(-3,3));
		OVER K 0 A_CustomMissile("RS_HadesBall4",8,40,random(-3,3),0,random(-3,3));
		OVER K 0 A_CustomMissile("RS_OverBall3",54,-50,random(-3,3),0,random(-3,3));
		OVER K 4 Bright A_CustomMissile("RS_OverBall3",54,50,random(-3,3),0,random(-3,3));
		OVER J 7 A_SpidRefire;
		OVER J 0 A_Jump(32,"Missile1");
		Goto Missile3+8;
	Missile4:
		OVER JJJJJJJJ 1 A_FaceTarget;
		OVER GHG 3 Bright;
		OVER K 4 Bright;
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",92,-40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",8,-40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",92,40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",8,40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",54,-50,random(-3,3),0,random(-3,3));
		OVER K 4 Bright A_CustomMissile("RS_BEESHOT",54,50,random(-3,3),0,random(-3,3));
		OVER G 3 Bright A_CheckSight("See");
		OVER K 4 Bright;
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",92,-40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",8,-40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",92,40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",8,40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_BEESHOT",54,-50,random(-3,3),0,random(-3,3));
		OVER K 4 Bright A_CustomMissile("RS_BEESHOT",54,50,random(-3,3),0,random(-3,3));
		OVER K 0 A_Jump(88,"Missile1");
		Goto See;
	Missile5:
		OVER JJJJJJJJ 1 A_FaceTarget;
		OVER GG 5 A_FaceTarget;
		OVER K 1 Bright A_CustomMissile("RS_LoadPE3",92,-40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_LoadPE3",8,-40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_LoadPE3",92,40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_LoadPE3",8,40,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_LoadPE3",54,-50,random(-3,3),0,random(-3,3));
		OVER K 1 Bright A_CustomMissile("RS_LoadPE3",54,50,random(-3,3),0,random(-3,3));
		OVER K 8 A_FaceTarget;
		OVER H 4 A_PlaySound("monster/ovlsit");
		OVER H 2 Bright A_CustomMissile("RS_SkullDeathPE",92,-40,random(-8,8),0,random(-8,8));
		OVER H 2 Bright A_CustomMissile("RS_SkullDeathPE",8,-40,random(-3,3),0,random(-3,3));
		OVER H 2 Bright A_CustomMissile("RS_SkullDeathPE",92,40,random(-12,12),0,random(-3,3));
		OVER H 2 Bright A_CustomMissile("RS_SkullDeathPE",8,40,random(-3,9),0,random(-9,3));
		OVER H 2 Bright A_CustomMissile("RS_SkullDeathPE",54,-50,random(-9,9),0,random(-3,3));
		OVER H 2 Bright A_CustomMissile("RS_SkullDeathPE",54,50,random(-3,3),0,random(-12,12));
		OVER GJ 2;
		Goto See;
	Melee:
		OVER ADF 4 A_FaceTarget;
		OVER E 4 A_MeleeAttack;
		OVER E 0 A_Jump(128,"Missile");
		Goto See;
	Pain:
		OVER L 6;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		OVER L 6 A_Pain;
		Goto See;
	Death:
		OVER M 1 Bright A_FaceTarget;
		OVER M 9 Bright A_ScreamAndUnblock;
		OVER NO 10 Bright;
		OVER PPPPP 0 A_CustomMissile("RS_OverFlesh1",random(0,90),random(0,40),random(-180,180),2,random(-15,15));
		OVER PPPPP 0 A_CustomMissile("RS_OverFlesh2",random(0,90),random(0,40),random(-180,180),2,random(-15,15));
		OVER PPPPPPPPPP 0 A_CustomMissile("RS_OverFlesh3",random(0,90),random(0,40),random(-180,180),2,random(-15,15));
		OVER PPPPPPPPPP 0 A_CustomMissile("RS_OverFlesh4",random(0,90),random(0,40),random(-180,180),2,random(-15,15));
		OVER PPPPPPPPPP 0 A_CustomMissile("RS_OverFlesh5",random(0,90),random(0,40),random(-180,180),2,random(-15,15));
		OVER PPPPPPPPPP 0 A_CustomMissile("RS_OverFlesh6",random(0,90),random(0,40),random(-180,180),2,random(-15,15));
		OVER P 0 A_CustomMissile("RS_OverBigArm1",40,-40,-90,2,random(-1,1));
		OVER P 0 A_CustomMissile("RS_OverBigArm2",40,40,90,2,random(-1,1));
		OVER P 0 A_CustomMissile("RS_OverSmallArm1",100,-30,-90,2,random(-15,15));
		OVER P 0 A_CustomMissile("RS_OverSmallArm1",100,30,90,2,random(-15,15));
		OVER P 0 A_CustomMissile("RS_OverSmallArm2",100,-30,-90,2,random(-15,15));
		OVER P 0 A_CustomMissile("RS_OverSmallArm2",100,30,90,2,random(-15,15));
		OVER P 0 A_CustomMissile("RS_OverHorn1",110,-16,-90,2,random(-15,15));
		OVER P 0 A_CustomMissile("RS_OverHorn2",110,16,90,2,random(-15,15));
		OVER PQRSTUV 10 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White boss ("Against thee wicked" -- the Watcher, then the
// Pilot).  CH: thepains.txt:2678 / 2811.
// ---------------------------------------------------------------------------
class RS_WhitePE2 : Actor   // CH thepains.txt:2678
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 5000;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 28;
		FloatSpeed 28;
		Species "PE";
		PainChance 128;
		Monster;   // CH lists Monster twice
		RadiusDamageFactor 0.33;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "plwater", 0.5;   // CH lists plwater twice, both 0.5
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOATBOB
		+AVOIDMELEE
		+BOSS
		+NOTARGET
		+NEVERTARGET
		+NOINFIGHTING
		+DONTHARMCLASS
		-NORADIUSDMG
		+FRIGHTENED
		+THRUSPECIES
		+NOICEDEATH
		+DONTMORPH
		+DONTBLAST
		+DONTTHRUST
		SeeSound "WHPESEE";
		PainSound "WHPEPAIN";
		DeathSound "Crack/death";
		ActiveSound "WHPEACT";
		Obituary "%o got sighted";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
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
		DropItem "RS_CH_Berserk";
		Tag "Against thee wicked";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Eyes;
	Eyes:
		// CH: ACS_NamedExecuteAlways("AnnounceWhitePE") -- announcer stripped
		WATC XXXXXXXXXXXX 12 A_SpawnItemEx("RS_MiniSentinelPE",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto Idle;
	Idle:
		WATC X 2 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WATC XXX 2 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"DropBuff");
		WATC XXX 2 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WATC X 1 A_CheckProximity("ReEye","RS_MiniSentinelPE",128,1,CPXF_LESSOREQUAL);
		TNT1 A 0 A_Jump(16,"WanderBit");
		WATC XXX 2 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	ReEye:
		WATC XXXXXXXXXXXX 6 A_SpawnItemEx("RS_MiniSentinelPE",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto See;
	WanderBit:
		WATC XXXXXXXXX 2 A_Wander;
		Goto See;
	DropBuff:
		WATC X 1;
		WATC Y 5;
		WATC W 5 A_SpawnItemEx("RS_BufferWhitePE",random(-64,64),random(-64,64),random(-4,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"WanderBit");
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WATC XX 1 A_SpawnItemEx("RS_MiniSentinelPE",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		WATC Y 5 A_SetScale(0.9,1.1);
		WATC W 5 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Jump(256,"Fountains","Beams");
		Goto See;
	Fountains:
		WATC VV 5 Bright A_SpawnItemEx("RS_HealthFountainWhitePE",random(-266,266),random(-266,266),random(1,6),0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Beams:
		WATC W 1;
		WATC W 5 A_FaceTarget;
		WATC V 5 Bright A_CustomRailgun(random(30,60),0,"red","red",RGF_FULLBRIGHT|RGF_NOPIERCING|RGF_NORANDOMPUFFZ,0,0,null,0,0,0,60,0.5,0.2,"RS_DFlarePE",3,30);   // CH: pufftype ""
		Goto See;
	Pain:
		WATC Y 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WATC Y 3 A_Pain;
		WATC YYY 3 A_SpawnItemEx("RS_MiniSentinelPE",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		WATC Y 3;
		Goto See;
	Death:
		WATC V 3 Bright;
		WATC V 3 Bright A_Scream;
		WATC V 3 Bright A_NoBlocking;
		WATC V 4 Bright A_CustomMissile("RS_HKRedDeath",100,-30,CMF_AIMOFFSET,2,-10);
		WATC V 4 Bright A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		WATC V 4 Bright A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		WATC V 4 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		WATC VVVV 4 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		WATC VVVV 3 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		WATC VVVV 2 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		WATC VVVVV 1 Bright A_CustomMissile("RS_HKRedDeath",random(15,90),random(-50,50),CMF_AIMOFFSET,2,random(-10,10));
		TNT1 A 0 A_SetScale(2.0,2.0);
		MISL BCD 5 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_WhitePE3",0,0,16,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_WhitePE3 : Actor   // CH thepains.txt:2811 -- "The Pilot", phase 2
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 1000;
		Radius 24;
		Height 40;
		Mass 150;
		Speed 46;
		FloatSpeed 46;
		Species "PE";
		PainChance 128;
		Monster;   // CH lists Monster twice
		RadiusDamageFactor 0.33;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "plwater", 0.5;   // CH lists plwater twice, both 0.5
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+FLOATBOB
		+AVOIDMELEE
		+BOSS
		+NOTARGET
		+DONTMORPH
		+NEVERTARGET
		+NOINFIGHTING
		+DONTHARMCLASS
		-NORADIUSDMG
		+THRUSPECIES
		+NOICEDEATH
		+DONTBLAST
		+DONTTHRUST
		SeeSound "BEDsee";
		PainSound "BEDpain";
		DeathSound "BEDded";
		ActiveSound "BEDsee";
		AttackSound "";
		Obituary "%o was killed by mechanised eyes tiny pilot";
		Tag "The Pilot";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: Dropitem "RareArmorPool" / "RLDemonicWeaponSpawner",20 /
		// "RLLegendaryWeaponSpawner",8 / "RLUniqueWeaponSpawner",42 -- DRLA, stripped
	}
	States
	{
	Spawn:
		WATC A 10 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WATC AAA 3 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(24,"DropBuff");
		WATC AAA 3 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	WanderBit:
		WATC AAAAAA 2 A_Wander;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WATC AAA 2 A_Wander;
		Goto See;
	DropBuff:
		WATC B 3;
		WATC C 4;
		WATC D 5 A_SpawnItemEx("RS_BufferWhitePE",random(-64,64),random(-64,64),random(-4,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_HealthFountainWhitePE",random(-266,266),random(-266,266),random(1,6),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"WanderBit");
		Goto See;
	Missile:
		WATC E 5 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WATC F 5 A_FaceTarget;
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,0);
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,random(-3,3));
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,random(-9,9));
		WATC G 5 Bright A_CustomRailgun(random(30,60),0,"red","red",RGF_FULLBRIGHT|RGF_NOPIERCING|RGF_NORANDOMPUFFZ,0,0,null,0,0,0,60,0.5,0.2,"RS_DFlarePE",7,30);   // CH: pufftype ""
		WATC F 5 A_FaceTarget;
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,0);
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,random(-3,3));
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,random(-9,9));
		WATC G 5 Bright A_CustomRailgun(random(30,60),0,"red","red",RGF_FULLBRIGHT|RGF_NOPIERCING|RGF_NORANDOMPUFFZ,0,0,null,0,0,0,60,0.5,0.2,"RS_DFlarePE",7,30);
		WATC F 5 A_FaceTarget;
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,0);
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,random(-3,3));
		WATC G 0 A_CustomMissile("RS_DFlarePE2",15,0,random(-9,9));
		WATC G 5 Bright A_CustomRailgun(random(30,60),0,"red","red",RGF_FULLBRIGHT|RGF_NOPIERCING|RGF_NORANDOMPUFFZ,0,0,null,0,0,0,60,0.5,0.2,"RS_DFlarePE",7,30);
		Goto See;
	Pain:
		WATC H 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WATC H 3 A_Pain;
		WATC H 1 A_Jump(64,"WanderBit");
		Goto See;
	Death:
		WATC I 8 A_Scream;
		WATC JKLM 6;
		WATC N 6 A_NoBlocking;
		TNT1 A 0 { bFLOATBOB = false; }   // CH: A_changeflag("FLOATBOB",false)
		WATC N 0 A_SetFloorClip;
		WATC O -1;
		Stop;
	}
}
