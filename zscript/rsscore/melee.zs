// ============================================================================
// THE FOURTH FAMILY: MELEE -- the Quest series' own (not ijon's; see CREDITS.md).
//
// The owner, 10-27: "we do have impressive melee abilities in our engine, and in BD 22
// weapons". The three families say HOW a kill happened in general; melee in VR is its own
// craft -- the swing, the parry, the throw, the finisher -- so it gets its own colour and its
// own cap, and the original thirteen are left exactly as they were (Brawler stays in Daring).
//
// WHERE THE FACTS COME FROM, and nothing here links against another mod:
//   the damage type     'Saber' (UltraBadassQuestSaber's cuts), 'Saw' / 'Cut' (Brutal Doom's
//                       axe, chainsaw and the BD22 VR swings, which spawn BD's own AxeAttack /
//                       DSAttack), 'Melee' 'Kick' 'HeadKick' 'Stomp' 'ExtremePunches' (BD's
//                       fists and boots), 'Fatality' (BD's executions) -- measured in
//                       brutal22test6's actors, not remembered
//   the inflictor       SSQ_Disc (the ShieldSaw thrown), UBQS_Thrown (the saber thrown),
//                       UBQS_Bolt (a shot the saber returned), the pawn itself (the shield's
//                       bash and grind) -- compared by class NAME, so absent mods cost nothing
//   SSQ_ScoreService    the shield's memory of blocks and turned shots (a block does no damage,
//                       so a scorer never hears of it otherwise) -- found by name
//   RS_ScoreShots       below: which shots were born of a monster, for a returned one
// ============================================================================

// the bonuses this file adds to the registry (bonus.zs SeedOwn calls this)
class RS_MeleeSeed play
{
	static void Names(out Array<String> into)
	{
		into.Push("RS_Bonus_Fatality");
		into.Push("RS_Bonus_Cleaved");
		into.Push("RS_Bonus_Hurled");
		into.Push("RS_Bonus_ShieldWork");
		into.Push("RS_Bonus_Riposte");
		into.Push("RS_Bonus_ReturnToSender");
		into.Push("RS_Bonus_Combo");
	}
}

class RS_Melee play
{
	enum EKind
	{
		MK_NONE,
		MK_SABER,      // a saber cut
		MK_DISC,       // the ShieldSaw thrown
		MK_THROWN,     // the saber thrown
		MK_BASH,       // the shield's bash
		MK_GRIND,      // the shield's revved grind, held
		MK_BLADE,      // an axe, a chainsaw, a sword (Brutal Doom's Saw / Cut)
		MK_FIST,       // fists and boots
		MK_FINISH,     // a Brutal Doom fatality
	}

	static int Kind(RS_ScoreEvent ev)
	{
		if (!ev.killer) return MK_NONE;
		Name dt = ev.damageType;
		String inf = "";
		if (ev.inflictor) inf = ev.inflictor.GetClassName();
		if (inf == "SSQ_Disc") return MK_DISC;
		if (inf == "UBQS_Thrown") return MK_THROWN;
		if (dt == 'Fatality') return MK_FINISH;
		if (dt == 'Saber') return inf == "UBQS_Bolt" || inf == "UBQS_RemoteBolt" ? MK_NONE : MK_SABER;
		bool byPawn = ev.inflictor == ev.killer;
		if (byPawn && ShieldInHand(ev.killer))
		{
			if (dt == 'Melee') return MK_BASH;
			if (dt == 'Saw') return MK_GRIND;
		}
		if (dt == 'Saw' || dt == 'Cut') return MK_BLADE;
		if (dt == 'Melee' || dt == 'Kick' || dt == 'HeadKick' || dt == 'Stomp' || dt == 'ExtremePunches') return MK_FIST;
		return MK_NONE;
	}

	static bool ShieldInHand(Actor who)
	{
		let p = who ? who.player : null;
		return p && p.OffhandWeapon && p.OffhandWeapon.GetClassName() == 'SSQ_ShieldSaw';
	}

	// Ask the ShieldSaw (if loaded) what it remembers. -1: nothing.
	static int AskShield(String request, Actor about)
	{
		let it = ServiceIterator.Find("SSQ_ScoreService");
		Service s;
		while (s = it.Next())
		{
			int v = s.GetInt(request, "", 0, 0, about);
			if (v >= 0) return v;
		}
		return -1;
	}

	// Gibbed: past the victim's gib threshold, the extreme death.
	static bool Gibbed(Actor v)
	{
		return v && v.health < v.GetGibHealth();
	}
}


// ---------------------------------------------------------------- the bonuses

// Fatality: Brutal Doom's execution landed the kill. Rare and deliberate.
class RS_Bonus_Fatality : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Fatality"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Kind(ev) == RS_Melee.MK_FINISH ? MULT : 0.0; }
}

// Cleaved: a melee kill that took the body apart (its extreme death): the disc's bisect, a
// hard axe or sword cut, a boot through a head.
class RS_Bonus_Cleaved : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Cleaved"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k == RS_Melee.MK_NONE || k == RS_Melee.MK_FINISH) return 0.0;
		return RS_Melee.Gibbed(ev.victim) ? MULT : 0.0;
	}
}

