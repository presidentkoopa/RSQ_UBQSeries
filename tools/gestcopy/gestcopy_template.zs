// @P@_GCopy -- @MOD@'s OWN COPY of RSQ Accessibility's gesture reader, used ONLY when RSQ Accessibility is not loaded
// (tools/gestcopy/gestcopy_template.zs, written by tools/gestcopy/gen_gestcopy.py; GENERATED, do not edit here).
// Owner 2026-11-04 19:45: "I worry that anyone who uses Gun Cards won't have the standout feature of the watch check card
// because they didn't have Gestures." So each mod whose standout rides on a gesture carries the detector itself. (The
// reader was RSQ Gestures until it was folded into RSQ Accessibility, 11-05, keeping its class and cvar names.)
//
// WHAT IT IS. A copy of the reader (Accessibility/zscript/rsqg/gestures.zs RSQG_Handler, pose.zs RSQG_Pose), not a
// rewrite: the same pose rules, the same numbers, the same cvar names (rsqg_*: without RSQ Accessibility those cvars do
// not exist, so every number here is the default its CVARINFO gives; gen_gestcopy.py checks that on every run), the left
// hand mirrored the same way.
@IF INSPECT@
//   INSPECT  the watch check, one hand: in front of the eyes at chest-to-face height, wrist turned rsqg_inspect_twist
//            degrees, still, held rsqg_inspect_hold tics (RSQG_Handler.InspectPose / Inspect1, copied).
@END@
@IF LOOK@
//   LOOK     the wrist checks by the rule of 2026-11-27 (owner: "Look at it, it shows"; "i want them to be fuckin
//            reliable"): the watch check ("inspect", the back of the wrist) and the pulse check ("pulse", the inside of
//            the wrist). A side of a wrist is checked while its face is turned toward your eyes AND you are looking toward
//            that wrist. No box, no pitch limit, no stillness, no hold: the answer is 0 or 2. See THE WRIST CHECK below.
//            A LOOK copy is its own reader: it does NOT stand down for RSQ Accessibility and asks it nothing (owner
//            2026-11-27 08:10: "remove accesability"), it reads the raw hand pose (no Off Hand Modifier swap), and it
//            does not carry INSPECT's box reader. It has no tick in the hand and names nothing on screen (those were RSQ
//            Accessibility's).
@END@
@IF PAIR@
//   PAIR     both hands down, both thrown apart, both palms out, both palms thrust (RSQG_Handler.TwoHand, copied), sent
//            as the same network event, rsqg_pair (arg0 the kind, arg1 hundredths), so the receiver is unchanged.
@END@
// What Accessibility adds on top and this copy does not: the watch-check rumble tick, the names on screen, Measure Me
// (its cvars are read, so a body measured once still fits), Gesture Ease and the twist sliders' gap (both act on its
// sliders, which do not exist without it), the punch / shove / thrust answers, its menu.
//
// ONE READER. The mod asks RSQ Accessibility first (RSQG_Service, by name) and asks this copy only when it is absent.
// The copy also checks for itself (once a second) and stands down when Accessibility is there: it measures nothing and
// sends nothing. Nothing is measured unless someone asked in the last IDLE tics (as the reader does).
// NETPLAY: as the reader. The pose is the console player's local hardware; the answers are about the console player.
//
// THE HANDS: @HS@.Fix (tools/handsync), the frame's hand carried to the body this tic, as the reader does.
// Rig only, not headset-confirmed.

// RSQG_Pose, copied (pose.zs): where a hand is and how it is turned, in the player's own frame, in metres. Src() asks
// RSQ_Accessibility's Off-Hand Modifier by name as RSQG_A11y.Ctrl does (no RSQ_Accessibility: every hand its own controller).
class @P@_GPose
{
	const ARM_MAX = 96.0;

	static clearscope double UnitsPerMeter() { let c = CVar.FindCVar("vr_vunits_per_meter"); double u = c ? c.GetFloat() : 34.0; return u > 1.0 ? u : 34.0; }
	static clearscope double Stretch() { double ps = level.pixelstretch; return ps > 0.1 ? ps : 1.2; }
	static clearscope bool MainIsLeft() { let cs = CVar.FindCVar("vr_control_scheme"); return cs && cs.GetInt() >= 10; }
	static clearscope bool IsLeft(int hand) { return (hand == 0) == MainIsLeft(); }

	static clearscope int Src(PlayerPawn pmo, int hand)
	{
		if (hand != 1 || !pmo || !pmo.player) return hand;
		let oh = CVar.FindCVar("rsqa_onehand");
		if (!oh || oh.GetInt() == 0) return hand;
		let it = ServiceIterator.Find("RSQA_Service");
		let s = it.Next();
		return (s && s.GetIntData("swap", "", pmo.PlayerNumber()) == 1) ? 0 : hand;
	}

