// ============================================================================
// RS_RevenantFX.zs -- Colourful Hell Revenant family: support actors,
// projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Revenants.txt
// (5,154 lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_Revenant.zs.
//
// ---------------------------------------------------------------------------
// CROSS-LANE OWNERSHIP (parallel swarm, CH file order Barons < Revenants <
// Fatsos < Spiders). Externals Revenants.txt names that CH defines in a LATER
// file defer to this lane, so they are built here:
//   RS_ZapFFAT             CH Fatsos.txt:269
//   RS_FatsoPuff3          CH Fatsos.txt:1880
//   RS_CyanCybieGunFlare   CH CYBIES.txt:1037
//   RS_CybieZappy          CH CYBIES.txt:4380
//   RS_TrailCB             CH CYBIES.txt:4428   (RS_CybieZappy's trail)
//   RS_CH_BoneGib          CH Gibs.txt:162      (root-level Gibs.txt, no lane)
//
// EXPECTED FROM THE BARONS LANE -- referenced by name here, NOT defined,
// because Barons.txt uses or defines them and Barons is the earlier lane:
//   RS_BrownVileGas     CH Archviles.txt:450   (Barons.txt uses it, 5 sites)
//   RS_FrostWingBaron   CH Barons.txt:822
//   RS_FrostWingBaron2  CH Barons.txt:850
// Until that lane lands these three spawn nothing; every other reference in
// both files resolves today.
// ALREADY LANDED BY THE BARONS LANE while this one was being written, so
// they are referenced read-only and NOT defined here even though CH defines
// them in Revenants.txt -- Barons.txt:2896/:2898 uses both, which under the
// file-order rule makes them Barons' to own:
//   RS_FireHand1    CH Revenants.txt:2556 -> zscript/monsters/baron/RS_BaronFX.zs:233
//   RS_BigBadFire1  CH Revenants.txt:2578 -> zscript/monsters/baron/RS_BaronFX.zs:258
//
// ALREADY OWNED -- CH defines these in Revenants.txt but earlier families
// imported them; referenced READ-ONLY here, never redefined:
//   RS_Trail11 (:1624, chaingunner FX); RS_MegaRedRev (:2855),
//   RS_RedRevLoad2 (:2880), RS_RedRevLoad (:2898) (hellknight/chaingunner FX);
//   RS_PsychPuff (:2279), RS_AcidBlast1 (:1595), RS_Zap7 (:1855),
//   RS_Purp1 (:2123), RS_Trail22 (:2153), RS_Trail12 (:1677),
//   RS_Homer1 (:2527), RS_RedDeathRev (:2916) (lostsoul FX);
//   RS_SpikeCyanRev (:446), RS_Splash11 (:1649) (demon FX);
//   RS_MinesRev (:3235), RS_RevNail (:3313) (cacodemon FX);
//   RS_BigBallCrev2, RS_Firespe1 (:2609), RS_Firespe2 (:2670),
//   RS_AbyssShotIdentifier (:217) (earlier lanes).
// Plus the ordinary shared set: RS_Zom, RS_ZomTierToken, RS_GrowRaisin,
// RS_CHBoner, RS_ThePlanBoner, RS_ColorTierIconCH..CH13, RS_HealthBundle,
// RS_ArmorBundle, RS_BackPackBundle, RS_ImplyingClip, RS_CH_Cirno,
// RS_SplashAbyss, RS_SplashAbyss2, RS_CrackoBallTrail, RS_ZAP88,
// RS_SparkPuff1, RS_ArcRing1, RS_ArchRingHelp, RS_HomingRocketTrailFatso,
// RS_HKRedDeath, RS_GrellSlowdown, RS_FatsoSpikes2, RS_PuffCybieRed,
// RS_PortalSummons, RS_MrBones, RS_TrailAbyPE1, RS_ZapZapCB, and the
// RS_CH_* pickup set (Berserk, BlueArmor, Cell, CellPack, GreenArmor,
// MegaSphere, PlasmaRifle, RocketAmmo, RocketBox, Shell, SoulSphere).
//
// ---------------------------------------------------------------------------
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Parent class "Loreshot" (CH BlackRevHook, Revenants.txt:3907). The
//     ONLY occurrence of that name anywhere in the CH tree is the inherit
//     line itself -- CH never defines it, so CH's own BlackRevHook fails to
//     spawn. Rebuilt here as a plain Actor carrying CH's whole body; nothing
//     substituted for the missing parent, flagged instead.
//   * Sprite DNKT frame A (RS_BlackRevenant3 / RS_BlackRevenantEX Scripted,
//     Revenants.txt:3052-3054, :3738-3740). Zero DNKT* lumps in the CH tree;
//     it is a transposition of DKNT on 1-tic states, invisible in CH too.
//     Kept verbatim.
//   * Sprite SBSI frame A (RS_Homer1's Spawn, Revenants.txt:2546 -- already
//     owned by the lostsoul lane, noted here for completeness). Zero SBSI*
//     lumps; a transposition of SBS1 on a 0-tic sound-only state.
//   * Sound "monster/dkdie" (RS_BlackRevenant3 + RS_BlackRevenantEX
//     DeathSound, Revenants.txt:3030, :3706). Not in CH's SNDINFO and no
//     matching lump in CH's sounds/ -- the Black Knight dies silent in CH
//     too. Kept verbatim. (CH DOES define monster/dkndie's siblings
//     dknact/dkndrt/dknhit/dknmsl/dknpai/dknswg; only dkdie is absent.)
//   * Translation "YellowRev01" (RS_YellowRevenant Script1,
//     Revenants.txt:2381). Defined at CH TRNSLATE.txt:10 as
//     YellowRev01 = "0:255=#[252,113,10]" but that line is NOT in this
//     repo's TRNSLATE.txt. Call kept verbatim; see the report.
//
// ---------------------------------------------------------------------------
// Standing strips, preserved at each site as "// CH:" comments so nothing is
// silently gutted: ACS announcers (BrownRevSPEED, AnnounceBlackRev,
// AnnounceWhiteRev, RevKillEx, RevBuffEx); the gore chain (XDeath ANIMATIONS
// stay); DRLA RLRevenantsLauncherPickup / RLDemonicWeaponSpawner drops.
//
// Conversion rules applied throughout (all from real compile errors):
// rolls -> DamageFunction (random(a,b)) and bare Damage N stays bare;
// CallACS -> RS_Zom.CV('rs_ch_*', CH default) with CH's value semantics
// (1 = colour off/reroll, 3 = fifty-fifty); A_SetUserVar -> anon blocks over
// real members; A_ChangeFlag -> { bFLAG = x; }; ThrustThing angle
// expressions wrapped in int(); A_RadiusGive filter 0 -> null; "none"
// spawnclass -> null; +DOOMBOUNCE -> BounceType "Doom".
// Deprecation warnings (MISSILEMORE, VelX, A_CustomMissile, A_ChangeFlag)
// are CH's idiom kept verbatim and are not errors.
// ============================================================================

// ---------------------------------------------------------------------------
// Brown revenant's kit.  CH: Revenants.txt:41-215.
// ---------------------------------------------------------------------------
class RS_RevSpeedBuff : CustomInventory   // CH Revenants.txt:41
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
		TNT1 A 0;
		// CH: TNT1 A 0 ACS_NamedExecuteAlways("BrownRevSPEED") -- ACS speed
		// announcer/booster stripped per the standing order.
		TNT1 A 0;
		Stop;
	}
}

