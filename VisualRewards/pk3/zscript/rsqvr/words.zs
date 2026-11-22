// RSQ VisualRewards -- MONSTER WORDS AND POPS (2026-11-09), and the handler the arrival beams share (beams.zs).
// RSQVR_Service "word", "word.hold", "word.clear", "pop" (service.zs; the shared contract of the Bossfight rework build).
//
// THE WORDS (design/MINIBOSS_REWORK.md "Words": the owner's Castlevania GIF, "our font"): a word in the Word Font (below;
// until 11-16 always RS Score's score-line font RSSCFON, Blue Shadow via Dakka, textures QVWnnn by tools/gen_beams.py) stands
// over the actor as a world billboard, drawn with the engine's VisualThinker exactly as the damage numbers are
// (damnums/glyphs.zs: one quad per letter, from the centre eye, so both eyes see it at one depth; no sprite frames;
// placed after every actor has moved, Prev and Pos set so it is interpolated). Score's font is grey with a dark
// outline: it is coloured by brightness through one runtime translation per colour (dark outline, lit face), as
// Score's own font colours paint it.
//   "word"        a one-off: it comes in with the SOTN entrance (below), drifts up, holds about a second (doubleArg
//                 seconds; 0 = 1 s), fades over 10 tics. The same word on the same actor while it is still up pops again
//                 in place (a small overshoot, 0.45 -> 1.35 -> 1.15 -> 1.0, and its flash between looks starts again; no
//                 second smear: a burst of shots is one lively word, not a stack). If the actor goes, the word finishes
//                 where it was.
//   "word.hold"   kept over the actor until "word.clear" with the same text, or the actor dies or is removed. Size 1
//                 normal, 2 large and pulsing (about one pulse a second), 0.6 small. It does the SOTN entrance once;
//                 asked again with the same text on the same actor: its colour and size change in place (a held word
//                 asked back while it fades pops in place, as a repeated one-off word). Held words stack upward; one-off
//                 words start above them.
// THE SOTN ENTRANCE (owner 11-16 07:59, "sotn style": design/mockups/word_motion/, the right column; the banners' SOTN
// letters, banners.zs SotnHead): counted from the first tic a word is drawn, tics 0-3 it is stretched wide and slanted
// forward (smear k = 1 - tic/4: width x (1 + 0.3k), the top 0.45k of its height ahead of the foot), at tic 4 it snaps
// upright at its normal size; tics 4-27 it flashes between its two looks every 4 tics (4-7 the light look, 8-11 its own,
// ...; the light look is each colour, both bands of the two-tone look, lightened halfway to white), from tic 28 its own
// look. This replaced (11-16) the first pop 0.45 -> 1.35 -> 1.15 -> 1.0 and the flicker to white. A quad cannot be
// sheared: in the smear tics each letter is drawn as FOUR horizontal slices (tools/gen_word_slices.py, TEXTURES.rsqvrsl:
// cut on whole font rows, slices 1-2 the top half and 3-4 the bottom half, so the two-tone look keeps its colours), each
// moved sideways by the slant at its own middle, as the banners' SlantTex slices their letters; each slice a hair nearer
// than the one above it (the letters' depth nudge kept). Photosensitive Mode: no flash between looks (the word holds its
// own look); the smear and the snap stay, as the banners keep theirs (a change of shape over 4 tics, no change of
// brightness), and a repeated word never smears again.
//   "pop"         a pixel ring and an eight-point star burst (drawn in code, tools/gen_beams.py) at the actor's middle,
//                 in the colour's four bands, 18 tics. Size scales it (1 = for a monster as tall as an imp).
// THE WORD FONT (owner 11-16, PRESENTATION_GUIDE.md 4b): Word Font (rsqvr_wordfont, user) picks the letters every word here
// is drawn in: 0 Score Small (RS Score's RSSCFN2; the default), 1 SOTN (the letters cut from the owner's word sheet), 2 JFO
// (the damage numbers' font), 3 Score Big (RSSCFON, the font until 11-16), 4 Doom small (the IWAD's own STCFN). Only the
// glyphs change: the entrance, the pop, the drift, the fade, the colours, the two-tone SOTN look and each word's size are
// the same in every font; each font is sized so its capital letters stand as tall as Score Big's (WF_FH). The glyphs are
// VisualRewards' own textures (tools/gen_word_fonts.py: graphics/rsqvrwf/, TEXTURES.rsqvrwf; Score Big gen_beams.py's
// QVWnnn), so every font works without RS Score loaded. A character a font lacks is drawn as its '?', or left a space.
// Above the HP bar and its markers (a tenth of the actor's height and 10 units over its top). Words grow with distance
// like the bars (Far Size) and follow Word Size x Monster Word Size (rsqvr_monword_size, 11-17: ReadSettings).
// Photosensitive Mode (rsqa_photosafe): no flash between looks (a word holds its colour), a pulse at most once a second,
// the pop's white first frames at 40%. Monster Words / Pops off (user rows): nothing is drawn; the service still answers
// 1 (an answer never depends on a player's own setting: netplay).
// Every word and pop is local to the console player's view; the requests come from synced play code on every machine.

class RSQVR_WGlyph : VisualThinker
{
	const STAT_W = 28;     // below STAT_FIRST_THINKING (32): never ticked by the engine (VisualRewards' numbers use 30,
	                       // RSQ Miniboss's effects 29)
	void Put(Vector3 newPos, Vector3 lastPos)
	{
		Prev = lastPos;    // (not a parameter named "prev": names are case-insensitive, glyphs.zs' seizure)
		Pos = newPos;
		UpdateSector();
	}
}

