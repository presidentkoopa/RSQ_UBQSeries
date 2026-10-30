// DOOMABLO COMPATIBILITY.
//
// Doomablo (https://github.com/sidav/doomablo) is real ZScript, unlike
// LegenDoom and DRLA -- and its rarity is a plain public field because of
// it. generatedRarity is declared on the Affixable mixin
// (zscript/affixable/affixable.zs) and applied to RwWeapon itself
// (zscript/rweapons/randomized_weapon.zs: "class RwWeapon : DoomWeapon
// abstract { mixin Affixable; }"), so every Doomablo weapon carries it
// directly -- no owned-item walk (wr_compat_legendoom.zs) or
// class-ancestry climb (wr_compat_drla.zs) needed. This is read exactly
// the way RS_Main's own Tier field is, in rsRows() (zscript.zs): this
// fork's field reflection natives, by name, no compile-time dependency on
// RwWeapon at all.
//
// Seven tiers, not the six the mod's own README lists -- Common(0)/
// Uncommon(1)/Rare(2)/Epic(3)/Legendary(4)/Mythic(5) plus Unique(6), the
// one adding_new_uniques.txt calls out separately as "max rarity" and the
// README's prose just doesn't enumerate. Names and the palette both come
// straight from RaritiesHelper (zscript/misc/rarities_helper.zs) --
// getRarityName() and indicatorColorForRarity(), the same colour Doomablo
// itself puts on the floating beam over a dropped item, so the sheet
// agrees with what the player already saw on the ground.
//
// WHAT THIS DOES NOT COVER: the applied-affix list (100+ per the mod's own
// README). appliedAffixes is an array<Affix>, and each concrete Affix
// subclass's display name comes from a VIRTUAL METHOD (getName(),
// zscript/affix/affix.zs), not a field -- field reflection reads raw
// field VALUES by name, it cannot invoke a method on a class this file has
// no compile-time knowledge of, and there is no array-element reflection
// in this fork's native set either (HasField/GetFieldInt/Bool/Float/
// String/Name/Object/FieldCount/FieldAt -- none of those give you element
// N of a named array field). Unlike the other two mods' second axis
// (LegenDoom's effects, DRLA's mods), this one is genuinely unreachable
// without either a Doomablo-side Service or new engine reflection natives
// -- not attempted here.
class wr_CompatDoomablo
{
	const DBL_COMMON    = 0;
	const DBL_UNCOMMON  = 1;
	const DBL_RARE      = 2;
	const DBL_EPIC      = 3;
	const DBL_LEGENDARY = 4;
	const DBL_MYTHIC    = 5;
	const DBL_UNIQUE    = 6;

	const COLOR_COMMON    = 0xFFFFFF;
	const COLOR_UNCOMMON  = 0x00FF00;
	const COLOR_RARE      = 0x1111FF;
	const COLOR_EPIC      = 0xCC00FF;
	const COLOR_LEGENDARY = 0xFFFF00;
	const COLOR_MYTHIC    = 0x00FFFF;
	const COLOR_UNIQUE    = 0xFF0000;

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	// FOUND, RARITY. A single level.GetFieldInt call -- the simplest read
	// of the four mods surveyed, since Doomablo already stores this the
	// same way RS_Main does.
	static bool, int RarityOf(Weapon w)
	{
		int rarity;
		if (!w || cv("wr_dbl_compat", 1.0) <= 0.0) return false, 0;
		if (!level.GetFieldInt(w, "generatedRarity", rarity)) return false, 0;

		// Range-checked against the seven tiers this file actually knows
		// about (README lists six; adding_new_uniques.txt's Unique is the
		// seventh, see the file header). RarityWord()/RarityColor()'s own
		// switches fall through anything unrecognized to COMMON/white with
		// no other signal -- so an unranged value here reads to the player
		// as a confident "this is Common", indistinguishable from a
		// genuine Common roll, rather than as what it actually is: a tier
		// number this file was never taught. A future Doomablo release
		// adding an 8th tier should show as unreadable, the same honest
		// "false" every other unrecognized read in this file already
		// returns, not as its own lowest rarity.
		if (rarity < DBL_COMMON || rarity > DBL_UNIQUE) return false, 0;

		return true, rarity;
	}

	static string RarityWord(int r)
	{
		switch (r)
		{
			case DBL_UNIQUE:    return "UNIQUE";
			case DBL_MYTHIC:    return "MYTHIC";
			case DBL_LEGENDARY: return "LEGENDARY";
			case DBL_EPIC:      return "EPIC";
			case DBL_RARE:      return "RARE";
			case DBL_UNCOMMON:  return "UNCOMMON";
		}
		return "COMMON";
	}

	static color RarityColor(int r)
	{
		switch (r)
		{
			case DBL_UNIQUE:    return color(COLOR_UNIQUE);
			case DBL_MYTHIC:    return color(COLOR_MYTHIC);
			case DBL_LEGENDARY: return color(COLOR_LEGENDARY);
			case DBL_EPIC:      return color(COLOR_EPIC);
			case DBL_RARE:      return color(COLOR_RARE);
			case DBL_UNCOMMON:  return color(COLOR_UNCOMMON);
		}
		return color(COLOR_COMMON);
	}

	// Same (bool, color) shape as rsTierLookup() / the other two compat
	// files' TierOf(), so all four drop into cardColorFor()/tierColorOf()'s
	// call chain identically.
	static bool, color TierOf(Weapon w)
	{
		bool found; int rarity;
		[found, rarity] = RarityOf(w);
		color none;
		if (!found) return false, none;
		return true, RarityColor(rarity);
	}

