// ============================================================================
// THE MELEE ROWS, SECOND ROUND (2026-11-09, design/SCORE_EXPANSION.md E: the audit of every RSQ Melee move against the
// rows Score already had; these are the moves that paid nothing, or paid under the wrong name). The owner: "I want a
// big tree to prune." Names are proposals; pay is a share of the kill's base like every row. Written by reading only:
// nothing here has been run (owner's rule for this batch).
//
// What they read from RSQ Melee, by NAME (RSQML_Service, Melee/zscript/rsqml/service.zs; 0 is always "no", so an older
// Melee that answers 0 to what it does not know can never pay one):
//   "guarded"        Rope-a-Dope        "barrel.kicked"   Field Goal          "headlock.by"   Meat Shield, Human Shield
//   "headlock.shield" Human Shield      "fear"            Red Mist            "punch.star"    Star Punch
// and from what Score already keeps: the kill's tool and tags (the ledger, combo.zs), Multi-Kill's count (rows.zs).
// ============================================================================

class RS_Melee2Seed play
{
	static void Names(out Array<String> into)
	{
		static const String rows[] =
		{
			"RS_RowM2_Swatted", "RS_RowM2_RopeADope", "RS_RowM2_Seismic", "RS_RowM2_OutOfMyWay", "RS_RowM2_FullRelease",
			"RS_RowM2_MeatShield", "RS_RowM2_HumanShield", "RS_RowM2_FieldGoal", "RS_RowM2_SeeingStars", "RS_RowM2_Meteor",
			"RS_RowM2_StarPunch", "RS_RowM2_DownForTheCount", "RS_RowM2_BareKnuckle", "RS_RowM2_RedMist"
		};
		for (int i = 0; i < rows.Size(); i++) into.Push(rows[i]);
	}
}

class RS_Melee2 play
{
	static int Ask(String what, Object about, int arg = 0) { return RS_Svc.Int(RS_Svc.MELEE, what, arg, about); }

	// ONE MOVE KILLING SEVERAL: how many earlier kills this same move made on this same tic (Multi-Kill's own count,
	// rows.zs RS_Row_MultiKill.Earlier), when the killing blow is that move
	static int SameMove(RS_ScoreEvent ev, String tool)
	{
		if (!ev.killer || ev.ringOut || RS_Rows.Tool(ev) != tool) return 0;
		return RS_Row_MultiKill.Earlier(ev);
	}
}

// E1 SWATTED: a monster's missile your open palm knocked ASIDE (Melee's plain swat, not Swat Back) killed something.
// Before 11-09 it read as a saber return and paid Return to Sender under that name; now Melee lists it ("returned.by" 3)
// and the ledger names it swat.aside (tools.zs). Replaces Return to Sender for that kill; Misdirection and Poetic
// Justice still pay what they say.
class RS_RowM2_Swatted : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Swatted"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Rows.Tool(ev) == "swat.aside") ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_ReturnToSender"; }
}

// E2 ROPE-A-DOPE: your Guard soaked this monster's blow, and you killed it within 3 s. More when the kill is a blow of
// your hands or a hand weapon (the counterpunch). A parry has its own combos (Parry Punish...): only the soak counts here.
class RS_RowM2_RopeADope : RS_ScoreBonus
{
	const MULT = 0.4;
	const HANDS = 0.6;
	const WINDOW = 105;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Rope-a-Dope"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || !ev.victim || ev.killerNum < 0) return 0.0;
		int t = RS_Melee2.Ask("guarded", ev.victim, ev.killerNum);
		if (t <= 0 || t - 1 > WINDOW) return 0.0;
		return RS_Rows.MeleeKind(ev) ? HANDS : MULT;
	}
}

