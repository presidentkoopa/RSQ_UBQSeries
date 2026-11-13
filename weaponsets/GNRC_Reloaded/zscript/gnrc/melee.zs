// GNRC_Reloaded: the Brass Knuckle and the Chainsaw.

// ------------------------------------------------------------------------------------------------ Brass Knuckle
// Owner: "we use melee so we don't need punching triggers". The FBX fists; physical melee comes from the RSQ series
// (RSQ Melee punches with any weapon that is a Fist: gloves.zs IsFist), so this is a Fist and its trigger and alt fire
// are left free. The FBX fist is BD22 VR's (rsq/hands.zs draws it on the Melee_Attacks mesh: RSQ_Alias).
class RSQGW_Knuckle : Fist replaces Fist
{
	mixin RSQGW_KickMix;

	Default
	{
		Weapon.SelectionOrder 3700;
		Weapon.SlotNumber 1;
		Weapon.BobStyle "Smooth";
		Weapon.BobSpeed 2.0;
		Weapon.BobRangeX 0.30;
		Weapon.BobRangeY 0.40;
		Obituary "%o was knocked out by %k's brass knuckle.";
		Tag "Brass Knuckle";
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
			state k = RSQGW_KickCheck();
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

// ------------------------------------------------------------------------------------------------ Chainsaw
// The BD22 Chain_saw mesh and BD22 VR's contact saw, as WoS_Reloaded's: in VR the trigger runs the chain with no swing
// animation (BD22 VR Saw.dec RSVR_SawRun) and the player moves the saw; the bar cuts whatever it touches
// (zscript/rsvr/melee.zs, the saw only). Each cut is RSQGW_SawCut, GNRC's saw damage (A_Saw 3, its ChainsawPuffSpawner).
// Out of VR: GNRC's own saw. GNRC's on / off switch (alt fire) is not carried: the trigger runs it.
class RSQGW_ModChainsaw : RSQGW_Gun replaces Chainsaw
{
	Default
	{
		Weapon.SelectionOrder 2200;
		Weapon.SlotNumber 1;
		Inventory.PickupMessage "A Chainsaw! Find some meat!";
		Inventory.PickupSound "chainsaw/pkup";
		Obituary "%o was made into lumber by %k's chainsaw.";
		Tag "Chainsaw";
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
		SAWG AB 4 RSQGW_Ready();
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
	Hold:	// out of VR: GNRC's saw
		SAWF S 1 { A_StartSound("weapons/chainsaw/loop", CHAN_WEAPON, CHANF_LOOPING); A_Saw("", "saw/flesh", 3, "RSQGW_ChainsawPuffSpawner", 8); }
		SAWF T 1;
		SAWF S 1;
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
	AltFire:	// none
		SAWG A 1;
		Goto Ready;
	}
}

// one contact cut of the running bar (rsvr/melee.zs RSVR_Hand.Strike, SAW): GNRC's saw damage at the point the bar met
// the body, started just inside it so it hits at once (as BD22's SawDamageHorizontal is used there)
class RSQGW_SawCut : Actor
{
	Default
	{
		Projectile;
		Radius 2;
		Height 2;
		Speed 4;
		DamageFunction (3);
		+EXTREMEDEATH
		+BLOODSPLATTER
		RenderStyle "None";
		Obituary "%o was made into lumber by %k's chainsaw.";
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
		TNT1 A 0 A_SpawnItemEx("RSQGW_ChainsawPuffSpawner");
		Stop;
	}
}
