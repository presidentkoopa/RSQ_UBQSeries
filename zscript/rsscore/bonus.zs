// ============================================================================
// RS_ScoreBonus -- the extension point, and the registry that collects them.
//
// THE RULE THIS FILE EXISTS TO ENFORCE: a bonus ships from the mod that owns the
// fact it measures. RS_Score must never contain a list of every bonus in the
// fleet. ShieldSaw's "parried" bonus needs ShieldSaw's state; the reload pack's
// "tactical" bonus needs the reload pack's state; neither is any of this pack's
// business. A fixed array of bonuses means adding one edits four files, which is
// exactly the shape we are avoiding.
//
// HOW A MOD ADDS ONE. Declare a subclass, and register it from your own handler:
//
//     class RSSS_Parried : RS_ScoreBonus { ... }
//
//     class RSSS_Handler : StaticEventHandler
//     {
//         override void OnRegister()
//         {
//             RS_ScoreRegistry.RegisterBonus("RSSS_Parried");
//         }
//     }
//
// WHY REGISTRATION AND NOT A CLASS SCAN. ZScript is only handed AllActorClasses,
// never the full class list, so there is no way to find every subclass of a
// non-actor class from script. Exposing PClass::AllClasses to ZScript would be a
// small and genuinely general engine addition -- it would serve any mod building a
// registry, not just this one -- and if it ever lands, the registry below becomes
// a scan and the RegisterBonus calls can go. Until then this is honest and it is
// deterministic, which matters more (see SORTING).
//
// SORTING, AND WHY IT IS NOT DECORATION. Bonuses are summed, and floating point
// addition is not associative -- a different order can land a different last bit.
// In a net game that is a desync. The registry sorts by class name so every
// machine sums in the same order regardless of load order.
// ============================================================================

class RS_ScoreBonus play
{
	enum EScoreFamily
	{
		FAM_EFFICIENCY,
		FAM_STYLE,
		FAM_DARING,
	}

	// Which of the three families this belongs to. The family decides the colour
	// on the HUD and which cap the bonus is charged against.
	virtual int Family() const { return FAM_STYLE; }

	// The label the breakdown shows. Kept here rather than in LANGUAGE because a
	// bonus from another mod should not have to add a string table to ship.
	virtual String DisplayName() const { return ""; }

	// The multiplier this bonus adds, as a fraction of base points. 0 means it did
	// not fire. The multipliers are SUMMED and the sum applied to the base once, so
	// they stack additively rather than compounding -- keep it that way.
	virtual double Evaluate(RS_ScoreEvent ev) { return 0.0; }

	// Anything this bonus needs to REMEMBER for next time. The handler calls it
	// only for bonuses that fired and were not superseded, after every Evaluate has
	// run -- so one bonus writing state can never change what another one returned.
	virtual void Commit(RS_ScoreEvent ev) {}

	// When both this bonus and `other` fire, does this one replace it? Swan Song
	// replaces Redline: being dead is not also being nearly dead. Two bonuses that
	// can never both return non-zero get this for free; stating it out loud means a
	// bonus from another mod can do the same deliberately.
	virtual bool Supersedes(RS_ScoreBonus other) const { return false; }

	// ------------------------------------------------------------ small helpers

	// The colour name this family draws in. One per family, three in all.
	String FamilyColor() const
	{
		switch (Family())
		{
			case FAM_EFFICIENCY: return "RSScore_Efficiency";
			case FAM_DARING:     return "RSScore_Daring";
			default:             return "RSScore_Style";
		}
	}
}


// ============================================================================
// RS_ScoreRegistry -- session-long, holds the bonus list.
//
// A StaticEventHandler because the list is the same for the whole session: it is
// decided by which mods are loaded, and that cannot change mid-game. The
// per-level RS_ScoreHandler asks this for the sorted, instantiated list.
// ============================================================================

class RS_ScoreRegistry : StaticEventHandler
{
	private Array<String> m_typeNames;
	private Array<RS_ScoreBonus> m_bonuses;
	private bool m_built;

