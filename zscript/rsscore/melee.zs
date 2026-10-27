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
//                       bash and grind) -- compared by class NAME, so absent mods cost nothing;
//                       and compared with ~== (a Name keeps the spelling it was FIRST made with:
//                       given by a lower-case string, UBQS_Force reported itself "ubqs_force" on
//                       the rig, and a plain == never matched)
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
		// the second round (10-27): the Force, the throw's way home, the perfect block, the hard swing
		into.Push("RS_Bonus_PerfectRiposte");
		into.Push("RS_Bonus_PoeticJustice");
		into.Push("RS_Bonus_Boomerang");
		into.Push("RS_Bonus_GroundDown");
		into.Push("RS_Bonus_HeavySwing");
		into.Push("RS_Bonus_Choked");
		into.Push("RS_Bonus_Slammed");
		into.Push("RS_Bonus_Juggle");
		into.Push("RS_Bonus_Boot");
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
		MK_FIST,       // fists (and the VR pistol whip, which lands BD's punch)
		MK_FINISH,     // a Brutal Doom fatality
		MK_FORCE,      // the saber's Force: push, grip choke, a flung body's slam (inflictor UBQS_Force)
		MK_BOOT,       // Brutal Doom's boots: Kick, HeadKick, Stomp (and the VR butt strike's kick)
	}

	static int Kind(RS_ScoreEvent ev)
	{
		if (!ev.killer) return MK_NONE;
		Name dt = ev.damageType;
		String inf = "";
		if (ev.inflictor) inf = ev.inflictor.GetClassName();
		if (inf ~== "SSQ_Disc") return MK_DISC;
		if (inf ~== "UBQS_Thrown") return MK_THROWN;
		// the Force: its push lands as 'Saber' and its choke and slam as 'Force', all from the
		// UBQS_Force item (QuestSaber zscript.txt, Push / GripTick / SlamTick) -- so the item, not
		// the type, says it was the Force and not a cut
		if (inf ~== "UBQS_Force") return MK_FORCE;
		if (dt == 'Fatality') return MK_FINISH;
		if (dt == 'Saber') return inf ~== "UBQS_Bolt" || inf ~== "UBQS_RemoteBolt" ? MK_NONE : MK_SABER;
		// A thing thrown with Distance Grab strikes as 'Melee' (BD's death reactions want that), but
		// it is no punch: the physical family pays for it (Thrown), so melee leaves it alone.
		if (dt == 'Melee' && ev.inflictor && ev.inflictor != ev.killer && RS_Physical.AskGrab("throw.by", ev.inflictor) >= 0) return MK_NONE;
		bool byPawn = ev.inflictor == ev.killer;
		if (byPawn && ShieldInHand(ev.killer))
		{
			if (dt == 'Melee') return MK_BASH;
			if (dt == 'Saw') return MK_GRIND;
		}
		if (dt == 'Saw' || dt == 'Cut') return MK_BLADE;
		if (dt == 'Kick' || dt == 'HeadKick' || dt == 'Stomp') return MK_BOOT;
		if (dt == 'Melee' || dt == 'ExtremePunches') return MK_FIST;
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

	// Ask every service that may know (the ShieldSaw's, and the saber's once it answers the same
	// request names) -- the first answer that is not -1 wins. -1: nobody knows.
	static int AskAny(String request, Actor about)
	{
		int v = AskShield(request, about);
		if (v >= 0) return v;
		let it = ServiceIterator.Find("UBQS_SaberService");
		Service s;
		while (s = it.Next())
		{
			v = s.GetInt(request, "", 0, 0, about);
			if (v >= 0) return v;
		}
		return -1;
	}

	// The ShieldSaw's object answers (who fired a shot it turned). null: nothing.
	static Actor AskShieldActor(String request, Actor about)
	{
		let it = ServiceIterator.Find("SSQ_ScoreService");
		Service s;
		while (s = it.Next())
		{
			let a = Actor(s.GetObject(request, "", 0, 0, about));
			if (a) return a;
		}
		return null;
	}

	// WHICH WAY A THROWN THING WAS FLYING when it killed: LEG_OUT away from the thrower (or stuck
	// grinding), LEG_BACK on its way home. Asked first ("thrown.leg": the ShieldSaw answers it for
	// its disc from the disc's own phase; the saber may answer it for UBQS_Thrown). If nobody
	// answers, MEASURED: the thrown thing's motion this tic (pos - Prev; the engine sets Prev = Pos
	// for every actor before the tic's thinkers run, p_tick.cpp) -- or, if it has not moved yet
	// this tic, its motion over the last tic (RS_ScoreShots samples it) -- against the line to
	// the thrower. Heading home within 60 degrees is BACK.
	enum ELeg { LEG_NONE = -1, LEG_OUT = 0, LEG_BACK = 1 }
	static int ThrownLeg(Actor thrown, Actor thrower)
	{
		if (!thrown || !thrower) return LEG_NONE;
		int asked = AskAny("thrown.leg", thrown);
		if (asked == LEG_OUT || asked == LEG_BACK) return asked;
		Vector3 step = thrown.pos - thrown.Prev;
		if (step.Length() < 0.5) step = RS_ScoreShots.LastStep(thrown);
		Vector3 home = thrower.pos + (0, 0, thrower.height * 0.5) - thrown.pos;
		double sl = step.Length(), hl = home.Length();
		if (sl < 0.5 || hl < 1) return LEG_NONE;
		return ((step / sl) dot (home / hl)) >= 0.5 ? LEG_BACK : LEG_OUT;
	}

	// IN THE AIR, AND YOU PUT IT THERE: off the floor (AIR_GAP clear of it, not standing on another
	// actor), not a flyer by nature (its class default has neither NOGRAVITY nor FLOAT -- a body the
	// Force grip holds up has NOGRAVITY only while it is held, so it counts), and touched by your
	// Force, a kick or a bash it lived through in the last LAUNCH_TICS (RS_ScoreShots.Launched).
	// MEASURED on the rig (mlprobe mode 9): the saber's real Force push lifts a Brutal Doom imp at
	// 120 units only 8 units, for about four tics -- so the gap is small, and the touch is what
	// says the air was yours rather than a stair.
	const AIR_GAP = 2.0;
	const LAUNCH_TICS = 70;
	static bool Airborne(Actor v)
	{
		if (!v || v.bOnMobj) return false;
		let def = GetDefaultByType(v.GetClass());
		if (def.bNoGravity || def.bFloat) return false;
		return v.pos.z - v.floorz >= AIR_GAP;
	}

	// THE BIG MOMENTS, in one place, for the SlowMo mod later (not wired to anything yet): a bonus
	// in this list, firing at or above the multiplier given, is a moment worth slowing down for.
	static bool BigMoment(RS_ScoreBonus b, double mult)
	{
		if (!b || mult <= 0) return false;
		String n = b.GetClassName();
		if (n ~== "RS_Bonus_Fatality" || n ~== "RS_Bonus_PerfectRiposte" || n ~== "RS_Bonus_PoeticJustice"
			|| n ~== "RS_Bonus_Boomerang" || n ~== "RS_Bonus_Slammed") return true;
		if (n ~== "RS_Bonus_HeavySwing") return mult >= RS_Bonus_HeavySwing.FULL;
		return false;
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
		int since = RS_Melee.AskAny("blocked", ev.victim);
		return (since >= 0 && since <= WINDOW) ? MULT : 0.0;
	}
}

