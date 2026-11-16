// What BD22 VR's melee (rsvr/melee.zs, carried here for the Motorsaw's contact saw only) asks of BD22 VR systems this
// pack does not carry: the axe (its off-hand copy, the wall-axe grab), the gun bash's flash, the fists' strike record
// and line use. Same names, neutral answers: melee.zs reads no axe, whip or butt here (KindOf: the Motorsaw only).
class RSQ_Off_BrutalAxe : Weapon
{
	Default
	{
		+WEAPON.CHEATNOTWEAPON
	}
	States
	{
	Ready:
		TNT1 A 1 A_WeaponReady;
		Loop;
	Select:
		TNT1 A 1 A_Raise;
		Loop;
	Deselect:
		TNT1 A 1 A_Lower;
		Loop;
	Fire:
		TNT1 A 1;
		Goto Ready;
	}
}
class RSQ_BashFX : Actor
{
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}
class RSVR_AxeGrab abstract
{
	static void GiveOff(PlayerPawn mo) {}
}
// BD22 VR 2.0.4r's axe pool (rsvr/axegrab.zs), which melee.zs asks: this pack has no axe, so no axe count and no axe in
// either hand (build.py also keeps melee.zs's AxePool tick from running)
class RSVR_Axes : Inventory { Default { Inventory.MaxAmount 0; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; } }
class RSVR_AxePool abstract
{
	static bool Logs(PlayerPawn mo) { return false; }
	static void Thrown(PlayerPawn mo, Actor proj) {}
	static void Spent(PlayerPawn mo, int hand, bool next) {}
	static bool IsAxeW(Weapon w) { return false; }
	static bool HandHasAxe(PlayerPawn mo, bool off) { return false; }
	static bool ToEmpty(PlayerPawn mo, bool off, String why) { return false; }
}
class RSVR_AxePoolInit : RSVR_Token {}
class RSVR_AxeCritNext : RSVR_Token {}
class RSVR_MainAxeNext : RSVR_Token {}
class RSVR_OffAxeNext : RSVR_Token {}
