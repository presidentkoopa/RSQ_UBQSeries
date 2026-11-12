// card.zs -- RSQ Gun Cards: THE CARDS ON THE GUNS (moved out of RSQ Wheel, where it was Project Wheel items 1-5).
//
// Two cards, in Ermac's Force Unleashed style and art (CREDITS.txt):
//   the small card   beside the wrist stub, right of it on the main hand, left of it on the off hand: his panel,
//                    his AMMO / MAGAZINE word, the rounds in the gun big and the reserve small (this file)
//   the watch card   check your watch, the back of the wrist to your face (RSQ Accessibility's watch check, the reader that
//                    was RSQ Gestures until it was folded in, 11-05; without it, Gun Cards' own copy of that reader,
//                    gestcopy.zs: the same pose) and the full card lies flat on the back-of-the-hand side of that wrist: the gun's name, MAGAZINE / RESERVE,
//                    Gun Bonsai level, XP and upgrades (side.zs)
// A weapon with no ammo pile (a melee weapon, a tool) has an item card on the watch instead: its name and what it holds
// over the status rows (items.zs); an empty hand has the status card.
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
// a millimetre at the card: rsqgc_side / rsqgc_up move the small card (or the gun's own spot, spots.zs), rsqgc_watch_up
// the watch card. Watch Card Side moves only the world watch card: the hand-drawn one has one turn, its rows (side.zs).
//
// SEE-THROUGH. A layer's alpha and render style can only be set from a state of the layer's own chain
// (A_OverlayFlags needs a calling layer, p_pspr.cpp:1011). RSQGC_CardItem keeps a hidden helper layer whose state
// sets them on every card piece made since it last ran.
//
// Needs nothing else. The watch check is RSQ Accessibility's inspect pose: asked of it when it is loaded, else read by
// Gun Cards' own copy of it (gestcopy.zs, RSQGC_GCopyService: RSQ Tactical Rig asks that by name too); with Gun Bonsai and RSQ Gun
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
	const P_BIG = 2;           // 5 slots (centred numbers, 2026-11-03)
	const P_SMALL = 7;         // 5 slots

	double mShow[2];           // 0..1 fade per hand
	int mInspectTill[2];
	int mReloadTill[2];        // "On Reload": shown until this tic (its own clock: a reload is not a watch check)
	bool mWasWatch[2];         // the card a hand showed last was the watch card: it fades out as itself
	bool mWasStatus[2];        // ...and it was the status card (GC5)
	double mTiltX[2], mTiltY[2];   // "Tilt to Your Eyes": the small card's turn this tic, psp units (TiltTo)
	transient Array<int> mTransKey;
	transient Array<int> mTransId;
	transient Array<int> mLum;
	transient RSQGC_LookState mLook;   // look.zs

	static RSQGC_GunCard Get() { return RSQGC_GunCard(EventHandler.Find("RSQGC_GunCard")); }
	int mLvHide[2];     // the small card stands down until this map tic: RSQ VisualRewards' weapon level card is in its place (RSQGC_Service)

	// ---- THE QoL ROUND (owner, 2026-10-31 afternoon) -----------------------------------------------------------
	// GC2 "+N" on a pickup: per hand, the gun and its ammo pile last tic (Pile: the reserve, so BD22 VR's rounds lent back
	// into the pile from its real magazine are no pickup); a rise of that pile is ammo picked up (a reload moves rounds OUT
	// of it, into the magazine), shown in the reserve's place for rsqgc_plus_tics.
	Weapon mTrackW[2];
	int mTrackAmt[2], mTrackLoaded[2];
	int mPlusN[2], mPlusTill[2];
	// GC7 kills with this gun this level. This handler is a level one (MAPINFO AddEventHandlers), so a new map starts
	// at 0. A kill goes to the hand that fired last within KILL_WINDOW tics (its rounds went down), and to neither
	// when both fired the same tic or neither fired: the attribution RSQ Wheel's stat tracker uses (wr_stattracker.zs
	// "ATTRIBUTION IS A GUESS, AND IT FAILS CLOSED"). The Wheel's own counts are not reachable by name (no service
	// answers them), so the cards keep their own.
	const KILL_WINDOW = 35;
	int mFiredTic[2];
	Array<Weapon> mKillW;
	Array<int> mKillN;
	Array<Actor> mDeadSeen;

	void Track(PlayerInfo p)
	{
		for (int hand = 0; hand < 2; hand++)
		{
			Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
			int amt = Pile(w);
			int ld = Loaded(w);
			if (w && w == mTrackW[hand])
			{
				if (amt > mTrackAmt[hand] && mTrackAmt[hand] >= 0)
				{
					int d = amt - mTrackAmt[hand];
					mPlusN[hand] = level.maptime < mPlusTill[hand] ? mPlusN[hand] + d : d;
					mPlusTill[hand] = level.maptime + max(1, ci("rsqgc_plus_tics", 52));
				}
				if (ld >= 0 && ld < mTrackLoaded[hand]) mFiredTic[hand] = level.maptime;
			}
			else mPlusTill[hand] = 0;
			mTrackW[hand] = w; mTrackAmt[hand] = amt; mTrackLoaded[hand] = ld;
		}
	}
	// "+N" now for this hand, 0 none
	int PlusNow(int hand) { return level.maptime < mPlusTill[hand] ? mPlusN[hand] : 0; }

	override void WorldThingDamaged(WorldEvent e)
	{
		let t = e.Thing;
		if (!t || t.Health > 0 || !(t.bIsMonster || t.bCountKill)) return;
		let src = e.DamageSource;
		if (!src || !src.player || src.player != players[consoleplayer]) return;
		if (mDeadSeen.Find(t) != mDeadSeen.Size()) return;
		if (mDeadSeen.Size() >= 64) mDeadSeen.Delete(0);
		mDeadSeen.Push(t);
		let p = src.player;
		int now = level.maptime;
		bool m = now - mFiredTic[0] <= KILL_WINDOW && mFiredTic[0] > 0, o = now - mFiredTic[1] <= KILL_WINDOW && mFiredTic[1] > 0;
		int hand = -1;
		if (m && (!o || mFiredTic[0] > mFiredTic[1])) hand = 0;
		else if (o && (!m || mFiredTic[1] > mFiredTic[0])) hand = 1;
		if (hand < 0) return;
		Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
		if (!w) return;
		int k = mKillW.Find(w);
		if (k == mKillW.Size()) { mKillW.Push(w); mKillN.Push(0); }
		mKillN[k]++;
		if (ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: kill %s -> %s hand %s (%d this level)", t.GetClassName(), hand ? "off" : "main", w.GetClassName(), mKillN[k]);
	}
	int KillsWith(Weapon w)
	{
		int k = mKillW.Find(w);
		return k < mKillW.Size() ? mKillN[k] : 0;
	}

	// GC4 Brutal Doom's GRENADE count (GrenadeAmmo, brutal22test6 actors/MISC/Ammo.dec: the hand grenades; the mines
	// are another pile and are NOT shown, owner). Without Brutal Doom's, RSQ Grenade's own (RSQGN_Ammo, 11-01) when that
	// pk3 is loaded. -1 when neither exists.
	static int Grenades(PlayerPawn pmo)
	{
		// a String first: a quoted class name is resolved when the script compiles, and without Brutal
		// Doom that is a script error (found 11-01 on plain Doom 2); a String variable is looked up at run time
		String gn = "GrenadeAmmo";
		class<Inventory> g = gn;
		if (!g) { gn = "RSQGN_Ammo"; g = gn; }
		if (!g) return -1;
		let it = pmo.FindInventory(g);
		return it ? it.Amount : 0;
	}

	// THE GRENADE'S FUSE COUNT (Gun Bonsai VR's Cook Sense 3, asked of RSQ Grenade by name): while the grenade in this hand
	// cooks, its whole seconds left; -1 otherwise (or without RSQ Grenade). FuseAmber: the fuse's first half (amber, as the
	// grenade's own flash), else red.
	static int FuseCount(PlayerInfo p, int hand)
	{
		Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
		if (!w || w.GetClassName() != 'RSQGN_Grenade' || !p.mo) return -1;
		let s = ServiceIterator.Find("RSQGN_Service").Next();
		return s ? s.GetInt("fuse.count", "", p.mo.PlayerNumber()) : -1;
	}
	static bool FuseAmber(PlayerInfo p)
	{
		let s = ServiceIterator.Find("RSQGN_Service").Next();
		return s && p.mo && s.GetInt("fuse.amber", "", p.mo.PlayerNumber()) == 1;
	}

	// what the extra lines say, for the watch card's signature
	string ExtraSig(PlayerPawn pmo, int hand, Weapon w)
	{
		return String.Format(" +%d k%d g%d", PlusNow(hand), KillsWith(w), Grenades(pmo));
	}

	// GC1 (Option): the gun up at your eye (sights or a scope): the hand within rsqgc_eye_reach metres of the eye and
	// pointing along where you look (within 25 degrees)
	static bool AtEye(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir || !pmo.player) return false;
		Vector3 hp = hand == 1 ? pmo.OffhandPos : pmo.AttackPos;
		Vector3 to = hp - (pmo.pos.xy, pmo.player.viewz);
		to.z *= level.pixelstretch;
		if (to.Length() > cv("rsqgc_eye_reach", 0.30) * cv("vr_vunits_per_meter", 34)) return false;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		return handDir(pmo, hand) dot look >= cos(25);
	}

	// GC5: a hand with nothing to count: no weapon, or fists (Brutal Doom's Melee_Attacks, Brutal Doom VR's off-hand
	// RSQ_Hands, vanilla's Fist)
	static bool EmptyHand(PlayerInfo p, int hand)
	{
		Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
		if (!w) return true;
		Name cn = w.GetClassName();
		return cn == 'Melee_Attacks' || cn == 'RSQ_Hands' || cn == 'Fist';
	}

	static double cv(string n, double f) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : f; }
	// CARDS ALIVE (owner 2026-11-11 23:56: "IF we could give them life like our RSQ bars I would want that as a toggle,
	// default on"; 11-12 00:44, his pick: the animated look). Cards Alive (rsqgc_alive, on): every card breathes -- its
	// opacity eases between 82% and 100% of Card Opacity once every 2 s, the off hand's card half a beat behind the main
	// hand's, as the SlowMo bars' edge breathes. Every card takes its opacity from here (the hand-drawn cards, the watch
	// and status cards, the cards in the world), so they breathe together. A slow ease, never a flash. Off: steady.
	// Seen only where the Material shows opacity (Glass, Glow, No Background); a Solid card stays solid.
	// CODE ONLY, NOT COMPILED OR SHOWN (owner 11-12 01:19: no rig runs).
	static double CardAlpha(int hand)
	{
		double a = cv("rsqgc_alpha", 0.85);
		let c = CVar.FindCVar("rsqgc_alive");
		if (c && !c.GetBool()) return a;
		double ph = (level.maptime % 70) * (360.0 / 70.0) + (hand ? 180.0 : 0.0);
		return a * (0.91 + 0.09 * sin(ph));
	}
	static int ci(string n, int f) { let c = CVar.FindCVar(n); return c ? c.GetInt() : f; }

	// ---- what the card says ----------------------------------------------------------------------------
	// BD22 VR'S REAL MAGAZINES (its counters.zs RealTick and GunAmmo, read by name; owner 11-10: a card for every weapon of
	// the series, guns their rounds). Nine guns Brutal Doom never reloads (MG42, Flamethrower2, IncendiaryLauncher,
	// Machinegun, Unmaker, Devastator, NukeLauncher, HellishMissileLauncher, Minigun) keep the rounds in the gun in
	// RSQ_Mag_<gun> while BD22 VR's hand reloading is on for them (rsr_reload 1, rsq_reload_nonstd on, in VR), and lend up
	// to 10 of them to the reserve pile (RSQ_Lent_<gun>) so Brutal Doom's fire code finds them. Then the magazine is
	// RSQ_Mag_<gun> and the reserve the pile less the lent rounds, as BD22 VR's own HUD shows them. Off, the gun is Brutal
	// Doom's: one count, the pile (the Machinegun's Ammo2 is its launcher's rockets, not a magazine).
	// Answers: -1 any other gun, 0 off, 1 on; then the magazine, its size and the reserve.
	static int, int, int, int RealMag(Weapon w)
	{
		let pmo = w ? PlayerPawn(w.Owner) : null;
		if (!pmo || !pmo.player || !w.Ammo1) return -1, 0, 0, 0;
		String cn = w.GetClassName();
		class<Inventory> mag = "RSQ_Mag_" .. cn;
		class<Inventory> lent = "RSQ_Lent_" .. cn;
		if (!mag || !lent) return -1, 0, 0, 0;
		let rr = CVar.GetCVar("rsr_reload", pmo.player), ns = CVar.GetCVar("rsq_reload_nonstd", pmo.player);
		bool on = rr && rr.GetInt() == 1 && (!ns || ns.GetInt() != 0) && pmo.player.PlayInVR && pmo.OverrideAttackPosDir;
		if (!on) return 0, 0, 0, 0;
		let d = GetDefaultByType(mag);
		return 1, pmo.CountInv(mag), d ? d.MaxAmount : 0, max(0, w.Ammo1.Amount - pmo.CountInv(lent));
	}
	// the magazine: a second ammo pile (Brutal Doom's guns keep their magazine in Ammo2 and have alt fire too, so alt fire
	// does not rule it out), or BD22 VR's real magazine
	static bool HasMagazine(Weapon w)
	{
		if (!w || !w.Ammo1) return false;
		int real, m, cap, res;
		[real, m, cap, res] = RealMag(w);
		if (real >= 0) return real == 1;
		return w.Ammo2 && w.Ammo2 != w.Ammo1;
	}
	// rounds you can fire now; an item's count (items.zs: flares, cigarettes); -1 for a weapon with nothing to count
	static int Loaded(Weapon w)
	{
		if (!w) return -1;
		if (!w.Ammo1) return RSQGC_Items.SmallCount(w) ? RSQGC_Items.Count(w) : -1;
		int real, m, cap, res;
		[real, m, cap, res] = RealMag(w);
		if (real == 1) return m;
		if (HasMagazine(w)) return w.Ammo2.Amount;
		return w.Ammo1.Amount;
	}
	static int LoadedCap(Weapon w)
	{
		if (!w || !w.Ammo1) return 0;
		int real, m, cap, res;
		[real, m, cap, res] = RealMag(w);
		if (real == 1) return cap;
		if (HasMagazine(w)) return w.Ammo2.MaxAmount;
		return w.Ammo1.MaxAmount;
	}
	static int Reserve(Weapon w)
	{
		if (!HasMagazine(w)) return -1;
		int real, m, cap, res;
		[real, m, cap, res] = RealMag(w);
		return real == 1 ? res : w.Ammo1.Amount;
	}
	// the pile a pickup raises (GC2): the reserve of a gun with a magazine, else its one count
	static int Pile(Weapon w)
	{
		int r = Reserve(w);
		return r >= 0 ? r : Loaded(w);
	}

	// THE MAGAZINE'S COLOUR (owner 2026-11-03, under Low Ammo Colour): green above half a magazine, yellow from half down
	// to Low Below (rsqgc_lowammo_frac, a quarter), red at or below it; three clear steps. A gun with no magazine: red when
	// empty, else no colour (its "cap" is the backpack's). -1: no colour (the count's own white).
	const MAG_GREEN = 0x50E050;
	const MAG_YELLOW = 0xF0D030;
	const MAG_RED = 0xFF5040;
	const RESERVE_GOLD = 0xFFB820;
	const RELOAD_FLIP = 52;   // tics between RELOAD and "0" on an empty magazine (1.5 s, owner 09:42)
	int mEmptySince[2];       // 1 + the tic this hand's magazine emptied with rounds to load, 0 not empty
	int mFlipWas[2];          // 1 + the phase shown last (0 RELOAD, 1 "0"), 0 none: for the debug log
	static int MagColour(Weapon w, int loaded)
	{
		if (!w || loaded < 0 || !ci("rsqgc_lowwarn", 1)) return -1;
		if (loaded == 0) return MAG_RED;
		if (!HasMagazine(w)) return -1;
		int cap = LoadedCap(w);
		if (cap <= 0) return -1;
		if (loaded <= cap * cv("rsqgc_lowammo_frac", 0.25)) return MAG_RED;
		if (loaded * 2 <= cap) return MAG_YELLOW;
		return MAG_GREEN;
	}
	static int ArmorOf(PlayerPawn pmo)
	{
		let arm = pmo.FindInventory("BasicArmor");
		return arm ? arm.Amount : 0;
	}
	// Text Quality (owner 2026-11-03): 0 Quest (JFO at half resolution), 1 PCVR (full)
	static int Quality() { return clamp(ci("rsqgc_text_q", 0), 0, 1); }

	// ---- THE KEYS (owner 2026-11-03: "I'd like to be able to know if a map uses skull keys or not so we don't confuse
	// the player") -------------------------------------------------------------------------------------------------------
	// A key by its class name, as the status card always read them: red / yellow / blue in the name, "skull" in it for a
	// skull. 0-2 the red / yellow / blue keycard, 3-5 the skulls, -1 another key.
	static int KeyType(string cn)
	{
		cn = cn.MakeLower();
		int c = -1;
		if (cn.IndexOf("red") >= 0) c = 0;
		else if (cn.IndexOf("yellow") >= 0 || cn.IndexOf("gold") >= 0) c = 1;
		else if (cn.IndexOf("blue") >= 0) c = 2;
		if (c < 0) return -1;
		return cn.IndexOf("skull") >= 0 ? c + 3 : c;
	}
	// the keys held: a bit per KeyType, and how many other keys
	static int, int HeldKeys(PlayerPawn pmo)
	{
		int mask = 0, others = 0;
		for (let i = pmo.Inv; i; i = i.Inv)
		{
			if (!(i is "Key")) continue;
			int t = KeyType(i.GetClassName());
			if (t < 0) others++; else mask |= 1 << t;
		}
		return mask, others;
	}
	// which key art: 0 the voxel pack's own keys (BD22_VoxelPack's Voxels/Keys loaded), 1 Freedoom's (shipped with us)
	transient int mKeyArt;
	transient bool mKeyArtSet;
	static int KeyArt()
	{
		let gc = Get();
		if (gc && gc.mKeyArtSet) return gc.mKeyArt;
		int a = (Wads.CheckNumForFullName("voxels/keys/rkeya.kvx") >= 0 || Wads.CheckNumForFullName("Voxels/Keys/RKEYA.kvx") >= 0) ? 0 : 1;
		if (gc) { gc.mKeyArt = a; gc.mKeyArtSet = true; }
		return a;
	}
	// THE MAP'S KEYS: which kinds (keycards, skulls) this map has, scanned when the map starts (WorldLoaded): keys lying in
	// the level, keys any monster or spawner can drop (its DropItem list), locks on lines that name a keycard (1-3) or a
	// skull (4-6); and kept up to date: a key spawned later (WorldThingSpawned: dropped, or spawned by a script), a monster
	// spawned later with a key to drop, and the keys in the player's inventory. Doom-format doors take either kind (locks
	// 129-131), so they only say "a key of that colour": with nothing else found they show the keycards.
	bool mMapCards, mMapSkulls, mMapEither, mScanned;
	int mScanThings, mScanDrops, mScanLocks;
	// a key lying in the level: a Key, or a pickup that gives one by its name (Brutal Doom places its keys with
	// GLRedCard etc., CustomInventory spawners: brutal22test6 actors/KeyPLacement.dec)
	static bool KeyLike(Actor a)
	{
		let inv = Inventory(a);
		if (!inv || inv.Owner) return false;
		if (a is "Key") return true;
		string cn = a.GetClassName();
		cn = cn.MakeLower();
		return cn.IndexOf("card") >= 0 || cn.IndexOf("skull") >= 0 || cn.IndexOf("key") >= 0;
	}
	private void NoteKey(string cn, int how)
	{
		int t = KeyType(cn);
		if (t < 0) return;
		bool was = t >= 3 ? mMapSkulls : mMapCards;
		if (t >= 3) mMapSkulls = true; else mMapCards = true;
		if (how == 0) mScanThings++; else if (how == 1) mScanDrops++;
		if (ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: key found %s (%s)", cn, how == 0 ? "in the level" : "a drop");
		if (!was && mScanned && ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: keys: %s on this map from now (%s)", t >= 3 ? "skulls" : "keycards", cn);
	}
	private void NoteDrops(Actor a)
	{
		for (let di = a.GetDropItems(); di; di = di.Next)
		{
			if (di.Name == 'None') continue;
			class<Actor> c = di.Name;
			if (!c || !(c is "Inventory")) continue;
			string cn = di.Name;
			cn = cn.MakeLower();
			if ((c is "Key") || cn.IndexOf("card") >= 0 || cn.IndexOf("skull") >= 0) NoteKey(di.Name, 1);
		}
	}
	void ScanMap()
	{
		mScanned = false;
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (a is "Inventory") { if (KeyLike(a)) NoteKey(a.GetClassName(), 0); continue; }
			if (a.bIsMonster || a is "RandomSpawner") NoteDrops(a);
		}
		for (int i = 0; i < level.lines.Size(); i++)
		{
			let l = level.lines[i];
			int lk = l.locknumber;
			int sp = l.special;
			if (!lk)
			{
				if (sp == 13) lk = l.args[3];                       // Door_LockedRaise
				else if (sp == 83 || sp == 85 || sp == 202) lk = l.args[4];   // ACS_LockedExecute(Door), Generic_Door
			}
			if (lk >= 1 && lk <= 3) { mMapCards = true; mScanLocks++; }
			else if (lk >= 4 && lk <= 6) { mMapSkulls = true; mScanLocks++; }
			else if (lk >= 129 && lk <= 134) mMapEither = true;
		}
		mScanned = true;
		if (ci("rsqgc_debug_log", 0))
			Console.Printf("rsqgc: keys on %s: keycards %d skulls %d either %d (things %d, drops %d, locks %d)", level.MapName,
				mMapCards, mMapSkulls, mMapEither, mScanThings, mScanDrops, mScanLocks);
	}
	override void WorldLoaded(WorldEvent e) { ScanMap(); }
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !mScanned) return;
		if (a is "Inventory") { if (KeyLike(a)) NoteKey(a.GetClassName(), 0); }
		else if (a.bIsMonster) NoteDrops(a);
	}
	// what the key row shows: (keycards, skulls). Only This Map's Keys off: both.
	bool, bool MapKeys(PlayerPawn pmo)
	{
		if (!ci("rsqgc_keys_map", 1)) return true, true;
		if (!mScanned) ScanMap();
		int mask, others;
		[mask, others] = HeldKeys(pmo);
		bool cards = mMapCards || (mask & 7), skulls = mMapSkulls || (mask & 56);
		if (!cards && !skulls && mMapEither) cards = true;
		return cards, skulls;
	}
	// everything the key row and the health / armour rows say, for the cards' signatures
	string StatusSig(PlayerPawn pmo)
	{
		int mask, others;
		[mask, others] = HeldKeys(pmo);
		bool c, k;
		[c, k] = MapKeys(pmo);
		return String.Format(" st%d %d k%d %d %d%d a%d g%d s%d", pmo.Health, ArmorOf(pmo), mask, others, c, k, KeyArt(), Grenades(pmo), ci("rsqgc_keys", 1));
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

	// ---- THE WATCH CARD FACES YOU OR IT IS NOT DRAWN (owner 11-11 23:56 "rogue voxels"; 11-12 04:45 "watch check with
	// lightsaber and tell me you don't see voxels firing off in a line"; his screenshot 04:56) -------------------------
	// A watch card is one voxel thick. Seen from its edge every row of it is a line of bright dashes running off across
	// the view: the other hand's card while you check this one (the saber's Force hand has an item card), a card that
	// lingers as the wrist turns away, any card with Watch Card: Always On. So a watch / status / item card is drawn only
	// while the back of that wrist is turned toward your eyes: FaceDot is the cosine between the card's face and the line
	// to your eyes (1 square on, 0 edge on, negative from behind), and under FACE_MIN the card fades out.
	// And only while you are looking its way: the wrist within GAZE_MAX of where your head points (a hand resting at
	// your side with its card half turned to you is not being read).
	const FACE_MIN = 0.50;      // 60 degrees off square
	const TWOHAND_NEAR = 16.0;  // map units between the hands (about 45 cm) under which the off hand is taken to be on the gun
	bool wchk[2];               // this hand's watch pose is held this tic (Watching), not just lingering or Always On
	static bool TwoHanding(PlayerInfo p, PlayerPawn pmo)
	{
		if (!p.ReadyWeapon) return false;
		if ((p.WeaponState & WF_TWOHANDSTABILIZED) != 0) return true;
		if (!pmo.OverrideAttackPosDir) return false;
		Vector3 d = pmo.AttackPos - pmo.OffhandPos;
		d.z *= level.pixelstretch;
		return d.Length() < TWOHAND_NEAR;
	}
	const GAZE_MAX = 45.0;
	static double GazeOff(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir || !pmo.player) return 0;
		Vector3 to = ((hand == 1) ? pmo.OffhandPos : pmo.AttackPos) - (pmo.pos.xy, pmo.player.viewz);
		to.z *= level.pixelstretch;
		double d = to.Length();
		if (d < 0.01) return 0;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		return acos(clamp((to / d) dot look, -1.0, 1.0));
	}
	static double FaceDot(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir || !pmo.player) return 1.0;
		double y = ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
		double p = (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		Vector3 f = (cos(p) * cos(y), cos(p) * sin(y), sin(p));
		Vector3 r0 = (sin(y), -cos(y), 0);
		Vector3 u0 = r0 cross f;
		// the twist, with the sign Watching reads it by (the physical left controller reports it mirrored)
		let cs = CVar.FindCVar("vr_control_scheme");
		bool left = (hand == 0) == (cs && cs.GetInt() >= 10);
		double rl = Actor.Normalize180(hand == 1 ? pmo.OffhandRoll : pmo.AttackRoll);
		double b = left ? rl : -rl;
		Vector3 n = r0 * cos(b) + u0 * sin(b);
		Vector3 to = (pmo.pos.xy, pmo.player.viewz) - ((hand == 1) ? pmo.OffhandPos : pmo.AttackPos);
		to.z *= level.pixelstretch;
		double d = to.Length();
		return d > 0.01 ? (n dot to) / d : 1.0;
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
	// rsqgc_card: 0 off, 1 always, 2 when you look at the gun, 3 the inspect gesture (RSQ Accessibility's reader; without
	// it Gun Cards' own copy, gestcopy.zs; as 2 only when that reader's watch check is switched off),
	// 4 on reload
	private bool Wanted(PlayerPawn pmo, int hand)
	{
		int mode = ci("rsqgc_card", 1);
		if (mode <= 0) return false;
		if (mode == 1) return true;
		if (mode == 4)
		{
			// ON RELOAD (owner's pick 41): while that hand's reload is held, and rsqgc_linger tics after. QZD 17.3 has a
			// reload per hand (BT_MAINHANDRELOAD 1<<20, BT_OFFHANDRELOAD 1<<28) and the shared one (BT_RELOAD), which
			// reloads both hands (p_pspr.cpp:103-115); teardown 00_CAPABILITIES 1.5.
			int bits = BT_RELOAD | (hand == 1 ? BT_OFFHANDRELOAD : BT_MAINHANDRELOAD);
			if (pmo.player.cmd.buttons & bits) mReloadTill[hand] = level.maptime + ci("rsqgc_linger", 35);
			return level.maptime < mReloadTill[hand];
		}
		if (mode == 3)
		{
			int g = Inspect(pmo, hand);
			if (g < 0) g = OwnInspect(pmo, hand);   // owner 11-05 "change": every mod works alone, as Watching does
			if (g >= 0)
			{
				if (g >= ci("rsqgc_inspect_level", 2)) mInspectTill[hand] = level.maptime + ci("rsqgc_linger", 35);
				return level.maptime < mInspectTill[hand];
			}
		}
		return Glance(pmo, hand);
	}

	// RSQ Accessibility's watch-check answer for this hand (RSQG_Service, the name it kept from RSQ Gestures), -1 when it
	// is not loaded or its Watch Check is off
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
		if (d < 4 || d > cv("rsqgc_glance_reach", 0.7) * cv("vr_vunits_per_meter", 34)) return false;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		return (to / d) dot look >= cos(cv("rsqgc_glance_cone", 30));
	}

	// Gun Cards' own copy of that inspect reader (gestcopy.zs), asked only while RSQ Accessibility is absent: the same pose
	// rules and numbers, the same answer (0 not, 1 entering, 2 held); -1 when Accessibility is loaded or the copy is missing
	static int OwnInspect(PlayerPawn pmo, int hand)
	{
		let h = RSQGC_GCopy.Get();
		return h ? h.Inspect(pmo.PlayerNumber(), hand) : -1;
	}

	// CHECKING YOUR WATCH with this hand: RSQ Accessibility's inspect (the back of the wrist turned to the face; RSQ Gestures
	// until it was folded into Accessibility, 11-05). With Accessibility loaded it is asked; without it Gun Cards reads the
	// same pose itself (owner 2026-11-04 19:45: the watch card is Gun Cards' standout and must not need another mod). The
	// looser pose below (the forearm across the chest, the wrist 15-50 cm before the eyes) was the fallback without the
	// reader until then; now it runs only with Accessibility loaded and its watch check switched off (its "inspect" -1).
	private bool Watching(PlayerPawn pmo, int hand)
	{
		int g = Inspect(pmo, hand);
		if (g < 0) g = OwnInspect(pmo, hand);
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
		// THE BACK OF THE WRIST to the face, not the pulse (2026-11-02; before, any twist counted): the gun's top turned
		// in toward the body at least 45 degrees, AttackRoll <= -45 on the physical right controller. The engine reports
		// the mirrored twist with the opposite sign on the left one (the reader's InspectPose, rig: right -90 / left +90
		// for the back of the hand up), so it is flipped there.
		let cs = CVar.FindCVar("vr_control_scheme");
		bool left = (hand == 0) == (cs && cs.GetInt() >= 10);
		double rl = Actor.Normalize180(hand == 1 ? pmo.OffhandRoll : pmo.AttackRoll);
		bool back = (left ? rl : -rl) >= 45;
		if (across && back) mInspectTill[hand] = level.maptime + ci("rsqgc_linger", 35);
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
		if (pick == COLOR_AMMO) { int c = AmmoColour(w); if (c >= 0) return c; }
		if (pick > 0 && pick < RSQGC_GunCard.PICK_COL.Size()) return RSQGC_GunCard.PICK_COL[pick];
		return RSQGC_GunCard.STYLE_COL[clamp(StyleFor(p, w), 0, 17)];
	}

	// GC6 BY AMMO TYPE (rsqgc_color 11): the colour of what the gun eats, by its ammo pile's name (and the Doom pile it
	// counts as): bullets gold, shells red, rockets and grenades orange, cells and plasma cyan, fuel green, souls
	// purple; any other pile a fixed colour of its own from the simple list (by its name). -1: a gun with no ammo.
	const COLOR_AMMO = 11;
	static int AmmoColour(Weapon w)
	{
		if (!w || !w.Ammo1) return -1;
		let a = w.Ammo1;
		string n = a.GetClassName();
		class<Ammo> par = a.GetParentAmmo();
		if (par) n = n .. " " .. par.GetClassName();
		n = n.MakeLower();
		if (n.IndexOf("shell") >= 0) return 0xE04040;
		if (n.IndexOf("rocket") >= 0 || n.IndexOf("grenade") >= 0 || n.IndexOf("glammo") >= 0 || n.IndexOf("missile") >= 0 || n.IndexOf("nuke") >= 0 || n.IndexOf("mortar") >= 0) return 0xF08030;
		if (n.IndexOf("cell") >= 0 || n.IndexOf("plasma") >= 0 || n.IndexOf("rail") >= 0 || n.IndexOf("laser") >= 0) return 0x50D0D0;
		if (n.IndexOf("gas") >= 0 || n.IndexOf("fuel") >= 0 || n.IndexOf("flame") >= 0) return 0x50D050;
		if (n.IndexOf("soul") >= 0 || n.IndexOf("hell") >= 0) return 0xB060E0;
		if (n.IndexOf("clip") >= 0 || n.IndexOf("pistol") >= 0 || n.IndexOf("smg") >= 0 || n.IndexOf("mp40") >= 0 || n.IndexOf("mauser") >= 0
			|| n.IndexOf("sniper") >= 0 || n.IndexOf("bullet") >= 0 || n.IndexOf("rifle") >= 0 || n.IndexOf("machinegun") >= 0 || n.IndexOf("9mm") >= 0) return 0xE0B040;
		int h = 0;
		for (int i = 0; i < int(n.Length()); i++) h = (h * 31 + n.ByteAt(i)) & 0xFFFF;
		return RSQGC_GunCard.PICK_COL[1 + h % 10];
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
		// the watch check as the cards read it: RSQ Accessibility's answer, else Gun Cards' own reader's (marked "own")
		int i0 = Inspect(pmo, 0), i1 = Inspect(pmo, 1);
		bool own = false;
		if (i0 < 0 && i1 < 0)
		{
			int o0 = OwnInspect(pmo, 0), o1 = OwnInspect(pmo, 1);
			if (o0 >= 0 || o1 >= 0) { i0 = o0; i1 = o1; own = true; }
		}
		s = s .. String.Format("guns  %s / %s  inspect %d %d%s", p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none', p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none', i0, i1, own ? " own" : "");
		Console.MidPrint(null, s, true);
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = PlayerPawn(p.mo);
		if (!pmo) return;
		if (ci("rsqgc_show_hands", 0)) ShowHands(pmo);
		int watchMode = ci("rsqgc_watch", 1);     // 0 off, 1 when you check your watch, 2 always (owner 2026-10-31)
		bool watchOn = watchMode > 0;
		bool always = watchMode == 2;
		if (p.playerstate != PST_LIVE || (ci("rsqgc_card", 1) <= 0 && !watchOn)) { ClearAll(p); GlowLights(pmo); return; }

		let item = RSQGC_CardItem(pmo.FindInventory("RSQGC_CardItem"));
		if (!item) item = RSQGC_CardItem(pmo.GiveInventoryType("RSQGC_CardItem"));
		if (!item) return;

		// see-through: rsqgc_look 0 solid, 1 glass, 2 glow
		int look = ci("rsqgc_look", 1);
		item.mStyle = look == 2 ? STYLE_Add : (look == 1 || look == 3) ? STYLE_Translucent : 0;   // 3: No Background, the text as glass
		if (look > 0 && !p.FindPSprite(L_FX)) p.SetPSprite(L_FX, item.FindState("Fx"), false, item);
		if (item.mStyle != item.mStyleSet)
		{
			// the look changed: every live layer gets it again
			item.mStyleSet = item.mStyle;
			for (int id = L_FIRST; id <= L_LAST; id++) if (p.FindPSprite(id)) item.mPending.Push(id);
			for (int id = RSQGC_SideCard.BASE0; id < RSQGC_SideCard.BASE0 + 2 * RSQGC_SideCard.PER_HAND; id++) if (p.FindPSprite(id)) item.mPending.Push(id);
		}

		// WHICH CARD. Checking your watch with a gun shows that gun's watch card (rsqgc_watch); otherwise the small
		// card shows when rsqgc_card says.
		Track(p);
		bool both = ci("rsqgc_hands", 0) == 1;
		bool watching[2], status[2];
		for (int hand = 0; hand < 2; hand++)
		{
			bool checking = watchOn && Watching(pmo, hand);
			// THE SUPPORT HAND IS NOT A WATCH CHECK (owner 11-12 14:11: "I'm still seeing voxels parallel to the laser when
			// holding ballistic weapons, gun posed in a 'freeze, police!' pose"): two-handing a gun puts the off hand across
			// the body with the back of its wrist up, which IS the watch pose, so its card came up edge on beside the gun.
			// While the engine steadies the gun with the off hand (WF_TWOHANDSTABILIZED), or the off hand is within
			// TWOHAND_NEAR of the hand holding a gun, the off hand's check does not count.
			if (checking && hand == 1 && TwoHanding(p, pmo)) checking = false;
			wchk[hand] = checking;
			watching[hand] = always || checking;
			// GC5: checking your watch with an EMPTY hand shows health, armour and keys (the status card). Drawn with
			// the hand, the off hand needs its own weapon slot filled to own the layers (Brutal Doom VR's off-hand
			// fist, RSQ_Hands, is that); Draw in the World (owner 2026-11-04: "must also show") needs no layers.
			// With Watch Card: Always On (owner 11-06: "an option to always draw wrist cards") it shows always.
			status[hand] = watching[hand] && EmptyHand(p, hand) && (hand == 0 || p.OffhandWeapon || ci("rsqgc_world", 0));
		}
		// EVERY WEAPON (owner 11-06, BUGS_1.0 #24: "guncards need to show on every weapon, at least the wrist card when toggled
		// on"; 11-10: "a card for every weapon in the RSQ series"): a weapon with no ammo pile (RSQ Saber, Whip, ShieldSaw,
		// Melee's gloves, the flare, any pack's melee weapon) has its item card on the wrist (items.zs), its name and what it
		// holds over the status rows
		bool show[2], itemCard[2];
		Weapon gun[2], other[2], itm[2];
		for (int hand = 0; hand < 2; hand++)
		{
			Weapon w = hand == 1 ? p.OffhandWeapon : p.ReadyWeapon;
			itm[hand] = (!EmptyHand(p, hand) && RSQGC_Items.IsItem(w)) ? w : null;
			itemCard[hand] = watching[hand] && itm[hand] != null;
			if (w && Loaded(w) < 0) w = null;
			gun[hand] = w;
			other[hand] = null;
			// GC1 (Option): the small card hides while the gun is up at your eye
			bool eyeHide = ci("rsqgc_hide_eye", 0) && AtEye(pmo, hand);
			show[hand] = status[hand] || itemCard[hand] || (watching[hand] ? w != null : (w && !eyeHide && Wanted(pmo, hand)));
			// (edge on or from behind, a watch card is a line of dashes: not drawn, FaceDot)
			if (show[hand] && (watching[hand] || status[hand] || itemCard[hand]) && !ci("rsqgc_world", 0))
			{
				double fd = FaceDot(pmo, hand), go = GazeOff(pmo, hand);
				// (11-12 14:11, "the watch card does not show up anymore": a real check tilts the wrist only 45-80 degrees, which
				// measures under FACE_MIN, so the test hid every checked card. A card whose own hand is being checked now, by
				// Watching's pose, is always drawn; the face and gaze test is for the rest: Always On, a lingering card.)
				bool cull = !wchk[hand] && (fd < FACE_MIN || go > GAZE_MAX);
				if (ci("rsqgc_debug_log", 0) && (level.maptime % 10) == 0) Console.Printf("rsqgc: hand %d watch card face %.2f, %.0f degrees off your gaze%s", hand, fd, go, cull ? " (not drawn)" : "");
				if (cull) show[hand] = false;
			}
			// a cooking grenade's count shows whatever Show Cards says, unless it says Off
			if (!show[hand] && w && ci("rsqgc_card", 1) > 0 && FuseCount(p, hand) >= 0) show[hand] = true;
			// THE LEVEL CARD IN ITS PLACE (owner 11-12; Level-Up Card Replaces Small Card, rsqgc_lvlcard): the small card fades
			// out while RSQ VisualRewards' weapon level card shows at this hand, and fades back in after. A watch check, the
			// status card and a cooking grenade's count still show.
			if (show[hand] && level.maptime < mLvHide[hand] && !watching[hand] && !status[hand] && !itemCard[hand] && FuseCount(p, hand) < 0) show[hand] = false;
		}
		// both guns on the main-hand small card (rsqgc_hands): the off hand's stands down. A host hand with nothing
		// to count carries the other gun alone. A hand you are checking shows its watch card instead.
		for (int hand = 0; hand < 2; hand++)
		{
			if (!both || watching[hand] || status[hand]) continue;
			if (hand == 1 && !watching[1] && !watching[0] && gun[0] != null) { show[1] = false; continue; }
			other[hand] = gun[1 - hand];
			if (!gun[hand]) { gun[hand] = other[hand]; other[hand] = null; show[hand] = gun[hand] != null && (watching[hand] || Wanted(pmo, 0) || Wanted(pmo, 1)); }
		}
		for (int hand = 0; hand < 2; hand++)
		{
			double step = 1.0 / max(1, ci("rsqgc_fade", 4));
			mShow[hand] = clamp(mShow[hand] + (show[hand] ? step : -step), 0.0, 1.0);
			// FADING OUT, a card stays the card it was (fixed 2026-10-31: when a watch check ended, the watch card
			// vanished at once and the small card flashed in for the fade's tics, even with Show Cards off)
			if (show[hand]) { mWasWatch[hand] = watching[hand] || status[hand]; mWasStatus[hand] = status[hand]; }
			bool full = watching[hand] || status[hand] || (!show[hand] && mWasWatch[hand]);
			bool stat = status[hand] || (!show[hand] && mWasStatus[hand]);
			Weapon w = gun[hand];
			Weapon fw = w ? w : itm[hand];      // the watch card's weapon: a gun, or an item with nothing to count
			Actor owner = hand == 1 ? Actor(p.OffhandWeapon) : Actor(item);
			// GC5 in the world: the status card on the back of the wrist, where the watch card goes; an item's watch card
			// there too (Draw in the World is left as it is, owner 11-10: "drawn in the world doesn't need to do anything
			// right now")
			if (mShow[hand] > 0 && ci("rsqgc_world", 0) && (stat || (full && itm[hand])))
			{
				WorldStatus(p, pmo, hand);
				continue;
			}
			if (stat && mShow[hand] > 0 && owner && !ci("rsqgc_world", 0))
			{
				// GC5: the status card, flat on the wrist like the watch card
				World(hand).Hide(); ClearHand(p, hand);
				DrawStatus(p, pmo, hand, owner);
				continue;
			}
			if (mShow[hand] <= 0 || !(full ? fw : w) || !owner) { World(hand).Hide(); ClearHand(p, hand); Side(hand).Remove(p); continue; }
			if (ci("rsqgc_world", 0))
			{
				// in the world: no layers on the gun at all
				ClearHand(p, hand); Side(hand).Remove(p);
				let wc = World(hand);
				bool wantFull = full;
				// Watch Card Shows in the world too (fixed 2026-11-10: the world watch card was always the Weapon card)
				int shows = wantFull ? ci("rsqgc_watch_shows", 0) : 0;
				if (shows == 1) { WorldStatus(p, pmo, hand); continue; }
				if (!wc.Shown() || wc.full != wantFull || wc.status) wc.Show(pmo.pos, wantFull);
				// Both Guns on One Card: the other gun's rounds in the small number, as on the hand-drawn card (fixed
				// 2026-11-10: in the world they showed nowhere)
				wc.Fill(pmo, w, CardColour(p, w), self, other[hand], shows);
				double sSide, sUp, sIn;
				[sSide, sUp, sIn] = RSQGC_Spots.SpotFor(w.GetClassName());   // this gun's spot (spots.zs)
				wc.Place(pmo, cv("rsqgc_world_scale", 1.4), wantFull ? WatchNudge(true) : sUp, wantFull ? WatchNudge(false) : sSide, mShow[hand] * CardAlpha(hand), wantFull ? 0 : sIn);
				continue;
			}
			World(hand).Hide();
			if (full)
			{
				// the watch card: the full card flat on the back-of-the-hand side of the wrist (side.zs). Always on: the small card
				// still shows as rsqgc_card says, beside it
				// Watch Card Shows (owner 2026-11-03): 0 the Weapon card, 1 the Status card, 2 both on one card; an item has
				// its item card for 0 and 2 (items.zs)
				int shows = ci("rsqgc_watch_shows", 0);
				if (shows == 1) DrawStatus(p, pmo, hand, owner);
				else DrawSide(p, pmo, hand, owner, fw, shows);
				if (always && w && Wanted(pmo, hand)) Draw(p, pmo, hand, owner, w, other[hand], other[hand] != null);
				else ClearHand(p, hand);
				continue;
			}
			Side(hand).Remove(p);
			Draw(p, pmo, hand, owner, w, other[hand], other[hand] != null);
		}
		// CARD GLOW: PCVR's small light at each hand whose card shows (glow.zs)
		for (int hand = 0; hand < 2; hand++)
		{
			Weapon w = gun[hand];
			mLightCol[hand] = (status[hand] || mWasStatus[hand] || !w) ? 0x8A8A8A : CardColour(p, w);
		}
		GlowLights(pmo);
	}
	int mLightCol[2];

	// ---- the cards in the world -----------------------------------------------------------------------------
	RSQGC_WorldCard mWorld[2];
	RSQGC_WorldCard World(int hand)
	{
		if (!mWorld[hand]) { mWorld[hand] = new("RSQGC_WorldCard"); mWorld[hand].hand = hand; }
		return mWorld[hand];
	}
	override void WorldUnloaded(WorldEvent e) { for (int h = 0; h < 2; h++) if (mWorld[h]) mWorld[h].live = false; }
	// the status card in the world, on the back of the wrist where the watch card goes (an empty or melee hand, or Watch
	// Card Shows: Status Card)
	private void WorldStatus(PlayerInfo p, PlayerPawn pmo, int hand)
	{
		ClearHand(p, hand); Side(hand).Remove(p);
		let wc = World(hand);
		if (!wc.Shown() || !wc.full || !wc.status) { wc.Show(pmo.pos, true); wc.status = true; }
		wc.FillStatus(pmo, 0x8A8A8A, self);
		wc.Place(pmo, cv("rsqgc_world_scale", 1.4), WatchNudge(true), WatchNudge(false), mShow[hand] * CardAlpha(hand), 0);
	}

	// ---- the watch card ---------------------------------------------------------------------------------------
	transient RSQGC_SideCard mSide[2];
	RSQGC_SideCard Side(int hand)
	{
		if (!mSide[hand]) { mSide[hand] = new("RSQGC_SideCard"); mSide[hand].hand = hand; }
		return mSide[hand];
	}
	private void DrawSide(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w, int shows)
	{
		// one card, on the back-of-the-hand side (the palm side faces away in a watch check, 2026-11-02)
		let c = Side(hand);
		bool mir = Mirrored(p, hand);
		int rot = SideRot(pmo, hand);
		int style = StyleFor(p, w);
		int q = Quality();
		bool isItem = RSQGC_Items.IsItem(w);
		string sig = Signature(pmo, w, 9, style) .. (mir ? " m" : "") .. String.Format(" c%d q%d v%d b%d w%d %.2f", ci("rsqgc_color", 0), q, shows, ci("rsqgc_watch_bonsai", 0), ci("rsqgc_lowwarn", 1), cv("rsqgc_lowammo_frac", 0.25))
			.. ExtraSig(pmo, hand, w) .. (shows == 2 || isItem ? StatusSig(pmo) : "") .. (isItem ? RSQGC_Items.Sig(w) .. String.Format(" s%d", ci("vr_control_scheme", 0)) : "") .. RSQGC_Glow.Sig();
		if (sig != c.sig || c.mir != mir || c.rot != rot)
		{
			c.sig = sig; c.mir = mir; c.rot = rot; c.quality = q;
			// the item card's words go in the half of the card nearer the elbow (side.zs BuildItem): which half, from
			// which wrist this is physically (as Mirrored)
			bool physLeft = hand == 1 ? ci("vr_control_scheme", 0) < 10 : ci("vr_control_scheme", 0) >= 10;
			if (isItem) c.BuildItem(pmo, w, CardColour(p, w), self, physLeft);
			else c.Build(pmo, hand, w, CardColour(p, w), self, shows);
		}
		c.Sync(p, owner, mShow[hand] * CardAlpha(hand), WatchNudge(true), self);
	}

	// WHICH WAY UP (2026-11-02, owner in the headset: "I look at the back of my wrist, not my pulse ... the card is upside
	// down"). The watch card lies in the plane of the gun's side, its text along the gun; tools/gen_side.py bakes it twice:
	// rot 0 reads upright when the gun's top points DOWN the screen (rig: the right hand across the chest, back of the
	// wrist up, seen from the eyes above it; the same for the mirrored left hand), rot 1 is turned half round for when the
	// top points UP the screen. So the turn comes from the pose: the gun's top (the hand's up axis, GetHandTransform's yaw,
	// pitch, then roll, as TiltTo builds it) against the screen's up where the card is seen (world up with its part along
	// the line of sight taken out; the head is not rolled). A margin keeps it from flickering when the top lies across
	// the view (the forearm pointing away from you: the text then runs away from you either way).
	int mRot[2];
	int SideRot(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir || !pmo.player) return mRot[hand];
		double hYaw = hand == 1 ? pmo.OffhandAngle : pmo.AttackAngle;
		double hPitch = hand == 1 ? pmo.OffhandPitch : pmo.AttackPitch;
		double rl = hand == 1 ? pmo.OffhandRoll : pmo.AttackRoll;
		Vector3 rt0 = (cos(hYaw), sin(hYaw), 0);
		Vector3 up0 = (sin(hPitch) * sin(hYaw), -sin(hPitch) * cos(hYaw), cos(hPitch));
		Vector3 up = rt0 * sin(rl) + up0 * cos(rl);
		Vector3 hp = hand == 1 ? pmo.OffhandPos : pmo.AttackPos;
		Vector3 v = hp - (pmo.pos.xy, pmo.player.viewz);
		v.z *= level.pixelstretch;
		double d = v.Length();
		if (d < 1) return mRot[hand];
		v /= d;
		Vector3 sUp = (0, 0, 1) - v * v.z;
		double l = sUp.Length();
		if (l < 0.05) return mRot[hand];   // looking straight down the line: keep what it was
		double k = (up dot sUp) / l;
		if (k > 0.15) mRot[hand] = 1;
		else if (k < -0.15) mRot[hand] = 0;
		if (ci("rsqgc_show_hands", 0) && level.maptime % 35 == 0)
			Console.Printf("rsqgc: watch card hand %d: top on screen %.2f -> turn %d", hand, k, mRot[hand]);
		return mRot[hand];
	}

	// ---- the status card (GC5) ----------------------------------------------------------------------------------
	private void DrawStatus(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner)
	{
		bool mir = Mirrored(p, hand);
		int rot = SideRot(pmo, hand);
		int q = Quality();
		string sig = "status" .. StatusSig(pmo) .. String.Format(" q%d", q) .. (mir ? " m" : "") .. RSQGC_Glow.Sig();
		let c = Side(hand);
		if (sig != c.sig || c.mir != mir || c.rot != rot)
		{
			c.sig = sig; c.mir = mir; c.rot = rot; c.quality = q;
			c.BuildStatus(pmo, hand, 0x8A8A8A, self);
		}
		c.Sync(p, owner, mShow[hand] * CardAlpha(hand), WatchNudge(true), self);
	}

	// ---- the small card ---------------------------------------------------------------------------------------
	private void Draw(PlayerInfo p, PlayerPawn pmo, int hand, Actor owner, Weapon w, Weapon other, bool both)
	{
		bool mir = Mirrored(p, hand);
		int base = L_FIRST + hand * PER_HAND;
		double alpha = mShow[hand] * CardAlpha(hand);

		int loaded = Loaded(w);
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
		// JFO (2026-11-03): the digits and the word are drawn white / light grey unless the Wheel palette tints them; the
		// magazine's count green / yellow / red (MagColour, under Low Ammo Colour)
		// SMALL CARD FONT (owner 07:58, rsqgc_small_font): 0 JFO, 1 Ermac's lettering and digits in their own colours
		bool ermac = ci("rsqgc_small_font", 0) == 1;
		if (tDigits < 0 && !ermac) tDigits = TransFor(0xF0F0F0);
		int tLabel = tPanel >= 0 || ermac ? tPanel : TransFor(0xC8C8C8);
		int mc = MagColour(w, loaded);
		int tLow = mc >= 0 ? TransFor(mc) : -1;
		int q = Quality();
		// COOK SENSE 3: the cooking grenade's seconds left take the big number, amber then red
		int fc = FuseCount(p, hand);
		if (fc >= 0)
		{
			loaded = fc;
			tLow = TransFor(FuseAmber(p) ? 0xFFB428 : 0xFF3020);
			if (ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: fuse count %d (%s)", fc, FuseAmber(p) ? "amber" : "red");
		}
		// THIS GUN'S SPOT (owner 11-06, spots.zs): its saved Up / Side / In, else the Placement sliders
		double spS, spU, spI;
		[spS, spU, spI] = RSQGC_Spots.SpotFor(w.GetClassName());
		mSpotSide[hand] = spS; mSpotUp[hand] = spU; mSpotIn[hand] = spI;
		TiltTo(pmo, hand, mir);
		mCurTilt = hand;

		// the panel
		int style = StyleFor(p, w);
		// with the AMMO / MAGAZINE word off the panel is the short one (owner 08:40): no empty strip, the numbers stay put
		// NO BACKGROUND (Material: No Background, owner 11-06): the panel is left out, only the words and numbers show
		if (RSQGC_Glow.NoPanel()) Kill(p, base + P_PANEL);
		else Put(p, base + P_PANEL, Nth(RSQGC_Glow.CPiece(ci("rsqgc_label", 1) ? 0 : 7, mir, 0, Depth()), style), owner, alpha, tPanel);
		// the word: MAGAZINE on a gun with one, AMMO otherwise
		int lab = HasMagazine(w) ? 1 : 0;
		if (ci("rsqgc_label", 1)) Put(p, base + P_LABEL, Nth(RSQGC_Glow.CPiece(1, mir, 0, Depth()), ermac ? RSQGC_CardStates.ERMAC_LABEL + lab : q * RSQGC_CardStates.LABELS + lab), owner, alpha, tLabel);
		else Kill(p, base + P_LABEL);
		// the big number, centred in the five slots (Digits); GC3: RELOAD in its place on an empty magazine with rounds to
		// load (Ermac's lettering, tools/gen_cards.py), in the empty colour
		// RELOAD AND 0 IN TURN (owner 2026-11-03 09:42): an empty magazine with rounds to load shows RELOAD, then a red "0"
		// (centred like any count), switching every RELOAD_FLIP tics from the tic it emptied; empty with nothing to load
		// shows the count as before
		bool reloadNow = HasMagazine(w) && loaded == 0 && Reserve(w) > 0 && fc < 0;
		if (!reloadNow) mEmptySince[hand] = 0;
		else if (mEmptySince[hand] <= 0) mEmptySince[hand] = level.maptime + 1;
		int flip = reloadNow ? ((level.maptime + 1 - mEmptySince[hand]) / RELOAD_FLIP) % 2 : 0;
		if (reloadNow && flip + 1 != mFlipWas[hand] && ci("rsqgc_debug_log", 0))
			Console.Printf("rsqgc: hand %d empty magazine: %s at tic %d (emptied at %d)", hand, flip ? "0" : "RELOAD", level.maptime, mEmptySince[hand] - 1);
		mFlipWas[hand] = reloadNow ? flip + 1 : 0;
		if (reloadNow && flip == 0)
		{
			for (int k = 1; k < RSQGC_CardStates.SLOTS; k++) Kill(p, base + P_BIG + k);
			// on the short card (word off) its own RELOAD, top on the big count's top, so RELOAD and the reserve sit
			// centred as the count and the reserve do (gen_cards.py RELOAD_SHORT_AT, owner 11-05 03:26)
			Put(p, base + P_BIG, Nth(RSQGC_Glow.CPiece(ci("rsqgc_label", 1) ? 4 : 8, mir, 0, Depth()), ermac ? RSQGC_CardStates.ERMAC_RELOAD : q), owner, alpha, TransFor(MAG_RED));
		}
		else if (reloadNow) Digits(p, 2, mir, base + P_BIG, owner, "0", false, alpha, TransFor(MAG_RED));
		else Digits(p, 2, mir, base + P_BIG, owner, clamp(loaded, 0, 999).."", false, alpha, tLow >= 0 ? tLow : tDigits);
		// the small number: the reserve (or the other gun's rounds on a both-guns card); GC2: "+N" for a moment after
		// ammo for this gun is picked up
		int plus = both ? 0 : PlusNow(hand);
		if (plus > 0) Digits(p, 3, mir, base + P_SMALL, owner, "+" .. clamp(plus, 1, 99), true, alpha, tDigits);
		// THE RESERVE IN GOLD (owner 2026-11-03 08:31), both fonts; the Wheel palette (Small Card Colours) keeps its own
		else if (reserve >= 0) Digits(p, 3, mir, base + P_SMALL, owner, clamp(reserve, 0, 999).."", true, alpha, tinted ? tDigits : TransFor(RESERVE_GOLD));
		else for (int k = 0; k < RSQGC_CardStates.SLOTS; k++) Kill(p, base + P_SMALL + k);
	}

	private void Digits(PlayerInfo p, int kind, bool mir, int base, Actor owner, string s, bool small, double alpha, int trans)
	{
		int slots = RSQGC_CardStates.SLOTS;
		int len = min(s.Length(), (slots + 1) / 2);
		int first = (slots - 1) / 2 - (len - 1);   // CENTRED (owner 08:20): the slots are half a digit apart
		for (int k = 0; k < slots; k++)
		{
			// slot 0 is the leftmost; digit i of the number stands in slot first + 2 i
			int ci0 = (k - first) % 2 == 0 && k >= first ? (k - first) / 2 : -1;
			if (ci0 < 0 || ci0 >= len) { Kill(p, base + k); continue; }
			int ch = s.ByteAt(ci0);
			int g = ch == 43 ? RSQGC_CardStates.GLYPH_PLUS : ch - 48;   // '+' (GC2)
			// JFO: kind 2 / 3, frame Text Quality * GLYPHS + glyph; Ermac (Small Card Font): kind 5 / 6, frame glyph
			if (ci("rsqgc_small_font", 0) == 1) Put(p, base + k, Nth(RSQGC_Glow.CPiece(kind + 3, mir, k, Depth()), g), owner, alpha, trans);
			else Put(p, base + k, Nth(RSQGC_Glow.CPiece(kind, mir, k, Depth()), Quality() * RSQGC_CardStates.GLYPHS + g), owner, alpha, trans);
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
		ps.x = mSpotSide[mCurTilt] * 4 + mTiltX[mCurTilt];        // degrees about the model origin (this gun's spot, spots.zs)
		ps.y = 32 + mSpotUp[mCurTilt] * 4 + mTiltY[mCurTilt];
		ps.alpha = alpha;
		ps.Translation = trans >= 0 ? TranslationID(trans) : TranslationID(0);
	}

	// ---- TILT TO YOUR EYES (owner's pick 43, rsqgc_tilt) --------------------------------------------------
	// The small card faces back along the forearm, so at many wrist angles it is seen edge-on. A layer's only per-tic
	// freedom is two turns of its model about the model origin, psp.x (yaw about the hand's up, x/4 degrees) and
	// psp.y (pitch about the hand's right, (y-32)/-4 degrees): hw_weapon.cpp:108, models.cpp:259-260; teardown
	// 11_HUD_MODELS 5.3. Turning the card about that origin also carries it round it (the origin is 30 cm back and
	// 5 cm up from the controller, models.cpp:227, so the card swings a few cm), hence the cap, rsqgc_tilt_max.
	// The hand frame is the engine's (hw_openxrdevice.cpp GetHandTransform:440-458): x right, y up, -z the gun's
	// facing, in true proportions (z times pixelstretch); the physical left hand is drawn mirrored in x
	// (hw_vrmodes.cpp:468), which turns a yaw round. Card centre (tools/gen_cards.py CARD, model cm about the
	// origin): 6.6 right, 11.3 down, 16.9 forward, moved back by rsqgc_in.
	int mCurTilt;
	double mSpotSide[2], mSpotUp[2], mSpotIn[2];   // the small card's spot this tic per hand (spots.zs)
	void TiltTo(PlayerPawn pmo, int hand, bool mir)
	{
		mTiltX[hand] = 0; mTiltY[hand] = 0;
		if (!ci("rsqgc_tilt", 0) || !pmo.OverrideAttackPosDir || !pmo.player) return;
		double ps = level.pixelstretch;
		double hYaw = hand == 1 ? pmo.OffhandAngle : pmo.AttackAngle;
		double hPitch = hand == 1 ? pmo.OffhandPitch : pmo.AttackPitch;
		double rl = hand == 1 ? pmo.OffhandRoll : pmo.AttackRoll;
		Vector3 hp = hand == 1 ? pmo.OffhandPos : pmo.AttackPos;
		// the hand's axes (world, true proportions): GetHandTransform's yaw hYaw, pitch hPitch, then roll -rl about the facing
		Vector3 rt0 = (cos(hYaw), sin(hYaw), 0);
		Vector3 up0 = (sin(hPitch) * sin(hYaw), -sin(hPitch) * cos(hYaw), cos(hPitch));
		Vector3 rt = rt0 * cos(rl) - up0 * sin(rl);
		Vector3 up = rt0 * sin(rl) + up0 * cos(rl);
		Vector3 bk = -(cos(hPitch) * cos(hYaw + 90), cos(hPitch) * sin(hYaw + 90), sin(hPitch));     // toward the player along the hand
		double cm = cv("vr_vunits_per_meter", 34) / 100.0;
		double sx = mir ? -1 : 1;                                                // where the card sits: right of a main hand
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 ox = (0, 5, 30);                                                 // the model origin, hand-local cm
		Vector3 c0 = (6.6 * sx, -11.3, -16.9 + mSpotIn[hand]);                   // the card about it (this gun's In)
		double lim = clamp(cv("rsqgc_tilt_max", 20), 0, 60);
		double a = 0, b = 0;
		for (int it = 0; it < 3; it++)
		{
			// the card's centre with this turn (Ry(a) Rx(b), as the engine applies them), in the world
			double y1 = c0.y * cos(b) - c0.z * sin(b), z1 = c0.y * sin(b) + c0.z * cos(b);
			double x2 = c0.x * cos(a) + z1 * sin(a), z2 = -c0.x * sin(a) + z1 * cos(a);
			Vector3 loc = ox + (x2, y1, z2);
			Vector3 at = hp + (rt * loc.x + up * loc.y + bk * loc.z) * cm;     // true proportions about the hand
			Vector3 to = eye - hp;
			to.z *= ps;
			to -= (at - hp);
			double d = to.Length();
			if (d < 1) return;
			to /= d;
			double ex = to dot rt, ey = to dot up, ez = to dot bk;
			// the card's face (local +z) turned by Ry(a) Rx(b) is (cos b sin a, -sin b, cos b cos a)
			b = clamp(-asin(clamp(ey, -1, 1)), -lim, lim);
			a = clamp(atan2(ex, ez), -lim, lim);
		}
		mTiltX[hand] = (mir ? -a : a) * 4;   // a mirrored hand turns the other way
		mTiltY[hand] = -b * 4;
	}

	// a layer just made: the helper gives it the card's look next tic
	void Fresh(int id)
	{
		let p = players[consoleplayer];
		let item = p.mo ? RSQGC_CardItem(p.mo.FindInventory("RSQGC_CardItem")) : null;
		if (item) item.mPending.Push(id);
	}
	// the watch card's sliders: degrees about the hand (drawn with it), cm (drawn in the world)
	double WatchNudge(bool up) { return cv(up ? "rsqgc_watch_up" : "rsqgc_watch_side", 0); }
	// IN AND OUT (owner 2026-10-31): rsqgc_in cm along the forearm, + toward you; the card is baked at
	// RSQGC_CardStates.DEPTHS places DEPTH_STEP apart, and this picks the nearest
	int Depth()
	{
		int mid = RSQGC_CardStates.DEPTHS / 2;
		int k = int(floor(mSpotIn[mCurTilt] / RSQGC_CardStates.DEPTH_STEP + 0.5)) + mid;   // this gun's In (spots.zs)
		return clamp(k, 0, RSQGC_CardStates.DEPTHS - 1);
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
		World(0).Hide(); World(1).Hide();
		Side(0).Remove(p); Side(1).Remove(p);
		Kill(p, L_FX);
		mShow[0] = mShow[1] = 0;
	}
}

// RSQ VisualRewards asks by name (its damnums/events.zs Tag): "levelcard", intArg the hand (0 main, 1 off), doubleArg
// how many tics its weapon level card shows, objectArg the player's pawn. The small card of that hand stands down that
// long (the console player's own: the cards are drawn for him only). Answers 1 when it does.
class RSQGC_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request ~== "levelcard")) return 0;
		let pmo = PlayerPawn(objectArg);
		let gc = RSQGC_GunCard.Get();
		if (!gc || !pmo || pmo.player != players[consoleplayer] || intArg < 0 || intArg > 1) return 0;
		if (RSQGC_GunCard.ci("rsqgc_lvlcard", 1) == 0) return 0;
		gc.mLvHide[intArg] = level.maptime + int(clamp(doubleArg, 0, 175));
		return 1;
	}
}
