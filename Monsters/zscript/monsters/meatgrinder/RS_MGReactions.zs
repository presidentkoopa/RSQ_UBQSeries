// ============================================================================
// RS_MGReactions.zs -- the pieces of the owner's HF monster template that the
// MeatGrinder monsters used in HF, besides what lives on RS_MGMonster itself
// (owner 2026-11-09: "TAKE THAT CODE"). Renamed so nothing clashes:
//   HF_HitKind / HF_EventContext (spine/HF_EventContext.zs) -> MGHIT_* / RS_MGEventContext
//   HF_ReactionHandler.WorldThingDied + BuildContext (spine/HF_ReactionHandler.zs)
//                                                       -> RS_MGReactionHandler
//   HF_RiftFlash, HF_HeadGibSpurt, HF_GoreBudget, HF_BurnLight, HF_ZapLight,
//   HF_FrostLight (monsters/HF_MonsterFX.zs)            -> MG_*
//   HF_EmberTrail, HF_SmokeWake, HF_BulletSpark (weapons/hf_ballistic_fx.zs)
//                                                       -> MG_*
// Sprites: TI3R M -> MGC3, DPUF -> MGC1, LPUF -> MGC2 (sprites/meatgrinder/).
// Cvars: hf_gore_level -> rsq_mg_gore_level, hf_gore_budget -> rsq_mg_gore_budget.
//
// What HF_ReactionHandler ALSO did on every monster's damage/death and is NOT
// here, because it is a whole-game system rather than the monsters' own code:
// score, kill-reward bits, elite gun drops, the director, damage numbers,
// weapon condition wear, and setting monsters on fire with HF_BurnFlame.
// ============================================================================

enum RS_MGHitKind
{
	MGHIT_NONE = 0,
	MGHIT_HITSCAN,
	MGHIT_MELEE,
	MGHIT_PROJECTILE,
}

struct RS_MGEventContext
{
	Actor  victim;
	Actor  attacker;
	Actor  inflictor;
	int    hitKind;
	Name   dmgType;
	bool   fromPlayer;
	bool   isHeadshot;
	bool   overkill;
	int    damage;
	double range;

	void Reset()
	{
		victim = null; attacker = null; inflictor = null;
		hitKind = MGHIT_NONE; dmgType = 'None'; fromPlayer = false;
		isHeadshot = false; overkill = false; damage = 0; range = 0;
	}
}

class RS_MGReactionHandler : EventHandler
{
	override void WorldThingDied(WorldEvent e)
	{
		let m = RS_MGMonster(e.Thing);
		if (!m) return;
		RS_MGEventContext ctx;
		BuildContext(e, ctx);
		// HF's own proxy, against the CLASS's spawn health as before: ApplyTier now writes the tier's health into
		// StartHealth (for Score's base), and the gore is not meant to move with it (RS_MGMonster.MG_ClassSpawnHealth)
		ctx.overkill = (e.Damage >= m.MG_ClassSpawnHealth());
		m.MG_AssignDeathReaction(ctx);
	}

	void BuildContext(WorldEvent e, out RS_MGEventContext ctx)
	{
		ctx.Reset();
		ctx.victim    = e.Thing;
		ctx.attacker  = e.DamageSource;
		ctx.inflictor = e.Inflictor;
		ctx.damage    = e.Damage;
		ctx.dmgType   = e.DamageType;
		ctx.fromPlayer =
			(e.DamageSource && e.DamageSource.player) ||
			(e.Inflictor && e.Inflictor.target && e.Inflictor.target.player);
		if (e.Inflictor && e.Inflictor.bMissile)
			ctx.hitKind = MGHIT_PROJECTILE;
		else if (e.DamageSource && e.DamageSource.player &&
		         e.DamageSource.Distance3D(e.Thing) <= e.Thing.radius + 80)
			ctx.hitKind = MGHIT_MELEE;
		else
			ctx.hitKind = MGHIT_HITSCAN;
		if (e.DamageSource)
			ctx.range = e.DamageSource.Distance3D(e.Thing);
		let mm = RS_MGMonster(e.Thing);
		if (mm) ctx.isHeadshot = mm.mgLastWasHeadshot;
	}
}

// ---- the gore performance governor (HF_GoreBudget) ----
class MG_GoreBudget
{
	static int PartsFor(int wantBase)
	{
		CVar gl = CVar.FindCVar("rsq_mg_gore_level");
		if (gl && gl.GetInt() <= 0) return 0;
		int cap = 8;
		CVar gb = CVar.FindCVar("rsq_mg_gore_budget");
		if (gb && gb.GetInt() > 0) cap = gb.GetInt();
		if (wantBase < 0) return 0;
		return (wantBase > cap) ? cap : wantBase;
	}
}

// ---- the portal pop at an abyss death-split (HF_RiftFlash) ----
class MG_RiftFlash : Actor
{
	Default
	{
		Radius 1; Height 1;
		+NOINTERACTION +NOGRAVITY +NOBLOCKMAP +BRIGHT
		RenderStyle "Add";
		Alpha 0.9;
		Scale 0.6;
	}
	States
	{
	Spawn:
		MGC3 M 2 A_SetScale(0.8);
		MGC3 M 2 A_SetScale(1.1);
		MGC3 M 2 A_FadeOut(0.15);
		MGC3 M 2 A_FadeOut(0.2);
		Stop;
	}
}

// ---- the neck-geyser gob (HF_HeadGibSpurt; stock BLUD frames) ----
class MG_HeadGibSpurt : Actor
{
	Default
	{
		Radius 2;
		Height 4;
		Gravity 0.5;
		Scale 0.6;
		+NOBLOCKMAP
		+DROPOFF
		+CORPSE
		+DONTSPLASH
		+NOTELEPORT
		RenderStyle "Normal";
	}
	override void BeginPlay()
	{
		Super.BeginPlay();
		gravity *= frandom(1.0, 1.5);
	}
	States
	{
	Spawn:
		BLUD A 6;
		BLUD BC 6;
	Splat:
		BLUD C -1 A_QueueCorpse;
		Stop;
	}
}

