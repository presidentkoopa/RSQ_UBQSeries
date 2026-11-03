// THE BODY'S TURN KEEPER, copied from RSQ TacticalRig (zscript/rsqtr/body.zs, RSQTR_TurnKeeper) so this mod works
// alone: the two must stay the same, so the shield and the rig's torso turn together. Used by SSQ_Handler.BodyKeep.
//
// THE TURN KEEPER (the owner's headset, 11-03 10:53: "the rig does not play well with snap turn, i can 360 around my
// torso and the shield doesn't move and the torso doesn't turn, or does sometimes"). How far the body turned this tic
// with the TRACKING SPACE (snap, smooth, a teleport's facing) or, with ssq_body_hands, with the head and both hands
// turning together in the room.
//
// WHY THE OLD SAME-TIC TEST MISSED (measured on the qzd17.3 rig, tools/rigtest/turnprobe, 11-03): the engine writes the
// controller yaws in the renderer's SetUp from doomYaw BEFORE that frame's turn is added to it (hw_openxrdevice.cpp
// 590 / 603 before updateHmdPose 739), while the turn reaches pawn.angle through the next ticcmd. So the controllers
// always trail the view by one rendered frame: a snap shows in the pawn's angle on one tic and in the controllers on
// the same tic or the next one (or, with frames dropped, several tics later), and every head step moves the controller
// yaws back by that frame's step and forward again. The old rule asked for all three in the same tic within 1.5
// degrees: over 8 snaps right then 8 left at 90 fps the old body moved -45, -45, -45, 0, -12, -60, -94, -56 and 0, 56,
// 69, 47, 45, 45, 0, 57 (missed snaps, then the head-held catch-up smearing them); RSQ ShieldSaw's copy (controllers
// exactly one tic late) 0, -9, -57, -98, -46, -45, -45, -45 and 34, 0, 0, 0, 0, -9, -15, -20. A smooth 360 left the
// old body 10 degrees off (ShieldSaw's 220-365), a real turn in the room left it 12-25 degrees short, and looking
// down at a hip holster while swinging the head slid it 13-18 degrees.
//
// NOW, three parts:
//   SNAPS (ViewJump): a head step of a snap's size in one tic waits for the controllers' matching step and the body
//   turns by exactly vr_snapTurn.
//   STEPS (Match): the head's yaw steps and the two controllers' COMMON yaw step (the smaller of the two when they turn
//   the same way, else none) each go into a short queue, and the body turns by what the two queues share, in the same
//   direction: a head turn alone shares nothing with still hands; one hand reaching shares nothing (the other hand did
//   not turn). A controller step AGAINST the head's step is the engine's late frame, so it is set aside as owed, never
//   matched, for LATE_TICS, and its return pays it off before it can be read as a turn. The two queues must also agree
//   like a turn of the tracking space does (the head's share within a third of the controllers', and within AGREE
//   degrees). A controller pointed steeply up or down (YAW_PITCH) has no yaw to go by and shares nothing.
//   SETTLING (below): the totals of every turn put right what the steps missed.
//
// TURNING WITH HEAD AND HANDS (ssq_body_hands, on; the owner's ask, 11-03: a real 360 in the room must carry the rig):
// hands held in front of you mark where your body faces. When the head AND both controllers (each held within HAND_PITCH
// of level, so a hand hanging down or in a holster never counts) all face more than START_AT degrees to the same side of
// the body for DWELL tics, the body turns to the nearest of the three, up to CHASE degrees a tic, until it is within
// STOP_AT; for AGAIN_TICS after that, a lead of AGAIN_AT starts it again, so a real turn ends with the body on the hands.
// Looking down past the "ignore looking down" angle never starts or continues it; one hand, or the head alone, never.
//
// SETTLING (11-03, second pass; measured on the rig, turnprobe): the queues alone lost a step now and then. A smooth
// 360 at 90 fps ended with the body 5.0 degrees short of the pawn (a controller step expired unmatched), and the room
// 360 back ended 10.0 short (too small for TURNING WITH HEAD AND HANDS to start); each stayed so for good, because
// nothing looked at the totals. So every run of matched steps is now a TURN, and a turn is SETTLED SETTLE_TICS after
// its last matched step by the totals, not the steps: from just before its first step (HIST tics, never before the
// last settled turn), how far the head turned, how far each controller turned, and how far the body turned (all the
// keeper's own turns, TURNING WITH HEAD AND HANDS included). Totals cannot miss a tic: the controllers' late frame
// cancels out over a turn. Then:
//   - snaps were turned exactly when they came (SNAPS, ViewJump below) and are taken out of every total first;
//   - when the three agree (within SETTLE_TOL, or a tenth): the body's turn is made the middle one (a smooth turn, or
//     the head and hands turning together in the room), unless it is already within SETTLE_NEAR;
//   - otherwise, if the body turned further than all three did (or the other way): back to what they share; a body
//     that turned less is left (TURNING WITH HEAD AND HANDS and the head-held catch-up are still at it);
//   - a turn that TURNING WITH HEAD AND HANDS took part in is left to it.
// A turn is settled only once two rendered frames have reached the script since its last step (or SETTLE_MAX tics).
// While the stick turns smoothly, a step's match may also differ from the head's by one rendered frame's turn (up to
// vr_snapTurn degrees: the controllers trail the view by exactly one frame), so the body moves every tic instead of in
// two-tic bursts; whatever that lets through by mistake, the settling takes back.
class SSQ_TurnKeeper play
{
	const WAIT_TICS = 6;           // tics a step waits for its match in the other queue
	const LATE_TICS = 70;           // tics a late controller step (against the head) waits for its return
	const START_AT = 20.0;        // degrees: head and both hands this far round the same way...
	const DWELL = 8;           // ...for this many tics (0.23 s) start the body turning with them
	const STOP_AT = 1.0;          // degrees: and it stops this close to the nearest of the three
	const AGAIN_AT = 4.0;      // degrees: within AGAIN_TICS of its last turn, this lead starts it again
	const AGAIN_TICS = 35;
	const CHASE = 12.0;        // most degrees a tic it turns while it catches up
	const HAND_PITCH = 50.0;   // degrees: a controller pointed further up or down than this marks no heading
	const AGREE = 6.0;         // degrees: head and controllers' shares this close (and within a third) = the tracking space
	const OWE_MAX = 20.0;      // degrees: the most a late controller is taken to owe (Owe): a frame's head step, at a slow frame
	const SNAPTOL = 0.15;      // of a snap: a head jump this close to vr_snapTurn is one snap; a controller step this close matches it
	const JUMP_DEG = 20.0;         // degrees in one tic: no head turns this fast; a jump of the view (a snap: 0.6 of vr_snapTurn)
	const JUMP_FRAMES = 2;     // rendered frames a snap's head jump waits for the controllers' (they come with the next)
	const MAX_WAIT = 35;       // tics: and no wait for a snap is longer than this (no frame drawn: a level load, a hitch)
	const SETTLE_MAX = 16;     // tics: a turn is settled this long after its last step even with no new frame seen
	const YAW_PITCH = 65.0;    // degrees: a controller pointed further up or down than this has no yaw to match
	const HIST = 20;           // tics before its first matched step a turn's totals start (covers WAIT_TICS and a slow frame)
	const SETTLE_TICS = 8;     // tics after its last matched step a turn is settled
	const SETTLE_TOL = 3.0;    // degrees: head and both controllers' totals this close together (or within a tenth) agree
	const SETTLE_NEAR = 1.0;   // degrees: a body's turn this close to what they agree on is left be

