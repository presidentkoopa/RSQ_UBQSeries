// RSQ SlowMo -- BE QUICK OR BE DEAD on the menu (owner 2026-11-07 06:31, built 11-10): DOWN's player-facing name as the
// header of its section, with the same letters breathing as on the plate (downhud.zs BreathOf: the Q, the K and both
// D's of DEAD). Each letter keeps its place; only its size breathes about its middle. Still in Photosensitive Mode.
class OptionMenuItemRSQSMBreathTitle : OptionMenuItem
{
	OptionMenuItemRSQSMBreathTitle Init(String label)
	{
		Super.Init(label, 'None', true);
		return self;
	}

	override bool Selectable() { return false; }

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		String t = StringTable.Localize(mLabel);
		Font f = Menu.OptionFont();
		if (!f) return indent;
		double w = f.StringWidth(t) * CleanXfac_1;
		double x = (Screen.GetWidth() - w) * 0.5;
		double fh = f.GetHeight() * CleanYfac_1;
		bool calm = RSQSM_A11y.Photo();
		double secs = MSTime() / 1000.0;
		int col = OptionMenuSettings.mFontColorHeader;
		for (int k = 0; k < int(t.Length()); k++)
		{
			String ch = t.Mid(k, 1);
			double cw = f.StringWidth(ch) * CleanXfac_1;
			double b = calm ? 1.0 : RSQSM_DownHud.BreathOf(k, secs);
			if (ch != " ")
				Screen.DrawText(f, col, x + cw * 0.5 - cw * b * 0.5, y + fh * 0.5 - fh * b * 0.5, ch,
					DTA_ScaleX, CleanXfac_1 * b, DTA_ScaleY, CleanYfac_1 * b);
			x += cw;
		}
		return indent;
	}
}
