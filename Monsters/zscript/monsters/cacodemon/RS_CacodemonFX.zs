// ============================================================================
// RS_CacodemonFX.zs -- Colourful Hell Cacodemon family: support actors,
// projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Cacodemons.txt (3876
// lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_Cacodemon.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here): RS_Zom, RS_ZomTierToken, RS_GrowRaisin, RS_CHBoner,
// RS_ThePlanBoner, RS_ColorTierIconCH..CH13, RS_HealthBundle, RS_ArmorBundle,
// RS_BackPackBundle, RS_implyingclip, RS_CH_Berserk, RS_CH_Cell,
// RS_CH_CellPack, RS_CH_RocketAmmo, RS_CH_MegaSphere, RS_CH_BlueArmor,
// RS_CH_Shell, RS_CH_Medikit, RS_CH_BFG9000, RS_CH_Cirno, RS_SplashAbyss,
// RS_SplashAbyssBubbleDemon, RS_AbyssShotIdentifier, RS_MediCacoBrown
// (CH source is Cacodemons.txt:148 but it shipped with the spectre family),
// RS_MediCacoBrown2 (same, :177), RS_SpeedBuffPE, RS_BrownImpCommand,
// RS_RedThingsLS, RS_RedThingsHK, RS_HKRedDeath, RS_EffectHK, RS_Trail12,
// RS_Splash11, RS_Gas14, RS_WDRock3, RS_WDRock4, RS_SpiralSaw5,
// RS_PuffCybieRed, RS_CrackoBallTrail (CH source is Cacodemons.txt:2055 but
// it shipped with the imp family).
//
// CROSS-LANE (parallel LOST SOULS import, lands with this one):
//   * Expected from the lostsoul lane: RS_RedLSoul (CH lostsouls.txt:1085)
//     -- named by RS_PortalSummons' spawn table below. Pending until that
//     lane lands; the parent re-verifies at integration.
//   * Sprite prefix CBAL (RS_DFlare's death flare, frames C-G) ships via
//     sprites/rs_lostsoul -- lostsouls.txt uses CBAL too, so per the
//     ownership rule the lostsoul lane copies it. CH ships 10 CBAL lumps.
//   * Referenced the other way (lostsouls.txt fires classes DEFINED in
//     Cacodemons.txt, so they are defined HERE, that lane references them
//     read-only): RS_Cacospit1, RS_CacoFire2, RS_Cacofire3, RS_Cacofire4,
//     RS_SpitFireCaco, RS_CrackodemonBall, RS_SbombCaco, and the bodies
//     RS_CommonCaco, RS_BlueCaco, RS_YellowCaco (lostsouls.txt:2345-2390,
//     2972-2984).
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sound "weapons/none" (RS_HadesBolt SeeSound): not in CH SNDINFO.txt,
//     not a vanilla gzdoom sound -- silent in CH too. CH's deliberate
//     "no sound" idiom, kept verbatim.
//   * Sound "holy2/holy4" (RS_SummonPortalCybie SeeSound): CH SNDINFO
//     defines Holy2/holy2 and Holy3/holy3 only -- inert in CH.
//   * Sound "spike/spiked" (RS_SmallIceCaco DeathSound): no entry anywhere
//     in CH SNDINFO.txt, not vanilla -- inert in CH.
//   * Sound "vile/laugh" (RS_EyeRocketCaco DeathSound): not in CH SNDINFO,
//     not vanilla (vanilla vile set is sight/active/pain/death/start/
//     firestrt/firecrkl) -- inert in CH.
//   * Sound "weapons/gntidl" (RS_HadesBolt DeathSound): CH SNDINFO.txt:700
//     maps it to lump DSGNTIDL, but no DSGNTIDL lump exists in
//     Desktop\CH\sounds or E:\New folder\ART SOURCE\CH, and doom2.wad has
//     none -- the entry resolves to a missing lump in CH itself. The repo
//     SNDINFO already carries the entry (2026-08-05 whole import); kept
//     verbatim, silent here exactly as in CH.
//
// Sprite prefixes CH does not ship (HEAD, BAL1, BAL2, BAL7, MISL, PLSS,
// PLSE) resolve from the IWAD and were NOT extracted.
//
// Standing strips, preserved at each site as "// CH:" comments: ACS
// announcers, the CHRandom_GibGenerator/NashGore gore chain (owner accepts
// vanilla gore; XDeath ANIMATIONS stay), DRLA RL*/RareArmorPool drops.
// ============================================================================

// ---------------------------------------------------------------------------
// Third-file externals referenced by Cacodemons.txt.
// ---------------------------------------------------------------------------

class RS_Zap88 : Actor   // CH Barons.txt:2775 -- the abyss melee lightning flick
{
	Default
	{
		Speed 1;
		Projectile;
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.65;
		Scale 1;
	}
	States
	{
	Spawn:
		LITN ABCDEFGOP 3 Bright;
		Stop;
	}
}

class RS_DFlare : Actor   // CH Archviles.txt:3927 -- the orb's laser dart
{
	Default
	{
		Radius 5;
		Height 5;
		Speed 25;
		DamageFunction (random(10,38));   // CH: Damage(random(10,38))
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		VBA3 AB 3 Bright A_SpawnItemEx("RS_MFlareFX",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		CBAL CDEFG 3 Bright;   // CBAL ships in sprites/monsters/fx (10 lumps, matches CH's sprites/fx)
		Stop;
	}
}

class RS_MFlareFX : Actor   // CH Archviles.txt:3951 -- DFlare's trail flame
{
	Default
	{
		Radius 0;
		Height 1;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.67;
	}
	States
	{
	Spawn:
		FDFX ABCDEF 4 Bright;
		Stop;
	}
}

class RS_PlasmaBallSP4 : Actor   // CH Hellknights.txt:2498 -- small plasma bolt
{
	Default
	{
		DamageType "Plasma";
		Radius 3;
		Height 3;
		Speed 9;
		DamageFunction (random(3,7));   // CH: Damage(random(3,7))
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.25;
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		PLSS A 0 A_Jump(2,"Death");
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

class RS_PlasmaBallSP5 : RS_PlasmaBallSP4   // CH CYBIES.txt:2351 -- the orb's pain spray
{
	Default
	{
		Species "Cybie";
		+DONTHARMCLASS   // CH: +dontharmspecies
	}
}

class RS_MolochNail : Actor   // CH CYBIES.txt:3958 -- the white boss's spike volley
{
	Default
	{
		Radius 4;
		Height 6;
		DamageFunction (random(10,30));   // CH: damage(random(10,30))
		DamageType "Fire";
		Speed 30;
		Scale 1.1;
		Decal "BulletChip";
		AttackSound "moloch/nailhitbleed";
		DeathSound "weapons/firex4";
		Projectile;
		+SPAWNSOUNDSOURCE
		+EXTREMEDEATH
		+BLOODSPLATTER
		+ROCKETTRAIL
	}
	States
	{
	Spawn:
		BLAD A 1 Bright;
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,10),64);   // per-frame explode: CH's nail burn, deliberate
		FBL1 EFG 1 Bright A_Explode(random(5,20),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_PuffCybieRed",0,0,2);
		Stop;
	}
}

class RS_MinesRev : Actor   // CH Revenants.txt:3235 -- the bouncing spike mine
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 24;
		DamageFunction (random(10,40));   // CH: Damage (random(10,40))
		RenderStyle "SoulTrans";
		Alpha 0.95;
		Projectile;
		DamageType "Fire";
		-NOGRAVITY
		+BOUNCEONWALLS
		+MTHRUSPECIES
		+THRUGHOST
		Gravity 0.9;
		BounceType "Doom";
		BounceCount 999;
		BounceFactor 0.85;
		WallBounceFactor 1.3;
		SeeSound "monster/dknmsl";
		BounceSound "fire/fire3";
		DeathSound "weapons/boom1";
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 174;
		DropItem "RS_CH_Cell", 32;
	}
	States
	{
	Spawn:
		RIP1 ABC 4 Bright;
		RIP1 C 0 A_Jump(12,"Death");
		RIP1 C 0 A_Jump(32,"Bounce");
		Loop;
	Bounce:
		RIP1 A 2 Bright ThrustThing(int(angle*256/(random(1,360))),12,0,0);   // CH: ThrustThing(angle*256/(random(1,360)),12,0,0)
		Goto Spawn;
	Death:
		RIP1 D 0 A_NoBlocking;
		RIP1 DEFGH 5 Bright A_Explode(random(5,15),88);   // per-frame explode: CH's mine burst, deliberate
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,0);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,10);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,20);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,30);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,40);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,50);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,60);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,70);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,80);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,90);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,100);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,110);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,120);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,130);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,140);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,150);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,160);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,180);   // CH skips 170 -- kept
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,190);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,200);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,210);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,220);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,230);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,240);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,250);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,260);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,270);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,280);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,290);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,300);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,310);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,320);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,330);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,340);
		RIP1 H 0 A_CustomMissile("RS_RevNail",0,0,350);
		Stop;
	}
}

