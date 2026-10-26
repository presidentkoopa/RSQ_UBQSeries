// MEASUREMENT. Runs the cone, publishes what each hand is pointing at, and
// does nothing else.
//
// REGISTERED FIRST, and that is the semantics rather than a formality. Handlers
// tick in registration order and that decides who sees whose writes inside one
// tic. The desktop build's catch test lived in a handler registered 4th and
// asked "is the flying object on my palm" BEFORE the handler registered 7th
// wrote the object's new position -- so the only position it ever saw was last
// tic's, ~23 units short, against a volume needing <= 1.0 where it scored ~17.
// The window was not tight, it was shut, and it passed testing because the
// residual error is a constant number of units and so hides entirely at arm's
// reach.
//
// So: this publishes, RSQDG_Grab decides, RSQDG_Tell draws. Nothing in this
// file writes to the playsim and nothing else in the package runs the cone.
class RSQDG_Aim : EventHandler
{
	private Actor target[2];

	// WHY THE CONE IS NOT RUN BY ITS CONSUMERS. It is a blockmap walk per hand
	// per tic, and two callers would also be free to disagree about the answer
	// -- which in a headset reads as the aim being randomly off and is
	// unfalsifiable from inside the game.
	static RSQDG_Aim Get()
	{
		return RSQDG_Aim(EventHandler.Find("RSQDG_Aim"));
	}

	Actor TargetFor(int hand) const
	{
		return (hand == 0 || hand == 1) ? target[hand] : null;
	}

	// Whether the pose is trustworthy this tic. Published rather than re-derived
	// so the lock and the carry cannot disagree with the drawing about it.
	private bool poseTrusted;
	bool PoseGood() const { return poseTrusted; }

	override void WorldTick()
	{
		// consoleplayer, because the VR pose fields are written for the camera
		// player alone and hold class defaults for everyone else -- both writers
		// key on `r_viewpoint.camera` and touch only that pawn. There is no path
		// by which a peer's hand pose reaches this machine.
		//
		// So this is a LOCAL read for a LOCAL decision. What it decides travels
		// afterwards as a command carrying a network ID, never as a position.
		let p = players[consoleplayer];
		if (!p || !p.mo)
		{
			target[0] = null; target[1] = null; poseTrusted = false;
			return;
		}
		let pmo = p.mo;

		if (pmo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true))
		{
			target[0] = null; target[1] = null; poseTrusted = false;
			return;
		}

