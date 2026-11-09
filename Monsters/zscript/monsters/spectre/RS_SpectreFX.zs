// ============================================================================
// RS_SpectreFX.zs -- Colourful Hell Spectre family: support classes.
// Source of truth: C:\Users\Command\Desktop\CH (spectres.txt read whole,
// 1,722 lines; externals from Cacodemons.txt / thepains.txt -- each class
// cites its CH file:line).
//
// Same import rules as the other families (see RS_ZombiemanFX.zs header).
// Shared classes reused read-only: RS_Zom, icons, tokens, bundles,
// RS_SplashAbyss, RS_Drt1/2/3, RS_EffectHK, RS_BrownImpCommand,
// RS_CH_* drop gates, RS_CH_Cirno, RS_CH_Pantsu.
//
// PARALLEL-LANE NOTE (2026-08-05): the Demons family is importing
// simultaneously into zscript/monsters/demon/. Classes Demons.txt also
// references or defines are the demons lane's to define and are only
// REFERENCED here: RS_AbyssDemon2, RS_FireBluDemon2, RS_BloodDemonArm,
// RS_BloodDemonArm2, RS_RedThingsLS, RS_SpikeCyanRev -- and
// RS_RedDemonBloodBolt3, which CH defines at spectres.txt:1031 but which
// Demons.txt:239 also fires (ownership rule: the demons lane owns every
// class Demons.txt references, so its body ships from the demons lane).
//
// The white boss's pack-buff is CH's ACS speed buff (CHSett.acs:317
// "PESPEED"), rebuilt native here per the owner's standing order
// ("break up the ACS yourself"): RS_SpeedBuffPE -> RS_PESpeedCtl.
//
// Dangling / silent by design, verbatim from CH:
//   * SLGM F -- RESOLVED 2026-08-06, no longer in this list. It was never
//     missing: the art sat uncopied at
//     E:\New folder\ART SOURCE\SPRITES\spectre\SLGMF0^0, a mirrored lump
//     ("SLGM" + "F0" + "^0") that defines frame F rot 0 AND frame "\" rot 0
//     -- "^" being GZDoom's on-disk escape for the backslash frame, the same
//     convention as VILE^1.lmp. It is the only caret-named CH sprite in the
//     whole tree, which is why every earlier pass missed it: the folder rips
//     at CH\sprites\trashmon drop it, the extractor-flattening failure
//     CLAUDE.md already records for the archvile. Copied to
//     sprites/rs_spectre/SLGMF0^0.png and both walk/PeekUp sites in
//     RS_Spectre.zs restored to CH verbatim. DO NOT "correct" the "^".
//   * SLGM "\" (white boss's PeekUp hold) -- the lump above supplies this
//     frame too, but it is left as a TNT1 hold of equal duration: a quoted
//     frame string containing an escaped backslash is a PARSE ERROR on this
//     engine build (the spectre lane hit it). Art is present if anyone finds
//     a syntax that compiles; the hold is deliberate, not a gap.
//   * SPG2 G -- RESOLVED 2026-08-06, no longer in this list. It was an SRG2
//     typo in CH, proven by the twin line in the demon file: Demons.txt:1516
//     writes `SRG2 G 1 A_SetUserVar("User_Calm",User_Calm == 1)` where
//     spectres.txt:881 writes `SPG2 G 1` with identical frame, tics and
//     action arguments -- the spectre file is a copy of the demon file and
//     mistyped SR as SP. Fixed at RS_Spectre.zs (owner: nothing invisible).
//   * Worm/Death and Worm/Hurt map to lumps DEATH / HIT, which exist
//     nowhere in CH's tree (or ours). Silent in CH, silent here, entries
//     kept verbatim. (Shadow/active and Shadow/pain DO resolve: their
//     $random members act1/act2/pain1/pain2 chain on to SHDACT*/SHDPAIN*
//     lumps, shipped by an earlier family.)
// ============================================================================