class RS_BrownRevBall : Actor   // CH Revenants.txt:168
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		DamageFunction (random(5,40));   // CH: Damage (random(5,40))
		DamageType "Plasma";
		Projectile;
		ProjectileKickBack 500;
		+RANDOMIZE
		+DONTHARMCLASS
		+SEEKERMISSILE
		SeeSound "imp/attack";
		DeathSound "Crack/death";
		Translation "0:255=[128,255,255]:[0,128,255]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RCHB AA 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB BB 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB ABAB 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB B 2 Bright A_SeekerMissile(45,45,SMF_PRECISE);
		Goto Fly2;
	Fly2:
		RCHB A 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB B 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB AB 2 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(1,3),0,0,1,random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB B 2 Bright A_Jump(64,"Turn");
	Turn:
		RCHB A 1 Bright A_SeekerMissile(45,45,SMF_PRECISE);
		Goto Fly2;
	Death:
		TNT1 A 0 A_SetScale(1.6,1.6);
		TNT1 A 0 A_RadiusGive("RS_GrellSlowdown",64,RGF_PLAYERS|RGF_CUBE,1);
		TNT1 AAAAAAA 0 A_SpawnItemEx("RS_ZapFFAT",random(-3,3),random(-3,3),random(-1,1),random(1,6),0,random(-15,15),random(-359,359),SXF_TRANSFERTRANSLATION);
		RCHB CDE 4 Bright A_Explode(random(6,9),64);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cyan revenant's kit.  CH: Revenants.txt:406-560.
// ---------------------------------------------------------------------------
class RS_BigBallCrev : Actor   // CH Revenants.txt:406
{
	Default
	{
		Radius 10;
		Height 10;
		Speed 38;
		Scale 1.25;
		RenderStyle "Add";
		Alpha 0.95;
		DamageFunction (random(3,30));   // CH: Damage (random(3,30))
		DamageType "Ice";
		Projectile;
		+SEEKERMISSILE
		+DONTHARMCLASS
		SeeSound "imp/attack";
		DeathSound "Ice/Hit2";
	}
	// CH: xscale 1.25 / yscale 0.75 -- Default only takes one Scale, so the
	// non-uniform pair is applied at spawn, same numbers.
	override void PostBeginPlay() { Super.PostBeginPlay(); Scale = (1.25, 0.75); }
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CHCY ABC 2 Bright A_SpawnItemEx("RS_BigBallCrev2",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		CHCY C 1 Bright A_SeekerMissile(18,18,SMF_PRECISE);
		CHCY DFG 2 Bright A_SpawnItemEx("RS_BigBallCrev2",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		CHCY G 1 Bright A_SeekerMissile(18,18,SMF_PRECISE);
		Loop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(0,90));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(89,180));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(181,270));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,40),0,random(5,25),random(271,359));
		PUFI ABCD 1 Bright A_SetTranslucent(0.4);
		PUFI EFGH 1 Bright;
		Stop;
	}
}

class RS_IceORBCyanRev : Actor   // CH Revenants.txt:473
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 20;
		DamageFunction (random(5,21));   // CH: Damage (random(5,21))
		DamageType "Ice";
		Projectile;
		Scale 0.75;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		ICEY A 3 Bright;
		ICEY B 3 Bright A_ScaleVelocity(1.25);
		ICEY C 3 Bright;
		Loop;
	Death:
		ICEY ABC 1 Bright;
		ICEY A 1 Bright A_Stop;
		ICEY BCA 1 Bright;
		ICEY BCABC 1 Bright;
		TNT1 A 0 A_SetScale(4,4);
		ICEY F 3 Bright A_Explode(random(10,80),128);
		ICEY GHI 2 Bright;
		Stop;
	}
}

class RS_ChainWhipRev : Actor   // CH Revenants.txt:505
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 29;
		Mass 500;
		DamageFunction (random(11,33));   // CH: Damage (random(11,33))
		Projectile;
		DamageType "Melee";
		+NOGRAVITY
		+THRUGHOST
		Gravity 1.25;
		Scale 0.25;
		DeathSound "weapons/boom1";
		Translation "144:151=90:95","64:79=96:109","236:239=104:111","1:2=111:111";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		RIP1 ABCB 2 Bright A_SpawnItemEx("RS_ChainWhipRev2",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: a_changeflag("NOGRAVITY",FALSE)
		RIP1 ABC 1 Bright A_SpawnItemEx("RS_ChainWhipRev2",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		RIP1 ABCA 2 A_Explode(random(1,4),8);
		RIP1 BCAB 2 A_Explode(random(1,4),8);
		RIP1 CBA 3 A_Explode(random(1,4),8);
		Stop;
	}
}

class RS_ChainWhipRev2 : Actor   // CH Revenants.txt:537
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 9;
		Mass 500;
		DamageFunction (random(1,9));   // CH: Damage (random(1,9))
		Projectile;
		DamageType "Melee";
		-NOGRAVITY
		+THRUGHOST
		Gravity 1.0;
		Scale 0.25;
		DeathSound "";
		Translation "144:151=90:95","64:79=96:109","236:239=104:111","1:2=111:111";
	}
	States
	{
	Spawn:
		RIP1 ABC 2 Bright;
	Death:
		RIP1 CBA 2 A_Explode(random(1,4),8);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Abyss revenant's kit.  CH: Revenants.txt:722-803.
// ---------------------------------------------------------------------------
class RS_CrackedAbyssRev : Actor   // CH Revenants.txt:722
{
	Default
	{
		Radius 4;
		Species "Revenant";
		Height 4;
		Speed 18;
		DamageFunction (random(6,66));   // CH: Damage (random(6,66))
		DamageType "Plasma";
		Projectile;
		+SEEKERMISSILE
		Scale 0.85;
		RenderStyle "Add";
		Alpha 1.95;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "Ice";
	}
	States
	{
	Spawn:
		BLL9 AA 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ZAP88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 AA 1 Bright A_SeekerMissile(6,9,SMF_PRECISE);
		TNT1 A 0 A_SpawnItemEx("RS_ZAP88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",random(-12,12),random(-12,12),random(-12,12),random(1,5),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 BB 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RS_ZAP88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 AA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",random(-12,12),random(-12,12),random(-12,12),random(1,5),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BLL9 BB 1 Bright A_SeekerMissile(9,6,SMF_PRECISE);
		TNT1 A 0 A_SpawnItemEx("RS_ZAP88",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 AAAA 0 A_SpawnItemEx("RS_ZAP88",random(-32,32),random(-32,32),random(-32,32),0,0,0,0,SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Explode(random(6,66),66,0);
		BLL9 CDE 6 Bright;
		Stop;
	}
}

class RS_IceORbAbyssRev : Actor   // CH Revenants.txt:760
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 15;
		VSpeed 1.1;
		DamageFunction (random(6,55));   // CH: Damage (random(6,55))
		DamageType "Ice";
		Projectile;
		+SEEKERMISSILE
		-NOGRAVITY
		+BOUNCEONFLOORS
		BounceType "Doom";
		BounceCount 2;
		BounceFactor 1.5;
		WallBounceFactor 1.5;
		Scale 2;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 3 Bright A_SeekerMissile(6,6);
		TNT1 AA 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		ICEY B 3 Bright A_ScaleVelocity(1.5);
		ICEY C 3 Bright A_Weave(0,3,0,4);
		Loop;
	Death:
		ICEY ABC 1 Bright;
		ICEY A 1 Bright A_Stop;
		ICEY BCA 6 Bright;
		ICEY BCABC 6 Bright;
		TNT1 A 0 A_SetScale(4,4);
		ICEY F 3 Bright A_Explode(random(40,130),128);
		ICEY GHI 2 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-24,24),random(-528,528),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-528,528),random(-24,24),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Fire-blue revenant's kit.  CH: Revenants.txt:967-1152.
// ---------------------------------------------------------------------------
class RS_FBSkelCH01 : Actor   // CH Revenants.txt:967
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		Damage 3;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
		Translation "0:255=%[0.35,0.00,0.00]:[2.00,0.50,0.50]";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Goto Fly;
	Fly:
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("nogravity",FALSE)
		PLSS AB 6 Bright;
		Loop;
	XDeath:
		MISL BCD 6 Bright A_Explode(random(7,18),64,0);
		Stop;
	Death:
		TNT1 A 0 { bFLATSPRITE = true; }   // CH: A_changeflag("flatsprite",true)
		MISL BCD 6 Bright A_Explode(random(7,18),64,0);
		Stop;
	}
}