	static clearscope bool PoseGood(PlayerPawn pmo, int hand)
	{
		if (!pmo || !pmo.player || !pmo.OverrideAttackPosDir) return false;
		if (pmo.AttackPos == pmo.OffhandPos) return false;
		Vector3 h = HandPos(pmo, hand);
		if (h.x == 0 && h.y == 0 && h.z == 0) return false;
		Vector3 d = h - pmo.Pos;
		if (d.xy.Length() > ARM_MAX) return false;
		if (d.z < -ARM_MAX || d.z > pmo.Height + ARM_MAX) return false;
		return true;
	}
	static clearscope Vector3 HandPos(PlayerPawn pmo, int hand) { return Src(pmo, hand) == 0 ? pmo.AttackPos : pmo.OffhandPos; }
	// THE ENGINE'S FIXED EYE HEIGHT (owner 2026-11-11, design/rigtest_2026-11-10/RESULTS_DOWNSHOT.md). With
	// vr_crouch_use_button on, QuestZDoom 17.3 places the eyes and the hands at viewz + the headset's height - a height it
	// caches ONCE (hw_openxrdevice.cpp:158-170, getDoomPlayerHeightWithoutCrouch: the pawn's ViewHeight at its first
	// frame). RSQ SlowMo's DOWN scales the pawn's ViewHeight to 40% while you are down, so pmo.ViewHeight is not that number
	// then; the pawn class's default (pmo.Default) is, crouched or not. A crouch still reaches the eyes through viewz. Code only, not shown.
	static clearscope double StandEyeHeight(PlayerPawn pmo) { return pmo ? pmo.Default.ViewHeight : 41.0; }

	static clearscope Vector3 EyePos(PlayerPawn pmo)
	{
		let p = pmo.player;
		double u = UnitsPerMeter(), ps = Stretch();
		let adj = CVar.FindCVar("vr_height_adjust");
		double hmdH = (pmo.HmdPosition.y + (adj ? adj.GetFloat() : 0)) * u / ps;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		double h = (cb && cb.GetBool()) ? StandEyeHeight(pmo) : hmdH;
		return (pmo.Pos.x, pmo.Pos.y, p.viewz + hmdH - h);
	}
	static clearscope Vector3 Metric(Vector3 v) { return (v.x, v.y, v.z * Stretch()) / UnitsPerMeter(); }
	static clearscope Vector3 FromEyes(PlayerPawn pmo, int hand) { return Metric(HandPos(pmo, hand) - EyePos(pmo)); }
	static clearscope Vector3 Body(PlayerPawn pmo, int hand)
	{
		Vector3 d = FromEyes(pmo, hand);
		double c = cos(pmo.Angle), s = sin(pmo.Angle);
		return (d.x * c + d.y * s, -d.x * s + d.y * c, d.z);
	}
	static clearscope double Roll(PlayerPawn pmo, int hand)  { return Src(pmo, hand) == 0 ? pmo.AttackRoll : pmo.OffhandRoll; }
	static clearscope double Pitch(PlayerPawn pmo, int hand) { return Src(pmo, hand) == 0 ? pmo.AttackPitch : pmo.OffhandPitch; }
}

// RSQG_Handler, the parts named above, copied. STATIC (never in a save; started afresh on every level, as the reader's reset).
class @P@_GCopy : StaticEventHandler
{
	const IDLE = 35;
	const RING = 9;
	const SNAP = 8.0;
	const NEVER = -1000000.0;
	const SAME_PEAK = 30.0;
@IF PAIR@
	const PAIR_DOWN  = 0;
	const PAIR_APART = 1;
	const PAIR_PALMS = 2;
	const PAIR_THRUST = 3;
	const PAIR_KINDS = 4;
@END@

	int lastAsk, lastRun;
	double prevAngle;
	bool live[2];
	Vector3 prevRel[2];
	double rvx[18], rvy[18], rvz[18];
	int ringAt[2], ringN[2];
	bool swapWas;
	// RSQ Accessibility loaded (then this copy measures nothing): looked up once a second
	transient int gestLook;
	transient bool gestHere;
@IF INSPECT@
	int insState[2], insTics[2];
@END@
@IF LOOK@
	// per hand: the watch check and the pulse check, 0 not or 2 checked; tics the watch check has been met
	int insState[2], insTics[2], pulState[2];
@END@
@IF PAIR@
	int quietTill;
	transient Service svcGrapple, svcWheel;
	transient int svcLook;
	double downAt[2], downMps[2], apartAt[2], palmsAt[2], thrustAt[2], thrustMps[2], saidAt[PAIR_KINDS];
	int pairAsk;
	double palmsHeldFor;
	bool palmsSaid;
@END@

	static @P@_GCopy Get() { return @P@_GCopy(StaticEventHandler.Find("@P@_GCopy")); }
	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static double NowMs() { return gametic * 1000.0 / TICRATE; }
	static bool Dbg() { return Opt("@DBG@", 0) >= 1; }

	override void OnRegister() { ResetAll(); lastAsk = -1000; lastRun = -1; }
	override void WorldLoaded(WorldEvent e) { ResetAll(); lastAsk = -1000; lastRun = -1; }

	void ResetAll()
	{
		for (int h = 0; h < 2; h++)
		{
			live[h] = false; ringN[h] = 0; ringAt[h] = 0;
@IF INSPECT@
			insState[h] = 0; insTics[h] = 0;
@END@
@IF LOOK@
			insState[h] = 0; insTics[h] = 0; pulState[h] = 0;
@END@
@IF PAIR@
			downAt[h] = NEVER; downMps[h] = 0; apartAt[h] = NEVER; palmsAt[h] = NEVER; thrustAt[h] = NEVER; thrustMps[h] = 0;
@END@
		}
@IF PAIR@
		for (int k = 0; k < PAIR_KINDS; k++) saidAt[k] = NEVER;
		pairAsk = -1000;
		palmsHeldFor = 0; palmsSaid = false;
@END@
	}

