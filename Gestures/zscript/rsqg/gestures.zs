// RSQ_Gestures -- what the hands are doing, for any series mod that asks. Ported from the owner's
// RS_Gestures (written for his REMA engine) to stock QuestZDoom 17.3.
//
// THREE KINDS, as in RS_Gestures:
//   POSE      one hand held a certain way: INSPECT (new here, the weapon cards' "show me"), STILL.
//   IMPULSE   one hand moving fast along its own axis: THRUST (away), PULL (back). rsg_signals.zs.
//   BOTH      a relationship between the two hands: both swept DOWN past the hips, thrown APART from
//             the chest, both PALMS held out. rsg_pair.zs.
// And two answers new here (owner's picks 49 and 50, 2026-10-31):
//   BRACED    the engine's two-hand grip latch, WF_TWOHANDSTABILIZED: ONE answer for every series mod
//             instead of each testing the bit (Wheel, TacticalRig, LaserSight, Whip, ShieldSaw do today;
//             Quest teardown apply/00_INDEX "the shared fix is one bitwise test"). Set by SteamVR
//             (gl_openvr.cpp 1704-1727) and by QuestZDoom's own Quest input (VrInputDefault.cpp 130-141):
//             the off grip pressed with the controllers within 0.50 m, vr_two_handed_weapons on.
//   PUNCH     jab / hook / uppercut, read the way Gun Bonsai's gloves read a punch (gloves.zs Swing and
//             Classify, SuperPunchOut's Arcade reader and ClassifyPunch), copied here, not linked: a
//             punch arms on a slow hand, counts once the hand has gone ARM_M toward where you face on
//             consecutive tics at an average of rsqg_punch_mps, and is named by its travel against
//             that line. Never while braced or with both hands shoving together: that is a two-hand
//             gun, and Brutal Doom's own butt-stroke push (owner, 10-31: nothing may collide with it).
// And the QoL round (owner, 2026-10-31 afternoon):
//   SHOVE     GE2, owner: "I want the BD gun-butt shove in our RSQ melee, it's awesome. It can still knock back
//             instead of counting as a punch." A punch-shaped swing with a GUN in that hand (or both hands driving
//             a gun together, or braced) is a shove: its own answer, never a punch. This only REPORTS it: the
//             knock back is Brutal Doom VR's own (2.0.3h melee.zs: the long guns' butt strike lands BD22's
//             KickAttack, Steadied + butt leading, rsq_butt, OFF by default; the pistol whip lands BD22's punch,
//             rsq_pistol_whip, on), and nothing here hurts or pushes anything, so nothing collides with it.
//   QUIET     GE1: while RSQ Grapple says you are on the rope ("climbing", "swinging", "reeling") or RSQ Wheel is open
//             ("IsOpen"), and for RING tics after, no thrust, pull, punch, shove or two-hand event is read.
//             Both asked by name through their services; neither mod is touched.
//   TICK      GE4: a light rumble in that hand when the watch-check (inspect) pose is held.
//   NAMES     GE7: a small grey line names each gesture as it is recognised (RenderOverlay).
//   BODY      GE3: Measure Me scales the zones to your eye height and reach.
// The drawn-shape matcher (rsg_match / rsg_capture / rsg_record) is not ported; see README.md.
//
// WHAT REMA HAD AND QZD DOES NOT, and what stands in for it here:
//   Level.HandVelAtPoint / RS_HAND_PEAK / HandPeakAgeMs (the engine's 250 ms velocity ring)
//       -> our own ring of the last RING tics of hand movement, measured from the pose each tic
//   Level.HandPos (the true hand, not the shooting point) -> AttackPos / OffhandPos: on QZD they ARE
//       the hand (no netplay, and the engine writes them for the camera player only)
//   HmdPos / HmdYaw / VRAvatarTable.BodyYaw -> the eyes rebuilt from HmdPosition (RSQG_Pose.EyePos),
//       and the pawn's angle (QZD turns the pawn with the headset)
//   FingerTouch* / GripValue* / TriggerValue* (an open palm) -> nothing reads fingers on QZD; palms
//       out is read from the hands' pointing and the fire buttons instead (CVARINFO)
//   Level.RealSeconds -> gametic: this runs every real tic (RSQ_SlowMo slows monsters, not the tic)
//
// COST. Nothing is measured unless a mod asked something in the last second (IDLE tics), or the
// signals / two-hand events are switched on, or debug is: otherwise WorldTick is one comparison.
//
// NETPLAY (QZD has none; do not make it worse). The pose is local hardware, written for the camera
// player only, so every answer is about the console player and 0 for anyone else. The detectors keep
// their state in this handler, on the machine with the hands. Anything the game should act on leaves
// as a network event (rsqg_thrust, rsqg_pull, rsqg_pair: the RS_Gestures shape, an index and a
// hundredths magnitude) for the receiver to apply to e.Player. Inspect is a look (a card shows), so it
// is a query, not an event.
class RSQG_Handler : EventHandler
{
	const IDLE = 35;          // tics since the last question before measuring stops
	const RING = 9;           // tics of hand movement kept (~250 ms, REMA's vr_hand_window_ms)
	const SNAP = 8.0;         // a turn of the body this many degrees in one tic is a snap turn: forget motion
	const NEVER = -1000000.0; // a time that has not happened (ms); see RS_Gestures' zero-stamp trap
	const SAME_PEAK = 30.0;   // ms: a peak less than a tic newer than the last announcement is that movement
	const SHOW = 52;          // GE7: tics a gesture's name stays on screen (1.5 s)

	const PAIR_DOWN  = 0;
	const PAIR_APART = 1;
	const PAIR_PALMS = 2;

	int lastAsk, lastRun;
	double prevAngle;

	// the hands' movement: per hand RING velocities (metres a second, map axes, metric), newest at
	// ringAt[hand], ringN[hand] of them good
	bool live[2];
	Vector3 prevRel[2];
	double rvx[18], rvy[18], rvz[18];
	int ringAt[2], ringN[2];

	// INSPECT, per hand: 0 not, 1 entering, 2 held; tics since the pose was met; tics in this state
	int insState[2], insTics[2], insStateTics[2];

	// ONE HAND
	int stillFor[2], lastImpulse[2];

