// ============================================================================
// THE COMBO SYSTEM: every monster keeps an ordered history of the TOOLS that touched it, and a kill
// pays for the chain of tools that led to it.
//
// The owner, 10-27: the series' mods are tools for your hands; Score is the arcade room. His rules:
//   * ORDER MATTERS ("whip, then bash" is not "bash, then whip");
//   * the chain BREAKS after 3 SECONDS between moves (CHAIN_GAP);
//   * GUNS COUNT as tools (every gun is the one tool "gun": swapping guns is Switcharoo's business);
//   * named SIGNATURE combos come from a DATA TABLE (RegisterCombo below, any mod may add rows);
//   * an unnamed chain still pays, as a generic 2-, 3- or 4-tool combo.
// Nothing names a monster class: the history is what happened to the body, on any monster set.
//
// WHERE A TOUCH COMES FROM, nothing linked:
//   a blow that lands (WorldThingDamaged, the player the source): classified by what struck, the same
//                     facts the melee and physical families read (Classify below);
//   what does no damage, asked by name at the next blow or the death (Poll): RSQ_Grapple's "hooked" /
//                     "hooked.by" / "yanked" / "struck", the saber's "pulled" / "gripped" / "blocked",
//                     the ShieldSaw's "blocked" -- each answers "how long ago", so the order is kept;
//   any other mod:    RS_ScoreService GetInt("touch", "<tool id>", playerNumber, 0, monster).
//
// THE TOOLS (ids; a pattern step may name a tool or a GROUP: its prefix -- "force", "shield", "hook",
// "saber" -- or "melee", "hands", "any", or a group a mod registered with RegisterTool):
//   gun            any shot of yours (a puff, a missile, a trace) that no other row claims
//   rig.draw       a shot inside 42 tics of a Tactical Rig holster draw (Quick Draw's window)
//   saber.cut      a lightsaber cut          saber.throw   the saber thrown
//   saber.return   a shot the saber or the Force turned back      saber.block   the saber blocked its attack
//   force.push     the Force push            force.pull    the Force pull     force.grip   the grip (choke, slam)
//   shield.bash    the ShieldSaw's bash or revved grind in the hand
//   shield.disc    the ShieldSaw thrown      shield.block  it blocked that monster's attack, or a shot it
//                                                          turned back struck (block-return)
//   hook.bite      RSQ_Grapple's claw took it        hook.yank   the hook threw it (or a body it threw struck it)
//   whip           the whip's crack
//   grab.throw     something thrown with Distance Grab
//   grab.hold      Distance Grab's off hand holding it (the walk-up grip on a living monster)
//   kick / punch / glove / blade / finisher   Brutal Doom's boots, fists (and the VR pistol whip), the
//                  boxing gloves, an axe/chainsaw/sword, a fatality
// A yank always follows a bite: "hook.bite, hook.yank" is ONE action for counting tools (ActionOf()).
//
// NOTHING SCORES TWICE:
//   * a named combo replaces the generic pay for the tools it names; the generic part pays only the
//     tools past it (named "Lion Tamer" in a 3-tool chain: Lion Tamer + 3-Tool Combo minus 2-Tool);
//   * today's sequence rows are NAMED COMBOS BACKED BY THEIR OWN ROWS, kept with their measured pay:
//     Reeled In (hook > melee), Ping-Pong (hook > a shove > hook), Fly Ball (hook yank > anything, in
//     the air), Bowling (a body the hook threw > anything inside 1 s), Pulled In (Force pull > melee),
//     Riposte / Perfect Riposte (block > anything). When one fires, the tools it covers come off the
//     generic pay the same way, and a named combo from the table must name a tool they do not;
//   * Variety (tools across a fight) and the melee Combo (kinds across kills) pay for mixing tools too:
//     on a kill whose own chain pays, the chain replaces them;
//   * the chain is one bonus, charged against the per-kill cap like any other; its breakdown rows are
//     its parts (the named combo, the N-Tool Combo).
// ============================================================================

