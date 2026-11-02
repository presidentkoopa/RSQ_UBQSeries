// THE FISTS TREE, the nodes new on 2026-11-02 (GBOVR_TREES.md section 4.1; every node kept by the owner, 11-02).
// The fourteen that existed before are in up_gloves.zs (their class names are kept for saves). Each fist is its own
// record, as before: a glove's upgrades apply to that glove's punches, and a node is offered to a glove only once that
// glove holds its parent (Has / PHas / LevelOf, up_gloves.zs RSQ_Upgrade_Base).
//
// WHO DOES WHAT. A node here is the upgrade: Gun Bonsai offering it, its level, its numbers. The move is RSQ Melee's;
// Melee asks this patch for a level ("level" / "unlocked" on RSQ_MeleeUpgradeService) and for the numbers
// ("upgrade.num", core.zs, which calls the static formulas below). A node that changes a punch's damage does it here,
// in ModifyDamageDealt, where the glove is the inflictor; it asks Melee about the punch through RSQML_Service by name.

// ---- A. POWER ------------------------------------------------------------------------------------------------------
// Heavy Hands (root) -> Haymaker -> Wallflower -> Knockdown; Heavy Hands 2 -> Body Blow -> Knockdown; the five below.

// a launch's height in metres for an imp-sized monster (mass 100): up map units a tic against gravity 1 a tic, the
// vertical x pixelstretch 1.2 at 34 units a metre. For the tooltips only.
class RSQ_FistMath
{
	static clearscope double LiftM(double up) { return up * up * 0.5 * 1.2 / 34.0; }
	static clearscope String Metres(double m) { return String.Format("%.1f m", m); }
}

// UPPERCUT (an unlock): without it, under Gun Bonsai VR, a rising punch is a jab and lifts nothing. Learned, a rising
// punch is an uppercut (the Super spark, the launch); levels 2 and 3 throw it higher.
class RSQ_Upgrade_Uppercut : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands") && LevelOf(info, "Uppercut") < 3; }
	// map units a tic of lift on top of the uppercut's own 5 to 9: none at level 1, +2 a level after
	static double Lift(uint lv) { return 2.0 * max(int(lv) - 1, 0); }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		// a half-speed uppercut (7 units a tic) on an imp, as the tree states it
		fields.Insert("high", RSQ_FistMath.Metres(RSQ_FistMath.LiftM(7.0 + Lift(level))));
	}
}

// LAUNCHER: what an uppercut lifts hangs in pain for the whole flight and staggers when it lands; it goes higher.
class RSQ_Upgrade_Launcher : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Uppercut", 2) && LevelOf(info, "Launcher") < 3; }
	static double Lift(uint lv) { return 3.0 * lv; }
	static int Stagger(uint lv) { return 10 + 10 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("high", RSQ_FistMath.Metres(RSQ_FistMath.LiftM(7.0 + RSQ_Upgrade_Uppercut.Lift(2) + Lift(level))));
		fields.Insert("time", AsSeconds(Stagger(level)));
	}
}

// JUGGLE: a punch on a monster you launched, inside 2 s, while it is still off the floor, hits harder and lifts it again
// (the re-lift is RSQ Melee's; the damage is here).
class RSQ_Upgrade_Juggle : RSQ_Upgrade_Base
{
	const WINDOW = 70;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher") && LevelOf(info, "Juggle") < 3; }
	static double Mult(uint lv) { return 1.5 + 0.25 * lv; }
	// tics since this player's uppercut launched it while it is still in the air, or -1 (RSQ Melee's "launch.age")
	static int LaunchAge(Actor pawn, Actor target)
	{
		let s = RSQM.Svc("RSQML_Service");
		if (!s || !pawn || !pawn.player || !target) return -1;
		return s.GetInt("launch.age", "", pawn.PlayerNumber(), 0, target);
	}
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!IsGlove(shot) || !Monster(target)) return damage;
		int age = LaunchAge(pawn, target);
		if (age < 0 || age > WINDOW) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(WINDOW));
	}
}

// METEOR: a launched monster that comes down on another hurts them both (RSQ Melee watches the fall).
class RSQ_Upgrade_Meteor : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher", 2) && LevelOf(info, "Meteor") < 3; }
	// fall = its downward speed when it hits, map units a tic
	static int Damage(uint lv, double fall) { return int(10 + 10 * lv + max(fall, 0.0)); }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("dmg", String.Format("%d", Damage(level, 0))); }
}

// GROUND POUND: both fists swung down hard together (RSQ Gestures' "both hands down", at GroundPound.speed or more): a
// shockwave round you. With Knockdown learned on that glove, what it hits that is no boss goes down for a count of 2.
class RSQ_Upgrade_GroundPound : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher", 3) && LevelOf(info, "GroundPound") < 3; }
	static double Radius(uint lv) { return 2.0 + 0.5 * lv; }     // metres
	static int Damage(uint lv) { return 20 + 10 * lv; }
	static double Speed() { return 3.0; }                        // m/s down, each hand
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("radius", RSQ_FistMath.Metres(Radius(level)));
		fields.Insert("dmg", String.Format("%d", Damage(level)));
	}
}

// CLEAR OUT (the owner's, 11-02: "a two hand, palm out shoving gesture to clear a wide area in front of you"): both
// palms thrust forward together (RSQ Gestures' "both palms thrust"): everything in a 90-degree wedge in front is shoved
// back hard, hurt, and staggered.
class RSQ_Upgrade_ClearOut : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands", 2) && LevelOf(info, "ClearOut") < 3; }
	static double Range(uint lv) { return 2.0 + 0.5 * lv; }      // metres
	static int Damage(uint lv) { return 10 + 5 * lv; }
	static double Push(uint lv) { return 12.0 + 2.0 * lv; }       // map units a tic, on a 100-mass monster
	static int Stagger() { return 10; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("range", RSQ_FistMath.Metres(Range(level)));
		fields.Insert("dmg", String.Format("%d", Damage(level)));
	}
}
