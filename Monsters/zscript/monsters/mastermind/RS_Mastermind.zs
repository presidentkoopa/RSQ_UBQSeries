// ============================================================================
// RS_Mastermind.zs -- Colourful Hell Spider Mastermind family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\MASTERMINDS.txt (5,274 lines,
// read whole; 108 actors). Every actor cites its CH line. Support, projectiles
// and the two native ACS rebuilds live in RS_MastermindFX.zs -- see its header
// for cross-lane ownership, already-owned skips, proven-missing assets and the
// standing strips.
//
// SEVENTEENTH AND FINAL CH FAMILY. With this in, the import is complete.
//
// Tier ladder is CH's own icon index: 1 Common, 2 Green, 3 Blue, 4 Purple,
// 5 Yellow, 6 Red, 7 FireBlu, 8 Gray, 9 Abyss, 10 Black, 11 White, 12 Cyan,
// 13 Brown. RS_SpecialSpider1 (purple's babies), RS_MiniSentinelSpider
// (white's drones) and RS_RedMindBomb (red's floating mine) are summons and
// get NO tier token. RS_CH_OrbOfChaos is CH's own "// UNUSED" actor -- kept
// verbatim, unreferenced, no token.
//
// NOTE ON STATE ORDER: this family leans hard on numeric state offsets
// (Goto See+3, Goto Missile+1, Goto Missile+4, Goto Missile+7,
// Goto Psyche2+3, Goto HitScan+2, Goto Chaingunlasers+1, ...). Blackmind2's
// "Goto Missile+7" in particular walks PAST its own Goto into the states
// physically following it (Choose:, then Miss2:). Every state line below is
// transcribed 1:1 in CH's order, with no insertions or removals, so those
// offsets land where CH put them. Do not "tidy" a line out of this file.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial. CH: MASTERMINDS.txt:1 -- Colourset17 replaces
// SpiderMastermind.
// ---------------------------------------------------------------------------
class RS_Colourset17 : RandomSpawner replaces SpiderMastermind
{
	Default
	{
		DropItem "RS_CommonMind", 255, 409;
		DropItem "RS_GreenMind", 255, 260;
		DropItem "RS_CyanMind", 255, 80;
		DropItem "RS_BlueMind", 255, 160;
		DropItem "RS_PurpleMind", 255, 83;
		DropItem "RS_YellowMind", 255, 40;
		DropItem "RS_GrayMind", 255, 35;
		DropItem "RS_BrownMind", 255, 35;
		DropItem "RS_FireBluMind", 255, 28;
		DropItem "RS_RedMind", 255, 10;
		DropItem "RS_AbyssMind", 255, 10;
		DropItem "RS_BlackMind", 255, 4;
		DropItem "RS_WhiteMind", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs. CH semantics: 1 = colour off (reroll into the main set,
// CH's default), 3 = fifty-fifty, anything else = the colour spawns.
//
// Unlike the revenant/imp stubs, this family's stubs are PERSISTENT MASTERS:
// they keep +INVULNERABLE/+NOINTERACTION and loop on a 3-tic state, and the
// spawned body calls A_KillMaster in its Death. That is why the spawn carries
// SXF_SETMASTER and why the stub has its own Death: a_bossdeath. Kept exactly.
//
// The two black/white bosses invert the test: gate == 1 means the boss DOES
// spawn, otherwise it downgrades (white -> black, black -> red). CH's own
// wiring, not a transcription slip.
// ---------------------------------------------------------------------------
class RS_BrownMind : Actor   // CH MASTERMINDS.txt:18 -- gate CH_Brown
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset17",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath();
		Stop;
	}
}

class RS_CyanMind : Actor   // CH MASTERMINDS.txt:752 -- gate CH_Cyan
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset17",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath();
		Stop;
	}
}

class RS_AbyssMind : Actor   // CH MASTERMINDS.txt:1090 -- gate CH_Abyssmal
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
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
		TNT1 A 0 A_SpawnItemEx("RS_Colourset17",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath();
		Stop;
	}
}

class RS_FireBluMind : Actor   // CH MASTERMINDS.txt:1671 -- gate CH_FireBLUES
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_fireblu', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_Colourset17",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath();
		Stop;
	}
}

class RS_GrayMind : Actor   // CH MASTERMINDS.txt:1765 -- gate CH_Grayscale
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_gray', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_Colourset17",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GrayMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// Inverted gate: 1 = the black boss DOES spawn; anything else downgrades to
// red. CH MASTERMINDS.txt:3821.
class RS_BlackMind : Actor   // CH MASTERMINDS.txt:3790 -- gate CH_BlackBossy
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_blackboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_BlackMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedMind",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath();
		Stop;
	}
}

// Inverted gate: 1 = the white boss DOES spawn; anything else downgrades to
// the black stub. CH MASTERMINDS.txt:4459.
class RS_WhiteMind : Actor   // CH MASTERMINDS.txt:4428 -- gate CH_WhiteBossy
{
	Default
	{
		+BOSSDEATH
		+INVULNERABLE
		-SOLID
		-COUNTKILL
		+NEVERTARGET
		+NOTARGET
		+NOTRIGGER
		+NOCLIP
		+NOTELEPORT
		-ACTIVATEMCROSS
		+THRUACTORS
		+THRUGHOST
		+SPECTRAL
		+CANTSEEK
		+NOTELEOTHER
		+DONTMORPH
		+DONTSQUASH
		+LAXTELEFRAGDMG
		+NOTELEFRAG
		+DONTDRAIN
		+NOTAUTOAIMED
		+NOTONAUTOMAP
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_whiteboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMind2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done:
		TNT1 A 3;
		Loop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackMind",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_SETMASTER|SXF_TRANSFERAMBUSHFLAG);
	Done2:
		TNT1 A 3;
		Loop;
	Death:
		TNT1 A 3 A_BossDeath();
		Stop;
	}
}


