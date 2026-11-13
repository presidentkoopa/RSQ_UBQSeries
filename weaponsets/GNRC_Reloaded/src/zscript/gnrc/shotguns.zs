// GNRC_Reloaded: the Riot Shotgun (BD22's Shot_Gun mesh, pump; alt = BD22 VR's slug) and the Double-Barrel Shotgun
// (BD22's SSG mesh, break-open; fire one barrel, alt both). The VR protocols are BD22 VR's, as in WoS_Reloaded:
// RSP_ (zscript/rsr/rsr_pump.zs) and RSB_ (zscript/rsr/rsr_break.zs). GNRC's screen kick and iron sights are not carried.

// ------------------------------------------------------------------------------------------------ Riot Gun
// GNRC: an 8-shell tube, 7 pellets of 6 (A_FireLedShotgun: A_FireBullets(4, 4, 7, 6): 4 x 4 degrees), pumped after
// every shot. Loaded from empty it must be pumped before it fires (BD22's ShotgunWasEmpty, as GNRC's FirstLoad +
// ReloadPump). Pump Shotgun Spread (rsq_pump_spread, BD22 VR's option): Enhanced = 3 x 2.5 degrees, same pellets.
// Alt fire: BD22 VR's Shotgun Slugshot (rsa_sg_slug): the same shell as one round of all seven pellets' damage.
// (GNRC's own alt was iron sights: not carried, as WoS's were not.)
class RSQGW_Riotgun : RSQGW_Gun replaces Shotgun
{
	Default
	{
		Weapon.SelectionOrder 1300;
		Weapon.SlotNumber 3;
		Weapon.AmmoType1 "Shell";
		Weapon.AmmoGive1 8;
		Weapon.AmmoType2 "RSQGW_ShotgunMag";
		Inventory.PickupMessage "You got the Riot Shotgun!";
		Inventory.PickupSound "weapons/riotgun/pump";
		Obituary "%o was blasted by %k's riot shotgun.";
		Tag "Riot Shotgun";
		RSQGW_Gun.Chambered false;	// a tube: it fills to 8
	}
	action void RSQGW_Buck()
	{
		let c = CVar.FindCVar('rsq_pump_spread');
		bool enh = c && c.GetInt() == 1;
		A_FireBullets(enh ? 3 : 4, enh ? 2.5 : 4, 7, 6, "BulletPuff", 0);
	}
	States
	{
	Spawn:
		RIOB A -1;
		Stop;
	Select:
		SHTN A 0 A_StartSound("weapons/sguns/equp", CHAN_WEAPON);
	SelectLoop:
		SHTN A 1 A_Raise;
		Loop;
	Deselect:
		SHTN A 1 A_Lower;
		Loop;
	Ready:	// BD22 VR: a shell the hand pushes home with the gun simply up is fed here (rsr_pump.zs FreeFeed)
		SHTN A 1
		{
			if (CountInv("RSP_ShellIn") > 0)
				return ResolveState("RSP_Feed");
			return RSQGW_Ready();
		}
		Loop;
	RSP_Feed:	// BD22 VR Shotgun.dec RSP_Feed: one pass per credited shell (Shotgun Shells Per Insert, rsr_shell_credit)
		SHTN A 0
		{
			if (invoker.Loaded() <= 0)
				A_GiveInventory("RSQ_ShotgunWasEmpty", 1);	// fed into an empty gun: nothing in the chamber
			while (CountInv("RSP_ShellIn") > 0)
			{
				A_TakeInventory("RSP_ShellIn", 1);
				invoker.LoadOne();
			}
			// loaded into an empty gun: nothing is chambered, so it waits for the pump now (no trigger pull first)
			if (invoker.Loaded() > 0 && CountInv("RSQ_ShotgunWasEmpty") > 0)
				return ResolveState("RSP_P2");
			return ResolveState("Ready");
		}
	Fire:
		SHTN A 0
		{
			if (CountInv("RSQ_ShotgunWasEmpty") > 0)
				return ResolveState("RSP_P2");		// loaded from empty and not pumped yet
			if (!invoker.TakeRound())
				return RSQGW_Empty();
			return ResolveState(null);
		}
		SHTA B 1 Bright
		{
			A_GunFlash();
			A_StartSound("weapons/riotgun/fire", CHAN_WEAPON);
			A_AlertMonsters();
			RSQGW_Buck();
		}
		SHTA C 1 RSQGW_ShotFX(null);
		SHTA D 1 A_AlertMonsters;
		SHTN A 5;
	Pump:	// BD22 VR: the hand works the pump; not in VR (or Stock), the gun's own pump
		SHTN A 0
		{
			A_TakeInventory("RSP_Go", 1);
			A_GiveInventory("RSP_PumpStart", 12);
			if (CountInv("RSP_Go") > 0)
				return ResolveState("RSP_P1Go");
			return ResolveState("PumpStock");
		}
	PumpStock:	// GNRC's pump: back, the hull out, forward
		SHT8 G 1 A_StartSound("weapons/riotgun/bck", CHAN_WEAPON);
		SHT8 HI 1;
		SHT8 J 2 A_FireProjectile("RSQGW_ShotgunCasingSpawner", 0, false, 2, -2.75);
		SHT8 J 1 A_StartSound("weapons/riotgun/fwd", CHAN_WEAPON);
		SHT8 IHG 1;
		SHTN A 3;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;

	// ---- the slug (alt fire)
	AltFire:
		SHTN A 0
		{
			if (CountInv("RSQ_ShotgunWasEmpty") > 0)
				return ResolveState("RSP_P2");
			let c = CVar.GetCVar('rsa_sg_slug', player);
			if (c && !c.GetBool())
				return ResolveState("Ready");
			if (!invoker.TakeRound())
				return RSQGW_Empty();
			return ResolveState(null);
		}
		SHTA B 1 Bright
		{
			A_GunFlash();
			A_StartSound("weapons/riotgun/fire", CHAN_WEAPON);
			A_AlertMonsters();
			A_FireBullets(0, 0, 1, 42, "BulletPuff", 0);	// 7 pellets x 6
		}
		SHTA C 1 RSQGW_ShotFX(null);
		SHTA D 1 A_AlertMonsters;
		SHTA E 1;
		SHTN A 3;
		Goto Pump;

	// ---- the reload: shells by hand (VR), GNRC's own otherwise
	Reload:
		SHTN A 0
		{
			if (!invoker.CanReload())
				return ResolveState("Ready");
			A_TakeInventory("RSP_Go", 1);
			A_GiveInventory("RSP_LoadStart", 1);
			if (CountInv("RSP_Go") > 0)
				return ResolveState("RSP_LoadGo");
			return ResolveState("StockReload");
		}
	StockReload:	// GNRC's: tilt, a shell at a time (fire stops it), pumped if it was empty
		SHTN A 0 { if (invoker.Loaded() <= 0) A_GiveInventory("RSQ_ShotgunWasEmpty", 1); }
		SHTN BCDEF 1;
	StockShell:
		SHTN V 0
		{
			if (!invoker.LoadOne())
				return ResolveState("StockEnd");
			A_StartSound("weapons/riotgun/load", 5);
			return ResolveState(null);
		}
		SHTN VWXY 2 A_WeaponReady(WRF_NOBOB | WRF_NOSWITCH | WRF_NOSECONDARY);
		Goto StockShell;
	StockEnd:
		SHTN FEDCB 1;
		SHTN A 0 { if (CountInv("RSQ_ShotgunWasEmpty") > 0) return ResolveState("RSP_P2"); return ResolveState(null); }
		SHTN A 2;
		Goto Ready;

	// ---- RSR-PUMP (BD22 VR's Shot_Gun states, this mod's ammo)
	RSP_P1Go:
		"####" "#" 0 A_TakeInventory("RSP_Go", 1);
	RSP_P1Wait:	// the hand works the pump (the script moves it)
		"####" "#" 1 A_WeaponReady(WRF_NOFIRE | WRF_NOBOB | WRF_NOSECONDARY | WRF_ALLOWRELOAD);
		"####" "#" 0
		{
			A_GiveInventory("RSP_PTick", 1);
			if (CountInv("RSP_Back") > 0) return ResolveState("RSP_P1Back");
			if (CountInv("RSP_Fwd") > 0) return ResolveState("RSP_P1Fwd");
			if (CountInv("RSP_ShellIn") > 0) return ResolveState("RSP_P1Feed");
			if (CountInv("RSP_Insert") > 0) return ResolveState("RSP_VRIns");
			if (CountInv("RSP_Auto") > 0) return ResolveState("RSP_P1Auto");
			if (CountInv("RSP_Ready") > 0) return ResolveState("RSP_P1Ready");
			return ResolveState("RSP_P1Wait");
		}
	RSP_P1Feed:	// shells topped off while the gun waits for the pump
		"####" "#" 0 { while (CountInv("RSP_ShellIn") > 0) { A_TakeInventory("RSP_ShellIn", 1); invoker.LoadOne(); } }
		Goto RSP_P1Wait;
	RSP_P1Back:	// all the way back: the spent shell out of the port
		"####" "#" 0 { A_TakeInventory("RSP_Back", 1); A_GiveInventory("RSP_CaseOut", 1); }
		Goto RSP_P1Wait;
	RSP_P1Fwd:
		"####" "#" 0 { A_TakeInventory("RSP_Fwd", 1); if (CountInv("RSP_Ready") > 0) return ResolveState("RSP_P1Ready"); return ResolveState("RSP_P1Wait"); }
	RSP_P1Ready:
		SHTN A 0 A_TakeInventory("RSP_Ready", 1);
		Goto Ready;
	RSP_P1Auto:	// the hand left the pump before working it: the gun's own pump
		SHTN A 0 A_TakeInventory("RSP_Auto", 1);
		Goto PumpStock;
	RSP_VRIns:	// a shell brought to the port with the gun simply up
		SHTN A 0
		{
			A_TakeInventory("RSP_Insert", 1);
			A_TakeInventory("RSP_Go", 1);
			A_GiveInventory("RSP_LoadStart", 1);
			if (CountInv("RSP_Go") > 0)
				return ResolveState("RSP_LoadGo");
			return ResolveState("Ready");
		}
	RSP_LoadGo:
		SHTN A 0 { A_TakeInventory("RSP_Go", 1); if (invoker.Loaded() <= 0) A_GiveInventory("RSQ_ShotgunWasEmpty", 1); }
	RSP_Next:	// room for another shell, and one to take?
		SHTN A 0
		{
			if (!invoker.CanReload())
				return ResolveState("RSP_LoadEnd");
			if (CountInv("RSQ_ShotgunWasEmpty") > 0)
				return ResolveState("RSP_LoadWaitE");
			return ResolveState(null);
		}
	RSP_LoadWait:	// the hand loads shells; fire ends the reload
		SHTN A 1 A_WeaponReady(WRF_NOBOB);
		Goto RSP_LoadTick;
	RSP_LoadWaitE:	// ...loaded from empty: no shot until the pump has been worked
		SHTN A 1 A_WeaponReady(WRF_NOBOB | WRF_NOFIRE | WRF_NOSECONDARY);
	RSP_LoadTick:
		SHTN A 0
		{
			A_GiveInventory("RSP_LTick", 1);
			if (CountInv("RSP_ShellIn") > 0) return ResolveState("RSP_Shell");
			if (CountInv("RSP_Back") > 0) return ResolveState("RSP_LBack");
			if (CountInv("RSP_Fwd") > 0) return ResolveState("RSP_LFwd");
			if (CountInv("RSQ_ShotgunWasEmpty") > 0) return ResolveState("RSP_LoadWaitE");
			return ResolveState("RSP_LoadWait");
		}
	RSP_Shell:	// a shell pushed home: one from the reserve into the tube
		SHTN A 0
		{
			A_TakeInventory("RSP_ShellIn", 1);
			if (!invoker.LoadOne())
				return ResolveState("RSP_LoadEnd");
			return ResolveState("RSP_Next");
		}
	RSP_LBack:
		SHTN A 0 { A_TakeInventory("RSP_Back", 1); if (CountInv("RSQ_ShotgunWasEmpty") > 0) return ResolveState("RSP_LoadWaitE"); return ResolveState("RSP_LoadWait"); }
	RSP_LFwd:	// a full stroke while loading chambers a shell and ends the reload
		SHTN A 0 { A_TakeInventory("RSP_Fwd", 1); if (invoker.Loaded() > 0) A_TakeInventory("RSQ_ShotgunWasEmpty", 1); }
	RSP_LoadEnd:
		SHTN A 0 { A_TakeInventory("RSP_ShellIn", 999); if (CountInv("RSQ_ShotgunWasEmpty") > 0) return ResolveState("RSP_P2"); return ResolveState("Ready"); }
	RSP_P2:	// the pump that chambers the first shell of a gun loaded from empty: no shot, no slug, until it is worked
		SHTN A 0
		{
			if (invoker.Loaded() <= 0)
			{
				A_TakeInventory("RSQ_ShotgunWasEmpty", 1);
				return ResolveState("Ready");
			}
			A_TakeInventory("RSP_Go", 1);
			A_GiveInventory("RSP_PumpStart", 12);
			if (CountInv("RSP_Go") > 0)
				return ResolveState("RSP_P2Go");
			return ResolveState("RSP_P2Stock");
		}
	RSP_P2Go:
		"####" "#" 0 A_TakeInventory("RSP_Go", 1);
	RSP_P2Wait:
		"####" "#" 1 A_WeaponReady(WRF_NOFIRE | WRF_NOBOB | WRF_NOSECONDARY | WRF_ALLOWRELOAD);
		"####" "#" 0
		{
			A_GiveInventory("RSP_PTick", 1);
			if (CountInv("RSP_Back") > 0) return ResolveState("RSP_P2Back");
			if (CountInv("RSP_Fwd") > 0) return ResolveState("RSP_P2Fwd");
			if (CountInv("RSP_ShellIn") > 0) return ResolveState("RSP_P2Feed");
			if (CountInv("RSP_Insert") > 0) return ResolveState("RSP_VRIns");
			if (CountInv("RSP_Auto") > 0) return ResolveState("RSP_P2Auto");
			if (CountInv("RSP_Ready") > 0) return ResolveState("RSP_P2Ready");
			return ResolveState("RSP_P2Wait");
		}
	RSP_P2Feed:
		"####" "#" 0 { while (CountInv("RSP_ShellIn") > 0) { A_TakeInventory("RSP_ShellIn", 1); invoker.LoadOne(); } }
		Goto RSP_P2Wait;
	RSP_P2Back:	// all the way back: nothing was fired, so nothing comes out
		"####" "#" 0 A_TakeInventory("RSP_Back", 1);
		Goto RSP_P2Wait;
	RSP_P2Fwd:	// forward again: chambered
		"####" "#" 0 { A_TakeInventory("RSP_Fwd", 1); A_TakeInventory("RSQ_ShotgunWasEmpty", 1); if (CountInv("RSP_Ready") > 0) return ResolveState("RSP_P2Ready"); return ResolveState("RSP_P2Wait"); }
	RSP_P2Ready:
		SHTN A 0 { A_TakeInventory("RSP_Ready", 1); A_TakeInventory("RSQ_ShotgunWasEmpty", 1); }
		Goto Ready;
	RSP_P2Auto:
		SHTN A 0 A_TakeInventory("RSP_Auto", 1);
	RSP_P2Stock:	// the hand is not on the pump (or not in VR): it is pumped for you, and no shell comes out
		SHT8 G 1 A_StartSound("weapons/riotgun/bck", CHAN_AUTO);
		SHT8 HI 1;
		SHT8 J 2;
		SHT8 I 1 A_StartSound("weapons/riotgun/fwd", CHAN_AUTO);
		SHT8 HG 1;
		SHTN A 2 A_TakeInventory("RSQ_ShotgunWasEmpty", 1);
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Double-Barrel Shotgun
// GNRC: fire one barrel, 9 pellets of 6 (A_FireLedSSGRight / Left: 6 x 5 degrees), the right while both are loaded, then
// the left; alt both at once (A_FireLedSSG: 11 x 8, 20 pellets of 6). With one shell in it, alt fires that one barrel.
// Reloaded break-open by hand in VR (rsr_break.zs), GNRC's own reload otherwise and on the flick.
class RSQGW_DoubleSG : RSQGW_Gun replaces SuperShotgun
{
	Default
	{
		Weapon.SelectionOrder 400;
		Weapon.SlotNumber 3;
		Weapon.AmmoType1 "Shell";
		Weapon.AmmoGive1 6;
		Weapon.AmmoType2 "RSQGW_DBSGMag";
		Inventory.PickupMessage "You got the Double-Barrel Shotgun!";
		Inventory.PickupSound "weapons/dbsg/opn";
		Obituary "%o was splattered by %k's super shotgun.";
		Tag "Double-Barrel Shotgun";
		Weapon.BobRangeX 0.15;
		RSQGW_Gun.Chambered false;
	}
	States
	{
	Spawn:
		DBBL A -1;
		Stop;
	Select:
		SHT2 A 1 A_Raise;
		Loop;
	Deselect:
		SHT2 A 1 A_Lower;
		Loop;
	Ready:
		SHT2 A 1 RSQGW_Ready();
		Loop;
	Fire:
		SHT2 A 0
		{
			bool both = invoker.Loaded() >= 2;
			if (!invoker.TakeRound())
				return RSQGW_Empty();
			A_StartSound("weapons/dbsg/sfir", CHAN_WEAPON);
			return ResolveState(null);
		}
		SHT2 C 1 Bright { A_GunFlash(); A_FireBullets(6, 5, 9, 6, "BulletPuff", 0); }
		SHT2 E 1 { A_AlertMonsters(); RSQGW_ShotFX(null); }
		SHT2 A 4;
		Goto Ready;
	AltFire:
		SHT2 A 0
		{
			if (invoker.Loaded() < 2)
				return ResolveState("Fire");
			invoker.TakeRound(2);
			A_StartSound("weapons/kapow", CHAN_WEAPON);
			return ResolveState(null);
		}
		SHT2 C 1 Bright { A_GunFlash(); A_FireBullets(11, 8, 20, 6, "BulletPuff", 0); }
		SHT2 E 1 { A_AlertMonsters(); RSQGW_ShotFX(null); }
		SHT2 A 6;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;

	// ---- RSR-BREAK: opened and loaded by hand (VR), GNRC's own reload otherwise
	Reload:
		SHT2 A 0
		{
			if (!invoker.CanReload())
				return ResolveState("Ready");
			if (invoker.InOffHand())
				return ResolveState("StockReload");
			A_TakeInventory("RSB_Go", 1);
			A_GiveInventory("RSB_Start", 1);
			if (CountInv("RSB_Go") > 0)
				return ResolveState("RSB_Open");
			return ResolveState("StockReload");
		}
	RSB_Open:
		SHT2 A 0 A_TakeInventory("RSB_Go", 1);
	RSB_Wait:	// the gun as the script shows it; the script runs every tic
		"####" "#" 1 A_WeaponReady(WRF_NOBOB | WRF_NOFIRE);
		"####" "#" 0
		{
			A_GiveInventory("RSB_Tick", 1);
			if (CountInv("RSB_EjectT") > 0) return ResolveState("RSB_Eject");
			if (CountInv("RSB_LoadT") > 0) return ResolveState("RSB_Load");
			if (CountInv("RSB_Done") > 0) return ResolveState("RSB_Done");
			return ResolveState("RSB_Wait");
		}
	RSB_Eject:	// GNRC's own casing, one per fired barrel
		"####" "#" 0
		{
			while (CountInv("RSB_EjectT") > 0)
			{
				A_TakeInventory("RSB_EjectT", 1);
				A_FireProjectile("RSQGW_SSGCasingSpawner", 0, false, -8, -6);
			}
		}
		Goto RSB_Wait;
	RSB_Load:	// one shell pushed home in a barrel
		"####" "#" 0 { A_TakeInventory("RSB_LoadT", 1); invoker.LoadOne(); }
		Goto RSB_Wait;
	RSB_Done:	// shut
		SHT2 A 0 A_TakeInventory("RSB_Done", 1);
		Goto Ready;
	RSQ_FlickReload:	// the flick's own reload (zscript/rsq/flick.zs): GNRC's reload, never the hand reload
		SHT2 A 0 { if (!invoker.CanReload()) return ResolveState("Ready"); return ResolveState("StockReload"); }
	StockReload:	// GNRC's: open, the spent hulls out, shells in, shut
		SHTZ B 1 A_StartSound("weapons/dbsg/opn", 5);
		SHTZ CDEFG 1;
		SHTZ H 2
		{
			for (int k = invoker.Loaded(); k < 2; k++)
				A_FireProjectile("RSQGW_SSGCasingSpawner", 0, false, -8, -6);
		}
		SHTZ L 2 A_StartSound("weapons/dbsg/load", 6);
		SHTZ QSTU 2;
		SHTZ V 2 { invoker.FillMag(); }
		SHTZ H 1 A_StartSound("weapons/dbsg/cls", CHAN_WEAPON);
		SHTZ GFEDCB 1;
		SHT2 A 2;
		Goto Ready;
	}
}