class RS_ComboSeed play
{
	static void Names(out Array<String> into) { into.Push("RS_Bonus_Chain"); }

	// THE DATA TABLE, Score's own rows. Proposed names -- the owner vetoes. "a > b" in order, the last
	// step is the finishing blow, the steps before may have other tools between them (but no 3 s gap).
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
		// that be a score combo" -- Distance Grab's off-hand headlock, then a punch, kick or glove
		reg.OwnCombo("Headlock",        "grab.hold > hands",                    0.5);
	}
}

// ---------------------------------------------------------------- the tools
class RS_Tool play
{
	// what one tool counts as when the tools of a chain are counted: a yank is the bite's own follow-through
	static String ActionOf(String t) { return t == "hook.yank" ? "hook.bite" : t; }

	static bool IsMelee(String t)
	{
		return t == "saber.cut" || t == "saber.throw" || t == "shield.bash" || t == "shield.disc"
			|| t == "blade" || t == "punch" || t == "glove" || t == "kick" || t == "finisher" || t == "whip"
			|| t.Left(6) == "force.";
	}

	// does tool t answer to pattern step g
	static bool InGroup(String t, String g)
	{
		if (g == "any" || t == g) return true;
		if (g == "melee") return IsMelee(t);
		if (g == "hands") return t == "kick" || t == "punch" || t == "glove";
		int dp = t.IndexOf(".");
		if (dp > 0 && t.Left(dp) == g) return true;
		return RS_ScoreRegistry.ToolInGroup(t, g);
	}

	// WHAT STRUCK, for a blow a player dealt (src) to a monster (v). The melee family's facts (melee.zs
	// KindOf, measured there), read for any blow and not only the killing one.
	static String Classify(Actor v, Actor inf, Actor src, Name dt, int flags)
	{
		String icn = "";
		if (inf) icn = inf.GetClassName();
		int pn = src.PlayerNumber();
		if (icn ~== "SSQ_Disc") return "shield.disc";
		if (icn ~== "UBQS_Thrown") return "saber.throw";
		if (icn ~== "UBQS_Force") return dt == 'Force' ? "force.grip" : "force.push";
		if (icn ~== "UBQS_Bolt" || icn ~== "UBQS_RemoteBolt") return "saber.return";
		// RSQ_Grapple's own blows: noted by its service before they land (asked only for a blow that
		// could be one: every blow passes through here, a shotgun's twenty pellets a tic)
		if (dt == 'Melee' && inf == src && RS_Grapple.Ask("whipped", v) == 0) return "whip";
		if (dt == 'Melee' && !inf && (RS_Grapple.Ask("landing", v) == 0 || RS_Grapple.Ask("struck", v) == 0)) return "hook.yank";
		bool shot = inf && (inf.bIsPuff || inf.bMissile);
		if (!shot && RS_Grapple.Ask("hook.dealing", src) == 1) return "hook.bite";
		if (inf && inf != src && !inf.bIsPuff && RS_Physical.AskGrab("throw.by", inf) == pn) return "grab.throw";
		if (RS_Melee.IsGlove(inf)) return "glove";
		// a shot sent back: turned by the shield, or a monster's missile now yours (the saber, the Force)
		if (shot && inf != src && (RS_Melee.AskShield("returned", inf) >= 0 || RS_Melee.AskShield("returned", v) >= 0)) return "shield.block";
		if (inf && inf.bMissile && RS_ScoreShots.BornOfMonster(inf)) return "saber.return";
		if (dt == 'Fatality') return "finisher";
		if (dt == 'Saber') return "saber.cut";
		if (inf == src && RS_Melee.ShieldInHand(src) && (dt == 'Melee' || dt == 'Saw')) return "shield.bash";
		if (dt == 'Saw' || dt == 'Cut') return "blade";
		if (dt == 'Kick' || dt == 'HeadKick' || dt == 'Stomp') return "kick";
		if (dt == 'Melee' || dt == 'ExtremePunches') return "punch";
		// a shot. Inside Quick Draw's window after a holster draw, it is the draw's.
		int t = RS_Physical.AskRig("rig.drawtic", src);
		if (t >= 0 && level.maptime - t <= RS_Bonus_QuickDraw.WINDOW) return "rig.draw";
		return "gun";
	}
}

