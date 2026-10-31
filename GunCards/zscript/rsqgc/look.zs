// look.zs -- RSQ Gun Cards: the colours and fonts the cards use, the Wheel's way, without needing the Wheel.
//
// A copy of RSQ Wheel's wr_q_look.zs (palettes from WRPALS lumps, font sets from WRFONTS lumps). With RSQ Wheel
// loaded its palette (wr_palette), font set (wr_fontset) and plate art (wr_ring_art) are followed, so the cards
// keep looking like the ring; with it absent there are no such cvars or lumps, and the cards use their own art:
// the Standard palette, DoomFont words (GCG cells) and Ermac's digits (GCE cells), his plate (GCEPLATE).

class RSQGC_Look play
{
	// The Wheel's colours, by role (only roles the cards use are read by number below).
	static const string ROLES[] =
	{
		"idle", "hover", "label", "sub", "beam_idle", "dry", "ammo", "ammo_dry", "alt_bar",
		"mark_mine", "mark_other", "slotnum", "stack",
		"slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8", "slot9",
		"sheet_bg", "sheet_bg2", "sheet_accent", "sheet_text", "sheet_dim", "sheet_hot", "sheet_cool",
		"sheet_meas", "sheet_lock", "delta_up", "delta_down", "laser"
	};
	static const int ROLE_COLS[] =
	{
		0x2E3440, 0xEF9F27, 0xD8DEE9, 0x4A3A20, 0x5A6C7A, 0x3A2226, 0x8C97A8, 0xC65C5C, 0x4FA3D1,
		0x6E7684, 0xEFC94C, 0x5F6874, 0xC98A3A,
		0x8A8F98, 0xE8C547, 0xE07A3E, 0x4FA3D1, 0xD1503F, 0x7B5FD1, 0x3FBF6F, 0xD14F9B, 0x46C6C0,
		0x0E1016, 0x1B2030, 0x7F77DD, 0xE8EAF0, 0x8D93A3, 0xEF9F27, 0x4FA3D1,
		0x5DCAA5, 0xBE3E4E, 0x66DD66, 0xDD5555, 0xFF3030
	};
	const R_AMMO = 6;
	const R_AMMO_DRY = 7;
	const R_SHEET_ACCENT = 24;

	private static RSQGC_LookState St()
	{
		let h = RSQGC_GunCard.Get();
		if (!h) return null;
		if (!h.mLook) h.mLook = new("RSQGC_LookState");
		if (h.mLook.mTic != level.maptime || !h.mLook.mBuilt) { h.mLook.mTic = level.maptime; h.mLook.Refresh(); }
		return h.mLook;
	}

	// A colour as the palette in force has it.
	static color Col(color c)
	{
		let s = St();
		if (!s) return c;
		int key = (c.r << 16) | (c.g << 8) | c.b;
		for (int i = 0; i < s.mFrom.Size(); i++) if (s.mFrom[i] == key) return color(255, (s.mTo[i] >> 16) & 255, (s.mTo[i] >> 8) & 255, s.mTo[i] & 255);
		return c;
	}
	static color Role(int r) { return Col(RSQGC_Look.ROLE_COLS[r]); }

	// The Wheel's font set when it names one; otherwise our own cells.
	static string WordPrefix() { let s = St(); return (s && s.mWordPfx != "") ? s.mWordPfx : "GCG"; }
	static string NumPrefix()  { let s = St(); return (s && s.mNumPfx != "") ? s.mNumPfx : "GCE"; }
	static double WordAspect() { let s = St(); return (s && s.mWordAsp > 0) ? s.mWordAsp : 9.0 / 7.0; }
	static double NumAspect()  { let s = St(); return (s && s.mNumAsp > 0) ? s.mNumAsp : 1.0; }

	// The plate: the Wheel's (wr_ring_art 1: the status bar's stone) when it is loaded, else Ermac's.
	static string Plate(bool strip)
	{
		let c = CVar.FindCVar("wr_ring_art");
		bool sbar = c && c.GetInt() == 1;
		if (strip) return sbar ? "GCSTONE" : "GCESTONE";
		return sbar ? "GCPLATE" : "GCEPLATE";
	}
}

class RSQGC_LookState play
{
	string mPalName, mFontName;
	bool   mBuilt;
	int    mTic;
	Array<int> mFrom, mTo;
	string mWordPfx, mNumPfx;
	double mWordAsp, mNumAsp;

	void Refresh()
	{
		let pc = CVar.FindCVar('wr_palette');
		let fc = CVar.FindCVar('wr_fontset');
		string pn = pc ? pc.GetString() : "Standard";
		string fn = fc ? fc.GetString() : "";
		if (mBuilt && pn ~== mPalName && fn ~== mFontName) return;
		mPalName = pn; mFontName = fn; mBuilt = true;
		mFrom.Clear(); mTo.Clear();
		mWordPfx = ""; mNumPfx = ""; mWordAsp = 0; mNumAsp = 0;
		ReadBlocks("WRPALS", "palette", pn, true);
		if (fn != "") ReadBlocks("WRFONTS", "fontset", fn, false);
	}

	private void ReadBlocks(string lumpName, string kw, string want, bool isPalette)
	{
		int lump = -1;
		while ((lump = Wads.FindLump(lumpName, lump + 1)) != -1)
		{
			Array<string> tok;
			Tokens(Wads.ReadLump(lump), tok);
			for (int i = 0; i + 2 < tok.Size(); i++)
			{
				if (!(tok[i] ~== kw) || !(tok[i + 1] ~== want) || tok[i + 2] != "{") continue;
				int j = i + 3;
				if (isPalette)
				{
					mFrom.Clear(); mTo.Clear();
					for (; j + 1 < tok.Size() && tok[j] != "}"; j += 2) SetRole(tok[j], tok[j + 1]);
				}
				else
				{
					for (; j + 3 < tok.Size() && tok[j] != "}"; j += 4)
					{
						double asp = tok[j + 3].ToDouble() > 0 ? tok[j + 2].ToDouble() / tok[j + 3].ToDouble() : 0;
						if (tok[j] ~== "words")   { mWordPfx = tok[j + 1]; mWordAsp = asp; }
						if (tok[j] ~== "numbers") { mNumPfx = tok[j + 1];  mNumAsp = asp; }
					}
				}
				i = j;
			}
		}
	}

	private void SetRole(string role, string hex)
	{
		for (int r = 0; r < RSQGC_Look.ROLES.Size(); r++)
		{
			if (!(RSQGC_Look.ROLES[r] ~== role)) continue;
			int to = hex.ToInt(16);
			int from = RSQGC_Look.ROLE_COLS[r];
			int k = mFrom.Find(from);
			if (k < mFrom.Size()) mTo[k] = to;
			else { mFrom.Push(from); mTo.Push(to); }
			return;
		}
	}

	private static void Tokens(string text, out Array<string> tok)
	{
		Array<string> lines;
		text.Split(lines, "\n");
		for (int l = 0; l < lines.Size(); l++)
		{
			string ln = lines[l];
			int c = ln.IndexOf("//");
			if (c >= 0) ln = ln.Left(c);
			ln.Replace("\t", " "); ln.Replace("\r", " ");
			ln.Replace("{", " { "); ln.Replace("}", " } ");
			Array<string> words;
			ln.Split(words, " ", TOK_SKIPEMPTY);
			for (int w = 0; w < words.Size(); w++) tok.Push(words[w]);
		}
	}
}
