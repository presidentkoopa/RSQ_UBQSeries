// ============================================================================
// RS_HellKnightFX.zs -- Colourful Hell Hell Knight family: support actors,
// projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Hellknights.txt
// (3,546 lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_HellKnight.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here) -- note that FOUR of them have Hellknights.txt as their CH
// source but shipped with earlier lanes, per the correct-in-place rule:
//   RS_HKRedDeath (Hellknights.txt:2231 -> zombieman FX),
//   RS_RedThingsHK (Hellknights.txt:2107 -> zombieman FX),
//   RS_EffectHK (Hellknights.txt:2088 -> imp FX),
//   RS_HKEXProtect (Hellknights.txt:2922 -> demon FX),
//   RS_BigHK / RS_BigHK2 / RS_BigHK3 (Hellknights.txt:1827/1856/1879 ->
//   lostsoul FX), RS_PlasmaBallSP4 (Hellknights.txt:2498 -> caco FX),
//   RS_BaronsBlueBalls (:1491), RS_HKBolt2 (:1642), RS_FireHKBall1 (:1802),
//   RS_THEBEEHK (:2131), RS_THEBEEHK2 (:2157) -- all five -> lostsoul FX,
//   each diffed against CH at cede time, identical.
// Plus the ordinary shared set: RS_Zom, RS_ZomTierToken, RS_GrowRaisin,
// RS_CHBoner, RS_ThePlanBoner, RS_ColorTierIconCH..CH13, RS_HealthBundle,
// RS_ArmorBundle, RS_BackPackBundle, RS_CH_Chainsaw, RS_CH_ClipBox,
// RS_CH_GreenArmor, RS_CH_RocketBox, RS_CH_RocketAmmo, RS_CH_BlueArmor,
// RS_CH_Berserk, RS_CH_MegaSphere, RS_CH_RocketLauncher, RS_CH_PlasmaRifle,
// RS_CH_SoulSphere, RS_CH_BFG9000, RS_CH_Shell, RS_CH_Cell,
// RS_implyingclip, RS_CH_Cirno, RS_SplashAbyss, RS_SplashAbyss2,
// RS_AbyssShotIdentifier, RS_SparkPuff1 + RS_Purpfire2 (shotgunner FX),
// RS_CGNail + RS_CGRailBuff + RS_RedRevLoad (chaingunner FX),
// RS_HellionBall (imp FX), RS_SpikeCyanRev (demon FX), RS_IceCacoTrail +
// RS_MolochNail (caco FX), RS_HomingRocketTrailFatso (lostsoul FX),
// RS_BlueImp (imp lane, parent of RS_SpecialImp), RS_CommonSpectre
// (spectre lane, parent of RS_SpecialSpectre2).
//
// The green knight's ACS lead-shot (CHACS.acs:54 "BaronMissile") is rebuilt
// native as RS_HKLead.FireLead below, per the standing order. Its opt-out
// gate CH_Intercept (CHSett.acs:84, CH default false) becomes the new cvar
// rs_ch_intercept (default 0). The lostsoul family's three flagged
// BaronMissile sites can switch to this helper whenever the owner wants.
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite HWAE frame K (RS_BrownHK2 Death first line, Hellknights.txt
//     :166): no HWAE* lump in either CH tree -- a one-line typo for HWAR on
//     a 0-tic state, invisible in CH too. Kept verbatim.
//   * Sound "moloch/nailhit" (RS_HKEXslash AttackSound): CH's $random
//     members for it are missing lumps -- the same known hole flagged by
//     earlier families. Kept verbatim.
//   * Sounds "weapons/grenlf"/"weapons/grenlx" (RS_BaronNade,
//     RS_BaronHellNade): not in CH's SNDINFO at all -- the same known hole
//     the zombieman family flagged. Silent in CH, kept verbatim.
//   * Sound "knight/pain" (RS_BrownHK2, RS_GreenHK PainSound): CH SNDINFO
//     never defines it (vanilla's knight set is sight/death/active; vanilla
//     HellKnight pain is baron/pain). Plays only if the engine defines it;
//     CH adds nothing. Kept verbatim.
//   * Sprite BRUR frames O-W (RS_RedHK Raise): CH ships BRUR A-N only; the
//     W..O half of CH's own raise run renders nothing in CH either (only
//     reachable via Archvile resurrection).
//
// RESOLVED 2026-08-06 -- sprite SGRN frame A. It was listed above as a
// verbatim CH hole (RS_BaronNade Spawn/Bounce, CH Hellknights.txt:2546-2551;
// RS_BaronHellNade Bounce, :3188). It is CH's one-character typo for HGRN,
// and is now written HGRN at all five sites in this file. Evidence, in order
// of weight:
//   1. No competing candidate exists. HGRN is the only sprite name
//      containing "GRN" in the whole CH tree (382 prefixes), and the only
//      single-edit neighbour of SGRN that exists anywhere: ART SOURCE
//      (20,330 sprite files) and CHP (11,365) ship no SGRN, no TGRN, no
//      JGRN.
//   2. The art is a grenade. sprites/molochs/HGRNA0.png + HGRNB0.png, 17x15,
//      a dark metal sphere with a lit fuse hole; B is pixel-identical to A
//      mirrored, i.e. a two-frame tumble. grAb offsets (8,7) -- dead centre,
//      authored as a flying projectile -- and 17px wide fits this actor's
//      Radius 8 exactly. The site is a bouncing grenade: BounceType "Doom",
//      +GRENADETRAIL, BounceSound "prox/beep", SeeSound "weapons/grenlf".
//   3. Nothing else claims it. HGRN is referenced by zero CH actors, so no
//      other effect loses its art to this.
//   4. CH already pulls sprites/molochs/ art into this very file:
//      RS_HKEXslash draws BLAD A and FBL1 EFG, both molochs/ lumps.
// The lump already ships here as sprites/monsters/_src/HGRNA0.png,
// byte-identical to CH's copy, so no art import was needed. CH and CHP are
// both still broken here -- this correction is ours, not theirs. The same
// typo still stands at the shotgunner (RS_SGGasNade) and spider
// (RS_SpiderStoneRocket, RS_SpRocket3) sites, which live in other files and
// were not touched.
//
// Standing strips, preserved at each site as "// CH:" comments: ACS
// announcers (AnnounceBlackHK, AnnounceWhiteHK); the gore chain; DRLA
// RLSniperModItem/RLNanoModItem/RLBaronBlasterPickup/RareArmorPool/RL*
// spawner drops.
// ============================================================================

// ---------------------------------------------------------------------------
// Native rebuild of CHACS.acs:54 "BaronMissile" -- fire a projectile at the
// point a constant-velocity target will occupy (CH brute-forced the
// intercept with ProjInt_Brute; this solves the same quadratic exactly).
// Speed matches CH: 15, or 20 when sv_fastmonsters is set.
// ---------------------------------------------------------------------------
class RS_HKLead play
{
	static void FireLead(Actor shooter, class<Actor> proj, double zofs)
	{
		if (!shooter || !shooter.target || !proj) return;
		double spd = (RS_Zom.CV('sv_fastmonsters', 0) != 0) ? 20 : 15;   // CH: CHACS.acs:56-58
		Actor tgt = shooter.target;
		Vector3 spos = shooter.Pos + (0, 0, zofs);
		Vector3 d = level.Vec3Diff(spos, tgt.Pos + (0, 0, tgt.Height / 2));
		Vector3 v = tgt.Vel;
		double qa = (v dot v) - spd * spd;
		double qb = 2 * (d dot v);
		double qc = d dot d;
		double t = -1;
		if (abs(qa) < 0.001)
		{
			if (abs(qb) > 0.001) t = -qc / qb;
		}
		else
		{
			double disc = qb * qb - 4 * qa * qc;
			if (disc >= 0)
			{
				double r1 = (-qb - sqrt(disc)) / (2 * qa);
				double r2 = (-qb + sqrt(disc)) / (2 * qa);
				t = (r1 > 0 && (r2 <= 0 || r1 < r2)) ? r1 : r2;
			}
		}
		Vector3 aim = (t > 0) ? d + v * t : d;   // no intercept -> straight shot, like CH's rand==1 branch
		double ang = VectorAngle(aim.X, aim.Y);
		double pitch = -VectorAngle((aim.X, aim.Y).Length(), aim.Z);
		let mo = Actor.Spawn(proj, spos, ALLOW_REPLACE);
		if (mo)
		{
			mo.target = shooter;
			mo.Angle = ang;
			mo.Pitch = pitch;
			mo.Vel3DFromAngle(spd, ang, pitch);
			mo.CheckMissileSpawn(shooter.radius);
		}
	}
}

// ---------------------------------------------------------------------------
// Brown knight's kit.  CH: Hellknights.txt:180-274.
// ---------------------------------------------------------------------------
class RS_BrownHKShieldCheck : Actor   // CH Hellknights.txt:180
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		DamageFunction (random(10,60));
		DamageType "Melee";
		Projectile;
		Alpha 0.85;
		Scale 1.5;
		Gravity 0.5;
		SeeSound "";
		DeathSound "";
		BounceSound "";
	}
	States
	{
	Spawn:
		TNT1 A 6;
		Goto Death;
	XDeath:
		TNT1 A 1 A_PlaySound("monster/dknswg");
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BrownHKShield : Actor   // CH Hellknights.txt:209
{
	Default
	{
		Radius 72;
		Height 64;
		Speed 1;
		Species "BaronOfHell";
		Health 999;
		Monster;
		+NOTRIGGER
		+NOTARGET
		+DONTTHRUST
		+NOGRAVITY
		+INVULNERABLE
		+REFLECTIVE
		+DEFLECT
		+SHIELDREFLECT
		+MTHRUSPECIES
		+THRUSPECIES
		RenderStyle "Add";
		Alpha 0.95;
		Scale 1.1;
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
		DKNT Z 1 Bright A_SetScale(0.9,0.8);
		TNT1 A 0 A_FaceTarget;
		DKNT Z 1 Bright A_SetScale(1.25,1.1);
		TNT1 A 0 A_PlaySound("HEALSIEL",0);
		DKNT Z 8 Bright;
		Goto Death;
	Death:
		DKNT Z 2 Bright A_NoBlocking;
		DKNT Z 2 Bright A_SetScale(0.8,0.7);
		DKNT Z 2 Bright A_SetScale(0.5,0.4);
		DKNT Z 2 Bright A_SetScale(0.3,0.2);
		DKNT Z 2 Bright A_SetScale(0.2,0.1);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_HellWarriorShield : Actor   // CH Hellknights.txt:257 -- the dropped shield prop
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 6;
		BounceType "Doom";   // was +DOOMBOUNCE
		+DROPOFF
		+MISSILE
	}
	States
	{
	Spawn:
		HWSH ABCDEFGH 3;
		Loop;
	Death:
		HWSH I -1;
		Loop;
	}
}

// ---------------------------------------------------------------------------
// Cyan knight's kit.  CH: Hellknights.txt:457-545.
// ---------------------------------------------------------------------------
class RS_IceHKShot : Actor   // CH Hellknights.txt:457
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 34;
		DamageFunction (random(9,27));
		DamageType "Ice";
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 1.5;
		SeeSound "Ice/Hit2";
		DeathSound "spike/spiked";   // CH: undefined in CH SNDINFO, the known verbatim hole
	}
	States
	{
	Spawn:
		ICEY ABC 3 Bright;
		Loop;
	Death:
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(0,90));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(89,180));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(181,270));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(271,359));
		ICEY FGHI 5 Bright;
		Stop;
	}
}

