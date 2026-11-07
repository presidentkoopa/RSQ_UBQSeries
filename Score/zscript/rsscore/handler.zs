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
	// the first breakdown row of each bonus (a bonus may have several: RowCount, bonus.zs)
	private Array<int> m_rowBase;

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
	// WHAT IS A KILL. A monster the level counts toward its kills (+COUNTKILL) -- not any actor
	// flagged a monster. Brutal Doom spawns helper actors that carry ISMONSTER and big health
	// and "die" as effects play out: one Brutal Doom imp (80 health) scored 1305, because a
	// blood smear (BootSmearerRed, 1000 health) died too and was paid as a kill (measured on
	// QZD 17.3 with brutal22test6; the engine's own kill count said 1). Lost Souls are the one
	// real monster Doom leaves uncounted, and Dakka paid for them, so they still count.
	//
	// AND A REPLACEMENT OF A REAL MONSTER, whatever its flags say. A monster set may rename a stock
	// monster and drop its COUNTKILL: Brutal Doom's WolfensteinSS is EvilMarine, a real soldier that
	// the level does not count (measured, rig B: five killed, none in killed_monsters, so none were
	// paid). Its replacee is a counted monster, so it is a kill. Brutal Doom's helpers (the smears,
	// Dying_Headshot, DyingSergeant, PoorPinkyLostHisArm) are spawned by name and replace nothing,
	// so they stay out.
	static bool IsScorable(Actor a)
	{
		if (!a || !a.bIsMonster) return false;
		if (a.bCountKill) return true;
		// AN EXTRA BODY ANOTHER MOD SPAWNED is not a kill whatever it replaces (boost.zs NOT_A_KILL):
		// Champions' Indigo clones keep the parent's class and lose COUNTKILL, so with Brutal Doom (whose
		// classes replace counted monsters) every clone paid a full base, and in vanilla none did.
		if (RS_Boost.NotAKill(a)) return false;
		class<Actor> ls = "LostSoul";
		class<Actor> mine = a.GetClass();
		class<Actor> was = Actor.GetReplacee(mine);
		if (ls && (a is ls || was == ls)) return true;
		if (!was || was == mine) return false;
		let def = GetDefaultByType(was);
		return def && def.bIsMonster && def.bCountKill;
	}

	private void Census()
	{
		m_counted.Clear();
		totalMonsters = 0;
		totalPoints   = 0;

		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor a;

		while (a = Actor(it.Next()))
		{
			if (!IsScorable(a) || a.bFriendly || a.health <= 0) { continue; }

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

		// the HUD's reward glow runs off these tics; a new map's clock starts again at 0, so an old one could light it
		tr.rewardTic  = 0;
		tr.lifeCueTic = 0;

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

	// Taking a hit ends an Untouchable run (WorldThingDamaged, below with the boost marks). A NODAMAGE player keeps it,
	// which is what stops a scripted hit or a cutscene from wiping the streak.

	// ------------------------------------------------------------------ kills

	override void WorldThingDied(WorldEvent e)
	{
		Actor victim = e.Thing;
		RS_Boost.NoteDeath(self, victim);   // boost.zs: an Undying champion's heart, before its master
		if (!victim || !IsScorable(victim)) { return; }

		// ONE BODY, ONE KILL. A morphed monster's death kills its original first (AActor::Die calls
		// the original's Die before its own WorldThingDied, p_interaction.cpp), and both are
		// monsters: the original is paid and names its morph (Alternative) as paid with it, so the
		// morph's own death on the same tic is not paid again. Measured, rig B: an imp morphed into a
		// counted monster and killed paid 63 + 11 before this.
		if (WasScored(victim) || (victim.Alternative && WasScored(victim.Alternative))) { return; }

		// Who gets the credit: the killing blow's damage source (RS_ScoreShots heard it in
		// WorldThingDamaged, just before Die), walked up out of any projectile to the thing that
		// fired it. NOT victim.target alone: Die() sets the target to the source only when there IS
		// a source (p_interaction.cpp), so a monster that was chasing you and died in a crusher still
		// had you as its target -- and was paid to you as your kill (measured, rig B: an imp crushed
		// with no source paid 60 + Spree). The target is the fallback for a death that came some
		// other way than a blow.
		Actor src; bool known;
		[src, known] = RS_ScoreShots.KillSource(victim);
		Actor killer = known ? src : victim.target;
		int guard = 0;
		while (killer && killer.bMissile && killer.target && guard < 8)
		{
			killer = killer.target;
			guard += 1;
		}

		bool playerKill = killer && killer.player != null;

		// BORN DEAD. A Pain Elemental's Lost Soul that has no room is killed in the tic it was
		// spawned, by the Elemental itself (painelemental.zs A_PainShootSkull: ClearCounters, then
		// DamageMobj(self, self, TELEFRAG_DAMAGE)). Lost Souls count, so each of those paid every
		// player as Infighter (measured, rig B: 8 of 13 Lost Soul deaths in a vanilla sweep). No
		// player did anything: a monster that never lived a tic pays nothing unless a player killed it.
		if (!playerKill && victim.GetAge() <= 1) { return; }

		// RING OUT. The level (a crusher, a pit) or another monster finished it, but a player's
		// Force, kick, punch or bash had just sent it there: that player earned it (melee.zs).
		Actor pusher = null;
		if (!playerKill && victim.GetAge() > 1)
		{
			pusher = RS_ScoreShots.LaunchedBy(victim);
			if (pusher && pusher == killer) pusher = null;
		}

		if (!pusher)
		{
			// Killed by the level itself -- a crusher, a damaging floor, a script. These
			// pay nothing.
			if (!killer) { return; }
		}

		bool selfKill  = killer && (killer == victim);
		bool monsterOn = killer && !selfKill && !killer.player && killer.bIsMonster && !killer.bFriendly;
		// CIVIL WAR / TURNCOAT (11-03, sheet N13, N14): a monster the player's Infight or Charm grenade turned made the
		// kill: his, not everyone's Infighter (a charmed one is friendly, so it reads as a friendly monster's kill)
		Actor turner = null;
		if (killer && !selfKill && !killer.player && killer.bIsMonster)
		{
			int by = RS_Svc.Int(RS_Svc.GRENADE, "turned.by", 0, killer);
			if (by >= 0 && by < MAXPLAYERS && playeringame[by] && players[by].mo) turner = players[by].mo;
		}
		bool turncoat = false;
		if (turner && !pusher) { pusher = turner; turncoat = true; }

		if (pusher) { selfKill = false; monsterOn = false; playerKill = true; killer = pusher; }

		if (!selfKill && !monsterOn && !playerKill) { return; }

		let ev = RS_ScoreEvent.Create(victim, playerKill ? killer : null, e.Inflictor, victim.DamageTypeReceived);
		ev.selfInflicted    = selfKill;
		ev.monsterOnMonster = monsterOn;
		ev.ringOut          = pusher != null && !turncoat;
		ev.turncoat         = turncoat;
		ev.utKillsNeeded    = utKillsNeeded;
		ev.utHPNeeded       = utHPNeeded;

		NoteScored(victim);
		if (victim.Alternative) NoteScored(victim.Alternative);

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

	// BOOST MARKS (boost.zs): a fact about a monster noted when something ELSE died first (an Undying
	// champion's heart names its master). Saved with the level; dead entries are dropped as it grows.
	Array<Actor> m_markV;
	Array<Name>  m_markWhy;
	Array<int>   m_markTic;
	void Mark(Actor v, Name why)
	{
		if (!v || Marked(v, why)) return;
		for (int i = m_markV.Size() - 1; i >= 0; i--) if (!m_markV[i]) { m_markV.Delete(i); m_markWhy.Delete(i); m_markTic.Delete(i); }
		m_markV.Push(v);
		m_markWhy.Push(why);
		m_markTic.Push(level.maptime);
	}
	bool Marked(Actor v, Name why)
	{
		for (int i = 0; i < m_markV.Size(); i++) if (m_markV[i] == v && m_markWhy[i] == why) return true;
		return false;
	}
	// tics since the mark, or -1
	int MarkedSince(Actor v, Name why)
	{
		for (int i = 0; i < m_markV.Size(); i++) if (m_markV[i] == v && m_markWhy[i] == why) return level.maptime - m_markTic[i];
		return -1;
	}
	static RS_ScoreHandler Get() { return RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler")); }

	// A LEGENDARY'S RISE (rows.zs Strike While It Rises): the first blow seen on a risen legendary marks the rise -- the
	// refill and the transform come together, and the next hit is soon after. A kill within 2 s of the mark pays.
	override void WorldThingDamaged(WorldEvent e)
	{
		let v = e.Thing;
		if (v && v.bIsMonster && !v.player && RS_Boost.Transformed(v) && !Marked(v, 'risen')) Mark(v, 'risen');
		if (!v || !v.player) { return; }
		if (e.Damage <= 0) { return; }
		if (v.bNoDamage) { return; }
		let tr = GetTracker(v);
		if (tr) { tr.ResetUntouchable(); }
	}

	// The bodies paid this tic (the morph pair above). Cleared on the next tic that pays.
	private Array<Actor> m_scoredNow;
	private int m_scoredTic;
	private bool WasScored(Actor a)
	{
		if (m_scoredTic != level.maptime) return false;
		for (int i = 0; i < m_scoredNow.Size(); i++) if (m_scoredNow[i] == a) return true;
		return false;
	}
	private void NoteScored(Actor a)
	{
		if (m_scoredTic != level.maptime) { m_scoredNow.Clear(); m_scoredTic = level.maptime; }
		m_scoredNow.Push(a);
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

			Array<double> ms;
			double sum = 0.0;
			for (int b = 0; b < m_bonuses.Size(); b++)
			{
				double m = max(0.0, m_bonuses[b].Evaluate(ev));
				ms.Push(m);
				sum += m;
			}
			// the total cap holds here too (Darwin alone is 2.0, on top of Spree and Untouchable)
			double totalCap = CvarInt("rs_score_cap_kill", 300) / 100.0;
			double scale = (totalCap > 0.0 && sum > totalCap) ? totalCap / sum : 1.0;

			for (int b = 0; b < m_bonuses.Size(); b++)
			{
				double m = ms[b] * scale;
				if (m <= 0.0) { continue; }

				total += PayRows(tr, b, ev.basePoints, m);
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

		// 2b. The bonuses that read the others' answers (Bullet Time). Taken from a copy, so the order
		//     two of them run in can never matter.
		Array<double> asked;
		asked.Copy(mults);
		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			mults[b] = m_bonuses[b].AfterOthers(ev, m_bonuses, asked, b);
		}

		// 3. Cap per family, then in total. Both default to off, so out of the box
		//    the numbers are the original's exactly.
		Array<double> famSum;
		famSum.Resize(RS_ScoreBonus.FAM_COUNT);

		for (int b = 0; b < m_bonuses.Size(); b++)
		{
			if (mults[b] > 0.0) { famSum[m_bonuses[b].Family()] += mults[b]; }
		}

		Array<double> famCap;
		famCap.Resize(RS_ScoreBonus.FAM_COUNT);
		famCap[RS_ScoreBonus.FAM_EFFICIENCY] = CvarInt("rs_score_cap_efficiency", 0) / 100.0;
		famCap[RS_ScoreBonus.FAM_STYLE]      = CvarInt("rs_score_cap_style",      0) / 100.0;
		famCap[RS_ScoreBonus.FAM_DARING]     = CvarInt("rs_score_cap_daring",     0) / 100.0;
		famCap[RS_ScoreBonus.FAM_MELEE]      = CvarInt("rs_score_cap_melee",      0) / 100.0;
		famCap[RS_ScoreBonus.FAM_COUNTER]    = CvarInt("rs_score_cap_counter",    0) / 100.0;

		for (int f = 0; f < RS_ScoreBonus.FAM_COUNT; f++)
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

		double totalCap = CvarInt("rs_score_cap_kill", 300) / 100.0;
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

			total += PayRows(tr, b, ev.basePoints, mults[b]);
		}

		Pay(tr, total);
		RecordKill(ev, total);
		BigMomentPulse(ev, mults);

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
		RS_MeleeMemory.Note(ev);	// Combo remembers every melee kill (melee.zs)
	}

	// ----------------------------------------------------- slow motion, for a big moment
	//
	// The owner: "recontextualize all existing point-reward events ... as taking place in slow
	// motion". A kill that a bonus calls a big moment (BigMoment, bonus.zs; the melee family's list
	// in RS_Melee.BigMoment) asks RSQ_SlowMo for a short pulse through its own door,
	// `netevent rsm_pulse <hold ms> <depth %>`. Nothing hears it when SlowMo is not loaded.
	//
	// THE DECISION IS GAME STATE, THE SEND IS ONE MACHINE'S. Which kill is a big moment and the
	// cooldown are play-scope facts, the same everywhere; only the machine of the player who earned
	// it sends, so a co-op game gets the event once (the Gun Bonsai VR patch's RSQM.Pulse does the
	// same). rs_score_slowmo turns it off; rs_score_slowmo_cooldown (seconds) keeps a spree from
	// being one long slow motion.
	const PULSE_MS    = 600;     // the hold; SlowMo eases in (rsm_ramp_in 0.15 s) and out (0.4 s) round it
	const PULSE_DEPTH = 35;      // percent of full speed
	private void BigMomentPulse(RS_ScoreEvent ev, Array<double> mults)
	{
		let tr = ev.tracker;
		if (!tr || ev.killerNum < 0) return;

		RS_ScoreBonus why = null;
		for (int b = 0; b < m_bonuses.Size() && !why; b++)
		{
			if (mults[b] <= 0.0) continue;
			if (m_bonuses[b].BigMoment(ev, mults[b]) || RS_Melee.BigMoment(m_bonuses[b], mults[b])) why = m_bonuses[b];
		}
		// the kill's record says so (RecordKill ran just before this)
		if (why) for (int k = kVictim.Size() - 1; k >= 0; k--) if (kVictim[k] == ev.victim) { kBig[k] = 1; break; }

		// HIT-STOP ON BIG KILLS (owner's pick 57, an option, off: rs_score_hitstop). A big kill -- a big moment as
		// above, or a monster of 400 spawn health or more (the Gun Bonsai VR patch's Adrenaline draws the "big
		// monster" line at 400 too) -- stops the world for a beat: a very short, very deep RSQ_SlowMo pulse
		// (rsm_pulse HITSTOP_MS at HITSTOP_DEPTH %, SlowMo's floor is 5 %). Nothing happens without SlowMo. Not while
		// the world is already slowed (a deep pulse would deepen that slow motion for the rest of its hold: SlowMo's
		// pulses merge, deeper wins), and at most once a second. When the same kill also earns the slow-motion
		// moment, that pulse is sent once the hit-stop's hold is over (WorldTick), so it reads as stop, then slow.
		bool stopped = false;
		bool big = why || ev.victimSpawnHealth >= HITSTOP_HEALTH;
		if (big && CvarInt("rs_score_hitstop", 0) != 0 && level.maptime >= hitstopReady[ev.killerNum]
			&& level.maptime > tr.slowmoUntil && RS_Physical.AskSlowMo("slowmo.active") != 1)
		{
			stopped = true;
			hitstopReady[ev.killerNum] = level.maptime + HITSTOP_COOLDOWN;
			// our own slow motion is not Bullet Time's (sheet C3): remembered here for a SlowMo that cannot say whose
			// pulse runs (physical.zs RS_Bonus_BulletTime asks "trigger.score" first)
			tr.slowmoUntil = max(tr.slowmoUntil, level.maptime + (HitStopMs() * 35) / 1000 + 20);
			if (DebugOn()) Console.Printf("RS_Score: big kill (%s) -> hit-stop pulse %d ms at %d%%%s", why ? why.DisplayName() : "big monster", HitStopMs(), HITSTOP_DEPTH, RS_Physical.AskSlowMo("slowmo.active") < 0 ? " (no RSQ_SlowMo: nothing hears it)" : "");
			if (ev.killerNum == consoleplayer) EventHandler.SendNetworkEvent("rsm_pulse", HitStopMs(), HITSTOP_DEPTH);
		}

		if (!why) return;
		if (CvarInt("rs_score_slowmo", 1) == 0) return;
		if (level.maptime < tr.slowmoReady) return;

		int delay = stopped ? (HitStopMs() * 35 + 999) / 1000 + 1 : 0;
		tr.slowmoReady = level.maptime + 35 * clamp(CvarInt("rs_score_slowmo_cooldown", 6), 1, 120);
		tr.slowmoUntil = level.maptime + delay + (PULSE_MS * 35) / 1000 + 20;
		if (DebugOn()) Console.Printf("RS_Score: big moment (%s) -> slow-motion pulse %d ms at %d%%%s", why.DisplayName(), PULSE_MS, PULSE_DEPTH, delay ? String.Format(" in %d tics", delay) : "");
		if (delay) pulseAt[ev.killerNum] = level.maptime + delay;   // game state everywhere; only its machine sends
		else if (ev.killerNum == consoleplayer) EventHandler.SendNetworkEvent("rsm_pulse", PULSE_MS, PULSE_DEPTH);
	}
	const HITSTOP_MS       = 115;    // 4 tics at the bottom (the teardown's hit-stop: 3 a tap, 4 the default, 6 heavy)
	// SlowMo eases every pulse in over its rsm_ramp_in (0.15 s by default) and the hold counts from the ask, so a bare
	// 115 ms pulse touched 5 % for one tic on the rig (2026-11-01). The ease is added, so the bottom lasts the 4 tics.
	static int HitStopMs()
	{
		let c = CVar.FindCVar("rsm_ramp_in");
		return HITSTOP_MS + int(clamp(c ? c.GetFloat() : 0.0, 0.0, 1.0) * 1000);
	}
	const HITSTOP_DEPTH    = 5;      // percent of full speed: SlowMo's floor
	const HITSTOP_HEALTH   = 400;
	const HITSTOP_COOLDOWN = 35;
	int hitstopReady[MAXPLAYERS];
	int pulseAt[MAXPLAYERS];         // a slow-motion pulse waiting for a hit-stop to end (this machine's player)

	// ---------------------------------------------------------------- payment

	private void Pay(RS_ScoreTracker tr, int points)
	{
		if (points == 0) { return; }

		int before = tr.score;
		tr.AddScore(points);
		// RSQ_Accessibility's Photosensitive Mode: a new score flash only 14 tics after the last one
		// started (2.5 a second at most; points landing faster ride the flash already showing)
		if (RSSC_A11y.Gate(tr.flashTic, level.maptime)) tr.flashTic = level.maptime;

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
				line = line .. String.Format(" | %s %.3f", m_bonuses[b].DebugName(), mults[b]);
			}
		}

		Console.Printf("%s", line);
	}

	// ---- the breakdown rows the HUD reads ----------------------------------
	// Index -1 is the Base row; 0..n-1 are the bonuses in registry order.

	private void EnsureRows(RS_ScoreTracker tr)
	{
		int want = rowName.Size();
		if (tr.rowValue.Size() == want) { return; }

		tr.rowValue.Resize(want);
		tr.rowTic.Resize(want);
	}

	// ---------------------------------------------------- awards from other mods
	//
	// THE ONE CALL ANOTHER MOD MAKES TO PAY POINTS FOR SOMETHING THAT IS NOT A KILL (a deflected
	// training-remote bolt, a stunt), through RS_ScoreService so nothing links:
	//   GetInt("award", "<row label>", points, 0, playerPawn)  -> the points paid, or -1
	// The label must be the DisplayName of a registered bonus (an award row: a bonus whose Evaluate
	// is always 0, see awards.zs), so it shows in the breakdown in its family's colour like any
	// other; an unknown label pays onto the Base row. Play scope: call it from the playsim (a
	// network event, an actor's Tick), never from ui code.
	int AwardExternal(Actor who, String label, int points)
	{
		if (!who || !who.player || points <= 0) return -1;
		// ROWS SCORE PAYS ITSELF NOW, on the kill's base (11-03): the flat award a mod still sends for one of them is
		// taken (0) and not paid, so the move pays once. F.E.A.R. Effect: RSQ Melee's 200 -> the combo
		// "shove > gun.shotgun@slow" (combo.zs).
		if (label ~== "F.E.A.R. Effect") return 0;
		// RSQ MINIBOSS'S AWARDS AS MULTIPLIERS (sheet C6): Thrall Slow Kill 100, Miniboss 500 and Greedy 1000 were the same
		// on an imp and a Cyberdemon and sat outside the per-kill cap. The award comes on the tic of the kill it is for:
		// it pays a share of THAT kill's base instead (0.3 / 1.0 / 1.5), on its own row as before.
		double mult = 0;
		if (label ~== "Thrall Slow Kill") mult = 0.3;
		else if (label ~== "Miniboss") mult = 1.0;
		else if (label ~== "Greedy") mult = 1.5;
		else if (label ~== "Bossfight") mult = 2.0;     // the called-in miniboss (owner 11-05), on top of Miniboss's 1.0
		// RSQ SLOWMO'S DOWN v2 (owner 11-06 19:51): "Revenge", the marked monster killed, is sent from its killing blow,
		// before that kill is recorded here: it waits for it (a kill already recorded this tic is another one) and pays
		// 1x its base (flat 100 with no kill by the next tic); that base is remembered for the player. "Revive", the
		// crate taken (seconds later, no kill of its own), pays 3x that remembered base (flat 300 without one).
		bool waits = false;
		if (label ~== "Revenge") { mult = 1.0; waits = true; points = 100; }
		else if (label ~== "Revive")
		{
			int rp = who.PlayerNumber();
			int rb = (rp >= 0 && rp < MAXPLAYERS) ? revengeBase[rp] : 0;
			if (rp >= 0 && rp < MAXPLAYERS) revengeBase[rp] = 0;
			return PayLabel(who, label, rb > 0 ? 3 * rb : 300);
		}
		if (mult > 0)
		{
			int pn = who.PlayerNumber();
			int k = KillIndex(LastKill(pn));
			if (waits)
			{
				pendWho.Push(who); pendLabel.Push(label); pendMult.Push(mult); pendFlat.Push(points); pendTic.Push(level.maptime);
				return points;
			}
			if (k >= 0 && kTic[k] == level.maptime) points = max(1, int(round(kBase[k] * mult)));
			// MINIBOSS AND GREEDY COME BEFORE THEIR KILL IS RECORDED (owner 11-05): RSQ Miniboss pays them as the
			// miniboss dies, before Score's WorldThingDied records that kill, so there was no base yet and they paid
			// a flat 500 / 1000 on any monster. They wait now for the kill this tic (RecordKill: that kill's base
			// times 1.0 / 1.5, like every other award); with no kill recorded by the next tic, the flat points.
			else if (label ~== "Miniboss" || label ~== "Greedy")
			{
				pendWho.Push(who); pendLabel.Push(label); pendMult.Push(mult); pendFlat.Push(points); pendTic.Push(level.maptime);
				return points;
			}
		}
		return PayLabel(who, label, points);
	}

	// an award's points onto its row (the Base row for an unknown label) and into the score
	private int PayLabel(Actor who, String label, int points)
	{
		let tr = GetTracker(who);
		if (!tr) return -1;
		EnsureRows(tr);
		int row = 0;
		for (int k = 1; k < rowName.Size(); k++) if (rowName[k] ~== label) { row = k; break; }
		AddRowAt(tr, row, points);
		Pay(tr, points);
		if (DebugOn()) Console.Printf("RS_Score: award %s paid %d", label, points);
		return points;
	}

	// awards waiting for their kill (Miniboss, Greedy: AwardExternal)
	int revengeBase[MAXPLAYERS];   // RSQ SlowMo's DOWN: the base of this player's last "Revenge" kill ("Revive" pays 3x it)
	Array<Actor> pendWho;
	Array<String> pendLabel;
	Array<double> pendMult;
	Array<int> pendFlat, pendTic;

	// a kill recorded: the awards waiting for it this tic are paid on its base. Called with pn -1 (WorldTick): the ones
	// left from an earlier tic, whose kill never came, are paid their flat points.
	private void SettleAwards(int pn, int base)
	{
		for (int i = pendWho.Size() - 1; i >= 0; i--)
		{
			Actor who = pendWho[i];
			bool mine = pn >= 0 && who && who.player && who.PlayerNumber() == pn && pendTic[i] == level.maptime;
			bool stale = pn < 0 && pendTic[i] < level.maptime;
			if (!mine && !stale) continue;
			int points = mine ? max(1, int(round(base * pendMult[i]))) : pendFlat[i];
			String label = pendLabel[i];
			if (label ~== "Revenge" && who && who.player) revengeBase[who.PlayerNumber()] = mine ? max(1, base) : 100;
			pendWho.Delete(i); pendLabel.Delete(i); pendMult.Delete(i); pendFlat.Delete(i); pendTic.Delete(i);
			if (who && who.player) PayLabel(who, label, points);
		}
	}

	// A bonus's pay onto its row (or rows: a bonus with several splits what it paid by its shares for
	// this kill). The points paid.
	private int PayRows(RS_ScoreTracker tr, int b, int basePoints, double mult)
	{
		let bon = m_bonuses[b];
		int n = bon.RowCount();
		if (n <= 1)
		{
			int points = int(round(basePoints * mult));
			AddRow(tr, b, points);
			return points;
		}
		int paid = 0;
		for (int i = 0; i < n; i++)
		{
			double sh = bon.RowShare(i);
			if (sh <= 0) continue;
			int points = int(round(basePoints * mult * sh));
			AddRowAt(tr, m_rowBase[b] + i, points);
			paid += points;
		}
		return paid;
	}

	private void AddRow(RS_ScoreTracker tr, int bonusIndex, int points)
	{
		AddRowAt(tr, bonusIndex < 0 ? 0 : m_rowBase[bonusIndex], points);
	}

	private void AddRowAt(RS_ScoreTracker tr, int row, int points)
	{
		if (points <= 0) { return; }

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
		//
		// THE CUE IS THE SOUND AND THE BAR, NOT THE WHOLE VIEW (owner 11-05: "can we optimize that effect? it slows down
		// my game"). In VR the engine draws a player blend as a full-eye quad that each eye adds and each eye then draws
		// all of (hw_entrypoint.cpp V_DrawBlend per eye -> v_draw.cpp DoDim outside2D -> gles_postprocess.cpp
		// Draw2D(true) per eye): two full-eye blended passes per eye for 26 tics, 52 with a life, and the 0.6 test tint
		// covered the rig's eye at ~0.9. The reward now lights Score's own bar and life pips instead (hud.zs
		// RewardGlow / DrawLives, off rewardTic and lifeCueTic): a few small HUD quads. The whole-view tint is still
		// there as an option, off ("Reward Screen Flash", rs_score_rewardflash, under the Screen Flash switch).
		if (tr.owner)
		{
			tr.owner.A_StartSound("rsscore/pointreward", CHAN_VOICE, CHANF_LOCAL, 1.0, ATTN_NONE);

			double a = 1.0 - (0.65 ** crossings);
			if (RewardFlash(tr.owner)) tr.owner.A_SetBlend("80 D4 FF", RSSC_A11y.Dim(a), 26, "80 D4 FF", 0.0);   // Photosensitive Mode: 40%
		}

		tr.rewardTic = level.maptime;
		tr.rewardKind = newLives > 0 ? 1 : 0;   // what the bar glows as (hud.zs): blue for a life, orange for ammo

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
		if (RewardFlash(mo)) mo.A_SetBlend("C0 E0 FF", RSSC_A11y.Dim(a), 26, "C0 7C FF", 0.0);
		tr.lifeCueTic = level.maptime;   // the life pips pop and light (hud.zs DrawLives)

		tr.rewardLifeTic = 0;
		tr.pendingLives  = 0;
	}

	// ------------------------------------------------------------------- tick

	override void WorldTick()
	{
		if (pendWho.Size() > 0) SettleAwards(-1, 0);
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) { continue; }

			let tr = GetTracker(players[i].mo);
			if (!tr) { continue; }

			// Score_DoRewards recalculated the percentage every tic. Keep that: it is
			// what the next map's threshold is scaled against.
			tr.CalcScorePercent(threshold);

			if (pulseAt[i] > 0 && level.maptime >= pulseAt[i])
			{
				pulseAt[i] = 0;
				if (i == consoleplayer) EventHandler.SendNetworkEvent("rsm_pulse", PULSE_MS, PULSE_DEPTH);
			}
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

			// GiveInventory spawns an item and runs every handler's WorldThingSpawned and the pickup chain for it: not for
			// an ammo already full, where it gives nothing (Ammo.HandlePickup) -- the 20 s burst kept spawning for those.
			if (now > had && (am.Amount < am.MaxAmount || sv_unlimited_pickup)) { mo.GiveInventory(am.GetClass(), now - had); }
		}

		tr.regenSpent += 1;
		tr.regenTimer -= 1;
	}

	// A LIFE SPENT IS A DEATH (owner 11-06 19:58 / 19:59): RSQ Graveyard (by name, its service) places its gold tombstone
	// where this player stood. Play scope, on every machine on the same tic (the stone is spawned, not sent).
	static void TellGraveyard(Actor mo)
	{
		let it = ServiceIterator.Find("gy_RSQService");
		Service s;
		while (s = it.Next())
		{
			if (s.GetClassName() != 'gy_RSQService') continue;
			int r = s.GetInt("stone.life", "", mo.PlayerNumber(), 0, mo);
			if (DebugOn()) Console.Printf("RS_Score: a life spent -- RSQ Graveyard's gold tombstone: %d", r);
		}
	}

	// RSQ SlowMo's DOWN holds this player now (RSQSM_Service "down.hold", by name; 0 without SlowMo)
	static bool DownHolds(Actor mo)
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RSQSM_Service') return s.GetInt("down.hold", "", mo.PlayerNumber()) == 1;
		return false;
	}

	// Extra lives hold the player in buddha and catch them at 1 hp. A life spent plays the original's revival:
	// the blast and the column of fire, from a fixed pool (revive.zs, owner 11-05).
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

			// RSQ SLOWMO'S DOWN COMES FIRST (owner 11-06): while it holds this player at 1 HP, no life is spent; a life
			// is spent only when DOWN fails (its killing blow is held at 1 HP by the hold above, and caught here)
			if (mo.health == 1 && DownHolds(mo))
			{
				if (DebugOn() && !tr.downNoted) Console.Printf("RS_Score: at 1 HP while RSQ SlowMo's DOWN holds him -- no life spent (%d held)", tr.extraLives);
				tr.downNoted = true;
				return;
			}
			tr.downNoted = false;

			if (mo.health == 1)
			{
				mo.health = mo.GetMaxHealth(true);
				p.health  = mo.health;

				tr.extraLives -= 1;
				tr.reviveTic = level.maptime;
				// THE REVIVAL (owner 11-05: "the score, it fires off a column of fire like in the original when we use a
				// life, right? ... i wanted an optimized version of that"). Dakka's Score_CheckRevival, parsed: the
				// revive sound, DakkaReviveExplosion (A_Explode(384, 256), no self-damage, and its ring and column of
				// fire) and RevivalIntervention (no damage while it plays). Here: the same sound, the same blast and
				// the guard, and the fire drawn by a pool of 32 flames spawned once (revive.zs) instead of ~1,150
				// flames each spawning a sprite a tic. "Revival Fire" (rs_score_revivefire, on) turns the fire off;
				// the blast and the guard stay, they are the revival.
				// THE WHOLE-VIEW TINT is off by default, like the reward's (396300e8e: a blend is two full-eye passes
				// per eye in VR): "Revival Screen Flash" (rs_score_reviveflash), under Screen Flash. Photosensitive
				// Mode: the fire plays, never the tint.
				mo.A_StartSound("rsscore/revive", CHAN_VOICE, CHANF_LOCAL, 1.0, ATTN_NONE);
				RS_ScoreReviveFire.Begin(mo, ReviveFire(mo));
				mo.GiveInventory("RS_ScoreReviveGuard", 1);
				if (ReviveFlash(mo)) mo.A_SetBlend("FF C0 60", 0.45, 20, "FF 60 20", 0.0);

				if (DebugOn())
				{
					Console.Printf("RS_Score: REVIVED at tic %d -- health %d, %d lives left",
						level.maptime, mo.health, tr.extraLives);
				}
				TellGraveyard(mo);

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

		m_rowBase.Clear();
		for (int i = 0; i < m_bonuses.Size(); i++)
		{
			m_rowBase.Push(rowName.Size());
			int n = max(1, m_bonuses[i].RowCount());
			for (int r = 0; r < n; r++)
			{
				rowName.Push(m_bonuses[i].RowName(r));
				rowColor.Push(m_bonuses[i].FamilyColor());
			}
		}
	}

	// ---------------------------------------------------- the last kills, for Gun Bonsai
	//
	// WHAT A KILL EARNED IN STYLE, read by name by the Gun Bonsai VR patch's "XP Source: Style"
	// (RS_ScoreService "kill.serial" / "kill.style" / "kill.base" / "kill.chain", awards.zs): a running
	// serial per kill a player earned, the base, the style (every bonus row: the total less the base --
	// Champions' and LegenDoom's rows included), and the chain of tools, finishing blow last. The last
	// sixteen are kept; a reader looks once a tic.
	int killSerial;
	Array<int> kSerial, kPn, kBase, kStyle, kTic;
	Array<int> kBig;    // 1: this kill was a big moment (BigMomentPulse's own call), for "kill.big" (Gun Bonsai VR's Lucky Kill)
	Array<String> kChain;
	Array<Actor> kVictim;

	private void RecordKill(RS_ScoreEvent ev, int total)
	{
		if (ev.killerNum < 0) return;
		RS_Combo.ChainOf(ev);
		String c = "";
		for (int k = 0; k < ev.chain.Size(); k++) c = c .. (k ? ">" : "") .. ev.chain[k];
		killSerial++;
		if (kSerial.Size() >= 16) { kSerial.Delete(0); kPn.Delete(0); kBase.Delete(0); kStyle.Delete(0); kChain.Delete(0); kVictim.Delete(0); kBig.Delete(0); kTic.Delete(0); }
		kSerial.Push(killSerial); kPn.Push(ev.killerNum); kBase.Push(ev.basePoints); kStyle.Push(max(0, total - ev.basePoints)); kChain.Push(c); kVictim.Push(ev.victim); kBig.Push(0); kTic.Push(level.maptime);
		if (DebugOn()) Console.Printf("RS_Score: kill #%d p%d base %d style %d chain %s", killSerial, ev.killerNum, ev.basePoints, max(0, total - ev.basePoints), c);
		if (pendWho.Size() > 0) SettleAwards(ev.killerNum, ev.basePoints);
	}

	// the newest kill serial of player pn (0: none this map)
	int LastKill(int pn)
	{
		for (int k = kSerial.Size() - 1; k >= 0; k--) if (kPn[k] == pn) return kSerial[k];
		return 0;
	}
	int KillIndex(int serial)
	{
		for (int k = kSerial.Size() - 1; k >= 0; k--) if (kSerial[k] == serial) return k;
		return -1;
	}

	// ----------------------------------------------------------------- helpers

	// A whole-view colour flash is the one effect that can be unpleasant in a headset; it is the
	// player's own choice (a user cvar, read through their replicated userinfo, so every machine
	// agrees and it only changes that player's view).
	static bool ScreenFlash(Actor mo)
	{
		if (!mo || !mo.player) return false;
		let cv = CVar.GetCVar("rs_score_screenflash", mo.player);
		return !cv || cv.GetBool();
	}

	// The reward's whole-view tint, the old cue (off since 11-05, see CheckRewards): only with Screen Flash on too.
	static bool RewardFlash(Actor mo)
	{
		if (!ScreenFlash(mo)) return false;
		let cv = CVar.GetCVar("rs_score_rewardflash", mo.player);
		return cv && cv.GetBool();
	}

	// The revival's column of fire (revive.zs): on unless this player turned it off.
	static bool ReviveFire(Actor mo)
	{
		if (!mo || !mo.player) return false;
		let cv = CVar.GetCVar("rs_score_revivefire", mo.player);
		return !cv || cv.GetBool();
	}

	// The revival's whole-view tint (off since 11-05): only with Screen Flash on too, and never in Photosensitive Mode.
	static bool ReviveFlash(Actor mo)
	{
		if (!ScreenFlash(mo) || RSSC_A11y.Photo()) return false;
		let cv = CVar.GetCVar("rs_score_reviveflash", mo.player);
		return cv && cv.GetBool();
	}

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
