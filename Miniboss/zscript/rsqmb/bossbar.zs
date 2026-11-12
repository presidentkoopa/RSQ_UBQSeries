// ============================================================================
// RSQ_Miniboss -- THE MINIBOSS BAR on the HUD (owner 2026-11-12, mockup "E - Arrival" on the boss bar canvas, approved 15:07
// "Yes, build it"; its place, owner 05:56: "a hud boss health bar where Be Quick or Be Dead is").
//
// WHERE AND HOW BIG (owner 15:28: "why is the bar where it is and not where we agreed it would be"): where RSQ SlowMo's
// Be Quick or Be Dead panel stands, by the same rule (SlowMo/zscript/rsqsm/downhud.zs EyeMap and its placement): laid out
// in the mockup's own pixels and scaled as one piece to half of what you see in the headset eye, centred under your gaze,
// its foot where that panel's foot is, clear of the status bar and inside the series' safe area. While you are DOWN that
// panel has the spot and this bar steps aside.
// THE LOOK is the mockup's, piece for piece, from the same series art (tools/gen_bossbar.py bakes it):
//   the head     the crowned skull with the red crosshair over it (RSQMBHD), 150 x 150 at 14, 36;
//   the name     gold, the score font (MBFG glyphs), 32 high at 190, 44 ("<SPECIES> WARLORD", owner 14:11: not coloured);
//   the bar      540 x 30 at 186, 90, leaning 26 degrees: a white rim (#e8ecf4, 4), a dark well (#120e1a), the fill in its
//                colour (light at the top, deep at the foot), a dark red trail (#7c1422) where health just went;
//                guarded, a grey fill (#b9bdc8 / #8a8f9c / #6a6e7a); a white flash as it goes live;
//   GUARD        silver (MBFS glyphs), 22 high, ending at 706, over the bar's right end, while it cannot be hurt;
//   X2           gold, 30 high at 744, 90, while it has more than one bar;
//   the clock    96 x 38 at 826, 86: #1a0606 inside a #5a1410 rim, red (#ff3b30) seven-segment SS:hh (RSQ SlowMo's DOWN
//                readout's digits), ONLY while the arrival's charge counts 03:00 down (owner 15:36: not during the fight);
//   the thralls  a 150 x 16 bar each (rim 3) at y 238, 40 apart, centred under the miniboss bar; over each, side by side
//                and centred, its crosshair (RSQ SlowMo's DOWN crosshairs, RSQMBX, in its colour) and its Champion icon.
// THE ARRIVAL (owner 14:11): the bar appears as a sliver and grows outward, empty (BB_GROW); each thrall's bar and icons pop
// in as it lands; the miniboss lands, its head, name and X2 come in, and its bar charges over 3 seconds while the clock
// counts 03:00 down and nobody in the encounter acts or can be hurt (boss.zs ChargeStart / ChargeEnd); then it flashes into
// its colour. Timings are the mockup's (its 12 s loop).
// VR: boxes and textures only (no clip rectangle, no Screen.Dim). PHOTOSENSITIVE MODE (RSQMB_A11y): no flash.
// Rig only, not headset-confirmed.
// ============================================================================

