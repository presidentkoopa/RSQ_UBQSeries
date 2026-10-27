// WHAT THE HOOK IS DOING, FOR ANY MOD THAT ASKS -- found by name (ServiceIterator), so nothing
// links against this mod and an absent grapple is simply no answer (-1 / null).
//
//   let it = ServiceIterator.Find("RSQGR_Service");
//   Service s = it.Next();
//   int t = s ? s.GetInt("hooked", "", 0, 0, monster) : -1;
//
// THE PLAYER (objectArg = the player's pawn; intArg = hand, 0 main / 1 off, where it says so)
//   "hook.phase"   hand: -1 no hook, 0 flying, 1 latched (wall, or a heavy monster used as an
//                  anchor), 2 biting a monster that comes, 3 JP yank hold, 4 coming back
//   "swinging"     1 a latched rope holds him and he is off the ground, 0 not
//   "reeling"      1 a held bind is taking rope in this tic, 0 not
//   "climbing"     1 a hand holds a latched rope (hand over hand), 0 not
//   "airborne"     1 he is in the air on a flight the rope took part in (from the last floor he
//                  stood on until the next), 0 not
//   "released"     tics since a rope let go of him (his tap, or it slipped) while he was in the
//                  air; -1 none in the last 10 s
//   "landed"       tics since he came down from a roped flight; -1 none in the last 10 s
//   "flight.dist"  map units (2D) from where that flight left the floor to where it landed (the
//                  last landing), or so far (in the air); -1 never
//   "flight.drop"  how far below the lower of its two floors the deepest floor under it was; -1
//   "gaps"         gap crossings paid to him on this map (see INDIANA JONES)
// THE MONSTER (objectArg = the monster)
//   "hooked"       tics since it was last on a hook's line (0 while on it: biting, or latched as
//                  a heavy anchor); -1 never, or more than 10 s ago
//   "hooked.by"    the player number who hooked it last; -1
//   "hooked.heavy" 1 it was too heavy to come (an anchor you swung from / reeled to), 0 it came
//   "bites"        hooks that took it one after another, each within 5 s of the last letting go
//   "volleys"      PING-PONG: of those, rehooks after it was sent flying AWAY from the hooker in
//                  between (a Force push, a kick, a bash, a blast: its own velocity, away from
//                  him, at least 6 u/tic of world time) -- read from what it did, not from whose
//                  mod did it
//   "yanked"       1 on the yank's path now, 2 flying on its own after it (cut, or stopped),
//                  0 neither; -1 never hooked
//   "landing"      tics since its own throw hurt it (the landing, or striking a wall or a thing);
//                  -1
//   "struck"       tics since a thrown body struck it (BOWLING); -1
//   "struck.by"    the player number who threw that body; -1
//   "pin"          which thing that body struck it was: 1 the first, 2 the second...; -1
//   "whipped"      tics since the whip's crack hit it; -1
// GUN BONSAI'S VR PATCH (perks.zs keeps these: the hook's XP and its upgrades; objectArg = the pawn)
//   "xp.bites" / "xp.yanks" / "xp.kills" / "xp.killhp" / "xp.slams"   running counts this map: bites,
//                  yanks (thrown), kills the hook was in on (3 s) and their spawn health, Double Hook slams
//   "xp.swing"     units swung in the air on a latched rope this map (at most 1280 a latch)
//   "hook.dealing" 1 while the hook's own blow to anything is being dealt (inside DamageMobj), 0 not
// OBJECTS (GetObject)
//   "hook.victim"  objectArg pawn, intArg hand: the monster on that hand's line, or null
//   "hooked.by"    objectArg monster: the pawn who hooked it
//   "struck.ball"  objectArg monster: the thrown body that struck it
//
// WHEN THE ANSWERS ARE WRITTEN, which is what makes them safe for a scorer: everything that hurts
// is noted BEFORE the blow lands (the throw's landing, its strike, the whip's crack), so a scorer
// hearing the death inside DamageMobj (WorldThingDied) already reads "landing" / "struck" /
// "whipped" as 0. The bite is noted as it happens (core.zs Fly); the rest is read live or kept by
// RSQGR_Events.WorldTick below, which runs after the core's and the throw's (MAPINFO order).
//
// INDIANA JONES (rsqgr_score). A flight the rope took part in that leaves one floor, passes over
// a floor at least 64 units below both ends, and comes down on the far side at least 192 units
// (2D) away is a gap crossed. It is paid once per gap (the pair of sectors it left and landed in,
// either way round) per player per map, through RSQ_Score's door by name
// (RS_ScoreService GetInt("award", "Indiana Jones", points, 0, pawn)): 150 points plus half a
// point per unit past 192, at most 500. Nothing happens without RSQ_Score; the crossing is still
// counted ("gaps"). Landing in deep water (waterlevel 2+) is not a crossing.
class RSQGR_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request.Left(3) ~== "xp." || request ~== "hook.dealing")
		{
			let pk = RSQGR_Perks.Get();
			return pk ? pk.Ask(request, objectArg) : -1;
		}
		let ev = RSQGR_Events.Get();
		if (!ev) return -1;
		return ev.Answer(request, Actor(objectArg), intArg);
	}

	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let ev = RSQGR_Events.Get();
		if (!ev) return null;
		return ev.AnswerObject(request, Actor(objectArg), intArg);
	}
}

