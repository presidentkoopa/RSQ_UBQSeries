// RSQ_SlowMo -- THE DOWN PANEL AND THE EDGE ARROWS, ON THE HUD LAYER (owner 2026-11-07 07:50, design/NEAR_DEATH.md "LAYERS":
// "on the sprite/HUD layer, like Score's readout and SlowMo's bars, so the clock can never be missed, hidden by the gun or
// clipped by a wall"). Drawn the way SlowMo's own bars are (countdown.zs): RenderOverlay, Screen.DrawTexture quads in screen
// pixels, every piece its own quad (no clip rectangle: its scissor misses the projected HUD in VR). The crosshairs and the
// eye-level trail stay in the world (plate.zs). Console player only, while he is DOWN.
//
// THE LOOK SINCE 2026-11-16 is Arcade Gold (design/BANNERS_AND_HUD.md section 8; DrawArcade below). Its PLACE, SIZE and
// TIMING are still the ones described here. Before (kept for the record): the look was design/mockups/down_v3_full_view_mockup.html with its approved second version (design/mockups/README.md):
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
//   lines     one a target, stacked up from the bar. Target Lines (owner 11-07 11:0x) Icon, the default: "TARGET:" and the
//             target's own crosshair icon tinted its colour, no name, no slot at the left (owner 11:1x); Name: a dark round
//             slot (r 27) at x 150 with the target's icon (r 21), then "TARGET: <name>" (Score's monster.name: with
//             Champions, Champions' own colour words).
//             The text in a light tint of its colour (the mockup's hsl(H, 80%, 75%)). Dead: the
//             line stays, its text dimmed with a thin strike-through so it stays readable (owner 07:50), its icon dimmed
//             and cracked (the mockup's crack). Owed and not spawned yet: faint.
//   the tab   x 900..1150, y 415..585 (#0b0b0d round #170708): "DEATH IN:" small, the seven-segment SS:hh readout (its look
//             as built, sized to sit inside the tab).
//   text      RSQ Score's combo font (RSSCFN2) when Score is loaded, else JFO (platefont.zs).
// THE ENTRANCE, MIDDLE THEN SINK (owner 2026-11-09 17:45, the default; Death In Entrance row): the moment you go down the
// whole panel (bar, lines, DEATH IN) and a big "DOWN" over it appear in the MIDDLE of the view at 1.6x, hold through the
// slow-mo fall (RSQSM_Down.ENTRY_HOLD, ~1 s), then glide down and shrink to their place (ENTRY_GLIDE), the label fading as
// it goes; the thump lands as it comes to rest. Bottom Only: at its place from the first frame. Slam Up: the slam below.
// Run on the rig 2026-11-09 (design/rigtest_2026-11-09); not headset-confirmed.
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
			if (c != 32 && w > 0)
			{
				String tn = String.Format(sf ? "RSPC%03d" : "RSPJ%03d", c);
				// JFO has no glyph for some punctuation (. , ! ? % ' brackets): without RSQ Score's font those drew blank in
				// the Name target lines; the Doom font's glyph (RSPG, TEXTURES.txt) stands in (rig follow-up 2026-11-09)
				if (!sf && !TexMan.CheckForTexture(tn, TexMan.Type_Any).IsValid()) tn = String.Format("RSPG%03d", c);
				BoxC(tn, cx + adv * 0.5, y, w, h, rgb, alpha);
			}
			cx += adv;
		}
		return cx;
	}

	// BE QUICK OR BE DEAD (owner 2026-11-07 06:31, built 11-10): DOWN's player-facing name, with some of its letters
	// breathing in size (the Q, the K and both D's of DEAD, each on its own beat). The code keeps the name DOWN.
	// Breathing letters keep their place (the advance is the plain one); in Photosensitive Mode none breathe.
	const BQ_NAME = "BE QUICK OR BE DEAD";
	const BQ_AMP = 0.16;      // how much a breathing letter grows (my number)
	const BQ_HZ = 0.6;        // its beat, a second (my number)
	static double BreathOf(int k, double secs)
	{
		static const int AT[] = { 3, 7, 15, 18 };
		for (int i = 0; i < 4; i++)
			if (AT[i] == k) return 1.0 + BQ_AMP * (0.5 + 0.5 * sin(secs * 360.0 * BQ_HZ + i * 97.0));
		return 1.0;
	}
	double BreathText(String txt, double x, double y, double cap, double maxW, int rgb, double alpha, double secs)
	{
		txt = txt.MakeUpper();
		Name sn = 'RS_ScoreService';
		class<Object> sc = sn;
		bool sf = sc != null;
		double tot = 0;
		for (int k = 0; k < int(txt.Length()); k++) tot += RSQSM_PlateFont.Adv(sf, txt.ByteAt(k));
		double k0 = cap / RSQSM_PlateFont.Cap(sf);
		if (tot * k0 > maxW && tot > 0) k0 = maxW / tot;
		bool calm = RSQSM_A11y.Photo();
		double cx = x;
		for (int k = 0; k < int(txt.Length()); k++)
		{
			int c = txt.ByteAt(k);
			if (c < RSQSM_PlateFont.LO || c > RSQSM_PlateFont.HI) c = 32;
			double b = calm ? 1.0 : BreathOf(k, secs);
			double adv = RSQSM_PlateFont.Adv(sf, c) * k0, w = RSQSM_PlateFont.Wid(sf, c) * k0 * b, h = RSQSM_PlateFont.Hgt(sf, c) * k0 * b;
			if (c != 32 && w > 0)
			{
				String tn = String.Format(sf ? "RSPC%03d" : "RSPJ%03d", c);
				if (!sf && !TexMan.CheckForTexture(tn, TexMan.Type_Any).IsValid()) tn = String.Format("RSPG%03d", c);
				BoxC(tn, cx + adv * 0.5, y, w, h, rgb, alpha);
			}
			cx += adv;
		}
		return cx;
	}

	// Panel Size (owner 2026-11-07 08:00): one user number that scales the panel and the edge arrows together (1 = half the view)
	static double PanelSize() { return clamp(RSQSM_Countdown.UCv("rsqsm_down_panelsize", 1.0), 0.5, 1.8); }
	// Target Lines (owner 2026-11-07 11:0x): 0 Icon (the default), 1 Name
	static int TargetLines() { return int(RSQSM_Countdown.UCv("rsqsm_down_lines", 0)) != 0 ? 1 : 0; }
	// Death In Entrance (owner 2026-11-09 17:45): 0 Middle Then Sink (the default), 1 Bottom Only, 2 Slam Up (as before)
	static int Entry() { return clamp(int(RSQSM_Countdown.UCv("rsqsm_down_entry", 0)), 0, 2); }
	// the panel's size in the middle, x its resting size: Entrance Size row (owner 2026-11-09 18:53, rig test: "let me scale
	// the panel in a menu with a slider"; 1.6 was my number)
	static double Big() { return clamp(RSQSM_Countdown.UCv("rsqsm_down_entry_size", 1.6), 1.0, 4.0); }
	// a line of the plate's font: its width at this cap height
	double TextW(String txt, double cap)
	{
		txt = txt.MakeUpper();
		Name sn = 'RS_ScoreService';
		class<Object> sc = sn;
		bool sf = sc != null;
		double tot = 0;
		for (int k = 0; k < int(txt.Length()); k++) tot += RSQSM_PlateFont.Adv(sf, txt.ByteAt(k));
		return tot * cap / RSQSM_PlateFont.Cap(sf);
	}
	const LICON = 40.0;     // the icon after "TARGET:" (mockup px; the slot's icon is 42 in a 62 px line pitch)

	// RSQSM_Down.RenderOverlay calls this every frame
	void Draw(RSQSM_Down d, RenderEvent e)
	{
		if (gamestate != GS_LEVEL || screenblocks > 11 || automapactive || menuactive != Menu.Off) return;   // not over a menu (owner 11-11)
		int pn = consoleplayer;
		if (!d || !d.IsDown(pn) || !players[pn].mo) return;
		DrawArcade(d, pn, level.maptime + e.FracTic);
		DrawEdges(d, pn);
	}

	// =================================================================================================================
	// THE ARCADE GOLD LOOK (owner 2026-11-16 02:37-02:49, design/BANNERS_AND_HUD.md section 8; mockups
	// mockups/banners/DOWN_now_vs_proposed.jpg, DOWN_proposed_settled_v2.jpg, anim_DOWN_blood_bar.gif). The same place and
	// timing as before (the panel's size, the gaze, Middle Then Sink, Bottom Only, Slam Up): only the look is new.
	//   GOING DOWN (the middle): the OUCH face greyed and a big red DOWN! (RSSCFON's letters in red bands, pre-made:
	//     graphics/rsqsmdn/RSQSRnnn, VisualRewards/tools/gen_banners.py), BE QUICK OR BE DEAD under it in the same red
	//     letters (Q, K and the D's still breathe), then the chips pop in sequence as the banners' do: n KILL(S) TO GET UP,
	//     nn% HEALTH (the getting-up health by the DOWN count, down.zs UpHealthShare: 100 / 66 / 33 %), DEATH IN with the
	//     seven-segment clock in its chip.
	//   SETTLED (the panel): BE QUICK OR BE DEAD small on top; one TARGET chip per target in its colour (dead: dimmed and
	//     struck through; owed and not here yet: faint); the bar; the DEATH IN chip beside it.
	//   THE BAR: the series' bar (RSQSMHE / RSQSMHW, drawn by countdown.zs Draw: 8 tinted steps, the sweeping band, the
	//     breathing edge), pulsing blood red (dark crimson to bright blood red, one beat every 0.8 s; Photosensitive Mode:
	//     once a second and dimmed), draining with the clock. Its icon the bloodied low-health Doomguy (the IWAD's STFST40 /
	//     41 / 42: one way, ahead, the other way, 0.2 s a frame). No skull and no gold: never the Boss bar.
	// Laid out in the panel's mockup px (MW wide, foot MFOOT; X() / Y()). Rig only, not headset-confirmed.
	const AROW = 548.0;       // the bar row's middle
	const ABAR_H = 34.0;      // the bar's thickness
	const AFACE_H = 72.0;     // the bloodied face's height
	const ACHIP_H = 64.0;     // the DEATH IN chip's height
	const ATG_Y = 470.0;      // the target chips' row (the first; more rows go up)
	const ATG_H = 48.0;
	const ATG_PITCH = 56.0;
	const ATG_ROW = 4;        // target chips a row
	const ABQ_CAP = 30.0;     // BE QUICK OR BE DEAD, settled
	const SEG_U = 11.0;        // the clock's segment unit (mockup px), so its digits are 3.6 x SEG_U tall
	// the entrance (in the same px, round the panel's middle, which Middle Then Sink puts on the gaze)
	const EDOWN_Y = 318.0;
	const EDOWN_CAP = 104.0;
	const EBQ_Y = 404.0;
	const EBQ_CAP = 34.0;
	const ECHIP_Y = 470.0;
	const ECHIP_H = 52.0;

	static double APop(double t, double dur = 8.0)
	{
		if (t < 0) return 0;
		double u = t / dur;
		if (u < 0.5) return 0.2 + 2.3 * u;
		if (u < 1.0) return 1.35 - 0.7 * (u - 0.5);
		return 1.0;
	}

	// the dark rounded pill (the banners' chip), x0..x1, y0..y1 in panel px; its round ends kept, its middle stretched
	void APill(double x0, double y0, double x1, double y1, double a)
	{
		TextureID t = T("RSQSMPL");
		if (!t.IsValid() || a <= 0.003) return;
		double px = X(x0), py = Y(y0), w = (x1 - x0) * sx, h = (y1 - y0) * sy;
		double cap = min((y1 - y0) * sx * 12.0 / 32.0, w * 0.5);
		Screen.DrawTexture(t, false, px, py, DTA_DestWidthF, cap, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_SrcX, 0.0, DTA_SrcWidth, 12.0, DTA_Alpha, a);
		if (w > 2 * cap)
			Screen.DrawTexture(t, false, px + cap, py, DTA_DestWidthF, w - 2 * cap, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_SrcX, 12.0, DTA_SrcWidth, 8.0, DTA_Alpha, a);
		Screen.DrawTexture(t, false, px + w - cap, py, DTA_DestWidthF, cap, DTA_DestHeightF, h, DTA_TopLeft, true, DTA_SrcX, 20.0, DTA_SrcWidth, 12.0, DTA_Alpha, a);
	}
	// a chip's width: an icon (or not), a number at the larger size and a word at the smaller, h tall
	double AChipW(bool icon, String num, String word, double h)
	{
		double u = h / 52.0, w = 28 * u;
		int parts = 0;
		if (icon) { w += 30 * u; parts++; }
		if (num != "") { w += TextW(num, 24 * u); parts++; }
		if (word != "") { w += TextW(word, 17 * u); parts++; }
		return w + max(0, parts - 1) * 10 * u;
	}
	// a chip centred on (cx, cy), h tall at rest, popped k
	void AChip(String icon, int irgb, String num, String word, int trgb, double cx, double cy, double h, double k, double a)
	{
		if (k <= 0.01 || a <= 0.01) return;
		h *= k;
		double u = h / 52.0, w = AChipW(icon != "", num, word, h);
		double x = cx - w * 0.5;
		APill(x, cy - h * 0.5, x + w, cy + h * 0.5, a);
		x += 14 * u;
		if (icon != "") { Box(icon, x, cy - 15 * u, x + 30 * u, cy + 15 * u, irgb, a); x += 40 * u; }
		if (num != "") x = Text(num, x, cy, 24 * u, 1e6, trgb, a) + 10 * u;
		if (word != "") Text(word, x, cy, 17 * u, 1e6, trgb, a);
	}
	// RSSCFON's letters in red bands (RSQSRnnn), centred on (cx, cy), cap tall (the letter cell with its outline); the
	// breathing letters of BE QUICK OR BE DEAD when breathe. Returns the width.
	double ARed(String txt, double cx, double cy, double cap, double a, bool breathe, double secs, bool measure = false)
	{
		txt = txt.MakeUpper();
		TextureID t0 = T("RSQSR065");
		if (!t0.IsValid()) return 0;
		int gw0, gh0;
		[gw0, gh0] = TexMan.GetSize(t0);                  // (vectors' .x / .y read as this class's X() / Y() here)
		double k = cap / max(1, gh0);                      // panel px a letter pixel
		double tot = 0;
		for (int i = 0; i < int(txt.Length()); i++)
		{
			int c = txt.ByteAt(i);
			TextureID t = T(String.Format("RSQSR%03d", c));
			int tw1, th1;
			if (t.IsValid()) [tw1, th1] = TexMan.GetSize(t);
			tot += (c == 32 || !t.IsValid()) ? 5 * k : (tw1 + 1) * k;
		}
		tot -= k;
		if (measure || a <= 0.003) return tot;
		bool calm = RSQSM_A11y.Photo();
		double x = cx - tot * 0.5;
		for (int i = 0; i < int(txt.Length()); i++)
		{
			int c = txt.ByteAt(i);
			TextureID t = T(String.Format("RSQSR%03d", c));
			if (c == 32 || !t.IsValid()) { x += 5 * k; continue; }
			int tw2, th2;
			[tw2, th2] = TexMan.GetSize(t);
			double b = (breathe && !calm) ? BreathOf(i, secs) : 1.0;
			double w = tw2 * k, h = th2 * k;
			// a drop shadow a letter pixel down and right, then the letter
			Screen.DrawTexture(t, false, X(x + w * 0.5 + k), Y(cy + k), DTA_DestWidthF, w * b * sx, DTA_DestHeightF, h * b * sy, DTA_CenterOffset, true,
				DTA_FillColor, 0, DTA_Alpha, 0.6 * a);
			Screen.DrawTexture(t, false, X(x + w * 0.5), Y(cy), DTA_DestWidthF, w * b * sx, DTA_DestHeightF, h * b * sy, DTA_CenterOffset, true,
				DTA_Alpha, a);
			x += w + k;
		}
		return tot;
	}
	// a Doomguy face of the IWAD's, centred, h tall (panel px), a dark outline a face pixel wide; grey: desaturated, cold
	void AFace(String n, double cx, double cy, double h, double a, bool grey)
	{
		TextureID t = T(n);
		if (!t.IsValid() || a <= 0.003) return;
		int fw, fh;
		[fw, fh] = TexMan.GetSize(t);
		double w = h * fw / max(1, fh), o = h / max(1, fh);
		for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++)
		{
			if (!dx && !dy) continue;
			Screen.DrawTexture(t, false, X(cx + dx * o), Y(cy + dy * o), DTA_DestWidthF, w * sx, DTA_DestHeightF, h * sy, DTA_CenterOffset, true,
				DTA_FillColor, 0x080606, DTA_Alpha, a);
		}
		if (grey)
			Screen.DrawTexture(t, false, X(cx), Y(cy), DTA_DestWidthF, w * sx, DTA_DestHeightF, h * sy, DTA_CenterOffset, true,
				DTA_Desaturate, 255, DTA_Color, Color(255, 210, 216, 232), DTA_Alpha, a);
		else
			Screen.DrawTexture(t, false, X(cx), Y(cy), DTA_DestWidthF, w * sx, DTA_DestHeightF, h * sy, DTA_CenterOffset, true, DTA_Alpha, a);
	}
	// the seven-segment clock (as built: its digits, segments and colours), centred on (rcx, rcy), a segment unit up px
	void ASeg(double secs, double rcx, double rcy, double up, double a)
	{
		int ss = min(99, int(secs)), hh = min(99, int((secs - int(secs)) * 100));
		static const double DX[] = { 8.3, 10.6, 13.3, 15.6 };
		static const int MASK[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };
		double dw = 1.9, dh = 3.6, th = 0.38;
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
				BoxC("RSPWHT", rcx + (x - 11.95) * up, rcy - y * up, w * up, h * up, lit, (on ? 1.0 : 0.12) * a);
			}
		}
		bool blink = RSQSM_A11y.Photo() || ((level.maptime / 17) & 1) == 0;
		for (int q = 0; q < 2; q++)
			BoxC("RSPWHT", rcx, rcy + (q != 0 ? 0.85 : -0.85) * up, 0.45 * up, 0.45 * up, lit, (blink ? 1.0 : 0.12) * a);
	}
	// the DEATH IN chip centred on (cx, cy), h tall at rest, popped k; its width at rest
	double AClockW(double h) { double u = h / ACHIP_H; return 28 * u + TextW("DEATH IN", 18 * u) + 14 * u + 9.6 * SEG_U * u; }
	void AClock(double secs, double cx, double cy, double h, double k, double a)
	{
		if (k <= 0.01 || a <= 0.01) return;
		h *= k;
		double u = h / ACHIP_H, w = AClockW(h);
		double x = cx - w * 0.5;
		APill(x, cy - h * 0.5, x + w, cy + h * 0.5, a);
		double r = Text("DEATH IN", x + 14 * u, cy, 18 * u, 1e6, 0xFF8C78, a);
		ASeg(secs, r + 14 * u + 4.8 * SEG_U * u, cy, SEG_U * u, a);
	}

	void DrawArcade(RSQSM_Down d, int pn, double t)
	{
		double sw = Screen.GetWidth(), shh = Screen.GetHeight();
		double f = clamp(RSQSM_Countdown.SCv("rsq_ui_inset", 0.04), 0.0, 0.3);
		// the targets: this player's, then the ones owed and not spawned yet
		Array<String> lnName;
		Array<int> lnIcon, lnCol, lnState;      // 0 alive, 1 dead, 2 waiting
		int col = RSQSM_Down.DOWN_RED;
		bool gotCol = false;
		int killed = 0;
		for (int i = 0; i < d.tMon.Size(); i++)
		{
			if (d.tPn[i] != pn) continue;
			if (d.tDead[i] != 0) killed++;
			if (d.tDead[i] == 2) continue;
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
		int rows = (nl + ATG_ROW - 1) / ATG_ROW;
		double topS = ATG_Y - ATG_H * 0.5 - (rows - 1) * ATG_PITCH - 10 - ABQ_CAP;
		double topE = EDOWN_Y - EDOWN_CAP * 0.6;
		double top = min(topS, topE);
		// the panel's place and size, exactly as before (DrawPanel): half the eye wide, under the gaze, clear of the
		// status bar, shrunk if it would rise past the gaze; Middle Then Sink: big on the gaze, then down to its place
		EyeMap();
		double k = EYE_TAN / MW * PanelSize();
		sx = k * ptx; sy = k * pty; s = sx;
		fx = gx;
		fy = gy + (MFOOT - 250.0) * (2 * EYE_TAN / 1312.0) * pty;
		double floorY = shh * (1 - f);
		if (StatusBar && screenblocks <= 10) floorY = min(floorY, StatusBar.GetTopOfStatusBar() - 2.0);
		fy = min(fy, floorY);
		if ((MFOOT - topS) * sy > fy - gy && fy > gy) { double kk = (fy - gy) / ((MFOOT - topS) * sy); sx *= kk; sy *= kk; s = sx; }
		double st = t - d.downStart[pn];
		int entry = Entry();
		double label = 0;     // the entrance's share (1 in the middle, 0 settled)
		if (entry == 0)
		{
			double big = Big(), bsx = sx * big, bsy = sy * big;
			double wmax = 2.0 * EYE_TAN * ptx * 0.94;
			if (MW * bsx > wmax) { double kk = wmax / (MW * bsx); bsx *= kk; bsy *= kk; }
			double bfy = gy + (MFOOT - (top + MFOOT) * 0.5) * bsy;
			double g = clamp((st - RSQSM_Down.ENTRY_HOLD) / double(RSQSM_Down.ENTRY_GLIDE), 0.0, 1.0);
			g = g * g * (3.0 - 2.0 * g);
			sx = bsx + (sx - bsx) * g; sy = bsy + (sy - bsy) * g; s = sx;
			fy = bfy + (fy - bfy) * g;
			label = 1.0 - g;
		}
		if (entry == 2 && st < SLAM && !RSQSM_A11y.Photo())
		{
			double x = clamp(st / SLAM, 0.0, 1.0) - 1.0;
			double p = 1.0 + (SLAM_BACK + 1.0) * x * x * x + SLAM_BACK * x * x;
			double drop = shh - (fy - (MFOOT - topS) * sy);
			fy += (1.0 - p) * drop;
		}
		bool calm = RSQSM_A11y.Photo();
		double secsNow = t / double(TICRATE);
		double settled = 1.0 - label;
		double secs = max(0.0, d.clk[pn] / TICRATE);

		// ---- GOING DOWN: the OUCH face and DOWN!, BE QUICK OR BE DEAD, the chips in sequence ---------------------------
		if (label > 0.01)
		{
			double kd = APop(st);
			double dw = ARed("DOWN!", 0, 0, EDOWN_CAP, 1, false, 0, true);
			double fh = EDOWN_CAP * 1.08;
			double fwid = fh * 24.0 / 29.0;
			double rowW = fwid + 24 + dw;
			double x0 = MCX - rowW * 0.5;
			AFace("STFOUCH0", x0 + fwid * 0.5, EDOWN_Y, fh * kd, label, true);
			ARed("DOWN!", x0 + fwid + 24 + dw * 0.5, EDOWN_Y, EDOWN_CAP * min(kd, 1.12), label, false, 0);
			if (st >= 4) ARed(BQ_NAME, MCX, EBQ_Y, EBQ_CAP * min(APop(st - 4), 1.12), label, true, secsNow);
			// n KILL(S) TO GET UP, nn% HEALTH (the getting-up health by the DOWN count: down.zs UpHealthShare)
			int left = max(0, d.owed[pn] - killed);
			let w = RSQSM_DownWatch(players[pn].mo.FindInventory("RSQSM_DownWatch"));
			int pct = int(round(RSQSM_Down.UpHealthShare(w ? max(1, w.downs) : 1) * 100));
			String kw = left == 1 ? "KILL TO GET UP" : "KILLS TO GET UP";
			String hn = String.Format("%d%%", pct);
			double w0 = AChipW(true, String.Format("%d", left), kw, ECHIP_H), w1 = AChipW(true, hn, "HEALTH", ECHIP_H);
			double cx0 = MCX - (w0 + w1 + 16) * 0.5;
			AChip("RSQSMID", -1, String.Format("%d", left), kw, 0xFF7A66, cx0 + w0 * 0.5, ECHIP_Y, ECHIP_H, APop(st - 10), label);
			AChip("RSQSMIH", -1, hn, "HEALTH", 0x8CF08C, cx0 + w0 + 16 + w1 * 0.5, ECHIP_Y, ECHIP_H, APop(st - 14), label);
		}

		// ---- SETTLED: BE QUICK OR BE DEAD, the target chips, the bar row ----------------------------------------------
		double cw = AClockW(ACHIP_H);
		double faceW = AFACE_H * 24.0 / 29.0;
		double barL = MCX - MW * 0.5 + faceW + 14, barR = MCX + MW * 0.5 - cw - 14;
		if (settled > 0.01)
		{
			ARed(BQ_NAME, MCX, topS + ABQ_CAP * 0.5, ABQ_CAP, settled, true, secsNow);
			bool iconLines = TargetLines() == 0;
			for (int r = 0; r < rows; r++)
			{
				int a0 = r * ATG_ROW, a1 = min(lnName.Size(), a0 + ATG_ROW);
				double tot = 0;
				for (int i = a0; i < a1; i++) tot += AChipW(true, "", iconLines ? "TARGET" : "TARGET " .. lnName[i], ATG_H) + (i > a0 ? 12 : 0);
				double x = MCX - tot * 0.5, y = ATG_Y - r * ATG_PITCH;
				for (int i = a0; i < a1; i++)
				{
					String word = iconLines ? "TARGET" : "TARGET " .. lnName[i];
					double w = AChipW(true, "", word, ATG_H);
					int stt = lnState[i];
					double ta = (stt == 0 ? 1.0 : (stt == 1 ? 0.5 : 0.45)) * settled;
					String ic = String.Format("RSPI%02dF", lnIcon[i]);
					AChip(ic, stt == 1 ? Mix(lnCol[i], 0x0B0B0D, 0.65) : lnCol[i], "", word, Light(lnCol[i]), x + w * 0.5, y, ATG_H, 1.0, ta);
					// dead: a thin strike-through so it stays readable
					if (stt == 1)
					{
						double sth = max(1.5, 1.0 / sy);
						Box("RSPKDD", x + 8, y - sth * 0.5, x + w - 8, y + sth * 0.5, -1, 0.75 * settled);
					}
					x += w + 12;
				}
			}

			// THE BAR: the series' bar, pulsing blood red, draining with the clock
			double total = max(1.0, RSQSM_Down.ClockTics());
			double fill = clamp(d.clk[pn] / total, 0.0, 1.0);
			double lt = st - SLAM * 0.75;
			if (lt < FILL_IN) fill = lt < 0 ? 0 : min(fill, clamp(lt / FILL_IN, 0.0, 1.0));
			double rt = t - d.refillTic[pn];
			double glint = (rt >= 0 && rt < RSQSM_Down.REFILL_TICS && !calm) ? 1.0 - rt / RSQSM_Down.REFILL_TICS : 0.0;
			// one beat every 0.8 s (28 tics); Photosensitive Mode: once a second (35) and half as deep
			double beat = calm ? 0.5 + 0.25 * sin(t * 360.0 / 35.0) : 0.5 + 0.5 * sin(t * 360.0 / 28.0);
			Color lo = Color(255, 60, 0, 0);
			Color mid = RSQSM_BarLife.Mix(Color(255, 160, 8, 12), Color(255, 200, 14, 18), beat);
			Color hi = RSQSM_BarLife.Mix(Color(255, 235, 40, 40), Color(255, 255, 90, 80), beat);
			TextureID te = T("RSQSMHE"), tw = T("RSQSMHW");
			if (te.IsValid() && tw.IsValid())
				RSQSM_Countdown.Draw(te, tw, X(barL), Y(AROW - ABAR_H * 0.5), (barR - barL) * sx, ABAR_H * sy, fill, lo, mid, hi,
					settled, true, calm, glint, t, settled);
			// its icon: the bloodied low-health face, looking one way, ahead, the other way (0.2 s a frame)
			static const int SEQ[] = { 40, 40, 41, 42, 42, 41 };
			int fr = SEQ[(level.maptime / 7) % 6];
			AFace(String.Format("STFST%d", fr), barL - 14 - faceW * 0.5, AROW, AFACE_H, settled, false);
		}
		// THE DEATH IN CHIP: centred under the entrance's chips in the middle, beside the bar settled (it moves between)
		double ccx = (barR + 14 + cw * 0.5) * settled + MCX * label;
		double ccy = AROW * settled + (ECHIP_Y + ECHIP_H * 0.5 + 18 + ACHIP_H * 0.5) * label;
		double ck = label > 0.01 ? APop(st - 18) : 1.0;
		AClock(secs, ccx, ccy, ACHIP_H, ck, 1.0);
	}

	// ---- THE EDGE ARROWS ------------------------------------------------------------------------------------------------
	void DrawEdges(RSQSM_Down d, int pn)
	{
		if (!d.plate) return;
		EdgeSetup(pn);
		for (int i = 0; i < d.plate.marks.Size(); i++)
		{
			let m = d.plate.marks[i];
			if (!m || m.mode != 1 || m.dead) continue;
			int fr = EdgeFrame(m.edgeTic);
			EdgeArrow(m.eAng, fr, m.col, 1.0, m.icon);
		}
	}
	// the momentum loop's frame (30 baked frames) from when the arrow came up; Photosensitive Mode: the first, held still
	static int EdgeFrame(int since) { return RSQSM_A11y.Photo() ? 0 : ((level.maptime - since) % 30 + 30) % 30; }
	// this frame's edge-arrow scale and style (shared with RSQSM_Arrows, arrows.zs: other mods' arrows look the same)
	double eq, eqy;
	int eStyle;
	void EdgeSetup(int pn)
	{
		// the mockup's view is the whole eye (2 x EYE_TAN across its 1312 px), round the gaze; scaled with the panel (owner
		// 07:55: "the edge arrows with it"), so a mockup px is the same size in the eye as the panel's (x 1312/1034 x 1/2)
		EyeMap();
		eq = 2 * EYE_TAN / VIEW_MW * ptx * (VIEW_MW * 0.5 / MW) * PanelSize();
		eqy = 2 * EYE_TAN / VIEW_MW * pty * (VIEW_MW * 0.5 / MW) * PanelSize();
		let cv = CVar.GetCVar("rsqsm_down_marker", players[pn]);
		eStyle = cv ? clamp(cv.GetInt(), 0, 3) : 2;
	}
	// one edge arrow round the gaze (EdgeSetup first): direction a (degrees, 0 right, 90 up), its momentum frame fr, its
	// colour, its size (1 = DOWN's; bigger grows outward, its inner end where DOWN's is) and the target's icon on a dark slot
	// on its inner side (icon < 0: none)
	void EdgeArrow(double a, int fr, int col, double size, int icon)
	{
		double q = eq, qy = eqy, cx = gx, cy = gy;
		String sh = eStyle == 0 ? "A" : (eStyle == 1 ? "B" : (eStyle == 2 ? "C" : "D"));
		// C's image: 38 x 24 cells of 4 px, its first cell 150 px out; A / B / D: 56 x 24 cells, a shape the chevrons' 88 px
		// tall, the image from 150 px out
		double w, h, rc;
		if (eStyle == 2) { w = 152; h = 96; rc = 142 + 76; }
		else { double cpx = 88.0 / 24.0; w = 56 * cpx; h = 24 * cpx; rc = 150 + w * 0.5; }
		if (size > 0 && size != 1.0) { rc += w * (size - 1.0) * 0.5; w *= size; h *= size; }
		double ax = cx + cos(a) * rc * q, ay = cy - sin(a) * rc * qy;
		Rot(String.Format("RSPM%sF%02d", sh, fr), ax, ay, w * q, h * q, a, -1, false);
		Rot(String.Format("RSPM%sC%02d", sh, fr), ax, ay, w * q, h * q, a, col, false);
		Rot(String.Format("RSPM%sL%02d", sh, fr), ax, ay, w * q, h * q, a, Light(col), true);
		if (icon < 0) return;
		double ix = cx + cos(a) * 110 * q, iy = cy - sin(a) * 110 * qy;
		Rot("RSPSLOT", ix, iy, 52 * q, 52 * q, 0, -1, false);
		Rot(String.Format("RSPI%02dF", icon), ix, iy, 40 * q, 40 * q, 0, col, false);
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
