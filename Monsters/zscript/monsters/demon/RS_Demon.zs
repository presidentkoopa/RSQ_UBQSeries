// ============================================================================
// RS_Demon.zs -- Colourful Hell Demon (Pinky) family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Demons.txt (2654 lines, read
// whole). Every actor cites its CH line. Support: RS_DemonFX.zs (see its
// header for cross-lane notes, proven-missing assets, and standing strips).
// Tier ladder as before: CH icon index -- 1 Common, 2 Green, 3 Blue,
// 4 Purple, 5 Yellow, 6 Red, 7 FireBlu, 8 Gray(worm), 9 Abyss(dog),
// 10 Black boss (Butcher), 11 White boss (Juggernaut), 12 Cyan(worm),
// 13 Brown. Minions (hounds, dash ghosts) get no token.
// RS_PinkDemon is CH's ORPHAN: defined at Demons.txt:19, spawned by nothing
// anywhere in CH's decorate. Imported whole anyway; its tier icon lines are
// commented out in CH itself (index 1) and its Raise jumps to a "Grow" label
// no PinkDemon ever defines -- both preserved as no-ops, documented at site.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Demons.txt:1 -- Colourset5 replaces Demon.
// ---------------------------------------------------------------------------
class RS_Colourset5 : RandomSpawner replaces Demon
{
	Default
	{
		DropItem "RS_CommonDemon", 255, 500;
		DropItem "RS_GreenDemon", 255, 400;
		DropItem "RS_CyanDemon", 255, 120;
		DropItem "RS_BrownDemon", 255, 100;
		DropItem "RS_BlueDemon", 255, 180;
		DropItem "RS_FireBluDemon", 255, 70;
		DropItem "RS_PurpleDemon", 255, 100;
		DropItem "RS_YellowDemon", 255, 55;
		DropItem "RS_AbyssDemon", 255, 40;
		DropItem "RS_GrayDemon", 255, 45;
		DropItem "RS_RedDemon", 255, 40;
		DropItem "RS_BlackDemon", 255, 3;
		DropItem "RS_WhiteDemon", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// CH's orphan.  CH: Demons.txt:19 -- "Pinkier", the LMLO fast walker.
// Referenced by nothing in CH; kept whole per the import-everything rule.
// ---------------------------------------------------------------------------
class RS_PinkDemon : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }   // CH's own (commented-out) icon is index 1
	Default
	{
		Health 500;
		PainChance 150;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 11;
		Radius 30;
		Height 56;
		Damage 7;   // bare constant stays bare
		Mass 2000;
		Monster;   // CH lists "Monster" twice (Demons.txt:33,52)
		+FLOORCLIP
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "blooddemon/sight";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o was rushed by pink walker";
		DropItem "RS_CH_Berserk";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_ShellBox";
		DropItem "Chainsaw";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "BackPack";
		Translation "0:255=%[0.50,0.02,0.28]:[1.95,1.22,2.00]";
		Tag "Pinkier";
	}
	States
	{
	Spawn:
		LMLO AB 10 A_Look;
		// CH (commented out there too): TNT1 A 0 A_SpawnItemEx("ColorTierIconCH",...)
		Loop;
	See:
		LMLO AABB 2 Fast A_Chase;
		// CH (commented out): tier icon
		LMLO CCDD 2 Fast A_Chase;
		// CH (commented out): tier icon
		Loop;
	Missile:
		TNT1 A 0 A_JumpIfCloser(100,"Melee2");
	DashFaster:
		LMLO AABB 1 A_Chase;
		LMLO CCDD 1 A_Chase;
		TNT1 A 0 A_JumpIfCloser(1000,"DashFaster");
		Goto See;
	Melee2:
		LMLO AB 2 Fast A_FaceTarget;
		LMLO CD 2 Fast A_SkullAttack(20);
		Goto See;
	Pain:
		LMLO E 2 Fast;
		// CH (commented out): tier icon
		LMLO N 2 Fast A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		LMLO F 8;
		LMLO G 8 A_Scream;
		LMLO H 4;
		LMLO I 4 A_NoBlocking;
		LMLO J 4;
		LMLO H 4;
		LMLO M -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported (owner: vanilla gore ok)
		POSS PPPPPP 1;   // CH: each P spawned a CHRandom_GibGenerator
		// CH: TNT1 AA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS R 4 A_XScream;
		// CH: TNT1 A 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS S 5;
		POSS T 4 A_NoBlocking;
		POSS UUUUU 1 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Raise:
		LMLO M 5 { if (CountInv("RS_GrowRaisin") >= 1) { state s = FindState("Grow"); if (s) return s; } return ResolveState(null); }   // CH: A_JumpIfInventory("GrowRaisin",1,"Grow") -- no Grow label exists on PinkDemon in CH; guarded so the no-op survives without naming a missing state
		LMLO KJIHGF 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families.
// ---------------------------------------------------------------------------
class RS_BrownDemon : Actor   // CH Demons.txt:115 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset5",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanDemon : Actor   // CH Demons.txt:360 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset5",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluDemon : Actor   // CH Demons.txt:513 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset5",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssDemon : Actor   // CH Demons.txt:646 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset5",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayDemon : Actor   // CH Demons.txt:862 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset5",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GreyDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackDemon : Actor   // CH Demons.txt:1775 -- gate CH_BlackBossy (no EX variant in this family)
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackDemon3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedDemon",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteDemon : Actor   // CH Demons.txt:2105 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackDemon",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN ("Brownie").  CH: Demons.txt:137.  The dasher: afterimage
// blink-rush under a protection powerup, sniper orb, close-range flame chain,
// and a death cry that hands the pack the BrownImpCommand buff.
// ---------------------------------------------------------------------------
class RS_BrownDemon2 : Actor
{
	int user_Calm;   // CH: Var int User_Calm
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 420;
		BloodColor "blue";
		PainChance 33;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 1.25;
		PainChance "DIMp", 0;
		Speed 17;
		Radius 30;
		Height 56;
		Damage 2;   // bare constant stays bare
		Mass 800;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "blooddemon/sight";
		PainSound "blooddemon/pain";
		DeathSound "weapons/rocklx";
		ActiveSound "blooddemon/active";
		Obituary "%o got crunched by brown demon";
		DropItem "RS_CH_Berserk", 50;
		MeleeRange 64;
		Translation "94:111=%[0.10,0.05,0.00]:[1.17,0.39,0.20]","80:93=%[0.20,0.10,0.00]:[0.98,0.57,0.34]";
		Tag "Brownie";
	}
	States
	{
	Spawn:
		IFN2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		IFIN A 0 A_PlaySound("BrownDemon/Step");
		IFIN AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"MaybeDash");
		TNT1 A 0;
		IFIN C 0 A_PlaySound("BrownDemon/Step");
		IFIN CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFN2 A 0 A_JumpIf(user_Calm == 1,"Calm");
		Loop;
	MaybeDash:
		TNT1 A 0 A_JumpIfInTargetLOS("Dash",0,JLOSF_DEADNOJUMP,1200,200);
		Goto See+7;
	Dash:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("NoPain",true)
		TNT1 A 0 A_GiveInventory("RS_HKEXProtect",1);
		IFIN G 1 A_SetSpeed(40);
		IFIN AB 1 A_Wander;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFIN C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFIN C 0 A_PlaySound("BrownDemon/Step");
		IFIN CD 1 A_Chase(null,null);   // CH: a_chase("","")
		// CH: IFN2 C -- CH mixes IFIN C and IFN2 C through this dash at random (Demons.txt:193-217) and only IFN2 A/B were ever drawn, in either tree. Re-verified frame by frame 2026-08-06: all 12 IFN2 C states here, and the IFN2 F below, are 0-tic, so the renderer never displays one; the visible dash is entirely the IFIN frames. Nothing invisible, nothing to remap -- left verbatim. See RS_DemonFX.zs header.
		IFN2 C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		IFIN AB 1 A_Chase(null,null);
		IFN2 C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		IFIN CD 1 A_Chase(null,null);
		IFIN C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		IFIN AB 1 A_Wander;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFN2 C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		IFIN CD 1 A_Chase(null,null);
		IFN2 C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		IFIN AB 1 A_Chase(null,null);
		IFN2 C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		IFIN CD 1 A_Chase(null,null);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFN2 C 0 A_SpawnItemEx("RS_BrownDemonGhost",0,0,6,0,0,0,0);
		IFN2 C 0 A_PlaySound("BrownDemon/Step");
		TNT1 A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag("NoPain",false)
		TNT1 A 0 A_TakeInventory("RS_HKEXProtect",1);
		IFIN G 1 A_SetSpeed(18);
		Goto See;
	Missile:
		IFN2 F 0 { user_Calm = (user_Calm == 1) ? 1 : 0; }   // CH: A_SetUserVar("User_Calm",User_Calm == 1) -- CH: IFN2 F (Demons.txt:223), no IFN2F lump in either tree; 0-tic, never drawn, so nothing to remap. Verified 2026-08-06.
		TNT1 A 0 A_JumpIfCloser(120,"ChainFlame");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFIN E 8 Bright A_FaceTarget;
		IFIN F 1 Bright A_PlaySound("SNPRFIRE");
		IFIN F 6 Bright A_CustomMissile("RS_BrownOrbDemon",32,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFIN G 3 Bright;
		IFIN G 9;
		Goto See;
	ChainFlame:
		TNT1 A 0 A_JumpIfCloser(120,"ChainFlame2");
		Goto See;
	ChainFlame2:
		IFIN E 2 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFIN F 1 Bright A_CustomMissile("RS_RedDemonBloodBolt3",32,0,random(-7,7));   // defined by the spectre lane (CH spectres.txt:1031)
		IFIN F 1 Bright A_MonsterRefire(128,"See");
		Goto ChainFlame;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		IFIN G 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		IFIN G 2 A_Pain;
		IFIN G 1 A_Jump(174,"SpeedBuff");
		Goto See;
	Pain.fire:
		IFIN G 3 Bright A_Pain;
		Goto SpeedBuff;
	SpeedBuff:
		IFIN G 1 A_SetSpeed(30);
		IFIN G 1 { user_Calm = (user_Calm == 0) ? 1 : 0; }   // CH: A_SetUserVar("User_Calm",User_Calm == 0)
		Goto See;
	Calm:
		IFIN G 2 A_SetSpeed(16);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		IFIN H 8;
		IFIN I 0 A_FaceTarget;
		IFIN I 8 A_Scream;
		IFIN J 4 A_Explode(random(5,32),64,0);
		IFIN K 4 A_NoBlocking;
		IFIN LM 4;
		TNT1 A 0 A_RadiusGive("RS_BrownImpCommand",320,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownDemon2","Demon1");
		IFIN N -1;
		Stop;
	Raise:
		IFIN NMLKJIH 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN ("Ice Worm").  CH: Demons.txt:382.  The burrower: hides
// flat, needle rings, warp-lunge hiss.
// ---------------------------------------------------------------------------
class RS_CyanDemon2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Obituary "%o was stored for winter by cyan demon";
		Health 270;
		PainChance 64;
		Speed 27;
		Radius 30;
		Height 56;
		Mass 400;
		Scale 0.95;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "Melee", 2.0;
		DamageFactor "Fire", 1.5;   // CH lists Fire twice (bare and quoted)
		DamageFactor "Ice", 0.15;   // CH lists Ice twice
		DamageFactor "PLWater", 0.25;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 82;
		PainChance "Melee", 12;
		Damage 3;   // bare constant stays bare
		Species "Demon1";
		SeeSound "slimeworm/sight";
		AttackSound "slimeworm/melee";
		PainSound "slimeworm/pain";
		DeathSound "slimeworm/death";
		ActiveSound "slimeworm/active";
		BloodColor "Blue";
		Monster;
		+THRUSPECIES
		+FLOORCLIP
		+NOTARGETSWITCH
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOTARGET
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOICEDEATH
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice
		DropItem "RS_CH_Chainsaw", 64;
		Tag "Ice Worm";
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
		MeleeRange 64;
	}
	States
	{
	Spawn:
		WORM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WORM AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM E 8 A_FaceTarget;
		WORM E 0 A_JumpIfCloser(72,"Melee");
		WORM E 8 A_JumpIfCloser(700,"Hiss");
	HideMe:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag(NOPAIN,TRUE)
		WORM G 2 A_SetScale(1.0,0.5);
		WORM G 2 A_SetScale(1.0,0.25);
		WORM G 2 A_SetScale(1.0,0.1);
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(0,90));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(89,180));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(181,270));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(271,359));
		WORM G 8 A_SetSpeed(77);
		WORM AABBCCDD 2 A_Wander;
		WORM AABBCCDD 1 A_Wander;
		WORM G 5 A_SetSpeed(25);
		WORM G 2 A_SetScale(1.0,0.25);
		WORM G 2 A_SetScale(1.0,0.5);
		WORM G 2 A_SetScale(1.0,1.0);
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(0,90));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(89,180));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(181,270));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(271,359));
		TNT1 A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag(NOPAIN,FALSE)
		Goto See;
	Melee:
		WORM EF 4 A_FaceTarget;
		TNT1 HHHHH 0 A_SpawnItemEx("RS_SpikeCyanRev",16,0,24,random(9,33),0,random(3,9),frandom(-9,9));
		TNT1 HHHHH 0 A_SpawnItemEx("RS_SpikeCyanRev",16,0,29,random(9,33),0,random(4,12),frandom(-4,4));
		WORM G 4 A_CustomMeleeAttack(random(25,75),"slimeworm/melee","none");
		Goto See;
	Hiss:
		WORM EF 4 A_FaceTarget;
		WORM G 8 A_SkullAttack(40);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		WORM H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM H 2 A_Pain;
		WORM H 2 A_Jump(232,"HideMe");
		Goto See;
	Death:
		WORM I 8;
		WORM J 8 A_Scream;
		WORM K 4;
		WORM L 4 A_NoBlocking(false);   // CH: A_NoBlocking(FALSE) -- deliberately drops nothing on plain death
		WORM M 4;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,254);
		WORM N 1 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU ("FireBluey").  CH: Demons.txt:532.  The slow tank that