// ---------------------------------------------------------------- the ledger
// One level handler (MAPINFO): saved with the level, empty on a new map. Flat parallel arrays, one entry
// per tool use run: victim, player, tool, the first and last tic of that run. A run is one tool used
// again and again with nothing else between (a burst of shots is one "gun").
class RS_ComboLedger : EventHandler
{
	const CHAIN_GAP = 105;     // the owner: the chain breaks after 3 seconds between moves
	const KEEP = 350;          // entries older than 10 s go
	const MAXE = 384;

	Array<Actor> eV;
	Array<int> ePn, eFirst, eLast;
	Array<String> eTool;

	// one poll per monster per player per tic
	Array<Actor> pV;
	Array<int> pPn;
	int pTic;

	static RS_ComboLedger Get() { return RS_ComboLedger(EventHandler.Find("RS_ComboLedger")); }

	override void WorldThingDamaged(WorldEvent e)
	{
		let v = e.Thing;
		if (!v || !v.bIsMonster || v.player) return;
		let src = e.DamageSource;
		if (!src || !src.player) return;
		int pn = src.PlayerNumber();
		Poll(v, pn);
		Touch(v, pn, RS_Tool.Classify(v, e.Inflictor, src, e.DamageType, e.DamageFlags), level.maptime);
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
		eV.Delete(k); ePn.Delete(k); eFirst.Delete(k); eLast.Delete(k); eTool.Delete(k);
	}

	// the last entry of (v, pn), or -1
	private int LastOf(Actor v, int pn)
	{
		for (int k = eV.Size() - 1; k >= 0; k--) if (eV[k] == v && ePn[k] == pn) return k;
		return -1;
	}

	// A BLOW, now: the same tool as the last one carries the run on, another starts a new one.
	void Touch(Actor v, int pn, String tool, int tic)
	{
		if (!v || tool == "") return;
		int j = LastOf(v, pn);
		if (j >= 0 && eTool[j] == tool) { eLast[j] = max(eLast[j], tic); return; }
		Append(v, pn, tool, tic, eV.Size());
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
		Append(v, pn, tool, tic, at);
	}

	private void Append(Actor v, int pn, String tool, int tic, int at)
	{
		if (eV.Size() >= MAXE) { Drop(0); at = max(0, at - 1); }
		at = clamp(at, 0, eV.Size());
		eV.Insert(at, v); ePn.Insert(at, pn); eTool.Insert(at, tool); eFirst.Insert(at, tic); eLast.Insert(at, tic);
	}

	// THE FACTS THAT DEAL NO DAMAGE, asked of each mod by name (absent mods answer -1).
	void Poll(Actor v, int pn)
	{
		if (!v) return;
		int now = level.maptime;
		if (pTic != now) { pV.Clear(); pPn.Clear(); pTic = now; }
		for (int k = 0; k < pV.Size(); k++) if (pV[k] == v && pPn[k] == pn) return;
		pV.Push(v); pPn.Push(pn);
		// RSQ_Grapple: the bite (counted from the release: 0 while on the line), the throw, a thrown
		// body striking it (bowling)
		int t = RS_Grapple.Ask("hooked", v);
		if (t >= 0 && RS_Grapple.Ask("hooked.by", v) == pn)
		{
			Note(v, pn, "hook.bite", now - t);
			int y = RS_Grapple.Ask("yanked", v);
			if (y == 1 || y == 2) Note(v, pn, "hook.yank", y == 1 ? now : now - t);
		}
		t = RS_Grapple.Ask("struck", v);
		if (t >= 0 && RS_Grapple.Ask("struck.by", v) == pn) Note(v, pn, "hook.yank", now - t);
		// the saber: the Force pull, the grip held now, its block
		t = AskSaber("pulled", v);
		if (t >= 0) Note(v, pn, "force.pull", now - t);
		if (AskSaber("gripped", v) == 1) Note(v, pn, "force.grip", now);
		t = AskSaber("blocked", v);
		if (t >= 0) Note(v, pn, "saber.block", now - t);
		// the ShieldSaw's block
		t = RS_Melee.AskShield("blocked", v);
		if (t >= 0) Note(v, pn, "shield.block", now - t);
	}

