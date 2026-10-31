// wr_q_detail.zs -- RSQ Wheel: THE DETAILED GUN CARD (Project Wheel; the mock-up templates).
//
// Normal play shows the small ammo card (wr_q_card.zs). Check your watch -- the inspect gesture
// (RSQ Gestures: raise the gun, twist it palm down) or, without that mod, the Wheel's own watch pose --
// and that gun shows a detailed card instead: its name and hand, the rounds in it under Ermac's
// MAGAZINE / AMMO word, the reserve, and, when Gun Bonsai is loaded, its level, XP and upgrades with
// their levels. Templates: Ammo, Compact, Full, Both hands; any can be the normal-play card or the watch
// card (wr_card_tpl, wr_card_watch_tpl).
//
// TEXT ON THE GUN. Every glyph and every slice of the panel is its own weapon layer drawn as a voxel at the
// hand (see wr_q_card.zs for why voxels), baked by tools/gen_detail.py at the card's anchor. A layer's x / y
// turn its model about the model origin (hw_weapon.cpp:108), so one baked piece can be put anywhere on the
// card; wr_DetailStates.Place / PlaceWide work out the turn for a spot in layout px (the generator baked
// every piece on the sphere those turns sweep, so nothing sinks behind the panel). The mirrored hand and the
// watch card's turned ("rolled") family are handled there too.
//
// The layout is rebuilt only when what the card says changes; otherwise the layers stand.

class wr_DetailOp
{
	State st;
	double px, py;     // the layer's x / y
	int col;           // 0xRRGGBB to tint, -1 none
}

class wr_DetailCard play
{
	const MAXL = 190;           // layers per hand
	const BASE0 = 1000400;      // main hand 1000400.., off hand 1000600..

	Array<wr_DetailOp> ops;
	string sig;                 // what the card said last time it was laid out
	int hand;
	bool mir;
	bool rolled;                // the watch card: the family turned to read upright in the palm-down twist
	int width;                  // wr_DetailStates.W_*
	int laid;                   // layers in use

	double CardW() { return wr_DetailStates.WIDTH_PX[width]; }

	// ---- building ----------------------------------------------------------------------------------------
	void Clear() { ops.Clear(); }
	private void Push(State s, Vector2 at, int col)
	{
		if (!s) return;
		let o = new("wr_DetailOp");
		o.st = s; o.px = at.x; o.py = at.y; o.col = col;
		ops.Push(o);
	}
	// a glyph-like piece pw x ph px, its top-left at (x, y) px on the card
	void At(State s, double x, double y, double pw, double ph, int col = -1)
	{
		if (!s) return;
		Push(s, wr_DetailStates.Place(x, y, mir, rolled, CardW(), pw, ph), col);
	}
	void Misc(int m, double x, double y, int col = -1)
	{
		At(wr_DetailStates.Piece(wr_DetailStates.K_MISC, mir, rolled, m),
			x, y, wr_DetailStates.MISC_SIZE[m * 2] / 100., wr_DetailStates.MISC_SIZE[m * 2 + 1] / 100., col);
	}
	static double MiscW(int m) { return wr_DetailStates.MISC_SIZE[m * 2] / 100.; }
	static double MiscH(int m) { return wr_DetailStates.MISC_SIZE[m * 2 + 1] / 100.; }
	// a full-width slice or rule (both halves on the rolled card), its top at y px
	void Wide(int kind, int style, double y, int col = -1)
	{
		for (int half = 0; half < (rolled ? 2 : 1); half++)
			Push(wr_DetailStates.Piece(kind, mir, rolled, style, width, half),
				wr_DetailStates.PlaceWide(kind, y, mir, rolled, width, half), col);
	}
	static double LineH(int font, int size)
	{
		return wr_DetailStates.FONT_H[font] * (size == wr_DetailStates.S_SMALL ? wr_DetailStates.SMALL_SCALE : 1.0);
	}
	// text at (x, y), left aligned; returns its width in px
	double Text(int font, int size, string s, double x, double y, int col = -1)
	{
		double h = LineH(font, size), pen = x;
		s = s.MakeUpper();
		for (int i = 0; i < s.Length(); i++)
		{
			int c = s.ByteAt(i);
			if (c < 32 || c > 95) c = 32;
			double adv = wr_DetailStates.Advance(font, size, c);
			if (c != 32) At(wr_DetailStates.Glyph(font, size, mir, rolled, c), pen, y, adv, h, col);
			pen += adv;
		}
		return pen - x;
	}
	static double TextW(int font, int size, string s) { return wr_DetailStates.TextWidth(font, size, s.MakeUpper()); }
	static string Fit(int font, int size, string s, double w)
	{
		s = s.MakeUpper();
		while (s.Length() > 1 && TextW(font, size, s) > w) s = s.Left(s.Length() - 1);
		return s;
	}
	// the panel, h px tall: top, as many middles as it takes, bottom
	void Panel(int style, double h, int col)
	{
		double top = wr_DetailStates.SLICE_PX[wr_DetailStates.K_TOP];
		double mid = wr_DetailStates.SLICE_PX[wr_DetailStates.K_MID];
		double bot = wr_DetailStates.SLICE_PX[wr_DetailStates.K_BOTTOM];
		h = max(h, top + bot);
		Wide(wr_DetailStates.K_TOP, style, 0, col);
		double end = h - bot;
		for (double y = top; y < end; y += mid) Wide(wr_DetailStates.K_MID, style, min(y, end - mid), col);
		Wide(wr_DetailStates.K_BOTTOM, style, end, col);
	}

