// ============================================================================
// RSQ_Miniboss -- the tokens. Every one is plain Inventory, so it rides the save with its holder.
// ============================================================================

class RSQMB_Token : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		+INVENTORY.UNCLEARABLE;
	}
}

// ON THE MINIBOSS. ALL DAMAGE RULES LIVE HERE, in ModifyDamage, never in DamageFactor: Champions writes
// DamageFactor itself (a Titan's aura every tic, every champion's death), so a cut kept there would
// be overwritten. ModifyDamage runs for each blow before the engine's DamageFactor and BUDDHA, so
// this multiplies with whatever Champions, LegenDoom Lite and the monster's own factors do.
//   taken (passive):
//     invulnerable (the arrival's charge, a life just lost)  -> 0 (the Boss bar's GUARD shakes, bossbar.zs)
//     else  the blow x THE THRALLS' CUT (owner 2026-11-17, the original Minibosses!' rule with its integer division fixed:
//           1 - 0.8 x living thralls / the thralls it came with, boss.zs ThrallFactor) / the inherited toughness
//   dealt: x the inherited damage power
// A fraction of a point is carried to the next blow, so a pistol's 5 x 0.2 still lands.
// (The shield segments, the windows, "GUARD!", the grey Xs and the greed rule went 2026-11-17, owner.)
class RSQMB_Ward : RSQMB_Token
{
	RSQMB_Boss boss;

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (!boss || boss.done || damage <= 0) return;
		if (passive)
		{
			if (boss.Invulnerable() || boss.guardUp) { newdamage = 0; boss.guardHitTic = level.maptime; return; }   // guardUp: GUARD after EXPOSED! (bigacts.zs)
			// BOSS TRAITS (traits.zs): SHIELDED's shell turns a blow from its front
			if (boss.TraitBlocks(inflictor, source)) { newdamage = 0; return; }
			// BREAK! (telegraph.zs; BOSS_REWORK.md 3, 9.3): x2 a Boss, x3 a Big Boss while it staggers, on top of the cut;
			// a stunned CHARGER's x (traits.zs TraitMult)
			double d = damage * boss.ThrallFactor() * boss.BreakMult() * boss.TraitMult() / max(1.0, boss.toughness) + boss.carry;
			int nd = int(d + 1e-6);
			boss.carry = d - nd;
			nd = boss.TraitClamp(nd);     // SPLITTER: its body holds at 2 while its copy stands
			newdamage = nd;
			boss.TraitHurt(nd);           // SUMMONER: hurt in its cast, fewer land
		}
		else
		{
			double om = boss.outMult * boss.TraitOut();   // SPLITTER: a half's weaker blows
			if (om != 1.0) newdamage = max(1, int(round(damage * om)));
		}
	}
}

// THE GREY X went with the shield (2026-11-17): a save from before may still hold one in flight. It goes on its next tic.
class RSQMB_XFx : VisualThinker
{
	override void Tick() { Destroy(); }
}

// ON EACH THRALL: whose it is, so a death finds its miniboss without a search.
class RSQMB_Thrall : RSQMB_Token
{
	RSQMB_Boss boss;
}

// THE GREED RULE IS GONE (owner 2026-11-17: "the greed penalty needs to go"). A save from before may still hold monsters it
// enraged, each with this token: the first tic after such a save loads (handler.zs RageLegacy) puts back what the rage wrote
// (only where nobody else changed it since) and the token goes.
class RSQMB_Rage : RSQMB_Token
{
	double baseSpeed, rageSpeed;
	double baseMult, rageMult;
	int    baseMMC, rageMMC;

	void Restore(Actor a)
	{
		if (abs(a.Speed - rageSpeed) < 0.0001) a.Speed = baseSpeed;
		if (abs(a.MissileChanceMult - rageMult) < 0.000001) a.MissileChanceMult = baseMult;
		if (a.MinMissileChance == rageMMC) a.MinMissileChance = baseMMC;
	}
}
