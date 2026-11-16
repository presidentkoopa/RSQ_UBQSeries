// GNRC_Reloaded: the Assault Rifle (BD22's Rifle mesh). GNRC's numbers (base.txt A_FireLedRifle, rifle.txt): 7 damage,
// 2 x 2 spread, one round every 4 tics, its 30 + 1 magazine. It replaces nothing: it drops from GNRC's clip spawners.
//   fire: full auto, or a 3-round burst per pull
//   alt:  switches between the two (owner: "rifle toggle 3 rnd burst")
// BD22's Rifle frames: RIFG A ready, RIFF ABC the shot, RIFR A-Z the stock reload.
// Each mode its own click (owner 2026-11-16 item 8: the HUD text alone is hard to see in VR): full auto a low click,
// burst a high one. RSQ Gun Cards shows the mode on the watch card when it is loaded (RSQGW_GunModeService, by name).
// Vanilla Damage: 5 a round (x 1-3), Doom's chaingun round; 4 tics a round is already the chaingun's rate.
// The underbarrel launcher (owner 2026-11-16 item 12, option "Rifle Underbarrel Launcher", rsqgw_rifle_gl, off): off,
// it is not drawn (RSQGW_Handler wears the rifle's no-launcher frames, MODELDEF.rsqgl); on, it is drawn and, with the
// off hand on the handguard (the engine's two-hand grip), the OFF TRIGGER launches GNRC's own grenade (RSQGW_Grenade2)
// for one rocket, one a second (RSQGW_Handler; the rifle's own triggers stay as they are).
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
		A_FireBullets(2, 2, -1, RSQGW_Gun.Vanilla() ? 5 : 7, "BulletPuff", 0);
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
		RIFG A 1
		{
			if (CountInv("RSQGW_GLGo") > 0)
				return ResolveState("Launch");
			return RSQGW_Ready();
		}
		Loop;
	Launch:	// the underbarrel launcher (RSQGW_Handler: the off trigger with the off hand on the handguard)
		RIFG A 0
		{
			A_TakeInventory("RSQGW_GLGo", 1);
			if (!RSQGW_Handler.LauncherOn())
				return ResolveState("Ready");
			bool inf = sv_infiniteammo || FindInventory('PowerInfiniteAmmo', true);
			if (CountInv("RocketAmmo") < 1 && !inf)
			{
				A_StartSound("RSQGW/dry", CHAN_AUTO);
				return ResolveState("Ready");
			}
			if (!inf)
				A_TakeInventory("RocketAmmo", 1, TIF_NOTAKEINFINITE);
			A_StartSound("weapons/grenade/fire", CHAN_WEAPON);
			A_FireProjectile('RSQGW_Grenade2', 0, false, 0, -4);
			A_AlertMonsters();
			return ResolveState(null);
		}
		RIFG A 4;
		Goto Ready;
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
		RIFG A 1;
		RIFG A 0 A_ReFire;	// 4 tics a round (A_ReFire jumps on the tic it is reached)
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
			// each mode its own click: burst high and quick, full auto low (GNRC's selector click, pitched)
			A_StartSound("weapons/rifle/click", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM, invoker.burstMode ? 1.45 : 0.75);
			A_Print(invoker.burstMode ? "3-round burst" : "Full auto");
			if (RSQGW_Handler.Logs(PlayerPawn(self)))
				Console.Printf("RSQGW rifle t%d: %s, its click at pitch %.2f", level.maptime, invoker.burstMode ? "3-round burst" : "full auto", invoker.burstMode ? 1.45 : 0.75);
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

// the rifle's fire mode for other mods, by name (owner 2026-11-16 item 8): RSQ Gun Cards asks every service whose name
// has "GunModeService" in it, GetString("firemode", objectArg = the gun). "" for anything that is not this pack's rifle.
class RSQGW_GunModeService : Service
{
	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request ~== "firemode"))
			return "";
		let r = RSQGW_ARifle(objectArg);
		if (!r)
			return "";
		return r.burstMode ? "BURST" : "AUTO";
	}
}
