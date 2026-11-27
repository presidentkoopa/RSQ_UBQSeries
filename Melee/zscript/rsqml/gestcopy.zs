// RSQML_GCopy -- RSQ Melee's OWN gesture reader (tools/gestcopy/gestcopy_template.zs, written by tools/gestcopy/gen_gestcopy.py;
// GENERATED, do not edit here). Owner 2026-11-04 19:45: "I worry that anyone who uses Gun Cards won't have the standout
// feature of the watch check card because they didn't have Gestures." So each mod whose standout rides on a gesture
// carries the detector itself. (It began as a copy of RSQ Gestures' reader, later RSQ Accessibility's; Accessibility was
// removed 2026-11-27, owner: "remove the whole mod", so this copy is the only reader and asks no other mod.)
//
// WHAT IT IS. The reader's pose rules and numbers, each number the default the old reader's settings gave (those
// settings are gone with Accessibility), the left hand mirrored the same way.
//   PAIR     both hands down, both thrown apart, both palms out, both palms thrust, sent as the network event
//            rsqml_pair (arg0 the kind, arg1 hundredths).
// Nothing is measured unless someone asked in the last IDLE tics.
// NETPLAY: the pose is the console player's local hardware; the answers are about the console player.
//
// THE HANDS: RSQML_HandSync.Fix (tools/handsync), the frame's hand carried to the body this tic.
// Rig only, not headset-confirmed.

// where a hand is and how it is turned, in the player's own frame, in metres; every hand its own controller
class RSQML_GPose
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
class RSQML_GCopy : StaticEventHandler
{
	const IDLE = 35;
	const RING = 9;
	const SNAP = 8.0;
	const NEVER = -1000000.0;
	const SAME_PEAK = 30.0;
	const PAIR_DOWN  = 0;
	const PAIR_APART = 1;
	const PAIR_PALMS = 2;
	const PAIR_THRUST = 3;
	const PAIR_KINDS = 4;

	int lastAsk, lastRun;
	double prevAngle;
	bool live[2];
	Vector3 prevRel[2];
	double rvx[18], rvy[18], rvz[18];
	int ringAt[2], ringN[2];
	int quietTill;
	transient Service svcGrapple, svcWheel;
	transient int svcLook;
	double downAt[2], downMps[2], apartAt[2], palmsAt[2], thrustAt[2], thrustMps[2], saidAt[PAIR_KINDS];
	int pairAsk;
	double palmsHeldFor;
	bool palmsSaid;

	static RSQML_GCopy Get() { return RSQML_GCopy(StaticEventHandler.Find("RSQML_GCopy")); }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static double NowMs() { return gametic * 1000.0 / TICRATE; }
	static bool Dbg() { return Opt("rsqml_debug", 0) >= 1; }

	override void OnRegister() { ResetAll(); lastAsk = -1000; lastRun = -1; }
	override void WorldLoaded(WorldEvent e) { ResetAll(); lastAsk = -1000; lastRun = -1; }

	void ResetAll()
	{
		for (int h = 0; h < 2; h++)
		{
			live[h] = false; ringN[h] = 0; ringAt[h] = 0;
			downAt[h] = NEVER; downMps[h] = 0; apartAt[h] = NEVER; palmsAt[h] = NEVER; thrustAt[h] = NEVER; thrustMps[h] = 0;
		}
		for (int k = 0; k < PAIR_KINDS; k++) saidAt[k] = NEVER;
		pairAsk = -1000;
		palmsHeldFor = 0; palmsSaid = false;
	}