	// RSQ Accessibility is loaded: its reader is the one reader, this copy stands down
	bool ReaderHere()
	{
		if (gestLook <= 0 || gametic >= gestLook)
		{
			let it = ServiceIterator.Find("RSQG_Service");
			gestHere = it.Next() != null;
			gestLook = gametic + TICRATE;
		}
		return gestHere;
	}

	PlayerPawn Me()
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return null;
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return null;
		return p.mo;
	}

@IF PAIR@
	// the reader's Two-Hand Events switch (rsqg_twohand) is read too: without Accessibility it does not exist, so the
	// events are read while a mod asked about them in the last second, as the reader does with its switch off
	bool TwoHandWanted() { return Opt("rsqg_twohand", 0) || gametic - pairAsk <= IDLE; }
	bool Running() { return gametic - lastAsk <= IDLE || TwoHandWanted(); }
@END@
@IF !PAIR@
	bool Running() { return gametic - lastAsk <= IDLE; }
@END@

	// body fit (Accessibility's Fit to My Body, rsqg_body*): 1 without RSQ Accessibility
	static double VScale() { if (!Opt("rsqg_body", 0)) return 1; double e = Num("rsqg_body_eye", 0); return e > 0.5 ? clamp(e / 1.60, 0.6, 1.4) : 1; }
	static double HScale() { if (!Opt("rsqg_body", 0)) return 1; double r = Num("rsqg_body_reach", 0); return r > 0.2 ? clamp(r / 0.70, 0.6, 1.4) : 1; }

	override void WorldTick()
	{
@IF !LOOK@
		if (!Running() || ReaderHere())
@END@
@IF LOOK@
		if (!Running())
@END@
		{
			if (lastRun >= 0) { ResetAll(); lastRun = -1; }
		}
		else Update();
	}

	void Update()
	{
		if (lastRun == gametic) return;
		lastRun = gametic;
		let pmo = Me();
		if (!pmo) { ResetAll(); return; }

		if (abs(Actor.DeltaAngle(prevAngle, pmo.Angle)) >= SNAP) { live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; }
		prevAngle = pmo.Angle;

		bool sw = @P@_GPose.Src(pmo, 1) == 0;
		if (sw != swapWas) { swapWas = sw; for (int k = 0; k < 2; k++) { live[k] = false; ringN[k] = 0; } }

@IF LOOK@
		// the wrist checks first, from the raw hand pose (no swap: a hand is its own controller)
		for (int h = 0; h < 2; h++) Look1(pmo, h);
@END@
		for (int h = 0; h < 2; h++)
		{
			if (!@P@_GPose.PoseGood(pmo, h) || (sw && h == 0))
			{
				live[h] = false; ringN[h] = 0;
@IF INSPECT@
				SetInspect(h, 0);
				insTics[h] = 0;
@END@
				continue;
			}
			Vector3 rel = @P@_GPose.Metric(@HS@.Fix(pmo, @P@_GPose.HandPos(pmo, h), @P@_GPose.Src(pmo, h)) - @P@_GPose.EyePos(pmo));
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
@IF INSPECT@
			if (InspectOff()) { SetInspect(h, 0); insTics[h] = 0; }
			else Inspect1(pmo, h);
@END@
		}
@IF PAIR@
		bool quiet = Quiet(pmo);
		if (TwoHandWanted()) TwoHand(pmo, quiet);
@END@
	}

	Vector3 VelAgo(int h, int ago)
	{
		int i = (ringAt[h] - ago + RING * 4) % RING;
		return (rvx[h * RING + i], rvy[h * RING + i], rvz[h * RING + i]);
	}
	double SpeedNow(int h)
	{
		int n = min(ringN[h], 3);
		if (n <= 0) return 0;
		Vector3 s = (0, 0, 0);
		for (int i = 0; i < n; i++) s += VelAgo(h, i);
		s /= n;
		return s.Length();
	}
	int PeakAgo(int h)
	{
		int best = -1; double bs = -1;
		for (int i = 0; i < ringN[h]; i++) { double s = VelAgo(h, i).Length(); if (s > bs) { bs = s; best = i; } }
		return best;
	}
	Vector3 PeakVel(int h) { int a = PeakAgo(h); return a < 0 ? (0, 0, 0) : VelAgo(h, a); }
	double PeakAgeMs(int h) { int a = PeakAgo(h); return a < 0 ? -1 : a * 1000.0 / TICRATE; }

	PlayerPawn Asked(int pn)
	{
		lastAsk = gametic;
@IF !LOOK@
		if (pn != consoleplayer || ReaderHere()) return null;
@END@
@IF LOOK@
		if (pn != consoleplayer) return null;
@END@
		Update();
		return Me();
	}

