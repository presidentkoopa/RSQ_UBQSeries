// THE SCREENS' CONTRACT (10-27). The owner's mockups: Gun Bonsai's in-play gauges (one per hand,
// top corners, RS Score top centre), the status screen and the level-up cards, drawn by this
// patch instead of Gun Bonsai's own list menus. Several looks ("skins") share one switch:
//   rsq_ui_skin  0 Gun Bonsai's own screens, 1 the recreation of the mockups (skin A),
//                2 and 3 the two alternatives (skins B and C)
// A skin is a subclass of RSQUI_Skin named in SKINS below. The dispatcher (skin A's agent wires
// it into the shadowed EventHandler.zsc and wherever Gun Bonsai opens its menus) asks Current()
// and calls these; a skin may leave any of them at the default, which falls back to Gun Bonsai.
class RSQUI_Skin ui abstract
{
	static const String SKINS[] = { "", "RSQUI_A_Skin", "RSQUI_B_Skin", "RSQUI_C_Skin" };

	// In play: both hands' gauges and the score. true = drawn (Gun Bonsai's own HUD is skipped).
	virtual bool DrawHud(RenderEvent e) { return false; }
	// The menus this skin opens in place of Gun Bonsai's: the status screen, the weapon level-up
	// and the player level-up. 'None' = Gun Bonsai's own.
	virtual Name StatusMenu() { return 'None'; }
	virtual Name WeaponLevelUpMenu() { return 'None'; }
	virtual Name PlayerLevelUpMenu() { return 'None'; }

	// A new object each call: the caller keeps it, and asks again when rsq_ui_skin changes.
	static RSQUI_Skin Current()
	{
		let cv = CVar.FindCVar("rsq_ui_skin");
		int k = cv ? cv.GetInt() : 0;
		if (k <= 0 || k >= SKINS.Size()) return null;
		class<RSQUI_Skin> c = SKINS[k];
		if (!c) return null;
		return RSQUI_Skin(new(c));
	}
}
