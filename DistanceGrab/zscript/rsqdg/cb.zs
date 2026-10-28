// RSQDG_CB -- the series' colour-blind palette, read from RSQ_Accessibility's rsqa_colorblind.
// The same table sits in every Radiant Silvergun Quest mod under its own prefix (RSQ_Accessibility,
// tools/cb_template.zs), so a cue means the same colour across the series and each mod still
// loads alone: without RSQ_Accessibility the setting reads 0 and every cue keeps its own colour.
//
//   rsqa_colorblind  0 Off, 1 Protanopia, 2 Deuteranopia, 3 Tritanopia, 4 High Contrast
//
// Roles, not colours: IDLE (searching, nothing found), COULD (noticed, would take it), HAVE
// (taken, locked, yours). A pair of anything (two hands, two bars) uses HAVE and COULD.
//   protan/deutan  grey D0D0D0, amber FFB000, azure 3090FF  (the blue-yellow axis they keep)
//   tritan         grey D0D0D0, red FF4040, cyan 00E0E0     (the red-cyan axis they keep)
//   high contrast  dim grey 8C8C8C, yellow FFFF00, magenta FF40FF (the widest brightness gaps)
// Measured with tools/cvd.py (Machado 2009 / Vienot 1999, CIEDE2000): every pair >= 24 in the
// vision it is for; the stock amber/green pair is 7.5 for deuteranopia.
class RSQDG_CB
{
	enum ERole { CB_IDLE, CB_COULD, CB_HAVE }

	static clearscope int Mode()
	{
		CVar cv = null; { Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN; if (rsqaC) cv = CVar.FindCVar("rsqa_colorblind"); }  // only while RSQ_Accessibility is loaded: a value left in the ini must not act on its own
		return cv ? clamp(cv.GetInt(), 0, 4) : 0;
	}

	// 0xRRGGBB for a role in a mode (1..4).
	static clearscope int Rgb(int role, int mode)
	{
		static const int T[] = {
			0xD0D0D0, 0xFFB000, 0x3090FF,   // 1 protanopia
			0xD0D0D0, 0xFFB000, 0x3090FF,   // 2 deuteranopia
			0xD0D0D0, 0xFF4040, 0x00E0E0,   // 3 tritanopia
			0x8C8C8C, 0xFFFF00, 0xFF40FF    // 4 high contrast
		};
		return T[(clamp(mode, 1, 4) - 1) * 3 + clamp(role, 0, 2)];
	}

	// For lump-defined looks (TRNSLATE, TEXTCOLO): "" off, "_PD", "_T" or "_HC" appended to a name.
	static clearscope String Suffix()
	{
		switch (Mode())
		{
			case 1: case 2: return "_PD";
			case 3: return "_T";
			case 4: return "_HC";
		}
		return "";
	}

	// The role's colour while the setting is on, else the mod's own colour.
	static clearscope int Pick(int role, int own)
	{
		int m = Mode();
		return m ? Rgb(role, m) : own;
	}
}
