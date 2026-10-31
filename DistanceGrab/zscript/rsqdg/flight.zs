// THE FLIGHT. Impulse-and-steer.
//
// The object is given a velocity and THE ENGINE MOVES IT. That is the whole
// design decision, and it is the opposite of the desktop original, which wrote
// the position itself along a computed parabola.
//
// Why. rs_throw.zs's own header says it, about the outbound throw:
//
//     AND THEN DOOM DOES EVERYTHING ELSE. P_XYMovement and P_ZMovement give
//     gravity, floors, ceilings, stairs, wall sliding, bouncing and impact --
//     for a thrown object those are not features to implement, they are what an
//     actor with a velocity already does.
//
// The inbound pull was the one place that argument was not applied. A written
// path also cannot carry MASS -- a barrel and a clip flew identically -- and it
// cannot be a reel, only a launch-and-arrive.
//
// WHAT IT COSTS, stated because it is a real loss and not a free win: a written
// path can be PLANNED against a whole route, and the desktop build planned one.
// Its MeasureArc sampled the straight line one point per 24 units, took the
// lowest ceiling and highest floor over the entire path, and fixed the arc's
// height ONCE at launch -- because clamping an arc per tic against whatever is
// locally overhead does not lower it, it SQUASHES it, pinning the object to the
// surface it met and dragging it there. Every "it hops and settles instead of
// sailing" report was that clamp.
//
// An impulse path has no arc to plan. A low doorway stops being a flatter
// trajectory and becomes a steering problem. That is the thing to watch the
// first time this meets geometry, and it is why the parabola is kept behind a
// cvar rather than deleted.
class RSQDG_Flight : EventHandler
{
	private Actor  flyActor[2];
	private int    flyTic[2];
	private int    flyHold[2];
	private double flyStart[2];   // room-distance at launch, for Progress()
	private double flyDist[2];    // room-distance now, palm to middle
	private int    flyLimit[2];   // tics before giving up, fixed at launch
	private bool   flyRefused[2]; // pull.refused already said for this flight
	private bool   flyArc[2];     // this flight is the ARC (rsqdg_flight_mode 1), fixed at launch
	private int    flyEta[2];     // arc: tics from launch to the palm, fixed at launch

	// ---- THE WORLDHANDS PATH (rsqdg_flight_mode 2, the default) ------------
	//
	// The owner's RS_WorldHands pull (rs_distance.zs RS_Pull), ported number for
	// number. A WRITTEN path, not a steered one: each tic the object is placed on
	//     start + (palm - start) * e,   e = t ^ 1.6        (it is PULLED: slow, then fast)
	// and lifted by the parabola 4 h e (1 - e), keyed on e so the hump sits in the
	// middle of the PATH whatever the speed curve does. h = 0.15 x the launch
	// distance, capped ONCE at launch by the lowest ceiling over the whole route
	// (MeasureArc) so a low doorway gives a flatter pull that still arrives. Time
	// of flight = distance / 15 m/s, clamped 6..70 tics, so near and far pulls
	// travel at the same speed. Moved by TryMove (Z first), lifted 6/12/18 units
	// if the first try is boxed in, and a pull that meets a wall drops there.
	// Mass does not change it: in WorldHands it never did.
	private bool    flyPath[2];   // this flight is the WorldHands path
	private int     flyTotal[2];  // its tics, fixed at launch
	private Vector3 flyFrom[2];   // the middle of the object at launch
	private double  flyArcH[2];   // the arc height this pull is allowed, fixed at launch

	// ---- THE TUMBLE (rs_distance.zs SaveTumble/ArmTumble/RestoreTumble) ----
	//
	// End over end, rsqdg_tumble turns across the WHOLE flight (WorldHands' shipped
	// default 0.5, "beautiful" in the headset), linear in time so it turns at a
	// constant rate. A sprite needs three render flags for it: +ROLLSPRITE (a
	// billboard ignores roll without it), +ROLLCENTER (about its middle, not its
	// feet) and +INTERPOLATEANGLES (the renderer smooths the roll between tics).
	// A VOXEL ignores roll unless its model flags say UseActorRoll; stock QZD lets
	// one actor carry that flag (SetModelFlag, models.cpp getFlags), so a voxel
	// tumbles too. A voxel turns about its PIVOT, which every BD_VoxelPack voxel
	// puts at its feet (KVX pivot z = height, measured), so its draw position is
	// moved by WorldOffset to keep its middle on the path (RSQDG_Turn.Fix).
	// Every flag, the roll and the offset are saved first and put back on every
	// exit: a sprite with +ROLLSPRITE is not drawn the same even at roll 0.
	private double tumTurns[2];
	private bool   tumSprite[2], tumCentre[2], tumInterp[2], tumVoxel[2];
	private double tumRoll[2];
	private double tumAngle[2], tumSpin[2];   // and turning about its own up (rsqdg_spin turns a flight), put back on the catch
	private Vector3 tumOfs[2];

	// ---- THE BORROWED STATE, AND EXACTLY ONE OWNER OF THE BACKUP ------------
	//
	// Stated three times in the desktop tree because it bit three times, so it
	// is worth stating once more here plainly:
	//
	//   Flight has to switch gravity off and pickup-on-touch off. If it did that
	//   and THEN handed the object to whatever holds it next, the next owner
	//   would save the flags it found -- the ones flight just changed -- and
	//   record "this object was always weightless and never touchable" as its
	//   original state. Releasing it later would leave it floating and
	//   unpickable forever, with nothing in the log.
	//
	// So: captured BEFORE the first mutation, owned by this one slot, and
	// restored on EVERY exit path including the ones nobody plans for: caught
	// (Catch restores before the handover), taken by something else mid-air
	// (restored in place, SPECIAL excepted), and arrived uncaught, timed out,
	// raised, switched off, died or changed level (all through Restore()).
	private bool   savedNoGrav[2];
	private bool   savedThruActors[2];
	private bool   savedSpecial[2];
	private double savedRadius[2];
	private double savedHeight[2];

