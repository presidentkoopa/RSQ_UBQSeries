// ============================================================================
// RS_ImpFX.zs -- Colourful Hell Imp family: support classes.
// Source of truth: C:\Users\Command\Desktop\CH (Imps.txt read whole, 3,133
// lines; externals from Fatsos.txt / MASTERMINDS.txt / Revenants.txt /
// Hellknights.txt / Barons.txt / Cacodemons.txt / Gibs.txt -- each class
// cites its CH file:line).
//
// Same import rules as the other families (see RS_ZombiemanFX.zs header).
// Shared classes reused read-only: RS_Zom, icons, tokens, bundles,
// RS_SplashAbyss(2), RS_CGNail, RS_CGthing3, RS_PuffCybieRed, RS_SparkPuff1,
// RS_FireSGguy2, RS_HKRedDeath, RS_CH_* drop gates, RS_CH_Cirno.
//
// The brown imp's war-cry is CH's ACS pack-buff (CHSett.acs:148
// "BrownImpCommand"), rebuilt native here per the owner's standing order
// ("break up the ACS yourself"): RS_BrownImpCommand -> RS_BrownImpBuffCtl.
//
// Dangling / silent by design, verbatim from CH:
//   * ZOMG U (fireblu imp's XDeath, RS_Imp.zs, CH Imps.txt:825-826) -- no
//     ZOMGU0 in CH, CHP or this repo; CHP keeps the same dangling reference
//     (DECORATE\01\01_G.txt:62). Both states are 0-tic, so nothing is ever
//     drawn and there is nothing to fix. Verified 2026-08-06, left verbatim.
//
// Resolved 2026-08-06 -- both remaining imp frame gaps closed:
//   * BLTR G (RS_AgauresBallTrail's last frame) was invisible for 2 tics.
//     CH ships BLTR A-F only, in both trees, and CHP does not re-author the
//     actor, so there is no corrected upstream copy. The set is a 6-step
//     darken/grow fade; the sequence now repeats F ("BLTR ABCDEFF"), which
//     holds the tail of the fade for those 2 tics. State count and total
//     tics unchanged.
//   * GIMP P (gray imp's death frame and its reverse in Raise, used in
//     RS_Imp.zs) was a typo in CH itself -- no GIMPP0 exists anywhere, and
//     the sequence is plainly I-J-K-L. CHP re-authors the actor and writes
//     "GIMP K 5" and "GIMP LKJI 4" (ART SOURCE\CHP\DECORATE\03\03_GY.txt:57
//     and :64); CHP wins. GIMPK0 ships here and is the mid-collapse frame.
//     Corrected to K at both sites.
//
// Resolved 2026-08-06 -- RS_EffectHK's sprite used to be VBAL, a typo in CH
// itself (CHP carries it verbatim, DECORATE/11/11_R.txt:2782). No VBAL lump
// exists in CH, CHP, ART SOURCE or this repo, so both frames rendered
// nothing. Fixed to CBAL, on this evidence: VBAL is a well-formed "?BAL"
// token one adjacent key from CBAL (C/V); CH uses CBAL twice within 50 lines
// of the typo in the same file (Hellknights.txt:2152 and :2181); and CBAL A
// is a rotation-0 red fire ball (11x11, mean RGB 209,30,7) that matches the
// red RS_RedThingsHK sparks this actor exists to burst. The near-miss VBA3 A
// is an orange 8-rotation comet with a 37x6 side streak -- a moving-
// projectile sprite, wrong on a Speed 0 +NOINTERACTION flash -- and 3/L is
// not a keystroke slip. CBAL A/B are the only frames of the CBAL set that no
// CH or CHP actor references (all 139 frame refs start at C): exactly the
// residue one misspelled reference leaves. The other "?BAL" sets are
// unrelated -- SBAL is the shadow-beast pack (spectres only) and HBAL is in
// the Knight pack, referenced by nothing in CH or CHP, as are 4 of that
// folder's 10 prefixes.
// ============================================================================

// ---------------------------------------------------------------------------
// The war-cry.  CH: Imps.txt:183 (the CustomInventory) + CHSett.acs:148
// (the script).  ACS did: skip bosses; force ALWAYSFAST (remembering
// whether it was already on); halve damage taken (APROP_DamageFactor 0.5);
// shove the monster in a random direction and up/down; hold 300 tics;
// restore both.  Rebuilt 1:1 below.
// ---------------------------------------------------------------------------
class RS_BrownImpCommand : CustomInventory   // CH Imps.txt:183
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
		TNT1 A 0 { if (!bBOSS) A_SpawnItemEx("RS_BrownImpBuffCtl",0,0,0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION); }
		Stop;
	}
}

