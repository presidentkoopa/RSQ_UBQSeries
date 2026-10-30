// GUNCASTER COMPATIBILITY.
//
// Guncaster has no per-weapon rarity or leveling at all -- checked directly
// against the weapon base class (GuncasterWeapon : Weapon), every custom
// field on it is animation/state-lock plumbing, nothing tracking kills, XP
// or a mastery rank. First pass over this mod concluded "nothing to build"
// on exactly that basis and was too narrow: Guncaster is class-based (one
// player class, "Cygnis"), and the PLAYER carries real, currently-tracked
// resource state a data card is exactly the right place to surface, even
// with no per-weapon axis to color a card by. So unlike
// wr_compat_legendoom.zs/drla.zs/doomablo.zs, this file never touches
// tierColorOf()/cardColorFor() -- purely supplementary sheet rows, the same
// shape wr_compat_pandemonium.zs already has for Insurrection.
//
// EVERY FIELD HERE LIVES ON THE PLAYER PAWN (class Guncaster : PlayerPawn,
// zscript/Guncaster.txt), not the weapon -- reached via w.Owner, a plain
// public field on Inventory. Reflection naturally scopes correctly here:
// GetFieldFloat/Int only succeeds if w.Owner's actual runtime class is
// Guncaster or a subclass, so nothing here needs its own "is this actually
// a Guncaster player" check beyond the field read itself succeeding.
class wr_CompatGuncaster
{
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active(Weapon w)
	{
		return w && w.Owner && cv("wr_gc_compat", 1.0) > 0.0;
	}

	// FOUND, SECONDS. spellDelay counts down in tics like every other
	// cooldown in this codebase reads; converted to seconds for the row
	// since "CD 35" reads as a shot count everywhere else on this sheet and
	// would be actively misleading here.
	static bool, double SpellCooldownOf(Weapon w)
	{
		double delay;
		if (!active(w) || !level.GetFieldFloat(w.Owner, "spellDelay", delay) || delay <= 0.0)
			return false, 0.0;
		return true, delay / 35.0;
	}

	// Ability resource pools -- each is situational (only meaningful while
	// that specific move/item is in play), so each is its own row and each
	// is independently gated on being non-zero rather than shown flat and
	// mostly empty. Short tags matching this sheet's existing all-caps
	// stat-label convention (COND, DPS, MAG, ...).
	private static string appendRes(Weapon w, string s, string field, string tag)
	{
		int n;
		if (!level.GetFieldInt(w.Owner, field, n) || n <= 0) return s;
		string t = String.Format("%s %d", tag, n);
		return s.Length() ? (s .. "  " .. t) : t;
	}

	static string ResourcesOf(Weapon w)
	{
		if (!active(w)) return "";

		string s = "";
		s = appendRes(w, s, "ChargeFuel",         "CHARGE");
		s = appendRes(w, s, "RocketHoverTics",     "HOVER");
		s = appendRes(w, s, "RocketGlideTics",     "GLIDE");
		s = appendRes(w, s, "StompCooldown",       "STOMP");
		s = appendRes(w, s, "draugh_curse_power",  "CURSE");
		return s;
	}
}
