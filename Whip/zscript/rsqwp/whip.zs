// THE WHIP (PROJECT WHIP, 2026-10-30). rsqwp_whip 1 turns the hook binds into a bullwhip.
//
// A REAL WHIP, SIMULATED. The thong is a chain of NN links with mass, integrated by Verlet
// SUB times a tic with distance constraints between neighbours -- the method Eye of the
// Temple uses for its whip (runevision's devlog: "the positions and velocities of the links
// are stored in arrays", "the spring pulls one link more than the other: the whip gets
// thinner towards the tip, critical for whip-like behavior"). Here the links get LIGHTER
// toward the tip (mass falls to about a tenth), so a motion at the handle gathers into the
// tip: the same taper that sends a real popper supersonic. Nothing is scripted:
//
//   * THE CRACK is the tip going fast: when the tip's speed in a tic passes the crack speed
//     (rsqwp_whip_crack, room units a tic) it cracks THERE, where the loop arrived. A lazy
//     swing never cracks; a lift and a snap of the forearm, or a flick of the wrist, does.
//     The handle is a rigid 24 cm stick in your hand, so turning the wrist whips the thong.
//   * THE DROOP is gravity on a slack thong, so it says how much the whip is loaded.
//   * IT HITS what it touches when it is moving fast (the outer half of the thong, swept
//     from where each link was to where it is, so a fast lash cannot pass through a thing
//     between two tics), harder the faster; the crack hits hardest, knocks the thing into its
//     Pain (which breaks off the attack it was winding up), throws a switch it lands on, and
//     flicks a loose pickup to you. A fast tip that meets something ABOVE the hand wraps round
//     it and becomes core's rope: swing, reel and let go are core's own.
//
// THE BINDS (the hook's two). Real (rsqwp_whip_mode 0): hold the bind and the whip uncoils
// from that hand; it hangs from the hand and does what your hand does; let go and it rolls up.
// Assist (1): a press throws a lash for you (the same simulated whip, the handle driven over
// the shoulder and snapped down) and it rolls up after. With RSQ_Accessibility's Hold to
// Toggle, Real is press-out, press-in.
//
// ROOM SPACE. The engine squashes map Z by pixelstretch (1.2), so the chain is simulated in
// room units (map z x 1.2), where lengths and speeds mean the same in every direction, and
// put back into map space to draw and to trace.
//
// NO EDIT TO CORE'S INPUT. This handler runs after core's on the same network event
// (registered after RSQWP_Input in MAPINFO): when the whip is on, the claw core just fired
// (phase FLY, age 0) is taken back before it moves a unit.
class RSQWP_Whip : EventHandler
{
	const NW = MAXPLAYERS * 2;
	const NN = 20;               // links in the thong; node 0 is the handle's tip
	const NP = NN + 1;
	const SUB = 8;               // Verlet sub-steps per tic
	const ITER = 6;              // constraint passes per sub-step (fewer and the thong stretches, which eats the wave)
	const HANDLEN = 8.0;          // the handle, map units (~24 cm)
	const PS = 1.2;              // pixelstretch
	const GRAV = 0.30;           // room units / tic^2 (Doom's own 1.0 is for falling bodies, not leather)
	const DAMP = 0.9995;         // per sub-step
	const MAXSTEP = 11.0;        // most a link may move in one sub-step (a hand teleport cannot explode it)

	const ST_IDLE = 0;
	const ST_OUT = 1;
	const ST_ROLL = 2;

	PlayerPawn wby[NW];
	int     wstate[NW];
	int     wmode[NW];           // 0 real, 1 assist
	int     wage[NW];
	double  wext[NW];            // how much of the thong is paid out, 0..1
	double  wlen[NW];            // the thong's full length, room units
	Vector3 wp[NW * NP];         // nodes, room space, now
	Vector3 wq[NW * NP];         // and one sub-step ago
	Vector3 wt[NW * NP];         // nodes in map space at the start of this tic (the sweep's start)
	Vector3 hb[NW], hd[NW];      // last tic's handle base (room) and direction (room, unit)
	double  tipSpd[NW];          // fastest the tip went this tic, room units a tic
	bool    armed[NW];
	bool    swished[NW];
	int     calm[NW];
	int     cracks[NW];          // cracks this draw (debug and the service)
	bool    pend[NW];            // past the crack speed, waiting for the peak
	double  pkSpd[NW], rearm[NW];
	Vector3 pkAt[NW], pkVel[NW];
	int     crackTic[NW];
	int     fullTics[NW];
	double  handSpd[NW];         // the handle tip's recent speed, room units a tic (decays 7% a tic: the wave takes a third of a second to reach the tip)        // tics the thong has been fully out (it cannot crack while it uncoils)
	Actor   whit[NW * 4];        // the last few things this lash has hit (once each per lash)
	int     whitTic[NW * 4];
	bool    whitCrack[NW * 4];
	int     lashUntil[NW];       // the crack's lash: the thong still lands as hard as the crack for a few tics
	// LOCK (rsqwp_whip_aim 2): the other hand points, the whip hand's alt-fire holds the lock
	bool    lockHeld[NW];
	bool    byWeapon[NW];        // this whip is the RSQWP_WhipWeapon's (weapon.zs): alt-fire locks, its model holds the handle
	int     lockLeft[NW];        // tics the lock lasts after the button is let go
	Actor   lockOn[NW];          // the locked monster or pickup, or
	Vector3 lockAt[NW];          // the point on a locked switch line
	bool    lockLine[NW];
	int     reachTic[NW];        // a locked crack's flight: tics left to reach the target
	Actor   reachFor[NW];
	Vector3 reachPt[NW];
	double  baseLen[NW];
	Vector3 pumpOff[NW];         // the whip hand's offset from the body last tic (the arm pump)
	int     mantleTic[MAXPLAYERS];   // tics left of a mantle (rising, then onto the top)
	double  mantleTop[MAXPLAYERS];   // the floor he is going up onto
	Vector2 mantleFwd[MAXPLAYERS];   // and which way it lies
	Vector2 mantleLip[MAXPLAYERS];   // the lip, in 2D
	bool    pumpHad[NW];
	// THE WHIP WEAPON (weapon.zs, owner 2026-10-31): mark with the trigger, cycle with alt-fire, pull by gesture, lasso
	bool    markHeld[NW];        // the trigger is held: the whip hand marks
	bool    markNext[NW];        // alt-fire: the mark moves on to the next nearest
	Line    markLine[NW];        // a marked switch
	Actor   wrapOn[NW];          // the monster the whip is wrapped round, waiting for the pull
	int     wrapUntil[NW];
	Vector3 pullOff[NW];         // the whip hand's offset from the body last tic
	bool    pullHad[NW];
	double  pullPk[NW];          // the pull so far (its peak, map units a tic)
	bool    lassoOn[NW], lassoWas[NW];
	Vector3 lassoP0[NW], lassoP1[NW];   // the off hand holding the thong, last tic and now (room)
	transient Array<Actor> cA;
	transient Array<Line> cL;
	transient Array<double> cK;
	transient Array<double> cPx, cPy, cPz;
	RSQWP_Rope wl[NW * NP];      // the drawn whip: piece 0 the handle, 1..NN the thong
	transient RSQWP_Tracer tracer;

	static RSQWP_Whip Get() { return RSQWP_Whip(EventHandler.Find("RSQWP_Whip")); }

	static clearscope Vector3 ToRoom(Vector3 m) { return (m.x, m.y, m.z * PS); }
	static clearscope Vector3 ToMap(Vector3 r) { return (r.x, r.y, r.z / PS); }

	override void OnRegister()
	{
		for (int i = 0; i < NW; i++) if (!wby[i]) wstate[i] = ST_IDLE;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		for (int i = 0; i < NW; i++) { wstate[i] = ST_IDLE; wby[i] = null; }
	}

	// Is a whip out in this hand? (the service and the hook ask)
	static bool IsOut(PlayerPawn pmo, int hand)
	{
		let w = Get();
		if (!w || !pmo || !pmo.player) return false;
		int i = pmo.PlayerNumber() * 2 + (hand & 1);
		return w.wstate[i] != ST_IDLE && w.wby[i] == pmo;
	}

