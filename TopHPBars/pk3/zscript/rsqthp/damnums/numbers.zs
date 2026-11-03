// RSQ HP Bars -- Damage Numbers: one number in the air (a hit, a running total, a gain on you), laid out as glyphs.
// Moved by RSQTHP_DamNumHandler.Step once a tic (no thinker of its own); its glyphs come from the handler's pool.
class RSQTHP_DnNum play
{
	enum EKind { K_HIT, K_TOTAL, K_GAIN }
	enum EState { S_LIVE, S_FLY, S_SLAM, S_BREAK, S_LAND, S_DONE }
	enum EWord { W_HEAD = 1, W_OVERKILL = 2 }

	int kind, st;
	Actor who;                  // the monster it is about (hits, totals)
	int value;                  // the number shown (a total counts up to it)
	double shown;               // a total's count-up
	int arrived;                // a total: what has flown in so far (the count-up runs to it; a kill sets it to value)
	int hits, hitsShown;        // a total's xN (true count, count shown)
	int nHits;                  // a hit: how many hits it stands for (pellets in one tic)
	double bumpT;               // a total: the clock when a hit last flew in (it swells for 2 tics)
	double rise;                // a hit / gain: how far it has drifted up
	Vector3 flyAt; double flyShift, flyScale;   // where a flight began
	int words;
	bool kill, crit, head;      // crit: the after-2.0 hook (RSQTHP_DnService "crit"); nothing drawn for it yet
	Name trans;                 // the digits' colour
	double size;                // size by hit (1 = a plain hit)
	double t;                   // its own clock, tics (world or your time in slow motion; stands still in a hit-stop)
	double stT;                 // the clock when its state began
	int born, lastHit;          // level tics: when made, a total's last hit (its 3 s chain)
	bool frozen;                // held in a hit-stop: stands still, unpopped, until its monster's freezetics runs out
	double popFrom;             // the pop's start size (0.35; 0.9 after a hit-stop held it)
	bool hidden;                // beyond the nearest N
	int amount;                 // a hit flying into a total: what it adds on arrival
	RSQTHP_DnNum into;          // ... and the total it flies into
	int gainKind;               // a gain: 0 health, 1 armour, 2 ammo
	int hand;                   // a gain: the hand it flies to
	bool landOnCards;           // a gain: RSQ Gun Cards is loaded and shows its own +N there

	// where it is
	Vector3 p0;                 // a hit / gain: where it appeared; a total: unused (it stands on its monster's bar)
	Vector3 at, atPrev;         // this tic's anchor and last tic's (glyph Pos / Prev)
	double shiftX;              // sideways shift of the whole number, world units (a total beside the bar)
	double jitX;                // a hit: a small sideways spread so stacked hits do not overlap exactly
	Vector3 slide;              // pushed out of the aim line (eased)
	double tossVX, tossVY, tossVZ, tossX, tossY, tossZ;   // Pop off: damnums' toss / float, integrated on its clock
	double alpha, scaleNow, dist;

	// the layout, at size 1 (world units): one entry per glyph
	Array<RSQTHP_Glyph> gl;
	Array<int> gCode, gFont;
	Array<double> gX, gY, gH;   // centre and row height
	Array<Name> gTrans;
	Array<double> bX, bY, bVX, bVY, bVZ, bZ, bRoll, bSpin;   // breaking apart
	double width, height;       // extent of the digits' row at size 1
	int laidValue, laidHits, laidWords, laidFont, laidQ;
	bool laidOut;
	bool drawn;                 // drawn at least once (glyph Prev = last tic's spot)

	void Free(RSQTHP_DamNumHandler hnd)
	{
		for (int i = 0; i < gl.Size(); i++) hnd.Release(gl[i]);
		gl.Clear();
		st = S_DONE;
	}

