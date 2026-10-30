// wr_q_shim.zs -- RSQ Wheel: what REMA's engine gave the ring, done in ZScript on stock
// QuestZDoom 17.3. The ring's own code calls these exactly where it called the engine
// (level.AddBillboardPersistent became wr_BB.AddBillboardPersistent, and so on), so the ring
// file stays a near line-for-line copy of REMA's and a fix on one side can be carried across.
//
// THREE PARTS:
//   wr_BB      the billboard system: world quads with yaw/tilt/roll, groups that scale about an
//              origin, text, bars, ray and touch hit tests. Drawn with model actors.
//   wr_Field   REMA's field reflection (read another mod's field by name). Stock ZScript has
//              none, so every read answers "not there" and the compat readers stay quiet.
//   wr_VR      input suppression, the pointing laser, haptics and the raw stick.
//
// WHY ACTORS AND NOT CANVAS TEXTURES. A canvas is the obvious way to paint a card, and REMA's
// wheel had that path (wr_canvas). It does not work here: QZD 17.3's Draw2D skips its viewport
// and its 2D projection whenever a VR mode is on (hw_draw2d.cpp, "In vr mode viewport setting
// ... is already done in FGLRenderer::Flush()"), so a canvas drawn in a headset comes out
// black. Measured on the 17.3 rig: canvas black, camera texture fine. So every billboard is a
// unit quad model (models/wrq/quad.obj) placed, turned and scaled each tic, and text is a strip
// of cells (models/wrq/strip4/8/12/24.obj), one per character, skinned per surface.
//
// EVERYTHING IS THE WAD'S OWN ART (the owner: "wad based fonts and textures, we want it to look
// natural"; WHEEL_WORK_QUEUE.md item 3). Through TEXTURES, by lump name, never copied:
//   cards and the sheet   STBAR's health box, the recessed rounded stone panel   WRPLATE
//   bars, accents         plain stone from the same box                          WRSTONE
//   words                 DoomFont, STCFN033..095, in 9x7 cells                  WRGxxx
//   numbers               the status bar's big numerals, STTNUM0..9 and friends   WRDxxx
// Colour is a palette translation built at run time from each colour, mapping every palette
// entry's brightness onto it -- Doom's own way of colouring fonts -- so the stone keeps its grain
// and a glyph its edge. tools/gen_assets.py writes the TEXTURES, the models and the palette's
// luminance table (wr_q_pallum.zs).
//
// GEOMETRY MATCHES REMA's BillboardBasis exactly (g_levellocals.h):
//   face  F = ( cos y,  sin y, 0)          right R = (-sin y, cos y, 0)
//   up    U = (-cos y sin t, -sin y sin t, cos t)    normal N = R x U
//   roll turns R toward U:  R' = R cos r + U sin r,  U' = U cos r - R sin r
// On the actor that is angle = yaw, pitch = -tilt, roll = roll (checked on the rig with an
// asymmetric test texture: upright, unmirrored, roll counter-clockwise).
//
// NETPLAY: these are real actors, so they exist on every machine; the ring builds them from
// players[consoleplayer] exactly as REMA's ring does. Single player is what this is built for.

//==========================================================================
// One billboard.
//==========================================================================
class wr_BBRec play
{
	int     id;
	Vector3 pos;
	double  w, h, yaw, tilt, roll;
	int     facing, payload, data, flags, group, order;
	color   col, col2;
	double  alpha;
	string  text;
	int     expire;          // maptime it dies at, 0 = never

	// What the parts are showing; rebuilt when payload/data/text/colour change.
	bool    lookDirty;
	Array<Actor> parts;
	// per part: offset in the quad's plane as a fraction of half-size (x right, y up), and its
	// own half-extent as a fraction of the billboard's -- or, for a glyph strip, cell size
	Array<double> pOX, pOY, pSX, pSY;
	Array<int>    pKind;     // 0 quad, 1 glyph strip
}

class wr_BBGroup play
{
	int     id;
	Vector3 origin;
	double  from, to;
	int     startTic, durTics;
}

class wr_BBQuad : Actor
{
	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTONAUTOMAP
		+INTERPOLATEANGLES
		+NOTIMEFREEZE
		RenderStyle "Translucent";
		Alpha 1.0;
		Radius 1;
		Height 1;
	}
	States { Spawn: WRBQ A -1; Stop; }
}
class wr_BBStrip : wr_BBQuad {}

