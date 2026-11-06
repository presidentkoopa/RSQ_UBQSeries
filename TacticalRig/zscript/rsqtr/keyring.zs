// THE KEYRING (owner 2026-10-31: "yes, i like this ... there are 3 keycards and 3 skull keys"): a steel ring on the
// front of your belt, beside the grenade spot on your off-hand side, with every key you carry hanging from it as the key
// itself -- its own pickup sprite, the voxel a voxel pack gives it, or a weapon pack's model of it -- small, in a
// little fan, swinging as you move. Look down and you see what you can open. Only you see it (it is this machine's
// own drawing); nothing about the keys changes. rsqtr_keyring.
// ITS OWN SPOT (owner 2026-11-01): where it hangs is the rig's place 8 (RSQTR_Region.KEYRING, rsqtr_r8_f / _l / _u /
// _rad), so it is moved by Move Holsters by Hand, saved in the holster profiles and shown as a sphere like the
// holsters. Its default is where it always hung. It is no gun holster: its grip does only the key doors below.

class RSQTR_Keyring : EventHandler
{
	const KEY_H = 0.08;         // a key's height, metres (bigger than life: it is read from 1.5 m away)
	const SPREAD = 0.045;       // between keys, metres (a voxel key is ~3 cm wide)
	const MAXK = 8;

	transient Actor ring;
	transient Actor keyShow[MAXK];
	transient Vector2 swing;    // the fan's sway, map units (follows the body's motion, springs back)

	// ---- KEYS TO A DOOR (owner's pick 17, 2026-10-31; off by default, rsqtr_key_doors) ----------------------------
	// Grip at the ring and the keys come off it into that hand (drawn there while the grip is held); touch them to a
	// locked door and it is used, through the engine's own lock check: Line.Activate(player, side, SPAC_Use)
	// (Quest teardown surveys/06_GRAB_INTERACTION.md 4.7: mapdata.zs:239 -> p_spec.cpp P_ActivateLine, which runs the
	// key check and the switch texture). No key that fits: the engine's own "you need a key" and nothing opens.
	// The touch is found on this machine (its hands), the door is opened in the sim from a network event.
	const TOUCH_M = 0.12;       // metres from the hand to the door's line that counts as touching it
	transient int keysIn;       // the hand holding the keys + 1 (0 = on the ring)
	transient bool gripWas[2];
	transient int gripUp[2];    // tics the keys' hand's grip has been up
	const GRIP_GRACE = 5;
	transient int lastLine, lastLineTic;

	// ---- THE KEYS IN THE OFF HAND (owner 2026-11-06, BUGS_1.0 item 39; both of his picks, under Keys Open Doors) -----
	// Grab the ring with the off hand (its grip, held: the keys stay in that hand while it is), take them to a locked door:
	//   FIRE (the off hand's trigger) = unlock and open: the door's own line used through the engine's lock check, as the
	//     touch does (rsqtr_keydoor). The off hand does not touch-open: it waits for the trigger.
	//   or HOLD ALT-FIRE AND RAISE THE HAND = lift the door: RSQ Distance Grab's door lift, driven through its own events
	//     by name (rsqdg_doorgrab / rsqdg_doorlift / rsqdg_doorrel: the door follows the hand, its key check is
	//     Distance Grab's, let go past its commit point and the door opens on its own). Without Distance Grab, or on a
	//     door it does not lift (a tagged one), raising the hand KEY_RAISE_M opens it as the trigger does.
	// While the off hand holds the keys its trigger and alt-fire are the keys' (eaten in InputProcess, so the off-hand
	// weapon does not fire). The main hand keeps the old touch-to-open.
	const KEY_REACH_M = 0.25;   // metres from the off hand to a locked door's line for the trigger / the lift
	const KEY_RAISE_M = 0.12;   // metres of raise that opens it without Distance Grab
	bool keyFire[MAXPLAYERS], keyAlt[MAXPLAYERS];   // synced: the off hand's trigger / alt-fire while it holds the keys
	transient bool fireWas, altWas;
	transient int liftLine;      // the door line being lifted (-1 none)
	transient bool liftDG;       // ...through Distance Grab's events
	transient double liftZ0, liftCeil0, liftSent;

