// THE INPUT AND THE LOCK.
//
// THREE ACTS, NOT TWO:
//
//   point   the cone considers it         neutral <-> amber
//   PRESS   you take hold of it at range  amber   <-> green
//   release you pull it, or let it go     the flash stops
//
// The press does not move anything. It says "that one", and keeps saying it
// until you let go, lose it, or launch it. Collapsing the press and the launch
// into one act removes the only moment where you can change your mind -- which
// is the whole reason the desktop build has a lock at all.
//
// THE LOCK IS ON THE PRESS EDGE, not on the hold, and this is a deliberate
// change from the desktop original, which moved it the other way. A per-tic
// hold test cannot distinguish "still grabbing" from "pressed the button for
// something else"; an edge can. The catch, later, stays on the hold for the
// reason the desktop comment gives.
class RSQDG_Grab : EventHandler
{
	// ---- THE POSE IS THE TRIGGER -------------------------------------------
	//
	// Turning your palm out arms the reach and HOLDS it. There is no button in
	// the gesture at all: the pose is the hold, the wrist flick is the pull, and
	// rolling your palm back is letting go. Three acts, one continuous motion,
	// nothing to press.
	//
	// AND A CONTINUOUSLY READABLE TRIGGER HAS NO LOST-RELEASE PROBLEM. This is
	// the real prize. A netevent is an EDGE -- a release swallowed by a focus
	// change or a menu would leave the grab stuck on forever -- which is why the
	// button path below still carries a timeout. The pose is read fresh every
	// tic from the controller, so it cannot get stuck: if your palm is not out,
	// you are not holding anything, and no bookkeeping is required to know that.
	//
	// The button survives as an optional fallback, off by default, for a desktop
	// test or for anyone who wants it. It is the only path that needs the lease.
	private bool armed[2];
	private int  lease[2];

	// Ten seconds, and ONLY for the button path. A deliberate grab-and-consider
	// is a second or two; ten is past any real one and still recovers within an
	// encounter.
	const LEASE_TICS = 350;

	// THE LOCK -- taken hold of, and still across the room.
	private Actor lockActor[2];

	// The last refusal reported per hand, so the trace says each one once.
	private transient String lastWhy[2];

	// The dwell before a self-lock: what the cone has held, and for how long.
	private transient Actor dwellOn[2];
	private transient int   dwellTics[2];

	static RSQDG_Grab Get()
	{
		return RSQDG_Grab(EventHandler.Find("RSQDG_Grab"));
	}

	Actor Locked(int hand) const
	{
		return (hand == 0 || hand == 1) ? lockActor[hand] : null;
	}

	bool Held(int hand) const
	{
		return (hand == 0 || hand == 1) && armed[hand];
	}

	// ---- the wire ----------------------------------------------------------
	//
	// NetworkProcess runs at the top of the tic, BEFORE P_PlayerThink and so
	// before WorldTick -- earlier than anything a usercmd bit could be read in.
	// It is `play` scope, so it may change the world, and it names the player.
	//
	// e.Player is who pressed it. We act only for the console player because the
	// decision was made from a local hand pose; a peer's press arrives with its
	// own player number and its own locally-made target, which is why the target
	// travels as a network ID rather than being re-derived here.
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqdg_press" && e.Name != "rsqdg_release") return;

		// OFF BY DEFAULT. The gesture is the trigger; this path exists for a
		// desktop test and for anyone who prefers a button. With both live they
		// simply both work -- the pose path sets `held` from the controller
		// every tic and this sets it from an edge, and whichever is true wins.
		{
			let pp = players[consoleplayer];
			if (pp && !RSQDG_Reach.Flag("rsqdg_button", pp, false)) return;
		}

		int hand = e.Args[0];
		if (hand != 0 && hand != 1) return;

		// TYPED AT THE CONSOLE IS NOT A GESTURE. IsManual distinguishes a real
		// bound press from somebody poking `netevent` by hand, and letting the
		// latter through would make the lock reachable without a controller --
		// useful for a bug report, confusing in a log.
		let p = players[e.Player >= 0 ? e.Player : consoleplayer];
		if (!p || !p.mo) return;

