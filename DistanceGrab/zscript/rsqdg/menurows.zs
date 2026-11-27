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
