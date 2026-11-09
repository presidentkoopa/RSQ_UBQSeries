// ============================================================================
// RS_Revenant.zs -- Colourful Hell Revenant family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\Revenants.txt (5,154 lines,
// read whole). Every actor cites its CH line. Support: RS_RevenantFX.zs
// (see its header for cross-lane ownership, expected-from-Barons names,
// proven-missing assets, and standing strips).
//
// Tier ladder is CH's own icon index: 1 Common, 2 Green, 3 Blue, 4 Purple,
// 5 Yellow (Orange), 6 Red, 7 FireBlu, 8 Gray, 9 Abyss, 10 Black (Knight,
// phase 2, EX, EX phase 2, EX shade -- black bosses all 10), 11 White
// (Lich), 12 Cyan, 13 Brown. RS_SpecialSoul is a summoned minion and gets
// no token.
//
// LANDING THIS FAMILY CLOSES THREE SETS OF DORMANT GUARDS:
//   (a) the zombieman family's MrBones third-raise guard
//       (RS_Zombieman.zs:2345) -- runtime-assembled "RS_CommonRevenant";
//   (b) the lostsoul family's five revenant guards (RS_LostSoulFX.zs:557,
//       :868, :872, :876, :880) -- RS_CommonRevenant x2, RS_GreenRevenant,
//       RS_PurpleRevenant, RS_RedRevenant;
//   (c) the cacodemon family's DropItem names (RS_CacodemonFX.zs:323-325) --
//       RS_CommonRevenant, RS_PurpleRevenant, RS_RedRevenant.
// All three sets now resolve. RS_RandomizerArc's four commented revenant
// drop lines (RS_LostSoulFX.zs:1924-1927, :1938) are the PARENT's to
// restore at integration -- not touched from this lane.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: Revenants.txt:1 -- Colourset1 replaces Revenant.
// ---------------------------------------------------------------------------
class RS_Colourset1 : RandomSpawner replaces Revenant
{
	Default
	{
		DropItem "RS_CommonRevenant", 255, 500;
		DropItem "RS_GreenRevenant", 255, 360;
		DropItem "RS_CyanRevenant", 255, 120;
		DropItem "RS_BlueRevenant", 255, 150;
		DropItem "RS_BrownRevenant", 255, 100;
		DropItem "RS_PurpleRevenant", 255, 75;
		DropItem "RS_YellowRevenant", 255, 40;
		DropItem "RS_RedRevenant", 255, 21;
		DropItem "RS_AbyssRevenant", 255, 30;
		DropItem "RS_BlackRevenant", 255, 4;
		DropItem "RS_FireBLURevenant", 255, 50;
		DropItem "RS_GrayRevenant", 255, 100;
		// CH: //	DropItem "BlackRevenantEX",255,2 -- commented out in CH too
		// (Revenants.txt:15); the EX boss reaches play through RS_BlackRevenant.
		DropItem "RS_WhiteRevenant", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs. CH semantics: 1 = colour off (reroll into the main set,
// CH's default), 3 = fifty-fifty, anything else = the colour spawns.
// ---------------------------------------------------------------------------
class RS_BrownRevenant : Actor   // CH Revenants.txt:19 -- gate CH_Brown
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanRevenant : Actor   // CH Revenants.txt:249 -- gate CH_Cyan
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssRevenant : Actor   // CH Revenants.txt:562 -- gate CH_Abyssmal
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBLURevenant : Actor   // CH Revenants.txt:805 -- gate CH_FireBLUES
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GrayRevenant : Actor   // CH Revenants.txt:1154 -- gate CH_Grayscale
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackRevenant : Actor   // CH Revenants.txt:2953 -- gates CH_BlackBossy + CH_ExBoss
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
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevenant3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1No:
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevenant3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX3:
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevenantEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX2:
		TNT1 A 0 A_Jump(128,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevenantEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	EX1:
		TNT1 A 0 A_Jump(232,"EX1No");
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevenantEX",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedRevenant",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteRevenant : Actor   // CH Revenants.txt:4457 -- gate CH_WhiteBossy
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
		TNT1 A 0 A_SpawnItemEx("RS_WhiteRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevenant",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 13 -- Brown Revenant ("Mummy mummy").  CH: Revenants.txt:57.
// ---------------------------------------------------------------------------
class RS_BrownRevenant2 : Actor   // CH Revenants.txt:57
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 666;
		GibHealth -85;
		Radius 20;
		Height 56;
		Mass 800;
		Speed 12;
		PainChance 120;
		Species "Revenant";
		Monster;
		MeleeThreshold 106;
		MeleeRange 102;
		+MISSILEMORE
		+MISSILEEVENMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		DamageFactor "Scrapper", 3.0;
		DamageFactor "fire", 1.25;
		MeleeRange 88;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "PLWater", 2.0;
		PainChance "PLWater", 128;
		PainThreshold 25;
		BloodColor "blue";
		Obituary "%o was blown out by brown revenant";
		HitObituary "%o got their butt whooped by brownh revenant.";
		SeeSound "monster/incsit";
		PainSound "skeleton/pain";
		DeathSound "monster/incdth";
		ActiveSound "monster/incact";
		AttackSound "monster/incatk";
		MeleeSound "monster/inchit";
		Translation "0:255=@33[128,64,0]","176:191=192:199";
		Tag "Mummy mummy";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
	}
	States
	{
	Spawn:
		INCA AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		INCA AAB 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		// RS_BrownVileGas is EXPECTED FROM THE BARONS LANE (CH Archviles.txt:450).
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		INCA BCC 2 A_Chase;
		RNGG A 0 A_RadiusGive("RS_RevSpeedBuff",256,RGF_MONSTERS,1);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		INCA DDE 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		INCA EFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		RNGG A 0 A_RadiusGive("RS_RevSpeedBuff",256,RGF_MONSTERS,1);
		TNT1 A 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		INCA G 0 A_FaceTarget;
		INCA G 5 A_SkelWhoosh;
		INCA H 5 A_FaceTarget;
		INCA I 5 A_SkelFist;
		Goto See;
	Missile:
		INCA J 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INCA J 5;
		INCA U 10 Bright;
		INCA K 0 A_CustomMissile("RS_BrownRevBall",62,12,12);
		INCA K 0 A_CustomMissile("RS_BrownRevBall",62,-12,-12);
		INCA K 10;
		Goto See;
	Pain:
		INCA L 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		INCA L 5 A_Pain;
		Goto See;
	Death:
		INCA LM 7;
		INCA N 7 A_Scream;
		INCA O 7 A_NoBlocking;
		INCA P 7;
		INCA Q -1;
		Stop;
	XDeath:
		TNT1 A 0 A_Scream;
		INCX A 10 Bright A_PlaySound("BASSFFAT",0);
		INCX BC 5 Bright;
		INCX D 5 Bright A_NoBlocking;
		TNT1 AAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_BrownVileGas",random(-2,2),random(-2,2),random(8,32),random(1,11),0,random(0,4),random(0,360),SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_RadiusGive("Health",1200,RGF_MONSTERS,500);
		TNT1 A 0 A_RadiusGive("RS_RevSpeedBuff",1200,RGF_MONSTERS,1);
		INCX EFGHIJ 5 Bright;
		INCX K -1;
	Raise:
		INCA Q 0;
		INCA QPONML 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 12 -- Cyan Revenant ("Cyan Revenant chains").  CH: Revenants.txt:271.
// ---------------------------------------------------------------------------
class RS_CyanRevenant2 : Actor   // CH Revenants.txt:271
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 480;
		Radius 20;
		Height 56;
		Mass 800;
		Speed 14;
		PainChance 120;
		Species "Revenant";
		Monster;
		MeleeThreshold 106;
		MeleeRange 102;
		+MISSILEMORE
		+MISSILEEVENMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+NOICEDEATH
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "Ice", 0.15;
		DamageFactor "Melee", 1.5;
		DamageFactor "fire", 1.5;
		MeleeRange 88;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "PLWater", 0.25;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 92;
		PainChance "Melee", 24;
		PainThreshold 25;
		SeeSound "skeleton/sight";
		PainSound "skeleton/active";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/sight";
		MeleeSound "skeleton/melee";
		HitObituary "%o got fisted ice cold";
		Obituary "%o froze from cyan revenant's agiation";
		BloodColor "blue";
		Tag "Cyan Revenant chains";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
	}
	States
	{
	Spawn:
		SREV AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SREV AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SREV DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(232,"SeeMe","See2");
		Loop;
	See2:
		SREV AABBCCDDEEFF 1 A_FastChase;
		Goto See;
	SeeMe:
		SREV A 0 A_JumpIfInTargetLOS("Jumpy",0,JLOSF_DEADNOJUMP,750);
		Goto See;
	Jumpy:
		SREV A 2 A_JumpIf(RS_Zom.CV('rs_ch_cyanbounce', 0) == 1, "See2");
		SREV A 1 ThrustThingZ(0,64,0,0);
		SREV A 1 ThrustThing(int(angle-randompick(90,130,180,230,270)),12,0,0);
		SREV A 2;
		SREV A 1 ThrustThingZ(0,52,0,0);
		SREV A 1 ThrustThing(int(angle+frandom(1,120)),18,0,0);
		Goto See;
	Melee:
		SREV G 1 A_FaceTarget;
		SREV G 3 A_SkelWhoosh;
		SREV H 3 A_FaceTarget;
		SREV I 0 A_CustomMeleeAttack(random(15,55),"skeleton/melee","none");
		SREV I 3 A_CustomMissile("RS_ChainWhipRev",64,10,0,0);
		TNT1 A 0 A_Jump(232,"SeeMe","See2");
		Goto See;
	Missile:
		SREV G 1 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SREV G 1 Bright A_FaceTarget;
		SREV G 1 Bright A_Jump(128,"IceBomb");
		SREV J 8 Bright A_FaceTarget;
		SREV K 0 A_CustomMissile("RS_IceORBCyanRev",62,12,0);
		SREV K 4 Bright A_CustomMissile("RS_IceORBCyanRev",62,-12,0);
		SREV J 8 Bright A_FaceTarget;
		SREV K 0 A_CustomMissile("RS_IceORBCyanRev",62,12,randompick(-1,1,-5,5),0,random(-1,1));
		SREV K 4 Bright A_CustomMissile("RS_IceORBCyanRev",62,-12,randompick(-1,1,-5,5),0,random(-1,1));
		SREV J 8 Bright A_FaceTarget;
		SREV K 0 A_CustomMissile("RS_IceORBCyanRev",62,12,randompick(-10,10,-5,5),0,random(-1,1));
		SREV K 4 Bright A_CustomMissile("RS_IceORBCyanRev",62,-12,randompick(-10,10,-5,5),0,random(-1,1));
		SREV K 12 A_FaceTarget;
		SREV L 2 A_Jump(64,"Bon");
		Goto See;
	IceBomb:
		SREV J 1 Bright A_FaceTarget;
		SREV J 9 Bright A_FaceTarget;
		SREV K 6 Bright A_CustomMissile("RS_BigBallCrev",62,12,5);
		SREV K 6 Bright A_CustomMissile("RS_BigBallCrev",62,-12,-5);
		SREV K 12 A_FaceTarget;
		SREV L 2 A_Jump(64,"Bon");
		Goto See;
	Pain:
		SREV L 5;
		SREV L 5 A_Pain;
		SREV L 2 A_Jump(128,"Bon");
		Goto See;
	Bon:
		SREV G 2;
		SREV G 1 ThrustThingZ(0,72,0,0);
		SREV G 1 ThrustThing(int(angle-180),18,0,0);
		SREV G 3;
		Goto See;
	Death:
		SREV LM 7;
		SREV N 7 A_Scream;
		SREV O 7 A_NoBlocking(false);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,vel.x,vel.y,vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,253);
		SREV P 7 A_IceGuyDie;
		SREV Q 7;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 9 -- Abyss Revenant.  CH: Revenants.txt:586.
// ---------------------------------------------------------------------------
class RS_AbyssRevenant2 : Actor   // CH Revenants.txt:586
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 1000;
		Species "revenant";
		BloodColor "Black";
		Radius 20;
		Height 56;
		Mass 550;
		Speed 11;
		PainChance 76;
		Monster;
		MeleeThreshold 100;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "Ice", 0.45;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 24;
		PainChance "ice", 2;
		PainChance "Fire", 88;
		PainChance "Melee", 128;
		SeeSound "skeleton/sight";
		PainSound "skeleton/active";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/sight";
		MeleeSound "skeleton/melee";
		HitObituary "%o felt the dark fist of abyss revenant";
		Obituary "%o was abyss drenched by abyss revenant";
		MeleeRange 88;
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle";
		DropItem "HealthBonus";
		DropItem "ArmorBonus";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_GreenArmor", 64;
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
		Tag "Abyss Revenant";
	}
	States
	{
	Spawn:
		SKEL AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKEL AAB 1 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		SKEL BCC 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		SKEL DDE 1 A_Chase;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-8,8),random(-8,8),random(5,32));
		SKEL EFF 1 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		SKEL G 2 A_FaceTarget;
		SKEL G 3 A_SkelWhoosh;
		SKEL H 2 A_FaceTarget;
		SKEL I 4 A_SkelFist;
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",56,3,random(-15,15),CMF_OFFSETPITCH,random(-25,-5));
		TNT1 A 0 A_Jump(86,"Missile");
		Goto See;
	Missile:
		SKEL G 2 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL G 0 A_JumpIfCloser(900,"StepDance");
	MissileIt:
		SKEL J 0 A_FaceTarget;
		SKEL J 12 Bright A_FaceTarget;
		SKEL J 1 A_CustomMissile("RS_CrackedAbyssRev",50,8,random(-10,1));
		SKEL J 5 A_CustomMissile("RS_CrackedAbyssRev",50,-8,random(-1,10));
		SKEL K 8;
		Goto See;
	StepDance:
		SKEL G 1;
		SKEL G 1 A_Jump(162,"MissileIt");
		SKEL G 1 ThrustThingZ(0,64,0,0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-328,328),random(-328,328),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		SKEL J 1 Bright A_FaceTarget;
		SKEL JJJJKK 2 A_CustomMissile("RS_IceOrbAbyssRev",42,0,random(-50,50),CMF_OFFSETPITCH,random(-35,15));
		SKEL K 8;
		Goto See;
	Phase:
		SKEL A 1;
		SKEL A 1 { bNOPAIN = true; }   // CH: a_changeflag("NOPAIN",TRUE)
		SKEL A 1 A_SetSpeed(99);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-128,128),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		SKEL ABCDEFABCDEFABCDEF 1 A_Wander;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-128,128),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		SKEL A 1 A_SetSpeed(11);
		SKEL A 1 { bNOPAIN = false; }   // CH: a_changeflag("NOPAIN",False)
		Goto See;
	Pain:
		SKEL L 5;
		SKEL L 5 A_Pain;
		SKEL L 1 A_Jump(76,"Phase");
		Goto See;
	Pain.Ice:
		SKEL A 1;
		SKEL A 2 A_PlaySound("RESISTCH");
		SKEL A 1;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		SKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SKEL LM 7;
		SKEL N 7 A_Scream;
		SKEL O 7 A_NoBlocking;
		SKEL P 7;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-128,128),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		SKEL Q -1;
		Stop;
	Raise:
		SKEL Q 5;
		SKEL PONML 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 7 -- Fire Blue Revenant ("Skeleton on fire!").  CH: Revenants.txt:824.
