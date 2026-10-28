// ============================================================================
// BOOSTED MONSTERS: the kill knows what it killed. (The owner, 10-27: a Champion kill names its
// colour and its mutation, a LegenDoom Lite legendary is named as legendary, and a "dormant boosted
// legendary champion" -- both at once -- gets its own row.)
//
// NOTHING HERE LINKS TO EITHER MOD. Every fact is an inventory class, a cvar or a lump looked up by
// NAME at run time, so this file compiles and runs with neither mod loaded (every row then pays 0).
//
// WHAT THE BASE ALREADY PAYS, so no row pays it twice (parsed from the two mods, 10-27):
//   Champions   its controller sets StartHealth = health / skill factor once the champion is set up
//               (baseclass.txt Tick), AFTER its tier's own health change (Red x2, Bronze x2, Silver
//               x1.25, Gold x5, Titan ((hp x 1.5) + 150) x 2...). The base is StartHealth
//               (GetSpawnHealth), so a champion's extra HEALTH is already paid; the colour row pays
//               for its POWERS, and is small.
//   LegenDoom Lite  ACS (LEGNDLIB LDMonsterInit) sets health to spawn health x LD_legendaryhealth/100
//               (300 % by default) without touching StartHealth, so the base is the class's. At half
//               of that it refills to full and transforms (LDLegendaryMonsterTransformed; its
//               PowerProtection only lists DemonSlayer, so every other damage type goes through
//               whole: measured, 1000 in -> 1000 taken). So a risen legendary is 1.5 x 300 % of the
//               class's health, none of it in the base: the legendary rows are the big ones.
//   Both, dormant  champion_Legendoom + champion_Dormant (+ LegenDoom loaded): EVERY champion stays
//               dormant -- no powers, no health, no icon -- until LegenDoom transforms it; then its
//               controller sets up and takes StartHealth from the health it has THEN: LegenDoom's
//               refill x the tier's factor. So the base of a legendary champion already holds the
//               legendary health, and its row ("Legendary Champion") is smaller than "Legendary". A
//               champion that never transformed in that mode never had a power: it pays nothing here.
//               Out of dormant mode the order decides: a legendary spawned after the map started is
//               boosted by LegenDoom's ACS first and set up by Champions after, so its StartHealth
//               holds the 300 % too (measured: a Bronze Titan imp 1740 = ((80 x 3 x 2) x 1.5 + 150)
//               x 2) -- so a risen legendary that is also an active champion is "Legendary Champion"
//               in either mode, never "Legendary". (And LegenDoom's refill then only goes back to the
//               health it captured BEFORE Champions: 240 for that imp -- Champions' order, not ours.)
//
// THE ROWS ONLY PAY A PLAYER'S KILL (ev.killer set). A monster that kills a legendary pays everyone
// base + Infighter, as any infight does.
//
// THE CAP HOLDS: these are ordinary bonuses, summed with the rest and charged against
// rs_score_cap_kill (Daring family, rs_score_cap_daring) like any other.
//
// THE HOOK FOR A LATER MONSTER SET (RS Monsters' 13 colour tiers and EX tier): subclass
// RS_ScoreTierRow, answer Token() (the inventory class the monster carries for that tier, by name),
// DisplayName(), Mult(), and Group() (one row per group per kill: the highest Mult wins), override
// Active(v) if the tier can be dormant, and register the class from your own StaticEventHandler's
// OnRegister with RS_ScoreRegistry.RegisterBonus("YourRow"). Nothing in RS_Score changes. A monster
// set that spawns extra bodies that are not kills adds their token to RS_Boost.NOT_A_KILL.
// ============================================================================