class RS_FBSkelCH02 : Actor   // CH Revenants.txt:1003
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		Damage 3;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
		Translation "0:255=%[0.00,0.00,0.94]:[0.80,0.80,2.00]";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Goto Fly;
	Fly:
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("nogravity",FALSE)
		PLSS AB 6 Bright;
		Loop;
	XDeath:
		MISL BCD 6 Bright A_Explode(random(7,18),64,0);
		Stop;
	Death:
		TNT1 A 0 { bFLATSPRITE = true; }   // CH: A_changeflag("flatsprite",true)
		MISL BCD 6 Bright A_Explode(random(7,18),64,0);
		Stop;
	}
}

class RS_FBSkelCH03 : Actor   // CH Revenants.txt:1039
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 17;
		Damage 3;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
		Translation "0:255=%[0.35,0.00,0.00]:[2.00,0.50,0.50]";
		RenderStyle "Add";
		WeaveIndexXY 10;
		WeaveIndexZ 1;
		Alpha 0.95;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		PLSS A 3 Bright A_Weave(6,0,-1.5,0.0);
		TNT1 A 0 A_SpawnItemEx("RS_FBSkelTrailer2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		PLSS B 3 Bright A_Weave(6,0,-1.5,0.0);
		TNT1 A 0 A_SpawnItemEx("RS_FBSkelTrailer2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		MISL BCD 6 Bright A_Explode(random(5,15),64,0);
		Stop;
	}
}

class RS_FBSkelCH04 : Actor   // CH Revenants.txt:1073
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 17;
		Damage 3;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "fire/fire3";
		DeathSound "weapons/plasmax";
		Translation "0:255=%[0.00,0.00,0.94]:[0.80,0.80,2.00]";
		WeaveIndexXY 10;
		WeaveIndexZ 1;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		PLSS A 3 Bright A_Weave(6,0,1.5,0.0);
		TNT1 A 0 A_SpawnItemEx("RS_FBSkelTrailer",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		PLSS B 3 Bright A_Weave(6,0,1.5,0.0);
		TNT1 A 0 A_SpawnItemEx("RS_FBSkelTrailer",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		MISL BCD 6 Bright A_Explode(random(5,15),64,0);
		Stop;
	}
}

