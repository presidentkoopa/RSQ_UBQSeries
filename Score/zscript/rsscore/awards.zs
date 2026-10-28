// ============================================================================
// AWARD ROWS: bonuses that never pay on a kill (Evaluate is always 0) and exist so that another
// mod's RS_ScoreService "award" call has a labelled row in the breakdown, in a family colour.
// ============================================================================

class RS_AwardSeed play
{
	static void Names(out Array<String> into)
	{
		into.Push("RS_Award_Deflect");
		into.Push("RS_Award_RemoteDown");
		into.Push("RS_Award_IndianaJones");
	}
}

// RSQ_Grapple: a gap crossed on the rope (its service.zs measures and pays it, once per gap per map).
class RS_Award_IndianaJones : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Indiana Jones"; }
}

// The saber's training remote: a bolt knocked back into it, and the remote knocked out of the air.
class RS_Award_Deflect : RS_ScoreBonus
{
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Deflect"; }
}

class RS_Award_RemoteDown : RS_ScoreBonus
{
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Remote Down"; }
}

// The door for other mods: GetInt("award", label, points, 0, playerPawn). See RS_ScoreHandler.AwardExternal.
class RS_ScoreService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "award")
		{
			let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
			return h ? h.AwardExternal(Actor(objectArg), stringArg, intArg) : -1;
		}
		// READS FOR A HUD THAT DRAWS THE SCORE ITSELF (the Gun Bonsai VR patch's screens, 10-27),
		// here and through GetIntUI. objectArg = the pawn (null: the console player's); -1 when
		// there is no score. "score" the running total the player reads; "progress" permille of
		// the way to the next reward (0..1000); "lives" extra lives held; "rewards" this map's.
		return Read(request, Actor(objectArg));
	}

	// the same reads from a HUD or menu (ui scope)
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return Read(request, Actor(objectArg));
	}

	static clearscope int Read(String request, Actor pawn)
	{
		if (!pawn && players[consoleplayer].mo) pawn = players[consoleplayer].mo;
		let tr = pawn ? RS_ScoreTracker(pawn.FindInventory("RS_ScoreTracker")) : null;
		if (!tr) return -1;
		if (request == "score") return tr.displayScore;
		if (request == "progress") return int(clamp(tr.scorePercent, 0.0, 1.0) * 1000);
		if (request == "lives") return tr.extraLives;
		if (request == "rewards") return tr.rewardCount;
		return -1;
	}
}
