// weapon.zs -- the whip as a WEAPON (owner 2026-10-31: "whip is a weapon"; slot 1 with the melee weapons, either hand).
//
// The owner's design (2026-10-31):
//   * ALWAYS OUT while it is the weapon in the hand: swing it and it cracks.
//   * TRIGGER held: point the whip hand, a mark shows the target; let go and the mark is lost. A crack while
//     something is marked sends the whip out to it (whip.zs Mark / Crack / Reach). Switches, keys and powerups
//     within rsqwp_whip_prio of you are marked first.
//   * ALT-FIRE moves the mark to the next nearest target.
//   * WRAPPED, it swings with your arm at the rope's length and smashes into the monsters it meets (keep the
//     trigger held to keep hold of it).
//   * THE PULL is a gesture: with the whip wrapped round a monster, a violent pull back yanks it -- light ones fly
//     to you, medium ones stagger, past a certain mass they cannot be pulled and the yank swings YOU to them in an
//     arc instead (whip.zs Wrap / Yank). A gentle tug only drags.
//   * THE LASSO: close the off hand on the whip -- its grip with the controller at the handle or the thong (any
//     headset, the Quest's too), or the engine's two-hand grip (SteamVR) -- and the off hand holds the thong; it
//     whirls as fast as the off hand drives it (the same simulated whip, nothing canned). Let go of the grip and it flies out the way it was going, and ropes the monster nearest that way.
//   * On a rope (the whip caught an edge): trigger held = reel in, alt-fire = let go.
// Either hand, ONE whip: Whip In (rsqwp_whip_hand) picks the hand (whip.zs WhipIn); in the off hand it reads the off-hand
// trigger and alt-fire (BT_OFFHANDATTACK / BT_OFFHANDALTATTACK).
//
// Hand on the Handle (on): the weapon draws the FBX hand round the drawn handle (A_WhipLook); off, no model: the whip
// draws its own handle.

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
	// What holds the aimed swing's ray (swing.zs): 1 the OTHER hand's alt-fire (the button, or its key eaten by the
	// whip, whip.zs AimKey), 2 the off hand's FIRE with the whip in the main hand and the off hand empty or a fist
	// (Aim With Off-Hand Fire: its key eaten the same way, or the button), 0 nothing.
	int AimBy()
	{
		if (!owner || !owner.player) return 0;
		let w = RSQWP_Whip.Get();
		int pn = owner.PlayerNumber();
		let p = owner.player;
		if (Hand() == 0 && RSQWP_Whip.OffFireAims(p)
			&& ((w && pn >= 0 && pn < MAXPLAYERS && w.aimFire[pn]) || (p.cmd.buttons & BT_OFFHANDATTACK)))
			return 2;
		if (w && pn >= 0 && pn < MAXPLAYERS && w.aimBtn[pn]) return 1;
		return (p.cmd.buttons & (Hand() ? BT_ALTATTACK : BT_OFFHANDALTATTACK)) ? 1 : 0;
	}
	bool AimHeld() { return AimBy() != 0; }
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
		w.tendTic[i] = level.maptime;     // this hand's whip is this weapon's (whip.zs: a weapon whip nobody tends is gone)
		bool trig = TriggerHeld();
		bool alt = AltHeld();
		bool altPress = alt && !altWas;
		altWas = alt;
		w.aimBy[i] = AimBy();
		w.aimHeld[i] = w.aimBy[i] != 0;
		w.aimTic[i] = level.maptime;
		let h = core.hooks[i];
		// A CHAIN (swing.zs): let go of an aimed swing's rope (or any rope with the ray held) and the whip is back in the
		// hand at once, its thong straight off the rope, so the next crack can come while you are still in the air
		// (the line's reel-back is not waited for)
		if (h && h.phase == RSQWP_Hook.PH_RETRACT && (h.aimed || w.aimHeld[i]))
		{
			h.Destroy(); core.hooks[i] = null; h = null;
			w.outNow[i] = true;
		}
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
		// the lasso: the off hand closed on the thong (only the main-hand whip has an off hand to spin it). Two routes:
		// the engine's two-hand grip latch (WF_TWOHANDSTABILIZED: SteamVR's gl_openvr.cpp, and QZD's own Quest input
		// too, VrInputDefault.cpp 130-141, the off grip pressed within 0.50 m with vr_two_handed_weapons on), and --
		// any backend, latch or not -- the off controller at the handle or the thong with its grip down (whip.zs
		// OffHandCloses; teardown apply/01 5.2).
		bool latch = (pmo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0;
		bool test = RSQWP_Util.Opt("rsqwp_lasso_test", 0) > 0;
		bool grip = hand == 0 && (latch || test || w.OffHandCloses(i, pmo));
		bool was = w.lassoOn[i];
		w.lassoOn[i] = grip && RSQWP_Whip.Unlock(pmo, RSQWP_Whip.G_LASSO, "rsqwp_whip_lasso", true);   // the Lasso node under Gun Bonsai VR
		if (w.lassoOn[i] && !was && RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LASSO on t%d by %s", i, level.maptime, latch ? "the two-hand latch" : (test ? "rsqwp_lasso_test" : "the off hand at the thong, grip down"));
	}

	void PutAway(PlayerPawn pmo)
	{
		let w = RSQWP_Whip.Get();
		let core = RSQWP_Core.Get();
		if (!pmo || !w || !core) return;
		int i = pmo.PlayerNumber() * 2 + Hand();
		w.markHeld[i] = false;
		w.lassoOn[i] = false;
		w.EndWrap(i);
		if (core.hooks[i]) { core.held[i] = false; core.LetGo(core.hooks[i], true); }
		w.WeaponUp(i, pmo);
		hadHook = false;
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
