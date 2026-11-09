// ============================================================================
// RS_PainElementalFX.zs -- Colourful Hell Pain Elemental family: support
// actors, projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\thepains.txt (3,307
// lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_PainElemental.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here): RS_Zom, RS_ZomTierToken, RS_GrowRaisin,
// RS_ColorTierIconCH..CH13, RS_HealthBundle, RS_ArmorBundle,
// RS_BackPackBundle, RS_implyingclip, RS_CH_SoulSphere, RS_CH_Medikit,
// RS_CH_BlueArmor, RS_CH_Berserk, RS_CH_MegaSphere, RS_CH_RocketLauncher,
// RS_CH_PlasmaRifle, RS_CH_ClipBox, RS_CH_CellPack, RS_CH_BFG9000,
// RS_CH_Shell, RS_CH_Cell, RS_CH_RocketAmmo, RS_CH_Cirno,
// RS_AbyssShotIdentifier, RS_SplashAbyss2, RS_RedThingsLS (demon FX),
// RS_REDTHINGSHK (zombieman FX), RS_CrackoBallTrail (imp FX),
// RS_PuffCybieRed (chaingunner FX), RS_DeathBreathDI (imp FX),
// RS_RandomizerArc (lostsoul FX), RS_SpeedBuffPE + RS_PESpeedCtl (spectre
// FX -- CH source is THIS family's file, thepains.txt:3046, but the spectre
// lane shipped it first; referenced read-only, NOT redefined).
// Lost Soul bodies this family spawns (all lostsoul lane, read-only):
// RS_CommonLSoul, RS_GreenLSoul, RS_BlueLSoul, RS_PurpleLSoul,
// RS_YellowLSoul, RS_RedLSoul, RS_BrownLSoul2, RS_CyanLSoul2, RS_GrayLSoul2,
// RS_BlackLSoul2, RS_FireBluLSoul2. Also RS_GraySpectre2 (spectre lane).
//
// The white boss's other two pack-buffs are CH ACS, rebuilt native here per
// the standing order ("break up the ACS yourself"), same mechanism as the
// spectre lane's RS_PESpeedCtl:
//   RS_RageBuffPE -> RS_PERageCtl (CHSett.acs:289 "PERAGE")
//   RS_HulkBuffPE -> RS_PEHulkCtl (CHSett.acs:345 "PEHULK")
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Class "CH_Soul" (Common/Green/Blue PE XDeath): defined NOWHERE in CH's
//     decorate tree (only CH_SoulSphere exists, DECORATE.txt:640). The spawn
//     is dead in CH; kept dead here through the runtime-lookup guard.
//   * Class "GrayDemon2" (RS_GrayPE2 Bug1, thepains.txt:988): CH spells the
//     demon body GreyDemon2 (Demons.txt:881) and defines GrayDemon2 nowhere,
//     so the hive's demon-birth attack was dead in CH. HEALED to
//     RS_GreyDemon2 at the owner's order (2026-08-05) -- a deliberate
//     departure from verbatim, the one CH bug this import fixes.
//   * Sprite NULL frame A (RS_RedPuff Spawn, thepains.txt:1763): no NULL*
//     lump in CH's sprite tree, and NULL is not a doom2.wad sprite. Renders
//     nothing for 3 tics in CH too.
//   * Sound "holy/holy2" (RS_PurplePE2 DeathSound): CH SNDINFO defines the
//     logical names "Holy2" and "Holy3", never "holy/holy2" -- silent in CH.
//     Kept verbatim.
//
// Standing strips, preserved at each site as "// CH:" comments: ACS
// announcers (AnnounceBlackPE, AnnounceWhitePE); the CHRandom_GibGenerator/
// NashGore gore chain (owner accepts vanilla gore; XDeath ANIMATIONS stay);
// DRLA RL*/RareArmorPool drops.
// ============================================================================

// ---------------------------------------------------------------------------
// The white boss's pack-buffs.  CH: thepains.txt:3014/3030 (the
// CustomInventories) + CHSett.acs:289 "PERAGE" / :345 "PEHULK" (the
// scripts).  PERAGE did: skip bosses; force NOPAIN; DamageMultiplier 1.5;
// hold 600 tics; restore.  PEHULK did: skip bosses; force QUICKTORETALIATE
// and DONTTHRUST, clear NODROPOFF; DamageFactor (damage TAKEN) 0.25; hold
// 600 tics; restore.  (CH's PEHULK revert gives NODROPOFF to monsters that
// never had it -- the remembered-flag revert below is the same fix
// RS_PESpeedCtl and RS_BrownImpBuffCtl use.)
// ---------------------------------------------------------------------------
class RS_RageBuffPE : CustomInventory   // CH thepains.txt:3014
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
		TNT1 A 0 { if (!bBOSS) A_SpawnItemEx("RS_PERageCtl",0,0,0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION); }
		Stop;
	}
}

class RS_PERageCtl : Actor   // native rebuild of CHSett.acs:289 "PERAGE"
{
	double prevDmgMul;
	bool setNoPain;
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
		prevDmgMul = m.DamageMultiply;
		if (!m.bNOPAIN) { m.bNOPAIN = true; setNoPain = true; }
		m.DamageMultiply = 1.5;   // CH: SetActorProperty(0,APROP_DamageMultiplier,1.5)
		applied = true;
	}

	void RS_RevertBuff()
	{
		let m = master;
		if (!applied || !m) return;
		m.DamageMultiply = prevDmgMul;
		if (setNoPain) m.bNOPAIN = false;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.RS_ApplyBuff(); }
		TNT1 A 600;   // CH: Delay(600)
		TNT1 A 0 { invoker.RS_RevertBuff(); }
		Stop;
	}
}

class RS_HulkBuffPE : CustomInventory   // CH thepains.txt:3030
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
		TNT1 A 0 { if (!bBOSS) A_SpawnItemEx("RS_PEHulkCtl",0,0,0,0,0,0,0,SXF_SETMASTER|SXF_NOCHECKPOSITION); }
		Stop;
	}
}