class RS_BrownImpBuffCtl : Actor   // native rebuild of CHSett.acs:148
{
	double prevFactor;
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
		prevFactor = m.DamageFactor;
		if (!m.bALWAYSFAST) { m.bALWAYSFAST = true; setFast = true; }
		m.DamageFactor = 0.5;
		// CH: ThrustThing(random(0,255),random(1,12),0,0)
		double a = random(0,255) * (360.0 / 256.0);
		m.Vel.XY += AngleToVector(a, random(1,12));
		// CH: ThrustThingZ(0,random(1,12),random(0,1),0) -- speed is in
		// quarter-units, third arg 1 = downward.
		m.Vel.Z += random(1,12) * 0.25 * (random(0,1) ? -1. : 1.);
		applied = true;
	}

	void RS_RevertBuff()
	{
		let m = master;
		if (!applied || !m) return;
		m.DamageFactor = prevFactor;
		if (setFast) m.bALWAYSFAST = false;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.RS_ApplyBuff(); }
		TNT1 A 300;   // CH: delay(300)
		TNT1 A 0 { invoker.RS_RevertBuff(); }
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Brown imp props.  CH: Imps.txt:199 / 249 / 262.
// ---------------------------------------------------------------------------
class RS_BrownImpShieldMini : Actor   // CH Imps.txt:199 -- the parry flash
{
	Default
	{
		Radius 64;
		Height 56;
		Speed 1;
		Species "Imp";
		Health 100;
		Monster;
		+NOTRIGGER
		+NOTARGET
		+NOPAIN
		+DONTTHRUST
		+NOGRAVITY
		+NOICEDEATH
		+MTHRUSPECIES
		+THRUSPECIES
		-COUNTKILL
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.5;
		Translation "0:255=#[240,247,9]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		DKNT Z 1 Bright A_SetScale(0.4,0.4);
		DKNT Z 1 Bright A_SetScale(0.6,0.6);
		DKNT Z 1 Bright A_SetScale(0.7,0.5);
		DKNT Z 1 Bright A_SetScale(0.5,0.5);
		TNT1 A 0 A_FaceTarget;
		DKNT Z 1 Bright A_SetScale(0.95,0.75);
		TNT1 A 0 A_PlaySound("HEALSIEL",0);
		TNT1 A 0 A_DamageSelf(50);   // CH: DamageThing(50)
		DKNT Z 0 A_SkullAttack(4);
		DKNT Z 24 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_Stop;
		DKNT Z 2 Bright A_NoBlocking;
		DKNT Z 2 Bright A_SetScale(0.5,0.6);
		DKNT Z 2 Bright A_SetScale(0.3,0.3);
		DKNT Z 2 Bright A_SetScale(0.3,0.2);
		DKNT Z 2 Bright A_SetScale(0.2,0.1);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_WarlordMace : Actor   // CH Imps.txt:249
{
	Default
	{
		BounceType "Doom";   // CH: +DOOMBOUNCE
		Speed 4;
	}
	States
	{
	Spawn:
		WLI2 ABCDEF 5;
		WLI2 G -1;
		Stop;
	}
}

class RS_WarlordShield : Actor   // CH Imps.txt:262
{
	Default
	{
		BounceType "Doom";   // CH: +DOOMBOUNCE
		Speed 5;
	}
	States
	{
	Spawn:
		WLI1 ABCDEF 5;
		WLI1 G -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// External FX pulled from other CH family files.
// ---------------------------------------------------------------------------
class RS_FatsoSpikes2 : Actor   // CH Fatsos.txt:1148 -- brown's spike volley
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 5;
		DamageFunction (random(10,40));
		Projectile;
		DamageType "Melee";
		-NOGRAVITY
		+THRUGHOST
		Gravity 0.1;
		Scale 0.45;
		SeeSound "monster/dknmsl";
		BounceSound "fire/fire3";
		DeathSound "weapons/boom1";
		Translation "144:151=90:95","64:79=96:109","236:239=104:111","1:2=111:111";
	}
	States
	{
	Spawn:
		RIP1 ABC 4 Bright;
		Loop;
	Death:
		RIP1 ABCABCABCBA 12 A_Explode(random(1,4),8);
		Stop;
	}
}

class RS_FrostLong : Actor   // CH MASTERMINDS.txt:2610 -- parent of the shard
{
	Default
	{
		Radius 3;
		Height 4;
		Speed 76;
		DamageFunction (random(5,12));
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageType "Ice";
		DeathSound "Ice/Hit2";
		Alpha 0.85;
		Scale 0.3;
	}
	States
	{
	Spawn:
		KIRC A 1 Bright A_SeekerMissile(8,8);
		KIRC B 1 Bright A_PlaySound("Ice/Fly");
		KIRC C 1 Bright A_Weave(1,1,2,1);
		KIRC D 1 Bright;
		Loop;
	Death:
		PUFI ABCD 1 Bright A_SetTranslucent(0.4);
		PUFI EFGH 1 Bright;
		Stop;
	}
}

class RS_FrostLong2 : RS_FrostLong   // CH MASTERMINDS.txt:2640
{
	Default
	{
		-SEEKERMISSILE
		DamageFunction (random(3,9));
	}
	States
	{
	Spawn:
		KIRC ABCD 1 Bright;
		Loop;
	}
}

class RS_Firespe1 : Actor   // CH Revenants.txt:2609 -- orange's pain ember
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 20;
		Mass 2;
		Gravity 0.4;
		BounceType "Heretic";
		+TOUCHY
		RenderStyle "Add";
		SeeSound "Fire/fire1";
		DamageType "Fire";
		Alpha 0.8;
	}
	States
	{
	Spawn:
		FLUM ABCDE 4 Bright A_Jump(84,"Death");
		Loop;
	Death:
		MISL B 5 Bright;
		MISL C 5 Bright A_Explode(7,64);
		MISL D 4 Bright A_SpawnItemEx("RS_Firespe2",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_Firespe2",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_Firespe2",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_Firespe2",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_Firespe2",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 0 A_SpawnItemEx("RS_Firespe2",random(-32,32),random(-32,32),2,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_Firespe2 : Actor   // CH Revenants.txt:2670 -- the lingering flame
{
	Default
	{
		Radius 4;
		Height 8;
		Mass 24;
		Gravity 1.5;
		+SLIDESONWALLS
		RenderStyle "Add";
		DamageType "Fire";
		Scale 0.7;
		Alpha 0.8;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		FLUM FGHIJK 3 Bright A_Explode(random(1,2),41);
		FLUM F 0 A_Jump(32,"A1");
		FLUM F 0 A_Jump(14,"Death");
		Loop;
	A1:
		FLUM FG 3 Bright A_Explode(random(1,2),41);
		TNT1 A 0 ThrustThing(random(0,255),random(1,2),0,0);
		FLUM HI 3 Bright A_Explode(random(1,2),41);
		TNT1 A 0 ThrustThing(random(0,255),random(1,3),0,0);
		FLUM JK 3 Bright A_Explode(random(1,2),41);
		TNT1 A 0 ThrustThing(random(0,255),random(2,3),0,0);
		FLUM F 0 A_Jump(20,"Death");
		Goto Fly;
	Death:
		FLUM FGHIJK 1 A_FadeOut(0.15);
		Stop;
	}
}

class RS_EffectHK : Actor   // CH Hellknights.txt:2088 -- red spark burst shell.
// CH writes VBAL here; that is a typo for CBAL (see the header block).
{
	Default
	{
		Radius 5;
		Height 5;
		Mass 5;
		Speed 0;
		Projectile;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		CBAL A 1;   // CH: VBAL -- CH typo; CBAL is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Death;
	Death:
		CBAL A 1 A_Burst("RS_RedThingsHK");   // CH: VBAL -- CH typo; CBAL is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_BaronRing : Actor   // CH Barons.txt:3091 -- White's summon flame ring
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 1;
		Mass 25;
		Gravity 0.7;
		Projectile;
		+THRUACTORS
		-NOGRAVITY
		+RANDOMIZE
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.75;
		Scale 1;
	}
	States
	{
	Spawn:
		RNGG ABCD 2 Bright;
		Loop;
	Death:
		RNGG ABCD 4 Bright;
		Stop;
	}
}

class RS_CrackoBallTrail : Actor   // CH Cacodemons.txt:2055
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+FLOAT
		RenderStyle "Add";
		Alpha 0.5;
		Translation "192:207=171:191","240:247=191:191";
	}
	States
	{
	Spawn:
		BLL9 AB 2 Bright A_FadeOut(0.1);
		Loop;
	}
}

class RS_RedBBall : Actor   // CH Barons.txt:3523 -- fireblu imp's red bolt
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 25;
		DamageFunction (random(10,50));
		Scale 0.5;
		Species "BaronOfHell";
		Projectile;
		+THRUGHOST
		+DONTHARMCLASS
		+DONTHARMSPECIES
		SeeSound "weapons/firbfi";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		RenderStyle "Add";
		Alpha 0.8;
		Translation "112:127=176:191";
		DamageType "Plasma";
	}
	States
	{
	Spawn:
		RED9 A 3 Bright A_SetScale(0.5);
		RED9 B 3 Bright A_CustomMissile("RS_CrackoBallTrail",4,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		RED9 C 3 Bright A_SetScale(0.4);
		Loop;
	Death:
		ARCB J 0 A_SetTranslucent(0.67,1);
		ARCB J 3 Bright;
		ARCB K 3 Bright A_Explode(random(5,20),128,0);
		ARCB LMN 3 Bright;
		Stop;
	}
}

class RS_BluBBall : RS_RedBBall { Default { Translation "0:255=196:207"; } }   // CH Barons.txt:3558

class RS_CHgold_teeth : Actor   // CH Gibs.txt:198 -- purple imp's keepsake
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 7;
		Scale 1;
		Damage 0;
		Projectile;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		+MOVEWITHSECTOR
		+CANNOTPUSH
		-NOGRAVITY
		+NOTONAUTOMAP
		BounceFactor 0.7;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 ThrustThingZ(0,45,0,1);
		Goto Wee;
	Wee:
		GTEE ABC random(3,6);
		Loop;
	Crash:
		GTEE C -1;
		Stop;
	Death:
		GTEE C -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The family's own projectiles.  CH: Imps.txt.
// ---------------------------------------------------------------------------
class RS_CyanImpBall : Actor   // CH Imps.txt:463
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 28;
		Scale 0.75;
		DamageFunction (random(2,20));
		DamageType "Ice";
		Projectile;
		+DONTHARMCLASS
		SeeSound "imp/attack";
		DeathSound "Ice/Hit2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CHCY ABCDFG 3 Bright;
		Loop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAA 0 A_CustomMissile("RS_FrostLong2",0,0,random(0,359),CMF_OFFSETPITCH,random(-25,-5));
		Stop;
	}
}

