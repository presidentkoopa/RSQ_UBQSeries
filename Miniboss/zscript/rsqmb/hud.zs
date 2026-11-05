// ============================================================================
// RSQ_Miniboss -- the BOSSFIGHT METER on the HUD (owner 2026-11-05: "under the SCORE word, above the SlowMo countdown
// bar, above the combos").
// WHERE: centred under RSQ Score's bar, asked by name (RS_ScoreService "hud.cx" / "hud.bar.bottom", screen pixels); without
// Score, where Score's defaults would put its bar (the same maths RSQ SlowMo's countdown uses). It answers
// RSQMB_Service "meter.bottom" (ui): RSQ SlowMo's countdown bar sits under that, and RSQ Score's combo rows below both.
// Each mod still places itself when the others are absent. Kept inside the series' safe area (rsq_ui_inset).
// SIZE (owner 11-05: "smaller than the score, neatly fitting centered under it score bar"): the bar is 0.8 of Score's bar
// thickness x Meter Size / 1.5, 11:112, and the row (skull + bar) is never wider than Score's bar; it follows Score's scale and
// so RSQ Accessibility's Text Size. RSQ SlowMo's countdown row under it has the same size and an hourglass where the skull is.
// LOOK (owner 11-05: "i don't want it to say Bossfight ready, just give the meter some life when it fills"): coldcite's Top
// HP Bars bar lying down, his rim and the series' well (VisualRewards/tools/gen_gauges.py: graphics/RSQMBHE empty, RSQMBHW
// the fill in white), the same art as the countdown bar and the side gauges. The fill is tinted in steps along the bar, red
// while it fills, gold when full; a band of light sweeps through it and its end breathes, as on the gauges. At its left the
// crowned skull (RSQMBSK0 dim, RSQMBSK1 lit: original pixel art) fills from the jaw up with the meter. FULL, it comes
// alive: the band runs gold, the fill and the skull swell with a slow beat, and a glint crosses the bar every few seconds.
// No words on the bar; when a due Bossfight has to wait, one small line under it: "No Miniboss: " and the reason (bfWhy).
// HIDDEN while a Bossfight runs (owner 11-05), from its arrival until its miniboss is dead or done: it shows only while it
// fills, when full, and full and waiting with its line. PHOTOSENSITIVE MODE (RSQ_Accessibility, by name: RSQMB_A11y): no glint, the edge
// held still, the beat at most 2.5 a second and dimmed, the band dimmer (as RSQ SlowMo's countdown bar does).
// VR: every piece is a quad cropped from the SOURCE (DTA_SrcX / DTA_SrcY) or a thick line: no clip rectangle and no
// Screen.Dim (neither shows on the projected HUD in VR). Rig only, not headset-confirmed.
// ============================================================================

