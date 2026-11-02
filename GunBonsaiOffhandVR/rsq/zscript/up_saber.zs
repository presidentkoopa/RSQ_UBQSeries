// THE SABERS' UPGRADE PATH (RSQ_Saber: UBQS_Saber, UBQS_SaberOff).
//
// Most of these change the saber's own behaviour, so the saber does the work: it asks
// RSQ_MeleeUpgradeService for its level by name ("level", "<short name>", weapon) and these
// classes are what Gun Bonsai offers, stores and shows. Without this patch the saber reads 0
// for everything and is exactly as it was.

class RSQ_Upgrade_SaberMarker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info); }
}

// MOMENTUM, shown as ELEGANT WEAPON (GBOVR_TREES.md 4.2 Blade, root; the class keeps its name for saves): damage builds
// while the blade keeps moving, and drops back when it stops. (UBQS_SaberBase.MomentumTick / UpgCutMult: +10% a level
// per half second of motion, up to 2 s)
class RSQ_Upgrade_Momentum : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "Momentum") < 4; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.10 * level));
		fields.Insert("max", AsPercentIncrease(1.0 + 0.40 * level));
	}
}

// RIPOSTE EDGE, shown as AGGRESSIVE NEGOTIATIONS (4.2 Blade, after Elegant Weapon 1): a block primes the blade; the next
// cut inside the window does x1.5 (+0.25 a level).
class RSQ_Upgrade_RiposteEdge : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Momentum") && LevelOf(info, "RiposteEdge") < 4; }
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

// SABER THROW: when its route is done, the thrown saber finds one more enemy per level. (4.2 Focus, after Battle
// Meditation 1.)
class RSQ_Upgrade_SaberThrow : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "BattleMeditation") && LevelOf(info, "SaberThrow") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// CHAIN CHOKE: a Force-choke kill jumps the grip to the nearest enemy.
// STRUCK BY THE OWNER (GBOVR_TREES.md 4.2, 11-02): no longer offered; a save that has it keeps it, and it still works.
class RSQ_Upgrade_ChainChoke : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return false; }
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

// ---- THE SABER TREE, new nodes (GBOVR_TREES.md 4.2; the owner kept every node, 11-02, names "Star-Warsy" at a
// film-goer's level). The saber does each move and asks its level by name (UBQS_Upg.Lv); its numbers come from
// "upgrade.num". SEVERAL OF THESE WERE THE SABER'S OWN BEHAVIOUR, and under Gun Bonsai VR they become unlocks, the way
// the Uppercut did on the gloves: without Gun Bonsai VR the saber is exactly what it was.

// ---- FOCUS (the marks) ----
// BATTLE MEDITATION: under Gun Bonsai VR a throw starts with one mark; each level adds one (5 at level 4, the saber's own
// default). The Lock-On Targets row is the saber's without the patch.
class RSQ_Upgrade_BattleMeditation : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "BattleMeditation") < 4; }
	static int Locks(uint lv) { return 1 + lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", Locks(level))); }
}
// SABER BARRAGE: the thrown saber cuts what it passes on its way home (an unlock under Gun Bonsai VR; it always did
// without it), for a share of a cut.
class RSQ_Upgrade_SaberBarrage : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "BattleMeditation", 2) && LevelOf(info, "SaberBarrage") < 3; }
	static double Share(uint lv) { return 0.5 + 0.15 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("share", AsPercent(Share(level))); }
}
// RETURNING BLADE: the thrown saber flies its marks again before it comes home (2: a third time).
class RSQ_Upgrade_ReturningBlade : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "SaberBarrage") && LevelOf(info, "ReturningBlade") < 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", level)); }
}

// ---- BLADE (the forms) ----
// STRIKE TRUE: a cut freezes what it hits for a beat (the Hit-Stop row's three settings as levels under Gun Bonsai VR).
class RSQ_Upgrade_StrikeTrue : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Momentum") && LevelOf(info, "StrikeTrue") < 3; }
	static int Tics(uint lv) { return lv >= 3 ? 6 : lv == 2 ? 4 : lv == 1 ? 3 : 0; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(Tics(level))); }
}
// KYBER ATTUNEMENT: the blade grows, 54 -> 65 -> 76 -> 88 -> 99 cm (the saber's five lengths as levels; the Blade Length
// row is the floor).
class RSQ_Upgrade_KyberAttunement : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Momentum", 2) && LevelOf(info, "KyberAttunement") < 4; }
	static int Cm(uint lv) { static const int C[] = { 54, 65, 76, 88, 99 }; return C[clamp(int(lv), 0, 4)]; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("cm", String.Format("%d cm", Cm(level))); }
}
// HIGH GROUND: a cut on a monster with little left cuts it apart (no bosses).
class RSQ_Upgrade_HighGround : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "RiposteEdge", 2) && LevelOf(info, "HighGround") < 3; }
	static double Share(uint lv) { return 0.20 + 0.05 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!shot || !RSQM.IsSaberName(shot.GetClassName()) || !Monster(target) || target.bBoss) return damage;
		if (target.health > RSQM.StartHealth(target) * Share(level)) return damage;
		// past its gib health, so it dies in pieces (its XDeath; Brutal Doom's own gib death)
		RSQM.Touch("sever", pawn, target);
		return max(damage, double(target.health - target.GetGibHealth() + 1) * 1.5);   // GetGibHealth is negative (-spawn health)
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("share", AsPercent(Share(level))); }
}

// ---- STAB ----
// POINT TAKEN: a stab driven in with your body (the head moving forward) hits much harder.
class RSQ_Upgrade_PointTaken : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "PointTaken") < 3; }
	static double Mult(uint lv) { return 2.0 + 0.25 * lv; }
	static double Speed() { return 0.8; }   // m/s, the head forward
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", String.Format("x%.2f", Mult(level))); }
}
// RUN THROUGH: a stabbed monster is held on the blade; pull the blade out and a monster with little left is finished.
class RSQ_Upgrade_RunThrough : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "PointTaken") && LevelOf(info, "RunThrough") < 3; }
	static int Tics(uint lv) { return int(17.5 + 8.75 * lv); }
	static double Finish() { return 0.15; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(Tics(level))); }
}
