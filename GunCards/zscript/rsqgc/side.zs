// side.zs -- RSQ Gun Cards: THE WATCH CARD (owner 2026-10-31 02:47 / 03:00): the full card, flat on the back-of-the-hand
// side of the wrist, facing you when you check your watch (the back of the wrist turned to your face). card.zs SideRot
// picks which way up from the pose (tools/gen_side.py bakes both). The wrist is measured from Brutal Doom VR's hand mesh.
//
// THE OWNER'S DESIGN (2026-11-03, approved from the mockups gcmock/mock5.py cards 1, 3 and 4). No title row. Three cards,
// chosen by Watch Card Shows (rsqgc_watch_shows); a watch check with an empty hand always shows the Status card:
//   WEAPON  MAG / RESERVE small, the two counts big; GRENADES n (orange); KILLS n (red); Gun Bonsai's rows below only
//           with Gun Bonsai on Card (rsqgc_watch_bonsai)
//   STATUS  H / A small; health (white, red at 25 or less) and armour (blue) big; the key icons, G:n (orange) right
//   BOTH    MAG / RESERVE, the counts; "H 100" / "A 50" (blue); the key icons, G:n right
// All text JFO (tools/jfo.py) at the Text Quality (rsqgc_text_q: 0 Quest, half-resolution glyphs; 1 PCVR). Text sits on
// a unit grid baked into the voxels (small 25 units, big 13): left text starts at unit 0, right text ends at the last.
// Rows are the generated row ids (RSQGC_SideStates.R_*); each piece is lifted to its row by its layer's y.

class RSQGC_SideOp
{
	State st;
	int col;       // tint 0xRRGGBB, -1 none
	double y;      // the layer y offset that lifts the piece to its row (RSQGC_SideStates.RowY; 0 for the panel)
}

class RSQGC_SideCard play
{
	const MAXL = 180;
	const BASE0 = 1001200;      // main hand 1001200.., off hand 1001400..
	const PER_HAND = 200;
	// the mockup's colours (mock5.py)
	const C_WHITE = 0xF0F0F0;
	const C_GREY = 0xC8C8C8;
	const C_DARK = 0x707070;
	const C_BLUE = 0x7CC4FF;
	const C_RED = 0xFF5040;
	const C_ORANGE = 0xF08030;
	const C_GREEN = 0x80E040;
	Array<RSQGC_SideOp> ops;
	string sig;
	int hand;
	int rot;                    // 0 / 1: which way up the text is baked (card.zs SideRot)
	bool mir;
	int quality;                // rsqgc_text_q when built: 0 Quest, 1 PCVR
	int laid;
	int lastRow;

	void Clear() { ops.Clear(); lastRow = 0; }
	int Fam() { return rot * 2 + (mir ? 1 : 0); }

	private void Add(State s, int col, double y = 0)
	{
		if (!s) return;
		let o = new("RSQGC_SideOp");
		o.st = s; o.col = col; o.y = y;
		ops.Push(o);
	}
	private void Used(int row) { if (RSQGC_SideStates.PANEL_NEED[row] > RSQGC_SideStates.PANEL_NEED[lastRow]) lastRow = row; }

