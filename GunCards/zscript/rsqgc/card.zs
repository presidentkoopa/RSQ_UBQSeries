// card.zs -- RSQ Gun Cards: THE CARDS ON THE GUNS (moved out of RSQ Wheel, where it was Project Wheel items 1-5).
//
// Two cards, in Ermac's Force Unleashed style and art (CREDITS.txt):
//   the small card   beside the wrist stub, right of it on the main hand, left of it on the off hand: his panel,
//                    his AMMO / MAGAZINE word, the rounds in the gun big and the reserve small (this file)
//   the watch card   check your watch knuckles up (RSQ Gestures' inspect; without it, the forearm across the chest)
//                    and the full card lies flat on both sides of that wrist: the gun's name, MAGAZINE / RESERVE,
//                    Gun Bonsai level, XP and upgrades (side.zs)
// Each gun has its own colour (by weapon slot), or one simple colour for every card (rsqgc_color).
//
// HOW THEY DRAW. Every piece (panel, word, each digit or letter) is a weapon layer drawn as a HUD model at the hand.
// The engine picks the hand by who owns the layer: the off hand when the owner is the off-hand gun
// (models.cpp:221). Because MODELDEF is keyed by the owner's class and the off-hand gun is any pack's gun, the
// pieces are VOXELDEF voxels (FindModelFrameRaw falls back to voxels for every class), built by tools/gen_cards.py
// and tools/gen_side.py with their place on the hand baked in. The main-hand card is owned by RSQGC_CardItem, the
// off-hand card by the off-hand gun itself, and the states live on Weapon classes (RSQGC_CardStates,
// RSQGC_SideStates, generated) so the gun's layer accepts them (p_pspr.cpp:544-551).
//
// NO LAG. The pieces are part of the hand's own draw: the same transform, the same frame, as the gun. Nothing here
// moves them per tic; the tic only decides which piece each layer shows. (rsqgc_world 1 draws the same cards as
// world quads instead, worldcard.zs: no gun can cover them, but they can trail a fast hand.)
//
// MIRRORING. The physical left hand is drawn mirrored (hw_vrmodes.cpp:467) unless its gun is NoAutoReverse, so
// every piece has a mirrored twin and the card picks per hand. Left-handed (vr_control_scheme 10+) follows.
//
// NUDGE. A layer's x / y turn its model about the model origin, a quarter degree a unit (hw_weapon.cpp:108), about
// a millimetre at the card: rsqgc_side / rsqgc_up move the small card, rsqgc_watch_up the watch card.
//
// SEE-THROUGH. A layer's alpha and render style can only be set from a state of the layer's own chain
// (A_OverlayFlags needs a calling layer, p_pspr.cpp:1011). RSQGC_CardItem keeps a hidden helper layer whose state
// sets them on every card piece made since it last ran.
//
// Needs nothing else. With RSQ Gestures loaded the watch check is its inspect pose; with Gun Bonsai and RSQ Gun
// Bonsai VR loaded the watch card shows levels and upgrades; with RSQ Wheel loaded the world cards follow its look.

class RSQGC_CardItem : CustomInventory
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
			let it = RSQGC_CardItem(invoker);
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

class RSQGC_GunCard : EventHandler
{
	// layer ids: below PSP_TARGETCENTER, clear of the Wheel's and Ermac-style mods' own
	const L_FX = 1000299;
	const L_FIRST = 1000300;
	const L_LAST = 1000359;
	const PER_HAND = 20;       // main hand 1000300.., off hand 1000320..
	const P_PANEL = 0;
	const P_LABEL = 1;
	const P_BIG = 2;           // 3 slots
	const P_SMALL = 5;         // 3 slots

	double mShow[2];           // 0..1 fade per hand
	int mInspectTill[2];
	transient Array<int> mTransKey;
	transient Array<int> mTransId;
	transient Array<int> mLum;
	transient RSQGC_LookState mLook;   // look.zs

	static RSQGC_GunCard Get() { return RSQGC_GunCard(EventHandler.Find("RSQGC_GunCard")); }

