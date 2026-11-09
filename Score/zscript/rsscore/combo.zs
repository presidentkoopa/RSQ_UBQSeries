// ============================================================================
// THE COMBO SYSTEM: every monster keeps an ordered history of the TOOLS that touched it, and a kill
// pays for the chain of tools that led to it.
//
// The owner, 10-27: the series' mods are tools for your hands; Score is the arcade room. His rules:
//   * ORDER MATTERS ("whip, then bash" is not "bash, then whip");
//   * the chain BREAKS after 3 SECONDS between moves (CHAIN_GAP);
//   * GUNS COUNT as tools (every gun is the one action "gun": swapping guns is Switcharoo's business; a
//     pattern may still name a class, gun.shotgun, when the move is that gun's);
//   * named SIGNATURE combos come from a DATA TABLE (RegisterCombo below, any mod may add rows);
//   * an unnamed chain still pays, as a generic chain (the one rule, COMBOS_MASTER section 2, 11-03).
// Nothing names a monster class: the history is what happened to the body, on any monster set.
//
// THE VOCABULARY is tools.zs (RS_Tool): one id per move in the series, the groups a pattern may name, and
// Classify, which reads what struck. The ids the mods send today are mapped onto it there (Canon), so a mod's
// strings never have to change for Score to understand them.
//
// WHERE A TOUCH COMES FROM, nothing linked:
//   a blow that lands (WorldThingDamaged, the player the source): classified by what struck;
//   what does no damage, asked by name at the next blow or the death (Poll): RSQ_Grapple's "hooked" /
//                     "hooked.by" / "yanked" / "struck", the saber's "pulled" / "gripped" / "blocked" /
//                     "perfect", the ShieldSaw's "blocked" / "perfect", the Whip's "wrapped" / "yanked" --
//                     each answers "how long ago", so the order is kept;
//   any other mod:    RS_ScoreService GetInt("touch", "<tool id>", playerNumber, 0, monster).
//
// TAGS ARE NOT TOOLS (11-03). An upgrade hook or a "how it landed" fact (hit.heavy, crit, cleave.saw, zip.kick,
// skeet...) rides on the blow's run instead of opening a new one: a Heavy Hands body uppercut used to be a
// 4-Tool Combo and a slow-motion moment by itself. A pattern step may require one (+tag).
//
// ONE BLOW, ONE MOVE. A mod names the move it deals (Melee's pound, clearout, shove; the Whip's tarzan; the
// hook's zip) with a touch on the same tic as the blow, which lands as a plain 'Melee' / 'Kick' / bite. The name
// and the guess merge (RS_Tool.Guess), so it never counts as two tools. THE CONTRACT: touch BEFORE the blow. A
// kill is scored inside the blow (WorldThingDied runs inside DamageMobj), so a name sent after a killing blow
// arrives too late for that kill's rows (it still joins the chain for the next one).
//
// A STEP MAY CARRY CONDITIONS: `gun.shotgun@slow` landed while the player's own slow motion was on;
// `glove.upper+air` the victim was airborne; `+pb` point-blank; `+head` a BD22 headshot; `+<tag>` any tag on
// the run. A pattern may end `| <filter>` on the victim (champ, armoured, legend, thrall, miniboss, a colour).
//
// NOTHING SCORES TWICE:
//   * one named row per kill, the best-paying match. It replaces the generic pay for the ACTIONS it names;
//     the actions past it pay as generic (named "Lion Tamer" in a 3-tool chain: Lion Tamer + the step from 2
//     to 3 tools), with the chain's breadth and tempo on that remainder only;
//   * today's sequence rows are NAMED COMBOS BACKED BY THEIR OWN ROWS, kept with their measured pay:
//     Reeled In (hook > melee), Ping-Pong (hook > a shove > hook), Fly Ball (hook yank > anything, in
//     the air), Bowling (a body the hook threw > anything inside 1 s), Pulled In (Force pull > melee),
//     Riposte / Perfect Riposte (block > anything). The tools they cover come off the generic pay the same
//     way. A table combo covered entirely by such a row may still fire when it pays MORE than that row's
//     base pay, and then pays only the difference (the kill earns the table combo's pay in total, never
//     both; the row's own run bonus stays on top);
//   * Variety (tools across a fight) and the melee Combo (kinds across kills) pay for mixing tools too:
//     on a kill whose own chain pays, the chain replaces them;
//   * a kill whose named row carries @slow gets no Bullet Time share for that row: the slow is in its pay;
//   * the chain is one bonus, charged against the per-kill cap like any other; its breakdown rows are
//     its parts (the named combo, the N-Tool Combo).
// ============================================================================

