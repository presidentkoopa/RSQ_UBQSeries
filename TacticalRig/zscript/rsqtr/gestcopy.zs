// RSQTR_GCopy -- RSQ Tactical Rig's OWN gesture reader (tools/gestcopy/gestcopy_template.zs, written by tools/gestcopy/gen_gestcopy.py;
// GENERATED, do not edit here). Owner 2026-11-04 19:45: "I worry that anyone who uses Gun Cards won't have the standout
// feature of the watch check card because they didn't have Gestures." So each mod whose standout rides on a gesture
// carries the detector itself. (It began as a copy of RSQ Gestures' reader, later RSQ Accessibility's; Accessibility was
// removed 2026-11-27, owner: "remove the whole mod", so this copy is the only reader and asks no other mod.)
//
// WHAT IT IS. The reader's pose rules and numbers, each number the default the old reader's settings gave (those
// settings are gone with Accessibility), the left hand mirrored the same way.
//   INSPECT  the watch check, one hand: in front of the eyes at chest-to-face height, wrist turned INS_TWIST degrees,
//            still, held INS_HOLD tics.
// Nothing is measured unless someone asked in the last IDLE tics.
// NETPLAY: the pose is the console player's local hardware; the answers are about the console player.
//
// THE HANDS: RSQTR_HandSync.Fix (tools/handsync), the frame's hand carried to the body this tic.
// Rig only, not headset-confirmed.

// where a hand is and how it is turned, in the player's own frame, in metres; every hand its own controller
class RSQTR_GPose
{
	const ARM_MAX = 96.0;

	static clearscope double UnitsPerMeter() { let c = CVar.FindCVar("vr_vunits_per_meter"); double u = c ? c.GetFloat() : 34.0; return u > 1.0 ? u : 34.0; }
	static clearscope double Stretch() { double ps = level.pixelstretch; return ps > 0.1 ? ps : 1.2; }
	static clearscope bool MainIsLeft() { let cs = CVar.FindCVar("vr_control_scheme"); return cs && cs.GetInt() >= 10; }
	static clearscope bool IsLeft(int hand) { return (hand == 0) == MainIsLeft(); }

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
	static clearscope Vector3 HandPos(PlayerPawn pmo, int hand) { return hand == 0 ? pmo.AttackPos : pmo.OffhandPos; }
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
	static clearscope double Roll(PlayerPawn pmo, int hand)  { return hand == 0 ? pmo.AttackRoll : pmo.OffhandRoll; }
	static clearscope double Pitch(PlayerPawn pmo, int hand) { return hand == 0 ? pmo.AttackPitch : pmo.OffhandPitch; }
}

