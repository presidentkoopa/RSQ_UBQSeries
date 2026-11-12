// RSQ HP Bars -- Damage Numbers: one thing in the air (a hit, a running total with its combo, a gain on you, the player
// level-up band, a weapon level-up tag), laid out as glyphs. Moved by RSQTHP_DamNumHandler.Step once a tic (no thinker of
// its own); its glyphs come from the handler's pool.
//
// LAYOUT. Every glyph belongs to a PART (the digits, the combo "xN", a word, the band, a line of the tag ...). A glyph's x / y
// / height are world units at size 1 about its part's centre; Draw places each part (where it stands, its own scale, alpha
// and shake) and the handler's palette colours each glyph. A glyph can have its own appearance time (t0: the tag types its
// letters in, each one flashing white on arrival).
class RSQTHP_DnNum play
{
	enum EKind { K_HIT, K_TOTAL, K_GAIN, K_BANNER, K_TAG, K_SEQ }   // K_SEQ: RSQ SlowMo's DOWN time added "+0.5s" (rsqvr/down.zs)
	enum EState { S_LIVE, S_KILL, S_FLY, S_LAND, S_DONE }
	enum EWord { W_HEAD = 1, W_OVERKILL = 2 }
	enum EPart { P_DIG, P_COMBO, P_WORD, P_SUB1, P_SUB2, P_BG, P_BORDER, P_NAME, P_LV, P_NEW, P_SWEEP }
	enum ETex { T_GLYPH, T_BAND, T_TAGF, T_TAGB, T_SWEEP }

	int kind, st;
	Actor who;                  // the monster it is about (hits, totals)
	int value;                  // the number shown (a total counts up to it)
	double shown;               // a total's roll-up
	int hits;                   // a total's combo (hits in the chain)
	int nHits;                  // a hit: how many hits it stands for (pellets in one tic)
	double bumpT;               // a total: its clock at the last hit (the bounce)
	int words;
	bool kill, crit, head;      // crit: the after-2.0 hook (RSQTHP_DnService "crit"); nothing drawn for it yet
	int fam;                    // the digits' colour (palette index)
	int famWord;                // a hit's word (HEADSHOT gold, OVERKILL red)
	Array<int> ramp;            // a total: its combo colour ramp (4 steps), picked when the chain starts
	Name trans;                 // damnums' colours (Hit Colours "damnums'") and the gains: a translation by name
	double size;                // a hit: 1, x1.35 for a headshot (x Size by Hit); RSQ SlowMo's DOWN REVIVE word: its tier's size
	int dur;                    // a banner's life in tics (0: BANNER_DUR); RSQ SlowMo's DOWN REVIVE word: its tier's life
	double t;                   // its own clock, tics (world or your time in slow motion; stands still in a hit-stop)
	double stT;                 // the clock when its state began
	int born, lastHit;          // level tics: when made, a total's last hit (its chain window)
	bool frozen;                // held in a hit-stop: stands still, unpopped, until its monster's freezetics runs out
	double popFrom;             // the pop's start size (0.45; 0.9 after a hit-stop held it)
	bool hidden;                // beyond the nearest N
	int gainKind;               // a gain: 0 health, 1 armour, 2 ammo
	int hand;                   // a gain / a tag: the hand
	bool landOnCards;           // a gain: RSQ Gun Cards is loaded and shows its own +N there
	int level;                  // a banner / a tag: the level reached
	String label;               // a tag: the gun's name; DOWN's time added: "+0.5s"; a banner: REVENGE / REVIVE (RSQ SlowMo's DOWN), else LEVEL UP
	bool special;               // RSQ SlowMo's DOWN (the time added, the words): the headshot's life (flash, colour cycling,
	                            // bobbing letters) and your time, not the world's (DOWN slows the world to 5%)
	bool slowSent;              // a banner: its slow-motion pulse has gone out
	bool jet;                   // a normal hit: launched as a little fountain jet (events.zs PlaceJet)
	Vector3 vel, jetPos;        // ... its velocity and where it is (map units, per tic)
	double spin, roll;          // ... its spin (degrees per tic) and roll
	double grav;                // ... its gravity scale (Number Size)