	// ui: while this machine's off hand holds the keys, its trigger and alt-fire belong to them
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		String cmd = Bindings.GetBinding(e.KeyScan);
		bool f = cmd ~== "+oh_attack", a = cmd ~== "+oh_altatk";
		if (!f && !a) return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (keysIn != 2 && down) return false;      // not holding the keys: the gun's, as always
		EventHandler.SendNetworkEvent("rsqtr_keybtn", a ? 1 : 0, down ? 1 : 0);
		return keysIn == 2;
	}

	// a line whose use needs a key: a lock number (UDMF), or one of the locked specials' lock argument
	static bool IsLocked(Line ln)
	{
		if (!ln || !(ln.activation & SPAC_Use)) return false;
		if (ln.locknumber > 0) return true;
		switch (ln.special)
		{
			case 13:  return ln.args[3] > 0;     // Door_LockedRaise (tag, speed, delay, lock)
			case 202: return ln.args[4] > 0;     // Generic_Door (tag, speed, kind, delay, lock)
			case 83:  return ln.args[4] > 0;     // ACS_LockedExecute (script, map, a1, a2, lock)
			case 85:  return ln.args[4] > 0;     // ACS_LockedExecuteDoor
		}
		return false;
	}

	static double SegDist(Vector2 p, Line ln)
	{
		Vector2 a = ln.v1.p, d = ln.delta;
		double dd = d dot d;
		double f = dd > 0 ? clamp(((p - a) dot d) / dd, 0.0, 1.0) : 0.0;
		return (p - (a + d * f)).Length();
	}

	// this machine's hands: take the keys, touch a door
	private Vector3 KeysTick(PlayerPawn pmo, PlayerInfo p, RSQTR_Rig rig, Vector3 ringAt)
	{
		// (in Move Holsters by Hand the grip carries the ring instead)
		if (!RSQTR_Rig.Flag("rsqtr_key_doors", p, false) || RSQTR_Rig.Flag("rsqtr_edit", p, false)) { keysIn = 0; return ringAt; }
		double grab = rig.RegionRadius(p, RSQTR_Region.KEYRING);     // metres from the hand to the ring that takes the keys (its sphere)
		int n = consoleplayer;
		for (int h = 0; h < 2; h++)
		{
			bool g = rig.gripDown[n * 2 + h];
			bool press = g && !gripWas[h];
			gripWas[h] = g;
			if (press && RSQTR_Rig.Flag("rsqtr_messages", p, false))
				Console.Printf("T_KEYS grip %d t%d, %.2f m from the ring", h, level.maptime, RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), ringAt));
			if (press && keysIn == 0 && RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), ringAt) <= grab)
			{
				keysIn = h + 1;
				RSQTR_Buzzer.Start(pmo, h, 0.3, 3);
				if (RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_KEYS in hand %d t%d", h, level.maptime);
			}
			// let go for a few tics before the keys go back: QuestZDoom moves the off grip from one key to another while
			// the main grip is held (443 -> 436, its shift), and the off hand's alt-fire is the main grip + off trigger
			// ...and while the off hand's alt-fire is held (its own key route takes the off grip's key away), the keys stay
			if (g || (h == 1 && keyAlt[n])) gripUp[h] = 0;
			else if (keysIn == h + 1 && ++gripUp[h] >= GRIP_GRACE) keysIn = 0;
		}
		if (keysIn == 0) { EndLift(); return ringAt; }
		Vector3 hand = RSQTR_Body.Hand(pmo, keysIn - 1);
		if (keysIn == 2) { OffKeys(pmo, p, hand); return hand; }
		double reach = TOUCH_M * RSQTR_Body.Upm();
		let it = BlockLinesIterator.CreateFromPos(hand, 64, reach + 16);
		Line best = null; double bd = reach;
		while (it.Next())
		{
			let ln = it.CurLine;
			if (!IsLocked(ln)) continue;
			double dd = SegDist(hand.xy, ln);
			if (dd <= bd) { bd = dd; best = ln; }
		}
		if (best && (best.Index() != lastLine || level.maptime - lastLineTic > 35))
		{
			lastLine = best.Index(); lastLineTic = level.maptime;
			int side = level.PointOnLineSide(pmo.pos.xy, best);
			EventHandler.SendNetworkEvent("rsqtr_keydoor", best.Index(), side);
			RSQTR_Buzzer.Start(pmo, keysIn - 1, 0.6, 5);
		}
		return hand;
	}

	// the nearest locked door line within m metres of the hand, or null
	static Line LockedNear(Vector3 hand, double m)
	{
		double reach = m * RSQTR_Body.Upm();
		let it = BlockLinesIterator.CreateFromPos(hand, 64, reach + 16);
		Line best = null; double bd = reach;
		while (it.Next())
		{
			let ln = it.CurLine;
			if (!IsLocked(ln)) continue;
			double dd = SegDist(hand.xy, ln);
			if (dd <= bd) { bd = dd; best = ln; }
		}
		return best;
	}

	private static bool DGThere() { return ServiceIterator.Find("RSQDG_DoorService").Next() != null; }

	// a door RSQ Distance Grab lifts by hand: a manual door special (tag 0) with a sector behind it (its FindDoor rule)
	static bool DGLiftable(Line l)
	{
		if (!l || !l.backsector || l.args[0] != 0) return false;
		int sp = l.special;
		return sp == 11 || sp == 12 || sp == 13 || sp == 202;
	}

	private void EndLift()
	{
		if (liftLine >= 0 && liftDG) EventHandler.SendNetworkEvent("rsqdg_doorrel", liftLine);
		liftLine = -1;
	}

	// this machine's off hand holding the keys: the trigger opens, alt-fire held and a raise lifts
	private void OffKeys(PlayerPawn pmo, PlayerInfo p, Vector3 hand)
	{
		int n = consoleplayer;
		bool f = keyFire[n], a = keyAlt[n];
		bool fPress = f && !fireWas, aPress = a && !altWas;
		fireWas = f; altWas = a;
		bool log = RSQTR_Rig.Flag("rsqtr_messages", p, false);
		if (fPress)
		{
			Line l = LockedNear(hand, KEY_REACH_M);
			if (log) Console.Printf("T_KEYS t%d off-hand trigger: %s", level.maptime, l ? String.Format("locked door line %d", l.Index()) : "no locked door in reach");
			if (l)
			{
				EventHandler.SendNetworkEvent("rsqtr_keydoor", l.Index(), level.PointOnLineSide(pmo.pos.xy, l));
				RSQTR_Buzzer.Start(pmo, 1, 0.6, 5);
			}
			else RSQTR_Buzzer.Start(pmo, 1, 0.12, 2);
		}
		if (aPress && liftLine < 0)
		{
			Line l = LockedNear(hand, KEY_REACH_M);
			if (l)
			{
				liftLine = l.Index();
				liftDG = DGThere() && DGLiftable(l);
				liftZ0 = hand.z;
				Vector2 mid = l.v1.p + l.delta * 0.5;
				liftCeil0 = l.backsector ? l.backsector.ceilingplane.ZatPoint(mid) : 0;
				liftSent = liftCeil0;
				if (liftDG) EventHandler.SendNetworkEvent("rsqdg_doorgrab", liftLine);
				RSQTR_Buzzer.Start(pmo, 1, 0.4, 4);
				if (log) Console.Printf("T_KEYS t%d off-hand alt-fire on locked door line %d: %s", level.maptime, liftLine, liftDG ? "lifted by hand (RSQ Distance Grab)" : "raise to open");
			}
			else if (log) Console.Printf("T_KEYS t%d off-hand alt-fire: no locked door in reach", level.maptime);
		}
		if (liftLine >= 0)
		{
			if (!a) { if (log) Console.Printf("T_KEYS t%d alt-fire let go: door line %d released", level.maptime, liftLine); EndLift(); return; }
			double rise = hand.z - liftZ0;
			if (liftDG)
			{
				let gc = CVar.FindCVar("rsqdg_door_gain");
				double target = liftCeil0 + rise * (gc ? gc.GetFloat() : 2.5);
				if (abs(target - liftSent) >= 0.25)
				{
					EventHandler.SendNetworkEvent("rsqdg_doorlift", liftLine, int(target * 8));
					liftSent = target;
				}
			}
			else if (rise >= KEY_RAISE_M * RSQTR_Body.Upm())
			{
				Line l = level.Lines[liftLine];
				EventHandler.SendNetworkEvent("rsqtr_keydoor", liftLine, level.PointOnLineSide(pmo.pos.xy, l));
				RSQTR_Buzzer.Start(pmo, 1, 0.6, 5);
				if (log) Console.Printf("T_KEYS t%d raised %.2f m: door line %d opened", level.maptime, rise / RSQTR_Body.Upm(), liftLine);
				liftLine = -1;
			}
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "rsqtr_keybtn")
		{
			int b = e.Player;
			if (b < 0 || b >= MAXPLAYERS) return;
			if (e.Args[0] == 1) keyAlt[b] = e.Args[1] != 0;
			else keyFire[b] = e.Args[1] != 0;
			if (RSQTR_Rig.Flag("rsqtr_messages", players[b], false))
				Console.Printf("T_KEYS t%d off-hand %s %s (the keys')", level.maptime, e.Args[0] == 1 ? "alt-fire" : "trigger", e.Args[1] ? "down" : "up");
			return;
		}
		if (e.Name != "rsqtr_keydoor") return;
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo || pmo.health <= 0 || !RSQTR_Rig.Flag("rsqtr_key_doors", players[n], false)) return;
		int li = e.Args[0];
		if (li < 0 || li >= level.Lines.Size()) return;
		Line ln = level.Lines[li];
		// in arm's reach of the body, as the sim sees it: the event says which door, never lets a far one open
		if (!IsLocked(ln) || SegDist(pmo.pos.xy, ln) > pmo.radius + 48) return;
		bool ok = ln.Activate(pmo, e.Args[1] & 1, SPAC_Use);
		if (RSQTR_Rig.Flag("rsqtr_messages", players[n], false))
			Console.Printf("T_KEYDOOR t%d line %d: Line.Activate returned %d (the engine runs the lock check itself)", level.maptime, li, ok);
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p ? p.mo : null;
		let rig = RSQTR_Rig.Get();
		bool on = pmo && rig && pmo.health > 0 && RSQTR_Rig.Flag("rsqtr_keyring", p, true) && RSQTR_Rig.Flag("rsqtr_on", p, true);
		Array<Inventory> keys;
		if (on)
			for (let it = pmo.Inv; it && keys.Size() < MAXK; it = it.Inv)
				if (it is "Key" && it.Amount > 0) keys.Push(it);
		if (!on || keys.Size() == 0) { Hide(); return; }

		Vector3 at = rig.RegionAt(pmo, RSQTR_Region.KEYRING);   // its place (carried by the hand while it is moved)
		Vector3 keysAt = KeysTick(pmo, p, rig, at);
		let body = rig.GetBody();
		double yaw = (body && body.primed) ? body.yaw : pmo.angle;

		// the sway: the keys lag the body's motion a little and swing back
		swing = swing * 0.85 - pmo.vel.xy * 0.06;
		if (swing.Length() > 0.8) swing = swing.Unit() * 0.8;

		if (!ring) ring = Actor.Spawn("RSQTR_RingShow", at);
		if (ring)
		{
			ring.SetOrigin(at, true);
			ring.angle = yaw;
			ring.bINVISIBLE = false;
		}
		// the keys: a fan across the ring, each hanging from it, the middle one lowest
		double upm = RSQTR_Body.Upm();
		Vector2 across = (-sin(yaw), cos(yaw));       // the body's left
		int n = keys.Size();
		for (int k = 0; k < MAXK; k++)
		{
			if (k >= n) { if (keyShow[k]) keyShow[k].bINVISIBLE = true; continue; }
			if (!keyShow[k]) keyShow[k] = Actor.Spawn("RSQTR_KeyShow", at);
			let ks = RSQTR_KeyShow(keyShow[k]);
			if (!ks) continue;
			double off = (k - (n - 1) * 0.5) * SPREAD * upm;
			// a key stands on its origin, so it hangs with its top at the ring: its whole height below it
			double drop = (0.02 + KEY_H + 0.008 * abs(k - (n - 1) * 0.5)) * upm / RSQTR_Body.Ps();
			Vector3 kp = keysAt + (across.x * off + swing.x, across.y * off + swing.y, -drop);
			ks.Show(keys[k].GetClassName(), KEY_H * upm);
			ks.SetOrigin(kp, true);
			ks.angle = yaw + 180;     // facing you
		}
	}

	private void Hide()
	{
		EndLift();
		if (ring) ring.bINVISIBLE = true;
		for (int k = 0; k < MAXK; k++) if (keyShow[k]) keyShow[k].bINVISIBLE = true;
	}

	// The drawings are this machine's alone and held by transient pointers: a save carries orphans, cleared on load.
	override void OnRegister()
	{
		liftLine = -1;
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next())) if (a is "RSQTR_RingShow" || a is "RSQTR_KeyShow") a.Destroy();
	}
}

