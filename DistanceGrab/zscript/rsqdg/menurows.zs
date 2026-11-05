// RSQ Distance Grab's own menu row (MENUDEF): a key binding row drawn greyed while the cvar it needs is off. The grab
// keys (+rsqdg_main / +rsqdg_off) are only read with "Grab Keys" (rsqdg_button) on (0.99a bug 14); greyed, the row can
// still be bound, so a key can be set before the switch is turned on.
//   RSQDGKey "Main Hand Key", "+rsqdg_main", "rsqdg_button"

class OptionMenuItemRSQDGKey : OptionMenuItemControl
{
	CVar mNeed;

	OptionMenuItemRSQDGKey Init(String label, Name command, String need)
	{
		Super.Init(label, command);
		mNeed = CVar.FindCVar(need);
		return self;
	}

	override bool IsGrayed() { return mNeed && !mNeed.GetBool(); }

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		bool g = IsGrayed();
		drawLabel(indent, y, mWaiting ? OptionMenuSettings.mFontColorHighlight :
			(selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor), g);
		Array<int> keys;
		mBindings.GetAllKeysForCommand(keys, mAction);
		String description = KeyBindings.NameAllKeys(keys);
		if (description.Length() > 0) drawValue(indent, y, Font.CR_WHITE, description, g);
		else drawValue(indent, y, Font.CR_BLACK, "---", g);
		return indent;
	}
}
