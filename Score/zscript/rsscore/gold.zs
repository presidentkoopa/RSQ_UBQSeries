// ============================================================================
// GOLD (design/KIOSK.md, owner 2026-11-16 04:47-04:52): the bank the Boss kiosk spends.
//
//   WHERE IT COMES FROM   RSQ VisualRewards' gold bits, asked to bank here by name: RS_ScoreService "gold.add". Since
//                         2026-11-22 (owner) only Bosses, Champions and LegenDoom legendaries drop them (VisualRewards' Gold
//                         From: Special Kills Only; Every Kill is the old way), and Score pays a small gold bonus for a
//                         skill moment of its own (SKILL GOLD, below), into the same bank.
//   WHERE IT LIVES        on the player's RS_ScoreTracker (tracker.zs gold): it rides the save and every map change.
//   NEVER LOST ON DEATH   (owner: "Kept, never lost"). Dying with no Score life reloads the map (its autosave, or the map
//                         from scratch), which would take back the gold earned since. So the bank at the moment of death is
//                         kept in RS_ScoreGoldKeep (a static handler: in no savegame, so a load cannot put it back) and given
//                         back when the same map begins or is loaded again; any other map, or a new session, clears it. (My
//                         reading: a New Game started straight after dying on that same map keeps it too; rare, and harmless.)
//                         (Until 2026-11-17 it was the server cvar rs_score_gold_keep: a savegame load puts the server cvars
//                         back as they were saved, so the load after a death wiped it, and this handler, loaded from the save,
//                         gets no WorldLoaded either: rig fps_gold_old, the bank back at the save's 100 after dying with 350.
//                         RSQ Miniboss's Big Boss bar had the same fault: RSQMB_ExKeep, commit 3898e2db3e.)
//   SPENDING              the kiosk asks by name: "gold.spend" (all or nothing) and "life.spend" (one Score life, for LUCKY).
//   THE LOG               Gold Log (rs_score_gold_log): every deposit and spend, and the gold earned on each map as it ends.
//   ON SHOW               RSQ Gun Cards' off-hand watch card (GOLD n), asked by name ("gold"); and the Boss kiosk's counter.
//                         Not on Score's line (owner 2026-11-16 06:30: the readout moved to the watch card).
// Rig only, not headset-confirmed.
// ============================================================================

class RS_ScoreGold : EventHandler
{
	static bool LogOn()
	{
		let c = CVar.FindCVar("rs_score_gold_log");
		return c && c.GetBool();
	}

	static RS_ScoreTracker TrackerOf(Actor pawn)
	{
		if (!pawn && players[consoleplayer].mo) pawn = players[consoleplayer].mo;
		return pawn ? RS_ScoreTracker(pawn.FindInventory("RS_ScoreTracker")) : null;
	}

	// a deposit: the bank after, -1 no score
	static int Add(Actor pawn, int amount, String source)
	{
		let tr = TrackerOf(pawn);
		if (!tr || amount <= 0) return tr ? tr.gold : -1;
		tr.gold += amount;
		tr.goldEarned += amount;
		tr.goldMap += amount;
		tr.goldTic = level.maptime;
		if (LogOn()) Console.Printf("RS_Score gold t%d: +%d (%s) -> bank %d, this map %d, earned %d", level.maptime, amount,
			source == "" ? "?" : source, tr.gold, tr.goldMap, tr.goldEarned);
		return tr.gold;
	}

	// all or nothing: the bank after, -1 not enough (nothing spent) or no score
	static int Spend(Actor pawn, int amount, String what)
	{
		let tr = TrackerOf(pawn);
		if (!tr || amount < 0 || tr.gold < amount) return -1;
		tr.gold -= amount;
		tr.goldSpent += amount;
		tr.goldSpendTic = level.maptime;
		if (LogOn()) Console.Printf("RS_Score gold t%d: -%d (%s) -> bank %d", level.maptime, amount, what == "" ? "?" : what, tr.gold);
		return tr.gold;
	}