class RS_FBSkelTrailer : Actor   // CH Revenants.txt:1107
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 0;
		+NOCLIP
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.45;
		Translation "0:255=%[0.35,0.00,0.00]:[2.00,0.50,0.50]";
	}
	States
	{
	Spawn:
		PLSS AB 4 Bright;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_FBSkelTrailer2 : RS_FBSkelTrailer   // CH Revenants.txt:1127
{
	Default { Translation "0:255=%[0.00,0.00,0.94]:[0.80,0.80,2.00]"; }
}

class RS_BoomSkel1 : Actor   // CH Revenants.txt:1129
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 10;
		Damage 4;
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		MISL B 2 Bright A_Explode(random(20,50),64,0);
		MISL CD 2 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Gray revenant's kit.  CH: Revenants.txt:1285-1339.
// ---------------------------------------------------------------------------
class RS_BoneToPickGrey : Actor   // CH Revenants.txt:1285
{
	Default
	{
		Radius 4;
		Height 4;
		DamageFunction (random(10,40));   // CH: Damage (random(10,40))
		Speed 36;
		DamageType "Melee";
		Projectile;
		+BLOODLESSIMPACT
		+SKYEXPLODE
		+FORCEPAIN
		Scale 0.75;
		Translation "0:255=[129,129,129]:[255,255,255]";
		SeeSound "skelatt";
		DeathSound "swordhit";
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
		Stop;
	XDeath:
		TNT1 AAAAA 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 A 1 A_PlaySound("COCONUTT",0);
		TNT1 A 1 A_SpawnItemEx("RS_BoneToPickGray2",0,0,42,random(1,3),0,random(1,6),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_BoneToPickGray2 : Actor   // CH Revenants.txt:1319
{
	Default
	{
		Projectile;
		Radius 2;
		Height 2;
		Speed 10;
		-NOGRAVITY
		+THRUACTORS
		Scale 0.75;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		BBBN ABCD 1 Bright;
		Loop;
	Death:
		BBBN "#" 20;   // CH: BBBN "#" 20 -- '#' keeps the last drawn frame
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Common revenant's tracer.  CH: Revenants.txt:1462.
// ---------------------------------------------------------------------------
class RS_RevenantTracer2 : RevenantTracer   // CH Revenants.txt:1462
{
	Default
	{
		DamageType "fire";
		DamageFunction (random(5,50));   // CH: Damage (random(5,50))
	}
}

// ---------------------------------------------------------------------------
// Blue revenant's kit.  CH: Revenants.txt:1881 (RS_Zap7 is chaingunner-owned).
// ---------------------------------------------------------------------------
class RS_Zap8 : Actor   // CH Revenants.txt:1881
{
	Default
	{
		Radius 3;
		Height 8;
		Speed 15;
		FastSpeed 38;
		DamageFunction (random(11,33));   // CH: Damage (random(11,33))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Scale 0.5;
		Alpha 0.75;
		SeeSound "weapons/plasmaf";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSE A 2 Bright A_ScaleVelocity(1.15);
		Loop;
	Death:
		PLSE CDE 6 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Purple revenant's ambient sparks.  CH: Revenants.txt:2081-2121.
// ---------------------------------------------------------------------------
class RS_Zap99 : Actor   // CH Revenants.txt:2081
{
	Default
	{
		Speed 1;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.65;
	}
	States
	{
	Spawn:
		LITN ABCDEFGFEDB 1 Bright;
		LITN A 0 A_CustomMissile("RS_Bounc34",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LITN A 0 A_CustomMissile("RS_Bounc34",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		LITN A 0 A_CustomMissile("RS_Bounc34",2,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Stop;
	}
}

class RS_Bounc34 : Actor   // CH Revenants.txt:2100
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 12;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.15;
		Translation "168:191=250:254","208:223=250:254";
	}
	States
	{
	Spawn:
		BAL1 AB 1 Bright;
		Goto Death;
	Death:
		BAL1 CDE 1 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Orange ("Yellow") revenant's kit.  CH: Revenants.txt:2302-2704.
// RS_Homer1, RS_Firespe1, RS_Firespe2 are already owned by earlier lanes.
// ---------------------------------------------------------------------------
class RS_ArchvileFire2 : ArchvileFire   // CH Revenants.txt:2302
{
	Default
	{
		Speed 5;
		Damage 0;
		Projectile;
		+NOCLIP
		+THRUACTORS
	}
}

// CH Revenants.txt:2556 (Firehand1) and :2578 (BigBadFire1) are NOT defined
// here: Barons.txt uses both (Barons.txt:2896, :2898), so under the CH
// file-order rule they belong to the earlier lane, and that lane has landed
// them at zscript/monsters/baron/RS_BaronFX.zs:233 (RS_FireHand1) and :258
// (RS_BigBadFire1). Referenced read-only from RS_YellowRevenant's HellFlame.
// NOTE the spelling: Barons' class is RS_FireHand1 with a capital H, and
// ZScript is case-insensitive -- defining RS_Firehand1 here would be a fatal
// redefinition, not a second class.

class RS_FirespeNewYel : Actor   // CH Revenants.txt:2641
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 24;
		Mass 2;
		Projectile;
		DamageFunction (random(8,24));   // CH: Damage(random(8,24))
		DamageType "Fire";
		RenderStyle "Add";
		SeeSound "Fire/fire1";
		Alpha 0.8;
	}
	States
	{
	Spawn:
		FLUM ABCDE 3 Bright;
		TNT1 A 0 ThrustThingZ(0,random(6,18),0,0);
		FLUM ABCDE 3 Bright;
		Goto Death;
	Death:
		MISL B 5 Bright;
		MISL C 5 Bright A_Explode(7,64);
		MISL D 5 Bright A_SpawnItemEx("RS_FireSpe2",0,0,0,random(3,9),0,0,random(0,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Black Knight's kit.  CH: Revenants.txt:3147-3449.
// ---------------------------------------------------------------------------
class RS_ShieldBlastRev : Actor   // CH Revenants.txt:3147
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 12;
		DamageFunction (random(10,65));   // CH: Damage (random(10,65))
		DamageType "Fire";
		Projectile;
		+SEEKERMISSILE
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.45;
		SeeSound "fire/fire3";
		DeathSound "spell/Impact1";
		Translation "76:79=44:47","136:143=184:191","128:136=175:183","64:79=176:191","208:223=171:181","161:161=170:170","144:151=180:191";
	}
	// CH: yScale 1.45 / xScale 1.0 -- non-uniform pair applied at spawn.
	override void PostBeginPlay() { Super.PostBeginPlay(); Scale = (1.0, 1.45); }
	States
	{
	Spawn:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
	Fly:
		FRGO DD 2 Bright A_SetSpeed(16);
	Fly2:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
	Fly3:
		FRGO DD 2 Bright A_SetSpeed(20);
	Fly4:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
	Fly5:
		FRGO DD 2 Bright A_SetSpeed(24);
	Fly6:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
	Fly7:
		FRGO DD 2 Bright A_SetSpeed(30);
	Fly8:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
		FRGO DD 2 Bright A_SeekerMissile(12,18);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1.5);
		BBOM B 2 A_SetTranslucent(0.65);
		BBOM CD 3 Bright A_Explode(random(5,25),148);
		BBOM EFG 6 Bright A_Explode(random(5,20),148);
		Stop;
	}
}

class RS_RevShieldWalk : Actor   // CH Revenants.txt:3196
{
	Default
	{
		Radius 64;
		Height 56;
		Speed 0;
		Species "MontyP";
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
		+THRUSPECIES
		-COUNTKILL
		RenderStyle "Add";
		Alpha 1.75;
		Scale 1.25;
	}
	States
	{
	Spawn:
		DKNT Z 3 Bright A_Warp(AAPTR_MASTER,24,0,42,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		DKNT Z 3 Bright A_Warp(AAPTR_MASTER,24,0,42,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		DKNT Z 3 Bright A_Warp(AAPTR_MASTER,24,0,42,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	Death:
		DKNT Z 2 Bright A_NoBlocking;
		DKNT Z 2 Bright A_SetScale(1);
		DKNT Z 2 Bright A_SetScale(0.7);
		DKNT Z 2 Bright A_SetScale(0.4);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_DKDart : Actor   // CH Revenants.txt:3343
{
	Default
	{
		Radius 3;
		Height 12;
		Speed 28;
		Damage 5;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 1.00;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		SeeSound "monster/dkndrt";
		DeathSound "weapons/firex2";
	}
	States
	{
	Spawn:
		DKAT ABC 3 Bright;
		Loop;
	Death:
		DKAT D 0 A_SetTranslucent(0.85,1);
		DKAT D 3 Bright;
		DKAT E 3 Bright A_Explode(random(5,55),64);
		DKAT FG 3 Bright;
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,45,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,90,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,135,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,180,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,225,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,270,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,315,2);
		DKAT H 3 Bright A_CustomMissile("RS_DKFire",0,0,0,2);
		DKAT IJKLM 3 Bright;
		Stop;
	}
}

class RS_DKFire : Actor   // CH Revenants.txt:3380
{
	Default
	{
		Radius 2;
		Height 6;
		Speed 6;
		Damage 0;
		ExplosionDamage 4;
		ExplosionRadius 8;
		RenderStyle "Add";
		Alpha 0.95;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		DeathSound "weapons/scorch";
	}
	States
	{
	Spawn:
		DKAT NOPQRSTNOPQRSTNOPQRST 3 Bright A_Explode;
		Goto Death;
	Death:
		DKAT UVW 3 Bright A_Explode;
		Stop;
	}
}

class RS_DKSword : Actor   // CH Revenants.txt:3405
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 1;
		Projectile;
		RenderStyle "Normal";
		-NOGRAVITY
		Gravity 0.125;   // was +LOWGRAVITY (engine sets Gravity = 1/8)
	}
	States
	{
	Spawn:
		SWRD KLMNOPQ 3 Bright;
		Goto Death;
	Death:
		SWRD RS 4 Bright;
		SWRD T 4 Bright;
		SWRD U 4;
		SWRD T 4 Bright;
		SWRD U 8;
		SWRD T 4 Bright;
		SWRD U 16;
		SWRD T 4 Bright;
		SWRD U -1;
		Stop;
	}
}

class RS_DKShield : Actor   // CH Revenants.txt:3432
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 1;
		Projectile;
		RenderStyle "Normal";
		-NOGRAVITY
		Gravity 0.125;   // was +LOWGRAVITY (engine sets Gravity = 1/8)
	}
	States
	{
	Spawn:
		SHLD ABCDEFGHI 3;
		Goto Death;
	Death:
		SHLD H -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Black Knight phase 2's kit.  CH: Revenants.txt:3571-3663.
// ---------------------------------------------------------------------------
class RS_SoulSeekerRev : Actor   // CH Revenants.txt:3571
{
	Default
	{
		Radius 4;
		Height 8;
		Speed 22;
		DamageFunction (random(5,20));   // CH: Damage (random(5,20))
		RenderStyle "Add";
		DamageType "Melee";
		Alpha 0.85;
		Scale 0.45;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		+SEEKERMISSILE
		SeeSound "skull/melee";
		DeathSound "weapons/firex2";
		Translation "175:191=193:207","32:47=240:246";
	}
	States
	{
	Spawn:
		UNHE AB 4 Bright A_SeekerMissile(12,24,SMF_PRECISE);
		Loop;
	Death:
		DKAT D 0 A_SetTranslucent(0.85,1);
		DKAT D 3 Bright A_SetScale(1);
		DKAT E 3 Bright A_Explode(random(5,20),64);
		DKAT FGH 3 Bright;
		DKAT IJKLM 3 Bright;
		Stop;
	}
}

class RS_RevSol : Actor   // CH Revenants.txt:3603
{
	Default
	{
		Radius 3;
		Height 12;
		Speed 32;
		DamageFunction (random(10,50));   // CH: Damage (random(10,50))
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		SeeSound "monster/dkndrt";
		DeathSound "weapons/firex2";
		Translation "175:191=160:167";
	}
	States
	{
	Spawn:
		DKAT ABC 3 Bright;
		Loop;
	Death:
		DKAT D 0 A_SetTranslucent(0.85,1);
		DKAT D 3 Bright A_SetScale(1.5);
		DKAT E 3 Bright A_Explode(random(5,30),128);
		DKAT FGH 3 Bright;
		DKAT IJKLM 3 Bright;
		Stop;
	}
}

class RS_DKFire2 : Actor   // CH Revenants.txt:3632
{
	Default
	{
		Radius 2;
		Height 6;
		Speed 8;
		Damage 0;
		RenderStyle "Add";
		Alpha 0.95;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		DeathSound "weapons/scorch";
		Translation "168:191=192:208","32:47=201:207";
	}
	States
	{
	Spawn:
		DKAT NOPQRSTNOPQRSTNOPQRST 3 Bright A_Explode(random(5,15),12);
		DKAT N 4 A_Jump(12,"Death");
		Loop;
	Death:
		DKAT UVW 3 Bright A_Explode(random(5,20),20);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,45,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,90,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,135,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,180,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,225,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,270,2);
		DKAT H 0 A_CustomMissile("RS_DKFire",0,0,315,2);
		DKAT H 3 Bright A_CustomMissile("RS_DKFire",0,0,0,2);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black Knight EX support.  CH: Revenants.txt:3884-4219.
// ---------------------------------------------------------------------------
class RS_BlackRevShade : Actor   // CH Revenants.txt:3884
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Stencil";
		StencilColor "black";
		SeeSound "Imp/Attack";
		DeathSound "Fire/fire5";
		Alpha 0.55;
		Scale 1.95;
	}
	// CH: yScale 3.25 / xScale 1.95 -- non-uniform pair applied at spawn.
	override void PostBeginPlay() { Super.PostBeginPlay(); Scale = (1.95, 3.25); }
	States
	{
	Spawn:
		FLUM ACDBE 3 Bright;
		Stop;
	}
}

// PROVEN MISSING IN CH: CH declares "ACTOR BlackRevHook : Loreshot"
// (Revenants.txt:3907) but the name Loreshot appears NOWHERE else in the
// entire CH tree -- there is no such actor, so CH's own BlackRevHook does
// not exist at load. Rebuilt here on Actor with CH's whole body verbatim;
// nothing invented to stand in for the absent parent.
class RS_BlackRevHook : Actor   // CH Revenants.txt:3907 -- parent Loreshot undefined in CH
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 42;
		DamageFunction (random(5,30));   // CH: Damage (random(5,30))
		Projectile;
		DamageType "Melee";
		+THRUGHOST
		+MTHRUSPECIES
		SeeSound "monster/dknmsl";
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		BLAD A 1 Bright A_SpawnItemEx("RS_FatsoSpikes2",0,0,1,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BLAD A 10;
		BLAD A 10;
		BLAD AAA 10 A_FadeOut(0.33);
		Stop;
	}
}

class RS_RevShieldWalk2 : Actor   // CH Revenants.txt:3932
{
	Default
	{
		Radius 64;
		Height 56;
		Speed 16;
		Species "MontyP";
		Health 999;
		Monster;
		+NOTRIGGER
		+NOTARGET
		+DONTTHRUST
		+NOGRAVITY
		+INVULNERABLE
		+MTHRUSPECIES
		+REFLECTIVE
		+DEFLECT
		+SHIELDREFLECT
		+THRUSPECIES
		-COUNTKILL
		RenderStyle "Add";
		Alpha 1.75;
		Scale 1.25;
	}
	int user_angle;   // CH: var int user_angle;
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 { user_angle = user_angle + 8; }   // CH: A_SetUserVar("user_angle",user_angle + 8)
		DKNT Z 1 Bright A_Warp(AAPTR_TARGET,64,0,64,user_angle + 8,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 A_Jump(2,"Death");
		Loop;
	Death:
		DKNT Z 2 Bright A_NoBlocking;
		DKNT Z 2 Bright A_SetScale(1);
		DKNT Z 2 Bright A_SetScale(0.7);
		DKNT Z 2 Bright A_SetScale(0.4);
		Stop;
	}
}

class RS_ShieldBombRev : Actor   // CH Revenants.txt:3974
{
	Default
	{
		Radius 4;
		Height 6;
		Mass 5;
		Speed 34;
		Projectile;
		Scale 0.55;
		DamageFunction (random(2,25));   // CH: Damage (random(2,25))
		DamageType "Fire";
		SeeSound "imp/attack";
		DeathSound "weapons/firex4";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 ABA 1;
		Loop;
	Death:
		BAL1 CDE 1 A_SetTranslucent(0.35);
		Stop;
	}
}

class RS_BRevEye : Actor   // CH Revenants.txt:3998
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.08;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "112:127=174:183";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BFE1 C 1 Bright A_Warp(AAPTR_TARGET,9,4,40,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 1 Bright A_Warp(AAPTR_TARGET,9,4,40,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BRevEye2 : Actor   // CH Revenants.txt:4025
{
	Default
	{
		Radius 40;
		Height 70;
		Speed 1;
		RenderStyle "Add";
		Alpha 1.25;
		Scale 0.08;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		Translation "112:127=174:183";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Live;
	Live:
		BFE1 C 1 Bright A_Warp(AAPTR_TARGET,9,-4,40,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		BFE1 B 1 Bright A_Warp(AAPTR_TARGET,9,-4,40,0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE|WARPF_COPYVELOCITY);
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_BlackRevShade2 : Actor   // CH Revenants.txt:4052
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Stencil";
		StencilColor "black";
		SeeSound "Imp/Attack";
		DeathSound "Fire/fire5";
		Alpha 0.85;
		Scale 1.05;
	}
	States
	{
	Spawn:
		WRTH AB 3 Bright;
	Fly:
		WRTH A 2 Bright A_SetScale(1.25,1.25);
		WRTH B 2 Bright A_SetScale(1.33,1.33);
		Stop;
	}
}

class RS_SoulSeekerRevex : Actor   // CH Revenants.txt:4078
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 19;
		DamageFunction (random(10,30));   // CH: Damage (random(10,30))
		RenderStyle "Add";
		DamageType "Melee";
		Alpha 0.85;
		Scale 0.35;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		+SEEKERMISSILE
		SeeSound "skull/melee";
		DeathSound "weapons/firex2";
		Translation "177:191=192:200","44:47=198:203","176:176=192:192","175:175=247:247","32:43=202:207";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		UNHE A 2 Bright A_SpawnItemEx("RS_SoulSeekerRevTrail",0,0,1,0,0,0,0);
		UNHE B 2 Bright A_SeekerMissile(5,10);
		Loop;
	Death:
		DKAT D 0 A_SetTranslucent(0.85,1);
		DKAT D 3 Bright A_SetScale(2.4,0.75);
		DKAT E 3 Bright A_Explode(random(10,30),128);
		DKAT FGH 3 Bright;
		DKAT IJKLM 3 Bright;
		Stop;
	}
}

class RS_SoulSeekerRevTrail : Actor   // CH Revenants.txt:4113
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 1;
		Projectile;
		+NOCLIP
		+NOINTERACTION
		RenderStyle "Stencil";
		StencilColor "cyan";
		Alpha 0.85;
		Scale 0.35;
	}
	States
	{
	Spawn:
		UNHE AB 6 Bright;
	Fly:
		UNHE AB 2 Bright A_SetScale(0.25,0.25);
		UNHE AB 2 Bright A_SetScale(0.1,0.1);
		Stop;
	}
}

class RS_RevSolex : Actor   // CH Revenants.txt:4136
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 34;
		DamageFunction (random(10,50));   // CH: Damage (random(10,50))
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		+BOUNCEONWALLS
		BounceType "Hexen";
		BounceCount 2;
		BounceFactor 1.5;
		SeeSound "monster/dkndrt";
		DeathSound "weapons/firex2";
		Translation "175:191=160:167";
	}
	States
	{
	Spawn:
		DKAT ABC 3 Bright;
		Loop;
	Death:
		DKAT D 0 A_SetTranslucent(0.85,1);
		DKAT D 3 Bright A_SetScale(1.5);
		DKAT E 3 Bright A_Explode(random(5,30),128);
		DKAT FGH 3 Bright;
		DKAT IJKLM 3 Bright;
		Stop;
	}
}

class RS_RainFireRevEX : Actor   // CH Revenants.txt:4169
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 15;
		DamageFunction (random(5,12));   // CH: Damage (random(5,12))
		RenderStyle "Add";
		Alpha 0.95;
		Projectile;
		+THRUGHOST
		+DONTHARMCLASS
		+MTHRUSPECIES
		DeathSound "weapons/scorch";
	}
	States
	{
	Spawn:
		DKAT NOPQRSTNOPQRSTNOPQRST 1 Bright A_SpawnItemEx("RS_RainFireRevEXTrail",0,0,0,random(-10,10),0,random(-10,10),random(-359,359),SXF_NOCHECKPOSITION);
		Loop;
	Death:
		DKAT UVW 3 Bright A_Explode(random(2,8),32,0);
		Stop;
	}
}

class RS_RainFireRevEXTrail : Actor   // CH Revenants.txt:4193
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 10;
		RenderStyle "Add";
		DamageFunction (random(1,3));   // CH: Damage (random(1,3))
		Alpha 0.55;
		Mass 10;
		Gravity 0.05;
		Projectile;
		+THRUGHOST
		-NOGRAVITY
		+DONTHARMCLASS
		+MTHRUSPECIES
		Scale 0.85;
		DeathSound "weapons/scorch";
	}
	States
	{
	Spawn:
		DKAT NOPQRSTNOPQRSTNOPQRST 1 Bright A_Explode(random(1,3),16,0);
		Goto Death;
	Death:
		DKAT UVW 3 Bright A_Explode(random(1,3),16,0);
		Stop;
	}
}

// The two EX bookkeeping tokens.  CH: Revenants.txt:4425, :4441.
// Both were pure ACS triggers; the ACS is stripped and the tokens kept,
// because RS_BlackRevEx3 tests for RS_PowerRevEx by inventory.
class RS_PowerRevEx : CustomInventory   // CH Revenants.txt:4425
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
		TNT1 A 0;
		// CH: TNT1 A 0 ACS_NamedExecuteAlways("RevKillEx") -- ACS stripped.
		TNT1 A 0;
		Stop;
	}
}

class RS_PowerRevEx2 : CustomInventory   // CH Revenants.txt:4441
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
		TNT1 A 0;
		// CH: TNT1 A 0 ACS_NamedExecuteAlways("RevBuffEx") -- ACS stripped.
		TNT1 A 0;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The Lich (white revenant) kit.  CH: Revenants.txt:4761-5154.
// ---------------------------------------------------------------------------
class RS_WhiteRevCoil : Actor   // CH Revenants.txt:4761
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 24;
		DamageFunction (random(40,90));   // CH: Damage (random(40,90))
		DamageType "Melee";
		Projectile;
		+THRUACTORS
		+SEEKERMISSILE
		Scale 0.15;
		SeeSound "baron/attack";
		DeathSound "weapons/rocklx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		AYPE Y 2 Bright A_Explode(random(18,28),64);
		AYPE Y 2 Bright A_SpawnItemEx("RS_TrailAbyPE1",-1,0,3,random(1,5),0,0,0);
		AYPE Y 0 A_SeekerMissile(4,5);
		TNT1 A 0 A_Jump(32,"Fly2");
		Loop;
	Fly2:
		AYPE Y 2 Bright A_Explode(random(18,28),64);
		AYPE Y 2 Bright A_SpawnItemEx("RS_TrailAbyPE1",-1,0,3,random(1,5),0,0,0);
		AYPE Y 0 A_SeekerMissile(1,1);
		TNT1 A 0 A_Jump(64,"Fly");
		Loop;
	Death:
		BAL1 CDE 2 Bright A_Explode(random(5,25),128);
		TNT1 AAAAAAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_WhiteRevCoil2 : RS_WhiteRevCoil { Default { Speed 12; } }   // CH Revenants.txt:4798
class RS_WhiteRevCoil3 : RS_WhiteRevCoil { Default { Speed 18; } }   // CH Revenants.txt:4799
class RS_WhiteRevCoil4 : RS_WhiteRevCoil { Default { Speed 30; } }   // CH Revenants.txt:4800

class RS_WhiteRevFrostBolt : Actor   // CH Revenants.txt:4802
{
	Default
	{
		Radius 8;
		Height 4;
		Speed 35;
		Projectile;
		+BRIGHT
		RenderStyle "Add";
		DamageType "Ice";
		DamageFunction (random(30,90));   // CH: Damage (random(30,90))
		Scale 1.0;
		SeeSound "weapons/rocklf";
		DeathSound "Bomb/boom";
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		// RS_FrostWingBaron is EXPECTED FROM THE BARONS LANE (CH Barons.txt:822).
		CHCY A 2 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",random(-16,16),random(-16,16),random(-16,16),0,0,0,0);
		CHCY B 2 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",random(-16,16),random(-16,16),random(-16,16),0,0,0,0);
		CHCY C 2 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",random(-16,16),random(-16,16),random(-16,16),0,0,0,0);
		CHCY D 2 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",random(-16,16),random(-16,16),random(-16,16),0,0,0,0);
		CHCY F 2 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",random(-16,16),random(-16,16),random(-16,16),0,0,0,0);
		CHCY G 2 Bright A_SpawnItemEx("RS_FrostWingBaron",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",random(-16,16),random(-16,16),random(-16,16),0,0,0,0);
		Loop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_SetScale(1.33,1.0);
		PUFI ABCD 3 Bright;
		TNT1 AAAAAAAAAAAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",0,0,0,random(10,20),0,random(-15,15),random(0,180));
		TNT1 AAAAAAAAAAAAA 0 A_SpawnItemEx("RS_FrostMistWhiteRev",0,0,0,random(10,20),0,random(-15,15),random(180,359));
		TNT1 A 0 A_Explode(random(20,120),128,0);
		PUFI EFGH 2 Bright;
		Stop;
	}
}

class RS_IceGroundWhiteRev : Actor   // CH Revenants.txt:4847
{
	Default
	{
		Radius 9;
		Height 9;
		DamageType "Ice";
		DamageFunction (random(33,66));   // CH: Damage (random(33,66))
		Projectile;
		+FLOORHUGGER
		DeathSound "Ice/Splode";
	}
	States
	{
	Spawn:
		1C3F DCB 10 Bright;
	Fly:
		1C3F AA 15 Bright;
		TNT1 A 0 A_Jump(12,"Death");
		Loop;
	Death:
		PUFI ABCD 3 Bright;
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",random(-6,6),random(-6,6),random(12,64),random(1,13),0,random(1,13),random(0,360));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",random(-6,6),random(-6,6),random(12,64),random(1,13),0,random(1,13),random(0,360));
		TNT1 AAAAAA 0 A_SpawnItemEx("RS_SpikeCyanRev",random(-6,6),random(-6,6),random(12,64),random(1,13),0,random(1,13),random(0,360));
		PUFI EFGH 2 Bright;
		Stop;
	}
}

class RS_IceToMeetWhiteRev : Actor   // CH Revenants.txt:4875
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 28;
		Alpha 0.67;
		Projectile;
		+THRUACTORS
		+THRUGHOST
		+DONTBLAST
		+MTHRUSPECIES
		-NOGRAVITY
		+USEBOUNCESTATE
		BounceType "Doom";
		BounceCount 99;
		BounceFactor 1.0;
		WallBounceFactor 1.0;
		Scale 0.75;
		Gravity 5.0;
	}
	States
	{
	Spawn:
		TNT1 A 1;
	Fly:
		TNT1 AA 1 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_IceToMeetWhiteRev2",0,0,0);
		Loop;
	Bounce.Floor:
		TNT1 A 0 ThrustThing(int(angle),12,0,0);   // CH: thrustthing(angle,12,0,0)
		Goto Fly;
	Bounce.Wall:
		TNT1 A 0 A_Stop;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_IceToMeetWhiteRev2 : Actor   // CH Revenants.txt:4915
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 1;
		DamageFunction (random(1,2));   // CH: Damage (random(1,2))
		DamageType "Ice";
		Projectile;
		+FLOORHUGGER
		+DONTHARMCLASS
		+RIPPER
		+DONTHARMSPECIES
		SeeSound "";
		DeathSound "Ice/Hit2";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		1C3F EFGHIJKLLLLLLLLLLLLIHGFE 5 Bright A_Explode(random(1,8),32,0);
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_FrostMistWhiteRev : Actor   // CH Revenants.txt:4943
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 19;
		DamageFunction (random(5,12));   // CH: Damage (random(5,12))
		DamageType "Ice";
		Projectile;
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.75;
		SeeSound "ice/Breath";
		DeathSound "Ice/Splode";
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		PUFI ABCD 3 Bright A_Explode(random(3,13),20);
		Goto Death;
	Death:
		PUFI EFGH 4 Bright A_Explode(random(3,13),20);
		Stop;
	}
}