	//==========================================================================
	// PLAYER ADVANCEMENT. Doomablo's own README calls this out directly:
	// "Player experience levels and upgradable player stats" -- a second,
	// PLAYER-side axis entirely independent of the weapon's own rarity.
	//
	// TWO-HOP REFLECTION -- new in this file, not needed anywhere else in
	// this mod. currentExpLevel/currentExperience are plain fields, but
	// they live on RwPlayerStats (zscript/player/player_stats/
	// player_stats.zs), a bare Object -- not an Actor -- reached through a
	// `RwPlayerStats stats;` field on RwPlayer (zscript/player/
	// base_player.zs, the actual player-pawn class). So this is
	// GetFieldObject(owner, "stats", ...) to get that object, THEN
	// GetFieldInt/Float on the result -- one extra indirection field
	// reflection handles the same way regardless of depth, since the
	// natives take a plain Object, not specifically an Actor.
	//
	// XP-TO-NEXT-LEVEL IS COMPUTED, NOT READ. getRequiredXPForNextLevel()
	// is a method, unreachable the same way Affix.getName() is (see the
	// file header) -- but unlike an affix name, its underlying function
	// (getRequiredXPForLevel, experience.zs) is `clearscope static` with a
	// small closed-form formula and no hidden state, so it is reproduced
	// here rather than needing to be called. If Doomablo ever changes the
	// curve, this drifts out of sync silently -- there is no way to detect
	// that without calling the real method, which remains impossible.
	const XP_EXPONENT_BASE   = 1.25;
	const XP_MULT_EVERY      = 7.0;
	const XP_BASE_AMOUNT     = 300.0;
	const XP_ADD_PER_LEVEL   = 200.0;

	private static double xpForLevel(int lvl)
	{
		lvl -= 2;
		if (lvl < 0) return 1.0;
		double addition = double(lvl) * XP_ADD_PER_LEVEL;
		return double(int((XP_BASE_AMOUNT + addition) * (XP_EXPONENT_BASE ** (double(lvl) / XP_MULT_EVERY))));
	}

	// FOUND, LEVEL, CURRENT XP, XP TO NEXT, UNSPENT POINTS.
	static bool, int, double, double, int LevelOf(Weapon w)
	{
		int none4; double noneD; int none2;
		if (!w || !w.Owner || cv("wr_dbl_compat", 1.0) <= 0.0) return false, 0, 0.0, 0.0, 0;

		Object stats;
		if (!level.GetFieldObject(w.Owner, "stats", stats) || stats == null)
			return false, 0, 0.0, 0.0, 0;

		int lvl; double xp; int points;
		if (!level.GetFieldInt(stats, "currentExpLevel", lvl)) return false, 0, 0.0, 0.0, 0;
		level.GetFieldFloat(stats, "currentExperience", xp);
		level.GetFieldInt(stats, "statPointsAvailable", points);

		return true, lvl, xp, xpForLevel(lvl + 1), points;
	}

	// FOUND, INFERNO LEVEL. Doomablo's own "Game Level" -- scales monster
	// difficulty AND loot quality together, so it's the single number that
	// answers "how dangerous and how rewarding is this run right now".
	// Plain field, directly on RwPlayer -- no nested object needed for
	// this one.
	static bool, int InfernoLevelOf(Weapon w)
	{
		int inferno;
		if (!w || !w.Owner || cv("wr_dbl_compat", 1.0) <= 0.0) return false, 0;
		if (!level.GetFieldInt(w.Owner, "infernoLevel", inferno)) return false, 0;
		return true, inferno;
	}

	// FIVE ROLLED PLAYER STATS -- Vitality/CritChance/CritDmg/Strength/
	// RareFind. currentStats[totalStatsCount] on RwPlayerStats
	// (player_stats.zs) is a fixed int array (base stat + every item
	// bonus already applied), which GetFieldInt correctly refused --
	// unblocked this session by GetFieldIntArray (FORK_CHANGES.md #40),
	// added specifically because this array and BorderDoom's equipped-item
	// arrays hit the identical wall in the same pass. Same two-hop shape
	// as LevelOf(): GetFieldObject for the nested RwPlayerStats, then
	// GetFieldIntArray on the result.
	//
	// Only the five NON-HIDDEN stats (RwPlayerStats.nonHiddenStatsCount,
	// player_stats.zs) -- the two beyond that (ReloadSpeedBonus,
	// RateOfFireBonus) are the mod's own "not in any menus, given only by
	// items" pair, so the sheet respects the same visibility split
	// Doomablo's own UI already draws rather than showing the player
	// numbers their own menus deliberately hide.
	const STAT_VITALITY    = 0;
	const STAT_CRITCHANCE  = 1;
	const STAT_CRITDMG     = 2;
	const STAT_STRENGTH    = 3;
	const STAT_RAREFIND    = 4;

	static bool, int, int, int, int, int StatsOf(Weapon w)
	{
		int none;
		if (!w || !w.Owner || cv("wr_dbl_compat", 1.0) <= 0.0) return false, 0, 0, 0, 0, 0;

		Object stats;
		if (!level.GetFieldObject(w.Owner, "stats", stats) || stats == null)
			return false, 0, 0, 0, 0, 0;

		int vit, crc, crd, str, rf;
		bool got = level.GetFieldIntArray(stats, "currentStats", STAT_VITALITY, vit);
		level.GetFieldIntArray(stats, "currentStats", STAT_CRITCHANCE, crc);
		level.GetFieldIntArray(stats, "currentStats", STAT_CRITDMG,    crd);
		level.GetFieldIntArray(stats, "currentStats", STAT_STRENGTH,   str);
		level.GetFieldIntArray(stats, "currentStats", STAT_RAREFIND,   rf);
		if (!got) return false, 0, 0, 0, 0, 0;

		return true, vit, crc, crd, str, rf;
	}
}
