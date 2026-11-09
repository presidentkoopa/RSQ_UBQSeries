// ============================================================================
// RS_LostSoul.zs -- Colourful Hell Lost Soul family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\lostsouls.txt (3092 lines,
// read whole). Every actor cites its CH line. Support: RS_LostSoulFX.zs
// (see its header for cross-lane notes, proven-missing assets, and
// standing strips).
// Tier ladder as before: CH icon index -- 1 Common, 2 Green, 3 Blue,
// 4 Purple, 5 Yellow (Forgotten One), 6 Red, 7 FireBlu, 8 Gray (hive),
// 9 Abyss (beetle), 10 Black boss (Queen Bee), 11 White boss (Shifter /
// EX), 12 Cyan, 13 Brown (THE CUBE). Minions (bees, eggs, EX skulls) get
// no token.
// RS_BlackLSoulOld3 is CH's ORPHAN: defined at lostsouls.txt:1273, spawned
// by nothing anywhere in CH. Imported whole per the import-everything rule
// (same treatment as RS_PinkDemon in the demon family). RS_CHKeganSurprise
// (lostsouls.txt:1263) is likewise referenced by nothing in CH's decorate
// or ACS -- a console-summon party trick, imported whole.
// This family's tiers 1-6 have NO cvar stubs in CH -- Colourset14 spawns
// those bodies directly; only Brown/Cyan/Abyss/Gray/FireBlu/Black/White
// carry gates. Kept as CH built it.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: lostsouls.txt:1 -- Colourset14 replaces Lostsoul.
// ---------------------------------------------------------------------------
class RS_Colourset14 : RandomSpawner replaces LostSoul
{
	Default
	{
		DropItem "RS_CommonLSoul", 255, 429;
		DropItem "RS_GreenLSoul", 255, 320;
		DropItem "RS_BrownLSoul", 255, 120;
		DropItem "RS_CyanLSoul", 255, 60;
		DropItem "RS_BlueLSoul", 255, 175;
		DropItem "RS_FireBluLSoul", 255, 50;
		DropItem "RS_PurpleLSoul", 255, 50;
		DropItem "RS_GrayLSoul", 255, 30;
		DropItem "RS_YellowLSoul", 255, 40;
		DropItem "RS_RedLSoul", 255, 20;
		DropItem "RS_AbyssLsoul", 255, 40;
		DropItem "RS_BlackLSoul", 255, 3;
		DropItem "RS_WhiteLSoul", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families
// (1 = colour off / reroll the dial, 3 = fifty-fifty).
// ---------------------------------------------------------------------------
class RS_BrownLSoul : Actor   // CH lostsouls.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset14",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanLSoul : Actor   // CH lostsouls.txt:131 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset14",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssLsoul : Actor   // CH lostsouls.txt:285 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset14",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayLSoul : Actor   // CH lostsouls.txt:533 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset14",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluLSoul : Actor   // CH lostsouls.txt:629 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset14",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackLSoul : Actor   // CH lostsouls.txt:1244 -- gate CH_BlackBossy (no EX branch on black in this family)
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackLSoul3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedLSoul",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteLSoul : Actor   // CH lostsouls.txt:1870 -- gates CH_WhiteBossy + CH_ExBoss
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
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 1, "EX1");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 2, "EX2");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_exboss', 1) == 3, "EX3");
		TNT1 A 0 A_SpawnItemEx("RS_WhiteLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackLSoul",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteLSoul2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteLSoulEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_WhiteLSoulEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232, "EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_WhiteLSoulEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// CH's console party trick: twelve queen bees at once.  CH: lostsouls.txt
// :1263.  Referenced by nothing in CH's decorate or ACS; imported whole.
// ---------------------------------------------------------------------------
class RS_CHKeganSurprise : Actor   // CH lostsouls.txt:1263
{
	States
	{
	Spawn:
		TNT1 AAAAAAAAAAAA 0 A_SpawnItemEx("RS_BlackLSoul3",random(-64,64),random(-64,64),random(-16,64),0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN ("THE CUBE").  CH: lostsouls.txt:40.  The vile-chasing
// spawn cube: heals the pack, hands out RS_CHBoner on its melee-death, and
// detonates.
// ---------------------------------------------------------------------------
class RS_BrownLSoul2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Species "LSoul";
		Health 125;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 15;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Damage 3;   // bare constant stays bare
		MeleeThreshold 150;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+NOBLOOD
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+NOICEDEATH
		+FLOATBOB
		+NOPAIN
		AttackSound "skelatt";
		PainSound "skelpai";
		DeathSound "skull/death";
		ActiveSound "skelsit";
		RenderStyle "SoulTrans";
		Scale 0.75;
		Obituary "%o got sharp cornered by brown lost soul.";
		Tag "THE CUBE";
	}
	States
	{
	Spawn:
		BOSF ABCD 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOSF ABCD 6 Bright A_VileChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSF ABCD 4 Bright A_FaceTarget;
		BOSF ABCD 3 Bright A_FaceTarget;
		BOSF ABCD 2 Bright A_FaceTarget;
		BOSF ABCD 1 Bright A_SkullAttack;
		BOSF ABCDABCDABCDABCD 1 Bright;
		BOSF ABCD 1 Bright A_SkullAttack;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSF ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD 1 Bright;
		TNT1 A 0 A_Stop;
		Goto See;
	Melee:
		BOSF ABCD 1 Bright A_FaceTarget;
		BOSF ABCD 1 Bright A_CustomMeleeAttack(random(1,3),"imp/melee");
		TNT1 A 0 A_CheckRange(128,"See",false);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSF D 20 Bright A_PlaySound("vile/active",0);
		Goto DeathHeal;
	Pain:
		BOSF ABCD 1 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Pain;
		Goto See;
	Heal:
		BOSF ABCD 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSF D 10 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOSF DCBA 3 Bright;
		BOSF DCBA 2 Bright;
		BOSF DCBA 1 Bright;
		Goto DeathHeal;
	DeathHeal:
		TNT1 AAAA 0 A_SpawnItemEx("RS_ArchRingHelp",random(-128,128),random(-128,128),0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_RadiusGive("Health",1200,RGF_MONSTERS,200);   // vanilla Health item, as in CH
		TNT1 A 0 A_RadiusGive("RS_CHBoner",320,RGF_MONSTERS);
		Goto Death;
	Death:
		BOSF AB 1 Bright;
		BOSF C 1 Bright A_Scream;
		BOSF D 1 Bright A_NoBlocking;
		MISL BCD 3 Bright A_Explode(random(10,50),128);   // per-frame explode: CH's cube detonation, deliberate
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN ("Cyan LostSoul").  CH: lostsouls.txt:203.  The two-eyed
// ice comet; leaves a cyan bomb trail on its rush.
// ---------------------------------------------------------------------------
class RS_CyanLSoul2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Species "LSoul";
		BloodColor "Blue";
		Health 80;
		Radius 16;
		Height 56;
		Mass 120;
		Speed 8;
		FloatSpeed 11;
		PainChance 192;
		Damage 2;   // bare constant stays bare
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 0.2;   // CH lists ice twice (quoted and bare)
		DamageFactor "Melee", 2.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOAT
		+NOGRAVITY
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+NOICEDEATH
		AttackSound "";
		DropItem "RS_HealthBundle", 32;
		PainSound "prox/beep";
		DeathSound "Crack/death";
		ActiveSound "WHPEACT";
		RenderStyle "SoulTrans";
		Alpha 0.66;
		Obituary "%o got smashed by cyan lost soul";
		Translation "0:255=%[0.00,0.00,2.00]:[1.01,2.00,2.00]";
		Tag "Cyan LostSoul";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Toot:
		TNT1 A 0 A_SpawnItemEx("RS_CyanSoulEye2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 0 A_SpawnItemEx("RS_CyanSoulEye",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
	Idle:
		LFX1 STUVW 1 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		LFX1 STUVW 1 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LFX1 ST 1 Bright A_FaceTarget;
		TNT1 A 0 A_PlaySound("ice/splode",0);
		LFX1 UVWS 1 Bright A_SkullAttack(18);
		LFX1 T 9 Bright A_SkullAttack(40);
		LFX1 T 0 ThrustThing(int(angle),30,0,0);   // CH: Thrustthing(angle,30,0,0)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LFX1 STUVW 1 Bright A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION);
		LFX1 STUVW 2 Bright A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,1,0,0,0,0,SXF_NOCHECKPOSITION);
		LFX1 STUVW 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LFX1 STUVW 4 Bright;
		LFX1 STUVW 5 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Stop;
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		LFX1 STUVW 1 Bright A_Pain;
		Goto See;
	Death:
		LFX1 STUVW 1 Bright;
		TNT1 A 2 A_Scream;
		TNT1 A 1 A_KillChildren("Extreme",KILS_FOILINVUL|KILS_KILLMISSILES);   // CH: a_killchildren(extreme,...)
		TNT1 A 2 A_NoBlocking;
		TNT1 A 0 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS ("beetlejuice").  CH: lostsouls.txt:308.  The stalker
// beetle: shrinks to a speck, creeps along floor or ceiling, pops back to
// size on top of you.
// ---------------------------------------------------------------------------
class RS_AbyssLSoul2 : Actor
{
	int user_pop;   // CH: var int user_pop
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Species "LSoul";
		BloodColor "Blue";
		Health 380;
		Radius 16;
		Height 32;
		Mass 5000;
		Speed 8;
		Damage 1;   // bare constant stays bare
		DamageFactor "Antiair", 3.0;
		DamageFactor "fire", 1.25;   // CH lists fire twice (quoted and bare)
		DamageFactor "melee", 0.25;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MeleeThreshold 200;
		PainChance 32;
		Monster;
		+FLOAT
		+NOGRAVITY
		+NOTARGET
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOICEDEATH
		PainSound "beetl/ow";
		SeeSound "BETLESEE";
		DeathSound "BETLEDED";
		ActiveSound "BETLEACT";
		Obituary "%o got bugged to death";
		// CH: Translation "160:167=196:200","208:223=197:207","67:73=201:207","146:151=189:191","128:133=176:183","134:143=200:207","144:147=181:186","148:150=204:207","151:151=191:191","76:79=187:191","73:76=201:206" -- commented out in CH itself
		Tag "beetlejuice";
		DropItem "RS_implyingclip";
		DropItem "RS_implyingclip";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_ShellBox", 12;
	}
	States
	{
	Spawn:
		BST7 AB 10 Bright A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetTranslucent(1.0);
		TNT1 A 0 { bFLOAT = false; }   // CH: A_changeflag("Float",FALSE)
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("Nogravity",FALSE)
		BST7 ABCDE 1 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(4,"HideM");
		BST7 FGHIJ 1 A_Chase;
		TNT1 A 0 A_Jump(6,"HideM2");
		BST7 KLMNO 1 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(8,"HideM3");
		Loop;
	HideM:
		TNT1 A 0 A_CheckSight("Hide");
		Goto See+8;
	HideM2:
		TNT1 A 0 A_CheckSight("Hide");
		Goto See+15;
	HideM3:
		TNT1 A 0 A_CheckSight("Hide");
		Goto See;
	Hide:
		TNT1 A 0 A_JumpIf(ceilingZ <= 164,"HideRoof");
	HideGround:
		BST7 A 1;
		TNT1 A 0 A_PlaySound("ZQuTag00",0);
		BST7 A 1 A_SetSpeed(4);
		BST7 A 1 A_UnSetSolid;
		BST7 A 1 A_SetScale(0.5,0.05);
		BST7 A 1 A_SetTranslucent(0.20);
		TNT1 A 0 A_PlaySound("ZQuTag01",0);
	Stalk2:
		ABSP G 1;
		ABSP G 1 A_Wander;
		ABSP G 1 A_CheckSight("Stalk2");
		Goto PopYet;
	PopYet:
		ABSP G 1;
		ABSP G 1 A_JumpIfCloser(128,"NOW2");
		ABSP G 1 { user_pop = user_pop + 1; }   // CH: A_setuservar("User_Pop",user_pop+1)
		ABSP G 2 A_JumpIf(user_pop >= 100,"NOW2");
		Goto Stalk2;
	Now2:
		TNT1 A 0 A_PlaySound("ZQuTag01",0);
		TNT1 A 0 A_SetScale(1.0,1.0);
		BST7 A 1 { user_pop = (user_pop == 1) ? 1 : 0; }   // CH: A_setuservar("User_Pop",user_pop==1)
		BST7 A 1 A_SetSpeed(8);
		BST7 A 1 A_SetSolid;
		TNT1 A 0 A_PlaySound("BETLEAT1",4);
		BST8 EFG 8;
		Goto See;
	HideRoof:
		BST7 A 1;
		TNT1 A 0 A_PlaySound("ZQuTag00",0);
		TNT1 A 0 { bFLOAT = true; }   // CH: A_changeflag("Float",TRUE)
		TNT1 A 0 { bNOGRAVITY = true; }   // CH: A_changeflag("Nogravity",TRUE)
		TNT1 A 0 ThrustThingZ(0,128,0,0);
		BST7 A 1 A_SetSpeed(4);
		BST7 A 1 A_UnSetSolid;
		BST7 A 1 A_SetScale(0.75,0.1);
		TNT1 A 0 A_PlaySound("ZQuTag01",0);
	Stalk:
		ABSP G 1;
		ABSP G 1 A_Wander;
		ABSP G 1 A_CheckSight("Stalk");
		Goto DropYet;
	DropYet:
		ABSP G 1;
		ABSP G 1 A_JumpIfCloser(128,"NOW");
		TNT1 A 0 ThrustThingZ(0,128,0,0);
		ABSP G 1 { user_pop = user_pop + 1; }   // CH: A_setuservar("User_Pop",user_pop+1)
		ABSP G 2 A_JumpIf(user_pop >= 100,"NOW");
		Goto Stalk;
	Now:
		TNT1 A 0 A_PlaySound("ZQuTag01",0);
		TNT1 A 0 A_SetScale(1.0,1.0);
		BST7 A 1 { user_pop = (user_pop == 1) ? 1 : 0; }   // CH: A_setuservar("User_Pop",user_pop==1)
		BST7 A 1 A_SetSpeed(8);
		BST7 A 1 A_SetSolid;
		TNT1 A 0 { bFLOAT = false; }   // CH: A_changeflag("Float",FALSE)
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("Nogravity",FALSE)
		TNT1 A 0 A_PlaySound("BETLEAT1",4);
		BST8 EFG 6;
		Goto See;
	Missile:
		BST8 A 10 Bright A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BST8 A 1 A_JumpIfCloser(600,"Rush");
		BST8 B 2 Bright;
		BST8 C 2 Bright A_PlaySound("BETLEAT2",4);
		BST8 DE 2 Bright A_FaceTarget;
		TNT1 AAAA 0 A_CustomMissile("RS_BeetleSpitAbyss",18,0,random(-10,10));
		BST8 FG 3 Bright;
	Rush:
		BST8 B 8 Bright A_SkullAttack;
		BST8 CD 7 Bright A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(90,"Melee");
		Goto Missile+3;
	Melee:
		BST8 EF 1 Bright A_CustomMeleeAttack(random(5,15),"Skull/melee");
		BST8 G 1 A_PlaySound("BETLEAT1",4);
		BST8 BCD 2 Bright A_JumpIfCloser(72,"Wrap");
		Goto See;
	Wrap:
		BST8 A 1 A_Warp(AAPTR_TARGET,random(-1,3),0,12,random(-45,45),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_PlaySound("BETLEAT1",4);
		BST8 A 1 A_Warp(AAPTR_TARGET,random(-1,3),0,12,random(-45,45),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_CustomMissile("RS_WormLewd",12,0,0);
		TNT1 A 0 HealThing(5,300);
		TNT1 A 0 A_JumpIfTargetInLOS("See",1);
		BST8 BEBEBEBEBEBEBEBEBEBEBEBE 1 A_Warp(AAPTR_TARGET,random(-1,3),0,12,random(-45,45),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	Pain:
		TNT1 A 0 A_SetScale(1.0,1.0);
		BST7 A 0 A_SetSpeed(8);
		BST7 A 0 A_SetTranslucent(1.0);
		BST7 A 0 { user_pop = (user_pop == 1) ? 1 : 0; }   // CH: A_setuservar("User_Pop",user_pop==1)
		BST7 A 0 A_SetSolid;
		TNT1 A 0 { bFLOAT = false; }   // CH: A_changeflag("Float",FALSE)
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("Nogravity",FALSE)
		BST9 A 3 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BST9 A 3 Bright A_Pain;
		Goto See;
	Death:
		TNT1 A 0 A_SetScale(1.0,1.0);
		BST7 A 1 A_SetTranslucent(1.0);
		BST9 A 6 Bright;
		BST9 B 6 Bright A_Scream;
		BST9 C 6 Bright;
		BST9 D 6 Bright A_NoBlocking;
		BST9 EFGH 6;
		BST9 H -1;
		Stop;
	Raise:
		BST9 HGFEDCBA 3;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY ("A hive").  CH: lostsouls.txt:552.  The ceiling hive:
// swells, releases bees, drops dead as a bee bomb.
// ---------------------------------------------------------------------------
class RS_GrayLSoul2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Species "LSoul";
		BloodColor "white";
		Health 50;
		Radius 8;
		Height 16;
		Mass 50;
		YScale 1.5;
		FloatSpeed 2;
		Speed 2;
		DamageFactor "Antiair", 3.0;
		DamageFactor "fire", 1.7;   // CH lists fire twice (quoted and bare)
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MeleeThreshold 150;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+SPAWNCEILING
		+NOICEDEATH
		+NOPAIN
		AttackSound "";
		PainSound "";
		DeathSound "Hornet/Death";
		ActiveSound "skull/active";
		DropItem "Backpack", 128;
		Obituary "%o ?? how did a hive kill you.";
		Translation "176:191=96:111","168:176=96:96","208:223=96:99","231:231=96:96","232:235=104:106";
		Tag "A hive";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 ThrustThingZ(0,12,0,0);
	Idle:
		BAL1 A 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BAL1 A 8 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnParticle("Gray",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BAL1 A 5 Bright A_SetScale(1.1,1.4);
		BAL1 A 5 Bright A_SetScale(1.2,1.3);
		TNT1 AA 0 A_SpawnParticle("Gray",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BAL1 A 5 Bright A_SetScale(1.3,1.2);
		BAL1 A 5 Bright A_SetScale(1.2,1.3);
		TNT1 A 0 A_DualPainAttack("RS_BlackLSoul2");
		TNT1 AA 0 A_SpawnParticle("Gray",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BAL1 A 5 Bright A_SetScale(1.1,1.4);
		BAL1 A 5 Bright A_SetScale(1.0,1.5);
		Goto See;
	Pain:
		TNT1 A 0;
		Goto See;
	Death:
		BAL1 A 0 A_Fall;
		BAL1 A 5 A_SetScale(1.5,1.0);
		BAL1 A 30;
	Crash:
		TNT1 AAAAAAAAAAAA 0 A_SpawnParticle("Gray",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 1 A_PainDie("RS_BlackLSoul2");
		TNT1 A 0 A_Scream;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU ("Charred skull").  CH: lostsouls.txt:648.  The rammer
// that detonates on its own melee.
// ---------------------------------------------------------------------------
class RS_FireBluLSoul2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Species "LSoul";
		BloodColor "Blue";
		Health 175;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 15;
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 1.2;   // CH lists ice twice (quoted and bare)
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Damage 3;   // bare constant stays bare
		MeleeThreshold 150;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+NOICEDEATH
		+NOPAIN
		AttackSound "skull/melee";
		PainSound "skull/pain";
		DeathSound "skull/death";
		ActiveSound "skull/active";
		RenderStyle "SoulTrans";
		Obituary "%o was fireblu soul'd.";
		Translation "160:167=196:200","208:223=197:207","67:73=201:207","146:151=189:191","128:133=176:183","134:143=200:207","144:147=181:186","148:150=204:207","151:151=191:191","76:79=187:191","73:76=201:206";
		Tag "Charred skull";
	}
	States
	{
	Spawn:
		SKUL AB 10 Bright A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKUL AB 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL C 10 Bright A_FaceTarget;
		SKUL D 4 Bright A_SkullAttack;
		SKUL CD 4 Bright;
		Goto Missile+3;
	Melee:
		SKUL CD 1 Bright A_CustomMeleeAttack(random(3,8),"Skull/melee");
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		MISL BCD 2 Bright A_Explode(random(10,50),128);   // per-frame explode: CH's suicide burst, deliberate
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SKUL E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL E 3 Bright A_Pain;
		Goto See;
	Death:
		SKUL F 3 Bright;
		SKUL G 3 Bright A_Scream;
		SKUL H 3 Bright;
		SKUL I 3 Bright A_NoBlocking;
		SKUL J 3;
		MISL BCD 3 Bright A_Explode(random(10,50),128);
		SKUL K 2 ThrustThingZ(0,2,1,0);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON ("LostSoul").  CH: lostsouls.txt:722.  Vanilla parent,
// CH's flag/species dressing on top.
// ---------------------------------------------------------------------------
class RS_CommonLSoul : LostSoul
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "LSoul";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		Tag "LostSoul";
	}
	States
	{
	Spawn:
		SKUL AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKUL AB 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SKUL C 10 Bright A_FaceTarget;
		SKUL D 4 Bright A_SkullAttack;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL CD 4 Bright;
		Goto Missile+2;
	Pain:
		SKUL E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL E 3 Bright A_Pain;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN ("Green LostSoul").  CH: lostsouls.txt:758.  Splashes
// poison on melee and death.
// ---------------------------------------------------------------------------
class RS_GreenLSoul : LostSoul
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Species "LSoul";
		BloodColor "Green";
		Health 120;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 8;
		PainChance 200;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Damage 3;   // bare constant stays bare
		MeleeThreshold 150;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+NOICEDEATH
		AttackSound "skull/melee";
		PainSound "skull/pain";
		DeathSound "skull/death";
		ActiveSound "skull/active";
		RenderStyle "SoulTrans";
		Obituary "%o was spooked by a green icky lost soul.";
		Translation "168:191=112:127","208:223=112:127","161:161=112:112","232:235=124:127","232:235=124:127","208:223=112:127","164:167=124:127";
		Tag "Green LostSoul";
	}
	States
	{
	Spawn:
		SKUL AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKUL AB 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SKUL C 10 Bright A_FaceTarget;
		SKUL D 4 Bright A_SkullAttack;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL CD 4 Bright;
		Goto Missile+2;
	Melee:
		SKUL CD 9 Bright A_CustomMeleeAttack(random(3,8),"Skull/melee");
		SKUL C 0 A_CustomMissile("RS_SplasherSoul",30,0);
		Goto See;
	Pain:
		SKUL E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL E 3 Bright A_Pain;
		Goto See;
	Death:
		SKUL F 6 Bright;
		SKUL G 6 Bright A_Scream;
		SKUL H 6 Bright A_CustomMissile("RS_SplasherSoul",30,0);
		SKUL I 6 Bright A_NoBlocking;
		SKUL JK 6;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE ("Blue LostSoul").  CH: lostsouls.txt:848.  Rushes close,
// or fires a psychic bullet volley from afar.
// ---------------------------------------------------------------------------
class RS_BlueLSoul : LostSoul
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Species "LSoul";
		BloodColor "blue";
		Health 145;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 9;
		PainChance 175;
		Damage 3;   // bare constant stays bare
		MeleeThreshold 150;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+NOICEDEATH
		AttackSound "skull/melee";
		PainSound "skull/pain";
		DeathSound "skull/death";
		ActiveSound "skull/active";
		RenderStyle "SoulTrans";
		DropItem "HealthBonus", 128;
		Obituary "%o got themselves a new blue skull";
		Translation "168:191=195:207","208:223=192:198","161:161=192:192","232:235=204:206","165:167=254:254";
		Tag "Blue LostSoul";
	}
	States
	{
	Spawn:
		SKUL AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKUL AB 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL C 3 Bright A_JumpIfCloser(650,"RushIt");
		SKUL C 0 A_Jump(255,"Decision");
		Goto See;
	Decision:
		SKUL C 0 A_Jump(255,"RushIt","Psychic");
		Goto See;
	RushIt:
		SKUL C 8 Bright A_FaceTarget;
		SKUL D 4 Bright A_SkullAttack;
		SKUL CD 4 Bright;
		Goto RushIt+1;
	Psychic:
		SKUL C 7 Bright A_FaceTarget;
		SKUL C 0 A_PlaySound("fire/fire4");
		SKUL D 4 Bright A_CustomBulletAttack(6,6,random(1,15),random(1,2),"RS_PsychPuff");
		SKUL CD 4 Bright;
		Goto Missile;
	Melee:
		SKUL CD 9 Bright A_CustomMeleeAttack(random(4,9),"Skull/melee");
		Goto See;
	Pain:
		SKUL E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL E 3 Bright A_Pain;
		Goto See;
	Death:
		SKUL F 6 Bright;
		SKUL G 6 Bright A_Scream;
		SKUL H 6 Bright;
		SKUL I 6 Bright A_NoBlocking;
		SKUL JK 6;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE ("Purple LostSoul").  CH: lostsouls.txt:928.  Phases
// through actors on its charge.
// ---------------------------------------------------------------------------
class RS_PurpleLSoul : LostSoul
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Species "LSoul";
		BloodColor "Purple";
		Health 150;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 9;
		PainChance 192;
		Damage 3;   // bare constant stays bare
		MeleeThreshold 150;
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 1.2;   // CH lists ice twice (quoted and bare)
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOTARGET
		+DONTFALL
		+NOICEDEATH
		AttackSound "skull/melee";
		DropItem "RS_HealthBundle", 16;
		PainSound "skull/pain";
		DeathSound "skull/death";
		ActiveSound "skull/active";
		RenderStyle "SoulTrans";
		Obituary "%o found the angry purple lost soul";
		Translation "168:191=251:254","208:223=250:250","161:161=168:168";
		Tag "Purple LostSoul";
	}
	States
	{
	Spawn:
		SKUL AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		SKUL AB 6 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SKUL C 0 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL C 8 Bright A_FaceTarget;
		SKUL D 4 Bright A_SkullAttack(35);
		SKUL CD 4 Bright A_JumpIfCloser(100,"Reset");
		Goto Missile+4;
	Reset:
		SKUL C 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		Goto Missile+3;
	Pain:
		SKUL E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKUL E 3 Bright A_Pain;
		Goto Reset2;
	Reset2:
		SKUL C 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		Goto See;
	Death:
		SKUL F 6 Bright;
		SKUL G 6 Bright A_Scream;
		SKUL H 6 Bright;
		SKUL I 6 Bright A_NoBlocking;
		SKUL JK 6;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW ("Yellow LostSoul", the Forgotten One).  CH: lostsouls
// .txt:1003.  The chain-charger; splits into a common soul on death.
// ---------------------------------------------------------------------------
class RS_YellowLSoul : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Obituary "%o met the Orange Lost Soul, thats about it";
		Species "LSoul";
		Health 180;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 12;
		PainChance 120;
		RenderStyle "Add";
		Alpha 1;
		Scale 1;
		PainSound "Forgotten/Pain";
		DeathSound "Forgotten/Death";
		ActiveSound "Forgotten/Active";
		DamageFactor "Antiair", 3.0;
		DamageFactor "ice", 1.2;   // CH lists ice twice (quoted and bare)
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DropItem "HealthBonus", 128;
		Damage 5;   // bare constant stays bare
		Monster;
		+FLOORCLIP
		+FLOAT
		+NOGRAVITY
		+NOICEDEATH
		+DONTFALL
		+FLOATBOB
		+NOBLOOD
		+NOFEAR
		Translation "168:191=220:223";
		Tag "Yellow LostSoul";
	}
	States
	{
	Spawn:
		FRGO A 0 NoDelay { bFLOATBOB = true; }   // CH: A_ChangeFlag("FloatBob",1)
		FRGO AAAAAA 1 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO BBBBBB 1 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FRGO A 0 { bFLOATBOB = true; }   // CH: A_ChangeFlag("FloatBob",1)
		FRGO AABB 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FRGO C 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FloatBob",0)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO CCDDC 2 Bright A_FaceTarget;
		FRGO D 0 A_PlaySound("Forgotten/Attack");
		FRGO D 2 Bright A_SkullAttack;
		FRGO C 2 Bright;
		FRGO C 0 A_JumpIfTargetInLOS("KeepUp",75);   // CH: A_JumpIfTargetInLOS(4,75) -- numeric state offset, label added (state counts unchanged)
		FRGO C 0 A_Jump(24,"StopCharge");
		FRGO DC 2 Bright;
		Goto Missile+11;
	KeepUp:
		FRGO C 0;
		Goto Missile+8;
	StopCharge:
		FRGO C 0 A_Stop;
		Goto See;
	Pain:
		FRGO E 0 { bFLOATBOB = true; }   // CH: A_ChangeFlag("FloatBob",1)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO E 3 Bright;
		FRGO E 3 Bright A_Pain;
		Goto See;
	Death:
		FRGO E 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FloatBob",0)
		FRGO E 0 A_Stop;
		FRGO EF 4 Bright;
		FRGO G 6 Bright A_Scream;
		FRGO H 6 Bright A_Explode(random(5,15),64);
		FRGO I 6 Bright A_NoBlocking;
		FRGO J 6 Bright A_PainDie("RS_CommonLSoul");
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED ("Bloody Red LostSoul").  CH: lostsouls.txt:1085.  Charges
// or spits plasma bolts; sheds RS_RedThingsLS flecks the whole while.
// ---------------------------------------------------------------------------
class RS_RedLSoul : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Obituary "Red Lost Soul? Wouldn't blood dripping soul sound more powerful?";
		Species "LSoul";
		DamageFactor "ice", 1.45;   // CH lists ice twice (bare and quoted)
		Health 240;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 11;
		PainChance 88;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Scale 1.15;
		PainSound "Forgotten/Pain";
		DeathSound "Forgotten/Death";
		ActiveSound "Forgotten/Active";
		DropItem "RS_implyingclip";
		DropItem "HealthBonus", 128;
		DropItem "HealthBonus", 128;
		Damage 5;   // bare constant stays bare
		Monster;
		+MISSILEEVENMORE
		+MISSILEMORE
		+FLOORCLIP
		+FLOAT
		+NOGRAVITY
		+NOICEDEATH
		+DONTFALL
		+FLOATBOB
		+NOFEAR
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Translation "76:79=44:47","136:143=184:191","128:136=175:183","64:79=176:191","208:223=171:181","161:161=170:170","144:151=180:191";
		Tag "Bloody Red LostSoul";
	}
	States
	{
	Spawn:
		FRGO A 0 NoDelay { bFLOATBOB = true; }   // CH: A_ChangeFlag("FloatBob",1)
		FRGO AAAAAA 1 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO BBBBBB 1 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		FRGO A 0 { bFLOATBOB = true; }   // CH: A_ChangeFlag("FloatBob",1)
		FRGO A 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO AABB 3 Bright A_Chase;
		FRGO A 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		FRGO C 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FloatBob",0)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO C 0 A_Jump(126,"Charge");
		FRGO C 0 A_Jump(256,"Charge","Spit");
	Spit:
		FRGO C 8 A_FaceTarget;
		FRGO D 5 A_CustomMissile("RS_SpitBoltLS",12,0,random(-8,8));
		FRGO C 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO D 3 A_CustomMissile("RS_SpitBoltLS",12,0,random(-8,8));
		FRGO C 4 A_FaceTarget;
		FRGO D 1 A_CustomMissile("RS_SpitBoltLS",12,0,random(-8,8));
		Goto See;
	Charge:
		FRGO CCDDC 2 Bright A_FaceTarget;
		FRGO D 0 A_PlaySound("Forgotten/Attack");
		FRGO D 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		FRGO D 2 Bright A_SkullAttack(23);
		FRGO D 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		FRGO C 2 Bright;
		FRGO C 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		FRGO C 0 A_JumpIfTargetInLOS("KeepUp",75);   // CH: A_JumpIfTargetInLOS(4,75) -- numeric state offset, label added (state counts unchanged)
		FRGO C 0 A_Jump(24,"StopCharge");
		FRGO DC 2 Bright;
		Goto Charge+8;
	KeepUp:
		FRGO C 0;
		Goto Charge+5;
	StopCharge:
		FRGO C 0 A_Stop;
		Goto See;
	Pain:
		FRGO E 0 { bFLOATBOB = true; }   // CH: A_ChangeFlag("FloatBob",1)
		FRGO E 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		FRGO E 3 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		FRGO E 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		FRGO E 3 Bright A_Pain;
		FRGO E 0 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Death:
		FRGO E 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FloatBob",0)
		FRGO E 0 A_Stop;
		FRGO EF 4 Bright A_Explode(random(5,15),64);
		FRGO G 6 Bright A_Scream;
		FRGO H 6 Bright A_Explode(random(5,15),64);
		FRGO I 6 Bright A_NoBlocking;
		FRGO J 6 Bright A_SpawnItemEx("RS_HKREDDEATH",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK, the old cut.  CH: lostsouls.txt:1273 ("BlackLSoulOld3").
// CH's ORPHAN -- spawned by nothing anywhere in CH; imported whole per the
// import-everything rule.  The 666hp Queen Bee, 46-bee escort.
// ---------------------------------------------------------------------------
class RS_BlackLSoulOld3 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }   // black bosses both 10
	Default
	{
		Obituary "%o was killed by the queen bee";
		Health 666;
		Radius 16;
		Height 32;
		PainChance 200;
		Mass 50;
		Speed 9;
		Damage 5;   // bare constant stays bare
		Scale 1.5;
		Species "HORNET";
		DamageType "hornet";
		DamageFactor "hornet", 0;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MaxTargetRange 256;
		BloodColor "yellow";
		DeathSound "Hornet/Death";
		Monster;
		+THRUSPECIES
		+FLOAT
		+NOGRAVITY
		+FLOATBOB
		+NOBLOODDECALS
		+SPAWNFLOAT
		+MISSILEMORE
		+DONTOVERLAP
		+BOSS
		+NORADIUSDMG
		+NOFEAR
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: Dropitem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",20 -- DRLA stripped per owner 2026-08-05
		Tag "Queen Bee";
	}
	States
	{
	Spawn:
		WASP A 0;
		WASP AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_BlackLSoul2",random(-16,16),random(-16,16),random(-6,10),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		WASP AAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_BlackLSoul2",random(-16,16),random(-16,16),random(-6,10),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		Goto Scripted;
	Scripted:
		WASP A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackSoul") -- announcers dropped per owner
		Goto Idle;
	Idle:
		WASP A 0;
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP AB 2 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 0 A_JumpIfCloser(256,"Dodge");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP AB 2 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Dodge:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 1 A_FastChase;
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP A 1 A_FaceTarget;
		WASP B 1 A_FastChase;
		WASP B 1 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP A 2 A_FaceTarget;
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP A 2 A_Jump(186,"MINIONS");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP B 2 A_SkullAttack;
		Goto See;
	MINIONS:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP AB 3 A_PainAttack("RS_BlackLSoul2");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP BA 3 A_DualPainAttack("RS_BlackLSoul2");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP BA 3 A_PainAttack("RS_BlackLSoul2");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP AB 3 A_DualPainAttack("RS_BlackLSoul2");
		WASP A 0 A_Jump(102,"MINIONS");
		Goto See;
	Pain:
		WASP B 1;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP B 2;
		Goto Dodge;
	Death:
		WASP C 1 A_StopSoundEx("SoundSlot7");
		WASP C 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FLOATBOB",0)
		WASP C 0 A_ScreamAndUnblock;
	Fall:
		WASP C 1 A_CheckFloor("Splat");
		Loop;
	Splat:
		WASP D 1 A_Stop;
		WASP D 0 A_PlaySound("Hornet/Splat");
		WASP D -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK ("Queen Bee").  CH: lostsouls.txt:1413.  The live one:
// 1500hp, stinger strafes, seeker swarm, revenant loads, bee minions.
// ---------------------------------------------------------------------------
class RS_BlackLSoul3 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Obituary "%o was killed by the queen bee";
		Health 1500;
		Radius 16;
		Height 32;
		PainChance 128;
		Mass 50;
		Speed 9;
		Damage 5;   // bare constant stays bare
		Scale 2.0;
		Species "HORNET";
		DamageType "hornet";
		DamageFactor "hornet", 0;
		DamageFactor "Heroic", 3.0;
		DamageFactor "fire", 2.0;   // CH lists fire twice (bare and quoted)
		DamageFactor "DIMp", 0;
		RadiusDamageFactor 0.5;
		PainChance "DIMp", 0;
		MaxTargetRange 256;
		BloodColor "yellow";
		DeathSound "Hornet/Death";
		Monster;
		+THRUSPECIES
		+FLOAT
		+NOGRAVITY
		+NOBLOODDECALS
		+SPAWNFLOAT
		+MISSILEMORE
		+DONTOVERLAP
		+BOSS
		+NOFEAR
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		// CH: Dropitem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",20 -- DRLA stripped per owner 2026-08-05
		Tag "Queen Bee";
	}
	States
	{
	Spawn:
		WASP A 0;
		WASP AAA 0 A_SpawnItemEx("RS_BlackLSoul2",random(-16,16),random(-16,16),random(-6,10),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		WASP AAA 0 A_SpawnItemEx("RS_BlackLSoul2",random(-16,16),random(-16,16),random(-6,10),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		WASP A 0 A_SpawnItemEx("RS_BLSoulAss",0,0,-12,0,0,0,0,SXF_SETMASTER);
		Goto Scripted;
	Scripted:
		WASP A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackSoul") -- announcers dropped per owner
		Goto Idle;
	Idle:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP AB 2 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 0 A_JumpIfCloser(256,"Dodge");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP AB 2 A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Dodge:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 1 A_FastChase;
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP A 1 A_FaceTarget;
		WASP B 1 A_FastChase;
		WASP B 1 A_FaceTarget;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP A 2 A_FaceTarget;
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP A 2 A_Jump(255,"MINIONS","Stinger","HurtSoul");
		WASP B 2 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	HurtSoul:
		WASP A 12 A_FaceTarget;
		WASP B 8 Bright A_CustomMissile("RS_BSoulHellNo",0,0,0);
		WASP A 0 A_Jump(128,"Stinger");
		Goto See;
	Stinger:
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 0 A_Jump(128,"ThatWay");
		TNT1 A 0 A_JumpIfHealthLower(800,"FasterBee");
		WASP A 5 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 5 Bright A_Stop;
		TNT1 A 0 A_Jump(32,"ThatWay");
		WASP A 5 ThrustThing(int(angle*256/360+192),20,0,0);   // CH: ThrustThing(angle*256/360+192,20,0,0)
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright A_Stop;
		Goto See;
	FasterBee:
		WASP A 3 ThrustThing(int(angle*256/360+64),25,0,0);   // CH: ThrustThing(angle*256/360+64,25,0,0)
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 1 Bright A_Stop;
		TNT1 A 0 A_Jump(32,"FasterBee2");
		WASP A 3 ThrustThing(int(angle*256/360+192),25,0,0);   // CH: ThrustThing(angle*256/360+192,25,0,0)
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright A_Stop;
		Goto See;
	FasterBee2:
		WASP A 3 ThrustThing(int(angle*256/360+192),25,0,0);   // CH: ThrustThing(angle*256/360+192,25,0,0)
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 1 Bright A_Stop;
		TNT1 A 0 A_Jump(32,"FasterBee");
		WASP A 3 ThrustThing(int(angle*256/360+64),25,0,0);   // CH: ThrustThing(angle*256/360+64,25,0,0)
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 2 Bright;
		WASP B 2 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright A_Stop;
		Goto See;
	ThatWay:
		TNT1 A 0 A_JumpIfHealthLower(800,"FasterBee2");
		WASP A 5 ThrustThing(int(angle*256/360+192),20,0,0);   // CH: ThrustThing(angle*256/360+192,20,0,0)
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 5 Bright A_Stop;
		WASP A 5 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger2",0,0,0);
		WASP A 5 Bright;
		WASP B 5 Bright A_CustomMissile("RS_BSoulStinger1",0,0,0);
		WASP A 5 Bright A_Stop;
		Goto See;
	MINIONS:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP A 0 A_JumpIfCloser(256,"Dodge");
		WASP AB 8 A_Stop;
		WASP A 6 A_CustomMissile("RS_RedRevLoad",18,0,0);
		WASP ABABABAB 4 Bright;
		WASP A 6 A_CustomMissile("RS_RedRevLoad",18,0,0);
		WASP ABABABAB 4 Bright;
		WASP AB 3 A_PainAttack("RS_BlackLSoul2");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP BA 3 A_DualPainAttack("RS_BlackLSoul2");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP BA 3 A_PainAttack("RS_BlackLSoul2");
		WASP A 0 A_CustomMissile("RS_SparkPuff1",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		WASP AB 3 A_DualPainAttack("RS_BlackLSoul2");
		Goto See;
	Pain:
		WASP B 1;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WASP B 2;
		Goto Dodge;
	Death:
		WASP C 1 A_StopSoundEx("SoundSlot7");
		WASP C 0 A_ScreamAndUnblock;
	Fall:
		WASP C 1 A_CheckFloor("Splat");
		Loop;
	Splat:
		WASP D 1 A_Stop;
		WASP D 0 A_PlaySound("Hornet/Splat");
		WASP D -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The bee.  CH: lostsouls.txt:1771.  Minion -- no tier, no token
// (-COUNTKILL in CH).  Spawned by the queens and the gray hive.
// ---------------------------------------------------------------------------
class RS_BlackLSoul2 : Actor
{
	Default
	{
		Obituary "%o couldn't take a little sting";
		Health 18;
		Species "HORNET";
		Radius 14;
		Height 26;
		Mass 30;
		Speed 18;
		PainChance 255;
		Scale 0.5;
		DamageFactor "fire", 0.2;
		DamageFactor "plasma", 0.4;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MaxTargetRange 256;
		BloodColor "yellow";
		DeathSound "Hornet/Death";
		Monster;
		+FLOAT
		+THRUSPECIES
		+NOGRAVITY
		+FLOATBOB
		+NOBLOODDECALS
		+DONTHARMCLASS
		+SPAWNFLOAT
		+DONTOVERLAP
		-NORADIUSDMG
		-COUNTKILL
		DropItem "HealthBonus", 88;
		DropItem "RS_implyingclip", 78;
		DropItem "RS_CH_Shell", 42;
		DropItem "RS_CH_Cell", 24;
		Tag "Bee";
	}
	States
	{
	Spawn:
		WASP A 0 NoDelay A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP AB 2 A_Look;
		Loop;
	See:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 0 A_JumpIfCloser(256,"Dodge");
		WASP AB 2 A_Chase;
		Loop;
	Dodge:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 1 A_FastChase;
		WASP A 1 A_FaceTarget;
		WASP B 1 A_FastChase;
		WASP B 1 A_FaceTarget;
		Goto See;
	Missile:
		WASP A 0 A_PlaySoundEx("Hornet/Fly","SoundSlot7",1,-1);
		WASP A 2 A_FaceTarget;
		WASP B 2 A_SkullAttack(30);
		WASP B 10 A_JumpIfCloser(16,"Melee");
		WASP B 10 A_CheckFloor("Death");
		WASP B 10 A_JumpIfCloser(16,"Melee");
		WASP B 10 A_CheckFloor("Death");
		WASP B 10 A_JumpIfCloser(16,"Melee");
		WASP B 10 A_CheckFloor("Death");
		WASP B 10 A_JumpIfCloser(16,"Melee");
		WASP B 10 A_CheckFloor("Death");
		WASP B 10 A_JumpIfCloser(16,"Melee");
		WASP B 10 A_CheckFloor("Death");
		WASP B 10 A_JumpIfCloser(16,"Melee");
		WASP B 10 A_CheckFloor("Death");
		Goto See;
	Melee:
		WASP A 5 A_FaceTarget;
		WASP B 3 A_CustomMeleeAttack(random(1,2),"GENTLES1");
		Goto See;
	Death:
		WASP C 1 A_Die;
		WASP C 1 A_StopSoundEx("SoundSlot7");
		WASP C 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FLOATBOB",0)
		WASP C 0 A_ScreamAndUnblock;
	Fall:
		WASP C 1 A_CheckFloor("Splat");
		Loop;
	Splat:
		WASP D 1 A_Stop;
		WASP D 1 A_PlaySound("Hornet/Splat");
		WASP D 64;
		WASP D 1 A_SetTranslucent(0.9);
		WASP D 1 A_SetTranslucent(0.8);
		WASP D 1 A_SetTranslucent(0.7);
		WASP D 1 A_SetTranslucent(0.6);
		WASP D 1 A_SetTranslucent(0.5);
		WASP D 1 A_SetTranslucent(0.4);
		WASP D 1 A_SetTranslucent(0.3);
		WASP D 1 A_SetTranslucent(0.2);
		WASP D 1 A_SetTranslucent(0.1);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE ("The shifter").  CH: lostsouls.txt:1906.  4500hp; takes
// revenant, baron, and archvile forms, laying eggs that hatch more.
// ---------------------------------------------------------------------------
class RS_WhiteLSoul2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "%o met the randomized terror of white lost soul";
		Health 4500;
		Radius 16;
		Height 32;
		Mass 400;
		Speed 19;
		PainChance 22;
		RenderStyle "Add";
		Alpha 0.8;
		AttackSound "skull/melee";
		PainSound "WSOUL/hurt";
		DeathSound "WSOUL/Death";
		ActiveSound "WSOUL/Sight";
		Species "whitelsoul";
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 0.2;   // CH lists ice twice (quoted and bare)
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+FLOAT
		+BOSS
		-NORADIUSDMG
		+NOGRAVITY
		+NOICEDEATH
		+MISSILEMORE
		+DONTFALL
		+NOBLOOD
		+DONTMORPH
		+NOTARGET
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack", 188;
		DropItem "RS_CH_CellPack", 188;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_BFG9000", 78;
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_PlasmaRifle", 182;
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLLegendaryWeaponSpawner",4 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",16 -- DRLA stripped per owner 2026-08-05
		Tag "The shifter";
	}
	States
	{
	Spawn:
		ETHS A 0;
		Goto Scripted;
	Scripted:
		ETHS A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSoul") -- announcers dropped per owner
		Goto Idle;
	Idle:
		ETHS ABCD 10 Bright A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ETHS A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag(nopain,false)
		ETHS AABB 3 Bright A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ETHS CCDD 3 Bright A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		ETHS C 0 { bNOPAIN = true; }   // CH: A_Changeflag(Nopain,true)
		ETHS C 3 Bright A_PlaySound("WSOUL/form");
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ETHS E 3 Bright;
		ETHS F 3 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS FF 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS P 3 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS PP 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS QQQRRR 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS R 1 Bright A_Jump(256,"revform","archform","baronform");
		Goto See;
	revform:
		SKEL L 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		SKEL L 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		SKEL L 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		SKEL LLLLLLLL 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKEL L 5 A_PlaySound("skeleton/sight");
		SKEL L 4;
		SKEL ABGG 2 A_FaceTarget;
		SKEL J 6 A_FaceTarget;
		SKEL K 0 A_CustomMissile("RevenantTracer",50,7,5);   // vanilla RevenantTracer, as in CH
		SKEL K 0 A_CustomMissile("RevenantTracer",50,-7,-5);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_AcidBlast1",50,7,12);
		SKEL K 0 A_CustomMissile("RS_AcidBlast1",50,-7,-12);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_zap7",50,7,1);
		SKEL K 0 A_CustomMissile("RS_zap7",50,-7,-1);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_Purp1",50,7,9);
		SKEL K 0 A_CustomMissile("RS_Purp1",50,-7,-9);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_Homer1",50,7,15);
		SKEL K 4 A_CustomMissile("RS_Homer1",50,-7,-15);
		SKEL L 4 A_PainAttack("RS_RevEgg",0,PAF_NOSKULLATTACK);
		SKEL L 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		SKEL L 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		SKEL L 0 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		SKEL LLLLLLLL 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	baronform:
		BOSS H 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		BOSS H 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		BOSS H 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		BOSS HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BOSS H 8 A_PlaySound("baron/sight");
		BOSS EEF 8 A_FaceTarget;
		BOSS G 7 A_BruisAttack;   // vanilla BaronBall, as in CH
		BOSS PQ 5 A_FaceTarget;
		BOSS R 5;   // CH: ACS_NamedExecuteWithResult("BaronMissile",1) -- ACS lead-predicted BaronBall shot (CHACS.acs:54); ACS not ported, flagged for owner
		BOSS EF 5 A_FaceTarget;
		BOSS G 5 A_CustomMissile("RS_Spspit2",32,5,random(-1,1));
		BOSS PQ 5 A_FaceTarget;
		BOSS R 3 A_CustomMissile("RS_Spspit2",32,5,random(-8,8));
		BOSS EF 3 A_FaceTarget;
		BOSS G 3 A_CustomMissile("RS_SmashBalls2",32,5,random(-8,8));
		BOSS PQ 6 A_FaceTarget;
		BOSS R 6 A_CustomMissile("RS_SmashBalls2",32,5,random(-1,1));
		BOSS EF 5 A_FaceTarget;
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,1);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,3);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-3);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,6);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-6);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,9);
		BOSS G 5 A_CustomMissile("RS_BaronWave",32,5,-9);
		BOSS PQ 5 A_FaceTarget;
		BOSS R 5 A_CustomMissile("RS_Spear11",32,5,random(-1,1));
		BOSS H 5;
		BOSS H 8 A_PainAttack("RS_HKEgg",0,PAF_NOSKULLATTACK);
		BOSS H 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		BOSS H 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		BOSS H 0 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		BOSS HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	archform:
		VILE Q 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		VILE Q 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		VILE Q 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		VILE QQQQQQQQ 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		VILE Q 8 A_PlaySound("vile/sight");
		VILE G 5 A_FaceTarget;
		VILE H 4 A_SpawnItemEx("RS_BlueGash",0,0,32);
		VILE IJKLM 7 Bright A_FaceTarget;
		VILE N 1 Bright A_CustomMissile("RS_BigBolt2",32,0);
		VILE G 0 A_VileStart;
		VILE G 7 Bright A_FaceTarget;
		VILE H 6 Bright A_VileTarget("RS_ArcRing1");
		VILE IJKLM 5 Bright A_FaceTarget;
		VILE N 4 Bright A_VileTarget("RS_ArcRing1");
		VILE O 0 A_CheckSight("See");
		VILE O 7 Bright A_VileTarget("RS_ArcRing2");
		VILE O 4 Bright A_CustomMissile("RS_ArcRing2",12,0,random(-3,3));
		VILE O 2 Bright A_CustomMissile("RS_ArcRing2",12,0,random(-3,3));
		VILE P 12 Bright;
		VILE Q 3 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-24,24),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);   // CH passes the flag word in the xvel slot; kept verbatim
		VILE Q 2 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-24,24),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		VILE Q 1 Bright A_SpawnItemEx("RS_ArchSpawnerOrb",random(-24,24),random(-24,24),6,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		VILE Q 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		VILE Q 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		VILE Q 8 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		Goto See;
	Pain:
		ETHS G 3 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ETHS G 3 Bright A_Pain;
		Goto See;
	Death:
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKEL L 0 A_PlaySound("Skeleton/death");
		SKEL LMNOP 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BOSS I 0 A_PlaySound("Baron/death");
		BOSS IJKLMNO 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		VILE Q 0 A_PlaySound("Vile/death");
		VILE QRSTUVWXYZ 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS HIJKLMN 6 Bright;
		ETHS O 12 Bright A_ScreamAndUnblock;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE EX ("The vengeful soul").  CH: lostsouls.txt:2225.
// 12500hp; adds caco / HK / mancubus forms, twin orbiting skulls, the ice
// beam, and the charging soul shot.
// ---------------------------------------------------------------------------
class RS_WhiteLSoulEX : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "%o got spooked out by the white lost soul EX";
		Health 12500;
		Radius 16;
		Height 32;
		Mass 400;
		Speed 19;
		RenderStyle "Add";
		Alpha 0.95;
		PainChance 32;
		AttackSound "skull/melee";
		PainSound "WSOUL/hurt";
		DeathSound "WSOUL/Death";
		ActiveSound "WSOUL/Sight";
		Species "whitelsoul";
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 0.2;   // CH lists ice twice (quoted and bare)
		DamageFactor "playervoid", 0.5;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+FLOAT
		+NOGRAVITY
		+NOICEDEATH
		+DONTMORPH
		+MISSILEMORE
		+BOSS
		-NORADIUSDMG
		+DONTFALL
		+NOBLOOD
		+NOTARGET
		+NOCLIP
		+DONTBLAST
		+DONTTHRUST
		+NODAMAGETHRUST
		+NOFEAR
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell", 174;
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_PlasmaRifle", 182;
		// CH: Dropitem "RareArmorPool",128 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLDemonicWeaponSpawner",12 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLLegendaryWeaponSpawner",8 -- DRLA stripped per owner 2026-08-05
		// CH: Dropitem "RLUniqueWeaponSpawner",18 -- DRLA stripped per owner 2026-08-05
		Tag "The vengeful soul";
	}
	States
	{
	Spawn:
		ETHS A 0;
		Goto Scripted;
	Scripted:
		ETHS A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSoul") -- announcers dropped per owner
		ETHS A 0 A_Log("A chill runs down your spine");
		TNT1 A 0 A_SpawnItemEx("RS_SkullWSoulEX1",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 0 A_SpawnItemEx("RS_SkullWSoulEX2",-32,-32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		Goto Idle;
	Idle:
		ETHS ABCD 10 Bright A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ETHS A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag(nopain,false)
		ETHS AA 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_LSoulEXShade",-2,0,1,1,0,1,-180,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX1",512,0,CPXF_EXACT);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX2",512,0,CPXF_EXACT);
		ETHS BB 3 Bright A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_LSoulEXShade",-2,0,1,1,0,1,-180,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX1",512,0,CPXF_EXACT);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX2",512,0,CPXF_EXACT);
		ETHS CC 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_LSoulEXShade",-2,0,1,1,0,1,-180,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX1",512,0,CPXF_EXACT);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX2",512,0,CPXF_EXACT);
		ETHS DD 3 Bright A_Chase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_LSoulEXShade",-2,0,1,1,0,1,-180,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX1",512,0,CPXF_EXACT);
		TNT1 A 0 A_CheckProximity("AddOns","RS_SkullWSoulEX2",512,0,CPXF_EXACT);
		Loop;
	AddOns:
		ETHS CEF 8 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_SkullWSoulEX1",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 0 A_SpawnItemEx("RS_SkullWSoulEX2",-32,-32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ETHS FEC 8 Bright;
		Goto See;
	Missile:
		ETHS C 0 { bNOPAIN = true; }   // CH: A_Changeflag(Nopain,true)
		ETHS C 2 Bright A_PlaySound("WSOUL/form");
		ETHS E 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ETHS FFFF 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_Jump(128,"A1","A2","A3");
	Miss2:
		TNT1 A 0 A_Jump(255,"SoulShot","Beam","Transformers");
		Goto See;
	Transformers:
		ETHS F 6 Bright A_SetScale(0.85,1.2);
		ETHS F 6 Bright A_SetScale(0.70,1.4);
		ETHS F 6 Bright A_SetScale(0.55,1.6);
		TNT1 AAAAAAAAAAAA 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_WSSmore",random(-8,8),random(-8,8),1,random(4,20),0,random(1,15),random(-359,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_JumpIfHealthLower(6000,"RollOut");
		TNT1 A 0 A_Jump(255,"HK","REV","CACO");
		Goto See;
	CACO:
		SKEL LLLLLLLL 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HEAD D 5 A_PlaySound("caco/sight");
		HEAD ABCC 2 A_FaceTarget;
		HEAD B 5 A_FaceTarget;
		HEAD C 3;
		HEAD D 1 Bright A_CustomMissile("CacodemonBall",50,7,-4);   // vanilla CacodemonBall, as in CH
		HEAD D 1 Bright A_CustomMissile("CacodemonBall",50,7,-2);
		HEAD D 1 Bright A_CustomMissile("CacodemonBall",50,7,0);
		HEAD D 1 Bright A_CustomMissile("CacodemonBall",50,7,2);
		HEAD D 1 Bright A_CustomMissile("CacodemonBall",50,7,4);
		HEAD CBC 3 A_FaceTarget;
		HEAD DDD 2 Bright A_CustomMissile("RS_Cacospit1",32,0,random(-7,7));
		HEAD CBC 3 A_FaceTarget;
		HEAD D 4 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-1,1));
		HEAD D 4 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-3,3));
		HEAD D 4 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-5,5));
		HEAD D 4 Bright A_CustomMissile("RS_CacoFire2",32,0,random(-4,4));
		HEAD CBC 3 A_FaceTarget;
		HEAD D 1 Bright;
		HEAD D 0 A_CustomMissile("RS_CacoFire4",32,0,8);
		HEAD D 0 A_CustomMissile("RS_CacoFire4",32,0,-8);
		HEAD D 0 A_CustomMissile("RS_CacoFire4",32,0,21);
		HEAD D 0 A_CustomMissile("RS_CacoFire4",32,0,-21);
		HEAD D 5 Bright A_CustomMissile("RS_CacoFire3",32,0,random(-1,1));
		HEAD CBC 3 A_FaceTarget;
		HEAD DDDD 2 A_CustomMissile("RS_SpitFireCaco",35,0,random(-90,90));
		HEAD CBC 3 A_FaceTarget;
		HEAD D 0 A_CustomMissile("RS_CrackodemonBall",24,0,0,1);
		HEAD D 0 A_CustomMissile("RS_CrackodemonBall",24,0,-8,1);
		HEAD D 5 Bright A_CustomMissile("RS_CrackodemonBall",24,0,8,1);
		HEAD CBC 2 A_FaceTarget;
		HEAD D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,16,1);
		HEAD D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,12,1);
		HEAD B 0 A_FaceTarget;
		HEAD C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,8,1);
		HEAD C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,4,1);
		HEAD B 0 A_FaceTarget;
		HEAD D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,0,1);
		HEAD D 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-4,1);
		HEAD B 0 A_FaceTarget;
		HEAD C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-8,1);
		HEAD C 2 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-12,1);
		HEAD D 0 A_FaceTarget;
		HEAD D 6 Bright A_CustomMissile("RS_CrackodemonBall",24,0,-16,1);
		HEAD D 5 Bright A_CustomMissile("RS_SBombCaco",24,0,0,1);
		SKEL LLLLLLLL 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		HEAD A 4;
		Goto See;
	REV:
		SKEL L 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		SKEL L 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		SKEL L 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		SKEL LLLLLLLL 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKEL L 5 A_PlaySound("skeleton/sight");
		SKEL L 4;
		SKEL ABGG 2 A_FaceTarget;
		SKEL J 6 A_FaceTarget;
		SKEL K 0 A_CustomMissile("RevenantTracer",50,7,5);   // vanilla RevenantTracer, as in CH
		SKEL K 0 A_CustomMissile("RevenantTracer",50,-7,-5);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_AcidBlast1",50,7,12);
		SKEL K 0 A_CustomMissile("RS_AcidBlast1",50,-7,-12);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_zap7",50,7,1);
		SKEL K 0 A_CustomMissile("RS_zap7",50,-7,-1);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_Purp1",50,7,9);
		SKEL K 0 A_CustomMissile("RS_Purp1",50,-7,-9);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_Homer1",50,7,15);
		SKEL K 0 A_CustomMissile("RS_Homer1",50,-7,-15);
		SKEL J 4 A_FaceTarget;
		SKEL K 7 A_CustomMissile("RS_RedDeathRev",50,0,0);
		SKEL KL 4;
		SKEL L 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		SKEL L 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		SKEL L 0 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		SKEL LLLLLLLL 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	HK:
		BOS2 H 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		BOS2 H 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		BOS2 H 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		BOS2 HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BOS2 H 8 A_PlaySound("knight/sight");
		BOS2 EEF 8 A_FaceTarget;
		BOS2 G 7 A_BruisAttack;   // vanilla BaronBall, as in CH
		BOS2 PQ 5 A_FaceTarget;
		BOS2 R 5;   // CH: ACS_NamedExecuteWithResult("BaronMissile",1) -- ACS lead-predicted BaronBall shot (CHACS.acs:54); ACS not ported, flagged for owner
		BOS2 EF 5 A_FaceTarget;
		BOS2 GGGGG 1 A_CustomMissile("RS_BaronsBlueBalls",32,5,random(-1,1));
		BOS2 PQ 5 A_FaceTarget;
		BOS2 RRR 1 A_CustomMissile("RS_BaronsBlueBalls",32,5,random(-8,8));
		BOS2 EF 3 A_FaceTarget;
		BOS2 G 3 A_CustomMissile("RS_HKBolt2",32,5,random(-8,8));
		BOS2 PQ 6 A_FaceTarget;
		BOS2 R 6 A_CustomMissile("RS_HKBolt2",32,5,random(-1,1));
		BOS2 EF 5 A_FaceTarget;
		BOS2 G 5 A_CustomMissile("RS_BigHK",32,5,1);
		BOS2 PQ 5 A_FaceTarget;
		BOS2 R 5 A_CustomMissile("RS_THEBEEHK",32,5,random(-1,1));
		BOS2 H 8;
		BOS2 H 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		BOS2 H 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		BOS2 H 0 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		BOS2 HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	RollOut:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(255,"Baron","Vile","Mancu");
		Goto See;
	Baron:
		BOSS H 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		BOSS H 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		BOSS H 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		BOSS HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BOSS H 8 A_PlaySound("baron/sight");
		BOSS EEF 8 A_FaceTarget;
		BOSS G 7 A_BruisAttack;   // vanilla BaronBall, as in CH
		BOSS PQ 5 A_FaceTarget;
		BOSS R 5;   // CH: ACS_NamedExecuteWithResult("BaronMissile",1) -- ACS lead-predicted BaronBall shot (CHACS.acs:54); ACS not ported, flagged for owner
		BOSS EF 5 A_FaceTarget;
		BOSS G 5 A_CustomMissile("RS_Spspit2",32,5,random(-1,1));
		BOSS PQ 5 A_FaceTarget;
		BOSS R 3 A_CustomMissile("RS_Spspit2",32,5,random(-8,8));
		BOSS EF 3 A_FaceTarget;
		BOSS G 3 A_CustomMissile("RS_SmashBalls2",32,5,random(-8,8));
		BOSS PQ 6 A_FaceTarget;
		BOSS R 6 A_CustomMissile("RS_SmashBalls2",32,5,random(-1,1));
		BOSS EF 5 A_FaceTarget;
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,1);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,3);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-3);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,6);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,-6);
		BOSS G 0 A_CustomMissile("RS_BaronWave",32,5,9);
		BOSS G 5 A_CustomMissile("RS_BaronWave",32,5,-9);
		BOSS PQ 5 A_FaceTarget;
		BOSS R 5 A_CustomMissile("RS_Spear11",32,5,random(-1,1));
		BOSS EF 5 A_FaceTarget;
		BOSS H 8 A_CustomMissile("RS_BaronStar",32,5,1);
		BOSS H 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		BOSS H 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		BOSS H 0 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		BOSS HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	Vile:
		VILE Q 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		VILE Q 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		VILE Q 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		VILE QQQQQQQQ 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		VILE Q 8 A_PlaySound("vile/sight");
		VILE G 5 A_FaceTarget;
		VILE H 4 A_SpawnItemEx("RS_BlueGash",0,0,32);
		VILE IJKLM 7 Bright A_FaceTarget;
		VILE N 1 Bright A_CustomMissile("RS_BigBolt2",32,0);
		VILE G 0 A_VileStart;
		VILE G 7 Bright A_FaceTarget;
		VILE H 6 Bright A_VileTarget("RS_ArcRing1");
		VILE IJKLM 5 Bright A_FaceTarget;
		VILE N 4 Bright A_VileTarget("RS_ArcRing1");
		VILE O 0 A_CustomMissile("RS_ReAComet",32,0);
		VILE O 7 Bright A_VileTarget("RS_ArcRing2");
		VILE O 4 Bright A_CustomMissile("RS_ArcRing2",12,0,random(-3,3));
		VILE O 2 Bright A_CustomMissile("RS_ArcRing2",12,0,random(-3,3));
		VILE P 12 Bright;
		VILE QQ 3 Bright A_CustomMissile("RS_BVileOrb1",32,0,random(-19,19));
		VILE QQQ 2 Bright A_CustomMissile("RS_BVileOrb1",32,0,random(-19,19));
		VILE QQQQQ 1 Bright A_CustomMissile("RS_BVileOrb1",32,0,random(-19,19));
		VILE Q 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		VILE Q 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		VILE Q 8 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		Goto See;
	Mancu:
		BOSS H 0 { bFLOAT = false; }   // CH: A_Changeflag(Float,false)
		BOSS H 0 { bNOGRAVITY = false; }   // CH: A_Changeflag(nogravity,false)
		BOSS H 0 { bDONTFALL = false; }   // CH: A_Changeflag(dontfall,false)
		BOSS HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		FATT G 8 A_PlaySound("fatso/sight");
		FATT G 20 A_FatRaise;
		FATT H 7 Bright A_FatAttack1;   // vanilla FatShot volley, as in CH
		FATT IG 4 A_FaceTarget;
		FATT H 7 Bright A_FatAttack2;
		FATT IG 4 A_FaceTarget;
		FATT H 7 Bright A_FatAttack3;
		FATT IG 4 A_FaceTarget;
		FATT H 10 Bright A_CustomMissile("RS_GreenBomb1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_GreenBomb1",20,-13,random(-5,5));
		FATT IG 5 A_FaceTarget;
		FATT H 10 Bright A_CustomMissile("RS_GreenBomb1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_GreenBomb1",20,-13,random(-5,5));
		FATT IG 5 A_FaceTarget;
		FATT H 10 Bright A_CustomMissile("RS_GreenBomb1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_GreenBomb1",20,-13,random(-5,5));
		FATT IG 5 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_Bluewave1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_Bluewave1",20,-13,random(-8,8));
		FATT IG 5 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_Bluewave1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_Bluewave1",20,-13,random(-8,8));
		FATT IG 5 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_Bluewave1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_Bluewave1",20,-13,random(-8,8));
		FATT IG 5 A_FaceTarget;
		FATT H 0 A_CustomMissile("RS_BlueFT",12,0);
		FATT H 10 Bright A_FaceTarget;
		FATT I 7 Bright A_FaceTarget;
		FATT G 8 Bright A_CustomMissile("RS_BlueFT2",20,0);
		FATT H 5 Bright A_CustomMissile("RS_BlueFT2",20,0,random(-4,4));
		FATT I 4 Bright A_CustomMissile("RS_BlueFT2",20,0,random(-9,9));
		FATT H 3 Bright A_CustomMissile("RS_BlueFT2",20,0,random(-16,16));
		FATT IG 5 A_FaceTarget;
		FATT H 11 Bright A_CustomMissile("RS_PurpleBomb1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_PurpleBomb1",20,-13,random(-8,8));
		FATT IG 7 A_FaceTarget;
		FATT H 11 Bright A_CustomMissile("RS_PurpleBomb1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_PurpleBomb1",20,-13,random(-8,8));
		FATT IG 7 A_FaceTarget;
		FATT H 11 Bright A_CustomMissile("RS_PurpleBomb1",20,13,random(-5,5));
		FATT H 0 A_CustomMissile("RS_PurpleBomb1",20,-13,random(-8,8));
		FATT IG 5 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-3,3),0);
		FATT H 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		FATT I 4 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-3,3),0);
		FATT H 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		FATT I 4 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-3,3),0);
		FATT H 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		FATT I 4 A_FaceTarget;
		FATT H 8 Bright A_CustomMissile("RS_RocketShotFatso",35,42,random(-3,3),0);
		FATT H 2 Bright A_CustomMissile("RS_RocketShotFatso",34,-39,random(-6,6),0);
		FATT IG 5 A_FaceTarget;
		FATT H 0 A_CustomMissile("RS_FatsoShotYE",36,-12,random(-3,3));
		FATT H 5 Bright A_CustomMissile("RS_FatsoShotYE",36,12,random(-3,3));
		FATT I 5 A_FaceTarget;
		FATT H 0 A_CustomMissile("RS_FatsoShotYE",36,-12,random(-3,3));
		FATT H 5 Bright A_CustomMissile("RS_FatsoShotYE",36,12,random(-3,3));
		FATT I 5 A_FaceTarget;
		FATT H 0 A_CustomMissile("RS_FatsoShotYE",36,-12,random(-3,3));
		FATT H 5 Bright A_CustomMissile("RS_FatsoShotYE",36,12,random(-3,3));
		FATT IG 5 A_FaceTarget;
		FATT H 1 Bright;
		HBST E 0 A_CustomMissile("RS_Shot2Fatso",32,20,random(-1,1));
		HBST E 0 A_CustomMissile("RS_Shot2Fatso",32,-20,random(-1,1));
		FATT H 5 Bright;
		FATT HHHIGB 4;
		BOSS H 0 { bFLOAT = true; }   // CH: A_Changeflag(Float,true)
		BOSS H 0 { bNOGRAVITY = true; }   // CH: A_Changeflag(nogravity,true)
		BOSS H 0 { bDONTFALL = true; }   // CH: A_Changeflag(dontfall,true)
		BOSS HHHHHHHH 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	Beam:
		ETHS F 4 Bright;
		ETHS EF 8 Bright A_FaceTarget;
		ETHS FFFFFFFFFFFFFFFFFFFFFFFFFFF 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 10 Bright A_CustomMissile("RS_SoulexBeam",32,0,0);
		ETHS FE 10 Bright;
		Goto See;
	SoulShot:
		ETHS F 4 Bright;
		ETHS EF 8 Bright A_FaceTarget;
		ETHS F 1 Bright A_SetScale(1.15,1.15);
		ETHS F 1 Bright A_SetScale(1.3,1.3);
		ETHS F 10 Bright A_CustomMissile("RS_SOULEXSoulCharge",32,0,0);
		ETHS F 1 Bright A_SetScale(1.15,1.15);
		ETHS F 1 Bright A_SetScale(1.0,1.0);
		Goto See;
	A1:
		ETHS GG 0 A_RadiusGive("RS_WhiteSoulAdsOff2",700,RGF_MONSTERS);
		Goto Miss2;
	A2:
		ETHS GG 0 A_RadiusGive("RS_WhiteSoulAdsOff3",700,RGF_MONSTERS);
		Goto Miss2;
	A3:
		ETHS GG 0 A_RadiusGive("RS_WhiteSoulAdsOff4",700,RGF_MONSTERS);
		Goto Miss2;
	Pain:
		ETHS G 3 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ETHS G 3 Bright A_Pain;
		ETHS G 3 Bright A_Jump(64,"Reset");
		Goto See;
	Reset:
		ETHS GGGG 0 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS GG 1 A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS GG 0 A_RadiusGive("RS_WhiteSoulAdsOff",700,RGF_MONSTERS);
		ETHS GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG 0 A_Wander;
		TNT1 A 0 A_SpawnItemEx("RS_SkullWSoulEX1",32,32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 0 A_SpawnItemEx("RS_SkullWSoulEX2",-32,-32,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		ETHS AB 1 Bright;
		Goto See;
	Death:
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 2 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS F 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SKEL L 0 A_PlaySound("pain/death");
		PAIN HIJKLM 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BOSS I 0 A_PlaySound("baby/death");
		BSPI JKLMNOP 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		VILE Q 0 A_PlaySound("Vile/death");
		VILE QRSTUVWXYZ 1 Bright A_CustomMissile("RS_WSSmore",16,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		ETHS HIJKLMN 6 Bright;
		ETHS O 12 Bright A_ScreamAndUnblock;
		Stop;
	}
}
