// weapon.zs -- the whip as a WEAPON (owner 2026-10-31: "whip is a weapon"; slot 1 with the melee weapons, either hand).
//
// The owner's design (2026-10-31):
//   * ALWAYS OUT while it is the weapon in the hand: swing it and it cracks.
//   * TRIGGER held: point the whip hand, a mark shows the target; let go and the mark is lost. A crack while
//     something is marked sends the whip out to it (whip.zs Mark / Crack / Reach). Switches, keys and powerups
//     within Whip Reach (rsqwp_target_reach, 20 m) are marked first (Switches First, rsqwp_whip_first).
//   * ALT-FIRE moves the mark to the next nearest target.
//   * WRAPPED, it swings with your arm at the rope's length and smashes into the monsters it meets (keep the
//     trigger held to keep hold of it).
//   * THE PULL is a gesture: with the whip wrapped round a monster, a violent pull back yanks it -- light ones fly
//     to you, medium ones stagger, past a certain mass they cannot be pulled and the yank swings YOU to them in an
//     arc instead (whip.zs Wrap / Yank). A gentle tug only drags.
//   * THE LASSO: close the off hand on the whip -- its grip with the controller at the handle or the thong (any
//     headset, the Quest's too), or the engine's two-hand grip (SteamVR) -- and the off hand holds the thong; it
//     whirls as fast as the off hand drives it (the same simulated whip, nothing canned). Let go of the grip and it flies out the way it was going, and ropes the monster nearest that way.
//   * On a rope (the whip caught an edge): trigger held = reel in, Jump = let go (owner 11-13; Tend has the switches).
// Either hand, ONE whip: Whip In (rsqwp_whip_hand) picks the hand (whip.zs WhipIn); in the off hand it reads the off-hand
// trigger and alt-fire (BT_OFFHANDATTACK / BT_OFFHANDALTATTACK).
//
// Hand on the Handle (on): the weapon draws the FBX hand round the drawn handle (A_WhipLook); off, no model: the whip
// draws its own handle.

