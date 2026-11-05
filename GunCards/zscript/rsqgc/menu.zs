// RSQ Gun Cards -- the "Show Cards" row (menu pass, owner 11-04: labels honest about what they need).
// Choice 3 is RSQ Gestures' inspect pose. Without RSQ Gestures the cards fall back to "When I Look"
// (card.zs Wanted: Inspect() answers -1, so Glance decides), so the row says exactly that there.
// RSQ Gestures is found by its service class name; nothing links to it.
class OptionMenuItemRSQGCShow : OptionMenuItemOption
{
	static bool HasGestures()
	{
		String n = "RSQG_Service";   // a variable, so the name is looked up when the menu draws, not at compile time
		Class<Object> c = n;
		return c != null;
	}

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor, isGrayed());
		int sel = GetSelection();
		String text = StringTable.Localize(OptionValues.GetText(mValues, sel));
		if (OptionValues.GetValue(mValues, sel) == 3 && !HasGestures()) text = "When I Look (no Gestures)";
		if (text.Length() == 0) text = StringTable.Localize("$TXT_UNKNOWN");
		drawValue(indent, y, OptionMenuSettings.mFontColorValue, text, isGrayed());
		return indent;
	}
}
