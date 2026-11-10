// ============================================================================
// ASKING THE SERIES' MODS, CHEAPLY. Score asks the grapple, the ShieldSaw, the saber, the grab, the rig,
// SlowMo, the Whip, Melee, the Grenade and Miniboss things by service NAME (nothing links). ServiceIterator.Find
// makes an iterator object and walks EVERY service in the game, lower-casing each name and searching it, in the
// VM -- and the combo system (combo.zs) asks several of those per blow and per monster per tic, so a shotgun's
// pellets or a minigun's stream into a crowd asked hundreds a tic. The services a name matches are found once
// (RS_ScoreRegistry.EnsureSvc) and asked straight; an absent mod costs one compare. Same answers, same
// order: the list is ServiceIterator's own, kept.
// ============================================================================

class RS_Svc play
{
	enum EWhich { GRAPPLE, SHIELD, SABER, GRAB, RIG, SLOWMO, WHIP, MELEE, GRENADE, MINIBOSS, MONSTERS, NUM }   // MONSTERS: RSQ Monsters' one read-out (roster rows rows_roster.zs, 11-09)

	static String NameOf(int w)
	{
		switch (w)
		{
		case GRAPPLE:  return "RSQGR_Service";
		case SHIELD:   return "SSQ_ScoreService";
		case SABER:    return "UBQS_SaberService";
		case GRAB:     return "RSQDG_ThrowService";
		case RIG:      return "RSQTR_RigService";
		case SLOWMO:   return "RSQSM_Service";
		case WHIP:     return "RSQWP_Service";
		case MELEE:    return "RSQML_Service";
		case GRENADE:  return "RSQGN_Service";
		case MINIBOSS: return "RSQMB_Service";
		case MONSTERS: return "RSQMN_RosterService";   // RSQ Monsters' read-out for the roster rows (11-09)
		}
		return "";
	}

	// the first answer that is not -1, or -1
	static int Int(int w, String request, int arg = 0, Object about = null)
	{
		let reg = RS_ScoreRegistry.Get();
		if (!reg) return -1;
		reg.EnsureSvc();
		int e = reg.svcStart[w] + reg.svcCount[w];
		for (int i = reg.svcStart[w]; i < e; i++)
		{
			let s = reg.svcList[i];
			if (!s) continue;
			int v = s.GetInt(request, "", arg, 0, about);
			if (v >= 0) return v;
		}
		return -1;
	}

	// the first answer that is not -1, with a double argument too
	static int IntD(int w, String request, int arg, double darg, Object about = null)
	{
		let reg = RS_ScoreRegistry.Get();
		if (!reg) return -1;
		reg.EnsureSvc();
		int e = reg.svcStart[w] + reg.svcCount[w];
		for (int i = reg.svcStart[w]; i < e; i++)
		{
			let s = reg.svcList[i];
			if (!s) continue;
			int v = s.GetInt(request, "", arg, darg, about);
			if (v >= 0) return v;
		}
		return -1;
	}

	// the first object that is an Actor, or null
	static Actor Act(int w, String request, Object about = null)
	{
		let reg = RS_ScoreRegistry.Get();
		if (!reg) return null;
		reg.EnsureSvc();
		int e = reg.svcStart[w] + reg.svcCount[w];
		for (int i = reg.svcStart[w]; i < e; i++)
		{
			let s = reg.svcList[i];
			if (!s) continue;
			let a = Actor(s.GetObject(request, "", 0, 0, about));
			if (a) return a;
		}
		return null;
	}

	// the first answer that is not empty, or ""
	static String Str(int w, String request, Object about = null, int arg = 0)
	{
		let reg = RS_ScoreRegistry.Get();
		if (!reg) return "";
		reg.EnsureSvc();
		int e = reg.svcStart[w] + reg.svcCount[w];
		for (int i = reg.svcStart[w]; i < e; i++)
		{
			let s = reg.svcList[i];
			if (!s) continue;
			String v = s.GetString(request, "", arg, 0, about);
			if (v != "") return v;
		}
		return "";
	}

	// is that mod's service there at all
	static bool Loaded(int w)
	{
		let reg = RS_ScoreRegistry.Get();
		if (!reg) return false;
		reg.EnsureSvc();
		return reg.svcCount[w] > 0;
	}
}
