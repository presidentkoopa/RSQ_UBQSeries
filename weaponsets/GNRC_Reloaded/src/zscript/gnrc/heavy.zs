// GNRC_Reloaded: the Minigun (BD22's Minigun mesh), the Rocket Launcher (BD22's rocket launcher), the Plasma Rifle
// (BD22's Plasma_Gun) and the BFG (BD22's BFG). GNRC's fire numbers, sounds and projectiles; GNRC's screen kick
// (A_SetPitch, A_ZoomFactor, A_WeaponOffset, Radius_Quake, A_SetBlend, A_Recoil) is not carried: in VR it moves the view.

// ------------------------------------------------------------------------------------------------ Minigun
// GNRC: fire spins it up, held it fires two rounds every 4 tics (A_FireLedMinigun: 5 x 5, 5 damage); let go it winds
// down. No alt fire. Its 150-round belt is a magazine (BD22 VR reload row 17, the ammo-box magazine, as WoS_Reloaded).
class RSQGW_Minigun : RSQGW_Gun replaces Chaingun
{
	Default
	{
		Weapon.SelectionOrder 4000;
		Weapon.SlotNumber 4;
		Weapon.AmmoType1 "RSQGW_Nato";
		Weapon.AmmoGive1 50;
		Weapon.AmmoType2 "RSQGW_MinigunMag";
		Inventory.PickupMessage "You got the Minigun!";
		Inventory.PickupSound "weapons/minig/pkup";
		Obituary "%o was mowed down by %k's minigun.";
		Tag "Minigun";
		RSQGW_Gun.Chambered false;
		-WEAPON.NOAUTOFIRE
	}
	// one round off the belt: false when it is empty
	action bool RSQGW_Round()
	{
		if (!invoker.TakeRound())
			return false;
		A_GunFlash();
		A_StartSound("weapons/minig/spin", 6);
		A_FireBullets(5, 5, 1, 5, "BulletPuff", 0);
		A_AlertMonsters();
		A_FireProjectile('RSQGW_ChaingunCasingSpawner', 0, false, -10, -8);
		return true;
	}
	States
	{
	Spawn:
		MNIG A -1;
		Stop;
	Select:
		CHAE A 0 A_StartSound("weapons/minig/equp", CHAN_WEAPON);
	SelectLoop:
		CHAE A 1 A_Raise;
		Loop;
	Deselect:
		CHAE A 1 A_Lower;
		Loop;
	Ready:
		CHAE A 1 RSQGW_Ready();
		Loop;
	Fire:	// GNRC's spin-up
		CHAE A 0
		{
			if (invoker.Loaded() <= 0)
				return RSQGW_Empty();
			A_StartSound("weapons/minig/start", CHAN_AUTO);
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
		CHAE A 0 A_StartSound("weapons/minig/down", CHAN_AUTO);
		CHAF S 1 A_WeaponReady;
		CHAF T 1 A_WeaponReady;
		CHAE E 1 A_WeaponReady;
		CHAE A 2 A_WeaponReady;
		CHAF S 2 A_WeaponReady;
		CHAF T 2 A_WeaponReady;
		CHAE E 3 A_WeaponReady;
		CHAE A 3 A_WeaponReady;
		CHAF S 3 A_WeaponReady;
		CHAF T 4 A_WeaponReady;
		CHAE E 4 A_WeaponReady;
		Goto Ready;
	Hold:	// two rounds every 4 tics
		CHAF A 1 Bright { if (!RSQGW_Round()) return ResolveState("EmptyWindDown"); RSQGW_ShotFX(null); return ResolveState(null); }
		CHAF B 1;
		CHAF C 1 Bright { if (!RSQGW_Round()) return ResolveState("EmptyWindDown"); return ResolveState(null); }
		CHAF E 1;
		CHAE A 0 A_ReFire;
	WindDown:
		CHAE A 0 A_StartSound("weapons/minig/stop", 6);
		CHAF A 1;
		CHAF B 1;
		CHAF C 1 A_WeaponReady(WRF_NOSWITCH);
		CHAF E 1 A_WeaponReady(WRF_NOSWITCH);
		CHAF ABCE 2 A_WeaponReady(WRF_NOSWITCH);
		Goto SpinDown;
	EmptyWindDown:	// GNRC: ran dry while firing
		CHAE A 0 { A_StartSound("weapons/minig/empty", CHAN_AUTO); A_StartSound("weapons/minig/stop", 6); }
		CHAF A 1;
		CHAF B 1;
		CHAF C 1;
		CHAF E 1;
		CHAF ABCE 2;
		Goto SpinDown;
	AltFire:	// none
		CHAE A 1;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 A_Light1;
		Goto LightDone;
	StockReload:	// GNRC's: a new belt fed in
		CHAE A 6 A_StartSound("weapons/minig/chain", 5);
		CHAE A 10 { invoker.FillMag(); A_StartSound("weapons/minig/reload", 6); }
		CHAE A 4;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Rocket Launcher
// GNRC: one Rocket2 a shot (A_FireLedRL) from a 5-rocket magazine, 7 tics a shot. No alt fire (owner: "no rocket
// altfire").
class RSQGW_Rlauncher : RSQGW_Gun replaces RocketLauncher
{
	Default
	{
		Weapon.SelectionOrder 2500;
		Weapon.SlotNumber 5;
		Weapon.AmmoType1 "RocketAmmo";
		Weapon.AmmoGive1 5;
		Weapon.AmmoType2 "RSQGW_RocketMag";
		Inventory.PickupMessage "You got the Rocket Launcher!";
		Inventory.PickupSound "weapons/rlaunch/pkup";
		Obituary "%o rode %k's rocket.";
		Tag "Rocket Launcher";
		RSQGW_Gun.Chambered false;
	}
	States
	{
	Spawn:
		LAWN A -1;
		Stop;
	Select:
		MISG A 0 A_StartSound("weapons/equprock", CHAN_WEAPON);
	SelectLoop:
		MISG A 1 A_Raise;
		Loop;
	Deselect:
		MISG A 1 A_Lower;
		Loop;
	Ready:
		MISG A 1 RSQGW_Ready();
		Loop;
	Fire:
		MISG A 0
		{
			if (!invoker.TakeRound())
				return RSQGW_Empty();
			A_StartSound("weapons/rocket/fire", CHAN_WEAPON);
			return ResolveState(null);
		}
		MISF A 1 Bright
		{
			A_GunFlash();
			A_FireProjectile('RSQGW_Rocket2', 0, false, 0, 7);
			A_AlertMonsters();
			RSQGW_ShotFX(null);
		}
		MISF B 1 Bright;
		MISF C 1 Bright;
		MISF D 1;
		MISF E 1;
		MISF G 1 A_StartSound("weapons/rocket/cycle", CHAN_AUTO);
		MISG A 1 A_ReFire;
		Goto Ready;
	AltFire:	// none (owner)
		MISG A 1;
		Goto Ready;
	Flash:
		TNT1 A 2 Bright A_Light2;
		TNT1 A 2 Bright A_Light1;
		Goto LightDone;
	StockReload:	// GNRC's: the rockets out, a fresh pack in
		MISR A 0 A_StartSound("weapons/rocket/out", 6);
		MISR ABCDEFGHIJKLMNO 1;
		MISR O 0 { invoker.FillMag(); A_StartSound("weapons/rocket/in", 5); }
		MISR PQRSTUVWXYZ 1;
		MISG A 2;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Plasma Rifle
// GNRC: a Plasma bolt every 5 tics while held (A_FireLedPLRifle), a cooldown when let go; alt charges and fires a rail
// for 20 cells (A_LedPLAltFire, 250-350 damage). Its 60-cell magazine. BD22's Plasma_Gun frames: PRSG G ready,
// PRSG B / C the shot, D E after, PRSA the cooldown, PRSG J K the charge, PRSR the stock reload.
class RSQGW_PlasRifle : RSQGW_Gun replaces PlasmaRifle
{
	Default
	{
		Weapon.SelectionOrder 100;
		Weapon.SlotNumber 6;
		Weapon.AmmoType1 "Cell";
		Weapon.AmmoGive1 30;
		Weapon.AmmoType2 "RSQGW_PlasmaMag";
		Inventory.PickupMessage "You got the Plasma Rifle!";
		Inventory.PickupSound "weapons/prifle/pkup";
		Obituary "%o was melted by %k's plasma rifle.";
		Tag "Plasma Rifle";
		RSQGW_Gun.Chambered false;
		-WEAPON.NOAUTOFIRE
	}
	States
	{
	Spawn:
		PLAS A -1;
		Stop;
	Select:
		PRSG G 0 A_StartSound("weapons/plsweps/upsnd", CHAN_WEAPON);
	SelectLoop:
		PRSG G 1 A_Raise;
		Loop;
	Deselect:
		PRSG G 1 A_Lower;
		Loop;
	Ready:
		PRSG G 1 RSQGW_Ready();
		Loop;
	Fire:	// 5 tics a bolt
		PRSG G 0 { if (!invoker.TakeRound()) return RSQGW_Empty(); return ResolveState(null); }
		PRSG B 1 Bright
		{
			A_GunFlash();
			A_StartSound("weapons/prifle/fire", CHAN_WEAPON);
			A_FireProjectile('RSQGW_Plasma', 0, false, 0, 6);
			A_AlertMonsters();
		}
		PRSG D 1;
		PRSG E 1;
		PRSG F 1;
		PRSG G 1 A_ReFire;
	Cooldown:	// GNRC's: let go, the barrel cools
		PRSA DEFGH 1 { if (!RSQGW_FX.Enhanced()) A_FireProjectile('RSQGW_PistolSmokeSpawner', 0, false, -2, 2); }
		PRSA III 2 A_WeaponReady(WRF_NOBOB | WRF_NOFIRE);
		PRSA HGFED 1;
		Goto Ready;
	AltFire:	// GNRC's rail: 20 cells, charged first
		PRSG G 0
		{
			if (invoker.Loaded() < 20)
				return RSQGW_Empty();
			A_StartSound("weapons/prifle/beep", CHAN_AUTO);
			return ResolveState(null);
		}
		PRSG JKJK 2;
		PRSG J 0 A_StartSound("weapons/prifle/chrge", CHAN_AUTO);
		PRSG JKJKJKJKJ 1;
		PRSG C 1 Bright
		{
			invoker.TakeUpTo(20);
			A_GunFlash();
			A_StartSound("weapons/prifle/altfire", CHAN_AUTO);
			A_RailAttack(random(250, 350), 0, false, "0F59EF", "grey", RGF_NOPIERCING | RGF_SILENT | RGF_FULLBRIGHT, 1);
			A_AlertMonsters();
		}
		PRSG D 1;
		PRSG E 1;
		PRSG F 1;
		Goto Cooldown;
	Flash:
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:	// GNRC's: the cell out, a fresh one in
		PRSR A 0 A_StartSound("weapons/prifle/cout", 6);
		PRSR AAZBCDEFGHH 1;
		PRSR I 10;
		PRSR I 0 { invoker.FillMag(); A_StartSound("weapons/prifle/cin", 5); }
		PRSR JKLMNNO 1;
		PRSR PQRSTTTTUVWXY 1;
		PRSR CZAA 1;
		PRSG G 2;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ BFG
// GNRC: a 23-tic charge, then Doom's BFG ball for 40 cells. No reload (owner: the BFG does not reload): it fires from
// the cells you carry. No alt fire. BD22's BFG frames: BFGN A ready, BFGN the charge, BFGA the shot.
class RSQGW_BFG9K : RSQGW_Gun replaces BFG9000
{
	Default
	{
		Weapon.SelectionOrder 2000;
		Weapon.SlotNumber 7;
		Weapon.AmmoType1 "Cell";
		Weapon.AmmoGive1 40;
		Inventory.PickupMessage "You got the BFG 9000! Hell yes!";
		Inventory.PickupSound "weapons/bfg/pickup";
		Obituary "%o was splintered by %k's BFG.";
		Tag "BFG";
		RSQGW_Gun.Chambered false;
	}
	// the cells it needs, from the reserve
	bool HasCells() { return Ammo1 && (Ammo1.Amount >= 40 || sv_infiniteammo || (Owner && Owner.FindInventory('PowerInfiniteAmmo', true))); }
	States
	{
	Spawn:
		BFUG A -1;
		Stop;
	Select:
		BFGN A 0 A_StartSound("weapons/plsweps/upsnd", CHAN_WEAPON);
	SelectLoop:
		BFGN A 1 A_Raise;
		Loop;
	Deselect:
		BFGN A 1 A_Lower;
		Loop;
	Ready:
		BFGN A 1 RSQGW_Ready();
		Loop;
	Fire:	// GNRC's charge, 23 tics, then the ball
		BFGN A 0
		{
			if (!invoker.HasCells())
			{
				A_StartSound("RSQGW/dry", CHAN_AUTO);
				return ResolveState("DryWait");
			}
			A_StartSound("weapons/bfg/charge", CHAN_AUTO);
			A_StartSound("weapons/bfg/ochrg", CHAN_AUTO);
			return ResolveState(null);
		}
		BFGN AFAF 2;
		BFGN GH 1;
		BFGN I 1 A_StartSound("weapons/bfg/prefir", CHAN_AUTO);
		BFGN JGHIJ 1;
		BFGN KLMNKLMN 1;
		BFGN OPQR 1;
		BFGA A 1 Bright
		{
			if (!(sv_infiniteammo || FindInventory('PowerInfiniteAmmo', true)))
				A_TakeInventory("Cell", 40, TIF_NOTAKEINFINITE);
			A_GunFlash();
			A_AlertMonsters();
			A_StartSound("weapons/bfg/fire", CHAN_WEAPON);
			A_FireProjectile('BFGBall', 0, false);
			RSQGW_ShotFX(null);
		}
		BFGA BC 1 Bright;
		BFGA D 1;
		BFGA EFGHH 1;
		BFGA I 1;
		BFGA JJKL 1;
		BFGN A 21;
		BFGN A 0 A_ReFire;
		Goto Ready;
	AltFire:	// none
		BFGN A 1;
		Goto Ready;
	Reload:		// none (owner)
	StockReload:
		BFGN A 1;
		Goto Ready;
	Flash:
		TNT1 A 3 Bright A_Light1;
		TNT1 A 3 Bright A_Light2;
		Goto LightDone;
	}
}
