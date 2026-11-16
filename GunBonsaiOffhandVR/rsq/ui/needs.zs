// ROWS THAT NEED ANOTHER MOD (11-16 bugfix GB9): an Option or Slider row of this page that does nothing unless another
// mod is loaded is greyed (and cannot be picked) without it, as the series' Gun Bonsai rows grey a locked feature. The
// mod is found by a class name it defines (by name: nothing links), or "legendoom" for LegenDoom (Gun Bonsai's own test).
//   RSQGBNeedsOption "Label", "cvar", "Values", "ClassName"
//   RSQGBNeedsSlider "Label", "cvar", min, max, step, prec, "ClassName"
// Reset All still resets them (they are Option and Slider rows).
class RSQGB_Needs ui
{
	static bool Loaded(String need)
	{
		if (need == "") return true;
		if (need ~== "legendoom") return TFLV_Settings.have_legendoom();
		class<Object> c = need;
		return c != null;
	}
}

class OptionMenuItemRSQGBNeedsOption : OptionMenuItemOption
{
	String mNeed;

	OptionMenuItemRSQGBNeedsOption Init(String label, Name command, Name values, String need)
	{
		Super.Init(label, command, values);
		mNeed = need;
		return self;
	}

	override bool IsGrayed() { return Super.IsGrayed() || !RSQGB_Needs.Loaded(mNeed); }
}

class OptionMenuItemRSQGBNeedsSlider : OptionMenuItemSlider
{
	String mNeed;

	OptionMenuItemRSQGBNeedsSlider Init(String label, Name command, double min, double max, double step, int showval, String need)
	{
		Super.Init(label, command, min, max, step, showval);
		mNeed = need;
		return self;
	}

	override bool IsGrayed() { return Super.IsGrayed() || !RSQGB_Needs.Loaded(mNeed); }
}
