// THE ROUTERS (10-27). MENUDEF points Gun Bonsai's three menu names here. Each router IS Gun
// Bonsai's own menu (a subclass, built by its own Init), so rsq_ui_skin 0 changes nothing. With a
// skin on, the router draws nothing and, on its first tic, closes and opens the skin's menu.
// (A menu cannot open another from inside its own Init: the engine activates the first one after
// Init returns, on top of whatever Init opened.)
mixin class RSQUI_Routing
{
	Name rsqTarget;

	void RouteInit(int which) { rsqTarget = RSQUI_Dispatch.MenuFor(which); }

	bool RouteTick()
	{
		if (rsqTarget == 'None') return false;
		Name t = rsqTarget;
		rsqTarget = 'None';
		Close();
		Menu.SetMenu(t);
		return true;
	}
}

class RSQUI_StatusRouter : TFLV_Menu_StatusDisplay
{
	mixin RSQUI_Routing;
	override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		RouteInit(0);
		super.Init(parent, desc);
	}
	override void Ticker() { if (!RouteTick()) super.Ticker(); }
	override void Drawer() { if (rsqTarget == 'None') super.Drawer(); }
}

class RSQUI_WeaponLevelUpRouter : TFLV_Menu_WeaponLevelUpMenu
{
	mixin RSQUI_Routing;
	override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		RouteInit(1);
		super.Init(parent, desc);
	}
	override void Ticker() { if (!RouteTick()) super.Ticker(); }
	override void Drawer() { if (rsqTarget == 'None') super.Drawer(); }
}

class RSQUI_PlayerLevelUpRouter : TFLV_Menu_PlayerLevelUpMenu
{
	mixin RSQUI_Routing;
	override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		RouteInit(2);
		super.Init(parent, desc);
	}
	override void Ticker() { if (!RouteTick()) super.Ticker(); }
	override void Drawer() { if (rsqTarget == 'None') super.Drawer(); }
}
