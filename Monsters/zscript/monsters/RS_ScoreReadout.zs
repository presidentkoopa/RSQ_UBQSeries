// ============================================================================
// RS_ScoreReadout.zs -- what RSQ Score may read about a roster monster, BY NAME.
// (Owner 2026-11-09, design/SCORE_EXPANSION.md B and C: Score's roster rows.)
//
// NOTHING HERE LINKS TO SCORE, AND SCORE NEVER LINKS TO THIS. Score finds this
// service by its class name ("RSQMN_RosterService", ServiceIterator) and asks it
// GetInt(request, "", intArg, 0, monster). Without RSQ Monsters loaded nobody
// answers and every roster row pays 0; without Score loaded nobody asks. The two
// stamps below are the only state this file adds, and they are plain inventory
// items on the monster (no behaviour, no drawing).
//
// THE REQUESTS (objectArg is the monster; every answer is -1 for "not ours" /
// "unknown"):
//   "set"          1 a CH colour-tier monster (it carries RS_ZomTierToken)
//   "tier"         its RSQ ladder tier, 1 Common .. 13 Brown (the token's amount)
//   "ex"           1 a CH EX boss form (class name ends "EX"), else 0
//   "spawn.odds"   N for "1 in N": how rare the CH colour dial's roll was for this
//                  colour in its family, with the menu's gates applied the way the
//                  stubs apply them (off = re-roll, half = half re-roll, Black Boss
//                  off -> Red, White Boss off -> Black, the EX share). -1 for a body that got its colour from a tier
//                  change (stamped), or a class not on the ladder.
//   "tier.next"    the tier a running tier-change flash (RS_RetierJob) will give
//                  it, or -1 when it is not flashing
//   "tier.ago"     tics since its last live tier change (the flash path), or -1
//   "tier.from"    the tier it had before that change, or -1
//   "headshot"     1 the newest blow was a head shot (RSQ Score's head check, when loaded and on)
//   "retier"       [11-09 miniboss rework] A TIER CHANGE ASKED BY ANOTHER MOD (RSQ Miniboss: a missed window, a
//                  lost life; design/MINIBOSS_REWORK.md): intArg = the tier wanted (1..13), doubleArg > 0 = instant
//                  (no flash: RSQ Miniboss's hub reset). RS_Retier.Request, the same path as the console's
//                  rs_retier: the tier flash, then the CH class swap (a NEW actor: the asker finds it by
//                  "tier.ago"). 1 asked, 0 not a ladder monster (or dead).
// (MeatGrinder went 11-10, owner: "mg.death", "mg.behave", the Abyss split and "family" are no longer answered (-1, "").)
//
// WHERE THE STAMP IS PUT: RS_RetierJob.Tick (RS_Retier.zs), after the swap: RS_TierStamp.
// ============================================================================

class RSQMN_RosterService : Service
{
	override String GetString(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// "set.class" (11-09, RSQ Minibosses' Miniboss From / Thralls From): stringArg any monster type (vanilla,
		// Brutal Doom's, CH), intArg the set (3 ColorfulHell), doubleArg the ladder tier -> the same family's class at
		// that colour, "" when the type has no Doom family or the set has none for it
		if (request == "set.class") return RS_BossfightPick.SetClass(stringArg, intArg, int(doubleArg));
		return "";
	}

