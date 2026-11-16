// RSQ Graveyards (RSQ Edition) -- a menu row greyed while the mod it needs is not loaded (check 11-16 GY8: the Bones rows
// read live without Legion of Bones). GPLv3 like the rest of this folder.
//   RSQGYIfLoaded "Label", "cvar", "Values", "AClassOfThatMod" [, "graycheck"]
class OptionMenuItemRSQGYIfLoaded : OptionMenuItemOption
{
	Name mNeed;

	OptionMenuItemRSQGYIfLoaded Init(String label, Name command, Name values, String needClass, CVar graycheck = null, int graycheckVal = 0)
	{
		Super.Init(label, command, values, graycheck, 0, graycheckVal);
		mNeed = needClass;
		return self;
	}

	override bool IsGrayed()
	{
		if (Super.IsGrayed()) return true;
		class<Object> c = mNeed;
		return c == null;
	}
}
