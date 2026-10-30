// PANDEMONIA -- ANARCHY ADDON COMPATIBILITY.
//
// Anarchy (Pand-Anarchy-Monsters + Pand-Anarchy-Weapons, always released as
// a matched pair -- CHANGELOG.txt on each names the other's exact version
// it was synced against) is a hard-mode layer on top of base Pandemonia --
// see wr_compat_pandemonia.zs's header for how the whole family fits
// together. Its own weapons (DustQuadShotgun etc.) are plain PandWeapon
// subclasses, so they need no file of their own -- wr_compat_pandemonia
// .zs's durability/magazine/sidegrade reads already apply to them for
// free, no extra work here.
//
// WHAT THIS FILE READS INSTEAD: the Anarchic Sigil, a
// PandAZS/AnarchicSigil.txt inventory item every player is auto-granted
// once Anarchy loads. It is the one genuine PLAYER-leveling system
// anywhere in the whole Pandemonia family -- three levels (alevel 1-3),
// each requiring more XP (points/pointmax) than the last, used on a
// qualifying live monster to instantly upgrade it into its "Anarchic"
// superboss form. Independent of whichever weapon is in hand, so this is
// read off the OWNER's inventory chain -- the same owned-item walk
// wr_compat_metadoom.zs uses for Demon Keys -- since the Sigil's class
// name is Anarchy's own and not something this file can reference at
// compile time.
class wr_CompatPandemoniaAnarchy
{
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active(Weapon w)
	{
		return w && cv("wr_pand_compat", 1.0) > 0.0;
	}

	// FOUND, LEVEL, POINTS, POINTS-TO-NEXT, ON-COOLDOWN. alevel/points/
	// pointmax/used are plain fields on Pand_AnarchicSigil. At alevel 3
	// (max) the mod itself forces points/pointmax to 0/0 -- shown as-is
	// rather than specially cased in this file, since 0/0 at max level
	// already reads as "nothing left to earn" without extra logic here;
	// the sheet-row code decides how to word that, not this reader.
	static bool, int, int, int, bool SigilOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0, 0, false;

		for (Inventory it = w.Owner.Inv; it; it = it.Inv)
		{
			if (("" .. it.GetClassName()) != "Pand_AnarchicSigil") continue;

			int lvl, pts, ptsMax, usedI;
			if (!level.GetFieldInt(it, "alevel", lvl)) return false, 0, 0, 0, false;
			level.GetFieldInt(it, "points", pts);
			level.GetFieldInt(it, "pointmax", ptsMax);
			level.GetFieldBool(it, "used", usedI);
			return true, lvl, pts, ptsMax, usedI != 0;
		}
		return false, 0, 0, 0, false;
	}
}