	// ---- text on the grid ---------------------------------------------------------------------------------------
	// small text's width in units (JFO: 2 a glyph, 1 a narrow one, 1 a space); characters JFO has not got are skipped
	static int SmallWidth(string s)
	{
		s = s.MakeUpper();
		int n = 0;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int ch = s.ByteAt(i);
			n += ch == 32 ? 1 : RSQGC_SideStates.Adv(ch);
		}
		return n;
	}
	// small text on a row from unit u0
	void SText(int row, string s, int u0, int col)
	{
		s = s.MakeUpper();
		int u = u0;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int ch = s.ByteAt(i);
			if (ch == 32) { u++; continue; }
			int a = RSQGC_SideStates.Adv(ch);
			if (a <= 0) continue;
			if (u + a > RSQGC_SideStates.SMALL_UNITS) break;
			Add(RSQGC_Glow.SGlyph(quality, Fam(), u, ch), col, RSQGC_SideStates.RowY(row, Fam()));
			u += a;
		}
		Used(row);
	}
	void SRight(int row, string s, int col) { SText(row, s, max(0, RSQGC_SideStates.SMALL_UNITS - SmallWidth(s)), col); }
	// big digits (and '+'), two units each
	void BText(int row, string s, int u0, int col)
	{
		for (int i = 0; i < int(s.Length()); i++)
		{
			int u = u0 + i * 2;
			if (u + 2 > RSQGC_SideStates.BIG_UNITS) break;
			Add(RSQGC_Glow.SGlyph(2 + quality, Fam(), u, s.ByteAt(i)), col, RSQGC_SideStates.RowY(row, Fam()));
		}
		Used(row);
	}
	void BRight(int row, string s, int col) { BText(row, s, max(0, RSQGC_SideStates.BIG_UNITS - 2 * int(s.Length())), col); }

	// ---- the layers -----------------------------------------------------------------------------------------------
	void Sync(PlayerInfo p, Actor owner, double alpha, double up, RSQGC_GunCard gc)
	{
		int base = BASE0 + hand * PER_HAND;
		int n = min(ops.Size(), MAXL);
		// the card turned half round (rot 1, families 2 and 3) has its rows the other way along the turn (RowY's sign
		// flips there), so the Up slider turns the other way too, to stay "up as it reads" (fixed 2026-11-10: it ran down)
		double upDir = rot == 1 ? -1 : 1;
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
			// the row: a turn about the pieces' far turning point (tools/gen_side.py HOW v3), plus the Up / Down slider
			// scaled to move the card as far as it did; no slide between tics when a piece changes rows
			ps.x = 0;
			double ny = 32 + o.y + upDir * up * 4 * RSQGC_SideStates.NUDGE_K;
			if (ps.y != ny) { ps.y = ny; ps.oldy = ny; }
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
		int base = BASE0 + hand * PER_HAND;
		for (int i = 0; i < MAXL; i++) if (p.FindPSprite(base + i)) p.SetPSprite(base + i, null);
		laid = 0; sig = "";
	}

	// THE SMALL LINES of the Weapon card (GRENADES, KILLS, then Gun Bonsai's), filled in order, top down. -1 when full.
	int nextLine;
	int Line()
	{
		int r;
		if (nextLine == 0) r = RSQGC_SideStates.R_LINE2;
		else if (nextLine == 1) r = RSQGC_SideStates.R_LINE3;
		else r = RSQGC_SideStates.R_GB0 + nextLine - 2;
		if (r >= RSQGC_SideStates.ROWS) return -1;
		nextLine++;
		return r;
	}
	// a line with a word on the left and a value on the right
	void Pair(string l, string r, int lc, int rc)
	{
		int row = Line();
		if (row < 0) return;
		SText(row, l, 0, lc);
		SRight(row, r, rc);
	}
	// the panel: the smallest height that holds the last row used, laid FIRST so the text stands in front
	void Panel(int panelCol)
	{
		if (RSQGC_Glow.NoPanel()) return;    // Material: No Background (owner 11-06)
		int need = RSQGC_SideStates.PANEL_NEED[lastRow];
		int hi = 0;
		while (hi < RSQGC_SideStates.PANEL_H.Size() - 1 && RSQGC_SideStates.PANEL_H[hi] < need) hi++;
		let pnl = new("RSQGC_SideOp");
		pnl.st = RSQGC_Glow.SPanel(Fam(), hi); pnl.col = panelCol;
		if (pnl.st) ops.Insert(0, pnl);
	}

	// ---- the rows the cards share -----------------------------------------------------------------------------
	// MAG / RESERVE and the two counts. RELOAD (GC3, red) in MAG's place on an empty magazine with rounds to load; "+N"
	// (GC2, green) in the reserve's place after a pickup; the count's colour from the magazine (green / yellow / red,
	// RSQGC_GunCard.MagColour, under Low Ammo Colour).
	private void GunRows(Weapon w, int hnd, RSQGC_GunCard gc)
	{
		int loaded = RSQGC_GunCard.Loaded(w), reserve = RSQGC_GunCard.Reserve(w);
		bool mag = RSQGC_GunCard.HasMagazine(w);
		bool reload = mag && loaded == 0 && reserve > 0;
		int R = RSQGC_SideStates.R_LABELS, C = RSQGC_SideStates.R_COUNTS;
		SText(R, reload ? "RELOAD" : mag ? "MAG" : "AMMO", 0, reload ? C_RED : C_GREY);
		if (reserve >= 0) SRight(R, "RESERVE", C_GREY);
		int mc = RSQGC_GunCard.MagColour(w, loaded);
		BText(C, String.Format("%d", clamp(loaded, 0, 999)), 0, mc >= 0 ? mc : C_WHITE);
		int plus = gc ? gc.PlusNow(hnd) : 0;
		if (plus > 0) BRight(C, String.Format("+%d", clamp(plus, 1, 99)), C_GREEN);
		else if (reserve >= 0) BRight(C, String.Format("%d", clamp(reserve, 0, 999)), C_WHITE);
	}

	// THE KEY ICONS (owner 2026-11-03): only the key kinds this map has (RSQGC_GunCard.MapKeys: keycards, skulls), each
	// colour lit when held and dark grey when not; the voxel pack's own keys when it is loaded, Freedoom's otherwise.
	// Other keys (no red / yellow / blue in the name) count as "+N" after the icons. Then G:n on the right.
	// iconsOnly (the item card, 11-10): the icons alone; the item card puts G:n on its own line, clear of the hand
	private void KeyRow(PlayerPawn pmo, int row, int textRow, RSQGC_GunCard gc, bool iconsOnly = false)
	{
		bool cards, skulls;
		[cards, skulls] = gc.MapKeys(pmo);
		if (!ci("rsqgc_keys", 1)) { cards = false; skulls = false; }
		int heldMask, others;
		[heldMask, others] = RSQGC_GunCard.HeldKeys(pmo);
		int src = RSQGC_GunCard.KeyArt();
		int fam = Fam();
		double y = RSQGC_SideStates.RowY(row, fam);
		bool any = false;
		if (cards) for (int t = 0; t < 3; t++) { Add(RSQGC_Glow.SKey(src, fam, t, 0, !(heldMask & (1 << t))), -1, y); any = true; }
		if (skulls) for (int t = 3; t < 6; t++) { Add(RSQGC_Glow.SKey(src, fam, t, cards, !(heldMask & (1 << t))), -1, y); any = true; }
		if (any) Used(row);
		if (iconsOnly) return;
		// other keys as "+N" after the icons, where it does not run into G:n
		int gren = RSQGC_GunCard.Grenades(pmo);
		string g = gren >= 0 ? String.Format("G:%d", gren) : "";
		int room = RSQGC_SideStates.SMALL_UNITS - (g != "" ? SmallWidth(g) + 1 : 0);
		if (others > 0)
		{
			string o = any ? String.Format("+%d", others) : String.Format("KEYS +%d", others);
			int at = !any ? 0 : (skulls && cards ? RSQGC_SideStates.KEYS_END1 : RSQGC_SideStates.KEYS_END0);
			if (at + SmallWidth(o) <= room) SText(textRow, o, at, C_GREY);
		}
		if (g != "") SRight(textRow, g, gren > 0 ? C_ORANGE : C_DARK);
	}
	static int ci(string n, int f) { let c = CVar.FindCVar(n); return c ? c.GetInt() : f; }

	// ---- the three cards -------------------------------------------------------------------------------------
	void Build(PlayerPawn pmo, int hnd, Weapon w, int panelCol, RSQGC_GunCard gc, int shows)
	{
		Clear();
		nextLine = 0;
		GunRows(w, hnd, gc);
		if (shows == 2)
		{
			// BOTH: "H 100" left (the number red at 25 or less), "A 50" blue right, then the key icons and G:n
			int hp = max(pmo.Health, 0);
			SText(RSQGC_SideStates.R_LINE2, "H", 0, C_WHITE);
			SText(RSQGC_SideStates.R_LINE2, String.Format("%d", clamp(hp, 0, 999)), 3, hp <= 25 ? C_RED : C_WHITE);
			SRight(RSQGC_SideStates.R_LINE2, String.Format("A %d", RSQGC_GunCard.ArmorOf(pmo)), C_BLUE);
			KeyRow(pmo, RSQGC_SideStates.R_KEYS3, RSQGC_SideStates.R_KEYS3TEXT, gc);
			Panel(panelCol);
			return;
		}
		// WEAPON: GC4 Brutal Doom's grenades (not the mines); GC7 this gun's kills this level, the count in red
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0) Pair("GRENADES", String.Format("%d", gren), C_GREY, gren > 0 ? C_ORANGE : C_DARK);
		if (gc) Pair("KILLS", String.Format("%d", gc.KillsWith(w)), C_GREY, C_RED);
		let e = ci("rsqgc_watch_bonsai", 0) ? RSQGC_Bonsai.Entry(pmo, w) : null;
		if (e && e.lvl >= 0)
		{
			int row = Line();
			if (row >= 0)
			{
				string lv = String.Format("LV %d ", e.lvl);
				int bars = (RSQGC_SideStates.SMALL_UNITS - SmallWidth(lv)) / 2;
				int on = e.permille * bars / 1000;
				string bar = "";
				for (int i = 0; i < bars; i++) bar = bar .. (i < on ? "=" : "-");
				SText(row, lv .. bar, 0, 0xFFD678);
			}
			int shown = min(e.names.Size(), 4);
			for (int i = 0; i < shown; i++)
			{
				row = Line();
				if (row < 0) break;
				int colr = e.on[i] ? RSQGC_GunCard.ColourOf(e.colours.Size() > i ? e.colours[i] : "") : C_DARK;
				string num = RSQGC_Bonsai.Numeral(e.levels[i]);
				int room = RSQGC_SideStates.SMALL_UNITS - SmallWidth(num) - 1;
				string nm = e.names[i].MakeUpper();
				while (nm.Length() > 0 && SmallWidth(nm) > room) nm = nm.Left(nm.Length() - 1);
				SText(row, nm, 0, colr);
				SRight(row, num, colr);
			}
			if (e.names.Size() > shown) { row = Line(); if (row >= 0) SText(row, String.Format("+%d MORE", e.names.Size() - shown), 0, 0x9A9A9A); }
		}
		Panel(panelCol);
	}

	// THE ITEM CARD (items.zs, owner 11-10): the watch check with a weapon that has no ammo pile. Its name, what it holds and
	// what it is doing, then health, armour, G:n and the key icons.
	// ITS WORDS ARE CLEAR OF THE HAND (rig 11-10, RESULTS_P2 N1; fixed 11-10): an item's own hand (the saber's hilt hand, the
	// flare's, the torch's) is drawn over the far half of the card -- the half toward the fingers, the right half of the
	// text on the right wrist and the left half on the left -- where a gun's hand is not, and it hid the saber's LIT / OFF,
	// the flare count and the battery. So every word and number of the item card stands in the near half (HALF small
	// units; the big count in the same half), one to a line, top down: the name, the count big (the flares left, the
	// battery) or else health big, the state word, then "H n" (when the count is big), "A n", "G:n", and the key icons.
	const HALF = 12;
	bool nearRight;     // the near half is the text's right half (the physically left wrist)
	private void HText(int row, string s, int col)
	{
		s = s.MakeUpper();
		while (s.Length() > 0 && SmallWidth(s) > HALF) s = s.Left(s.Length() - 1);
		if (nearRight) SRight(row, s, col); else SText(row, s, 0, col);
	}
	private void HBig(int row, string s, int col)
	{
		if (nearRight) BRight(row, s, col); else BText(row, s, 0, col);
	}
	void BuildItem(PlayerPawn pmo, Weapon w, int panelCol, RSQGC_GunCard gc, bool physLeft)
	{
		Clear();
		nextLine = 0;
		nearRight = physLeft;
		string st; int stc;
		[st, stc] = RSQGC_Items.State(w);
		HText(RSQGC_SideStates.R_LABELS, RSQGC_Items.Label(w), C_WHITE);
		int hp = max(pmo.Health, 0), ar = clamp(RSQGC_GunCard.ArmorOf(pmo), 0, 999);
		int n = RSQGC_Items.Count(w);
		int C = RSQGC_SideStates.R_COUNTS;
		// the big number is the item's own count only (flares, battery, cigarettes). An item with none (the saber, gloves,
		// the whip...) shows no big number: health there read as ammo (owner 11-11: "saber probably doesnt need to say 100")
		if (n >= 0) HBig(C, String.Format("%d", clamp(n, 0, 999)), n == 0 ? C_RED : C_WHITE);
		int row;
		if (st != "" && (row = Line()) >= 0) HText(row, st, stc);
		if ((row = Line()) >= 0) HText(row, String.Format("H %d", clamp(hp, 0, 999)), hp <= 25 ? C_RED : C_WHITE);
		if ((row = Line()) >= 0) HText(row, String.Format("A %d", ar), C_BLUE);
		int gren = RSQGC_GunCard.Grenades(pmo);
		if (gren >= 0 && (row = Line()) >= 0) HText(row, String.Format("G:%d", gren), gren > 0 ? C_ORANGE : C_DARK);
		if ((row = Line()) >= 0) KeyRow(pmo, row, row, gc, true);
		Panel(panelCol);
	}

	// GC5 THE STATUS CARD: the watch check with an empty hand (or Watch Card Shows: Status Card)
	void BuildStatus(PlayerPawn pmo, int hnd, int panelCol, RSQGC_GunCard gc)
	{
		Clear();
		nextLine = 0;
		SText(RSQGC_SideStates.R_LABELS, "H", 0, C_GREY);
		SRight(RSQGC_SideStates.R_LABELS, "A", C_GREY);
		int hp = max(pmo.Health, 0);
		BText(RSQGC_SideStates.R_COUNTS, String.Format("%d", clamp(hp, 0, 999)), 0, hp <= 25 ? C_RED : C_WHITE);
		BRight(RSQGC_SideStates.R_COUNTS, String.Format("%d", clamp(RSQGC_GunCard.ArmorOf(pmo), 0, 999)), C_BLUE);
		KeyRow(pmo, RSQGC_SideStates.R_KEYS2, RSQGC_SideStates.R_KEYS2TEXT, gc);
		Panel(panelCol);
	}
}
