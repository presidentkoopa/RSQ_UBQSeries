// ============================================================================
// RS_Zombieman.zs -- Colourful Hell Zombieman family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Zombies.txt (2,786 lines,
// read whole). Every actor cites its CH line. Support classes and the
// import rules header live in RS_ZombiemanFX.zs.
//
// Tier ladder (CH icon index): 1 Common, 2 Green, 3 Blue, 4 Purple,
// 5 Yellow(Orange), 6 Red, 7 FireBlu, 8 Gray, 9 Abyss, 10 Black,
// 11 White, 12 Cyan, 13 Brown.  RS_Zom.SetTier() in each PostBeginPlay.
//
// Frame gap closed 2026-08-06 (owner: visual consistency beats verbatim
// silence):
//   * ZOMP M -- the gib set ships N-U (8 lumps) here AND in CH; M is in no
//     IWAD and nowhere in CH.  CH's complete zombie sets (CZOW/PZOW/ZUNM)
//     run their XDeath O-W, and CH shifted that 9-frame template down two
//     letters onto ZOMP as M-U -- one letter more than the set has.
//     RS_PurpleZombie is the only class that writes it, on a 5-tic state, so
//     its gib animation opened with 5 tics of invisibility.  Now holds N.
//     Frame count and tic count unchanged.  (SGUP M in RS_Shotgunner.zs is the
//     same defect on a 0-tic state and was left verbatim -- see that header.)
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Zombies.txt:1 -- Colourset2 replaces ZombieMan.
// Weights verbatim.
// ---------------------------------------------------------------------------
class RS_ZombieColourset : RandomSpawner replaces ZombieMan
{
	Default
	{
		DropItem "RS_CommonZombie", 255, 540;
		DropItem "RS_BrownZombie", 255, 100;
		DropItem "RS_GreenZombie", 255, 320;
		DropItem "RS_BlueZombie", 255, 220;
		DropItem "RS_CyanZombie", 255, 100;
		DropItem "RS_AbyssZombie", 255, 60;
		DropItem "RS_GrayZombie", 255, 60;
		DropItem "RS_FireBluZombie", 255, 50;
		DropItem "RS_PurpleZombie", 255, 80;
		DropItem "RS_YellowZombie", 255, 60;
		DropItem "RS_RedZombie", 255, 26;
		DropItem "RS_BlackZombie", 255, 2;
		DropItem "RS_WhiteZombie", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  CH gates via CallACS -> cvar; value semantics kept:
// 1 = reroll into the main set (colour off), 3 = 50/50, else spawn colour.
// ---------------------------------------------------------------------------
class RS_BrownZombie : Actor   // CH Zombies.txt:18
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
		TNT1 A 0 A_SpawnItemEx("RS_ZombieColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanZombie : Actor   // CH Zombies.txt:187 -- spawns THREE bodies.
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
		TNT1 A 0 A_SpawnItemEx("RS_ZombieColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_CyanZombie2",0,0,0,2,0,1,90,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_CyanZombie2",0,0,0,2,0,1,180,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluZombie : Actor   // CH Zombies.txt:340
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
		TNT1 A 0 A_SpawnItemEx("RS_ZombieColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayZombie : Actor   // CH Zombies.txt:473
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
		TNT1 A 0 A_SpawnItemEx("RS_ZombieColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssZombie : Actor   // CH Zombies.txt:620
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
		TNT1 A 0 A_SpawnItemEx("RS_ZombieColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackZombie : Actor   // CH Zombies.txt:1569 -- boss gate.
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackZombie1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackZombie1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackZombieEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackZombieEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackZombieEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedZombie",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteZombie : Actor   // CH Zombies.txt:2027
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteZombie1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackZombie",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN.  CH: Zombies.txt:40.  The bodyguard: warps to big
// demons and jumps at you.
// ---------------------------------------------------------------------------
class RS_BrownZombie2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 100;
		PainChance 128;
		Speed 8;
		Radius 24;
		Height 64;
		Mass 1000;
		Scale 0.9;
		Monster;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		+FLOORCLIP
		+AVOIDMELEE
		+NOINFIGHTING
		+ROLLSPRITE
		+NOTARGETSWITCH
		SeeSound "Zom2/see";
		AttackSound "grunt/attack";
		PainSound "Form2/hurt";
		DeathSound "zom2/die";
		ActiveSound "Form2/active";
		Obituary "%o got bodyguard slammed";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "HealthBonus", 64;
		DropItem "HealthBonus", 128;
	}
	States
	{
	Spawn:
		SGAR A 5 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SGAR BC 6 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CheckProximity("GETDOWN","Archvile",1000,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_SETMASTER|CPXF_CLOSEST);
		TNT1 A 0 A_CheckProximity("GETDOWN","BaronOfHell",1000,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_SETMASTER|CPXF_CLOSEST);
		TNT1 A 0 A_CheckProximity("GETDOWN","HellKnight",1000,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_SETMASTER|CPXF_CLOSEST);
		TNT1 A 0 A_CheckProximity("GETDOWN","CyberDemon",1000,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_SETMASTER|CPXF_CLOSEST);
		TNT1 A 0 A_CheckProximity("GETDOWN","ChainGunGuy",1000,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT|CPXF_SETMASTER|CPXF_CLOSEST);
		SGAR DE 6 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128, "See");
		TNT1 A 0 A_CheckLOF("FrontJump",CLOFF_NOAIM_VERT|CLOFF_JUMPENEMY|CLOFF_SKIPOBSTACLES,800);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SGAR F 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SGAR G 10 Bright A_PosAttack;
		SGAR F 10;
		Goto See;
	GETDOWN:
		TNT1 A 0 A_CheckLOF("GetDown2",CLOFF_NOAIM_VERT|CLOFF_JUMPENEMY|CLOFF_SKIPOBSTACLES,800);
		Goto See+8;
	GetDown2:
		TNT1 A 0;
		SGAR F 5 A_FaceMaster;
		SGAR F 1 ThrustThingZ(0,30,0,0);
		SGAR F 1 ThrustThing(angle,24,0,0);
		SGAR F 1 A_SetRoll(30);
		SGAR F 1 A_SetRoll(60);
		SGAR F 1 A_SetTranslucent(0.7);
		SGAR F 1 A_SetRoll(90);
		SGAR F 1 A_SetRoll(120);
		SGAR F 1 A_SetTranslucent(0.4);
		SGAR F 1 A_SetRoll(150);
		SGAR F 1 A_SetRoll(180);
		SGAR F 1 A_SetTranslucent(0.1);
		SGAR F 1 A_Warp(AAPTR_MASTER,randompick(32,48,64),0,randompick(-32,-16,0,16,32),0,WARPF_COPYVELOCITY|WARPF_COPYPITCH);
		SGAR F 1 A_SetTranslucent(0.4);
		SGAR F 1 A_SetRoll(240);
		SGAR F 1 A_SetRoll(270);
		SGAR F 1 A_SetTranslucent(0.7);
		SGAR F 1 A_SetRoll(300);
		SGAR F 2 A_SetTranslucent(1.0);
		SGAR F 1 A_SetRoll(330);
		SGAR F 1 A_SetRoll(360);
		SGAR F 6 A_Stop;
		Goto See;
	FrontJump:
		SGAR F 5 A_FaceTarget;
		SGAR F 1 ThrustThingZ(0,28,0,0);
		SGAR F 1 ThrustThing(angle,14,0,0);
		SGAR F 16;
		SGAR F 6 A_Stop;
		SGAR BC 6 A_FastChase;
		Goto See;
	Pain:
		TNT1 A 0 A_SetRoll(0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SGAR H 8 A_Pain;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",0,"Tickles");
		TNT1 A 0 A_SetRoll(0);
		SGAR I 5;
		SGAR J 5 A_Scream;
		SGAR K 5;
		SGAR L 5 A_NoBlocking;
		SGAR M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (owner: vanilla gore ok)
		POSS M 3;
		POSS N 3 A_XScream;
		POSS O 3 A_NoBlocking;
		POSS PQRST 3;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		POSS A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	Raise:
		SGAR LKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN.  CH: Zombies.txt:245.  Comes in threes; ice shots.
// ---------------------------------------------------------------------------
class RS_IceZombieShot : Actor   // CH Zombies.txt:211
{
	Default
	{
		Radius 3;
		Height 2;
		Speed 33;
		DamageFunction (random(6,16));
		DamageType "Ice";
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		XScale 1.15;
		YScale 0.15;
		SeeSound "Ice/Hit2";
		DeathSound "spike/spiked";   // undefined in CH's own SNDINFO too -- silent, verbatim
	}
	States
	{
	Spawn:
		ICEY ABC 3 Bright;
		Loop;
	Death:
		ICEY FGHI 5 Bright;
		Stop;
	}
}

class RS_IceZombieShot2 : RS_IceZombieShot   // CH Zombies.txt:236
{
	Default
	{
		Radius 2;
		XScale 0.95;
		YScale 0.1;
		Speed 42;
		DamageFunction (random(4,14));
	}
}

class RS_CyanZombie2 : Actor   // CH Zombies.txt:245
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 30;
		Radius 20;
		Height 56;
		Speed 9;
		PainChance 40;
		BloodColor "Blue";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "Fire", 2.0;
		DamageFactor "Melee", 2.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+THRUSPECIES
		+MISSILEMORE
		+AVOIDMELEE
		+NOICEDEATH
		SeeSound "Zom2/see";
		AttackSound "grunt/attack";
		PainSound "Form2/hurt";
		DeathSound "zom2/die";
		ActiveSound "Form2/active";
		Obituary "%o got cooled off by cyan zombie";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "HealthBonus", 64;
		DropItem "HealthBonus", 128;
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
		Tag "Cyan Zombieman";
	}
	States
	{
	Spawn:
		CYNT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CYNT AABBCCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(128, "See2");
		Loop;
	See2:
		CYNT AABBCCDD 1 A_FastChase;
		Goto See;
	Missile:
		CYNT E 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYNT F 4 A_CustomMissile("RS_IceZombieShot",42,1,random(-2,2));
		CYNT E 4;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CYNT G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CYNT G 3 A_Pain;
		Goto See;
	Death:
		CYNT G 12 A_Scream;
		CYNT G 4 A_NoBlocking;
		CYNT G 6 A_SetScale(1.2,0.8);
		CYNT G 6 A_SetScale(1.0,1.0);
		CYNT G 6 A_SetScale(0.8,1.2);
		CYNT G 4 A_SetScale(1.2,0.8);
		CYNT G 4 A_SetScale(0.8,1.2);
		CYNT G 3 A_SetScale(1.2,0.8);
		CYNT G 3 A_SetScale(0.8,1.2);
		CYNT G 2 A_SetScale(1.2,0.8);
		CYNT G 2 A_SetScale(0.8,1.2);
		CYNT G 1 A_SetScale(1.2,0.8);
		CYNT G 1 A_SetScale(0.8,1.2);
		MISL A 0 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU.  CH: Zombies.txt:359.  Sheds fire while it walks,
// explodes on melee range / XDeath.
// ---------------------------------------------------------------------------
class RS_FireBluZombie2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 70;
		Species "Zombie";
		GibHealth -5;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "Fire", 0.25;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 12;
		PainChance 255;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "%o was killed by a... uhhh... flaming zombieman?";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "RS_CH_RocketAmmo";
		Translation "0:64=%[1.95,0.56,0.59]:[0.69,0.08,0.09]","65:128=%[0.17,0.42,1.59]:[0.02,0.07,0.41]","129:192=%[1.95,0.56,0.59]:[0.69,0.08,0.09]","193:255=%[0.17,0.42,1.59]:[0.02,0.07,0.41]";
		Tag "FireBlu Zombie";
	}
	States
	{
	Spawn:
		POSS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		POSS AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See2:
		POSS AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS A 0 A_SpawnItemEx("RS_FireSGguy2",-6,0,3,-2,0,1,-180);
		POSS CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS A 0 A_SpawnItemEx("RS_FireSGguy2",-6,0,3,-2,0,1,-180);
		Loop;
	Missile:
		TNT1 A 0;
		Goto See2;
	Melee:
		POSS EF 5 Bright A_FaceTarget;
		Goto XDeath;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		Stop;
	Pain:
		POSS G 3 A_SpawnItemEx("RS_FireSGguy2",6,0,3,9,0,1,random(0,359));
		POSS G 3 A_Pain;
		Goto See2;
	Death:
		POSS H 5 A_JumpIfInventory("RS_CHBoner",0,"Tickles");
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5;
		TNT1 A 0 A_JumpIfInventory("RS_CHAbyssMark",1,"AbyssGrow");
		POSS L -1;
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		POSS A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		ZOMG P 0 A_PlaySound("weapons/rocklx",7,1);
		MISL B 6 Bright A_Explode(random(12,44),84);
		MISL C 6 Bright A_Quake(20,12,0,64,0);
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS AAAAA 0 A_SpawnItemEx("RS_FireSGguy2",0,0,3,random(3,9),0,1,random(-359,359));
		ZOMG T 0 A_CustomMissile("RS_FireSGguy2",32,7);   // CH: ZOMG U -- 0-tic, frame past end of set
		ZOMG T 0 A_CustomMissile("RS_FireSGguy2",32,-7);   // CH: ZOMG U -- 0-tic, frame past end of set
		MISL D 6 A_NoBlocking;
		Stop;
	Raise:
		POSS K 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		POSS JIH 5;
		Goto See2;
	Grow:
		POSS JIH 5;
		POSS A 0 A_SpawnItemEx("RS_PurpleZombie",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY.  CH: Zombies.txt:492.  Slow brick-thrower.
// ---------------------------------------------------------------------------
class RS_ZombieRock : RS_WDRock3   // CH Zombies.txt:614
{
	Default
	{
		DamageFunction (random(1,12));
		Scale 0.25;
	}
}

class RS_GrayZombie2 : ZombieMan
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 110;
		Radius 20;
		Height 56;
		Speed 4;
		Damage 1;
		PainChance 40;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "Fire", 2.0;
		DamageFactor "Melee", 2.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+AVOIDMELEE
		SeeSound "Zom2/see";
		AttackSound "grunt/attack";
		PainSound "Form2/hurt";
		DeathSound "zom2/die";
		ActiveSound "Form2/active";
		Obituary "%o was brick'd by gray zombie.";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "HealthBonus", 64;
		DropItem "HealthBonus", 128;
		Translation "0:255=%[0.00,0.00,0.00]:[1.13,1.25,1.35]";
		Tag "Gray Zombieman";
	}
	States
	{
	Spawn:
		SHDT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SHDT AABB 5 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDT CCDD 5 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SHDT E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDT F 2 Bright A_CustomMissile("RS_ZombieRock",46,1,random(-2,2));
		SHDT F 2 A_CustomMissile("RS_ZombieRock",46,1,random(-2,2));
		SHDT F 2 Bright A_CustomMissile("RS_ZombieRock",46,1,random(-2,2));
		SHDT F 2;
		SHDT E 8;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SHDT G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDT G 3 A_Pain;
		Goto See;
	Death:
		SHDT H 5 A_JumpIfInventory("RS_CHBoner",0,"Tickles");
		SHDT I 5 A_Scream;
		SHDT J 5 A_NoBlocking;
		SHDT K 5;
		TNT1 A 0 A_JumpIfInventory("RS_CHAbyssMark",1,"AbyssGrow");
		SHDT L -1;
		Stop;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		SHDT A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	XDeath:
		SHDT G 12 A_Scream;
		SHDT G 4 A_NoBlocking;
		SHDT G 6 A_SetScale(1.2,0.8);
		SHDT G 6 A_SetScale(1.0,1.0);
		SHDT G 6 A_SetScale(0.8,1.2);
		SHDT G 4 A_SetScale(1.2,0.8);
		SHDT G 4 A_SetScale(0.8,1.2);
		SHDT G 3 A_SetScale(1.2,0.8);
		SHDT G 3 A_SetScale(0.8,1.2);
		SHDT G 2 A_SetScale(1.2,0.8);
		SHDT G 2 A_SetScale(0.8,1.2);
		SHDT G 1 A_SetScale(1.2,0.8);
		SHDT G 1 A_SetScale(0.8,1.2);
		MISL BCD 1;
		TNT1 AAAAAAAAAAAAA 0 A_CustomMissile("RS_ZombieRock",32,0,random(-359,359));
		Stop;
	Raise:
		SHDT K 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SHDT JIH 5;
		Goto See;
	Grow:
		SHDT JIH 5;
		SHDT A 0 A_SpawnItemEx("RS_PurpleZombie",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS.  CH: Zombies.txt:643-786.  Infects other zombies with
// the mark; they transform into more of it when they die.
// ---------------------------------------------------------------------------
class RS_AbyssZShotCH : Actor   // CH Zombies.txt:643
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 32;
		XScale 0.5;
		YScale 0.2;
		DamageFunction (random(5,30));
		DamageType "Ice";
		RenderStyle "Add";
		Alpha 0.95;
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BAL1 A 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BAL1 B 2 Bright A_Weave(2,1,2,0.1);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(0.85,0.85);
		BAL7 CDE 4 Bright A_Explode(random(1,8),42);
		Stop;
	}
}

class RS_AbyssZShotCH2 : RS_AbyssZShotCH   // CH Zombies.txt:677
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 45;
		XScale 0.3;
		YScale 0.1;
	}
}

class RS_AbyssZShotCH3 : RS_AbyssZShotCH   // CH Zombies.txt:686
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 60;
		XScale 0.35;
		YScale 0.15;
	}
}

class RS_AbyssZombie2 : Actor   // CH Zombies.txt:695
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Obituary "%o was dragged down deep by Abyss Zombie.";
		Health 200;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 14;
		BloodColor "Black";
		Species "Zombie";
		PainChance 18;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "Zom2/see";
		PainSound "Form2/hurt";
		DeathSound "imp2/die";
		ActiveSound "Form2/active";
		DropItem "RS_CH_Cell";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_Berserk", 64;
		DropItem "RS_CH_Cell", 128;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+AVOIDMELEE
		Tag "Abyss Infected Zombie";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fling:
		ABTR A 1 A_RadiusGive("RS_CHAbyssMark",528,RGF_MONSTERS,55,null,"Zombie");   // CH passed 0 for the filter; ZScript wants null
	Idle:
		ABTR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ABTR AAB 2 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABTR B 1 A_FastChase;
		ABTR CCD 2 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABTR D 1 A_FastChase;
		Loop;
	Missile:
		ABTR E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABTR F 5 A_CustomMissile("RS_AbyssZShotCH",36,3,random(-7,1));
		ABTR F 5 A_CustomMissile("RS_AbyssZShotCH",36,3,random(-1,7));
		ABTR E 10;
		Goto See;
	Pain:
		ABTR G 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ABTR G 1 A_Pain;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-178,178),random(-178,178),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		ABTR H 5 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ABTR I 5 A_Scream;
		ABTR J 5 A_NoBlocking;
		ABTR KL 5;
		ABTR L -1;
		Stop;
	XDeath:
		ABTR MNO 5;
		TNT1 AAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ABTR P 5 A_XScream;
		ABTR Q 5 A_NoBlocking;
		ABTR RSTU 5 A_SpawnItemEx("RS_SplashAbyss2",random(-24,24),random(-24,24),random(8,64),0,0,random(-359,359),2,SXF_NOCHECKPOSITION);
		ABTR U -1;
	Raise:
		ABTR KJIH 5;
		Goto See;
	}
}

