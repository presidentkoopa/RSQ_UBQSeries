// WHAT A THROWN THING DOES WHEN IT GETS THERE.
//
// The Power Loader's TickFlung and the saber's SlamTick, the same idea twice on
// Quest (report §5.4): keep a short list of thrown actors and their speed last
// tic, and a speed that falls below HALF of last tic's IS the impact -- a wall,
// a floor, a body. Nothing about the object is changed to make this work.
//
// NOT +MISSILE, and the reasons are the design doc's: P_ExplodeMissile jumps
// the actor to Death on the first line it touches (a thrown barrel goes off on
// a doorframe whatever the throw), the whole P_XYMovement branch changes, the
// thrower is passed through, monsters stop treating it as a target, and an actor
// that survives the throw is left PERMANENTLY mutated. The tracker does the
// damage instead, so the object never has to be a missile, never has to be
// shootable, and is never touched.
//
// TWO WAYS TO LAND A HIT:
//
//   SOLID things (a barrel) are stopped by what they hit, and the speed drop
//   says so. The damage goes to everything shootable in reach of the stop.
//
//   NON-SOLID things (every pickup: a clip, a shotgun) are NOT stopped by
//   monsters -- Doom lets them pass straight through. So each tic the tracker
//   also asks whether the object's cylinder is inside a shootable one, and
//   that counts as a hit too, once per victim.
//
// THE NUMBERS: damage is kinetic energy over rsqdg_throw_j (joules per point),
// from the kilograms the pull already uses -- so a keycard stings, a shotgun
// hurts, and a barrel at a run is a weapon. A MASSDEF `impact explode` row (the
// exploding barrel ships one) sets the object off on a hard landing, with the
// thrower credited.
//
// A plain EventHandler: it holds actor pointers and must be saved with them, or
// a save taken mid-throw would come back with the barrel flying and nobody
// watching it land.
class RSQDG_Throw : EventHandler
{
	const MAX_WATCH  = 16;
	const LIFE_TICS  = 105;     // three seconds; nothing flies longer than that
	const STILL_TICS = 6;       // this long under ~0.6 m/s and it has landed
	const MAX_VICTIMS = 4;

	private Actor   wa[MAX_WATCH];       // the object
	private Actor   wBy[MAX_WATCH];      // who threw it -- credit and immunity
	private double  wLast[MAX_WATCH];    // speed last tic, map units/tic
	private double  wLastMps[MAX_WATCH]; // the same, as an impact speed (see ImpactMps)
	private int     wAge[MAX_WATCH];
	private int     wStill[MAX_WATCH];
	private int     wHand[MAX_WATCH];
	private Actor   wHit[MAX_WATCH * MAX_VICTIMS];   // already struck by this throw
	private Vector2 wBody[MAX_WATCH];    // the thrower's own velocity, added at release
	private bool    wAir[MAX_WATCH];     // off the floor last tic (a re-catch now is a mid-air one)

	// ---- the throw ledger: what a SCORER needs to know, after the fact ---------
	//
	// The watch above forgets a throw the tic it lands, and a barrel's blast comes
	// tics after that (its death sequence runs first), so the facts a scorer asks
	// about -- whose throw, how hard it landed, whether the landing set it off --
	// are written here and kept for LOG_TICS. Read through RSQDG_ThrowService
	// (bottom of this file); nothing here changes what a throw does.
	// Serialized with the handler, like the watch.
	const MAX_LOG  = 16;
	const LOG_TICS = 350;       // ten seconds after the release
	private Actor   lgA[MAX_LOG];        // the object
	private Actor   lgBy[MAX_LOG];       // the thrower's pawn
	private int     lgRel[MAX_LOG];      // level.maptime of the release
	private int     lgCms[MAX_LOG];      // impact speed, cm/s; -1 until it lands
	private bool    lgBlast[MAX_LOG];    // its hard landing set it off (or a thrown blast set it off)
	private int     lgJuggle[MAX_LOG];   // mid-air re-catches carried into this throw
	private bool    lgAloft[MAX_LOG];    // taken back into a hand / a pull before it landed