		// THE POSE COLLAPSES TO THE BODY WHEN A MENU IS OPEN -- it does not
		// freeze, which is the trap.
		//
		// OpenXRDeviceMode::SetUp() calls its base unconditionally and only then
		// gates the hand block on `gamestate == GS_LEVEL && menuactive ==
		// MENU_Off` (hw_openxrdevice.cpp:568). The level still renders behind an
		// open menu, so the fields fall back to the pawn's attack point, yaw
		// becomes viewYaw - 90 and pitch -viewPitch. The first frame after the
		// menu closes therefore reads as a one-metre swing.
		//
		// LATCHED ON A JUMP, NOT ON `menuactive`, and on purpose. Whether a mod
		// can read `menuactive` from play scope is not established -- stock's own
		// play code does it, but that is stock reading its own symbol. A jump
		// threshold needs no engine symbol at all, catches tracking loss as well
		// as menus, and cannot be wrong about something it does not consult.
		//
		// A metre in a single tic is 28.6 ms of arm movement. No arm does that.
		// IN THE BODY'S FRAME, NOT THE WORLD'S (PORT_SCOPE A2).
		//
		// The hand is measured relative to the pawn and un-rotated by the
		// pawn's yaw before it is differenced. Two things fall out of that for
		// free, with no accumulator and no engine symbol:
		//
		//   - WALKING IS NOT A THROW. The world position of your hand changes
		//     at walking speed while your arm is still; relative to the body it
		//     does not move at all. Opening a hand while walking used to throw.
		//   - A TURN IS NOT A THROW. A snap turn swings the whole tracking
		//     space, hand included, through 45 degrees about the pawn in one
		//     tic -- a third of a metre of "hand motion" in 28 ms, the hardest
		//     sideways throw of the session. Un-rotated, hand and pawn turn
		//     together and cancel.
		//
		// This is lane 1's fix for rs_swing.zs, in about fifteen lines instead
		// of a port. The fork used native hand velocity and VRTurnYaw for it;
		// stock has neither and, framed this way, needs neither.
		//
		// The jump test uses the same body-frame delta, so a teleporter or a
		// fast lift no longer reads as tracking having lied.
		poseTrusted = true;
		double yaw = pmo.Angle;
		for (int h = 0; h < 2; h++)
		{
			Vector3 now = RSQDG_Reach.Palm(pmo, h);
			Vector3 off = now - pmo.Pos;
			Vector2 flat = Actor.RotateVector(off.xy, -yaw);
			Vector3 rel = (flat.x, flat.y, off.z);

			Vector3 dRel = rel - lastRel[h];
			if (primed[h])
			{
				double jumped = RSQDG_Reach.Metres(dRel);
				if (jumped > RSQDG_Reach.Num("rsqdg_jump_m", p, 1.0))
					poseTrusted = false;
			}
			// A bad pose contributes a ZERO sample rather than the collapse
			// delta, which would otherwise be the hardest throw of the session.
			palmVel[h * PITCH_WINDOW + palmAt[h]] =
				(primed[h] && poseTrusted) ? dRel : (0, 0, 0);
			palmAt[h] = (palmAt[h] + 1) % PITCH_WINDOW;

			lastRel[h] = rel;
			primed[h] = true;
		}
		bodyYaw = yaw;

		// The wrist is sampled whatever the pose is doing, because the sampler
		// needs an unbroken chain to difference against -- it just contributes
		// zero on a tic it cannot trust.
		SampleWrist(pmo, 0, poseTrusted);
		SampleWrist(pmo, 1, poseTrusted);

		// Hold last tic's answer through a bad pose rather than acquiring from
		// the body. Every consumer must do the same: a carry that recomputed
		// from the live hand point would drag a held object into the player's
		// chest for as long as the menu stayed open.
		if (!poseTrusted) return;

