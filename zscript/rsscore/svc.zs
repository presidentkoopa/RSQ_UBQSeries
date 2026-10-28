// ============================================================================
// ASKING THE SERIES' MODS, CHEAPLY. Score asks the grapple, the ShieldSaw, the saber, the grab, the rig
// and SlowMo things by service NAME (nothing links). ServiceIterator.Find makes an iterator object and
// walks EVERY service in the game, lower-casing each name and searching it, in the VM -- and the combo
// system (combo.zs) asks several of those per blow and per monster per tic, so a shotgun's pellets or a
// minigun's stream into a crowd asked hundreds a tic. The services a name matches are found once
// (RS_ScoreRegistry.EnsureSvc) and asked straight; an absent mod costs one compare. Same answers, same
// order: the list is ServiceIterator's own, kept.
// ============================================================================

class RS_Svc play
{
	enum EWhich { GRAPPLE, SHIELD, SABER, GRAB, RIG, SLOWMO, NUM }

	static String NameOf(int w)
	{
		switch (w)
		{
		case GRAPPLE: return "RSQGR_Service";
		case SHIELD:  return "SSQ_ScoreService";
		case SABER:   return "UBQS_SaberService";
		case GRAB:    return "RSQDG_ThrowService";
		case RIG:     return "RSQTR_RigService";
		case SLOWMO:  return "RSQSM_Service";
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
	static String Str(int w, String request, Object about = null)
	{
		let reg = RS_ScoreRegistry.Get();
		if (!reg) return "";
		reg.EnsureSvc();
		int e = reg.svcStart[w] + reg.svcCount[w];
		for (int i = reg.svcStart[w]; i < e; i++)
		{
			let s = reg.svcList[i];
			if (!s) continue;
			String v = s.GetString(request, "", 0, 0, about);
			if (v != "") return v;
		}
		return "";
	}
}
