// ============================================================================
// RS_ChaingunnerFX.zs -- Colourful Hell Chaingunner family: support classes.
// Source of truth: C:\Users\Command\Desktop\CH (Chaingunners.txt read whole,
// 3,169 lines; externals from DECORATE.txt / CYBIES.txt / Revenants.txt --
// each class cites its CH file:line).
//
// Same import rules as zombieman/shotgunner (see RS_ZombiemanFX.zs header):
// native ZScript, rs_ch_* gates, no announcers, no gore chain, no abstract,
// no DRLA/LegenDoom. Tier = RS_ZomTierToken via RS_Zom.SetTier().
// Shared classes reused read-only from the earlier families: RS_Zom, icons,
// RS_CHBoner, RS_GrowRaisin, RS_ThePlanBoner, RS_SplashAbyss(2),
// RS_AbyssZShotCH3, RS_IceZombieShot2, RS_HKRedDeath, RS_AbyssShotIdentifier,
// RS_DetoPuffCG, RS_PlasmaBallSP3, RS_SparkPuff1, RS_TrailSPCguy,
// RS_CH_* drop gates, bundles, RS_CH_Pantsu, RS_CH_Cirno, RS_CH_Cactus.
//
// RESOLVED 2026-08-06 -- MISL frame E -> MISL D, six sites (RS_GrayCGuff
// Melee, RS_DetoPuff2 Melee, RS_DetoPuff3 Melee, RS_YellowBombCGUYEX Death
// x3; CH Chaingunners.txt:764, :1855, :1868, :3012-3014). Vanilla MISL is
// MISLA1/A5/A6A4/A7A3/A8A2/B0/C0/D0 -- eight lumps, frames A-D -- identical
// in doom.wad and doom2.wad, and CH ships no MISL lump of its own beyond
// its three custom MISLX0/Y0/Z0. Frame E therefore rendered nothing in CH
// too. D is the last frame of the vanilla rocket explosion (B->C->D), so
// each E now holds D for exactly E's tics; every tic count and every action
// call is unchanged. The YellowBombCGUYEX site mattered most -- it was four
// visible tics of an on-screen death burst showing nothing.
// Still open elsewhere (not this lane's files): the same MISL E sits at
// RS_ShotgunnerFX.zs:244 (RS_DetoPuffCG -- the BASE class of the two
// RS_DetoPuff* fixed here) and :702 (RS_DetoPuffCG2), and at
// RS_PainElementalFX.zs:1183.
//
// Dangling / silent by design, verbatim from CH:
//   * "LewdLabCoat" (WhiteCguy2 drop) is defined nowhere in CH -- silent
//     no-op drop there too.
//   * BlackCGuyEX's SparkPuff1 A_CustomMissile calls pass CMF_AIMOFFSET in
//     the ANGLE slot and random(0,360) as FLAGS -- CH's own arg-order bug,
//     kept verbatim; it compiles and only affects a cosmetic puff.
// ============================================================================

// ---------------------------------------------------------------------------
// Drop gates this family adds.  CH: DECORATE.txt:456 / 502 / 548.
// ---------------------------------------------------------------------------
class RS_CH_BlueArmor : RS_DropBaseArmor   // CH DECORATE.txt:456
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("BlueArmor",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("BlueArmor",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_Chainsaw : RS_DropBaseWeapon   // CH DECORATE.txt:502
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("ChainSaw",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("ChainSaw",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_BFG9000 : RS_DropBaseWeapon   // CH DECORATE.txt:548
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("BFG9000",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("BFG9000",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// External FX pulled from other CH family files.
// ---------------------------------------------------------------------------
class RS_Trail11 : Actor   // CH Revenants.txt:1624 -- green's bullet trail puff
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.5;
		Alpha 0.6;
		Translation "168:255=112:127";
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

class RS_Trail12 : Actor   // CH Revenants.txt:1677
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.5;
		Alpha 0.5;
	}
	States
	{
	Spawn:
		BAL7 CDE 6 Bright;
		Stop;
	}
}

class RS_Trail14 : Actor   // CH Chaingunners.txt:2805
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Scale 0.3;
		Alpha 0.5;
	}
	States
	{
	Spawn:
		BAL7 CDE 4 Bright;
		Stop;
	}
}

class RS_PuffCybieRed : Actor   // CH CYBIES.txt:3988
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
	}
	States
	{
	Spawn:
		SMK2 ABCDE 2;
		Stop;
	}
}

class RS_SpiralSaw5 : Actor   // CH CYBIES.txt:3589
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		+NOCLIP
		+NOGRAVITY
		Speed 1;
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.55;
	}
	States
	{
	Spawn:
		SPIR EDCBA 3 Bright A_Explode(random(2,10),88);
		Stop;
	}
}