class RS_CyanHKShade : Actor   // CH Hellknights.txt:485
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Add";
		SeeSound "";
		DeathSound "";
		Alpha 0.25;
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		HFRY A 2 Bright;
	Death:
		TNT1 A 0 A_SetTranslucent(0.20);
		HFRY A 2 Bright A_SetScale(1.1,1.1);
		TNT1 A 0 A_SetTranslucent(0.10);
		HFRY A 2 Bright A_SetScale(1.3,1.3);
		TNT1 A 0 A_SetTranslucent(0.05);
		HFRY A 2 Bright A_SetScale(1.5,1.5);
		Stop;
	}
}

class RS_IceOrbCyanHK : Actor   // CH Hellknights.txt:513
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 42;
		DamageFunction (random(7,60));
		DamageType "Ice";
		Projectile;
		Scale 2;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 2 Bright;
		ICEY B 2 Bright A_SpawnItemEx("RS_IceCacoTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		ICEY C 2 Bright A_SpawnItemEx("RS_IceCacoTrail",0,0,0,random(2,21),0,random(-5,25),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_SetScale(2.5,1.5);
		ICEY F 4 Bright A_Explode(random(10,60),128);
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(0,90));
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(89,180));
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(181,270));
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(271,359));
		ICEY GHI 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Abyss knight's kit.  CH: Hellknights.txt:734-793.