// ===========================================================================
// BODIES
// ===========================================================================

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN. CH MASTERMINDS.txt:70.
// ---------------------------------------------------------------------------
class RS_BrownMind2 : Actor   // CH MASTERMINDS.txt:70
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 8858;
		Radius 100;
		Species "MMind";
		BloodColor "red";
		Height 100;
		Mass 1000;
		Speed 16;
		PainChance 64;
		Monster;
		DamageFactor "Fire", 1.20;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.15;
		RadiusDamageFactor 0.5;
		DamageFactor "ice", 0.50;   // CH sets ice twice (:86 then :88); last wins
		DamageFactor "Melee", 1.20;
		PainChance "DIMp", 0;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		+FULLVOLDEATH
		SeeSound "BR0SPIDA";
		AttackSound "";
		PainSound "brownMind/ouch";
		DeathSound "BR0SPDED";
		ActiveSound "brownMind/Angry";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 200;
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_ClipBox", 200;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		DropItem "BackPack", 64;
		DropItem "RS_CH_CellPack", 64;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		Obituary "%o was bonebroken by Brown Mastermind";
		Tag "Death N Decay Master";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Idle:
		B05P AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		B05P A 3 A_PlaySound("brownmind/step");
		B05P ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		B05P C 3;
		B05P CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		B05P E 3 A_PlaySound("brownmind/step");
		B05P EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"See2");
		Loop;
	See2:
		B05P A 1 A_PlaySound("brownmind/step");
		B05P ABB 1 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		B05P C 1;
		B05P CDD 1 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		B05P E 1;
		B05P EFF 1 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(176,"See2");
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		B05P A 3 A_Jump(128,"Checkers");
	BackBack:
		TNT1 A 0 A_JumpIfInTargetLOS("Spiral",0,JLOSF_DEADNOJUMP,850,100);
		B05P A 3 Bright A_FaceTarget();
	Missile2:
		B05P A 3 Bright;
		B05P A 3 Bright A_Jump(96,"GroundBreak");
		B05P G 2 Bright A_FaceTarget();
		B05P G 10 Bright A_FaceTarget();
		B05P HHH 5 Bright A_CustomMissile("RS_BrownOrbMind",42,0,random(-2,2),0,random(-1,1));
		B05P A 0 A_Jump(64,"Boners");
		B05P G 10 Bright A_FaceTarget();
		B05P HHH 5 Bright A_CustomMissile("RS_BrownOrbMind",42,0,random(-2,2),0,random(-1,1));
		B05P G 10 Bright A_FaceTarget();
		B05P HHH 5 Bright A_CustomMissile("RS_BrownOrbMind",42,0,random(-2,2),0,random(-1,1));
		B05P A 0 A_Jump(128,"Boners");
		B05P A 10 Bright A_FaceTarget();
		Goto See;
	Boners:
		B05P G 10 Bright A_FaceTarget();
		B05P H 10 Bright A_CustomMissile("RS_BrownMindBone2",42,0,-2,0,0);
		B05P H 10 Bright A_CustomMissile("RS_BrownMindBone2",42,0,0,0,0);
		B05P H 10 Bright A_CustomMissile("RS_BrownMindBone2",42,0,2,0,0);
		B05P A 10 Bright A_FaceTarget();
		Goto See;
	GroundBreak:
		TNT1 A 0 A_PlaySound("ECHOIMPB",0);
		B05P TUV 8 Bright;
		B05P VVV 8 Bright A_VileTarget("RS_MindGroundSpikeBrown");
		B05P VUT 15;
		Goto See;
	Spiral:
		B05P A 3 Bright A_Jump(176,"Missile2");
		B05P A 3 Bright;
		B05P G 7 Bright A_FaceTarget();
		B05P HHHHHHH 0 A_CustomMissile("RS_ZombieRock",random(28,35),random(-5,5),random(-4,4),CMF_OFFSETPITCH,random(-3,5));
		B05P H 1 Bright A_CustomMissile("RS_WindBlastMasterMind",32,0,0);
		B05P H 1 Bright A_CustomMissile("RS_WindBlastMasterMind2",32,0,0);
		B05P H 1 Bright A_CustomMissile("RS_WindBlastMasterMind3",32,0,0);
		B05P HA 8 Bright;
		Goto See;
	Checkers:
		B05P A 1;
		TNT1 A 0 A_CheckProximity("FeelIt2","ChainGunGuy",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt2","DoomImp",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt2","ShotgunGuy",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt2","ZombieMan",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt2","Demon",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt2","Spectre",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt2","HellKnight",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_Jump(128,"BackBack");
		TNT1 A 0 A_CheckProximity("FeelIt","Arachnotron",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","CacoDemon",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","Fatso",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","Revenant",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","PainElemental",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("FeelIt","BaronOfHell",320,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		Goto See;
	FeelIt2:
		TNT1 A 0 A_Jump(128,"BackBack");
		Goto FeelIt;
	YumYum:
		TNT1 A 0 A_CheckFlag("Boss","FeelIt",AAPTR_TARGET);
		B05P A 1 A_RadiusGive("RS_EatableMind",526,RGF_MONSTERS,1);
		TNT1 A 0 A_JumpIfInTargetInventory("RS_EatableMind",1,"Yum2");
		Goto FeelIt;
	Yum2:
		TNT1 A 0 A_JumpIfCloser(256,"Yum3",true);
		Goto FeelIt;
	Yum3:
		TNT1 A 0 { bNOTARGETSWITCH = true; }   // CH: A_changeflag("NOTARGETSWITCH",true)
		TNT1 A 0 { bNOPAIN = true; }           // CH: A_changeflag("NOPAIN",true)
		B05P H 10 Bright A_FaceTarget();
		TNT1 A 0 A_VileTarget("RS_Drt3");
		B05P H 2 Bright A_RadiusThrust(-800,302,RTF_NOTMISSILE,300);
		B05P H 1 A_GiveInventory("RS_BrownWarriorsStrifeFor",1,AAPTR_TARGET);
		TNT1 A 0 A_PlaySound("CUCHUM01",0);
		B05P H 1 Bright A_RadiusThrust(-500,302,RTF_NOTMISSILE,300);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_RedMessMindB",16,random(-12,12),random(38,42),random(6,18),0,random(-1,8),random(-15,15));
		B05P G 10 Bright A_KillTarget("Extreme",KILS_FOILINVUL);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_RedMessMindB",16,random(-12,12),random(38,42),random(6,18),0,random(-1,8),random(-15,15));
		B05P H 10 Bright A_GiveInventory("Health",500);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_RedMessMindB",16,random(-12,12),random(38,42),random(6,18),0,random(-1,8),random(-15,15));
		TNT1 AAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(32,128),random(3,12),0,random(1,15),random(0,359),SXF_NOCHECKPOSITION);
		B05P G 10 Bright A_PlaySound("CUCHUM01",0);
		B05P H 10 Bright;
		B05P G 10 Bright A_PlaySound("CUCHUM01",0);
		TNT1 A 0 { bNOTARGETSWITCH = false; }   // CH: A_changeflag("NOTARGETSWITCH",FALSE)
		TNT1 A 0 { bNOPAIN = false; }           // CH: A_changeflag("NOPAIN",FALSE)
		Goto See;
	FeelIt:
		TNT1 A 0 A_PlaySound("BONEBR3K",0);
		B05P TUV 10 Bright;
		TNT1 A 0 A_PlaySound("BONEBR3K",0);
		TNT1 A 0 A_RadiusGive("RS_ShieldUpMind",732,RGF_MONSTERS,1);
		B05P VUT 10;
		Goto See;
		// CH MASTERMINDS.txt:260-262 -- three states sitting after the Goto,
		// unreachable in CH too. Kept so the state array keeps CH's shape.
		B05P H 2 Bright A_FaceTarget();
		B05P G 1 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-3,3));
		B05P H 1 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-5,5));
	Pain:
		B05P I 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		B05P I 3 A_Pain();
		Goto See2;
	Pain.Ice:
		B05P I 2 A_PlaySound("ResistCH",7);
		B05P I 2 A_Pain();
		Goto See;
	Death:
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		B05P J 20 A_Scream();
		B05P K 10 A_NoBlocking();
		B05P LMNOPQR 10;
		B05P S 30;
		TNT1 AAAAAAAAAAAA 0 A_CustomMissile("RS_CH_BoneGib",0,12,random(-180,180),0,random(0,90));
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		B05P S -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN. CH MASTERMINDS.txt:804.
// ---------------------------------------------------------------------------
class RS_CyanMind2 : Actor   // CH MASTERMINDS.txt:804
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Health 7777;
		Radius 40;
		Height 95;
		Speed 21;
		FloatSpeed 21;
		BloodColor "cyan";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		RadiusDamageFactor 0.5;
		DamageFactor "Melee", 1.75;
		DamageFactor "Fire", 1.75;
		DamageFactor "Ice", 0.35;
		DamageFactor "PLWater", 0.35;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance 10;
		Mass 1000;
		Monster;
		+BOSS
		-NOGRAVITY
		-FLOAT
		-FLOATBOB
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "fiend/see";
		DeathSound "spider/death";
		Obituary "%o had their mind frozen by cyan mastermind";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 32;
		DropItem "BackPack", 64;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_SoulSphere", 32;
		// CH: DropItem "FinallyFullyCovered" (MASTERMINDS.txt:850) -- class
		//     defined NOWHERE in the CH tree. Itemised, not silently gutted.
		DropItem "RS_CH_PlasmaRifle", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		Tag "Cyanide Master(Mind)";
		Translation "48:79=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "128:151=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "0:15=%[0.00,0.00,0.58]:[0.00,0.00,0.72]", "4:4=4:4", "80:95=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "152:159=%[0.00,0.00,2.00]:[1.01,2.00,2.00]", "96:111=%[0.00,0.00,2.00]:[1.01,2.00,2.00]", "48:63=%[0.00,0.00,1.01]:[1.01,2.00,2.00]", "13:15=203:207", "236:239=202:207", "208:223=192:207", "16:31=192:207", "168:191=0:0", "32:47=195:207", "160:167=192:201", "224:231=192:199", "232:235=200:203", "255:255=201:201", "248:249=192:192", "112:127=192:207";
	}
	States
	{
	Spawn:
		SUPS A 2;
		Goto Idle;
	Idle:
		SUPS A 4 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SUPS A 0 { bFLOAT = true; }       // CH: A_Changeflag("FLOAT",TRUE)
		SUPS A 0 { bFLOATBOB = true; }    // CH: A_Changeflag("FLOATBOB",TRUE)
		SUPS A 0 { bNOGRAVITY = true; }   // CH: A_Changeflag("NOGRAVITY",TRUE)
		SUPS A 0 A_PlaySound("ice/cast");
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpidTrail",-4,0,1,random(-1,12),0,random(-1,1),angle+random(-90,90));
		SUPS A 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpidTrail",-4,0,1,random(-1,12),0,random(-1,1),angle+random(-90,90));
		SUPS A 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpidTrail",-4,0,1,random(-1,12),0,random(-1,1),angle+random(-90,90));
		TNT1 A 0 A_Jump(64,"Dodge");
		SUPS A 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpidTrail",-4,0,1,random(-1,12),0,random(-1,1),angle+random(-90,90));
		SUPS A 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(54,"Jumps");
		Loop;
	Dodge:
		SUPS A 0 A_PlaySound("ice/cast");
		SUPS A 3 A_FastChase();
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpidTrail",-4,0,1,random(-1,12),0,random(-1,1),angle+random(-90,90));
		SUPS A 3 A_FastChase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpidTrail",-4,0,1,random(-1,12),0,random(-1,1),angle+random(-90,90));
		Goto See+3;
	Jumps:
		SUPS A 5 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,2,0,0,3,0,SXF_NOCHECKPOSITION);
		SUPS A 1 A_PlaySound("monster/heltel");
		SUPS A 1 A_SetTranslucent(0.90);
		SUPS A 1 A_SetTranslucent(0.80);
		SUPS A 1 A_SetTranslucent(0.70);
		SUPS A 1 A_SetTranslucent(0.60);
		SUPS A 1 A_SetTranslucent(0.50);
		SUPS A 1 A_SetTranslucent(0.40);
		SUPS A 1 A_SetTranslucent(0.30);
		SUPS A 1 A_SetTranslucent(0.20);
		SUPS A 1 A_SetTranslucent(0.10);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Wander();
		SUPS A 1 A_PlaySound("monster/heltel");
		SUPS A 1 A_SetTranslucent(0.10);
		SUPS A 1 A_SetTranslucent(0.20);
		SUPS A 1 A_SetTranslucent(0.30);
		SUPS A 1 A_SetTranslucent(0.40);
		SUPS A 1 A_SetTranslucent(0.50);
		SUPS A 1 A_SetTranslucent(0.60);
		SUPS A 1 A_SetTranslucent(0.70);
		SUPS A 1 A_SetTranslucent(0.80);
		SUPS A 1 A_SetTranslucent(0.90);
		SUPS A 1 A_SetTranslucent(1.0);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPS A 5 A_SpawnItemEx("RS_BaronCyanBombTrail",0,0,2,0,0,3,0,SXF_NOCHECKPOSITION);
		Goto See+3;
	Pain:
		SUPS A 2;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPS A 4 A_Teleport("See","RS_CyanSpidTrail","RS_BaronCyanBombTrail",TF_KEEPVELOCITY);
		Goto See;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPS B 0 A_JumpIfCloser(1500,"FrostMode");
		SUPS B 0 A_Jump(255,"RapidFire");
		Goto See+3;
	RapidFire:
		SUPS B 4 Bright A_FaceTarget();
		SUPS F 2 Bright A_CustomMissile("RS_SpiderCyanBomb",30,0,0);
		SUPS E 2 Bright A_FaceTarget();
		SUPS B 1 Bright A_CheckSight("See");
		SUPS F 2 Bright A_CustomMissile("RS_SpiderCyanBomb",30,0,random(-3,3));
		SUPS E 2 Bright A_FaceTarget();
		SUPS B 1 Bright A_CheckSight("See");
		SUPS F 2 Bright A_CustomMissile("RS_SpiderCyanBomb",30,0,random(-1,1));
		SUPS E 2 Bright A_MonsterRefire(128,"See");
		Goto RapidFire;
	FrostMode:
		TNT1 A 0 A_Jump(64,"RapidFire");
		SUPS B 10 Bright A_FaceTarget();
		TNT1 A 0 A_Jump(72,"Frost2");
		SUPS B 0 A_PlayWeaponSound("fiend/bomb");
		SUPS OPQ 5 Bright A_FaceTarget();
		SUPS QQQQQQQQQQQQQQQQQQQQQQQQ 1 A_CustomMissile("RS_IceOrbCyanMind",30,0,random(-1,1));
		SUPS QPO 5 Bright A_FaceTarget();
		Goto See+3;
	Frost2:
		SUPS B 0 A_PlayWeaponSound("fiend/bomb");
		SUPS OPQ 5 Bright A_FaceTarget();
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,0);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,15);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-15);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-30);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,30);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-45);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,45);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-60);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-60);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-75);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,75);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-45);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,45);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,15);
		SUPS Q 3 A_CustomMissile("RS_IceOrbCyanMind2",30,0,-15);
		SUPS Q 5 Bright A_FaceTarget();
		TNT1 A 0 A_CheckSight("See");
		SUPS QQQQQQQQ 5 A_CustomMissile("RS_IceOrbCyanMind2",30,0,random(-5,5));
		SUPS Q 5 Bright A_FaceTarget();
		TNT1 A 0 A_CheckSight("See");
		SUPS QQQQ 7 A_CustomMissile("RS_IceOrbCyanMind2",30,0,0);
		SUPS QPO 5 Bright A_FaceTarget();
		Goto See+3;
	Death:
		SUPS G 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag(FLOATBOB,0)
		SUPS G 10 A_Scream();
		SUPS H 10;
		SUPS I 10 A_Fall();
		SUPS JKLM 10;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		SUPS N 20 A_BossDeath();
		SUPS N 10 A_SetScale(1.0,0.5);
		SUPS N 10 A_SetScale(1.0,0.25);
		SUPS N 10 A_SetScale(0.66,0.1);
		SUPS N 10 A_SetScale(0.44,0.05);
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,242);
		SUPS N 10 A_SetScale(0.22,0.03);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 9 -- ABYSS. CH MASTERMINDS.txt:1143.
