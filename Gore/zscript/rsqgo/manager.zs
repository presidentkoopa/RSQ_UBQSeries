// ============================================================================
// RSQGO_Manager -- RSQ Gore's one event handler (design/GORE_SYSTEM_DESIGN.md section 2.2). PHASE 1.
//
//   - THE TAKEOVER. CheckReplacement swaps a Brutal Doom / XMVE gore class for our card class (cards.zs) by name: one
//     map read per spawn (RSQGO_Data.byName, keyed by the class name), only while rsqgo_on is true, never IsFinal (the
//     engine then asks again about our class, which is in no table, so it spawns as is). A class not in the generated
//     table stays BD's. With rsqgo_on off, or without BD, nothing changes at all.
//   - THE PLAYSIM QUEUE (saved): actors that must appear later and identically on every machine: BD's floor spot where
//     a drop lands, BD's liquid spot, BD actors a blood spawns after a delay, screen blood given when a drop is in the
//     air. Walked once a tic; no ThinkerIterator, no BlockThingsIterator.
//   - THE COSMETIC SCHEDULE (transient, per machine): particles that start later (a child spawned 2 tics after its
//     parent, the splash where a drop lands, a trail laid one particle a tic) and landing sounds.
//   - BUDGETS (emit.zs): live particles under rsqgo_part_* percent of r_maxparticles; spray density by distance to
//     this machine's camera; the frame-time guard (Quest preset).
//   - rsqgo_debug: one console line every 350 tics.
//
// THE TWO TIERS (section 2.1). Anything that is an actor is decided identically on every machine: server cvars,
// random[RSQGO_Play], positions from geometry traces. Particles may differ per machine and never spawn an actor. User
// cvars are read for cosmetics, and for screen blood only per receiving player (userinfo is the same on every machine).
// ============================================================================

class RSQGO_Manager : EventHandler
{
	// Parking (section 2.4): a thinker in a statnum below STAT_FIRST_THINKING (32) is never ticked. The series' map:
	// 28-30 are taken (Miniboss fx.zs 29, VisualRewards 30); RSQ Gore takes these two (used from phase 2 on).
	const STAT_PARKED_ACTOR = 26;    // landed spots, pools, meat, limbs, casings
	const STAT_PARKED_VT    = 27;    // VisualThinkers drawn by the cosmetic emitter
	const DEBUG_EVERY = 350;

	transient RSQGO_Data data;
	transient CVar cvOn;
	transient RSQGO_Gibs gibs;      // phase 3 (chunks.zs): the chunk takeover table and the ring
	transient RSQGO_ResidueRings res;     // phase 2: floor/ceiling residue rings (residue.zs)

	// ---- the playsim queue (saved: a save made mid-fight still lands its spots)
	enum EQueue { Q_ACTOR, Q_SCREEN }
	Array<int> qDue;
	Array<int> qKind;
	Array<String> qCls;
	Array<double> qPX;
	Array<double> qPY;
	Array<double> qPZ;
	Array<double> qVX;
	Array<double> qVY;
	Array<double> qVZ;
	Array<double> qAng;
	Array<double> qRad;
	int spotCount;              // spots our drops have left this level (Blood That Stays: Some keeps every second one)

	// ---- the cosmetic schedule (emit.zs; transient: particles are not saved either). Parallel arrays, one entry a job.
	transient Array<int> jDue;
	transient Array<int> jKind;
	transient Array<int> jA;            // J_EMIT: variant. J_TRAIL: child spawn index.
	transient Array<int> jB;            // the card
	transient Array<int> jLife;         // J_EMIT: life. J_TRAIL: the tic the parent landed (-1 never).
	transient Array<double> jPX;
	transient Array<double> jPY;
	transient Array<double> jPZ;
	transient Array<double> jVX;
	transient Array<double> jVY;
	transient Array<double> jVZ;
	transient Array<double> jAcc;       // J_EMIT: z acceleration. J_TRAIL: the parent's gravity.
	transient Array<double> jAng;
	transient Array<int> jI;
	transient Array<int> jCount;
	transient Array<int> jInterval;
	transient Array<int> sndCells;      // landing-sound cells used this tic

	// ---- the cosmetic budget and frame state (emit.zs)
	transient Array<int> ring;          // particles that expire at each tic (mod RING): the live count without a scan
	transient int live, capNow, frameTic, oneLeft;
	transient bool frameOk, camOk;
	transient Vector3 camPos;
	transient double densNow, gapEma, lastMs;
	transient uint rngState;

