// RSQ VisualRewards -- RSQ SlowMo's DOWN v3 (owner-approved 2026-11-07, design/NEAR_DEATH.md). SlowMo owns the mode and
// tells every service named "...RSQDownJoin" by name (its down.zs Tell); nothing links, and each mod still loads alone.
// What this mod shows (damnums/events.zs DownTime, DownWord; the bar: bar.zs; the bank: rsqvr/killrewards.zs):
//   "down.time"     "+0.4s" pops at the monster you hit, in the DOWN colour, on your time: the clock time that hit bought
//   "down.revenge"  REVENGE flies past on the level-up band, JFO, its own colour (a target killed by you)
//                   World words (2026-11-17, worldwords.zs; Reward Words row): REVENGE! over that monster as it dies and
//                   REVIVE! rising from the floor in front of you on "down.up"; In the World, no word on the band
//   "down.up"       REVIVE, every time you get up; its size, life and rise by the tier (stringArg "top" / "middle" /
//                   "bottom": x1.5 / x1.15 / x0.85); not when the REVIVE banner shows (2026-11-16, no doubling)
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
		// THE WORLD WORDS (owner 2026-11-17, worldwords.zs): REVENGE! over the monster that downed you (the DOWN target this
		// kill was: objectArg), REVIVE! rising from the floor where you get up. Reward Words In the World: not on the band.
		let fx = RSQVR_FxHandler.Get();
		int place = RSQVR_FxHandler.RewardPlace(consoleplayer);
		if (request == "down.revenge")
		{
			if (fx && place != RSQVR_FxHandler.RW_HUD && !fx.WorldWord("REVENGE!|over|low", 'magenta', consoleplayer, Actor(objectArg)))
				fx.WorldWord("REVENGE!|ahead|low", 'magenta', consoleplayer, pmo);     // the monster already gone: in front of you
			// (low, 2026-11-27: under the eye line, clear of RSQ Score's score line; worldwords.zs)
			if (place == RSQVR_FxHandler.RW_WORLD) return 1;
			h.DownWord(pmo, "REVENGE", RSQTHP_DamNumHandler.REVENGE_COL);
			return 1;
		}
		if (request == "down.up")
		{
			if (fx && place != RSQVR_FxHandler.RW_HUD) fx.WorldWord("REVIVE!|floor", 'cyan', consoleplayer, pmo);
			if (place == RSQVR_FxHandler.RW_WORLD) return 1;
			// NO DOUBLING WITH A BANNER (design/PRESENTATION_GUIDE.md 4b, owner 2026-11-16 06:10): when the REVIVE banner is
			// up or waiting for this player (RSQ SlowMo asks for it just before it says "down.up"), no REVIVE word on the
			// band; banners off or absent: the word, as before
			let bn = RSQVR_Banners.Get();
			let bc = CVar.GetCVar("rsqvr_banners", players[consoleplayer]);     // Banners off (this machine's own row): the word
			if (bn && (!bc || bc.GetBool()))
				for (int i = 0; i < bn.list.Size(); i++)
				{
					let b = bn.list[i];
					if (b && b.moment == RSQVR_Banners.M_REVIVE && (b.pn == consoleplayer || b.pn < 0)) return 1;
				}
			double k = stringArg == "top" ? 1.5 : (stringArg == "middle" ? 1.15 : 0.85);
			h.DownWord(pmo, "REVIVE", RSQTHP_DamNumHandler.REVIVE_COL, false, k);
			return 1;
		}
		return 0;
	}
}