	// one Score life spent by choice (the kiosk's LUCKY): the lives left, -1 none held (nothing spent)
	static int SpendLife(Actor pawn, String what)
	{
		let tr = TrackerOf(pawn);
		if (!tr || tr.extraLives <= 0) return -1;
		tr.extraLives -= 1;
		if (LogOn() || RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score t%d: a life spent (%s): %d left", level.maptime, what == "" ? "?" : what, tr.extraLives);
		return tr.extraLives;
	}

	// ---- never lost on death ----------------------------------------------------------------------------------------
	// The bank at a death is kept in RS_ScoreGoldKeep (below), read on this handler's first tic after the map began or a
	// save was loaded (a load gives a handler from the save no WorldLoaded, and its transient fields come back empty, so
	// keepLive is false again), and given back (the larger) within KEEP_TICS of that tic, once the pawn has its tracker
	// (a save's maptime is its own, not 0).
	const KEEP_TICS = 70;
	override void PlayerDied(PlayerEvent e)
	{
		let mo = players[e.PlayerNumber].mo;
		let tr = TrackerOf(mo);
		if (tr) tr.goldLivesLost++;       // SKILL GOLD: a death in a Boss fight is not a clean win
		let k = RS_ScoreGoldKeep.Get();
		if (!tr || !k || e.PlayerNumber != consoleplayer) return;
		k.map = level.MapName; k.gold = tr.gold; k.earned = tr.goldEarned;
		if (LogOn()) Console.Printf("RS_Score gold: died on %s with %d banked: kept for the reload", level.MapName, tr.gold);
	}

	// the reload after a death: read the kept bank on the first tic, give it back once the pawn has its tracker
	transient bool keepLive;
	transient int keepGold, keepEarned, keepTill;
	transient bool keepPending;
	void KeepLoad()
	{
		keepPending = false;
		keepTill = level.maptime + KEEP_TICS;
		let k = RS_ScoreGoldKeep.Get();
		if (!k || k.map == "") return;
		String mp = k.map;
		k.map = "";
		if (!(mp ~== level.MapName)) return;
		keepGold = k.gold; keepEarned = k.earned; keepPending = true;
		if (LogOn()) Console.Printf("RS_Score gold t%d: %s %s after a death: %d kept to give back", level.maptime, level.MapName,
			level.maptime > 1 ? "loaded from a save" : "begun again", keepGold);
	}

	// SKILL GOLD's Boss fight (RS_ScoreSkillGold): RSQ Miniboss's "bossfight" turning on is the fight's start. Saved (not
	// transient), so a save loaded mid-fight does not read as a new start.
	bool mbFightWas;
	override void WorldTick()
	{
		if (!(level.maptime & 3) && RS_Svc.Loaded(RS_Svc.MINIBOSS))
		{
			bool on = RS_Svc.Int(RS_Svc.MINIBOSS, "bossfight") == 1;
			if (on && !mbFightWas) RS_ScoreSkillGold.FightBegins(RS_Svc.Int(RS_Svc.MINIBOSS, "bigboss") == 1);
			mbFightWas = on;
		}
		if (!keepLive) { keepLive = true; KeepLoad(); }
		if (!keepPending) return;
		if (level.maptime > keepTill) { keepPending = false; return; }
		let tr = TrackerOf(players[consoleplayer].mo);
		if (!tr) return;
		keepPending = false;
		int was = tr.gold;
		tr.gold = max(tr.gold, keepGold);
		tr.goldEarned = max(tr.goldEarned, keepEarned);
		if (LogOn()) Console.Printf("RS_Score gold: %s reloaded after a death: bank %d -> %d (kept)", level.MapName, was, tr.gold);
	}

	override void PlayerEntered(PlayerEvent e)
	{
		let tr = TrackerOf(players[e.PlayerNumber].mo);
		if (tr) { tr.goldMap = 0; tr.goldTic = 0; tr.goldSpendTic = 0; }   // (the HUD's pop counts in this map's tics)
	}

	override void WorldUnloaded(WorldEvent e)
	{
		if (!LogOn()) return;
		let tr = TrackerOf(players[consoleplayer].mo);
		if (!tr) return;
		Console.Printf("RS_Score gold: map %s ends: %d earned on it (%d tics), bank %d, %d spent in all, %d earned in all",
			level.MapName, tr.goldMap, level.maptime, tr.gold, tr.goldSpent, tr.goldEarned);
	}
}

// ============================================================================
// SKILL GOLD (owner 2026-11-22: "Skill moments pay a small gold bonus"). Paid straight into the bank (Add, the same bank
// the gold bits fill) and shown as RSQ VisualRewards' toast, "+10 GOLD: 10 KILL CHAIN", in the gold "up" chip (RSQVR_Service
// "toast" by name; without VisualRewards it is banked and not shown, as gold is not shown on Score's line). Server settings,
// the RSQ Score menu's Skill Gold rows (0 = that one off):
//   rs_score_gold_skill        Skill Gold, on: all of them on or off
//   rs_score_gold_chain   10   KILL CHAIN: every rs_score_gold_chain_every (10) kills of one Spree (Score's kill chain:
//                              each kill keeps it going for 2 to 10 s by the monster's health, bonuses.zs RS_Bonus_Spree)
//   rs_score_gold_combo   10   BIG COMBO: a kill whose combo chain is a big moment (a named combo of three steps or more,
//                              five tools in one chain, or four mods: combo.zs RS_Bonus_Chain.BigMoment)
//   rs_score_gold_boss    50   CLEAN BOSS KILL: an RSQ Miniboss Boss won (its "Miniboss Called" award) by a player who lost
//                              no Score life and did not die from the moment that fight began (RSQMB_Service "bossfight"
//                              turning on) until it died; a Big Boss pays twice (RSQMB_Service "bigboss" at the start)
//   A room or area cleared without taking damage: NOT PAID. Score tracks no rooms or areas (Untouchable counts kills since
//   the last hit, not a place cleared), so it is skipped (the owner: "only if Score already tracks something like it").
// The Gold Log (rs_score_gold_log) writes each one with its reason. Rig only, not headset-confirmed (code only, 2026-11-22).
// ============================================================================
class RS_ScoreSkillGold play
{
	static int CvI(String n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }
	static bool Enabled() { return CvI("rs_score_gold_skill", 1) != 0; }

