// bb.zs -- RSQ Gun Cards: the few world quads the cards drawn IN THE WORLD are made of (rsqgc_world).
//
// A cut-down copy of RSQ Wheel's billboards (Wheel/zscript/wheel/wr_q_shim.zs, wr_BB): a plate, a line of text or
// a number, each a unit quad model (models/rsqgc) placed, turned and scaled every tic; text is a strip of cells,
// one per character, skinned per surface. Only what the cards use is here: no groups, no hit tests, no bars.
// Geometry is the Wheel's (REMA's BillboardBasis):
//   face  F = ( cos y,  sin y, 0)          right R = (-sin y, cos y, 0)
//   up    U = (-cos y sin t, -sin y sin t, cos t)    normal N = R x U
//   roll turns R toward U:  R' = R cos r + U sin r,  U' = U cos r - R sin r
// Colour is a palette translation from each colour, mapping every palette entry's brightness onto it (Doom's
// own way of colouring fonts), so the plate keeps its grain and a glyph its edge.

class RSQGC_BBRec play
{
	int     id;
	Vector3 pos;
	double  w, h, yaw, tilt, roll;
	int     facing, payload, data, order;
	color   col;
	double  alpha;
	string  text;
	bool    lookDirty;
	Array<Actor> parts;
	Array<double> pOX, pOY, pSX, pSY;
	Array<int>    pKind;     // 0 quad, 1 glyph strip
}

class RSQGC_BBQuad : Actor
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
	States { Spawn: GCBQ A -1; Stop; }
}
class RSQGC_BBStrip : RSQGC_BBQuad {}

// Registered AFTER RSQGC_GunCard (MAPINFO), so the quads are laid out in the same tic the card moved them.
class RSQGC_BB : EventHandler
{
	enum EPayload { BB_PANEL = 0, BB_DIGITS = 2, BB_TEXT = 6 }
	enum EFacing { BBF_FIXED = 0, BBF_CAMERA = 2 }

	const STRIP_CELLS = 24;
	const LAYER_STEP  = 0.03;           // map units toward the viewer per creation order step

	Map<int, RSQGC_BBRec> mRecs;
	Array<RSQGC_BBRec>    mList;
	int mNextId, mOrder;

	static RSQGC_BB Get() { return RSQGC_BB(EventHandler.Find("RSQGC_BB")); }
	private RSQGC_BBRec rec(int id)
	{
		if (id <= 0 || !mRecs.CheckKey(id)) return null;
		return mRecs.Get(id);
	}

