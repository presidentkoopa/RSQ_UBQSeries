// RSQ Grapple's own menu rows (MENUDEF): a row greyed while the mode it belongs to is off, so the page says
// which rows only matter on the rope (0.99a bug 19) without any help text. The condition is a string of words,
// all of which must hold:
//   rope        the wall rope is in play: Wall Hook "Rope" (rsqgr_geo_mode 0) or Swing and Momentum on
//               (core.zs: the OG fling never makes a rope; Pull and Swing both run Climb, RopeSight, Mantle)
//   swing       Swing and Momentum on (core.zs SwingMode: the row, or Gun Bonsai VR's Momentum when learned)
//   cvar=a|b    that cvar holds one of those values (e.g. rsqgr_monster_mode=1|2)
// Greyed rows still keep their setting; they just do nothing until the mode is on.

class RSQGR_MenuWhen ui
{
	static bool Holds(String when)
	{
		if (when.Length() == 0) return true;
		Array<String> t;
		when.Split(t, " ", TOK_SKIPEMPTY);
		PlayerPawn pmo = (consoleplayer >= 0 && consoleplayer < MAXPLAYERS && playeringame[consoleplayer]) ? players[consoleplayer].mo : null;
		for (int i = 0; i < t.Size(); i++)
		{
			String w = t[i];
			if (w ~== "swing") { if (!RSQGR_Core.SwingMode(pmo)) return false; continue; }
			if (w ~== "rope")
			{
				if (RSQGR_Util.Opt("rsqgr_geo_mode", 1) != 0 && !RSQGR_Core.SwingMode(pmo)) return false;
				continue;
			}
			int eq = w.IndexOf("=");
			if (eq <= 0) continue;
			int v = RSQGR_Util.Opt(w.Left(eq), 0);
			Array<String> vals;
			w.Mid(eq + 1).Split(vals, "|", TOK_SKIPEMPTY);
			bool any = false;
			for (int k = 0; k < vals.Size(); k++) if (vals[k].ToInt() == v) { any = true; break; }
			if (!any) return false;
		}
		return true;
	}
}

// Option "Label", "cvar", "Values" -- greyed unless <when> holds
class OptionMenuItemRSQGRWhen : OptionMenuItemOption
{
	String mWhen;
	OptionMenuItemRSQGRWhen Init(String label, Name command, Name values, String when)
	{
		Super.Init(label, command, values);
		mWhen = when;
		return self;
	}
	override bool IsGrayed() { return Super.IsGrayed() || !RSQGR_MenuWhen.Holds(mWhen); }
}

// Slider "Label", "cvar", min, max, step, digits -- greyed unless <when> holds
class OptionMenuItemRSQGRWhenSlider : OptionMenuItemSlider
{
	String mWhen;
	OptionMenuItemRSQGRWhenSlider Init(String label, Name command, double lo, double hi, double step, int showval, String when)
	{
		Super.Init(label, command, lo, hi, step, showval);
		mWhen = when;
		return self;
	}
	override bool IsGrayed() { return Super.IsGrayed() || !RSQGR_MenuWhen.Holds(mWhen); }
}
