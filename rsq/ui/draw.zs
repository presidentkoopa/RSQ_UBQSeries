// THE SCREENS' PEN (10-27). Every skin draws in DESIGN UNITS: the owner's mockups were cropped
// to 960x540 and every number in the skins is a pixel of that crop. A pen maps those units to the
// screen -- an origin and a scale -- so a layout is written once and fits whatever the headset's
// 2D layer is (QZD's is near-square, not 16:9: 320x300 on the rig at QZ_RES 300, measured).
//
// Fonts are the baked folders in fonts/ (tools/rsqui_bake.py): rsqui_pix (Press Start 2P, 8 units
// to the em at size 8), rsqui_term (VT323, 16 units at size 16) and rsqui_chrom (Orbitron, 16 at
// size 16). Colour comes from DTA_Color on white glyphs, so one font serves every neon.
class RSQUI_Pen ui
{
	double ox, oy, u;   // screen px of design (0,0), and screen px per design unit
	Font fPix, fTerm, fChrome, fOrb;
	// VT323 is narrower than the mockups' terminal face (cap/advance 1.31 measured there, 1.125 in
	// the baked VT323): it is drawn this much taller than wide.
	const TERM_TALL = 1.16;
	// One Shape2D per polygon per frame: the 2D drawer keeps a reference and renders later, so a
	// shape refilled for the next polygon would redraw as that one (or not at all).
	Array<Shape2D> shapes;
	int shapeUsed;
	TextureID white;

	static RSQUI_Pen Make()
	{
		let p = new("RSQUI_Pen");
		p.fPix = Font.GetFont("rsqui_pix");
		p.fTerm = Font.GetFont("rsqui_term");
		p.fChrome = Font.GetFont("rsqui_chrom");
		p.fOrb = Font.GetFont("rsqui_orb");
		if (!p.fOrb) p.fOrb = SmallFont;
		if (!p.fPix) p.fPix = SmallFont;
		if (!p.fTerm) p.fTerm = NewConsoleFont;
		if (!p.fChrome) p.fChrome = BigFont;
		p.white = TexMan.CheckForTexture("RSQWHITE", TexMan.Type_Any);
		p.u = 1;
		return p;
	}

	// The safe area: the screen minus rsq_ui_inset (a fraction of each side) -- in a headset the
	// screen's own corners sit at the edge of view.
	static double, double, double, double SafeArea()
	{
		double w = Screen.GetWidth(), h = Screen.GetHeight();
		let cv = CVar.FindCVar("rsq_ui_inset");
		double f = cv ? clamp(cv.GetFloat(), 0.0, 0.3) : 0.04;
		return w * f, h * f, w * (1 - 2 * f), h * (1 - 2 * f);
	}

