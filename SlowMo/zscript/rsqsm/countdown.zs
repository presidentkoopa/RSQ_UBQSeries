// THE COUNTDOWN BAR (owner, 2026-11-03 19:06: "another UI bar ... Horizontal, and count down whenever we slow time outside
// of player choice"; 2026-11-05 03:55: "remove both sidebars, use our new slowdown timer bar for all slowmo, when player
// triggers it, it starts full, and drains for however long the player has set it to").
//
// WHEN (owner 2026-11-06: "RIGHT = the automatic slow-mo countdown, shown ONLY while the game has slowed time by itself"):
// the countdown runs for EVERY slow motion (clock.zs) but the bar SHOWS only while an automatic trigger let it in (clock.cdAuto).
// The stored slow-mo bar (the adrenaline meter) is drawn here too, at its left. Before 11-06: EVERY slow motion, from any source (clock.zs CountdownStart / CountdownTick): his key, the wrist cross, its burst,
// the Wheel, the Accessibility button, the shootdodge, and every pulse (a kill moment or shove, the cigarette, the
// Bossfight landing, Score, Gun Bonsai VR, close-call, reload, any mod through rsm_pulse or the named door). It starts
// full and holds the REAL time left until the world is at full speed (the hold, then the ease out), empties evenly to zero
// (level.maptime is never slowed, and the frame's FracTic makes it smooth), then fades. A slow that starts or pushes the end
// later refills it to the new time left, with a glint. A held slow with no end of its own (the key, the Wheel, a dodge in
// the air) drains the adrenaline meter's time with Adrenaline on, and sits full until let go with it off.
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
// rectangle, whose scissor misses the projected HUD in VR (the old side gauge's Slab, commit ff21977ce).
class RSQSM_Countdown : StaticEventHandler
{
	const FADE_IN = 5.0;      // tics
	const FADE_OUT = 14.0;    // tics (0.4 s)
	const REFILL = 8.0;       // tics for a refill to climb the whole bar
	const GLINT = 12.0;       // tics a refill's glint lasts
	const SWEEP = 52.0;       // tics for the band to cross the fill (1.5 s)
	const SLICES = 8;
	const RANDOM = 98;
	const GLIDE = 6.0;        // tics for the stored bar to glide aside (or back) as the countdown comes and goes

	ui double shown;          // the fraction drawn (a refill climbs to the clock's; emptying follows it exactly)
	ui double lastT;
	ui int lastStart;