	// ---- drawing ---------------------------------------------------------------------------------------------
	// Put the ops on layers; layers past the ops are taken away. Only touches a layer whose state changed.
	int copy;                   // 0 the inside card, 1 the outside copy (same ops, turned outboard)
	double extraSide;           // degrees the outside copy is turned

	void Sync(PlayerInfo p, Actor owner, double alpha, wr_GunCard gc)
	{
		int base = BASE0 + hand * 200 + copy * 400;
		int n = min(ops.Size(), MAXL);
		double side = ((rolled ? gc.WatchNudge(false) : gc.Nudge(false)) + extraSide) * 4 * (mir ? -1 : 1), up = (rolled ? gc.WatchNudge(true) : gc.Nudge(true)) * 4;
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
			ps.x = o.px + side;
			ps.y = o.py + up;
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
		int base = BASE0 + hand * 200 + copy * 400;
		for (int i = 0; i < MAXL; i++) if (p.FindPSprite(base + i)) p.SetPSprite(base + i, null);
		laid = 0;
		sig = "";
	}
}

// The templates. Every one reads the same facts and lays them out its own way.
class wr_DetailTemplates play
{
	enum ETpl { T_OFF = 0, T_AMMO = 1, T_COMPACT = 2, T_FULL = 3, T_BOTH = 4 }

	// Gun Bonsai's colour codes (the colour it gives an upgrade's name), to RGB
	static int ColourOf(string code)
	{
		code = code.MakeUpper();
		if (code == "ORANGE") return 0xFF9030;
		if (code == "RED" || code == "DARKRED") return 0xFF5040;
		if (code == "GREEN" || code == "DARKGREEN" || code == "OLIVE") return 0x80E040;
		if (code == "BLUE" || code == "LIGHTBLUE" || code == "CYAN") return 0x60C8FF;
		if (code == "PURPLE") return 0xC080FF;
		if (code == "YELLOW" || code == "GOLD") return 0xFFD060;
		if (code == "BRICK" || code == "BROWN") return 0xD07040;
		return 0xE8E8E8;
	}

	// "R" / "L" as the player knows the hands (physical: a left-handed player's main hand is "L")
	static string HandTag(int hand)
	{
		let c = CVar.FindCVar("vr_control_scheme");
		bool rightHanded = !c || c.GetInt() < 10;
		return (hand == 0) == rightHanded ? "R" : "L";
	}

	static string NameOf(Weapon w)
	{
		// an off-hand copy (Brutal Doom VR's RSQ_Off_<gun>) goes by the gun it copies
		string cn = w.GetClassName();
		if (cn.Left(8) ~== "RSQ_Off_")
		{
			class<Actor> real = cn.Mid(8);
			if (real) { let d = GetDefaultByType(real); if (d) return d.GetTag(); }
		}
		string n = w.GetTag();
		if (n.Length() == 0) n = w.GetClassName();
		return n;
	}

