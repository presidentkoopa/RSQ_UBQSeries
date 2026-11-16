// RSQ Gun Cards -- a menu row of its own (2026-11-16 bug check E, GC2). The series' shared rows are rsmenu.zs (tools/rsmenu).

// An On/Off row for ANOTHER pack's cvar (Remove HUD Health and Armor, Remove HUD Ammo: rsq_hud_nohp / rsq_hud_noammo are BD22
// VR Reloaded's and GNRC's): greyed, and not selectable, when that cvar does not exist (its pack is not loaded), so the row
// never promises what nothing here can do.
class OptionMenuItemRSQGCOtherOption : OptionMenuItemOption
{
	OptionMenuItemRSQGCOtherOption Init(String label, Name command, Name values)
	{
		Super.Init(label, command, values);
		return self;
	}

	override bool IsGrayed() { return !CVar.FindCVar(mAction) || Super.IsGrayed(); }
}
