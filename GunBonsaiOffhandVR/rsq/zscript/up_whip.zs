// THE WHIP TREE (GBOVR_TREES.md 4.4; owner 11-02: Crack, Reach, Wrap, Lasso, Rope and the Fists link). Every node is on
// RSQ Whip's weapon (RSQWP_WhipWeapon); RSQ Whip asks their levels by name once a second (whip.zs GbRefresh) and owns
// every move. The numbers live with the moves (whip.zs, core.zs); the tooltips here say them.
class RSQ_Upgrade_WhipMarker : RSQ_Upgrade_Base
{
	static bool WhipInfo(TFLV_WeaponInfo info) { return info && info.wpnClass ~== "RSQWP_WhipWeapon"; }
	virtual int Cap() { return 3; }
	virtual String Parent() { return ""; }
	virtual int ParentLevel() { return 1; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		String pa = Parent();
		String me = GetClassName();
		return WhipInfo(info) && (pa == "" || Has(info, pa, ParentLevel())) && LevelOf(info, me.Mid(12)) < Cap();   // "RSQ_Upgrade_" is 12
	}
}

// ---- CRACK ---------------------------------------------------------------------------------------------------------
// STING (root): a crack does 25% more a level (12 -> 24 at 4).
class RSQ_Upgrade_Sting : RSQ_Upgrade_WhipMarker
{
	override int Cap() { return 4; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pct", AsPercentIncrease(1.0 + 0.25 * level)); }
}
// STUN (after Sting 1): the pain a crack causes is held 10 + 10 lv tics.
class RSQ_Upgrade_WhipStun : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "Sting"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(10 + 10 * level)); }
}
// CRACK SHOT (after Sting 2): a crack through a monster's missile blows it up; 2-3: and hurts what stands within 2, 2.5 m
// of it by the missile's own damage.
class RSQ_Upgrade_CrackShot : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "Sting"; }
	override int ParentLevel() { return 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("m", level >= 2 ? String.Format(" It hurts what stands within %.1f m of it.", 1.0 + 0.5 * level) : ""); }
}
// RETURN CRACK (after Crack Shot 1): the cracked missile goes back at its shooter instead, its damage x1 + 0.25 lv.
class RSQ_Upgrade_ReturnCrack : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "CrackShot"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(1.0 + 0.25 * level)); }
}
// STRIKE TRUE (after Sting 1): a crack freezes the monster 3, 4, 6 tics.
class RSQ_Upgrade_WhipStrikeTrue : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "Sting"; }
	override void GetTooltipFields(Dictionary fields, uint level) { static const int T[] = { 0, 3, 4, 6 }; fields.Insert("n", String.Format("%d", T[clamp(int(level), 0, 3)])); }
}

// ---- REACH ---------------------------------------------------------------------------------------------------------
// LONG THONG (root): the thong x1.25, 1.5, 1.75 (1.8 m -> 2.25, 2.7, 3.15 m); the lasso reaches 4x it.
class RSQ_Upgrade_LongThong : RSQ_Upgrade_WhipMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("m", String.Format("%.2f", 1.8 * (1.0 + 0.25 * level))); }
}
// QUICK MARK (after Long Thong 1): pickups and switches marked 2 m further a level; 3: a second pickup marked too, the
// crack fetching both. The reach it adds to is RSQ Whip's Whip Reach (rsqwp_target_reach, 3..60 m, 20 by default; read by
// name), as the whip's code does (whip.zs Mark: LockRange + 2 m a level). Until 11-10 the tooltip said a fixed 8 + 2 lv m.
class RSQ_Upgrade_QuickMark : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "LongThong"; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		let cv = CVar.FindCVar("rsqwp_target_reach");
		double reach = cv ? clamp(cv.GetFloat(), 3.0, 60.0) : 20.0;
		fields.Insert("m", String.Format("%g", reach + 2 * level));
		fields.Insert("two", level >= 3 ? " Two pickups are marked at once and one crack fetches both." : "");
	}
}

// ---- WRAP ----------------------------------------------------------------------------------------------------------
// HEAVY YANK (root): the mass under which a yanked monster flies to you 400 -> 600, 800, 1000.
class RSQ_Upgrade_HeavyYank : RSQ_Upgrade_WhipMarker
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", 400 + 200 * level)); }
}
// PULL AND PUNCH (after Heavy Yank 1; needs RSQ Melee): a yanked monster arrives staggered 17 + 9 lv tics, so the free
// hand's punch counts as a counter.
class RSQ_Upgrade_PullAndPunch : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "HeavyYank"; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Super.IsSuitableForWeapon(info) && RSQM.Has("RSQML_Service"); }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(17 + 9 * level)); }
}

// ---- LASSO ---------------------------------------------------------------------------------------------------------
// LASSO (root, the unlock): the off hand on the thong whirls it as a lasso; 2: a lassoed monster is held 50% longer.
class RSQ_Upgrade_Lasso : RSQ_Upgrade_WhipMarker { override int Cap() { return 2; } }
// BOLA (after Lasso 2): the lasso takes two monsters at once (2: three), swung and yanked together.
class RSQ_Upgrade_Bola : RSQ_Upgrade_WhipMarker
{
	override int Cap() { return 2; }
	override String Parent() { return "Lasso"; }
	override int ParentLevel() { return 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", 1 + level)); }
}

// ---- ROPE ----------------------------------------------------------------------------------------------------------
// SNAG (root, the unlock): a lash that catches an edge above the hand becomes a rope; 2: edges from the hand's height up.
class RSQ_Upgrade_Snag : RSQ_Upgrade_WhipMarker { override int Cap() { return 2; } }
// MANTLE (after Snag 1): reel up to a lip or lay a hand on it and go over; 2: from a swing too.
class RSQ_Upgrade_Mantle : RSQ_Upgrade_WhipMarker
{
	override int Cap() { return 2; }
	override String Parent() { return "Snag"; }
}
// MOMENTUM (after Snag 1): the swing's speed carries on landing; 2-3: the swing's speed cap 30 -> 36, 42.
class RSQ_Upgrade_WhipMomentum : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "Snag"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("cap", level >= 2 ? String.Format(" The swing's top speed is %d.", 30 + 6 * (level - 1)) : ""); }
}
// TARZAN (after Momentum 2): swinging into a monster at 3 m/s or more hurts it 10 + 10 lv x your speed share and knocks
// it flat.
class RSQ_Upgrade_Tarzan : RSQ_Upgrade_WhipMarker
{
	override String Parent() { return "WhipMomentum"; }
	override int ParentLevel() { return 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", 10 + 10 * level)); }
}
