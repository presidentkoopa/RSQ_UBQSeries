// SKIN B, "HEX RAIL" (10-27): the first alternative. Same colours and fonts as A, laid out for
// the headset's near-square layer rather than a 16:9 monitor: compact corner gauges (a hexagon
// badge and a slanted, segmented rail), a status screen that gives the focused gun the whole
// right side, and level-up cards in a 2x2 grid.
class RSQUI_B_Skin : RSQUI_Skin
{
	RSQUI_Pen pen;
	RSQUI_Data data;

	override Name StatusMenu() { return 'RSQUI_B_StatusMenu'; }
	override Name WeaponLevelUpMenu() { return 'RSQUI_B_WeaponLevelUp'; }
	override Name PlayerLevelUpMenu() { return 'RSQUI_B_PlayerLevelUp'; }

	override bool DrawHud(RenderEvent e)
	{
		if (!pen) pen = RSQUI_Pen.Make();
		if (!data) data = RSQUI_Data.Make();
		data.Read();
		pen.HudFrame();
		double W = pen.UnitsWide(), H = pen.UnitsHigh();
		if (data.stats)
		{
			if (data.hands[1].valid) RSQUI_B_Draw.Gauge(pen, data, data.hands[1], 8, 10, true);
			if (data.hands[0].valid) RSQUI_B_Draw.Gauge(pen, data, data.hands[0], W - 8, 10, false);
		}
		if (data.haveScore) RSQUI_B_Draw.Score(pen, data, W / 2, 10);
		if (RSQUI_Dispatch.BottomOn()) RSQUI_B_Draw.Bottom(pen, data, W, H);
		return true;
	}
}

