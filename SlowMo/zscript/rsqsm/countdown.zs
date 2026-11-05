// THE REAL-TIME COUNTDOWN BAR (owner, 2026-11-03 19:06: "another UI bar, like the two you designed. This one would live
// below the score bar but above where the combos appear. Horizontal, and count down whenever we slow time outside of player
// choice -- this would help the player understand when they will be back in real time. Green, with the standard
// Accessibility options. Animated with life like the other two bars.")
//
// WHEN: only while a slow NOT of the player's own choosing runs (clock.zs OwnCat / CountdownTick: his key, wrist cross,
// burst, Wheel, Accessibility button and shootdodge are his; a mod's pulse -- a kill moment, the miniboss window, the
// cigarette, Gun Bonsai VR, Score, the named door -- and close-call / reload are forced). It holds the REAL time left until
// the world is at full speed (the hold, then the ease out), empties evenly to zero (level.maptime is never slowed, and the
// frame's FracTic makes it smooth), then fades. A pulse that pushes the end later refills it smoothly, with a glint.
// WHERE: centred under RSQ Score's bar and above its combo rows, read by name (RS_ScoreService "hud.cx" /
// "hud.bar.bottom"; Score moves its rows below this slot, asking "countdown.bottom" back). Without Score, the spot Score's
// defaults would put its bar on. Kept inside the series' safe area (rsq_ui_inset).
// SIZE (owner 11-05: "smaller than the score, neatly fitting centered under it score bar"): 0.8 of Score's bar thickness x
// Bar Size / 1.5, 11:112; the row (hourglass + bar) never wider than Score's bar, centred on it; it follows Score's scale and
// so RSQ Accessibility's Text Size. An original pixel-art hourglass (RSQSMHG, gen_gauges.py) at its left, the skull's size.
// LOOK: coldcite's Top HP Bars bar (the gauges' family and their rim and well, VisualRewards/tools/gen_gauges.py; owner 11-05:
// "all four of these bars should be visually consistent"), tinted Green or the chosen colour (Random: a
// fresh one each time it appears), darker as it empties. Alive (Bar Animation): a light band sweeps along the fill, the
// fill's end breathes, a refill glints. ACCESSIBILITY (RSQ_Accessibility, by name): the colour-blind palette's "have"
// colour replaces the hue; Photosensitive Mode drops the glint and holds the edge still (the band stays, dimmer).
// VR: every piece is a quad cropped from the SOURCE (DTA_SrcX / DTA_SrcWidth + DTA_DestWidthF) or a thick line: no clip
// rectangle, whose scissor misses the projected HUD in VR (gauge.zs Slab, commit ff21977ce).
class RSQSM_Countdown : StaticEventHandler
{
	const FADE_IN = 5.0;      // tics
	const FADE_OUT = 14.0;    // tics (0.4 s)
	const REFILL = 8.0;       // tics for a refill to climb the whole bar
	const GLINT = 12.0;       // tics a refill's glint lasts
	const SWEEP = 52.0;       // tics for the band to cross the fill (1.5 s)
	const SLICES = 8;
	const RANDOM = 98;

	ui double shown;          // the fraction drawn (a refill climbs to the clock's; emptying follows it exactly)
	ui double lastT;
	ui int lastStart;