// chain-rams.  The spectre lane's RS_FireBluSpectre2 inherits this class.
// ---------------------------------------------------------------------------
class RS_FireBluDemon2 : Demon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 205;
		Species "Demon1";
		BloodColor "blue";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 0.25;
		PainChance "DIMp", 0;
		Speed 5;
		Radius 30;
		Height 56;
		Mass 5000;
		XScale 1.33;
		YScale 0.75;
		Damage 1;   // bare constant stays bare
		Monster;
		+FLOORCLIP
		+NOTARGET
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o met some Fireblu meat";
		MeleeRange 64;
		Translation "0:64=%[1.95,0.56,0.59]:[0.69,0.08,0.09]","65:128=%[0.17,0.42,1.19]:[0.02,0.07,0.41]","129:192=%[1.95,0.56,0.59]:[0.69,0.08,0.09]","193:255=%[0.17,0.42,1.19]:[0.02,0.07,0.41]";   // CH line carries long commented-out alternates after this string
		Tag "FireBluey";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SARG AABB 4 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG CCDD 4 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG E 4 Bright A_JumpIfCloser(800,"Rush");
		SARG E 0;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Rush:
		SARG F 1 A_FaceTarget;
		SARG F 3 A_SkullAttack(20);
		SARG F 3 Fast A_FaceTarget;
		SARG F 3 A_SkullAttack(20);
		SARG F 3 Fast A_FaceTarget;
		SARG F 3 A_SkullAttack(20);
		SARG F 3 Fast A_FaceTarget;
		SARG F 3 A_SkullAttack(20);
		SARG F 3 Fast A_FaceTarget;
		SARG F 3 A_SkullAttack(20);
		Goto See;
	Melee:
		SARG EF 7 Fast A_FaceTarget;
		SARG G 8 Fast A_CustomMeleeAttack(random(15,50),"Demon/melee","none");
		Goto See;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		Goto See;
	Pain.fire:
		SARG H 1;
		Goto See;
	Death:
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS PPPPPP 1;   // CH: each P spawned a CHRandom_GibGenerator
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS R 4 A_XScream;
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS S 5;
		POSS AAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_FireSGguy2",0,0,3,random(3,9),0,2,random(-359,359),SXF_NOCHECKPOSITION,64);
		POSS T 4 A_NoBlocking;
		POSS UUUUUU 1 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_PurpleDemon",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS ("Bad dog").  CH: Demons.txt:669.  The near-invisible
