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
		int    d      = int(UserInt(pln, "rs_score_scale", 100) * RSSC_A11y.Text());   // RSQ_Accessibility's Text Size (1 = as set)
		double aspect = Screen.GetWidth() / double(Screen.GetHeight());

		double screenwidth  = ScaleRes(SCREEN_X, d);
		double screenheight = ScaleRes(SCREEN_Y, d);
		double widewidth    = screenheight * aspect;

		double compressRatio = max(1.0, aspect / (16.0 / 9.0));
		screenwidth *= compressRatio;

		double centerX = ScaledCoord(UserInt(pln, "rs_score_x", 85), widewidth,    PAD_WIDTH,  widewidth - screenwidth);
		double centerY = ScaledCoord(UserInt(pln, "rs_score_y", 10), screenheight, PAD_HEIGHT, 0);
		// THE SHIELDSAW'S GAUGE (the Gun Bonsai VR patch, rsq_hud_shield, off by default) takes the top
		// middle; while it is on, the whole display -- line, bar, lives, breakdown -- moves down by as far
		// as that gauge reaches below the hand gauges' top (asked by name: RSQ_HudService). Off, or
		// without the patch, nothing moves.
		centerY += screenheight * GaugeShift();

		// The original draws into SetHudSize(screenwidth, screenheight) while its X
		// coordinates were measured against widewidth. That asymmetry IS the
		// compensation; reproduce it rather than tidy it.
		double vw = screenwidth;
		double vh = screenheight;

		// flash = flashscore && gotPoints, where gotPoints is a one-tic pulse on the
		// tic points landed. The message it posted held 0.05s then faded 0.15s.
		bool flash = UserBool(pln, "rs_score_flash", true)
		          && FadeAlpha(tr.flashTic, 0.05, 0.15) > 0.0;
		double flashAlpha = flash ? RSSC_A11y.Dim(FadeAlpha(tr.flashTic, 0.05, 0.15)) : 0.0;   // Photosensitive Mode: 40%

		DrawScoreLine(tr, handler, pln, vw, vh, centerX, centerY, flashAlpha);
		DrawBar(tr, handler, pln, vw, vh, centerX, centerY, flashAlpha);
		DrawLives(tr, vw, vh, centerX, centerY);

		if (!hideBonuses) { DrawBreakdown(tr, handler, pln, vw, vh, centerX, centerY); }
	}

	// ------------------------------------------------------------ the number
	//
	// Original: one message, "Score: \c[DScore_Gold]<n>", font DAKKAFON, colour
	// DScore_White, x centred on centerX (.4), y BOTTOM-anchored at centerY+7 (.2).
	// The flash is the same string in the Flash colours over the top.

	private ui void DrawScoreLine(RS_ScoreTracker tr, RS_ScoreHandler handler, int pln, double vw, double vh, double cx, double cy, double flashAlpha)
	{
		Font fnt = Font.GetFont("RSSCFON");
		if (!fnt) { fnt = smallfont; }

		String label = "Score: ";
		String num   = String.Format("%d", tr.displayScore);

		double total = fnt.StringWidth(label .. num);
		double x     = cx - total * 0.5;            // x fraction .4: centred
		double y     = (cy + 7) - fnt.GetHeight();  // y fraction .2: bottom edge

		if (UserBool(pln, "rs_score_alive", true))
			Screen.DrawText(fnt, Font.FindFontColor("RSScore_White"), x, y, label,
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_Color, LabelColor(tr, handler));
		else
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
		DrawBarTag(nextIsLife, cx, y, vw, vh);

		if (handler.threshold <= 0) { return; }

		// barPoints = curPoints % goalPoints; barWidth = 120 * barPoints / goalPoints
		int barPoints = tr.score % handler.threshold;
		double barWidth = (BARWIDTH * double(barPoints)) / double(handler.threshold);
		if (barWidth <= 0.0) { return; }

		double barLeft = cx - (BARWIDTH / 2);

		DrawClipped(fg, cx, y, vw, vh, 1.0, barLeft, barLeft + barWidth);
		if (flashAlpha > 0.0) { DrawClipped(fgFlash, cx, y, vw, vh, flashAlpha, barLeft, barLeft + barWidth); }
	}

	// Colour-blind play (rsqa_colorblind, cb.zs): what the bar fills toward is told by its colour
	// (orange: a reward, blue: a life), so a life also shows as a life pip at the bar's end.
	private ui void DrawBarTag(bool nextIsLife, double cx, double y, double vw, double vh)
	{
		if (nextIsLife && RS_ScoreCB.Mode()) DrawCentered("HUD_LIF1", cx + BARWIDTH / 2 + 8, y, vw, vh, 1.0);
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
			// Colour-blind play (rsqa_colorblind, cb.zs): the family's colour for that vision
			// (TEXTCOLO _PD / _T / _HC) and its letter left of the number, so a family is never
			// told by colour alone. Off, the breakdown is exactly as it was.
			String tag = "";
			String fam = color;
			if (RS_ScoreCB.Mode())
			{
				tag = FamilyLetter(color);
				if (tag != "" || fam == "RSScore_Base") fam = fam .. RS_ScoreCB.Suffix();   // a mod's own colour stays
			}

			double rowY = bonusY + ROW_STEP * (offset - 1) - half;

			if (tag != "")
				Screen.DrawText(fnt, Font.FindFontColor(fam), cx - 55 - fnt.StringWidth(tag .. " "), rowY, tag,
					DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
					DTA_Alpha, alpha);

			Screen.DrawText(fnt, Font.FindFontColor(fam), cx - 55, rowY,
				String.Format("+%d", tr.rowValue[row]),
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_Alpha, alpha);

			Screen.DrawText(fnt, Font.FindFontColor("RSScore_White"), cx - 12, rowY, name,
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_Alpha, alpha);
		}
	}

	// ------------------------------------------------------------ the living word
	//
	// THE WORD "Score:" BREATHES (the owner, 10-27: like Gun Bonsai's XP bars, whose frame cycles the
	// rainbow on a level-up -- HUD.zsc GetShinyColour -- but gentler). rs_score_alive (on) turns it off;
	// only the word changes, the number, the bar and the breakdown keep their look. It multiplies the
	// word's own white (DTA_Color), so it is a tint of the same letters:
	//   * a slow pastel hue cycle (24 s round), the letters never less than 60% white;
	//   * a breath in brightness (88..100%, one every 4 s);
	//   * as the bar nears its reward (the last quarter) it warms toward gold and breathes twice as fast;
	//   * a big combo (combo.zs: a named combo, or three tools or more) lifts it to full white for a second.
	// RSQ_Accessibility: Photosensitive Mode holds it still (no cycle, no breath, no lift: only the slow
	// warming, which follows the bar); a colour-blind setting drops the hue cycle and the warming (they
	// would be colour alone) and keeps the breath, which speeds up near the reward instead.
	private ui int LabelColor(RS_ScoreTracker tr, RS_ScoreHandler handler)
	{
		double t = level.maptime + 0.0;
		bool photo = RSSC_A11y.Photo();
		bool cb = RS_ScoreCB.Mode() != 0;
		double near = handler.threshold > 0 ? clamp((tr.ProgressFraction(handler.threshold) - 0.75) / 0.25, 0.0, 1.0) : 0.0;

		// the hue cycle, pastel: mixed 60% toward white
		double r = 1, g = 1, b = 1;
		if (!photo && !cb)
		{
			double hr, hg, hb;
			[hr, hg, hb] = Hue((t / 840.0) % 1.0);
			r = 0.6 + 0.4 * hr; g = 0.6 + 0.4 * hg; b = 0.6 + 0.4 * hb;
		}
		// warming toward gold (FFC860) near the reward
		if (!cb && near > 0)
		{
			double k = 0.9 * near;
			r = r + (1.00 - r) * k; g = g + (0.78 - g) * k; b = b + (0.38 - b) * k;
		}
		// the breath
		double v = 1.0;
		if (!photo)
		{
			double period = 140.0 / (1.0 + near);
			v = 0.88 + 0.12 * (0.5 + 0.5 * sin(t * 360.0 / period));
			// a big combo: full white, easing back over a second
			int age = level.maptime - tr.bigComboTic;
			if (tr.bigComboTic > 0 && age >= 0 && age < 35)
			{
				double k = 1.0 - age / 35.0;
				r += (1 - r) * k; g += (1 - g) * k; b += (1 - b) * k; v += (1 - v) * k;
			}
		}
		int ir = clamp(int(255 * r * v), 0, 255), ig = clamp(int(255 * g * v), 0, 255), ib = clamp(int(255 * b * v), 0, 255);
		return 0xFF000000 | (ir << 16) | (ig << 8) | ib;
	}

	// a hue (0..1) at full saturation
	private ui double, double, double Hue(double h)
	{
		double x = h * 6.0;
		int seg = int(x) % 6;
		double f = x - floor(x);
		switch (seg)
		{
			case 0: return 1, f, 0;
			case 1: return 1 - f, 1, 0;
			case 2: return 0, 1, f;
			case 3: return 0, 1 - f, 1;
			case 4: return f, 0, 1;
		}
		return 1, 0, 1 - f;
	}

	// the share of the screen's height the display moves down while the Gun Bonsai VR patch's ShieldSaw
	// gauge is on (how far it reaches below the hand gauges' top, RSQ_HudService "shield.gauge.drop"); 0 off or without the patch
	private ui double GaugeShift()
	{
		let it = ServiceIterator.Find("RSQ_HudService");
		let s = it.Next();
		if (!s) return 0.0;
		int h = s.GetIntUI("shield.gauge.drop", "", 0, 0, null);
		return h > 0 ? h / 1000.0 : 0.0;
	}

	// ----------------------------------------------------------------- helpers

	// A family's letter for colour-blind play, from its colour name (bonus.zs FamilyColor).
	private ui String FamilyLetter(String color)
	{
		if (color == "RSScore_Efficiency") return "E";
		if (color == "RSScore_Style")      return "S";
		if (color == "RSScore_Daring")     return "D";
		if (color == "RSScore_Melee")      return "M";
		return "";
	}

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
