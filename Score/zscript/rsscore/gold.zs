// ============================================================================
// GOLD (design/KIOSK.md, owner 2026-11-16 04:47-04:52): the bank the Boss kiosk spends.
//
//   WHERE IT COMES FROM   RSQ VisualRewards' gold bits (a share of every kill's bits, a fountain from Bosses and champions),
//                         asked to bank here by name: RS_ScoreService "gold.add". Nothing here makes gold by itself.
//   WHERE IT LIVES        on the player's RS_ScoreTracker (tracker.zs gold): it rides the save and every map change.
//   NEVER LOST ON DEATH   (owner: "Kept, never lost"). Dying with no Score life reloads the map (its autosave, or the map
//                         from scratch), which would take back the gold earned since. So the bank at the moment of death is
//                         written to a cvar (rs_score_gold_keep, noarchive: "<map>|<gold>|<earned>") and given back when the
//                         same map loads again; any other map, or a new session, clears it. (My reading: a New Game started
//                         straight after dying on that same map keeps it too; rare, and harmless.)
//   SPENDING              the kiosk asks by name: "gold.spend" (all or nothing) and "life.spend" (one Score life, for LUCKY).
//   THE LOG               Gold Log (rs_score_gold_log): every deposit and spend, and the gold earned on each map as it ends.
//   THE HUD               hud.zs DrawGold: a coin and the bank in Score's gold, right of the score line; it pops on a deposit.
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
	override void PlayerDied(PlayerEvent e)
	{
		let mo = players[e.PlayerNumber].mo;
		let tr = TrackerOf(mo);
		let kc = CVar.FindCVar("rs_score_gold_keep");
		if (!tr || !kc || e.PlayerNumber != consoleplayer) return;
		kc.SetString(String.Format("%s|%d|%d", level.MapName, tr.gold, tr.goldEarned));
		if (LogOn()) Console.Printf("RS_Score gold: died on %s with %d banked: kept for the reload", level.MapName, tr.gold);
	}

	// the reload after a death: read the kept bank as the map loads, give it back once the pawn has its tracker
	transient String keepMap;
	transient int keepGold, keepEarned;
	transient bool keepPending;
	override void WorldLoaded(WorldEvent e)
	{
		let kc = CVar.FindCVar("rs_score_gold_keep");
		if (!kc) return;
		String k = kc.GetString();
		if (k == "") return;
		kc.SetString("");
		Array<String> f; k.Split(f, "|");
		if (f.Size() < 3 || !(f[0] ~== level.MapName)) return;
		keepGold = f[1].ToInt(); keepEarned = f[2].ToInt(); keepPending = true;
	}

	override void WorldTick()
	{
		if (!keepPending || level.maptime > 70) { keepPending = false; return; }
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
