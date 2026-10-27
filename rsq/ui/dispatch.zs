// THE DISPATCHER (10-27): how the skins get Gun Bonsai's screens.
//
//  In play   RSQUI_Handler (below) draws the skin; the shadowed EventHandler.zsc skips Gun
//            Bonsai's own HUD while rsq_ui_skin is 1..3 (a cvar read: that file compiles in Gun
//            Bonsai's ZSCRIPT lump, before this one, so it cannot name these classes).
//  Menus     Gun Bonsai opens its three screens by NAME -- Menu.SetMenu("GunBonsaiStatusDisplay")
//            in ShowInfo, AwaitChoice("GunBonsaiWeaponLevelUpMenu" / "...PlayerLevelUpMenu") in its
//            upgrade givers. This patch's MENUDEF redefines those three names to point at the
//            routers in router.zs, which open the skin's menu instead (or behave exactly as Gun
//            Bonsai's own when rsq_ui_skin is 0). No further Gun Bonsai file is shadowed for it:
//            the choice still goes back through bonsai-choose-level-up-option, Choose(index).
//  Hand      The status screen browses both guns. Gun Bonsai's toggle/tune netevents act on
//            PerPlayerStats.menuHand, so the skin sends rsqui-menu-hand (RSQUI_Handler) first.
//
// OTHER MODS' HUDS. While a skin draws:
//  * RS Score's own score line would sit beside ours, so its user cvar rs_score_hide is set, and
//    put back as it was (saved in rsq_ui_saved_scorehide) when rsq_ui_skin returns to 0.
//  * with rsq_ui_bottom on, the base game's fullscreen HUD would sit under our bottom row. Brutal
//    Doom's is chosen by its user cvar bd_sbartype; it is set to 0 (no fullscreen HUD) the same way
//    (saved in rsq_ui_saved_sbartype). Any other base HUD is left alone and drawn over.
//  Removing the patch while a skin is on leaves those two as they were set: put them back by hand
//  (rs_score_hide 0, bd_sbartype 1) or set rsq_ui_skin 0 once before removing it.
class RSQUI_Dispatch ui
{
	RSQUI_Skin skin;
	int skinIdx;
	bool made;

	static int SkinIndex()
	{
		let cv = CVar.FindCVar("rsq_ui_skin");
		return cv ? cv.GetInt() : 0;
	}

	static bool BottomOn()
	{
		let cv = CVar.FindCVar("rsq_ui_bottom");
		return SkinIndex() != 0 && cv && cv.GetBool();
	}

	RSQUI_Skin Current()
	{
		int k = SkinIndex();
		if (!made || k != skinIdx)
		{
			skin = RSQUI_Skin.Current();
			skinIdx = k;
			made = true;
		}
		return skin;
	}

	// From RenderOverlay. canDraw = the HUD is not hidden (screenblocks, automap).
	bool Draw(RenderEvent e, bool canDraw)
	{
		let sk = Current();
		if (houseTick-- <= 0) { houseTick = 17; Housekeep(sk != null); }
		if (!sk) return false;
		if (!canDraw) return true;
		return sk.DrawHud(e);
	}

	// ---- other mods' HUDs ----
	int scoreKnown;   // 0 unknown, 1 RS Score loaded, 2 not
	int houseTick;
	void Housekeep(bool active)
	{
		if (!scoreKnown) scoreKnown = RSQUI_Data.ScoreServiceLoaded() ? 1 : 2;
		// RS Score draws its own line, untouched: only put back a hide an older build set.
		Manage("rs_score_hide", "rsq_ui_saved_scorehide", false, 1);
		Manage("bd_sbartype", "rsq_ui_saved_sbartype", active && BottomOn(), 0);
	}

	static void Manage(String userVar, String saveVar, bool want, int hideVal)
	{
		// the local cvar (FindCVar): what the console shows, what is archived, and what reaches
		// userinfo. Setting the userinfo copy (GetCVar with a player) did not stick on the rig.
		let uc = CVar.FindCVar(userVar);
		let sv = CVar.FindCVar(saveVar);
		if (!uc || !sv) return;
		if (want)
		{
			if (sv.GetInt() == -1) sv.SetInt(uc.GetInt());
			if (uc.GetInt() != hideVal) uc.SetInt(hideVal);
		}
		else if (sv.GetInt() != -1)
		{
			uc.SetInt(sv.GetInt());
			sv.SetInt(-1);
		}
	}

	// The menu a skin wants in place of Gun Bonsai's (0 status, 1 weapon level-up, 2 player level-up).
	static Name MenuFor(int which)
	{
		let sk = RSQUI_Skin.Current();
		if (!sk) return 'None';
		if (which == 0) return sk.StatusMenu();
		if (which == 1) return sk.WeaponLevelUpMenu();
		return sk.PlayerLevelUpMenu();
	}
}

// The skins' own event handler (MAPINFO): the HUD, and the status screen's hand.
class RSQUI_Handler : StaticEventHandler
{
	ui RSQUI_Dispatch disp;

	override void RenderOverlay(RenderEvent e)
	{
		if (!disp) disp = new("RSQUI_Dispatch");
		bool canDraw = gamestate == GS_LEVEL && playeringame[consoleplayer] && players[consoleplayer].mo
			&& screenblocks <= 11 && !automapactive;
		disp.Draw(e, canDraw);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.name != "rsqui-menu-hand") return;
		let mo = players[e.player].mo;
		let st = mo ? TFLV_PerPlayerStats.GetStatsFor(mo) : null;
		if (st) st.menuHand = e.args[0] == 1 ? 1 : 0;
	}
}
