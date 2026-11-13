// RSQ_WeaponsOfSaturn: the MP40 and the Maschine Rifle (SPEC: MP40 = BD22's MP40 mesh, MachineRifle = BD22's Rifle +
// its underbarrel). WoS's fire numbers; WoS's screen kick (A_SetPitch, A_ZoomFactor, Offset) is not carried: in VR it
// moves the player's view. BD22 VR's recoil follow moves the gun instead (rsq/gunmoves.zs).

// MP40 (SPEC, owner: "fires from an open bolt and only operates in fully automatic mode ... 500 to 550 rounds per
// minute"): full auto only, one round every 4 tics (525 rpm), no alt fire. Open bolt: nothing in a chamber, so the
// magazine always fills to 32. Emptied, the hand reload ends with the bolt (Racks).
class RSQWS_MP40 : RSQWS_Gun
{
	Default
	{
		Weapon.SelectionOrder 1200;
		Weapon.SlotNumber 2;
		Weapon.AmmoType1 "Clip";
		Weapon.AmmoGive1 30;
		Weapon.AmmoType2 "RSQWS_MP40Ammo";
		Inventory.PickupMessage "You got the MP40!";
		Inventory.PickupSound "weapon/mp40";
		Obituary "%o was cleansed by %k's MP40.";
		Tag "MP40";
		RSQWS_Gun.Chambered false;
		RSQWS_Gun.Racks true;
		-WEAPON.NOAUTOFIRE
	}
	States
	{
	Spawn:
		MPIC A -1;
		Stop;
	Select:
		MP40 A 0 A_StartSound("weapons/MP40/cock", CHAN_WEAPON);
	SelectLoop:
		MP40 A 1 A_Raise;
		Loop;
	Deselect:
		MP40 A 1 A_Lower;
		Loop;
	Ready:
		MP40 A 1 RSQWS_Ready();
		Loop;
	Fire:	// 4 tics a round
		MP40 A 0 { if (!invoker.TakeRound()) return RSQWS_Empty(); return ResolveState(null); }
		MP40 B 1 Bright
		{
			A_GunFlash();
			A_StartSound("weapons/MP40/fire", 7);
			A_FireBullets(3, 4, -1, 6, "RSQWS_AltPuff", 0);
		}
		MP40 D 1 RSQWS_ShotFX('RSQWS_9mmCasingSpawner');
		MP40 E 1 A_AlertMonsters;
		MP40 A 1 A_ReFire;
		Goto Ready;
	AltFire:	// none (owner: "I don't know how to make an alt fire for this")
		MP40 A 1;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:
		MP4R A 0 A_StartSound("weapons/beretta/magdrop", 6);
		MP4R ABCDEFGHIJKLMN 1;
		MP4R N 0 { invoker.FillMag(); A_StartSound("weapons/MP40/reload", 5); }
		MP4R OPQRSTUVWXY 1;
		MP4R Z 2 A_StartSound("weapons/MP40/cock", 6);
		MP40 A 2;
		Goto Ready;
	}
}

// The Maschine Rifle: WoS's rifle, semi or full as WoS has it (full auto, A_ReFire), its 30 + 1. Alt fire is the
// underbarrel launcher (SPEC: it replaces WoS's iron sights), BD22 VR's (zscript/rsr/rsr_m203.zs): in VR it is loaded by
// hand (off trigger unlatches, push the tube open, a round in, pull it shut); out of VR, or with Reloading on Stock, a
// round goes in by itself if you have one. Its ammo: RSQ Grenade's grenades, else rockets (Rifle Underbarrel Ammo).
class RSQWS_MachineRifle : RSQWS_Gun
{
	Default
	{
		Weapon.SelectionOrder 500;
		Weapon.SlotNumber 4;
		Weapon.AmmoType1 "RSQWS_RifleAmmo";
		Weapon.AmmoGive1 15;
		Weapon.AmmoType2 "RSQWS_Magazine";
		Inventory.PickupMessage "You got the Maschine Rifle!";
		Inventory.PickupSound "weapons/fist/swing";
		Obituary "%o was neutralized by %k's rifle.";
		Tag "Maschine Rifle";
		RSQWS_Gun.Chambered true;
		RSQWS_Gun.Racks true;
		-WEAPON.NOAUTOFIRE
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
		RIFG A 0 A_StartSound("weapons/rifle/deselect", CHAN_WEAPON);
	DeselectLoop:
		RIFG A 1 A_Lower;
		Loop;
	Ready:
		RIFG A 1 RSQWS_Ready();
		Loop;
	Fire:
		RIFG A 0 { if (!invoker.TakeRound()) return RSQWS_Empty(); return ResolveState(null); }
		RIFF A 1 Bright
		{
			A_GunFlash();
			A_StartSound("weapons/rifle/fire", 7);
			A_FireBullets(3, 3, -1, 7, "RSQWS_AltPuff2", 0);
		}
		RIFF B 1 RSQWS_ShotFX('RSQWS_RifleCasingSpawner');
		RIFF C 1 A_AlertMonsters;
		RIFG A 1 A_ReFire;
		Goto Ready;
	Flash:
		TNT1 A 1 Bright A_Light1;
		Goto LightDone;
	StockReload:
		RIFR A 0 A_StartSound("weapons/rifle/out", 6);
		RIFR ABCDEFGH 1;
		RIFR H 0 { invoker.FillMag(); A_StartSound("weapons/rifle/in", 5); }
		RIFR IJKLMNOPQRSTUVW 1;
		RIFR X 1 A_StartSound("weapons/rifle/bolt", 6);
		RIFR YZ 1;
		RIFG A 2;
		Goto Ready;

	// ---- the underbarrel launcher (BD22 VR Rifle.dec, 1:1 in ZScript)
	AltFire:
		RIFG A 0
		{
			if (CountInv("RFGLoaded") > 0)
				return ResolveState("RSM_FireGrenade");
			if (CountInv("RSM_VR") > 0)
				return ResolveState("RSM_Dry");
			A_GiveInventory("RSM_StockLoad", 1);	// out of VR / Stock: a round in by itself, if there is one
			if (CountInv("RFGLoaded") > 0)
				return ResolveState("RSM_FireGrenade");
			return ResolveState("RSM_Dry");
		}
	RSM_Dry:
		RIFG A 0 A_StartSound("Weapon/Empty", CHAN_AUTO);
		RIFG A 8;
		Goto Ready;
	RSM_FireGrenade:
		RIFG A 0
		{
			A_TakeInventory("RFGLoaded", 1);
			A_GiveInventory("FiredMGGrenade", 1);
			A_StartSound("GrenadeLauncher/Fire", 1);
		}
		RIFF A 1 Bright A_FireProjectile("RSQ_M203Grenade", 0, false);	// as BD22 VR: no ammo taken here (RFGLoaded above)
		RIFF B 2;
		RIFF C 2;
		RIFG A 6;
		Goto Ready;
	}
}