// ---------------------------------------------------------------------------
// The pack speed-buff.  CH: thepains.txt:3046 (the CustomInventory) +
// CHSett.acs:317 (the script).  ACS did: skip bosses; force ALWAYSFAST;
// +10 speed; hold 600 tics; restore.  (CH's revert unsets ALWAYSFAST even
// when the monster spawned with it -- the remembered-flag revert below is
// the same fix the imp family's RS_BrownImpBuffCtl uses.)
// ---------------------------------------------------------------------------
class RS_SpeedBuffPE : CustomInventory   // CH thepains.txt:3046
{
	Default
	{
		Radius 20;
		Height 16;
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
	}
	States
	{
	Pickup:
	Use:
		TNT1 A 0 { if (!bBOSS) A_SpawnItemEx("RS_PESpeedCtl",0,0,0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION); }
		Stop;
	}
}

class RS_PESpeedCtl : Actor   // native rebuild of CHSett.acs:317 "PESPEED"
{
	double prevSpeed;
	bool setFast;
	bool applied;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
	}

	void RS_ApplyBuff()
	{
		let m = master;
		if (!m || m.bBOSS || m.Health <= 0) return;
		prevSpeed = m.Speed;
		if (!m.bALWAYSFAST) { m.bALWAYSFAST = true; setFast = true; }
		m.Speed = prevSpeed + 10;   // CH: SetActorProperty(0,APROP_SPEED,normal+10)
		applied = true;
	}

	void RS_RevertBuff()
	{
		let m = master;
		if (!applied || !m) return;
		m.Speed = prevSpeed;
		if (setFast) m.bALWAYSFAST = false;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.RS_ApplyBuff(); }
		TNT1 A 600;   // CH: delay(600)
		TNT1 A 0 { invoker.RS_RevertBuff(); }
		Stop;
	}
}

// ---------------------------------------------------------------------------
// External FX pulled from other CH family files.
// ---------------------------------------------------------------------------
class RS_MediCacoBrown : Actor   // CH Cacodemons.txt:148 -- brown's healing motes
{
	Default
	{
		Radius 2;
		Height 2;
		Mass 7;
		Speed 4;
		Projectile;
		+THRUACTORS
		Scale 0.45;
		RenderStyle "Add";
		Alpha 0.33;
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_MediCacoBrown2",0,-4,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_MediCacoBrown2",0,4,0,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_MediCacoBrown2",0,0,-4,0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_MediCacoBrown2",0,0,4,0,0,0,0);
		BAL1 AB 6;
		Goto Death;
	Death:
		BAL1 A 1 A_SetTranslucent(0.1);
		Stop;
	}
}

class RS_MediCacoBrown2 : Actor   // CH Cacodemons.txt:177
{
	Default
	{
		Radius 2;
		Height 2;
		Mass 7;
		Speed 4;
		Projectile;
		+THRUACTORS
		Scale 0.45;
		RenderStyle "Add";
		Alpha 0.33;
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 7;
		Goto Death;
	Death:
		BAL1 A 1 A_SetTranslucent(0.1);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The family's own projectiles and props.  CH: spectres.txt.
// ---------------------------------------------------------------------------
class RS_IceOrbCH2 : Actor   // CH spectres.txt:467 -- gray's bouncing ice orb
{
	Default
	{
		ProjectileKickBack 1999;
		Radius 8;
		Height 8;
		Speed 15;
		DamageFunction (random(11,33));
		DamageType "Melee";
		Projectile;
		+SEEKERMISSILE
		+BOUNCEONFLOORS
		+USEBOUNCESTATE
		BounceType "Doom";
		BounceCount 25;
		BounceFactor 1.0;
		WallBounceFactor 1.0;
		Scale 1.25;
		SeeSound "ice/Cast";
		DeathSound "skeleton/melee";
		BounceSound "jam/jamd";
		WeaveIndexXY 12;
		WeaveIndexZ 12;
		Translation "0:255=%[0.31,0.23,0.18]:[1.10,0.74,0.40]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 1 Bright A_SeekerMissile(4,4);
		ICEY A 1 Bright A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),0,32);
		ICEY B 1 Bright A_Weave(2,3,5,4);
		ICEY B 1 Bright A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),0,32);
		ICEY C 1 Bright A_CStaffMissileSlither;
		ICEY C 1 Bright A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),0,32);
		Loop;
	Bounce.Floor:
		ROSX R 0 A_SpawnItemEx("RS_Drt1",0,0,0,5,0,3,random(0,360),0,128);
		ROSX R 0 A_SpawnItemEx("RS_Drt2",0,0,0,5,0,3,random(0,360),0,128);
		ROSX R 0 A_SpawnItemEx("RS_Drt3",0,0,0,5,0,3,random(0,360),0,128);
		Goto Fly;
	Death:
		ICEY FGHI 5 Bright A_Explode(random(5,12),32);
		Stop;
	}
}