	double lastA, lastH0, lastH1;
	Array<double> hAmt, cAmt;  // pending steps, head and controllers; each queue is all one sign
	Array<int> hEnd, cEnd;     // the tic each pending step expires
	int withFor;               // tics head and hands have been round the same way (TURNING WITH HEAD AND HANDS)
	bool withOn;
	int withLast;              // the last tic it turned the body
	Array<double> lAmt, mAmt;  // what each late controller still owes (main, off): its steps against the head, waiting to come back
	Array<int> lEnd, mEnd;
	// SETTLING: the last HIST tics (head, each controller, the body's turn, the tic), and the open turn's totals
	Array<double> rA, r0, r1, rB, rJ, rW;
	Array<int> rT;
	bool tOn;
	int tLast, tSettled;
	double tA, t0, t1, tB, tJ, tW;
	double jPend;              // SNAPS: the head's jump waiting for the controllers (ViewJump)
	int jEnd, jFrames;
	bool jGot0, jGot1;
	int frames, tFrames;       // rendered frames seen (Step), and at the open turn's last matched step
	double lastSettle;         // the last settling's correction (the probe reads it)

	void Prime(double a, double h0, double h1)
	{
		lastA = a; lastH0 = h0; lastH1 = h1;
		hAmt.Clear(); hEnd.Clear(); cAmt.Clear(); cEnd.Clear(); lAmt.Clear(); lEnd.Clear(); mAmt.Clear(); mEnd.Clear();
		rA.Clear(); r0.Clear(); r1.Clear(); rB.Clear(); rJ.Clear(); rW.Clear(); rT.Clear();
		withFor = 0; withOn = false; tOn = false; tSettled = 0; lastSettle = 0; jPend = 0; frames = tFrames = 0;
	}