class RS_BoostSeed play
{
	static void Names(out Array<String> into)
	{
		static const String rows[] =
		{
			"RS_Bonus_ChampDarkRed", "RS_Bonus_ChampRed", "RS_Bonus_ChampOrange", "RS_Bonus_ChampYellow",
			"RS_Bonus_ChampDarkGreen", "RS_Bonus_ChampGreen", "RS_Bonus_ChampCyan", "RS_Bonus_ChampBlue",
			"RS_Bonus_ChampIndigo", "RS_Bonus_ChampViolet", "RS_Bonus_ChampPink", "RS_Bonus_ChampBlack",
			"RS_Bonus_ChampGrey", "RS_Bonus_ChampWhite", "RS_Bonus_ChampBronze", "RS_Bonus_ChampSilver",
			"RS_Bonus_ChampGold",
			"RS_Bonus_MutTitan", "RS_Bonus_MutUndying", "RS_Bonus_MutGhost", "RS_Bonus_MutBalloon",
			"RS_Bonus_MutHybrid",
			"RS_Bonus_Legendary", "RS_Bonus_LegendDenied", "RS_Bonus_LegendChampion"
		};
		for (int i = 0; i < rows.Size(); i++) into.Push(rows[i]);
	}
}

// The facts, by name.
class RS_Boost play
{
	// NotAKill: carried by bodies another mod spawns that the level does not count and that are not kills,
	// whatever their class replaces (Champions' Indigo clones keep the parent's class -- a Brutal Doom
	// class that replaces a counted monster -- after Champions clears their COUNTKILL).
	static bool Has(Actor a, String cls)
	{
		if (!a || cls == "") return false;
		class<Inventory> c = cls;
		return c && a.FindInventory(c);
	}

	static bool NotAKill(Actor a)
	{
		static const String NOT_A_KILL[] = { "champion_CloneToken" };
		for (int i = 0; i < NOT_A_KILL.Size(); i++) if (Has(a, NOT_A_KILL[i])) return true;
		return false;
	}

	static int CvarI(Name n) { let c = CVar.FindCVar(n); return c ? c.GetInt() : 0; }

	static bool LegenDoomLoaded()
	{
		return Wads.FindLump("LEGNDLIB") != -1 || Wads.CheckNumForFullName("acs/LEGNDLIB.o") != -1;
	}

	// Champions' own test (handler.txt WorldLoaded + champion_LegendoomCheck): its LegenDoom mode is on
	// and dormant. Then a champion has no powers until LegenDoom transforms it.
	static bool DormantMode()
	{
		return CvarI('champion_Legendoom') != 0 && CvarI('champion_Dormant') != 0 && LegenDoomLoaded();
	}

	static bool Legendary(Actor v)   { return Has(v, "LDLegendaryMonsterToken"); }
	static bool Transformed(Actor v) { return Has(v, "LDLegendaryMonsterTransformed"); }
	static bool Champion(Actor v)    { return Has(v, "champion_PersistentInfo"); }

	// A champion with its powers on.
	static bool ChampActive(Actor v)
	{
		return Champion(v) && (!DormantMode() || Transformed(v));
	}

	// Champions' colour tokens all derive from champion_Token (tokens.txt); a hybrid carries two.
	static int ColourTokens(Actor v)
	{
		String bn = "champion_Token";
		class<Inventory> base = bn;
		if (!v || !base) return 0;
		int n = 0;
		// Amount, not items: a hybrid whose second colour is its first holds one token at 2 (MaxAmount 2)
		for (let it = v.Inv; it; it = it.Inv) if (it.GetClass() != base && it is base) n += it.Amount;
		return n;
	}

	// Marks noted when something else dies first (RS_ScoreHandler.WorldThingDied -> NoteDeath): an
	// Undying champion's heart names its master, and the heart is gone by the time the master dies.
	static void NoteDeath(RS_ScoreHandler h, Actor dead)
	{
		if (!h || !dead || !dead.master) return;
		if (dead.GetClassName() == 'champion_Heart') h.Mark(dead.master, 'undying');
	}
}

// One boosted-monster row. The data is the subclass's answers; the rule is here.
class RS_ScoreTierRow : RS_ScoreBonus
{
	virtual String Token() const { return ""; }
	virtual double Mult() const { return 0.25; }
	virtual Name Group() const { return 'champion'; }
	virtual bool Active(Actor v) { return RS_Boost.ChampActive(v); }