class RS_ComboSeed play
{
	static void Names(out Array<String> into) { into.Push("RS_Bonus_Chain"); }

	// THE DATA TABLE, Score's own rows. Proposed names -- the owner renames after 1.0 (11-03). "a > b" in
	// order, the last step is the finishing blow, the steps before may have other tools between them (but no
	// 3 s gap).
	static void Combos(RS_ScoreRegistry reg)
	{
		reg.OwnCombo("Lion Tamer",      "whip > shield.bash",                   0.5);
		reg.OwnCombo("Clay Pigeon",     "force.push > gun",                     0.5);
		reg.OwnCombo("Sitting Duck",    "force.grip > gun",                     0.5);
		reg.OwnCombo("Pull!",           "force.pull > gun",                     0.5);
		reg.OwnCombo("Disc Jockey",     "force.push > shield.disc",             0.5);
		reg.OwnCombo("Gun Kata",        "hands > gun",                          0.4);
		reg.OwnCombo("Fast Hands",      "melee > rig.draw",                     0.5);
		reg.OwnCombo("Lasso",           "whip > hook.yank",                     0.5);
		reg.OwnCombo("Pitch and Slice", "grab.throw > saber.cut",               0.5);
		reg.OwnCombo("Circus Act",      "whip > hook.yank > gun",               0.9);
		reg.OwnCombo("Yo-Yo",           "force.pull > force.push > gun",        0.9);
		reg.OwnCombo("Discus",          "shield.bash > force.push > shield.disc", 0.9);
		// the owner, 10-29: "allow offhand to grab enemy up to a point so mainhand can punch them, have
		// that be a score combo" -- the off-hand Headlock (RSQ Melee's since 11-01, touching "grab.hold"), then a
		// punch, kick or glove
		reg.OwnCombo("Headlock",        "grab.hold > hands",                    0.5);
		// F.E.A.R. EFFECT (the owner's name, spelt as he wrote it): a shotgun kill in the slow motion after a gun-butt
		// shove. Was RSQ Melee's flat 200-point award (sheet C14); now a Style row on the kill's base, and the award
		// label pays nothing (handler.zs AwardExternal).
		reg.OwnCombo("F.E.A.R. Effect", "shove > gun.shotgun@slow",             0.6);   // over Breach (0.5): the slow is in its pay
		RS_ComboTable.Add(reg);   // the series' signature combos (combos.zs, 11-03)
	}
}

// ---------------------------------------------------------------- the ledger
// One level handler (MAPINFO): saved with the level, empty on a new map. Flat parallel arrays, one entry
// per tool use run: victim, player, tool, the first and last tic of that run, its condition bits and its tags.
// A run is one tool used again and again with nothing else between (a burst of shots is one "gun").
class RS_ComboLedger : EventHandler
{
	const CHAIN_GAP = 105;     // the owner: the chain breaks after 3 seconds between moves
	const TEMPO = 70;          // the whole chain, first move to kill, inside 2 s: the generic part x1.25
	const KEEP = 350;          // entries older than 10 s go
	const MAXE = 384;

	enum ELedgerCond { C_SLOW = 1, C_AIR = 2, C_PB = 4, C_HEAD = 8 }   // not ECond: it is the field eCond, case-insensitively

	Array<Actor> eV;
	Array<int> ePn, eFirst, eLast, eCond, eHits;   // eHits: blows in the run (a burst's pellets count one each)
	Array<String> eTool, eTags;

	// one poll per monster per player per tic
	Array<Actor> pV;
	Array<int> pPn;
	int pTic;
	// a tag sent BEFORE the blow it belongs to, on a body with no run yet (Melee's wall tag comes first, by the
	// contract): held for the run that opens on the same tic
	Array<Actor> hV;
	Array<int> hPn;
	Array<String> hTag;
	int hTic;

	static RS_ComboLedger Get() { return RS_ComboLedger(EventHandler.Find("RS_ComboLedger")); }