	// this tic's turn of the body, degrees; snap = vr_snapTurn (a snap when over 10, a smooth turn's most per frame
	// when 10 or less)
	double Step(double a, double h0, double h1, double p0, double p1, int now, double snap)
	{
		double dA = Actor.DeltaAngle(lastA, a);
		double d0 = Actor.DeltaAngle(lastH0, h0), d1 = Actor.DeltaAngle(lastH1, h1);
		lastA = a; lastH0 = h0; lastH1 = h1;
		// this tic's record (the body's share is filled in by Note), and the open turn's totals
		rA.Push(dA); r0.Push(d0); r1.Push(d1); rB.Push(0); rJ.Push(0); rW.Push(0); rT.Push(now);
		while (rT.Size() > HIST) { rA.Delete(0); r0.Delete(0); r1.Delete(0); rB.Delete(0); rJ.Delete(0); rW.Delete(0); rT.Delete(0); }
		if (tOn) { tA += dA; t0 += d0; t1 += d1; }
		// a rendered frame reached the script: the controller yaws are written once a frame (a live hand never holds
		// exactly still). Under load the rig rendered one frame in 9 tics, and every wait counted in tics ran out.
		if (abs(d0) > 0.0001 || abs(d1) > 0.0001) frames++;
		double j = ViewJump(dA, d0, d1, now, snap);
		// A CONTROLLER POINTED STEEPLY UP OR DOWN HAS NO YAW TO GO BY (measured on the rig: a hand held down at a hip
		// holster read yaws swinging through 180 degrees while it moved a few centimetres). Its steps match nothing; a
		// snap still needs only the other controller (ViewJump).
		if (abs(p0) > YAW_PITCH) d0 = 0;
		if (abs(p1) > YAW_PITCH) d1 = 0;
		double m = Match(dA, d0, d1, now, snap);
		if (j != 0 || m != 0)
		{
			if (!tOn) Open();
			tLast = now;
			tFrames = frames;
		}
		if (j != 0) { rJ[rJ.Size() - 1] += j; tJ += j; }
		Note(j + m);
		m += j;
		if (tOn && now - tLast >= SETTLE_TICS && (frames - tFrames >= 2 || now - tLast >= SETTLE_MAX)) m += Settle(now, snap);
		return m;
	}