class RS_RevNail : Actor   // CH Revenants.txt:3313 -- the mine's shrapnel nail
{
	Default
	{
		Radius 2;
		Height 4;
		DamageFunction (random(5,15));   // CH: damage (random(5,15))
		DamageType "Melee";
		Speed 55;
		Scale 0.7;
		Decal "BulletChip";
		AttackSound "moloch/nailhitbleed";
		DeathSound "weapons/firex4";
		Projectile;
		+SPAWNSOUNDSOURCE
		+MTHRUSPECIES
		+EXTREMEDEATH
		+BLOODSPLATTER
	}
	States
	{
	Spawn:
		BLAD A 1 Bright;
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,5),64);   // per-frame explode: CH's nail burn, deliberate
		FBL1 EFG 1 Bright A_Explode(random(2,8),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_PuffCybieRed",0,0,2);
		Stop;
	}
}

class RS_PortalSummons : RandomSpawner   // CH CYBIES.txt:3535 -- the hell portal's roster
{
	// DropItem names resolve at spawn time, so entries for families not yet
	// imported are inert until those lanes land, then self-activate --
	// same self-healing as the RS_CommonRevenant guard.
	Default
	{
		DropItem "RS_CommonRevenant", 255, 300;   // revenant family not imported yet
		DropItem "RS_PurpleRevenant", 255, 100;   // revenant family not imported yet
		DropItem "RS_RedRevenant", 255, 120;      // revenant family not imported yet
		DropItem "RS_RedLSoul", 255, 200;         // expected from lostsoul lane (lostsouls.txt:1085)
		DropItem "RS_RedZombie", 255, 80;
		DropItem "RS_RedSG", 255, 50;
		DropItem "RS_RedCGuy", 255, 70;
		DropItem "RS_RedImp", 255, 300;
		DropItem "RS_RedDemon", 255, 150;
		DropItem "RS_RedCaco", 255, 50;
		DropItem "RS_MolochWraith", 255, 800;     // RS_Cyberdemon.zs:1981 (CH CYBIES.txt:3692)
	}
}