// RESOLVED 2026-08-06 -- the See/See2/See3 "AMIN KLMLK" lines were a slip for
// ANIM and are now ANIM KLMLK. AMIN ships A-I (8-rotation walk); K/L/M ship on
// ANIM (ANIMK0/ANIML0/ANIMM0), the SAME monster's flat-rotation prefix, in the
// same folder (sprites/monsters/Mastermind/T06, CH sprites/abyssmind). CH's own
// MindSpike and MindWave write "ANIM KLMMLK 2 bright" for this identical
// three-frame flash-pulse (MASTERMINDS.txt:1279, :1316) -- K is the neutral
// pose, L and M are brightness ramps of it. Frame letters and tic counts are
// unchanged, so state offsets are untouched. CHP inherits the same typo
// verbatim (DECORATE/16/16_A.txt:38 et al) -- it is upstream, not deliberate.
// ---------------------------------------------------------------------------
class RS_AbyssMind2 : Actor   // CH MASTERMINDS.txt:1143
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 9); }
	Default
	{
		Health 12222;
		Radius 40;
		Height 95;
		Speed 21;
		FloatSpeed 23;
		PainChance 48;
		Mass 1000;
		RadiusDamageFactor 0.5;
		DamageFactor "Plasma", 0.70;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.45;
		DamageFactor "melee", 0.75;
		DamageFactor "PLWater", 0.40;
		DamageFactor "PlayerVoid", 0.40;
		PainChance "DIMp", 0;
		Monster;
		+NOPAIN
		+BOSS
		-NOGRAVITY
		-FLOATBOB
		-FLOAT
		-NORADIUSDMG
		+NOFEAR
		+MISSILEMORE
		+DONTMORPH
		+DONTHARMCLASS
		SeeSound "arachnophyte/sight";
		PainSound "arachnophyte/pain";
		DeathSound "arachnophyte/death";
		Obituary "%o couldn't handle the abyss mastermind";
		RenderStyle "Translucent";
		Alpha 0.85;
		Scale 1.33;
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		DropItem "BackPack", 128;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_RocketBox", 148;
		DropItem "RS_CH_RocketBox", 255;
		DropItem "RS_CH_RocketBox", 148;
		DropItem "RS_CH_RocketBox", 255;
		DropItem "RS_CH_RocketBox", 148;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_Berserk";
		// CH: Dropitem "RLDeathsGazePickup",64 / Dropitem "RareArmorPool",128 /
		//     Dropitem "RLDemonicWeaponSpawner",12 /
		//     Dropitem "RLLegendaryWeaponSpawner",4 /
		//     Dropitem "RLUniqueWeaponSpawner",24 (MASTERMINDS.txt:1203-1207)
		//     -- DRLA cross-mod drops, stripped per owner.
		Tag "Abys$|<%#¤e£Mind";
	}
	States
	{
	Spawn:
		AMIN ABCDEFGHI 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ARNQ A 0 { bFLOAT = true; }
		ARNQ A 0 { bFLOATBOB = true; }
		ARNQ A 0 { bNOGRAVITY = true; }
		TNT1 A 0 A_Jump(99,"See2","See3");
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN A 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN B 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN C 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 1 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM KLMLK 1 A_Chase();   // CH: AMIN KLMLK -- AMIN ships A-I only; K/L/M exist on ANIM, the same monster's other prefix in the same folder, and CH itself writes "ANIM KLMMLK" for this identical flash-pulse in MindSpike/MindWave. Slip for ANIM. Fixed 2026-08-06 (owner: nothing invisible).
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Jump(12,"Warp");
		Loop;
	See2:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN D 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN E 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN F 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Jump(12,"Warp");
		ANIM KLMLK 1 A_Chase();   // CH: AMIN KLMLK -- AMIN ships A-I only; K/L/M exist on ANIM, the same monster's other prefix in the same folder, and CH itself writes "ANIM KLMMLK" for this identical flash-pulse in MindSpike/MindWave. Slip for ANIM. Fixed 2026-08-06 (owner: nothing invisible).
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Jump(99,"See","See3");
		Loop;
	See3:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN G 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN H 3 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		AMIN I 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Jump(12,"Warp");
		ANIM KLMLK 1 A_Chase();   // CH: AMIN KLMLK -- AMIN ships A-I only; K/L/M exist on ANIM, the same monster's other prefix in the same folder, and CH itself writes "ANIM KLMMLK" for this identical flash-pulse in MindSpike/MindWave. Slip for ANIM. Fixed 2026-08-06 (owner: nothing invisible).
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Jump(99,"See","See2");
		Loop;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM K 3 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM K 3 Bright A_FaceTarget();
		TNT1 A 0 A_JumpIfCloser(1000,"Choice1");
		TNT1 A 0 A_Jump(255,"Choice2");
		Goto See;
	Choice1:
		TNT1 A 0 A_Jump(255,"MindSpike","MindWave","BigZap");
	Choice2:
		TNT1 A 0 A_Jump(255,"MindSpike","MindWave");
	MindSpike:
		ANIM K 1 A_PlaySound("queen/sight",7,2,false,ATTN_NONE);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM VXW 12 Bright A_VileTarget("RS_AbyssMindSpike");
		ANIM U 9 Bright A_VileTarget("RS_AbyssMindSpike2");
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM KLMMLK 2 Bright;
		TNT1 A 0 A_Jump(64,"Warp");
		Goto See;
	BigZap:
		ANIM K 1 A_FaceTarget();
		ANIM KJN 9 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Wander();
		ANIM NJK 6 Bright;
		ANIM K 12 A_FaceTarget();
		ANIM K 12 A_CustomMissile("RS_AbyssMindBigZap",42,0,0);
		ANIM K 0 { bNOPAIN = true; }    // CH: A_Changeflag("NOPAIN",TRUE)
		ANIM VWOQPRUTYK 5 Bright A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-359,359));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_CrackedAbyssMindFall",random(-1028,1028),random(-1028,1028),random(32,128),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-15,15));
		TNT1 A 0 A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-1,1));
		TNT1 AAAAAAAAAAA 0 A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-359,359));
		ANIM VYWOQRSTUY 5 Bright A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-359,359));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_CrackedAbyssMindFall",random(-1528,1528),random(-1528,1528),random(32,128),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-359,359));
		TNT1 AAA 0 A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-15,15));
		TNT1 A 0 A_CustomMissile("RS_CrackedAbyssMindFloor",1,0,random(-1,1));
		ANIM KJN 4 Bright;
		TNT1 AAAAAAAAAA 0 A_Wander();
		ANIM NJK 3 Bright;
		ANIM K 0 { bNOPAIN = false; }   // CH: A_Changeflag("NOPAIN",FALSE)
		Goto See;
	MindWave:
		ANIM K 1 A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM OP 9 Bright A_CustomMissile("RS_AbyssMindWave",35,0,random(-6,6));
		TNT1 AAA 0 A_CustomMissile("RS_AbyssMindWave",35,0,random(-20,20));
		TNT1 A 0 A_FaceTarget();
		ANIM QR 9 Bright A_CustomMissile("RS_AbyssMindWave",35,0,random(-2,2));
		TNT1 AAA 0 A_CustomMissile("RS_AbyssMindWave",35,0,random(-20,20));
		TNT1 AAA 0 A_CustomMissile("RS_AbyssMindWave",35,0,random(-50,50));
		ANIM R 10 Bright A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM KLMMLK 2 Bright;
		TNT1 A 0 A_Jump(64,"Warp");
		Goto See;
	Pain:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssMindWalk",12,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		ANIM KJ 2;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_WvileSpot",random(-128,128),random(-128,128),1,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION|SXF_SETMASTER,212);
		ANIM N 2 A_Pain();
		ANIM N 0 A_Jump(128,"Warp");
		Goto See;
	Warp:
		TNT1 A 0 A_SpawnItemEx("RS_CrackedAbyssMindFall",random(-1028,1028),random(-1028,1028),random(32,128),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_Wander();
		TNT1 A 0 A_SpawnItemEx("RS_CrackedAbyssMindFall",random(-1028,1028),random(-1028,1028),random(32,128),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH9",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ANIM K 1;
		Goto See;
	Death:
		ANIM K 10;
		ABSP G 0 A_BossDeath();
		TNT1 A 0 A_Scream();
		ANIM KY 10;
		TNT1 A 0 { bFLOAT = false; }
		TNT1 A 0 { bFLOATBOB = false; }
		TNT1 A 0 { bNOGRAVITY = false; }
		ANIM ST 10;
		TNT1 A 0 A_NoBlocking();
		ANIM T 10 A_SetScale(1.0,0.7);
		ANIM T 10 A_SetScale(1.0,0.4);
		ANIM T 10 A_SetScale(1.0,0.1);
		ANIM TTT 10 A_FadeOut(0.33);
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON. CH MASTERMINDS.txt:1721.
// ---------------------------------------------------------------------------
class RS_CommonMind : SpiderMastermind   // CH MASTERMINDS.txt:1721
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		Species "MMind2";
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		+DONTHARMSPECIES
		-NORADIUSDMG
		+NOFEAR
		// CH: dropitem "RLMinigunpickup",12 (MASTERMINDS.txt:1732) -- DRLA
		//     cross-mod drop, stripped per owner.
		Tag "Spider MasterMind";
	}
	States
	{
	Spawn:
		SPID AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPID A 3 A_Metal();
		SPID ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID C 3 A_Metal();
		SPID CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID E 3 A_Metal();
		SPID EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SPID A 20 Bright A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID GH 4 Bright A_SPosAttackUseAtkSound();
		SPID H 1 Bright A_SpidRefire();
		Goto Missile+1;
	Pain:
		SPID I 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID I 3 A_Pain();
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY. CH MASTERMINDS.txt:1807.
// ---------------------------------------------------------------------------
class RS_GrayMind2 : SpiderMastermind   // CH MASTERMINDS.txt:1807
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		Health 8007;
		Radius 100;
		Species "MMind";
		BloodColor "black";
		Height 100;
		Mass 1000;
		Speed 9;
		PainChance 40;
		Monster;
		RadiusDamageFactor 0.4;
		DamageFactor "Fire", 0.6;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.65;
		DamageFactor "Melee", 0.5;
		PainChance "DIMp", 0;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "SpidHigh";
		AttackSound "spider/attack";
		PainSound "spider/pain";
		DeathSound "spider/death";
		ActiveSound "spider/active";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_ArmorBundle", 200;
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_ClipBox", 200;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		DropItem "BackPack", 64;
		DropItem "RS_CH_CellPack", 64;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_RocketLauncher";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox";
		DropItem "RS_CH_RocketBox", 128;
		Obituary "%o should've paid attention to Gray Mastermind";
		Translation "0:255=%[0.14,0.25,0.32]:[0.79,0.79,0.79]", "168:191=0:2";
		Tag "Rocky Road Spider";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	SetSpike:
		TNT1 AAA 0 A_SpawnItemEx("RS_BrainPainGray",0,0,32,0,0,0,0,SXF_SETMASTER);
	Idle:
		SPIB AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPIB A 3 A_PlaySound("bluemind/step");
		SPIB ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB C 3 A_PlaySound("bluemind/step");
		SPIB CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB E 3 A_PlaySound("bluemind/step");
		SPIB EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SPIB H 1;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(1500,"BLECK");
		TNT1 A 0 A_JumpIfHealthLower(4004,"BLECK2");
		SPIB A 25 Bright A_FaceTarget();
	Missile2:
		SPIB H 2 Bright A_FaceTarget();
		SPIB GG 1 Bright A_CustomBulletAttack(0,0,2,random(1,8),"RS_GrayCGuff");
		SPIB HH 1 Bright A_CustomBulletAttack(3,3,5,random(1,8),"RS_GrayCGuff");
		SPIB H 1 Bright A_MonsterRefire(188,"See");
		Goto Missile2;
	BLECK:
		SPIB H 2 Bright A_FaceTarget();
		TNT1 A 0 A_Jump(128,"Needler");
		SPIB G 1 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-3,3));
		SPIB H 1 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-5,5));
		SPIB GG 1 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-13,13),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-10,10));
		SPIB HH 1 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-15,15),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-10,10));
		SPIB G 0 A_CustomMissile("RS_SpidieShotGray",35,0,random(-10,10),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-10,10));
		SPIB G 0 A_CustomMissile("RS_SpidieShotGray",35,0,random(-10,10),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-10,10));
		SPIB H 3 Bright A_CustomMissile("RS_SpidieShotGray",35,0,random(-10,10));
		TNT1 A 0 A_Jump(32,"SpikeYou");
		SPIB H 15 Bright A_FaceTarget();
		SPIB H 1 Bright A_MonsterRefire(188,"See");
		Goto BLECK;
	Needler:
		SPIB H 8 Bright A_FaceTarget();
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",64,12);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",64,-12);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",132,24);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",132,-24);
		SPIB H 3 Bright;
		SPIB G 3 Bright;
		SPIB H 8 Bright A_FaceTarget();
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",64,12);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",64,-12);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",132,24);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",132,-24);
		SPIB H 3 Bright;
		SPIB G 3 Bright;
		SPIB H 8 Bright A_FaceTarget();
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",64,12);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",64,-12);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",132,24);
		TNT1 A 0 A_CustomMissile("RS_GrayMindNeedle",132,-24);
		SPIB H 3 Bright;
		SPIB G 3 Bright;
		Goto See;
	SpikeYou:
		SPIB H 15 Bright A_FaceTarget();
		SPIB GHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGHGH 1 Bright A_CustomMissile("RS_MolochNail",35,random(-15,15),random(-8,8),CMF_OFFSETPITCH|CMF_SAVEPITCH,random(-5,5));
		SPIB H 15 Bright A_FaceTarget();
		Goto See;
	BLECK2:
		TNT1 A 0;
		SPIB H 1 A_Jump(128,"Missile2","SpikeYou");
		TNT1 A 0;
		Goto BLECK;
	Pain:
		SPIB I 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB I 3 A_Pain();
		Goto See;
	Pain.Ice:
	Pain.Melee:
	Pain.Fire:
		SPIB I 2 A_PlaySound("ResistCH",7);
		SPIB I 2 A_Pain();
		Goto See;
	Death:
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		SPIB J 20 A_Scream();
		SPIB K 10 A_NoBlocking();
		SPIB LMNOPQR 10;
		SPIB S 30;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		SPIB S -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU. CH MASTERMINDS.txt:2114.
