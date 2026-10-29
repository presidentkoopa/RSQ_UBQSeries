// THE GRIP, UP CLOSE (the owner, 10-29). Three things a grip does with a hand that is touching
// something, and while it does them it comes first -- before the engine's two-hand steadying, before
// the distance reach -- so the grip press is EATEN (InputProcess returns true) whenever one of them
// takes it. A hand in a Tactical Rig holster is the rig's: holsters come before all of this.
//
//   SWAP HANDS   both controllers together (rsqdg_swap_m) and both rolled palm-up/sideways
//                (|roll| >= rsqdg_swap_roll): either grip swaps the two hands' weapons. The off
//                hand's grip takes the main hand's gun; the main hand's takes the off hand's. A hand
//                with nothing to give gets its empty hand (the fist / Brutal Doom VR's hands).
//   WALK-UP GRAB the grip with the palm within rsqdg_near_m of a thing takes it straight into the
//                hand: a pickup is used (as a caught pull is, rsqdg_catch_takes), a barrel or corpse
//                is carried until the grip is let go (moving: thrown), a door is lifted (door.zs).
//   HEADLOCK     the OFF hand's grip on a living monster no heavier than rsqdg_collar_mass holds it
//                frozen in front of the hand for up to rsqdg_collar_secs, so the main hand can punch
//                it. RSQ_Score is told ("grab.hold"), and "Headlock" (grab.hold > hands) is a combo.
//
// THE GRIP KEYS are read raw, as the rig reads them: QuestZDoom sends the off-hand grip as
// KEY_PAD_RTHUMB (443), or KEY_PAD_DPAD_UP (436) while the main grip is held as a shift; the main
// grip is KEY_PAD_LTRIGGER (446) only when vr_secondary_button_mappings is off. Both are cvars.
//
// NETPLAY: the hand poses exist only on the camera player's machine, so that machine decides and
// sends one network event per press; the act is applied from it. In a netgame the target is found
// again from the pawn's synced fields on each machine -- single player is the target here.
class RSQDG_Near : EventHandler
{
	// ---- synced (NetworkProcess) ----------------------------------------------------------
	bool gripDown[MAXPLAYERS * 2];
	bool owns[MAXPLAYERS * 2];          // this hand's held object was taken by the walk-up grip
	Actor collar[MAXPLAYERS];
	int collarEnd[MAXPLAYERS], collarPing[MAXPLAYERS];
	bool cNoGrav[MAXPLAYERS], cThru[MAXPLAYERS];
	String offNext[MAXPLAYERS];
	int offWait[MAXPLAYERS];

	// ---- local (console player): read by InputProcess --------------------------------------
	transient bool ready[2];
	private transient ui bool eaten[2];
	private transient ui bool keyState[2];
	private transient ui Array<int> keysMain, keysOff;
	private transient ui String keysMainFrom, keysOffFrom;

	static RSQDG_Near Get() { return RSQDG_Near(EventHandler.Find("RSQDG_Near")); }

	// The grab and the door ask these.
	static bool IsGripDown(int h)
	{
		let n = Get();
		return n && (h == 0 || h == 1) && n.gripDown[consoleplayer * 2 + h];
	}
	static bool OwnsHand(PlayerInfo p, int h)
	{
		let n = Get();
		if (!n || !p || !p.mo || (h != 0 && h != 1)) return false;
		return n.owns[p.mo.PlayerNumber() * 2 + h];
	}

	// ---- the switches --------------------------------------------------------------------
	static bool On(String n, PlayerInfo p, bool d) { return RSQDG_Reach.Flag(n, p, d); }

