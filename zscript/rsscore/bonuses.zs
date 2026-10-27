// ============================================================================
// The thirteen bonuses.
//
// EVERY NUMBER IN THIS FILE WAS READ OUT OF THE ORIGINAL ACS, not out of anyone's
// memory: the defines from score_defs.h and the rules from score_mults.h.
// If you change a number, change it because you decided to, and say so.
//
// EVALUATE IS PURE. It reads and returns; it never writes to the tracker. Anything
// a bonus needs to remember happens in Commit, which the handler calls only for
// the bonuses that actually survived the supersede pass. Mutating a counter inside
// a multiplier makes the result depend on the order the multipliers happened to be
// called in, which is how the original behaved and is not worth keeping.
//
// THIRTEEN, NOT FOURTEEN. The original's BONUSCOUNT is 14 because index 0 is
// BS_BASE -- the "Base" row of the HUD breakdown, which is the unmultiplied points
// and not a bonus at all. There is no fourteenth bonus to find.
// ============================================================================


// ---------------------------------------------------------------- EFFICIENCY

// Spree: kills in quick succession. The window scales with what you killed, so a
// Cyberdemon buys you longer to find the next one than a Zombieman does.
class RS_Bonus_Spree : RS_ScoreBonus
{
	const TICSPER100HP = 24;
	const MINTICS      = 72;
	const MAXTICS      = 360;
	const MULTMAX      = 0.25;
	const MULTINC      = 0.025;

	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Spree"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) { return 0.0; }

		// Lapsed streaks pay nothing. Commit starts the next one at 1.
		if (level.maptime > tr.spreeExpire) { return 0.0; }

		return min(MULTMAX, MULTINC * tr.spreeCount);
	}

	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) { return; }

		if (level.maptime > tr.spreeExpire) { tr.spreeCount = 1; }
		else                                { tr.spreeCount += 1; }

		int add = clamp(int(round(TICSPER100HP * ev.victimSpawnHealth * 0.01)), MINTICS, MAXTICS);
		tr.spreeExpire = level.maptime + add;
	}
}


// Untouchable: kills since you last took damage. Two ways in -- a kill count or a
// combined health count -- so it triggers both for someone clearing a crowd of
// weak monsters and for someone who took down one big one.
//
// Once it is running it ESCALATES: every further kill adds stacks, and a big
// monster adds more of them. Both thresholds come from the map census, so a small
// map asks for less.
class RS_Bonus_Untouchable : RS_ScoreBonus
{
	const KILLBOOST_HPDIVISOR = 400;
	const MAXSTACKS           = 20;
	const MAXMULT             = 0.5;

	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Untouchable"; }

	private bool Qualifies(RS_ScoreEvent ev) const
	{
		let tr = ev.tracker;
		if (!tr) { return false; }
		return (tr.utKills >= ev.utKillsNeeded) || (tr.utHP >= ev.utHPNeeded);
	}

	private int StacksAfter(RS_ScoreEvent ev) const
	{
		return ev.tracker.utStacks + 1 + (ev.victimSpawnHealth / KILLBOOST_HPDIVISOR);
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!Qualifies(ev)) { return 0.0; }
		return (MAXMULT * min(StacksAfter(ev), MAXSTACKS)) / double(MAXSTACKS);
	}

	override void Commit(RS_ScoreEvent ev)
	{
		if (!Qualifies(ev)) { return; }
		ev.tracker.utStacks = StacksAfter(ev);
	}
}


// Infighter: a monster killed another monster and every player scores. Not earned
// by anyone in particular, which is exactly why it pays everyone.
class RS_Bonus_Infighter : RS_ScoreBonus
{
	const MULT = 0.2;

	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Infighter"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		return ev.monsterOnMonster ? MULT : 0.0;
	}
}


// -------------------------------------------------------------------- STYLE

// Switcharoo: you varied what you were shooting with. Two different weapons pays
// twice what two different triggers on one weapon pays.
class RS_Bonus_Switcharoo : RS_ScoreBonus
{
	const TICSPER100HP = 24;
	const MINTICS      = 72;
	const MAXTICS      = 144;
	const MULT_WEAPONS = 0.15;
	const MULT_MODES   = 0.075;

	override String DisplayName() const { return "Switcharoo"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) { return 0.0; }

		// maxtics = middle(72, oldRound(24 * myhp * 0.01), 144); cutoff = Timer() - maxtics
		int maxtics = clamp(int(round(TICSPER100HP * ev.victimSpawnHealth * 0.01)), MINTICS, MAXTICS);
		int cutoff  = level.maptime - maxtics;

		int weapons, modes;
		tr.CountRecentFire(cutoff, weapons, modes);

		if (weapons > 1) { return MULT_WEAPONS; }
		if (modes   > 1) { return MULT_MODES; }
		return 0.0;
	}
}


// Air: killed while off the ground, paid on how high this jump reaches rather than
// how high you happen to be at the moment of the shot -- so a kill on the way up
// counts the same as one at the apex.
class RS_Bonus_Air : RS_ScoreBonus
{
	const MINHEIGHT = 64.0;
	const MULT      = 0.005;
	const MAXMULT   = 2.0;

	override String DisplayName() const { return "Air"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		double over = max(0.0, ev.airHeight - MINHEIGHT);
		return min(MAXMULT, over * MULT);
	}
}


// Curveball: the victim never had a clear line to you. Around a corner, over a
// ledge, through a doorway it could not see through.
class RS_Bonus_Curveball : RS_ScoreBonus
{
	const MULT = 0.2;

	override String DisplayName() const { return "Curveball"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) { return 0.0; }
		return ev.victimCouldSee ? 0.0 : MULT;
	}
}


