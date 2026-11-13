// RSQ_WeaponsOfSaturn: the Rotary Cannon (BD22's Minigun mesh), the Saturn V (BD22's rocket launcher; alt = BD22 VR's
// 3x lock-on), the Nova Rifle (BD22's RailGun; live scope always on, 3x; charge ball as WoS) and the Titan (BD22's
// Nuker; Hyper Nova as WoS). WoS's fire numbers and projectiles; WoS's screen kick (A_SetPitch, A_ZoomFactor,
// Offset) is not carried: in VR it moves the player's view.

// ------------------------------------------------------------------------------------------------ Rotary Cannon
// WoS: fire spins it up, held it fires its bullets (every other burst with a tracer); alt spins it up and fires
// RotaryPlasma. Its 120-round belt is a magazine (BD22 VR reload row 17, the ammo-box magazine).
class RSQWS_Minigun : RSQWS_Gun replaces Chaingun
{
	bool tracerTurn;
	Default
	{
		Weapon.SelectionOrder 400;
		Weapon.SlotNumber 4;
		Weapon.AmmoType1 "RSQWS_Nato";
		Weapon.AmmoGive1 80;
		Weapon.AmmoType2 "RSQWS_NatoBelt";
		Inventory.PickupMessage "You got the Vulcan Rotary Cannon!";
		Inventory.PickupSound "weapons/fist/swing";
		Obituary "%o was torn to pieces by %k's minigun.";
		Tag "Rotary Cannon";
		RSQWS_Gun.Chambered false;
		-WEAPON.NOAUTOFIRE
	}
	// a round off the belt, or the wind-down when it is empty
	action state RSQWS_Belt(int n = 1)
	{
		for (int k = 0; k < n; k++)
			if (!invoker.TakeRound())
				return ResolveState("WindDown");
		return null;
	}
	action void RSQWS_Case()
	{
		A_FireProjectile('RSQWS_ChaingunCasingSpawner', 0, false, -12, -18);
	}
	States
	{
	Spawn:
		MNIG A -1;
		Stop;
	Select:
		CHAE A 0 A_StartSound("weapon/minigun", CHAN_WEAPON);
	SelectLoop:
		CHAE A 1 A_Raise;
		Loop;
	Deselect:
		CHAE A 1 A_Lower;
		Loop;
	Ready:
		CHAE A 1 RSQWS_Ready();
		Loop;
	Fire:	// spin up
		CHAE A 0
		{
			if (invoker.Loaded() <= 0)
				return RSQWS_Empty();
			A_StartSound("weapons/chaingun/start", CHAN_AUTO);
			return ResolveState(null);
		}
		CHAF S 2;
		CHAF T 1;
		CHAE E 1;
		CHAE A 1;
		CHAF S 1;
		CHAF T 1;
		CHAE E 1;
		CHAE A 0 A_ReFire;
	SpinDown:
		CHAE A 0 A_StartSound("weapons/chaingun/stop", 6);
		CHAE A 1;
		CHAF S 1;
		CHAF T 1;
		CHAE E 1;
		CHAE A 2;
		CHAF S 2;
		CHAF T 2 A_WeaponReady;
		CHAE E 3 A_WeaponReady;
		CHAE A 3 A_WeaponReady;
		CHAF S 3 A_WeaponReady;
		CHAF T 4 A_WeaponReady;
		CHAE E 4 A_WeaponReady;
		Goto Ready;
	Hold:	// WoS's Hold / Hold2: four rounds a burst, five shots, a tracer every other burst
		CHAE A 0
		{
			A_AlertMonsters();
			A_StartSound("weapons/chaingun/spin", 7);
			return RSQWS_Belt();
		}
		CHAF A 1 { A_GunFlash(); A_FireBullets(3, 2, -1, invoker.tracerTurn ? 1 : 5, "RSQWS_AltPuff3", 0); }
		CHAF B 1 RSQWS_Case();
		CHAF C 1 { A_FireBullets(3, 2, -1, invoker.tracerTurn ? 0 : 2, "RSQWS_AltPuff3", 0); RSQWS_Case(); return RSQWS_Belt(); }
		CHAF E 1
		{
			if (invoker.tracerTurn)
				A_FireProjectile('RSQWS_ChaingunTracer', frandom(-1.0, 1.0), false, 0, -1, 0, frandom(-1.0, 1.0));
			return RSQWS_Belt();
		}
		CHAF A 1 Bright { A_FireBullets(3, 2, -1, invoker.tracerTurn ? 1 : 2, "RSQWS_AltPuff3", 0); RSQWS_Case(); }
		CHAF B 1 { A_FireBullets(2, 2, -1, invoker.tracerTurn ? 0 : 10, "RSQWS_AltPuff3", 0); RSQWS_Case(); return RSQWS_Belt(); }
		CHAF C 1 A_FireBullets(3, 2, -1, invoker.tracerTurn ? 8 : 2, "RSQWS_AltPuff3", 0);
		CHAF E 1 { RSQWS_Case(); RSQWS_ShotFX(null); invoker.tracerTurn = !invoker.tracerTurn; }
		CHAE A 0 A_ReFire;
		Goto WindDown;
	AltFire:	// spin up for the RotaryPlasma
		CHAE A 0
		{
			if (invoker.Loaded() <= 0)
				return RSQWS_Empty();
			A_StartSound("weapon/minigun", CHAN_AUTO);
			A_StartSound("weapons/chaingun/start", CHAN_WEAPON);
			return ResolveState(null);
		}
		CHAF S 2;
		CHAF T 1;
		CHAE E 1;
		CHAE A 1;
		CHAF S 1;
		CHAF T 1;
		CHAE E 1;
		CHAE A 1;
		CHAF S 1;
		CHAF T 1;
		CHAE E 1;
		CHAE A 0 A_ReFire;
		Goto SpinDown;
	AltHold:	// WoS's: six rounds a burst, four RotaryPlasma
		CHAE A 0
		{
			A_AlertMonsters();
			A_StartSound("weapons/chaingun/spin", 7);
			A_StartSound("weapons/rotarypulse/fire", CHAN_WEAPON);
			return RSQWS_Belt(3);
		}
		CHAF A 1 { A_GunFlash(); A_FireProjectile('RSQWS_RotaryPlasma', frandom(-2.0, 2.0), false, -1, 0, 0, frandom(-2.0, 2.0)); RSQWS_Case(); RSQWS_Case(); }
		CHAF C 1 { A_FireProjectile('RSQWS_RotaryPlasma', frandom(-2.0, 2.0), false, -2, 0, 0, frandom(-1.0, 1.0)); RSQWS_Case(); RSQWS_Case(); A_StartSound("weapons/rotarypulse/fire", CHAN_WEAPON); return RSQWS_Belt(); }
		CHAF E 1 { A_FireProjectile('RSQWS_RotaryPlasma', frandom(-2.0, 2.0), false, 0, 0, 0, frandom(-2.0, 2.0)); RSQWS_Case(); RSQWS_Case(); return RSQWS_Belt(); }
		CHAF A 1 Bright { A_FireProjectile('RSQWS_RotaryPlasma', frandom(-2.0, 2.0), false, -1, 0, 0, frandom(-1.0, 1.0)); A_StartSound("weapons/rotarypulse/fire", CHAN_WEAPON); RSQWS_Case(); return RSQWS_Belt(); }
		CHAF C 1 Bright { A_FireProjectile('RSQWS_RotaryPlasma', frandom(-2.0, 2.0), false, -1, 0, 0, frandom(-2.0, 2.0)); RSQWS_ShotFX(null); }
		CHAF E 1;
		CHAE A 0 A_ReFire;
	WindDown:
		CHAE A 0 A_StartSound("weapons/chaingun/stop", 6);
		CHAF A 1;
		CHAF B 1;
		CHAF C 1;
		CHAF E 1;
		CHAF A 2;
		CHAF B 2;
		CHAF C 2;
		CHAF E 2;
		Goto SpinDown;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 2 A_Light0;
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 A_Light1;
		TNT1 A 2 A_Light0;
		Goto LightDone;
	StockReload:	// WoS's: a new belt fed in
		CHAE A 6 A_StartSound("weapons/chaingun/feed", 5);
		CHAE A 10 { invoker.FillMag(); }
		CHAE A 4;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Saturn V
// WoS's rocket: one SaturnRocket and six SaturnTracers a shot from a 12-rocket magazine. Alt fire is BD22 VR's lock-on
// (zscript/rsq/rlock.zs, SPEC): hold alt and up to three enemies near the barrel's line are painted; let go and a salvo
// of three Saturn rockets (one round each) goes down Fire, each homing on its lock.
class RSQWS_SaturnV : RSQWS_Gun replaces RocketLauncher
{
	Default
	{
		Weapon.SelectionOrder 2500;
		Weapon.SlotNumber 5;
		Weapon.AmmoType1 "RocketAmmo";
		Weapon.AmmoGive1 6;
		Weapon.AmmoType2 "RSQWS_RocketRounds";
		Inventory.PickupMessage "You got the Saturn V!";
		Inventory.PickupSound "weapons/fist/swing";
		Obituary "%o was sent to the moon by %k's Saturn Rocket";
		Tag "Saturn V";
		RSQWS_Gun.Chambered false;
	}
	States
	{
	Spawn:
		LAWN A -1;
		Stop;
	Select:
		MISG A 0 A_StartSound("weapons/launcher/ready", CHAN_WEAPON);
	SelectLoop:
		MISG A 1 A_Raise;
		Loop;
	Deselect:
		MISG A 1 A_Lower;
		Loop;
	Ready:
		MISG A 1 RSQWS_Ready();
		Loop;
	Fire:
		MISG A 0
		{
			if (!invoker.TakeRound())
				return RSQWS_Empty();
			A_StartSound("weapons/launcher/fire", 4);
			return ResolveState(null);
		}
		MISF A 1 A_GunFlash;
		MISF A 1 Bright A_AlertMonsters;
		MISF B 1 Bright
		{
			for (int k = 0; k < 6; k++)
				A_FireProjectile('RSQWS_SaturnTracer', frandom(-8.0, 8.0), false, 0, 0, 0, frandom(-4.0, 4.0));
			A_FireProjectile('RSQWS_SaturnRocket', 0, false, 0, 5);
			RSQWS_ShotFX(null);
		}
		MISF C 1;
		MISF D 1;
		MISF E 2;
		MISF G 4;
		MISG A 1 A_ReFire;
		Goto Ready;
	AltFire:	// BD22 VR's RSA_RLLock: held here while the lock-on paints (rlock.zs); letting go fires the salvo down Fire
	RSA_RLLock:
		"####" "#" 1 A_WeaponReady(WRF_NOFIRE | WRF_NOSECONDARY | WRF_NOSWITCH | WRF_NOBOB);
		"####" "#" 0 { if (player && (player.cmd.buttons & BT_ALTATTACK)) return ResolveState("RSA_RLLock"); return ResolveState("Ready"); }
	Flash:
		TNT1 A 2 Bright A_Light2;
		TNT1 A 2 Bright A_Light1;
		Goto LightDone;
	StockReload:
		MISR A 0 A_StartSound("weapons/launcher/up", 6);
		MISR ABCDEFGHIJKLMNO 1;
		MISR O 0 { invoker.FillMag(); A_StartSound("weapons/launcher/load", 5); }
		MISR PQRSTUVWXYZ 1;
		MISG A 2;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Nova Rifle
// WoS's: a Plasma bolt a shot (it re-fires fast while held); alt charges and fires a NovaBall for five cells. The live
// scope is BD22 VR's, always on, 3x (rsq/scope_real.zs on the RailGun mesh).
class RSQWS_NovaRifle : RSQWS_Gun replaces PlasmaRifle
{
	Default
	{
		Weapon.SelectionOrder 100;
		Weapon.SlotNumber 6;
		Weapon.AmmoType1 "Cell";
		Weapon.AmmoGive1 60;
		Weapon.AmmoType2 "RSQWS_Cellpak";
		Inventory.PickupMessage "You got the Nova Rifle!";
		Inventory.PickupSound "weapons/fist/swing";
		Obituary "%o was Cronenberged by %k's Nova Rifle";
		Tag "Nova Rifle";
		RSQWS_Gun.Chambered false;
		-WEAPON.NOAUTOFIRE
	}
	States
	{
	Spawn:
		PLAS A -1;
		Stop;
	Select:
		RAIL A 0 A_StartSound("weapons/plasmagun/upsound", CHAN_WEAPON);
	SelectLoop:
		RAIL A 1 A_Raise;
		Loop;
	Deselect:
		RAIL A 1 A_Lower;
		Loop;
	Ready:
		RAIL A 1 RSQWS_Ready();
		Loop;
	Fire:
		RAIL A 0
		{
			if (!invoker.TakeRound())
				return RSQWS_Empty();
			A_GunFlash();
			A_AlertMonsters();
			A_StartSound("weapons/plasmagun/fire", CHAN_WEAPON);
			return ResolveState(null);
		}
		RAIF B 1 Bright A_FireProjectile('RSQWS_Plasma', 0, false, -1, 1);
		RAIF D 1 A_ReFire;
		RAIF B 1 A_ReFire;
		RAIL A 0 RSQWS_ShotFX(null);
		RAIL A 12;
		RAIL A 6;
		Goto Ready;
	AltFire:	// WoS's charge: five cells, the NovaBall
		RAIL A 0
		{
			if (invoker.Loaded() <= 0)
				return RSQWS_Empty();
			return ResolveState(null);
		}
		RAIL A 1;
		RAIL A 1 A_StartSound("weapons/plasmagun/charge", CHAN_AUTO);
		RAIL A 9;
		RAIL A 2;
		RAIL A 0
		{
			invoker.TakeUpTo(5);
			A_GunFlash();
			A_StartSound("weapons/plasmagun/fire", CHAN_WEAPON);
			A_FireProjectile('RSQWS_NovaBall', 0, false);
			A_AlertMonsters();
		}
		RAIF D 1 Bright;
		RAIF B 1;
		RAIF C 1;
		RAIF E 1 RSQWS_ShotFX(null);
		RAIF G 12;
		RAIF E 2;
		RAIF C 4;
		RAIL A 2 A_StartSound("weapons/plasmagun/beep", 6);
		RAIL A 6;
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light1;
		Goto LightDone;
	StockReload:
		RAIR A 0 A_StartSound("weapons/plasmagun/reload", 6);
		RAIR ABCDEFGHI 1;
		RAIR I 0 { invoker.FillMag(); }
		RAIR JKLMNOPQRS 1;
		RAIL A 2;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Titan
// WoS's: fire is a Nova for five cells, alt the Hyper Nova for forty (a charge first). A 160-cell magazine.
class RSQWS_TITAN : RSQWS_Gun replaces BFG9000
{
	Default
	{
		Weapon.SelectionOrder 2800;
		Weapon.SlotNumber 7;
		Weapon.AmmoType1 "Cell";
		Weapon.AmmoGive1 80;
		Weapon.AmmoType2 "RSQWS_BFGCell";
		Obituary "%o went to plaid from %k's Titan";
		Inventory.PickupMessage "You got the Titan! Oh, yes.";
		Inventory.PickupSound "weapons/fist/swing";
		Tag "Titan";
		RSQWS_Gun.Chambered false;
	}
	States
	{
	Spawn:
		DEBF A -1;
		Stop;
	Select:
		NKLG A 0 A_StartSound("weapons/bfg/pickup", CHAN_WEAPON);
	SelectLoop:
		NKLG A 1 A_Raise;
		Loop;
	Deselect:
		NKLG A 1 A_Lower;
		Loop;
	Ready:
		NKLG A 1 RSQWS_Ready();
		Loop;
	Fire:
		NKLG A 0 { if (invoker.Loaded() <= 0) return RSQWS_Empty(); A_GunFlash(); return ResolveState(null); }
		NKLG A 6;
		NKLF A 0
		{
			invoker.TakeUpTo(5);
			A_StartSound("weapons/bfg/fire", 5);
			RSQWS_ShotFX(null);
		}
		NKLF E 1 Bright A_FireProjectile('RSQWS_Nova', 0, false);
		NKLF E 2;
		NKLF G 2;
		NKLF K 2;
		NKLG A 2;
		NKLG A 0 A_ReFire;
		NKLG A 0 A_StartSound("weapons/plasmagun/beep", CHAN_WEAPON);
		NKLG A 8;
		Goto Ready;
	AltFire:
		NKLG A 0
		{
			if (invoker.Loaded() <= 0)
				return RSQWS_Empty();
			A_StartSound("weapons/bfg/start", 5);
			A_StartSound("weapons/bfg/classic", CHAN_WEAPON);
			A_GunFlash();
			return ResolveState(null);
		}
		NKLG A 30;
		NKLF A 4;
		NKLF A 0 { invoker.TakeUpTo(40); RSQWS_ShotFX(null); }
		NKLF E 1 Bright A_FireProjectile('RSQWS_HyperNova', 0, false);
		NKLF E 2 Bright;
		NKLF K 6;
		NKLG A 6;
		NKLF K 6;
		NKLG A 6;
		NKLF K 6;
		NKLG A 2 A_StartSound("weapons/plasmagun/beep", 7);
		NKLG A 10;
		NKLG A 0 A_ReFire;
		Goto Ready;
	Flash:
		TNT1 A 3 Bright A_Light1;
		TNT1 A 3 Bright A_Light2;
		Goto LightDone;
	StockReload:
		NKLG A 8 A_StartSound("weapons/bfg/reload", 6);
		NKLG A 12 { invoker.FillMag(); }
		NKLG A 6;
		Goto Ready;
	}
}
