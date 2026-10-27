// DOORS LIFTED BY HAND (the owner, 2026-10-26: "we grab a door and lift it open...
// unlock door speed to be equal to the speed we use to lift it").
//
// Put a hand flat on a door and take hold -- the grip, Use, or a palm turned out
// against it -- then lift. The door's ceiling follows your hand up at your hand's
// speed (capped, so a flick cannot throw it open, and wider doors are heavier).
// Keep holding until it is open far enough to mean it: let go past the commit point
// and the door finishes opening by its own special (so it waits and closes as that
// door always did, and keys are honoured); let go before it and the door drops shut.
//
// WHAT THE ENGINE GIVES, checked in the qzd17.3 source: Sector.MoveCeiling (moves a
// ceiling toward a height at a speed), Sector.ceilingdata (a door already moving),
// Line.Activate and Level.ExecuteSpecial (the door's own behaviour), Actor.CheckKeys.
//
// SCOPE, v1: manual doors (a door special with tag 0 -- Doom's ordinary doors),
// taken from their front face, and not while the door is already moving.
//
// NETPLAY: the hand exists on one machine, so that machine sends the grab, the lift
// height and the release as events; every machine moves the same ceiling the same way.

class RSQTR_Door : EventHandler
{
	const TOUCH = 7.0;          // map units from the hand to the door face
	const LIFT_CAP = 4.0;       // x the door's own speed

	// ---- synced: one held door per player -------------------------------------------
	int    dLine[MAXPLAYERS];   // line index, -1 none
	double dTarget[MAXPLAYERS];
	double dTop[MAXPLAYERS], dFloor[MAXPLAYERS], dSpeed[MAXPLAYERS];

	// ---- local (console player) ----------------------------------------------------
	private transient int    held[2];      // line index the hand holds, -1 none
	private transient double grabZ[2], startCeil[2], lastSent[2];
	private transient bool   pressWas[2], confirmed[2];
	private transient int    pendT[2], tried[2];
	private transient int    buzzT;

	static RSQTR_Door Get() { return RSQTR_Door(EventHandler.Find("RSQTR_Door")); }
	bool Holding(int h) const { return (h == 0 || h == 1) && held[h] >= 0; }