// ---------------------------------------------------------------------------
class RS_FireBluRevenant2 : Actor   // CH Revenants.txt:824
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 720;
		Species "revenant";
		BloodColor "blue";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "Ice", 0.9;
		DamageFactor "fire", 0.75;
		PainChance 12;
		Radius 20;
		Height 56;
		Mass 550;
		Speed 6;
		Monster;
		MeleeThreshold 255;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+DONTHARMCLASS
		+MISSILEEVENMORE
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		Obituary "%o was fire blue revenants victim";
		DropItem "RS_HealthBundle", 64;
		MeleeRange 42;
		Translation "40:45=205:207","70:74=206:207","130:143=178:191","128:129=201:203","164:167=240:243","144:151=182:191","236:239=204:207","64:79=202:207","80:82=176:178","83:95=200:207","4:4=198:198","152:159=180:189","5:15=241:245","99:110=184:191","96:98=199:203";
		Tag "Skeleton on fire!";
	}
	States
	{
	Spawn:
		SKEL AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKEL AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_JumpIfCloser(500,"Spread");
		SKEL J 0 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL J 9 Bright A_FaceTarget;
		SKEL J 7;
		SKEL K 0 A_CustomMissile("RS_FBSkelCH03",56,7,1);
		SKEL K 0 A_CustomMissile("RS_FBSkelCH04",56,-7,-1);
		SKEL K 14 Bright A_FaceTarget;
		SKEL K 0 A_CustomMissile("RS_FBSkelCH03",56,9,random(1,5));
		SKEL K 0 A_CustomMissile("RS_FBSkelCH04",56,-9,random(-5,-1));
		SKEL K 14 Bright A_FaceTarget;
		SKEL K 0 A_CustomMissile("RS_FBSkelCH03",56,9,random(2,8));
		SKEL K 0 A_CustomMissile("RS_FBSkelCH04",56,-9,random(-8,-2));
		SKEL K 14 Bright A_FaceTarget;
		SKEL K 0 A_CustomMissile("RS_FBSkelCH03",56,9,random(3,11));
		SKEL K 0 A_CustomMissile("RS_FBSkelCH04",56,-9,random(-11,-3));
		SKEL K 20 A_FaceTarget;
		Goto See;
	Spread:
		SKEL G 10;
		SKEL L 10 Bright;
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,5,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,15,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,45,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,75,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,105,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,135,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,165,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,195,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,225,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,255,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,285,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,315,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH02",42,0,345,0);
		SKEL F 0 A_CustomMissile("RS_FBSkelCH01",42,0,355,0);
		SKEL L 20;
		Goto See;
	Melee:
		SKEL G 6 A_FaceTarget;
		SKEL G 1 A_SkelWhoosh;
		SKEL H 1 A_FaceTarget;
		SKEL H 0 A_PlaySound("weapons/rocklx");
		SKEL I 1 Bright;
		SKEL I 0 A_CustomMissile("RS_BoomSkel1",42);
		Goto See;
	Pain.AbyssPE:
		AYPB A 3 Bright;
		AYPB B 3 Bright A_PlaySound("AbyssForm",0);
		AYPB CDE 3 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 3 Bright A_SetScale(1,0.75);
		AYPB H 3 Bright A_SetScale(1,0.5);
		AYPB I 3 Bright A_SetScale(1,0.25);
		AYPB H 3 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SKEL L 5;
		SKEL L 5 A_Pain;
		Goto Spread;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Pain.Fire:
	Pain.Ice:
		SKEL L 4 A_PlaySound("ResistCH",7);
		SKEL L 2;
		SKEL L 2 A_Pain;
		Goto See;
	Death:
		SKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SKEL LM 7;
		SKEL N 7 A_Scream;
		SKEL O 7 A_NoBlocking;
		SKEL P 7;
		SKEL Q -1;
		Stop;
	Raise:
		SKEL Q 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SKEL PONML 5;
		Goto See;
	Grow:
		SKEL PONML 5;
		SKEL A 0 A_SpawnItemEx("RS_PurpleRevenant",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 8 -- Gray Revenant ("Punchout master").  CH: Revenants.txt:1173.
// ---------------------------------------------------------------------------
class RS_GrayRevenant2 : Actor   // CH Revenants.txt:1173
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 660;
		Species "revenant";
		BloodColor "white";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 550;
		Speed 18;
		Monster;
		MeleeThreshold 255;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+NOPAIN
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o was oraoraoraora'd by GrayRevenant";
		DropItem "RS_HealthBundle", 64;
		MeleeRange 72;
		Translation "32:47=99:111","24:31=89:95","184:191=95:95","164:167=100:105","232:235=104:107","64:68=96:99","221:223=101:104","63:63=96:96";
		Tag "Punchout master";
	}
	States
	{
	Spawn:
		ZKEL AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetScale(1.0,1.0);
		ZKEL AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ZKEL DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		ZKEL G 1 A_FaceTarget;
		ZKEL G 1 A_SkelWhoosh;
		ZKEL H 1 A_FaceTarget;
		ZKEL I 1 A_CustomMeleeAttack(random(2,8));
		ZKEL G 1 A_SetScale(-1.0,1.0);
		ZKEL G 1 A_SkelWhoosh;
		ZKEL H 1 A_FaceTarget;
		ZKEL I 1 A_CustomMeleeAttack(random(2,8));
		Goto See;
	Missile:
		ZKEL G 0 A_JumpIfCloser(1000,"Closer");
	BoneIt:
		ZKEL G 8 A_FaceTarget;
		ZKEL H 2 A_CustomMissile("RS_BoneToPickGrey",42,3,0);
		ZKEL I 2;
		ZKEL G 6 A_FaceTarget;
		ZKEL H 2 A_CustomMissile("RS_BoneToPickGrey",42,3,random(-1,1));
		ZKEL I 2;
		ZKEL G 4 A_FaceTarget;
		ZKEL H 2 A_CustomMissile("RS_BoneToPickGrey",42,3,random(-3,3));
		ZKEL I 2;
		Goto See;
	Closer:
		TNT1 A 0 A_Jump(32,"BoneIt");
		ZKEL G 2 Bright A_SkullAttack(45);
		Goto Melee;
	Pain.AbyssPE:
		AYPB A 3 Bright;
		AYPB B 3 Bright A_PlaySound("AbyssForm",0);
		AYPB CDE 3 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 3 Bright A_SetScale(1,0.75);
		AYPB H 3 Bright A_SetScale(1,0.5);
		AYPB I 3 Bright A_SetScale(1,0.25);
		AYPB H 3 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		ZKEL L 5;
		ZKEL L 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		ZKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		ZKEL LM 7;
		ZKEL N 7 A_Scream;
		ZKEL O 7 A_NoBlocking;
		ZKEL P 7;
		ZKEL Q -1;
		Stop;
	Raise:
		ZKEL Q 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		ZKEL PONML 5;
		Goto See;
	Grow:
		ZKEL PONML 5;
		SKEL A 0 A_SpawnItemEx("RS_PurpleRevenant",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 1 -- Common Revenant.  CH: Revenants.txt:1341 (inherits Revenant).
// THIS is the class the zombieman MrBones guard, the five lostsoul guards
// and the cacodemon drop tables have been waiting on.
// ---------------------------------------------------------------------------
class RS_CommonRevenant : Revenant   // CH Revenants.txt:1341
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "revenant";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Health 300;
		GibHealth -80;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 10;
		PainChance 100;
		Monster;
		MeleeThreshold 196;
		+MISSILEMORE
		+FLOORCLIP
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o was agitated by a revenant.";
		Obituary "%o cursed the missiles of the revenant";
		MeleeRange 88;
		Tag "Revenant";
	}
	States
	{
	Spawn:
		SKEL AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKEL AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		SKEL G 1 A_FaceTarget;
		SKEL G 6 A_SkelWhoosh;
		SKEL H 6 A_FaceTarget;
		SKEL I 6 A_SkelFist;
		Goto See;
	Missile:
		SKEL J 0 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL J 10 Bright A_FaceTarget;
		SKEL J 9;
		SKEL K 0 A_CustomMissile("RS_RevenantTracer2",50,7,1);
		SKEL K 0 A_CustomMissile("RS_RevenantTracer2",50,-7,-1);
		SKEL K 10 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBA 5 Bright;
		AYPB CDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SKEL L 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL L 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		SKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SKEL LM 7;
		SKEL N 7 A_Scream;
		SKEL O 7 A_NoBlocking;
		SKEL P 7;
		SKEL Q -1;
		Stop;
	XDeath:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-12,12),random(-12,12),random(20,52),0,0,0,0,0);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 AAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-2,2),random(-2,2),random(26,34),0,0,0,0,0);
		TNT1 A 0 A_SetTranslucent(0.1);
		REVB A 1 ThrustThingZ(0,45,0,0);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_Scream;
		REVB A 5 A_SetTranslucent(0.35);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_NoBlocking;
		REVB A 5 A_SetTranslucent(0.7);
		REVB A 8 A_SetTranslucent(1);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		REVB A -1;
		Stop;
	Raise:
		SKEL Q 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SKEL PONML 5;
		Goto See;
	Grow:
		SKEL PONML 5;
		SKEL A 0 A_SpawnItemEx("RS_GreenRevenant",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 2 -- Green Revenant.  CH: Revenants.txt:1464.
// ---------------------------------------------------------------------------
class RS_GreenRevenant : Actor   // CH Revenants.txt:1464
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 360;
		GibHealth -90;
		Species "revenant";
		BloodColor "Green";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 550;
		Speed 11;
		PainChance 88;
		Monster;
		MeleeThreshold 255;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o was punching bagged by uncommon revenant";
		Obituary "%o took a taste of homing acid";
		DropItem "RS_HealthBundle", 64;
		MeleeRange 88;
		Translation "16:47=112:127","232:235=123:127","128:143=115:127","144:151=121:127","64:79=152:159","160:167=112:127","208:223=112:127";
		Tag "Green Revenant";
	}
	States
	{
	Spawn:
		SKEL AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKEL AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL AA 0 A_SpawnItemEx("RS_Splash11",random(-5,5),random(-5,5),random(5,56));
		Loop;
	Melee:
		SKEL G 3 A_FaceTarget;
		SKEL GG 0 A_SpawnItemEx("RS_Splash11",random(-5,5),random(-5,5),random(5,56));
		SKEL G 6 A_SkelWhoosh;
		SKEL H 6 A_FaceTarget;
		SKEL I 6 A_SkelFist;
		Goto See;
	Missile:
		SKEL J 0 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL J 9 Bright A_FaceTarget;
		SKEL JJ 0 A_SpawnItemEx("RS_Splash11",random(-5,5),random(-5,5),random(5,56));
		SKEL J 7;
		SKEL K 0 A_CustomMissile("RS_AcidBlast1",50,7,1);
		SKEL K 0 A_CustomMissile("RS_AcidBlast1",50,-7,-1);
		SKEL K 8 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBA 5 Bright;
		AYPB CDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SKEL L 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL LL 0 A_SpawnItemEx("RS_Splash11",random(-5,5),random(-5,5),random(5,56));
		SKEL L 5 A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		SKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SKEL LM 7;
		SKEL N 7 A_Scream;
		SKEL N 0 A_SpawnItemEx("RS_Splash11",random(-5,5),random(-5,5),random(5,56));
		SKEL O 7 A_NoBlocking;
		SKEL P 7;
		SKEL P 0 A_SpawnItemEx("RS_Splash11",random(-5,5),random(-5,5),random(5,56));
		SKEL Q -1;
		Stop;
	XDeath:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-12,12),random(-12,12),random(20,52),0,0,0,0,0);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 AAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-2,2),random(-2,2),random(26,34),0,0,0,0,0);
		TNT1 A 0 A_SetTranslucent(0.1);
		REVB A 1 ThrustThingZ(0,45,0,0);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnParticle("green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_Scream;
		REVB A 5 A_SetTranslucent(0.35);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_NoBlocking;
		REVB A 5 A_SetTranslucent(0.7);
		REVB A 8 A_SetTranslucent(1);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		REVB A -1;
		Stop;
	Raise:
		SKEL Q 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SKEL PONML 5;
		Goto See;
	Grow:
		SKEL PONML 5;
		SKEL A 0 A_SpawnItemEx("RS_BlueRevenant",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 3 -- Blue Revenant.  CH: Revenants.txt:1697.
// ---------------------------------------------------------------------------
class RS_BlueRevenant : Actor   // CH Revenants.txt:1697
{
	int user_nodash1;   // CH: Var Int User_nodash1;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 420;
		Species "revenant";
		BloodColor "Blue";
		Radius 20;
		Height 56;
		GibHealth -80;
		Mass 550;
		Speed 12;
		PainChance 77;
		Monster;
		MeleeThreshold 300;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o felt tyson of the rare blue revenant";
		Obituary "%o is feeling bit blue from that blast";
		MeleeRange 88;
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_ArmorBundle";
		DropItem "ArmorBonus", 128;
		DropItem "RS_CH_Cell", 64;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Translation "128:143=192:207","144:151=197:207","64:79=195:207","13:15=205:207","32:47=200:207","63:63=205:205","232:235=200:205","163:167=200:204","208:223=198:206","26:31=199:205";
		Tag "Blue Revenant";
	}
	States
	{
	Spawn:
		SKEL AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKEL AABBCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL DDEEFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Jumper:
		SKEL AABBCCDDEEFF 2 A_FastChase;
		SKEL A 0 A_Jump(158,"See");
		Loop;
	Melee:
		SKEL G 3 A_FaceTarget;
		SKEL G 5 A_SkelWhoosh;
		SKEL H 5 A_FaceTarget;
		SKEL I 4 A_SkelFist;
		Goto See;
	Missile:
		SKEL G 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL G 0 A_JumpIfCloser(300,"Falcon");
		SKEL G 0 A_Jump(255,"Blastings");
		Goto See;
	Falcon:
		SKEL G 0 A_JumpIf(user_nodash1 >= 11,"Blastings");
		SKEL G 0 { user_nodash1 = user_nodash1 + 5; }   // CH: A_SetUserVar("User_nodash1",User_nodash1+5)
		SKEL G 2 Bright A_SkullAttack(30);
		Goto Melee;
	Blastings:
		SKEL J 0 A_FaceTarget;
		SKEL J 12 Bright A_FaceTarget;
		SKEL J 5;
		SKEL K 0 A_CustomMissile("RS_Zap7",50,7,random(0,2));
		SKEL K 0 A_CustomMissile("RS_Zap7",50,-7,random(-2,0));
		SKEL J 12 Bright A_FaceTarget;
		SKEL K 0 A_CustomMissile("RS_Zap8",50,-7,random(4,7));
		SKEL K 0 A_CustomMissile("RS_Zap8",50,7,random(-7,-4));
		SKEL K 0 A_CustomMissile("RS_Zap8",50,7);
		SKEL K 0 A_CustomMissile("RS_Zap8",50,-7);
		SKEL K 0 A_CustomMissile("RS_Zap8",50,-7,random(4,7));
		SKEL K 0 A_CustomMissile("RS_Zap8",50,7,random(-7,-4));
		SKEL K 0 A_CustomMissile("RS_Zap8",50,-7,random(-7,7));
		SKEL G 0 { user_nodash1 = user_nodash1 - 2; }   // CH: A_SetUserVar("User_nodash1",User_nodash1-2)
		SKEL K 8 A_FaceTarget;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBA 5 Bright;
		AYPB CDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SKEL L 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL L 5 A_Pain;
		Goto Jumper;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		SKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SKEL LM 7;
		SKEL N 7 A_Scream;
		SKEL O 7 A_NoBlocking;
		SKEL P 7;
		SKEL Q -1;
		Stop;
	XDeath:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-12,12),random(-12,12),random(20,52),0,0,0,0,0);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 AAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-2,2),random(-2,2),random(26,34),0,0,0,0,0);
		TNT1 A 0 A_SetTranslucent(0.1);
		REVB A 1 ThrustThingZ(0,45,0,0);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_Scream;
		REVB A 5 A_SetTranslucent(0.35);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAA 0 A_SpawnParticle("Blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_NoBlocking;
		REVB A 5 A_SetTranslucent(0.7);
		REVB A 8 A_SetTranslucent(1);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		REVB A -1;
		Stop;
	Raise:
		SKEL Q 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SKEL PONML 5;
		Goto See;
	Grow:
		SKEL PONML 5;
		SKEL A 0 A_SpawnItemEx("RS_PurpleRevenant",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 4 -- Purple Revenant.  CH: Revenants.txt:1908.
// ---------------------------------------------------------------------------
class RS_PurpleRevenant : Actor   // CH Revenants.txt:1908
{
	int user_nodash2;   // CH: Var int User_nodash2;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 515;
		GibHealth -80;
		Species "revenant";
		BloodColor "Purple";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Radius 20;
		Height 56;
		Mass 550;
		Speed 13;
		PainChance 66;
		Monster;
		MeleeThreshold 200;
		+MISSILEMORE
		+MISSILEEVENMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		SeeSound "skeleton/sight";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o felt the touch of the purple revenant's revenanting revenant fist";
		Obituary "%o got purple powered";
		DropItem "RS_HealthBundle", 164;
		DropItem "HealthBonus";
		DropItem "RS_ArmorBundle", 72;
		DropItem "RS_CH_GreenArmor", 42;
		DropItem "RS_CH_CellPack", 24;
		MeleeRange 88;
		RenderStyle "SoulTrans";
		Alpha 0.92;
		Translation "128:143=[241,48,241]:[54,7,53]","64:79=[209,102,213]:[83,21,89]","144:151=[145,38,145]:[112,29,139]","163:167=[118,37,96]:[84,35,103]","16:31=[190,54,205]:[83,23,98]","32:47=[187,41,207]:[56,15,60]","13:15=[101,35,101]:[55,19,54]","232:235=[74,26,73]:[100,58,112]","48:63=[173,43,191]:[67,27,103]","96:111=[123,28,30]:[64,19,20]","80:95=[192,48,51]:[141,35,38]","152:159=[142,43,45]:[65,20,41]","4:4=[196,45,234]:[230,21,27]";
		Tag "Purple Revenant";
	}
	States
	{
	Spawn:
		SKEL AB 10 A_Look;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SKEL AABB 3 A_Chase;
		SKEL B 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL CCDD 3 A_Chase;
		SKEL D 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL EEFF 3 A_Chase;
		SKEL F 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Jumper2:
		SKEL AABB 3 A_FastChase;
		SKEL B 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL CCDD 3 A_FastChase;
		SKEL D 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL EEFF 3 A_FastChase;
		SKEL F 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL A 0 A_Jump(158,"See");
		Loop;
	Melee:
		SKEL G 3 A_FaceTarget;
		SKEL G 4 A_SkelWhoosh;
		SKEL G 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL H 4 A_FaceTarget;
		SKEL I 4 A_SkelFist;
		Goto See;
	Missile:
		SKEL G 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL G 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL G 0 A_JumpIfCloser(300,"Falcon2");
		SKEL G 0 A_JumpIfCloser(1800,"Fireing2");
		SKEL G 0 A_Jump(255,"Fireing1");
		Goto See;
	Falcon2:
		SKEL G 0 A_JumpIf(user_nodash2 >= 11,"Fireing2");
		SKEL G 0 { user_nodash2 = user_nodash2 + 5; }   // CH: A_SetUserVar("User_nodash2",User_nodash2+5)
		SKEL G 2 Bright A_SkullAttack(40);
		Goto Melee;
	Fireing2:
		SKEL J 0 A_FaceTarget;
		SKEL J 9 Bright A_FaceTarget;
		SKEL J 5 Bright A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL K 0 A_CustomMissile("RS_Purp1",50,7,random(0,2));
		SKEL K 0 A_CustomMissile("RS_Purp1",50,-7,random(-2,0));
		SKEL J 8 Bright A_FaceTarget;
		SKEL J 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL G 0 { user_nodash2 = user_nodash2 - 2; }   // CH: A_SetUserVar("User_nodash2",User_nodash2-2)
		SKEL K 8 A_FaceTarget;
		Goto See;
	Fireing1:
		SKEL J 0 A_FaceTarget;
		SKEL G 15 Bright;
		SKEL J 15 Bright A_FaceTarget;
		SKEL J 5 Bright A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		TNT1 A 0 A_CheckSight("See");
		SKEL K 0 A_CustomRailgun(random(2,20),7,"purple","white",RGF_FULLBRIGHT,1,0,"RS_FatsoPuff3",0,0,10000,0,1,1,null,20);
		SKEL K 0 A_CustomRailgun(random(2,20),-7,"purple","white",RGF_FULLBRIGHT,1,0,"RS_FatsoPuff3",0,0,10000,0,1,1,null,20);
		SKEL J 10 Bright A_FaceTarget;
		SKEL JJJ 0 A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		SKEL K 8 A_MonsterRefire(120,"See");
		Goto Missile;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBA 5 Bright;
		AYPB CDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SKEL L 5 Bright A_CustomMissile("RS_Zap99",random(20,64),random(-15,15));
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SKEL L 5 A_Pain;
		Goto Jumper2;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		SKEL L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SKEL LM 7;
		SKEL N 7 A_Scream;
		SKEL O 7 A_NoBlocking;
		SKEL P 7;
		SKEL Q -1;
		Stop;
	XDeath:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnParticle("purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-12,12),random(-12,12),random(20,52),0,0,0,0,0);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-32,32),random(-32,32),random(10,64),0,0,0,0,0);
		TNT1 AAA 1 A_SpawnItemEx("RS_HomingRocketTrailFatso",random(-2,2),random(-2,2),random(26,34),0,0,0,0,0);
		TNT1 A 0 A_SetTranslucent(0.1);
		REVB A 1 ThrustThingZ(0,45,0,0);
		TNT1 AAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnParticle("purple",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_Scream;
		REVB A 5 A_SetTranslucent(0.35);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 AAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		REVB A 5 A_NoBlocking;
		REVB A 5 A_SetTranslucent(0.7);
		REVB A 8 A_SetTranslucent(1);
		TNT1 AAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		REVB A -1;
		Stop;
	Raise:
		SKEL Q 5;
		SKEL PONML 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// The Lich/Orange escort soul -- a summoned minion, NO tier token.
// CH: Revenants.txt:2207.
// CH also carries a commented-out "YellowRevenant //This is an egg" actor
// at Revenants.txt:2178-2205 that spawned this soul plus a YellowRevenant2;
// it is inside a /* */ block in CH and is deliberately not rebuilt here.
// ---------------------------------------------------------------------------
class RS_SpecialSoul : Actor   // CH Revenants.txt:2207
{
	Default
	{
		Species "Revenant";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 0;
		Health 75;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 7;
		PainChance 256;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTFALL
		+NOICEDEATH
		+THRUSPECIES
		+NOCLIP
		+NOINFIGHTING
		+NOTARGET
		+NOFEAR
		+DONTBLAST
		+DONTTHRUST
		AttackSound "skull/melee";
		PainSound "skull/pain";
		DeathSound "skull/death";
		ActiveSound "skull/active";
		RenderStyle "Add";
		DropItem "HealthBonus";
		DropItem "HealthBonus", 200;
		DropItem "HealthBonus", 88;
		DropItem "HealthBonus", 64;
		Alpha 0.95;
		Scale 0.85;
		Obituary "%o got hit by Legendary Revenant's assistant soul";
		Tag "Soul soother";
	}
	States
	{
	Spawn:
		SKUL AB 10 Bright A_Look;
		Loop;
	See:
		SKUL AB 6 Bright A_Chase;
		SKUL A 0 A_JumpIfMasterCloser(720,"See");
		SKUL A 1 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	Missile:
		SKUL C 10 Bright A_FaceTarget;
		SKUL D 4 Bright A_CustomBulletAttack(8,8,random(1,6),1,"RS_PsychPuff");
		SKUL CD 4 Bright;
		Goto See;
	Pain:
		SKUL E 3 Bright;
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
// Tier 5 -- Orange ("Yellow") Revenant.  CH: Revenants.txt:2311.
// Gate CH_YellowRev (CH CVARINFO.txt:19, default 0) becomes
// RS_Zom.CV('rs_ch_yellowrev', 0). That cvar is NOT in this repo's
// CVARINFO.txt and this lane must not edit it; CV() returns the CH default
// 0, which is CH's own behaviour (Script3: noclip + four escort souls).
// A_SetTranslation("YellowRev01") is kept verbatim -- see the FX header,
// the translation is CH TRNSLATE.txt:10 and absent from our TRNSLATE.txt.
// ---------------------------------------------------------------------------
class RS_YellowRevenant : Actor   // CH Revenants.txt:2311
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	Default
	{
		Health 666;
		GibHealth -100;
		Species "revenant";
		BloodColor "Yellow";
		Radius 20;
		Height 56;
		Mass 750;
		Speed 7;
		PainChance 30;
		DamageFactor "Fire", 0.3;
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 8;
		DamageFactor "PLWater", 2.0;
		PainChance "PLWater", 128;
		PainChance "ice", 2;
		Monster;
		MeleeThreshold 200;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		-NORADIUSDMG
		+DONTHARMCLASS
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		DropItem "RS_CH_BlueArmor", 102;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketAmmo", 176;
		DropItem "RS_CH_RocketAmmo", 176;
		DropItem "RS_CH_RocketAmmo", 176;
		DropItem "RS_CH_RocketAmmo", 176;
		SeeSound "skeleton/sight";
		PainSound "skeleton/sight";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		HitObituary "%o found no escape from the horrible legendary revenant";
		Obituary "%o was left as charred bones";
		MeleeRange 94;
		RenderStyle "Add";
		Alpha 0.85;
		Translation "128:143=208:223","64:79=214:223","144:151=164:167","32:47=163:167","80:95=215:219","4:4=225:225";
		Tag "Terrifying Orange (NoClip?) Revenant";
	}
	States
	{
	Spawn:
		REVN A 0;
		Goto Scripted;
	Scripted:
		REVN A 0 A_JumpIf(RS_Zom.CV('rs_ch_yellowrev', 0) == 1, "Script1");
		REVN A 0 A_JumpIf(RS_Zom.CV('rs_ch_yellowrev', 0) == 2, "Script2");
	Script3:
		REVN A 0 { bNOCLIP = true; }   // CH: a_changeflag("noclip",true)
		SKUL A 0 A_SpawnItemEx("RS_SpecialSoul",0,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 0 A_SpawnItemEx("RS_SpecialSoul",0,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 0 A_SpawnItemEx("RS_SpecialSoul",5,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION|SXF_TRANSFERAMBUSHFLAG);
		SKUL A 0 A_SpawnItemEx("RS_SpecialSoul",-5,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION|SXF_TRANSFERAMBUSHFLAG);
		Goto Idle;
	Script1:
		TNT1 A 0 A_SetSpeed(24);
		TNT1 A 0 A_SetRenderStyle(1.0,STYLE_Normal);
		TNT1 A 0 A_SetTranslation("YellowRev01");
		Goto Idle;
	Script2:
		REVN A 0 A_Jump(128,"Script1");
		Goto Script3;
	Idle:
		REVN AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		REVN A 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	See:
		REVN AABBCC 5 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		REVN DDEEFF 5 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		REVN A 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Melee:
		REVN G 6 A_FaceTarget;
		REVN G 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN G 4 A_SkelWhoosh;
		REVN H 4 A_FaceTarget;
		REVN H 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN I 4 A_SkelFist;
		Goto See;
	Missile:
		REVN G 4 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		REVN G 0 A_JumpIfCloser(600,"NewMove");
		REVN G 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN G 0 A_JumpIfCloser(1500,"Projeor");
		REVN G 0 A_Jump(255,"HellFlame");
		Goto See;
	NewMove:
		TNT1 A 0 A_JumpIf(speed >= 20,"SpitIt");
		Goto Missile+4;
	SpitIt:
		REVN L 8 Bright;
		REVN K 8 Bright A_FaceTarget;
		REVN JJJJ 3 Bright A_CustomMissile("RS_FireSpeNewYel",46,0,random(-6,6),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-5,-1));
		REVN J 5 A_CheckSight("See");
		Goto Missile;
	Projeor:
		REVN G 0 A_Jump(78,"Proje");
		REVN G 0 A_Jump(255,"Proje","HellFlame");
		Goto See;
	Proje:
		REVN J 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN J 0 A_FaceTarget;
		REVN J 9 Bright A_FaceTarget;
		REVN J 5 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN K 0 A_CustomMissile("RS_Homer1",50,9,random(0,5));
		REVN K 0 A_CustomMissile("RS_Homer1",50,-9,random(-5,0));
		REVN J 8 Bright A_FaceTarget;
		REVN J 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN K 8 A_FaceTarget;
		Goto See;
	HellFlame:
		REVN G 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN G 14 Bright A_CustomMissile("RS_FireHand1",32,20);   // Barons lane: RS_BaronFX.zs:233
		REVN H 10 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN I 8 Bright A_VileTarget("RS_BigBadFire1");   // Barons lane: RS_BaronFX.zs:258
		REVN I 9 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Goto See;
	FlameSplit:
		REVN L 0 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN L 5 Bright;
		REVN K 5 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		REVN K 0 A_CustomMissile("RS_Firespe1",42,0,random(-360,360));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBA 5 Bright;
		AYPB CDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		REVN L 5 A_CustomMissile("RS_SparkPuff1",34,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		REVN L 5 A_Pain;
		REVN L 0 A_Jump(76,"FlameSplit");
		Goto See;
	Pain.Fire:
		REVN L 0 A_Jump(42,"Whatthe");
		Goto See;
	Whatthe:
		REVN K 1;
		REVN H 1 A_PlaySound("skeleton/sight");
		SKEL L 1;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		REVN L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		REVN LM 7;
		REVN N 7 A_Scream;
		REVN O 7 A_NoBlocking;
		REVN P 7;
		REVN Q -1;
		Stop;
	XDeath:
		TNT1 A 5 A_SpawnItemEx("RS_ArcRing1",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Scream;
		TNT1 A 1 A_NoBlocking;
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,0);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,45);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,90);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,135);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,180);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,225);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,270);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,305);
		RIP1 H 0 A_CustomMissile("RS_ArchvileFire2",0,0,340);
		TNT1 A 24;
		REVB A 12 A_SetTranslucent(0.15);
		REVB A 12 A_SetTranslucent(0.3);
		REVB A 12 A_SetTranslucent(0.45);
		REVB A 12 A_SetTranslucent(0.6);
		REVB A 12 A_SetTranslucent(0.8);
		REVB A -1;
		Stop;
	Raise:
		REVN QPONML 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 6 -- Red Revenant.  CH: Revenants.txt:2706.
// ---------------------------------------------------------------------------
class RS_RedRevenant : Actor   // CH Revenants.txt:2706
{
	int user_ttt;   // CH: Var Int User_TTT;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 830;
		GibHealth -150;
		Species "revenant";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "fire", 4;
		DamageFactor "ice", 1.45;
		Radius 20;
		Height 56;
		Mass 750;
		Speed 14;
		PainChance 22;
		Monster;
		MeleeThreshold 200;
		+MISSILEMORE
		+FLOORCLIP
		+QUICKTORETALIATE
		+DONTHARMSPECIES
		+NOFEAR
		-NORADIUSDMG
		+DONTHARMCLASS
		DropItem "RS_CH_BlueArmor", 128;
		DropItem "RS_CH_Berserk", 128;
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_RocketBox", 108;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_RocketAmmo", 200;
		DropItem "RS_CH_RocketAmmo", 200;
		DropItem "RS_CH_RocketAmmo", 200;
		// CH: DropItem "RLRevenantsLauncherPickup",12 -- DRLA cross-mod drop, stripped.
		SeeSound "skeleton/sight";
		PainSound "skeleton/sight";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/sight";
		MeleeSound "skeleton/melee";
		MeleeRange 94;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		HitObituary "%o was Close Combated by Red Revenant";
		Obituary "%o got some bloody agitation on them";
		Tag "a Bloody Red Revenant";
	}
	States
	{
	Spawn:
		RASK AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		RASK AAABBBCCC 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		RASK DDDEEEFFF 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Melee:
		RASK G 1 A_FaceTarget;
		RASK G 6 A_SkelWhoosh;
		RASK H 5 A_FaceTarget;
		RASK I 3 A_SkelFist;
		RASK I 3 A_SkelFist;
		Goto See;
	Missile:
		RASK J 1 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		RASK J 1 Bright A_JumpIf(user_ttt >= 4,"MegaShot");
		RASK J 9 Bright A_FaceTarget;
		RASK K 10 A_CustomMissile("RS_RedDeathRev",60,9,random(-4,4));
		RASK K 0 { user_ttt = user_ttt + 1; }   // CH: A_SetUserVar("User_TTT",User_TTT+1)
		RASK K 10 A_FaceTarget;
		RASK K 2;
		Goto See;
	MegaShot:
		RASK J 5 Bright A_PlaySound("Skeleton/Sight");
		RASK JJJ 5 Bright A_FaceTarget;
		RASK J 10 Bright A_CustomMissile("RS_RedRevLoad",60,9,0);
		RASK J 15 Bright A_FaceTarget;
		RASK K 7 Bright A_CustomMissile("RS_MegaRedRev",60,9,random(-4,4));
		RASK K 5 A_FaceTarget;
		RASK K 1 { user_ttt = user_ttt - 4; }   // CH: A_SetUserVar("User_TTT",User_TTT-4)
		RASK K 1;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_changeflag("Nopain",true)
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBA 5 Bright;
		AYPB CDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssRevenant2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		RASK L 5;
		RASK L 5 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		RASK L 5 A_Pain;
		RASK L 5 { bNOPAIN = true; }          // CH: A_ChangeFlag("NOPAIN",TRUE)
		RASK L 5 { bMISSILEEVENMORE = true; } // CH: A_changeFlag("MissileEvenMore",TRUE)
		RASK L 5;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		RASK L 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		RASK LM 7;
		RASK N 7 A_Scream;
		RASK O 7 A_NoBlocking;
		RASK P 7;
		RASK Q -1;
		Stop;
	XDeath:
		TNT1 A 1 A_Scream;
		TNT1 A 0 A_NoBlocking;
		TNT1 A 1 A_CustomMissile("RS_RedRevLoad",42,0,0);
		TNT1 AAAAAAAAAAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 7;
		TNT1 AAAAAAAAA 1 A_CustomMissile("RS_HKRedDeath",random(12,64),random(-16,16));
		TNT1 AAAAAAAAAAAAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 24;
		RASK Q 12 A_SetTranslucent(0.2);
		RASK Q 12 A_SetTranslucent(0.3);
		RASK Q 12 A_SetTranslucent(0.4);
		RASK Q 12 A_SetTranslucent(0.5);
		RASK Q 12 A_SetTranslucent(0.6);
		RASK Q 12 A_SetTranslucent(0.7);
		RASK Q 12 A_SetTranslucent(0.8);
		RASK Q 12 A_SetTranslucent(0.95);
		RASK Q -1;
	Raise:
		RASK QPONML 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- The Black Knight, phase 1.  CH: Revenants.txt:2989.
// CH: "////// AnnounceBlackRev" (Revenants.txt:2951) and the
// ACS_NamedExecuteAlways("AnnounceBlackRev") call in Scripted are the ACS
// announcer, stripped per the standing order; the 1-tic timing states stay.
// The DNKT sprite in Scripted is CH's own transposition of DKNT and has no
// lump in CH either -- kept verbatim, see the FX header.
// ---------------------------------------------------------------------------
class RS_BlackRevenant3 : Actor   // CH Revenants.txt:2989
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 4500;
		Radius 20;
		Height 56;
		Mass 700;
		Speed 10;
		PainChance 64;
		MeleeRange 92;
		Species "MontyP";
		RadiusDamageFactor 0.33;
		DamageFactor "Melee", 0.6;
		DamageFactor "Fire", 1.75;
		DamageFactor "Ice", 0.80;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 28;
		PainChance "ice", 42;
		PainChance "Fire", 42;
		PainChance "Melee", 2;
		Monster;
		+FLOORCLIP
		+NOTARGET
		+BOSS
		-NORADIUSDMG
		+MISSILEMORE
		+NOFEAR
		+DONTMORPH
		+NOICEDEATH
		+THRUSPECIES
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		Obituary "No, %o , we wont call it a draw";
		HitObituary "oh c'mon now, %o , its just a flesh wound";
		MeleeSound "monster/dknhit";
		SeeSound "BK/Pass";
		PainSound "monster/dknpai";
		DeathSound "monster/dkdie";   // PROVEN MISSING IN CH -- silent there too
		ActiveSound "monster/dknact";
		Translation "160:167=102:111","208:223=240:247","229:231=207:207","144:151=102:111","69:79=5:8","128:133=96:102";
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "BackPack";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		DropItem "RS_CH_RocketAmmo";
		Tag "The Black Knight";
	}
	States
	{
	Spawn:
		DKNT A 1;
		Goto Scripted;
	Scripted:
		DKNT A 1;   // CH: DNKT -- CH typo; DKNT is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		// CH: DNKT A 1 ACS_NamedExecuteAlways("AnnounceBlackRev") -- ACS announcer stripped.
		DKNT A 1;   // CH: DNKT -- CH typo; DKNT is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		DKNT A 1;   // CH: DNKT -- CH typo; DKNT is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Idle;
	Idle:
		DKNT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DKNT CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	ShieldSee:
		TNT1 A 0 A_SpawnItemEx("RS_RevShieldWalk",0,4,64,0,0,0,0,SXF_SETMASTER);
		DKNT PPQQRRSS 3 A_Chase;
		Goto See;
	Melee:
		DKNT E 6 A_FaceTarget;
		DKNT F 1 A_PlaySound("monster/dknswg");
		DKNT F 6 A_FaceTarget;
		DKNT G 6 A_CustomMeleeAttack(random(20,120));
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT A 0 A_PlaySound("BK/invi",0,4);
		DKNT A 0 A_Jump(255,"DartCleave","Mines","Dash");
		Goto See;
	DartCleave:
		DKNT E 9 Bright A_FaceTarget;
		DKNT F 8 Bright A_PlaySound("monster/kntswg");
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(-6,-2),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(-12,-7),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,0,0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(7,12),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(2,6),0);
		DKNT G 5 Bright;
		Goto See;
	Mines:
		DKNT T 8 Bright A_FaceTarget;
		DKNT U 2 Bright A_FaceTarget;
		DKNT U 0 A_CustomMissile("RS_MinesRev",44,-4,-12,0);
		DKNT U 6 Bright A_CustomMissile("RS_MinesRev",44,-4,12,0);
		DKNT U 0 A_UnSetReflectiveInvulnerable;
		DKNT U 0 A_Jump(64,"Mines");
		Goto See;
	Dash:
		DKNT E 8 Bright A_UnSetReflectiveInvulnerable;
		DKNT FFFFF 8 Bright A_SkullAttack(38);
		DKNT G 4 Bright A_Stop;
		Goto Melee;
	Shield:
		TNT1 A 0 { bNOPAIN = true; }    // CH: a_changeflag(NOPAIN,TRUE)
		TNT1 A 0 A_SpawnItemEx("RS_RevShieldWalk",0,4,64,0,0,0,0,SXF_SETMASTER);
		DKNT P 60;
		DKNT T 10 Bright A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT U 10 Bright A_CustomMissile("RS_ShieldBlastRev",44,0,0,0);
		TNT1 A 0 { bNOPAIN = false; }   // CH: a_changeflag(NOPAIN,FALSE)
		Goto See;
	Pain:
		DKNT H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DKNT H 2 A_Pain;
		DKNT P 0 A_Jump(178,"Shield");
		Goto See;
	Pain.Melee:
	Pain.Ice:
		DKNT H 1;
		DKNT H 1 A_PlaySound("ResistCH",7);
		DKNT PT 1;
		Goto ShieldSee;
	Pain.Fire:
		DKNT H 1;
		DKNT H 2 A_Pain;
		DKNT H 2 A_Pain;
		DKNT P 1;
		Goto ShieldSee;
	Death:
		DKNT I 12 Bright A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT I 0 A_CustomMissile("RS_DKSword",44,32,-90,0);
		DKNT I 8 Bright A_CustomMissile("RS_DKShield",44,-32,90,0);
		DKNT J 8 Bright;
		DKNT J 8 Bright A_Scream;
		DKNT J 8 Bright A_NoBlocking;
		DKNT K 8 Bright A_SpawnItemEx("RS_BlackRev2",0,0,32,0,0,0,0,SXF_NOCHECKPOSITION);
		DKNT L 8 Bright;
		DKNT MN 8 Bright;
		DKNT O -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- The Black Knight, phase 2 ("Just a flesh wound").
// CH: Revenants.txt:3452.
// ---------------------------------------------------------------------------
class RS_BlackRev2 : Actor   // CH Revenants.txt:3452
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 2800;
		BloodColor "black";
		Radius 24;
		Height 56;
		Mass 400;
		Speed 16;
		RadiusDamageFactor 0.33;
		DamageFactor "Fire", 1.1;
		DamageFactor "Melee", 0.4;
		DamageFactor "Plasma", 2.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Heroic", 3.0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 8;
		PainChance "Melee", 2;
		FloatSpeed 19;
		PainChance 12;
		Monster;
		+FLOAT
		+NOGRAVITY
		+NOTARGET
		+BOSS
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOFEAR
		+NOCLIP
		+DONTBLAST
		+NODAMAGETHRUST
		RenderStyle "Add";
		Alpha 1.05;
		SeeSound "BK/Phase2";
		PainSound "monster/dknpai";
		DeathSound "BK/Die";
		ActiveSound "monster/dknact";
		Obituary "%o found out that the black knight doesnt give up";
		Translation "64:79=96:111","236:239=5:8","128:143=199:203","144:151=240:247";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_BlueArmor";
		// CH: Dropitem "RLDemonicWeaponSpawner",12 -- DRLA cross-mod drop, stripped.
		Tag "Just a flesh wound";
	}
	States
	{
	Spawn:
		WRTH AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WRTH A 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		WRTH E 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WRTH E 0 A_Jump(255,"Seekers","AoE","Shots");
	Shots:
		WRTH F 5 A_FaceTarget;
		WRTH G 5 Bright;
		WRTH G 0 A_CustomMissile("RS_RevSol",32,0,random(-9,9));
		WRTH G 0 A_CustomMissile("RS_RevSol",32,0,random(-1,1));
		WRTH G 0 A_CustomMissile("RS_RevSol",32,0,random(-9,9));
		Goto See;
	AoE:
		WRTH FG 5 A_FaceTarget;
		WRTH IJ 5 Bright A_PlaySound("Spell/SpellCast1",0,3);
		WRTH I 0 A_CustomMissile("RS_DKFire2",0,0,45,2);
		WRTH I 0 A_CustomMissile("RS_DKFire2",0,0,90,2);
		WRTH I 0 A_CustomMissile("RS_DKFire2",0,0,135,2);
		WRTH I 0 A_CustomMissile("RS_DKFire2",0,0,180,2);
		WRTH J 0 A_CustomMissile("RS_DKFire2",0,0,225,2);
		WRTH J 0 A_CustomMissile("RS_DKFire2",0,0,270,2);
		WRTH J 0 A_CustomMissile("RS_DKFire2",0,0,315,2);
		WRTH J 0 A_CustomMissile("RS_DKFire2",0,0,0,2);
		WRTH IF 5;
		Goto See;
	Seekers:
		WRTH F 6 A_FaceTarget;
		WRTH G 6 Bright;
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRev",32,0,random(-19,-9));
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRev",32,0,random(9,19));
		WRTH F 6 A_FaceTarget;
		WRTH G 6 Bright;
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRev",32,0,random(-19,-9));
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRev",32,0,random(9,19));
		WRTH F 6 A_FaceTarget;
		WRTH G 6 Bright;
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRev",32,0,random(-19,-9));
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRev",32,0,random(9,19));
		WRTH F 2 Bright A_MonsterRefire(64,"See");
		Goto Seekers;
	Pain:
		WRTH E 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WRTH E 3 A_Pain;
		WRTH F 6 A_Jump(128,"AoE");
		Goto See;
	Death:
		WRTH I 8;
		WRTH J 8 A_Scream;
		WRTH KL 8;
		WRTH M 8 A_NoBlocking;
		WRTH NOPQ 6;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,vel.x,vel.y,vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,232);
		WRTH R -1 A_SetFloorClip;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- The Black Knight EX, phase 1.  CH: Revenants.txt:3667.
// ---------------------------------------------------------------------------
class RS_BlackRevenantEX : Actor   // CH Revenants.txt:3667
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 7500;
		Radius 20;
		Height 56;
		Mass 3000;
		Speed 14;
		PainChance 32;
		MeleeRange 92;
		Scale 1.2;
		Species "MontyP";
		RadiusDamageFactor 0.33;
		DamageFactor "Fire", 1.8;
		DamageFactor "Poison", 0.25;
		DamageFactor "Ice", 0.6;
		DamageFactor "Heroic", 3.0;
		DamageFactor "PlayerVoid", 0.6;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Monster;
		+FLOORCLIP
		+NOTARGET
		+BOSS
		+DONTMORPH
		-NORADIUSDMG
		+MISSILEMORE
		+NOFEAR
		+NOICEDEATH
		+THRUSPECIES
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		Obituary "None shall pass, %o ";
		HitObituary "oh c'mon now, %o , its just a flesh wound";
		MeleeSound "monster/dknhit";
		SeeSound "BK/Pass";
		PainSound "monster/dknpai";
		DeathSound "monster/dkdie";   // PROVEN MISSING IN CH -- silent there too
		ActiveSound "monster/dknact";
		Translation "160:167=102:111","208:223=240:247","229:231=207:207","144:151=102:111","69:79=5:8","128:133=96:102";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Berserk";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
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
		Tag "The Black Knight unleashed";
	}
	States
	{
	Spawn:
		DKNT A 1;
		Goto Scripted;
	Scripted:
		DKNT A 1;   // CH: DNKT -- CH typo; DKNT is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		// CH: DNKT A 1 ACS_NamedExecuteAlways("AnnounceBlackRev") -- ACS announcer stripped.
		DKNT A 1;   // CH: DNKT -- CH typo; DKNT is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		DKNT A 1 A_Log("A chill runs down your spine");   // CH: DNKT -- CH typo; DKNT is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Idle;
	Idle:
		DKNT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		DKNT AA 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevShade",-2,0,12,1,0,-0.5,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DKNT BB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevShade",-2,0,12,1,0,-0.5,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DKNT CC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevShade",-2,0,12,0,0,-0.5,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DKNT DD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevShade",-2,0,12,1,0,-0.5,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	ShieldSee:
		TNT1 A 0 A_SpawnItemEx("RS_RevShieldWalk2",0,4,64,0,0,0,0,SXF_SETTARGET);
		TNT1 A 0 A_SpawnItemEx("RS_RevShieldWalk",0,4,64,0,0,0,0,SXF_SETMASTER);
		DKNT PPQQRRSS 3 A_Chase;
		Goto See;
	Melee:
		DKNT E 3 A_FaceTarget;
		DKNT F 1 A_PlaySound("monster/dknswg");
		DKNT F 4 A_FaceTarget;
		DKNT G 4 A_CustomMeleeAttack(random(50,140));
		TNT1 A 0 A_PlaySound("BKFuKINV",0,4);
		DKNT G 4;
		DKNT U 0 A_Jump(128,"Grap2");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT A 0 A_PlaySound("BK/invi",0,4);
		TNT1 A 0 A_JumpIfCloser(1000,"Choice2");
		DKNT A 0 A_Jump(255,"DartCleave","ShieldBlast","Dash");
		Goto See;
	Choice2:
		DKNT A 0 A_Jump(255,"DartCleave","Mines","Dash","Grap");
		Goto See;
	ShieldBlast:
		DKNT P 10 Bright A_FaceTarget;
		DKNT T 10 Bright A_FaceTarget;
		DKNT U 2 Bright;
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_ShieldBombRev",random(32,56),0,random(-7,7),0);
		DKNT UUUUUUUU 1 A_CustomMissile("RS_ShieldBombRev",random(32,56),0,random(-7,7),0);
		TNT1 AAAAAAAA 0 A_CustomMissile("RS_ShieldBombRev",random(32,56),0,random(-7,7),0);
		DKNT UUUUUUUU 1 A_CustomMissile("RS_ShieldBombRev",random(32,56),0,random(-7,7),0);
		DKNT U 8 Bright A_CustomMissile("RS_ShieldBlastRev",44,0,0,0);
		Goto See;
	Grap:
		DKNT PTU 3 Bright A_FaceTarget;
		DKNT U 3 Bright A_CustomMissile("RS_BlackRevHook",44,0,0,0);
		DKNT T 3;
		DKNT P 2;
		Goto See;
	Grap2:
		DKNT PTU 3 Bright A_FaceTarget;
		DKNT U 3 Bright A_CustomMissile("RS_BlackRevHook",44,0,random(-13,13),0);
		DKNT T 3;
		DKNT P 2;
		Goto See;
	DartCleave:
		DKNT E 9 Bright A_FaceTarget;
		DKNT F 8 Bright A_PlaySound("monster/kntswg");
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(-6,-2),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(-3,-1),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(-12,-7),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(-18,9),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,0,0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(9,18),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(7,12),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(1,3),0);
		DKNT G 0 A_CustomMissile("RS_DKDart",32,0,random(2,6),0);
		DKNT G 5 Bright;
		TNT1 A 0 A_PlaySound("BKFuKINV",0,4);
		Goto See;
	Mines:
		DKNT T 8 Bright A_FaceTarget;
		DKNT U 2 Bright A_FaceTarget;
		DKNT U 0 A_CustomMissile("RS_MinesRev",44,-4,-12,0);
		DKNT U 0 A_CustomMissile("RS_MinesRev",44,-4,-24,0);
		DKNT U 0 A_CustomMissile("RS_MinesRev",44,-4,24,0);
		DKNT U 6 Bright A_CustomMissile("RS_MinesRev",44,-4,12,0);
		DKNT U 0 A_UnSetReflectiveInvulnerable;
		DKNT U 0 A_Jump(64,"Mines");
		DKNT U 0 A_Jump(106,"Grap2");
		Goto See;
	Dash:
		DKNT E 8 Bright A_UnSetReflectiveInvulnerable;
		DKNT FFFFF 8 Bright A_SkullAttack(42);
		DKNT G 4 Bright A_Stop;
		DKNT U 0 A_Jump(64,"Grap","Grap2");
		TNT1 A 0 A_PlaySound("BKFuKINV",0,4);
		Goto Melee;
	Shield:
		TNT1 A 0 { bNOPAIN = true; }    // CH: a_changeflag(NOPAIN,TRUE)
		TNT1 A 0 A_SpawnItemEx("RS_RevShieldWalk",0,4,64,0,0,0,0,SXF_SETMASTER);
		DKNT P 50;
		DKNT T 10 Bright A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT U 10 Bright A_CustomMissile("RS_ShieldBlastRev",44,0,0,0);
		DKNT UUU 9 Bright A_SpawnItemEx("RS_RevShieldWalk2",0,4,64,0,0,0,0,SXF_SETTARGET);
		TNT1 A 0 { bNOPAIN = false; }   // CH: a_changeflag(NOPAIN,FALSE)
		TNT1 A 0 A_PlaySound("BKFuKINV",0,4);
		Goto See;
	Pain:
		DKNT H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DKNT H 2 A_Pain;
		DKNT P 0 A_Jump(178,"Shield");
		Goto See;
	Pain.Ice:
		DKNT H 1;
		DKNT H 1 A_PlaySound("ResistCH",7);
		DKNT PT 1;
		Goto ShieldSee;
	Pain.Fire:
		DKNT H 1;
		DKNT H 2 A_Pain;
		DKNT H 2 A_Pain;
		DKNT P 1;
		Goto ShieldSee;
	Death:
		DKNT I 12 Bright A_KillChildren("extreme",KILS_FOILINVUL);
		DKNT I 0 A_CustomMissile("RS_DKSword",44,32,-90,0);
		DKNT I 8 Bright A_CustomMissile("RS_DKShield",44,-32,90,0);
		DKNT J 8 Bright;
		DKNT J 8 Bright A_Scream;
		DKNT J 8 Bright A_NoBlocking;
		DKNT K 8 Bright A_SpawnItemEx("RS_BlackRevEx2",0,0,32,0,0,0,0,SXF_NOCHECKPOSITION);
		DKNT L 8 Bright;
		DKNT MN 8 Bright;
		DKNT O 240;
		DKNT OOOO 10 A_SpawnItemEx("RS_BlackRevShade",0,0,12,0,0,0,0,SXF_NOCHECKPOSITION);
		DKNT O 1 A_SpawnItemEx("RS_BlackRevEx3",0,0,12,0,0,0,0,SXF_NOCHECKPOSITION);
		DKNT O -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- The Black Knight's shadow.  CH: Revenants.txt:4221.
// ---------------------------------------------------------------------------
class RS_BlackRevEx3 : Actor   // CH Revenants.txt:4221
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 20000;
		Radius 20;
		Height 56;
		Mass 700;
		Speed 5;
		PainChance 12;
		MeleeRange 92;
		Species "MontyP";
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		RenderStyle "Stencil";
		StencilColor "black";
		Monster;
		+FLOORCLIP
		+NOTARGET
		+BOSS
		-NORADIUSDMG
		+MISSILEMORE
		+NOCLIP
		+DONTMORPH
		+NOFEAR
		+NOBLOOD
		+NOINFIGHTING
		+NOICEDEATH
		+THRUSPECIES
		+DONTBLAST
		+NODAMAGETHRUST
		HitObituary "%o found shade of past that snuck on them";
		MeleeSound "monster/dknhit";
		Tag "The Black Knight's shadow";
	}
	States
	{
	Spawn:
		DKNT ONMLKJI 6;
		DKNT A 1;
	See:
		DKNT AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfInventory("RS_PowerRevEx",1,"Death");
		TNT1 A 0 A_CheckProximity("Death","RS_BlackRevEx2",9999,0,CPXF_NOZ|CPXF_EXACT);
		DKNT CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfInventory("RS_PowerRevEx",1,"Death");
		TNT1 A 0 A_CheckProximity("Death","RS_BlackRevEx2",9999,0,CPXF_NOZ|CPXF_EXACT);
		Loop;
	Melee:
		DKNT E 6 A_FaceTarget;
		DKNT F 1 A_PlaySound("monster/dknswg");
		DKNT F 6 A_FaceTarget;
		DKNT G 6 A_CustomMeleeAttack(random(20,120));
		Goto See;
	Pain:
		DKNT H 2;
		DKNT H 2 A_Pain;
		Goto See;
	Death:
		DKNT I 12 Bright;
		DKNT I 0;
		DKNT I 8 Bright;
		DKNT J 8 Bright;
		DKNT J 8 Bright;
		DKNT J 8 Bright A_NoBlocking;
		DKNT K 8 Bright;
		DKNT L 8 Bright;
		DKNT MN 8 Bright;
		DKNT OOO 10 A_FadeOut(0.33);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 10 -- The Black Knight EX, phase 2 ("Just a shade wound").
// CH: Revenants.txt:4293.
// ---------------------------------------------------------------------------
class RS_BlackRevEx2 : Actor   // CH Revenants.txt:4293
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	Default
	{
		Health 6666;
		BloodColor "black";
		Radius 24;
		Height 56;
		Mass 400;
		Speed 18;
		RadiusDamageFactor 0.33;
		DamageFactor "Fire", 0.95;
		DamageFactor "Melee", 0.33;
		DamageFactor "Plasma", 2.0;
		DamageFactor "Poison", 0.25;
		DamageFactor "DIMp", 0;
		DamageFactor "Heroic", 3.0;
		DamageFactor "PlayerVoid", 0.6;
		PainChance "DIMp", 0;
		FloatSpeed 20;
		PainChance 12;
		Monster;
		+FLOAT
		+NOGRAVITY
		+NOTARGET
		+BOSS
		+DONTBLAST
		+DONTTHRUST
		+DONTMORPH
		-NORADIUSDMG
		+MISSILEMORE
		+NOICEDEATH
		+MISSILEEVENMORE
		+NOFEAR
		+NOCLIP
		+NODAMAGETHRUST
		SeeSound "BK/Phase2";
		PainSound "monster/dknpai";
		DeathSound "BK/Die";
		ActiveSound "monster/dknact";
		Obituary "%o found out black revenant ex is very persistant";
		// CH: // Renderstyle Stencil / // Stencilcolor "black" -- commented out in CH too.
		Translation "0:255=%[0.00,0.00,0.00]:[0.43,0.43,0.43]";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_BlueArmor";
		// CH: Dropitem "RLDemonicWeaponSpawner",12 -- DRLA cross-mod drop, stripped.
		Tag "Just a shade wound";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 1 A_SpawnItemEx("RS_BRevEye",0,4,64,0,0,0,0,SXF_SETMASTER);
		TNT1 A 1 A_SpawnItemEx("RS_BRevEye2",0,4,64,0,0,0,0,SXF_SETMASTER);
	Idle:
		WRTH AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WRTH A 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevShade2",-1,0,12,-1,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WRTH B 2 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_BlackRevShade2",-1,0,12,-1,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		WRTH E 5 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WRTH E 0 A_Jump(255,"Seekers","AoE","Shots");
	Shots:
		WRTH F 5 A_FaceTarget;
		WRTH G 5 Bright;
		WRTH G 0 A_CustomMissile("RS_RevSolex",32,5,random(-9,1));
		WRTH G 0 A_CustomMissile("RS_RevSolex",32,0,random(-1,2));
		WRTH G 0 A_CustomMissile("RS_RevSolex",32,-5,random(-1,9));
		WRTH G 0 A_CustomMissile("RS_RevSolex",32,0,random(-2,1));
		Goto See;
	AoE:
		WRTH FG 5 A_FaceTarget;
		WRTH IJ 5 Bright A_PlaySound("Spell/SpellCast1",0,3);
		WRTH IIIIIJJJJJ 1 A_SpawnItemEx("RS_RainFireRevEX",random(-528,528),random(-528,528),random(-64,64),random(-5,5),0,random(-5,5),random(-359,359),SXF_NOCHECKPOSITION);
		WRTH IF 5;
		Goto See;
	Seekers:
		WRTH F 6 A_FaceTarget;
		WRTH G 6 Bright;
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRevex",32,0,random(-19,-9));
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRevex",32,0,random(9,19));
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRevex",32,32,random(-45,-30));
		WRTH G 0 A_CustomMissile("RS_SoulSeekerRevex",32,-32,random(30,45));
		WRTH F 2 Bright A_MonsterRefire(64,"See");
		Goto Seekers;
	Pain:
		WRTH E 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_RadiusGive("RS_PowerRevEx2",2800,RGF_MONSTERS|RGF_NOSIGHT,1,"RS_BlackRevEx3");
		WRTH E 3 A_Pain;
		WRTH F 6 A_Jump(128,"Warp");
		Goto See;
	Warp:
		WRTH E 0 { bNOPAIN = true; }    // CH: A_changeflag("NOPAIN",true)
		WRTH E 1 A_SetSpeed(99);
		WRTH EEE 0 A_Wander;
		WRTH AAAAAA 1 A_Wander;
		WRTH EEE 0 A_Wander;
		WRTH E 1 A_SetSpeed(18);
		WRTH E 0 { bNOPAIN = false; }   // CH: A_changeflag("NOPAIN",false)
		Goto See;
	XDeath:
	Death:
		WRTH I 8;
		WRTH J 8 A_Scream;
		WRTH KL 8;
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		TNT1 A 0 A_RadiusGive("RS_PowerRevEx",9999,RGF_MONSTERS|RGF_NOSIGHT,1,"RS_BlackRevEx3");
		WRTH M 8 A_NoBlocking;
		WRTH NOPQ 6;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,vel.x,vel.y,vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,232);
		WRTH R -1 A_SetFloorClip;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tier 11 -- The Lich ("Lichest Lich").  CH: Revenants.txt:4476.
// CH defines Pain: TWICE in this one States block (Revenants.txt:4703 and
// :4725) with byte-identical bodies. The first is the one that binds; the
// second is kept below verbatim under PainDup:, unreachable exactly as in
// CH, because ZScript rejects a duplicate state label outright.
// RS_FrostWingBaron2 is EXPECTED FROM THE BARONS LANE (CH Barons.txt:850).
// ---------------------------------------------------------------------------
class RS_WhiteRevenant2 : Actor   // CH Revenants.txt:4476
{
	int user_enrage;   // CH: var int user_enrage;
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 8866;
		BloodColor "white";
		Radius 24;
		Height 56;
		Mass 400;
		Speed 23;
		RadiusDamageFactor 0.5;
		DamageFactor "Fire", 0.9;
		DamageFactor "Melee", 0.9;
		DamageFactor "PLWater", 0.75;
		DamageFactor "Poison", 0.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Heroic", 3.0;
		DamageFactor "PlayerVoid", 0.65;
		PainChance "DIMp", 0;
		FloatSpeed 23;
		PainChance 255;
		PainThreshold 34;
		Monster;
		-FLOAT
		-NOGRAVITY
		+NOTARGET
		+NOINFIGHTING
		+BOSS
		+DONTBLAST
		+DONTMORPH
		-NORADIUSDMG
		+MISSILEMORE
		+NOICEDEATH
		+NOFEAR
		+NODAMAGETHRUST
		SeeSound "LICHVOID";
		PainSound "monster/dknpai";
		DeathSound "LICHDEAD";
		ActiveSound "LICHLMAO";
		Obituary "%o is now a cold servant of the lich";
		// CH: // Renderstyle Stencil / // Stencilcolor "black" -- commented out in CH too.
		Scale 0.65;
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_SoulSphere";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_BlueArmor";
		// CH: Dropitem "RLDemonicWeaponSpawner",24 -- DRLA cross-mod drop, stripped.
		Tag "Lichest Lich";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Scripted:
		// CH: TNT1 A 0 ACS_NamedExecuteAlways("AnnounceWhiteRev") -- ACS announcer stripped.
		TNT1 A 0;
	Idle:
		REVW ABCD 5 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		REVW AB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev2",random(-1,2),random(-6,6),3,random(3,11),0,random(0,2),randompick(45,90,225,270,180,0),SXF_NOCHECKPOSITION);
		REVW CD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev2",random(1,2),random(-6,6),3,random(3,11),0,random(0,2),randompick(45,90,225,270,180,0),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(4500,"Enrage");
		TNT1 A 0 A_GiveInventory("RS_WhiteRevProtect",1);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev",random(1,2),0,46,random(1,2),0,2,0,SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_PlaySound("Lich/Cast",0);
		REVW E 5 Bright A_FaceTarget;
		REVW E 0 A_JumpIfCloser(1500,"CloseChoice");
		WRTH E 0 A_Jump(255,"IceBolt","DeathCoil");
		Goto See;
	DeathCoil:
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_Splash11",2,24,66,random(3,9),0,random(2,9),random(0,359));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_Splash11",2,-24,66,random(3,9),0,random(2,9),random(0,359));
		REVW FGHI 6 Bright A_FaceTarget;
		TNT1 AAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_Splash11",12,0,42,random(2,7),0,random(2,6),random(-12,12));
		REVW I 4 Bright A_CustomMissile("RS_WhiteRevCoil",random(28,40),random(-7,7),random(-11,1),0,random(-2,2));
		REVW I 4 Bright A_CustomMissile("RS_WhiteRevCoil2",random(28,40),random(-7,7),random(-1,1));
		REVW I 4 Bright A_CustomMissile("RS_WhiteRevCoil3",random(28,40),random(-7,7),random(-1,11),0,random(-2,2));
		TNT1 A 0 A_JumpIfHealthLower(4500,"MoreCoil");
		REVW GF 3;
		Goto See;
	MoreCoil:
		REVW I 4 Bright A_CustomMissile("RS_WhiteRevCoil4",32,0,random(-1,1));
		REVW GF 3;
		Goto See;
	IceBolt:
		REVW FGH 4 Bright A_FaceTarget;
		REVW I 4 A_CustomMissile("RS_CyanCybieGunFlare",32,0,0);
		REVW I 6 Bright A_CustomMissile("RS_WhiteRevFrostBolt",32,0,0);
		REVW GF 3;
		Goto See;
	Missile2:
		TNT1 A 0 A_GiveInventory("RS_WhiteRevProtect",1);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev",random(1,2),0,46,random(1,2),0,2,0,SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_PlaySound("Lich/Cast",0);
		REVW E 5 Bright A_FaceTarget;
		REVW E 0 A_JumpIfCloser(1500,"CloseChoice2");
		WRTH E 0 A_Jump(255,"IceBolt","DeathCoil");
		Goto See;
	IceBreath:
		REVW FGHI 4 Bright A_FaceTarget;
		TNT1 A 0 A_JumpIfHealthLower(6200,"BiggerBreath");
		REVW I 6 Bright A_CustomMissile("RS_IceToMeetWhiteRev",32,0,0);
		TNT1 A 0 A_JumpIfHealthLower(6200,"BiggerBreath");
		REVW GF 3;
		Goto See;
	BiggerBreath:
		REVW I 0 A_CustomMissile("RS_IceToMeetWhiteRev",32,0,5);
		REVW I 0 A_CustomMissile("RS_IceToMeetWhiteRev",32,0,-5);
		REVW I 6 Bright A_CustomMissile("RS_IceToMeetWhiteRev",32,0,0);
		REVW GF 3;
		Goto See;
	SummonHelp:
		REVW J 1 Bright;
		TNT1 A 0 A_CustomMissile("RS_RedRevLoad",72,23,0);
		TNT1 A 0 A_CustomMissile("RS_RedRevLoad",72,-23,0);
		REVW J 5 Bright;
		REVW L 3 Bright { bNOPAIN = false; }   // CH: A_changeflag("NOPAIN",false)
		REVW K 3 Bright;
		REVW JKL 8 Bright A_FaceTarget;
		REVW J 5 Bright A_FaceTarget;
		REVW K 3 Bright ThrustThingZ(0,12,0,0);
		TNT1 A 0 A_GiveInventory("RS_WhiteRevProtect",1);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev",random(1,2),0,46,random(1,2),0,2,0,SXF_NOCHECKPOSITION,128);
		REVW JKL 8 Bright A_FaceTarget;
		REVW JKL 8 Bright A_FaceTarget;
		REVW JKL 8 Bright A_SpawnItemEx("RS_MrBones",randompick(-64,64,32,-32),randompick(-128,64,-64,128),32,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 0 A_GiveInventory("RS_WhiteRevProtect",1);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev",random(1,2),0,46,random(1,2),0,2,0,SXF_NOCHECKPOSITION,128);
		REVW JKL 8 Bright A_FaceTarget;
		REVW JKL 8 Bright A_FaceTarget;
		REVW JKL 8 Bright A_FaceTarget;
		TNT1 A 0 A_GiveInventory("RS_WhiteRevProtect",1);
		TNT1 A 0 A_SpawnItemEx("RS_EvilShadeWhiteRev",random(1,2),0,46,random(1,2),0,2,0,SXF_NOCHECKPOSITION,128);
		REVW L 3 Bright { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",TRUE)
		REVW FGHI 2 Bright;
		REVW III 2 Bright A_SpawnItemEx("RS_PortalSummons",randompick(-64,64,32,-32),randompick(-128,64,-64,128),32,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		REVW I 12 Bright A_FaceTarget;
		Goto See;
	CloseChoice2:
		WRTH E 0 A_Jump(255,"GroundPainex","SummonHelp","DeathCoil","IceBolt");
		Goto See;
	CloseChoice:
		WRTH E 0 A_Jump(255,"GroundPain","FrostMines","IceBreath","DeathCoil","IceBolt");
		Goto See;
	Nah:
		TNT1 A 0;
		Goto Missile2;
	FrostMines:
		REVW J 5 Bright;
		TNT1 AAAAA 0 A_SpawnItemEx("RS_FrostWingBaron2",2,24,74,random(2,12),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_FrostWingBaron2",2,-24,74,random(2,12),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		REVW L 3 Bright { bNOPAIN = false; }   // CH: A_changeflag("NOPAIN",false)
		REVW K 3 Bright;
		TNT1 AAAAA 0 A_SpawnItemEx("RS_FrostWingBaron2",2,24,74,random(2,12),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_FrostWingBaron2",2,-24,74,random(2,12),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		REVW JKL 5 Bright A_FaceTarget;
	FrostMines2:
		REVW J 5 Bright A_FaceTarget;
		REVW KK 2 Bright A_SpawnItemEx("RS_IceGroundWhiteRev",random(24,1028),random(-128,128),12,0,0,0,0,SXF_NOCHECKPOSITION);
		REVW L 2 Bright A_FaceTarget;
		REVW LL 2 Bright A_SpawnItemEx("RS_IceGroundWhiteRev",random(128,1028),random(-528,528),12,0,0,0,0,SXF_NOCHECKPOSITION);
		REVW E 0 A_CheckSight("FrostMinesStop");
		REVW E 0 A_Jump(24,"FrostMinesStop");
		REVW E 0 A_JumpIfCloser(1500,"FrostMines2");
		Goto GroundStop;
	FrostMinesStop:
		REVW E 2;
		WRTH E 0 { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",true)
		REVW E 2 A_Jump(32,"IceBolt");
		Goto See;
	Enrage:
		TNT1 A 0 A_JumpIf(user_enrage == 1,"Nah");
		TNT1 A 0 A_PlaySound("deepone/death",7,2,false,ATTN_NONE);
		REVW E 5 Bright A_FaceTarget;
		REVW J 3 Bright { bFLOAT = true; }       // CH: A_changeflag("FLOAT",TRUE)
		REVW K 3 Bright { bNOGRAVITY = true; }   // CH: A_changeflag("NOGRAVITY",TRUE)
		REVW L 3 Bright { user_enrage = 1; }     // CH: a_setuservar("User_Enrage",user_enrage = 1)
		REVW L 1 A_SetTranslucent(0.80);
		REVW L 1 A_SetTranslucent(0.60);
		REVW L 1 A_SetTranslucent(0.40);
		REVW L 1 A_SetTranslucent(0.20);
		REVW L 1 A_SetSpeed(99);
		REVW LLL 2 A_Wander;
		REVW LLLL 1 A_Wander;
		REVW LL 2 A_Wander;
		REVW L 1 A_SetSpeed(23);
		REVW L 1 A_SetTranslucent(0.40);
		REVW L 1 A_SetTranslucent(0.60);
		REVW L 1 A_SetTranslucent(0.80);
		REVW L 1 A_SetTranslucent(1.0);
		Goto See;
	GroundPainex:
		REVW J 5 Bright;
		REVW L 3 Bright { bNOPAIN = false; }   // CH: A_changeflag("NOPAIN",false)
		REVW K 3 Bright A_VileTarget("RS_DarkChannelWhiteRev");
		REVW JKL 7 Bright A_FaceTarget;
		REVW JKL 3 Bright A_FaceTarget;
	GroundPainex2:
		REVW J 5 Bright A_FaceTarget;
		REVW KK 2 Bright A_SpawnItemEx("RS_IceGroundWhiteRev",random(24,1028),random(-128,128),12,0,0,0,0,SXF_NOCHECKPOSITION);
		REVW L 2 Bright A_FaceTarget;
		REVW LL 2 Bright A_SpawnItemEx("RS_IceGroundWhiteRev",random(128,1028),random(-528,528),12,0,0,0,0,SXF_NOCHECKPOSITION);
		REVW E 0 A_CheckSight("GroundStopex");
		REVW E 0 A_Jump(24,"GroundStopex");
		REVW E 0 A_JumpIfCloser(1500,"GroundPainex2");
		Goto GroundStopex;
	GroundStopex:
		REVW E 2;
		WRTH E 0 { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",true)
		REVW E 2 A_RadiusGive("RS_ByeWhiteRevCast",9999,RGF_MISSILES|RGF_NOSIGHT,1);
		Goto See;
	Pain:
		REVW M 3;
		REVW M 3 A_Pain;
		REVW M 3 A_Jump(255,"Warp");
		Goto See;
	GroundPain:
		REVW J 5 Bright;
		REVW L 3 Bright { bNOPAIN = false; }   // CH: A_changeflag("NOPAIN",false)
		REVW K 3 Bright A_VileTarget("RS_DarkChannelWhiteRev");
		REVW JKL 8 Bright A_FaceTarget;
		REVW JKL 5 Bright A_FaceTarget;
	GroundPain2:
		REVW JKL 5 Bright A_FaceTarget;
		REVW E 0 A_CheckSight("GroundStop");
		REVW E 0 A_Jump(12,"GroundStop");
		REVW E 0 A_JumpIfCloser(1500,"GroundPain2");
		Goto GroundStop;
	GroundStop:
		REVW E 2;
		WRTH E 0 { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",true)
		REVW E 2 A_RadiusGive("RS_ByeWhiteRevCast",9999,RGF_MISSILES|RGF_NOSIGHT,1);
		Goto See;
	PainDup:
		// CH: Pain: (Revenants.txt:4725) -- CH declares Pain a SECOND time in
		// this same States block, byte-identical to :4703. The first binding
		// wins, so this run is dead in CH too; ZScript rejects the duplicate
		// label outright, so it is kept verbatim under a unique name.
		REVW M 3;
		REVW M 3 A_Pain;
		REVW M 3 A_Jump(255,"Warp");
		Goto See;
	Warp:
		REVW M 1 A_SetTranslucent(0.80);
		REVW M 1 A_SetTranslucent(0.60);
		REVW M 1 A_SetTranslucent(0.40);
		REVW M 1 A_SetTranslucent(0.20);
		WRTH M 10 { bNOPAIN = true; }   // CH: A_changeflag("NOPAIN",true)
		TNT1 A 0 A_RadiusGive("RS_ByeWhiteRevCast",9999,RGF_MISSILES|RGF_NOSIGHT,1);
		REVW M 1 A_SetSpeed(99);
		REVW MMM 2 A_Wander;
		REVW MMMMMM 1 A_Wander;
		REVW MMMM 2 A_Wander;
		REVW M 1 A_SetTranslucent(0.40);
		REVW M 1 A_SetTranslucent(0.60);
		REVW M 1 A_SetTranslucent(0.80);
		REVW M 1 A_SetTranslucent(1.0);
		REVW M 1 A_SetSpeed(23);
		REVW M 20;
		Goto See;
	XDeath:
	Death:
		TNT1 A 0 A_RadiusGive("RS_ByeWhiteRevCast",9999,RGF_MISSILES|RGF_NOSIGHT,1);
		REVW MMMMMM 2 A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		REVW M 3 A_Scream;
		REVW MMMMMMMMMM 1 A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		REVW M 3 A_NoBlocking;
		REVW M 3 A_SetFloorClip;
		REVW MMMM 3 A_FadeOut(0.25);
		Stop;
	}
}
