// GNRC_Reloaded: the one base every gun is built on (WoS_Reloaded's base, the GNRC prefix). The VR protocols live here:
//   - the magazine reload by hand (BD22 VR's zscript/rsr/vreload.zs, its RSR_ token protocol), and the stock reload
//     when not in VR or with Reloading on Stock / Flick (the flick enters Reload too: zscript/rsq/flick.zs);
//   - the quick kick (owner: "if we need a quick kick then make one"): a key, any time a gun is up;
//   - semi auto, empty / dry fire, the ready check every gun calls.
// Ammo: Ammo1 = the reserve, Ammo2 = the rounds in the gun (GNRC has them the other way round; the numbers are GNRC's).
// No ACS, none of Led's options (owner): GNRC's ACS option reads are their defaults.

class RSQGW_Kicking : Inventory { Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; } }

// the quick kick, shared by the guns and the fists (a Fist: RSQ Melee punches with it), so it is a mixin. The kick is
// the leg's: the gun stays as it is in the hand (no kick frames in VR). WoS_Reloaded's kick numbers (2*random(5,15),
// 96 units, berserk x10), GNRC's swing sound.
mixin class RSQGW_KickMix
{
	action void RSQGW_KickHit(bool air)
	{
		int dmg = 2 * random(5, 15);
		if (FindInventory('PowerStrength', true)) dmg *= 10;
		A_CustomPunch(dmg, true, CPF_NOTURN, 'RSQGW_KickPuff', air ? 112 : 96);
		A_RadiusThrust(5000, 64, RTF_NOIMPACTDAMAGE | RTF_NOTMISSILE);
	}

	// the kick token, checked by every Ready tic (RSQGW_Gun.RSQGW_Ready, the fists' Ready)
	action state RSQGW_KickCheck()
	{
		if (CountInv('RSQGW_Kicking') > 0 && !invoker.bOffhandWeapon)
			return ResolveState("DoKick");
		return null;
	}

	States
	{
	DoKick:
		"####" "#" 0
		{
			A_TakeInventory("RSQGW_Kicking", 1);
			A_StartSound("swing", CHAN_WEAPON);
			if (!player || player.onground == false && vel.z != 0)
				return ResolveState("AirKick");
			return ResolveState(null);
		}
		"####" "#" 3 A_WeaponReady(WRF_NOFIRE | WRF_NOSWITCH);
		"####" "#" 0 RSQGW_KickHit(false);
		"####" "#" 10 A_WeaponReady(WRF_NOFIRE | WRF_NOSWITCH);
		"####" "#" 3;
		"####" "#" 0 A_Jump(256, "Ready");	// by name at run time: a Goto in a mixin is resolved where the mixin is, which has no Ready
	AirKick:
		"####" "#" 4 A_WeaponReady(WRF_NOFIRE | WRF_NOSWITCH);
		"####" "#" 0 RSQGW_KickHit(true);
		"####" "#" 10 A_WeaponReady(WRF_NOFIRE | WRF_NOSWITCH);
		"####" "#" 0 A_Jump(256, "Ready");
	}
}

// the kick's hit: GNRC's bullet puff look, the punch sound on flesh
class RSQGW_KickPuff : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		+NOEXTREMEDEATH
		AttackSound "weapons/fist/punch";
		SeeSound "weapons/fist/punch";
		DamageType "Melee";
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}

class RSQGW_Gun : Weapon abstract
{
	mixin RSQGW_KickMix;

	bool chambered;		// a round in the chamber: empty, the magazine takes one less (GNRC's 10 / 11)
	bool racks;			// emptied, the hand reload ends with the slide / bolt / handle (RSR_Charge)
	bool semiOption;	// "Pistol Semi Auto" (rsa_pistol_semi) applies to this gun
	property Chambered: chambered;
	property Racks: racks;
	property SemiOption: semiOption;