	// SNAPS (and any other one-tic jump of the view, a teleport's new facing): a head step of JUMP_DEG or more in one tic is
	// no head (a person's quickest look is a few degrees a tic) and goes in no queue. It waits JUMP_FRAMES frames for
	// the controllers: each one's step that matches it (within SNAPTOL of a snap, or 3 degrees) is taken out of that
	// controller's step, and once both have matched (or one, when the wait runs out: a hand pointed straight down has no
	// yaw to speak of) the body turns by EXACTLY the snap. A head jump the controllers never follow turns nothing.
	// (11-03, second pass: the shared queues let a head swing in the tics before a snap eat it; measured on the rig, the
	// body missed a snap made while looking down at a holster and turned 89 degrees on the next one.)
	double ViewJump(double dA, out double d0, out double d1, int now, double snap)
	{
		double jmin = snap > 10 ? 0.6 * snap : JUMP_DEG;
		if (abs(dA) > jmin)
		{
			jPend = (snap > 10 && abs(abs(dA) - snap) < SNAPTOL * snap + 3) ? (dA > 0 ? snap : -snap) : dA;
			jEnd = now + MAX_WAIT;
			jFrames = frames;
			jGot0 = jGot1 = false;
		}
		if (jPend == 0) return 0;
		// a controller stepping AGAINST the jump first is the engine's late frame after a head that moved (the
		// controllers go back by the head's step, then forward again): no snap. Measured on the rig: the head set 60
		// degrees round and back in one tic each, and that return matched the controllers' coming back.
		if ((d0 * jPend < 0 && abs(d0) > 0.5 * abs(jPend)) || (d1 * jPend < 0 && abs(d1) > 0.5 * abs(jPend))) { jPend = 0; return 0; }
		double tol = max(SNAPTOL * abs(jPend), 3.0);
		if (!jGot0 && abs(d0 - jPend) < tol) { d0 -= jPend; jGot0 = true; }
		if (!jGot1 && abs(d1 - jPend) < tol) { d1 -= jPend; jGot1 = true; }
		// the frame after the snap's carries it to the controllers: two frames on (or MAX_WAIT tics), the wait is over
		bool over = now >= jEnd || frames - jFrames >= JUMP_FRAMES;
		if ((jGot0 && jGot1) || (over && (jGot0 || jGot1)))
		{
			double r = jPend;
			jPend = 0;
			return r;
		}
		if (over) jPend = 0;
		return 0;
	}

	// a turn starts: its totals from the last HIST tics (none from before the last settling)
	void Open()
	{
		tOn = true; tA = t0 = t1 = tB = tJ = tW = 0;
		for (int i = 0; i < rT.Size(); i++)
		{
			if (rT[i] <= tSettled) continue;
			tA += rA[i]; t0 += r0[i]; t1 += r1[i]; tB += rB[i]; tJ += rJ[i]; tW += rW[i];
		}
	}

	// the body turned by t this tic (any of the keeper's turns)
	void Note(double t)
	{
		if (t == 0) return;
		if (rB.Size() > 0) rB[rB.Size() - 1] += t;
		if (tOn) tB += t;
	}

