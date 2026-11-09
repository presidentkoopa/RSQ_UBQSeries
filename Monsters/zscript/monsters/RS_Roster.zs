// =====================================================================
// RS_Roster -- which monster actually spawns, per family.
//
// TWO JOBS:
//   1. SET SELECTION. Several rosters cover the same seventeen Doom
//      families (MG, the CH colour tiers, whatever comes next). One set
//      is active; a family the active set does not cover falls through
//      to the CH dial instead of spawning nothing.
//   2. TIER CAP. Within the CH fallback, how far up that family's colour
//      ladder a spawn may roll. 1 = Common only, which opens a new game
//      at roughly vanilla footing.
//
// ---------------------------------------------------------------------
// MONSTERS REGISTER THEMSELVES. DO NOT ADD A CENTRAL LIST.
// ---------------------------------------------------------------------
// The first version of this file carried a `switch` mapping family -> MG
// class. That is the wrong shape for a roster the owner has said he will
// be changing constantly: every new monster meant editing a switch in a
// file that has nothing to do with that monster, and a set half-added to
// the switch fails SILENTLY -- the family just keeps using the old set,
// no error, nothing in the log.
//
// So there is no list here. A monster extends RS_RosterMonster, declares
// two lines in its own Default block, and IS in the roster:
//
//     class RS_MG_Zombieman : RS_RosterMonster
//     {
//         Default
//         {
//             RS_RosterMonster.RosterFamily "ZombieMan";
//             RS_RosterMonster.RosterSet    "MG";
//             ...
//         }
//     }
//
// WorldLoaded walks AllActorClasses, picks out every RS_RosterMonster
// with a family declared, and builds the table. Adding a monster, a whole
// new set, or a tier ladder inside a set touches NO file but that
// monster's own.
//
// RosterTier and RosterWeight are there so a set can grow a ladder later
// without redesigning this: several monsters may claim the same family in
// the same set, and the pick is weighted among those at or below the
// family's cap. One monster per family just leaves both at their defaults.
//
// ---------------------------------------------------------------------
// WHY NOT `replaces`, WHICH IS WHAT THE SOURCE PACKS DO
// ---------------------------------------------------------------------
// Two classes replacing one vanilla monster is resolved by parse order,
// silently, and the loser never spawns again with nothing in the log. That
// is an unacceptable failure mode for a roster meant to be swapped often.
// Routing every choice through CheckReplacement means the active set is a
// cvar, every set stays spawnable by name, and NOTHING under
// zscript/monsters/ is edited to change which roster is live.
//
// ---------------------------------------------------------------------
// COST
// ---------------------------------------------------------------------
// CheckReplacement fires once per spawn, never per tic. The registration
// scan is once per map. The CH tier filter is cached per family per map --
// parsing thirteen class names per spawn is ~169 substring searches, which
// on a 4000-monster slaughter map is most of a second of load time for an
// answer that never changes.
// =====================================================================

// ---------------------------------------------------------------------
// The base every roster monster extends. Plain Actor subclass -- NOT
// abstract: abstract actors are invisible in this project and have cost
// it the weapons once and the monsters once.
// ---------------------------------------------------------------------
class RS_RosterMonster : Actor
{
	meta Name RS_Family;   // the vanilla class this stands in for
	meta Name RS_Set;      // which roster it belongs to
	meta int  RS_Tier;     // position on that set's ladder, 1 = base
	meta int  RS_Weight;   // relative pick weight within family+set

	Property RosterFamily : RS_Family;
	Property RosterSet    : RS_Set;
	Property RosterTier   : RS_Tier;
	Property RosterWeight : RS_Weight;

	Default
	{
		RS_RosterMonster.RosterFamily "none";
		RS_RosterMonster.RosterSet    "none";
		RS_RosterMonster.RosterTier   1;
		RS_RosterMonster.RosterWeight 100;
	}
}

class RS_RosterHandler : EventHandler
{
	const FAM_COUNT = 17;
	const TIER_MAX  = 13;

	private CVar cvEnable, cvSet;

	// --- registered roster monsters, rebuilt per map ---
	private Array<Class<Actor> > regClass;
	private Array<int>  regFam;
	private Array<int>  regTier;
	private Array<int>  regWeight;
	private Array<Name> regSet;

	// --- CH fallback tier cache, flattened; see header ---
	private Array<Name> chName;
	private Array<int>  chWeight;
	private int  famStart[FAM_COUNT];
	private int  famCount[FAM_COUNT];
	private bool famBuilt[FAM_COUNT];
	private int  famCap[FAM_COUNT];

