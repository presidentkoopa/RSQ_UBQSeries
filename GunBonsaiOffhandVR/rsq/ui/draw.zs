// THE SCREENS' PEN (10-27). Every skin draws in DESIGN UNITS: the owner's mockups were cropped
// to 960x540 and every number in the skins is a pixel of that crop. A pen maps those units to the
// screen -- an origin and a scale -- so a layout is written once and fits whatever the headset's
// 2D layer is (QZD's is near-square, not 16:9: 320x300 on the rig at QZ_RES 300, measured).
//
// Fonts are Doom's own (owner, 10-27: "just use the doom fonts"): SmallFont for labels and card
// titles, BigFont for the big title, NewSmallFont (the face Gun Bonsai's own HUD writes in) for body
// text. A size is the font's line height in design units. Colour is the nearest of the engine's
// text colours (Font.CR_*), since Doom's glyphs are not white and cannot be tinted.
class RSQUI_Pen ui
{
	double ox, oy, u;   // screen px of design (0,0), and screen px per design unit
	double ts;          // RSQ_Accessibility's Text Size (1 = the mockups' own sizes)
	Font fPix, fTerm, fChrome, fOrb;
	// One Shape2D per polygon per frame: the 2D drawer keeps a reference and renders later, so a
	// shape refilled for the next polygon would redraw as that one (or not at all).
	Array<Shape2D> shapes;
	int shapeUsed;
	TextureID white;

	static RSQUI_Pen Make()
	{
		let p = new("RSQUI_Pen");
		p.fPix = SmallFont;
		p.fOrb = SmallFont;
		p.fTerm = NewSmallFont;
		p.fChrome = BigFont;
		p.white = TexMan.CheckForTexture("RSQWHITE", TexMan.Type_Any);
		p.u = 1;
		p.ts = 1;
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
		ts = RSQGB_A11y.Text();
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
		ts = RSQGB_A11y.Text();
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
	// size = the font's line height in design units (times Text Size: the layout stays, the words grow,
	// and wrapped text re-wraps to the same width).
	double Scale(Font f, double size) { return size * ts / max(1, f.GetHeight()) * u; }
	double ScaleY(Font f, double size) { return Scale(f, size); }

	double Width(Font f, double size, String s) { return f.StringWidth(s) * Scale(f, size) / u; }
	double Height(Font f, double size) { return size * ts; }

	// Doom's fonts start their capitals at the top of the line.
	double CapTop(Font f, double size) { return 0; }

	// The engine text colour nearest to c (Doom's glyphs take a translation, not a tint).
	static int NearestCR(Color c)
	{
		static const int crs[] = { Font.CR_WHITE, Font.CR_GRAY, Font.CR_DARKGRAY, Font.CR_RED,
			Font.CR_DARKRED, Font.CR_ORANGE, Font.CR_GOLD, Font.CR_YELLOW, Font.CR_GREEN,
			Font.CR_DARKGREEN, Font.CR_CYAN, Font.CR_LIGHTBLUE, Font.CR_BLUE, Font.CR_PURPLE,
			Font.CR_BRICK, Font.CR_TAN };
		static const int rgb[] = { 0xFFFFFF, 0xB0B0B0, 0x606060, 0xFF3030,
			0xA01010, 0xFF9020, 0xFFC830, 0xFFFF40, 0x40FF40,
			0x208020, 0x40FFFF, 0x80B0FF, 0x4060FF, 0xFF50FF,
			0xFF8070, 0xD0B080 };
		int best = Font.CR_WHITE, bd = 0x7FFFFFFF;
		for (int i = 0; i < 16; i++)
		{
			int dr = c.r - ((rgb[i] >> 16) & 255), dg = c.g - ((rgb[i] >> 8) & 255), db = c.b - (rgb[i] & 255);
			int d = dr * dr + dg * dg + db * db;
			if (d < bd) { bd = d; best = crs[i]; }
		}
		return best;
	}

	// align: 0 left, 1 centre, 2 right. y is the top of the line.
	void Text(Font f, double size, String s, double x, double y, Color c, int align = 0, double alpha = 1.0)
	{
		double k = Scale(f, size);
		double w = f.StringWidth(s) * k / u;
		if (align == 1) x -= w / 2;
		else if (align == 2) x -= w;
		Screen.DrawText(f, NearestCR(c), X(x), Y(y), s,
			DTA_ScaleX, k, DTA_ScaleY, k, DTA_Alpha, alpha);
	}

	void Cap(Font f, double size, String s, double x, double capTop, Color c, int align = 0, double alpha = 1.0)
	{
		Text(f, size, s, x, capTop - CapTop(f, size), c, align, alpha);
	}

	// The big title: BigFont in light blue (the mockups' chrome-blue title).
	void TextRaw(Font f, double size, String s, double x, double y, int align = 0, double alpha = 1.0)
	{
		Text(f, size, s, x, y, Color(255, 0x80, 0xB0, 0xFF), align, alpha);
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
			y += lineh * ts;
		}
		return y;
	}
}