	// ---- input ----------------------------------------------------------------------------
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		let me = players[consoleplayer];
		Refresh("rsqdg_keys_main", "446", me, keysMain, keysMainFrom);
		Refresh("rsqdg_keys_off", "443 436", me, keysOff, keysOffFrom);
		bool down = e.Type == InputEvent.Type_KeyDown;
		for (int h = 0; h < 2; h++)
		{
			bool mine = h == 0 ? keysMain.Find(e.KeyScan) < keysMain.Size() : keysOff.Find(e.KeyScan) < keysOff.Size();
			if (!mine) continue;
			if (keyState[h] == down) return eaten[h];
			keyState[h] = down;
			if (down)
			{
				eaten[h] = ready[h];
				if (eaten[h]) EventHandler.SendNetworkEvent("rsqdg_ngrip", h, 1);
				return eaten[h];
			}
			bool was = eaten[h];
			eaten[h] = false;
			if (was) EventHandler.SendNetworkEvent("rsqdg_ngrip", h, 0);
			return was;
		}
		return false;
	}

	private ui void Refresh(String cvn, String def, PlayerInfo me, out Array<int> keys, out String from)
	{
		let cv = CVar.GetCVar(cvn, me);
		String s = cv ? cv.GetString() : def;
		if (s == from) return;
		from = s;
		keys.Clear();
		Array<String> w;
		s.Split(w, " ", TOK_SKIPEMPTY);
		for (int i = 0; i < w.Size(); i++) keys.Push(w[i].ToInt());
	}

	// ---- what a hand could do right now ------------------------------------------------------
	static bool RigBusy(PlayerPawn pmo, int h)
	{
		let rit = ServiceIterator.Find("RSQTR_RigService");
		Service rs;
		while (rs = rit.Next())
			if (rs.GetInt("rig.region", "", h, 0, pmo) >= 0) return true;
		return false;
	}

	static bool SwapPose(PlayerPawn pmo, PlayerInfo p)
	{
		if (!On("rsqdg_swap", p, true)) return false;
		if (RSQDG_Reach.Metres(pmo.AttackPos - pmo.OffhandPos) > RSQDG_Reach.Num("rsqdg_swap_m", p, 0.25)) return false;
		double need = RSQDG_Reach.Num("rsqdg_swap_roll", p, 55.0);
		return abs(RSQDG_Reach.NormDeg(pmo.AttackRoll)) >= need && abs(RSQDG_Reach.NormDeg(pmo.OffhandRoll)) >= need;
	}

	// The nearest thing the palm is touching: a pickup, barrel or corpse the grab's table allows, or
	// (the off hand, rsqdg_collar) a living monster light enough to hold.
	static Actor FindNear(PlayerPawn pmo, PlayerInfo p, int h)
	{
		if (!On("rsqdg_near", p, true)) return null;
		Vector3 hp = RSQDG_Reach.Palm(pmo, h);
		double nearU = RSQDG_Reach.MetresToUnits(RSQDG_Reach.Num("rsqdg_near_m", p, 0.30));
		bool collarOn = h == 1 && On("rsqdg_collar", p, true);
		double maxMass = RSQDG_Reach.Num("rsqdg_collar_mass", p, 400.0);
		let pol = RSQDG_Policy.Get();
		let fl = RSQDG_Flight.Get();
		let hold = RSQDG_Hold.Get();
		Actor best = null;
		double bestD = 1e9;
		let it = BlockThingsIterator.CreateFromPos(hp.x, hp.y, hp.z, 128, 128, false);
		while (it.Next())
		{
			Actor a = it.thing;
			if (!a || a == pmo || a.player) continue;
			// the room distance from the palm to the thing's cylinder
			Vector2 dxy = a.Pos.xy - hp.xy;
			double hz = max(0.0, dxy.Length() - a.Radius);
			double vz = 0;
			if (hp.z < a.Pos.z) vz = a.Pos.z - hp.z;
			else if (hp.z > a.Pos.z + a.Height) vz = hp.z - (a.Pos.z + a.Height);
			double d = sqrt(hz * hz + (vz * RSQDG_Reach.PIXELSTRETCH) ** 2);
			if (d > nearU || d >= bestD) continue;
			if ((fl && fl.IsFlying(a)) || (hold && hold.IsHeld(a))) continue;
			bool ok = false;
			if (a.bISMONSTER && a.Health > 0)
				ok = collarOn && a.bSHOOTABLE && !a.bBOSS && !a.bNOINTERACTION && a.Mass <= maxMass;
			else
				ok = pol && pol.Decide(a, pmo, p) != null;
			if (!ok) continue;
			best = a;
			bestD = d;
		}
		return best;
	}

	// ---- the local loop ----------------------------------------------------------------------
	override void WorldTick()
	{
		TickSwaps();
		TickCollars();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			// a held object the hold let go of (a break, a death) is no longer ours
			let hold = RSQDG_Hold.Get();
			for (int h = 0; h < 2; h++)
				if (owns[n * 2 + h] && (!hold || n != consoleplayer || !hold.HandIsFull(h))) owns[n * 2 + h] = false;
		}
		let p = players[consoleplayer];
		ready[0] = false; ready[1] = false;
		if (!p || !p.mo || p.mo.health <= 0 || !On("rsqdg_on", p, true)) return;
		let pmo = p.mo;
		let hold = RSQDG_Hold.Get();
		let door = RSQDG_Door.Get();
		bool swap = SwapPose(pmo, p) && HasSwap(p);
		for (int h = 0; h < 2; h++)
		{
			if (RigBusy(pmo, h)) continue;     // holsters first
			int k = consoleplayer * 2 + h;
			ready[h] = swap || gripDown[k]
				|| (door && On("rsqdg_door_grip", p, true) && door.Touching(h))
				|| ((!hold || !hold.HandIsFull(h)) && FindNear(pmo, p, h) != null);
		}
	}

	// ---- the act (every machine) -----------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqdg_ngrip") return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let p = players[n];
		let pmo = p.mo;
		int h = e.Args[0];
		if (!pmo || (h != 0 && h != 1)) return;
		int k = n * 2 + h;
		bool down = e.Args[1] != 0;
		let hold = RSQDG_Hold.Get();
		if (!down)
		{
			gripDown[k] = false;
			if (owns[k] && hold && hold.HandIsFull(h)) hold.Release(h, p);
			owns[k] = false;
			if (h == 1 && collar[n]) EndCollar(n);
			return;
		}
		gripDown[k] = true;
		if (pmo.health <= 0) return;
		if (SwapPose(pmo, p) && HasSwap(p)) { DoSwap(n); return; }
		let door = RSQDG_Door.Get();
		if (door && n == consoleplayer && door.Touching(h)) return;   // door.zs takes the grip
		if (hold && hold.HandIsFull(h)) return;
		let a = FindNear(pmo, p, h);
		if (!a) return;
		if (a.bISMONSTER && a.Health > 0) { StartCollar(n, a); return; }
		let feel = RSQDG_Feel.Get();
		let inv = Inventory(a);
		if (inv && On("rsqdg_catch_takes", p, true))
		{
			double heft = RSQDG_Mass.Heft(a);
			bool took; Actor res;
			[took, res] = inv.CallTryPickup(pmo);
			if (took) { if (feel) feel.OnCatch(h, null, p, true, heft); return; }
		}
		if (hold && hold.Take(h, a, p))
		{
			owns[k] = true;
			if (feel) feel.OnCatch(h, a, p, false, RSQDG_Mass.Heft(a));
		}
	}

	// ---- SWAP HANDS --------------------------------------------------------------------------
	// A gun that can change hands: not a saber, shield, Force hand, empty-hand filler or fist.
	static bool Movable(Weapon w)
	{
		if (!w) return false;
		String c = w.GetClassName();
		c = c.MakeLower();
		if (c.IndexOf("ubqs_") == 0 || c.IndexOf("ssq_") == 0 || c == "rsq_hands") return false;
		if (w.bMELEEWEAPON) return false;
		let d = GetDefaultByType(w.GetClass());
		return d && !d.bOffhandWeapon;       // an off-hand-only copy (BD VR's dual guns) stays put
	}

	static bool HasSwap(PlayerInfo p) { return Movable(p.ReadyWeapon) || Movable(p.OffhandWeapon); }

	static Weapon EmptyHand(PlayerPawn pmo)
	{
		Weapon best = null;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || w.bOffhandWeapon || Movable(w)) continue;
			String c = w.GetClassName();
			c = c.MakeLower();
			if (c.IndexOf("ubqs_") == 0 || c.IndexOf("ssq_") == 0) continue;
			bool found; int slot, idx;
			[found, slot, idx] = pmo.player.weapons.LocateWeapon(w.GetClass());
			if (!found || slot != 1) continue;
			if (!best || w.SelectionOrder > best.SelectionOrder) best = w;
		}
		return best;
	}

	private void DoSwap(int n)
	{
		let p = players[n];
		let pmo = p.mo;
		Weapon mainGun = Movable(p.ReadyWeapon) ? p.ReadyWeapon : null;
		Weapon offGun = Movable(p.OffhandWeapon) ? p.OffhandWeapon : null;
		if (!mainGun && !offGun) return;
		if (offGun)
		{
			p.SetPsprite(PSP_OFFHANDWEAPON, null);
			p.OffhandWeapon = null;
			offGun.bOffhandWeapon = false;
			p.PendingWeapon = offGun;
		}
		else
		{
			let e = EmptyHand(pmo);
			if (e) p.PendingWeapon = e;
		}
		String hands = "RSQ_Hands";        // Brutal Doom VR's empty off hand, null without it
		class<Weapon> hc = hands;
		String next = "";
		if (mainGun) next = mainGun.GetClassName();
		else if (hc) next = hands;
		offNext[n] = next;
		offWait[n] = 70;
		pmo.A_StartSound("misc/w_pkup", CHAN_AUTO, CHANF_LOCAL, 0.5);
	}

	// Once the main hand has switched, raise the queued weapon into the off hand (as the rig does).
	private void TickSwaps()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (offNext[n] == "") continue;
			let p = players[n];
			if (!playeringame[n] || !p.mo || p.mo.health <= 0 || --offWait[n] <= 0) { offNext[n] = ""; continue; }
			if (p.PendingWeapon != WP_NOCHANGE) continue;
			class<Weapon> c = offNext[n];
			offNext[n] = "";
			if (!c) continue;
			let w = Weapon(p.mo.FindInventory(c));
			if (!w) { p.mo.GiveInventory(c, 1); w = Weapon(p.mo.FindInventory(c)); }
			if (!w || w == p.ReadyWeapon) continue;
			w.bOffhandWeapon = true;
			if (p.OffhandWeapon != w) p.PendingWeapon = w;
		}
	}

	// ---- HEADLOCK ----------------------------------------------------------------------------
	private void StartCollar(int n, Actor a)
	{
		if (collar[n]) EndCollar(n);
		let p = players[n];
		collar[n] = a;
		cNoGrav[n] = a.bNOGRAVITY;
		cThru[n] = a.bTHRUACTORS;
		a.bNOGRAVITY = true;
		a.bTHRUACTORS = true;
		a.Vel = (0, 0, 0);
		collarEnd[n] = level.maptime + int(RSQDG_Reach.Num("rsqdg_collar_secs", p, 3.0) * TICRATE);
		collarPing[n] = 0;
		let feel = RSQDG_Feel.Get();
		if (feel) feel.OnCatch(1, a, p, false, RSQDG_Mass.Heft(a));
	}

	private void EndCollar(int n)
	{
		let a = collar[n];
		collar[n] = null;
		if (!a) return;
		a.bNOGRAVITY = cNoGrav[n];
		a.bTHRUACTORS = cThru[n];
		if (a.Health > 0 && a.tics < 0) a.tics = 1;     // the frozen frame moves on
	}

	private void TickCollars()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			let a = collar[n];
			if (!a) continue;
			let p = players[n];
			if (!playeringame[n] || !p.mo || p.mo.health <= 0 || a.Health <= 0 || level.maptime >= collarEnd[n]
				|| !gripDown[n * 2 + 1]) { EndCollar(n); continue; }
			// held in front of the off hand, frozen in whatever frame it was in (a punch's pain frame
			// freezes too: it reads as stunned)
			Vector3 hp = RSQDG_Reach.Palm(p.mo, 1);
			Vector3 fw = RSQDG_Reach.Dir(p.mo, 1);
			Vector3 at = hp + fw * (a.Radius + 6.0);
			at.z -= a.Height * 0.5;
			if (RSQDG_Reach.Metres(at - a.Pos) > 1.5) { EndCollar(n); continue; }   // torn away
			if (!a.TryMove(at.xy, true)) { }
			a.SetZ(max(a.floorz, at.z));
			a.Vel = (0, 0, 0);
			a.tics = -1;
			// RSQ_Score: "grab.hold" touched it (kept alive every 2 s so the 3 s chain gap never breaks it)
			if (level.maptime >= collarPing[n])
			{
				collarPing[n] = level.maptime + 70;
				let sit = ServiceIterator.Find("RS_ScoreService");
				Service s;
				while (s = sit.Next()) s.GetInt("touch", "grab.hold", n, 0, a);
			}
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int n = 0; n < MAXPLAYERS; n++) if (collar[n]) EndCollar(n);
	}
}
