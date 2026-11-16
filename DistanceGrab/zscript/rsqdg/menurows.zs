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

// DUCK UNDER DOORS (C3, 2026-11-16): the dip under a lower ceiling acts on the Steer and Lob pulls and on Barrel Lock-On's
// steered barrel (flight.zs Duck, lockon.zs); the default Arc pull plans its own arc under the route's lowest ceiling at
// launch and never asks it. So the row greys when it can do nothing: Flight Path Arc (2) with Barrel Lock-On off.
class OptionMenuItemRSQDGDuck : OptionMenuItemOption
{
	OptionMenuItemRSQDGDuck Init(String label, Name command, Name values)
	{
		Super.Init(label, command, values);
		return self;
	}
	override bool IsGrayed()
	{
		let fm = CVar.FindCVar("rsqdg_flight_mode");
		let lk = CVar.FindCVar("rsqdg_lockon");
		return (!fm || fm.GetInt() == 2) && (lk && !lk.GetBool());
	}
}
