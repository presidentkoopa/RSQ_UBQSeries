// ============================================================================
// RS_DemonFX.zs -- Colourful Hell Demon (Pinky) family: support actors,
// projectiles, and third-file externals. 2026-08-05.
// Source of truth: C:\Users\Command\Desktop\CH\decorate\Demons.txt (2654
// lines, read whole). Externals chased to their defining CH file:line.
// Bodies live in RS_Demon.zs.
//
// Shared classes referenced READ-ONLY (defined by earlier families, never
// redefined here): RS_Zom, RS_ZomTierToken, RS_GrowRaisin, RS_CHBoner,
// RS_ThePlanBoner, RS_ColorTierIconCH..CH13, RS_HealthBundle, RS_ArmorBundle,
// RS_BackPackBundle, RS_implyingclip, RS_CH_Berserk, RS_CH_Chainsaw,
// RS_CH_Medikit, RS_CH_MegaSphere, RS_CH_Shell, RS_CH_ShellBox, RS_CH_Cell,
// RS_CH_RocketAmmo, RS_CH_BlueArmor, RS_CH_Cirno, RS_SplashAbyss,
// RS_SplashAbyss2, RS_AbyssShotIdentifier, RS_FireSGguy2, RS_BrownImpCommand,
// RS_EffectHK, RS_Gas14, RS_Drt1, RS_Drt2, RS_Drt3.
//
// CROSS-LANE (parallel spectre import, lands with this one):
//   * RS_RedDemonBloodBolt3 -- CH defines it in spectres.txt:1031, but
//     Demons.txt:238 (ChainFlame2) fires it too, so it lives HERE per the
//     demons-owns-shared rule. The spectre lane references it read-only.
//   * Exported the other way (spectres.txt references, we define):
//     RS_AbyssDemon2, RS_FireBluDemon2 (spectres.txt:322 inherits it),
//     RS_BloodDemonArm (spectres.txt:921), RS_BloodDemonArm2 (:1018).
//
// PROVEN MISSING IN CH ITSELF (verbatim silence kept, no substitution):
//   * Sprite SPRY (frames A-G, RS_RedDemonBloodBolt2 and 3): no SPRY* lump
//     in Desktop\CH\sprites, E:\New folder\ART SOURCE\CH\sprites, CHP's
//     sprites, or the lump directory of doom.wad or doom2.wad. Those frames
//     render nothing in CH too.
//     Re-investigated 2026-08-06 and DECLINED -- no substitute is provable:
//       - CHP re-authors this actor from scratch (DECORATE\07\07_R.txt:1819
//         RedDemonBloodBolt3_C, reparented to FastProjectile) and RETYPES
//         "SPRY ABCDEF 4 / SPRY G 3" verbatim while shipping no SPRY lump.
//         The layer that wins never resolved it, so there is no corrected
//         upstream copy to read the intent from.
//       - No CH or CHP prefix is edit-distance 1 from SPRY. The only two in
//         the whole corpus, SPGY and SPCY, are CHP Spider Mastermind BODY
//         sheets (8 rotations, 15-19 frames; ours under
//         sprites/monsters/Mastermind/T09 and /T03) -- a boss walk cycle on
//         a droplet, excluded outright.
//       - CH ships 11 prefixes with exactly A-G rot-0-only; none is gore and
//         none lives in demon/, fx/ or nashgore/. The only A-G prefix CH
//         references nowhere is TRPS, viewed frame-by-frame: a ~100px green
//         pain-elemental gas cloud, not a droplet.
//       - CH's other blood bolts (RedDemonBloodBolt1 Demons.txt:1705,
//         BloodBoltHK Hellknights.txt:2060, RedThingsHK :2107) all draw BAL1.
//     Leave it silent. A wrong sprite here is a visible bug on a projectile
//     the player sees; absence reads as subtle. Needs the original art or an
//     owner ruling on a deliberate replacement, not a guess.
//   * Sound "x" (RS_WormLewd DeathSound): no "x" entry anywhere in CH's
//     SNDINFO.txt -- inert in CH itself. Kept verbatim.
//   * Sprite IFN2 frames C and F (RS_BrownDemon2 Dash/Missile): CH ships
//     only IFN2 A/B in both trees. Every C/F use is a 0-tic state, so CH
//     never renders them either. Kept verbatim.
//
// Standing strips, preserved at each site as "// CH:" comments: ACS
// announcers, the CHRandom_GibGenerator/NashGore gore chain (owner accepts
// vanilla gore; XDeath ANIMATIONS stay), DRLA RL*/RareArmorPool drops.
// ============================================================================

