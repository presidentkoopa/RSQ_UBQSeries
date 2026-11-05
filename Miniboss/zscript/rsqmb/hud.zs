// ============================================================================
// RSQ_Miniboss -- the BOSSFIGHT METER on the HUD (owner 2026-11-05: "under the SCORE word, above the SlowMo countdown
// bar, above the combos").
// WHERE: centred under RSQ Score's bar, asked by name (RS_ScoreService "hud.cx" / "hud.bar.bottom", screen pixels); without
// Score, where Score's defaults would put its bar (the same maths RSQ SlowMo's countdown uses). It answers
// RSQMB_Service "meter.bottom" (ui): RSQ SlowMo's countdown bar sits under that, and RSQ Score's combo rows below both.
// Each mod still places itself when the others are absent. Kept inside the series' safe area (rsq_ui_inset).
// SIZE: a third of the safe height x Meter Size x the series HUD Size (rsq_ui_hud_scale / 1.5) x RSQ Accessibility's Text
// Size, 11:112: the same length and thickness as RSQ SlowMo's countdown bar under it, and the thickness the side gauges have
// for their length (owner 11-05: "all four of these bars should be visually consistent").
// LOOK (owner 11-05: "i don't want it to say Bossfight ready, just give the meter some life when it fills"): coldcite's Top
// HP Bars bar lying down, his rim and the series' well (VisualRewards/tools/gen_gauges.py: graphics/RSQMBHE empty, RSQMBHW
// the fill in white), the same art as the countdown bar and the side gauges. The fill is tinted in steps along the bar, red
// while it fills, gold when full; a band of light sweeps through it and its end breathes, as on the gauges. At its left the
// crowned skull (RSQMBSK0 dim, RSQMBSK1 lit: original pixel art) fills from the jaw up with the meter. FULL, it comes
// alive: the band runs gold, the fill and the skull swell with a slow beat, and a glint crosses the bar every few seconds.
// No words, except the reason when a due Bossfight has to wait (bfWhy, small, on the bar). While a Bossfight runs, the set
// piece's own colour, alive the same way. PHOTOSENSITIVE MODE (RSQ_Accessibility, by name: RSQMB_A11y): no glint, the edge
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
	static ui bool MeterShown() { return BfOn() && UCv("rsqmb_bf_hud", 1) != 0; }

	// x, y, width, height in screen pixels (the bar; the skull sits at its left, SkullRect)
	static ui double, double, double, double MeterRect()
	{
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(CF('rsq_ui_inset', 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double w = ah * 0.32 * clamp(UCv("rsqmb_bf_hud_size", 1.5), 0.5, 2.5) * clamp(CF('rsq_ui_hud_scale', 1.5), 0.4, 2.5) / 1.5
			* RSQMB_A11y.Text();
		w = min(w, aw);
		double h = w * 11.0 / 112.0;
		double cx, below;
		[cx, below] = ScoreSpot();
		// kept between the side gauges' lanes (owner 11-05: the four bars one set; RSQ Gun Bonsai VR's Berserk gauges stand
		// 2.5 to 3.5 gauge widths in from each side, so the bar keeps 4 gauge widths clear; on the rig's square eye the
		// right gauge crossed this bar's end). Centred under Score's bar wherever that fits.
		double lane = ah * 0.32 * clamp(CF('rsq_ui_hud_scale', 1.5), 0.4, 2.5) * 11.0 / 112.0 * 4.0;
		double kw = h * (SKULL + 0.3);     // the skull at its left
		double xlo = sx + lane + kw, xhi = max(xlo, sx + aw - lane - w);
		if (w + kw > aw - 2 * lane) { xlo = sx + kw; xhi = max(xlo, sx + aw - w); }
		double x = clamp(cx - w * 0.5, xlo, xhi);
		double y = clamp(below + h * 0.35, sy, sy + ah - h);
		return x, y, w, h;
	}
	// the crowned skull: a square SKULL x the bar's thickness, a little left of the bar, centred on it
	const SKULL = 1.6;
	static ui double, double, double SkullRect(double x, double y, double h)
	{
		double s = h * SKULL;
		return x - s - h * 0.3, y + (h - s) * 0.5, s;
	}

	// RSQ Score's bar centre and bottom edge, screen pixels; without Score, where its defaults put it (Score hud.zs)
	static ui double, double ScoreSpot()
	{
		let s = ServiceIterator.Find("RS_ScoreService").Next();
		if (s)
		{
			int cx = s.GetIntUI("hud.cx", "", 0, 0, null);
			int bot = s.GetIntUI("hud.bar.bottom", "", 0, 0, null);
			if (cx >= 0 && bot >= 0) return cx, bot;
		}
		double W = Screen.GetWidth(), H = Screen.GetHeight();
		int d = 150;
		double aspect = W / H;
		double scw = round(640 * 100.0 / d), sch = round(480 * 100.0 / d);
		double wide = sch * aspect;
		scw *= max(1.0, aspect / (16.0 / 9.0));
		double cx = Coord(85, wide, 140, wide - scw), cy = Coord(10, sch, 40, 0);
		return cx * W / scw, (cy + 17) * H / sch;
	}
	static ui double Coord(int pos, double range, double padding, double downshift)
	{
		double safe = range - ((range > padding) ? padding : 0.0);
		return safe * (clamp(pos, 0, 100) / 100.0) + (range - safe) * 0.5 - downshift * 0.5;
	}

	// RSQMB_Service "meter.bottom": the pixel row under the meter's slot (the skull's bottom: it hangs a little under the
	// bar), -1 when it is off
	static ui int MeterBottom()
	{
		if (gamestate != GS_LEVEL || !MeterShown()) return -1;
		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		double kx, ky, ks;
		[kx, ky, ks] = SkullRect(x, y, h);
		return int(ceil(max(y + h, ky + ks)));
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
		bool fight = arrPhase != 0 || (bfBoss && !bfBoss.done);
		if (fight || ready) fill = 1.0;
		if (fill > hudShown) hudShown = min(fill, hudShown + dt / 20.0);
		else hudShown = fill;
		bool full = (ready || fight) && hudShown >= 0.999;
		bool photo = RSQMB_A11y.Photo();

		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		// the colours: red while it fills, gold when full (owner's mock-up, 11-05), the set piece's own while one runs
		Color lo, mid, hi;
		if (fight)
		{
			int bi = bfBoss ? bfBoss.idx : bosses.Size();
			mid = PALETTE[bi % PALETTE.Size()];
			lo = Color(255, int(mid.r * 0.35), int(mid.g * 0.35), int(mid.b * 0.35));
			hi = Mix(mid, Color(255, 255, 255, 255), 0.6);
		}
		else if (ready) { lo = Color(255, 190, 120, 10); mid = Color(255, 255, 190, 30); hi = Color(255, 255, 228, 130); }
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

		// ---- words: only why a due Bossfight waits (owner 11-05: no BOSSFIGHT READY) ----
		if (ready && !fight && bfWhy != "")
		{
			Font fnt = NewSmallFont;
			double s = (h * 0.62) / max(1, fnt.GetHeight());
			double tw2 = fnt.StringWidth(bfWhy) * s;
			if (tw2 > w * 0.94) { s *= w * 0.94 / tw2; tw2 = w * 0.94; }
			double vw = Screen.GetWidth() / s, vh = Screen.GetHeight() / s;
			double tx = (x + (w - tw2) * 0.5) / s, ty = (y + (h - fnt.GetHeight() * s) * 0.5) / s;
			Screen.DrawText(fnt, Font.CR_BLACK, tx + 1, ty + 1, bfWhy, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, 0.8);
			Screen.DrawText(fnt, Font.CR_WHITE, tx, ty, bfWhy, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true);
		}
	}
}