	// ---- input ------------------------------------------------------------------------------

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		int hand = e.Args[0] & 1;
		int i = e.Player * 2 + hand;
		let pmo = players[e.Player].mo;
		if (!pmo) return;
		if (false) {}
		else if (e.Name ~== "rsqwp_up")
		{
			if (wstate[i] == ST_OUT && wmode[i] == 0 && wby[i] == pmo) RollUp(i);
		}
		else if (e.Name ~== "rsqwp_lock")
		{
			lockHeld[i] = e.Args[1] != 0;
			if (lockHeld[i]) lockLeft[i] = 35;
		}
	}

	// LOCK's button: whatever is bound to +altattack. While a whip is out in this machine's hand
	// and Whip Aim is Lock, that press and release go to the whip (and not to the gun in the hand).
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		if (RSQWP_Util.Opt("rsqwp_whip_aim", 1) != 2) return false;
		let b = Bindings.GetBinding(e.KeyScan);
		if (!(b ~== "+altattack")) return false;
		let p = players[consoleplayer];
		if (!p || !p.mo) return false;
		for (int hand = 0; hand < 2; hand++)
		{
			int i = consoleplayer * 2 + hand;
			if (wstate[i] == ST_IDLE || wby[i] != p.mo || byWeapon[i]) continue;
			EventHandler.SendNetworkEvent("rsqwp_lock", hand, e.Type == InputEvent.Type_KeyDown ? 1 : 0);
			return true;
		}
		return false;
	}

	void Start(int i, PlayerPawn pmo, int hand, int mode)
	{
		bool fresh = wstate[i] == ST_IDLE || wby[i] != pmo;
		wby[i] = pmo;
		wmode[i] = clamp(mode, 0, 1);
		wstate[i] = ST_OUT;
		wage[i] = 0;
		wlen[i] = clamp(RSQWP_Util.Num("rsqwp_whip_reach", 128), 48, 320);
		armed[i] = true; swished[i] = false; calm[i] = 0; cracks[i] = 0; pend[i] = false; rearm[i] = 0; crackTic[i] = -100; fullTics[i] = wmode[i] == 1 ? -100000 : 0; handSpd[i] = 0; lashUntil[i] = -100; reachTic[i] = 0; baseLen[i] = wlen[i];
		for (int k = 0; k < 4; k++) { whit[i * 4 + k] = null; whitTic[i * 4 + k] = -1000; whitCrack[i * 4 + k] = false; }
		Vector3 b, d;
		[b, d] = Handle(i, pmo, hand);
		hb[i] = b; hd[i] = d;
		if (fresh)
		{
			wext[i] = wmode[i] == 1 ? 1.0 : 0.08;     // Assist throws it straight out of the hand
			// hanging from the handle: it uncoils under gravity and the hand's motion
			Vector3 tip = b + d * HANDLEN;
			Vector3 fall = (0, 0, -1);
			double seg = wext[i] * wlen[i] / NN;
			for (int k = 0; k < NP; k++)
			{
				wp[i * NP + k] = tip + fall * seg * k;
				wq[i * NP + k] = wp[i * NP + k];
				wt[i * NP + k] = ToMap(wp[i * NP + k]);
			}
		}
		Noise(pmo, 'unfurl', ToMap(b));
		if (wmode[i] == 1) Throw(i, pmo, hand);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d start mode %d len %.0f", i, wmode[i], wlen[i]);
	}

	// the whip weapon's trigger let go: roll it up (Real), as the bind's release does
	void WeaponUp(int i, PlayerPawn pmo)
	{
		if (wstate[i] == ST_OUT && wmode[i] == 0 && wby[i] == pmo) RollUp(i);
	}

	void RollUp(int i)
	{
		if (wstate[i] != ST_OUT) return;
		wstate[i] = ST_ROLL;
		if (wby[i]) Noise(wby[i], 'unfurl', ToMap(hb[i]));
	}

	// ---- the hand ---------------------------------------------------------------------------

	// The handle's base (the hand, room space) and its direction (room, unit). Assist drives
	// the direction over the shoulder and down; Real is the controller as it is.
	Vector3, Vector3 Handle(int i, PlayerPawn pmo, int hand)
	{
		Vector3 b = ToRoom(RSQWP_Util.HandPos(pmo, hand));
		double yaw = RSQWP_Util.HandYaw(pmo, hand);
		double pit = RSQWP_Util.HandPitch(pmo, hand);
		if (wmode[i] == 1) pit += AssistPitch(wage[i]);
		Vector3 d = (cos(pit) * cos(yaw), cos(pit) * sin(yaw), sin(pit));
		return b, d.Unit();
	}

	// A lash thrown for you: lift over the shoulder (7 tics), hold (2), snap down (3), follow.
	static double AssistPitch(int age)
	{
		if (age < 7) { double t = age / 7.0; return 115.0 * (t * t * (3 - 2 * t)); }
		if (age < 9) return 115.0;
		if (age < 12) { double t = (age - 9) / 3.0; return 115.0 - 140.0 * t; }
		return -25.0;
	}

	// ---- the tic ----------------------------------------------------------------------------

	double tickMs;               // last tic's cost, all whips (rsqwp_debug 2)

	override void WorldTick()
	{
		double t0 = MSTimeF();
		WorldTick2();
		tickMs = MSTimeF() - t0;
		msSum += tickMs; msMax = max(msMax, tickMs); msN++;
		if (msN >= 70)
		{
			if (RSQWP_Util.Opt("rsqwp_debug", 0) == 3) Console.Printf("T_WPWMS t%d mean %.3f max %.3f ms over %d tics (sim %.3f, sweeps %.3f, draw %.3f)", level.maptime, msSum / msN, msMax, msN, msSim / msN, msCol / msN, msDraw / msN);
			msSum = 0; msMax = 0; msN = 0; msSim = 0; msCol = 0; msDraw = 0;
		}
	}
	double msSum, msMax, msSim, msCol, msDraw;
	int msN;

	void WorldTick2()
	{
		// the whip weapon is in every player's slot 1 while RSQ Whip is on (no console needed)
		if (level.maptime % 35 == 1 && RSQWP_Util.Flag("rsqwp_on", true) && RSQWP_Util.Flag("rsqwp_whip_weapon", true))
			for (int pn = 0; pn < MAXPLAYERS; pn++)
			{
				let pm = playeringame[pn] ? players[pn].mo : null;
				if (pm && pm.Health > 0 && !pm.FindInventory("RSQWP_WhipWeapon")) pm.GiveInventory("RSQWP_WhipWeapon", 1);
			}
		ArmPump();
		Mantle();
		for (int i = 0; i < NW; i++)
		{
			if (wstate[i] == ST_IDLE)
			{
				continue;
			}
			let pmo = wby[i];
			if (!pmo || pmo.Health <= 0 || !RSQWP_Util.Flag("rsqwp_on", true)) { Halt(i); continue; }
			int hand = i & 1;
			wage[i]++;
			if (wstate[i] == ST_OUT)
			{
				wext[i] = min(1.0, wext[i] + 0.16);
				if (wext[i] >= 1.0) fullTics[i]++;
				if (wmode[i] == 1 && wage[i] > 24) RollUp(i);
			}
			if (wstate[i] == ST_ROLL)
			{
				wext[i] -= 0.12;
				if (wext[i] <= 0.06) { Halt(i); continue; }
			}
			Vector3 b, d;
			[b, d] = Handle(i, pmo, hand);
			// a hand that jumped (a teleport, a load: 24 room units a tic is 24 m/s, no arm does that):
			// lay the whip out again from where it is, and it must not count as a lash
			if ((b - hb[i]).Length() > 24)
			{
				Vector3 tip = b + d * HANDLEN;
				for (int k = 0; k < NP; k++) { wp[i * NP + k] = tip + (0, 0, -1) * (wext[i] * wlen[i] / NN) * k; wq[i * NP + k] = wp[i * NP + k]; }
				hb[i] = b; hd[i] = d;
				handSpd[i] = 0; pend[i] = false;
			}
			for (int k = 0; k < NP; k++) wt[i * NP + k] = ToMap(wp[i * NP + k]);
			// how hard the hand has driven the handle lately (its tip's speed, decaying): a crack
			// needs the hand behind it -- a whip that only falls or settles never cracks
			double hs = ((b + d * HANDLEN) - (hb[i] + hd[i] * HANDLEN)).Length();
			handSpd[i] = max(handSpd[i] * 0.93, hs);
			if (byWeapon[i]) Mark(i, pmo, hand); else Lock(i, pmo, hand);
			Reach(i, pmo, hand);
			HoldWrap(i, pmo, hand);
			if (lassoOn[i])
			{
				lassoP1[i] = ToRoom(RSQWP_Util.HandPos(pmo, 1 - hand));
				if (!lassoWas[i]) lassoP0[i] = lassoP1[i];
			}
			Vector3 peakAt, peakVel;
			double tA = MSTimeF();
			[peakAt, peakVel] = Sim(i, hb[i], hd[i], b, d);
			msSim += MSTimeF() - tA;
			if (lassoWas[i] && !lassoOn[i]) LassoThrow(i, pmo, hand);
			lassoWas[i] = lassoOn[i];
			lassoP0[i] = lassoP1[i];
			hb[i] = b; hd[i] = d;
			tA = MSTimeF();
			bool snagged = Collide(i, pmo, hand);
			msCol += MSTimeF() - tA;
			if (snagged) continue;     // snagged: core has it now
			Lash(i, pmo, hand, peakAt, peakVel);
			if (wstate[i] == ST_IDLE) continue;
			tA = MSTimeF();
			Draw(i);
			msDraw += MSTimeF() - tA;
		}
	}

	// The thong, SUB sub-steps from last tic's handle to this tic's. Returns where the tip
	// was when it went fastest this tic (map space) and its velocity there (room/tic).
	Vector3, Vector3 Sim(int i, Vector3 b0, Vector3 d0, Vector3 b1, Vector3 d1)
	{
		int o = i * NP;
		if (!invmSet) SetInvMass();
		double seg = max(0.5, wext[i] * wlen[i] / NN);
		// at rest (a still hand, a settled thong, nothing flying) three sub-steps are plenty
		int subs = (handSpd[i] < 0.5 && tipSpd[i] < 1.0 && reachTic[i] <= 0 && wext[i] >= 1.0) ? 3 : SUB;
		double g = GRAV / (subs * subs);
		double best = -1;
		Vector3 bestAt = ToMap(wp[o + NN]), bestVel = (0, 0, 0);
		for (int s = 1; s <= subs; s++)
		{
			double t = double(s) / subs;
			Vector3 base = b0 + (b1 - b0) * t;
			Vector3 dir = d0 + (d1 - d0) * t;
			double dl = dir.Length();
			dir = dl > 0.001 ? dir / dl : d1;
			Vector3 anchor = base + dir * HANDLEN;
			for (int k = 1; k < NP; k++)
			{
				Vector3 v = (wp[o + k] - wq[o + k]) * DAMP;
				double vl = v.Length();
				if (vl > MAXSTEP) v *= MAXSTEP / vl;
				wq[o + k] = wp[o + k];
				wp[o + k] = wp[o + k] + v + (0, 0, -g);
			}
			wq[o] = wp[o];
			wp[o] = anchor;
			for (int it = 0; it < ITER; it++)
			{
				// the handle is rigid: the first link leaves it along the handle
				Vector3 want = anchor + dir * seg;
				wp[o + 1] = want;
				for (int k = 0; k < NN; k++)
				{
					Vector3 dd = wp[o + k + 1] - wp[o + k];
					double l = dd.Length();
					if (l < 0.0001) continue;
					double diff = (l - seg) / l;
					double w0 = k == 0 ? 0.0 : invm[k];
					double w1 = invm[k + 1];
					double sum = w0 + w1;
					wp[o + k] = wp[o + k] + dd * (diff * w0 / sum);
					wp[o + k + 1] = wp[o + k + 1] - dd * (diff * w1 / sum);
				}
				// the lasso: the off hand holds the thong LASSO_K links out
				if (lassoOn[i]) wp[o + LASSO_K] = lassoP0[i] + (lassoP1[i] - lassoP0[i]) * t;
			}
			Vector3 tv = (wp[o + NN] - wq[o + NN]) * subs;
			double sp = tv.Length();
			if (sp > best) { best = sp; bestAt = ToMap(wp[o + NN]); bestVel = tv; }
		}
		tipSpd[i] = best;
		return bestAt, bestVel;
	}

	// Mass falls from 1 at the handle to about a thirtieth at the popper: the taper. Worked out once
	// (InvMass is in the solver's innermost loop: a power per call cost a third of the tic). Searched in
	// tools/whipsim.py against rig-recorded hand paths: an overhead or side-arm crack takes the tip
	// past 50 room units a tic, a slow lift or a sweep stays under 1.
	transient double invm[NP];
	transient bool invmSet;
	void SetInvMass()
	{
		for (int k = 0; k < NP; k++)
		{
			double u = double(k) / NN;
			invm[k] = 1.0 / (((1.0 - 0.85 * u) ** 2.5) + 0.02);
		}
		invmSet = true;
	}

	// Floors, ceilings and walls, swept from where each link was at the start of the tic. The
	// outer half of the thong also meets things (hits) and, fast and above the hand, snags.
	bool Collide(int i, PlayerPawn pmo, int hand)
	{
		int o = i * NP;
		let tr = GetTracer();
		tr.shooter = pmo;
		Vector3 handAt = RSQWP_Util.HandPos(pmo, hand);
		double handZ = handAt.z;
		double hitSpd = RSQWP_Util.Num("rsqwp_whip_crack", 20) * 0.45;
		bool snagOn = RSQWP_Util.Flag("rsqwp_whip_snag", true) && wstate[i] == ST_OUT;
		for (int k = 1; k < NP; k++)
		{
			Vector3 m = ToMap(wp[o + k]);
			Vector3 m0 = wt[o + k];
			double spd = (wp[o + k] - ToRoom(m0)).Length();     // room units this tic
			bool outer = k >= NN / 2;
			Vector3 mv = m - m0;
			double ml = mv.Length();
			if (ml > (outer ? 0.5 : 1.5))
			{
				Vector3 dir = mv / ml;
				bool lashing = level.maptime <= lashUntil[i];
				bool any = tr.Trace(m0, level.PointInSector(m0.xy), dir, ml + 0.5, 0, RSQWP_Tracer.WALLMASK, !(outer && spd >= (lashing ? hitSpd * 0.5 : hitSpd)), pmo);
				if (any && tr.Results.HitType == TRACE_HitActor && tr.Results.HitActor)
				{
					// in the crack's lash (the tics after it, while the loop unrolls and the thong
					// lands) a fast link strikes as hard as the crack itself
					bool lash = level.maptime <= lashUntil[i] && spd >= hitSpd * 0.5;
					Hit(i, pmo, hand, tr.Results.HitActor, tr.Results.HitPos, spd, lash);
				}
				else if (any && tr.Results.HitType != TRACE_HitNone)
				{
					Vector3 at = tr.Results.HitPos;
					bool edge; double ez;
					[edge, ez] = Edge(tr, at);
					if (RSQWP_Util.Opt("rsqwp_debug", 0) == 4 && k >= NN / 2)
						Console.Printf("T_WPWC %d t%d link %d hit %d at (%.0f %.0f %.0f) spd %.1f edge %d ez %.0f handZ %.0f", i, level.maptime, k, tr.Results.HitType, at.x, at.y, at.z, spd, edge, ez, handZ);
					if (snagOn && edge && k >= NN * 2 / 3 && spd >= hitSpd * 0.4 && at.z > handZ + RSQWP_Util.Num("rsqwp_whip_above", 16))
					{
						if (Snag(i, pmo, hand, (at.x, at.y, ez), dir, tr.Results.HitSector, at)) return true;
					}
					m = at - dir * 0.5;
					wp[o + k] = ToRoom(m);
					wq[o + k] = wp[o + k];             // it stops dead against the wall
					continue;
				}
			}
			// the floor and the ceiling under and over the link
			let sec = level.PointInSector(m.xy);
			double fz = sec.floorplane.ZatPoint(m.xy) + 0.4;
			double cz = sec.ceilingplane.ZatPoint(m.xy) - 0.4;
			if (m.z < fz || m.z > cz)
			{
				m.z = m.z < fz ? fz : cz;
				Vector3 r = ToRoom(m);
				Vector3 v = wp[o + k] - wq[o + k];
				wp[o + k] = r;
				wq[o + k] = r - (v.x * 0.6, v.y * 0.6, 0);   // drags along the floor
			}
		}
		return false;
	}

	const LOCK_RANGE = 512.0;    // map units (~15 m)
	const LOCK_CONE = 7.0;       // degrees round the pointing hand
	const REACH_TICS = 5;

	// LOCK: while the whip hand's alt-fire is held, the OTHER hand points; the nearest monster,
	// loose pickup or switch along that ray (within LOCK_CONE degrees, in sight) is locked, marked
	// with a small ring of sparks, and a tick in the pointing hand says so. The lock lasts a second
	// after the button is let go. The next crack goes to it (Crack, Reach).
	void Lock(int i, PlayerPawn pmo, int hand)
	{
		if (lockLeft[i] > 0 && !lockHeld[i]) lockLeft[i]--;
		if (lockLeft[i] <= 0) { lockOn[i] = null; lockLine[i] = false; return; }
		if (lockOn[i] && (lockOn[i].bDestroyed || (lockOn[i].Health <= 0 && lockOn[i].bISMONSTER))) lockOn[i] = null;
		int ph = 1 - hand;
		if (lockHeld[i])
		{
			Vector3 org = RSQWP_Util.HandPos(pmo, ph);
			Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, ph), RSQWP_Util.HandPitch(pmo, ph));
			Actor was = lockOn[i];
			bool wasLine = lockLine[i];
			Actor best = null;
			double bestA = LOCK_CONE;
			let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, LOCK_RANGE, false);
			while (it.Next())
			{
				let a = it.thing;
				if (!a || a == pmo || a.player || a.bDestroyed) continue;
				bool mon = a.bSHOOTABLE && !a.bNONSHOOTABLE && a.Health > 0 && !a.bMISSILE && !(a is "RSQWP_Rope");
				let inv = Inventory(a);
				bool item = inv && !inv.Owner && inv.bSPECIAL;
				if (!mon && !item) continue;
				Vector3 c = a.pos + (0, 0, a.height * 0.5);
				Vector3 to = c - org;
				double d = to.Length();
				if (d < 8 || d > LOCK_RANGE) continue;
				double ang = acos(clamp((to / d) dot dir, -1.0, 1.0));
				// a wide target may be off the ray by its own radius
				double slack = atan2(a.radius, d);
				if (ang - slack > bestA) continue;
				if (!pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
				best = a; bestA = ang - slack;
			}
			lockOn[i] = best;
			lockLine[i] = false;
			if (!best)
			{
				// a switch on the ray
				let tr = GetTracer();
				tr.shooter = pmo;
				if (tr.Trace(org, level.PointInSector(org.xy), dir, LOCK_RANGE, 0, RSQWP_Tracer.WALLMASK, true, pmo)
					&& tr.Results.HitType == TRACE_HitWall && tr.Results.HitLine && tr.Results.HitLine.special
					&& (tr.Results.HitLine.activation & (SPAC_Use | SPAC_Impact | SPAC_UseThrough)))
				{
					lockLine[i] = true;
					lockAt[i] = tr.Results.HitPos - dir * 2;
				}
			}
			if ((lockOn[i] && lockOn[i] != was) || (lockLine[i] && !wasLine)) Buzz(pmo, ph, 0.3, 2);
		}
		// the mark: a small turning ring of sparks over the locked thing
		if (level.maptime % 2 == 0 && (lockOn[i] || lockLine[i]))
		{
			Vector3 c = lockOn[i] ? lockOn[i].pos + (0, 0, lockOn[i].height + 6) : lockAt[i];
			double r = lockOn[i] ? max(6.0, lockOn[i].radius * 0.8) : 6.0;
			Vector3 off = c - pmo.pos;
			for (int k = 0; k < 6; k++)
			{
				double a = level.maptime * 12 + k * 60;
				pmo.A_SpawnParticle(lockLine[i] ? 0xFFE060 : 0xFF6030, SPF_FULLBRIGHT, 5, 3.0, 0,
					off.x + cos(a) * r, off.y + sin(a) * r, off.z, 0, 0, 0.1);
			}
		}
	}

	// ---- the whip weapon: mark, pull, lasso (owner 2026-10-31) ---------------------------------

	const MARK_CONE = 20.0;      // degrees round the whip hand for monsters and other pickups
	const PRIO_CONE = 70.0;      // switches, keys and powerups: anywhere roughly ahead, within rsqwp_whip_prio
	const WRAP_TICS = 70;        // how long the whip stays wrapped round a monster waiting for the pull
	const PULL_MIN = 1.5;        // the hand going back from the target, map units a tic (~1.5 m/s): a tug
	const PULL_FULL = 4.0;       // ~4 m/s: a violent pull, the full yank
	const LASSO_K = 5;           // the link the off hand holds
	const LASSO_MIN = 6.0;       // the tip's speed (room units a tic) a let-go must have to fly

	static bool IsDoor(int sp)
	{
		return (sp >= 10 && sp <= 14) || sp == 105 || sp == 106 || sp == 202 || sp == 249;
	}
	static bool Priority(Inventory inv)
	{
		return inv is "Key" || inv is "PowerupGiver" || inv.bCOUNTITEM || inv.bBIGPOWERUP;
	}

	private void AddCand(Actor a, Line l, Vector3 p, double key)
	{
		int n = cK.Size();
		int at = n;
		while (at > 0 && cK[at - 1] > key) at--;
		cA.Insert(at, a); cL.Insert(at, l); cPx.Insert(at, p.x); cPy.Insert(at, p.y); cPz.Insert(at, p.z); cK.Insert(at, key);
	}

	// MARK: while the trigger is held the whip hand points. The candidates are switches, keys and powerups within
	// rsqwp_whip_prio (nearest first), then monsters and pickups along the hand (within MARK_CONE, LOCK_RANGE,
	// nearest first). The mark stays on what it is on while that is still a candidate; alt-fire moves it to the
	// next. Let go of the trigger and the mark is lost. The next crack flies to it (Crack, Reach).
	void Mark(int i, PlayerPawn pmo, int hand)
	{
		if (!markHeld[i])
		{
			lockOn[i] = null; lockLine[i] = false; lockLeft[i] = 0; markLine[i] = null; markNext[i] = false;
			return;
		}
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, hand), RSQWP_Util.HandPitch(pmo, hand));
		double prio = max(0.0, RSQWP_Util.Num("rsqwp_whip_prio", 256));
		cA.Clear(); cL.Clear(); cPx.Clear(); cPy.Clear(); cPz.Clear(); cK.Clear();
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, LOCK_RANGE, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || a.bDestroyed) continue;
			bool mon = a.bSHOOTABLE && !a.bNONSHOOTABLE && a.Health > 0 && !a.bMISSILE && a.bISMONSTER && !(a is "RSQWP_Rope");
			if (a.bINVISIBLE || a.sprite == Actor.GetSpriteIndex('TNT1')) continue;   // a spawner or a marker, not a thing to see
			let inv = Inventory(a);
			bool item = inv && !inv.Owner && inv.bSPECIAL;
			if (!mon && !item) continue;
			Vector3 c = a.pos + (0, 0, a.height * 0.5);
			Vector3 to = c - org;
			double d = to.Length();
			if (d < 8 || d > LOCK_RANGE) continue;
			double ang = acos(clamp((to / d) dot dir, -1.0, 1.0)) - atan2(a.radius, d);
			bool first = item && Priority(inv) && d <= prio && ang <= PRIO_CONE;
			if (!first && ang > MARK_CONE) continue;
			if (!pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			AddCand(a, null, c, first ? d : 100000 + d);
		}
		if (prio > 0 && RSQWP_Util.Flag("rsqwp_whip_lines", true))
		{
			let tr = GetTracer();
			tr.shooter = pmo;
			let li = BlockLinesIterator.CreateFromPos(org, 64, prio);
			while (li.Next())
			{
				Line l = li.CurLine;
				if (!l || !l.special || IsDoor(l.special) || !(l.activation & (SPAC_Use | SPAC_Impact | SPAC_UseThrough))) continue;
				Vector2 a = l.v1.p, dl = l.delta;
				double len2 = dl dot dl;
				if (len2 <= 0) continue;
				double t = clamp(((org.xy - a) dot dl) / len2, 0.05, 0.95);
				Vector2 p2 = a + dl * t;
				Sector s = level.PointOnLineSide(org.xy, l) == 0 ? l.frontsector : l.backsector;
				if (!s) continue;
				double fz = s.floorplane.ZatPoint(p2), cz = s.ceilingplane.ZatPoint(p2);
				// a two-sided line: its switch is on the step or the lintel, else the middle of the wall
				Sector o2 = level.PointOnLineSide(org.xy, l) == 0 ? l.backsector : l.frontsector;
				double z = clamp(org.z, fz + 8, max(fz + 8, cz - 8));
				if (o2)
				{
					double ofz = o2.floorplane.ZatPoint(p2), ocz = o2.ceilingplane.ZatPoint(p2);
					if (ofz > fz + 8) z = (fz + min(ofz, cz)) * 0.5;
					else if (ocz < cz - 8) z = (max(ocz, fz) + cz) * 0.5;
				}
				Vector3 p = (p2.x, p2.y, z);
				Vector3 to = p - org;
				double d = to.Length();
				if (d < 4 || d > prio) continue;
				double ang = acos(clamp((to / d) dot dir, -1.0, 1.0));
				if (ang > PRIO_CONE) continue;
				// in sight: the first wall along the way is this one
				Vector3 u = to / d;
				if (tr.Trace(org, level.PointInSector(org.xy), u, d + 4, 0, RSQWP_Tracer.WALLMASK, true, pmo)
					&& tr.Results.HitType != TRACE_HitNone && tr.Results.HitLine != l && tr.Results.Distance < d - 2) continue;
				AddCand(null, l, p - u * 2, d);
			}
		}
		int n = cK.Size();
		int cur = -1;
		for (int k = 0; k < n; k++)
			if ((lockOn[i] && cA[k] == lockOn[i]) || (!lockOn[i] && markLine[i] && cL[k] == markLine[i])) { cur = k; break; }
		int pick = cur;
		if (n == 0) pick = -1;
		else if (markNext[i]) pick = (cur + 1) % n;
		else if (cur < 0) pick = 0;
		markNext[i] = false;
		Actor wasA = lockOn[i]; Line wasL = markLine[i];
		if (pick < 0) { lockOn[i] = null; markLine[i] = null; lockLine[i] = false; lockLeft[i] = 0; }
		else
		{
			lockOn[i] = cA[pick]; markLine[i] = cL[pick]; lockLine[i] = cL[pick] != null; lockAt[i] = (cPx[pick], cPy[pick], cPz[pick]);
			lockLeft[i] = 35;
		}
		if (lockOn[i] != wasA || markLine[i] != wasL)
		{
			if (pick >= 0) Buzz(pmo, hand, 0.3, 2);
			if (RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d MARK t%d -> %s (%d of %d)", i, level.maptime,
					lockOn[i] ? String.Format("%s", lockOn[i].GetClassName()) : (markLine[i] ? String.Format("line %d special %d", markLine[i].Index(), markLine[i].special) : "nothing"), pick + 1, n);
		}
		MarkRing(i, pmo);
	}

	// the mark: a small turning ring of sparks over the marked thing (a switch: gold)
	void MarkRing(int i, PlayerPawn pmo)
	{
		if (level.maptime % 2 != 0 || !(lockOn[i] || lockLine[i])) return;
		Vector3 c = lockOn[i] ? lockOn[i].pos + (0, 0, lockOn[i].height + 6) : lockAt[i];
		double r = lockOn[i] ? max(6.0, lockOn[i].radius * 0.8) : 6.0;
		Vector3 off = c - pmo.pos;
		for (int k = 0; k < 6; k++)
		{
			double a = level.maptime * 12 + k * 60;
			pmo.A_SpawnParticle(lockLine[i] ? 0xFFE060 : 0xFF6030, SPF_FULLBRIGHT, 5, 3.0, 0,
				off.x + cos(a) * r, off.y + sin(a) * r, off.z, 0, 0, 0.1);
		}
	}

	// WRAPPED round a monster (a marked crack or a lasso landed on it): the thong stays laid out to it, and a pull
	// back of the whip hand -- the hand going away from the monster, against the body, so walking does not count --
	// yanks it when the pull ends (Yank: how hard is the pull's peak). Nothing in WRAP_TICS and it lets go.
	void HoldWrap(int i, PlayerPawn pmo, int hand)
	{
		Vector3 hp = RSQWP_Util.HandPos(pmo, hand);
		Vector3 off = hp - pmo.pos;
		Vector3 d = off - pullOff[i];
		bool had = pullHad[i];
		pullOff[i] = off; pullHad[i] = true;
		let v = wrapOn[i];
		if (!v) return;
		if (v.bDestroyed || v.Health <= 0 || level.maptime > wrapUntil[i] || reachTic[i] > 0) { if (reachTic[i] <= 0) wrapOn[i] = null; return; }
		Vector3 c = v.pos + (0, 0, v.height * 0.6);
		Vector3 roomTo = ToRoom(c) - ToRoom(hp);
		double dist = roomTo.Length();
		if (dist > LOCK_RANGE * 1.3) { wrapOn[i] = null; return; }
		// the thong stays out to it: the outer half laid along the line, the tip on the monster
		wlen[i] = max(baseLen[i], dist + 8);
		int o = i * NP;
		for (int k = NN / 2; k < NP; k++)
		{
			double u = double(k - NN / 2) / (NN - NN / 2);
			Vector3 want = ToRoom(hp) + roomTo * (0.5 + 0.5 * u);
			wp[o + k] = wp[o + k] + (want - wp[o + k]) * 0.5;
		}
		if (!had || d.Length() > 24) return;
		Vector3 toV = (c - hp).Unit();
		double pull = -(d dot toV);
		if (pull >= PULL_MIN) { pullPk[i] = max(pullPk[i], pull); return; }
		if (pullPk[i] >= PULL_MIN) Yank(i, pmo, hand, v, pullPk[i]);
		pullPk[i] = 0;
	}

	// THE YANK. How hard: 0 a tug (PULL_MIN) .. 1 violent (PULL_FULL). Light monsters (mass up to rsqwp_whip_light)
	// are pulled off their feet on an arc toward you -- most of the way on a violent pull; medium ones stagger part
	// of the way; at rsqwp_whip_heavy mass, a boss or a thing that cannot be thrust, it does not move: the yank
	// swings you toward it in an arc instead.
	void Yank(int i, PlayerPawn pmo, int hand, Actor v, double peak)
	{
		double s = clamp((peak - PULL_MIN) / (PULL_FULL - PULL_MIN), 0.0, 1.0);
		double light = RSQWP_Util.Num("rsqwp_whip_light", 400);
		double heavyM = RSQWP_Util.Num("rsqwp_whip_heavy", 1000);
		bool heavy = v.bBOSS || v.bDONTTHRUST || v.Mass >= heavyM;
		Vector3 to = pmo.pos - v.pos;
		double dist = to.xy.Length();
		Vector2 u = dist > 0.01 ? to.xy / dist : (0, 0);
		String what;
		if (!heavy)
		{
			bool isLight = v.Mass <= light;
			double frac = isLight ? 0.25 + 0.65 * s : 0.08 + 0.3 * s;
			double travel = max(0.0, dist - pmo.radius - v.radius - 16) * frac;
			double T = 14;
			double g = v.bNOGRAVITY ? 0 : level.gravity * v.Gravity / 800.0;
			double lift = isLight ? 0.5 * g * T : 0.5 * g * T * 0.4;
			v.vel = (u.x * travel / T, u.y * travel / T, lift + max(0.0, to.z) / T);
			if (isLight && s >= 0.5 && v.bISMONSTER)
			{
				State pain = v.FindState("Pain");
				if (pain && !v.InStateSequence(v.CurState, pain)) v.SetState(pain);
			}
			what = isLight ? "light: pulled" : "medium: staggers";
		}
		else
		{
			double sp = 6 + 10 * s;
			pmo.vel.xy = pmo.vel.xy * 0.3 - u * sp;
			pmo.vel.z = max(pmo.vel.z, 4 + 5 * s);
			double top = RSQWP_Util.Num("rsqwp_max_speed", 30);
			if (top > 0 && pmo.vel.Length() > top) pmo.vel *= top / pmo.vel.Length();
			pmo.player.keepmomentum = true;
			what = "heavy: you swing to it";
		}
		Noise(pmo, 'swish', v.pos + (0, 0, v.height * 0.6));
		Buzz(pmo, hand, 0.5 + 0.5 * s, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d YANK t%d %s mass %d pull %.1f (%.0f%%) %s", i, level.maptime, v.GetClassName(), v.Mass, peak, s * 100, what);
		wrapOn[i] = null;
	}

	// THE LASSO let go: the thong was whirling on the off hand; the grip let go, it flies on the way its tip was
	// going (flat), to the monster nearest that way (within 25 degrees and twice the whip's length) and wraps round
	// it, ready for the pull -- or out to full length if nothing is there. Too slow and it just drops.
	void LassoThrow(int i, PlayerPawn pmo, int hand)
	{
		int o = i * NP;
		Vector3 tv = wp[o + NN] - ToRoom(wt[o + NN]);
		double sp = tv.Length();
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LASSO let go t%d tip speed %.1f%s", i, level.maptime, sp, sp < LASSO_MIN ? " (too slow: it drops)" : "");
		if (sp < LASSO_MIN || reachTic[i] > 0) return;
		Vector3 dir = ToMap(tv);
		if (dir.xy.Length() < 0.01) return;
		dir = (dir.xy.Unit(), 0);
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		double reach = min(LOCK_RANGE, wlen[i] * 2);
		Actor best = null;
		double bestA = 25.0;
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, reach, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || a.Health <= 0 || !a.bSHOOTABLE || a.bNONSHOOTABLE || a.bMISSILE || !a.bISMONSTER) continue;
			Vector3 to = a.pos + (0, 0, a.height * 0.5) - org;
			double d = to.xy.Length();
			if (d < 8 || d > reach + a.radius) continue;
			double ang = acos(clamp((to.xy / d) dot dir.xy, -1.0, 1.0)) - atan2(a.radius, d);
			if (ang > bestA || !pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			best = a; bestA = ang;
		}
		reachFor[i] = best;
		reachPt[i] = best ? best.pos + (0, 0, best.height * 0.6) : org + dir * (wlen[i] / PS);
		reachTic[i] = REACH_TICS;
		Noise(pmo, 'swish', org);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LASSO thrown -> %s", i, best ? String.Format("%s", best.GetClassName()) : "the air");
	}

	// A locked crack's flight: the thong pays out to the target over REACH_TICS (its length grows
	// to the distance and the outer links are drawn along the line to it, the physics doing the
	// rest), and strikes there: a monster takes the full crack (and, with the whip bind still
	// held and Whip Leash on, is caught on core's line and pulled), a pickup is flicked to you, a
	// switch is thrown. Then the thong comes back to its own length.
	void Reach(int i, PlayerPawn pmo, int hand)
	{
		if (reachTic[i] <= 0)
		{
			if (!wrapOn[i] && wlen[i] > baseLen[i]) wlen[i] = max(baseLen[i], wlen[i] - 24);
			return;
		}
		if (reachFor[i] && !reachFor[i].bDestroyed) reachPt[i] = reachFor[i].pos + (0, 0, reachFor[i].height * 0.6);
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 roomTo = ToRoom(reachPt[i]) - ToRoom(org);
		double dist = roomTo.Length();
		wlen[i] = max(baseLen[i], dist + 8);
		double f = 1.0 - double(reachTic[i] - 1) / REACH_TICS;    // 0.2 .. 1.0
		int o = i * NP;
		// lay the outer half along the line to the target, the tip at f of the way
		for (int k = NN / 2; k < NP; k++)
		{
			double u = double(k - NN / 2) / (NN - NN / 2);
			Vector3 want = ToRoom(org) + roomTo * (f * (0.5 + 0.5 * u));
			wq[o + k] = wp[o + k];
			wp[o + k] = wp[o + k] + (want - wp[o + k]) * 0.6;
		}
		reachTic[i]--;
		if (reachTic[i] > 0) return;
		// arrival
		Vector3 at = reachPt[i];
		let v = reachFor[i];
		reachFor[i] = null;
		if (!v && !lockLine[i] && wmode[i] == 1)
		{
			// Assist's lash into the air: an ordinary crack at the end of it
			Crack(i, pmo, hand, at, roomTo / max(1.0, dist) * 30);
			return;
		}
		Noise(pmo, 'crack', at);
		RSQWP_Looks.Spark(at, 'crack');
		Buzz(pmo, hand, 1.0, 5);
		let inv = Inventory(v);
		if (inv && !inv.Owner)
		{
			let mark = Actor.Spawn("RSQWP_WhipTip", inv.pos, NO_REPLACE);
			if (mark) Fetch(pmo, mark, 8 + inv.radius);
		}
		else if (v && v.Health > 0)
		{
			tipSpd[i] = max(tipSpd[i], RSQWP_Util.Num("rsqwp_whip_crack", 20));
			Hit(i, pmo, hand, v, at, tipSpd[i], true);
			if (byWeapon[i] && v && v.Health > 0 && v.bISMONSTER)
			{
				// the whip weapon: it wraps round the monster and waits for the pull (HoldWrap)
				wrapOn[i] = v; wrapUntil[i] = level.maptime + WRAP_TICS; pullHad[i] = false; pullPk[i] = 0;
			}
			else if (v && v.Health > 0 && v.bISMONSTER && RSQWP_Util.Flag("rsqwp_whip_leash", true) && BindHeld(pmo, hand)) Leash(i, pmo, hand, v, at);
		}
		else if (!v && RSQWP_Util.Flag("rsqwp_whip_lines", true))
		{
			Switches(pmo, at, 24);
		}
	}

	// ASSIST's lash: thrown for you, along where the hand points, the way a locked crack flies
	// (Reach): to the monster nearest that line within 15 degrees and the whip's length (a
	// little more), else to full length in the air, where it cracks (Crack: Assist's reach round
	// the tip, switches, pickups).
	void Throw(int i, PlayerPawn pmo, int hand)
	{
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, hand), RSQWP_Util.HandPitch(pmo, hand));
		double reach = wlen[i] * 1.1;
		Actor best = null;
		double bestA = 15.0;
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, reach, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || a.Health <= 0 || !a.bSHOOTABLE || a.bNONSHOOTABLE || a.bMISSILE || !a.bISMONSTER) continue;
			Vector3 to = a.pos + (0, 0, a.height * 0.5) - org;
			double d = to.Length();
			if (d < 8 || d > reach + a.radius) continue;
			double ang = acos(clamp((to / d) dot dir, -1.0, 1.0)) - atan2(a.radius, d);
			if (ang > bestA || !pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			best = a; bestA = ang;
		}
		reachFor[i] = best;
		if (best) reachPt[i] = best.pos + (0, 0, best.height * 0.6);
		else
		{
			// full length, or the wall first
			let tr = GetTracer();
			tr.shooter = pmo;
			double len = wlen[i] / PS * 0.9 + (wlen[i] * 0.9 - wlen[i] / PS * 0.9) * (1 - abs(dir.z));   // map units, near enough
			if (tr.Trace(org, level.PointInSector(org.xy), dir, len, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType != TRACE_HitNone)
				len = max(8.0, tr.Results.Distance - 4);
			reachPt[i] = org + dir * len;
		}
		reachTic[i] = REACH_TICS;
	}

	// Is this player's whip bind still down? (core keeps it: held[] from press to release)
	static bool BindHeld(PlayerPawn pmo, int hand)
	{
		let core = RSQWP_Core.Get();
		if (!core || !pmo || !pmo.player) return false;
		return core.held[pmo.PlayerNumber() * 2 + hand];
	}

	// The leash: core's own hook, built bitten into the monster exactly as core's Fly does when a
	// claw hits a thing, so the pull, the yank, the weight test and letting go are all core's.
	// The whip goes back into the hand.
	void Leash(int i, PlayerPawn pmo, int hand, Actor v, Vector3 at)
	{
		let core = RSQWP_Core.Get();
		if (!core || core.hooks[i]) return;
		let h = RSQWP_Hook(Actor.Spawn("RSQWP_Hook", at, NO_REPLACE));
		if (!h) return;
		Vector3 hand0 = RSQWP_Util.HandPos(pmo, hand);
		Vector3 ldir = (at - hand0).Unit();
		h.owner = pmo; h.hand = hand; h.dir = ldir;
		h.speed = max(4.0, RSQWP_Util.Num("rsqwp_speed", 40));
		h.range = max(64.0, RSQWP_Util.Num("rsqwp_range", 1024));
		h.angle = atan2(ldir.y, ldir.x);
		h.traveled = (at - hand0).Length();
		h.whipped = true;
		core.hooks[i] = h;
		h.SetOrigin(at, true);
		h.victim = v;
		Vector3 ofs = at - v.Pos;
		ofs.xy = ofs.xy.Length() > v.radius ? ofs.xy.Unit() * v.radius : ofs.xy;
		ofs.z = clamp(ofs.z, 0, v.Height);
		h.victimOfs = ofs;
		h.heavy = RSQWP_Core.TooHeavy(h, v);
		if (h.heavy)
		{
			h.anchor = v.Pos + h.victimOfs;
			core.Latch(h, i);
		}
		else
		{
			Vector3 dv = v.Pos - pmo.Pos;
			h.bestDist = dv.xy.Length();
			h.noProgress = 0;
			h.SetPhase(RSQWP_Hook.PH_BITE);
			RSQWP_Monster.OnHooked(v, pmo, hand, at);
		}
		RSQWP_Events.Bitten(pmo, v, hand, h.heavy);
		RSQWP_Perks.OnBite(h, v);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LEASH t%d %s (%s) -> core's line", i, level.maptime, v.GetClassName(), h.heavy ? "too heavy: an anchor" : "comes to you");
		Halt(i);
	}

	// An edge within WRAP of the crack: a two-sided line the tip is beside (in 2D), with a lintel
	// just above the tip or a ledge lip just below it. The nearest one is snagged.
	const WRAP = 12.0;
	bool WrapNear(int i, PlayerPawn pmo, int hand, Vector3 at)
	{
		let it = BlockLinesIterator.CreateFromPos(at, 64, WRAP + 8);
		Line best = null;
		double bestD = WRAP, bestZ = 0;
		Vector2 bestP;
		while (it.Next())
		{
			Line l = it.CurLine;
			if (!l || !l.frontsector || !l.backsector) continue;
			Vector2 a = l.v1.p, d = l.delta;
			double len2 = d dot d;
			if (len2 <= 0) continue;
			double t = clamp(((at.xy - a) dot d) / len2, 0.0, 1.0);
			Vector2 p = a + d * t;
			double dist = (at.xy - p).Length();
			if (dist > bestD) continue;
			double openTop = min(l.frontsector.ceilingplane.ZatPoint(p), l.backsector.ceilingplane.ZatPoint(p));
			double openBot = max(l.frontsector.floorplane.ZatPoint(p), l.backsector.floorplane.ZatPoint(p));
			if (openTop - openBot < 4) continue;
			double fullTop = max(l.frontsector.ceilingplane.ZatPoint(p), l.backsector.ceilingplane.ZatPoint(p));
			double fullBot = min(l.frontsector.floorplane.ZatPoint(p), l.backsector.floorplane.ZatPoint(p));
			double z = 0;
			bool ok = false;
			if (fullTop - openTop > 4 && abs(at.z - openTop) <= WRAP) { z = openTop - 1; ok = true; }        // a lintel or beam
			else if (openBot - fullBot > 4 && abs(at.z - openBot) <= WRAP) { z = openBot + 1; ok = true; }   // a ledge's lip
			if (!ok) continue;
			best = l; bestD = dist; bestZ = z; bestP = p;
		}
		if (!best) return false;
		// which way the whip came at it: from the hand's side of the line
		Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
		Vector2 toLine = bestP - h0.xy;
		Vector3 dir = toLine.Length() > 0.01 ? (toLine.Unit(), 0) : (1, 0, 0);
		Sector sec = level.PointOnLineSide(h0.xy, best) == 0 ? best.backsector : best.frontsector;
		// the wall it wraps: the face just above (a beam) or just below (a lip) the corner
		Vector3 struck = (bestP.x, bestP.y, bestZ > at.z ? bestZ + 4 : bestZ - 4);
		if (bestZ > (best.frontsector.floorplane.ZatPoint(bestP) + best.backsector.floorplane.ZatPoint(bestP)) * 0.5 + 8
			&& bestZ < min(best.frontsector.ceilingplane.ZatPoint(bestP), best.backsector.ceilingplane.ZatPoint(bestP)))
			struck.z = bestZ + 4;            // a beam: its face is above the corner
		else struck.z = bestZ - 4;           // a lip: its face is below
		return Snag(i, pmo, hand, (bestP.x, bestP.y, bestZ), dir, sec, struck);
	}

	// Something a whip can wrap round: an EDGE, not a flat wall. A two-sided line hit just under
	// its lintel (the top of the opening: a doorway's head, a beam) or just under its ledge lip
	// (the top of a step or a ledge), or a 3D floor's side near its top. A plain wall, a floor or
	// a ceiling has nothing to wrap round, and a crack against it just cracks.
	//
	// Returns the edge's height too: the whip wraps ROUND the edge, so the line's anchor goes on
	// the corner itself (a lintel's underside, a lip's top) -- not on the face it struck, where a
	// body swinging under a beam would lose sight of it and the rope would slip.
	static bool, double Edge(RSQWP_Tracer tr, Vector3 at)
	{
		if (tr.Results.HitType != TRACE_HitWall) return false, 0;
		if (tr.Results.ffloor)
		{
			double top = tr.Results.ffloor.top.ZatPoint(at.xy);
			return at.z <= top + 1 && top - at.z <= 16, top + 1;
		}
		Line l = tr.Results.HitLine;
		if (!l || !l.frontsector || !l.backsector) return false, 0;
		double openTop = min(l.frontsector.ceilingplane.ZatPoint(at.xy), l.backsector.ceilingplane.ZatPoint(at.xy));
		double openBot = max(l.frontsector.floorplane.ZatPoint(at.xy), l.backsector.floorplane.ZatPoint(at.xy));
		if (openTop - openBot < 4) return false, 0;                         // a closed door is a wall
		if (at.z >= openTop - 1) return at.z - openTop <= 24, openTop - 1;   // under a lintel or beam
		if (at.z <= openBot + 1) return openBot - at.z <= 16, openBot + 1;   // just under a ledge's lip
		return false, 0;
	}

	// The tic's fastest tip: the swish as it loads, and the crack AT THE PEAK -- once the tip has
	// passed the crack speed, the crack waits for the tic its speed turns down, and happens where
	// the tip was fastest: where the loop arrived. A throw can crack twice (on a hard lift as well
	// as on the snap, as a real one does): after a crack it re-arms once the tip has dropped below
	// 70% of that crack's speed.
	void Lash(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 vel)
	{
		double crackSpd = max(4.0, RSQWP_Util.Num("rsqwp_whip_crack", 20));
		double sp = tipSpd[i];
		if (RSQWP_Util.Opt("rsqwp_debug", 0) >= 2)
			Console.Printf("T_WPW %d t%d tip %.1f armed %d ext %.2f full %d hand %.1f pend %d tip(%.1f %.1f %.1f) ms %.3f", i, level.maptime, sp, armed[i], wext[i], fullTics[i], handSpd[i], pend[i], at.x, at.y, at.z, tickMs);
		if (lassoOn[i]) { pend[i] = false; return; }
		if (sp >= crackSpd * 0.55 && !swished[i] && wext[i] > 0.7)
		{
			swished[i] = true;
			Noise(pmo, 'swish', at);
		}
		if (pend[i])
		{
			if (sp > pkSpd[i]) { pkSpd[i] = sp; pkAt[i] = at; pkVel[i] = vel; return; }
			pend[i] = false;
			armed[i] = false;
			rearm[i] = pkSpd[i] * 0.7;
			crackTic[i] = level.maptime;
			tipSpd[i] = pkSpd[i];
			Crack(i, pmo, hand, pkAt[i], pkVel[i]);
			return;
		}
		if (armed[i] && sp >= crackSpd && fullTics[i] >= 4 && wstate[i] == ST_OUT && handSpd[i] >= 2.0)
		{
			pend[i] = true; pkSpd[i] = sp; pkAt[i] = at; pkVel[i] = vel;
			return;
		}
		if (!armed[i] && sp < rearm[i] && level.maptime - crackTic[i] >= 3) armed[i] = true;
		if (sp < crackSpd * 0.45) { if (++calm[i] >= 3) { armed[i] = true; swished[i] = false; } }
		else calm[i] = 0;
	}

	RSQWP_Tracer GetTracer()
	{
		if (!tracer) tracer = new("RSQWP_Tracer");
		return tracer;
	}

	// THE ARM PUMP (rsqwp_arm_pump). Swinging on the whip (a snag: core's line, drawn as the whip),
	// haul down on it -- the whip hand moving away from the anchor, relative to the body, as you
	// pull yourself up a rope -- and the swing gains speed along the way it is going, as a kick on
	// a rope swing does. Capped per tic and by core's top speed; only in the air, only moving.
	// Runs after core's tic, so core reads it next tic as a push, as it does the stick's pump.
	void ArmPump()
	{
		double k = RSQWP_Util.Num("rsqwp_arm_pump", 0.12);
		let core = RSQWP_Core.Get();
		for (int i = 0; i < NW; i++)
		{
			let pmo = players[i / 2].mo;
			let h = core ? core.hooks[i] : null;
			if (k <= 0 || !playeringame[i / 2] || !pmo || !h || !h.whipped || h.phase != RSQWP_Hook.PH_LATCH || h.owner != pmo)
			{
				pumpHad[i] = false;
				continue;
			}
			int hand = i & 1;
			Vector3 off = RSQWP_Util.HandPos(pmo, hand) - pmo.pos;
			bool had = pumpHad[i];
			Vector3 d = off - pumpOff[i];
			pumpOff[i] = off; pumpHad[i] = true;
			if (!had || d.Length() > 24) continue;
			bool air = pmo.pos.z > pmo.floorz + 0.5 && !pmo.bOnMobj;
			double sp = pmo.vel.Length();
			if (!air || sp < 3) continue;
			Vector3 toA = h.anchor - RSQWP_Util.HandPos(pmo, hand);
			double la = toA.Length();
			if (la < 1) continue;
			double pull = -(d dot (toA / la));          // the hand going away from the anchor: a haul
			if (pull <= 1.0) continue;
			double add = min(0.8, pull * k);
			pmo.vel += pmo.vel / sp * add;
			double top = RSQWP_Util.Num("rsqwp_max_speed", 30);
			if (top > 0 && pmo.vel.Length() > top) pmo.vel *= top / pmo.vel.Length();
			if (RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d PUMP t%d haul %.1f +%.2f -> speed %.1f", i, level.maptime, pull, add, pmo.vel.Length());
		}
	}

	// THE MANTLE (rsqwp_mantle). On a line (whip or hook) caught on a LEDGE LIP -- the anchor near
	// the top of a wall whose far side is a floor he fits on -- he goes up and over it, by physics
	// (no teleport): reeled or climbed until the lip is about at his chest, or a free hand on the
	// Grab bind laid on the lip (within GRAB_LIP of the anchor) while the lip is in an arm's reach
	// of his feet. He is given exactly the upward speed that clears the lip (v = sqrt(2 g h), a
	// little over), the line lets go, and once he is above the lip he is carried forward onto the
	// top until his body is past the edge (player.keepmomentum keeps the push through the landing).
	const GRAB_LIP = 20.0;

	void Mantle()
	{
		let core = RSQWP_Core.Get();
		if (!core) return;
		bool on = RSQWP_Util.Flag("rsqwp_mantle", true);
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.Health <= 0) { mantleTic[pn] = 0; continue; }
			if (mantleTic[pn] > 0)
			{
				// carrying him over: rising until above the top, then forward until past the lip
				mantleTic[pn]--;
				pmo.player.keepmomentum = true;
				if (pmo.pos.z >= mantleTop[pn] - 0.5)
				{
					Vector2 past = mantleLip[pn] + mantleFwd[pn] * (pmo.radius + 6);
					if ((past - pmo.pos.xy) dot mantleFwd[pn] > 0)
						pmo.vel.xy = mantleFwd[pn] * 5;
					else { pmo.vel.xy *= 0.5; mantleTic[pn] = 0; }
				}
				continue;
			}
			if (!on) continue;
			for (int hand = 0; hand < 2; hand++)
			{
				int i = pn * 2 + hand;
				let h = core.hooks[i];
				if (!h || h.phase != RSQWP_Hook.PH_LATCH || h.owner != pmo || h.anchorPlane != 0 || h.heavy) continue;
				// the far side of the wall the anchor is on: a floor near the anchor's height, with room
				Vector2 fwd = h.hitDir.xy;
				if (fwd.Length() < 0.01) continue;
				fwd = fwd.Unit();
				Vector2 beyond = h.anchor.xy + fwd * 12;
				let sec = level.PointInSector(beyond);
				double top = sec.floorplane.ZatPoint(beyond);
				double room = sec.ceilingplane.ZatPoint(beyond) - top;
				if (top < h.anchor.z - 32 || top > h.anchor.z + 24 || room < pmo.height) continue;
				if (top <= pmo.pos.z + 4) continue;                       // nothing to climb onto
				// reeled or climbed up to it: the lip at his chest
				// (or reeled all the way in: the rope at its shortest, the lip just over his head)
				bool reached = (pmo.pos.z + pmo.height * 0.7 >= top && (pmo.pos.xy - h.anchor.xy).Length() <= pmo.radius + 28)
					|| ((RSQWP_Core.AttachPoint(pmo) - h.anchor).Length() <= RSQWP_Util.Num("rsqwp_min_len", 32) + 10 && top - pmo.pos.z <= pmo.height + 24);
				// or a free hand laid on the lip
				bool grabbed = false;
				for (int gh = 0; gh < 2; gh++)
				{
					if (!core.grabHeld[pn * 2 + gh]) continue;
					if ((RSQWP_Util.HandPos(pmo, gh) - h.anchor).Length() <= GRAB_LIP && top - pmo.pos.z <= pmo.height + 14) grabbed = true;
				}
				if (!reached && !grabbed) continue;
				double rise = top - pmo.pos.z + 3;
				double g = max(0.01, pmo.GetGravity());
				pmo.vel.z = sqrt(2 * g * rise) + 0.5;
				pmo.vel.xy = (0, 0);
				mantleTic[pn] = 35;
				mantleTop[pn] = top;
				mantleFwd[pn] = fwd;
				mantleLip[pn] = h.anchor.xy;
				pmo.player.keepmomentum = true;
				core.LetGo(h, false);
				Buzz(pmo, hand, 0.5, 4);
				if (RSQWP_Util.Flag("rsqwp_debug", false))
					Console.Printf("T_WPW MANTLE t%d player %d %s: from z %.0f onto %.0f (rise %.0f, vz %.1f)", level.maptime, pn, grabbed ? "hand on the lip" : "reeled up", pmo.pos.z, top, rise, pmo.vel.z);
				break;
			}
		}
	}

	// ---- what it does -----------------------------------------------------------------------

	// The thing a lash touched. A fast link stings (part of the damage, by speed); the crack
	// is the full blow and the stun.
	void Hit(int i, PlayerPawn pmo, int hand, Actor v, Vector3 at, double spd, bool crack)
	{
		if (!v || v == pmo || v.Health <= 0 || !v.bSHOOTABLE || v.bNONSHOOTABLE) return;
		// once per thing per lash: a sting once per 12 tics, the crack once (it may follow a sting)
		for (int k = 0; k < 4; k++)
			if (whit[i * 4 + k] == v && level.maptime - whitTic[i * 4 + k] < 12 && (!crack || whitCrack[i * 4 + k])) return;
		int slot = 0;
		for (int k = 1; k < 4; k++) if (whitTic[i * 4 + k] < whitTic[i * 4 + slot]) slot = k;
		whit[i * 4 + slot] = v; whitTic[i * 4 + slot] = level.maptime; whitCrack[i * 4 + slot] = crack;
		double crackSpd = max(4.0, RSQWP_Util.Num("rsqwp_whip_crack", 20));
		double maxDmg = RSQWP_Util.Opt("rsqwp_whip_damage", 12);
		int dmg = crack ? int(maxDmg) : int(maxDmg * clamp(spd / crackSpd, 0.15, 0.5) + 0.5);
		int hp0 = v.Health;
		if (dmg > 0) { RSQWP_Events.Whipped(v, pmo); RSQWP_Perks.Hurt(v, pmo, pmo, dmg, 'Melee'); }
		bool stunned = false;
		if (crack && v && v.Health > 0 && v.bISMONSTER && RSQWP_Util.Flag("rsqwp_whip_stun", true))
		{
			State pain = v.FindState("Pain");
			if (pain && !v.InStateSequence(v.CurState, pain)) { v.SetState(pain); stunned = true; }
			else stunned = pain != null;
		}
		String s = RSQWP_Looks.Sound('hitflesh');
		if (s != "") { let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE); if (c) c.A_StartSound(s, CHAN_VOICE, 0, crack ? 1.0 : 0.6); }
		if (crack) RSQWP_Looks.Spark(at, 'flesh');
		Buzz(pmo, hand, crack ? 0.8 : 0.35, crack ? 6 : 3);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d %s %s at speed %.1f: hp %d -> %d, pain %d", i, crack ? "CRACK hit" : "sting", v ? v.GetClassName() : 'gone', spd, hp0, v ? v.Health : 0, stunned);
	}

	void Crack(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 vel)
	{
		cracks[i]++;
		lashUntil[i] = level.maptime + 8;
		if ((RSQWP_Util.Opt("rsqwp_whip_aim", 1) == 2 || byWeapon[i]) && (lockOn[i] || lockLine[i]) && lockLeft[i] > 0)
		{
			// LOCK: the crack sends the thong out to the target, however far (up to the lock's
			// range): it pays out over REACH_TICS and strikes on arrival (Reach)
			reachFor[i] = lockOn[i];
			reachPt[i] = lockOn[i] ? lockOn[i].pos + (0, 0, lockOn[i].height * 0.6) : lockAt[i];
			reachTic[i] = REACH_TICS;
			Noise(pmo, 'crack', at);
			Buzz(pmo, hand, 1.0, 5);
			if (RSQWP_Util.Flag("rsqwp_debug", false))
			{
				Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
				Console.Printf("T_WPW %d CRACK #%d t%d LOCKED -> %s at %.0f units", i, cracks[i], level.maptime,
					lockOn[i] ? lockOn[i].GetClassName() : 'line', (reachPt[i] - h0).Length());
			}
			lockLeft[i] = 0; lockOn[i] = null; lockLine[i] = false;
			return;
		}

		Noise(pmo, 'crack', at);
		RSQWP_Looks.Spark(at, 'crack');
		Buzz(pmo, hand, 1.0, 5);
		bool dbg = RSQWP_Util.Flag("rsqwp_debug", false);
		bool assist = RSQWP_Util.Opt("rsqwp_whip_aim", 1) == 1;
		double reach = assist ? max(8.0, RSQWP_Util.Num("rsqwp_whip_assist", 40)) : 12.0;
		Vector3 vdir = vel.Length() > 0.01 ? ToMap(vel).Unit() : (0, 0, 0);

		// a crack right by an EDGE above the hand (a beam's underside, a ledge's lip) wraps round it,
		// as a tip hitting it would: the loop arriving next to a beam throws the popper over it
		if (RSQWP_Util.Flag("rsqwp_whip_snag", true) && wstate[i] == ST_OUT && wmode[i] == 0)
		{
			Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
			if (at.z > h0.z + RSQWP_Util.Num("rsqwp_whip_above", 16) && WrapNear(i, pmo, hand, at)) return;
		}

		// the thing it cracks on: nearest the tip within reach (Free: touching it), and the tip
		// must see it (no cracking through a wall)
		let mark = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		Actor best = null;
		double bestD = reach;
		if (mark)
		{
			let it = BlockThingsIterator.Create(mark, reach + 64);
			while (it.Next())
			{
				let a = it.thing;
				if (!a || a == pmo || a.player || a.Health <= 0 || !a.bSHOOTABLE || a.bNONSHOOTABLE || a.bMISSILE) continue;
				if (a is "RSQWP_Rope" || a is "RSQWP_Hook" || a is "RSQWP_WhipTip") continue;
				// distance from the tip to the thing's body (a cylinder)
				Vector2 dxy = a.pos.xy - at.xy;
				double hd2 = max(0.0, dxy.Length() - a.radius);
				double vz = at.z < a.pos.z ? a.pos.z - at.z : (at.z > a.pos.z + a.height ? at.z - a.pos.z - a.height : 0);
				double dist = sqrt(hd2 * hd2 + vz * vz);
				if (dist > bestD) continue;
				if (!mark.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
				best = a; bestD = dist;
			}
		}
		if (best) Hit(i, pmo, hand, best, at, tipSpd[i], true);

		// a switch (or any line you could use) the crack lands on
		int lines = 0;
		if (RSQWP_Util.Flag("rsqwp_whip_lines", true)) lines = Switches(pmo, at, reach);
		// a loose pickup within reach is flicked to you
		int fetched = 0;
		if (RSQWP_Util.Flag("rsqwp_whip_fetch", true) && mark) fetched = Fetch(pmo, mark, reach * 1.5);
		if (dbg) Console.Printf("T_WPW %d CRACK #%d t%d speed %.1f at (%.0f %.0f %.0f) %.0f from the hand: target %s, lines %d, fetched %d",
			i, cracks[i], level.maptime, tipSpd[i], at.x, at.y, at.z, (at - ToMap(hb[i])).Length(), best ? best.GetClassName() : 'none', lines, fetched);
	}

	// Lines with a use (or impact) special whose wall the tip is within reach of: thrown, as if
	// the player had pressed them -- locks still ask for their key.
	int Switches(PlayerPawn pmo, Vector3 at, double reach)
	{
		int n = 0;
		let it = BlockLinesIterator.CreateFromPos(at, 64, reach);
		while (it.Next())
		{
			Line l = it.CurLine;
			if (!l || !l.special || !(l.activation & (SPAC_Use | SPAC_Impact | SPAC_UseThrough))) continue;
			// distance from the tip to the line, in 2D
			Vector2 a = l.v1.p, d = l.delta;
			double len2 = d dot d;
			double t = len2 > 0 ? clamp(((at.xy - a) dot d) / len2, 0.0, 1.0) : 0.0;
			if ((at.xy - (a + d * t)).Length() > reach) continue;
			int side = level.PointOnLineSide(pmo.pos.xy, l);
			int type = (l.activation & SPAC_Impact) ? SPAC_Impact : ((l.activation & SPAC_UseThrough) ? SPAC_UseThrough : SPAC_Use);
			if (l.Activate(pmo, side, type)) n++;
		}
		return n;
	}

	// Pickups lying loose near the crack fly to the player on an arc that lands on him.
	int Fetch(PlayerPawn pmo, Actor mark, double reach)
	{
		int n = 0;
		let it = BlockThingsIterator.Create(mark, reach);
		while (it.Next())
		{
			let inv = Inventory(it.thing);
			if (!inv || inv.Owner || !inv.bSPECIAL) continue;
			if ((inv.pos - mark.pos).Length() > reach) continue;
			Vector3 to = (pmo.pos.x, pmo.pos.y, pmo.pos.z + pmo.height * 0.4) - inv.pos;
			double T = 16;
			double g = level.gravity * inv.Gravity / 800.0;
			if (inv.bNOGRAVITY) g = 0;
			inv.vel = (to.x / T, to.y / T, to.z / T + 0.5 * g * T);
			n++;
		}
		return n;
	}

	// Core's hook, built as a claw that hit this spot would have been (core.zs Fly's geometry
	// branch), then handed to core's own Latch(): the whip's tip wrapped round it.
	private bool Snag(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 dir, Sector sec, Vector3 struck)
	{
		let core = RSQWP_Core.Get();
		if (!core || core.hooks[i]) return false;
		let h = RSQWP_Hook(Actor.Spawn("RSQWP_Hook", at, NO_REPLACE));
		if (!h) return false;
		Vector3 hand0 = RSQWP_Util.HandPos(pmo, hand);
		Vector3 ldir = (at - hand0).Unit();
		h.owner = pmo;
		h.hand = hand;
		h.dir = ldir;
		h.speed = max(4.0, RSQWP_Util.Num("rsqwp_speed", 40));
		h.range = max(64.0, RSQWP_Util.Num("rsqwp_range", 1024));
		h.angle = atan2(ldir.y, ldir.x);
		h.traveled = (at - hand0).Length();
		h.anchor = at - (dir.xy.Length() > 0.01 ? (dir.xy.Unit() * 0.5, 0) : (0, 0, 0));   // on the corner, a hair on the near side
		h.hitDir = (dir.xy.Length() > 0.01 ? (dir.xy.Unit(), 0) : ldir);
		h.SetOrigin(h.anchor, true);
		h.anchorSec = sec;
		h.anchorPlane = 0;              // an edge is a wall's: core checks the wall is still there
		h.whipped = true;
		h.struck = struck - h.hitDir * 0.5;
		core.hooks[i] = h;
		core.Latch(h, i);
		Noise(pmo, 'crack', at);
		Buzz(pmo, hand, 0.7, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d SNAG t%d at (%.0f %.0f %.0f), %.0f above the hand -> core's rope", i, level.maptime, at.x, at.y, at.z, at.z - hand0.z);
		Halt(i);
		return true;
	}

	// ---- looks ------------------------------------------------------------------------------

	// The whip's own sounds (gen_whip.py), at a point, through a tiny actor that carries them.
	void Noise(PlayerPawn pmo, Name what, Vector3 at)
	{
		String s;
		double vol = 1.0;
		if (what == 'crack') s = "rsqwp/whip/crack";
		else if (what == 'swish') { s = "rsqwp/whip/swish"; vol = 0.7; }
		else if (what == 'unfurl') { s = "rsqwp/whip/unfurl"; vol = 0.45; }
		if (s == "") return;
		let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		if (c) c.A_StartSound(s, CHAN_VOICE, 0, vol);
	}

	// A pulse in the hand holding the whip (the series' route: RSQ ShieldSaw's QF_WAVE quake,
	// felt with vr_quake_haptic_level > 0).
	void Buzz(PlayerPawn pmo, int hand, double amp, int tics)
	{
		if (!pmo || !pmo.player || pmo.player != players[consoleplayer]) return;
		let q = RSQWP_WhipBuzz(Actor.Spawn("RSQWP_WhipBuzz", pmo.pos, NO_REPLACE));
		if (!q) return;
		let cv = CVar.FindCVar('vr_control_scheme');
		bool leftHanded = cv && cv.GetInt() >= 10;
		bool right = (hand == 0) != leftHanded;
		q.feels = pmo; q.left = !right; q.amp = amp; q.total = tics; q.tleft = tics;
	}

	// The handle and the plaited thong: core's rope tube (rsqrope.md3) in the whip's skins,
	// tapering from the handle to the popper.
	void Draw(int i)
	{
		int o = i * NP;
		double w0 = RSQWP_Util.Num("rsqwp_rope_width", 0.6) * 1.15;
		Vector3 base = ToMap(hb[i]);
		for (int k = 0; k < NP; k++)
		{
			Vector3 pa = k == 0 ? base : ToMap(wp[o + k - 1]);
			Vector3 pb = ToMap(wp[o + k]);
			double w = k == 0 ? 0.69 * 1.7 : w0 * max(0.18, 1.0 - 0.8 * (k - 1.0) / NN);   // the handle keeps its size whatever the thong's thickness
			RSQWP_Rope r = wl[o + k];
			bool fresh = false;
			if (!r)
			{
				r = RSQWP_Rope(Actor.Spawn(k == 0 ? "RSQWP_WhipHandle" : "RSQWP_WhipLink", pa, NO_REPLACE));
				wl[o + k] = r;
				fresh = true;
			}
			if (!r) continue;
			if (!fresh) r.SetOrigin(pa, true);
			Vector3 room = ToRoom(pb - pa);
			double l = room.Length();
			if (l < 0.01) { r.scale = (w, 0.001); continue; }
			r.angle = atan2(room.y, room.x);
			r.pitch = -atan2(room.z, room.xy.Length()) + 90;
			r.scale = (w, l / RSQWP_Rope.ROPE_L);
			if (fresh) r.ClearInterpolation();
		}
	}

	void Halt(int i)
	{
		wstate[i] = ST_IDLE;
		byWeapon[i] = false; wrapOn[i] = null; lassoOn[i] = false; lassoWas[i] = false; markHeld[i] = false; markLine[i] = null;
		wby[i] = null;
		lockOn[i] = null; lockLine[i] = false; lockLeft[i] = 0; lockHeld[i] = false; reachTic[i] = 0; reachFor[i] = null;
		for (int k = 0; k < NP; k++)
		{
			if (wl[i * NP + k]) wl[i * NP + k].Destroy();
			wl[i * NP + k] = null;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < NW; i++) if (wstate[i] != ST_IDLE) Halt(i);
	}
}

// The thong's pieces and the handle: core's rope tube with the whip's skins (MODELDEF).
// Subclasses of RSQWP_Rope, so every tracer that skips the rope skips the whip.
class RSQWP_WhipLink : RSQWP_Rope {}
class RSQWP_WhipHandle : RSQWP_Rope {}

// Carries a sound at a point (the tip, the crack), then goes.
class RSQWP_WhipTip : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
	}
	States
	{
	Spawn:
		TNT1 A 90;
		Stop;
	}
}

// A pulse in one controller: X of a QF_WAVE quake drives the left, Y the right, faded over
// its length (RSQ ShieldSaw's SSQ_Buzzer; felt with vr_quake_haptic_level > 0).
class RSQWP_WhipBuzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;
	Default { +NOINTERACTION +NOBLOCKMAP +DONTSPLASH +NOTIMEFREEZE }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels || tleft <= 0) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		double a = amp * tleft / double(max(1, total)) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}
	States { Spawn: TNT1 A 40; Stop; }
}
