// CARRYING IT. One object per hand, from the catch until you let go.
//
// A PLAIN EventHandler, NOT A StaticEventHandler, and that is load-bearing.
//
// The saved flags below are the ONLY record that a held object was ever normal.
// The object's own flags are serialized by the engine; if the backup that undoes
// them is not serialized alongside, a save taken while you are holding something
// restores the MODIFIED object and loses the record of what it used to be --
// permanently weightless, permanently unpickable, and nothing in the log.
//
// A plain EventHandler's fields are serialized with the level. A
// StaticEventHandler is marked transient and its fields are NOT. So the split is
// forced: measurement may be static, held-object state may not.
class RSQDG_Hold : EventHandler
{
	private Actor held[2];

	// ---- the borrowed state, one owner --------------------------------------
	//
	// Captured BEFORE the first mutation and restored on every exit. The flight
	// hands the object over with its TRUE flags already put back, precisely so
	// that what gets saved here is the truth rather than what the flight
	// imposed. That handover order is not incidental -- it is the whole fix for
	// the trap the desktop tree documents three times.
	private bool   savedNoGrav[2];
	private bool   savedThruActors[2];
	private bool   savedSpecial[2];

	// WHERE THE OBJECT SITS, FROZEN rather than recomputed when the pose lies.
	//
	// This is a requirement no existing implementation has, because none of them
	// holds anything across a menu opening. The VR hand fields do not freeze when
	// a menu opens -- they COLLAPSE TO THE BODY -- so a carry that re-solved its
	// position from the live hand point every tic would yank the held object into
	// the player's chest and keep it there for as long as the menu stayed open,
	// then snap it back out.
	//
	// Ignoring gestures during a bad pose is not enough. The POSITION has to
	// freeze too.
	private Vector3 frozenAt[2];
	private bool    frozen[2];

	static RSQDG_Hold Get()
	{
		return RSQDG_Hold(EventHandler.Find("RSQDG_Hold"));
	}

	bool HandIsFull(int hand) const
	{
		return (hand == 0 || hand == 1) && held[hand] != null;
	}

	Actor HeldBy(int hand) const
	{
		return (hand == 0 || hand == 1) ? held[hand] : null;
	}

	bool IsHeld(Actor a) const
	{
		return a && (held[0] == a || held[1] == a);
	}

	// ---- taking it ---------------------------------------------------------
	//
	// Called by the flight on a successful catch, with the object's true flags
	// already restored. Returns false if it could not be taken, so the caller
	// can leave it in the air rather than dropping it on a refusal.
	bool Take(int hand, Actor a, PlayerInfo p)
	{
		if (hand != 0 && hand != 1 || !a) return false;
		if (held[hand]) return false;

		// NOT OUT OF THE OTHER HAND. Two holders would each save the object's
		// state before touching it, so the second records what the first already
		// changed as the "original". Whichever releases last restores that
		// fiction and the true values are gone.
		if (held[1 - hand] == a) return false;

		savedNoGrav[hand]     = a.bNOGRAVITY;
		savedThruActors[hand] = a.bTHRUACTORS;
		savedSpecial[hand]    = a.bSPECIAL;

		// Weightless while carried, pass-through so it does not fight your own
		// collision cylinder, and not collectable by walking over your own hand.
		a.bNOGRAVITY  = true;
		a.bTHRUACTORS = true;
		a.bSPECIAL    = false;
		a.Vel = (0, 0, 0);

		held[hand] = a;
		frozen[hand] = false;

		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d CAUGHT %s", hand, a.GetClassName());
		return true;
	}

