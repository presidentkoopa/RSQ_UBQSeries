// RSQ Glow In The Dark -- PROFILES: named, complete looks. One table; add a row to add a profile (the menu reads
// its names from here, nothing else to edit). Row 0 is Custom (the Custom Look page's own settings) and row 1 is
// Random Profile (a named row drawn from the colour seed); every row from 2 on is a named look.
//
// FIELDS, separated by '|':
//   name
//   floor     the floor glow's colours: hex list "FF2000,AA1100" (each room draws one), "R" = any colour like 1.1
//             (each channel 25..255), "-" = no floor glow
//   ceiling   the same, for the ceiling glow
//   jitter    0..1, how far each room's colour may wander from its palette colour (brightness)
//   strength  colour gain (1 = as written)
//   height    how far the glow reaches up/down the walls, map units
//   floorgain, ceilgain   the balance between the floor and the ceiling glow
//   shape     0 steady, 1 breathe, 2 heartbeat, 3 candle flicker, 4 hue drift (colours turn slowly), 5 ripple
//             (a slow swell rolling out from the map's middle)
//   rate      cycles per minute (hue drift: turns of the colour wheel per minute). All slow: nothing here flashes.
//   depth     0..1, how deep the pulse goes
//   liquid    0 liquids keep their own colour, 1 their colour leans toward the profile, 2 the profile's colour
//   ddz mode, ddz preset   the DarkDoomZ pairing (its Mode and Preset values; mode 0 = DarkDoomZ off)
//   note      shown under the profile row