// The ledger. A level handler: saved with the level, empty on a new map.
class RSQGR_Events : EventHandler
{
	const KEEP = 350;          // 10 s: older answers are -1
	const CHAIN = 175;         // 5 s: a rehook inside this after letting go continues the chain
	const FLUNG_SPEED = 6.0;   // u/tic of world time, away from the hooker
	const NREC = 32;
	const GAP_DEPTH = 64.0;
	const GAP_DIST = 192.0;

	// ---- the monsters ----
	Array<Actor> vA;
	Array<PlayerPawn> vBy;
	Array<int> vLine, vRel, vBites, vVolleys, vLand, vStruck, vPin, vWhip;
	Array<int> vOn, vFlung, vHeavy;   // bools as ints (0/1)
	Array<Actor> vBall;
	Array<PlayerPawn> vBallBy;

	// ---- the players ----
	bool wasRoped[MAXPLAYERS];     // a latched rope held him in the air last tic
	int  relTic[MAXPLAYERS];
	int  landTic[MAXPLAYERS];
	bool flying[MAXPLAYERS];       // in the air, and the rope took part
	bool inAir[MAXPLAYERS];
	Vector3 gPos[MAXPLAYERS];      // the last floor he stood on
	double gFloor[MAXPLAYERS];
	int gSec[MAXPLAYERS];
	double airMin[MAXPLAYERS];     // the lowest floor under him since he left it
	double fDist[MAXPLAYERS], fDrop[MAXPLAYERS];
	bool everFlew[MAXPLAYERS];
	int gapsPaid[MAXPLAYERS];
	Array<int> gapKey;             // pn * 2^24 + lower sector * 2^12 + higher sector... (see Key)
	bool started;

	static RSQGR_Events Get() { return RSQGR_Events(EventHandler.Find("RSQGR_Events")); }

	private void Start()
	{
		started = true;
		for (int i = 0; i < MAXPLAYERS; i++) { relTic[i] = -100000; landTic[i] = -100000; fDist[i] = -1; fDrop[i] = -1; }
	}

	// ======================================================== the calls from the hook (play)

	// The claw bit a monster (core.zs Fly). heavy: it will not come, it is an anchor.
	static void Bitten(PlayerPawn by, Actor v, int hand, bool heavy)
	{
		let me = Get();
		if (!me || !v || !by) return;
		if (!me.started) me.Start();
		int r = me.Rec(v, true);
		int now = level.maptime;
		bool chain = me.vBites[r] > 0 && me.vBy[r] == by && now - me.vRel[r] <= CHAIN;
		if (chain)
		{
			me.vBites[r]++;
			if (me.vFlung[r]) me.vVolleys[r]++;
		}
		else { me.vBites[r] = 1; me.vVolleys[r] = 0; }
		me.vBy[r] = by;
		me.vLine[r] = now;
		me.vOn[r] = 1;
		me.vFlung[r] = 0;
		me.vHeavy[r] = heavy ? 1 : 0;
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRS t%d bite %s hand %d heavy %d bites %d volleys %d", now, v.GetClassName(), hand, heavy, me.vBites[r], me.vVolleys[r]);
	}