		target[0] = RSQDG_Cone.Best(pmo, p, 0);
		target[1] = RSQDG_Cone.Best(pmo, p, 1);
	}

	private Vector3 lastRel[2];   // palm relative to the pawn, un-rotated by its yaw
	private bool    primed[2];
	private double  bodyYaw;      // the yaw those samples were taken at

	// ---- palm velocity, for the throw --------------------------------------
	//
	// DIFFERENCED, because there is none to read. The fork's AttackVel and
	// OffhandVel are OpenXR's own XrSpaceVelocity and they do not exist on
	// stock; the entire VR surface here is ten readonly pose fields.
	//
	// THE PEAK OVER A WINDOW, not the last tic. A throw is decided by the
	// fastest part of the motion, and the hand is usually already decelerating
	// by the time the fingers open -- taking the final tic would under-read
	// every throw and the player would have to exaggerate to compensate.
	private Vector3 palmVel[2 * PITCH_WINDOW];
	private int     palmAt[2];

	// Map units per tic, direction included, IN THE WORLD -- a throw needs to
	// know which way. The samples are body-frame; the peak is turned back into
	// the world by the body's current yaw, so "forward" is where you face now.
	Vector3 PalmVelocity(int hand) const
	{
		if (hand != 0 && hand != 1) return (0, 0, 0);
		Vector3 best = (0, 0, 0);
		double bestLen = -1.0;
		for (int i = 0; i < PITCH_WINDOW; i++)
		{
			Vector3 v = palmVel[hand * PITCH_WINDOW + i];
			// Compared in REAL length, not map length, or a mostly-vertical
			// throw would be judged against a stretched axis and win ties it
			// should lose.
			double l = RSQDG_Reach.Metres(v);
			if (l > bestLen) { bestLen = l; best = v; }
		}
		Vector2 w = Actor.RotateVector(best.xy, bodyYaw);
		return (w.x, w.y, best.z);
	}

	// ---- the wrist, for the launch gesture ---------------------------------
	//
	// THERE IS NO HAND VELOCITY ON THIS ENGINE. None -- no linear velocity, no
	// angular rate, no trigger or grip scalar. The whole VR surface is ten
	// readonly pose fields. The fork added AttackVel/OffhandVel natives; they do
	// not exist here, so any motion gesture has to difference the pose itself.
	//
	// WRIST PITCH RATE, and it is turn-immune AT SOURCE rather than by
	// correction. Stock writes `AttackPitch = -weaponangles[PITCH]` with no yaw
	// term at all (hw_openxrdevice.cpp:586-588); the yaw term appears only in
	// AttackAngle (:590). So a snap turn cannot contaminate this, and the fork's
	// VRTurnYaw accumulator -- which does not exist on stock -- is not needed.
	//
	// That is also why the shoulder-pull gesture is dropped rather than ported:
	// it pairs a position delta against a yaw-carrying direction with nothing to
	// reconcile the two frames, which is broken here and was always fragile.
	//
	// A RATE, NOT A TOTAL. Degrees per tic, so a slow deliberate lift of the
	// whole forearm never crosses it however far it travels, while a sharp tip
	// of the wrist does immediately. That is what separates the gesture from
	// ordinary aiming, and it is why raising the threshold is the fix if it ever
	// misfires -- not shortening the window.
	//
	// ERGONOMICS, not technology, decided this. Dragging the hand back toward
	// the body is a SHOULDER movement, and seated with an elbow on an armrest
	// that is the one motion you cannot repeat. A wrist tip is the same intent
	// routed through the joint that is still free. This mod is played seated.
	const PITCH_WINDOW = 7;   // ~200 ms. The peak lingers long enough that a
	                          // release a tic or two after the flick still sees it.

	private double pitchRate[2 * PITCH_WINDOW];
	private int    pitchAt[2];
	private double lastPitch[2];
	private bool   pitchPrimed[2];

	// The fastest single tic in the window, upward only. Upward because the
	// gesture is "tip it up at me"; a downward flick is putting something down.
	double PeakPitchUp(int hand) const
	{
		if (hand != 0 && hand != 1) return 0.0;
		double best = 0.0;
		for (int i = 0; i < PITCH_WINDOW; i++)
		{
			double v = pitchRate[hand * PITCH_WINDOW + i];
			if (v > best) best = v;
		}
		return best;
	}

	// Called once the gesture has fired, so the lingering peak cannot fire a
	// second launch the instant the first one lands.
	void ForgetWrist(int hand)
	{
		if (hand != 0 && hand != 1) return;
		for (int i = 0; i < PITCH_WINDOW; i++)
			pitchRate[hand * PITCH_WINDOW + i] = 0.0;
	}

	private void SampleWrist(PlayerPawn pmo, int h, bool good)
	{
		double now = RSQDG_Reach.Pitch(pmo, h);
		if (!pitchPrimed[h]) { lastPitch[h] = now; pitchPrimed[h] = true; }

		// Wrapped, because pitch crossing +/-180 is not a 360-degree flick.
		double d = now - lastPitch[h];
		while (d > 180) d -= 360;
		while (d < -180) d += 360;
		lastPitch[h] = now;

		// A bad pose contributes NOTHING rather than a huge bogus delta. The
		// collapse to the body position when a menu opens would otherwise read
		// as the sharpest wrist flick of the session.
		pitchRate[h * PITCH_WINDOW + pitchAt[h]] = good ? d : 0.0;
		pitchAt[h] = (pitchAt[h] + 1) % PITCH_WINDOW;
	}

	override void WorldLoaded(WorldEvent e)
	{
		target[0] = null; target[1] = null;
		primed[0] = false; primed[1] = false;
		poseTrusted = false;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		target[0] = null; target[1] = null;
		primed[0] = false; primed[1] = false;
		poseTrusted = false;
	}
}
