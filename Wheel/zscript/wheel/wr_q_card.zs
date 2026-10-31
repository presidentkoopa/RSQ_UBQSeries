// wr_q_card.zs -- RSQ Wheel: THE CARD ON THE GUN (Project Wheel, items 1-5).
//
// A small holo display on each gun, in Ermac's Force Unleashed style and art (CREDITS.txt): his panel,
// his AMMO / MAGAZINE label, his digits. It stands over the stock facing you while you aim (the "rear
// display"), so the count is where your eye already is.
//
// HOW IT DRAWS. Every piece (panel, label, each digit) is a weapon layer drawn as a HUD model at the hand.
// The engine picks the hand by who owns the layer: the off hand when the owner is the off-hand gun
// (models.cpp:221). Because MODELDEF is keyed by the owner's class and the off-hand gun is any pack's
// gun, the pieces are VOXELDEF voxels (FindModelFrameRaw falls back to voxels for every class), built by
// tools/gen_cards.py with their place on the gun baked in. The main-hand card is owned by wr_CardItem,
// the off-hand card by the off-hand gun itself, and the states live on a Weapon class
// (wr_CardStates, generated) so the gun's layer accepts them (p_pspr.cpp:544-551).
//
// NO LAG. The pieces are part of the hand's own draw: the same transform, the same frame, as the gun.
// Nothing here moves them per tic; the tic only decides which digit each piece shows.
//
// MIRRORING. The physical left hand is drawn mirrored (hw_vrmodes.cpp:467) unless its gun is
// NoAutoReverse, so every piece has a mirrored twin and the card picks per hand.
//
// NUDGE. A layer's x / y turn its model about the model origin, a quarter degree a unit (hw_weapon.cpp:108),
// about a millimetre at the card: wr_card_side / wr_card_up move the whole card that way.
//
// SEE-THROUGH. A layer's alpha and render style can only be set from a state of the layer's own chain
// (A_OverlayFlags needs a calling layer, p_pspr.cpp:1011). wr_CardItem keeps a hidden helper layer whose
// state sets them on every card piece each tic.

class wr_CardItem : CustomInventory
{
	int mStyle;          // render style for every card piece, 0 = leave alone
	double mAlpha;

	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
		Inventory.MaxAmount 1;
	}
	States
	{
	Use:
		TNT1 A 0;
		Fail;
	Fx:
		TNT1 A 1
		{
			let it = wr_CardItem(invoker);
			if (it && it.mStyle > 0)
				for (int id = wr_GunCard.L_FIRST; id <= wr_GunCard.L_LAST; id++)
				{
					A_OverlayFlags(id, PSPF_ALPHA | PSPF_RENDERSTYLE | PSPF_FORCESTYLE | PSPF_FORCEALPHA, true);
					A_OverlayRenderStyle(id, it.mStyle);
				}
		}
		Loop;
	}
}

class wr_GunCard : EventHandler
{
	// layer ids: below PSP_TARGETCENTER, clear of the ring's and Ermac-style mods' own
	const L_FX = 1000299;
	const L_FIRST = 1000300;
	const L_LAST = 1000359;
	const PER_HAND = 20;       // main hand 1000300.., off hand 1000320..
	// pieces within a hand's block
	const P_PANEL = 0;
	const P_LABEL = 1;
	const P_BIG = 2;           // 3 slots
	const P_SMALL = 5;         // 3 slots

	double mShow[2];           // 0..1 fade per hand
	int mInspectTill[2];
	transient Array<int> mTransKey;
	transient Array<int> mTransId;
	transient Array<int> mLum;

	static wr_GunCard Get() { return wr_GunCard(EventHandler.Find("wr_GunCard")); }

