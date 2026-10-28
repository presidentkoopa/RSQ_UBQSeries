// THE SCREENS' MENUS, SHARED (10-27): what every skin's status and level-up screens do; the skins
// only draw. Controls are a thumbstick and one button (VR) or the keyboard:
//   level-up   left/right (or up/down) move between the cards, Enter picks, 1-9 pick directly,
//              Back refuses the level (Gun Bonsai's own rule: it costs the level's XP)
//   status     up/down walk the list (main gun, its abilities, off-hand gun, its abilities, the
//              player's upgrades); on an ability left/right change its level and Enter toggles it;
//              on a gun, right/Enter step into its abilities and left into the player's upgrades
// The choice goes back exactly as Gun Bonsai's own menus send it: bonsai-choose-level-up-option,
// bonsai-toggle-upgrade, bonsai-tune-upgrade.
class RSQUI_Menu : GenericMenu
{
	RSQUI_Pen pen;
	RSQUI_Data data;
	int openTic;

	override void Init(Menu parent)
	{
		super.Init(parent);
		DontDim = true;
		DontBlur = true;
		pen = RSQUI_Pen.Make();
		data = RSQUI_Data.Make();
		data.Read();
		openTic = MenuTime();
	}

	// pulse 0..1 for the selection glow
	double Pulse() { return 0.5 + 0.5 * sin(MenuTime() * 9.0); }
}

// ---- level-up ------------------------------------------------------------------------------------
class RSQUI_LevelUpMenu : RSQUI_Menu
{
	TFLV_UpgradeGiver giver;
	TFLV_Upgrade_UpgradeBag bag;   // what the gun (or the player) already has
	String title;
	bool isPlayer;
	int sel;
	bool picked;

	virtual bool ForPlayer() { return false; }

	override void Init(Menu parent)
	{
		super.Init(parent);
		isPlayer = ForPlayer();
		let st = data.stats;
		giver = st ? st.currentEffectGiver : null;
		if (isPlayer)
		{
			let pg = TFLV_PlayerUpgradeGiver(giver);
			if (pg) bag = pg.stats.upgrades;
			title = String.Format("LEVEL %d", data.plvl + 1);
		}
		else
		{
			let wg = TFLV_WeaponUpgradeGiver(giver);
			if (wg && wg.wielded)
			{
				bag = wg.wielded.upgrades;
				title = wg.wielded.wpn ? wg.wielded.wpn.GetTag() : wg.wielded.wpnClass;
			}
		}
		sel = 0;
	}

	int Count() { return giver ? giver.candidates.Size() : 0; }

	TFLV_Upgrade_BaseUpgrade Candidate(int i)
	{
		if (!giver || i < 0 || i >= giver.candidates.Size()) return null;
		return giver.candidates[i];
	}

	// the level this candidate has now (0 = new)
	int Owned(int i)
	{
		let c = Candidate(i);
		return (c && bag) ? bag.Level(c.GetClassName()) : 0;
	}

	void Pick(int i)
	{
		if (picked || i < 0 || i >= Count()) return;
		picked = true;
		MenuSound("menu/choose");
		EventHandler.SendNetworkEvent("bonsai-choose-level-up-option", i);
		Close();
	}

	override void Ticker()
	{
		super.Ticker();
		// The giver went away (inventory eaten, a load): nothing to choose from any more.
		if (!picked && (!giver || giver.bDestroyed)) Close();
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		int n = Count();
		switch (mkey)
		{
		case MKEY_Left:
		case MKEY_Up:
			if (n > 0) { sel = (sel + n - 1) % n; MenuSound("menu/cursor"); }
			return true;
		case MKEY_Right:
		case MKEY_Down:
			if (n > 0) { sel = (sel + 1) % n; MenuSound("menu/cursor"); }
			return true;
		case MKEY_PageUp:
			sel = max(0, sel - 4); return true;
		case MKEY_PageDown:
			sel = min(max(0, n - 1), sel + 4); return true;
		case MKEY_Enter:
			Pick(sel);
			return true;
		case MKEY_Back:
			// Gun Bonsai's rule: leaving the level-up menu refuses the level.
			if (!picked)
			{
				picked = true;
				EventHandler.SendNetworkEvent("bonsai-choose-level-up-option", -1);
			}
			return super.MenuEvent(mkey, fromcontroller);
		}
		return super.MenuEvent(mkey, fromcontroller);
	}

	override bool OnUIEvent(UIEvent ev)
	{
		if (ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_Char)
		{
			int c = ev.KeyChar;
			if (c >= 0x31 && c <= 0x39)
			{
				int i = (sel / 4) * 4 + (c - 0x31);
				if (c - 0x31 < 4 && i < Count()) { sel = i; Pick(i); return true; }
			}
		}
		return super.OnUIEvent(ev);
	}

	// first card shown: pages of four
	int PageStart() { return (sel / 4) * 4; }
}

class RSQUI_WeaponLevelUpMenu : RSQUI_LevelUpMenu {}
class RSQUI_PlayerLevelUpMenu : RSQUI_LevelUpMenu { override bool ForPlayer() { return true; } }

// ---- status --------------------------------------------------------------------------------------
// A row the cursor can stand on.
class RSQUI_Row ui
{
	int kind;   // 0 gun card, 1 gun ability, 2 player upgrade
	int hand;   // 0 main, 1 off (kind 0/1)
	int index;  // into the bag (kind 1/2)
}

