// RSQ HP Bars -- Damage Numbers: the glyphs, drawn with the engine's VisualThinker (QZD 17.3, visualthinker.zs).
//
// WHY A VISUALTHINKER. damnums drew one Actor per digit with baked digit-position sprites: 280 sprite frames a font, in a
// load order near the engine's 65,535. A VisualThinker takes a TEXTURE (graphics/rsqthpdn, tools/gen_dn_art.py), so the
// numbers cost NO sprite frames, and it has no states, no blockmap link and no collision: lighter than an actor.
//   - Where a digit sits in its number is the VisualThinker's Offset: a shift in world units along the view's side and up
//     vectors, applied by the renderer around the glyph (hw_sprites.cpp HandleSpriteOffsets). Every glyph of a number
//     stands on the same point and is shifted sideways by its column, so the number reads left to right from any angle.
//   - STEREO: the renderer builds a VisualThinker's quad once per frame from the CENTRE eye (CalculateVertices is handed
//     Viewpoint.CenterEyePos), so both eyes see the same quad in the world at its real depth; rig frames of both eyes:
//     test/evidence/dn_stereo_*.png.
//   - The pool's glyphs sit on a NON-TICKING statnum (STAT_GLYPH < STAT_FIRST_THINKING): the engine never ticks them. One
//     driver (RSQTHP_DnDriver, after every actor has moved) places all of them, setting Prev and Pos itself so the renderer
//     interpolates between tics (InterpolatedPosition), and calls UpdateSector as visualthinker.zs asks for a moved
//     non-ticking one. A free glyph is Alpha 0: the renderer skips it (ProcessParticle returns at alpha <= 0).
class RSQTHP_Glyph : VisualThinker
{
	const STAT_GLYPH = 30;      // below STAT_FIRST_THINKING (32): never ticked by the engine; not STAT_STATIC (kept across maps)
	Name curTrans;
	bool rolling;

	void Put(Vector3 p, Vector3 prev)
	{
		Prev = prev;
		Pos = p;
		UpdateSector();
	}
	void Hide() { Alpha = 0; }
	void Look(TextureID t, Name trans)
	{
		if (Texture != t) Texture = t;
		if (curTrans != trans) { curTrans = trans; SetTranslation(trans); }
	}
	void SetRolling(bool r, double ang = 0)
	{
		if (r != rolling) { rolling = r; if (r) Flags |= SPF_ROLL; else Flags &= ~SPF_ROLL; }
		PrevRoll = Roll;
		Roll = r ? ang : 0;
	}
}

// One post-thinker driver per map: every number is moved here, after all actors (statnum 100) have moved and dealt this
// tic's damage, so a running total stands on its monster's bar with no tic of lag and a hit shows the tic it lands.
class RSQTHP_DnDriver : Thinker
{
	RSQTHP_DamNumHandler h;
	override void Tick() { if (h) h.Step(); }
}

// The fonts (texture names RQN<F><Q><HH>, tools/gen_dn_art.py): F J JFO metal digits, S JFO small, E Ermac's digits,
// C / D damnums' Doom Classic / Doom Small; Q 0 Quest (half resolution), 1 PCVR; HH the ASCII code in hex.
// Textures are looked up once and kept (transient: looked up again after a load).
class RSQTHP_DnFonts play
{
	enum EFont { F_JFO, F_SMALL, F_ERMAC, F_CLASSIC, F_CLASSIC_SMALL, F_COUNT }
	static const String LETTER[] = { "J", "S", "E", "C", "D" };
	// a digit's height in the world at size 1, map units, and the advance as a share of a glyph's width (JFO's beveled
	// cells overlap a little, as the mockups set them; the pixel fonts get a small gap)
	static const double BASEH[] = { 9.0, 4.8, 8.0, 11.0, 6.5 };
	static const double ADV[] = { 0.84, 0.80, 1.08, 1.02, 1.12 };

	transient Array<TextureID> tex;
	transient Array<double> tw, th;
	transient bool made;

	void Make()
	{
		made = true;
		tex.Clear(); tw.Clear(); th.Clear();
		int n = F_COUNT * 2 * 128;
		for (int i = 0; i < n; i++) { TextureID t; tex.Push(t); tw.Push(-1); th.Push(-1); }
	}

	// the texture of a glyph, its size in pixels (0 x 0: none in this font)
	TextureID Glyph(int font, int q, int code, out double w, out double h)
	{
		if (!made) Make();
		int i = (font * 2 + q) * 128 + (code & 127);
		if (tw[i] < 0)
		{
			String nm = String.Format("RQN%s%d%02X", LETTER[font], q, code);
			TextureID t = TexMan.CheckForTexture(nm, TexMan.Type_Any);
			tex[i] = t;
			if (t.IsValid()) { int iw, ih; [iw, ih] = TexMan.GetSize(t); tw[i] = iw; th[i] = ih; }
			else { tw[i] = 0; th[i] = 0; }
		}
		w = tw[i]; h = th[i];
		return tex[i];
	}
}