	// ---- the settle list ---------------------------------------------------
	//
	// A released object's collision, size and collectability, still borrowed,
	// put back the first tic each one FITS (hold.zs Restore says why). The
	// single owner of that backup from the moment of release.
	const MAX_SETTLE = 8;
	const SETTLE_GIVEUP = 70;   // two seconds wedged: restore anyway, as before
	private Actor   sa[MAX_SETTLE];
	private bool    sThru[MAX_SETTLE];
	private bool    sSpecial[MAX_SETTLE];
	private double  sRadius[MAX_SETTLE];
	private double  sHeight[MAX_SETTLE];
	private int     sAge[MAX_SETTLE];
	private int     sMin[MAX_SETTLE];

	// Take over the rest of a release. The object stays pass-through, uncollectable
	// and at its carried size until it is clear of everything it would collide
	// with -- and for at least `minTics`.
	void Settle(Actor a, bool thru, bool special, double radius, double height, int minTics)
	{
		if (!a) return;
		int slot = -1;
		for (int i = 0; i < MAX_SETTLE; i++)
		{
			if (sa[i] == a) { slot = i; break; }
			if (!sa[i] && slot < 0) slot = i;
		}
		if (slot < 0)
		{
			// Full (eight things wedged at once): finish the oldest now.
			int oldest = 0;
			for (int i = 1; i < MAX_SETTLE; i++) if (sAge[i] > sAge[oldest]) oldest = i;
			Finish(oldest, true);
			slot = oldest;
		}
		sa[slot] = a; sThru[slot] = thru; sSpecial[slot] = special;
		sRadius[slot] = radius; sHeight[slot] = height;
		sAge[slot] = 0; sMin[slot] = minTics;
		a.bTHRUACTORS = true;
		a.bSPECIAL = false;
		TrySettle(slot);
	}

	// SOMEONE ELSE IS ABOUT TO BORROW IT. Whoever saves its flags next must
	// save the TRUE ones, not the pass-through ones still lent to the settle --
	// the second-claimant trap (report §11.2). So the settle hands everything
	// back first, unconditionally. Called by the flight and the hold before
	// they capture anything.
	void Unsettle(Actor a)
	{
		if (!a) return;
		for (int i = 0; i < MAX_SETTLE; i++) if (sa[i] == a) Finish(i, true);
	}

	bool Settling(Actor a) const
	{
		if (!a) return false;
		for (int i = 0; i < MAX_SETTLE; i++) if (sa[i] == a) return true;
		return false;
	}

	// Put everything back. `force` skips the fit test (giving up, or full).
	private void Finish(int i, bool force)
	{
		Actor a = sa[i];
		sa[i] = null;
		if (!a) return;
		a.bTHRUACTORS = sThru[i];
		if (a.Radius != sRadius[i] || a.Height != sHeight[i])
			a.A_SetSize(sRadius[i], sHeight[i], !force);
		a.bSPECIAL = sSpecial[i];
	}

	private void TrySettle(int i)
	{
		Actor a = sa[i];
		if (!a) { sa[i] = null; return; }
		if (sAge[i] >= SETTLE_GIVEUP) { Finish(i, true); return; }
		if (sAge[i] < sMin[i]) return;

		// SIZE FIRST, tested: A_SetSize with testpos refuses a size that
		// would put it inside a wall or a solid thing.
		if (a.Radius != sRadius[i] || a.Height != sHeight[i])
		{
			bool wasThru = a.bTHRUACTORS;
			a.bTHRUACTORS = sThru[i];
			bool ok = a.A_SetSize(sRadius[i], sHeight[i], true);
			a.bTHRUACTORS = wasThru;
			if (!ok) return;
		}
		// THEN COLLISION: would it be stuck with its own flags back?
		a.bTHRUACTORS = sThru[i];
		if (!a.TestMobjLocation())
		{
			a.bTHRUACTORS = true;
			return;
		}
		Finish(i, false);
	}

	static RSQDG_Throw Get()
	{
		return RSQDG_Throw(EventHandler.Find("RSQDG_Throw"));
	}