		if (e.Name == "rsqdg_press")
		{
			armed[hand]  = true;
			lease[hand] = LEASE_TICS;

			// A PRESS MEANS THE NEAREST THING IT COULD MEAN, in this order:
			//
			//   something arriving at this hand   -> catch it
			//   nothing in this hand yet          -> lock what the cone found
			//
			// The catch comes first because it is the one with a window. A lock
			// can be taken a moment later and nothing is lost; a catch missed is
			// the object on the floor.
			let fl = RSQDG_Flight.Get();
			if (fl && fl.CatchableBy(hand, p.mo, p))
			{
				if (fl.Catch(hand, p.mo, p)) return;
				// Refused -- it said why and the object is still flying. Fall
				// through: there may be something else worth locking.
			}

			TryLock(hand, p);
		}
		else
		{
			armed[hand]  = false;
			lease[hand] = 0;

			// Letting go of something you are CARRYING is a different act from
			// letting go of a lock, and only one of them can be true at a time.
			let hold = RSQDG_Hold.Get();
			if (hold && hold.HandIsFull(hand))
				hold.Release(hand, p);
			else if (lockActor[hand])
				Resolve(hand, p);
		}
	}

	// ---- taking hold -------------------------------------------------------
	//
	// EVERY REFUSAL SAYS WHY. These guards each returned false in silence in an
	// earlier generation of this mechanic, which made "the grab did nothing"
	// mean any of five different faults with one symptom and no way to tell them
	// apart from inside a headset. Named rather than numbered: a log line that
	// says "pose not trustworthy" is read once, and "refused at guard 3" is read
	// against this file forever.
	private void TryLock(int hand, PlayerInfo p)
	{
		String why = "";
		Actor a = null;

		let aim  = RSQDG_Aim.Get();
		let hold = RSQDG_Hold.Get();
		let fl   = RSQDG_Flight.Get();
		if (!aim)                      why = "RSQDG_Aim missing";
		else if (!aim.PoseGood())      why = "hand pose not trustworthy this tic";
		else if (hold && hold.HandIsFull(hand))
		                               why = "this hand is already holding something";
		// A HAND MID-PULL IS BUSY. Its palm is out because it is waiting to
		// catch, not because it is reaching for a second thing.
		else if (fl && fl.Flying(hand)) why = "this hand is already pulling something";
		else
		{
			a = aim.TargetFor(hand);
			if (!a)                    why = "nothing in the cone";
			else if (lockActor[hand])  why = "this hand already has a lock";
			// NOR OUT OF A HAND. There is no gesture meaning "take it out of my
			// own grip", so there is nothing this could have meant -- and
			// allowing it would have a second claimant save the first's
			// modified flags as the original.
			else if (hold && hold.IsHeld(a)) why = "a hand is already holding it";
			// NOT SOMETHING THE OTHER HAND IS ALREADY HOLDING.
			//
			// Not a harmless duplicate. Once this grab can change an object's
			// flags, two holders each save the object's true state before
			// touching it -- so the second save records what the FIRST holder
			// already changed as the "original", and whichever releases last
			// restores that fiction. The true values are overwritten and gone.
			//
			// There is no gesture that means "grab it with both hands", so
			// refusing is the whole fix. Refused at the LOCK rather than at the
			// launch, because a lock is what a launch turns into -- allowing the
			// second lock only defers the collision to the moment both fire.
			else if (lockActor[1 - hand] == a) why = "the other hand has it";
		}

		if (why != "")
		{
			// SAID ONCE, NOT EVERY TIC. With the pose as the trigger this runs
			// every tic the palm is out, so an unthrottled trace printed the same
			// refusal thirty-five times a second and buried everything else. A
			// reason is reported when it CHANGES, which is when it is news.
			if (why != lastWhy[hand] && RSQDG_Reach.Flag("rsqdg_trace", p, false))
				Console.Printf("[RSQDG] hand %d refused -- %s", hand, why);
			lastWhy[hand] = why;
			return;
		}
		lastWhy[hand] = "";

		lockActor[hand] = a;
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d LOCKED %s", hand, a.GetClassName());

		let feel = RSQDG_Feel.Get();
		if (feel) feel.OnLock(hand, a, p);
	}

	// ---- opening your hand -------------------------------------------------
	//
	// THE RELEASE IS WHERE THE DECISION IS MADE, and there is no separate launch
	// input to get wrong. Open your hand while the wrist is tipping up and the
	// object is pulled to you; open it at rest and you simply let go. The same
	// act means both things, and which one you got is decided by whether your
	// arm was doing anything.
	//
	// The desktop original says it best: "There is no separate flick input to
	// get wrong -- the same act means both things."
	private void Resolve(int hand, PlayerInfo p)
	{
		Actor a = lockActor[hand];
		if (!a) return;

		let aim = RSQDG_Aim.Get();
		double upRate = aim ? aim.PeakPitchUp(hand) : 0.0;
		double need = RSQDG_Reach.Num("rsqdg_flick_deg", p, 5.0);

		if (upRate >= need)
		{
			let fl = RSQDG_Flight.Get();
			if (fl && fl.Launch(hand, a, p.mo, p))
			{
				// The peak lingers in the window for a fifth of a second after
				// the motion stops, which is long enough to fire a second launch
				// the instant the first one lands.
				if (aim) aim.ForgetWrist(hand);
				lockActor[hand] = null;
				return;
			}
			// Launch refused -- it said why. Fall through and simply let go,
			// rather than leaving a lock nothing can now reach.
		}

		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d let go of %s (%.1f deg/tic, needed %.1f)",
				hand, a.GetClassName(), upRate, need);
		Unlock(hand, p, "opened at rest");
	}

	// EVERY ENDING A LOCK HAS THAT IS NOT A LAUNCH comes through here -- you
	// opened your hand, it died, it left range, the mechanic was switched off.
	// One place, so nothing can end a lock without the cleanup running.
	private void Unlock(int hand, PlayerInfo p, String reason)
	{
		Actor was = lockActor[hand];
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false) && was)
			Console.Printf("[RSQDG] hand %d unlocked %s -- %s",
				hand, was.GetClassName(), reason);
		lockActor[hand] = null;
		if (was)
		{
			let feel = RSQDG_Feel.Get();
			if (feel) feel.OnUnlock(hand, was);
		}
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo)
		{
			lockActor[0] = null; lockActor[1] = null;
			armed[0] = false; armed[1] = false;
			return;
		}

		if (p.mo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true))
		{
			// OFF HAS TO MEAN OFF. The desktop build switched its master cvar
			// off with something locked, and the handler that owned the lock
			// returned early while the lock survived -- so the object went on
			// pulsing and the beam went on being drawn for the rest of the
			// level, with the whole system supposedly disabled.
			if (lockActor[0]) Unlock(0, p, "switched off");
			if (lockActor[1]) Unlock(1, p, "switched off");
			armed[0] = false; armed[1] = false;
			lease[0] = 0; lease[1] = 0;
			return;
		}

		let pmo = p.mo;
		let aim = RSQDG_Aim.Get();
		bool poseGood = aim && aim.PoseGood();

		for (int h = 0; h < 2; h++)
		{
			// ---- THE POSE, READ FRESH ------------------------------------
			//
			// This is the trigger. Palm out and the hand is reaching; palm back
			// and it is not. Nothing is remembered, so nothing can get stuck --
			// which is the whole advantage over an edge-based input.
			//
			// A BAD POSE IS NOT A RELEASE. When the hand fields collapse to the
			// body the roll is whatever the body happens to be, so treating that
			// as "palm rolled back" would drop whatever you were holding every
			// time you opened a menu. The previous state is kept instead.
			bool poseHeld = armed[h];
			if (poseGood)
				poseHeld = RSQDG_Reach.PalmOk(pmo, p, h);

			if (RSQDG_Reach.Flag("rsqdg_button", p, false))
			{
				// The button path runs alongside, and its lease is the backstop
				// an edge needs. Either being true means held.
				if (armed[h] && !poseHeld)
				{
					if (--lease[h] <= 0)
					{
						armed[h] = false;
						if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
							Console.Printf("[RSQDG] hand %d lease expired -- a release went missing", h);
						if (lockActor[h]) Unlock(h, p, "lease expired");
					}
				}
				else if (poseHeld)
				{
					armed[h] = true;
					lease[h] = LEASE_TICS;
				}
			}
			else
			{
				// THE EDGE, DERIVED FROM A LEVEL. The pose is a level, and
				// letting go is the falling edge of it -- which is where the
				// flick is read, exactly as a button release would be.
				bool was = armed[h];
				armed[h] = poseHeld;
				if (was && !poseHeld)
				{
					let hold = RSQDG_Hold.Get();
					if (hold && hold.HandIsFull(h))      hold.Release(h, p);
					else if (lockActor[h])               Resolve(h, p);
				}
			}

			// ---- the lock takes itself -----------------------------------
			//
			// With no button there is no press edge to hang the lock on, so the
			// pose does it: while the reach is armed, whatever the cone has
			// becomes the lock, and then STICKS. Sticking is the point -- a
			// moment of wobble must not lose a target you already chose, and you
			// are allowed to look away from what you are holding.
			//
			// THE DWELL (G2, rsqdg_lock_dwell, tics; 0 = off and the old behaviour).
			// The lock took itself the first tic the cone had anything, so the amber
			// "could" glow flashed by before green. With a dwell the cone must hold
			// the SAME target that many tics first; a different target restarts it.
			// Only the pose path waits: a button press is already deliberate.
			if (armed[h] && !lockActor[h] && poseGood)
			{
				int need = int(RSQDG_Reach.Num("rsqdg_lock_dwell", p, 0));
				let aim2 = RSQDG_Aim.Get();
				Actor cand = aim2 ? aim2.TargetFor(h) : null;
				if (cand != dwellOn[h]) { dwellOn[h] = cand; dwellTics[h] = cand ? 1 : 0; }   // this tic counts
				else if (cand) dwellTics[h]++;
				if (need <= 0 || (cand && dwellTics[h] >= need))
					TryLock(h, p);
			}
			else { dwellOn[h] = null; dwellTics[h] = 0; }

			ValidateLock(h, p);
		}
	}

	// A LOCK IS NOT FOREVER. It survives you looking away -- you already decided
	// -- but not the object dying, not your hand opening, and not the thing
	// leaving the range you could have taken it from in the first place.
	//
	// An Actor pointer nulls itself when the actor dies, so a target crushed or
	// collected clears its own slot. Everything else is checked here.
	private void ValidateLock(int hand, PlayerInfo p)
	{
		Actor a = lockActor[hand];
		if (!a) return;

		if (!armed[hand]) { Unlock(hand, p, "hand opened"); return; }

		// STILL SOMETHING YOU MAY PULL. The policy's answer can change under a
		// lock: an Arch-Vile raises the corpse you were holding, another player
		// walks over the medikit, a switch is turned off in the menu. A living
		// monster is never pullable, and that has to stay true after the lock.
		let pol = RSQDG_Policy.Get();
		if (pol && !pol.Decide(a, p.mo, p)) { Unlock(hand, p, "no longer pullable"); return; }

		// A GENEROUS MARGIN, not the acquisition range. Acquiring needs
		// precision; keeping what you already chose should not punish a wobble.
		// 1.25x is the desktop figure and there is no reason to differ.
		double reach = RSQDG_Reach.Num("rsqdg_reach", p, 512.0) * 1.25;
		Vector3 mid = (a.Pos.x, a.Pos.y, a.Pos.z + a.Height * 0.5);
		Vector3 d = mid - RSQDG_Reach.Palm(p.mo, hand);
		Vector3 pd = (d.x, d.y, d.z * RSQDG_Reach.PIXELSTRETCH);
		if (pd.Length() > reach) Unlock(hand, p, "out of range");
	}

	override void WorldLoaded(WorldEvent e)
	{
		lockActor[0] = null; lockActor[1] = null;
		armed[0] = false; armed[1] = false;
		lease[0] = 0; lease[1] = 0;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		lockActor[0] = null; lockActor[1] = null;
		armed[0] = false; armed[1] = false;
		lease[0] = 0; lease[1] = 0;
	}
}