class RS_AbyssBallCH : Actor   // CH Imps.txt:674
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 21;
		DamageFunction (random(5,40));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		SeeSound "Roach/Fire";
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RCHB A 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359));
		RCHB B 2 Bright;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359));
		Loop;
	Death:
		TNT1 A 0 A_SetScale(1.2,1.2);
		TNT1 AAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",6,0,random(-180,180),CMF_OFFSETPITCH,random(-25,-5));
		RCHB CDE 4 Bright A_Explode(random(1,9),56);
		Stop;
	}
}

// CH: Imps.txt:961 -- CH replaces the VANILLA imp fireball with a
// fire-damagetype version. Carried verbatim, replaces and all.
class RS_DoomImpBall2 : Actor replaces DoomImpBall
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		FastSpeed 20;
		Damage 3;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
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

class RS_GreenIBall : Actor   // CH Imps.txt:1179
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 14;
		FastSpeed 26;
		DamageFunction (random(5,23));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright A_SeekerMissile(1,1);
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(1,7),32);
		Stop;
	}
}

class RS_Blufier1 : Actor   // CH Imps.txt:1315
{
	Default
	{
		Radius 17;
		Height 15;
		Speed 16;
		DamageFunction (random(17,38));
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.95;
		Scale 1.3;
		SeeSound "imp/attack";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSE BCD 3 Bright A_SpawnItemEx("RS_Blutrail1",0,0,3);
		Loop;
	Death:
		PLSE CDE 3 Bright;
		Stop;
	}
}