class RSQUI_B_Draw ui
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

	// A flat-topped hexagon of radius r at (cx, cy): fill, then a neon edge.
	static void Hex(RSQUI_Pen pen, double cx, double cy, double r, Color fill, double fa, Color edge, double t = 2)
	{
		Array<double> xs, ys;
		for (int i = 0; i < 6; i++)
		{
			xs.Push(cx + r * cos(60 * i));
			ys.Push(cy + r * sin(60 * i));
		}
		pen.Poly(xs, ys, fill, fa);
		pen.PolyLine(xs, ys, t, edge);
	}

	// A slanted rail (parallelogram) from x0 to x1 at y, height h, slant s (units), filled to frac
	// in segs segments; dir -1 = it grows right to left.
	static void Rail(RSQUI_Pen pen, double x0, double x1, double y, double h, double s, double frac, int segs, Color c, Color edge)
	{
		double a = min(x0, x1), b = max(x0, x1);
		Array<double> xs, ys;
		xs.Push(a + s); ys.Push(y); xs.Push(b + s); ys.Push(y); xs.Push(b); ys.Push(y + h); xs.Push(a); ys.Push(y + h);
		pen.Poly(xs, ys, NAVY, 0.75);
		double seg = (b - a) / segs;
		int lit = int(frac * segs + 0.001);
		for (int i = 0; i < segs; i++)
		{
			int k = x1 < x0 ? segs - 1 - i : i;
			if (k >= lit) continue;
			double sx = a + i * seg + 1.5;
			Array<double> qx, qy;
			qx.Push(sx + s); qy.Push(y + 2); qx.Push(sx + seg - 1.5 + s); qy.Push(y + 2);
			qx.Push(sx + seg - 1.5); qy.Push(y + h - 2); qx.Push(sx); qy.Push(y + h - 2);
			pen.Poly(qx, qy, c, 1.0);
		}
		pen.PolyLine(xs, ys, 1.5, edge);
	}

	// One hand's gauge. ax = the outer edge (left edge for the off hand, right for the main).
	static void Gauge(RSQUI_Pen pen, RSQUI_Data d, RSQUI_Hand h, double ax, double ay, bool left)
	{
		bool ready = h.ready || d.pready;
		Color edge = ready ? ORANGE : CYAN;
		double dir = left ? 1 : -1;
		double hx = ax + dir * 34, hy = ay + 34;
		// the rail first, so the badge sits over its end
		double r0 = hx + dir * 24, r1 = hx + dir * 190;
		double frac = h.ignored ? 0 : clamp(h.xp / h.xpmax, 0, 1);
		Rail(pen, r0, r1, ay + 30, 14, left ? 6 : -6, h.ready ? 1.0 : frac, 12, h.ready ? GREEN : edge, edge);
		Hex(pen, hx, hy, 32, ready ? 0xFF5A1400 : 0xFF064A50, 0.85, edge, 2.5);
		pen.Cap(pen.fPix, 9, String.Format("LV%d", d.plvl), hx, hy - 10, WHITE, 1);
		pen.Cap(pen.fTerm, 15, String.Format("%d/%d", d.pxp, d.pmax), hx, hy + 5, WHITE, 1);
		int al = left ? 0 : 2;
		double tx = hx + dir * 30;
		pen.Cap(pen.fOrb, 12, h.tag, tx, ay + 12, edge, al);
		String lv = h.ignored ? "LV -" : String.Format("LV %d  %d/%d", h.lvl, h.xp, h.xpmax);
		pen.Cap(pen.fTerm, 15, lv, tx, ay + 50, h.ready ? GREEN : GREY, al);
	}

	static void Score(RSQUI_Pen pen, RSQUI_Data d, double cx, double y)
	{
		pen.Cap(pen.fPix, 8, "SCORE", cx, y + 2, GREY, 1);
		pen.Cap(pen.fOrb, 26, String.Format("%d", d.score), cx, y + 16, GOLD, 1);
		pen.Rect(cx - 60, y + 40, 120, 3, NAVY, 0.8);
		pen.Rect(cx - 60, y + 40, 120 * d.progress / 1000.0, 3, ORANGE, 1.0);
		for (int i = 0; i < min(10, d.lives); i++)
			Hex(pen, cx - 6 * (min(10, d.lives) - 1) + 12 * i, y + 50, 4, GOLD, 1.0, GOLD, 1);
	}

	// Bottom: a corner block per hand (magazine big, reserve small, the ammo icon), health | face |
	// armour in the middle on a neon rule.
	static void Bottom(RSQUI_Pen pen, RSQUI_Data d, double W, double H)
	{
		for (int s = 0; s <= 1; s++)
		{
			let hd = d.hands[s];
			if (!hd.wpn || hd.reserve < 0) continue;
			bool left = s == 1;
			double x = left ? 14 : W - 14;
			int al = left ? 0 : 2;
			String big = hd.mag >= 0 ? String.Format("%d", hd.mag) : String.Format("%d", hd.reserve);
			pen.Cap(pen.fPix, 20, big, x, H - 46, hd.mag >= 0 ? GOLD : PALE, al);
			if (hd.mag >= 0) pen.Cap(pen.fTerm, 16, String.Format("/ %d", hd.reserve), x, H - 20, PALE, al);
			double iw = pen.Width(pen.fPix, 20, big);
			pen.Picture(hd.ammoIcon, left ? x + iw + 6 : x - iw - 30, H - 48, 24, 24);
			pen.Rect(left ? x : x - 90, H - 6, 90, 2, left ? ORANGE : CYAN, 0.9);
		}
		double cx = W / 2;
		TextureID face = StatusBar ? StatusBar.GetMugshot(5) : TexMan.CheckForTexture("STFST01", TexMan.Type_Any);
		Hex(pen, cx, H - 24, 22, NAVY, 0.7, MAGENTA, 2);
		pen.Picture(face, cx - 14, H - 37, 28, 26);
		pen.Cap(pen.fPix, 16, String.Format("%d", d.health), cx - 30, H - 32, 0xFFFF3030, 2);
		pen.Cap(pen.fPix, 7, "HP", cx - 30, H - 12, GREY, 2);
		if (d.armor > 0)
		{
			pen.Cap(pen.fPix, 16, String.Format("%d", d.armor), cx + 30, H - 32, GREEN, 0);
			pen.Cap(pen.fPix, 7, "AR", cx + 30, H - 12, GREY, 0);
		}
	}
}