// Perfect Riposte: the same, after a PERFECT block -- the plate met the attack moving into it
// (the ShieldSaw's own test, ssq_perfect_speed). Pays more, and replaces Riposte.
class RS_Bonus_PerfectRiposte : RS_ScoreBonus
{
	const MULT = 0.7;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Perfect Riposte"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim) return 0.0;
		int since = RS_Melee.AskAny("perfect", ev.victim);
		return (since >= 0 && since <= RS_Bonus_Riposte.WINDOW) ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Riposte"; }
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
		if (n ~== "UBQS_Bolt" || n ~== "UBQS_RemoteBolt") return MULT;          // the saber returned it
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

// Poetic Justice: a shot sent back killed the very monster that fired it. Stacks on Return to
// Sender. Who fired it: a missile the saber or the Force turned is the same actor, and
// RS_ScoreShots noted its shooter when it was born; one the shield turned is a fresh actor and the
// shield remembers ("returned.from"), as it does the shooter of a bullet it sent back. A saber
// return bolt (UBQS_Bolt) counts once the saber sets the bolt's tracer to the shooter.
class RS_Bonus_PoeticJustice : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Poetic Justice"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let v = ev.victim, inf = ev.inflictor;
		if (!ev.killer || !v) return 0.0;
		if (inf && inf != ev.killer)
		{
			String cn = inf.GetClassName();
			if (cn ~== "UBQS_Bolt") return inf.tracer == v ? MULT : 0.0;
			if (inf.bMissile && RS_ScoreShots.BornOf(inf) == v) return MULT;
			if (RS_Melee.AskShieldActor("returned.from", inf) == v) return MULT;
		}
		if (RS_Melee.AskShieldActor("returned.from", v) == v) return MULT;   // a bullet the shield sent back
		return 0.0;
	}
}

