// SMOOTH WALKERS (the owner's pick 27, on by default; rsqsm_smooth). apply/05_SLOWMO §4 and 10_TIME §5.2.
//
// A monster does not walk by velocity: A_Chase makes one TryMove of Speed units per state entry
// (P_Move, p_enemy.cpp:502), and the clock slows walking by stretching the states. So a slowed
// walker steps the whole step at once and then stands: at rsm_depth 0.25 a 3-tic walk state lasts 12,
// a step, hold x11 (~2.9 Hz); at 0.4 it lasts 7-8 (~4.7 Hz). Measured on the rig before this was
// built (tools/rigtest, mode 1): see README / HANDOFF.
//
// The fix is §4's "puppeted step": a thinker that runs AFTER the actors (RunThinkers walks the
// statnums upward, dthinker.cpp:145-149; this sits at RSQSM_STAT = 120, above STAT_DEFAULT 100 and
// STAT_VISUALTHINKER 105), sees the full step a walker just took, puts it back to the start of the
// step plus one share, and pays the rest out a share a tic over the state's stretched length, so it
// stands at the end of the step exactly when its next A_Chase runs. SetOrigin(.., true) keeps the
// interpolation (00_CAPABILITIES §7.12): every share is drawn smoothly between tics. What is still
// owed when anything else happens -- a state with no step (an attack, pain), a push, a block, slow
// motion ending -- is paid at once, so a walker never ends up anywhere the engine did not put it.
// A payment into a spot that is no longer free (another thing walked in) waits; the step's end was
// free when the engine checked it, and the next step re-adds whatever is owed.
//
// Only the nearest rsqsm_smooth_max walkers within rsqsm_smooth_range of a player (§4: "the handful of
// monsters nearest the player"); further away the step is not readable.
class RSQSM_Smooth : Thinker
{
	const RSQSM_STAT = 120;

	Array<Actor>  mon;
	Array<State>  lastState;
	Array<double> lx, ly, lz;        // where this left it last tic
	Array<double> ox, oy, oz;        // still owed
	Array<int>    left;              // tics to pay it over
	int pick;

	static RSQSM_Smooth Ensure(RSQSM_Smooth have)
	{
		if (have && !have.bDestroyed) return have;
		let s = new("RSQSM_Smooth");
		s.ChangeStatNum(RSQSM_STAT);
		return s;
	}

	private void Forget(int i)
	{
		mon.Delete(i); lastState.Delete(i); lx.Delete(i); ly.Delete(i); lz.Delete(i);
		ox.Delete(i); oy.Delete(i); oz.Delete(i); left.Delete(i);
	}

	// Move a walker to `to`, drawn smoothly. One on the ground stays ON the ground: its z and floorz are
	// the floor under its whole box there (CheckPosition's), as TryMove leaves them. Measured on the
	// rig: a part-way point over the lower side of a step, left at the in-between height, hung the
	// walker in the air, where P_Move refuses to walk (p_enemy.cpp:522-526), and it lost two steps.
	static bool Put(Actor a, Vector3 to)
	{
		bool grounded = !a.bNOGRAVITY && !a.bFLOAT && a.pos.z <= a.floorz + 0.5;
		FCheckPosition tm;
		if (!a.CheckPosition(to.xy, false, tm)) return false;
		a.SetOrigin(to, true);
		if (grounded) { a.FloorZ = tm.floorz; a.SetZ(tm.floorz); }
		return true;
	}

	// Pay everything owed now, if the spot is free; otherwise it is let go (the walker stays where it is).
	private void Settle(int i)
	{
		Actor a = mon[i];
		if (a && !a.bDestroyed && (ox[i] != 0 || oy[i] != 0 || oz[i] != 0))
			Put(a, a.pos + (ox[i], oy[i], oz[i]));
		ox[i] = 0; oy[i] = 0; oz[i] = 0; left[i] = 0;
		if (a) { lx[i] = a.pos.x; ly[i] = a.pos.y; lz[i] = a.pos.z; }
	}

	private void Release()
	{
		for (int i = mon.Size() - 1; i >= 0; i--) { Settle(i); Forget(i); }
	}

	static bool Walker(Actor a)
	{
		return a && !a.bDestroyed && a.bISMONSTER && a.health > 0 && !a.bDORMANT && !a.player && a.Speed > 0;
	}

