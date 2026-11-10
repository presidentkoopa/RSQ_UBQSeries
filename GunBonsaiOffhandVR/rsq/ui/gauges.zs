// THE BERSERK METER'S GAUGE (2026-11-02; GBOVR_TREES.md 4.1 F "a meter on the skin HUD"). The owner: repurpose coldcite's
// Top HP Bars bar as a vertical HUD element (TopHPBars/tools/gen_gauges.py: graphics/RSQGBGE the empty bar; his art,
// "feel free to use this in your mods"), the style RSQ SlowMo's gauge uses too. The fill is drawn live over it, tinted,
// from graphics/RSQGBGW (RSQUI_GaugeLife). (The baked full bar RSQGBGF was never drawn; removed 11-10.)
// One gauge per glove that has learned Berserk Meter, on that hand's side (the main hand right, the off hand left), set
// in from the edge so RSQ SlowMo's gauge at the very edge never covers it. It fills as that glove's fist damage does;
// while the Berserk it earned runs, it drains with the time left and pulses. Hidden under a Berserk pack (the meter does
// not fill then), and with the HUD (automap, screen size past 11). Rows: Berserk Meter Gauge (on), Gauge Animation (on).
// THE FILL IS ALIVE (owner, 11-02): tinted dark crimson to blood red to hot orange-white as it fills, an earned Berserk
// burning orange; with Gauge Animation a band of light rises through it, its edge breathes, a full one glints.
class RSQUI_Gauges : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL || !playeringame[consoleplayer] || !players[consoleplayer].mo) return;
		if (screenblocks > 11 || automapactive) return;
		let cv = CVar.GetCVar("rsqgb_berserk_gauge", players[consoleplayer]);
		if (cv && !cv.GetBool()) return;
		let stats = TFLV_EventHandler.GetConsolePlayerStats();
		if (!stats) return;
		let pmo = players[consoleplayer].mo;
		let earned = RSQ_EarnedStrength(pmo.FindInventory("RSQ_EarnedStrength"));
		bool pack = !earned && pmo.FindInventory("PowerStrength", true);
		if (pack) return;
		TextureID te = TexMan.CheckForTexture("RSQGBGE", TexMan.Type_Any);
		TextureID tw = TexMan.CheckForTexture("RSQGBGW", TexMan.Type_Any);
		if (!te.IsValid() || !tw.IsValid()) return;
		let av = CVar.GetCVar("rsqgb_gauge_anim", players[consoleplayer]);
		bool anim = !av || av.GetBool();
		double t = level.maptime + e.FracTic;

		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		let iv = CVar.FindCVar("rsq_ui_inset");
		double f = iv ? clamp(iv.GetFloat(), 0.0, 0.3) : 0.04;
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		let hs = CVar.FindCVar("rsq_ui_hud_scale");
		double h = ah * 0.32 * clamp(hs ? hs.GetFloat() : 1.5, 0.4, 2.5);
		double w = h * 11.0 / 112.0;
		double y = sy + (ah - h) * 0.5;

		for (int hand = 0; hand < 2; hand++)
		{
			let info = stats.GetInfoForHand(hand);
			if (!info || !info.upgrades) continue;
			RSQ_Upgrade_BerserkMeter bm = null;
			for (int i = 0; i < info.upgrades.upgrades.Size(); i++)
			{
				bm = RSQ_Upgrade_BerserkMeter(info.upgrades.upgrades[i]);
				if (bm) break;
			}
			if (!bm || !bm.enabled) continue;
			double frac, alpha = 1.0;
			if (earned)
			{
				frac = earned.total > 0 ? clamp(double(earned.left) / earned.total, 0.0, 1.0) : 0.0;
				alpha = 0.75 + 0.25 * sin(level.maptime * 20.0);
			}
			else frac = clamp(double(bm.meter) / RSQ_Upgrade_BerserkMeter.FULL, 0.0, 1.0);
			// each on its hand's side (the main hand's on the right for a right-hander, on the left for a left-hander:
			// RSQUI_Hand.OnLeft), 2.5 gauge widths in from the edge
			double x = RSQUI_Hand.OnLeft(hand) ? sx + w * 2.5 : sx + aw - w * 3.5;
			// dark crimson empty, blood red half way, hot orange-white full; an earned Berserk burns orange as it drains
			if (earned) RSQUI_GaugeLife.Draw(te, tw, x, y, w, h, frac, Color(255, 200, 60, 10), Color(255, 255, 120, 20), Color(255, 255, 220, 140), alpha, anim, t);
			else RSQUI_GaugeLife.Draw(te, tw, x, y, w, h, frac, Color(255, 110, 10, 10), Color(255, 230, 40, 40), Color(255, 255, 190, 120), alpha, anim, t);
		}
	}
}

// THE GAUGE'S LIFE (the owner, 2026-11-02: "they can have some life to them, some colors, maybe some light optional
// animation"). The fill is coldcite's blocks in white (gen_gauges.py's <NAME>W), tinted by the level: lo at empty, mid at
// half, hi at full, so the colour moves as it fills. With the animation on: a band of light rises through the fill every
// RISE tics, the fill's top edge breathes, and a full gauge glints. The same routine is in RSQ SlowMo (gauge.zs) and RSQ
// Gun Bonsai VR (rsq/ui/gauges.zs): two mods that must each work alone, so it is copied, not shared.
class RSQUI_GaugeLife ui
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
		// PHOTOSENSITIVE MODE (RSQ_Accessibility, by name: RSQGB_A11y; owner 11-05, as the Bossfight meter): no glint, the edge
		// held still, the band dimmer
		bool photo = RSQGB_A11y.Photo();
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
