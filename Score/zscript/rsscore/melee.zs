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
		// the suite round (10-27): the saber's pull and second blade, sent-back chains, the push into
		// harm, the Force jump's landing, the disc's sweep and bank, the shield held up, the gloves
		into.Push("RS_Bonus_PulledIn");
		into.Push("RS_Bonus_TwinBlades");
		into.Push("RS_Bonus_Rally");
		into.Push("RS_Bonus_RingOut");
		into.Push("RS_Bonus_GroundPound");
		into.Push("RS_Bonus_CleanSweep");
		into.Push("RS_Bonus_BankShot");
		into.Push("RS_Bonus_ShieldWall");
		into.Push("RS_Bonus_Counter");
		into.Push("RS_Bonus_Knockdown");
		into.Push("RS_Bonus_Flurry");
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
		MK_HOOK,       // RSQ_Grapple's throw: a hooked body's landing or strike, or what it struck (hook.zs)
		MK_WHIP,       // RSQ_Grapple's whip crack
	}

	static int Kind(RS_ScoreEvent ev)
	{
		if (ev.meleeKind < 0) ev.meleeKind = KindOf(ev);
		return ev.meleeKind;
	}

	private static int KindOf(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return MK_NONE;	// a Ring Out was struck by the level or a monster
		Name dt = ev.damageType;
		String inf = "";
		if (ev.inflictor) inf = ev.inflictor.GetClassName();
		if (inf ~== "SSQ_Disc") return MK_DISC;
		if (inf ~== "UBQS_Thrown") return MK_THROWN;
		// the Force: its push lands as 'Saber' and its choke and slam as 'Force', all from the
		// UBQS_Force item (QuestSaber zscript.txt, Push / GripTick / SlamTick) -- so the item, not
		// the type, says it was the Force and not a cut
		if (inf ~== "UBQS_Force") return MK_FORCE;
		// RSQ_Grapple's own blows land as 'Melee' -- a thrown body's landing or strike with no inflictor,
		// the whip's crack with the pawn as inflictor -- and are no punch: its service noted each one
		// before it landed (hook.zs)
		if (dt == 'Melee' && !ev.inflictor && (RS_Grapple.Ask("landing", ev.victim) == 0 || RS_Grapple.Ask("struck", ev.victim) == 0)) return MK_HOOK;
		if (dt == 'Melee' && ev.inflictor == ev.killer && RS_Grapple.Ask("whipped", ev.victim) == 0) return MK_WHIP;
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
		return RS_Svc.Int(RS_Svc.SHIELD, request, 0, about);
	}

	// Ask every service that may know (the ShieldSaw's, and the saber's once it answers the same
	// request names) -- the first answer that is not -1 wins. -1: nobody knows.
	static int AskAny(String request, Actor about)
	{
		int v = AskShield(request, about);
		if (v >= 0) return v;
		return RS_Svc.Int(RS_Svc.SABER, request, 0, about);
	}

	// The ShieldSaw's object answers (who fired a shot it turned). null: nothing.
	static Actor AskShieldActor(String request, Actor about)
	{
		return RS_Svc.Act(RS_Svc.SHIELD, request, about);
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

	// THE BIG MOMENTS, in one place: a bonus in this list, firing at or above the multiplier given,
	// is a moment worth slowing down for (handler.zs BigMomentPulse sends RSQ_SlowMo a short pulse).
	// The original thirteen and the physical bonuses answer for themselves (BigMoment, bonus.zs).
	static bool BigMoment(RS_ScoreBonus b, double mult)
	{
		if (!b || mult <= 0) return false;
		String n = b.GetClassName();
		if (n ~== "RS_Bonus_Fatality" || n ~== "RS_Bonus_PerfectRiposte" || n ~== "RS_Bonus_PoeticJustice"
			|| n ~== "RS_Bonus_Boomerang" || n ~== "RS_Bonus_Slammed" || n ~== "RS_Bonus_RingOut"
			|| n ~== "RS_Bonus_CleanSweep" || n ~== "RS_Bonus_BankShot") return true;
		if (n ~== "RS_Bonus_HeavySwing") return mult >= RS_Bonus_HeavySwing.FULL;
		if (n ~== "RS_Bonus_Rally") return mult >= RS_Bonus_Rally.PER * 3 - 0.001;     // the fourth in a row
		if (n ~== "RS_Bonus_Flurry") return mult >= RS_Bonus_Flurry.MAXMULT - 0.001;   // the fifth punch
		return false;
	}

	// A SHOT SENT BACK killed it: turned by the shield or the saber, a bolt the saber returned, or a
	// bullet either of them returned. (Return to Sender's test; Rally and the physical family read it.)
	static bool Returned(RS_ScoreEvent ev)
	{
		if (ev.returned < 0) ev.returned = ReturnedOf(ev) ? 1 : 0;
		return ev.returned == 1;
	}

	private static bool ReturnedOf(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return false;
		let inf = ev.inflictor;
		String n = "";
		if (inf) n = inf.GetClassName();
		if (n ~== "UBQS_Bolt" || n ~== "UBQS_RemoteBolt") return true;          // the saber returned it
		if (inf && inf.bMissile && RS_ScoreShots.BornOfMonster(inf)) return true; // a monster's shot, now ours
		if (inf && AskShield("returned", inf) >= 0) return true;
		if (AskShield("returned", ev.victim) >= 0) return true;                // a returned bullet
		return false;
	}

	// The saber's answer for one hand of this pawn: 1 lit (or thrown), 0 doused, -1 none.
	static int SaberLit(Actor who, int hand)
	{
		return RS_Svc.Int(RS_Svc.SABER, "saber.lit", hand, who);
	}

	// One of the boxing gloves (the Gun Bonsai VR patch's RSQ_Glove / RSQ_GloveOff, SuperPunchOut's
	// SPO_Glove) dealt the blow: a glove is its own inflictor (RSQ_GloveHandler.Deliver).
	static bool IsGlove(Actor inf)
	{
		if (!inf) return false;
		String n = inf.GetClassName();
		return n.Left(9) ~== "RSQ_Glove" || n.Left(9) ~== "SPO_Glove";
	}

	// The victim was in its own attack (its Missile or Melee sequence) when it died -- the state
	// before Die changes it (WorldThingDied runs before the death state is set, p_interaction.cpp).
	// The Gun Bonsai VR patch's RSQM.InAttack, the same test.
	static bool InAttack(Actor v)
	{
		if (!v || !v.CurState) return false;
		State s = v.FindState("Missile");
		if (s && v.InStateSequence(v.CurState, s)) return true;
		s = v.FindState("Melee");
		return s && v.InStateSequence(v.CurState, s);
	}

	static bool InPain(Actor v)
	{
		if (!v || !v.CurState) return false;
		State s = v.FindState("Pain");
		return s && v.InStateSequence(v.CurState, s);
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
		if (k == RS_Melee.MK_NONE || k == RS_Melee.MK_FINISH || k == RS_Melee.MK_HOOK) return 0.0;
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
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Returned(ev) ? MULT : 0.0; }
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
		if (RS_Combo.Mixed(ev)) return 0.0;   // this kill's own chain mixed its tools (combo.zs)
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
// from a fling. The choke and the slam have their own rows and replace it. (A PULL does no damage
// and leaves no touch; a pulled monster cut on arrival is Pulled In, from the saber's "pulled".)
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
	// the body in the air is one fact: Skeet (physical.zs) pays it for any kill, Juggle for one you
	// launched -- not both
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Skeet"; }
}