	static RSQDG_Flight Get()
	{
		return RSQDG_Flight(EventHandler.Find("RSQDG_Flight"));
	}

	bool Flying(int hand) const
	{
		return (hand == 0 || hand == 1) && flyActor[hand] != null;
	}

	bool IsFlying(Actor a) const
	{
		return a && (flyActor[0] == a || flyActor[1] == a);
	}

	Actor FlyingActor(int hand) const
	{
		return (hand == 0 || hand == 1) ? flyActor[hand] : null;
	}

	// How far along the pull is, 0 at launch to 1 on the palm. For the
	// feedback only -- the haptic ramp and the rising hum -- never for the
	// motion, which the engine owns.
	double Progress(int hand) const
	{
		if (hand != 0 && hand != 1 || !flyActor[hand] || flyStart[hand] <= 1) return 0;
		return clamp(1.0 - flyDist[hand] / flyStart[hand], 0.0, 1.0);
	}

	// The last stretch before the catch window, where the ramp goes quiet so
	// the catch tick lands on a free channel. Two and a half catch radii.
	bool Near(int hand) const
	{
		if (hand != 0 && hand != 1 || !flyActor[hand]) return false;
		return flyDist[hand] <= nearDist;
	}
	private double nearDist;

	// THE ROOM DISTANCE, the same measure the cone and the catch use, so "near"
	// here and "within the catch radius" there are the same kind of number.
	static double RoomDist(Vector3 d)
	{
		return (d.x, d.y, d.z * RSQDG_Reach.PIXELSTRETCH).Length();
	}

	// ---- what mass does to a pull ------------------------------------------
	//
	// The cruise speed it is steered toward. sqrt of the pull share, so the
	// spread is felt but not absurd: a clip arrives at the full speed, a barrel
	// at about a third of it -- a heave -- and a Cacodemon corpse at the floor of
	// 15%, a slow drag that the dynamic timeout still lets finish.
	static double CruiseFor(Actor a, PlayerInfo p)
	{
		double share = RSQDG_Mass.PullShare(a, p);
		double full = RSQDG_Reach.MetresToUnits(
			RSQDG_Reach.Num("rsqdg_flight_speed", p, 12.0)) / TICRATE;
		return full * max(0.15, sqrt(share));
	}

	// ---- launch ------------------------------------------------------------
	//
	// Returns false when it could not start, so the caller can say why rather
	// than silently doing nothing.
	bool Launch(int hand, Actor a, PlayerPawn pmo, PlayerInfo p)
	{
		String why = "";
		if (hand != 0 && hand != 1)       why = "bad hand index";
		else if (!a)                      why = "no target";
		else if (flyActor[hand])          why = "this hand already has something in the air";
		// NOR SOMETHING THE OTHER HAND IS ALREADY PULLING. Not a harmless
		// duplicate: each flight saves the object's true flags before touching
		// them, so the second save records what the first already changed as the
		// original, and whichever ends last restores that fiction. There is no
		// gesture meaning "pull it with both hands", so refusing is the fix.
		else if (flyActor[1 - hand] == a) why = "the other hand is already pulling it";

		if (why != "")
		{
			if (RSQDG_Reach.Flag("rsqdg_trace", p, false))
				Console.Printf("[RSQDG] hand %d launch refused -- %s", hand, why);
			return false;
		}

		// CAPTURED BEFORE ANYTHING IS TOUCHED.
		// The settle list may still be lending it pass-through (throw.zs).
		let settler = RSQDG_Throw.Get();
		if (settler) settler.Unsettle(a);

		savedNoGrav[hand]      = a.bNOGRAVITY;
		savedThruActors[hand]  = a.bTHRUACTORS;
		savedSpecial[hand]     = a.bSPECIAL;
		savedRadius[hand]      = a.Radius;
		savedHeight[hand]      = a.Height;

		// SPECIAL OFF FOR THE FLIGHT. The object homes to your palm, which is
		// inside your own collision cylinder, so a live pickup flag means the
		// item is collected MID-AIR -- and the flight then goes on steering
		// something you already own.
		a.bSPECIAL = false;

		// THRUACTORS, for the last few tics of the approach. The object ends up
		// crossing into your own collision cylinder, and a +SOLID thing -- a
		// barrel above all -- is refused that move, which would read as the pull
		// dying an arm's length short every single time.
		a.bTHRUACTORS = true;

		// GRAVITY OFF BY DEFAULT. A pull is an authored force; gravity fighting
		// it would sag every long pull into the floor and the steering would
		// spend its whole authority climbing. Switchable, because "let it sag"
		// is a legitimate feel and this is the cheapest thing here to A/B.
		// THE ARC (rsqdg_flight_mode 1, G3) needs gravity: it IS the curve.
		int mode = int(RSQDG_Reach.Num("rsqdg_flight_mode", p, 2));
		bool arc = mode == 1;
		bool path = mode == 2;
		flyArc[hand] = arc;
		flyPath[hand] = path;
		if (arc) a.bNOGRAVITY = false;
		// THE WORLDHANDS PATH IS AUTHORED: gravity fighting it would drag it down.
		else if (path || !RSQDG_Reach.Flag("rsqdg_flight_gravity", p, false))
			a.bNOGRAVITY = true;

		// SHRUNK TO SOMETHING THE SIZE IT LOOKS.
		//
		// A Doom pickup's radius is a PICKUP-TRIGGER volume, not a physical hull
		// -- a clip is radius 20, the same as a shotgun guy, because that is how
		// near you have to walk to collect it. It is a few units across to look
		// at. Flying a 40-unit-wide box through a doorway for an object the size
		// of a fist is what produced twelve blocked pulls in one desktop session,
		// every one of them a radius-20 pickup and not one a radius-10 barrel.
		//
		// CAPPED, NOT SCALED: a barrel already fits everywhere it needs to.
		// A_SetSize rather than writing Radius, because the actor has to be
		// re-linked into the blockmap at the new size or every collision test
		// goes on using the old one.
		double thin = RSQDG_Reach.Num("rsqdg_flight_radius", p, 2.0);
		if (a.Radius > thin) a.A_SetSize(thin, a.Height);

		flyActor[hand] = a;
		flyTic[hand]   = 0;
		flyHold[hand]  = 0;

		// THE IMPULSE. Toward the palm, at the speed THIS object cruises at,
		// and then the engine owns it.
		Vector3 palm = RSQDG_Reach.Palm(pmo, hand);
		Vector3 d = palm - MidOf(a);
		double len = d.Length();
		double cruise = CruiseFor(a, p);
		if (len > 0.01) a.Vel = (d / len) * cruise;
		// The arc's time of flight: the straight run at this object's cruise, so a
		// heavy thing hangs longer in the air. Never under half a second.
		flyEta[hand] = ArcTime(a, palm, cruise, p);
		if (arc) a.Vel = ArcVel(a, palm, flyEta[hand]);
		if (path) StartPath(hand, a, palm, p);

		// LIFT IT OFF THE FLOOR. Found in the rig, 2026-10-26: a barrel pulled
		// along the ground never left it. Doom applies ground friction -- about
		// 9% of speed per tic -- to anything touching its floor, NOGRAVITY or
		// not, and against the barrel's share of the pull (0.14) friction won:
		// it slid at a third of its cruise and took four seconds to cross a
		// room it should have crossed in two. A clip never showed it because a
		// clip's steering outruns friction easily.
		//
		// So the pull starts with a hop, the way a thing you yank toward you
		// leaves the floor -- unless the palm is BELOW it (pulling something
		// down off a ledge), where it should simply drop toward you.
		if (!path) Lift(a, d.z >= 0);

		flyRefused[hand] = false;
		flyStart[hand] = RoomDist(d);
		flyDist[hand]  = flyStart[hand];

		// GIVE UP AFTER WHAT THIS PULL NEEDS, not a flat number. A flat 140
		// tics was fine when everything flew at one speed; a barrel at a third
		// of it across a big room needs most of that just to cross. So: twice
		// the straight-line travel time at its cruise, plus a second of
		// slack, and never less than the menu figure.
		double travel = (cruise > 0.01) ? (len / cruise) : 0;
		flyLimit[hand] = max(int(RSQDG_Reach.Num("rsqdg_flight_timeout", p, 140.0)),
			int(travel * 2.0) + TICRATE);
		if (path) flyLimit[hand] = max(flyLimit[hand], flyTotal[hand] + TICRATE);

		SaveTumble(hand, a, p);

		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d LAUNCHED %s  dist=%.0f  %.2fkg%s  share=%.2f  cruise=%.1fm/s  limit=%d  r=%.0f->%.0f",
				hand, a.GetClassName(), len, RSQDG_Mass.Kg(a),
				RSQDG_Mass.IsStated(a) ? "" : " (guessed)",
				RSQDG_Mass.PullShare(a, p),
				RSQDG_Reach.Metres((cruise, 0, 0)) * TICRATE, flyLimit[hand],
				savedRadius[hand], a.Radius);