	// A thrown body's own throw is about to hurt it (monster.zs Land / Impact).
	static void Slam(Actor a, PlayerPawn by)
	{
		let me = Get();
		if (!me || !a) return;
		int r = me.Rec(a, true);
		me.vLand[r] = level.maptime;
		if (!me.vBy[r]) me.vBy[r] = by;
	}

	// A thrown body is about to strike another thing (monster.zs Impact): bowling.
	static void Struck(Actor ball, Actor hit, PlayerPawn by)
	{
		let me = Get();
		if (!me || !hit || !ball) return;
		int pins = 0;
		for (int k = 0; k < me.vA.Size(); k++) if (me.vBall[k] == ball && me.vA[k] && me.vA[k] != hit) pins++;
		int r = me.Rec(hit, true);
		me.vStruck[r] = level.maptime;
		if (me.vBall[r] != ball) me.vPin[r] = pins + 1;
		me.vBall[r] = ball;
		me.vBallBy[r] = by;
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRS t%d struck %s by %s pin %d", level.maptime, hit.GetClassName(), ball.GetClassName(), me.vPin[r]);
	}

	// The whip's crack is about to hit it (whip.zs Crack).
	static void Whipped(Actor v, PlayerPawn by)
	{
		let me = Get();
		if (!me || !v) return;
		int r = me.Rec(v, true);
		me.vWhip[r] = level.maptime;
		if (!me.vBy[r]) me.vBy[r] = by;
	}

	// ======================================================== the records

	private int Rec(Actor v, bool make)
	{
		for (int k = 0; k < vA.Size(); k++) if (vA[k] == v) return k;
		if (!make) return -1;
		Prune();
		if (vA.Size() >= NREC) Drop(0);
		vA.Push(v); vBy.Push(null); vBall.Push(null); vBallBy.Push(null);
		vLine.Push(-100000); vRel.Push(-100000); vBites.Push(0); vVolleys.Push(0);
		vLand.Push(-100000); vStruck.Push(-100000); vPin.Push(0); vWhip.Push(-100000);
		vOn.Push(0); vFlung.Push(0); vHeavy.Push(0);
		return vA.Size() - 1;
	}

	private void Drop(int k)
	{
		vA.Delete(k); vBy.Delete(k); vBall.Delete(k); vBallBy.Delete(k);
		vLine.Delete(k); vRel.Delete(k); vBites.Delete(k); vVolleys.Delete(k);
		vLand.Delete(k); vStruck.Delete(k); vPin.Delete(k); vWhip.Delete(k);
		vOn.Delete(k); vFlung.Delete(k); vHeavy.Delete(k);
	}

	// gone, or nothing about it newer than KEEP
	private void Prune()
	{
		int now = level.maptime;
		for (int k = vA.Size() - 1; k >= 0; k--)
		{
			if (!vA[k]) { Drop(k); continue; }
			int last = max(max(vLine[k], vLand[k]), max(vStruck[k], vWhip[k]));
			if (!vOn[k] && now - last > KEEP) Drop(k);
		}
	}

	private int Since(int tic) const
	{
		int d = level.maptime - tic;
		return (d >= 0 && d <= KEEP) ? d : -1;
	}

	// ======================================================== the tic (after core's and the throw's)

