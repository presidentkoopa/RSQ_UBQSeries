// RSQ_SlowMo -- THE DOWN PANEL AND THE EDGE ARROWS, ON THE HUD LAYER (owner 2026-11-07 07:50, design/NEAR_DEATH.md "LAYERS":
// "on the sprite/HUD layer, like Score's readout and SlowMo's bars, so the clock can never be missed, hidden by the gun or
// clipped by a wall"). Drawn the way SlowMo's own bars are (countdown.zs): RenderOverlay, Screen.DrawTexture quads in screen
// pixels, every piece its own quad (no clip rectangle: its scissor misses the projected HUD in VR). The crosshairs and the
// eye-level trail stay in the world (plate.zs). Console player only, while he is DOWN.
//
// THE LOOK is design/mockups/down_v3_full_view_mockup.html with its approved second version (design/mockups/README.md):
// the panel is laid out in the mockup's own pixels and scaled as one piece to HALF OF WHAT YOU SEE IN THE HEADSET EYE
// (owner 07:55: "whatever the HUD scale"), centred under your gaze, its foot where the mockup's is (335 of its view px
// under the gaze), flat; raised just enough to clear the status bar, inside the series' safe area (rsq_ui_inset). If many
// target lines would lift it past the gaze, the whole panel shrinks instead.
// HOW THE HUD MEETS THE EYE (QuestZDoom's own code, DrBeef/gzdoom questzdoom gl_openxrdevice.cpp getHUDProjection: read,
// not guessed): the HUD screen is a quad 1 m ahead, its half-width vr_hud_scale m, its height stretched by the level's
// pixel stretch, tilted down vr_hud_rotate degrees. So a HUD pixel is (vr_hud_scale / half the screen) of a unit of
// tangent across, (vr_hud_scale x pixel stretch / half the screen height) up, and the gaze is tan(vr_hud_rotate) above
// the HUD's middle. The player's HUD scale is never changed: the panel undoes it.
// THE EYE'S WIDTH: ZScript cannot read the headset eye's field of view, so EYE_TAN is the eye's half-width as a tangent,
// MEASURED on the 17.3 rig (the v3f run: the panel drawn half the HUD screen wide at vr_hud_scale 0.55 measured 145 of the
// eye's 480 px, so 0.55 x 1.0 / (2 x 0.302) = 0.91, an ~85 degree eye). A headset with another eye shows it in proportion.
// THE ENTRANCE (owner 07:55): it slams up from the bottom edge (SLAM tics, a slight overshoot), the bar filling left to
// right as it lands; the heavy controller thump is down.zs's (at the landing).
//   the bar   mockup x 120..880, foot y 575, three steps 14 / 30 / 52 px (thin, normal, tall: the tall right end drains
//             first), each a #0b0b0d 4 px border round a #202024 track; the fill 60 slices in the mockup's moving gradient
//             (hsl(H +- 9, 95%, 50 +- 12%)) of the first living target's colour, draining smoothly; no step breaks off
//             (owner 07:07). THE REFILL (a kill with targets left, down.zs BarReset): a bright edge running left to right
//             over REFILL_TICS (owner 07:50: "a bright moving edge"), the fill full behind it.
//   lines     one a target, stacked up from the bar: a dark round slot (r 27) at x 150, the target's icon (r 21), then
//             "TARGET: <name>" (Score's monster.name) in a light tint of its colour (the mockup's hsl(H, 80%, 75%)). Dead: the
//             line stays, its text dimmed with a thin strike-through so it stays readable (owner 07:50), its icon dimmed
//             and cracked (the mockup's crack). Owed and not spawned yet: faint.
//   the tab   x 900..1150, y 415..585 (#0b0b0d round #170708): "DEATH IN:" small, the seven-segment SS:hh readout (its look
//             as built, sized to sit inside the tab).
//   text      RSQ Score's combo font (RSSCFN2) when Score is loaded, else JFO (platefont.zs).
// THE EDGE ARROWS: a target farther than 75 degrees from your view (plate.zs decides, and eases the direction after your
// gaze): the chosen Turn Marker (default Triple Chevron) in its baked momentum frames, pointing the way to turn, with the
// target's icon on a dark slot on its inner side, round the middle of the view at the mockup's distances (icon 110 px, the
// arrows from 150 px out, of its 1312 px view); behind you: at the bottom, pointing down.
class RSQSM_DownHud ui
{
	const MW = 1034.0;      // the panel's width in mockup px (116..1150)
	const MCX = 633.0;      // its middle
	const MFOOT = 585.0;    // its foot
	const BL = 120.0;
	const BR = 880.0;
	const BASE = 575.0;
	const LINE0 = 513.0;
	const LPITCH = 62.0;
	const TXT_X = 191.0;
	const TXT_W = 426.0;
	const VIEW_MW = 1312.0; // the mockup's whole view, for the edge arrows

