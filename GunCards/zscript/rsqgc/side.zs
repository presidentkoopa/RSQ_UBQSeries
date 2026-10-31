// side.zs -- RSQ Gun Cards: THE WATCH CARD (owner 2026-10-31 02:47 / 03:00): the full card, flat on each side of the
// wrist, facing you when you check your watch knuckles up. The wrist is measured from Brutal Doom VR's hand mesh
// (tools/gen_side.py). Every row and column is baked, so the text sits exactly where it was laid out: the runtime
// only picks which glyph each spot shows and the panel height.
//
// Rows: 0 the gun's name (and the hand on the right), 1 MAGAZINE / RESERVE, 2 the counts (Ermac's digits), 3 Gun
// Bonsai level and XP, 4..7 upgrades (name, level), 8 "+N MORE". The panel is tinted the gun's colour.

class RSQGC_SideOp
{
	State st;
	int col;       // tint 0xRRGGBB, -1 none
}

class RSQGC_SideCard play
{
	const MAXL = 180;
	const BASE0 = 1001200;      // main hand 1001200.., off hand 1001400..; the other side +400
	Array<RSQGC_SideOp> ops;
	string sig;
	int hand;
	int side;                   // 0 / 1: the two sides of the wrist
	bool mir;
	int laid;
	int lastRow;

	void Clear() { ops.Clear(); lastRow = 0; }
	int Fam() { return side * 2 + (mir ? 1 : 0); }

	private void Add(State s, int col)
	{
		if (!s) return;
		let o = new("RSQGC_SideOp");
		o.st = s; o.col = col;
		ops.Push(o);
	}
	// text on a row from column c0
	void Text(int row, string s, int c0, int col = -1)
	{
		s = s.MakeUpper();
		int n = RSQGC_SideStates.FONT_COLS[RSQGC_SideStates.ROW_FONT[row]];
		for (int i = 0; i < int(s.Length()) && c0 + i < n; i++)
		{
			int ch = s.ByteAt(i);
			if (ch != 32) Add(RSQGC_SideStates.Glyph(row, Fam(), c0 + i, ch), col);
		}
		lastRow = max(lastRow, row);
	}
	void TextRight(int row, string s, int col = -1)
	{
		int n = RSQGC_SideStates.FONT_COLS[RSQGC_SideStates.ROW_FONT[row]];
		Text(row, s, max(0, n - s.Length()), col);
	}
	static int Cols(int row) { return RSQGC_SideStates.FONT_COLS[RSQGC_SideStates.ROW_FONT[row]]; }

	void Sync(PlayerInfo p, Actor owner, double alpha, double up, RSQGC_GunCard gc)
	{
		int base = BASE0 + hand * 200 + side * 400;
		int n = min(ops.Size(), MAXL);
		for (int i = 0; i < n; i++)
		{
			let o = ops[i];
			int id = base + i;
			let ps = p.FindPSprite(id);
			if (!ps || ps.Caller != owner || ps.CurState != o.st)
			{
				bool fresh = !ps || ps.Caller != owner;
				p.SetPSprite(id, o.st, false, owner);
				ps = p.FindPSprite(id);
				if (fresh) gc.Fresh(id);
			}
			if (!ps) continue;
			ps.bAddBob = false;
			ps.bAddWeapon = false;
			ps.x = 0;
			ps.y = 32 + up * 4;
			ps.alpha = alpha;
			ps.Translation = o.col >= 0 ? TranslationID(gc.TransFor(o.col)) : TranslationID(0);
		}
		for (int i = n; i < laid; i++)
			if (p.FindPSprite(base + i)) p.SetPSprite(base + i, null);
		laid = n;
	}
	void Remove(PlayerInfo p)
	{
		if (laid <= 0 && sig == "") return;
		int base = BASE0 + hand * 200 + side * 400;
		for (int i = 0; i < MAXL; i++) if (p.FindPSprite(base + i)) p.SetPSprite(base + i, null);
		laid = 0; sig = "";
	}

	// THE SMALL LINES (rows 3 on, tools/gen_side.py ROWS): filled in order, top down. -1 when the card is full.
	int nextLine;
	int Line()
	{
		if (nextLine >= RSQGC_SideStates.ROWS) return -1;
		return nextLine++;
	}
	// a line with a word on the left and a value on the right
	void Pair(string l, string r, int lc, int rc)
	{
		int row = Line();
		if (row < 0) return;
		Text(row, l, 0, lc);
		TextRight(row, r, rc);
	}
	// the panel: the smallest height that holds the last row used, laid FIRST so the text stands in front
	void Panel(int panelCol)
	{
		int need = RSQGC_SideStates.ROW_BOTTOM_PX[lastRow];
		int hi = 0;
		while (hi < RSQGC_SideStates.PANEL_H.Size() - 1 && RSQGC_SideStates.PANEL_H[hi] < need) hi++;
		let pnl = new("RSQGC_SideOp");
		pnl.st = RSQGC_SideStates.Panel(Fam(), hi); pnl.col = panelCol;
		if (pnl.st) ops.Insert(0, pnl);
	}

