// TEST ONLY (scratch, GBOVR rig pass 2026-11-11): readouts and a card picker for RSQ Gun Bonsai VR's own screens.
// The picker presses Enter on the open level-up menu (RSQUI_LevelUpMenu.MenuEvent), the same path a player's Enter takes.
class GBP_Probe : EventHandler
{
	PlayerPawn P() { return players[consoleplayer].mo; }

	static clearscope String TreeOf(TFLV_Upgrade_BaseUpgrade u)
	{
		if (!u) return "none";
		String cn = u.GetClassName();
		if (cn.Left(12) != "RSQ_Upgrade_") return "stock";
		if (u is "RSQ_HookPerk") return "Grapple";
		if (u is "RSQ_RigPerk") return "Gunslinger";
		if (u is "RSQ_SlowPerk") return "SlowMo";
		if (u is "RSQ_KRPerk") return "KillRewards";
		if (u is "RSQ_CritPerk") return "CriticalHits";
		if (u is "RSQ_DualPerk" || u is "RSQ_Upgrade_Evasion" || u is "RSQ_Upgrade_Southpaw" || u is "RSQ_Upgrade_SteadyAim") return "TwoHandsBody";
		if (u is "RSQ_GuardPerk" || u is "RSQ_Upgrade_Guard") return "Guard";
		if (u is "RSQ_GrabPerk") return "Grab(retired)";
		if (u is "RSQ_Upgrade_SaberMarker") return "Saber";
		if (u is "RSQ_Upgrade_ShieldMarker") return "ShieldSaw";
		if (u is "RSQ_Upgrade_WhipMarker") return "Whip";
		if (u is "RSQ_Upgrade_GrenadeMarker") return "Grenade";
		if (u is "RSQ_Upgrade_Lunge" || u is "RSQ_Upgrade_Executioner" || u is "RSQ_Upgrade_Adrenaline") return "Melee";
		return "Fists";
	}

	static clearscope String Bag(TFLV_Upgrade_UpgradeBag b)
	{
		if (!b) return "(no bag)";
		String s = "";
		for (int i = 0; i < b.upgrades.Size(); i++)
		{
			let u = b.upgrades[i];
			if (u) s = s .. String.Format("%s:%d%s[%s] ", u.GetClassName(), u.level, u.enabled ? "" : "(off)", TreeOf(u));
		}
		return s == "" ? "(empty)" : s;
	}

	Weapon FindW(String cn)
	{
		let p = P();
		for (let i = p.Inv; i; i = i.Inv) { let w = Weapon(i); if (!w) continue; String wn = w.GetClassName(); if (wn ~== cn) return w; }
		return null;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		let p = P();
		if (!p) return;
		let st = TFLV_PerPlayerStats.GetStatsFor(p);
		if (e.Name ~== "gbp_bag")
		{
			if (!st) { Console.Printf("GBP BAG no stats"); return; }
			Console.Printf("GBP BAG tag %d player level %d xp %d upgrades %s", e.Args[0], st.level, st.XP, Bag(st.upgrades));
			for (int i = 0; i < st.weapons.Size(); i++)
			{
				let w = st.weapons[i];
				if (!w) continue;
				Console.Printf("GBP BAG tag %d  %s lv %d xp %.0f/%.0f hand %d upgrades %s", e.Args[0], w.wpnClass, w.level, w.XP, w.maxXP,
					w.wpn ? st.HandHolding(w.wpn) : -9, Bag(w.upgrades));
			}
			return;
		}
		if (e.Name ~== "gbp_hands")
		{
			String s = "";
			for (int h = 0; h <= 1; h++) { let w = st ? st.WeaponForHand(h) : null; s = s .. String.Format("hand%d=%s ", h, w ? String.Format("%s", w.GetClassName()) : "none"); }
			Console.Printf("GBP HANDS t%d %s ready %s", level.maptime, s, p.player.ReadyWeapon ? String.Format("%s", p.player.ReadyWeapon.GetClassName()) : "none");
			return;
		}
		if (e.Name.Left(7) ~== "gbp_xp:")   // gbp_xp:<Class> n: exactly enough XP for n levels on that weapon's record
		{
			let w = FindW(e.Name.Mid(7));
			if (!w || !st) { Console.Printf("GBP XP %s: not carried", e.Name.Mid(7)); return; }
			let info = st.GetOrCreateInfoFor(w);
			if (!info) { Console.Printf("GBP XP %s: no record", e.Name.Mid(7)); return; }
			int n = max(1, e.Args[0]);
			double need = 0;
			for (int j = 0; j < n; j++) need += info.GetXPForLevel(info.level + 1 + j);
			need -= info.XP;
			need += 1;
			info.AddXP(need);
			Console.Printf("GBP XP t%d %s +%.0f -> lv %d xp %.0f/%.0f pending %d hand %d", level.maptime, w.GetClassName(), need, info.level, info.XP, info.maxXP, info.CountPendingLevels(), st.HandHolding(w));
			return;
		}
		if (e.Name.Left(10) ~== "gbp_start:")   // the record's own StartLevelUp (for a weapon in no hand)
		{
			let w = FindW(e.Name.Mid(10));
			let info = (w && st) ? st.GetOrCreateInfoFor(w) : null;
			bool ok = info ? info.StartLevelUp() : false;
			Console.Printf("GBP START t%d %s -> %d", level.maptime, e.Name.Mid(10), ok);
			return;
		}
	}

