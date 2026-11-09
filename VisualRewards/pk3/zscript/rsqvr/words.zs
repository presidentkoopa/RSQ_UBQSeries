// RSQ VisualRewards -- MONSTER WORDS AND POPS (2026-11-09), and the handler the arrival beams share (beams.zs).
// RSQVR_Service "word", "word.hold", "word.clear", "pop" (service.zs; the shared contract of the Bossfight rework build).
//
// THE WORDS (design/MINIBOSS_REWORK.md "Words": the owner's Castlevania GIF, "our font"): a word in RS Score's
// score-line font (RSSCFON, Blue Shadow via Dakka; generated as textures QVW032..QVW096 by tools/gen_beams.py) stands
// over the actor as a world billboard, drawn with the engine's VisualThinker exactly as the damage numbers are
// (damnums/glyphs.zs: one quad per letter, from the centre eye, so both eyes see it at one depth; no sprite frames;
// placed after every actor has moved, Prev and Pos set so it is interpolated). Score's font is grey with a dark
// outline: it is coloured by brightness through one runtime translation per colour (dark outline, lit face), as
// Score's own font colours paint it.
//   "word"        a one-off: it pops (a small overshoot), flickers between its colour and white for its first 14 tics,
//                 drifts up, holds about a second (doubleArg seconds; 0 = 1 s), fades over 10 tics. The same word on
//                 the same actor while it is still up pops again in place (a burst of shots is one lively word, not a
//                 stack). If the actor goes, the word finishes where it was.
//   "word.hold"   kept over the actor until "word.clear" with the same text, or the actor dies or is removed. Size 1
//                 normal, 2 large and pulsing (about one pulse a second), 0.6 small. Asked again with the same text on
//                 the same actor: its colour and size change in place. Held words stack upward; one-off words start
//                 above them.
//   "pop"         a pixel ring and an eight-point star burst (drawn in code, tools/gen_beams.py) at the actor's middle,
//                 in the colour's four bands, 18 tics. Size scales it (1 = for a monster as tall as an imp).
// Above the HP bar and its markers (a tenth of the actor's height and 10 units over its top). Words grow with distance
// like the bars (Far Size) and follow Word Size. Photosensitive Mode (rsqa_photosafe): no white flicker (a word holds its
// colour), a pulse at most once a second, the pop's white first frames at 40%. Monster Words / Pops off (user rows):
// nothing is drawn; the service still answers 1 (an answer never depends on a player's own setting: netplay).
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
	Vector3 lastPos;
	double lastH;
	Array<RSQVR_WGlyph> gl;
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
	const GLYPH_CAP = 160;
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
	transient Array<TextureID> glyphTex;
	transient Array<TextureID> popFrames;
	transient int readAt;
	transient bool wordsOn, popsOn, photo;
	transient double wordSize, far;

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
			if (w && !w.held && w.who == a && w.text == txt && w.t < w.life) { w.t = 0; w.rgb = rgb & 0xFFFFFF; return 1; }
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
				if (w.clearing) { w.clearing = false; w.t = 0; }
				return 1;
			}
		}
		let w = NewWord(txt, rgb, a);
		w.held = true;
		w.size = clamp(sizeArg, 0.3, 4.0);
		return 1;
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
		w.lastPos = a.Pos; w.lastH = a.Height;
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
			TextureID t0 = FontTex(65);
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
	}
	void FreePop(RSQVR_Pop p) { if (p && p.g) { Release(p.g); p.g = null; } }

	TextureID FontTex(int c)
	{
		if (glyphTex.Size() != 65)
		{
			glyphTex.Clear();
			for (int i = 32; i <= 96; i++) glyphTex.Push(TexMan.CheckForTexture(String.Format("QVW%03d", i), TexMan.Type_Any));
		}
		return glyphTex[clamp(c, 32, 96) - 32];
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
	override void WorldLoaded(WorldEvent e) { EnsureDriver(); }
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
			if (w.who) { w.lastPos = w.who.Pos; w.lastH = w.who.Height; }
			// a held word goes with its actor (dead or gone): a quick fade
			if (w.held && !w.clearing && (!w.who || w.who.health <= 0)) { w.clearing = true; w.clearT = 0; }
			if (!frozen) { w.t++; if (w.clearing) w.clearT++; }
			bool done = w.held ? (w.clearing && w.clearT >= 6) : (w.t >= w.life + 10);
			if (done) { FreeWord(w); words.Delete(i); continue; }
		}
		// stack each actor's held words from the bar up, one-off words above them
		for (int i = 0; i < words.Size(); i++)
		{
			let w = words[i];
			if (!wordsOn || !cam) { HideWord(w); continue; }
			double heldUp = 0;
			for (int j = 0; j < words.Size(); j++)
			{
				let o = words[j];
				if (j == i || !o || o.who != w.who || !o.held) continue;
				if (j < i || !w.held) heldUp += LineH(o, eye);
			}
			DrawWord(w, eye, heldUp, ps);
		}

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
		return BASE_H * wordSize * grow * w.size / RSQVR_BeamData.FONT_H;     // map units per font pixel
	}
	double LineH(RSQVR_Word w, Vector3 eye) { return Unit(w, eye) * RSQVR_BeamData.FONT_H * 1.3; }

	void HideWord(RSQVR_Word w)
	{
		for (int i = 0; i < w.gl.Size(); i++) if (w.gl[i]) w.gl[i].Alpha = 0;
	}

	void DrawWord(RSQVR_Word w, Vector3 eye, double heldUp, double ps)
	{
		int n = int(w.text.Length());
		// its glyphs (one per character that has one; spaces only advance)
		while (w.gl.Size() < n) w.gl.Push(null);
		double u = Unit(w, eye);
		// the life: pop (overshoot) over 4 tics; a held big word pulses (about once a second)
		double popK = w.t == 0 ? 0.45 : (w.t == 1 ? 1.35 : (w.t == 2 ? 1.15 : 1.0));
		double pulse = 1.0;
		if (w.held && w.size >= 1.5) pulse = 1.0 + 0.08 * sin(w.t * 10.3);
		double k = u * popK * pulse;
		double a = 1.0;
		double rise = 0;
		if (w.held) { if (w.clearing) a = 1.0 - w.clearT / 6.0; }
		else
		{
			rise = BASE_H * wordSize * 1.4 * (1.0 - exp(-w.t / 10.0));
			if (w.t > w.life) a = 1.0 - (w.t - w.life) / 10.0;
		}
		// colour: Castlevania's flicker to white for the first 14 tics (2 tics each); never with Photosensitive Mode
		bool white = !w.held && !photo && w.t < 14 && ((w.t / 2) & 1) == 1;
		TranslationID tr = Trans(white ? 0xFFFFFF : w.rgb, true);
		// where: above the actor's HP bar and markers, the held stack below it
		Vector3 anchor = w.lastPos + (0, 0, w.lastH * 1.1 + 10 + heldUp + rise + u * RSQVR_BeamData.FONT_H * 0.5);
		Vector3 d = eye - anchor;
		double dl = d.Length();
		Vector3 toEye = dl > 0.01 ? d / dl : (0, 0, 0);
		// the line's width, font pixels
		double width = 0;
		for (int i = 0; i < n; i++) width += RSQVR_BeamData.FONT_ADV(Code(w.text.ByteAt(i)));
		double cx = -width * 0.5;
		for (int i = 0; i < n; i++)
		{
			int c = Code(w.text.ByteAt(i));
			double adv = RSQVR_BeamData.FONT_ADV(c), gw = RSQVR_BeamData.FONT_W(c);
			let g = w.gl[i];
			if (c == 32 || gw <= 0) { if (g) g.Alpha = 0; cx += adv; continue; }
			bool fresh = false;
			if (!g) { g = Acquire(anchor); w.gl[i] = g; fresh = true; if (!g) { cx += adv; continue; } }
			TextureID tx = FontTex(c);
			if (g.Texture != tx) g.Texture = tx;
			g.Translation = tr;
			g.SetRenderStyle(STYLE_Translucent);     // (a pooled glyph may last have been a pop, drawn Add)
			double sc = k / RSQVR_BeamData.FONT_K;
			g.Scale = (sc, sc);
			g.Offset = ((cx + gw * 0.5) * k, 0);
			g.Alpha = clamp(a, 0.0, 1.0);
			// each glyph a hair nearer than the one before (see-through quads at one depth flicker in the headset)
			Vector3 at = anchor + toEye * (i * 0.03);
			g.Put(at, fresh ? at : g.Pos);
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
		words.Clear(); pops.Clear(); pool.Clear(); freeG.Clear(); beams.Clear();
		driver = null;
	}
}