class RS_GroundRedCyb : Actor   // CH CYBIES.txt:3637
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 1;
		Mass 25;
		Projectile;
		+FLOORHUGGER
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		BounceCount 999;
		BounceType "Doom";
		DamageType "Fire";
		BounceFactor 1;
		WallBounceFactor 1.5;
		RenderStyle "Add";
		SeeSound "Fire/fire3";
		Alpha 0.95;
		YScale 0.3;
		XScale 0.75;
	}
	States
	{
	Spawn:
		RED8 ABCFGH 3 Bright A_Explode(random(2,10),128);
		RED8 D 1 Bright;
		Stop;
	}
}

class RS_RedRevLoad : Actor   // CH Revenants.txt:2898 -- the charge-up flare
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
		SPIR ABCDE 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The family's own projectiles.  CH: Chaingunners.txt.
// ---------------------------------------------------------------------------
class RS_BrownSandBagCGuy : Actor   // CH Chaingunners.txt:162 -- deployable cover
{
	Default
	{
		Radius 42;
		Height 24;
		Speed 3;
		Species "BrownCguy";
		Health 80;
		Monster;
		+NOTRIGGER
		+NOTARGET
		+DONTTHRUST
		+NOBLOOD
		+FLOORCLIP
		-COUNTKILL
		+THRUSPECIES
		+THRUACTORS
		Gravity 1;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		SB4G X 3 Bright A_SetScale(0.3,0.3);
		SB4G X 3 Bright A_SetScale(0.4,0.5);
		SB4G X 3 Bright A_SetScale(0.7,0.8);
		SB4G X 3 Bright A_SetScale(1.0,1.0);
		SB4G XX 1 A_Wander;
		TNT1 A 0 { bTHRUACTORS = false; }
	Flier:
		SB4G X 3 Bright;
		SB4G X 300 Bright;
		Goto Death;
	Death:
		SB4G X 2 Bright A_NoBlocking;
		SB4G X 2 Bright A_SetScale(0.7,0.7);
		SB4G X 2 Bright A_SetScale(0.5,0.5);
		SB4G X 2 Bright A_SetScale(0.2,0.1);
		Stop;
	}
}

class RS_BrownOrbCguy : Actor   // CH Chaingunners.txt:204
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 32;
		Mass 10;
		DamageFunction (random(3,9));
		Gravity 0.05;
		Projectile;
		DamageType "Fire";
		-NOGRAVITY
		+MTHRUSPECIES
		+THRUGHOST
		SeeSound "fire/fire3";
		DeathSound "weapons/boom1";
		Translation "0:255=@74[77,52,26]";
		Scale 0.33;
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Loop;
	Death:
		RIP1 D 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_SetTranslation("BBEASTEX5");
		RIP1 DEFGH 3 Bright A_Explode(random(1,5),32);
		Stop;
	}
}

