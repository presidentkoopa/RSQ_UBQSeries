// RSQTR_GCopy -- RSQ Tactical Rig's OWN COPY of RSQ Accessibility's gesture reader, used ONLY when RSQ Accessibility is not loaded
// (tools/gestcopy/gestcopy_template.zs, written by tools/gestcopy/gen_gestcopy.py; GENERATED, do not edit here).
// Owner 2026-11-04 19:45: "I worry that anyone who uses Gun Cards won't have the standout feature of the watch check card
// because they didn't have Gestures." So each mod whose standout rides on a gesture carries the detector itself. (The
// reader was RSQ Gestures until it was folded into RSQ Accessibility, 11-05, keeping its class and cvar names.)
//
// WHAT IT IS. A copy of the reader (Accessibility/zscript/rsqg/gestures.zs RSQG_Handler, pose.zs RSQG_Pose), not a
// rewrite: the same pose rules, the same numbers, the same cvar names (rsqg_*: without RSQ Accessibility those cvars do
// not exist, so every number here is the default its CVARINFO gives; gen_gestcopy.py checks that on every run), the left
// hand mirrored the same way.
//   INSPECT  the watch check, one hand: in front of the eyes at chest-to-face height, wrist turned rsqg_inspect_twist
//            degrees, still, held rsqg_inspect_hold tics (RSQG_Handler.InspectPose / Inspect1, copied).
// What Accessibility adds on top and this copy does not: the watch-check rumble tick, the names on screen, Measure Me
// (its cvars are read, so a body measured once still fits), Gesture Ease and the twist sliders' gap (both act on its
// sliders, which do not exist without it), the punch / shove / thrust answers, its menu.
//
// ONE READER. The mod asks RSQ Accessibility first (RSQG_Service, by name) and asks this copy only when it is absent.
// The copy also checks for itself (once a second) and stands down when Accessibility is there: it measures nothing and
// sends nothing. Nothing is measured unless someone asked in the last IDLE tics (as the reader does).
// NETPLAY: as the reader. The pose is the console player's local hardware; the answers are about the console player.
//
// THE HANDS: RSQTR_HandSync.Fix (tools/handsync), the frame's hand carried to the body this tic, as the reader does.
// Rig only, not headset-confirmed.

// RSQG_Pose, copied (pose.zs): where a hand is and how it is turned, in the player's own frame, in metres. Src() asks
// RSQ_Accessibility's Off-Hand Modifier by name as RSQG_A11y.Ctrl does (no RSQ_Accessibility: every hand its own controller).
class RSQTR_GPose
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
class RSQTR_GCopy : StaticEventHandler
{
	const IDLE = 35;
	const RING = 9;
	const SNAP = 8.0;
	const NEVER = -1000000.0;
	const SAME_PEAK = 30.0;

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
	int insState[2], insTics[2];

	static RSQTR_GCopy Get() { return RSQTR_GCopy(StaticEventHandler.Find("RSQTR_GCopy")); }
	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static double NowMs() { return gametic * 1000.0 / TICRATE; }
	static bool Dbg() { return Opt("rsqtr_messages", 0) >= 1; }

	override void OnRegister() { ResetAll(); lastAsk = -1000; lastRun = -1; }
	override void WorldLoaded(WorldEvent e) { ResetAll(); lastAsk = -1000; lastRun = -1; }

