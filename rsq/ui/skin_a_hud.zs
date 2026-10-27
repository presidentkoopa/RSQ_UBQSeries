// SKIN A, IN PLAY (10-27): the recreation of the owner's mockups.
//
// Every number below is measured off the mockups cropped to 960x540 (the game window of
// ab98b8f7/c349c19f, 962x529 px, resized): see the report's crops. The gauges are Gun Bonsai's
// own frame art (LHUDA2/LHDWA2/LHDPA2, ToxicFrog, MIT) -- the mockups ARE that frame, cyan, with a
// body -- drawn 237x79 units, the off hand's flipped. The badge carries the PLAYER's level, the
// text beside it the gun's.
class RSQUI_A_Skin : RSQUI_Skin
{
	RSQUI_Pen pen;
	RSQUI_Data data;

	// the mockups' colours (sampled)
	const C_CYAN    = 0xFF00F0FF;
	const C_ORANGE  = 0xFFFF6A10;
	const C_RED     = 0xFFB02424;
	const C_GREEN   = 0xFF10FF50;
	const C_WHITE   = 0xFFF0F0F0;
	const C_GOLD    = 0xFFFFC020;
	const C_PALE    = 0xFFE8C878;

	override Name StatusMenu() { return 'RSQUI_A_StatusMenu'; }
	override Name WeaponLevelUpMenu() { return 'RSQUI_A_WeaponLevelUp'; }
	override Name PlayerLevelUpMenu() { return 'RSQUI_A_PlayerLevelUp'; }

	void Prepare()
	{
		if (!pen) pen = RSQUI_Pen.Make();
		if (!data) data = RSQUI_Data.Make();
	}

	override bool DrawHud(RenderEvent e)
	{
		Prepare();
		data.Read();
		pen.HudFrame();
		double W = pen.UnitsWide(), H = pen.UnitsHigh();
		if (data.stats)
		{
			// the off hand's gun top left, the main hand's top right: as you hold them
			if (data.hands[1].valid) DrawGauge(data.hands[1], 0, true);
			if (data.hands[0].valid) DrawGauge(data.hands[0], W - 236, false);
		}
		if (data.haveScore) DrawScore(W / 2, 0);
		if (RSQUI_Dispatch.BottomOn()) DrawBottom(W, H);
		return true;
	}

	// ---- the gauge -------------------------------------------------------------------------
	// x = the left edge of the 237x79 frame box. flip: the badge on the right, the blade pointing left.
	void DrawGauge(RSQUI_Hand h, double x, bool flip)
	{
		double y = 8, w = 237, ht = 79;
		bool ready = h.ready || data.pready;
		Color frame = ready ? C_ORANGE : C_CYAN;
		double k = w / 1536.0;  // units per texel of Gun Bonsai's art
		TextureID frm = TexMan.CheckForTexture("LHUDA2", TexMan.Type_Any);

		// Gun Bonsai's frame art is opaque dark grey inside: tinted, that is the body (teal under
		// cyan, rust under orange, as the mockups have it). The bars go on top of it.
		Tex(frm, x, y, w, ht, frame, 1.0, flip);
		// weapon XP: the blade (LHDWA2's quad, texels 493..1406 at the top, ..1333 at the bottom),
		// the full green bar when a level is waiting
		double wp = h.ignored ? 0 : clamp(h.xp / h.xpmax, 0.0, 1.0);
		if (h.ready) BarQuad(x, y, w, flip, 493, 1406, 1333, 298, 365, 1.0, C_GREEN);
		else if (wp > 0) BarQuad(x, y, w, flip, 493, 1406, 1333, 298, 365, wp, C_RED);
		// player XP: the short lower blade (LHDPA2's quad)
		double pp = clamp(double(data.pxp) / data.pmax, 0.0, 1.0);
		if (pp > 0) BarQuad(x, y, w, flip, 492, 793, 743, 402, 435, pp, data.pready ? C_GREEN : C_CYAN);

		// The badge: the player's level over the player's XP (the mockup's "Lv.0" over "1/7").
		// the badge spans texels 60..470 of the art
		double bl = flip ? x + (1536 - 470) * k : x + 60 * k;
		double br = flip ? x + (1536 - 60) * k : x + 470 * k;
		double bc = (bl + br) / 2;
		// mockup (960 crop): badge "Lv.0" caps at y 30 centred, "0/7" caps at 52 ending 13 short of
		// the badge's edge; the tag's caps at 15, "Lv.n (xp/max)" at 35, 3 units off the badge
		pen.Cap(pen.fTerm, 16.6, String.Format("Lv.%d", data.plvl), bc - 2, y + 22, C_WHITE, 1);
		pen.Cap(pen.fTerm, 16.6, String.Format("%d/%d", data.pxp, data.pmax), br - 13, y + 44, C_WHITE, 2);

		// Beside it: the gun's own tag over "Lv.n (xp/max)".
		String lv = h.ignored ? "Lv.- (---/---)" : String.Format("Lv.%d (%d/%d)", h.lvl, h.xp, h.xpmax);
		if (flip)
		{
			pen.Cap(pen.fTerm, 16.6, h.tag, bl - 3, y + 7, C_RED, 2);
			pen.Cap(pen.fTerm, 16.6, lv, bl - 3, y + 27, C_RED, 2);
		}
		else
		{
			pen.Cap(pen.fTerm, 16.6, h.tag, br + 3, y + 7, C_RED, 0);
			pen.Cap(pen.fTerm, 16.6, lv, br + 3, y + 27, C_RED, 0);
		}
	}