// Boot: Brutal Doom's boots finished it -- a kick, a head kick, a stomp.
class RS_Bonus_Boot : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Boot"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Kind(ev) == RS_Melee.MK_BOOT ? MULT : 0.0; }
}


// ---------------------------------------------------------------- the suite round (10-27)

// Pulled In: the saber's Force pull yanked this monster to you, and a melee blow killed it within two
// seconds of the pull (UBQS_SaberService "pulled": the saber's own memory, kept 2 s).
class RS_Bonus_PulledIn : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Pulled In"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k == RS_Melee.MK_NONE || k == RS_Melee.MK_FINISH) return 0.0;
		int since = RS_Melee.AskAny("pulled", ev.victim);
		return (since >= 0 && since <= 70) ? MULT : 0.0;
	}
}

// Twin Blades: a saber kill (a cut or a throw) while a lit saber is in each hand (the saber's own
// "saber.lit", per hand; a thrown saber counts as out).
class RS_Bonus_TwinBlades : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Twin Blades"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k != RS_Melee.MK_SABER && k != RS_Melee.MK_THROWN) return 0.0;
		return (RS_Melee.SaberLit(ev.killer, 0) == 1 && RS_Melee.SaberLit(ev.killer, 1) == 1) ? MULT : 0.0;
	}
}