	// PUNCH, per hand (gloves.zs RSQ_PunchHand): armed, the travel so far toward where you face, its tics,
	// and the last punch: its gametic (0 never), kind (PK_*), average speed m/s
	enum EPunch { PK_JAB, PK_HOOK, PK_UPPER }
	const ARM_M = 0.15;       // gloves.zs / spo_corner.zs: metres of travel before a swing is a punch
	const IN_MPS = 0.25;      // m/s that still counts as coming in
	const MAX_TICS = 14;      // longer than this is two motions, not one
	const MAX_STALE = 3;      // tics a hand may repeat its last pose (a late frame) inside one swing
	bool pArmed[2];
	double pTravel[2];
	int pTics[2], pStale[2];
	Vector3 pDir[2];
	int punchTic[2], punchKind[2];
	double punchMps[2];
	// SHOVE (GE2): the last gun-in-hand swing, per hand: its gametic (0 never), two hands on it, its m/s
	int shoveTic[2];
	bool shoveTwo[2];
	double shoveMps[2];

	// QUIET (GE1): no impulse gestures until this gametic; why (1 rope climb, 2 the Wheel open)
	int quietTill, quietWhy;
	transient Service svcGrapple, svcWheel;
	transient int svcLook;

	// NAMES (GE7): the last gesture named, and when (gametic)
	String sayName;
	int sayTic;

	// BODY (GE3): measuring from this gametic until measureTill; the largest seen
	int measureFrom, measureTill;
	double mEye, mReach;
	const REF_EYE = 1.60;     // the body the defaults were set for: eyes this high (metres)
	const REF_REACH = 0.70;   // ...and a hand this far from the eyes, arm straight out

	// BRACED: the latch, and since when (gametic, 0 = not braced or not measured)
	int bracedSince;

	// BOTH HANDS (rsg_pair.zs, times in ms of gametic)
	double downAt[2], downMps[2], apartAt[2], palmsAt[2], saidAt[3];
	double palmsHeldFor;
	bool palmsSaid;

	// cost (debug 3)
	double costMs;
	int costN;