// ---------------------------------------------------------------------------
class RS_FireBluMind2 : SpiderMastermind   // CH MASTERMINDS.txt:2114
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 7); }
	Default
	{
		Health 8007;
		Radius 100;
		Species "MMind";
		BloodColor "red";
		Height 100;
		Mass 1000;
		Speed 21;
		PainChance 40;
		Monster;
		MinMissileChance 160;
		RadiusDamageFactor 0.33;
		DamageFactor "Fire", 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.45;
		PainChance "DIMp", 0;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "spider/sight";
		AttackSound "spider/attack";
		PainSound "spider/pain";
		DeathSound "spider/death";
		ActiveSound "spider/active";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_BlueArmor", 200;
		DropItem "RS_CH_ClipBox", 200;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack", 64;
		DropItem "BackPack", 128;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		DropItem "BackPack", 128;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		Obituary "%o got eye burned by fireblu mastermind";
		Translation "48:63=176:191", "128:143=195:207", "144:147=201:204", "148:151=181:187", "64:71=197:202", "72:79=179:187", "1:2=45:47", "13:15=199:202", "5:12=240:247", "96:99=194:197", "100:104=179:183", "105:108=201:205", "109:111=186:191", "208:212=172:175", "224:228=205:205", "80:95=188:191", "17:28=199:206", "4:4=200:200", "152:159=184:190", "192:196=200:203";
		Tag "It's horrifying!";
	}
	States
	{
	Spawn:
		SPID AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPID A 3 A_Metal();
		SPID ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID C 3 A_Metal();
		SPID CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID E 3 A_Metal();
		SPID EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfCloser(1500,"Choices");
		SPID A 25 Bright A_FaceTarget();
		SPID H 10 Bright A_PlaySound("spider/sight");
		SPID G 5 Bright A_CheckSight("See");
		SPID H 5 Bright A_VileTarget("RS_FireBluMindFlame1");
		SPID G 5 Bright A_CheckSight("See");
		SPID H 5 Bright A_VileTarget("RS_FireBluMindFlame1");
		SPID G 5 Bright A_CheckSight("See");
		SPID H 5 Bright A_VileTarget("RS_FireBluMindFlame1");
		SPID A 10;
		Goto See;
	Choices:
		TNT1 A 0 A_Jump(255,"Spam","GroundFlame");
	GroundFlame:
		SPID A 14 Bright A_FaceTarget();
		SPID H 2 Bright A_FaceTarget();
		SPID G 2 Bright A_CustomMissile("RS_FireBluMindFlame3",31,4,random(-3,3));
		TNT1 A 0 A_CustomMissile("RS_FireBluMindFlame3",31,4,random(30,150));
		SPID H 2 Bright A_CustomMissile("RS_FireBluMindFlame3",31,4,random(-150,30));
		SPID H 1 Bright;
		Goto See;
	Spam:
		SPID A 15 Bright A_FaceTarget();
		SPID H 2 Bright A_FaceTarget();
		SPID G 2 Bright A_CustomMissile("RS_FireBCGguy",31,4,random(-3,3));
		TNT1 A 0 A_CustomMissile("RS_FireBCGguy",31,4,random(-15,15));
		SPID H 2 Bright A_CustomMissile("RS_FireBCGguy",31,4,random(-35,35));
		SPID H 1 Bright A_MonsterRefire(188,"See");
		Goto Missile+1;
	Pain:
		SPID I 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH7",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID I 3 A_Pain();
		Goto See;
	Death:
		SPID J 20 A_Scream();
		SPID K 10 A_NoBlocking();
		SPID LMNOPQR 10;
		SPID S 30;
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		SPID S -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN. CH MASTERMINDS.txt:2337.
// ---------------------------------------------------------------------------
class RS_GreenMind : SpiderMastermind   // CH MASTERMINDS.txt:2337
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 4200;
		Radius 100;
		Species "MMind";
		BloodColor "Green";
		Height 100;
		Mass 1000;
		Speed 12;
		PainChance 40;
		Monster;
		MinMissileChance 160;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "spider/sight";
		AttackSound "spider/attack";
		PainSound "spider/pain";
		DeathSound "spider/death";
		ActiveSound "spider/active";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle", 128;
		DropItem "RS_CH_GreenArmor", 42;
		DropItem "RS_CH_ClipBox", 200;
		DropItem "RS_CH_ClipBox";
		Obituary "%o fell ill and died from green masterminds ugly presence";
		Translation "48:79=[53,255,53]:[0,66,0]", "128:151=[0,155,0]:[0,40,0]", "16:31=119:127", "208:223=121:127";
		Tag "Green Spider MasterMind";
	}
	States
	{
	Spawn:
		SPID AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPID A 3 A_Metal();
		SPID ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID C 3 A_Metal();
		SPID CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID E 3 A_Metal();
		SPID EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SPID A 20 Bright A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID H 2 Bright A_FaceTarget();
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,random(-3,3));
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,random(-5,5));
		TNT1 A 0 Bright A_Jump(32,"Sweep");
		SPID H 1 Bright A_MonsterRefire(188,"See");
		Goto Missile+1;
	Sweep:
		SPID H 2 Bright A_FaceTarget();
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,8);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,7);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,6);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,5);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,4);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,3);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,2);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,1);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,0);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-1);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-2);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-3);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-4);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-5);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-6);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-7);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-8);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-7);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-6);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-5);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-4);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-3);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-2);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,-1);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,0);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,1);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,2);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,3);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,4);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,5);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,6);
		SPID H 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,7);
		SPID G 2 Bright A_CustomMissile("RS_SpidieShot1",35,0,8);
		SPID H 1 Bright A_MonsterRefire(188,"See");
		Goto Missile+1;
	Pain:
		SPID I 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPID I 3 A_Pain();
		Goto See;
	Death:
		SPID J 20 A_Scream();
		SPID K 10 A_NoBlocking();
		SPID LMNOPQR 10;
		SPID S 30;
		SPID S -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE. CH MASTERMINDS.txt:2488.
// ---------------------------------------------------------------------------
class RS_BlueMind : SpiderMastermind   // CH MASTERMINDS.txt:2488
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 5600;
		Radius 100;
		Species "MMind";
		BloodColor "Blue";
		Height 100;
		Mass 1000;
		Speed 18;
		PainChance 25;
		Monster;
		// CH: // MinMissileChance 160 -- commented out in CH too (:2500)
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.6;
		PainChance "DIMp", 0;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+MISSILEEVENMORE
		+DONTHARMSPECIES
		+NOFEAR
		SeeSound "spider/sight";
		AttackSound "spider/attack";
		PainSound "spider/pain";
		DeathSound "spider/death";
		ActiveSound "spider/active";
		DropItem "RS_ArmorBundle", 128;
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_BlueArmor", 34;
		DropItem "RS_CH_Cell", 200;
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		Obituary "%o was frozen to the bone by Blue SpiderMasterMind";
		Tag "Frosty Blue Spider MasterMind";
	}
	States
	{
	Spawn:
		SPIB AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SPIB A 3 A_PlaySound("bluemind/step");
		SPIB ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB C 3 A_PlaySound("bluemind/step");
		SPIB CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB E 3 A_PlaySound("bluemind/step");
		SPIB EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		SPIB A 10 Bright A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB A 0 A_JumpIfCloser(420,"FrostBreath");
		SPIB A 0 A_JumpIfHealthLower(2650,"OrMaybe");
		SPIB A 0 A_JumpIfCloser(1200,"FrostOrbs");
		SPIB A 0 A_Jump(255,"LongFrost");
		Goto See;
	OrMaybe:
		SPIB A 0 A_Jump(255,"LongFrost2","FrostOrbs");
		Goto See;
	FrostBreath:
		SPIB H 0 A_PlaySound("Ice/Inhale",0,1.5);
		SPIB H 2 Bright A_FaceTarget();
		TNT1 A 0 A_JumpIfHigherOrLower("HighShot",null,28,0,true);   // CH: A_JumpIfhigherorlower("HighShot","",28,0,true)
		SPIB G 1 Bright A_CustomMissile("RS_FrostMind",30,0,random(-3,3));
		SPIB G 2 Bright A_CustomMissile("RS_FrostMind",30,0,random(-7,7));
		SPIB H 1 Bright A_MonsterRefire(80,"See");
		Goto Missile+1;
	HighShot:
		SPIB G 6 Bright A_PlaySound("Spell/SpellCast1",1,3);
		SPIB G 0 A_SpawnItemEx("RS_IceOrb",0,0,64,random(6,12),0,random(6,14),0);
		SPIB G 0 A_SpawnItemEx("RS_IceOrb",0,0,64,random(6,12),0,random(6,14),-7);
		SPIB G 0 A_SpawnItemEx("RS_IceOrb",0,0,64,random(6,12),0,random(6,14),7);
		Goto Missile+1;
	FrostOrbs:
		SPIB H 6 Bright A_FaceTarget();
		TNT1 A 0 A_JumpIfHigherOrLower("HighShot",null,28,0,true);   // CH: A_JumpIfhigherorlower("HighShot","",28,0,true)
		SPIB G 6 Bright A_PlaySound("Spell/SpellCast1",1,3);
		SPIB G 0 A_CustomMissile("RS_IceOrb",52,-32,random(-5,5));
		SPIB G 0 A_CustomMissile("RS_IceOrb",52,32,random(-5,5));
		SPIB G 0 A_CustomMissile("RS_IceOrb",36,0,random(-1,1));
		SPIB H 6 A_Jump(128,"Missile");
		Goto See;
	LongFrost:
		SPIB H 2 Bright A_FaceTarget();
		SPIB G 2 Bright A_CustomMissile("RS_FrostLong",34,0,random(-1,1));
		SPIB G 2 Bright A_CustomMissile("RS_FrostLong",34,0,random(-6,6));
		SPIB H 1 Bright A_MonsterRefire(80,"See");
		Goto Missile+1;
	LongFrost2:
		SPIB H 2 Bright A_FaceTarget();
		SPIB G 2 Bright A_CustomMissile("RS_FrostLong",34,0,random(-1,1));
		SPIB G 2 Bright A_CustomMissile("RS_FrostLong",34,0,random(-15,15));
		SPIB H 1 Bright A_MonsterRefire(70,"See");
		Goto LongFrost2;
	Pain:
		SPIB I 3;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SPIB I 3 A_Pain();
		Goto See;
	Death:
		SPIB J 20 A_Scream();
		SPIB K 10 A_NoBlocking();
		SPIB LMNOPQR 10;
		SPIB S 30;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,232);
		SPIB S -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Purple's summoned babies. Minion -- NO tier token. CH MASTERMINDS.txt:2724.
// ---------------------------------------------------------------------------
class RS_SpecialSpider1 : RS_BlueSP1   // CH MASTERMINDS.txt:2724
{
	Default
	{
		Species "MMind3";
		Health 350;
		RenderStyle "Add";
		DamageFactor "Scrapper", 3.0;
		DamageFactor "DIMp", 0;
		Alpha 0.95;
		Monster;
		+FLOORCLIP
		+BOSSDEATH
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+THRUSPECIES
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		Obituary "%o was killed by Purple SpiderMasterMind's 'little' spidie baby";
		DropItem "RS_ArmorBundle", 65;
		DropItem "RS_HealthBundle";
		Tag "a weird Spider baby";
	}
	States
	{
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal();
		BSPI ABBCC 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI D 3 A_BabyMetal();
		BSPI DEEFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BSPI A 0 A_JumpIfMasterCloser(1000,"See");
		BSPI A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE. CH MASTERMINDS.txt:2764.
// ---------------------------------------------------------------------------
class RS_PurpleMind : SpiderMastermind   // CH MASTERMINDS.txt:2764
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }

	int user_ragemind;   // CH: Var Int User_Ragemind (MASTERMINDS.txt:2806)

