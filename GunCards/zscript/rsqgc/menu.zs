// RSQ Gun Cards -- the "Show Cards" row (menu pass, owner 11-04: labels honest about what they need).
// Choice 3 is the inspect pose: RSQ Accessibility's gesture reader (RSQG_Service) when it is loaded, else Gun Cards'
// own copy of it (gestcopy.zs, RSQGC_GCopyService; owner 11-05 "change": every mod works alone). Only if neither is
// found do the cards fall back to "When I Look" (card.zs Wanted: both answer -1, so Glance decides), and the row says so.
// Both are found by class name; nothing links to them.
class OptionMenuItemRSQGCShow : OptionMenuItemOption
{
	static bool HasGestures()
	{
		String n = "RSQG_Service";   // a variable, so the name is looked up when the menu draws, not at compile time
		Class<Object> c = n;
		if (c != null) return true;
		n = "RSQGC_GCopyService";    // Gun Cards' own copy of the reader
		c = n;
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