// Rally: shots sent back (Return to Sender) killing one after another, each within 3 s of the last --
// a deflect chain. The second pays 0.2, the third 0.4, then 0.6. On top of Return to Sender.
class RS_Bonus_Rally : RS_ScoreBonus
{
	const PER = 0.2;
	const WINDOW = 105;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Rally"; }
	private int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		return (tr && tr.rallyCount > 0 && level.maptime - tr.rallyTic <= WINDOW) ? tr.rallyCount : 0;
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Melee.Returned(ev)) return 0.0;
		return min(PER * 3, PER * Earlier(ev));
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || !RS_Melee.Returned(ev)) return;
		tr.rallyCount = Earlier(ev) + 1;
		tr.rallyTic = level.maptime;
	}
}

// Ring Out: something other than you killed it -- a crusher, a pit, another monster's attack -- inside
// two seconds of your Force, a kick, a punch or a bash sending it there (RS_ScoreShots.LaunchedBy; the
// handler gives you the kill, which otherwise paid nobody or every player).
class RS_Bonus_RingOut : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Ring Out"; }
	override double Evaluate(RS_ScoreEvent ev) { return ev.ringOut ? MULT : 0.0; }
}

// Ground Pound: the Force jump's landing (QuestSaber LandSlam, a Gun Bonsai Force Jump level 2+)
// killed it. Its 'Force' blow has no NO_PAIN flag, like the slam's, so it is told from a flung body by
// what LandSlam does: it strikes round a player standing on the floor, within its reach (96 + 32 a
// level past 2, here up to 288 units with the body's radius) and 64 units of height, and throws the
// body UP before it strikes (vel.z += half its push, at least 1). A flung body has stopped dead.
// Replaces Slammed for that kill.
class RS_Bonus_GroundPound : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Ground Pound"; }
	static bool IsLanding(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_FORCE || ev.damageType != 'Force') return false;
		int fl = RS_ScoreShots.KillFlags(ev.victim);
		if (fl < 0 || (fl & DMG_NO_PAIN)) return false;
		let k = ev.killer, v = ev.victim;
		if (k.pos.z > k.floorz + 1.0) return false;
		if (abs(v.pos.z - k.pos.z) > 64.0 + 16.0) return false;
		if (k.Distance2D(v) > 288.0 + v.radius) return false;
		return v.bDontThrust || v.vel.z >= 0.9;
	}
	override double Evaluate(RS_ScoreEvent ev) { return IsLanding(ev) ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Slammed"; }
}

// Clean Sweep: the ShieldSaw thrown at two or more locks killed the last of them -- every lock it
// was sent to has been visited. Read from the disc's own lock rings (SSQ_LockMark, each pointing at
// its target; the disc removes a ring when it is done with that lock or the target dies), counted
// for this disc by RS_ScoreShots when they appear with it.
class RS_Bonus_CleanSweep : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Clean Sweep"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_DISC) return 0.0;
		return RS_ScoreShots.SweptClean(ev.inflictor, ev.victim) ? MULT : 0.0;
	}
}

// Bank Shot: the ShieldSaw came off a wall toward a new target (its Ricochet, a Gun Bonsai upgrade:
// the disc picks a fresh lock at the wall and rings it) and killed that target.
class RS_Bonus_BankShot : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Bank Shot"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_DISC) return 0.0;
		return RS_ScoreShots.BankedAt(ev.inflictor, ev.victim) ? MULT : 0.0;
	}
}

// Shield Wall: a kill while the ShieldSaw in your hand is holding something else off -- it blocked
// another monster's attack inside the last second. (The monster it blocked is Riposte's business.)
class RS_Bonus_ShieldWall : RS_ScoreBonus
{
	const MULT = 0.25;
	const WINDOW = 35;
	const REACH = 2048;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Shield Wall"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || ev.ringOut || !RS_Melee.ShieldInHand(k)) return 0.0;
		let it = BlockThingsIterator.Create(k, REACH);
		while (it.Next())
		{
			let m = it.thing;
			if (!m || m == ev.victim || !m.bIsMonster || m.player) continue;
			int since = RS_Melee.AskShield("blocked", m);
			if (since >= 0 && since <= WINDOW) return MULT;
		}
		return 0.0;
	}
}

// Counter: a punch killed it in the middle of its own attack -- in its Missile or Melee sequence, or
// half a second after it fired a shot (Brutal Doom's monsters jump out of "Missile" into their own
// attack states at once: an imp set to Missile on the rig was not in that sequence a tic later) --
// the gloves' counter, Brutal Doom's fists too.
class RS_Bonus_Counter : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Counter"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_FIST) return 0.0;
		return (RS_Melee.InAttack(ev.victim) || RS_ScoreShots.FiredWithin(ev.victim, 18)) ? MULT : 0.0;
	}
}