// ---------------------------------------------------------------------------
class RS_AbyssHKBall : Actor   // CH Hellknights.txt:734
{
	Default
	{
		Radius 12;
		Height 9;
		Speed 28;
		YScale 1.0;
		XScale 1.42;
		DamageFunction (random(10,55));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.95;
		SeeSound "baron/attack";
		DeathSound "spit/spit2";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		BAL7 AB 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-228,228),random(-8,8),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(8,8),random(-228,228),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Explode(random(8,30),64,0);
		PLSE CDE 3 Bright;
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssHKMist",random(-156,156),random(-156,156),6,random(1,11),0,0,random(-359,359),SXF_NOCHECKPOSITION,128);
		Stop;
	}
}

class RS_AbyssHKMist : Actor   // CH Hellknights.txt:769
{
	Default
	{
		Radius 16;
		Height 12;
		Speed 1;
		DamageType "Ice";
		Projectile;
		RenderStyle "Add";
		XScale 1.33;
		YScale 0.6;
		Alpha 0.6;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,4),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		PSBG CDE 2 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,4),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Goto Death;
	Death:
		PSBG FGHIIHGFFGHI 6 Bright A_Explode(random(1,9),46);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// FireBlu / Gray / Common / Blue / Purple / Yellow / Red projectiles.
// ---------------------------------------------------------------------------
class RS_FireBluHKBall1 : Actor   // CH Hellknights.txt:938
{
	Default
	{
		Radius 20;
		Height 20;
		Mass 600;
		Speed 15;
		DamageFunction (random(5,50));
		DamageType "Plasma";
		Projectile;
		Scale 1;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "Crack/death";
		Translation "216:223=199:207","208:214=193:201","231:231=194:194","168:175=198:201";
	}
	States
	{
	Spawn:
		MANF AB 3 A_SpawnItemEx("RS_FireBluHKBall3",random(-3,3),random(-3,3),random(-3,3),0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		MISL B 4 A_SetTranslucent(0.35);
		MISL C 1 A_Explode(random(5,20),128);
		MISL CCCCCCCCCCCCCC 0 A_CustomMissile("RS_FireBluHKBall2",5,0,random(0,360),0,random(-180,180));
		MISL DDD 2 A_Explode(random(5,10),128);
		Stop;
	}
}

class RS_FireBluHKBall2 : Actor   // CH Hellknights.txt:967
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 20;
		DamageFunction (random(5,10));
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "208:223=195:207","225:231=192:195";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(1,7),128);
		Stop;
	}
}

