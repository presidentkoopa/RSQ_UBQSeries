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
