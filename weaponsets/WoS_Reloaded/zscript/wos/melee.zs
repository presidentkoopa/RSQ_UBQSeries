// RSQ_WeaponsOfSaturn: the Knuckles and the Motorsaw.

// ------------------------------------------------------------------------------------------------ Knuckles
// SPEC (owner): the FBX fists; physical melee comes from the RSQ series (RSQ Melee punches with any weapon that is a
// Fist: gloves.zs IsFist) or the basics' punches, so the Knuckles are a Fist and in VR their trigger and alt fire are
// left free. With Punches off (and no RSQ Melee), or out of VR, the trigger punches (owner 2026-11-16 03:30). The FBX fist is BD22
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
	Fire:	// in VR with the punches on, free (SPEC): RSQ Melee or the basics read the swing, and the trigger opens and closes
			// the hand. Otherwise (Punches off, or out of VR) the trigger punches, as BD22 VR's fists do (owner 03:30)
		PUNG A 0 { if (RSQWS_ArmPunches()) return ResolveState("FreeTrigger"); return ResolveState(null); }
		PUNG A 0 A_StartSound("weapons/fist/swing", CHAN_WEAPON);
		PUNG A 3;
		PUNG A 0 RSQWS_TriggerPunch();
		PUNG A 6;
		PUNG A 0 A_ReFire;
		Goto Ready;
	AltFire:
	FreeTrigger:
		PUNG A 1;
		Goto Ready;
	}

	// the arm throws the punches: in VR, and RSQ Melee is loaded (its punches, always) or the basics' Punches are on
	action bool RSQWS_ArmPunches()
	{
		let mo = PlayerPawn(self);
		if (!mo || !player || !RSVR_VRHand.InVR(mo))
			return false;
		if (Object.FindClass("RSQML_Gloves") != null)
			return true;
		return RSQ.PlayerInt(mo, 'rsqb_punch', 1) != 0;
	}
	// the trigger's punch: the basics' punch numbers (Doom's: 2 x 1-10, berserk x10), 64 units, WoS's own puff and sounds
	action void RSQWS_TriggerPunch()
	{
		int dmg = 2 * random(1, 10);
		if (FindInventory('PowerStrength', true)) dmg *= 10;
		A_CustomPunch(dmg, true, CPF_NOTURN, 'RSQWS_FistPuff', 64);
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

	// THE REV BURST (owner 2026-11-16 03:33): alt fire revs the chain for REV tics: it runs by itself (in VR the bar cuts what
	// it touches, out of VR WoS's saw), each cut doing twice the saw's damage (RSQWS_SawCutRev), louder and higher, the hand
	// buzzing. Then REV_COOL tics before it will rev again (alt fire only coughs). The trigger works as before throughout.
	int revUntil, coolUntil;
	const REV = 35;			// 1 s
	const REV_COOL = 70;	// 2 s after the burst
	static bool Revving(Actor mo)
	{
		let p = mo ? mo.player : null;
		let w = p ? RSQWS_Motorsaw(p.ReadyWeapon) : null;
		return w && mo.Level.maptime < w.revUntil;
	}
	action state RSQWS_RevTic(bool cut)
	{
		if (level.maptime >= invoker.revUntil)
		{
			A_StopSound(CHAN_WEAPON);
			A_StartSound("weapons/chainsaw/stop", CHAN_WEAPON);
			return ResolveState("Ready");
		}
		A_AlertMonsters();
		if ((level.maptime - invoker.revUntil) % 4 == 0)
			RSQB_GN_Buzzer.Start(self, 0, 0.55, 4);
		if (cut && CountInv("RSVR_SawVR") <= 0)	// out of VR: WoS's saw, twice the damage
			A_CustomPunch(2 * random(1, 10), true, CPF_PULLIN, "RSQWS_ChainsawPuffSpawner", 96, 0, 0, null, "saw/flesh");
		return ResolveState(null);
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
	AltFire:	// the rev burst (owner 03:33); cooling down, it only coughs
		SAWG A 0
		{
			if (level.maptime < invoker.coolUntil)
			{
				A_StartSound("weapons/chainsaw/lower", CHAN_AUTO, 0, 0.6);
				return ResolveState("RevRefused");
			}
			invoker.revUntil = level.maptime + REV;
			invoker.coolUntil = invoker.revUntil + REV_COOL;
			A_StopSound(CHAN_BODY);
			A_StartSound("weapons/chainsaw/start", 5, 0, 1.0, ATTN_NORM, 1.3);
			A_StartSound("weapons/chainsaw/loop", CHAN_WEAPON, CHANF_LOOPING, 1.0, ATTN_NORM, 1.35);
			if (CountInv("RSVR_SawVR") > 0)
				return ResolveState("RevVR");
			return ResolveState(null);
		}
	RevLoop:	// out of VR: WoS's saw animation
		SAWF S 1 RSQWS_RevTic(true);
		SAWF T 1 RSQWS_RevTic(false);
		Loop;
	RevVR:	// in VR: the chain runs, the hand moves the saw, the bar cuts by contact (rsvr/melee.zs: RSQWS_SawCutRev)
		SAWG A 1 RSQWS_RevTic(false);
		SAWG B 1 RSQWS_RevTic(false);
		Loop;
	RevRefused:
		SAWG A 6;
		Goto Ready;
	}
}

// a cut during the rev burst: twice the saw's damage
class RSQWS_SawCutRev : RSQWS_SawCut
{
	Default
	{
		DamageFunction (2 * random(1, 10));
	}
}

// ------------------------------------------------------------------------------------------------ the butt strike
// Owner 2026-11-16 03:33: both hands on a long gun (Maschine Rifle, MP40, Riot Gun, Coach Gun), drive the stock forward
// and it smacks what it meets. The detection is BD22 VR's own (rsvr/melee.zs: the butt rows measured on these meshes, the
// stock leading, both hands on, a forward blow); the blow is WoS's kick (2 x 5-15, berserk x10), a thud, the hand's buzz;
// then COOL tics before the next one. Butt Strike (rsqws_butt) turns it off. VR only (it is a swing of the real gun).
class RSQWS_ButtStrike : Actor
{
	const COOL = 18;	// about half a second between strikes
	Default
	{
		Projectile;
		Radius 8;
		Height 8;
		Speed 16;
		DamageFunction (2 * random(5, 15));
		DamageType "Melee";
		+NOGRAVITY
		+BLOODSPLATTER
		+NOEXTREMEDEATH
		RenderStyle "None";
		Obituary "%o was clubbed by %k's gun stock.";
	}
	States
	{
	Spawn:
		TNT1 A 2;
		Stop;
	XDeath:
		TNT1 A 0 A_StartSound("weapons/fist/punch", CHAN_AUTO, 0, 1.0, ATTN_NORM, 0.7);	// a thud: WoS's punch, lower
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}
class RSQWS_ButtStrikeBerserk : RSQWS_ButtStrike { Default { DamageFunction (20 * random(5, 15)); } }

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
