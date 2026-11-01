// RSQ Grenade -- THE BLAST: how the explosion looks (no damage here; the damage is the grenade's own A_Explode,
// thrown.zs, so the kill is credited to the player who threw it).
//
// Ported from the owner's RS_Grenade (rs_blast.zs, itself RS_Main's RS_FX_Blast): the UAC Survival Pack's hand
// grenade detonation (JohnnyDoom's pack; J_ThrownGrenade's XDeath, DECORATE.grenade) transcribed 1:1 -- the same
// actors in the same order at the same counts: 12 flames, 10 heavy embers, 18 fast embers, 73 shrapnel sparks, 2
// smoke columns, 4 trailing smokes, the flare and the secondary burst. The pack's crater actors are left out (they
// need its own dirt actors and an ACS script). Nothing from the owner's RS_FX library is called: every class here
// is its own, RSQGN_-prefixed, and its sprites are the pack's, renamed to QG* so no other mod's lumps are replaced
// (JFLR->QGFL, JL2N->QGL2, JLNR->QGLR, JS17->QGSC, JSMO->QGSM, JSPK->QGSK, JXPL->QGXP; byte-identical to the
// pack's, checked when they were copied).
//
// DECORATE-isms RS_Grenade already corrected on its import: +DOOMBOUNCE -> BounceType "Doom"; XScale/YScale ->
// Scale set in PostBeginPlay; the underwater ACS call -> a waterlevel check.

// ---------------------------------------------------------------------
// Bases
// ---------------------------------------------------------------------
class RSQGN_BlastFlareBase : Actor
{
	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+CLIENTSIDEONLY
		RenderStyle "Add";
		Radius 1;
		Height 1;
		Alpha 0.4;
		Scale 0.4;
	}
}

class RSQGN_BlastEmber : Actor
{
	Default
	{
		Speed 9;
		Radius 8;
		Height 1;
		Gravity 0.5;
		RenderStyle "Add";
		Scale 0.06;
		Damage 0;
		+MISSILE
		+CLIENTSIDEONLY
		+NOTELEPORT
		+NOBLOCKMAP
		+BLOODLESSIMPACT
		+FORCEXYBILLBOARD
		+DONTSPLASH
		+THRUACTORS
		+GHOST
		BounceType "Doom";      // was +DOOMBOUNCE
		BounceFactor 0.01;
	}
	States
	{
	Spawn:
		QGSK A 1 Bright A_FadeOut(0.02);
		Wait;
	Death:
		Stop;
	}
}

// ---------------------------------------------------------------------
// Flares
// ---------------------------------------------------------------------
class RSQGN_BlastRedFlare : RSQGN_BlastFlareBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_Jump(128, "Alt");
		QGLR A 2 Bright;
		Stop;
	Alt:
		QGLR B 2 Bright;
		Stop;
	}
}

class RSQGN_BlastFlare : RSQGN_BlastFlareBase
{
	Default
	{
		Alpha 1.0;
	}
	// XScale 0.8 / YScale 0.4 in the source. A Default block cannot hold
	// a non-uniform scale on this engine, so it is set here.
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Scale = (0.8, 0.4);
	}
	States
	{
	Spawn:
		QGFL A 2 Bright;
		QGFL AAAAAAAAAAAAAAAA 1 Bright A_FadeOut(0.11);
		Stop;
	}
}

class RSQGN_BlastFlareSpawner : RSQGN_BlastFlareBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnItem("RSQGN_BlastFlare");
		QGL2 AAA 1 Bright;
		QGL2 A 5;
		Stop;
	}
}

// ---------------------------------------------------------------------
// Smoke
// ---------------------------------------------------------------------
class RSQGN_BlastSmoke : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+DONTSPLASH
		+MISSILE
		+FORCEXYBILLBOARD
		+CLIENTSIDEONLY
		+NOINTERACTION
		+NOGRAVITY
		+THRUACTORS
		BounceType "Doom";
		BounceFactor 0.5;
		Radius 0;
		Height 0;
		Alpha 0.2;
		RenderStyle "Translucent";
		Scale 0.9;
		Speed 2;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_JumpIf(waterlevel > 1, "Gone");
		QGSM A 20;
		TNT1 A 0 A_JumpIf(waterlevel > 1, "Gone");
		QGSM AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 2 A_FadeOut(0.01);
		Stop;
	Gone:
		TNT1 A 0;
		Stop;
	}
}