	override int GetInt(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// by type, no monster needed (11-09, RSQ Minibosses' Miniboss From / Thralls From): stringArg a class name ->
		// "class.set" 1 ColorfulHell, -1 not on the ladder; "class.tier" its CH ladder tier, 0 none
		if (request == "class.set")
		{
			class<Actor> c = stringArg;
			if (!c) return -1;
			return RS_TierLadder.TierOf(stringArg) > 0 ? 1 : -1;
		}
		if (request == "class.tier") return RS_TierLadder.TierOf(stringArg);
		let mo = Actor(objectArg);
		if (!mo) return -1;
		if (request == "set")         return RS_ScoreReadout.SetOf(mo);
		if (request == "tier")        return RS_ScoreReadout.TierOf(mo);
		if (request == "ex")          return RS_ScoreReadout.SetOf(mo) == 1 ? (RS_ScoreReadout.IsEX(mo) ? 1 : 0) : -1;
		if (request == "spawn.odds")  return RS_ScoreReadout.SpawnOdds(mo);
		if (request == "tier.next")   { let j = RS_Retier.JobFor(mo); return j ? j.targetTier : -1; }
		if (request == "retier")
		{
			if (mo.health <= 0 || RS_Retier.TierNowOf(mo) < 0) return 0;
			RS_Retier.Request(mo, intArg, doubleArg > 0);
			return 1;
		}
		if (request == "tier.ago")    { let s = RS_TierStamp(mo.FindInventory("RS_TierStamp")); return s ? level.maptime - s.tic : -1; }
		if (request == "tier.from")   { let s = RS_TierStamp(mo.FindInventory("RS_TierStamp")); return s ? s.fromTier : -1; }
		// [11-09 head shots] RSQ Score's head check answers for every monster when it is loaded and on (RS_ScoreService)
		if (request == "headshot")    return RS_ScoreReadout.Headshot(mo);
		return -1;
	}
}

class RS_ScoreReadout play
{
	// [11-09 head shots] the head-shot verdict: RSQ Score's (asked by name, nothing links)
	static int Headshot(Actor mo)
	{
		if (!mo) return -1;
		let it = ServiceIterator.Find("RS_ScoreService");
		Service s;
		while (s = it.Next())
		{
			int v = s.GetInt("headshot", "", 0, 0, mo);
			if (v >= 0) return v;
		}
		return -1;
	}

	static int SetOf(Actor mo)
	{
		if (!mo) return -1;
		return TierOf(mo) > 0 ? 1 : -1;
	}

	static int TierOf(Actor mo)
	{
		int t = RS_Zom.GetTier(mo);
		if (t <= 0) t = RS_TierLadder.TierOf(mo.GetClassName());   // (rig 11-09) a Common CH body carries no tier token
		return t > 0 ? t : -1;
	}

	static bool IsEX(Actor mo)
	{
		String n = mo.GetClassName();
		return n.Length() > 2 && n.Mid(n.Length() - 2) == "EX";
	}

	// The ladder family of a CH body. EX forms are not in the ladder tables: their
	// family is the gate they came from (RS_BlackImpEX -> RS_BlackImp; the spider's
	// RS_BlackSPEX -> RS_BlackSP1).
	static int FamilyOf(Actor mo)
	{
		String n = mo.GetClassName();
		int f = RS_TierLadder.FamilyOf(n);
		if (f >= 0 || !IsEX(mo)) return f;
		String g = n.Left(n.Length() - 2);
		f = RS_TierLadder.FamilyOf(g);
		if (f < 0) f = RS_TierLadder.FamilyOf(g .. "1");
		return f;
	}

	static int Gate(Name cv)
	{
		let c = CVar.FindCVar(cv);
		return c ? c.GetInt() : 1;
	}

