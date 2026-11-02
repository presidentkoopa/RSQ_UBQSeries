// THE SLOWMO GAUGE (2026-11-02; the owner: "repurpose and recolor the TopHPBar as a hud element for SlowMo, arrange it
// vertically, change the colors or style"). coldcite's Top HP Bars bar, stood on end and coloured electric cyan
// (TopHPBars/tools/gen_gauges.py: graphics/RSQSMGE empty, RSQSMGF full; his art, "feel free to use this in your mods").
//   ADRENALINE ON   the gauge is the meter, 0 to 100: dim while it is below Adrenaline to Start (a white tick marks that
//                   line), pulsing while slow motion spends it.
//   ADRENALINE OFF  there is no meter: the gauge shows only while the world is slowed, filled by how slow (the depth
//                   the World Speed slider sets is full).
// Drawn on the HUD's layer, at the side of the safe area (the series' rsq_ui_inset when the series UI is loaded, else 4 %
// of each side: a headset's screen corners sit at the edge of view), half way down. Hidden with the HUD (automap,
// screen size past 11). Rows: SlowMo Gauge (on), Gauge Side, Gauge Size.
class RSQSM_Gauge : StaticEventHandler
{
	const TICK_ALPHA = 0.8;

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
			double depth = clamp(SCv("rsm_depth", 0.25), 0.05, 0.95);
			frac = clamp((1.0 - clock.scale) / max(1.0 - depth, 0.05), 0.0, 1.0);
		}
		TextureID te = TexMan.CheckForTexture("RSQSMGE", TexMan.Type_Any);
		TextureID tf = TexMan.CheckForTexture("RSQSMGF", TexMan.Type_Any);
		if (!te.IsValid() || !tf.IsValid()) return;

		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		double f = clamp(SCv("rsq_ui_inset", 0.04), 0.0, 0.3);
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		double h = ah * 0.32 * clamp(UCv("rsqsm_gauge_size", 1.0), 0.5, 2.5);
		double w = h * 11.0 / 112.0;
		double x = UCv("rsqsm_gauge_side", 0) >= 1 ? sx + aw - w : sx;
		double y = sy + (ah - h) * 0.5;

		double alpha = 1.0;
		double need = clamp(SCv("rsqsm_adr_min", 25), 0, 100) / 100.0;
		if (meter && frac < need) alpha = 0.5;
		if (meter && slowing) alpha *= 0.75 + 0.25 * sin(level.maptime * 20.0);
		Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9);
		if (frac > 0.001)
			Screen.DrawTexture(tf, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, alpha, DTA_ClipTop, int(y + h * (1.0 - frac)));
		if (meter && need > 0.001)
		{
			int ty = int(y + h * (1.0 - need));
			Screen.DrawThickLine(int(x - w * 0.3), ty, int(x + w * 1.3), ty, max(1.0, h / 112.0), 0xFFFFFFFF, int(255 * TICK_ALPHA));
		}
	}
}