	Default
	{
		Health 6666;
		Radius 100;
		Species "MMind3";
		Height 100;
		Mass 1000;
		Speed 12;
		PainChance 20;
		Monster;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MinMissileChance 160;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		-NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+THRUSPECIES
		+NOFEAR
		SeeSound "monster/demsit";
		AttackSound "spider/attack";
		PainSound "spider/pain";
		DeathSound "spider/death";
		ActiveSound "spider/active";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack", 200;
		DropItem "BackPack", 128;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		// CH: dropitem "RLNuclearArmorPickup",24 (MASTERMINDS.txt:2804) --
		//     DRLA cross-mod drop, stripped per owner.
		Obituary "%o met the evil Purple SpiderMastermind; was killed by it too";
		Tag "Purple Spider MasterMind";
	}
	States
	{
	Spawn:
		SKUL A 0 A_SpawnItemEx("RS_SpecialSpider1",0,-5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialSpider1",0,-5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialSpider1",0,-5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SKUL A 1 Bright A_SpawnItemEx("RS_SpecialSpider1",0,-5,6,0,0,0,0,SXF_TRANSFERAMBUSHFLAG|SXF_SETMASTER|SXF_NOCHECKPOSITION);
	Idle:
		DEMO AB 10 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		DEMO A 3 A_Metal();
		DEMO ABB 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DEMO C 3 A_Metal();
		DEMO CDD 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DEMO E 3 A_Metal();
		DEMO EFF 3 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		DEMO A 10 A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DEMO A 0 A_JumpIf(user_ragemind >= 10,"RageSummon");
		DEMO A 0 A_JumpIfCloser(1000,"PewPew");
		DEMO A 0 A_Jump(255,"HitScanHell","Borb");
		Goto See;
	PewPew:
		DEMO A 0 A_Jump(64,"PewPew2","Borb");
		DEMO A 0 A_Jump(255,"PewPew2","HitScanHell");
		Goto See;
	PewPew2:
		DEMO T 12 Bright A_FaceTarget();
		DEMO T 8 Bright A_PlaySound("Spider/Sight");
		DEMO U 10 Bright A_CustomMissile("RS_DemoMissile",32,0,0);
		DEMO U 10;
		DEMO A 8 A_Jump(88,"Missile");
		Goto See;
	HitScanHell:
		DEMO G 5 A_FaceTarget();
		DEMO G 0 A_PlaySound("spider/attack");
		DEMO G 0 A_CustomBulletAttack(8,8,random(1,7),random(1,2));
		DEMO G 0 A_PlaySound("spider/attack");
		DEMO G 4 Bright A_CustomBulletAttack(5,5,random(1,7),random(1,2));
		DEMO G 0 A_PlaySound("spider/attack");
		DEMO H 0 A_CustomBulletAttack(12,12,random(1,7),random(1,2));
		DEMO G 0 A_PlaySound("spider/attack");
		DEMO H 4 Bright A_CustomBulletAttack(2,2,random(1,7),random(1,2));
		DEMO G 0 A_PlaySound("spider/attack");
		DEMO H 1 Bright A_SpidRefire();
		Goto HitScanHell;
	Borb:
		DEMO G 5 A_FaceTarget();
		DEMO G 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO H 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO H 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO G 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 3 Bright A_FaceTarget();
		DEMO H 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO H 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO G 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO G 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO H 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO H 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO H 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO H 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO G 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO G 3 Bright A_FaceTarget();
		DEMO H 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO H 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO G 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO G 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		DEMO H 2 Bright A_CustomMissile("RS_OrbPurpleMind",32,12,random(-1,1));
		DEMO H 3 Bright A_CustomMissile("RS_OrbPurpleMind",32,-12,random(-1,1));
		Goto See;
	RageSummon:
		DEMO A 12 Bright A_PlaySound("Spider/Sight");
		DEMO I 8 Bright { bNOPAIN = true; }    // CH: A_ChangeFlag("NoPain",TRUE)
		DEMO I 12 Bright A_PlaySound("Spider/Sight");
		DEMO G 4 Bright A_SpawnItemEx("RS_SpecialSpider1",0,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		DEMO G 4 Bright A_SpawnItemEx("RS_SpecialSpider1",0,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		DEMO G 4 Bright A_SpawnItemEx("RS_SpecialSpider1",5,-5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		DEMO G 4 Bright A_SpawnItemEx("RS_SpecialSpider1",-5,5,6,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		DEMO A 4 { user_ragemind = user_ragemind - 8; }   // CH: A_SetUserVar("User_RageMind",User_Ragemind-8)
		DEMO I 8 Bright { bNOPAIN = false; }   // CH: A_ChangeFlag("NoPain",FALSE)
		Goto See;
	Pain:
		DEMO I 3 { user_ragemind = user_ragemind + 1; }   // CH: A_SetUserVar("User_RageMind",User_Ragemind+1)
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		DEMO I 3 A_Pain();
		Goto See;
	Death:
		DEMO J 20 Bright A_Scream();
		DEMO K 10 Bright A_NoBlocking();
		DEMO LMNOPQR 10 Bright;
		DEMO S 30;
		DEMO S -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW. CH MASTERMINDS.txt:3037.
// ---------------------------------------------------------------------------
class RS_YellowMind : Actor   // CH MASTERMINDS.txt:3037
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }

	int user_halpme;   // CH: Var Int User_HalpMe (MASTERMINDS.txt:3080)

	Default
	{
		Health 7777;
		Radius 40;
		Height 95;
		Speed 12;
		BloodColor "Yellow";
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance 10;
		Mass 1000;
		Monster;
		+BOSS
		-NOGRAVITY
		-FLOAT
		-FLOATBOB
		-NORADIUSDMG
		+DONTMORPH
		+MISSILEMORE
		+NOFEAR
		+DONTHARMCLASS
		SeeSound "fiend/see";
		DeathSound "spider/death";
		Obituary "%o had their mind fly by Orange Mastermind";
		Translation "169:191=160:167";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "BackPack";
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 128;
		DropItem "BackPack", 64;
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_PlasmaRifle";
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		DropItem "RS_CH_RocketBox", 128;
		Tag "Yellow MasterMind";
	}
	States
	{
	Spawn:
		SUPS A 4;
		Goto Announce;
	Announce:
		SUPS A 2;
		SUPS A 4;   // CH: ACS_NamedExecuteAlways("AnnounceSpidie1") -- announcer stripped
		Goto Idle;
	Idle:
		SUPS A 4 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SUPS A 0 { bFLOAT = true; }
		SUPS A 0 { bFLOATBOB = true; }
		SUPS A 0 { bNOGRAVITY = true; }
		SUPS A 0 A_PlaySound("fiend/hover");
		SUPS AAAA 2 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SUPS B 0 A_JumpIfHealthLower(3500,"Halp");
		SUPS B 0 A_JumpIfCloser(500,"BFGd");
		SUPS B 0 A_JumpIfCloser(2000,"OrMaybe");
		SUPS B 0 A_Jump(255,"Homers");
		Goto See+3;
	OrMaybe:
		SUPS B 0 A_Jump(255,"Homers","PlasmaSpam","RapidPlasma");
		Goto See+3;
	Halp:
		SUPS E 0 A_JumpIf(user_halpme >= 1,"Nah");
		SUPS E 12 A_PlaySound("fiend/see");
		SUPS B 24 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenmore",TRUE)
		SUPS B 4 A_SpawnItemEx("RS_YellowSP1",0,-55,56,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SUPS B 4 A_SpawnItemEx("RS_YellowSP1",0,55,-56,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SUPS B 4 A_SpawnItemEx("RS_YellowSP1",0,-25,26,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SUPS B 4 A_SpawnItemEx("RS_YellowSP1",0,25,-26,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		SUPS B 2 { bTHRUACTORS = true; }        // CH: A_ChangeFlag("THRUACTORS",TRUE)
		SUPS B 24;
		SUPS B 8 { user_halpme = user_halpme + 1; }   // CH: A_SetUserVar("User_HalpMe",User_HalpMe+1)
		SUPS B 2 { bTHRUACTORS = false; }       // CH: A_ChangeFlag("THRUACTORS",FALSE)
		Goto See+3;
	Nah:
		SUPS E 0;
		Goto Missile+4;
	PlasmaSpam:
		SUPS B 0 A_PlaySound("fiend/hover");
		SUPS B 6 Bright A_FaceTarget();
		SUPS B 0 A_PlaySound("fiend/hover");
		SUPS B 6 Bright A_FaceTarget();
		SUPS F 2 Bright A_CustomMissile("RS_FiendPlasmaBall",30,0,0);
		SUPS E 2 Bright;
		SUPS B 1 Bright A_SpidRefire();
		SUPS F 2 Bright A_CustomMissile("RS_FiendPlasmaBall",30,0,random(-3,3));
		SUPS E 2 Bright;
		SUPS B 1 Bright A_SpidRefire();
		SUPS F 2 Bright A_CustomMissile("RS_FiendPlasmaBall",30,0,random(-8,8));
		SUPS E 2 Bright;
		Goto Missile;
	BFGd:
		SUPS B 0 A_PlaySound("fiend/hover");   // CH: //BFG
		SUPS B 8 Bright A_FaceTarget();
		SUPS B 0 A_PlaySound("fiend/hover");
		SUPS B 8 Bright A_FaceTarget();
		SUPS B 8 Bright A_PlayWeaponSound("fiend/bfg");
		SUPS E 10 Bright A_FaceTarget();
		SUPS F 10 Bright;
		SUPS F 0 A_CustomMissile("RS_FiendPlasmaBall",30,0,0);
		SUPS F 0 A_CustomMissile("RS_FiendPlasmaBall",30,0,-6);
		SUPS F 0 A_CustomMissile("RS_FiendPlasmaBall",30,0,6);
		SUPS F 0 A_CustomMissile("RS_FiendPlasmaBall",30,0,-12);
		SUPS F 0 A_CustomMissile("RS_FiendPlasmaBall",30,0,12);
		TNT1 A 0 A_Jump(128,"PlasmaSpam","RapidPlasma");
		Goto See+3;
	RapidPlasma:
		SUPS B 10 Bright A_FaceTarget();
		SUPS B 0 A_PlayWeaponSound("fiend/bomb");
		SUPS OPQ 7 Bright A_FaceTarget();
		TNT1 A 0 A_Jump(128,"HitIt2");
	HitIt:
		SUPS Q 1 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_PlasmaBallSP3",22,20,random(-11,1));
		SUPS Q 0 A_CustomMissile("RS_PlasmaBallSP3",22,-20,random(-1,11));
		SUPS Q 1 A_FaceTarget();
		SUPS Q 1 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_PlasmaBallSP3",22,20,random(1,5));
		SUPS Q 0 A_CustomMissile("RS_PlasmaBallSP3",22,-20,random(-5,-1));
		SUPS Q 1 A_FaceTarget();
		SUPS Q 1 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_PlasmaBallSP3",22,20,1);
		SUPS Q 0 A_CustomMissile("RS_PlasmaBallSP3",22,-20,-1);
		SUPS Q 1 A_FaceTarget();
		SUPS Q 1 A_CheckSight("StopIt");
		TNT1 A 0 A_Jump(64,"HitIt2");
		TNT1 A 0 A_CheckFlag("SOLID","HitIt",AAPTR_TARGET);
		Goto See;
	HitIt2:
		SUPS Q 1 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_AracnorbBall",22,20,random(-11,1));
		SUPS Q 0 A_CustomMissile("RS_AracnorbBall",22,-20,random(-1,11));
		SUPS Q 1 A_FaceTarget();
		SUPS Q 1 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_AracnorbBall",22,20,random(1,5));
		SUPS Q 0 A_CustomMissile("RS_AracnorbBall",22,-20,random(-5,-1));
		SUPS Q 1 A_FaceTarget();
		SUPS Q 1 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_AracnorbBall",22,20,1);
		SUPS Q 0 A_CustomMissile("RS_AracnorbBall",22,-20,-1);
		SUPS Q 1 A_FaceTarget();
		SUPS Q 1 A_CheckSight("StopIt");
		TNT1 A 0 A_Jump(64,"HitIt");
		TNT1 A 0 A_CheckFlag("SOLID","HitIt2",AAPTR_TARGET);
		Goto See;
	StopIt:
		SUPS QPO 10 Bright A_FaceTarget();
		Goto See;
	Homers:
		SUPS B 10 Bright A_FaceTarget();
		SUPS B 0 A_PlayWeaponSound("fiend/bomb");
		SUPS OPQ 7 Bright A_FaceTarget();
		SUPS Q 0 A_CustomMissile("RS_RemoteBombV2",22,20,45);
		SUPS Q 0 A_CustomMissile("RS_RemoteBombV2",22,-20,-45);
		SUPS Q 16 Bright A_FaceTarget();
		SUPS B 0 A_PlayWeaponSound("fiend/bomb");
		SUPS Q 0 A_CustomMissile("RS_RemoteBombV2",22,20,33);
		SUPS Q 0 A_CustomMissile("RS_RemoteBombV2",22,-20,-33);
		SUPS Q 16 Bright A_FaceTarget();
		SUPS B 0 A_PlayWeaponSound("fiend/bomb");
		SUPS Q 0 A_CustomMissile("RS_RemoteBombV2",22,20,15);
		SUPS Q 0 A_CustomMissile("RS_RemoteBombV2",22,-20,-15);
		SUPS QPO 10 Bright A_FaceTarget();
		Goto See+3;
	Death:
		SUPS G 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag(FLOATBOB,0)
		SUPS G 10 A_Scream();
		SUPS H 10;
		SUPS I 10 A_Fall();
		SUPS JKLM 10;
		SUPS N -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED. CH MASTERMINDS.txt:3359.
// ---------------------------------------------------------------------------
class RS_RedMind : Actor   // CH MASTERMINDS.txt:3359
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }

	int user_phase2;   // CH: Var Int User_Phase2 (MASTERMINDS.txt:3418)

	Default
	{
		Health 10000;
		Radius 40;
		Height 95;
		Speed 18;
		FloatSpeed 20;
		PainChance 1;
		Mass 1000;
		RadiusDamageFactor 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		DamageFactor "ice", 1.35;
		Monster;
		+NOPAIN
		+BOSS
		-NOGRAVITY
		-FLOATBOB
		-FLOAT
		-NORADIUSDMG
		+NOFEAR
		+DONTMORPH
		+MISSILEMORE
		+DONTHARMCLASS
		SeeSound "arachnophyte/sight";
		PainSound "arachnophyte/pain";
		DeathSound "arachnophyte/death";
		AttackSound "Ice/Hit2";
		Obituary "%o ran out of luck in the face of Red Mastermind";
		ExplosionDamage 128;
		ExplosionRadius 255;
		Scale 1.33;
		Translation "96:111=176:191", "3:3=183:183", "80:95=176:184", "5:12=[84,1,1]:[39,7,7]", "0:2=42:47", "128:143=186:191", "144:151=188:191";
		DropItem "RS_ArmorBundle";
		DropItem "RS_HealthBundle";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_BFG9000";
		DropItem "RS_CH_RocketBox", 148;
		DropItem "RS_CH_RocketBox", 255;
		DropItem "RS_CH_RocketBox", 148;
		DropItem "RS_CH_RocketBox", 255;
		DropItem "RS_CH_RocketBox", 148;
		DropItem "RS_CH_RocketBox", 64;
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_ClipBox";
		DropItem "RS_CH_Berserk";
		// CH: Dropitem "RLDeathsGazePickup",32 / Dropitem "RareArmorPool",128 /
		//     Dropitem "RLDemonicWeaponSpawner",24 /
		//     Dropitem "RLLegendaryWeaponSpawner",2 /
		//     Dropitem "RLUniqueWeaponSpawner",32 (MASTERMINDS.txt:3412-3416)
		//     -- DRLA cross-mod drops, stripped per owner.
		Decal "BulletChip";
		Tag "Red MasterMind";
	}
	States
	{
	Spawn:
		APYT A 4;
		Goto Announce;
	Announce:
		APYT A 2;
		APYT A 4;   // CH: ACS_NamedExecuteAlways("AnnounceSpidie2") -- announcer stripped
		Goto Idle;
	Idle:
		APYT A 0 A_PlaySound("arachnophyte/engine");
		APYT ABABAB 4 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	See:
		APYT A 0 { bFLOAT = true; }
		APYT A 0 { bFLOATBOB = true; }
		APYT A 0 { bNOGRAVITY = true; }
		APYT A 0 A_PlaySound("arachnophyte/engine");
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT AABBAA 2 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT BBAABB 2 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT A 0 A_Jump(128,"See2");
		Loop;
	See2:
		APYT A 0 A_PlaySound("arachnophyte/engine");
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT AABBAA 2 A_FastChase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT BBAABB 2 A_FastChase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT A 0 A_Jump(128,"See");
		Loop;
	Missile:
		APYT A 0 A_PlaySound("arachnophyte/engine");
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT A 0 A_JumpIf(user_phase2 >= 1,"Phase2Jumps");
		APYT A 0 A_JumpIfHealthLower(5000,"Phase2");
		APYT A 0 A_Jump(255,"Chaingunlasers","Blobs","FireWave");
		Goto See+3;
	Phase2Jumps:
		APYT A 0 A_JumpIfCloser(1500,"Phase2Jumps2");
		APYT A 0 A_Jump(255,"Chaingunlasers");
		Goto See+3;
	Phase2Jumps2:
		APYT A 0 A_Jump(255,"Chaingunlasers2","Blobs","FireWave","GroundHogs");
		Goto See+3;
	Chaingunlasers2:
		APYT BABAB 1 A_FaceTarget();
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT A 0 A_PlaySound("arachnophyte/engine");
		APYT CD 5 A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		APYT D 0 A_Jump(64,"Blobs");
		APYT D 2 A_MonsterRefire(128,"See");
		Goto Chaingunlasers2+1;
	Phase2:
		APYT A 6 A_PlaySound("arachnophyte/sight");
		APYT A 2 { bMISSILEEVENMORE = true; }   // CH: A_ChangeFlag("MissileEvenMore",True)
		APYT ABABABABABAB 4 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT AB 4 A_FaceTarget();
		APYT ABABABABABAB 4 A_CustomMissile("RS_RedMessImp",32,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		APYT AB 4 A_FaceTarget();
		APYT A 4 { user_phase2 = user_phase2 + 1; }   // CH: A_SetUserVar("User_Phase2",User_Phase2+1)
		Goto GroundHogs;
	GroundHogs:
		APYT BA 5 A_FaceTarget();
		APYT C 6 A_FaceTarget();
		APYT DCDCD 6 A_CustomMissile("RS_RedMindRingNew",0,random(-32,32),random(-64,64));
		Goto See+3;
	FireWave:
		APYT BA 5 A_FaceTarget();
		APYT C 6 A_FaceTarget();
		APYT DCDCDCD 6 A_CustomMissile("RS_SpiralSawMind1",18,random(-32,32),random(-32,32));
		Goto See+3;
	Blobs:
		APYT BA 5 A_FaceTarget();
		APYT C 8 A_FaceTarget();
		APYT C 8;
		APYT CCCCC 6 A_SpawnItemEx("RS_RedMindBomb",random(-60,60),random(-60,60),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See+3;
	Chaingunlasers:
		APYT BABAB 1 A_FaceTarget();
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		APYT A 0 A_PlaySound("arachnophyte/engine");
		APYT CD 5 A_CustomRailgun(random(2,10),0,"none","red",RGF_FULLBRIGHT,1,12,"none",0,0,0,34,1,15,"none",0);
		APYT D 0 A_Jump(24,"Blobs");
		APYT D 2 A_MonsterRefire(128,"See");
		Goto Chaingunlasers+1;
	Pain:
		APYT A 1 A_Pain();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		APYT AAABBB 0 A_SpawnItemEx("RS_RedThingsLS",random(-40,40),random(-40,40),random(-15,40),0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See+3;
	Death:
		APYT A 0 A_PlaySound("spider/death");
		APYT A 4 A_Scream();
		APYT B 4;
		APYT EF 8;
		APYT G 6 A_Explode(random(5,45),128);
		APYT H 6 A_Fall();
		APYT IJ 6;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Red's floating mine. Summon -- NO tier token. CH MASTERMINDS.txt:3715.
// ---------------------------------------------------------------------------
class RS_RedMindBomb : Actor   // CH MASTERMINDS.txt:3715
{
	Default
	{
		Obituary "run, %o , its red and dangerous!";
		Health 20;
		DamageFactor "Fire", 0.2;
		DamageFactor "None", 1.5;
		Radius 20;
		Height 20;
		Mass 20;
		Speed 19;
		DamageType "Fire";
		PainChance 20;
		SeeSound "prox/fire";
		AttackSound "vile/active";
		DeathSound "weapons/rocklx";
		Translation "208:223=176:191", "224:231=176:176";
		RenderStyle "Add";
		Alpha 0.85;
		Scale 1.85;
		Monster;
		+FLOAT
		+FLOATBOB
		+NOTARGETSWITCH
		+NOGRAVITY
		+LOOKALLAROUND
		+NOBLOOD
		+THRUACTORS
		-COUNTKILL
	}
	States
	{
	Spawn:
		BAL1 AABB 10 A_Look();
		Loop;
	See:
		BAL1 AB 2 A_Chase();
		BAL1 A 0 A_SpawnItemEx("RS_RedMessMind",0,0,8,0,0,0,0);
		Loop;
	Melee:
		BAL1 A 0;
		Goto Boom;
	Boom:
		MISL B 0 A_SetScale(1.1);
		MISL B 0 A_Explode(random(20,70),128);
		MISL B 5 Bright A_PlaySound("weapons/rocklx");
		MISL C 5 A_NoBlocking();
		MISL D 5;
		TNT1 A 0 A_Die();
		Stop;
	Pain:
		BAL1 A 3;
		BAL1 A 3 A_Pain();
		Goto See;
	Pain.Fire:
		BAL1 A 3 A_SetSpeed(30);
		BAL1 A 3 A_Pain();
		Goto See;
	Death:
		MISL B 0 A_SetScale(1.1);
		MISL B 0 A_Explode(50,128);
		MISL B 5 Bright A_PlaySound("weapons/rocklx");
		MISL C 5 A_NoBlocking();
		MISL D 0 A_Jump(255,"Clip2","Shell2");
		TNT1 A 0 A_Die();
		Stop;
	Clip2:
		MISL D 5 A_SpawnItemEx("Clip",0,0,0,0,0,0,0,0,128);
		TNT1 A 0 A_Die();
		Stop;
	Shell2:
		MISL D 5 A_SpawnItemEx("Shell",0,0,0,0,0,0,0,0,128);
		TNT1 A 0 A_Die();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK, "Pseudo Old God". CH MASTERMINDS.txt:3839.
// RESOLVED 2026-08-06 -- RapidFire's "ARNQ P" was a slip for ARNQ D and is now
// ARNQ D. ARNQ ships A-M (CH sprites/bigmama, 37 lumps); the line sits in a run
// of eleven otherwise-identical "ARNQ D 0 A_FaceTarget" facing-resets in the
// same state, so the intended frame is not in doubt. It is a 0-tic state, so it
// never rendered before or after -- the change removes a phantom, it does not
// change what is drawn. CHP inherits the same typo verbatim
// (DECORATE/16/16_K.txt:127 et al).
// ---------------------------------------------------------------------------
class RS_BlackMind2 : Actor   // CH MASTERMINDS.txt:3839
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }

	int user_sce;   // CH: var int user_sce (MASTERMINDS.txt:3894)

	Default
	{
		Monster;
		+BOSS
		+NOTARGET
		+DONTMORPH
		-NORADIUSDMG
		+DONTHARMCLASS
		+MISSILEMORE
		+NOICEDEATH
		Health 11111;
		Radius 40;
		Height 95;
		Mass 2000;
		Speed 26;
		RadiusDamageFactor 0.33;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		FloatSpeed 28;
		PainChance 45;
		PainThreshold 24;
		SeeSound "queen/sight";
		ActiveSound "queen/active";
		PainSound "queen/pain";
		DeathSound "queen/death";
		MeleeSound "queen/melee";
		Alpha 0.75;
		MissileHeight 36;
		Obituary "%o got worse than just afflicted by the Black MasterMind";
		HitObituary "%o had %p skull chewed by Black MasterMind, somehow?";
		Scale 1.5;
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BFG9000";
		// CH: Dropitem "VoidOrb" (MASTERMINDS.txt:3883) -- class defined
		//     NOWHERE in the CH tree. Itemised, not silently gutted.
		// CH: Dropitem "SchoolGirlTG" (MASTERMINDS.txt:3884) -- class defined
		//     NOWHERE in the CH tree (dropped here and at Barons.txt:3940,
		//     declared never). Same itemisation the baron lane made.
		DropItem "RS_CH_Medikit";
		DropItem "RS_CH_Medikit";
		DropItem "RS_CH_Medikit";
		DropItem "RS_CH_BlurSphere";   // CH MASTERMINDS.txt:3888 -- restored 2026-08-06 with the root DECORATE.txt sweep (chshared/RS_CHShared.zs:59)
		// CH: Dropitem "RareArmorPool" / Dropitem "RLDemonicWeaponSpawner",18 /
		//     Dropitem "RLLegendaryWeaponSpawner",12 /
		//     Dropitem "RLUniqueWeaponSpawner",46 (MASTERMINDS.txt:3889-3892)
		//     -- DRLA cross-mod drops, stripped per owner.
		Translation "48:63=[124,124,124]:[2,2,2]", "16:31=[121,121,121]:[2,2,2]", "64:79=[88,88,88]:[2,2,2]", "128:144=[91,91,91]:[48,48,48]", "236:239=0:2", "13:15=0:2", "144:151=104:111", "208:223=96:111", "32:47=96:111", "232:235=108:111", "112:127=46:47", "80:95=144:151", "224:227=103:107", "168:173=96:96", "192:196=236:239", "96:101=236:239", "208:210=102:104", "152:159=106:111";
		Tag "Pseudo Old God";
	}
	States
	{
	Spawn:
		ARNQ A 0;
		Goto Announce;
	Announce:
		ARNQ A 2;
		ARNQ A 4;   // CH: ACS_NamedExecuteAlways("AnnounceSpidie3") -- announcer stripped
		Goto Idle;
	Idle:
		ARNQ A 1 A_Look();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		ARNQ A 0 { bFLOAT = true; }
		ARNQ A 0 { bFLOATBOB = true; }
		ARNQ A 0 { bNOGRAVITY = true; }
		ARNQ A 2 A_Chase();
		ARNQ A 0 A_CustomMissile("RS_BlackSpidShade",random(-5,55),random(-15,15),CMF_AIMOFFSET,random(0,360),random(0,360));
		ARNQ A 2 A_Chase();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ A 0 A_CustomMissile("RS_BlackSpidShade",random(-5,55),random(-15,15),CMF_AIMOFFSET,random(0,360),random(0,360));
		ARNQ A 0 A_Jump(12,"PainTele");
		Loop;
	Missile:
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_JumpIfHealthLower(7777,"SCREEE");
		TNT1 A 0 A_JumpIfCloser(512,"CloseRange");
		TNT1 A 0 A_JumpIfCloser(2028,"Choose");
		TNT1 A 0 A_Jump(256,"Psyche2");
		Goto See;
	Choose:
		TNT1 A 0 A_Jump(256,"BIGBAM","LongRange");
		Goto See;
	Miss2:
		TNT1 A 0 A_JumpIfCloser(512,"CloseRange2");
		TNT1 A 0 A_JumpIfCloser(2028,"Choose2");
		TNT1 A 0 A_Jump(256,"Psyche2");
		Goto Missile+7;
	SCREEE:
		ARNQ E 0 A_JumpIf(user_sce >= 1,"Miss2");
		ARNQ E 0 { bNOPAIN = true; }              // CH: A_changeFlag("NOPAIN",true)
		ARNQ E 10 Bright { bMISSILEEVENMORE = true; }   // CH: A_changeFlag("MISSILEEVENMORE",true)
		ARNQ E 10 Bright A_PlaySound("DeepOne/active",7,2,false,ATTN_NONE);
		ARNQ E 10 Bright { user_sce = user_sce + 1; }   // CH: A_SetUserVar("user_sce",user_sce+1)
		ARNQ EEEEEE 2 Bright A_SpawnParticle("Black",SPF_FULLBRIGHT,70,2,random(-180,180),random(-180,180),random(-180,180),random(-180,180));
		ARNQ E 10 Bright A_SetSpeed(24);
		ARNQ E 8 Bright { bNOPAIN = false; }      // CH: A_changeFlag("NOPAIN",False)
		Goto See;
	CloseRange2:
		TNT1 A 0 A_Jump(200,"RapidFire","Waves2","Psyche2","Summons");
		Goto Missile;
	Choose2:
		TNT1 A 0 A_Jump(212,"Choose","BIGBAM","Waves2","Psyche2","Summons");
		Goto Missile;
	CloseRange:
		TNT1 A 0 A_Jump(176,"RapidFire","Waves");
		Goto SpreadFire;
	LongRange:
		TNT1 A 0 A_Jump(176,"SpreadFire","Waves","Psyche2");
		Goto RapidFire;
	BIGBAM:
		TNT1 A 0 A_PlaySound("queen/fire");
		ARNQ BCD 6 A_FaceTarget();
		ARNQ E 10 Bright A_CustomMissile("RS_QueenMindWave",64,0,0);
		Goto See;
	Waves:
		TNT1 A 0 A_PlaySound("queen/fire");
		ARNQ BCD 4 A_FaceTarget();
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",30,-10,0);
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",54,-2,random(-5,5));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",72,10,random(-8,8));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",64,-10,random(-12,12));
		ARNQ E 6 Bright A_CustomMissile("RS_ZWAVE3",44,18,random(-15,15));
		ARNQ E 0 A_Jump(72,"Missile");
		Goto See;
	Waves2:
		TNT1 A 0 A_PlaySound("queen/fire");
		ARNQ BCD 4 A_FaceTarget();
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",64,-10,random(-12,12));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",54,10,random(-12,12));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",44,-0,random(-1,1));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",74,20,random(-12,12));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",64,-30,random(-4,4));
		ARNQ E 0 A_CustomMissile("RS_ZWAVE3",54,30,random(-12,12));
		ARNQ E 6 Bright A_CustomMissile("RS_ZWAVE3",64,-20,random(-12,12));
		ARNQ E 0 A_Jump(84,"BIGBAM","ClusterEf");
		Goto Waves;
	ClusterEf:
		ARNQ BCD 4 A_FaceTarget();
		ARNQ EEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 1 Bright A_CustomMissile("RS_ZWAVE3",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 1 Bright A_CustomMissile("RS_ZWAVE3",62,0,random(-11,11));
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 1 Bright A_CustomMissile("RS_ZWAVE3",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		Goto See;
	Summons:
		ARNQ E 10 Bright A_FaceTarget();
		ARNQ E 10 Bright A_PlaySound("DeepOne/active",7,2,false,ATTN_NONE);
		ARNQ DC 8 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ BABAB 3 Bright A_SpawnItemEx("RS_PortalSummons2",random(-178,178),random(-178,178),random(5,64),0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		ARNQ C 7 Bright;
		Goto See;
	RapidFire:
		ARNQ BCD 4 A_FaceTarget();
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-4,4));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-7,7));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-11,11));
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ D 0 A_FaceTarget();   // CH: ARNQ P -- ARNQ ships A-M only. This is one line in a run of eleven otherwise-identical "ARNQ D 0 A_FaceTarget" facing-resets in the same state; P is a slip for D. 0 tics, so it never rendered either way. Fixed 2026-08-06 (owner: nothing invisible).
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-7,7));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-7,7));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEE 2 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-4,4));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEEEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-4,7));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEEEEEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-11,11));
		ARNQ D 0 A_FaceTarget();
		ARNQ EEEEEEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-7,4));
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ D 0 A_FaceTarget();
		ARNQ EEEEEEEEEEEE 1 Bright A_CustomMissile("RS_QueenPlasmaBlast",62,0,random(-3,3));
		ARNQ D 5 A_FaceTarget();
		ARNQ D 1 A_CheckSight("PainTele");
		ARNQ D 1 A_Jump(72,"BIGBAM","ClusterEf");
		ARNQ D 1 A_Jump(94,"Missile");
		Goto See;
	Psyche2:
		ARNQ E 5 Bright A_FaceTarget();
		ARNQ E 9 Bright A_PlaySound("queen/sight",7,2,false,ATTN_NONE);
		ARNQ E 9 Bright A_FaceTarget();
		ARNQ E 3 Bright A_FaceTarget();
		ARNQ E 0 A_CheckSight("See");
		ARNQ E 4 Bright A_VileTarget("RS_PsychicAra2");
		ARNQ E 2 A_MonsterRefire(128,"See");
		Goto Psyche2+3;
	SpreadFire:
		ARNQ BCD 6 A_FaceTarget();
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-7,1),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-1,7),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-15,-7),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(7,15),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-7,7),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		ARNQ E 5 Bright A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-4,4));
		ARNQ B 1 Bright A_CheckSight("See");
		ARNQ BCD 5 A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-7,1),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-1,7),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AAAA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-15,15),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-7,17),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		TNT1 AA 0 A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-17,7),CMF_AIMOFFSET|CMF_OFFSETPITCH,random(-3,3));
		ARNQ E 5 Bright A_CustomMissile("RS_QueenPlasmaBlast",64,0,random(-4,4));
		ARNQ D 5 A_FaceTarget();
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ D 1 A_Jump(64,"Missile","ClusterEf");
		Goto See;
	Pain:
		TNT1 A 0 A_Jump(142,"PainTele");
		ARNQ F 4;
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		ARNQ F 4 A_Pain();
		Goto See;
	PainTele:
		ARNQ E 2 A_Teleport("See","RS_BlackSpidShade","RS_ZWAVE2",TF_KEEPVELOCITY);
		TNT1 AA 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Death:
		TNT1 A 0 A_NoBlocking();
		ARNQ G 0 A_PlaySound("deepone/death",7,2,false,ATTN_NONE);
		ARNQ G 0 { bFLOATBOB = false; }   // CH: A_ChangeFlag("FLOATBOB",0)
		ARNQ G 9 A_Scream();
		TNT1 A 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		ARNQ G 3;
		Goto Crash;
	Crash:
		ARNQ HIJKL 9;
		ARNQ L 2 Radius_Quake(60,60,0,80,0);
		ARNQ M -1 A_BossDeath();
		Stop;
	}
}

