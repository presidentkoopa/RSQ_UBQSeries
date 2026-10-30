// LEGENDOOM COMPATIBILITY.
//
// LegenDoom is DECORATE, not ZScript -- no zscript folder, no Service class
// in it anywhere. That turns out not to matter: DECORATE compiles into the
// same Actor/Inventory class system ZScript does, so nothing here needs to
// know or care which language wrote the classes it's reading.
//
// What DOES matter is that LegenDoom's rarity is not a FIELD the way
// RS_Main's Tier is. RARITY_COMMON/UNCOMMON/RARE/EPIC (DECORATE.txt) are
// only ever passed as literal ACS args at the moment an effect is rolled --
// never stored anywhere on the weapon. The rarity a weapon actually HAS is
// recorded by giving it a marker Inventory item it owns for the rest of its
// life: e.g. "Actor LDPistolLegendaryRare : LDPermanentInventory {}"
// (PistolMechanics.dec). LegenDoom's own Ready states read it back the same
// way -- Pistol.dec checks "A_JumpIfInventory('LDPistolLegendaryRare',1,...)"
// with no AAPTR target, i.e. checking itself.
//
// The marker's own name is the weapon's class name with "Legendary" and the
// rarity word appended -- confirmed against all nine LegenDoom base
// weapons, including the one case (Fist) where the source FOLDER name
// doesn't match: the actual playable class is "LDFists", and the marker is
// "LDFistsLegendaryRare", so the weapon's own GetClassName() is always the
// right prefix. No lookup table needed.
//
// So this is a third read pattern alongside RS_Main's field reflection and
// the ServiceIterator bridge: walk the weapon's OWN owned-inventory chain
// and string-match a class name. Nothing here references an LD* class at
// compile time, so this compiles and no-ops identically whether or not
// LegenDoom is loaded -- same soft-dependency shape as cardColorFor()'s
// RS_TierColorService lookup, just without needing a Service to ask.
class wr_CompatLegenDoom
{
	const LD_COMMON   = 0;
	const LD_UNCOMMON = 1;
	const LD_RARE     = 2;
	const LD_EPIC     = 3;

	// LegenDoom's OWN colours, not invented for this sheet -- lifted from the
	// StencilColor on its pickup-glow effect actors (BaseWeaponPickups.dec:
	// LDLegendaryCommonPickupEffect and its three siblings), resolved against
	// the engine's named-colour table (x11r6rgb.txt) to real RGB. A player who
	// has picked up a purple-glowing rare already associates that colour with
	// that rarity; reusing it means the sheet agrees with the pickup instead
	// of teaching a second palette for the same four tiers.
	const COLOR_COMMON   = 0x00FF00;   // Green
	const COLOR_UNCOMMON = 0x0000FF;   // Blue
	const COLOR_RARE     = 0xA020F0;   // Purple
	const COLOR_EPIC     = 0xFFA500;   // Orange

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	// A dual-wielded weapon is legitimately a numbered clone subclass
	// (LDPistol_2, per the ring's own convention), but LegenDoom's Ready-
	// state check for the rarity marker is inherited unchanged from the
	// base class, so the marker granted on a clone is still named after
	// the UN-suffixed base ("LDPistolLegendaryEpic"). Without stripping
	// the suffix first, RarityOf(LDPistol_2) searched for
	// "LDPistol_2LegendaryEpic", found nothing, and a legendary weapon's
	// twin silently showed no rarity at all.
	//
	// wr_Rig.familyRoot() does the stripping -- a shared static, not a
	// duplicated copy: unlike this file's own private cv() (which
	// genuinely differs from the ring's, see that comment), the suffix
	// rule is pure string logic with no cvar or mod dependency, so a
	// second copy here had nothing to justify it and no way to stay in
	// sync with the original if the convention ever changed.

	// FOUND, RARITY. Order checked is Epic down to Common, matching the order
	// LegenDoom's own Ready states check in (Pistol.dec and siblings) -- a
	// weapon only ever carries one of the four, so the order only matters if
	// that invariant is ever broken, and Epic-first is the safe side of that.
	static bool, int RarityOf(Weapon w)
	{
		int none;
		if (!w || cv("wr_ld_compat", 1.0) <= 0.0) return false, none;

		string base = wr_Rig.familyRoot("" .. w.GetClassName());
		string wantEpic     = base .. "LegendaryEpic";
		string wantRare     = base .. "LegendaryRare";
		string wantUncommon = base .. "LegendaryUncommon";
		string wantCommon   = base .. "LegendaryCommon";

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
			if (nm == wantEpic)     return true, LD_EPIC;
			if (nm == wantRare)     return true, LD_RARE;
			if (nm == wantUncommon) return true, LD_UNCOMMON;
			if (nm == wantCommon)   return true, LD_COMMON;
		}
		return false, none;
	}

	static string RarityWord(int r)
	{
		switch (r)
		{
			case LD_EPIC:     return "EPIC";
			case LD_RARE:     return "RARE";
			case LD_UNCOMMON: return "UNCOMMON";
			case LD_COMMON:   return "COMMON";
		}
		return "";
	}

	static color RarityColor(int r)
	{
		switch (r)
		{
			case LD_EPIC:     return color(COLOR_EPIC);
			case LD_RARE:     return color(COLOR_RARE);
			case LD_UNCOMMON: return color(COLOR_UNCOMMON);
		}
		return color(COLOR_COMMON);
	}

	// Convenience wrapper for the two call sites (tierColorOf, cardColorFor)
	// that only want a colour and don't care which rarity produced it --
	// mirrors rsTierLookup()'s own (bool, color) shape so both bridges drop
	// into the same "found, use it" pattern at the call site.
	static bool, color TierOf(Weapon w)
	{
		bool found; int rarity;
		[found, rarity] = RarityOf(w);
		color none;
		if (!found) return false, none;
		return true, RarityColor(rarity);
	}

	//==========================================================================
	// ROLLED EFFECTS -- a second data axis on top of rarity, same idea as
	// wr_compat_drla.zs's Mod Station read but simpler to reach: around 180
	// distinct effects exist across the roster (Determined, Replicating,
	// Regenerating, DualWield, ...) -- far too many to hand-name, and unlike
	// DRLA's eight mods there is no need to. Every owned item matching
	// "<WeaponClass>Effect_<Name>" already carries its own display-ready
	// name as the suffix (LDPistolEffect_Determined -> "Determined"), so
	// this is read by PREFIX MATCH rather than a fixed list -- covers every
	// effect that exists today and any LegenDoom adds later with no table
	// to maintain.
	//
	// No attempt made to learn how many effects a given rarity actually
	// grants -- unnecessary. This walks w.Inv and collects every match it
	// finds, so it reads correctly whether a weapon carries one effect or
	// five; there is nothing here that assumes a count.
	//==========================================================================
	static string EffectsOf(Weapon w)
	{
		if (!w || cv("wr_ld_compat", 1.0) <= 0.0 || cv("wr_ld_effects", 1.0) <= 0.0) return "";

		string prefix = wr_Rig.familyRoot("" .. w.GetClassName()) .. "Effect_";
		int plen = int(prefix.Length());   // Length() is unsigned; see classNameHash()
		                                    // in zscript.zs for the same cast and why.
		string s = "";

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
			if (int(nm.Length()) > plen && nm.Left(plen) == prefix)
			{
				string tag = nm.Mid(plen).MakeUpper();
				s = s.Length() ? (s .. " " .. tag) : tag;
			}
		}
		return s;
	}
}