//==========================================================================
// The host: one EventHandler holding every billboard, registered AFTER wr_Rig so its
// WorldTick (front-to-back) lays the quads out after the ring has moved them this tic.
//==========================================================================
class wr_BB : EventHandler
{
	// REMA's payload / facing / flag numbers (doombase.zs EBillboard*), so call sites keep
	// their meaning.
	enum EPayload
	{
		BB_PANEL = 0, BB_TEXTURE = 1, BB_DIGITS = 2, BB_GLYPH = 3, BB_RING = 4, BB_BAR = 5,
		BB_TEXT = 6, BB_SEGMENT = 7, BB_SEGLCD = 8, BB_SEAM = 9, BB_WG13 = 10,
		BB_SDFPANEL = 11, BB_SDFHEX = 12, BB_SDFSTAR = 13, BB_NEON = 14
	}
	enum EFacing { BBF_FIXED = 0, BBF_CAMERAYAW = 1, BBF_CAMERA = 2 }
	enum EFlags
	{
		BBFL_PERSISTENT = 1, BBFL_ATTACHED = 2, BBFL_NODEPTH = 4, BBFL_VIEWLOCKED = 8,
		BBFL_FOLLOWANGLE = 16, BBFL_NOHIT = 32, BBFL_VOID = 64, BBFL_HANDMAIN = 128,
		BBFL_HANDOFF = 256, BBFL_FLIPU = 512, BBFL_STEREO = 1024, BBFL_AGED = 2048, BBFL_STEADY = 4096
	}

	const STRIP_CELLS = 24;
	const CELL_ASPECT = 9.0 / 7.0;      // a WRGxxx DoomFont cell is 9 x 7 pixels
	const NUM_ASPECT  = 14.0 / 16.0;    // a WRDxxx status bar numeral cell is 14 x 16
	const LAYER_STEP  = 0.03;           // map units toward the viewer per creation order step

	Map<int, wr_BBRec>   mRecs;
	Array<wr_BBRec>      mList;         // same records, in creation order, for iteration
	Array<wr_BBGroup>    mGroups;
	int mNextId, mNextGid, mOrder;

	//----------------------------------------------------------------------
	static wr_BB Get() { return wr_BB(EventHandler.Find("wr_BB")); }

	private wr_BBRec rec(int id)
	{
		if (id <= 0 || !mRecs.CheckKey(id)) return null;
		return mRecs.Get(id);
	}
	private wr_BBGroup grp(int gid)
	{
		if (gid <= 0) return null;
		for (int i = 0; i < mGroups.Size(); i++) if (mGroups[i].id == gid) return mGroups[i];
		return null;
	}