	// where it is
	Vector3 p0;                 // a hit / gain: where it appeared; a banner / tag: where it is anchored (eased)
	Vector3 at, atPrev;         // this tic's anchor and last tic's (glyph Pos / Prev)
	Vector3 arcR;               // a hit: the world direction it arcs out along (the view's right when it was made, x side)
	double arcOut, arcUp;       // a hit: how far out and up it may go (kept clear of walls and the ceiling)
	int lane;                   // a hit: its lane (successive hits on one monster alternate sides and step outward)
	double rise;                // a gain: how far it has drifted up
	Vector3 flyAt; double flyScale;   // where a gain's flight began
	Vector3 slide;              // pushed out of the aim line (eased)
	double tossVX, tossVY, tossVZ, tossX, tossY, tossZ;   // Pop off: damnums' toss / float, integrated on its clock
	double alpha, scaleNow, dist;
	double bandD;               // a banner: its distance from the eyes (map units)
	// a total: where its parts go (worked out from its bar and the room every few tics)
	int comboSide;              // +1 right of the bar, -1 left (a wall on the right)
	int totalMode;              // 0 centred above the bar, 1 beside it (a low ceiling), 2 under it
	int roomAt;

	// the layout: one entry per glyph
	Array<RSQTHP_Glyph> gl;
	Array<int> gCode, gFont, gPart, gFam, gTex;
	Array<double> gX, gY, gH, gW, gT0;
	double width, height;       // the digits' row at size 1
	double comboW, comboH;      // the combo's row at size 1
	int laidValue, laidHits, laidWords, laidFont, laidQ;
	bool laidOut;
	bool drawn;

	void Free(RSQTHP_DamNumHandler hnd)
	{
		for (int i = 0; i < gl.Size(); i++) hnd.Release(gl[i]);
		gl.Clear();
		st = S_DONE;
	}

	void ClearLayout()
	{
		gCode.Clear(); gFont.Clear(); gPart.Clear(); gFam.Clear(); gTex.Clear();
		gX.Clear(); gY.Clear(); gH.Clear(); gW.Clear(); gT0.Clear();
	}

	void Add(int c, int f, double x, double y, double hh, int part, int fm = -1, double t0 = -1, int tex = T_GLYPH, double w = 0)
	{
		gCode.Push(c); gFont.Push(f); gX.Push(x); gY.Push(y); gH.Push(hh); gPart.Push(part); gFam.Push(fm); gT0.Push(t0);
		gTex.Push(tex); gW.Push(w);
	}