// ---------------------------------------------------------------------------
// CH's own "// UNUSED" actor -- nothing in CH references it. Kept verbatim,
// no tier token. CH MASTERMINDS.txt:4477.
// ---------------------------------------------------------------------------
class RS_CH_OrbOfChaos : Actor   // CH MASTERMINDS.txt:4477 -- UNUSED in CH
{
	Default
	{
		Obituary "";
		Health 2000;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Radius 40;
		Height 80;
		Scale 1.0;
		Mass 0x7FFFFFFF;
		Species "MMind";
		PainChance 96;
		SeeSound "";
		PainSound "";
		DeathSound "";
		ActiveSound "";
		Monster;
		+FLOORCLIP
		+DONTHARMCLASS
		+LOOKALLAROUND
		+THRUSPECIES
		+NOTARGET
		+MISSILEEVENMORE
		-NORADIUSDMG
		Tag "Devil's Machine";
	}
	States
	{
	Spawn:
		TNT1 A 10;
	Stay:
		CHA0 ABCDCBA 8 Bright;
		Loop;
	Death:
		CHA0 EFGHIJKL 6 Bright;
		TNT1 A 0 A_Scream();
		TNT1 A 0 A_NoBlocking();
		CHA0 M -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE, "Heavily Armed Spidey". CH MASTERMINDS.txt:4925.
// ---------------------------------------------------------------------------
class RS_WhiteMind2 : Actor   // CH MASTERMINDS.txt:4925
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 15000;
		Species "MMind";
		Radius 64;
		Height 64;
		Mass 1000;
		Speed 28;
		PainChance 40;
		PainThreshold 50;
		Damage 8;
		Scale 1.25;
		Monster;
		DamageFactor "Fire", 0.25;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.25;
		DamageFactor "Plasma", 0.75;
		DamageFactor "Melee", 0.95;
		RadiusDamageFactor 0.2;
		PainChance "DIMp", 0;
		DamageFactor "Falling", 0.0;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		+NOBLOOD
		-NORADIUSDMG
		+NOICEDEATH
		+DONTMORPH
		+BOSSDEATH
		+DONTHARMSPECIES
		+NOFEAR
		+LAXTELEFRAGDMG
		+AVOIDMELEE
		SeeSound "WMINDAGR";
		PainSound "spider/pain";
		DeathSound "WMINDDED";
		ActiveSound "WMIND/IDLE";
		DropItem "RS_CH_MegaSphere";
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_CellPack", 128;
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BlueArmor";
		DropItem "RS_CH_BFG9000";
		// CH: Dropitem "VoidOrb" (MASTERMINDS.txt:4979) -- class defined
		//     NOWHERE in the CH tree. Itemised, not silently gutted.
		DropItem "RS_CH_Medikit";
		DropItem "RS_CH_Medikit";
		DropItem "RS_CH_Medikit";
		DropItem "RS_CH_BlurSphere";   // CH MASTERMINDS.txt:4983 -- restored 2026-08-06 with the root DECORATE.txt sweep (chshared/RS_CHShared.zs:59)
		// CH: Dropitem "RareArmorPool" / Dropitem "RLDemonicWeaponSpawner",18 /
		//     Dropitem "RLLegendaryWeaponSpawner",12 /
		//     Dropitem "RLUniqueWeaponSpawner",46 (MASTERMINDS.txt:4984-4987)
		//     -- DRLA cross-mod drops, stripped per owner.
		Obituary "%o fell to the power of white spider mastermind";
		Tag "Heavily Armed Spidey";
	}
	States
	{
	Spawn:
		W5PD AB 1;
		TNT1 A 0;   // CH: ACS_NamedExecuteAlways("AnnounceSpidie4") -- announcer stripped
	Idle:
		W5PD AB 10 A_Look();
		Loop;
	See:
		W5PD ABCD 2 A_Chase();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(16,"See2");
		Loop;
	See2:
		W5PD ABCDABCD 1 A_Wander();
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Dodge1:
		TNT1 A 0 A_Jump(128,"Dodge2");
		W5PD A 5 ThrustThing(int(angle*256/360+64),36,0,0);   // CH: ThrustThing(angle*256/360+64,36,0,0)
		W5PD AABBCCDD 2 A_SpawnItemEx("RS_WhiteSpidShade",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Dodge2:
		W5PD A 5 ThrustThing(int(angle*256/360+192),36,0,0);   // CH: ThrustThing(angle*256/360+192,36,0,0)
		W5PD AABBCCDD 2 A_SpawnItemEx("RS_WhiteSpidShade",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		W5PD F 5 A_FaceTarget();
		TNT1 A 0 A_JumpIfCloser(100,"Dash",true);
		TNT1 A 0 A_JumpIfCloser(1500,"LowRange",true);
		TNT1 A 0 A_Jump(255,"EyeBeam","RapidFire","HitScan");
	HitScan:
		W5PD FE 5 Bright A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMindFlare",8,16,32,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMindFlare",8,-16,32,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("moloch/nailhitbleed",0);
		W5PD F 2 Bright A_CustomBulletAttack(random(2,15),0,random(1,2),random(1,2),"RS_WhiteMindFlare");
		W5PD F 0 A_CustomBulletAttack(random(2,15),0,random(1,2),random(1,2),"RS_WhiteMindFlare");
		W5PD E 1 A_MonsterRefire(64,"See");
		Goto HitScan+2;
	LowRange:
		TNT1 A 0 A_JumpIfHealthLower(5000,"Third");
		TNT1 A 0 A_JumpIfHealthLower(10000,"Second");
		TNT1 A 0 A_Jump(255,"RapidFire","EyeBeam","OrbShot","FloorCrack");
	Second:
		TNT1 A 0 A_Jump(255,"HitScan","OrbShot2","FloorCrack2","SpawnSentinel");
		Goto See;
	Third:
		TNT1 A 0 A_Jump(255,"HitScan","OrbShot3","FloorCrack3","SpawnSentinel");
		Goto See;
	OrbShot3:
		W5PD F 5 Bright;
		W5PD E 8 Bright ThrustThingZ(0,50,0,0);
		W5PD E 5 A_CustomMissile("RS_WhiteMindCrackleOrb",64,0,0);
		W5PD FEF 5 Bright A_CustomMissile("RS_WhiteMindCrackleOrb2",64,0,0);
		W5PD F 5 Bright;
		Goto See;
	FloorCrack3:
		W5PD F 5 Bright;
		W5PD E 15 Bright A_FaceTarget();
		W5PD F 5 Bright;
		TNT1 A 0 A_PlaySound("DSHADEXP",0);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,0);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,10);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-10);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,20);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-20);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,30);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-30);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,40);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-40);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,50);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-50);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,60);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-60);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,70);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-70);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,80);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-80);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,90);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-90);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,16,-92);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,-16,92);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,16,-32);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,-16,32);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,16,-62);
		W5PD F 5 A_CustomMissile("RS_WhiteSpidWinder",8,-16,62);
		Goto See;
	Dash:
		W5PD E 5 A_SkullAttack();
		W5PD AABBCCDD 2 A_SpawnItemEx("RS_WhiteSpidShade",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		W5PD F 5 A_Stop();
		TNT1 A 0 A_Jump(128,"Dodge1","Dodge2");
		Goto See;
	SpawnSentinel:
		W5PD F 5 Bright;
		W5PD E 8 Bright;
		W5PD E 15 A_DualPainAttack("RS_MiniSentinelSpider");
		W5PD E 10 A_DualPainAttack("RS_MiniSentinelSpider");
		W5PD E 5 A_DualPainAttack("RS_MiniSentinelSpider");
		W5PD E 5 A_DualPainAttack("RS_MiniSentinelSpider");
		W5PD F 5 Bright;
		TNT1 A 0 A_Jump(64,"RapidFire","OrbShot","FloorCrack");
		Goto See;
	FloorCrack:
		W5PD F 5 Bright;
		W5PD E 8 Bright ThrustThingZ(0,50,0,0);
		W5PD E 15;
		W5PD F 5 Bright;
		TNT1 A 0 A_PlaySound("DSHADEXP",0);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,16,-92);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,-16,92);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,16,-32);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,-16,32);
		TNT1 A 0 A_CustomMissile("RS_WhiteSpidWinder",8,16,-62);
		W5PD F 5 A_CustomMissile("RS_WhiteSpidWinder",8,-16,62);
		Goto See;
	FloorCrack2:
		W5PD F 5 Bright;
		W5PD E 10 A_FaceTarget();
		W5PD F 5 Bright;
		TNT1 A 0 A_PlaySound("DSHADEXP",0);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,0);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,10);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-10);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,20);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-20);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,30);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-30);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,40);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-40);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,50);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-50);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,60);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-60);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,70);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-70);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,80);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-80);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,90);
		TNT1 A 0 A_CustomMissile("RS_STracerWhiteSP",8,0,-90);
		Goto See;
	OrbShot2:
		TNT1 A 0 A_PlaySound("ELECFATT",0);
		W5PD FE 5 Bright A_FaceTarget();
		W5PD F 2 Bright A_CustomMissile("RS_WhiteMindCrackleOrb2",64,0,0);
		W5PD F 20;
		Goto See;
	OrbShot:
		TNT1 A 0 A_PlaySound("ELECFATT",0);
		W5PD FE 5 Bright A_FaceTarget();
		W5PD F 2 Bright A_CustomMissile("RS_WhiteMindCrackleOrb",64,0,0);
		W5PD F 20;
		Goto See;
	RapidFire:
		W5PD FE 5 Bright A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMindFlare",4,16,32,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMindFlare",4,-16,32,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("DEEPSHO1",0);
		W5PD F 2 Bright A_CustomMissile("RS_WhiteMindshot1",32,16,-1);
		W5PD F 0 A_CustomMissile("RS_WhiteMindshot1",32,-16,1);
		TNT1 A 0 A_PlaySound("DEEPSHO1",0);
		W5PD E 2 Bright A_CustomMissile("RS_WhiteMindshot1",32,16);
		W5PD F 0 A_CustomMissile("RS_WhiteMindshot1",32,-16);
		TNT1 A 0 A_PlaySound("DEEPSHO1",0);
		W5PD F 2 Bright A_CustomMissile("RS_WhiteMindshot1",32,16);
		W5PD F 0 A_CustomMissile("RS_WhiteMindshot1",32,-16);
		W5PD E 12 Bright A_FaceTarget();
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMindFlare",4,16,32,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_WhiteMindFlare",4,-16,32,0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("DEEPSHO1",0);
		W5PD F 2 Bright A_CustomMissile("RS_WhiteMindshot1",32,16,1);
		W5PD F 0 A_CustomMissile("RS_WhiteMindshot1",32,-16,-1);
		TNT1 A 0 A_PlaySound("DEEPSHO1",0);
		W5PD E 2 Bright A_CustomMissile("RS_WhiteMindshot1",32,16);
		W5PD F 0 A_CustomMissile("RS_WhiteMindshot1",32,-16);
		TNT1 A 0 A_PlaySound("DEEPSHO1",0);
		W5PD F 2 Bright A_CustomMissile("RS_WhiteMindshot1",32,16);
		W5PD F 0 A_CustomMissile("RS_WhiteMindshot1",32,-16);
		Goto See;
	EyeBeam:
		W5PD F 5 Bright A_FaceTarget();
		TNT1 A 0 A_PlaySound("ECHOIMPB",0);
		W5PD F 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		W5PD F 6 Bright A_CustomRailgun(0,0,"none","Blue",RGF_NOPIERCING);
		W5PD E 4 Bright A_CustomRailgun(random(10,40),0,"blue","blue",RGF_FULLBRIGHT|RGF_NORANDOMPUFFZ,0,0,"RS_WhiteMindRB3",0,0,0,66,0.7,0.9,"RS_WhiteMindRB4",7,10);
		W5PD F 20;
		Goto See;
	Pain:
		W5PD F 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		W5PD F 3 A_Pain();
		Goto Dodge1;
	Death:
		W5PD F 10 A_NoBlocking();
		W5PD FABDF 10 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		W5PD AFDCF 8 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		W5PD BFDCD 3 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		W5PD FFFFFFFFFFF 1 Bright A_CustomMissile("RS_HKRedDeath",random(20,100),random(-30,30),CMF_AIMOFFSET,2,-10);
		W5PD F 20 A_Scream();
		W5PD F 0 A_KillMaster("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		W5PD F 1 A_BossDeath();
		W5PD FFFFFFFFFFF 2 A_FadeOut(0.15);
		W5PD F -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White's drones. Summon -- NO tier token. CH MASTERMINDS.txt:5210.
// ---------------------------------------------------------------------------
class RS_MiniSentinelSpider : Actor   // CH MASTERMINDS.txt:5210
{
	Default
	{
		Health 70;
		PainChance 255;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "MMind";
		Speed 28;
		Radius 12;
		Height 26;
		Mass 300;
		Monster;
		+NOGRAVITY
		+DROPOFF
		+NOBLOOD
		+DONTHARMSPECIES
		+NOBLOCKMONST
		+INCOMBAT
		+MISSILEMORE
		+LOOKALLAROUND
		+NEVERRESPAWN
		SeeSound "";
		DeathSound "Crack/death";
		ActiveSound "";
		PainSound "prox/beep";
		Obituary "%o was vaporized by a mini sentinel";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_Shell", 64;
		DropItem "RS_CH_RocketAmmo", 42;
		DropItem "RS_CH_Cell", 12;
	}
	States
	{
	Spawn:
		MNDR A 10;
		Goto See;
	See:
		MNDR A 1 A_SentinelBob();
		MNDR A 2 A_Chase();
		Loop;
	Missile:
		MNDR A 4 A_FaceTarget();
		MNDR B 1 Bright A_CustomMissile("RS_DflarePE2",15,0,0);
		MNDR B 1 Bright A_CustomMissile("RS_DflarePE2",15,0,random(-3,3));
		MNDR B 1 Bright A_CustomMissile("RS_DflarePE2",15,0,random(-9,9));
		MNDR A 4;
		Goto See;
	Pain:
		MNDR A 5 A_Pain();
		Goto See;
	Death:
		MNDR C 7 Bright A_Fall();
		MNDR D 5 Bright A_Scream();
		MNDR E 5 Bright A_TossGib();
		MNDR F 5 Bright;
		MNDR G 5 Bright A_TossGib();
		MNDR HI 5 Bright;
		TNT1 A 0 A_Jump(32,"SpawnThing");
		TNT1 AAA 0 A_SpawnItemEx("RS_DeathBreathDI",random(-178,178),random(-178,178),random(-12,42),0,0,0,0,128,0);
		Stop;
	SpawnThing:
		TNT1 A 1 A_SpawnItemEx("ArchvileFire",0,0,3,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 2 A_SpawnItemEx("RS_RandomizerArc",0,0,6,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}
