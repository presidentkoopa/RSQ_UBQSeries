// WHICH THINGS ARE DRAWN AS VOXELS (G7).
//
// The glow twin (glow.zs) wears its host's SPRITE. A host drawn as a voxel --
// BD_VoxelPack's barrels, ammo and guns -- has a sprite too, but what you see is
// the voxel, so the twin came out as a thin green card standing in front of a
// solid model. For those hosts the colour flash (tell.zs: the host's own
// translation, which a voxel honours) is the honest cue instead.
//
// There is no engine call that says "this actor draws as a voxel", so it is read
// from the same data the engine reads, once per session:
//   - every VOXELDEF lump: `spritframe = "lump"` lines (key = 4-letter sprite +
//     frame letter, sometimes + angle digit), and
//   - every lump in the voxels/ namespace, which the engine maps by its own name
//     (SPRTF or SPRTF0) without a VOXELDEF entry.
// Kept as (SpriteID, frame) pairs, so the per-actor test is two compares.
class RSQDG_Voxels : StaticEventHandler
{
	private Array<int> sprites;
	private Array<int> frames;
	private bool built;

	static bool Drawn(Actor a)
	{
		if (!a) return false;
		let me = RSQDG_Voxels(StaticEventHandler.Find("RSQDG_Voxels"));
		if (!me) return false;
		if (!me.built) me.Build();
		int s = a.sprite, f = a.frame;
		for (int i = 0; i < me.sprites.Size(); i++)
			if (me.sprites[i] == s && (me.frames[i] == f || me.frames[i] < 0)) return true;
		return false;
	}

	// Built at the first level load, not the first time something is aimed at:
	// a pass over every lump is a hitch, and a load is where a hitch belongs.
	override void WorldLoaded(WorldEvent e) { if (!built) Build(); }

	private void Add(String key)
	{
		// "BAR1A", "bar1a0", "BAR1A1" ...: four letters of sprite, then the frame.
		// Four letters alone ("BAR1") is every frame of that sprite (voxeldef.cpp).
		if (key.Length() < 4) return;
		key = key.MakeUpper();
		int f = -1;
		if (key.Length() >= 5)
		{
			f = key.ByteAt(4) - 65;   // 'A'
			if (f < 0 || f > 28) return;
		}
		int s = Actor.GetSpriteIndex(key.Left(4));
		if (s <= 0) return;
		for (int i = 0; i < sprites.Size(); i++)
			if (sprites[i] == s && frames[i] == f) return;
		sprites.Push(s);
		frames.Push(f);
	}

	private void Build()
	{
		built = true;
		// 1. the voxels/ namespace
		int n = Wads.GetNumLumps();
		for (int i = 0; i < n; i++)
			if (Wads.GetLumpNamespace(i) == Wads.ns_voxels)
				Add(Wads.GetLumpName(i));
		// 2. VOXELDEF: the key before each '=' at the start of a statement
		int lump = -1;
		while ((lump = Wads.FindLump("VOXELDEF", lump + 1)) >= 0)
		{
			String txt = Wads.ReadLump(lump);
			Array<String> lines;
			txt.Split(lines, "\n");
			int depth = 0;
			for (int k = 0; k < lines.Size(); k++)
			{
				String ln = lines[k];
				int c = ln.IndexOf("//");
				if (c >= 0) ln = ln.Left(c);
				if (depth == 0)
				{
					int eq = ln.IndexOf("=");
					if (eq > 0)
					{
						// One voxel can serve several sprites: `BAR1A BAR1B = "x"`.
						String keys = ln.Left(eq);
						keys.Replace("\"", " ");
						keys.Replace(",", " ");
						keys.Replace("\t", " ");
						Array<String> parts;
						keys.Split(parts, " ", TOK_SKIPEMPTY);
						for (int q = 0; q < parts.Size(); q++) Add(parts[q]);
					}
				}
				for (int j = 0; j < int(ln.Length()); j++)
				{
					int ch = ln.ByteAt(j);
					if (ch == 123) depth++;          // {
					else if (ch == 125 && depth > 0) depth--;   // }
				}
			}
		}
	}
}
