// THE WHIP'S TWO MOVES (owner 2026-11-27: "the whip is been conceptually cool but a huge pain in the ass. what i want is
// to do a big wide swing and damage + knockback + slomo in a nearly 120 arc on front of me, and if i crack down to the
// ground the impact sends out a shockwave and sends enemies airborne with contextual slowmo", and "i want to tone this
// thing down"). Both are read from the whip hand; no button is held or pressed for either:
//
//   WIDE SWING    a big wide level swing of the whip hand (the hand round the body through SWEEP_ARC degrees, fast,
//                 mostly level). Every monster in sight within SWEEP_REACH, in the 120 degrees in front of the swing
//                 (SWEEP_FAN either side of its middle), takes SWEEP_DMG, is knocked back and flinches; RSQ SlowMo
//                 is asked for slow motion when it hit something.
//   GROUND CRACK  a hard downward flick of the whip hand (fast down, then stopped). The thong flies to the floor where
//                 the hand's line meets it; the impact sends out a shockwave: every living hostile monster within
//                 SHOCK_M of it is thrown up into the air and outward and staggered, and RSQ SlowMo is asked for slow
//                 motion when it threw something. A boss or a monster of mass 1000 or more is staggered, not lifted.
//
// A SNAP TURN OR A HEAD TURN IS NEITHER (findings F1): the hand is measured against the body in the world's own axes
// (it was turned by the pawn's angle, which follows the headset, so a turn read as a fast hand), and the tic the
// tracking space turns, or the pawn's angle steps, is skipped with everything read before it (LashTick).
//
// The pointed crack at a monster, the snag (wrap, trip, interrupt, pin), the parry, the pickup fetch, the switch throw
// and Whip Style went the same day ("i want to tone this thing down"). Code only: not compiled, not run.
extend class RSQWP_Whip
{
	// ---- the numbers that were here before 2026-11-27, unchanged unless said --------------------------------------
	const FLICK_MPS = 1.6;        // the Ground Crack's flick: the hand at least this fast DOWNWARD (m/s, against the body) ...
	const FLICK_STOP = 0.4;       // ... then down to this part of that tic's speed within FLICK_WIN tics: the snap
	const FLICK_WIN = 4;
	const LASH_GAP = 8;           // tics between two moves
	const CRACK_REACH = 4.5;      // metres: how far along the hand's line the Ground Crack looks for the floor
	const SWEEP_ARC = 70.0;       // degrees of the hand round the body within SWEEP_WIN tics
	const SWEEP_WIN = 8;
	const SWEEP_MPS = 2.0;        // the hand's average speed through it
	const SWEEP_REACH = 2.6;      // metres: the arm and the thong
	const SWEEP_FAN = 60.0;       // degrees either side of the swing's middle: 120 in all (was 75; owner 2026-11-27: "a nearly 120 arc")
	const SWEEP_DMG = 8;
	const SWEEP_PUSH = 7.0;       // map units a tic, the Wide Swing's knockback; the shockwave's push outward too
	const HEAVY_MASS = 1000;      // from this mass a monster is not pushed or lifted (the sweep's rule, named)
	// ---- chosen 2026-11-27 (owner: "damage + knockback + slomo", "sends enemies airborne with contextual slowmo") ---
	const SWEEP_SLOW_MS = 500;    // the Wide Swing's slow motion, asked of RSQ SlowMo: half a second
	const SHOCK_M = 3.0;          // metres: the shockwave's radius round the impact
	const SHOCK_LIFT = 10.0;      // map units a tic upward (the engine's jump is 8): about 1.5 m into the air
	const SHOCK_SLOW_MS = 1000;   // the Ground Crack's slow motion: a second
	const TURN_SKIP = 20.0;       // degrees: the pawn's angle stepping more than this in one tic is a snap turn, not a head

	Vector3 lsRel[NW];            // the whip hand against the body, the world's axes, room units
	bool    lsHave[NW];
	double  lsSpd[NW * 8];        // the last 8 tics' speeds, m/s (ring)
	Vector3 lsVel[NW * 8];        // and velocities, m/s, the world's axes (z up)
	double  lsYaw[NW * 8];        // the hand's bearing round the body, degrees, the world's
	int     lsAt[NW];
	int     lsLast[NW];           // the tic of the last move
	double  lsAng[NW];            // the pawn's angle last tic

	static clearscope double M2U() { let c = CVar.FindCVar("vr_vunits_per_meter"); double v = c ? c.GetFloat() : 34; return v > 0 ? v : 34; }

	Vector3 LsVelAgo(int i, int ago) { return lsVel[i * 8 + (lsAt[i] - ago + 16) % 8]; }
	double  LsSpdAgo(int i, int ago) { return lsSpd[i * 8 + (lsAt[i] - ago + 16) % 8]; }
	double  LsYawAgo(int i, int ago) { return lsYaw[i * 8 + (lsAt[i] - ago + 16) % 8]; }

	// everything read of the hand so far is forgotten: the next tic only takes the hand's place
	void LsReset(int i)
	{
		lsHave[i] = false;
		for (int k = 0; k < 8; k++) { lsSpd[i * 8 + k] = 0; lsVel[i * 8 + k] = (0, 0, 0); lsYaw[i * 8 + k] = 0; }
	}

	// RSQ Gun Bonsai VR's Kill Rewards bits, by name (the whip loads without it): never a whip target.
	static clearscope bool NotATarget(Actor a)
	{
		if (!a) return true;
		String n = a.GetClassName();
		n = n.MakeLower();
		return n.IndexOf("rsq_kr") == 0;
	}

	// RSQ SLOWMO, BY NAME (owner 2026-11-27: "slomo", "contextual slowmo"): its service's own door for another mod
	// (RSQSM_Service "start": the reason, the hold in milliseconds, speed 0 = the player's own World Speed row). Found by
	// name as util.zs WorldScale finds it; nothing happens without RSQ SlowMo, or with its Other / Unknown Mods row off.
	static void AskSlow(int ms)
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service s;
		while (s = it.Next())
		{
			if (s.GetInt("start", "whip", ms, 0, null) >= 0) return;
		}
	}

	// into its Pain state (the sweep's flinch, the shockwave's stagger): whatever it was doing is broken off
	static void Stagger(Actor v)
	{
		State pain = v.FindState("Pain");
		if (pain && !v.InStateSequence(v.CurState, pain)) v.SetState(pain);
	}

	// ---- every tic, per whip (whip.zs WorldTick2) -------------------------------------------------------------------
	void LashTick(int i, PlayerPawn pmo, int hand)
	{
		Vector3 eye = pmo.pos + (0, 0, SteadyEye(pmo));
		// 2026-11-27 (findings F1; owner: a snap turn or a head turn must not trigger either move): the hand against the
		// body in the WORLD's axes. It was turned by minus the pawn's angle, and on QuestZDoom that angle follows the
		// headset, so turning the head put speed into a still hand.
		Vector3 rel = ToRoom(BodyHand(pmo, hand)) - ToRoom(eye);
		// ... and the tic the tracking space turns (a snap or stick turn: whip.zs TrackFrame, the Classic crack's guard),
		// or the pawn's angle steps by more than TURN_SKIP (the rig, 11-02: it took a 45 degree snap one tic before the
		// controllers did), is skipped, with every sample before it; no move for LASH_GAP tics after
		double step = lsHave[i] ? abs(Actor.DeltaAngle(lsAng[i], pmo.angle)) : 0.0;
		lsAng[i] = pmo.angle;
		if (turnTic[i / 2] == level.maptime || step > TURN_SKIP)
		{
			LsReset(i);
			lsLast[i] = level.maptime;
			return;
		}
		if (!lsHave[i]) { lsRel[i] = rel; lsHave[i] = true; return; }
		Vector3 d = rel - lsRel[i];
		lsRel[i] = rel;
		if (d.Length() > 24) return;   // a teleport or a pose jump, not an arm
		Vector3 v = d * TICRATE / M2U();
		lsAt[i] = (lsAt[i] + 1) % 8;
		lsVel[i * 8 + lsAt[i]] = v;
		lsSpd[i * 8 + lsAt[i]] = v.Length();
		lsYaw[i * 8 + lsAt[i]] = atan2(rel.y, rel.x);
		if (wstate[i] != ST_OUT || reachTic[i] > 0 || level.maptime - lsLast[i] < LASH_GAP) return;
		if (Sweep(i, pmo, hand)) return;
		GroundCrack(i, pmo, hand);
	}

	// THE WIDE SWING: the hand's bearing round the body has turned through SWEEP_ARC in SWEEP_WIN tics, fast and level
	// (the sweep's own test, unchanged). 2026-11-27 (owner: "damage + knockback + slomo in a nearly 120 arc on front of
	// me"): the fan is 60 degrees either side of the swing's middle, other mods are told before the damage (findings
	// F8), and RSQ SlowMo is asked when it hit something.
	bool Sweep(int i, PlayerPawn pmo, int hand)
	{
		double turned = 0, spd = 0, flat = 0, up = 0;
		for (int a = 0; a < SWEEP_WIN - 1; a++)
		{
			turned += Actor.DeltaAngle(LsYawAgo(i, a + 1), LsYawAgo(i, a));
			Vector3 v = LsVelAgo(i, a);
			spd += v.Length(); flat += v.xy.Length(); up += abs(v.z);
		}
		spd /= SWEEP_WIN - 1;
		if (abs(turned) < SWEEP_ARC || spd < SWEEP_MPS || up > flat * 0.6) return false;
		lsLast[i] = level.maptime;
		// the fan's middle: where the hand was halfway through (its bearing is the world's already)
		double mid = Actor.Normalize180(LsYawAgo(i, SWEEP_WIN / 2));
		double reach = SWEEP_REACH * M2U();
		int n = 0;
		let it = BlockThingsIterator.Create(pmo, reach);
		while (it.Next())
		{
			let v = it.thing;
			if (!v || v == pmo || v.player || v.Health <= 0 || !v.bSHOOTABLE || v.bNONSHOOTABLE || !v.bISMONSTER || NotATarget(v)) continue;
			Vector2 to = v.pos.xy - pmo.pos.xy;
			if (to.Length() - v.radius > reach) continue;
			if (abs(Actor.DeltaAngle(mid, atan2(to.y, to.x))) > SWEEP_FAN) continue;
			if (!pmo.CheckSight(v, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			RSQWP_Events.Whipped(v, pmo);   // noted BEFORE the blow (service.zs), so a scorer hearing the death reads it
			RSQWP_Perks.Hurt(v, pmo, pmo, SWEEP_DMG, DmgType(), DMG_THRUSTLESS);
			if (!v || v.bDestroyed || v.Health <= 0) { n++; continue; }
			Vector2 away = to.Length() > 0.01 ? to.Unit() : Actor.AngleToVector(mid, 1);
			if (!v.bDONTTHRUST && v.Mass < HEAVY_MASS) v.vel.xy += away * SWEEP_PUSH * clamp(400.0 / max(v.Mass, 50), 0.3, 2.0);
			Stagger(v);
			n++;
		}
		Noise(pmo, 'crack', pmo.pos + (Actor.AngleToVector(mid, reach * 0.7), SteadyEye(pmo) * 0.8));
		Buzz(pmo, hand, 0.9, 6);
		if (n > 0) AskSlow(SWEEP_SLOW_MS);
		if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d WIDE SWING t%d: %.0f degrees at %.1f m/s, middle %.0f, %d hit", i, level.maptime, turned, spd, mid, n);
		return true;
	}

	// THE GROUND CRACK (owner 2026-11-27: "if i crack down to the ground the impact sends out a shockwave"): a hard
	// downward flick. The flick reader's own numbers, read downward: the hand's fastest downward tic of the last
	// FLICK_WIN at FLICK_MPS or more, more down than across in that tic, and the hand now at FLICK_STOP of that tic's
	// speed or less. The thong then flies to the floor (whip.zs Reach) and lands REACH_TICS later (GroundImpact).
	bool GroundCrack(int i, PlayerPawn pmo, int hand)
	{
		double dn = 0;
		int at = 0;
		for (int a = 1; a <= FLICK_WIN; a++)
		{
			Vector3 va = LsVelAgo(i, a);
			double vz = -va.z;
			if (vz > dn) { dn = vz; at = a; }
		}
		if (dn < FLICK_MPS) return false;
		Vector3 pv = LsVelAgo(i, at);
		if (dn < pv.xy.Length()) return false;                      // across more than down: not a crack at the ground
		if (LsSpdAgo(i, 0) > pv.Length() * FLICK_STOP) return false;   // the hand has not stopped yet
		lsLast[i] = level.maptime;
		// WHERE IT LANDS: where the whip hand's line meets the floor within CRACK_REACH; if the line meets no floor
		// there (it ends in the air, or on a wall or a ceiling), the floor straight under where the line ends
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, hand), RSQWP_Util.HandPitch(pmo, hand));
		double reach = CRACK_REACH * M2U();
		let tr = GetTracer();
		tr.shooter = pmo;
		Vector3 pt = org + dir * reach;
		bool onFloor = false;
		if (tr.Trace(org, level.PointInSector(org.xy), dir, reach, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType != TRACE_HitNone)
		{
			onFloor = tr.Results.HitType == TRACE_HitFloor;
			pt = onFloor ? tr.Results.HitPos : org + dir * max(8.0, tr.Results.Distance - 4);
		}
		if (!onFloor)
		{
			if (tr.Trace(pt, level.PointInSector(pt.xy), (0, 0, -1), 4096, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType == TRACE_HitFloor)
				pt = tr.Results.HitPos;
			else
				pt = (pt.x, pt.y, level.PointInSector(pt.xy).floorplane.ZatPoint(pt.xy));
		}
		reachPt[i] = pt;
		reachTic[i] = REACH_TICS;
		Noise(pmo, 'swish', org);
		Buzz(pmo, hand, 0.6, 3);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d GROUND CRACK t%d: down %.1f m/s, now %.1f; the floor at (%.0f %.0f %.0f), %s", i, level.maptime, dn, LsSpdAgo(i, 0), pt.x, pt.y, pt.z, onFloor ? "on the hand's line" : "under the line's end");
		return true;
	}

	// THE IMPACT (whip.zs Reach, when the thong lands): a ring and dust, the heavy crack, and the shockwave. Every living
	// hostile monster within SHOCK_M of the spot, in the player's sight, is told to other mods (RSQWP_Events.Whipped),
	// thrown up (SHOCK_LIFT) and outward (the Wide Swing's push, by its mass as there) and staggered; a boss, a monster
	// that cannot be pushed, or one of HEAVY_MASS or more is only staggered; one that flies is pushed, not lifted. No
	// damage: his words give the shockwave none. RSQ SlowMo is asked when it caught at least one.
	void GroundImpact(int i, PlayerPawn pmo, int hand, Vector3 at)
	{
		double r = SHOCK_M * M2U();
		Noise(pmo, 'crackheavy', at);
		RSQWP_Looks.Spark(at + (0, 0, 4), 'crack');
		RSQWP_Looks.Ring(at, r);
		Buzz(pmo, hand, 1.0, 6);
		int n = 0, lifted = 0;
		// RSQ SCORE, BY NAME (2026-11-27; owner, on Score and today's Whip: "New rows for new moves"): the shockwave deals
		// no blow, so Score is told that this player's Ground Crack caught the monster ("touch" ground.crack, as RSQ Melee
		// and the Saber tell it their moves). Its Ground Crack row and its combos read it. Nothing without RSQ Score.
		Service score = ServiceIterator.Find("RS_ScoreService").Next();
		let it = BlockThingsIterator.CreateFromPos(at.x, at.y, at.z, 64, r, false);
		while (it.Next())
		{
			let v = it.thing;
			if (!v || v == pmo || v.player || v.Health <= 0 || !v.bSHOOTABLE || v.bNONSHOOTABLE || !v.bISMONSTER || v.bFRIENDLY || NotATarget(v)) continue;
			Vector2 to = v.pos.xy - at.xy;
			double l = to.Length();
			if (l - v.radius > r) continue;
			if (v.pos.z > at.z + r || v.pos.z + v.height < at.z - r) continue;   // a floor above or below the wave
			if (!pmo.CheckSight(v, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			RSQWP_Events.Whipped(v, pmo);
			if (score) score.GetInt("touch", "ground.crack", pmo.PlayerNumber(), 0, v);
			if (!v.bBOSS && !v.bDONTTHRUST && v.Mass < HEAVY_MASS)
			{
				Vector2 away = l > 0.01 ? to / l : Actor.AngleToVector(pmo.angle, 1);
				v.vel.xy += away * SWEEP_PUSH * clamp(400.0 / max(v.Mass, 50), 0.3, 2.0);
				if (!v.bNOGRAVITY) { v.vel.z = max(v.vel.z, SHOCK_LIFT); lifted++; }
			}
			Stagger(v);
			n++;
		}
		if (n > 0) AskSlow(SHOCK_SLOW_MS);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d IMPACT t%d at (%.0f %.0f %.0f): %d in the shockwave, %d thrown up", i, level.maptime, at.x, at.y, at.z, n, lifted);
	}
}