@IF INSPECT@
	// ---- INSPECT (RSQG_Handler.SetInspect / InspectPose / Inspect1, copied) ------------------------------------
	void SetInspect(int h, int s)
	{
		if (insState[h] == s) return;
		if (Dbg()) Console.Printf("@P@ watch check (own copy of RSQ Accessibility's watch check): %s hand %d -> %d (t%d)", h == 0 ? "main" : "off", insState[h], s, level.maptime);
		insState[h] = s;
	}
	static clearscope bool InspectOff() { return Opt("rsqg_inspect_off", 0) != 0; }

	static bool InspectPose(PlayerPawn pmo, int h, double slack, double need)
	{
		Vector3 b = @P@_GPose.Body(pmo, h);
		double hs = HScale(), vs = VScale();
		if (b.x < Num("rsqg_inspect_near", 0.15) * hs - slack || b.x > Num("rsqg_inspect_far", 0.65) * hs + slack) return false;
		if (b.z < -Num("rsqg_inspect_low", 0.30) * vs - slack || b.z > Num("rsqg_inspect_high", 0.20) * vs + slack) return false;
		if (abs(b.y) > Num("rsqg_inspect_side", 0.35) * hs + slack) return false;
		if (abs(Actor.Normalize180(@P@_GPose.Pitch(pmo, h))) > Num("rsqg_inspect_pitch", 60) + slack * 100) return false;
		double r = Actor.Normalize180(@P@_GPose.Roll(pmo, h));
		// the left controller reports the mirrored twist with the opposite sign (the reader's rig measurement): a one-way
		// choice is flipped for the physical left hand
		double s = @P@_GPose.IsLeft(h) ? -1 : 1;
		// rsqg_inspect_way: Accessibility's CVARINFO default is 2 (the back of the wrist; its code's own fallback, 0, is never
		// used while Accessibility is loaded), so without it this copy uses 2 too
		int dir = Opt("rsqg_inspect_way", 2);
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
			if (still && InspectPose(pmo, h, 0, Num("rsqg_inspect_twist", 35)))
			{
				insTics[h] = 1;
				SetInspect(h, Opt("rsqg_inspect_hold", 6) <= 1 ? 2 : 1);
			}
			else { insTics[h] = 0; SetInspect(h, 0); }
			return;
		}
		double slack = Num("rsqg_inspect_slack", 0.05);
		bool keep = InspectPose(pmo, h, slack, Num("rsqg_inspect_untwist", 20));
		if (!keep || (s == 1 && !still)) { insTics[h] = 0; SetInspect(h, 0); return; }
		insTics[h]++;
		if (s == 1 && insTics[h] >= Opt("rsqg_inspect_hold", 6)) SetInspect(h, 2);
	}

	// the reader's "inspect" answer: 0 not, 1 entering, 2 held; -1 switched off (rsqg_inspect_off) or Accessibility is loaded
	int Inspect(int pn, int h)     { if (InspectOff()) return -1; if (!Asked(pn)) return ReaderHere() ? -1 : 0; if (h < 0 || h > 1) return 0; return insState[h]; }
	int InspectTics(int pn, int h) { if (InspectOff()) return -1; if (!Asked(pn)) return ReaderHere() ? -1 : 0; if (h < 0 || h > 1) return 0; return insTics[h]; }
@END@