class RSQGD_Profiles
{
	// the table lives in a function (a class-level const array is not reachable from functions on QZD 17.3)
	clearscope static String Row(int i)
	{
		static const String ROWS[] =
		{
		"Custom|-|-|0|1|64|1|1|0|0|0|0|0|0|Your own settings: the Custom Look page.",
		"Random Profile|-|-|0|1|64|1|1|0|0|0|0|0|0|A named profile drawn at random, re-drawn by Re-roll.",
		"Classic (1.1)|R|R|0|1|64|1|1|0|0|0|0|2|3|Glow In The Dark 1.1: any colour, one per tag group.",
		"Classic Doom|C8A070,8C8C8C,B4785A,A0A0B4|A0A0B4,C8B48C,8C8C8C|0.2|0.9|64|1|1|0|0|0|0|2|2|Warm tans and greys, the way id lit it.",
		"Hellfire|FF3000,FF6000,C01000|FF8000,FF2000|0.15|1.3|96|1.2|0.8|3|40|0.35|1|4|4|Flame orange that flickers.",
		"Toxic Waste|40FF20,80FF00,20C040|A0FF40,40C020|0.15|1.2|80|1.2|0.8|1|12|0.3|0|2|4|Sick green, breathing.",
		"Neon Arcade|FF00FF,00FFFF,FF0080,00FF80|FF00FF,00FFFF,FFFF00|0|1.4|80|1|1|0|0|0|0|3|5|Hard neon in every room.",
		"Synthwave|FF2090,B000FF|00C0FF,4040FF|0.1|1.3|96|1.1|0.9|1|8|0.25|1|2|4|Pink floors under blue ceilings.",
		"Vaporwave|FF71CE,01CDFE,05FFA1,B967FF|FFFB96,FF71CE,01CDFE|0.1|1.2|96|1|1|4|2|0.5|1|2|3|Pastels that turn slowly.",
		"Blood Moon|B00000,800000,FF2020|600000,A01010|0.15|1.2|96|1.2|0.8|2|50|0.35|2|4|5|Deep red with a slow heartbeat.",
		"Deep Ocean|0040C0,0080FF,00A0A0|002060,004080|0.15|1|128|1.2|0.6|1|6|0.3|1|2|5|Sea blues, the ceiling dark.",
		"Arctic|C0E8FF,80C0FF,FFFFFF|E0F0FF,A0D0FF|0.1|1|80|1|1|0|0|0|1|3|3|Ice white and pale blue.",
		"Radioactive|80FF00,C0FF00|60C000|0.1|1.4|112|1.3|0.7|1|30|0.45|2|11|0|Everything glows green, liquids too.",
		"Gothic Candle|FF9020,E07010,FFB040|803000,A05010|0.2|1|56|1.3|0.4|3|60|0.4|0|4|5|Low candlelight that gutters.",
		"Lava Lamp|FF4000,FF0060,FF8000,C000C0|FF4000,FF0060,C000C0|0.1|1.2|128|1|1|5|5|0.5|1|2|4|Warm blobs of colour swelling outward.",
		"Ultraviolet|6000FF,A000FF,4000C0|8000FF,3000A0|0.1|1.3|96|1|1|1|6|0.2|1|11|0|Blacklight purple.",
		"Matrix Green|00FF40,00C030,00801A|00FF40,004010|0.1|1.2|64|0.8|1.3|5|20|0.5|2|4|6|Green code rolling down the walls.",
		"Sunset|FF8040,FF4060,FFC060|6040C0,FF6080|0.15|1.1|96|1.2|0.9|0|0|0|1|2|2|Orange floors, violet sky.",
		"Monochrome|C0C0C0,FFFFFF,808080|A0A0A0|0.1|1|64|1|1|0|0|0|2|3|4|Greys only.",
		"Inferno|FF2000,FF5000,FFA000|FF3000,FF0000|0.2|1.6|160|1.2|1|3|90|0.3|1|4|6|Tall, hot, restless fire.",
		"Aurora|00FF80,00C0FF,8040FF|40FFC0,8060FF|0.2|1.1|128|0.6|1.4|4|1|0.5|1|2|5|Northern lights along the ceilings.",
		"Cyberpunk|FF0080,00F0FF,FFE000|00F0FF,FF0080|0|1.4|72|1|1|0|0|0|1|3|5|Magenta, cyan, a little yellow.",
		"Witching Hour|6000A0,20A040,400060|300050,104020|0.15|1|96|1.2|0.8|1|4|0.3|1|11|0|Witch purple and swamp green.",
		"Sepia|C09060,A07040,E0C090|806040|0.1|0.9|64|1|1|0|0|0|2|2|3|An old photograph.",
		"Ghost|A0C0D0,C0E0F0|80A0B0|0.1|0.8|160|1.4|0.4|1|5|0.5|1|4|6|Pale mist rising off the floors.",
		"Toxic Rainbow|FF0000,FF8000,FFFF00,00FF00,0080FF,8000FF|FF0000,FFFF00,00FF00,0080FF,8000FF|0|1.3|80|1|1|4|3|0.5|0|2|3|Every colour, drifting.",
		"Ember|FF6020,C04010|401008|0.2|0.9|48|1.4|0.3|3|30|0.5|1|4|5|Coals glowing low on the floor.",
		"Abyss|002040,100030|000010,001020|0.2|0.8|192|1.2|0.6|1|3|0.4|1|12|0|Barely there, in the dark.",
		"Overcast|8090A0,A0A8B0|C0C8D0|0.1|0.8|64|0.8|1.2|0|0|0|0|2|2|Flat grey daylight.",
		"Holy|FFF0C0,FFE080,FFFFFF|FFF8E0,FFE0A0|0.1|1.2|128|0.6|1.5|1|4|0.2|1|3|2|Gold light from above.",
		"Corruption|800040,400020,A00060|200010,600030|0.25|1.1|112|1.2|0.8|2|40|0.3|2|4|5|Flesh tones with a pulse.",
		"Biohazard|C0FF00,FFE000,40A000|808000|0.15|1.2|80|1.2|0.8|1|20|0.3|1|2|4|Warning yellow-green.",
		"Martian|FF5020,C03010,FF8040|A04020|0.15|1|96|1.2|0.8|0|0|0|1|2|3|Red planet dust.",
		"Glacier|40C0FF,00FFFF,80E0FF|0080C0,40A0E0|0.1|1.1|112|1.1|0.9|1|3|0.2|1|3|4|Blue ice, deep and cold.",
		"Firefly|FFE040,C0FF40|201000|0.3|0.9|40|1.5|0.1|3|20|0.6|0|4|6|Small warm lights near the floor.",
		"Disco (slow)|FF0080,00FF80,0080FF,FFFF00|FF0080,00FF80,0080FF,FFFF00|0|1.2|80|1|1|4|6|0.5|0|2|3|Colours turn once every 10 s; smooth, no flashing.",
		"Minimal|404040|-|0|0.5|32|1|0|0|0|0|0|0|0|A faint grey line along the floors."
		};
		if (i < 0) return String.Format("%d", ROWS.Size());
		return ROWS[clamp(i, 0, ROWS.Size() - 1)];
	}

	const FIRST_NAMED = 2;

	clearscope static int Count() { return Row(-1).ToInt(); }

	clearscope static String Field(int row, int f)
	{
		if (row < 0 || row >= Count()) row = FIRST_NAMED;
		Array<String> t;
		Row(row).Split(t, "|");
		return f < t.Size() ? t[f] : "";
	}

	clearscope static String NameOf(int row) { return Field(row, 0); }