	override void WorldThingDamaged(WorldEvent e)
	{
		let v = e.Thing;
		if (!v || !v.bIsMonster || v.player) return;
		let src = e.DamageSource;
		if (!src || !src.player) return;
		int pn = src.PlayerNumber();
		Poll(v, pn);
		String tool = RS_Tool.Classify(v, e.Inflictor, src, e.DamageType, e.DamageFlags);
		Touch(v, pn, tool, level.maptime, CondOf(v, src, e.DamageType));
		// a grenade's blast carries the throw's facts (RSQGN_Service, 11-03): tags on the run
		if (RS_Tool.Prefix(tool) == "grenade" && e.Inflictor)
		{
			if (RS_Svc.Int(RS_Svc.GRENADE, "teeth", 0, e.Inflictor) == 1) Touch(v, pn, "teeth", level.maptime);
			if (RS_Svc.Int(RS_Svc.GRENADE, "skeet", 0, e.Inflictor) == 1) Touch(v, pn, "skeet", level.maptime);
			if (RS_Svc.Int(RS_Svc.GRENADE, "impact", 0, e.Inflictor) == 1) Touch(v, pn, "impact", level.maptime);
			if (RS_Svc.Int(RS_Svc.GRENADE, "cooked", 0, e.Inflictor) >= 35) Touch(v, pn, "cooked", level.maptime);
		}
		// Switcharoo (bonuses.zs): the gun that fired, read off the blow (BD22 VR's guns never call the old door)
		if (tool.Left(3) == "gun" || tool == "rig.draw") RS_ScoreTracker.NoteFire(src, e.Inflictor);
	}

	// the facts about this blow a pattern step may ask for
	int CondOf(Actor v, Actor src, Name dt)
	{
		int c = 0;
		if (RS_Physical.SlowKind() == 1) c |= C_SLOW;                       // the player's own slow motion
		if (RS_Melee.Airborne(v)) c |= C_AIR;
		if (RS_ScoreEvent.MeasureEdgeGap(v, src) < RS_Bonus_PointBlank.DIST) c |= C_PB;
		if (dt == 'Head' || dt == 'MinorHead' || dt == 'Headshot') c |= C_HEAD;
		// RSQ Monsters' MeatGrinder set finds a head shot by where the blow landed, not by damage type (its
		// RS_MGMonster.DamageMobj sets the answer before the engine fires this event), so it is asked by name
		// (RSQ Monsters' RSQMN_RosterService "headshot", 11-09, design/SCORE_EXPANSION.md A3). Without RSQ Monsters: -1, no head.
		else if (RS_Svc.Int(RS_Svc.MONSTERS, "headshot", 0, v) == 1) c |= C_HEAD;
		return c;
	}

	override void WorldTick()
	{
		if ((level.maptime % 35) != 0) return;
		for (int k = eV.Size() - 1; k >= 0; k--)
		{
			let v = eV[k];
			if (!v || level.maptime - eLast[k] > KEEP || (v.health <= 0 && level.maptime - eLast[k] > 35)) Drop(k);
		}
	}

	private void Drop(int k)
	{
		eV.Delete(k); ePn.Delete(k); eFirst.Delete(k); eLast.Delete(k); eTool.Delete(k); eCond.Delete(k); eTags.Delete(k); eHits.Delete(k);
	}

	// the last entry of (v, pn), or -1
	private int LastOf(Actor v, int pn)
	{
		for (int k = eV.Size() - 1; k >= 0; k--) if (eV[k] == v && ePn[k] == pn) return k;
		return -1;
	}

	// A BLOW, now: the same tool as the last one carries the run on, another starts a new one. A tag rides
	// on the newest run. A mod's own name for the blow that just landed replaces the guess (same tic).
	void Touch(Actor v, int pn, String tool, int tic, int cond = 0)
	{
		if (!v || tool == "") return;
		tool = RS_Tool.Canon(tool);
		int j = LastOf(v, pn);
		if (RS_Tool.IsTag(tool))
		{
			if (j >= 0 && tic - eLast[j] <= CHAIN_GAP) AddTag(j, tool);
			else Hold(v, pn, tool, tic);
			return;
		}
		if (j >= 0 && eTool[j] == tool) { eLast[j] = max(eLast[j], tic); eCond[j] |= cond; eHits[j]++; TakeHeld(j, v, pn, tic); return; }
		// the mod named the move BEFORE its blow landed (the contract: a kill by it then reads as that move, since
		// the kill is scored inside the blow): the blow's guess is that move
		if (j >= 0 && eLast[j] == tic && RS_Tool.Guess(tool) && !RS_Tool.Guess(eTool[j])) { eCond[j] |= cond; eHits[j]++; TakeHeld(j, v, pn, tic); return; }
		if (j >= 0 && eLast[j] == tic && RS_Tool.Guess(eTool[j]) && !RS_Tool.Guess(tool))
		{
			eTool[j] = tool; eCond[j] |= cond;
			// the run before it was the same move (a pound's second blow): one run
			int i = PrevOf(v, pn, j);
			if (i >= 0 && eTool[i] == tool) { eLast[i] = max(eLast[i], tic); eCond[i] |= eCond[j]; eHits[i] += eHits[j]; if (eTags[j] != "") AddTags(i, eTags[j]); Drop(j); }
			return;
		}
		Append(v, pn, tool, tic, eV.Size(), cond);
		TakeHeld(LastOf(v, pn), v, pn, tic);
	}