	// The nearest walkers in range, from the clock's own list (only slowed things are candidates).
	private void Choose(RSQSM_Clock clock)
	{
		double range = clamp(RSQSM_Clock.Cv("rsqsm_smooth_range", 1024), 128, 4096);
		int most = clamp(int(RSQSM_Clock.Cv("rsqsm_smooth_max", 12)), 1, 64);
		Array<Actor> cand;
		Array<double> dist;
		for (int i = 0; i < clock.act.Size(); i++)
		{
			Actor a = clock.act[i];
			if (!Walker(a) || clock.fac[i] >= 0.9999) continue;
			double best = 1e9;
			for (int p = 0; p < MAXPLAYERS; p++)
				if (playeringame[p] && players[p].mo) best = min(best, level.Vec3Diff(players[p].mo.pos, a.pos).Length());
			if (best > range) continue;
			// insertion by distance, kept to `most`
			int at = dist.Size();
			while (at > 0 && dist[at - 1] > best) at--;
			if (at >= most) continue;
			cand.Insert(at, a); dist.Insert(at, best);
			if (cand.Size() > most) { cand.Pop(); dist.Pop(); }
		}
		// drop the ones no longer chosen (paying what they are owed), add the new ones
		for (int i = mon.Size() - 1; i >= 0; i--)
			if (cand.Find(mon[i]) >= cand.Size()) { Settle(i); Forget(i); }
		for (int i = 0; i < cand.Size(); i++)
		{
			if (mon.Find(cand[i]) < mon.Size()) continue;
			Actor a = cand[i];
			mon.Push(a); lastState.Push(a.CurState);
			lx.Push(a.pos.x); ly.Push(a.pos.y); lz.Push(a.pos.z);
			ox.Push(0); oy.Push(0); oz.Push(0); left.Push(0);
		}
	}

	override void Tick()
	{
		let clock = RSQSM_Clock.Get();
		if (!clock || clock.StoodDown() || !clock.Active() || RSQSM_Clock.Cv("rsqsm_smooth", 1) == 0)
		{
			if (mon.Size()) Release();
			return;
		}
		if (pick-- <= 0) { pick = 8; Choose(clock); }
		bool dev = RSQSM_Body.Dev();
		for (int i = mon.Size() - 1; i >= 0; i--)
		{
			Actor a = mon[i];
			if (!Walker(a)) { if (a && !a.bDestroyed) Settle(i); Forget(i); continue; }
			Vector3 was = (lx[i], ly[i], lz[i]);
			Vector3 d = level.Vec3Diff(was, a.pos);
			double moved = d.xy.Length();
			bool entered = a.CurState != lastState[i];
			double f = clock.FactorFor(a, a.Speed);
			bool stepped = entered && moved > 0.01 && moved <= a.Speed * 1.5 + 2 && a.vel.xy.Length() < 0.5 && f < 0.9999;
			if (stepped)
			{
				// What was still owed is added to this step, so nothing is lost.
				Vector3 owed = (ox[i], oy[i], oz[i]);
				Vector3 goal = a.pos;
				Vector3 withOwed = goal + owed;
				if ((ox[i] != 0 || oy[i] != 0) && a.CheckPosition(withOwed.xy)) goal = withOwed;
				Vector3 total = goal - was;
				// the state this step began lasts tics/f once the clock stretches it (next tic)
				int n = clamp(int(round(max(1, a.tics) / f)), 1, 60);
				Vector3 share = total / n;
				if (n > 1 && Put(a, was + share))
				{
					ox[i] = goal.x - a.pos.x; oy[i] = goal.y - a.pos.y; oz[i] = goal.z - a.pos.z;
					left[i] = n - 1;
				}
				else { ox[i] = 0; oy[i] = 0; oz[i] = 0; left[i] = 0; }     // left where the engine put it
				if (dev && a == mon[0]) Console.Printf("RSQ_SlowMo: smooth %s step %.2f paid over %d tics", a.GetClassName(), total.xy.Length(), n);
			}
			else if (moved > 0.01 || entered)
			{
				// moved by something other than its step, or a state with no step: pay up
				Settle(i);
			}
			else if (left[i] > 0)
			{
				Vector3 share = (ox[i], oy[i], oz[i]) / left[i];
				Vector3 to = a.pos + share;
				Vector3 from = a.pos;
				if (Put(a, to))
				{
					ox[i] -= a.pos.x - from.x; oy[i] -= a.pos.y - from.y; oz[i] -= a.pos.z - from.z;
					left[i]--;
				}
				if (left[i] <= 0) Settle(i);
			}
			lastState[i] = a.CurState;
			lx[i] = a.pos.x; ly[i] = a.pos.y; lz[i] = a.pos.z;
		}
	}

	override void OnDestroy()
	{
		Release();
		Super.OnDestroy();
	}
}
