// ANY COLOUR, ON A STOCK ENGINE.
//
// The first version had seven colours because a translation was a TRNSLATE line,
// and TRNSLATE is read once at startup. UZDXREMA has colour pickers because its
// laser is drawn in C++. The way through on stock QuestZDoom is a struct nobody
// in the family had used: `Translation` (engine/base.zs, version 2.4) -- fill its
// 256 colours and AddTranslation() stores a real translation table at run time,
// from play code. Tested in the rig 2026-10-26: it returns an id, an actor wears
// it, and the SAME colours twice return the SAME id (PaletteContainer::Store-
// Translation dedupes), so building one per colour change leaks nothing. User
// translations are also written into savegames.
//
// THE MAPPING is TRNSLATE's desaturate-and-tint, `%[0,0,0]:[2r,2g,2b]`, done by
// hand: each palette entry's brightness times twice the chosen colour, clamped.
// Everything the laser draws is white or grey, so brightness IS the texture, and
// the doubling lets a mid-grey reach the full colour. That needs the brightness
// of each palette index, so the palette is read from PLAYPAL itself -- a mod that
// replaces the palette is still mapped correctly.
//
// A small cache, so a colour that does not change costs one array lookup a tic.
class RSQLS_Colors play
{
	const CACHE = 24;

	private static RSQLS_ColorTable Table()
	{
		let t = RSQLS_ColorTable(StaticEventHandler.Find("RSQLS_ColorTable"));
		return t;
	}

	// The translation that paints a white texture `rgb` (0xRRGGBB).
	static TranslationID Tint(int rgb)
	{
		let t = Table();
		return t ? t.Get(rgb & 0xFFFFFF) : 0;
	}

	// Hue (degrees) at full saturation and value, as 0xRRGGBB. For cycling.
	static int Hue(double deg)
	{
		deg = deg - floor(deg / 360.0) * 360.0;
		double h = deg / 60.0;
		int i = int(h);
		double f = h - i;
		int up = int(255 * f), dn = int(255 * (1.0 - f));
		int r, g, b;
		switch (i)
		{
		case 0:  r = 255; g = up;  b = 0;   break;
		case 1:  r = dn;  g = 255; b = 0;   break;
		case 2:  r = 0;   g = 255; b = up;  break;
		case 3:  r = 0;   g = dn;  b = 255; break;
		case 4:  r = up;  g = 0;   b = 255; break;
		default: r = 255; g = 0;   b = dn;  break;
		}
		return (r << 16) | (g << 8) | b;
	}

	// Between two colours, t in 0..1.
	static int Mix(int a, int b, double t)
	{
		t = clamp(t, 0.0, 1.0);
		int r = int(((a >> 16) & 255) * (1 - t) + ((b >> 16) & 255) * t);
		int g = int(((a >> 8) & 255) * (1 - t) + ((b >> 8) & 255) * t);
		int c = int((a & 255) * (1 - t) + (b & 255) * t);
		return (r << 16) | (g << 8) | c;
	}
}

// The palette's brightness table and the colour -> translation cache. Static:
// it is rebuilt each session and holds nothing a savegame needs (a loaded game
// keeps its actors' translation ids; the engine re-stores user tables on load).
class RSQLS_ColorTable : StaticEventHandler
{
	private double lum[256];
	private bool   haveLum;
	private int    cacheRgb[RSQLS_Colors.CACHE];
	private TranslationID cacheId[RSQLS_Colors.CACHE];
	private int    cacheN, cacheNext;

	private void ReadPalette()
	{
		haveLum = true;
		int lump = Wads.CheckNumForName("PLAYPAL", Wads.ns_global);
		String pal = (lump >= 0) ? Wads.ReadLump(lump) : "";
		for (int i = 0; i < 256; i++)
		{
			if (pal.Length() >= 768)
			{
				int r = pal.ByteAt(i * 3), g = pal.ByteAt(i * 3 + 1), b = pal.ByteAt(i * 3 + 2);
				lum[i] = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
			}
			else lum[i] = i / 255.0;   // no palette: a plain ramp
		}
	}

	TranslationID Get(int rgb)
	{
		for (int k = 0; k < cacheN; k++)
			if (cacheRgb[k] == rgb) return cacheId[k];

		if (!haveLum) ReadPalette();
		int cr = (rgb >> 16) & 255, cg = (rgb >> 8) & 255, cb = rgb & 255;
		Translation t;
		for (int i = 0; i < 256; i++)
		{
			double l = lum[i] * 2.0;
			t.colors[i] = Color(255, min(255, int(cr * l)), min(255, int(cg * l)), min(255, int(cb * l)));
		}
		TranslationID id = t.AddTranslation();

		int slot;
		if (cacheN < RSQLS_Colors.CACHE) slot = cacheN++;
		else { slot = cacheNext; cacheNext = (cacheNext + 1) % RSQLS_Colors.CACHE; }
		cacheRgb[slot] = rgb;
		cacheId[slot] = id;
		return id;
	}
}