	private void Hold(Actor v, int pn, String tag, int tic)
	{
		if (hTic != tic) { hV.Clear(); hPn.Clear(); hTag.Clear(); hTic = tic; }
		hV.Push(v); hPn.Push(pn); hTag.Push(tag);
	}

	// the tags held for (v, pn) this tic go onto entry k
	private void TakeHeld(int k, Actor v, int pn, int tic)
	{
		if (k < 0 || hTic != tic) return;
		for (int i = hV.Size() - 1; i >= 0; i--)
			if (hV[i] == v && hPn[i] == pn) { AddTag(k, hTag[i]); hV.Delete(i); hPn.Delete(i); hTag.Delete(i); }
	}

	// the entry of (v, pn) before entry k, or -1
	private int PrevOf(Actor v, int pn, int k)
	{
		for (int i = k - 1; i >= 0; i--) if (eV[i] == v && ePn[i] == pn) return i;
		return -1;
	}

	private void AddTags(int k, String tags)
	{
		Array<String> a;
		tags.Split(a, ",", TOK_SKIPEMPTY);
		for (int i = 0; i < a.Size(); i++) AddTag(k, a[i]);
	}

	private void AddTag(int k, String tag)
	{
		if (RS_Tool.HasTag(eTags[k], tag)) return;
		eTags[k] = eTags[k] == "" ? tag : eTags[k] .. "," .. tag;
	}

	// A FACT REPORTED AS "SO LONG AGO" (a bite, a pull, a block): it goes where its time puts it. Asked
	// again and again, the same fact must not become a second entry: a later time on the same tool's run
	// with nothing after it carries that run on; one after other tools is a new use.
	void Note(Actor v, int pn, String tool, int tic)
	{
		if (!v || tool == "" || tic < level.maptime - KEEP) return;
		int last = LastOf(v, pn);
		int same = -1;
		for (int k = eV.Size() - 1; k >= 0; k--) if (eV[k] == v && ePn[k] == pn && eTool[k] == tool) { same = k; break; }
		if (same >= 0)
		{
			if (tic <= eLast[same]) return;
			if (same == last) { eLast[same] = tic; return; }
			if (tic <= eLast[last])
			{
				// a use between the run and the newest entry: the polls missed nothing in between, so it
				// is the same run reported late (the hook's "hooked" counts from the release)
				eLast[same] = tic;
				return;
			}
		}
		// where it goes: after this monster's last entry that began at or before it
		int at = -1;
		for (int k = eV.Size() - 1; k >= 0; k--)
			if (eV[k] == v && ePn[k] == pn && eFirst[k] <= tic) { at = k + 1; break; }
		if (at < 0)
		{
			at = eV.Size();
			for (int k = 0; k < eV.Size(); k++) if (eV[k] == v && ePn[k] == pn) { at = k; break; }
		}
		Append(v, pn, tool, tic, at, 0);
	}

	private void Append(Actor v, int pn, String tool, int tic, int at, int cond)
	{
		if (eV.Size() >= MAXE) { Drop(0); at = max(0, at - 1); }
		at = clamp(at, 0, eV.Size());
		eV.Insert(at, v); ePn.Insert(at, pn); eTool.Insert(at, tool); eFirst.Insert(at, tic); eLast.Insert(at, tic);
		eCond.Insert(at, cond); eTags.Insert(at, ""); eHits.Insert(at, 1);
	}

