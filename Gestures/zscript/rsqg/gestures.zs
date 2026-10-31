// RSQ_Gestures -- what the hands are doing, for any series mod that asks. Ported from the owner's
// RS_Gestures (written for his REMA engine) to stock QuestZDoom 17.3.
//
// THREE KINDS, as in RS_Gestures:
//   POSE      one hand held a certain way: INSPECT (new here, the weapon cards' "show me"), STILL.
//   IMPULSE   one hand moving fast along its own axis: THRUST (away), PULL (back). rsg_signals.zs.
//   BOTH      a relationship between the two hands: both swept DOWN past the hips, thrown APART from
//             the chest, both PALMS held out. rsg_pair.zs.
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
			downAt[h] = NEVER; downMps[h] = 0; apartAt[h] = NEVER; palmsAt[h] = NEVER;
		}
		for (int k = 0; k < 3; k++) saidAt[k] = NEVER;
		palmsHeldFor = 0; palmsSaid = false;
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
		return gametic - lastAsk <= IDLE || SwSignals() || SwTwohand() || dbg == 1 || dbg == 2;
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
			Inspect1(pmo, h);
		}

		if (SwSignals() || SwDebug() > 0) Signals(pmo);
		else { stillFor[0] = StillNow(0) ? stillFor[0] + 1 : 0; stillFor[1] = StillNow(1) ? stillFor[1] + 1 : 0; }
		if (SwTwohand()) TwoHand(pmo);

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
	}

	// the pose: in front of the eyes at chest-to-face height, not pointing at floor or ceiling, wrist
	// twisted at least `need` degrees (the way rsqg_inspect_way says), `slack` metres of drift allowed
	static bool InspectPose(PlayerPawn pmo, int h, double slack, double need)
	{
		Vector3 b = RSQG_Pose.Body(pmo, h);
		if (b.x < Num("rsqg_inspect_near", 0.15) - slack || b.x > Num("rsqg_inspect_far", 0.65) + slack) return false;
		if (b.z < -Num("rsqg_inspect_low", 0.30) - slack || b.z > Num("rsqg_inspect_high", 0.20) + slack) return false;
		if (abs(b.y) > Num("rsqg_inspect_side", 0.35) + slack) return false;
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

	void Signals(PlayerPawn pmo)
	{
		bool fire = SwSignals();
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
			if (SwDebug() >= 1)
				Console.Printf("\c[Gold]rsqg: %s, %s hand, %.2f m/s (t%d)", ev == "rsqg_thrust" ? "thrust" : "pull", h == 0 ? "main" : "off", abs(along), level.maptime);
		}
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

	void TwoHand(PlayerPawn pmo)
	{
		if (!live[0] || !live[1]) { for (int h = 0; h < 2; h++) { downAt[h] = NEVER; apartAt[h] = NEVER; palmsAt[h] = NEVER; } palmsHeldFor = 0; palmsSaid = false; return; }
		double now = NowMs();
		double windowMs = max(Num("rsqg_two_window_ms", 120), 0);
		double ageMs = Num("rsqg_two_age", 180);
		double repeatMs = max(Num("rsqg_two_repeat_ms", 500), 0);
		double needDown = Num("rsqg_two_down_mps", 2.0);
		double downFrac = clamp(Num("rsqg_two_down_frac", 0.5), 0, 1);
		double hipM = Num("rsqg_two_hip_m", 0.60);
		double needApart = Num("rsqg_two_apart_mps", 2.0);
		double chestM = Num("rsqg_two_chest_m", 0.40), chestR = Num("rsqg_two_chest_r", 0.50);
		double frontM = Num("rsqg_two_front_m", 0.25);
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

		if (Together(downAt[0], downAt[1], windowMs, now, liveMs))
		{
			if (Announce(PAIR_DOWN, min(downMps[0], downMps[1]), now, repeatMs)) { downAt[0] = NEVER; downAt[1] = NEVER; }
		}
		if (Together(apartAt[0], apartAt[1], windowMs, now, liveMs))
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
		bool apartEnough = abs(b0.y - b1.y) >= Num("rsqg_two_palms_gap", 0.25);
		if (palmsAt[0] > NEVER && palmsAt[1] > NEVER && apartEnough)
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

	int Inspect(int pn, int h)      { if (!Asked(pn) || h < 0 || h > 1) return 0; return insState[h]; }
	int InspectTics(int pn, int h)  { if (!Asked(pn) || h < 0 || h > 1) return 0; return insTics[h]; }
	int StillTics(int pn, int h)    { if (!Asked(pn) || h < 0 || h > 1) return 0; return stillFor[h]; }
	double Thrust(int pn, int h)    { let pmo = Asked(pn); if (!pmo || h < 0 || h > 1) return 0; return ThrustAlong(pmo, h); }
	double ThrustAgeMs(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1) return -1; return PeakAgeMs(h); }
	double PalmsOutSeconds(int pn)  { if (!Asked(pn)) return 0; return palmsHeldFor; }
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
		if (request ~== "inspect.any")  return max(h.Inspect(pn, 0), h.Inspect(pn, 1));
		if (request ~== "still")        return h.StillTics(pn, intArg);               // tics the hand has been still
		if (request ~== "thrust")       return int(round(h.Thrust(pn, intArg) * 100)); // hundredths m/s along the hand (- = pulling back)
		if (request ~== "pair.ago")     return int(h.PairAgoMs(pn, intArg));          // ms since that two-hand gesture fired, -1 never
		if (request ~== "palms")        return int(h.PalmsOutSeconds(pn) * 1000);     // ms both palms have been out
		if (request ~== "mainleft")     return RSQG_Pose.MainIsLeft() ? 1 : 0;        // the main hand is the left controller
		return -1;
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
		if (request ~== "inspect")      return h.Peek(intArg);
		if (request ~== "inspect.tics") return h.PeekTics(intArg);
		if (request ~== "inspect.any")  return max(h.Peek(0), h.Peek(1));
		if (request ~== "mainleft")     return RSQG_Pose.MainIsLeft() ? 1 : 0;
		return -1;
	}
}