	//======================================================================
	// The REMA API, static, same names and arguments.
	//======================================================================
	static int AddBillboardPersistent(Vector3 pos, double w, double h, double yaw, double tilt, int facing, int payload, int data, color col, int flags = 0, double lifetime = 0, string text = "")
	{
		let b = Get(); if (!b) return 0;
		return b.add(pos, w, h, yaw, tilt, facing, payload, data, col, flags, 0, text);
	}
	static void AddBillboard(Vector3 pos, double w, double h, double yaw, double tilt, int facing, int payload, int data, color col, int flags = 0, double lifetime = 0, string text = "")
	{
		let b = Get(); if (!b) return;
		// A transient billboard: REMA draws it for its lifetime (or one frame at 0). Here it
		// lives that many tics, and at least one so it is ever seen.
		int tics = max(1, int(lifetime * TICRATE + 0.5));
		b.add(pos, w, h, yaw, tilt, facing, payload, data, col, flags | BBFL_NOHIT, level.maptime + tics, text);
	}
	static void UpdateBillboard(int id, int data, color col)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		if (r.data != data || r.col != col) { r.data = data; r.col = col; r.lookDirty = true; }
	}
	static void SetBillboardText(int id, string text)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		if (r.text != text) { r.text = text; r.lookDirty = true; }
	}
	// Neon halo, a second gradient colour, a reveal: shader effects with no stand-in here.
	static void SetBillboardGlow(int id, double radius, double strength) {}
	static void SetBillboardGradient(int id, color col2)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.col2 = col2;
	}
	static void SetBillboardProgress(int id, double t) {}
	static void SetBillboardFont(int id, int slot) {}

	// Width a single line draws at this height: DoomFont cells are 9 x 7, one per character.
	static clearscope double MeasureBillboardText(string text, double height, int fontSlot = 0)
	{
		return text.CodePointCount() * height * CELL_ASPECT;
	}
	static clearscope Vector2 MeasureBillboardTextBlock(string text, double height, int fontSlot = 0)
	{
		Array<string> lines;
		text.Split(lines, "\n");
		int widest = 0;
		for (int i = 0; i < lines.Size(); i++) widest = max(widest, lines[i].CodePointCount());
		return (widest * height * CELL_ASPECT, max(1, lines.Size()) * height);
	}

	static void MoveBillboard(int id, Vector3 pos)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.pos = pos;
	}
	static void OrientBillboard(int id, double yaw, double tilt, int facing)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		r.yaw = yaw; r.tilt = tilt; r.facing = facing;
	}
	static void RollBillboard(int id, double roll)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.roll = roll;
	}
	static void ResizeBillboard(int id, double w, double h)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		r.w = w; r.h = h;
	}
	static void SetBillboardAlpha(int id, double alpha)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.alpha = clamp(alpha, 0.0, 1.0);
	}
	static void RemoveBillboard(int id)
	{
		let b = Get(); if (!b) return; b.remove(id);
	}

	static int AddBillboardGroup(Vector3 origin)
	{
		let b = Get(); if (!b) return 0;
		let g = new("wr_BBGroup");
		g.id = ++b.mNextGid; g.origin = origin; g.from = 1; g.to = 1; g.durTics = 0;
		b.mGroups.Push(g);
		return g.id;
	}
	static void SetBillboardGroup(int id, int gid)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.group = gid;
	}
	static void SetBillboardGroupScale(int gid, double scale)
	{
		let b = Get(); if (!b) return; let g = b.grp(gid); if (!g) return;
		g.from = scale; g.to = scale; g.durTics = 0;
	}
	static void AnimateBillboardGroup(int gid, double from, double to, int tics)
	{
		let b = Get(); if (!b) return; let g = b.grp(gid); if (!g) return;
		g.from = from; g.to = to; g.startTic = level.maptime; g.durTics = max(0, tics);
	}
	static void SetBillboardGroupOrigin(int gid, Vector3 origin)
	{
		let b = Get(); if (!b) return; let g = b.grp(gid); if (g) g.origin = origin;
	}
	static void RemoveBillboardGroup(int gid)
	{
		let b = Get(); if (!b) return;
		for (int i = 0; i < b.mGroups.Size(); i++) if (b.mGroups[i].id == gid) { b.mGroups.Delete(i); break; }
	}

	// Ray versus billboard: the nearest hittable one the ray crosses, and where (u left to
	// right, v top to bottom) -- REMA's AimBillboard, same rules.
	static int, Vector2 AimBillboard(Vector3 start, Vector3 dir, double maxDist = 0)
	{
		int id; Vector2 uv; double t;
		[id, uv, t] = AimBillboardT(start, dir, maxDist);
		return id, uv;
	}

	// The same, with how far along the ray the hit is (0 on a miss). RSQ's own, for the beams.
	static int, Vector2, double AimBillboardT(Vector3 start, Vector3 dir, double maxDist = 0)
	{
		let b = Get(); if (!b) return 0, (0, 0), 0;
		double dl = dir.Length();
		if (dl <= 0) return 0, (0, 0), 0;
		dir /= dl;
		int best = 0; double bestT = maxDist > 0 ? maxDist : 1e30; Vector2 bestUV = (0, 0);
		for (int i = 0; i < b.mList.Size(); i++)
		{
			let r = b.mList[i];
			if (!b.hittable(r)) continue;
			Vector3 c, vR, vU, vN; double hw, hh;
			[c, hw, hh] = b.resolve(r, start);
			vR = b.mR; vU = b.mU; vN = b.mN;
			double den = vN dot dir;
			if (abs(den) < 1e-9) continue;
			double t = (vN dot (c - start)) / den;
			if (t <= 0 || t >= bestT) continue;
			Vector3 rel = (start + dir * t) - c;
			double ac = rel dot vR, dn = rel dot vU;
			if (abs(ac) > hw || abs(dn) > hh) continue;
			bestT = t; best = r.id;
			bestUV = ((ac + hw) / (hw * 2), (hh - dn) / (hh * 2));
		}
		return best, bestUV, best ? bestT : 0;
	}

	// Point versus billboard: the nearest whose face the point is within maxRange of and inside
	// the bounds of -- REMA's TouchBillboard.
	static int, Vector2, double TouchBillboard(Vector3 point, double maxRange = 0)
	{
		let b = Get(); if (!b) return 0, (0, 0), 0;
		int best = 0; double bestD = maxRange > 0 ? maxRange : 1e30; Vector2 bestUV = (0, 0);
		for (int i = 0; i < b.mList.Size(); i++)
		{
			let r = b.mList[i];
			if (!b.hittable(r)) continue;
			Vector3 c; double hw, hh;
			[c, hw, hh] = b.resolve(r, point);
			Vector3 vR = b.mR, vU = b.mU, vN = b.mN;
			Vector3 rel = point - c;
			double d = abs(rel dot vN);
			if (d > bestD) continue;
			double ac = rel dot vR, dn = rel dot vU;
			if (abs(ac) > hw || abs(dn) > hh) continue;
			bestD = d; best = r.id;
			bestUV = ((ac + hw) / (hw * 2), (hh - dn) / (hh * 2));
		}
		return best, bestUV, best ? bestD : 0;
	}

	//======================================================================
	// Implementation
	//======================================================================
	private int add(Vector3 pos, double w, double h, double yaw, double tilt, int facing, int payload, int data, color col, int flags, int expire, string text)
	{
		let r = new("wr_BBRec");
		r.id = ++mNextId;
		r.pos = pos; r.w = w; r.h = h; r.yaw = yaw; r.tilt = tilt; r.roll = 0;
		r.facing = facing; r.payload = payload; r.data = data; r.col = col; r.col2 = col;
		r.flags = flags; r.text = text; r.alpha = 1.0; r.expire = expire;
		r.order = ++mOrder;
		r.lookDirty = true;
		mRecs.Insert(r.id, r);
		mList.Push(r);
		return r.id;
	}

	private void remove(int id)
	{
		let r = rec(id);
		if (!r) return;
		clearParts(r);
		mRecs.Remove(id);
		int i = mList.Find(r);
		if (i < mList.Size()) mList.Delete(i);
	}

	private void clearParts(wr_BBRec r)
	{
		for (int i = 0; i < r.parts.Size(); i++) if (r.parts[i]) r.parts[i].Destroy();
		r.parts.Clear(); r.pOX.Clear(); r.pOY.Clear(); r.pSX.Clear(); r.pSY.Clear(); r.pKind.Clear();
	}

	private bool hittable(wr_BBRec r)
	{
		if (r.flags & BBFL_NOHIT) return false;
		if (r.group && groupScale(r.group) <= 0) return false;
		return true;
	}

	// The group's scale this tic. REMA's curves: growth eases out with a slight overshoot,
	// collapse eases in (g_levellocals.h BillboardGroupScale), evaluated at tic rate here.
	double groupScale(int gid, Vector3 o = (0, 0, 0))
	{
		let g = grp(gid);
		if (!g) return 1.0;
		if (g.durTics <= 0) return g.to;
		double t = (level.maptime - g.startTic) / double(g.durTics);
		if (t <= 0) return g.from;
		if (t >= 1) return g.to;
		double e;
		if (g.to >= g.from) { double c = 0.6, u = t - 1; e = 1 + (c + 1) * u * u * u + c * u * u; }
		else e = t * t;
		double s = g.from + (g.to - g.from) * e;
		return s > 0 ? s : 0;
	}

	// The basis of the last resolve(): its right, up and normal.
	Vector3 mR, mU, mN;

	// Where a billboard is and how it is turned, seen from `eye` (camera-facing ones turn to
	// it). Returns centre and half-extents and leaves the basis in mR/mU/mN.
	private Vector3, double, double resolve(wr_BBRec r, Vector3 eye)
	{
		Vector3 c = r.pos;
		double s = 1.0;
		if (r.group)
		{
			let g = grp(r.group);
			if (g)
			{
				s = groupScale(r.group);
				c = g.origin + (r.pos - g.origin) * s;
			}
		}
		double useYaw = r.yaw, useTilt = r.tilt, useRoll = r.roll;
		if (r.facing == BBF_CAMERAYAW || r.facing == BBF_CAMERA)
		{
			Vector3 d = eye - c;
			useYaw = atan2(d.y, d.x);
			if (r.facing == BBF_CAMERA) useTilt = atan2(d.z, d.xy.Length());
		}
		double cy = cos(useYaw), sy = sin(useYaw), ct = cos(useTilt), st = sin(useTilt);
		Vector3 bR = (-sy, cy, 0);
		Vector3 bU = (-cy * st, -sy * st, ct);
		if (useRoll != 0)
		{
			double cr = cos(useRoll), sr = sin(useRoll);
			Vector3 r0 = bR, u0 = bU;
			bR = r0 * cr + u0 * sr;
			bU = u0 * cr - r0 * sr;
		}
		mR = bR; mU = bU; mN = bR cross bU;
		mYaw = useYaw; mTilt = useTilt; mRoll = useRoll;
		double g = max(s, 0.01);
		return c, r.w * 0.5 * g, r.h * 0.5 * g;
	}
	double mYaw, mTilt, mRoll;

	//----------------------------------------------------------------------
	// Building what a billboard shows.
	//----------------------------------------------------------------------
	private Actor newPart(wr_BBRec r, class<Actor> cls, double ox, double oy, double sx, double sy, int kind)
	{
		let a = Actor.Spawn(cls, r.pos);
		if (!a) return null;
		r.parts.Push(a); r.pOX.Push(ox); r.pOY.Push(oy); r.pSX.Push(sx); r.pSY.Push(sy); r.pKind.Push(kind);
		return a;
	}

	// Turn a quad actor so its face normal is n and its width runs along w (both unit). The
	// basis above inverted: N = (cy ct, sy ct, st), so yaw and tilt come from n, and roll is
	// whatever turns R onto w.
	static void OrientQuad(Actor a, Vector3 n, Vector3 w)
	{
		double yaw = atan2(n.y, n.x), tilt = asin(clamp(n.z, -1.0, 1.0));
		double cy = cos(yaw), sy = sin(yaw), ct = cos(tilt), st = sin(tilt);
		Vector3 bR = (-sy, cy, 0), bU = (-cy * st, -sy * st, ct);
		a.angle = yaw;
		a.pitch = -tilt;
		a.roll = atan2(w dot bU, w dot bR);
	}

	// COLOUR THE DOOM WAY: a palette translation that maps each palette entry's brightness onto
	// the wanted colour (TRNSLATE's %[0,0,0]:[r,g,b] ramp, built at run time), so a WAD graphic
	// keeps its own shading -- the stone's grain, a glyph's edge -- and only its hue changes.
	// Doom colours its fonts the same way. One translation per colour, kept for the session.
	Array<int>            mTransKey;
	Array<TranslationID>  mTransId;

	TranslationID TransFor(color c)
	{
		int key = (c.r << 16) | (c.g << 8) | c.b;
		for (int i = 0; i < mTransKey.Size(); i++) if (mTransKey[i] == key) return mTransId[i];
		Translation t;
		for (int k = 0; k < 256; k++)
		{
			// brightness 0..1, lifted so a mid-grey stone reads as the colour rather than as
			// its shadow (the status bar's stone sits around 60-90 of 255), plus a little of the
			// stone's own grey so a dark card colour still shows the grain instead of going flat
			double l = wr_PalLum.LUM[k] / 255.0;
			double v = min(1.0, l * 2.2);
			double g = min(255.0, l * 255.0 * 0.45);
			t.colors[k] = color(255, int(min(255.0, c.r * v + g)), int(min(255.0, c.g * v + g)), int(min(255.0, c.b * v + g)));
		}
		t.colors[0] = color(0, 0, 0, 0);   // index 0 is a patch's transparency; it must stay clear
		TranslationID id = t.AddTranslation();
		mTransKey.Push(key);
		mTransId.Push(id);
		return id;
	}

	void Tint(Actor a, color c, double alpha, bool recolour)
	{
		a.A_SetRenderStyle(alpha, STYLE_Translucent);
		if (recolour) a.Translation = TransFor(c);
	}

	private void setSkin(Actor a, string tex)
	{
		a.A_ChangeModel("", 0, "", "", 0, "", tex);
	}

	// Text: the string fitted into the box the way REMA's bitmap glyphs are (centred, scaled to
	// whichever of width or height runs out first), one strip of 24 cells per line or part line.
	// Numbers -- the ammo count, a percentage -- in the status bar's own numerals, as Doom draws
	// them; anything with a letter in it in DoomFont.
	static bool AllNumeral(string t)
	{
		if (t.Length() == 0) return false;
		for (int i = 0; i < t.Length(); i++)
		{
			int c = t.ByteAt(i);
			if (!((c >= 48 && c <= 57) || c == 37 || c == 45)) return false;
		}
		return true;
	}

	private void buildText(wr_BBRec r, string text)
	{
		text = text.MakeUpper();
		bool num = AllNumeral(text);
		double aspect = num ? NUM_ASPECT : CELL_ASPECT;
		string pfx = num ? "WRD" : "WRG", blank = num ? "WRDBLNK" : "WRGBLNK";
		Array<string> lines;
		text.Split(lines, "\n");
		if (lines.Size() == 0) return;
		int widest = 1;
		for (int i = 0; i < lines.Size(); i++) widest = max(widest, lines[i].CodePointCount());
		// cell size as a fraction of the box: fit widest x lines cells into w x h
		double cellH = min(1.0 / lines.Size(), (r.w / max(r.h, 0.001)) / (widest * aspect));
		double cellW = cellH * aspect * (r.h / max(r.w, 0.001));   // as a fraction of w
		int n = lines.Size();
		for (int li = 0; li < n; li++)
		{
			string ln = lines[li];
			int len = ln.CodePointCount();
			double rowY = (n - 1) * 0.5 - li;          // in cells, +up
			double x0 = -len * cellW * 0.5;            // left edge, fraction of w
			for (int k0 = 0; k0 < max(len, 1); k0 += STRIP_CELLS)
			{
				let a = newPart(r, "wr_BBStrip", (x0 + k0 * cellW) * 2.0, rowY * cellH * 2.0, cellW * 2.0, cellH * 2.0, 1);
				if (!a) continue;
				// the shortest strip that holds this piece (every cell is drawn, glyph or not)
				int need = min(STRIP_CELLS, len - k0);
				int cells = need <= 4 ? 4 : need <= 8 ? 8 : need <= 12 ? 12 : STRIP_CELLS;
				if (cells != STRIP_CELLS)
					a.A_ChangeModel("", 0, "models/wrq", String.Format("strip%d.obj", cells), 0, "", "", 0);
				for (int k = 0; k < cells; k++)
				{
					string g = blank;
					int ci = k0 + k;
					if (ci < len)
					{
						int ch = ln.ByteAt(ci);
						if (ch >= 33 && ch <= 95) g = String.Format("%s%03d", pfx, ch);
					}
					a.A_ChangeModel("", 0, "", "", k, "", g, CMDL_USESURFACESKIN);
				}
			}
		}
	}

	static string PlateFor(wr_BBRec r)
	{
		double ar = r.w / max(r.h, 0.001);
		return (ar > 4.0 || ar < 0.25) ? "WRSTONE" : "WRPLATE";
	}

	private void build(wr_BBRec r)
	{
		clearParts(r);
		switch (r.payload)
		{
		case BB_TEXTURE:
		{
			// REMA passes TextureID.GetIndex() in data; the ring's call sites here pass the
			// texture's NAME in text as well, since an index cannot be turned back into one.
			let a = newPart(r, "wr_BBQuad", 0, 0, 1, 1, 0);
			if (a && r.text != "") setSkin(a, r.text);
			break;
		}
		case BB_BAR:
		{
			let tr = newPart(r, "wr_BBQuad", 0, 0, 1, 1, 0);           // track
			if (tr) setSkin(tr, "WRSTONE");
			double fill = clamp(r.data, 0, 100) / 100.0;
			if (fill > 0) { let fl = newPart(r, "wr_BBQuad", -(1.0 - fill), 0, fill, 1, 0); if (fl) setSkin(fl, "WRSTONE"); }
			break;
		}
		case BB_TEXT:
		case BB_SEGMENT:
		case BB_SEGLCD:
			buildText(r, r.text);
			break;
		case BB_DIGITS:
		case BB_WG13:
			buildText(r, String.Format("%d", r.data));
			break;
		case BB_GLYPH:
			buildText(r, String.Format("%c", clamp(r.data, 1, 255)));
			break;
		default:
			// PANEL, SDFPANEL, RING, SEAM, SDFHEX, SDFSTAR, NEON: the status bar's stone in the
			// billboard's colour -- its bevelled health box for a card, plain stone for a strip.
			{ let a = newPart(r, "wr_BBQuad", 0, 0, 1, 1, 0); if (a) setSkin(a, PlateFor(r)); break; }
		}
		r.lookDirty = false;
	}

	//----------------------------------------------------------------------
	// Every tic: expire, build, place.
	//----------------------------------------------------------------------
	override void WorldTick()
	{
		let pp = players[consoleplayer];
		if (!pp.mo) return;
		Vector3 eye = (pp.mo.pos.xy, pp.viewz);

		for (int i = mList.Size() - 1; i >= 0; i--)
		{
			let r = mList[i];
			if (r.expire > 0 && level.maptime >= r.expire) { remove(r.id); continue; }
		}

		for (int i = 0; i < mList.Size(); i++)
		{
			let r = mList[i];
			if (r.lookDirty) build(r);
			place(r, eye);
		}
	}

	private void place(wr_BBRec r, Vector3 eye)
	{
		Vector3 c; double hw, hh;
		[c, hw, hh] = resolve(r, eye);
		double s = r.group ? groupScale(r.group) : 1.0;
		bool hide = (s <= 0) || (r.alpha <= 0.001) || (hw <= 0.0005) || (hh <= 0.0005);
		// later-made quads sit a hair nearer the viewer, so the label always wins over its plate
		Vector3 lift = mN * (LAYER_STEP * (r.order % 64));
		bool recolour = (r.payload != BB_TEXTURE);   // a weapon sprite keeps its own colours
		for (int p = 0; p < r.parts.Size(); p++)
		{
			let a = r.parts[p];
			if (!a) continue;
			if (hide) { a.bInvisible = true; continue; }
			a.bInvisible = false;
			color pc = r.col;
			if (r.payload == BB_BAR && p == 0) pc = color(r.col.r / 4, r.col.g / 4, r.col.b / 4);
			Tint(a, pc, r.alpha, recolour);
			Vector3 at;
			if (r.pKind[p] == 1)
			{
				// glyph strip: origin is its left edge, cells run right; scale is one cell
				at = c + mR * (r.pOX[p] * hw) + mU * (r.pOY[p] * hh) + lift;
				a.scale = (r.pSX[p] * hw, r.pSY[p] * hh);
			}
			else
			{
				at = c + mR * (r.pOX[p] * hw) + mU * (r.pOY[p] * hh) + lift;
				a.scale = (r.pSX[p] * hw * 2, r.pSY[p] * hh * 2);
			}
			// the plate under a bar's fill sits behind it
			if (r.payload == BB_BAR && p == 1) at += mN * (LAYER_STEP * 0.5);
			a.SetOrigin(at, true);
			a.angle = mYaw;
			a.pitch = -mTilt;
			a.roll = mRoll;
		}
	}

	// A level change destroys every actor; the records go with them.
	override void WorldUnloaded(WorldEvent e)
	{
		mRecs.Clear(); mList.Clear(); mGroups.Clear();
	}
}