	// the facts as one string: when it changes the card is laid out again
	static string Signature(PlayerPawn pmo, Weapon w, Weapon other, int tpl, int style)
	{
		string s = String.Format("%d %d %s %d %d", tpl, style, w ? w.GetClassName() : 'none', wr_GunCard.Loaded(w), wr_GunCard.Reserve(w));
		if (other) s = s .. String.Format(" | %s %d %d", other.GetClassName(), wr_GunCard.Loaded(other), wr_GunCard.Reserve(other));
		for (int k = 0; k < (other ? 2 : 1); k++)
		{
			let e = WR_Bonsai.Entry(pmo, k == 0 ? w : other);
			if (!e || e.lvl < 0) continue;
			s = s .. String.Format(" b%d %d", e.lvl, e.permille / 20);
			for (int i = 0; i < e.names.Size(); i++) s = s .. String.Format(" %s%d%d", e.names[i], e.levels[i], e.on[i]);
		}
		return s;
	}

	const DF = wr_DetailStates.F_DoomFont;
	const ED = wr_DetailStates.F_ErmacDigits;
	const ST = wr_DetailStates.S_TEXT;
	const SS = wr_DetailStates.S_SMALL;
	const DIM = 0x9A9A9A;
	const GOLD = 0xFFD678;
	const EMPTY = 0xFF5A46;

	// ---- Full and Compact (the mock-ups) --------------------------------------------------------------------
	static void Single(wr_DetailCard c, PlayerPawn pmo, int hand, Weapon w, bool compact, int style, int panelCol, int textCol)
	{
		c.width = compact ? wr_DetailStates.W_COMPACT : wr_DetailStates.W_FULL;
		double cw = c.CardW(), pad = 4, x0 = pad, right = cw - pad;
		double y = pad;
		// the panel is laid first (everything else stands in front of it), sized once the rest is known
		wr_DetailCard body = new("wr_DetailCard");
		body.mir = c.mir; body.rolled = c.rolled; body.width = c.width;

		// title: the gun's name, and the hand on the right
		string tag = HandTag(hand);
		double tagW = body.TextW(DF, SS, tag);
		body.Text(DF, ST, body.Fit(DF, ST, NameOf(w), right - x0 - tagW - 3), x0, y, textCol);
		body.Text(DF, SS, tag, right - tagW, y + body.LineH(DF, ST) - body.LineH(DF, SS), DIM);
		y += body.LineH(DF, ST) + 2;
		body.Wide(wr_DetailStates.K_RULE, style, y);
		y += 3;

		// the rounds: Ermac's word over the count (Full), or his bullet beside it (Compact); the reserve
		// on the right with his stack of rounds
		int loaded = wr_GunCard.Loaded(w), reserve = wr_GunCard.Reserve(w);
		bool mag = wr_GunCard.HasMagazine(w);
		if (!compact)
		{
			body.Misc(mag ? wr_DetailStates.M_LABEL_MAGAZINE : wr_DetailStates.M_LABEL_AMMO, x0, y);
			y += wr_DetailCard.MiscH(wr_DetailStates.M_LABEL_AMMO) + 1;
		}
		double dx = x0;
		if (compact)
		{
			body.Misc(wr_DetailStates.M_ROUND, dx, y + (body.LineH(ED, ST) - wr_DetailCard.MiscH(wr_DetailStates.M_ROUND)) / 2);
			dx += wr_DetailCard.MiscW(wr_DetailStates.M_ROUND) + 2;
		}
		body.Text(ED, ST, String.Format("%d", max(loaded, 0)), dx, y, loaded == 0 ? EMPTY : -1);
		if (reserve >= 0)
		{
			string rs = String.Format("%d", reserve);
			double rw = body.TextW(ED, SS, rs);
			double sw = wr_DetailCard.MiscW(wr_DetailStates.M_STACK);
			double ry = y + body.LineH(ED, ST) - body.LineH(ED, SS);
			body.Text(ED, SS, rs, right - rw, ry);
			body.Misc(wr_DetailStates.M_STACK, right - rw - sw - 2, ry + (body.LineH(ED, SS) - wr_DetailCard.MiscH(wr_DetailStates.M_STACK)) / 2);
		}
		y += body.LineH(ED, ST) + 2;

		// Gun Bonsai: level, XP, upgrades
		let e = WR_Bonsai.Entry(pmo, w);
		if (e && e.lvl >= 0)
		{
			double sh = body.LineH(DF, SS);
			double lw = body.Text(DF, SS, String.Format("LV %d", e.lvl), x0, y, GOLD);
			double bx = x0 + lw + 3;
			int segs = int((right - bx) / wr_DetailStates.BAR_ADV);
			int on = e.permille * segs / 1000;
			for (int i = 0; i < segs; i++)
				body.Misc(i < on ? wr_DetailStates.M_BAR_ON : wr_DetailStates.M_BAR_OFF, bx + i * wr_DetailStates.BAR_ADV, y + (sh - 2) / 2, i < on ? GOLD : -1);
			y += sh + 2;
			int shown = min(e.names.Size(), compact ? 2 : 4);
			if (shown > 0)
			{
				body.Wide(wr_DetailStates.K_RULE, style, y);
				y += 3;
			}
			for (int i = 0; i < shown; i++)
			{
				int col = e.on[i] ? ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070;
				int lv = e.levels[i];
				int pips = clamp(max(e.maxes[i], lv), 1, 5);
				double pw = 2;
				double px = right - pips * pw + 1;
				body.Text(DF, SS, body.Fit(DF, SS, e.names[i], px - x0 - 2), x0, y, col);
				for (int k = 0; k < pips; k++)
					body.Misc(k < lv ? wr_DetailStates.M_PIP_ON : wr_DetailStates.M_PIP_OFF, px + k * pw, y + (sh - 1) / 2, k < lv ? col : -1);
				y += sh + 1;
			}
			if (e.names.Size() > shown)
			{
				body.Text(DF, SS, String.Format("+%d MORE", e.names.Size() - shown), x0, y, DIM);
				y += sh + 1;
			}
		}
		y += pad - 1;
		c.Panel(style, y, panelCol);
		for (int i = 0; i < body.ops.Size(); i++) c.ops.Push(body.ops[i]);
	}