	// THE FACTS THAT DEAL NO DAMAGE, asked of each mod by name (absent mods answer -1).
	void Poll(Actor v, int pn)
	{
		if (!v) return;
		int now = level.maptime;
		if (pTic != now) { pV.Clear(); pPn.Clear(); pTic = now; }
		for (int k = 0; k < pV.Size(); k++) if (pV[k] == v && pPn[k] == pn) return;
		pV.Push(v); pPn.Push(pn);
		// RSQ_Grapple: the bite (counted from the release: 0 while on the line; an anchor too heavy to come is
		// hook.heavy), the throw, a thrown body striking it (bowling)
		int t = RS_Grapple.Ask("hooked", v);
		if (t >= 0 && RS_Grapple.Ask("hooked.by", v) == pn)
		{
			Note(v, pn, RS_Grapple.Ask("hooked.heavy", v) == 1 ? "hook.heavy" : "hook.bite", now - t);
			int y = RS_Grapple.Ask("yanked", v);
			if (y == 1 || y == 2) Note(v, pn, "hook.yank", y == 1 ? now : now - t);
		}
		t = RS_Grapple.Ask("struck", v);
		if (t >= 0 && RS_Grapple.Ask("struck.by", v) == pn) Note(v, pn, "hook.yank", now - t);
		// RSQ Whip's own rope: the wrap (counted from the release), the yank (it came to you)
		t = RS_Whip.Ask("wrapped", v);
		if (t >= 0 && RS_Whip.Ask("wrapped.by", v) == pn) Note(v, pn, "whip.wrap", now - t);
		t = RS_Whip.Ask("yanked", v);
		if (t >= 0 && RS_Whip.Ask("wrapped.by", v) == pn) Note(v, pn, "whip.yank", now - t);
		// the saber: the Force pull, the grip held now, its block and its parry
		t = AskSaber("pulled", v);
		if (t >= 0) Note(v, pn, "force.pull", now - t);
		if (AskSaber("gripped", v) == 1) Note(v, pn, "force.grip", now);
		t = AskSaber("blocked", v);
		if (t >= 0) Note(v, pn, "saber.block", now - t);
		t = AskSaber("perfect", v);
		if (t >= 0) Note(v, pn, "saber.parry", now - t);
		// the ShieldSaw's block and its perfect block
		t = RS_Melee.AskShield("blocked", v);
		if (t >= 0) Note(v, pn, "shield.block", now - t);
		t = RS_Melee.AskShield("perfect", v);
		if (t >= 0) Note(v, pn, "shield.perfect", now - t);
	}

	static int AskSaber(String request, Actor about)
	{
		return RS_Svc.Int(RS_Svc.SABER, request, 0, about);
	}

	// THE CHAIN that ended on v, for player pn, oldest first: walked back from the newest run while each
	// gap is at most CHAIN_GAP, and the newest run must be at most CHAIN_GAP old. `idx` are the ledger
	// entries (for a step's conditions), `span` the tics from the chain's first move to now.
	void Chain(Actor v, int pn, out Array<String> steps, out Array<int> idx, out int span)
	{
		steps.Clear(); idx.Clear(); span = 0;
		Array<int> mine;
		for (int k = 0; k < eV.Size(); k++) if (eV[k] == v && ePn[k] == pn) mine.Push(k);
		int n = mine.Size();
		if (n == 0 || level.maptime - eLast[mine[n - 1]] > CHAIN_GAP) return;
		int from = n - 1;
		while (from > 0 && eFirst[mine[from]] - eLast[mine[from - 1]] <= CHAIN_GAP) from--;
		for (int k = from; k < n; k++) { steps.Push(eTool[mine[k]]); idx.Push(mine[k]); }
		span = level.maptime - eFirst[mine[from]];
	}

	// does ledger entry k satisfy pattern step `step`
	bool StepOk(int k, String step)
	{
		if (k < 0 || k >= eV.Size()) return false;
		return RS_Tool.StepMatches(eTool[k], eCond[k], eTags[k], step);
	}

	// the tool of the newest run of (v, pn) when that run was touched this very tic, else "" (the kill
	// reads its own blow back: melee.zs KindOf)
	String ToolNow(Actor v, int pn)
	{
		int j = LastOf(v, pn);
		return (j >= 0 && eLast[j] == level.maptime) ? eTool[j] : "";
	}

	// a tag on the newest run of (v, pn) inside the chain gap
	bool TagNow(Actor v, int pn, String tag)
	{
		int j = LastOf(v, pn);
		return j >= 0 && level.maptime - eLast[j] <= CHAIN_GAP && RS_Tool.HasTag(eTags[j], tag);
	}