class RSQTR_RingShow : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP Radius 1; Height 1; }
	States { Spawn: RTKR A -1; Stop; }
}

// One key on the ring: the key's own pickup look (as RSQTR_Icon wears a gun's): its first visible Spawn frame, and the
// model a pack binds to the key class, if any.
class RSQTR_KeyShow : Actor
{
	String wearing;
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1; Stop; }

	// hUnits: how tall it should stand. A sprite's height in pixels at scale 1 is its height in map units.
	void Show(String cls, double hUnits)
	{
		if (cls != wearing)
		{
			wearing = cls;
			class<Actor> c = cls;
			let d = c ? GetDefaultByType(c) : null;
			State st = d ? d.SpawnState : null;
			int tnt = GetSpriteIndex('TNT1');
			for (int i = 0; i < 16 && st && st.sprite == tnt; i++) st = st.NextState;
			if (st && st.sprite != tnt)
			{
				sprite = st.sprite; frame = st.Frame;
				A_ChangeModel(Name(cls));
				let tex = st.GetSpriteTexture(0);
				double hpx = 16;
				if (tex.IsValid()) { Vector2 sz = TexMan.GetScaledSize(tex); hpx = max(4.0, sz.y); }
				double sc = hUnits / hpx * (d ? 1.0 / max(0.01, d.Scale.Y) : 1.0);
				Scale = (sc, sc) * (d ? d.Scale.Y : 1.0);
			}
			else { sprite = tnt; frame = 0; }
		}
		bINVISIBLE = false;
	}
}