// hound; fades in to bite, drips abyss the whole while.
// ---------------------------------------------------------------------------
class RS_AbyssDemon2 : Actor
{
	int user_hidd;   // CH: var int user_hidd
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 600;
		PainChance 128;
		Speed 19;
		Radius 30;
		Height 50;
		Mass 500;
		Species "Demon";   // note: "Demon", not "Demon1" -- CH's own choice
		DamageFactor "Fire", 1.25;
		DamageFactor "Ice", 0.75;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		RenderStyle "Add";
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+THRUSPECIES
		+NOFEAR
		Alpha 0.10;
		Obituary "%o was hunted down by abyss demon";
		HitObituary "%o is back on the menu, boys!";
		SeeSound "abydogse";
		AttackSound "monster/dogatk";
		MeleeSound "monster/dogbit";
		PainSound "abydoghu";
		DeathSound "abydogde";
		ActiveSound "abydogac";
		DropItem "RS_CH_Medikit";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_Cell";
		MeleeThreshold 150;
		Tag "Bad dog";
		Translation "32:47=0:0","168:191=0:0","80:95=0:0","3:4=0:0","96:111=0:0","64:79=%[0.02,0.02,0.03]:[0.29,0.49,0.65]","48:63=0:0";
	}
	States
	{
	Spawn:
		HDOG A 10 A_Look;
		Loop;
	See:
		HDOG AAAA 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG BBBB 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG CCCC 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG DDDD 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG EEEE 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG FFFF 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		Loop;
	See2:
		TNT1 A 0 A_JumpIf(user_hidd >= 1,"Rehide");
		HDOG AAAA 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG BBBB 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-8,8),random(-8,8),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG CCCC 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG DDDD 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-8,8),random(-8,8),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		HDOG EEEE 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		HDOG FFFF 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyssBubbleDemon",random(-8,8),random(-8,8),random(5,32),0,0,0,0,SXF_NOCHECKPOSITION,216);
		Loop;
	Rehide:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HDOG G 1 Bright;
		HDOG G 1 Bright A_SetTranslucent(0.70);
		HDOG G 1 Bright A_SetTranslucent(0.40);
		HDOG G 1 Bright A_SetTranslucent(0.10);
		HDOG G 1 { user_hidd = 0; }   // CH: a_setuservar("User_hidd",user_hidd = 0)
		Goto See2;
	Melee:
		HDOG G 2 A_SetTranslucent(1.00);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HDOG G 3 { user_hidd = user_hidd + 1; }   // CH: a_setuservar("User_hidd",user_hidd+1)
		HDOG H 4 A_FaceTarget;
		HDOG I 6 A_CustomMeleeAttack(random(17,58),"blooddemon/melee","none");
		HDOG I 1 A_Jump(86,"Missile");
		Goto See2;
	Missile:
		HDOG G 2 A_SetTranslucent(1.00);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HDOG G 3 { user_hidd = user_hidd + 1; }
		HDOG G 8 A_FaceTarget;
		HDOG H 1 A_CustomMissile("RS_AbyssDogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_AbyssDogFire",28,-5,-17,0,0);
		HDOG H 1 A_CustomMissile("RS_AbyssDogFire",28,5,17,0,0);
		HDOG I 6;
		Goto See2;
	Pain:
		HDOG J 1;
		HDOG J 1 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HDOG J 1 A_SetTranslucent(1.00);
		HDOG J 2 { user_hidd = user_hidd + 1; }
		Goto See2;
	Death:
		HDOG K 8;
		HDOG L 8 A_Scream;
		HDOG M 4;
		HDOG N 4 A_NoBlocking;
		HDOG OP 4;
		HDOG Q -1;
		Stop;
	Raise:
		HDOG QPONMLK 5;
		Goto See2;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY ("Coiling menace").  CH: Demons.txt:881.  The wrap worm:
