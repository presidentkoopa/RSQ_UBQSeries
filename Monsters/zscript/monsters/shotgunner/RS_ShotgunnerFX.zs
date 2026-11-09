// ============================================================================
// RS_ShotgunnerFX.zs -- Colourful Hell Shotgunner family: support classes.
// Source of truth: C:\Users\Command\Desktop\CH (Shotgunners.txt read whole,
// 3,102 lines; externals pulled from DECORATE.txt / Gibs.txt / Barons.txt /
// Archviles.txt / Chaingunners.txt / CYBIES.txt / Imps.txt -- each class
// cites its CH file:line).
//
// Same import rules as the Zombieman (see RS_ZombiemanFX.zs header):
// native ZScript, rs_ch_* cvar gates, no announcers, no gore chain,
// no abstract, no DRLA, and now no LegenDoom either (the Benellus
// "LDLegendaryMonsterTransformed" easter gate is stripped the same way).
// Tier = RS_ZomTierToken via RS_Zom.SetTier(), the family-agnostic helpers
// that already live in RS_ZombiemanFX.zs. Shared classes reused from the
// zombieman import (read-only): RS_Zom, RS_ZomTierToken, RS_ColorTierIconCH*,
// RS_CHBoner, RS_CHAbyssMark, RS_GrowRaisin, RS_ThePlanBoner, RS_SplashAbyss,
// RS_SplashAbyss2, RS_AbyssZShotCH2, RS_IceZombieShot2, RS_HKRedDeath,
// RS_ShotgunWhere, RS_HealthBundle, RS_ArmorBundle, RS_BackPackBundle,
// RS_DropBaseAmmo, RS_DropBaseItem, RS_CH_Shell, RS_CH_Cell, RS_CH_Medikit,
// RS_CH_SuperShotgun.
//
// Dangling / silent by design, verbatim from CH:
//   * SGRN sprite (the gas grenade) ships NOWHERE in CH -- the nade is
//     invisible in CH itself; its GRENADETRAIL smoke is the visual.
//   * weapons/grenlf, weapons/grenlx, weapons/grbnce, weapons/rockx --
//     sound names CH never defines; silent in CH itself.
//   * ZPS1 -- CH's own typo for ZSP1 on a few 0-tic frames (BlackSG2).
//     Kept verbatim; renders nothing either way.
//
// Frame gaps closed 2026-08-06 (owner: visual consistency beats verbatim
// silence).  Both were CH writing frame letters past the end of a VANILLA
// sprite set -- the sets ship, the letters don't, in either IWAD:
//   * PLSS C D E -- PLSS ships A and B only (PLSSA0/PLSSB0); C/D/E are PLSE's
//     letters, not PLSS's.  CH wrote them on the SGLance chain (SGLance1
//     "ABCDE", SGLance5/2/3 "ABC") while its own SGLance4 correctly writes
//     "AB".  Remapped to the A/B flicker vanilla PlasmaBall itself loops.
//     Frame counts, tic counts and A_SpawnItemEx call counts all unchanged.
//   * PUFF E -- PUFF ships A B C D only.  RS_BrownSGshot's death tail
//     "PUFF DE 6" now holds D.  2 frames x 6 tics unchanged.
// ============================================================================

