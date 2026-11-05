// THE SLOWMO GAUGE (2026-11-02; the owner: "repurpose and recolor the TopHPBar as a hud element for SlowMo, arrange it
// vertically, change the colors or style"). coldcite's Top HP Bars bar, stood on end and coloured electric cyan
// (VisualRewards/tools/gen_gauges.py: graphics/RSQSMGE empty, RSQSMGF full, RSQSMGW the white fill; his art, "feel free to use this in your mods").
//   ADRENALINE ON   the gauge is the meter, 0 to 100: dim while it is below Adrenaline to Start (a white tick marks that
//                   line), pulsing while slow motion spends it.
//   ADRENALINE OFF  there is no meter: the gauge shows only while the world is slowed, filled by how slow (full is the
//                   World Speed slider's depth, Gun Bonsai VR's Deeper depth when learned, the shootdodge's in a dodge).
// THE FILL IS ALIVE (owner, 11-02): tinted deep blue to cyan to near white as it fills, and (Gauge Animation, on) a band of
// light rising through it, a breathing edge, a glint when full (RSQSM_GaugeLife below).
// Drawn on the HUD's layer, at the side of the safe area (the series' rsq_ui_inset when the series UI is loaded, else 4 %
// of each side: a headset's screen corners sit at the edge of view), half way down. Hidden with the HUD (automap,
// screen size past 11). Rows: SlowMo Gauge (on), Gauge Side, Gauge Size.
class RSQSM_Gauge : StaticEventHandler
{
	const TICK_ALPHA = 0.8;
	// (the fill and its light: RSQSM_GaugeLife below)

	static clearscope double UCv(String n, double d) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetFloat() : d; }
	static clearscope double SCv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive) return;
		if (UCv("rsqsm_gauge", 1) == 0) return;
		let clock = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		if (!clock) return;
		bool meter = SCv("rsqsm_adrenaline", 0) != 0;
		bool slowing = clock.scale < 0.98;
		double frac;
		if (meter) frac = clamp(clock.adr / 100.0, 0.0, 1.0);
		else
		{
			if (!slowing) return;
			// full is the deepest of his own slow motion now: the World Speed row, or Gun Bonsai VR's Deeper node when learned
			// (clock.curDepth, Depth()), and the shootdodge's speed while one is in flight (0.99a bug 2: against rsm_depth
			// alone the gauge sat full through both)
			double depth = clock.curDepth > 0 ? clock.curDepth : clamp(SCv("rsm_depth", 0.25), 0.05, 0.95);
			bool dodging = false;
			for (int n = 0; n < MAXPLAYERS; n++) if (clock.dodgeTic[n] > 0) dodging = true;
			if (dodging) depth = min(depth, clamp(SCv("rsqsm_dodge_depth", 0.10), 0.05, 0.95));
			frac = clamp((1.0 - clock.scale) / max(1.0 - depth, 0.05), 0.0, 1.0);
		}
		TextureID te = TexMan.CheckForTexture("RSQSMGE", TexMan.Type_Any);
		TextureID tw = TexMan.CheckForTexture("RSQSMGW", TexMan.Type_Any);
		if (!te.IsValid() || !tw.IsValid()) return;

		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(SCv("rsq_ui_inset", 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double h = ah * 0.32 * clamp(UCv("rsqsm_gauge_size", 1.5), 0.5, 2.5);
		double w = h * 11.0 / 112.0;
		double x = UCv("rsqsm_gauge_side", 0) >= 1 ? sx + aw - w : sx;
		double y = sy + (ah - h) * 0.5;

		double alpha = 1.0;
		double need = clamp(SCv("rsqsm_adr_min", 25), 0, 100) / 100.0;
		if (meter && frac < need) alpha = 0.5;
		if (meter && slowing) alpha *= 0.75 + 0.25 * sin(level.maptime * 20.0);
		// deep blue empty, electric cyan half way, near white full; below Adrenaline to Start it stays dim
		bool anim = UCv("rsqsm_gauge_anim", 1) != 0;
		RSQSM_GaugeLife.Draw(te, tw, x, y, w, h, frac, Color(255, 30, 60, 200), Color(255, 60, 220, 255), Color(255, 225, 250, 255),
			alpha, anim, level.maptime + e.FracTic);
		if (meter && need > 0.001)
		{
			int ty = int(y + h * (1.0 - need));
			Screen.DrawThickLine(int(x - w * 0.3), ty, int(x + w * 1.3), ty, max(1.0, h / 112.0), 0xFFFFFFFF, int(255 * TICK_ALPHA));
		}
	}
}

// THE GAUGE'S LIFE (the owner, 2026-11-02: "they can have some life to them, some colors, maybe some light optional
// animation"). The fill is coldcite's blocks in white (gen_gauges.py's <NAME>W), tinted by the level: lo at empty, mid at
// half, hi at full, so the colour moves as it fills. With the animation on: a band of light rises through the fill every
// RISE tics, the fill's top edge breathes, and a full gauge glints. The same routine is in RSQ SlowMo (gauge.zs) and RSQ
// Gun Bonsai VR (rsq/ui/gauges.zs): two mods that must each work alone, so it is copied, not shared.
class RSQSM_GaugeLife ui
{
	const RISE = 52.0;   // tics for the band to climb the fill (1.5 s)
	const SLICES = 8;    // the fill's colour steps up the gauge

