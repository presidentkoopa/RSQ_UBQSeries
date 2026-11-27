// modelcard.zs -- RSQ Gun Cards: THE SMALL CARD, DRAWN BY MODELS (owner 2026-11-15, option B "Same card, drawn by models";
// 07:32 "do all that in this style").
//
// card.zs Draw lays the card out (the same layers, the same spot, Ermac's panels, the JFO or Ermac glyphs, the same
// translations for the colours); each piece is a model whose animation frames are its glyphs (tools/gen_modelcard.py,
// the way RemaSelaco draws its ammo digits). Its sprites have no graphics, so it costs no sprite frames (the voxel card it
// replaced cost 9,929). The owner's change (05:57): the big count and RELOAD sit centred between the word and the reserve.
//
// WHO DRAWS IT. The main hand's card is owned by RSQGC_CardItem: blocks in MODELDEF.txt, for every gun. The off hand's is
// owned by the off-hand gun (the engine picks the hand by that), and MODELDEF finds its model by that gun's class, so a
// gun has an off-hand card only when its blocks are loaded, and the pack that defines the gun carries them (BD22 VR
// Reloaded 2.0.5a on, RSQ Grenade; tools/gen_modelcard.py PACKS; they were bridge pk3s until 2026-11-16). Each such pack
// lists its classes in a lump RSQGCOFF, read here.
//
// THE IN SLIDER. Each glyph is baked at In 0, +14 and -14 cm; a piece's two states (In 0, then +14 or -14) last
// RSQGC_MC.TICS tics, and the engine draws a model blended between its state's frame and the next state's by the tics left
// (models.cpp RenderFrameModels). McIn sets the tics left for this tic's In, so the card sits at the slider's place
// (13 places, 2 cm apart, as before). With the engine's model interpolation off the card stays at In 0.
//
// RIG ONLY, NOT HEADSET-CONFIRMED (see GunCards/docs/modelcard/).

extend class RSQGC_GunCard
{
	transient Array<Name> mMcOff;
	transient bool mMcRead;
	int mMcTics;            // the tics left to give each piece drawn this tic (Put), 0 none
	bool mMcNeg;            // this tic's In is below 0: the pieces blend toward -14

	private void McRead()
	{
		mMcOff.Clear();
		int lump = -1;
		while ((lump = Wads.FindLump("RSQGCOFF", lump + 1)) >= 0)
		{
			Array<String> lines;
			String txt = Wads.ReadLump(lump);
			txt.Replace("\r", "");
			txt.Split(lines, "\n");
			for (int i = 0; i < lines.Size(); i++)
			{
				String s = lines[i];
				s.StripRight();
				if (s.Length() > 0 && s.Left(2) != "//") mMcOff.Push(Name(s));
			}
		}
		mMcRead = true;
		if (ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: off-hand guns with a small card (their packs' RSQGCOFF): %d", mMcOff.Size());
	}

	// can this hand's small card be drawn? owner: the layers' owner (RSQGC_CardItem on the main hand, the off-hand gun on the
	// off hand)
	bool McUse(int hand, Actor owner, Weapon w)
	{
		if (!w || !owner) return false;
		if (hand == 0) return owner is "RSQGC_CardItem";
		if (!mMcRead) McRead();
		bool ok = mMcOff.Find(owner.GetClassName()) != mMcOff.Size();
		if (!ok && ci("rsqgc_debug_log", 0) && level.maptime % 70 == 0)
			Console.Printf("rsqgc: no off-hand small card for %s (no pack carries its blocks)", owner.GetClassName());
		return ok;
	}

	// this tic's In: depth is card.zs Depth()'s place, 0..DEPTHS-1
	void McIn(int depth)
	{
		double cm = (depth - RSQGC_MC.DEPTHS / 2) * RSQGC_MC.DEPTH_STEP;
		mMcNeg = cm < 0;
		double t = clamp(abs(cm) / RSQGC_MC.END, 0.0, 1.0);
		mMcTics = clamp(int(round(RSQGC_MC.TICS * (1.0 - t))), 2, RSQGC_MC.TICS);
	}

	// a piece's first state (kind and slot as RSQGC_MCStates.Piece), toward +14 or -14 by this tic's In; its Bright twin
	// under Card Glow
	State McPiece(int kind, int slot)
	{
		int code = (kind * 100 + slot) * 2 + (mMcNeg ? 1 : 0);
		return RSQGC_Glow.Mode() > 0 ? RSQGC_MCStatesB.Piece(code) : RSQGC_MCStates.Piece(code);
	}

	// letter n's state: each letter has two (its In 0 frame, then the +14 or -14 one)
	static State McNth(State s, int n)
	{
		for (int i = 0; i < n * 2 && s; i++) s = s.NextState;
		return s;
	}

	// McNth(McPiece(kind, slot), n), REMEMBERED PER LAYER (performance, 2026-11-27). Every small-card piece asked this every
	// tic, for both hands: McPiece runs a 70-case switch and a FindState, and McNth walks up to 40 states down the chain, to
	// land on the same state as last tic unless the count changed. States never change while the game runs, so the state
	// for a (piece, In side, Card Glow, letter) is that state for good: each layer keeps the last one it was given and
	// its key, and only a different key looks it up again. id: the layer (L_FIRST..L_LAST); any other id, or a letter past
	// the key's room, is looked up as before.
	transient Array<int> mMcKey;     // per layer (id - L_FIRST): 1 + the key of the state below, 0 none yet
	transient Array<State> mMcSt;
	State McGlyph(int id, int kind, int slot, int n)
	{
		int i = id - L_FIRST;
		if (i < 0 || i > L_LAST - L_FIRST || n < 0 || n >= 128) return McNth(McPiece(kind, slot), n);
		int code = (kind * 100 + slot) * 2 + (mMcNeg ? 1 : 0);   // as McPiece builds it
		int key = ((code * 2 + (RSQGC_Glow.Mode() > 0 ? 1 : 0)) * 128 + n) + 1;
		if (mMcKey.Size() <= i) { mMcKey.Resize(L_LAST - L_FIRST + 1); mMcSt.Resize(L_LAST - L_FIRST + 1); }
		if (mMcKey[i] == key) return mMcSt[i];
		State s = McNth(McPiece(kind, slot), n);
		mMcKey[i] = key; mMcSt[i] = s;
		return s;
	}
}