class RS_Blutrail1 : Actor   // CH Imps.txt:1340
{
	Default
	{
		Radius 15;
		Height 9;
		Speed 0;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.55;
		Scale 1.2;
		Translation "192:194=198:202","4:4=195:195","224:225=193:196";
	}
	States
	{
	Spawn:
		PLSE BCD 3 Bright;
		Goto Death;
	Death:
		PLSE DE 3 Bright;
		Stop;
	}
}

class RS_Bounc11 : Actor   // CH Imps.txt:1479 -- purple's bouncing bomb
{
	Default
	{
		Radius 15;
		Height 8;
		Speed 18;
		DamageFunction (random(5,35));
		DamageType "Fire";
		Projectile;
		+BOUNCEONWALLS
		RenderStyle "Add";
		Alpha 0.75;
		BounceType "Hexen";
		WallBounceFactor 0.7;
		BounceFactor 0.7;
		BounceCount 4;
		BounceSound "Bomb/bounce";
		SeeSound "imp/attack";
		DeathSound "weapons/plasmax";
		Translation "168:191=250:254","208:223=250:254";
	}
	States
	{
	Spawn:
		BAL1 AB 3 Bright A_CustomMissile("RS_Bounc22",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Bounce:
		BAL1 CD 2 Bright A_Explode(15,25);
	Death:
		BAL1 CDE 3 Bright A_Explode(random(2,10),42);
		Stop;
	}
}

class RS_Bounc22 : Actor   // CH Imps.txt:1512
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 12;
		DamageFunction (random(1,3));
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.2;
		Translation "168:191=250:254","208:223=250:254";
	}
	States
	{
	Spawn:
		BAL1 AB 3 Bright;
		Goto Death;
	Death:
		BAL1 CDE 3 Bright;
		Stop;
	}
}

