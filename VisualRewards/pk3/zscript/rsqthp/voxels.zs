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
	// Cheap at the first bar, whatever else is loaded (the review, 10-27: a char-by-char parse of every
	// VOXELDEF froze the first hurt monster for 300-400 ms once RSQ_LaserSight's 7633-voxel VOXELDEF was
	// loaded). The build only notes WHICH lump draws a frame (lines split natively, no tokenising, no
	// voxel read); a voxel's header is read the first time a monster wearing that frame asks.
	transient Map<int, int> lumpOf;      // key sprite * 32 + frame (frame 31 = every frame) -> voxel lump
	transient Map<int, double> scaleOf;  // VOXELDEF Scale for that key
	transient Map<int, double> tops;     // resolved tops (0 = not a readable voxel)
	transient bool built;
	transient int count;

	// Built while the level loads (also after a save is loaded: the tables are transient), not
	// mid-fight: 40 ms on the desktop rig with the full order plus RSQ_LaserSight (was 402 ms).
	override void WorldLoaded(WorldEvent e)
	{
		if (!built) Build();
	}

	static double TopOf(Actor a)
	{
		let me = RSQTHP_Voxels(StaticEventHandler.Find("RSQTHP_Voxels"));
		if (!me) return 0;
		if (!me.built) me.Build();
		if (me.count == 0) return 0;
		double t = me.Resolve(a.sprite * 32 + a.frame);
		if (t > 0) return t;
		return me.Resolve(a.sprite * 32 + 31);
	}

	private double Resolve(int key)
	{
		bool ok;
		double t;
		[t, ok] = tops.CheckValue(key);
		if (ok) return t;
		int lump;
		[lump, ok] = lumpOf.CheckValue(key);
		t = 0;
		if (ok)
		{
			double sc;
			bool sok;
			[sc, sok] = scaleOf.CheckValue(key);
			if (!sok || sc <= 0) sc = 1.0;
			t = KvxTop(lump) * sc;
		}
		tops.Insert(key, t);
		return t;
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

	// key from a sprite-frame name (SPRT or SPRTF); -1 when the sprite doesn't exist
	private static int KeyOf(String nm)
	{
		if (nm.Length() < 4) return -1;
		nm = nm.MakeUpper();
		int f = 31;
		if (nm.Length() >= 5)
		{
			f = nm.ByteAt(4) - 65;
			if (f < 0 || f > 28) return -1;
		}
		int s = Actor.GetSpriteIndex(nm.Left(4));
		if (s <= 0) return -1;
		return s * 32 + f;
	}

	private void Note(int key, int lump, double scale)
	{
		if (key < 0 || lump < 0) return;
		lumpOf.Insert(key, lump);
		scaleOf.Insert(key, scale);
		tops.Remove(key);
		count++;
	}

	void Build()
	{
		built = true;
		int n = Wads.GetNumLumps();
		for (int i = 0; i < n; i++)
			if (Wads.GetLumpNamespace(i) == Wads.ns_voxels)
				Note(KeyOf(Wads.GetLumpName(i)), i, 1.0);
		int lump = -1;
		while ((lump = Wads.FindLump("VOXELDEF", lump + 1, Wads.AnyNamespace)) >= 0)
			ParseDef(Wads.ReadLump(lump));
	}

	// One line at a time: `KEY = "lump"` starts an entry (possibly with `{ Scale = n ... }` on the
	// same line or the lines after). Only entries whose sprite exists are kept.
	private void ParseDef(String src)
	{
		Array<String> lines;
		src.Split(lines, "\n");
		int curKey = -1, curLump = -1;
		double curScale = 1.0;
		for (int i = 0; i < lines.Size(); i++)
		{
			String ln = lines[i];
			int c = ln.IndexOf("//");
			if (c >= 0) ln = ln.Left(c);
			int eq = ln.IndexOf("=");
			int q1 = ln.IndexOf("\"");
			if (eq > 0 && q1 > eq)
			{
				Note(curKey, curLump, curScale);
				int q2 = ln.IndexOf("\"", q1 + 1);
				String key = ln.Left(eq);
				key.StripRight();
				key.StripLeft();
				String lumpName = q2 > q1 ? ln.Mid(q1 + 1, q2 - q1 - 1) : "";
				curKey = KeyOf(key);
				curLump = -1;
				curScale = 1.0;
				if (curKey >= 0 && lumpName != "")
				{
					curLump = Wads.CheckNumForName(lumpName, Wads.ns_voxels);
					if (curLump < 0) curLump = Wads.CheckNumForFullName(lumpName);
				}
			}
			int sc = ln.MakeLower().IndexOf("scale");
			if (sc >= 0 && curKey >= 0)
			{
				int e2 = ln.IndexOf("=", sc);
				if (e2 > 0)
				{
					String v = ln.Mid(e2 + 1);
					v.StripLeft();
					double d = v.ToDouble();
					if (d > 0) curScale = d;
				}
			}
		}
		Note(curKey, curLump, curScale);
	}
}