class RS_SummonPortalCybie : Actor   // CH CYBIES.txt:3550 -- the white boss's hell portal. Summon: no tier token.
{
	Default
	{
		Health 50;
		Radius 20;
		Height 64;
		Monster;
		+NOPAIN
		+NOTARGET
		+FLOAT
		+FLOATBOB
		+NOGRAVITY
		+LOOKALLAROUND
		Speed 1;
		RenderStyle "Add";
		SeeSound "holy2/holy4";   // PROVEN missing in CH itself -- silent there too (see header)
		DeathSound "wraith/wraith5";
		DropItem "RS_HealthBundle";
		Alpha 0.95;
		Scale 2;
		Tag "Hell portal";
	}
	States
	{
	Spawn:
		SPIR DCBA 8 A_Look;
		Loop;
	See:
		SPIR DCBA 8 A_Chase;
		SPIR A 0 A_Jump(12,"Missile");
		Loop;
	Missile:
		SPIR B 1;
		SPIR B 2 A_PainAttack("RS_PortalSummons",0,PAF_NOSKULLATTACK);
		Goto See;
	Death:
		SPIR EE 1 A_Scream;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cacodemons.txt internals: support, projectiles, minion FX. File order.
// RS_MediCacoBrown / RS_MediCacoBrown2 (Cacodemons.txt:148/177) already
// shipped with the spectre family; RS_CrackoBallTrail (:2055) with the imp
// family. Referenced read-only.
// ---------------------------------------------------------------------------

class RS_GrellBallBrown : Actor   // CH Cacodemons.txt:200 -- brown's slowing gob
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 15;
		Damage 4;   // bare constant stays bare
		Scale 0.75;
		DamageType "Melee";
		RenderStyle "Add";
		Alpha 0.67;
		Projectile;
		DeathSound "grell/projhit";
		Translation "0:255=%[0.31,0.23,0.18]:[1.10,0.74,0.40]";
	}
	States
	{
	Spawn:
		ICEY AAABBBCCC 1 Bright A_SpawnItemEx("RS_Splash11",0,0,3,random(1,4),0,random(1,6),random(0,359),128,0);
		Loop;
	XDeath:
		TNT1 A 0 A_RadiusGive("RS_GrellSlowdown",48,RGF_PLAYERS|RGF_CUBE,1);
	Death:
		RCHB CDE 4 Bright;
		MISL CCC 0 A_SpawnItemEx("RS_Gas14",random(-8,8),random(-8,8),random(-2,2),random(1,8),0,random(-6,20),random(-359,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_GrellSlowdown : PowerSpeed   // CH Cacodemons.txt:227 -- the 0.8x slow it inflicts
{
	Default
	{
		+INVENTORY.AUTOACTIVATE
		-INVENTORY.INVBAR
		Powerup.Duration -1;
		Speed 0.8;
	}
}

class RS_BigIceCaco : Actor   // CH Cacodemons.txt:376 -- cyan's big ice ball
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 32;
		Scale 0.95;
		RenderStyle "Add";
		Alpha 0.95;
		DamageFunction (random(8,40));   // CH: Damage(random(8,40))
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
		CHCY ABCDFG 3 Bright A_SpawnItemEx("RS_IceCacoTrail",cos(pitch)*1,0,0-(sin(pitch)*1),cos(pitch)*1,0,-sin(pitch)*1,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 A 0 A_Scream;
		TNT1 AAAAAAAAAAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_IceCacoTrail",0,0,1,random(12,40),0,random(-10,25),random(0,180));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_IceCacoTrail",0,0,1,random(12,40),0,random(-10,25),random(180,359));
		PUFI ABCD 1 Bright A_SetTranslucent(0.4);
		PUFI EFGH 1 Bright;
		Stop;
	}
}

class RS_SmallIceCaco : Actor   // CH Cacodemons.txt:409 -- cyan's ice needle
{
	Default
	{
		Radius 3;
		Height 2;
		Speed 42;
		DamageFunction (random(8,21));   // CH: Damage(random(8,21))
		DamageType "Ice";
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		XScale 1.55;
		YScale 0.25;
		SeeSound "Ice/Hit2";
		DeathSound "spike/spiked";   // PROVEN missing in CH itself -- silent there too (see header)
		Decal "BulletChip";
	}
	States
	{
	Spawn:
		ICEY ABC 3 Bright;
		Loop;
	Death:
		ICEY FG 5 Bright;
		TNT1 AAAAAAA 0 A_SpawnParticle("Cyan",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,32,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		ICEY HI 5 Bright;
		Stop;
	}
}

class RS_IceCacoTrail : RS_SmallIceCaco   // CH Cacodemons.txt:437
{
	Default
	{
		DamageFunction (random(2,16));   // CH: Damage(random(2,16))
		Alpha 0.5;
		XScale 1.75;
		YScale 0.65;
	}
	States
	{
	Spawn:
		ICEY ABC 3 Bright;
	Death:
		ICEY FGHI 3 Bright;
		Stop;
	}
}

class RS_BigBallCrev2 : RS_SmallIceCaco   // CH Cacodemons.txt:453 -- referenced by nothing
// in Cacodemons.txt itself (a Revenants-side pickup point); imported whole
// per the import-everything rule.
{
	Default
	{
		DamageFunction (random(1,8));   // CH: Damage(random(1,8))
		Alpha 0.5;
		XScale 2.5;
		YScale 0.85;
	}
	States
	{
	Spawn:
		ICEY ABC 3 Bright;
		Stop;
	}
}

class RS_AbyssCacoBalls : Actor   // CH Cacodemons.txt:641 -- abyss spam ball
{
	Default
	{
		Radius 8;
		Species "Caco";   // CH lists Species twice ("caco" :644, via projectile block) -- kept once
		Height 6;
		Speed 21;
		DamageFunction (random(5,55));   // CH: Damage(random(5,55))
		DamageType "Ice";
		Projectile;
		+THRUSPECIES
		+DONTHARMCLASS
		+DONTHARMCLASS
		Scale 1.25;
		RenderStyle "Add";
		Alpha 0.8;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "Ice";
	}
	States
	{
	Spawn:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssCacoZap",0,0,0,0,0,0,0,SXF_SETMASTER|SXF_ORIGINATOR);
	Fly:
		BLL9 AB 4 Bright;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-32,32),random(-32,32),random(-16,16),0,0,0,0);
		TNT1 A 0 A_KillChildren("extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		BLL9 CDE 6 Bright;
		Stop;
	}
}

class RS_AbyssCacoHidi : Actor   // CH Cacodemons.txt:676 -- abyss seeker flame
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 55;
		DamageFunction (random(30,95));   // CH: Damage(random(30,95))
		Projectile;
		+SEEKERMISSILE
		+THRUSPECIES
		+DONTHARMCLASS
		+DONTHARMCLASS
		Species "Caco";
		DamageType "Plasma";
		RenderStyle "Add";
		Alpha 0.95;
		XScale 1.4;
		YScale 0.35;
		SeeSound "weapons/bigbrn";
		DeathSound "weapons/bigbrn";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		FRFX A 1 Bright A_SeekerMissile(2,2);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-12,12),random(-12,12),random(-1,1),0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		FRFX B 1 Bright A_Weave(3,1,5,0);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-12,12),random(-12,12),random(-1,1),0,0,0,0);
		FRFX C 1 Bright A_SeekerMissile(2,2);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-12,12),random(-12,12),random(-1,1),0,0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		FRFX D 1 Bright A_Weave(3,1,5,0);
		TNT1 AAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-12,12),random(-12,12),random(-1,1),0,0,0,0);
		Loop;
	Death:
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-64,64),random(-64,64),random(-32,32),0,0,0,0);
		TNT1 A 0 A_SetScale(1.5,1.5);
		FRFX HIJ 2 Bright A_Explode(random(4,10),88);   // per-frame explode: CH's flame burst, deliberate
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-64,64),random(-64,64),random(-32,32),0,0,0,0);
		FRFX KLM 2 Bright A_Explode(random(4,12),128);
		TNT1 AAAAAAAAA 0 A_SpawnItemEx("RS_AbyssCacoZap2",random(-64,64),random(-64,64),random(-32,32),0,0,0,0);
		FRFX NO 2 Bright;
		Stop;
	}
}

class RS_AbyssCacoZap : Actor   // CH Cacodemons.txt:722 -- lightning orbiting the ball
{
	Default
	{
		Radius 2;
		Species "Caco";   // CH lists Species twice ("caco" :725, "Caco" :728) -- kept once
		Height 2;
		Speed 4;
		DamageFunction (random(1,5));   // CH: Damage(random(1,5))
		DamageType "Plasma";
		Projectile;
		+RIPPER
		+THRUSPECIES
		+DONTHARMCLASS
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1.75;
		Translation "Ice";
	}
	States
	{
	Spawn:
	Fly:
		LITN ABCDEFGOP 2 Bright A_Warp(AAPTR_MASTER,random(-2,2),random(-2,2),random(-2,2),0,WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	Death:
		TNT1 AAAAAA 1 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_AbyssCacoZap2 : Actor   // CH Cacodemons.txt:751 -- static discharge
{
	Default
	{
		Radius 2;
		Species "Caco";   // CH lists Species twice ("caco" :754, "Caco" :757) -- kept once
		Height 2;
		Speed 2;
		DamageFunction (random(1,5));   // CH: Damage(random(1,5))
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		+DONTHARMCLASS
		+THRUSPECIES
		RenderStyle "Add";
		Alpha 1.75;
		Translation "Ice";
	}
	States
	{
	Spawn:
	Death:
		LITN ABCDEFGOP 2 Bright A_Explode(random(1,4),64,0);   // per-frame explode: CH's crawling zap, deliberate
		TNT1 AAAAAA 0 A_SpawnParticle("white",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,12,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_CacoRockBreath : RS_WDRock3   // CH Cacodemons.txt:920 -- gray's rock spit
{
	Default
	{
		DamageFunction (random(15,50));   // CH: Damage(Random(15,50))
	}
}

class RS_FireBluCacoBall : Actor   // CH Cacodemons.txt:1028 -- fireblu's bouncer
{
	Default
	{
		Radius 12;
		Height 18;
		Speed 16;
		DamageFunction (random(5,40));   // CH: Damage(random(5,40))
		DamageType "Plasma";
		Projectile;
		+BOUNCEONWALLS
		BounceType "Hexen";
		WallBounceFactor 0.9;
		BounceFactor 0.9;
		BounceCount 4;
		BounceSound "Bomb/bounce";
		RenderStyle "Add";
		Alpha 0.45;
		Scale 1.5;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "208:223=195:207","225:231=192:195";
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright A_SpawnItemEx("RS_FireBluCacoBall2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		BAL1 A 0 A_Jump(32,"WOM");
		Loop;
	WOM:
		BAL1 BCD 0 A_Stop;
		BAL1 BCD 0 A_SetAngle(angle + random(-60,60));
		BAL1 BCD 0 ThrustThing(int(angle*256/360),8,0,0);   // CH: ThrustThing(angle*256/360,8,0,0)
		Goto Spawn;
	Death:
		BAL1 CDE 6 Bright A_Explode(random(5,15),128);   // per-frame explode: CH's triple pop, deliberate
		Stop;
	}
}

class RS_FireBluCacoBall2 : Actor   // CH Cacodemons.txt:1066 -- the fire it sheds
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 1;
		DamageFunction (random(5,23));   // CH: Damage(random(5,23))
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
		FIRE AB 1 Bright;
		Goto Death;
	Death:
		FIRE CDEEDCDE 5 A_Explode(random(3,10),64);   // per-frame explode: CH's lingering fire, deliberate
		FIRE FGH 4 Bright A_Explode(random(3,10),64);
		Stop;
	}
}

class RS_CacodemonBall2 : Actor replaces CacodemonBall   // CH Cacodemons.txt:1094 -- "CacodemonBall2 replaces Cacodemonball"
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		FastSpeed 20;
		Damage 5;   // bare constant stays bare
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
	}
	States
	{
	Spawn:
		BAL2 AB 4 Bright;
		Loop;
	Death:
		BAL2 CDE 6 Bright;
		Stop;
	}
}

class RS_Cacospit1 : Actor   // CH Cacodemons.txt:1299 -- green's spit. lostsouls.txt:2357 fires it too (read-only there).
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 17;
		FastSpeed 20;
		DamageFunction (random(10,45));   // CH: Damage(Random(10,45))
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.65;
		SeeSound "baron/attack";
		DeathSound "baron/shotx";
		Decal "BaronScorch";
	}
	States
	{
	Spawn:
		BAL7 AB 4 Bright A_SpawnItemEx("RS_Trail12",0,0,3);
		Loop;
	Death:
		BAL7 CDE 6 Bright;
		Stop;
	}
}

class RS_CacoFire2 : Actor   // CH Cacodemons.txt:1433 -- blue's holy volley. lostsouls.txt:2359 fires it too.
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 18;
		DamageFunction (random(6,35));   // CH: Damage(random(6,35))
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.73;
		Scale 0.7;
		SeeSound "holy3/holy3";
		DeathSound "holy2/holy2";
	}
	States
	{
	Spawn:
		SSBL ABCDEFGH 3 Bright;
		Loop;
	Death:
		SSBL K 6 Bright A_SetScale(0.5);
		SSBL I 6 Bright A_SetScale(0.7);
		SSBL K 6 Bright A_SetScale(0.5);
		SSBL J 6 Bright A_SetScale(1);
		Stop;
	}
}