class RS_SpitFireImp : Actor   // CH Imps.txt:1662
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 19;
		DamageFunction (random(2,42));
		DamageType "Fire";
		Projectile;
		RenderStyle "Add";
		SeeSound "Imp/Attack";
		DeathSound "Fire/fire5";
		Alpha 0.9;
		Scale 0.85;
	}
	States
	{
	Spawn:
		FLUM ABCDE 6 Bright;
		Loop;
	Death:
		BBOM ABC 2 Bright A_SetScale(0.7);
		BBOM DEFG 3 Bright A_Explode(random(2,13),64);
		Stop;
	}
}

// --- Black imp weapons.  CH: Imps.txt:1891-2566 -----------------------------
class RS_BlackImpEXcharge : Actor   // CH Imps.txt:1891
{
	Default
	{
		Radius 10;
		Height 18;
		Speed 1;
		Scale 1.45;
		RenderStyle "Add";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BLVB A 3 Bright A_SetScale(1.45,1.2);
		BLVB B 3 Bright A_SetScale(1.2,1.45);
		BLVB A 3 Bright A_SetScale(1.45,1.2);
		BLVB B 3 Bright A_SetScale(1.2,1.45);
		BLVB A 3 Bright A_SetScale(1.45,1.2);
		BLVB B 3 Bright A_SetScale(1.2,1.45);
		BLVB A 3 Bright A_SetScale(1.0,1.0);
		BLVB B 3 Bright A_SetScale(0.6,0.6);
		BLVB A 3 Bright A_SetScale(0.25,0.25);
		Stop;
	}
}

class RS_BlackImpBeam1 : Actor   // CH Imps.txt:1920 -- kamehameha puff
{
	Default
	{
		Radius 1;
		Height 1;
		Scale 1.25;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		Speed 1;
		RenderStyle "Add";
		DamageType "Plasma";
		DeathSound "NETHERDE";
		Alpha 1.25;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		TNT1 A 1 A_Scream;
		SPIR EDCBA 3 Bright A_Explode(random(2,20),128);
		TNT1 AAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		Stop;
	}
}

class RS_BlackImpBeam2 : Actor   // CH Imps.txt:1945 -- kamehameha spawnclass
{
	Default
	{
		Radius 10;
		Height 18;
		Speed 1;
		Scale 1.75;
		DamageType "Fire";
		DamageFunction (random(10,20));
		RenderStyle "Add";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BLVB A 3 Bright A_SetScale(1.75,1.75);
		BLVB B 3 Bright A_SetScale(1.5,1.5);
		TNT1 A 0 A_Explode(random(5,30),64,0);
		BLVB A 3 Bright A_SetScale(1.75,1.75);
		BLVB B 3 Bright A_SetScale(1.5,1.5);
		TNT1 A 0 A_Explode(random(5,30),64,0);
		BLVB A 3 Bright A_SetScale(1.75,1.75);
		BLVB B 3 Bright A_SetScale(1.5,1.5);
		TNT1 A 0 A_Explode(random(5,30),64,0);
		BLVB A 3 Bright A_SetScale(1.75,1.75);
		BLVB B 3 Bright A_SetScale(1.5,1.5);
		TNT1 A 0 A_Explode(random(5,30),64,0);
		BLVB A 3 Bright A_SetScale(1.15,1.15);
		BLVB B 3 Bright A_SetScale(0.5,0.5);
		BLVB A 3 Bright A_SetScale(0.15,0.15);
		TNT1 AA 0 A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(-3,3),random(-359,359));
		Stop;
	}
}