//==========================================================================
// wr_Field -- REMA's field reflection, absent on stock QZD. Every read reports "no such field",
// which is exactly what the compat readers already do when the mod they read is not loaded:
// the data card shows the universal rows (tracker, stats) and no mod-specific ones.
//==========================================================================
class wr_Field
{
	static clearscope bool GetFieldInt(Object o, string field, out int value) { return false; }
	static clearscope bool GetFieldIntArray(Object o, string field, int index, out int value) { return false; }
	static clearscope bool GetFieldBool(Object o, string field, out int value) { return false; }
	static clearscope bool GetFieldFloat(Object o, string field, out double value) { return false; }
	static clearscope bool GetFieldString(Object o, string field, out string value) { return false; }
	static clearscope bool GetFieldName(Object o, string field, out name value) { return false; }
	static clearscope bool GetFieldObject(Object o, string field, out Object value) { return false; }
}

//==========================================================================
// wr_VR -- the VR hooks REMA's engine had for the ring, on stock QZD 17.3.
//==========================================================================
class wr_Buzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;
	Default { +NOINTERACTION +NOBLOCKMAP +DONTSPLASH +NOTIMEFREEZE }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) { Destroy(); return; }
		// The series' one route to the controllers (RSQ ShieldSaw's SSQ_Buzzer): a QF_WAVE
		// quake whose X jiggle drives the left controller and Y the right, felt only with
		// vr_quake_haptic_level > 0. Faded over its length.
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}
	States { Spawn: TNT1 A 40; Stop; }
}

