// ============================================================================
// RSQ_Miniboss -- THE MINIBOSS BAR on the HUD (owner 2026-11-12: mockup "E - Arrival" on the boss bar canvas, approved
// 15:07 "Yes, build it"). It takes the place of the fight's HUD stack (hud.zs DrawStack, kept but no longer called).
//
// WHAT IS ON IT (owner 05:56, 06:08, 14:11):
//   - the miniboss's head (its own sprite, the top of it) with a crosshair over it, left of the bar;
//   - its name over the bar, gold, in the series' score font (RSQ VisualRewards' glyphs by name; the engine's small font
//     without that pack);
//   - a smooth slanted bar: white rim, dark well, the fill in its colour, a dark red trail where health just went;
//   - "X2" at the bar's right end when it has more than one bar (its lives), with a slow shine;
//   - "GUARD" in grey over the right end of the bar, and the bar greyed, while it cannot be hurt;
//   - the LED clock right of that (RSQ SlowMo's DOWN readout, rebuilt here from boxes): seconds and hundredths until the
//     guard ends, shown while a countdown runs (the arrival's charge; a window after a thrall dies);
//   - under it one small slanted bar a thrall, and over each, side by side and centred, its crosshair icon (RSQ SlowMo's
//     art by name) and its Champion power icon.
// THE ARRIVAL (owner 14:11): the bar appears as a sliver and grows outward, empty; each thrall's bar pops in as it lands,
// one by one; then the miniboss comes in and its bar charges up over 3 seconds, smoothly, grey, with the clock counting
// 03:00 down; at 00:00 it flashes into its colour. While it charges the miniboss and its thralls take no damage and do
// not act (boss.zs ChargeStart / ChargeEnd).
// WHERE: where the stack was, under RSQ Score's bar (hud.zs MeterRect); RSQ SlowMo's rows and Score's combos sit under its
// bottom (StackRect, "meter.bottom").
// VR: boxes and textures cropped from the source only (no clip rectangle, no Screen.Dim): the slant is made of rows.
// PHOTOSENSITIVE MODE (RSQMB_A11y): no flash, no shine. Rig only, not headset-confirmed.
// ============================================================================

