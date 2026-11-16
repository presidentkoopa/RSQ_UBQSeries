// RSQ Glow In The Dark -- menu rows that read the profile table (so a new profile needs no MENUDEF edit).

// "Profile": left/right (or a click) steps through RSQGD_Profiles.ROWS by name.
// namedOnly (Colours From, GD5 2026-11-16): only the named profiles (Custom and Random Profile are not a palette; both read
// as Classic there). cond: greyed while it holds (RSQGD_Cond).
class OptionMenuItemRSQGDProfile : OptionMenuItem
{
	CVar mCVar;
	int mFirst;
	RSQGD_Cond mCond;

	OptionMenuItemRSQGDProfile Init(String label, Name cv, int namedOnly = 0, String cond = "")
	{
		Super.Init(label, cv);
		mCVar = CVar.FindCVar(cv);
		mFirst = namedOnly ? RSQGD_Profiles.FIRST_NAMED : 0;
		mCond = RSQGD_Cond.Make(cond);
		return self;
	}

	override bool IsGrayed() { return mCond && mCond.Holds(); }
	override bool Selectable() { return !IsGrayed(); }

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor, IsGrayed());
		int v = mCVar ? mCVar.GetInt() : 2;
		drawValue(indent, y, OptionMenuSettings.mFontColorValue, RSQGD_Profiles.NameOf(max(v, mFirst)), IsGrayed(), false);
		return indent;
	}

	void Step(int d)
	{
		if (!mCVar) return;
		int n = RSQGD_Profiles.Count() - mFirst;
		int v = max(mCVar.GetInt(), mFirst) - mFirst;
		mCVar.SetInt(mFirst + (v + d + n) % n);
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

	// greyed for Random Profile and Custom too (GD6 / NEW-GD-A, 2026-11-16): neither has one pairing (Custom's table row has
	// none: it switched the darkness off, ddz_mode 0, with no word)
	override bool IsGrayed()
	{
		if (!CVar.FindCVar("ddz_mode")) return true;
		let pc = CVar.FindCVar("rsqgd_profile");
		return pc && pc.GetInt() < RSQGD_Profiles.FIRST_NAMED;
	}
	override bool Selectable() { return !IsGrayed(); }

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
		if (p < RSQGD_Profiles.FIRST_NAMED) return false;   // Custom, Random Profile: no single pairing (GD6 / NEW-GD-A)
		m.SetInt(RSQGD_Profiles.Field(p, 12).ToInt());
		pr.SetInt(RSQGD_Profiles.Field(p, 13).ToInt());
		Menu.MenuSound("menu/choose");
		return true;
	}
}

// ---- GREYED WHILE A CONDITION HOLDS (GD14, 2026-11-16) ----------------------------------------------------------------
// A row that does nothing in the current setup is greyed: cond is "cvar==n" or "cvar!=n" terms joined by "|" (greyed when ANY
// holds), e.g. "rsqgd_profile!=0" (the Custom Profile rows), "rsqgd_mb==0|rsqgd_mb_colour!=2" (Custom Tint).
class RSQGD_Cond ui
{
	Array<String> cv;
	Array<int> val;
	Array<bool> ne;

	static RSQGD_Cond Make(String cond)
	{
		if (cond == "") return null;
		let c = new("RSQGD_Cond");
		Array<String> terms;
		cond.Split(terms, "|", TOK_SKIPEMPTY);
		for (int i = 0; i < terms.Size(); i++)
		{
			String t = terms[i];
			int at = t.IndexOf("!=");
			bool isNe = at >= 0;
			if (!isNe) at = t.IndexOf("==");
			if (at < 0) continue;
			c.cv.Push(t.Left(at));
			c.val.Push(t.Mid(at + 2).ToInt());
			c.ne.Push(isNe);
		}
		return c;
	}

	bool Holds()
	{
		for (int i = 0; i < cv.Size(); i++)
		{
			let c = CVar.FindCVar(cv[i]);
			if (!c) continue;
			bool eq = c.GetInt() == val[i];
			if (ne[i] ? !eq : eq) return true;
		}
		return false;
	}
}

class OptionMenuItemRSQGDCSlider : OptionMenuItemSlider
{
	RSQGD_Cond mCond;
	OptionMenuItemRSQGDCSlider Init(String label, Name command, double min, double max, double step, int showval, String cond)
	{
		Super.Init(label, command, min, max, step, showval);
		mCond = RSQGD_Cond.Make(cond);
		return self;
	}
	override bool IsGrayed() { return Super.IsGrayed() || (mCond && mCond.Holds()); }
}

class OptionMenuItemRSQGDCOption : OptionMenuItemOption
{
	RSQGD_Cond mCond;
	OptionMenuItemRSQGDCOption Init(String label, Name command, Name values, String cond)
	{
		Super.Init(label, command, values);
		mCond = RSQGD_Cond.Make(cond);
		return self;
	}
	override bool IsGrayed() { return Super.IsGrayed() || (mCond && mCond.Holds()); }
}

class OptionMenuItemRSQGDCColor : OptionMenuItemColorPicker
{
	RSQGD_Cond mCond;
	OptionMenuItemRSQGDCColor Init(String label, Name command, String cond)
	{
		Super.Init(label, command);
		mCond = RSQGD_Cond.Make(cond);
		return self;
	}
	override bool IsGrayed() { return Super.IsGrayed() || (mCond && mCond.Holds()); }
	override bool Selectable() { return !IsGrayed(); }
}