class RS_SplashAbyssCguy : Actor   // CH Chaingunners.txt:553 -- the abyss vile-blast
{
	Default
	{
		Radius 6;
		Height 16;
		DamageFunction (random(1,9));
		DamageType "Ice";
		Speed 16;
		FastSpeed 23;
		Projectile;
		+THRUACTORS
		+FLOATBOB
		+FORCERADIUSDMG
		Scale 0.3;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		BAL7 C 1 Bright A_SetScale(0.5);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(1,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		TNT1 A 0 ThrustThingZ(0,random(1,33),0,0);
		TNT1 A 0 A_Explode(random(2,12),32);
		BAL7 CDE 3 Bright;
		Stop;
	}
}

class RS_GrayCGuff : Actor   // CH Chaingunners.txt:742 -- gray's exploding puff
{
	Default
	{
		+NOGRAVITY
		+ALLOWPARTICLES
		+PUFFONACTORS
		Projectile;
		RenderStyle "Add";
		Alpha 0.85;
		VSpeed 1;
		Scale 0.25;
		DamageType "Fire";
		SeeSound "weapons/firex4";
		Mass 5;
		Translation "0:249=%[0.00,0.00,0.00]:[2.00,2.00,2.00]","128:143=80:95","144:151=87:95","13:15=93:95","96:111=80:95","236:239=95:95","152:159=80:89","5:12=85:95","0:2=92:95","168:191=0:2","192:207=0:0","32:47=0:0";
	}
	States
	{
	Spawn:
		MISL BC 2 Bright;
	Melee:
		MISL D 4 Bright A_Explode(random(1,12),64);
		MISL D 1 Bright A_SpawnItemEx("RS_CGthing3",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		MISL D 4 Bright;   // CH: MISL E -- vanilla MISL ends at D in both IWADs (checked doom.wad and doom2.wad lump directories: MISLA*,B0,C0,D0 only) and CH ships no MISL lump, so CH's own frame renders nothing; held D, the last explosion frame, for E's 4 tics. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_CGthing3 : Actor   // CH Chaingunners.txt:769 -- the nail ring
{
	Default
	{
		Speed 0;
		Height 1;
		Radius 1;
		Projectile;
		+NOCLIP
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
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

class RS_CGNail : Actor   // CH Chaingunners.txt:798
{
	Default
	{
		Radius 2;
		Height 2;
		DamageFunction (random(1,5));
		DamageType "Melee";
		Speed 45;
		Scale 0.5;
		Decal "BulletChip";
		AttackSound "moloch/nailhitbleed";
		DeathSound "weapons/firex4";
		Projectile;
		+SPAWNSOUNDSOURCE
		+EXTREMEDEATH
		+BLOODSPLATTER
	}
	States
	{
	Spawn:
		BLAD A 2 Bright;
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(1,3),16);
		FBL1 EFG 1 Bright A_Explode(random(1,3),16);
		FBL1 G 1 Bright A_SpawnItemEx("RS_PuffCybieRed",0,0,2);
		Stop;
	}
}

class RS_FireBCGguy : Actor   // CH Chaingunners.txt:963
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 45;
		FastSpeed 26;
		DamageFunction (random(5,20));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.65;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200","160:160=177:177","162:162=184:184","163:163=204:204","164:164=186:186","165:165=204:204","166:166=189:189","167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 4 Bright;
		Goto Fly;
	Fly:
		FIRE CDEEDCDE 3 A_Explode(random(4,15),64);
		Loop;
	Death:
		FIRE FGH 6 Bright A_Explode(random(5,15),64);
		Stop;
	}
}

class RS_BlueChainPuff2 : Actor   // CH Chaingunners.txt:1300
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 2;
		Projectile;
		+NOINTERACTION
		+ALWAYSPUFF
		RenderStyle "Add";
		Alpha 0.73;
		Scale 0.25;
	}
	States
	{
	Spawn:
		SSBL KIJ 1 Bright;
		Goto Death;
	Death:
		SSBL KIJ 1 Bright;
		Stop;
	}
}

class RS_BlueChainPuff3 : Actor   // CH Chaingunners.txt:1323
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 1;
		Projectile;
		+NOINTERACTION
		RenderStyle "Add";
		Alpha 0.73;
		Scale 0.55;
		SeeSound "prox/beep";
	}
	States
	{
	Spawn:
		SSBL KIJ 1 Bright;
		SSBL I 1 Bright A_PlaySound("prox/beep");
		SSBL J 1 Bright A_SetScale(0.3,0.3);
		Goto Death;
	Death:
		SSBL KJI 1 Bright;
		Stop;
	}
}

class RS_Boomer1 : Actor   // CH Chaingunners.txt:1461
{
	Default
	{
		Radius 3;
		Height 2;
		Speed 68;
		DamageFunction (random(1,8));
		DamageType "Fire";
		Projectile;
		+DEHEXPLOSION
		+SEEKERMISSILE
		SeeSound "SNPRFIRE";
		DeathSound "weapons/firex4";
		Scale 0.15;
	}
	States
	{
	Spawn:
		MISL A 1 Bright A_SeekerMissile(8,8);
		Loop;
	Death:
		MISL B 8 Bright A_Explode(random(1,8),46);
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	}
}

class RS_Boomer2 : RS_Boomer1   // CH Chaingunners.txt:1488
{
	Default
	{
		DamageFunction (random(1,7));
	}
	States
	{
	Spawn:
		MISL A 1 Bright A_SeekerMissile(4,4);
		Loop;
	}
}

class RS_Boomer3 : RS_Boomer1   // CH Chaingunners.txt:1499
{
	Default
	{
		-SEEKERMISSILE
		DamageFunction (random(1,6));
	}
	States
	{
	Spawn:
		MISL A 1 Bright A_SeekerMissile(7,7);
		Loop;
	}
}

class RS_CGRailBuff : Actor   // CH Chaingunners.txt:1677
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 14;
		FastSpeed 26;
		DamageFunction (random(1,3));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		Scale 0.33;
		RenderStyle "Add";
		Alpha 0.85;
		Translation "168:191=193:205","208:223=192:197","160:167=4:4","224:231=4:4","232:235=199:199","248:249=193:193","0:0=0:0";
	}
	States
	{
	Spawn:
		BAL1 AB 3 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_SetScale(0.22,0.22);
		BAL1 A 3 Bright A_Explode(random(1,2),24);
		TNT1 A 0 A_SetScale(0.11,0.11);
		BAL1 B 3 Bright A_Explode(random(1,2),24);
		Stop;
	}
}

