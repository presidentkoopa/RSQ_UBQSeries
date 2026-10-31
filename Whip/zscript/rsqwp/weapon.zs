// weapon.zs -- the whip as a WEAPON (owner 2026-10-31: "whip is a weapon"; slot 1 with the melee weapons, either hand).
//
// The owner's design (2026-10-31):
//   * ALWAYS OUT while it is the weapon in the hand: swing it and it cracks.
//   * TRIGGER held: point the whip hand, a mark shows the target; let go and the mark is lost. A crack while
//     something is marked sends the whip out to it (whip.zs Mark / Crack / Reach). Switches, keys and powerups
//     within rsqwp_whip_prio of you are marked first.
//   * ALT-FIRE moves the mark to the next nearest target.
//   * THE PULL is a gesture: with the whip wrapped round a monster, a violent pull back yanks it -- light ones fly
//     to you, medium ones stagger, past a certain mass they cannot be pulled and the yank swings YOU to them in an
//     arc instead (whip.zs Wrap / Yank). A gentle tug only drags.
//   * THE LASSO: grab the whip with the off hand (the engine's two-hand grip, SteamVR) and the off hand holds the
//     thong; it whirls as fast as the off hand drives it (the same simulated whip, nothing canned). Let go of the
//     grip and it flies out the way it was going, and ropes the monster nearest that way.
//   * On a rope (the whip caught an edge): trigger held = reel in, alt-fire = let go.
// Either hand: the off-hand copy reads the off-hand trigger and alt-fire (BT_OFFHANDATTACK / BT_OFFHANDALTATTACK).
//
// The hand is Brutal Doom VR's own (MODELDEF: its axe grip); while the whip is out it draws its own handle.

class RSQWP_WhipWeapon : Weapon
{
	bool altWas;
	bool hadHook;
	bool reelArmed;

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

	bool TriggerHeld()
	{
		if (!owner || !owner.player) return false;
		return (owner.player.cmd.buttons & (Hand() ? BT_OFFHANDATTACK : BT_ATTACK)) != 0;
	}
	bool AltHeld()
	{
		if (!owner || !owner.player) return false;
		return (owner.player.cmd.buttons & (Hand() ? BT_OFFHANDALTATTACK : BT_ALTATTACK)) != 0;
	}

	// every tic in the hand: keep the whip out, pass the trigger and alt-fire on
	void Tend(PlayerPawn pmo)
	{
		let w = RSQWP_Whip.Get();
		let core = RSQWP_Core.Get();
		if (!pmo || !pmo.player || !w || !core || !RSQWP_Util.Flag("rsqwp_on", true)) return;
		int hand = Hand();
		int i = pmo.PlayerNumber() * 2 + hand;
		bool trig = TriggerHeld();
		bool alt = AltHeld();
		bool altPress = alt && !altWas;
		altWas = alt;
		let h = core.hooks[i];
		if (h)
		{
			// on a rope: the trigger reels (a fresh press: the trigger that was marking does not reel at once),
			// alt-fire lets go
			if (!hadHook) reelArmed = !trig;
			if (!trig) reelArmed = true;
			hadHook = true;
			core.held[i] = trig && reelArmed;
			core.pressFired[i] = true;
			if (altPress) { core.held[i] = false; core.LetGo(h, true); }
			w.markHeld[i] = false;
			w.lassoOn[i] = false;
			return;
		}
		if (hadHook) { hadHook = false; core.held[i] = false; core.pressFired[i] = false; }
		if (w.wstate[i] != RSQWP_Whip.ST_OUT || w.wby[i] != pmo) w.Start(i, pmo, hand, 0);
		w.byWeapon[i] = true;
		w.markHeld[i] = trig;
		if (altPress && trig) w.markNext[i] = true;
		// the lasso: the off hand on the two-hand grip (only the main-hand whip has an off hand to spin it)
		bool grip = hand == 0 && ((pmo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0 || RSQWP_Util.Opt("rsqwp_lasso_test", 0) > 0);
		w.lassoOn[i] = grip && RSQWP_Util.Flag("rsqwp_whip_lasso", true);
	}

	void PutAway(PlayerPawn pmo)
	{
		let w = RSQWP_Whip.Get();
		let core = RSQWP_Core.Get();
		if (!pmo || !w || !core) return;
		int i = pmo.PlayerNumber() * 2 + Hand();
		w.markHeld[i] = false;
		w.lassoOn[i] = false;
		w.wrapOn[i] = null;
		if (core.hooks[i]) { core.held[i] = false; core.LetGo(core.hooks[i], true); }
		w.WeaponUp(i, pmo);
		hadHook = false;
	}

	action void A_WhipReady()
	{
		A_WeaponReady(WRF_NOFIRE);
		invoker.Tend(PlayerPawn(self));
	}

	States
	{
	Spawn:
		WHPW A -1;
		Stop;
	Select:
		WHPW A 1 A_Raise(12);
		Loop;
	Deselect:
		WHPW A 0 { invoker.PutAway(PlayerPawn(self)); }
		WHPW A 1 A_Lower(12);
		Wait;
	Ready:
		WHPW B 1 A_WhipReady();     // B: the hand alone -- the whip is out and draws its own handle
		Loop;
	Fire:
	AltFire:
		Goto Ready;
	}
}
