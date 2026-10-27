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
	}
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
		return -1;
	}
}
