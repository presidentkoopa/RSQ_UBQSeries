// weapon.zs -- the whip as a WEAPON (owner 2026-10-31: "whip is a weapon"; slot 1 with the melee weapons, either hand).
//
// ALWAYS OUT while it is the weapon in the hand: the thong hangs from the handle and follows it (whip.zs).
// 2026-11-27 (owner: "what i want is to do a big wide swing ... and if i crack down to the ground the impact sends out a
// shockwave", "i want to tone this thing down"): its two moves are read from the hand (lash.zs); the weapon's trigger
// and alt fire do nothing, and no other button is read. The mark, the lock, the rope's buttons and the lasso went.
// Either hand, ONE whip: Whip In (rsqwp_whip_hand) picks the hand (whip.zs WhipIn).
//
// Hand on the Handle (on): the weapon draws the FBX hand round the drawn handle (A_WhipLook); off, no model: the whip
// draws its own handle.

class RSQWP_WhipWeapon : Weapon
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 3900;
		Weapon.AmmoUse 0;
		Weapon.Kickback 0;
		Weapon.BobStyle "InverseSmooth";
		Inventory.PickupMessage "You got the whip!";
		Tag "Whip";
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
		+WEAPON.NOAUTOFIRE
		+WEAPON.WIMPY_WEAPON
		+WEAPON.NOAUTOSWITCHTO
		+INVENTORY.UNDROPPABLE
	}

	int Hand() { return (owner && owner.player && owner.player.OffhandWeapon == self) ? 1 : 0; }

	// every tic in the hand: keep the whip out
	void Tend(PlayerPawn pmo)
	{
		let w = RSQWP_Whip.Get();
		if (!pmo || !pmo.player || !w || !RSQWP_Util.Flag("rsqwp_on", true)) return;
		int hand = Hand();
		int i = pmo.PlayerNumber() * 2 + hand;
		// DRAWN THIS TIC (owner 11-05 04:17, from a holster: "the whip and handle are far, far apart"): the weapon was not
		// in this hand last tic (a Tactical Rig holster draw, the hip spot, a slot key, Whip In's hand switch, the Wheel)
		bool drawn = level.maptime - w.tendTic[i] > 1;
		w.tendTic[i] = level.maptime;     // this hand's whip is this weapon's (whip.zs: a weapon whip nobody tends is gone)
		// the whip is this weapon's BEFORE it starts, so Start lays the thong out from the DRAWN handle's tip (Hand on the
		// Handle, whip.zs Handle) and not from the controller's aim line; and a whip still out when the weapon comes
		// (back) into the hand is seated on that hand's handle at once, every link snapped there (whip.zs Seat)
		w.byWeapon[i] = true;
		if (w.wstate[i] != RSQWP_Whip.ST_OUT || w.wby[i] != pmo) w.Start(i, pmo, hand);
		else if (drawn) w.Seat(i, pmo, hand);
	}

	void PutAway(PlayerPawn pmo)
	{
		let w = RSQWP_Whip.Get();
		if (!pmo || !w) return;
		int i = pmo.PlayerNumber() * 2 + Hand();
		w.reachTic[i] = 0;     // a Ground Crack on its way is over: no impact from a whip put away
		w.WeaponUp(i, pmo);
	}

	action void A_WhipReady()
	{
		A_WeaponReady(WRF_NOFIRE);
		invoker.Tend(PlayerPawn(self));
		A_WhipLook();
	}
	// HAND ON THE HANDLE (owner 2026-11-03, rsqwp_hand_handle, on): the weapon draws BD22 VR's FBX hand in its magazine
	// hold round the whip's handle (sprite WHPH, MODELDEF: the hand in slot 7 + Skin 7 "fbx_hand.png", so BD22's Hand
	// Skin Tone tones it; the handle in slot 0). Off: WHPW, no model, as before (the whip draws its own handle).
	action void A_WhipLook()
	{
		let psp = player ? player.FindPSprite(invoker.Hand() ? PSP_OFFHANDWEAPON : PSP_WEAPON) : null;
		if (!psp) return;
		bool on = RSQWP_Whip.HandOnHandle(PlayerPawn(self));
		psp.Sprite = GetSpriteIndex(on ? "WHPH" : "WHPW");
		psp.Frame = on ? 0 : 1;
	}

	States
	{
	Spawn:
		WHPW A -1;
		Stop;
	Select:
		WHPW A 1 { A_Raise(12); A_WhipLook(); }
		Loop;
	Deselect:
		WHPW A 0 { invoker.PutAway(PlayerPawn(self)); }
		WHPW A 1 { A_Lower(12); A_WhipLook(); }
		Wait;
	// never entered: registers the hand's sprite name (the engine knows a sprite only when a state uses it)
	HandReg:
		WHPH A 0;
		Stop;
	Ready:
		WHPW B 1 A_WhipReady();     // B: the hand alone -- the whip is out and draws its own handle
		Loop;
	Fire:
	AltFire:
		Goto Ready;
	}
}

// THE WHIP, COILED, IN RSQ TACTICAL RIG'S WHIP HOLSTER (owner 2026-11-03 20:14: "draw the holstered whip on the body as its
// model when stored"). The rig spawns this by name at its whip holster (main-hand hip) while the whip is in neither hand,
// and turns it to the body's heading; the whip only says what it looks like: three loops of its own plaited thong and its
// wrapped handle (models/rsqwp/rsqwp_coil.md3, tools/gen_whipcoil.py), the size of the whip in your hand. Never in play.
class RSQWP_Stowed : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States
	{
	Spawn:
		RSWP A -1;
		Stop;
	}
}
