// SKIN C, "TERMINAL" (10-27): the second alternative. Same colours and fonts, read as a console:
// corner readouts with thin bracket rules instead of frames, a single-column status list with the
// gun picture and the description beside it, and the level-up choices as full-width rows.
class RSQUI_C_Skin : RSQUI_Skin
{
	RSQUI_Pen pen;
	RSQUI_Data data;

	override Name StatusMenu() { return 'RSQUI_C_StatusMenu'; }
	override Name WeaponLevelUpMenu() { return 'RSQUI_C_WeaponLevelUp'; }
	override Name PlayerLevelUpMenu() { return 'RSQUI_C_PlayerLevelUp'; }

	override bool DrawHud(RenderEvent e)
	{
		if (!pen) pen = RSQUI_Pen.Make();
		if (!data) data = RSQUI_Data.Make();
		data.Read();
		pen.HudFrame();
		double W = pen.UnitsWide(), H = pen.UnitsHigh();
		if (data.stats)
		{
			if (data.hands[1].valid) RSQUI_C_Draw.Readout(pen, data, data.hands[1], 10, 10, true);
			if (data.hands[0].valid) RSQUI_C_Draw.Readout(pen, data, data.hands[0], W - 10, 10, false);
		}
		if (data.haveScore) RSQUI_C_Draw.Score(pen, data, W / 2, 10);
		if (RSQUI_Dispatch.BottomOn()) RSQUI_C_Draw.Bottom(pen, data, W, H);
		return true;
	}
}

class RSQUI_C_Draw ui
{
	const CYAN   = 0xFF00F0FF;
	const ORANGE = 0xFFFF6A10;
	const MAGENTA= 0xFFE05CD8;
	const GREEN  = 0xFF10FF50;
	const GOLD   = 0xFFFFC020;
	const PALE   = 0xFFE8C878;
	const WHITE  = 0xFFF0F0F0;
	const NAVY   = 0xFF0E0A1C;
	const GREY   = 0xFFB4B4BC;
	const DIM    = 0xFF6E6E78;

	// [#####.....] in the terminal face
	static String Blocks(double frac, int n)
	{
		int lit = int(clamp(frac, 0, 1) * n + 0.001);
		String s = "";
		for (int i = 0; i < n; i++) s = s .. (i < lit ? "#" : ".");
		return s;
	}

	// A corner bracket: two rules meeting at (x, y), arms dx and dy long.
	static void Bracket(RSQUI_Pen pen, double x, double y, double dx, double dy, Color c)
	{
		pen.Line(x, y, x + dx, y, 2, c);
		pen.Line(x, y, x, y + dy, 2, c);
	}

	static void Readout(RSQUI_Pen pen, RSQUI_Data d, RSQUI_Hand h, double ax, double ay, bool left)
	{
		bool ready = h.ready || d.pready;
		Color c = ready ? ORANGE : CYAN;
		int al = left ? 0 : 2;
		double dir = left ? 1 : -1;
		double x = ax + dir * 10;
		Bracket(pen, ax, ay, dir * 26, 64, c);
		pen.Rect(left ? ax + 4 : ax - 214, ay + 4, 210, 60, NAVY, 0.55);
		pen.Cap(pen.fPix, 8, left ? "OFF" : "MAIN", x, ay + 8, c, al);
		pen.Cap(pen.fOrb, 13, h.tag, x + dir * (left ? 34 : 42), ay + 6, WHITE, al);
		String bar = h.ignored ? "[----------]" : String.Format("[%s]", Blocks(h.ready ? 1 : h.xp / h.xpmax, 10));
		pen.Cap(pen.fTerm, 16, String.Format("LV%d %s", h.lvl, bar), x, ay + 26, h.ready ? GREEN : c, al);
		pen.Cap(pen.fTerm, 14, h.ignored ? "" : String.Format("%d/%d  P.LV%d %d/%d", h.xp, h.xpmax, d.plvl, d.pxp, d.pmax),
			x, ay + 46, GREY, al);
	}

	static void Score(RSQUI_Pen pen, RSQUI_Data d, double cx, double y)
	{
		String s = String.Format("SCORE %06d", d.score);
		pen.Cap(pen.fTerm, 22, s, cx, y + 6, GOLD, 1);
		double w = pen.Width(pen.fTerm, 22, s);
		pen.Rect(cx - w / 2, y + 26, w, 2, DIM, 0.8);
		pen.Rect(cx - w / 2, y + 26, w * d.progress / 1000.0, 2, ORANGE, 1.0);
		if (d.lives > 0) pen.Cap(pen.fTerm, 14, String.Format("x%d", d.lives), cx + w / 2 + 6, y + 8, GOLD);
	}

