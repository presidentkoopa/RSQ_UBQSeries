// THE BEAM RIDES THE GUN.
//
// The old beam was a world actor the playsim moved 35 times a second; the headset draws
// the hands and guns 72-90 times a second, so the beam always trailed the gun. This one is
// a PSPRITE LAYER CALLED BY THE GUN ITSELF, so the renderer places it with the controller
// every rendered frame, exactly as it places the gun model:
//
//   - which controller: models.cpp RenderHUDModel, hand = (caller == OffhandWeapon). The
//     caller is the gun in that hand, so a gun moved to the off hand by switchhand, or
//     Brutal Doom Quest's off-hand dual copy, carries its beam there.
//   - how it turns with the gun layer (raised, lowered, kicked by Offset): hw_weapon.cpp
//     adds the CALLER's weapon layer offset to a PSPF_ADDWEAPON layer, and the turn is
//     (x / 4, (y - WEAPONTOP) / -4). The gun's own MODELDEF Offset is the rod's Offset, so
//     both turn about the same point. A gun mirrored by its MODELDEF (Scale -1) turns
//     sideways the other way: the layer's x is set to -2 x the gun's, every tic, from the
//     gun layer's own x and oldx (players' psprites tick in P_PlayerThink, before WorldTick,
//     so they are this tic's).
//   - how it is made: by an item of ours (so its first state's action may set it additive),
//     then handed to the gun by PSprite.Caller -- see RSQLS_BeamLayer in muzzles.zs.
//   - its model: a voxel rod per gun and length (VOXELDEF, tools/gen_beams.py). A voxel is
//     found by sprite frame alone, for any caller (models.cpp FindModelFrameRaw), where a
//     MODELDEF block keyed to a gun class would be a fatal error with that gun's mod absent.
//   - it hides with the gun: a layer called by the off-hand weapon is skipped while the
//     engine steadies the gun in two hands (hw_weapon.cpp), and TickPSprites destroys a
//     layer whose weapon caller is in neither hand.
//
// LAYER IDS (one psprite id holds one caller): 2140 main hand, 1000140 off hand. Checked
// against everything in the load order on 2026-10-27: BD22 VR Reloaded hands out 2100-2131,
// 2200-2210 and 2300-2301 (rsq/hands.zs RSQ_Layers.Taken, scope 2112, M203 2130-2131),
// the QuestSaber 2000051-2000052; Brutal Doom and the rest of the suite use none. The
// off-hand id is above PSP_OFFHANDWEAPON (1000000) so it draws after the off-hand gun.
//
// THE FADE is a translation: the rod's palette indices are distance from the muzzle (1 at
// the muzzle .. 254 at FADE_MAX), and the translation built here maps each index to the
// beam colour times its brightness at that distance for the fade length chosen. Drawn
// additive, black is clear. One rod per length serves every colour and fade.
class RSQLS_Beams : StaticEventHandler
{
	const LAYER_MAIN = 2140;
	const LAYER_OFF = 1000140;
	const TINTS = 32;

	private bool built;
	private Array<String> cname;
	private Array<int> cplace, cmirror, cfirst, ccount;
	private Array<int> rkeys;        // sprite index * 64 + frame, ready-pose frames, per class
	private Array<int> sprIdx;       // the rods' sprite indices
	private State beamState;

	// Translation cache: (colour, fade cm, brightness step) -> id
	private int tKey[TINTS], tFade[TINTS];
	private TranslationID tId[TINTS];
	private int tN, tNext;

	private void Build()
	{
		built = true;
		int n = RSQLS_Muzzles.CLASSES.Size() / 4;
		for (int i = 0; i < n; i++)
		{
			cname.Push(RSQLS_Muzzles.CLASSES[i * 4]);
			cplace.Push(RSQLS_Muzzles.CLASSES[i * 4 + 1].ToInt());
			cmirror.Push(RSQLS_Muzzles.CLASSES[i * 4 + 2].ToInt());
			cfirst.Push(rkeys.Size());
			Array<String> codes;
			RSQLS_Muzzles.CLASSES[i * 4 + 3].Split(codes, " ", TOK_SKIPEMPTY);
			for (int k = 0; k < codes.Size(); k++)
			{
				int si = Actor.GetSpriteIndex(codes[k].Left(4));
				if (si >= 0) rkeys.Push(si * 64 + codes[k].Mid(4).ToInt());
			}
			ccount.Push(rkeys.Size() - cfirst[i]);
		}
		for (int i = 0; i < RSQLS_Muzzles.SPRITES.Size(); i++)
			sprIdx.Push(Actor.GetSpriteIndex(RSQLS_Muzzles.SPRITES[i]));
		let d = GetDefaultByType("RSQLS_BeamLayer");
		beamState = d ? d.FindState("Beam") : null;
	}

	static RSQLS_Beams Get()
	{
		let me = RSQLS_Beams(StaticEventHandler.Find("RSQLS_Beams"));
		if (me && !me.built) me.Build();
		return me;
	}

	// The measured class's first row, or -1: no measurement, no beam.
	int Find(Weapon w)
	{
		if (!w) return -1;
		String n = w.GetClassName();
		for (int i = 0; i < cname.Size(); i++) if (cname[i] ~== n) return i;
		return -1;
	}

	int Place(int ci) { return cplace[ci]; }
	bool IsMirrored(int ci) { return cmirror[ci] != 0; }

