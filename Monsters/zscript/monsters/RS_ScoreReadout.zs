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
//   "set"          1 a CH colour-tier monster (it carries RS_ZomTierToken),
//                  2 a MeatGrinder monster (RS_MGMonster)
//   "tier"         its RSQ ladder tier, 1 Common .. 13 Brown (CH: the token's
//                  amount; MG: its Tier field)
//   "ex"           1 a CH EX boss form (class name ends "EX"), else 0
//   "spawn.odds"   N for "1 in N": how rare the CH colour dial's roll was for this
//                  colour in its family, with the menu's gates applied the way the
//                  stubs apply them (off = re-roll, half = half re-roll, Black Boss
//                  off -> Red, White Boss off -> Black, the EX share). -1 for MG
//                  (never rolled) and for a body that got its colour from a tier
//                  change (stamped), or a class not on the ladder.
//   "tier.next"    the tier a running tier-change flash (RS_RetierJob) will give
//                  it, or -1 when it is not flashing
//   "tier.ago"     tics since its last live tier change (the flash path), or -1
//   "tier.from"    the tier it had before that change, or -1
//   "mg.death"     MG only: the reactive death it takes. intArg = the killing
//                  blow's damage. 0 its own death, 1 head-pop, 2 exploding head,
//                  3 gib, 4 burn, 5 freeze, 6 shock, 7 melt. The router's own
//                  answer when it has already run (mgPendingDeathSeq); otherwise
//                  the router's rule (MG_AssignDeathReaction) asked the same way,
//                  because which event handler hears a death first is not fixed.
//   "mg.behave"    MG only: the tier's aggression (MGBehave: 0..1 none,
//                  2 +MISSILEMORE, 3 +MISSILEEVENMORE)
//   "split.group"  an Abyss death-split: the group number shared by the Abyss
//                  monster that split and the lost souls it split into; 0 none
//   "split.child"  1 a lost soul born of a death-split, else 0
//
// WHERE THE STAMPS ARE PUT (two lines each, marked "RSQ Score read-out"):
//   RS_RetierJob.Tick (RS_Retier.zs), after the swap / in-place tier: RS_TierStamp.
//   RS_MGMonster.MG_DeathSplit (RS_MGMonsters.zs): RS_SplitStamp on the parent and
//   each lost soul.
// ============================================================================

class RSQMN_RosterService : Service
{
	override int GetInt(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let mo = Actor(objectArg);
		if (!mo) return -1;
		if (request == "set")         return RS_ScoreReadout.SetOf(mo);
		if (request == "tier")        return RS_ScoreReadout.TierOf(mo);
		if (request == "ex")          return RS_ScoreReadout.SetOf(mo) == 1 ? (RS_ScoreReadout.IsEX(mo) ? 1 : 0) : -1;
		if (request == "spawn.odds")  return RS_ScoreReadout.SpawnOdds(mo);
		if (request == "tier.next")   { let j = RS_Retier.JobFor(mo); return j ? j.targetTier : -1; }
		if (request == "tier.ago")    { let s = RS_TierStamp(mo.FindInventory("RS_TierStamp")); return s ? level.maptime - s.tic : -1; }
		if (request == "tier.from")   { let s = RS_TierStamp(mo.FindInventory("RS_TierStamp")); return s ? s.fromTier : -1; }
		if (request == "mg.death")    return RS_ScoreReadout.MGDeath(mo, intArg);
		if (request == "mg.behave")   { let m = RS_MGMonster(mo); return m ? m.MGBehave(m.Tier) : -1; }
		if (request == "split.group") { let s = RS_SplitStamp(mo.FindInventory("RS_SplitStamp")); return s ? s.group : 0; }
		if (request == "headshot")    { let m = RS_MGMonster(mo); return m ? (m.mgLastWasHeadshot ? 1 : 0) : -1; }   // MG head-band hit (combo.zs CondOf; was RSQMON_Service, folded in at merge 11-09)
		if (request == "split.child") { let s = RS_SplitStamp(mo.FindInventory("RS_SplitStamp")); return (s && s.child) ? 1 : 0; }
		return -1;
	}
}

class RS_ScoreReadout play
{
	static int SetOf(Actor mo)
	{
		if (!mo) return -1;
		if (RS_MGMonster(mo)) return 2;
		return RS_Zom.GetTier(mo) > 0 ? 1 : -1;
	}

	static int TierOf(Actor mo)
	{
		let m = RS_MGMonster(mo);
		if (m) return m.Tier;
		int t = RS_Zom.GetTier(mo);
		return t > 0 ? t : -1;
	}

	static bool IsEX(Actor mo)
	{
		String n = mo.GetClassName();
		return n.Length() > 2 && n.Right(2) == "EX";
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

	// The MG reactive death (RS_MGMonster.MG_AssignDeathReaction's rule, read-only).
	static int MGDeath(Actor mo, int damage)
	{
		let m = RS_MGMonster(mo);
		if (!m) return -1;
		let rd = CVar.FindCVar("rsq_mg_reactdeath");
		if (rd && !rd.GetBool()) return 0;
		String p = m.mgPendingDeathSeq;
		if (p != "")
		{
			if (p == "DeathSeq_Head")   return m.mgHeadExplode ? 2 : 1;
			if (p == "DeathSeq_Gib")    return 3;
			if (p == "DeathSeq_Burn")   return 4;
			if (p == "DeathSeq_Freeze") return 5;
			if (p == "DeathSeq_Shock")  return 6;
			if (p == "DeathSeq_Melt")   return 7;
			return 0;
		}
		Name dt = m.DamageTypeReceived;
		if (dt == 'Lightning' || dt == 'Electric') return 6;
		if (dt == 'Melt' || dt == 'Acid')          return 7;
		if (dt == 'Fire')                          return 4;
		if (dt == 'Ice')                           return 5;
		if (dt == 'Explosive' || (damage >= 0 && damage >= m.SpawnHealth())) return 3;
		if (m.mgLastWasHeadshot && (m.Tier <= 1 || RS_MGMonster.MG_DismemberTieredOn()))
		{
			let eh = CVar.FindCVar("rsq_mg_explodeheads");
			bool ehOn = (!eh || eh.GetBool());
			return (ehOn && damage >= 60) ? 2 : 1;
		}
		return 0;
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

	// `a` is the body after the change (CH: the swapped-in class; MG: itself), `from` the tier before.
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

// An Abyss death-split: the monster that split and the lost souls it split into share a group.
class RS_SplitStamp : Inventory
{
	int group;
	bool child;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	// grp 0: a new group for the parent (returned); otherwise `a` is a child of grp.
	static int Mark(Actor a, int grp)
	{
		if (!a) return 0;
		bool isChild = grp > 0;
		if (!isChild) grp = random[RSQSplit](1, 0x3FFFFFFF);
		a.GiveInventory("RS_SplitStamp", 1);
		let s = RS_SplitStamp(a.FindInventory("RS_SplitStamp"));
		if (s) { s.group = grp; s.child = isChild; }
		return grp;
	}
}