	// ---- letting go --------------------------------------------------------
	//
	// THE RELEASE DECIDES, by the same rule the launch uses: open your hand while
	// it is moving and the object is thrown; open it at rest and it simply drops.
	// One act, two meanings, and which one you got is decided by whether your arm
	// was doing anything.
	void Release(int hand, PlayerInfo p)
	{
		Actor a = held[hand];
		if (!a) return;

		a.bNOGRAVITY  = savedNoGrav[hand];
		a.bTHRUACTORS = savedThruActors[hand];
		a.bSPECIAL    = savedSpecial[hand];

		// THE THROW. Hand velocity differenced from the palm, because there is
		// no native hand velocity on this engine -- the fork's AttackVel does
		// not exist here.
		//
		// A BAD POSE THROWS NOTHING. The collapse to the body position would
		// otherwise read as the hardest throw of the session, launching whatever
		// you were holding across the map the instant you opened a menu.
		Vector3 v = (0, 0, 0);
		let aim = RSQDG_Aim.Get();
		if (aim && aim.PoseGood() && !frozen[hand])
			v = aim.PalmVelocity(hand) * RSQDG_Reach.Num("rsqdg_throw_scale", p, 1.0);

		// THE ARM'S PART IS MEASURED AGAINST THE BODY (aim.zs), so walking is
		// not a throw. But a real throw thrown while running carries the run:
		// so the body's own velocity is added back ONLY when the arm actually
		// threw. Opening a still hand while walking drops the thing where it
		// is; flinging it while running sends it further than standing still.
		bool thrown = RSQDG_Reach.Metres(v) * TICRATE > 0.5;
		if (thrown && p.mo) v += p.mo.Vel;

		a.Vel = v;

		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d released %s at %.1f m/s",
				hand, a.GetClassName(), RSQDG_Reach.Metres(v) * TICRATE);

		held[hand] = null;
		frozen[hand] = false;

		// A throw is anything faster than a gentle set-down: half a metre a
		// second. Below that it is a drop, and says so to anyone listening.
		let feel = RSQDG_Feel.Get();
		if (feel) feel.OnRelease(hand, a, thrown);
	}

	// Put it back the way it was found and forget it. Not a drop and not a
	// throw -- this is the path for a hold that cannot continue: the mechanic
	// switched off, the player died, the level ended.
	void Drop(int hand)
	{
		Actor a = held[hand];
		if (a)
		{
			a.bNOGRAVITY  = savedNoGrav[hand];
			a.bTHRUACTORS = savedThruActors[hand];
			a.bSPECIAL    = savedSpecial[hand];
			a.Vel = (0, 0, 0);
			// Told, like every other ending, so a listener that dressed the
			// thing can undress it -- switched off, died, level change.
			RSQDG_Events.Tell("hold.drop", hand, a);
		}
		held[hand] = null;
		frozen[hand] = false;
	}

	void DropAll()
	{
		Drop(0);
		Drop(1);
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) { DropAll(); return; }
		let pmo = p.mo;

		// OFF HAS TO MEAN OFF, and that includes handing back everything
		// borrowed. A held object left weightless and pass-through after the
		// mechanic was switched off is an object nothing in the game will ever
		// put right.
		if (pmo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true))
		{
			DropAll();
			return;
		}

		let aim = RSQDG_Aim.Get();
		bool good = aim && aim.PoseGood();

		for (int h = 0; h < 2; h++)
		{
			Actor a = held[h];
			if (!a) { frozen[h] = false; continue; }

			if (!good)
			{
				// FREEZE WHERE IT IS, once, and leave it there. Not "carry on
				// from the body position", which is what reading the live hand
				// point would do.
				if (!frozen[h])
				{
					frozenAt[h] = a.Pos;
					frozen[h] = true;
				}
				a.SetOrigin(frozenAt[h], true);
				a.Vel = (0, 0, 0);
				continue;
			}
			frozen[h] = false;

			// Carried AT the palm. SetOrigin with interpolation telling the
			// renderer this is a continuous move rather than a teleport --
			// without it the object strobes between tics at headset rate.
			Vector3 palm = RSQDG_Reach.Palm(pmo, h);
			a.SetOrigin((palm.x, palm.y, palm.z - a.Height * 0.5), true);
			a.Vel = (0, 0, 0);
		}
	}

	override void WorldLoaded(WorldEvent e) { DropAll(); }
	override void WorldUnloaded(WorldEvent e) { DropAll(); }
}
