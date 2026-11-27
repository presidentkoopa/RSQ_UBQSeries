// WHAT THE WHIP HAS DONE, FOR ANY MOD THAT ASKS -- found by name (ServiceIterator), so nothing links against this
// mod and an absent whip is simply no answer (-1). Written 2026-11-03 for RSQ Score: the same request names as
// RSQ_Grapple's RSQGR_Service wherever the fact is the same, so a scorer asks both.
//
//   let it = RSQWP_Lookup.Find("RSQWP_Service");
//   Service s = it.Next();
//   int t = s ? s.GetInt("whipped", "", 0, 0, monster) : -1;
//
// 2026-11-27 (owner: "what i want is to do a big wide swing ... and if i crack down to the ground the impact sends out a
// shockwave", "i want to tone this thing down"): the whip has two moves and no rope, wrap, yank, flail or Return Crack,
// so only "whipped" can still happen. Every other name RSQ Score asks is kept and answers what "it has not happened"
// always answered, so no asker has to change:
// THE MONSTER (objectArg = the monster)
//   "whipped"        tics since a Wide Swing hit it or a Ground Crack's shockwave caught it; -1 never, or more than 10 s ago
//   "crack.k"        -1 (the pointed crack, whose weight this was, is gone; RSQ Score's Lashed then pays its flat rate)
//   "wrapped"        -1        "wrapped.by"  -1        "yanked"  -1
//   "flailing"       0 for a monster with a record, -1 without (as before)
// A MISSILE (objectArg = the missile)
//   "returned"       -1
// THE PLAYER (objectArg = the player's pawn)
//   "swinging" 0, "airborne" 0, "swings" 0, "released" -1, "landed" -1, "rope.speed" -1, "released.speed" -1
//
// WHEN "whipped" IS WRITTEN, which is what makes it safe for a scorer: BEFORE the blow lands (lash.zs Sweep calls Whipped
// first), so a scorer hearing the death inside DamageMobj already reads "whipped" as 0.
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
	Array<int> vWhip;

	static RSQWP_Events Get() { return RSQWP_Events(EventHandler.Find("RSQWP_Events")); }

	// ======================================================== the calls from the whip (play)

	// A Wide Swing is about to hit it, or a Ground Crack's shockwave has caught it (lash.zs Sweep / GroundImpact).
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
		vA.Push(v); vBy.Push(null);
		vWhip.Push(-100000);
		return vA.Size() - 1;
	}

	private void Drop(int k)
	{
		vA.Delete(k); vBy.Delete(k);
		vWhip.Delete(k);
	}

	// gone, or nothing about it newer than KEEP
	private void Prune()
	{
		int now = level.maptime;
		for (int k = vA.Size() - 1; k >= 0; k--)
		{
			if (!vA[k]) { Drop(k); continue; }
			if (now - vWhip[k] > KEEP) Drop(k);
		}
	}

	private int Since(int tic) const
	{
		int d = level.maptime - tic;
		return (d >= 0 && d <= KEEP) ? d : -1;
	}

	override void WorldTick()
	{
		if (level.maptime % 35 == 0) Prune();
	}

	// ======================================================== the answers

	int Answer(String req, Actor a)
	{
		if (!a) return -1;
		let pmo = PlayerPawn(a);
		if (pmo && pmo.player)
		{
			// no rope any more: he is never swinging on one, was never let go by one
			if (req ~== "swinging" || req ~== "airborne" || req ~== "swings") return 0;
			return -1;     // "released", "landed", "rope.speed", "released.speed", and anything unknown
		}
		if (req ~== "returned") return -1;
		int r = Rec(a, false);
		if (r < 0) return -1;
		if (req ~== "whipped") return Since(vWhip[r]);
		if (req ~== "flailing") return 0;
		return -1;         // "crack.k", "wrapped", "wrapped.by", "yanked", and anything unknown
	}
}