	static double Setting(String n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	// Fit a design box of dw x dh units into the safe area, centred (a menu).
	void FitBox(double dw, double dh, double scaleMul = 1.0, double vpos = 0.5)
	{
		shapeUsed = 0;
		double sx, sy, sw, sh;
		[sx, sy, sw, sh] = SafeArea();
		u = min(sw / dw, sh / dh) * scaleMul;
		ox = sx + (sw - dw * u) * 0.5;
		oy = sy + (sh - dh * u) * vpos;
	}

	// The HUD's frame: one design unit = safe height / 540, scaled by rsq_ui_hud_scale, origin at
	// the safe area's top-left. Anchoring is done by the caller with Left/Right/Top/Bottom.
	double sx, sy, sw, sh;
	void HudFrame()
	{
		shapeUsed = 0;
		[sx, sy, sw, sh] = SafeArea();
		// the mockup's top row (two gauges and the score) needs 660 units across: a near-square
		// headset layer is narrower than the 16:9 mockup, so it scales by width there
		u = min(sh / 540.0, sw / 660.0) * clamp(Setting("rsq_ui_hud_scale", 1.0), 0.4, 2.5);
		ox = sx; oy = sy;
	}
	// Design width of the safe area in HUD units (for right-anchoring).
	double UnitsWide() { return sw / u; }
	double UnitsHigh() { return sh / u; }

	double X(double x) { return ox + x * u; }
	double Y(double y) { return oy + y * u; }

	// ---- fills and lines ----
	// NOT Screen.Dim: in VR, QZD draws Dim outside the HUD layer, onto the eye (DoDim's outside2D,
	// v_draw.cpp) -- measured on the rig: a Dim rect lands in eye space while text lands on the HUD
	// quad. A tinted white texture stays on the HUD layer with everything else.
	void Rect(double x, double y, double w, double h, Color c, double alpha = 1.0)
	{
		if (w <= 0 || h <= 0) return;
		double x0 = X(x), y0 = Y(y);
		if (white.IsValid())
			Screen.DrawTexture(white, false, x0, y0, DTA_DestWidthF, w * u, DTA_DestHeightF, h * u,
				DTA_TopLeft, true, DTA_Color, c | 0xFF000000, DTA_Alpha, alpha);
		else if (alpha >= 0.99)
			Screen.Clear(int(x0), int(y0), int(x0 + w * u), int(y0 + h * u), c);
	}

	void Line(double x0, double y0, double x1, double y1, double t, Color c, double alpha = 1.0)
	{
		Screen.DrawThickLine(X(x0), Y(y0), X(x1), Y(y1), max(1.0, t * u), c, int(255 * alpha));
	}

	// A rectangle outline of thickness t (units), inside the box.
	void Frame(double x, double y, double w, double h, double t, Color c, double alpha = 1.0)
	{
		Rect(x, y, w, t, c, alpha);
		Rect(x, y + h - t, w, t, c, alpha);
		Rect(x, y + t, t, h - 2 * t, c, alpha);
		Rect(x + w - t, y + t, t, h - 2 * t, c, alpha);
	}

	// The mockups' neon: a soft halo, then the bright line.
	void Neon(double x, double y, double w, double h, Color c, double t = 2, double glow = 0.35)
	{
		if (glow > 0)
		{
			Frame(x - 3, y - 3, w + 6, h + 6, 3, c, glow * 0.25);
			Frame(x - 1.5, y - 1.5, w + 3, h + 3, 1.5, c, glow * 0.5);
		}
		Frame(x, y, w, h, t, c, 1.0);
	}

	// A filled convex polygon, points in design units: xs/ys of equal length.
	// DrawShapeFill, with red and blue swapped going in: QZD 17.3 hands this one call's colour to
	// the renderer as BGR (measured on the rig: 0xFFFF00 drew cyan). The textured DrawShape drew
	// nothing on the HUD layer there at all.
	void Poly(Array<double> xs, Array<double> ys, Color c, double alpha = 1.0)
	{
		int n = xs.Size();
		if (n < 3) return;
		if (shapeUsed >= shapes.Size()) shapes.Push(new("Shape2D"));
		let shp = shapes[shapeUsed++];
		shp.Clear();
		for (int i = 0; i < n; i++)
		{
			shp.PushVertex((X(xs[i]), Y(ys[i])));
			shp.PushCoord((0, 0));
		}
		for (int i = 1; i < n - 1; i++) shp.PushTriangle(0, i, i + 1);
		Color bgr = Color(255, c.b, c.g, c.r);
		Screen.DrawShapeFill(bgr, alpha, shp);
	}

	void PolyLine(Array<double> xs, Array<double> ys, double t, Color c, double alpha = 1.0, bool closed = true)
	{
		int n = xs.Size();
		for (int i = 0; i < n - (closed ? 0 : 1); i++)
		{
			int j = (i + 1) % n;
			Line(xs[i], ys[i], xs[j], ys[j], t, c, alpha);
		}
	}

	// ---- textures ----
	// Fit a texture into a box keeping its aspect, centred. Returns false if there was nothing.
	bool Picture(TextureID tex, double x, double y, double w, double h, double alpha = 1.0, Color tint = 0, bool flip = false)
	{
		if (!tex.IsValid()) return false;
		Vector2 sz = TexMan.GetScaledSize(tex);
		if (sz.x <= 0 || sz.y <= 0) return false;
		double k = min(w / sz.x, h / sz.y);
		double dw = sz.x * k, dh = sz.y * k;
		if (tint)
			Screen.DrawTexture(tex, false, X(x + (w - dw) / 2), Y(y + (h - dh) / 2),
				DTA_DestWidthF, dw * u, DTA_DestHeightF, dh * u, DTA_TopLeft, true, DTA_Alpha, alpha,
				DTA_Color, tint, DTA_FlipX, flip);
		else
			Screen.DrawTexture(tex, false, X(x + (w - dw) / 2), Y(y + (h - dh) / 2),
				DTA_DestWidthF, dw * u, DTA_DestHeightF, dh * u, DTA_TopLeft, true, DTA_Alpha, alpha,
				DTA_FlipX, flip);
		return true;
	}

	// ---- text ----
	// size = the font's em in design units (rsqui_pix is 8 at 1x, the others 16).
	double Scale(Font f, double size)
	{
		double em = (f == fPix) ? 8.0 : 16.0;
		return size / em * u;
	}
	double ScaleY(Font f, double size) { return Scale(f, size) * (f == fTerm ? TERM_TALL : 1.0); }

	double Width(Font f, double size, String s)
	{
		return f.StringWidth(s) * Scale(f, size) / u;
	}

	double Height(Font f, double size)
	{
		return f.GetHeight() * ScaleY(f, size) / u;
	}

	// Where a font's capitals start below the y Text() is given, in units (the baked glyphs carry
	// their pad and outline): measured off the baked 'L's.
	double CapTop(Font f, double size)
	{
		if (f == fPix) return size / 8;
		if (f == fTerm) return 5.0 * TERM_TALL * size / 16;
		if (f == fOrb) return 5.75 * size / 16;
		if (f == fChrome) return 6.75 * size / 16;
		return 0;
	}

	// align: 0 left, 1 centre, 2 right. y is the top of the line.
	void Text(Font f, double size, String s, double x, double y, Color c, int align = 0, double alpha = 1.0)
	{
		double k = Scale(f, size), ky = ScaleY(f, size);
		double w = f.StringWidth(s) * k / u;
		if (align == 1) x -= w / 2;
		else if (align == 2) x -= w;
		Screen.DrawText(f, Font.CR_UNTRANSLATED, X(x), Y(y), s,
			DTA_ScaleX, k, DTA_ScaleY, ky, DTA_Color, c, DTA_Alpha, alpha);
	}

	// Text placed by the top of its capitals (how the mockups were measured).
	void Cap(Font f, double size, String s, double x, double capTop, Color c, int align = 0, double alpha = 1.0)
	{
		Text(f, size, s, x, capTop - CapTop(f, size), c, align, alpha);
	}

	// Untinted (the title font carries its own colour).
	void TextRaw(Font f, double size, String s, double x, double y, int align = 0, double alpha = 1.0)
	{
		double k = Scale(f, size), ky = ScaleY(f, size);
		double w = f.StringWidth(s) * k / u;
		if (align == 1) x -= w / 2;
		else if (align == 2) x -= w;
		Screen.DrawText(f, Font.CR_UNTRANSLATED, X(x), Y(y), s,
			DTA_ScaleX, k, DTA_ScaleY, ky, DTA_Alpha, alpha);
	}

	// Gun Bonsai colours some names (\c[GREEN]Venomous Inscription): the skins colour by card.
	static String Plain(String s)
	{
		String o = "";
		int n = s.Length();
		int i = 0;
		while (i < n)
		{
			int c, nx;
			[c, nx] = s.GetNextCodePoint(i);
			if (c == 0x1C || (c == 0x5C && nx < n && (s.ByteAt(nx) | 0x20) == 0x63))
			{
				i = nx + (c == 0x1C ? 0 : 1);   // past the 'c'
				if (i < n && s.ByteAt(i) == 0x5B) { while (i < n && s.ByteAt(i) != 0x5D) i++; i++; }
				else i++;                          // a one-letter colour
				continue;
			}
			o.AppendCharacter(c);
			i = nx;
		}
		return o;
	}

	// Word-wrap s to width w (units); returns the lines.
	void Wrap(Font f, double size, String s, double w, out Array<String> lines)
	{
		lines.Clear();
		Array<String> paras;
		s.Split(paras, "\n");
		for (int p = 0; p < paras.Size(); p++)
		{
			Array<String> words;
			paras[p].Split(words, " ", TOK_SKIPEMPTY);
			String cur = "";
			for (int i = 0; i < words.Size(); i++)
			{
				String t = cur == "" ? words[i] : cur .. " " .. words[i];
				if (cur != "" && Width(f, size, t) > w)
				{
					lines.Push(cur);
					cur = words[i];
				}
				else cur = t;
			}
			lines.Push(cur);
		}
	}

	// Wrapped text block; returns the y below it.
	double Para(Font f, double size, String s, double x, double y, double w, double lineh, Color c, int maxLines = 99, double alpha = 1.0)
	{
		Array<String> lines;
		Wrap(f, size, s, w, lines);
		for (int i = 0; i < lines.Size() && i < maxLines; i++)
		{
			Text(f, size, lines[i], x, y, c, 0, alpha);
			y += lineh;
		}
		return y;
	}
}
