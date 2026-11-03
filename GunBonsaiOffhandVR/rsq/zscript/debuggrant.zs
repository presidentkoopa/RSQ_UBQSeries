// THE HEADSET PASS'S DEBUG (owner 2026-11-02: "option within GBOVR, Debug -> Add All, Add Incremental"). Our nodes
// (RSQ_Upgrade_*) on the player and on every weapon carried, through Gun Bonsai's own suitability tests, so the trees'
// parents and caps hold. ADD ALL: passes until nothing more is offered (every node at its cap). ADD INCREMENTAL: one
// pass, one level of every node offered now (press again to climb). Stock Gun Bonsai upgrades are never touched.
// The menu's two rows (menudef.rsq, Tuning and Debug) and the console: rsqgb_add_all, rsqgb_add_step (keyconf.txt).
class RSQ_DebugGrant : EventHandler
{
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqgb_dbg_all" && e.Name != "rsqgb_dbg_step") return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player] || !players[e.Player].mo) return;
		bool all = e.Name == "rsqgb_dbg_all";
		int n = Grant(players[e.Player].mo, all ? 40 : 1);
		Console.Printf("\c[Gold]RSQ Gun Bonsai VR:\c- debug %s: %d node level%s added", all ? "Add All" : "Add Incremental", n, n == 1 ? "" : "s");
	}

	static int Grant(PlayerPawn pmo, int passes)
	{
		let reg = TFLV_Upgrade_Registry.GetRegistry();
		let st = TFLV_PerPlayerStats.GetStatsFor(pmo);
		if (!reg || !st || !st.upgrades) return 0;
		// every weapon carried has its record (Gun Bonsai makes one on first sight; made here for the rest)
		Array<TFLV_WeaponInfo> infos;
		for (Inventory it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w) continue;
			let info = st.GetOrCreateInfoFor(w);
			if (info && infos.Find(info) == infos.Size()) infos.Push(info);
		}
		int added = 0;
		for (int pass = 0; pass < passes; pass++)
		{
			int now = 0;
			for (uint i = 0; i < reg.upgrades.Size(); i++)
			{
				let u = reg.upgrades[i];
				if (!u) continue;
				String cn = u.GetClassName();
				if (cn.Left(12) != "RSQ_Upgrade_") continue;
				if (u.IsSuitableForPlayer(st)) { st.upgrades.Add(cn, 1); now++; }
				for (int k = 0; k < infos.Size(); k++)
					if (infos[k].upgrades && u.IsSuitableForWeapon(infos[k])) { infos[k].upgrades.Add(cn, 1); now++; }
			}
			added += now;
			if (now == 0) break;
		}
		return added;
	}
}