// ---------------------------------------------------------------------------
// Drop gates the shotgunners use that the zombieman didn't.
// CH: DECORATE.txt:277 / 293 / 325 / 433.
// ---------------------------------------------------------------------------
class RS_CH_ClipBox : RS_DropBaseAmmo   // CH DECORATE.txt:277
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("ClipBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("ClipBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("ClipBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_ShellBox : RS_DropBaseAmmo   // CH DECORATE.txt:293
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("ShellBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("ShellBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("ShellBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_CellPack : RS_DropBaseAmmo   // CH DECORATE.txt:325
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("CellPack",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("CellPack",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("CellPack",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_GreenArmor : RS_DropBaseArmor   // CH DECORATE.txt:433
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("GreenArmor",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("GreenArmor",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Keepsake props.  CH: Gibs.txt:81 (cactus, Benellus) / 131 (cirno, cyan).
// ---------------------------------------------------------------------------
class RS_CH_Cactus : Actor
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 5;
		Scale 1;
		Damage 0;
		Projectile;
		BounceType "Doom";        // CH: +DOOMBOUNCE
		+MOVEWITHSECTOR
		+CANNOTPUSH
		-NOGRAVITY
		+NOTONAUTOMAP
		BounceFactor 0.45;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 ThrustThingZ(0,65,0,1);
		Goto Wee;
	Wee:
		CACT ABAC random(3,6);
		Loop;
	Crash:
		CACT B -1;
		Stop;
	Death:
		CACT B -1;
		Stop;
	}
}

class RS_CH_Cirno : Actor
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 1;
		Scale 1;
		Damage 0;
		Projectile;
		+MOVEWITHSECTOR
		+CANNOTPUSH
		-NOGRAVITY
		+NOTONAUTOMAP
		Gravity 0.05;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 ThrustThingZ(0,5,0,1);
		Goto Wee;
	Wee:
		CIRN A 5;
		Loop;
	Crash:
		CIRN A -1;
		Stop;
	Death:
		CIRN A -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// External FX pulled from other CH family files.
// ---------------------------------------------------------------------------
class RS_Drt1 : Actor   // CH Barons.txt:4382 -- brown's dirt kick
{
	Default
	{
		Projectile;
		-NOGRAVITY
		-NOBLOCKMAP
		-NOTELEPORT
		+RANDOMIZE
		Radius 2;
		Damage 0;
		Speed 5;
	}
	States
	{
	Spawn:
		DIRT A 0 A_SetGravity(0.5);
		DIRT A 0 ThrustThingZ(0,15,0,1);
		Goto See;
	See:
		DIRT ABC 5;
		Loop;
	Death:
		DIRT JKL 3;
		Stop;
	}
}

class RS_SparkPuff1 : Actor   // CH Archviles.txt:3045 -- Benellus EX sparks
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+SPAWNFLOAT
		+NOINTERACTION
		RenderStyle "Add";
		Speed 1;
		Alpha 0.95;
		VSpeed 4;
		Mass 2;
	}
	States
	{
	Spawn:
		PUFF ABAB 4 Bright;
		Stop;
	}
}

class RS_DetoPuffCG : Actor   // CH Chaingunners.txt:1820 -- exploding pellet puff
{
	Default
	{
		+NOGRAVITY
		+ALLOWPARTICLES
		+RANDOMIZE
		+PUFFONACTORS
		+ALWAYSPUFF
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
		VSpeed 1;
		Scale 0.35;
		DamageType "Fire";
		SeeSound "weapons/firex4";
		Mass 5;
	}
	States
	{
	Spawn:
		MISL BC 4 Bright A_SetScale(0.35);
	Melee:
		MISL D 4 Bright A_Explode(random(2,6),42);
		MISL D 4 Bright;   // CH: MISL E -- vanilla MISL ships A-D only (verified in both IWAD lump directories); E is one letter past the end of the rocket explosion. Held D, its last real frame. Tics and actions unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_Gas14 : Actor   // CH CYBIES.txt:2326 -- the nade's poison cloud
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 0;
		FastSpeed 0;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Poison";
		Scale 0.8;
		Alpha 0.6;
	}
	States
	{
	Spawn:
		PSBG CDEFGHGF 4 Bright A_Explode(random(4,8),42);
		PSBG G 0 A_Jump(180,"Death");
		Loop;
	Death:
		PSBG CDEFGHI 6 Bright A_Explode(random(4,8),42);
		Stop;
	}
}

class RS_RedMessImp : Actor   // CH Imps.txt:1832
{
	Default
	{
		Radius 5;
		Height 5;
		Mass 7;
		Speed 4;
		Projectile;
		+THRUACTORS
		Scale 0.3;
		RenderStyle "Add";
		Alpha 0.5;
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 6;
		Goto Death;
	Death:
		BAL1 A 1 A_SetTranslucent(0.25);
		Stop;
	}
}

class RS_RedMessImp2 : Actor   // CH Imps.txt:1803
{
	Default
	{
		Radius 6;
		Height 8;
		Mass 5;
		Speed 11;
		Projectile;
		+SEEKERMISSILE
		Scale 0.55;
		RenderStyle "Add";
		DamageFunction (random(2,19));
		DamageType "Fire";
		Alpha 0.95;
		SeeSound "imp/attack";
		DeathSound "weapons/firex4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 A 1 A_SeekerMissile(3,5);
		BAL1 B 1 A_CustomMissile("RS_RedMessImp",2,0,random(-180,180));
		BAL1 A 1 A_Weave(1,1,2,1);
		Loop;
	Death:
		BAL1 CDE 1 A_SetTranslucent(0.35);
		Stop;
	}
}

class RS_RedMessImp3 : RS_RedMessImp2   // CH Shotgunners.txt:1538
{
	Default
	{
		Speed 48;
		Scale 0.35;
	}
	States
	{
	Spawn:
		BAL1 A 1 A_CustomMissile("RS_RedMessImp",2,0,random(-180,180),0,random(-180,180));
		BAL1 B 1 A_CustomMissile("RS_RedMessImp",2,0,random(-180,180),0,random(-180,180));
		Loop;
	Death:
		BAL1 CCCCCCCCCCCCCCC 0 A_CustomMissile("RS_RedMessImp",2,0,random(-180,180),0,random(-180,180));
		BAL1 CDE 1 A_SetTranslucent(0.35);
		Stop;
	}
}

class RS_FireSGguy : Actor   // CH Shotgunners.txt:784 -- fireblu's flame shot
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 21;
		FastSpeed 26;
		DamageFunction (random(5,15));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200","160:160=177:177","162:162=184:184","163:163=204:204","164:164=186:186","165:165=204:204","166:166=189:189","167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 2 Bright;
		Goto Death;
	Death:
		FIRE CDEEDCDE 3 A_Explode(random(3,15),64);
		FIRE FGH 3 Bright A_Explode(random(3,15),64);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The family's own projectiles and puffs.  CH: Shotgunners.txt.
// ---------------------------------------------------------------------------
class RS_BrownSGshot : Actor   // CH Shotgunners.txt:163
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 64;
		DamageFunction (random(1,5));
		Projectile;
		+DONTBLAST
		+DONTTHRUST
		RenderStyle "Add";
		Alpha 0.85;
		Scale 1;
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		TNT1 A 5 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_Stop;
		PUFF C 6 Bright;
		TNT1 A 0 A_Blast(BF_NOIMPACTDAMAGE,128,32,20.0);
		PUFF DD 6 Bright;   // CH: PUFF E -- E is not a vanilla frame; PUFF ships A B C D only (doom.wad and doom2.wad both, PUFFA0-PUFFD0). Held D, the frame before it, so the smoke tail finishes instead of 6 blank tics. 2 frames x 6 tics unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_RedDotSGPuff : BulletPuff   // CH Shotgunners.txt:492
{
	Default
	{
		+NOBLOOD
		+PAINLESS
		+ALWAYSPUFF
		Translation "0:255=175:191";
		Scale 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Melee:
	Death:
		PUFF A 6;
		Stop;
	}
}

class RS_CyanSGPuff : BulletPuff   // CH Shotgunners.txt:510
{
	Default
	{
		DeathSound "Ice/Hit2";
	}
	States
	{
	Spawn:
		TNT1 A 1;
	Melee:
	Death:
		TNT1 A 0;
		TNT1 A 0 A_Scream;
		TNT1 AAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_SGshot1 : Actor   // CH Shotgunners.txt:1006 -- green's plasma pellet
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 55;
		FastSpeed 80;
		DamageFunction (random(2,6));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.15;
		DeathSound "imp/shotx";
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Loop;
	Death:
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_SGLance1 : Actor   // CH Shotgunners.txt:1145 -- blue's plasma lance
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 20;
		Damage 1;
		Projectile;
		+RIPPER
		+STRIFEDAMAGE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.3;
		SeeSound "weapons/plasmax";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		PLSS ABABA 2 Bright A_SpawnItemEx("RS_SGLance2",0,0,1,4);   // CH: PLSS C D E -- not vanilla frames; PLSS ships A B only (doom.wad and doom2.wad both, PLSSA0/PLSSB0 -- C D E belong to PLSE). Continued the A/B flicker that vanilla PlasmaBall and CH's own SGLance4 use. 5 frames x 2 tics = 10 tics and 5 A_SpawnItemEx calls, both unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Death;
	Death:
		PLSE E 1 Bright A_SpawnItemEx("RS_SGLance5",0,0,1,4);
		Stop;
	}
}

class RS_SGLance5 : Actor   // CH Shotgunners.txt:1174
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 1;
		Damage 1;
		Projectile;
		+RIPPER
		RenderStyle "Add";
		Alpha 1.25;
		Scale 1.5;
		SeeSound "weapons/plasmax";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSS ABA 2 Bright;   // CH: PLSS C -- not a vanilla frame; PLSS ships A B only. Continued the A/B flicker. 3 frames x 2 tics = 6 tics unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Death;
	Death:
		PLSE DCE 2 Bright A_Explode(random(2,8),32);
		Stop;
	}
}

class RS_SGLance2 : RS_SGLance1   // CH Shotgunners.txt:1200
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 1;
		DamageFunction (random(0,1));
		Projectile;
		-RIPPER
		Alpha 0.75;
		Scale 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		PLSS ABA 2 Bright A_SpawnItemEx("RS_SGLance3",0,0,1,3);   // CH: PLSS C -- not a vanilla frame; PLSS ships A B only. Continued the A/B flicker. 3 frames x 2 tics = 6 tics and 3 A_SpawnItemEx calls, both unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Death;
	Death:
		PLSE DE 2 Bright;
		Stop;
	}
}

class RS_SGLance3 : RS_SGLance2   // CH Shotgunners.txt:1225
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 1;
		Projectile;
		Alpha 0.75;
		Scale 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		PLSS ABA 2 Bright A_SpawnItemEx("RS_SGLance4",0,0,1,3);   // CH: PLSS C -- not a vanilla frame; PLSS ships A B only. Continued the A/B flicker. 3 frames x 2 tics = 6 tics and 3 A_SpawnItemEx calls, both unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Death;
	Death:
		PLSE DE 1 Bright;
		Stop;
	}
}