// --- Black boss kit.  CH: spectres.txt:1230-1387 ---------------------------
class RS_TeleporterSpotSH : SpecialSpot   // CH spectres.txt:1230 -- the blink anchor
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 128;
		Mass 25;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		+INVISIBLE
		BounceCount 999;
		BounceType "Doom";
		DamageType "Fire";
		BounceFactor 1;
		WallBounceFactor 1.5;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.8;
		YScale 0.5;
		XScale 1.2;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_implyingclip", 128;
	}
	States
	{
	Spawn:
		RED8 ABCCCCCCFGHHHHHH 1 Bright A_Wander;
		RED8 D 0 A_Jump(32,"Death");
		Loop;
	Death:
		RED8 ABCD 4 Bright A_SetScale(0.5);
		RED8 CDE 1 A_NoBlocking;
		Stop;
	}
}

class RS_ShadowBall : Actor   // CH spectres.txt:1298
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 18;
		DamageFunction (random(20,55));
		Projectile;
		+RANDOMIZE
		DamageType "Plasma";
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "Shadow/attack";
		DeathSound "imp/shotx";
		Decal "DoomImpScorch";
	}
	States
	{
	Spawn:
		SBAL ABC 4 Bright A_SpawnItemEx("RS_ShadowTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		SBAL C 5 Bright;
		SBAL DEFGH 4 Bright;
		Stop;
	}
}

class RS_ShadowBall2 : Actor   // CH spectres.txt:1270 -- the big one that sheds more
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 8;
		DamageFunction (random(30,90));
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.75;
		Scale 1.75;
		SeeSound "Shadow/attack";
		DeathSound "imp/shotx";
		Decal "DoomImpScorch";
	}
	States
	{
	Spawn:
		SBAL C 4 Bright A_SpawnItemEx("RS_ShadowTrail",0,0,2,0,0,0,0,128);
		SBAL AABB 1 Bright A_CustomMissile("RS_ShadowBall",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		SBAL C 5 Bright A_CustomMissile("RS_ShadowBall",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		SBAL DEFGH 4 Bright A_CustomMissile("RS_ShadowBall",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Stop;
	}
}

class RS_ShadowGhostA : Actor   // CH spectres.txt:1324 -- the chase afterimages
{
	Default
	{
		Radius 4;
		Height 8;
		Speed 0;
		Damage 0;
		Mass 75;
		RenderStyle "Translucent";
		Alpha 0.25;
		Projectile;
	}
	States
	{
	Spawn:
		SHDW A 10;
		Stop;
	}
}

class RS_ShadowGhostB : RS_ShadowGhostA   // CH spectres.txt:1342
{
	States
	{
	Spawn:
		SHDW B 10;
		Stop;
	}
}

class RS_ShadowGhostC : RS_ShadowGhostA   // CH spectres.txt:1352
{
	States
	{
	Spawn:
		SHDW C 10;
		Stop;
	}
}

class RS_ShadowGhostD : RS_ShadowGhostA   // CH spectres.txt:1362
{
	States
	{
	Spawn:
		SHDW D 10;
		Stop;
	}
}

class RS_ShadowTrail : Actor   // CH spectres.txt:1372
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.5;
		+NOCLIP
	}
	States
	{
	Spawn:
		SHTR ABCDEF 4 Bright;
		Stop;
	}
}

// --- White boss kit.  CH: spectres.txt:1563-1722 ---------------------------
class RS_RiseCheck : Inventory { Default { Inventory.MaxAmount 1; } }   // CH spectres.txt:1563

