// wr_q_side.zs -- RSQ Wheel: THE WATCH CARD (owner 2026-10-31 02:47): "expanded card that shows up along grip hand
// area, full card, facing player, when I check my watch, knuckles up".
//
// The card lies flat on the side of the gun at the back of the grip hand (tools/gen_side.py). In the knuckles-up
// pose that side faces the eyes. Its columns are baked (a glyph per column); its rows are placed by turning each
// layer about the model's X axis (the layer's y, hw_weapon.cpp:108), which keeps it in the card's plane.
//
// What it says: the gun's name and hand, the magazine (big) with the reserve, and with Gun Bonsai its level, XP and
// upgrades in Gun Bonsai's colours. The panel is tinted the gun's colour (wr_GunCard.StyleFor).

class wr_SideOp
{
	State st;
	double dz;     // cm down the card from its top edge
	double ycm;    // the piece's place along the gun (its column), for the turn's radius
	int col;       // tint 0xRRGGBB, -1 none
}

class wr_SideCard play
{
	const MAXL = 160;
	const BASE0 = 1001200;      // main hand 1001200.., off hand 1001400..; the other side +400
	Array<wr_SideOp> ops;
	string sig;
	int hand;
	int side;                   // 0 outboard of the wrist, 1 inboard (owner 03:00: both sides)
	bool mir;
	int laid;

	void Clear() { ops.Clear(); }

	// the model-Y centre of a column (mirrored: the columns run the other way, as the generator baked them)
	static double ColY(int font, int col, bool mir)
	{
		double gw = wr_SideStates.CELL_W[font] * wr_SideStates.PX_CM;
		double pad = wr_SideStates.PAD * wr_SideStates.PX_CM, w = wr_SideStates.CARD_W * wr_SideStates.PX_CM;
		double y0 = mir ? wr_SideStates.CARD_Y0 + w - pad - (col + 1) * gw : wr_SideStates.CARD_Y0 + pad + col * gw;
		return y0 + gw / 2;
	}

	void Add(State s, double dz, double ycm, int col)
	{
		if (!s) return;
		let o = new("wr_SideOp");
		o.st = s; o.dz = dz; o.ycm = ycm; o.col = col;
		ops.Push(o);
	}

	// text in a font from column c0 on, at dz cm down; returns the next free column
	int Text(int font, string s, int c0, double dz, int col = -1)
	{
		s = s.MakeUpper();
		int n = wr_SideStates.NCOLS[font];
		int c = c0;
		for (int i = 0; i < s.Length() && c < n; i++, c++)
		{
			int ch = s.ByteAt(i);
			if (ch == 32) continue;
			Add(wr_SideStates.Glyph(font, mir, c, ch, side), dz, ColY(font, c, mir != (side == 1)), col);
		}
		return c;
	}
	// right-aligned text ending at the last column
	void TextRight(int font, string s, double dz, int col = -1)
	{
		int n = wr_SideStates.NCOLS[font];
		Text(font, s, max(0, n - s.Length()), dz, col);
	}
	static double RowH(int font) { return wr_SideStates.CELL_H[font] * wr_SideStates.PX_CM; }

	void Sync(PlayerInfo p, Actor owner, double alpha, double up, wr_GunCard gc)
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
			// down the card by dz: turn about the model X axis by asin(dz / Y) (Y < 0 along the gun)
			double r = min(o.ycm, -1.0);
			double phi = asin(clamp(o.dz / r, -0.9, 0.9));
			ps.x = 0;
			ps.y = 32 - phi * 4 * wr_SideStates.PITCH_SIGN + up * 4;
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

	// ---- the full card -------------------------------------------------------------------------------------------
	void Build(PlayerPawn pmo, int hnd, Weapon w, int panelCol)
	{
		Clear();
		int S = wr_SideStates.F_SMALL, T = wr_SideStates.F_TITLE, D = wr_SideStates.F_DIGIT;
		double pad = wr_SideStates.PAD * wr_SideStates.PX_CM;
		double z = pad;
		Array<wr_SideOp> body;
		// title: name, the hand on the right
		Text(T, wr_DetailTemplates.NameOf(w), 0, z, 0xF0F0F0);
		TextRight(S, wr_DetailTemplates.HandTag(hnd), z + RowH(T) - RowH(S), 0x9A9A9A);
		z += RowH(T) + 0.25;
		// the rounds: the word, then the magazine big and the reserve after it
		int loaded = wr_GunCard.Loaded(w), reserve = wr_GunCard.Reserve(w);
		Text(S, wr_GunCard.HasMagazine(w) ? "MAGAZINE" : "AMMO", 0, z, 0xC8C8C8);
		if (reserve >= 0) TextRight(S, "RESERVE", z, 0xC8C8C8);
		z += RowH(S) + 0.1;
		Text(D, String.Format("%d", max(loaded, 0)), 0, z, loaded == 0 ? 0xFF5A46 : -1);
		if (reserve >= 0) TextRight(D, String.Format("%d", reserve), z, -1);
		z += RowH(D) + 0.25;
		// Gun Bonsai
		let e = WR_Bonsai.Entry(pmo, w);
		if (e && e.lvl >= 0)
		{
			int n = wr_SideStates.NCOLS[S];
			string lv = String.Format("LV %d ", e.lvl);
			int bars = n - lv.Length();
			int on = e.permille * bars / 1000;
			string bar = "";
			for (int i = 0; i < bars; i++) bar = bar .. (i < on ? "=" : "-");
			int c = Text(S, lv, 0, z, 0xFFD678);
			Text(S, bar, c, z, 0xFFD678);
			z += RowH(S) + 0.15;
			int shown = min(e.names.Size(), 4);
			for (int i = 0; i < shown; i++)
			{
				int colr = e.on[i] ? wr_DetailTemplates.ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070;
				string num = WR_Bonsai.Numeral(e.levels[i]);
				int room = n - num.Length() - 1;
				string nm = e.names[i].MakeUpper();
				if (nm.Length() > room) nm = nm.Left(room);
				Text(S, nm, 0, z, colr);
				TextRight(S, num, z, colr);
				z += RowH(S) + 0.1;
			}
			if (e.names.Size() > shown) { Text(S, String.Format("+%d MORE", e.names.Size() - shown), 0, z, 0x9A9A9A); z += RowH(S) + 0.1; }
		}
		z += pad;
		// the panel: the smallest height that holds it, laid FIRST so the text stands in front
		int hi = 0;
		while (hi < wr_SideStates.PANEL_H.Size() - 1 && wr_SideStates.PANEL_H[hi] * wr_SideStates.PX_CM < z) hi++;
		let pnl = new("wr_SideOp");
		pnl.st = wr_SideStates.Panel(mir, hi, side); pnl.dz = 0; pnl.ycm = wr_SideStates.CARD_Y0 + wr_SideStates.CARD_W * wr_SideStates.PX_CM / 2; pnl.col = panelCol;
		if (pnl.st) ops.Insert(0, pnl);
	}
}