class RS_PEHulkCtl : Actor   // native rebuild of CHSett.acs:345 "PEHULK"
{
	double prevDmgFac;
	bool setQuick;
	bool setThrust;
	bool clearedNoDrop;
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
		if (!m.bQUICKTORETALIATE) { m.bQUICKTORETALIATE = true; setQuick = true; }
		if (m.bNODROPOFF) { m.bNODROPOFF = false; clearedNoDrop = true; }
		if (!m.bDONTTHRUST) { m.bDONTTHRUST = true; setThrust = true; }
		prevDmgFac = m.DamageFactor;
		m.DamageFactor = 0.25;   // CH: SetActorProperty(0,APROP_DAMAGEFACTOR,0.25)
		applied = true;
	}

	void RS_RevertBuff()
	{
		let m = master;
		if (!applied || !m) return;
		m.DamageFactor = prevDmgFac;
		if (setQuick) m.bQUICKTORETALIATE = false;
		if (clearedNoDrop) m.bNODROPOFF = true;
		if (setThrust) m.bDONTTHRUST = false;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.RS_ApplyBuff(); }
		TNT1 A 600;   // CH: Delay(600)
		TNT1 A 0 { invoker.RS_RevertBuff(); }
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Brown PE's flesh kit.  CH: thepains.txt:184-447.
// ---------------------------------------------------------------------------
class RS_BrownPEShot : Actor   // CH thepains.txt:184
{
	Default
	{
		Radius 6;
		Height 14;
		Speed 18;
		DamageFunction (random(10,45));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		SeeSound "baron/attack";
		DeathSound "baron/shotx";
		Translation "0:255=%[0.00,0.00,0.31]:[0.20,0.20,2.00]";
	}
	States
	{
	Spawn:
		BAL7 AB 4 Bright A_SpawnItemEx("RS_SplashBrownPE",0,0,3);
		Loop;
	Death:
		BAL7 CDE 6 Bright;
		TNT1 AAAAA 0 A_SpawnItemEx("RS_SplashBrownPE2",random(-6,6),random(-6,6),random(8,24),random(3,12),0,random(3,16),random(0,360),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_SplashBrownPE : Actor   // CH thepains.txt:209
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 16;
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		-NOGRAVITY
		+CLIENTSIDEONLY
		Scale 0.25;
		Translation "0:255=%[0.00,0.00,0.31]:[0.20,0.20,2.00]";
	}
	States
	{
	Spawn:
		BAL1 AB 12;
		BAL1 A 2 A_Jump(32,"Death");
		Loop;
	Death:
		BAL7 C 1 Bright A_SetScale(0.6,0.1);
		BAL7 CDE 4 Bright;
		Stop;
	}
}

class RS_SplashBrownPE2 : Actor   // CH thepains.txt:235
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 16;
		Projectile;
		+RANDOMIZE
		-NOGRAVITY
		+THRUACTORS
		Scale 0.25;
		Translation "0:255=%[0.00,0.00,0.31]:[0.20,0.20,2.00]";
	}
	States
	{
	Spawn:
		BAL1 AB 12;
		BAL1 A 2 A_Jump(32,"Death");
		Loop;
	Death:
		TNT1 A 0 { bFLATSPRITE = true; }   // CH: A_changeflag("FLATSPRITE",TRUE)
		BAL7 A 1 Bright A_SetScale(0.6,0.6);
		BAL7 AB 8 Bright;
		BAL7 A 6 Bright A_SetScale(0.9,0.9);
		BAL7 B 6 Bright A_SetScale(1.25,1.25);
		TNT1 A 0 A_PlaySound("monster/tenpn1",0);
		TNT1 AAA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);   // CH: "TNT1 A 000" frame runs
		BAL7 AB 8 Bright A_Explode(random(2,12),32,0);
		TNT1 AAA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("monster/tenpn2",0);
		BAL7 AB 8 Bright A_Explode(random(2,12),32,0);
		TNT1 AAA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		BAL7 AB 8 Bright A_Explode(random(2,12),32,0);
		TNT1 AAA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		BAL7 AB 8 Bright A_Explode(random(2,12),32,0);
		TNT1 A 0 A_PlaySound("monster/tenpn1",0);
		TNT1 AAA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		BAL7 AB 8 Bright A_Explode(random(2,12),32,0);
		TNT1 AAA 0 A_SpawnItemEx("RS_PuffCybieRed",random(-6,6),random(-6,6),random(6,32),0,0,random(1,9),0,SXF_NOCHECKPOSITION);
		BAL7 AB 8 Bright A_Explode(random(2,12),32,0);
		TNT1 A 0 A_PlaySound("monster/tenpn2",0);
		BAL7 CDE 2 A_FadeOut(0.25);
		Stop;
	}
}

class RS_BrownPEDed : Actor   // CH thepains.txt:280
{
	Default
	{
		Radius 1;
		Height 1;
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		SeeSound "Crack/death";
		Translation "0:255=%[0.00,0.00,0.31]:[0.20,0.20,2.00]";
		Scale 1.35;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		HADE IJKL 8 Bright A_FadeOut(0.15);
		Stop;
	}
}

class RS_FleshSpawnGibs : Actor   // CH thepains.txt:300
{
	Default
	{
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib1",14,0,random(-180,180),2,random(10,40));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib2",6,2,random(-180,180),2,random(0,25));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib2B",10,-2,random(-180,180),2,random(0,25));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib3",8,0,random(-180,180),2,random(0,35));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib4",12,5,random(-180,180),2,random(-5,40));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib4B",5,-5,random(-180,180),2,random(0,30));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib5",6,3,random(-180,180),2,random(10,60));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib5",8,0,random(-180,180),2,random(-10,55));
		TNT1 A 0 A_CustomMissile("RS_Fleshspawngib6",12,0,0,2,0);
		Stop;
	}
}

class RS_Fleshspawngib1 : Actor   // CH thepains.txt:320
{
	Default
	{
		Speed 8;
		Mass 100;
		Radius 1;
		Height 1;
		Projectile;
		-NOGRAVITY
		+DROPOFF
		Scale 1.5;
	}
	States
	{
	Spawn:
		FGB1 ABCD 4;
		Loop;
	Death:
		FGB1 E -1;
		Stop;
	}
}

class RS_Fleshspawngib2 : RS_Fleshspawngib1   // CH thepains.txt:341
{
	Default
	{
		Speed 8;
		Mass 100;
		Radius 1;
		Height 1;
		Projectile;
		-NOGRAVITY
		+DROPOFF
		+CLIENTSIDEONLY
		Scale 1.5;
	}
	States
	{
	Spawn:
		FGB2 ABCD 4;
		Loop;
	Death:
		FGB2 I -1;
		Stop;
	}
}

class RS_Fleshspawngib2B : RS_Fleshspawngib1   // CH thepains.txt:363
{
	Default
	{
		+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		FGB2 EFGH 4;
		Loop;
	Death:
		FGB2 J -1;
		Stop;
	}
}

