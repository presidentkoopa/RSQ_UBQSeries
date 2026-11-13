// GNRC_Reloaded: the Beretta. GNRC's numbers (base.txt A_FireLedPistol / A_BurstLedPistol, pistol.txt), BD22's
// BrutalPistol frames (the mesh is keyed to them): PIST E ready, PIST A shot, B C D the slide, PISR A-J magazine out,
// PISR K-W magazine in. Its 10 + 1 magazine.
//   fire: one shot, 6 tics a shot (owner: "pistol ROF is 5 or 6 per second": 35 / 6 = 5.8 a second)
//   alt:  GNRC's 3-round burst (three shots 3 tics apart)
class RSQGW_Beretta : RSQGW_Gun replaces Pistol
{
	Default
	{
		Weapon.SelectionOrder 1900;
		Weapon.SlotNumber 2;
		Weapon.AmmoType1 "RSQGW_PistolAmmo";
		Weapon.AmmoGive1 10;
		Weapon.AmmoType2 "RSQGW_PistolMag";
		Inventory.PickupMessage "You got the Pistol!";
		Inventory.PickupSound "weapons/pistol/slide";
		Obituary "%o was shot down by %k's pistol.";
		Tag "Beretta";
		+WEAPON.WIMPY_WEAPON;
		RSQGW_Gun.Chambered true;
		RSQGW_Gun.Racks true;
		RSQGW_Gun.SemiOption true;
	}
	action void RSQGW_Shot(bool burst)
	{
		A_GunFlash();
		A_StartSound("weapons/pistol/fire", CHAN_WEAPON);
		if (burst)
			A_FireBullets(3.5, 2.75, -1, 7, "BulletPuff", 0);
		else
			A_FireBullets(2.25, 1.5, -1, 7, "BulletPuff", 0);
		A_AlertMonsters();
		RSQGW_ShotFX('RSQGW_9mmCasingSpawner', 0, 0.5);
	}
	States
	{
	Spawn:
		RQGP A -1;		// GNRC's pickup (PIST A) under its own name: PIST is the HUD mesh's sprite
		Stop;
	Select:
		PIST E 0 A_StartSound("weapons/pistol/equip", CHAN_WEAPON);
	SelectLoop:
		PIST E 1 A_Raise;
		Loop;
	Deselect:
		PIST E 1 A_Lower;
		Loop;
	Ready:
		PIST E 1 RSQGW_Ready();
		Loop;
	Fire:	// 6 tics a shot
		PIST E 0 { if (!invoker.TakeRound()) return RSQGW_Empty(); return ResolveState(null); }
		PIST A 1 Bright RSQGW_Shot(false);
		PIST B 1;
		PIST C 1;
		PIST D 1;
		PIST A 2;	// 6 tics to the A_ReFire (which jumps on the tic it is reached)
		PIST E 0 { if (RSQGW_SemiOn()) return ResolveState("SemiHold"); return ResolveState(null); }
		PIST E 1 A_ReFire;
		Goto Ready;
	SemiHold:	// Pistol Semi Auto: one shot per trigger pull
		PIST E 1 { if (!RSQGW_TriggerHeld()) return ResolveState("Ready"); A_WeaponReady(WRF_NOFIRE | WRF_NOBOB); return ResolveState(null); }
		Loop;
	AltFire:	// GNRC's burst: three rounds (fewer if the magazine runs out), then 5 tics; held, again (GNRC's A_ReFire)
		PIST E 0 { if (!invoker.TakeRound()) return RSQGW_Empty(); return ResolveState(null); }
		PIST A 1 Bright RSQGW_Shot(true);
		PIST BC 1;
		PIST E 0 { if (!invoker.TakeRound()) return ResolveState("BurstEnd"); return ResolveState(null); }
		PIST A 1 Bright RSQGW_Shot(true);
		PIST BC 1;
		PIST E 0 { if (!invoker.TakeRound()) return ResolveState("BurstEnd"); return ResolveState(null); }
		PIST A 1 Bright RSQGW_Shot(true);
		PIST BC 1;
	BurstEnd:	// as GNRC: held, it bursts again
		PIST D 2;
		PIST A 2;
		PIST E 1 A_ReFire;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:	// GNRC's: the magazine out, the reserve in, the slide if it ran dry
		PIST A 4 A_StartSound("weapons/pistol/cout", 6);
		PISR ABCDEFGHIJ 1;
		PISR J 0 { invoker.FillMag(); A_StartSound("weapons/pistol/cin", 5); }
		PISR KLMNOP 1;
		PISR Q 3 A_StartSound("weapons/pistol/snap", 5);
		PISR RSTUVW 1;
		Goto Ready;
	}
}