	static int AskSaber(String request, Actor about)
	{
		return RS_Svc.Int(RS_Svc.SABER, request, 0, about);
	}

	// THE CHAIN that ended on v, for player pn, oldest first: walked back from the newest run while each
	// gap is at most CHAIN_GAP, and the newest run must be at most CHAIN_GAP old.
	void Chain(Actor v, int pn, out Array<String> steps)
	{
		steps.Clear();
		Array<int> mine;
		for (int k = 0; k < eV.Size(); k++) if (eV[k] == v && ePn[k] == pn) mine.Push(k);
		int n = mine.Size();
		if (n == 0 || level.maptime - eLast[mine[n - 1]] > CHAIN_GAP) return;
		int from = n - 1;
		while (from > 0 && eFirst[mine[from]] - eLast[mine[from - 1]] <= CHAIN_GAP) from--;
		for (int k = from; k < n; k++) steps.Push(eTool[mine[k]]);
	}

	// for the debug line and the probe
	String Describe(Actor v, int pn)
	{
		String s = "";
		for (int k = 0; k < eV.Size(); k++)
			if (eV[k] == v && ePn[k] == pn) s = s .. String.Format("%s%s@%d-%d", s == "" ? "" : " ", eTool[k], eFirst[k], eLast[k]);
		return s;
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
		ev.chain.Clear();
		if (!ev.killer || ev.killerNum < 0 || !ev.victim) return;
		let led = RS_ComboLedger.Get();
		if (!led) return;
		led.Poll(ev.victim, ev.killerNum);
		led.Chain(ev.victim, ev.killerNum, ev.chain);
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

	// the generic pay for N tools
	static double Generic(int n)
	{
		if (n <= 1) return 0.0;
		if (n == 2) return RS_Bonus_Chain.GEN2;
		if (n == 3) return RS_Bonus_Chain.GEN3;
		return RS_Bonus_Chain.GEN4;
	}

	// Does the pattern (steps p[ps .. ps+pc-1]) match the chain? The last step must be the finishing
	// blow; the others in order, anywhere before it. The chain positions used go into `used`.
	static bool Match(RS_ScoreRegistry reg, int c, Array<String> chain, out Array<int> used)
	{
		used.Clear();
		int ps, pc; double m;
		[ps, pc, m] = reg.ComboSteps(c);
		int n = chain.Size();
		if (pc < 1 || n < 1) return false;
		if (!RS_Tool.InGroup(chain[n - 1], reg.Step(ps + pc - 1))) return false;
		used.Push(n - 1);
		int at = n - 2;
		for (int q = pc - 2; q >= 0; q--)
		{
			while (at >= 0 && !RS_Tool.InGroup(chain[at], reg.Step(ps + q))) at--;
			if (at < 0) return false;
			used.Push(at);
			at--;
		}
		return true;
	}
}

class RS_Bonus_Chain : RS_ScoreBonus
{
	const GEN2 = 0.2;
	const GEN3 = 0.4;
	const GEN4 = 0.6;
	const NGEN = 3;            // rows 0..2: 2-, 3-, 4-Tool Combo; then one row per named combo