class wr_VR play
{
	// LEFT-HANDED IS THE ENGINE'S SETTING: vr_control_scheme >= 10 (as RSQ ShieldSaw reads it).
	static clearscope bool LeftHanded()
	{
		let cv = CVar.FindCVar('vr_control_scheme');
		return cv && cv.GetInt() >= 10;
	}

	// REMA: level.VRHaptic(hand, intensity, ms). hand 0 main, 1 off.
	static void VRHaptic(int hand, double intensity, double durationMs)
	{
		let mo = players[consoleplayer].mo;
		if (!mo || intensity <= 0) return;
		let q = wr_Buzz(Actor.Spawn("wr_Buzz", mo.pos));
		if (!q) return;
		bool mainIsRight = !LeftHanded();
		q.feels = mo;
		q.left = (hand == 0) ? !mainIsRight : mainIsRight;
		q.amp = clamp(intensity, 0.05, 1.0);
		q.total = clamp(int(durationMs * TICRATE / 1000.0 + 0.5), 1, 16);
		q.tleft = q.total;
	}

	// REMA: level.SuppressVRInput -- stops locomotion, turning and the weapons. Here: the player
	// is frozen (CF_TOTALLYFROZEN keeps only Use; PlayerPawn.MovePlayer/TickPSprites honour it),
	// and the trigger presses the ring wants are taken in its InputProcess before a weapon sees
	// them, as before. Who froze is remembered so this never thaws a freeze it did not make.
	static void SuppressVRInput(bool on, int claim = 0)
	{
		let p = players[consoleplayer];
		let h = wr_VRState.Get();
		if (!h) return;
		if (on && !h.mFroze)
		{
			if (!(p.cheats & CF_TOTALLYFROZEN)) { p.cheats |= CF_TOTALLYFROZEN; h.mFroze = true; }
		}
		else if (!on && h.mFroze)
		{
			p.cheats &= ~CF_TOTALLYFROZEN;
			h.mFroze = false;
		}
	}