	bool Watching(Actor a) const
	{
		if (!a) return false;
		for (int i = 0; i < MAX_WATCH; i++) if (wa[i] == a) return true;
		return false;
	}

	void Watch(Actor a, Actor by, int hand, Vector2 body = (0, 0))
	{
		if (!a) return;
		int slot = -1;
		for (int i = 0; i < MAX_WATCH; i++)
		{
			if (wa[i] == a) { slot = i; break; }
			if (!wa[i] && slot < 0) slot = i;
		}
		// Full: the oldest throw gives way. Sixteen things in the air from
		// one pair of hands means the first of them has long since landed.
		if (slot < 0)
		{
			int oldest = 0;
			for (int i = 1; i < MAX_WATCH; i++) if (wAge[i] > wAge[oldest]) oldest = i;
			slot = oldest;
		}
		wa[slot] = a;
		wBy[slot] = by;
		wLast[slot] = a.Vel.Length();
		wLastMps[slot] = ImpactMps(a, a.Vel, body);
		wAge[slot] = 0;
		wStill[slot] = 0;
		wHand[slot] = hand;
		wBody[slot] = body;
		wAir[slot] = false;
		for (int v = 0; v < MAX_VICTIMS; v++) wHit[slot * MAX_VICTIMS + v] = null;
		LogThrow(a, by);
	}

	// ---- the ledger --------------------------------------------------------

	private int LogFind(Actor a) const
	{
		if (!a) return -1;
		for (int k = 0; k < MAX_LOG; k++)
			if (lgA[k] == a && level.maptime - lgRel[k] <= LOG_TICS) return k;
		return -1;
	}

	private int LogSlot(Actor a)
	{
		int slot = -1, oldest = 0;
		for (int k = 0; k < MAX_LOG; k++)
		{
			if (lgA[k] == a) return k;
			if (!lgA[k] && slot < 0) slot = k;
			if (lgRel[k] < lgRel[oldest]) oldest = k;
		}
		return slot >= 0 ? slot : oldest;
	}

	// A new throw of `a`. If it was caught back out of its previous throw before
	// that one landed, the catch is carried: a juggle.
	private void LogThrow(Actor a, Actor by)
	{
		int prev = LogFind(a);
		int juggle = (prev >= 0 && lgAloft[prev]) ? lgJuggle[prev] + 1 : 0;
		int k = LogSlot(a);
		lgA[k] = a; lgBy[k] = by; lgRel[k] = level.maptime;
		lgCms[k] = -1; lgBlast[k] = false; lgJuggle[k] = juggle; lgAloft[k] = false;
	}

	private void LogLanded(Actor a, double mps)
	{
		int k = LogFind(a);
		if (k >= 0 && lgCms[k] < 0) lgCms[k] = int(mps * 100);
	}

	// Read by RSQDG_ThrowService. -1 when `a` is no recent throw.
	int Ask(String request, Actor a) const
	{
		int k = LogFind(a);
		if (k < 0) return -1;
		if (request ~== "throw.by")     return (lgBy[k] && lgBy[k].player) ? lgBy[k].PlayerNumber() : -1;
		if (request ~== "throw.age")    return level.maptime - lgRel[k];
		if (request ~== "throw.cms")    return lgCms[k];
		if (request ~== "throw.blast")  return lgBlast[k] ? 1 : 0;
		if (request ~== "throw.juggle") return lgJuggle[k];
		return -1;
	}