	static clearscope double UCv(String n, double d) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetFloat() : d; }
	static clearscope double SCv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope bool Enabled() { return UCv("rsqsm_cdbar", 1) != 0; }

	// ---- where it goes, in screen pixels: x, y, width, height (the bar; the hourglass sits at its left, GlassRect) ----
	// SIZE AND PLACE (owner 11-05: "i was expecting them to be smaller than the score, neatly fitting centered under it
	// score bar"): the row -- hourglass, gap, bar -- is sized from RSQ Score's own bar (its thickness x ROWK x Bar Size / 1.5),
	// never wider than that bar, and centred on it as one group; it follows Score's scale, Text Size and screen shape. RSQ
	// Miniboss's Bossfight meter row above uses the same maths and the same icon size (its crowned skull), so they line up.
	// Clear of the side gauges' lanes (RSQ Gun Bonsai VR's Berserk gauges stand 2.5 to 3.5 gauge widths in from each side; 4
	// kept clear): where Score sits near one, the row shrinks, still centred, rather than moving off Score's centre.
	const GLASS = 1.6;       // the hourglass: a square GLASS x the bar's thickness (the skull's size) ...
	const KGAP = 0.3;        // ... KGAP left of the bar
	const ROWK = 0.8;        // the bar's thickness against Score's bar (8 of 120): smaller than Score
	static ui double, double, double, double Rect()
	{
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(SCv("rsq_ui_inset", 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double cx, below, sbw;
		[cx, below, sbw] = ScoreSpot();
		double per = 112.0 / 11.0 + GLASS + KGAP;     // the row's width per pixel of bar thickness
		double h = sbw * 8.0 / 120.0 * ROWK * clamp(UCv("rsqsm_cdbar_size", 1.5), 0.5, 2.5) / 1.5;
		double gw = min(h * per, sbw);
		double lane = ah * 0.32 * clamp(SCv("rsq_ui_hud_scale", 1.5), 0.4, 2.5) * 11.0 / 112.0 * 4.0;
		double room = 2.0 * min(cx - (sx + lane), sx + aw - lane - cx);
		if (room >= gw * 0.5) gw = min(gw, room);
		gw = min(gw, aw);
		h = gw / per;
		double gx = clamp(cx - gw * 0.5, sx, max(sx, sx + aw - gw));
		double w = h * 112.0 / 11.0;
		double y = clamp(below + h * (0.3 + 0.25), sy, sy + ah - h);
		return gx + h * (GLASS + KGAP), y, w, h;
	}
	static ui double, double, double GlassRect(double x, double y, double h)
	{
		double s = h * GLASS;
		return x - s - h * KGAP, y + (h - s) * 0.5, s;
	}
	// the pixel row under the row (the hourglass hangs a little under the bar): RSQSM_Service "countdown.bottom"
	static ui int Bottom()
	{
		double x, y, w, h;
		[x, y, w, h] = Rect();
		return int(ceil(y + h * (1.0 + (GLASS - 1.0) * 0.5)));
	}

	// RSQ Score's bar: its centre, its bottom edge and its width, in screen pixels, asked by name; without Score (or an older
	// one that does not answer), where Score's own defaults (x 85, y 10, scale 150 x Text Size, bar 120) put it (Score hud.zs)
	// RSQ MINIBOSS'S BOSSFIGHT METER (owner 11-05: under the score, above this bar) sits between: asked by name
	// (RSQMB_Service "meter.bottom", screen pixels, -1 off; under its wait line while one shows), this row goes under it.
	static ui double, double, double ScoreSpot()
	{
		double cx, bot, bw;
		[cx, bot, bw] = ScoreSpot2();
		let m = ServiceIterator.Find("RSQMB_Service").Next();
		if (m) { int mb = m.GetIntUI("meter.bottom", "", 0, 0, null); if (mb > bot) bot = mb; }
		return cx, bot, bw;
	}
	static ui double, double, double ScoreSpot2()
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
		int d = clamp(int(150 * RSQSM_A11y.Text()), 25, 400);
		double aspect = W / H;
		double scw = round(640 * 100.0 / d), sch = round(480 * 100.0 / d);
		double wide = sch * aspect;
		scw *= max(1.0, aspect / (16.0 / 9.0));
		double cx = Coord(85, wide, 140, wide - scw), cy = Coord(10, sch, 40, 0);
		return cx * W / scw, (cy + 17) * H / sch, 120.0 * W / scw;     // the bracket (8 tall) is centred 13 under Score's centre
	}
	static ui double Coord(int pos, double range, double padding, double downshift)
	{
		double safe = range - ((range > padding) ? padding : 0.0);
		return safe * (clamp(pos, 0, 100) / 100.0) + (range - safe) * 0.5 - downshift * 0.5;
	}

	// ---- its colour: the palette the series' new colour rows share (VisualRewards tools/gen_dn_art.py PALETTE) ----------
	static ui Color Pal(int i)
	{
		static const int P[] = { 0xFFFFFF, 0xB3BDD1, 0xFFEB38, 0xFFBD2E, 0xFF7A14, 0xFF291A, 0xDB0A42, 0xFF80C2, 0xFF2EF2,
			0xC299FF, 0x943DFF, 0x3D66FF, 0x70C2FF, 0x14F2FF, 0x14CCA3, 0x33FF4D, 0xB8FF24 };
		int v = P[clamp(i, 0, P.Size() - 1)];
		return Color(255, (v >> 16) & 255, (v >> 8) & 255, v & 255);
	}
	static ui Color BarColor(int startTic)
	{
		int cb = RSQSM_CB.Mode();
		if (cb) { int v = RSQSM_CB.Rgb(RSQSM_CB.CB_HAVE, cb); return Color(255, (v >> 16) & 255, (v >> 8) & 255, v & 255); }
		int i = int(UCv("rsqsm_cdbar_color", 15));
		if (i == RANDOM) i = ((startTic * 7919 + 13) % 17 + 17) % 17;   // a fresh colour each time the bar appears
		return Pal(i);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive) return;
		if (!Enabled()) return;
		let clock = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		if (!clock || (clock.rival && SCv("rsm_yield", 1) != 0)) return;
		double t = level.maptime + e.FracTic;
		double dt = clamp(t - lastT, 0.0, 3.0);
		lastT = t;

		double alpha, target;
		if (clock.cdOn)
		{
			alpha = clamp((t - clock.cdStartTic) / FADE_IN, 0.0, 1.0);
			double left = max(0.0, clock.cdLeft - e.FracTic);
			target = clock.cdTotal > 0 ? clamp(left / clock.cdTotal, 0.0, 1.0) : 1.0;
			if (clock.cdStartTic != lastStart) { lastStart = clock.cdStartTic; shown = target; }
		}
		else
		{
			double age = t - clock.cdEndTic;
			if (clock.cdEndTic <= 0 || age >= FADE_OUT || age < 0) { shown = 0; return; }
			alpha = 1.0 - age / FADE_OUT;
			target = 0;
		}
		// emptying follows the clock exactly; a refill climbs to it over REFILL tics
		if (target > shown) shown = min(target, shown + dt / REFILL);
		else shown = target;

		TextureID te = TexMan.CheckForTexture("RSQSMHE", TexMan.Type_Any);
		TextureID tw = TexMan.CheckForTexture("RSQSMHW", TexMan.Type_Any);
		if (!te.IsValid() || !tw.IsValid()) return;
		double x, y, w, h;
		[x, y, w, h] = Rect();
		Color mid = BarColor(clock.cdStartTic);
		Color lo = Color(255, int(mid.r * 0.30), int(mid.g * 0.30), int(mid.b * 0.30));
		Color hi = RSQSM_GaugeLife.Mix(mid, Color(255, 255, 255, 255), 0.6);
		bool anim = UCv("rsqsm_cdbar_anim", 1) != 0;
		bool photo = RSQSM_A11y.Photo();
		double glint = 0;
		if (anim && !photo && clock.cdOn && clock.cdRefillTic > 0)
		{
			double ga = t - clock.cdRefillTic;
			if (ga >= 0 && ga < GLINT) glint = 1.0 - ga / GLINT;
		}
		Draw(te, tw, x, y, w, h, shown, lo, mid, hi, alpha, anim, photo, glint, t);
		// the hourglass at its left (owner 11-05: "hourglass icon by the slowdown bar"), the meter's skull's size and place
		TextureID hg = TexMan.CheckForTexture("RSQSMHG", TexMan.Type_Any);
		if (hg.IsValid())
		{
			double gx, gy, gs;
			[gx, gy, gs] = GlassRect(x, y, h);
			Screen.DrawTexture(hg, false, gx, gy, DTA_DestWidthF, gs, DTA_DestHeightF, gs, DTA_Alpha, 0.95 * alpha);
		}
	}

	// ONE COLUMN BAND of the bar drawn at x, y, w, h: screen columns a..b, cropped from the source and drawn as its own quad
	static ui void Slab(TextureID tw, double x, double y, double w, double h, double a, double b, Color c, double alpha, bool add)
	{
		a = max(a, x);
		b = min(b, x + w);
		if (b <= a) return;
		Vector2 ts = TexMan.GetScaledSize(tw);
		double srcx = (a - x) / w * ts.x, srcw = (b - a) / w * ts.x;
		if (add)
			Screen.DrawTexture(tw, false, a, y, DTA_DestWidthF, b - a, DTA_DestHeightF, h, DTA_SrcX, srcx, DTA_SrcWidth, srcw,
				DTA_Color, c, DTA_Alpha, alpha, DTA_LegacyRenderStyle, STYLE_Add);
		else
			Screen.DrawTexture(tw, false, a, y, DTA_DestWidthF, b - a, DTA_DestHeightF, h, DTA_SrcX, srcx, DTA_SrcWidth, srcw,
				DTA_Color, c, DTA_Alpha, alpha);
	}

	static ui void Draw(TextureID te, TextureID tw, double x, double y, double w, double h, double frac, Color lo, Color mid, Color hi,
		double alpha, bool anim, bool photo, double glint, double t)
	{
		Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9 * alpha);
		if (frac <= 0.001) return;
		double right = x + w * frac;
		// the fill in SLICES columns from the left, each tinted by its place: dark at the left end climbing toward light, so a
		// full bar shows the whole range and an emptying one darkens as it shrinks
		for (int i = 0; i < SLICES; i++)
		{
			double s0 = x + w * double(i) / SLICES, s1 = x + w * double(i + 1) / SLICES;
			if (s0 >= right) break;
			double mid01 = (i + 0.5) / SLICES;
			Slab(tw, x, y, w, h, int(s0), int(ceil(min(right, s1))), RSQSM_GaugeLife.ByLevel(lo, mid, hi, min(mid01, frac)), alpha, false);
		}
		if (glint > 0)
			Slab(tw, x, y, w, h, x, right, hi, 0.9 * glint * alpha, true);
		if (!anim) return;
		// the band: an eighth of the bar wide, sweeping left to right through the fill
		double ph = (t % SWEEP) / SWEEP;
		double bw = w * 0.125;
		double bR = x + (w * frac + bw) * ph;
		double bL = bR - bw;
		if (bL < right)
			Slab(tw, x, y, w, h, int(max(x, bL)), int(min(right, bR)), hi, (photo ? 0.25 : 0.45) * alpha, true);
		// the edge: a bright line where the fill ends, breathing (held still in Photosensitive Mode)
		double glow = photo ? 0.8 : 0.55 + 0.45 * sin(t * 12.0);
		Screen.DrawThickLine(int(right), int(y), int(right), int(y + h), max(1.0, w / 90.0), hi, int(255 * glow * alpha));
	}
}