class RS_FireBluHKBall3 : Actor   // CH Hellknights.txt:993
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 12;
		DamageFunction (random(5,10));
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.5;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "208:223=195:207","225:231=192:195";
	}
	States
	{
	Spawn:
		BAL1 AB 1 Bright A_BishopMissileWeave;
		BAL1 A 0 A_Jump(4,"Death");
		Loop;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(1,5),128);
		Stop;
	}
}

class RS_MinesHK : Actor   // CH Hellknights.txt:1126 -- gray's bouncing nail mine
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 32;
		DamageFunction (random(5,20));
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Projectile;
		DamageType "Fire";
		-NOGRAVITY
		+BOUNCEONWALLS
		+THRUGHOST
		Gravity 0.3;
		BounceType "Doom";
		BounceCount 25;
		BounceFactor 0.95;
		WallBounceFactor 1.1;
		SeeSound "monster/dknmsl";
		BounceSound "fire/fire3";
		DeathSound "weapons/boom1";
		Translation "144:151=90:95","64:79=96:109","236:239=104:111","1:2=111:111";
	}
	States
	{
	Spawn:
		RIP1 ABC 4 Bright;
		RIP1 C 0 A_Jump(4,"Death");
		Loop;
	Death:
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,15,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,45,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,75,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,105,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,135,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,165,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,195,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,225,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,255,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,285,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,315,0);
		MISL D 0 A_CustomMissile("RS_CGNail",0,0,345,0);
		Stop;
	}
}

class RS_HKSplashDed : Actor   // CH Hellknights.txt:1255 -- the XDeath blood burst
{
	Default
	{
		Radius 10;
		Height 42;
		+NOGRAVITY
		Scale 2;
	}
	States
	{
	Spawn:
		BAR1 A 0;
		Goto Death;
	Death:
		BAL7 C 6 Bright A_XScream;
		BAL7 DE 6 Bright;
		Stop;
	}
}

// RS_BaronsBlueBalls (CH Hellknights.txt:1491) -- ceded: already defined in
// RS_LostSoulFX.zs; diffed against CH, identical. Referenced read-only.
// RS_HKBolt2 (CH Hellknights.txt:1642) -- ceded: same, lostsoul lane owns it.
// RS_FireHKBall1 (CH Hellknights.txt:1802) -- ceded: same, lostsoul lane owns it.

class RS_BloodBoltHK : Actor   // CH Hellknights.txt:2060
{
	Default
	{
		Radius 12;
		Height 12;
		Mass 25;
		Speed 17;
		DamageFunction (random(10,54));
		DamageType "Plasma";
		Projectile;
		Scale 0.75;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "fire/Fire4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 4 A_CustomMissile("RS_REDTHINGSHK",3,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Loop;
	Death:
		BAL1 C 4 A_SetTranslucent(0.35);
		BAL1 D 5 A_Explode(random(2,14),32);
		BAL1 E 5 A_Explode(random(2,14),44);
		Stop;
	}
}

// RS_THEBEEHK (CH Hellknights.txt:2131) -- ceded: already defined in
// RS_LostSoulFX.zs; diffed against CH, identical. Referenced read-only.
// RS_THEBEEHK2 (CH Hellknights.txt:2157) -- ceded: same, lostsoul lane owns it.

class RS_SpecialImp : RS_BlueImp   // CH Hellknights.txt:2186 -- red knight's warp-tethered assistant
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }   // minion: no tier token
	Default
	{
		Health 90;
		Species "BaronOfHell";
		BloodColor "blue";
		Radius 20;
		Height 56;
		Mass 100;
		Speed 9;
		PainChance 140;
		RenderStyle "Add";
		Alpha 1;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+MISSILEMORE
		+THRUSPECIES
		+NOTARGETSWITCH
		-COUNTKILL
		-ACTIVATEMCROSS
		+NOTRIGGER
		SeeSound "imp2/see";
		PainSound "imp2/hurt";
		DeathSound "imp2/die";
		ActiveSound "imp2/active";
		DropItem "RS_HealthBundle", 42;
		DropItem "RS_CH_Cell", 22;
		Obituary "%o met Red Hell Knights Assistant Blue Imp";
		HitObituary "%o scratch wound bleed blue? what";
		Translation "64:79=196:207","58:63=195:198","168:191=1:1","0:0=0:0";
		Tag "Blue Imp Imago";
	}
	States
	{
	See:
		TROO ABBCC 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO DEEFF 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TROO A 0 A_JumpIfMasterCloser(1000,"See");
		TROO A 2 A_Warp(AAPTR_MASTER,5,1,6,0,WARPF_NOCHECKPOSITION);
		Loop;
	}
}

// ---------------------------------------------------------------------------
// Black boss (Terminator) kit.  CH: Hellknights.txt:2466-2635, plus
// third-file externals from CYBIES / Revenants / Barons.
// ---------------------------------------------------------------------------
class RS_BrusMode : Inventory   // CH Hellknights.txt:2466
{
	Default
	{
		Inventory.MaxAmount 3;
	}
}