// Boomerang: a throw (the ShieldSaw or the saber) that killed on its way out kills again on its
// way home. Each kill on the way back pays.
class RS_Bonus_Boomerang : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Boomerang"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k != RS_Melee.MK_DISC && k != RS_Melee.MK_THROWN) return 0.0;
		if (RS_Melee.ThrownLeg(ev.inflictor, ev.killer) != RS_Melee.LEG_BACK) return 0.0;
		return RS_ScoreShots.ThrowKilledOut(ev.inflictor) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k != RS_Melee.MK_DISC && k != RS_Melee.MK_THROWN) return;
		int leg = RS_Melee.ThrownLeg(ev.inflictor, ev.killer);
		if (leg == RS_Melee.LEG_OUT) RS_ScoreShots.NoteThrowOut(ev.inflictor);
	}
}

// Ground Down: the thrown disc stuck in a monster too tough to cut through, and ground it to death
// where it stood (the ShieldSaw's mid tier; "disc.grinding").
class RS_Bonus_GroundDown : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Ground Down"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_DISC) return 0.0;
		return RS_Melee.AskShield("disc.grinding", ev.inflictor) == 0 ? MULT : 0.0;
	}
}

// Heavy Swing: BD22Q's VR melee lands Brutal Doom's own attack at the contact point and STACKS
// them by how hard the arm swung (zscript/rsvr/melee.zs Strike: the axe one AxeAttack, a second at
// power 1.6, a third at 2.4; the pistol whip a second punch at 2.0). Paid when the killing blow
// was the second or third of one swing's stack -- the swing's extra weight is what killed it
// (RS_ScoreShots counts the blows as they land).
class RS_Bonus_HeavySwing : RS_ScoreBonus
{
	const HALF = 0.15;   // two stacked
	const FULL = 0.3;    // three
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Heavy Swing"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.inflictor) return 0.0;
		int n = RS_ScoreShots.Stacked(ev.victim);
		if (n >= 3) return FULL;
		if (n == 2) return HALF;
		return 0.0;
	}
}

// Choked: the Force grip choked it to death (its 'Force' damage carries DMG_NO_PAIN; the slam's
// does not -- QuestSaber GripTick / SlamTick).
class RS_Bonus_Choked : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Choked"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_FORCE || ev.damageType != 'Force') return 0.0;
		int fl = RS_ScoreShots.KillFlags(ev.victim);
		return (fl >= 0 && (fl & DMG_NO_PAIN)) ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Juggle"; }
}

// Slammed: a body flung out of the Force grip died hitting something (the saber's slam: it stops
// dead and takes damage by how fast it was going).
class RS_Bonus_Slammed : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Slammed"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_FORCE || ev.damageType != 'Force') return 0.0;
		int fl = RS_ScoreShots.KillFlags(ev.victim);
		return (fl >= 0 && !(fl & DMG_NO_PAIN)) ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Juggle"; }
}

// Juggle: a melee or Force kill of something in the air that cannot fly, which your Force, a kick,
// a punch or a bash put there -- caught at the top of a push, cut while it hangs in the grip, hit as it flies
// from a fling. The choke and the slam have their own rows and replace it. (A PULL does no damage,
// so it leaves no touch to read, and on the rig it did not lift an imp at all: a pulled monster
// cut on arrival needs the saber to say it pulled it.)
class RS_Bonus_Juggle : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Juggle"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k == RS_Melee.MK_NONE || k == RS_Melee.MK_FINISH) return 0.0;
		if (!RS_Melee.Airborne(ev.victim)) return 0.0;
		int since = RS_ScoreShots.Launched(ev.victim, ev.killer);
		return (since >= 0 && since <= RS_Melee.LAUNCH_TICS) ? MULT : 0.0;
	}
}