class RS_Cacofire3 : Actor   // CH Cacodemons.txt:1576 -- purple's seeker. lostsouls.txt:2369 fires it too.
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 15;
		FastSpeed 28;
		DamageFunction (random(10,50));   // CH: Damage(Random(10,50))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
	}
	States
	{
	Spawn:
		SBS4 ABC 6 Bright A_SeekerMissile(4,4);
		Loop;
	Death:
		BAL2 C 0 A_Jump(32,"Oh");
		BAL2 CDE 6 Bright;
		Stop;
	Oh:
		BAL2 C 3 Bright A_SetScale(1.3,1.3);
		BAL2 CC 2 Bright A_Explode(random(8,32),64);   // per-frame explode: CH's growing blast, deliberate
		BAL2 D 3 Bright A_SetScale(1.6,1.6);
		BAL2 DD 2 Bright A_Explode(random(12,44),82);
		BAL2 E 3 Bright A_SetScale(2,2);
		BAL2 EE 2 Bright A_Explode(random(16,64),112);
		Stop;
	}
}

class RS_Cacofire4 : Actor   // CH Cacodemons.txt:1612 -- purple's small seeker. lostsouls.txt:2365 fires it too.
{
	Default
	{
		Radius 4;
		Height 6;
		Speed 16;
		FastSpeed 29;
		DamageFunction (random(5,25));   // CH: Damage(Random(5,25))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		Scale 0.5;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
	}
	States
	{
	Spawn:
		SBS4 ABC 6 Bright A_SeekerMissile(6,6);
		Loop;
	Death:
		BAL2 CDE 6 Bright;
		Stop;
	}
}

class RS_SpitFireCaco : Actor   // CH Cacodemons.txt:1774 -- yellow lich's bouncing flame. lostsouls.txt:2371 fires it too.
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 20;
		DamageFunction (random(10,65));   // CH: Damage(Random(10,65))
		DamageType "Fire";
		Projectile;
		+VISIBILITYPULSE
		+BOUNCEONWALLS
		RenderStyle "Add";
		SeeSound "CacoFlame/Attack";
		DeathSound "Fire/fire5";
		WallBounceFactor 0.8;
		BounceCount 8;
		BounceType "Doom";
		Alpha 0.9;
		Scale 0.7;
	}
	States
	{
	Spawn:
		FLUM ABCDE 6 Bright;
		Loop;
	Death:
		BBOM ABC 2 Bright A_SetScale(0.6);
		BBOM DEFG 3 Bright A_Explode(random(5,15),64);   // per-frame explode: CH's fire splash, deliberate
		Stop;
	}
}

class RS_VoidField : Actor   // CH Cacodemons.txt:1805 -- yellow's damage bubble. Summon: no tier token.
{
	Default
	{
		Radius 46;
		Height 46;
		Health 6666;
		Species "Caco";
		Speed 0;
		FastSpeed 0;
		Damage 0;   // bare constant stays bare
		Monster;
		+INVULNERABLE
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+REFLECTIVE
		+NOTARGET
		+NOGRAVITY
		-COUNTKILL
		-SOLID
		-CANPUSHWALLS
		-CANUSEWALLS
		-ACTIVATEMCROSS
		+DONTTHRUST
		RenderStyle "Add";
		DamageType "DIMp";
		Alpha 0.75;
		Scale 1.5;
		SeeSound "spell/spellcast1";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		BBOM B 1 Bright A_SetScale(1.5);
		BBOM B 1 Bright A_SetScale(1.3);
		BBOM B 1 Bright A_Explode(5,64);
		BBOM B 1 Bright A_SetScale(1.0);
		BBOM B 1 Bright A_Jump(2,"Death");
		Goto Spawn+1;
	Death:
		BBOM B 3 Bright A_SetScale(1.3);
		BBOM B 3 Bright A_SetScale(1.0);
		BBOM B 3 Bright A_SetScale(0.7);
		BBOM B 3 Bright A_SetScale(0.3);
		Stop;
	}
}