	// a tag on ledger entry k (a chain step), and the entry's blows and span (rows.zs reads them)
	bool TagAt(int k, String tag) { return k >= 0 && k < eV.Size() && RS_Tool.HasTag(eTags[k], tag); }
	int HitsAt(int k) { return (k >= 0 && k < eV.Size()) ? eHits[k] : 0; }
	int SpanAt(int k) { return (k >= 0 && k < eV.Size()) ? eLast[k] - eFirst[k] : 0; }
	int CondAt(int k) { return (k >= 0 && k < eV.Size()) ? eCond[k] : 0; }

	// for the debug line and the probe
	String Describe(Actor v, int pn)
	{
		String s = "";
		for (int k = 0; k < eV.Size(); k++)
			if (eV[k] == v && ePn[k] == pn)
				s = s .. String.Format("%s%s@%d-%d%s%s", s == "" ? "" : " ", eTool[k], eFirst[k], eLast[k],
					eCond[k] ? String.Format("[c%d]", eCond[k]) : "", eTags[k] != "" ? "{" .. eTags[k] .. "}" : "");
		return s;
	}
}

// RSQ Whip's service (RSQWP_Service), asked by name: its rope, wrap and yank, the crack's weight. -1: not loaded,
// or a Whip that does not answer it.
class RS_Whip play
{
	static int Ask(String request, Object about, int arg = 0)
	{
		if (!about) return -1;
		return RS_Svc.Int(RS_Svc.WHIP, request, arg, about);
	}
}

// ---------------------------------------------------------------- the bonus
class RS_Combo play
{
	// the kill's chain, worked out once (the bonus and the handler's publish both ask)
	static void ChainOf(RS_ScoreEvent ev)
	{
		if (ev.chainAsked) return;
		ev.chainAsked = true;
		ev.chain.Clear(); ev.chainIdx.Clear(); ev.chainSpan = 0;
		if (!ev.killer || ev.killerNum < 0 || !ev.victim) return;
		let led = RS_ComboLedger.Get();
		if (!led) return;
		led.Poll(ev.victim, ev.killerNum);
		led.Chain(ev.victim, ev.killerNum, ev.chain, ev.chainIdx, ev.chainSpan);
	}

	// MIXING TOOLS IS PAID ONCE A KILL: when the kill's own chain mixed two or more tools (paid by the
	// chain, or by a row that is a named combo already -- Reeled In, Riposte...), Variety and the melee
	// Combo (the mix across kills) stand down for that kill. They still remember it.
	static bool Mixed(RS_ScoreEvent ev)
	{
		ChainOf(ev);
		return Tools(ev.chain) >= 2;
	}

	static int Tools(Array<String> steps)
	{
		Array<String> seen;
		for (int k = 0; k < steps.Size(); k++)
		{
			String act = RS_Tool.ActionOf(steps[k]);
			bool had = false;
			for (int j = 0; j < seen.Size(); j++) if (seen[j] == act) { had = true; break; }
			if (!had) seen.Push(act);
		}
		return seen.Size();
	}

	// the mods the chain's tools came from
	static int Mods(Array<String> steps)
	{
		Array<String> seen;
		for (int k = 0; k < steps.Size(); k++)
		{
			String m = RS_Tool.ModOf(steps[k]);
			bool had = false;
			for (int j = 0; j < seen.Size(); j++) if (seen[j] == m) { had = true; break; }
			if (!had) seen.Push(m);
		}
		return seen.Size();
	}

	// THE SCALE: what N actions in one chain are worth before any name (COMBOS_MASTER section 2)
	static double Scale(int n)
	{
		if (n <= 1) return 0.0;
		if (n == 2) return 0.2;
		if (n == 3) return 0.45;
		if (n == 4) return 0.75;
		if (n == 5) return 1.0;
		return 1.2;
	}

	// Does the pattern (steps p[ps .. ps+pc-1]) match the chain? The last step must be the finishing
	// blow; the others in order, anywhere before it. The chain positions used go into `used`.
	static bool Match(RS_ScoreRegistry reg, int c, RS_ScoreEvent ev, out Array<int> used)
	{
		used.Clear();
		int ps, pc; double m;
		[ps, pc, m] = reg.ComboSteps(c);
		int n = ev.chain.Size();
		if (pc < 1 || n < 1) return false;
		let led = RS_ComboLedger.Get();
		if (!led) return false;
		if (!led.StepOk(ev.chainIdx[n - 1], reg.Step(ps + pc - 1))) return false;
		used.Push(n - 1);
		int at = n - 2;
		for (int q = pc - 2; q >= 0; q--)
		{
			while (at >= 0 && !led.StepOk(ev.chainIdx[at], reg.Step(ps + q))) at--;
			if (at < 0) return false;
			used.Push(at);
			at--;
		}
		return true;
	}
}