	PlayerPawn Me()
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return null;
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return null;
		return p.mo;
	}

	// the two-hand events are read while a mod asked about them in the last second
	bool TwoHandWanted() { return gametic - pairAsk <= IDLE; }
	bool Running() { return gametic - lastAsk <= IDLE || TwoHandWanted(); }

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
			if (!RSQML_GPose.PoseGood(pmo, h))
			{
				live[h] = false; ringN[h] = 0;
				continue;
			}
			Vector3 rel = RSQML_GPose.Metric(RSQML_HandSync.Fix(pmo, RSQML_GPose.HandPos(pmo, h), h) - RSQML_GPose.EyePos(pmo));
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
		}
		bool quiet = Quiet(pmo);
		if (TwoHandWanted()) TwoHand(pmo, quiet);
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


	// ---- QUIET: on RSQ Grapple's rope or with RSQ Wheel open, no two-hand events -------------
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

	// ---- BOTH HANDS ---------------------------------------------------------------------------------------------------
	// the old reader's two-hand numbers: the window both hands must land in, how old a peak may be, how soon the same
	// gesture may come again (ms); speeds in m/s and the share of a move that must go the named way; heights and reaches
	// in metres from the eyes; the pitch a palm or a thrust must point up (degrees); how long palms are held out (ms)
	const TWO_WINDOW_MS = 120.0;
	const TWO_AGE_MS = 180.0;
	const TWO_REPEAT_MS = 500.0;
	const TWO_DOWN_MPS = 2.0;
	const TWO_DOWN_FRAC = 0.5;
	const TWO_HIP_M = 0.60;
	const TWO_APART_MPS = 2.0;
	const TWO_CHEST_M = 0.40;
	const TWO_CHEST_R = 0.50;
	const TWO_FRONT_M = 0.25;
	const TWO_THRUST_MPS = 2.5;
	const TWO_THRUST_FRAC = 0.6;
	const TWO_THRUST_PITCH = 20.0;
	const TWO_PALMS_PITCH = 40.0;
	const TWO_PALMS_GAP = 0.25;
	const TWO_HOLD_MS = 400.0;
	const STILL_MPS = 0.3;
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
		if (Actor.Normalize180(RSQML_GPose.Pitch(pmo, h)) < TWO_PALMS_PITCH) return false;
		Vector3 b = RSQML_GPose.Body(pmo, h);
		return b.x >= frontM && b.z >= -hipM;
	}

	void TwoHand(PlayerPawn pmo, bool quiet)
	{
		if (quiet || !live[0] || !live[1]) { for (int h = 0; h < 2; h++) { downAt[h] = NEVER; apartAt[h] = NEVER; palmsAt[h] = NEVER; thrustAt[h] = NEVER; } palmsHeldFor = 0; palmsSaid = false; return; }
		double now = NowMs();
		double windowMs = TWO_WINDOW_MS, ageMs = TWO_AGE_MS, repeatMs = TWO_REPEAT_MS;
		double hipM = TWO_HIP_M, chestM = TWO_CHEST_M, chestR = TWO_CHEST_R, frontM = TWO_FRONT_M;
		bool doThrust = !IsBraced(pmo.player);
		double fc = cos(pmo.Angle), fs = sin(pmo.Angle);

		for (int h = 0; h < 2; h++)
		{
			double peakAt = PeakTimeMs(h, ageMs);
			Vector3 vel = PeakVel(h);
			Vector3 rel = RSQML_GPose.FromEyes(pmo, h);
			double speed = vel.Length();

			double downMove = -vel.z;
			bool downish = speed > 0.0001 && downMove / speed >= TWO_DOWN_FRAC;
			if (peakAt > NEVER && peakAt > saidAt[PAIR_DOWN] + SAME_PEAK && downMove >= TWO_DOWN_MPS && downish && rel.z <= -hipM)
			{
				downAt[h] = peakAt;
				downMps[h] = downMove;
			}

			Vector3 fromChest = (rel.x, rel.y, rel.z + chestM);
			double chestDist = fromChest.Length();
			if (peakAt > NEVER && peakAt > saidAt[PAIR_APART] + SAME_PEAK && chestDist > 0.0001 && chestDist <= chestR)
			{
				if ((vel dot fromChest.Unit()) >= TWO_APART_MPS * 0.5) apartAt[h] = peakAt;
			}

			if (PalmOut(pmo, h, frontM, hipM, STILL_MPS)) { if (palmsAt[h] <= NEVER) palmsAt[h] = now; }
			else palmsAt[h] = NEVER;

			double fwd = vel.x * fc + vel.y * fs;
			if (doThrust && peakAt > NEVER && peakAt > saidAt[PAIR_THRUST] + SAME_PEAK && fwd >= TWO_THRUST_MPS && speed > 0.0001
				&& fwd / speed >= TWO_THRUST_FRAC && rel.z >= -hipM && Actor.Normalize180(RSQML_GPose.Pitch(pmo, h)) >= TWO_THRUST_PITCH)
			{
				thrustAt[h] = peakAt;
				thrustMps[h] = fwd;
			}
		}

		double capMs = ageMs > 0 ? ageMs : RING * 1000.0 / TICRATE;
		double liveMs = capMs + windowMs;

		if (Together(downAt[0], downAt[1], windowMs, now, liveMs))
		{
			if (Announce(PAIR_DOWN, min(downMps[0], downMps[1]), now, repeatMs)) { downAt[0] = NEVER; downAt[1] = NEVER; }
		}
		if (Together(apartAt[0], apartAt[1], windowMs, now, liveMs))
		{
			Vector3 sep = RSQML_GPose.FromEyes(pmo, 0) - RSQML_GPose.FromEyes(pmo, 1);
			double rate = 0;
			if (sep.Length() > 0.0001) { Vector3 closing = PeakVel(0) - PeakVel(1); rate = closing dot sep.Unit(); }
			if (rate >= TWO_APART_MPS && Announce(PAIR_APART, rate, now, repeatMs)) { apartAt[0] = NEVER; apartAt[1] = NEVER; }
		}

		Vector3 b0 = RSQML_GPose.Body(pmo, 0), b1 = RSQML_GPose.Body(pmo, 1);
		bool apartEnough = abs(b0.y - b1.y) >= TWO_PALMS_GAP;
		if (doThrust && apartEnough && Together(thrustAt[0], thrustAt[1], windowMs, now, liveMs))
		{
			if (Announce(PAIR_THRUST, min(thrustMps[0], thrustMps[1]), now, repeatMs)) { thrustAt[0] = NEVER; thrustAt[1] = NEVER; }
		}
		if (palmsAt[0] > NEVER && palmsAt[1] > NEVER && apartEnough)
		{
			palmsHeldFor = (now - max(palmsAt[0], palmsAt[1])) / 1000.0;
			if (!palmsSaid && palmsHeldFor * 1000.0 >= TWO_HOLD_MS && Announce(PAIR_PALMS, palmsHeldFor, now, 0)) palmsSaid = true;
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
		EventHandler.SendNetworkEvent("rsqml_pair", which, int(round(mag * 100)), 0);
		saidAt[which] = now;
		if (Dbg())
		{
			static const String pairName[] = { "both hands down", "both hands apart", "both palms out", "both palms thrust" };
			Console.Printf("RSQML pair: %s, %.2f (t%d)", pairName[which], mag, level.maptime);
		}
		return true;
	}

	// "pair.ago": ms since that two-hand gesture fired, -1 never; asking keeps the two-hand events read a second
	double PairAgoMs(int pn, int k) { pairAsk = gametic; if (!Asked(pn) || k < 0 || k >= PAIR_KINDS || saidAt[k] <= NEVER) return -1; return NowMs() - saidAt[k]; }
}

// RSQML_GCopyService -- ask by name (no compile dependency); objectArg the asking PlayerPawn (anyone but the console player
// gets 0). -1 unknown.
//   "reader"     1: this reader is here
//   "pair.reader" 1: this mod reads both hands itself (both hands down / apart / palms / palms thrust)
//   "pair.ago"   ms since that two-hand gesture (intArg the kind) fired, -1 never; asking keeps the reader awake
class RSQML_GCopyService : Service
{
	static int Pn(Object o) { let pmo = PlayerPawn(o); return (pmo && pmo.player) ? pmo.PlayerNumber() : consoleplayer; }

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "reader") return 1;
		if (request ~== "pair.reader") return 1;
		let h = RSQML_GCopy.Get();
		if (!h) return -1;
		int pn = Pn(objectArg);
		if (request ~== "pair.ago")     return int(h.PairAgoMs(pn, intArg));
		return -1;
	}
}
