// RSQ VisualRewards -- RSQ SlowMo's DOWN v3 (owner-approved 2026-11-07, design/NEAR_DEATH.md). SlowMo owns the mode and
// tells every service named "...RSQDownJoin" by name (its down.zs Tell); nothing links, and each mod still loads alone.
// What this mod shows (damnums/events.zs DownTime, DownWord; the bar: bar.zs; the bank: rsqvr/killrewards.zs):
//   "down.time"     "+0.4s" pops at the monster you hit, in the DOWN colour, on your time: the clock time that hit bought
//   "down.revenge"  REVENGE flies past on the level-up band, JFO, its own colour (a target killed by you)
//   "down.up"       REVIVE, every time you get up; its size, life and rise by the tier (stringArg "top" / "middle" /
//                   "bottom": x1.5 / x1.15 / x0.85)
//   "down.target"   a DOWN target: its HP bar is made now and kept up even if you never hit it (Aimed Only too); SlowMo
//                   draws the target's icon over it
// Only the console player's own DOWN shows (netplay: each player sees his). "down.revive" is now the TOP tier's extras
// (Tactical Rig's cigarette, Grenade's grenade): no word here (down.up says REVIVE every time).
class RSQVR_RSQDownJoin : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (intArg != consoleplayer) return 0;
		if (request == "down.target")
		{
			let bh = RSQTHP_Handler.Get();
			let m = Actor(objectArg);
			if (!bh || !m) return 0;
			bh.Ensure(m, false, m.health);
			return 1;
		}
		let h = RSQTHP_DamNumHandler.Get();
		if (!h) return 0;
		if (request == "down.time") { h.DownTime(Actor(objectArg), stringArg); return 1; }
		let pmo = players[consoleplayer].mo;
		if (!pmo) return 0;
		if (request == "down.revenge") { h.DownWord(pmo, "REVENGE", RSQTHP_DamNumHandler.REVENGE_COL); return 1; }
		if (request == "down.up")
		{
			double k = stringArg == "top" ? 1.5 : (stringArg == "middle" ? 1.15 : 0.85);
			h.DownWord(pmo, "REVIVE", RSQTHP_DamNumHandler.REVIVE_COL, false, k);
			return 1;
		}
		return 0;
	}
}