// Boot: Brutal Doom's boots finished it -- a kick, a head kick, a stomp.
class RS_Bonus_Boot : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Boot"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Kind(ev) == RS_Melee.MK_BOOT ? MULT : 0.0; }
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
// RS_ScoreShots -- the melee family's eyes on the level (one EventHandler, already registered in
// MAPINFO): play scope, fed only by the playsim, the same on every machine.
//   * which shots a MONSTER fired, and which monster, so a shot turned back (its target now a
//     player, by whatever turned it) can be told from one the player fired, and its own shooter
//     known (Return to Sender, Poetic Justice);
//   * the thrown things in flight (the ShieldSaw's disc, the saber), their last tic of motion,
//     and which throws have already killed on the way out (Boomerang);
//   * which blow of one VR swing's stack killed (Heavy Swing);
//   * which bodies a player's Force, kick or bash touched and they lived (Juggle);
//   * the damage flags of the blow that killed (Choked / Slammed): WorldThingDamaged runs just
//     before the victim's Die (p_interaction.cpp), with the health already taken off.
// ============================================================================
class RS_ScoreShots : EventHandler
{
	Array<Actor> shots;
	Array<Actor> shotFrom;     // the monster that fired each

	Array<Actor> thrown;       // discs and thrown sabers in flight
	Array<double> thrX, thrY, thrZ, stepX, stepY, stepZ;   // Array<Vector3> is not allowed
	Array<Actor> outKillers;   // throws that have killed on their way out

	Actor swVictim, swSource;  // the blows of one swing's stack landing on one body in one tic
	int swTic, swCount;

	Array<Actor> lnV, lnBy;    // bodies a player's Force, kick or bash touched, and lived through
	Array<int> lnTic;

	Actor killVictim;          // the last blow that brought something to 0 health
	int kFlags, killTic, killStack;

	static bool IsThrown(String n) { return n ~== "SSQ_Disc" || n ~== "UBQS_Thrown"; }
	static bool IsSwingAttack(String n)
	{
		return n ~== "AxeAttack" || n ~== "AxeAttackNoDecal" || n ~== "MeleeStrikeNormal" || n ~== "MeleeStrike1Berserked";
	}