class RS_Fleshspawngib3 : RS_Fleshspawngib1   // CH thepains.txt:377
{
	Default
	{
		+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		FGB3 ABCD 4;
		Loop;
	Death:
		FGB3 E -1;
		Stop;
	}
}

class RS_Fleshspawngib4 : RS_Fleshspawngib1   // CH thepains.txt:391
{
	Default
	{
		+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		FGB4 ABCD 4;
		Loop;
	Death:
		FGB4 I -1;
		Stop;
	}
}

class RS_Fleshspawngib4B : RS_Fleshspawngib1   // CH thepains.txt:405
{
	Default
	{
		+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		FGB4 EFGH 4;
		Loop;
	Death:
		FGB4 J -1;
		Stop;
	}
}

class RS_Fleshspawngib5 : RS_Fleshspawngib1   // CH thepains.txt:419
{
	Default
	{
		+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		FGB5 ABCD 4;
		Loop;
	Death:
		FGB5 E -1;
		Stop;
	}
}

class RS_Fleshspawngib6 : RS_Fleshspawngib1   // CH thepains.txt:433
{
	Default
	{
		+CLIENTSIDEONLY
		Speed 0;
	}
	States
	{
	Spawn:
		FGB6 A 4;
		Loop;
	Death:
		FGB6 BC 4;
		FGB6 D -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Cyan PE's ice orbs.  Third-file externals: CH defines these in
// Spiders.txt (the cyan Arachnotron's shots); thepains.txt:540/544 fires
// them.  The Spiders family is not imported yet -- when it lands, it
// references these read-only.
// ---------------------------------------------------------------------------
class RS_IceOrbCyanAra1 : Actor   // CH Spiders.txt:422
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		DamageFunction (random(10,45));
		DamageType "Ice";
		Projectile;
		+SEEKERMISSILE
		+BOUNCEONFLOORS
		RenderStyle "Add";
		BounceType "Doom";
		BounceCount 7;
		BounceFactor 1.25;
		WallBounceFactor 1.25;
		Alpha 0.85;
		Scale 1.5;
		Gravity 0.5;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		BounceSound "Ice/Splode";
		WeaveIndexXY 5;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 3 Bright A_SeekerMissile(6,6);
		ICEY B 3 Bright A_ScaleVelocity(1.5);
		ICEY C 3 Bright A_Weave(1,3,random(-1,1),random(-4,4));
		TNT1 A 0 { bNOGRAVITY = false; }   // CH: A_changeflag("NOGRAVITY",FALSE)
		Loop;
	Death:
		ICEY FGHI 5 Bright A_Explode(random(5,12),32);
		Stop;
	}
}

class RS_IceOrbCyanAra2 : Actor   // CH Spiders.txt:461
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		DamageFunction (random(10,50));
		DamageType "Ice";
		Projectile;
		Alpha 0.85;
		Scale 1.5;
		SeeSound "ice/Cast";
		DeathSound "Ice/Hit2";
		BounceSound "Ice/Splode";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY A 3 Bright;
		ICEY B 3 Bright A_ScaleVelocity(1.25);
		ICEY C 3 Bright A_Jump(32,"A1");
		Loop;
	A1:
		ICEY A 3 Bright ThrustThing(random(0,255),random(1,12),0,0);
		ICEY B 3 Bright A_ScaleVelocity(1.25);
		ICEY C 3 Bright;
		Loop;
	Death:
		ICEY FGHI 5 Bright A_Explode(random(5,12),32);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Abyss PE's kit.  CH: thepains.txt:747-900, plus the siphon soul it
// summons from Barons.txt (third-file external, the Barons family
// references it read-only when it lands).
// ---------------------------------------------------------------------------
class RS_AbyssPEShadow : Actor   // CH thepains.txt:747
{
	Default
	{
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		AYPE Y 8;
		AYPE Y 9;
		AYPE YYY 10 A_FadeOut(0.33);
		Stop;
	}
}

class RS_AbyPECoil : Actor   // CH thepains.txt:762
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 12;
		DamageFunction (random(30,80));
		DamageType "Melee";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		+SEEKERMISSILE
		Scale 0.3;
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
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		AYPE Y 0 A_SeekerMissile(4,5);
		TNT1 A 0 A_Jump(32,"Fly2");
		Loop;
	Fly2:
		AYPE Y 2 Bright A_Explode(random(18,28),64);
		AYPE Y 2 Bright A_SpawnItemEx("RS_TrailAbyPE1",-1,0,3,random(1,5),0,0,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		AYPE Y 0 A_SeekerMissile(1,1);
		TNT1 A 0 A_Jump(64,"Fly");
		Loop;
	Death:
		BAL1 CDE 2 Bright A_Explode(random(5,25),128);
		TNT1 A 0 A_RadiusGive("Health",128,RGF_MONSTERS|RGF_EXFILTER,175,"RS_AbyssPE2");
		TNT1 AAAAAAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_VollreyAbyPE : Actor   // CH thepains.txt:803
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 27;
		FastSpeed 38;
		DamageFunction (random(5,40));
		DamageType "Plasma";
		Projectile;
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.55;
		SeeSound "Forgotten/Attack";
		DeathSound "spell/Impact1";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		FRGO CC 2 Bright A_SeekerMissile(12,18);
		FRGO DD 2 Bright A_CustomMissile("RS_SplashAbyss2",8,0);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BBOM A 2 Bright A_SetScale(1.25);
		BBOM B 2 A_SetTranslucent(0.65);
		TNT1 AAAAAAAAAAAAAAAAAAA 0 A_CustomMissile("RS_SplashAbyss2",6,0,random(-359,359),CMF_OFFSETPITCH,random(-25,-5));
		BBOM CD 3 Bright A_Explode(random(2,12),128);
		BBOM EFG 6 Bright A_Explode(random(2,12),128);
		Stop;
	}
}

class RS_TrailAbyPE1 : Actor   // CH thepains.txt:837
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 16;
		DamageFunction (random(1,10));
		Projectile;
		+RIPPER
		RenderStyle "Add";
		Scale 0.75;
		Alpha 0.85;
		Translation "168:191=112:127";   // CH keeps the old whole-range remap commented out on this line
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BAL1 CDE 6 Bright A_RadiusGive("Health",125,RGF_MONSTERS|RGF_EXFILTER,5,"RS_AbyssPE2");
		TNT1 A 0 A_SetScale(0.5,0.5);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BAL1 CDE 6 Bright A_RadiusGive("Health",125,RGF_MONSTERS|RGF_EXFILTER,5,"RS_AbyssPE2");
		TNT1 A 0 A_SetScale(0.25,0.25);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		BAL1 CDE 6 Bright A_RadiusGive("Health",125,RGF_MONSTERS|RGF_EXFILTER,5,"RS_AbyssPE2");
		Goto Death;
	Death:
		BAL1 CDE 1 Bright;
		Stop;
	}
}