	const EYE_TAN = 0.91;   // the eye's half-width as a tangent, measured on the 17.3 rig (above)
	const SLAM = 8;         // tics the slam takes (~0.23 s: "fast", my number)
	const SLAM_BACK = 1.0;  // its overshoot (an ease-out-back with c1 1.0: ~6%, "slight", my number)
	const FILL_IN = 10;     // tics the bar takes to fill left to right as it lands (my number)

	// this frame's mapping, mockup px -> screen px (sx across, sy down: the HUD's pixels are stretched in VR)
	double s, sx, sy, fx, fy;
	double X(double mx) { return fx + (mx - MCX) * sx; }
	double Y(double my) { return fy - (MFOOT - my) * sy; }
	// the HUD in the eye: screen px a unit of tangent (across, up) and the gaze's place on the screen
	double ptx, pty, gx, gy;
	void EyeMap()
	{
		double sw = Screen.GetWidth(), shh = Screen.GetHeight();
		let vm = CVar.FindCVar("vr_mode");
		if (!vm || vm.GetInt() == 0)
		{
			// a flat screen: the view is the screen
			ptx = sw * 0.5 / EYE_TAN; pty = ptx; gx = sw * 0.5; gy = shh * 0.5;
			return;
		}
		let hs = CVar.FindCVar("vr_hud_scale");
		let hr = CVar.FindCVar("vr_hud_rotate");
		double scale = hs ? max(0.05, hs.GetFloat()) : 0.4;
		double ps = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
		ptx = sw * 0.5 / scale;
		pty = shh * 0.5 / (scale * ps);
		gx = sw * 0.5;
		gy = shh * 0.5 - tan(hr ? hr.GetFloat() : 0.0) * pty;
	}

