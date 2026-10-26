// WHAT STATE A THING IS IN, SAID IN COLOUR.
//
//   considered   neutral <-> AMBER    the cone is on it
//   locked       amber   <-> GREEN    you have taken hold of it at range
//   in flight    nothing              the flash stops
//
// AMBER IS THE SHARED END of the first two cycles on purpose, so taking hold of
// something continues the colour it was already showing instead of starting a
// new one. The flash changes what it is DOING, not what it IS.
//
// REGISTERED LAST, so it draws what this tic decided rather than last tic's.
// Measurement first, decisions second, drawing last -- see MAPINFO.
//
// NOT A MODEL SWAP. The sprite-versus-model decision happens before any
// per-instance override is read, so hiding a voxel gets you an invisible object
// rather than a sprite. Translation works on either, and it is stock.
class RSQDG_Tell : EventHandler
{
	// SAVED BEFORE IT IS CHANGED, and restored to the SAVED VALUE rather than to
	// none. Plenty of actors ship with a translation already -- a mod's
	// recoloured ammo, a Hexen player class -- and blanket-clearing would strip
	// it off anything we ever pointed at, permanently, with nothing in the log
	// to say why.
	private Actor         litActor[2];
	private TranslationID litWas[2];

	private void ClearMark(int h)
	{
		// An Actor pointer nulls itself when the actor dies, so a target that
		// was crushed or collected clears its own slot -- but the saved
		// translation does not, and a stale one is what would be handed to an
		// unrelated object next time.
		if (litActor[h]) litActor[h].Translation = litWas[h];
		litActor[h] = null;
		litWas[h] = 0;
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) { ClearMark(0); ClearMark(1); return; }

		if (p.mo.Health <= 0
			|| !RSQDG_Reach.Flag("rsqdg_on", p, true)
			|| !RSQDG_Reach.Flag("rsqdg_lightup", p, true))
		{
			ClearMark(0); ClearMark(1);
			return;
		}

		let aim  = RSQDG_Aim.Get();
		let grab = RSQDG_Grab.Get();
		let fl   = RSQDG_Flight.Get();

		// Half a period on, half off. The point is SLOW -- fast enough to read
		// as alive, slow enough that a room full of pickups is not a strobe.
		double period = RSQDG_Reach.Num("rsqdg_flash", p, 24.0);
		if (period < 2) period = 2;
		bool phase = (int(level.time / (period * 0.5)) & 1) != 0;

		for (int h = 0; h < 2; h++)
		{
			Actor want = null;
			bool locked = false;

			// IN FLIGHT, THE FLASH STOPS ENTIRELY, and that is deliberate
			// rather than an omission. The arc IS the feedback by then: the
			// object is crossing the room at you and there is nothing left to
			// tell you. A thing still pulsing while it flies reads as
			// unfinished business.
			if (fl && fl.Flying(h))
			{
				ClearMark(h);
				continue;
			}

			// IN YOUR HAND: solid green, not flashing. It is the one state that
			// is not a question -- green means "mine" everywhere in this
			// language, and a thing you are already carrying has nothing left
			// to tell you.
			let hold = RSQDG_Hold.Get();
			if (hold && hold.HeldBy(h))
			{
				Actor hv = hold.HeldBy(h);
				if (litActor[h] != hv)
				{
					ClearMark(h);
					if (litActor[1 - h] != hv)
					{
						litWas[h] = hv.Translation;
						litActor[h] = hv;
					}
				}
				if (litActor[h])
					litActor[h].Translation = Translation.GetID("RSQDG_Held");
				continue;
			}

			// A LOCK OUTRANKS THE CONE. Once you have taken hold of something
			// the cone may well be pointing somewhere else -- you are allowed to
			// look away from what you are holding -- and the colour has to
			// follow what you own, not what you are aiming at.
			if (grab && grab.Locked(h))
			{
				want = grab.Locked(h);
				locked = true;
			}
			else if (aim)
			{
				want = aim.TargetFor(h);
			}

			if (litActor[h] != want)
			{
				ClearMark(h);

				// ONE HAND OWNS A GIVEN OBJECT'S COLOUR.
				//
				// Both hands can be pointing at the same thing -- that is the
				// normal way to two-hand something. Hand 0 marks it and writes
				// the hot translation. Hand 1 then captures `want.Translation`
				// as the "original" to restore later, and what it captures is
				// the value hand 0 just wrote. From then on hand 1 restores
				// HOT, and the object is permanently lit with nothing selecting
				// it, for the rest of its life.
				//
				// Save what you found, and only if you are the one who found it.
				// Exactly the same ownership trap that governs the flag backups
				// on a carried object, in a second place.
				if (want && litActor[1 - h] != want)
				{
					litWas[h] = want.Translation;
					litActor[h] = want;
				}
			}

			if (!litActor[h]) continue;

			// Locked pulses amber <-> green; considered pulses neutral <-> amber.
			litActor[h].Translation = locked
				? (phase ? Translation.GetID("RSQDG_Locked")
				         : Translation.GetID("RSQDG_Considered"))
				: (phase ? Translation.GetID("RSQDG_Considered")
				         : litWas[h]);
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		litActor[0] = null; litActor[1] = null;
		litWas[0] = 0; litWas[1] = 0;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		litActor[0] = null; litActor[1] = null;
		litWas[0] = 0; litWas[1] = 0;
	}
}