// E3 SEISMIC: one Ground Pound kills two or more. Each kill past the first pays 0.3, up to 0.9. Replaces Multi-Kill
// for those kills (its count is still kept: every bonus is committed, handler.zs). The single pound kill is Ground Pound's.
class RS_RowM2_Seismic : RS_ScoreBonus
{
	const PER = 0.3;
	const MAXMULT = 0.9;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Seismic"; }
	override double Evaluate(RS_ScoreEvent ev) { int n = RS_Melee2.SameMove(ev, "pound"); return n > 0 ? min(MAXMULT, PER * n) : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Row_MultiKill"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 2 * PER - 0.001; }
}

// E4 OUT OF MY WAY: one Clear Out kills two or more (the same pay and rule as Seismic). The single kill is Bouncer's.
class RS_RowM2_OutOfMyWay : RS_ScoreBonus
{
	const PER = 0.3;
	const MAXMULT = 0.9;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Out of My Way"; }
	override double Evaluate(RS_ScoreEvent ev) { int n = RS_Melee2.SameMove(ev, "clearout"); return n > 0 ? min(MAXMULT, PER * n) : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Row_MultiKill"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 2 * PER - 0.001; }
}

// E5 FULL RELEASE: the Guard's stored charge, let out round you, kills two or more (Absorb and Release, Gun Bonsai VR).
// The single kill is Release's.
class RS_RowM2_FullRelease : RS_ScoreBonus
{
	const PER = 0.3;
	const MAXMULT = 0.9;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Full Release"; }
	override double Evaluate(RS_ScoreEvent ev) { int n = RS_Melee2.SameMove(ev, "guard.release"); return n > 0 ? min(MAXMULT, PER * n) : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Row_MultiKill"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 2 * PER - 0.001; }
}

// E6 MEAT SHIELD: the monster in your Headlock dies of what another monster threw at you (Human Shield's blows taken
// for you, or a shot it simply stood in front of). It is your kill now (melee.zs RS_ScoreShots.LaunchedBy names the
// holder: a Ring Out), and this replaces Ring Out's row for it.
class RS_RowM2_MeatShield : RS_ScoreBonus
{
	const MULT = 0.6;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Meat Shield"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.ringOut || !ev.victim || ev.killerNum < 0) return 0.0;
		return RS_Melee2.Ask("headlock.by", ev.victim) == ev.killerNum + 1 ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_RingOut"; }
}

// E7 HUMAN SHIELD: you kill something else while your off hand holds a living monster as a Human Shield (the option, or
// Gun Bonsai VR's node). The held monster itself is Hostage's, Close Quarters'... (combos.zs).
class RS_RowM2_HumanShield : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Human Shield"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || !ev.victim || ev.killerNum < 0) return 0.0;
		if (RS_Melee2.Ask("headlock.shield", ev.killer) != 2) return 0.0;
		return RS_Melee2.Ask("headlock.by", ev.victim) == ev.killerNum + 1 ? 0.0 : MULT;
	}
}

// E8 FIELD GOAL: the blast of a barrel your uppercut kicked (Uppercut Kicks Barrels, or Distance Grab's Barrel Lock-On)
// kills, within 5 s of the kick. With the lock-on Distance Grab flies it as a throw, so Powder Keg pays as well.
class RS_RowM2_FieldGoal : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Field Goal"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.inflictor || ev.inflictor == ev.killer || ev.killerNum < 0) return 0.0;
		return RS_Melee2.Ask("barrel.kicked", ev.inflictor, ev.killerNum) > 0 ? MULT : 0.0;
	}
}

// E9 SEEING STARS: a monster a Heavy Hands punch froze (the chicks and stars over its head) is killed within 1 s of that
// punch, by anything of yours. Read from the ledger: the punch's run carries Melee's hit.heavy tag. A Heavy Hands punch
// that kills by itself is not this (its tag comes after the blow).
class RS_RowM2_SeeingStars : RS_ScoreBonus
{
	const MULT = 0.3;
	const WINDOW = 35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Seeing Stars"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || ev.killerNum < 0) return 0.0;
		RS_Combo.ChainOf(ev);
		let led = RS_ComboLedger.Get();
		if (!led) return 0.0;
		for (int k = 0; k < ev.chainIdx.Size(); k++)
		{
			int i = ev.chainIdx[k];
			if (led.TagAt(i, "hit.heavy") && i < led.eLast.Size() && level.maptime - led.eLast[i] <= WINDOW) return MULT;
		}
		return 0.0;
	}
}

// E10 METEOR: a monster your uppercut launched came down on this one and killed it (Gun Bonsai VR's Meteor node; Melee
// tags the blow "meteor" before it lands).
class RS_RowM2_Meteor : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Meteor"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Melee.Tagged(ev, "meteor")) ? MULT : 0.0; }
}

// E11 STAR PUNCH: the gloves' Star Punch (Gun Bonsai VR, SuperPunchOut's) kills it. A big moment.
class RS_RowM2_StarPunch : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Star Punch"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.GloveKill(ev) && RS_Rows.Punch(ev, "punch.star") == 1) ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// E12 DOWN FOR THE COUNT: a monster your Rifle Butt shove knocked down (Gun Bonsai VR; Melee's butt.knockdown tag) is
// killed inside the chain's 3 s.
class RS_RowM2_DownForTheCount : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Down for the Count"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && !ev.ringOut && RS_Rows.ChainTag(ev, "butt.knockdown")) ? MULT : 0.0; }
}

// E13 BARE KNUCKLE: a glove kill while RSQ Melee's Slappers Only is on (every gun put away for the run).
class RS_RowM2_BareKnuckle : RS_ScoreBonus
{
	const MULT = 0.15;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Bare Knuckle"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Rows.GloveKill(ev)) return 0.0;
		let c = CVar.FindCVar("rsqml_slappers");
		return (c && c.GetInt() != 0) ? MULT : 0.0;
	}
}

// E14 RED MIST (section F): a shotgun kill inside your F.E.A.R. window (the slow motion after your gun-butt shove) on a
// monster you did NOT shove -- the shoved one is the F.E.A.R. Effect combo's (combo.zs). With Melee's F.E.A.R. Blood Mist
// on it is the kill that bursts into mist.
class RS_RowM2_RedMist : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Red Mist"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || RS_Rows.Tool(ev) != "gun.shotgun") return 0.0;
		if (RS_Melee2.Ask("fear", ev.killer) != 1) return 0.0;
		return RS_Rows.ChainHas(ev, "shove") ? 0.0 : MULT;
	}
}
