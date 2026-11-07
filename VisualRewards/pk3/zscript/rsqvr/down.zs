// RSQ VisualRewards -- RSQ SlowMo's DOWN v2 (owner-approved 2026-11-06 19:51, design/NEAR_DEATH.md: DOWN -> REVENGE ->
// REVIVE -> RAGE). SlowMo owns the mode and tells every service named "...RSQDownJoin" by name (its down.zs Tell); nothing
// links, and each mod still loads alone. What this mod shows (damnums/events.zs DownTime, DownWord; the skull: bar.zs):
//   "down.time"     "+0.5s" pops at the monster you hit, in the DOWN colour, on your time (Damage Numbers row)
//   "down.revenge"  REVENGE flies past on the level-up band, JFO, its own colour (the mark killed)
//   "down.revive"   REVIVE, the same, its own colour (the crate taken)
//   "down.rage"     RAGE, the same, its own colour
//   the mark        a skull over the marked monster's HP bar (Markers row), asked from the bar: RSQSM_Service "down.mark"
// Only the console player's own DOWN shows (netplay: each player sees his).
class RSQVR_RSQDownJoin : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQTHP_DamNumHandler.Get();
		if (!h || intArg != consoleplayer) return 0;
		if (request == "down.time") { h.DownTime(Actor(objectArg), stringArg); return 1; }
		let pmo = players[consoleplayer].mo;
		if (!pmo) return 0;
		if (request == "down.revenge") { h.DownWord(pmo, "REVENGE", RSQTHP_DamNumHandler.REVENGE_COL); return 1; }
		if (request == "down.revive")  { h.DownWord(pmo, "REVIVE", RSQTHP_DamNumHandler.REVIVE_COL); return 1; }
		if (request == "down.rage")    { h.DownWord(pmo, "RAGE", RSQTHP_DamNumHandler.RAGE_COL); return 1; }
		return 0;
	}
}
