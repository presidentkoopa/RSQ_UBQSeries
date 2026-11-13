// RSQ_WeaponsOfSaturn: the Knuckles and the Motorsaw.

// ------------------------------------------------------------------------------------------------ Knuckles
// SPEC (owner): the FBX fists; physical melee comes from the RSQ series (RSQ Melee punches with any weapon that is a
// Fist: gloves.zs IsFist), so the Knuckles are a Fist and their trigger and alt fire are left free. The FBX fist is BD22
// VR's (rsq/hands.zs draws it on the Melee_Attacks mesh: RSQ_Alias). The quick kick works here as on every gun.
class RSQWS_Knuckles : Fist replaces Fist
{
	mixin RSQWS_KickMix;

	Default
	{
		Weapon.SelectionOrder 3700;
		Weapon.SlotNumber 1;
		Weapon.BobStyle "Smooth";
		Weapon.BobSpeed 2.0;
		Weapon.BobRangeX 0.30;
		Weapon.BobRangeY 0.40;
		Obituary "%o was mauled by %k's fists";
		Tag "Knuckles";
		+WEAPON.WIMPY_WEAPON
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
	}
	States
	{
	Select:
		PUNG A 1 A_Raise;
		Loop;
	Deselect:
		PUNG A 1 A_Lower;
		Loop;
	Ready:
		PUNG A 1
		{
			state k = RSQWS_KickCheck();
			if (k)
				return k;
			A_WeaponReady();
			return ResolveState(null);
		}
		Loop;
	Fire:	// free (SPEC): RSQ Melee reads the swing, and the trigger opens and closes the hand
	AltFire:
		PUNG A 1;
		Goto Ready;
	}
}

// ------------------------------------------------------------------------------------------------ Motorsaw
// SPEC (owner): the BD22 Chain_saw mesh, its animations uncoupled as in BD22 VR: in VR the trigger runs the chain
// with no swing animation (BD22 VR Saw.dec RSVR_SawRun) and the player moves the saw; the bar cuts whatever it touches
// (owner: "Port BD22 VR's contact saw": zscript/rsvr/melee.zs, the saw only). Each cut is RSQWS_SawCut, WoS's saw damage
// (random 1-10, its ChainsawPuff). Out of VR: WoS's own saw.
class RSQWS_Motorsaw : RSQWS_Gun replaces Chainsaw
{
	Default
	{
		Weapon.SelectionOrder 2200;
		Weapon.SlotNumber 1;
		Inventory.PickupMessage "A Chain saw! Find some meat!";
		Inventory.PickupSound "weapons/chainsaw/up";
		Obituary "%o was made into lumber by %k's chain saw";
		Tag "Chain Saw";
		+WEAPON.MELEEWEAPON
		+WEAPON.WIMPY_WEAPON
		+EXTREMEDEATH
		-WEAPON.NOAUTOFIRE
	}
	States
	{
	Spawn:
		CSAW Z -1;
		Stop;
	Select:
		SAWG A 0 A_StartSound("weapons/chainsaw/start", CHAN_WEAPON);
	SelectLoop:
		SAWG A 1 A_Raise;
		Loop;
	Deselect:
		SAWG A 0 { A_StopSound(CHAN_BODY); A_StartSound("weapons/chainsaw/lower", CHAN_BODY); }
	DeselectLoop:
		SAWG A 1 A_Lower;
		Loop;
	Ready:
		SAWG A 0 A_StartSound("weapons/chainsaw/idle", CHAN_BODY, CHANF_LOOPING);
	ReadyLoop:
		SAWG AB 4 RSQWS_Ready();
		Loop;
	Fire:
		SAWG A 0
		{
			A_AlertMonsters();
			A_StopSound(CHAN_BODY);
			if (CountInv("RSVR_SawVR") > 0)
				return ResolveState("RSVR_SawRun");
			A_StartSound("weapons/chainsaw/start", CHAN_WEAPON);
			return ResolveState(null);
		}
		SAWG A 2;
	Hold:	// out of VR: WoS's saw
		SAWF S 1 { A_StartSound("weapons/chainsaw/loop", CHAN_WEAPON, CHANF_LOOPING); A_CustomPunch(random(1, 10), true, CPF_PULLIN, "RSQWS_ChainsawPuffSpawner", 96, 0, 0, null, "saw/flesh"); }
		SAWF T 1;
		SAWF S 1 A_CustomPunch(random(1, 10), true, CPF_PULLIN, "RSQWS_ChainsawPuffSpawner", 96, 0, 0, null, "saw/flesh");
		SAWF T 1;
		SAWG A 0 A_ReFire;
		SAWG A 0 { A_StopSound(CHAN_WEAPON); A_StartSound("weapons/chainsaw/stop", CHAN_WEAPON); }
		SAWG A 5;
		Goto Ready;
	RSVR_SawRun:	// in VR: the chain runs, the saw is where the hand puts it, the bar cuts by contact (rsvr/melee.zs)
		SAWG A 0 { A_StartSound("weapons/chainsaw/start", 5); A_StartSound("weapons/chainsaw/loop", CHAN_WEAPON, CHANF_LOOPING); }
	RSVR_SawRunLoop:
		SAWG A 0 A_AlertMonsters;
		SAWG ABAB 1;
		SAWG A 0 A_ReFire("RSVR_SawRunLoop");
		SAWG A 0 { A_StopSound(CHAN_WEAPON); A_StartSound("weapons/chainsaw/stop", CHAN_WEAPON); }
		Goto Ready;
	AltFire:	// nothing yet (WoS's lunge is a screen move): see the report
		SAWG A 1;
		Goto Ready;
	}
}

// one contact cut of the running bar (rsvr/melee.zs RSVR_Hand.Strike, SAW): WoS's saw damage at the point the bar met
// the body, started just inside it so it hits at once (as BD22's SawDamageHorizontal is used there)
class RSQWS_SawCut : Actor
{
	Default
	{
		Projectile;
		Radius 2;
		Height 2;
		Speed 4;
		DamageFunction (random(1, 10));
		+EXTREMEDEATH
		+BLOODSPLATTER
		RenderStyle "None";
		Obituary "%o was made into lumber by %k's chain saw";
	}
	States
	{
	Spawn:
		TNT1 A 2;
		Stop;
	XDeath:
		TNT1 A 0 A_StartSound("saw/flesh", CHAN_AUTO);
		Stop;
	Death:
		TNT1 A 0 A_SpawnItemEx("RSQWS_ChainsawPuffSpawner");
		Stop;
	}
}