	Default
	{
		Weapon.BobStyle "Smooth";
		Weapon.BobSpeed 2.0;
		Weapon.BobRangeX 0.30;
		Weapon.BobRangeY 0.40;
		Weapon.AmmoUse1 0;			// the reserve is never spent by firing: Ammo2 is (each gun takes it itself)
		Weapon.AmmoUse2 0;
		+WEAPON.NOALERT;
		+WEAPON.AMMO_OPTIONAL;
		+WEAPON.ALT_AMMO_OPTIONAL;
		+WEAPON.NOAUTOFIRE;
		RSQGW_Gun.Chambered true;
		RSQGW_Gun.Racks false;
		RSQGW_Gun.SemiOption false;
	}

	// ---------------------------------------------------------------- ammo
	int Loaded() { return Ammo2 ? Ammo2.Amount : 0; }
	int Reserve() { return Ammo1 ? Ammo1.Amount : 0; }
	int Cap()
	{
		if (!Ammo2) return 0;
		return chambered && Ammo2.Amount <= 0 ? Ammo2.MaxAmount - 1 : Ammo2.MaxAmount;
	}
	bool CanReload()
	{
		if (!Ammo2 || !Ammo1) return false;
		return Ammo2.Amount < Ammo2.MaxAmount && (Ammo1.Amount > 0 || sv_infiniteammo || (Owner && Owner.FindInventory('PowerInfiniteAmmo', true)));
	}
	// the reserve into the gun up to Cap: the same for the stock reload, the hand reload and the flick
	void FillMag()
	{
		if (!Ammo2 || !Ammo1 || !Owner) return;
		int cap = Cap();
		bool inf = sv_infiniteammo || Owner.FindInventory('PowerInfiniteAmmo', true);
		while (Ammo2.Amount < cap && (Ammo1.Amount > 0 || inf))
		{
			Ammo2.Amount++;
			if (!inf) Ammo1.Amount--;
		}
	}
	// one round from the reserve into the gun (a shell into a tube or a barrel); false: full, or nothing to load
	bool LoadOne()
	{
		if (!Ammo2 || !Ammo1 || !Owner || Ammo2.Amount >= Ammo2.MaxAmount) return false;
		bool inf = sv_infiniteammo || Owner.FindInventory('PowerInfiniteAmmo', true);
		if (Ammo1.Amount <= 0 && !inf) return false;
		Ammo2.Amount++;
		if (!inf) Ammo1.Amount--;
		return true;
	}
	// up to n rounds out of the gun, as GNRC's A_TakeInventory(mag, n) (the plasma rifle's rail); how many
	int TakeUpTo(int n)
	{
		if (!Ammo2) return 0;
		int k = min(n, Ammo2.Amount);
		if (!(sv_infiniteammo || (Owner && Owner.FindInventory('PowerInfiniteAmmo', true))))
			Ammo2.Amount -= k;
		return k;
	}
	// fire one round from the gun (false: it is empty)
	bool TakeRound(int n = 1)
	{
		if (!Ammo2 || Ammo2.Amount < n) return false;
		if (!(sv_infiniteammo || (Owner && Owner.FindInventory('PowerInfiniteAmmo', true))))
			Ammo2.Amount -= n;
		return true;
	}

	// ---------------------------------------------------------------- the hand that holds it
	bool InOffHand() { return bOffhandWeapon; }
	// this hand's trigger, now (semi auto: wait for it to be let go)
	action bool RSQGW_TriggerHeld()
	{
		if (!player) return false;
		int b = player.cmd.buttons;
		return invoker.InOffHand() ? (b & BT_OFFHANDATTACK) != 0 : (b & BT_ATTACK) != 0;
	}
	action bool RSQGW_SemiOn()
	{
		if (!invoker.semiOption || !player) return false;
		let c = CVar.GetCVar('rsa_pistol_semi', player);
		return c && c.GetBool();
	}

	// ---------------------------------------------------------------- every gun's ready tic
	// the kick, then A_WeaponReady (reload offered only when there is room and rounds to put in)
	action state RSQGW_Ready(int flags = 0)
	{
		state k = RSQGW_KickCheck();
		if (k)
			return k;
		A_WeaponReady(flags | (invoker.CanReload() ? WRF_ALLOWRELOAD : 0));
		return null;
	}
	// a trigger pulled on an empty gun: reload if it can, else the dry click
	action state RSQGW_Empty()
	{
		if (invoker.CanReload())
			return ResolveState("Reload");
		A_StartSound("RSQWS/dry", CHAN_AUTO);
		return ResolveState("DryWait");
	}