	static Color Mix(Color a, Color b, double k)
	{
		k = clamp(k, 0.0, 1.0);
		return Color(255, int(a.r + (b.r - a.r) * k), int(a.g + (b.g - a.g) * k), int(a.b + (b.b - a.b) * k));
	}
	static Color ByLevel(Color lo, Color mid, Color hi, double f) { return f < 0.5 ? Mix(lo, mid, f * 2.0) : Mix(mid, hi, (f - 0.5) * 2.0); }

	// ONE ROW BAND OF THE GAUGE, screen rows a..b of the gauge drawn at x, y, w, h (2026-11-03, the owner: "the slowmo and
	// berserk bars do not fill in vr"). The band is cropped from the SOURCE (DTA_SrcY / DTA_SrcHeight) and drawn as its own
	// quad, never clipped with DTA_ClipTop / DTA_ClipBottom: QuestZDoom turns those into a GL scissor box in flat window
	// pixels (v_2ddrawer.cpp:507-512, hw_draw2d.cpp:141-153), but in VR the HUD's quads go through the HUD projection
	// (vr_hud_scale, vr_hud_distance: OpenVREyePose::AdjustHud / getHUDProjection), so the box no longer lies over the
	// gauge and cut the whole fill away. A quad carries no scissor and lands where the empty gauge lands. Rows and texels
	// map exactly as the clipped full texture did, so the flat look is the same pixel for pixel.
	static void Slab(TextureID tw, double x, double y, double w, double h, double a, double b, Color c, double alpha, bool add)
	{
		a = max(a, y);
		b = min(b, y + h);
		if (b <= a) return;
		Vector2 ts = TexMan.GetScaledSize(tw);
		double sy = (a - y) / h * ts.y, sh = (b - a) / h * ts.y;
		if (add)
			Screen.DrawTexture(tw, false, x, a, DTA_DestWidthF, w, DTA_DestHeightF, b - a, DTA_SrcY, sy, DTA_SrcHeight, sh,
				DTA_Color, c, DTA_Alpha, alpha, DTA_LegacyRenderStyle, STYLE_Add);
		else
			Screen.DrawTexture(tw, false, x, a, DTA_DestWidthF, w, DTA_DestHeightF, b - a, DTA_SrcY, sy, DTA_SrcHeight, sh,
				DTA_Color, c, DTA_Alpha, alpha);
	}

	static void Draw(TextureID te, TextureID tw, double x, double y, double w, double h, double frac, Color lo, Color mid, Color hi, double alpha, bool anim, double t)
	{
		Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9);
		if (frac <= 0.001) return;
		double top = y + h * (1.0 - frac);
		// the fill in SLICES slices up the gauge, each tinted by its own height: the low colour at the bottom climbing to the
		// level's colour at the top of the fill, so a fuller gauge shows more of the range
		for (int i = 0; i < SLICES; i++)
		{
			double sliceBot = y + h * (1.0 - double(i) / SLICES), sliceTop = y + h * (1.0 - double(i + 1) / SLICES);
			if (sliceBot <= top) break;
			double mid01 = (i + 0.5) / SLICES;
			Slab(tw, x, y, w, h, int(max(top, sliceTop)), int(ceil(sliceBot)), ByLevel(lo, mid, hi, min(mid01, frac)), alpha, false);
		}
		if (!anim) return;
		// PHOTOSENSITIVE MODE (RSQ_Accessibility, by name: RSQSM_A11y; owner 11-05, as the Bossfight meter): no glint, the edge
		// held still, the band dimmer
		bool photo = RSQSM_A11y.Photo();
		// the band: an eighth of the gauge tall, from the bottom up to the fill's top, light added on top of the fill
		double ph = (t % RISE) / RISE;
		double bh = h * 0.125;
		double fillH = h * frac;
		double bBot = y + h - (fillH + bh) * ph + bh;
		double bTop = bBot - bh;
		if (bBot > top)
			Slab(tw, x, y, w, h, int(max(top, bTop)), int(min(y + h, bBot)), hi, (photo ? 0.25 : 0.45) * alpha, true);
		// the edge: a bright line where the fill stops, breathing (DrawThickLine sets no scissor, v_2ddrawer.cpp AddThickLine:
		// it shows in VR, seen in the rig's eye frame on 11-03)
		double glow = photo ? 0.8 : 0.55 + 0.45 * sin(t * 12.0);
		Screen.DrawThickLine(int(x), int(top), int(x + w), int(top), max(1.0, h / 90.0), hi, int(255 * glow * alpha));
		// full: the whole gauge glints, a short flash every couple of seconds
		if (frac >= 0.999 && !photo)
		{
			double g = sin(t * 5.0);
			if (g > 0.8)
				Screen.DrawTexture(tw, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Color, hi, DTA_Alpha, (g - 0.8) * 2.5 * alpha,
					DTA_LegacyRenderStyle, STYLE_Add);
		}
	}
}
