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
//   taken (passive): 0 while invulnerable, else x shield (living thralls) x 1/toughness (inherited)
//   dealt          : x the inherited damage power
// A fraction of a point is carried to the next blow, so a pistol's 5 x 0.2 still lands 1 in 1.
class RSQMB_Ward : RSQMB_Token
{
	RSQMB_Boss boss;
	double carry;

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (!boss || boss.done || damage <= 0) return;
		if (passive)
		{
			// Struck by a player while thralls live: the greedy play this set piece is built around.
			Actor who = source;
			if (who && !who.player && who.FriendPlayer > 0) who = players[who.FriendPlayer - 1].mo;
			if (who && who.player) boss.NoteStruck();
			if (boss.Invulnerable()) { newdamage = 0; return; }
			double f = boss.TakeFactor();
			if (f >= 0.9999) return;
			double d = damage * f + carry;
			int nd = int(d + 1e-6);
			carry = d - nd;
			newdamage = nd;
		}
		else if (boss.outMult != 1.0)
		{
			newdamage = max(1, int(round(damage * boss.outMult)));
		}
	}
}

// ON EACH THRALL: whose it is, so a death finds its miniboss without a search.
class RSQMB_Thrall : RSQMB_Token
{
	RSQMB_Boss boss;
}

// ON EACH MONSTER THE GREED RULE ENRAGED: what it was, so it is put back exactly.
// Each value is restored only where nobody else changed it since (a value someone else wrote is theirs:
// LegenDoom Lite's transform mid-rage, a script's A_SetSpeed).
class RSQMB_Rage : RSQMB_Token
{
	double baseSpeed, rageSpeed;
	double baseMult, rageMult;
	int    baseMMC, rageMMC;

	// "Double aggression": the engine fires a missile when random(0..255) >= min(dist x MissileChanceMult,
	// MinMissileChance) (MissileChanceMult is what MISSILEMORE / MISSILEEVENMORE became in 4.13). Both
	// halved -> the threshold halves at every range. Speed (A_Chase's step) x speedMult. RSQ_SlowMo never
	// writes a monster's Speed (only a missile's), so the two compose: slowed AND enraged moves at
	// depth x 2 per its stretched tics.
	void Apply(Actor a, double speedMult)
	{
		baseSpeed = a.Speed;
		rageSpeed = a.Speed * speedMult;
		a.Speed = rageSpeed;
		baseMult = a.MissileChanceMult;
		rageMult = baseMult * 0.5;
		a.MissileChanceMult = rageMult;
		baseMMC = a.MinMissileChance;
		rageMMC = max(1, baseMMC / 2);
		a.MinMissileChance = rageMMC;
		a.ReactionTime = 0;      // a countdown, not a setting: spent, nothing to put back
	}

	void Restore(Actor a)
	{
		if (abs(a.Speed - rageSpeed) < 0.0001) a.Speed = baseSpeed;
		if (abs(a.MissileChanceMult - rageMult) < 0.000001) a.MissileChanceMult = baseMult;
		if (a.MinMissileChance == rageMMC) a.MinMissileChance = baseMMC;
	}
}
