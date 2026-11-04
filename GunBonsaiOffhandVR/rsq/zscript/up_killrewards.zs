// THE KILL REWARDS PATH (GBOVR_TREES.md 3.14 / 4.10; player nodes, credit SoM for the bits).
//
// Kill Rewards itself (the bits on a kill, rsqgb_kr_*, its menu page, the bit classes RSQ_KR*) moved to RSQ VisualRewards
// on 2026-11-03. These four nodes stay here, in Gun Bonsai's player bag, and nothing links between the two pk3s:
//   - VisualRewards reads each node's level by name (RSQ_MeleeUpgradeService "plevel" "BitScavenger" / "RichBits" /
//     "Magnet" / "LuckyKill") and does the effect; for Lucky Kill it asks back "kr.lucky" and "kr.luckyfx" (core.zs);
//   - here, a node is offered only while VisualRewards answers RSQVR_Service "kr.loaded" == 1. Without VisualRewards
//     Gun Bonsai VR loads and works as before, with no Kill Rewards and none of these four offered.
class RSQ_KRPerk : RSQ_Perk
{
	override int Cap() { return 3; }
	virtual String Parent() { return ""; }
	// VisualRewards' Kill Rewards is loaded (asked by name; nothing links)
	override bool ModLoaded()
	{
		let s = RSQM.Svc("RSQVR_Service");
		return s && s.GetInt("kr.loaded") == 1;
	}
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		String pa = Parent();
		return Super.IsSuitableForPlayer(stats) && (pa == "" || PHas(stats, pa));
	}
}
// BIT SCAVENGER, shown as "Gastropub" (owner 11-02) (root): +25% bits a kill a level.
class RSQ_Upgrade_BitScavenger : RSQ_KRPerk
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pct", string.format("%d%%", 25 * level)); }
}
// RICH BITS (after Bit Scavenger 1): a health or armour bit is worth 2, 3, 4 times; an ammo bit 8, 11, 14 rounds.
class RSQ_Upgrade_RichBits : RSQ_KRPerk
{
	override String Parent() { return "BitScavenger"; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("x", string.format("%d", 1 + level));
		fields.Insert("ammo", string.format("%d", 5 + 3 * level));
	}
}
// MAGNET (after Bit Scavenger 1): bits inside 2, 3, 4 m drift to you.
class RSQ_Upgrade_Magnet : RSQ_KRPerk
{
	override String Parent() { return "BitScavenger"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("m", string.format("%d", 1 + level)); }
}
// LUCKY KILL (after Rich Bits 1): a critical, a Finisher or a Score big moment drops double, triple, x4.
class RSQ_Upgrade_LuckyKill : RSQ_KRPerk
{
	override String Parent() { return "RichBits"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("x", string.format("%d", 1 + level)); }
}