	// Which measured pose is the gun layer drawing the gun in? A class that rests in more than
	// one pose (BD's pistol with and without a round chambered, its SSG on SHTN or SHT2) has a
	// row per pose, adjacent, starting at Find's row. -1: none -- a reload, a kick in the mesh:
	// the mesh has moved off every measured muzzle, so no beam.
	int PoseRow(int ci, PSprite gp)
	{
		if (!gp || ci < 0) return -1;
		int key = int(gp.Sprite) * 64 + gp.Frame;
		for (int r = ci; r < cname.Size() && cname[r] ~== cname[ci]; r++)
			for (int k = cfirst[r], e = cfirst[r] + ccount[r]; k < e; k++)
				if (rkeys[k] == key) return r;
		return -1;
	}

	// Placement numbers (tools/gen_beams.py): turning point, muzzle from it, barrel, layer y.
	static Vector3 Offset(int pi) { int b = pi * 10; return (RSQLS_Muzzles.PLACE[b], RSQLS_Muzzles.PLACE[b + 1], RSQLS_Muzzles.PLACE[b + 2]); }
	static Vector3 Muzzle(int pi) { int b = pi * 10 + 3; return (RSQLS_Muzzles.PLACE[b], RSQLS_Muzzles.PLACE[b + 1], RSQLS_Muzzles.PLACE[b + 2]); }
	static Vector3 Barrel(int pi) { int b = pi * 10 + 6; return (RSQLS_Muzzles.PLACE[b], RSQLS_Muzzles.PLACE[b + 1], RSQLS_Muzzles.PLACE[b + 2]); }
	static double LayerY(int pi) { return RSQLS_Muzzles.PLACE[pi * 10 + 9]; }

	// The fade: colour rgb, brightness a (0..1, stepped), gone by fadeCm from the muzzle.
	TranslationID Tint(int rgb, double a, double fadeCm)
	{
		int step = int(clamp(a, 0.0, 1.0) * 32 + 0.5);
		int fc = int(clamp(fadeCm, 10.0, RSQLS_Muzzles.FADE_MAX));
		int key = (rgb & 0xFFFFFF) | (step << 24);
		for (int k = 0; k < tN; k++)
			if (tKey[k] == key && tFade[k] == fc) return tId[k];
		int cr = (rgb >> 16) & 255, cg = (rgb >> 8) & 255, cb = rgb & 255;
		double b0 = step / 32.0;
		Translation t;
		t.colors[0] = Color(255, 0, 0, 0);
		t.colors[255] = Color(255, 0, 0, 0);
		for (int i = 1; i < 255; i++)
		{
			double d = (i - 0.5) / 254.0 * RSQLS_Muzzles.FADE_MAX;   // the middle of index i's band
			double u = d / fc;
			double b = (u < 1.0) ? b0 * (1.0 - u) : 0.0;     // linear: gone exactly at the fade length
			t.colors[i] = Color(255, int(cr * b), int(cg * b), int(cb * b));
		}
		TranslationID id = t.AddTranslation();
		int slot;
		if (tN < TINTS) slot = tN++;
		else { slot = tNext; tNext = (tNext + 1) % TINTS; }
		tKey[slot] = key; tFade[slot] = fc; tId[slot] = id;
		return id;
	}

	// The rod for placement pi that is as long as possible without passing `cm` (or, given
	// cm < 0, the shortest that reaches past the fade). -1: shorter than the shortest.
	static int Length(double cm, double fadeCm, double ws)
	{
		int n = RSQLS_Muzzles.NLEN;
		if (cm < 0 || cm >= fadeCm)
		{
			for (int k = 0; k < n; k++) if (RSQLS_Muzzles.LENGTHS[k] * ws >= fadeCm) return k;
			return n - 1;
		}
		int best = -1;
		for (int k = 0; k < n; k++) if (RSQLS_Muzzles.LENGTHS[k] * ws <= cm) best = k;
		return best;
	}

	// Put the beam layer on hand h's gun: placement pi, rod k, tint, following gun layer gp.
	void Show(PlayerInfo p, int h, Weapon w, int ci, PSprite gp, int k, TranslationID tint)
	{
		int id = (h == 0) ? LAYER_MAIN : LAYER_OFF;
		let psp = p.FindPSprite(id);
		if (!psp || psp.Caller != w)
		{
			// MADE by the item, HANDED to the gun: see RSQLS_BeamLayer (muzzles.zs). Setting
			// Caller directly keeps the flags the item's action set -- SetPsprite with a new
			// caller would reset them (p_pspr.cpp GetPSprite).
			if (!beamState || !p.mo) return;
			let holder = p.mo.FindInventory("RSQLS_BeamLayer");
			if (!holder)
			{
				p.mo.GiveInventory("RSQLS_BeamLayer", 1);
				holder = p.mo.FindInventory("RSQLS_BeamLayer");
				if (!holder) return;
			}
			p.SetPsprite(id, beamState, false, holder);
			psp = p.FindPSprite(id);
			if (!psp) return;
			psp.Caller = w;
			psp.firstTic = true;
		}
		int pi = cplace[ci];
		int g = pi * RSQLS_Muzzles.NLEN + k;
		int si = sprIdx[g / 26];
		if (si < 0) return;
		psp.Sprite = si;
		psp.Frame = g % 26;
		psp.Translation = tint;
		psp.bAddWeapon = true;
		psp.bAddBob = true;
		// The rod's pitch off level is the layer's own turn (tools/gen_beams.py rod_angles)
		psp.y = LayerY(pi);
		psp.oldy = psp.y;
		// A mirrored gun model turns the other way sideways: cancel the gun layer's x twice
		if (cmirror[ci] != 0 && gp) { psp.x = -2 * gp.x; psp.oldx = -2 * gp.oldx; }
		else { psp.x = 0; psp.oldx = 0; }
	}

	static void Hide(PlayerInfo p, int h)
	{
		int id = (h == 0) ? LAYER_MAIN : LAYER_OFF;
		if (p.FindPSprite(id)) p.SetPsprite(id, null);
	}
}