	override void WorldTick()
	{
		if (!started) Start();
		let core = RSQGR_Core.Get();
		if (!core) return;
		int now = level.maptime;
		double sc = max(0.05, RSQGR_Core.Scale());

		// who is on a line this tic
		for (int k = 0; k < vA.Size(); k++)
		{
			let v = vA[k];
			if (!v || !vOn[k]) continue;
			bool still = false;
			for (int i = 0; i < RSQGR_Core.NHOOK && !still; i++)
			{
				let h = core.hooks[i];
				still = h && h.victim == v && (h.phase == RSQGR_Hook.PH_BITE || h.phase == RSQGR_Hook.PH_LATCH);
			}
			if (still) { vLine[k] = now; continue; }
			vOn[k] = 0;
			vRel[k] = now;
		}
		// let go of lately: was it sent flying away from the one who hooked it?
		for (int k = 0; k < vA.Size(); k++)
		{
			let v = vA[k];
			if (!v || vOn[k] || vFlung[k] || !vBy[k] || now - vRel[k] > CHAIN) continue;
			Vector2 away = v.Pos.xy - vBy[k].Pos.xy;
			double al = away.Length();
			if (al < 1) continue;
			if ((v.Vel.xy dot (away / al)) / sc >= FLUNG_SPEED)
			{
				vFlung[k] = 1;
				if (RSQGR_Util.Flag("rsqgr_debug", false))
					Console.Printf("T_GRS t%d flung %s at %.1f u/tic", now, v.GetClassName(), (v.Vel.xy dot (away / al)) / sc);
			}
		}
		if (now % 35 == 0) Prune();

		// the players' flights
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.Health <= 0) { flying[pn] = false; inAir[pn] = false; wasRoped[pn] = false; continue; }
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj || pmo.waterlevel >= 2;
			bool latched = false;
			for (int hand = 0; hand < 2; hand++)
			{
				let h = core.hooks[pn * 2 + hand];
				if (h && h.phase == RSQGR_Hook.PH_LATCH) latched = true;
			}
			bool roped = latched && !grounded;
			if (wasRoped[pn] && !roped && !grounded) relTic[pn] = now;
			wasRoped[pn] = roped;

