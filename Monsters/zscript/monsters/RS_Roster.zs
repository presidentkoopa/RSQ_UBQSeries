// =====================================================================
// RS_Roster -- which monster actually spawns, per family.
//
// TWO JOBS:
//   1. SET SELECTION. Several rosters cover the same seventeen Doom
//      families (the CH colour tiers, whatever comes next). One set
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

	private CVar cvEnable;

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
	private bool regBuilt;

	private void BuildRegistry()
	{
		regBuilt = true;
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

	// Tier from the class name's colour word -- the RSQ ladder, ordered by
	// strength (owner 2026-11-11; RS_Retier.zs RS_TierLadder), so a family's cap
	// is "how strong may a spawn be". Name-derived because the tier token is only
	// set in PostBeginPlay and does not exist yet at the moment this has to choose.
	//
	// FIREBLU IS TESTED FIRST AND MUST STAY FIRST: RS_FireBluZombie also
	// contains "blu".
	static int TierOf(Name cls)
	{
		String s = "" .. cls;
		s = s.MakeLower();

		if (s.IndexOf("fireblu") >= 0) return 8;
		if (s.IndexOf("common")  >= 0) return 1;
		if (s.IndexOf("green")   >= 0) return 2;
		if (s.IndexOf("blue")    >= 0) return 3;
		if (s.IndexOf("purple")  >= 0) return 4;
		if (s.IndexOf("cyan")    >= 0) return 5;
		if (s.IndexOf("brown")   >= 0) return 6;
		if (s.IndexOf("yellow")  >= 0) return 7;
		if (s.IndexOf("gray")    >= 0) return 9;
		if (s.IndexOf("red")     >= 0) return 10;
		if (s.IndexOf("abyss")   >= 0) return 11;
		if (s.IndexOf("black")   >= 0) return 12;
		if (s.IndexOf("white")   >= 0) return 13;

		// Unrecognised colour survives the cap rather than vanishing -- a
		// roster that silently drops entries reads as monsters failing to
		// spawn, which is far worse than one extra spawn.
		return 1;
	}

	// an extra colour whose menu gate is off (CVARINFO: 1 = off and re-rolled)
	static bool GateOff(int tier)
	{
		Name cv = 'None';
		switch (tier)
		{
			case 5:  cv = 'rs_ch_cyan'; break;
			case 6:  cv = 'rs_ch_brown'; break;
			case 8:  cv = 'rs_ch_fireblu'; break;
			case 9:  cv = 'rs_ch_gray'; break;
			case 11: cv = 'rs_ch_abyss'; break;
		}
		if (cv == 'None') return false;
		let c = CVar.FindCVar(cv);
		return c && c.GetInt() == 1;
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
			int dt = TierOf(di.Name);
			if (dt > cap) continue;
			// [11-13 fix 3, design/BD_XMVE_TIERING.md 8.3] A SWITCHED-OFF EXTRA COLOUR IS NOT IN THE CAPPED LIST. Its gate
			// stub re-rolls into the family's WHOLE dial, uncapped, so under a cap of 5 or more a Cyan / Brown / FireBlu /
			// Gray / Abyss entry could come out as anything, Black and White included. (The boss gates are safe: off, they
			// turn into Red / Black, never the dial.)
			if (GateOff(dt)) continue;

			int w = di.Amount;
			if (w <= 0) w = 1;   // dial default is -1; RandomSpawner reads it the same way

			chName.Push(di.Name);
			chWeight.Push(w);
			famCount[fam]++;
		}
		famBuilt[fam] = true;
	}

	// =================================================================
	// THE MONSTER SET (RSQ, 2026-11-08). One server cvar, rsq_monster_set,
	// decides what the stock monster spawns become; it replaced the old
	// string rs_roster_pack (VANILLA/RSMG/RSMON). Read at each spawn, so a
	// change takes effect on the next map (or map restart).
	//   0 Vanilla      the id classes themselves, even with Brutal Doom loaded
	//   1 BD22         no RSQ replacement at all: whatever mod is loaded
	//                  decides. Brutal Doom not loaded (no BD class found at
	//                  runtime) = Vanilla.
	//   2 (MeatGrinder, removed 2026-11-10: read as ColorfulHell)
	//   3 ColorfulHell the CH dials, with the per-family tier caps as before
	//                  (rs_roster_enable / rs_roster_<family>), plus CH's six
	//                  projectile swaps. These used to be class-level
	//                  `replaces` on the CH classes; they live here now so the
	//                  set decides, and no other set gets them.
	// =================================================================
	const SET_VANILLA = 0;
	const SET_BD22    = 1;
	const SET_MG_GONE = 2;   // MeatGrinder, removed 2026-11-10 (owner); the number stays free
	const SET_CH      = 3;

	private CVar cvMonSet;
	private int  bdState;    // 0 unknown, 1 yes, -1 no

	// Brutal Doom, by class name only -- no hard link to it.
	private bool BDLoaded()
	{
		if (bdState == 0)
		{
			// Names held in strings so they resolve at RUN time: a class
			// literal is checked at compile time and fails without BD.
			static const String BDCLS[] = { "BrutalWeapon", "Brutal_Blood", "BD_Token" };
			bdState = -1;
			for (int i = 0; i < BDCLS.Size(); i++)
			{
				Class<Actor> c = BDCLS[i];
				if (c) { bdState = 1; break; }
			}
		}
		return bdState > 0;
	}

	// CH's dial per family (was `class <dial> : RandomSpawner replaces <id>`).
	static Name CHDial(int fam)
	{
		switch (fam)
		{
			case 0:  return 'RS_ZombieColourset';
			case 1:  return 'RS_ShotgunnerColourset';
			case 2:  return 'RS_ChaingunnerColourset';
			case 3:  return 'RS_ImpColourset';
			case 4:  return 'RS_Colourset5';
			case 5:  return 'RS_SpectreColourset';
			case 6:  return 'RS_Colourset7';
			case 7:  return 'RS_Colourset14';
			case 8:  return 'RS_Colourset15';
			case 9:  return 'RS_Colourset8';
			case 10: return 'RS_Colourset13';
			case 11: return 'RS_Colourset1';
			case 12: return 'RS_Colourset10';
			case 13: return 'RS_Colourset9';
			case 14: return 'RS_Colourset11';
			case 15: return 'RS_Colourset16';
			case 16: return 'RS_Colourset17';
		}
		return 'None';
	}

	// CH's projectile swaps (were `replaces` on the CH FX classes).
	static Name CHProjectile(Name replacee)
	{
		switch (replacee)
		{
			case 'DoomImpBall':       return 'RS_DoomImpBall2';     // RS_ImpFX.zs
			case 'CacodemonBall':     return 'RS_CacodemonBall2';   // RS_CacodemonFX.zs, CH Cacodemons.txt:1094
			case 'BaronBall':         return 'RS_BaronBall2';       // RS_BaronFX.zs, CH Barons.txt:1921
			case 'FatShot':           return 'RS_FatShot2';         // RS_FatsoFX.zs, CH Fatsos.txt:1283
			case 'ArachnotronPlasma': return 'RS_ArachnotronPlasma2'; // RS_SpiderFX.zs, CH Spiders.txt:1433
			case 'Rocket':            return 'RS_Rocket2';          // RS_CyberdemonFX.zs, CH CYBIES.txt:2119
		}
		return 'None';
	}

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!e.Replacee) return;
		Name rn = e.Replacee.GetClassName();
		int fam = FamilyId(rn);
		Name proj = (fam < 0) ? CHProjectile(rn) : 'None';
		if (fam < 0 && proj == 'None') return;   // not a class any set touches

		if (!cvMonSet) cvMonSet = CVar.FindCVar("rsq_monster_set");
		int set = cvMonSet ? cvMonSet.GetInt() : SET_CH;

		if (set == SET_BD22)
		{
			if (BDLoaded()) return;   // hand it to Brutal Doom untouched
			set = SET_VANILLA;
		}

		// ---- VANILLA -- the id monster itself, whatever else is loaded ----
		//
		// Replacement = null, NOT = Replacee. The engine refuses a
		// replacement equal to the replacee (the infinite-recursion guard
		// in DStaticEventHandler::CheckReplacement), so writing the vanilla
		// class back leaves the other mod's replacement in place. Null with
		// IsFinal makes GetReplacement return the original class.
		// Projectiles are left alone: Vanilla is about which MONSTERS spawn.
		if (set == SET_VANILLA)
		{
			if (fam < 0) return;
			e.Replacement = null;
			e.IsFinal = true;
			return;
		}

		// (2, MeatGrinder, went 11-10, owner: a saved 2 reads as ColorfulHell)
		if (set == SET_MG_GONE) set = SET_CH;

		// ---- COLORFUL HELL ----
		if (proj != 'None')
		{
			Class<Actor> pc = proj;
			if (pc) { e.Replacement = pc; e.IsFinal = true; }
			return;
		}

		Class<Actor> dial = CHDial(fam);
		if (!dial) return;

		// [ladder system, design/LADDER_SYSTEM.md point 1] the sliding window around the world tier, every colour
		if (RS_Ladder.On())
		{
			Class<Actor> lc = RS_Ladder.ClassForRung(fam, RS_Ladder.Roll(fam));
			if (lc) { e.Replacement = lc; e.IsFinal = true; return; }
		}

		if (!cvEnable) cvEnable = CVar.FindCVar("rs_roster_enable");
		int cap = (cvEnable && cvEnable.GetBool()) ? FamilyCap(fam) : TIER_MAX;
		if (cap < TIER_MAX)
		{
			if (!famBuilt[fam] || famCap[fam] != cap)
				BuildCHFamily(fam, dial, cap);

			int start = famStart[fam];
			int total = 0;
			for (int i = 0; i < famCount[fam]; i++)
				total += chWeight[start + i];
			if (total > 0)
			{
				int roll = random[RSRoster](0, total - 1);
				for (int i = 0; i < famCount[fam]; i++)
				{
					roll -= chWeight[start + i];
					if (roll < 0)
					{
						Class<Actor> pick = chName[start + i];
						if (pick) { e.Replacement = pick; e.IsFinal = true; return; }
						break;
					}
				}
			}
		}
		// Uncapped (or nothing under the cap): the family's own dial, which
		// is what the class-level `replaces` used to hand back.
		e.Replacement = dial;
		e.IsFinal = true;
	}

	private int FamilyCap(int fam)
	{
		let cv = CVar.FindCVar(FamilyCVar(fam));
		return cv ? clamp(cv.GetInt(), 1, TIER_MAX) : 1;
	}
}
