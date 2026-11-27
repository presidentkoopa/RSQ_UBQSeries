// THE INVULNERABILITY BAR (owner 2026-11-16: "the invuln bar can be modelled like our other three bars, and laid out at the
// top. the invulnerable text that we flash to the player can be the same vivid color as the bar so the player knows where
// to look"; design/BANNERS_AND_HUD.md section 5, mockup A3_TOP_STACK.jpg).
// THE SAME FAMILY AS THE OTHER THREE (RSQ SlowMo's countdown.zs, RSQ Miniboss's hud.zs): coldcite's Top HP Bars well and
// white fill (RQVBIE / RQVBIW, tools/gen_gauges.py: the same art as RSQSMHE / RSQSMHW), tinted in 8 steps along the bar,
// the light band sweeping through the fill, the breathing edge; HOT MAGENTA (dark plum empty, magenta, pale pink at the
// top: red/gold, cyan and green are taken); its icon DOOMGUY'S GOD-MODE FACE (owner 2026-11-22: the status bar's
// yellow-eyed face, the load order's STFGOD0 by name) where the Boss meter has its skull, at the size the magenta orb had
// (RQVBII, which stays as the fallback when no STFGOD0 is loaded; the banner's INVULNERABLE chip keeps the orb).
// WHEN: only while the console player holds a power of the PowerInvulnerable family (any: the sphere, a mod's own), full
// when it appears and draining to zero over the REAL time left (its EffectTics; the bar's whole is the time left when it
// appeared, so it always starts full), then it fades. A longer power picked up on top refills it, with a glint. A
// banner's INVULNERABLE chip (banners.zs) flies up to it as a highlight; where it lands the bar flashes in full (since
// 11-16 05:44 the bar does not wait for the chip: it shows and drains from the tic the power is given).
// WHERE: its own row under the slow motion row, the Boss meter's width and thickness and left edge, asked the way the
// bars ask each other (by name, ui): under RSQ Score's bar ("hud.*"), RSQ Miniboss's meter ("meter.bottom", "meter.x" /
// "meter.w" / "meter.h") and RSQ SlowMo's countdown row ("countdown.bottom"); without them, where their own formulas
// would put the Boss meter's row. It answers RSQVR_Service "invbar.bottom" (ui) so RSQ Score's combo rows go under it.
// PHOTOSENSITIVE MODE: no glint, the edge held still, the band dimmer, the landing flash at 40% (as the other bars).
// Rig only, not headset-confirmed.
extend class RSQVR_Banners
{
	const IFADE_IN = 2.0;      // owner 11-16 05:44: invulnerable "immediately": the bar is there almost at once
	const IFADE_OUT = 14.0;
	const ISWEEP = 52.0;
	const ISLICES = 8;
	const IGLINT = 12.0;
	const ILAND = 10.0;        // tics the landing flash lasts
	const ICON_K = 1.6;        // the orb: a square ICON_K x the bar's thickness, IGAP left of the bar (the skull's)
	const IGAP = 0.3;

	ui bool invOn;
	ui double invTotal, invLast, invOffTic, invOnTic, invRefill, invShown;

	static clearscope double UF(String n, double d) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetFloat() : d; }
	static clearscope double SF(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static ui bool InvBarOn() { return UF("rsqvr_invbar", 1) != 0; }

	// the console player's invulnerability, tics left (the longest of its PowerInvulnerable family; 0 none)
	static ui int InvLeft()
	{
		let mo = players[consoleplayer].mo;
		if (!mo) return 0;
		int left = 0;
		for (let i = mo.Inv; i; i = i.Inv)
		{
			let p = Powerup(i);
			if (p && p is "PowerInvulnerable") left = max(left, p.EffectTics);
		}
		return left;
	}

	// RSQ Score's bar: centre, bottom, width (screen px), asked by name; without Score, where its defaults put it
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
		int d = 150;
		double aspect = W / H;
		double scw = round(640 * 100.0 / d), sch = round(480 * 100.0 / d);
		double wide = sch * aspect;
		scw *= max(1.0, aspect / (16.0 / 9.0));
		double cx = Coord(50, wide, 140, wide - scw), cy = Coord(13, sch, 40, 0);
		return cx * W / scw, (cy + 17) * H / sch, 120.0 * W / scw;
	}
	static ui double Coord(int pos, double range, double padding, double downshift)
	{
		double safe = range - ((range > padding) ? padding : 0.0);
		return safe * (clamp(pos, 0, 100) / 100.0) + (range - safe) * 0.5 - downshift * 0.5;
	}

	// the bar's x, y, w, h in screen px (the orb at its left: IconRect)
	static ui double, double, double, double InvRect()
	{
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(SF("rsq_ui_inset", 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double cx, below, sbw;
		[cx, below, sbw] = ScoreSpot();
		double x = -1, w = 0, h = 0;
		let mb = ServiceIterator.Find("RSQMB_Service").Next();
		if (mb)
		{
			below = max(below, mb.GetIntUI("meter.bottom", "", 0, 0, null));
			double mx = mb.GetDoubleUI("meter.x", "", 0, 0, null);
			double mw = mb.GetDoubleUI("meter.w", "", 0, 0, null);
			double mh = mb.GetDoubleUI("meter.h", "", 0, 0, null);
			if (mw > 0 && mh > 0 && mx >= 0) { x = mx; w = mw; h = mh; }
		}
		let sm = ServiceIterator.Find("RSQSM_Service").Next();
		if (sm) below = max(below, sm.GetIntUI("countdown.bottom", "", 0, 0, null));
		if (x < 0)
		{
			// RSQ Miniboss's own formula (hud.zs MeterRect: Score's bar x 0.8 x (Meter Size + 0.3) / 1.5, clear of the lanes)
			double per = 112.0 / 11.0 + ICON_K + IGAP;
			double size = UF("rsqmb_bf_hud_size", 1.5);
			h = sbw * 8.0 / 120.0 * 0.8 * (clamp(size, 0.5, 2.5) + 0.3) / 1.5;
			double gw = min(h * per, sbw);
			double lane = ah * 0.32 * clamp(SF("rsq_ui_hud_scale", 1.5), 0.4, 2.5) * 11.0 / 112.0 * 4.0;
			double room = 2.0 * min(cx - (sx + lane), sx + aw - lane - cx);
			if (room >= gw * 0.5) gw = min(gw, room);
			gw = min(gw, aw);
			h = gw / per;
			double gx0 = clamp(cx - gw * 0.5, sx, max(sx, sx + aw - gw));
			x = gx0 + h * (ICON_K + IGAP);
			w = h * 112.0 / 11.0;
		}
		double y = clamp(below + h * (0.3 + 0.25), sy, sy + ah - h);
		return x, y, w, h;
	}
	static ui double, double, double IconRect(double x, double y, double h)
	{
		double s = h * ICON_K;
		return x - s - h * IGAP, y + (h - s) * 0.5, s;
	}
	// the pixel row under the whole top stack, the invulnerability bar's row counted whether or not it shows (the banners
	// go under it)
	static ui double StackBottom()
	{
		double x, y, w, h;
		[x, y, w, h] = InvRect();
		return y + h * (1.0 + (ICON_K - 1.0) * 0.5);
	}
	// RSQVR_Service "invbar.bottom": the pixel row under the bar while it shows, -1 when it does not
	ui int InvBottom()
	{
		if (!invOn && level.maptime - invOffTic >= IFADE_OUT) return -1;
		double x, y, w, h;
		[x, y, w, h] = InvRect();
		return int(ceil(y + h * (1.0 + (ICON_K - 1.0) * 0.5)));
	}

	ui void DrawInvBar(double t)
	{
		if (!InvBarOn()) { invOn = false; return; }
		int left = InvLeft();
		int land = LandTic();
		bool landing = land >= 0 && t - land >= 0 && t - land < ILAND;
		// on / off: the power itself, from the tic it is given (owner 11-16 05:44: "it needs to be invuln immediately and
		// start counting down ... the timer for it has to start the second we revive"): a banner's INVULNERABLE chip no
		// longer holds the bar back; it flies in as a highlight and lands on a bar already counting down
		if (left > 0)
		{
			if (!invOn) { invOn = true; invTotal = left; invOnTic = t; invShown = 1.0; }
			else if (left > invLast + 2) { invTotal = max(left, 1); invRefill = t; }   // a longer power on top: refill
		}
		else if (invOn) { invOn = false; invOffTic = t; }
		invLast = left;
		double alpha, frac;
		if (invOn)
		{
			alpha = clamp((t - invOnTic) / IFADE_IN, 0.0, 1.0);
			if (landing) alpha = 1.0;
			frac = invTotal > 0 ? clamp((left - (t - floor(t))) / invTotal, 0.0, 1.0) : 0.0;
			if (left > 35 * 3600) frac = 1.0;     // a power with no end of its own sits full
		}
		else
		{
			double age = t - invOffTic;
			if (age < 0 || age >= IFADE_OUT || invOffTic <= 0) return;
			alpha = 1.0 - age / IFADE_OUT;
			frac = 0;
		}
		TextureID te = T("RQVBIE"), tw = T("RQVBIW");
		if (!te.IsValid() || !tw.IsValid()) return;
		double x, y, w, h;
		[x, y, w, h] = InvRect();
		Color lo = Color(255, 70, 8, 60), mid = Color(255, 255, 40, 190), hi = Color(255, 255, 205, 245);
		double glint = 0;
		if (invRefill > 0 && t - invRefill >= 0 && t - invRefill < IGLINT) glint = 1.0 - (t - invRefill) / IGLINT;
		DrawBarArt(te, tw, x, y, w, h, frac, lo, mid, hi, alpha, glint, t);
		// the landing: the bar flashes in full where the chip lands
		if (landing)
		{
			double la = 1.0 - (t - land) / ILAND;
			BarSlab(tw, x, y, w, h, x, x + w, hi, 0.9 * la, true);
			Tex("RQVBGL", x - h * 2, y - h * 1.5, w + h * 4, h * 4, 0.55 * la, -1, 0xFF60D8, true);
		}
		double ix, iy, isz;
		[ix, iy, isz] = IconRect(x, y, h);
		// the god-mode face in the orb's square: its full height, its own width (24 x 29 in Doom 2), centred across
		TextureID god = T("STFGOD0");
		if (god.IsValid())
		{
			Vector2 gs = TexMan.GetScaledSize(god);
			double gw = gs.y > 0 ? isz * gs.x / gs.y : isz;
			Tex("STFGOD0", ix + (isz - gw) * 0.5, iy, gw, isz, 0.95 * alpha);
		}
		else Tex("RQVBII", ix, iy, isz, isz, 0.95 * alpha);
	}

	// one column band of the bar: screen columns a..b, cropped from the source, its own quad (no clip rectangle)
	static ui void BarSlab(TextureID tw, double x, double y, double w, double h, double a, double b, Color c, double alpha, bool add)
	{
		a = max(a, x);
		b = min(b, x + w);
		if (b <= a || alpha <= 0.0) return;
		Vector2 ts = TexMan.GetScaledSize(tw);
		double srcx = (a - x) / w * ts.x, srcw = (b - a) / w * ts.x;
		Screen.DrawTexture(tw, false, a, y, DTA_DestWidthF, b - a, DTA_DestHeightF, h, DTA_SrcX, srcx, DTA_SrcWidth, srcw,
			DTA_Color, c, DTA_Alpha, alpha, DTA_LegacyRenderStyle, add ? STYLE_Add : STYLE_Translucent);
	}
	static ui Color MixC(Color a, Color b, double k)
	{
		k = clamp(k, 0.0, 1.0);
		return Color(255, int(a.r + (b.r - a.r) * k), int(a.g + (b.g - a.g) * k), int(a.b + (b.b - a.b) * k));
	}
	static ui Color ByLevel(Color lo, Color mid, Color hi, double f) { return f < 0.5 ? MixC(lo, mid, f * 2.0) : MixC(mid, hi, (f - 0.5) * 2.0); }
	// the series' bar, exactly as RSQ SlowMo's countdown draws it (countdown.zs Draw)
	static ui void DrawBarArt(TextureID te, TextureID tw, double x, double y, double w, double h, double frac, Color lo, Color mid, Color hi,
		double alpha, double glint, double t)
	{
		Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9 * alpha);
		if (frac <= 0.001) return;
		double right = x + w * frac;
		for (int i = 0; i < ISLICES; i++)
		{
			double s0 = x + w * double(i) / ISLICES, s1 = x + w * double(i + 1) / ISLICES;
			if (s0 >= right) break;
			double mid01 = (i + 0.5) / ISLICES;
			BarSlab(tw, x, y, w, h, int(s0), int(ceil(min(right, s1))), ByLevel(lo, mid, hi, min(mid01, frac)), alpha, false);
		}
		if (glint > 0) BarSlab(tw, x, y, w, h, x, right, hi, 0.9 * glint * alpha, true);
		double ph = (t % ISWEEP) / ISWEEP;
		double bw = w * 0.125;
		double bR = x + (w * frac + bw) * ph;
		double bL = bR - bw;
		if (bL < right) BarSlab(tw, x, y, w, h, int(max(x, bL)), int(min(right, bR)), hi, 0.45 * alpha, true);
		double glow = 0.55 + 0.45 * sin(t * 12.0);
		Screen.DrawThickLine(int(right), int(y), int(right), int(y + h), max(1.0, w / 90.0), hi, int(255 * glow * alpha));
	}
}