class RS_AbyssZombie3 : RS_AbyssZombie2   // CH Zombies.txt:782
{
	Default
	{
		Health 140;
		Speed 10;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON.  CH: Zombies.txt:788.  Vanilla stats + CH death web.
// Inherits ZombieMan's Health 20 and vanilla Missile state on purpose.
// ---------------------------------------------------------------------------
class RS_CommonZombie : ZombieMan
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Speed 7;
		Species "Zombie";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+AVOIDMELEE
		Obituary "%o was somehow killed by common zombie";
		DropItem "RS_implyingclip";
		Tag "Zombieman";
	}
	States
	{
	Spawn:
		POSS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		POSS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Death:
		POSS H 5 A_JumpIfInventory("RS_CHBoner",0,"Tick");
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5;
		TNT1 A 0 A_JumpIfInventory("RS_CHAbyssMark",1,"AbyssGrow");
		POSS L -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS M 3;
		POSS N 3 A_XScream;
		POSS O 3 A_NoBlocking;
		POSS PQRST 3;
		TNT1 AAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Tick:
		POSS HIIIIIII 5;
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		POSS A 0 A_SpawnItemEx("RS_AbyssZombie3",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	Raise:
		POSS K 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		POSS JIH 5;
		Goto See;
	Grow:
		POSS JIH 5;
		POSS A 0 A_SpawnItemEx("RS_GreenZombie",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN.  CH: Zombies.txt:870.  Leaks poison gas everywhere.
// ---------------------------------------------------------------------------
class RS_Gas11 : Actor   // CH Zombies.txt:989
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 0;
		FastSpeed 0;
		DamageType "Poison";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Scale 0.8;
		Alpha 0.6;
	}
	States
	{
	Spawn:
		PSBG CDE 3 Bright;
		Goto Death;
	Death:
		PSBG FGHI 6 Bright A_Explode(random(1,8),32);
		Stop;
	}
}

class RS_GreenZombie : ZombieMan
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 40;
		Species "Zombie";
		BloodColor "Green";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 9;
		PainChance 180;
		MeleeThreshold 300;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "%o was killed by a smelly uncommon zombieman.";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		Translation "128:143=[10,146,33]:[1,21,0]","152:159=[43,208,97]:[21,73,20]","144:151=[34,121,38]:[17,49,26]","16:31=[41,241,101]:[26,104,21]","32:39=[23,96,33]:[9,54,7]","76:79=125:127","48:63=112:116","70:79=123:127","160:167=116:123","214:223=122:127","66:71=121:124","39:47=124:127","64:65=120:121";
		Tag "Green Zombie";
	}
	States
	{
	Spawn:
		POSS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		POSS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See2:
		POSS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS A 0 A_CustomMissile("RS_Gas11",32,0);
		Loop;
	Missile:
		POSS E 0 A_CustomMissile("RS_Gas11",32,0);
		POSS E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS F 8 A_PosAttack;
		POSS E 8 A_CustomMissile("RS_Gas11",32,0);
		POSS E 10 A_FaceTarget;
		POSS F 8 A_PosAttack;
		POSS E 8 A_CustomMissile("RS_Gas11",32,0);
		Goto See2;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		POSS G 3 A_CustomMissile("RS_Gas11",32,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS G 3 A_Pain;
		Goto See2;
	Death:
		POSS H 5 A_JumpIfInventory("RS_CHBoner",0,"Tickles");
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5 A_CustomMissile("RS_Gas11",32,0);
		TNT1 A 0 A_JumpIfInventory("RS_CHAbyssMark",1,"AbyssGrow");
		POSS L -1;
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		POSS A 0 A_SpawnItemEx("RS_AbyssZombie3",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		ZOMG M 5 A_SetTranslucent(0.8);
		ZOMG N 5 A_XScream;
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		ZOMG O 5 A_NoBlocking;
		ZOMG PQR 5 A_SetTranslucent(0.5);
		ZOMG RST 5 A_SetTranslucent(0.3);
		// CH: ZOMG U 5 -- CH's gib death walks N,O,PQR,RST and then steps one
		// letter PAST the end of its own sprite set: CH ships ZOMG N-T only
		// (7 lumps, verified in CH's own sprites/zombies/). So the corpse
		// vanished for the 5 tics in which it bursts into its gas cloud.
		// Held T, the set's real last frame. Same sprite, same tics, gas
		// unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		ZOMG T 5 A_CustomMissile("RS_Gas11",49,0);
		ZOMG T 0 A_CustomMissile("RS_Gas11",32,7);   // CH: ZOMG U -- 0-tic, same fix for consistency
		ZOMG T 0 A_CustomMissile("RS_Gas11",32,-7);   // CH: ZOMG U -- 0-tic, same fix for consistency
		Stop;
	Raise:
		POSS K 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		POSS JIH 5;
		Goto See2;
	Grow:
		POSS JIH 5;
		POSS A 0 A_SpawnItemEx("RS_BlueZombie",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE.  CH: Zombies.txt:1013.  Faster, tighter hitscan.
// ---------------------------------------------------------------------------
class RS_BlueZombie : ZombieMan
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 60;
		Radius 20;
		Height 56;
		Speed 9;
		PainChance 140;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+AVOIDMELEE
		SeeSound "Zom2/see";
		AttackSound "grunt/attack";
		PainSound "Form2/hurt";
		DeathSound "zom2/die";
		ActiveSound "Form2/active";
		Obituary "%o got the blues from getting killed by zombie.";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "HealthBonus", 64;
		DropItem "HealthBonus", 128;
		Translation "128:143=[54,54,241]:[9,11,83]","152:159=[0,0,255]:[0,0,64]","144:151=[0,0,255]:[0,0,64]","16:31=[0,0,255]:[0,0,64]","32:39=[0,0,255]:[0,0,64]","76:79=204:207","48:63=196:199","70:79=200:206","160:167=198:205","214:223=202:207","66:71=201:205","39:47=242:247","64:65=201:204","112:127=198:207","168:191=160:167";
		Tag "Blue Zombieman";
	}
	States
	{
	Spawn:
		POSS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		POSS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		POSS E 10 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS F 7 A_CustomBulletAttack(7,7,3,random(1,2));
		POSS E 8;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		POSS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS G 3 A_Pain;
		Goto See;
	Death:
		POSS H 5 A_JumpIfInventory("RS_CHBoner",0,"Tickles");
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5;
		TNT1 A 0 A_JumpIfInventory("RS_CHAbyssMark",1,"AbyssGrow");
		POSS L -1;
		Stop;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		POSS A 0 A_SpawnItemEx("RS_AbyssZombie3",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		ZOMB N 5 A_XScream;
		ZOMB O 5 A_NoBlocking;
		ZOMB PQRST 5;
		TNT1 AAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ZOMB U -1;
		Stop;
	Raise:
		POSS K 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		POSS JIH 5;
		Goto See;
	Grow:
		POSS JIH 5;
		POSS A 0 A_SpawnItemEx("RS_PurpleZombie",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE.  CH: Zombies.txt:1125.  Hitscan close, seeker orbs far.
// ---------------------------------------------------------------------------
class RS_Orbb11 : Actor   // CH Zombies.txt:1245
{
	Default
	{
		Radius 3;
		Height 4;
		Speed 21;
		FastSpeed 32;
		DamageFunction (random(2,18));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.3;
		SeeSound "Weapons/Plasmaf";
		DeathSound "weapons/plasmax";
		Translation "16:47=250:254","48:79=250:254","80:111=250:254","128:143=250:254","144:151=253:254","152:191=250:254";
	}
	States
	{
	Spawn:
		BAL1 A 2 Bright A_SeekerMissile(2,3);
		BAL1 B 2 Bright A_Weave(5,4,2,1);
		Loop;
	Death:
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_PurpleZombie : ZombieMan
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 95;
		Species "Zombie";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Speed 10;
		PainChance 120;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+AVOIDMELEE
		SeeSound "Zom2/see";
		AttackSound "grunt/attack";
		PainSound "Form2/hurt";
		DeathSound "zom2/die";
		ActiveSound "Form2/active";
		Obituary "%o got outfabolous'd";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "HealthBonus";
		DropItem "HealthBonus", 88;
		DropItem "HealthBonus", 128;
		DropItem "ArmorBonus", 64;
		RenderStyle "SoulTrans";
		Alpha 1;
		Translation "48:63=[230,149,247]:[180,24,156]","169:191=0:0","64:79=[168,15,181]:[41,12,13]","128:143=[238,133,250]:[117,23,56]","144:151=[175,16,216]:[125,26,28]","152:159=[176,27,214]:[100,19,21]","160:167=0:2","215:223=106:111","117:125=0:2","21:21=27:31";
		Tag "Purple Zombieman";
	}
	States
	{
	Spawn:
		POSS AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		POSS AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS E 2 A_JumpIfCloser(800,"Hitscanne");
		POSS E 0 A_Jump(255,"Orbb");
	Hitscanne:
		POSS E 10 A_FaceTarget;
		POSS F 7 A_CustomBulletAttack(9,9,3,random(1,2));
		POSS F 4 A_CustomBulletAttack(7,7,2,random(1,2));
		POSS E 8 A_MonsterRefire(128,"See");
		Goto Missile;
	Orbb:
		POSS E 5 A_FaceTarget;
		POSS F 5 Bright A_CustomMissile("RS_Orbb11",46,1);
		POSS F 5 Bright A_CustomMissile("RS_Orbb11",46,1);
		POSS F 5 Bright A_CustomMissile("RS_Orbb11",46,1);
		POSS E 5;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		POSS G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		POSS G 3 A_Pain;
		Goto See;
	Death:
		POSS H 5 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5;
		TNT1 A 0 A_JumpIfInventory("RS_CHAbyssMark",1,"AbyssGrow");
		POSS L -1;
		Stop;
	AbyssGrow:
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Black",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(9,15),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-32,32),random(-32,32),random(2,16),0,0,2,random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 8;
		POSS A 0 A_SpawnItemEx("RS_AbyssZombie3",0,0,6,0,0,1,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		ZOMP N 5;   // CH: ZOMP M -- the lump does not exist (ZOMP ships N-U only, in CH too, and M is in no IWAD). Unlike SGUP M this state is 5 TICS, so the gib animation opened with 5 tics of nothing. Held N, the set's real first gib frame, so N now plays 5+5. Frame count and tic count both unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		ZOMP N 5 A_XScream;
		ZOMP O 5 A_NoBlocking;
		ZOMP PQRST 5;
		TNT1 AAAA 0 A_SpawnParticle("Purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ZOMP U -1;
		Stop;
	Raise:
		POSS KJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW (Orange Zombiewoman).  CH: Zombies.txt:1275.
// Burst bullets close, mini-rockets far; launcher jams after 3.
// ---------------------------------------------------------------------------
class RS_MiniRKTZombie : Actor   // CH Zombies.txt:1411
{
	Default
	{
		Radius 6;
		Height 4;
		Speed 22;
		DamageFunction (random(5,40));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+DEHEXPLOSION
		+ROCKETTRAIL
		Scale 0.4;
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		MISL A 1 Bright;
		Loop;
	Death:
		MISL B 8 Bright A_Explode(random(5,15),58);
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

class RS_RocketCounter : Inventory { Default { Inventory.MaxAmount 3; } }   // CH Zombies.txt:1439

class RS_YellowZombie : ZombieMan
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 140;
		Mass 90;
		Species "Zombie";
		BloodColor "Yellow";
		DamageFactor "Melee", 2;
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 13;
		Radius 19;
		Height 52;
		PainChance 100;
		Obituary "%o was shown that the orange zombie was a tough lady";
		SeeSound "lady/aggro";
		PainSound "lady/hurt";
		DeathSound "lady/die";
		ActiveSound "lady/active";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketBox", 12;
		DropItem "RS_CH_Medikit", 160;
		DropItem "RS_CH_RocketLauncher", 24;
		// CH: DropItem "RLDuelistArmorPickup",32 -- DRLA stripped per owner 2026-08-05
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+AVOIDMELEE
		+DONTHARMSPECIES
		Translation "168:191=160:167","152:159=164:167","40:47=232:235","32:39=213:223","26:31=248:248";
		Tag "Orange Zombiewoman";
	}
	States
	{
	Spawn:
		CZOW AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		CZOW AABB 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZOW CCDD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Dodger:
		CZOW AABB 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZOW CCDD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZOW A 0 A_Jump(88,"See");
		Loop;
	Missile:
		CZOW E 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZOW E 0 A_JumpIfCloser(550,"Bullets");
		CZOW E 0 A_Jump(256,"RocketsOr");
		Goto See;
	RocketsOr:
		CZOW E 0 A_Jump(255,"Rockets","Bullets");
		Goto See;
	Bullets:
		CZOW F 0 A_PlaySound("chainguy/attack");
		CZOW F 3 Bright A_CustomBulletAttack(4,4,1,random(1,3));
		CZOW E 2 A_FaceTarget;
		CZOW F 3 Bright A_CustomBulletAttack(7,7,1,random(1,3));
		CZOW E 2 A_FaceTarget;
		CZOW F 3 Bright A_CustomBulletAttack(9,9,1,random(1,3));
		CZOW E 2 A_MonsterRefire(128,"See");
		Goto Missile;
	Rockets:
		CZOW F 0 A_JumpIfInventory("RS_RocketCounter",3,"Jammed");
		CZOW F 3 Bright A_CustomMissile("RS_MiniRKTZombie",32,2,random(-2,2));
		CZOW E 2 A_GiveInventory("RS_RocketCounter",1);
		CZOW E 2 A_MonsterRefire(128,"See");
		Goto Missile;
	Jammed:
		CZOW E 0 { bNOPAIN = true; }
		CZOW E 10 A_PlaySound("Jam/Jamd",0,1.9);
		CZOW A 18 A_FaceTarget;
		CZOW E 10 A_PlaySound("Jam/Jamd",0,1.9);
		CZOW E 10 A_PlaySound("Jam/Jamd",0,1.9);
		CZOW E 10 A_PlaySound("Jam/Jamd",0,1.9);
		CZOW G 16 A_TakeInventory("RS_RocketCounter",3);
		CZOW A 16 A_PlaySound("Lady/Active");
		CZOW A 0 { bNOPAIN = false; }
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		CZOW G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		CZOW G 3 A_Pain;
		Goto Dodger;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		CZOW H 5 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		CZOW I 5 A_Scream;
		CZOW J 5 A_Fall;
		CZOW K 5;
		CZOW LM 5;
		CZOW N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		CZOW O 5;
		CZOW P 5 A_XScream;
		CZOW Q 5 A_Fall;
		CZOW RSTUV 5;
		TNT1 AAAAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Pantsu",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		CZOW W -1;
		Stop;
	Raise:
		CZOW MLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED (ZombieUnman).  CH: Zombies.txt:1441.  Unmaker beams.
// ---------------------------------------------------------------------------
class RS_BloodyPuff : Actor   // CH Zombies.txt:1553
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		+EXTREMEDEATH
	}
	States
	{
	Spawn:
	Crash:
		DBLD A 4 Bright;
		DBLD BCD 4;
		Stop;
	}
}

class RS_RedZombie : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Obituary "%o was unmade by the Red Zombie.";
		Health 186;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		Species "Zombie";
		PainChance 100;
		AttackSound "zombie/unmaker";
		DamageFactor "Exorcist", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Melee", 3;
		PainChance "DIMp", 0;
		SeeSound "Zom2/see";
		PainSound "Form2/hurt";
		DeathSound "zom2/die";
		ActiveSound "Form2/active";
		DropItem "RS_CH_Cell";
		DropItem "RS_implyingclip";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_Berserk", 128;
		DropItem "RS_CH_Cell", 128;
		// CH: DropItem "RLUnmakerPickup",4 -- DRLA stripped per owner 2026-08-05
		Decal "BloodSplat";
		Monster;
		+FLOORCLIP
		+EXTREMEDEATH
		+DONTHARMSPECIES
		+AVOIDMELEE
		Tag "Red ZombieUnman";
	}
	States
	{
	Spawn:
		ZUNM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ZUNM AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZUNM CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZUNM E 0 A_Jump(64,"Missile2");
		ZUNM E 15 A_FaceTarget;
		ZUNM F 10 A_CustomBulletAttack(2,2,1,random(5,25),"RS_BloodyPuff");
		ZUNM E 10;
		Goto See;
	Missile2:
		ZUNM E 16 A_FaceTarget;
		ZUNM E 0 A_PlaySound("zombie/unpower");
		ZUNM F 1 Bright A_CustomRailgun(random(5,20),4,"FF 00 00",0,0);
		ZUNM E 0 A_PlaySound("zombie/unpower");
		ZUNM F 1 Bright A_CustomRailgun(random(5,20),4,"CC 00 00",0,0);
		ZUNM E 0 A_PlaySound("zombie/unpower");
		ZUNM F 1 Bright A_CustomRailgun(random(5,20),4,"99 00 00",0,0);
		ZUNM E 0 A_PlaySound("zombie/unpower");
		ZUNM F 1 Bright A_CustomRailgun(random(5,20),4,"55 00 00",0,0);
		ZUNM E 0 A_PlaySound("zombie/unpower");
		ZUNM F 1 Bright A_CustomRailgun(random(5,20),4,"33 00 00",0,0);
		ZUNM E 10 A_SentinelRefire;
		Goto Missile2+1;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssZombie2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		ZUNM G 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZUNM G 3 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		ZUNM H 5 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ZUNM I 5 A_Scream;
		ZUNM J 5 A_NoBlocking;
		ZUNM K 5;
		ZUNM L 5;
		ZUNM M 5;
		ZUNM N -1;
		Stop;
	XDeath:
		ZUNM O 5;
		TNT1 AAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ZUNM P 5 A_XScream;
		ZUNM Q 5 A_NoBlocking;
		ZUNM RSTUV 5 A_SpawnItemEx("RS_HKRedDeath",random(-24,24),random(-24,24),random(8,64),0,0,0,0,SXF_NOCHECKPOSITION);
		ZUNM W -1;
	Raise:
		ZUNM KJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK.  CH: Zombies.txt:1607 (EX) / 1888 (normal).
// "Player X" / "Player 9".  ACS announcer dropped per owner.
// ---------------------------------------------------------------------------
class RS_PlayerEXBFG : Actor   // CH Zombies.txt:1825
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 25;
		DamageFunction (random(100,200));
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.25;
		Scale 1.0;
		DeathSound "weapons/bfgx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BFS1 A 2 Bright A_SpawnItemEx("RS_TrailSPCguy",random(-2,2),random(-2,2),random(-1,1),20,0,random(-5,5),random(-270,270));
		BFS1 B 2 Bright A_SpawnItemEx("RS_TrailSPCguy",random(-2,2),random(-2,2),random(-1,1),20,0,random(-5,5),random(-270,270));
		Loop;
	Death:
		BFE1 AB 8 Bright A_SetScale(1.25);
		TNT1 A 0 Radius_Quake(15,15,0,40,0);
		BFE1 C 8 Bright A_Explode(random(45,125),156);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_PlayerEXBFG2",random(-12,12),random(-12,12),random(-1,1),random(2,19),0,random(-9,9),random(-359,359),SXF_NOCHECKPOSITION);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

class RS_PlayerEXBFG2 : Actor   // CH Zombies.txt:1857
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 10;
		DamageFunction (random(20,80));
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.55;
		Translation "0:255=%[0.00,0.17,0.00]:[0.81,1.35,0.28]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BFS1 A 2 Bright A_SetScale(0.55,0.75);
		BFS1 B 2 Bright A_SetScale(0.75,0.55);
		TNT1 A 0 A_Jump(2,"Death");
		Loop;
	Death:
		BFS1 ABABAB 2 Bright A_FadeOut(0.33);
		Stop;
	}
}

class RS_ShotgunWhere : Inventory { Default { Inventory.MaxAmount 1; } }   // CH Zombies.txt:2025

class RS_BlackZombieEX : Actor   // CH Zombies.txt:1607 -- Player X
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 5000;
		Radius 16;
		Height 56;
		Mass 100;
		Speed 28;
		PainChance 16;
		DamageFactor "Heroic", 3.0;
		DamageFactor "PlayerVoid", 0.5;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Falling", 0.0;
		PainChance "PLWater", 12;
		PainChance "ice", 12;
		PainChance "Fire", 4;
		PainChance "Melee", 12;
		Monster;
		+LAXTELEFRAGDMG
		+BOSS
		+QUICKTORETALIATE
		+FLOORCLIP
		+LOOKALLAROUND
		+MISSILEMORE
		+DONTMORPH
		-NORADIUSDMG
		+NOFEAR
		Translation "123:127=5:8","112:122=108:111","152:159=6:8","128:143=5:8","9:12=0:0","64:79=106:111","48:63=32:47","16:31=32:47","80:95=0:0","96:111=0:0","144:151=184:191";
		SeeSound "HEHEEENH";
		ActiveSound "HEHEEENH";
		DeathSound "*death";
		PainSound "*pain50";
		Obituary "%o met the player X";
		HitObituary "Player X: lmao owned rekt gg ez";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "CH_Chaingun";        // undefined in CH itself -- silent no-op there too, kept verbatim
		DropItem "RS_CH_SuperShotgun";
		// CH: DropItem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLFragShotgunPickup",84 -- DRLA stripped per owner 2026-08-05
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: DropItem "RLUniqueWeaponSpawner",24 -- DRLA stripped per owner 2026-08-05
		Tag "Player X";
	}
	States
	{
	Spawn:
		PLAY A 1;
		Goto Scripted;
	Scripted:
		PLAY A 1;
		PLAY A 1;   // CH: ACS_NamedExecuteAlways("AnnounceBlackZombie") -- announcers dropped per owner
		PLAY A 1 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		PLAY A 4 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PLAY ABCD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY A 0 A_Jump(128,"See2");
		Loop;
	See2:
		PLAY ABCD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY A 0 A_Jump(128,"See");
		Loop;
	Melee:
		PLAY E 4 A_FaceTarget;
		PLAY E 4 A_CustomMeleeAttack(random(60,120),"player/fist","none");
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		Goto Shotttgun;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY E 0 A_JumpIfCloser(300,"Shotttgun");
		PLAY E 0 A_JumpIfCloser(840,"PlasmaSpammer");
		PLAY E 0 A_Jump(256,"Rawkets");
		Goto See;
	Taunt:
		PLAY A 4;
		PLAY G 4 A_PlaySound("HEHEEENH",0);
		PLAY A 4;
		PLAY G 4 A_PlaySound("HEHEEENH",0);
		PLAY A 4;
		PLAY G 4 A_PlaySound("HEHEEENH",0);
		PLAY A 4;
		PLAY G 4 A_PlaySound("HEHEEENH",0);
		PLAY A 4;
		PLAY G 4 A_PlaySound("HEHEEENH",0);
		PLAY A 3;
		PLAY G 3 A_PlaySound("HEHEEENH",0);
		PLAY A 3;
		PLAY G 3 A_PlaySound("HEHEEENH",0);
		PLAY A 3;
		PLAY G 3 A_PlaySound("HEHEEENH",0);
		PLAY GAG 4 A_PlaySound("HEHEEENH",0);
		PLAY AGA 3 A_PlaySound("HEHEEENH",0);
		PLAY GAG 2 A_PlaySound("HEHEEENH",0);
		Goto See;
	Shotttgun:
		PLAY E 3 A_FaceTarget;
		PLAY E 1 A_JumpIfCloser(300,"Shootmydude");
		PLAY E 1 ThrustThingZ(0,64,0,0);
		PLAY E 1 ThrustThing(angle,12,0,0);
		PLAY E 10;
	Shootmydude:
		PLAY F 0 A_JumpIfInventory("RS_ShotgunWhere",1,"Jammed");
		PLAY F 0 A_PlaySound("weapons/sshotf");
		PLAY F 13 Bright A_CustomBulletAttack(22.5,5,8,6,"BulletPuff",0);
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY F 0 A_GiveInventory("RS_ShotgunWhere",1);
		Goto See;
	Jammed:
		PLAY E 8 Bright;
		PLAY A 2 A_PlaySound("weapons/sshotl");
		PLAY A 8 A_TakeInventory("RS_ShotgunWhere",1);
		PLAY E 2 A_SpawnItemEx("Shell",8,4,32,3,3,1,angle+5);
		PLAY E 0 A_Jump(84,"RBarrage");
		PLAY E 0 A_Jump(64,"BFGBoi");
		Goto Missile;
	RBarrage:
		PLAY E 1 ThrustThingZ(0,64,0,0);
		PLAY E 1 ThrustThing(angle-180,12,0,0);
		PLAY E 6 A_FaceTarget;
		TNT1 A 0 A_Jump(128,"AltBar");
		PLAY E 1 ThrustThingZ(0,64,0,0);
		PLAY E 1 ThrustThing(angle+90,12,0,0);
		PLAY E 2;
		PLAY F 4 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY F 4 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY F 4 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		Goto See;
	AltBar:
		PLAY E 1 ThrustThingZ(0,64,0,0);
		PLAY E 1 ThrustThing(angle-90,12,0,0);
		PLAY E 2;
		PLAY F 4 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY F 4 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY F 4 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		Goto See;
	BFGBoi:
		PLAY E 1;
		PLAY E 1 A_PlaySound("weapons/bfgf",0);
		PLAY E 10 Bright;
		PLAY E 8 Bright A_FaceTarget;
		PLAY E 6 Bright A_FaceTarget;
		PLAY F 4 Bright A_CustomMissile("RS_PlayerEXBFG",32,0,0);
		PLAY E 12;
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		Goto See;
	PlasmaSpammer:
		PLAY E 0 A_Jump(84,"RBarrage");
		PLAY E 2 A_FaceTarget;
		PLAY E 0 A_FaceTarget;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-5,5));
		PLAY E 1 A_FaceTarget;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-15,15));
		PLAY E 1 A_FaceTarget;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-25,25));
		PLAY E 1;
		PLAY E 0 A_Jump(34,"BFGBoi");
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-35,35));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY A 0 A_MonsterRefire(128,"CellEject");
		Goto Missile;
	CellEject:
		PLAY A 8;
		PLAY GG 3 A_SpawnItemEx("Cell",8,4,32,3,3,1,angle+5);
		PLAY A 3;
		Goto See;
	Rawkets:
		PLAY E 2;
		PLAY F 2 Bright A_CustomBulletAttack(5.6,0,1,5,"BulletPuff");
		PLAY E 2 A_Jump(32,"ActualRawk");
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY E 0 A_Jump(8,"BFGBoi");
		PLAY A 0 A_CPosRefire;
		Goto Missile;
	ActualRawk:
		PLAY E 2;
		PLAY F 2 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 0 A_CheckFlag("CORPSE","Taunt",AAPTR_TARGET);
		PLAY E 0 A_Jump(34,"BFGBoi");
		PLAY E 2;
		Goto Missile;
	Pain:
		PLAY G 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY G 4 A_Pain;
		PLAY E 0 A_Jump(84,"RBarrage");
		Goto See;
	Death:
		PLAY H 10;
		PLAY I 10 A_Scream;
		PLAY J 10 A_NoBlocking;
		PLAY I 10 A_PlaySound("*death");
		PLAY J 10;
		PLAY I 10 A_PlaySound("*death");
		PLAY J 10;
		PLAY I 10 A_PlaySound("*death");
		PLAY JKLM 10;
		PLAY M -1;
		Stop;
	}
}