@IF LOOK@
	// ---- THE WRIST CHECK: "LOOK AT IT, IT SHOWS" (2026-11-27) ---------------------------------------------------
	// Owner 2026-11-27: "both watch cards and the pulse start fight card are WILDILY unreliable in when and how they
	// showup, and it makes me LIVID." "i want them to be fuckin reliable." Asked how the wrist cards should show, he
	// chose "Look at it, it shows": no box, no stillness, no hold. So the box in front of the eyes, the pitch limit, the
	// twist of the roll number alone, the stillness test, the hold time, the slack and every ease on them are gone.
	// ONE RULE for both checks. A side of a wrist is checked while
	//   (a) FACE: that side's face is turned toward your eyes: the angle between the face's normal and the line from the
	//       wrist to your eyes (0 square on, 90 edge on, over 90 turned away) is under the limit. The normal comes from
	//       the hand's whole orientation, angle, pitch and roll together; where the hand is does not enter.
	//   (b) GAZE: you are looking toward that wrist: the angle between where your head points and the line from your
	//       eyes to the wrist is under the limit.
	// The back of the wrist is the watch check ("inspect"), the inside is the pulse check ("pulse"). Each limit has a
	// looser value to KEEP a check than to START one, so it does not flicker at the edge.
	//
	// THE ANGLES, AND WHY (the lesson of Gun Cards' note of 2026-11-12 14:11, card.zs: "a real check tilts the wrist only
	// 45-80 degrees, which measures under FACE_MIN", 60 degrees off square, "so the test hid every checked card"):
	//   the back of the wrist   starts under FACE_BACK_ON 80, kept under FACE_BACK_KEEP 88. With the forearm across the
	//       chest 30 cm under the eyes, a wrist tilted 60 degrees has its back 61-82 degrees off square to the eyes and
	//       one tilted 80 degrees 42-63 (worked out for this rule, tools/gestcopy): 60 hid them, 80 takes them, and
	//       past 88 the card is edge on (a line of dashes) anyway. A gun held out to aim has the back of that hand 86-126
	//       degrees off square: turned away, so aiming does not start it.
	//   the inside of the wrist starts under FACE_IN_ON 60, kept under FACE_IN_KEEP 75. Turning the palm up to the face
	//       is the forearm's easy way round: a pulse check measures 5-50 degrees off square. It is NOT 80 like the back
	//       because the inside of a hand held out to aim already half faces you (54-90 degrees off square, most often
	//       65-85): at 80 an off-hand gun aimed while you look down it would be a pulse check.
	//   the gaze                starts under GAZE_ON 50, kept under GAZE_KEEP 65. The headset cannot see where the eyes
	//       point, only the head; 50 degrees is about the edge of the headset's picture, so a wrist you can see with a
	//       glance of the eyes alone counts, and one at your hip or your side does not.
	// The left hand is the right hand's mirror image: the back of the right hand is the controller's right side, the
	// back of the left hand its left side. (Gun Cards' FaceDot and RSQ Boss's InnerDot had the left hand's sideways
	// part with the wrong sign until this day; they agreed with this only at a full 90 degree turn.)
	// Code only: not compiled, not run, not headset-confirmed.
	const SIDE_IN = 1;            // the inside of the wrist (the pulse side)
	const SIDE_BACK = 2;          // the back of the wrist (the watch side)
	const FACE_BACK_ON = 80.0;
	const FACE_BACK_KEEP = 88.0;
	const FACE_IN_ON = 60.0;
	const FACE_IN_KEEP = 75.0;
	const GAZE_ON = 50.0;
	const GAZE_KEEP = 65.0;

	// the raw hand (0 main, 1 off): each hand its own controller
	static Vector3 RawPos(PlayerPawn pmo, int h) { return h == 0 ? pmo.AttackPos : pmo.OffhandPos; }
	static bool RawGood(PlayerPawn pmo, int h)
	{
		if (!pmo || !pmo.player || !pmo.OverrideAttackPosDir) return false;
		if (pmo.AttackPos == pmo.OffhandPos) return false;   // the engine's collapsed pose (a menu just closed)
		Vector3 hp = RawPos(pmo, h);
		if (hp.x == 0 && hp.y == 0 && hp.z == 0) return false;
		Vector3 d = hp - pmo.Pos;
		if (d.xy.Length() > @P@_GPose.ARM_MAX) return false;
		if (d.z < -@P@_GPose.ARM_MAX || d.z > pmo.Height + @P@_GPose.ARM_MAX) return false;
		return true;
	}
	// from the eyes to that wrist, in true proportions (the map is squashed by pixelstretch up and down); the frame's
	// hand carried to where the body is this tic (@HS@), so a tic with no frame does not swing the line
	static Vector3 ToWrist(PlayerPawn pmo, int h)
	{
		Vector3 to = @HS@.Fix(pmo, RawPos(pmo, h), h) - @HS@.Body(pmo);
		to.z *= @P@_GPose.Stretch();
		return to;
	}
	// FACE: degrees between that side's face and the line from the wrist to your eyes (0 square on, 90 edge on)
	static double FaceOff(PlayerPawn pmo, int h, int side)
	{
		if (!RawGood(pmo, h)) return 180;
		double y = (h == 0 ? pmo.AttackAngle : pmo.OffhandAngle) + 90;   // the engine stores the hand's yaw minus 90
		double p = h == 0 ? pmo.AttackPitch : pmo.OffhandPitch;          // up is positive
		double r = Actor.Normalize180(h == 0 ? pmo.AttackRoll : pmo.OffhandRoll);   // + = the controller's top to its right
		Vector3 f = (cos(p) * cos(y), cos(p) * sin(y), sin(p));          // where the hand points
		Vector3 r0 = (sin(y), -cos(y), 0);                               // its right side before the roll
		Vector3 u0 = r0 cross f;                                         // its top before the roll
		Vector3 n = r0 * cos(r) - u0 * sin(r);                           // the controller's right side: the back of a right hand
		if (@P@_GPose.IsLeft(h)) n = -n;                                 // the back of a left hand is its left side
		if (side == SIDE_IN) n = -n;
		Vector3 to = -ToWrist(pmo, h);
		double d = to.Length();
		if (d < 0.01) return 180;
		return acos(clamp((n dot to) / d, -1.0, 1.0));
	}
	// GAZE: degrees between where your head points and the line from your eyes to that wrist
	static double GazeOff(PlayerPawn pmo, int h)
	{
		if (!RawGood(pmo, h)) return 180;
		Vector3 to = ToWrist(pmo, h);
		double d = to.Length();
		if (d < 0.01) return 180;
		Vector3 look = (cos(pmo.Angle) * cos(pmo.Pitch), sin(pmo.Angle) * cos(pmo.Pitch), -sin(pmo.Pitch));
		return acos(clamp((to / d) dot look, -1.0, 1.0));
	}
	static double FaceMax(int side, bool held)
	{
		if (side == SIDE_IN) return held ? FACE_IN_KEEP : FACE_IN_ON;
		return held ? FACE_BACK_KEEP : FACE_BACK_ON;
	}
	// THE RULE: that side of that wrist is checked (held: it was checked last tic, so the looser angles keep it)
	static bool Checked(PlayerPawn pmo, int h, int side, bool held)
	{
		if (!RawGood(pmo, h)) return false;
		return FaceOff(pmo, h, side) < FaceMax(side, held) && GazeOff(pmo, h) < (held ? GAZE_KEEP : GAZE_ON);
	}
	// WHICH SIDE IS THE WATCH: RSQ Accessibility's Wrist Turn (rsqg_inspect_way, read by name while that mod is still
	// loaded; without it 2): 2 the back of the wrist, 1 the pulse side, 0 either way. The pulse check is the other side.
	// With Either Way the watch takes both sides and the pulse check answers -1 (it has no side left).
	static int Way() { return Opt("rsqg_inspect_way", 2); }
	static bool WatchRule(PlayerPawn pmo, int h, bool held)
	{
		int w = Way();
		if (w == 1) return Checked(pmo, h, SIDE_IN, held);
		if (w == 2) return Checked(pmo, h, SIDE_BACK, held);
		return Checked(pmo, h, SIDE_BACK, held) || Checked(pmo, h, SIDE_IN, held);
	}
	static bool PulseRule(PlayerPawn pmo, int h, bool held)
	{
		int w = Way();
		if (w == 0) return false;
		return Checked(pmo, h, w == 1 ? SIDE_BACK : SIDE_IN, held);
	}

	void Look1(PlayerPawn pmo, int h)
	{
		int was = insState[h];
		int s = WatchRule(pmo, h, was == 2) ? 2 : 0;
		insTics[h] = s == 2 ? insTics[h] + 1 : 0;
		insState[h] = s;
		if (s != was && Dbg()) Console.Printf("@P@ watch check: %s hand %d -> %d, %s (t%d)", h == 0 ? "main" : "off", was, s, Why(pmo, h, false), level.maptime);
		was = pulState[h];
		s = PulseRule(pmo, h, was == 2) ? 2 : 0;
		pulState[h] = s;
		if (s != was && Dbg()) Console.Printf("@P@ pulse check: %s hand %d -> %d, %s (t%d)", h == 0 ? "main" : "off", was, s, Why(pmo, h, true), level.maptime);
	}

	// WHY A CHECK IS NOT MET ("pose.why"): which of the two tests fails, with its numbers, or "met"; then both numbers
	// and the limits in use (the looser ones while it is checked). Read only.
	String Why(PlayerPawn pmo, int h, bool pulse)
	{
		if (h < 0 || h > 1) return "";
		if (!RawGood(pmo, h)) return "no hand pose";
		int w = Way();
		if (pulse && w == 0) return "no pulse check: Wrist Turn is Either Way, the watch check has both sides";
		int side = pulse ? (w == 1 ? SIDE_BACK : SIDE_IN) : (w == 1 ? SIDE_IN : SIDE_BACK);
		bool held = (pulse ? pulState[h] : insState[h]) == 2;
		double fo = FaceOff(pmo, h, side);
		// Either Way: the watch check goes by whichever side is turned nearer to your eyes
		if (!pulse && w == 0 && FaceOff(pmo, h, SIDE_IN) < fo) { side = SIDE_IN; fo = FaceOff(pmo, h, SIDE_IN); }
		double go = GazeOff(pmo, h);
		double fm = FaceMax(side, held), gm = held ? GAZE_KEEP : GAZE_ON;
		String sn = side == SIDE_IN ? "the inside of the wrist" : "the back of the wrist";
		String why = "met";
		if (fo >= fm && go >= gm) why = String.Format("%s is not turned to your eyes (face %.0f >= %.0f) and you are not looking at it (gaze %.0f >= %.0f)", sn, fo, fm, go, gm);
		else if (fo >= fm) why = String.Format("%s is not turned to your eyes (face %.0f >= %.0f)", sn, fo, fm);
		else if (go >= gm) why = String.Format("you are not looking at it (gaze %.0f >= %.0f)", go, gm);
		return String.Format("%s; %s face %.0f of %.0f, gaze %.0f of %.0f degrees%s", why, sn, fo, fm, go, gm, held ? " (checked: the looser limits)" : "");
	}

	// the answers: "inspect" the watch check, "pulse" the pulse check: 0 not, 2 checked (never 1: there is no hold).
	// "pulse" is -1 only with Wrist Turn on Either Way.
	int Inspect(int pn, int h)     { if (!Asked(pn) || h < 0 || h > 1) return 0; return insState[h]; }
	int InspectTics(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1) return 0; return insTics[h]; }
	int Pulse(int pn, int h)       { if (Way() == 0) return -1; if (!Asked(pn) || h < 0 || h > 1) return 0; return pulState[h]; }