	// ---- scratch results (emit.zs): a flight's end and a child's spawn. Fields, not out-parameters: an out Vector3
	// compiles and then aborts the VM in this engine.
	transient int flyHit, flyT;
	transient Vector3 flyPos, flyDir;
	transient Sector flySector;
	transient Vector3 kidPos, kidVel;
	transient double kidAng;

	// ---- debug counters (transient: they restart after a load)
	transient Map<Name, int> statTake;
	transient int statTakeAll, statParticles, statAvoided, statSpots, statQueued, statCulled;
	transient double statMs;

	static RSQGO_Manager Get()
	{
		return RSQGO_Manager(EventHandler.Find("RSQGO_Manager"));
	}

	bool Ready()
	{
		if (!data)
		{
			data = new("RSQGO_Data");
			data.Build();
		}
		return data.ok;
	}

	bool IsOn()
	{
		if (!cvOn) cvOn = CVar.FindCVar("rsqgo_on");
		return cvOn && cvOn.GetBool();
	}

	override void WorldLoaded(WorldEvent e) { res = RSQGO_ResidueRings.Get(false); }

	// ---------------------------------------------------------------- the takeover
	override void CheckReplacement(ReplaceEvent e)
	{
		if (!e.Replacee || !IsOn() || !Ready()) return;
		int c;
		bool has;
		[c, has] = data.byName.CheckValue(e.Replacee.GetClassName());
		if (!has)
		{
			// phase 3 (chunks.zs): meat, guts, limbs, heads, halves, casings
			Class<Actor> gc = RSQGO_Gibs.Lookup(self, e.Replacee.GetClassName());
			if (gc) { e.Replacement = gc; return; }
			// not a phase 1 class: phase 2's residue takeover (spots, pools, drips, smearers)
			if (!res) res = RSQGO_ResidueRings.Get(true);
			Class<Actor> rc = res ? res.TakeOver(e.Replacee) : null;
			if (rc) e.Replacement = rc;
			return;
		}
		e.Replacement = data.cCls[c];
		if (rsqgo_debug)
		{
			Name n = e.Replacee.GetClassName();
			statTake.Insert(n, statTake.GetIfExists(n) + 1);
			statTakeAll++;
		}
	}

	// ---------------------------------------------------------------- every tic
	override void WorldTick()
	{
		if (res) res.WorldTic();
		if (!data && !qDue.Size()) return;      // nothing taken over on this level, nothing waiting from a save
		double t0 = rsqgo_debug ? MSTimeF() : 0;
		if (qDue.Size()) RunQueue();
		if (data) CosmeticTick();
		if (rsqgo_debug)
		{
			statMs += MSTimeF() - t0;
			if (level.maptime % DEBUG_EVERY == 0) DebugLine();
		}
	}

	// ---------------------------------------------------------------- the playsim queue
	void QueueActor(Class<Actor> cls, Vector3 pos, Vector3 vel, double ang, int delay)
	{
		if (!cls) return;
		if (delay <= 0)
		{
			SpawnQueued(cls, pos, vel, ang);
			return;
		}
		PushQueue(Q_ACTOR, cls.GetClassName(), pos, vel, ang, 0, delay);
	}

	void QueueScreen(String cls, Vector3 pos, double radius, int delay)
	{
		if (delay <= 0)
		{
			GiveScreenBlood(cls, pos, radius);
			return;
		}
		PushQueue(Q_SCREEN, cls, pos, (0, 0, 0), 0, radius, delay);
	}

	private void PushQueue(int kind, String cls, Vector3 pos, Vector3 vel, double ang, double rad, int delay)
	{
		qDue.Push(level.maptime + delay); qKind.Push(kind); qCls.Push(cls);
		qPX.Push(pos.x); qPY.Push(pos.y); qPZ.Push(pos.z);
		qVX.Push(vel.x); qVY.Push(vel.y); qVZ.Push(vel.z);
		qAng.Push(ang); qRad.Push(rad);
		statQueued++;
	}