class RSQVR_Word play
{
	Actor who;
	String text;
	int rgb, t, life;
	double size;
	bool held, clearing;
	int clearT;
	// the SOTN look (LegenDoom HUD direction D, owner 11-11 15:30): two tones, rgb on the top half of each letter and rgb2 on
	// the bottom, the font's outline near-black (SOTN style A's dark box); each letter is two quads, gl (top) and gl2 (bottom)
	bool sotn;
	int rgb2;
	Name tag;              // who asked (nothing for the service's words; 'legendary' for LEGENDARY, its own user row)
	Array<RSQVR_WGlyph> gl2;
	double barTop;         // the top of its monster's HP bar and markers, this tic (-1e9 none)
	Vector3 lastPos;
	double lastH;
	double lastCeil;      // the ceiling over it (owner 11-11 23:56: the word and the bar "get clipped into ceilings")
	Array<RSQVR_WGlyph> gl;
	// the SOTN entrance (see the header): et counts tics from the first tic it is drawn (-1 not drawn yet); repop: it was
	// asked again while up (pops in place, never smears again); gs the smear's slices (4 per letter, only in the smear tics)
	int et;
	bool repop;
	Array<RSQVR_WGlyph> gs;
}

class RSQVR_Pop play
{
	Vector3 at;
	int rgb, t;
	double unit;
	RSQVR_WGlyph g;
}

// After every actor has moved (as the damage numbers' driver).
class RSQVR_FxDriver : Thinker
{
	RSQVR_FxHandler h;
	override void Tick() { if (h) h.DrawStep(); }
}

class RSQVR_FxHandler : EventHandler
{
	const GLYPH_CAP = 256;     // (160 until 11-16: a word smearing in takes four quads a letter for its first 4 tics)
	const WORD_CAP = 24;
	const POP_CAP = 12;
	const BASE_H = 6.0;        // a word's letters, map units tall at size 1 (17 cm): readable across a room in the headset
	const POP_T = 2;           // tics a pop frame

	Array<RSQVR_Beam> beams;
	Array<RSQVR_Word> words;
	Array<RSQVR_Pop> pops;
	Array<RSQVR_WGlyph> pool, freeG;
	RSQVR_FxDriver driver;

	transient Array<int> sprIdx;
	transient Array<int> tKey;
	transient Array<TranslationID> tId;
	transient Array<double> palLum;
	transient Array<TextureID> wfGlyph;      // [font][part: full, top half, bottom half, slices 1..4][character 32..96]
	transient Array<int> wfWid;              // [font][character]: the full glyph's width, texture pixels (0: none)
	transient int wfont;                      // Word Font (rsqvr_wordfont), this tic
	transient Array<TextureID> popFrames;
	transient int readAt;
	transient bool wordsOn, popsOn, photo, ldWordOn, ldDropOn;
	transient int cbMode;
	transient double wordSize, far;          // wordSize: Word Size x Monster Word Size, this tic (ReadSettings)

	static RSQVR_FxHandler Get() { return RSQVR_FxHandler(EventHandler.Find("RSQVR_FxHandler")); }

	// =================================================================================================================
	// COLOUR (shared with the beams)
	// the four bands of a colour: 0 core (near white), 1 light, 2 mid (the colour), 3 dark; times k
	static Color BandCol(int rgb, int band, double k = 1.0)
	{
		double r = (rgb >> 16) & 255, g = (rgb >> 8) & 255, b = rgb & 255;
		double m = band == 0 ? 0.88 : (band == 1 ? 0.5 : 0.0);
		double mul = band == 3 ? 0.5 : 1.0;
		r = (r + (255 - r) * m) * mul * k;
		g = (g + (255 - g) * m) * mul * k;
		b = (b + (255 - b) * m) * mul * k;
		return Color(255, clamp(int(r), 0, 255), clamp(int(g), 0, 255), clamp(int(b), 0, 255));
	}
	// the SOTN entrance's light look (words.zs DrawWord): a colour lightened halfway to white
	static int Lighter(int rgb)
	{
		int r = (rgb >> 16) & 255, g = (rgb >> 8) & 255, b = rgb & 255;
		return (((r + 255) / 2) << 16) | (((g + 255) / 2) << 8) | ((b + 255) / 2);
	}
	// the ladder's Black tier and its like: drawn see-through, not added (adding near-black shows nothing)
	static bool IsDark(int rgb)
	{
		double l = 0.299 * ((rgb >> 16) & 255) + 0.587 * ((rgb >> 8) & 255) + 0.114 * (rgb & 255);
		return l < 56;
	}

	private void ReadPal()
	{
		palLum.Clear();
		int lump = Wads.FindLump("PLAYPAL");
		String pal = lump >= 0 ? Wads.ReadLump(lump) : "";
		for (int i = 0; i < 256; i++)
		{
			if (pal.Length() >= 768)
				palLum.Push(0.299 * pal.ByteAt(i * 3) + 0.587 * pal.ByteAt(i * 3 + 1) + 0.114 * pal.ByteAt(i * 3 + 2));
			else palLum.Push(i);
		}
	}

	// One translation per colour, from the loaded palette by brightness. font false: the art's four greys (67, 127, 191,
	// 255; tools/gen_beams.py) -> dark, mid, light, core. font true: a smooth ramp, the outline dark, the face the colour,
	// the brightest lighter. Cached per colour (transient: rebuilt after a load; the engine reuses an identical table).
	TranslationID Trans(int rgb, bool font)
	{
		rgb &= 0xFFFFFF;
		int key = rgb | (font ? 0x1000000 : 0);
		for (int i = 0; i < tKey.Size(); i++) if (tKey[i] == key) return tId[i];
		if (palLum.Size() != 256) ReadPal();
		Translation tr;
		Color c0 = BandCol(rgb, 0), c1 = BandCol(rgb, 1), c2 = BandCol(rgb, 2), c3 = BandCol(rgb, 3);
		double r = (rgb >> 16) & 255, g = (rgb >> 8) & 255, b = rgb & 255;
		for (int i = 0; i < 256; i++)
		{
			double l = palLum[i];
			if (!font)
			{
				tr.colors[i] = l >= 223 ? c0 : (l >= 159 ? c1 : (l >= 97 ? c2 : c3));
				continue;
			}
			double u = l / 255.0;
			double rr, gg, bb;
			if (u < 0.55)
			{
				double f = clamp((u - 0.2) / 0.35, 0.0, 1.0);
				double d = 0.3 + 0.7 * f;
				rr = r * d; gg = g * d; bb = b * d;
			}
			else
			{
				double f = clamp((u - 0.55) / 0.45, 0.0, 1.0) * 0.6;
				rr = r + (255 - r) * f; gg = g + (255 - g) * f; bb = b + (255 - b) * f;
			}
			tr.colors[i] = Color(255, clamp(int(rr), 0, 255), clamp(int(gg), 0, 255), clamp(int(bb), 0, 255));
		}
		tr.colors[0] = Color(0, 0, 0, 0);
		TranslationID id = tr.AddTranslation();
		tKey.Push(key);
		tId.Push(id);
		return id;
	}