class RS_SGLance4 : RS_SGLance2   // CH Shotgunners.txt:1248
{
	Default
	{
		Scale 0.45;
	}
	States
	{
	Spawn:
		PLSS AB 2 Bright;
		Goto Death;
	Death:
		PLSE ABCDE 2 Bright;
		Stop;
	}
}

class RS_Purpfire2 : Actor   // CH Shotgunners.txt:1375 -- purple's flame bolt
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 16;
		DamageFunction (random(5,10));
		DamageType "Fire";
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
		Scale 1.1;
		SeeSound "fire/fire1";
		DeathSound "Imp/shotx";
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		PFIR ABCD 5 Bright A_Explode(random(3,10),20);
		Goto Death;
	Death:
		PFIR EFFG 5 Bright A_Explode(random(3,10),20);
		Stop;
	}
}

class RS_SGGasNade : Actor   // CH Shotgunners.txt:1674 -- gas grenade.
// SGRN ships nowhere in CH: invisible in flight there too; the trail shows.
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 25;
		DamageFunction (random(20,75));
		Projectile;
		-NOGRAVITY
		+GRENADETRAIL
		BounceType "Doom";
		Gravity 0.29;
		SeeSound "weapons/grenlf";    // undefined in CH's SNDINFO -- silent there too
		DeathSound "weapons/grenlx";  // undefined in CH's SNDINFO -- silent there too
		BounceSound "weapons/grbnce"; // undefined in CH's SNDINFO -- silent there too
		DamageType "Fire";
	}
	States
	{
	Spawn:
		HGRN A 1 Bright;   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 1 Bright A_Jump(8,"Bounce");   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 1 Bright A_Jump(4,"Death");   // CH: SGRN -- CH typo; HGRN is the real prefix (only *GRN* art in CH, a grenade sprite). Fixed 2026-08-06 (owner: nothing invisible).
		Loop;
	Bounce:
		HGRN A 2 Bright ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),12,0,0)
		Goto Spawn;
	Death:
		MISL B 8 Bright A_Explode(random(20,50),128);
		MISL CCCC 2 Bright A_SpawnItemEx("RS_Gas14",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL DDDD 2 Bright A_SpawnItemEx("RS_Gas14",random(-220,220),random(-220,220),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL DDDDDD 0 A_SpawnItemEx("RS_Gas14",random(-280,280),random(-280,280),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_DetoPuffCG2 : Actor   // CH Shotgunners.txt:1709 -- the sniper mark detonation
{
	Default
	{
		Projectile;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.55;
		Height 1;
		Radius 2;
		Mass 1;
		DamageType "Fire";
		SeeSound "weapons/firex4";
	}
	States
	{
	Spawn:
		MISL BC 1 Bright;
		Goto Death;
	Death:
		MISL D 4 Bright A_Explode(random(12,36),42);
		MISL D 4 Bright A_Burst("RS_PufFCHBS");   // CH: MISL E -- vanilla MISL ships A-D only (verified in both IWAD lump directories); E is one letter past the end of the rocket explosion. Held D, its last real frame. Tics and actions unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_AirStrikeCHBS : Actor   // CH Shotgunners.txt:1732 -- the airstrike carrier
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 28;
		Mass 50;
		DamageFunction (random(5,40));
		DamageType "Fire";
		Projectile;
		+CEILINGHUGGER
		+FLOAT
		+NOGRAVITY
		RenderStyle "Add";
		Gravity 7;
		Alpha 0.35;
		Scale 0.5;
		SeeSound "caco/attack";
		DeathSound "fire/fire5";
	}
	States
	{
	Spawn:
		HEAD DD 2 Bright A_SpawnItemEx("RS_MissileCHBS",random(-80,80),random(-80,80),-32,random(-10,13),random(-10,25),1,SXF_NOCHECKPOSITION);
		HEAD DD 3 Bright A_SpawnItemEx("RS_MissileCHBS",random(-200,200),random(-200,200),-32,random(-10,13),random(-10,25),1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(10,40),108);
		BBOM EFG 6 Bright A_Explode(random(10,45),108);
		Stop;
	}
}

class RS_MissileCHBS : Actor   // CH Shotgunners.txt:1766 -- the falling ordnance
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 10;
		DamageFunction (random(10,50));
		DamageType "Fire";
		Projectile;
		-NOGRAVITY
		Gravity 1.5;
		Scale 0.7;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/homingexplode";
		DropItem "Shell", 12;
	}
	States
	{
	Spawn:
		MSLH A 2 Bright;
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		MISL B 4 Bright A_Explode(random(5,40),98);
		MISL C 5 Bright;
		MISL D 6 Bright A_Burst("RS_PufFCHBS");
		Stop;
	}
}

class RS_PufFCHBS : Actor   // CH Shotgunners.txt:1794
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		Projectile;
		Speed 8;
		DamageFunction (random(0,1));
		RenderStyle "Add";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		SMK2 ABCDE 2;
		Stop;
	}
}