	void Tex(TextureID t, double x, double y, double w, double h, Color c, double alpha, bool flip)
	{
		if (!t.IsValid()) return;
		Screen.DrawTexture(t, false, pen.X(x), pen.Y(y),
			DTA_DestWidthF, w * pen.u, DTA_DestHeightF, h * pen.u, DTA_TopLeft, true,
			DTA_Color, c, DTA_Alpha, alpha, DTA_FlipX, flip);
	}

	// A bar filled to frac: the quad's left edge at texel l, its right edge from tr (top) to br
	// (bottom), rows ty..by, all in Gun Bonsai's 1536x512 art; flip mirrors it.
	void BarQuad(double x, double y, double w, bool flip, double l, double tr, double br, double ty, double by, double frac, Color c)
	{
		double k = w / 1536.0;
		double e = l + (tr - l) * frac;
		double xt = min(e, tr), xb = min(e, br);
		if (xt - l < 1) return;
		Array<double> xs, ys;
		xs.Push(x + (flip ? 1536 - l : l) * k);   ys.Push(y + ty * k);
		xs.Push(x + (flip ? 1536 - xt : xt) * k); ys.Push(y + ty * k);
		xs.Push(x + (flip ? 1536 - xb : xb) * k); ys.Push(y + by * k);
		xs.Push(x + (flip ? 1536 - l : l) * k);   ys.Push(y + by * k);
		pen.Poly(xs, ys, c, 1.0);
	}

	// ---- RS Score, top centre ----------------------------------------------------------------
	// The mockup's score line IS RS Score's own look (its font RSSCFON and its bar art), so with
	// RS Score loaded we draw with its assets, moved to the top centre.
	void DrawScore(double cx, double y0)
	{
		Font f = Font.GetFont("RSSCFON");
		String label = "Score: ";
		String num = String.Format("%d", data.score);
		if (f)
		{
			double k = 15.0 / max(1, f.GetHeight()) * pen.u;   // the mockup's cap: 15 units
			double tw = f.StringWidth(label .. num) * k / pen.u;
			double x = cx - tw / 2;
			Screen.DrawText(f, Font.FindFontColor("RSScore_White"), pen.X(x), pen.Y(y0 + 31), label,
				DTA_ScaleX, k, DTA_ScaleY, k);
			Screen.DrawText(f, Font.FindFontColor("RSScore_Gold"), pen.X(x + f.StringWidth(label) * k / pen.u), pen.Y(y0 + 31), num,
				DTA_ScaleX, k, DTA_ScaleY, k);
		}
		else
		{
			double tw = pen.Width(pen.fPix, 14, label .. num);
			pen.Text(pen.fPix, 14, label, cx - tw / 2, y0 + 32, C_WHITE);
			pen.Text(pen.fPix, 14, num, cx - tw / 2 + pen.Width(pen.fPix, 14, label), y0 + 32, C_GOLD);
		}
		// the bar: 140x20 units at y 50 (mockup), a translucent gold pad behind RS Score's bracket
		double bw = 140, bh = 20, bx = cx - bw / 2, by = y0 + 50;
		pen.Rect(bx, by, bw, bh, 0xFF806010, 0.45);
		TextureID bkt = TexMan.CheckForTexture("SCOREBKT", TexMan.Type_Any);
		// RS Score's own choice of art: the life bar when the next reward is a life
		bool life = RSQUI_A_Skin.NextRewardIsLife(data.rewards);
		TextureID bg = TexMan.CheckForTexture(life ? "SCOREBG2" : "SCOREBG1", TexMan.Type_Any);
		TextureID fg = TexMan.CheckForTexture(life ? "SCOREBR2" : "SCOREBR1", TexMan.Type_Any);
		double ix = bx + 6, iw = bw - 12, iy = by + 6, ih = bh - 12;
		if (bkt.IsValid() && bg.IsValid() && fg.IsValid())
		{
			double k = iw / 120.0;
			Screen.DrawTexture(bg, false, pen.X(ix), pen.Y(iy), DTA_DestWidthF, iw * pen.u, DTA_DestHeightF, ih * pen.u, DTA_TopLeft, true);
			Screen.DrawTexture(bkt, false, pen.X(ix - 2 * k), pen.Y(iy - 1 * k), DTA_DestWidthF, 124 * k * pen.u, DTA_DestHeightF, ih * pen.u + 2 * k * pen.u, DTA_TopLeft, true);
			double frac = data.progress / 1000.0;
			if (frac > 0)
				Screen.DrawTexture(fg, false, pen.X(ix), pen.Y(iy), DTA_DestWidthF, iw * pen.u, DTA_DestHeightF, ih * pen.u, DTA_TopLeft, true,
					DTA_ClipRight, int(ceil(pen.X(ix + iw * frac))));
		}
		else
		{
			pen.Rect(ix, iy, iw, ih, 0xFF201000, 0.8);
			pen.Rect(ix, iy, iw * data.progress / 1000.0, ih, C_ORANGE, 1.0);
		}
		// extra lives: RS Score's pips above the line
		if (data.lives > 0)
		{
			TextureID pip = TexMan.CheckForTexture("HUD_LIF1", TexMan.Type_Any);
			int n = min(10, data.lives);
			for (int i = 0; i < n; i++)
				pen.Picture(pip, cx - 7 * (n - 1) + 14 * i - 5, y0 + 18, 10, 10);
		}
	}

