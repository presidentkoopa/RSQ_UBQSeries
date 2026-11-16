// ============================================================================
// RSQ_Miniboss -- two menu rows of its own (2026-11-16 bug check E: MB7, MB8, NEW-MB-B). The series' shared rows are in
// rsmenu.zs (generated from tools/rsmenu: not edited here).
// ============================================================================

// SLOW DEPTH (rsqmb_slow_depth): 0 or below is RSQ SlowMo's own depth (rsm_depth; handler.zs Refresh treats dp <= 0 so), shown
// in words; above it, 5..90 in steps of 5 on the step grid. A plain Slider from -1 stepped -1, 4, 9 ... 89, 90 (4 read as 5).
// The saved default -1 is left as it ships: it reads "SlowMo's" and the first step right is 5.
class OptionMenuItemRSQMBDepthSlider : OptionMenuItemSlider
{
	String mZero;

	OptionMenuItemRSQMBDepthSlider Init(String label, Name command, double min, double max, double step, int showval, String zero)
	{
		Super.Init(label, command, min, max, step, showval);
		mZero = zero;
		return self;
	}

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		if (GetSliderValue() > 0) return Super.Draw(desc, y, indent, selected);
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor, IsGrayed());
		drawValue(indent, y, OptionMenuSettings.mFontColorValue, mZero, IsGrayed());
		return indent;
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey != Menu.MKEY_Left && mkey != Menu.MKEY_Right) return Super.MenuEvent(mkey, fromcontroller);
		double st = max(1.0, mStep);
		double v = round(max(0.0, GetSliderValue()) / st) * st;
		v += (mkey == Menu.MKEY_Right) ? st : -st;
		SetSliderValue(clamp(v, max(0.0, mMin), mMax));
		Menu.MenuSound("menu/change");
		return true;
	}

}

// GRAVES RADIUS (rsqmb_bf_graves_radius): used only by the two "Within Radius" modes (bossfight.zs Graves: mode 1 or 3), and only
// with Graves Rise on: greyed otherwise.
class OptionMenuItemRSQMBGraveRadius : OptionMenuItemSlider
{
	OptionMenuItemRSQMBGraveRadius Init(String label, Name command, double min, double max, double step, int showval)
	{
		Super.Init(label, command, min, max, step, showval);
		return self;
	}

	override bool IsGrayed()
	{
		let on = CVar.FindCVar("rsqmb_bf_graves"), md = CVar.FindCVar("rsqmb_bf_graves_mode");
		if (on && !on.GetBool()) return true;
		int m = md ? md.GetInt() : 0;
		return m != 1 && m != 3;
	}
}