	// REMA: level.GetRawStickMove -- the locomotion stick, read before suppression zeroes it.
	// original_cmd is the command before PlayerThink's freeze stripped it. -1..1 each axis,
	// x right, y forward.
	static Vector2 GetRawStickMove()
	{
		let p = players[consoleplayer];
		double f = p.original_cmd.forwardmove / 12800.0;
		double s = p.original_cmd.sidemove / 10240.0;
		return (clamp(s, -1.0, 1.0), clamp(f, -1.0, 1.0));
	}

	// REMA: level.ForceVRLaser / SetVRLaserRange -- the engine's laser, drawn on demand and
	// stopped at a range the script gives it (the engine's trace cannot see billboards). Here
	// it is the ring's own beam: a thin quad from the hand.
	static void ForceVRLaser(bool on, int hand = -1, bool both = false)
	{
		let h = wr_VRState.Get(); if (!h) return;
		h.mLaserOn = on; h.mLaserHand = (hand == 1) ? 1 : 0; h.mBoth = on && both;
		if (!on) h.hideBeams();
	}
	static void SetVRLaserRange(double range, int hand = -1)
	{
		let h = wr_VRState.Get(); if (h) h.mLaserRange = range;
	}
}

class wr_Beam : wr_BBQuad
{
	Default { RenderStyle "AddStencil"; }
}

