// THE BERSERK METER'S GAUGE (2026-11-02; GBOVR_TREES.md 4.1 F "a meter on the skin HUD"). The owner: repurpose coldcite's
// Top HP Bars bar as a vertical HUD element (TopHPBars/tools/gen_gauges.py: graphics/RSQGBGE empty, RSQGBGF full, blood
// red; his art, "feel free to use this in your mods"), the style RSQ SlowMo's gauge uses too.
// One gauge per glove that has learned Berserk Meter, on that hand's side (the main hand right, the off hand left), set
// in from the edge so RSQ SlowMo's gauge at the very edge never covers it. It fills as that glove's fist damage does;
// while the Berserk it earned runs, it drains with the time left and pulses. Hidden under a Berserk pack (the meter does
// not fill then), and with the HUD (automap, screen size past 11). Rows: Berserk Meter Gauge (on).
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
		TextureID tf = TexMan.CheckForTexture("RSQGBGF", TexMan.Type_Any);
		if (!te.IsValid() || !tf.IsValid()) return;

		double sw = Screen.GetWidth(), sh = Screen.GetHeight();
		let iv = CVar.FindCVar("rsq_ui_inset");
		double f = iv ? clamp(iv.GetFloat(), 0.0, 0.3) : 0.04;
		double sx = sw * f, sy = sh * f, aw = sw * (1 - 2 * f), ah = sh * (1 - 2 * f);
		let hs = CVar.FindCVar("rsq_ui_hud_scale");
		double h = ah * 0.32 * clamp(hs ? hs.GetFloat() : 1.0, 0.4, 2.5);
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
			// the main hand's on the right, the off hand's on the left, each 2.5 gauge widths in from the edge
			double x = hand == 0 ? sx + aw - w * 3.5 : sx + w * 2.5;
			Screen.DrawTexture(te, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, 0.9);
			if (frac > 0.001)
				Screen.DrawTexture(tf, false, x, y, DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_Alpha, alpha, DTA_ClipTop, int(y + h * (1.0 - frac)));
		}
	}
}