class RS_SbombCaco : Actor   // CH Cacodemons.txt:1999 -- red's sludge bomb. lostsouls.txt:2390 fires it too.
{
	Default
	{
		Radius 20;
		Height 20;
		Mass 600;
		Speed 11;
		DamageFunction (random(5,80));   // CH: Damage(random(5,80))
		DamageType "Plasma";
		Projectile;
		Scale 2;
		RenderStyle "Add";
		Alpha 0.95;
		SeeSound "Spell/spellCast1";
		DeathSound "Crack/death";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 A 1 A_CustomMissile("RS_RedThingsHK",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BAL1 A 1 A_SpawnItemEx("RS_CrackoBallTrail",0,0,0,0,0,0,0,128);
		BAL1 B 1 A_SpawnItemEx("RS_RedThingsLS",0,0,5,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BAL1 C 4 A_SetTranslucent(0.35);
		BAL1 D 1 A_Explode(random(5,20),88);
		BAL1 DDDDDDDEEEEE 1 A_CustomMissile("RS_CrackodemonBall",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BAL1 E 2 A_Explode(random(5,20),99);
		Stop;
	}
}

class RS_CrackodemonBall : Actor   // CH Cacodemons.txt:2030 -- red's spam ball. lostsouls.txt:2373 fires it too.
{
	Default
	{
		Radius 8;
		Species "Caco";
		Height 6;
		Speed 15;
		DamageFunction (random(5,55));   // CH: Damage(random(5,55))
		DamageType "Plasma";
		Projectile;
		RenderStyle "Add";
		Alpha 0.8;
		SeeSound "Crack/see";
		DeathSound "Crack/death";
		Translation "192:207=171:191","240:247=191:191";
	}
	States
	{
	Spawn:
		BLL9 AAAABBBB 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		BLL9 CDE 6 Bright;
		Stop;
	}
}

class RS_BlackCacoBeam1 : Actor   // CH Cacodemons.txt:2287 -- EX railgun puff
{
	Default
	{
		Radius 1;
		Height 1;
		Scale 0.95;
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
		SPIR EDCBA 3 Bright A_Explode(random(2,20),128);   // per-frame explode: CH's rail burn, deliberate
		Stop;
	}
}

class RS_BlackCacoBeam2 : Actor   // CH Cacodemons.txt:2311 -- EX railgun spawnclass
{
	Default
	{
		Radius 10;
		Height 18;
		Speed 1;
		Scale 1.25;
		DamageType "Fire";
		DamageFunction (random(10,20));   // CH: Damage(random(10,20))
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
		Stop;
	}
}

class RS_HadesBallEX3 : CacodemonBall   // CH Cacodemons.txt:2573 -- EX wide zapper
{
	Default
	{
		DamageFunction (random(15,60));   // CH: Damage(random(15,60))
		Speed 10;
		Radius 12;
		Height 8;
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+FORCEXYBILLBOARD
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		Decal "CacoScorch";
		Scale 1.25;
	}
	States
	{
	Spawn:
		HADE AA 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-526,-356),0,0,0,0,0,128);
		HADE AAAAA 0 A_SpawnItemEx("RS_ZapperCaco",0,random(-1026,-528),0,0,0,0,0,128);
		HADE BB 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-296,-188),0,0,0,0,0,128);
		HADE AAAAA 0 A_SpawnItemEx("RS_ZapperCaco",0,random(-528,-128),0,0,0,0,0,128);
		HADE CC 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-188,-88),0,0,0,0,0,128);
		HADE DD 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-88,0),0,0,0,0,0,128);
		HADE EE 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(0,88),0,0,0,0,0,128);
		HADE GG 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(88,188),0,0,0,0,0,128);
		HADE HH 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(188,296),0,0,0,0,0,128);
		HADE AAAAA 0 A_SpawnItemEx("RS_ZapperCaco",0,random(128,528),0,0,0,0,0,128);
		HADE AA 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(356,526),0,0,0,0,0,128);
		HADE AAAAA 0 A_SpawnItemEx("RS_ZapperCaco",0,random(526,1026),0,0,0,0,0,128);
		Loop;
	Death:
		HEFX CDEEFGH 4 Bright A_SpawnItemEx("RS_HadeExpl",random(-228,228),random(-228,228),random(-12,12),0,0,0,0);
		Stop;
	}
}

class RS_HadesBallEX4 : CacodemonBall   // CH Cacodemons.txt:2609 -- EX fountain zapper
{
	Default
	{
		DamageFunction (random(15,60));   // CH: Damage(random(15,60))
		Speed 10;
		Radius 12;
		Height 8;
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+FORCEXYBILLBOARD
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		Decal "CacoScorch";
		Scale 1.25;
	}
	States
	{
	Spawn:
		HADE AA 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(33,66));
		HADE BB 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(-66,33));
		HADE CC 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(33,66));
		HADE DD 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(-66,33));
		HADE EE 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(33,66));
		HADE GG 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(-66,33));
		HADE HH 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(33,66));
		HADE AA 1 Bright A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(-66,33));
		Loop;
	Death:
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_ZapperCacoEX",0,0,0,random(5,28),0,0,random(0,359));
		HEFX CDEEFGH 4 Bright A_SpawnItemEx("RS_HadeExpl",random(-228,228),random(-228,228),random(-12,12),0,0,0,0);
		Stop;
	}
}

class RS_ZapperCacoEX : Actor   // CH Cacodemons.txt:2642 ("ZappercacoEX")
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 3;
		Damage 3;   // bare constant stays bare
		+NOCLIP
		+NOGRAVITY
		Projectile;
		RenderStyle "Add";
		Alpha 0.7;
		SeeSound "Crack/death";
	}
	States
	{
	Spawn:
		HADE IJKLIJKLIJKLIJKL 3 Bright A_Explode(random(2,20),32);   // per-frame explode: CH's crawling zap, deliberate
		Stop;
	}
}

class RS_RedSpikeCacoEX : Actor   // CH Cacodemons.txt:2662 -- EX orbiting spike. Minion: no tier token.
{
	int user_angle;   // CH: var int user_angle
	Default
	{
		Species "Caco";
		Health 100;
		Radius 16;
		Height 56;
		Mass 50;
		Scale 1.25;
		Speed 20;
		RadiusDamageFactor 0.33;
		Damage 5;   // bare constant stays bare
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+NOTRIGGER
		+NOICEDEATH
		+NOBLOOD
		+THRUSPECIES
		+DONTMORPH
		-NORADIUSDMG
		-COUNTKILL
		AttackSound "";
		ActiveSound "";
		DropItem "RS_CH_Cell", 32;
		DropItem "RS_CH_Shell", 102;
		DropItem "RS_implyingclip", 176;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Berserk", 2;
		Obituary "%o was spike shocked";
		Tag "Spiky ouch ouch";
		Translation "0:255=%[0.50,0.00,0.00]:[2.00,0.00,0.00]";
	}
	States
	{
	Spawn:
		CHCY A 0;
	See:
		TNT1 A 0;
	Fly:
		CHCY AB 1 Bright A_Warp(AAPTR_MASTER,176,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }   // CH: A_SetUserVar("user_angle",user_angle + 8)
		CHCY CD 1 Bright A_Warp(AAPTR_MASTER,176,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		CHCY FG 1 Bright A_Warp(AAPTR_MASTER,176,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }
		TNT1 A 0 A_JumpIf(user_angle >= 720,"Strike");
		Loop;
	Strike:
		CHCY ABCDFG 1 Bright A_Chase;
		Loop;
	Missile:
		CHCY ABCDFG 1 Bright A_FaceTarget;
		CHCY A 1 Bright A_SkullAttack(50);
		TNT1 A 0 ThrustThing(int(angle),33,0,0);   // CH: thrustthing(angle,33,0,0) -- degrees passed as byte angle, CH's own quirk kept
		CHCY BCDFG 1 Bright;
		CHCY ABCDFG 1 Bright;
		CHCY ABCDFG 2 Bright;
		CHCY ABCDFG 3 Bright;
		CHCY ABCDFG 4 Bright;
		CHCY ABCDFG 5 Bright;
		CHCY ABCDFG 6 Bright;
		CHCY ABCDFG 7 Bright;
		CHCY ABCDFG 8 Bright;
	Death:
		TNT1 A 1 Bright A_CustomMissile("RS_HKRedDeath",100,-30,CMF_AIMOFFSET,2,-10);
		TNT1 A 1 Bright A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		TNT1 A 1 Bright A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		TNT1 A 1 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		TNT1 A 1 A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_CacoNail",0,0,2,random(33,66),0,random(-1,25),random(0,90));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_CacoNail",0,0,2,random(33,66),0,random(-1,25),random(90,180));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_CacoNail",0,0,2,random(33,66),0,random(-1,25),random(180,270));
		TNT1 AAAAAAAA 0 A_SpawnItemEx("RS_CacoNail",0,0,2,random(33,66),0,random(-1,25),random(270,359));
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_HadesBallEX2 : CacodemonBall   // CH Cacodemons.txt:2744 -- EX bonus duck
{
	Default
	{
		DamageFunction (random(25,75));   // CH: Damage(random(25,75))
		Speed 18;
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+FORCEXYBILLBOARD
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		Decal "CacoScorch";
		Scale 1.5;
	}
	States
	{
	Spawn:
		HEFX AB 4 Bright A_SpawnItemEx("RS_SpiralSaw5",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		HEFX CDE 4 Bright A_SpawnItemEx("RS_HadeLoad1",random(-128,128),random(-128,128),random(-12,12),0,0,0,0);
		HEFX EFGH 4 Bright A_SpawnItemEx("RS_HadeExpl",random(-228,228),random(-228,228),random(-12,12),0,0,0,0);
		HADE HGEDCBA 6 Bright;
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,0);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,90);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,180);
		TNT1 A 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-1,24),random(8,33),0,0,270);
		Stop;
	}
}