	// SETTLING (above): the correction that makes the body's turn what the totals say
	double Settle(int now, double snap)
	{
		tOn = false;
		tSettled = now;
		// the snaps were turned exactly (ViewJump): only what the three turned besides them is looked at
		double a = tA - tJ, c0 = t0 - tJ, c1 = t1 - tJ, b = tB - tJ;
		// the turn the three agree on: the middle one of head and controllers (one hand or the head moving on its own
		// does not move it), and how far apart they are
		double lo = min(a, min(c0, c1)), hi = max(a, max(c0, c1));
		double mid = a + c0 + c1 - lo - hi;
		bool together = c0 * c1 > 0 && c0 * a > 0;
		double want = b;
		// TURNING WITH HEAD AND HANDS took part: it turns the body to where head and hands face now, not by what they
		// turned in this window, and it carries on until it is there; totals would only undo it (measured on the rig: a
		// real turn's settling pulled the body back 25 degrees, and the chase brought it round again)
		if (abs(tW) > 0.01) want = b;
		else if (together && hi - lo <= max(SETTLE_TOL, 0.1 * abs(mid)))
		{
			// they agree: a smooth turn, or head and hands turning together; a body already this close is left be
			if (abs(b - mid) > SETTLE_NEAR) want = mid;
		}
		else
		{
			// they do not: the steps matched were no turn of the tracking space (a head swinging while the hands
			// moved). A body turned further than all three (or against them) goes back to what they share; measured on
			// the rig, looking down at a hip holster with the head sweeping and the hands moving, this took the body
			// back from 31 degrees.
			double share = together ? (c0 > 0 ? 1 : -1) * min(abs(a), min(abs(c0), abs(c1))) : 0;
			if (b * share < 0 || abs(b) > abs(share) + SETTLE_NEAR) want = share;
		}
		// what was pending is part of this turn: settled with it
		hAmt.Clear(); hEnd.Clear(); cAmt.Clear(); cEnd.Clear();
		double c = want - b;
		lastSettle = c;
		if (abs(c) < 0.01) return 0;
		Note(c);
		return c;
	}

	// the step matcher: what the head's and the controllers' queues share this tic
	double Match(double dA, double d0, double d1, int now, double snap)
	{
		if (abs(dA) > (snap > 10 ? 0.6 * snap : JUMP_DEG)) dA = 0;	// a snap's head step: ViewJump's
		Expire(hAmt, hEnd, now);
		Expire(cAmt, cEnd, now);
		Expire(lAmt, lEnd, now);
		Expire(mAmt, mEnd, now);
		// each late controller coming back first pays off what it owes; a new step against the head's is owed, never
		// matched (measured at 35 fps: the controllers trail the head by one frame's step, +0.4, +1.0, +1.4, +1.9
		// while it sped up, back to 0 as it stopped; matched, that moved the torso 1.9 degrees). Kept per controller: a
		// hand pointed down (at a holster) swings its yaw about, and a shared reading lost the other hand's debt.
		d0 = Owe(lAmt, lEnd, d0, dA, now, snap);
		d1 = Owe(mAmt, mEnd, d1, dA, now, snap);
		double c = 0;
		if (d0 * d1 > 0) c = abs(d0) < abs(d1) ? d0 : d1;
		Add(hAmt, hEnd, dA, now + WAIT_TICS);
		Add(cAmt, cEnd, c, now + WAIT_TICS);
		double sH = Sum(hAmt), sC = Sum(cAmt);
		if (sH * sC <= 0) return 0;
		double m = abs(sH) < abs(sC) ? sH : sC;
		if (abs(sH - sC) > min(abs(sC) / 3.0, AGREE) + 0.5 + (snap > 0 && snap <= 10 ? snap : 0)) return 0;
		Take(hAmt, hEnd, m);
		Take(cAmt, cEnd, m);
		return m;
	}

