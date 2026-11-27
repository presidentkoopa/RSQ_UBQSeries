// ============================================================================
// RS_ScoreHUD -- a transcription of score_display.h, not an interpretation.
//
// THE LAYOUT IS THE ORIGINAL'S (its anchors and spacing; the size default is 150 here and the rows move down for
// other mods' HUD pieces, RSQ SlowMo's countdown bar). That includes the two
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
// THE BAR FILL keeps [centerX - 60, centerX - 60 + barWidth] of the texture drawn
// whole and centred -- the same thing SetHudClipRect did -- by cropping the source
// with DTA_WindowLeftF/RightF measured from the texture's own left edge, so it holds
// whatever the art's width. (2026-11-03: it was DTA_ClipLeft/ClipRight, which take
// screen pixels, not these virtual units, and whose scissor misses the projected HUD
// in VR. See DrawClipped.)
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

	ui bool migrated;

	// Saved settings outlive a changed default, so a saved Across is moved once (rs_score_cfgver), as Gun Bonsai VR does.
	// Version 1 (owner 11-11): Across 85 (the old default, the line over the main hand gauge's weapon name) becomes 50.
	static ui void Migrate()
	{
		let ver = CVar.FindCVar("rs_score_cfgver");
		if (!ver || ver.GetInt() >= 4) return;
		int from = ver.GetInt();
		let x = CVar.FindCVar("rs_score_x");
		if (from < 1 && x && x.GetInt() == 85) x.SetInt(50);
		// Version 2 (owner 11-11 23:56: "lower Score a few units more"): Down 10 (the old default) becomes 13; any other
		// saved Down is kept. Between the hand gauges it is 3 units under their middle (GaugeShift keeps the move from 10).
		let y = CVar.FindCVar("rs_score_y");
		if (from < 2 && y && y.GetInt() == 10) y.SetInt(13);
		// Version 3 (owner 11-12 14:11: "i had asked for the bar to be lower, maybe it is and my settings need changed"):
		// version 2 only moved a saved 10. Any saved Down under 13 becomes 13 now; one already lower on the screen is kept.
		if (from < 3 && y && y.GetInt() < 13) y.SetInt(13);
		// Version 4 (2026-11-27; owner, asked what a new map does to Score lives: "Keep lives and total"): New Map Keeps
		// was Nothing by default (rs_score_startmode 0), which set the lives to 0 on every new map, the starting life
		// included. The default is now Plus Rewards (2), and a saved 0 is moved to it this once; any other saved choice is
		// kept, and Nothing chosen after this stays. (A server setting: the engine applies the change on the next tic.)
		let sm = CVar.FindCVar("rs_score_startmode");
		if (from < 4 && sm && sm.GetInt() == 0) sm.SetInt(2);
		ver.SetInt(4);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (!migrated) { migrated = true; Migrate(); }
		if (gamestate != GS_LEVEL) { return; }
		if (automapactive) { return; }
		if (menuactive != Menu.Off) { return; }   // owner 11-11: nothing over a menu (any menu)

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

		double centerX, centerY, vw, vh;
		[centerX, centerY, vw, vh] = Layout(pln);

		// flash = flashscore && gotPoints, where gotPoints is a one-tic pulse on the
		// tic points landed. The message it posted held 0.05s then faded 0.15s.
		bool flash = UserBool(pln, "rs_score_flash", true)
		          && FadeAlpha(tr.flashTic, 0.05, 0.15) > 0.0;
		double flashAlpha = flash ? FadeAlpha(tr.flashTic, 0.05, 0.15) : 0.0;

		// THE REWARD'S VISIBLE CUE (owner 11-05: "can we optimize that effect? it slows down my game"): when the bar fills,
		// the bar lights in the colour of what it paid (orange ammo, blue a life) and the score line flashes, for the 26 tics
		// the old whole-view tint ran; a life also pops the life pips (DrawLives). A few small HUD quads instead of the
		// full-eye passes a blend costs in VR (handler.zs CheckRewards).
		double glow = FadeAlpha(tr.rewardTic, 0.1, 0.65);

		DrawScoreLine(tr, handler, pln, vw, vh, centerX, centerY, max(flashAlpha, glow));
		DrawBar(tr, handler, pln, vw, vh, centerX, centerY, flashAlpha, glow);
		DrawLives(tr, vw, vh, centerX, centerY);

		if (!hideBonuses) { DrawBreakdown(tr, handler, pln, vw, vh, centerX, centerY); }
	}

	// ---- Score_Draw's coordinate space, transcribed: the display's centre and its virtual size ----------------
	// (a static so RS_ScoreService's "hud.*" reads give other HUDs the same answer: RSQ SlowMo's countdown bar)
	static ui double, double, double, double Layout(int pln)
	{
		int    d      = SUserInt(pln, "rs_score_scale", 150);
		double aspect = Screen.GetWidth() / double(Screen.GetHeight());

		double screenwidth  = SScaleRes(SCREEN_X, d);
		double screenheight = SScaleRes(SCREEN_Y, d);
		double widewidth    = screenheight * aspect;

		double compressRatio = max(1.0, aspect / (16.0 / 9.0));
		screenwidth *= compressRatio;

		double centerX = SScaledCoord(SUserInt(pln, "rs_score_x", 50), widewidth,    PAD_WIDTH,  widewidth - screenwidth);
		double centerY = SScaledCoord(SUserInt(pln, "rs_score_y", 13), screenheight, PAD_HEIGHT, 0);
		// BETWEEN THE HAND GAUGES (owner 11-11 evening: "score should be centered top middle and down a few units so it
		// isn't flush with the top edge of screen. neatly between xp bars"): while a gauge is drawn, the score line's middle
		// sits at the middle of the gauges' band (RSQ_HudService "gauges.top" / "gauges.bottom"); the Down row still moves
		// it from there (its default, 10, is no move). Without Gun Bonsai VR, or with no gauge on screen, the line is at
		// the Down row's place near the top, as before.
		centerY += GaugeShift(centerY, screenheight);

		// The original draws into SetHudSize(screenwidth, screenheight) while its X
		// coordinates were measured against widewidth. That asymmetry IS the
		// compensation; reproduce it rather than tidy it.
		return centerX, centerY, screenwidth, screenheight;
	}

	// FOR ANOTHER HUD, in screen pixels (RS_ScoreService GetIntUI): "hud.cx" the display's centre, "hud.bar.bottom" the bar's
	// bottom edge (its bracket, 8 tall, centred 13 under the centre), "hud.bar.w" the bar's width. DTA_KeepRatio maps the
	// virtual space straight onto the screen (v_draw.cpp VirtualToRealCoords with handleaspect off), so it is a plain scale.
	static ui int LayoutPx(String request)
	{
		int pln = consoleplayer;
		if (pln < 0 || pln >= MAXPLAYERS || !playeringame[pln]) return -1;
		double cx, cy, vw, vh;
		[cx, cy, vw, vh] = Layout(pln);
		double W = Screen.GetWidth(), H = Screen.GetHeight();
		if (request == "hud.cx") return int(cx * W / vw);
		if (request == "hud.bar.bottom") return int(ceil((cy + 17) * H / vh));
		if (request == "hud.bar.w") return int(BARWIDTH * W / vw);
		return -1;
	}

	// RSQ SLOWMO'S REAL-TIME COUNTDOWN BAR (owner 2026-11-03 19:06: "below the score bar but above where the combos appear")
	// sits under the bar while its row is on; the combo rows start below it (asked by name: RSQSM_Service
	// "countdown.bottom", screen pixels). Answers how far down, in this HUD's virtual units, the rows must move; 0 when
	// SlowMo is not loaded, its bar is switched off, or there is room already.
	// RSQ MINIBOSS'S BOSSFIGHT METER (owner 11-05) sits between the bar and the countdown (RSQMB_Service "meter.bottom");
	// SlowMo's bar already goes under it, and without SlowMo the rows go under the meter.
	static ui double CountdownShift(double rowsTop, double vh)
	{
		int px = -1;
		let s = ServiceIterator.Find("RSQSM_Service").Next();
		if (s) px = s.GetIntUI("countdown.bottom", "", 0, 0, null);
		let mb = ServiceIterator.Find("RSQMB_Service").Next();
		if (mb) px = max(px, mb.GetIntUI("meter.bottom", "", 0, 0, null));
		// RSQ VisualRewards' invulnerability bar (2026-11-16), its own row under SlowMo's, while it shows
		let vr = ServiceIterator.Find("RSQVR_Service").Next();
		if (vr) px = max(px, vr.GetIntUI("invbar.bottom", "", 0, 0, null));
		if (px <= 0) return 0.0;
		double need = px * vh / Screen.GetHeight() + 2;
		return max(0.0, need - rowsTop);
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
		{
			// "Letters" (rs_score_letters, owner 11-06): Uniform, the word breathes as one; Wave, the owner's mode 2, each
			// letter its own colour in a smooth sequence; Chaos, each letter breathes on its own
			let lcv = CVar.GetCVar("rs_score_letters", players[pln]);
			int mode = lcv ? lcv.GetInt() : 0;
			if (mode > 0)
			{
				int n = label.Length();
				double lx = x;
				for (int i = 0; i < n; i++)
				{
					String ch = label.Mid(i, 1);
					Screen.DrawText(fnt, Font.FindFontColor("RSScore_White"), lx, y, ch,
						DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
						DTA_Color, LabelColor(tr, handler, i, n, mode == 2));
					lx += fnt.StringWidth(ch);
				}
			}
			else
				Screen.DrawText(fnt, Font.FindFontColor("RSScore_White"), x, y, label,
					DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
					DTA_Color, LabelColor(tr, handler));
		}
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
	                        double vw, double vh, double cx, double cy, double flashAlpha, double glow = 0.0)
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

		// the reward glow lights the whole bar in what was just paid (tracker rewardKind), whatever comes next
		String glowBg = tr.rewardKind == 1 ? "SCOREBG4" : "SCOREBG3";
		String glowFg = tr.rewardKind == 1 ? "SCOREBR4" : "SCOREBR3";

		DrawCentered(bg, cx, y, vw, vh, 1.0);
		if (flashAlpha > 0.0) { DrawCentered(bgFlash, cx, y, vw, vh, flashAlpha); }
		if (glow > 0.0) { DrawCentered(glowBg, cx, y, vw, vh, glow); }

		DrawCentered("SCOREBKT", cx, y, vw, vh, 1.0);

		double barLeft = cx - (BARWIDTH / 2);

		// barPoints = curPoints % goalPoints; barWidth = 120 * barPoints / goalPoints
		if (handler.threshold > 0)
		{
			int barPoints = tr.score % handler.threshold;
			double barWidth = (BARWIDTH * double(barPoints)) / double(handler.threshold);
			if (barWidth > 0.0)
			{
				DrawClipped(fg, cx, y, vw, vh, 1.0, barLeft, barLeft + barWidth);
				if (flashAlpha > 0.0) { DrawClipped(fgFlash, cx, y, vw, vh, flashAlpha, barLeft, barLeft + barWidth); }
			}
		}

		if (glow > 0.0) { DrawClipped(glowFg, cx, y, vw, vh, glow, barLeft, barLeft + BARWIDTH); }
	}

	// ------------------------------------------------------------- the lives
	//
	// Original: four frames cycling every four tics; borderLeft = centerX - 6*(n-1),
	// step 12, y = centerY - 12, each pip centred on its x and on y.
	// DOOMGUY FACES (owner 2026-11-16, design/BANNERS_AND_HUD.md section 5: "an excellent idea ... yes, i like this"): each
	// life is a small Doomguy face (STFST01, from the IWAD the player loads) in the old pip's place and step; the newest
	// grins (STFEVL0) as it is gained, and one that is spent falls away OUCH (STFOUCH0) and grey. RSQ VisualRewards' +1UP
	// floats up into the newest face's slot: this HUD tells it where that slot is and holds that face back until the badge
	// lands (RSQVR_Service "banner.lives", by name; without VisualRewards nothing is held).
	// Rig only, not headset-confirmed.
	const FACE_H = 11.0;       // a face's height, virtual units (the pip was 8; the step stays 12)
	const GRIN = 52;           // tics the newest face grins
	const FALL = 30;           // tics a spent face takes to fall away
	ui int shownLives, grinTic, fallTic;
	ui double fallX, fallY;
	ui bool livesSeen;

	private ui void DrawLives(RS_ScoreTracker tr, double vw, double vh, double cx, double cy)
	{
		int lives = min(LIVES_MAX, tr.extraLives);
		double y = cy - 12;
		int slots = max(1, lives);
		double left = cx - (6 * (slots - 1));

		// where the newest face is (where a +1UP lands), and how many faces VisualRewards holds back
		int hold = 0;
		let vr = ServiceIterator.Find("RSQVR_Service").Next();
		if (vr)
		{
			double W = Screen.GetWidth(), H = Screen.GetHeight();
			hold = vr.GetIntUI("banner.lives", String.Format("%d %.2f", lives, FACE_H * H / vh), int((left + 12.0 * (slots - 1)) * W / vw), y * H / vh, null);
		}
		int shown = clamp(lives - hold, 0, lives);
		if (!livesSeen) { livesSeen = true; shownLives = shown; }
		if (shown > shownLives) grinTic = level.maptime;
		if (shown < shownLives)
		{
			// the face that went: the last one of the row as it was
			int was = max(1, shownLives);
			fallX = cx - 6 * (was - 1) + 12.0 * (was - 1);
			fallY = y;
			fallTic = level.maptime;
		}
		shownLives = shown;

		// the extra-life cue (handler.zs RunRewardCue sets lifeCueTic): every face swells up to half again and is lit
		// (drawn again, added) as the cue fades; a face that lands from a +1UP pops the same way.
		double pop = hold > 0 ? 0.0 : FadeAlpha(tr.lifeCueTic, 0.1, 0.65);
		double gpop = FadeAlpha(grinTic, 0.1, 0.65);
		bool grinning = grinTic > 0 && level.maptime - grinTic < GRIN;

		for (int i = 0; i < shown; i++)
		{
			bool newest = i == shown - 1;
			double p = max(pop, newest ? gpop : 0.0);
			DrawFace((newest && grinning) ? "STFEVL0" : "STFST01", left + 12.0 * i, y, vw, vh, 1.0 + 0.5 * p, p, 0, 1.0, false);
		}
		// a spent life falls away, OUCH and grey
		if (fallTic > 0)
		{
			double a = level.maptime - fallTic;
			if (a >= 0 && a < FALL)
				DrawFace("STFOUCH0", fallX + a * 0.2, fallY + 0.045 * a * a, vw, vh, 1.0, 0, 255, 1.0 - a / FALL, true);
		}
	}

	// a face centred on (fx, fy), FACE_H x scale tall, lit (added) by lit; desat 255 greys it
	private ui void DrawFace(String texName, double fx, double fy, double vw, double vh, double scale, double lit, int desat, double alpha, bool tintCold)
	{
		TextureID tex = TexMan.CheckForTexture(texName, TexMan.Type_Any);
		if (!tex.IsValid()) { tex = TexMan.CheckForTexture("HUD_LIF1", TexMan.Type_Any); if (!tex.IsValid()) return; }
		Vector2 ts = TexMan.GetScaledSize(tex);
		double h = FACE_H * scale, w = h * ts.x / max(1.0, ts.y);
		Color tint = tintCold ? Color(255, 205, 212, 230) : Color(255, 255, 255, 255);
		// a dark outline a face pixel wide, then the face
		double o = h / max(1.0, ts.y);
		for (int dx = -1; dx <= 1; dx++) for (int dy = -1; dy <= 1; dy++)
		{
			if (!dx && !dy) continue;
			Screen.DrawTexture(tex, false, fx + dx * o, fy + dy * o,
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true,
				DTA_FillColor, 0x080606, DTA_Alpha, 0.85 * alpha);
		}
		Screen.DrawTexture(tex, false, fx, fy,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
			DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true,
			DTA_Desaturate, desat, DTA_Color, tint, DTA_Alpha, alpha);
		if (lit > 0.0)
			Screen.DrawTexture(tex, false, fx, fy,
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_DestWidthF, w, DTA_DestHeightF, h, DTA_CenterOffset, true,
				DTA_LegacyRenderStyle, STYLE_Add, DTA_Alpha, lit * alpha);
	}

	// --------------------------------------------------------- the breakdown
	//
	// Original: font DAKKAFN2. `offset` counts EVERY row with a value, whether or not
	// it is being redrawn, so a row keeps its slot while others come and go. The "+N"
	// column is LEFT-anchored at centerX-55, the name at centerX-12, and both are
	// vertically CENTRED on centerY + 26 + 13*(offset-1).
	//
	// Hold time is (bonustime/35) - 0.5 seconds (never under 0), then a 0.5 second fade. Every slider step counts (11-09:
	// values under 35 used to read as 35).

	private ui void DrawBreakdown(RS_ScoreTracker tr, RS_ScoreHandler handler, int pln,
	                              double vw, double vh, double cx, double cy)
	{
		int showTics = clamp(UserInt(pln, "rs_score_bonustime", 35), 7, 196);

		Font fnt = Font.GetFont("RSSCFN2");
		if (!fnt) { fnt = smallfont; }
		// BONUS FONT (owner 2026-11-24 23:07): 0 Score Small (RSSCFN2, as before), 1 SOTN (fonts/RSSCSOTN: the letters
		// RSQ VisualRewards' SOTN words are drawn in, its owner's word sheet), drawn at Score Small's row height
		Font wf = fnt;
		double ws = 1.0;
		if (UserInt(pln, "rs_score_bonusfont", 0) == 1)
		{
			Font so = Font.GetFont("RSSCSOTN");
			if (so) { wf = so; ws = fnt.GetHeight() * 1.1 / so.GetHeight(); }
		}

		double half = fnt.GetHeight() * 0.5;
		double bonusY = cy + 26;
		bonusY += CountdownShift(bonusY - half, vh);   // below RSQ SlowMo's countdown bar, while its row is on
		// THREE COLUMNS (owner 2026-11-24 23:06: "with our slowmo, scorebar, and bossbar being in a row now we could show our
		// score bonuses in 3 columns, sorted by their base category"): the original's three families, one under each bar --
		// Efficiency under RSQ SlowMo's (left), Style under Score's (middle), Daring under the Boss bar's (right). RSQ's own two
		// go with the nearest: Melee (style with your hands) in the middle, Counterplay (answering an attack) on the right. The
		// Base row and any mod's own rows head the middle. Each column keeps its own stable slots.
		int offs[3]; offs[0] = 0; offs[1] = 0; offs[2] = 0;

		double hold = (showTics / 35.0) - 0.5;
		if (hold < 0.0) { hold = 0.0; }

		for (int row = 0; row < tr.rowValue.Size(); row++)
		{
			if (tr.rowValue[row] <= 0) { continue; }

			// Counted for every row that has a value -- this is what keeps the slots
			// stable, and it happens before the visibility test on purpose.
			int colN = row < handler.rowColor.Size() ? ColumnOf(handler.rowColor[row]) : 1;
			offs[colN] += 1;
			int offset = offs[colN];
			double ccx = cx + (colN - 1) * COL_STEP;

			if (tr.rowTic[row] <= 0) { continue; }

			double alpha = FadeAlpha(tr.rowTic[row], hold, 0.5);
			if (alpha <= 0.0) { continue; }

			if (row >= handler.rowName.Size()) { continue; }
			String name  = handler.rowName[row];
			String color = handler.rowColor[row];
			String fam = color;

			double rowY = bonusY + ROW_STEP * (offset - 1) - half;

			// THE SOTN LIFE (owner 2026-11-24 23:07: "each different colors ... some life to them in our sotn style"): the
			// whole row in its family's colour (the name was white), and RSQ VisualRewards' SOTN entrance (rsqvr/words.zs):
			// tics 0-3 stretched wide and settling, then until tic 28 a flash to the light look every 4 tics.
			int age = level.maptime - tr.rowTic[row];
			double k = age < 4 ? 1.0 - age / 4.0 : 0.0;
			double sx = 1.0 + 0.3 * k;
			bool lit = age >= 4 && age < 28 && ((age - 4) / 4) % 2 == 0;
			int famCol = Font.FindFontColor(fam);
			double wy = rowY + (fnt.GetHeight() - wf.GetHeight() * ws) * 0.5;
			// the SOTN letters carry no outline of their own (it took the row's colour): a dark drop shadow, one letter pixel
			if (wf != fnt)
			{
				double sh = ws;
				Screen.DrawText(wf, Font.CR_BLACK, ccx - 55 + sh, wy + sh, String.Format("+%d", tr.rowValue[row]),
					DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
					DTA_ScaleX, ws * sx, DTA_ScaleY, ws, DTA_Alpha, alpha * 0.9);
				Screen.DrawText(wf, Font.CR_BLACK, ccx - 12 + sh, wy + sh, name,
					DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
					DTA_ScaleX, ws * sx, DTA_ScaleY, ws, DTA_Alpha, alpha * 0.9);
			}
			// (owner 23:11: "maybe have the numbers be white and the word be colored")
			Screen.DrawText(wf, Font.FindFontColor("RSScore_White"), ccx - 55, wy,
				String.Format("+%d", tr.rowValue[row]),
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_ScaleX, ws * sx, DTA_ScaleY, ws, DTA_Alpha, alpha, DTA_ColorOverlay, lit ? 0x70FFFFFF : 0);

			Screen.DrawText(wf, famCol, ccx - 12, wy, name,
				DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
				DTA_ScaleX, ws * sx, DTA_ScaleY, ws, DTA_Alpha, alpha, DTA_ColorOverlay, lit ? 0x70FFFFFF : 0);
			// A CHAMPION ROW'S ICON (owner 11-10, design/icons style B): left of the number
			int ic = row < handler.rowIcon.Size() ? handler.rowIcon[row] : -1;
			if (ic >= 0)
			{
				TextureID it = TexMan.CheckForTexture(String.Format("RSSCCH%02d", ic), TexMan.Type_Any);
				double isz = fnt.GetHeight() * 1.1;
				double ix = ccx - 55 - isz - 3;
				if (it.IsValid())
					Screen.DrawTexture(it, false, ix, rowY + half - isz * 0.5, DTA_DestWidthF, isz, DTA_DestHeightF, isz,
						DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, alpha);
			}
		}
	}

	// ------------------------------------------------------------ the living word
	//
	// THE WORD "Score:" BREATHES, in the owner's colours (owner 11-05; his own earlier Score HUD, hf_score_hud.zs
	// ScoreLabelColor / DrawScoreLabel / HF_ScoreReact, the label colour only). rs_score_alive (on) turns it off; only
	// the word changes. It multiplies the word's own white (DTA_Color):
	//   * pulse = 0.5 + 0.5 * sin(ms * 0.18 deg): one breath every 2 s, on the game clock (it stops with a pause);
	//   * the colour runs with it from calm blue (110,170,230) to warm (250,240,140);
	//   * a reaction pushes it toward hot white-gold (255,255,70): a fresh award (points landing, a 7-tic flash) plus
	//     half a combo pop (EaseOutBack over 10 tics), as his HF_ScoreReact; and ours, a big combo (combo.zs: a named
	//     combo, or three tools or more) holds it there and eases back over a second;
	//   * ours too: as the bar nears its reward (the last quarter) the word warms toward gold;
	//   * "Letters" Wave (rs_score_letters 1) is his mode 2: each letter 55 degrees on from the last;
	//   * "Letters" Chaos (rs_score_letters 2, owner 11-06 "random chaos"): each letter breathes on its own, at its own pace
	//     (0.55x to 1.6x the breath) from its own starting point, both fixed per letter, so it never flickers: it stays a
	//     breath, just never in step.
	private ui int LabelColor(RS_ScoreTracker tr, RS_ScoreHandler handler, int idx = 0, int n = 1, bool chaos = false)
	{
		double near = handler.threshold > 0 ? clamp((tr.ProgressFraction(handler.threshold) - 0.75) / 0.25, 0.0, 1.0) : 0.0;

		double ms = level.maptime * (1000.0 / TICRATE);
		double phase = n > 1 ? 55.0 * idx : 0.0;
		double rate = 1.0;
		if (chaos && n > 1)
		{
			// a fixed pace and start per letter (a small hash of its place), so each breathes on its own
			double v1 = sin(idx * 78.233 + 12.9898) * 43758.5453, v2 = sin(idx * 39.346 + 11.135) * 24634.6345;
			double h1 = v1 - floor(v1), h2 = v2 - floor(v2);
			rate = 0.55 + 1.05 * h1;
			phase = 360.0 * h2;
		}
		double pulse = 0.5 + 0.5 * sin(ms * 0.18 * rate + phase);   // sin takes degrees
		double react = LabelReact(tr);

		double r = 110 + 140 * pulse;
		double g = 170 + 70  * pulse;
		double b = 230 - 90  * pulse;
		if (near > 0)
		{
			double k = 0.8 * near;   // toward gold, FFC860
			r += (255 - r) * k; g += (200 - g) * k; b += (96 - b) * k;
		}
		r += (255 - r) * react;
		g += (255 - g) * react;
		b += (70  - b) * react;
		int ir = clamp(int(r), 0, 255), ig = clamp(int(g), 0, 255), ib = clamp(int(b), 0, 255);
		return 0xFF000000 | (ir << 16) | (ig << 8) | ib;
	}

	// 0..1 heat from recent scoring (the owner's HF_ScoreReact: award flash + half the combo pop), and a big combo's lift
	private ui double LabelReact(RS_ScoreTracker tr)
	{
		double heat = 0.0;
		int age = level.maptime - tr.flashTic;
		if (tr.flashTic > 0 && age >= 0)
		{
			if (age <= 7)  heat += (7 - age) / 7.0;
			if (age <= 10) heat += 0.5 * EaseOutBack((10 - age) / 10.0);
		}
		int cage = level.maptime - tr.bigComboTic;
		if (tr.bigComboTic > 0 && cage >= 0 && cage < 35) heat = max(heat, 1.0 - cage / 35.0);
		return clamp(heat, 0.0, 1.0);
	}

	private ui double EaseOutBack(double t)
	{
		double c1 = 1.70158, c3 = c1 + 1.0, u = t - 1.0;
		return 1.0 + c3 * u * u * u + c1 * u * u;
	}

	// How far (virtual units) the display moves so the score line's middle (DrawScoreLine: bottom edge at centerY + 7, one
	// font height tall) sits at the middle of the hand gauges' band, plus the Down row's move from its default (10).
	// 0 when no gauge is drawn.
	static ui double GaugeShift(double cy, double vh)
	{
		let it = ServiceIterator.Find("RSQ_HudService");
		let s = it.Next();
		if (!s) return 0.0;
		int b = s.GetIntUI("gauges.bottom", "", 0, 0, null);
		int t = s.GetIntUI("gauges.top", "", 0, 0, null);
		if (b <= 0 || t < 0 || t >= b) return 0.0;
		Font fnt = Font.GetFont("RSSCFON");
		if (!fnt) { fnt = smallfont; }
		double lineMid = cy + 7 - fnt.GetHeight() * 0.5;
		double downMove = cy - SScaledCoord(10, vh, PAD_HEIGHT, 0);      // the Down row's own move, kept
		return (t + b) / 2000.0 * vh - (lineMid - downMove);
	}

	// ----------------------------------------------------------------- helpers

	// the column a family's rows go in: 0 left (under RSQ SlowMo's bar), 1 middle (Score's), 2 right (the Boss bar's)
	const COL_STEP = 125.0;   // a column's centre from the next, in Score's virtual units (its bar is 120 wide)
	static ui int ColumnOf(String color)
	{
		if (color == "RSScore_Efficiency") return 0;
		if (color == "RSScore_Daring" || color == "RSScore_Counter") return 2;
		return 1;
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

		// Cropped from the source (DTA_WindowLeftF / RightF, texels of the texture drawn at 1:1 in this virtual space), not
		// clipped with DTA_ClipLeft / ClipRight (2026-11-03): those take SCREEN pixels, so the virtual bar edges passed
		// here landed somewhere else on screen, and in VR the clip's scissor box stays in flat window pixels while the HUD
		// is projected (v_2ddrawer.cpp:507-512, hw_draw2d.cpp:141-153), which cut the fill away. The window keeps exactly
		// [clipLeft, clipRight] of the bar, in the same virtual units the rest of this HUD uses.
		double left = cx - size.x * 0.5;
		double wl = clamp(clipLeft - left, 0.0, size.x), wr = clamp(clipRight - left, 0.0, size.x);
		if (wr <= wl) { return; }
		Screen.DrawTexture(tex, false, left, cy - size.y * 0.5,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true,
			DTA_Alpha, alpha,
			DTA_WindowLeftF, wl,
			DTA_WindowRightF, wr);
	}

	// Score_ScaleRes: scale = middle(25, scale, 400); round(res * 100 / scale).
	static ui double SScaleRes(int res, int scale)
	{
		scale = clamp(scale, 25, 400);
		return round(res * 100.0 / scale);
	}

	// Score_ScaledCoord, with the downshift term the first pass dropped:
	//   saferange = range - (range > padding ? padding : 0)
	//   saferange * (clamp(pos,0,100)/100) + (range - saferange)/2 - downshift/2
	static ui double SScaledCoord(int pos, double range, double padding, double downshift)
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

	static ui int SUserInt(int pln, String name, int fallback)
	{
		let cv = CVar.GetCVar(name, players[pln]);
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
