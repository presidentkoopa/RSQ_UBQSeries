// ============================================================================
// RS_ScoreHUD -- a transcription of score_display.h, not an interpretation.
//
// EVERY NUMBER AND EVERY ANCHOR HERE MATCHES THE ORIGINAL. That includes the two
// things that look like mistakes and are not:
//
//   compressRatio -- the original multiplies the virtual WIDTH by
//     max(1.0, aspect / (16/9)). It is compensating for SetHudSize letterboxing out
//     to 16:9 and then stretching past it. Drop it and the block sits somewhere
//     else on any display that is not 16:9. It is kept.
//
//   downshift -- Score_ScaledCoord's fourth argument, passed as
//     (widewidth - screenwidth) for X and 0 for Y, and subtracted as (downshift/2).
//     Part of the same compensation. It is kept.
//
// THE ANCHORS come from HudMessage's coordinate-fraction convention, which this
// engine implements in DHUDMessage::Draw (hudmessages.cpp). With a HUD size set:
//
//   x fraction .4  -> centre the text on x         (score line, bar, life pips)
//   x fraction .1  -> x is the LEFT edge           (both bonus columns)
//   y fraction .2  -> y is the BOTTOM edge         (score line)
//   y fraction  0  -> y is the VERTICAL CENTRE     (bar, pips, bonus rows)
//
// So the score line's BASELINE BOX BOTTOM sits at centerY+7 -- not its top -- and a
// bonus row is centred on its y, not hung from it. Getting those two wrong moves
// everything by a font height, which is what a first pass at this did.
//
// WHAT IS NOT A HudMessage ANY MORE: the original had no way to draw a picture, so
// every graphic was registered as a font containing the single character "A" and
// printed as the string "A". We draw the texture. The anchor maths is unchanged, so
// it lands in the same place.
//
// THE BAR FILL uses DTA_ClipLeft/DTA_ClipRight, which clip the DESTINATION -- the
// same thing SetHudClipRect did. The texture is drawn whole, centred, and clipped
// to [centerX - 60, centerX - 60 + barWidth]. Cropping the source instead would
// differ the moment the art is not exactly 120 wide.
//
// UI SCOPE. The only file allowed to know whose screen this is, and it writes
// nothing.
// ============================================================================

class RS_ScoreHUD : EventHandler
{
	const SCREEN_X    = 640;
	const SCREEN_Y    = 480;
	const BARWIDTH    = 120;   // SCORE_BARWIDTH
	const PAD_WIDTH   = 140;   // BAR_APPROXWIDTH
	const PAD_HEIGHT  = 40;    // BAR_APPROXHEIGHT
	const LIVES_MAX   = 10;    // LIVES_MAXDRAW
	const ROW_STEP    = 13;

	override void RenderOverlay(RenderEvent e)
	{
		if (gamestate != GS_LEVEL) { return; }
		if (automapactive) { return; }

		int pln = consoleplayer;
		if (pln < 0 || pln >= MAXPLAYERS || !playeringame[pln]) { return; }
		if (!players[pln].mo) { return; }

		let tr = RS_ScoreTracker(players[pln].mo.FindInventory("RS_ScoreTracker"));
		if (!tr) { return; }

		let handler = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
		if (!handler) { return; }

		// hideScore = dakka_cl_hidescore | (screenblocks == 12)
		bool hideScore = UserBool(pln, "rs_score_hide", false)
		              || UserInt(pln, "screenblocks", 11) == 12;
		if (hideScore) { return; }

		// hideBonuses = (bonustime == 0) | hideScore
		bool hideBonuses = UserInt(pln, "rs_score_bonustime", 35) == 0;

		// ---- Score_Draw's coordinate space, transcribed ----------------------
		int    d      = UserInt(pln, "rs_score_scale", 100);
		double aspect = Screen.GetWidth() / double(Screen.GetHeight());

		double screenwidth  = ScaleRes(SCREEN_X, d);
		double screenheight = ScaleRes(SCREEN_Y, d);
		double widewidth    = screenheight * aspect;

		double compressRatio = max(1.0, aspect / (16.0 / 9.0));
		screenwidth *= compressRatio;

		double centerX = ScaledCoord(UserInt(pln, "rs_score_x", 85), widewidth,    PAD_WIDTH,  widewidth - screenwidth);
		double centerY = ScaledCoord(UserInt(pln, "rs_score_y", 10), screenheight, PAD_HEIGHT, 0);

		// The original draws into SetHudSize(screenwidth, screenheight) while its X
		// coordinates were measured against widewidth. That asymmetry IS the
		// compensation; reproduce it rather than tidy it.
		double vw = screenwidth;
		double vh = screenheight;

		// flash = flashscore && gotPoints, where gotPoints is a one-tic pulse on the
		// tic points landed. The message it posted held 0.05s then faded 0.15s.
		bool flash = UserBool(pln, "rs_score_flash", true)
		          && FadeAlpha(tr.flashTic, 0.05, 0.15) > 0.0;
		double flashAlpha = flash ? FadeAlpha(tr.flashTic, 0.05, 0.15) : 0.0;

		DrawScoreLine(tr, vw, vh, centerX, centerY, flashAlpha);
		DrawBar(tr, handler, pln, vw, vh, centerX, centerY, flashAlpha);
		DrawLives(tr, vw, vh, centerX, centerY);

		if (!hideBonuses) { DrawBreakdown(tr, handler, pln, vw, vh, centerX, centerY); }
	}