	override int Family() const { return FAM_DARING; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim) return 0.0;
		if (!RS_Boost.Has(ev.victim, Token()) || !Active(ev.victim)) return 0.0;
		return Mult();
	}

	// One row per group per kill (a hybrid wears two colour tokens): the higher Mult wins; on a tie
	// the first in registry order (class-name order) zeroes the other before it is asked.
	override bool Supersedes(RS_ScoreBonus other) const
	{
		let o = RS_ScoreTierRow(other);
		if (!o || o.Group() != Group()) return false;
		return Mult() >= o.Mult();
	}
}

// ---- Champions' seventeen colours (champion_Tokens in Champions' zscript.txt, rarity weights in its
// cvarinfo: the fourteen colours 10 each, Bronze 3, Silver 2, Gold 1) ------------------------------
class RS_Bonus_ChampDarkRed   : RS_ScoreTierRow { override String Token() const { return "champion_DarkRedToken"; }   override String DisplayName() const { return "Dark Red Champion"; } }
class RS_Bonus_ChampRed       : RS_ScoreTierRow { override String Token() const { return "champion_RedToken"; }       override String DisplayName() const { return "Red Champion"; } }
class RS_Bonus_ChampOrange    : RS_ScoreTierRow { override String Token() const { return "champion_OrangeToken"; }    override String DisplayName() const { return "Orange Champion"; } }
class RS_Bonus_ChampYellow    : RS_ScoreTierRow { override String Token() const { return "champion_YellowToken"; }    override String DisplayName() const { return "Yellow Champion"; } }
class RS_Bonus_ChampDarkGreen : RS_ScoreTierRow { override String Token() const { return "champion_DarkGreenToken"; } override String DisplayName() const { return "Dark Green Champion"; } }
class RS_Bonus_ChampGreen     : RS_ScoreTierRow { override String Token() const { return "champion_GreenToken"; }     override String DisplayName() const { return "Green Champion"; } }
class RS_Bonus_ChampCyan      : RS_ScoreTierRow { override String Token() const { return "champion_CyanToken"; }      override String DisplayName() const { return "Cyan Champion"; } }
class RS_Bonus_ChampBlue      : RS_ScoreTierRow { override String Token() const { return "champion_BlueToken"; }      override String DisplayName() const { return "Blue Champion"; } }
class RS_Bonus_ChampIndigo    : RS_ScoreTierRow { override String Token() const { return "champion_IndigoToken"; }    override String DisplayName() const { return "Indigo Champion"; } }
class RS_Bonus_ChampViolet    : RS_ScoreTierRow { override String Token() const { return "champion_VioletToken"; }    override String DisplayName() const { return "Violet Champion"; } }
class RS_Bonus_ChampPink      : RS_ScoreTierRow { override String Token() const { return "champion_PinkToken"; }      override String DisplayName() const { return "Pink Champion"; } }
class RS_Bonus_ChampBlack     : RS_ScoreTierRow { override String Token() const { return "champion_BlackToken"; }     override String DisplayName() const { return "Black Champion"; } }
class RS_Bonus_ChampGrey      : RS_ScoreTierRow { override String Token() const { return "champion_GreyToken"; }      override String DisplayName() const { return "Grey Champion"; } }
class RS_Bonus_ChampWhite     : RS_ScoreTierRow { override String Token() const { return "champion_WhiteToken"; }     override String DisplayName() const { return "White Champion"; } }
// the rare three: their health is in the base already; the row pays their powers and their rarity
class RS_Bonus_ChampBronze    : RS_ScoreTierRow { override String Token() const { return "champion_BronzeToken"; }    override String DisplayName() const { return "Bronze Champion"; } override double Mult() const { return 0.5; } }
class RS_Bonus_ChampSilver    : RS_ScoreTierRow { override String Token() const { return "champion_SilverToken"; }    override String DisplayName() const { return "Silver Champion"; } override double Mult() const { return 0.5; } }
class RS_Bonus_ChampGold      : RS_ScoreTierRow { override String Token() const { return "champion_GoldToken"; }      override String DisplayName() const { return "Gold Champion"; }   override double Mult() const { return 0.75; } }