	// A BLAST IS THE THROWER'S, DOWN THE CHAIN. The engine already credits the kill
	// (a barrel killed through DamageMobj with the thrower as source keeps him as its
	// target, and its A_Explode passes that on -- measured, QZD 17.3 + brutal22test6:
	// three imps killed by a thrown BarrelVOX, every one with target = the player,
	// inflictor = the barrel). What it cannot say is that it was a THROW that set it
	// off; a barrel shot by the same player looks identical. So a barrel that dies to
	// a thrown blast is written down as one too, and so on along the chain.
	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.bIsMonster || !e.Inflictor || e.Inflictor == a) return;
		int src = LogFind(e.Inflictor);
		if (src < 0 || !lgBlast[src]) return;
		if (!(RSQDG_Mass.Flags(a) & RSQDG_Mass.FLIGHT_EXPLODE)) return;
		Actor by = lgBy[src];
		int rel = lgRel[src];
		int k = LogSlot(a);
		lgA[k] = a; lgBy[k] = by; lgRel[k] = rel;
		lgCms[k] = lgCms[src]; lgBlast[k] = true; lgJuggle[k] = lgJuggle[src]; lgAloft[k] = false;
	}

	private void Forget(int i)
	{
		wa[i] = null;
		wBody[i] = (0, 0);
		wBy[i] = null;
		for (int v = 0; v < MAX_VICTIMS; v++) wHit[i * MAX_VICTIMS + v] = null;
	}

	private bool AlreadyHit(int i, Actor t)
	{
		for (int v = 0; v < MAX_VICTIMS; v++) if (wHit[i * MAX_VICTIMS + v] == t) return true;
		return false;
	}

	private void MarkHit(int i, Actor t)
	{
		for (int v = 0; v < MAX_VICTIMS; v++)
		{
			if (!wHit[i * MAX_VICTIMS + v]) { wHit[i * MAX_VICTIMS + v] = t; return; }
		}
	}

	// HOW HARD IT ARRIVED, in metres a second as a body would feel it.
	//
	// DOOM'S GRAVITY IS ABOUT FOUR AND A HALF G. One map unit per tic squared,
	// and vertically 28.3 units is a metre: 35^2 / 28.3 = 43 m/s^2. Read raw, a
	// barrel set down from hand height lands at a speed that in the real world
	// would be a fall from two storeys -- and the first rig run blew one up at
	// the player's feet for exactly that. So the VERTICAL part is scaled by
	// sqrt(g / g_doom): a drop from height h then lands at sqrt(2 g h), what
	// that drop is in the room. Horizontal speed is the throw's own and is left
	// alone.
	//
	// AND ONLY THE ARM'S SPEED COUNTS SIDEWAYS. A throw made while moving
	// carries the body's velocity so the object does not fall behind you -- but
	// Doom walking is ~8 m/s, so counted raw a flick while walking would set a
	// barrel off at the first wall (review). The thrower's velocity at release
	// is stored and taken back out here.
	static double ImpactMps(Actor a, Vector3 v, Vector2 body = (0, 0))
	{
		v = (v.x - body.x, v.y - body.y, v.z);
		double gDoom = a.GetGravity() * TICRATE * TICRATE
			/ (RSQDG_Reach.UNITS_PER_METRE_XY / RSQDG_Reach.PIXELSTRETCH);
		double f = (gDoom > 9.81) ? sqrt(9.81 / gDoom) : 1.0;
		double h = v.xy.Length() / RSQDG_Reach.UNITS_PER_METRE_XY;
		double z = v.z * RSQDG_Reach.PIXELSTRETCH / RSQDG_Reach.UNITS_PER_METRE_XY * f;
		return sqrt(h * h + z * z) * TICRATE;
	}

	// Joules -> points. Never zero for a real hit: anything that registered as
	// an impact at all deserves to be noticed by what it hit.
	private static int DamageFor(double kg, double speedMps, PlayerInfo p)
	{
		double j = 0.5 * kg * speedMps * speedMps;
		double per = max(0.5, RSQDG_Reach.Num("rsqdg_throw_j", p, 15.0));
		return max(1, int(j / per));
	}

	private static bool CanHurt(Actor t, Actor a, Actor by)
	{
		return t && t != a && t != by && t.bSHOOTABLE && t.Health > 0 && !t.bDORMANT;
	}

	// The object's real half-width: a pickup's radius is its pickup trigger
	// (a clip is 20), so it is capped at half its height, as the carry does.
	static double BodyRadius(Actor a)
	{
		return (a is "Inventory") ? min(a.Radius, a.Height * 0.5) : a.Radius;
	}

	// Is t's cylinder overlapping a's?
	private static bool Touching(Actor a, Actor t, double pad)
	{
		Vector2 d = t.Pos.xy - a.Pos.xy;
		if (d.Length() > BodyRadius(a) + t.Radius + pad) return false;
		return a.Pos.z <= t.Pos.z + t.Height + pad && t.Pos.z <= a.Pos.z + a.Height + pad;
	}

	private void Strike(int i, Actor t, double speedMps, PlayerInfo p)
	{
		Actor a = wa[i];
		if (!a || !t) return;
		String an = a.GetClassName(), tn = t.GetClassName();
		int dmg = DamageFor(RSQDG_Mass.Kg(a), speedMps, p);
		MarkHit(i, t);
		// The OBJECT is the inflictor and the THROWER the source: kill credit
		// and infighting both go to whoever threw it, and the kick comes from
		// the direction the object was travelling.
		t.DamageMobj(a, wBy[i], dmg, 'Melee');
		if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
			Console.Printf("[RSQDG] thrown %s hit %s at %.1f m/s for %d", an, tn, speedMps, dmg);
		RSQDG_Events.Tell("throw.hit", wHand[i], t);   // t may be gone (gibbed): null then
	}

	private void Impact(int i, double speedMps, PlayerInfo p)
	{
		Actor a = wa[i];
		LogLanded(a, speedMps);

		// Everything shootable within reach of where it stopped, once each.
		// COLLECTED FIRST, STRUCK AFTER (review): damage inside the iterator
		// can kill and destroy actors -- a gib death, a second barrel going off
		// -- and unlink blockmap nodes the iterator has already stepped to.
		double reach = BodyRadius(a) + 16;
		Array<Actor> victims;
		let it = BlockThingsIterator.Create(a, reach);
		while (it.Next() && victims.Size() < MAX_VICTIMS)
		{
			Actor t = it.thing;
			if (!CanHurt(t, a, wBy[i]) || AlreadyHit(i, t)) continue;
			// The iterator is 2D (report §3.2): range-test the height in script.
			if (!Touching(a, t, 16)) continue;
			victims.Push(t);
		}
		for (int v = 0; v < victims.Size(); v++)
		{
			if (!wa[i]) return;          // the object itself went (a barrel hit a barrel)
			if (victims[v] && victims[v].Health > 0) Strike(i, victims[v], speedMps, p);
		}
		a = wa[i];
		if (!a) return;

		let feel = RSQDG_Feel.Get();
		if (feel) feel.OnImpact(a, p, speedMps, RSQDG_Mass.Heft(a));
		RSQDG_Events.Tell("throw.impact", wHand[i], a);

		// A HARD LANDING SETS OFF WHAT IS MADE TO GO OFF. MASSDEF's `impact
		// explode`; the thrower is the source, so the kill is his. Killed
		// through damage rather than A_Die, so its own death sequence --
		// the explosion -- runs exactly as if it had been shot.
		double hard = RSQDG_Reach.Num("rsqdg_throw_explode", p, 6.0);
		if (hard > 0 && speedMps >= hard
			&& (RSQDG_Mass.Flags(a) & RSQDG_Mass.FLIGHT_EXPLODE)
			&& a.bSHOOTABLE && a.Health > 0)
		{
			if (RSQDG_Reach.Flag("rsqdg_debug", p, false))
				Console.Printf("[RSQDG] thrown %s went off at %.1f m/s", a.GetClassName(), speedMps);
			int k = LogFind(a);
			if (k >= 0) lgBlast[k] = true;      // before the damage: the ledger says why it went off
			a.DamageMobj(null, wBy[i], a.Health, 'None', DMG_FORCED);
		}
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p) return;

		for (int k = 0; k < MAX_SETTLE; k++)
		{
			if (!sa[k]) continue;
			sAge[k]++;
			TrySettle(k);
		}

		for (int i = 0; i < MAX_WATCH; i++)
		{
			Actor a = wa[i];
			if (!a) { if (wBy[i]) Forget(i); continue; }

			// Taken back into a hand, or into the air by a new pull: no longer
			// a throw.
			let hold = RSQDG_Hold.Get();
			let fl = RSQDG_Flight.Get();
			if ((hold && hold.IsHeld(a)) || (fl && fl.IsFlying(a)))
			{
				// Caught back before it landed (it was off the floor last tic): the
				// next throw of it carries the catch (the ledger's juggle).
				int k = LogFind(a);
				if (k >= 0 && wAir[i] && lgCms[k] < 0) lgAloft[k] = true;
				Forget(i);
				continue;
			}

			double speed = a.Vel.Length();
			double mps = ImpactMps(a, a.Vel, wBody[i]);
			double lastMps = wLastMps[i];
			double minMps = RSQDG_Reach.Num("rsqdg_throw_min", p, 3.0);
			wAge[i]++;

			// PASSING THROUGH A BODY. Pickups are not solid and Doom lets them
			// fly through monsters untouched, so overlap is a hit by itself.
			if (!a.bSOLID && mps >= minMps)
			{
				Actor hitT = null;
				let it = BlockThingsIterator.Create(a, BodyRadius(a) + 8);
				while (it.Next())
				{
					Actor t = it.thing;
					if (!CanHurt(t, a, wBy[i]) || AlreadyHit(i, t)) continue;
					if (!Touching(a, t, 0)) continue;
					hitT = t;
					break;
				}
				if (hitT)
				{
					LogLanded(a, mps);
					Strike(i, hitT, mps, p);
					if (!wa[i]) { Forget(i); continue; }
					// It does not sail on through: it hit something, and
					// stops most of its travel there.
					a.Vel *= 0.25;
					speed = a.Vel.Length();
				}
			}

			// THE IMPACT: last tic it was moving fast enough to matter, this
			// tic it has lost more than half of that. A wall, the floor,
			// something solid. Speed taken from BEFORE the stop.
			if (wAge[i] > 1 && lastMps >= minMps && speed < wLast[i] * 0.5)
			{
				// ONE IMPACT PER THROW. What it does after the first stop is a
				// bounce, and a bounce is not a second blow.
				Impact(i, lastMps, p);
				Forget(i);
				continue;
			}

			wLast[i] = speed;
			wLastMps[i] = ImpactMps(a, a.Vel, wBody[i]);
			wAir[i] = a.Pos.Z > a.FloorZ + 2 && !a.bOnMobj;
			if (mps < 0.6) wStill[i]++;
			else wStill[i] = 0;

			if (wStill[i] >= STILL_TICS || wAge[i] >= LIFE_TICS) Forget(i);
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		// A savegame brings its throws back with it -- that is why this is a
		// plain, serialized handler.
		if (e.IsSaveGame) return;
		for (int i = 0; i < MAX_WATCH; i++) Forget(i);
		for (int k = 0; k < MAX_LOG; k++) { lgA[k] = null; lgBy[k] = null; }
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int k = 0; k < MAX_SETTLE; k++) Finish(k, true);
		for (int i = 0; i < MAX_WATCH; i++) Forget(i);
	}
}


