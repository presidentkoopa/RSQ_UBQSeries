// modelcard.zs -- RSQ Gun Cards: THE SMALL CARD DRAWN BY MODELS (owner 2026-11-15, option B: "Same card, drawn by models").
//
// The same card as the voxel one (card.zs Draw: the same layers, the same spot, the same JFO glyphs, Ermac's panels, the
// same translations for the colours), but each piece is a model whose animation frames are its glyphs (tools/gen_modelcard.py,
// the way RemaSelaco draws its ammo digits). Its sprites have no graphics, so it costs no sprite frames; the voxel card
// costs 9,906. One change, the owner's (05:57): the big count and RELOAD sit centred between the word and the reserve.
//
// WHICH GUNS (the proof, 2026-11-15): the main hand's guns listed in models/rsqgc/mc/guns.txt (BD22 VR's Rifle), and
// the off hand's listed in the BD22 VR bridge's models/rsqgc/mc/offguns.txt (RSQ_Off_Rifle) when that pk3 is loaded
// (bridge_bd22vr/: the off hand's blocks are keyed by the off-hand gun's class, which must be loaded for MODELDEF to take
// them). Every other gun keeps the voxel card. rsqgc_modelcard 0 puts the voxel card back on them too (to compare).
// Small Card Font: Ermac keeps the voxel card (only JFO is built as models so far).
//
// RIG ONLY, NOT HEADSET-CONFIRMED (see GunCards/docs/modelcard/).

extend class RSQGC_GunCard
{
	transient Array<Name> mMcMain, mMcOff;
	transient bool mMcRead;

	private static void McList(String path, out Array<Name> into)
	{
		int lump = Wads.CheckNumForFullName(path);
		if (lump < 0) return;
		Array<String> lines;
		String txt = Wads.ReadLump(lump);
		txt.Replace("\r", "");
		txt.Split(lines, "\n");
		for (int i = 0; i < lines.Size(); i++)
		{
			String s = lines[i];
			s.StripRight();
			if (s.Length() > 0 && s.Left(2) != "//") into.Push(Name(s));
		}
	}

	// does this hand's small card draw by models? owner: the layers' owner (RSQGC_CardItem on the main hand, the off-hand
	// gun on the off hand), w: the gun the card counts
	bool McUse(int hand, Actor owner, Weapon w)
	{
		if (!w || !owner || !ci("rsqgc_modelcard", 1) || ci("rsqgc_small_font", 0) == 1) return false;
		if (!mMcRead)
		{
			mMcMain.Clear(); mMcOff.Clear();
			McList("models/rsqgc/mc/guns.txt", mMcMain);
			McList("models/rsqgc/mc/offguns.txt", mMcOff);
			mMcRead = true;
			if (ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: model card guns: main %d, off hand %d (bridge %s)", mMcMain.Size(), mMcOff.Size(), mMcOff.Size() ? "loaded" : "not loaded");
		}
		if (hand == 0) return owner is "RSQGC_CardItem" && mMcMain.Find(w.GetClassName()) != mMcMain.Size();
		return mMcOff.Find(owner.GetClassName()) != mMcOff.Size();
	}

	// the first state of a model piece (RSQGC_MCStates, generated), its Bright twin under Card Glow
	static State McPiece(int kind, int slot, int depth)
	{
		int code = kind * 1000 + slot * 100 + depth;
		return RSQGC_Glow.Mode() > 0 ? RSQGC_MCStatesB.Piece(code) : RSQGC_MCStates.Piece(code);
	}
}