// The big slow bloom that hangs after the flash.
class RSQGN_BlastSmokeHeavy : RSQGN_BlastSmoke
{
	Default
	{
		Scale 1.4;
		Alpha 0.12;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_JumpIf(waterlevel > 1, "Gone");
		QGSM A 40;
		TNT1 A 0 A_JumpIf(waterlevel > 1, "Gone");
		QGSM AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 2 A_FadeOut(0.002);
		Stop;
	Gone:
		TNT1 A 0;
		Stop;
	}
}

class RSQGN_BlastSmokeColumn : Actor
{
	Default
	{
		Radius 0;
		Height 0;
		Alpha 0.4;
		RenderStyle "Translucent";
		Damage 0;
		+NOBLOCKMAP
		+NOTELEPORT
		+DONTSPLASH
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Scale = (1.4, 1.0);     // XScale 1.4 in the source
	}
	States
	{
	Spawn:
		QGSC E 4;
		TNT1 A 0 A_JumpIf(waterlevel > 1, "Gone");
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC ABCD 5;
		QGSC E 4;
		Stop;
	Gone:
		TNT1 A 0;
		Stop;
	}
}

// ---------------------------------------------------------------------
// Embers / shrapnel
// ---------------------------------------------------------------------
class RSQGN_BlastEmberFast : RSQGN_BlastEmber
{
	Default
	{
		Scale 0.05;
		Speed 18;
		Gravity 0.9;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_JumpIf(waterlevel > 1, "Death");
		QGSK A 1 Bright A_FadeOut(0.02);
		Wait;
	Death:
		Stop;
	}
}

class RSQGN_BlastShrapnel : RSQGN_BlastEmber
{
	Default
	{
		Speed 20;
		Gravity 0.0;
		+NOGRAVITY
		Scale 0.12;
		Radius 10;
		Height 10;
		Damage 0;
		Alpha 1.0;
	}
	States
	{
	Spawn:
		QGSK AAAAAAAAAAAAAAAAA 1 Bright A_FadeOut(0.05);
		Stop;
	Death:
		Stop;
	}
}

// ---------------------------------------------------------------------
// Flames -- the body of the explosion.
// ---------------------------------------------------------------------
class RSQGN_BlastFlames : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+DONTSPLASH
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+MISSILE
		+NOGRAVITY
		+THRUACTORS
		Radius 1;
		Height 1;
		RenderStyle "Add";
		Alpha 1.0;
		Scale 2.2;
		Speed 2;
		Damage 0;
	}
	States
	{
	Spawn:
		QGXP AA 3 Bright A_SpawnItem("RSQGN_BlastRedFlare", 0, 0);
		QGXP BCDF 3 Bright;
		QGXP AAA 0 A_SpawnProjectile("RSQGN_BlastSmoke", 0, 0,
			random(0, 360), CMF_AIMDIRECTION, random(0, 360));
		QGXP GHII 3 Bright;
		Stop;
	}
}

class RSQGN_BlastFlamesMedium : RSQGN_BlastFlames
{
	Default
	{
		Scale 1.3;
	}
	States
	{
	Spawn:
		QGXP AA 2 Bright A_SpawnItem("RSQGN_BlastRedFlare", 0, 0);
		QGXP A 0 A_SpawnProjectile("RSQGN_BlastSmoke", 0, 0,
			random(0, 360), CMF_AIMDIRECTION, random(0, 360));
		QGXP BCDF 2 Bright;
		QGXP GHII 2 Bright;
		Stop;
	}
}

