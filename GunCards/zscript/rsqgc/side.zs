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

	void Build(PlayerPawn pmo, int hnd, Weapon w, int panelCol)
	{
		Clear();
		Text(0, RSQGC_GunCard.NameOf(w), 0, 0xF0F0F0);
		TextRight(0, RSQGC_GunCard.HandTag(hnd), 0x9A9A9A);
		int loaded = RSQGC_GunCard.Loaded(w), reserve = RSQGC_GunCard.Reserve(w);
		Text(1, RSQGC_GunCard.HasMagazine(w) ? "MAGAZINE" : "AMMO", 0, 0xC8C8C8);
		if (reserve >= 0) TextRight(1, "RESERVE", 0xC8C8C8);
		Text(2, String.Format("%d", max(loaded, 0)), 0, loaded == 0 ? 0xFF5A46 : -1);
		if (reserve >= 0) TextRight(2, String.Format("%d", reserve), -1);
		let e = RSQGC_Bonsai.Entry(pmo, w);
		if (e && e.lvl >= 0)
		{
			int n = Cols(3);
			string lv = String.Format("LV %d ", e.lvl);
			int bars = n - lv.Length();
			int on = e.permille * bars / 1000;
			string bar = "";
			for (int i = 0; i < bars; i++) bar = bar .. (i < on ? "=" : "-");
			Text(3, lv .. bar, 0, 0xFFD678);
			int shown = min(e.names.Size(), 4);
			for (int i = 0; i < shown; i++)
			{
				int colr = e.on[i] ? RSQGC_GunCard.ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070;
				string num = RSQGC_Bonsai.Numeral(e.levels[i]);
				int room = Cols(4 + i) - num.Length() - 1;
				string nm = e.names[i].MakeUpper();
				if (int(nm.Length()) > room) nm = nm.Left(room);
				Text(4 + i, nm, 0, colr);
				TextRight(4 + i, num, colr);
			}
			if (e.names.Size() > shown) Text(8, String.Format("+%d MORE", e.names.Size() - shown), 0, 0x9A9A9A);
		}
		// the panel: the smallest height that holds the last row used, laid FIRST so the text stands in front
		int need = RSQGC_SideStates.ROW_BOTTOM_PX[lastRow];
		int hi = 0;
		while (hi < RSQGC_SideStates.PANEL_H.Size() - 1 && RSQGC_SideStates.PANEL_H[hi] < need) hi++;
		let pnl = new("RSQGC_SideOp");
		pnl.st = RSQGC_SideStates.Panel(Fam(), hi); pnl.col = panelCol;
		if (pnl.st) ops.Insert(0, pnl);
	}
}