class RS_ByeWhiteRevCast : Inventory   // CH Revenants.txt:4970
{
	Default { Inventory.MaxAmount 1; }
}

class RS_WhiteRevProtect : PowerProtection   // CH Revenants.txt:4971
{
	Default
	{
		DamageFactor 0.33;
		Powerup.Duration -1;
	}
}

class RS_DarkChannelWhiteRev : Actor   // CH Revenants.txt:4977
{
	Default
	{
		Radius 12;
		Height 9;
		Speed 0;
		Alpha 0.95;
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		+FLOORHUGGER
		+THRUACTORS
		+FLATSPRITE
		SeeSound "";
		DeathSound "Litn/litn3";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Mark:
		TNT1 A 0 A_PlaySound("Forgotten/Attack");
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev",46,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev2",-46,0,0,3,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev3",46,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev4",-46,0,0,3,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		TNT1 A 10;
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev",46,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev2",-46,0,0,3,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev3",46,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev4",-46,0,0,3,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		TNT1 A 10;
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev",46,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev2",-46,0,0,3,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev3",46,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CastTargetingWhiteRev4",-46,0,0,3,0,0,0,SXF_NOCHECKPOSITION|SXF_ORIGINATOR|SXF_SETMASTER);
		D4RC A 8 A_SetScale(0.1,0.1);
		D4RC B 8 A_SetScale(0.3,0.3);
		D4RC C 8 A_SetScale(0.5,0.5);
		D4RC D 8 A_SetScale(0.7,0.7);
		D4RC E 8 A_SetScale(1.0,1.0);
		Goto Fly;
	Fly:
		TNT1 A 0 A_JumpIfInventory("RS_ByeWhiteRevCast",1,"Death");
		TNT1 A 0 A_PlaySound("Litn/litn3",0);
		D4RC ABCDE 5 Bright A_Explode(random(10,80),256,0);
		D4RC ABCDE 2 A_SpawnItemEx("RS_CybieZappy",0,0,12,random(8,20),0,random(2,15),random(0,180),SXF_NOCHECKPOSITION);
		D4RC A 1 Bright A_Explode(random(10,80),256,0);
		D4RC ABCDE 2 A_SpawnItemEx("RS_CybieZappy",0,0,12,random(8,20),0,random(2,15),random(180,359),SXF_NOCHECKPOSITION);
		D4RC E 1 Bright A_Explode(random(10,80),256,0);
		TNT1 A 0 A_Jump(102,"Fly2");
		Loop;
	Fly2:
		D4RC A 1 A_SetScale(1.1,1.1);
		D4RC B 1 A_SetScale(1.3,1.3);
		D4RC C 1 A_SetScale(1.5,1.5);
		D4RC D 1 A_SetScale(1.7,1.7);
		D4RC E 1 A_SetScale(2.0,2.0);
	Fly3:
		TNT1 A 0 A_JumpIfInventory("RS_ByeWhiteRevCast",1,"Death");
		TNT1 A 0 A_PlaySound("Litn/litn3",0);
		D4RC ABCDE 3 Bright A_Explode(random(10,80),512,0);
		D4RC ABCDE 1 A_SpawnItemEx("RS_CybieZappy",0,0,12,random(12,30),0,random(5,15),random(0,180),SXF_NOCHECKPOSITION);
		D4RC A 1 Bright A_Explode(random(10,80),512,0);
		D4RC ABCDE 1 A_SpawnItemEx("RS_CybieZappy",0,0,12,random(12,30),0,random(5,15),random(180,359),SXF_NOCHECKPOSITION);
		D4RC E 1 Bright A_Explode(random(10,80),256,0);
		Loop;
	Death:
		D4RC A 1 A_SetScale(0.6,0.6);
		D4RC B 1 A_SetScale(0.4,0.4);
		D4RC C 1 A_SetScale(0.2,0.2);
		D4RC D 1 A_SetScale(0.1,0.1);
		Stop;
	}
}