class RS_BlackImpSmokeOut : Actor   // CH Imps.txt:1983 -- the smoke flood
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 1;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Stencil";
		StencilColor "Black";
		SeeSound "Fire/fire3";
		Alpha 0.75;
		YScale 0.25;
		XScale 0.5;
	}
	States
	{
	Spawn:
		RNGG ABCDABCDABCD 1 Bright;
	Fly:
		RNGG ABCDABCDABCD 3 Bright A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		RNGG ABCDABCDABCD 2 Bright A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		RNGG ABCDABCDABCD 1 Bright A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		RNGG ABCD 4 Bright A_SpawnItemEx("RS_DeathBreathDI",0,0,random(1,6),random(3,15),0,random(1,12),random(-359,359));
		Stop;
	}
}

class RS_BlackImpEXBall1 : Actor   // CH Imps.txt:2013
{
	Default
	{
		Radius 10;
		Height 10;
		Speed 14;
		DamageFunction (random(5,40));
		Scale 1.15;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		WeaveIndexXY 54;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A2","A3");
	A1:
		BLVB A 1 Bright A_SpawnItemEx("RS_AgauresBallTrail",0,0,0,0,0,0,0,128,0);
		BLVB B 1 Bright A_Weave(3,0,2,0);
		Loop;
	A2:
		BLVB A 1 Bright A_SpawnItemEx("RS_AgauresBallTrail",0,0,0,0,0,0,0,128,0);
		BLVB B 1 Bright A_Weave(3,0,-2,0);
		Loop;
	A3:
		BLVB A 1 Bright A_SpawnItemEx("RS_AgauresBallTrail",0,0,0,0,0,0,0,128,0);
		BLVB B 1 Bright;
		Loop;
	Death:
		BLVB CDEF 2 Bright A_SpawnItemEx("RS_DeathBreathDI",random(-178,178),random(-178,178),random(-12,42),random(1,6),0,0,random(-359,359));
		Stop;
	}
}

class RS_BlackImpExBigOne : Actor   // CH Imps.txt:2052
{
	Default
	{
		Radius 16;
		Height 16;
		Speed 9;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		Scale 2.35;
		DamageFunction (random(50,120));
		DamageType "Plasma";
		Alpha 1.25;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		DropItem "RS_CH_RocketAmmo";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RED9 B 1 Bright A_Explode(random(4,10),128);
		RED9 A 1 Bright A_SeekerMissile(2,2);
		Loop;
	Death:
		SPIR AAAAAAAAAAAA 0 A_SpawnItemEx("RS_DeathBreathDI",random(-178,178),random(-178,178),random(-12,42),random(1,6),0,0,random(-359,359));
		TNT1 A 0 A_SetScale(4.0,4.0);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(5,50),256);
		SPIR E 1 A_NoBlocking;
		Stop;
	}
}

class RS_BlackImpExBall2 : Actor   // CH Imps.txt:2263
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 19;
		DamageFunction (random(1,10));
		RenderStyle "Add";
		Alpha 0.67;
		DamageType "Fire";
		Projectile;
		Gravity 0.02;
		-NOGRAVITY
		+USEBOUNCESTATE
		+SEEKERMISSILE
		BounceType "Hexen";
		BounceFactor 1.25;
		BounceCount 4;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BLVB A 1 Bright A_SpawnItemEx("RS_AgauresBallTrail",0,0,0,0,0,0,0,128,0);
		BLVB B 1 Bright A_SeekerMissile(random(2,8),random(2,10));
		Loop;
	Bounce:
		TNT1 A 0 ThrustThingZ(0,9,0,0);
		Goto Fly;
	Death:
		BLVB C 0 A_SetScale(2,2);
		BLVB CDEF 4 Bright A_Explode(random(1,8),32);
		Stop;
	}
}