class RS_SpecSlime1 : Actor   // CH spectres.txt:1565 -- the bouncing poison glob
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 17;
		DamageFunction (random(10,70));
		PoisonDamage 15;
		SeeSound "Shadow/attack";
		DeathSound "imp/shotx";
		Scale 0.75;
		Projectile;
		+BOUNCEONWALLS
		WallBounceFactor 1;
		BounceCount 3;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Fly;
	Fly:
		BOGY A 1 Bright;
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,-3,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BOGY B 1 Bright;
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,-3,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BOGY C 1 Bright;
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,-3,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Death:
		BOGY DEF 4 Bright;
		TNT1 AAAAAAAAAAAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_SpecSlime2 : Actor   // CH spectres.txt:1599 -- the fast spray glob
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 24;
		DamageFunction (random(10,40));
		PoisonDamage 5;
		SeeSound "Shadow/attack";
		DeathSound "imp/shotx";
		Scale 0.4;
		Projectile;
	}
	States
	{
	Spawn:
		BOGY ABC 1 Bright;
		Loop;
	Death:
		BOGY DEF 4 Bright;
		Stop;
	}
}

class RS_SpecSlime3 : Actor   // CH spectres.txt:1621 -- the floor-hugging ripper
{
	Default
	{
		Alpha 1.0;
		RenderStyle "Add";
		Speed 7;
		Radius 14;
		Height 9;
		DamageFunction (random(10,50));
		XScale 0.1;
		YScale 1.8;
		DamageType "Plasma";
		Projectile;
		+SEEKERMISSILE
		+RIPPER
		+FLOORHUGGER
		SeeSound "shadowbeast/pr1sight";
		DeathSound "shadowbeast/pr1death";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Fly;
	Fly:
		BDP1 E 2 Bright A_SeekerMissile(5,4);
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BDP1 D 2 Bright A_SeekerMissile(3,6);
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BDP1 E 2 Bright A_SeekerMissile(12,7);
		TNT1 AAA 0 A_SpawnParticle("Green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Death:
		BDP2 DE 4 Bright;
		BDP2 FGH 3 Bright;
		Stop;
	}
}

// The white boss's pain-summon.  A summon, not a ladder monster: no tier
// token, same as the other families' minions.
class RS_Wakawaka : Actor   // CH spectres.txt:1659
{
	Default
	{
		Health 320;
		PainChance 120;
		Species "Demon1";
		BloodColor "Green";
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 16;
		Radius 30;
		Height 56;
		DamageFunction (random(20,75));   // CH: Damage (random(20,75))
		Mass 4000;
		Monster;
		+NEVERTARGET
		+NOINFIGHTING
		+DONTHARMSPECIES
		+DONTHARMCLASS
		AttackSound "EWorm/Bite";
		SeeSound "EWorm/Sight";
		ActiveSound "EWorm/Idle";
		PainSound "Worm/Hurt";
		Obituary "%o got nommed up";
		MeleeRange 60;
		Tag "You're not pacman";
	}
	States
	{
	Spawn:
		EWRM A 8 A_Look;
		Loop;
	See:
		EWRM A 1 A_Chase;
		Loop;
	Missile:
		EWRM A 0 A_JumpIfCloser(60,"Melee");
		EWRM A 1 A_FaceTarget;
		TNT1 A 0 A_PlaySound("Worm/Hurt");
		EWRM A 0 ThrustThingZ(0,random(6,13),0,0);
		TNT1 A 0 ThrustThing(int(angle*256/360),21,0,0);   // CH: ThrustThing(angle*256/360,21,0,0)
	MidLeap:
		EWRM A 1 A_CheckFloor("Land");
		TNT1 A 0 A_CheckFloor("Land");
		Loop;
	Land:
		EWRM A 1 A_Stop;
		Goto See;
	Melee:
		EWRM B 5 A_FaceTarget;
		EWRM A 11 A_CustomMeleeAttack(random(10,45),"","","None",false);   // CH: A_CustomMeleeAttack(random(10,45),0,0,0,0)
		Goto See;
	Pain:
		EWRM B 7 A_Pain;
		Goto See;
	Death:
		TWIA ABAC 1;
		TNT1 A 0 A_PlaySound("Worm/Death");
		TWIA ABACABACABACABAC 1;
		DEAE AB 4;
		TNT1 A 1 A_PlaySound("weapons/rocklx");
		MISL BCD 6 A_Explode(random(10,50),64);
		Stop;
	}
}