class RS_CastTargetingWhiteRev : Actor   // CH Revenants.txt:5051
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 55;
		Projectile;
		+NOCLIP
		Alpha 0.95;
		Scale 1.5;
		RenderStyle "Add";
		Translation "0:255=%[0.94,0.00,0.00]:[2.00,0.65,0.65]";
	}
	int user_angle;   // CH: var int user_angle;
	int user_raise;   // CH: var int user_raise;
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		SSUL B 1 Bright A_Warp(AAPTR_MASTER,64,0,user_raise,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SSUL B 1 Bright { user_angle = user_angle + 8; }   // CH: A_SetUserVar("user_angle",user_angle + 8)
		TNT1 A 0 { user_raise = user_raise + 3; }          // CH: A_SetUserVar("user_raise",user_raise + 3)
		TNT1 A 0 A_JumpIf(user_raise >= 100,"Death");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RS_CastTargetingWhiteRev2 : RS_CastTargetingWhiteRev   // CH Revenants.txt:5082
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		SSUL A 1 Bright A_Warp(AAPTR_MASTER,-64,0,user_raise,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SSUL A 1 Bright { user_angle = user_angle - 8; }
		TNT1 A 0 { user_raise = user_raise + 3; }
		TNT1 A 0 A_JumpIf(user_raise >= 100,"Death");
		Loop;
	}
}

