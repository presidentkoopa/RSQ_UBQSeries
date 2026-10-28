// THE SHIELDSAW'S UPGRADE PATH (RSQ_ShieldSaw: SSQ_ShieldSaw). Like the saber's, the
// ShieldSaw asks for its levels by name and does the work; Rebound is the one done here.

class RSQ_Upgrade_ShieldMarker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info); }
}

// RICOCHET: the thrown disc bounces off a wall toward a new target, one more per level.
class RSQ_Upgrade_Ricochet : RSQ_Upgrade_ShieldMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// MEAT GRINDER: a kill while embedded frees the disc to fly straight to its next lock at full
// speed (2+: or to a new target if there is none); the grind is 25% harder per level after 1.
class RSQ_Upgrade_MeatGrinder : RSQ_Upgrade_ShieldMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("grind", AsPercentIncrease(1.0 + 0.25 * (level - 1))); }
}

// HUNTER'S RETURN: on the way home the disc swerves through enemies near its path.
class RSQ_Upgrade_HuntersReturn : RSQ_Upgrade_ShieldMarker
{
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("n", string.format("%d", level));
		fields.Insert("r", AsMeters(160 + 32 * level));
	}
}

// BULWARK: a wider perfect-block window -- a slower plate still counts as meeting the shot.
class RSQ_Upgrade_Bulwark : RSQ_Upgrade_ShieldMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("need", AsPercent(1.0 / (1.0 + 0.35 * level))); }
}

// REBOUND: shots the shield turns hit harder.
class RSQ_Upgrade_Rebound : RSQ_Upgrade_ShieldMarker
{
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

// BATTERING RAM: a bashed monster flies into others, and the collision hurts both.
class RSQ_Upgrade_BatteringRam : RSQ_Upgrade_ShieldMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("dmg", string.format("%d+", 6 + 4 * level)); }
}