	// RS_Score's own thirteen, pushed DIRECTLY onto this instance.
	//
	// NOT through RegisterBonus, and NOT from OnRegister. A handler cannot Find
	// ITSELF from inside its own OnRegister -- it is not in the registered list yet,
	// so Find returns null and RegisterBonus takes its early return. That is exactly
	// what happened: all thirteen were dropped, the bonus list stayed empty, and
	// nothing complained. Kills still paid their base points, the HUD still drew, the
	// boot test still went green -- every bonus just silently paid nothing. Seeding
	// from Build, against `self`, is what stops that recurring.
	private void SeedOwn()
	{
		Own("RS_Bonus_Spree");
		Own("RS_Bonus_Untouchable");
		Own("RS_Bonus_Infighter");
		Own("RS_Bonus_Switcharoo");
		Own("RS_Bonus_Air");
		Own("RS_Bonus_Curveball");
		Own("RS_Bonus_Scrapping");
		Own("RS_Bonus_Darwin");
		Own("RS_Bonus_Telefrag");
		Own("RS_Bonus_Brawler");
		Own("RS_Bonus_Redline");
		Own("RS_Bonus_SwanSong");
		Own("RS_Bonus_PointBlank");
	}

	private void Own(String typeName)
	{
		for (int i = 0; i < m_typeNames.Size(); i++)
		{
			if (m_typeNames[i] == typeName) { return; }
		}

		m_typeNames.Push(typeName);
	}

	// Called from any mod's OnRegister. Safe to call twice with the same name.
	static void RegisterBonus(String typeName)
	{
		let reg = RS_ScoreRegistry(StaticEventHandler.Find("RS_ScoreRegistry"));
		if (!reg) { return; }

		if (reg.m_built)
		{
			// The list has already been handed out this session. Silently growing it
			// now would give two machines different lists if their load orders
			// differed, so say so instead of desyncing later.
			Console.Printf("\cgRS_Score: bonus '%s' registered too late to be used.", typeName);
			return;
		}

		for (int i = 0; i < reg.m_typeNames.Size(); i++)
		{
			if (reg.m_typeNames[i] == typeName) { return; }
		}

		reg.m_typeNames.Push(typeName);
	}

	// The sorted, instantiated list. Built once, on first ask -- by which time
	// every mod's OnRegister has run.
	static void GetBonuses(out Array<RS_ScoreBonus> outList)
	{
		outList.Clear();

		let reg = RS_ScoreRegistry(StaticEventHandler.Find("RS_ScoreRegistry"));
		if (!reg) { return; }

		if (!reg.m_built) { reg.Build(); }

		for (int i = 0; i < reg.m_bonuses.Size(); i++)
		{
			outList.Push(reg.m_bonuses[i]);
		}
	}

	private void Build()
	{
		m_built = true;

		// Ours first, then whatever other mods registered during their OnRegister.
		SeedOwn();

		// Insertion sort by class name. Small list, and a stable order on every
		// machine is the entire point (see SORTING in the header).
		Array<String> sorted;
		for (int i = 0; i < m_typeNames.Size(); i++)
		{
			String name = m_typeNames[i];
			int at = sorted.Size();

			for (int j = 0; j < sorted.Size(); j++)
			{
				if (name < sorted[j]) { at = j; break; }
			}

			sorted.Insert(at, name);
		}

		for (int i = 0; i < sorted.Size(); i++)
		{
			class<RS_ScoreBonus> type = sorted[i];

			if (!type)
			{
				Console.Printf("\cgRS_Score: no such bonus class '%s'.", sorted[i]);
				continue;
			}

			let b = RS_ScoreBonus(new(type));
			if (b) { m_bonuses.Push(b); }
		}

		// SAY SO IF THE LIST IS EMPTY. An empty registry is never correct and is
		// invisible from the outside: the score still counts, the HUD still draws, and
		// every bonus just quietly pays nothing. That failure ran green for hours.
		if (m_bonuses.Size() == 0)
		{
			Console.Printf("\cgRS_Score: NO BONUSES REGISTERED -- base points only. This is a bug.");
		}
		else
		{
			let cv = CVar.FindCVar("rs_score_debug");
			if (cv && cv.GetBool())
			{
				Console.Printf("RS_Score: %d bonuses registered.", m_bonuses.Size());
			}
		}
	}
}
