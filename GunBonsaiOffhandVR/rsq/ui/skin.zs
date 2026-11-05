// THE SCREENS' CONTRACT (10-27; one look since 11-05). The owner's mockups: Gun Bonsai's in-play gauges (one per hand,
// top corners, RS Score top centre), the status screen and the level-up cards, drawn by this patch instead of Gun
// Bonsai's own list menus. One switch, the menu's "GBOVR Menus and HUD" (owner 11-05: "the only hud we want is the
// Mockup, which we will rename the option to: GBOVR Menus and HUD : On / Off"):
//   rsq_ui_skin  1 On  = the Mockup (RSQUI_A_Skin: skin_a_hud.zs, skin_a_menus.zs)
//                0 Off = Gun Bonsai's own screens: its list menus, its own gauges, no bottom row
// (Hex Rail and Terminal, skins B and C, were removed on 11-05; a saved 2 or 3 reads as On, and settings version 1,
// RSQUI_Handler.Migrate, writes it back as 1.) The dispatcher asks Current() and calls these; a method left at the
// default falls back to Gun Bonsai.
class RSQUI_Skin ui abstract
{
	// In play: both hands' gauges and the score. true = drawn (Gun Bonsai's own HUD is skipped).
	virtual bool DrawHud(RenderEvent e) { return false; }
	// The menus this skin opens in place of Gun Bonsai's: the status screen, the weapon level-up
	// and the player level-up. 'None' = Gun Bonsai's own.
	virtual Name StatusMenu() { return 'None'; }
	virtual Name WeaponLevelUpMenu() { return 'None'; }
	virtual Name PlayerLevelUpMenu() { return 'None'; }

	// GBOVR Menus and HUD: any value but 0 is On (a save from before 11-05 may still hold 2 or 3 until Migrate runs).
	static clearscope bool On()
	{
		let cv = CVar.FindCVar("rsq_ui_skin");
		return !cv || cv.GetInt() != 0;
	}

	// A new object each call: the caller keeps it, and asks again when rsq_ui_skin changes.
	static RSQUI_Skin Current()
	{
		if (!On()) return null;
		return new("RSQUI_A_Skin");
	}
}
