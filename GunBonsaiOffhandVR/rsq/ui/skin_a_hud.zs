// SKIN A, IN PLAY (10-27): the recreation of the owner's mockups. In play it draws one thing: the bottom row (an
// ammo counter per hand, health, face and armour; Ammo and Health Row, RSQUI_Dispatch.BottomOn). Gun Bonsai's XP
// gauges (ca.ancilla.bonsai/HUD.zsc) and RS Score's line draw themselves. Every number below is measured off the
// mockups cropped to 960x540 (the game window of ab98b8f7/c349c19f, 962x529 px, resized). (The Mockup's own drawn
// gauges and score line, never called since the owner's 10-27 "untouched", were removed 11-10.)
class RSQUI_A_Skin : RSQUI_Skin
{
	RSQUI_Pen pen;
	RSQUI_Data data;

	override Name StatusMenu() { return 'RSQUI_A_StatusMenu'; }
	override Name WeaponLevelUpMenu() { return 'RSQUI_A_WeaponLevelUp'; }
	override Name PlayerLevelUpMenu() { return 'RSQUI_A_PlayerLevelUp'; }

	void Prepare()
	{
		if (!pen) pen = RSQUI_Pen.Make();
		if (!data) data = RSQUI_Data.Make();
	}

	override bool DrawHud(RenderEvent e)
	{
		Prepare();
		data.Read();
		pen.HudFrame();
		double W = pen.UnitsWide(), H = pen.UnitsHigh();
		// Gun Bonsai's XP gauges and RS Score's line draw themselves, untouched (owner, 10-27).
		if (RSQUI_Dispatch.BottomOn()) DrawBottom(W, H);
		return true;
	}

	// ---- the bottom: one ammo counter per hand, the face between health and armour ------------
	// Mockup: digits 16 units tall with their top 78 above the bottom, the ammo icon under the
	// reserve (488..520); health and armour digits 24 tall, the row 506..535.
	void DrawBottom(double W, double H)
	{
		Font big = Font.GetFont("HUDFONT_DOOM");
		if (!big) big = BigFont;
		// each hand's counter on that hand's side (RSQUI_Hand.OnLeft: the off hand left for a right-hander, the main hand
		// left for a left-hander); the magazine's colour is the hand's (off gold, main orange)
		for (int s = 0; s <= 1; s++)
		{
			let hd = data.hands[s];
			if (!hd.wpn || hd.reserve < 0) continue;
			int mc = s == 1 ? Font.CR_GOLD : Font.CR_ORANGE;
			if (RSQUI_Hand.OnLeft(s))
			{
				// the left corner: reserve then magazine
				double x = 39;
				double rw = Digits(big, 16, String.Format("%d", hd.reserve), x, H - 78, Font.CR_GOLD, 0, 0.75);
				if (hd.mag >= 0) Digits(big, 16, String.Format("%d", hd.mag), x + rw + 6, H - 78, mc, 0);
				pen.Picture(hd.ammoIcon, x + rw / 2 - 13, H - 52, 26, 32);
			}
			else
			{
				// the right corner: magazine then reserve, right-aligned
				double xr = W - 39;
				double rw = Digits(big, 16, String.Format("%d", hd.reserve), xr, H - 78, Font.CR_GOLD, 2, 0.75);
				if (hd.mag >= 0) Digits(big, 16, String.Format("%d", hd.mag), xr - rw - 6, H - 78, mc, 2);
				pen.Picture(hd.ammoIcon, xr - rw / 2 - 13, H - 52, 26, 32);
			}
		}
		// centre: health | face | armour
		double cx = W / 2;
		TextureID face = StatusBar ? StatusBar.GetMugshot(5) : TexMan.CheckForTexture("STFST01", TexMan.Type_Any);
		pen.Picture(face, cx - 17, H - 36, 34, 32);
		// REMOVE HUD HEALTH AND ARMOR (owner 2026-11-12 15:36, the row in RSQ Gun Cards' options; the cvar is BD22 VR
		// Reloaded's, rsq_hud_nohp, read by name): the face stays, its health and armour go
		let nohp = CVar.GetCVar('rsq_hud_nohp', players[consoleplayer]);
		if (nohp && nohp.GetBool()) return;
		double hw = Digits(big, 24, String.Format("%d", data.health), cx - 26, H - 33, Font.CR_UNTRANSLATED, 2);
		TextureID med = TexMan.CheckForTexture("MEDIA0", TexMan.Type_Any);
		pen.Picture(med, cx - 26 - hw - 38, H - 34, 32, 29);
		if (data.armor > 0)
		{
			TextureID arm = data.armorIcon.IsValid() ? data.armorIcon : TexMan.CheckForTexture("ARM1A0", TexMan.Type_Any);
			pen.Picture(arm, cx + 26, H - 34, 34, 29);
			Digits(big, 24, String.Format("%d", data.armor), cx + 66, H - 33, Font.CR_UNTRANSLATED, 0);
		}
	}

	// Digits in the game's own HUD font, h units tall; returns the width in units.
	double Digits(Font f, double h, String s, double x, double y, int cr, int align, double alpha = 1.0)
	{
		double k = h / max(1, f.GetHeight()) * pen.u;
		double w = f.StringWidth(s) * k / pen.u;
		if (align == 2) x -= w; else if (align == 1) x -= w / 2;
		Screen.DrawText(f, cr, pen.X(x), pen.Y(y), s, DTA_ScaleX, k, DTA_ScaleY, k, DTA_Alpha, alpha);
		return w;
	}
}