	override void OnRegister()
	{
		for (int i = 0; i < MAXPLAYERS; i++) dLine[i] = -1;
		held[0] = -1; held[1] = -1; tried[0] = -1; tried[1] = -1;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame)
		{
			// A save taken mid-lift: the hand that held the door is not in the save, so
			// the door is let go as if released (it finishes or drops by the same rule).
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (dLine[i] < 0) continue;
				if (playeringame[i] && players[i].mo && dLine[i] < Level.Lines.Size())
					Release(i, players[i].mo, Level.Lines[dLine[i]]);
				dLine[i] = -1;
			}
			return;
		}
		for (int i = 0; i < MAXPLAYERS; i++) dLine[i] = -1;
		held[0] = -1; held[1] = -1; tried[0] = -1; tried[1] = -1;
	}

	static bool IsDoorSpecial(int sp)
	{
		return sp == 11 || sp == 12 || sp == 13 || sp == 202;   // Door_Open, Door_Raise, Door_LockedRaise, Generic_Door
	}

	static int LockOf(Line l)
	{
		if (l.special == 13) return l.args[3];
		if (l.special == 202) return l.args[4];
		return l.locknumber;
	}

	// Speed in map units per tic: the special's own (eighths of a unit per tic).
	static double SpeedOf(Line l)
	{
		int s = l.args[1];
		return s > 0 ? s / 8.0 : 2.0;
	}

	static Vector2 Mid(Line l) { return l.v1.p + l.delta * 0.5; }

	// The door face a hand is on: a manual door line within TOUCH of the hand, the
	// hand on its front side and inside the doorway's height.
	static Line FindDoor(PlayerPawn pmo, Vector3 hand)
	{
		let it = BlockLinesIterator.CreateFromPos(hand, 8, TOUCH * 2);
		Line best = null;
		double bestD = TOUCH;
		while (it.Next())
		{
			Line l = it.CurLine;
			if (!l || !IsDoorSpecial(l.special) || l.args[0] != 0 || !l.backsector) continue;
			if (Level.PointOnLineSide(hand.xy, l) != 0) continue;   // the front face only
			// distance from the hand to the segment, in 2D
			Vector2 a = l.v1.p, d = l.delta;
			double len2 = d dot d;
			if (len2 < 1) continue;
			double t = clamp(((hand.xy - a) dot d) / len2, 0.0, 1.0);
			double dist = (hand.xy - (a + d * t)).Length();
			if (dist < bestD) { bestD = dist; best = l; }
		}
		return best;
	}

	// ---- the local loop ----------------------------------------------------------------
	override void WorldTick()
	{
		ApplyAll();

		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return;
		let pmo = p.mo;
		if (!RSQTR_Rig.Flag("rsqtr_door", p, true)) return;
		let rig = RSQTR_Rig.Get();
		int n = consoleplayer;

		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		for (int h = 0; h < 2; h++)
		{
			Vector3 hp = RSQTR_Body.Hand(pmo, h);
			bool grip = rig && RSQTR_Rig.Flag("rsqtr_door_grip", p, true) && rig.gripDown[n * 2 + h];
			bool use = RSQTR_Rig.Flag("rsqtr_door_use", p, true) && useDown;
			bool palm = RSQTR_Rig.Flag("rsqtr_door_palm", p, true) && PalmOut(pmo, h);
			bool pressing = grip || use || palm;
			// A hand inside a rig region is reaching for a weapon, not a door.
			if (rig && rig.HoverRegion(h) >= 0) pressing = false;

			if (!pressing) tried[h] = -1;
			if (held[h] < 0)
			{
				bool start = pressing && !pressWas[h];
				// a palm turned out against the door takes hold the moment it touches
				bool palmTouch = !start && palm;
				if (start || palmTouch)
				{
					Line l = FindDoor(pmo, hp);
					// a door that refused this hand (locked, already moving) is not asked
					// again every tic while a palm stays on it; a fresh press asks again
					if (l && palmTouch && l.Index() == tried[h]) l = null;
					if (l && dLine[n] < 0)
					{
						EventHandler.SendNetworkEvent("rsqtr_doorgrab", l.Index());
						held[h] = l.Index();
						confirmed[h] = false;
						pendT[h] = 0;
						grabZ[h] = hp.z;
						startCeil[h] = l.backsector.ceilingplane.ZatPoint(Mid(l));
						lastSent[h] = startCeil[h];
					}
				}
			}
			else
			{
				bool mine = dLine[n] == held[h];
				if (mine && !confirmed[h])
				{
					// the grab arrived (in netplay a few tics after it was sent)
					confirmed[h] = true;
					Line l = Level.Lines[held[h]];
					startCeil[h] = l.backsector.ceilingplane.ZatPoint(Mid(l));
					lastSent[h] = startCeil[h];
					grabZ[h] = hp.z;
					RSQTR_Buzzer.Start(pmo, h, 0.35, 4);
				}
				if (!pressing)
				{
					// sent even before the grab is confirmed: events arrive in order, and
					// the release only acts on the door this player holds
					EventHandler.SendNetworkEvent("rsqtr_doorrel", held[h]);
					held[h] = -1;
				}
				else if (!mine)
				{
					// refused, or taken from us (another mover, death): let it be
					if (confirmed[h] || ++pendT[h] > 35) { tried[h] = held[h]; held[h] = -1; }
				}
				else
				{
					double target = startCeil[h] + (hp.z - grabZ[h]) * RSQTR_Rig.Num("rsqtr_door_gain", p, 2.5);
					if (abs(target - lastSent[h]) >= 0.25)
					{
						EventHandler.SendNetworkEvent("rsqtr_doorlift", held[h], int(target * 8));
						lastSent[h] = target;
					}
					// The rumble rises as the door opens.
					Line l = Level.Lines[held[h]];
					double cur = l.backsector.ceilingplane.ZatPoint(Mid(l));
					double frac = dTop[n] > dFloor[n] ? clamp((cur - dFloor[n]) / (dTop[n] - dFloor[n]), 0.0, 1.0) : 0;
					if (++buzzT % 4 == 0) RSQTR_Buzzer.Start(pmo, h, 0.10 + 0.35 * frac, 3);
				}
			}
			pressWas[h] = pressing;
		}
	}

	// The palm turned out, the grab's own convention (rsqdg_palm_roll / _tol when the
	// grab is loaded, the same defaults when not).
	static bool PalmOut(PlayerPawn pmo, int h)
	{
		double roll = (h == 0) ? pmo.AttackRoll : pmo.OffhandRoll;
		roll = roll - floor((roll + 180.0) / 360.0) * 360.0;
		let p = pmo.player;
		double tgt = RSQTR_Rig.Num("rsqdg_palm_roll", p, 90.0);
		double tol = RSQTR_Rig.Num("rsqdg_palm_tol", p, 30.0);
		return abs(abs(roll) - tgt) <= tol;
	}

	// ---- every machine ----------------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;
		int li = e.Args[0];
		if (li < 0 || li >= Level.Lines.Size()) return;
		Line l = Level.Lines[li];
		if (e.Name == "rsqtr_doorgrab") Grab(n, pmo, l);
		else if (e.Name == "rsqtr_doorlift") { if (dLine[n] == li) dTarget[n] = e.Args[1] / 8.0; }
		else if (e.Name == "rsqtr_doorrel") { if (dLine[n] == li) Release(n, pmo, l); }
	}

	private void Grab(int n, PlayerPawn pmo, Line l)
	{
		if (!IsDoorSpecial(l.special) || l.args[0] != 0 || !l.backsector) return;
		Sector sec = l.backsector;
		if (sec.ceilingdata && !TakeOver(sec, l)) return;    // already moving: not ours to take
		int lock = LockOf(l);
		if (lock > 0 && !pmo.CheckKeys(lock, false)) return;  // the normal locked message
		double top;
		Vertex vv;
		[top, vv] = sec.FindLowestCeilingSurrounding();
		dTop[n] = top - 4;
		dFloor[n] = sec.floorplane.ZatPoint(Mid(l));
		dTarget[n] = sec.ceilingplane.ZatPoint(Mid(l));
		// Heavier when wider: a 64-unit door at the plain cap, a 128-unit one at half.
		double len = l.delta.Length();
		dSpeed[n] = SpeedOf(l) * LIFT_CAP * clamp(64.0 / max(len, 1.0), 0.4, 1.5);
		dLine[n] = l.Index();
		pmo.A_StartSound("rsqtr/doorgrab", CHAN_AUTO, 0, 0.7);
	}

	// Use is also the engine's own "open this door", and the player's think runs
	// before this handler hears of the grab, so a Use press on a door has always just
	// started it opening. A door that only began rising in the last few tics is taken
	// over: its mover is stopped and the hand has it. Anything further along is left.
	static bool TakeOver(Sector sec, Line l)
	{
		let d = Door(sec.ceilingdata);
		if (!d || d.m_Direction != Door.dirUp) return false;
		double cur = sec.ceilingplane.ZatPoint(Mid(l));
		double flo = sec.floorplane.ZatPoint(Mid(l));
		if (cur - flo > d.m_Speed * 6 + 1) return false;
		d.Destroy();
		return sec.ceilingdata == null;
	}

	private void Release(int n, PlayerPawn pmo, Line l)
	{
		dLine[n] = -1;
		Sector sec = l.backsector;
		if (!sec) return;
		double cur = sec.ceilingplane.ZatPoint(Mid(l));
		double frac = dTop[n] > dFloor[n] ? (cur - dFloor[n]) / (dTop[n] - dFloor[n]) : 0;
		double commit = RSQTR_Rig.Num("rsqtr_door_commit", players[n], 0.4);
		if (frac >= commit)
		{
			// The door's own special finishes it: it opens the rest of the way at its
			// own speed, waits, and closes as it always did.
			l.Activate(pmo, 0, SPAC_Use);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.8, 6);
		}
		else if (cur > dFloor[n] + 0.5)
		{
			// Not far enough: it drops shut (Door_Close on this line's door).
			Level.ExecuteSpecial(10, pmo, l, false, 0, int(SpeedOf(l) * 8));
		}
	}

	// Move every held door toward its hand's height, at most its capped speed a tic.
	private void ApplyAll()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (dLine[n] < 0) continue;
			if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0) { dLine[n] = -1; continue; }
			Line l = Level.Lines[dLine[n]];
			Sector sec = l.backsector;
			if (!sec || sec.ceilingdata) { dLine[n] = -1; continue; }   // something else took it
			double cur = sec.ceilingplane.ZatPoint(Mid(l));
			double dest = clamp(dTarget[n], dFloor[n], dTop[n]);
			double diff = dest - cur;
			if (abs(diff) < 0.05) continue;
			double sp = min(abs(diff), dSpeed[n]);
			sec.MoveCeiling(sp, dest, -1, diff > 0 ? 1 : -1, false);
		}
	}
}
