// RSQGR_Core -- GRAPPLE 2.0 (design/PLANNED_PROJECTS.md "Grapple 2.0": every rule here is the owner's; where the plan is
// silent the simplest thing was chosen, and Grapple/README.md lists those).
//
// THE OFF HAND'S INSTANT HOOK. One press of Fire Hook, from the off hand, where it points: the bite is decided on the
// press tic by one trace out to the reach (jpalomo's 780 units, about 23 m), and the chain is drawn from the hand to
// the claw while the result plays. Three results, decided where it bites:
//   WALL OR FLOOR    you are flung at it: jpalomo's Hook_HitWall thrust, number for number, and your momentum is yours
//   LEDGE LIP        a bite on the top of a step you could stand on (room to stand): you are carried up and onto it
//   LIGHT MONSTER    GET OVER HERE: it is yanked to you and lands in front of you (no catch). In the air: it is pulled up
//                    to you and held there -- the AIR SPIKE's moment
//   HEAVY MONSTER    (a boss, mass over 1000, dormant, or RSQ Miniboss's Can't Be Yanked) you are pulled to it, and
//                    arriving IS the kick: 30 damage, knocked back, staggered, the yellow cross, KICK!, slow motion on
//                    contact, then the kick-off: away from it and up about 1.5 m (the ceiling checked every tic)
// THE KICK-CHAIN: in the air after a kick-off the hook fires again (Aim Assist snaps it to the nearest valid target
// round the off hand's line); a big one kicks again (chain +1, KICK! x2 ...), a light one comes up to you, a wall or a
// lip lands you, nothing in reach lets you fall. Each link's slow motion is 0.3 s shorter (1.5, 1.2, 0.9, 0.6, 0.3 s).
// THE DOUBLE JUMP: one per kick-off; jump in the air for more air and +0.5 s ("DoubleJump!"), and up to 5 monsters in
// reach get a time marker (+0.25 s nearer, +0.5 s farther) that hooking them pays.
// THE AIR SPIKE: a light monster held up in front of you in the air: both hands swung down hard together (3 m/s,
// anything in them, only at this moment) spike it straight down; you hang until it hits the floor; RSQ Grenade's Neon
// Crescent goes off there, with blood, fire and a shockwave, and RSQ SlowMo's Grapple-Slam slows your descent.
//
// RUNS AT FULL SPEED IN SLOW MOTION: the claw and the effects are "rsq..." classes (RSQ SlowMo runs them in real time),
// monsters on the hook are moved by position (a pushed velocity would be scaled by the world's clock), and every tic the
// hook moves you it asks RSQ SlowMo for full-speed movement ("g2.fullspeed") before it sets your velocity.
//
// NETPLAY: the press carries the off hand's pose (input.zs). The two gestures (the air spike's swing, Scorpion Pull's
// yank) read the hands in play, which are real only for the machine's own player: single player. Rig only, not
// headset-confirmed.
class RSQGR_Core : EventHandler
{
	enum EMode
	{
		M_NONE,
		M_YANK,       // GET OVER HERE: a light monster on its way to land in front of you
		M_AIRPULL,    // in the air: a light monster pulled up to you
		M_AIRHOLD,    // ... held in front of you: the air spike's moment
		M_SPIKE,      // spiked: it falls, you hang
		M_PULL,       // you on your way to a heavy one (arriving is the kick)
		M_MANTLE,     // up and onto a ledge
		M_SCORP       // Scorpion Pull: held on the chain until the off hand yanks back
	}
	enum EBite { B_NONE, B_WALL, B_LIGHT, B_HEAVY, B_LEDGE, B_MISS }

	// THE NUMBERS (owner 2026-11-13 00:2x where he gave them; the rest chosen, README "Chosen, not specified")
	const KICK_DAMAGE = 30;        // as RSQ Melee's Ground Pound
	const KICK_STAGGER = 15;       // Ground Pound's stagger, tics
	const KICK_UP_M = 1.5;         // the kick-off's rise, metres
	const KICK_OUT = 8.0;          // the kick-off's speed away from the monster, units a tic (chosen)
	const DJ_UP_M = 1.5;           // the double jump's rise, metres (chosen: as the kick-off)
	const SLOW_FIRST = 1.5;        // the first link's slow motion, seconds
	const SLOW_STEP = 0.3;         // each next link's, that much shorter
	const DJ_TICS = 18;            // +0.5 s
	const MARK_MAX = 5;
	const MARK_NEAR_TICS = 9;      // +0.25 s
	const MARK_FAR_TICS = 18;      // +0.5 s
	const ASSIST_CONE = 10.0;      // degrees round the off hand's line (chosen)
	const PULL_MIN = 20.0;         // the slowest a pull to a heavy one goes, units a tic (chosen; jp: distance / 12)
	const YANK_MAX_TICS = 12;      // jp: distance / 12 a tic, so any yank takes at most 12 tics
	const LIP = 40.0;              // a wall bite this close under the top of a step is a ledge lip (chosen)
	const AIR_HOLD = 35;           // the air spike's moment, tics (chosen)
	const SPIKE_MPS = 3.0;         // both hands down at least this fast
	const SPIKE_FALL = 30.0;       // the spiked monster's fall, units a tic (chosen)
	const SHOCK_R = 160.0;         // the shockwave's reach (chosen)
	const SCORP_HOLD = 105;        // Scorpion Pull waits this long for the yank, tics (chosen)
	const SCORP_MPS = 2.0;         // the yank back, m/s (chosen)
	const OG_HOLD = 16;            // jp's claw stays shut 16 tics after a wall bite (CCLW A 16)
	const RGB_KICK = 0xFFC83C;
	const RGB_MARK = 0x60E0FF;