// Hurled: a thrown kill (the ShieldSaw, the saber). Each further kill by the SAME throw pays
// more -- the disc hunting its locks down one by one is the move this is for.
class RS_Bonus_Hurled : RS_ScoreBonus
{
	const MULT = 0.3;
	const PER  = 0.15;
	const MAXMULT = 0.75;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Hurled"; }

	private int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		return (tr && ev.inflictor && tr.hurlBy == ev.inflictor) ? tr.hurlKills : 0;
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k != RS_Melee.MK_DISC && k != RS_Melee.MK_THROWN) return 0.0;
		return min(MAXMULT, MULT + PER * Earlier(ev));
	}

	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) return;
		if (tr.hurlBy != ev.inflictor) { tr.hurlBy = ev.inflictor; tr.hurlKills = 0; }
		tr.hurlKills++;
	}
}

// Shield Work: killed by the shield itself in the hand -- the bash or the revved grind.
class RS_Bonus_ShieldWork : RS_ScoreBonus
{
	const BASH  = 0.3;
	const GRIND = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Shield Work"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k == RS_Melee.MK_BASH) return BASH;
		if (k == RS_Melee.MK_GRIND) return GRIND;
		return 0.0;
	}
}

// Riposte: you blocked this monster's attack with the shield, then killed it within 3 s.
class RS_Bonus_Riposte : RS_ScoreBonus
{
	const MULT   = 0.4;
	const WINDOW = 105;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Riposte"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim) return 0.0;
		int since = RS_Melee.AskShield("blocked", ev.victim);
		return (since >= 0 && since <= WINDOW) ? MULT : 0.0;
	}
}

// Return to Sender: killed by a shot that was sent back -- turned by the shield or the saber,
// or a bullet either of them returned.
class RS_Bonus_ReturnToSender : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Return to Sender"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) return 0.0;
		let inf = ev.inflictor;
		String n = "";
		if (inf) n = inf.GetClassName();
		if (n == "UBQS_Bolt" || n == "UBQS_RemoteBolt") return MULT;          // the saber returned it
		if (inf && inf.bMissile && RS_ScoreShots.BornOfMonster(inf)) return MULT; // a monster's shot, now ours
		if (RS_Melee.AskShield("returned", inf) >= 0) return MULT;
		if (RS_Melee.AskShield("returned", ev.victim) >= 0) return MULT;      // a returned bullet
		return 0.0;
	}
}

// Combo: kills by different melee moves close together -- a jab, then a saber cut, then the
// saw thrown. Each kind beyond the first inside 4 s adds a step.
class RS_Bonus_Combo : RS_ScoreBonus
{
	const PER     = 0.1;
	const MAXMULT = 0.4;
	const WINDOW  = 140;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Combo"; }

	// distinct kinds in the window, counting this kill's
	private int Distinct(RS_ScoreEvent ev, int kind)
	{
		let tr = ev.tracker;
		if (!tr) return 0;
		int seen = 1 << kind;
		int n = 1;
		for (int k = 0; k < tr.comboKind.Size(); k++)
		{
			if (level.maptime - tr.comboTic[k] > WINDOW) continue;
			int bit = 1 << tr.comboKind[k];
			if (seen & bit) continue;
			seen |= bit;
			n++;
		}
		return n;
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		int kind = RS_Melee.Kind(ev);
		if (kind == RS_Melee.MK_NONE) return 0.0;
		return min(MAXMULT, PER * (Distinct(ev, kind) - 1));
	}

	override void Commit(RS_ScoreEvent ev) {}
}

// Combo's memory is written for EVERY melee kill, not only the ones Combo paid on, so it is
// kept by the handler's own pass (RS_ScoreHandler calls Note after a kill is scored).
class RS_MeleeMemory play
{
	static void Note(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) return;
		int kind = RS_Melee.Kind(ev);
		if (kind == RS_Melee.MK_NONE) return;
		for (int k = tr.comboKind.Size() - 1; k >= 0; k--)
			if (level.maptime - tr.comboTic[k] > RS_Bonus_Combo.WINDOW) { tr.comboKind.Delete(k); tr.comboTic.Delete(k); }
		if (tr.comboKind.Size() >= 16) { tr.comboKind.Delete(0); tr.comboTic.Delete(0); }
		tr.comboKind.Push(kind);
		tr.comboTic.Push(level.maptime);
	}
}


// ============================================================================
// RS_ScoreShots -- which shots a MONSTER fired, so a shot turned back (its target now a
// player, by whatever turned it) can be told from one the player fired. Kept for the level,
// trimmed as shots die; play scope, the same on every machine.
// ============================================================================
class RS_ScoreShots : EventHandler
{
	Array<Actor> shots;

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bMissile) return;
		let src = a.target;
		if (!src || src.player || !src.bIsMonster) return;
		if (shots.Size() >= 256) Trim();
		shots.Push(a);
	}

	override void WorldTick()
	{
		if ((level.maptime % 35) == 0) Trim();
	}

	private void Trim()
	{
		for (int k = shots.Size() - 1; k >= 0; k--) if (!shots[k]) shots.Delete(k);
		while (shots.Size() >= 256) shots.Delete(0);
	}

	static bool BornOfMonster(Actor shot)
	{
		let h = RS_ScoreShots(EventHandler.Find("RS_ScoreShots"));
		if (!h || !shot) return false;
		for (int k = 0; k < h.shots.Size(); k++) if (h.shots[k] == shot) return true;
		return false;
	}
}
