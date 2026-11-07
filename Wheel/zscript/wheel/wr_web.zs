// wr_web.zs -- RSQ Wheel: the HOLSTER WEB and the shared next / prev ROTATION (owner 2026-11-07, 06:50-07:47; the
// approved mock-ups; design/PARKED.md "Wheel holster web", whose newest lines win).
//
//   MAIN-HAND ALT-FIRE on a card opens the web for that gun: a teal panel on a nearer layer than the ring, the load
//   order's own marine (PLAYA1) on it, and the six gun holsters of RSQ Tactical Rig as rings where the ACTIVE holster
//   profile puts them (a front view of the profile's positions on the marine), in the profile's ring colour, each
//   numbered: 1 L shoulder, 2 R shoulder, 3 L chest, 4 R chest, 5 L hip, 6 R hip. A ring another gun is assigned to
//   shows that gun's name under it. Thin lines run from the card to the rings. A Clear node under the marine.
//   A trigger (either hand) on a ring assigns the gun to that holster at once (the Rig's "rsqtr_assign:<gun>": the gun
//   goes into it, out of the hand holding it, and a gun that held the holster loses it); on Clear it is unassigned and
//   out of the rotation ("rsqtr_unassign:<gun>"). The web then closes; the Wheel stays open (admin mode). Main-hand
//   alt-fire on the same card again closes the web; on another card it opens that card's.
//   OFF-HAND ALT-FIRE on a card puts it in or out of the one shared next / prev rotation; on a holster-assigned card
//   it does nothing but a dull tick (unassign it in the web first).
//   Every admin action restarts the Wheel's fold-away clock.
//
//   A CARD IS ONE OF THREE: plain (Wheel only); a living border, a short gold light running round its edge (in the
//   rotation); sitting back on the ring, smaller, a little further, faded, with an outline in the profile's colour
//   (assigned to a holster, whether the gun is in it or in a hand: out of the rotation). Every toggle flashes a soft
//   ring round the card and ticks the controller.
//
//   THE ROTATION: one list for both hands. A new game (IDKFA) starts with every gun in it (the token below holds the
//   guns taken OUT, so a new inventory is all in); a holster-assigned gun is never in it. QuestZDoom 17.3's next /
//   prev binds ("weapnext" / "weapprev", "weapnext 1" / "weapprev 1" for the off hand) are taken here and step through
//   the guns in the rotation in the engine's own slot order (player.zs PickNextWeapon's walk); with nothing in the
//   rotation they step through every gun, as the engine does.
//
// Without RSQ Tactical Rig (asked by name, RSQTR_RigService) there are no holsters: main-hand alt-fire gives the dull
// tick, and the rotation works alone. Nothing here names a Rig class.

// The guns taken out of the rotation, carried on the player (so it lives through levels and saves, and a new game
// starts empty: every gun in).
class wr_RotTok : Inventory
{
	Array<String> mOut;   // lower-case card class names
	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
		Inventory.MaxAmount 1;
	}
}