// ---- status: the focused gun gets the right side ----------------------------------------------
class RSQUI_B_StatusMenu : RSQUI_StatusMenu
{
	override void Drawer()
	{
		pen.FitBox(960, 600);
		let L = RSQUI_B_Draw.NAVY;
		// player strip (40..920 x 20..96)
		pen.Rect(40, 20, 880, 76, L, 0.88);
		pen.Neon(40, 20, 880, 76, RSQUI_A_Look.BLUE_EDGE, 2, 0.4);
		pen.Cap(pen.fPix, 10, "PLAYER", 54, 32, RSQUI_A_Look.STEEL);
		pen.Cap(pen.fPix, 18, String.Format("LV %d", data.plvl), 54, 50, RSQUI_B_Draw.WHITE);
		RSQUI_B_Draw.Rail(pen, 180, 420, 54, 14, 6, double(data.pxp) / data.pmax, 7, RSQUI_A_Look.BLUE_EDGE, RSQUI_A_Look.BLUE_EDGE);
		pen.Cap(pen.fTerm, 16, String.Format("%d/%d", data.pxp, data.pmax), 440, 55, RSQUI_A_Look.XP_GREEN);
		// the player's upgrades as chips along the strip's right half
		let r = Row();
		double cx = 520;
		int n = data.pbag ? data.pbag.upgrades.Size() : 0;
		if (n == 0) pen.Cap(pen.fTerm, 15, "No upgrades", 520, 52, RSQUI_B_Draw.DIM);
		for (int i = 0; i < n && cx < 900; i++)
		{
			let up = data.pbag.upgrades[i];
			String t = String.Format("%s %d", RSQUI_Pen.Plain(up.GetName()), up.level);
			double w = pen.Width(pen.fTerm, 15, t) + 14;
			if (cx + w > 910) break;
			bool hot = r && r.kind == 2 && r.index == i;
			pen.Rect(cx, 44, w, 26, hot ? RSQUI_A_Look.BLUE_FILL : 0xFF14243A, 0.95);
			pen.Frame(cx, 44, w, 26, hot ? 2 : 1, RSQUI_A_Look.BLUE_EDGE, hot ? 1.0 : 0.5);
			pen.Cap(pen.fTerm, 15, t, cx + 7, 52, up.enabled ? RSQUI_B_Draw.WHITE : RSQUI_B_Draw.DIM);
			cx += w + 8;
		}

		// gun tabs (40..300 x 110..400)
		for (int h = 0; h <= 1; h++) Tab(h, 40, 110 + h * 148, 260, 140);

		// the focused gun's abilities (316..920 x 110..400)
		int fh = FocusHand();
		let hd = data.hands[fh];
		Color edge = fh == 0 ? RSQUI_A_Look.MAIN_EDGE : RSQUI_A_Look.OFF_EDGE;
		pen.Rect(316, 110, 604, 288, RSQUI_A_Look.PURP_FILL, 0.92);
		pen.Neon(316, 110, 604, 288, RSQUI_A_Look.PURP_EDGE, 2, 0.5);
		pen.Cap(pen.fPix, 10, "ABILITIES", 330, 122, RSQUI_A_Look.LAVENDER);
		pen.Cap(pen.fOrb, 13, hd.valid ? hd.tag : "", 906, 120, edge, 2);
		int m = (hd.valid && hd.bag) ? hd.bag.upgrades.Size() : 0;
		if (m == 0) pen.Cap(pen.fTerm, 16, "No abilities yet", 332, 146, RSQUI_B_Draw.GREY);
		int hot = (r && r.kind == 1 && r.hand == fh) ? r.index : -1;
		int first = hot >= 8 ? hot - 7 : 0;
		for (int i = first; i < m && i < first + 8; i++)
		{
			let up = hd.bag.upgrades[i];
			double y = 142 + (i - first) * 26;
			bool sel = i == hot;
			if (sel) pen.Rect(326, y - 4, 584, 24, 0xFFFFFFFF, 0.08 + 0.06 * Pulse());
			if (sel) pen.Frame(326, y - 4, 584, 24, 1, RSQUI_A_Look.PURP_EDGE);
			pen.Cap(pen.fTerm, 17, RSQUI_Pen.Plain(up.GetName()), 336, y + 2, up.enabled ? RSQUI_B_Draw.WHITE : RSQUI_B_Draw.DIM);
			// level pips
			for (int k = 0; k < int(up.max_level) && k < 10; k++)
				RSQUI_B_Draw.Hex(pen, 700 + k * 16, y + 8, 6, k < int(up.level) ? RSQUI_B_Draw.GOLD : RSQUI_B_Draw.NAVY, 1.0,
					up.enabled ? RSQUI_B_Draw.GOLD : RSQUI_B_Draw.DIM, 1);
			pen.Cap(pen.fPix, 8, up.enabled ? "ON" : "OFF", 900, y + 4, up.enabled ? RSQUI_B_Draw.GREEN : RSQUI_B_Draw.DIM, 2);
		}
		pen.Rect(330, 362, 576, 1, 0xFFA060C0, 0.9);
		pen.Cap(pen.fPix, 8, "BOND", 330, 372, RSQUI_A_Look.LAVENDER);
		pen.Cap(pen.fTerm, 15, "No Bond Unlocked", 380, 371, 0xFFB8A8C0);

		// description (40..920 x 412..580)
		pen.Rect(40, 412, 880, 168, RSQUI_A_Look.DESC_FILL, 0.95);
		pen.Frame(40, 412, 880, 168, 1, RSQUI_A_Look.DESC_EDGE);
		String desc = RowDescription(r);
		pen.Para(pen.fTerm, 17, desc, 56, 426 - pen.CapTop(pen.fTerm, 17), 848, 20, RSQUI_B_Draw.GREY, 5);
		String ctl = (r && r.kind != 0) ? "↵ On/Off   ←→ Level   ↑↓ Move" : "↵ Abilities   ↑↓ Move";
		pen.Cap(pen.fTerm, 16, ctl, 56, 556, RSQUI_B_Draw.WHITE);
	}

