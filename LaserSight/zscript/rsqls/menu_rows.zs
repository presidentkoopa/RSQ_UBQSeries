// RSQ Laser Sight's own menu rows (check 11-16 LS4 / LS6 / NEW-LS3): colour rows greyed while what they colour is not
// drawn, where one stock grey check (one cvar equal to one value) cannot say it.
//   RSQLSColorIf "Label", "cvar", "rule" [, "graycheck"]
//     rule "dot":    the dot's own colours, used only in Colour Mode 2 (Beam and Dot): grey in modes 0 and 1
//     rule "target": the target colour, drawn only with Target Lock AND Colour on Target on (Recolor, sight.zs)
class OptionMenuItemRSQLSColorIf : OptionMenuItemColorPicker
{
	String mRule;

	OptionMenuItemRSQLSColorIf Init(String label, Name command, String rule, CVar graycheck = null, int graycheckVal = 0)
	{
		Super.Init(label, command, graycheck, graycheckVal);
		mRule = rule;
		return self;
	}

	static bool On(Name n, bool d) { let cv = CVar.FindCVar(n); return cv ? cv.GetBool() : d; }

	override bool IsGrayed()
	{
		if (Super.IsGrayed()) return true;
		if (mRule ~== "dot")
		{
			let cv = CVar.FindCVar('rsqls_color_mode');
			return !cv || cv.GetInt() != 2;
		}
		if (mRule ~== "target")
			return !On('rsqls_lock', true) || !On('rsqls_target_recolor', false);
		return false;
	}
}