	static void Bottom(RSQUI_Pen pen, RSQUI_Data d, double W, double H)
	{
		for (int s = 0; s <= 1; s++)
		{
			let hd = d.hands[s];
			if (!hd.wpn || hd.reserve < 0) continue;
			bool left = s == 1;
			double ax = left ? 10 : W - 10;
			double dir = left ? 1 : -1;
			int al = left ? 0 : 2;
			Bracket(pen, ax, H - 8, dir * 26, -40, left ? ORANGE : CYAN);
			String t = hd.mag >= 0 ? String.Format("%d|%d", hd.mag, hd.reserve) : String.Format("%d", hd.reserve);
			pen.Cap(pen.fTerm, 26, t, ax + dir * 10, H - 34, hd.mag >= 0 ? GOLD : PALE, al);
			double tw = pen.Width(pen.fTerm, 26, t);
			pen.Picture(hd.ammoIcon, left ? ax + 16 + tw : ax - 16 - tw - 22, H - 36, 22, 22);
		}
		double cx = W / 2;
		TextureID face = StatusBar ? StatusBar.GetMugshot(5) : TexMan.CheckForTexture("STFST01", TexMan.Type_Any);
		pen.Picture(face, cx - 15, H - 36, 30, 28);
		pen.Cap(pen.fTerm, 26, String.Format("HP%d", d.health), cx - 22, H - 32, 0xFFFF3A3A, 2);
		if (d.armor > 0) pen.Cap(pen.fTerm, 26, String.Format("AR%d", d.armor), cx + 22, H - 32, GREEN, 0);
	}
}

class RSQUI_C_StatusMenu : RSQUI_StatusMenu
{
	override void Drawer()
	{
		pen.FitBox(960, 600);
		pen.Rect(30, 20, 900, 560, RSQUI_C_Draw.NAVY, 0.9);
		RSQUI_C_Draw.Bracket(pen, 30, 20, 40, 40, RSQUI_C_Draw.MAGENTA);
		RSQUI_C_Draw.Bracket(pen, 930, 580, -40, -40, RSQUI_C_Draw.MAGENTA);
		pen.Cap(pen.fTerm, 22, "> STATUS", 50, 34, RSQUI_C_Draw.MAGENTA);
		pen.Rect(50, 60, 540, 1, RSQUI_C_Draw.DIM, 1.0);

		// the list, left (50..590): sections and rows, the cursor marked ">"
		let r = Row();
		double y = 72, step = 21;
		int maxRows = 22;
		// keep the cursor in view
		int curLine = 0, line = 0;
		Array<String> texts; Array<int> cols; Array<int> sels;
		Section(texts, cols, sels, String.Format("PLAYER  LV%d  %d/%d", data.plvl, data.pxp, data.pmax), RSQUI_A_Look.BLUE_EDGE);
		int pn = data.pbag ? data.pbag.upgrades.Size() : 0;
		for (int i = 0; i < pn; i++)
			Item(texts, cols, sels, data.pbag.upgrades[i], r && r.kind == 2 && r.index == i);
		for (int h = 0; h <= 1; h++)
		{
			let hd = data.hands[h];
			if (!hd.valid) continue;
			Color c = h == 0 ? RSQUI_A_Look.MAIN_EDGE : RSQUI_A_Look.OFF_EDGE;
			String lv = hd.ignored ? "LV-" : String.Format("LV%d  %d/%d", hd.lvl, hd.xp, hd.xpmax);
			texts.Push(String.Format("%s :: %s  %s", h == 0 ? "MAIN" : "OFF", hd.tag, lv));
			cols.Push(c);
			sels.Push((r && r.kind == 0 && r.hand == h) ? 1 : 0);
			int m = hd.bag ? hd.bag.upgrades.Size() : 0;
			if (m == 0) { texts.Push("   (none)"); cols.Push(RSQUI_C_Draw.DIM); sels.Push(0); }
			for (int i = 0; i < m; i++)
				Item(texts, cols, sels, hd.bag.upgrades[i], r && r.kind == 1 && r.hand == h && r.index == i);
			texts.Push("   bond: none"); cols.Push(RSQUI_C_Draw.DIM); sels.Push(0);
		}
		for (int i = 0; i < sels.Size(); i++) if (sels[i]) curLine = i;
		int first = curLine >= maxRows ? curLine - maxRows + 1 : 0;
		for (int i = first; i < texts.Size() && i < first + maxRows; i++)
		{
			bool sel = sels[i] != 0;
			if (sel) pen.Rect(46, y - 3, 548, step - 1, RSQUI_C_Draw.MAGENTA, 0.12 + 0.08 * Pulse());
			pen.Cap(pen.fTerm, 17, (sel ? "> " : "  ") .. texts[i], 50, y, cols[i]);
			y += step;
		}

		// right (610..910): the focused gun's picture, then the description
		int fh = FocusHand();
		let hd = data.hands[fh];
		Color c = fh == 0 ? RSQUI_A_Look.MAIN_EDGE : RSQUI_A_Look.OFF_EDGE;
		RSQUI_C_Draw.Bracket(pen, 610, 72, 30, 30, c);
		RSQUI_C_Draw.Bracket(pen, 910, 222, -30, -30, c);
		if (hd.valid) pen.Picture(RSQUI_GunPic.Get(hd.wpn), 620, 82, 280, 130);
		pen.Cap(pen.fTerm, 16, "> INFO", 610, 236, RSQUI_C_Draw.MAGENTA);
		pen.Para(pen.fTerm, 16, RowDescription(r), 610, 258 - pen.CapTop(pen.fTerm, 16), 300, 19, RSQUI_C_Draw.GREY, 12);
		String ctl = (r && r.kind != 0) ? "ENTER on/off  ←→ level" : "ENTER abilities";
		pen.Cap(pen.fTerm, 16, ctl, 610, 552, RSQUI_C_Draw.WHITE);
	}