	// ------------------------------------------------------------ the number
	//
	// Original: one message, "Score: \c[DScore_Gold]<n>", font DAKKAFON, colour
	// DScore_White, x centred on centerX (.4), y BOTTOM-anchored at centerY+7 (.2).
	// The flash is the same string in the Flash colours over the top.

	private ui void DrawScoreLine(RS_ScoreTracker tr, double vw, double vh, double cx, double cy, double flashAlpha)
	{
		Font fnt = Font.GetFont("RSSCFON");
		if (!fnt) { fnt = smallfont; }

		String label = "Score: ";
		String num   = String.Format("%d", tr.displayScore);

		double total = fnt.StringWidth(label .. num);
		double x     = cx - total * 0.5;            // x fraction .4: centred
		double y     = (cy + 7) - fnt.GetHeight();  // y fraction .2: bottom edge

		Screen.DrawText(fnt, Font.FindFontColor("RSScore_White"), x, y, label,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true);

		Screen.DrawText(fnt, Font.FindFontColor("RSScore_Gold"), x + fnt.StringWidth(label), y, num,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true);

		if (flashAlpha <= 0.0) { return; }

		Screen.DrawText(fnt, Font.FindFontColor("RSScore_WhiteFlash"), x, y, label,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
			DTA_Alpha, flashAlpha);

		Screen.DrawText(fnt, Font.FindFontColor("RSScore_GoldFlash"), x + fnt.StringWidth(label), y, num,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
			DTA_Alpha, flashAlpha);
	}

	// --------------------------------------------------------------- the bar
	//
	// Original draw order, bottom to top: background (SCOREBG), its flash, the
	// bracket (SCOREBKT), then the fill (SCOREBR) clipped to the progress width, and
	// the fill's flash. All centred on centerX, vertically centred on centerY+13.

	private ui void DrawBar(RS_ScoreTracker tr, RS_ScoreHandler handler, int pln,
	                        double vw, double vh, double cx, double cy, double flashAlpha)
	{
		if (UserBool(pln, "rs_score_norewards", false)) { return; }
		if (ServerInt("rs_score_rewardtypes", 3) == 4) { return; }

		bool nextIsLife;
		switch (ServerInt("rs_score_rewardtypes", 3))
		{
			default: nextIsLife = (tr.rewardCount % 2) == 1; break;
			case 1:  nextIsLife = (tr.rewardCount % 2) == 0; break;
			case 2:  nextIsLife = false; break;
			case 3:  nextIsLife = true;  break;
		}

		String bg      = nextIsLife ? "SCOREBG2" : "SCOREBG1";
		String bgFlash = nextIsLife ? "SCOREBG4" : "SCOREBG3";
		String fg      = nextIsLife ? "SCOREBR2" : "SCOREBR1";
		String fgFlash = nextIsLife ? "SCOREBR4" : "SCOREBR3";

		double y = cy + 13;

		DrawCentered(bg, cx, y, vw, vh, 1.0);
		if (flashAlpha > 0.0) { DrawCentered(bgFlash, cx, y, vw, vh, flashAlpha); }

		DrawCentered("SCOREBKT", cx, y, vw, vh, 1.0);

		if (handler.threshold <= 0) { return; }

		// barPoints = curPoints % goalPoints; barWidth = 120 * barPoints / goalPoints
		int barPoints = tr.score % handler.threshold;
		double barWidth = (BARWIDTH * double(barPoints)) / double(handler.threshold);
		if (barWidth <= 0.0) { return; }

		double barLeft = cx - (BARWIDTH / 2);

		DrawClipped(fg, cx, y, vw, vh, 1.0, barLeft, barLeft + barWidth);
		if (flashAlpha > 0.0) { DrawClipped(fgFlash, cx, y, vw, vh, flashAlpha, barLeft, barLeft + barWidth); }
	}

	// ------------------------------------------------------------- the lives
	//
	// Original: four frames cycling every four tics; borderLeft = centerX - 6*(n-1),
	// step 12, y = centerY - 12, each pip centred on its x and on y.

	private ui void DrawLives(RS_ScoreTracker tr, double vw, double vh, double cx, double cy)
	{
		int lives = min(LIVES_MAX, tr.extraLives);
		if (lives <= 0) { return; }

		String pip;
		switch ((level.maptime / 4) % 4)
		{
			default:
			case 0: pip = "HUD_LIF1"; break;
			case 1: pip = "HUD_LIF2"; break;
			case 2: pip = "HUD_LIF3"; break;
			case 3: pip = "HUD_LIF4"; break;
		}

		double left = cx - (6 * (lives - 1));
		double y    = cy - 12;

		for (int i = 0; i < lives; i++)
		{
			DrawCentered(pip, left + 12.0 * i, y, vw, vh, 1.0);
		}
	}