	// what to draw: digits, then "xN" for a total, words above
	void Layout(RSQTHP_DamNumHandler hnd)
	{
		int v = kind == K_TOTAL ? int(shown) : value;
		int hs = kind == K_TOTAL ? hitsShown : 0;
		if (laidOut && v == laidValue && hs == laidHits && words == laidWords && hnd.face == laidFont && hnd.q == laidQ) return;
		laidOut = true; laidValue = v; laidHits = hs; laidWords = words; laidFont = hnd.face; laidQ = hnd.q;
		gCode.Clear(); gFont.Clear(); gX.Clear(); gY.Clear(); gH.Clear(); gTrans.Clear();

		int font = hnd.face;
		double H = RSQTHP_DnFonts.BASEH[font];
		String s = String.Format("%d", max(0, v));
		if (kind == K_GAIN) s = "+" .. s;
		// the digits' row, centred on 0
		Array<int> rc; Array<int> rf; Array<double> rw;
		double x = 0;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int c = s.ByteAt(i);
			int f = font;
			double w, gh;
			TextureID tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh);
			if (!tx.IsValid() || gh <= 0) { f = RSQTHP_DnFonts.F_JFO; tx = hnd.fonts.Glyph(f, hnd.q, c, w, gh); }   // damnums' fonts have no "+"
			if (!tx.IsValid() || gh <= 0) continue;
			double ww = w * (H / gh);
			rc.Push(c); rf.Push(f); rw.Push(ww);
			x += ww * RSQTHP_DnFonts.ADV[f];
		}
		double rowW = x;
		x = -rowW / 2;
		for (int i = 0; i < rc.Size(); i++)
		{
			double adv = rw[i] * RSQTHP_DnFonts.ADV[rf[i]];
			Add(rc[i], rf[i], x + adv / 2, 0, H, 'None');     // 'None': the number's own colour, read as it is drawn
			x += adv;
		}
		width = rowW; height = H;
		// a total's hit counter, small, after the digits and on their baseline
		if (hs >= 2)
		{
			String cs = String.Format("X%d", hs);
			double ch = H * 0.5;
			double cx = rowW / 2 + H * 0.08;
			for (int i = 0; i < int(cs.Length()); i++)
			{
				int c = cs.ByteAt(i);
				double w, gh;
				TextureID tx = hnd.fonts.Glyph(RSQTHP_DnFonts.F_SMALL, hnd.q, c, w, gh);
				if (!tx.IsValid() || gh <= 0) continue;
				double ww = w * (ch / gh), adv = ww * RSQTHP_DnFonts.ADV[RSQTHP_DnFonts.F_SMALL];
				Add(c, RSQTHP_DnFonts.F_SMALL, cx + adv / 2, -H / 2 + ch / 2, ch, 'RSQTHP_DnCount');
				cx += adv;
			}
			width = rowW + 2 * (cx - rowW / 2);      // keep it centred in the extent the comfort pass reads
		}
		// words above the digits, the top one first: HEADSHOT over OVERKILL
		double wy = H / 2 + H * 0.12;
		if (words & W_OVERKILL) wy = AddWord(hnd, "OVERKILL", wy, H, 'RSQTHP_DnOverkill');
		if (words & W_HEAD) wy = AddWord(hnd, "HEADSHOT", wy, H, 'RSQTHP_DnHead');
	}

	double AddWord(RSQTHP_DamNumHandler hnd, String wd, double y, double H, Name tr)
	{
		double rh = H * 0.5;
		double tot = 0;
		Array<double> ws;
		for (int i = 0; i < int(wd.Length()); i++)
		{
			double w, gh;
			hnd.fonts.Glyph(RSQTHP_DnFonts.F_SMALL, hnd.q, wd.ByteAt(i), w, gh);
			double ww = gh > 0 ? w * (rh / gh) : 0;
			ws.Push(ww);
			tot += ww * RSQTHP_DnFonts.ADV[RSQTHP_DnFonts.F_SMALL];
		}
		double x = -tot / 2;
		for (int i = 0; i < int(wd.Length()); i++)
		{
			double adv = ws[i] * RSQTHP_DnFonts.ADV[RSQTHP_DnFonts.F_SMALL];
			if (ws[i] > 0) Add(wd.ByteAt(i), RSQTHP_DnFonts.F_SMALL, x + adv / 2, y + rh / 2, rh, tr);
			x += adv;
		}
		return y + rh * 1.1;
	}

	void Add(int c, int f, double x, double y, double hh, Name tr)
	{
		gCode.Push(c); gFont.Push(f); gX.Push(x); gY.Push(y); gH.Push(hh); gTrans.Push(tr);
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

	// start breaking apart: every glyph flies off on its own, spinning, and fades
	void StartBreak()
	{
		st = S_BREAK; stT = t;
		bX.Clear(); bY.Clear(); bVX.Clear(); bVY.Clear(); bVZ.Clear(); bZ.Clear(); bRoll.Clear(); bSpin.Clear();
		for (int i = 0; i < gCode.Size(); i++)
		{
			double side = gX[i] >= 0 ? 1 : -1;
			bX.Push(0); bY.Push(0); bZ.Push(0); bRoll.Push(0);
			bVX.Push(side * frandom[rsqthpdn](0.4, 1.4) + gX[i] * 0.06);
			bVY.Push(frandom[rsqthpdn](0.6, 1.8));
			bVZ.Push(0);
			bSpin.Push(frandom[rsqthpdn](6, 16) * (frandom[rsqthpdn](0, 1) < 0.5 ? -1 : 1));
		}
	}
}