class RS_SwooshCBBar1 : Actor   // CH Hellknights.txt:2468
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 36;
		DamageFunction (random(10,40));
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.75;
		Scale 0.6;
		SeeSound "Litn/litn3";
		DeathSound "weapons/bfgx";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 AB 1 Bright A_SpawnItemEx("RS_SwooshCBTR",0,0,3);
		Loop;
	Death:
		BFE1 ABC 1 Bright A_Explode(random(5,30),124);
		BFS1 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("RS_PlasmaBallSP4",random(-8,8),random(-8,20),0,random(15,60),0,random(-33,33),random(0,120));
		BFS1 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("RS_PlasmaBallSP4",random(-8,8),random(-8,20),0,random(15,60),0,random(-33,33),random(120,240));
		BFS1 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 0 A_SpawnItemEx("RS_PlasmaBallSP4",random(-8,8),random(-8,20),0,random(15,60),0,random(-33,33),random(240,359));
		Stop;
	}
}

class RS_SwooshCBTR : Actor   // CH CYBIES.txt:2618 -- third-file external, the beam's trail
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 33;
		Projectile;
		+FULLVOLDEATH
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.50;
		Scale 0.4;
		DeathSound "Spell/Lightn";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 AB 2 Bright A_SpawnItemEx("RS_SwooshCBTR2",0,0,2);
		Goto Death;
	Death:
		BFS1 AB 4 Bright A_Explode(random(5,20),32);
		Stop;
	}
}

class RS_SwooshCBTR2 : Actor   // CH CYBIES.txt:2645
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 30;
		Projectile;
		+FULLVOLDEATH
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.25;
		Scale 0.2;
		DeathSound "Spell/Lightn";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 AB 2 Bright;
		Goto Death;
	Death:
		BFS1 AB 4 Bright A_Explode(random(5,15),32);
		Stop;
	}
}

class RS_BluCybFX : Actor   // CH CYBIES.txt:2494 -- third-file external, muzzle flare
{
	Default
	{
		Radius 15;
		Height 9;
		Speed 1;
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.3;
	}
	States
	{
	Spawn:
		PLSE BCD 3 Bright;
		Goto Death;
	Death:
		PLSE CDE 3 Bright;
		Stop;
	}
}

class RS_MegaRedRev : Actor   // CH Revenants.txt:2855 -- third-file external, the death beam
{
	Default
	{
		Radius 11;
		Height 9;
		Speed 90;
		DamageFunction (random(35,95));
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.8;
		Scale 1.5;
		SeeSound "Crack/see";
		DeathSound "Litn/litn3";
		Translation "192:207=171:191","240:247=191:191";
	}
	States
	{
	Spawn:
		BLL9 AAAABBBB 1 Bright A_SpawnItemEx("RS_RedRevLoad2",0,0,4,0,0,0,0,128);
		Loop;
	Death:
		BLL9 CDE 6 Bright A_Explode(random(15,55),64);
		Stop;
	}
}

class RS_RedRevLoad2 : Actor   // CH Revenants.txt:2882 -- third-file external, the beam's charge FX
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "Weapons/BFGF";
	}
	States
	{
	Spawn:
		SPIR ABCDE 3 Bright A_SpawnItemEx("RS_RedRevLoad",0,0,4,0,0,0,0,128);
		Stop;
	}
}

class RS_BaronStar3 : Actor   // CH Barons.txt:2988 -- third-file external, the nade's seeker stars
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 27;
		FastSpeed 38;
		DamageFunction (random(5,30));
		DamageType "Fire";
		Species "BaronOfHell";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		Scale 1.3;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		STRS AB 2 Bright A_SeekerMissile(3,3);
		STRS CD 2 Bright A_Weave(4,1,6,0);
		Goto Death;
	Death:
		BBOM A 2 Bright A_SetScale(1.5);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,20),148);
		BBOM EFG 6 Bright A_Explode(random(5,30),148);
		Stop;
	}
}

