// WHERE A VOXEL'S TOP IS. A frame drawn as a voxel (Cheello's Voxel Doom II, BD_VoxelPack's items)
// is not the height of its sprite. The engine reads the same two places this reads, once:
//   - every VOXELDEF lump: `SPRITEFRAME = "lump" { Scale = n ... }`
//   - every lump in the voxels/ namespace, named after its sprite frame
// and for each, the KVX header of the voxel lump itself (int32 numbytes, xsiz, ysiz, zsiz, then the
// pivot in 8.8 fixed point). A KVX hangs from its pivot with z growing downward, so its top is
// zpivot units above the actor's origin, times the VOXELDEF scale (the actor's scale is applied by
// the caller). Built lazily, the first time a bar asks; a lookup is one Map probe.
class RSQTHP_Voxels : StaticEventHandler
{
	transient Map<int, double> tops;     // key sprite * 32 + frame (frame 31 = every frame)
	transient bool built;
	transient int count;

	static double TopOf(Actor a)
	{
		let me = RSQTHP_Voxels(StaticEventHandler.Find("RSQTHP_Voxels"));
		if (!me) return 0;
		if (!me.built) me.Build();
		if (me.count == 0) return 0;
		bool ok;
		double t;
		[t, ok] = me.tops.CheckValue(a.sprite * 32 + a.frame);
		if (ok) return t;
		[t, ok] = me.tops.CheckValue(a.sprite * 32 + 31);
		return ok ? t : 0;
	}

	private static int I32(String d, int o)
	{
		return d.ByteAt(o) | (d.ByteAt(o + 1) << 8) | (d.ByteAt(o + 2) << 16) | (d.ByteAt(o + 3) << 24);
	}

	// top of a voxel lump in voxel units, 0 if it is not a KVX we can read
	private static double KvxTop(int lump)
	{
		if (lump < 0 || Wads.GetLumpLength(lump) < 28) return 0;
		String d = Wads.ReadLump(lump);
		if (d.Length() < 28) return 0;
		int zsiz = I32(d, 12);
		int zpiv = I32(d, 24);
		if (zsiz <= 0 || zsiz > 1024) return 0;
		// models_voxel.cpp: vertex height = PivotZ - z, z from 0 (the voxel's top row) down to zsiz,
		// and no pixel-stretch for voxels -- so the top is PivotZ above the origin, wherever the
		// pivot is (BD_VoxelPack's SPDFA hangs 32 tall from a pivot 64 below its top: top 64).
		double t = zpiv / 256.0;
		return t > 0 ? t : 0;
	}

	private void Add(String key, double top)
	{
		if (top <= 0 || key.Length() < 4) return;
		key = key.MakeUpper();
		int f = 31;
		if (key.Length() >= 5)
		{
			f = key.ByteAt(4) - 65;
			if (f < 0 || f > 28) return;
		}
		int s = Actor.GetSpriteIndex(key.Left(4));
		if (s <= 0) return;
		tops.Insert(s * 32 + f, top);
		count++;
	}

	void Build()
	{
		built = true;
		int n = Wads.GetNumLumps();
		for (int i = 0; i < n; i++)
			if (Wads.GetLumpNamespace(i) == Wads.ns_voxels)
			{
				String nm = Wads.GetLumpName(i);
				Add(nm, KvxTop(i));
			}
		int lump = -1;
		while ((lump = Wads.FindLump("VOXELDEF", lump + 1, Wads.AnyNamespace)) >= 0)
			ParseDef(Wads.ReadLump(lump));
	}

	// tokens: words, "strings", = { } ; -- comments stripped
	private void Tokenise(String src, out Array<String> toks)
	{
		int i = 0, n = src.Length();
		while (i < n)
		{
			int c = src.ByteAt(i);
			if (c <= 32) { i++; continue; }
			if (c == 47 && i + 1 < n && src.ByteAt(i + 1) == 47) { while (i < n && src.ByteAt(i) != 10) i++; continue; }
			if (c == 47 && i + 1 < n && src.ByteAt(i + 1) == 42)
			{
				i += 2;
				while (i + 1 < n && !(src.ByteAt(i) == 42 && src.ByteAt(i + 1) == 47)) i++;
				i += 2; continue;
			}
			if (c == 34)
			{
				int j = i + 1;
				while (j < n && src.ByteAt(j) != 34) j++;
				toks.Push(src.Mid(i + 1, j - i - 1));
				i = j + 1; continue;
			}
			if (c == 61 || c == 123 || c == 125 || c == 59 || c == 44) { toks.Push(src.Mid(i, 1)); i++; continue; }
			int j = i;
			while (j < n)
			{
				int d = src.ByteAt(j);
				if (d <= 32 || d == 61 || d == 123 || d == 125 || d == 59 || d == 34 || d == 44) break;
				j++;
			}
			toks.Push(src.Mid(i, j - i));
			i = j;
		}
	}

	private void ParseDef(String src)
	{
		Array<String> t;
		Tokenise(src, t);
		int i = 0;
		while (i < t.Size())
		{
			// KEY = "lump" [ { props } ]
			if (i + 2 < t.Size() && t[i + 1] == "=")
			{
				String key = t[i];
				String lumpName = t[i + 2];
				i += 3;
				double scale = 1.0;
				if (i < t.Size() && t[i] == "{")
				{
					i++;
					while (i < t.Size() && t[i] != "}")
					{
						if (t[i] ~== "Scale" && i + 2 < t.Size() && t[i + 1] == "=") { scale = t[i + 2].ToDouble(); i += 3; continue; }
						i++;
					}
					i++;
				}
				int lump = Wads.CheckNumForName(lumpName, Wads.ns_voxels);
				if (lump < 0) lump = Wads.CheckNumForFullName(lumpName);
				double top = KvxTop(lump);
				if (top > 0 && scale > 0) Add(key, top * scale);
				continue;
			}
			i++;
		}
	}
}