class RS_CastTargetingWhiteRev3 : RS_CastTargetingWhiteRev   // CH Revenants.txt:5098
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		SSUL B 1 Bright A_Warp(AAPTR_MASTER,-32,0,user_raise,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SSUL B 1 Bright { user_angle = user_angle - 8; }
		TNT1 A 0 { user_raise = user_raise + 3; }
		TNT1 A 0 A_JumpIf(user_raise >= 100,"Death");
		Loop;
	}
}

class RS_CastTargetingWhiteRev4 : RS_CastTargetingWhiteRev   // CH Revenants.txt:5114
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		SSUL A 1 Bright A_Warp(AAPTR_MASTER,32,0,user_raise,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		SSUL A 1 Bright { user_angle = user_angle - 8; }
		TNT1 A 0 { user_raise = user_raise + 3; }
		TNT1 A 0 A_JumpIf(user_raise >= 100,"Death");
		Loop;
	}
}

class RS_EvilShadeWhiteRev : Actor   // CH Revenants.txt:5130
{
	Default
	{
		Radius 20;
		Height 56;
		Speed 14;
		DamageFunction (random(2,7));   // CH: Damage (random(2,7))
		DamageType "Melee";
		Projectile;
		+NOCLIP
		+DONTHARMCLASS
	}
	States
	{
	Spawn:
		REVW NOPQRS 2;
		Goto Death;
	Death:
		// CH passes only 8 arguments here, so SXF_NOCHECKPOSITION lands in
		// A_SpawnItemEx's ANGLE slot -- CH's own off-by-one, kept verbatim.
		TNT1 A 1 A_SpawnItemEx("RS_ArchRingHelp",0,0,3,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_EvilShadeWhiteRev2 : RS_EvilShadeWhiteRev   // CH Revenants.txt:5151
{
	// CH: yscale 0.15 / xscale 1.0 -- non-uniform pair applied at spawn.
	override void PostBeginPlay() { Super.PostBeginPlay(); Scale = (1.0, 0.15); }
}

// ===========================================================================
// CROSS-LANE EXTERNALS OWNED BY THIS LANE (CH defines them in a later file).
// ===========================================================================

class RS_ZapFFAT : Actor   // CH Fatsos.txt:269
{
	Default
	{
		Speed 1;
		Projectile;
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.65;
		Translation "0:255=#[255,255,0]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_Jump(128,"A1");
		LITN ABCD 1 Bright;
		TNT1 A 0 A_SetScale(0.85,0.4);
		LITN EFG 1 Bright;
		TNT1 A 0 A_SetScale(0.4,0.85);
		LITN FEDB 1 Bright;
		Stop;
	A1:
		LITN ABCD 1 Bright;
		TNT1 A 0 A_SetScale(0.4,0.85);
		LITN EFG 1 Bright;
		TNT1 A 0 A_SetScale(0.85,0.4);
		LITN FEDB 1 Bright;
		Stop;
	}
}

class RS_FatsoPuff3 : Actor   // CH Fatsos.txt:1880
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.5;
		Alpha 0.6;
		Translation "168:191=250:254","208:223=250:254";
	}
	States
	{
	Spawn:
		BAL1 CDE 6 Bright;
		Goto Death;
	Death:
		BAL1 CDE 6 Bright;
		Stop;
	}
}

class RS_CyanCybieGunFlare : Actor   // CH CYBIES.txt:1037
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 2;
		Projectile;
		+NOINTERACTION
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.66;
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		SSBL ABCDEFGH 2 Bright;
		Stop;
	}
}