	static RSQG_Handler Get() { return RSQG_Handler(EventHandler.Find("RSQG_Handler")); }

	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }

	static double NowMs() { return gametic * 1000.0 / TICRATE; }

	override void OnRegister() { ResetAll(); lastAsk = -1000; lastRun = -1; }
	override void WorldLoaded(WorldEvent e) { ResetAll(); }

	void ResetAll()
	{
		for (int h = 0; h < 2; h++)
		{
			live[h] = false; ringN[h] = 0; ringAt[h] = 0;
			insState[h] = 0; insTics[h] = 0; insStateTics[h] = 0;
			stillFor[h] = 0;
			pArmed[h] = false; pTravel[h] = 0; pTics[h] = 0; pStale[h] = 0; pDir[h] = (0, 0, 0);
			downAt[h] = NEVER; downMps[h] = 0; apartAt[h] = NEVER; palmsAt[h] = NEVER;
		}
		for (int k = 0; k < 3; k++) saidAt[k] = NEVER;
		palmsHeldFor = 0; palmsSaid = false;
		bracedSince = 0;
	}

	PlayerPawn Me()
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return null;
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return null;
		return p.mo;
	}

	// the switches, looked up once (user cvars: retried while the player is not there yet)
	CVar cvSignals, cvTwohand, cvDebug;
	int SwSignals() { if (!cvSignals) cvSignals = CVar.FindCVar("rsqg_signals"); return cvSignals ? cvSignals.GetInt() : 0; }
	int SwTwohand() { if (!cvTwohand) cvTwohand = CVar.FindCVar("rsqg_twohand"); return cvTwohand ? cvTwohand.GetInt() : 0; }
	int SwDebug()   { if (!cvDebug) cvDebug = CVar.FindCVar("rsqg_debug"); return cvDebug ? cvDebug.GetInt() : 0; }

	bool Running(int dbg)
	{
		return gametic - lastAsk <= IDLE || SwSignals() || SwTwohand() || dbg == 1 || dbg == 2 || gametic < measureTill;
	}

	// ---- QUIET (GE1): the rope and the Wheel, asked by name -----------------------------------------------
	// RSQ Grapple's "climbing" (service.zs: 1 while a hand holds a latched rope, hand over hand) and RSQ Wheel's
	// "IsOpen" (wr_RigService: 1 while the wheel is open and a hand points at it). Each service object is found
	// once and asked every tic; an absent mod is simply no answer. RING tics after either ends are quiet too, so
	// the last stroke or the poke that closed the wheel, still in the ring, is never read as a gesture.
	static Service FindSvc(String n)
	{
		let it = ServiceIterator.Find(n);
		return it.Next();
	}
	bool Quiet(PlayerPawn pmo)
	{
		if (gametic >= svcLook)
		{
			if (!svcGrapple) svcGrapple = FindSvc("RSQGR_Service");
			if (!svcWheel) svcWheel = FindSvc("wr_RigService");
			svcLook = gametic + TICRATE;
		}
		int why = 0;
		// the rope in any of its held states: climbing hand over hand, swinging on it in the air (rig: the body's
		// swing read as thrusts and pulls), reeling in
		if (svcGrapple && (svcGrapple.GetInt("climbing", "", 0, 0, pmo) == 1 || svcGrapple.GetInt("swinging", "", 0, 0, pmo) == 1
			|| svcGrapple.GetInt("reeling", "", 0, 0, pmo) == 1)) why = 1;
		else if (svcWheel && svcWheel.GetInt("IsOpen", "", 0, 0, pmo) == 1) why = 2;
		if (why)
		{
			if (gametic >= quietTill && SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: quiet, %s (t%d)", why == 1 ? "on the rope" : "the Wheel is open", level.maptime);
			quietTill = gametic + RING;
			quietWhy = why;
		}
		else if (quietTill > 0 && gametic == quietTill && SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: quiet ends (t%d)", level.maptime);
		return gametic < quietTill;
	}

	// ---- NAMES (GE7) ----------------------------------------------------------------------------------------
	void Say(String what)
	{
		sayName = what;
		sayTic = gametic;
	}
	static clearscope String HandName(int h) { return h == 0 ? "main" : "off"; }

	override void RenderOverlay(RenderEvent e)
	{
		if (sayName == "" || !Opt("rsqg_names", 1)) return;
		int age = gametic - sayTic;

		if (age < 0 || age >= SHOW) return;
		// subtle: small, grey, half-transparent, low in the view, fading over its last half second
		double a = 0.55 * min(1.0, (SHOW - age) / 18.0);
		double vw = 640, vh = 400;
		String t = sayName;
		Screen.DrawText(SmallFont, Font.CR_GRAY, (vw - SmallFont.StringWidth(t)) / 2, vh * 0.72, t,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, a);
	}

	// ---- TICK (GE4): the series' rumble route, a light one ------------------------------------------------
	void TickHand(PlayerPawn pmo, int h)
	{
		if (!Opt("rsqg_inspect_tick", 1)) return;
		RSQG_Tick.Start(pmo, RSQG_Pose.IsLeft(h), Num("rsqg_tick_strength", 0.35), 3);
		if (SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: watch-check tick, %s hand (%s controller) (t%d)", HandName(h), RSQG_Pose.IsLeft(h) ? "left" : "right", level.maptime);
	}

	// ---- BODY (GE3) ------------------------------------------------------------------------------------------
	// the zones' scales: up and down by your eye height, forward and sideways by your reach (1 when off or unmeasured)
	static double VScale()
	{
		if (!Opt("rsqg_body", 0)) return 1;
		double e = Num("rsqg_body_eye", 0);
		return e > 0.5 ? clamp(e / REF_EYE, 0.6, 1.4) : 1;
	}
	static double HScale()
	{
		if (!Opt("rsqg_body", 0)) return 1;
		double r = Num("rsqg_body_reach", 0);
		return r > 0.2 ? clamp(r / REF_REACH, 0.6, 1.4) : 1;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqg_measure") || e.Player != consoleplayer) return;
		// two seconds to close the menu and stand (the game is paused while the menu is open), then one to measure
		measureFrom = gametic + 2 * TICRATE;
		measureTill = measureFrom + TICRATE;
		mEye = 0; mReach = 0;
		Console.MidPrint(null, "RSQ Gestures: Measure Me\nClose the menu, stand tall,\narms straight out to your sides.", true);
	}

	void Measure(PlayerPawn pmo)
	{
		if (gametic < measureFrom || measureTill <= 0) return;
		let adj = CVar.FindCVar("vr_height_adjust");
		mEye = max(mEye, pmo.HmdPosition.y + (adj ? adj.GetFloat() : 0));
		for (int h = 0; h < 2; h++)
			if (live[h]) { Vector3 bh = RSQG_Pose.Body(pmo, h); mReach = max(mReach, bh.xy.Length()); }
		if (gametic < measureTill - 1) return;
		measureTill = 0;
		if (mEye < 0.5 || mReach < 0.2)
		{
			Console.MidPrint(null, String.Format("RSQ Gestures: could not measure\n(eyes %.2f m, reach %.2f m). Try again.", mEye, mReach), true);
			Console.Printf("rsqg: measure failed, eyes %.2f m reach %.2f m", mEye, mReach);
			return;
		}
		let ce = CVar.FindCVar("rsqg_body_eye"), cr = CVar.FindCVar("rsqg_body_reach"), cb = CVar.FindCVar("rsqg_body");
		if (ce) ce.SetFloat(mEye);
		if (cr) cr.SetFloat(mReach);
		if (cb) cb.SetInt(1);
		Console.MidPrint(null, String.Format("RSQ Gestures: measured\neyes %.2f m, reach %.2f m", mEye, mReach), true);
		Console.Printf("rsqg: measured eyes %.2f m, reach %.2f m: zones x%.2f up/down, x%.2f forward/sideways", mEye, mReach,
			clamp(mEye / REF_EYE, 0.6, 1.4), clamp(mReach / REF_REACH, 0.6, 1.4));
	}

	override void WorldTick()
	{
		int dbg = SwDebug();
		double t0 = dbg >= 3 ? MSTimeF() : 0;
		if (!Running(dbg))
		{
			if (lastRun >= 0) { ResetAll(); lastRun = -1; }
		}
		else Update();
		// debug 3: what this costs a tic, idle or measuring (debug 3 alone does not wake it)
		if (dbg >= 3)
		{
			costMs += MSTimeF() - t0; costN++;
			if (costN >= TICRATE) { Console.Printf("rsqg cost: %.4f ms a tic, %s (avg of %d)", costMs / costN, lastRun == gametic ? "measuring" : "idle", costN); costMs = 0; costN = 0; }
		}
	}

	// ---- the per-tic measurement (once per tic, from WorldTick or from the first question) -----------
	void Update()
	{
		if (lastRun == gametic) return;
		lastRun = gametic;
		let pmo = Me();
		if (!pmo) { ResetAll(); return; }

		if (abs(Actor.DeltaAngle(prevAngle, pmo.Angle)) >= SNAP) { live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; }
		prevAngle = pmo.Angle;

		for (int h = 0; h < 2; h++)
		{
			if (!RSQG_Pose.PoseGood(pmo, h))
			{
				live[h] = false; ringN[h] = 0;
				SetInspect(h, 0);
				insTics[h] = 0;
				continue;
			}
			Vector3 rel = RSQG_Pose.FromEyes(pmo, h);
			if (live[h])
			{
				Vector3 v = (rel - prevRel[h]) * TICRATE;
				int at = (ringAt[h] + 1) % RING;
				ringAt[h] = at;
				rvx[h * RING + at] = v.x; rvy[h * RING + at] = v.y; rvz[h * RING + at] = v.z;
				if (ringN[h] < RING) ringN[h]++;
			}
			prevRel[h] = rel;
			live[h] = true;
			// GE5: the watch-check pose switched off: never met (and "inspect" answers -1, see InspectOff)
			if (InspectOff()) { SetInspect(h, 0); insTics[h] = 0; }
			else Inspect1(pmo, h);
		}
		Measure(pmo);

		bool quiet = Quiet(pmo);
		if (SwSignals() || SwDebug() > 0) Signals(pmo, quiet);
		else { stillFor[0] = StillNow(0) ? stillFor[0] + 1 : 0; stillFor[1] = StillNow(1) ? stillFor[1] + 1 : 0; }
		if (SwTwohand()) TwoHand(pmo, quiet);

		bool br = IsBraced(pmo.player);
		if (br && bracedSince == 0) { bracedSince = gametic; if (SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: braced (t%d)", level.maptime); }
		else if (!br && bracedSince != 0) { bracedSince = 0; if (SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: unbraced (t%d)", level.maptime); }
		for (int h = 0; h < 2; h++)
		{
			if (quiet) { pArmed[h] = false; PunchReset(h); continue; }
			Punch1(pmo, h, br);
		}

		if (SwDebug() >= 2 && gametic % TICRATE == 0) Telemetry(pmo);
	}

	// ---- the ring -----------------------------------------------------------------------------------
	Vector3 VelAgo(int h, int ago)
	{
		int i = (ringAt[h] - ago + RING * 4) % RING;
		return (rvx[h * RING + i], rvy[h * RING + i], rvz[h * RING + i]);
	}
	// the hand's speed now: its movement over the last three tics (one rendered frame can land late)
	double SpeedNow(int h)
	{
		int n = min(ringN[h], 3);
		if (n <= 0) return 0;
		Vector3 s = (0, 0, 0);
		for (int i = 0; i < n; i++) s += VelAgo(h, i);
		s /= n;
		return s.Length();
	}
	// the fastest instant in the ring (RS_HAND_PEAK) and how many tics ago it was (-1 none)
	int PeakAgo(int h)
	{
		int best = -1; double bs = -1;
		for (int i = 0; i < ringN[h]; i++)
		{
			Vector3 v = VelAgo(h, i);
			double s = v.Length();
			if (s > bs) { bs = s; best = i; }
		}
		return best;
	}
	Vector3 PeakVel(int h)
	{
		int a = PeakAgo(h);
		return a < 0 ? (0, 0, 0) : VelAgo(h, a);
	}
	double PeakAgeMs(int h)
	{
		int a = PeakAgo(h);
		return a < 0 ? -1 : a * 1000.0 / TICRATE;
	}
	bool StillNow(int h) { return live[h] && ringN[h] > 0 && PeakVel(h).Length() < Num("rsqg_still_mps", 0.3); }

	// ---- INSPECT --------------------------------------------------------------------------------------
	void SetInspect(int h, int s)
	{
		if (insState[h] == s) { insStateTics[h]++; return; }
		if (SwDebug() >= 1)
			Console.Printf("\c[Gold]rsqg: inspect %s hand %d -> %d (t%d)", h == 0 ? "main" : "off", insState[h], s, level.maptime);
		insState[h] = s;
		insStateTics[h] = 0;
		// the pose is held: name it, and the light tick in that hand (GE4, GE7)
		if (s == 2)
		{
			Say("watch check (" .. HandName(h) .. ")");
			let pmo = Me();
			if (pmo) TickHand(pmo, h);
		}
	}

	static clearscope bool InspectOff() { return Opt("rsqg_inspect_off", 0) != 0; }

	// the pose: in front of the eyes at chest-to-face height, not pointing at floor or ceiling, wrist
	// twisted at least `need` degrees (the way rsqg_inspect_way says), `slack` metres of drift allowed
	static bool InspectPose(PlayerPawn pmo, int h, double slack, double need)
	{
		Vector3 b = RSQG_Pose.Body(pmo, h);
		double hs = HScale(), vs = VScale();   // GE3: fitted to your body (1, 1 unless Fit to My Body)
		if (b.x < Num("rsqg_inspect_near", 0.15) * hs - slack || b.x > Num("rsqg_inspect_far", 0.65) * hs + slack) return false;
		if (b.z < -Num("rsqg_inspect_low", 0.30) * vs - slack || b.z > Num("rsqg_inspect_high", 0.20) * vs + slack) return false;
		if (abs(b.y) > Num("rsqg_inspect_side", 0.35) * hs + slack) return false;
		if (abs(Actor.Normalize180(RSQG_Pose.Pitch(pmo, h))) > Num("rsqg_inspect_pitch", 60) + slack * 100) return false;
		double r = Actor.Normalize180(RSQG_Pose.Roll(pmo, h));
		// one way and the other: the engine reports a mirrored twist with the opposite sign on the
		// left controller (measured: right +60 stage roll reads +50, left -60 reads -50), so a
		// one-way choice is flipped for the physical left hand
		double s = RSQG_Pose.IsLeft(h) ? -1 : 1;
		int dir = Opt("rsqg_inspect_way", 0);
		if (dir == 1) return r * s >= need;
		if (dir == 2) return -r * s >= need;
		return abs(r) >= need;
	}

	void Inspect1(PlayerPawn pmo, int h)
	{
		int s = insState[h];
		bool still = SpeedNow(h) < Num("rsqg_inspect_still", 1.2);
		if (s == 0)
		{
			if (still && InspectPose(pmo, h, 0, Num("rsqg_inspect_twist", 45)))
			{
				insTics[h] = 1;
				SetInspect(h, Opt("rsqg_inspect_hold", 6) <= 1 ? 2 : 1);
			}
			else { insTics[h] = 0; SetInspect(h, 0); }
			return;
		}
		double slack = Num("rsqg_inspect_slack", 0.05);
		bool keep = InspectPose(pmo, h, slack, Num("rsqg_inspect_untwist", 30));
		// entering must stay still too (a swing through the pose is not holding it); once held you may
		// move the gun a little while you read it
		if (!keep || (s == 1 && !still)) { insTics[h] = 0; SetInspect(h, 0); return; }
		insTics[h]++;
		if (s == 1 && insTics[h] >= Opt("rsqg_inspect_hold", 6)) SetInspect(h, 2);
		else SetInspect(h, s);
	}

	// ---- ONE HAND (rsg_signals.zs) ----------------------------------------------------------------------
	// speed along the hand's own forward axis at the ring's fastest instant, metres a second; + away
	double ThrustAlong(PlayerPawn pmo, int h)
	{
		if (!live[h] || ringN[h] <= 0) return 0;
		Vector3 ax = RSQG_Pose.Forward(pmo, h);
		return PeakVel(h) dot ax;
	}

	void Signals(PlayerPawn pmo, bool quiet)
	{
		bool fire = SwSignals() && !quiet;   // GE1: never while climbing the rope or pointing at the Wheel
		double need = Num("rsqg_thrust_mps", 2.0), ageCap = Num("rsqg_thrust_age", 150);
		int repeat = Opt("rsqg_thrust_repeat", 12);
		for (int h = 0; h < 2; h++)
		{
			stillFor[h] = StillNow(h) ? stillFor[h] + 1 : 0;
			if (!fire || !live[h] || ringN[h] <= 0) continue;
			if (gametic - lastImpulse[h] < repeat) continue;
			double age = PeakAgeMs(h);
			if (age < 0 || (ageCap > 0 && age > ageCap)) continue;
			double along = ThrustAlong(pmo, h);
			// a peak from before the last announcement is the same movement (rsg_pair's SAME_PEAK rule)
			if (gametic - int(age * TICRATE / 1000.0 + 0.5) <= lastImpulse[h]) continue;
			String ev = "";
			if (along >= need) ev = "rsqg_thrust";
			else if (along <= -need) ev = "rsqg_pull";
			if (ev == "") continue;
			EventHandler.SendNetworkEvent(ev, h, int(round(abs(along) * 100)), 0);
			lastImpulse[h] = gametic;
			Say((ev == "rsqg_thrust" ? "thrust (" : "pull (") .. HandName(h) .. ")");
			if (SwDebug() >= 1)
				Console.Printf("\c[Gold]rsqg: %s, %s hand, %.2f m/s (t%d)", ev == "rsqg_thrust" ? "thrust" : "pull", h == 0 ? "main" : "off", abs(along), level.maptime);
		}
	}

	// ---- BRACED --------------------------------------------------------------------------------------
	// The engine's own latch, readable from any scope. WeaponState is play state the engine keeps for
	// every player, so unlike the hand pose this answer is true for any player, not only this machine's.
	static clearscope bool IsBraced(PlayerInfo p)
	{
		return p && (p.WeaponState & WF_TWOHANDSTABILIZED) != 0;
	}

	// ---- PUNCH (gloves.zs RSQ_GloveHandler.Swing / Classify, copied) ------------------------------------
	// SuperPunchOut's ClassifyPunch, unchanged: from how the hand travelled against the line you face.
	// The travel is metric with the vertical x pixelstretch (survey 01_MELEE 0: "this will cost you your
	// uppercut"), where gloves.zs hands it map units; the rule is the same.
	static int Classify(Vector3 dir, Vector2 toFoe, double rise)
	{
		double fwd = dir.xy dot toFoe;
		double lat = abs(dir.x * toFoe.y - dir.y * toFoe.x);
		if (dir.z > rise) return PK_UPPER;
		if (lat > 0.6 && lat > fwd) return PK_HOOK;
		return PK_JAB;
	}

	void PunchReset(int h) { pTravel[h] = 0; pTics[h] = 0; pStale[h] = 0; pDir[h] = (0, 0, 0); }

	void Punch1(PlayerPawn pmo, int h, bool isBr)
	{
		if (!live[h] || ringN[h] <= 0) { pArmed[h] = false; PunchReset(h); return; }
		double minMps = Num("rsqg_punch_mps", 2.0);
		Vector3 v = VelAgo(h, 0);
		// a tic that repeats the last pose exactly is a late frame, not a stop (the hand is written per
		// rendered frame): it neither adds to the swing nor ends it, for MAX_STALE tics
		if (v == (0, 0, 0) && pTics[h] > 0 && pStale[h] < MAX_STALE) { pStale[h]++; return; }
		pStale[h] = 0;
		double mps = v.Length();
		if (!pArmed[h])
		{
			if (gametic - punchTic[h] >= Opt("rsqg_punch_rehit", 6) && mps < minMps * 0.6) pArmed[h] = true;
			return;
		}
		if (mps >= IN_MPS && pTics[h] < MAX_TICS)
		{
			pTravel[h] += mps / TICRATE;
			pTics[h]++;
			pDir[h] += v / TICRATE;
		}
		else { PunchReset(h); return; }
		if (pTravel[h] < ARM_M) return;
		double avg = pTravel[h] * TICRATE / pTics[h];
		if (avg < minMps) return;

		// WHAT IS IN THAT HAND (GE2): a gun turns the swing into a shove; a blade's swing is its own
		int carry = Carry(pmo, h);
		Vector3 u = v.Unit();
		int o = 1 - h;
		bool together = live[o] && ringN[o] > 0 && (VelAgo(o, 0) dot u) >= mps * Num("rsqg_punch_together", 0.6);
		bool two = isBr || together;
		// NOT A PUNCH: a braced two-hand gun, or both hands shoving the same way together (a two-hand gun without
		// the latch -- Brutal Doom's butt-stroke push is exactly this). With a gun in THIS hand it is a two-hand shove.
		if (two && carry != CARRY_GUN)
		{
			if (SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: not a punch, %s hand, %.2f m/s: %s (t%d)", HandName(h), avg, isBr ? "braced" : "both hands together", level.maptime);
			pArmed[h] = false; PunchReset(h);
			return;
		}

		Vector2 face = (cos(pmo.Angle), sin(pmo.Angle));
		// NOT A PUNCH either: a hand drawn BACK (toward you, not rising as an uppercut does) or swung DOWN.
		// gloves.zs never meets these, because it counts only a swing that reaches a target in front; with
		// no target here the direction stands in for it (rig: the hand pulled back from a jab read "jab").
		// Nor a shove: Brutal Doom VR's butt strike must drive forward too (melee.zs rsvr_butt_fwd).
		double rise = Num("rsqg_punch_rise", 0.5);
		if (((u.xy dot face) < -0.3 && u.z <= rise) || u.z < -rise)
		{
			if (SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: not a %s, %s hand, %.2f m/s: %s (t%d)", carry == CARRY_GUN ? "shove" : "punch", HandName(h), avg, u.z < -rise ? "swung down" : "drawn back", level.maptime);
			pArmed[h] = false; PunchReset(h);
			return;
		}
		pArmed[h] = false; PunchReset(h);
		// a blade (the axe, the sword, the chainsaw: Brutal Doom VR swings them itself) is neither
		if (carry == CARRY_BLADE)
		{
			if (SwDebug() >= 1) Console.Printf("\c[Gold]rsqg: not a punch, %s hand, %.2f m/s: a blade in hand (t%d)", HandName(h), avg, level.maptime);
			return;
		}
		if (carry == CARRY_GUN)
		{
			// THE SHOVE (GE2): its own answer, never a punch. The knock back is Brutal Doom VR's own.
			shoveTic[h] = gametic; shoveTwo[h] = two; shoveMps[h] = avg;
			if (SwSignals()) EventHandler.SendNetworkEvent("rsqg_shove", h, two ? 1 : 0, int(round(avg * 100)));
			Say((two ? "two-hand shove (" : "shove (") .. HandName(h) .. ")");
			if (SwDebug() >= 1)
				Console.Printf("\c[Gold]rsqg: shove%s, %s hand, %.2f m/s, with %s (t%d)", two ? " (two hands)" : "", HandName(h), avg, CarryName(pmo, h), level.maptime);
			return;
		}
		int kind = Classify(u, face, rise);
		punchTic[h] = gametic; punchKind[h] = kind; punchMps[h] = avg;
		if (SwSignals()) EventHandler.SendNetworkEvent("rsqg_punch", h, kind, int(round(avg * 100)));
		String kn = kind == PK_JAB ? "jab" : kind == PK_HOOK ? "hook" : "uppercut";
		Say(kn .. " (" .. HandName(h) .. ")");
		if (SwDebug() >= 1)
			Console.Printf("\c[Gold]rsqg: punch %s, %s hand, %.2f m/s, dir fwd %.2f lat %.2f up %.2f (t%d)", kn,
				HandName(h), avg, u.xy dot face, u.x * face.y - u.y * face.x, u.z, level.maptime);
	}

	// WHAT A HAND CARRIES (GE2), from the engine's public weapon slots: the main hand's ReadyWeapon, the off hand's
	// OffhandWeapon (QuestZDoom). Fists are an empty hand: Brutal Doom's Melee_Attacks (main), Brutal Doom VR's
	// RSQ_Hands (the off hand's fist, fists.zs), vanilla's Fist. Any other +WEAPON.MELEEWEAPON is a blade (BD22's
	// BrutalAxe and the chainsaw carry it). Everything else is a gun.
	enum ECarry { CARRY_EMPTY, CARRY_GUN, CARRY_BLADE }
	static Weapon HandWeapon(PlayerPawn pmo, int h)
	{
		let p = pmo.player;
		if (!p) return null;
		return h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
	}
	static int Carry(PlayerPawn pmo, int h)
	{
		let w = HandWeapon(pmo, h);
		if (!w) return CARRY_EMPTY;
		Name cn = w.GetClassName();
		if (cn == 'Melee_Attacks' || cn == 'RSQ_Hands' || cn == 'Fist') return CARRY_EMPTY;
		// the blades Brutal Doom VR swings itself, by name too (melee.zs KindOf: BrutalAxe, DSweap, Chain_saw)
		if (w.bMeleeWeapon || cn == 'DSweap' || cn == 'Chain_saw' || cn == 'RSQ_Off_BrutalAxe') return CARRY_BLADE;
		return CARRY_GUN;
	}
	static String CarryName(PlayerPawn pmo, int h)
	{
		let w = HandWeapon(pmo, h);
		return w ? String.Format("%s", w.GetClassName()) : "nothing";
	}

	// ---- BOTH HANDS (rsg_pair.zs) -------------------------------------------------------------------
	double PeakTimeMs(int h, double maxAgeMs)
	{
		double age = PeakAgeMs(h);
		if (age < 0) return NEVER;
		if (maxAgeMs > 0 && age > maxAgeMs) return NEVER;
		return NowMs() - age;
	}

	// one palm out: in front, above the hips, still, pointing up (fingers up: no finger reading on QZD),
	// no trigger held
	bool PalmOut(PlayerPawn pmo, int h, double frontM, double hipM, double stillMps)
	{
		if (!live[h] || ringN[h] <= 0) return false;
		if (pmo.player.cmd.buttons & (BT_ATTACK | BT_ALTATTACK)) return false;
		if (PeakVel(h).Length() >= stillMps) return false;
		if (Actor.Normalize180(RSQG_Pose.Pitch(pmo, h)) < Num("rsqg_two_palms_pitch", 40)) return false;
		Vector3 b = RSQG_Pose.Body(pmo, h);
		return b.x >= frontM && b.z >= -hipM;
	}

	void TwoHand(PlayerPawn pmo, bool quiet)
	{
		// GE1: climbing the rope or pointing at the Wheel: none of the three
		if (quiet || !live[0] || !live[1]) { for (int h = 0; h < 2; h++) { downAt[h] = NEVER; apartAt[h] = NEVER; palmsAt[h] = NEVER; } palmsHeldFor = 0; palmsSaid = false; return; }
		double now = NowMs();
		double windowMs = max(Num("rsqg_two_window_ms", 120), 0);
		double ageMs = Num("rsqg_two_age", 180);
		double repeatMs = max(Num("rsqg_two_repeat_ms", 500), 0);
		double needDown = Num("rsqg_two_down_mps", 2.0);
		double downFrac = clamp(Num("rsqg_two_down_frac", 0.5), 0, 1);
		double hs = HScale(), vs = VScale();   // GE3: fitted to your body (1, 1 unless Fit to My Body)
		double hipM = Num("rsqg_two_hip_m", 0.60) * vs;
		double needApart = Num("rsqg_two_apart_mps", 2.0);
		double chestM = Num("rsqg_two_chest_m", 0.40) * vs, chestR = Num("rsqg_two_chest_r", 0.50) * hs;
		double frontM = Num("rsqg_two_front_m", 0.25) * hs;
		// GE6: each event on its own switch (under Two-Hand Events)
		bool doDown = Opt("rsqg_two_down", 1) != 0, doApart = Opt("rsqg_two_apart", 1) != 0, doPalms = Opt("rsqg_two_palms", 1) != 0;
		double holdMs = max(Num("rsqg_two_hold_ms", 400), 0);
		double stillMps = Num("rsqg_still_mps", 0.3);

		for (int h = 0; h < 2; h++)
		{
			double peakAt = PeakTimeMs(h, ageMs);
			Vector3 vel = PeakVel(h);
			Vector3 rel = RSQG_Pose.FromEyes(pmo, h);
			double speed = vel.Length();

			double downMove = -vel.z;
			bool downish = speed > 0.0001 && downMove / speed >= downFrac;
			if (peakAt > NEVER && peakAt > saidAt[PAIR_DOWN] + SAME_PEAK && downMove >= needDown && downish && rel.z <= -hipM)
			{
				downAt[h] = peakAt;
				downMps[h] = downMove;
			}

			Vector3 fromChest = (rel.x, rel.y, rel.z + chestM);
			double chestDist = fromChest.Length();
			if (peakAt > NEVER && peakAt > saidAt[PAIR_APART] + SAME_PEAK && chestDist > 0.0001 && chestDist <= chestR)
			{
				if ((vel dot fromChest.Unit()) >= needApart * 0.5) apartAt[h] = peakAt;
			}

			if (PalmOut(pmo, h, frontM, hipM, stillMps)) { if (palmsAt[h] <= NEVER) palmsAt[h] = now; }
			else palmsAt[h] = NEVER;
		}

		double capMs = ageMs > 0 ? ageMs : RING * 1000.0 / TICRATE;
		double liveMs = capMs + windowMs;

		if (doDown && Together(downAt[0], downAt[1], windowMs, now, liveMs))
		{
			if (Announce(PAIR_DOWN, min(downMps[0], downMps[1]), now, repeatMs)) { downAt[0] = NEVER; downAt[1] = NEVER; }
		}
		if (doApart && Together(apartAt[0], apartAt[1], windowMs, now, liveMs))
		{
			Vector3 sep = RSQG_Pose.FromEyes(pmo, 0) - RSQG_Pose.FromEyes(pmo, 1);
			double rate = 0;
			if (sep.Length() > 0.0001)
			{
				Vector3 closing = PeakVel(0) - PeakVel(1);
				rate = closing dot sep.Unit();
			}
			if (rate >= needApart && Announce(PAIR_APART, rate, now, repeatMs)) { apartAt[0] = NEVER; apartAt[1] = NEVER; }
		}

		// side by side, not one behind the other on a rifle
		Vector3 b0 = RSQG_Pose.Body(pmo, 0), b1 = RSQG_Pose.Body(pmo, 1);
		bool apartEnough = abs(b0.y - b1.y) >= Num("rsqg_two_palms_gap", 0.25) * hs;
		if (doPalms && palmsAt[0] > NEVER && palmsAt[1] > NEVER && apartEnough)
		{
			palmsHeldFor = (now - max(palmsAt[0], palmsAt[1])) / 1000.0;
			if (!palmsSaid && palmsHeldFor * 1000.0 >= holdMs && Announce(PAIR_PALMS, palmsHeldFor, now, 0)) palmsSaid = true;
		}
		else { palmsHeldFor = 0; palmsSaid = false; }
	}

	bool Together(double a, double b, double windowMs, double now, double liveMs)
	{
		if (a <= NEVER || b <= NEVER) return false;
		if (now - a > liveMs || now - b > liveMs) return false;
		return abs(a - b) <= windowMs;
	}

	bool Announce(int which, double mag, double now, double repeatMs)
	{
		if (which < 0 || which >= 3) return false;
		if (repeatMs > 0 && now - saidAt[which] < repeatMs) return false;
		EventHandler.SendNetworkEvent("rsqg_pair", which, int(round(mag * 100)), 0);
		saidAt[which] = now;
		Say(which == 0 ? "both hands down" : which == 1 ? "both hands apart" : "both palms out");
		if (SwDebug() >= 1)
			Console.Printf("\c[Gold]rsqg: pair %s, %.2f (t%d)", which == 0 ? "both hands down" : which == 1 ? "both hands apart" : "both palms out", mag, level.maptime);
		return true;
	}

	void Telemetry(PlayerPawn pmo)
	{
		for (int h = 0; h < 2; h++)
		{
			if (!live[h]) { Console.Printf("rsqg %s: no pose", h == 0 ? "main" : "off"); continue; }
			Vector3 b = RSQG_Pose.Body(pmo, h);
			Console.Printf("rsqg %s: fwd %.2f left %.2f up %.2f m  roll %.0f pitch %.0f  speed %.2f m/s  inspect %d (%d)  still %d",
				h == 0 ? "main" : "off", b.x, b.y, b.z, Actor.Normalize180(RSQG_Pose.Roll(pmo, h)), Actor.Normalize180(RSQG_Pose.Pitch(pmo, h)),
				SpeedNow(h), insState[h], insTics[h], stillFor[h]);
		}
	}

	// ---- the questions (play: a question also keeps the measuring awake) ------------------------------
	PlayerPawn Asked(int pn)
	{
		lastAsk = gametic;
		if (pn != consoleplayer) return null;
		Update();
		return Me();
	}

	int Inspect(int pn, int h)      { if (InspectOff()) return -1; if (!Asked(pn) || h < 0 || h > 1) return 0; return insState[h]; }
	int InspectTics(int pn, int h)  { if (InspectOff()) return -1; if (!Asked(pn) || h < 0 || h > 1) return 0; return insTics[h]; }
	int StillTics(int pn, int h)    { if (!Asked(pn) || h < 0 || h > 1) return 0; return stillFor[h]; }
	double Thrust(int pn, int h)    { let pmo = Asked(pn); if (!pmo || h < 0 || h > 1) return 0; return ThrustAlong(pmo, h); }
	double ThrustAgeMs(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1) return -1; return PeakAgeMs(h); }
	double PalmsOutSeconds(int pn)  { if (!Asked(pn)) return 0; return palmsHeldFor; }
	int Braced(int pn)              { lastAsk = gametic; if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return 0; return IsBraced(players[pn]) ? 1 : 0; }
	int BracedTics(int pn)          { if (!Asked(pn) || bracedSince == 0) return 0; return gametic - bracedSince + 1; }
	// the last punch: within rsqg_punch_window ms, kind + 1 (1 jab, 2 hook, 3 uppercut); else 0
	int PunchNow(int pn, int h)
	{
		if (!Asked(pn) || h < 0 || h > 1 || punchTic[h] <= 0) return 0;
		if ((gametic - punchTic[h]) * 1000.0 / TICRATE > Num("rsqg_punch_window", 300)) return 0;
		return punchKind[h] + 1;
	}
	int LastPunchKind(int pn, int h)    { if (!Asked(pn) || h < 0 || h > 1 || punchTic[h] <= 0) return -1; return punchKind[h]; }
	double PunchAgoMs(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1 || punchTic[h] <= 0) return -1; return (gametic - punchTic[h]) * 1000.0 / TICRATE; }
	double LastPunchMps(int pn, int h)  { if (!Asked(pn) || h < 0 || h > 1 || punchTic[h] <= 0) return 0; return punchMps[h]; }
	// the last shove (GE2): within rsqg_punch_window, 1 one hand, 2 two hands on the gun; else 0
	int ShoveNow(int pn, int h)
	{
		if (!Asked(pn) || h < 0 || h > 1 || shoveTic[h] <= 0) return 0;
		if ((gametic - shoveTic[h]) * 1000.0 / TICRATE > Num("rsqg_punch_window", 300)) return 0;
		return shoveTwo[h] ? 2 : 1;
	}
	double ShoveAgoMs(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1 || shoveTic[h] <= 0) return -1; return (gametic - shoveTic[h]) * 1000.0 / TICRATE; }
	double LastShoveMps(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1 || shoveTic[h] <= 0) return 0; return shoveMps[h]; }
	int QuietNow(int pn)            { if (!Asked(pn)) return 0; return gametic < quietTill ? quietWhy : 0; }
	double PairAgoMs(int pn, int k) { if (!Asked(pn) || k < 0 || k > 2 || saidAt[k] <= NEVER) return -1; return NowMs() - saidAt[k]; }
	double Hand(int pn, int h, int what)
	{
		let pmo = Asked(pn);
		if (!pmo || h < 0 || h > 1 || !live[h]) return 0;
		Vector3 b = RSQG_Pose.Body(pmo, h);
		if (what == 0) return b.x;
		if (what == 1) return b.y;
		if (what == 2) return b.z;
		if (what == 3) return Actor.Normalize180(RSQG_Pose.Roll(pmo, h));
		return Actor.Normalize180(RSQG_Pose.Pitch(pmo, h));
	}

	// read-only, from any scope: the last answer, without waking the measuring
	clearscope int Peek(int h) const { return (h < 0 || h > 1) ? 0 : insState[h]; }
	clearscope int PeekTics(int h) const { return (h < 0 || h > 1) ? 0 : insTics[h]; }
}

// THE STATIC API, for a mod that loads after this one and is happy to depend on it. Series mods call
// RSQG_Service by name instead (no compile dependency). Hands: 0 main, 1 off. The console player.
class RSQG
{
	static play int Inspect(int hand)      { let h = RSQG_Handler.Get(); return h ? h.Inspect(consoleplayer, hand) : 0; }
	static play int InspectTics(int hand)  { let h = RSQG_Handler.Get(); return h ? h.InspectTics(consoleplayer, hand) : 0; }
	static play int StillTics(int hand)    { let h = RSQG_Handler.Get(); return h ? h.StillTics(consoleplayer, hand) : 0; }
	static play double Thrust(int hand)    { let h = RSQG_Handler.Get(); return h ? h.Thrust(consoleplayer, hand) : 0; }
	static play double PalmsOutSeconds()   { let h = RSQG_Handler.Get(); return h ? h.PalmsOutSeconds(consoleplayer) : 0; }
	static clearscope bool Braced(PlayerPawn pmo) { return pmo && RSQG_Handler.IsBraced(pmo.player); }
	static play int Punch(int hand)        { let h = RSQG_Handler.Get(); return h ? h.PunchNow(consoleplayer, hand) : 0; }
	static play int Shove(int hand)        { let h = RSQG_Handler.Get(); return h ? h.ShoveNow(consoleplayer, hand) : 0; }
}

// RSQG_Service -- ask by name, no compile dependency:
//     let it = ServiceIterator.Find("RSQG_Service"); Service s;
//     while (s = it.Next()) state = s.GetInt("inspect", "", hand);
// intArg is the hand (0 main, 1 off) or, for "pair", the kind (0 down, 1 apart, 2 palms).
// objectArg may be the asking PlayerPawn: anyone but the console player gets 0 (the pose is local).
// -1 = unknown request.
class RSQG_Service : Service
{
	static int Pn(Object o)
	{
		let pmo = PlayerPawn(o);
		if (pmo && pmo.player) return pmo.PlayerNumber();
		return consoleplayer;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQG_Handler.Get();
		if (!h) return -1;
		int pn = Pn(objectArg);
		if (request ~== "inspect")      return h.Inspect(pn, intArg);                 // 0 not, 1 entering, 2 held
		if (request ~== "inspect.tics") return h.InspectTics(pn, intArg);             // tics since the pose was met (0 = not)
		if (request ~== "inspect.any")  return RSQG_Handler.InspectOff() ? -1 : max(h.Inspect(pn, 0), h.Inspect(pn, 1));   // -1: the pose is switched off (GE5)
		if (request ~== "still")        return h.StillTics(pn, intArg);               // tics the hand has been still
		if (request ~== "thrust")       return int(round(h.Thrust(pn, intArg) * 100)); // hundredths m/s along the hand (- = pulling back)
		if (request ~== "pair.ago")     return int(h.PairAgoMs(pn, intArg));          // ms since that two-hand gesture fired, -1 never
		if (request ~== "palms")        return int(h.PalmsOutSeconds(pn) * 1000);     // ms both palms have been out
		if (request ~== "mainleft")     return RSQG_Pose.MainIsLeft() ? 1 : 0;        // the main hand is the left controller
		if (request ~== "braced")       return h.Braced(PnAny(objectArg));            // 1 while the two-hand grip latch is on
		if (request ~== "braced.tics")  return h.BracedTics(pn);                      // tics it has been on (0 = not)
		if (request ~== "punch")        return h.PunchNow(pn, intArg);                // 1 jab, 2 hook, 3 uppercut within rsqg_punch_window; 0 none
		if (request ~== "punch.kind")   return h.LastPunchKind(pn, intArg);               // the last punch: 0 jab, 1 hook, 2 uppercut; -1 never
		if (request ~== "punch.ago")    return int(h.PunchAgoMs(pn, intArg));         // ms since it, -1 never
		if (request ~== "punch.speed")  return int(round(h.LastPunchMps(pn, intArg) * 100)); // its average, hundredths m/s
		if (request ~== "shove")        return h.ShoveNow(pn, intArg);                // GE2: 1 a gun shoved one-handed, 2 two hands on it, within rsqg_punch_window; 0 none. Never a punch.
		if (request ~== "shove.ago")    return int(h.ShoveAgoMs(pn, intArg));         // ms since the last shove, -1 never
		if (request ~== "shove.speed")  return int(round(h.LastShoveMps(pn, intArg) * 100)); // its average, hundredths m/s
		if (request ~== "quiet")        return h.QuietNow(pn);                        // GE1: 1 climbing the rope, 2 the Wheel open (or just closed); 0 gestures are read
		return -1;
	}

	// braced is the engine's play state, true for any player (not only this machine's hands)
	static int PnAny(Object o)
	{
		let pmo = PlayerPawn(o);
		if (pmo && pmo.player) return pmo.PlayerNumber();
		return consoleplayer;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQG_Handler.Get();
		if (!h) return 0;
		int pn = Pn(objectArg);
		// the hand from your eyes, metres: forward, left, up; and its roll and pitch, degrees
		if (request ~== "hand.x")     return h.Hand(pn, intArg, 0);
		if (request ~== "hand.y")     return h.Hand(pn, intArg, 1);
		if (request ~== "hand.z")     return h.Hand(pn, intArg, 2);
		if (request ~== "hand.roll")  return h.Hand(pn, intArg, 3);
		if (request ~== "hand.pitch") return h.Hand(pn, intArg, 4);
		if (request ~== "thrust")     return h.Thrust(pn, intArg);
		if (request ~== "palms")      return h.PalmsOutSeconds(pn);
		if (request ~== "punch.speed") return h.LastPunchMps(pn, intArg);
		if (request ~== "shove.speed") return h.LastShoveMps(pn, intArg);
		return 0;
	}

	// ui / any scope: the last inspect answer, read only (it does not keep the measuring awake: ask from
	// play at least once a second, or the answer goes to 0)
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}
	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQG_Handler(EventHandler.Find("RSQG_Handler"));
		if (!h) return -1;
		if (RSQG_Handler.InspectOff() && request.Left(7) ~== "inspect") return -1;   // GE5: switched off, not answering
		if (request ~== "inspect")      return h.Peek(intArg);
		if (request ~== "inspect.tics") return h.PeekTics(intArg);
		if (request ~== "inspect.any")  return max(h.Peek(0), h.Peek(1));
		if (request ~== "mainleft")     return RSQG_Pose.MainIsLeft() ? 1 : 0;
		if (request ~== "braced")
		{
			int pn = consoleplayer;
			let pmo = PlayerPawn(objectArg);
			if (pmo && pmo.player) pn = pmo.PlayerNumber();
			return (pn >= 0 && pn < MAXPLAYERS && playeringame[pn] && RSQG_Handler.IsBraced(players[pn])) ? 1 : 0;
		}
		return -1;
	}
}

// THE WATCH-CHECK TICK (GE4): a short, light rumble on one controller, the series' route (RSQ Accessibility's
// RSQA_Buzz, RSQ Wheel's wr_Buzz): A_QuakeEx QF_WAVE re-issued every tic, X driving the left controller and Y the
// right (r_utility.cpp:1084-1094), scaled by vr_quake_haptic_level; amplitude / 3.2 is the controller's peak.
// The local player only; no sound, no damage, an 8-unit tremor radius at the player.
class RSQG_Tick : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;

	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH +NOTIMEFREEZE }

	static void Start(Actor who, bool leftController, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let q = RSQG_Tick(Actor.Spawn("RSQG_Tick", who.pos));
		if (!q) return;
		q.feels = who;
		q.left = leftController;
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels || tleft <= 0) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}