extend class RSQMB_Handler
{
	ui double hudShown;
	ui double hudLastT;

	static clearscope double UCv(String n, double d)
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return d;
		let c = CVar.GetCVar(n, players[consoleplayer]);
		return c ? c.GetFloat() : d;
	}
	// HIDDEN WHILE A BOSSFIGHT RUNS (owner 11-05): from the arrival through the landing until its miniboss is dead or done,
	// nothing is drawn (and "meter.bottom" answers -1, so RSQ SlowMo's countdown and Score's rows close up under Score)
	static ui bool MeterShown()
	{
		if (!BfOn() || UCv("rsqmb_bf_hud", 1) == 0) return false;
		let hd = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		return !(hd && (hd.arrPhase != 0 || (hd.bfBoss && !hd.bfBoss.done)));
	}

	// x, y, width, height in screen pixels (the bar; the skull sits at its left, SkullRect)
	// SIZE AND PLACE (owner 11-05: "i was expecting them to be smaller than the score, neatly fitting centered under it
	// score bar"): the row -- skull, gap, bar -- is sized from RSQ Score's own bar (its thickness x ROWK x Meter Size / 1.5),
	// never wider than that bar, and centred on it as one group, so it follows Score's scale, Text Size and screen shape.
	// RSQ SlowMo's countdown row under it takes THIS rect's bar left edge, width and thickness while the meter shows
	// (RSQMB_Service "meter.x" / "meter.w" / "meter.h", by name), so the two line up whatever Meter Size and its Bar Size
	// say (owner 11-05); the hourglass is the skull's size.
	// Clear of the side gauges' lanes (RSQ Gun Bonsai VR's Berserk gauges stand 2.5 to 3.5 gauge widths in from each side;
	// 4 kept clear): where Score sits near one, the row shrinks, still centred, rather than moving off Score's centre.
	static ui double, double, double, double MeterRect()
	{
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(CF('rsq_ui_inset', 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double cx, below, sbw;
		[cx, below, sbw] = ScoreSpot();
		double per = 112.0 / 11.0 + SKULL + KGAP;     // the row's width per pixel of bar thickness
		double h = sbw * 8.0 / 120.0 * ROWK * clamp(UCv("rsqmb_bf_hud_size", 1.5), 0.5, 2.5) / 1.5;
		double gw = min(h * per, sbw);
		double lane = ah * 0.32 * clamp(CF('rsq_ui_hud_scale', 1.5), 0.4, 2.5) * 11.0 / 112.0 * 4.0;
		double room = 2.0 * min(cx - (sx + lane), sx + aw - lane - cx);
		if (room >= gw * 0.5) gw = min(gw, room);
		gw = min(gw, aw);
		h = gw / per;
		double gx = clamp(cx - gw * 0.5, sx, max(sx, sx + aw - gw));
		double w = h * 112.0 / 11.0;
		double y = clamp(below + h * (0.3 + 0.25), sy, sy + ah - h);
		return gx + h * (SKULL + KGAP), y, w, h;
	}
	// the crowned skull: a square SKULL x the bar's thickness, KGAP left of the bar, centred on it
	const SKULL = 1.6;
	const KGAP = 0.3;
	const ROWK = 0.8;        // the bar's thickness against Score's bar (8 of 120): smaller than Score
	static ui double, double, double SkullRect(double x, double y, double h)
	{
		double s = h * SKULL;
		return x - s - h * KGAP, y + (h - s) * 0.5, s;
	}

	// RSQ Score's bar centre, bottom edge and width, screen pixels, asked by name; without Score, where its defaults put it
	// (Score hud.zs Layout: x 85, y 10, scale 150 x Text Size, bar 120 wide)
	static ui double, double, double ScoreSpot()
	{
		let s = ServiceIterator.Find("RS_ScoreService").Next();
		if (s)
		{
			int cx = s.GetIntUI("hud.cx", "", 0, 0, null);
			int bot = s.GetIntUI("hud.bar.bottom", "", 0, 0, null);
			int bw = s.GetIntUI("hud.bar.w", "", 0, 0, null);
			if (cx >= 0 && bot >= 0 && bw > 0) return cx, bot, bw;
		}
		double W = Screen.GetWidth(), H = Screen.GetHeight();
		int d = clamp(int(150 * RSQMB_A11y.Text()), 25, 400);
		double aspect = W / H;
		double scw = round(640 * 100.0 / d), sch = round(480 * 100.0 / d);
		double wide = sch * aspect;
		scw *= max(1.0, aspect / (16.0 / 9.0));
		double cx = Coord(85, wide, 140, wide - scw), cy = Coord(10, sch, 40, 0);
		return cx * W / scw, (cy + 17) * H / sch, 120.0 * W / scw;
	}
	static ui double Coord(int pos, double range, double padding, double downshift)
	{
		double safe = range - ((range > padding) ? padding : 0.0);
		return safe * (clamp(pos, 0, 100) / 100.0) + (range - safe) * 0.5 - downshift * 0.5;
	}

	// RSQMB_Service "meter.bottom": the pixel row under the meter's slot (the skull's bottom: it hangs a little under the
	// bar; under the wait line while one shows), -1 when it is off
	static ui int MeterBottom()
	{
		if (gamestate != GS_LEVEL || !MeterShown()) return -1;
		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		double kx, ky, ks;
		[kx, ky, ks] = SkullRect(x, y, h);
		double bot = max(y + h, ky + ks);
		if (WaitLine() != "") bot += h * (WAIT_GAP + WAIT_H);
		return int(ceil(bot));
	}

	// THE WAIT LINE (owner 11-05: "below it we can say No Miniboss: Low Health / No Room"): bfWhy (bossfight.zs Guard /
	// TryArrive, already in his words) while a due Bossfight waits; "" otherwise
	const WAIT_GAP = 0.15;   // under the skull, x the bar's thickness
	const WAIT_H = 0.8;      // its letters' height, x the bar's thickness
	static ui String WaitLine()
	{
		let hd = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!hd || hd.bfWhy == "" || hd.arrPhase != 0 || (hd.bfBoss && !hd.bfBoss.done)) return "";
		if (consoleplayer < 0 || !playeringame[consoleplayer] || !players[consoleplayer].mo) return "";
		let m = RSQMB_Meter(players[consoleplayer].mo.FindInventory("RSQMB_Meter"));
		return (m && m.ready) ? hd.bfWhy : "";
	}

	const SWEEP = 52.0;       // tics for the band to cross the fill (1.5 s), as the countdown bar and the gauges
	const SLICES = 8;         // the fill's colour steps along the bar
	const BEAT = 8.0;         // full: the beat's phase step, degrees per tic (0.8 a second)
	const GLINT_EVERY = 105;  // full: a glint crosses the bar every 3 s ...
	const GLINT_RUN = 12.0;   // ... in 12 tics

	static ui Color Mix(Color a, Color b, double k)
	{
		k = clamp(k, 0.0, 1.0);
		return Color(255, int(a.r + (b.r - a.r) * k), int(a.g + (b.g - a.g) * k), int(a.b + (b.b - a.b) * k));
	}
	static ui Color ByLevel(Color lo, Color mid, Color hi, double f) { return f < 0.5 ? Mix(lo, mid, f * 2.0) : Mix(mid, hi, (f - 0.5) * 2.0); }

	// ONE COLUMN BAND of the bar drawn at x, y, w, h: screen columns a..b, cropped from the source, its own quad
	static ui void Slab(TextureID tw, double x, double y, double w, double h, double a, double b, Color c, double alpha, bool add)
	{
		a = max(a, x);
		b = min(b, x + w);
		if (b <= a || alpha <= 0.0) return;
		Vector2 ts = TexMan.GetScaledSize(tw);
		double srcx = (a - x) / w * ts.x, srcw = (b - a) / w * ts.x;
		Screen.DrawTexture(tw, false, a, y, DTA_DestWidthF, b - a, DTA_DestHeightF, h, DTA_SrcX, srcx, DTA_SrcWidth, srcw,
			DTA_Color, c, DTA_Alpha, alpha, DTA_LegacyRenderStyle, add ? STYLE_Add : STYLE_Translucent);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive || !MeterShown()) return;
		TextureID te = TexMan.CheckForTexture("RSQMBHE", TexMan.Type_Any);
		TextureID tw = TexMan.CheckForTexture("RSQMBHW", TexMan.Type_Any);
		if (!te.IsValid() || !tw.IsValid()) return;
		let m = RSQMB_Meter(players[consoleplayer].mo.FindInventory("RSQMB_Meter"));
		double t = level.maptime + e.FracTic;
		double dt = clamp(t - hudLastT, 0.0, 3.0);
		hudLastT = t;
		double fill = m ? clamp(m.fill / 1000.0, 0.0, 1.0) : 0.0;
		bool ready = m && m.ready;
		if (ready) fill = 1.0;
		if (fill > hudShown) hudShown = min(fill, hudShown + dt / 20.0);
		else hudShown = fill;
		bool full = ready && hudShown >= 0.999;
		bool photo = RSQMB_A11y.Photo();

		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		// the colours: red while it fills, gold when full (owner's mock-up, 11-05)
		Color lo, mid, hi;
		if (ready) { lo = Color(255, 190, 120, 10); mid = Color(255, 255, 190, 30); hi = Color(255, 255, 228, 130); }
		else { lo = Color(255, 90, 10, 8); mid = Color(255, 220, 40, 30); hi = Color(255, 255, 150, 120); }
		// full: a slow beat (0..1), capped and dimmed in Photosensitive Mode
		double beat = full ? 0.5 + 0.5 * sin(t * RSQMB_A11y.Deg(BEAT)) : 0.0;
		double beatK = photo ? 0.5 : 1.0;

		// ---- the bar: empty, the fill in steps, the beat, the band, the edge, the glint ----
		Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9);
		double right = x + w * hudShown;
		if (hudShown > 0.001)
		{
			for (int i = 0; i < SLICES; i++)
			{
				double s0 = x + w * double(i) / SLICES, s1 = x + w * double(i + 1) / SLICES;
				if (s0 >= right) break;
				double k01 = (i + 0.5) / SLICES;
				Slab(tw, x, y, w, h, int(s0), int(ceil(min(right, s1))), ByLevel(lo, mid, hi, min(k01, max(hudShown, 0.75))), 1.0, false);
			}
			if (full) Slab(tw, x, y, w, h, x, right, hi, 0.28 * beat * beatK, true);
			// the band: an eighth of the bar wide, sweeping left to right through the fill (brighter when full)
			double ph = (t % SWEEP) / SWEEP;
			double bw = w * 0.125;
			double bR = x + (w * hudShown + bw) * ph;
			double bL = bR - bw;
			if (bL < right)
				Slab(tw, x, y, w, h, int(max(x, bL)), int(min(right, bR)), hi, (photo ? 0.25 : (full ? 0.55 : 0.45)), true);
			if (!full)
			{
				// the edge: a bright line where the fill ends, breathing (held still in Photosensitive Mode)
				double glow = photo ? 0.8 : 0.55 + 0.45 * sin(t * 12.0);
				Screen.DrawThickLine(int(right), int(y), int(right), int(y + h), max(1.0, w / 90.0), hi, int(255 * glow));
			}
			else if (!photo)
			{
				// the glint: a narrow streak of white light running across the whole bar every few seconds
				double ga = (level.maptime % GLINT_EVERY) + e.FracTic;
				if (ga < GLINT_RUN)
				{
					double gw = w * 0.06;
					double gR = x + (w + gw) * (ga / GLINT_RUN);
					Slab(tw, x, y, w, h, int(gR - gw), int(gR), Color(255, 255, 255, 255), 0.85, true);
				}
			}
		}

		// ---- the crowned skull at its left: dim, the lit one rising from the jaw with the fill; full, it beats ----
		TextureID k0 = TexMan.CheckForTexture("RSQMBSK0", TexMan.Type_Any);
		TextureID k1 = TexMan.CheckForTexture("RSQMBSK1", TexMan.Type_Any);
		if (k0.IsValid() && k1.IsValid())
		{
			double kx, ky, ks;
			[kx, ky, ks] = SkullRect(x, y, h);
			Vector2 kz = TexMan.GetScaledSize(k1);
			if (hudShown < 0.999)
				Screen.DrawTexture(k0, false, kx, ky, DTA_DestWidthF, ks, DTA_DestHeightF, ks, DTA_Alpha, 0.95);
			// the lit skull from the bottom up to the fill, cropped from the source in whole texels (crisp pixel art)
			int rows = int(round(kz.y * hudShown));
			if (rows > 0)
			{
				double top = ky + ks * (1.0 - rows / kz.y);
				Screen.DrawTexture(k1, false, kx, top, DTA_DestWidthF, ks, DTA_DestHeightF, ky + ks - top,
					DTA_SrcY, kz.y - rows, DTA_SrcHeight, double(rows), DTA_Alpha, 0.95);
			}
			if (full)
				Screen.DrawTexture(k1, false, kx, ky, DTA_DestWidthF, ks, DTA_DestHeightF, ks, DTA_Color, hi,
					DTA_Alpha, 0.45 * beat * beatK, DTA_LegacyRenderStyle, STYLE_Add);
		}

		// ---- words: one small line under the meter while a due Bossfight waits ("No Miniboss: Low Health"); none on it ----
		String why = WaitLine();
		if (why != "")
		{
			double kx, ky, ks;
			[kx, ky, ks] = SkullRect(x, y, h);
			double gl = kx, gw = x + w - kx;     // the row: skull to the bar's right end
			Font fnt = NewSmallFont;
			double s = (h * WAIT_H) / max(1, fnt.GetHeight());
			double tw2 = fnt.StringWidth(why) * s;
			if (tw2 > gw) { s *= gw / tw2; tw2 = gw; }
			double vw = Screen.GetWidth() / s, vh = Screen.GetHeight() / s;
			double tx = (gl + (gw - tw2) * 0.5) / s, ty = (max(y + h, ky + ks) + h * WAIT_GAP) / s;
			Screen.DrawText(fnt, Font.CR_BLACK, tx + 1, ty + 1, why, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, 0.8);
			Screen.DrawText(fnt, Font.CR_WHITE, tx, ty, why, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true);
		}
	}
}