		let feel = RSQDG_Feel.Get();
		if (feel) feel.OnLaunch(hand, a, p);
		return true;
	}

	// Off the floor and rising, if it is on the floor and the palm is above.
	// One unit up breaks floor contact (no friction from the next tic); the
	// upward speed keeps it from settling back while it climbs. Respects the
	// ceiling: a thing in a crawlspace stays where it can fit.
	private static void Lift(Actor a, bool palmAbove)
	{
		if (!palmAbove || a.Pos.z > a.floorz + 0.5) return;
		if (a.floorz + 1 + a.Height <= a.ceilingz)
			a.SetOrigin((a.Pos.x, a.Pos.y, a.floorz + 1), true);
		a.Vel.z = max(a.Vel.z, 1.5);
	}

	// The MIDDLE of the thing, not its origin. A Doom actor's origin is the
	// floor of its volume, so steering toward a barrel's origin aims at the
	// floor in front of it.
	static Vector3 MidOf(Actor a)
	{
		return (a.Pos.x, a.Pos.y, a.Pos.z + a.Height * 0.5);
	}

	// ---- the catch ---------------------------------------------------------
	//
	// WHICH FLYING OBJECT, IF ANY, IS WITHIN THIS HAND'S GRASP RIGHT NOW. This
	// is what makes catching a matter of TIMING rather than a button that always
	// works: the object homes to your palm, so it is only catchable once it has
	// nearly got there.
	Actor CatchableBy(int hand, PlayerPawn pmo, PlayerInfo p)
	{
		if (hand != 0 && hand != 1) return null;
		Actor a = flyActor[hand];
		if (!a) return null;

		Vector3 d = RSQDG_Reach.Palm(pmo, hand) - MidOf(a);
		Vector3 pd = (d.x, d.y, d.z * RSQDG_Reach.PIXELSTRETCH);
		return pd.Length() <= RSQDG_Reach.Num("rsqdg_catch_radius", p, 24.0) ? a : null;
	}

	// TAKE IT OUT OF THE AIR.
	//
	// THE TRUE FLAGS GO BACK BEFORE THE HANDOVER, EVERY TIME. Whoever takes the
	// object next saves what it finds, and what it would find otherwise is the
	// state THIS flight imposed -- so it would record "weightless, pass-through,
	// not collectable" as the object's original state and hand that fiction back
	// when released. That is the trap stated three times in the desktop tree,
	// and restoring first is the whole of the fix.
	bool Catch(int hand, PlayerPawn pmo, PlayerInfo p)
	{
		Actor a = flyActor[hand];
		if (!a) return false;

		a.bNOGRAVITY  = savedNoGrav[hand];
		a.bTHRUACTORS = savedThruActors[hand];
		a.bSPECIAL    = savedSpecial[hand];
		a.A_SetSize(savedRadius[hand], savedHeight[hand]);
		// The tumble too, BEFORE the handover: whoever takes it next saves what it
		// finds, and a caught barrel must not sit in the hand cocked at whatever
		// angle it arrived at.
		RestoreTumble(hand, a);

		// CONSUMED ON THE WAY IN, when it is something you simply collect.
		//
		// This is "catch a weapon and use it right away": an Inventory that
		// pickups successfully is gone -- equipped, or added to a count -- and
		// there is nothing left to hold. Asked FIRST, because holding a medikit
		// you have already absorbed is nonsense.
		//
		// It is a switch rather than a rule, because the opposite is also a real
		// want: pulling a medikit across a room in order to CARRY it somewhere
		// is impossible if arrival always spends it.
		if (RSQDG_Reach.Flag("rsqdg_catch_takes", p, true))
		{
			let inv = Inventory(a);
			if (inv)
			{
				// TWO RETURN VALUES, not an out-parameter. The stock signature
				// is `bool, Actor CallTryPickup(Actor toucher)` -- the Actor is
				// the thing that actually ended up being picked up, which may
				// not be the one offered.
				// Heft is read BEFORE the pickup: a successful one usually
				// destroys the item, and the feedback still wants to know
				// whether it was a clip or a backpack that landed.
				double heft = RSQDG_Mass.Heft(a);
				String cname = a.GetClassName();
				bool took;
				Actor result;
				[took, result] = inv.CallTryPickup(pmo);
				if (took)
				{
					if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
						Console.Printf("[RSQDG] hand %d caught and USED %s", hand, cname);
					flyActor[hand] = null;
					flyTic[hand] = 0;
					flyHold[hand] = 0;
					let feel = RSQDG_Feel.Get();
					if (feel) feel.OnCatch(hand, null, p, true, heft);
					return true;
				}
			}
		}

		let hold = RSQDG_Hold.Get();
		if (hold && hold.Take(hand, a, p))
		{
			flyActor[hand] = null;
			flyTic[hand] = 0;
			flyHold[hand] = 0;
			let feel = RSQDG_Feel.Get();
			if (feel) feel.OnCatch(hand, a, p, false, RSQDG_Mass.Heft(a));
			return true;
		}

		// REFUSED, so it keeps flying rather than being dropped on the floor by
		// a hand that could not take it. Flight's own flags go back ON -- and
		// that includes THRUACTORS, or the rest of the approach runs into the
		// player and stops dead.
		a.bNOGRAVITY  = flyArc[hand] ? false : (flyPath[hand] || !RSQDG_Reach.Flag("rsqdg_flight_gravity", p, false));   // the arc keeps its gravity
		a.bTHRUACTORS = true;
		a.bSPECIAL    = false;
		double thin = RSQDG_Reach.Num("rsqdg_flight_radius", p, 2.0);
		if (a.Radius > thin) a.A_SetSize(thin, a.Height);
		// Still in the air, so still tumbling -- the flags go back on WITHOUT
		// re-saving (the saved ones are the truth; these are the flight's).
		ArmTumble(hand, a);

		if (RSQDG_Reach.Flag("rsqdg_trace", p, false))
			Console.Printf("[RSQDG] hand %d could not take %s -- still flying",
				hand, a.GetClassName());
		// SAID ONCE PER FLIGHT. The catch is retried every tic of the arrival
		// dwell, and the same refusal is not news five times.
		if (!flyRefused[hand])
		{
			flyRefused[hand] = true;
			let feel = RSQDG_Feel.Get();
			if (feel) feel.OnRefused(hand, a);
		}
		return false;
	}

	// ---- every exit goes through here --------------------------------------
	private void Restore(int hand)
	{
		Actor a = flyActor[hand];
		if (a)
		{
			a.bNOGRAVITY  = savedNoGrav[hand];
			a.bTHRUACTORS = savedThruActors[hand];
			a.bSPECIAL    = savedSpecial[hand];
			// NOT the size of a monster that got up. The saved size is the
			// CORPSE's; raising it already put the living size back, and
			// writing the corpse's over it would leave a quarter-height imp.
			if (!(a.bISMONSTER && a.Health > 0))
				a.A_SetSize(savedRadius[hand], savedHeight[hand]);
			RestoreTumble(hand, a);
		}
		flyActor[hand] = null;
		flyTic[hand]   = 0;
		flyHold[hand]  = 0;
	}

	// Every ending that is not a catch. `what` is the event the feedback and
	// any listener hear: pull.missed, pull.blocked or pull.aborted. Only a
	// pull that was actually in the air reports -- AbortAll runs on every
	// level load and every tic the mechanic is off.
	void Abort(int hand, String what = "pull.aborted")
	{
		Actor a = flyActor[hand];
		bool was = (a != null) || flyTic[hand] != 0;
		Restore(hand);
		if (a) a.Vel = (0, 0, 0);
		if (was)
		{
			let feel = RSQDG_Feel.Get();
			if (feel) feel.OnDrop(hand, a, players[consoleplayer], what);
		}
	}

	void AbortAll()
	{
		Abort(0);
		Abort(1);
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) { AbortAll(); return; }
		let pmo = p.mo;

		// OFF HAS TO MEAN OFF, and that includes putting back everything we
		// borrowed. The desktop build switched its master cvar off mid-flight
		// and the object finished its arc and hit the player with the whole
		// system supposedly disabled.
		if (pmo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true))
		{
			AbortAll();
			return;
		}

		// The quiet stretch before the catch: two and a half catch radii.
		nearDist = RSQDG_Reach.Num("rsqdg_catch_radius", p, 24.0) * 2.5;

		for (int h = 0; h < 2; h++)
		{
			Actor a = flyActor[h];

			// An Actor pointer nulls itself when the actor dies, so a target
			// crushed or consumed mid-flight clears its own slot. The saved
			// flags do NOT, and a stale pair is what the next launch would hand
			// onward as an object's "true" state.
			if (!a)
			{
				if (flyTic[h] != 0) Abort(h, "pull.aborted");
				continue;
			}

			// ALREADY SOMEBODY'S. If anything gave the item an owner mid-flight
			// the flight is over: steering an owned item moves it around inside
			// an inventory. The borrowed flags are NOT put back -- becoming an
			// item set its own.
			let inv = Inventory(a);
			if (inv && inv.Owner)
			{
				// GRAVITY, PASS-THROUGH AND SIZE GO BACK -- SPECIAL DOES NOT.
				// Becoming an item touches SPECIAL, the blockmap links and the
				// statnum (Inventory.BecomeItem) and NOTHING ELSE, so without
				// this the item sits in an inventory weightless, pass-through and
				// two units wide -- and the day it is dropped (CreateTossable
				// hands back the same actor) it floats. SPECIAL alone is left
				// as BecomeItem set it: an owned item must not be collectable.
				// (Found in review, 2026-10-26: the old comment here said
				// becoming an item "set its own". It does not.)
				a.bNOGRAVITY  = savedNoGrav[h];
				a.bTHRUACTORS = savedThruActors[h];
				a.A_SetSize(savedRadius[h], savedHeight[h]);
				RestoreTumble(h, a);
				flyActor[h] = null;
				flyTic[h] = 0;
				flyHold[h] = 0;
				let feel = RSQDG_Feel.Get();
				if (feel) feel.OnDrop(h, a, p, "pull.aborted");
				continue;
			}

			// RAISED MID-PULL. An Arch-Vile brings back the corpse you are
			// pulling: a living monster is never pullable, so the pull ends.
			// Restore() knows not to write the corpse's size back onto it.
			if (a.bISMONSTER && a.Health > 0)
			{
				if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
					Console.Printf("[RSQDG] hand %d: %s got up -- pull ended", h, a.GetClassName());
				Abort(h, "pull.aborted");
				continue;
			}

			flyTic[h]++;

			// Give up rather than steer something forever. A pull that has not
			// arrived in this long has met something it cannot get past, and
			// leaving it circling is worse than dropping it.
			if (flyTic[h] > flyLimit[h])
			{
				if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
					Console.Printf("[RSQDG] hand %d gave up on %s after %d tics",
						h, a.GetClassName(), flyTic[h]);
				Abort(h, "pull.blocked");
				continue;
			}

			// ---- the steering ----------------------------------------------
			//
			// HOMES TO WHERE YOUR HAND IS NOW, re-read every tic, not to where
			// it was when you pulled. Over a third of a second your hand has
			// moved, and an object flying to a stale point arrives beside it.
			Vector3 palm = RSQDG_Reach.Palm(pmo, h);

			// THE WORLDHANDS PATH places the object itself, then the arrival
			// below works on where it got to.
			if (flyPath[h] && !StepPath(h, a, palm, p))
			{
				if (RSQDG_Reach.Flag("rsqdg_trace", p, false))
					Console.Printf("[RSQDG] hand %d lost %s -- blocked on tic %d/%d at (%.0f %.0f %.0f)",
						h, a.GetClassName(), flyTic[h], flyTotal[h], a.Pos.x, a.Pos.y, a.Pos.z);
				Abort(h, "pull.blocked");
				continue;
			}
			StepTumble(h, a);
			// A FAINT TRAIL behind what you are pulling (owner 2026-10-31: "some life"): a few soft motes in the lock's
			// green, fading where it was
			if (RSQDG_Reach.Flag("rsqdg_trail", p, true) && (level.maptime & 1))
				a.A_SpawnParticle(RSQDG_CB.Pick(RSQDG_CB.CB_HAVE, 0x8CFFA8), SPF_FULLBRIGHT, 10, 3.0, 0, 0, 0, a.Height * 0.5, 0, 0, 0.05, 0.45, -0.04);

			Vector3 toPalm = palm - MidOf(a);
			double dist = toPalm.Length();
			flyDist[h] = RoomDist(toPalm);

			// ARRIVED. Hold it on the palm for a few tics rather than resolving
			// the instant it gets there.
			//
			// This is not politeness, it is the §11.1 trap. A state that exists
			// for ZERO TICS cannot be observed by anything reading last tic's
			// value -- and the desktop catch test, registered earlier in the
			// tic than the code that moved the object, only ever saw the
			// previous tic's position: ~23 units short and ~13 above the palm,
			// scoring ~17 against a volume needing <= 1.0. The window was not
			// tight, it was SHUT.
			//
			// It passed testing because the residual is a constant number of
			// units rather than a fraction, so short pulls catch fine. Under
			// 50-70 units it works, which is arm's reach -- exactly the distance
			// anyone tests at first. A long pull is where it shows, and the
			// claw's clean record at 72 units is no evidence at 512.
			// THE ROOM DISTANCE, the same measure CatchableBy() and Near() use,
			// so "arrived" here and "catchable" there can never disagree.
			double catchR = RSQDG_Reach.Num("rsqdg_catch_radius", p, 24.0);
			bool pathDone = flyPath[h] && flyTic[h] >= flyTotal[h];
			if (flyPath[h] && !pathDone && flyDist[h] <= catchR)
			{
				// On its way in and already within reach of the palm: an open
				// hand takes it now. The path keeps placing it otherwise.
				let g0 = RSQDG_Grab.Get();
				if (g0 && g0.Held(h) && Catch(hand: h, pmo: pmo, p: p)) continue;
			}
			if (flyPath[h] ? pathDone : (flyDist[h] <= catchR))
			{
				// Park ON the palm and keep tracking it, so whatever resolves
				// the catch gets several real looks at the real arrival
				// position, including one after the hand's own pose has settled.
				// (The WorldHands path is already on the palm: t is clamped at 1,
				// so it re-solves onto the live palm every tic of the hold, as
				// WorldHands' CATCH_HOLD_TICS does.)
				a.Vel = (0, 0, 0);
				if (!flyPath[h]) a.SetOrigin((palm.x, palm.y, palm.z - a.Height * 0.5), true);

				// AN OPEN HAND CATCHES IT. With the gesture as the trigger
				// there is no button to press on arrival, so the pose does it:
				// if your palm is still out when the object gets there, you
				// catch it. You flicked it toward yourself -- obviously you are
				// trying to catch it.
				//
				// What makes a miss possible is turning your hand away or moving
				// it, which is the honest version of the skill: keep your hand
				// where the thing is coming.
				let g = RSQDG_Grab.Get();
				if (g && g.Held(h) && Catch(hand: h, pmo: pmo, p: p))
					continue;

				if (flyHold[h] < int(RSQDG_Reach.Num("rsqdg_catch_hold", p, 4.0)))
				{
					flyHold[h]++;
					continue;
				}

				// THE CATCH IS NOT WRITTEN YET. Until it is, an arrival drops
				// the object as an ordinary Doom actor -- every borrowed flag
				// put back, gravity included, which is what carries it down to
				// your feet from the palm it was flying to.
				//
				// A MISS JUST DROPS IT, and that is the shipping behaviour too,
				// not a placeholder. The original resolved a missed catch as a
				// real event -- the medikit healed you, the barrel hurt you --
				// and the argument was that missing should cost something. What
				// it actually meant was that you could not pull a medikit across
				// a room to CARRY it: fumbling it spent the item where it stood.
				// An interaction whose failure mode is "you take damage" is one
				// people stop using.
				if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
					Console.Printf("[RSQDG] %s arrived and was not caught -- dropped",
						a.GetClassName());
				Abort(h, "pull.missed");
				continue;
			}

			// NOT THERE YET. Steer toward the palm with BOUNDED acceleration,
			// scaled by 1/mass, and let P_XYMovement and P_ZMovement do the
			// moving. That is where the collision, the wall sliding and the
			// stairs come from for free.
			//
			// MASS IS WHY THIS DESIGN WAS CHOSEN, and now it has one. A
			// written path gave a barrel and a clip identical flight; here a
			// heavy thing cruises slower AND turns lazily, a light one snaps to
			// the hand. Both from RSQDG_Mass -- kilograms out of MASSDEF -- and
			// NOT Actor.Mass, which is 100 on every non-monster and made every
			// pickup fly the same (PORT_SCOPE A1).
			// THE ARC (G3): no steering force at all. Each tic the throw that would
			// land on the palm in the time remaining is solved again under gravity
			// and becomes the velocity -- a lob that follows your hand, and the one
			// path a kinematic arc could route-plan. Mass is in the time of flight.
			if (flyPath[h]) continue;   // placed above, not steered

			if (flyArc[h])
			{
				int left = max(2, flyEta[h] - flyTic[h]);
				a.Vel = ArcVel(a, palm, left);
				Duck(a, p);
				continue;
			}

			Vector3 want = (toPalm / dist) * CruiseFor(a, p);

			// Steering authority is the plain share, no sqrt: a heavy thing
			// should be noticeably harder to turn, more than it is slower.
			// Floored so a body can still be steered round a corner at all.
			double authority = max(0.05, RSQDG_Mass.PullShare(a, p));

			double maxAcc = RSQDG_Reach.MetresToUnits(
				RSQDG_Reach.Num("rsqdg_steer", p, 40.0)) / (TICRATE * TICRATE) * authority;

			Vector3 dv = want - a.Vel;
			double dvl = dv.Length();
			if (dvl > maxAcc) dv = (dv / dvl) * maxAcc;
			a.Vel = a.Vel + dv;

			// AND KEEP IT OFF THE FLOOR while it still has to climb to you. A
			// step, a slope or a lip can ground it mid-pull, and a grounded heavy
			// thing is back to fighting friction. Only when the palm is above:
			// a pull down off a ledge is allowed to land and slide.
			Lift(a, toPalm.z > a.Height * 0.25);
			Duck(a, p);
		}
	}

	// ---- the WorldHands path ------------------------------------------------

	// At launch: the time of flight from the distance, and the arc this route
	// allows. All of it from rs_distance.zs RS_Pull.Start.
	private void StartPath(int hand, Actor a, Vector3 palm, PlayerInfo p)
	{
		Vector3 mid0 = MidOf(a);
		double dist = (mid0 - palm).Length();
		double upt = max(0.1, RSQDG_Reach.MetresToUnits(RSQDG_Reach.Num("rsqdg_path_speed", p, 15.0)) / TICRATE);
		double lo = max(1.0, RSQDG_Reach.Num("rsqdg_path_tmin", p, 6.0));
		double hi = max(lo, RSQDG_Reach.Num("rsqdg_path_tmax", p, 70.0));
		flyTotal[hand] = int(clamp(dist / upt, lo, hi));
		flyFrom[hand] = mid0;
		double want = dist * RSQDG_Reach.Num("rsqdg_path_arc", p, 0.15);
		double cap = MeasureArc(a, mid0, palm);
		flyArcH[hand] = (cap < 0.0) ? want : min(want, cap);
		a.Vel = (0, 0, 0);
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] path: dist %.0f  %d tics  arc %.0f (wanted %.0f, room %.0f)",
				dist, flyTotal[hand], flyArcH[hand], want, cap);
	}

	// HOW HIGH THIS PULL CAN ARC WITHOUT MEETING A CEILING (MeasureArc, verbatim
	// in substance): the straight line sampled every 24 units (4..48 samples), the
	// LOWEST ceiling and HIGHEST floor over the whole route, an 8-unit margin for
	// a box turning over. -1 when nothing sampled: keep the arc wanted.
	private static double MeasureArc(Actor a, Vector3 from, Vector3 to)
	{
		double span = (to - from).Length();
		int samples = clamp(int(span / 24.0), 4, 48);
		double minCeil = 1e30, maxFloor = -1e30;
		for (int i = 0; i <= samples; i++)
		{
			double t = double(i) / double(samples);
			Vector2 pt = (from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t);
			Sector sec = level.PointInSector(pt);
			if (!sec) continue;
			double c = sec.ceilingplane.ZatPoint(pt);
			double f = sec.floorplane.ZatPoint(pt);
			if (c < minCeil) minCeil = c;
			if (f > maxFloor) maxFloor = f;
		}
		if (minCeil > 1e29 || maxFloor < -1e29) return -1.0;
		double margin = 8.0;
		double room = minCeil - maxFloor - a.Height - margin;
		double avail = (minCeil - a.Height - margin) - max(from.z, to.z);
		double cap = min(room, avail);
		return cap > 0.0 ? cap : 0.0;
	}

	// One tic of the path. False when the object could not move: it met a wall.
	private bool StepPath(int h, Actor a, Vector3 palm, PlayerInfo p)
	{
		double t = min(1.0, double(flyTic[h]) / double(max(1, flyTotal[h])));
		double acc = max(0.25, RSQDG_Reach.Num("rsqdg_path_accel", p, 1.6));
		// SMOOTHER (owner 2026-10-31: "smoother, quicker ... some life"): the pulled curve (slow, then fast) blended
		// with an ease that starts and lands softly, rsqdg_path_smooth of the second: it leaves the floor with a
		// tug, flies, and settles into the hand instead of slamming into it.
		double sm = clamp(RSQDG_Reach.Num("rsqdg_path_smooth", p, 0.6), 0.0, 1.0);
		double soft = t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
		double e = (t ** acc) * (1.0 - sm) + soft * sm;
		// HOMES TO WHERE YOUR HAND IS NOW, re-read every tic.
		Vector3 pos = flyFrom[h] + (palm - flyFrom[h]) * e;
		pos.z += 4.0 * flyArcH[h] * e * (1.0 - e);

		// Z FIRST, CLAMPED TO THE ROOM, then XY by TryMove -- a real move that
		// stops at walls, not SetOrigin, which passes through them.
		double flyZ = pos.z - a.Height * 0.5;
		double lo = a.floorz;
		double hi = max(lo, a.ceilingz - a.Height);
		a.SetZ(clamp(flyZ, lo, hi));
		bool moved = a.TryMove((pos.x, pos.y), 1);

		// LIFT IT OUT BEFORE DRAGGING IT SIDEWAYS: a pickup in an alcove is boxed
		// in where it lies. Up to three 6-unit steps; the Z goes back if none helps.
		if (!moved)
		{
			double keepZ = a.Pos.z;
			for (int lift = 1; lift <= 3 && !moved; lift++)
			{
				double tryZ = keepZ + lift * 6.0;
				if (tryZ + a.Height > a.ceilingz) break;
				a.SetZ(tryZ);
				moved = a.TryMove((pos.x, pos.y), 1);
			}
			if (!moved) a.SetZ(keepZ);
		}
		a.Vel = (0, 0, 0);
		return moved;
	}

	// ---- the tumble ----------------------------------------------------------

	private void SaveTumble(int hand, Actor a, PlayerInfo p)
	{
		tumSprite[hand] = a.bROLLSPRITE;
		tumCentre[hand] = a.bROLLCENTER;
		tumInterp[hand] = a.bINTERPOLATEANGLES;
		tumRoll[hand]   = a.Roll;
		tumAngle[hand]  = a.Angle;
		tumSpin[hand]   = RSQDG_Reach.Num("rsqdg_spin", p, 1.0);
		tumOfs[hand]    = a.WorldOffset;
		tumVoxel[hand]  = false;
		tumTurns[hand]  = RSQDG_Reach.Num("rsqdg_tumble", p, 0.5);
		ArmTumble(hand, a);
	}

	// The flags back ON without re-saving: the refused catch, still in the air.
	private void ArmTumble(int hand, Actor a)
	{
		if (tumTurns[hand] == 0) return;   // 0 is off, and off means untouched
		a.bROLLSPRITE = true;
		a.bROLLCENTER = true;
		a.bINTERPOLATEANGLES = true;
		if (RSQDG_Voxels.Drawn(a))
		{
			a.SetModelFlag(MDL_USEACTORROLL);
			tumVoxel[hand] = true;
		}
	}

	// Every exit. The roll VALUE as well as the flags, or a caught barrel sits
	// cocked at whatever angle it arrived at.
	private void RestoreTumble(int hand, Actor a)
	{
		if (!a || tumTurns[hand] == 0) return;
		a.bROLLSPRITE = tumSprite[hand];
		a.bROLLCENTER = tumCentre[hand];
		a.bINTERPOLATEANGLES = tumInterp[hand];
		a.Roll = tumRoll[hand];
		if (tumSpin[hand] != 0) a.Angle = tumAngle[hand];
		a.WorldOffset = tumOfs[hand];
		if (tumVoxel[hand]) a.ResetModelFlags();
		tumVoxel[hand] = false;
	}

	// KEYED ON TIME, NOT ON THE PATH: a tumbling thing turns at a constant rate.
	// Turns across the whole flight, so near and far pulls turn the same amount.
	// The WorldHands path knows its time; a steered or lobbed pull uses how far
	// along it is.
	private void StepTumble(int h, Actor a)
	{
		if (tumTurns[h] == 0) return;
		double t = flyPath[h] ? min(1.0, double(flyTic[h]) / double(max(1, flyTotal[h])))
		                      : Progress(h);
		double before = a.Roll;
		a.Roll = tumRoll[h] + tumTurns[h] * 360.0 * t;
		// ALIVE: it spins about its own up as well as end over end, fastest mid-flight (a voxel or a model shows it)
		if (tumSpin[h] != 0) a.Angle = tumAngle[h] + tumSpin[h] * 360.0 * (t * t * (3.0 - 2.0 * t));
		if (tumVoxel[h]) a.WorldOffset = tumOfs[h] + RSQDG_Turn.Fix(a, savedHeight[h] * 0.5, false, (before + a.Roll) * 0.5);
	}

	// THE ARC'S TIME OF FLIGHT, chosen by its HEIGHT (review, 10-26). Taking the
	// straight run at cruise lobbed a slow barrel ~1,700 units up -- the apex of a
	// lob is g t^2 / 8, so time is what has to be bounded. The run at cruise is
	// still the preference (heavy things hang longer), but no longer than the
	// time that peaks at rsqdg_arc_apex metres, and lower under a low ceiling --
	// but never faster than twice full flight speed.
	private static int ArcTime(Actor a, Vector3 palm, double cruise, PlayerInfo p)
	{
		Vector3 d = palm - MidOf(a);
		double run = d.XY.Length();
		double eta = RoomDist(d) / max(cruise, 0.01);
		double g = level.gravity * a.CurSector.gravity * a.Gravity * 0.00125;
		if (g <= 0.0001) return max(8, int(eta));
		double apex = RSQDG_Reach.MetresToUnits(RSQDG_Reach.Num("rsqdg_arc_apex", p, 1.0));
		double tApex = sqrt(8.0 * max(apex, 1.0) / g);
		double full = RSQDG_Reach.MetresToUnits(RSQDG_Reach.Num("rsqdg_flight_speed", p, 12.0)) / TICRATE;
		double tFast = run / max(2.0 * full, 0.01);
		double t = min(eta, max(tApex, tFast));
		// The ceiling MIDWAY, where a level lob peaks (rig: a low ceiling over the
		// player's own spot flattened every arc in the room): its top must pass under.
		double base = max(a.Pos.z + a.Height, palm.z + a.Height * 0.5);
		Vector2 mid = (a.Pos.XY + palm.XY) * 0.5;
		Sector ms = level.PointInSector(mid);
		double room = (ms ? ms.ceilingplane.ZatPoint(mid) : a.ceilingz) - base - 2.0;
		if (room > 1.0) t = min(t, sqrt(8.0 * room / g));
		// Never faster than twice full flight speed, even under a low ceiling: there
		// the arc flattens against the ceiling (Duck) rather than becoming a bullet.
		t = max(t, tFast);
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] arc: run %.0f eta %.1f apexT %.1f fastT %.1f room %.0f g %.2f -> %d tics", run, eta, tApex, tFast, room, g, max(8, int(t)));
		return max(8, int(t));
	}

	// The velocity that carries the middle of `a` onto `palm` in `t` tics under
	// this actor's own gravity (the engine's: level x sector x actor x 1/800).
	private static Vector3 ArcVel(Actor a, Vector3 palm, int t)
	{
		Vector3 d = palm - MidOf(a);
		double g = a.bNOGRAVITY ? 0.0 : level.gravity * a.CurSector.gravity * a.Gravity * 0.00125;
		return (d.x / t, d.y / t, d.z / t + 0.5 * g * t);
	}

	// CEILING-AWARE (G4). The pull climbs toward a palm that is usually higher
	// than the object, and a doorway's lintel is a lower ceiling a few units
	// ahead: the top of the object met the header and the whole pull stopped dead
	// on the wall above the door. Look along the flight for the lowest ceiling in
	// the next few tics and cap the climb so the top passes under it. Floors are
	// not mirrored -- stepping up is already the engine's. rsqdg_flight_duck 0 off.
	const DUCK_AHEAD = 4;       // tics of flight looked along
	const DUCK_MARGIN = 2.0;    // units kept under the ceiling
	private static void Duck(Actor a, PlayerInfo p)
	{
		if (!RSQDG_Reach.Flag("rsqdg_flight_duck", p, true)) return;
		double sp = a.Vel.XY.Length();
		if (sp < 0.5) return;
		for (int k = 1; k <= DUCK_AHEAD; k++)
		{
			Vector2 at = a.Pos.XY + a.Vel.XY * k;
			Sector sec = level.PointInSector(at);
			if (!sec) continue;
			double ceil = sec.ceilingplane.ZatPoint(at);
			double flr  = sec.floorplane.ZatPoint(at);
			// Only a gap it can actually fit through; a wall is the engine's business.
			if (ceil - flr < a.Height + DUCK_MARGIN) continue;
			double room = ceil - DUCK_MARGIN - a.Height - a.Pos.z;   // how far up it may still go
			double cap = room / k;
			if (a.Vel.z > cap) a.Vel.z = cap;
		}
	}

	override void WorldLoaded(WorldEvent e) { AbortAll(); }
	override void WorldUnloaded(WorldEvent e) { AbortAll(); }
}