// ---------------------------------------------------------------------------
// Third-file externals referenced by Demons.txt.
// ---------------------------------------------------------------------------

class RS_MolochQuake : Actor   // CH CYBIES.txt:4005 -- the floor shockwave ray
{
	Default
	{
		Speed 8;
		DamageFunction (random(5,27));   // CH: Damage(random(5,27))
		DamageType "Melee";
		Radius 12;
		Height 16;
		RenderStyle "Translucent";
		Alpha 0.1;
		Projectile;
		+DROPOFF
		-NOGRAVITY
		+FORCERADIUSDMG
		+BLOODLESSIMPACT
		+FLOORHUGGER
		+RIPPER
		SeeSound "moloch/thud";
	}
	States
	{
	Spawn:
		IDGA CCAABBCCC 10 A_Explode(random(7,28),128);   // per-frame explode: CH's lingering quake, deliberate
	Death:
		IDGA C 1 A_Explode(random(7,28),128);
		Stop;
	}
}

class RS_ZapZapCB : Actor   // CH CYBIES.txt:4410 -- yellow's crawling lightning
{
	Default
	{
		Speed 1;
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		DamageType "Plasma";
		Alpha 0.65;
		Scale 1;
	}
	States
	{
	Spawn:
		LITN ABCDEFGOPABCDEFGOP 1 Bright A_Explode(random(1,8),64);   // per-frame explode: CH's lightning DoT, deliberate
		Stop;
	}
}

class RS_RedThingsLS : Actor   // CH lostsouls.txt:1218 -- red's melee blood flecks
{
	Default
	{
		Radius 1;
		Height 1;
		Mass 8;
		Speed 9;
		Projectile;
		+THRUACTORS
		-NOGRAVITY
		Scale 0.15;
		Gravity 2;
		RenderStyle "Add";
		Alpha 0.8;
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 12;
		BAL1 A 2 A_Jump(32,"Death");
		Loop;
	Death:
		BAL1 A 1 A_SetTranslucent(0.35);
		Stop;
	}
}

class RS_HKEXProtect : PowerProtection   // CH Hellknights.txt:2922 -- brown's dash armor
{
	Default
	{
		DamageFactor 0.6;
		Powerup.Duration -7;
	}
}

class RS_SpikeCyanRev : Actor   // CH Revenants.txt:446 -- cyan worm's ice needle
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 9;
		Mass 500;
		DamageFunction (random(1,3));   // CH: Damage (random(1,3))
		Projectile;
		DamageType "Ice";
		-NOGRAVITY
		+THRUGHOST
		Gravity 1.5;
		Scale 0.25;
		RenderStyle "Add";
		Alpha 0.80;
		DeathSound "";
		Translation "0:255=%[0.06,0.31,0.35]:[1.01,2.00,2.00]";
	}
	States
	{
	Spawn:
		RIP1 ABCABC 8 Bright;
	Death:
		RIP1 CBA 6 A_Explode(random(0,1),6);
		Stop;
	}
}

class RS_Splash11 : Actor   // CH Revenants.txt:1649 -- green death-web droplet
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		-NOGRAVITY
		RenderStyle "Add";
		Scale 0.3;
		Alpha 0.5;
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 AB 12;
		BAL1 A 2 A_Jump(32,"Death");
		Loop;
	Death:
		BAL7 C 1 Bright A_SetScale(0.6);
		BAL7 CDE 4 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Demons.txt internals: support, projectiles, minion FX. File order.