extend class wr_Rig
{
	const WST_PLAIN = 0;
	const WST_ROT = 1;
	const WST_HOLSTER = 2;

	const WEB_SHRINK = 0.80;      // a holstered card's size
	const WEB_FADE = 0.70;        // ...and its fade
	const WEB_BACK = 2.2;         // ...and how much further away it sits (map units, x wr_scale)
	// the web panel sits this much NEARER than the ring (x wr_scale): negative, just BEHIND the cards' plane, so the hand's
	// pointer reaches its rings past the hand, as it reaches the cards (owner 09:5x)
	const WEB_NEAR = -1.5;
	const WEB_COL_ROT = 0xFFB020;   // the living border: the Wheel's gold
	const WEB_COL_LINE = 0x2FB8C8;  // the web's teal (the mock-ups' border)
	const WEB_COL_OUT = 0x9AA4B0;   // the flash of a card going out of the rotation
	const WEB_FLASH_TICS = 14;
	const WEB_SIZE = 1.5;         // the panel, x its first size (rings and numbers readable; coordinator 2026-11-07)
	// what sits on the panel, this much nearer than it (map units). The panel is SOLID (drawn in the opaque pass, so it
	// fills the depth buffer): anything in front of it by any margin is drawn over it, whatever the translucent sort does.
	// All of it stays behind the cards' plane (WEB_NEAR).
	const WEB_ON_MARINE = 0.25;
	const WEB_ON_LINE = 0.35;
	const WEB_ON_RING = 0.45;
	const WEB_ON_TEXT = 0.6;
	// THE RING NUMBERS (owner 2026-11-07 10:29): RSQ Score's combo font (RSSCFN2; the Wheel's own copies WRSCnnn,
	// tools/gen_web_digits.py) when RSQ Score is loaded, else JFO's big digits (WRJBnnn), bigger. The ring (WREWRING,
	// tools/gen_web_art.py) peaks at 0.78 of its half size and is half strength at 0.71: its clear inside is 0.71 of the
	// ring across. A digit's picture is this many rings tall, its width by its own proportions: RSSCFN2's are cut to
	// their ink (6 x 6 font pixels), JFO's are 64 x 64 cells with the ink in about 60 x 60 of them.
	const WEB_NUM_SCORE = 0.52;
	const WEB_NUM_JFO = 0.56;
	// THE MARINE'S BODY, measured on BD's PLAYA1 (41 x 56, offset 18 / 51, the load order's marine): the shoulder line
	// at row 10 and the hip line at row 29 of the 51 rows from the top of the picture to his feet; his chest 27 px across
	// and his hips 18 px. The ring spots come from the active profile FITTED to these (owner 09:5x).
	const WEB_SHOULDER_Y = 10.0 / 51.0;
	const WEB_HIP_Y = 29.0 / 51.0;
	const WEB_HALF_W = 9.0 / 41.0;   // the widest holster's distance from his middle, of the picture's width
	const WEB_UNFOLD = 10;        // tics: the panel growing out of the card
	const WEB_LINE_GAP = 3;       // tics between one line starting to draw and the next
	const WEB_LINE_TICS = 5;      // tics a line takes to draw out
	const WEB_POP_TICS = 5;       // tics a ring takes to pop in
	const WEB_PULSE_TICS = 24;    // tics a light pulse takes down a line
	const WEB_FLY_TICS = 14;      // tics the gun's sprite takes from the card into the ring
	const WEB_AFTER_FLY = 16;     // tics the web stays open after it lands (the flash), then closes

	// the six gun holsters by their number (1..6): RSQ Tactical Rig's places 4 5 6 7 0 1 (rig.zs RSQTR_Region)
	static const int WEB_REGION[] = { 4, 5, 6, 7, 0, 1 };
	// the holster profiles' ring colours (1 Standing A blue, 2 Standing B orange, 3 Seated A purple, 4 Seated B
	// yellow), measured from the Rig's own ring skins (models/rsqtr/rtwireid / or / pu / ye.png)
	static const int WEB_PROF_COL[] = { 0x46BEFF, 0xFF9628, 0xAF5FFF, 0xFFE83C };

	// ---- state of the web ---------------------------------------------------------------------------------
	bool mWebOpen;
	bool mWebNumScore;                           // the ring numbers are in RSQ Score's font (Score is loaded)
	Class<Weapon> mWebCls;
	int mWebPanel, mWebMarine, mWebClear, mWebClearText;
	Array<int> mWebRing, mWebNum, mWebName, mWebLine;
	Array<String> mWebNameTxt;
	Array<int> mWebPulse, mWebSpr, mWebBorder;   // the lines' light pulses, the taken rings' gun sprites, the border's light
	Array<String> mWebSprCls;                    // ...the sprite each taken ring shows
	int mWebT0, mWebCloseAt;                     // when the web opened (the unfold), when it closes after a fly-in
	int mFlyId, mFlyNode, mFlyHand, mFlyT0;      // the fly-in: its sprite, its ring, the hand that picked, its start
	bool mFlying;
	String mFlyTex;
	Array<int> mWDMain, mWDSub;   // per card: outline, three sparks of the living border (4 ids a card)
	Array<int> mWFId, mWFTic;     // the toggle flashes
	Array<double> mWFX, mWFY, mWFZ, mWFS;

	// ---- the Rig, by name ---------------------------------------------------------------------------------
	static Service webSvc() { return ServiceIterator.Find("RSQTR_RigService").Next(); }

	// the card's own class: an off-hand version's card is its gun's (the Rig files a gun under the same name)
	Class<Weapon> webKey(Class<Actor> t)
	{
		let wc = (Class<Weapon>)(t);
		if (!wc) return null;
		return cardOf(wc);
	}

	int webAssigned(Class<Weapon> c)
	{
		let sv = webSvc();
		if (!sv || !c) return -1;
		return sv.GetInt("rig.locked", c.GetClassName(), 0, 0, players[consoleplayer].mo);
	}

	String webOwner(int r)
	{
		let sv = webSvc();
		if (!sv) return "";
		return sv.GetString("rig.owner", "", r, 0, players[consoleplayer].mo);
	}

	int webProfile()
	{
		let sv = webSvc();
		if (!sv) return 1;
		return clamp(sv.GetInt("rig.profile", "", 0, 0, players[consoleplayer].mo), 1, 4);
	}

	color webProfCol() { return wr_GunLook.Rgb(WEB_PROF_COL[webProfile() - 1]); }

	// ---- the rotation ---------------------------------------------------------------------------------------
	static wr_RotTok webTok(PlayerPawn pmo, bool make)
	{
		if (!pmo) return null;
		let t = wr_RotTok(pmo.FindInventory("wr_RotTok"));
		if (!t && make)
		{
			pmo.GiveInventoryType("wr_RotTok");
			t = wr_RotTok(pmo.FindInventory("wr_RotTok"));
		}
		return t;
	}

	bool webExcluded(PlayerPawn pmo, Class<Weapon> c)
	{
		let t = webTok(pmo, false);
		if (!t || !c) return false;
		String n = c.GetClassName();
		return t.mOut.Find(n.MakeLower()) != t.mOut.Size();
	}

	void webSetExcluded(PlayerPawn pmo, Class<Weapon> c, bool isOut)
	{
		if (!c) return;
		let t = webTok(pmo, isOut);
		if (!t) return;
		String n = c.GetClassName();
		n = n.MakeLower();
		int at = t.mOut.Find(n);
		if (isOut && at == t.mOut.Size()) t.mOut.Push(n);
		if (!isOut && at != t.mOut.Size()) t.mOut.Delete(at);
	}

	bool webInRotation(PlayerPawn pmo, Class<Weapon> c)
	{
		return c && webAssigned(c) < 0 && !webExcluded(pmo, c);
	}

	// a card's state (-1: no gun on it)
	int webState(Class<Actor> t)
	{
		let c = webKey(t);
		if (!c) return -1;
		if (webAssigned(c) >= 0) return WST_HOLSTER;
		return webExcluded(players[consoleplayer].mo, c) ? WST_PLAIN : WST_ROT;
	}

	Vector3 webSitBack(Vector3 pos, Vector3 eye, double sc)
	{
		Vector3 away = pos - eye;
		if (away.Length() < 0.01) return pos;
		return pos + away.Unit() * WEB_BACK * sc;
	}

	// ---- feel ----------------------------------------------------------------------------------------------
	// a tick in hand h, as the Wheel's other ticks (wr_haptics; QuestZDoom's own haptics switch still overrules it);
	// dull: weaker and longer
	void webTick(int h, bool dull)
	{
		double gain = cv("wr_haptics", 1.0);
		if (gain <= 0.0) return;
		if (dull) wr_VR.VRHaptic(h, 0.18 * gain, 60);
		else      wr_VR.VRHaptic(h, 0.45 * gain, 25);
	}

	void webResetFold()
	{
		mLockTics = int(cv("wr_locktics", 140.0));
		if (mLockTics <= 0) mLockTics = 140;
		mWarnedThisOpen = false;
	}

	// ---- which card is under a hand ----------------------------------------------------------------------
	int webIdUnder(PlayerPawn pmo, int h)
	{
		if (h == mPokeHand) return mHovered;
		int oid; Vector2 ouv;
		[oid, ouv] = wr_BB.AimBillboard(aimPos(pmo, h), aimDir(pmo, h), POINTER_RANGE);
		double touchR = cv("wr_touch", 7.0) * cv("wr_scale", 1.0);
		if (touchR > 0.0)
		{
			int tid; Vector2 tuv; double td;
			[tid, tuv, td] = wr_BB.TouchBillboard(handPos(pmo, h) + handDir(pmo, h) * mTouchReach, touchR);
			if (tid != 0) oid = tid;
		}
		return oid;
	}

	Class<Weapon> webClassOf(int id)
	{
		if (id == 0) return null;
		int sub = subIndexOf(id);
		if (sub >= 0 && sub < mSubTypes.Size()) return webKey(mSubTypes[sub]);
		int i = cardIndexOf(id);
		if (i >= 0 && i < mTypes.Size()) return webKey(mTypes[i]);
		return null;
	}

	// where the card of gun c is now (a fan card first, then the ring's); false: not on the ring
	bool, Vector3 webCardAt(Class<Weapon> c)
	{
		for (int i = 0; i < mSubTypes.Size(); i++) if (webKey(mSubTypes[i]) == c) return true, subPos(i);
		for (int i = 0; i < mTypes.Size(); i++) if (webKey(mTypes[i]) == c) return true, cardPos(i);
		return false, (0, 0, 0);
	}

	// 0..5 a holster ring (its number - 1), 6 Clear, 7 the panel; -1 not the web
	clearscope int webNode(int id) const
	{
		if (id == 0 || !mWebOpen) return -1;
		for (int k = 0; k < mWebRing.Size(); k++) if (mWebRing[k] == id) return k;
		if (id == mWebClear) return 6;
		if (id == mWebPanel) return 7;
		return -1;
	}

	// ---- input (ui) -----------------------------------------------------------------------------------------
	ui bool webInput(InputEvent e, bool fire, bool alt)
	{
		if (mPage != PAGE_WEAPONS) return false;
		bool offFire = wr_Keybind.isKeyFor(e.KeyScan, "+oh_attack");
		bool offAlt  = wr_Keybind.isKeyFor(e.KeyScan, "+oh_altatk");
		int node = webNode(mHovered);
		if (node >= 0)
		{
			if (fire) { EventHandler.SendNetworkEvent("wr_webpick", node, offFire && !wr_Keybind.isKeyFor(e.KeyScan, "+attack") ? 1 : 0); return true; }
			if (alt) return true;   // nothing, and it never fires
			return false;
		}
		if (alt)
		{
			int h = (offAlt && !wr_Keybind.isKeyFor(e.KeyScan, "+altattack")) ? 1 : 0;
			EventHandler.SendNetworkEvent("wr_alt", h);
			return true;
		}
		return false;
	}

	// next / prev: a key bound to exactly QuestZDoom's weapnext / weapprev (with " 1": the off hand) is READ here, never
	// eaten (owner 2026-11-07: RSQ ShieldSaw's off-hand cycle and RSQ Tactical Rig's cigarette read the same keys). The
	// engine's own switch still runs; webCycleTick puts the rotation's pick in its place.
	ui bool webCycleKey(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown) return false;
		let mc = CVar.FindCVar("wr_wheel_mode");
		if (mc && mc.GetInt() != 1) return false;     // the Wheel switched off: the engine's own next / prev
		String b = Bindings.GetBinding(e.KeyScan);
		b = b.MakeLower();
		b.StripLeftRight();
		int dir = 0, hand = 0;
		if (b == "weapnext") dir = 1;
		else if (b == "weapprev") dir = -1;
		else if (b == "weapnext 1") { dir = 1; hand = 1; }
		else if (b == "weapprev 1") { dir = -1; hand = 1; }
		if (dir == 0) return false;
		EventHandler.SendNetworkEvent("wr_cycle", dir, hand);
		return false;
	}

	// ---- network (the console player's own, as the rest of the Wheel) ------------------------------------------
	bool webNetwork(ConsoleEvent e)
	{
		if (e.Name ~== "wr_alt")  { webAlt(e.Args[0] & 1); return true; }
		if (e.Name ~== "wr_webpick") { webPick(e.Args[0], e.Args[1] & 1); return true; }
		if (e.Name ~== "wr_cycle") { webCycle(e.Args[0], e.Args[1] & 1); return true; }
		return false;
	}

	private void webAlt(int h)
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo || !mOpen || mPage != PAGE_WEAPONS) return;
		int id = webIdUnder(pmo, h);
		if (webNode(id) >= 0) return;
		let c = webClassOf(id);
		bool dbg = cvBool("wr_debug", false);
		if (!c) return;
		webResetFold();
		if (h == 0)
		{
			if (!webSvc())
			{
				webTick(0, true);
				if (dbg) Console.Printf("RSQ Wheel web: main-hand alt-fire on %s: no RSQ Tactical Rig, a dull tick", c.GetClassName());
				return;
			}
			if (mWebOpen && mWebCls == c)
			{
				webClose();
				webTick(0, false);
				if (dbg) Console.Printf("RSQ Wheel web: closed (alt-fire on %s again)", c.GetClassName());
				return;
			}
			webClose();
			webOpenFor(c);
			webTick(0, false);
			if (dbg) Console.Printf("RSQ Wheel web: opened for %s (profile %d)", c.GetClassName(), webProfile());
			return;
		}
		// the off hand: the rotation
		if (webAssigned(c) >= 0)
		{
			webTick(1, true);
			if (dbg) Console.Printf("RSQ Wheel web: off-hand alt-fire on %s: assigned to holster %d, nothing (a dull tick)", c.GetClassName(), webAssigned(c));
			return;
		}
		bool wasOut = webExcluded(pmo, c);
		webSetExcluded(pmo, c, !wasOut);
		webFlashGun(c, wasOut ? wr_GunLook.Rgb(WEB_COL_ROT) : wr_GunLook.Rgb(WEB_COL_OUT));
		webTick(1, false);
		if (dbg) Console.Printf("RSQ Wheel web: %s %s the rotation", c.GetClassName(), wasOut ? "into" : "out of");
	}

	private void webPick(int node, int h)
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo || !mOpen || !mWebOpen || !mWebCls || mWebCloseAt > 0) return;
		bool dbg = cvBool("wr_debug", false);
		webResetFold();
		let c = mWebCls;
		String cn = c.GetClassName();
		if (node >= 0 && node < 6)
		{
			int r = WEB_REGION[node];
			String was = webOwner(r);
			if (was != "" && !(was ~== cn))
			{
				// the gun that held this holster loses it: a plain card (out of the rotation, as Clear leaves one)
				Class<Weapon> wc = was;
				webSetExcluded(pmo, wc, true);
			}
			EventHandler.SendNetworkEvent("rsqtr_assign:" .. cn, r);
			webFlashGun(c, webProfCol());
			webTick(h, false);
			if (dbg) Console.Printf("RSQ Wheel web: %s -> holster %d (place %d)%s", cn, node + 1, r, (was != "" && !(was ~== cn)) ? String.Format(", %s loses it", was) : "");
			webFlyStart(c, node, h);   // the web closes once the gun has flown into its ring (webLayout)
			return;
		}
		if (node == 6)
		{
			EventHandler.SendNetworkEvent("rsqtr_unassign:" .. cn);
			webSetExcluded(pmo, c, true);
			webFlashGun(c, wr_GunLook.Rgb(WEB_COL_OUT));
			webTick(h, false);
			if (dbg) Console.Printf("RSQ Wheel web: %s cleared (no holster, out of the rotation)", cn);
			webClose();
		}
	}

	// NEXT / PREV, the engine's own walk through the weapon slots (player.zs PickNextWeapon), skipping what is not in the
	// rotation; with nothing in the rotation, every gun (as the engine does).
	private void webCycle(int dir, int hand)
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo || !pmo.player || pmo.health <= 0) return;
		let p = pmo.player;
		bool dbg = cvBool("wr_debug", false);
		Weapon cur = hand ? p.OffhandWeapon : ((p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon) ? p.PendingWeapon : p.ReadyWeapon);
		// the slots in the engine's order (slot 0 first, as PickNextWeapon walks them)
		Array<Weapon> list;
		int at = -1;
		for (int sl = 0; sl < 10; sl++)
		{
			for (int ix = 0; ix < p.weapons.SlotSize(sl); ix++)
			{
				let type = p.weapons.GetWeapon(sl, ix);
				let w = type ? Weapon(pmo.FindInventory(type)) : null;
				if (!w || list.Find(w) != list.Size()) continue;
				if (w == cur) at = list.Size();
				if (w != cur && (!w.CheckAmmo(Weapon.EitherFire, false) || w.bOffhandWeapon != (hand == 1))) continue;
				list.Push(w);
			}
		}
		int n = list.Size();
		if (n == 0) return;
		// a hand holding something in no slot (RSQ Tactical Rig's cigarette or Zippo, a prop): its own mod decides
		if (cur && at < 0) { mCycleUntil = 0; return; }
		if (at < 0) at = dir > 0 ? n - 1 : 0;
		bool anyRot = false;
		for (int i = 0; i < n; i++) if (webInRotation(pmo, webKey(list[i].GetClass()))) anyRot = true;
		Weapon pick = null;
		String skipped = "";
		for (int step = 1; step < n; step++)
		{
			let w = list[((at + dir * step) % n + n) % n];
			if (w == cur) continue;
			let key = webKey(w.GetClass());
			if (!anyRot || webInRotation(pmo, key)) { pick = w; break; }
			skipped = skipped .. " " .. w.GetClassName() .. (webAssigned(key) >= 0 ? "(holster)" : "(wheel only)");
		}
		if (dbg) Console.Printf("RSQ Wheel rotation: %s (hand %d) from %s -> %s%s", dir > 0 ? "next" : "prev", hand,
			cur ? cur.GetClassName() : 'nothing', pick ? pick.GetClassName() : 'nothing',
			anyRot ? (skipped != "" ? ", skipped" .. skipped : "") : " (nothing in the rotation: every gun)");
		// nothing in the rotation: the engine's own switch is left alone (every gun)
		if (!anyRot) { mCycleUntil = 0; return; }
		// the engine's switch for the same press lands this tic or the next (the bind runs after this event is sent):
		// for a few tics the hand's switch is held to the rotation's pick (or to no switch at all, when the pick is the
		// gun in the hand)
		mCyclePick = pick ? pick : cur;
		mCycleHand = hand;
		mCycleUntil = level.maptime + 6;
		webCycleTick();
	}

	Weapon mCyclePick;
	int mCycleHand, mCycleUntil;

	void webCycleTick()
	{
		if (mCycleUntil <= 0) return;
		if (level.maptime > mCycleUntil || !mCyclePick) { mCycleUntil = 0; mCyclePick = null; return; }
		let pmo = players[consoleplayer].mo;
		if (!pmo || !pmo.player) return;
		let p = pmo.player;
		let held = mCycleHand ? p.OffhandWeapon : p.ReadyWeapon;
		Weapon want = (mCyclePick == held) ? null : mCyclePick;
		if (want)
		{
			if (p.PendingWeapon != want)
			{
				if (cvBool("wr_debug", false) && p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon)
					Console.Printf("RSQ Wheel rotation: the engine's %s replaced by %s", p.PendingWeapon.GetClassName(), want.GetClassName());
				p.PendingWeapon = want;
			}
		}
		else if (p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon && (p.PendingWeapon.bOffhandWeapon == (mCycleHand == 1)))
		{
			if (cvBool("wr_debug", false)) Console.Printf("RSQ Wheel rotation: the engine's %s held off (the hand keeps %s)", p.PendingWeapon.GetClassName(), held ? held.GetClassName() : 'nothing');
			p.PendingWeapon = WP_NOCHANGE;
		}
	}

	// ---- the toggle's flash: a soft ring round the card, growing and fading ---------------------------------------
	void webFlashGun(Class<Weapon> c, color col)
	{
		bool on; Vector3 at;
		[on, at] = webCardAt(c);
		if (!on) return;
		double s = panelWNow();
		int id = wr_BB.AddBillboardPersistent(at, s, s, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_SKIN, 0, col,
			wr_BB.BBFL_NOHIT | wr_BB.BBFL_SHADED, 0, "WREWRING");
		if (!id) return;
		mWFId.Push(id); mWFTic.Push(level.maptime); mWFX.Push(at.x); mWFY.Push(at.y); mWFZ.Push(at.z); mWFS.Push(s);
	}

	private void webFlashTick()
	{
		for (int i = mWFId.Size() - 1; i >= 0; i--)
		{
			double t = (level.maptime - mWFTic[i]) / double(WEB_FLASH_TICS);
			if (t >= 1.0)
			{
				wr_BB.RemoveBillboard(mWFId[i]);
				mWFId.Delete(i); mWFTic.Delete(i); mWFX.Delete(i); mWFY.Delete(i); mWFZ.Delete(i); mWFS.Delete(i);
				continue;
			}
			double e = 1.0 - (1.0 - t) * (1.0 - t);
			double sz = mWFS[i] * (0.9 + 1.1 * e);
			wr_BB.ResizeBillboard(mWFId[i], sz, sz);
			wr_BB.SetBillboardAlpha(mWFId[i], 0.9 * (1.0 - t));
		}
	}

	private void webFlashClear()
	{
		for (int i = 0; i < mWFId.Size(); i++) wr_BB.RemoveBillboard(mWFId[i]);
		mWFId.Clear(); mWFTic.Clear(); mWFX.Clear(); mWFY.Clear(); mWFZ.Clear(); mWFS.Clear();
	}

	// ---- the card states' parts ----------------------------------------------------------------------------------
	private int webQuad(string skin, color col, int behind, int steps)
	{
		int id = wr_BB.AddBillboardPersistent((0, 0, 0), 1, 1, 0, 0, wr_BB.BBF_FIXED, wr_BB.BB_SKIN, 0, col,
			wr_BB.BBFL_NOHIT | wr_BB.BBFL_SHADED, 0, skin);
		if (id)
		{
			wr_BB.SetBillboardAlpha(id, 0);
			if (behind) wr_BB.SetBillboardLayerFrom(id, behind, steps);
		}
		return id;
	}

	void webDecorClear(bool sub)
	{
		Array<int> a;
		if (sub) a.Move(mWDSub); else a.Move(mWDMain);
		for (int i = 0; i < a.Size(); i++) if (a[i]) wr_BB.RemoveBillboard(a[i]);
		if (!sub) webFlashClear();
	}

	// card i (a fan card when sub) was placed this tic at pos, w x h, alpha; st its state
	void webDecorCard(bool sub, int i, int plate, Vector3 pos, double faceYaw, double tilt, double roll,
	                  double w, double h, double alpha, int st)
	{
		if (st < 0 && (sub ? mWDSub.Size() : mWDMain.Size()) <= i * 4) return;
		int base = i * 4;
		if (sub) { while (mWDSub.Size() < base + 4) mWDSub.Push(0); }
		else     { while (mWDMain.Size() < base + 4) mWDMain.Push(0); }
		int ids[4];
		for (int k = 0; k < 4; k++) ids[k] = sub ? mWDSub[base + k] : mWDMain[base + k];
		if (st == WST_HOLSTER && !ids[0]) ids[0] = webQuad("WREHALO", webProfCol(), plate, -6);
		if (st == WST_ROT)
			for (int k = 1; k < 4; k++) if (!ids[k]) ids[k] = webQuad("WRESPARK", wr_GunLook.Rgb(WEB_COL_ROT), plate, 3);
		for (int k = 0; k < 4; k++) { if (sub) mWDSub[base + k] = ids[k]; else mWDMain[base + k] = ids[k]; }

		double cy = cos(faceYaw), sy = sin(faceYaw), ct = cos(tilt), stl = sin(tilt);
		Vector3 cR = (-sy, cy, 0), cU = (-cy * stl, -sy * stl, ct);
		// roll turns the card's right toward its up
		Vector3 rR = cR * cos(roll) + cU * sin(roll), rU = cU * cos(roll) - cR * sin(roll);
		Vector3 fwd = (cy, sy, 0);

		// THE OUTLINE (assigned to a holster): a glow round the card in the profile's ring colour, breathing slowly
		if (ids[0])
		{
			if (st == WST_HOLSTER)
			{
				double b = 0.5 + 0.5 * sin(level.maptime * 6.0 + i * 40.0);
				wr_BB.MoveBillboard(ids[0], pos - fwd * 0.4);
				wr_BB.ResizeBillboard(ids[0], w * 1.28, h * 1.42);
				wr_BB.OrientBillboard(ids[0], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(ids[0], roll);
				wr_BB.SetBillboardAlpha(ids[0], alpha * (0.55 + 0.35 * b) / WEB_FADE);
			}
			else wr_BB.SetBillboardAlpha(ids[0], 0);
		}
		// THE LIVING BORDER (in the rotation): a short gold light running round the edge, a head and two fading tail sparks
		for (int k = 1; k < 4; k++)
		{
			if (!ids[k]) continue;
			if (st != WST_ROT) { wr_BB.SetBillboardAlpha(ids[k], 0); continue; }
			double th = level.maptime * 9.0 + i * 67.0 - (k - 1) * 9.0;
			double c = cos(th), s = sin(th);
			double hw = w * 0.5, hh = h * 0.5;
			double kk = 1.0 / max(abs(c) / hw, abs(s) / hh);
			wr_BB.MoveBillboard(ids[k], pos + fwd * (LABEL_LIFT * 1.2) + rR * (c * kk) + rU * (s * kk));
			double sz = h * (k == 1 ? 0.42 : (k == 2 ? 0.32 : 0.24));
			wr_BB.ResizeBillboard(ids[k], sz, sz);
			wr_BB.OrientBillboard(ids[k], faceYaw, tilt, wr_BB.BBF_FIXED);
			wr_BB.SetBillboardAlpha(ids[k], alpha * (k == 1 ? 1.0 : (k == 2 ? 0.6 : 0.3)));
		}
	}

	// ---- the web itself ------------------------------------------------------------------------------------------
	private int webBB(int payload, int data, color col, string text, bool hit, int layer, int extra = 0)
	{
		int id = wr_BB.AddBillboardPersistent((0, 0, 0), 1, 1, 0, 0, wr_BB.BBF_FIXED, payload, data, col,
			(hit ? 0 : wr_BB.BBFL_NOHIT) | extra, 0, text);
		if (id) wr_BB.SetBillboardLayer(id, layer);
		return id;
	}

	// a glow quad (AddShaded: the texture's grey is its strength), unhittable, hidden until placed
	private int webGlow(string skin, color col, int layer)
	{
		int id = wr_BB.AddBillboardPersistent((0, 0, 0), 1, 1, 0, 0, wr_BB.BBF_FIXED, wr_BB.BB_SKIN, 0, col,
			wr_BB.BBFL_NOHIT | wr_BB.BBFL_SHADED, 0, skin);
		if (id) { wr_BB.SetBillboardLayer(id, layer); wr_BB.SetBillboardAlpha(id, 0); }
		return id;
	}

	// the gun's own pickup sprite (an off-hand copy: its gun's, artClass), by name; "" when it has none
	static String webPickupName(Class<Actor> c)
	{
		if (!c) return "";
		TextureID t = spawnTex(artClass(c));
		if (!t.IsValid()) return "";
		String n = TexMan.GetName(t);
		if (n.Left(4) ~== "TNT1") return "";
		return n;
	}

	// a gun's name for under its ring
	static String webTagOf(String cls)
	{
		if (cls == "") return "";
		Class<Weapon> oc = cls;
		String nm = oc ? GetDefaultByType(oc).GetTag() : cls;
		nm = nm.MakeUpper();
		if (int(nm.Length()) > 12) nm = nm.Left(12);
		return nm;
	}

	private void webOpenFor(Class<Weapon> c)
	{
		mWebOpen = true;
		mWebCls = c;
		mWebT0 = level.maptime;
		mWebCloseAt = 0;
		color pc = webProfCol();
		mWebNumScore = ServiceIterator.Find("RS_ScoreService").Next() != null;
		// the panel and the marine are SOLID (the opaque pass: nothing behind the panel shows through it) and BRIGHT (the
		// panel's own teal and the marine's own colours, whatever the room's light)
		mWebPanel = webBB(wr_BB.BB_TEXTURE, 0, 0xFFFFFF, "WREWPAN", true, 0, wr_BB.BBFL_SOLID | wr_BB.BBFL_BRIGHT);
		mWebMarine = webBB(wr_BB.BB_TEXTURE, 0, 0xFFFFFF, "PLAYA1", false, 2, wr_BB.BBFL_SOLID | wr_BB.BBFL_BRIGHT);
		for (int k = 0; k < 6; k++)
		{
			mWebLine.Push(webBB(wr_BB.BB_SKIN, 0, WEB_COL_LINE, "WREWLINE", false, 3));
			wr_BB.SetBillboardAlpha(mWebLine[k], 0);
			mWebPulse.Push(webGlow("WRESPARK", WEB_COL_LINE, 4));
		}
		for (int k = 0; k < 6; k++)
		{
			int rid = wr_BB.AddBillboardPersistent((0, 0, 0), 1, 1, 0, 0, wr_BB.BBF_FIXED, wr_BB.BB_SKIN, 0, pc, wr_BB.BBFL_SHADED, 0, "WREWRING");
			if (rid) wr_BB.SetBillboardLayer(rid, 4);
			mWebRing.Push(rid);
			mWebNum.Push(webBB(wr_BB.BB_TEXTURE, 0, 0xFFFFFF, webNumTex(k + 1), false, 6, wr_BB.BBFL_BRIGHT));
			mWebName.Push(0); mWebNameTxt.Push("");
			mWebSpr.Push(0); mWebSprCls.Push("");
		}
		for (int k = 0; k < 3; k++) mWebBorder.Push(webGlow("WRESPARK", wr_GunLook.Rgb(WEB_COL_ROT), 7));
		mWebClear = webBB(wr_BB.BB_PANEL, 0, 0x1C4F58, "", true, 4);
		mWebClearText = webBB(wr_BB.BB_TEXT, 0, 0xE6F4F6, "CLEAR", false, 6);
	}

	// a ring number's picture: RSQ Score's font with Score loaded, else JFO's (mWebNumScore, set as the web opens)
	private String webNumTex(int d)
	{
		return String.Format(mWebNumScore ? "WRSC%03d" : "WRJB%03d", 48 + d);
	}

	void webClose()
	{
		if (mWebPanel) wr_BB.RemoveBillboard(mWebPanel);
		if (mWebMarine) wr_BB.RemoveBillboard(mWebMarine);
		if (mWebClear) wr_BB.RemoveBillboard(mWebClear);
		if (mWebClearText) wr_BB.RemoveBillboard(mWebClearText);
		if (mFlyId) wr_BB.RemoveBillboard(mFlyId);
		for (int k = 0; k < mWebRing.Size(); k++) if (mWebRing[k]) wr_BB.RemoveBillboard(mWebRing[k]);
		for (int k = 0; k < mWebNum.Size(); k++) if (mWebNum[k]) wr_BB.RemoveBillboard(mWebNum[k]);
		for (int k = 0; k < mWebName.Size(); k++) if (mWebName[k]) wr_BB.RemoveBillboard(mWebName[k]);
		for (int k = 0; k < mWebLine.Size(); k++) if (mWebLine[k]) wr_BB.RemoveBillboard(mWebLine[k]);
		for (int k = 0; k < mWebPulse.Size(); k++) if (mWebPulse[k]) wr_BB.RemoveBillboard(mWebPulse[k]);
		for (int k = 0; k < mWebSpr.Size(); k++) if (mWebSpr[k]) wr_BB.RemoveBillboard(mWebSpr[k]);
		for (int k = 0; k < mWebBorder.Size(); k++) if (mWebBorder[k]) wr_BB.RemoveBillboard(mWebBorder[k]);
		mWebPanel = mWebMarine = mWebClear = mWebClearText = mFlyId = 0;
		mWebRing.Clear(); mWebNum.Clear(); mWebName.Clear(); mWebLine.Clear(); mWebNameTxt.Clear();
		mWebPulse.Clear(); mWebSpr.Clear(); mWebSprCls.Clear(); mWebBorder.Clear();
		mWebOpen = false;
		mWebCls = null;
		mFlying = false;
		mWebCloseAt = 0;
	}

	// While the web is open the data sheet under it is not drawn (sized to nothing; layoutSheet sizes it again every
	// tic, so it is back the tic the web closes): the hovered card's label never shows through the panel.
	private void webHideSheet()
	{
		if (mSheetPlate) wr_BB.ResizeBillboard(mSheetPlate, 0, 0);
		if (mSheetAccent) wr_BB.ResizeBillboard(mSheetAccent, 0, 0);
		if (mSheetTitle) wr_BB.ResizeBillboard(mSheetTitle, 0, 0);
		if (mGLSheetShadow) wr_BB.ResizeBillboard(mGLSheetShadow, 0, 0);
		if (mSheetHit) wr_BB.ResizeBillboard(mSheetHit, 0, 0);
		for (int i = 0; i < mSheetRows.Size(); i++) if (mSheetRows[i]) wr_BB.ResizeBillboard(mSheetRows[i], 0, 0);
		for (int i = 0; i < mSheetBars.Size(); i++) if (mSheetBars[i]) wr_BB.ResizeBillboard(mSheetBars[i], 0, 0);
	}

	private void webPlace(int id, Vector3 at, double w, double h, double yaw, double tilt, double roll = 0)
	{
		if (!id) return;
		wr_BB.MoveBillboard(id, at);
		wr_BB.ResizeBillboard(id, w, h);
		wr_BB.OrientBillboard(id, yaw, tilt, wr_BB.BBF_FIXED);
		wr_BB.RollBillboard(id, roll);
	}

	// a sprite fitted into a box d x d, its own proportions
	private void webPlaceSprite(int id, String tex, Vector3 at, double d, double yaw, double tilt)
	{
		double w = d, h = d;
		TextureID t = TexMan.CheckForTexture(tex, TexMan.Type_Any);
		if (t.IsValid())
		{
			Vector2 sz = TexMan.GetScaledSize(t);
			if (sz.x > 0 && sz.y > 0) { if (sz.x >= sz.y) h = d * sz.y / sz.x; else w = d * sz.x / sz.y; }
		}
		webPlace(id, at, w, h, yaw, tilt);
	}

	// the active profile's place r on the body, metres from the eyes: forward, left, up (the Rig's own settings)
	static double webCv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }

	static double webEase(double t) { t = clamp(t, 0.0, 1.0); return 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t); }

	// Every tic the ring is laid out (layout()'s end): the flashes, and the web while it is open.
	void webLayout(PlayerPawn pmo, Vector3 wrist, double viewYaw, double tilt, double rise, double ringR,
	               double panelW, double panelH, Vector3 eye)
	{
		webFlashTick();
		if (!mWebOpen) return;
		if (!mWebCls || !pmo.FindInventory(mWebCls)) { webClose(); return; }
		if (mWebCloseAt > 0 && level.maptime >= mWebCloseAt) { webClose(); return; }
		webHideSheet();
		int age = level.maptime - mWebT0;
		double sc = cv("wr_scale", 1.0);
		double yaw = viewYaw + 180;
		double cy = cos(yaw), sy = sin(yaw), ct = cos(tilt), st = sin(tilt);
		Vector3 wR = (-sy, cy, 0), wU = (-cy * st, -sy * st, ct), wF = (cy, sy, 0);
		Vector3 wC = wrist + (0, 0, rise) + wF * (WEB_NEAR * sc);

		// the card's centre, seen through the panel's plane from the eye
		bool cardOn; Vector3 cardAt;
		[cardOn, cardAt] = webCardAt(mWebCls);
		double cu = 0, cvv = 0;
		if (cardOn)
		{
			Vector3 dq = cardAt - eye;
			double den = wF dot dq;
			if (abs(den) > 1e-6)
			{
				double t = (wF dot (wC - eye)) / den;
				Vector3 pp = eye + dq * t - wC;
				cu = pp dot wR; cvv = pp dot wU;
			}
		}

		// THE UNFOLD: the panel grows out of the card (its centre slides from the card to its place as it grows); the
		// lines then draw out one by one and each ring pops in as its line reaches it
		double e = webEase(age / double(WEB_UNFOLD));
		double s = 0.08 + 0.92 * e;
		double ox = cu * (1.0 - e), oy = cvv * (1.0 - e);

		// THE PANEL: inside the ring, in front of the data sheet
		double PW = max(ringR * 1.0, panelW * 2.0) * WEB_SIZE;
		double PH = PW * 1.25;
		webPlace(mWebPanel, wC + wR * ox + wU * oy, PW * s, PH * s, yaw, tilt);

		// THE MARINE: the load order's PLAYA1, its own proportions, placed by its own OFFSET (the point the engine
		// stands on the floor: his body's middle and his feet), not by the picture's box, which takes in the rifle
		double sw = 41, sh = 56, sox = 20.5, soy = 53;
		TextureID tex = TexMan.CheckForTexture("PLAYA1", TexMan.Type_Sprite);
		if (tex.IsValid())
		{
			Vector2 sz = TexMan.GetScaledSize(tex);
			Vector2 so = TexMan.GetScaledOffset(tex);
			if (sz.x > 0 && sz.y > 0) { sw = sz.x; sh = sz.y; }
			sox = (so.x > 0 && so.x < sw) ? so.x : sw * 0.5;
			soy = (so.y > sh * 0.5 && so.y <= sh * 1.1) ? so.y : sh;
			// BD's PLAYA1 (41 x 56, offset 18 / 51): his body's middle is column 14.5, measured from its pixels (head,
			// chest and hips all centre on 14.5; owner 2026-11-07); any other marine keeps its own offset
			if (sw == 41 && sh == 56 && so.x == 18 && so.y == 51) sox = 14.5;
		}
		double MH = PH * 0.72;
		double k = MH / sh;               // map units a sprite pixel
		double MW = sw * k;
		double mTop = PH * 0.5 - PH * 0.08;
		double bodyH = soy * k;           // the top of the picture to his feet
		double mx = (sw * 0.5 - sox) * k; // the picture's middle, from his body's
		webPlace(mWebMarine, wC + wR * (ox + s * mx) + wU * (oy + s * (mTop - MH * 0.5)) + wF * WEB_ON_MARINE, MW * s, MH * s, yaw, tilt);

		// THE HOLSTERS on him: a front view (he faces you, so his left is on your right).
		// the profile FITTED to him: its highest holsters on his shoulder line, its lowest on his hip line, the rest
		// scaled between; left / right as the profile has them, its widest holster WEB_HALF_W from his middle
		double uHi = -1e9, uLo = 1e9, lMax = 0;
		for (int q = 0; q < 6; q++)
		{
			int rq = WEB_REGION[q];
			double uq = webCv(String.Format("rsqtr_r%d_u", rq), 0), lq = webCv(String.Format("rsqtr_r%d_l", rq), 0);
			uHi = max(uHi, uq); uLo = min(uLo, uq); lMax = max(lMax, abs(lq));
		}
		double yShoulder = mTop - bodyH * WEB_SHOULDER_Y, yHip = mTop - bodyH * WEB_HIP_Y;
		double halfW = sw * WEB_HALF_W * k;
		double D = MH * 0.13;
		color pc = webProfCol();
		color pcLit = color(min(255, pc.r / 2 + 128), min(255, pc.g / 2 + 128), min(255, pc.b / 2 + 128));
		String wcn = mWebCls.GetClassName();

		for (int n = 0; n < 6 && n < mWebRing.Size(); n++)
		{
			int r = WEB_REGION[n];
			double l = webCv(String.Format("rsqtr_r%d_l", r), 0);
			double u = webCv(String.Format("rsqtr_r%d_u", r), 0);
			double fu = (uHi - uLo) > 0.01 ? (u - uLo) / (uHi - uLo) : 0.5;
			double fl = lMax > 0.01 ? l / lMax : 0.0;
			double px = ox + s * (fl * halfW), py = oy + s * (yHip + fu * (yShoulder - yHip));
			Vector3 at = wC + wR * px + wU * py;
			bool lit = mWebRing[n] == mHovered;
			String owner = webOwner(r);
			bool mine = (owner ~== wcn);
			bool flying = (mFlying && n == mFlyNode);
			if (flying) owner = "";

			// this ring's line starts drawing at lineT, takes WEB_LINE_TICS, and the ring pops in as it arrives
			int lineT = WEB_UNFOLD + n * WEB_LINE_GAP;
			double lf = clamp((age - lineT) / double(WEB_LINE_TICS), 0.0, 1.0);
			double pp = clamp((age - lineT - WEB_LINE_TICS) / double(WEB_POP_TICS), 0.0, 1.0);
			double pop = pp * (1.0 + 0.6 * sin(pp * 180.0));

			double rs = D * pop * (lit ? 1.35 : 1.0) * (mine ? 1.12 : 1.0);
			webPlace(mWebRing[n], at + wF * WEB_ON_RING, rs, rs, yaw, tilt);
			wr_BB.SetBillboardAlpha(mWebRing[n], 1.0);
			wr_BB.UpdateBillboard(mWebRing[n], 0, lit ? pcLit : pc);

			// a taken ring shows its gun's own pickup sprite; an empty one its number
			Class<Actor> oca = owner;
			String want = (owner != "" && oca) ? webPickupName(oca) : "";
			if (n < mWebSpr.Size() && !(want ~== mWebSprCls[n]))
			{
				if (mWebSpr[n]) wr_BB.RemoveBillboard(mWebSpr[n]);
				mWebSpr[n] = want != "" ? webBB(wr_BB.BB_TEXTURE, 0, 0xFFFFFF, want, false, 6, wr_BB.BBFL_SOLID | wr_BB.BBFL_BRIGHT) : 0;
				mWebSprCls[n] = want;
			}
			if (mWebSpr[n]) webPlaceSprite(mWebSpr[n], mWebSprCls[n], at + wF * WEB_ON_TEXT, rs * 0.80, yaw, tilt);
			// (text is laid out in its box's proportions when first built: its box is never sized to nothing, it is hidden
			// by its alpha instead)
			double tp = max(pop, 0.05);
			{
				// the number as big as its ring allows (WEB_NUM_*), centred in it, its picture's own proportions
				int tw, th;
				[tw, th] = TexMan.GetSize(TexMan.CheckForTexture(webNumTex(n + 1), TexMan.Type_Any));
				double nh = max(rs, D * 0.05) * (mWebNumScore ? WEB_NUM_SCORE : WEB_NUM_JFO);
				webPlace(mWebNum[n], at + wF * WEB_ON_TEXT, nh * (th > 0 ? double(tw) / th : 1.0), nh, yaw, tilt);
			}
			wr_BB.SetBillboardAlpha(mWebNum[n], (pop > 0.0 && !mWebSpr[n]) ? 1.0 : 0.0);

			// the owner's name under the ring, never wider than two rings
			String nm = webTagOf(owner);
			if (!(nm == mWebNameTxt[n]))
			{
				if (mWebName[n]) wr_BB.RemoveBillboard(mWebName[n]);
				mWebName[n] = nm != "" ? webBB(wr_BB.BB_TEXT, 0, 0xFFFFFF, nm, false, 6) : 0;
				mWebNameTxt[n] = nm;
			}
			if (mWebName[n])
			{
				double nh = D * 0.30 * tp;
				wr_BB.SetBillboardAlpha(mWebName[n], pop > 0.0 ? 1.0 : 0.0);
				double nw = wr_BB.MeasureBillboardText(nm, nh);
				if (nw > D * 2.0) { nh *= D * 2.0 / nw; nw = D * 2.0; }
				webPlace(mWebName[n], at + wF * WEB_ON_TEXT - wU * (D * 0.5 + nh * 0.7), nw, nh, yaw, tilt);
			}

			// THE FLY-IN: the gun's sprite from the card down this ring's line into the ring; at the ring a flash in the
			// profile's colour and a kick in the hand that picked it
			if (flying)
			{
				double ft = clamp((level.maptime - mFlyT0) / double(WEB_FLY_TICS), 0.0, 1.0);
				double fe = ft * ft * (3 - 2 * ft);
				Vector3 to = at + wF * (WEB_ON_TEXT + 0.1);
				Vector3 from = cardOn ? cardAt + wF * 1.0 : to;
				double fd = panelW * (1.0 - fe) + rs * 0.80 * fe;
				if (mFlyId) webPlaceSprite(mFlyId, mFlyTex, from + (to - from) * fe, fd, yaw, tilt);
				if (ft >= 1.0)
				{
					mFlying = false;
					if (mFlyId) wr_BB.RemoveBillboard(mFlyId);
					mFlyId = 0;
					webFlashAt(to, D * 2.4, pc);
					double gain = cv("wr_haptics", 1.0);
					if (gain > 0.0) wr_VR.VRHaptic(mFlyHand, 0.85 * gain, 45);
					if (cvBool("wr_debug", false)) Console.Printf("RSQ Wheel web: %s landed in holster %d (flash, kick)", wcn, n + 1);
				}
			}

			// the thread from the card: drawn out from the card; solid and brighter while its ring is hovered; a small
			// light pulse running down it from the card otherwise
			double du = px - cu, dv = py - cvv;
			double full = sqrt(du * du + dv * dv) - D * 0.5;
			double ang = atan2(dv, du);
			if (!cardOn || full <= 0.05 || lf <= 0.0)
			{
				wr_BB.SetBillboardAlpha(mWebLine[n], 0);
				wr_BB.SetBillboardAlpha(mWebPulse[n], 0);
				continue;
			}
			double len = full * lf;
			double ex = cu + cos(ang) * len * 0.5, ey = cvv + sin(ang) * len * 0.5;
			webPlace(mWebLine[n], wC + wR * ex + wU * ey + wF * WEB_ON_LINE, len, (lit ? 0.22 : 0.10) * sc, yaw, tilt, ang);
			wr_BB.SetBillboardAlpha(mWebLine[n], lit ? 1.0 : 0.6);
			if (lit || lf < 1.0) { wr_BB.SetBillboardAlpha(mWebPulse[n], 0); continue; }
			double ph = ((level.maptime + n * 7) % WEB_PULSE_TICS) / double(WEB_PULSE_TICS);
			double qx = cu + cos(ang) * full * ph, qy = cvv + sin(ang) * full * ph;
			double qs = D * 0.32;
			webPlace(mWebPulse[n], wC + wR * qx + wU * qy + wF * (WEB_ON_LINE + 0.05), qs, qs, yaw, tilt);
			wr_BB.SetBillboardAlpha(mWebPulse[n], sin(ph * 180.0));

		}

		// CLEAR, under the marine
		double clW = PW * 0.38 * s, clH = PH * 0.075 * s;
		Vector3 clAt = wC + wR * ox + wU * (oy + s * (-PH * 0.5 + PH * 0.075));
		webPlace(mWebClear, clAt + wF * WEB_ON_RING, clW, clH, yaw, tilt);
		wr_BB.UpdateBillboard(mWebClear, 0, mWebClear == mHovered ? color(0x2FB8C8) : color(0x1C4F58));
		webPlace(mWebClearText, clAt + wF * WEB_ON_TEXT, clW * 0.8, clH * 0.6, yaw, tilt);

		// THE PANEL'S BORDER carries the running light of an in-rotation card: a short gold light round its edge
		for (int b = 0; b < mWebBorder.Size(); b++)
		{
			if (!mWebBorder[b]) continue;
			if (e < 1.0) { wr_BB.SetBillboardAlpha(mWebBorder[b], 0); continue; }
			double th = level.maptime * 9.0 - b * 9.0;
			double c = cos(th), sn = sin(th);
			double hw = PW * 0.5 * 0.985, hh = PH * 0.5 * 0.99;
			double kk = 1.0 / max(abs(c) / hw, abs(sn) / hh);
			double bs = D * (b == 0 ? 0.9 : (b == 1 ? 0.7 : 0.5));
			webPlace(mWebBorder[b], wC + wR * (c * kk) + wU * (sn * kk) + wF * WEB_ON_TEXT, bs, bs, yaw, tilt);
			wr_BB.SetBillboardAlpha(mWebBorder[b], b == 0 ? 1.0 : (b == 1 ? 0.6 : 0.3));
		}
	}

	// a soft ring flashing out at a point (the fly-in's landing), in the toggle flashes' list
	void webFlashAt(Vector3 at, double size, color col)
	{
		int id = wr_BB.AddBillboardPersistent(at, size, size, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_SKIN, 0, col,
			wr_BB.BBFL_NOHIT | wr_BB.BBFL_SHADED, 0, "WREWRING");
		if (!id) return;
		mWFId.Push(id); mWFTic.Push(level.maptime); mWFX.Push(at.x); mWFY.Push(at.y); mWFZ.Push(at.z); mWFS.Push(size);
	}

	// the fly-in starts (webPick): the picked gun's sprite leaves its card for ring n
	void webFlyStart(Class<Weapon> c, int n, int h)
	{
		if (mFlyId) wr_BB.RemoveBillboard(mFlyId);
		mFlyTex = webPickupName(c);
		mFlyId = mFlyTex != "" ? webBB(wr_BB.BB_TEXTURE, 0, 0xFFFFFF, mFlyTex, false, 8, wr_BB.BBFL_SOLID | wr_BB.BBFL_BRIGHT) : 0;
		mFlyNode = n;
		mFlyHand = h;
		mFlyT0 = level.maptime;
		mFlying = true;
		mWebCloseAt = level.maptime + WEB_FLY_TICS + WEB_AFTER_FLY;
	}
}
