// THE LASH: THE WHIP REDESIGNED (owner 2026-11-24 16:07: "you're free to completely redesign the whip. the actual whip
// itself is great"). The thong, its MIT physics and its look are kept as they are; what you DO with it is new. It was
// unwieldy and tiresome: big swings to crack, a trigger to mark, a rope to swing from (the grapple's job). Now three
// moves, read from the whip hand against your body, nothing held for the first two:
//
//   CRACK  a short sharp flick (the hand fast, then stopped dead within a few tics: a wrist snap, not an arm swing).
//          The tip flies to what the whip hand points at, within CRACK_REACH and a CRACK_CONE-degree cone (aim
//          assist: the nearest to the line wins), and cracks there: the whip's own hit and stun, plus LASH_BONUS damage.
//          Nothing in the cone: it cracks in the air where it points (a switch there is thrown, a pickup fetched).
//   SWEEP  a wide flat swing across you (the hand round the body through SWEEP_ARC degrees, fast, mostly level). The
//          thong lashes through the fan in front of where the swing ran: every monster within SWEEP_REACH in it takes
//          SWEEP_DMG, is knocked back and flinches. For when you are swarmed.
//   SNAG   the crack with the trigger held: the tip wraps the monster. Then the hand says what happens:
//            yank DOWN   trip: a knockdown, TRIP_DMG and TRIP_TICS on the ground, a finisher's moment
//            yank BACK   interrupt: whatever it was doing (an attack wound up) is cut off, INTERRUPT_TICS of flinch
//            hold still  pinned where it stands (its feet held) up to PIN_TICS, while your other hand shoots
//            let go of the trigger: it lets go
//   PARRY  a crack whose cone holds a fireball (anything flying at you that is not yours) takes that first: close
//          (within PARRY_RETURN) it goes back the way it came at whoever threw it, further it is cracked out of the air.
//
// The whip never moves you (the grapple does): no rope, no swing, no beam, no marking with the trigger in this style.
// Whip Style "Classic" (rsqwp_style 0) is the whip as it was. Code only, not run in the headset.
extend class RSQWP_Whip
{
	const CRACK_REACH = 4.5;      // metres
	const CRACK_CONE = 14.0;      // degrees round the whip hand's line
	const FLICK_MPS = 1.6;        // the flick: the hand at least this fast (m/s, against the body) ...
	const FLICK_STOP = 0.4;       // ... then down to this part of that within FLICK_WIN tics: the snap
	const FLICK_WIN = 4;
	const LASH_GAP = 8;           // tics between two lashes (a crack or a sweep)
	const LASH_BONUS = 12;        // a crack's damage on top of the whip's own hit (3..12)
	const SWEEP_ARC = 70.0;       // degrees of the hand round the body within SWEEP_WIN tics
	const SWEEP_WIN = 8;
	const SWEEP_MPS = 2.0;        // the hand's average speed through it
	const SWEEP_REACH = 2.6;      // metres: the arm and the thong
	const SWEEP_FAN = 75.0;       // degrees either side of the swing's middle
	const SWEEP_DMG = 8;
	const SWEEP_PUSH = 7.0;       // map units a tic
	const YANK_MPS = 2.0;         // a snag's yank (down or back)
	const TRIP_DMG = 10;
	const TRIP_TICS = 70;         // 2 s down
	const INTERRUPT_TICS = 35;
	const PIN_TICS = 105;         // 3 s
	const PARRY_RETURN = 2.5;
	const YANK_REST = 8;          // after a yank, this long more before the next flick counts     // metres: a fireball cracked this close goes back

	Vector3 lsRel[NW];            // the whip hand against the body (the body's facing turned out), room units
	bool    lsHave[NW];
	double  lsSpd[NW * 8];        // the last 8 tics' speeds, m/s (ring)
	Vector3 lsVel[NW * 8];        // and velocities, m/s, the body's frame (x ahead, y left, z up)
	double  lsYaw[NW * 8];        // the hand's bearing round the body, degrees
	int     lsAt[NW];
	int     lsLast[NW];           // the tic of the last lash
	bool    lsSnag[NW];           // this crack was thrown with the trigger held: it wraps
	int     lsPinFrom[NW];
	Vector3 lsPinAt[NW];

	static clearscope bool LashOn() { return RSQWP_Util.Opt("rsqwp_style", 1) == 1; }
	static clearscope double M2U() { let c = CVar.FindCVar("vr_vunits_per_meter"); double v = c ? c.GetFloat() : 34; return v > 0 ? v : 34; }

	Vector3 LsVelAgo(int i, int ago) { return lsVel[i * 8 + (lsAt[i] - ago + 16) % 8]; }
	double  LsSpdAgo(int i, int ago) { return lsSpd[i * 8 + (lsAt[i] - ago + 16) % 8]; }
	double  LsYawAgo(int i, int ago) { return lsYaw[i * 8 + (lsAt[i] - ago + 16) % 8]; }

	// ---- every tic, per whip (whip.zs WorldTick2, in place of Mark / Lock) ------------------------------------------
	void LashTick(int i, PlayerPawn pmo, int hand)
	{
		Vector3 eye = pmo.pos + (0, 0, SteadyEye(pmo));
		Vector3 r = ToRoom(BodyHand(pmo, hand)) - ToRoom(eye);
		double c = cos(-pmo.angle), s = sin(-pmo.angle);
		Vector3 rel = (r.x * c - r.y * s, r.x * s + r.y * c, r.z);
		if (!lsHave[i]) { lsRel[i] = rel; lsHave[i] = true; return; }
		Vector3 d = rel - lsRel[i];
		lsRel[i] = rel;
		if (d.Length() > 24) return;   // a teleport or a pose jump, not an arm
		Vector3 v = d * TICRATE / M2U();
		lsAt[i] = (lsAt[i] + 1) % 8;
		lsVel[i * 8 + lsAt[i]] = v;
		lsSpd[i * 8 + lsAt[i]] = v.Length();
		lsYaw[i * 8 + lsAt[i]] = atan2(rel.y, rel.x);
		if (wrapOn[i] || reachTic[i] > 0 || level.maptime - lsLast[i] < LASH_GAP) return;
		if (Sweep(i, pmo, hand)) return;
		// THE FLICK: a peak in the last FLICK_WIN tics, and now stopped
		double pk = 0;
		int pkAgo = 0;
		for (int a = 1; a <= FLICK_WIN; a++) if (LsSpdAgo(i, a) > pk) { pk = LsSpdAgo(i, a); pkAgo = a; }
		if (pk >= FLICK_MPS && LsSpdAgo(i, 0) <= pk * FLICK_STOP)
		{
			lsLast[i] = level.maptime;
			LashCrack(i, pmo, hand, trigNow[i]);
		}
	}

	// THE SWEEP: the hand's bearing round the body has turned through SWEEP_ARC in SWEEP_WIN tics, one way, fast and level
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
		// the fan's middle: where the hand was halfway through, in the world
		double mid = pmo.angle + Actor.Normalize180(LsYawAgo(i, SWEEP_WIN / 2));
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
			RSQWP_Perks.Hurt(v, pmo, pmo, SWEEP_DMG, DmgType(), DMG_THRUSTLESS);
			if (!v || v.bDestroyed || v.Health <= 0) { n++; continue; }
			Vector2 away = to.Length() > 0.01 ? to.Unit() : Actor.AngleToVector(mid, 1);
			if (!v.bDONTTHRUST && v.Mass < 1000) v.vel.xy += away * SWEEP_PUSH * clamp(400.0 / max(v.Mass, 50), 0.3, 2.0);
			State pain = v.FindState("Pain");
			if (pain && !v.InStateSequence(v.CurState, pain)) v.SetState(pain);
			n++;
		}
		Noise(pmo, 'crack', pmo.pos + (Actor.AngleToVector(mid, reach * 0.7), SteadyEye(pmo) * 0.8), i);
		Buzz(pmo, hand, 0.9, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d SWEEP t%d: %.0f degrees at %.1f m/s, %d hit", i, level.maptime, turned, spd, n);
		return true;
	}

	// THE CRACK (and the snag, and the parry): what the whip hand points at
	void LashCrack(int i, PlayerPawn pmo, int hand, bool snag)
	{
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, hand), RSQWP_Util.HandPitch(pmo, hand));
		double reach = CRACK_REACH * M2U();
		Actor best = null, shot = null;
		double bestA = CRACK_CONE, shotA = CRACK_CONE;
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, reach, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || NotATarget(a)) continue;
			bool fire = a.bMISSILE && a.target != pmo && !a.bDestroyed;
			bool mon = !fire && a.Health > 0 && a.bSHOOTABLE && !a.bNONSHOOTABLE && a.bISMONSTER;
			bool item = !fire && !mon && Inventory(a) && !Inventory(a).Owner && a.bSPECIAL;
			if (!fire && !mon && !item) continue;
			Vector3 to = a.pos + (0, 0, a.height * 0.5) - org;
			double d = to.Length();
			if (d < 4 || d > reach + a.radius) continue;
			double ang = acos(clamp((to / d) dot dir, -1.0, 1.0)) - atan2(a.radius, d);
			if (fire) { if (ang < shotA) { shot = a; shotA = ang; } continue; }
			if (RSQWP_Util.Flag("rsqwp_debug", false) && mon) Console.Printf("T_WPW %d lash cone: %s %.0f units, %.0f degrees off the line (cone %.0f)", i, a.GetClassName(), d, ang, CRACK_CONE);
			if (ang > bestA || !pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			best = a; bestA = ang;
		}
		Noise(pmo, 'crack', org + dir * 32, i);
		Buzz(pmo, hand, 1.0, 5);
		// THE PARRY: a fireball in the cone is taken first
		if (shot)
		{
			Vector3 at = shot.pos;
			bool back = (shot.pos - org).Length() <= PARRY_RETURN * M2U();
			if (back) ReturnTo(pmo, shot, 0);
			else CrackMissile(pmo, shot, dir);
			RSQWP_Looks.Spark(at, 'crack');
			reachFor[i] = null; reachMarked[i] = false; reachPt[i] = at; reachTic[i] = REACH_TICS; lsSnag[i] = false;
			crackV[i] = RSQWP_Util.Num("rsqwp_whip_crack", 20);
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d PARRY t%d %s: %s", i, level.maptime, shot.GetClassName(), back ? "sent back" : "cracked out of the air");
			return;
		}
		reachFor[i] = best;
		reachMarked[i] = best != null;
		lsSnag[i] = snag && best && best.bISMONSTER;
		crackV[i] = max(RSQWP_Util.Num("rsqwp_whip_crack", 20) * 1.5, 30.0);   // a full crack (the whip's own hit at its top)
		if (best) reachPt[i] = best.pos + (0, 0, best.height * 0.6);
		else
		{
			let tr = GetTracer();
			tr.shooter = pmo;
			double len = reach;
			if (tr.Trace(org, level.PointInSector(org.xy), dir, len, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType != TRACE_HitNone)
				len = max(8.0, tr.Results.Distance - 4);
			reachPt[i] = org + dir * len;
		}
		reachTic[i] = REACH_TICS;
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LASH CRACK t%d -> %s%s", i, level.maptime, best ? best.GetClassName() : 'nothing', lsSnag[i] ? " (snag)" : "");
	}

	// the crack arrives (whip.zs Reach, in place of its own arrival)
	void LashArrive(int i, PlayerPawn pmo, int hand, Actor v, Vector3 at)
	{
		RSQWP_Looks.Spark(at, 'crack');
		let inv = Inventory(v);
		if (inv && !inv.Owner)
		{
			let mark = Actor.Spawn("RSQWP_WhipTip", inv.pos, NO_REPLACE);
			if (mark) Fetch(pmo, mark, 8 + inv.radius);
			return;
		}
		if (v && v.Health > 0 && v.bISMONSTER)
		{
			Touch("crack.marked", pmo, v);
			Hit(i, pmo, hand, v, at, crackV[i], true);
			if (v && !v.bDestroyed && v.Health > 0) RSQWP_Perks.Hurt(v, pmo, pmo, LASH_BONUS, DmgType(), DMG_THRUSTLESS);
			if (lsSnag[i] && trigNow[i] && v && !v.bDestroyed && v.Health > 0)
			{
				BeginWrap(i, pmo, hand, v, false);
				lsPinFrom[i] = level.maptime;
				lsPinAt[i] = v.pos;
			}
			lsSnag[i] = false;
			return;
		}
		lsSnag[i] = false;
		if (RSQWP_Util.Flag("rsqwp_whip_lines", true)) Switches(pmo, at, 32);
	}

	// ---- the snag, held (in place of HoldWrap) ------------------------------------------------------------------------
	void LashHold(int i, PlayerPawn pmo, int hand)
	{
		let v = wrapOn[i];
		if (!v) return;
		if (v.bDestroyed || v.Health <= 0 || !trigNow[i] || level.maptime - lsPinFrom[i] > PIN_TICS) { EndWrap(i); return; }
		Vector3 hp = BodyHand(pmo, hand);
		Vector3 cpt = v.pos + (0, 0, v.height * 0.6);
		Vector3 roomTo = ToRoom(cpt) - ToRoom(hp);
		double dist = roomTo.Length();
		if (dist > CRACK_REACH * M2U() * 1.4) { EndWrap(i); return; }
		// the thong laid to it, as the classic wrap does
		wlen[i] = max(baseLen[i], dist + 8);
		int o = i * NP;
		for (int k = NN / 2; k < NP; k++)
		{
			double u = double(k - NN / 2) / (NN - NN / 2);
			Vector3 want = ToRoom(hp) + roomTo * (0.5 + 0.5 * u);
			Vector3 dv = (want - wp[o + k]) * 0.5;
			wp[o + k] = wp[o + k] + dv;
			wq[o + k] = wq[o + k] + dv;
		}
		if (level.maptime - lsPinFrom[i] < 3) { Pin(i, v); return; }   // the wrap settles before a yank counts
		Vector3 hv = LsVelAgo(i, 0);
		// back: the hand's motion toward you, along the line to it (the body's frame: the line turned the same way)
		Vector3 r = roomTo / max(dist, 0.001);
		double c = cos(-pmo.angle), s = sin(-pmo.angle);
		Vector3 line = (r.x * c - r.y * s, r.x * s + r.y * c, r.z);
		double back = -(hv dot line);
		if (hv.z <= -YANK_MPS)
		{
			RSQWP_Perks.Hurt(v, pmo, pmo, TRIP_DMG, DmgType(), DMG_THRUSTLESS);
			if (v && !v.bDestroyed && v.Health > 0) Flinch(v, TRIP_TICS);
			Touch("crack.stun", pmo, v);
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d TRIP t%d %s", i, level.maptime, v ? v.GetClassName() : 'gone');
			lsLast[i] = level.maptime + YANK_REST;   // the yank's own stop is not a flick (rig: it cracked again a tic later)
			EndWrap(i);
			return;
		}
		if (back >= YANK_MPS)
		{
			if (v && !v.bDestroyed && v.Health > 0) Flinch(v, INTERRUPT_TICS);
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d INTERRUPT t%d %s", i, level.maptime, v ? v.GetClassName() : 'gone');
			lsLast[i] = level.maptime + YANK_REST;
			EndWrap(i);
			return;
		}
		Pin(i, v);
	}

	// held where it was wrapped: its feet do not move (it may still turn and shoot)
	void Pin(int i, Actor v)
	{
		if (v.bDONTTHRUST || v.bBOSS) return;
		v.vel.xy = (0, 0);
		if ((v.pos.xy - lsPinAt[i].xy).Length() > 1) v.SetOrigin((lsPinAt[i].xy, v.pos.z), true);
	}

	// into its Pain and held there: a knockdown, an interrupted attack
	static void Flinch(Actor v, int tics)
	{
		State pain = v.FindState("Pain");
		if (!pain) { v.A_Stop(); return; }
		if (!v.InStateSequence(v.CurState, pain)) v.SetState(pain);
		if (v && !v.bDestroyed && v.Health > 0) v.tics = max(v.tics, tics);
	}
}