// Scrapping: a kill with a signature weapon. Originally one specific gun, matched
// by damage type or by whatever fired last. The damage-type route is general and
// stays; the weapon list is empty until a weapon pack declares one, because a
// hardcoded weapon name here would be a favour to one mod.
class RS_Bonus_Scrapping : RS_ScoreBonus
{
	const MULT = 0.125;

	override String DisplayName() const { return "Scrapping"; }

	// SMult_Scrapping, both halves. Note the order: if a damage type was given at
	// all, the damage type is the ONLY test -- the weapon-slot fallback is reached
	// only when there is no damage type, which in this engine is rare.
	override double Evaluate(RS_ScoreEvent ev)
	{
		String dt = ev.damageType;
		bool haveType = (dt != "" && dt != "None");

		if (haveType)
		{
			return (dt == "Scrap") ? MULT : 0.0;
		}

		let tr = ev.tracker;
		if (!tr) { return 0.0; }

		return (tr.LatestFiredSlot() == RS_ScoreTracker.S_SCRAPPER) ? MULT : 0.0;
	}
}


// Darwin: the monster killed itself. Pays every player, and pays enormously --
// triple the base -- because you did not do it, you arranged it.
class RS_Bonus_Darwin : RS_ScoreBonus
{
	const MULT = 2.0;

	override String DisplayName() const { return "Darwin"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		return ev.selfInflicted ? MULT : 0.0;
	}
}


// Telefrag.
class RS_Bonus_Telefrag : RS_ScoreBonus
{
	const MULT = 1.0;

	override String DisplayName() const { return "Telefragged"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		return ev.telefragged ? MULT : 0.0;
	}
}


// -------------------------------------------------------------------- DARING

// Brawler: a melee kill, priced per weapon. The table is kept whole -- the Heretic
// and Hexen entries cost nothing to carry and work the moment someone loads those
// weapons.
//
// Two ways to match: by damage type, which is exact, or by what the player is
// currently holding, which is a guess and is why some entries are marked
// type-only.
class RS_Bonus_Brawler : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Brawler"; }

	// weapon class, damage type, multiplier, and whether the weapon name may only
	// be trusted when no damage type was given. Built once on first use rather
	// than declared as static const arrays, which keeps the four columns readable
	// and the types unambiguous.
	private Array<String> m_wep;
	private Array<String> m_type;
	private Array<double> m_mult;
	private Array<int>    m_typeOnly;
	private bool m_built;

	private void Entry(String wep, String type, double mult, int typeOnly)
	{
		m_wep.Push(wep);
		m_type.Push(type);
		m_mult.Push(mult);
		m_typeOnly.Push(typeOnly);
	}

	private void BuildTable()
	{
		m_built = true;

		//     weapon          damage type        mult   type-only
		Entry("Fist",         "",                0.5,   0);
		Entry("Chainsaw",     "",                0.5,   0);
		Entry("DWep_Fists",   "FistRapid",       0.25,  1);
		Entry("",             "FistLightStun",   0.25,  0);
		Entry("",             "FistMediumStun",  0.25,  0);
		Entry("",             "FistHeavyStun",   0.25,  0);
		Entry("PunchDagger",  "",                0.5,   0);
		Entry("FWeapFist",    "",                0.25,  0);
		Entry("FWeapAxe",     "",                0.15,  0);
		Entry("FWeapHammer",  "",                0.1,   0);
		Entry("CWeapMace",    "",                0.3,   0);
		Entry("Staff",        "",                0.5,   0);
		Entry("Gauntlets",    "",                0.25,  0);
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) { return 0.0; }
		if (!m_built) { BuildTable(); }

		String dt = ev.damageType;
		bool haveType = (dt != "" && dt != "None");

		String held = "";
		let p = ev.killer.player;
		if (p && p.ReadyWeapon) { held = p.ReadyWeapon.GetClassName(); }

		for (int i = 0; i < m_mult.Size(); i++)
		{
			if (haveType && m_type[i] != "" && dt == m_type[i])
			{
				return m_mult[i];
			}

			if ((!haveType || m_typeOnly[i] == 0) && m_wep[i] != "" && held == m_wep[i])
			{
				return m_mult[i];
			}
		}

		return 0.0;
	}
}


// Redline: YOUR health, not the victim's. The original switched its activator to
// the shooter before running any multiplier, so SMult_BoneDry was reading the
// player all along -- it pays for killing while you are nearly dead, not for
// killing something that was. At 25 HP it pays 0.02; at 1 HP it pays 0.50.
class RS_Bonus_Redline : RS_ScoreBonus
{
	const MAXHP     = 25;
	const MULTPERHP = 0.02;

	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Redline"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) { return 0.0; }

		// Below zero is Swan Song's business.
		if (ev.killerHealth < 0) { return 0.0; }
		if (ev.killerHealth > MAXHP) { return 0.0; }

		return MULTPERHP * ((MAXHP - ev.killerHealth) + 1);
	}
}


// Swan Song: the kill landed after you were already dead. Triple base, and it
// replaces Redline -- being dead is not also being nearly dead.
class RS_Bonus_SwanSong : RS_ScoreBonus
{
	const MULT = 3.0;

	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Swan Song"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) { return 0.0; }
		return ev.killerWasDead ? MULT : 0.0;
	}

	override bool Supersedes(RS_ScoreBonus other) const
	{
		return (other is "RS_Bonus_Redline");
	}
}


// Point-Blank: measured box edge to box edge, never centre to centre. A
// Cyberdemon standing on your feet has its centre a long way from yours.
class RS_Bonus_PointBlank : RS_ScoreBonus
{
	const DIST = 64.0;
	const MULT = 0.1;

	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Point-Blank"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) { return 0.0; }
		return (ev.edgeDistance < DIST) ? MULT : 0.0;
	}
}