	// RS Score's hud.zs DrawBar, transcribed: which reward comes next.
	static bool NextRewardIsLife(int rewards)
	{
		let cv = CVar.FindCVar("rs_score_rewardtypes");
		int t = cv ? cv.GetInt() : 3;
		switch (t)
		{
		case 1: return (rewards % 2) == 0;
		case 2: return false;
		case 3: return true;
		}
		return (rewards % 2) == 1;
	}

	// ---- the bottom: one ammo counter per hand, the face between health and armour ------------
	// Mockup: digits 16 units tall with their top 78 above the bottom, the ammo icon under the
	// reserve (488..520); health and armour digits 24 tall, the row 506..535.
	void DrawBottom(double W, double H)
	{
		Font big = Font.GetFont("HUDFONT_DOOM");
		if (!big) big = BigFont;
		// left hand (the off-hand gun): reserve then magazine
		let off = data.hands[1];
		if (off.wpn && off.reserve >= 0)
		{
			double x = 39;
			double rw = Digits(big, 16, String.Format("%d", off.reserve), x, H - 78, Font.CR_GOLD, 0, 0.75);
			if (off.mag >= 0) Digits(big, 16, String.Format("%d", off.mag), x + rw + 6, H - 78, Font.CR_GOLD, 0);
			pen.Picture(off.ammoIcon, x + rw / 2 - 13, H - 52, 26, 32);
		}
		// right hand (the main gun): magazine then reserve, right-aligned
		let mn = data.hands[0];
		if (mn.wpn && mn.reserve >= 0)
		{
			double xr = W - 39;
			double rw = Digits(big, 16, String.Format("%d", mn.reserve), xr, H - 78, Font.CR_GOLD, 2, 0.75);
			if (mn.mag >= 0) Digits(big, 16, String.Format("%d", mn.mag), xr - rw - 6, H - 78, Font.CR_ORANGE, 2);
			pen.Picture(mn.ammoIcon, xr - rw / 2 - 13, H - 52, 26, 32);
		}
		// centre: health | face | armour
		double cx = W / 2;
		TextureID face = StatusBar ? StatusBar.GetMugshot(5) : TexMan.CheckForTexture("STFST01", TexMan.Type_Any);
		pen.Picture(face, cx - 17, H - 36, 34, 32);
		double hw = Digits(big, 24, String.Format("%d", data.health), cx - 26, H - 33, Font.CR_UNTRANSLATED, 2);
		TextureID med = TexMan.CheckForTexture("MEDIA0", TexMan.Type_Any);
		pen.Picture(med, cx - 26 - hw - 38, H - 34, 32, 29);
		if (data.armor > 0)
		{
			TextureID arm = data.armorIcon.IsValid() ? data.armorIcon : TexMan.CheckForTexture("ARM1A0", TexMan.Type_Any);
			pen.Picture(arm, cx + 26, H - 34, 34, 29);
			Digits(big, 24, String.Format("%d", data.armor), cx + 66, H - 33, Font.CR_UNTRANSLATED, 0);
		}
	}

	// Digits in the game's own HUD font, h units tall; returns the width in units.
	double Digits(Font f, double h, String s, double x, double y, int cr, int align, double alpha = 1.0)
	{
		double k = h / max(1, f.GetHeight()) * pen.u;
		double w = f.StringWidth(s) * k / pen.u;
		if (align == 2) x -= w; else if (align == 1) x -= w / 2;
		Screen.DrawText(f, cr, pen.X(x), pen.Y(y), s, DTA_ScaleX, k, DTA_ScaleY, k, DTA_Alpha, alpha);
		return w;
	}
}
