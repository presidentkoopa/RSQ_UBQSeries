// DOOMRL ARSENAL COMPATIBILITY.
//
// DRLA is DECORATE, like LegenDoom (see wr_compat_legendoom.zs), but its
// rarity concept is built a completely different way. LegenDoom rolls a
// marker item onto a weapon that otherwise stays the same class. DRLA does
// not -- an assembled weapon IS a different class outright: picking up a
// High-Power mod on a Pistol does not add anything to "RLPistol", it hands
// you an "RLHighPowerPistol", a wholly separate ACTOR that happens to
// inherit from RLWeapon. There is no field and no owned item on the HELD
// weapon that says its own tier, because the weapon's CLASS is the tier.
//
// Four tiers, confirmed against actors/weapons/{basic,advanced,master}
// assemblies.txt and actors/weapons/exotic/ -- Basic, Advanced, Master and
// Exotic, plus RLStandardWeaponPickup for a weapon nobody has modded at
// all. All five are declared in actors/ArsenalRLWeaponPickup.txt, and
// crucially ALL FIVE share the exact same pickup-glow effect
// (RLRarityBeamAssembled) -- DRLA never gave itself a colour per tier the
// way LegenDoom's StencilColor did, so unlike that file's palette, the
// colours below are invented rather than sourced. Picked to sit clear of
// LegenDoom's own four (green/blue/purple/orange) so a ring mixing both
// mods' weapons still reads as two systems, not one muddled one.
//
// THE READ: every weapon's pickup class is named "<WeaponClass>Pickup"
// with no exception found across all four tiers (spot-checked Basic,
// Advanced and Master directly; Exotic confirmed by its own base class
// existing and being used). That pickup class inherits from exactly one of
// the five bases above, so walking ITS ancestry -- never spawning it,
// purely a static class-table walk -- reads the tier straight off the
// class hierarchy DRLA already built. No per-weapon table, so a future
// DRLA weapon needs nothing added here as long as it follows the naming
// this build already uses everywhere.
//
// GetParentClass()/GetClassName() work on a class<Object> VALUE directly,
// not just on instances -- confirmed against the compiler
// (FxGetParentClass::Resolve, codegen.cpp), because the doc comment in
// engine/base.zs lists these as bare intrinsics with no `native` line of
// their own and it isn't obvious from that alone that a bare class
// reference qualifies as a valid Self for either call.
class wr_CompatDRLA
{
	const DRLA_BASIC    = 0;
	const DRLA_ADVANCED = 1;
	const DRLA_MASTER   = 2;
	const DRLA_EXOTIC   = 3;

	const COLOR_BASIC    = 0x8FA8C8;   // steel blue
	const COLOR_ADVANCED = 0x2FD9C4;   // teal
	const COLOR_MASTER   = 0xE0243E;   // crimson
	const COLOR_EXOTIC   = 0xFFD700;   // gold -- DRLA's own name for its rarest says so

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	// DRLA only ever registers "<Class>Pickup" for class names it actually
	// owns, never for a third-party mod's numbered dual-wield clones. A
	// dual-wielded Advanced Pistol is legitimately "RLAdvancedPistol_2"
	// under this ring's own convention, and Object.FindClass on
	// "RLAdvancedPistol_2Pickup" finds nothing -- the clone's card silently
	// showed no tier at all. wr_Rig.familyRoot() strips the suffix -- a
	// shared static now, not a duplicated copy (see wr_compat_legendoom.zs's
	// note on why this one, unlike this file's own cv(), didn't belong
	// triplicated).

	// FOUND, TIER. Checked highest to lowest only because that reads best;
	// unlike LegenDoom's markers a weapon cannot possibly match more than
	// one of these, they are mutually exclusive ancestors.
	static bool, int TierOf(Weapon w)
	{
		int none;
		if (!w || cv("wr_drla_compat", 1.0) <= 0.0) return false, none;

		class<Object> cls = (class<Object>)(Object.FindClass(Name(wr_Rig.familyRoot("" .. w.GetClassName()) .. "Pickup")));

		// Capped rather than walked to the root unconditionally -- a
		// defensive bound, not an expected case. DRLA's own hierarchy
		// bottoms out in a handful of steps; 32 is headroom, not a tuned
		// number.
		for (int i = 0; cls != null && i < 32; ++i, cls = cls.GetParentClass())
		{
			string nm = "" .. cls.GetClassName();
			if (nm == "RLExoticWeaponPickup")            return true, DRLA_EXOTIC;
			if (nm == "RLMasterAssembledWeaponPickup")   return true, DRLA_MASTER;
			if (nm == "RLAdvancedAssembledWeaponPickup") return true, DRLA_ADVANCED;
			if (nm == "RLBasicAssembledWeaponPickup")    return true, DRLA_BASIC;
			if (nm == "RLStandardWeaponPickup")          return false, none;   // explicitly unmodded; stop rather than keep climbing
		}
		return false, none;
	}

	static string TierWord(int t)
	{
		switch (t)
		{
			case DRLA_EXOTIC:   return "EXOTIC";
			case DRLA_MASTER:   return "MASTER";
			case DRLA_ADVANCED: return "ADVANCED";
			case DRLA_BASIC:    return "BASIC";
		}
		return "";
	}

	static color TierColor(int t)
	{
		switch (t)
		{
			case DRLA_EXOTIC:   return color(COLOR_EXOTIC);
			case DRLA_MASTER:   return color(COLOR_MASTER);
			case DRLA_ADVANCED: return color(COLOR_ADVANCED);
		}
		return color(COLOR_BASIC);
	}

