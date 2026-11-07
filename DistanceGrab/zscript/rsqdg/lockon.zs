// BARREL LOCK-ON (owner 2026-11-07 10:41-11:1x, design/PARKED.md "Barrel lock-on" and its "Lock-on answers").
//
//   - ONE LOCK PER PLAYER, set by either free palm, used by either hand. A free palm is a hand whose palm the grab's own
//     gate passes (reach.zs PalmOk: a gun hand turned sideways counts) and that carries and pulls nothing.
//   - The palm cone picks the MONSTER over an item when the other hand holds a barrel, or you stand within punching
//     reach of a barrel (Doom's own punch range, MELEERANGE 64 map units, from your body to the barrel's side);
//     otherwise the cone finds items as before.
//   - Sticky: taking a lock needs the grab's cone (Aim Width, 12 degrees); keeping it needs twice that (24). The palm on
//     another monster takes the lock at once. With no palm on it the lock holds 3 s, then 0.5 s of grace in which a
//     throw or an uppercut still goes to that monster (or where it last was). Look: the grab's green "have" glow (tell.zs),
//     while the lock holds (not in the grace).
//   - A BARREL thrown with a lock (hold.zs Release) is solved onto the locked monster and STEERED in flight after it: it
//     always lands. How hard the swing was sets its speed across the ground (harder = flatter, faster, more impact); the
//     softest it may go is the 45-degree lob that reaches (the slowest throw that can). A still release still sets it
//     down. Steering is for barrels only (MASSDEF `impact explode`); anything else keeps the throw's aim assist. A lower
//     ceiling ahead (a door's lintel) caps its climb as it caps a pull's (flight.zs Duck, the Duck Under Doors row).
//   - RSQ Melee's uppercut barrel asks by name (throw.zs RSQDG_ThrowService "lockon.kick"): with a lock roughly ahead
//     (within 60 degrees of the kick's way, the throw's own "forward" gate, aim.zs ThrowVelocity) the barrel goes to it
//     the same way and is watched as a throw: impact, stagger, blast. Otherwise Melee kicks it where you punched.
//
// Like the rest of the grab, the hands are the console player's own: the lock is decided on that machine.
// Registered right after RSQDG_Aim (MAPINFO): the cone's item pick on a hand that is on a monster is taken away
// before RSQDG_Grab reads it.
class RSQDG_LockOn : EventHandler
{
	const HOLD_TICS  = 105;   // 3 s with no palm on it
	const GRACE_TICS = 18;    // then 0.5 s (17.5 tics) of grace
	const PUNCH_RANGE = 64.0; // Doom's MELEERANGE: how far the fist reaches from the body (A_Punch)
	const AHEAD_DEG  = 60.0;  // "roughly ahead": the throw's forward gate (aim.zs ThrowVelocity)
	const MAX_STEER  = 8;

	private Actor   mon;         // the lock
	private Vector3 lastPos;     // its middle, last seen
	private int     offTics;     // tics with no palm on it
	private int     setBy;       // the hand that set it (log only)

	// steered barrels
	private Actor   sA[MAX_STEER];
	private Actor   sT[MAX_STEER];
	private Vector3 sPos[MAX_STEER];
	private double  sHs[MAX_STEER];
	private int     sAge[MAX_STEER];
	private bool    sKick[MAX_STEER];

	static RSQDG_LockOn Get()
	{
		return RSQDG_LockOn(EventHandler.Find("RSQDG_LockOn"));
	}

	static bool On(PlayerInfo p)
	{
		return p && RSQDG_Reach.Flag("rsqdg_on", p, true) && RSQDG_Reach.Flag("rsqdg_lockon", p, true);
	}

	// the lock while it shows (the glow): null in the grace and without one
	Actor Shown() const
	{
		return (mon && offTics <= HOLD_TICS) ? mon : null;
	}

	// where a throw or an uppercut goes: the lock or, in the grace, the monster or where it last was. false: no lock.
	bool, Actor, Vector3 Target() const
	{
		if (offTics > HOLD_TICS + GRACE_TICS) return false, null, (0, 0, 0);
		if (mon && mon.Health > 0) return true, mon, Mid(mon);
		if (lastPos != (0, 0, 0) && offTics > HOLD_TICS) return true, null, lastPos;
		return false, null, (0, 0, 0);
	}

	static bool IsBarrel(Actor a)
	{
		return a && (RSQDG_Mass.Flags(a) & RSQDG_Mass.FLIGHT_EXPLODE) && a.bSHOOTABLE && a.Health > 0 && !a.bISMONSTER;
	}

