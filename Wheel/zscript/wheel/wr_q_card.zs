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
	int mStyleSet;       // the style the live layers were last given
	Array<int> mPending; // layers made since the helper last ran: give them the style

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
			// only the layers made since last time (flags and style stay on a layer once given)
			let it = wr_CardItem(invoker);
			if (it)
			{
				for (int i = 0; i < it.mPending.Size(); i++)
				{
					int id = it.mPending[i];
					A_OverlayFlags(id, PSPF_ALPHA | PSPF_RENDERSTYLE | PSPF_FORCESTYLE | PSPF_FORCEALPHA, it.mStyle > 0);
					if (it.mStyle > 0) A_OverlayRenderStyle(id, it.mStyle);
				}
				it.mPending.Clear();
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
	static int ci(string n, int f) { let c = CVar.FindCVar(n); return c ? c.GetInt() : f; }

	// ---- what the card says ----------------------------------------------------------------------------
	// a second ammo pile is the magazine (the rule the wrist card has always used; Brutal Doom's guns keep
	// their magazine in Ammo2 and have alt fire too, so alt fire does not rule it out)
	static bool HasMagazine(Weapon w)
	{
		return w && w.Ammo1 && w.Ammo2 && w.Ammo2 != w.Ammo1;
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
	int TransFor(color c)
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
	// HAND NUMBERS ON SCREEN (wr_show_hands): what the engine tells the mods about the hands, for a screenshot
	// when something sits wrong in a headset. No console needed.
	private void ShowHands(PlayerPawn pmo)
	{
		if (level.maptime % 5 != 0) return;
		let p = pmo.player;
		Vector3 m = pmo.AttackPos - pmo.pos, o = pmo.OffhandPos - pmo.pos;
		string s = String.Format("RSQ hands  vr_mode %d  scheme %d  override %d\n", ci("vr_mode", -1), ci("vr_control_scheme", 0), pmo.OverrideAttackPosDir);
		s = s .. String.Format("body angle %.0f pitch %.0f  eye %.1f\n", pmo.angle, pmo.pitch, p.viewz - pmo.pos.z);
		s = s .. String.Format("MAIN  %.1f %.1f %.1f  yaw %.0f pitch %.0f roll %.0f\n", m.x, m.y, m.z, pmo.AttackAngle, pmo.AttackPitch, pmo.AttackRoll);
		s = s .. String.Format("OFF   %.1f %.1f %.1f  yaw %.0f pitch %.0f roll %.0f\n", o.x, o.y, o.z, pmo.OffhandAngle, pmo.OffhandPitch, pmo.OffhandRoll);
		s = s .. String.Format("guns  %s / %s  inspect %d %d", p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none', p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none', Inspect(pmo, 0), Inspect(pmo, 1));
		Console.MidPrint(null, s, true);
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = PlayerPawn(p.mo);
		if (!pmo) return;
		if (ci("wr_show_hands", 0)) ShowHands(pmo);
		if (p.playerstate != PST_LIVE || (ci("wr_card", 1) <= 0 && ci("wr_card_watch_tpl", 3) <= 0)) { ClearAll(p); return; }

		let item = wr_CardItem(pmo.FindInventory("wr_CardItem"));
		if (!item) item = wr_CardItem(pmo.GiveInventoryType("wr_CardItem"));
		if (!item) return;

		// see-through: wr_card_look 0 solid, 1 glass, 2 glow
		int look = ci("wr_card_look", 1);
		item.mStyle = look == 2 ? STYLE_Add : look == 1 ? STYLE_Translucent : 0;
		if (look > 0 && !p.FindPSprite(L_FX)) p.SetPSprite(L_FX, item.FindState("Fx"), false, item);

		if (item.mStyle != item.mStyleSet)
		{
			// the look changed: every live layer gets it again
			item.mStyleSet = item.mStyle;
			for (int id = L_FIRST; id <= L_LAST; id++) if (p.FindPSprite(id)) item.mPending.Push(id);
			for (int id = wr_DetailCard.BASE0; id < wr_SideCard.BASE0 + 800; id++) if (p.FindPSprite(id)) item.mPending.Push(id);
		}

		// WHICH CARD. Checking your watch with a gun shows that gun's watch card (wr_card_watch_tpl);
		// otherwise the always card (wr_card_tpl) shows when wr_card says. Templates: 1 ammo (the small
		// card), 2 compact, 3 full, 4 both hands (on the main-hand card).
		int tplAlways = ci("wr_card_tpl", 1), tplWatch = ci("wr_card_watch_tpl", 3);
		bool both = ci("wr_card_hands", 0) == 1;
		bool watching[2];
		for (int hand = 0; hand < 2; hand++) watching[hand] = tplWatch > 0 && Watching(pmo, hand);
		int tpl[2];
		bool show[2];
		Weapon gun[2], other[2];
		for (int hand = 0; hand < 2; hand++)
		{
			Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
			if (w && Loaded(w) < 0) w = null;
			gun[hand] = w;
			other[hand] = null;
			if (watching[hand]) { tpl[hand] = tplWatch; show[hand] = w != null; }
			else { tpl[hand] = tplAlways; show[hand] = w && tplAlways > 0 && Wanted(pmo, hand); }
		}
		// both guns on one card: the "both hands" template, or wr_card_hands for the ammo card. A watch card
		// rides the hand you are checking; the always card rides the main hand (the off hand's then stands
		// down). A host hand with nothing to count carries the other gun alone.
		for (int hand = 0; hand < 2; hand++)
		{
			bool bothHere = tpl[hand] == wr_DetailTemplates.T_BOTH || (tpl[hand] == wr_DetailTemplates.T_AMMO && both);
			if (!bothHere) continue;
			if (hand == 1 && !watching[1] && !watching[0] && gun[0] != null) { show[1] = false; continue; }
			other[hand] = gun[1 - hand];
			if (!gun[hand]) { gun[hand] = other[hand]; other[hand] = null; show[hand] = gun[hand] != null && (watching[hand] || Wanted(pmo, 0) || Wanted(pmo, 1)); }
		}
		for (int hand = 0; hand < 2; hand++)
		{
			double step = 1.0 / max(1, ci("wr_card_fade", 4));
			mShow[hand] = clamp(mShow[hand] + (show[hand] ? step : -step), 0.0, 1.0);
			Weapon w = gun[hand];
			Actor owner = hand == 1 ? Actor(p.OffhandWeapon) : Actor(item);
			if (mShow[hand] <= 0 || !w || !owner) { World(hand).Hide(); ClearHand(p, hand); Detail(hand).Remove(p); DetailOut(hand).Remove(p); Side(hand).Remove(p); SideOf(hand, 1).Remove(p); continue; }
			if (ci("wr_card_world", 0))
			{
				// in the world: no layers on the gun at all
				ClearHand(p, hand); Detail(hand).Remove(p); DetailOut(hand).Remove(p); Side(hand).Remove(p); SideOf(hand, 1).Remove(p);
				let wc = World(hand);
				bool wantFull = watching[hand] && tpl[hand] != wr_DetailTemplates.T_AMMO;
				if (!wc.Shown() || wc.full != wantFull) wc.Show(pmo.pos, wantFull);
				wc.Fill(pmo, w, STYLE_COL[clamp(StyleFor(p, w), 0, 17)]);
				wc.Place(pmo, cv("wr_card_world_scale", 1.0), wantFull ? WatchNudge(true) : Nudge(true), wantFull ? WatchNudge(false) : Nudge(false), mShow[hand] * cv("wr_card_alpha", 0.85));
				continue;
			}
			World(hand).Hide();
			if (watching[hand] && tpl[hand] != wr_DetailTemplates.T_AMMO)
			{
				// the watch card: the full card on the side of the gun at the grip hand (wr_q_side.zs)
				ClearHand(p, hand); Detail(hand).Remove(p); DetailOut(hand).Remove(p);
				DrawSide(p, pmo, hand, owner, w);
				continue;
			}
			Side(hand).Remove(p); SideOf(hand, 1).Remove(p);
			if (tpl[hand] == wr_DetailTemplates.T_AMMO)
			{
				Detail(hand).Remove(p); DetailOut(hand).Remove(p);
				Draw(p, pmo, hand, owner, w, other[hand], other[hand] != null);
			}
			else
			{
				ClearHand(p, hand);
				DrawDetail(p, pmo, hand, owner, w, other[hand], tpl[hand], watching[hand]);
			}
		}
	}

	// ---- the detailed card ---------------------------------------------------------------------------------
	transient wr_DetailCard mDetail[2], mDetailOut[2];
	wr_DetailCard Detail(int hand)
	{
		if (!mDetail[hand]) { mDetail[hand] = new("wr_DetailCard"); mDetail[hand].hand = hand; }
		return mDetail[hand];
	}
	static const int STYLE_COL[] = { 0xB0B0B0, 0x808080, 0x60C060, 0xC0B060, 0xB06060, 0x6080C0, 0x90A0B0, 0x7070D0, 0xA0A060, 0x9070B0, 0xD0A040, 0x60A0D0, 0xD060A0, 0x60D0C0, 0xC08040, 0x5070E0, 0xA0A0A0, 0xE0E0E0 };
	wr_WorldCard mWorld[2];
	wr_WorldCard World(int hand)
	{
		if (!mWorld[hand]) { mWorld[hand] = new("wr_WorldCard"); mWorld[hand].hand = hand; }
		return mWorld[hand];
	}
	override void WorldUnloaded(WorldEvent e) { for (int h = 0; h < 2; h++) if (mWorld[h]) mWorld[h].group = 0; }
	transient wr_SideCard mSide[2], mSide2[2];
	wr_SideCard Side(int hand) { return SideOf(hand, 0); }
	wr_SideCard SideOf(int hand, int side)
	{
		if (side == 0) { if (!mSide[hand]) { mSide[hand] = new("wr_SideCard"); mSide[hand].hand = hand; } return mSide[hand]; }
		if (!mSide2[hand]) { mSide2[hand] = new("wr_SideCard"); mSide2[hand].hand = hand; mSide2[hand].side = 1; }
		return mSide2[hand];
	}
	private void DrawSide(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w)
	{
		DrawSideOne(p, pmo, hand, owner, w, 0);
		DrawSideOne(p, pmo, hand, owner, w, 1);
	}
	private void DrawSideOne(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w, int side)
	{
		let c = SideOf(hand, side);
		bool mir = Mirrored(p, hand);
		int style = StyleFor(p, w);
		string sig = wr_DetailTemplates.Signature(pmo, w, null, 9, style) .. (mir ? " m" : "");
		if (sig != c.sig || c.mir != mir)
		{
			c.sig = sig; c.mir = mir;
			// the panel in the gun's colour: Ermac's panel colours by slot, as the top card
			c.Build(pmo, hand, w, wr_GunCard.STYLE_COL[clamp(style, 0, 17)]);
		}
		c.Sync(p, owner, mShow[hand] * cv("wr_card_alpha", 0.85), WatchNudge(true), self);
	}

	// the copy outboard of the grip (wr_card_both_sides): same layout, turned the other side of the hand
	wr_DetailCard DetailOut(int hand)
	{
		if (!mDetailOut[hand]) { mDetailOut[hand] = new("wr_DetailCard"); mDetailOut[hand].hand = hand; mDetailOut[hand].copy = 1; }
		return mDetailOut[hand];
	}

	// The panel for a gun: wr_card_style 1..18 is one of Ermac's for every gun; 0 gives each gun its own by
	// its weapon slot, as in the mock-ups (slot 2 gold, 3 red, 4 grey, 5 green, 6 blue ...)
	static const int SLOT_STYLE[] = { 2, 2, 4, 3, 1, 5, 16, 17, 12, 19 };   // Ermac's ammo_bg number per slot 0..9
	static int StyleFor(PlayerInfo p, Weapon w)
	{
		int st = ci("wr_card_style", 0);
		if (st > 0) return clamp(st, 1, wr_DetailStates.STYLES) - 1;
		int slot = 0;
		if (w)
		{
			bool found; int sl, idx;
			[found, sl, idx] = p.weapons.LocateWeapon(w.GetClass());
			if (found) slot = sl;
		}
		// Ermac's numbers skip 10: map the number to its place in the generated list
		int num = wr_GunCard.SLOT_STYLE[clamp(slot, 0, 9)];
		return num >= 10 ? num - 2 : num - 1;
	}
	private void DrawDetail(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w, Weapon other, int tpl, bool watching)
	{
		let c = Detail(hand);
		bool mir = Mirrored(p, hand);
		int style = StyleFor(p, w);
		string sig = wr_DetailTemplates.Signature(pmo, w, other, tpl, style) .. (mir ? " m" : "") .. String.Format(" %d", ci("wr_card_tint", 0));
		bool rolled = watching && ci("wr_card_watch_roll", 1) > 0;
		if (sig != c.sig || c.mir != mir || c.rolled != rolled)
		{
			c.sig = sig;
			c.mir = mir;
			c.rolled = rolled;
			c.Clear();
			int panelCol = -1, textCol = 0xF0F0F0;
			if (ci("wr_card_tint", 0))
			{
				color pc = wr_Look.Col(wr_Look.ROLE_COLS[24]);
				panelCol = (pc.r << 16) | (pc.g << 8) | pc.b;
			}
			if (tpl == wr_DetailTemplates.T_BOTH)
			{
				Weapon r = hand == 0 ? w : other, l = hand == 0 ? other : w;
				wr_DetailTemplates.Both(c, pmo, r, l, style, panelCol, textCol);
			}
			else wr_DetailTemplates.Single(c, pmo, hand, w, tpl == wr_DetailTemplates.T_COMPACT, style, panelCol, textCol);
		}
		c.Sync(p, owner, mShow[hand] * cv("wr_card_alpha", 0.85), self);
		// the same card on the other side of the grip, while checking your watch
		let o = DetailOut(hand);
		if (watching && ci("wr_card_both_sides", 1))
		{
			o.ops.Copy(c.ops); o.mir = c.mir; o.rolled = c.rolled; o.sig = c.sig;
			o.extraSide = cv("wr_card_out_turn", -40);
			o.Sync(p, owner, mShow[hand] * cv("wr_card_alpha", 0.85), self);
		}
		else o.Remove(p);
	}

	// CHECKING YOUR WATCH with this hand: RSQ Gestures' inspect when that mod is loaded (palm-down twist),
	// otherwise the Wheel's own watch pose (forearm across the chest, wrist in front of the face).
	private bool Watching(PlayerPawn pmo, int hand)
	{
		int g = Inspect(pmo, hand);
		if (g >= 0)
		{
			if (g >= ci("wr_card_inspect_level", 2)) mInspectTill[hand] = level.maptime + ci("wr_card_linger", 35);
			return level.maptime < mInspectTill[hand];
		}
		if (!pmo.OverrideAttackPosDir || !pmo.player) return false;
		Vector3 hp = hand == 1 ? pmo.OffhandPos : pmo.AttackPos;
		Vector3 to = hp - (pmo.pos.xy, pmo.player.viewz);
		to.z *= level.pixelstretch;
		double d = to.Length();
		if (d < 5 || d > 17) return false;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		if ((to / d) dot look < cos(35)) return false;
		double yaw = (hand == 1 ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
		Vector2 hd = (cos(yaw), sin(yaw));
		bool across = hd dot (cos(pmo.angle), sin(pmo.angle)) <= cos(55);
		if (across) mInspectTill[hand] = level.maptime + ci("wr_card_linger", 35);
		return level.maptime < mInspectTill[hand];
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
		// the top card: the magazine big, the reserve small under it (owner 02:47); on a both-hands card the
		// small row is the other gun
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
		int style = StyleFor(p, w);
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
			bool fresh = !ps || ps.Caller != owner;
			p.SetPSprite(id, s, false, owner);
			ps = p.FindPSprite(id);
			if (fresh) Fresh(id);
		}
		if (!ps) return;
		ps.bAddBob = false;
		ps.bAddWeapon = false;
		ps.x = cv("wr_card_side", 0) * 4;        // degrees about the model origin
		ps.y = 32 + cv("wr_card_up", 0) * 4;
		ps.alpha = alpha;
		ps.Translation = trans >= 0 ? TranslationID(trans) : TranslationID(0);
	}

	// a layer just made: the helper gives it the card's look next tic
	void Fresh(int id)
	{
		let p = players[consoleplayer];
		let item = p.mo ? wr_CardItem(p.mo.FindInventory("wr_CardItem")) : null;
		if (item) item.mPending.Push(id);
	}
	// the nudge sliders, degrees about the hand
	double Nudge(bool up) { return cv(up ? "wr_card_up" : "wr_card_side", 0); }
	double WatchNudge(bool up) { return cv(up ? "wr_card_watch_up" : "wr_card_watch_side", up ? -8 : 0); }

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
		World(0).Hide(); World(1).Hide();
		Detail(0).Remove(p); Detail(1).Remove(p); DetailOut(0).Remove(p); DetailOut(1).Remove(p); Side(0).Remove(p); Side(1).Remove(p); SideOf(0, 1).Remove(p); SideOf(1, 1).Remove(p);
		Kill(p, L_FX);
		mShow[0] = mShow[1] = 0;
	}
}
