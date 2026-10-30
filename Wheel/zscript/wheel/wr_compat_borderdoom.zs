// BORDERDOOM COMPATIBILITY.
//
// The real per-shot stats (damage, accuracy, firerate, recoil, clip size)
// are NOT read from CallACS("GetCurrentDamage") and friends -- those were
// hand-decompiled this session and PROVEN to strip and regrant the
// weapon's ammo capacity as normal, non-error-path execution every time
// they're called (see project memory: BorderDoom's ACS, function 3).
// Calling them from the wheel's own passive sheet-rebuild would desync a
// player's ammo just from pointing the wheel at a gun. Not attempted here,
// and should not be -- that finding doesn't change until BorderDoom's own
// ACS changes.
//
// What's actually read instead: the CACHED array values those ACS
// functions write INTO as a side effect of their own resync work.
// user_equippedDamage[MAX_EQUIPPED_ITEMS] (and its five siblings) are
// plain `var int` arrays declared directly on the player pawn
// (decorate_/bd_player.txt) -- genuinely safe, zero-side-effect reads,
// using the new Level.GetFieldIntArray native (FORK_CHANGES.md #40, added
// this session specifically because BorderDoom and Doomablo both hit the
// same "GetFieldInt refuses arrays" wall). The tradeoff: this can be one
// resync cycle stale rather than truly live, since nothing here forces a
// fresh recompute -- an acceptable trade for "never corrupts your ammo".
//
// THE INDEX PROBLEM. MAX_EQUIPPED_ITEMS is 3, not one slot per weapon
// type -- these arrays are keyed by WHICH of your (up to three) currently
// carried weapons this is, assigned in pickup order, not by weapon type.
// So which index belongs to the HELD weapon has to be found at runtime:
// user_equippedItemType[MAX_EQUIPPED_ITEMS] holds each slot's ItemType_*
// constant (decorate_/pickup_base.txt: Pistol=1, Shotgun=2, SMG=3,
// Rifle=4, RocketLauncher=5, DemonStaff=6) -- so this reads all three
// type-slots, compares against the constant the held weapon's OWN class
// name maps to, and uses the first matching index for every other array.
// Every one of these reads is the safe array-element native; nothing here
// calls ACS.
class wr_CompatBorderDoom
{
	const MAX_EQUIPPED = 3;

	const ITEM_PISTOL         = 1;
	const ITEM_SHOTGUN        = 2;
	const ITEM_SMG            = 3;
	const ITEM_RIFLE          = 4;
	const ITEM_ROCKETLAUNCHER = 5;
	const ITEM_DEMONSTAFF     = 6;

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	// Compile-time-known mapping from THIS wheel's held-weapon class name
	// to BorderDoom's own ItemType_* constant -- no runtime lookup needed
	// for this half, since the class names are fixed and small in number.
	private static int itemTypeFor(Weapon w)
	{
		string cls = "" .. w.GetClassName();
		if (cls == "RealPistol")         return ITEM_PISTOL;
		if (cls == "RealShotgun")        return ITEM_SHOTGUN;
		if (cls == "RealSMG")            return ITEM_SMG;
		if (cls == "RealRifle")          return ITEM_RIFLE;
		if (cls == "RealRocketLauncher") return ITEM_ROCKETLAUNCHER;
		if (cls == "RealDemonStaff")     return ITEM_DEMONSTAFF;
		return 0;
	}

	// Which of the three equipped-item slots the held weapon occupies, or
	// -1 if none match (e.g. holding something BorderDoom itself doesn't
	// track this way).
	private static int slotIndexFor(Weapon w)
	{
		int want = itemTypeFor(w);
		if (want == 0 || w.Owner == null) return -1;

		for (int i = 0; i < MAX_EQUIPPED; ++i)
		{
			int got;
			if (level.GetFieldIntArray(w.Owner, "user_equippedItemType", i, got) && got == want)
				return i;
		}
		return -1;
	}

	// FOUND, DAMAGE, ACCURACY, FIRERATE, RECOIL, CLIP SIZE, LEVEL. One
	// combined read rather than six separate functions, since every value
	// shares the same slot-index lookup and there is no reason to repeat
	// it six times per sheet rebuild.
	static bool, int, int, int, int, int, int StatsOf(Weapon w)
	{
		int none;
		if (!w || cv("wr_bd_compat", 1.0) <= 0.0) return false, 0, 0, 0, 0, 0, 0;

		int idx = slotIndexFor(w);
		if (idx < 0) return false, 0, 0, 0, 0, 0, 0;

		int dmg, acc, rof, rcl, clip, lvl;
		level.GetFieldIntArray(w.Owner, "user_equippedDamage",    idx, dmg);
		level.GetFieldIntArray(w.Owner, "user_equippedAccuracy",  idx, acc);
		level.GetFieldIntArray(w.Owner, "user_equippedFirerate",  idx, rof);
		level.GetFieldIntArray(w.Owner, "user_equippedRecoil",    idx, rcl);
		level.GetFieldIntArray(w.Owner, "user_equippedClipSize",  idx, clip);
		level.GetFieldIntArray(w.Owner, "user_equippedLevel",     idx, lvl);

		return true, dmg, acc, rof, rcl, clip, lvl;
	}
}
