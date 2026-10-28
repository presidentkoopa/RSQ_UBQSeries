// THE SABERS' UPGRADE PATH (UltraBadassQuestSaber: UBQS_Saber, UBQS_SaberOff).
//
// Most of these change the saber's own behaviour, so the saber does the work: it asks
// RSQ_MeleeUpgradeService for its level by name ("level", "<short name>", weapon) and these
// classes are what Gun Bonsai offers, stores and shows. Without this patch the saber reads 0
// for everything and is exactly as it was.

class RSQ_Upgrade_SaberMarker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info); }
}

// MOMENTUM: damage builds while the blade keeps moving, and drops back when it stops.
// (UBQS_SaberBase.MomentumTick / UpgCutMult: +10% a level per half second of motion, up to 2 s)
class RSQ_Upgrade_Momentum : RSQ_Upgrade_SaberMarker
{
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.10 * level));
		fields.Insert("max", AsPercentIncrease(1.0 + 0.40 * level));
	}
}

// RIPOSTE EDGE: a block primes the blade; the next cut inside the window does x1.5 (+0.25 a level).
class RSQ_Upgrade_RiposteEdge : RSQ_Upgrade_SaberMarker
{
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", string.format("x%.2f", 1.5 + 0.25 * (level - 1)));
		fields.Insert("time", AsSeconds(35 + 17 * (level - 1)));
	}
}

// PIERCING RETURN: a returned bolt goes through the first body it meets (one more per level).
class RSQ_Upgrade_PiercingReturn : RSQ_Upgrade_SaberMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// SABER THROW: when its route is done, the thrown saber finds one more enemy per level.
class RSQ_Upgrade_SaberThrow : RSQ_Upgrade_SaberMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// CHAIN CHOKE: a Force-choke kill jumps the grip to the nearest enemy.
class RSQ_Upgrade_ChainChoke : RSQ_Upgrade_SaberMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsMeters(256 + 64 * level)); }
}

// DUAL HARMONY: cuts that alternate between your two sabers stack.
class RSQ_Upgrade_DualHarmony : RSQ_Upgrade_SaberMarker
{
	static double Mult(uint lv, int stack) { return 1.0 + 0.10 * lv * stack; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!shot || !pawn || !pawn.player || !RSQM.IsSaberName(shot.GetClassName())) return damage;
		let h = RSQ_MeleeHandler.Get();
		if (!h) return damage;
		return damage * Mult(level, h.DualStackFor(pawn.PlayerNumber(), shot.GetClassName()));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.10 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 5)));
	}
}

// ---- THE FORCE (UBQS_Force: push, pull, choke, jump) -----------------------------------------
// With this patch loaded an unlearned power starts weaker (rsq_force_start, 60%); level 1 is
// the saber's own full strength and each level after adds to it -- and changes it:
class RSQ_Upgrade_ForcePush : RSQ_Upgrade_SaberMarker
{
	// 2+: the cone opens 10 degrees a level. 3+: it is a shockwave all round you as well.
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); }
}
class RSQ_Upgrade_ForcePull : RSQ_Upgrade_SaberMarker
{
	// 2+: what arrives is stunned. 3+: the pull yanks its weapon away (no ranged attacks).
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); }
}
class RSQ_Upgrade_ForceChoke : RSQ_Upgrade_SaberMarker
{
	// 2+: it lifts them and the grip crushes harder the longer you hold. 3+: it holds more than one.
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); fields.Insert("n", string.format("%d", max(1, level - 1))); }
}
class RSQ_Upgrade_ForceJump : RSQ_Upgrade_SaberMarker
{
	// 2+: landing from a Force jump is a slam that throws everything near you.
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); }
}