	override void WorldLoaded(WorldEvent e)
	{
		chName.Clear();
		chWeight.Clear();
		for (int i = 0; i < FAM_COUNT; i++)
		{
			famBuilt[i] = false;
			famStart[i] = 0;
			famCount[i] = 0;
			famCap[i]   = TIER_MAX;
		}
		BuildRegistry();
	}

	// One pass over every actor class in the game. Anything descending
	// from RS_RosterMonster with a family declared joins the table.
	private void BuildRegistry()
	{
		regClass.Clear(); regFam.Clear(); regTier.Clear();
		regWeight.Clear(); regSet.Clear();

		for (int i = 0; i < AllActorClasses.Size(); i++)
		{
			Class<RS_RosterMonster> c = (class<RS_RosterMonster>)(AllActorClasses[i]);
			if (!c) continue;

			let d = GetDefaultByType(c);
			if (!d || d.RS_Family == 'none' || d.RS_Set == 'none') continue;

			int fam = FamilyId(d.RS_Family);
			if (fam < 0) continue;   // declared a family this handler doesn't know

			regClass.Push(c);
			regFam.Push(fam);
			regSet.Push(d.RS_Set);
			regTier.Push(d.RS_Tier < 1 ? 1 : d.RS_Tier);
			regWeight.Push(d.RS_Weight <= 0 ? 1 : d.RS_Weight);
		}
	}

	// Keyed on the VANILLA class each dial replaces -- dial names are
	// inconsistent (RS_ZombieColourset, but RS_Colourset1 for revenants)
	// while the vanilla names never move. Anything unlisted returns -1,
	// which is what keeps this off the projectile replacements
	// (DoomImpBall, Rocket, FatShot) that share the same event.
	static int FamilyId(Name replacee)
	{
		switch (replacee)
		{
			case 'ZombieMan':        return 0;
			case 'ShotgunGuy':       return 1;
			case 'ChaingunGuy':      return 2;
			case 'DoomImp':          return 3;
			case 'Demon':            return 4;
			case 'Spectre':          return 5;
			case 'Cacodemon':        return 6;
			case 'LostSoul':         return 7;
			case 'PainElemental':    return 8;
			case 'HellKnight':       return 9;
			case 'BaronOfHell':      return 10;
			case 'Revenant':         return 11;
			case 'Fatso':            return 12;
			case 'Arachnotron':      return 13;
			case 'Archvile':         return 14;
			case 'CyberDemon':       return 15;
			case 'SpiderMastermind': return 16;
		}
		return -1;
	}

	static Name FamilyCVar(int id)
	{
		switch (id)
		{
			case 0:  return 'rs_roster_zombieman';
			case 1:  return 'rs_roster_shotgunner';
			case 2:  return 'rs_roster_chaingunner';
			case 3:  return 'rs_roster_imp';
			case 4:  return 'rs_roster_demon';
			case 5:  return 'rs_roster_spectre';
			case 6:  return 'rs_roster_cacodemon';
			case 7:  return 'rs_roster_lostsoul';
			case 8:  return 'rs_roster_painelemental';
			case 9:  return 'rs_roster_hellknight';
			case 10: return 'rs_roster_baron';
			case 11: return 'rs_roster_revenant';
			case 12: return 'rs_roster_fatso';
			case 13: return 'rs_roster_arachnotron';
			case 14: return 'rs_roster_archvile';
			case 15: return 'rs_roster_cyberdemon';
			case 16: return 'rs_roster_mastermind';
		}
		return 'none';
	}

	// Tier from the class name's colour word -- CH's own icon index,
	// documented at RS_ZombiemanFX.zs:17-19. Name-derived because the tier
	// token is only set in PostBeginPlay and does not exist yet at the
	// moment this has to choose.
	//
	// FIREBLU IS TESTED FIRST AND MUST STAY FIRST: RS_FireBluZombie also
	// contains "blu".
	static int TierOf(Name cls)
	{
		String s = "" .. cls;
		s = s.MakeLower();

		if (s.IndexOf("fireblu") >= 0) return 7;
		if (s.IndexOf("common")  >= 0) return 1;
		if (s.IndexOf("green")   >= 0) return 2;
		if (s.IndexOf("blue")    >= 0) return 3;
		if (s.IndexOf("purple")  >= 0) return 4;
		if (s.IndexOf("yellow")  >= 0) return 5;
		if (s.IndexOf("red")     >= 0) return 6;
		if (s.IndexOf("gray")    >= 0) return 8;
		if (s.IndexOf("abyss")   >= 0) return 9;
		if (s.IndexOf("black")   >= 0) return 10;
		if (s.IndexOf("white")   >= 0) return 11;
		if (s.IndexOf("cyan")    >= 0) return 12;
		if (s.IndexOf("brown")   >= 0) return 13;

		// Unrecognised colour survives the cap rather than vanishing -- a
		// roster that silently drops entries reads as monsters failing to
		// spawn, which is far worse than one extra spawn.
		return 1;
	}