	void Tab(int h, double x, double y, double w, double ht)
	{
		let hd = data.hands[h];
		bool main = h == 0;
		Color edge = main ? RSQUI_A_Look.MAIN_EDGE : RSQUI_A_Look.OFF_EDGE;
		bool focus = hd.valid && FocusHand() == h;
		pen.Rect(x, y, w, ht, RSQUI_A_Look.CARD_DARK, 0.92);
		if (focus) pen.Neon(x, y, w, ht, edge, 2, 0.3 + 0.5 * Pulse());
		else pen.Frame(x, y, w, ht, 1, edge, 0.6);
		pen.Cap(pen.fPix, 8, main ? "MAIN" : "OFFHAND", x + 8, y + 8, edge);
		if (!hd.valid) { pen.Cap(pen.fTerm, 15, "Empty", x + 8, y + 60, RSQUI_B_Draw.DIM); return; }
		pen.Picture(RSQUI_GunPic.Get(hd.wpn), x + 8, y + 20, w - 16, 64);
		pen.Cap(pen.fOrb, 13, hd.tag, x + 8, y + 92, RSQUI_B_Draw.WHITE);
		pen.Cap(pen.fPix, 10, hd.ignored ? "LV -" : String.Format("LV %d", hd.lvl), x + 8, y + 112, edge);
		if (!hd.ignored)
		{
			RSQUI_B_Draw.Rail(pen, x + 70, x + w - 10, y + 110, 12, 4, hd.ready ? 1.0 : clamp(hd.xp / hd.xpmax, 0, 1), 10,
				hd.ready ? RSQUI_B_Draw.GREEN : edge, edge);
		}
	}
}