class RS_CacoNail : Actor   // CH Cacodemons.txt:2813 -- the spike's shrapnel
{
	Default
	{
		Radius 2;
		Height 4;
		DamageFunction (random(5,15));   // CH: damage(random(5,15))
		DamageType "Melee";
		RenderStyle "Add";
		Speed 55;
		Scale 0.95;
		Decal "BulletChip";
		AttackSound "moloch/nailhitbleed";
		DeathSound "weapons/firex4";
		Projectile;
		+SPAWNSOUNDSOURCE
		+MTHRUSPECIES
		+EXTREMEDEATH
		+BLOODSPLATTER
		Translation "0:255=%[0.50,0.00,0.00]:[2.00,0.00,0.00]";
	}
	States
	{
	Spawn:
		BLAD A 1 Bright;
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,5),64);   // per-frame explode: CH's nail burn, deliberate
		FBL1 EFG 1 Bright A_Explode(random(2,8),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_PuffCybieRed",0,0,2);
		Stop;
	}
}

class RS_BlackCacoEXShade : Actor   // CH Cacodemons.txt:2845 -- EX's red afterimage
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
		StencilColor "red";
		Alpha 0.33;
		YScale 1.85;
		XScale 2.35;
	}
	States
	{
	Spawn:
		HADE IJKLIJKLIJKLIJKL 1 Bright;
		Stop;
	}
}

class RS_EyeBeamCaco : Actor   // CH Cacodemons.txt:2866 -- the black boss's eye lance
{
	Default
	{
		Radius 11;
		Height 9;
		Speed 178;
		Damage 1;   // bare constant stays bare
		DamageType "Plasma";
		Projectile;
		+STRIFEDAMAGE
		RenderStyle "Add";
		Alpha 0.8;
		Scale 0.65;
		SeeSound "Crack/see";
		DeathSound "Litn/litn3";
		Translation "192:207=171:191","240:247=191:191";
	}
	States
	{
	Spawn:
		BLL9 AAAABBBB 1 Bright A_SpawnItemEx("RS_RedRevLoad3",0,0,4,0,0,0,0,128);
		Loop;
	Death:
		BLL9 CDE 6 Bright A_Explode(random(2,30),34);   // per-frame explode: CH's lance burst, deliberate
		Stop;
	}
}

class RS_RedRevLoad3 : Actor   // CH Cacodemons.txt:2892 -- eye lance spiral
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
		Scale 0.65;
		SeeSound "Weapons/BFGF";
	}
	States
	{
	Spawn:
		SPIR ABCDE 1 Bright A_SpawnItemEx("RS_RedRevLoad4",0,0,4,0,0,0,0,128);
		Stop;
	}
}

class RS_RedRevLoad4 : Actor   // CH Cacodemons.txt:2911
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
		Scale 0.65;
		SeeSound "Weapons/BFGF";
	}
	States
	{
	Spawn:
		SPIR ABCDE 2 Bright;
		Stop;
	}
}

class RS_HadeAra : Actor   // CH Cacodemons.txt:2930 -- the black boss's bullet flame
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+ALLOWPARTICLES
		+RANDOMIZE
		+PUFFONACTORS
		Projectile;
		RenderStyle "Add";
		DamageType "Melee";
		Alpha 0.95;
		VSpeed 1;
		Scale 2;
		SeeSound "Vile/Active";
		Mass 5;
	}
	States
	{
	Spawn:
		HADE ABCDEGH 3 Bright A_Explode(random(2,26),64);   // per-frame explode: CH's flame wall, deliberate; falls through to Melee as in CH
	Melee:
		HADE AHGEDCBA 3 Bright A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-88,88),0,0,0,0);
		Stop;
	}
}

class RS_ZapperCaco : Actor   // CH Cacodemons.txt:2956 ("Zappercaco")
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 3;
		Damage 3;   // bare constant stays bare
		+NOCLIP
		+NOGRAVITY
		Projectile;
		RenderStyle "Add";
		Alpha 0.7;
		SeeSound "Crack/death";
	}
	States
	{
	Spawn:
		HADE IJKL 4 Bright A_Explode(random(2,20),32);   // per-frame explode: CH's zap field, deliberate
		Stop;
	}
}

class RS_HadesBall3 : CacodemonBall   // CH Cacodemons.txt:2976 -- slow wide zapper
{
	Default
	{
		DamageFunction (random(5,50));   // CH: Damage(random(5,50))
		Speed 4;
		Radius 12;
		Height 8;
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+FORCEXYBILLBOARD
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		Decal "CacoScorch";
		Scale 1.25;
	}
	States
	{
	Spawn:
		HADE AA 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-333,-256),0,0,0,0,0,128);
		HADE BB 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-256,-168),0,0,0,0,0,128);
		HADE CC 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-168,-88),0,0,0,0,0,128);
		HADE DD 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(-88,0),0,0,0,0,0,128);
		HADE EE 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(0,88),0,0,0,0,0,128);
		HADE GG 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(88,168),0,0,0,0,0,128);
		HADE HH 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(168,256),0,0,0,0,0,128);
		HADE AA 1 Bright A_SpawnItemEx("RS_ZapperCaco",0,random(256,333),0,0,0,0,0,128);
		Loop;
	Death:
		HEFX CDEEFGH 4 Bright A_SpawnItemEx("RS_HadeExpl",random(-228,228),random(-228,228),random(-12,12),0,0,0,0);
		Stop;
	}
}

class RS_HadesBall2 : CacodemonBall   // CH Cacodemons.txt:3008 -- the sawblade that births a Red
{
	Default
	{
		DamageFunction (random(5,50));   // CH: Damage(random(5,50))
		Speed 12;
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+FORCEXYBILLBOARD
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		Decal "CacoScorch";
		Scale 1.5;
	}
	States
	{
	Spawn:
		HEFX AB 4 Bright A_SpawnItemEx("RS_SpiralSaw5",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		HEFX CDE 4 Bright A_SpawnItemEx("RS_HadeLoad1",random(-128,128),random(-128,128),random(-12,12),0,0,0,0);
		HEFX EFGH 4 Bright A_SpawnItemEx("RS_HadeExpl",random(-228,228),random(-228,228),random(-12,12),0,0,0,0);
		HADE HGEDCBA 6 Bright;
		HADE A 0 A_SpawnItemEx("RS_RedCaco",0,-64,12,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_HadeExpl : Actor   // CH Cacodemons.txt:3034 -- the hades pop
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 3;
		FastSpeed 9;
		DamageFunction (random(5,10));   // CH: Damage(random(5,10))
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 1;
		Scale 1.15;
		SeeSound "caco/attack";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		HADE M 4 Bright A_Explode(random(2,10),108);   // per-frame explode: CH's expanding pop, deliberate
		HADE N 5 Bright A_Explode(random(2,12),124);
		HADE OP 5 Bright A_Explode(random(2,10),138);
		HADE Q 6 Bright A_Explode(random(5,25),128);
		Stop;
	}
}

class RS_HadeLoad1 : Actor   // CH Cacodemons.txt:3065 -- charge-up spiral
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.9;
		SeeSound "Weapons/BFGF";
	}
	States
	{
	Spawn:
		HADE XWVUTSR 3 Bright A_SpawnItemEx("RS_HadeLoad2",random(-15,15),random(-15,15),random(-15,15),0,0,0,0,128);
		Stop;
	}
}