// ---------------------------------------------------------------------------

class RS_BrownDemonGhost : Actor   // CH Demons.txt:294 -- brown's dash afterimage
{
	Default
	{
		Radius 30;
		Height 56;
		Speed 1;
		RenderStyle "Translucent";
		Alpha 0.33;
		Species "Demon1";
		Health 15;
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
	}
	States
	{
	Spawn:
		IFIN ABCD 6 Bright;
		Goto Death;
	Death:
		TNT1 A 0 A_Stop;
		IFIN G 1 Bright A_NoBlocking;
		IFIN G 1 Bright A_SetScale(0.8,0.8);
		IFIN G 1 Bright A_SetScale(0.6,0.6);
		IFIN G 1 Bright A_SetScale(0.3,0.2);
		IFIN G 1 Bright A_SetScale(0.1,0.1);
		TNT1 A 0 A_Die;
		Stop;
	}
}

class RS_BrownOrbDemon : Actor   // CH Demons.txt:330 -- brown's sniper orb
{
	Default
	{
		Radius 3;
		Height 3;
		Speed 28;
		ProjectileKickback 2000;
		Mass 100;
		Species "Demon1";
		DamageFunction (random(13,33));   // CH: Damage (random(13,33))
		Projectile;
		DamageType "Fire";
		+MTHRUSPECIES
		+THRUGHOST
		SeeSound "fire/fire3";
		DeathSound "weapons/boom1";
		Translation "0:255=@74[77,52,26]";
		Scale 0.5;
	}
	States
	{
	Spawn:
		BAL1 AB 4 Bright;
		Loop;
	Death:
		RIP1 D 0 A_SetScale(1.0,1.0);
		TNT1 A 0 A_SetTranslation("BBEASTEX5");   // defined in TRNSLATE.txt (CH's own no-op range, imported with the chaingunner family)
		RIP1 DEFGH 3 Bright A_Explode(random(2,8),64);
		Stop;
	}
}

class RS_AbyssDogFire : Actor   // CH Demons.txt:792 -- abyss hound's seeker flame
{
	Default
	{
		Radius 4;
		Height 3;
		Speed 18;
		DamageFunction (random(5,45));   // CH: Damage (random(5,45))
		Projectile;
		+SEEKERMISSILE
		DamageType "Fire";
		RenderStyle "Add";
		Alpha 1.95;
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
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		FRFX B 1 Bright A_Weave(3,1,5,0);
		FRFX C 1 Bright A_SeekerMissile(2,2);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssShotIdentifier",0,0,0,random(1,7),0,random(-5,5),random(0,359),SXF_TRANSFERTRANSLATION|SXF_NOCHECKPOSITION);
		FRFX D 1 Bright A_Weave(3,1,5,0);
		Loop;
	Death:
		FRFX HIJ 2 Bright A_Explode(random(1,9),32);
		FRFX KLM 2 Bright A_Explode(random(1,7),64);
		FRFX NO 2 Bright;
		Stop;
	}
}

class RS_SplashAbyssBubbleDemon : Actor   // CH Demons.txt:826 -- abyss dog's pond bubble
{
	Default
	{
		Radius 16;
		Height 4;
		Speed 3;
		Projectile;
		+THRUACTORS
		+FLOORHUGGER
		SeeSound "";
		YScale 0.12;
		XScale 1.45;
		DeathSound "";
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		ICEY G 3 Bright;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-124,124),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		ICEY H 3 Bright;
		TNT1 AA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-124,124),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		ICEY I 3 Bright;
		TNT1 AAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-124,124),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(24,"Death");
		Loop;
	Death:
		ICEY ABC 1 Bright;
		ICEY GHI 2 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-24,24),random(-128,128),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss2",random(-128,128),random(-24,24),random(6,16),0,0,2,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_WormLewd : Actor   // CH Demons.txt:994 -- gray worm's coil-drain pulse
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 14;
		FastSpeed 26;
		Scale 0.75;
		Species "Demon1";
		DamageFunction (random(5,23));   // CH: Damage (random(5,23))
		DamageType "Melee";
		Projectile;
		+DONTHARMCLASS
		+DONTHARMSPECIES
		RenderStyle "Add";
		Alpha 0.25;
		SeeSound "";
		DeathSound "x";   // "x" resolves to nothing in CH's own SNDINFO -- silent there too, kept verbatim
		Translation "168:191=112:127";
	}
	States
	{
	Spawn:
		BAL1 A 1 Bright;
		Goto Death;
	Death:
		BAL1 CDE 2 Bright A_Explode(random(1,7),32,0);
		Stop;
	}
}

