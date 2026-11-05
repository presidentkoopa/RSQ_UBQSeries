// ============================================================================
// RSQ_Miniboss -- the BOSSFIGHT METER on the HUD (owner 2026-11-05: "under the SCORE word, above the SlowMo countdown
// bar, above the combos").
// WHERE: centred under RSQ Score's bar, asked by name (RS_ScoreService "hud.cx" / "hud.bar.bottom", screen pixels); without
// Score, where Score's defaults would put its bar (the same maths RSQ SlowMo's countdown uses). It answers
// RSQMB_Service "meter.bottom" (ui): RSQ SlowMo's countdown bar sits under that, and RSQ Score's combo rows below both.
// Each mod still places itself when the others are absent. Kept inside the series' safe area (rsq_ui_inset).
// SIZE: a third of the safe height x Meter Size x the series HUD Size (rsq_ui_hud_scale / 1.5), 9:112.
// LOOK: plain quads drawn as thick lines (no clip rectangle and no Screen.Dim: neither showed on the projected HUD in VR), filling ember to orange;
// full, it beats red-gold and reads BOSSFIGHT READY (or what it waits for, once due); while a Bossfight runs, the set
// piece's own colour and BOSSFIGHT!. Rig only, not headset-confirmed.
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

	// x, y, width, height in screen pixels
	static ui double, double, double, double MeterRect()
	{
		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(CF('rsq_ui_inset', 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double w = ah * 0.32 * clamp(UCv("rsqmb_bf_hud_size", 1.5), 0.5, 2.5) * clamp(CF('rsq_ui_hud_scale', 1.5), 0.4, 2.5) / 1.5;
		w = min(w, aw);
		double h = w * 9.0 / 112.0;
		double cx, below;
		[cx, below] = ScoreSpot();
		double x = clamp(cx - w * 0.5, sx, sx + aw - w);
		double y = clamp(below + h * 0.35, sy, sy + ah - h);
		return x, y, w, h;
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

	// RSQMB_Service "meter.bottom": the pixel row under the meter's slot, -1 when it is off
	static ui int MeterBottom()
	{
		if (gamestate != GS_LEVEL || !MeterShown()) return -1;
		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		return int(ceil(y + h));
	}

	// a filled rectangle as one thick line (no clip rectangle, no Dim: neither shows on the projected HUD in VR)
	static ui void Bar(int x, int y, int w, int h, Color c, double alpha)
	{
		if (w <= 0 || h <= 0) return;
		if (w >= h) Screen.DrawThickLine(x, y + h / 2, x + w, y + h / 2, h, c, int(clamp(alpha, 0.0, 1.0) * 255));
		else Screen.DrawThickLine(x + w / 2, y, x + w / 2, y + h, w, c, int(clamp(alpha, 0.0, 1.0) * 255));
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive || !MeterShown()) return;
		let m = RSQMB_Meter(players[consoleplayer].mo.FindInventory("RSQMB_Meter"));
		double t = level.maptime + e.FracTic;
		double dt = clamp(t - hudLastT, 0.0, 3.0);
		hudLastT = t;
		double fill = m ? clamp(m.fill / 1000.0, 0.0, 1.0) : 0.0;
		bool ready = m && m.ready;
		bool fight = arrPhase != 0 || (bfBoss && !bfBoss.done);
		if (fight) fill = 1.0;
		if (fill > hudShown) hudShown = min(fill, hudShown + dt / 20.0);
		else hudShown = fill;

		double x, y, w, h;
		[x, y, w, h] = MeterRect();
		int ix = int(x), iy = int(y), iw = int(w), ih = int(max(4, h));
		int bd = max(1, ih / 10);
		double pulse = 0.5 + 0.5 * sin(t * 8.0);
		Color edge = ready ? Color(255, 255, int(80 + 120 * pulse), 40) : Color(255, 150, 70, 40);
		Bar(ix, iy, iw, ih, Color(255, 0, 0, 0), 0.55);
		Bar(ix, iy, iw, bd, edge, 0.9);
		Bar(ix, iy + ih - bd, iw, bd, edge, 0.9);
		Bar(ix, iy, bd, ih, edge, 0.9);
		Bar(ix + iw - bd, iy, bd, ih, edge, 0.9);
		Color fc;
		if (fight)
		{
			int bi = bfBoss ? bfBoss.idx : bosses.Size();
			fc = PALETTE[bi % PALETTE.Size()];
		}
		else if (ready) fc = Color(255, 255, int(40 + 150 * pulse), int(20 + 30 * pulse));
		else fc = Color(255, int(150 + 105 * hudShown), int(50 + 60 * hudShown), 20);
		int fw = int((iw - 2 * bd) * hudShown);
		if (fw > 0) Bar(ix + bd, iy + bd, fw, ih - 2 * bd, fc, ready ? 0.75 + 0.2 * pulse : 0.8);

		String label = "BOSSFIGHT";
		if (fight) label = "BOSSFIGHT!";
		else if (ready) label = bfWhy != "" ? "BOSSFIGHT: " .. bfWhy : "BOSSFIGHT READY";
		Font fnt = NewSmallFont;
		double s = (h * 0.72) / max(1, fnt.GetHeight());
		double tw = fnt.StringWidth(label) * s;
		if (tw > w * 0.94) { s *= w * 0.94 / tw; tw = w * 0.94; }
		double vw = Screen.GetWidth() / s, vh = Screen.GetHeight() / s;
		double tx = (x + (w - tw) * 0.5) / s, ty = (y + (h - fnt.GetHeight() * s) * 0.5) / s;
		Screen.DrawText(fnt, ready || fight ? Font.CR_GOLD : Font.CR_WHITE, tx, ty, label,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, ready ? 0.75 + 0.25 * pulse : 0.9);
	}
}
