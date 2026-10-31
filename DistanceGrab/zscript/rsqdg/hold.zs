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
//
// =========================================================================
// THE CARRY IS A SPRING, NOT A TELEPORT (report §3.3, every Quest grab agrees)
// =========================================================================
//
//   vel = palmVel * share + (target - pos) * k,   clamped to vmax
//
// SetOrigin is a teleport: it puts the object through the wall you hold it
// against, and there is nothing to push back. Asking for a VELOCITY lets the
// engine's own movement do the collision -- so pinning something against a wall
// is not a feature anyone writes, it is what happens when the hand keeps asking
// and the wall keeps refusing. And that refusal is measurable: STRAIN, the
// distance between where the hand wants the object and where it is, which the
// rumble plays (feel.zs) and which ends the hold if it goes on too long.
//
// MASS DECIDES THE SPRING. `share` is the same k/(k+kg) the pull steers on:
//   - the FEED-FORWARD term (palm velocity x share) is what makes a clip stay
//     glued to the hand through a fast move, and a barrel trail behind it;
//   - k (rsqdg_hold_k x (0.33 + 0.67 share)) is how hard the lag is pulled in;
//   - vmax (x sqrt(share), floor 0.3) is how fast the ARM can haul it.
// THE BODY'S OWN MOTION IS FED FORWARD IN FULL, and only the arm's part is
// scaled by mass. Found in review: scaling the whole palm delta made walking
// with a barrel a permanent 0.8 m lag -- constant "strain", constant rumble --
// and running past vmax dropped it. You carry a barrel at walking pace; it is
// your arm that cannot whip it about.
// So weight is felt in the hand's motion with no extra rule for it.
//
// THE TARGET IS A STAND-OFF, not the palm (D5, report §13): a short distance
// ahead of the hand along where it points, plus the object's own half-size --
// so a barrel sits in front of your hand rather than inside your view, and
// pointing the hand at a wall puts the object on the wall.
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
	private bool   savedCorpse[2];
	private double savedRadius[2];
	private double savedHeight[2];
	private bool   savedShoot[2];

	// BOTH HANDS ON IT (owner 2026-10-31, picked "two-hand lift"): the other palm on the held thing, that hand empty.
	// It then handles as if rsqdg_two_hand times lighter -- follows faster, sags less, throws harder -- and sits
	// between the two hands. Read fresh every tic; the release reads the last tic's.
	private bool   two[2];

	// ---- A HELD THING TURNS WITH THE WRIST (rs_held.zs, rs_hold_rotate) -------
	//
	// WorldHands' carry: a held sprite gets +ROLLSPRITE/+ROLLCENTER/
	// +INTERPOLATEANGLES and its roll follows the controller's (NEGATED -- "turning
	// the wrist one way rolled the barrel the other", headset 2026-08-28); a held
	// VOXEL also takes the hand's pitch (negated: HandPitch is up-positive, Actor
	// pitch down-positive) and yaw, because a voxel has a front and a top and all
	// three angles show. Stock QZD draws a voxel's pitch and roll only with
	// UseActorPitch/UseActorRoll, which SetModelFlag gives this one actor; its
	// middle is kept on the hand with WorldOffset (RSQDG_Turn.Fix, flight.zs).
	//
	// ONE CHANGE, AND THE GESTURE FORCES IT. WorldHands holds on a squeeze, so the
	// wrist is free; here the PALM POSE is the hold, and the hand is always rolled
	// a quarter turn while carrying. Taken literally, every held thing would lie on
	// its side. So the roll is the wrist's turn SINCE THE CATCH: the thing arrives
	// upright and tips as you tip your wrist (within the palm tolerance, +-30 deg).
	//
	// Every borrowed angle and flag is saved first and put back on every exit.
	private bool    turnOn[2];
	private bool    tSprite[2], tCentre[2], tInterp[2], tVoxel[2];
	private double  tRoll[2], tPitch[2], tAngle[2], tRef[2];
	private Vector3 tOfs[2];

	// A FREEZE, rather than a target recomputed when the pose lies.
	//
	// The VR hand fields do not freeze when a menu opens -- they COLLAPSE TO
	// THE BODY (hw_vrmodes.cpp:442; the real write is gated on menuactive,
	// hw_openxrdevice.cpp:568). A carry that chased the live hand point would
	// haul the object into the player's chest for as long as the menu stayed
	// open, then fling it back out. So a bad pose stops the object dead where
	// it is, and refuses to read the release as a throw.
	private bool frozen[2];

	// The spring's memory: last tic's palm (for the feed-forward) and the
	// strain it measured.
	private Vector3 lastPalm[2];
	private Vector3 lastBody[2];
	private bool    havePalm[2];
	private double  strainM[2];
	private int     strainTics[2];

	// HOW LONG A HOLD SURVIVES BEING HELD BACK. Half a second at more than
	// rsqdg_hold_break metres short: the object is behind a wall, or you walked
	// away from where it is stuck. Let go of it there, rather than tow it
	// through the geometry or keep it straining for ever.
	const BREAK_TICS = 18;
	private double armPeak[2];      // the arm's recent top speed, m/s (the throw lets go after it)

	// A palm that moves further than this in one tic did not move, it was
	// moved -- a teleport, a level-start pose. No feed-forward from that.
	const PALM_JUMP = 64.0;

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

	// Metres the object is short of where the hand wants it. 0 when empty.
	double Strain(int hand) const
	{
		return (hand == 0 || hand == 1) && held[hand] ? strainM[hand] : 0;
	}

	// What both hands are carrying, in kilograms. The burden token reads it.
	double CarriedKg() const
	{
		double kg = 0;
		for (int h = 0; h < 2; h++)
			if (held[h]) kg += RSQDG_Mass.Kg(held[h]);
		return kg;
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

		// The settle list may still be lending it pass-through (throw.zs).
		let settler = RSQDG_Throw.Get();
		if (settler) settler.Unsettle(a);

		savedNoGrav[hand]     = a.bNOGRAVITY;
		savedThruActors[hand] = a.bTHRUACTORS;
		savedSpecial[hand]    = a.bSPECIAL;
		savedCorpse[hand]     = a.bCORPSE;
		savedRadius[hand]     = a.Radius;
		savedHeight[hand]     = a.Height;
		savedShoot[hand]      = a.bSHOOTABLE;
		// A BODY SHIELD (owner 2026-10-31): a held corpse stops bullets. A corpse is not shootable; while it is held it
		// is, and with its health at or below 0 DamageMobj does nothing to it -- the bullet just stops there. A barrel
		// is shootable already (and goes off when it is hit, held or not). Fireballs: ShieldTick.
		if (Shieldy(a) && a.Health <= 0 && RSQDG_Reach.Flag("rsqdg_body_shield", p, true)) a.bSHOOTABLE = true;

		// Weightless while carried, pass-through so it does not fight your own
		// collision cylinder, and not collectable by walking over your own hand.
		a.bNOGRAVITY  = true;
		a.bTHRUACTORS = true;
		a.bSPECIAL    = false;
		a.Vel = (0, 0, 0);

		// A PICKUP'S RADIUS IS ITS TRIGGER, not its body (a clip is radius 20,
		// the same as a shotgun guy). Carried at that size, a clip stops 20
		// units from every wall you reach toward. Capped at its own half-height
		// -- the flight's lesson again -- and only for pickups: a barrel's
		// radius IS the barrel.
		if (a is "Inventory")
		{
			double thin = max(RSQDG_Reach.Num("rsqdg_flight_radius", p, 2.0),
				min(a.Radius, a.Height * 0.5));
			if (a.Radius > thin) a.A_SetSize(thin, a.Height);
		}

		held[hand] = a;
		frozen[hand] = false;
		havePalm[hand] = false;
		strainM[hand] = 0;
		strainTics[hand] = 0;
		turnOn[hand] = false;
		if (p.mo) tRef[hand] = RSQDG_Reach.Roll(p.mo, hand);

		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d CAUGHT %s (%.1f kg)", hand, a.GetClassName(), RSQDG_Mass.Kg(a));
		return true;
	}

	// A corpse that got up while in your hand (an Arch-Vile) is a monster now,
	// at its living size; giving it back the corpse's size would make a
	// quarter-height imp. The flight has the same guard.
	private bool Raised(int hand, Actor a) const
	{
		return savedCorpse[hand] && a.Health > 0 && !a.bCORPSE;
	}

	// Every borrowed thing back, in one place. Every exit goes through here.
	//
	// BUT NOT ALWAYS AT ONCE (review): the object may be overlapping the
	// player or a wall it was pinned to, and a solid barrel turned solid
	// inside a solid player locks both; a clip widened back to its trigger
	// radius inside a wall cannot move. So gravity comes back now, and the
	// rest -- collision, size, collectability -- is handed to the settle list
	// (throw.zs), which puts each back the first tic it fits. One owner of
	// the remaining backup: the settler, from this line on.
	private void Restore(int hand, Actor a, int minTics = 0)
	{
		Unturn(hand, a);
		a.bNOGRAVITY = savedNoGrav[hand];
		if (!Raised(hand, a)) a.bSHOOTABLE = savedShoot[hand];
		double r = Raised(hand, a) ? a.Radius : savedRadius[hand];
		double h = Raised(hand, a) ? a.Height : savedHeight[hand];
		let th = RSQDG_Throw.Get();
		if (th)
		{
			th.Settle(a, savedThruActors[hand], savedSpecial[hand], r, h, minTics);
			return;
		}
		a.bTHRUACTORS = savedThruActors[hand];
		a.bSPECIAL    = savedSpecial[hand];
		if (a.Radius != r || a.Height != h) a.A_SetSize(r, h);
	}

	// ---- the turn ---------------------------------------------------------------
	private void Turn(int h, Actor a, PlayerPawn pmo, PlayerInfo p)
	{
		if (!RSQDG_Reach.Flag("rsqdg_hold_turn", p, true)) { Unturn(h, a); return; }
		if (!turnOn[h])
		{
			turnOn[h]  = true;
			tSprite[h] = a.bROLLSPRITE;
			tCentre[h] = a.bROLLCENTER;
			tInterp[h] = a.bINTERPOLATEANGLES;
			tRoll[h]   = a.Roll;
			tPitch[h]  = a.Pitch;
			tAngle[h]  = a.Angle;
			tOfs[h]    = a.WorldOffset;
			tVoxel[h]  = false;
		}
		a.bROLLSPRITE = true;
		a.bROLLCENTER = true;
		a.bINTERPOLATEANGLES = true;
		double before = a.Roll;
		a.Roll = tRoll[h] - RSQDG_Reach.NormDeg(RSQDG_Reach.Roll(pmo, h) - tRef[h]);
		if (RSQDG_Voxels.Drawn(a))
		{
			if (!tVoxel[h])
			{
				a.SetModelFlag(MDL_USEACTORPITCH | MDL_USEACTORROLL);
				tVoxel[h] = true;
			}
			a.Pitch = -RSQDG_Reach.Pitch(pmo, h);
			a.Angle = RSQDG_Reach.Yaw(pmo, h);
			a.WorldOffset = tOfs[h] + RSQDG_Turn.Fix(a, savedHeight[h] * 0.5, true, (before + a.Roll) * 0.5);
		}
	}

	private void Unturn(int h, Actor a)
	{
		if (!turnOn[h] || !a) { turnOn[h] = false; return; }
		turnOn[h] = false;
		a.bROLLSPRITE = tSprite[h];
		a.bROLLCENTER = tCentre[h];
		a.bINTERPOLATEANGLES = tInterp[h];
		a.Roll = tRoll[h];
		a.Pitch = tPitch[h];
		a.Angle = tAngle[h];
		a.WorldOffset = tOfs[h];
		if (tVoxel[h]) a.ResetModelFlags();
		tVoxel[h] = false;
	}

	private void Forget(int hand)
	{
		held[hand] = null;
		two[hand] = false;
		turnOn[hand] = false;
		sag[hand] = 0;
		frozen[hand] = false;
		havePalm[hand] = false;
		strainM[hand] = 0;
		strainTics[hand] = 0;
	}

	// ---- letting go --------------------------------------------------------
	//
	// THE RELEASE DECIDES, by the same rule the launch uses: open your hand while
	// it is moving and the object is thrown; open it at rest and it simply drops.
	// One act, two meanings, and which one you got is decided by whether your arm
	// was doing anything. `canThrow` false is a set-down whatever the arm did --
	// the path for a hold that broke.
	void Release(int hand, PlayerInfo p, bool canThrow = true)
	{
		Actor a = held[hand];
		if (!a) return;

		// THE THROW. Hand velocity differenced from the palm, in the tracking
		// frame, peak of the last ~200 ms (aim.zs) -- there is no native hand
		// velocity on this engine.
		//
		// A BAD POSE THROWS NOTHING. The collapse to the body position would
		// otherwise read as the hardest throw of the session.
		Vector3 v = (0, 0, 0);
		let aim = RSQDG_Aim.Get();
		if (canThrow && aim && aim.PoseGood() && !frozen[hand])
			v = aim.PalmVelocity(hand) * RSQDG_Reach.Num("rsqdg_throw_scale", p, 1.0);

		// THE ARM HAS MASS TOO (rs_throw.zs's model). A throw is your arm and
		// the object moving together; let go and the object keeps the share
		// of that motion that was its own -- arm/(arm+kg). With the arm at
		// 30 kg a keycard leaves at your hand's speed and a 60 kg barrel at a
		// third of it: a heave, not a flick. Weight shows in the throw with no
		// rule written for any object.
		double kg = EffKg(hand, a, p);
		double arm = max(1.0, RSQDG_Reach.Num("rsqdg_arm_kg", p, 30.0));
		v *= arm / (arm + kg);
		// THE THROWING BOOST (owner 2026-10-31: "let me have a throwing boost so I can chuck a barrel a reasonable
		// distance"): a VR arm swings at a fraction of a real throw's speed and has none of the body behind it, so
		// the release is multiplied -- weight still divides it first, so a barrel still goes shorter than a clip.
		v *= max(0.0, RSQDG_Reach.Num("rsqdg_throw_boost", p, 2.5));

		// THE ARM'S PART IS MEASURED AGAINST THE BODY (aim.zs), so walking is
		// not a throw. But a real throw thrown while running carries the run:
		// so the body's own velocity is added back ONLY when the arm actually
		// threw. Half a metre a second is the line between a throw and a
		// gentle set-down.
		bool thrown = RSQDG_Reach.Metres(v) * TICRATE > 0.5;
		Vector3 body = (0, 0, 0);
		if (thrown && p.mo) body = p.mo.Vel;
		v += body;

		// A thrown pickup stays uncollectable for a moment, or walking after
		// your own throw picks it straight back up on the same tic.
		Restore(hand, a, thrown ? 10 : 0);
		if (thrown && p.mo) v = Assist(p, a, v - body) + body;
		a.Vel = v;

		// INTO THE AIR, EVERY RELEASE: thrown or set down, it falls at the one
		// rate WorldHands gives everything that leaves a hand (throw.zs Air).
		let air = RSQDG_Throw.Get();
		double mps = RSQDG_Reach.Metres(v - body) * TICRATE;
		double spin = thrown ? clamp(mps * 3.0, 4.0, 28.0) * (FRandom[RSQDGSpin](0, 1) < 0.5 ? -1 : 1) * RSQDG_Reach.Num("rsqdg_throw_spin", p, 1.0) : 0.0;
		if (air) air.Air(a, spin);
		if (thrown) RSQDG_Feel.Whoosh(a, p, mps, RSQDG_Mass.Heft(a));

		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] hand %d released %s at %.1f m/s (%s; arm %.1f, body %.1f)",
				hand, a.GetClassName(), RSQDG_Reach.Metres(v) * TICRATE,
				thrown ? "thrown" : "dropped",
				RSQDG_Reach.Metres(v - body) * TICRATE, RSQDG_Reach.Metres(body) * TICRATE);

		Forget(hand);

		// A thrown thing is watched until it lands: the impact is what hurts
		// (throw.zs).
		if (thrown && p.mo)
		{
			let th = RSQDG_Throw.Get();
			if (th) th.Watch(a, p.mo, hand, body.xy);
		}

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
			Restore(hand, a);
			a.Vel = (0, 0, 0);
			// Told, like every other ending, so a listener that dressed the
			// thing can undress it -- switched off, died, level change.
			RSQDG_Events.Tell("hold.drop", hand, a);
		}
		Forget(hand);
	}

	void DropAll()
	{
		Drop(0);
		Drop(1);
	}

	// Where the hand wants the object's ORIGIN (feet, not centre) this tic.
	private Vector3 Target(PlayerPawn pmo, PlayerInfo p, int h, Actor a, int ph = -1)
	{
		if (ph < 0) ph = h;
		Vector3 palm = RSQDG_Reach.Palm(pmo, ph);
		Vector3 dir  = RSQDG_Reach.Dir(pmo, ph);   // room-space unit vector

		// Metres ahead of the hand: the setting, plus the object's half-size so
		// its near face, not its middle, sits at the stand-off. Half-size from
		// the TRUE radius capped by half-height, for the same reason as the
		// thinning above.
		double half = min(savedRadius[h], savedHeight[h] * 0.5) / RSQDG_Reach.UNITS_PER_METRE_XY;
		double m = max(0.0, RSQDG_Reach.Num("rsqdg_hold_dist", p, 0.30)) + half;

		// Room metres to map units, per axis (34 across, 28.3 up).
		Vector3 off = (dir.x * m * RSQDG_Reach.UNITS_PER_METRE_XY,
		               dir.y * m * RSQDG_Reach.UNITS_PER_METRE_XY,
		               dir.z * m * RSQDG_Reach.UNITS_PER_METRE_XY / RSQDG_Reach.PIXELSTRETCH);
		Vector3 c = palm + off;
		return (c.x, c.y, c.z - a.Height * 0.5 - sag[h]);
	}

	// WHAT HEAVY LOOKS LIKE (rs_held.zs HoldSag): a heavy thing hangs lower, and
	// dips further while you swing it, and settles when you stop. Units below the
	// hand: heavy x rsqdg_hold_sag x (3 + swing x 4), heavy = log10(kg + 1) / 1.8
	// (the strain haptic's logarithmic order; a barrel ~1, a clip ~0.07), swing =
	// the arm's speed / 6 units a tic. WorldHands lowered only the DRAWING, in the
	// hand model's frame (Z over pixelstretch); here it lowers where the spring
	// carries the thing, by the same amount.
	private double sag[2];
	private void UpdateSag(int h, Actor a, Vector3 armVel, PlayerInfo p)
	{
		double amount = RSQDG_Reach.Num("rsqdg_hold_sag", p, 1.0);
		if (amount <= 0) { sag[h] = 0; return; }
		double heavy = clamp(log10(max(EffKg(h, a, p), 0.0) + 1.0) / 1.8, 0.0, 1.0);
		double swing = clamp(armVel.Length() / 6.0, 0.0, 1.0);
		sag[h] = heavy * amount * (3.0 + swing * 4.0) / RSQDG_Reach.PIXELSTRETCH;
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
			UpdateBurden(pmo, p);
			return;
		}

		let aim = RSQDG_Aim.Get();
		bool good = aim && aim.PoseGood();

		for (int h = 0; h < 2; h++)
		{
			Actor a = held[h];
			if (!a) { Forget(h); continue; }

			// GOT UP, or GOT TAKEN: an Arch-Vile raised it, or something put
			// it in an inventory. Either way it is not ours to steer.
			if (Raised(h, a) || (Inventory(a) && Inventory(a).Owner))
			{
				if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
					Console.Printf("[RSQDG] hand %d: %s is no longer a held thing", h, a.GetClassName());
				Drop(h);
				continue;
			}

			if (!good)
			{
				// STOP WHERE IT IS. Not "carry on toward the body position",
				// which is what reading the live hand point would do.
				frozen[h] = true;
				havePalm[h] = false;
				strainM[h] = 0;
				strainTics[h] = 0;
				a.Vel = (0, 0, 0);
				continue;
			}
			frozen[h] = false;

			Vector3 palm = RSQDG_Reach.Palm(pmo, h);
			Vector3 armVel = (0, 0, 0), bodyVel = (0, 0, 0);
			if (havePalm[h])
			{
				bodyVel = pmo.Pos - lastBody[h];
				armVel = (palm - lastPalm[h]) - bodyVel;
				if (bodyVel.Length() > PALM_JUMP) bodyVel = (0, 0, 0);   // teleported
				if (armVel.Length() > PALM_JUMP)  armVel  = (0, 0, 0);
			}
			lastPalm[h] = palm;
			lastBody[h] = pmo.Pos;
			havePalm[h] = true;

			// THROWING NEEDS NO SECOND GESTURE (owner 2026-10-31: "throwing right now doesn't work, everything just
			// instantly falls"). Letting go was the palm rolled back, and by the time a player has thrown AND rolled
			// the palm the throw's speed has left the window it is read from, so it dropped at the feet. Now the
			// throw lets go by itself: the arm past rsqdg_auto_throw m/s, and then slowing (its peak passed, as a
			// real throw lets go) -- released with the peak's speed. 0 is the old way (the palm decides).
			double autoMps = RSQDG_Reach.Num("rsqdg_auto_throw", p, 2.5);
			// ONLY A SWING AWAY FROM YOU (rig 2026-10-31: the wind-up was read as the throw, peak and all, and the
			// barrel went over your shoulder). The arm's speed counts while it moves within 60 degrees of where you
			// face, across the ground; a wind-up, a pull to the chest or a drop straight down never lets go.
			double nowMps = RSQDG_Reach.Metres(armVel) * TICRATE;
			Vector2 face = (cos(pmo.Angle), sin(pmo.Angle));
			double across = armVel.xy.Length();
			bool outward = across > 0.001 && (armVel.xy dot face) > 0.5 * across;
			if (!outward) nowMps = 0;
			armPeak[h] = max(armPeak[h] * 0.85, nowMps);
			if (autoMps > 0 && armPeak[h] >= autoMps && nowMps < armPeak[h] * 0.6)
			{
				armPeak[h] = 0;
				if (RSQDG_Reach.Flag("rsqdg_debug", p, false)) Console.Printf("[RSQDG] hand %d: the throw lets go", h);
				Release(h, p);
				continue;
			}

			bool wasTwo = two[h];
			two[h] = BothHands(pmo, p, h, a);
			if (two[h] && !wasTwo) RSQDG_Feel.Thud(a, p, RSQDG_Mass.Heft(a), 0.3);   // the second hand takes hold
			if (two[h] != wasTwo && RSQDG_Reach.Flag("rsqdg_debug", p, false))
				Console.Printf("[RSQDG] hand %d: %s %s", h, a.GetClassName(), two[h] ? "BOTH HANDS" : "one hand");
			UpdateSag(h, a, armVel, p);
			Turn(h, a, pmo, p);
			Vector3 want = Target(pmo, p, h, a);
			if (two[h]) want = (want + Target(pmo, p, h, a, 1 - h)) * 0.5;
			Vector3 err = want - a.Pos;

			// STRAIN is measured BEFORE this tic's push, from where the
			// engine let the object get to on the last one.
			strainM[h] = RSQDG_Reach.Metres(err);

			double breakM = RSQDG_Reach.Num("rsqdg_hold_break", p, 1.5);
			if (breakM > 0 && strainM[h] > breakM)
			{
				if (++strainTics[h] >= BREAK_TICS)
				{
					if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
						Console.Printf("[RSQDG] hand %d lost %s -- held back %.2f m",
							h, a.GetClassName(), strainM[h]);
					Release(h, p, false);
					continue;
				}
			}
			else strainTics[h] = 0;

			double pk = max(0.1, RSQDG_Reach.Num("rsqdg_pull_kg", p, 10.0));
			double share = pk / (pk + EffKg(h, a, p));
			double k = clamp(RSQDG_Reach.Num("rsqdg_hold_k", p, 0.6), 0.05, 0.95)
				* (0.33 + 0.67 * share);
			double vmax = RSQDG_Reach.Num("rsqdg_hold_vmax", p, 40.0) * max(0.3, sqrt(share));

			// The arm's part, mass-scaled and capped; the body's, in full.
			Vector3 v = armVel * share + err * k;
			double vl = v.Length();
			if (vl > vmax) v *= vmax / vl;
			a.Vel = v + bodyVel;
			ShieldTick(pmo, p, h, a);
		}

		UpdateBurden(pmo, p);
		PruneFlying();
	}

	// ---- both hands, aim, shield ---------------------------------------------------

	// The kilograms the hand feels: the thing's own, divided when both hands carry it.
	private double EffKg(int h, Actor a, PlayerInfo p) const
	{
		double kg = RSQDG_Mass.Kg(a);
		if ((h == 0 || h == 1) && two[h]) kg /= max(1.0, RSQDG_Reach.Num("rsqdg_two_hand", p, 2.0));
		return kg;
	}

	// The other hand is empty and its palm is on the thing: within its body plus a quarter metre.
	private bool BothHands(PlayerPawn pmo, PlayerInfo p, int h, Actor a)
	{
		if (RSQDG_Reach.Num("rsqdg_two_hand", p, 2.0) <= 1.0 || held[1 - h]) return false;
		Vector3 op = RSQDG_Reach.Palm(pmo, 1 - h);
		double pad = 0.25 * RSQDG_Reach.UNITS_PER_METRE_XY;
		double r = min(savedRadius[h], max(savedHeight[h] * 0.5, 8.0)) + pad;
		double mid = a.Pos.z + a.Height * 0.5;
		if ((op.xy - a.Pos.xy).Length() > r) return false;
		return abs(op.z - mid) <= a.Height * 0.5 + pad / RSQDG_Reach.PIXELSTRETCH;
	}

	// THROW AIM ASSIST (owner 2026-10-31, picked): a throw within rsqdg_throw_assist degrees of a monster you can see
	// is turned onto it, and lobbed so the arc comes down on its middle at the speed you threw (the air's real
	// gravity, throw.zs). The speed across the ground is yours; only the heading and the lob are corrected, the lob
	// by no more than 0.6 of that speed either way.
	private Vector3 Assist(PlayerInfo p, Actor a, Vector3 v)
	{
		double cone = RSQDG_Reach.Num("rsqdg_throw_assist", p, 12.0);
		double hs = v.xy.Length();
		if (cone <= 0 || hs < 0.5 || !p.mo) return v;
		double heading = VectorAngle(v.x, v.y);
		Actor best = null;
		double bestOff = cone;
		let it = BlockThingsIterator.Create(a, 1200);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || t == a || t == p.mo || !t.bISMONSTER || t.Health <= 0 || !t.bSHOOTABLE || t.bFRIENDLY) continue;
			Vector2 d = t.Pos.xy - a.Pos.xy;
			double dl = d.Length();
			if (dl < 32 || dl > 1200) continue;
			double off = abs(Actor.DeltaAngle(heading, VectorAngle(d.x, d.y)));
			if (off >= bestOff || !p.mo.CheckSight(t, SF_IGNOREVISIBILITY)) continue;
			best = t;
			bestOff = off;
		}
		if (!best) return v;
		Vector2 d = best.Pos.xy - a.Pos.xy;
		double dl = d.Length();
		Vector2 nh = d / dl * hs;
		double tt = dl / hs;
		double g = a.GetGravity() * clamp(RSQDG_Reach.Num("rsqdg_air_gravity", p, 0.27), 0.0, 1.0);
		double dz = (best.Pos.z + best.Height * 0.5) - (a.Pos.z + a.Height * 0.5);
		double vz = clamp(dz / tt + 0.5 * g * tt, v.z - hs * 0.6, v.z + hs * 0.6);
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] throw assist: onto %s, %.1f deg off, %.0f units", best.GetClassName(), bestOff, dl);
		return (nh.x, nh.y, vz);
	}

	// What can be a shield: a corpse, a barrel, a body of a thing -- not a pickup, not a living monster.
	static bool Shieldy(Actor a)
	{
		return a && !(a is "Inventory") && (a.bCORPSE || !a.bISMONSTER) && RSQDG_Mass.Kg(a) >= 20.0;
	}

	// A HELD BODY STOPS FIREBALLS. The held thing is pass-through while carried (so it does not fight your own
	// collision), and PIT_CheckThing lets a missile through anything pass-through -- so each tic every enemy missile
	// whose next step crosses the held thing's body is stopped on it and goes off there. A held barrel that is hit
	// takes the hit (and goes off). The body is the thing's own radius and its living height, 24..56.
	// Every missile in the level, from its spawn: a blockmap search misses the ones that are not linked in it
	// (rig 2026-10-31: Brutal Doom's imp ball went straight through a held barrel unseen).
	private Array<Actor> flying;
	override void WorldThingSpawned(WorldEvent e)
	{
		if (!e.Thing || !e.Thing.bMISSILE) return;
		if (flying.Size() >= 64) PruneFlying();
		flying.Push(e.Thing);
	}
	private void PruneFlying()
	{
		for (int k = flying.Size() - 1; k >= 0; k--)
			if (!flying[k] || !flying[k].bMISSILE) flying.Delete(k);
	}

	private void ShieldTick(PlayerPawn pmo, PlayerInfo p, int h, Actor a)
	{
		if (!Shieldy(a) || !RSQDG_Reach.Flag("rsqdg_body_shield", p, true)) return;
		if (savedShoot[h] && a.Health <= 0) return;   // a barrel that went off: its own blast is not stopped
		let def = GetDefaultByType(a.GetClass());
		double r = max(savedRadius[h], 14.0);
		double ht = clamp(def ? def.Height : savedHeight[h], 24.0, 56.0);
		double z0 = a.Pos.z + a.Height * 0.5 - ht * 0.5;
		Array<Actor> hits;
		Array<double> hx, hy, hz;
		for (int k = 0; k < flying.Size(); k++)
		{
			Actor m = flying[k];
			if (!m || (m.Pos.xy - a.Pos.xy).Length() > 200) continue;
			if (m && m.bMISSILE && RSQDG_Reach.Flag("rsqdg_trace", p, false))
				Console.Printf("[RSQDG] shield sees %s at %.0f %.0f %.0f vel %.1f %.1f %.1f r %.0f (held %.0f %.0f %.0f r %.0f ht %.0f)", m.GetClassName(), m.Pos.x, m.Pos.y, m.Pos.z, m.Vel.x, m.Vel.y, m.Vel.z, m.Radius, a.Pos.x, a.Pos.y, z0, r, ht);
			// coming at it, at a missile's speed, and not its own (a blast's debris, a trail puff)
			if (!m || m == a || !m.bMISSILE || m.target == pmo || m.target == a || m.Vel.Length() < 4.0) continue;
			if (((a.Pos.xy - m.Pos.xy) dot m.Vel.xy) <= 0) continue;
			Vector2 d = m.Vel.xy;
			double l2 = d dot d;
			double t = l2 > 0 ? clamp(((a.Pos.xy - m.Pos.xy) dot d) / l2, 0.0, 1.0) : 0.0;
			Vector2 q = m.Pos.xy + d * t;
			if ((q - a.Pos.xy).Length() > r + m.Radius) continue;
			double z = m.Pos.z + m.Vel.z * t;
			if (z + m.Height < z0 || z > z0 + ht) continue;
			hits.Push(m); hx.Push(q.x); hy.Push(q.y); hz.Push(z);
		}
		for (int i = 0; i < hits.Size(); i++)
		{
			Actor m = hits[i];
			if (!m || !m.bMISSILE) continue;
			if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
				Console.Printf("[RSQDG] hand %d: %s stopped %s", h, a.GetClassName(), m.GetClassName());
			m.SetOrigin((hx[i], hy[i], hz[i]), false);
			Actor src = m.target;
			if (a && a.bSHOOTABLE && a.Health > 0) a.DamageMobj(m, src, max(1, m.GetMissileDamage(7, 1)), m.DamageType);
			if (m) m.ExplodeMissile(null, a);
			RSQDG_Events.Tell("hold.block", h, a);
		}
	}

	// ---- the burden --------------------------------------------------------
	//
	// HEAVY THINGS SLOW YOU, through the only hook that can (report §5.1):
	// Inventory.GetSpeedFactor, multiplied in by TweakSpeeds INSIDE MovePlayer,
	// after MovePlayer has reset Speed for the tic -- which is why A_SetSpeed
	// from anywhere never works in VR. Given and taken HERE, every tic, by the
	// thing that knows what is held: a flag set in one place and cleared in
	// another is the bug that outlives the session.
	private void UpdateBurden(PlayerPawn pmo, PlayerInfo p)
	{
		double factor = 1.0;
		if (RSQDG_Reach.Flag("rsqdg_burden", p, true) && pmo.Health > 0)
		{
			// Half speed at rsqdg_burden_kg; a clip is nothing, a barrel is
			// felt, two barrels are a struggle.
			double ref = max(1.0, RSQDG_Reach.Num("rsqdg_burden_kg", p, 120.0));
			factor = 1.0 / (1.0 + CarriedKg() / ref);
		}

		let tok = RSQDG_Burden(pmo.FindInventory("RSQDG_Burden"));
		if (factor > 0.99)
		{
			if (tok) tok.Destroy();
			return;
		}
		if (!tok)
		{
			tok = RSQDG_Burden(pmo.GiveInventoryType("RSQDG_Burden"));
			if (!tok) return;
		}
		tok.factor = factor;
	}

	private void TakeBurden()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let tok = p.mo.FindInventory("RSQDG_Burden");
		if (tok) tok.Destroy();
	}

	override void WorldLoaded(WorldEvent e) { DropAll(); TakeBurden(); }
	override void WorldUnloaded(WorldEvent e) { DropAll(); TakeBurden(); }
}

// The slowdown itself. Nothing but a number the hold handler writes. Undroppable,
// invisible, and destroyed by the handler the tic nothing heavy is held -- or on
// any map change, so it can never ride into a new level by itself.
class RSQDG_Burden : Inventory
{
	double factor;

	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
		Inventory.MaxAmount 1;
	}

	override double GetSpeedFactor()
	{
		return clamp(factor, 0.2, 1.0);
	}
}