	int mode[MAXPLAYERS];
	int modeAge[MAXPLAYERS];
	RSQGR_Claw claw[MAXPLAYERS];
	Actor victim[MAXPLAYERS];
	bool vNoGrav[MAXPLAYERS];      // the victim's own NOGRAVITY, given back
	int pending[MAXPLAYERS];       // M_SCORP: what the yank sets off (B_LIGHT / B_HEAVY)
	Vector3 pFrom[MAXPLAYERS], pTo[MAXPLAYERS];
	Vector2 pDir[MAXPLAYERS];      // a yank's line, from you out to the monster
	double pHump[MAXPLAYERS];
	int pTics[MAXPLAYERS];
	double pSpeed[MAXPLAYERS], pBest[MAXPLAYERS];
	int pStuck[MAXPLAYERS];
	Vector3 lStand[MAXPLAYERS];
	double lTop[MAXPLAYERS];
	bool hanging[MAXPLAYERS];
	double hangZ[MAXPLAYERS];
	bool flung[MAXPLAYERS];        // the hook sent you into the air: full speed and comfort until you land
	// the kick-chain
	int chain[MAXPLAYERS];
	int bestChain[MAXPLAYERS];
	bool airChain[MAXPLAYERS];     // in the air after a kick-off, until you land
	bool djReady[MAXPLAYERS];
	bool rising[MAXPLAYERS];
	bool ceilCut[MAXPLAYERS];
	int lastKick[MAXPLAYERS];
	int kicks[MAXPLAYERS];
	int prevButtons[MAXPLAYERS];
	// the hands, last three tics (map units against the body): main 0..2, off 3..5
	Vector3 hist[MAXPLAYERS * 6];
	int histN[MAXPLAYERS];
	int histAt[MAXPLAYERS];
	// the time markers
	Array<Actor> markOn;
	Array<int> markPn, markTics;
	// what happened (service.zs)
	Array<String> evName;
	Array<int> evTic, evPn;
	int evCount[MAXPLAYERS];
	Array<Actor> recMon;
	Array<int> recKick, recYank, recSpike, recBy;
	transient RSQGR_Tracer tracer;

