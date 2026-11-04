// RSQ FlashFlare -- the flares you carry, the box they come in, and the flare in your hand.
//
// AMMO, saegiru's way (his Emergency Flare, DECORATE.flares FlareBox, parsed): a box gives 6, you carry 24 at most. His box
// was a usable inventory item that fired a flare from the face; here a flare comes out of your chest pocket by hand.
// The pickup is the owner's flare model, three in a bundle (box.md3), not his sprite.

class RSQFF_Ammo : Ammo
{
	Default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 24;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount 24;
		Inventory.PickupMessage "Picked up a road flare.";
		+INVENTORY.IGNORESKILL;
		Tag "Flares";
	}
	States
	{
	Spawn:
		QFFB A -1;
		Stop;
	}
}

class RSQFF_Box : RSQFF_Ammo
{
	Default
	{
		Inventory.Amount 6;
		Inventory.PickupMessage "Picked up a box of road flares!";
	}
	States
	{
	Spawn:
		QFFB A -1;
		Stop;
	}
}

// given once, so "Start With" fills the pocket at a new game (and after dying), never on every map
class RSQFF_Given : Inventory
{
	Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE Inventory.MaxAmount 1; }
}

// THE FLARE IN THE OFF HAND: an off-hand weapon, as RSQ Tactical Rig's Zippo is (its RSQTR_ZippoWeapon), so the main hand
// keeps its gun. It does nothing on its own trigger (WRF_NOFIRE): the handler reads the hand. The picture is set each tic:
//   QFFH A  unlit, in the hand        QFFH B  lit (cap off), in the hand
//   QFFH C  unlit, no hand drawn      QFFH D  lit, no hand drawn
//   QFFH E  the glowing burning end, an overlay drawn full bright over B / D
// The hand is Brutal Doom 22 VR Reloaded's FBX fist (its fbx_oh_free_R.md3 frame 1), with the flare baked into the fist's
// grip hole (tools/gen_flare.py), drawn in the same MODELDEF block BD22 VR draws its off-hand fist in.
// Being an OFF-HAND weapon by its class, RSQ Tactical Rig never throws it or holsters it (rig.zs IsMovedGun).
class RSQFF_Held : Weapon
{
	const EMBER = 7311;      // the overlay layer of the glowing end

	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Weapon.Kickback 0;
		Tag "Road Flare";
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+WEAPON.NO_AUTO_SWITCH
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}

	action void A_RSQFFReady()
	{
		A_WeaponReady(WRF_NOFIRE | WRF_NOSWITCH);
		if (!player || !player.mo) return;
		let psp = player.FindPSprite(PSP_OFFHANDWEAPON);
		if (!psp || player.OffhandWeapon != invoker) return;
		int n = player.mo.PlayerNumber();
		bool lit = RSQFF_Handler.IsLit(n);
		let hc = CVar.GetCVar("rsqff_hand", player);
		bool hand = !hc || hc.GetBool();
		psp.Frame = (hand ? 0 : 2) + (lit ? 1 : 0);
		let em = player.FindPSprite(EMBER);
		if (lit && !em) A_Overlay(EMBER, "Ember");
		else if (!lit && em) player.SetPSprite(EMBER, null);
	}

	States
	{
	Spawn:
		QFFB A -1;
		Stop;
	Select:
		QFFH A 1 A_Raise(24);
		Loop;
	Deselect:
		QFFH A 1 A_Lower(24);
		Loop;
	Ready:
		QFFH A 1 A_RSQFFReady;
		Loop;
	Fire:
		QFFH A 1;
		Goto Ready;
	Ember:
		QFFH E 1 Bright;
		Loop;
	// never entered: names the frames for MODELDEF
	Frames:
		QFFH BCD 0;
		Stop;
	}
}

// RUMBLE, the series' way (RSQ Grenade RSQGN_Buzzer): a tiny local A_QuakeEx; X goes to the left controller, Y the right.
class RSQFF_Buzzer : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;

	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH }

	static void Start(Actor who, int hand, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let q = RSQFF_Buzzer(Actor.Spawn("RSQFF_Buzzer", who.pos));
		if (!q) return;
		q.feels = who;
		q.left = (hand == 1) != RSQFF_Geo.LeftHanded();
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}
