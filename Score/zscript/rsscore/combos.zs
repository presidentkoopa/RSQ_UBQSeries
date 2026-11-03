// ============================================================================
// THE SIGNATURE COMBOS: the series' named chains, as data (combo.zs RS_ComboSeed.Combos calls Add). One row per
// recognisable move, chosen from Score/ideas/COMBOS_MASTER.md section 4 for variety and coverage without
// confusion (the owner, 11-03: "Variety, coverage, but not confusion"); the generic chain rule pays every other
// mix. Names are proposals; the owner renames after 1.0, and a rename never needs code: the sheet's
// "suggested name" column is the source of these strings.
//
// A pattern is "a > b > c", the last step the finishing blow (combo.zs): a step is a tool id, a prefix (saber,
// grenade, gun...) or a group (hands, fists, melee, block, parry, return, throw); it may carry @slow (landed in
// the player's own slow motion), +air / +pb / +head / +<tag>, and the pattern may end "| <filter>" on the victim.
// Pay is a multiplier of the kill's base. A named row must pay more than any broader row it sits under (the
// best-paying match wins), so a class row (gun.shotgun) always beats its plain twin (gun).
// ============================================================================
class RS_ComboTable play
{
	static void Add(RS_ScoreRegistry reg)
	{
		// filled by the combo shortlist pass (Score handoff step 3.5)
	}
}