class RS_CHBSTarget : Actor   // CH Shotgunners.txt:1813 -- airstrike target marker
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		Speed 1;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 1.1;
	}
	States
	{
	Spawn:
		CHTA A 3 Bright;
		TNT1 A 3 Bright;
		Goto Fly;
	Fly:
		CHTA A 4 Bright A_PlaySound("prox/beep",7,2,false,ATTN_NONE);
		TNT1 A 4 Bright;
		CHTA A 4 Bright;
		TNT1 A 4 Bright A_PlaySound("prox/beep",7,2,false,ATTN_NONE);
		CHTA A 4 Bright;
		TNT1 A 3 Bright;
		CHTA A 3 Bright;
		TNT1 A 3 Bright;
		Stop;
	}
}

class RS_MineShotgun : Actor   // CH Shotgunners.txt:2473 -- Benellus's bouncing gift
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 20;
		DamageFunction (random(10,50));
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Projectile;
		DamageType "Fire";
		-NOGRAVITY
		+BOUNCEONWALLS
		+THRUGHOST
		Gravity 0.9;
		BounceType "Doom";
		BounceCount 11;
		BounceFactor 0.75;
		WallBounceFactor 1.2;
		SeeSound "weapons/sshotl";
		BounceSound "weapons/sshotl";
		DeathSound "weapons/rockx";   // undefined in CH's SNDINFO -- silent there too
	}
	States
	{
	Spawn:
		SHOT A 1 Bright A_SetScale(1.15);
		SHOT A 1 Bright A_SetScale(1.3);
		SHOT A 0 A_Jump(6,"Death");
		SHOT A 0 A_Jump(32,"Bounce");
		SHOT A 1 Bright A_SetScale(1.15);
		SHOT A 1 Bright A_SetScale(1);
		Loop;
	Bounce:
		SHOT A 2 Bright ThrustThing(int(angle*256/(random(1,360))),15,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),15,0,0)
		Goto Spawn;
	Death:
		MISL BCD 5 Bright A_Explode(random(5,50),128);
		Stop;
	}
}