// warps onto you, drains, heals itself.
// ---------------------------------------------------------------------------
class RS_GreyDemon2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Obituary "%o was questionably assimilated by gray demon worm";
		Health 700;
		PainChance 32;
		Speed 16;
		Radius 30;
		Height 56;
		Mass 400;
		Scale 0.65;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "Demon1";
		SeeSound "slimeworm/sight";
		AttackSound "slimeworm/melee";
		PainSound "slimeworm/pain";
		DeathSound "slimeworm/death";
		ActiveSound "slimeworm/active";
		BloodColor "Black";
		Monster;
		+THRUSPECIES
		+FLOORCLIP
		+NOTARGETSWITCH
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOTARGET
		+MISSILEMORE
		+SHORTMISSILERANGE
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice
		DropItem "RS_implyingclip", 174;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Berserk", 128;
		Tag "Coiling menace";
		Translation "16:47=91:111","232:235=152:159","208:223=0:0","64:79=96:111","176:191=96:111","160:167=96:111","224:231=0:0";
	}
	States
	{
	Spawn:
		WORM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WORM AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM E 8 A_FaceTarget;
		WORM E 0 A_JumpIfCloser(72,"Wrap");
		WORM E 8 A_JumpIfCloser(900,"AllyOp");
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag(NOPAIN,TRUE)
		WORM G 8 A_SetSpeed(50);
		WORM AABBCCDD 2 A_Wander;
		WORM G 5 A_SetSpeed(16);
		TNT1 A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag(NOPAIN,FALSE)
		Goto See;
	Melee:
		WORM EF 3 A_FaceTarget;
		WORM G 3 A_JumpIfCloser(72,"Wrap");
		Goto See;
	Wrap:
		WORM H 1 A_Warp(AAPTR_TARGET,random(-1,3),0,12,random(-45,45),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_PlaySound("slimeworm/melee",4);
		WORM E 1 A_Warp(AAPTR_TARGET,random(-1,3),0,12,random(-45,45),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_CustomMissile("RS_WormLewd",12,0,0);
		TNT1 A 0 HealThing(5,99);
		TNT1 A 0 A_JumpIfTargetInLOS("See",1);
		WORM HEHEHEHEHEHEHEHEHEHE 1 A_Warp(AAPTR_TARGET,random(-1,3),0,12,random(-45,45),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	AllyOp:
		WORM F 10 A_SkullAttack(45);
		WORM F 10 A_JumpIfCloser(32,"Wrap");
		WORM G 10 A_Stop;
		Goto Missile;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		WORM H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM H 2 A_Pain;
		Goto See;
	Death:
		WORM I 8;
		WORM J 8 A_Scream;
		WORM K 4;
		WORM L 4 A_NoBlocking;
		WORM M 4;
		WORM N -1;
		Stop;
	Raise:
		WORM NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON ("Pinky").  CH: Demons.txt:1024.  Vanilla-plus stats.
// ---------------------------------------------------------------------------
class RS_CommonDemon : Demon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		PainChance 150;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "Demon1";
		MeleeRange 54;
		GibHealth -70;
		Monster;
		Tag "Pinky";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SARG AABB 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG CCDD 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		SARG EF 8 Fast A_FaceTarget;
		SARG G 8 Fast A_SargAttack;
		Goto See;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS PPPPPP 1;   // CH: each P spawned a CHRandom_GibGenerator
		// CH: TNT1 AA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS R 4 A_XScream;
		// CH: TNT1 A 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS S 5;
		POSS T 4 A_NoBlocking;
		POSS UUUUU 1 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_GreenDemon",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN ("Greeny").  CH: Demons.txt:1108.  44/256 of its plain
// deaths detonate into the gas-and-slime web.
// ---------------------------------------------------------------------------
class RS_GreenDemon : Demon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 170;
		PainChance 130;
		Species "Demon1";
		GibHealth 45;   // CH's own positive gibhealth, verbatim
		BloodColor "Green";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 11;
		Radius 30;
		Height 56;
		Mass 400;
		Monster;
		+FLOORCLIP
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o was chewed by something green";
		MeleeRange 54;
		Translation "16:31=114:127","32:46=125:127","47:47=0:0","173:191=115:123";
		Tag "Greeny";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SARG AABB 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG CCDD 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		SARG EF 7 Fast A_FaceTarget;
		SARG G 8 Fast A_CustomMeleeAttack(random(13,40),"Demon/melee","none");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		Goto See;
	Death.melee:
		SARG I 0;
		Goto Death+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+2;
	Death:
		SARG I 0 A_Jump(44,"XDeath");
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	Death.Fire:
	XDeath:
		ZOMG P 0 A_SpawnItemEx("RS_GreenDEDSmoke",0,0,32,0,0,0,SXF_NOCHECKPOSITION);
		ZOMG P 0 A_XScream;
		ZOMG P 0 A_PlaySound("weapons/rocklx",7,1);
		ZOMG P 8 Bright A_Explode(random(12,64),78);
		ZOMG Q 6 Bright A_Quake(20,12,0,64,0);
		ZOMG Q 0 A_SpawnItemEx("RS_Gas14",random(-120,120),random(-120,120),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		ZOMG Q 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG Q 0 A_SpawnItemEx("RS_Gas14",random(-80,80),random(-80,80),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		ZOMG Q 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG Q 0 A_SpawnItemEx("RS_Gas14",random(-20,20),random(-20,20),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		ZOMG Q 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG Q 0 A_SpawnItemEx("RS_Gas14",random(-80,80),random(-80,80),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		ZOMG R 4 Bright A_PlaySound("slimeball/splat",6,2);
		ZOMG R 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG R 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG R 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,36),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG R 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG R 0 A_SpawnItemEx("RS_Splash11",random(-64,64),random(-64,64),random(3,26),random(1,24),random(1,24),random(1,64),random(-180,180));
		ZOMG S 3 Bright A_SetTranslucent(0.5);
		ZOMG T 3 Bright A_SetTranslucent(0.3);
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_BlueDemon",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE ("Bluey").  CH: Demons.txt:1246.
// ---------------------------------------------------------------------------
class RS_BlueDemon : Demon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 205;
		GibHealth -65;
		PainChance 110;
		Species "Demon1";
		BloodColor "blue";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 1.1;
		PainChance "DIMp", 0;
		Speed 13;
		Radius 30;
		Height 56;
		Mass 500;
		Monster;
		+FLOORCLIP
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o met some blue meat";
		MeleeRange 64;
		Translation "16:31=198:207","32:46=240:247","47:47=0:0","208:223=198:205","160:167=112:124","173:191=197:207";
		Tag "Bluey";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SARG AABB 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG CCDD 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SARG E 4 Bright A_JumpIfCloser(800,"Rush");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Rush:
		SARG F 1 A_FaceTarget;
		SARG F 3 A_SkullAttack(25);
		Goto See;
	Melee:
		SARG EF 7 Fast A_FaceTarget;
		SARG G 8 Fast A_CustomMeleeAttack(random(15,43),"Demon/melee","none");
		Goto See;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		Goto See;
	Pain.fire:
		SARG H 1;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS PPPPPP 1;   // CH: each P spawned a CHRandom_GibGenerator
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS R 4 A_XScream;
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS S 5;
		POSS T 4 A_NoBlocking;
		POSS UUUUUU 1 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_PurpleDemon",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE ("Purply").  CH: Demons.txt:1358.
// ---------------------------------------------------------------------------
class RS_PurpleDemon : Demon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 260;
		GibHealth -80;
		BloodColor "Purple";
		PainChance 80;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Fire", 1.2;
		Damage 3;   // bare constant stays bare
		Speed 15;
		Radius 30;
		Height 56;
		Mass 500;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;   // CH lists Falling twice
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o got purple rushed";
		DropItem "RS_CH_Berserk", 42;
		MeleeRange 64;
		Translation "16:31=[230,149,247]:[180,24,156]","160:167=175:181","32:47=[168,15,181]:[41,12,13]","173:191=250:254";
		Tag "Purply";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SARG AABB 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG CCDD 2 Fast A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG E 4 Bright A_JumpIfCloser(800,"Rush2");
		Goto See;
	Rush2:
		SARG F 2 A_FaceTarget;
		SARG F 3 A_SkullAttack(24);
		Goto See;
	Melee:
		SARG EF 7 Fast A_FaceTarget;
		SARG G 6 Fast A_CustomMeleeAttack(random(13,46),"Demon/melee","none");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		SARG H 2 Bright A_Jump(100,"Missile");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	XDeath:
		// CH: TNT1 AAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain not imported
		POSS PPPPPP 1;   // CH: each P spawned a CHRandom_GibGenerator
		// CH: TNT1 AA 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS R 4 A_XScream;
		// CH: TNT1 A 0 A_SpawnItemEx("CHRandom_GibGenerator",...)
		POSS S 5;
		POSS T 4 A_NoBlocking;
		POSS UUUUUU 1 A_SpawnParticle("purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		POSS U -1;
		Stop;
	Raise:
		SARG NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW ("Yellowy").  CH: Demons.txt:1466.  The blood demon that
// skull-rams behind a lightning burst; loses an arm on death.
// ---------------------------------------------------------------------------
class RS_YellowDemon : Demon
{
	int user_Calm;   // CH: Var int User_Calm
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 325;
		BloodColor "Yellow";
		PainChance 75;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 1.25;
		PainChance "DIMp", 0;
		PainChance "fire", 8;   // CH lists fire twice; the second (4) wins, both kept
		PainChance "fire", 4;
		Speed 18;
		Radius 30;
		Height 56;
		Damage 4;   // bare constant stays bare
		Mass 800;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "blooddemon/sight";
		PainSound "blooddemon/pain";
		DeathSound "blooddemon/death";
		ActiveSound "blooddemon/active";
		Obituary "%o was chomped by orange demon";
		DropItem "RS_CH_Berserk", 50;
		MeleeRange 64;
		Translation "168:191=160:167","16:31=208:216","32:40=215:223","41:46=232:235","47:47=190:190";
		Tag "Yellowy";
	}
	States
	{
	Spawn:
		SRG2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SRG2 A 0 A_PlaySound("blooddemon/walk");
		SRG2 AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 C 0 A_PlaySound("blooddemon/walk");
		SRG2 CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 A 0 A_JumpIf(user_Calm == 1,"Calm");
		Loop;
	Melee:
		SRG2 EF 7 A_FaceTarget;
		SRG2 G 6 A_CustomMeleeAttack(random(13,52),"blooddemon/melee","none");
		SRG2 G 1 { user_Calm = (user_Calm == 1) ? 1 : 0; }   // CH: A_SetUserVar("User_Calm",User_Calm == 1)
		Goto NOYOUDONT;
	NOYOUDONT:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 G 8 A_SkullAttack(30);
		SRG2 GGGGG 2 A_CustomMissile("RS_ZapZapCB",32,random(-32,32),random(-32,32));
		SRG2 G 0 A_PlaySound("Litn/litn3");
		SRG2 G 4 A_Stop;
		SRG2 G 0 A_SetSpeed(16);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SRG2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 H 2 A_Pain;
		SRG2 H 1 A_Jump(174,"SpeedBuff");
		Goto See;
	Pain.fire:
		SRG2 H 3 Bright A_Pain;
		Goto SpeedBuff;
	SpeedBuff:
		SRG2 E 1 A_SetSpeed(30);
		SRG2 E 1 { user_Calm = (user_Calm == 0) ? 1 : 0; }   // CH: A_SetUserVar("User_Calm",User_Calm == 0)
		Goto See;
	Calm:
		SRG2 E 1 A_SetSpeed(16);
		SRG2 E 1 A_PlaySound("Litn/litn3");
		SRG2 EEEEE 0 A_CustomMissile("RS_ZapZapCB",32,random(-32,32),random(-32,32));
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SRG2 I 8;
		SRG2 I 0 A_FaceTarget;
		SRG2 J 0 A_SpawnItemEx("RS_BloodDemonArm",10,0,32,0,8,0,0,128);
		SRG2 J 8 A_Scream;
		SRG2 K 4;
		SRG2 L 4 A_NoBlocking;
		SRG2 M 4;
		SRG2 N -1;
		Stop;
	Raise:
		SRG2 NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED ("Red-y").  CH: Demons.txt:1600.  The blood spitter; enrage
// buff on pain, arm drop on death.
// ---------------------------------------------------------------------------
class RS_RedDemon : Demon
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 400;
		PainChance 30;
		Species "Demon1";
		Speed 15;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "Fire", 1.25;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 1.45;   // CH lists ice twice (bare and quoted)
		PainChance "DIMp", 0;
		Radius 30;
		Height 56;
		Mass 5000;
		Damage 4;   // bare constant stays bare
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "blooddemon/sight";
		PainSound "blooddemon/pain";
		DeathSound "blooddemon/death";
		ActiveSound "blooddemon/active";
		HitObituary "%o was crunched by red demon";
		Obituary "%o got puked on";
		DropItem "RS_CH_Berserk", 58;
		Translation "80:95=171:183","96:111=177:191","192:192=170:170","3:3=190:190","128:143=181:191","160:167=5:8";
		MeleeRange 64;
		Tag "Red-y";
	}
	States
	{
	Spawn:
		SRG2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SRG2 A 0 A_PlaySound("blooddemon/walk");
		SRG2 AABB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 C 0 A_PlaySound("blooddemon/walk");
		SRG2 CCDD 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 EF 7 Bright A_FaceTarget;
		SRG2 F 3 Bright A_CustomMissile("RS_RedDemonBloodBolt1",32);
		SRG2 G 4;
		Goto See;
	Melee:
		SRG2 EF 7 A_FaceTarget;
		SRG2 G 7 A_CustomMeleeAttack(random(13,58),"blooddemon/melee","none");
		SRG2 G 1 A_SpawnItemEx("RS_RedThingsLS",1,3,15,0,0,0,0,SXF_NOCHECKPOSITION);
		SRG2 G 0 A_SpawnItemEx("RS_RedThingsLS",6,3,15,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SRG2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 H 2 A_Pain;
		SRG2 H 1 A_Jump(174,"BuffUP");
		Goto See;
	BuffUP:
		SRG2 E 1 A_SetSpeed(25);
		SRG2 EF 6 A_CustomMissile("RS_EffectHK",24,0);
		SRG2 G 5 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		SRG2 G 0 { bMISSILEMORE = true; }   // CH: A_ChangeFlag("Missilemore",TRUE)
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SRG2 I 8;
		SRG2 I 0 A_FaceTarget;
		SRG2 J 0 A_SpawnItemEx("RS_BloodDemonArm2",10,0,32,0,8,0,0,128);
		SRG2 J 8 A_Scream;
		SRG2 K 4;
		SRG2 L 4 A_NoBlocking;
		SRG2 M 4;
		SRG2 N -1;
		Stop;
	Raise:
		SRG2 NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK BOSS ("FRESH MEAT", the Butcher).  CH: Demons.txt:1794.
// ---------------------------------------------------------------------------
class RS_BlackDemon3 : Actor
{
	int user_HOP;   // CH: Var Int User_HOP
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was made into minced meat by Butcher";
		HitObituary "%o was made into minced meat by Butcher";
		Health 4500;
		RadiusDamageFactor 0.33;
		DamageFactor "Melee", 0.9;
		DamageFactor "Plasma", 1.1;
		PainChance "DIMp", 0;
		Radius 22;
		Height 62;
		Mass 5000;
		Speed 17;
		PainChance 68;
		Species "Butcher";
		MeleeRange 77;
		MeleeThreshold 120;
		SeeSound "Butcher/Sight";
		PainSound "Butcher/Pain";
		DeathSound "Butcher/Death";
		ActiveSound "Butcher/Active";
		MeleeSound "Butcher/Melee";
		DamageFunction (random(10,40));   // CH: Damage (random(10,40))
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Monster;
		+FLOORCLIP
		+THRUSPECIES
		+BOSS
		-NORADIUSDMG
		+DONTMORPH   // CH lists +dontmorph twice
		+MISSILEMORE
		+NOFEAR
		DropItem "RS_CH_MegaSphere", 34;
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Chainsaw";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		// CH: dropitem "RLGeosGoldenGauntletArmorPickup",64 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",4 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		Tag "FRESH MEAT";
	}
	States
	{
	Spawn:
		BCHR A 0;
		Goto Scripted;
	Scripted:
		BCHR A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackDemon") -- announcers dropped per owner
		Goto Idle;
	Idle:
		BCHR AAAAAAAAAA 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BCHR BBBBBBBBBB 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BCHR AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BCHR C 0 A_PlaySoundEx("Butcher/Step","SoundSlot7",0);
		BCHR CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BCHR A 0 A_PlaySoundEx("Butcher/Step","SoundSlot7",0);
		BCHR A 0 A_Jump(64,"Calm");
		Loop;
	Calm:
		BCHR A 0 A_SetSpeed(18);
		Goto See;
	Missile:
		BCHR E 0 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BCHR E 0 A_JumpIf(user_HOP >= 8,"DOGS");
		BCHR E 0 A_JumpIfHigherOrLower("AlleUp",null,128);   // CH: A_JumpIfHigherOrLower("AlleUp","",128)
		BCHR E 0 A_JumpIfCloser(500,"BIGHOP");
		BCHR E 0 A_Jump(256,"HOPHOP");
		Goto See;
	AlleUp:
		BCHR E 0 A_FaceTarget;
		BCHR E 4 ThrustThingZ(0,88,0,0);
		BCHR E 0 A_JumpIfHigherOrLower("AlleUp","See",26,-26);
		BCHR E 1 A_CheckRange(520,"See",true);
		Goto Missile;
	HOPHOP:
		BCHR E 0 A_FaceTarget;
		BCHR E 0 ThrustThingZ(0,12,int(angle+360),0);   // CH: thrustThingZ(0,12,angle+360,0) -- nonzero third arg = thrust down, CH's own quirk
		BCHR EF 7 A_SkullAttack(20);
		BCHR E 0 A_JumpIfCloser(60,"Melee");
		Goto HOPHOP;
	BIGHOP:
		BCHR EF 12 A_SkullAttack(37);
		BCHR E 3 A_FaceTarget;
		BCHR E 0 A_Jump(64,"HOPHOP");
		Goto Melee;
	DOGS:
		BCHR E 20 A_FaceTarget;
		BCHR FFFF 12 A_SpawnItemEx("RS_WHOLETTHEDOGSOUT",random(-65,65),random(-66,66),random(3,24),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		BCHR G 12 { user_HOP = user_HOP - 8; }   // CH: A_SetUserVar("User_HOP",User_HOP-8)
		Goto See;
	Melee:
		BCHR EF 5 A_FaceTarget;
		BCHR G 7 A_CustomMeleeAttack(random(30,125),"Butcher/Melee","Butcher/miss","Extreme");
		BCHR G 1 A_Stop;
		Goto See;
	Pain:
		BCHR H 3 A_SetSpeed(28);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BCHR H 3 A_Pain;
		BCHR H 3 { user_HOP = user_HOP + 1; }   // CH: A_SetUserVar("User_HOP",User_HOP+1)
		Goto See;
	Death:
		BCHR H 12 A_Scream;
		BCHR I 0 A_PlaySound("Butcher/Explode");
		BCHR IJK 6 A_KillChildren;
		BCHR L 0 A_FaceTarget;
		BCHR L 6 A_SpawnItemEx("RS_ButcherHammer",0,-18,24,3,0,3,-85,128);
		BCHR M 6 A_NoBlocking;
		BCHR NOP 6;
		BCHR Q -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Butcher's hounds.  CH: Demons.txt:1939.  Minion -- no tier token.
// ---------------------------------------------------------------------------
class RS_WHOLETTHEDOGSOUT : Actor
{
	Default
	{
		Health 120;
		PainChance 128;
		Speed 19;
		Radius 30;
		Height 50;
		Mass 500;
		MeleeDamage 7;
		Species "Butcher";
		MaxTargetRange 256;
		DamageFactor "Fire", 0.5;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+THRUSPECIES
		+NOFEAR
		Obituary "%o got burned by the Butchers pet hounds";
		HitObituary "butchers pet hound enjoyed %o for dinner.";
		SeeSound "monster/dogsit";
		AttackSound "monster/dogatk";
		MeleeSound "monster/dogbit";
		PainSound "monster/dogpai";
		DeathSound "monster/dogdth";
		ActiveSound "monster/dogact";
		DropItem "RS_CH_Shell", 174;
		DropItem "RS_implyingclip", 200;
		DropItem "RS_CH_RocketAmmo", 128;
		DropItem "RS_CH_Cell", 64;
		Tag "DOGE";
	}
	States
	{
	Spawn:
		HDOG A 10 A_Look;
		Loop;
	See:
		HDOG AAAABBBBCCCCDDDDEEEEFFFF 1 A_Chase;
		Loop;
	Melee:
		HDOG GH 6 A_FaceTarget;
		HDOG I 6 A_MeleeAttack;
		Goto See;
	Missile:
		HDOG G 10 A_FaceTarget;
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG H 1 A_CustomMissile("RS_DogFire",28,0,0,0,0);
		HDOG I 6;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0;
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		Stop;   // CH ends this block with Stop, no A_Die -- verbatim
	Pain:
		HDOG J 2;
		HDOG J 2 A_Pain;
		Goto See;
	Death:
		HDOG K 8;
		HDOG L 8 A_Scream;
		HDOG M 4;
		HDOG N 4 A_NoBlocking;
		HDOG OP 4;
		HDOG Q -1;
		Stop;
	Raise:
		HDOG QPONMLK 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE BOSS ("YOU KNOW WHO I AM", the Juggernaut).
// CH: Demons.txt:2124.  Meteor call, rock barrages, ground-quake dash.
// ---------------------------------------------------------------------------
class RS_WhiteDemon2 : Actor
{
	int user_rock;   // CH: var int user_rock
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 8000;
		PainChance 16;
		Speed 19;
		Radius 32;
		Height 64;
		Mass 12000;
		MeleeRange 88;
		RadiusDamageFactor 0.33;
		DamageFactor "Melee", 0.45;
		DamageFactor "Ice", 1.5;   // CH lists Ice twice
		PainChance "DIMp", 0;
		MeleeThreshold 120;
		MeleeSound "Butcher/Melee";
		DamageFunction (random(20,60));   // CH: Damage (random(20,60))
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Species "Demon1";
		DamageFactor "Falling", 0.0;   // CH lists Falling twice
		Monster;
		+LAXTELEFRAGDMG
		+FLOORCLIP
		+THRUSPECIES
		+BOSS
		-NORADIUSDMG
		+DONTMORPH   // CH lists +dontmorph twice
		+MISSILEMORE
		+NOTARGETSWITCH
		+NOTARGET
		+NOFEAR
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+JUMPDOWN
		+NOBLOCKMONST
		+DROPOFF
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Chainsaw";
		DropItem "RS_CH_Chainsaw";
		DropItem "RS_CH_Chainsaw";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		DropItem "BlueArmor", 64;
		// CH: dropitem "RLGeosGoldenGauntletArmorPickup",64 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",2 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLLegendaryWeaponSpawner",4 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		SeeSound "Juggernaut/Sight";
		PainSound "Juggernaut/Pain";
		DeathSound "Juggernaut/Death";
		Obituary "%o wasnt able to stop the juggernaut";
		Tag "YOU KNOW WHO I AM";
	}
	States
	{
	Spawn:
		JUGG A 0;
		Goto Scripted;
	Scripted:
		JUGG A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteDemon") -- announcers dropped per owner
		Goto Idle;
	Idle:
		JUGG AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		JUGG A 3 A_Chase;
		JUGG A 0 { bNOCLIP = false; }   // CH: a_changeflag("noclip",false)
		JUGG A 0 A_CheckBlock("Unblock",CBF_DROPOFF);
		JUGG A 0 A_CheckBlock("Unblock",CBF_DROPOFF);
		JUGG A 0 A_PlaySound("Juggernaut/Step");
		JUGG A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		JUGG BB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		JUGG C 3 A_Chase;
		JUGG C 0 A_PlaySound("Juggernaut/Step");
		JUGG C 3 A_Chase;
		JUGG DD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Unblock:
		JUGG A 2 { bNOCLIP = true; }   // CH: a_changeflag("noclip",true)
		JUGG A 3 A_FaceTarget;
		JUGG A 3 A_SkullAttack(20);
		JUGG A 2 { bNOCLIP = false; }
		Goto See;
	Missile:
		JUGG E 0 A_SetSpeed(20);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		JUGG E 0 A_JumpIf(user_rock >= 7,"METEOR");
		JUGG E 0 A_JumpIfHigherOrLower("AlleUp",null,128);   // CH: A_JumpIfHigherOrLower("AlleUp","",128)
		JUGG E 0 A_JumpIfCloser(700,"DASH",true);
		JUGG E 0 A_JumpIfCloser(1400,"Choice");
		JUGG E 0 A_Jump(256,"ROCKS");
	DASH:
		JUGG E 0 A_JumpIf(user_rock >= 7,"METEOR");
		JUGG E 0 { user_rock = user_rock + 2; }   // CH: A_setuservar("user_rock",user_rock+2)
		JUGG EF 4 Bright A_FaceTarget;
		JUGG G 4 Bright { bNOPAIN = true; }   // CH: A_changeFlag("NOPAIN",true)
		JUGG H 9 Bright A_SkullAttack(37);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,160-angle);
		JUGG H 2 Bright A_CustomMeleeAttack(random(50,120),"","");
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,180-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,190-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,160-angle);
		JUGG H 2 Bright A_CustomMeleeAttack(random(50,120),"","");
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,180-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,190-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,160-angle);
		JUGG H 2 Bright A_CustomMeleeAttack(random(50,120),"","");
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,180-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,190-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,160-angle);
		JUGG H 2 Bright A_CustomMeleeAttack(random(50,120),"","");
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,180-angle);
		JUGG H 1 A_CustomMissile("RS_MolochQuake",0,-48,190-angle);
		JUGG J 1 A_SetSpeed(0);
		JUGG J 1 A_ScaleVelocity(0.05);
		Goto BAM;
	BAM:
		JUGG J 1 Bright A_PlaySound("monster/hamflr");
		JUGG J 8 Bright Radius_Quake(30,60,0,120,0);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,0);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,10);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,20);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,30);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,40);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,50);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,60);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,70);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,80);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,90);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,100);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,110);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,120);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,130);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,140);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,150);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,160);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,180);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,190);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,200);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,210);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,220);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,230);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,240);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,250);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,260);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,270);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,280);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,290);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,300);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,310);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,320);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,330);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,340);
		JUGG J 0 A_CustomMissile("RS_MolochQuake",0,-48,350);
		JUGG J 0 A_SpawnItemEx("RS_Drt1",random(-128,128),random(-128,128),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt2",random(-128,128),random(-128,128),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt3",random(-128,128),random(-128,128),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt2",random(-128,128),random(-128,128),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt1",random(-128,128),random(-128,128),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt3",random(-128,128),random(-128,128),0,5,0,3,random(0,360),128);
		JUGG FE 7;
		JUGG E 0 { user_rock = user_rock - 1; }   // CH: A_setuservar("user_rock",user_rock-1)
		JUGG E 0 A_ScaleVelocity(1);
		JUGG E 0 A_SetSpeed(18);
		JUGG E 8 { bNOPAIN = false; }   // CH: A_changeFlag("NOPAIN",False)
		Goto See;
	Maybenot:
		JUGG E 0;
		Goto Missile+5;
	Choice:
		JUGG E 0 A_Jump(256,"ROCKS","HOPHOP");
		Goto See;
	ROCKS:
		JUGG I 8 Bright A_FaceTarget;
		JUGG I 2 Radius_Quake(30,60,0,900,0);
		JUGG I 8 Bright A_CustomMissile("RS_WDRock1",42,15);
		JUGG I 10 Bright A_FaceTarget;
		JUGG J 6 Bright A_CustomMissile("RS_WDRock2",56,0,random(-1,1),CMF_OFFSETPITCH|CMF_ABSOLUTEPITCH,random(2,6));
		JUGG FE 6 A_FaceTarget;
		JUGG E 0 A_JumpIfCloser(1400,"Missile");
		Goto ROCKS2;
	ROCKS2:
		JUGG I 6 Bright A_FaceTarget;
		JUGG J 0 A_SpawnItemEx("RS_Drt1",random(-12,12),random(-12,12),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt2",random(-12,12),random(-12,12),0,5,0,3,random(0,360),128);
		JUGG J 0 A_SpawnItemEx("RS_Drt3",random(-18,12),random(-12,12),0,5,0,3,random(0,360),128);
		JUGG J 7 Bright A_CustomMissile("RS_WDRock3",34,0,random(-2,2));
		JUGG J 0 A_CheckSight("See");
		JUGG G 6 Bright A_FaceTarget;
		JUGG H 0 A_SpawnItemEx("RS_Drt1",random(-12,12),random(-12,12),0,5,0,3,random(0,360),128);
		JUGG H 0 A_SpawnItemEx("RS_Drt2",random(-12,12),random(-12,12),0,5,0,3,random(0,360),128);
		JUGG H 0 A_SpawnItemEx("RS_Drt3",random(-18,12),random(-12,12),0,5,0,3,random(0,360),128);
		JUGG H 6 Bright A_CustomMissile("RS_WDRock3",34,0,random(-5,5));
		JUGG H 0 A_CheckSight("See");
		JUGG H 0 { user_rock = user_rock + 1; }   // CH: A_setuservar("user_rock",user_rock+1)
		JUGG H 1 A_MonsterRefire(128,"See");
		Goto ROCKS2;
	METEOR:
		JUGG E 2 { bINVULNERABLE = true; }   // CH: A_changeFlag("INVULNERABLE",TRUE)
		JUGG E 2 { bTHRUACTORS = true; }     // CH: A_changeFlag("THRUACTORS",TRUE)
		JUGG E 2 { bNOGRAVITY = true; }      // CH: A_changeFlag("NOGRAVITY",TRUE)
		JUGG E 4 ThrustThingZ(0,90,0,0);
		JUGG E 1 A_SetScale(0.7,1.0);
		JUGG E 1 A_SetScale(0.5,1.0);
		JUGG E 1 A_SetScale(0.3,1.0);
		JUGG E 1 A_SetScale(0.1,1.0);
		TNT1 AAA 1 A_Wander;
		TNT1 A 3 A_SetScale(1.0,1.0);
		TNT1 AAA 1 A_Wander;
		TNT1 A 0 A_VileTarget("RS_MeteorStrikeCH");
		TNT1 A 4 A_Warp(AAPTR_TARGET,0,0,128,0,WARPF_NOCHECKPOSITION);
		TNT1 A 40;
		JUGG E 2 { bINVULNERABLE = false; }
		JUGG E 2 { bTHRUACTORS = false; }
		JUGG E 2 { bNOGRAVITY = false; }
		JUGG E 6 Bright ThrustThingZ(0,90,1,0);
		JUGG E 6 A_Explode(random(30,80),128);
		JUGG H 0 { user_rock = user_rock - 6; }   // CH: A_setuservar("user_rock",user_rock-6)
		Goto BAM;
	AlleUp:
		JUGG E 0 A_JumpIfCloser(700,"Maybenot");
		JUGG E 0 A_FaceTarget;
		JUGG E 4 ThrustThingZ(0,102,0,0);
		JUGG E 0 A_JumpIfHigherOrLower("AlleUp","See",26,-26);
		JUGG E 1 A_CheckRange(520,"See",true);
		Goto Missile;
	HOPHOP:
		JUGG E 0 A_FaceTarget;
		JUGG E 0 ThrustThingZ(0,16,0,0);
		JUGG E 0 Radius_Quake(10,40,0,80,0);
		JUGG CC 7 A_SkullAttack(32);
		JUGG E 0 A_JumpIfCloser(120,"DASH");
		Goto HOPHOP;
	BIGHOP:
		JUGG AA 12 A_SkullAttack(42);
		JUGG I 3 A_FaceTarget;
		JUGG E 0 A_Jump(64,"HOPHOP");
		Goto Melee;
	Melee:
		JUGG EFG 2 A_FaceTarget;
		JUGG G 0 A_PlaySoundEx("Juggernaut/Attack","SoundSlot5");
		JUGG G 0 A_PlaySoundEx("Juggernaut/Pain","SoundSlot6");
		JUGG H 6 A_CustomMeleeAttack(random(40,120),"Juggernaut/Hit","","",1);
		JUGG I 4 A_FaceTarget;
		JUGG I 0 A_PlaySoundEx("Juggernaut/Attack","SoundSlot5");
		JUGG I 0 A_PlaySoundEx("Juggernaut/Pain","SoundSlot6");
		JUGG J 6 A_CustomMeleeAttack(random(40,120),"Juggernaut/Hit","","",1);
		JUGG J 0 A_Jump(128,"DASH");
		Goto See;
	Pain:
		JUGG E 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		JUGG E 2 A_Pain;
		JUGG E 2 A_SetSpeed(30);
		Goto See;
	Death:
		JUGG K 6 A_Scream;
		JUGG LM 6;
		JUGG N 6 A_PlaySound("Juggernaut/Thud");
		JUGG O 6 A_NoBlocking;
		JUGG P 6;
		JUGG Q -1;
		Stop;
	}
}