	static RSQGR_Core Get() { return RSQGR_Core(EventHandler.Find("RSQGR_Core")); }

	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++) { lastKick[i] = -1; }
	}

	void Log(int pn, String s)
	{
		if (RSQGR_Util.Debug()) Console.Printf("T_G2 t%d p%d %s", level.maptime, pn, s);
	}

	// ---- what happened, for the service ---------------------------------------------------------------------------
	void Event(int pn, String name, Actor about = null)
	{
		evName.Push(name); evTic.Push(level.maptime); evPn.Push(pn);
		if (evName.Size() > 64) { evName.Delete(0); evTic.Delete(0); evPn.Delete(0); }
		if (pn >= 0 && pn < MAXPLAYERS) evCount[pn]++;
		Log(pn, "EVENT " .. name .. (about ? " " .. about.GetClassName() : ""));
	}
	int Rec(Actor a)
	{
		for (int i = 0; i < recMon.Size(); i++) if (recMon[i] == a) return i;
		if (recMon.Size() >= 64)
			for (int i = recMon.Size() - 1; i >= 0; i--)
				if (!recMon[i]) { recMon.Delete(i); recKick.Delete(i); recYank.Delete(i); recSpike.Delete(i); recBy.Delete(i); }
		recMon.Push(a); recKick.Push(-1); recYank.Push(-1); recSpike.Push(-1); recBy.Push(-1);
		return recMon.Size() - 1;
	}

	// ---- the press ------------------------------------------------------------------------------------------------
	void Fire(int pn, Vector3 org, Vector3 dir)
	{
		let pmo = players[pn].mo;
		if (!pmo || pmo.health <= 0) return;
		int m = mode[pn];
		if (m == M_PULL || m == M_MANTLE || m == M_AIRPULL || m == M_AIRHOLD || m == M_SPIKE || m == M_SCORP)
		{
			Log(pn, String.Format("press ignored: the hook is busy (mode %d)", m));
			return;
		}
		if (m == M_YANK) EndVictim(pn, "a new press");
		if (claw[pn]) { claw[pn].Destroy(); claw[pn] = null; }
		mode[pn] = M_NONE;

		bool air = !RSQGR_Util.OnGround(pmo);
		double range = RSQGR_Util.Range();
		if (air && RSQGR_Util.Flag("rsqgr_aim_assist", true))
		{
			double off;
			Actor t;
			[t, off] = AssistTarget(pmo, org, dir, range);
			if (t)
			{
				dir = (RSQGR_Util.Mid(t) - org).Unit();
				Log(pn, String.Format("aim assist: snapped %.1f degrees to %s", off, t.GetClassName()));
			}
		}
		pmo.A_StartSound("rsqgr/fire", CHAN_AUTO, CHANF_OVERLAP);

		if (!tracer) tracer = new("RSQGR_Tracer");
		tracer.shooter = pmo;
		bool hit = tracer.Trace(org, level.PointInSector(org.xy), dir, range, TRACE_HitSky, RSQGR_Tracer.WALLMASK, false, pmo);
		int ht = tracer.Results.HitType;
		Log(pn, String.Format("fire from (%.0f %.0f %.0f) dir (%.2f %.2f %.2f) %s, hit type %d at %.0f", org.x, org.y, org.z, dir.x, dir.y, dir.z, air ? "in the air" : "on the ground", ht, hit ? tracer.Results.Distance : -1));
		if (!hit || ht == TRACE_HitNone || ht == TRACE_CrossingPortal || ht == TRACE_HasHitSky)
		{
			Vector3 end = (hit && ht == TRACE_HasHitSky) ? tracer.Results.HitPos : org + dir * range;
			let c = RSQGR_Claw.Make(pmo, end, null);
			if (c) c.Back();
			claw[pn] = c;
			Event(pn, "miss");
			return;
		}
		Vector3 at = tracer.Results.HitPos;
		if (ht == TRACE_HitActor)
		{
			let v = tracer.Results.HitActor;
			claw[pn] = RSQGR_Claw.Make(pmo, at, v);
			pmo.A_StartSound("rsqgr/hit/flesh", CHAN_AUTO, CHANF_OVERLAP);
			MarkerHooked(pn, v);
			bool heavy = RSQGR_Util.Heavy(v);
			Log(pn, String.Format("bite %s (mass %d, boss %d, dormant %d) -> %s", v.GetClassName(), v.Mass, v.bBOSS, v.bDORMANT, heavy ? "HEAVY: you go to it" : "LIGHT: it comes"));
			Event(pn, heavy ? "bite.heavy" : "bite.light", v);
			if (RSQGR_Util.Flag("rsqgr_scorpion", false))
			{
				victim[pn] = v;
				pending[pn] = heavy ? B_HEAVY : B_LIGHT;
				SetMode(pn, M_SCORP);
				Event(pn, "scorpion.hold", v);
				return;
			}
			if (heavy) StartPull(pn, v);
			else StartYank(pn, v, air);
			return;
		}

		// geometry: a wall, a floor, a ceiling
		Vector3 bite = at - dir * 1.0;
		let c = RSQGR_Claw.Make(pmo, bite, null);
		claw[pn] = c;
		pmo.A_StartSound("rsqgr/hit/terrain", CHAN_AUTO, CHANF_OVERLAP);
		double top;
		Vector3 stand;
		bool ledge;
		[ledge, top, stand] = LedgeSpot(pmo, ht, tracer.Results.HitLine, tracer.Results.Side, at, dir);
		if (ledge)
		{
			lTop[pn] = top;
			lStand[pn] = stand;
			SetMode(pn, M_MANTLE);
			flung[pn] = true;
			Log(pn, String.Format("bite: LEDGE LIP, top %.0f (feet at %.0f), stand at (%.0f %.0f)", top, pmo.Pos.z, stand.x, stand.y));
			Event(pn, "bite.ledge");
			return;
		}
		if (c) c.holdTics = OG_HOLD;
		Fling(pmo, at - dir * 15.0);
		flung[pn] = true;
		Event(pn, ht == TRACE_HitWall ? "bite.wall" : ht == TRACE_HitFloor ? "bite.floor" : "bite.ceiling");
	}

	// AIM ASSIST (in the air): the valid target nearest the off hand's line, inside ASSIST_CONE, in sight
	Actor, double AssistTarget(PlayerPawn pmo, Vector3 org, Vector3 dir, double range)
	{
		Actor best = null;
		double bestOff = ASSIST_CONE;
		let it = BlockThingsIterator.Create(pmo, range);
		while (it.Next())
		{
			let a = it.thing;
			if (!RSQGR_Util.Biteable(a, pmo) || !a.bIsMonster || a.bFRIENDLY) continue;
			Vector3 to = RSQGR_Util.Mid(a) - org;
			double l = to.Length();
			if (l < 1 || l > range) continue;
			double off = acos(clamp((to / l) dot dir, -1.0, 1.0));
			if (off > bestOff) continue;
			if (!pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			best = a;
			bestOff = off;
		}
		return best, bestOff;
	}

	// A LEDGE LIP WITH ROOM TO STAND: the bite is on the face of a step no more than LIP under its top (or on the top of
	// a floor higher than you can step), the top is above what you can step up, and on top there is floor at that height
	// with room for your whole height. Answers the top's height and where you will stand.
	bool, double, Vector3 LedgeSpot(PlayerPawn pmo, int ht, Line ln, int side, Vector3 at, Vector3 dir)
	{
		double top;
		Vector2 spot;
		if (ht == TRACE_HitWall)
		{
			if (!ln || !ln.backsector || !ln.frontsector) return false, 0, (0, 0, 0);
			Sector behind = side == 0 ? ln.backsector : ln.frontsector;
			top = behind.floorplane.ZatPoint(at.xy);
			if (at.z > top + 1 || top - at.z > LIP) return false, 0, (0, 0, 0);
			Vector2 n = (-ln.delta.y, ln.delta.x);         // into the back sector
			if (side != 0) n = -n;
			if (n.Length() < 0.001) return false, 0, (0, 0, 0);
			spot = at.xy + n.Unit() * (pmo.radius + 4);
		}
		else if (ht == TRACE_HitFloor)
		{
			top = at.z;
			spot = at.xy;
		}
		else return false, 0, (0, 0, 0);
		if (top <= pmo.Pos.z + pmo.MaxStepHeight + 1) return false, 0, (0, 0, 0);
		Sector s = level.PointInSector(spot);
		double fz = s.floorplane.ZatPoint(spot), cz = s.ceilingplane.ZatPoint(spot);
		if (abs(fz - top) > 2 || cz - fz < pmo.Height) return false, 0, (0, 0, 0);
		return true, top, (spot.x, spot.y, top);
	}

	// JPALOMO'S WALL THRUST (jp_original/scripts/hook.acs Hook_HitWall, measured against his pk3 on the rig 11-03 by the
	// old grapple): vel.xy += (distance / 12) along his 256-step angle to the claw, vel.z += -((round(z - claw z) / 4) / 4).
	// Added, never set: your momentum is kept, and keepmomentum keeps the engine's VR momentum wipe off you.
	void Fling(PlayerPawn pmo, Vector3 hook)
	{
		Vector2 dxy = hook.xy - pmo.Pos.xy;
		int f = int(dxy.Length());
		double ang = atan2(dxy.y, dxy.x);
		if (ang < 0) ang += 360.0;
		int b = (int(ang * (65536.0 / 360.0)) >> 8) & 255;
		int zh = int(floor(pmo.Pos.z - hook.z + 0.5));
		double th = b * (360.0 / 256.0);
		FullSpeed(pmo);
		pmo.player.keepmomentum = true;
		pmo.vel.xy += (cos(th), sin(th)) * (f / 12);
		pmo.vel.z += -((zh / 4) / 4.0);
		Log(pmo.PlayerNumber(), String.Format("FLING (jp): f %d b %d zh %d -> vel (%.2f %.2f %.2f)", f, b, zh, pmo.vel.x, pmo.vel.y, pmo.vel.z));
	}

	// ---- the modes ------------------------------------------------------------------------------------------------
	void SetMode(int pn, int m) { mode[pn] = m; modeAge[pn] = 0; pStuck[pn] = 0; }

	// GET OVER HERE (and in the air, the pull up to you): a path from where it was bitten to the near end of the chain,
	// at jp's speed (the distance in 12 tics), moved by position so it comes at full speed in slow motion
	void StartYank(int pn, Actor v, bool air)
	{
		let pmo = players[pn].mo;
		Vector2 d = v.Pos.xy - pmo.Pos.xy;
		if (d.Length() < 1) d = (cos(pmo.Angle), sin(pmo.Angle));
		pDir[pn] = d.Unit();
		victim[pn] = v;
		vNoGrav[pn] = v.bNOGRAVITY;
		v.bNOGRAVITY = true;
		v.vel = (0, 0, 0);
		pFrom[pn] = v.Pos;
		pTo[pn] = YankPoint(pmo, v, pDir[pn], air);
		double dist = (pTo[pn] - pFrom[pn]).Length();
		pTics[pn] = clamp(int(ceil(dist / max(dist / YANK_MAX_TICS, 8.0))), 1, YANK_MAX_TICS);
		pHump[pn] = air ? 0 : min(32.0, dist * 0.08);
		int r = Rec(v);
		recYank[r] = level.maptime; recBy[r] = pn;
		if (air) { HangStart(pn); SetMode(pn, M_AIRPULL); Event(pn, "airpull", v); }
		else { SetMode(pn, M_YANK); Event(pn, "getoverhere", v); }
		Log(pn, String.Format("%s: %s from %.0f units, %d tics", air ? "AIR PULL" : "GET OVER HERE", v.GetClassName(), dist, pTics[pn]));
	}

	// in front of you along the chain: on the floor there, or (in the air) its middle at your chest
	Vector3 YankPoint(PlayerPawn pmo, Actor v, Vector2 u, bool air)
	{
		double gap = pmo.radius + v.radius + 16;
		Vector2 xy = pmo.Pos.xy + u * gap;
		if (!air)
		{
			Sector s = level.PointInSector(xy);
			return (xy.x, xy.y, s.floorplane.ZatPoint(xy));
		}
		Sector s = level.PointInSector(xy);
		double z = pmo.Pos.z + pmo.Height * 0.55 - v.Height * 0.5;
		z = max(z, s.floorplane.ZatPoint(xy));
		return (xy.x, xy.y, z);
	}

	// one step of a monster moved by position: z first, then the move with its own collision (TryMove)
	bool StepTo(Actor v, Vector3 p)
	{
		v.vel = (0, 0, 0);
		v.SetZ(max(p.z, v.floorz));
		bool ok = v.TryMove(p.xy, 1);
		v.vel = (0, 0, 0);
		return ok;
	}

	void TickYank(int pn, PlayerPawn pmo)
	{
		let v = victim[pn];
		if (!v || v.health <= 0) { EndVictim(pn, "it died on the way"); SetMode(pn, M_NONE); if (claw[pn]) claw[pn].Back(); return; }
		int age = ++modeAge[pn];
		bool air = mode[pn] == M_AIRPULL;
		if (air) pTo[pn] = YankPoint(pmo, v, pDir[pn], true);   // you hang, but the point follows you
		double t = min(1.0, age / double(pTics[pn]));
		Vector3 p = pFrom[pn] + (pTo[pn] - pFrom[pn]) * t;
		p.z += pHump[pn] * sin(180.0 * t);
		if (!StepTo(v, p))
		{
			if (++pStuck[pn] >= 2)
			{
				Log(pn, String.Format("yank stuck at (%.0f %.0f %.0f): let go there", v.Pos.x, v.Pos.y, v.Pos.z));
				EndVictim(pn, "stuck");
				SetMode(pn, M_NONE);
				HangEnd(pn);
				if (claw[pn]) claw[pn].Back();
				return;
			}
		}
		if (t < 1.0) return;
		if (!air)
		{
			v.SetZ(v.floorz);
			Log(pn, String.Format("GET OVER HERE landed: %s %.0f units in front of you", v.GetClassName(), pmo.Distance2D(v)));
			EndVictim(pn, "landed");
			SetMode(pn, M_NONE);
			if (claw[pn]) claw[pn].Back();
			Event(pn, "getoverhere.land", v);
			return;
		}
		SetMode(pn, M_AIRHOLD);
		histN[pn] = 0;
		Log(pn, String.Format("AIR HOLD: %s in front of you (%.0f units), swing both hands down", v.GetClassName(), pmo.Distance3D(v)));
		Event(pn, "airhold", v);
	}

	// THE AIR SPIKE'S MOMENT: held in front of you; both hands down hard together spike it
	void TickAirHold(int pn, PlayerPawn pmo)
	{
		let v = victim[pn];
		if (!v || v.health <= 0) { EndVictim(pn, "it died"); SetMode(pn, M_NONE); HangEnd(pn); if (claw[pn]) claw[pn].Back(); return; }
		modeAge[pn]++;
		StepTo(v, YankPoint(pmo, v, pDir[pn], true));
		double m0, m1;
		[m0, m1] = DownSpeeds(pn);
		if (m0 >= SPIKE_MPS && m1 >= SPIKE_MPS)
		{
			Log(pn, String.Format("AIR SPIKE: both hands down at %.2f and %.2f m/s", m0, m1));
			int r = Rec(v);
			recSpike[r] = level.maptime; recBy[r] = pn;
			SetMode(pn, M_SPIKE);
			if (claw[pn]) claw[pn].Back();
			Event(pn, "airspike", v);
			return;
		}
		if (modeAge[pn] > AIR_HOLD)
		{
			Log(pn, String.Format("air hold over: no swing (fastest down %.2f / %.2f m/s), it drops", m0, m1));
			EndVictim(pn, "dropped");
			SetMode(pn, M_NONE);
			HangEnd(pn);
			if (claw[pn]) claw[pn].Back();
			Event(pn, "air.drop", v);
		}
	}

	void TickSpike(int pn, PlayerPawn pmo)
	{
		let v = victim[pn];
		modeAge[pn]++;
		if (!v) { SetMode(pn, M_NONE); HangEnd(pn); return; }
		v.vel = (0, 0, 0);
		v.SetZ(max(v.floorz, v.Pos.z - SPIKE_FALL));
		if (v.Pos.z > v.floorz + 0.5 && modeAge[pn] < 105) return;
		SpikeImpact(pn, pmo, v);
	}

	// ON IMPACT: RSQ Grenade's #10 Neon Crescent (by name, "g2.neon"), blood, fire, a shockwave; RSQ SlowMo's
	// Grapple-Slam for your descent ("g2.slam")
	void SpikeImpact(int pn, PlayerPawn pmo, Actor v)
	{
		Vector3 at = v.Pos;
		EndVictim(pn, "spiked into the floor");
		let spot = Actor.Spawn("RSQGR_Spot", at, NO_REPLACE);
		if (spot) spot.target = pmo;
		let gn = RSQGR_Util.Svc("RSQGN_Service");
		int neon = (gn && spot) ? gn.GetInt("g2.neon", "safe", pn + 1, 0, spot) : -2;
		for (int i = 0; i < 4; i++) v.SpawnBlood(RSQGR_Util.Mid(v), frandom[rsqgr](0, 360), KICK_DAMAGE);
		for (int i = 0; i < 6; i++)
		{
			double a = i * 60 + frandom[rsqgr](-15, 15), r = frandom[rsqgr](16, 48);
			let f = Actor.Spawn("RSQGR_Fire", at + (cos(a) * r, sin(a) * r, 0), NO_REPLACE);
			if (f) f.vel.z = frandom[rsqgr](0.5, 1.5);
		}
		RSQGR_Fx.Ring(at, SHOCK_R, 0xFFA040);
		int pushed = 0;
		let it = BlockThingsIterator.CreateFromPos(at.x, at.y, at.z, 64, SHOCK_R, false);
		while (it.Next())
		{
			let o = it.thing;
			if (!o || o == v || o.player || !o.bIsMonster || o.health <= 0 || o.bFRIENDLY) continue;
			Vector2 d = o.Pos.xy - at.xy;
			double l = d.Length();
			if (l > SHOCK_R + o.radius) continue;
			if (!o.bDONTTHRUST && l > 0.5) { o.vel.xy += d / l * 6.0 * Heft(o); o.vel.z += 3.0 * Heft(o); }
			Stagger(o, KICK_STAGGER);
			pushed++;
		}
		int slam = RSQGR_Util.SlowMo("g2.slam", "", 0, pmo);
		Log(pn, String.Format("SPIKE LANDED at (%.0f %.0f %.0f): Neon Crescent g2.neon -> %d, blood x4, fire x6, shockwave pushed %d, Grapple-Slam g2.slam -> %d", at.x, at.y, at.z, neon, pushed, slam));
		SetMode(pn, M_NONE);
		HangEnd(pn);
		Event(pn, "spike.land", v);
	}

	// YOU TO A HEAVY ONE: straight at its face, walls stopping you as they stop any move (the engine's own collision,
	// every tic); arriving is the kick
	void StartPull(int pn, Actor v)
	{
		let pmo = players[pn].mo;
		victim[pn] = v;
		HangEnd(pn);
		double dist = (FacePoint(pmo, v) - pmo.Pos).Length();
		pSpeed[pn] = max(PULL_MIN, dist / 12.0);
		pBest[pn] = dist;
		SetMode(pn, M_PULL);
		flung[pn] = true;
		pmo.A_StartSound("rsqgr/loop", CHAN_AUTO, CHANF_OVERLAP);
		Log(pn, String.Format("PULL to %s: %.0f units at %.1f a tic", v.GetClassName(), dist, pSpeed[pn]));
	}

	// where your body stands to kick it: out from its middle toward you, touching it
	Vector3 FacePoint(PlayerPawn pmo, Actor v)
	{
		Vector2 d = pmo.Pos.xy - v.Pos.xy;
		if (d.Length() < 1) d = (-cos(pmo.Angle), -sin(pmo.Angle));
		Vector2 xy = v.Pos.xy + d.Unit() * (v.radius + pmo.radius + 2);
		double z = v.Pos.z + v.Height * 0.5 - pmo.Height * 0.5;
		return (xy.x, xy.y, max(z, v.floorz));
	}

	bool Touching(PlayerPawn pmo, Actor v)
	{
		if (pmo.Distance2D(v) > pmo.radius + v.radius + 6) return false;
		return pmo.Pos.z < v.Pos.z + v.Height + 8 && pmo.Pos.z + pmo.Height > v.Pos.z - 8;
	}

	void TickPull(int pn, PlayerPawn pmo)
	{
		let v = victim[pn];
		int age = ++modeAge[pn];
		if (!v || v.health <= 0)
		{
			Log(pn, "pull: it is gone before you arrived, you fall");
			victim[pn] = null; SetMode(pn, M_NONE); if (claw[pn]) claw[pn].Back();
			Event(pn, "pull.lost");
			return;
		}
		Vector3 d = FacePoint(pmo, v) - pmo.Pos;
		double l = d.Length();
		FullSpeed(pmo);
		pmo.player.keepmomentum = true;
		if (Touching(pmo, v) || l <= pSpeed[pn] || pmo.BlockingMobj == v)
		{
			if (l <= pSpeed[pn]) pmo.vel = d; else pmo.vel = (0, 0, 0);
			Log(pn, String.Format("pull arrived after %d tics (%.0f units from its face)", age, l));
			Kick(pn, pmo, v);
			return;
		}
		if (l < pBest[pn] - 0.5) { pBest[pn] = l; pStuck[pn] = 0; }
		else if (++pStuck[pn] >= 6 || age > 70)
		{
			Log(pn, String.Format("pull blocked %.0f units short (a wall in the way): you fall", l));
			victim[pn] = null; SetMode(pn, M_NONE); if (claw[pn]) claw[pn].Back();
			Event(pn, "pull.blocked");
			return;
		}
		pmo.vel = d / l * pSpeed[pn];
		RSQGR_Util.Comfort(pmo, 1.0);
	}

	// THE KICK (arriving at a heavy one): 30 damage, knocked back, staggered, the yellow cross, KICK!, slow motion on
	// contact; then the kick-off. A guarded miniboss: the blow goes through RSQ Miniboss's own guard (no damage, its GUARD
	// shakes), no knockback, no stagger, no slow motion, no chain link -- and you bounce off it all the same.
	void Kick(int pn, PlayerPawn pmo, Actor v)
	{
		victim[pn] = null;
		SetMode(pn, M_NONE);
		if (claw[pn]) claw[pn].Back();
		Vector3 hitAt = RSQGR_Util.Mid(v) + ((pmo.Pos.xy - v.Pos.xy).Unit() * v.radius, 0);
		bool guarded = RSQGR_Util.MinibossGuarded(v);
		int r = Rec(v);
		recKick[r] = level.maptime; recBy[r] = pn;
		if (guarded)
		{
			int hp = v.health;
			v.DamageMobj(pmo, pmo, KICK_DAMAGE, 'Melee', DMG_THRUSTLESS);
			Log(pn, String.Format("GUARD: %s is guarded (RSQ Miniboss): health %d -> %d, bounce", v.GetClassName(), hp, v ? v.health : -1));
			Event(pn, "guard", v);
			KickOff(pn, pmo, v);
			return;
		}
		chain[pn]++;
		kicks[pn]++;
		bestChain[pn] = max(bestChain[pn], chain[pn]);
		lastKick[pn] = level.maptime;
		int hp = v.health;
		String vn = v.GetClassName();
		v.DamageMobj(pmo, pmo, KICK_DAMAGE, 'Melee', DMG_THRUSTLESS);
		bool killed = !v || v.health <= 0;
		if (v && !killed)
		{
			if (!v.bDONTTHRUST)
			{
				Vector2 d = v.Pos.xy - pmo.Pos.xy;
				double l = d.Length();
				if (l > 0.5) v.vel.xy += d / l * 4.0 * Heft(v);
				v.vel.z += 3.0 * Heft(v);
			}
			Stagger(v, KICK_STAGGER);
		}
		// the yellow cross: RSQ Melee's own MLK4 burst by name, gold; without Melee, a puff of gold
		String bn = "RSQML_Burst4";
		class<Actor> bc = bn;
		Actor burst = bc ? Actor.Spawn(bc, hitAt, NO_REPLACE) : null;
		if (burst)
		{
			burst.A_SetRenderStyle(1.0, STYLE_AddShaded);
			burst.SetShade(RGB_KICK);
			burst.Scale *= 1.5;
		}
		else RSQGR_Fx.Puff(hitAt);
		String word = chain[pn] > 1 ? String.Format("KICK! x%d", chain[pn]) : "KICK!";
		int said = RSQGR_Util.Word("word", word, RGB_KICK, 1.0, v);
		pmo.A_StartSound("rsqgr/hit/flesh", CHAN_AUTO, CHANF_OVERLAP);
		pmo.A_StartSound("rsqml/fx/thud", CHAN_AUTO, CHANF_OVERLAP);   // RSQ Melee's thud, when Melee is loaded
		// slow motion on contact: 1.5 s, each next link 0.3 s shorter
		double secs = SLOW_FIRST - SLOW_STEP * (chain[pn] - 1);
		int tics = secs > 0.001 ? int(secs * TICRATE + 0.5) : 0;
		int slow = tics > 0 ? RSQGR_Util.SlowMo("g2.slow", word, tics, pmo) : 0;
		Log(pn, String.Format("KICK %d: %s health %d -> %d (%s), knockback %s, burst %s, word \"%s\" -> %d, slow %d tics -> %d",
			chain[pn], vn, hp, v ? v.health : 0, killed ? "a kill" : "alive",
			(v && !killed && !v.bDONTTHRUST) ? "yes" : "no", burst ? "MLK4 (RSQ Melee)" : "puff", word, said, tics, slow));
		Event(pn, killed ? "kick.kill" : "kick", v);
		KickOff(pn, pmo, v);
	}

	// THE KICK-OFF: away from the monster (straight out from its middle toward where you hit it) and up about 1.5 m;
	// under a low ceiling the rise is cut to the room there is, and it is checked again every tic (WorldTick)
	void KickOff(int pn, PlayerPawn pmo, Actor v)
	{
		Vector2 d = (0, 0);
		if (v) d = pmo.Pos.xy - v.Pos.xy;
		if (d.Length() < 0.5) d = (-cos(pmo.Angle), -sin(pmo.Angle));
		d = d.Unit();
		double want = RSQGR_Util.MetresUp(KICK_UP_M);
		double room = pmo.ceilingz - (pmo.Pos.z + pmo.Height) - 2;
		double h = clamp(room, 0.0, want);
		double g = max(0.01, pmo.GetGravity());
		FullSpeed(pmo);
		pmo.player.keepmomentum = true;
		pmo.vel = (d.x * KICK_OUT, d.y * KICK_OUT, sqrt(2 * g * h));
		airChain[pn] = true;
		djReady[pn] = true;
		rising[pn] = true;
		ceilCut[pn] = h < want - 0.5;
		flung[pn] = true;
		Log(pn, String.Format("KICK-OFF: out (%.2f %.2f) at %.0f, up %.1f of %.1f units (room %.1f)%s, vel.z %.2f", d.x, d.y, KICK_OUT, h, want, room, ceilCut[pn] ? " CEILING CUT at launch" : "", pmo.vel.z));
	}

	// a monster's push away from you, by its weight (RSQ Melee's Heft: a boss barely moves)
	static double Heft(Actor o)
	{
		double k = clamp(100.0 / max(o.Mass, 1.0), 0.1, 1.5);
		return o.bBOSS ? k * 0.3 : k;
	}
	// RSQ Melee's stagger: its Pain state, held at least this many tics
	static void Stagger(Actor mo, int tics)
	{
		if (!mo || mo.health <= 0 || !mo.bIsMonster) return;
		State p = mo.FindState("Pain");
		if (p) mo.SetState(p);
		if (mo && mo.tics >= 0 && mo.tics < tics) mo.tics = tics;
	}

	void TickMantle(int pn, PlayerPawn pmo)
	{
		int age = ++modeAge[pn];
		Vector2 d = lStand[pn].xy - pmo.Pos.xy;
		double l = d.Length();
		double top = lTop[pn];
		FullSpeed(pmo);
		pmo.player.keepmomentum = true;
		if (pmo.Pos.z >= top - 1 && l <= 8)
		{
			pmo.vel.xy = (0, 0);
			Log(pn, String.Format("LEDGE: on top at z %.0f (top %.0f) after %d tics", pmo.Pos.z, top, age));
			SetMode(pn, M_NONE);
			if (claw[pn]) claw[pn].Back();
			Event(pn, "ledge.land");
			return;
		}
		if (age > 45)
		{
			Log(pn, String.Format("ledge: gave up after %d tics at z %.0f, %.0f units short", age, pmo.Pos.z, l));
			SetMode(pn, M_NONE);
			if (claw[pn]) claw[pn].Back();
			Event(pn, "ledge.fail");
			return;
		}
		Vector2 u = (0, 0);
		if (l > 0.01) u = d / l;
		if (pmo.Pos.z < top + 2) pmo.vel = (u.x * 2, u.y * 2, min(12.0, top + 4 - pmo.Pos.z)); // up the face
		else pmo.vel = (u.x * min(12.0, l), u.y * min(12.0, l), 0);                  // over the lip
		RSQGR_Util.Comfort(pmo, 1.0);
	}

	// SCORPION PULL: held on the chain until the off hand yanks back (or SCORP_HOLD runs out)
	void TickScorp(int pn, PlayerPawn pmo)
	{
		let v = victim[pn];
		int age = ++modeAge[pn];
		if (!v || v.health <= 0) { victim[pn] = null; SetMode(pn, M_NONE); if (claw[pn]) claw[pn].Back(); return; }
		if (pending[pn] == B_LIGHT) v.vel.xy = (0, 0);
		double mps = YankBack(pn, pmo);
		if (mps >= SCORP_MPS)
		{
			Log(pn, String.Format("SCORPION: the off hand yanked back at %.2f m/s after %d tics", mps, age));
			Event(pn, "scorpion.yank", v);
			SetMode(pn, M_NONE);
			if (pending[pn] == B_HEAVY) StartPull(pn, v);
			else StartYank(pn, v, !RSQGR_Util.OnGround(pmo));
			return;
		}
		if (age > SCORP_HOLD)
		{
			Log(pn, "scorpion: no yank, the chain lets go");
			victim[pn] = null; SetMode(pn, M_NONE); if (claw[pn]) claw[pn].Back();
			Event(pn, "scorpion.timeout", v);
		}
	}

	// the victim given back to the world: its own gravity, no velocity of ours
	void EndVictim(int pn, String why)
	{
		let v = victim[pn];
		victim[pn] = null;
		if (!v) return;
		v.bNOGRAVITY = vNoGrav[pn];
		v.vel = (0, 0, 0);
	}

	void HangStart(int pn) { let pmo = players[pn].mo; hanging[pn] = true; hangZ[pn] = pmo ? pmo.Pos.z : 0; }
	void HangEnd(int pn) { hanging[pn] = false; }

	// RSQ SlowMo: your movement at full speed for the next 2 tics (asked every tic the hook moves you)
	void FullSpeed(PlayerPawn pmo) { RSQGR_Util.SlowMo("g2.fullspeed", "", 2, pmo); }

	// ---- the hands (the two gestures) -----------------------------------------------------------------------------
	void ReadHands(int pn, PlayerPawn pmo)
	{
		if (!RSQGR_Util.PoseGood(pmo)) { histN[pn] = 0; return; }
		int at = (histAt[pn] + 1) % 3;
		histAt[pn] = at;
		hist[pn * 6 + at] = RSQGR_Util.HandOff(pmo, 0);
		hist[pn * 6 + 3 + at] = RSQGR_Util.HandOff(pmo, 1);
		if (histN[pn] < 3) histN[pn]++;
		if (RSQGR_Util.Debug() && mode[pn] != M_AIRHOLD)
		{
			double m0, m1;
			[m0, m1] = DownSpeeds(pn);
			if (m0 >= SPIKE_MPS && m1 >= SPIKE_MPS) Log(pn, String.Format("both hands down at %.2f / %.2f m/s: not the air spike's moment (mode %d), nothing", m0, m1, mode[pn]));
		}
	}
	// a hand's velocity over the last two tics, room metres a second
	Vector3 HandVel(int pn, int ctrl)
	{
		if (histN[pn] < 3) return (0, 0, 0);
		int now = histAt[pn], old = (histAt[pn] + 1) % 3;
		Vector3 d = hist[pn * 6 + ctrl * 3 + now] - hist[pn * 6 + ctrl * 3 + old];
		return RSQGR_Util.Metric(d) * (TICRATE / 2.0);
	}
	// both hands' speed DOWN (m/s), counted only when the move is mostly down
	double, double DownSpeeds(int pn)
	{
		return DownOf(HandVel(pn, 0)), DownOf(HandVel(pn, 1));
	}
	static double DownOf(Vector3 v)
	{
		double sp = v.Length();
		return (sp > 0.0001 && -v.z / sp >= 0.5) ? -v.z : 0.0;
	}
	// the off hand's speed straight back from the claw (m/s)
	double YankBack(int pn, PlayerPawn pmo)
	{
		let c = claw[pn];
		if (!c) return 0;
		Vector3 away = RSQGR_Util.Metric(RSQGR_Util.HandPos(pmo) - c.Pos);
		double l = away.Length();
		if (l < 0.001) return 0;
		return HandVel(pn, 1) dot (away / l);
	}

	// ---- the time markers -----------------------------------------------------------------------------------------
	int MarkIndex(Actor a, int pn)
	{
		for (int i = 0; i < markOn.Size(); i++) if (markOn[i] == a && markPn[i] == pn) return i;
		return -1;
	}
	void PlaceMarkers(int pn, PlayerPawn pmo)
	{
		double range = RSQGR_Util.Range();
		Array<Actor> c;
		Array<double> dist;
		let it = BlockThingsIterator.Create(pmo, range);
		while (it.Next())
		{
			let a = it.thing;
			if (!RSQGR_Util.Biteable(a, pmo) || !a.bIsMonster || a.bFRIENDLY || MarkIndex(a, pn) >= 0) continue;
			double l = pmo.Distance3D(a);
			if (l > range || !pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			int k = 0;
			while (k < dist.Size() && dist[k] <= l) k++;
			c.Insert(k, a);
			dist.Insert(k, l);
		}
		int n = min(c.Size(), MARK_MAX);
		String said = "";
		for (int k = 0; k < n; k++)
		{
			bool near = dist[k] <= range * 0.5;
			markOn.Push(c[k]);
			markPn.Push(pn);
			markTics.Push(near ? MARK_NEAR_TICS : MARK_FAR_TICS);
			int ok = RSQGR_Util.Word("word.hold", near ? "+0.25 sec" : "+0.5 sec", RGB_MARK, 0.8, c[k]);
			said = said .. String.Format(" %s@%.0f=%s%s", c[k].GetClassName(), dist[k], near ? "+0.25" : "+0.5", ok ? "" : "(particles)");
		}
		Log(pn, String.Format("MARKERS: %d of %d in reach:%s", n, c.Size(), said));
		if (n > 0) Event(pn, "markers");
	}
	void MarkerHooked(int pn, Actor a)
	{
		int i = MarkIndex(a, pn);
		if (i < 0) return;
		int tics = markTics[i];
		String text = tics == MARK_NEAR_TICS ? "+0.25 sec" : "+0.5 sec";
		RSQGR_Util.Word("word.clear", text, 0, 0, a);
		markOn.Delete(i); markPn.Delete(i); markTics.Delete(i);
		int r = RSQGR_Util.SlowMo("g2.addtime", text, tics, players[pn].mo);
		Log(pn, String.Format("MARKER HOOKED: %s, %s (%d tics) -> g2.addtime %d", a.GetClassName(), text, tics, r));
		Event(pn, "marker", a);
	}
	void ClearMarkers(int pn)
	{
		for (int i = markOn.Size() - 1; i >= 0; i--)
		{
			if (pn >= 0 && markPn[i] != pn) continue;
			if (markOn[i]) RSQGR_Util.Word("word.clear", markTics[i] == MARK_NEAR_TICS ? "+0.25 sec" : "+0.5 sec", 0, 0, markOn[i]);
			markOn.Delete(i); markPn.Delete(i); markTics.Delete(i);
		}
	}
	void TickMarkers()
	{
		bool vr = RSQGR_Util.Svc("RSQVR_Service") != null;
		for (int i = markOn.Size() - 1; i >= 0; i--)
		{
			let a = markOn[i];
			if (!a || a.health <= 0) { if (a) RSQGR_Util.Word("word.clear", markTics[i] == MARK_NEAR_TICS ? "+0.25 sec" : "+0.5 sec", 0, 0, a); markOn.Delete(i); markPn.Delete(i); markTics.Delete(i); continue; }
			if (!vr) RSQGR_Fx.Marker(a, RGB_MARK);
		}
	}

	// ---- every tic ------------------------------------------------------------------------------------------------
	override void WorldTick()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.health <= 0)
			{
				if (mode[pn] != M_NONE || claw[pn]) { EndVictim(pn, "you died"); SetMode(pn, M_NONE); HangEnd(pn); if (claw[pn]) claw[pn].Destroy(); claw[pn] = null; }
				chain[pn] = 0; airChain[pn] = false; djReady[pn] = false; flung[pn] = false;
				continue;
			}
			ReadHands(pn, pmo);
			if (hanging[pn])
			{
				pmo.vel = (0, 0, 0);
				if (pmo.Pos.z < hangZ[pn]) pmo.SetZ(hangZ[pn]);
				FullSpeed(pmo);
			}
			switch (mode[pn])
			{
			case M_YANK:
			case M_AIRPULL: TickYank(pn, pmo); break;
			case M_AIRHOLD: TickAirHold(pn, pmo); break;
			case M_SPIKE: TickSpike(pn, pmo); break;
			case M_PULL: TickPull(pn, pmo); break;
			case M_MANTLE: TickMantle(pn, pmo); break;
			case M_SCORP: TickScorp(pn, pmo); break;
			}
			AirTick(pn, pmo);
			prevButtons[pn] = players[pn].cmd.buttons;
		}
		TickMarkers();
	}

	// the air after a kick-off: the ceiling every tic on the way up, the double jump, the landing that ends a chain
	void AirTick(int pn, PlayerPawn pmo)
	{
		bool ground = RSQGR_Util.OnGround(pmo);
		if (mode[pn] == M_NONE && flung[pn] && !ground)
		{
			FullSpeed(pmo);
			if (pmo.vel.Length() > 4) RSQGR_Util.Comfort(pmo, 1.0);
		}
		if (rising[pn])
		{
			double top = pmo.Pos.z + pmo.Height;
			if (pmo.vel.z <= 0) rising[pn] = false;
			else if (top + pmo.vel.z > pmo.ceilingz - 1)
			{
				double vz = max(0.0, pmo.ceilingz - 1 - top);
				Log(pn, String.Format("CEILING CUT: rising %.2f, %.1f units under the ceiling (z %.0f, ceiling %.0f): vel.z -> %.2f", pmo.vel.z, pmo.ceilingz - top, pmo.Pos.z, pmo.ceilingz, vz));
				pmo.vel.z = vz;
				ceilCut[pn] = true;
				if (vz <= 0) rising[pn] = false;
			}
		}
		if (airChain[pn] && djReady[pn] && !ground && mode[pn] == M_NONE)
		{
			int b = players[pn].cmd.buttons;
			if ((b & BT_JUMP) && !(prevButtons[pn] & BT_JUMP))
			{
				djReady[pn] = false;
				double h = clamp(pmo.ceilingz - (pmo.Pos.z + pmo.Height) - 2, 0.0, RSQGR_Util.MetresUp(DJ_UP_M));
				FullSpeed(pmo);
				pmo.player.keepmomentum = true;
				pmo.vel.z = sqrt(2 * max(0.01, pmo.GetGravity()) * h);
				rising[pn] = true;
				int r = RSQGR_Util.SlowMo("g2.addtime", "DoubleJump!", DJ_TICS, pmo);
				Log(pn, String.Format("DOUBLE JUMP: up %.1f units (vel.z %.2f), +0.5 s g2.addtime -> %d", h, pmo.vel.z, r));
				Event(pn, "doublejump");
				PlaceMarkers(pn, pmo);
			}
		}
		if (ground && mode[pn] == M_NONE && !rising[pn])
		{
			if (airChain[pn])
			{
				Log(pn, String.Format("LANDED: the kick-chain ends at %d", chain[pn]));
				Event(pn, "chain.end");
				ClearMarkers(pn);
			}
			chain[pn] = 0;
			airChain[pn] = false;
			djReady[pn] = false;
			flung[pn] = false;
		}
	}
}