	// ---- colours ----------------------------------------------------------------------------------------------------
	static clearscope int Mix(int a, int b, double k)
	{
		k = clamp(k, 0.0, 1.0);
		int rr = int(((a >> 16) & 255) * (1 - k) + ((b >> 16) & 255) * k);
		int gg = int(((a >> 8) & 255) * (1 - k) + ((b >> 8) & 255) * k);
		int bl = int((a & 255) * (1 - k) + (b & 255) * k);
		return (rr << 16) | (gg << 8) | bl;
	}
	static clearscope double, double, double ToHsl(int rgb)
	{
		double rr = ((rgb >> 16) & 255) / 255.0, gg = ((rgb >> 8) & 255) / 255.0, bb = (rgb & 255) / 255.0;
		double mx = max(rr, max(gg, bb)), mn = min(rr, min(gg, bb));
		double l = (mx + mn) * 0.5, h = 0, sa = 0;
		if (mx > mn)
		{
			double d = mx - mn;
			sa = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn);
			if (mx == rr) h = (gg - bb) / d + (gg < bb ? 6 : 0);
			else if (mx == gg) h = (bb - rr) / d + 2;
			else h = (rr - gg) / d + 4;
			h *= 60;
		}
		return h, sa, l;
	}
	static clearscope double HueC(double p, double q, double t)
	{
		if (t < 0) t += 1;
		if (t > 1) t -= 1;
		if (t < 1.0 / 6) return p + (q - p) * 6 * t;
		if (t < 0.5) return q;
		if (t < 2.0 / 3) return p + (q - p) * (2.0 / 3 - t) * 6;
		return p;
	}
	static clearscope int Hsl(double h, double sa, double l)
	{
		h = (h % 360.0 + 360.0) % 360.0 / 360.0; sa = clamp(sa, 0.0, 1.0); l = clamp(l, 0.0, 1.0);
		double rr = l, gg = l, bb = l;
		if (sa > 0)
		{
			double q = l < 0.5 ? l * (1 + sa) : l + sa - l * sa, p = 2 * l - q;
			rr = HueC(p, q, h + 1.0 / 3); gg = HueC(p, q, h); bb = HueC(p, q, h - 1.0 / 3);
		}
		return (int(rr * 255 + 0.5) << 16) | (int(gg * 255 + 0.5) << 8) | int(bb * 255 + 0.5);
	}
	// the mockup's light tint (its job line, hsl(H, 80%, 75%)), for any target colour
	static clearscope int Light(int col)
	{
		double h, sa, l;
		[h, sa, l] = ToHsl(col);
		return Hsl(h, 0.8 * sa, max(0.75, l));
	}
	static Color C(int rgb) { return Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255); }

	// ---- drawing ----------------------------------------------------------------------------------------------------
	static TextureID T(String n) { return TexMan.CheckForTexture(n, TexMan.Type_Any); }
	// a texture over a mockup rectangle: as it is (rgb < 0), or white tinted rgb; add: additive
	void Box(String tex, double x0, double y0, double x1, double y1, int rgb = -1, double alpha = 1.0, bool add = false)
	{
		TextureID t = T(tex);
		if (!t.IsValid() || alpha <= 0.002) return;
		double px = X(x0), py = Y(y0), w = (x1 - x0) * sx, h = (y1 - y0) * sy;
		if (w <= 0 || h <= 0) return;
		if (rgb < 0)
			Screen.DrawTexture(t, false, px, py, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_LeftOffset, 0, DTA_TopOffset, 0, DTA_Alpha, alpha);
		else if (add)
			Screen.DrawTexture(t, false, px, py, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_LeftOffset, 0, DTA_TopOffset, 0, DTA_Alpha, alpha,
				DTA_Color, C(rgb), DTA_LegacyRenderStyle, STYLE_Add);
		else
			Screen.DrawTexture(t, false, px, py, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_LeftOffset, 0, DTA_TopOffset, 0, DTA_Alpha, alpha,
				DTA_Color, C(rgb));
	}
	void BoxC(String tex, double cx, double cy, double w, double h, int rgb = -1, double alpha = 1.0)
	{
		Box(tex, cx - w * 0.5, cy - h * 0.5, cx + w * 0.5, cy + h * 0.5, rgb, alpha);
	}
	// a line of the plate's font: left edge x, centre y, cap height, never wider than maxW; returns its right end
	double Text(String txt, double x, double y, double cap, double maxW, int rgb, double alpha)
	{
		txt = txt.MakeUpper();
		Name sn = 'RS_ScoreService';
		class<Object> sc = sn;
		bool sf = sc != null;
		double tot = 0;
		for (int k = 0; k < int(txt.Length()); k++) tot += RSQSM_PlateFont.Adv(sf, txt.ByteAt(k));
		double k0 = cap / RSQSM_PlateFont.Cap(sf);
		if (tot * k0 > maxW && tot > 0) k0 = maxW / tot;
		double cx = x;
		for (int k = 0; k < int(txt.Length()); k++)
		{
			int c = txt.ByteAt(k);
			if (c < RSQSM_PlateFont.LO || c > RSQSM_PlateFont.HI) c = 32;
			double adv = RSQSM_PlateFont.Adv(sf, c) * k0, w = RSQSM_PlateFont.Wid(sf, c) * k0, h = RSQSM_PlateFont.Hgt(sf, c) * k0;
			if (c != 32 && w > 0) BoxC(String.Format(sf ? "RSPC%03d" : "RSPJ%03d", c), cx + adv * 0.5, y, w, h, rgb, alpha);
			cx += adv;
		}
		return cx;
	}

	// RSQSM_Down.RenderOverlay calls this every frame
	void Draw(RSQSM_Down d, RenderEvent e)
	{
		if (gamestate != GS_LEVEL || screenblocks > 11 || automapactive) return;
		int pn = consoleplayer;
		if (!d || !d.IsDown(pn) || !players[pn].mo) return;
		DrawPanel(d, pn, level.maptime + e.FracTic);
		DrawEdges(d, pn);
	}

	void DrawPanel(RSQSM_Down d, int pn, double t)
	{
		double sw = Screen.GetWidth(), shh = Screen.GetHeight();
		double f = clamp(RSQSM_Countdown.SCv("rsq_ui_inset", 0.04), 0.0, 0.3);
		// the lines: this player's targets, then the ones owed and not spawned yet
		Array<String> lnName;
		Array<int> lnIcon, lnCol, lnState;      // 0 alive, 1 dead, 2 waiting
		int col = RSQSM_Down.DOWN_RED;
		bool gotCol = false;
		for (int i = 0; i < d.tMon.Size(); i++)
		{
			if (d.tPn[i] != pn || d.tDead[i] == 2) continue;
			lnName.Push(d.tName[i]); lnIcon.Push(d.tIcon[i]); lnCol.Push(d.tCol[i]); lnState.Push(d.tDead[i] != 0 ? 1 : 0);
			if (d.tDead[i] == 0 && !gotCol) { col = d.tCol[i]; gotCol = true; }
		}
		for (int i = 0; i < d.spPn.Size(); i++)
		{
			if (d.spPn[i] != pn) continue;
			Name cn = d.spCls[i];
			class<Actor> cc = cn;
			lnName.Push(cc ? GetDefaultByType(cc).GetTag() : d.spCls[i]); lnIcon.Push(d.spIcon[i]); lnCol.Push(col); lnState.Push(2);
		}
		int nl = max(1, lnName.Size());
		double top = min(415.0, LINE0 - (nl - 1) * LPITCH - 27);
		// half the eye's width, centred under the gaze, its foot where the mockup's is; clear of the status bar; shrunk if
		// it would rise past the gaze
		EyeMap();
		double k = EYE_TAN / MW;               // tangent a panel px (the panel is EYE_TAN wide: half the eye)
		sx = k * ptx; sy = k * pty; s = sx;
		fx = gx;
		fy = gy + (MFOOT - 250.0) * (2 * EYE_TAN / 1312.0) * pty;   // the mockup's foot: 335 of its 1312 view px under the gaze
		double floorY = shh * (1 - f);
		if (StatusBar && screenblocks <= 10) floorY = min(floorY, StatusBar.GetTopOfStatusBar() - 2.0);
		fy = min(fy, floorY);
		if ((MFOOT - top) * sy > fy - gy && fy > gy) { double kk = (fy - gy) / ((MFOOT - top) * sy); sx *= kk; sy *= kk; s = sx; }
		// THE SLAM: up from below the bottom edge, a slight overshoot
		double st = t - d.downStart[pn];
		if (st < SLAM && !RSQSM_A11y.Photo())
		{
			double x = clamp(st / SLAM, 0.0, 1.0) - 1.0;
			double p = 1.0 + (SLAM_BACK + 1.0) * x * x * x + SLAM_BACK * x * x;
			double drop = shh - (fy - (MFOOT - top) * sy);   // the panel's top at the bottom edge
			fy += (1.0 - p) * drop;
		}
		bool calm = RSQSM_A11y.Photo();
		double tt = calm ? 0.0 : t / TICRATE;

		// ---- THE BAR --------------------------------------------------------------------------------------------------
		static const double HT[] = { 14, 30, 52 };
		for (int k = 0; k < 3; k++)
		{
			double x0 = BL + (BR - BL) * k / 3.0, x1 = BL + (BR - BL) * (k + 1) / 3.0;
			Box("RSPK0B", x0 - 4, BASE - HT[k] - 4, x1 + 4, BASE + 4);
		}
		for (int k = 0; k < 3; k++)
		{
			double x0 = BL + (BR - BL) * k / 3.0, x1 = BL + (BR - BL) * (k + 1) / 3.0;
			Box("RSPK20", x0, BASE - HT[k], x1, BASE);
		}
		double total = 3.0 * RSQSM_Down.StepTics();
		double el = max(0.0, t - d.barStart[pn]);
		double fill = clamp(1.0 - el / total, 0.0, 1.0);
		double rt = t - d.refillTic[pn];
		bool sweeping = rt >= 0 && rt < RSQSM_Down.REFILL_TICS;
		double front = clamp(rt / RSQSM_Down.REFILL_TICS, 0.0, 1.0);
		// as it lands, the bar fills left to right (the same bright edge as the refill)
		double lt = t - d.downStart[pn] - SLAM * 0.75;
		if (lt < FILL_IN)
		{
			front = clamp(lt / FILL_IN, 0.0, 1.0);
			fill = min(fill, front);
			sweeping = lt >= 0;
			if (lt < 0) fill = 0;
		}
		if (sweeping && rt >= 0 && rt < RSQSM_Down.REFILL_TICS) fill = max(clamp(1.0 - d.refillOldE[pn] / total, 0.0, 1.0), front);
		double fxm = BL + (BR - BL) * fill;
		double ch, cs, cl;
		[ch, cs, cl] = ToHsl(col);
		double sat = cs * 0.95, lk = cl / 0.58;   // the mockup's bar is hsl(H, 95%, 50 +- 12%) for its colour hsl(H, 100%, 58%)
		for (int i = 0; i < 60; i++)
		{
			double x0 = BL + (BR - BL) * i / 60.0;
			double x1 = min(BL + (BR - BL) * (i + 1) / 60.0, fxm);
			if (x1 - x0 <= 0.05) break;
			double h = HT[i / 20];
			int sc = Hsl(ch + 9 * sin((tt * 4 + i * 0.45) * 57.2958), sat, (0.50 + 0.12 * sin((tt * 2.5 - i * 0.3) * 57.2958)) * lk);
			Box("RSPWHT", x0, BASE - h, x1 + 0.5, BASE, sc);
		}
		// THE REFILL: a bright edge running left to right (a white core, a glow trailing behind it), full behind it
		if (sweeping)
		{
			double ex = BL + (BR - BL) * front;
			int k = clamp(int((ex - BL) / ((BR - BL) / 3.0)), 0, 2);
			double h = HT[k];
			int hi = Mix(Light(col), 0xFFFFFF, 0.5);
			for (int g = 0; g < 4; g++)
			{
				double gw = 10.0 + g * 14.0;
				Box("RSPWHT", max(BL, ex - gw), BASE - h, ex, BASE, hi, 0.28, true);
			}
			Box("RSPWHT", max(BL, ex - 5), BASE - h - 3, ex + 1, BASE + 3, 0xFFFFFF, 1.0);
		}

		// ---- THE TARGET LINES ------------------------------------------------------------------------------------------
		for (int i = 0; i < lnName.Size(); i++)
		{
			double ly = LINE0 - i * LPITCH;
			int stt = lnState[i];
			BoxC("RSPSLOT", 150, ly, 54, 54);
			String ic = String.Format("RSPI%02dF", lnIcon[i]);
			if (stt == 1) BoxC(ic, 150, ly, 42, 42, Mix(lnCol[i], 0x0B0B0D, 0.65));
			else BoxC(ic, 150, ly, 42, 42, lnCol[i], stt == 0 ? 1.0 : 0.45);
			if (stt == 1) BoxC("RSPCRK", 150, ly, 54, 54);
			double ta = stt == 0 ? 1.0 : (stt == 1 ? 0.5 : 0.45);
			double right = Text("TARGET: " .. lnName[i], TXT_X, ly, 18, TXT_W, Light(lnCol[i]), ta);
			// dead: a thin strike-through (1.5 mockup px, at least a screen pixel), so the dimmed name stays readable
			double sth = max(1.5, 1.0 / sy);
			if (stt == 1) Box("RSPKDD", TXT_X - 2, ly - sth * 0.5, right + 2, ly + sth * 0.5, -1, 0.75);
		}

		// ---- THE CLOCK TAB ---------------------------------------------------------------------------------------------
		Box("RSPK0B", 900, 415, 1150, 585);
		Box("RSPK17", 906, 421, 1144, 579);
		Text("DEATH IN:", 916, 439, 16, 220, 0xC98A8A, 1.0);
		double secs = max(0.0, d.clk[pn] / TICRATE);
		int ss = min(99, int(secs)), hh = min(99, int((secs - int(secs)) * 100));
		// the readout as built (its digits, segments, colours, in the old plate's units), sized to sit in the tab
		static const double DX[] = { 8.3, 10.6, 13.3, 15.6 };
		static const int MASK[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };   // a b c d e f g
		double dw = 1.9, dh = 3.6, th = 0.38;
		double up = 85.0 / dh;
		double rcx = 1025, rcy = 463 + 42.5;
		int lit = 0xFF2A1A;
		for (int di = 0; di < 4; di++)
		{
			int dq = di == 0 ? ss / 10 : (di == 1 ? ss % 10 : (di == 2 ? hh / 10 : hh % 10));
			for (int s7 = 0; s7 < 7; s7++)
			{
				double x = DX[di], y = 0, w = th, h = th;
				switch (s7)
				{
				case 0: y = dh * 0.5; w = dw; break;
				case 1: x = DX[di] + dw * 0.5; y = dh * 0.25; h = dh * 0.5; break;
				case 2: x = DX[di] + dw * 0.5; y = -dh * 0.25; h = dh * 0.5; break;
				case 3: y = -dh * 0.5; w = dw; break;
				case 4: x = DX[di] - dw * 0.5; y = -dh * 0.25; h = dh * 0.5; break;
				case 5: x = DX[di] - dw * 0.5; y = dh * 0.25; h = dh * 0.5; break;
				case 6: w = dw; break;
				}
				bool on = (MASK[dq] & (1 << s7)) != 0;
				BoxC("RSPWHT", rcx + (x - 11.95) * up, rcy - y * up, w * up, h * up, lit, on ? 1.0 : 0.12);
			}
		}
		bool blink = calm || ((level.maptime / 17) & 1) == 0;
		for (int q = 0; q < 2; q++)
			BoxC("RSPWHT", rcx, rcy + (q != 0 ? 0.85 : -0.85) * up, 0.45 * up, 0.45 * up, lit, blink ? 1.0 : 0.12);
	}

	// ---- THE EDGE ARROWS ------------------------------------------------------------------------------------------------
	void DrawEdges(RSQSM_Down d, int pn)
	{
		if (!d.plate) return;
		// the mockup's view is the whole eye (2 x EYE_TAN across its 1312 px), round the gaze; scaled with the panel (owner
		// 07:55: "the edge arrows with it"), so a mockup px is the same size in the eye as the panel's (x 1312/1034 x 1/2)
		EyeMap();
		double q = 2 * EYE_TAN / VIEW_MW * ptx * (VIEW_MW * 0.5 / MW);
		double qy = 2 * EYE_TAN / VIEW_MW * pty * (VIEW_MW * 0.5 / MW);
		double cx = gx, cy = gy;
		let cv = CVar.GetCVar("rsqsm_down_marker", players[pn]);
		int style = cv ? clamp(cv.GetInt(), 0, 3) : 2;
		String sh = style == 0 ? "A" : (style == 1 ? "B" : (style == 2 ? "C" : "D"));
		// C's image: 38 x 24 cells of 4 px, its first cell 150 px out; A / B / D: 56 x 24 cells, a shape the chevrons' 88 px
		// tall, the image from 150 px out
		double w, h, rc;
		if (style == 2) { w = 152; h = 96; rc = 142 + 76; }
		else { double cpx = 88.0 / 24.0; w = 56 * cpx; h = 24 * cpx; rc = 150 + w * 0.5; }
		for (int i = 0; i < d.plate.marks.Size(); i++)
		{
			let m = d.plate.marks[i];
			if (!m || m.mode != 1 || m.dead) continue;
			double a = m.eAng;
			int fr = RSQSM_A11y.Photo() ? 0 : ((level.maptime - m.edgeTic) % 30 + 30) % 30;
			double ax = cx + cos(a) * rc * q, ay = cy - sin(a) * rc * qy;
			Rot(String.Format("RSPM%sF%02d", sh, fr), ax, ay, w * q, h * q, a, -1, false);
			Rot(String.Format("RSPM%sC%02d", sh, fr), ax, ay, w * q, h * q, a, m.col, false);
			Rot(String.Format("RSPM%sL%02d", sh, fr), ax, ay, w * q, h * q, a, Light(m.col), true);
			double ix = cx + cos(a) * 110 * q, iy = cy - sin(a) * 110 * qy;
			Rot("RSPSLOT", ix, iy, 52 * q, 52 * q, 0, -1, false);
			Rot(String.Format("RSPI%02dF", m.icon), ix, iy, 40 * q, 40 * q, 0, m.col, false);
		}
	}
	// a texture centred at a screen point, turned ang degrees (counter-clockwise, 0 = as drawn: pointing right)
	static void Rot(String tex, double x, double y, double w, double h, double ang, int rgb, bool add)
	{
		TextureID t = T(tex);
		if (!t.IsValid()) return;
		if (rgb < 0)
			Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true, DTA_Rotate, ang);
		else if (add)
			Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true, DTA_Rotate, ang,
				DTA_Color, C(rgb), DTA_LegacyRenderStyle, STYLE_Add);
		else
			Screen.DrawTexture(t, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true, DTA_Rotate, ang,
				DTA_Color, C(rgb));
	}
}
