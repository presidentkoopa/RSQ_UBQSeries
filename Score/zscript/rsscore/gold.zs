// ============================================================================
// GOLD (design/KIOSK.md, owner 2026-11-16 04:47-04:52): the bank the Boss kiosk spends.
//
//   WHERE IT COMES FROM   RSQ VisualRewards' gold bits (a share of every kill's bits, a fountain from Bosses and champions),
//                         asked to bank here by name: RS_ScoreService "gold.add". Nothing here makes gold by itself.
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

	override void WorldTick()
	{
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

// THE BANK AT A DEATH (RS_ScoreGold above): a static handler, so it is in no savegame and a load does not put it back
class RS_ScoreGoldKeep : StaticEventHandler
{
	String map;
	int gold, earned;
	static RS_ScoreGoldKeep Get() { return RS_ScoreGoldKeep(StaticEventHandler.Find("RS_ScoreGoldKeep")); }
}