	// The SOTN look's colour (design/mockups/sotn_words/mock.py paint + boxed, as make_mockups.py sotn() draws LEGENDARY): the
	// font's outline and anything darker (palette brightness <= 75) near-black, the SOTN dark box; the lit face the colour at
	// 0.55 + 0.45 x its brightness, x 1.15. Cached per colour beside the others.
	TranslationID TransSotn(int rgb)
	{
		rgb &= 0xFFFFFF;
		int key = rgb | 0x2000000;
		for (int i = 0; i < tKey.Size(); i++) if (tKey[i] == key) return tId[i];
		if (palLum.Size() != 256) ReadPal();
		Translation tr;
		double r = (rgb >> 16) & 255, g = (rgb >> 8) & 255, b = rgb & 255;
		for (int i = 0; i < 256; i++)
		{
			double l = palLum[i];
			if (l <= 75) { tr.colors[i] = Color(255, 8, 8, 10); continue; }
			double k = (0.55 + 0.45 * l / 255.0) * 1.15;
			tr.colors[i] = Color(255, clamp(int(r * k), 0, 255), clamp(int(g * k), 0, 255), clamp(int(b * k), 0, 255));
		}
		tr.colors[0] = Color(0, 0, 0, 0);
		TranslationID id = tr.AddTranslation();
		tKey.Push(key);
		tId.Push(id);
		return id;
	}

	// a sprite name's number (GetSpriteIndex searches every sprite: once, then kept)
	int Spr(int i)
	{
		if (sprIdx.Size() != RSQVR_BeamData.NSPR)
		{
			sprIdx.Clear();
			for (int k = 0; k < RSQVR_BeamData.NSPR; k++) sprIdx.Push(Actor.GetSpriteIndex(RSQVR_BeamData.SPR(k)));
		}
		return sprIdx[clamp(i, 0, RSQVR_BeamData.NSPR - 1)];
	}

	// is a beam still holding this monster?
	bool BeamOn(Actor m)
	{
		for (int i = beams.Size() - 1; i >= 0; i--)
		{
			let b = beams[i];
			if (!b || b.bDestroyed) { beams.Delete(i); continue; }
			if (b.mon == m && !b.released) return true;
		}
		return false;
	}