class RS_GreenDEDSmoke : Actor   // CH Demons.txt:1222 -- green's death barrel-pop
{
	Default
	{
		Radius 10;
		Height 42;
		+DONTGIB
		+NOGRAVITY
		DamageType "Fire";
		DeathSound "world/barrelx";
		Translation "128:143=113:127","144:151=118:127","168:191=113:127","208:223=112:121","232:235=120:125","121:127=0:0";
		Scale 0.9;
	}
	States
	{
	Spawn:
		MISL A 0 A_PlaySound("world/barrelx");
		Goto Death;
	Death:
		MISL B 8 Bright A_Explode(random(5,10),42);
		MISL C 6 Bright A_PlaySound("world/barrelx");
		MISL D 4 Bright;
		Stop;
	}
}

class RS_BloodDemonArm : Actor   // CH Demons.txt:1580 -- yellow's severed arm (spectres.txt:921 references it too)
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 8;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		+DROPOFF
		+MISSILE
		Translation "168:191=160:167","16:31=208:216","32:40=215:223","41:46=232:235","47:47=190:190";
	}
	States
	{
	Spawn:
		SG2A ABCDEFGH 2;
		Loop;
	Death:
		SG2A I -1;
		Loop;
	}
}

class RS_RedDemonBloodBolt1 : Actor   // CH Demons.txt:1705 -- red's blood shot
{
	Default
	{
		Radius 7;
		Height 7;
		Mass 5;
		Speed 19;
		Projectile;
		Scale 0.95;
		RenderStyle "Add";
		DamageFunction (random(2,27));   // CH: Damage (random(2,27))
		DamageType "Fire";
		Alpha 0.95;
		SeeSound "imp/attack";
		DeathSound "misc/gibbed";
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 1;
		BAL1 BBB 0 A_CustomMissile("RS_RedDemonBloodBolt2",1,0,random(-180,180));
		Loop;
	Death:
		BAL1 CD 1 A_SetTranslucent(0.35);
		BAL1 EEEEEEEEEEEE 0 A_CustomMissile("RS_RedDemonBloodBolt2",1,0,random(-180,180),CMF_AIMOFFSET,random(-180,180));
		BAL1 E 1;
		Stop;
	}
}

class RS_RedDemonBloodBolt2 : Actor   // CH Demons.txt:1734 -- the droplet spray
{
	Default
	{
		Speed 2;
		Alpha 0.75;
		RenderStyle "SoulTrans";
		Projectile;
		DamageType "Fire";
		DamageFunction (random(0,1));   // CH: damage (random(0,1))
		Scale 0.95;
	}
	States
	{
	Spawn:
		BLUD CBA 8;
		// OWNER RULING 2026-08-06: "i want it visually consistent, so use BAL1".
		// SPRY was proven unresolvable (see header) -- the art exists in neither
		// CH nor CHP, and CHP retypes the same dead token. CH's three OTHER blood
		// bolts all draw BAL1 (RS_RedDemonBloodBolt1 above, BloodBoltHK
		// Hellknights.txt:2060, RedThingsHK :2107), so this now matches its own
		// family instead of rendering nothing. BAL1 ships A-E only, so CH's
		// 6+1 frame split becomes 5+1 over the same 20 tics: ABCDE at 3, then
		// E held 5 to keep the tail length. Frame E is the fade, as the sibling
		// bolt uses it. THIS IS A DELIBERATE DEPARTURE FROM CH -- do not revert.
		BAL1 ABCDE 3;   // CH: SPRY ABCDEF 3
		BAL1 E 5;       // CH: SPRY G 2
		Stop;
	Death:
		BLUD C 0;
		Stop;
	}
}