// ---- brief death lights (HF_BurnLight / HF_ZapLight / HF_FrostLight) ----
class MG_BurnLight : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTELEPORT }
	States
	{
	Spawn:
		TNT1 A 1 A_AttachLight("mgburn", DynamicLight.PointLight, "FF6A24", 104, 0);
		TNT1 A 1 A_AttachLight("mgburn", DynamicLight.PointLight, "E85418", 72, 0);
		TNT1 A 1 A_AttachLight("mgburn", DynamicLight.PointLight, "B83810", 40, 0);
		Stop;
	}
}

class MG_ZapLight : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTELEPORT }
	States
	{
	Spawn:
		TNT1 A 1 A_AttachLight("mgzap", DynamicLight.PointLight, "70E0FF", 112, 0);
		TNT1 A 1 A_AttachLight("mgzap", DynamicLight.PointLight, "40A8F0", 76, 0);
		TNT1 A 1 A_AttachLight("mgzap", DynamicLight.PointLight, "2078C8", 40, 0);
		Stop;
	}
}

class MG_FrostLight : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTELEPORT }
	States
	{
	Spawn:
		TNT1 A 1 A_AttachLight("mgfrost", DynamicLight.PointLight, "B0E8FF", 96, 0);
		TNT1 A 1 A_AttachLight("mgfrost", DynamicLight.PointLight, "88C8F0", 60, 0);
		TNT1 A 1 A_AttachLight("mgfrost", DynamicLight.PointLight, "5098C8", 32, 0);
		Stop;
	}
}

// ---- burn-death embers and smoke (HF_EmberTrail / HF_SmokeWake) ----
class MG_EmberTrail : Actor
{
	Default
	{
		+NOGRAVITY +NOINTERACTION +BRIGHT +FORCEXYBILLBOARD
		RenderStyle "Add";
		Alpha 0.7;
		Scale 0.22;
	}
	States
	{
	Spawn:
		MGC1 ABCDE 2 Bright A_FadeOut(0.12);
		Stop;
	}
}

class MG_SmokeWake : Actor
{
	Default
	{
		+NOGRAVITY +NOINTERACTION +FORCEXYBILLBOARD
		RenderStyle "Translucent";
		Alpha 0.35;
		Scale 0.34;
	}
	States
	{
	Spawn:
		MGC2 ABCD 3 { A_SetScale(scale.x * 1.06, scale.y * 1.06); A_FadeOut(0.06); }
		Stop;
	}
}

// ---- bouncing spark (HF_BulletSpark): shock deaths, exploding heads ----
class MG_BulletSpark : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		Projectile;
		-NOGRAVITY
		+THRUACTORS
		+BOUNCEONWALLS
		+FORCEXYBILLBOARD
		+DONTSPLASH
		+NOTRIGGER
		+CLIENTSIDEONLY
		Gravity 0.4;
		BounceFactor 0.3;
		RenderStyle "Add";
		Scale 0.18;
		Alpha 1.0;
	}
	States
	{
	Spawn:
		MGC2 A 2 Bright A_FadeOut(0.06);
		MGC2 B 2 Bright A_FadeOut(0.08);
		MGC2 CD 2 Bright A_FadeOut(0.10);
		Loop;
	Death:
		Stop;
	}
}

// ---- the floating tier marker (HF_TierIcon, HF_MonsterFX.zs). HF picked the
// TI3R frame from its own tier order (A neutral, B green ... M white); TI3R A-M
// is the CH icon sheet RSQ Monsters already ships (sprites/rs_zombieman/).
class MG_TierIcon : Actor
{
	int tierFrame;
	Default
	{
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+BRIGHT
		RenderStyle "Add";
		Alpha 0.85;
		Scale 0.5;
	}
	States
	{
	Spawn:
		TI3R A 1 A_MGTierIconShow();
		TI3R A 17 A_FadeOut(0.05);
		Stop;
	}
	// RSQ ladder tier -> HF's frame index (HF_MonTier order).
	void SetTierFrame(int t)
	{
		static const int HFIDX[] = { 0, 0, 1, 2, 4, 5, 10, 7, 9, 6, 11, 12, 3, 8 };
		tierFrame = (t >= 0 && t < 14) ? HFIDX[t] : 0;
	}
	void A_MGTierIconShow() { frame = tierFrame; }
}

// ---- RSQ MONSTERS' SERVICE: what another mod may ask about our monsters, BY NAME (nothing links). ----
// First reader (owner 11-09, design/SCORE_EXPANSION.md A3): RSQ Score's Headshot row. Score reads a head shot off
// BD22's damage types (Head / MinorHead); the MeatGrinder set finds one by where the blow landed (DamageMobj above:
// the inflictor's Z against the head band), which no damage type carries. Score asks this on each player blow.
//   "headshot"  objectArg a monster -> 1 the blow being dealt now (or the last one a player dealt) landed in the head,
//               0 it did not, -1 not a MeatGrinder monster.
// mgLastWasHeadshot is set BEFORE Super.DamageMobj, and the engine fires WorldThingDamaged from inside that call,
// before Die (p_interaction.cpp:1612-1615, 1633 of QZD 17.3), so a reader in WorldThingDamaged sees this blow's answer.
class RSQMON_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "headshot")
		{
			let mg = RS_MGMonster(objectArg);
			if (!mg) return -1;
			return mg.mgLastWasHeadshot ? 1 : 0;
		}
		return -1;
	}
}