// ---- Champions' mutations (baseclass.txt champion_InitMutation). Only Titan leaves a token; the
// others are read off what the mutation did to the monster. --------------------------------------
class RS_ScoreMutationRow : RS_ScoreTierRow
{
	override Name Group() const { return 'mutation'; }
	virtual bool Mutated(Actor v) { return RS_Boost.Has(v, Token()); }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Boost.ChampActive(ev.victim) || !Mutated(ev.victim)) return 0.0;
		return Mult();
	}
}

// Titan: bigger, x2 damage, bosses' flags, triple shots (its health is in the base)
class RS_Bonus_MutTitan : RS_ScoreMutationRow
{
	override String Token() const { return "champion_TitanToken"; }
	override String DisplayName() const { return "Titan"; }
	override double Mult() const { return 0.5; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Undying: buddha until its heart is killed (the heart's death is noted, RS_Boost.NoteDeath)
class RS_Bonus_MutUndying : RS_ScoreMutationRow
{
	override String DisplayName() const { return "Undying"; }
	override double Mult() const { return 0.5; }
	override bool Mutated(Actor v)
	{
		let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
		return h && h.Marked(v, 'undying');
	}
}

// Ghost: VISIBILITYPULSE set on a class that does not have it
class RS_Bonus_MutGhost : RS_ScoreMutationRow
{
	override String DisplayName() const { return "Ghost"; }
	override bool Mutated(Actor v) { return v.bVisibilityPulse && !v.default.bVisibilityPulse; }
}

// Balloon: a walker made to float and bob (Champions clears FLOATBOB a tic after the death; the
// death event comes first)
class RS_Bonus_MutBalloon : RS_ScoreMutationRow
{
	override String DisplayName() const { return "Balloon"; }
	override bool Mutated(Actor v) { return v.bFloatBob && !v.default.bFloatBob && v.bNoGravity && !v.default.bNoGravity; }
}

// Hybrid: a second colour's powers (two colour tokens); the colour row pays one of them
class RS_Bonus_MutHybrid : RS_ScoreMutationRow
{
	override String DisplayName() const { return "Hybrid"; }
	override bool Mutated(Actor v) { return RS_Boost.ColourTokens(v) >= 2; }
}

// ---- LegenDoom Lite ----------------------------------------------------------------------------
// Each its own group; the three exclude one another in Evaluate.

// Risen: it went to half and came back full -- 4.5 x the class's health in all (none of it in the base)
class RS_Bonus_Legendary : RS_ScoreTierRow
{
	override Name Group() const { return 'legend'; }
	override String DisplayName() const { return "Legendary"; }
	override double Mult() const { return 1.5; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Boost.Transformed(ev.victim)) return 0.0;
		if (RS_Boost.ChampActive(ev.victim)) return 0.0;   // Legendary Champion's
		return Mult();
	}
}

// Killed before it could rise: its triple health went in one tic (LegenDoom's ACS looks once a tic)
class RS_Bonus_LegendDenied : RS_ScoreTierRow
{
	override Name Group() const { return 'legend'; }
	override String DisplayName() const { return "Legend Denied"; }
	override double Mult() const { return 0.75; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Boost.Legendary(ev.victim) || RS_Boost.Transformed(ev.victim)) return 0.0;
		return Mult();
	}
}

// The boosted legendary champion -- in the owner's dormant mode, a champion BECAUSE it rose: risen
// with its champion powers on. Its base already holds LegenDoom's health (see the header), so this
// is smaller than Legendary; its colour and mutation rows pay as well.
class RS_Bonus_LegendChampion : RS_ScoreTierRow
{
	override Name Group() const { return 'legend'; }
	override String DisplayName() const { return "Legendary Champion"; }
	override double Mult() const { return 0.5; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Boost.Transformed(ev.victim)) return 0.0;
		if (!RS_Boost.ChampActive(ev.victim)) return 0.0;
		return Mult();
	}
}
