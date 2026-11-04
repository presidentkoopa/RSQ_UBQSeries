// RSQ Glow In The Dark -- menu rows that read the profile table (so a new profile needs no MENUDEF edit).

// "Profile": left/right (or a click) steps through RSQGD_Profiles.ROWS by name.
class OptionMenuItemRSQGDProfile : OptionMenuItem
{
	CVar mCVar;

	OptionMenuItemRSQGDProfile Init(String label, Name cv)
	{
		Super.Init(label, cv);
		mCVar = CVar.FindCVar(cv);
		return self;
	}

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor);
		int v = mCVar ? mCVar.GetInt() : 2;
		drawValue(indent, y, OptionMenuSettings.mFontColorValue, RSQGD_Profiles.NameOf(v), false, false);
		return indent;
	}

	void Step(int d)
	{
		if (!mCVar) return;
		int n = RSQGD_Profiles.Count();
		mCVar.SetInt((mCVar.GetInt() + d + n) % n);
		Menu.MenuSound("menu/change");
	}

	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey == Menu.MKEY_Left) { Step(-1); return true; }
		if (mkey == Menu.MKEY_Right) { Step(1); return true; }
		return Super.MenuEvent(mkey, fromcontroller);
	}

	override bool Activate()
	{
		Step(1);
		return true;
	}
}

// A line of text about the chosen profile: 0 its note, 1 its DarkDoomZ pairing.
class OptionMenuItemRSQGDNote : OptionMenuItemStaticText
{
	int mWhich;

	OptionMenuItemRSQGDNote Init(int which)
	{
		Super.Init("", Font.CR_DARKGRAY);
		mWhich = which;
		return self;
	}

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		let c = CVar.FindCVar("rsqgd_profile");
		int p = c ? c.GetInt() : 2;
		mLabel = mWhich == 0 ? RSQGD_Profiles.Field(p, 14) : RSQGD_Profiles.DdzText(p);
		if (mWhich == 1 && !CVar.FindCVar("ddz_mode")) mLabel = mLabel .. " (DarkDoomZ not loaded)";
		return Super.Draw(desc, y, indent, selected);
	}
}

// "Use This DarkDoomZ Pairing": sets DarkDoomZ's Mode and Preset to the chosen profile's pairing. Only when
// DarkDoomZ is loaded (its cvars exist); DarkDoomZ applies them itself.
class OptionMenuItemRSQGDPairing : OptionMenuItem
{
	OptionMenuItemRSQGDPairing Init(String label)
	{
		Super.Init(label, 'None');
		return self;
	}

	override bool IsGrayed() { return !CVar.FindCVar("ddz_mode"); }

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor, IsGrayed());
		return indent;
	}

	override bool Activate()
	{
		let m = CVar.FindCVar("ddz_mode"), pr = CVar.FindCVar("ddz_preset"), pc = CVar.FindCVar("rsqgd_profile");
		if (!m || !pr) return false;
		int p = pc ? pc.GetInt() : 2;
		if (p == 1) return false;            // Random Profile: no single pairing
		m.SetInt(RSQGD_Profiles.Field(p, 12).ToInt());
		pr.SetInt(RSQGD_Profiles.Field(p, 13).ToInt());
		Menu.MenuSound("menu/choose");
		return true;
	}
}
