// RSQ FlashFlare -- the flares you carry, the box they come in, and the flare in your hand.
//
// AMMO, saegiru's way (his Emergency Flare, DECORATE.flares FlareBox, parsed): a box gives 6, you carry 24 at most. His box
// was a usable inventory item that fired a flare from the face; here a flare comes out of your chest pocket by hand.
// The pickups (11-03, the owner: "use the UDV Survival Flares pack's art"): the box is his box sprite FBOXA0 (QFFX A, at
// his FlareBox's scale 0.7) and, with voxels on, a voxel of the same box (voxels/QFFBOX.kvx, VOXELDEF.txt). One flare is
// his lying flare FLRLA0 (QFFB A, at his flare's scale 0.5) and, with models on, the owner's flare model, three in a
// bundle (box.md3; MODELDEF's scale makes up for the actor's 0.5).

class RSQFF_Ammo : Ammo
{
	Default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 24;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount 24;
		Inventory.PickupMessage "Picked up a road flare.";
		Scale 0.5;
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
		Scale 0.7;
	}
	States
	{
	Spawn:
		QFFX A -1;
		Stop;
	}
}

// given once, so "Start With" fills the pocket at a new game, never on every map. After a death the new player has none, so
// the pocket is filled again (and RSQFF_Handler.PlayerRespawned fills it on a respawn in place, which may keep this).
class RSQFF_Given : Inventory
{
	Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE Inventory.MaxAmount 1; }
}

// THE FLARE IN THE OFF HAND: an off-hand weapon, as RSQ Tactical Rig's Zippo is (its RSQTR_ZippoWeapon), so the main hand
// keeps its gun. It does nothing on its own trigger (WRF_NOFIRE): the handler reads the hand. The picture is set each tic:
//   QFFH A  unlit, in the hand        QFFH B  lit (cap off), in the hand
//   QFFH C  unlit, no hand drawn      QFFH D  lit, no hand drawn
//   QFFH E  the glowing burning end, an overlay drawn full bright over B / D
// The hand is Brutal Doom 22 VR Reloaded's FBX holding hand (fbx_oh_hold_R.md3 frame 0, MODELDEF.txt), with the flare
// baked in (tools/gen_flare.py), drawn in the same MODELDEF block BD22 VR draws its off-hand fist in.
// Being an OFF-HAND weapon by its class, RSQ Tactical Rig never throws it or holsters it (rig.zs IsMovedGun).
class RSQFF_Held : Weapon
{
	const EMBER = 7311;      // the overlay layer of the glowing end
	bool burning;            // struck (the handler's state is per level; this rides the item to the next map)

	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Weapon.Kickback 0;
		Tag "Road Flare";
		Inventory.Icon "WRIFLARE";   // drawn for the series (Wheel/sources/icons/gen_item_icons.py; owner 2026-11-05)
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+WEAPON.NO_AUTO_SWITCH
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}

	// SWITCHABLE (11-03): another off-hand weapon raised into this hand (RSQ Tactical Rig's off-hand draw from a holster,
	// Brutal Doom's Dual key, the off hand's next-weapon key) lowers the flare, and the handler then puts an unlit one
	// back in the pocket or lets a lit one fall (Keep). With WRF_NOSWITCH, as until 11-03, such a switch never happened:
	// the engine's off-hand switch waits for WF_OFFHANDSWITCHOK (QZD player.zs CheckWeaponChange), so the off-hand gun
	// stayed pending and the flare in the hand (rig, 11-03: an off-hand draw from the hip with a flare out hung 68 tics,
	// until the flare was put back by hand).
	action void A_RSQFFReady()
	{
		A_WeaponReady(WRF_NOFIRE);
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

	// RSQ_Accessibility's RUMBLE BACKUP, by name (as its tools/a11y_template.zs RumbleBackup; this mod carries no copy of
	// that class): as a rumble starts, at Quake Haptics 0, RSQ_Accessibility sends the engine's shot buzz on that
	// controller. This rumble is played as before either way; Rumble Backup off or RSQ_Accessibility absent, nothing.
	static void RumbleBackup(Actor who, bool left)
	{
		if (!who || !who.player) return;
		Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN;
		if (!rsqaC) return;
		let cv = CVar.FindCVar('rsqa_rumble_backup');
		if (!cv || !cv.GetInt()) return;
		let it = ServiceIterator.Find("RSQA_Service");
		let s = it.Next();
		if (s) s.GetInt("buzz", "RSQFF", who.PlayerNumber(), left ? 1 : 0);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		if (tleft == total) RumbleBackup(feels, left);
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}

// A FLARE IN RSQ TACTICAL RIG'S FLARE HOLSTER (owner 2026-11-03 20:14: "draw the holstered whip/flare on the body as their
// models when stored"). The rig spawns this by name, places it at its flare holster and turns it (cap up); FnF only says
// what it looks like: the owner's flare (flare.md3), unlit, cap on, real size (MODELDEF: 22.8 cm, centred). Never in play.
class RSQFF_Stowed : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States
	{
	Spawn:
		QFFW C -1;
		Stop;
	}
}
