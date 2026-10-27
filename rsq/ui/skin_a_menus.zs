// SKIN A, THE SCREENS (10-27): the status screen and the level-up cards, as the owner's mockups
// draw them. All coordinates are units of the 960x540 mockup crop (status_mock.png and
// levelup_mock.png in the report); the pen fits that box into the headset's safe area.

// Shared look: the colours sampled off the mockups.
class RSQUI_A_Look ui
{
	const NAVY      = 0xFF0E0A1C;   // outer panel body
	const BAND      = 0xFF1A1733;   // title band
	const EDGE      = 0xFF4F3275;   // outer panel edge
	const BLUE_FILL = 0xFF1E4F7C;   // player status panel
	const BLUE_EDGE = 0xFF8DD3EE;
	const BLUE_DIM  = 0xFF5A8CB4;
	const STEEL     = 0xFFC4CEDE;   // blue panel labels
	const PURP_FILL = 0xFF4E2468;   // weapon status panels
	const PURP_EDGE = 0xFFDD80F3;
	const LAVENDER  = 0xFFD9A8F0;
	const CARD_DARK = 0xFF120B17;
	const PIC_DARK  = 0xFF080814;
	const MAIN_EDGE = 0xFF98DEFC;
	const OFF_EDGE  = 0xFFF5BF21;
	const MAIN_LV   = 0xFF6DB8EC;
	const OFF_LV    = 0xFFF0A818;
	const XP_GREEN  = 0xFF5CE05C;
	const DESC_FILL = 0xFF0E0818;
	const DESC_EDGE = 0xFF5C4E7B;
	const MAGENTA   = 0xFFD070E0;
	const WHITE     = 0xFFF2F2F2;
	const GREY      = 0xFFB4B4BC;
	const DIMGREY   = 0xFF6E6E78;
	const GOLD      = 0xFFF0C020;
	const TRACK     = 0xFF4A2A3A;
	const CARD_FILL = 0xFF170D26;
}

// Gun pictures: graphics/rsqui/guns/<class>.png made by tools/rsqui_gunshots.py from the gun's
// own model on the rig; without one, the weapon's own icon or pickup sprite.
class RSQUI_GunPic ui
{
	static TextureID Get(Weapon w)
	{
		TextureID t;
		t.SetInvalid();
		if (!w) return t;
		String cls = w.GetClassName();
		t = TexMan.CheckForTexture("graphics/rsqui/guns/" .. cls .. ".png", TexMan.Type_Any);
		if (t.IsValid()) return t;
		t = w.Icon;
		if (t.IsValid()) return t;
		let st = w.SpawnState;
		if (st) t = st.GetSpriteTexture(0);
		if (t.IsValid() && TexMan.GetName(t) != "TNT1A0") return t;
		// a fist has no pickup: its raised frame
		st = w.FindState("Ready");
		if (st) t = st.GetSpriteTexture(0);
		if (t.IsValid() && TexMan.GetName(t) == "TNT1A0") t.SetInvalid();
		return t;
	}
}

class RSQUI_A_StatusMenu : RSQUI_StatusMenu
{
	override void Drawer()
	{
		pen.FitBox(960, 540);
		// outer panel 75..884 x 54..477
		pen.Rect(75, 54, 809, 423, RSQUI_A_Look.NAVY, 0.90);
		pen.Frame(75, 54, 809, 423, 2, RSQUI_A_Look.EDGE);
		pen.Rect(77, 56, 805, 30, RSQUI_A_Look.BAND, 0.95);
		Label("STATUS", 85, 64, 11, RSQUI_A_Look.STEEL);

		DrawPlayerPanel();
		for (int h = 0; h <= 1; h++) DrawGun(h);
		DrawDescription();
	}