	// --------------------------------------------------------- the breakdown
	//
	// Original: font DAKKAFN2. `offset` counts EVERY row with a value, whether or not
	// it is being redrawn, so a row keeps its slot while others come and go. The "+N"
	// column is LEFT-anchored at centerX-55, the name at centerX-12, and both are
	// vertically CENTRED on centerY + 26 + 13*(offset-1).
	//
	// Hold time is (bonustime/35) - 0.5 seconds, then a 0.5 second fade.

	private ui void DrawBreakdown(RS_ScoreTracker tr, RS_ScoreHandler handler, int pln,
	                              double vw, double vh, double cx, double cy)
	{
		int showTics = clamp(UserInt(pln, "rs_score_bonustime", 35), 35, 193);

		Font fnt = Font.GetFont("RSSCFN2");
		if (!fnt) { fnt = smallfont; }

		double half = fnt.GetHeight() * 0.5;
		double bonusY = cy + 26;
		int offset = 0;

		double hold = (showTics / 35.0) - 0.5;
		if (hold < 0.0) { hold = 0.0; }

		for (int row = 0; row < tr.rowValue.Size(); row++)
		{
			if (tr.rowValue[row] <= 0) { continue; }

			// Counted for every row that has a value -- this is what keeps the slots
			// stable, and it happens before the visibility test on purpose.
			offset += 1;

			if (tr.rowTic[row] <= 0) { continue; }

			double alpha = FadeAlpha(tr.rowTic[row], hold, 0.5);
			if (alpha <= 0.0) { continue; }

			if (row >= handler.rowName.Size()) { continue; }
			String name  = handler.rowName[row];
			String color = handler.rowColor[row];

			double rowY = bonusY + ROW_STEP * (offset - 1) - half;

			Screen.DrawText(fnt, Font.FindFontColor(color), cx - 55, rowY,
				String.Format("+%d", tr.rowValue[row]),
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_Alpha, alpha);

			Screen.DrawText(fnt, Font.FindFontColor("RSScore_White"), cx - 12, rowY, name,
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_Alpha, alpha);
		}
	}

	// ----------------------------------------------------------------- helpers

	// HUDMSG_FADEOUT: full alpha for `hold` seconds from `startTic`, then linear to
	// zero over `fade` seconds.
	private ui double FadeAlpha(int startTic, double hold, double fade)
	{
		if (startTic <= 0) { return 0.0; }

		double age = (level.maptime - startTic) / 35.0;
		if (age < 0.0)    { return 0.0; }
		if (age <= hold)  { return 1.0; }

		if (fade <= 0.0) { return 0.0; }

		double t = (age - hold) / fade;
		return (t >= 1.0) ? 0.0 : 1.0 - t;
	}

	private ui void DrawCentered(String texName, double cx, double cy, double vw, double vh, double alpha)
	{
		TextureID tex = TexMan.CheckForTexture(texName, TexMan.Type_Any);
		if (!tex.IsValid()) { return; }

		Vector2 size = TexMan.GetScaledSize(tex);

		Screen.DrawTexture(tex, false, cx - size.x * 0.5, cy - size.y * 0.5,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
			DTA_Alpha, alpha);
	}

	// The same centred draw, clipped on the destination -- SetHudClipRect's job.
	private ui void DrawClipped(String texName, double cx, double cy, double vw, double vh,
	                            double alpha, double clipLeft, double clipRight)
	{
		TextureID tex = TexMan.CheckForTexture(texName, TexMan.Type_Any);
		if (!tex.IsValid()) { return; }

		Vector2 size = TexMan.GetScaledSize(tex);

		Screen.DrawTexture(tex, false, cx - size.x * 0.5, cy - size.y * 0.5,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
			DTA_Alpha, alpha,
			DTA_ClipLeft, int(clipLeft),
			DTA_ClipRight, int(clipRight));
	}

	// Score_ScaleRes: scale = middle(25, scale, 400); round(res * 100 / scale).
	private ui double ScaleRes(int res, int scale)
	{
		scale = clamp(scale, 25, 400);
		return round(res * 100.0 / scale);
	}

	// Score_ScaledCoord, with the downshift term the first pass dropped:
	//   saferange = range - (range > padding ? padding : 0)
	//   saferange * (clamp(pos,0,100)/100) + (range - saferange)/2 - downshift/2
	private ui double ScaledCoord(int pos, double range, double padding, double downshift)
	{
		double safe = range - ((range > padding) ? padding : 0.0);
		return safe * (clamp(pos, 0, 100) / 100.0)
		     + (range - safe) * 0.5
		     - downshift * 0.5;
	}

	private ui int ServerInt(String name, int fallback)
	{
		let cv = CVar.FindCVar(name);
		return cv ? cv.GetInt() : fallback;
	}

	private ui int UserInt(int pln, String name, int fallback)
	{
		let cv = CVar.GetCVar(name, players[pln]);
		return cv ? cv.GetInt() : fallback;
	}

	private ui bool UserBool(int pln, String name, bool fallback)
	{
		let cv = CVar.GetCVar(name, players[pln]);
		return cv ? cv.GetBool() : fallback;
	}
}