class RS_Bonus_Chain : RS_ScoreBonus
{
	const NGEN = 5;            // rows 0..4: 2-, 3-, 4-, 5-, 6-Tool Combo; then one row per named combo
	const BREADTH = 0.1;       // per mod past two in the chain, to BREADTH_MAX
	const BREADTH_MAX = 0.3;
	const TEMPO_MULT = 1.25;   // the whole chain inside RS_ComboLedger.TEMPO

	// this kill's answer (the bonus is one shared object; the handler asks Evaluate, Supersedes and the
	// row shares for one kill before the next)
	int lastNamed;             // index into the registry's combo table, or -1
	double lastNamedMult, lastGeneric, lastBreadth;
	bool lastTempo, lastNamedSlow;
	int lastTools, lastMods;

	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Combo Chain"; }

	override int RowCount() const { return NGEN + RS_ScoreRegistry.ComboCount(); }
	override String RowName(int i) const
	{
		if (i < NGEN) return String.Format("%d-Tool Combo", i + 2);
		return RS_ScoreRegistry.ComboName(i - NGEN);
	}
	override double RowShare(int i) const
	{
		double total = lastNamedMult + lastGeneric;
		if (total <= 0) return 0.0;
		if (i < NGEN) return (i == clamp(lastTools - 2, 0, NGEN - 1)) ? lastGeneric / total : 0.0;
		return (i - NGEN == lastNamed) ? lastNamedMult / total : 0.0;
	}

	// THE ROWS THAT ARE ALREADY NAMED COMBOS (their own classes, their own measured pay): the setup step
	// each one covers, as a pattern group, and its base pay (what a table combo covered by it must beat).
	static String RowSetup(RS_ScoreBonus b)
	{
		if (b is "RS_Bonus_ReeledIn") return "hook";
		if (b is "RS_Bonus_PingPong") return "hook";
		if (b is "RS_Bonus_FlyBall") return "hook";
		if (b is "RS_Bonus_Bowling") return "hook";
		if (b is "RS_Bonus_PulledIn") return "force.pull";
		if (b is "RS_Bonus_Riposte" || b is "RS_Bonus_PerfectRiposte") return "block";
		return "";
	}
	static double RowBase(RS_ScoreBonus b)
	{
		if (b is "RS_Bonus_ReeledIn") return RS_Bonus_ReeledIn.MULT;
		if (b is "RS_Bonus_PingPong") return RS_Bonus_PingPong.MULT;
		if (b is "RS_Bonus_FlyBall") return RS_Bonus_FlyBall.MULT;
		if (b is "RS_Bonus_Bowling") return RS_Bonus_Bowling.MULT;
		if (b is "RS_Bonus_PulledIn") return RS_Bonus_PulledIn.MULT;
		if (b is "RS_Bonus_PerfectRiposte") return RS_Bonus_PerfectRiposte.MULT;
		if (b is "RS_Bonus_Riposte") return RS_Bonus_Riposte.MULT;
		return 0.0;
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		lastNamed = -1; lastNamedMult = 0; lastGeneric = 0; lastBreadth = 0; lastTools = 0; lastMods = 0;
		lastTempo = false; lastNamedSlow = false;
		if (!ev.killer || ev.killerNum < 0 || !ev.victim) return 0.0;
		RS_Combo.ChainOf(ev);
		int n = RS_Combo.Tools(ev.chain);
		lastTools = n;
		lastMods = RS_Combo.Mods(ev.chain);
		if (n < 1) return 0.0;

		// the tools some name already covers (as actions)
		Array<String> covered;

		// 1. the rows that are named combos already (their own classes, their own measured pay): here they
		//    only cover tools, and set the pay a table combo under them must beat
		Array<String> rowCov;
		double rowBase = 0;
		Array<RS_ScoreBonus> all;
		RS_ScoreRegistry.GetBonuses(all);
		for (int b = 0; b < all.Size(); b++)
		{
			String setup = RowSetup(all[b]);
			if (setup == "" || all[b].Evaluate(ev) <= 0) continue;
			rowBase = max(rowBase, RowBase(all[b]));
			AddAction(rowCov, ev.chain[ev.chain.Size() - 1]);
			// Ping-Pong is the whole rally: the bites and every shove between them
			bool rally = all[b] is "RS_Bonus_PingPong";
			int first = -1;
			for (int k = ev.chain.Size() - 2; k >= 0; k--)
			{
				String t = ev.chain[k];
				if (setup == "block" ? RS_Tool.InGroup(t, "block") : RS_Tool.InGroup(t, setup))
				{
					AddAction(rowCov, t);
					first = k;
					if (!rally) break;
				}
			}
			if (rally) for (int k = max(0, first); first >= 0 && k < ev.chain.Size(); k++) AddAction(rowCov, ev.chain[k]);
		}
		for (int k = 0; k < rowCov.Size(); k++) covered.Push(rowCov[k]);

		// 2. the data table: the best-paying match. One that names a tool those rows do not already pay for
		//    pays whole; one they cover entirely pays only what it has past the row's base (B S9).
		Array<int> used, bestUsed;
		double best = 0;
		let reg = RS_ScoreRegistry.Get();
		for (int c = 0; reg && c < reg.NumCombos(); c++)
		{
			int ps, pc; double m;
			[ps, pc, m] = reg.ComboSteps(c);
			if (m <= best) continue;
			String filter = reg.Filter(c);
			if (filter != "" && !RS_Tool.VictimIs(ev.victim, filter)) continue;
			if (!RS_Combo.Match(reg, c, ev, used)) continue;
			bool fresh = false;
			for (int k = 0; k < used.Size() && !fresh; k++) fresh = !Has(rowCov, RS_Tool.ActionOf(ev.chain[used[k]]));
			double pay = fresh ? m : m - rowBase;
			if (pay <= best) continue;
			best = pay; lastNamed = c; bestUsed.Copy(used);
		}
		lastNamedMult = best;
		for (int k = 0; k < bestUsed.Size(); k++) AddAction(covered, ev.chain[bestUsed[k]]);
		if (lastNamed >= 0)
		{
			int ps, pc; double m;
			[ps, pc, m] = reg.ComboSteps(lastNamed);
			for (int q = 0; q < pc; q++) if (RS_Tool.StepIsSlow(reg.Step(ps + q))) lastNamedSlow = true;
		}

		// 3. the actions past what the names cover pay as a generic chain, with the chain's breadth (mods past
		//    two) and tempo (the whole chain inside 2 s) on that remainder only
		int cov = covered.Size();
		double gen = max(0.0, RS_Combo.Scale(n) - (cov >= 2 ? RS_Combo.Scale(min(cov, n)) : 0.0));
		if (gen > 0)
		{
			lastBreadth = min(BREADTH_MAX, BREADTH * max(0, lastMods - 2));
			lastTempo = ev.chainSpan <= RS_ComboLedger.TEMPO;
			lastGeneric = (gen + lastBreadth) * (lastTempo ? TEMPO_MULT : 1.0);
		}
		return lastNamedMult + lastGeneric;
	}