	// AddText's width for a string, nothing added (its glyph fallbacks the same)
	double Measure(RSQTHP_DamNumHandler hnd, String s, int font, double H)
	{
		double tot = 0;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int c = s.ByteAt(i);
			if (c >= 97 && c <= 122) c -= 32;
			int f = font;
			double w, gh;
			TextureID tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh);
			if ((!tx.IsValid() || gh <= 0) && f != RSQTHP_DnFonts.F_JFO) { f = RSQTHP_DnFonts.F_JFO; tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh); }
			if ((!tx.IsValid() || gh <= 0) && f != RSQTHP_DnFonts.F_SMALL) { f = RSQTHP_DnFonts.F_SMALL; tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh); }
			double ww = (tx.IsValid() && gh > 0) ? w * (H / gh) : 0;
			tot += ww > 0 ? ww * RSQTHP_DnFonts.ADV[f] : H * 0.45;
		}
		return tot;
	}

	// one line of text centred on (cx, y): returns its width. step > 0 types it in, one letter every `step` tics from t0.
	// Letters the font lacks (and spaces) keep their advance. Lower case is drawn upper case.
	double AddText(RSQTHP_DamNumHandler hnd, String s, int font, double cx, double y, double H, int part, int fm = -1, double t0 = -1, double step = 0)
	{
		Array<int> rc; Array<int> rf; Array<double> rw;
		double tot = 0;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int c = s.ByteAt(i);
			if (c >= 97 && c <= 122) c -= 32;
			int f = font;
			double w, gh;
			TextureID tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh);
			if ((!tx.IsValid() || gh <= 0) && f != RSQTHP_DnFonts.F_JFO) { f = RSQTHP_DnFonts.F_JFO; tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh); }
			if ((!tx.IsValid() || gh <= 0) && f != RSQTHP_DnFonts.F_SMALL) { f = RSQTHP_DnFonts.F_SMALL; tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh); }
			double ww = (tx.IsValid() && gh > 0) ? w * (H / gh) : 0;
			double adv = ww > 0 ? ww * RSQTHP_DnFonts.ADV[f] : H * 0.45;
			rc.Push(ww > 0 ? c : 0); rf.Push(f); rw.Push(adv);
			tot += adv;
		}
		double x = cx - tot / 2;
		int k = 0;
		for (int i = 0; i < rc.Size(); i++)
		{
			if (rc[i]) Add(rc[i], rf[i], x + rw[i] / 2, y, H, part, fm, step > 0 ? t0 + k * step : t0);
			if (rc[i]) k++;
			x += rw[i];
		}
		return tot;
	}

	// what to draw
	void Layout(RSQTHP_DamNumHandler hnd)
	{
		int v = kind == K_TOTAL ? int(shown) : value;
		int hs = kind == K_TOTAL ? hits : 0;
		if (laidOut && v == laidValue && hs == laidHits && words == laidWords && hnd.face == laidFont && hnd.q == laidQ) return;
		if (laidOut && (kind == K_BANNER || kind == K_TAG) && hnd.q == laidQ) return;
		laidOut = true; laidValue = v; laidHits = hs; laidWords = words; laidFont = hnd.face; laidQ = hnd.q;
		ClearLayout();
		int font = hnd.face;
		double H = RSQTHP_DnFonts.BASEH[font];
		switch (kind)
		{
		case K_HIT:
		case K_GAIN:
		{
			String s = String.Format("%d", max(0, v));
			if (kind == K_GAIN) s = "+" .. s;
			width = AddText(hnd, s, font, 0, 0, H, P_DIG);
			height = H;
			double wy = H / 2 + H * 0.12;
			if (words & W_OVERKILL) wy = AddWord(hnd, "OVERKILL", wy, H, 5);
			if (words & W_HEAD) wy = AddWord(hnd, "HEADSHOT", wy, H, famWord);
			break;
		}
		case K_TOTAL:
			// the digits (centred above the bar), the combo (beside it), OVERKILL over the digits; parts placed in Draw
			width = AddText(hnd, String.Format("%d", max(0, v)), font, 0, 0, H, P_DIG);
			height = H;
			comboH = H * 0.62 * hnd.wordSize;     // a word: Word Size
			comboW = 0;
			if (hs >= 2) comboW = AddText(hnd, String.Format("X%d", hs), font, 0, 0, comboH, P_COMBO);
			if (words & W_OVERKILL) AddWord(hnd, "OVERKILL", H / 2 + H * 0.12, H, 5);
			break;
		case K_SEQ:
			// RSQ SlowMo's DOWN time added: "+0.5s" in the numbers' font; the unit "s" set small on the baseline (the
			// fonts have capitals only: a full-height S read as a 5 on the rig)
			if (label.Length() > 1 && label.Mid(label.Length() - 1, 1) == "s")
			{
				String num = label.Left(label.Length() - 1);
				double hs = H * 0.6;
				double w1 = Measure(hnd, num, font, H), w2 = Measure(hnd, "S", font, hs);
				double tot = w1 + w2;
				AddText(hnd, num, font, -tot / 2 + w1 / 2, 0, H, P_DIG);
				AddText(hnd, "S", font, tot / 2 - w2 / 2, -(H - hs) / 2, hs, P_DIG);
				width = tot;
			}
			else width = AddText(hnd, label, font, 0, 0, H, P_DIG);
			height = H;
			break;
		case K_BANNER:
		{
			if (label == "REVIVE" || label == "REVENGE")
			{
				// RSQ SlowMo's DOWN words (owner 11-06 v2; v3 11-07: REVIVE every time, sized by tier; no RAGE): the level-up band, the word in the damage numbers' font (JFO),
				// each its own colour (events.zs DownWord)
				Add(0, 0, 0, 0, 14, P_BG, -2, -1, T_BAND, 1.0);
				AddText(hnd, label, RSQTHP_DnFonts.F_JFO, 0, 0.4, 7.0, P_DIG);
				width = max(24, 40 * label.Length() / 6); height = 14;
				break;
			}
			// at 64 map units from the eyes, Word Size 1 (LEVEL UP 4.5 degrees tall, the lines under it 2 and 1.7); Draw
			// scales it with its real distance (kept out of walls) and Word Size
			Add(0, 0, 0, 0, 14, P_BG, -2, -1, T_BAND, 1.0);   // the band: width filled in by Draw (the view's width)
			AddText(hnd, "LEVEL UP", RSQTHP_DnFonts.F_SMALL, 0, 1.7, 5.0, P_DIG);
			AddText(hnd, String.Format("PLAYER LV %d", level), RSQTHP_DnFonts.F_SMALL, 0, -2.9, 2.2, P_SUB1, 0);
			AddText(hnd, "+1 UPGRADE", RSQTHP_DnFonts.F_SMALL, 0, -5.3, 1.9, P_SUB2, 15);
			width = 40; height = 14;
			break;
		}
		case K_TAG:
		{
			// a small tag at the gun: its name typed in (a white flash per letter), "LV n" with one punch, NEW UPGRADE
			double nw = AddText(hnd, label, RSQTHP_DnFonts.F_SMALL, 0, 2.3, 1.3, P_NAME, 0, 2, 1);
			AddText(hnd, String.Format("LV %d", level), RSQTHP_DnFonts.F_JFO, 0, -0.2, 2.6, P_LV, -1, 6);
			double uw = AddText(hnd, "NEW UPGRADE", RSQTHP_DnFonts.F_SMALL, 0, -2.6, 1.0, P_NEW, 15, 14, 1);
			double bw = max(9.0, max(nw, uw) + 2.4);
			Add(0, 0, 0, 0, 7.6, P_BG, -2, -1, T_TAGF, bw);
			Add(0, 0, 0, 0, 7.6, P_BORDER, -1, -1, T_TAGB, bw);
			// THE CLEAN SWEEP (owner 11-12 03:58, mockup A1: "clean sweep, thinner line, faster"): one thin white line that
			// crosses the card once as LV n lands (events.zs Draw, SWEEP_T0 / SWEEP_TICS)
			Add(0, 0, 0, 0, 7.0, P_SWEEP, -1, -1, T_SWEEP, 0.35);
			width = bw; height = 7.6;
			break;
		}
		}
	}

	double AddWord(RSQTHP_DamNumHandler hnd, String wd, double y, double H, int fm)
	{
		double rh = H * 0.42 * hnd.wordSize;
		AddText(hnd, wd, RSQTHP_DnFonts.F_SMALL, 0, y + rh / 2, rh, P_WORD, fm);
		return y + rh * 1.1;
	}

	// fit the pool's glyphs to the layout; false: the pool is out of glyphs
	bool Fit(RSQTHP_DamNumHandler hnd)
	{
		while (gl.Size() > gCode.Size()) { hnd.Release(gl[gl.Size() - 1]); gl.Pop(); }
		while (gl.Size() < gCode.Size())
		{
			let g = hnd.Acquire(at);
			if (!g) return false;
			g.Prev = at; g.Pos = at;
			gl.Push(g);
		}
		return true;
	}

	// a total's combo step (the mockup's ramp: x1-2, x3-4, x5, x6+)
	int ComboStep() { return hits <= 2 ? 0 : (hits <= 4 ? 1 : (hits == 5 ? 2 : 3)); }
}