class RS_DIBigOne : Actor   // CH Imps.txt:2437 -- the black imp's big one.
// The roll below is the one that once shipped flattened to `Damage 60`
// and sat wrong through three lanes (see CLAUDE.md). It stays a roll.
{
	Default
	{
		Radius 12;
		Height 24;
		Speed 7;
		Projectile;
		+NOGRAVITY
		RenderStyle "Add";
		Scale 2;
		DamageFunction (random(40,125));
		DamageType "Plasma";
		Alpha 0.75;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
		DropItem "RocketAmmo";
	}
	States
	{
	Spawn:
		RED9 B 1 Bright;
		RED9 AA 1 Bright A_SpawnItemEx("RS_SpiralSaw5",0,0,0,0,0,0,0,128);
		RED9 A 0 A_CustomMissile("RS_GroundRedCyb",0,0);
		RED9 A 0 A_CustomMissile("RS_AgauresBall1",7,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		RED9 A 0 A_Explode(random(4,10),128);
		Loop;
	Death:
		SPIR AAAA 0 A_SpawnItemEx("RS_DeathBreathDI",random(-178,178),random(-178,178),random(-12,42),0,0,0,0,128,0);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(5,30),178);
		SPIR E 1 A_NoBlocking;
		Stop;
	}
}

class RS_AgauresBall1 : Actor   // CH Imps.txt:2469
{
	Default
	{
		Radius 10;
		Height 18;
		Speed 9;
		DamageFunction (random(5,40));
		Scale 1.45;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Projectile;
		+THRUGHOST
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		BLVB AAABBB 1 Bright A_SpawnItemEx("RS_AgauresBallTrail",0,0,0,0,0,0,0,128,0);
		BLVB A 0 A_Jump(24,"Death");
		Loop;
	Death:
		BLVB CDEF 2 Bright A_SpawnItemEx("RS_DeathBreathDI",random(-178,178),random(-178,178),random(-12,42),0,0,0,0,128,0);
		Stop;
	}
}

class RS_AgauresBall2 : Actor   // CH Imps.txt:2495
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 19;
		DamageFunction (random(5,25));
		RenderStyle "Add";
		Alpha 0.67;
		DamageType "Fire";
		Projectile;
		+THRUGHOST
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
	}
	States
	{
	Spawn:
		BLVB AAABBB 1 Bright A_SpawnItemEx("RS_AgauresBallTrail",0,0,0,0,0,0,0,128,0);
		Loop;
	Death:
		BLVB C 0 A_SetScale(2,2);
		BLVB CDEF 4 Bright A_Explode(random(1,10),64);
		Stop;
	}
}