extend class RSQMB_Handler
{
	const BB_CHARGE = 105;      // the arrival's charge: 3 seconds (owner 14:11)
	const BB_GROW = 40.0;       // the sliver growing to the full bar (the mockup: 2% to 12% of 12 s)
	const BB_POP = 13.0;        // a thrall's bar and icons popping in (3% of 12 s)
	const BB_TFILL = 17.0;      // ... then its fill (4%)
	const BB_ARRIVE = 10.0;     // the head, name and X2 coming in (2.5%)
	const BB_FLASH = 18.0;      // the white flash going (4%)
	const BB_LEAN = 0.4877;     // tan 26 degrees
	// the mockup's frame: what is drawn spans x 14..922, y 36..254; its middle goes under the gaze, its foot where Be
	// Quick or Be Dead's foot is
	const BB_MW = 908.0;
	const BB_MCX = 468.0;
	const BB_MFOOT = 254.0;
	const GUARD_SHAKE = 12.0;   // tics GUARD shakes after a blow on the guarded miniboss
	const BB_LIFT = 110.0;
	const TB_STEP = 3.0;        // tics per shade on the live miniboss bar (SOTN's boss bar steps about this fast)      // raised this many mockup px above Be Quick or Be Dead's foot
	const BB_EYE_TAN = 0.91;    // RSQ SlowMo's measured eye (downhud.zs EYE_TAN)

	ui bool   bbWas;
	ui double bbStart;
	ui double bbLag, bbLast, bbMbT;
	ui double bbThrT[8];
	ui double bbThrMax[8];
	ui int    bbThrIc[8];
	ui int    bbIcTic;
	// this frame's mapping, mockup px -> screen px
	ui double bbSx, bbSy, bbFx, bbFy;
	ui double bbA;

	ui double BX(double mx) { return bbFx + (mx - BB_MCX) * bbSx; }
	ui double BY(double my) { return bbFy - (BB_MFOOT - my) * bbSy; }

	// the HUD in the eye, as RSQ SlowMo's Be Quick or Be Dead panel maps it (downhud.zs EyeMap), and its placement
	ui void BBMap()
	{
		double sw = Screen.GetWidth(), shh = Screen.GetHeight();
		double ptx, pty, gx, gy;
		let vm = CVar.FindCVar("vr_mode");
		if (!vm || vm.GetInt() == 0)
		{
			ptx = sw * 0.5 / BB_EYE_TAN; pty = ptx; gx = sw * 0.5; gy = shh * 0.5;
		}
		else
		{
			let hs = CVar.FindCVar("vr_hud_scale");
			let hr = CVar.FindCVar("vr_hud_rotate");
			double scale = hs ? max(0.05, hs.GetFloat()) : 0.4;
			double ps = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
			ptx = sw * 0.5 / scale;
			pty = shh * 0.5 / (scale * ps);
			gx = sw * 0.5;
			gy = shh * 0.5 - tan(hr ? hr.GetFloat() : 0.0) * pty;
		}
		double k = BB_EYE_TAN / BB_MW;
		bbSx = k * ptx; bbSy = k * pty;
		bbFx = gx;
		bbFy = gy + 335.0 * (2 * BB_EYE_TAN / 1312.0) * pty;   // Be Quick or Be Dead's foot: 335 of its 1312 view px under the gaze
		double f = clamp(CF('rsq_ui_inset', 0.04), 0.0, 0.3);
		double floorY = shh * (1 - f);
		if (StatusBar && screenblocks <= 10) floorY = min(floorY, StatusBar.GetTopOfStatusBar() - 2.0);
		bbFy = min(bbFy, floorY);
		// RAISED (owner 15:36 "raise the bar some"): its foot BB_LIFT mockup px above Be Quick or Be Dead's, clear of the HUD's
		// health and armour row
		bbFy -= BB_LIFT * bbSy;
		// shrunk, never moved, if it would rise past the gaze
		double tall = (BB_MFOOT - 36.0) * bbSy;
		if (bbFy > gy && tall > bbFy - gy) { double kk = (bbFy - gy) / tall; bbSx *= kk; bbSy *= kk; }
	}

	ui void BBBox(TextureID wh, double mx, double my, double mw, double mh, Color c, double a = 1.0)
	{
		if (mw <= 0 || mh <= 0 || a <= 0) return;
		Screen.DrawTexture(wh, false, BX(mx), BY(my), DTA_DestWidthF, mw * bbSx, DTA_DestHeightF, mh * bbSy,
			DTA_Color, c, DTA_Alpha, a * bbA);
	}

	static ui Color BBGrad(Color top, Color mid, Color bot, double k)
	{
		return k < 0.45 ? Mix(top, mid, k / 0.45) : Mix(mid, bot, (k - 0.45) / 0.55);
	}

	// the slanted bar at mockup x, y, w, h (leaning 26 degrees about its middle), rim rim: the trail to lag, the fill to frac
	// (light top, c, deep foot), a white flash over it all; grow scales it across about its middle
	ui void BBBar(TextureID wh, double mx, double my, double mw, double mh, double rim, double frac, Color top, Color c,
		Color bot, double lag, double flash, double grow = 1.0, double a = 1.0, bool tube = false)
	{
		if (a <= 0) return;
		int rows = max(4, int(mh / 2.0));
		double rh = mh / rows;
		double w = mw * grow, x0 = mx + (mw - w) * 0.5;
		Color rimc = Color(255, 0xE8, 0xEC, 0xF4), well = Color(255, 0x12, 0x0E, 0x1A), trail = Color(255, 0x7C, 0x14, 0x22);
		frac = clamp(frac, 0.0, 1.0);
		for (int r = 0; r < rows; r++)
		{
			double yy = my + r * rh, ym = yy + rh * 0.5;
			double off = (mh * 0.5 - (ym - my)) * BB_LEAN;
			BBBox(wh, x0 + off, yy, w, rh + 0.4, rimc, a);
			if (ym - my < rim || my + mh - ym < rim) continue;
			double ix = x0 + off + rim, iw = w - 2 * rim;
			if (iw <= 0) continue;
			BBBox(wh, ix, yy, iw, rh + 0.4, well, a);
			if (lag > frac) BBBox(wh, ix + iw * frac, yy, iw * (min(lag, 1.0) - frac), rh + 0.4, trail, a);
			double k = (ym - my - rim) / max(1.0, mh - 2 * rim);
			Color fc = BBGrad(top, c, bot, k);
			if (tube)
			{
				// THE SOTN GLASS TUBE (the boss bar in Richter's fight, owner 18:26): round across its height, dark at the
				// edges, a bright streak running its length a little above the middle
				double hl = (k - 0.3) / 0.13; hl = 1.0 / (1.0 + hl * hl * hl * hl);
				double ed = abs(k - 0.5) * 2.0; ed *= ed;
				fc = Mix(Mix(c, Color(255, 0, 0, 0), 0.55 * ed), Color(255, 255, 255, 255), 0.5 * hl);
			}
			if (frac > 0.001) BBBox(wh, ix, yy, iw * frac, rh + 0.4, fc, a);
			if (flash > 0.01) BBBox(wh, ix, yy, iw, rh + 0.4, Color(255, 255, 255, 255), a * flash);
		}
	}

	// a word in the baked score font (MBFG gold / MBFS silver), hgt mockup px tall, from mockup x (right: ending at x);
	// returns its width in mockup px; measure: nothing drawn
	ui double BBWord(String s, String set, double mx, double my, double hgt, double a = 1.0, bool right = false, bool measure = false)
	{
		double k = hgt / 48.0;
		double w = 0;
		for (int i = 0; i < s.Length(); i++)
		{
			int ch = s.ByteAt(i);
			if (ch >= 97 && ch <= 122) ch -= 32;
			TextureID g = TexMan.CheckForTexture(String.Format("%s%03d", set, ch), TexMan.Type_Any);
			if (ch == 32 || !g.IsValid()) { w += 18 * k; continue; }
			Vector2 gs = TexMan.GetScaledSize(g);
			w += gs.x * k + 2 * k;
		}
		if (measure) return w;
		double cx = right ? mx - w : mx;
		for (int i = 0; i < s.Length(); i++)
		{
			int ch = s.ByteAt(i);
			if (ch >= 97 && ch <= 122) ch -= 32;
			TextureID g = TexMan.CheckForTexture(String.Format("%s%03d", set, ch), TexMan.Type_Any);
			if (ch == 32 || !g.IsValid()) { cx += 18 * k; continue; }
			Vector2 gs = TexMan.GetScaledSize(g);
			double gw = gs.x * k;
			Screen.DrawTexture(g, false, BX(cx), BY(my), DTA_DestWidthF, gw * bbSx, DTA_DestHeightF, hgt * bbSy, DTA_Alpha, a * bbA);
			cx += gw + 2 * k;
		}
		return w;
	}

	// a texture at mockup x, y, w, h, scaled about its middle by sc
	ui void BBTex(String name, double mx, double my, double mw, double mh, double a = 1.0, double sc = 1.0, Color c = 0xFFFFFFFF)
	{
		TextureID g = TexMan.CheckForTexture(name, TexMan.Type_Any);
		if (!g.IsValid() || a <= 0) return;
		double cx = mx + mw * 0.5, cy = my + mh * 0.5;
		mw *= sc; mh *= sc;
		Screen.DrawTexture(g, false, BX(cx - mw * 0.5), BY(cy - mh * 0.5), DTA_DestWidthF, mw * bbSx, DTA_DestHeightF, mh * bbSy,
			DTA_Color, c, DTA_Alpha, a * bbA);
	}

	// the LED clock at mockup x, y, w, h: SS:hh, red seven-segment (RSQ SlowMo's DOWN readout's digits)
	ui void BBClock(TextureID wh, double mx, double my, double mw, double mh, double secs, bool blink, double a)
	{
		BBBox(wh, mx, my, mw, mh, Color(255, 0x5A, 0x14, 0x10), a);
		BBBox(wh, mx + 2, my + 2, mw - 4, mh - 4, Color(255, 0x1A, 0x06, 0x06), a);
		secs = clamp(secs, 0.0, 99.99);
		int ss = int(secs), hh = int((secs - ss) * 100);
		static const int MASK[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };   // a b c d e f g
		static const double DX[] = { -3.65, -1.35, 1.35, 3.65 };
		double dw = 1.9, dh = 3.6, th = 0.38;
		double up = (mh * 0.62) / dh;
		double cx = mx + mw * 0.5, cy = my + mh * 0.5;
		Color lit = Color(255, 0xFF, 0x3B, 0x30);
		for (int di = 0; di < 4; di++)
		{
			int dq = di == 0 ? ss / 10 : (di == 1 ? ss % 10 : (di == 2 ? hh / 10 : hh % 10));
			for (int s7 = 0; s7 < 7; s7++)
			{
				double sx = DX[di], sy = 0, sw = th, sh = th;
				switch (s7)
				{
				case 0: sy = dh * 0.5; sw = dw; break;
				case 1: sx = DX[di] + dw * 0.5; sy = dh * 0.25; sh = dh * 0.5; break;
				case 2: sx = DX[di] + dw * 0.5; sy = -dh * 0.25; sh = dh * 0.5; break;
				case 3: sy = -dh * 0.5; sw = dw; break;
				case 4: sx = DX[di] - dw * 0.5; sy = -dh * 0.25; sh = dh * 0.5; break;
				case 5: sx = DX[di] - dw * 0.5; sy = dh * 0.25; sh = dh * 0.5; break;
				case 6: sw = dw; break;
				}
				bool on = (MASK[dq] & (1 << s7)) != 0;
				BBBox(wh, cx + (sx - sw * 0.5) * up, cy - (sy + sh * 0.5) * up, sw * up, sh * up, lit, a * (on ? 1.0 : 0.12));
			}
		}
		for (int q = 0; q < 2; q++)
			BBBox(wh, cx - 0.22 * up, cy + (q != 0 ? 0.85 : -0.85) * up - 0.22 * up, 0.45 * up, 0.45 * up, lit, a * (blink ? 1.0 : 0.12));
	}

	// a Champion power's icon for this monster (graphics/RSQMBC00..16), -1 none
	static clearscope int ChampIconOf(Actor a)
	{
		if (!a) return -1;
		static const String COL[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo",
			"Violet", "Pink", "Black", "Grey", "White", "Bronze", "Silver", "Gold" };
		for (int i = 0; i < 17; i++) { class<Inventory> c = "champion_" .. COL[i] .. "Token"; if (c && a.FindInventory(c)) return i; }
		return -1;
	}

	// a Champion colour (graphics/RSQMBC00..16's order) as a HUD colour
	static ui Color ChampColour(int i)
	{
		static const int RGB[] = { 0xB01818, 0xFF3030, 0xFF9020, 0xFFE030, 0x1E9E3A, 0x40F040, 0x40E8E8, 0x3868FF, 0x6A50D8,
			0xB040E0, 0xFF80B0, 0x505058, 0x9A9AA4, 0xF2F2F2, 0xC08A50, 0xD8DEE6, 0xFFC820 };
		return RGBc(i >= 0 && i < RGB.Size() ? RGB[i] : 0xC8C8C8);
	}

	static clearscope int ChampRGB(int i)
	{
		static const int RGB[] = { 0xB01818, 0xFF3030, 0xFF9020, 0xFFE030, 0x1E9E3A, 0x40F040, 0x40E8E8, 0x3868FF, 0x6A50D8,
			0xB040E0, 0xFF80B0, 0x505058, 0x9A9AA4, 0xF2F2F2, 0xC08A50, 0xD8DEE6, 0xFFC820 };
		return (i >= 0 && i < RGB.Size()) ? RGB[i] : 0xC8C8C8;
	}

	// the console player is DOWN (RSQ SlowMo, by name): Be Quick or Be Dead has the spot
	static ui bool BBDown()
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service s;
		while (s = it.Next()) return s.GetIntUI("down", "", consoleplayer, 0, null) > 0;
		return false;
	}

	ui void DrawBossBar(RenderEvent e)
	{
		TextureID wh = TexMan.CheckForTexture("RSQMBWH", TexMan.Type_Any);
		let hd = HD();
		if (!wh.IsValid() || !hd) return;
		if (BBDown()) return;
		double t = level.maptime + e.FracTic;
		int now = level.maptime;
		bool photo = RSQMB_A11y.Photo();
		RSQMB_Boss b = null;
		if (hd.arrPhase == 0) b = StackBoss(hd);
		bool landing = hd.arrPhase != 0;

		if (!bbWas || t < bbStart)
		{
			bbWas = true;
			bbStart = landing ? t : t - BB_GROW;   // a fight already under way (a save, a classic pick): no grow
			bbLag = 0; bbIcTic = 0; bbMbT = 0;
			for (int i = 0; i < 8; i++) { bbThrT[i] = 0; bbThrMax[i] = 0; bbThrIc[i] = -1; }
		}
		double dt = clamp(t - bbLast, 0.0, 3.0);
		bbLast = t;
		BBMap();
		bbA = 0.97;

		// ---- the bar: a sliver growing outward ----
		double g = clamp((t - bbStart) / BB_GROW, 0.0, 1.0);
		g = 0.02 + 0.98 * (1.0 - (1.0 - g) * (1.0 - g) * (1.0 - g));

		Actor mb = b ? b.mb : (hd.arrMon.Size() ? hd.arrMon[0] : null);
		bool mbIn = b != null || (hd.arrState.Size() && hd.arrState[0] == 2);
		if (mbIn && bbMbT <= 0) bbMbT = landing ? t : t - BB_ARRIVE;
		Color col = b ? b.col : (hd.arrCol.Size() ? RGBc(hd.arrCol[0]) : Color(255, 0xFF, 0x46, 0x32));
		Color lite = Mix(col, Color(255, 255, 255, 255), 0.5), deep = Mix(col, Color(255, 0, 0, 0), 0.25);
		Color g1 = Color(255, 0xB9, 0xBD, 0xC8), g2 = Color(255, 0x8A, 0x8F, 0x9C), g3 = Color(255, 0x6A, 0x6E, 0x7A);

		double frac = 0, flash = 0, clock = -1;
		bool guard = false;
		if (b)
		{
			double hp = b.mb ? clamp(b.mb.health / double(max(1, b.maxHP)), 0.0, 1.0) : 0.0;
			double left = b.chargeUntil - t;
			if (b.chargeUntil > 0 && left > 0)
			{
				frac = clamp(1.0 - left / BB_CHARGE, 0.0, 1.0);   // charging: grey, filling smoothly, the clock counting down
				clock = left / TICRATE;
				guard = true;
				bbLag = 0;
			}
			else
			{
				frac = hp;
				if (b.chargeUntil > 0 && !photo) flash = clamp(1.0 - (t - b.chargeUntil) / BB_FLASH, 0.0, 1.0) * 0.9;
				int since = now - b.lifeLostAt;
				if (b.lifeLostAt > 0 && since < REFILL)
				{
					double k = (since + e.FracTic) / REFILL;   // a life lost: the next bar rises, white into its colour
					frac = min(frac, k);
					col = Mix(Color(255, 255, 255, 255), b.col, k);
					lite = Mix(col, Color(255, 255, 255, 255), 0.5); deep = Mix(col, Color(255, 0, 0, 0), 0.25);
					bbLag = 0;
				}
				guard = b.ShieldUp() || b.Invulnerable();
				if (bbLag < frac) bbLag = frac;
				else bbLag = max(frac, bbLag - dt * 0.012);
			}
		}
		// LIVE, IT CYCLES (owner 18:26: the vertical rainbow boss bar in SOTN's Richter fight, "in shades of the MB color"):
		// the fill steps through shades of the miniboss's colour every few tics, as SOTN's steps through its colours, in the
		// glass-tube look. Photosensitive Mode: it drifts slowly between them instead of stepping.
		if (!guard)
		{
			static const double SHL[] = { 0.0, 0.34, -0.30, 0.16, -0.46, 0.48 };   // + toward white, - toward black
			double step = t / TB_STEP;
			double sh;
			if (photo) sh = 0.25 * sin(t * 4.0);
			else sh = SHL[int(step) % SHL.Size()];
			col = sh >= 0 ? Mix(col, Color(255, 255, 255, 255), sh) : Mix(col, Color(255, 0, 0, 0), -sh);
		}
		if (guard) BBBar(wh, 186, 90, 540, 30, 4, frac, g1, g2, g3, bbLag, flash, g, 1.0, true);
		else       BBBar(wh, 186, 90, 540, 30, 4, frac, lite, col, deep, bbLag, flash, g, 1.0, true);

		// ---- GUARD, silver, over the bar's right end; it SHAKES when a blow on the guarded miniboss is shrugged off (owner
		// 15:56: "the word GUARD in the healthbar shakes and vibrates when the guarded miniboss is hit ... to help give
		// feedback"): GUARD_SHAKE tics of a fast jitter that dies away, brighter while it lasts (Photosensitive Mode: brighter,
		// no jitter) ----
		if (guard && g >= 0.999)
		{
			double jx = 0, jy = 0, lit = 0;
			int since = b ? now - b.guardHitTic : 999;
			if (b && b.guardHitTic > 0 && since < GUARD_SHAKE)
			{
				double k = 1.0 - (since + e.FracTic) / GUARD_SHAKE;
				lit = k;
				if (!photo) { jx = sin(t * 97.0) * 5.0 * k + sin(t * 151.0) * 2.0 * k; jy = cos(t * 113.0) * 2.5 * k; }
			}
			BBWord("GUARD", "MBFS", 706 + jx, 94 + jy, 22, 1.0, true);
			if (lit > 0.01) BBWord("GUARD", "MBFG", 706 + jx, 94 + jy, 22, lit * 0.8, true);
		}

		// ---- its head, its name, X2 and the clock: they come in with it ----
		if (mbIn && mb)
		{
			double ar = clamp((t - bbMbT) / BB_ARRIVE, 0.0, 1.0);
			BBTex("RSQMBHD", 14, 36, 150, 150, ar, 1.5 - 0.5 * ar);
			String nm = mb.Species != 'None' ? String.Format("%s", mb.Species) : mb.GetTag();
			nm = nm.MakeUpper() .. " WARLORD";
			double nh = 32;
			double nw = BBWord(nm, "MBFG", 0, 0, nh, 1.0, false, true);
			if (nw > 530) nh *= 530 / nw;
			BBWord(nm, "MBFG", 190, 44 + (32 - nh), nh, ar);
			int lives = b ? b.lives : (clamp(CI('rsqmb_lives', 3), 1, 9) + hd.LifeBonusPreview());
			if (lives > 1) BBWord(String.Format("X%d", lives), "MBFG", 744, 90, 30, ar);
			if (clock >= 0) BBClock(wh, 826, 86, 96, 38, clock, photo || ((now / 17) & 1) == 0, ar);
		}

		// ---- the thralls: a small bar each, its crosshair and its power icon over it ----
		int n = landing ? max(0, hd.arrState.Size() - 1) : (b ? b.thr.Size() : 0);
		if (n > 5) n = 5;
		if (n <= 0) return;
		bool fresh = bbIcTic == 0 || (now != bbIcTic && now % 10 == 0);
		if (fresh) bbIcTic = now;
		static const int XH[] = { 3, 7, 5, 4, 6 };
		double tot = n * 150 + (n - 1) * 40;
		double x0 = 456 - tot * 0.5;
		for (int i = 0; i < n; i++)
		{
			Actor a = null;
			bool shown = false;
			Color tc = col;
			if (landing)
			{
				if (i + 1 < hd.arrMon.Size()) a = hd.arrMon[i + 1];
				shown = i + 1 < hd.arrState.Size() && hd.arrState[i + 1] == 2;
				if (i + 1 < hd.arrCol.Size()) tc = RGBc(hd.arrCol[i + 1]);
			}
			else
			{
				a = i < b.thr.Size() ? b.thr[i] : null;
				shown = true;
				for (int k = 1; k < hd.arrMon.Size() && k < hd.arrCol.Size(); k++) if (a && hd.arrMon[k] == a) { tc = RGBc(hd.arrCol[k]); break; }
			}
			if (!shown) continue;
			if (bbThrT[i] <= 0) bbThrT[i] = landing ? t : t - BB_POP - BB_TFILL;
			double pop = clamp((t - bbThrT[i]) / BB_POP, 0.0, 1.0);
			double fillIn = clamp((t - bbThrT[i] - BB_POP) / BB_TFILL, 0.0, 1.0);
			bool alive = a && a.health > 0;
			if (alive && a.health > bbThrMax[i]) bbThrMax[i] = a.health;
			double hf = alive ? a.health / max(1.0, bbThrMax[i]) : 0.0;
			// every tic until it has one (Champions turns a legendary thrall into a Champion a few tics after it lands), then
			// twice a second
			if (a && (fresh || bbThrIc[i] < 0)) bbThrIc[i] = ChampIconOf(a);
			// IN ITS OWN COLOUR (owner 15:56: "those bars will be the color of the boosted legendary champion thrall"): its
			// Champion colour, else the colour it landed in
			if (bbThrIc[i] >= 0) tc = ChampColour(bbThrIc[i]);
			double tx = x0 + i * 190;
			BBBar(wh, tx, 238, 150, 16, 3, hf * fillIn, Mix(tc, Color(255, 255, 255, 255), 0.4), tc, Mix(tc, Color(255, 0, 0, 0), 0.25), 0, 0, 1.0, pop);
			// the pair, side by side and centred over its bar (the mockup: crosshair 52, the icon 48, 112 in all)
			double ia = (alive ? 1.0 : 0.3) * pop, ps = 0.2 + 0.8 * pop;
			bool two = bbThrIc[i] >= 0;
			double px = tx + 75 - (two ? 56 : 26);
			BBTex(String.Format("RSQMBX%02d", XH[i]), px, 176, 52, 52, ia, ps, tc);
			if (two) BBTex(String.Format("RSQMBC%02d", bbThrIc[i]), px + 60, 178, 48, 48, ia, ps);
		}
	}
}