	// Same (bool, color) shape as wr_CompatLegenDoom.TierOf() and
	// rsTierLookup(), so all three drop into cardColorFor()/tierColorOf()'s
	// call chain identically.
	static bool, color ColorOf(Weapon w)
	{
		bool found; int tier;
		[found, tier] = TierOf(w);
		color none;
		if (!found) return false, none;
		return true, TierColor(tier);
	}

	//==========================================================================
	// MODS -- A SECOND DATA AXIS, independent of the tier above.
	//
	// DRLA's Mod Station lets a player bolt UPGRADE mods onto a weapon after
	// the fact: Agility, Bulk, Firestorm, Nano, Power, Sniper, Technical, and
	// one joke entry ("Fu", found on exactly one secret weapon, Alucard's --
	// included anyway, since checking for it costs nothing extra). Unlike
	// TierOf() these are NOT mutually exclusive -- DRLA's own reset states
	// (e.g. HighPowerPistol.txt's discard handling) A_TakeInventory every mod
	// type off the same weapon in sequence, confirming one gun can carry any
	// combination at once. Same owned-item mechanism as TierOf(), checked as
	// a SET instead of stopping at the first match.
	//
	// Checked independently of TierOf() rather than folded under "only if
	// isDRLA" -- the mod item's own name is built from the HELD weapon's
	// class, not from its tier, so nothing here rules out a mod living on an
	// unassembled stock weapon if DRLA's Mod Station allows that.
	//
	// LEVEL INCLUDED. A mod's owned Inventory item caps at Amount 2, not 1
	// -- DRLA's own "Mod II" upgrade over the base mod -- confirmed
	// universal rather than type-specific: 66 to 76 weapon files each
	// reference a level-2 check, for every one of the seven real types, not
	// a subset. Amount is a plain Inventory field, the same one the
	// RESERVE row already reads off w.Ammo1 a few lines up in zscript.zs --
	// no new API, just read off the same owned item ModsOf() already found.
	//==========================================================================
	const MOD_AGILITY   = 1 << 0;
	const MOD_BULK      = 1 << 1;
	const MOD_FIRESTORM = 1 << 2;
	const MOD_NANO      = 1 << 3;
	const MOD_POWER     = 1 << 4;
	const MOD_SNIPER    = 1 << 5;
	const MOD_TECHNICAL = 1 << 6;
	const MOD_FU        = 1 << 7;

	// FOUND-mask, LEVEL2-mask. A mod at Amount 1 sets only the first; Amount
	// 2 or more sets both, so mask2 is always a subset of mask.
	static int, int ModsOf(Weapon w)
	{
		if (!w || cv("wr_drla_compat", 1.0) <= 0.0 || cv("wr_drla_mods", 1.0) <= 0.0) return 0, 0;

		string base = wr_Rig.familyRoot("" .. w.GetClassName());
		int mask = 0, mask2 = 0;
		// w.Owner.Inv, the head of the OWNER's chain: Inventory.Inv on an item
		// is the sibling link in its owner's list (inventory_util.zs
		// AddInventory prepends and reuses Inv as the link), so a walk from
		// w.Inv only ever saw items older than the weapon -- and the tokens
		// this looks for are granted to the PLAYER by weapon-state action
		// functions after the weapon is already owned, so they were in front
		// of it and never found. An unowned floor weapon has no tokens.
		for (Inventory it = (w.Owner ? w.Owner.Inv : null); it; it = it.Inv)
		{
			string nm = "" .. it.GetClassName();
			int bit = 0;
			if (nm == base .. "AgilityMod")        bit = MOD_AGILITY;
			else if (nm == base .. "BulkMod")      bit = MOD_BULK;
			else if (nm == base .. "FirestormMod") bit = MOD_FIRESTORM;
			else if (nm == base .. "NanoMod")      bit = MOD_NANO;
			else if (nm == base .. "PowerMod")     bit = MOD_POWER;
			else if (nm == base .. "SniperMod")    bit = MOD_SNIPER;
			else if (nm == base .. "TechnicalMod") bit = MOD_TECHNICAL;
			else if (nm == base .. "FuMod")        bit = MOD_FU;

			if (bit != 0)
			{
				mask |= bit;
				if (it.Amount >= 2) mask2 |= bit;
			}
		}
		return mask, mask2;
	}

	private static string appendMod(string s, int mask, int mask2, int bit, string tag)
	{
		if (!(mask & bit)) return s;
		string t = (mask2 & bit) ? (tag .. "-II") : tag;
		return s.Length() ? (s .. " " .. t) : t;
	}

	// Four-letter tags, kept short and uniform-width because a fully modded
	// weapon can show several at once on one row and the sheet has no
	// overflow handling for stat rows the way the title row does. "-II"
	// appended per mod at level 2, so a heavily modded weapon reads e.g.
	// "NANO-II BULK PWR" rather than needing a separate row per level.
	static string ModsWord(int mask, int mask2)
	{
		string s = "";
		s = appendMod(s, mask, mask2, MOD_NANO,      "NANO");
		s = appendMod(s, mask, mask2, MOD_BULK,      "BULK");
		s = appendMod(s, mask, mask2, MOD_AGILITY,   "AGIL");
		s = appendMod(s, mask, mask2, MOD_FIRESTORM, "FIRE");
		s = appendMod(s, mask, mask2, MOD_POWER,     "PWR");
		s = appendMod(s, mask, mask2, MOD_SNIPER,    "SNPR");
		s = appendMod(s, mask, mask2, MOD_TECHNICAL, "TECH");
		s = appendMod(s, mask, mask2, MOD_FU,        "FU");
		return s;
	}
}