	void ResetAll()
	{
		for (int h = 0; h < 2; h++)
		{
			live[h] = false; ringN[h] = 0; ringAt[h] = 0;
			insState[h] = 0; insTics[h] = 0;
		}
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

	bool Running() { return gametic - lastAsk <= IDLE; }

	// body fit (Accessibility's Fit to My Body, rsqg_body*): 1 without RSQ Accessibility
	static double VScale() { if (!Opt("rsqg_body", 0)) return 1; double e = Num("rsqg_body_eye", 0); return e > 0.5 ? clamp(e / 1.60, 0.6, 1.4) : 1; }
	static double HScale() { if (!Opt("rsqg_body", 0)) return 1; double r = Num("rsqg_body_reach", 0); return r > 0.2 ? clamp(r / 0.70, 0.6, 1.4) : 1; }

	override void WorldTick()
	{
		if (!Running() || ReaderHere())
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

		bool sw = RSQTR_GPose.Src(pmo, 1) == 0;
		if (sw != swapWas) { swapWas = sw; for (int k = 0; k < 2; k++) { live[k] = false; ringN[k] = 0; } }

		for (int h = 0; h < 2; h++)
		{
			if (!RSQTR_GPose.PoseGood(pmo, h) || (sw && h == 0))
			{
				live[h] = false; ringN[h] = 0;
				SetInspect(h, 0);
				insTics[h] = 0;
				continue;
			}
			Vector3 rel = RSQTR_GPose.Metric(RSQTR_HandSync.Fix(pmo, RSQTR_GPose.HandPos(pmo, h), RSQTR_GPose.Src(pmo, h)) - RSQTR_GPose.EyePos(pmo));
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
			if (InspectOff()) { SetInspect(h, 0); insTics[h] = 0; }
			else Inspect1(pmo, h);
		}
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
		if (pn != consoleplayer || ReaderHere()) return null;
		Update();
		return Me();
	}

	// ---- INSPECT (RSQG_Handler.SetInspect / InspectPose / Inspect1, copied) ------------------------------------
	void SetInspect(int h, int s)
	{
		if (insState[h] == s) return;
		if (Dbg()) Console.Printf("RSQTR watch check (own copy of RSQ Accessibility's watch check): %s hand %d -> %d (t%d)", h == 0 ? "main" : "off", insState[h], s, level.maptime);
		insState[h] = s;
	}
	static clearscope bool InspectOff() { return Opt("rsqg_inspect_off", 0) != 0; }

	static bool InspectPose(PlayerPawn pmo, int h, double slack, double need)
	{
		Vector3 b = RSQTR_GPose.Body(pmo, h);
		double hs = HScale(), vs = VScale();
		if (b.x < Num("rsqg_inspect_near", 0.15) * hs - slack || b.x > Num("rsqg_inspect_far", 0.65) * hs + slack) return false;
		if (b.z < -Num("rsqg_inspect_low", 0.30) * vs - slack || b.z > Num("rsqg_inspect_high", 0.20) * vs + slack) return false;
		if (abs(b.y) > Num("rsqg_inspect_side", 0.35) * hs + slack) return false;
		if (abs(Actor.Normalize180(RSQTR_GPose.Pitch(pmo, h))) > Num("rsqg_inspect_pitch", 60) + slack * 100) return false;
		double r = Actor.Normalize180(RSQTR_GPose.Roll(pmo, h));
		// the left controller reports the mirrored twist with the opposite sign (the reader's rig measurement): a one-way
		// choice is flipped for the physical left hand
		double s = RSQTR_GPose.IsLeft(h) ? -1 : 1;
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

}

// RSQTR_GCopyService -- ask by name, as RSQG_Service is asked (no compile dependency). The same requests and answers as
// RSQ Accessibility's RSQG_Service for what is copied; objectArg the asking PlayerPawn (anyone but the console player
// gets 0). -1 unknown, or RSQ Accessibility is loaded (ask its RSQG_Service instead).
//   "reader"     1: this copy is here (whether or not it stands down for RSQ Accessibility)
//   "inspect"    0 not, 1 entering, 2 held, intArg the hand (0 main, 1 off)     "inspect.tics"  tics since the pose was met
//   "inspect.any" the higher of the two hands
class RSQTR_GCopyService : Service
{
	static int Pn(Object o) { let pmo = PlayerPawn(o); return (pmo && pmo.player) ? pmo.PlayerNumber() : consoleplayer; }

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "reader") return 1;
		let h = RSQTR_GCopy.Get();
		if (!h || h.ReaderHere()) return -1;
		int pn = Pn(objectArg);
		if (request ~== "inspect")      return h.Inspect(pn, intArg);
		if (request ~== "inspect.tics") return h.InspectTics(pn, intArg);
		if (request ~== "inspect.any")  { int a = h.Inspect(pn, 0); return a < 0 ? a : max(a, h.Inspect(pn, 1)); }
		return -1;
	}
}