class RSQWP_WhipWeapon : Weapon
{
	bool altWas;
	bool trigWas;
	bool latched;       // the Lock-On Whip: a fire press has set the mark; it stays with no button held (Tend)
	int  latchTic;
	Actor latchOn;      // the monster the latched mark is on (put back after a crack spends the mark)
	bool hadHook;
	bool reelArmed;
	bool jumpWas;       // On a Rope, Jump Lets Go: the jump button last tic (its fresh press lets go)
	int  waitSeen;      // ... the last tic this rope was still waiting for its start (that jump starts it, never lets go)

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
		// DRAWN THIS TIC (owner 11-05 04:17, from a holster: "the whip and handle are far, far apart"): the weapon was not
		// in this hand last tic (a Tactical Rig holster draw, the hip spot, a slot key, Whip In's hand switch, the Wheel)
		bool drawn = level.maptime - w.tendTic[i] > 1;
		w.tendTic[i] = level.maptime;     // this hand's whip is this weapon's (whip.zs: a weapon whip nobody tends is gone)
		bool trig = TriggerHeld();
		bool alt = AltHeld();
		bool altPress = alt && !altWas;
		altWas = alt;
		bool trigPress = trig && !trigWas;
		trigWas = trig;
		bool lw = RSQWP_Whip.LockWhipOn();     // the Lock-On Whip (swing.zs): the ray always, presses lock, nothing is held
		bool dbg = RSQWP_Util.Flag("rsqwp_debug", false);
		// WHIP AND GUN, "Indiana Jones" (owner 11-10 12:30; swing.zs IndyOn): a weapon in the other hand, the row on. The whip
		// hand's own ray is the snag cursor while its trigger is up (aimBy 3); the trigger held marks as ever and the
		// cursor is gone (its gold spot forgotten, so the beam never stands the mark down). The other hand keeps its
		// buttons (whip.zs AimKey eats nothing), there is no lasso, and the swing is the whip hand's alone.
		bool indy = RSQWP_Whip.IndyOn(pmo.player, hand);
		if (indy != w.indy[i] && RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d WHIP AND GUN t%d %s (other hand: %s)", i, level.maptime, indy ? "on: the whip hand's ray is the cursor" : "off: the whip as in slot 1",
				hand ? (pmo.player.ReadyWeapon ? pmo.player.ReadyWeapon.GetClassName() : 'none') : (pmo.player.OffhandWeapon ? pmo.player.OffhandWeapon.GetClassName() : 'none'));
		w.indy[i] = indy;
		w.aimBy[i] = lw ? 3 : (indy ? (trig ? 0 : 3) : AimBy());
		w.aimHeld[i] = w.aimBy[i] != 0;
		w.aimTic[i] = level.maptime;
		if (!lw && indy && trig && !w.casting[i]) w.okTic[i] = -100;
		if (!lw) { latched = false; if (w.geoLock[i]) w.GeoUnlock(i, "Lock-On Controls is off"); }
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
			// FIRE LETS GO (owner 11-11 23:56: "using mainhand alt fire to dismount is strange, can we change it to primary
			// fire dismounts (when snagged)?"; rsqwp_rope_fire, on): on a rope the whip hand's trigger, in a fresh press,
			// lets go, and its alt-fire held reels. Off: as before, the trigger reels and alt-fire lets go.
			// JUMP LETS GO (owner 11-13 17:52: "the controls are fucked up and super uncomfortable. fire is trigger and alt fire
			// is grip+trigger": alt-fire to reel needs the grip down first, and a trigger landing a hair early was a fire
			// press that let go; his pick: "Trigger reels, Jump lets go"; rsqwp_rope_jump, on): on a rope the whip hand's
			// trigger held reels (a fresh press, as ever), a fresh Jump lets go, alt-fire does nothing. The jump that starts
			// a rope waiting on the ground is that rope's start, never its let-go. Off: On a Rope, Fire Lets Go decides.
			bool jumpDrops = RSQWP_Util.Flag("rsqwp_rope_jump", true);
			bool fireDrops = !jumpDrops && RSQWP_Util.Flag("rsqwp_rope_fire", true);
			bool jmp = (pmo.player.cmd.buttons & BT_JUMP) != 0;
			bool jumpPress = jmp && !jumpWas;
			jumpWas = jmp;
			// (only ON THE GROUND, and only while Jump Starts Swing is on: rig 11-13, run wp13_step -- a rope stepped off a lip
			// with no start is still "waiting" in the air, and its first Jump was a start in the air, not the let-go; and with
			// Jump Starts Swing off a jump never starts it, so it lets go)
			bool grounded = pmo.pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			if (h.waiting && grounded && RSQWP_Util.Flag("rsqwp_swing_jump", true)) waitSeen = level.maptime;
			bool drop = jumpDrops ? (jumpPress && level.maptime - waitSeen > 1) : (fireDrops ? (trig && reelArmed) : altPress);
			core.held[i] = fireDrops ? alt : (trig && reelArmed);
			core.pressFired[i] = true;
			if (drop)
			{
				core.held[i] = false; core.LetGo(h, true);
				if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d ROPE let go t%d by %s", i, level.maptime, jumpDrops ? "jump" : (fireDrops ? "fire" : "alt-fire"));
			}
			w.markHeld[i] = false;
			w.lassoOn[i] = false;
			latched = false; w.GeoUnlock(i, "on a rope");
			return;
		}
		if (hadHook) { hadHook = false; core.held[i] = false; core.pressFired[i] = false; }
		jumpWas = (pmo.player.cmd.buttons & BT_JUMP) != 0;
		// the whip is this weapon's BEFORE it starts, so Start lays the thong out from the DRAWN handle's tip (Hand on the
		// Handle, whip.zs Handle) and not from the controller's aim line, as it did until 11-05; and a whip still out when the
		// weapon comes (back) into the hand is seated on that hand's handle at once, every link snapped there (whip.zs Seat)
		w.byWeapon[i] = true;
		if (w.wstate[i] != RSQWP_Whip.ST_OUT || w.wby[i] != pmo) w.Start(i, pmo, hand, 0);
		else if (drawn) w.Seat(i, pmo, hand);
		if (lw)
		{
			// FIRE: mark what is nearest along the hand; again: the next one. The mark needs no button held.
			if (trigPress)
			{
				w.GeoUnlock(i, "fire marks");
				bool had = latched && (w.lockOn[i] || w.markLine[i]);
				if (had) w.markNext[i] = true;
				latched = true; latchTic = level.maptime;
				if (dbg) Console.Printf("T_WPW %d LOCK t%d fire: %s", i, level.maptime, had ? "the mark moves to the next" : "mark the nearest along the hand");
			}
			// ALT-FIRE: lock the gold cursor's spot for the crack; again: let it go
			if (altPress)
			{
				if (w.geoLock[i]) w.GeoUnlock(i, "alt-fire again");
				else if (w.aimOk[i] && !w.casting[i])
				{
					w.geoLock[i] = true; latched = false;
					if (dbg) Console.Printf("T_WPW %d LOCK t%d alt-fire: spot locked at (%.0f %.0f %.0f), %.1f m; the mark is let go", i, level.maptime, w.okAt[i].x, w.okAt[i].y, w.okAt[i].z, w.aimM[i]);
				}
				else if (dbg) Console.Printf("T_WPW %d LOCK t%d alt-fire: no gold cursor here (%s), nothing locked", i, level.maptime, w.aimWhy[i]);
			}
			// THE MARK STAYS THROUGH A CRACK (rig 11-12 04:58: the crack that flew to the mark spent it, so the next crack
			// had no mark): the monster the latch is on is remembered, and put back as the mark while it lives, once the
			// crack's flight is over. Fire again still moves it on; alt-fire or its death ends it.
			if (latched && w.lockOn[i]) latchOn = w.lockOn[i];
			else if (latched && latchOn && latchOn.health > 0 && !latchOn.bDestroyed && !w.markLine[i] && !trigPress)
			{
				// (gone out of reach or out of sight: the latch is over, below)
				if (pmo.Distance3D(latchOn) > RSQWP_Whip.LockRange() * 1.15 || !pmo.CheckSight(latchOn, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) latchOn = null;
				else
				{
					latchTic = level.maptime;     // the flight is not "nothing to mark"
					if (!w.casting[i] && w.reachTic[i] <= 0) { w.lockOn[i] = latchOn; w.lockLine[i] = false; w.lockLeft[i] = 35; }
				}
			}
			else if (latched && latchOn && (latchOn.health <= 0 || latchOn.bDestroyed)) latchOn = null;
			if (!latched) latchOn = null;
			// the mark found nothing, or what it was on is gone with nothing else along the hand: the latch is over
			if (latched && level.maptime > latchTic + 2 && !w.lockOn[i] && !w.markLine[i])
			{
				latched = false;
				if (dbg) Console.Printf("T_WPW %d LOCK t%d the mark is over (nothing to mark)", i, level.maptime);
			}
			// a locked spot you have walked out of reach of is let go
			if (w.geoLock[i] && (w.okAt[i] - RSQWP_Util.HandPos(pmo, hand)).Length() > RSQWP_Whip.LockRange() * 1.15) w.GeoUnlock(i, "out of reach");
			w.markHeld[i] = latched;
		}
		else
		{
			w.markHeld[i] = trig;
			if (altPress && trig) w.markNext[i] = true;
		}
		// the lasso: the off hand closed on the thong (only the main-hand whip has an off hand to spin it). Two routes:
		// the engine's two-hand grip latch (WF_TWOHANDSTABILIZED: SteamVR's gl_openvr.cpp, and QZD's own Quest input
		// too, VrInputDefault.cpp 130-141, the off grip pressed within 0.50 m with vr_two_handed_weapons on), and --
		// any backend, latch or not -- the off controller at the handle or the thong with its grip down (whip.zs
		// OffHandCloses; teardown apply/01 5.2).
		bool latch = (pmo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0;
		bool test = RSQWP_Util.Opt("rsqwp_lasso_test", 0) > 0;
		bool grip = hand == 0 && (latch || test || w.OffHandCloses(i, pmo));
		bool was = w.lassoOn[i];
		w.lassoOn[i] = !indy && grip && RSQWP_Whip.Unlock(pmo, RSQWP_Whip.G_LASSO, "rsqwp_whip_lasso", true);   // the Lasso node under Gun Bonsai VR; never beside a gun (Whip and Gun)
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
		latched = false; w.GeoUnlock(i, "the whip is put away");
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