	static clearscope double UCv(String n, double d) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetFloat() : d; }
	static clearscope double SCv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope bool Enabled() { return UCv("rsqsm_cdbar", 1) != 0; }
	// WHICH SLOWS SHOW THE BAR (owner 11-06 07:00): with Adrenaline off, every slow motion, his own too (the key, the wrist
	// cross and its burst, the Wheel, the Accessibility button, a shootdodge, the cigarette, a shove, a parry or block,
	// Miniboss's Bossfight landing) as well as every automatic one; with Adrenaline on, only an automatic one (his own
	// spends the stored bar, which is then the meter)
	static clearscope bool ShowsFor(RSQSM_Clock clock) { return clock && (clock.cdAuto || SCv("rsqsm_adrenaline", 0) == 0); }

	// ---- where it goes, in screen pixels ------------------------------------------------------------------------------
	// TWO BARS SIDE BY SIDE (owner 2026-11-06, his approved layout): under the SCORE word, then RSQ Miniboss's Bossfight bar,
	// then a pair: LEFT the stored slow-mo (the adrenaline meter, the old charge bar back), RIGHT this countdown, which shows
	// only while the game slowed time by itself. One bar alone is centred; when the second appears the pair glides so the
	// two together are centred. Each is a row: an hourglass (the same icon, its trim recoloured: black for stored, brown
	// for the countdown), a gap, the bar. The two rows are always the same size, so a bar never changes size when the other
	// comes or goes.
	// SIZE (owner 11-05: "smaller than the score, neatly fitting centered under it score bar"): the PAIR is sized from RSQ
	// Score's bar (its thickness x ROWK x Bar Size / 1.5) and never wider than that bar; it follows Score's scale, Text
	// Size and screen shape. Clear of the side gauges' lanes (RSQ Gun Bonsai VR's Berserk gauges stand 2.5 to 3.5 gauge
	// widths in from each side; 4 kept clear): where Score sits near one, the pair shrinks rather than leaving Score's centre.
	// LINED UP WITH THE BOSSFIGHT METER (owner 11-05: "always line up, whatever Meter Size and Bar Size are set to"): while
	// RSQ Miniboss's meter shows above (RSQMB_Service "meter.x" / "meter.w" / "meter.h", ui, by name), the pair spans the
	// meter's row exactly: the left hourglass starts under the skull, the right bar ends where the meter ends.
	const GLASS = 1.6;       // the hourglass: a square GLASS x the bar's thickness (the skull's size) ...
	const KGAP = 0.3;        // ... KGAP left of its bar
	const ROWK = 0.8;        // the bar's thickness against Score's bar (8 of 120): smaller than Score
	const PGAP = 1.2;        // the gap between the two rows, in bar thicknesses
	const PER = 112.0 / 11.0 + 1.6 + 0.3;   // one row's width per pixel of bar thickness (bar + GLASS + KGAP)
	// the slot: the pair's centre x, the bars' top y, their thickness h
	static ui double, double, double Slot()
	{
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(SCv("rsq_ui_inset", 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double cx, below, sbw;
		[cx, below, sbw] = ScoreSpot();
		double pairK = 2.0 * PER + PGAP;
		let mb = ServiceIterator.Find("RSQMB_Service").Next();
		if (mb)
		{
			double mx = mb.GetDoubleUI("meter.x", "", 0, 0, null);
			double mw = mb.GetDoubleUI("meter.w", "", 0, 0, null);
			double mh = mb.GetDoubleUI("meter.h", "", 0, 0, null);
			if (mw > 0 && mh > 0 && mx >= 0)
			{
				double left = mx - mh * (GLASS + KGAP), span = mx + mw - left;
				double h = span / pairK;
				return left + span * 0.5, clamp(below + h * (0.3 + 0.25), sy, sy + ah - h), h;
			}
		}
		double h = sbw * 8.0 / 120.0 * ROWK * clamp(UCv("rsqsm_cdbar_size", 1.5), 0.5, 2.5) / 1.5;
		double pw = min(h * pairK, sbw);
		double lane = ah * 0.32 * clamp(SCv("rsq_ui_hud_scale", 1.5), 0.4, 2.5) * 11.0 / 112.0 * 4.0;
		double room = 2.0 * min(cx - (sx + lane), sx + aw - lane - cx);
		if (room >= pw * 0.5) pw = min(pw, room);
		pw = min(pw, aw);
		h = pw / pairK;
		cx = clamp(cx, sx + pw * 0.5, max(sx + pw * 0.5, sx + aw - pw * 0.5));
		return cx, clamp(below + h * (0.3 + 0.25), sy, sy + ah - h), h;
	}
	// a row's place: k 0 alone (centred), -1 the pair's left, 1 the pair's right; between (-1..0) while it glides. Answers
	// the BAR's x, y, w, h (the hourglass sits at its left, GlassRect)
	static ui double, double, double, double RowRect(double cx, double y, double h, double k)
	{
		double rw = h * PER;
		double off = (rw + h * PGAP) * 0.5 * k;        // a row's centre moves half a row and half the gap each way
		double rx = cx + off - rw * 0.5;
		return rx + h * (GLASS + KGAP), y, h * 112.0 / 11.0, h;
	}
	static ui double, double, double GlassRect(double x, double y, double h)
	{
		double s = h * GLASS;
		return x - s - h * KGAP, y + (h - s) * 0.5, s;
	}
	// the pixel row under the pair (the hourglass hangs a little under the bar; under the cause line while one shows):
	// RSQSM_Service "countdown.bottom"
	static ui int Bottom()
	{
		double cx, y, h;
		[cx, y, h] = Slot();
		double bot = y + h * (1.0 + (GLASS - 1.0) * 0.5);
		if (CauseShown() != "") bot += h * (CAUSE_GAP + CAUSE_H);
		if (DownShown()) bot = DownY(y, h) + h * (1.0 + (GLASS - 1.0) * 0.5) + h * (CAUSE_GAP + CAUSE_H);
		return int(ceil(bot));
	}

	// THE DOWN BAR (v2) IS GONE (v3, owner 2026-11-07): DOWN's clock and reward bar are on the plate in the world (down.zs /
	// plate.zs). These stay as no-ops so the callers below need no change.
	static ui bool DownShown() { return false; }
	static ui double DownY(double y, double h) { return y; }
	ui void DrawDown(double t) {}

	// THE CAUSE LINE (owner 2026-11-06: "under the right-hand automatic countdown bar, while it runs, one short line naming
	// what caused it ... in the same style as Miniboss's blocker text under its bar"): RSQ Miniboss's wait line's look
	// (hud.zs: NewSmallFont, white on a black drop shadow, letters 0.8 of the bar's thickness, 0.15 of it under the icon,
	// centred on the row from the icon to the bar's end, shrunk to fit it). The clock's cdCause, while the countdown bar shows
	// (it fades with the bar and is gone with it).
	const CAUSE_GAP = 0.15;
	const CAUSE_H = 0.8;
	static ui String CauseShown()
	{
		if (!Enabled()) return "";
		let clock = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		if (!clock || !ShowsFor(clock) || clock.cdCause == "") return "";
		if (clock.cdOn) return clock.cdCause;
		double age = level.maptime - clock.cdEndTic;
		return (clock.cdEndTic > 0 && age >= 0 && age < FADE_OUT) ? clock.cdCause : "";
	}
	static ui void DrawCause(String why, double x, double y, double w, double h, double alpha)
	{
		if (why == "" || alpha <= 0.01) return;
		double gx, gy, gs;
		[gx, gy, gs] = GlassRect(x, y, h);
		double gl = gx, gw = x + w - gx;     // the row: the hourglass to the bar's right end
		Font fnt = NewSmallFont;
		double s = (h * CAUSE_H) / max(1, fnt.GetHeight());
		double tw2 = fnt.StringWidth(why) * s;
		if (tw2 > gw) { s *= gw / tw2; tw2 = gw; }
		double vw = Screen.GetWidth() / s, vh = Screen.GetHeight() / s;
		double tx = (gl + (gw - tw2) * 0.5) / s, ty = (max(y + h, gy + gs) + h * CAUSE_GAP) / s;
		Screen.DrawText(fnt, Font.CR_BLACK, tx + 1, ty + 1, why, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, 0.8 * alpha);
		Screen.DrawText(fnt, Font.CR_WHITE, tx, ty, why, DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, alpha);
	}
	// either bar can show: the countdown's row, or the stored bar's (it needs Adrenaline on: without it nothing is stored)
	static clearscope bool StoreOn() { return UCv("rsqsm_storebar", 1) != 0 && SCv("rsqsm_adrenaline", 0) != 0; }
	static clearscope bool AnyOn() { return Enabled() || StoreOn(); }

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

	ui double pairK;          // 0 the stored bar alone and centred, -1 it has glided left to make room for the countdown

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive) return;
		let clock = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		if (!clock || (clock.rival && SCv("rsm_yield", 1) != 0)) return;
		if (DownShown()) DrawDown(level.maptime + e.FracTic);
		if (!AnyOn()) return;
		double t = level.maptime + e.FracTic;
		double dt = clamp(t - lastT, 0.0, 3.0);
		lastT = t;

		// THE COUNTDOWN (right): only while the slow running now (or easing out) was let in by an automatic trigger
		double alpha = 0, target = 0;
		bool cdVis = false;
		if (clock.cdOn)
		{
			double left = max(0.0, clock.cdLeft - e.FracTic);
			target = clock.cdTotal > 0 ? clamp(left / clock.cdTotal, 0.0, 1.0) : 1.0;
			if (clock.cdStartTic != lastStart) { lastStart = clock.cdStartTic; shown = target; }
			if (ShowsFor(clock))
			{
				cdVis = true;
				alpha = clamp((t - max(clock.cdStartTic, clock.cdAutoTic)) / FADE_IN, 0.0, 1.0);
			}
		}
		else
		{
			double age = t - clock.cdEndTic;
			if (ShowsFor(clock) && clock.cdEndTic > 0 && age < FADE_OUT && age >= 0) { cdVis = true; alpha = 1.0 - age / FADE_OUT; }
			target = 0;
			if (!cdVis) shown = 0;
		}
		if (!Enabled()) cdVis = false;
		// emptying follows the clock exactly; a refill climbs to it over REFILL tics
		if (target > shown) shown = min(target, shown + dt / REFILL);
		else shown = target;

		bool stVis = StoreOn();
		// the glide: the stored bar moves aside over GLIDE tics when the countdown appears, and back when it has gone
		double want = (stVis && cdVis) ? -1.0 : 0.0;
		if (pairK > want) pairK = max(want, pairK - dt / GLIDE);
		else pairK = min(want, pairK + dt / GLIDE);
		if (!cdVis && !stVis) return;

		TextureID te = TexMan.CheckForTexture("RSQSMHE", TexMan.Type_Any);
		TextureID tw = TexMan.CheckForTexture("RSQSMHW", TexMan.Type_Any);
		if (!te.IsValid() || !tw.IsValid()) return;
		double cx, y, h;
		[cx, y, h] = Slot();
		bool anim = UCv("rsqsm_cdbar_anim", 1) != 0;
		bool photo = RSQSM_A11y.Photo();
		double x, w;

		if (stVis)
		{
			// THE STORED SLOW-MO (left; the old charge bar, owner 11-06 "the bar showing how much SlowMo we've built up"): the
			// adrenaline meter 0..100, its old colours (deep blue empty, electric cyan half, near white full). Dim below
			// Adrenaline to Start (a white tick marks that line), pulsing while slow motion spends it.
			double frac = clamp(clock.adr / 100.0, 0.0, 1.0);
			double need = clamp(SCv("rsqsm_adr_min", 25), 0, 100) / 100.0;
			bool spending = clock.on;
			for (int n = 0; n < MAXPLAYERS; n++) if (clock.dodgeTic[n] > 0) spending = true;
			double sa = frac < need ? 0.5 : 1.0;
			if (spending && !photo) sa *= 0.75 + 0.25 * sin(t * 20.0);
			[x, y, w, h] = RowRect(cx, y, h, pairK);
			Draw(te, tw, x, y, w, h, frac, Color(255, 30, 60, 200), Color(255, 60, 220, 255), Color(255, 225, 250, 255),
				sa, anim, photo, 0, t, 1.0);
			if (need > 0.001)
			{
				int tx = int(x + w * need);
				Screen.DrawThickLine(tx, int(y - h * 0.3), tx, int(y + h * 1.3), max(1.0, w / 112.0), 0xFFFFFFFF, int(255 * 0.8));
			}
			DrawGlass("RSQSMHS", x, y, h, 0.95);
		}
		if (cdVis)
		{
			[x, y, w, h] = RowRect(cx, y, h, stVis ? 1.0 : 0.0);
			Color mid = BarColor(clock.cdStartTic);
			Color lo = Color(255, int(mid.r * 0.30), int(mid.g * 0.30), int(mid.b * 0.30));
			Color hi = RSQSM_BarLife.Mix(mid, Color(255, 255, 255, 255), 0.6);
			double glint = 0;
			if (anim && !photo && clock.cdOn && clock.cdRefillTic > 0)
			{
				double ga = t - clock.cdRefillTic;
				if (ga >= 0 && ga < GLINT) glint = 1.0 - ga / GLINT;
			}
			Draw(te, tw, x, y, w, h, shown, lo, mid, hi, alpha, anim, photo, glint, t, alpha);
			// the hourglass at its left (owner 11-05: "hourglass icon by the slowdown bar"), the meter's skull's size and place
			DrawGlass("RSQSMHG", x, y, h, 0.95 * alpha);
			DrawCause(clock.cdCause, x, y, w, h, alpha);
		}
	}
	static ui void DrawGlass(String tex, double x, double y, double h, double a)
	{
		TextureID hg = TexMan.CheckForTexture(tex, TexMan.Type_Any);
		if (!hg.IsValid()) return;
		double gx, gy, gs;
		[gx, gy, gs] = GlassRect(x, y, h);
		Screen.DrawTexture(hg, false, gx, gy, DTA_DestWidthF, gs, DTA_DestHeightF, gs, DTA_Alpha, a);
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
		double alpha, bool anim, bool photo, double glint, double t, double wellAlpha)
	{
		Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9 * wellAlpha);
		if (frac <= 0.001) return;
		double right = x + w * frac;
		// the fill in SLICES columns from the left, each tinted by its place: dark at the left end climbing toward light, so a
		// full bar shows the whole range and an emptying one darkens as it shrinks
		for (int i = 0; i < SLICES; i++)
		{
			double s0 = x + w * double(i) / SLICES, s1 = x + w * double(i + 1) / SLICES;
			if (s0 >= right) break;
			double mid01 = (i + 0.5) / SLICES;
			Slab(tw, x, y, w, h, int(s0), int(ceil(min(right, s1))), RSQSM_BarLife.ByLevel(lo, mid, hi, min(mid01, frac)), alpha, false);
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

// THE FILL'S COLOUR STEPS (kept from the removed side gauge, gauge.zs, 11-05): lo at empty, mid at half, hi at full
class RSQSM_BarLife ui
{
	static Color Mix(Color a, Color b, double k)
	{
		k = clamp(k, 0.0, 1.0);
		return Color(255, int(a.r + (b.r - a.r) * k), int(a.g + (b.g - a.g) * k), int(a.b + (b.b - a.b) * k));
	}
	static Color ByLevel(Color lo, Color mid, Color hi, double f) { return f < 0.5 ? Mix(lo, mid, f * 2.0) : Mix(mid, hi, (f - 0.5) * 2.0); }
}