	// TURNING WITH HEAD AND HANDS: this tic's turn of the body (yaw) toward the head (a) and the controllers (h0, h1
	// as the engine gives them: a controller held straight ahead reads the pawn's angle less 90; p0, p1 their pitch).
	// allowed: the switch is on and nothing holds the body still (looking down, edit mode).
	double With(double yaw, double a, double h0, double h1, double p0, double p1, bool allowed)
	{
		double o = Actor.DeltaAngle(yaw, a), o0 = Actor.DeltaAngle(yaw, h0 + 90), o1 = Actor.DeltaAngle(yaw, h1 + 90);
		bool same = allowed && jPend == 0 && abs(p0) <= HAND_PITCH && abs(p1) <= HAND_PITCH && o * o0 > 0 && o * o1 > 0;
		double near = min(abs(o), min(abs(o0), abs(o1)));
		if (!same || near < STOP_AT) { withFor = 0; withOn = false; return 0; }
		if (!withOn)
		{
			// just after it turned with you, a smaller lead starts it again (a real turn's head and hands lead and stop
			// at their own pace: measured on the rig, the body caught the trailing hands, stopped, and was left 18.6
			// degrees short when they stopped under START_AT)
			double start = level.maptime - withLast <= AGAIN_TICS ? AGAIN_AT : START_AT;
			withFor = near > start ? withFor + 1 : 0;
			if (withFor < DWELL) return 0;
			withOn = true;
		}
		withLast = level.maptime;
		double t = clamp((o > 0 ? 1 : -1) * near * 0.5, -CHASE, CHASE);
		// what this turn covers is no longer pending: the queues must not turn the body by it a second time
		if (Sum(hAmt) * t > 0 && Sum(cAmt) * t > 0) { Take(hAmt, hEnd, t); Take(cAmt, cEnd, t); }
		Note(t);
		if (rW.Size() > 0) rW[rW.Size() - 1] += t;
		if (tOn) tW += t;
		return t;
	}

	// one controller's step after its debt: a step back pays it off; a step against the head's step is owed
	// (11-03, second pass) A snap's step pays no debt and is never owed (snaps are ViewJump's), and what a controller
	// owes is capped at OWE_MAX: measured on the rig, a hand reaching about a hip holster (its yaw swinging +-40
	// degrees) while the head swept +-60 ran up debts of tens of degrees, and the next snap's controller step went to
	// paying them: the body missed that snap, then turned 89 degrees on the one after. The engine's late frame is never
	// more than a frame's head step (16-19 degrees seen on the rig when its frames came in bursts; a 6-degree cap let
	// that through as a 16-degree turn).
	static double Owe(Array<double> q, Array<int> e, double d, double dA, int now, double snap)
	{
		if (snap > 10 && abs(d) > 0.5 * snap) return d;
		d = Cancel(q, e, d);
		if (d * dA < 0 && abs(d) <= abs(dA) + 0.5 && abs(Sum(q) + d) <= OWE_MAX) { Add(q, e, d, now + LATE_TICS); return 0; }
		return d;
	}

	static double Sum(Array<double> q) { double s = 0; for (int i = 0; i < q.Size(); i++) s += q[i]; return s; }

	static void Expire(Array<double> q, Array<int> e, int now)
	{
		for (int i = q.Size() - 1; i >= 0; i--) if (e[i] < now) { q.Delete(i); e.Delete(i); }
	}

	// a new step: one against the queue cancels its oldest entries first, so the queue keeps one sign
	static void Add(Array<double> q, Array<int> e, double v, int endTic)
	{
		v = Cancel(q, e, v);
		if (abs(v) >= 0.0001) { q.Push(v); e.Push(endTic); }
	}

	// a step against the queue takes its oldest entries away; what is left of the step comes back
	static double Cancel(Array<double> q, Array<int> e, double v)
	{
		while (q.Size() > 0 && q[0] * v < 0 && abs(v) >= 0.0001)
		{
			if (abs(q[0]) <= abs(v)) { v += q[0]; q.Delete(0); e.Delete(0); }
			else { q[0] += v; v = 0; }
		}
		return abs(v) < 0.0001 ? 0 : v;
	}

	// take a matched amount out, oldest first (same sign as the queue)
	static void Take(Array<double> q, Array<int> e, double m)
	{
		double r = abs(m);
		while (q.Size() > 0 && r > 0)
		{
			double x = abs(q[0]);
			if (x <= r + 0.0001) { r -= x; q.Delete(0); e.Delete(0); }
			else { q[0] = q[0] > 0 ? x - r : r - x; r = 0; }
		}
	}
}
