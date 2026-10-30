// wr_q_look.zs -- RSQ Wheel: swappable palettes and font sets, read from lumps.
//
// PALETTES (lump WRPALS, every one loaded, later lumps win on a name they share):
//
//     palette Doom
//     {
//         hover  D9A441        // role, then the colour as RRGGBB
//         slot2  E0C050
//     }
//
// A role is one of the ring's own colours by name (ROLES below); a role a palette leaves out
// keeps the ring's colour. wr_palette names the palette in use ("Standard" is the ring as REMA
// coloured it). Roles that share a colour in the ring move together: hover and sheet_hot are the
// same orange, slot4 and sheet_cool the same blue.
//
// FONT SETS (lump WRFONTS):
//
//     fontset StatusBar { words WRG 9 7  numbers WRD 14 16 }
//
// words / numbers: the TEXTURES cell prefix (cells named <prefix><3-digit character code>,
// e.g. WRG065 for 'A') and the cell's width and height in pixels. tools/gen_assets.py writes
// cells from any WAD font lumps; wr_fontset names the set in use.
//
// Both are looked up by name when the ring opens, so a pk3 that adds a palette or a font set
// only has to carry its WRPALS / WRFONTS lump (and, for a font, its TEXTURES cells).

class wr_Look play
{
	// The ring's colours, by role. Defaults are the constants in zscript.zs (wr_Rig).
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
	const LASER_ROLE = 33;

	// the palette and font set in force, and what they were built from
	private static wr_LookState St()
	{
		let h = wr_VRState.Get();
		if (!h) return null;
		if (!h.mLook) h.mLook = new("wr_LookState");
		if (h.mLook.mTic != level.maptime || !h.mLook.mBuilt) { h.mLook.mTic = level.maptime; h.mLook.Refresh(); }
		return h.mLook;
	}

	// A colour as the palette has it.
	static color Col(color c)
	{
		let s = St();
		if (!s) return c;
		int key = (c.r << 16) | (c.g << 8) | c.b;
		for (int i = 0; i < s.mFrom.Size(); i++) if (s.mFrom[i] == key) return color(255, (s.mTo[i] >> 16) & 255, (s.mTo[i] >> 8) & 255, s.mTo[i] & 255);
		return c;
	}

	static color Laser() { return Col(wr_Look.ROLE_COLS[wr_Look.LASER_ROLE]); }

	static string WordPrefix() { let s = St(); return (s && s.mWordPfx != "") ? s.mWordPfx : "WRG"; }
	static string NumPrefix()  { let s = St(); return (s && s.mNumPfx != "") ? s.mNumPfx : "WRD"; }
	static double WordAspect() { let s = St(); return (s && s.mWordAsp > 0) ? s.mWordAsp : 9.0 / 7.0; }
	static double NumAspect()  { let s = St(); return (s && s.mNumAsp > 0) ? s.mNumAsp : 14.0 / 16.0; }
}

class wr_LookState play
{
	string mPalName, mFontName;    // what this was built for
	bool   mBuilt;
	int    mTic;                   // the cvars are looked at once a tic, not once a quad
	Array<int> mFrom, mTo;
	string mWordPfx, mNumPfx;
	double mWordAsp, mNumAsp;

	void Refresh()
	{
		let pc = CVar.FindCVar('wr_palette');
		let fc = CVar.FindCVar('wr_fontset');
		string pn = pc ? pc.GetString() : "Standard";
		string fn = fc ? fc.GetString() : "StatusBar";
		if (mBuilt && pn ~== mPalName && fn ~== mFontName) return;
		mPalName = pn; mFontName = fn; mBuilt = true;
		mFrom.Clear(); mTo.Clear();
		mWordPfx = ""; mNumPfx = ""; mWordAsp = 0; mNumAsp = 0;
		ReadBlocks("WRPALS", "palette", pn, true);
		ReadBlocks("WRFONTS", "fontset", fn, false);
		let dbg = CVar.FindCVar('wr_debug');
		if (dbg && dbg.GetBool())
			Console.Printf("RSQ Wheel look: palette %s (%d roles), font set %s (words %s, numbers %s)",
				pn, mFrom.Size(), fn, mWordPfx == "" ? "WRG" : mWordPfx, mNumPfx == "" ? "WRD" : mNumPfx);
	}

	// Every lump of that name; inside each, the block "<kw> <name> { ... }" that matches.
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
					// a later lump's block for the same name replaces the earlier one
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
		for (int r = 0; r < wr_Look.ROLES.Size(); r++)
		{
			if (!(wr_Look.ROLES[r] ~== role)) continue;
			int to = hex.ToInt(16);
			int from = wr_Look.ROLE_COLS[r];
			int k = mFrom.Find(from);
			if (k < mFrom.Size()) mTo[k] = to;
			else { mFrom.Push(from); mTo.Push(to); }
			return;
		}
	}

	// Words, braces, and nothing else: // comments dropped, whitespace splits.
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