@END@
@IF PAIR@
	// ---- QUIET (the reader's GE1, copied): on RSQ Grapple's rope or with RSQ Wheel open, no two-hand events -------------
	static Service FindSvc(String n) { let it = ServiceIterator.Find(n); return it.Next(); }
	bool Quiet(PlayerPawn pmo)
	{
		if (gametic >= svcLook)
		{
			if (!svcGrapple) svcGrapple = FindSvc("RSQGR_Service");
			if (!svcWheel) svcWheel = FindSvc("wr_RigService");
			svcLook = gametic + TICRATE;
		}
		bool why = (svcGrapple && (svcGrapple.GetInt("climbing", "", 0, 0, pmo) == 1 || svcGrapple.GetInt("swinging", "", 0, 0, pmo) == 1
			|| svcGrapple.GetInt("reeling", "", 0, 0, pmo) == 1)) || (svcWheel && svcWheel.GetInt("IsOpen", "", 0, 0, pmo) == 1);
		if (why) quietTill = gametic + RING;
		return gametic < quietTill;
	}

	// ---- BOTH HANDS (RSQG_Handler.PeakTimeMs / PalmOut / TwoHand / Together / Announce, copied) --------------------
	static clearscope bool IsBraced(PlayerInfo p) { return p && (p.WeaponState & WF_TWOHANDSTABILIZED) != 0; }
	double PeakTimeMs(int h, double maxAgeMs)
	{
		double age = PeakAgeMs(h);
		if (age < 0) return NEVER;
		if (maxAgeMs > 0 && age > maxAgeMs) return NEVER;
		return NowMs() - age;
	}
	bool PalmOut(PlayerPawn pmo, int h, double frontM, double hipM, double stillMps)
	{
		if (!live[h] || ringN[h] <= 0) return false;
		if (pmo.player.cmd.buttons & (BT_ATTACK | BT_ALTATTACK)) return false;
		if (PeakVel(h).Length() >= stillMps) return false;
		if (Actor.Normalize180(@P@_GPose.Pitch(pmo, h)) < Num("rsqg_two_palms_pitch", 40)) return false;
		Vector3 b = @P@_GPose.Body(pmo, h);
		return b.x >= frontM && b.z >= -hipM;
	}

	void TwoHand(PlayerPawn pmo, bool quiet)
	{
		if (quiet || !live[0] || !live[1]) { for (int h = 0; h < 2; h++) { downAt[h] = NEVER; apartAt[h] = NEVER; palmsAt[h] = NEVER; thrustAt[h] = NEVER; } palmsHeldFor = 0; palmsSaid = false; return; }
		double now = NowMs();
		// RSQ_Accessibility's Slower Taps (rsqa_slow_taps, read by name): x1.5, as RSQG_A11y.TapScale
		double windowMs = max(Num("rsqg_two_window_ms", 120), 0) * (Opt("rsqa_slow_taps", 0) ? 1.5 : 1.0);
		double ageMs = Num("rsqg_two_age", 180);
		double repeatMs = max(Num("rsqg_two_repeat_ms", 500), 0);
		double needDown = Num("rsqg_two_down_mps", 2.0);
		double downFrac = clamp(Num("rsqg_two_down_frac", 0.5), 0, 1);
		double hs = HScale(), vs = VScale();
		double hipM = Num("rsqg_two_hip_m", 0.60) * vs;
		double needApart = Num("rsqg_two_apart_mps", 2.0);
		double chestM = Num("rsqg_two_chest_m", 0.40) * vs, chestR = Num("rsqg_two_chest_r", 0.50) * hs;
		double frontM = Num("rsqg_two_front_m", 0.25) * hs;
		bool doDown = Opt("rsqg_two_down", 1) != 0, doApart = Opt("rsqg_two_apart", 1) != 0, doPalms = Opt("rsqg_two_palms", 1) != 0;
		bool doThrust = Opt("rsqg_two_thrust", 1) != 0 && !IsBraced(pmo.player);
		double needThrust = Num("rsqg_two_thrust_mps", 2.5);
		double thrustFrac = clamp(Num("rsqg_two_thrust_frac", 0.6), 0, 1);
		double thrustPitch = Num("rsqg_two_thrust_pitch", 20);
		double fc = cos(pmo.Angle), fs = sin(pmo.Angle);
		double holdMs = max(Num("rsqg_two_hold_ms", 400), 0);
		double stillMps = Num("rsqg_still_mps", 0.3);

		for (int h = 0; h < 2; h++)
		{
			double peakAt = PeakTimeMs(h, ageMs);
			Vector3 vel = PeakVel(h);
			Vector3 rel = @P@_GPose.FromEyes(pmo, h);
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

			double fwd = vel.x * fc + vel.y * fs;
			if (doThrust && peakAt > NEVER && peakAt > saidAt[PAIR_THRUST] + SAME_PEAK && fwd >= needThrust && speed > 0.0001
				&& fwd / speed >= thrustFrac && rel.z >= -hipM && Actor.Normalize180(@P@_GPose.Pitch(pmo, h)) >= thrustPitch)
			{
				thrustAt[h] = peakAt;
				thrustMps[h] = fwd;
			}
		}

		double capMs = ageMs > 0 ? ageMs : RING * 1000.0 / TICRATE;
		double liveMs = capMs + windowMs;

		if (doDown && Together(downAt[0], downAt[1], windowMs, now, liveMs))
		{
			if (Announce(PAIR_DOWN, min(downMps[0], downMps[1]), now, repeatMs)) { downAt[0] = NEVER; downAt[1] = NEVER; }
		}
		if (doApart && Together(apartAt[0], apartAt[1], windowMs, now, liveMs))
		{
			Vector3 sep = @P@_GPose.FromEyes(pmo, 0) - @P@_GPose.FromEyes(pmo, 1);
			double rate = 0;
			if (sep.Length() > 0.0001) { Vector3 closing = PeakVel(0) - PeakVel(1); rate = closing dot sep.Unit(); }
			if (rate >= needApart && Announce(PAIR_APART, rate, now, repeatMs)) { apartAt[0] = NEVER; apartAt[1] = NEVER; }
		}

		Vector3 b0 = @P@_GPose.Body(pmo, 0), b1 = @P@_GPose.Body(pmo, 1);
		bool apartEnough = abs(b0.y - b1.y) >= Num("rsqg_two_palms_gap", 0.25) * hs;
		if (doThrust && apartEnough && Together(thrustAt[0], thrustAt[1], windowMs, now, liveMs))
		{
			if (Announce(PAIR_THRUST, min(thrustMps[0], thrustMps[1]), now, repeatMs)) { thrustAt[0] = NEVER; thrustAt[1] = NEVER; }
		}
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
		if (which < 0 || which >= PAIR_KINDS) return false;
		if (repeatMs > 0 && now - saidAt[which] < repeatMs) return false;
		if (ReaderHere()) return false;   // never a second rsqg_pair beside RSQ Accessibility's own
		EventHandler.SendNetworkEvent("rsqg_pair", which, int(round(mag * 100)), 0);
		saidAt[which] = now;
		if (Dbg())
		{
			static const String pairName[] = { "both hands down", "both hands apart", "both palms out", "both palms thrust" };
			Console.Printf("@P@ pair (own copy of RSQ Accessibility's two-hand reader): %s, %.2f (t%d)", pairName[which], mag, level.maptime);
		}
		return true;
	}

	// the reader's "pair.ago": ms since that two-hand gesture fired, -1 never; asking keeps the two-hand events read a second
	double PairAgoMs(int pn, int k) { pairAsk = gametic; if (!Asked(pn) || k < 0 || k >= PAIR_KINDS || saidAt[k] <= NEVER) return -1; return NowMs() - saidAt[k]; }
