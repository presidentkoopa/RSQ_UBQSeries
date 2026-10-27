// ============================================================================
// RS_ScoreHandler -- the driver. Counts the map, scores the kills, pays the
// rewards. Everything here is play scope.
//
// WHAT REPLACED WHAT, so nobody goes looking for the old machinery:
//   the ACS `kill` script + TID juggling      -> WorldThingDied and real references
//   A_RadiusGive(16383, RGF_NOSIGHT) census   -> ThinkerIterator
//   the 19-name Zandronum monster table       -> gone; the iterator sees everything
//   the Sender_/SToC_ client data channel     -> gone; play state is already shared
//   warping the corpse to test line of sight  -> three LineTraces (see event.zs)
//
// THE ONE RULE: nothing in this file may read consoleplayer, a user cvar, or
// anything else that is one machine's opinion. Scoring has to come out identical
// everywhere. The HUD is the only place that is allowed to care whose screen it is.
// ============================================================================

class RS_ScoreHandler : EventHandler
{
	// ---- this map ----------------------------------------------------------
	int threshold;          // points for one reward
	int utKillsNeeded;      // Untouchable's two thresholds, off the census
	int utHPNeeded;
	int totalMonsters;
	int totalPoints;

	// Monsters that were standing here when the map loaded. A kill of anything not
	// in this list pays reduced base -- that is the anti-farming rule, and because a
	// monster is REMOVED from the list when it dies, an Arch-vile raising the same
	// corpse five times cannot pay five times either.
	private Array<Actor> m_counted;

	private Array<RS_ScoreBonus> m_bonuses;

	// The breakdown's labels and colours, as PLAIN STRINGS, index 0 being the Base
	// row. The HUD is ui scope: it may READ play data but it may not CALL a play
	// function, so asking a bonus for its own name at draw time is not allowed.
	// Resolving them once here, in play scope, is what makes them readable there.
	Array<String> rowName;
	Array<String> rowColor;

	// ------------------------------------------------------------- map start

	override void WorldLoaded(WorldEvent e)
	{
		RS_ScoreRegistry.GetBonuses(m_bonuses);
		BuildRowLabels();

		Census();
		ComputeThreshold();

		// Score_CalcMapPoints' tail: rescale each player's progress against the new
		// map's threshold, so 40% of the way there stays 40% of the way there even
		// though the number itself has changed. scorePercent is kept current every
		// tic, so there is nothing to stash at map exit.
		//
		// The original adds one fixed-point unit here (`percent + 1`) purely because
		// FixedMul truncates. Doubles do not, so there is nothing to counter.
		if (!e.IsSaveGame)
		{
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (!playeringame[i] || !players[i].mo) { continue; }

				let tr = GetTracker(players[i].mo);
				if (!tr) { continue; }

				tr.score = int(threshold * tr.scorePercent);
			}
		}