class RS_AbyssPEPulse : Actor   // CH thepains.txt:870
{
	Default
	{
		Speed 11;
		DamageFunction (random(1,2));
		DamageType "AbyssPE";
		Radius 10;
		Height 4;
		RenderStyle "Translucent";
		Alpha 0.1;
		Species "PE";
		Translation "ice";
		Projectile;
		+THRUACTORS
		+DROPOFF
		+FORCERADIUSDMG
		+BLOODLESSIMPACT
		+RIPPER
		+FORCEPAIN
		SeeSound "moloch/thud";
	}
	States
	{
	Spawn:
		TNT1 A 4;
	Fly:
		TNT1 A 0 { bTHRUACTORS = false; }   // CH: A_changeflag("thruactors",false)
		IDGA CCAABBCCC 10 A_Explode(random(1,2),128);
	Death:
		IDGA C 1 A_Explode(random(10,30),128);
		Stop;
	}
}

class RS_AbyssBaronSoul : Actor   // CH Barons.txt:1252 -- the siphon soul the abyss PE summons
{
	Default
	{
		Obituary " %o was soul siphoned";
		Health 30;
		Radius 24;
		Height 24;
		Mass 20;
		Speed 30;
		FloatSpeed 30;
		Species "LSoul";
		DamageType "Ice";
		AttackSound "vile/active";
		DeathSound "weapons/rocklx";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
		Scale 0.75;
		Monster;
		+FLOAT
		+NOICEDEATH
		+FLOATBOB
		+NOTARGETSWITCH
		+MISSILEMORE
		+NOPAIN
		+THRUSPECIES
		+MISSILEEVENMORE
		+NOGRAVITY
		+LOOKALLAROUND
		+NOBLOOD
		+THRUACTORS
		-COUNTKILL
	}
	States
	{
	Spawn:
		SSUL AB 2 Bright;
		Goto See;
	See:
		SSUL A 1 Bright A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		SSUL B 1 Bright A_SpawnItemEx("RS_AbyssBaronHandFire",0,0,0,0,0,0,0);
		SSUL A 1 Bright A_Chase;
		SSUL B 1 Bright A_SpawnItemEx("RS_AbyssBaronHandFire",0,0,0,0,0,0,0);
		SSUL A 1 Bright A_Chase;
		SSUL B 1 Bright A_SpawnItemEx("RS_AbyssBaronHandFire",0,0,0,0,0,0,0);
		TNT1 A 0 { bTHRUACTORS = false; }   // CH: A_changeflag("THRUACTORS",FALSE)
		Loop;
	Melee:
		BAL1 A 0;
		Goto Boom;
	Death:
		TNT1 A 0;
		Goto Boom;
	Boom:
		MISL B 0 A_SetScale(1.1);
		MISL B 0 A_Explode(random(20,80),128);
		MISL B 5 Bright A_PlaySound("weapons/rocklx");
		MISL C 5 A_NoBlocking;
		MISL D 5;
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_AbyssBaronHandFire : Actor   // CH Barons.txt:1342
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 1;
		Projectile;
		+NOINTERACTION
		+NOCLIP
		RenderStyle "Add";
		Alpha 1.95;
		XScale 0.75;
		YScale 1.54;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		FRFX ABCD 2 Bright;
		Goto Death;
	Death:
		FRFX HIJKLMNO 1 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Green / Blue / FireBlu / Purple / Yellow / Red projectiles.
// ---------------------------------------------------------------------------
class RS_Gas13 : Actor   // CH thepains.txt:1326 -- green's fart cloud (Gas14 is the shotgunner lane's, different actor)
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
		PSBG CDEFGHGF 4 Bright A_Explode(random(6,12),42);
		PSBG G 0 A_Jump(56,"Death");
		Loop;
	Death:
		PSBG CDEFGHI 6 Bright A_Explode(random(6,12),42);
		Stop;
	}
}

class RS_PlasmaPE : Actor   // CH thepains.txt:1453
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 14;
		FastSpeed 26;
		DamageFunction (random(10,23));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.8;
		SeeSound "spell/spellcast1";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSE AB 4 Bright A_SeekerMissile(1,1);
		Loop;
	Death:
		PLSE CDE 6 Bright A_Explode(8,32);
		Stop;
	}
}

class RS_BoomPEBlu : Actor   // CH thepains.txt:1130 -- fireblu's exploding skull-bomb
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 25;
		Projectile;
		DamageType "Fire";   // CH lists DamageType twice; both are Fire
		DamageFunction (random(25,50));
		RenderStyle "Add";
		Translation "208:223=197:207";
		DeathSound "weapons/rocklx";
		Alpha 0.75;
	}
	States
	{
	Spawn:
		MISL B 4 Bright;
		Goto Death;
	Death:
		MISL CD 4 Bright A_Explode(random(20,40),64,0);
		TNT1 A 0 A_SpawnItemEx("RS_FireBluLSoul2",0,0,6,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,128);
		Stop;
	}
}

class RS_PurplePE1 : Actor   // CH thepains.txt:1572
{
	Default
	{
		Radius 8;
		Height 10;
		Speed 24;
		FastSpeed 24;
		Mass 23;
		Gravity 0.3;
		DamageFunction (random(10,47));
		Projectile;
		+RANDOMIZE
		+EXPLODEONWATER
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.88;
		Scale 1;
		SeeSound "caco/attack";
		DeathSound "Bomb/boom";
		Translation "168:191=250:254";
	}
	States
	{
	Spawn:
		SBS1 ABCD 6 Bright A_SeekerMissile(3,3);
		Loop;
	Death:
		SBS4 DE 6 Bright A_SetTranslucent(0.4);
		SBS4 FGH 6 Bright A_Explode(random(5,38),88);
		Stop;
	}
}