class RS_SGBurst : Actor   // CH Shotgunners.txt:2513 -- the shotgun rain
{
	Default
	{
		Mass 5;
		Alpha 0.01;
		Speed 18;
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Goto Death;
	Death:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("Shotgun",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAA 1 A_SpawnItemEx("Shotgun",random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80),random(-80,80));
		TNT1 A 1 A_Burst("Shotgun");
		Stop;
	}
}

class RS_SparkShieldBen : Actor   // CH Shotgunners.txt:3059
{
	Default
	{
		+NOGRAVITY
		+SPAWNFLOAT
		+NOINTERACTION
		RenderStyle "Add";
		Speed 1;
		Alpha 0.95;
		Scale 1.33;
		Mass 2;
	}
	States
	{
	Spawn:
		PUFF ABABABAB 10 Bright;
		PUFF BBB 5 A_FadeOut(0.33);
		Stop;
	}
}

class RS_SparkFireBen : Actor   // CH Shotgunners.txt:3079
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 55;
		FastSpeed 80;
		DamageFunction (random(6,12));
		Projectile;
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.15;
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		PUFF AB 1 Bright A_SpawnItemEx("RS_SparkPuff1",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 AAAAAAAAAAAA 0 A_SpawnItemEx("RS_SparkPuff1",0,0,0,random(-3,3),random(-3,3),random(-3,3),random(-358,358),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Benellus shrine / punisher menagerie.  CH: Shotgunners.txt:2783-3057.
// ---------------------------------------------------------------------------
class RS_ShotgunShrine : Actor   // CH Shotgunners.txt:2783
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 8;
		Health 800;
		Monster;
		+NOTRIGGER
		+MISSILEMORE
		+MISSILEEVENMORE
		+THRUSPECIES
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+NOTARGETSWITCH
		+NOCLIP
		Species "BENE";
		SeeSound "weapons/sshotl";
		DeathSound "weapons/rockx";   // undefined in CH's SNDINFO -- silent there too
		DropItem "RS_CH_Shell";
		DropItem "Shotgun";
		DropItem "Shotgun";
		DropItem "Shotgun";
	}
	States
	{
	Spawn:
		BENE M 2 Bright A_SetScale(1.0,0.1);
		BENE M 2 Bright A_SetScale(1.0,0.4);
		BENE M 2 Bright A_SetScale(1.0,0.7);
		BENE M 2 Bright A_SetScale(1.0,1.0);
	Idle:
		BENE MNOP 6 A_Chase;
		Loop;
	Missile:
		BENE M 6 A_FaceTarget;
		BENE M 6 Bright;
	Nuts:
		BENE Q 1 Bright A_PlaySound("shotguy/attack",0);
		BENE QRQRQRQR 1 Bright A_CustomMissile("RS_SparkFireBen",84,0,random(-3,3));
		TNT1 A 0 A_DamageSelf(50);   // CH: damagething(50)
		Loop;
	Death:
		BENE M 2 Bright A_SetScale(0.8,1.0);
		BENE M 2 Bright A_SetScale(0.5,1.2);
		BENE M 2 Bright A_SetScale(0.3,1.5);
		BENE M 2 Bright A_SetScale(0.1,1.8);
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Fall;
		MISL BCD 5 Bright A_Explode(random(5,15),128);
		TNT1 AA 0 A_CustomMissile("RS_MineShotgun",random(20,60),random(-15,15),random(-20,20),0);
		Stop;
	}
}