// ---------------------------------------------------------------------
// RSQGN_Blast -- ONE actor that fires the whole layered detonation.
//
// The source spelled this out as ~40 inline A_CustomMissile lines in the
// grenade's own Death state, twice (it picked between two near-identical
// variants with A_Jump). Putting it in one place means anything that
// wants this explosion spawns one actor, and tuning it is one edit
// rather than two.
// ---------------------------------------------------------------------
// THE SOURCE'S DETONATION, 1:1.
//
// This is J_ThrownGrenade's XDeath state transcribed verbatim: the same
// actors, in the same order, at the same counts -- 12 flames, 10 heavy
// embers, 18 fast embers, 73 shrapnel, 2 smoke columns, 4 trailing
// smokes, and the same two-stage A_Explode(85,200) / A_Explode(75,255).
//
// It is a wall of repeated TNT1 frames because that is what it is in the
// source. I rewrote it once as a cvar-driven loop and that was wrong:
// the counts ARE the explosion, and changing them changes the thing the
// owner asked for. If a shrapnel slider is wanted it goes in on top of
// this, not instead of it.
//
// The only substitutions are names -- G_* to RSQGN_Blast* -- and the two
// crater actors, which are dropped: they exist to spawn MudDust /
// DirtChunk / BrownCloud off an IsOverGrass inventory token, none of
// which exist in this project, behind the source's one ACS call.
class RSQGN_Blast : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+NOGRAVITY
		+CLIENTSIDEONLY
		+DONTSPLASH
		RenderStyle "Add";
		Alpha 1.0;
	}

	// The pack's 73 shrapnel sparks (a wall of 73 A_CustomMissile lines in the source), as one loop.
	action void A_RSQGN_BlastShrapnel()
	{
		for (int i = 0; i < 73; i++)
			A_SpawnProjectile("RSQGN_BlastShrapnel", 0, 0, random(0, 360), CMF_AIMDIRECTION, random(0, 360));
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnItemEx("RSQGN_BlastFlareSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("RSQGN_BlastKaboom", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAAA 0 A_SpawnProjectile("RSQGN_BlastFlames", 0, 0, random(0, 360), CMF_AIMDIRECTION, random(0, 360));
		TNT1 AAAAAAAAAA 0 A_SpawnProjectile("RSQGN_BlastEmber", 0, 0, random(0, 360), CMF_AIMDIRECTION, random(0, 360));
		TNT1 AAAAAAAAAAAAAAAAAA 0 A_SpawnProjectile("RSQGN_BlastEmberFast", 0, 0, random(0, 360), CMF_AIMDIRECTION, random(0, 360));
		TNT1 A 0 A_RSQGN_BlastShrapnel();
		TNT1 A 0 A_QuakeEx(3, 3, 3, 30, 0, 448, "none");
		TNT1 AA 0 A_SpawnItemEx("RSQGN_BlastSmokeColumn", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		// NOTE: the source's two A_Explode calls are NOT here -- they
		// live in the thrown grenade's own Death state, at the same
		// numbers (85/200 then 75/255). They have to: A_Explode credits
		// the calling actor's target as the killer, and this actor has
		// none, so firing the blast from here would strip the player of
		// the kill -- no obituary, no score, no Bits, no GunBonsai XP.
		// The visuals belong here; the damage belongs to the grenade.
		TNT1 A 2;
		TNT1 AAAA 8 Bright A_SpawnProjectile("RSQGN_BlastSmoke", 1, 0, random(0, 360), CMF_AIMDIRECTION, random(50, 130));
		Stop;
	}
}

// G_BarrelKaboom -- the secondary burst the source fires alongside the
// main one. Kept because it is part of the look.
class RSQGN_BlastKaboom : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+NOGRAVITY
		+CLIENTSIDEONLY
		+DONTSPLASH
	}
	States
	{
	Spawn:
		TNT1 A 1;
		TNT1 AAAAAA 0 A_SpawnProjectile("RSQGN_BlastFlamesMedium", 20, 0, random(0, 360), CMF_AIMDIRECTION, random(0, 180));
		Stop;
	}
}