class RS_BlackZombie1 : Actor   // CH Zombies.txt:1888 -- Player 9
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 2500;
		Radius 16;
		Height 56;
		Mass 100;
		Speed 26;
		PainChance 16;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 8;
		PainChance "ice", 10;
		PainChance "Fire", 8;
		PainChance "Melee", 42;
		Monster;
		+BOSS
		+QUICKTORETALIATE
		+FLOORCLIP
		+LOOKALLAROUND
		+MISSILEMORE
		+DONTMORPH
		-NORADIUSDMG
		+NOFEAR
		Translation "80:95=96:111","96:111=5:8","112:127=96:111";
		DeathSound "*death";
		PainSound "*pain50";
		Obituary "%o met the missing player";
		HitObituary "Player9: Git Gud";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "CH_Chaingun";        // undefined in CH itself -- kept verbatim
		DropItem "RS_CH_SuperShotgun";
		// CH: DropItem "RareArmorPool",64 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLFragShotgunPickup",72 -- DRLA stripped per owner 2026-08-05
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: DropItem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		Tag "Player 9";
	}
	States
	{
	Spawn:
		PLAY A 1;
		Goto Scripted;
	Scripted:
		PLAY A 1;
		PLAY A 1;   // CH: ACS_NamedExecuteAlways("AnnounceBlackZombie") -- announcers dropped per owner
		PLAY A 1;
		Goto Idle;
	Idle:
		PLAY A 4 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PLAY ABCD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY A 0 A_Jump(128,"See2");
		Loop;
	See2:
		PLAY ABCD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY A 0 A_Jump(128,"See");
		Loop;
	Melee:
		PLAY E 4 A_FaceTarget;
		PLAY E 4 A_CustomMeleeAttack(random(20,80),"player/fist","none");
		Goto Shotttgun;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY E 0 A_JumpIfCloser(300,"Shotttgun");
		PLAY E 0 A_JumpIfCloser(840,"PlasmaSpammer");
		PLAY E 0 A_Jump(256,"Rawkets");
		Goto See;
	Shotttgun:
		PLAY E 3 A_FaceTarget;
		PLAY F 0 A_JumpIfInventory("RS_ShotgunWhere",1,"Jammed");
		PLAY F 0 A_PlaySound("weapons/sshotf");
		PLAY F 13 Bright A_CustomBulletAttack(22.5,5,8,6,"BulletPuff",0);
		PLAY F 0 A_GiveInventory("RS_ShotgunWhere",1);
		Goto See;
	Jammed:
		PLAY E 8 Bright;
		PLAY A 2 A_PlaySound("weapons/sshotl");
		PLAY A 8 A_TakeInventory("RS_ShotgunWhere",1);
		PLAY E 2 A_SpawnItemEx("Shell",8,4,32,3,3,1,angle+5);
		Goto Missile;
	PlasmaSpammer:
		PLAY E 2 A_FaceTarget;
		PLAY E 0 A_FaceTarget;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-5,5));
		PLAY E 1 A_FaceTarget;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-15,15));
		PLAY E 1 A_FaceTarget;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-25,25));
		PLAY E 1;
		PLAY F 3 Bright A_CustomMissile("RS_PlasmaBallSP3",32,0,random(-35,35));
		PLAY A 0 A_MonsterRefire(128,"CellEject");
		Goto Missile;
	CellEject:
		PLAY A 8;
		PLAY GG 3 A_SpawnItemEx("Cell",8,4,32,3,3,1,angle+5);
		PLAY A 3;
		Goto See;
	Rawkets:
		PLAY E 2;
		PLAY F 2 Bright A_CustomBulletAttack(5.6,0,1,5,"BulletPuff");
		PLAY E 2 A_Jump(32,"ActualRawk");
		PLAY A 0 A_CPosRefire;
		Goto Missile;
	ActualRawk:
		PLAY E 2;
		PLAY F 2 Bright A_CustomMissile("Rocket",32,0,random(-1,1));
		PLAY E 2;
		Goto Missile;
	Pain:
		PLAY G 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PLAY G 4 A_Pain;
		Goto See;
	Death:
		PLAY H 10;
		PLAY I 10 A_Scream;
		PLAY J 10 A_NoBlocking;
		PLAY I 10 A_PlaySound("*death");
		PLAY J 10;
		PLAY I 10 A_PlaySound("*death");
		PLAY J 10;
		PLAY I 10 A_PlaySound("*death");
		PLAY JKLM 10;
		PLAY M -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE (the Undertaker) and the bone economy.