	clearscope static String DdzText(int row)
	{
		int m = Field(row, 12).ToInt(), p = Field(row, 13).ToInt();
		static const String MODES[] = { "Off", "Subtract", "Compress", "Clamp", "Crush" };
		String mode;
		if (m >= 1 && m <= 4) mode = String.Format("%s %d", MODES[m], p);
		else if (m == 10) mode = "DarkDoom Lite";
		else if (m == 11) mode = "DarkDoom Classic";
		else if (m == 12) mode = "DarkDoom Black";
		else mode = "Off";
		return "DarkDoomZ pairing: " .. mode;
	}
}

// One profile, parsed once when the look is (re)built, never per tic.
class RSQGD_Look
{
	String title;
	Array<int> floorPal, ceilPal;     // empty with floorAny: any colour; empty without: no glow on that plane
	bool floorAny, ceilAny;
	double jitter, strength, height, floorGain, ceilGain, rate, depth;
	int shape, liquid;

	static int ParseHex(String s)
	{
		int v = 0;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int c = s.ByteAt(i), d = -1;
			if (c >= 48 && c <= 57) d = c - 48;
			else if (c >= 65 && c <= 70) d = c - 55;
			else if (c >= 97 && c <= 102) d = c - 87;
			if (d >= 0) v = (v << 4) | d;
		}
		return v & 0xFFFFFF;
	}

	static void ParsePal(String s, out bool anyc, Array<int> pal)
	{
		pal.Clear();
		anyc = (s == "R");
		if (anyc || s == "-" || s == "") return;
		Array<String> t;
		s.Split(t, ",");
		for (int i = 0; i < t.Size(); i++) pal.Push(ParseHex(t[i]));
	}

	void FromRow(int row)
	{
		Array<String> t;
		RSQGD_Profiles.Row(row).Split(t, "|");
		while (t.Size() < 16) t.Push("0");
		title = t[0];
		ParsePal(t[1], floorAny, floorPal);
		ParsePal(t[2], ceilAny, ceilPal);
		jitter = t[3].ToDouble(); strength = t[4].ToDouble(); height = t[5].ToDouble();
		floorGain = t[6].ToDouble(); ceilGain = t[7].ToDouble();
		shape = t[8].ToInt(); rate = t[9].ToDouble(); depth = t[10].ToDouble(); liquid = t[11].ToInt();
	}

	// Custom: the Custom Look page's settings.
	void FromCustom()
	{
		title = "Custom";
		int fm = RSQGD_Handler.I("rsqgd_c_floor_mode", 0), cm = RSQGD_Handler.I("rsqgd_c_ceil_mode", 0);
		int pal = RSQGD_Handler.I("rsqgd_c_palette", 4);
		RSQGD_Look src = new("RSQGD_Look");
		src.FromRow(max(pal, RSQGD_Profiles.FIRST_NAMED));
		CustomPlane(fm, false, src, floorAny, floorPal);
		CustomPlane(cm, true, src, ceilAny, ceilPal);
		jitter = RSQGD_Handler.F("rsqgd_c_jitter", 0.0);
		strength = RSQGD_Handler.F("rsqgd_c_strength", 1.0);
		height = RSQGD_Handler.I("rsqgd_height", 64);
		floorGain = RSQGD_Handler.F("rsqgd_c_floor_gain", 1.0);
		ceilGain = RSQGD_Handler.F("rsqgd_c_ceil_gain", 1.0);
		shape = RSQGD_Handler.I("rsqgd_c_shape", 0);
		rate = RSQGD_Handler.F("rsqgd_c_rate", 10.0);
		depth = RSQGD_Handler.F("rsqgd_c_depth", 0.3);
		liquid = RSQGD_Handler.I("rsqgd_c_liquid", 0);
	}

	// mode 0 any colour (1.1), 1 the fixed colour (1.1's sliders), 2 the chosen profile's palette, 3 off
	static void CustomPlane(int mode, bool ceil, RSQGD_Look src, out bool anyc, Array<int> pal)
	{
		pal.Clear();
		anyc = false;
		if (mode == 0) { anyc = true; return; }
		if (mode == 3) return;
		if (mode == 1)
		{
			String p = ceil ? "rsqgd_ceil_" : "rsqgd_floor_";
			pal.Push((clamp(RSQGD_Handler.I(p .. "r", 135), 0, 255) << 16) | (clamp(RSQGD_Handler.I(p .. "g", 135), 0, 255) << 8)
				| clamp(RSQGD_Handler.I(p .. "b", 135), 0, 255));
			return;
		}
		anyc = ceil ? src.ceilAny : src.floorAny;
		if (ceil) pal.Copy(src.ceilPal); else pal.Copy(src.floorPal);
	}
}