extend class RSQMB_Handler
{
	const BB_CHARGE = 105;      // the arrival's charge: 3 seconds (owner 14:11: "the miniboss bar takes 3 seconds to charge up")
	const BB_GROW = 12.0;       // tics the bar takes to grow outward from a sliver
	const BB_POP = 6.0;         // tics a thrall's bar and icons take to pop in
	const BB_SLANT = 0.49;      // the lean: tan 26 degrees (the mockup's skew)
	const BB_K = 1.5;           // the bar's thickness, x the meter bar's

	ui bool   bbWas;            // shown last frame
	ui double bbStart;          // when it appeared
	ui double bbLag;            // the trail's end, as a share of the bar
	ui double bbLast;
	ui double bbThrT[8];        // when each thrall's bar appeared (0: not yet)
	ui double bbThrMax[8];      // the most health each was seen with
	ui int    bbThrIc[8];       // its Champion icon, -1 none
	ui int    bbIcTic;

	// the bar's rect (x, y, w, h) and the whole block's bottom
	static ui double, double, double, double, double BossBarRect()
	{
		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		double bh = h * BB_K;
		double barY = y + bh * 1.15;
		let hd = HD();
		int n = 0;
		if (hd)
		{
			if (hd.arrPhase != 0) n = max(0, hd.arrState.Size() - 1);
			else { let b = StackBoss(hd); if (b) n = b.thr.Size(); }
		}
		double bot = barY + bh;
		if (n > 0) bot = barY + bh * (1.45 + 1.25 + 0.2 + 0.5);
		return x, barY, w, bh, bot;
	}

	// a Champion power's icon for this monster (graphics/RSQMBC00..21), -1 none
	static clearscope int ChampIconOf(Actor a)
	{
		if (!a) return -1;
		static const String COL[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo",
			"Violet", "Pink", "Black", "Grey", "White", "Bronze", "Silver", "Gold" };
		for (int i = 0; i < 17; i++) { class<Inventory> c = "champion_" .. COL[i] .. "Token"; if (c && a.FindInventory(c)) return i; }
		return -1;
	}

	// a slanted bar made of rows: rim, well, a trail from frac to lag, the fill to frac
	static ui void BBSlant(TextureID wh, double x, double y, double w, double h, double frac, Color c, double lag, double alpha, double flash, int rows = 8)
	{
		if (w <= 0.5 || h <= 0.5 || alpha <= 0) return;
		double rh = h / rows, bd = rh;
		Color rim = Color(255, 0xE8, 0xEC, 0xF4), well = Color(255, 0x12, 0x0E, 0x1A), trail = Color(255, 0x7C, 0x14, 0x22);
		Color lite = Mix(c, Color(255, 255, 255, 255), 0.45), dark = Mix(c, Color(255, 0, 0, 0), 0.3);
		frac = clamp(frac, 0.0, 1.0);
		for (int r = 0; r < rows; r++)
		{
			double yy = y + r * rh;
			double off = (0.5 - (r + 0.5) / rows) * h * BB_SLANT;
			Box(wh, x + off, yy, w, rh + 0.6, rim, alpha);
			if (r == 0 || r == rows - 1) continue;
			double ix = x + off + bd, iw = w - 2 * bd;
			if (iw <= 0) continue;
			Box(wh, ix, yy, iw, rh + 0.6, well, alpha);
			if (lag > frac) Box(wh, ix + iw * frac, yy, iw * (min(lag, 1.0) - frac), rh + 0.6, trail, alpha);
			if (frac > 0.001)
			{
				double k = (r - 1) / max(1.0, rows - 3.0);
				Color fc = k < 0.45 ? Mix(lite, c, k / 0.45) : Mix(c, dark, (k - 0.45) / 0.55);
				Box(wh, ix, yy, iw * frac, rh + 0.6, fc, alpha);
			}
			if (flash > 0.01) Box(wh, ix, yy, iw, rh + 0.6, Color(255, 255, 255, 255), alpha * flash);
		}
	}

	// a word in the score font, two-tone (the top half lighter); returns its width. measure: nothing is drawn
	static ui double BBWord(String s, double x, double y, double hgt, Color c, double alpha, bool measure = false)
	{
		TextureID probe = TexMan.CheckForTexture("QVW065", TexMan.Type_Any);
		if (!probe.IsValid())
		{
			double k = hgt / max(1, smallfont.GetHeight());
			if (!measure)
				Screen.DrawText(smallfont, Font.CR_UNTRANSLATED, x, y, s, DTA_ScaleX, k, DTA_ScaleY, k, DTA_Color, c, DTA_Alpha, alpha);
			return smallfont.StringWidth(s) * k;
		}
		Color top = Mix(c, Color(255, 255, 255, 255), 0.55);
		double cx = x;
		for (int i = 0; i < s.Length(); i++)
		{
			int ch = s.ByteAt(i);
			if (ch >= 97 && ch <= 122) ch -= 32;
			TextureID g;
			g.SetInvalid();
			if (ch > 32 && ch <= 96) g = TexMan.CheckForTexture(String.Format("QVW%03d", ch), TexMan.Type_Any);
			if (!g.IsValid()) { cx += hgt * 0.45; continue; }
			Vector2 ts = TexMan.GetScaledSize(g);
			double gw = ts.x / max(1.0, ts.y) * hgt;
			if (!measure)
			{
				Screen.DrawTexture(g, false, cx, y, DTA_DestWidthF, gw, DTA_DestHeightF, hgt, DTA_Color, c, DTA_Alpha, alpha);
				Screen.DrawTexture(g, false, cx, y, DTA_DestWidthF, gw, DTA_DestHeightF, hgt * 0.5, DTA_SrcHeight, ts.y * 0.5,
					DTA_Color, top, DTA_Alpha, alpha);
			}
			cx += gw * 0.92;
		}
		return cx - x;
	}

	// the LED clock: SS:HH in seven-segment digits, red on a dark panel (RSQ SlowMo's DOWN readout, downhud.zs)
	static ui void BBClock(TextureID wh, double x, double y, double w, double h, double secs, bool blink)
	{
		Box(wh, x, y, w, h, Color(255, 0x5A, 0x14, 0x10), 0.95);
		double bd = max(1.0, h * 0.06);
		Box(wh, x + bd, y + bd, w - 2 * bd, h - 2 * bd, Color(255, 0x1A, 0x06, 0x06), 0.95);
		secs = clamp(secs, 0.0, 99.99);
		int ss = int(secs), hh = int((secs - ss) * 100);
		static const int MASK[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };   // a b c d e f g
		static const double DX[] = { -3.65, -1.35, 1.35, 3.65 };
		double dw = 1.9, dh = 3.6, th = 0.38;
		double up = (h * 0.66) / dh;
		double cx = x + w * 0.5, cy = y + h * 0.5;
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
				Box(wh, cx + (sx - sw * 0.5) * up, cy - (sy + sh * 0.5) * up, sw * up, sh * up, lit, on ? 1.0 : 0.12);
			}
		}
		for (int q = 0; q < 2; q++)
			Box(wh, cx - 0.22 * up, cy + (q != 0 ? 0.85 : -0.85) * up - 0.22 * up, 0.45 * up, 0.45 * up, lit, blink ? 1.0 : 0.12);
	}

	// a square icon by name, centred; false when the texture is not there
	static ui bool BBIcon(String name, double cx, double cy, double size, double alpha, Color c = 0xFFFFFFFF)
	{
		TextureID g = TexMan.CheckForTexture(name, TexMan.Type_Any);
		if (!g.IsValid()) return false;
		Screen.DrawTexture(g, false, cx - size * 0.5, cy - size * 0.5, DTA_DestWidthF, size, DTA_DestHeightF, size, DTA_Color, c, DTA_Alpha, alpha);
		return true;
	}

	ui void DrawBossBar(RenderEvent e)
	{
		TextureID wh = TexMan.CheckForTexture("RSQMBWH", TexMan.Type_Any);
		let hd = HD();
		if (!wh.IsValid() || !hd) return;
		double t = level.maptime + e.FracTic;
		int now = level.maptime;
		bool photo = RSQMB_A11y.Photo();
		double x, barY, w, bh, bot;
		[x, barY, w, bh, bot] = BossBarRect();
		RSQMB_Boss b = null;
		if (hd.arrPhase == 0) b = StackBoss(hd);
		bool landing = hd.arrPhase != 0;

		if (!bbWas || t < bbStart)
		{
			bbWas = true;
			bbStart = landing ? t : t - BB_GROW;   // a fight already under way (a save, a classic pick): no grow
			bbLag = 0;
			bbIcTic = 0;
			for (int i = 0; i < 8; i++) { bbThrT[i] = 0; bbThrMax[i] = 0; bbThrIc[i] = -1; }
		}
		double dt = clamp(t - bbLast, 0.0, 3.0);
		bbLast = t;

		// ---- the bar: a sliver growing outward ----
		double g = clamp((t - bbStart) / BB_GROW, 0.0, 1.0);
		g = 1.0 - (1.0 - g) * (1.0 - g);
		double bw = max(w * 0.02, w * g);
		double bx = x + (w - bw) * 0.5;

		Actor mb = b ? b.mb : (hd.arrMon.Size() ? hd.arrMon[0] : null);
		bool mbIn = b != null || (hd.arrState.Size() && hd.arrState[0] == 2);
		Color col = b ? b.col : (hd.arrCol.Size() ? RGBc(hd.arrCol[0]) : Color(255, 255, 70, 50));
		Color grey = Color(255, 0x8A, 0x8F, 0x9C);

		double frac = 0, flash = 0, clock = -1;
		bool guard = false;
		if (b)
		{
			double hp = b.mb ? clamp(b.mb.health / double(max(1, b.maxHP)), 0.0, 1.0) : 0.0;
			double left = b.chargeUntil - t;
			if (b.chargeUntil > 0 && left > 0)
			{
				// charging: grey, filling smoothly, the clock counting down
				frac = clamp(1.0 - left / BB_CHARGE, 0.0, 1.0);
				clock = left / TICRATE;
				guard = true;
				bbLag = 0;
			}
			else
			{
				frac = hp;
				if (b.chargeUntil > 0 && !photo) flash = clamp(1.0 - (t - b.chargeUntil) / 6.0, 0.0, 1.0) * 0.9;
				int since = now - b.lifeLostAt;
				if (b.lifeLostAt > 0 && since < REFILL)
				{
					double k = (since + e.FracTic) / REFILL;   // a life lost: the next bar rises, white into its colour
					frac = min(frac, k);
					col = Mix(Color(255, 255, 255, 255), b.col, k);
					bbLag = 0;
				}
				guard = b.ShieldUp() || b.Invulnerable();
				if (b.winSeg >= 0) clock = max(0.0, (b.winEnd - t) / TICRATE);   // a window: how long it stays open
				if (bbLag < frac) bbLag = frac;
				else bbLag = max(frac, bbLag - dt * 0.012);
			}
		}
		BBSlant(wh, bx, barY, bw, bh, frac, guard ? grey : col, guard ? 0.0 : bbLag, 0.97, flash);

		// ---- GUARD, grey, over the bar's right end ----
		if (guard && g >= 1.0)
		{
			double gh = bh * 0.62;
			double gwid = BBWord("GUARD", 0, 0, gh, grey, 1.0, true);
			BBWord("GUARD", x + w - gwid - bh * 0.7, barY + (bh - gh) * 0.5, gh, Color(255, 0xC8, 0xCC, 0xD6), 0.95);
		}

		// ---- its head, its name, X and its bars ----
		if (mbIn && mb)
		{
			double hs = bh * 2.15;                      // from the name's top to the bar's bottom
			double hx = x - hs - bh * 0.55, hy = barY + bh - hs;
			double bd = max(1.0, bh * 0.08);
			Box(wh, hx - bd, hy - bd, hs + 2 * bd, hs + 2 * bd, Color(255, 0xE8, 0xEC, 0xF4), 0.95);
			Box(wh, hx, hy, hs, hs, Color(255, 0x12, 0x0E, 0x1A), 0.95);
			State st = mb.SpawnState;
			if (st)
			{
				TextureID sp; bool flip; Vector2 sc;
				[sp, flip, sc] = st.GetSpriteTexture(0);
				if (sp.IsValid())
				{
					Vector2 ts = TexMan.GetScaledSize(sp);
					double srcH = min(ts.y, ts.x * 0.8);   // the top of the sprite: its head and shoulders
					double srcW = min(ts.x, srcH);
					double dw = hs, dh = hs * srcH / max(1.0, srcW);
					if (dh > hs) { dw *= hs / dh; dh = hs; }
					Screen.DrawTexture(sp, false, hx + (hs - dw) * 0.5, hy + hs - dh, DTA_DestWidthF, dw, DTA_DestHeightF, dh,
						DTA_SrcX, (ts.x - srcW) * 0.5, DTA_SrcWidth, srcW, DTA_SrcY, 0.0, DTA_SrcHeight, srcH,
						DTA_TranslationIndex, mb.Translation, DTA_FlipX, flip, DTA_TopOffset, 0, DTA_LeftOffset, 0);
				}
			}
			if (!BBIcon("RSPA0116", hx + hs * 0.5, hy + hs * 0.5, hs * 1.2, 0.95, Color(255, 255, 210, 70)))
				BBIcon("RSQMBSK1", hx + hs * 0.85, hy + hs * 0.15, hs * 0.5, 0.95);

			String nm = mb.Species != 'None' ? String.Format("%s", mb.Species) : mb.GetTag();
			nm = nm.MakeUpper() .. " WARLORD";
			BBWord(nm, x + bh * 0.2, barY - bh * 1.05, bh * 0.85, Color(255, 255, 200, 60), 0.97);

			int lives = b ? b.lives : (clamp(CI('rsqmb_lives', 3), 1, 9) + hd.LifeBonusPreview());
			double rx = x + w + bh * 0.55;
			if (lives > 1)
			{
				double shine = photo ? 0.0 : 0.5 + 0.5 * sin(t * 6.0);
				Color xc = Mix(Color(255, 255, 200, 60), Color(255, 255, 255, 235), shine * 0.6);
				rx += BBWord(String.Format("X%d", lives), rx, barY, bh, xc, 0.97) + bh * 0.4;
			}
			if (clock >= 0) BBClock(wh, rx, barY - bh * 0.12, bh * 3.2, bh * 1.24, clock, photo || ((now / 17) & 1) == 0);
		}

		// ---- the thralls: a small bar each, its crosshair and its power icon over it ----
		int n = landing ? max(0, hd.arrState.Size() - 1) : (b ? b.thr.Size() : 0);
		if (n > 8) n = 8;
		if (n <= 0) return;
		bool fresh = bbIcTic == 0 || (now != bbIcTic && now % 10 == 0);
		if (fresh) bbIcTic = now;
		double gap = bh * 0.6;
		double tw = min(w * 0.3, (w - gap * (n - 1)) / n);
		double tot = tw * n + gap * (n - 1);
		double tx0 = x + (w - tot) * 0.5;
		double icY = barY + bh * 1.45, icH = bh * 1.25, tbY = icY + icH + bh * 0.2, tbH = bh * 0.5;
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
				a = b.thr[i];
				shown = true;
				for (int k = 1; k < hd.arrMon.Size() && k < hd.arrCol.Size(); k++) if (a && hd.arrMon[k] == a) { tc = RGBc(hd.arrCol[k]); break; }
			}
			if (!shown) continue;
			if (bbThrT[i] <= 0) bbThrT[i] = landing ? t : t - BB_POP * 3;
			double pop = clamp((t - bbThrT[i]) / BB_POP, 0.0, 1.0);
			double fillIn = clamp((t - bbThrT[i] - BB_POP) / 8.0, 0.0, 1.0);
			bool alive = a && a.health > 0;
			if (alive && a.health > bbThrMax[i]) bbThrMax[i] = a.health;
			double hf = alive ? a.health / max(1.0, bbThrMax[i]) : 0.0;
			if (fresh && a) bbThrIc[i] = ChampIconOf(a);
			double tx = tx0 + i * (tw + gap);
			BBSlant(wh, tx, tbY, tw, tbH, hf * fillIn, tc, 0.0, 0.97 * pop, 0.0, 6);
			// the pair, side by side and centred over its bar
			double isz = icH * (0.2 + 0.8 * pop);
			double ia = (alive ? 0.97 : 0.3) * pop;
			double cxm = tx + tw * 0.5, cym = icY + icH * 0.5;
			bool two = bbThrIc[i] >= 0;
			bool gotX = BBIcon(String.Format("RSPA%02d16", 2 + (i % 9)), two ? cxm - isz * 0.55 : cxm, cym, isz, ia, tc);
			if (two) BBIcon(String.Format("RSQMBC%02d", bbThrIc[i]), gotX ? cxm + isz * 0.55 : cxm, cym, isz * 0.9, ia);
		}
	}
}