// THE THROW, FOR A SCORER (RSQ_Score's physical bonuses), found by name like the
// rig's RSQTR_RigService -- nothing links. Every answer is -1 when there is nothing
// to say.
//   GetInt("throw.by",     "", 0, 0, object)   player number of whoever threw it
//   GetInt("throw.age",    "", 0, 0, object)   tics since it left the hand
//   GetInt("throw.cms",    "", 0, 0, object)   how hard it landed, cm/s (-1 in flight)
//   GetInt("throw.blast",  "", 0, 0, object)   1: its throw set it off (or a thrown blast did)
//   GetInt("throw.juggle", "", 0, 0, object)   times it was caught back out of the air first
//   GetInt("hold.full",    "", hand, 0, pawn)  1 while that hand carries something
// A throw is remembered for ten seconds after the release. The hands, like the rest
// of the grab, are the console player's own (hold.full is 0 for anyone else).
class RSQDG_ThrowService : Service play
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "hold.full")
		{
			let who = Actor(objectArg);
			if (who && who.player != players[consoleplayer]) return 0;
			let hold = RSQDG_Hold.Get();
			return (hold && hold.HandIsFull(intArg & 1)) ? 1 : 0;
		}
		let th = RSQDG_Throw.Get();
		return th ? th.Ask(request, Actor(objectArg)) : -1;
	}
}
