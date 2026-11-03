// WHAT THE WHIP IS DOING, FOR ANY MOD THAT ASKS -- found by name (ServiceIterator), so nothing links against this
// mod and an absent whip is simply no answer (-1). Written 2026-11-03 for RSQ Score (its sheet S17, S18, W1, W4, W11,
// X4): the same request names as RSQ_Grapple's RSQGR_Service wherever the fact is the same, so a scorer asks both.
//
//   let it = ServiceIterator.Find("RSQWP_Service");
//   Service s = it.Next();
//   int t = s ? s.GetInt("wrapped", "", 0, 0, monster) : -1;
//
// THE PLAYER (objectArg = the player's pawn)
//   "swinging"       1 a latched rope holds him and he is off the ground, 0 not
//   "airborne"       1 he is in the air on a flight the rope took part in (from the last floor he stood on until
//                    the next), 0 not
//   "released"       tics since a rope let go of him while he was in the air; -1 none in the last 10 s
//   "landed"         tics since he came down from a roped flight; -1 none in the last 10 s
//   "swings"         latches one after another, each within 2 s of the last letting go (a chain of aimed swings), this
//                    one included; 0 none running
//   "rope.speed"     his speed while a latched rope holds him, map units a tic x 10; -1 not on a rope
//   "released.speed" his speed when a rope last let go of him in the air, x 10; -1 none in the last 10 s
// THE MONSTER (objectArg = the monster)
//   "whipped"        tics since a crack hit it (or a flail's smash struck it); -1 never, or more than 10 s ago
//   "crack.k"        how hard that crack was, 0..100: 0 the softest crack (a quarter of the damage), 100 the
//                    hardest (all of it); -1 never cracked (a sting, a smash)
//   "wrapped"        tics since the thong let go of it (0 while it is wrapped); -1 never, or more than 10 s ago
//   "wrapped.by"     the player number who wrapped it last; -1
//   "yanked"         tics since a yank threw it toward its player; -1
//   "flailing"       1 while it is the thong's swung body now, 0 not
// A MISSILE (objectArg = the missile)
//   "returned"       0 a Return Crack sent it back at its shooter; -1 not
//
// WHEN THE ANSWERS ARE WRITTEN, which is what makes them safe for a scorer: the crack and the smash are noted BEFORE
// the blow lands (whip.zs Crack / Flail call Whipped first), so a scorer hearing the death inside DamageMobj already
// reads "whipped" as 0. The wrap, the yank and the player's flights are kept by WorldTick, which runs after the
// core's (MAPINFO order).
class RSQWP_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let ev = RSQWP_Events.Get();
		if (!ev) return -1;
		return ev.Answer(request, Actor(objectArg));
	}
}

// The ledger. A level handler: saved with the level, empty on a new map.
class RSQWP_Events : EventHandler
{
	const KEEP = 350;          // 10 s: older answers are -1
	const NREC = 32;

	// ---- the monsters ----
	Array<Actor> vA;
	Array<PlayerPawn> vBy;
	Array<int> vWhip, vK, vWrap, vRel, vYank;
	Array<int> vOn;            // wrapped now (0/1)

	// ---- missiles a Return Crack sent back ----
	Array<Actor> retM;
	Array<int> retTic;

	// ---- the players ----
	bool wasRoped[MAXPLAYERS];     // a latched rope held him in the air last tic
	int  relTic[MAXPLAYERS], relSpd[MAXPLAYERS];
	int  landTic[MAXPLAYERS];
	bool flying[MAXPLAYERS];       // in the air, and the rope took part
	bool inAir[MAXPLAYERS];
	bool wasLatched[MAXPLAYERS];   // a rope was latched last tic
	int  unlatchTic[MAXPLAYERS];   // the tic the last latch let go
	int  swings[MAXPLAYERS];       // latches one after another, each within SWING_CHAIN of the last letting go
	bool started;
	const SWING_CHAIN = 70;

	static RSQWP_Events Get() { return RSQWP_Events(EventHandler.Find("RSQWP_Events")); }

	private void Start()
	{
		started = true;
		for (int i = 0; i < MAXPLAYERS; i++) { relTic[i] = -100000; landTic[i] = -100000; relSpd[i] = 0; unlatchTic[i] = -100000; swings[i] = 0; wasLatched[i] = false; }
	}

	// ======================================================== the calls from the whip (play)

	// kept for the core's calls (the Whip's line is a fork of Grapple's; its bite is a snag, not a hook's claw)
	static void Bitten(PlayerPawn by, Actor v, int hand, bool heavy) {}

	// The crack (or a flail's smash) is about to hit it (whip.zs Crack / Flail). k: the crack's weight 0..1, -1 not a crack.
	static void Whipped(Actor v, PlayerPawn by, double k = -1)
	{
		let me = Get();
		if (!me || !v) return;
		int r = me.Rec(v, true);
		me.vWhip[r] = level.maptime;
		if (k >= 0) me.vK[r] = int(clamp(k, 0.0, 1.0) * 100 + 0.5);
		if (!me.vBy[r]) me.vBy[r] = by;
	}

	// The thong wrapped it (whip.zs BeginWrap) / let it go (EndWrap).
	static void Wrapped(Actor v, PlayerPawn by)
	{
		let me = Get();
		if (!me || !v) return;
		int r = me.Rec(v, true);
		me.vWrap[r] = level.maptime;
		me.vOn[r] = 1;
		me.vBy[r] = by;
	}
	static void Unwrapped(Actor v)
	{
		let me = Get();
		if (!me || !v) return;
		int r = me.Rec(v, false);
		if (r < 0 || !me.vOn[r]) return;
		me.vOn[r] = 0;
		me.vRel[r] = level.maptime;
	}