	private static bool Has(Array<String> a, String x)
	{
		for (int k = 0; k < a.Size(); k++) if (a[k] == x) return true;
		return false;
	}

	private static void AddAction(out Array<String> into, String tool)
	{
		String act = RS_Tool.ActionOf(tool);
		for (int k = 0; k < into.Size(); k++) if (into[k] == act) return;
		into.Push(act);
	}

	// a signature combo of three steps or more, five actions in one chain, or four mods
	override bool BigMoment(RS_ScoreEvent ev, double paid) const
	{
		if (paid <= 0) return false;
		if (lastNamed >= 0 && RS_ScoreRegistry.ComboLength(lastNamed) >= 3) return true;
		return lastTools >= 5 || lastMods >= 4;
	}

	override void Commit(RS_ScoreEvent ev)
	{
		// the HUD's word breathes brighter on a big combo (hud.zs)
		if (ev.tracker && (lastNamedMult + lastGeneric) > 0 && (lastNamed >= 0 || lastTools >= 3)) ev.tracker.bigComboTic = level.maptime;
	}

	override String DebugName() const
	{
		String s = "Combo Chain";
		if (lastNamed >= 0) s = s .. "[" .. RS_ScoreRegistry.ComboName(lastNamed) .. String.Format(" %.2f", lastNamedMult) .. "]";
		if (lastGeneric > 0) s = s .. String.Format("[%d-Tool %.2f%s%s]", lastTools, lastGeneric, lastBreadth > 0 ? String.Format(" mods%d+%.1f", lastMods, lastBreadth) : "", lastTempo ? " tempo" : "");
		return s;
	}
}