class RS_RedDemonBloodBolt3 : Actor   // CH spectres.txt:1031 -- fired by both families (Demons.txt:238 ChainFlame2)
{
	Default
	{
		Speed 15;
		Alpha 0.75;
		RenderStyle "SoulTrans";
		Projectile;
		-NOGRAVITY;
		Mass 5;
		Gravity 0.2;
		DamageType "Fire";
		DamageFunction (random(1,5));   // CH: damage (random(1,5))
		Scale 0.95;
	}
	States
	{
	Spawn:
		BLUD CBA 8;
		// OWNER RULING 2026-08-06 -- same as RS_RedDemonBloodBolt2 above; see the
		// note there and the header. CH's 6+1 at 4/3 tics (27 total) becomes 5+1
		// over the same span: ABCDE at 4, E held 7. Deliberate departure, not a
		// transcription error.
		BAL1 ABCDE 4;   // CH: SPRY ABCDEF 4
		BAL1 E 7;       // CH: SPRY G 3
		Stop;
	Death:
		BLUD C 0;
		Stop;
	}
}

class RS_BloodDemonArm2 : Actor   // CH Demons.txt:1756 -- red's severed arm (spectres.txt:1018 references it too)
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 8;
		BounceType "Doom";   // CH: +DOOMBOUNCE
		+DROPOFF
		+MISSILE
	}
	States
	{
	Spawn:
		SG2A ABCDEFGH 2;
		Loop;
	Death:
		SG2A I -1;
		Loop;
	}
}

class RS_ButcherHammer : Actor   // CH Demons.txt:1924 -- the dropped cleaver-hammer
{
	Default
	{
		BounceType "Doom";   // CH: +DoomBounce
		+NOBLOCKMAP
		Gravity 0.4;
		Speed 3;
	}
	States
	{
	Spawn:
		BRHM ABCD 5;
		BRHM E -1;
		Stop;
	}
}

class RS_DogFire : Actor   // CH Demons.txt:2034 -- butcher hound's flame lick
{
	Default
	{
		Radius 2;
		Height 4;
		Speed 16;
		Damage 1;   // bare constant stays bare (engine 1d8 multiply)
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		Alpha 0.67;
		Scale 0.67;
		SeeSound "weapons/bigbrn";
		DeathSound "weapons/bigbrn";
		DontHurtShooter true;   // engine: Property DontHurtShooter (actor.zs:310) -- takes a value, not a bare flag
		+THRUGHOST
	}
	States
	{
	Spawn:
		TNT1 A 2 Bright;
		FRFX ABCD 2 Bright A_Explode(1,8);   // per-frame explode: CH's growing fireburst, deliberate
		FRFX D 0 A_LowGravity;
		FRFX EFG 2 Bright A_Explode(1,16);
		FRFX HIJ 2 Bright A_Explode(1,32);
		FRFX KLM 2 Bright A_Explode(1,64);
		FRFX NO 2 Bright;
		Stop;
	Death:
		FRFX HIJ 2 Bright A_Explode(1,32);
		FRFX KLM 2 Bright A_Explode(1,64);
		FRFX NO 2 Bright;
		Stop;
	}
}

class RS_DogShot : Actor   // CH Demons.txt:2068 -- hound bolt (defined in CH, fired by nothing in Demons.txt; kept per import-everything rule)
{
	Default
	{
		Radius 8;
		Height 12;
		Speed 16;
		Damage 7;   // bare constant stays bare
		Projectile;
		RenderStyle "Add";
		DamageType "Fire";
		+THRUGHOST
		SeeSound "monster/dogsht";
		DeathSound "monster/doghit";
	}
	States
	{
	Spawn:
		TNT1 A 3;
		HHFX AABBCC 1 Bright A_SpawnItemEx("RS_DogTrail",0,0,0,0,0,0,0,128);
		Goto Spawn+1;
	Death:
		HHFX DFGH 4 Bright;
		Stop;
	}
}