class RS_DetoPuff2 : RS_DetoPuffCG   // CH Chaingunners.txt:1847
{
	States
	{
	Spawn:
		MISL BC 4 Bright A_SetScale(0.28);
	Melee:
		MISL D 4 Bright A_Explode(random(1,4),38);
		MISL D 4 Bright;   // CH: MISL E -- frame absent from both IWADs and from CH; held D for E's 4 tics. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_DetoPuff3 : RS_DetoPuffCG   // CH Chaingunners.txt:1860
{
	States
	{
	Spawn:
		MISL BC 4 Bright A_SetScale(0.2);
	Melee:
		MISL D 4 Bright A_Explode(random(1,3),32);
		MISL D 4 Bright;   // CH: MISL E -- frame absent from both IWADs and from CH; held D for E's 4 tics. Fixed 2026-08-06 (owner: nothing invisible).
		Stop;
	}
}

class RS_YellowBombCGUYEX : Actor   // CH Chaingunners.txt:2050
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 38;
		DamageFunction (random(20,80));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 1;
		Scale 1.25;
		SeeSound "spit/spit";
		DeathSound "spit/spit2";
		Translation "0:255=%[1.29,0.65,0.00]:[2.00,2.00,1.01]";
	}
	States
	{
	Spawn:
		GBLL ABC 6 Bright;
	Fly:
		GBLL ABC 6 Bright;
		TNT1 A 0 { bNOGRAVITY = false; }
		GBLL ABC 6 Bright;
		Loop;
	Death:
		GBLL A 6 Bright A_SetScale(1.0,1.0);
		GBLL B 6 Bright A_SetScale(0.75,0.75);
		GBLL C 6 Bright A_SetScale(0.5,0.5);
		GBLL A 6 Bright A_SetScale(0.25,0.25);
		GBLL BC 6 Bright;
		GBLL ABC 6 Bright;
		TNT1 A 0 A_PlaySound("spell/Impact1",0);
		BBOM A 2 Bright A_SetScale(0.5,0.5);
		TNT1 A 0 A_Explode(random(10,20),32,0);
		BBOM B 2 Bright A_SetScale(0.75,0.75);
		TNT1 A 0 A_Explode(random(10,30),64,0);
		BBOM C 2 Bright A_SetScale(1.25,1.25);
		TNT1 A 0 A_Explode(random(20,60),74,0);
		BBOM C 2 Bright A_SetScale(2.0,2.0);
		TNT1 A 0 A_Explode(random(20,80),128,0);
		BBOM C 2 Bright A_SetScale(2.5,2.5);
		TNT1 A 0 A_PlaySound("Bomb/boom",0);
		TNT1 A 0 A_Explode(random(30,90),176,0);
		BBOM C 2 Bright A_SetScale(3.0,3.0);
		TNT1 A 0 A_Explode(random(30,90),256,0);
		BBOM C 2 Bright A_SetScale(3.5,3.5);
		TNT1 A 0 A_Explode(random(30,90),256,0);
		BBOM C 2 Bright A_SetScale(4.0,4.0);
		TNT1 A 0 A_Explode(random(30,90),312,0);
		BBOM CCCBA 4 Bright A_FadeOut(0.20);
		Stop;
	}
}

class RS_SpamShotsCguyEX : Actor   // CH Chaingunners.txt:2106
{
	Default
	{
		Radius 12;
		Height 9;
		Speed 28;
		DamageFunction (random(10,120));
		DamageType "Plasma";
		Projectile;
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 0.95;
		Scale 0.25;
		SeeSound "weapons/bfgf";
		DeathSound "weapons/bfgx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		GRFZ DEFGH 2 Bright A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		Loop;
	Death:
		GRFZ IJ 4 Bright A_SetScale(1.0,1.0);
		GRFZ K 4 Bright A_Explode(random(22,88),256,0);
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ LMN 3 Bright A_SpawnItemEx("RS_EXPLOSIONSCGuyEX",random(-64,64),random(-64,64),random(-32,32),0,0,0,random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEX",random(-128,128),random(-128,128),random(-32,32),0,0,0,random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ OP 4 Bright A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-32,32),random(-32,32),random(-64,128),random(12,99),0,random(-25,25),random(0,359),SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_SpamShotsCguyEX2 : RS_SpamShotsCguyEX   // CH Chaingunners.txt:2140
{
	Default { DamageType "Fire"; }
}

class RS_CGBigEx : Actor   // CH Chaingunners.txt:2142
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 21;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(30,80));
		DamageType "Plasma";
		Alpha 0.75;
		Scale 0.75;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		RED9 B 1 Bright A_SeekerMissile(2,4);
		RED9 AA 1 Bright A_SpawnItemEx("RS_SpiralSaw5",0,0,0,0,0,0,0,128);
		RED9 A 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEX",random(-128,24),random(-64,64),random(-32,32),1,0,random(-1,1),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(1.5);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(5,30),164);
		SPIR E 1 Bright A_SetScale(3.0);
		GRFZ IJ 4 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-24,68),random(12,99),0,random(-25,25),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-14,28),random(12,99),0,random(-25,25),random(180,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-4,28),random(12,99),0,random(-25,25),random(0,180),SXF_NOCHECKPOSITION);
		GRFZ K 4 Bright A_Explode(random(55,111),386,0);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-6,28),random(12,99),0,random(-25,25),random(180,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-4,28),random(12,99),0,random(-25,25),random(0,180),SXF_NOCHECKPOSITION);
		GRFZ LMN 3 Bright A_SpawnItemEx("RS_EXPLOSIONSCGuyEX",random(-64,64),random(-64,64),random(-32,32),0,0,0,random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-4,28),random(12,99),0,random(-25,25),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-4,28),random(12,99),0,random(-25,25),random(180,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_EXPLOSIONSCGuyEXDelayd",random(-12,12),random(-12,12),random(-64,128),random(12,99),0,random(-25,25),random(0,180),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Explode(random(66,128),386,0);
		GRFZ OP 4 Bright A_SpawnItemEx("RS_EXPLOSIONSCGuyEX",random(-64,64),random(-124,124),random(-32,32),0,0,0,random(0,359),SXF_NOCHECKPOSITION);
		GRFZ III 2 A_FadeOut(0.20);
		Stop;
	}
}

