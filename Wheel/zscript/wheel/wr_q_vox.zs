// wr_q_vox.zs -- RSQ Wheel: how big a pickup voxel really is, so it can be fitted inside its card.
//
// A pickup sprite says nothing about the voxel drawn in its place: BD_VoxelPack gives each voxel
// its own Scale in VOXELDEF (0.19 to 0.5 there), and the voxel's own size is in its KVX file. So
// both are read, once, from the lumps themselves:
//   VOXELDEF   <sprite frame> = "<voxel lump>" { Scale = <s> ... }   (every VOXELDEF lump, in
//              load order, so a later pack's entry for a frame replaces an earlier one)
//   KVX        int32 bytes, int32 xsiz, ysiz, zsiz: the voxel's size in voxels
// A voxel draws xsiz x ysiz x zsiz map units times its Scale (times the actor's). The card asks
// Size(frame) for a sprite frame name ("PISTA") and gets the voxel's width across (the longer of
// x and y, since it turns) and height, or (0, 0) when that frame has no voxel -- then the card
// keeps its flat icon rather than guessing.

class wr_VoxSize play
{
	Map<String, double> mW, mH;     // frame -> voxel width across and height, in map units
	bool mRead;

	static wr_VoxSize Get()
	{
		let h = wr_VRState.Get();
		if (!h) return null;
		if (!h.mVox) h.mVox = new("wr_VoxSize");
		if (!h.mVox.mRead) h.mVox.ReadAll();
		return h.mVox;
	}

	// width across, height; (0, 0) when the frame has no voxel this could measure
	static Vector2 Size(string frame)
	{
		let v = Get();
		if (!v || frame.Length() < 5) return (0, 0);
		string key = frame.Left(5).MakeUpper();
		if (!v.mW.CheckKey(key)) key = frame.Left(4).MakeUpper();   // a whole-sprite entry ("PIST")
		if (!v.mW.CheckKey(key)) return (0, 0);
		return (v.mW.Get(key), v.mH.Get(key));
	}

	private void ReadAll()
	{
		mRead = true;
		int lump = -1;
		while ((lump = Wads.FindLump("VOXELDEF", lump + 1)) != -1) ReadDef(Wads.ReadLump(lump));
	}

	private void ReadDef(string text)
	{
		Array<string> tok;
		Tokens(text, tok);
		for (int i = 0; i + 2 < tok.Size(); i++)
		{
			// <frame> = "<lump>" [ { ... } ]
			if (tok[i + 1] != "=") continue;
			string frame = tok[i].MakeUpper();
			string vlump = tok[i + 2];
			double scale = 1.0;
			int j = i + 3;
			if (j < tok.Size() && tok[j] == "{")
			{
				for (j++; j < tok.Size() && tok[j] != "}"; j++)
					if (tok[j] ~== "scale" && j + 2 < tok.Size() && tok[j + 1] == "=") scale = tok[j + 2].ToDouble();
			}
			int x, y, z;
			[x, y, z] = KvxDims(vlump);
			if (x > 0)
			{
				mW.Insert(frame, max(x, y) * scale);
				mH.Insert(frame, z * scale);
			}
			i = j;
		}
	}

	// The KVX header's three sizes, from the lump by its short name (any namespace) or full path.
	private static int, int, int KvxDims(string name)
	{
		int l = Wads.CheckNumForFullName(name);
		if (l < 0) l = Wads.FindLump(name, 0, Wads.AnyNamespace);
		if (l < 0) return 0, 0, 0;
		string d = Wads.ReadLump(l);
		if (d.Length() < 16) return 0, 0, 0;
		return I32(d, 4), I32(d, 8), I32(d, 12);
	}

	private static int I32(string d, int at)
	{
		return d.ByteAt(at) | (d.ByteAt(at + 1) << 8) | (d.ByteAt(at + 2) << 16) | (d.ByteAt(at + 3) << 24);
	}

