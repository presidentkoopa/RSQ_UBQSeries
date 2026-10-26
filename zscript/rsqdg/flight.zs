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
	private Actor flyActor[2];
	private int   flyTic[2];
	private int   flyHold[2];

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
	// restored on EVERY exit path including the ones nobody plans for. There are
	// four exits -- caught, arrived uncaught, blocked, aborted -- and all four go
	// through Restore().
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

	Actor FlyingActor(int hand) const
	{
		return (hand == 0 || hand == 1) ? flyActor[hand] : null;
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
			if (RSQDG_Reach.Flag("rsqdg_trace", p, true))
				Console.Printf("[RSQDG] hand %d launch refused -- %s", hand, why);
			return false;
		}

		// CAPTURED BEFORE ANYTHING IS TOUCHED.
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
		if (!RSQDG_Reach.Flag("rsqdg_flight_gravity", p, false))
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

		// THE IMPULSE. Toward the palm, at the configured speed, and then the
		// engine owns it.
		Vector3 palm = RSQDG_Reach.Palm(pmo, hand);
		Vector3 d = palm - MidOf(a);
		double len = d.Length();
		if (len > 0.01)
		{
			double speed = RSQDG_Reach.MetresToUnits(
				RSQDG_Reach.Num("rsqdg_flight_speed", p, 12.0)) / TICRATE;
			a.Vel = (d / len) * speed;
		}

		if (RSQDG_Reach.Flag("rsqdg_debug", p, true))
			Console.Printf("[RSQDG] hand %d LAUNCHED %s  dist=%.0f mass=%d r=%.0f->%.0f",
				hand, a.GetClassName(), len, a.Mass, savedRadius[hand], a.Radius);
		return true;
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
				bool took;
				Actor result;
				[took, result] = inv.CallTryPickup(pmo);
				if (took)
				{
					if (RSQDG_Reach.Flag("rsqdg_debug", p, true))
						Console.Printf("[RSQDG] hand %d caught and USED %s",
							hand, a.GetClassName());
					flyActor[hand] = null;
					flyTic[hand] = 0;
					flyHold[hand] = 0;
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
			return true;
		}

		// REFUSED, so it keeps flying rather than being dropped on the floor by
		// a hand that could not take it. Flight's own flags go back ON -- and
		// that includes THRUACTORS, or the rest of the approach runs into the
		// player and stops dead.
		a.bNOGRAVITY  = !RSQDG_Reach.Flag("rsqdg_flight_gravity", p, false);
		a.bTHRUACTORS = true;
		a.bSPECIAL    = false;
		double thin = RSQDG_Reach.Num("rsqdg_flight_radius", p, 2.0);
		if (a.Radius > thin) a.A_SetSize(thin, a.Height);

		if (RSQDG_Reach.Flag("rsqdg_trace", p, true))
			Console.Printf("[RSQDG] hand %d could not take %s -- still flying",
				hand, a.GetClassName());
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
			a.A_SetSize(savedRadius[hand], savedHeight[hand]);
		}
		flyActor[hand] = null;
		flyTic[hand]   = 0;
		flyHold[hand]  = 0;
	}

	void Abort(int hand)
	{
		Actor a = flyActor[hand];
		Restore(hand);
		if (a) a.Vel = (0, 0, 0);
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

		for (int h = 0; h < 2; h++)
		{
			Actor a = flyActor[h];

			// An Actor pointer nulls itself when the actor dies, so a target
			// crushed or consumed mid-flight clears its own slot. The saved
			// flags do NOT, and a stale pair is what the next launch would hand
			// onward as an object's "true" state.
			if (!a)
			{
				if (flyTic[h] != 0) Restore(h);
				continue;
			}

			// ALREADY SOMEBODY'S. If anything gave the item an owner mid-flight
			// the flight is over: steering an owned item moves it around inside
			// an inventory. The borrowed flags are NOT put back -- becoming an
			// item set its own.
			let inv = Inventory(a);
			if (inv && inv.Owner)
			{
				flyActor[h] = null;
				flyTic[h] = 0;
				flyHold[h] = 0;
				continue;
			}

			flyTic[h]++;

			// Give up rather than steer something forever. A pull that has not
			// arrived in this long has met something it cannot get past, and
			// leaving it circling is worse than dropping it.
			int maxTics = int(RSQDG_Reach.Num("rsqdg_flight_timeout", p, 140.0));
			if (flyTic[h] > maxTics)
			{
				if (RSQDG_Reach.Flag("rsqdg_debug", p, true))
					Console.Printf("[RSQDG] hand %d gave up on %s after %d tics",
						h, a.GetClassName(), flyTic[h]);
				Abort(h);
				continue;
            }

			// ---- the steering ----------------------------------------------
			//
			// HOMES TO WHERE YOUR HAND IS NOW, re-read every tic, not to where
			// it was when you pulled. Over a third of a second your hand has
			// moved, and an object flying to a stale point arrives beside it.
			Vector3 palm = RSQDG_Reach.Palm(pmo, h);
			Vector3 toPalm = palm - MidOf(a);
			double dist = toPalm.Length();

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
			double catchR = RSQDG_Reach.Num("rsqdg_catch_radius", p, 24.0);
			if (dist <= catchR)
			{
				// Park ON the palm and keep tracking it, so whatever resolves
				// the catch gets several real looks at the real arrival
				// position, including one after the hand's own pose has settled.
				a.Vel = (0, 0, 0);
				a.SetOrigin((palm.x, palm.y, palm.z - a.Height * 0.5), true);

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
				if (RSQDG_Reach.Flag("rsqdg_debug", p, true))
					Console.Printf("[RSQDG] %s arrived -- dropped (no catch yet)",
						a.GetClassName());
				Abort(h);
				continue;
			}

			// NOT THERE YET. Steer toward the palm with BOUNDED acceleration,
			// scaled by 1/mass, and let P_XYMovement and P_ZMovement do the
			// moving. That is where the collision, the wall sliding and the
			// stairs come from for free.
			//
			// MASS IS WHY THIS DESIGN WAS CHOSEN. A written path gave a barrel
			// and a clip identical flight; here a heavy thing turns lazily and a
			// light one snaps to the hand, off the actor's own Mass with no
			// table to maintain.
			double speed = RSQDG_Reach.MetresToUnits(
				RSQDG_Reach.Num("rsqdg_flight_speed", p, 12.0)) / TICRATE;
			Vector3 want = (toPalm / dist) * speed;

			double massRef = RSQDG_Reach.Num("rsqdg_mass_ref", p, 100.0);
			double mass = a.Mass > 1 ? double(a.Mass) : 1.0;
			double authority = clamp(massRef / mass, 0.1, 4.0);

			double maxAcc = RSQDG_Reach.MetresToUnits(
				RSQDG_Reach.Num("rsqdg_steer", p, 40.0)) / (TICRATE * TICRATE) * authority;

			Vector3 dv = want - a.Vel;
			double dvl = dv.Length();
			if (dvl > maxAcc) dv = (dv / dvl) * maxAcc;
			a.Vel = a.Vel + dv;
		}
	}

	override void WorldLoaded(WorldEvent e) { AbortAll(); }
	override void WorldUnloaded(WorldEvent e) { AbortAll(); }
}