	// ---- left: PLAYER STATUS (84..351 x 87..384) ----
	void DrawPlayerPanel()
	{
		pen.Rect(84, 87, 267, 297, RSQUI_A_Look.BLUE_FILL, 0.95);
		pen.Neon(84, 87, 267, 297, RSQUI_A_Look.BLUE_EDGE, 2, 0.5);
		Label("PLAYER STATUS", 95, 98, 11, RSQUI_A_Look.STEEL);
		Body("Level", 95, 119, 16, RSQUI_A_Look.WHITE);
		Body(String.Format("%d", data.plvl), 343, 119, 16, RSQUI_A_Look.WHITE, 2);
		Body("XP", 95, 140, 16, RSQUI_A_Look.WHITE);
		Body(String.Format("%d / %d", data.pxp, data.pmax), 343, 140, 16, RSQUI_A_Look.XP_GREEN, 2);
		pen.Rect(94, 158, 249, 4, RSQUI_A_Look.TRACK, 1.0);
		pen.Rect(94, 158, 249 * clamp(double(data.pxp) / data.pmax, 0, 1), 4, RSQUI_A_Look.BLUE_EDGE, 1.0);
		pen.Rect(94, 169, 249, 1, RSQUI_A_Look.BLUE_DIM, 1.0);
		Label("UPGRADES", 95, 175, 11, RSQUI_A_Look.STEEL);
		// the player's upgrades (bag 0), 6 rows from y 195
		int n = data.pbag ? data.pbag.upgrades.Size() : 0;
		if (n == 0) Body("(no upgrades yet)", 100, 195, 16, RSQUI_A_Look.GREY);
		else DrawList(data.pbag, 2, 0, 98, 195, 245, 6, 18);
		// ITEMS: vestigial, five empty slots
		Label("ITEMS", 95, 316, 11, RSQUI_A_Look.STEEL);
		for (int i = 0; i < 5; i++)
		{
			pen.Rect(94 + i * 50, 329, 44, 45, 0xFF173656, 1.0);
			pen.Frame(94 + i * 50, 329, 44, 45, 1, 0xFF3C6C94);
		}
	}

	// ---- middle (a gun card) and right (its WEAPON STATUS / WEAPON BOND) ----
	void DrawGun(int h)
	{
		let hd = data.hands[h];
		double dy = h == 1 ? 153 : 0;
		bool main = h == 0;
		Color edge = main ? RSQUI_A_Look.MAIN_EDGE : RSQUI_A_Look.OFF_EDGE;
		Color lvc = main ? RSQUI_A_Look.MAIN_LV : RSQUI_A_Look.OFF_LV;
		bool focus = hd.valid && FocusHand() == h;

		// card backdrop 352..566 and the focus halo
		pen.Rect(352, 80 + dy, 214, 151, RSQUI_A_Look.CARD_DARK, 0.92);
		if (focus) pen.Neon(353, 81 + dy, 212, 149, edge, 1, 0.25 + 0.5 * Pulse());
		// picture frame 361..563 x 87..177
		pen.Rect(363, 89 + dy, 198, 86, RSQUI_A_Look.PIC_DARK, 1.0);
		pen.Rect(363, 89 + dy, 198, 30, main ? 0xFF14203A : 0xFF2A1A0A, 0.9);
		if (hd.valid)
		{
			TextureID pic = RSQUI_GunPic.Get(hd.wpn);
			if (!pen.Picture(pic, 372, 100 + dy, 180, 70))
				Body("?", 462, 120 + dy, 24, RSQUI_A_Look.DIMGREY, 1);
		}
		pen.Neon(361, 87 + dy, 202, 90, edge, 2, 0.4);
		pen.Frame(364, 90 + dy, 196, 84, 1, edge, 0.45);
		Label(main ? "MAIN" : "OFFHAND", 365, 90 + dy, 9, edge);

		if (hd.valid)
		{
			Body(hd.tag, 363, 184 + dy, 20.5, RSQUI_A_Look.WHITE);
			pen.Cap(pen.fPix, 13, hd.ignored ? "LV -" : String.Format("LV %d", hd.lvl), 363, 208 + dy, lvc);
			if (!hd.ignored)
				Body(String.Format("%d/%d", hd.xp, hd.xpmax), 564, 212 + dy, 16.5, hd.ready ? RSQUI_A_Look.GOLD : RSQUI_A_Look.XP_GREEN, 2);
		}
		else Body(main ? "(empty hand)" : "(no off-hand gun)", 363, 190 + dy, 16, RSQUI_A_Look.DIMGREY);

		// right: 565..875 x 87..229 (main) / 240..384 (off)
		double py = main ? 87 : 240, ph = main ? 142 : 144;
		pen.Rect(565, py, 310, ph, RSQUI_A_Look.PURP_FILL, 0.95);
		pen.Neon(565, py, 310, ph, RSQUI_A_Look.PURP_EDGE, 2, focus ? 0.7 : 0.35);
		Label("WEAPON STATUS", 575, py + 8, 10, RSQUI_A_Look.LAVENDER);
		int n = (hd.valid && hd.bag) ? hd.bag.upgrades.Size() : 0;
		if (n == 0) Body("(no upgrades yet)", 578, py + 26, 16, RSQUI_A_Look.GREY);
		else DrawList(hd.bag, 1, h, 576, py + 27, 290, 3, 18);
		double sy = py + 84;
		pen.Rect(575, sy, 290, 1, 0xFFA060C0, 0.9);
		Label("WEAPON BOND", 575, sy + 6, 10, RSQUI_A_Look.LAVENDER);
		Body("No Bond Unlocked", 575, sy + 24, 15, 0xFFE8D8E8);
		Body("Bond perks unlock later.", 575, sy + 44, 13, 0xFFB8A8C0);
	}