	// The CH spawn dial's odds for this body's colour (see the header).
	static int SpawnOdds(Actor mo)
	{
		if (SetOf(mo) != 1 || mo.FindInventory("RS_TierStamp")) return -1;
		int tier = TierOf(mo);
		int fam = FamilyOf(mo);
		if (fam < 0 || tier < 1 || tier > 13) return -1;
		Name dn = RS_TierLadder.DialOf(fam);
		class<Actor> dc = dn;
		if (!dc) return -1;
		let def = GetDefaultByType(dc);
		if (!def) return -1;

		// the weights, by tier (RandomSpawner.ChooseSpawn's own reading: Amount, -1 = 1)
		Array<double> w;
		w.Resize(14);
		for (DropItem di = def.GetDropItems(); di != null; di = di.Next)
		{
			if (di.Name == 'None') continue;
			for (int t = 1; t <= 13; t++)
			{
				if (RS_TierLadder.GateFor(fam, t) != di.Name) continue;
				w[t] += di.Amount < 0 ? 1 : di.Amount;
				break;
			}
		}

		// the gates, as the stubs read them (CVARINFO: 1 = colour off and re-rolled;
		// 3 = half of them re-rolled, brown / cyan / abyss only)
		int g = Gate('rs_ch_brown');
		if (g == 1) w[13] = 0; else if (g == 3) w[13] *= 0.5;
		g = Gate('rs_ch_cyan');
		if (g == 1) w[12] = 0; else if (g == 3) w[12] *= 0.5;
		g = Gate('rs_ch_abyss');
		if (g == 1) w[9] = 0;  else if (g == 3) w[9] *= 0.5;
		if (Gate('rs_ch_fireblu') == 1) w[7] = 0;
		if (Gate('rs_ch_gray') == 1) w[8] = 0;
		// White Boss off: a White roll becomes a Black roll; Black Boss off: a Black roll becomes Red
		if (Gate('rs_ch_whiteboss') != 1) { w[10] += w[11]; w[11] = 0; }
		if (Gate('rs_ch_blackboss') != 1) { w[6] += w[10]; w[10] = 0; }

		double total = 0;
		for (int t = 1; t <= 13; t++) total += w[t];
		if (total <= 0 || w[tier] <= 0) return -1;
		double p = w[tier] / total;

		// the EX share of its boss gate (A_Jump(232) -> 24/256; 2 = half; 3 = always; anything else never)
		if (IsEX(mo))
		{
			int ex = Gate('rs_ch_exboss');
			double f = ex == 1 ? 24.0 / 256.0 : (ex == 2 ? 0.5 : (ex == 3 ? 1.0 : 0.0));
			p *= f;
		}
		if (p <= 0) return -1;
		return max(1, int(round(1.0 / p)));
	}

}

// A live tier change (the flash path), on the body that came out of it.
class RS_TierStamp : Inventory
{
	int fromTier, toTier, tic;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	// `a` is the body after the change (the swapped-in class), `from` the tier before.
	static void Put(Actor a, int from)
	{
		if (!a || a.health <= 0) return;
		int to = RS_Retier.TierNowOf(a);
		if (to < 0 || to == from) return;
		let s = RS_TierStamp(a.FindInventory("RS_TierStamp"));
		if (!s)
		{
			a.GiveInventory("RS_TierStamp", 1);
			s = RS_TierStamp(a.FindInventory("RS_TierStamp"));
		}
		if (!s) return;
		s.fromTier = from;
		s.toTier = to;
		s.tic = level.maptime;
	}
}

// =====================================================================================================================
// RSQ Monsters > Bossfight (owner 2026-11-09 07:45, "your rules are good"): Miniboss From / Thralls From. RSQ Minibosses
// asks RSQMN_RosterService "set.class" for the same family in another set; nothing here spawns anything.
// =====================================================================================================================
class RS_BossfightPick play
{
	// the vanilla Doom class a monster type stands in for: up its parents (CH bodies are Doom classes), what it
	// replaces (Brutal Doom's); 'None' when it has none
	static Name VanillaOf(class<Actor> c)
	{
		if (!c) return 'None';
		for (class<Actor> k = c; k; k = (class<Actor>)(k.GetParentClass()))
		{
			Name kn = k.GetClassName();
			if (RS_RosterHandler.FamilyId(kn) >= 0) return kn;
			class<Actor> r = Actor.GetReplacee(k);
			if (r && r != k)
			{
				Name rn = r.GetClassName();
				if (RS_RosterHandler.FamilyId(rn) >= 0) return rn;
			}
		}
		return 'None';
	}

	// the CH ladder family (RS_TierLadder's numbering) of a vanilla class, by the dial both tables share
	static int LadderFam(Name v)
	{
		int id = RS_RosterHandler.FamilyId(v);
		if (id < 0) return -1;
		Name dial = RS_RosterHandler.CHDial(id);
		for (int f = 0; f < RS_TierLadder.FamilyCount(); f++) if (RS_TierLadder.DialOf(f) == dial) return f;
		return -1;
	}

	static String SetClass(String clsName, int set, int tier)
	{
		class<Actor> c = clsName;
		Name v = VanillaOf(c);
		if (v == 'None') return "";
		if (set == 3)
		{
			int f = LadderFam(v);
			if (f < 0) return "";
			Name n = RS_TierLadder.ClassFor(f, clamp(tier, 1, RS_TierLadder.MaxTier()));
			String ns = n;
			class<Actor> nc = ns;
			return nc ? ns : "";
		}
		return "";
	}
}
