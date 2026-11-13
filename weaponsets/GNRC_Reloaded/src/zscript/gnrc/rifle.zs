// GNRC_Reloaded: the Assault Rifle (BD22's Rifle mesh). GNRC's numbers (base.txt A_FireLedRifle, rifle.txt): 7 damage,
// 2 x 2 spread, one round every 4 tics, its 30 + 1 magazine. It replaces nothing: it drops from GNRC's clip spawners.
//   fire: full auto, or a 3-round burst per pull
//   alt:  switches between the two (owner: "rifle toggle 3 rnd burst")
// BD22's Rifle frames: RIFG A ready, RIFF ABC the shot, RIFR A-Z the stock reload.
class RSQGW_ARifle : RSQGW_Gun
{
	bool burstMode;

	Default
	{
		Weapon.SelectionOrder 2500;
		Weapon.SlotNumber 2;
		Weapon.AmmoType1 "RSQGW_RifleAmmo";
		Weapon.AmmoGive1 30;
		Weapon.AmmoType2 "RSQGW_RifleMag";
		Inventory.PickupMessage "You got the Assault Rifle!";
		Inventory.PickupSound "weapons/rifle/pkup";
		Obituary "%o was gunned down by %k's assault rifle.";
		Tag "Assault Rifle";
		RSQGW_Gun.Chambered true;
		RSQGW_Gun.Racks true;
		-WEAPON.NOAUTOFIRE
	}
	action void RSQGW_Shot()
	{
		A_GunFlash();
		A_StartSound("weapons/rifle/fire", CHAN_WEAPON);
		A_FireBullets(2, 2, -1, 7, "BulletPuff", 0);
		A_AlertMonsters();
		RSQGW_ShotFX('RSQGW_RifleCasingSpawner', 1, -6);
	}
	States
	{
	Spawn:
		RIFL A -1;
		Stop;
	Select:
		RIFG A 0 A_StartSound("weapons/rifle/up", CHAN_WEAPON);
	SelectLoop:
		RIFG A 1 A_Raise;
		Loop;
	Deselect:
		RIFG A 1 A_Lower;
		Loop;
	Ready:
		RIFG A 1 RSQGW_Ready();
		Loop;
	Fire:
		RIFG A 0
		{
			if (!invoker.TakeRound())
				return RSQGW_Empty();
			if (invoker.burstMode)
				return ResolveState("Burst");
			return ResolveState(null);
		}
		RIFF A 1 Bright RSQGW_Shot();
		RIFF B 1;
		RIFF C 1;
		RIFG A 1 A_ReFire;
		Goto Ready;
	Burst:	// three rounds, 4 tics apart (fewer if the magazine runs out), one burst per pull
		RIFF A 1 Bright RSQGW_Shot();
		RIFF BC 1;
		RIFG A 1;
		RIFG A 0 { if (!invoker.TakeRound()) return ResolveState("BurstHold"); return ResolveState(null); }
		RIFF A 1 Bright RSQGW_Shot();
		RIFF BC 1;
		RIFG A 1;
		RIFG A 0 { if (!invoker.TakeRound()) return ResolveState("BurstHold"); return ResolveState(null); }
		RIFF A 1 Bright RSQGW_Shot();
		RIFF BC 1;
		RIFG A 1;
	BurstHold:
		RIFG A 1 { if (!RSQGW_TriggerHeld()) return ResolveState("Ready"); A_WeaponReady(WRF_NOFIRE | WRF_NOBOB); return ResolveState(null); }
		Loop;
	AltFire:	// full auto <-> 3-round burst
		RIFG A 0
		{
			invoker.burstMode = !invoker.burstMode;
			A_StartSound("weapons/rifle/click", CHAN_AUTO);
			A_Print(invoker.burstMode ? "3-round burst" : "Full auto");
		}
		RIFG A 1;
	AltHold:	// one switch per pull
		RIFG A 1 { if (!player || !(player.cmd.buttons & BT_ALTATTACK)) return ResolveState("Ready"); A_WeaponReady(WRF_NOFIRE | WRF_NOBOB); return ResolveState(null); }
		Loop;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:	// GNRC's: the magazine out, the reserve in, the slap, the bolt if it ran dry
		RIFR A 0 A_StartSound("weapons/rifle/cout", 6);
		RIFR ABCDEFGH 1;
		RIFR H 0 { invoker.FillMag(); A_StartSound("weapons/rifle/cin", 5); }
		RIFR IJKLMNOPQRSTUVW 1;
		RIFR X 1 A_StartSound("weapons/rifle/slap", 6);
		RIFR YZ 1;
		RIFG A 2 A_StartSound("weapons/rifle/click", CHAN_AUTO);
		Goto Ready;
	}
}