class RSQUI_StatusMenu : RSQUI_Menu
{
	Array<RSQUI_Row> rows;
	int cur;           // index into rows
	int curKind, curHand, curIndex;   // the cursor by identity, so a rebuild keeps it
	int sentHand;

	override void Init(Menu parent)
	{
		super.Init(parent);
		sentHand = -2;
		curKind = 0; curIndex = 0;
		// Show Info already stepped Gun Bonsai's menuHand: start on that gun.
		curHand = (data.stats && data.stats.menuHand == 1 && data.hands[1].valid) ? 1 : 0;
		if (!data.hands[curHand].valid) curHand = 1 - curHand;
		Rebuild();
	}

	void AddRow(int k, int h, int i)
	{
		let r = new("RSQUI_Row");
		r.kind = k; r.hand = h; r.index = i;
		rows.Push(r);
	}

	void Rebuild()
	{
		rows.Clear();
		for (int h = 0; h <= 1; h++)
		{
			let hd = data.hands[h];
			if (!hd.valid) continue;
			if (h == 1 && data.hands[0].valid && hd.info == data.hands[0].info) continue;
			AddRow(0, h, 0);
			if (hd.bag) for (int i = 0; i < hd.bag.upgrades.Size(); i++) AddRow(1, h, i);
		}
		if (data.pbag) for (int i = 0; i < data.pbag.upgrades.Size(); i++) AddRow(2, 0, i);
		cur = 0;
		for (int i = 0; i < rows.Size(); i++)
		{
			let r = rows[i];
			if (r.kind == curKind && (r.kind == 2 || r.hand == curHand) && (r.kind == 0 || r.index == curIndex)) { cur = i; break; }
		}
		Remember();
	}

	void Remember()
	{
		if (cur < 0 || cur >= rows.Size()) return;
		let r = rows[cur];
		curKind = r.kind; curIndex = r.index;
		if (r.kind != 2) curHand = r.hand;
	}

	RSQUI_Row Row() { return (cur >= 0 && cur < rows.Size()) ? rows[cur] : null; }

	// the gun the screen is on (the last gun the cursor touched)
	int FocusHand() { return curHand; }

	TFLV_Upgrade_BaseUpgrade RowUpgrade(RSQUI_Row r)
	{
		if (!r) return null;
		if (r.kind == 1)
		{
			let b = data.hands[r.hand].bag;
			return (b && r.index < b.upgrades.Size()) ? b.upgrades[r.index] : null;
		}
		if (r.kind == 2)
			return (data.pbag && r.index < data.pbag.upgrades.Size()) ? data.pbag.upgrades[r.index] : null;
		return null;
	}

	// Gun Bonsai's weapon toggles act on PerPlayerStats.menuHand: point it at our gun first.
	void SendHand(int h)
	{
		if (h == sentHand) return;
		sentHand = h;
		EventHandler.SendNetworkEvent("rsqui-menu-hand", h);
	}

	override void Ticker()
	{
		super.Ticker();
		data.Read();
		Rebuild();
		if (!data.stats || (!data.hands[0].valid && !data.hands[1].valid)) Close();
	}

	void Move(int d)
	{
		int n = rows.Size();
		if (n == 0) return;
		cur = (cur + d + n) % n;
		Remember();
		MenuSound("menu/cursor");
	}

	void JumpTo(int kind, int hand)
	{
		for (int i = 0; i < rows.Size(); i++)
			if (rows[i].kind == kind && (kind == 2 || rows[i].hand == hand)) { cur = i; Remember(); MenuSound("menu/cursor"); return; }
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		let r = Row();
		switch (mkey)
		{
		case MKEY_Up: Move(-1); return true;
		case MKEY_Down: Move(1); return true;
		case MKEY_Left:
		case MKEY_Right:
		{
			int d = mkey == MKEY_Left ? -1 : 1;
			if (r && r.kind != 0)
			{
				if (r.kind == 1) SendHand(r.hand);
				MenuSound("menu/change");
				EventHandler.SendNetworkEvent("bonsai-tune-upgrade", r.kind == 1 ? 1 : 0, r.index, d);
			}
			else if (r)
			{
				if (d > 0) JumpTo(1, r.hand); else JumpTo(2, 0);
			}
			return true;
		}
		case MKEY_Enter:
			if (r && r.kind != 0)
			{
				if (r.kind == 1) SendHand(r.hand);
				MenuSound("menu/choose");
				EventHandler.SendNetworkEvent("bonsai-toggle-upgrade", r.kind == 1 ? 1 : 0, r.index);
			}
			else if (r) JumpTo(1, r.hand);
			return true;
		}
		return super.MenuEvent(mkey, fromcontroller);
	}

	// The cursor's text for the description box: the ability's description and its numbers.
	String RowDescription(RSQUI_Row r)
	{
		let up = RowUpgrade(r);
		if (up)
		{
			String s = up.GetDesc();
			String tt = up.GetTooltip(up.level);
			if (tt != "") s = s .. "\n" .. tt;
			return s;
		}
		if (r && r.kind == 0)
		{
			let h = data.hands[r.hand];
			if (h.valid && h.wpn) return String.Format("%s (%s)", h.tag, h.wpn.GetClassName());
		}
		return "";
	}
}