class RS_DogTrail : BulletPuff   // CH Demons.txt:2092
{
	Default
	{
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		TNT1 A 5;
		HHFX DFGH 3 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// White boss meteor rig. CH Demons.txt:2404-2654.
// ---------------------------------------------------------------------------

class RS_MeteorStrikeCH : Actor   // CH Demons.txt:2404 -- the strike marker
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		FloatSpeed 1;
		+NOCLIP
		DeathSound "Juggernaut/Attack";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Death;
	Death:
		TNT1 A 1 A_Scream;
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH",88,0,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH2",-88,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH3",0,88,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH4",-88,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH5",0,46,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		JUBD A 0 A_SpawnItemEx("RS_CircleDrawMeteorCH6",-46,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		CHTA A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH5",0,46,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH6",-46,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		CHTA A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH5",0,46,-3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		TNT1 A 1 Bright A_SpawnItemEx("RS_CircleDrawMeteorCH6",-46,0,0,-3,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		CHTA A 10 Bright;
		TNT1 A 1 Bright;
		TNT1 A 0 A_KillChildren("Extreme",KILS_FOILINVUL|KILS_KILLMISSILES);
		Stop;
	}
}

class RS_CircleDrawMeteorCH : Actor   // CH Demons.txt:2451 -- orbiting ring tracer
{
	int user_angle;
	Default
	{
		Radius 1;
		Height 1;
		Speed 255;
		Projectile;
		+INVISIBLE
		+NOCLIP
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,88,0,1,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 AAAA 0 A_SpawnParticle("orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(90,120),random(11,13),0,0,0,3,0,0,0,0,0,0,0.98,-1,0);
		TNT1 A 0 { user_angle = user_angle + 7; }   // CH: A_SetUserVar("user_angle",user_angle + 7)
		Loop;
	}
}

class RS_CircleDrawMeteorCH2 : RS_CircleDrawMeteorCH   // CH Demons.txt:2474
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,-88,0,1,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 AAAA 0 A_SpawnParticle("orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(90,120),random(11,13),0,0,0,3,0,0,0,0,0,0,0.98,-1,0);
		TNT1 A 0 { user_angle = user_angle + 7; }
		Loop;
	}
}

class RS_CircleDrawMeteorCH3 : RS_CircleDrawMeteorCH   // CH Demons.txt:2489
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,0,88,1,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 AAAA 0 A_SpawnParticle("orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(90,120),random(11,13),0,0,0,3,0,0,0,0,0,0,0.98,-1,0);
		TNT1 A 0 { user_angle = user_angle + 7; }
		Loop;
	}
}

class RS_CircleDrawMeteorCH4 : RS_CircleDrawMeteorCH   // CH Demons.txt:2504
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,0,-88,1,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 AAAA 0 A_SpawnParticle("orange",SPF_FULLBRIGHT|SPF_RELATIVE,random(90,120),random(11,13),0,0,0,3,0,0,0,0,0,0,0.98,-1,0);
		TNT1 A 0 { user_angle = user_angle + 7; }
		Loop;
	}
}

class RS_CircleDrawMeteorCH5 : RS_CircleDrawMeteorCH   // CH Demons.txt:2519
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,0,46,4,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 AAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(90,120),random(15,20),0,0,0,5,0,0,0,0,0,0.01,0.98,-1,0);
		TNT1 A 0 { user_angle = user_angle + 9; }
		Loop;
	}
}