// the reader, the parts named above. STATIC (never in a save; started afresh on every level).
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
	int insState[2], insTics[2];

	static RSQTR_GCopy Get() { return RSQTR_GCopy(StaticEventHandler.Find("RSQTR_GCopy")); }
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

	PlayerPawn Me()
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return null;
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return null;
		return p.mo;
	}

	bool Running() { return gametic - lastAsk <= IDLE; }

	override void WorldTick()
	{
		if (!Running())
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

		for (int h = 0; h < 2; h++)
		{
			if (!RSQTR_GPose.PoseGood(pmo, h))
			{
				live[h] = false; ringN[h] = 0;
				SetInspect(h, 0);
				insTics[h] = 0;
				continue;
			}
			Vector3 rel = RSQTR_GPose.Metric(RSQTR_HandSync.Fix(pmo, RSQTR_GPose.HandPos(pmo, h), h) - RSQTR_GPose.EyePos(pmo));
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
		if (pn != consoleplayer) return null;
		Update();
		return Me();
	}

	// ---- INSPECT: the watch check, the old reader's box rule and numbers ---------------------------------------------
	// the box in front of the eyes, metres (forward near / far, down, up, to the side), the pitch limit in degrees
	const INS_NEAR = 0.15;
	const INS_FAR = 0.65;
	const INS_LOW = 0.30;
	const INS_HIGH = 0.20;
	const INS_SIDE = 0.35;
	const INS_PITCH = 60.0;
	const INS_TWIST = 35.0;       // degrees the back of the wrist turns to start the check
	const INS_UNTWIST = 20.0;     // degrees it may come back and keep it
	const INS_STILL = 1.2;        // m/s: slower than this is still
	const INS_HOLD = 6;           // tics held to go from entering to held
	const INS_SLACK = 0.05;       // metres the box grows while the check is kept
	void SetInspect(int h, int s)
	{
		if (insState[h] == s) return;
		if (Dbg()) Console.Printf("RSQTR watch check: %s hand %d -> %d (t%d)", h == 0 ? "main" : "off", insState[h], s, level.maptime);
		insState[h] = s;
	}

	static bool InspectPose(PlayerPawn pmo, int h, double slack, double need)
	{
		Vector3 b = RSQTR_GPose.Body(pmo, h);
		if (b.x < INS_NEAR - slack || b.x > INS_FAR + slack) return false;
		if (b.z < -INS_LOW - slack || b.z > INS_HIGH + slack) return false;
		if (abs(b.y) > INS_SIDE + slack) return false;
		if (abs(Actor.Normalize180(RSQTR_GPose.Pitch(pmo, h))) > INS_PITCH + slack * 100) return false;
		double r = Actor.Normalize180(RSQTR_GPose.Roll(pmo, h));
		// the back of the wrist toward the eyes; the left controller reports the mirrored twist with the opposite sign (the
		// reader's rig measurement), so the sign is flipped for the physical left hand
		double s = RSQTR_GPose.IsLeft(h) ? -1 : 1;
		return -r * s >= need;
	}

	void Inspect1(PlayerPawn pmo, int h)
	{
		int s = insState[h];
		bool still = SpeedNow(h) < INS_STILL;
		if (s == 0)
		{
			if (still && InspectPose(pmo, h, 0, INS_TWIST))
			{
				insTics[h] = 1;
				SetInspect(h, 1);
			}
			else { insTics[h] = 0; SetInspect(h, 0); }
			return;
		}
		bool keep = InspectPose(pmo, h, INS_SLACK, INS_UNTWIST);
		if (!keep || (s == 1 && !still)) { insTics[h] = 0; SetInspect(h, 0); return; }
		insTics[h]++;
		if (s == 1 && insTics[h] >= INS_HOLD) SetInspect(h, 2);
	}

	// the "inspect" answer: 0 not, 1 entering, 2 held
	int Inspect(int pn, int h)     { if (!Asked(pn) || h < 0 || h > 1) return 0; return insState[h]; }
	int InspectTics(int pn, int h) { if (!Asked(pn) || h < 0 || h > 1) return 0; return insTics[h]; }

}

// RSQTR_GCopyService -- ask by name (no compile dependency); objectArg the asking PlayerPawn (anyone but the console player
// gets 0). -1 unknown.
//   "reader"     1: this reader is here
//   "inspect"    0 not, 1 entering, 2 held, intArg the hand (0 main, 1 off)     "inspect.tics"  tics since the pose was met
//   "inspect.any" the higher of the two hands
class RSQTR_GCopyService : Service
{
	static int Pn(Object o) { let pmo = PlayerPawn(o); return (pmo && pmo.player) ? pmo.PlayerNumber() : consoleplayer; }

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "reader") return 1;
		let h = RSQTR_GCopy.Get();
		if (!h) return -1;
		int pn = Pn(objectArg);
		if (request ~== "inspect")      return h.Inspect(pn, intArg);
		if (request ~== "inspect.tics") return h.InspectTics(pn, intArg);
		if (request ~== "inspect.any")  return max(h.Inspect(pn, 0), h.Inspect(pn, 1));
		return -1;
	}
}