class RS_BaronNade : Actor   // CH Hellknights.txt:2524
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
		BounceCount 15;
		BounceFactor 1.15;
		WallBounceFactor 0.7;
		SeeSound "weapons/grenlf";   // CH: maps to a lump CH never ships, silent there too
		DeathSound "weapons/grenlx"; // CH: same
		BounceSound "prox/beep";
		DamageType "Fire";
	}
	States
	{
	Spawn:
		HGRN A 1 Bright;   // CH: SGRN -- CH typo; HGRN is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 1 Bright A_Jump(12,"Bounce");   // CH: SGRN -- CH typo; HGRN is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		HGRN A 1 Bright A_Jump(4,"Death");   // CH: SGRN -- CH typo; HGRN is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Loop;
	Bounce:
		HGRN A 2 Bright ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: SGRN A 2 Bright ThrustThing(angle*256/(random(1,360)),12,0,0) -- CH typo SGRN; HGRN is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Spawn;
	Death:
		MISL B 8 Bright A_Explode(random(20,50),128);
		MISL CCCC 2 Bright A_SpawnItemEx("RS_BaronStar3",random(-180,180),random(-180,180),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL DDDD 2 Bright A_SpawnItemEx("RS_BaronStar3",random(-220,220),random(-220,220),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		MISL DDDDDD 0 A_SpawnItemEx("RS_BaronStar3",random(-280,280),random(-280,280),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_SpreadMisBar1 : Actor   // CH Hellknights.txt:2562
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 17;
		DamageFunction (random(10,40));
		DamageType "Fire";
		Projectile;
		Scale 1.25;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/homingexplode";
	}
	States
	{
	Spawn:
		MSLH A 2 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		MSLH A 0 A_Jump(10,"Death");
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		MISL B 2 Bright A_Explode(random(5,35),88);
		MISL C 3 Bright;
		MISL CC 0 A_CustomMissile("RS_MolochNail",random(-2,2),random(-2,2),random(-4,4),CMF_AIMDIRECTION|CMF_SAVEPITCH);
		MISL DD 0 A_CustomMissile("RS_MolochNail",random(-2,2),random(-2,2),random(-4,4),CMF_AIMDIRECTION|CMF_SAVEPITCH);
		MISL D 3 Bright;
		Stop;
	}
}

class RS_BruiserMissile : Actor   // CH Hellknights.txt:2590
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 20;
		DamageFunction (random(20,75));
		Scale 1.15;
		DamageType "Fire";   // CH also sets +FireDamage, the deprecated flag alias for the same thing
		Projectile;
		RenderStyle "Normal";
		+THRUGHOST
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright;
		FBRS A 1 Bright A_SpawnItemEx("RS_BruiserTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 6 Bright A_SetScale(1.5);
		BAL3 D 6 Bright A_Explode(random(20,75),128,0);
		BAL3 E 6 Bright;
		Stop;
	}
}

class RS_BruiserTrail : Actor   // CH Hellknights.txt:2621
{
	Default
	{
		Radius 3;
		Height 3;
		RenderStyle "Translucent";
		Alpha 0.67;
		Projectile;
	}
	States
	{
	Spawn:
		TNT1 A 3 Bright;
		PUFF ABCD 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black EX (Terminator MK II) kit.  CH: Hellknights.txt:2928-3215.
// ---------------------------------------------------------------------------
class RS_ZapOrbHKEX : Actor   // CH Hellknights.txt:2928
{
	Default
	{
		Radius 9;
		Height 6;
		Speed 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_Warp(AAPTR_TARGET,1,0,88,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 1 Bright A_SpawnItemEx("RS_ZapDecHKex",random(-64,64),random(-64,64),random(-72,12),0,0,0,0,128);
		TNT1 A 0 A_Jump(2,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_ZapOrbHKEX2 : Actor   // CH Hellknights.txt:2949
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 41;
		DamageFunction (random(10,40));
		DamageType "Plasma";
		Projectile;
		+RIPPER
		Scale 1.1;
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_SpawnItemEx("RS_ZapDecHKex",random(-16,16),random(-16,16),random(-2,2),0,0,0,0,128);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_HKEXslash : Actor   // CH Hellknights.txt:2970
{
	Default
	{
		Radius 6;
		Height 8;
		DamageFunction (random(10,35));
		DamageType "Melee";
		Speed 42;
		YScale 5.2;
		XScale 1.25;
		AttackSound "moloch/nailhit";   // CH: $random members are missing lumps, the known verbatim hole
		DeathSound "weapons/firex4";
		Projectile;
		+SPAWNSOUNDSOURCE
		+EXTREMEDEATH
		+FLOORHUGGER
		+RIPPER
		+BLOODSPLATTER
		Translation "0:255=[53,0,0]:[244,0,0]";
	}
	States
	{
	Spawn:
		BLAD A 1 Bright;
		Loop;
	Death:
		FBL1 EFG 1 Bright A_Explode(random(5,20),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_PuffCybieRed",0,0,2);
		Stop;
	}
}

class RS_SpreadMisBarEX : Actor   // CH Hellknights.txt:3000
{
	Default
	{
		Radius 9;
		Height 6;
		Speed 41;
		DamageFunction (random(10,40));
		DamageType "Fire";
		Projectile;
		Scale 1.1;
		SeeSound "weapons/hominglaunch";
		DeathSound "weapons/homingexplode";
	}
	States
	{
	Spawn:
		MSLH A 2 Bright A_SpawnItemEx("RS_HomingRocketTrailFatso",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		MISL B 0 A_SetTranslucent(0.8,1);
		MISL B 2 Bright A_Explode(random(5,35),88);
		MISL CD 3 Bright;
		Stop;
	}
}

class RS_BruiserMissileEx : Actor   // CH Hellknights.txt:3024
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 33;
		DamageFunction (random(40,95));
		Scale 1.15;
		DamageType "Fire";   // CH also sets +FireDamage, deprecated alias, same thing
		Projectile;
		RenderStyle "Normal";
		+THRUGHOST
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright A_SpawnItemEx("RS_BruiserTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 4 Bright A_SetScale(2.5,2.0);
		BAL3 D 6 Bright A_Explode(random(40,95),208,0);
		BAL3 E 8 Bright;
		Stop;
	}
}

class RS_BruiserMissileEx2 : Actor   // CH Hellknights.txt:3054
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 29;
		DamageFunction (random(80,125));
		Scale 1.15;
		DamageType "Fire";   // CH also sets +FireDamage, deprecated alias, same thing
		Projectile;
		RenderStyle "Normal";
		+THRUGHOST
		+SEEKERMISSILE
		SeeSound "monster/brufir";
		DeathSound "weapons/hellex";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		Decal "Scorch";
	}
	States
	{
	Spawn:
		FBRS A 1 Bright A_SeekerMissile(12,9);
		FBRS A 1 Bright A_SpawnItemEx("RS_BruiserTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BAL3 C 0 A_SetTranslucent(0.67,1);
		BAL3 C 4 Bright;
		BAL3 D 6 Bright A_Explode(random(10,40),128,0);
		BAL3 E 8 Bright;
		Stop;
	}
}

class RS_HKEXFastBeam : Actor   // CH Hellknights.txt:3086
{
	Default
	{
		Radius 13;
		Height 6;
		Speed 45;
		Projectile;
		+FULLVOLDEATH
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.50;
		YScale 0.3;
		XScale 0.75;
		DeathSound "Spell/Lightn";
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 A 1 Bright A_SpawnItemEx("RS_HKEXFastBeamTrail",0,0,1);
		TNT1 A 0 A_SpawnItemEx("RS_HKEXFastBeamTrail",-21,0,1);
		BFS1 B 1 Bright A_SpawnItemEx("RS_HKEXFastBeamTrail",0,0,1);
		TNT1 A 0 A_SpawnItemEx("RS_HKEXFastBeamTrail",-21,0,1);
		Loop;
	Death:
		BFS1 AB 4 Bright A_Explode(random(5,30),32);
		Stop;
	}
}

class RS_HKEXFastBeamTrail : Actor   // CH Hellknights.txt:3115
{
	Default
	{
		Radius 13;
		Height 6;
		Speed 1;
		Projectile;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.50;
		YScale 0.25;
		XScale 0.45;
		Translation "112:127=192:207";
	}
	States
	{
	Spawn:
		BFS1 A 3 Bright;
	Death:
		BFS1 AB 4 Bright A_Explode(random(5,30),32);
		BFS1 A 3 Bright A_SetScale(0.1,0.1);
		Stop;
	}
}

class RS_ZapDecHKex : Actor   // CH Hellknights.txt:3139
{
	Default
	{
		Speed 1;
		Projectile;
		RenderStyle "Add";
		Alpha 0.88;
		XScale 0.55;
		YScale 0.75;
		Translation "0:255=[138,173,187]:[255,255,255]";
	}
	States
	{
	Spawn:
		LITN ABCDEFGFEDB 1 Bright;
		Stop;
	}
}

class RS_BaronHellNade : Actor   // CH Hellknights.txt:3157
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 28;
		DamageFunction (random(30,85));
		Projectile;
		-NOGRAVITY
		+GRENADETRAIL
		+SEEKERMISSILE
		BounceType "Doom";
		Gravity 0.33;
		BounceCount 23;
		BounceFactor 1.15;
		Scale 0.55;
		WallBounceFactor 0.95;
		SeeSound "weapons/grenlf";   // CH: missing lump in CH too
		DeathSound "weapons/grenlx"; // CH: missing lump in CH too
		BounceSound "prox/beep";
		DamageType "Fire";
	}
	States
	{
	Spawn:
		BBOM B 1 Bright A_SetScale(0.75,0.35);
		BBOM B 1 Bright A_Weave(4,4,random(-5,5),random(-5,5));
		BBOM B 1 Bright A_SetScale(0.35,0.75);
		BBOM B 1 Bright A_SeekerMissile(12,12);
		BBOM B 1 Bright A_Jump(12,"Bounce");
		Loop;
	Bounce:
		HGRN A 2 Bright ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: SGRN A 2 Bright ThrustThing(angle*256/(random(1,360)),12,0,0) -- CH typo SGRN; HGRN is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).
		Goto Spawn;
	Death:
		MISL B 5 Bright A_Explode(random(30,50),128);
		TNT1 AAAA 0 A_SpawnItemEx("RS_BaronStar3",random(-128,128),random(-128,128),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAA 1 A_SpawnItemEx("RS_BaronStar3",random(64,64),random(64,64),random(32,64),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_BaronStar3",random(128,258),random(-42,42),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_BaronStar3",random(-42,42),random(128,258),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAA 1 A_SpawnItemEx("RS_BaronStar3",random(64,64),random(64,64),random(64,128),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_BaronStar3",random(-258,128),random(-42,42),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_BaronStar3",random(-42,42),random(-258,-128),random(1,32),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAA 1 A_SpawnItemEx("RS_BaronStar3",random(64,64),random(64,64),random(88,176),0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",250,0,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",250,250,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",0,250,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",-250,-250,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",250,-250,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",-250,250,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",-250,0,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",0,-250,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",200,200,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",-200,200,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",200,-200,32,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_BaronStar3",-200,-200,32,0,0,0,SXF_NOCHECKPOSITION);
		MISL CD 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White boss (Ghost of 1993) kit.  CH: Hellknights.txt:3374-3547.
// ---------------------------------------------------------------------------
class RS_SpecialSpectre2 : RS_CommonSpectre   // CH Hellknights.txt:3374 -- the ghost's summoned spectres
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 0); }   // minion: no tier token
	Default
	{
		Monster;
		+THRUSPECIES
		+NOCLIP
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 174;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
	}
}

class RS_MiniPhantom : Actor   // CH Hellknights.txt:3399
{
	Default
	{
		RenderStyle "Add";
		+FLOAT
		+LOOKALLAROUND
		+NOBLOCKMONST
		+NOGRAVITY
		+SHOOTABLE
		+NOBLOOD
		+NOCLIP
		Health 10;
		Radius 16;
		Height 20;
		Speed 14;
		MissileType "RS_SoulSmoke";
		Obituary "%o was defeated by ghosts of M8E1";
	}
	States
	{
	Spawn:
	See:
		SPI1 AA 1 A_Chase;
		SPI1 A 0 A_FaceTarget;
		SPI1 A 0 A_SpawnItemEx("RS_SoulSmoke",0,0,0,15,0,0,0,128);
		SPI1 BB 1 A_Chase;
		SPI1 A 0 A_FaceTarget;
		SPI1 B 0 A_SpawnItemEx("RS_SoulSmoke",0,0,0,15,0,0,0,128);
		Loop;
	Melee:
		SPI1 EFGHIJ 2 A_Die;
		Stop;
	Death:
		SPIR E 0 A_Explode(random(20,50),88);
		SPIR E 0 A_PlaySound("phantom/explode");
		SPIR FGHIJ 2;
		Stop;
	}
}

class RS_PhantomEgg : Actor   // CH Hellknights.txt:3437
{
	Default
	{
		DamageFunction (random(20,60));
		Projectile;
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 22;
		SeeSound "phantom/spirit1";
		DeathSound "none";   // CH: DEATHSOUND NONE
		RenderStyle "Add";
		Translation "192:207=84:95";
		Scale 1.2;
	}
	States
	{
	Spawn:
		PLSS AB 5 A_SpawnItemEx("RS_SoulTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		PLSS A 1 A_SpawnItem("RS_PhantomHatch",1,0,0);
		Stop;
	}
}

class RS_PhantomHatch : Actor   // CH Hellknights.txt:3461
{
	Default
	{
		RenderStyle "Add";
		+NOGRAVITY
		+NOCLIP
	}
	States
	{
	Spawn:
		SPI1 JIHGFE 4;
		SPI1 A 4 A_SpawnItem("RS_MiniPhantom",1,0,0);
		Stop;
	}
}

class RS_SoulBomb : Actor   // CH Hellknights.txt:3475
{
	Default
	{
		Radius 12;
		Height 8;
		Speed 11;
		DamageFunction (random(20,80));
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
		Scale 0.95;
		MissileType "RS_SoulTrail";
		SeeSound "phantom/bomb";
		DeathSound "phantom/explode";
		Translation "128:143=80:95","64:79=80:95","144:151=89:95","168:191=80:95","208:223=80:88","0:2=193:196","48:63=80:95","160:167=192:201","232:235=90:95";
	}
	States
	{
	Spawn:
		SKUL C 1 Bright A_SpawnItemEx("RS_SoulTrail",0,0,13,0,0,0,0,128);
		SKUL D 1 Bright A_SpawnItemEx("RS_SoulTrail",0,0,14,0,0,0,0,128);
		SKUL C 1 Bright A_SpawnItemEx("RS_SoulTrail",0,0,15,0,0,0,0,128);
		SKUL D 1 Bright A_SpawnItemEx("RS_SoulTrail",0,0,16,0,0,0,0,128);
		SKUL C 1 Bright A_SpawnItemEx("RS_SoulTrail",0,0,15,0,0,0,0,128);
		SKUL D 1 Bright A_SpawnItemEx("RS_SoulTrail",0,0,14,0,0,0,0,128);
		Loop;
	Death:
		SPIR B 0 A_SetScale(1.8);
		SPIR K 3 Bright A_Explode(random(20,70),200);
		SPIR L 3 Bright A_Explode(random(15,60),178);
		SPIR M 3 Bright A_Explode(random(10,50),158);
		SPIR N 3 Bright A_Explode(random(5,40),128);
		SPIR O 3 Bright;
		Stop;
	}
}

class RS_SoulTrail : Actor   // CH Hellknights.txt:3510
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 15;
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
		DamageType "Fire";   // CH: +FireDamage, the deprecated flag alias
	}
	States
	{
	Spawn:
		SPIR QRS 4;
		Goto Death;
	Death:
		SPIR S 6 Bright;
		Stop;
	}
}

class RS_SoulSmoke : Actor   // CH Hellknights.txt:3530
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 15;
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
	}
	States
	{
	Spawn:
		SPIR FGH 4;
		Goto Death;
	Death:
		SPIR IJ 3 Bright;
		Stop;
	}
}