class RS_PurplePE2 : Actor   // CH thepains.txt:1604
{
	Default
	{
		Radius 8;
		Height 10;
		Speed 28;
		FastSpeed 50;
		Mass 23;
		Gravity 0.3;
		DamageFunction (random(5,25));
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.75;
		SeeSound "caco/attack";
		DeathSound "holy/holy2";
		Translation "168:191=250:254","208:223=250:252","128:143=250:252","64:79=251:254","160:167=251:251","48:63=250:251";
	}
	States
	{
	Spawn:
		SKUL CD 5 Bright;
		Loop;
	Death:
		SKUL C 6 Bright A_SetTranslucent(0.4);
		SKUL D 5 A_SetTranslucent(0.25);
		SKUL D 4 A_SetTranslucent(0.1);
		Stop;
	}
}

class RS_LavaballPE : Actor   // CH thepains.txt:1722
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 17;
		DamageFunction (random(15,60));
		DamageType "Fire";
		Scale 1.0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.95;
		+THRUGHOST
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex3";
		BounceType "Doom";
		BounceCount 3;
		WallBounceFactor 1.25;
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
	}
	States
	{
	Spawn:
		BAL3 AB 4 Bright A_SpawnItem("RS_RedPuff",0,0);
		Loop;
	Death:
		BAL3 C 5 Bright A_Explode(random(5,50),88);
		BAL3 DE 5 Bright;
		Stop;
	}
}

class RS_RedPuff : Actor   // CH thepains.txt:1752
{
	Default
	{
		Radius 0;
		Height 1;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
	}
	States
	{
	Spawn:
		TNT1 A 3 Bright;   // CH: NULL A -- CH ships no NULL lump; the token is its idiom for "draw nothing for a beat" before the real animation (same shape at CYBIES.txt:3915, Imps.txt:2530, thepains.txt:1763). TNT1 is GZDoom the actual null sprite and what the rest of this tree uses. Same tics. Fixed 2026-08-06.
		RPUF ABCDE 3 Bright;
		Stop;
	}
}