class RS_AgauresBallTrail : Actor   // CH Imps.txt:2520
{
	Default
	{
		Radius 0;
		Height 1;
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright;   // CH: NULL A -- CH ships no NULL lump; the token is its idiom for "draw nothing for a beat" before the real animation (same shape at CYBIES.txt:3915, Imps.txt:2530, thepains.txt:1763). TNT1 is GZDoom the actual null sprite and what the rest of this tree uses. Same tics. Fixed 2026-08-06.
		BLTR ABCDEFF 2 Bright;   // CH: BLTR G -- frame G ships nowhere (CH's blackimp/ and this repo both stop at BLTRF0), so CH's own trail blinks out for its last 2 tics. Repeats F, the darkest/largest frame of the fade, so the tail holds instead of vanishing. Still 7 states / 14 tics. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

// The black smoke itself -- DamageType "DIMp", the type every CH monster
// is immune to (DamageFactor "DIMp",0), and it heals the black imp's kin.
class RS_DeathBreathDI : Actor   // CH Imps.txt:2536
{
	Default
	{
		Radius 24;
		Height 6;
		Speed 1;
		Damage 1;
		DamageType "DIMp";
		Scale 0.95;
		Projectile;
		+FLOATBOB
		RenderStyle "Translucent";
		Alpha 0.67;
	}
	States
	{
	Spawn:
		AGAS ABCDE 4 A_Explode(random(0,2),42);
		AGAS E 0 A_RadiusGive("Health",64,RGF_MONSTERS|RGF_EXFILTER,3,"RS_BlackImp1");
		AGAS FGDEF 4 A_Explode(random(1,2),42);
		AGAS F 0 A_RadiusGive("Health",64,RGF_MONSTERS|RGF_EXFILTER,5,"RS_BlackImp1");
		AGAS GDEFGD 4 A_Explode(random(0,1),42);
		AGAS E 0 A_RadiusGive("Health",64,RGF_MONSTERS|RGF_EXFILTER,3,"RS_BlackImp1");
		AGAS EFGDEF 4 A_Explode(random(1,2),42);
		AGAS F 0 A_RadiusGive("Health",64,RGF_MONSTERS|RGF_EXFILTER,5,"RS_BlackImp1");
		AGAS GDCBA 4 A_Explode(random(0,1),42);
		Goto Death;
	Death:
		AGAS DC 1 A_SetScale(0.65);
		AGAS BA 3 A_Explode(random(1,2),32);
		Stop;
	}
}

// --- White imp weapons.  CH: Imps.txt:2981-3133 -----------------------------
class RS_WimpBall1 : Actor   // CH Imps.txt:2981
{
	Default
	{
		Radius 7;
		Height 14;
		Speed 14;
		FastSpeed 26;
		DamageFunction (random(5,25));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Scale 0.8;
		Alpha 0.85;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(1,7),32);
		Stop;
	}
}

class RS_WimpBall2 : RS_WimpBall1   // CH Imps.txt:3009
{
	Default
	{
		Speed 16;
		DamageFunction (random(4,32));
		Translation "168:191=192:207","208:223=193:200","231:231=4:4";
	}
	States
	{
	Death:
		PLSE C 0 A_SetScale(1.1);
		PLSE CDE 4 Bright;
		Stop;
	}
}

class RS_WimpBall3 : RS_WimpBall1   // CH Imps.txt:3023
{
	Default
	{
		Speed 15;
		DamageFunction (random(2,24));
		Translation "0:0=0:0";
	}
	States
	{
	Spawn:
		BAL1 A 2 Bright A_SetScale(1.2,0.5);
		BAL1 A 2 Bright A_SetScale(1,0.65);
		BAL1 B 2 Bright A_SetScale(0.8,0.8);
		BAL1 B 2 Bright A_SetScale(1,0.65);
		Loop;
	Death:
		BAL1 C 0 A_SetScale(1.1,1.1);
		BAL1 CDE 6 Bright A_Explode(random(1,12),64);
		Stop;
	}
}

class RS_WimpBall4 : RS_WimpBall1   // CH Imps.txt:3043
{
	Default
	{
		Speed 15;
		DamageFunction (random(3,31));
		+SEEKERMISSILE
		Translation "168:191=208:223";
	}
	States
	{
	Spawn:
		BAL1 A 3 Bright A_SeekerMissile(1,1);
		BAL1 B 3 Bright A_Weave(1,1,1,1);
		Loop;
	}
}

class RS_WimpBall5 : RS_Bounc11   // CH Imps.txt:3058
{
	Default
	{
		Scale 0.8;
		BounceCount 1;
	}
	States
	{
	Spawn:
		BAL1 A 3 Bright;
		BAL1 B 3 Bright;
		Loop;
	}
}

class RS_HellionBall : Actor   // CH Imps.txt:3071
{
	Default
	{
		Radius 12;
		Height 16;
		DamageFunction (random(10,60));
		Speed 19;
		Alpha 0.80;
		Scale 1.3;
		DamageType "Fire";
		Projectile;
		+THRUGHOST
		+FORCEXYBILLBOARD
		+SEEKERMISSILE
		RenderStyle "Add";
		SeeSound "Monster/hlnatk";
		DeathSound "Monster/hlnexp";
		Decal "DoomImpScorch";
	}
	States
	{
	Spawn:
		HLBL A 1 Bright A_SeekerMissile(7,5);
		HLBL B 1 Bright A_SpawnItemEx("RS_HellionPuff",0,0,0,0,0,0,0,128);
		HLBL A 1 Bright A_Weave(1.0,1.0,1.0,10);
		HLBL B 1 Bright A_SpawnItemEx("RS_HellionPuff",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		HLBL JKLMN 3 Bright;
		Stop;
	}
}

class RS_Hel2 : RS_HellionBall   // CH Imps.txt:3103
{
	States
	{
	Spawn:
		HLBL A 1 Bright A_SeekerMissile(5,7);
		HLBL B 1 Bright A_SpawnItemEx("RS_HellionPuff",0,0,0,0,0,0,0,128);
		HLBL A 1 Bright A_Weave(1.0,1.0,1.0,1.0);
		HLBL B 1 Bright A_SpawnItemEx("RS_HellionPuff",0,0,0,0,0,0,0,128);
		Loop;
	}
}

class RS_HellionPuff : Actor   // CH Imps.txt:3116
{
	Default
	{
		Radius 3;
		Height 3;
		RenderStyle "Add";
		Alpha 0.67;
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+FORCEXYBILLBOARD
	}
	States
	{
	Spawn:
		TNT1 A 3 Bright;
		HLBL CDEFGHI 3 Bright;
		Stop;
	}
}
