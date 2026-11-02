// THE SHIELDSAW'S UPGRADE PATH (RSQ_ShieldSaw: SSQ_ShieldSaw). Like the saber's, the
// ShieldSaw asks for its levels by name and does the work; Rebound is the one done here.

class RSQ_Upgrade_ShieldMarker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info); }
}

// RICOCHET: the thrown disc bounces off a wall toward a new target, one more per level. (4.3 Throw, after Lockstep 1)
class RSQ_Upgrade_Ricochet : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Lockstep") && LevelOf(info, "Ricochet") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// MEAT GRINDER: a kill while embedded frees the disc to fly straight to its next lock at full
// speed (2+: or to a new target if there is none); the grind is 25% harder per level after 1. (After Hunter's Return 1)
class RSQ_Upgrade_MeatGrinder : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "HuntersReturn") && LevelOf(info, "MeatGrinder") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("grind", AsPercentIncrease(1.0 + 0.25 * (level - 1))); }
}

// HUNTER'S RETURN: on the way home the disc swerves through enemies near its path. (After Ricochet 1)
class RSQ_Upgrade_HuntersReturn : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Ricochet") && LevelOf(info, "HuntersReturn") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("n", string.format("%d", level));
		fields.Insert("r", AsMeters(160 + 32 * level));
	}
}

// WALL BOUNCES (4.3 Throw, after Ricochet 2): the walls a thrown disc bounces off on its way to its marks, the
// ShieldSaw's Wall Bounces row (3) and one more a level. (SSQ_Disc.Begin)
class RSQ_Upgrade_WallBounces : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Ricochet", 2) && LevelOf(info, "WallBounces") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", 3 + level)); }
}

// CLEAVER (4.3 Throw, after Meat Grinder 1): the hit tiers rise. Cut in two at or under 70 -> 100, 140, 200; stuck and
// ground at or under 600 -> 800, 1000, 1200. The same shares apply to Brutal Doom v22's tiers. (SSQ_Disc, the hit)
class RSQ_Upgrade_Cleaver : RSQ_Upgrade_ShieldMarker
{
	static double Fodder(uint lv) { static const double f[] = { 1.0, 100.0 / 70.0, 2.0, 200.0 / 70.0 }; return f[clamp(int(lv), 0, 3)]; }
	static double Mid(uint lv) { static const double m[] = { 1.0, 800.0 / 600.0, 1000.0 / 600.0, 2.0 }; return m[clamp(int(lv), 0, 3)]; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "MeatGrinder") && LevelOf(info, "Cleaver") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("cut", string.format("%d", int(70 * Fodder(level) + 0.5)));
		fields.Insert("grind", string.format("%d", int(600 * Mid(level) + 0.5)));
	}
}

// BULWARK: a wider perfect-block window -- a slower plate still counts as meeting the shot. (4.3 Block, after Broadening 1)
class RSQ_Upgrade_Bulwark : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Broadening") && LevelOf(info, "Bulwark") < 4; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("need", AsPercent(1.0 / (1.0 + 0.35 * level))); }
}

// REBOUND: shots the shield turns hit harder. (After Bulwark 1)
class RSQ_Upgrade_Rebound : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Bulwark") && LevelOf(info, "Rebound") < 4; }
	static double Mult(uint lv) { return 1.1 + 0.15 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		// the ShieldSaw remembers what it turned (SSQ_ScoreService "returned", asked by name);
		// a turned missile is paid to the shield because the shield sets its master
		if (!shot || !shot.bMissile) return damage;
		let it = ServiceIterator.Find("SSQ_ScoreService");
		let svc = it.Next();
		if (!svc || svc.GetInt("returned", "", 0, 0, shot) < 0) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// BACK PLATE (4.3 Block, after Broadening 2): the shield on your back blocks (1), and turns shots too (2). Under this
// patch it replaces the ShieldSaw's Block While Holstered row. (SSQ_Guard.BackPlate)
class RSQ_Upgrade_BackPlate : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Broadening", 2) && LevelOf(info, "BackPlate") < 2; }
}

// SHIELD WALL (4.3 Block, after Bulwark 2): a perfect block slows time 0.5 + 0.25 s a level through RSQ SlowMo. Under this
// patch it replaces the ShieldSaw's Perfect-Block Slow-Mo row. (SSQ_Guard.ShieldWallMs)
class RSQ_Upgrade_ShieldWall : RSQ_Upgrade_ShieldMarker
{
	static int Ms(uint lv) { return lv > 0 ? 500 + 250 * int(lv) : 0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Bulwark", 2) && LevelOf(info, "ShieldWall") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", string.format("%.2f s", Ms(level) / 1000.0)); }
}

// REFLECT (4.3 Block, after Rebound 2): a bullet the shield stops and sends back does x1.5, x2 (on top of the ShieldSaw's
// Returned Bullet Damage row, and of Rebound). (SSQ_Guard.StopsHitscan)
class RSQ_Upgrade_Reflect : RSQ_Upgrade_ShieldMarker
{
	static double Mult(uint lv) { return 1.0 + 0.5 * min(int(lv), 2); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && Has(info, "Rebound", 2) && LevelOf(info, "Reflect") < 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", string.format("x%.1f", Mult(level))); }
}

// BATTERING RAM: a bashed monster flies into others, and the collision hurts both.
class RSQ_Upgrade_BatteringRam : RSQ_Upgrade_ShieldMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("dmg", string.format("%d+", 6 + 4 * level)); }
}