	// WorldThingSpawned runs from PostBeginPlay, on the actor's first tic -- after the spawner
	// has set its target, before it has moved.
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		String n = a.GetClassName();
		if (IsThrown(n))
		{
			if (thrown.Size() >= 16) DropThrown(0);
			thrown.Push(a);
			thrX.Push(a.pos.x); thrY.Push(a.pos.y); thrZ.Push(a.pos.z);
			stepX.Push(0); stepY.Push(0); stepZ.Push(0);
			return;
		}
		if (!a.bMissile) return;
		let src = a.target;
		if (!src) return;
		if (src.player || !src.bIsMonster) return;
		if (shots.Size() >= 256) Trim();
		shots.Push(a);
		shotFrom.Push(src);
	}

	// HOW A STACK IS COUNTED. BD22Q's Launch spawns each attack INSIDE the body and calls
	// CheckMissileSpawn, so each one lands at once -- before the next is even spawned, and before
	// WorldThingSpawned has heard of it. So the blows are counted as they LAND: same body, same
	// player, same tic, one after another. A kill by blow 2 proves the swing reached power 1.6 (the
	// second is only launched then), blow 3 power 2.4. A hard swing that kills with its FIRST blow
	// cannot be told from a soft one, and is not paid: the weight has to be what killed it.
	override void WorldThingDamaged(WorldEvent e)
	{
		let v = e.Thing;
		if (!v) return;
		let inf = e.Inflictor, src = e.DamageSource;
		if (inf && src && src.player && IsSwingAttack(inf.GetClassName()))
		{
			if (swVictim == v && swSource == src && swTic == level.maptime) swCount++;
			else { swVictim = v; swSource = src; swTic = level.maptime; swCount = 1; }
		}
		if (v.health > 0)
		{
			String icn = inf ? inf.GetClassName() : 'None';
			if (src && src.player && inf && (icn ~== "UBQS_Force"
				|| e.DamageType == 'Kick' || e.DamageType == 'HeadKick' || e.DamageType == 'Melee'))
				NoteLaunch(v, src);
			return;
		}
		killVictim = v;
		kFlags = e.DamageFlags;
		killTic = level.maptime;
		killStack = (swVictim == v && swTic == level.maptime) ? swCount : 0;
	}

	override void WorldTick()
	{
		if ((level.maptime % 35) == 0) Trim();
		// each thrown thing's motion over the last tic (sampled before the thinkers run)
		for (int k = thrown.Size() - 1; k >= 0; k--)
		{
			let a = thrown[k];
			if (!a) { DropThrown(k); continue; }
			Vector3 d = a.pos - (thrX[k], thrY[k], thrZ[k]);
			if (d.Length() >= 0.5) { stepX[k] = d.x; stepY[k] = d.y; stepZ[k] = d.z; }
			thrX[k] = a.pos.x; thrY[k] = a.pos.y; thrZ[k] = a.pos.z;
		}
	}

	private void NoteLaunch(Actor v, Actor by)
	{
		for (int k = lnV.Size() - 1; k >= 0; k--)
			if (!lnV[k] || lnV[k] == v || level.maptime - lnTic[k] > RS_Melee.LAUNCH_TICS) { lnV.Delete(k); lnBy.Delete(k); lnTic.Delete(k); }
		if (lnV.Size() >= 32) { lnV.Delete(0); lnBy.Delete(0); lnTic.Delete(0); }
		lnV.Push(v); lnBy.Push(by); lnTic.Push(level.maptime);
	}

	private void DropThrown(int k)
	{
		thrown.Delete(k); thrX.Delete(k); thrY.Delete(k); thrZ.Delete(k);
		stepX.Delete(k); stepY.Delete(k); stepZ.Delete(k);
	}

	private void Trim()
	{
		for (int k = shots.Size() - 1; k >= 0; k--) if (!shots[k]) { shots.Delete(k); shotFrom.Delete(k); }
		while (shots.Size() >= 256) { shots.Delete(0); shotFrom.Delete(0); }
		for (int k = outKillers.Size() - 1; k >= 0; k--) if (!outKillers[k]) outKillers.Delete(k);
	}

	static RS_ScoreShots Get() { return RS_ScoreShots(EventHandler.Find("RS_ScoreShots")); }

	static bool BornOfMonster(Actor shot)
	{
		let h = Get();
		if (!h || !shot) return false;
		for (int k = 0; k < h.shots.Size(); k++) if (h.shots[k] == shot) return true;
		return false;
	}

	// the monster that fired this shot, or null
	static Actor BornOf(Actor shot)
	{
		let h = Get();
		if (!h || !shot) return null;
		for (int k = 0; k < h.shots.Size(); k++) if (h.shots[k] == shot) return h.shotFrom[k];
		return null;
	}

	static Vector3 LastStep(Actor a)
	{
		let h = Get();
		if (h) for (int k = 0; k < h.thrown.Size(); k++)
			if (h.thrown[k] == a) return (h.stepX[k], h.stepY[k], h.stepZ[k]);
		return (0, 0, 0);
	}

	static bool ThrowKilledOut(Actor a)
	{
		let h = Get();
		if (!h || !a) return false;
		for (int k = 0; k < h.outKillers.Size(); k++) if (h.outKillers[k] == a) return true;
		return false;
	}

	static void NoteThrowOut(Actor a)
	{
		let h = Get();
		if (!h || !a || ThrowKilledOut(a)) return;
		if (h.outKillers.Size() >= 16) h.outKillers.Delete(0);
		h.outKillers.Push(a);
	}

	// which blow of one swing's stack killed v this tic (0: not a VR swing's attack)
	static int Stacked(Actor v)
	{
		let h = Get();
		if (!h || !v || h.killVictim != v || h.killTic != level.maptime) return 0;
		return h.killStack;
	}

	// tics since this player's Force, kick or bash last touched v (and v lived), or -1
	static int Launched(Actor v, Actor by)
	{
		let h = Get();
		if (!h || !v) return -1;
		for (int k = 0; k < h.lnV.Size(); k++) if (h.lnV[k] == v && h.lnBy[k] == by) return level.maptime - h.lnTic[k];
		return -1;
	}

	// the damage flags of the blow that killed v this tic, or -1
	static int KillFlags(Actor v)
	{
		let h = Get();
		if (!h || !v || h.killVictim != v || h.killTic != level.maptime) return -1;
		return h.kFlags;
	}
}
