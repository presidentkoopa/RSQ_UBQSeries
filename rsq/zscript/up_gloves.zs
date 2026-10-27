// THE GLOVES' UPGRADE PATH. Every one reads the punch the reader wrote onto the glove
// (RSQ_Glove.last*), because in ModifyDamageDealt the glove itself is the inflictor.

class RSQ_Upgrade_Base : TFLV_Upgrade_BaseUpgrade
{
	// These effects key off their own inflictors, so Gun Bonsai's priority chain (which keeps a
	// poison DoT from proccing an explosion) has nothing to protect here.
	override bool CheckPriority(Actor inflictor) { return true; }
	static bool GloveInfo(TFLV_WeaponInfo info) { return info && RSQM.IsGloveName(info.wpnClass); }
	static bool SaberInfo(TFLV_WeaponInfo info) { return info && RSQM.IsSaberName(info.wpnClass); }
	static bool ShieldInfo(TFLV_WeaponInfo info) { return info && RSQM.IsShieldName(info.wpnClass); }
	static bool Monster(Actor t) { return t && t.bIsMonster && t.health > 0; }
}

// HAYMAKER: the harder you throw it, the more each level adds.
class RSQ_Upgrade_Haymaker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv, double power) { return 1.0 + lv * (0.15 + 0.35 * power); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let g = RSQ_Glove(shot);
		if (!g) return damage;
		return damage * Mult(level, g.lastPower);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("soft", AsPercentIncrease(Mult(level, 0.0)));
		fields.Insert("hard", AsPercentIncrease(Mult(level, 1.0)));
	}
}

// ONE-TWO: left, right, left -- each alternating hit inside half a second adds to the next.
class RSQ_Upgrade_OneTwo : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv, int chain) { return 1.0 + 0.15 * lv * clamp(chain - 1, 0, 4); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let g = RSQ_Glove(shot);
		if (!g) return damage;
		return damage * Mult(level, g.lastChain);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.15 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 5)));
	}
}

// STAR PUNCH: clean hits bank stars (SuperPunchOut's rule); an uppercut with the trigger held
// spends one and launches what it hits.
class RSQ_Upgrade_StarPunch : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv) { return 2.0 + lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastStar) return damage;
		return damage * Mult(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastStar || !target || target.health <= 0 || target.bDontThrust) return;
		double mk = clamp(100.0 / max(target.mass, 1.0), 0.08, 2.0);
		target.vel.z += (8.0 + 2.0 * level) * mk;
		RSQ_Dazed.On(target).Stagger(35);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", string.format("x%d", Mult(level)));
	}
}

// COUNTERPUNCH: hit it while it winds up an attack -- it reels, and the punch lands harder.
class RSQ_Upgrade_Counterpunch : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv) { return 1.25 + 0.25 * lv; }
	static int Tics(uint lv) { return 17 + 9 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastCounter) return damage;
		return damage * Mult(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastCounter || !Monster(target)) return;
		RSQ_Dazed.On(target).Stagger(Tics(level));
		target.A_StartSound("rsq/counter", CHAN_AUTO, 0, 1.0);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(Tics(level)));
	}
}

// BODY BLOW: a hit below the chest winds it -- every move it makes is slower for a while.
class RSQ_Upgrade_BodyBlow : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static int Tics(uint lv) { return 35 + 18 * lv; }
	static double Factor(uint lv) { return min(0.4 + 0.15 * lv, 1.0); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastBody || !Monster(target)) return;
		RSQ_Dazed.On(target).Wind(Tics(level), Factor(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", AsSeconds(Tics(level)));
		fields.Insert("slow", AsPercent(Factor(level) * 0.5));
	}
}

// KNOCKDOWN: enough punishment inside two seconds puts it on the floor for a count.
class RSQ_Upgrade_Knockdown : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Share(uint lv) { return max(0.5 - 0.06 * lv, 0.15); }
	static int Count(uint lv) { return min(2 + lv, 8); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!RSQ_Glove(shot) || !Monster(target) || target.bBoss) return;
		let dz = RSQ_Dazed.On(target);
		if (dz.IsDown()) return;
		dz.NoteHit(damage);
		if (dz.RecentDamage(70) >= target.GetSpawnHealth() * Share(level)) dz.KnockDown(Count(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("share", AsPercent(Share(level)));
		fields.Insert("count", string.format("%d", Count(level)));
	}
}