		if (DebugOn())
		{
			Console.Printf("RS_Score: %d monsters, %d points, threshold %d (UT %d kills / %d hp)",
				totalMonsters, totalPoints, threshold, utKillsNeeded, utHPNeeded);
		}
	}

	// Every monster standing on the map, counted exactly. ACS could not do this: it
	// spawned a dummy and fired A_RadiusGive across the whole map so that every
	// monster would pick up a trigger item that called back, and where the engine
	// lacked RGF_NOSIGHT it fell back to a hardcoded list of nineteen Doom 2 monsters
	// -- which means our own monster pack would have been invisible to it.
	private void Census()
	{
		m_counted.Clear();
		totalMonsters = 0;
		totalPoints   = 0;

		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor a;

		while (a = Actor(it.Next()))
		{
			if (!a.bIsMonster || a.bFriendly || a.health <= 0) { continue; }

			totalMonsters += 1;
			totalPoints   += a.GetSpawnHealth();
			m_counted.Push(a);
		}
	}

	// The formula, from score_levelstart.h. The average monster is worth the
	// same everywhere; what changes is how many of them a map asks you to get
	// through before a reward.
	private void ComputeThreshold()
	{
		int avg = (totalMonsters > 0) ? (totalPoints / totalMonsters) : 0;

		int monMin   = CvarInt("rs_score_monstermin",    140);
		int monMax   = CvarInt("rs_score_monstermax",    800);
		int scalar   = CvarInt("rs_score_monsterscalar",  50);
		int interval = max(CvarInt("rs_score_interval", 5000), 1);

		double mult = (scalar / 100.0) * clamp(totalMonsters, monMin, monMax);
		int    pts  = int(round(avg * mult));

		threshold = max(interval, ((pts + interval / 2) / interval) * interval);

		utKillsNeeded = clamp(totalMonsters / 10,   20,    100);
		utHPNeeded    = clamp(totalPoints   / 10, 2000,  10000);
	}

	// ---------------------------------------------------------------- players

	override void PlayerEntered(PlayerEvent e)
	{
		GiveTracker(e.PlayerNumber);
		ScoreReset(e.PlayerNumber);
	}

	// Score_Reset, reading rs_score_startmode, with the original's four masks.
	//
	//   SMASK_ONLYREWARDS = REGENTIMER | REGENSPENT | EXTRALIVES | HASLIVES
	//   0  SMASK_ALL                            -- wipe everything
	//   1  SMASK_NOTDISPLAY                     -- keep the running total only
	//   2  SMASK_NOTDISPLAY & SMASK_NOTREWARDS  -- keep the total and the rewards
	//   3  0                                    -- keep everything
	//
	// HASLIVES IS NEVER CLEARED. The original says why in a comment worth repeating:
	// it is what stops the player being left in buddha at the start of a map.
	private void ScoreReset(int pln)
	{
		if (pln < 0 || pln >= MAXPLAYERS || !playeringame[pln]) { return; }

		let mo = players[pln].mo;
		if (!mo) { return; }

		let tr = GetTracker(mo);
		if (!tr) { return; }

		int mode = CvarInt("rs_score_startmode", 0);
		if (mode == 3) { tr.lastResetTic = level.maptime; return; }

		bool keepDisplay = (mode == 1 || mode == 2);
		bool keepRewards = (mode == 2);

		tr.score       = 0;
		tr.rewardCount = 0;
		tr.scorePercent = 0.0;

		if (!keepDisplay) { tr.displayScore = 0; }

		if (!keepRewards)
		{
			tr.regenTimer = 0;
			tr.regenSpent = 0;
			tr.extraLives = 0;
		}

		tr.lastResetTic = level.maptime;
	}

	// ------------------------------------------------------- Switcharoo entry
	//
	// The replacement for Dakka_Switcharoo, and the same contract: a weapon calls it
	// from its own fire state with its slot and which trigger fired. Slots are 0..8
	// and fire modes 0..2, and anything outside is ignored.
	//
	//   RS_ScoreHandler.Switcharoo(self, 2, 0);   // slot 2, primary
	//
	// Called from a projectile rather than the player, it takes one hop to that
	// projectile's shooter, exactly as SetActivatorToTarget did there.
	static void Switcharoo(Actor who, int slot, int firemode)
	{
		if (!who) { return; }

		if (!who.player && who.target) { who = who.target; }
		if (!who || !who.player) { return; }

		let tr = GetTracker(who);
		if (tr) { tr.RecordFire(slot, firemode); }
	}

	override void PlayerRespawned(PlayerEvent e)
	{
		GiveTracker(e.PlayerNumber);
	}

	private void GiveTracker(int pln)
	{
		if (pln < 0 || pln >= MAXPLAYERS || !playeringame[pln]) { return; }

		let mo = players[pln].mo;
		if (!mo) { return; }

		if (!mo.FindInventory("RS_ScoreTracker"))
		{
			mo.GiveInventory("RS_ScoreTracker", 1);
		}
	}

	static RS_ScoreTracker GetTracker(Actor mo)
	{
		if (!mo) { return null; }
		return RS_ScoreTracker(mo.FindInventory("RS_ScoreTracker"));
	}

	// Taking a hit ends an Untouchable run. A NODAMAGE player keeps it, which is
	// what stops a scripted hit or a cutscene from wiping the streak.
	override void WorldThingDamaged(WorldEvent e)
	{
		if (!e.Thing || !e.Thing.player) { return; }
		if (e.Damage <= 0) { return; }
		if (e.Thing.bNoDamage) { return; }

		let tr = GetTracker(e.Thing);
		if (tr) { tr.ResetUntouchable(); }
	}

	// ------------------------------------------------------------------ kills

	override void WorldThingDied(WorldEvent e)
	{
		Actor victim = e.Thing;
		if (!victim || !victim.bIsMonster) { return; }

		// Who gets the credit. Start at whoever the victim was last set against,
		// then walk up out of any projectile to the thing that fired it.
		Actor killer = victim.target;
		int guard = 0;
		while (killer && killer.bMissile && killer.target && guard < 8)
		{
			killer = killer.target;
			guard += 1;
		}

		// Killed by the level itself -- a crusher, a damaging floor, a script. These
		// pay nothing.
		if (!killer) { return; }

		bool selfKill  = (killer == victim);
		bool monsterOn = !selfKill && !killer.player && killer.bIsMonster && !killer.bFriendly;
		bool playerKill = (killer.player != null);

		if (!selfKill && !monsterOn && !playerKill) { return; }

		let ev = RS_ScoreEvent.Create(victim, playerKill ? killer : null, e.Inflictor, victim.DamageTypeReceived);
		ev.selfInflicted    = selfKill;
		ev.monsterOnMonster = monsterOn;
		ev.utKillsNeeded    = utKillsNeeded;
		ev.utHPNeeded       = utHPNeeded;

		// Anti-farming. A monster that was not on the map at load -- spawned by a
		// script, raised from the dead, a Lost Soul thrown by a Pain Elemental --
		// pays a fraction. Taking it off the list here is what stops the same
		// corpse being farmed by an Arch-vile.
		// Compared by hand rather than with Array.Find: Find on an array of object
		// references does not reliably report a miss, which quietly turned this whole
		// rule off -- a dummy spawned after the census still paid full base.
		int at = -1;
		for (int i = 0; i < m_counted.Size(); i++)
		{
			if (m_counted[i] == victim) { at = i; break; }
		}

		if (at < 0)
		{
			int pct = clamp(CvarInt("rs_score_farmpercent", 25), 0, 100);
			ev.basePoints = (ev.basePoints * pct) / 100;
		}
		else
		{
			m_counted.Delete(at);
		}

		if (selfKill || monsterOn)
		{
			AwardEveryone(ev);
			return;
		}

		AwardKiller(ev);
	}

	// A monster killed itself, or killed another monster. Nobody earned it, so
	// everybody is paid: base plus the one bonus that applies. These used to live in
	// separate scripts; here they are ordinary bonuses that simply cannot fire on a
	// player kill, which keeps them visible in the breakdown like any other.
	private void AwardEveryone(RS_ScoreEvent ev)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) { continue; }

			let tr = GetTracker(players[i].mo);
			if (!tr) { continue; }

			ev.tracker   = tr;
			ev.killerNum = i;

			int total = ev.basePoints;
			EnsureRows(tr);
			AddRow(tr, -1, ev.basePoints);

			for (int b = 0; b < m_bonuses.Size(); b++)
			{
				double m = m_bonuses[b].Evaluate(ev);
				if (m <= 0.0) { continue; }

				int points = int(round(ev.basePoints * m));
				total += points;
				AddRow(tr, b, points);
			}

			Array<double> everyMults;
			for (int b = 0; b < m_bonuses.Size(); b++) { everyMults.Push(0.0); }
			DebugAward("everyone", ev, everyMults);

			Pay(tr, total);
		}
	}

	// The full pass, for a kill a player earned.
	private void AwardKiller(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) { return; }

		EnsureRows(tr);

		// 1. Ask everyone. Nothing is written yet, so no bonus can change another
		//    bonus's answer.
		Array<double> mults;
		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			mults.Push(m_bonuses[b].Evaluate(ev));
		}

		// 2. Drop anything a firing bonus supersedes. Swan Song over Redline.
		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			if (mults[b] <= 0.0) { continue; }

			for (int o = 0; o < m_bonuses.Size(); o++)
			{
				if (o == b || mults[o] <= 0.0) { continue; }
				if (m_bonuses[b].Supersedes(m_bonuses[o])) { mults[o] = 0.0; }
			}
		}

		// 3. Cap per family, then in total. Both default to off, so out of the box
		//    the numbers are the original's exactly.
		Array<double> famSum;
		famSum.Resize(3);

		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			if (mults[b] > 0.0) { famSum[m_bonuses[b].Family()] += mults[b]; }
		}

		Array<double> famCap;
		famCap.Resize(3);
		famCap[RS_ScoreBonus.FAM_EFFICIENCY] = CvarInt("rs_score_cap_efficiency", 0) / 100.0;
		famCap[RS_ScoreBonus.FAM_STYLE]      = CvarInt("rs_score_cap_style",      0) / 100.0;
		famCap[RS_ScoreBonus.FAM_DARING]     = CvarInt("rs_score_cap_daring",     0) / 100.0;

		for (int f = 0; f < 3; f++)
		{
			if (famCap[f] <= 0.0 || famSum[f] <= famCap[f]) { continue; }

			double scale = famCap[f] / famSum[f];
			for (int b = 0; b < m_bonuses.Size(); b++)
			{
				if (mults[b] > 0.0 && m_bonuses[b].Family() == f) { mults[b] *= scale; }
			}
		}

		double totalMult = 0.0;
		for (int b = 0; b < m_bonuses.Size(); b++) { totalMult += max(0.0, mults[b]); }

		double totalCap = CvarInt("rs_score_cap_total", 0) / 100.0;
		if (totalCap > 0.0 && totalMult > totalCap)
		{
			double scale = totalCap / totalMult;
			for (int b = 0; b < m_bonuses.Size(); b++) { mults[b] *= scale; }
		}

		// 4. Pay. Base, then each surviving bonus as its own row so the breakdown
		//    can show what earned what.
		DebugAward("killer", ev, mults);

		int total = ev.basePoints;
		AddRow(tr, -1, ev.basePoints);

		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			if (mults[b] <= 0.0) { continue; }

			int points = int(round(ev.basePoints * mults[b]));
			total += points;
			AddRow(tr, b, points);
		}

		Pay(tr, total);

		// 5. Only now does anything remember this kill -- and EVERY bonus is told,
		//    not just the ones that paid. The original called AddKillstreak after every
		//    kill for a reason: a streak bonus pays nothing on the first kill, so if
		//    only paying bonuses were committed the streak could never start and
		//    Spree would silently read zero forever. A bonus decides for itself
		//    whether this kill was worth remembering.
		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			m_bonuses[b].Commit(ev);
		}

		tr.AddUntouchable(ev.victimSpawnHealth);
	}

	// ---------------------------------------------------------------- payment

	private void Pay(RS_ScoreTracker tr, int points)
	{
		if (points == 0) { return; }

		int before = tr.score;
		tr.AddScore(points);
		tr.flashTic = level.maptime;

		// PUBLISH GAINS TO THE NATIVE SCORE FIELD, AND ONLY GAINS. Actor.Score is a field
		// the engine never uses for anything itself ("The engine doesn't use this itself
		// for anything", src/playsim/actor.h:2372) -- it exists as a convention between
		// mods, and a mod reading it is the whole point. Our own total stays on the
		// tracker; this is a one-way mirror of what was earned, not a second copy that has
		// to be kept in step with ours.
		//
		// NEVER SUBTRACT FROM IT, and the reason is that the readers of this convention
		// take a RISE, not a total. Gun Bonsai baselines the field and pays weapon XP for
		// the increase alone, once a tic
		// (GunBonsai-Offhand-VR/ca.ancilla.bonsai/PerPlayerStats.zsc:1237-1270: `prevScore`,
		// then `owner.score > prevScore`). A fall is invisible to it, so the points are
		// simply lost; and to a reader that does hold a total, clawing points back makes XP
		// it has already SPENT look like it vanished, or drives the field negative and
		// poisons every other reader. So a negative payment, if a bonus ever manages to
		// produce one, is ours to absorb on the tracker and is not published.
		//
		// DO NOT MISTAKE THIS FOR OUR RUNNING TOTAL, AND DO NOT READ IT BACK AS ONE. The
		// engine hands the player a fresh pawn on every map and nothing in C++ copies Score
		// onto it -- the only two writes are ACS SetActorProperty (src/playsim/p_acs.cpp:4268)
		// and the mapthing's own score (src/playsim/p_mobj.cpp:7170) -- so the field is zero
		// at every map start no matter what ScoreReset does, and ScoreReset has nothing to
		// undo here. It outlives only a savegame and hub travel, where the pawn itself
		// does. tr.displayScore is the total a player reads.
		//
		// The owner check is because an Inventory token in flight has none; the tracker is
		// only ever given straight to a pawn, but a null here would be a VM abort.
		if (points > 0 && tr.owner) { tr.owner.score += points; }

		if (DebugOn())
		{
			Console.Printf("RS_Score: +%d -> %d (threshold %d) | rewards %d lives %d buddha %d regen %d",
				points, tr.displayScore, threshold,
				tr.rewardCount, tr.extraLives, tr.hasLives ? 1 : 0, tr.regenTimer);
		}

		CheckRewards(tr, before, tr.score);
	}

	// Debug only: says which path paid, what the base was, and which bonuses fired.
	// A scorer that pays the right-looking total down the wrong path is the failure
	// mode that survives a smoke test, so the path is named out loud.
	private void DebugAward(String path, RS_ScoreEvent ev, Array<double> mults)
	{
		if (!DebugOn()) { return; }

		String line = String.Format("RS_Score[%s]: %s spawnhp %d base %d counted %d | spree n=%d exp=%d t=%d | ut k=%d hp=%d st=%d",
			path, ev.victim.GetClassName(), ev.victimSpawnHealth, ev.basePoints, m_counted.Size(),
			ev.tracker ? ev.tracker.spreeCount : -1,
			ev.tracker ? ev.tracker.spreeExpire : -1,
			level.maptime,
			ev.tracker ? ev.tracker.utKills : -1,
			ev.tracker ? ev.tracker.utHP : -1,
			ev.tracker ? ev.tracker.utStacks : -1);

		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			if (b < mults.Size() && mults[b] > 0.0)
			{
				line = line .. String.Format(" | %s %.3f", m_bonuses[b].DisplayName(), mults[b]);
			}
		}

		Console.Printf("%s", line);
	}

	// ---- the breakdown rows the HUD reads ----------------------------------
	// Index -1 is the Base row; 0..n-1 are the bonuses in registry order.

	private void EnsureRows(RS_ScoreTracker tr)
	{
		int want = m_bonuses.Size() + 1;
		if (tr.rowValue.Size() == want) { return; }

		tr.rowValue.Resize(want);
		tr.rowTic.Resize(want);
	}

	private void AddRow(RS_ScoreTracker tr, int bonusIndex, int points)
	{
		if (points <= 0) { return; }

		int row = bonusIndex + 1;
		if (row < 0 || row >= tr.rowValue.Size()) { return; }

		// A row accumulates while it is still on screen rather than being replaced, so
		// three quick point-blank kills read as one growing number.
		if (tr.rowTic[row] <= 0) { tr.rowValue[row] = 0; }

		tr.rowValue[row] += points;
		tr.rowTic[row]    = level.maptime;
	}

	// ---------------------------------------------------------------- rewards

	private void CheckRewards(RS_ScoreTracker tr, int before, int after)
	{
		if (threshold <= 0) { return; }
		if (CvarInt("rs_score_rewardtypes", 0) == 4) { return; }

		int crossings = (after / threshold) - (before / threshold);
		if (crossings <= 0) { return; }

		int newLives = 0;

		for (int i = 0; i < crossings; i++)
		{
			bool giveLife;

			switch (CvarInt("rs_score_rewardtypes", 0))
			{
				default: giveLife = (tr.rewardCount % 2) == 1; break;
				case 1:  giveLife = (tr.rewardCount % 2) == 0; break;
				case 2:  giveLife = false; break;   // lives off
				case 3:  giveLife = true;  break;   // regen off
			}

			if (giveLife)
			{
				tr.extraLives += 1;
				newLives += 1;
			}
			else
			{
				// 20 seconds, plus the tic it is consumed on.
				tr.regenTimer += (35 * 20) + 1;
			}

			tr.rewardCount += 1;
		}

		// Score_Award's presentation, transcribed.
		//
		//   LocalAmbientSound("dakka/pointreward", 127)
		//   FadeRange(128,212,255, 1.0 - 0.65^n, 128,212,255, 0, 0.75)
		//   and if any of them was a life, after a 24 tic delay:
		//   LocalAmbientSound("dakka/fullheal", 127)
		//   FadeRange(192,224,255, 1.0 - 0.5^n, 192,124,255, 0.0, 0.75)
		//
		// CHANF_LOCAL is what LocalAmbientSound meant: heard only by the player who
		// earned it, which is also what keeps it out of everyone else's ears in co-op.
		if (tr.owner)
		{
			tr.owner.A_StartSound("rsscore/pointreward", CHAN_VOICE, CHANF_LOCAL, 1.0, ATTN_NONE);

			double a = 1.0 - (0.65 ** crossings);
			tr.owner.A_SetBlend("80 D4 FF", a, 26, "80 D4 FF", 0.0);
		}

		tr.rewardTic = level.maptime;

		if (newLives > 0)
		{
			// The 24 tic Delay before the second cue. Scheduled rather than slept on,
			// and picked up in WorldTick.
			tr.rewardLifeTic  = level.maptime + 24;
			tr.pendingLives   = newLives;
		}
	}

	// The delayed half of Score_Award.
	private void RunRewardCue(Actor mo, RS_ScoreTracker tr)
	{
		if (tr.rewardLifeTic <= 0 || level.maptime < tr.rewardLifeTic) { return; }

		int n = max(1, tr.pendingLives);

		mo.A_StartSound("rsscore/fullheal", CHAN_VOICE, CHANF_LOCAL, 1.0, ATTN_NONE);

		double a = 1.0 - (0.5 ** n);
		mo.A_SetBlend("C0 E0 FF", a, 26, "C0 7C FF", 0.0);

		tr.rewardLifeTic = 0;
		tr.pendingLives  = 0;
	}

	// ------------------------------------------------------------------- tick

	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) { continue; }

			let tr = GetTracker(players[i].mo);
			if (!tr) { continue; }

			// Score_DoRewards recalculated the percentage every tic. Keep that: it is
			// what the next map's threshold is scaled against.
			tr.CalcScorePercent(threshold);

			ExpireRows(tr);
			RunRewardCue(players[i].mo, tr);
			RunAmmoRegen(players[i].mo, tr);
			RunExtraLives(players[i].mo, tr);
		}
	}

	// A row leaves the breakdown after its display time. The time itself is a user
	// cvar -- one person's screen -- so the tic is kept here and the HUD decides
	// when it has been long enough.
	private void ExpireRows(RS_ScoreTracker tr)
	{
		for (int r = 0; r < tr.rowTic.Size(); r++)
		{
			if (tr.rowTic[r] <= 0) { continue; }

			// 193 is the largest display time the HUD will honour (the original's own
			// clamp), so clearing at that point can never cut a row short on any
			// screen -- while the HUD still hides it at whatever the local setting is.
			//
			// This is the one place the original is deliberately NOT followed: it read
			// the viewer's own dakka_cl_bonustime here, in server-side code. Doing that
			// makes a game-state value depend on one machine's setting, which is a
			// desync. The observable behaviour is identical.
			if (level.maptime - tr.rowTic[r] > 193)
			{
				tr.rowTic[r]   = 0;
				tr.rowValue[r] = 0;
			}
		}
	}

	// GENERALISED ON PURPOSE. The original regenerated a hardcoded list of its own
	// eight ammo classes at fixed rates per 20 seconds, which does nothing for any
	// other weapon set. This gives back a percentage of each ammo type the player
	// actually carries, so it works for Vanilla, Modern, BD22 and anything else.
	// The amounts therefore cannot be the original's, and the percentage is a cvar.
	private void RunAmmoRegen(Actor mo, RS_ScoreTracker tr)
	{
		if (tr.regenTimer <= 0)
		{
			if (tr.regenSpent > 0) { tr.regenSpent = 0; }
			return;
		}

		int pct = clamp(CvarInt("rs_score_regenpercent", 40), 0, 400);
		int step = tr.regenSpent;

		for (let item = mo.Inv; item != null; item = item.Inv)
		{
			let am = Ammo(item);
			if (!am || am.MaxAmount <= 0) { continue; }

			// The whole burst is 700 tics; hand out the slice that falls on this one,
			// computed from the running totals so rounding cannot drift.
			int perBurst = (am.MaxAmount * pct) / 100;
			int had  = (step       * perBurst) / 700;
			int now  = ((step + 1) * perBurst) / 700;

			if (now > had) { mo.GiveInventory(am.GetClass(), now - had); }
		}

		tr.regenSpent += 1;
		tr.regenTimer -= 1;
	}

	// Extra lives hold the player in buddha and catch them at 1 hp.
	// The revival's fire-and-explosion actors have not been brought across; the
	// mechanic is here and the spectacle is a later decision.
	private void RunExtraLives(Actor mo, RS_ScoreTracker tr)
	{
		let p = mo.player;
		if (!p) { return; }

		if (tr.extraLives > 0)
		{
			if (!tr.hasLives)
			{
				tr.hasLives = true;
				p.cheats |= CF_BUDDHA;

				if (DebugOn())
				{
					Console.Printf("RS_Score: buddha ON (%d lives held)", tr.extraLives);
				}
			}

			// DIED ANYWAY. Score_CheckRevival's first branch, and it matters: buddha
			// does not stop forced damage, a telefrag, or the kill cheat. When the
			// player goes down regardless, the lives are spent and the hold comes off --
			// otherwise they respawn still holding buddha with a stale life count.
			if (mo.health <= 0)
			{
				tr.extraLives = 0;
				tr.hasLives   = false;
				p.cheats &= ~CF_BUDDHA;

				if (DebugOn())
				{
					Console.Printf("RS_Score: died through the hold -- lives cleared, buddha OFF");
				}

				return;
			}

			if (mo.health == 1)
			{
				mo.health = mo.GetMaxHealth(true);
				p.health  = mo.health;

				tr.extraLives -= 1;
				tr.reviveTic = level.maptime;

				if (DebugOn())
				{
					Console.Printf("RS_Score: REVIVED at tic %d -- health %d, %d lives left",
						level.maptime, mo.health, tr.extraLives);
				}

				if (tr.extraLives <= 0)
				{
					tr.hasLives = false;
					p.cheats &= ~CF_BUDDHA;
				}
			}
		}
		else if (tr.hasLives)
		{
			tr.hasLives = false;
			p.cheats &= ~CF_BUDDHA;
		}
	}

	// ------------------------------------------------------- read by the HUD

	// Row 0 is Base; rows 1..n are the bonuses in registry order, which is the same
	// order tracker.rowValue uses.
	private void BuildRowLabels()
	{
		rowName.Clear();
		rowColor.Clear();

		rowName.Push("Base");
		rowColor.Push("RSScore_Base");

		for (int i = 0; i < m_bonuses.Size(); i++)
		{
			rowName.Push(m_bonuses[i].DisplayName());
			rowColor.Push(m_bonuses[i].FamilyColor());
		}
	}

	// ----------------------------------------------------------------- helpers

	static int CvarInt(String name, int fallback)
	{
		// A server cvar read from play scope is the same on every machine. Looking
		// one up that does not exist returns null, and GetInt on null aborts the VM
		// and takes the map with it -- so the fallback is not politeness.
		let cv = CVar.FindCVar(name);
		return cv ? cv.GetInt() : fallback;
	}

	static bool DebugOn()
	{
		let cv = CVar.FindCVar("rs_score_debug");
		return cv ? cv.GetBool() : false;
	}
}
