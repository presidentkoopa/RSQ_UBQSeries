// The pistols. WoS's numbers (PISTOL.txt, 1911.txt), BD22's frames (the meshes are keyed to them):
// BrutalPistol PIST E ready, PIST A shot, B C D the slide, PISR A-J magazine out, PISR K-W magazine in.
// The 1911 shows the same frames: its own mesh (BrutalWolf 1911) is keyed to them (MODELDEF), and it sits where
// BrutalPistol sits in the FBX pistol hand (tools/seat_1911.py), so the pistol's hand, recoil and muzzle rows apply.
// Kicks are gone (SPEC: BD's quick kick, any gun): alt fire is free on both.

class RSQWS_Beretta : RSQWS_Gun replaces Pistol
{
	Default
	{
		Weapon.SelectionOrder 2000;
		Weapon.SlotNumber 2;
		Weapon.AmmoType1 "Clip";
		Weapon.AmmoGive1 12;
		Weapon.AmmoType2 "RSQWS_9mm";
		Inventory.PickupMessage "Picked up a handgun";
		Inventory.PickupSound "weapons/fist/swing";
		Inventory.Icon "CLIPB0";
		Obituary "%o was humiliated by %k's side-arm";
		Tag "Beretta";
		+WEAPON.WIMPY_WEAPON;
		RSQWS_Gun.Chambered true;
		RSQWS_Gun.Racks true;
		RSQWS_Gun.SemiOption true;
	}
	States
	{
	Spawn:
		RQWP A -1;		// WoS's pickup (PIST A) under its own name: PIST is the HUD mesh's sprite
		Stop;
	Select:
		PIST E 0 A_StartSound("weapons/beretta/snap", CHAN_WEAPON);
	SelectLoop:
		PIST E 1 A_Raise;
		Loop;
	Deselect:
		PIST E 1 A_Lower;
		Loop;
	Ready:
		PIST E 1 RSQWS_Ready();
		Loop;
	Fire:
		PIST E 0 { if (!invoker.TakeRound()) return RSQWS_Empty(); return ResolveState(null); }
		PIST A 1 A_GunFlash;
		PIST A 0 A_StartSound("weapons/beretta/fire", 7);
		PIST A 1 Bright A_FireBullets(3, 3, -1, 6, "RSQWS_AltPuff", 0);
		PIST B 1 A_AlertMonsters;
		PIST B 0 RSQWS_ShotFX('RSQWS_9mmCasingSpawner');
		PIST CC 1;
		PIST D 1;
		PIST A 2;
		PIST E 0 { if (RSQWS_SemiOn()) return ResolveState("SemiHold"); return ResolveState(null); }
		PIST E 1 A_ReFire;
		Goto Ready;
	SemiHold:	// Pistol Semi Auto: one shot per trigger pull
		PIST E 1 { if (!RSQWS_TriggerHeld()) return ResolveState("Ready"); A_WeaponReady(WRF_NOFIRE | WRF_NOBOB); return ResolveState(null); }
		Loop;
	AltFire:
		PIST E 1;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:	// WoS's reload: the magazine out, the reserve in, the slide if it ran dry
		PIST A 4 A_StartSound("weapons/beretta/magdrop", 6);
		PISR ABCDEFGHIJ 1;
		PISR J 0 { invoker.FillMag(); }
		PISR KLMNOP 1;
		PISR Q 3 A_StartSound("weapons/beretta/snap", 5);
		PISR RSTUVW 1;
		Goto Ready;
	}
}

class RSQWS_1911 : RSQWS_Gun
{
	Default
	{
		Weapon.SelectionOrder 1911;
		Weapon.SlotNumber 2;	// owner 2026-11-12: a slot-2 pistol (WoS had it on 8)
		Weapon.AmmoType1 "RSQWS_Bullets";
		Weapon.AmmoGive1 4;
		Weapon.AmmoType2 "RSQWS_ACP";
		Inventory.PickupMessage "You got the 1911!";
		Inventory.PickupSound "weapons/fist/swing";
		Obituary "%o was liberated by %k's 1911";
		Tag "1911";
		RSQWS_Gun.Chambered true;
		RSQWS_Gun.Racks true;
		RSQWS_Gun.SemiOption true;
	}
	States
	{
	Spawn:
		COLP A -1;
		Stop;
	Select:
		PIST E 0 A_StartSound("weapons/1911/slide", CHAN_WEAPON);
	SelectLoop:
		PIST E 1 A_Raise;
		Loop;
	Deselect:
		PIST E 1 A_Lower;
		Loop;
	Ready:
		PIST E 1 RSQWS_Ready();
		Loop;
	Fire:
		PIST E 0 { if (!invoker.TakeRound()) return RSQWS_Empty(); return ResolveState(null); }
		PIST A 1 A_GunFlash;
		PIST A 0 A_StartSound(RSQWS_FX.Enhanced() ? "rsqws/1911/fire" : "weapons/1911/fire", 7);	// Ballistics Stock: WoS's 1911; Low / Max: the 1911's own (owner's file; WoS's until it comes)
		PIST A 1 Bright A_FireBullets(4, 4, -1, 18, "RSQWS_AltPuff2", 0);
		PIST B 1 A_AlertMonsters;
		PIST B 0 RSQWS_ShotFX('RSQWS_45CasingSpawner');
		PIST CC 1;
		PIST D 2;
		PIST A 2;
		PIST E 0 { if (RSQWS_SemiOn()) return ResolveState("SemiHold"); return ResolveState(null); }
		PIST E 2 A_ReFire;
		Goto Ready;
	SemiHold:
		PIST E 1 { if (!RSQWS_TriggerHeld()) return ResolveState("Ready"); A_WeaponReady(WRF_NOFIRE | WRF_NOBOB); return ResolveState(null); }
		Loop;
	AltFire:
		PIST E 1;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light2;
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:
		PIST A 4 A_StartSound("weapons/1911/reload", 6);
		PISR ABCDEFGHIJ 1;
		PISR J 0 { invoker.FillMag(); }
		PISR KLMNOP 1;
		PISR Q 3 A_StartSound("weapons/1911/snap", 5);
		PISR RSTUVW 1;
		Goto Ready;
	}
}