class RS_CircleDrawMeteorCH6 : RS_CircleDrawMeteorCH   // CH Demons.txt:2534
{
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		CDW2 X 1 Bright A_Warp(AAPTR_MASTER,0,-46,4,user_angle,WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 AAAA 0 A_SpawnParticle("Red",SPF_FULLBRIGHT|SPF_RELATIVE,random(90,120),random(15,20),0,0,0,5,0,0,0,0,0,0.01,0.98,-1,0);
		TNT1 A 0 { user_angle = user_angle + 9; }
		Loop;
	}
}

class RS_WDRock1 : Actor   // CH Demons.txt:2549 -- the slow riser boulder
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 5;
		FloatSpeed 6;
		+FLOAT
		+NOGRAVITY
		+NOCLIP
		Scale 1.2;
	}
	States
	{
	Spawn:
		JUBD A 0;
		Goto Fly;
	Fly:
		JUBD A 0 ThrustThingZ(0,8,0,0);
		JUBD A 6 Bright A_PlaySound("moloch/step",7,2,false,ATTN_NONE);
		Goto Death;
	Death:
		JUBD A 3 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),0,2,0,3,random(0,360),128);
		JUBD A 3 Bright A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),0,1,0,3,random(0,360),128);
		JUBD A 11 Bright A_SpawnItemEx("RS_Drt3",random(-1,2),random(-2,2),0,3,0,3,random(0,360),128);
		Stop;
	}
}

class RS_WDRock2 : Actor   // CH Demons.txt:2577 -- the lobbed boulder
{
	Default
	{
		Radius 12;
		Height 12;
		Speed 28;
		DamageFunction (random(35,125));   // CH: Damage (Random(35,125))
		DamageType "Melee";
		Projectile;
		-NOGRAVITY
		Gravity 0.12;
		Scale 1.2;
		SeeSound "monster/hamflr";
		DeathSound "moloch/thud";
	}
	States
	{
	Spawn:
		JUBD ABCD 1 Bright A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-3,3),1,0,1,random(0,360),128);
		JUBD A 0 A_PlaySound("Ice/Fly");
		Loop;
	Death:
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt1",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDDDDD 0 A_CustomMissile("RS_WDRock4",random(-1,12),random(-12,12),random(0,360),CMF_OFFSETPITCH|CMF_ABSOLUTEPITCH|CMF_ABSOLUTEANGLE,random(0,360));
		JUBD DDD 0 A_CustomMissile("RS_WDRock3",random(-1,12),random(-12,12),random(0,360),CMF_OFFSETPITCH|CMF_ABSOLUTEPITCH|CMF_ABSOLUTEANGLE,random(0,360));
		JUBD DDDDDDD 0 A_CustomMissile("RS_WDRock4",random(-1,12),random(-12,12),random(0,360),CMF_OFFSETPITCH|CMF_ABSOLUTEPITCH|CMF_ABSOLUTEANGLE,random(0,360));
		JUBD D 1 Bright Radius_Quake(40,60,0,40,0);
		Stop;
	}
}

class RS_WDRock4 : Actor   // CH Demons.txt:2609 -- shrapnel pebble
{
	Default
	{
		Radius 4;
		Height 4;
		Speed 42;
		DamageFunction (random(5,20));   // CH: Damage (Random(5,20))
		DamageType "Melee";
		Projectile;
		Scale 0.4;
		SeeSound "monster/hamflr";
		DeathSound "Butcher/melee";
	}
	States
	{
	Spawn:
		JUBD ABCD 2 Bright;
		Loop;
	Death:
		JUBD DD 1 Bright A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),0,1,0,1,random(0,360),128);
		Stop;
	}
}

// RS_WDRock3 (CH Demons.txt:2632) is NOT defined here: the zombieman family
// already owns it (RS_ZombiemanFX.zs:680, imported for ZombieRock's parent).
// Both bodies were diffed against CH Demons.txt:2632 and are identical --
// Radius 9, Height 9, Speed 36, DamageFunction (random(15,65)), Melee,
// Scale 0.7, monster/hamflr / Butcher/melee, JUBD ABCD 3 spawn, same death.
// RS_WDRock2's death and RS_WhiteDemon2's ROCKS2 reference it read-only.