class RS_CybieZappy : Actor   // CH CYBIES.txt:4380
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 8;
		FastSpeed 8;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		-NOGRAVITY
		RenderStyle "Add";
		Gravity 0.4;
		Alpha 0.65;
		Scale 1.1;
		SeeSound "baron/attack";
		DeathSound "Litn/litn3";
		Translation "112:127=250:254","0:0=250:254","112:113=224:224","192:193=224:224","192:207=250:254";
	}
	States
	{
	Spawn:
		BAL2 AB 2 Bright A_SpawnItemEx("RS_TrailCB",0,0,1);
		Loop;
	Death:
		PLSE CDE 2 Bright A_Explode(random(5,20),32);
		PLSE EEEEE 0 A_SpawnItemEx("RS_ZapZapCB",random(-128,128),random(-128,128),random(1,12));
		Stop;
	}
}

class RS_TrailCB : Actor   // CH CYBIES.txt:4428
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 8;
		FastSpeed 52;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.55;
		Scale 0.75;
		SeeSound "baron/attack";
		DeathSound "weapons/plasmax";
		Translation "112:127=250:254","0:0=250:254","112:113=224:224","192:193=224:224","192:207=250:254";
	}
	States
	{
	Spawn:
		BAL2 AB 4 Bright A_Explode(random(5,20),64);
		Goto Death;
	Death:
		PLSE CDE 2 Bright;
		Stop;
	}
}

class RS_CH_BoneGib : Actor   // CH Gibs.txt:162
{
	Default
	{
		Radius 2;
		Height 3;
		Projectile;
		Damage 0;
		Speed 2;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		+MOVEWITHSECTOR
		+CANNOTPUSH
		-NOGRAVITY
		+NOTONAUTOMAP
		BounceFactor 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 ThrustThingZ(0,55,0,1);
		Goto Wee;
	Wee:
		BBBN ABCD random(3,6);
		Loop;
	Crash:
		BBBN ABD 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BBBN C 850;
		BBBN CCCC 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	Death:
		BBBN ABD 1 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		BBBN C 850;
		BBBN CCCC 0 A_SpawnParticle("White",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}