// Knockdown: a punch finished it while it was still reeling (in its Pain sequence) from an earlier blow.
class RS_Bonus_Knockdown : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Knockdown"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		return (RS_Melee.Kind(ev) == RS_Melee.MK_FIST && RS_Melee.InPain(ev.victim)) ? MULT : 0.0;
	}
}

// Flurry: the gloves' one-two -- a glove kill that ends a run of punches landing left, right, left,
// each within half a second of the last (the patch's own One-Two window, 17 tics). The third punch of
// the run pays 0.15, the fourth 0.3, the fifth and on 0.45.
class RS_Bonus_Flurry : RS_ScoreBonus
{
	const PER = 0.15;
	const MAXMULT = 0.45;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Flurry"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Melee.IsGlove(ev.inflictor) || ev.killerNum < 0) return 0.0;
		int n = RS_ScoreShots.GloveRun(ev.killerNum);
		return n >= 3 ? min(MAXMULT, PER * (n - 2)) : 0.0;
	}
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
	Array<int> shotTic;        // ...and when

	Array<Actor> thrown;       // discs and thrown sabers in flight
	Array<double> thrX, thrY, thrZ, stepX, stepY, stepZ;   // Array<Vector3> is not allowed
	Array<Actor> outKillers;   // throws that have killed on their way out

	Actor swVictim, swSource;  // the blows of one swing's stack landing on one body in one tic
	int swTic, swCount;

	Array<Actor> lnV, lnBy;    // bodies a player's Force, kick or bash touched, and lived through
	Array<int> lnTic;

	Actor killVictim;          // the last blow that brought something to 0 health
	Actor kSource;             // ...who dealt it (the engine's damage source; null: the level)
	int kFlags, killTic, killStack;

	// monsters that died lately, and the weapons that fell out of them (Hand-Me-Down)
	Array<Actor> deadV, drops;
	Array<int> deadTic;

	// the ShieldSaw's lock rings, by the disc they appeared with (Clean Sweep, Bank Shot)
	Array<Actor> lmDisc, lmMark, lmTarget;
	Array<int> lmLate;         // 1: rung after the throw (a Ricochet's new lock), 0: at the throw
	Array<int> thrTic;         // the tic each thrown thing appeared

	// the gloves' run of alternating punches, per player (Flurry)
	Actor glLast[MAXPLAYERS];
	int glTic[MAXPLAYERS], glRun[MAXPLAYERS];

	// THE CLASSES THIS LOOKS FOR, resolved once per map from their names (null when that mod is not
	// loaded). EVERY ACTOR THAT SPAWNS passes through WorldThingSpawned -- Brutal Doom spawns blood,
	// casings and smoke by the hundred -- so the test there is a pointer compare, not a string one.
	transient bool clsReady;
	transient class<Actor> cDisc, cThrown, cMark, cGlove, cSpoGlove, cSw1, cSw2, cSw3, cSw4;
	private void Classes()
	{
		if (clsReady) return;
		clsReady = true;
		String n;
		n = "SSQ_Disc";             cDisc = n;
		n = "UBQS_Thrown";          cThrown = n;
		n = "SSQ_LockMark";         cMark = n;
		n = "RSQ_Glove";            cGlove = n;
		n = "SPO_Glove";            cSpoGlove = n;
		n = "AxeAttack";            cSw1 = n;
		n = "AxeAttackNoDecal";     cSw2 = n;
		n = "MeleeStrikeNormal";    cSw3 = n;
		n = "MeleeStrike1Berserked"; cSw4 = n;
	}

	private bool IsSwing(Actor a)
	{
		if (!a) return false;
		class<Actor> c = a.GetClass();
		return c && (c == cSw1 || c == cSw2 || c == cSw3 || c == cSw4);
	}
	private bool IsGloveHit(Actor a)
	{
		return a && ((cGlove && a is cGlove) || (cSpoGlove && a is cSpoGlove));
	}

	// WorldThingSpawned runs from PostBeginPlay, on the actor's first tic -- after the spawner
	// has set its target, before it has moved.
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		Classes();
		class<Actor> c = a.GetClass();
		if ((cDisc && c == cDisc) || (cThrown && c == cThrown))
		{
			if (thrown.Size() >= 16) DropThrown(0);
			thrown.Push(a);
			thrX.Push(a.pos.x); thrY.Push(a.pos.y); thrZ.Push(a.pos.z);
			stepX.Push(0); stepY.Push(0); stepZ.Push(0);
			thrTic.Push(level.maptime);
			return;
		}
		if (cMark && c == cMark) { NoteMark(a); return; }
		if (deadV.Size() > 0 && a is "Weapon") { NoteDrop(a); return; }
		if (!a.bMissile) return;
		let src = a.target;
		if (!src) return;
		if (src.player || !src.bIsMonster) return;
		if (shots.Size() >= 256) Trim();
		shots.Push(a);
		shotFrom.Push(src);
		shotTic.Push(level.maptime);
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
		Classes();
		if (inf && src && src.player && IsGloveHit(inf)) NoteGlove(src.PlayerNumber(), inf);
		if (inf && src && src.player && IsSwing(inf))
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
		kSource = src;
		kFlags = e.DamageFlags;
		killTic = level.maptime;
		killStack = (swVictim == v && swTic == level.maptime) ? swCount : 0;
	}

	override void WorldTick()
	{
		if ((level.maptime % 35) == 0) Trim();
		// each ring's target, kept once the ring has one (the ring itself goes when the disc is done
		// with that lock)
		for (int k = 0; k < lmMark.Size(); k++) if (!lmTarget[k] && lmMark[k] && lmMark[k].tracer) lmTarget[k] = lmMark[k].tracer;
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
		if (k < thrTic.Size()) thrTic.Delete(k);
	}

	// A lock ring appeared. The disc that rang it is the ShieldSaw in flight: one that appeared this
	// very tic rang it at the throw (SSQ_Disc.FindLocks), an older one rang it at a wall (Ricochet).
	// The ring's target (tracer) is set just after it spawns, so it is read when asked, not now. A ring
	// with no disc in flight is the aim preview's (state.zs) and is not kept.
	private void NoteMark(Actor m)
	{
		Actor disc = null;
		int late = 0;
		for (int k = thrown.Size() - 1; k >= 0; k--)
		{
			if (!thrown[k] || !(cDisc && thrown[k] is cDisc)) continue;
			disc = thrown[k];
			late = (k < thrTic.Size() && thrTic[k] == level.maptime) ? 0 : 1;
			break;
		}
		if (!disc) return;
		for (int k = lmDisc.Size() - 1; k >= 0; k--) if (!lmDisc[k]) { lmDisc.Delete(k); lmMark.Delete(k); lmLate.Delete(k); lmTarget.Delete(k); }
		if (lmDisc.Size() >= 64) { lmDisc.Delete(0); lmMark.Delete(0); lmLate.Delete(0); lmTarget.Delete(0); }
		lmDisc.Push(disc); lmMark.Push(m); lmLate.Push(late); lmTarget.Push(null);
	}

	// A WEAPON THAT FELL OUT OF A MONSTER: one that appears at the body of a monster that died in the
	// last two seconds (a death drop: A_NoBlocking's DropItem, Brutal Doom's own drops). Not the
	// engine's DROPPED flag: every item spawned after the map loads carries that (Inventory.BeginPlay),
	// Brutal Doom's map weapons included, since its spawners make them at run time.
	override void WorldThingDied(WorldEvent e)
	{
		let v = e.Thing;
		if (!v || !v.bIsMonster) return;
		if (deadV.Size() >= 16) { deadV.Delete(0); deadTic.Delete(0); }
		deadV.Push(v); deadTic.Push(level.maptime);
	}

	private void NoteDrop(Actor w)
	{
		for (int k = deadV.Size() - 1; k >= 0; k--)
		{
			let v = deadV[k];
			if (!v || level.maptime - deadTic[k] > 70) { deadV.Delete(k); deadTic.Delete(k); continue; }
			// the body's standing height, not its corpse's (Die shrinks it to its DeathHeight)
			double tall = GetDefaultByType(v.GetClass()).height;
			if (w.Distance2D(v) <= v.radius + 32 && w.pos.z >= v.pos.z - 8 && w.pos.z <= v.pos.z + tall + 8)
			{
				for (int j = drops.Size() - 1; j >= 0; j--) if (!drops[j]) drops.Delete(j);
				if (drops.Size() >= 32) drops.Delete(0);
				drops.Push(w);
				return;
			}
		}
	}

	static bool MonsterDrop(Actor w)
	{
		let h = Get();
		if (!h || !w) return false;
		for (int k = 0; k < h.drops.Size(); k++) if (h.drops[k] == w) return true;
		return false;
	}

	// The engine's damage source for the blow that killed v this tic. `known` false when no such
	// blow was seen (a death that did not come through DamageMobj).
	static Actor, bool KillSource(Actor v)
	{
		let h = Get();
		if (!h || !v || h.killVictim != v || h.killTic != level.maptime) return null, false;
		return h.kSource, true;
	}

	private void NoteGlove(int pn, Actor glove)
	{
		if (pn < 0 || pn >= MAXPLAYERS) return;
		if (glRun[pn] > 0 && glLast[pn] && glLast[pn] != glove && level.maptime - glTic[pn] <= 17) glRun[pn]++;
		else glRun[pn] = 1;
		glLast[pn] = glove;
		glTic[pn] = level.maptime;
	}

	private void Trim()
	{
		// a spent shot is kept 35 tics (Counter asks who fired lately)
		for (int k = shots.Size() - 1; k >= 0; k--) if (!shots[k] && level.maptime - shotTic[k] > 35) { shots.Delete(k); shotFrom.Delete(k); shotTic.Delete(k); }
		while (shots.Size() >= 256) { shots.Delete(0); shotFrom.Delete(0); shotTic.Delete(0); }
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

	// did this monster fire a shot in the last `tics` tics (its own attack, whatever its states are called)
	static bool FiredWithin(Actor m, int tics)
	{
		let h = Get();
		if (!h || !m) return false;
		for (int k = h.shots.Size() - 1; k >= 0; k--)
		{
			if (level.maptime - h.shotTic[k] > tics) break;
			if (h.shotFrom[k] == m) return true;
		}
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

	// the player whose Force, kick, punch or bash last touched v (and v lived) inside LAUNCH_TICS, or null
	static Actor LaunchedBy(Actor v)
	{
		let h = Get();
		if (!h || !v) return null;
		for (int k = h.lnV.Size() - 1; k >= 0; k--)
			if (h.lnV[k] == v && h.lnBy[k] && h.lnBy[k].player && level.maptime - h.lnTic[k] <= RS_Melee.LAUNCH_TICS) return h.lnBy[k];
		// RSQ_Grapple's hook let go of it lately (dropped in a pit, thrown into harm): the hooker
		int t = RS_Grapple.Ask("hooked", v);
		if (t >= 0 && t <= RS_Melee.LAUNCH_TICS)
		{
			let by = RS_Grapple.AskActor("hooked.by", v);
			if (by && by.player) return by;
		}
		return null;
	}

	// Clean Sweep: this disc was rung on two or more locks at the throw, the victim is one of them, and
	// every other one of them is dead. (Not "every ring is gone": the disc drops a ring when it is done
	// with a lock, and measured on rig B it dropped a living Cyberdemon's ring and flew home -- the
	// sweep has to be the kills.)
	static bool SweptClean(Actor disc, Actor victim)
	{
		let h = Get();
		if (!h || !disc) return false;
		int rung = 0;
		bool wasLock = false;
		for (int k = 0; k < h.lmDisc.Size(); k++)
		{
			if (h.lmDisc[k] != disc || h.lmLate[k] != 0) continue;
			Actor t = h.lmTarget[k];
			if (!t && h.lmMark[k]) t = h.lmMark[k].tracer;
			if (!t) continue;
			rung++;
			if (t == victim) { wasLock = true; continue; }
			if (t.health > 0) return false;   // a lock still standing
		}
		return rung >= 2 && wasLock;
	}

	// Bank Shot: the victim carries a ring this disc rang after the throw (at a wall)
	static bool BankedAt(Actor disc, Actor victim)
	{
		let h = Get();
		if (!h || !disc || !victim) return false;
		for (int k = 0; k < h.lmDisc.Size(); k++)
		{
			if (h.lmDisc[k] != disc || h.lmLate[k] != 1) continue;
			Actor t = h.lmTarget[k];
			if (!t && h.lmMark[k]) t = h.lmMark[k].tracer;
			if (t == victim) return true;
		}
		return false;
	}

	// the gloves' run of alternating punches for this player, counting the punch that just landed
	static int GloveRun(int pn)
	{
		let h = Get();
		if (!h || pn < 0 || pn >= MAXPLAYERS || h.glTic[pn] != level.maptime) return 0;
		return h.glRun[pn];
	}

	// the damage flags of the blow that killed v this tic, or -1
	static int KillFlags(Actor v)
	{
		let h = Get();
		if (!h || !v || h.killVictim != v || h.killTic != level.maptime) return -1;
		return h.kFlags;
	}
}