class RS_EXPLOSIONSCGuyEX : Actor   // CH Chaingunners.txt:2186
{
	Default
	{
		Radius 12;
		Height 9;
		Speed 28;
		DamageFunction (random(20,60));
		DamageType "Fire";
		Projectile;
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 0.95;
		Scale 0.42;
		SeeSound "weapons/bfgf";
		DeathSound "weapons/bfgx";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		GRFZ IJ 3 Bright;
		GRFZ K 3 Bright A_Explode(random(11,77),128,0);
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ LMN 2 Bright;
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ OP 3 Bright;
		Stop;
	}
}

class RS_EXPLOSIONSCGuyEXDelayd : Actor   // CH Chaingunners.txt:2216
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 50;
		DamageFunction (random(20,60));
		DamageType "Fire";
		Projectile;
		+DONTHARMCLASS
		RenderStyle "Add";
		Alpha 0.95;
		Scale 0.42;
		SeeSound "weapons/bfgf";
		DeathSound "weapons/bfgx";
	}
	States
	{
	Spawn:
		TNT1 A 11;
	Death:
		TNT1 A 0 A_Stop;
		GRFZ IJ 3 Bright;
		GRFZ K 3 Bright A_Explode(random(11,77),128,0);
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ LMN 2 Bright;
		TNT1 AAAAAAAAAA 0 A_SpawnParticle("red",SPF_FULLBRIGHT|SPF_RELATIVE,random(12,48),random(10,25),frandom(0,360),0,0,1,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		GRFZ OP 3 Bright;
		Stop;
	}
}

class RS_SpiralLoadGeneEX : Actor   // CH Chaingunners.txt:2247
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
		Alpha 0.95;
		Scale 1;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Death:
		GRFZ CBA 4 Bright;
		TNT1 A 0 A_SetScale(0.75,0.75);
		GRFZ BA 4 Bright;
		TNT1 A 0 A_SetScale(0.5,0.5);
		GRFZ BA 4 Bright;
		TNT1 A 0 A_SetScale(0.25,0.25);
		GRFZ BA 4 Bright;
		GRFZ I 1 Bright;
		TNT1 A 0 A_SetScale(0.5,0.5);
		GRFZ I 1 Bright;
		TNT1 A 0 A_SetScale(0.75,0.75);
		GRFZ I 1 Bright;
		Stop;
	}
}

class RS_CGBigOne : Actor   // CH Chaingunners.txt:2389
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 19;
		Projectile;
		+NOGRAVITY
		+SEEKERMISSILE
		RenderStyle "Add";
		DamageFunction (random(30,80));
		DamageType "Plasma";
		Alpha 0.75;
		SeeSound "Spell/SpellCast1";
		DeathSound "Fire/Fire4";
	}
	States
	{
	Spawn:
		RED9 B 1 Bright A_SeekerMissile(3,6);
		RED9 AA 1 Bright A_SpawnItemEx("RS_SpiralSaw5",0,0,0,0,0,0,0,128);
		RED9 A 0 A_CustomMissile("RS_GroundRedCyb",0,0);
		Loop;
	Death:
		SPIR A 1 Bright A_SetScale(2);
		SPIR ABCDEDCBA 5 Bright A_Explode(random(5,30),164);
		SPIR E 1;
		Stop;
	}
}

class RS_GenShield : Actor   // CH Chaingunners.txt:2442
{
	Default
	{
		Radius 20;
		Height 20;
		Speed 1;
		Damage 0;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 1.5;
		DropItem "Cell";
	}
	States
	{
	Spawn:
		BFS1 ABA 15 Bright;
		Goto Death;
	Death:
		BFE1 A 8 Bright A_SetScale(1.15);
		BFE1 B 8 Bright A_SetScale(0.8);
		BFE1 C 8 Bright A_SetScale(0.6);
		BFE1 C 0 A_NoBlocking;
		BFE1 DEF 8 Bright A_CustomMissile("RS_TrailSPCguy",random(-2,2),random(-2,2),random(-4,4),CMF_AIMDIRECTION|CMF_SAVEPITCH);
		Stop;
	}
}