	// ---------------------------------------------------------------- a shot's effects
	// Ballistics Stock: GNRC's own smoke (casings always; Real Casing Models decides their look). Low / Max: RS Ballistics
	// (BD22 VR's zscript/rsq/*) takes over the smoke.
	action void RSQGW_ShotFX(class<Actor> casing = null, double side = 0, double up = 8)
	{
		if (!RSQGW_FX.Enhanced(player))
			A_FireProjectile('RSQGW_GunSmokeSpawner', 0, false, 0, up);
		if (casing)
			A_FireProjectile(casing, 0, false, side, up);
	}

	States
	{
	// ---- the magazine reload. Reload is the one entry: the hand reload in VR (Reloading = VR), the gun's own
	// stock reload otherwise (not in VR, Reloading = Stock, the flick, an off-hand copy).
	Reload:
		"####" "#" 0
		{
			if (!invoker.CanReload())
				return ResolveState("Ready");
			if (invoker.InOffHand())
				return ResolveState("StockReload");
			A_TakeInventory("RSR_Go", 1);
			A_GiveInventory("RSR_Start", 1);
			if (CountInv("RSR_Go") > 0)
				return ResolveState("RSR_Out");
			return ResolveState("StockReload");
		}
	RSR_Out:
		"####" "#" 0
		{
			A_TakeInventory("RSR_Go", 1);
			A_TakeInventory("RSR_Charge", 1);
			if (invoker.racks && invoker.Loaded() <= 0)
				A_GiveInventory("RSR_Charge", 1);	// ran dry: the hand racks it after the magazine is home
			A_GiveInventory("RSR_MagOut", 1);	// the magazine drops out
		}
	RSR_Wait:	// the gun as the script shows it; the script runs every tic
		"####" "#" 1 A_WeaponReady(WRF_NOBOB | WRF_NOFIRE);
		"####" "#" 0
		{
			A_GiveInventory("RSR_Tick", 1);
			if (CountInv("RSR_Seated") > 0)
				return ResolveState("RSR_Fill");
			if (CountInv("RSR_Done") > 0)
				return ResolveState("RSR_Done");
			return ResolveState("RSR_Wait");
		}
	RSR_Fill:	// the magazine is home: the reserve into it, then the script racks it if it ran dry, else done
		"####" "#" 0
		{
			A_TakeInventory("RSR_Seated", 1);
			invoker.FillMag();
			A_GiveInventory("RSR_Filled", 1);
			return ResolveState("RSR_Wait");
		}
	RSR_Done:
		"####" "#" 0
		{
			A_TakeInventory("RSR_Done", 1);
			A_TakeInventory("RSR_Charge", 1);
			return ResolveState("Ready");
		}
	DryWait:
		"####" "#" 8;
		Goto Ready;

	}
}

// the Quick Kick key: KEYCONF "Quick Kick" -> netevent rsqgw_kick
class RSQGW_KickKey : EventHandler
{
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqgw_kick") || e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player])
			return;
		let mo = players[e.Player].mo;
		if (mo && mo.health > 0 && (players[e.Player].ReadyWeapon is 'RSQGW_Gun' || players[e.Player].ReadyWeapon is 'RSQGW_Knuckle'))
			mo.GiveInventory('RSQGW_Kicking', 1);
	}
}

// Ballistics (rsq_ballistics, BD22 VR's one option): 0 Stock = GNRC's own sounds and smoke, 1 Low / 2 Max = RS Ballistics
// (and the hand reload's RS Combat FX sounds)
class RSQGW_FX abstract
{
	clearscope static bool Enhanced(PlayerInfo p = null)
	{
		let c = CVar.FindCVar('rsq_ballistics');
		return c && c.GetInt() > 0;
	}
}