	// =================================================================================================================
	// THE REQUESTS
	int WordOnce(String txt, int rgb, double secs, Actor a)
	{
		if (!a || a.bDestroyed) return 0;
		txt = txt.MakeUpper();
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			if (w && !w.held && w.who == a && w.text == txt && w.t < w.life) { w.t = 0; w.rgb = rgb & 0xFFFFFF; Repop(w); return 1; }
		}
		let w = NewWord(txt, rgb, a);
		w.life = secs > 0 ? int(clamp(secs, 0.2, 10.0) * 35) : 35;
		w.size = 1.0;
		return 1;
	}

	int WordHold(String txt, int rgb, double sizeArg, Actor a)
	{
		if (!a || a.bDestroyed) return 0;
		txt = txt.MakeUpper();
		if (sizeArg <= 0) sizeArg = 1.0;
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			if (w && w.held && w.who == a && w.text == txt)
			{
				w.rgb = rgb & 0xFFFFFF; w.size = clamp(sizeArg, 0.3, 4.0);
				if (w.clearing) { w.clearing = false; w.t = 0; Repop(w); }
				return 1;
			}
		}
		let w = NewWord(txt, rgb, a);
		w.held = true;
		w.size = clamp(sizeArg, 0.3, 4.0);
		return 1;
	}

	// A held word in the SOTN look: top and bottom colours, a tag for its own user row (DrawStep). LegenDoom's LEGENDARY
	// (owner 11-11 15:30, ldword.zs) is the only one so far.
	int WordHoldSotn(String txt, int top, int bot, double sizeArg, Actor a, Name tag)
	{
		if (WordHold(txt, top, sizeArg, a) != 1) return 0;
		txt = txt.MakeUpper();
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			if (w && w.held && w.who == a && w.text == txt) { w.sotn = true; w.rgb2 = bot & 0xFFFFFF; w.tag = tag; }
		}
		return 1;
	}

	// asked again while it is up: it pops in place and its flash between looks starts again, and it never smears again
	// (a burst of shots is one lively word); its smear's slices, if it was still smearing, go back to the pool
	void Repop(RSQVR_Word w)
	{
		w.repop = true;
		w.et = -1;
		FreeSlices(w);
	}

	int ClearWord(String txt, Actor a)
	{
		txt = txt.MakeUpper();
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			if (w && w.held && w.who == a && w.text == txt && !w.clearing) { w.clearing = true; w.clearT = 0; }
		}
		return 1;
	}

	int PopAt(int rgb, double sizeArg, Actor a)
	{
		if (!a || a.bDestroyed) return 0;
		if (pops.Size() >= POP_CAP) { FreePop(pops[0]); pops.Delete(0); }
		let p = new("RSQVR_Pop");
		p.at = a.Pos + (0, 0, a.Height * 0.5);
		p.rgb = rgb & 0xFFFFFF;
		p.unit = 1.2 * (sizeArg > 0 ? sizeArg : 1.0) * max(a.Height, 32.0) / 56.0;
		pops.Push(p);
		return 1;
	}

	RSQVR_Word NewWord(String txt, int rgb, Actor a)
	{
		if (words.Size() >= WORD_CAP)
		{
			// the oldest one-off goes first; held words only if nothing else can
			int drop = 0;
			for (int i = 0; i < words.Size(); i++) if (words[i] && !words[i].held) { drop = i; break; }
			FreeWord(words[drop]); words.Delete(drop);
		}
		let w = new("RSQVR_Word");
		w.who = a; w.text = txt; w.rgb = rgb & 0xFFFFFF;
		w.et = -1;
		w.lastPos = a.Pos; w.lastH = a.Height; w.lastCeil = a.ceilingz;
		words.Push(w);
		return w;
	}

	// =================================================================================================================
	// THE GLYPH POOL
	RSQVR_WGlyph Acquire(Vector3 at)
	{
		RSQVR_WGlyph g = null;
		while (freeG.Size() && !g) { g = freeG[freeG.Size() - 1]; freeG.Pop(); }
		if (!g && pool.Size() < GLYPH_CAP)
		{
			TextureID t0 = WfTex(wfont, 0, 65);
			if (!t0.IsValid()) t0 = WfTex(WF_BIG, 0, 65);
			g = RSQVR_WGlyph(VisualThinker.Spawn("RSQVR_WGlyph", t0, at, (0, 0, 0), 0.0, SPF_FULLBRIGHT, 0, (1, 1), (0, 0), STYLE_Translucent));
			if (g) { g.ChangeStatNum(RSQVR_WGlyph.STAT_W); pool.Push(g); }
		}
		return g;
	}
	void Release(RSQVR_WGlyph g)
	{
		if (!g) return;
		g.Alpha = 0;
		freeG.Push(g);
	}
	void FreeWord(RSQVR_Word w)
	{
		if (!w) return;
		for (int i = 0; i < w.gl.Size(); i++) Release(w.gl[i]);
		w.gl.Clear();
		for (int i = 0; i < w.gl2.Size(); i++) Release(w.gl2[i]);
		w.gl2.Clear();
		FreeSlices(w);
	}
	void FreeSlices(RSQVR_Word w)
	{
		for (int i = 0; i < w.gs.Size(); i++) Release(w.gs[i]);
		w.gs.Clear();
	}
	void FreePop(RSQVR_Pop p) { if (p && p.g) { Release(p.g); p.g = null; } }

	// ---- THE WORD FONTS (see the header). Per font: its textures' names (full glyph, top half and bottom half in a full
	// cell: the SOTN look), texture pixels per font pixel, the font pixels that stand BASE_H tall (its H's height), the
	// advance (the glyph's width x ADVK + KERN, font pixels; JFO's bevelled cells overlap as the damage numbers set them)
	// and the space's advance.
	enum EWordFont { WF_SMALL, WF_SOTN, WF_JFO, WF_BIG, WF_DOOM, WF_N }
	const WF_PARTS = 7;       // full, top half, bottom half (the SOTN look), the smear's slices 1..4 (WF_SLICE + j)
	const WF_SLICE = 3;
	const WF_CH = 65;         // characters 32..96
	// the smear's slices' cuts (tools/gen_word_slices.py cuts(), the same rule): cut j (0..4) of a cell th texture pixels
	// tall, texture pixels from its top: on whole font rows, cut 2 the SOTN halves' split
	static int SliceB(int f, int th, int j)
	{
		int k = WF_K(f), r = th / k, t = r / 2;
		if (j <= 0) return 0;
		if (j == 1) return ((t + 1) / 2) * k;
		if (j == 2) return t * k;
		if (j == 3) return (t + (r - t + 1) / 2) * k;
		return th;
	}
	static String WF_NAME(int f, int part)
	{
		static const String T[] = { "QWSW", "QWST", "QWSB", "QWS1", "QWS2", "QWS3", "QWS4",
			"QWOW", "QWOT", "QWOB", "QWO1", "QWO2", "QWO3", "QWO4", "QWJW", "QWJT", "QWJB", "QWJ1", "QWJ2", "QWJ3", "QWJ4",
			"QVW", "QVT", "QVB", "QV1", "QV2", "QV3", "QV4", "QWDW", "QWDT", "QWDB", "QWD1", "QWD2", "QWD3", "QWD4" };
		return T[clamp(f, 0, WF_N - 1) * WF_PARTS + clamp(part, 0, WF_PARTS - 1)];
	}
	static int WF_K(int f) { static const int T[] = { 4, 4, 1, 4, 1 }; return T[clamp(f, 0, WF_N - 1)]; }
	static double WF_FH(int f) { static const double T[] = { 6, 7, 32, 12, 7 }; return T[clamp(f, 0, WF_N - 1)]; }
	static double WF_ADVK(int f) { static const double T[] = { 1.0, 1.0, 0.86, 1.0, 1.0 }; return T[clamp(f, 0, WF_N - 1)]; }
	static double WF_KERN(int f) { static const double T[] = { 0, -1, 0, -1, 0 }; return T[clamp(f, 0, WF_N - 1)]; }
	static double WF_SPACE(int f) { static const double T[] = { 4, 3, 10, 7, 4 }; return T[clamp(f, 0, WF_N - 1)]; }

	private void WfInit()
	{
		wfGlyph.Clear(); wfWid.Clear();
		for (int f = 0; f < WF_N; f++)
			for (int part = 0; part < WF_PARTS; part++)
				for (int c = 32; c <= 96; c++)
				{
					TextureID t = TexMan.CheckForTexture(String.Format("%s%03d", WF_NAME(f, part), c), TexMan.Type_Any);
					wfGlyph.Push(t);
					if (part != 0) continue;
					int tw = 0, th = 0;
					if (t.IsValid() && c != 32) [tw, th] = TexMan.GetSize(t);
					wfWid.Push(tw);
				}
	}
	TextureID WfTex(int f, int part, int c)
	{
		if (wfGlyph.Size() != WF_N * WF_PARTS * WF_CH) WfInit();
		return wfGlyph[(clamp(f, 0, WF_N - 1) * WF_PARTS + clamp(part, 0, WF_PARTS - 1)) * WF_CH + clamp(c, 32, 96) - 32];
	}
	// the character this font draws for c (Code(c) first): its own, else its '?', else 32 (a space)
	int WfChar(int f, int c)
	{
		if (wfGlyph.Size() != WF_N * WF_PARTS * WF_CH) WfInit();
		c = Code(c);
		if (c == 32) return 32;
		f = clamp(f, 0, WF_N - 1);
		if (wfWid[f * 65 + c - 32] > 0) return c;
		return wfWid[f * 65 + 63 - 32] > 0 ? 63 : 32;
	}
	// a glyph's width and advance, font pixels (c from WfChar)
	double WfW(int f, int c) { return c == 32 ? 0 : wfWid[clamp(f, 0, WF_N - 1) * 65 + clamp(c, 32, 96) - 32] / double(WF_K(f)); }
	double WfAdv(int f, int c) { return c == 32 ? WF_SPACE(f) : WfW(f, c) * WF_ADVK(f) + WF_KERN(f); }
	// the font this tic: the menu's, or Score Big when the chosen one is not there (Doom small with an IWAD with no STCFN)
	int WfPick(int f)
	{
		if (wfGlyph.Size() != WF_N * WF_PARTS * WF_CH) WfInit();
		f = clamp(f, 0, WF_N - 1);
		return wfWid[f * 65 + 65 - 32] > 0 ? f : WF_BIG;
	}
	TextureID PopTex(int f)
	{
		if (popFrames.Size() != RSQVR_BeamData.POP_N)
		{
			popFrames.Clear();
			for (int i = 0; i < RSQVR_BeamData.POP_N; i++) popFrames.Push(TexMan.CheckForTexture(String.Format("QVPOP%02d", i), TexMan.Type_Any));
		}
		return popFrames[clamp(f, 0, RSQVR_BeamData.POP_N - 1)];
	}

	// =================================================================================================================
	// EACH TIC
	override void WorldLoaded(WorldEvent e)
	{
		EnsureDriver();
		if (e.IsSaveGame) DropWorldWords();      // a loaded save: no reward sign left over from the moment it was saved in
	}
	override void WorldTick() { EnsureDriver(); }
	void EnsureDriver()
	{
		if (driver) return;
		driver = new("RSQVR_FxDriver");
		driver.h = self;
		driver.ChangeStatNum(125);        // after the actors (STAT_DEFAULT 100), beside the damage numbers' driver
	}

	void ReadSettings()
	{
		let c = CVar.GetCvar('rsqvr_words', players[consoleplayer]);
		wordsOn = !c || c.GetBool();
		c = CVar.GetCvar('rsqvr_pops', players[consoleplayer]);
		popsOn = !c || c.GetBool();
		photo = RSQTHP_A11y.Photo();
		c = CVar.GetCvar('rsqthp_dn_wordsize', players[consoleplayer]);
		wordSize = c ? clamp(c.GetFloat(), 0.25, 4.0) : 1.0;
		// MONSTER WORD SIZE (owner 11-17 08:39: THREAT! was too large and nothing could change it):
		// rsqvr_monword_size (user, 0.25..2.0, 1.0 = the size before it) scales every word over a monster, here and only
		// here. wordSize is the one size every word drawn below reads (Unit: the letters, the smear's slices, the ends kept
		// out of walls, the ceiling's room; LineH: each line of the "never on top of each other" stack and the room the HP
		// bar leaves under it, StackOver; the one-off word's drift up), so all of them scale alike in every Word Font.
		c = CVar.GetCvar('rsqvr_monword_size', players[consoleplayer]);
		wordSize *= c ? clamp(c.GetFloat(), 0.25, 2.0) : 1.0;
		c = CVar.GetCvar('rsqvr_ldword', players[consoleplayer]);
		ldWordOn = !c || c.GetBool();
		c = CVar.GetCvar('rsqvr_lddrop', players[consoleplayer]);
		ldDropOn = !c || c.GetBool();
		cbMode = 0;
		{ Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN; if (rsqaC) { let cb = CVar.FindCVar("rsqa_colorblind"); if (cb) cbMode = clamp(cb.GetInt(), 0, 4); } }
		c = CVar.GetCvar('rsqvr_wordfont', players[consoleplayer]);
		wfont = WfPick(c ? c.GetInt() : WF_SMALL);
		let cf = CVar.FindCVar('rsqthp_far');
		far = cf ? max(1.0, cf.GetFloat()) : 2.0;
	}

	void DrawStep()
	{
		if (level.maptime >= readAt || level.maptime < readAt - 8) { ReadSettings(); readAt = level.maptime + 8; }
		bool frozen = level.IsFrozen();
		let p = players[consoleplayer];
		let cam = p.camera ? p.camera : Actor(p.mo);
		Vector3 eye = (0, 0, 0);
		if (cam) eye = (cam.Pos.xy, cam == p.mo ? p.viewz : cam.Pos.z + cam.Height * 0.8);
		double ps = level.pixelstretch;

		// ---- words ----
		for (int i = words.Size() - 1; i >= 0; i--)
		{
			let w = words[i];
			if (!w) { words.Delete(i); continue; }
			if (w.who && w.who.bDestroyed) w.who = null;
			if (w.who) { w.lastPos = w.who.Pos; w.lastH = w.who.Height; w.lastCeil = w.who.ceilingz; }
			// a held word goes with its actor (dead or gone): a quick fade
			if (w.held && !w.clearing && (!w.who || w.who.health <= 0)) { w.clearing = true; w.clearT = 0; }
			if (!frozen) { w.t++; if (w.et >= 0) w.et++; if (w.clearing) w.clearT++; }
			bool done = w.held ? (w.clearing && w.clearT >= 6) : (w.t >= w.life + 10);
			if (done) { FreeWord(w); words.Delete(i); continue; }
		}
		// stack each actor's held words from the bar up, one-off words above them
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			// LEGENDARY has its own row (rsqvr_ldword), the service's words Monster Words (rsqvr_words)
			// and a LegenDoom drop's words theirs (rsqvr_lddrop)
			bool on = w.tag == 'legendary' ? ldWordOn : w.tag == 'lddrop' ? ldDropOn : wordsOn;
			if (!on || !cam) { HideWord(w); continue; }
			// NEVER ON TOP OF EACH OTHER (owner 11-16 03:15, PRESENTATION_GUIDE.md 4b; rig: THREAT!, ENEMIES TIER UP! and
			// MINIBOSS DEFEATED! piled up on one miniboss): every word on one monster (or on one spot, once it is gone)
			// stands in its own line: the held ones from the bar up, then each one-off word above the ones before it
			double heldUp = 0, stackAll = LineH(w, eye);
			for (int j = 0; j < words.Size(); j++)
			{
				let o = words[j];
				if (j == i || !o || !SameSpot(o, w)) continue;
				bool oOn = o.tag == 'legendary' ? ldWordOn : o.tag == 'lddrop' ? ldDropOn : wordsOn;
				if (!oOn) continue;
				if (o.held)
				{
					stackAll += LineH(o, eye);
					if (j < i || !w.held) heldUp += LineH(o, eye);
				}
				else if (!w.held && j < i) { heldUp += LineH(o, eye); stackAll += LineH(o, eye); }
			}
			w.barTop = BarTopOf(w.who);
			lastEye = eye; haveEye = true;
			DrawWord(w, eye, heldUp, ps, stackAll);
		}
		// ---- the world words (worldwords.zs: REVENGE!, REVIVE!, LEVEL UP!, 1UP; their own setting, never stacked here) ----
		WorldStep(eye, cam != null, ps);

		// ---- pops ----
		for (int i = pops.Size() - 1; i >= 0; i--)
		{
			let o = pops[i];
			if (!o) { pops.Delete(i); continue; }
			if (!frozen) o.t++;
			int f = o.t / POP_T;
			if (f >= RSQVR_BeamData.POP_N) { FreePop(o); pops.Delete(i); continue; }
			if (!popsOn || !cam) { if (o.g) o.g.Alpha = 0; continue; }
			if (!o.g) { o.g = Acquire(o.at); if (!o.g) continue; o.g.Put(o.at, o.at); }
			let g = o.g;
			TextureID tx = PopTex(f);
			if (g.Texture != tx) g.Texture = tx;
			g.Translation = Trans(o.rgb, false);
			g.SetRenderStyle(IsDark(o.rgb) ? STYLE_Translucent : STYLE_Add);
			double sc = o.unit / RSQVR_BeamData.POP_K;
			g.Scale = (sc, sc);
			g.Offset = (0, 0);
			double a = 1.0;
			if (photo && f <= 1) a = RSQTHP_A11y.DIM_K;
			g.Alpha = a;
			Vector3 d = eye - o.at;
			double dl = d.Length();
			Vector3 at = dl > 0.01 ? o.at + d / dl * 4.0 : o.at;      // a hair toward you: in front of the actor
			g.Put(at, g.Pos);
		}
	}

	// a word's height on screen in the world, map units (its size, Word Size, grown with distance like the bars, its pulse)
	double Unit(RSQVR_Word w, Vector3 eye)
	{
		double d = (w.lastPos - eye).Length();
		double grow = 1.0 + (far - 1.0) * clamp((d - 256.0) / 768.0, 0.0, 1.0);
		return BASE_H * wordSize * grow * w.size / WF_FH(wfont);     // map units per font pixel
	}
	double LineH(RSQVR_Word w, Vector3 eye) { return Unit(w, eye) * WF_FH(wfont) * 1.3; }

	void HideWord(RSQVR_Word w)
	{
		for (int i = 0; i < w.gl.Size(); i++) if (w.gl[i]) w.gl[i].Alpha = 0;
		for (int i = 0; i < w.gl2.Size(); i++) if (w.gl2[i]) w.gl2[i].Alpha = 0;
		for (int i = 0; i < w.gs.Size(); i++) if (w.gs[i]) w.gs[i].Alpha = 0;
	}

	// UNDER THE CEILING (owner 11-11 23:56: LEGENDARY "is large with a large hp bar and gets clipped into ceilings"): the
	// words over an actor start a tenth of its height and 10 units above it; where the ceiling is lower than the whole
	// stack needs (stackAll: every line over this actor), the stack starts lower so its top is CEIL_GAP under the ceiling,
	// never below the actor's middle. The HP bar asks StackOver and sits under the words (rsqthp/bar.zs).
	const CEIL_GAP = 2.0;
	Vector3 lastEye; bool haveEye;
	// one monster's words, or (its actor gone) words on the same spot
	static bool SameSpot(RSQVR_Word a, RSQVR_Word b)
	{
		if (a.who && b.who) return a.who == b.who;
		return (a.lastPos.xy - b.lastPos.xy).Length() < 24 && abs(a.lastPos.z - b.lastPos.z) < 64;
	}
	// NEVER ON ITS HEALTH BAR (owner 11-16 03:15, PRESENTATION_GUIDE.md 4b; rig: Grapple's KICK! half under the bar): the
	// top of this monster's HP bar and its markers (rsqthp/bar.zs: the bar stands at its sprite's top, BAR_SPAN x its scale
	// tall with the markers), -1e9 with no bar shown
	const BAR_SPAN = 14.0;
	double BarTopOf(Actor who)
	{
		if (!who) return -1e9;
		let h = RSQTHP_Handler(EventHandler.Find("RSQTHP_Handler"));
		if (!h) return -1e9;
		for (int i = 0; i < h.bars.Size(); i++)
		{
			let b = h.bars[i];
			if (!b || b.who != who || b.bInvisible) continue;
			// the bar is 11 px from its foot; a crown, chain or DOWN skull above it is drawn at twice the bar's scale
			double span = BAR_SPAN;
			if ((b.boss && !b.boss.bInvisible) || (b.dmark && !b.dmark.bInvisible) || (b.mark && !b.mark.bInvisible))
				span += 36.0 * RSQTHP_A11y.Cue();
			return b.Pos.z + span * b.Scale.Y;
		}
		return -1e9;
	}
	double StackBase(RSQVR_Word w, double stackAll)
	{
		double base = w.lastPos.z + w.lastH * 1.1 + 10;
		base = max(base, w.barTop + 3);         // above the bar and its markers
		if (w.lastCeil > w.lastPos.z) base = min(base, w.lastCeil - CEIL_GAP - stackAll);
		return max(base, w.lastPos.z + w.lastH * 0.5);
	}
	// how much room the words held over this actor take, map units (0 with none): for the HP bar under them
	double StackOver(Actor who)
	{
		if (!who || !haveEye) return 0;
		double sum = 0;
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			if (!w || w.who != who) continue;
			bool on = w.tag == 'legendary' ? ldWordOn : w.tag == 'lddrop' ? ldDropOn : wordsOn;
			if (on) sum += LineH(w, lastEye);
		}
		return sum;
	}

	transient RSQVR_WallTracer wallT;
	Vector3 OutOfWalls(Vector3 at, Vector3 toEye, double toEyeDist, double halfW)
	{
		if (halfW <= 0.5 || toEye == (0, 0, 0)) return at;
		if (!wallT) wallT = new("RSQVR_WallTracer");
		Vector3 side = (toEye.y, -toEye.x, 0);
		double sl = side.Length();
		if (sl < 0.01) return at;
		side /= sl;
		double need[2]; need[0] = 0; need[1] = 0;
		let sec = level.PointInSector(at.xy);
		if (!sec) return at;
		for (int s = 0; s < 2; s++)
		{
			Vector3 dir = s == 0 ? side : -side;
			if (wallT.Trace(at, sec, dir, halfW + 1.0, 0) && wallT.Results.HitType != TRACE_HitNone && wallT.Results.HitType != TRACE_HitActor)
				need[s] = halfW + 1.0 - wallT.Results.Distance;
		}
		if (need[0] <= 0 && need[1] <= 0) return at;
		// a wall on one side: the line slides sideways off it. Walls on both sides (narrower than the line): it steps toward
		// your eye instead, where the walls' gap looks wider, never past halfway to you.
		if (need[0] > 0 && need[1] > 0) return at + toEye * min(max(need[0], need[1]) * 2.0, toEyeDist * 0.5);
		return at - side * need[0] + side * need[1];
	}

	void DrawWord(RSQVR_Word w, Vector3 eye, double heldUp, double ps, double stackAll)
	{
		int n = int(w.text.Length());
		// its glyphs (one per character that has one; spaces only advance)
		while (w.gl.Size() < n) w.gl.Push(null);
		if (w.sotn) while (w.gl2.Size() < n) w.gl2.Push(null);
		// a world word (worldwords.zs): the same apparent size at any distance, from where its foot stands this tic
		Vector3 wBase = (0, 0, 0);
		double u;
		if (w.world) { wBase = WorldBase(w, eye); u = WorldUnit(wBase, eye, w.size); }
		else u = Unit(w, eye);
		// THE SOTN ENTRANCE (the header): et from this, the first tic it is drawn; smear sm 1, 0.75, 0.5, 0.25 over its first
		// 4 tics (never again once it has been asked again: repop), then upright
		if (w.et < 0) w.et = 0;
		double sm = w.repop ? 0.0 : clamp(1.0 - w.et / 4.0, 0.0, 1.0);
		double sxk = 1.0 + 0.3 * sm, shear = 0.45 * sm;
		if (sm <= 0 && w.gs.Size()) FreeSlices(w);
		// the life: a word asked again pops in place (overshoot) over 4 tics; a held big word pulses (about once a second)
		double popK = !w.repop ? 1.0 : (w.t == 0 ? 0.45 : (w.t == 1 ? 1.35 : (w.t == 2 ? 1.15 : 1.0)));
		double pulse = 1.0;
		if (w.held && w.size >= 1.5) pulse = 1.0 + 0.08 * sin(w.t * 10.3);
		double k = u * popK * pulse;
		double a = 1.0;
		double rise = 0;
		if (w.held) { if (w.clearing) a = 1.0 - w.clearT / 6.0; }
		else
		{
			// (a world word: 1.4 of its own letters' height; one rising from the floor or a crate has risen already)
			if (w.world) rise = w.wKind == WK_RISE ? 0.0 : u * WF_FH(wfont) * 1.4 * (1.0 - exp(-w.t / 10.0));
			else rise = BASE_H * wordSize * 1.4 * (1.0 - exp(-w.t / 10.0));
			if (w.t > w.life) a = 1.0 - (w.t - w.life) / 10.0;
		}
		// colour: the flash between its two looks, tics 4-27 (4 tics each, the light look first; the banners' SOTN letters'
		// shine); never with Photosensitive Mode
		bool light = !photo && w.et >= 4 && w.et < 28 && (((w.et - 4) / 4) & 1) == 0;
		TranslationID tr = Trans(light ? Lighter(w.rgb) : w.rgb, true);
		TranslationID trTop, trBot;
		if (w.sotn)
		{
			// colour-blind play (RSQ Accessibility): the series' COULD colour on top, the same lightened halfway to white below
			int top = w.rgb, bot = w.rgb2;
			if (cbMode)
			{
				static const int CB[] = { 0xFFB000, 0xFFB000, 0xFF4040, 0xFFFF00 };
				top = CB[cbMode - 1];
				int r = (top >> 16) & 255, g = (top >> 8) & 255, b = top & 255;
				bot = (((r + 255) / 2) << 16) | (((g + 255) / 2) << 8) | ((b + 255) / 2);
			}
			if (light) { top = Lighter(top); bot = Lighter(bot); }
			trTop = TransSotn(top);
			trBot = TransSotn(bot);
		}
		// where: above the actor's HP bar and markers, the held stack below it
		int f = wfont;
		double fh = WF_FH(f);
		Vector3 anchor;
		if (w.world)
		{
			// its foot on its base, drifted up; under the ceiling over it
			anchor = wBase + (0, 0, rise + u * fh * 0.5);
			let cs = level.PointInSector(anchor.xy);
			if (cs)
			{
				double cz = cs.ceilingplane.ZatPoint(anchor.xy), fz = cs.floorplane.ZatPoint(anchor.xy);
				if (cz > fz) anchor.z = max(min(anchor.z, cz - CEIL_GAP - u * fh * 0.5), fz + u * fh * 0.5);
			}
		}
		else
		{
			anchor = (w.lastPos.xy, StackBase(w, stackAll) + heldUp + rise + u * fh * 0.5);
			if (w.lastCeil > w.lastPos.z) anchor.z = min(anchor.z, max(w.lastCeil - CEIL_GAP - u * fh * 0.5, w.lastPos.z + w.lastH * 0.5));
		}
		Vector3 d = eye - anchor;
		double dl = d.Length();
		Vector3 toEye = dl > 0.01 ? d / dl : (0, 0, 0);
		// the line's width, font pixels
		double width = 0;
		for (int i = 0; i < n; i++) width += WfAdv(f, WfChar(f, w.text.ByteAt(i)));
		// OUT OF THE WALLS (owner 11-13: "lots of text has a hard time respecting boundaries, like legendary weapon text clips
		// through walls"): the word is a flat line facing you; where a wall is nearer its middle, sideways, than half the
		// line's width, the line would cut into it. It is moved toward your eye until its ends clear the wall, never past
		// halfway to you.
		// (in the smear: stretched wide, and the slant reaches half its height's 0.45 x sm past each end)
		double cellH = 0;
		{ int tw0, th0; [tw0, th0] = TexMan.GetSize(WfTex(f, 0, WfChar(f, 65))); cellH = th0; }
		anchor = OutOfWalls(anchor, toEye, dl, width * k * 0.5 * sxk + shear * cellH / WF_K(f) * k * 0.5);
		d = eye - anchor; dl = d.Length(); toEye = dl > 0.01 ? d / dl : (0, 0, 0);
		if (sm > 0) while (w.gs.Size() < n * 4) w.gs.Push(null);
		double cx = -width * 0.5;
		for (int i = 0; i < n; i++)
		{
			int c = WfChar(f, w.text.ByteAt(i));
			double adv = WfAdv(f, c), gw = WfW(f, c);
			let g = w.gl[i];
			if (c == 32 || gw <= 0) { if (g) g.Alpha = 0; if (w.sotn && w.gl2[i]) w.gl2[i].Alpha = 0; cx += adv; continue; }
			if (sm > 0)
			{
				// the smear: four slices (TEXTURES.rsqvrsl) in place of the letter, stretched sxk wide and each moved forward
				// by the slant at its own middle (shear x its height above the cell's middle: the word leans about its middle,
				// as the mockup's sheared word, centred). Slices 1-2 the top colour, 3-4 the bottom, in the SOTN look.
				if (g) g.Alpha = 0;
				if (w.sotn && w.gl2[i]) w.gl2[i].Alpha = 0;
				double sc = k / WF_K(f);
				int twid = wfWid[f * 65 + c - 32];
				int tw, th; [tw, th] = TexMan.GetSize(WfTex(f, 0, c));
				double ox = ((cx + gw * 0.5) * k - (twid & 1) * 0.5 * sc) * sxk;
				for (int j = 0; j < 4; j++)
				{
					let gj = w.gs[i * 4 + j];
					bool freshJ = false;
					if (!gj) { gj = Acquire(anchor); w.gs[i * 4 + j] = gj; freshJ = true; if (!gj) continue; }
					TextureID tj = WfTex(f, WF_SLICE + j, c);
					if (gj.Texture != tj) gj.Texture = tj;
					gj.Translation = w.sotn ? (j < 2 ? trTop : trBot) : tr;
					gj.SetRenderStyle(STYLE_Translucent);
					gj.Scale = (sc * sxk, sc);
					double mid = (SliceB(f, th, j) + SliceB(f, th, j + 1)) * 0.5;      // texture pixels from the cell's top
					gj.Offset = (ox + shear * (th * 0.5 - mid) * sc, 0);
					gj.Alpha = clamp(a, 0.0, 1.0);
					// the letter's depth nudge, each slice a hair nearer than the one above it (inside the next letter's)
					Vector3 atj = anchor + toEye * (i * 0.03 + j * 0.0075);
					gj.Put(atj, freshJ ? atj : gj.Pos);
				}
				cx += adv;
				continue;
			}
			bool fresh = false;
			if (!g) { g = Acquire(anchor); w.gl[i] = g; fresh = true; if (!g) { cx += adv; continue; } }
			TextureID tx = WfTex(f, w.sotn ? 1 : 0, c);
			if (g.Texture != tx) g.Texture = tx;
			g.Translation = w.sotn ? trTop : tr;
			g.SetRenderStyle(STYLE_Translucent);     // (a pooled glyph may last have been a pop, drawn Add)
			double sc = k / WF_K(f);
			g.Scale = (sc, sc);
			// (the texture's offset is its width / 2 rounded down: an odd width stands half a texture pixel right)
			int twid = wfWid[f * 65 + c - 32];
			g.Offset = ((cx + gw * 0.5) * k - (twid & 1) * 0.5 * sc, 0);
			g.Alpha = clamp(a, 0.0, 1.0);
			// each glyph a hair nearer than the one before (see-through quads at one depth flicker in the headset)
			Vector3 at = anchor + toEye * (i * 0.03);
			g.Put(at, fresh ? at : g.Pos);
			if (w.sotn)
			{
				// the bottom half: the same place, size and offset (its cell is the full glyph's), a hair nearer still
				let g2 = w.gl2[i];
				bool fresh2 = false;
				if (!g2) { g2 = Acquire(anchor); w.gl2[i] = g2; fresh2 = true; }
				if (g2)
				{
					TextureID tb = WfTex(f, 2, c);
					if (g2.Texture != tb) g2.Texture = tb;
					g2.Translation = trBot;
					g2.SetRenderStyle(STYLE_Translucent);
					g2.Scale = (sc, sc);
					g2.Offset = g.Offset;
					g2.Alpha = g.Alpha;
					Vector3 at2 = at + toEye * 0.015;
					g2.Put(at2, fresh2 ? at2 : g2.Pos);
				}
			}
			cx += adv;
		}
	}

	// a character -> one the font has (32..96): lower case as upper case, anything else as '?'
	static int Code(int c)
	{
		if (c >= 97 && c <= 122) return c - 32;
		if (c < 32 || c > 96) return 63;
		return c;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		// the map's thinkers (glyphs, the driver, the beams) go with it
		words.Clear(); pops.Clear(); pool.Clear(); freeG.Clear(); beams.Clear(); wwords.Clear();
		driver = null;
	}
}

// the sideways test of OutOfWalls: walls, floors and ceilings stop it, actors do not
class RSQVR_WallTracer : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitActor) return TRACE_Skip;
		return TRACE_Stop;
	}
}
