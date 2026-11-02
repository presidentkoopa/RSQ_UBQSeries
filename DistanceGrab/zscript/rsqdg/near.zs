// THE GRIP, UP CLOSE (the owner, 10-29). What a grip does with a hand that is touching
// something, and while it does it it comes first -- before the engine's two-hand steadying, before
// the distance reach -- so the grip press is EATEN (InputProcess returns true) whenever one of them
// takes it. A hand in a Tactical Rig holster is the rig's: holsters come before all of this.
//
//   (SWAP HANDS was here until 11-01: controllers together + grip is exactly QuestZDoom's own two-hand
//   latch on PCVR, which takes the press first, so it never worked in the owner's headset. Removed on his
//   order: the Tactical Rig moves a gun between hands -- holster with one, draw with the other.)
//   WALK-UP GRAB the grip with the palm within rsqdg_near_m of a thing takes it straight into the
//                hand: a pickup is used (as a caught pull is, rsqdg_catch_takes), a barrel or corpse
//                is carried until the grip is let go (moving: thrown), a door is lifted (door.zs).
//   (HEADLOCK, the off hand's grip on a living monster, moved to RSQ Melee on 2026-11-01: its headlock.zs.
//                ONE MOD DECIDES each off-grip press: Melee takes it when a holdable monster is nearer the palm
//                than anything this grab would take and this hand is not already ours. We ask Melee
//                ("headlock.claim", RSQML_Service) and stand down for that press; Melee asks us how near our
//                nearest is ("near.dist", RSQDG_ThrowService). A monster thrown out of the Headlock comes back
//                here to fly (throw.zs, "headlock.throw").)
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

	// The nearest thing the palm is touching: a pickup, barrel or corpse the grab's table allows (a living
	// monster is RSQ Melee's Headlock now, never ours), and its distance in map units (-1 none).
	static Actor FindNear(PlayerPawn pmo, PlayerInfo p, int h)
	{
		Actor a; double d;
		[a, d] = FindNearDist(pmo, p, h);
		return a;
	}
	static Actor, double FindNearDist(PlayerPawn pmo, PlayerInfo p, int h)
	{
		if (!On("rsqdg_near", p, true)) return null, -1;
		Vector3 hp = RSQDG_Reach.Palm(pmo, h);
		double nearU = RSQDG_Reach.MetresToUnits(RSQDG_Reach.Num("rsqdg_near_m", p, 0.30));
		let pol = RSQDG_Policy.Get();
		let fl = RSQDG_Flight.Get();
		let hold = RSQDG_Hold.Get();
		Actor best = null;
		double bestD = 1e9;
		// THE SWEEP IS THE REACH, NOT A BLOCKMAP CELL. checkradius is a half-extent, not a
		// diameter: the constructor keeps it as checkpoint.Z (p_maputl.cpp:1084) and the box is
		// setBox(x, y, that) (:1142), so 128 was a 256-unit box -- a 2x2 to 3x3 walk of 128-unit
		// cells, per hand, per tic, to find things 10.2 units away. nearU is enough on its own,
		// because an actor is linked into EVERY cell its radius touches and not just its centre
		// cell (p_maputl.cpp:518-529, "[RH] Link into every block this actor touches") and the test
		// below subtracts the radius -- so anything whose cylinder comes within nearU of the palm
		// already shares a cell with the box, whatever its radius, up to a Spider Mastermind
		// corpse. The + 8 is slack against the rounding in a diagonal corner and costs one cell at
		// most. checkh is left at 128: it is not the box, only the height the portal groups are
		// collected over (checkz + checkh, :1083).
		let it = BlockThingsIterator.CreateFromPos(hp.x, hp.y, hp.z, 128, nearU + 8, false);
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
			if (a.bISMONSTER && a.Health > 0) continue;
			if (!pol || pol.Decide(a, pmo, p) == null) continue;
			best = a;
			bestD = d;
		}
		return best, best ? bestD : -1;
	}

	// FOR RSQ MELEE'S HEADLOCK ("near.dist", throw.zs RSQDG_ThrowService): -2 while this hand is ours already
	// (its grip pressed for us, carrying, on a door, in a rig holster), else how near the palm our nearest
	// walk-up thing is in map units, -1 none.
	static double NearDist(PlayerPawn pmo, int h)
	{
		if (!pmo || !pmo.player || (h != 0 && h != 1)) return -1;
		let p = pmo.player;
		let n = Get();
		if (n && n.gripDown[pmo.PlayerNumber() * 2 + h]) return -2;
		if (!On("rsqdg_on", p, true) || RigBusy(pmo, h)) return -2;
		let hold = RSQDG_Hold.Get();
		if (hold && hold.HandIsFull(h)) return -2;
		let door = RSQDG_Door.Get();
		if (door && On("rsqdg_door_grip", p, true) && door.Touching(h)) return -2;
		Actor a; double d;
		[a, d] = FindNearDist(pmo, p, h);
		return d;
	}

	// RSQ Melee's Headlock takes this hand's press now (asked by name; 0 without Melee)
	static bool MeleeClaims(PlayerPawn pmo, int h)
	{
		if (h != 1) return false;
		let it = ServiceIterator.Find("RSQML_Service");
		Service s = it.Next();
		return s && s.GetInt("headlock.claim", "", h, 0, pmo) == 1;
	}

	// ---- the local loop ----------------------------------------------------------------------
	override void WorldTick()
	{
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
		bool two = RSQDG_Reach.TwoHanding(p);
		for (int h = 0; h < 2; h++)
		{
			if (RigBusy(pmo, h)) continue;     // holsters first
			int k = consoleplayer * 2 + h;
			// TWO-HANDING (reach.zs TwoHanding): the off grip is steadying the gun, not reaching for
			// what is next to it. A grip already held, or a hand already carrying, keeps what it has.
			if (two && !gripDown[k] && (!hold || !hold.HandIsFull(h))) continue;
			// a press RSQ Melee's Headlock takes is not ours (one mod decides; see the header)
			ready[h] = gripDown[k]
				|| (!MeleeClaims(pmo, h) && ((door && On("rsqdg_door_grip", p, true) && door.Touching(h))
				|| ((!hold || !hold.HandIsFull(h)) && FindNear(pmo, p, h) != null)));
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
			return;
		}
		gripDown[k] = true;
		if (pmo.health <= 0) return;
		let door = RSQDG_Door.Get();
		if (door && n == consoleplayer && door.Touching(h)) return;   // door.zs takes the grip
		if (hold && hold.HandIsFull(h)) return;
		let a = FindNear(pmo, p, h);
		if (!a) return;
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

	// (The HEADLOCK -- StartCollar, EndCollar, TickCollars, ThrowSwing and the release-on-load -- moved to RSQ
	// Melee's headlock.zs on 2026-11-01. The flight of a monster it throws is still ours: throw.zs "headlock.throw".)
}
