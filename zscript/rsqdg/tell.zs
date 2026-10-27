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

	// The glow twins, one per hand (glow.zs).
	private RSQDG_Glow    glw[2];

	const COULD_COLOR = 0xFFB030;
	const HAVE_COLOR  = 0x40FF70;

	// "Could" vs "have" on light: which thing each hand is about, and how
	// strongly. Run first and on its own switch, so it works with the colour
	// flash on, off, or both.
	private void UpdateGlow(PlayerInfo p)
	{
		bool on = p && p.mo && p.mo.Health > 0
			&& RSQDG_Reach.Flag("rsqdg_on", p, true)
			&& RSQDG_Reach.Flag("rsqdg_glow", p, true);

		Actor want[2];
		bool have[2];
		let aim  = RSQDG_Aim.Get();
		let grab = RSQDG_Grab.Get();
		let fl   = RSQDG_Flight.Get();
		for (int h = 0; h < 2; h++)
		{
			want[h] = null; have[h] = false;
			if (!on || (fl && fl.Flying(h))) continue;
			Actor lk = grab ? grab.Locked(h) : null;
			if (lk) { want[h] = lk; have[h] = true; }
			else if (aim) want[h] = aim.TargetFor(h);
		}
		// One glow per object. Both hands on the same thing: the stronger
		// state shows, once.
		if (want[0] && want[0] == want[1])
		{
			have[0] = have[0] || have[1];
			want[1] = null;
		}

		Vector3 eye = p && p.mo ? (p.mo.Pos.x, p.mo.Pos.y, p.viewz) : (0, 0, 0);
		double t = level.maptime;
		double gain = clamp(RSQDG_Reach.Num("rsqdg_glow_a", p, 1.0), 0.0, 2.0);
		for (int h = 0; h < 2; h++)
		{
			Actor a = want[h];
			// A host with no sprite to wear (TNT1, or invisible) gets no glow; nor a
			// host drawn as a VOXEL -- it gets the colour flash instead (G7, below).
			if (!a || a.bINVISIBLE || a.sprite == 0 || VoxelFlash(a, p))
			{
				if (glw[h]) glw[h].Hide();
				continue;
			}
			if (!glw[h])
			{
				glw[h] = RSQDG_Glow(Actor.Spawn("RSQDG_Glow", a.Pos));
				if (!glw[h]) continue;
			}
			// How it looks: GlowLook (below).
			double alph, rim; int col;
			[alph, col, rim] = GlowLook(have[h], t);
			glw[h].Follow(a, eye, clamp(alph * gain, 0.0, 1.0), col, rim);
		}
	}

	// THE GLOW'S LOOK at map time t: brightness, colour, rim (the twin's size over the host's).
	// The saber's breath: 0.15..0.50, once every 60 tics (cos is in degrees), at 0.55 for
	// "could". "Have" breathes twice as fast and burns a little brighter -- but tops out at
	// 0.32: in the rig a green barrel under 0.55 of additive green was a solid slab with its own
	// detail gone, and at ~0.15 the stave lines show through. Colour and tempo carry the
	// difference; brightness only helps.
	// COLOUR-BLIND PLAY (rsqa_colorblind, cb.zs): the series' pair for that vision, and not
	// colour alone -- "have" burns clearly brighter than "could" (0.22..0.42 against 0.05..0.18,
	// no overlap) and wears a wider rim; the tempo stays twice as fast.
	static double, int, double GlowLook(bool have, double t)
	{
		if (!RSQDG_CB.Mode())
		{
			if (have) return 0.12 + 0.20 * (0.5 - 0.5 * cos(t * 12.0)), HAVE_COLOR, 1.06;
			return (0.15 + 0.35 * (0.5 - 0.5 * cos(t * 6.0))) * 0.55, COULD_COLOR, 1.06;   // the saber's exact "could"
		}
		if (have) return 0.22 + 0.20 * (0.5 - 0.5 * cos(t * 12.0)), RSQDG_CB.Pick(RSQDG_CB.CB_HAVE, HAVE_COLOR), 1.14;
		return 0.05 + 0.13 * (0.5 - 0.5 * cos(t * 6.0)), RSQDG_CB.Pick(RSQDG_CB.CB_COULD, COULD_COLOR), 1.06;
	}

	// A voxel-drawn host takes the colour flash instead of the glow twin.
	private static bool VoxelFlash(Actor a, PlayerInfo p)
	{
		// Only while the glow is on: it flashes INSTEAD of the glow, so with the
		// glow switched off a voxel is left alone like everything else (review).
		return RSQDG_Reach.Flag("rsqdg_glow", p, true)
			&& RSQDG_Reach.Flag("rsqdg_voxel_flash", p, true) && RSQDG_Voxels.Drawn(a);
	}

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
		UpdateGlow(p);
		if (!p || !p.mo) { ClearMark(0); ClearMark(1); return; }

		if (p.mo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true))
		{
			ClearMark(0); ClearMark(1);
			return;
		}
		// With the flash off (the default) it still runs for VOXEL hosts, which
		// the glow twin cannot light (G7); everything else is the glow's.
		bool lightAll = RSQDG_Reach.Flag("rsqdg_lightup", p, true);

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
			if (hold && hold.HeldBy(h) && !lightAll && !VoxelFlash(hold.HeldBy(h), p))
			{
				ClearMark(h);
				continue;
			}
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
					litActor[h].Translation = Translation.GetID("RSQDG_Held" .. RSQDG_CB.Suffix());
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

			if (want && !lightAll && !VoxelFlash(want, p)) want = null;

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
				? (phase ? Translation.GetID("RSQDG_Locked" .. RSQDG_CB.Suffix())
				         : Translation.GetID("RSQDG_Considered" .. RSQDG_CB.Suffix()))
				: (phase ? Translation.GetID("RSQDG_Considered" .. RSQDG_CB.Suffix())
				         : litWas[h]);
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		// A SAVEGAME KEEPS WHAT IT LIT, and this handler's record of what to
		// put back (both serialized). Clearing the record here is what left a
		// thing lit for good after a load (review).
		if (e.IsSaveGame) return;
		litActor[0] = null; litActor[1] = null;
		litWas[0] = 0; litWas[1] = 0;
		glw[0] = null; glw[1] = null;
		// A hub snapshot may have kept twins from an older visit.
		let it = ThinkerIterator.Create("RSQDG_Glow");
		Actor old;
		while (old = Actor(it.Next())) old.Destroy();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		// PUT BACK, then forget: in a hub this level is kept as it is left, and
		// an object left recoloured -- or a twin left glowing, frozen, its Tick
		// waiting for a host -- would greet the player on the way back.
		ClearMark(0); ClearMark(1);
		for (int h = 0; h < 2; h++)
		{
			if (glw[h]) glw[h].Destroy();
			glw[h] = null;
		}
	}
}