	private void BuildCHFamily(int fam, Class<Actor> dial, int cap)
	{
		famStart[fam] = chName.Size();
		famCount[fam] = 0;
		famCap[fam]   = cap;

		let def = GetDefaultByType(dial);
		if (!def) { famBuilt[fam] = true; return; }

		for (DropItem di = def.GetDropItems(); di != null; di = di.Next)
		{
			if (di.Name == 'None') continue;
			if (TierOf(di.Name) > cap) continue;

			int w = di.Amount;
			if (w <= 0) w = 1;   // dial default is -1; RandomSpawner reads it the same way

			chName.Push(di.Name);
			chWeight.Push(w);
			famCount[fam]++;
		}
		famBuilt[fam] = true;
	}

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!cvEnable) cvEnable = CVar.FindCVar("rs_roster_enable");
		if (!cvEnable || !cvEnable.GetBool()) return;
		if (!e.Replacement || !e.Replacee) return;

		int fam = FamilyId(e.Replacee.GetClassName());
		if (fam < 0) return;

		if (!cvSet) cvSet = CVar.FindCVar("rs_roster_pack");
		Name active = cvSet ? Name(cvSet.GetString()) : 'RSMG';

		// ---- 0. VANILLA -- cancel every replacement for this family -----
		//
		// Replacement = null, NOT = Replacee. The engine explicitly refuses
		// to assign a replacement equal to the replacee (events.cpp:2360,
		// the infinite-recursion guard), so writing the vanilla class back
		// leaves the colourset in place and the flag does nothing. Null with
		// IsFinal makes GetReplacement's `return Replacement ? Replacement
		// : this` hand back the original class -- info.cpp:625.
		if (active == 'VANILLA')
		{
			e.Replacement = null;
			e.IsFinal = true;
			return;
		}

		// ---- 1. the active pack, if it covers this family ---------------
		if (active != 'RSMON')
		{
			int cap = FamilyCap(fam);
			int total = 0;
			for (int i = 0; i < regClass.Size(); i++)
				if (regFam[i] == fam && regSet[i] == active && regTier[i] <= cap)
					total += regWeight[i];

			if (total > 0)
			{
				int roll = random[RSRoster](0, total - 1);
				for (int i = 0; i < regClass.Size(); i++)
				{
					if (regFam[i] != fam || regSet[i] != active || regTier[i] > cap) continue;
					roll -= regWeight[i];
					if (roll < 0)
					{
						e.Replacement = regClass[i];
						e.IsFinal = true;
						return;
					}
				}
			}
			// Falls through deliberately: the active pack has no monster for
			// this family, so RS_Mon covers it rather than the family
			// vanishing. A pack is allowed to be partial.
		}

		// ---- 2. RS_Mon (the colour tiers), tier-capped -------------------
		int cap = FamilyCap(fam);
		if (cap >= TIER_MAX) return;   // uncapped: hand it back to the dial untouched

		if (!famBuilt[fam] || famCap[fam] != cap)
			BuildCHFamily(fam, e.Replacement, cap);

		if (famCount[fam] <= 0) return;

		int start = famStart[fam];
		int total = 0;
		for (int i = 0; i < famCount[fam]; i++)
			total += chWeight[start + i];
		if (total <= 0) return;

		int roll = random[RSRoster](0, total - 1);
		for (int i = 0; i < famCount[fam]; i++)
		{
			roll -= chWeight[start + i];
			if (roll < 0)
			{
				e.Replacement = chName[start + i];
				e.IsFinal = true;
				return;
			}
		}
	}

	private int FamilyCap(int fam)
	{
		let cv = CVar.FindCVar(FamilyCVar(fam));
		return cv ? clamp(cv.GetInt(), 1, TIER_MAX) : 1;
	}
}