	private void RunQueue()
	{
		int now = level.maptime;
		// One pass, compacting in place (was a Delete per entry across 11 arrays: O(n) each). The bound is read every
		// pass, so an entry a spawn queues during this walk still runs this tic if it is due, exactly as before; order
		// is kept, so every machine walks the same list the same way.
		int w = 0;
		for (int r = 0; r < qDue.Size(); r++)
		{
			if (qDue[r] > now)
			{
				if (w != r)
				{
					qDue[w] = qDue[r]; qKind[w] = qKind[r]; qCls[w] = qCls[r];
					qPX[w] = qPX[r]; qPY[w] = qPY[r]; qPZ[w] = qPZ[r];
					qVX[w] = qVX[r]; qVY[w] = qVY[r]; qVZ[w] = qVZ[r];
					qAng[w] = qAng[r]; qRad[w] = qRad[r];
				}
				w++;
				continue;
			}
			Vector3 p = (qPX[r], qPY[r], qPZ[r]);
			if (qKind[r] == Q_ACTOR)
			{
				Class<Actor> cls = qCls[r];
				if (cls) SpawnQueued(cls, p, (qVX[r], qVY[r], qVZ[r]), qAng[r]);
			}
			else GiveScreenBlood(qCls[r], p, qRad[r]);
		}
		int n = qDue.Size();
		if (w < n)
		{
			int k = n - w;
			qDue.Delete(w, k); qKind.Delete(w, k); qCls.Delete(w, k);
			qPX.Delete(w, k); qPY.Delete(w, k); qPZ.Delete(w, k);
			qVX.Delete(w, k); qVY.Delete(w, k); qVZ.Delete(w, k);
			qAng.Delete(w, k); qRad.Delete(w, k);
		}
	}

	private void SpawnQueued(Class<Actor> cls, Vector3 pos, Vector3 vel, double ang)
	{
		let a = Actor.Spawn(cls, pos, ALLOW_REPLACE);
		if (!a) return;
		a.angle = ang;
		a.vel = vel;
	}

	// Screen blood (BD: A_RadiusGive("BloodSplasher_*", radius, RGF_PLAYERS, 1)), by A_RadiusGive's own rule
	// (p_actionfunctions.cpp DoRadiusGive): a living player whose centre is within `radius` of the blood and who can see
	// it. One more rule here: that player's own Screen Blood row (rsqgo_screen, userinfo, so every machine reads the
	// same value for that player). Every player is tested, never just the console player.
	void GiveScreenBlood(String cls, Vector3 pos, double radius)
	{
		Class<Inventory> ic = cls;
		if (!ic) return;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i]) continue;
			let mo = players[i].mo;
			if (!mo || mo.health <= 0) continue;
			Vector3 diff = level.Vec3Diff(pos, mo.pos);
			diff.z += mo.height * 0.5;
			if (diff.Length() > radius) continue;
			let cv = CVar.GetCVar("rsqgo_screen", players[i]);
			if (cv && !cv.GetBool()) continue;
			if (!SeesPoint(mo, pos)) continue;
			mo.GiveInventory(ic, 1);
		}
	}

	// A_RadiusGive's sight test is P_CheckSight(player, blood). The blood actor is gone by then, so this traces from the
	// player's centre to the point instead (geometry only: the same on every machine).
	static bool SeesPoint(Actor mo, Vector3 pos)
	{
		Vector3 from = mo.pos + (0, 0, mo.height * 0.5);
		Vector3 d = level.Vec3Diff(from, pos);
		double len = d.Length();
		if (len < 1) return true;
		FLineTraceData t;
		mo.LineTrace(atan2(d.y, d.x), len, -atan2(d.z, d.xy.Length()), TRF_THRUACTORS | TRF_ABSPOSITION,
			from.z, from.x, from.y, t);
		return t.HitType == TRACE_HitNone || t.Distance >= len - 2;
	}

	// ---------------------------------------------------------------- debug
	private void DebugLine()
	{
		String top = "";
		Array<Name> keys;
		Array<int> vals;
		MapIterator<Name, int> it;
		it.Init(statTake);
		while (it.Next())
		{
			// insertion sort by count, largest first
			int v = it.GetValue();
			int at = vals.Size();
			for (int j = 0; j < vals.Size(); j++) if (v > vals[j]) { at = j; break; }
			keys.Insert(at, it.GetKey());
			vals.Insert(at, v);
		}
		for (int j = 0; j < keys.Size() && j < 8; j++)
		{
			String kn = keys[j];
			top = top .. String.Format("%s%s %d", j > 0 ? ", " : "", kn, vals[j]);
		}
		Console.Printf("\cfRSQ Gore\c- t%d: %d takeovers (%s) | %d particles (%d live, cap %d, %d thinned) | %d BD spawns avoided | %d spots, %d queued | %.2f ms",
			level.maptime, statTakeAll, top, statParticles, live, PartCap(), statCulled, statAvoided, statSpots, statQueued,
			statMs / DEBUG_EVERY);
		String gt = RSQGO_Gibs.DebugText(self);	// phase 3: flying / kept chunks
		if (gt != "") Console.Printf("%s", gt);
		statTake.Clear();
		statTakeAll = statParticles = statAvoided = statSpots = statQueued = statCulled = 0;
		statMs = 0;
	}
}