// CH: Zombies.txt:2046-2786.
// ---------------------------------------------------------------------------
class RS_ThePlanBoner : Actor   // CH Zombies.txt:2046 -- the egg every marked corpse hatches
{
	Default
	{
		Health 45;
		Radius 8;
		Height 16;
		Mass 1;
		Speed 1;
		Monster;
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOBLOCKMONST
		+FLOAT
		+FLOATBOB
		+NORADIUSDMG
		Translation "0:255=[129,129,129]:[255,255,255]";
	}
	States
	{
	Spawn:
		BBBN A 3;
		Goto Hatch;
	Hatch:
		BBBN BCDABCD 5;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 3 Bright A_SpawnItemEx("RS_MrBones",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death2;
	Death:
		MISL B 0 A_SetScale(0.4,0.4);
		MISL BCD 3;
		Stop;
	Death2:
		TNT1 A 1;
		Stop;
	}
}

class RS_BoneGibWhite : Actor   // CH Zombies.txt:2082
{
	Default
	{
		Radius 2;
		Height 3;
		Projectile;
		Damage 1;
		Speed 1;
		BounceType "Doom";        // CH: +DOOMBOUNCE (DECORATE compat flag)
		+MOVEWITHSECTOR
		+CANNOTPUSH
		-NOGRAVITY
		+NOTONAUTOMAP
		+DONTHARMCLASS
		BounceFactor 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Wee;
	Wee:
		BBBN ABCD random(3,6);
		Loop;
	Crash:
		BBBN AAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	Death:
		BBBN AAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_MrBones : Actor   // CH Zombies.txt:2114 -- "The ride"
{
	int user_ILive;
	int user_IDie;
	Default
	{
		HitObituary "%o's funnybone was tickled by a skeleton";
		Health 50;
		PainChance 180;
		Speed 12;
		Radius 24;
		GibHealth -60;
		Height 56;
		Mass 100;
		Scale 0.9;
		SeeSound "skelsit";
		PainSound "skelpai";
		DeathSound "skeldth";
		Species "UnderTaker";
		Monster;
		+NOBLOOD
		+LOOKALLAROUND
		-ACTIVATEMCROSS
		+NOBLOCKMONST
		+NOFEAR
		+DONTDRAIN
		+NOCLIP
		-COUNTKILL
		+DONTHARMSPECIES
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_Shell", 64;
		DropItem "RS_CH_RocketAmmo", 32;
		DropItem "RS_CH_Cell", 12;
		Tag "The ride";
	}
	States
	{
	Spawn:
		SKLT R 10 A_Look;
		Loop;
	See:
		SKLT AABB 2 A_Chase("Melee",null,CHF_STOPIFBLOCKED);   // CH: "" for no missile state; ZScript wants null
		SKLT A 0 { bNOCLIP = false; }
		SKLT A 0 A_CheckBlock("IStuck",CBF_DROPOFF);
		SKLT DDCC 2 A_Chase("Melee",null,CHF_STOPIFBLOCKED);
		SKLT A 0 A_CheckBlock("IStuck",CBF_DROPOFF);
		SKLT EEFF 2 A_Chase("Melee",null,CHF_STOPIFBLOCKED);
		SKLT A 0 A_CheckBlock("IStuck",CBF_DROPOFF);
		SKLT A 0 { user_IDie = user_IDie - 1; }
		Loop;
	IStuck:
		SKLT A 0 A_JumpIf(user_IDie >= 12, "GiveUp");
		SKLT A 5 { bNOCLIP = true; }
		SKLT A 0 { user_IDie = user_IDie + 2; }
		SKLT ABDC 1 A_Wander;
		SKLT A 1;
		Goto See;
	Melee:
		SKLT GH 4 A_FaceTarget;
		SKLT I 4 A_PlaySound("skelatt",CHAN_AUTO);
		SKLT J 4 A_CustomMeleeAttack(random(1,6)*4,"swordhit","none");
		SKLT K 4 A_FaceTarget;
		Goto See;
	Pain:
		SKLT L 2;
		SKLT L 2 A_Pain;
		Goto See;
	Death:
		SKLT M 4 A_Scream;
		SKLT N 4 A_Fall;
		SKLT O 8 A_NoBlocking;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SKLT P 0 A_RadiusGive("Health",528,RGF_MONSTERS,random(12,128),"RS_WhiteZombie1");
		SKLT P 0 A_RadiusGive("RS_BoneUp2",528,RGF_MONSTERS,1,"RS_WhiteZombie1");
		SKLT P 12 A_RadiusGive("RS_BoneUp",528,RGF_MONSTERS,1,"RS_WhiteZombie1");
		SKLT Q 450 CanRaise;
		Goto Vanish;
	GiveUp:
		SKLT MN 8;
		SKLT O 10;
		SKLT P 14;
		Goto Vanish;
	Vanish:
		SKLT Q 20 A_FadeOut(0.3);
		SKLT Q 15 A_FadeOut(0.3);
		SKLT Q 10 A_FadeOut(0.3);
		Stop;
	XDeath:
		TNT1 A 1 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_BoneGibWhite",0,0,3,frandom(-180,180),frandom(-180,180),frandom(-180,180),frandom(-180,180),SXF_NOCHECKPOSITION);
		Stop;
	Raise:
		SKLT P 0 A_JumpIf(user_ILive >= 2, "Revenante");
		SKLT PONM 4;
		SKLT A 1 { user_ILive = user_ILive + 1; }
		Goto See;
	Revenante:
		SKLT PO 2 Bright;
		TNT1 AAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SKLT PONPON 3 Bright;
		TNT1 AAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: A_SpawnItemEx("CommonRevenant",...) -- revenant family not imported yet.
		// Guarded so it activates the day RS_CommonRevenant exists. The class
		// name is assembled at runtime because a literal unknown class name
		// is a compile error.
		TNT1 A 0 { class<Actor> cls = (class<Actor>)(String.Format("RS_%s","CommonRevenant")); if (cls) A_SpawnItemEx(cls,0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET); }
		Stop;
	}
}

class RS_BoneUp : Inventory { Default { Inventory.MaxAmount 30; } }   // CH Zombies.txt:2219

class RS_BoneUp2 : CustomInventory   // CH Zombies.txt:2221
{
	Default
	{
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
	}
	States
	{
	Pickup:
		TNT1 AAAAAA 1 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 2 A_SpawnItemEx("RS_SpirZom",0,0,38,0,0,2,0,SXF_SETMASTER);
		TNT1 A 2 A_PlaySound("ice/Cast");
		Stop;
	}
}

class RS_SpirZom : Actor   // CH Zombies.txt:2236
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+FLOATBOB
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Follow:
		SPIR ABC 4 Bright A_Warp(AAPTR_MASTER,0,0,38);
		SPIR C 2 A_SpawnItemEx("RS_SpirZom2",random(-15,15),random(-15,15),0,0,0,0,random(-15,15),SXF_NOCHECKPOSITION);
		SPIR DE 4 Bright A_Warp(AAPTR_MASTER,0,0,38);
		SPIR E 2 A_SpawnItemEx("RS_SpirZom2",random(-15,15),random(-15,15),0,0,0,0,random(-15,15),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_SpirZom2 : Actor   // CH Zombies.txt:2260
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+FLOAT
		Alpha 1;
		Scale 0.4;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Follow:
		HUWZ A 3 Bright;
		HUWZ A 3 Bright ThrustThingZ(0,6,0,0);
		HUWZ AAA 4 Bright A_FadeOut(0.25);
		Stop;
	}
}

class RS_WhiteZombie1 : Actor   // CH Zombies.txt:2282 -- UNDERTAKER
{
	int user_skel1;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 2800;
		Radius 16;
		Height 56;
		Mass 100;
		Speed 10;
		PainChance 16;
		Species "UnderTaker";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+BOSS
		+QUICKTORETALIATE
		+FLOORCLIP
		+LOOKALLAROUND
		+MISSILEMORE
		+NOTARGET
		-NORADIUSDMG
		+NOFEAR
		+DONTMORPH
		+DONTHARMSPECIES
		+DONTHARMCLASS
		Translation "205:205=192:192","206:206=88:88","207:207=93:93","241:241=99:99","242:242=103:103","6:6=102:102","5:5=109:109","243:243=110:110","250:254=152:158","164:167=107:111","0:0=0:0","125:125=112:112";
		DeathSound "Under/Die";
		SeeSound "Under/See";
		PainSound "skelpai";
		Obituary "Hey %o , the demons called the undertaker~";
		HitObituary "Shovel to the face?";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_MegaSphere", 72;
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: DropItem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLDemonicWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLLegendaryWeaponSpawner",4 -- DRLA stripped per owner 2026-08-05
		// CH: DropItem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		Tag "UNDERTAKER";
	}
	States
	{
	Spawn:
		MAGE A 1;
		Goto Scripted;
	Scripted:
		MAGE A 1;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteZombie") -- announcers dropped per owner
		MAGE A 1 A_RadiusGive("RS_CHBoner",16383,RGF_NOSIGHT|RGF_MONSTERS);
		Goto Idle;
	Idle:
		MAGE A 4 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		MAGE E 0 A_JumpIfInventory("RS_BoneUp",12,"Buff3");
		MAGE E 0 A_JumpIfInventory("RS_BoneUp",9,"Buff2");
		MAGE E 0 A_JumpIfInventory("RS_BoneUp",5,"Buff1");
		MAGE ABCD 4 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MAGE A 0 A_Jump(128,"See2");
		Loop;
	See2:
		MAGE ABCD 4 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MAGE A 0 A_Jump(128,"See");
		Loop;
	Melee:
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MAGE E 0 A_JumpIf(user_skel1 == 4,"FinalForm");
		MAGE E 0 A_JumpIfCloser(550,"Shovel",true);
		MAGE E 0 A_JumpIfCloser(1250,"MedRange");
		MAGE E 0 A_Jump(255,"RapidBone");
		Goto See;
	FinalForm:
		MAGE E 0 A_JumpIfCloser(550,"Close2",true);
		MAGE E 0 A_JumpIfCloser(1250,"MedRange2");
		MAGE E 0 A_Jump(255,"RapidBone3");
		Goto See;
	Close2:
		MAGE E 0 A_Jump(255,"ShotBone3","Shovel");
		Goto See;
	MedRange2:
		MAGE E 0 A_Jump(255,"ShotBone3","BoneTornado","RapidBone3");
		Goto See;
	BoneTornado:
		MAGE E 9 A_FaceTarget;
		MAGE E 7 Bright A_PlaySound("Under/Goodie",7,2,false,ATTN_NONE);
		MAGE E 7;
		MAGE E 5 Bright;
		MAGE E 5;
		MAGE E 3 Bright;
		MAGE E 3;
		MAGE F 5 Bright A_CustomMissile("RS_BoneTorn2",4,0,random(-64,64));
		MAGE F 3 Bright;
		MAGE E 3;
		Goto See;
	RapidBone3:
		MAGE E 7 A_FaceTarget;
		MAGE F 1 Bright;
		MAGE FFF 1 Bright A_CustomMissile("RS_BoneProjZM3",random(34,40),random(-1,1),random(-2,2),32,random(-1,1));
		MAGE F 1 A_MonsterRefire(120,"See");
		Goto RapidBone3+1;
	ShotBone3:
		MAGE E 8 A_FaceTarget;
		MAGE F 5 Bright;
		MAGE FFFFFFFFFFF 0 A_CustomMissile("RS_BoneProjZM3",random(32,42),random(-5,5),random(-12,12),32,random(-3,3));
		MAGE E 5;
		Goto See;
	MedRange:
		MAGE E 0 A_Jump(255,"ShotBone","RapidBone");
		Goto See;
	ShotBone:
		MAGE E 8 A_FaceTarget;
		MAGE F 6 Bright A_JumpIf(user_skel1 == 3,"ShotBone2");
		MAGE FFFFFFFFF 0 A_CustomMissile("RS_BoneProjZM",random(32,42),random(-5,5),random(-12,12),32,random(-3,3));
		MAGE E 5;
		Goto See;
	ShotBone2:
		MAGE FFFFFFFFFFFF 0 A_CustomMissile("RS_BoneProjZM2",random(32,42),random(-5,5),random(-12,12),32,random(-3,3));
		MAGE E 5;
		Goto See;
	RapidBone:
		MAGE E 0 A_JumpIf(user_skel1 == 3,"RapidBone2");
		MAGE E 7 A_FaceTarget;
		MAGE F 1 Bright;
		MAGE FF 1 Bright A_CustomMissile("RS_BoneProjZM",random(34,40),random(-2,2),random(-5,5),32,random(-1,1));
		MAGE F 0 A_Jump(12,"ShotBone");
		MAGE F 2 A_MonsterRefire(150,"See");
		Goto RapidBone+2;
	RapidBone2:
		MAGE E 7 A_FaceTarget;
		MAGE F 1 Bright;
		MAGE FF 1 Bright A_CustomMissile("RS_BoneProjZM2",random(34,40),random(-1,1),random(-3,3),32,random(-1,1));
		MAGE F 0 A_Jump(12,"ShotBone2");
		MAGE F 1 A_MonsterRefire(120,"See");
		Goto RapidBone2+1;
	Shovel:
		MAGE E 7 A_FaceTarget;
		MAGE F 7 Bright A_PlaySound("Spell/SpellCast1");
		MAGE F 0 A_CustomMissile("RS_ShoveZM",38,0,0);
		MAGE F 0 A_CustomMissile("RS_ShoveZM",38,3,5);
		MAGE F 0 A_CustomMissile("RS_ShoveZM",38,-3,-5);
		MAGE E 0 A_JumpIf(user_skel1 == 3,"ShotBone2");
		MAGE E 6 A_Jump(128,"Missile","ShotBone");
		Goto See;
	Reset:
		MAGE A 0;
		Goto See+3;
	Buff1:
		MAGE A 0 A_JumpIf(user_skel1 >= 2,"Reset");
		MAGE A 0 A_PlaySound("Under/Goodie",7,2,false,ATTN_NONE);
		MAGE AAAAAAAAAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		MAGE E 1 { bMISSILEEVENMORE = true; }
		MAGE E 1 { user_skel1 = user_skel1 + 2; }
		MAGE E 5 A_SetSpeed(16);
		MAGE E 0 A_SetScale(1.1,1.1);
		Goto See+3;
	Buff2:
		MAGE A 0 A_JumpIf(user_skel1 >= 3,"Reset");
		MAGE A 0 A_PlaySound("Under/Goodie",7,2,false,ATTN_NONE);
		MAGE AAAAAAAAAAAAAAA 0 A_SpawnParticle("Yellow",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		MAGE E 1 { user_skel1 = user_skel1 + 1; }
		MAGE E 1 A_SetSpeed(21);
		MAGE E 6 A_SetScale(1.25,1.25);
		Goto See+3;
	Buff3:
		MAGE A 0 A_JumpIf(user_skel1 >= 4,"Reset");
		MAGE A 0 A_PlaySound("Under/Goodie",7,2,false,ATTN_NONE);
		MAGE AAAAAAAAAAAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		MAGE E 0 { bNOPAIN = true; }
		MAGE E 1 { user_skel1 = user_skel1 + 1; }
		MAGE E 8 A_SetSpeed(28);
		MAGE E 0 A_SetScale(1.45,1.45);
		MAGE E 12;
		Goto See+3;
	Pain:
		MAGE G 4;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MAGE G 4 A_Pain;
		Goto See;
	Death:
		MAGE H 13;
		MAGE I 13 A_Scream;
		MAGE J 13 A_NoBlocking;
		MAGE KLM 13;
		MAGE N -1;
		Stop;
	}
}

// --- Bone projectiles.  CH: Zombies.txt:2475-2786 ---------------------------
class RS_BoneTorn2 : Actor   // CH Zombies.txt:2475 -- the bone tornado
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 18;
		Mass 25;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+DONTBLAST
		+DONTTHRUST
		+BOUNCEONWALLS
		+INVISIBLE
		BounceCount 999;
		BounceType "Doom";
		BounceFactor 1;
		WallBounceFactor 1.1;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.75;
		Scale 1;
	}
	States
	{
	Spawn:
		RNGG AB 1 Bright A_Wander;
		RNGG CCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer1",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 0 A_SpawnItemEx("RS_BoneStormer3",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer2",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer4",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 0 A_SpawnItemEx("RS_BoneStormer5",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer6",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCDD 1 Bright A_CustomMissile("RS_BoneProjZM3",4,random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		RNGG CCCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer7",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer1",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG AB 1 Bright A_Wander;
		RNGG CCCCCCCCC 0 A_SpawnItemEx("RS_BoneStormer3",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 1 Bright A_SpawnItemEx("RS_BoneStormer2",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer4",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 0 A_SpawnItemEx("RS_BoneStormer5",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer6",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer7",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCDD 1 Bright A_CustomMissile("RS_BoneProjZM3",4,random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		RNGG AB 1 Bright A_Wander;
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer4",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 0 A_SpawnItemEx("RS_BoneStormer5",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer6",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 1 Bright A_SpawnItemEx("RS_BoneStormer7",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer1",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 0 A_SpawnItemEx("RS_BoneStormer3",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer2",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer4",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 0 A_SpawnItemEx("RS_BoneStormer5",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer6",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG AB 1 Bright A_Wander;
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer7",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCDD 1 Bright A_CustomMissile("RS_BoneProjZM3",4,random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer1",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 0 A_SpawnItemEx("RS_BoneStormer3",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer2",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG AB 1 Bright A_Wander;
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer4",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCC 0 A_SpawnItemEx("RS_BoneStormer5",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer6",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCCCCC 1 Bright A_SpawnItemEx("RS_BoneStormer7",0,0,4,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
		RNGG CCDD 1 Bright A_CustomMissile("RS_BoneProjZM3",4,random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		RNGG D 0 A_Jump(8,"Death");
		Loop;
	Death:
		RNGG ABCD 4 Bright;
		Stop;
	}
}

class RS_BoneStormer1 : Actor   // CH Zombies.txt:2549
{
	int user_angle;
	Default
	{
		Radius 8;
		Height 8;
		DamageFunction (random(1,3));
		Speed 120;
		Projectile;
		+BLOODLESSIMPACT
		+RIPPER
		+FORCEPAIN
		Scale 0.75;
		Translation "0:255=[129,129,129]:[255,255,255]";
		DeathSound "Ice/Fly";
	}
	States
	{
	Spawn:
		BBBN A 1 Bright NoDelay A_Warp(AAPTR_MASTER,32,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(8,"Death");
		Loop;
	Death:
		TNT1 AAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		MISL B 0 A_SetScale(0.3,0.3);
		MISL BCD 3;
		Stop;
	}
}

class RS_BoneStormer2 : RS_BoneStormer1   // CH Zombies.txt:2579
{
	Default { Speed 105; }
	States
	{
	Spawn:
		BBBN B 1 Bright NoDelay A_Warp(AAPTR_MASTER,28,0,28,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(4,"Death");
		Loop;
	}
}

class RS_BoneStormer3 : RS_BoneStormer1   // CH Zombies.txt:2592
{
	Default { Speed 115; }
	States
	{
	Spawn:
		BBBN A 1 Bright NoDelay A_Warp(AAPTR_MASTER,12,0,10,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(4,"Death");
		Loop;
	}
}

class RS_BoneStormer4 : RS_BoneStormer1   // CH Zombies.txt:2605
{
	Default { Speed 130; }
	States
	{
	Spawn:
		BBBN C 1 Bright NoDelay A_Warp(AAPTR_MASTER,44,0,64,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(4,"Death");
		Loop;
	}
}

class RS_BoneStormer5 : RS_BoneStormer1   // CH Zombies.txt:2618
{
	Default { Speed 125; }
	States
	{
	Spawn:
		BBBN D 1 Bright NoDelay A_Warp(AAPTR_MASTER,56,0,88,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(4,"Death");
		Loop;
	}
}

class RS_BoneStormer6 : RS_BoneStormer1   // CH Zombies.txt:2631
{
	Default { Speed 130; }
	States
	{
	Spawn:
		BBBN A 1 Bright NoDelay A_Warp(AAPTR_MASTER,68,0,102,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(4,"Death");
		Loop;
	}
}

class RS_BoneStormer7 : RS_BoneStormer1   // CH Zombies.txt:2644
{
	Default { Speed 155; }
	States
	{
	Spawn:
		BBBN B 1 Bright NoDelay A_Warp(AAPTR_MASTER,80,0,128,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_Jump(4,"Death");
		Loop;
	}
}

class RS_BoneProjZM : Actor   // CH Zombies.txt:2657 -- thrown bone; drops ammo on death
{
	Default
	{
		Radius 8;
		Height 8;
		DamageFunction (random(4,16));
		Speed 32;
		Projectile;
		+BLOODLESSIMPACT
		+SKYEXPLODE
		+FORCEPAIN
		Scale 0.75;
		Translation "0:255=[129,129,129]:[255,255,255]";
		SeeSound "skelatt";
		DeathSound "swordhit";
		DropItem "RS_implyingclip", 48;
		DropItem "RS_CH_Shell", 32;
		DropItem "RS_CH_Cell", 16;
		DropItem "RS_CH_RocketAmmo", 8;
	}
	States
	{
	Spawn:
		BBBN ABCD 4;
		Loop;
	Death:
		TNT1 AAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		MISL B 0 A_SetScale(0.3,0.3);
		MISL BCD 3;
		MISL D 0 A_SpawnItemEx("RS_MrBones",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,250);
		Stop;
	}
}

class RS_BoneProjZM2 : RS_BoneProjZM   // CH Zombies.txt:2690
{
	Default
	{
		DamageFunction (random(8,20));
		Speed 36;
	}
}

class RS_BoneProjZM3 : RS_BoneProjZM   // CH Zombies.txt:2696
{
	Default
	{
		DamageFunction (random(12,26));
		Speed 40;
	}
}

class RS_ShoveZM : Actor   // CH Zombies.txt:2702 -- the shovel throw
{
	Default
	{
		Radius 6;
		Height 8;
		DamageFunction (random(10,45));
		DamageType "Melee";
		Speed 25;
		Scale 2;
		Decal "BulletChip";
		AttackSound "skelsit4";   // undefined in CH's own SNDINFO too -- silent, verbatim
		DeathSound "moloch/nailhitbleed";
		Projectile;
		+SPAWNSOUNDSOURCE
		+EXTREMEDEATH
		+BLOODSPLATTER
	}
	States
	{
	Spawn:
		BLAD AA 2 Bright A_CustomMissile("RS_ShoveZM2",0,0);
		BLAD AAA 0 A_CustomMissile("RS_ShoveZM3",0,0);
		BLAD A 2 Bright A_CustomMissile("RS_ShoveZM2",0,0);
		BLAD AAA 0 A_CustomMissile("RS_ShoveZM2",0,0);
		BLAD A 3 Bright A_CustomMissile("RS_ShoveZM2",0,0);
		BLAD AA 0 A_CustomMissile("RS_ShoveZM3",0,3,-180);
		BLAD AA 0 A_CustomMissile("RS_ShoveZM3",0,-3,-180);
		BLAD A 3 Bright A_CustomMissile("RS_ShoveZM2",0,0);
		BLAD AAA 0 A_CustomMissile("RS_ShoveZM2",0,0,random(-190,-175),32,-6);
		BLAD AAA 0 A_CustomMissile("RS_ShoveZM2",0,0,random(-190,-175),32,6);
		BLAD AAA 0 A_CustomMissile("RS_ShoveZM3",0,3,random(-190,-175),32,-3);
		BLAD AAA 0 A_CustomMissile("RS_ShoveZM3",0,-3,random(-190,-175),32,3);
	Death:
		BLAD A 0 A_PlaySound("moloch/nailhit");
		BLAD A 1 Bright;
		6PUF ABCDEF 1 Bright;
		FBL1 EFG 1 Bright A_Explode(random(5,20),64);
		TNT1 A 0 A_SpawnItemEx("RS_MrBones",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		Stop;
	}
}

class RS_ShoveZM2 : Actor   // CH Zombies.txt:2742
{
	Default
	{
		Radius 6;
		Height 8;
		DamageFunction (random(1,5));
		DamageType "Melee";
		Alpha 0.75;
		Speed 25;
		Scale 1.8;
		Decal "BulletChip";
		AttackSound "moloch/nailhitbleed";
		Projectile;
		+SPAWNSOUNDSOURCE
		+EXTREMEDEATH
		+BLOODSPLATTER
	}
	States
	{
	Spawn:
		BLAD AAAA 3 Bright;
	Death:
		BLAD AA 1 Bright;
		BLAD AAAA 1 Bright A_FadeOut(0.15);
		FBL1 G 1 Bright A_FadeOut(0.15);
		Stop;
	}
}

class RS_ShoveZM3 : RS_ShoveZM2   // CH Zombies.txt:2770
{
	Default
	{
		Speed 27;
		DamageFunction (random(3,12));
		DamageType "Melee";
		Scale 1.55;
	}
	States
	{
	Spawn:
		BLAD AA 2 Bright;
	Death:
		BLAD A 1 Bright A_FadeOut(0.15);
		BLAD A 1 Bright A_FadeOut(0.15);
		FBL1 G 1 Bright A_FadeOut(0.15);
		Stop;
	}
}