// ---- level-up: a 2x2 grid of wide cards ---------------------------------------------------------
class RSQUI_B_CardsDraw ui
{
	static void Draw(RSQUI_LevelUpMenu m)
	{
		let pen = m.pen;
		pen.FitBox(960, 600);
		String t = m.title.MakeUpper();
		double ts = 30.5;
		double tw = pen.Width(pen.fChrome, ts, t);
		if (tw > 900) ts *= 900 / tw;
		pen.TextRaw(pen.fChrome, ts, t, 480, 40 - pen.CapTop(pen.fChrome, ts), 1);
		int n = m.Count();
		int first = m.PageStart();
		for (int k = 0; k < 4 && first + k < n; k++)
		{
			double x = 40 + (k % 2) * 450, y = 100 + (k / 2) * 230;
			Card(m, first + k, k, x, y, 430, 210);
		}
		if (n > 4) pen.Cap(pen.fPix, 9, String.Format("%d-%d / %d", first + 1, min(n, first + 4), n), 480, 560, RSQUI_B_Draw.GREY, 1);
	}

	static void Card(RSQUI_LevelUpMenu m, int i, int slot, double x, double y, double w, double h)
	{
		let pen = m.pen;
		let up = m.Candidate(i);
		if (!up) return;
		Color c = RSQUI_A_CardsDraw.CardColour(slot);
		bool sel = i == m.sel;
		pen.Rect(x, y, w, h, RSQUI_A_Look.CARD_FILL, 0.9);
		if (sel) pen.Neon(x, y, w, h, c, 3, 0.4 + 0.4 * m.Pulse());
		else pen.Frame(x, y, w, h, 2, c, 0.8);
		// the number in a hexagon, left
		RSQUI_B_Draw.Hex(pen, x + 40, y + 44, 26, sel ? c : RSQUI_B_Draw.NAVY, sel ? 0.35 : 0.9, c, 2.5);
		pen.Cap(pen.fPix, 20, String.Format("%d", slot + 1), x + 41, y + 35, c, 1);
		String t = RSQUI_Pen.Plain(up.GetName()).MakeUpper();
		double ts = 15;
		double tw = pen.Width(pen.fOrb, ts, t);
		if (tw > w - 100) ts *= (w - 100) / tw;
		pen.Cap(pen.fOrb, ts, t, x + 80, y + 22, c);
		int own = m.Owned(i);
		pen.Cap(pen.fPix, 9, own <= 0 ? "NEW" : String.Format("LV %d→%d", own, own + 1), x + 80, y + 46, RSQUI_B_Draw.GREY);
		pen.Para(pen.fTerm, 16, up.GetDesc(), x + 18, y + 84 - pen.CapTop(pen.fTerm, 16), w - 36, 19, RSQUI_B_Draw.WHITE, 6);
	}
}

class RSQUI_B_WeaponLevelUp : RSQUI_WeaponLevelUpMenu
{
	override void Drawer() { RSQUI_B_CardsDraw.Draw(self); }
	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		// a 2x2 grid: up/down jump a row
		int n = Count();
		if (n > 0 && (mkey == MKEY_Up || mkey == MKEY_Down))
		{
			int t = sel + (mkey == MKEY_Down ? 2 : -2);
			if (t >= 0 && t < n) { sel = t; MenuSound("menu/cursor"); }
			return true;
		}
		return super.MenuEvent(mkey, fromcontroller);
	}
}

class RSQUI_B_PlayerLevelUp : RSQUI_PlayerLevelUpMenu
{
	override void Drawer() { RSQUI_B_CardsDraw.Draw(self); }
	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		int n = Count();
		if (n > 0 && (mkey == MKEY_Up || mkey == MKEY_Down))
		{
			int t = sel + (mkey == MKEY_Down ? 2 : -2);
			if (t >= 0 && t < n) { sel = t; MenuSound("menu/cursor"); }
			return true;
		}
		return super.MenuEvent(mkey, fromcontroller);
	}
}
