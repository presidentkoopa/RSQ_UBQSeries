// MODELSWAPPER COMPATIBILITY.
//
// Unlike every other wr_compat_*.zs file, this one is not reading a
// third-party mod at arm's length -- ModelSwapper is ours, same author,
// same "RS_" family. So instead of the usual field-only, zero-coordination
// treatment, ModelSwapper's own RS_ForeignModelHandler publishes a small
// BRIDGE of plain fields specifically for this (see the "THE WHEEL BRIDGE"
// block in its zscript/RS_ForeignModels.zs), refreshed once per tic.
//
// It is still read purely by NAME, through this fork's own reflection
// natives, and this file still has NO compile-time reference to any
// ModelSwapper class anywhere. That is deliberate even though we own both
// sides: a real class reference would make RS_WeaponWheel fail to compile
// for the (overwhelming majority of) players who never install
// ModelSwapper at all, and load-order would decide whether it worked even
// for players who do. Reflection degrades to a clean "not found" instead.
//
// THE ONE GENUINE EXCEPTION to "read-only, no side effects" anywhere in
// this mod's whole compat layer: cycling the model actually needs
// ModelSwapper to DO something (rebind the mesh, persist the pick), and
// method calls aren't reflectable. So this writes an int into a cvar
// ModelSwapper's own tick already watches and clears -- rs_fm_bridge_cmd_
// main/off, declared in ITS cvarinfo, not ours, found here purely by name
// the same way everything else in this file is. Safe if ModelSwapper is
// not loaded: nothing is listening, the write is inert.
class wr_CompatModelSwapper
{
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active()
	{
		return cv("wr_ms_compat", 1.0) > 0.0;
	}

	// StaticEventHandler.Find() takes a Class<StaticEventHandler>, not a
	// bare string -- a plain string literal gets coerced to a class token
	// AT COMPILE TIME, which is a genuine compile-time reference and fails
	// this file's own build the moment ModelSwapper is not loaded (caught
	// building this exact file: "Unknown class name 'RS_ForeignModelHandler'"
	// the instant it was checked standalone). Object.FindClass(string) is
	// the real runtime lookup -- null, not an error, when the class does
	// not exist anywhere in the current load -- so the class token has to
	// be resolved that way first and downcast afterward, same two-step
	// wr_compat_drla.zs already uses for exactly this reason.
	private static Object handler()
	{
		if (!active()) return null;
		let cls = (class<StaticEventHandler>)(Object.FindClass("RS_ForeignModelHandler"));
		if (!cls) return null;
		return StaticEventHandler.Find(cls);
	}

	// hand: 0 = main, 1 = off. Matches this wheel's own convention
	// (mInspectHand, preferredToggleHand) rather than ModelSwapper's
	// internal PSP_WEAPON/PSP_OFFHANDWEAPON layer constants, which this
	// file never needs to know about.
	//
	// FOUND (that hand currently has a bridged weapon), ARCHETYPE, PICK
	// (0-based), COUNT (models on that archetype's shelf), DONOR (the
	// currently-bound donor class name, cleaned for display).
	static bool, string, int, int, string StateOf(int hand)
	{
		let h = handler();
		if (!h) return false, "", 0, 0, "";

		string hasField  = (hand == 1) ? "mBridgeHasOff"   : "mBridgeHasMain";
		string archField = (hand == 1) ? "mBridgeArcheOff" : "mBridgeArcheMain";
		string pickField = (hand == 1) ? "mBridgePickOff"  : "mBridgePickMain";
		string cntField  = (hand == 1) ? "mBridgeCountOff" : "mBridgeCountMain";
		string donField  = (hand == 1) ? "mBridgeDonorOff" : "mBridgeDonorMain";

		int hasI;
		if (!level.GetFieldBool(h, hasField, hasI) || hasI == 0) return false, "", 0, 0, "";

		string arche = ""; level.GetFieldString(h, archField, arche);
		int pick = 0;      level.GetFieldInt(h, pickField, pick);
		int cnt = 0;       level.GetFieldInt(h, cntField, cnt);
		string donor = ""; level.GetFieldString(h, donField, donor);

		if (cnt <= 0) return false, "", 0, 0, "";
		return true, arche, pick, cnt, CleanDonor(donor);
	}

	// Donor class names are ModelSwapper's own internal shelf identifiers
	// (RS_GH_Pistol, VR_Revolver, MS_BD_SSG...) rather than anything meant
	// for a player to read. Stripping the family prefix is a cosmetic
	// nicety, not a real name lookup -- there is no display-name table to
	// read (nothing on the shelf publishes one), and this file does not
	// invent one.
	private static string CleanDonor(string cls)
	{
		if (cls.Length() > 3 && cls.Mid(0, 3) == "RS_") return cls.Mid(3);
		if (cls.Length() > 3 && cls.Mid(0, 3) == "VR_") return cls.Mid(3);
		if (cls.Length() > 3 && cls.Mid(0, 3) == "MS_") return cls.Mid(3);
		return cls;
	}

	// ONE ROW OF THE SHELF, BY INDEX. ModelSwapper publishes the whole shelf
	// as a "|"-joined string per hand, because reflection reads FIELDS -- it
	// cannot call a per-row accessor, and a ZScript Array<string> is a type
	// it cannot index at all. So the list arrives whole and is split here.
	//
	// hand: 0 = main, 1 = off.
	static string NameAt(int hand, int index)
	{
		let h = handler();
		if (!h || index < 0) return "";

		string joined = "";
		if (!level.GetFieldString(h, (hand == 1) ? "mBridgeNamesOff" : "mBridgeNamesMain", joined))
			return "";
		if (joined.Length() == 0) return "";

		Array<string> rows;
		joined.Split(rows, "|");
		if (index >= rows.Size()) return "";
		return CleanDonor(rows[index]);
	}

	// THE ONE WRITE. dir is +1 or -1. ModelSwapper's own WorldTick consumes
	// this cvar and zeroes it same-tick, so there is nothing here to read
	// back -- the NEXT StateOf() call, one tic later, is the confirmation.
	static void Cycle(int hand, int dir)
	{
		if (!active()) return;
		string cvarName = (hand == 1) ? "rs_fm_bridge_cmd_off" : "rs_fm_bridge_cmd_main";
		let c = CVar.FindCVar(cvarName);
		if (c) c.SetInt(dir);
	}
}