	static int Add(Vector3 pos, double w, double h, int payload, color col)
	{
		let b = Get(); if (!b) return 0;
		let r = new("RSQGC_BBRec");
		r.id = ++b.mNextId;
		r.pos = pos; r.w = w; r.h = h; r.facing = BBF_CAMERA; r.payload = payload; r.col = col;
		r.alpha = 1.0; r.order = ++b.mOrder; r.lookDirty = true;
		b.mRecs.Insert(r.id, r);
		b.mList.Push(r);
		return r.id;
	}
	static void Update(int id, int data, color col)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		if (r.data != data || r.col != col) { r.data = data; r.col = col; r.lookDirty = true; }
	}
	static void SetText(int id, string text)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		if (r.text != text) { r.text = text; r.lookDirty = true; }
	}
	static void Move(int id, Vector3 pos) { let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.pos = pos; }
	static void Orient(int id, double yaw, double tilt, double roll)
	{
		let b = Get(); if (!b) return; let r = b.rec(id); if (!r) return;
		r.yaw = yaw; r.tilt = tilt; r.roll = roll; r.facing = BBF_FIXED;
	}
	static void Resize(int id, double w, double h) { let b = Get(); if (!b) return; let r = b.rec(id); if (r) { r.w = w; r.h = h; } }
	static void SetAlpha(int id, double alpha) { let b = Get(); if (!b) return; let r = b.rec(id); if (r) r.alpha = clamp(alpha, 0.0, 1.0); }
	static void Remove(int id)
	{
		let b = Get(); if (!b) return;
		let r = b.rec(id); if (!r) return;
		b.clearParts(r);
		b.mRecs.Remove(id);
		int i = b.mList.Find(r);
		if (i < b.mList.Size()) b.mList.Delete(i);
	}

	private void clearParts(RSQGC_BBRec r)
	{
		for (int i = 0; i < r.parts.Size(); i++) if (r.parts[i]) r.parts[i].Destroy();
		r.parts.Clear(); r.pOX.Clear(); r.pOY.Clear(); r.pSX.Clear(); r.pSY.Clear(); r.pKind.Clear();
	}

	Vector3 mR, mU, mN;
	double mYaw, mTilt, mRoll;
	private void resolve(RSQGC_BBRec r, Vector3 eye)
	{
		double useYaw = r.yaw, useTilt = r.tilt, useRoll = r.roll;
		if (r.facing == BBF_CAMERA)
		{
			Vector3 d = eye - r.pos;
			useYaw = atan2(d.y, d.x);
			useTilt = atan2(d.z, d.xy.Length());
			useRoll = 0;
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
	}

	private Actor newPart(RSQGC_BBRec r, class<Actor> cls, double ox, double oy, double sx, double sy, int kind)
	{
		let a = Actor.Spawn(cls, r.pos);
		if (!a) return null;
		r.parts.Push(a); r.pOX.Push(ox); r.pOY.Push(oy); r.pSX.Push(sx); r.pSY.Push(sy); r.pKind.Push(kind);
		return a;
	}

	Array<int>           mTransKey;
	Array<TranslationID> mTransId;
	TranslationID TransFor(color c)
	{
		int key = (c.r << 16) | (c.g << 8) | c.b;
		for (int i = 0; i < mTransKey.Size(); i++) if (mTransKey[i] == key) return mTransId[i];
		Translation t;
		for (int k = 0; k < 256; k++)
		{
			double l = RSQGC_PalLum.LUM[k] / 255.0;
			double v = min(1.0, l * 2.2);
			double g = min(255.0, l * 255.0 * 0.45);
			t.colors[k] = color(255, int(min(255.0, c.r * v + g)), int(min(255.0, c.g * v + g)), int(min(255.0, c.b * v + g)));
		}
		t.colors[0] = color(0, 0, 0, 0);
		TranslationID id = t.AddTranslation();
		mTransKey.Push(key);
		mTransId.Push(id);
		return id;
	}

	static bool AllNumeral(string t)
	{
		if (t.Length() == 0) return false;
		for (int i = 0; i < int(t.Length()); i++)
		{
			int c = t.ByteAt(i);
			if (!((c >= 48 && c <= 57) || c == 37 || c == 45)) return false;
		}
		return true;
	}

	// Text fitted into the box (centred, scaled to whichever of width or height runs out first), numbers in the
	// number cells, anything with a letter in the word cells.
	private void buildText(RSQGC_BBRec r, string text)
	{
		text = text.MakeUpper();
		bool num = AllNumeral(text);
		double aspect = num ? RSQGC_Look.NumAspect() : RSQGC_Look.WordAspect();
		string pfx = num ? RSQGC_Look.NumPrefix() : RSQGC_Look.WordPrefix();
		Array<string> lines;
		text.Split(lines, "\n");
		if (lines.Size() == 0) return;
		int widest = 1;
		for (int i = 0; i < lines.Size(); i++) widest = max(widest, lines[i].CodePointCount());
		double cellH = min(1.0 / lines.Size(), (r.w / max(r.h, 0.001)) / (widest * aspect));
		double cellW = cellH * aspect * (r.h / max(r.w, 0.001));
		int n = lines.Size();
		for (int li = 0; li < n; li++)
		{
			string ln = lines[li];
			int len = ln.CodePointCount();
			double rowY = (n - 1) * 0.5 - li;
			double x0 = -len * cellW * 0.5;
			for (int k0 = 0; k0 < max(len, 1); k0 += STRIP_CELLS)
			{
				let a = newPart(r, "RSQGC_BBStrip", (x0 + k0 * cellW) * 2.0, rowY * cellH * 2.0, cellW * 2.0, cellH * 2.0, 1);
				if (!a) continue;
				int need = min(STRIP_CELLS, len - k0);
				int cells = need <= 4 ? 4 : need <= 8 ? 8 : need <= 12 ? 12 : STRIP_CELLS;
				if (cells != STRIP_CELLS)
					a.A_ChangeModel("", 0, "models/rsqgc", String.Format("strip%d.obj", cells), 0, "", "", 0);
				for (int k = 0; k < cells; k++)
				{
					string g = "GCGBLNK";
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

	private void build(RSQGC_BBRec r)
	{
		clearParts(r);
		if (r.payload == BB_TEXT) buildText(r, r.text);
		else if (r.payload == BB_DIGITS) buildText(r, String.Format("%d", r.data));
		else
		{
			let a = newPart(r, "RSQGC_BBQuad", 0, 0, 1, 1, 0);
			double ar = r.w / max(r.h, 0.001);
			if (a) a.A_ChangeModel("", 0, "", "", 0, "", RSQGC_Look.Plate(ar > 4.0 || ar < 0.25));
		}
		r.lookDirty = false;
	}

	override void WorldTick()
	{
		let pp = players[consoleplayer];
		if (!pp.mo) return;
		Vector3 eye = (pp.mo.pos.xy, pp.viewz);
		for (int i = 0; i < mList.Size(); i++)
		{
			let r = mList[i];
			if (r.lookDirty) build(r);
			place(r, eye);
		}
	}

	private void place(RSQGC_BBRec r, Vector3 eye)
	{
		resolve(r, eye);
		double hw = r.w * 0.5, hh = r.h * 0.5;
		bool hide = (r.alpha <= 0.001) || (hw <= 0.0005) || (hh <= 0.0005);
		Vector3 lift = mN * (LAYER_STEP * (r.order % 64));
		for (int p = 0; p < r.parts.Size(); p++)
		{
			let a = r.parts[p];
			if (!a) continue;
			if (hide) { a.bInvisible = true; continue; }
			a.bInvisible = false;
			a.A_SetRenderStyle(r.alpha, STYLE_Translucent);
			a.Translation = TransFor(RSQGC_Look.Col(r.col));
			Vector3 at = r.pos + mR * (r.pOX[p] * hw) + mU * (r.pOY[p] * hh) + lift;
			if (r.pKind[p] == 1) a.scale = (r.pSX[p] * hw, r.pSY[p] * hh);
			else a.scale = (r.pSX[p] * hw * 2, r.pSY[p] * hh * 2);
			a.SetOrigin(at, true);
			a.angle = mYaw;
			a.pitch = -mTilt;
			a.roll = mRoll;
		}
	}

	// A level change destroys every actor; the records go with them.
	override void WorldUnloaded(WorldEvent e)
	{
		mRecs.Clear(); mList.Clear();
	}
}
