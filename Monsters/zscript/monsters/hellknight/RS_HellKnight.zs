// ============================================================================
// RS_HellKnight.zs -- Colourful Hell Hell Knight family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Hellknights.txt (3,546 lines,
// read whole). Every actor cites its CH line. Support: RS_HellKnightFX.zs
// (see its header for cross-lane notes, proven-missing assets, and
// standing strips).
// Tier ladder as before: CH icon index -- 1 Common, 2 Green, 3 Blue,
// 4 Purple, 5 Yellow (Orange Bruiser), 6 Red (Knightmare), 7 FireBlu,
// 8 Gray, 9 Abyss (Bruiser), 10 Black (Terminator, + MK II EX), 11 White
// (Ghost of 1993), 12 Cyan, 13 Brown (Lion). Minions (SpecialImp,
// SpecialSpectre2, MiniPhantom, shields) get no token.
//
// BRUR FRAME COVERAGE -- CLOSED 2026-08-06.  BRUR ships frames A-N and
// nothing further: 91 lumps, 8-rotation, A/B/C/D and K/L/M mirrored
// (BRURA2A8, BRURK3K7 ...), E-J and N unmirrored (BRURE1..BRURE8).  Both
// halves of every mirrored lump name the SAME frame letter, so there are no
// hidden frames past N.  Identical in CH's own sprites/ -- the art was never
// drawn, it was not lost in import.
//   RS_RedHK's Raise (below) was CH's one reference past the end of the set.
// CH Hellknights.txt:2055 reads `BRUR WVUTSRQPONMLKJIHGFEDCBA 2`, which is
// the BRUD raise line (CH :729 and :1797, ours at :672 and :1491) with the
// prefix swapped to this actor's body sprite and the frame list left alone.
// BRUD legitimately ships A0-W0, all 23 frames, so the line is correct there
// and nine-frames-short here.  BRUD is NOT the fix -- it is the Bruiser's
// death sprite, a different monster; the Red Knightmare never renders it.
//   Resolution: the nine phantom leading frames now hold BRUR N, the frame
// this actor actually dies on, so the rewind is visible from tic 0 instead of
// 18 tics of nothing.  State count and total tics are unchanged.
//   FOR THE RECORD, an owner call we did not take on our own authority: CHP
// re-authored all 15 Red Knightmare variants in
// `E:\New folder\ART SOURCE\CHP\DECORATE\11\11_R.txt` and gave every one of
// them `Raise: Stop` (:102, :214, :326, :438, :550, :662, :774, :886, :999,
// :1112, :1229, :1342, :1458, :1629, :1742) -- i.e. CHP hit the same dead end
// and deleted the raise, making the monster unresurrectable.  That is a
// gameplay change, not a sprite fix, so it was left to the owner.
//
// LANDING THIS FAMILY CLOSES FOUR GUARDS: the lostsoul family's
// runtime-lookup guards for RS_CommonHK / RS_GreenHK / RS_BlueHK /
// RS_YellowHK (RS_LostSoulFX.zs:508/899/903/907/911) self-activate now that
// these classes exist, and RS_RandomizerArc's four commented HK drop lines
// were restored in the same change.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Hellknights.txt:1 -- Colourset8 replaces HellKnight.
// ---------------------------------------------------------------------------
class RS_Colourset8 : RandomSpawner replaces HellKnight
{
	Default
	{
		DropItem "RS_CommonHK", 255, 500;
		DropItem "RS_GreenHK", 255, 400;
		DropItem "RS_CyanHK", 255, 120;
		DropItem "RS_BrownHK", 255, 120;
		DropItem "RS_BlueHK", 255, 150;
		DropItem "RS_GrayHK", 255, 75;
		DropItem "RS_PurpleHK", 255, 75;
		DropItem "RS_YellowHK", 255, 50;
		DropItem "RS_AbyssHK", 255, 50;
		DropItem "RS_FireBluHK", 255, 20;
		DropItem "RS_RedHK", 255, 25;
		DropItem "RS_BlackHK", 255, 3;
		DropItem "RS_WhiteHK", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families.
// ---------------------------------------------------------------------------
class RS_BrownHK : Actor   // CH Hellknights.txt:18 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset8",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanHK : Actor   // CH Hellknights.txt:276 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset8",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssHK : Actor   // CH Hellknights.txt:547 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset8",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayHK : Actor   // CH Hellknights.txt:795 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset8",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluHK : Actor   // CH Hellknights.txt:814 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset8",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackHK : Actor   // CH Hellknights.txt:2254 -- gates CH_BlackBossy + CH_ExBoss
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedHK",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackHKEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackHKEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackHKEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteHK : Actor   // CH Hellknights.txt:3219 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteHK3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackHK",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown ("Lion?"), the parry knight.  CH: Hellknights.txt:40.
// ---------------------------------------------------------------------------
class RS_BrownHK2 : Actor   // CH Hellknights.txt:40
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 700;
		Speed 12;
		Radius 24;
		Height 64;
		PainChance 50;
		Mass 1000;
		SeeSound "knight/sight";
		PainSound "knight/pain";
		DeathSound "knight/death";
		ActiveSound "knight/active";
		DamageFactor "Blessed", 3.0;
		DamageFactor "PLWater", 1.5;
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		DamageFactor "Melee", 0.65;    // CH lists Melee twice, both 0.65
		DamageFactor "fire", 0.80;     // CH lists fire twice, both 0.80
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+MISSILEMORE
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+LAXTELEFRAGDMG
		Obituary "%o caught brown hell knights projectile";
		HitObituary "%o got too close to brown hellknight's shield.";
		DropItem "RS_CH_Chainsaw", 16;
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_ClipBox", 38;
		Tag "Lion?";
	}
	States
	{
	Spawn:
		HWAR AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		HWAR AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"MaybeParry");
		HWAR CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(32,"MaybeParry2");
		Loop;
	MaybeParry:
		TNT1 A 0 A_JumpIfInTargetLOS("Parry",0,JLOSF_DEADNOJUMP,1200,200);
		Goto See+5;
	MaybeParry2:
		TNT1 A 0 A_JumpIfInTargetLOS("Parry",0,JLOSF_DEADNOJUMP,1200,200);
		Goto See;
	MaybeParry3:
		TNT1 A 0 A_JumpIfInTargetLOS("Parry",0,JLOSF_DEADNOJUMP,1200,200);
		Goto Missile+4;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR E 1 A_FaceTarget;
		TNT1 A 0 A_Jump(32,"MaybeParry3");
		HWAR E 1 A_FaceTarget;
		HWAR EF 8 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(radius + 64,"MeleeMaybe");
		HWAR G 6 A_CustomMissile("RS_HellionBall",32,0);
		TNT1 A 0 A_JumpIfCloser(radius + 64,"Melee");
		Goto See;
	MeleeMaybe:
		TNT1 A 0 A_JumpIfCloser(radius + 64,"MeleeMaybe2");
		HWAR FJ 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto Rush;
	MeleeMaybe2:
		TNT1 A 0;
		Goto Melee+2;
	Parry:
		HWAR HH 3 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR II 3 A_FaceTarget;
		HWAR H 1 A_FaceTarget;
		HWAR I 3 A_SpawnItemEx("RS_BrownHKShield",18,0,24,1,0,0,0,SXF_NOCHECKPOSITION);
		HWAR HIHI 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(252,"Rush");
		TNT1 A 0 A_JumpIfCloser(128,"BlastEm");
		HWAR IHII 3;
		Goto See;
	Melee:
		HWAR EF 8 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR G 8 A_CustomMeleeAttack(random(10,60),"Baron/Melee","none");
		HWAR H 6 A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(252,"Rush");
		Goto See;
	Rush:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR I 12 ThrustThing(int(angle),32,0,0);   // CH: thrustthing(angle,32,0,0)
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR H 3 Bright A_CustomMissile("RS_BrownHKShieldCheck",32,0);
		TNT1 A 0 A_JumpIfCloser(176,"BlastEm");
		HWAR H 1 A_CustomMissile("RS_HKRedDeath",32,0);
		Goto See;
	BlastEm:
		HWAR H 1 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR H 1 A_CustomMissile("RS_HKRedDeath",32,0);
		HWAR H 2 A_VileAttack("bomb/boom",5,5,128,1.35);
		HWAR H 1 A_RadiusThrust(2040,400,RTF_NOTMISSILE);
		Goto See;
	Pain:
		HWAR I 0 A_SetSpeed(12);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HWAR J 6 A_Pain;
		HWAR J 1 A_Jump(84,"Parry");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		HWAR K 0 A_FaceTarget;   // CH: sprite HWAE ships nowhere in CH (typo for HWAR); 0-tic, invisible there too
		HWAR K 5 A_SpawnItemEx("RS_HellWarriorShield",0,0,25,6,0,0,60,128);
		HWAR L 5 A_Scream;
		HWAR M 5;
		HWAR N 5 A_NoBlocking;
		HWAR OPQRS 5;
		HWAR T -1;
		Stop;
	Raise:
		HWAR QPONMLK 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan ("Cyanide HellKnight").  CH: Hellknights.txt:298.
// ---------------------------------------------------------------------------
class RS_CyanHK2 : Actor   // CH Hellknights.txt:298
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 700;
		Speed 16;
		Radius 24;
		Height 64;
		PainChance 80;
		Mass 1000;
		RenderStyle "Add";
		BloodColor "cyan";
		Alpha 1.0;
		Monster;
		+BRIGHT
		+MISSILEMORE
		+MISSILEEVENMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+NOICEDEATH
		+LAXTELEFRAGDMG
		DamageFactor "Blessed", 3.0;
		DamageFactor "Ice", 0.15;   // CH lists Ice twice, both 0.15
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 76;
		PainChance "Melee", 102;
		DamageFactor "Falling", 0.0;   // CH lists Falling twice, both 0.0
		DamageFactor "Melee", 1.25;    // CH lists Melee twice, both 1.25
		DamageFactor "fire", 2.0;      // CH lists fire twice, both 2.0
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "superbaron/scream";
		PainSound "superbaron/pain";
		DeathSound "superbaron/death";
		ActiveSound "superbaron/act";
		Obituary "%o felt the chill of the cyan knight";
		HitObituary "%o got ripped to fragments by cyan knight";
		DropItem "RS_CH_Chainsaw", 16;
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
		Tag "Cyanide HellKnight";
	}
	States
	{
	Spawn:
		HFRY AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetScale(1.0,1.0);
		HFRY AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HFRY CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"See2");
		TNT1 A 0 A_Jump(232,"SeeMe");
		Loop;
	SeeMe:
		HFRY A 0 A_JumpIfInTargetLOS("Jumpy",0,JLOSF_DEADNOJUMP,750);
		Goto See;
	Jumpy:
		HFRY A 2 A_FastChase;
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");   // CH: CallACS("CH_CyanBounce") == 1
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HFRY A 1 ThrustThingZ(0,64,0,0);
		HFRY A 3 ThrustThing(int(angle-randompick(90,130,180,230,270)),12,0,0);   // CH: thrustthing(angle-randompick(...),12,0,0)
		HFRY A 1 ThrustThingZ(0,32,0,0);
		HFRY A 1 ThrustThing(int(angle-randompick(10,30,-20)),24,0,0);
		Goto See;
	See2:
		TNT1 A 0 A_SetScale(1.0,1.0);
		HFRY AABB 2 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HFRY CCDD 2 A_FastChase;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HFRY E 0 A_Jump(128,"A1");
		HFRY EF 6 A_FaceTarget;
		HFRY G 6 A_CustomMissile("RS_IceHKShot",42,0,0);
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_SetScale(-1.0,1.0);
		HFRY EF 6 A_FaceTarget;
		HFRY G 6 A_CustomMissile("RS_IceHKShot",42,0,random(-3,3));
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_CheckSight("See");
		HFRY EF 4 A_FaceTarget;
		HFRY G 5 A_CustomMissile("RS_IceHKShot",42,0,random(-1,1));
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_SetScale(-1.0,1.0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		HFRY EF 4 A_FaceTarget;
		HFRY G 5 A_CustomMissile("RS_IceHKShot",42,0,random(-5,5));
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_CheckSight("See");
		HFRY EF 3 A_FaceTarget;
		HFRY G 3 A_CustomMissile("RS_IceHKShot",42,0,random(-3,3));
		TNT1 A 0 A_CheckSight("See");
		TNT1 A 0 A_SetScale(-1.0,1.0);
		HFRY EF 3 A_FaceTarget;
		HFRY G 3 A_CustomMissile("RS_IceHKShot",42,0,random(-7,7));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(1.0,1.0);
		Goto See;
	A1:
		HFRY P 8 A_FaceTarget;
		HFRY P 6 A_CustomMissile("RS_CyanHKShade",20,0,180);
		HFRY P 6 A_CustomMissile("RS_CyanHKShade",20,0,180);
		HFRY Q 8 A_CustomMissile("RS_IceOrbCyanHK",60,0,0);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",12,-21,24,random(12,33),0,random(1,3),frandom(-5,5));
		FATT HHHHH 0 A_SpawnItemEx("RS_SpikeCyanRev",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",12,21,24,random(12,33),0,random(1,3),frandom(-5,5));
		HFRY QQQQQQQQQQ 0 A_CustomMissile("RS_SpikeCyanRev",60,0,randompick(-10,-5,0,5,10));
		TNT1 A 0 A_Jump(64,"Dodge1","Dodge2");
		Goto See;
	Melee:
		HFRY EF 8 A_FaceTarget;
		HFRY G 8 A_CustomMeleeAttack(random(20,90),"baron/melee");
		TNT1 AAAAAAAAAAAAAAAA 0 A_CustomMissile("RS_SpikeCyanRev",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		TNT1 A 0 A_Jump(64,"Missile");
		TNT1 A 0 A_Jump(64,"Dodge1","Dodge2");
		Goto See;
	Dodge1:
		TNT1 A 0 A_CustomMissile("RS_CyanHKShade",20,0,180);
		HFRY A 1 ThrustThingZ(0,11,0,0);
		HFRY A 1 ThrustThing(int(angle-90),29,0,0);
		Goto See2;
	Dodge2:
		TNT1 A 0 A_CustomMissile("RS_CyanHKShade",20,0,180);
		HFRY A 1 ThrustThingZ(0,11,0,0);
		HFRY A 1 ThrustThing(int(angle+90),29,0,0);
		Goto See2;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SetScale(1.0,1.0);
		HFRY H 2 A_CustomMissile("RS_CyanHKShade",20,0,180);
		HFRY H 2 A_Pain;
		TNT1 A 0 A_Jump(128,"Dodge1","Dodge2");
		Goto See;
	Death:
		HFRY I 8 A_Scream;
		HFRY JK 8;
		HFRY L 8 A_NoBlocking(false);
		HFRY MN 8;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,251);
		TNT1 A 0 A_IceGuyDie;
		HFRY O -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss ("Abyss Bruiser").  CH: Hellknights.txt:570.
// ---------------------------------------------------------------------------
class RS_AbyssHK2 : HellKnight   // CH Hellknights.txt:570
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "black";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance 64;
		Health 1850;
		Speed 15;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		-NORADIUSDMG
		+NOFEAR
		DamageFactor "Fire", 0.4;   // CH lists Fire twice, both 0.4
		DamageFactor "ice", 0.4;    // CH lists ice twice, both 0.4
		HitObituary "%o was dragged deep below";
		Obituary "%o got made into abysmal bloody mist";
		SeeSound "deepone/sight";
		PainSound "deepone/pain";
		DeathSound "deepone/death";
		ActiveSound "deepone/active";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_GreenArmor", 64;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox";
		XScale 1.15;
		YScale 1.0;
		MeleeRange 58;
		Tag "Abyss Bruiser";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		BRUS AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetSpeed(15);
		BRUS AABB 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS CCDD 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See2:
		TNT1 A 0 A_SetSpeed(15);
		BRUS AABB 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		BRUS CCDD 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		TNT1 A 0 A_Jump(64,"Dodge1","Dodge2");
		Loop;
	Dodge1:
		BRUS A 1 ThrustThingZ(0,11,0,0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BRUS A 1 ThrustThing(int(angle-90),29,0,0);   // CH: thrustthing(angle-90,29,0,0)
		Goto See2;
	Dodge2:
		BRUS A 1 ThrustThingZ(0,11,0,0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BRUS A 1 ThrustThing(int(angle+90),29,0,0);
		Goto See2;
	Melee:
		BRUS E 4 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",4,26,46);
		BRUS F 4 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_SplashAbyss",4,13,30);
		BRUS G 5 Bright A_CustomMeleeAttack(random(20,90),"baron/melee");
		TNT1 AAAAAAAAAAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		BRUS G 1 Bright A_Jump(88,"Missile");
		Goto See2;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS E 0 A_JumpIfCloser(1500,"Choices");
		Goto Balls;
	Choices:
		BRUS E 0 A_JumpIfCloser(900,"Choices2");
		BRUS E 1 Bright A_Jump(255,"Balls","BallsBar");
		Goto See2;
	Choices2:
		BRUS E 1 Bright A_Jump(255,"Balls","Mist","BallsBar");
	Balls:
		BRUS EF 4 Bright A_FaceTarget;
		BRUS G 2 Bright A_CustomMissile("RS_AbyssHKBall",32,2,random(-1,1));
		TNT1 A 0 A_Jump(64,"CL2");
		BRUS G 1 Bright A_MonsterRefire(128,"See");
		Goto Balls2;
	Balls2:
		BRUS HI 4 Bright A_FaceTarget;
		BRUS J 2 Bright A_CustomMissile("RS_AbyssHKBall",32,2,random(-1,1));
		TNT1 A 0 A_Jump(64,"CL2");
		BRUS J 1 Bright A_MonsterRefire(128,"See");
		Goto Balls;
	CL1:
		BRUS E 0 A_JumpIfCloser(800,"BallsBar");
		Goto Balls2;
	CL2:
		BRUS E 0 A_JumpIfCloser(800,"BallsBar");
		Goto Balls;
	BallsBar:
		BRUS K 7 Bright A_FaceTarget;
		BRUS KL 6 Bright A_FaceTarget;
		BRUS M 1 Bright A_CustomMissile("RS_AbyssHKBall",32,0,0);
		TNT1 AAA 0 A_CustomMissile("RS_AbyssHKBall",32,0,random(1,14));
		TNT1 AAA 0 A_CustomMissile("RS_AbyssHKBall",32,0,random(-14,-1));
		BRUS M 16 Bright;
		Goto See2;
	Mist:
		BRUS K 1 Bright A_FaceTarget;
		BRUS K 12 Bright A_PlaySound("superbaron/scream");
		BRUS KL 12 Bright A_FaceTarget;
		BRUS M 1 Bright { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",TRUE)
		BRUS M 1 A_SetTranslucent(0.45);
		BRUS M 1 A_SetSpeed(99);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BRUS MMMMMMMM 1 A_SpawnItemEx("RS_AbyssHKMist",random(-256,256),random(-256,256),6,random(1,11),0,0,random(-359,359),SXF_NOCHECKPOSITION);
		BRUS MMMMMMM 1 A_Wander;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BRUS MMMMMMMMMM 1 A_SpawnItemEx("RS_AbyssHKMist",random(-256,256),random(-256,256),6,random(1,11),0,0,random(-359,359),SXF_NOCHECKPOSITION);
		BRUS MMMMMMMM 1 A_Wander;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BRUS MMMMMMMMM 1 A_SpawnItemEx("RS_AbyssHKMist",random(-256,256),random(-256,256),6,random(1,11),0,0,random(-359,359),SXF_NOCHECKPOSITION);
		BRUS MMMMMMMMMM 1 A_Wander;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		BRUS M 1 Bright;
		BRUS M 1 A_SetTranslucent(1.0);
		BRUS M 1 A_SetSpeed(15);
		BRUS M 10 Bright;
		BRUS M 8 Bright { bNOPAIN = false; }   // CH: A_changeflag("NOPAIN",FALSE)
		TNT1 A 0 A_Jump(64,"Dodge1","Dodge2");
		Goto See2;
	Pain:
		BRUS N 5 Bright A_Pain;
		TNT1 A 0 A_SetSpeed(15);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS N 1 Bright A_Jump(64,"Choices","Dodge1","Dodge2");
		Goto See2;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BRUD A 6 Bright A_Scream;
		BRUD BCDEFG 4 Bright;
		BRUD H 4 Bright A_Fall;
		BRUD IJKLMNOP 4 Bright;
		BRUD QRSTUV 4;
		BRUD W -1;
		Stop;
	Raise:
		BRUD WVUTSRQPONMLKJIHGFEDCBA 2;
		Goto See2;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- FireBlu ("Knight with clown armor").  CH: Hellknights.txt:833.
// ---------------------------------------------------------------------------
class RS_FireBluHK2 : Actor   // CH Hellknights.txt:833
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "Blue";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 8;   // CH lists fire twice, both 8
		Health 900;
		Speed 13;
		Radius 24;
		Height 64;
		Monster;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		+DONTHARMCLASS
		SeeSound "HK2/see";
		ActiveSound "knight/active";
		PainSound "HK2/Hurt";
		DeathSound "HK2/Die";
		Obituary "%o was forged into fireblu hell knights armor";
		DropItem "RS_HealthBundle", 188;
		DropItem "HealthBonus";
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_GreenArmor", 64;
		DropItem "RS_CH_RocketLauncher", 128;
		Translation "144:151=196:207","48:63=171:186","128:143=195:207","13:15=45:47","74:79=183:191","64:74=199:207","1:2=242:244","122:127=177:182","112:121=197:204";
		Tag "Knight with clown armor";
	}
	States
	{
	Spawn:
		BOS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 E 0 A_Jump(255,"Bolt1","Fires5");
		Goto See;
	Bolt1:
		BOS2 EF 6 A_FaceTarget;
		BOS2 G 6 A_CustomMissile("RS_FireBluHKBall1",32,3,random(-1,1));
		BOS2 PQ 5 A_FaceTarget;
		BOS2 R 5 A_CustomMissile("RS_FireBluHKBall1",32,3,random(-9,9));
		BOS2 R 0 A_Jump(76,"Bolt1");
		Goto See;
	Melee:
	Fires5:
		BOS2 H 12 Bright A_FaceTarget;
		BOS2 HHHHHH 0 A_CustomMissile("RS_FireBluHKBall2",54,1,random(-25,25),0,random(-15,15));
		BOS2 HHHH 1 Bright A_CustomMissile("RS_FireBluHKBall2",54,1,random(-25,25),0,random(-15,15));
		BOS2 HHHHHH 0 A_CustomMissile("RS_FireBluHKBall2",54,1,random(-25,25),0,random(-15,15));
		BOS2 HHHH 1 Bright A_CustomMissile("RS_FireBluHKBall2",54,1,random(-25,25),0,random(-15,15));
		BOS2 H 6 Bright;
		BOS2 H 4;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		BOS2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS2 I 8;
		BOS2 J 8 A_Scream;
		BOS2 K 8;
		BOS2 L 8 A_NoBlocking;
		BOS2 MN 8;
		BOS2 O -1;
		Stop;
	Raise:
		BOS2 ONMLKJI 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray ("Gray knight").  CH: Hellknights.txt:1020.
// ---------------------------------------------------------------------------
class RS_GrayHK2 : Actor   // CH Hellknights.txt:1020
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "White";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 8;   // CH lists fire twice, both 8
		Health 800;
		Speed 15;
		Radius 24;
		Height 64;
		PainChance 16;
		Monster;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		+DONTHARMCLASS
		SeeSound "HK2/see";
		ActiveSound "knight/active";
		PainSound "HK2/Hurt";
		DeathSound "HK2/Die";
		Obituary "%o got stoned with gray hell knight";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_GreenArmor", 32;
		Translation "54:63=87:95","144:151=96:106","13:15=109:111","138:143=104:108","128:135=96:98","112:127=80:95";
		Tag "Gray knight";
	}
	States
	{
	Spawn:
		BOS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 E 0 A_JumpIfCloser(600,"Fire3");
		BOS2 E 0 A_Jump(255,"Bolt3");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Bolt3:
		BOS2 EF 8 A_FaceTarget;
		BOS2 G 8 A_CustomMissile("RS_MolochNail",32,3,random(-1,1));
		BOS2 G 0 A_Jump(128,"Bolt4");
		Goto See;
	Bolt4:
		BOS2 PQ 8 A_FaceTarget;
		BOS2 R 8 A_CustomMissile("RS_MolochNail",32,3,random(-1,1));
		BOS2 R 0 A_Jump(76,"Bolt3");
		Goto See;
	Fire3:
		BOS2 H 10 Bright A_FaceTarget;
		BOS2 H 9 Bright A_CustomMissile("RS_MinesHK",54,1,random(-1,1));
		BOS2 H 12 Bright A_FaceTarget;
		BOS2 H 9 Bright A_CustomMissile("RS_MinesHK",54,1,random(-9,9));
		BOS2 H 12 Bright A_FaceTarget;
		BOS2 H 9 Bright A_CustomMissile("RS_MinesHK",54,1,random(-25,25));
		Goto See;
	Pain:
		BOS2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS2 I 8;
		BOS2 J 8 A_Scream;
		BOS2 K 8;
		BOS2 L 8 A_NoBlocking;
		BOS2 MN 8;
		BOS2 O -1;
		Stop;
	Raise:
		BOS2 ONMLKJI 8;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common.  CH: Hellknights.txt:1171.  Landing this class closes
// the lostsoul family's RS_CommonHK guards.
// ---------------------------------------------------------------------------
class RS_CommonHK : HellKnight   // CH Hellknights.txt:1171
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "BaronOfHell";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		GibHealth -80;
		Monster;
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		BloodColor "Green";
		Tag "HellKnight";
	}
	States
	{
	Spawn:
		BOS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 EF 8 A_FaceTarget;
		BOS2 G 8 A_BruisAttack;
		Goto See;
	Pain:
		BOS2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS2 I 8;
		BOS2 J 8 A_Scream;
		BOS2 K 8;
		BOS2 L 8 A_NoBlocking;
		BOS2 MN 8;
		BOS2 O -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Raise:
		BOS2 O 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BOS2 NMLKJI 5;
		Goto See;
	Grow:
		BOS2 NMLKJI 5;
		BOS2 A 0 A_SpawnItemEx("RS_GreenHK",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		BOS2 I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOS2 I 0 A_Stop;
		BOS2 I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: TNT1 AAAAA 0 A_SpawnItemEx("CHRandom_GibGenerator",...) -- gore chain stripped, animation stays
		HKGB A 0 A_ScreamAndUnblock;
		HKGB A -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green.  CH: Hellknights.txt:1274.  Carries the native rebuild of
// the ACS lead-shot (see RS_HKLead in the FX file).
// ---------------------------------------------------------------------------
class RS_GreenHK : HellKnight   // CH Hellknights.txt:1274
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "Green";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 600;
		GibHealth -80;
		Speed 9;
		-BOSSDEATH
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		SeeSound "knight/sight";
		ActiveSound "knight/active";
		PainSound "knight/pain";
		DeathSound "knight/death";
		DropItem "RS_HealthBundle";
		HitObituary "%o was taken down by greener than green, Green Hell Knight";
		Obituary "%o felt the green overload of Green Hell Knight";
		Translation "48:63=112:118","128:143=117:127","144:151=118:127","13:15=125:127","64:79=152:159";
		Tag "Green HellKnight";
	}
	States
	{
	Spawn:
		BOS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 EF 8 A_FaceTarget;
		BOS2 G 8 A_CustomComboAttack("BaronBall",32,11 * random(1,8),"baron/melee");
		BOS2 G 2 A_Jump(164,"Missile2");
		Goto See;
	Missile2:
		BOS2 PQ 8 A_FaceTarget;
		BOS2 Q 0 A_JumpIf(RS_Zom.CV('rs_ch_intercept', 0) == 1, "Miss2");   // CH: CallACS("CH_Intercept") == true (CH default false)
		// OWNER-APPROVED DEPARTURE FROM CH (ruled 2026-08-06). Second one in the
		// project, after GrayPE2's healed RS_GreyDemon2. DO NOT "correct" this
		// back to match CH -- the divergence is deliberate and was chosen with
		// the facts below in hand.
		//
		// CH calls ACS_NamedExecuteWithResult("BaronMissile") here with NO
		// argument, i.e. rand=0 (Hellknights.txt:1319). CHACS.acs:54 inverts
		// it -- `if(rand == 1)` false -> else -> ProjInt_Brute(..., rand=1, 0).
		// And miscFuncs.acs:114 is `if(rand){ random(1, sml_t); }`: the return
		// value is DISCARDED, so lead time 't' stays 0 and every lead term
		// becomes FixedMul(0, targetVel). CH's hell knight therefore does NOT
		// lead -- it fires at the target's current position and is dodged by
		// strafing, while the baron and lost souls (which pass rand=1 and hit
		// the working branch) genuinely do predict. That asymmetry is a typo,
		// not a design choice: the author wrote a solver and called it for all
		// three. The owner ruled to keep the intended behaviour.
		BOS2 R 8 { RS_HKLead.FireLead(self, "BaronBall", 32); }   // CH: ACS_NamedExecuteWithResult("BaronMissile") -- CHACS.acs:54
		BOS2 R 2 A_Jump(128,"Missile");
		Goto See;
	Miss2:
		BOS2 R 8 A_CustomComboAttack("BaronBall",32,11 * random(1,8),"baron/melee");
		BOS2 R 2 A_Jump(128,"Missile");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		BOS2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS2 I 8;
		BOS2 J 8 A_Scream;
		BOS2 K 8;
		BOS2 L 8 A_NoBlocking;
		BOS2 MN 8;
		BOS2 O -1;
		Stop;
	Raise:
		BOS2 O 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BOS2 NMLKJI 5;
		Goto See;
	Grow:
		BOS2 NMLKJI 5;
		BOS2 A 0 A_SpawnItemEx("RS_BlueHK",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		BOS2 I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOS2 I 0 A_Stop;
		BOS2 I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		HKGB A 0 A_ScreamAndUnblock;
		HKGB A -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue.  CH: Hellknights.txt:1380.
// ---------------------------------------------------------------------------
class RS_BlueHK : HellKnight   // CH Hellknights.txt:1380
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "Blue";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 666;
		GibHealth -90;
		Speed 10;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		SeeSound "HK2/see";
		ActiveSound "knight/active";
		PainSound "HK2/Hurt";
		DeathSound "HK2/Die";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_HealthBundle", 64;
		HitObituary "%o was blue hand smack'd";
		Obituary "%o got hit by Blue Hell Knights blue bolts";
		MeleeRange 54;
		Translation "112:127=192:207","64:79=195:207","54:63=194:196","144:151=196:207","128:143=194:207","13:15=240:242";
		Tag "Blue HellKnight";
	}
	States
	{
	Spawn:
		BOS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 EF 8;
		BOS2 G 8 A_CustomMeleeAttack(random(10,70),"baron/melee");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 EF 8 A_FaceTarget;
		BOS2 G 8 A_CustomMissile("RS_BaronsBlueBalls",32,3,random(-1,1));
		BOS2 G 0 A_CheckSight("See");
		BOS2 PQ 6 A_FaceTarget;
		BOS2 R 6 A_CustomMissile("RS_BaronsBlueBalls",32,3,random(-3,3));
		BOS2 G 0 A_CheckSight("See");
		BOS2 EF 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 G 4 A_CustomMissile("RS_BaronsBlueBalls",32,3,random(-5,5));
		BOS2 PQ 3 A_FaceTarget;
		BOS2 R 3 A_CustomMissile("RS_BaronsBlueBalls",32,3,random(-7,7));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		BOS2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS2 I 8;
		BOS2 J 8 A_Scream;
		BOS2 K 8;
		BOS2 L 8 A_NoBlocking;
		BOS2 MN 8;
		BOS2 O -1;
		Stop;
	Raise:
		BOS2 O 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		BOS2 NMLKJI 5;
		Goto See;
	Grow:
		BOS2 NMLKJI 5;
		BOS2 A 0 A_SpawnItemEx("RS_PurpleHK",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	XDeath:
		BOS2 I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOS2 I 0 A_Stop;
		BOS2 I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		HKGB A 0 A_ScreamAndUnblock;
		HKGB A -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple ("Royal Purple HellKnight").  CH: Hellknights.txt:1518.
// ---------------------------------------------------------------------------
class RS_PurpleHK : HellKnight   // CH Hellknights.txt:1518
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "Blue";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 8;   // CH lists fire twice, both 8
		Health 730;
		GibHealth -90;
		Speed 11;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		SeeSound "HK2/see";
		ActiveSound "knight/active";
		PainSound "HK2/Hurt";
		DeathSound "HK2/Die";
		RenderStyle "SoulTrans";
		Alpha 1;
		HitObituary "%o was face smacked by purplehand of purple hell knight";
		Obituary "%o met some true knight royalty";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 64;
		DropItem "RS_CH_GreenArmor", 22;
		MeleeRange 54;
		Translation "48:63=[248,160,250]:[230,108,226]","133:143=[194,20,164]:[60,23,30]","144:151=[192,34,215]:[94,34,65]","255:255=254:254","13:15=254:254","0:0=247:247","194:207=174:191";
		Tag "Royal Purple HellKnight";
	}
	States
	{
	Spawn:
		BOS2 AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BOS2 AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 EF 8;
		BOS2 G 8 A_CustomMeleeAttack(random(20,90),"baron/melee");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 E 0 A_JumpIfCloser(300,"Fire3");
		BOS2 E 0 A_Jump(255,"Bolt3");
		Goto See;
	Bolt3:
		BOS2 EF 8 A_FaceTarget;
		BOS2 G 8 A_CustomMissile("RS_HKBolt2",32,3,random(-1,1));
		BOS2 G 0 A_Jump(128,"Bolt4");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Bolt4:
		BOS2 PQ 8 A_FaceTarget;
		BOS2 R 8 A_CustomMissile("RS_HKBolt2",32,3,random(-1,1));
		BOS2 R 0 A_Jump(76,"Bolt3");
		Goto See;
	Fire3:
		BOS2 H 1 A_JumpIfCloser(300,"Fbreath");
		BOS2 H 1 A_Jump(255,"See");
		Goto See;
	Fbreath:
		BOS2 H 4 Bright A_FaceTarget;
		BOS2 H 2 Bright A_CustomMissile("RS_PurpFire2",54,1,random(-1,1));
		BOS2 H 1 Bright A_FaceTarget;
		BOS2 H 1 Bright A_CustomMissile("RS_PurpFire2",54,1,random(-3,3));
		BOS2 H 1 Bright A_FaceTarget;
		BOS2 H 1 Bright A_CustomMissile("RS_PurpFire2",54,1,random(-5,5));
		BOS2 H 1 Bright A_MonsterRefire(150,"See");
		Goto Fire3;
	Pain:
		BOS2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BOS2 H 2 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BOS2 I 8;
		BOS2 J 8 A_Scream;
		BOS2 K 8;
		BOS2 L 8 A_NoBlocking;
		BOS2 MN 8;
		BOS2 O -1;
		Stop;
	Raise:
		BOS2 ONMLKJI 8;
		Goto See;
	XDeath:
		BOS2 I 0 A_SpawnItemEx("RS_HKSplashDed",0,2,47,0,0,0,0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR);
		BOS2 I 0 A_Stop;
		BOS2 I 8;
		TNT1 AAAAAAAAAAAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		// CH: CHRandom_GibGenerator spam stripped (gore chain), animation stays
		HKGB A 0 A_ScreamAndUnblock;
		HKGB A -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 5 -- Yellow ("Orange Bruiser").  CH: Hellknights.txt:1674.
// ---------------------------------------------------------------------------
class RS_YellowHK : HellKnight   // CH Hellknights.txt:1674
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Species "BaronOfHell";
		BloodColor "Yellow";
		DamageFactor "Blessed", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 0.75;   // CH lists Fire 0.75 twice here, then 0.5 lower down; the last one wins, all kept
		DamageFactor "PLWater", 1.65;
		DamageFactor "ice", 0.75;    // CH lists ice twice, both 0.75
		PainChance "DIMp", 0;
		PainChance "fire", 0;        // CH lists fire twice, both 0
		Health 999;
		Speed 10;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		-NORADIUSDMG
		+NOFEAR
		RenderStyle "SoulTrans";
		Alpha 1;
		DamageFactor "Fire", 0.5;
		HitObituary "%o got super bruiser bro'd";
		Obituary "%o was charred nicely by Orange Hell Knight";
		SeeSound "superbaron/scream";
		PainSound "superbaron/pain";
		DeathSound "superbaron/death";
		ActiveSound "superbaron/act";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_GreenArmor", 22;
		DropItem "RS_CH_RocketBox", 64;
		MeleeRange 54;
		Tag "Orange Bruiser";
	}
	States
	{
	Spawn:
		BRUS AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BRUS AABB 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS CCDD 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		BRUS E 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS F 6 Bright A_FaceTarget;
		BRUS G 6 Bright A_CustomMeleeAttack(random(20,90),"baron/melee");
		BRUS G 1 Bright A_Jump(88,"Missile");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS E 0 A_Jump(255,"Rapidfire","Boom");
		BRUS E 1 Bright;
		Goto See;
	Rapidfire:
		BRUS EF 4 Bright A_FaceTarget;
		BRUS G 2 Bright A_CustomMissile("RS_FireHKBall1",32,2,random(-1,1));
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS G 1 Bright A_MonsterRefire(128,"See");
		Goto Rapidfire2;
	Rapidfire2:
		BRUS HI 4 Bright A_FaceTarget;
		BRUS J 2 Bright A_CustomMissile("RS_FireHKBall1",32,2,random(-1,1));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS J 1 Bright A_MonsterRefire(128,"See");
		Goto Rapidfire;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Boom:
		BRUS K 1 Bright A_FaceTarget;
		BRUS K 12 Bright A_PlaySound("superbaron/scream");
		BRUS K 1 Bright A_CustomMissile("RS_SparkPuff1",52,34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 0 A_CustomMissile("RS_SparkPuff1",52,-34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 1 Bright A_CustomMissile("RS_SparkPuff1",52,34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 0 A_CustomMissile("RS_SparkPuff1",52,-34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 1 Bright A_CustomMissile("RS_SparkPuff1",52,34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 0 A_CustomMissile("RS_SparkPuff1",52,-34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 1 Bright A_CustomMissile("RS_SparkPuff1",52,34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS K 0 A_CustomMissile("RS_SparkPuff1",52,-34,CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUS KL 12 Bright A_FaceTarget;
		BRUS M 10 Bright A_CustomMissile("RS_BigHK",32,0);
		BRUS M 8 Bright;
		Goto See;
	Pain:
		BRUS N 5 Bright A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUS N 1 Bright A_Jump(64,"Boom");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BRUD A 6 Bright A_Scream;
		BRUD BCDEFG 4 Bright;
		BRUD H 4 Bright A_Fall;
		BRUD IJKLMNOP 4 Bright;
		BRUD QRSTUV 4;
		BRUD W -1;
		Stop;
	Raise:
		BRUD WVUTSRQPONMLKJIHGFEDCBA 2;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red ("Red Knightmare").  CH: Hellknights.txt:1902.
// ---------------------------------------------------------------------------
class RS_RedHK : HellKnight   // CH Hellknights.txt:1902
{
	int user_Rage2;   // CH: Var Int User_Rage2
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Species "BaronOfHell";
		Health 1300;
		Speed 11;
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+DONTHARMSPECIES
		-NORADIUSDMG
		+NOFEAR
		RenderStyle "SoulTrans";
		DamageFactor "Fire", 0.5;
		DamageFactor "Plasma", 0.7;
		DamageFactor "Blessed", 3.0;
		DamageFactor "ice", 1.45;   // CH lists ice twice, both 1.45
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Alpha 0.9;
		HitObituary "%o got hand smacked by Red Hell Knightmare";
		Obituary "%o blood was boiled by Red Hell Knightmare";
		SeeSound "superbaron/scream";
		PainSound "superbaron/pain";
		DeathSound "superbaron/death";
		ActiveSound "superbaron/act";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_BlueArmor", 38;
		DropItem "RS_CH_RocketBox", 232;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketAmmo";
		Scale 1.15;
		MeleeRange 54;
		Tag "Red Knightmare";
	}
	States
	{
	Spawn:
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",-5,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",0,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",0,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",5,-5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialImp",-5,5,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
	Idle:
		BRUR AB 10 Bright A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BRUR AABB 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUR CCDD 3 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Dodge1:
		BRUR A 5 ThrustThing(int(angle*256/360+64),20,0,0);   // CH: ThrustThing(angle*256/360+64,20,0,0)
		Goto See;
	Dodge2:
		BRUR A 5 ThrustThing(int(angle*256/360+192),20,0,0);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssHK2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Melee:
		BRUR E 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUR F 6 Bright A_FaceTarget;
		BRUR G 6 Bright A_CustomMeleeAttack(random(20,99),"baron/melee");
		BRUR G 1 Bright A_Jump(88,"Missile");
		Goto See;
	Missile:
		BRUR A 0 A_JumpIfHealthLower(800,"Enrage");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUR A 0 A_Jump(255,"DoT","BoilBolt");
		BRUR A 1 Bright;
		Goto See;
	DoT:
		BRUR K 6 Bright A_FaceTarget;
		BRUR KL 8 Bright;
		BRUR M 1 Bright A_CustomMissile("RS_THEBEEHK",32,2);
		BRUR M 9 Bright A_CustomMissile("RS_EffectHK",30,0);
		Goto See;
	BoilBolt:
		BRUR EF 6 Bright A_FaceTarget;
		BRUR G 3 Bright A_CustomMissile("RS_BloodBoltHK",32,2,random(-1,1));
		BRUR G 2 Bright A_MonsterRefire(128,"See");
		BRUR G 1 Bright A_Jump(22,"DoT");
		Goto BoilBolt2;
	BoilBolt2:
		BRUR HI 6 Bright A_FaceTarget;
		BRUR J 3 Bright A_CustomMissile("RS_BloodBoltHK",32,2,random(-1,1));
		BRUR J 2 Bright A_MonsterRefire(128,"See");
		BRUR G 1 Bright A_Jump(22,"DoT");
		Goto BoilBolt;
	Enrage:
		BRUR A 1 A_JumpIf(user_Rage2 >= 1,"Nah");
		BRUR K 1 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		BRUR K 12 Bright A_PlaySound("superbaron/scream");
		BRUR KL 12 Bright A_CustomMissile("RS_EffectHK",48,0);
		BRUR M 10 Bright { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenMore",TRUE)
		BRUR MMM 2 Bright A_CustomMissile("RS_EffectHK",24,0);
		BRUR M 8 Bright { user_Rage2 += 1; }   // CH: A_SetUserVar("User_Rage2",User_Rage2+1)
		Goto See;
	Nah:
		BRUR A 1;
		Goto Missile+1;
	Pain:
		BRUR N 5 Bright A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUR N 1 Bright A_Jump(74,"Dodge1","Dodge2");
		Goto See;
	Pain.Fire:
		BRUR N 0;
		Goto Pain+1;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		BRUR N 6 Bright A_Scream;
		BRUR N 4 Bright A_CustomMissile("RS_HKRedDeath",100,-30,CMF_AIMOFFSET,2,-10);
		BRUR N 2 Bright A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		BRUR N 4 Bright A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		BRUR N 4 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		BRUR N 4 A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		BRUR N 5 Bright A_Fall;
		BRUR N 4 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		BRUR N 4 A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		BRUR N 4 Bright A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		BRUR N 4 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		BRUR N 2 A_CustomMissile("RS_HKRedDeath",100,-30,CMF_AIMOFFSET,2,-10);
		TROO QRST 5;
		TROO U -1;
		Stop;
	Raise:
		BRUR NNNNNNNNNNMLKJIHGFEDCBA 2;   // CH: BRUR WVUTSRQPONMLKJIHGFEDCBA -- frames W..O do not exist (BRUR ships A-N only); held BRUR N in their place. 23 states / 46 tics, unchanged. See header note. Fixed 2026-08-06 (owner: nothing invisible).
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- Black boss ("Terminator").  CH: Hellknights.txt:2290.
// ---------------------------------------------------------------------------
class RS_BlackHK2 : Actor   // CH Hellknights.txt:2290
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 5555;
		Radius 24;
		Height 64;
		Mass 1000;
		DamageFactor "None", 0.7;
		RadiusDamageFactor 0.25;
		DamageFactor "Fire", 0.75;   // CH lists Fire twice, both 0.75
		DamageFactor "Plasma", 1.5;  // CH lists Plasma twice, both 1.5
		DamageFactor "Melee", 0.7;
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 1.5;     // CH lists ice twice, both 1.5
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 6;
		PainChance 30;
		Monster;
		MeleeDamage 13;
		MeleeRange 68;
		Obituary "%o was terminated by T-800 Baron";
		HitObituary "%o was unable to stop the termination close by";
		Species "BaronOfHell";
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+BOSS
		+DONTHARMSPECIES
		+DONTMORPH
		-NORADIUSDMG
		+FLOORCLIP
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "monster/brusit";
		PainSound "baron/pain";
		DeathSound "monster/brudth";
		MeleeSound "baron/melee";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_BlueArmor";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_PlasmaRifle";
		// CH: DropItem "RLSniperModItem" / "RareArmorPool",128 /
		// "RLUniqueWeaponSpawner",24 -- DRLA cross-mod drops, stripped
		Scale 1.33;
		Translation "128:143=107:111","13:15=5:8","74:79=0:2","144:144=109:109","236:239=0:2","144:151=0:2";
		Tag "Terminator";
	}
	States
	{
	Spawn:
		BRUC A 0;
		Goto Scripted;
	Scripted:
		BRUC A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackHK") -- announcer stripped
		Goto Idle;
	Idle:
		BRUC AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		BRUC E 8 A_FaceTarget;
		BRUC E 5 Bright A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 4 A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 5 Bright A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 3 A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 3 Bright A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 2 A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 2 Bright A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 1 A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 1 Bright A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 1 A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		BRUC E 1 Bright A_CustomMissile("RS_SparkPuff1",random(12,66),random(-20,20),CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See2;
	See2:
		BRUC A 1 A_PlaySound("monster/bruwlk");
		BRUC AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC C 1 A_PlaySound("monster/bruwlk");
		BRUC CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC D 0 A_Jump(8,"Mode1","Mode2");
		Loop;
	Missile:
		BRUC E 8 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC E 0 A_JumpIfInventory("RS_BrusMode",3,"MisMode2");
		BRUC E 0 A_Jump(256,"BigMis","ClusterMis","NadeToss");
		Goto See2;
	MisMode2:
		BRUC E 0 A_Jump(256,"LaserShot1","DeathBeam","NadeToss");
		Goto See2;
	LaserShot1:
		BRUC E 0 A_PlaySound("prox/beep");
		BRUC E 4 Bright A_FaceTarget;
		BRUC FE 4 Bright A_CustomMissile("RS_BluCybFX",38,15,0,0);
		BRUC FFF 4 Bright A_CustomMissile("RS_SwooshCBBar1",38,15,random(-7,7),0);
		BRUC F 0 A_CheckSight("See2");
		BRUC E 2 Bright A_FaceTarget;
		BRUC FE 4 Bright A_CustomMissile("RS_BluCybFX",38,15,0,0);
		BRUC FFF 4 Bright A_CustomMissile("RS_SwooshCBBar1",38,15,random(-14,14),0);
		BRUC E 2 Bright A_MonsterRefire(128,"See2");
		Goto LaserShot1+1;
	DeathBeam:
		BRUC EE 12 A_FaceTarget;
		BRUC E 0 A_PlaySound("prox/beep");
		BRUC F 8 Bright A_CustomMissile("RS_RedRevLoad",38,15,random(-1,1),0);
		BRUC F 6 Bright A_FaceTarget;
		BRUC F 6 Bright A_CustomMissile("RS_MegaRedRev",38,15,random(-1,1),0);
		BRUC F 0 A_SpawnItemEx("Cell",8,4,48,3,3,3,int(angle+1));
		BRUC F 0 A_SpawnItemEx("Cell",8,4,48,3,3,3,int(angle+1));
		BRUC F 5 A_Jump(60,"LaserShot1");
		Goto See2;
	BigMis:
		BRUC F 0 A_PlaySound("prox/beep");
		BRUC F 12 Bright A_CustomMissile("RS_BruiserMissile",38,15,0,0);
		BRUC F 0 A_CheckSight("See2");
		BRUC EE 10 A_FaceTarget;
		BRUC F 0 A_PlaySound("prox/beep");
		BRUC F 7 Bright A_CustomMissile("RS_BruiserMissile",38,15,random(-3,3),0);
		BRUC F 0 A_CheckSight("See2");
		BRUC EE 10 A_FaceTarget;
		BRUC F 0 A_PlaySound("prox/beep");
		BRUC F 7 Bright A_CustomMissile("RS_BruiserMissile",38,15,random(-7,7),0);
		BRUC F 0 A_SpawnItemEx("RocketBox",8,4,48,3,3,3,int(angle+1));
		BRUC E 1 A_Jump(60,"ClusterMis");
		Goto See2;
	ClusterMis:
		BRUC F 9 Bright A_CustomMissile("RS_SpreadMisBar1",38,15,random(-5,5),0);
		BRUC F 5 Bright A_CustomMissile("RS_SpreadMisBar1",38,15,random(-14,14),0);
		BRUC F 0 A_CheckSight("See2");
		BRUC EEE 5 A_FaceTarget;
		BRUC F 9 Bright A_CustomMissile("RS_SpreadMisBar1",38,15,random(-7,7),0);
		BRUC F 5 Bright A_CustomMissile("RS_SpreadMisBar1",38,15,random(-16,16),0);
		BRUC FFF 0 A_SpawnItemEx("Shell",8,4,48,3,3,3,int(angle+1));
		BRUC E 1 A_Jump(42,"Missile");
		Goto See2;
	NadeToss:
		BRUC GH 7 A_FaceTarget;
		BRUC I 9 A_CustomMissile("RS_BaronNade",38,2,random(-9,9),0,random(3,12));
		BRUC I 1 A_Jump(42,"Missile");
		Goto See2;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC GH 8 A_FaceTarget;
		BRUC I 6 A_MeleeAttack;
		BRUC I 0 A_Jump(128,"Missile");
		Goto See2;
	Pain:
		BRUC J 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC J 2 A_Pain;
		BRUC J 2 A_Jump(256,"Mode1","Mode2");
		Goto See2;
	Mode1:
		BRUC A 0 A_GiveInventory("RS_BrusMode",3);
		Goto See2;
	Mode2:
		BRUC A 0 A_TakeInventory("RS_BrusMode",3);
		Goto See2;
	Death:
		BRUC KKK 4 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BRUC K 8 Bright A_Scream;
		BRUC LLMMNN 6 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BRUC O 6 Bright A_NoBlocking;
		BRUC QR 6 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BRUC S 6;
		BRUC T -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 EX -- Black EX ("Terminator MK II").  CH: Hellknights.txt:2639.
// ---------------------------------------------------------------------------
class RS_BlackHKEX : Actor   // CH Hellknights.txt:2639
{
	int user_ready;   // CH: var int user_ready
	int user_rage;    // CH: var int user_rage
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 11000;
		Radius 24;
		Height 64;
		Mass 4000;
		DamageFactor "None", 0.7;
		RadiusDamageFactor 0.33;
		DamageFactor "Plasma", 1.25;
		DamageFactor "Melee", 0.75;
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 1.5;   // CH lists ice twice, both 1.5
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "PlayerVoid", 0.6;
		Speed 14;
		PainChance 30;
		Monster;
		Obituary "%o was terminated by T-800 Baron MK II";
		Species "BaronOfHell";
		-BOSSDEATH
		+QUICKTORETALIATE
		+MISSILEMORE
		+BOSS
		+DONTHARMSPECIES
		-NORADIUSDMG
		+DONTMORPH
		+FLOORCLIP
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "BLCKHKEX";
		PainSound "baron/pain";
		DeathSound "monster/brudth";
		MeleeSound "baron/melee";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_BlueArmor";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_PlasmaRifle";
		// CH: DropItem "RLNanoModItem" / "RareArmorPool",128 /
		// "RLUniqueWeaponSpawner",60 -- DRLA cross-mod drops, stripped
		XScale 1.25;
		YScale 1.5;
		Translation "128:143=107:111","13:15=5:8","74:79=0:2","144:144=109:109","236:239=0:2","144:151=0:2";
		Tag "Terminator MK II";
	}
	States
	{
	Spawn:
		BRUC A 0;
		Goto Scripted;
	Scripted:
		BRUC A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackHK") -- announcer stripped
		BRUC A 0 A_Log("A chill runs down your spine");
		Goto Idle;
	Idle:
		BRUC AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_JumpIf(user_ready >= 1,"See2");
		BRUC J 8 A_FaceTarget;
		BRUC J 5 Bright A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 4 A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 5 Bright A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 3 A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 2 Bright A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 1 A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 1 Bright A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 1 A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		BRUC J 1 Bright;
		BRUC J 1;
		BRUC J 1 Bright;
		BRUC J 1 { user_ready += 1; }   // CH: a_setuservar("User_ready",User_ready+1)
		BRUC J 1 Bright;
		BRUC J 1;
		Goto See2;
	See2:
		BRUC A 1 A_PlaySound("BHKEXSTP");
		BRUC AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC C 1 A_PlaySound("BHKEXSTP");
		BRUC CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC D 0 A_Jump(24,"Warp");
		Loop;
	Phase2:
		TNT1 A 0 A_JumpIf(user_rage >= 1,"Nah");
		TNT1 A 0 A_SetSpeed(18);
		TNT1 A 0 { bMISSILEEVENMORE = true; }   // CH: A_changeflag("Missileevenmore",true)
		BRUC J 6 Bright { user_rage += 1; }     // CH: a_setuservar("User_rage",User_rage+1)
		BRUC JJJJJ 2 Bright A_CustomMissile("RS_ZapDecHKex",random(12,88),random(-20,20),0);
		Goto See2;
	Nah:
		TNT1 A 0;
		Goto Missile+1;
	Missile:
		TNT1 A 0 A_JumpIfHealthLower(5000,"Phase2");
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC E 8 A_FaceTarget;
		BRUC E 0 A_JumpIfCloser(500,"Mode2");
		BRUC E 0 A_JumpIfCloser(1500,"Mode1");
		TNT1 A 0 A_Jump(256,"Homing","DeathBeam","BigMiss");
		Goto See2;
	BigMiss:
		// CH: the Missile jump table names "BigMiss", a label defined NOWHERE
		// in CH ("BigMis" is the real one). DECORATE treats the bad jump as a
		// no-op and falls through to Goto see2 -- reproduced exactly: this
		// branch does nothing and resumes the chase.
		TNT1 A 0;
		Goto See2;
	Mode1:
		BRUC E 0 A_Jump(256,"BigMis","MisBar","NadeToss","DeathBeam","FastBeam");
		Goto See2;
	Mode2:
		BRUC E 0 A_Jump(256,"BigSlash","MisBar","FastBeam","NadeToss");
		Goto See2;
	FastBeam:
		BRUC E 0 A_PlaySound("prox/beep");
		BRUC E 3 Bright A_FaceTarget;
		BRUC FE 3 Bright A_CustomMissile("RS_BluCybFX",42,15,0,0);
		BRUC F 1 Bright A_CustomMissile("RS_HKEXFastBeam",42,15,0,0);
		BRUC FFF 2 Bright A_CustomMissile("RS_HKEXFastBeam",42,15,random(-14,14),0);
		BRUC F 0 A_Jump(32,"AccurateBeam");
		BRUC F 0 A_CheckSight("See2");
		BRUC E 2 Bright A_FaceTarget;
		BRUC FE 3 Bright A_CustomMissile("RS_BluCybFX",42,15,0,0);
		BRUC F 1 Bright A_CustomMissile("RS_HKEXFastBeam",42,15,0,0);
		BRUC FFF 2 Bright A_CustomMissile("RS_HKEXFastBeam",42,15,random(-24,24),0);
		BRUC F 0 A_Jump(64,"AccurateBeam");
		BRUC E 2 Bright A_MonsterRefire(128,"See2");
		Goto FastBeam+1;
	Homing:
		BRUC E 9 Bright A_PlaySound("prox/beep");
		BRUC E 9 A_FaceTarget;
		BRUC E 9 Bright A_PlaySound("prox/beep");
		BRUC E 9 A_FaceTarget;
		BRUC F 9 Bright A_CustomMissile("RS_BruiserMissileEx2",38,15,0,0);
		BRUC E 6;
		Goto See2;
	AccurateBeam:
		BRUC FF 6 Bright A_CustomRailgun(random(1,4),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,0,0,"RS_CGRailBuff",0,0,0,66,0.7,0.9,"RS_CGRailBuff",7,10);
		BRUC F 0 A_CheckSight("See2");
		BRUC E 2 Bright A_MonsterRefire(128,"See2");
		Goto FastBeam+1;
	DeathBeam:
		BRUC EE 9 A_FaceTarget;
		BRUC E 0 A_PlaySound("prox/beep");
		BRUC F 7 Bright A_CustomMissile("RS_RedRevLoad",38,15,random(-1,1),0);
		BRUC F 5 Bright A_FaceTarget;
		BRUC F 5 Bright A_CustomMissile("RS_MegaRedRev",38,15,random(-1,1),0);
		BRUC F 0 A_SpawnItemEx("Cell",8,4,48,3,3,3,int(angle+1));
		BRUC F 0 A_SpawnItemEx("Cell",8,4,48,3,3,3,int(angle+1));
		BRUC F 5 A_Jump(60,"BigMis");
		Goto See2;
	BigMis:
		BRUC F 0 A_PlaySound("prox/beep");
		BRUC F 9 Bright A_CustomMissile("RS_BruiserMissileEx",38,15,0,0);
		BRUC F 0 A_CheckSight("See2");
		BRUC EE 7 A_FaceTarget;
		BRUC F 0 A_PlaySound("prox/beep");
		BRUC F 6 Bright A_CustomMissile("RS_BruiserMissileEx",38,15,random(-7,7),0);
		BRUC F 0 A_CheckSight("See2");
		BRUC EE 7 A_FaceTarget;
		BRUC F 0 A_PlaySound("prox/beep");
		BRUC F 6 Bright A_CustomMissile("RS_BruiserMissileEx",38,15,random(-17,17),0);
		BRUC F 0 A_SpawnItemEx("RocketBox",8,4,48,3,3,3,int(angle+1));
		BRUC F 0 A_Jump(64,"Homing");
		BRUC E 1 A_Jump(60,"MisBar");
		Goto See2;
	MisBar:
		BRUC FF 2 Bright A_CustomMissile("RS_SpreadMisBarEX",40,15,random(-5,5),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-1,1));
		BRUC FFFF 2 Bright A_CustomMissile("RS_SpreadMisBarEX",40,15,random(-14,14),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-3,3));
		BRUC F 0 A_CheckSight("See2");
		BRUC EEE 5 A_FaceTarget;
		BRUC FFF 2 Bright A_CustomMissile("RS_SpreadMisBarEX",40,15,random(-14,14),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-5,5));
		BRUC FFFFF 1 Bright A_CustomMissile("RS_SpreadMisBarEX",40,15,random(-24,24),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-7,7));
		BRUC FFF 0 A_SpawnItemEx("Shell",8,4,48,3,3,3,int(angle+1));
		BRUC E 1 A_Jump(42,"Missile");
		Goto See2;
	NadeToss:
		BRUC GH 7 A_FaceTarget;
		BRUC I 9 A_CustomMissile("RS_BaronHellNade",38,2,random(-9,9),0,random(3,12));
		BRUC I 1 A_Jump(42,"Missile");
		Goto See2;
	BigSlash:
		BRUC GH 5 A_FaceTarget;
		BRUC I 0 A_CustomMissile("RS_HKexSlash",38,2,random(-12,-4));
		BRUC I 0 A_CustomMissile("RS_HKexSlash",38,2,random(4,12));
		BRUC I 5 A_CustomMissile("RS_HKexSlash",38,2,0);
		BRUC I 1 A_Jump(42,"Missile");
		Goto See2;
	Resistance:
		BRUC J 4;
		BRUC I 5;
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",36,2,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",39,6,0);
		BRUC I 1 A_CustomMissile("RS_ZapDecHKex",39,-6,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",42,9,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",42,-9,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",42,4,0);
		BRUC I 1 A_CustomMissile("RS_ZapDecHKex",42,-4,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",45,9,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",45,-9,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",45,4,0);
		BRUC I 1 A_CustomMissile("RS_ZapDecHKex",45,-4,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",48,9,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",48,-9,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",48,4,0);
		BRUC I 1 A_CustomMissile("RS_ZapDecHKex",48,-4,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",54,2,0);
		BRUC I 0 A_CustomMissile("RS_ZapDecHKex",51,6,0);
		BRUC I 1 A_CustomMissile("RS_ZapDecHKex",51,-6,0);
		BRUC I 0 A_GiveInventory("RS_HKEXProtect",1);
		BRUC I 6 A_CustomMissile("RS_ZapOrbHKEX",78,0,0);
		TNT1 A 0 A_JumpIf(user_rage >= 1,"Res2");
		Goto See2;
	Res2:
		BRUC I 6 Bright;
		BRUC HG 8 Bright A_FaceTarget;
		BRUC GGGG 1 Bright A_CustomMissile("RS_ZapDecHKex",64,12,0);
		BRUC GHI 3 Bright;
		BRUC I 0 A_CustomMissile("RS_ZapOrbHKEX2",38,0,random(-12,1));
		BRUC I 0 A_CustomMissile("RS_ZapOrbHKEX2",38,0,random(-1,12));
		BRUC I 4 A_CustomMissile("RS_ZapOrbHKEX2",38,0,0);
		Goto See;
	Melee:
		BRUC I 0 A_Jump(255,"BigSlash");
		Goto See2;
	Warp:
		BRUC J 1 { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",TRUE)
		TNT1 A 0 A_PlaySound("WarpHKEX",0);
		BRUC J 2 A_SetScale(1.4,1.0);
		BRUC J 1 A_SetScale(1.7,0.7);
		BRUC J 1 A_SetScale(2.0,0.4);
		BRUC J 2 A_SetScale(2.3,0.2);
		BRUC J 1 A_SetScale(2.6,0.05);
		TNT1 A 0 A_SetSpeed(99);
		TNT1 AAAA 0 A_Wander;
		TNT1 AA 1 A_Wander;
		TNT1 AAAA 0 A_Wander;
		TNT1 A 0 A_JumpIf(user_rage >= 1,"Warp2");
		TNT1 A 0 A_SetSpeed(14);
		BRUC J 1 A_SetScale(2.6,0.05);
		TNT1 A 0 A_PlaySound("WarpHKEX",0);
		BRUC J 1 A_SetScale(2.3,0.2);
		BRUC J 1 A_SetScale(2.0,0.4);
		BRUC J 2 A_SetScale(1.7,0.7);
		BRUC J 2 A_SetScale(1.4,1.0);
		BRUC J 2 A_SetScale(1.25,1.5);
		BRUC J 1 { bNOPAIN = false; }
		TNT1 A 0 A_Jump(64,"Resistance");
		Goto See2;
	Warp2:
		TNT1 A 0 A_SetSpeed(18);
		BRUC J 1 A_SetScale(2.6,0.05);
		TNT1 A 0 A_PlaySound("WarpHKEX",0);
		BRUC J 1 A_SetScale(2.3,0.2);
		BRUC J 1 A_SetScale(2.0,0.4);
		BRUC J 2 A_SetScale(1.7,0.7);
		BRUC J 2 A_SetScale(1.4,1.0);
		BRUC J 2 A_SetScale(1.25,1.5);
		BRUC J 1 { bNOPAIN = false; }
		TNT1 A 0 A_Jump(78,"Resistance");
		Goto See2;
	Pain:
		BRUC J 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BRUC J 2 A_Pain;
		BRUC J 2 A_Jump(128,"Warp");
		Goto See2;
	Death:
		BRUC KKK 4 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BRUC K 8 Bright A_Scream;
		BRUC LLMMNN 6 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BRUC O 6 Bright A_NoBlocking;
		BRUC QR 6 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		BRUC S 6;
		BRUC T -1 A_BossDeath;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- White boss ("Ghost of 1993").  CH: Hellknights.txt:3238 / 3385.
// ---------------------------------------------------------------------------
class RS_WhiteHK3 : Actor   // CH Hellknights.txt:3238
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Obituary "%o was defeated by ghosts of E1M8";
		HitObituary "%o got hand smacked by the ghosts";
		Health 5000;
		Radius 24;
		Height 64;
		Mass 1000;
		Speed 13;
		Species "WhiteHK";
		PainChance 50;
		RenderStyle "Add";
		Alpha 0.75;
		BloodColor "FF FF FF";
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "phantom/death";
		ActiveSound "baron/active";
		RadiusDamageFactor 0.5;
		DamageFactor "Melee", 0.25;
		DamageFactor "Plasma", 0.85;   // CH lists Plasma twice, both 0.85
		DamageFactor "None", 0.8;
		DamageFactor "Fire", 2.0;      // CH lists Fire twice, both 2.0
		DamageFactor "Heroic", 3.0;
		DamageFactor "ice", 0.33;      // CH lists ice twice, both 0.33
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Scale 1.25;
		Monster;
		+BOSS
		+THRUSPECIES
		-NORADIUSDMG
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+DONTMORPH
		+FLOORCLIP
		+FLOAT
		+NOGRAVITY
		+MISSILEMORE
		+NOCLIP
		+NOFEAR
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_BFG9000", 64;
		DropItem "RS_CH_RocketLauncher", 128;
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		// CH: Dropitem "RLBaronBlasterPickup",42 / "RareArmorPool",128 /
		// "RLDemonicWeaponSpawner",20 / "RLLegendaryWeaponSpawner",8 /
		// "RLUniqueWeaponSpawner",32 -- DRLA cross-mod drops, stripped
		Tag "Ghost of 1993";
	}
	States
	{
	Spawn:
		PHAN A 0 NoDelay A_SpawnItemEx("RS_WHITEHK2",24,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERAMBUSHFLAG);
		Goto Scripted;
	Scripted:
		PHAN A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteHK") -- announcer stripped
		Goto Idle;
	Idle:
		PHAN AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		PHAN A 0 A_Stop;
		PHAN A 0 { bNOCLIP = true; }   // CH: A_ChangeFlag("NOCLIP",TRUE)
		PHAN AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PHAN CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See+2;
	See2:
		PHAN A 0 { bNOCLIP = false; }   // CH: A_ChangeFlag("NOCLIP",FALSE)
		PHAN AABB 3 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PHAN CCDD 3 A_FastChase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PHAN A 0 A_Jump(14,"See");
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PHAN E 0 A_Jump(64,"Summons");
		PHAN E 0 A_Jump(256,"GhostBombs","BigBomb");
	GhostBombs:
		PHAN EF 7 A_FaceTarget;
		PHAN G 8 A_CustomMissile("RS_PhantomEgg",32,0,random(-5,5),0);
		PHAN G 0 A_CheckSight("See");
		PHAN OP 7 A_FaceTarget;
		PHAN Q 8 A_CustomMissile("RS_PhantomEgg",32,0,random(-10,10),0);
		PHAN Q 0 A_MonsterRefire(128,"See");
		Goto GhostBombs;
	Summons:
		PHAN H 8 A_FaceTarget;
		PHAN H 8 A_PlaySound("Baron/Sight");
		PHAN HHHH 4 A_SpawnItemEx("RS_SpecialSpectre2",random(-64,64),random(-64,64),random(5,15),0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		PHAN A 1 A_Jump(88,"BigBomb");
		Goto See;
	BigBomb:
		PHAN EFG 7 A_FaceTarget;
		PHAN QPO 7 A_PlaySound("Baron/Pain");
		PHAN OP 5 A_FaceTarget;
		PHAN Q 9 A_CustomMissile("RS_SoulBomb",32,0,0,0);
		PHAN Q 7 A_CustomMissile("RS_SoulBomb",32,0,random(-8,8),0);
		PHAN Q 5 A_CustomMissile("RS_SoulBomb",32,0,random(-14,14),0);
		PHAN PO 4;
		PHAN A 1 A_Jump(64,"GhostBombs","Summons","BigBomb");
		Goto See;
	Pain:
		PHAN H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		PHAN H 2 A_Pain;
		PHAN A 0 A_Jump(128,"See2");
		Goto See;
	Death:
		PHAN I 8;
		PHAN J 8 A_Scream;
		PHAN K 8;
		PHAN L 8 A_NoBlocking;
		PHAN MN 8;
		PHAN R -1 A_BossDeath;
		Stop;
	}
}

class RS_WHITEHK2 : RS_WhiteHK3   // CH Hellknights.txt:3385 -- the spawned twin ghost
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }   // companion copy: no tier token
	States
	{
	Spawn:
		PHAN A 0;
		Goto Idle;
	Idle:
		PHAN AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	}
}
