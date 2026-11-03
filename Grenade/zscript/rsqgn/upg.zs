// RSQ Grenade -- THE GUN BONSAI VR PATCH, asked by name (RSQ_MeleeUpgradeService). This mod names no class of the
// patch: absent, Svc() is null, every level reads 0, and the grenade is exactly what it was. The levels live on the
// grenade weapon's own record (RSQGN_Grenade levels like a gun: its thrown grenades are claimed for it, hand.zs Throw);
// the tree is GBOVR_TREES.md 4.5, the numbers live with the upgrades ("upgrade.num").
class RSQGN_Upg play
{
	static Service Svc()
	{
		let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
		return it.Next();
	}
	static bool On() { return Svc() != null; }
	// the level of a node on this player's grenade (who: the pawn, or the grenade weapon itself)
	static int Lv(Actor who, String upgrade)
	{
		if (!who) return 0;
		let w = Weapon(who);
		if (!w) w = Weapon(who.FindInventory("RSQGN_Grenade"));
		if (!w) return 0;
		let s = Svc();
		return s ? max(0, s.GetInt("level", upgrade, 0, 0, w)) : 0;
	}
	static double Num(String what, int lv, double fb)
	{
		let s = Svc();
		return s ? s.GetDouble("upgrade.num", what, lv, 0) : fb;
	}
	// RSQ Score's combo ledger, by name (nothing without it)
	static void Touch(String id, Actor pawn, Actor victim)
	{
		if (!pawn || !pawn.player || !victim) return;
		let it = ServiceIterator.Find("RS_ScoreService");
		let s = it.Next();
		if (s) s.GetInt("touch", id, pawn.PlayerNumber(), 0, victim);
	}
}

// WHAT THE GRENADE TELLS OTHER MODS, by name. "cooked", objectArg = a thrown grenade: the tics it cooked in the hand before
// it was thrown, -1 for anything else (Gun Bonsai VR's Slow Burn). "fuse.count" / "fuse.amber", intArg = a player number:
// while the grenade in that player's hand cooks AND they have COOK SENSE 3 (Gun Bonsai VR patch), its whole seconds left /
// 1 for the fuse's first half (the amber flash), -1 otherwise (RSQ Gun Cards draws the count on the grenade's card).
class RSQGN_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "cooked")
		{
			let g = RSQGN_Thrown(objectArg);
			return g ? g.cooked : -1;
		}
		if (request == "fuse.count" || request == "fuse.amber")
		{
			let h = RSQGN_Handler.Get();
			int n = intArg;
			if (!h || n < 0 || n >= MAXPLAYERS || !playeringame[n] || !players[n].mo) return -1;
			let pmo = players[n].mo;
			if (!h.spoon[n] || RSQGN_Handler.HandOf(players[n]) < 0 || RSQGN_Upg.Lv(pmo, "CookSense") < 3) return -1;
			int fuse = RSQGN_Handler.FuseTics(pmo);
			int left = max(fuse - (level.maptime - h.cookTic[n]), 0);
			if (request == "fuse.amber") return left * 2 > fuse ? 1 : 0;
			return (left + TICRATE - 1) / TICRATE;
		}
		return 0;
	}
}