	// A scrolling list of a bag's upgrades: name, then the level (gold) -- "Explosive Death  1".
	// kind/hand say which rows of the cursor belong to it.
	void DrawList(TFLV_Upgrade_UpgradeBag bag, int kind, int hand, double x, double y, double w, int vis, double step)
	{
		int n = bag.upgrades.Size();
		let r = Row();
		int hot = -1;
		if (r && r.kind == kind && (kind == 2 || r.hand == hand)) hot = r.index;
		int first = 0;
		if (hot >= vis) first = hot - vis + 1;
		for (int i = first; i < n && i < first + vis; i++)
		{
			let up = bag.upgrades[i];
			double yy = y + (i - first) * step;
			bool sel = i == hot;
			if (sel)
			{
				pen.Rect(x - 4, yy - 2, w, step - 1, 0xFFFFFFFF, 0.10 + 0.08 * Pulse());
				pen.Frame(x - 4, yy - 2, w, step - 1, 1, kind == 2 ? RSQUI_A_Look.BLUE_EDGE : RSQUI_A_Look.PURP_EDGE, 0.9);
			}
			Color nc = up.enabled ? RSQUI_A_Look.WHITE : RSQUI_A_Look.DIMGREY;
			String nm = RSQUI_Pen.Plain(up.GetName());
			if (!up.enabled) nm = "[OFF] " .. nm;
			Body(nm, x + 2, yy, 16, nc);
			String lv = up.level == up.max_level ? String.Format("%d", up.level) : String.Format("%d/%d", up.level, up.max_level);
			Body(lv, x + w - 12, yy, 16, up.enabled ? RSQUI_A_Look.GOLD : RSQUI_A_Look.DIMGREY, 2);
		}
		if (first > 0) Body("↑", x + w - 2, y - 4, 12, RSQUI_A_Look.GREY, 2);
		if (first + vis < n) Body("↓", x + w - 2, y + (vis - 1) * step + 6, 12, RSQUI_A_Look.GREY, 2);
	}

	// ---- bottom: DESCRIPTION (84..875 x 390..476) ----
	void DrawDescription()
	{
		pen.Rect(84, 390, 791, 86, RSQUI_A_Look.DESC_FILL, 0.96);
		pen.Frame(84, 390, 791, 86, 1, RSQUI_A_Look.DESC_EDGE);
		Label("DESCRIPTION", 94, 396, 10, RSQUI_A_Look.MAGENTA);
		let r = Row();
		String d = RowDescription(r);
		double y = 413;
		if (d != "") y = pen.Para(pen.fTerm, 15.6, d, 96, 413 - pen.CapTop(pen.fTerm, 15.6), 770, 17, RSQUI_A_Look.GREY, 2);
		if (r && r.kind != 0)
		{
			// the mockup's two control lines (Gun Bonsai's own help text), side by side
			Body("↵ Toggle upgrade", 94, 453, 15.6, RSQUI_A_Look.WHITE);
			Body("←→ Adjust upgrade level", 290, 453, 15.6, RSQUI_A_Look.WHITE);
		}
		else if (r)
		{
			Body("↵ Abilities", 94, 453, 15.6, RSQUI_A_Look.WHITE);
			Body("↑↓ Select gun", 290, 453, 15.6, RSQUI_A_Look.WHITE);
		}
	}

	// Labels: Orbitron Bold sized by the mockup's cap height (its capitals are 0.72 of the em).
	void Label(String s, double x, double capTop, double capH, Color c, int align = 0)
	{
		pen.Cap(pen.fOrb, capH / 0.72, s, x, capTop, c, align);
	}
	// Body: VT323, size = twice the mockup's advance per letter.
	void Body(String s, double x, double capTop, double size, Color c, int align = 0)
	{
		pen.Cap(pen.fTerm, size, s, x, capTop, c, align);
	}
}

// ---- the level-up cards ----------------------------------------------------------------------
class RSQUI_A_CardsDraw ui
{
	// card colours, left to right (mockup: orange, cyan, magenta, green)
	static Color CardColour(int i)
	{
		switch (i % 4)
		{
		case 0: return 0xFFFFA514;
		case 1: return 0xFF45C8DC;
		case 2: return 0xFFE05CD8;
		}
		return 0xFF9CFF58;
	}