// WHERE A TURNED VOXEL'S MIDDLE GOES, AND THE OFFSET THAT PUTS IT BACK.
//
// models.cpp RenderModel turns a model about its origin: yaw (-angle about up),
// then pitch (-actor pitch, about the model's side axis) when USEACTORPITCH, then
// roll (-roll, about its forward axis) when USEACTORROLL -- applied to the vertex
// in the reverse order. A KVX voxel's origin is its pivot, which BD_VoxelPack
// puts at the bottom of every voxel, so turning one swings it about its feet. Fix
// returns the WorldOffset (render-only, hw_sprites.cpp adds it to the draw
// position) that keeps a point `u` units above the origin -- the middle -- where
// it was. `roll` is the roll to solve for (the mid-tic one: WorldOffset is not
// interpolated and the angles are, so solving halfway halves the error).
class RSQDG_Turn
{
	static Vector3 Fix(Actor a, double u, bool usePitch, double roll)
	{
		double r = roll;
		double pt = usePitch ? -a.Pitch : 0.0;
		double ya = a.Angle;
		// GL frame: X forward, Y up, Z = left of forward (after yaw).
		// roll (-r about X): (0, u, 0) -> (0, u cos r, -u sin r)
		double y0 = u * cos(r), z0 = -u * sin(r);
		// pitch (pt about Z): x = -y sin pt, y = y cos pt
		double x1 = -y0 * sin(pt), y1 = y0 * cos(pt), z1 = z0;
		// yaw (-ya about Y): X = x cos ya - z sin ya, Z = x sin ya + z cos ya
		double wx = x1 * cos(ya) - z1 * sin(ya);
		double wy = x1 * sin(ya) + z1 * cos(ya);
		// The middle should be straight above the origin; move the drawing by the
		// difference.
		return (-wx, -wy, u - y1);
	}
}
