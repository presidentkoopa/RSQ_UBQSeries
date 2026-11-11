// TEST ONLY (scratch, 2026-11-11): the Miniboss tier bonus and Smoker across a level change. Readouts and level setters.
class MBT_Probe : EventHandler
{
	PlayerPawn P() { return players[consoleplayer].mo; }
	static Service Svc(String n) { let it = ServiceIterator.Find(n); Service s; while (s = it.Next()) if (s.GetClassName() == n) return s; return null; }
	bool invWas; bool invKnown;
	override void WorldLoaded(WorldEvent e)
	{
		let p = P();
		if (p) Console.Printf("MBT LOADED %s t%d bINVULNERABLE %d", level.MapName, level.maptime, p.bINVULNERABLE);
	}
	override void WorldTick()
	{
		let p = P();
		if (!p) return;
		if (!invKnown || p.bINVULNERABLE != invWas)
		{
			Console.Printf("MBT INV t%d %s bINVULNERABLE %d", level.maptime, level.MapName, p.bINVULNERABLE);
			invWas = p.bINVULNERABLE; invKnown = true;
		}
	}
	override void WorldUnloaded(WorldEvent e)
	{
		let p = P();
		if (p) Console.Printf("MBT UNLOADED %s t%d bINVULNERABLE %d", level.MapName, level.maptime, p.bINVULNERABLE);
	}
	override void NetworkProcess(ConsoleEvent e)
	{
		let p = P();
		if (!p) return;
		let st = TFLV_PerPlayerStats.GetStatsFor(p);
		String n = e.Name;
		if (n ~== "mbt_plv")
		{
			if (!st) { Console.Printf("MBT PLV no stats"); return; }
			st.level = e.Args[0];
			Console.Printf("MBT PLV t%d player level set %d", level.maptime, st.level);
		}
		else if (n ~== "mbt_wlv")   // mbt_wlv hand level
		{
			if (!st) return;
			int h = e.Args[0];
			let info = st.CreateInfoForHand(h);
			if (!info) { Console.Printf("MBT WLV hand %d: no weapon / record", h); return; }
			info.level = e.Args[1];
			Console.Printf("MBT WLV t%d hand %d %s level set %d", level.maptime, h, info.wpn ? info.wpn.GetClassName() : 'none', info.level);
		}
		else if (n ~== "mbt_hands")
		{
			let gb = Svc("RSQGB_Service");
			String s = "";
			for (int h = 0; h <= 1; h++)
			{
				Weapon w = h == 1 ? p.player.OffhandWeapon : p.player.ReadyWeapon;
				s = s .. String.Format("hand%d=%s gb level %d; ", h, w ? String.Format("%s", w.GetClassName()) : "none", gb ? gb.GetInt("level", "", h, 0, p) : -9);
			}
			Console.Printf("MBT HANDS t%d tag %d %s player level %d", level.maptime, e.Args[0], s, gb ? gb.GetInt("player.level", "", 0, 0, p) : -9);
		}
		else if (n ~== "mbt_scan")   // the Bossfight's monsters and their colours (RSQ Monsters' own "tier")
		{
			let mb = Svc("RSQMB_Service"); let mn = Svc("RSQMN_RosterService");
			let it = ThinkerIterator.Create("Actor"); Actor a;
			String bs = "", ts = "";
			int nt = 0;
			while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0 && a.FindInventory("RSQMB_Called"))
			{
				bool isB = mb && mb.GetInt("miniboss", "", 0, 0, a) == 1;
				int t = mn ? mn.GetInt("tier", "", 0, 0, a) : -9;
				String one = String.Format("%s(tier %d)", a.GetClassName(), t);
				if (isB) bs = bs .. one .. " "; else { ts = ts .. one .. " "; nt++; }
			}
			Console.Printf("MBT SCAN t%d tag %d: MINIBOSS %s| %d thralls: %s", level.maptime, e.Args[0], bs == "" ? "none " : bs, nt, ts);
		}
		else if (n ~== "mbt_smoker")
		{
			if (!st || !st.upgrades) return;
			st.upgrades.Add("RSQ_Upgrade_Smoker", 1);
			Console.Printf("MBT SMOKER t%d added (player upgrades)", level.maptime);
		}
		else if (n ~== "mbt_inv")
			Console.Printf("MBT INVNOW t%d %s tag %d bINVULNERABLE %d health %d", level.maptime, level.MapName, e.Args[0], p.bINVULNERABLE, p.health);
	}
}