	// The whole screen: the chrome title, then up to four cards 228x290 at y 124.
	static void Draw(RSQUI_LevelUpMenu m)
	{
		let pen = m.pen;
		pen.FitBox(960, 540);
		// the title: Orbitron chrome, cap 22 units with its top at y 78
		String t = m.title.MakeUpper();
		double ts = 30.5;   // cap 22 units: Orbitron's capitals are 0.72 of the em
		double tw = pen.Width(pen.fChrome, ts, t);
		if (tw > 900) ts *= 900 / tw;
		pen.TextRaw(pen.fChrome, ts, t, 480, 78 - pen.CapTop(pen.fChrome, ts), 1);

		int n = m.Count();
		int first = m.PageStart();
		int shown = min(4, n - first);
		// the mockup's four cards span 2..957; fewer cards stay the same size, centred
		double cw = 228, gap = 14;
		double total = shown * cw + (shown - 1) * gap;
		double x0 = 480 - total / 2;
		for (int k = 0; k < shown; k++)
		{
			int i = first + k;
			DrawCard(m, i, k, x0 + k * (cw + gap), 124, cw, 290);
		}
		if (n > 4)
		{
			String pg = String.Format("%d-%d / %d", first + 1, first + shown, n);
			pen.Text(pen.fPix, 9, pg, 480, 424, RSQUI_A_Look.GREY, 1);
			if (first > 0) pen.Text(pen.fPix, 14, "←", x0 - 22, 262, RSQUI_A_Look.WHITE, 1);
			if (first + shown < n) pen.Text(pen.fPix, 14, "→", x0 + total + 22, 262, RSQUI_A_Look.WHITE, 1);
		}
	}

	static void DrawCard(RSQUI_LevelUpMenu m, int i, int slot, double x, double y, double w, double h)
	{
		let pen = m.pen;
		let up = m.Candidate(i);
		if (!up) return;
		Color c = CardColour(slot);
		bool sel = i == m.sel;
		// body, then the mockup's double outline: bright 2 units outside, dim 2 units inside
		pen.Rect(x, y, w, h, RSQUI_A_Look.CARD_FILL, 0.90);
		if (sel)
		{
			double p = m.Pulse();
			pen.Frame(x - 6, y - 6, w + 12, h + 12, 3, c, 0.12 + 0.18 * p);
			pen.Frame(x - 3, y - 3, w + 6, h + 6, 2, c, 0.35 + 0.3 * p);
			pen.Rect(x + 4, y + 4, w - 8, h - 8, c, 0.06 + 0.04 * p);
		}
		else pen.Frame(x - 2, y - 2, w + 4, h + 4, 2, c, 0.18);
		pen.Frame(x, y, w, h, 2, c, 1.0);
		pen.Frame(x + 3, y + 3, w - 6, h - 6, 2, c, 0.45);

		// title: card colour, as large as fits (mockup: 9.3 for 21 letters, 12.6 for 14)
		// title: Orbitron in the card colour, as large as fits (mockup: cap 8 for 21 letters, 10 for 14)
		String t = RSQUI_Pen.Plain(up.GetName()).MakeUpper();
		double ts = 14;
		double tw = pen.Width(pen.fOrb, ts, t);
		if (tw > w - 16) ts *= (w - 16) / tw;
		pen.Cap(pen.fOrb, ts, t, x + w / 2, y + 13 + (14 - ts) * 0.36, c, 1);

		// description: VT323 14.5, 18 units a line, from 44 below the top
		pen.Para(pen.fTerm, 14.5, up.GetDesc(), x + 10, y + 43 - pen.CapTop(pen.fTerm, 14.5), w - 20, 18, RSQUI_A_Look.WHITE, 6);

		// the icon box (100x100 at 114,161 in the card) -- Gun Bonsai has no icons: it carries the
		// level this choice takes the ability to
		double bx = x + 113, by = y + 161;
		pen.Rect(bx, by, 100, 100, 0xFF0C0818, 0.95);
		pen.Frame(bx, by, 100, 100, 2, c, 1.0);
		int own = m.Owned(i);
		if (own <= 0) pen.Text(pen.fPix, 12, "NEW", bx + 50, by + 44, c, 1, 0.9);
		else
		{
			pen.Text(pen.fPix, 10, "LV", bx + 50, by + 30, c, 1, 0.9);
			pen.Text(pen.fPix, 14, String.Format("%d→%d", own, own + 1), bx + 50, by + 50, c, 1, 0.95);
		}

		// the number, bottom left, with a glow
		String num = String.Format("%d", slot + 1);
		pen.Text(pen.fPix, 18, num, x + 11, y + 255, c, 0, 0.35);
		pen.Text(pen.fPix, 16, num, x + 12, y + 256, c, 0);
	}
}

class RSQUI_A_WeaponLevelUp : RSQUI_WeaponLevelUpMenu
{
	override void Drawer() { RSQUI_A_CardsDraw.Draw(self); }
}

class RSQUI_A_PlayerLevelUp : RSQUI_PlayerLevelUpMenu
{
	override void Drawer() { RSQUI_A_CardsDraw.Draw(self); }
}
