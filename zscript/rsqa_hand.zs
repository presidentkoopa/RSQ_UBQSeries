// RSQ_Accessibility -- Handedness (rsqa_handed: 0 Follow QuestZDoom, 1 Right-Handed, 2 Left-Handed).
//
// WHICH CONTROLLER IS THE MAIN HAND IS THE ENGINE'S, and only the engine's. QZD 17.3 reads
// vr_control_scheme (< 10 right-handed; 10 "Left-Handed (A)", 11 "Left-Handed (B)", menudef.txt
// ControlScheme) for: which physical controller writes AttackPos/AttackAngle/AttackPitch/AttackRoll
// and which writes the Offhand* set (gl_openvr.cpp getMainHandAngles / getOffHandAngles; on the
// Quest the same swap happens in VrInputDefault, measured on the rig: with the controllers posed as
// exact mirror images, scheme 0 and scheme 10 give the same two pose sets with MAIN and OFF traded,
// to 0.1 unit and 0.1 degree), which buttons fire which hand, which drawn weapon is reflected
// (hw_vrmodes.cpp GetWeaponTransform: the physical LEFT controller's weapon, unless NoAutoReverse)
// and which controller a weapon's own rumble goes to (p_map.cpp / p_mobj.cpp).
// A mod cannot move the main weapon to the other controller, so a Left-Handed setting that left the
// engine right-handed would put holsters, pockets and HUDs for a left-hander around a right-handed
// pair of hands. So choosing Right- or Left-Handed here ALSO sets QuestZDoom's Control Scheme
// (menus may set engine cvars: vmnatives.cpp CVar.SetInt allows it inside menu code), and the
// series mods read rsqa_handed only for body layout that no hand owns (the cigarette pocket, the
// way holstered guns hang, the Gun Bonsai HUD sides). Follow QuestZDoom leaves the engine alone.
//
// AND IF THE ENGINE WAS CHANGED SINCE: setting the Control Scheme in QuestZDoom's own menu after
// choosing here is the newer choice, so when the two disagree at start-up (an item's Init runs when
// MENUDEF is read, after the ini: rig, ini rsqa_handed=2 + vr_control_scheme=10 stays 2, ini
// rsqa_handed=2 + vr_control_scheme=0 comes up 0), Handedness goes back to Follow QuestZDoom.
// Only at start-up: rsqa_handed is a SERVER cvar, so a change made in a game lands a tic later (the
// value read back straight after SetSelection is still the old one, measured), and a check on every
// draw would see the engine already switched and the setting not yet, and undo the choice.
//
// WHICH LEFT-HANDED SCHEME. QuestZDoom has two (10 "Left-Handed (A)", 11 "Left-Handed (B)": the same
// hands, different button layouts). Right-Handed writes 0, so the left one in use is kept in
// rsqa_left_scheme first (whenever the engine is on 10 or 11: at start-up, and before every change
// made here), and Left-Handed puts that one back. Before, Left always wrote 10: a player on B who
// chose Right and then Left came back on A.

class OptionMenuItemRSQAHanded : OptionMenuItemOption
{
	OptionMenuItemRSQAHanded Init(String label, Name command, Name values)
	{
		Super.Init(label, command, values);
		Reconcile();
		return self;
	}

	void Reconcile()
	{
		RememberLeft();
		if (!mCVar) return;
		int h = mCVar.GetInt();
		if ((h == 1 || h == 2) && (h == 2) != RSQA_Hand.EngineLeft()) mCVar.SetInt(0);
	}

	override void SetSelection(int Selection)
	{
		Super.SetSelection(Selection);
		let cs = CVar.FindCVar("vr_control_scheme");
		if (!cs || Selection < 0 || Selection >= OptionValues.GetCount(mValues)) return;
		// the value chosen, not mCVar's: a server cvar changed in a game is applied a tic later
		int h = int(OptionValues.GetValue(mValues, Selection));
		RememberLeft();
		if (h == 1 && cs.GetInt() >= 10) cs.SetInt(0);
		else if (h == 2 && cs.GetInt() < 10) cs.SetInt(LeftScheme());
	}

	// the engine's left-handed scheme now, kept for the way back
	static void RememberLeft()
	{
		let cs = CVar.FindCVar("vr_control_scheme");
		let keep = CVar.FindCVar("rsqa_left_scheme");
		if (!cs || !keep) return;
		int v = cs.GetInt();
		if (v >= 10 && v != keep.GetInt()) keep.SetInt(v);
	}

	// the left-handed scheme to go back to: the last one in use, 10 when none was
	static int LeftScheme()
	{
		let keep = CVar.FindCVar("rsqa_left_scheme");
		int v = keep ? keep.GetInt() : 10;
		return (v == 10 || v == 11) ? v : 10;
	}
}

// For any mod that loads after this pk3 and wants the answer in one call. Series mods do NOT call
// this (it would be a hard link); each carries the same few lines and falls back to the engine.
class RSQA_Hand
{
	// the engine's main hand is the left controller
	static clearscope bool EngineLeft()
	{
		let cs = CVar.FindCVar("vr_control_scheme");
		return cs && cs.GetInt() >= 10;
	}
	// the body layout is a left-hander's: rsqa_handed if set, else the engine's
	static clearscope bool Left()
	{
		let h = CVar.FindCVar("rsqa_handed");
		int v = h ? h.GetInt() : 0;
		if (v == 1) return false;
		if (v == 2) return true;
		return EngineLeft();
	}
}