	// A yank threw it toward its player (whip.zs Yank, a light or medium one: it came).
	static void Yanked(Actor v, PlayerPawn by)
	{
		let me = Get();
		if (!me || !v) return;
		int r = me.Rec(v, true);
		me.vYank[r] = level.maptime;
		me.vBy[r] = by;
	}

	// A Return Crack sent this missile back at its shooter (whip.zs ReturnTo).
	static void Returned(Actor m)
	{
		let me = Get();
		if (!me || !m) return;
		for (int k = me.retM.Size() - 1; k >= 0; k--) if (!me.retM[k] || level.maptime - me.retTic[k] > KEEP) { me.retM.Delete(k); me.retTic.Delete(k); }
		if (me.retM.Size() >= 16) { me.retM.Delete(0); me.retTic.Delete(0); }
		me.retM.Push(m); me.retTic.Push(level.maptime);
	}

	// ======================================================== the records

	private int Rec(Actor v, bool make)
	{
		for (int k = 0; k < vA.Size(); k++) if (vA[k] == v) return k;
		if (!make) return -1;
		Prune();
		if (vA.Size() >= NREC) Drop(0);
		vA.Push(v); vBy.Push(null);
		vWhip.Push(-100000); vK.Push(-1); vWrap.Push(-100000); vRel.Push(-100000); vYank.Push(-100000);
		vOn.Push(0);
		return vA.Size() - 1;
	}

	private void Drop(int k)
	{
		vA.Delete(k); vBy.Delete(k);
		vWhip.Delete(k); vK.Delete(k); vWrap.Delete(k); vRel.Delete(k); vYank.Delete(k);
		vOn.Delete(k);
	}

	// gone, or nothing about it newer than KEEP
	private void Prune()
	{
		int now = level.maptime;
		for (int k = vA.Size() - 1; k >= 0; k--)
		{
			if (!vA[k]) { Drop(k); continue; }
			int last = max(max(vWhip[k], vWrap[k]), max(vRel[k], vYank[k]));
			if (!vOn[k] && now - last > KEEP) Drop(k);
		}
	}

	private int Since(int tic) const
	{
		int d = level.maptime - tic;
		return (d >= 0 && d <= KEEP) ? d : -1;
	}

	// ======================================================== the tic (after the core's)

	override void WorldTick()
	{
		if (!started) Start();
		let core = RSQWP_Core(EventHandler.Find("RSQWP_Core"));
		if (!core) return;
		int now = level.maptime;
		if (now % 35 == 0) Prune();
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.Health <= 0) { flying[pn] = false; inAir[pn] = false; wasRoped[pn] = false; continue; }
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj || pmo.waterlevel >= 2;
			bool latched = Latched(core, pn);
			if (latched && !wasLatched[pn]) swings[pn] = (now - unlatchTic[pn] <= SWING_CHAIN) ? swings[pn] + 1 : 1;
			if (!latched && wasLatched[pn]) unlatchTic[pn] = now;
			wasLatched[pn] = latched;
			bool roped = latched && !grounded;
			if (wasRoped[pn] && !roped && !grounded) { relTic[pn] = now; relSpd[pn] = int(pmo.Vel.Length() * 10); }
			wasRoped[pn] = roped;
			if (grounded)
			{
				if (flying[pn]) landTic[pn] = now;
				flying[pn] = false;
				inAir[pn] = false;
				continue;
			}
			inAir[pn] = true;
			if (latched && !flying[pn]) flying[pn] = true;
		}
	}

	static bool Latched(RSQWP_Core core, int pn)
	{
		for (int hand = 0; hand < 2; hand++)
		{
			let h = core.hooks[pn * 2 + hand];
			if (h && h.phase == RSQWP_Hook.PH_LATCH) return true;
		}
		return false;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		Start();
	}

	// ======================================================== the answers

	int Answer(String req, Actor a)
	{
		if (!a) return -1;
		let pmo = PlayerPawn(a);
		if (pmo && pmo.player)
		{
			int pn = pmo.PlayerNumber();
			if (pn < 0 || pn >= MAXPLAYERS) return -1;
			int now = level.maptime;
			let core = RSQWP_Core(EventHandler.Find("RSQWP_Core"));
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			bool latched = core && Latched(core, pn);
			if (req ~== "swinging") return (latched && !grounded) ? 1 : 0;
			if (req ~== "airborne") return (flying[pn] && !grounded) ? 1 : 0;
			if (req ~== "released") return Since(relTic[pn]);
			if (req ~== "landed") return Since(landTic[pn]);
			if (req ~== "rope.speed") return latched ? int(pmo.Vel.Length() * 10) : -1;
			if (req ~== "swings") return (latched || now - unlatchTic[pn] <= SWING_CHAIN) ? swings[pn] : 0;
			if (req ~== "released.speed") return Since(relTic[pn]) >= 0 ? relSpd[pn] : -1;
			return -1;
		}
		if (req ~== "returned")
		{
			for (int k = 0; k < retM.Size(); k++) if (retM[k] == a) return 0;
			return -1;
		}
		int r = Rec(a, false);
		if (r < 0) return -1;
		if (req ~== "whipped") return Since(vWhip[r]);
		if (req ~== "crack.k") return Since(vWhip[r]) >= 0 ? vK[r] : -1;
		if (req ~== "wrapped") return vOn[r] ? 0 : Since(vRel[r]);
		if (req ~== "wrapped.by") return vBy[r] && vBy[r].player ? vBy[r].PlayerNumber() : -1;
		if (req ~== "yanked") return Since(vYank[r]);
		if (req ~== "flailing") return vOn[r];
		return -1;
	}
}