			if (grounded)
			{
				if (flying[pn]) Landed(pmo, pn);
				flying[pn] = false;
				inAir[pn] = false;
				gPos[pn] = pmo.Pos;
				gFloor[pn] = pmo.floorz;
				gSec[pn] = pmo.CurSector ? pmo.CurSector.Index() : -1;
				airMin[pn] = pmo.floorz;
				continue;
			}
			if (!inAir[pn]) { inAir[pn] = true; airMin[pn] = min(gFloor[pn], pmo.floorz); }
			airMin[pn] = min(airMin[pn], pmo.floorz);
			if (latched && !flying[pn]) { flying[pn] = true; everFlew[pn] = true; }
			if (flying[pn]) fDist[pn] = (pmo.Pos.xy - gPos[pn].xy).Length();
		}
	}

	private void Landed(PlayerPawn pmo, int pn)
	{
		int now = level.maptime;
		landTic[pn] = now;
		double dist = (pmo.Pos.xy - gPos[pn].xy).Length();
		double drop = min(gFloor[pn], pmo.floorz) - airMin[pn];
		fDist[pn] = dist;
		fDrop[pn] = drop;
		int sec = pmo.CurSector ? pmo.CurSector.Index() : -1;
		bool gap = pmo.waterlevel < 2 && dist >= GAP_DIST && drop >= GAP_DEPTH && sec != gSec[pn];
		bool dbg = RSQGR_Util.Flag("rsqgr_debug", false);
		if (dbg)
			Console.Printf("T_GRS t%d landed dist %.1f drop %.1f from sector %d (floor %.1f) to %d (floor %.1f), lowest %.1f gap %d",
				now, dist, drop, gSec[pn], gFloor[pn], sec, pmo.floorz, airMin[pn], gap);
		if (!gap) return;
		int key = Key(pn, gSec[pn], sec);
		for (int k = 0; k < gapKey.Size(); k++) if (gapKey[k] == key) { if (dbg) Console.Printf("T_GRS gap already paid"); return; }
		gapKey.Push(key);
		gapsPaid[pn]++;
		if (!RSQGR_Util.Flag("rsqgr_score", true)) return;
		int pts = clamp(150 + int((dist - GAP_DIST) * 0.5), 150, 500);
		int got = Award(pmo, "Indiana Jones", pts);
		if (dbg) Console.Printf("T_GRS t%d Indiana Jones %d points -> paid %d", now, pts, got);
	}

	// the pair of sectors either way round, for one player
	static int Key(int pn, int a, int b)
	{
		int lo = min(a, b) & 0x7FF, hi = max(a, b) & 0x7FF;
		return (pn << 22) | (lo << 11) | hi;
	}

	// POINTS TO THE SERIES' SCORER (RSQ_Score), found by name: nothing happens without it. The label
	// is one of its award rows. -1: not paid.
	static int Award(Actor who, String label, int points)
	{
		if (!who || !who.player || points <= 0) return -1;
		let it = ServiceIterator.Find("RS_ScoreService");
		Service s;
		while (s = it.Next())
		{
			int got = s.GetInt("award", label, points, 0, who);
			if (got >= 0) return got;
		}
		return -1;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		Start();
	}

	// ======================================================== the answers

	int Answer(String req, Actor a, int hand)
	{
		if (!a) return -1;
		let core = RSQGR_Core.Get();
		let pmo = PlayerPawn(a);
		if (pmo && pmo.player)
		{
			int pn = pmo.PlayerNumber();
			if (pn < 0 || pn >= MAXPLAYERS) return -1;
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			if (req ~== "hook.phase")
			{
				let h = core ? core.hooks[pn * 2 + (hand & 1)] : null;
				return h ? h.phase : -1;
			}
			if (req ~== "swinging" || req ~== "reeling" || req ~== "climbing")
			{
				for (int k = 0; k < 2; k++)
				{
					let h = core ? core.hooks[pn * 2 + k] : null;
					if (!h || h.phase != RSQGR_Hook.PH_LATCH) continue;
					if (req ~== "swinging" && !grounded) return 1;
					if (req ~== "reeling" && h.reelHeld) return 1;
					if (req ~== "climbing" && h.gripHand >= 0) return 1;
				}
				return 0;
			}
			if (req ~== "airborne") return (flying[pn] && !grounded) ? 1 : 0;
			if (req ~== "released") return Since(relTic[pn]);
			if (req ~== "landed") return Since(landTic[pn]);
			if (req ~== "flight.dist") return everFlew[pn] ? int(fDist[pn]) : -1;
			if (req ~== "flight.drop") return (everFlew[pn] && fDrop[pn] >= 0) ? int(fDrop[pn]) : -1;
			if (req ~== "gaps") return gapsPaid[pn];
			return -1;
		}
		int r = Rec(a, false);
		if (req ~== "yanked")
		{
			let fl = RSQGR_Flight.Get();
			int s = fl ? fl.SlotOf(a) : -1;
			if (s >= 0) return fl.fph[s] == RSQGR_Flight.FP_PATH ? 1 : 2;
			return r >= 0 && vBites[r] > 0 ? 0 : -1;
		}
		if (r < 0) return -1;
		if (req ~== "hooked") return vBites[r] > 0 ? (vOn[r] ? 0 : Since(vLine[r])) : -1;
		if (req ~== "hooked.by") return vBy[r] && vBy[r].player ? vBy[r].PlayerNumber() : -1;
		if (req ~== "hooked.heavy") return vBites[r] > 0 ? vHeavy[r] : -1;
		if (req ~== "bites") return vBites[r];
		if (req ~== "volleys") return vVolleys[r];
		if (req ~== "landing") return Since(vLand[r]);
		if (req ~== "struck") return Since(vStruck[r]);
		if (req ~== "struck.by") return vBallBy[r] && vBallBy[r].player ? vBallBy[r].PlayerNumber() : -1;
		if (req ~== "pin") return vPin[r] > 0 ? vPin[r] : -1;
		if (req ~== "whipped") return Since(vWhip[r]);
		return -1;
	}

	Object AnswerObject(String req, Actor a, int hand)
	{
		if (!a) return null;
		if (req ~== "hook.victim")
		{
			let pmo = PlayerPawn(a);
			let core = RSQGR_Core.Get();
			if (!pmo || !pmo.player || !core) return null;
			let h = core.hooks[pmo.PlayerNumber() * 2 + (hand & 1)];
			return (h && (h.phase == RSQGR_Hook.PH_BITE || h.phase == RSQGR_Hook.PH_LATCH)) ? h.victim : null;
		}
		int r = Rec(a, false);
		if (r < 0) return null;
		if (req ~== "hooked.by") return vBy[r];
		if (req ~== "struck.ball") return vBall[r];
		return null;
	}
}
