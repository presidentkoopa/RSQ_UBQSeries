// METADOOM COMPATIBILITY.
//
// MetaDoom has no rarity/tier ladder -- confirmed twice over (its weapon
// "variety" is spawn-time selection between distinct, separately-authored
// classes, actors/weapons/SPAWNERS.zsc, not a quality axis on one weapon
// that changes over time) -- but a third pass, specifically hunting for
// escalation on a weapon already IN HAND rather than at pickup, found two
// real ones. Both were missed by searching "rarity"/"tier"/"level"
// vocabulary because MetaDoom names them after what they physically are,
// not after a loot-system word.
//
// No tier concept here either, so like wr_compat_pandemonium.zs and
// wr_compat_guncaster.zs this never touches tierColorOf()/cardColorFor() --
// purely supplementary sheet rows.
class wr_CompatMetaDoom
{
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active(Weapon w)
	{
		return w && cv("wr_meta_compat", 1.0) > 0.0;
	}

	// PLASMA RIFLE HEAT. heatlevel/shotsfired are plain fields declared
	// directly on MetaPlasmaRifle (actors/weapons/metaplasmarifle.zsc) --
	// every 10 shots bumps heat by one, capped at 5, and MetaDoom's own
	// weapon overlay already re-skins the model per heat level, so this
	// mirrors something the game already shows on the gun itself, not new
	// information invented for the sheet.
	//
	// FOUND, HEAT, SHOTS-TOWARD-NEXT. Found only for the one weapon that
	// actually has these fields -- reflection fails cleanly on anything
	// else, so no class-name check is needed up front.
	static bool, int, int HeatOf(Weapon w)
	{
		int heat, shots;
		if (!active(w) || !level.GetFieldInt(w, "heatlevel", heat)) return false, 0, 0;
		level.GetFieldInt(w, "shotsfired", shots);
		return true, heat, shots;
	}

	// UNMAKER DEMON KEYS. DemonKey (Doom 64 lore: the three keys) is a
	// plain player-inventory Counter, not a field -- read the same
	// owned-item walk wr_compat_legendoom.zs uses for rarity markers,
	// since CountInv() needs a compile-time class<Inventory> and DemonKey
	// is MetaDoom's own class, not this wheel's. More keys held changes
	// the Unmaker's actual fire pattern (single shot -> triple shot +
	// triple rail), so this is shown for the Unmaker at ANY key count
	// including zero -- zero keys is the reason a freshly-found Unmaker
	// fires so much weaker than a late-game one, which is worth knowing,
	// not just worth hiding until it changes.
	static bool, int KeysOf(Weapon w)
	{
		if (!active(w) || w.Owner == null) return false, 0;
		if (("" .. w.GetClassName()) != "MetaUnmaker") return false, 0;

		for (Inventory it = w.Owner.Inv; it; it = it.Inv)
		{
			if (("" .. it.GetClassName()) == "DemonKey")
				return true, it.Amount;
		}
		return true, 0;
	}
}