class RS_SbombPE : Actor   // CH thepains.txt:1882
{
	Default
	{
		Radius 20;
		Height 20;
		Mass 600;
		Speed 9;
		DamageFunction (random(10,50));
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
		BAL1 A 1 A_SetScale(1.65);
		BAL1 A 1 A_CustomMissile("RS_REDTHINGSHK",5,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		BAL1 B 1 A_SetScale(2);
		BAL1 B 1 A_SpawnItemEx("RS_RedThingsLS",0,0,5,0,0,0,0,SXF_NOCHECKPOSITION);
		Loop;
	Death:
		BAL1 C 4 A_SetTranslucent(0.35);
		BAL1 D 1 A_Explode(random(5,25),88);
		BAL1 DDEE 3;
		BAL1 E 2 A_SpawnItemEx("RS_RedLSoul",0,0,-34,0,0,0,0,128,SXF_NOCHECKPOSITION,178);
		Stop;
	}
}

class RS_CorpseBreathPE : Actor   // CH thepains.txt:1914
{
	Default
	{
		Radius 18;
		Height 18;
		Speed 15;
		DamageFunction (random(5,12));
		DamageType "Melee";
		Projectile;
		+THRUACTORS
		-NOGRAVITY
		+BOUNCEONFLOORS
		RenderStyle "Add";
		BounceType "Doom";
		BounceCount 3;
		BounceFactor 0.8;
		Gravity 0.24;
		Alpha 0.85;
		Scale 0.85;
		SeeSound "misc/gibbed";
		DeathSound "misc/gibbed";
		Translation "192:207=250:254";
	}
	States
	{
	Spawn:
		POSS N 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS N 1 A_SetTranslucent(0.6);
		POSS NN 2 A_Explode(random(5,8));
		POSS N 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS NOO 1 A_Explode(random(5,8));
		POSS O 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS OOP 1 A_Explode(random(5,8));
		POSS P 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS P 1 A_SetTranslucent(0.45);
		POSS P 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS QRR 3 A_Explode(random(5,8));
		POSS R 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS RSTT 3 A_Explode(random(5,8));
		POSS UU 1 A_SpawnItemEx("RS_RedThingsLS",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		POSS U 3 A_SetTranslucent(0.25);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Black boss (Hell Soul Elemental) kit.  CH: thepains.txt:2147-2657.
// ---------------------------------------------------------------------------
class RS_LoadPE3 : Actor   // CH thepains.txt:2147
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 1;
		Damage 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.80;
		Scale 0.75;
		DamageType "Plasma";
	}
	States
	{
	Spawn:
		LFX1 STUV 2 Bright;
		Goto Death;
	Death:
		LFX1 S 1;
		Stop;
	}
}

class RS_SkullDeathPE : Actor   // CH thepains.txt:2169
{
	Default
	{
		Radius 5;
		Height 7;
		Speed 32;
		FastSpeed 38;
		DamageFunction (random(10,50));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.65;
		SeeSound "Forgotten/Attack";
		DeathSound "spell/Impact1";
		Translation "76:79=44:47","136:143=184:191","128:136=175:183","64:79=176:191","208:223=171:181","161:161=170:170","144:151=180:191";
	}
	States
	{
	Spawn:
		FRGO C 1 Bright A_Weave(1,1,1,1);
		FRGO D 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,2,0,0,0,0,128);
		FRGO C 1 Bright A_Weave(1,1,1,1);
		FRGO D 1 Bright A_SpawnItemEx("RS_CrackoBallTrail",0,0,2,0,0,0,0,128);
		Loop;
	Death:
		MISL B 3 Bright A_SetScale(1.4);
		MISL C 3 A_SetTranslucent(0.65);
		MISL D 3 Bright A_Explode(random(10,25),128);
		MISL D 5 Bright A_Explode(random(10,45),128);   // CH: MISL E -- vanilla MISL ships A-D only (verified in both IWAD lump directories); E is one letter past the end of the rocket explosion. Held D, its last real frame. Tics and actions unchanged. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_SkullBundle3 : Actor   // CH thepains.txt:2203
{
	Default
	{
		Radius 6;
		Height 32;
		Speed 15;
		Damage 3;
		Projectile;
		-ACTIVATEPCROSS
		+RANDOMIZE
		SeeSound "brain/spit";
		DeathSound "brain/cubeboom";
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 176, 2;
		DropItem "RS_CH_Cell", 72;
		DropItem "RS_CH_RocketAmmo", 128;
	}
	States
	{
	Spawn:
		BOSF ABCD 3 Bright;
		Loop;
	Death:
		FIRE ABCDEF 2 Bright A_Fire;
		FIRE GGHH 1 A_PainAttack("RS_BundleRandom3",random(-180,180));
		FIRE H 0 A_Scream;
		Stop;
	}
}

class RS_BundleRandom3 : RandomSpawner   // CH thepains.txt:2231
{
	Default
	{
		DropItem "RS_CommonLSoul", 255, 150;
		DropItem "RS_GreenLSoul", 255, 125;
		DropItem "RS_BlueLSoul", 255, 100;
		DropItem "RS_PurpleLSoul", 255, 75;
		DropItem "RS_YellowLSoul", 255, 50;
		DropItem "RS_RedLSoul", 255, 50;
	}
}

class RS_BEESHOT : Actor   // CH thepains.txt:2241
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 1;
		Damage 0;
		Projectile;
		+INVISIBLE
		RenderStyle "Add";
		Alpha 0.80;
		DamageType "Plasma";
	}
	States
	{
	Spawn:
		LFX1 S 1;
		Goto Death;
	Death:
		LFX1 SS 2 Bright A_SpawnItemEx("RS_BlackLSoul2",random(-12,12),random(-12,12),random(-12,12),0,0,0,0,SXF_SETMASTER);
		Stop;
	}
}

class RS_OverFlesh1 : Actor   // CH thepains.txt:2263
{
	Default
	{
		Speed 8;
		Mass 100;
		Radius 1;
		Height 1;
		Projectile;
		+THRUGHOST
		Gravity 0.125;   // was +LOWGRAVITY (engine sets Gravity = 1/8)
		-NOGRAVITY
	}
	States
	{
	Spawn:
		OVF1 ACEGIKM 5;
		Loop;
	Death:
		OVF1 O 3;
		OVF1 Q -1;
		Stop;
	}
}

class RS_OverFlesh2 : RS_OverFlesh1   // CH thepains.txt:2285
{
	States
	{
	Spawn:
		OVF1 BDFHJLN 5;
		Loop;
	Death:
		OVF1 P 3;
		OVF1 R -1;
		Stop;
	}
}

class RS_OverFlesh3 : RS_OverFlesh1   // CH thepains.txt:2299
{
	States
	{
	Spawn:
		OVF2 ACEG 5;
		Loop;
	Death:
		OVF2 I -1;
		Loop;
	}
}

class RS_OverFlesh4 : RS_OverFlesh1   // CH thepains.txt:2312
{
	States
	{
	Spawn:
		OVF2 BDFH 5;
		Loop;
	Death:
		OVF2 J -1;
		Loop;
	}
}

class RS_OverFlesh5 : RS_OverFlesh1   // CH thepains.txt:2325
{
	States
	{
	Spawn:
		OVF3 ACEGI 5;
		Loop;
	Death:
		OVF3 K -1;
		Loop;
	}
}

class RS_OverFlesh6 : RS_OverFlesh1   // CH thepains.txt:2338
{
	States
	{
	Spawn:
		OVF3 BDFHJ 5;
		Loop;
	Death:
		OVF3 L -1;
		Loop;
	}
}

class RS_OverBigArm1 : RS_OverFlesh1   // CH thepains.txt:2351
{
	States
	{
	Spawn:
		OVF4 ACEGI 5;
		Loop;
	Death:
		OVF4 K 3;
		OVF4 M -1;
		Stop;
	}
}

class RS_OverBigArm2 : RS_OverFlesh1   // CH thepains.txt:2365
{
	States
	{
	Spawn:
		OVF4 BDFHJ 5;
		Loop;
	Death:
		OVF4 L 3;
		OVF4 N -1;
		Stop;
	}
}

class RS_OverSmallArm1 : RS_OverFlesh1   // CH thepains.txt:2379
{
	States
	{
	Spawn:
		OVF5 ACEG 5;
		Loop;
	Death:
		OVF5 I -1;
		Stop;
	}
}

class RS_OverSmallArm2 : RS_OverFlesh1   // CH thepains.txt:2392
{
	States
	{
	Spawn:
		OVF5 BDFH 5;
		Loop;
	Death:
		OVF5 J -1;
		Stop;
	}
}

class RS_OverHorn1 : RS_OverFlesh1   // CH thepains.txt:2405
{
	States
	{
	Spawn:
		OVF6 ACEGI 5;
		Loop;
	Death:
		OVF6 K -1;
		Stop;
	}
}

class RS_OverHorn2 : RS_OverFlesh1   // CH thepains.txt:2418
{
	States
	{
	Spawn:
		OVF6 BDFHJ 5;
		Loop;
	Death:
		OVF6 L -1;
		Stop;
	}
}

class RS_HadesBall4 : CacodemonBall   // CH thepains.txt:2431
{
	Default
	{
		Damage 8;   // bare constant stays bare
		Speed 15;
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
		HEFX CDEEFGH 3 Bright;
		Stop;
	}
}

class RS_OverBall3 : Actor   // CH thepains.txt:2453
{
	Default
	{
		Radius 10;
		Height 20;
		Speed 15;
		Damage 8;
		DamageType "Plasma";
		ExplosionDamage 32;
		ExplosionRadius 32;
		Projectile;
		RenderStyle "Add";
		Alpha 0.75;
		Translation "192:207=168:191";
		+THRUGHOST
		+FORCEXYBILLBOARD
		DeathSound "weapons/devzap";
		Decal "CacoScorch";
	}
	States
	{
	Spawn:
		AFX1 ABC 1 Bright;
		Loop;
	Death:
		AFX1 DE 4 Bright A_Explode;
		AFX1 FGHI 4 Bright;
		Stop;
	}
}

class RS_StormShot1 : Actor   // CH thepains.txt:2482
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 30;
		DamageFunction (random(40,150));
		Projectile;
		RenderStyle "Add";
		Alpha 0.80;
		DamageType "Plasma";
		+THRUGHOST
		+NODAMAGETHRUST
		+FORCEXYBILLBOARD
		DeathSound "weapons/devexp";
	}
	States
	{
	Spawn:
		LFX1 STUVW 1 Bright;
		LFX1 W 0 A_CustomMissile("RS_StormLite1",0,0,90,6);
		LFX1 W 0 A_CustomMissile("RS_StormLite1",0,0,270,6);
		Loop;
	Death:
		LFX1 S 0 A_SpawnItemEx("RS_StormShotter3",0,0,1,0,0,0,0);
		LFX1 STUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVW 1 Bright A_Explode(16,32,0);
		Stop;
	}
}