	void Build(PlayerPawn pmo, int hnd, Weapon w, int panelCol, RSQGC_GunCard gc)
	{
		Clear();
		nextLine = 3;
		Text(0, RSQGC_GunCard.NameOf(w), 0, 0xF0F0F0);
		TextRight(0, RSQGC_GunCard.HandTag(hnd), 0x9A9A9A);
		int loaded = RSQGC_GunCard.Loaded(w), reserve = RSQGC_GunCard.Reserve(w);
		// GC3: an empty magazine with rounds to load says RELOAD where MAGAZINE was, in the empty colour
		bool reload = RSQGC_GunCard.HasMagazine(w) && loaded == 0 && reserve > 0;
		Text(1, reload ? "RELOAD" : RSQGC_GunCard.HasMagazine(w) ? "MAGAZINE" : "AMMO", 0, reload ? 0xFF5A46 : 0xC8C8C8);
		if (reserve >= 0) TextRight(1, "RESERVE", 0xC8C8C8);
		Text(2, String.Format("%d", max(loaded, 0)), 0, loaded == 0 ? 0xFF5A46 : -1);
		// GC2: "+N" in the reserve's place for a moment after a pickup (on the right for a gun with no reserve)
		int plus = gc ? gc.PlusNow(hnd) : 0;
		if (plus > 0) TextRight(2, String.Format("+%d", clamp(plus, 1, 99)), 0x80E040);
		else if (reserve >= 0) TextRight(2, String.Format("%d", reserve), -1);
		// GC4: Brutal Doom's grenades (not the mines); GC7: this gun's kills this level
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0) Pair("GRENADES", String.Format("%d", gren), 0xC8C8C8, gren > 0 ? 0xF08030 : 0x707070);
		if (gc) Pair("KILLS", String.Format("%d", gc.KillsWith(w)), 0xC8C8C8, 0xF0F0F0);
		let e = RSQGC_Bonsai.Entry(pmo, w);
		if (e && e.lvl >= 0)
		{
			int row = Line();
			if (row >= 0)
			{
				int n = Cols(row);
				string lv = String.Format("LV %d ", e.lvl);
				int bars = n - lv.Length();
				int on = e.permille * bars / 1000;
				string bar = "";
				for (int i = 0; i < bars; i++) bar = bar .. (i < on ? "=" : "-");
				Text(row, lv .. bar, 0, 0xFFD678);
			}
			int shown = min(e.names.Size(), 4);
			for (int i = 0; i < shown; i++)
			{
				row = Line();
				if (row < 0) break;
				int colr = e.on[i] ? RSQGC_GunCard.ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070;
				string num = RSQGC_Bonsai.Numeral(e.levels[i]);
				int room = Cols(row) - num.Length() - 1;
				string nm = e.names[i].MakeUpper();
				if (int(nm.Length()) > room) nm = nm.Left(room);
				Text(row, nm, 0, colr);
				TextRight(row, num, colr);
			}
			if (e.names.Size() > shown) { row = Line(); if (row >= 0) Text(row, String.Format("+%d MORE", e.names.Size() - shown), 0, 0x9A9A9A); }
		}
		Panel(panelCol);
	}

	// GC5 THE STATUS CARD: the watch check with an empty hand. Health and armour big, the keys (cards on one line,
	// skulls on another, each its colour's initial in that colour), Brutal Doom's grenades, the level's kills.
	void BuildStatus(PlayerPawn pmo, int hnd, int panelCol, RSQGC_GunCard gc)
	{
		Clear();
		nextLine = 3;
		Text(0, "STATUS", 0, 0xF0F0F0);
		TextRight(0, RSQGC_GunCard.HandTag(hnd), 0x9A9A9A);
		Text(1, "HEALTH", 0, 0xC8C8C8);
		TextRight(1, "ARMOUR", 0xC8C8C8);
		int hp = max(pmo.Health, 0);
		let arm = pmo.FindInventory("BasicArmor");
		int ap = arm ? arm.Amount : 0;
		Text(2, String.Format("%d", hp), 0, hp <= 25 ? 0xFF5A46 : -1);
		TextRight(2, String.Format("%d", ap), 0x7CC4FF);   // armour in blue, so "100 100" reads as two numbers
		string cards = "", skulls = "";
		Array<int> cardCol, skullCol;
		int others = 0;
		for (let i = pmo.Inv; i; i = i.Inv)
		{
			if (!(i is "Key")) continue;
			string n = i.GetClassName();
			n = n.MakeLower();
			int c = -1; string l = "";
			if (n.IndexOf("red") >= 0) { c = 0xFF5040; l = "R"; }
			else if (n.IndexOf("blue") >= 0) { c = 0x60A0FF; l = "B"; }
			else if (n.IndexOf("yellow") >= 0) { c = 0xFFD040; l = "Y"; }
			if (c < 0) { others++; continue; }
			if (n.IndexOf("skull") >= 0) { skulls = skulls .. l; skullCol.Push(c); }
			else { cards = cards .. l; cardCol.Push(c); }
		}
		int row = Line();
		if (row >= 0)
		{
			Text(row, "KEYS", 0, 0xC8C8C8);
			string tail = others > 0 ? String.Format("+%d", others) : "";
			if (cards == "" && tail == "") TextRight(row, "-", 0x707070);
			int n = Cols(row) - int(tail.Length()) - (tail != "" ? 1 : 0);
			int at = n - (int(cards.Length()) * 2 - 1);
			for (int k = 0; k < int(cards.Length()); k++) Text(row, cards.Mid(k, 1), max(0, at + k * 2), cardCol[k]);
			if (tail != "") TextRight(row, tail, 0xC8C8C8);
		}
		if (skulls != "")
		{
			row = Line();
			if (row >= 0)
			{
				Text(row, "SKULLS", 0, 0xC8C8C8);
				int at = Cols(row) - (int(skulls.Length()) * 2 - 1);
				for (int k = 0; k < int(skulls.Length()); k++) Text(row, skulls.Mid(k, 1), max(0, at + k * 2), skullCol[k]);
			}
		}
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0) Pair("GRENADES", String.Format("%d", gren), 0xC8C8C8, gren > 0 ? 0xF08030 : 0x707070);
		Pair("KILLS", String.Format("%d/%d", level.killed_monsters, level.total_monsters), 0xC8C8C8, 0xF0F0F0);
		Panel(panelCol);
	}
}
