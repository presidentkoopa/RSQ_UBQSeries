// THE KEYRING (owner 2026-10-31: "yes, i like this ... there are 3 keycards and 3 skull keys"): a steel ring on the
// front of your belt, beside the grenade spot on your off-hand side, with every key you carry hanging from it as the key
// itself -- its own pickup sprite, the voxel a voxel pack gives it, or a weapon pack's model of it -- small, in a
// little fan, swinging as you move. Look down and you see what you can open. Only you see it (it is this machine's
// own drawing); nothing about the keys changes. rsqtr_keyring.

class RSQTR_Keyring : EventHandler
{
	const RING_F = 0.14;        // metres from the head, body frame (the rig's BodyPoint): in front of the belt
	const RING_L = 0.13;        // to the off-hand side, clear of the grenade spot on the buckle
	const RING_U = -0.70;
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
	const GRAB_M = 0.12;        // metres from the hand to the ring that takes the keys
	transient int keysIn;       // the hand holding the keys + 1 (0 = on the ring)
	transient bool gripWas[2];
	transient int lastLine, lastLineTic;

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
		if (!RSQTR_Rig.Flag("rsqtr_key_doors", p, false)) { keysIn = 0; return ringAt; }
		int n = consoleplayer;
		for (int h = 0; h < 2; h++)
		{
			bool g = rig.gripDown[n * 2 + h];
			bool press = g && !gripWas[h];
			gripWas[h] = g;
			if (press && RSQTR_Rig.Flag("rsqtr_messages", p, false))
				Console.Printf("T_KEYS grip %d t%d, %.2f m from the ring", h, level.maptime, RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), ringAt));
			if (press && keysIn == 0 && RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, h), ringAt) <= GRAB_M)
			{
				keysIn = h + 1;
				RSQTR_Buzzer.Start(pmo, h, 0.3, 3);
				if (RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_KEYS in hand %d t%d", h, level.maptime);
			}
			if (!g && keysIn == h + 1) keysIn = 0;
		}
		if (keysIn == 0) return ringAt;
		Vector3 hand = RSQTR_Body.Hand(pmo, keysIn - 1);
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

	override void NetworkProcess(ConsoleEvent e)
	{
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

		double side = RSQTR_Body.LayoutLeft() ? -1 : 1;     // the off-hand side: left for a right-hander
		Vector3 at = rig.BodyPoint(pmo, RING_F, RING_L * side, RING_U);
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
		if (ring) ring.bINVISIBLE = true;
		for (int k = 0; k < MAXK; k++) if (keyShow[k]) keyShow[k].bINVISIBLE = true;
	}

	// The drawings are this machine's alone and held by transient pointers: a save carries orphans, cleared on load.
	override void OnRegister()
	{
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