class RS_StormShotter3 : Actor   // CH thepains.txt:2510
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 0;
		Projectile;
		RenderStyle "Add";
		Alpha 0.10;
		DamageType "Plasma";
		+THRUGHOST
		+NODAMAGETHRUST
		+FORCEXYBILLBOARD
		DeathSound "weapons/devexp";
	}
	States
	{
	Spawn:
		LFX1 S 0;
		Goto Death;
	Death:
		LFX1 STUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVWSTUVW 1 A_CustomMissile("RS_OverBall3",0,0,CMF_AIMOFFSET,random(0,360),random(0,360));
		Stop;
	}
}

class RS_StormStrike1 : Actor   // CH thepains.txt:2534
{
	Default
	{
		Radius 16;
		Height 1;
		Speed 90;
		Damage 2;
		Projectile;
		DamageType "lightning";
		RenderStyle "Add";
		Alpha 0.75;
		+THRUGHOST
		+RIPPER
		+NODAMAGETHRUST
		+STRIFEDAMAGE
		DeathSound "weapons/devzap";
	}
	States
	{
	Spawn:
		LFX1 IJKLM 1 Bright A_Explode(64,64,0);
		Loop;
	Death:
		LFX1 NOPQR 2 Bright;
		Stop;
	}
}

class RS_StormBolt : RS_StormStrike1   // CH thepains.txt:2560
{
	Default
	{
		Speed 4;
		Radius 8;
		Height 16;
		Damage 1;
		DamageType "lightning";
		SeeSound "weapons/none";     // CH: not in CH SNDINFO -- CH's deliberate silent idiom (see caco header)
		DeathSound "weapons/gntidl"; // CH: SNDINFO maps it to DSGNTIDL, a lump CH never ships -- silent there too
		YScale 4.0;
		XScale 2.0;
		ReactionTime 35;
		+FLOORHUGGER
		BounceType "Hexen";   // was +HEXENBOUNCE
		-NOGRAVITY
	}
	States
	{
	Spawn:
		LFX2 F 1 Bright A_Explode(16,64,0);
		LFX2 F 0 A_CustomMissile("RS_StormBolt2",16,0,0,6,90);
		LFX2 F 0 ThrustThing(random(0,255),1,0,0);
		LFX2 G 1 Bright A_Explode(16,64,0);
		LFX2 G 0 A_CustomMissile("RS_StormBolt2",16,0,0,6,90);
		LFX2 H 1 Bright A_Explode(16,64,0);
		LFX2 H 0 A_CustomMissile("RS_StormBolt2",16,0,0,6,90);
		LFX2 I 1 Bright A_Explode(16,64,0);
		LFX2 I 0 A_CustomMissile("RS_StormBolt2",16,0,0,6,90);
		LFX2 J 1 Bright A_Explode(16,64,0);
		LFX2 J 0 A_CustomMissile("RS_StormBolt2",16,0,0,6,90);
		LFX2 J 0 A_CountDown;
		Loop;
	Death:
		LFX2 FGHIJ 2 Bright A_Explode(16,64,0);
		Stop;
	}
}

class RS_StormBolt2 : RS_StormStrike1   // CH thepains.txt:2597
{
	Default
	{
		Speed 184;
		Damage 1;
		Height 15;
		Radius 8;
		DamageType "lightning";
		SeeSound "Monster/hadtel";
		DeathSound "Monster/hadsit";
		+RIPPER
		+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 1 Bright A_Explode(16,64,0);
		Loop;
	Death:
		TNT1 A 1 Bright;
		Stop;
	}
}

class RS_StormLite1 : Actor   // CH thepains.txt:2619
{
	Default
	{
		Radius 6;
		Height 12;
		Speed 32;
		Damage 5;
		Projectile;
		RenderStyle "Add";
		Alpha 0.80;
		DamageType "lightning";
		DeathSound "weapons/devzap";
		+THRUGHOST
		+RIPPER
		+FORCEXYBILLBOARD
	}
	States
	{
	Spawn:
		DLIT ABC 1 Bright;
		Loop;
	Death:
		DLIT DEFGHIJKLMNO 1 Bright;
		Stop;
	}
}

class RS_StormLite2 : RS_StormLite1   // CH thepains.txt:2644
{
	Default
	{
		Speed 64;
		Damage 10;
	}
	States
	{
	Spawn:
		LFX1 XYZ 1 Bright;
		Loop;
	Death:
		LFX1 STUVW 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White boss (the Watcher) kit.  CH: thepains.txt:2920-3308.
// ---------------------------------------------------------------------------
class RS_DFlarePE : Actor   // CH thepains.txt:2920
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 25;
		DamageFunction (random(10,20));
		RenderStyle "Stencil";
		StencilColor "red";
		DamageType "Fire";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		+THRUSPECIES
		Species "PE";
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		VBA3 AB 3 Bright A_SpawnItemEx("RS_MFlareFX",0,0,0,0,0,0,0,128);
		Goto Death;
	Death:
		CBAL CDEFG 3 Bright;
		Stop;
	}
}

class RS_DFlarePE2 : Actor   // CH thepains.txt:2948 -- same flare, but the Spawn loops
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 25;
		DamageFunction (random(10,20));
		RenderStyle "Stencil";
		StencilColor "red";
		DamageType "Fire";
		Alpha 0.85;
		Projectile;
		+THRUGHOST
		+MTHRUSPECIES
		+THRUSPECIES
		Species "PE";
		SeeSound "weapons/firmfi";
		DeathSound "weapons/firex4";
	}
	States
	{
	Spawn:
		VBA3 AB 3 Bright A_SpawnItemEx("RS_MFlareFX",0,0,0,0,0,0,0,128);
		Loop;
	Death:
		CBAL CDEFG 3 Bright;
		Stop;
	}
}