class RS_Shotgunpunishernerfed : Actor   // CH Shotgunners.txt:2837
{
	Default
	{
		Speed 1;
		Projectile;
		+NOCLIP
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunPunishNerf",0,128,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		TNT1 A 1 Bright A_SpawnItemEx("RS_ShotgunPunishNerf2",0,-128,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_ShotgunPunish : Actor   // CH Shotgunners.txt:2856
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		Health 300;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Monster;
		+NOTRIGGER
		+NOCLIP
		-COUNTKILL
		SeeSound "weapons/sshotl";
		DeathSound "weapons/rockx";   // undefined in CH's SNDINFO -- silent there too
	}
	States
	{
	Spawn:
		SHOT A 2 Bright A_SetScale(0.8,0.3);
		SHOT A 2 Bright A_SetScale(1.3,0.6);
		SHOT A 4 Bright A_SetScale(1.6,0.9);
		SHOT A 4 Bright A_SetScale(1.2,1.1);
		SHOT A 4 Bright A_SetScale(1.0,1.0);
		SHOT A 3 Bright A_SetScale(1.3,0.6);
	Shoot:
		SHOT A 0 A_FaceTarget;
		SHOT A 13 Bright;
		SHOT A 4 Bright A_PlaySound("weapons/sshotf");
		SHOT A 4 Bright A_SetScale(1.3,0.6);
		SHOT A 6 Bright A_CustomBulletAttack(7,5,random(3,10),random(1,6),"BulletPuff",0);
		SHOT A 4 Bright A_SetScale(1.0,1.0);
		Goto Death;
	Death:
		SHOT A 3 Bright A_SetScale(0.7,0.7);
		SHOT A 3 Bright A_SetScale(0.4,0.4);
		SHOT A 3 Bright A_SetScale(0.1,0.1);
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Scream;
		MISL BCD 5 Bright A_Explode(random(5,15),64);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_ShotgunPunish2 : Actor   // CH Shotgunners.txt:2899
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		Health 300;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Monster;
		+NOTRIGGER
		+NOCLIP
		-COUNTKILL
		SeeSound "weapons/sshotl";
		DeathSound "weapons/rockx";   // undefined in CH's SNDINFO -- silent there too
	}
	States
	{
	Spawn:
		SHOT A 2 Bright A_SetScale(-0.8,0.3);
		SHOT A 4 Bright A_SetScale(-1.3,0.6);
		SHOT A 4 Bright A_SetScale(-1.6,0.9);
		SHOT A 4 Bright A_SetScale(-1.2,1.1);
		SHOT A 3 Bright A_SetScale(-1.0,1.0);
	Shoot:
		SHOT A 0 A_FaceTarget;
		SHOT A 13 Bright;
		SHOT A 4 Bright A_PlaySound("weapons/sshotf");
		SHOT A 4 Bright A_SetScale(-1.3,0.6);
		SHOT A 6 Bright A_CustomBulletAttack(7,5,random(3,10),random(1,6),"BulletPuff",0);
		SHOT A 3 Bright A_SetScale(-1.0,1.0);
		Goto Death;
	Death:
		SHOT A 3 Bright A_SetScale(-0.7,0.7);
		SHOT A 3 Bright A_SetScale(-0.4,0.4);
		SHOT A 3 Bright A_SetScale(-0.1,0.1);
		TNT1 A 0 A_Scream;
		MISL BCD 5 Bright A_Explode(random(5,15),64);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_Shotgunpunisher : Actor   // CH Shotgunners.txt:2940
{
	Default
	{
		Speed 1;
		Projectile;
		+NOCLIP
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunPunish",0,128,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		TNT1 A 1 Bright A_SpawnItemEx("RS_ShotgunPunish2",0,-128,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_ShotgunPunishnerf : Actor   // CH Shotgunners.txt:2959
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		Health 300;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Monster;
		+NOTRIGGER
		+NOCLIP
		SeeSound "weapons/sshotl";
		DeathSound "weapons/rockx";   // undefined in CH's SNDINFO -- silent there too
	}
	States
	{
	Spawn:
		SHOT A 6 Bright A_SetScale(0.8,0.3);
		SHOT A 6 Bright A_SetScale(1.3,0.6);
		SHOT A 6 Bright A_SetScale(1.6,0.9);
		SHOT A 6 Bright A_SetScale(1.2,1.1);
		SHOT A 6 Bright A_SetScale(1.0,1.0);
		SHOT A 6 Bright A_SetScale(1.3,0.6);
	Shoot:
		SHOT A 0 A_FaceTarget;
		SHOT A 18 Bright;
		SHOT A 4 Bright A_PlaySound("weapons/sshotf");
		SHOT A 4 Bright A_SetScale(1.3,0.6);
		SHOT A 6 Bright A_CustomBulletAttack(7,5,random(1,7),random(1,5),"BulletPuff",0);
		SHOT A 4 Bright A_SetScale(1.0,1.0);
		Goto Death;
	Death:
		SHOT A 3 Bright A_SetScale(0.7,0.7);
		SHOT A 3 Bright A_SetScale(0.4,0.4);
		SHOT A 3 Bright A_SetScale(0.1,0.1);
		TNT1 A 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_Scream;
		MISL BCD 5 Bright A_Explode(random(5,15),64);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_ShotgunPunishnerf2 : Actor   // CH Shotgunners.txt:3001
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		Health 300;
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Monster;
		+NOTRIGGER
		+NOCLIP
		SeeSound "weapons/sshotl";
		DeathSound "weapons/rockx";   // undefined in CH's SNDINFO -- silent there too
	}
	States
	{
	Spawn:
		SHOT A 6 Bright A_SetScale(-0.8,0.3);
		SHOT A 6 Bright A_SetScale(-1.3,0.6);
		SHOT A 6 Bright A_SetScale(-1.6,0.9);
		SHOT A 6 Bright A_SetScale(-1.2,1.1);
		SHOT A 6 Bright A_SetScale(-1.0,1.0);
	Shoot:
		SHOT A 0 A_FaceTarget;
		SHOT A 18 Bright;
		SHOT A 4 Bright A_PlaySound("weapons/sshotf");
		SHOT A 4 Bright A_SetScale(-1.3,0.6);
		SHOT A 6 Bright A_CustomBulletAttack(7,5,random(1,7),random(1,5),"BulletPuff",0);
		SHOT A 3 Bright A_SetScale(-1.0,1.0);
		Goto Death;
	Death:
		SHOT A 3 Bright A_SetScale(-0.7,0.7);
		SHOT A 3 Bright A_SetScale(-0.4,0.4);
		SHOT A 3 Bright A_SetScale(-0.1,0.1);
		TNT1 A 0 A_Scream;
		MISL BCD 5 Bright A_Explode(random(5,15),64);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_Shotgunpunisher2 : Actor   // CH Shotgunners.txt:3041
{
	Default
	{
		Speed 1;
		Projectile;
		+NOCLIP
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_ShotgunShrine",0,178,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		TNT1 A 1 Bright A_SpawnItemEx("RS_ShotgunShrine",0,-178,12,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Tokens.  CH: Shotgunners.txt:1536, 2241-2296.
// ---------------------------------------------------------------------------
class RS_ASGZAmmo : Ammo { Default { Inventory.MaxAmount 16; } }   // CH Shotgunners.txt:1536

// The spec-ops squad brain: rolled once per See re-entry, hands the troop
// one of five stances.  CH: Shotgunners.txt:2241.
class RS_ZSpecOpsSGSitRep : CustomInventory
{
	Default
	{
		Inventory.MaxAmount 0;
		+INVENTORY.AUTOACTIVATE
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Fail;
	Use:
		TNT1 A 0 A_JumpIfHealthLower(50,"LowHealth");
		TNT1 A 0 A_CheckSight("OutOfSight");
		TNT1 A 0 A_JumpIfCloser(384,"Close");
	ChecksFailed:
		TNT1 A 0 A_Jump(256,"AggressiveMode","SprintMode");
	LowHealth:
		TNT1 A 0 A_CheckSight("LowHealthOutOfSight");
		TNT1 A 0 A_JumpIfCloser(768,"LowHealthClose");
		TNT1 A 0 A_Jump(256,"SprintMode","BerserkMode");
	LowHealthOutOfSight:
		TNT1 A 0 A_JumpIfCloser(768,"LowHealthOutOfSightClose");
		TNT1 A 0 A_Jump(256,"SprintMode","CreepMode");
	LowHealthOutOfSightClose:
		TNT1 A 0 A_Jump(256,"CreepMode","AggressiveMode","BerserkMode");
	LowHealthClose:
		TNT1 A 0 A_Jump(256,"BerserkMode","AggressiveMode");
	OutOfSight:
		TNT1 A 0 A_JumpIfCloser(384,"OutOfSightClose");
		TNT1 A 0 A_Jump(256,"AggressiveMode","WanderMode","CreepMode");
	OutOfSightClose:
		TNT1 A 0 A_Jump(256,"AggressiveMode","CreepMode");
	Close:
		TNT1 A 0 A_Jump(256,"AggressiveMode");
	AggressiveMode:
		TNT1 A 0 A_GiveInventory("RS_ZSpecOpAggressive",1);
		Stop;
	SprintMode:
		TNT1 A 0 A_GiveInventory("RS_ZSpecOpSprint",1);
		Stop;
	WanderMode:
		TNT1 A 0 A_GiveInventory("RS_ZSpecOpWander",1);
		Stop;
	CreepMode:
		TNT1 A 0 A_GiveInventory("RS_ZSpecOpCreep",1);
		Stop;
	BerserkMode:
		TNT1 A 0 A_GiveInventory("RS_ZSpecOpBerserk",1);
		Stop;
	}
}

class RS_ZSpecOpAggressive : Inventory { Default { Inventory.MaxAmount 1; } }
class RS_ZSpecOpSprint : Inventory { Default { Inventory.MaxAmount 1; } }
class RS_ZSpecOpWander : Inventory { Default { Inventory.MaxAmount 1; } }
class RS_ZSpecOpCreep : Inventory { Default { Inventory.MaxAmount 1; } }
class RS_ZSpecOpBerserk : Inventory { Default { Inventory.MaxAmount 1; } }