	private static double cv(string n, double f) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : f; }
	private static int ci(string n, int f) { let c = CVar.FindCVar(n); return c ? c.GetInt() : f; }

	// ---- what the card says ----------------------------------------------------------------------------
	static bool HasMagazine(Weapon w)
	{
		return w && w.Ammo2 && w.Ammo2 != w.Ammo1 && !w.FindState('AltFire');
	}
	// rounds you can fire now, -1 for a gun with no ammo
	static int Loaded(Weapon w)
	{
		if (!w) return -1;
		if (HasMagazine(w)) return w.Ammo2.Amount;
		return w.Ammo1 ? w.Ammo1.Amount : -1;
	}
	static int LoadedCap(Weapon w)
	{
		if (!w) return 0;
		if (HasMagazine(w)) return w.Ammo2.MaxAmount;
		return w.Ammo1 ? w.Ammo1.MaxAmount : 0;
	}
	static int Reserve(Weapon w)
	{
		if (!HasMagazine(w) || !w.Ammo1) return -1;
		return w.Ammo1.Amount;
	}

	// ---- which way the hand is drawn ---------------------------------------------------------------------
	// hand 0 main, 1 off. The physical left hand is mirrored unless its gun says NoAutoReverse.
	static bool Mirrored(PlayerInfo p, int hand)
	{
		bool rightHanded = ci("vr_control_scheme", 0) < 10;
		bool physLeft = hand == 1 ? rightHanded : !rightHanded;
		if (!physLeft) return false;
		Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
		return !(w && w.bNoAutoReverse);
	}

	// ---- seen or not -------------------------------------------------------------------------------------
	// wr_card: 0 off, 1 always, 2 when you look at the gun, 3 the inspect gesture (RSQ_Gestures; without it,
	// as 2)
	private bool Wanted(PlayerPawn pmo, int hand)
	{
		int mode = ci("wr_card", 1);
		if (mode <= 0) return false;
		if (mode == 1) return true;
		if (mode == 3)
		{
			int g = Inspect(pmo, hand);
			if (g >= 0)
			{
				if (g >= ci("wr_card_inspect_level", 2)) mInspectTill[hand] = level.maptime + ci("wr_card_linger", 35);
				return level.maptime < mInspectTill[hand];
			}
		}
		return Glance(pmo, hand);
	}

	// RSQ_Gestures' answer for this hand, -1 when that mod is not loaded
	static int Inspect(PlayerPawn pmo, int hand)
	{
		let it = ServiceIterator.Find("RSQG_Service");
		Service s;
		while (s = it.Next()) return s.GetInt("inspect", "", hand, 0, pmo);
		return -1;
	}

	// The gun is in front of the eyes and the eyes are on it.
	private static bool Glance(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir || !pmo.player) return false;
		Vector3 hp = hand == 1 ? pmo.OffhandPos : pmo.AttackPos;
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 to = hp - eye;
		to.z *= level.pixelstretch;        // true proportions
		double d = to.Length();
		if (d < 4 || d > cv("wr_card_glance_reach", 0.7) * 34) return false;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		return (to / d) dot look >= cos(cv("wr_card_glance_cone", 30));
	}

	// ---- colour --------------------------------------------------------------------------------------------
	// A translation that recolours a piece by brightness into one colour (dark stays dark).
	private int TransFor(color c)
	{
		int key = (c.r << 16) | (c.g << 8) | c.b;
		for (int i = 0; i < mTransKey.Size(); i++) if (mTransKey[i] == key) return mTransId[i];
		if (mLum.Size() == 0) ReadPalette();
		Translation t;
		for (int i = 0; i < 256; i++)
		{
			double l = mLum.Size() == 256 ? mLum[i] / 255.0 : i / 255.0;
			l = min(1.0, l * 1.35);
			t.colors[i] = color(255, int(c.r * l), int(c.g * l), int(c.b * l));
		}
		int id = int(t.AddTranslation());
		mTransKey.Push(key); mTransId.Push(id);
		return id;
	}
	private void ReadPalette()
	{
		mLum.Clear();
		int lump = Wads.FindLump("PLAYPAL");
		if (lump < 0) return;
		string pal = Wads.ReadLump(lump);
		if (pal.Length() < 768) return;
		for (int i = 0; i < 256; i++)
		{
			int r = pal.ByteAt(i * 3), g = pal.ByteAt(i * 3 + 1), b = pal.ByteAt(i * 3 + 2);
			mLum.Push(int(0.299 * r + 0.587 * g + 0.114 * b));
		}
	}

	// ---- the tic ----------------------------------------------------------------------------------------------
	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = PlayerPawn(p.mo);
		if (!pmo) return;
		if (p.playerstate != PST_LIVE || ci("wr_card", 1) <= 0) { ClearAll(p); return; }

		let item = wr_CardItem(pmo.FindInventory("wr_CardItem"));
		if (!item) item = wr_CardItem(pmo.GiveInventoryType("wr_CardItem"));
		if (!item) return;

		// see-through: wr_card_look 0 solid, 1 glass, 2 glow
		int look = ci("wr_card_look", 1);
		item.mStyle = look == 2 ? STYLE_Add : look == 1 ? STYLE_Translucent : 0;
		if (look > 0 && !p.FindPSprite(L_FX)) p.SetPSprite(L_FX, item.FindState("Fx"), false, item);

		bool both = ci("wr_card_hands", 0) == 1;     // B: both guns on the main-hand card
		for (int hand = 0; hand < 2; hand++)
		{
			Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
			Weapon other = null;
			bool show;
			if (!both) show = w && Loaded(w) >= 0 && Wanted(pmo, hand);
			else if (hand == 1) show = false;
			else
			{
				// B: the main-hand card carries both guns -- big = main, small = off. A main hand with
				// nothing to count gives the card to the off-hand gun.
				Weapon o = p.OffhandWeapon;
				if (o && Loaded(o) < 0) o = null;
				if (!w || Loaded(w) < 0) { w = o; o = null; }
				other = o;
				show = w && (Wanted(pmo, 0) || Wanted(pmo, 1));
			}
			double step = 1.0 / max(1, ci("wr_card_fade", 4));
			mShow[hand] = clamp(mShow[hand] + (show ? step : -step), 0.0, 1.0);
			if (mShow[hand] <= 0 || !w) { ClearHand(p, hand); continue; }
			Actor owner = hand == 1 ? Actor(p.OffhandWeapon) : Actor(item);
			if (!owner) { ClearHand(p, hand); continue; }
			Draw(p, pmo, hand, owner, w, both ? other : null, both);
		}
	}

	private void Draw(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w, Weapon other, bool both)
	{
		bool mir = Mirrored(p, hand);
		int base = L_FIRST + hand * PER_HAND;
		double alpha = mShow[hand] * cv("wr_card_alpha", 0.85);

		int loaded = Loaded(w);
		int cap = LoadedCap(w);
		// low: a magazine below wr_lowammo_frac of a full one; any other gun only when it is empty (its
		// 'cap' is the backpack's, so a fraction of it means nothing)
		bool low = loaded == 0 || (HasMagazine(w) && cap > 0 && loaded <= cap * cv("wr_lowammo_frac", 0.25));
		int reserve = both ? (other ? Loaded(other) : -1) : Reserve(w);

		int tinted = ci("wr_card_tint", 0);
		int tPanel = -1, tDigits = -1;
		if (tinted)
		{
			tPanel = TransFor(wr_Look.Col(wr_Look.ROLE_COLS[24]));   // sheet_accent
			tDigits = TransFor(wr_Look.Col(wr_Look.ROLE_COLS[6]));   // ammo
		}
		int tLow = low && ci("wr_card_lowwarn", 1) ? TransFor(wr_Look.Col(wr_Look.ROLE_COLS[7])) : -1;   // ammo_dry

		// the panel
		int style = clamp(ci("wr_card_style", 5), 1, wr_CardStates.STYLES) - 1;
		Put(p, base + P_PANEL, Nth(wr_CardStates.Piece(0, mir), style), owner, alpha, tPanel);
		// the label: MAGAZINE on a gun with one, AMMO otherwise (CHAMBER is there for a pack that wants it)
		int lab = HasMagazine(w) ? 1 : 0;
		if (ci("wr_card_label", 1)) Put(p, base + P_LABEL, Nth(wr_CardStates.Piece(1, mir), lab), owner, alpha, tPanel);
		else Kill(p, base + P_LABEL);
		// the big number, right-aligned in three slots
		Digits(p, 2, mir, base + P_BIG, owner, clamp(loaded, 0, 999), false, alpha, tLow >= 0 ? tLow : tDigits);
		// the small number: the reserve (or the other gun's rounds on a both-hands card)
		if (reserve >= 0) Digits(p, 3, mir, base + P_SMALL, owner, clamp(reserve, 0, 999), true, alpha, tDigits);
		else for (int k = 0; k < wr_CardStates.SLOTS; k++) Kill(p, base + P_SMALL + k);
	}

	private void Digits(PlayerInfo p, int kind, bool mir, int base, Actor owner, int n, bool small, double alpha, int trans)
	{
		int slots = wr_CardStates.SLOTS;
		string s = String.Format("%d", n);
		int len = s.Length();
		for (int k = 0; k < slots; k++)
		{
			// slot 0 is the leftmost; a short number sits on the right
			int ci0 = k - (slots - len);
			if (ci0 < 0) { Kill(p, base + k); continue; }
			int g = s.ByteAt(ci0) - 48;
			Put(p, base + k, Nth(wr_CardStates.Piece(kind, mir, k), g), owner, alpha, trans);
		}
	}

	private static State Nth(State s, int n)
	{
		for (int i = 0; i < n && s; i++) s = s.NextState;
		return s;
	}

	private void Put(PlayerInfo p, int id, State s, Actor owner, double alpha, int trans)
	{
		if (!s) { Kill(p, id); return; }
		let ps = p.FindPSprite(id);
		if (!ps || ps.Caller != owner || ps.CurState != s)
		{
			p.SetPSprite(id, s, false, owner);
			ps = p.FindPSprite(id);
		}
		if (!ps) return;
		ps.bAddBob = false;
		ps.bAddWeapon = false;
		ps.x = cv("wr_card_side", 0) * 4;        // degrees about the model origin
		ps.y = 32 + cv("wr_card_up", 0) * 4;
		ps.alpha = alpha;
		ps.Translation = trans >= 0 ? TranslationID(trans) : TranslationID(0);
	}

	private static void Kill(PlayerInfo p, int id)
	{
		if (p.FindPSprite(id)) p.SetPSprite(id, null);
	}
	private void ClearHand(PlayerInfo p, int hand)
	{
		int base = L_FIRST + hand * PER_HAND;
		for (int i = 0; i < PER_HAND; i++) Kill(p, base + i);
	}
	private void ClearAll(PlayerInfo p)
	{
		ClearHand(p, 0); ClearHand(p, 1);
		Kill(p, L_FX);
		mShow[0] = mShow[1] = 0;
	}
}