class RS_BufferWhitePE : Actor   // CH thepains.txt:2976 -- drops one of the three pack-buffs
{
	Default
	{
		Radius 6;
		Height 1;
		+NOTRIGGER
		+LOOKALLAROUND
		+NOTARGET
		+NEVERTARGET
		+NOCLIP
		RenderStyle "Stencil";
		StencilColor "black";
		Speed 5;
		Scale 0.35;
		Alpha 0.01;
		Mass 2;
	}
	States
	{
	Spawn:
		RNGG A 0;
		Goto See;
	See:
		TNT1 A 0 A_Jump(256,"A1","A2","A3");
	A1:
		RNGG A 0 A_RadiusGive("RS_RageBuffPE",526,RGF_MONSTERS|RGF_EXFILTER|RGF_EXSPECIES,1,"RS_WhitePE2","PE");
		TNT1 AAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	A2:
		RNGG A 0 A_RadiusGive("RS_HulkBuffPE",526,RGF_MONSTERS|RGF_EXFILTER|RGF_EXSPECIES,1,"RS_WhitePE2","PE");
		TNT1 AAAAA 0 A_SpawnParticle("green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	A3:
		RNGG A 0 A_RadiusGive("RS_SpeedBuffPE",526,RGF_MONSTERS|RGF_EXFILTER|RGF_EXSPECIES,1,"RS_WhitePE2","PE");
		TNT1 AAAAA 0 A_SpawnParticle("blue",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Stop;
	}
}

class RS_HealthFountainWhitePE : Actor   // CH thepains.txt:3062 -- walking green heal/resurrect zone
{
	Default
	{
		Health 100;
		Monster;
		Radius 16;
		Height 3;
		-ACTIVATEMCROSS
		-COUNTKILL
		+NOTRIGGER
		+LOOKALLAROUND
		+NOTARGET
		+NEVERTARGET
		+NOCLIP
		RenderStyle "Stencil";
		StencilColor "green";
		Speed 15;
		Species "PE";
		Scale 0.65;
		Alpha 0.95;
		Mass 500;
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_Shell", 64;
		DropItem "RS_CH_RocketAmmo", 42;
		DropItem "RS_CH_Cell", 12;
	}
	States
	{
	Spawn:
		RNGG A 0;
		Goto See;
	See:
		RNGG A 0 A_RadiusGive("RS_GrowRaisin",60,RGF_MONSTERS|RGF_CORPSES,1);
		RNGG A 0 A_RadiusGive("Health",252,RGF_MONSTERS|RGF_EXFILTER|RGF_EXSPECIES,25,"RS_WhitePE2","PE");
		RNGG AB 6 Bright A_Chase(null,null,CHF_RESURRECT);   // CH: A_Chase("","",CHF_RESURRECT)
		TNT1 AAAAA 0 A_SpawnParticle("green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		RNGG CD 6 Bright A_Wander;
		Loop;
	Heal:
		BBOM CDE 2 Bright;
		TNT1 AAAAA 0 A_SpawnParticle("green",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,24,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Goto See;
	}
}

class RS_MiniSentinelPE : Actor   // CH thepains.txt:3106 -- the Watcher's orbiting drone
{
	int user_angle;
	int user_pitch;   // CH: declared, never used
	Default
	{
		Health 70;
		PainChance 255;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Species "PE";
		Speed 28;
		Radius 12;
		Height 26;
		Mass 300;
		Monster;
		+NOGRAVITY
		+DROPOFF
		+NOBLOOD
		+NOBLOCKMONST
		+INCOMBAT
		+MISSILEMORE
		+LOOKALLAROUND
		+NEVERRESPAWN
		SeeSound "";
		DeathSound "Crack/death";
		ActiveSound "";
		PainSound "prox/beep";
		Obituary "%o was vaporized by a frustated mini sentinel";
		DropItem "RS_implyingclip", 128;
		DropItem "RS_CH_Shell", 64;
		DropItem "RS_CH_RocketAmmo", 42;
		DropItem "RS_CH_Cell", 12;
	}
	States
	{
	Spawn:
		MNDR A 10;
		Goto MoveIt;
	MoveIt:
		TNT1 A 0 A_Jump(8,"Angreh");
		TNT1 A 0 A_Jump(255,"A1","A2","A3","A4","A5","A6","A7");
	A1:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,2,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }   // CH: A_SetUserVar("user_angle",user_angle + 8)
		Loop;
	// CH defines A5 TWICE (thepains.txt:3149 and :3255). DECORATE lets the
	// second definition win, so this first block is unreachable in CH; it is
	// kept, dead, under a parked label to preserve that exactly.
	A5_CHDeadFirst:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,62,0,48,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		Loop;
	A6:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,78,0,26,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		Loop;
	A2:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,22,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,52,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,42,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,0,52,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,62,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,0,72,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,0,82,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,0,82,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,0,72,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,62,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,0,52,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,0,42,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-52,0,32,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,0,22,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,2,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,0,-2,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,0,-12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,0,-12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,0,-2,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,2,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle += 8; }
		Loop;
	A3:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,0,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,22,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,52,0,32,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,42,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,0,52,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,62,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,0,72,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,0,82,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,0,82,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,0,72,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,62,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,0,52,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,0,42,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-52,0,32,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,0,22,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,0,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,0,-2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,0,-12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,0,-12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,0,-2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	A7:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,12,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,24,22,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-52,36,32,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,48,42,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,60,52,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,72,62,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,84,72,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,96,82,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,96,82,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,84,72,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,72,62,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,60,52,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,48,42,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,52,36,32,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,24,22,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,12,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,-12,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,-24,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,-24,-2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,12,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,-2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	A4:
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,12,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 0 { user_angle -= 12; }   // CH: A_SetUserVar("user_angle",user_angle - 12)
		Loop;
	A5:   // CH's second A5 (thepains.txt:3255) -- the one DECORATE actually uses
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,0,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,0,22,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-52,0,32,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-42,0,42,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-32,0,52,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,62,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,0,72,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,0,82,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,0,82,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,0,72,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,62,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,0,52,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,42,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,52,0,32,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,42,0,22,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,32,0,12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,22,0,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,12,0,-2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,2,0,-12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-2,0,-12,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-12,0,-2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		MNDR A 1 Bright A_Warp(AAPTR_MASTER,-22,0,2,0,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		Loop;
	Angreh:
		MNDR A 1 A_SentinelBob;
		MNDR A 2 A_Chase;
		Loop;
	Missile:
		MNDR A 4 A_FaceTarget;
		MNDR B 1 Bright A_CustomMissile("RS_DFlarePE2",15,0,0);
		MNDR B 1 Bright A_CustomMissile("RS_DFlarePE2",15,0,random(-3,3));
		MNDR B 1 Bright A_CustomMissile("RS_DFlarePE2",15,0,random(-9,9));
		MNDR A 4;
		Goto Angreh;
	Pain:
		MNDR A 5 A_Pain;
		Goto Angreh;
	Death:
		MNDR C 7 Bright A_Fall;
		MNDR D 5 Bright A_Scream;
		MNDR E 5 Bright A_TossGib;
		MNDR F 5 Bright;
		MNDR G 5 Bright A_TossGib;
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