class RS_HadeLoad2 : Actor   // CH Cacodemons.txt:3083
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.7;
		SeeSound "Crack/death";
	}
	States
	{
	Spawn:
		HADE IJKL 4 Bright;
		Stop;
	}
}

class RS_HadesBall : CacodemonBall   // CH Cacodemons.txt:3101 -- the basic hades bolt
{
	Default
	{
		DamageFunction (random(5,30));   // CH: Damage(random(5,30))
		Speed 17;
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+FORCEXYBILLBOARD
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		Decal "CacoScorch";
	}
	States
	{
	Spawn:
		HEFX AB 4 Bright;
		Loop;
	Death:
		HEFX CDEEFGH 4 Bright A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(-12,12),0,0,0,0);
		Stop;
	}
}

class RS_HadesBolt : CacodemonBall   // CH Cacodemons.txt:3123 -- the floor crawler
{
	Default
	{
		Damage 1;   // bare constant stays bare
		Speed 5;
		Radius 8;
		Height 8;
		DamageType "Plasma";
		SeeSound "weapons/none";     // PROVEN missing in CH itself -- CH's deliberate silence (see header)
		DeathSound "weapons/gntidl"; // SNDINFO entry exists; lump DSGNTIDL missing in CH itself (see header)
		YScale 4.0;
		XScale 0.7;
		ReactionTime 35;
		+FLOORHUGGER
		BounceType "Hexen";   // CH: +HexenBounce
		+RIPPER
		+FLOORCLIP
		-NOGRAVITY
		-STRIFEDAMAGE
	}
	States
	{
	Spawn:
		HADE A 1 Bright A_Explode(random(5,15),64,0);   // per-frame explode: CH's crawling bolt, deliberate
		HADE A 0 A_CustomMissile("RS_HadesBolt2",0,0,0,6,90);
		HADE B 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(1,12),0,0,0,0);
		HADE A 0 ThrustThing(random(0,255),1,0,0);
		HADE B 1 Bright A_Explode(random(5,15),64,0);
		HADE B 0 A_CustomMissile("RS_HadesBolt2",0,0,0,6,90);
		HADE B 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(12,24),0,0,0,0);
		HADE C 1 Bright A_Explode(random(5,15),64,0);
		HADE C 0 A_CustomMissile("RS_HadesBolt2",0,0,0,6,90);
		HADE C 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(16,32),0,0,0,0);
		HADE D 1 Bright A_Explode(random(5,15),64,0);
		HADE D 0 A_CustomMissile("RS_HadesBolt2",0,0,0,6,90);
		HADE D 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(24,42),0,0,0,0);
		HADE H 1 Bright A_Explode(random(5,15),64,0);
		HADE H 0 A_CustomMissile("RS_HadesBolt2",0,0,0,6,90);
		HADE H 1 A_SpawnItemEx("RS_HadeExpl",random(-128,128),random(-128,128),random(32,64),0,0,0,0);
		HADE H 0 A_CountDown;
		Loop;
	Death:
		HADE FGHIJK 2 Bright A_Explode(random(5,35),64,0);
		Stop;
	}
}

class RS_HadesBolt2 : CacodemonBall   // CH Cacodemons.txt:3168 -- the crawler's riser
{
	Default
	{
		Damage 0;   // bare constant stays bare
		Speed 184;
		RenderStyle "None";
		DamageType "Plasma";
		+THRUGHOST
		+RIPPER
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_Explode(random(5,15),64,0);   // per-frame explode: CH's rising zap, deliberate
		Loop;
	Death:
		TNT1 A 1 Bright;
		Stop;
	}
}

class RS_BloodRainerCaco : Actor   // CH Cacodemons.txt:3535 -- the white boss's rain eye. Minion: no tier token.
{
	Default
	{
		Radius 16;
		Height 20;
		Health 9999;
		Speed 1;
		Species "Caco";
		Monster;
		+NOGRAVITY
		+NOCLIP
		-COUNTKILL
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		CDWO J 3 ThrustThingz(0,10,0,0);
	Death:
		CDWO IJ 8;
		TNT1 A 6 A_CustomMissile("RS_EyeRocketCaco",12,0,random(-3,3));
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_EyeRocketCaco : Actor   // CH Cacodemons.txt:3561 -- the seeking eye
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 24;
		FastSpeed 24;
		Scale 0.65;
		DamageFunction (random(50,150));   // CH: Damage(random(50,150))
		Projectile;
		+SEEKERMISSILE
		+THRUSPECIES
		+MTHRUSPECIES
		DamageType "Melee";
		SeeSound "skull/melee";
		DeathSound "vile/laugh";   // PROVEN missing in CH itself -- silent there too (see header)
	}
	States
	{
	Spawn:
		CDWO I 2 Bright A_SeekerMissile(11,11);
		Loop;
	Death:
		CDWO J 3 Bright A_Scream;
		TNT1 A 0 A_Explode(random(50,120),64);
		CDWO KLMN 3 Bright;
		CDWO O 3 Bright A_PlaySound("misc/gibbed");
		CDWO PQR 3 Bright;
		CDWO R 3 A_SetScale(0.45,0.45);
		CDWO R 3 A_SetScale(0.25,0.25);
		CDWO R 3 A_SetScale(0.05,0.05);
		Stop;
	}
}

class RS_WhiteCacoOrb1 : Actor   // CH Cacodemons.txt:3594 -- the orb of doom. Minion: no tier token.
{
	int user_angle;   // CH: var int user_angle
	Default
	{
		Species "Caco";
		Health 2000;
		Radius 16;
		Height 56;
		Mass 50;
		Scale 0.8;
		Speed 20;
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "plasma", 0.2;   // CH lists it twice (quoted :3606, bare :3607) -- kept once
		PainChance "DIMp", 0;
		PainChance 232;
		Monster;
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		+NOTRIGGER
		+NOICEDEATH
		+NOBLOOD
		+DONTMORPH
		-NORADIUSDMG
		AttackSound "";
		PainSound "prox/beep";
		DeathSound "prox/beep";
		ActiveSound "";
		DropItem "BackPack";
		DropItem "RS_CH_Medikit";
		Obituary "%o wasnt careful enough with the orb of doom";
		Tag "O of destruction";
	}
	States
	{
	Spawn:
		CDW2 X 0;
	See:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,64,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle = user_angle + 8; }   // CH: A_SetUserVar("user_angle",user_angle + 8)
		Loop;
	Pain:
		TNT1 A 0 A_Pain;
		TNT1 A 0 A_Jump(128,"Laser");
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile("RS_PlasmaBallSP5",random(-3,3),random(-12,12),random(0,360),CMF_AIMDIRECTION,random(0,360));
		Goto See;
	Laser:
		TNT1 AAA 0 A_CustomMissile("RS_DFlare",12,0,random(-3,3));
		Goto See;
	Death:
		CDW2 X 6 Bright;
		CDW2 X 3 Bright A_GiveInventory("RS_CacoSafety",1,AAPTR_MASTER);
		CDW2 X 5 Bright A_Scream;
		CDW2 X 5 Bright A_Scream;
		CDW2 X 6 Bright A_NoBlocking;
		CDW2 X 4 Bright A_CustomMissile("RS_HKRedDeath",100,-30,CMF_AIMOFFSET,2,-10);
		CDW2 X 4 Bright A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		CDW2 X 4 Bright A_CustomMissile("RS_HKRedDeath",20,30,CMF_AIMOFFSET,2,10);
		CDW2 X 4 Bright A_CustomMissile("RS_HKRedDeath",60,5,CMF_AIMOFFSET,2,-10);
		CDW2 X 4 A_CustomMissile("RS_HKRedDeath",100,50,CMF_AIMOFFSET,2,10);
		CDW2 XXX 4 A_FadeOut(0.25);
		Stop;
	}
}