	// Words, '=', braces and quoted strings (quotes dropped); // and /* */ comments skipped.
	private static void Tokens(string text, out Array<string> tok)
	{
		int n = text.Length();
		int i = 0;
		while (i < n)
		{
			int c = text.ByteAt(i);
			if (c == 47 && i + 1 < n && text.ByteAt(i + 1) == 47) { while (i < n && text.ByteAt(i) != 10) i++; continue; }
			if (c == 47 && i + 1 < n && text.ByteAt(i + 1) == 42)
			{
				i += 2;
				while (i + 1 < n && !(text.ByteAt(i) == 42 && text.ByteAt(i + 1) == 47)) i++;
				i += 2; continue;
			}
			if (c <= 32 || c == 59 || c == 44) { i++; continue; }           // space, ';', ','
			if (c == 61 || c == 123 || c == 125) { tok.Push(text.Mid(i, 1)); i++; continue; }   // = { }
			if (c == 34)
			{
				int s = ++i;
				while (i < n && text.ByteAt(i) != 34) i++;
				tok.Push(text.Mid(s, i - s)); i++; continue;
			}
			int s = i;
			while (i < n)
			{
				int k = text.ByteAt(i);
				if (k <= 32 || k == 61 || k == 123 || k == 125 || k == 59 || k == 44 || k == 34) break;
				i++;
			}
			tok.Push(text.Mid(s, i - s));
		}
	}
}

// THE SERIES' OWN HAND WEAPONS' MESHES, for their 3D model cards (zscript.zs spawnOwnProp, owner 11-11). ZScript cannot
// read an MD3, so these are measured by tools/measure_card_props.py from each pack's own MODELDEF block and mesh frame,
// placed as the engine's world path places them (Scale, then the Offset unscaled; x forward, y left, z up; actor scale 1):
//   across   the longer of the x and y extents (the prop turns)
//   height   the mesh's height before the pixel stretch (the game divides it by level.pixelstretch)
//   cx, cy   the middle of its bounds, forward and left of the actor's origin
//   meshZ    the mesh's part of the middle's z (divided by the pixel stretch), offZ the Offset's z (not divided)
class wr_CardProp
{
	enum ERow { SABER, SHIELD, WHIP, FBXFIST, GLOVE }
	const NROWS = 5;   // QZD 17.3 will not compare an int with an enum member ("Incompatible operands"): a plain const

	static Name ClassOf(int r)
	{
		static const Name n[] = { 'UBQS_HipSaber', 'SSQ_Prop', 'RSQWP_Stowed', 'RSQ_Glove', 'RSQ_Glove' };
		return (r >= 0 && r < NROWS) ? n[r] : 'None';
	}
	static Name SpriteOf(int r)
	{
		static const Name n[] = { 'UBSP', 'SSQP', 'RSWP', 'RMHF', 'RMHG' };
		return (r >= 0 && r < NROWS) ? n[r] : 'TNT1';
	}
	static int FrameOf(int r)
	{
		static const int n[] = { 13, 0, 0, 0, 0 };   // UBSP N; the rest frame A
		return (r >= 0 && r < NROWS) ? n[r] : 0;
	}
	//                                              saber   shield  whip    FBX fist  glove
	static double Across(int r) { static const double v[] = { 27.06, 19.97,  9.64, 20.55,  18.78 }; return v[clamp(r, 0, NROWS - 1)]; }
	static double Height(int r) { static const double v[] = { 32.24, 19.88, 12.23, 11.73,  13.98 }; return v[clamp(r, 0, NROWS - 1)]; }
	static double CX(int r)     { static const double v[] = {  0.01, -3.21,  0.09,  1.24,  -0.37 }; return v[clamp(r, 0, NROWS - 1)]; }
	static double CY(int r)     { static const double v[] = { -28.92, -2.13, 0.62, -22.14, -22.34 }; return v[clamp(r, 0, NROWS - 1)]; }
	static double MeshZ(int r)  { static const double v[] = { -0.01,  0.03, -1.12, -0.57,   0.04 }; return v[clamp(r, 0, NROWS - 1)]; }
	static double OffZ(int r)   { static const double v[] = { -8.00,  0.00,  0.00, -10.00, -10.30 }; return v[clamp(r, 0, NROWS - 1)]; }
}