	// ---- ui: the picker, the status cursor, the option-menu scroller, the shield band ----
	ui Menu lastM;
	ui int openFor;
	ui Array<String> done;
	ui String lastBand;

	ui int CV(String n) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetInt() : -1; }

	override void UiTick()
	{
		let m = Menu.GetCurrentMenu();
		if (m != lastM)
		{
			lastM = m; openFor = 0;
			Console.Printf("GBP MENU %s", m ? String.Format("open %s", m.GetClassName()) : "closed");
		}
		else openFor++;
		if (!m) return;

		let lu = RSQUI_LevelUpMenu(m);
		if (lu)
		{
			if (openFor == 1)
			{
				Console.Printf("GBP CARDS title \"%s\" player %d count %d", lu.title, lu.isPlayer, lu.Count());
				for (int i = 0; i < lu.Count(); i++)
				{
					let c = lu.Candidate(i);
					Console.Printf("GBP CARDS  [%d] %s \"%s\" tree %s owned %d", i, c ? String.Format("%s", c.GetClassName()) : "none", c ? c.GetName() : "", TreeOf(c), lu.Owned(i));
				}
			}
			int hold = CV("gbp_hold");
			if (hold >= 0 && openFor >= hold && !lu.picked && lu.Count() > 0)
			{
				int pick = -1;
				let wc = CVar.GetCVar("gbp_want", players[consoleplayer]);
				String want = wc ? wc.GetString() : "";
				for (int i = 0; i < lu.Count() && pick < 0 && want != ""; i++) if (TreeOf(lu.Candidate(i)) == want) pick = i;
				for (int i = 0; i < lu.Count() && pick < 0; i++) { String t = TreeOf(lu.Candidate(i)); if (t != "stock" && done.Find(t) == done.Size()) pick = i; }
				for (int i = 0; i < lu.Count() && pick < 0; i++) if (TreeOf(lu.Candidate(i)) != "stock") pick = i;
				if (pick < 0) pick = 0;
				let c = lu.Candidate(pick);
				String t = TreeOf(c);
				if (done.Find(t) == done.Size()) done.Push(t);
				lu.sel = pick;
				Console.Printf("GBP PICK \"%s\" [%d] %s tree %s (was level %d) by Enter", lu.title, pick, c.GetClassName(), t, lu.Owned(pick));
				lu.MenuEvent(Menu.MKEY_Enter, false);
			}
			return;
		}

		let sm = RSQUI_StatusMenu(m);
		if (sm)
		{
			if (openFor == 2)
			{
				Console.Printf("GBP STATUS rows %d, focus hand %d, menuHand %d", sm.rows.Size(), sm.curHand, sm.data.stats ? sm.data.stats.menuHand : -1);
				for (int i = 0; i < sm.rows.Size(); i++)
				{
					let r = sm.rows[i];
					let u = sm.RowUpgrade(r);
					Console.Printf("GBP STATUS  [%d] kind %d hand %d %s", i, r.kind, r.hand, u ? String.Format("%s lv %d%s", u.GetClassName(), u.level, u.enabled ? "" : " OFF") : (r.kind == 0 ? sm.data.hands[r.hand].tag : "?"));
				}
			}
			int want = CV("gbp_stat");
			if (want >= 0 && sm.rows.Size() > 0)
			{
				want = min(want, sm.rows.Size() - 1);
				if (sm.cur != want) { sm.cur = want; sm.Remember(); Console.Printf("GBP STATUS cursor -> %d", want); }
			}
			return;
		}

		let om = OptionMenu(m);
		int ms = CV("gbp_menusel");
		if (om && om.mDesc && ms >= 0)
		{
			if (ms >= 1000)
			{
				for (int i = 0; i < om.mDesc.mItems.Size(); i++)
				{
					let it = om.mDesc.mItems[i];
					Console.Printf("GBP OPT %s [%d] \"%s\" %s grey %d", om.mDesc.mMenuName, i, it.mLabel, it.GetClassName(), it.IsGrayed());
				}
				CVar.GetCVar("gbp_menusel", players[consoleplayer]).SetInt(-1);
				return;
			}
			int want = min(ms, om.mDesc.mItems.Size() - 1);
			if (om.mDesc.mSelectedItem != want) { om.mDesc.mSelectedItem = want; om.mDesc.mScrollPos = max(0, want - 6); }
		}
	}

	override void RenderOverlay(RenderEvent e)
	{
		let s = ServiceIterator.Find("RSQ_HudService").Next();
		int top = s ? s.GetIntUI("shield.gauge.top", "", 0, 0, null) : -9;
		int h = s ? s.GetIntUI("shield.gauge.h", "", 0, 0, null) : -9;
		int drop = s ? s.GetIntUI("shield.gauge.drop", "", 0, 0, null) : -9;
		double shift = RS_ScoreHUD.GaugeShift();
		String b = String.Format("dual %d shieldrow %d | shield.gauge.top %d h %d drop %d | Score GaugeShift %.3f", CV("bonsai_vr_dual_hud"), CV("rsq_hud_shield"), top, h, drop, shift);
		if (b != lastBand) { lastBand = b; Console.Printf("GBP BAND maptime %d %s", level.maptime, b); }
	}
}