class RS_SpamShotsCguy : Actor   // CH Chaingunners.txt:2472
{
	Default
	{
		Radius 14;
		Height 9;
		Speed 25;
		DamageFunction (random(10,60));
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		+SEEKERMISSILE
		RenderStyle "Add";
		Alpha 0.75;
		Scale 0.55;
		SeeSound "weapons/bfgf";
		DeathSound "weapons/bfgx";
	}
	States
	{
	Spawn:
		BFS1 AB 2 Bright;
		Loop;
	Death:
		BFE1 AB 8 Bright A_SetScale(1.15);
		BFE1 C 8 Bright A_Explode(random(5,45),128);
		BFE1 DEF 8 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The scientist's toys.  CH: Chaingunners.txt:2707-3169.
// ---------------------------------------------------------------------------
class RS_Puddle2 : Actor   // CH Chaingunners.txt:2707 -- wandering slime pool
{
	Default
	{
		Radius 12;
		Height 3;
		Speed 12;
		Damage 4;
		PoisonDamage 15;
		PoisonDamageType "Poison";
		Species "Science";
		DeathSound "slimeball/splat";
		XScale 1.1;
		YScale 0.3;
		+FLOORHUGGER
		+DONTHARMCLASS
		+DONTHARMSPECIES
		+THRUACTORS
		+RANDOMIZE
		+BOUNCEONWALLS
		BounceCount 999;
		BounceType "Doom";
		BounceFactor 1;
		WallBounceFactor 1.5;
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		BOGY ABC 2 Bright A_CustomMissile("RS_SlimeBall4",random(5,15),random(-8,8),random(-180,180),2,random(10,60));
		BOGY A 0 A_Jump(16,"Death");
		BOGY ABC 2 Bright A_Wander;
		Loop;
	Death:
		BOGY D 0 A_NoGravity;
		BOGY DEF 4 Bright;
		Stop;
	}
}

class RS_Puddle1 : Actor   // CH Chaingunners.txt:2745
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 14;
		Damage 4;
		PoisonDamage 15;
		PoisonDamageType "Poison";
		DeathSound "slimeball/splat";
		Scale 0.5;
		Projectile;
		-NOGRAVITY
		Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
		BOGY ABC 2 Bright;
		Loop;
	Death:
		BOGY D 0 A_NoGravity;
		BOGY DEF 4 Bright A_CustomMissile("RS_Puddle2",random(2,16),random(-16,16),random(-20,20),CMF_SAVEPITCH,random(5,15));
		BOGY F 1;
		Stop;
	}
}

class RS_NeedlesCg2 : Actor   // CH Chaingunners.txt:2772
{
	Default
	{
		Radius 6;
		Height 5;
		DamageFunction (random(5,45));
		DamageType "Poison";
		PoisonDamage 15;
		PoisonDamageType "Poison";
		Speed 25;
		YScale 0.75;
		XScale 1.55;
		Decal "BulletChip";
		SeeSound "Jam/Jamd";
		AttackSound "moloch/nailhitbleed";
		DeathSound "gas/gas1";
		Projectile;
		+SPAWNSOUNDSOURCE
		+BLOODSPLATTER
	}
	States
	{
	Spawn:
		BLAD A 1 Bright A_SpawnItemEx("RS_Trail14",0,0,2);
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,8),64);
		FBL1 GGG 0 A_SpawnItemEx("RS_Trail14",random(-8,8),random(-8,8),random(-8,8));
		FBL1 EFG 1 Bright A_Explode(random(2,12),64);
		FBL1 GGG 0 A_SpawnItemEx("RS_Trail12",random(-8,8),random(-8,8),random(-8,8));
		Stop;
	}
}

class RS_NeedlesCg1 : Actor   // CH Chaingunners.txt:2825
{
	Default
	{
		Radius 5;
		Height 4;
		DamageFunction (random(5,25));
		DamageType "Melee";
		Speed 35;
		YScale 0.6;
		XScale 1.4;
		Decal "BulletChip";
		SeeSound "Jam/Jamd";
		AttackSound "moloch/nailhitbleed";
		DeathSound "gas/gas1";
		Projectile;
		+SPAWNSOUNDSOURCE
		+BLOODSPLATTER
	}
	States
	{
	Spawn:
		BLAD A 1 Bright;
		Loop;
	Death:
		6PUF A 0 A_PlaySound("moloch/nailhit");
		6PUF ABCDEF 1 Bright A_Explode(random(2,5),64);
		FBL1 EFG 1 Bright A_Explode(random(2,8),64);
		FBL1 G 1 Bright A_SpawnItemEx("RS_Trail12",0,0,1);
		Stop;
	}
}