// Per-session state for wr_VR, and the beam it draws. Registered after wr_Rig.
class wr_VRState : EventHandler
{
	bool   mFroze;
	bool   mLaserOn;
	int    mLaserHand;
	bool   mBoth;            // RSQ: the other hand shows a dimmer beam too (either-hand picking)
	double mLaserRange;
	Actor  mBeam[2];

	static wr_VRState Get() { return wr_VRState(EventHandler.Find("wr_VRState")); }

	void hideBeams() { for (int i = 0; i < 2; i++) if (mBeam[i]) mBeam[i].bInvisible = true; }

	override void WorldTick()
	{
		if (!mLaserOn) { hideBeams(); return; }
		let mo = players[consoleplayer].mo;
		if (!mo) return;
		for (int hand = 0; hand < 2; hand++)
		{
			bool active = (hand == mLaserHand);
			if (!active && !mBoth) { if (mBeam[hand]) mBeam[hand].bInvisible = true; continue; }
			Vector3 org = wr_Rig.handPos(PlayerPawn(mo), hand);
			Vector3 dir = wr_Rig.handDir(PlayerPawn(mo), hand);
			double len = active ? mLaserRange : 0;
			if (!active)
			{
				// the idle hand's beam stops at whatever card it crosses, as the active one does
				int id; Vector2 uv; double t;
				[id, uv, t] = wr_BB.AimBillboardT(org, dir, 200);
				len = t;
			}
			if (len <= 0)
			{
				// no card under it: run to whatever it hits, as the engine's laser would
				FLineTraceData tr;
				mo.LineTrace(atan2(dir.y, dir.x), 1024, -asin(clamp(dir.z, -1.0, 1.0)), TRF_THRUACTORS | TRF_ABSPOSITION, org.z, org.x, org.y, tr);
				len = (tr.HitType != TRACE_HitNone) ? tr.Distance : 1024;
			}
			drawBeam(mo, hand, org, dir, len, active ? 0.8 : 0.3);
		}
	}