@END@
}

// @P@_GCopyService -- ask by name, as RSQG_Service is asked (no compile dependency). The same requests and answers as
// RSQ Accessibility's RSQG_Service for what is copied; objectArg the asking PlayerPawn (anyone but the console player
// gets 0). -1 unknown, or RSQ Accessibility is loaded (ask its RSQG_Service instead).
//   "reader"     1: this copy is here (whether or not it stands down for RSQ Accessibility)
@IF INSPECT@
//   "inspect"    0 not, 1 entering, 2 held, intArg the hand (0 main, 1 off)     "inspect.tics"  tics since the pose was met
//   "inspect.any" the higher of the two hands
@END@
@IF LOOK@
// A LOOK copy answers whether or not RSQ Accessibility is loaded (it never stands down):
//   "inspect"    the watch check: 0 not, 2 checked, intArg the hand (0 main, 1 off)   "inspect.tics"  tics it has been met
//   "inspect.any" the higher of the two hands
//   "pulse"      the pulse check: 0 not, 2 checked; -1 only with Wrist Turn (rsqg_inspect_way) on Either Way
//   "pose.why"   (GetString) stringArg "watch" or "pulse", intArg the hand, objectArg the console player's pawn: why that
//                check is not met (which of the two tests fails, with its numbers), or "met"
@END@
@IF PAIR@
//   "pair.reader" 1: this mod reads both hands itself without RSQ Accessibility (both hands down / apart / palms / palms thrust)
//   "pair.ago"   ms since that two-hand gesture (intArg the kind) fired, -1 never; asking keeps the reader awake
@END@
class @P@_GCopyService : Service
{
	static int Pn(Object o) { let pmo = PlayerPawn(o); return (pmo && pmo.player) ? pmo.PlayerNumber() : consoleplayer; }

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "reader") return 1;
@IF PAIR@
		if (request ~== "pair.reader") return 1;