	// pay it and show it: the bank after, -1 none paid
	static int Pay(Actor pawn, int amount, String why, String shown)
	{
		if (!pawn || !pawn.player || amount <= 0 || !Enabled()) return -1;
		int bank = RS_ScoreGold.Add(pawn, amount, why);
		if (bank < 0) return -1;
		let vr = RS_ScoreHandler.SvcNamed("RSQVR_Service");
		if (vr) vr.GetInt("toast", String.Format("up|+%d GOLD: %s", amount, shown), 0, 0, pawn);
		return bank;
	}

	// a kill that kept a Spree going (bonuses.zs RS_Bonus_Spree.Commit): its count now
	static void Chain(Actor pawn, int count)
	{
		int every = max(2, CvI("rs_score_gold_chain_every", 10));
		if (count < every || count % every != 0) return;
		Pay(pawn, CvI("rs_score_gold_chain", 10), String.Format("skill: a %d-kill chain", count), String.Format("%d KILL CHAIN", count));
	}

	// a kill whose combo chain is a big moment (combo.zs RS_Bonus_Chain.Commit)
	static void Combo(Actor pawn, String what)
	{
		Pay(pawn, CvI("rs_score_gold_combo", 10), "skill: a big combo (" .. what .. ")", "BIG COMBO");
	}

	// the Boss fight's start, per player (RS_ScoreGold.WorldTick): the lives lost so far
	static void FightBegins(bool big)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let tr = RS_ScoreGold.TrackerOf(players[i].mo);
			if (!tr) continue;
			tr.goldFightOn = true;
			tr.goldFightBig = big;
			tr.goldFightMark = tr.goldLivesLost;
		}
		if (RS_ScoreGold.LogOn()) Console.Printf("RS_Score gold t%d: a %s fight begins: a clean win pays Clean Boss Kill gold", level.maptime, big ? "Big Boss" : "Boss");
	}

	// the Boss won (handler.zs AwardExternal, RSQ Miniboss's "Miniboss Called"): clean if no life was lost since it began
	static void BossWon(Actor pawn)
	{
		if (!pawn || !pawn.player) return;
		let tr = RS_ScoreGold.TrackerOf(pawn);
		if (!tr || !tr.goldFightOn) return;
		tr.goldFightOn = false;
		bool clean = tr.goldLivesLost == tr.goldFightMark && pawn.health > 0;
		if (!clean)
		{
			if (RS_ScoreGold.LogOn()) Console.Printf("RS_Score gold t%d: Boss won, not clean (%d life/lives lost in the fight): no Clean Boss Kill gold", level.maptime, tr.goldLivesLost - tr.goldFightMark);
			return;
		}
		int amt = CvI("rs_score_gold_boss", 50) * (tr.goldFightBig ? 2 : 1);
		Pay(pawn, amt, tr.goldFightBig ? "skill: a clean Big Boss kill" : "skill: a clean Boss kill", tr.goldFightBig ? "CLEAN BIG BOSS KILL" : "CLEAN BOSS KILL");
	}
}

// THE BANK AT A DEATH (RS_ScoreGold above): a static handler, so it is in no savegame and a load does not put it back
class RS_ScoreGoldKeep : StaticEventHandler
{
	String map;
	int gold, earned;
	static RS_ScoreGoldKeep Get() { return RS_ScoreGoldKeep(StaticEventHandler.Find("RS_ScoreGoldKeep")); }
}