class RS_SlimeBall1 : DoomImpBall   // CH Chaingunners.txt:2927
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 14;
		Damage 4;
		PoisonDamage 15;
		PoisonDamageType "Poison";
		DeathSound "slimeball/splat";
		Scale 0.5;
		-NOGRAVITY
		Decal "PlasmaScorchLower";
	}
	States
	{
	Spawn:
		BOGY ABC 2 Bright;
		Loop;
	Death:
		BOGY D 0 A_NoGravity;
		BOGY DEF 4 Bright;
		Stop;
	}
}

class RS_SlimeBall2 : RS_SlimeBall1 { Default { Speed 16; } }   // CH Chaingunners.txt:2952
class RS_SlimeBall3 : RS_SlimeBall1 { Default { Speed 18; } }
class RS_SlimeBall4 : RS_SlimeBall1 { Default { Speed 20; } }
class RS_SlimeBall5 : RS_SlimeBall1 { Default { Speed 22; } }

class RS_BabyCacoBall : Actor   // CH Chaingunners.txt:3146
{
	Default
	{
		Radius 3;
		Height 4;
		Speed 11;
		FastSpeed 10;
		Damage 3;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 1;
		SeeSound "caco/attack";
		DeathSound "caco/shotx";
		Decal "HImpScorch";
	}
	States
	{
	Spawn:
		BCAB AB 4 Bright;
		Loop;
	Death:
		BCAB CDE 6 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// The scientist's minions.  CH: Chaingunners.txt:2855-3144.  No tier tokens
// (summons, like MrBones / RS_BlackSG2).
// ---------------------------------------------------------------------------
class RS_SlimyWorm : Actor   // CH Chaingunners.txt:2855
{
	Default
	{
		Obituary "%o got melted up good by slimy minion worm";
		HitObituary "%o was digested by a slimy minion worm.";
		Health 250;
		PainChance 90;
		Speed 8;
		Radius 30;
		Height 56;
		Mass 400;
		Species "Science";
		SeeSound "slimeworm/sight";
		AttackSound "slimeworm/melee";
		PainSound "slimeworm/pain";
		DeathSound "slimeworm/death";
		ActiveSound "slimeworm/active";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		BloodColor "Yellow";
		Monster;
		+THRUSPECIES
		+FLOORCLIP
		+MISSILEMORE
		+SHORTMISSILERANGE
		+NOCLIP
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 174;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		Tag "Worm minion";
	}
	States
	{
	Spawn:
		WORM AB 10 A_Look;
		Loop;
	See:
		WORM AABBCCDD 3 A_Chase;
		WORM A 0 { bNOCLIP = false; }
		Loop;
	Missile:
		WORM E 8 A_FaceTarget;
		WORM F 8 A_PlaySound("SlimeBall/Shoot");
		WORM F 0 A_CustomMissile("RS_SlimeBall1",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall2",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall3",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall4",40,0,random(-10,10),2,random(10,20));
		WORM F 0 A_CustomMissile("RS_SlimeBall5",40,0,random(-10,10),2,random(10,20));
		WORM G 8;
		Goto See;
	Melee:
		WORM EF 8 A_FaceTarget;
		WORM G 8 A_SargAttack;
		Goto See;
	Pain:
		WORM H 2;
		WORM H 2 A_Pain;
		Goto See;
	Death:
		WORM I 8;
		WORM J 8 A_Scream;
		WORM K 4;
		WORM L 4 A_NoBlocking;
		WORM M 4;
		WORM N -1;
		Stop;
	Raise:
		WORM NMLKJI 5;
		Goto See;
	}
}

class RS_VolativeCaco : Actor   // CH Chaingunners.txt:2957 -- walking bomb
{
	Default
	{
		Health 100;
		GibHealth 65;
		BloodColor "Blue";
		Species "Science";
		Radius 31;
		Height 56;
		Mass 500;
		Speed 11;
		PainChance 90;
		Monster;
		+MISSILEMORE
		+MISSILEEVENMORE
		+TOUCHY
		+LOOKALLAROUND
		+FLOAT
		+NOGRAVITY
		+DONTHARMSPECIES
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "weapons/rocklx";
		ActiveSound "caco/active";
		Obituary "%o stood to close to the unstable cacodemon";
		Scale 1.1;
		XScale 1.3;
		Tag "Unstable cacodemon";
	}
	States
	{
	Spawn:
		HEAD A 10 A_Look;
		Loop;
	See:
		HEAD A 1 A_Chase;
		HEAD A 1 A_SetScale(1.4,1.3);
		HEAD A 1 A_Chase;
		HEAD A 1 A_SetScale(1.5,1.4);
		HEAD A 1 A_Chase;
		HEAD A 1 A_SetScale(1.4,1.3);
		HEAD A 1 A_Chase;
		HEAD A 1 A_SetScale(1.3,1.2);
		Loop;
	Melee:
		HEAD BC 4;
		Goto Death;
	Pain:
		HEAD E 3;
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Death:
		HEAD D 8;
		HEAD D 1 A_Scream;
		MISL CD 6 A_Explode(random(20,60),128);
		MISL D 1 A_DualPainAttack("RS_BabyCaco");   // CH: MISL E -- frame absent from both IWADs and from CH, so this whole 4-tic death burst rendered nothing; held D, the last explosion frame. Fixed 2026-08-06 (owner: nothing invisible).
		MISL D 2 A_PainAttack("RS_BabyCaco");       // CH: MISL E -- same, see above.
		MISL D 1 A_DualPainAttack("RS_BabyCaco");   // CH: MISL E -- same, see above.
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_SpliceBaron : Actor   // CH Chaingunners.txt:3020
{
	Default
	{
		Health 1000;
		DamageFactor "Plasma", 1.2;
		DamageFactor "Fire", 1.1;
		PainChance "DIMp", 0;
		Species "Science";
		Radius 64;
		Height 70;
		Speed 12;
		PainChance 0;
		Mass 1000;
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "arachnobaron/death";
		ActiveSound "baby/active";
		BloodColor "Green";
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		Monster;
		+FLOORCLIP
		+THRUSPECIES
		+DONTHARMSPECIES
		+MISSILEMORE
		+MISSILEEVENMORE
		+DONTMORPH
		+NOCLIP
		Obituary "what has science done; %o was killed by a horrible abomination";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_Medikit", 174;
		Tag "Splice hell";
	}
	States
	{
	Spawn:
		ARBR AB 10 A_Look;
		Loop;
	See:
		ARBR A 3 A_BabyMetal;
		ARBR ABBCC 3 A_Chase;
		ARBR A 0 { bNOCLIP = false; }
		ARBR D 3 A_BabyMetal;
		ARBR DEEFF 3 A_Chase;
		Goto See;
	Missile:
		ARBR A 1 Bright A_Jump(127,"Missile2");
		ARBR A 20 Bright A_FaceTarget;
		ARBR G 3 Bright A_CustomMissile("ArachnotronPlasma",15,0,0);
		ARBR H 2 Bright;
		ARBR H 1 Bright A_SpidRefire;
		Goto Missile+2;
	Missile2:
		ARBR P 2 Bright A_FaceTarget;
		ARBR P 5 Bright A_CustomMissile("BaronBall",30,0,5);
		ARBR Q 5 Bright A_CustomMissile("BaronBall",30,0,0);
		ARBR R 5 Bright A_CustomMissile("BaronBall",30,0,-5);
		Goto See+1;
	Death:
		ARBR J 20 A_Scream;
		ARBR K 7 A_NoBlocking;
		ARBR LMNO 7;
		ARBR O -1 A_BossDeath;
		Stop;
	}
}

class RS_BabyCaco : Cacodemon   // CH Chaingunners.txt:3085
{
	Default
	{
		Health 125;
		Radius 18;
		Height 36;
		Mass 200;
		Speed 11;
		PainChance 176;
		SeeSound "BabyCaco/Sight";
		PainSound "BabyCaco/Pain";
		DeathSound "BabyCaco/Death";
		ActiveSound "BabyCaco/Active";
		BloodColor "Blue";
		DamageFactor "Antiair", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Obituary "%o underestimated a Baby Cacodemon.";
		HitObituary "%o was nibbled to death by a Baby Cacodemon.";
		Monster;
		+NOGRAVITY
		+THRUSPECIES
		+FLOAT
		Scale 0.9;
		DropItem "RS_CH_Shell", 128;
		DropItem "RS_implyingclip", 174;
		DropItem "RS_CH_RocketAmmo", 64;
		DropItem "RS_CH_Cell", 32;
		Tag "smol babby caco";
	}
	States
	{
	Spawn:
		CACB A 10 A_Look;
		Loop;
	See:
		CACB A 3 A_Chase;
		Loop;
	Melee:
	Missile:
		CACB AB 5 A_FaceTarget;
		CACB C 5 Bright A_CustomComboAttack("RS_BabyCacoBall",17,random(1,8) * 3,"BabyCaco/Melee");
		Goto See;
	Pain:
		CACB D 3;
		CACB D 3 A_Pain;
		CACB E 6;
		Goto See;
	Death:
		CACB F 8;
		CACB G 8 A_Scream;
		CACB HI 8;
		CACB J 8 A_NoBlocking;
		CACB K 8;
		CACB L -1 A_SetFloorClip;
		Stop;
	Raise:
		CACB L 8 A_UnSetFloorClip;
		CACB KJIHGF 8;
		Goto See;
	}
}