class RS_CacoSafety : Inventory { Default { Inventory.MaxAmount 4; } }   // CH Cacodemons.txt:3660

class RS_WhiteCacoFake : Actor   // CH Cacodemons.txt:3662 -- the decoy. Fake: no tier token.
{
	Default
	{
		Radius 16;
		Height 20;
		Speed 0;
		Projectile;
		+NOGRAVITY
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		CACP AAAAA 7 A_Warp(AAPTR_DEFAULT,random(-128,128),random(-128,128),random(-32,32),0,WARPF_NOCHECKPOSITION);   // CH: A_warp(0,...)
		CACP A 5;
		CACP AAA 4 A_FadeOut(0.25);
		Stop;
	}
}

class RS_ArmSpawnerCACO : Actor   // CH Cacodemons.txt:3683 -- the white arm summoner
{
	Default
	{
		Radius 32;
		Height 16;
		Speed 1;
		FloatSpeed 1;
		+NOGRAVITY
		+FLOAT
		RenderStyle "Stencil";
		StencilColor "white";
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		GBLL A 3 Bright A_SetScale(4.7,4.7);
		GBLL B 3 Bright A_SetScale(4.4,4.4);
		GBLL C 3 Bright A_SetScale(3,3);
		Goto Death;
	Death:
		GBLL C 3 Bright A_SetScale(3.5,3.5);
		GBLL B 3 Bright A_SetScale(3,3);
		GBLL A 3 Bright A_SetScale(2,2);
		TNT1 AA 2 A_SpawnItemEx("RS_CacoARMSU",random(-64,64),random(-64,64),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAA 2 A_SpawnItemEx("RS_CacoARMSU",random(-128,128),random(-128,128),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAA 2 A_SpawnItemEx("RS_CacoARMSU",random(-256,256),random(-256,256),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_ArmSpawnerCACO2 : Actor   // CH Cacodemons.txt:3715 -- the black arm summoner
{
	Default
	{
		Radius 32;
		Height 16;
		Speed 1;
		FloatSpeed 1;
		+NOGRAVITY
		+FLOAT
		RenderStyle "Stencil";
		StencilColor "black";
	}
	States
	{
	Spawn:
		GBLL A 0;
		Goto Fly;
	Fly:
		GBLL A 2 Bright A_SetScale(4.7,4.7);
		GBLL B 2 Bright A_SetScale(4.4,4.4);
		GBLL C 2 Bright A_SetScale(3,3);
		Goto Death;
	Death:
		GBLL C 2 Bright A_SetScale(3.5,3.5);
		GBLL B 2 Bright A_SetScale(3,3);
		GBLL A 2 Bright A_SetScale(2,2);
		TNT1 AAA 2 A_SpawnItemEx("RS_CacoARMSU2",random(-64,64),random(-64,64),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAA 2 A_SpawnItemEx("RS_CacoARMSU2",random(-128,128),random(-128,128),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAA 2 A_SpawnItemEx("RS_CacoARMSU2",random(-256,256),random(-256,256),random(2,8),0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CacoARMSU2 : Actor   // CH Cacodemons.txt:3747 -- the rising arm, DIMp flavor
{
	Default
	{
		Radius 16;
		Height 20;
		Speed 0;
		Projectile;
		+RANDOMIZE
		+NOGRAVITY
		+THRUACTORS
		+FLOORHUGGER
		DamageType "DIMp";
		SeeSound "Forgotten/Active";
		Scale 1;
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		TNT1 A 3;
	Riiise:
		CDWO E 5 A_SetScale(1,0.25);
		CDWO E 5 A_SetScale(1,1);
		CDWO EFGH 3 Bright A_Explode(random(10,50),64);   // per-frame explode: CH's grasping arm, deliberate
		CDWO HHHH 7 Bright A_Explode(random(10,50),64);
		TNT1 A 0 A_SetScale(1,1.25);
		CDWO HHHHHH 6 Bright A_Explode(random(10,50),64);
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(1,1);
		CDWO H 4 Bright A_Explode(random(10,50),64);   // CH writes "bright bright" here -- kept once
		CDWO H 4 A_SetScale(0.75,0.75);
		CDWO H 4 A_SetScale(0.5,0.75);
		CDWO H 4 A_SetScale(0.25,0.75);
		CDWO H 4 A_SetScale(0.05,0.75);
		Stop;
	}
}

class RS_CacoARMSU : Actor   // CH Cacodemons.txt:3785 -- the rising arm, melee flavor
{
	Default
	{
		Radius 16;
		Height 20;
		Speed 0;
		Projectile;
		+RANDOMIZE
		+NOGRAVITY
		+THRUACTORS
		+FLOORHUGGER
		DamageType "Melee";
		SeeSound "Forgotten/Pain";
		Scale 1;
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		TNT1 A 3;
	Riiise:
		CDWO EFGH 4 Bright A_Explode(random(10,50),64);   // per-frame explode: CH's grasping arm, deliberate
		CDWO HGG 4 Bright A_Explode(random(10,50),64);
		TNT1 A 0 A_SetScale(1,1.25);
		CDWO HHGG 4 Bright A_Explode(random(10,50),64);
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(1,1);
		CDWO HGEF 4 Bright A_Explode(random(10,50),64);   // CH writes "bright bright" here -- kept once
		CDWO F 4 A_SetScale(1,0.75);
		CDWO F 4 A_SetScale(1,0.5);
		CDWO F 4 A_SetScale(1,0.25);
		Stop;
	}
}

class RS_CacobaldBall : Actor   // CH Cacodemons.txt:3820 -- the white boss's basic shot
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 20;
		FastSpeed 24;
		Damage 5;   // bare constant stays bare
		Projectile;
		+RANDOMIZE
		DamageType "Melee";
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Decal "DoomImpScorch";
	}
	States
	{
	Spawn:
		CEIE ABCDEF 4 Bright;
		Loop;
	Death:
		CEYX ABC 5 Bright;
		Stop;
	}
}

class RS_CacobaldBall2 : Actor   // CH Cacodemons.txt:3844 -- the wonky seeker
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 18;
		Damage 5;   // bare constant stays bare
		Projectile;
		+SEEKERMISSILE
		Scale 0.75;
		DamageType "Melee";
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Decal "DoomImpScorch";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Fly;
	Fly:
		TNT1 A 0 A_Jump(255,"A1","A2","A3");
	A1:
		CEIE ABCDEF 4 Bright A_BishopMissileWeave;
		Loop;
	A2:
		CEIE ABCDEF 4 Bright A_CStaffMissileSlither;
		Loop;
	A3:
		CEIE ABCDEF 4 Bright A_SetSpeed(30);
		Loop;
	Death:
		CEYX ABC 5 Bright;
		Stop;
	}
}
