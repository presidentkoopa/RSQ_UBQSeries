// PANDEMONIA (BASE GAME) COMPATIBILITY.
//
// Pandemonia is the base mod the whole "Pandemonium" family sits on top of
// -- Anarchy (wr_compat_pandemonia_anarchy.zs), Ascension, Insurrection
// (wr_compat_pandemonia_insurrection.zs) and Renovation are all addons for
// THIS mod, not separate games; "Pandemonium" was this fork's own earlier
// misnomer for the family name. Its own weapon class, PandWeapon
// (PandZS/BaseActors.txt), is a COMPLETELY SEPARATE class hierarchy from
// Insurrection's PandInsWeapon -- the two mods do not share a weapon base
// class at all, so this file exists independently and reads its own field
// set. Anarchy's own weapons (e.g. "Class DustQuadShotgun :
// DustSuperShotgun", PandAWZS/Weapons/Slot3/QuadShotgun.txt) DO subclass
// base Pandemonia weapons, so everything here applies to them too with no
// extra work on this file's part.
//
// NO RARITY OR TIER CONCEPT HERE EITHER -- confirmed, same as the
// Insurrection module. What base Pandemonia has instead: its own
// independent durability system (same shape as Insurrection's but a
// separate field set on a separate class), an internal magazine distinct
// from the ammo pool (the number the mod's own HUD actually calls
// "loaded"), a fixed two-slot "sidegrade" upgrade system, and a single
// player-wide difficulty/progression counter mirrored onto the player
// pawn every tick. None of this touches tierColorOf()/cardColorFor() --
// purely supplementary rows.
//
// EVERY FIELD HERE IS PLAIN, read the same way every other real-ZScript
// mod in this fork is: this fork's field reflection natives, by name, no
// compile-time dependency on PandWeapon or DustPlayer at all.
class wr_CompatPandemonia
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

	// FOUND(HasDurability), CURRENT, MAX, BROKEN. Same shape and same
	// fail-closed reasoning as wr_CompatPandemoniaInsurrection.DurabilityOf
	// -- durability is opt-in per weapon (dwep), so that flag is the real
	// gate, not just a successful field read. A weapon can only ever match
	// ONE of the two DurabilityOf()s (this file's or Insurrection's),
	// since the two classes never share an instance -- both are called
	// unconditionally from buildSheetRows() and only one can ever return
	// found=true for a given weapon.
	static bool, int, int, bool DurabilityOf(Weapon w)
	{
		int hasI;
		if (!active(w) || !level.GetFieldBool(w, "dwep", hasI) || hasI == 0) return false, 0, 0, false;

		int cur, max, brokenI;
		if (!level.GetFieldInt(w, "durability", cur)) return false, 0, 0, false;
		if (!level.GetFieldInt(w, "dmax", max)) return false, 0, 0, false;
		if (!level.GetFieldBool(w, "dbroken", brokenI)) return false, 0, 0, false;
		return true, cur, max, brokenI != 0;
	}

	// FOUND(HasMagazine), CURRENT, MAX. magSize defaults to 0 on every
	// PandWeapon ("no internal mag, uses ammo pool directly" -- confirmed
	// against the mod's own HUD, PanHUDZS.txt, which reads magCount/
	// magSize off the ready weapon the same way this does), so "found"
	// means magSize > 0, not merely "the field exists". This is genuinely
	// different information from the sheet's generic AMMO/RESERVE rows --
	// magCount is what the mod's own HUD calls "loaded", separate from
	// whatever sits in the ammo pool behind it.
	static bool, int, int MagazineOf(Weapon w)
	{
		int cur, max;
		if (!active(w) || !level.GetFieldInt(w, "magSize", max) || max <= 0) return false, 0, 0;
		level.GetFieldInt(w, "magCount", cur);
		return true, cur, max;
	}

	// FOUND(HasSidegrade), SLOT-1-UNLOCKED, SLOT-2-UNLOCKED, LABEL. The
	// closest thing base Pandemonia has to a build system: a fixed
	// two-slot upgrade pair per weapon (sidegrade1/sidegrade2), each
	// either locked or holding a specific named upgrade (sidestring1/
	// sidestring2). "sidegrade" itself just means "this weapon HAS the
	// concept" -- weapons that don't opt in read false here the same way
	// an Insurrection weapon with no augments reads curaugs/maxaugs as
	// 0/0. sidestring1/sidestring2 are declared `name`, not `string` (a
	// real distinction this fork's field reflection enforces -- GetField
	// String refuses a name-typed field outright), so this reads them with
	// GetFieldName and converts with the same "" .. n coercion the rest of
	// this fork uses for class names.
	static bool, bool, bool, string SidegradesOf(Weapon w)
	{
		int hasI;
		if (!active(w) || !level.GetFieldBool(w, "sidegrade", hasI) || hasI == 0) return false, false, false, "";

		int s1I, s2I; name n1, n2;
		level.GetFieldBool(w, "sidegrade1", s1I);
		level.GetFieldBool(w, "sidegrade2", s2I);
		level.GetFieldName(w, "sidestring1", n1);
		level.GetFieldName(w, "sidestring2", n2);

		string l1 = "" .. n1, l2 = "" .. n2;
		string label = "";
		if (s1I != 0 && l1.Length()) label = l1;
		if (s2I != 0 && l2.Length()) label = label.Length() ? (label .. " / " .. l2) : l2;

		return true, s1I != 0, s2I != 0, label;
	}

	// FOUND, GAME LEVEL. playergamelevel (PandZS/Player/Player.txt) is a
	// plain int on DustPlayer, mirrored every tick from PandGlobalVariables
	// -- a bare Thinker singleton this fork's field reflection cannot
	// reach (it is never attached to any actor). DustPlayer is the shared
	// player class for the WHOLE Pandemonia family -- Insurrection's own
	// player class is declared "PandInsPlayer : DustPlayer" -- so this
	// same read works for an Insurrection weapon's owner too. Called
	// unconditionally from buildSheetRows(), same as Doomablo's LevelOf(),
	// since it says something about the PLAYER regardless of which
	// Pandemonia-family weapon happens to be in hand right now.
	static bool, int GameLevelOf(Weapon w)
	{
		int lvl;
		if (!active(w) || !w.Owner) return false, 0;
		if (!level.GetFieldInt(w.Owner, "playergamelevel", lvl)) return false, 0;
		return true, lvl;
	}
}