	static double cv(string n, double f) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : f; }
	static int ci(string n, int f) { let c = CVar.FindCVar(n); return c ? c.GetInt() : f; }

	// ---- what the card says ----------------------------------------------------------------------------
	// a second ammo pile is the magazine (Brutal Doom's guns keep their magazine in Ammo2 and have alt fire too,
	// so alt fire does not rule it out)
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

	// Gun Bonsai's colour codes (the colour it gives an upgrade's name), to RGB
	static int ColourOf(string code)
	{
		code = code.MakeUpper();
		if (code == "ORANGE") return 0xFF9030;
		if (code == "RED" || code == "DARKRED") return 0xFF5040;
		if (code == "GREEN" || code == "DARKGREEN" || code == "OLIVE") return 0x80E040;
		if (code == "BLUE" || code == "LIGHTBLUE" || code == "CYAN") return 0x60C8FF;
		if (code == "PURPLE") return 0xC080FF;
		if (code == "YELLOW" || code == "GOLD") return 0xFFD060;
		if (code == "BRICK" || code == "BROWN") return 0xD07040;
		return 0xE8E8E8;
	}

	// "R" / "L" as the player knows the hands (physical: a left-handed player's main hand is "L")
	static string HandTag(int hand)
	{
		let c = CVar.FindCVar("vr_control_scheme");
		bool rightHanded = !c || c.GetInt() < 10;
		return (hand == 0) == rightHanded ? "R" : "L";
	}

	static string NameOf(Weapon w)
	{
		// an off-hand copy (Brutal Doom VR's RSQ_Off_<gun>) goes by the gun it copies
		string cn = w.GetClassName();
		if (cn.Left(8) ~== "RSQ_Off_")
		{
			class<Actor> real = cn.Mid(8);
			if (real) { let d = GetDefaultByType(real); if (d) return d.GetTag(); }
		}
		string n = w.GetTag();
		if (n.Length() == 0) n = w.GetClassName();
		return n;
	}

	// the facts as one string: when it changes the card is laid out again
	static string Signature(PlayerPawn pmo, Weapon w, int kind, int style)
	{
		string s = String.Format("%d %d %s %d %d", kind, style, w ? w.GetClassName() : 'none', Loaded(w), Reserve(w));
		let e = RSQGC_Bonsai.Entry(pmo, w);
		if (e && e.lvl >= 0)
		{
			s = s .. String.Format(" b%d %d", e.lvl, e.permille / 20);
			for (int i = 0; i < e.names.Size(); i++) s = s .. String.Format(" %s%d%d", e.names[i], e.levels[i], e.on[i]);
		}
		return s;
	}

	// ---- where a hand is (the Wheel's wr_Rig.handPos / handDir) -----------------------------------------
	static Vector3 handPos(PlayerPawn pmo, int hand)
	{
		if (pmo.OverrideAttackPosDir) return (hand == 1) ? pmo.OffhandPos : pmo.AttackPos;
		double yaw = pmo.angle;
		double side = (hand == 1) ? -1.0 : 1.0;
		Vector3 head = pmo.Pos + (0, 0, pmo.player.viewheight);
		Vector3 fwd = (cos(yaw), sin(yaw), 0);
		Vector3 rt = (cos(yaw - 90), sin(yaw - 90), 0);
		return head + fwd * 22.0 + rt * (side * 11.0) - (0, 0, 8.0);
	}
	// the engine's own convention: a hand's facing is its angle plus ninety degrees
	static Vector3 handDir(PlayerPawn pmo, int hand)
	{
		double y, p;
		if (pmo.OverrideAttackPosDir)
		{
			y = ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
			p = (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		}
		else
		{
			y = pmo.angle;
			p = -pmo.pitch;
		}
		double cp = cos(p);
		return (cp * cos(y), cp * sin(y), sin(p));
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
	// rsqgc_card: 0 off, 1 always, 2 when you look at the gun, 3 the inspect gesture (RSQ Gestures; without it, as 2)
	private bool Wanted(PlayerPawn pmo, int hand)
	{
		int mode = ci("rsqgc_card", 1);
		if (mode <= 0) return false;
		if (mode == 1) return true;
		if (mode == 3)
		{
			int g = Inspect(pmo, hand);
			if (g >= 0)
			{
				if (g >= ci("rsqgc_inspect_level", 2)) mInspectTill[hand] = level.maptime + ci("rsqgc_linger", 35);
				return level.maptime < mInspectTill[hand];
			}
		}
		return Glance(pmo, hand);
	}

	// RSQ Gestures' answer for this hand, -1 when that mod is not loaded
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
		if (d < 4 || d > cv("rsqgc_glance_reach", 0.7) * 34) return false;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		return (to / d) dot look >= cos(cv("rsqgc_glance_cone", 30));
	}

	// CHECKING YOUR WATCH with this hand: RSQ Gestures' inspect when that mod is loaded (knuckles-up twist),
	// otherwise the forearm across the chest, the wrist in front of the face.
	private bool Watching(PlayerPawn pmo, int hand)
	{
		int g = Inspect(pmo, hand);
		if (g >= 0)
		{
			if (g >= ci("rsqgc_inspect_level", 2)) mInspectTill[hand] = level.maptime + ci("rsqgc_linger", 35);
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
		if (across) mInspectTill[hand] = level.maptime + ci("rsqgc_linger", 35);
		return level.maptime < mInspectTill[hand];
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

	// THE CARD COLOUR (owner 03:32: "select the colours from some simple selections"). rsqgc_color 0: each gun its
	// own (by its weapon slot, Ermac's panel colour for that slot); 1.. one colour for every card.
	static const int STYLE_COL[] = { 0xB0B0B0, 0x808080, 0x60C060, 0xC0B060, 0xB06060, 0x6080C0, 0x90A0B0, 0x7070D0, 0xA0A060, 0x9070B0, 0xD0A040, 0x60A0D0, 0xD060A0, 0x60D0C0, 0xC08040, 0x5070E0, 0xA0A0A0, 0xE0E0E0 };
	static const int PICK_COL[] = { 0, 0xE8E8E8, 0x8A8A8A, 0xE04040, 0xE0B040, 0x50D050, 0x5080F0, 0x50D0D0, 0xB060E0, 0xF08030, 0xF070B0 };
	static int CardColour(PlayerInfo p, Weapon w)
	{
		int pick = ci("rsqgc_color", 0);
		if (pick > 0 && pick < RSQGC_GunCard.PICK_COL.Size()) return RSQGC_GunCard.PICK_COL[pick];
		return RSQGC_GunCard.STYLE_COL[clamp(StyleFor(p, w), 0, 17)];
	}

	// The panel for a gun: rsqgc_style 1..18 is one of Ermac's for every gun; 0 gives each gun its own by its weapon
	// slot, as in the mock-ups (slot 2 gold, 3 red, 4 grey, 5 green, 6 blue ...)
	static const int SLOT_STYLE[] = { 2, 2, 4, 3, 1, 5, 16, 17, 12, 19 };   // Ermac's ammo_bg number per slot 0..9
	static int StyleFor(PlayerInfo p, Weapon w)
	{
		int st = ci("rsqgc_style", 0);
		if (st > 0) return clamp(st, 1, RSQGC_CardStates.STYLES) - 1;
		int slot = 0;
		if (w)
		{
			bool found; int sl, idx;
			[found, sl, idx] = p.weapons.LocateWeapon(w.GetClass());
			if (found) slot = sl;
		}
		// Ermac's numbers skip 10: map the number to its place in the generated list
		int num = RSQGC_GunCard.SLOT_STYLE[clamp(slot, 0, 9)];
		return num >= 10 ? num - 2 : num - 1;
	}

	// ---- the tic ----------------------------------------------------------------------------------------------
	// HAND NUMBERS ON SCREEN (rsqgc_show_hands): what the engine tells the mods about the hands, for a screenshot
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
		if (ci("rsqgc_show_hands", 0)) ShowHands(pmo);
		bool watchOn = ci("rsqgc_watch", 1) > 0;
		if (p.playerstate != PST_LIVE || (ci("rsqgc_card", 1) <= 0 && !watchOn)) { ClearAll(p); return; }

		let item = RSQGC_CardItem(pmo.FindInventory("RSQGC_CardItem"));
		if (!item) item = RSQGC_CardItem(pmo.GiveInventoryType("RSQGC_CardItem"));
		if (!item) return;

		// see-through: rsqgc_look 0 solid, 1 glass, 2 glow
		int look = ci("rsqgc_look", 1);
		item.mStyle = look == 2 ? STYLE_Add : look == 1 ? STYLE_Translucent : 0;
		if (look > 0 && !p.FindPSprite(L_FX)) p.SetPSprite(L_FX, item.FindState("Fx"), false, item);
		if (item.mStyle != item.mStyleSet)
		{
			// the look changed: every live layer gets it again
			item.mStyleSet = item.mStyle;
			for (int id = L_FIRST; id <= L_LAST; id++) if (p.FindPSprite(id)) item.mPending.Push(id);
			for (int id = RSQGC_SideCard.BASE0; id < RSQGC_SideCard.BASE0 + 800; id++) if (p.FindPSprite(id)) item.mPending.Push(id);
		}

		// WHICH CARD. Checking your watch with a gun shows that gun's watch card (rsqgc_watch); otherwise the small
		// card shows when rsqgc_card says.
		bool both = ci("rsqgc_hands", 0) == 1;
		bool watching[2];
		for (int hand = 0; hand < 2; hand++) watching[hand] = watchOn && Watching(pmo, hand);
		bool show[2];
		Weapon gun[2], other[2];
		for (int hand = 0; hand < 2; hand++)
		{
			Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
			if (w && Loaded(w) < 0) w = null;
			gun[hand] = w;
			other[hand] = null;
			show[hand] = watching[hand] ? w != null : (w && Wanted(pmo, hand));
		}
		// both guns on the main-hand small card (rsqgc_hands): the off hand's stands down. A host hand with nothing
		// to count carries the other gun alone. A hand you are checking shows its watch card instead.
		for (int hand = 0; hand < 2; hand++)
		{
			if (!both || watching[hand]) continue;
			if (hand == 1 && !watching[1] && !watching[0] && gun[0] != null) { show[1] = false; continue; }
			other[hand] = gun[1 - hand];
			if (!gun[hand]) { gun[hand] = other[hand]; other[hand] = null; show[hand] = gun[hand] != null && (watching[hand] || Wanted(pmo, 0) || Wanted(pmo, 1)); }
		}
		for (int hand = 0; hand < 2; hand++)
		{
			double step = 1.0 / max(1, ci("rsqgc_fade", 4));
			mShow[hand] = clamp(mShow[hand] + (show[hand] ? step : -step), 0.0, 1.0);
			Weapon w = gun[hand];
			Actor owner = hand == 1 ? Actor(p.OffhandWeapon) : Actor(item);
			if (mShow[hand] <= 0 || !w || !owner) { World(hand).Hide(); ClearHand(p, hand); Side(hand).Remove(p); SideOf(hand, 1).Remove(p); continue; }
			if (ci("rsqgc_world", 0))
			{
				// in the world: no layers on the gun at all
				ClearHand(p, hand); Side(hand).Remove(p); SideOf(hand, 1).Remove(p);
				let wc = World(hand);
				bool wantFull = watching[hand];
				if (!wc.Shown() || wc.full != wantFull) wc.Show(pmo.pos, wantFull);
				wc.Fill(pmo, w, CardColour(p, w));
				wc.Place(pmo, cv("rsqgc_world_scale", 1.4), wantFull ? WatchNudge(true) : Nudge(true), wantFull ? WatchNudge(false) : Nudge(false), mShow[hand] * cv("rsqgc_alpha", 0.85));
				continue;
			}
			World(hand).Hide();
			if (watching[hand])
			{
				// the watch card: the full card flat on both sides of the wrist (side.zs)
				ClearHand(p, hand);
				DrawSide(p, pmo, hand, owner, w);
				continue;
			}
			Side(hand).Remove(p); SideOf(hand, 1).Remove(p);
			Draw(p, pmo, hand, owner, w, other[hand], other[hand] != null);
		}
	}

	// ---- the cards in the world -----------------------------------------------------------------------------
	RSQGC_WorldCard mWorld[2];
	RSQGC_WorldCard World(int hand)
	{
		if (!mWorld[hand]) { mWorld[hand] = new("RSQGC_WorldCard"); mWorld[hand].hand = hand; }
		return mWorld[hand];
	}
	override void WorldUnloaded(WorldEvent e) { for (int h = 0; h < 2; h++) if (mWorld[h]) mWorld[h].live = false; }

	// ---- the watch card ---------------------------------------------------------------------------------------
	transient RSQGC_SideCard mSide[2], mSide2[2];
	RSQGC_SideCard Side(int hand) { return SideOf(hand, 0); }
	RSQGC_SideCard SideOf(int hand, int side)
	{
		if (side == 0) { if (!mSide[hand]) { mSide[hand] = new("RSQGC_SideCard"); mSide[hand].hand = hand; } return mSide[hand]; }
		if (!mSide2[hand]) { mSide2[hand] = new("RSQGC_SideCard"); mSide2[hand].hand = hand; mSide2[hand].side = 1; }
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
		string sig = Signature(pmo, w, 9, style) .. (mir ? " m" : "") .. String.Format(" c%d", ci("rsqgc_color", 0));
		if (sig != c.sig || c.mir != mir)
		{
			c.sig = sig; c.mir = mir;
			c.Build(pmo, hand, w, CardColour(p, w));
		}
		c.Sync(p, owner, mShow[hand] * cv("rsqgc_alpha", 0.85), WatchNudge(true), self);
	}

	// ---- the small card ---------------------------------------------------------------------------------------
	private void Draw(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w, Weapon other, bool both)
	{
		bool mir = Mirrored(p, hand);
		int base = L_FIRST + hand * PER_HAND;
		double alpha = mShow[hand] * cv("rsqgc_alpha", 0.85);

		int loaded = Loaded(w);
		int cap = LoadedCap(w);
		// low: a magazine below rsqgc_lowammo_frac of a full one; any other gun only when it is empty (its 'cap' is
		// the backpack's, so a fraction of it means nothing)
		bool low = loaded == 0 || (HasMagazine(w) && cap > 0 && loaded <= cap * cv("rsqgc_lowammo_frac", 0.25));
		// the magazine big, the reserve small under it (owner 02:47); on a both-guns card the small row is the other gun
		int reserve = both ? (other ? Loaded(other) : -1) : Reserve(w);

		int tinted = ci("rsqgc_tint", 0);
		int tPanel = -1, tDigits = -1;
		int pick = ci("rsqgc_color", 0);
		if (pick > 0) tPanel = TransFor(CardColour(p, w));
		if (tinted)
		{
			tPanel = TransFor(RSQGC_Look.Role(RSQGC_Look.R_SHEET_ACCENT));
			tDigits = TransFor(RSQGC_Look.Role(RSQGC_Look.R_AMMO));
		}
		int tLow = low && ci("rsqgc_lowwarn", 1) ? TransFor(RSQGC_Look.Role(RSQGC_Look.R_AMMO_DRY)) : -1;

		// the panel
		int style = StyleFor(p, w);
		Put(p, base + P_PANEL, Nth(RSQGC_CardStates.Piece(0, mir), style), owner, alpha, tPanel);
		// the word: MAGAZINE on a gun with one, AMMO otherwise
		int lab = HasMagazine(w) ? 1 : 0;
		if (ci("rsqgc_label", 1)) Put(p, base + P_LABEL, Nth(RSQGC_CardStates.Piece(1, mir), lab), owner, alpha, tPanel);
		else Kill(p, base + P_LABEL);
		// the big number, right-aligned in three slots
		Digits(p, 2, mir, base + P_BIG, owner, clamp(loaded, 0, 999), false, alpha, tLow >= 0 ? tLow : tDigits);
		// the small number: the reserve (or the other gun's rounds on a both-guns card)
		if (reserve >= 0) Digits(p, 3, mir, base + P_SMALL, owner, clamp(reserve, 0, 999), true, alpha, tDigits);
		else for (int k = 0; k < RSQGC_CardStates.SLOTS; k++) Kill(p, base + P_SMALL + k);
	}

	private void Digits(PlayerInfo p, int kind, bool mir, int base, Actor owner, int n, bool small, double alpha, int trans)
	{
		int slots = RSQGC_CardStates.SLOTS;
		string s = String.Format("%d", n);
		int len = s.Length();
		for (int k = 0; k < slots; k++)
		{
			// slot 0 is the leftmost; a short number sits on the right
			int ci0 = k - (slots - len);
			if (ci0 < 0) { Kill(p, base + k); continue; }
			int g = s.ByteAt(ci0) - 48;
			Put(p, base + k, Nth(RSQGC_CardStates.Piece(kind, mir, k), g), owner, alpha, trans);
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
		ps.x = cv("rsqgc_side", 0) * 4;        // degrees about the model origin
		ps.y = 32 + cv("rsqgc_up", 0) * 4;
		ps.alpha = alpha;
		ps.Translation = trans >= 0 ? TranslationID(trans) : TranslationID(0);
	}

	// a layer just made: the helper gives it the card's look next tic
	void Fresh(int id)
	{
		let p = players[consoleplayer];
		let item = p.mo ? RSQGC_CardItem(p.mo.FindInventory("RSQGC_CardItem")) : null;
		if (item) item.mPending.Push(id);
	}
	// the nudge sliders, degrees about the hand
	double Nudge(bool up) { return cv(up ? "rsqgc_up" : "rsqgc_side", 0); }
	double WatchNudge(bool up) { return cv(up ? "rsqgc_watch_up" : "rsqgc_watch_side", 0); }

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
		Side(0).Remove(p); Side(1).Remove(p); SideOf(0, 1).Remove(p); SideOf(1, 1).Remove(p);
		Kill(p, L_FX);
		mShow[0] = mShow[1] = 0;
	}
}
