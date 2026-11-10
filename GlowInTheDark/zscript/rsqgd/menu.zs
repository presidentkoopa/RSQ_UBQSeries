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

// "Use DarkDoomZ Pairing": sets the built-in DarkDoomZ's Mode and Preset to the chosen profile's pairing; DarkDoomZ
// applies them itself.
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