	// ---- Both hands on one card -------------------------------------------------------------------------
	static void Both(wr_DetailCard c, PlayerPawn pmo, Weapon r, Weapon l, int style, int panelCol, int textCol)
	{
		c.width = wr_DetailStates.W_WIDE;
		double cw = c.CardW(), pad = 4, half = cw / 2;
		wr_DetailCard body = new("wr_DetailCard");
		body.mir = c.mir; body.rolled = c.rolled; body.width = c.width;
		double yEnd = 0;
		for (int side = 0; side < 2; side++)
		{
			Weapon w = side == 0 ? r : l;
			if (!w) continue;
			double x0 = pad + side * half, right = (side + 1) * half - pad, y = pad;
			double sh = body.LineH(DF, SS);
			body.Text(DF, SS, body.Fit(DF, SS, HandTag(side) .. " " .. NameOf(w), right - x0), x0, y, textCol);
			y += sh + 2;
			int loaded = wr_GunCard.Loaded(w), reserve = wr_GunCard.Reserve(w);
			double dx = x0;
			body.Misc(wr_DetailStates.M_ROUND, dx, y + (body.LineH(ED, ST) - wr_DetailCard.MiscH(wr_DetailStates.M_ROUND)) / 2);
			dx += wr_DetailCard.MiscW(wr_DetailStates.M_ROUND) + 2;
			body.Text(ED, ST, String.Format("%d", max(loaded, 0)), dx, y, loaded == 0 ? EMPTY : -1);
			if (reserve >= 0)
			{
				string rs = String.Format("%d", reserve);
				double rw = body.TextW(ED, SS, rs);
				body.Text(ED, SS, rs, right - rw, y + body.LineH(ED, ST) - body.LineH(ED, SS), DIM);
			}
			y += body.LineH(ED, ST) + 2;
			let e = WR_Bonsai.Entry(pmo, w);
			if (e && e.lvl >= 0)
			{
				body.Text(DF, SS, String.Format("LV %d", e.lvl), x0, y, GOLD);
				y += sh + 1;
				for (int i = 0; i < min(2, e.names.Size()); i++)
				{
					int col = e.on[i] ? ColourOf(e.colours.Size() > i ? e.colours[i] : "") : 0x707070;
					string lv = WR_Bonsai.Numeral(e.levels[i]);
					double lvW = body.TextW(DF, SS, lv);
					body.Text(DF, SS, body.Fit(DF, SS, e.names[i], right - x0 - lvW - 2), x0, y, col);
					body.Text(DF, SS, lv, right - lvW, y, col);
					y += sh + 1;
				}
			}
			yEnd = max(yEnd, y);
		}
		c.Panel(style, yEnd + pad - 1, panelCol);
		for (int i = 0; i < body.ops.Size(); i++) c.ops.Push(body.ops[i]);
	}
}
