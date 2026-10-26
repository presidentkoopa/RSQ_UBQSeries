// THE BEAM.
//
// WHY VisualThinker AND NOT A PSPRITE, AND NOT 84 ACTORS.
//
// There is no beam native on this engine -- the fork's Level.SetBeam, ClaimBeam
// and SetBeamStyleScroll are zero hits here and will not be added. Three routes
// remain and only one of them is right:
//
//   2D drawing from a ui hook  -- WRONG SURFACE. In VR every 2D draw command is
//     composited onto a flat head-locked quad: getHUDProjection() puts it at
//     vr_hud_distance 1.0 m, vr_hud_scale 0.25, pitched 10 degrees. It is a half
//     metre rectangle a metre in front of your face that follows your head. It
//     cannot carry anything anchored in the world.
//
//   a psprite model            -- RIGHT RATE, WRONG DEPTH. HUD models always
//     draw in front of the world; the renderer squashes their depth range to
//     the near 30% specifically to stop a view model poking into walls. A beam
//     drawn there passes through geometry. It is also deleted outright while a
//     weapon is two-hand stabilised, with no warning to script.
//
//   VisualThinker              -- world-space, DEPTH-CORRECT, interpolated by
//     the renderer off Prev, and free below a ticking statnum. This is the one.
//
// And the count matters. An earlier generation of this drew its volume with 84
// beams per hand REBUILT EVERY TIC and destroyed the framerate. These are
// pooled: allocated once, repositioned, and hidden by alpha rather than
// destroyed. Nothing is spawned after the first frame it is needed.
class RSQDG_Bead : VisualThinker
{
	// UpdateSector is protected, so moving one of these from outside needs a
	// method on the class itself. Without the call the thinker keeps the sector
	// it was spawned in, which decides its light level and whether it is culled
	// -- so a bead dragged across a room would stay lit by the room it was born
	// in and vanish when that room is out of view.
	void Place(Vector3 p, bool teleport = false)
	{
		Pos = p;
		if (teleport)
		{
			// Prev is what the renderer interpolates FROM. Rebuilding the chain
			// without this smears every bead from wherever it last was, which
			// at headset rate reads as the beam snapping into place from a
			// random direction.
			Prev = p;
			PrevRoll = Roll;
		}
		UpdateSector();
	}

	void Hide()
	{
		Alpha = 0.0;
	}

	// Driven entirely from the handler. An empty Tick keeps the renderer's
	// interpolation working off Pos/Prev without the thinker trying to move
	// itself, and costs a call.
	override void Tick() {}
}


// THE LASER, IN LAYERS.
//
// Four of them, and which ones you get is the quality tier:
//
//   1  core      a thin bright line. The beam itself.
//   2  + halo    a wider, dimmer line underneath. This is what makes it read as
//                light rather than as a row of dots.
//   3  + motes   a few beads travelling along the line TOWARD the palm. This is
//                the reeling motion, and it is what the fork's scrolling beam
//                style was for.
//   4  + flare   a larger pulse at the far end, on the thing itself.
//
// Every magnitude is a cvar. "Damn the cost" means the owner chooses, not that
// the cost goes unmeasured -- so the bead count per tier is stated here:
// low 10, medium 26, high 48 per active hand, and a bead is one sprite draw.
class RSQDG_Laser : EventHandler
{
	const MAX_BEADS = 48;

	private RSQDG_Bead bead[2 * MAX_BEADS];
	private int live[2];          // how many of this hand's beads are in use
	private bool built[2];
	private TextureID glow;

	override void OnRegister()
	{
		glow = TexMan.CheckForTexture("RSQDGLO", TexMan.Type_Any);
	}

	// ---- how many beads each layer gets at this quality ---------------------
	//
	// Returned together so the budget is visible in one place rather than
	// scattered through the drawing code.
	private int, int, int, int Budget(PlayerInfo p)
	{
		int q = RSQDG_Reach.Opt("rsqdg_laser", p, 3);
		if (q <= 0) return 0, 0, 0, 0;
		if (q == 1) return 10, 0,  0, 0;    // core only
		if (q == 2) return 14, 10, 0, 2;    // core + halo + flare
		return 18, 14, 12, 4;               // everything
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) { HideAll(); return; }
		let pmo = p.mo;