	void Section(out Array<String> t, out Array<int> c, out Array<int> s, String text, Color col)
	{
		t.Push(text); c.Push(col); s.Push(0);
	}

	void Item(out Array<String> t, out Array<int> c, out Array<int> s, TFLV_Upgrade_BaseUpgrade up, bool sel)
	{
		String lv = up.level == up.max_level ? String.Format("%d", up.level) : String.Format("%d/%d", up.level, up.max_level);
		t.Push(String.Format("   %s %s%s", RSQUI_Pen.Plain(up.GetName()), lv, up.enabled ? "" : " [off]"));
		c.Push(up.enabled ? RSQUI_C_Draw.WHITE : RSQUI_C_Draw.DIM);
		s.Push(sel ? 1 : 0);
	}
}

// ---- level-up: full-width rows ----------------------------------------------------------------
class RSQUI_C_RowsDraw ui
{
	static void Draw(RSQUI_LevelUpMenu m)
	{
		let pen = m.pen;
		pen.FitBox(960, 600);
		String t = m.title.MakeUpper();
		double ts = 26;
		double tw = pen.Width(pen.fChrome, ts, t);
		if (tw > 880) ts *= 880 / tw;
		pen.TextRaw(pen.fChrome, ts, t, 480, 30 - pen.CapTop(pen.fChrome, ts), 1);
		int n = m.Count();
		int first = m.PageStart();
		for (int k = 0; k < 4 && first + k < n; k++)
			Row(m, first + k, k, 40, 86 + k * 118, 880, 106);
		if (n > 4) pen.Cap(pen.fTerm, 16, String.Format("%d-%d / %d", first + 1, min(n, first + 4), n), 480, 566, RSQUI_C_Draw.GREY, 1);
	}

	static void Row(RSQUI_LevelUpMenu m, int i, int slot, double x, double y, double w, double h)
	{
		let pen = m.pen;
		let up = m.Candidate(i);
		if (!up) return;
		Color c = RSQUI_A_CardsDraw.CardColour(slot);
		bool sel = i == m.sel;
		pen.Rect(x, y, w, h, RSQUI_C_Draw.NAVY, 0.88);
		pen.Rect(x, y, 56, h, c, sel ? 0.55 + 0.25 * m.Pulse() : 0.25);
		if (sel) pen.Frame(x, y, w, h, 2, c);
		else { RSQUI_C_Draw.Bracket(pen, x, y, 30, 30, c); RSQUI_C_Draw.Bracket(pen, x + w, y + h, -30, -30, c); }
		pen.Cap(pen.fPix, 24, String.Format("%d", slot + 1), x + 28, y + h / 2 - 11, sel ? RSQUI_C_Draw.WHITE : c, 1);
		String t = RSQUI_Pen.Plain(up.GetName()).MakeUpper();
		pen.Cap(pen.fOrb, 15, t, x + 74, y + 12, c);
		int own = m.Owned(i);
		pen.Cap(pen.fTerm, 16, own <= 0 ? "new" : String.Format("lv %d > %d", own, own + 1), x + w - 14, y + 12, RSQUI_C_Draw.GREY, 2);
		pen.Para(pen.fTerm, 17, up.GetDesc(), x + 74, y + 40 - pen.CapTop(pen.fTerm, 17), w - 100, 20, RSQUI_C_Draw.WHITE, 3);
	}
}

class RSQUI_C_WeaponLevelUp : RSQUI_WeaponLevelUpMenu
{
	override void Drawer() { RSQUI_C_RowsDraw.Draw(self); }
}

class RSQUI_C_PlayerLevelUp : RSQUI_PlayerLevelUpMenu
{
	override void Drawer() { RSQUI_C_RowsDraw.Draw(self); }
}