	private void drawBeam(Actor mo, int hand, Vector3 org, Vector3 dir, double len, double alpha)
	{
		if (!mBeam[hand])
		{
			mBeam[hand] = Actor.Spawn("wr_Beam", org);
			if (!mBeam[hand]) return;
			mBeam[hand].A_ChangeModel("", 0, "", "", 0, "", "WRSTONE");
			mBeam[hand].SetShade("FF3030");
		}
		let b = mBeam[hand];
		b.A_SetRenderStyle(alpha, STYLE_AddStencil);
		b.bInvisible = false;
		// A ribbon along the ray, turned about it to face the eye.
		Vector3 eye = (mo.pos.xy, mo.player.viewz);
		Vector3 mid = org + dir * (len * 0.5);
		Vector3 toEye = eye - mid;
		Vector3 nrm = toEye - dir * (toEye dot dir);
		if (nrm.Length() < 1e-6) nrm = (0, 0, 1);
		b.SetOrigin(mid, true);
		wr_BB.OrientQuad(b, nrm.Unit(), dir);
		b.scale = (len, 0.12);
	}

	override void WorldUnloaded(WorldEvent e)
	{
		let p = players[consoleplayer];
		if (mFroze) { p.cheats &= ~CF_TOTALLYFROZEN; mFroze = false; }
		mLaserOn = false;
		mBeam[0] = null; mBeam[1] = null;
	}
}

//==========================================================================
// wr_FX -- REMA's renderer effects the ring dressed itself in: the volumetric pointer cone,
// the fog slab under the ring, the sweep rings, the glow wave and the shape slots. All are
// shaders that do not exist on stock QZD, and none carries information, so each is a no-op.
//==========================================================================
class wr_FX
{
	static clearscope void SetGlowWave(double wavelength, double speed, double sharpness, int shape) {}
	static clearscope void ClearSweep() {}
	static void RemoveShape(int slot) {}
	static clearscope void ClearVolumetricBeam(int slot = 0) {}
	static clearscope void ClearFogSlabOverride() {}
	static clearscope void SetVolumetricBeam(Vector3 pos, Vector3 dir, color col, double inner, double outer, double length, double density, double falloff, double dust = 0, double dustScale = 0.04, double dustDrift = 0, int slot = 0) {}
	static clearscope void SetSweepOrigin(int mode, Vector3 origin, int count) {}
	static clearscope void SetSweepBand(int index, double radius, double thickness, double softness, color col, double intensity) {}
	static void SetShapeRepeat(int slot, int mode, double count, double space, double spin) {}
	static void SetShapeMotion(int slot, double seam, double seamRate, double grow) {}
	static clearscope void SetGlowWavePhase(double wallTop, double wallBottom, double floorPhase, double ceilPhase) {}
	static clearscope void SetGlowWaveOrigin(Vector3 origin) {}
	static clearscope void SetGlowWaveDepth(double reach, double bright, double colour, double detune, double seed) {}
	static clearscope void SetFogSlabOverride(double topZ, double density, double softness, double scatter, color col, double bottomZ = -32768) {}
	static void MoveShape(int slot, double x, double y, double z) {}
	// -1: no slot was taken, so the ring's release path has nothing to free.
	static int AddShape(int kind, int orient, double x, double y, double z, double size, double angle, double thick, color col, double intensity, double life) { return -1; }
}