	// this kill's answer (the bonus is one shared object; the handler asks Evaluate, Supersedes and the
	// row shares for one kill before the next)
	int lastNamed;             // index into the registry's combo table, or -1
	double lastNamedMult, lastGeneric;
	int lastTools;

	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Combo Chain"; }

	override int RowCount() const { return NGEN + RS_ScoreRegistry.ComboCount(); }
	override String RowName(int i) const
	{
		if (i == 0) return "2-Tool Combo";
		if (i == 1) return "3-Tool Combo";
		if (i == 2) return "4-Tool Combo";
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
	// each one covers, as a pattern group.
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

	override double Evaluate(RS_ScoreEvent ev)
	{
		lastNamed = -1; lastNamedMult = 0; lastGeneric = 0; lastTools = 0;
		if (!ev.killer || ev.killerNum < 0 || !ev.victim) return 0.0;
		RS_Combo.ChainOf(ev);
		int n = RS_Combo.Tools(ev.chain);
		lastTools = n;
		if (n < 1) return 0.0;

		// the tools some name already covers (as actions)
		Array<String> covered;

		// 1. the rows that are named combos already (their own classes, their own measured pay): here they
		//    only cover tools
		Array<String> rowCov;
		Array<RS_ScoreBonus> all;
		RS_ScoreRegistry.GetBonuses(all);
		for (int b = 0; b < all.Size(); b++)
		{
			String setup = RowSetup(all[b]);
			if (setup == "" || all[b].Evaluate(ev) <= 0) continue;
			AddAction(rowCov, ev.chain[ev.chain.Size() - 1]);
			// Ping-Pong is the whole rally: the bites and every shove between them
			bool rally = all[b] is "RS_Bonus_PingPong";
			int first = -1;
			for (int k = ev.chain.Size() - 2; k >= 0; k--)
			{
				String t = ev.chain[k];
				if (setup == "block" ? (t == "shield.block" || t == "saber.block") : RS_Tool.InGroup(t, setup))
				{
					AddAction(rowCov, t);
					first = k;
					if (!rally) break;
				}
			}
			if (rally) for (int k = max(0, first); first >= 0 && k < ev.chain.Size(); k++) AddAction(rowCov, ev.chain[k]);
		}
		for (int k = 0; k < rowCov.Size(); k++) covered.Push(rowCov[k]);

		// 2. the data table: the best-paying match -- one that names at least one tool those rows do not
		//    already pay for (a kick inside a Ping-Pong rally is not also Gun Kata)
		Array<int> used, bestUsed;
		double best = 0;
		let reg = RS_ScoreRegistry.Get();
		for (int c = 0; reg && c < reg.NumCombos(); c++)
		{
			int ps, pc; double m;
			[ps, pc, m] = reg.ComboSteps(c);
			if (m <= best) continue;
			if (!RS_Combo.Match(reg, c, ev.chain, used)) continue;
			bool fresh = false;
			for (int k = 0; k < used.Size() && !fresh; k++) fresh = !Has(rowCov, RS_Tool.ActionOf(ev.chain[used[k]]));
			if (!fresh) continue;
			best = m; lastNamed = c; bestUsed.Copy(used);
		}
		lastNamedMult = best;
		for (int k = 0; k < bestUsed.Size(); k++) AddAction(covered, ev.chain[bestUsed[k]]);

		// 3. the tools past what the names cover pay as a generic chain
		int cov = covered.Size();
		lastGeneric = max(0.0, RS_Combo.Generic(n) - (cov >= 2 ? RS_Combo.Generic(min(cov, n)) : 0.0));
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

	// a three-step signature combo, or four tools in one chain
	override bool BigMoment(RS_ScoreEvent ev, double paid) const
	{
		if (paid <= 0) return false;
		if (lastNamed >= 0 && RS_ScoreRegistry.ComboLength(lastNamed) >= 3) return true;
		return lastTools >= 4;
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
		if (lastGeneric > 0) s = s .. String.Format("[%d-Tool %.2f]", lastTools, lastGeneric);
		return s;
	}
}