		if (pmo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true))
		{
			HideAll();
			return;
		}

		int nCore, nHalo, nMote, nFlare;
		[nCore, nHalo, nMote, nFlare] = Budget(p);
		if (nCore == 0) { HideAll(); return; }

		let aim  = RSQDG_Aim.Get();
		let grab = RSQDG_Grab.Get();
		let fl   = RSQDG_Flight.Get();
		let hold = RSQDG_Hold.Get();

		// A BAD POSE DRAWS NOTHING, rather than drawing a beam out of the
		// player's chest. The hand fields collapse to the body when a menu is
		// open, so the alternative is a laser that lurches to the navel and
		// back every time the player checks a setting.
		if (!aim || !aim.PoseGood()) { HideAll(); return; }

		for (int h = 0; h < 2; h++)
		{
			DrawHand(h, pmo, p, aim, grab, fl, hold, nCore, nHalo, nMote, nFlare);
		}
	}

	private void DrawHand(int h, PlayerPawn pmo, PlayerInfo p,
		RSQDG_Aim aim, RSQDG_Grab grab, RSQDG_Flight fl, RSQDG_Hold hold,
		int nCore, int nHalo, int nMote, int nFlare)
	{
		// NO BEAM WHILE SOMETHING IS IN THE AIR OR IN THE HAND. The arc is the
		// feedback at that point -- the object is crossing the room at you --
		// and a line still reaching out past it reads as unfinished business.
		// The same reasoning that stops the colour flash during flight.
		if ((fl && fl.Flying(h)) || (hold && hold.HandIsFull(h)))
		{
			HideHand(h);
			return;
		}

		Actor locked = grab ? grab.Locked(h) : null;
		Actor aimed  = locked ? locked : aim.TargetFor(h);

		Vector3 from = RSQDG_Reach.Palm(pmo, h);
		Vector3 to;
		bool onThing = false;

		if (aimed)
		{
			to = (aimed.Pos.x, aimed.Pos.y, aimed.Pos.z + aimed.Height * 0.5);
			onThing = true;
		}
		else
		{
			// THE IDLE LINE DRAWS ANYWAY, and this is a ported rule rather than
			// a flourish. A laser that only appears once it has found something
			// gives you no way to learn where you are pointing -- you cannot
			// aim an invisible thing, so every miss looks identical to the
			// mechanic being broken.
			// AND THE SAME PALM GATE THE CONE USES, read the same way, so what
			// you see and what will happen cannot disagree. Turning your palm
			// out is what summons the beam; a hand in a gun grip has none.
			//
			// This is the tell doing real work rather than decorating: the beam
			// appearing IS the feedback that the reach is armed, which is a
			// thing you can learn in one session without being told.
			if (!RSQDG_Reach.Flag("rsqdg_laser_idle", p, true)
				|| !RSQDG_Reach.PalmOk(pmo, p, h))
			{
				HideHand(h);
				return;
			}

			double reach = RSQDG_Reach.Num("rsqdg_reach", p, 512.0);
			Vector3 dir = RSQDG_Reach.Dir(pmo, h);

			// CLIPPED AT THE FIRST SURFACE. LineTrace is the cheapest
			// hand-origin query the engine has -- one blockmap walk, no puff,
			// no event, no world change -- and it is what stops the idle line
			// disappearing into a wall and reappearing in the next room.
			//
			// TRF_ABSPOSITION with coordinates computed here, NEVER the offset
			// parameters: P_LineTrace accumulates its offsets onto an
			// UNINITIALISED stack vector, reachable precisely when
			// OverrideAttackPosDir is true (which is always, in VR) and either
			// offset is non-zero. Passing zero offsets avoids the branch
			// entirely.
			FLineTraceData t;
			bool hit = pmo.LineTrace(
				RSQDG_Reach.Yaw(pmo, h), reach, RSQDG_Reach.Pitch(pmo, h),
				TRF_ABSPOSITION | TRF_THRUACTORS,
				from.z, from.x, from.y, t);

			to = hit ? t.HitLocation : (from + dir * reach);
		}

		// ---- the colour --------------------------------------------------
		//
		// The same three states the object's own flash uses, so the line and
		// the thing it points at can never disagree about what is happening.
		Color c;
		if (locked)      c = Color(255, 110, 255, 150);   // locked: green
		else if (onThing) c = Color(255, 255, 190,  80);  // considered: amber
		else              c = Color(255, 150, 195, 255);  // idle: cold blue

		double thick = RSQDG_Reach.Num("rsqdg_laser_core_w", p, 1.1);
		double haloW = RSQDG_Reach.Num("rsqdg_laser_halo_w", p, 4.5);
		double aCore = RSQDG_Reach.Num("rsqdg_laser_core_a", p, 0.85);
		double aHalo = RSQDG_Reach.Num("rsqdg_laser_halo_a", p, 0.22);

		// Dimmer when it has found nothing, so "considering something" is a
		// change the eye catches rather than a colour you have to read.
		if (!onThing)
		{
			aCore *= 0.45;
			aHalo *= 0.45;
		}

		int at = 0;
		Vector3 span = to - from;

		// ---- the core ----------------------------------------------------
		//
		// Spaced evenly and overlapping. The beads are round, so a gap between
		// them reads as dots; an overlap of about half a bead reads as a line.
		for (int i = 0; i < nCore; i++)
		{
			double t2 = (i + 0.5) / double(nCore);
			at = Put(h, at, from + span * t2, thick, aCore, c);
		}

		// ---- the halo ----------------------------------------------------
		//
		// Wider and much dimmer, drawn additively over the core. This is the
		// layer that does the work: a bare core is a hard line, and a hard line
		// in a dark room looks like a wireframe rather than light.
		for (int i = 0; i < nHalo; i++)
		{
			double t2 = (i + 0.5) / double(nHalo);
			at = Put(h, at, from + span * t2, haloW, aHalo, c);
		}

		// ---- the motes ---------------------------------------------------
		//
		// Travelling TOWARD the palm, always, because the mechanic pulls. This
		// is the direction cue the fork got from a scrolling beam style, and
		// doing it with discrete beads is both cheaper and clearer -- a scroll
		// is a texture trick that reads as motion only if you already know what
		// it means, whereas something visibly moving along the line does not
		// need explaining.
		//
		// They SPEED UP as they arrive, by squaring the phase. A constant rate
		// reads as a conveyor belt; accelerating reads as being drawn in.
		if (nMote > 0)
		{
			double rate = RSQDG_Reach.Num("rsqdg_laser_mote_hz", p, 0.9);
			double moteW = RSQDG_Reach.Num("rsqdg_laser_mote_w", p, 2.6);
			double base = (level.time * rate) / TICRATE;
			for (int i = 0; i < nMote; i++)
			{
				double ph = base + double(i) / double(nMote);
				ph = ph - floor(ph);
				// 1 - ph so they run target -> palm, squared so they accelerate.
				double t2 = 1.0 - (ph * ph);
				// Fade in at the far end and out at the palm, so nothing pops
				// into existence or vanishes mid-air.
				double fade = sin(180.0 * ph);
				at = Put(h, at, from + span * t2, moteW,
					aCore * 0.7 * fade, c);
			}
		}

		// ---- the terminus flare ------------------------------------------
		//
		// On the thing, not on the line, and only when there IS a thing. It
		// pulses with the same period as the object's own colour flash so the
		// two read as one event rather than two.
		if (nFlare > 0 && onThing)
		{
			double period = RSQDG_Reach.Num("rsqdg_flash", p, 24.0);
			if (period < 2) period = 2;
			double pulse = 0.5 + 0.5 * sin(360.0 * (level.time / period));
			double fw = RSQDG_Reach.Num("rsqdg_laser_flare_w", p, 9.0);
			for (int i = 0; i < nFlare; i++)
			{
				// Stacked at one point rather than spread: several overlapping
				// soft sprites make a bright centre with a soft edge, which one
				// sprite scaled up cannot do.
				at = Put(h, at, to, fw * (1.0 + 0.35 * i),
					(aHalo + 0.10 * pulse) / (1.0 + i), c);
			}
		}

		// Everything this hand did not use this tic goes invisible rather than
		// being destroyed. Destroying and respawning is what made the first
		// attempt at this unplayable.
		for (int i = at; i < live[h]; i++)
		{
			let b = bead[h * MAX_BEADS + i];
			if (b) b.Hide();
		}
		live[h] = at;
	}

	// Place one bead, allocating it the first time it is needed. Returns the
	// next free index.
	private int Put(int h, int at, Vector3 pos, double w, double a, Color c)
	{
		if (at >= MAX_BEADS) return at;
		int k = h * MAX_BEADS + at;

		let b = bead[k];
		bool fresh = false;
		if (!b)
		{
			b = RSQDG_Bead(VisualThinker.Spawn("RSQDG_Bead", glow, pos,
				(0, 0, 0), a, 0, 0.0, (w, w), (0, 0), STYLE_Add));
			bead[k] = b;
			fresh = true;
			if (!b) return at;
		}

		b.Scale = (w, w);
		b.Alpha = a;
		b.scolor = c;
		// Teleported on its first frame so it does not streak in from wherever
		// Spawn put it, and whenever it has been hidden -- a bead coming back
		// from alpha 0 has a Prev from minutes ago.
		b.Place(pos, fresh || at >= live[h]);
		return at + 1;
	}

	private void HideHand(int h)
	{
		for (int i = 0; i < live[h]; i++)
		{
			let b = bead[h * MAX_BEADS + i];
			if (b) b.Hide();
		}
		live[h] = 0;
	}

	private void HideAll()
	{
		HideHand(0);
		HideHand(1);
	}

	// A level change destroys the thinkers; the pointers do not clear
	// themselves, and a stale one would be written to on the next map.
	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < 2 * MAX_BEADS; i++) bead[i] = null;
		live[0] = 0; live[1] = 0;
	}
}