	static Vector3 Mid(Actor a)
	{
		return (a.Pos.x, a.Pos.y, a.Pos.z + a.Height * 0.5);
	}

	private static bool Lockable(Actor t, PlayerPawn pmo)
	{
		return t && t != pmo && !t.player && t.bISMONSTER && t.Health > 0 && t.bSHOOTABLE && !t.bFRIENDLY && !t.bDORMANT
			&& !RSQDG_Throw.Helper(t);
	}

	// degrees between a hand's aim and a thing's middle, in the room (the cone's own measure, cone.zs)
	private static double OffAxis(PlayerPawn pmo, int h, Actor t, out double dist)
	{
		Vector3 o = RSQDG_Reach.AimPalm(pmo, h);
		Vector3 dir = RSQDG_Reach.AimDir(pmo, h);
		Vector3 d = Mid(t) - o;
		Vector3 pd = (d.x, d.y, d.z * RSQDG_Reach.PIXELSTRETCH);
		dist = pd.Length();
		if (dist < 0.01 || dir.Length() < 1e-6) return 180;
		return acos(clamp((pd / dist) dot dir.Unit(), -1, 1));
	}

	// the monster this palm is on: the one nearest its line inside `cone` degrees, in reach and (Line of Sight) in view
	private Actor BestMonster(PlayerPawn pmo, PlayerInfo p, int h, double cone)
	{
		double reach = RSQDG_Reach.Num("rsqdg_reach", p, 512.0);
		if (reach <= 0 || cone <= 0) return null;
		bool sightOn = RSQDG_Reach.Flag("rsqdg_sight", p, true);
		Vector3 o = RSQDG_Reach.AimPalm(pmo, h);
		Actor best = null;
		double bestAng = cone;
		let it = BlockThingsIterator.CreateFromPos(o.x, o.y, o.z, reach, reach, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!Lockable(t, pmo)) continue;
			double dist;
			double ang = OffAxis(pmo, h, t, dist);
			if (dist > reach || ang > bestAng) continue;
			if (sightOn && !pmo.CheckSight(t, SF_IGNOREVISIBILITY)) continue;
			best = t; bestAng = ang;
		}
		return best;
	}

	// for the refusal log: the monster nearest this palm's line, and the first test it fails
	private String Explain(PlayerPawn pmo, PlayerInfo p, int h, double cone)
	{
		double reach = RSQDG_Reach.Num("rsqdg_reach", p, 512.0);
		Vector3 o = RSQDG_Reach.AimPalm(pmo, h);
		Actor best = null; double bestAng = 1e9, bestDist = 0;
		let it = BlockThingsIterator.CreateFromPos(o.x, o.y, o.z, reach * 2, reach * 2, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || !t.bISMONSTER || t.Health <= 0) continue;
			double dist;
			double ang = OffAxis(pmo, h, t, dist);
			if (ang < bestAng) { best = t; bestAng = ang; bestDist = dist; }
		}
		if (!best) return "no living monster near";
		String who = best.GetClassName();
		if (!Lockable(best, pmo)) return who .. " is not lockable (friendly, dormant or a hitbox)";
		if (bestAng > cone) return String.Format("%s is %.1f deg off the palm's line (the cone is %.0f)", who, bestAng, cone);
		if (bestDist > reach) return String.Format("%s is %.0f units away (reach %.0f)", who, bestDist, reach);
		if (RSQDG_Reach.Flag("rsqdg_sight", p, true) && !pmo.CheckSight(best, SF_IGNOREVISIBILITY)) return who .. " is behind a wall (Line of Sight)";
		return who .. " should be lockable";
	}

	// a barrel within Doom's punch range of your body (its side, not its middle), standing on your level
	private static bool NearBarrel(PlayerPawn pmo)
	{
		let hold = RSQDG_Hold.Get();
		let fl = RSQDG_Flight.Get();
		let it = BlockThingsIterator.Create(pmo, PUNCH_RANGE + 32);
		while (it.Next())
		{
			Actor b = it.thing;
			if (!IsBarrel(b) || (hold && hold.IsHeld(b)) || (fl && fl.IsFlying(b))) continue;
			if ((b.Pos.xy - pmo.Pos.xy).Length() - b.Radius > PUNCH_RANGE) continue;
			if (b.Pos.z > pmo.Pos.z + pmo.Height || b.Pos.z + b.Height < pmo.Pos.z) continue;
			return true;
		}
		return false;
	}

	// THE REFUSAL LOG (rsqdg_trace, Report Refusals): why a palm turned out took no monster, said when it changes
	private transient String traced[2];
	private void Trace(PlayerInfo p, int h, String why)
	{
		if (why == traced[h]) return;
		traced[h] = why;
		if (why != "" && RSQDG_Reach.Flag("rsqdg_trace", p, false))
			Console.Printf("[RSQDG] t%d lock-on: hand %d -- %s", level.maptime, h, why);
	}

	private void Clear(PlayerInfo p, String why)
	{
		if (mon && RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] t%d lock-on: let go of %s -- %s", level.maptime, mon.GetClassName(), why);
		mon = null; lastPos = (0, 0, 0); offTics = 0;
	}

	override void WorldTick()
	{
		TickSteer();

		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.Health <= 0 || !On(p)) { if (mon || lastPos != (0, 0, 0)) Clear(p, "off"); return; }
		let pmo = p.mo;
		let aim = RSQDG_Aim.Get();
		if (!aim || !aim.PoseGood()) return;   // a bad pose keeps everything as it was
		let hold = RSQDG_Hold.Get();
		let fl = RSQDG_Flight.Get();
		bool dbg = RSQDG_Reach.Flag("rsqdg_debug", p, false);

		// the lock died or left the grab's keeping range (grab.zs ValidateLock's 1.25 x reach)
		// (in the grace a throw still goes where it last was: lastPos stays)
		if (mon && (mon.Health <= 0 || !mon.bSHOOTABLE))
		{
			if (offTics > HOLD_TICS) mon = null;
			else Clear(p, "it died");
		}
		if (mon)
		{
			double d;
			OffAxis(pmo, 0, mon, d);
			if (d > RSQDG_Reach.Num("rsqdg_reach", p, 512.0) * 1.25) Clear(p, "out of range");
		}

		double spread = RSQDG_Reach.Num("rsqdg_spread", p, 12.0);
		bool near = NearBarrel(pmo);
		bool kept = false;
		for (int h = 0; h < 2; h++)
		{
			if (!RSQDG_Reach.PalmOk(pmo, p, h)) continue;
			if ((hold && hold.HandIsFull(h)) || (fl && fl.Flying(h))) continue;
			bool prefer = near || (hold && IsBarrel(hold.HeldBy(1 - h)));
			double dl;
			double lockAng = mon ? OffAxis(pmo, h, mon, dl) : 180;
			bool onLock = mon && lockAng <= spread * 2.0;
			if (prefer)
			{
				Actor cand = BestMonster(pmo, p, h, spread);
				if (!cand && RSQDG_Reach.Flag("rsqdg_trace", p, false)) Trace(p, h, "no monster in the cone (" .. Explain(pmo, p, h, spread) .. ")");
				else if (cand) Trace(p, h, "");
				if (cand && cand != mon && !(mon && lockAng <= spread))
				{
					if (dbg) Console.Printf("[RSQDG] t%d lock-on: hand %d LOCKED %s%s (%.1f deg)%s", level.maptime, h, cand.GetClassName(),
						mon ? " (took it from " .. mon.GetClassName() .. ")" : "", OffAxis(pmo, h, cand, dl), near ? ", a barrel in punching reach" : ", the other hand holds a barrel");
					mon = cand; setBy = h; onLock = true;
				}
				// the monster wins over an item: this hand's item pick is taken away
				if (cand || onLock) aim.Suppress(h);
			}
			else Trace(p, h, "no barrel in the other hand nor in punching reach: the cone finds items");
			if (onLock) kept = true;
		}
		// no monster: only a grace that outlived it (died or gone in the grace) runs on, to its end
		if (!mon)
		{
			if (lastPos != (0, 0, 0) && (offTics <= HOLD_TICS || ++offTics > HOLD_TICS + GRACE_TICS)) { lastPos = (0, 0, 0); offTics = 0; }
			return;
		}
		lastPos = Mid(mon);
		if (kept)
		{
			if (dbg && offTics > 0) Console.Printf("[RSQDG] t%d lock-on: palm back on %s after %d tics", level.maptime, mon.GetClassName(), offTics);
			offTics = 0;
			return;
		}
		offTics++;
		if (dbg && offTics == 1) Console.Printf("[RSQDG] t%d lock-on: no palm on %s -- holds 3 s", level.maptime, mon.GetClassName());
		if (dbg && offTics == HOLD_TICS + 1) Console.Printf("[RSQDG] t%d lock-on: %s grace 0.5 s", level.maptime, mon.GetClassName());
		if (offTics > HOLD_TICS + GRACE_TICS) Clear(p, "3.5 s with no palm on it");
	}

	// ---- the barrel to the lock ----------------------------------------------

	// The velocity that lands `a` on the lock's middle at `hs` map units a tic across the ground (at least the
	// 45-degree lob that reaches it), under the air's real gravity (throw.zs Air). Registers the steering. false: no
	// lock (nothing changed).
	bool, Vector3 Send(PlayerInfo p, Actor a, double hs, bool kick)
	{
		if (!a || !p || !On(p) || !IsBarrel(a)) return false, (0, 0, 0);
		bool have; Actor t; Vector3 at;
		[have, t, at] = Target();
		if (!have) return false, (0, 0, 0);
		Vector3 v = Solve(p, a, at, hs);
		int slot = -1, oldest = 0;
		for (int i = 0; i < MAX_STEER; i++)
		{
			if (sA[i] == a) { slot = i; break; }
			if (!sA[i] && slot < 0) slot = i;
			if (sAge[i] > sAge[oldest]) oldest = i;
		}
		if (slot < 0) slot = oldest;
		sA[slot] = a; sT[slot] = t; sPos[slot] = at; sHs[slot] = v.xy.Length(); sAge[slot] = 0; sKick[slot] = kick;
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] t%d lock-on: %s %s to %s, %.0f units, %.1f m/s across%s", level.maptime, kick ? "uppercut" : "threw",
				a.GetClassName(), t ? t.GetClassName() : 'its_last_spot', (at.xy - a.Pos.xy).Length(),
				v.xy.Length() / RSQDG_Reach.UNITS_PER_METRE_XY * TICRATE, offTics > HOLD_TICS ? " (grace)" : "");
		return true, v;
	}

	private static double GravityOf(PlayerInfo p, Actor a)
	{
		return a.GetGravity() * clamp(RSQDG_Reach.Num("rsqdg_air_gravity", p, 0.27), 0.0, 1.0);
	}

	// UNDER THE CEILINGS ON THE WAY (a window's or a door's top): an arc whose top would meet a lower ceiling between
	// here and the lock is thrown flatter -- faster across the ground, 15% a step, up to five times -- until it passes
	// under (the rig, 11-07: a 7 m/s lob through a window met the wall above it). A gap it cannot fit through (a wall,
	// a closed door) is not looked at: that is a wall's business, as for a pull (flight.zs Duck).
	const PATH_STEP = 8.0;
	const CEIL_MARGIN = 2.0;
	private static Vector3 Solve(PlayerInfo p, Actor a, Vector3 at, double hs)
	{
		Vector2 d = at.xy - a.Pos.xy;
		double dl = d.Length();
		double g = GravityOf(p, a);
		if (dl < 1.0) return (0, 0, 0);
		hs = max(hs, sqrt(g * dl * 0.5));   // the 45-degree lob is the softest throw that reaches
		double dz = at.z - (a.Pos.z + a.Height * 0.5);
		Vector2 u = d / dl;
		double vz = 0;
		for (int tries = 0; tries <= 12; tries++)
		{
			double tt = max(1.0, dl / hs);
			vz = dz / tt + 0.5 * g * tt;
			bool clear = true;
			for (double sd = PATH_STEP; sd < dl && clear; sd += PATH_STEP)
			{
				Vector2 xy = a.Pos.xy + u * sd;
				Sector sec = level.PointInSector(xy);
				if (!sec) continue;
				double ceil = sec.ceilingplane.ZatPoint(xy), flr = sec.floorplane.ZatPoint(xy);
				if (ceil - flr < a.Height + CEIL_MARGIN) continue;
				double ts = sd / hs;
				if (a.Pos.z + vz * ts - 0.5 * g * ts * ts + a.Height > ceil - CEIL_MARGIN) clear = false;
			}
			if (clear) break;
			hs *= 1.15;
		}
		return (u.x * hs, u.y * hs, vz);
	}

	// IN FLIGHT: re-solved every tic onto where the monster is now, at the speed it left with. Steering ends when it hits
	// something (its speed across the ground halves: a wall, a body; the throw's watcher takes the impact), lands short,
	// is taken back, or the throw's watcher lets it go.
	private void TickSteer()
	{
		let p = players[consoleplayer];
		let th = RSQDG_Throw.Get();
		let hold = RSQDG_Hold.Get();
		let fl = RSQDG_Flight.Get();
		for (int i = 0; i < MAX_STEER; i++)
		{
			Actor a = sA[i];
			if (!a) continue;
			sAge[i]++;
			String why = "";
			if (a.Health <= 0 || !a.bSHOOTABLE) why = "it went off";
			else if ((hold && hold.IsHeld(a)) || (fl && fl.IsFlying(a))) why = "taken back";
			else if (!th || !th.Watching(a)) why = "landed";
			else if (sAge[i] > 1 && a.Vel.xy.Length() < sHs[i] * 0.5) why = "hit something";
			else if (sAge[i] > 3 && a.Pos.z <= a.floorz + 1 && a.Vel.z <= 0) why = "on the floor";
			if (why == "")
			{
				Actor t = sT[i];
				if (t && t.Health > 0) sPos[i] = Mid(t);
				Vector2 d = sPos[i].xy - a.Pos.xy;
				double reachXY = a.Radius + (t ? t.Radius : 0);
				if (d.Length() <= reachXY) why = "arrived";
				else
				{
					a.Vel = Solve(p, a, sPos[i], sHs[i]);
					sHs[i] = max(sHs[i], a.Vel.xy.Length());
					// under a lower ceiling ahead (a door's lintel) the climb is capped, as a pull's is (Duck Under Doors)
					RSQDG_Flight.Duck(a, p);
				}
			}
			if (why != "")
			{
				// it met the locked monster (arrived on it, or stopped against it): the blow lands now (throw.zs ImpactNow)
				Actor t = sT[i];
				bool met = (why == "arrived" || why == "hit something") && t && t.Health > 0 && Meets(a, t);
				if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
					Console.Printf("[RSQDG] t%d lock-on: steering of %s ends -- %s%s (%d tics; %s %.0f units off, bodies %.0f + %.0f)", level.maptime,
						a.GetClassName(), why, met ? " on " .. t.GetClassName() : "", sAge[i], t ? t.GetClassName() : 'its_last_spot',
						t ? (t.Pos.xy - a.Pos.xy).Length() : (sPos[i].xy - a.Pos.xy).Length(), a.Radius, t ? t.Radius : 0.0);
				sA[i] = null; sT[i] = null;
				if (met && th) th.ImpactNow(a);
			}
		}
	}

	// the barrel's body against the monster's, 8 units of slack (the throw's own pass-through pad is 0..16). Doom's bodies
	// are square boxes, not round (the rig, 11-07: a barrel stopped by an imp's box corner 35.5 units from its middle,
	// bodies 10 + 16), so the test is the boxes'.
	private static bool Meets(Actor a, Actor t)
	{
		double r = a.Radius + t.Radius + 8;
		if (abs(t.Pos.x - a.Pos.x) > r || abs(t.Pos.y - a.Pos.y) > r) return false;
		return a.Pos.z <= t.Pos.z + t.Height + 8 && t.Pos.z <= a.Pos.z + a.Height + 8;
	}

	// RSQ MELEE'S UPPERCUT BARREL (asked by name: RSQDG_ThrowService "lockon.kick"). `hs` is Melee's own forward kick,
	// map units a tic. With a lock roughly ahead of the kick (player to barrel), the barrel is sent to it and watched as
	// a throw. false: Melee kicks it as before.
	bool Kick(PlayerInfo p, Actor b, double hs)
	{
		if (!p || !p.mo || p != players[consoleplayer] || !On(p) || !IsBarrel(b)) return false;
		bool have; Actor t; Vector3 at;
		[have, t, at] = Target();
		if (!have) return false;
		Vector2 way = b.Pos.xy - p.mo.Pos.xy;
		if (way.Length() < 0.5) way = (cos(p.mo.Angle), sin(p.mo.Angle));
		Vector2 to = at.xy - b.Pos.xy;
		double off = abs(Actor.DeltaAngle(VectorAngle(way.x, way.y), VectorAngle(to.x, to.y)));
		if (off > AHEAD_DEG)
		{
			if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
				Console.Printf("[RSQDG] t%d lock-on: uppercut barrel not to %s -- %.0f deg off the kick (ahead is %.0f)", level.maptime,
					t ? t.GetClassName() : 'its_last_spot', off, AHEAD_DEG);
			return false;
		}
		bool ok; Vector3 v;
		[ok, v] = Send(p, b, hs, true);
		if (!ok) return false;
		b.Vel = v;
		b.target = p.mo;
		let th = RSQDG_Throw.Get();
		if (th)
		{
			double mps = RSQDG_Reach.Metres(v) * TICRATE;
			th.Air(b, clamp(mps * 3.0, 4.0, 28.0) * RSQDG_Reach.Num("rsqdg_throw_spin", p, 1.0));
			th.Watch(b, p.mo, 0, (0, 0));
		}
		return true;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		mon = null; lastPos = (0, 0, 0); offTics = 0;
		for (int i = 0; i < MAX_STEER; i++) { sA[i] = null; sT[i] = null; }
	}

	override void WorldUnloaded(WorldEvent e)
	{
		mon = null; lastPos = (0, 0, 0); offTics = 0;
		for (int i = 0; i < MAX_STEER; i++) { sA[i] = null; sT[i] = null; }
	}
}