@END@
		let h = @P@_GCopy.Get();
@IF !LOOK@
		if (!h || h.ReaderHere()) return -1;
@END@
@IF LOOK@
		if (!h) return -1;
@END@
		int pn = Pn(objectArg);
@IF LOOK@
		if (request ~== "inspect")      return h.Inspect(pn, intArg);
		if (request ~== "pulse")        return h.Pulse(pn, intArg);
		if (request ~== "inspect.tics") return h.InspectTics(pn, intArg);
		if (request ~== "inspect.any")  return max(h.Inspect(pn, 0), h.Inspect(pn, 1));
@END@
@IF INSPECT@
		if (request ~== "inspect")      return h.Inspect(pn, intArg);
		if (request ~== "inspect.tics") return h.InspectTics(pn, intArg);
		if (request ~== "inspect.any")  { int a = h.Inspect(pn, 0); return a < 0 ? a : max(a, h.Inspect(pn, 1)); }
@END@
@IF PAIR@
		if (request ~== "pair.ago")     return int(h.PairAgoMs(pn, intArg));
@END@
		return -1;
	}
@IF LOOK@

	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request ~== "pose.why")) return "";
		let h = @P@_GCopy.Get();
		let pmo = PlayerPawn(objectArg);
		if (!h || !pmo || !pmo.player || pmo.PlayerNumber() != consoleplayer) return "";
		return h.Why(pmo, intArg, stringArg ~== "pulse");
	}
@END@
}
