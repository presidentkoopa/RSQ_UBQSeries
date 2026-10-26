// RS_ShieldSawQ -- the three states, the shoulder mount, the loadout swap, and the input.
//
//   STOWED   on the mount over your off shoulder (a world prop, guarding your back)
//   DRAWN    in your off hand: SSQ_ShieldSaw is the off-hand weapon
//   FLYING   thrown. Your previous off-hand weapon is already back, so you are never
//            empty-handed. The disc comes home along the way it went; a hand near it on the
//            way back catches it (DRAWN), otherwise it lands on the mount (STOWED).
//
// THE INPUT (owner, 2026-10-22 04:08), all synced usercmd bits, nothing to bind:
//   off hand in the ZONE by the off shoulder + USE   -> the shield is in the hand (whatever was
//                                                        there steps aside and comes back after)
//   off PRIMARY held                                  -> the saw revs
//   off SECONDARY held                                -> lock-on: rings over what you aim at
//   off SECONDARY released, arm moving               -> throw, at the ringed targets in order
//   off SECONDARY released, arm still                -> nothing; it stays in the hand
//   off SECONDARY pressed while it flies              -> recall
//   USE in the zone again                             -> back on the shoulder
//   hand near the returning disc (Back in Hand on Return) -> caught
// The decision runs here, in WorldTick, from the SYNCED pose (pose.zs). No wait on the grab.

class SSQ_Handler : EventHandler
{
	enum EState { SS_STOWED = 0, SS_DRAWN, SS_FLYING }

	int   mState[MAXPLAYERS];
	SSQ_Pose mPose[MAXPLAYERS];
	Actor mProp[MAXPLAYERS];		// the shield as a world actor: on the back, or in the hand for others
	Actor mMarker[MAXPLAYERS];
	Actor mDisc[MAXPLAYERS];
	class<Weapon> mPrevOff[MAXPLAYERS];	// what the draw displaced (null: nothing, or the pack's hands)
	class<Weapon> mPrevMain[MAXPLAYERS];	// the main-hand weapon a two-handed conflict lowered
	bool  mGripWas[MAXPLAYERS];		// off secondary last tic
	bool  mUseWas[MAXPLAYERS];
	bool  mStowLatch[MAXPLAYERS];	// holstered with Use: no re-draw until Use is let go
	int   mCatchGrace[MAXPLAYERS];	// tics after a catch before the grip is read again
	int   mDrawGrace[MAXPLAYERS];	// tics after a draw before an empty off hand counts as eviction
	int   mStartDrawn[MAXPLAYERS];	// countdown to the draw at spawn (ssq_start_drawn)
	bool  mInZone[MAXPLAYERS];		// the off hand is in the zone over the shoulder: the off-hand gun has yielded
	// THE LOCK-ON YOU SEE. While the shield is held, a cone from where the off hand points picks
	// the targets every tic; a ring hangs over each, biggest over the first the disc will visit.
	// Let go and this list is what flies, in this order.
	Array<Actor> mLocks[MAXPLAYERS];
	Array<Actor> mLockMarks[MAXPLAYERS];
	Array<int>   mLockMiss[MAXPLAYERS];	// tics each lock has been out of the keep cone or out of sight
	int   mLastPaint[MAXPLAYERS];	// the tic the last target was painted: they go on one at a time
	int   mKeepMarks[MAXPLAYERS];	// let go for less than this long and your marks are still there
	int   mLockSig[MAXPLAYERS];


	// ---- lookups -------------------------------------------------------------------
	static clearscope SSQ_Handler Get() { return SSQ_Handler(EventHandler.Find('SSQ_Handler')); }

	static clearscope double SV(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}
	static clearscope int SVI(Name n, int def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetInt() : def;
	}
	static clearscope double UV(PlayerInfo p, Name n, double def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetFloat() : def;
	}
	static clearscope int UVI(PlayerInfo p, Name n, int def)
	{
		let cv = CVar.GetCVar(n, p);
		return cv ? cv.GetInt() : def;
	}
	// cm -> map units
	static clearscope double CM(double cm) { return cm * SSQ_Hand.VU() / 100.0; }

	clearscope int StateOf(int pnum) { return mState[pnum]; }
	clearscope SSQ_Pose PoseOf(int pnum) { return mPose[pnum]; }

	// LEFT-HANDED IS THE ENGINE'S SETTING, not ours: vr_control_scheme >= 10 (gl_openxrdevice.cpp:639).
	// It is a local cvar, so it travels in the pose event (arg3 bit 0) and every machine reads it
	// from the sender's pose; before any pose has arrived the local cvar stands in.
	static clearscope bool LocalLeftHanded()
	{
		let cv = CVar.FindCVar('vr_control_scheme');
		return cv && cv.GetInt() >= 10;
	}
	static clearscope bool LeftHanded(PlayerInfo p)
	{
		let h = Get();
		if (h && p && p.mo)
		{
			int n = p.mo.PlayerNumber();
			if (n >= 0 && n < MAXPLAYERS && h.mPose[n].count > 0) return h.mPose[n].left;
		}
		return LocalLeftHanded();
	}

	// ---- the mount: a point over the off shoulder, relative to the body ----------------
	// Forward is the pawn's yaw (the head's, in VR); up is from the eye (viewz, which the sim
	// has for every player). The off side is the left for a right-handed scheme.
	static clearscope Vector3 MountPos(PlayerPawn mo)
	{
		let p = mo.player;
		double side = CM(UV(p, 'ssq_mount_side', 8.0)) * (LeftHanded(p) ? -1 : 1);
		double fwd = CM(UV(p, 'ssq_mount_fwd', -7.0));
		double up = CM(UV(p, 'ssq_mount_up', -4.0));
		double a = mo.angle;
		Vector3 f = (cos(a), sin(a), 0);
		Vector3 l = (cos(a + 90), sin(a + 90), 0);
		return mo.pos + f * fwd + l * side + (0, 0, p.viewz - mo.pos.z + up);
	}

	// THE HOLSTERED POSE, DERIVED FROM THE MESH, not from hand-set offsets.
	//
	// MountPos is the grab point: where the hand is when it reaches over the shoulder.
	// Holstered, the shield hangs there in the one orientation that is both grabbable and
	// guards the back: its forearm axis F points UP (the handle is at the top, where your
	// hand closes on it) and its +L side -- the side your arm is on -- faces FORWARD into
	// your back, so the face normal -L looks behind you. U = F x L is then the player's
	// left. The disc falls ssq_plate_f (15.4 cm, measured) below the grab point on its own,
	// which is what ssq_mount_drop used to guess at.
	//
	// The world prop (SSQ_Prop) is one MODELDEF block with no mirror, so this frame uses
	// the unmirrored lateral sign for both handednesses: 5 cm of ssq_plate_u is all that
	// differs between them, on a 58 cm disc.
	static clearscope Vector3 MountPlateCentre(PlayerPawn mo)
	{
		double a = mo.angle;
		Vector3 Fh = (0, 0, 1);
		Vector3 Lh = (cos(a), sin(a), 0);			// forward
		Vector3 Uh = (cos(a + 90), sin(a + 90), 0);	// Fh x Lh = the player's left
		double k = SSQ_Guard.Scale();
		return MountPos(mo)
			+ Fh * (CM(SV('ssq_plate_f', -15.4)) * k)
			+ Lh * (CM(SV('ssq_plate_l', -7.5)) * k)
			+ Uh * (CM(SV('ssq_plate_u', -5.0)) * k);
	}

	static clearscope Vector3 MountPlateNormal(PlayerPawn mo)
	{
		double a = mo.angle;
		return (-cos(a), -sin(a), 0);	// -Lh: behind you
	}

	// the prop's own angles for that frame. models.cpp RenderModel composes
	// rotate(-angle,Y) . rotate(-pitch,Z) . rotate(-roll,X) on a vertex swizzled to
	// (mx, mz, my), so model +x is the actor's forward and model +y its left: pitch -90
	// stands the handle up, and roll 180 turns the mesh's +y (its +L side) forward.
	static clearscope double MountPropPitch() { return -90.0; }
	static clearscope double MountPropRoll() { return 180.0; }

	// THE LOCK/THROW TRIGGER, and why it is not just the alt button any more.
	//
	// Lock-on and the throw both hung on BT_OFFHANDALTATTACK alone. On a Quest that action is
	// `alt +oh_altatk` in the stock bind set (engine/vr/defbind3.txt) -- a GRIP-SHIFTED trigger:
	// you must hold the off grip to reach it, and holding that same grip is what arms QZD's
	// two-hand grab. So the one button the shield needed most was the one button the player
	// could not press cleanly, and from the outside the shield simply never locked and never
	// threw. The owner's own lightsaber reads BT_OFFHANDATTACK -- the plain off-hand trigger --
	// and that is why its lock-on and throw work.
	//
	// So: either button, by default. Holding the off trigger revs the saw AND paints locks;
	// letting go with the arm moving throws, which is also how the saber does it and makes a
	// revved throw the natural one. ssq_lock_button 0 keeps the old alt-only behaviour, 2 is
	// the trigger alone.
	// ---- LIVING WITH OTHER OFF-HAND MODS ------------------------------------------------
	//
	// Two mods we load beside are built to never leave the off hand empty: the weapon pack's
	// RSQ_Hands re-gives itself whenever the slot is null, and UltraBadassQuestSaber's bridge
	// gives UBQS_SaberOff to an empty off hand every tic when dual is on. Both are right to
	// do it and neither knows about us. The consequence is that an off-hand slot we leave
	// null for even one tic gets filled by somebody, and whatever we do next fights them.
	//
	// So: a weapon that appears in the off hand BY ITSELF is not the player taking the hand
	// away from us. This names those -- by class name, at run time, so neither mod has to be
	// present and nothing links against them.
	static clearscope bool IsFiller(Weapon w)
	{
		if (!w) return false;
		String n = w.GetClassName();
		return n.IndexOf('Hands') >= 0 || n.IndexOf('UBQS_') == 0;
	}

	// the off-hand weapon another mod would hand back when we let go, if there is one
	static clearscope Weapon HandBack(PlayerPawn mo)
	{
		static const Name fillers[] = { 'UBQS_SaberOff', 'RSQ_Hands' };
		for (int k = 0; k < 2; k++)
		{
			let w = Weapon(mo.FindInventory(fillers[k]));
			if (w) return w;
		}
		return null;
	}

	static clearscope bool SecHeld(PlayerInfo p)
	{
		int b = p.cmd.buttons;
		int mode = SVI('ssq_lock_button', 1);
		if (mode == 0) return (b & BT_OFFHANDALTATTACK) != 0;
		if (mode == 2) return (b & BT_OFFHANDATTACK) != 0;
		return (b & (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK)) != 0;
	}

	static clearscope double Reach(PlayerInfo p) { return CM(UV(p, 'ssq_mount_reach', 10.0)); }
	// THE ZONE over the shoulder: larger than the grab reach, so the hand is inside it for tics
	// before the finger can be at the grab point
	static clearscope double Zone(PlayerInfo p) { return Reach(p) * SV('ssq_zone_scale', 2.2); }

	// ---- lifecycle ----------------------------------------------------------------
	override void OnRegister()
	{
		for (int i = 0; i < MAXPLAYERS; i++) mPose[i] = new('SSQ_Pose');
	}

	override void PlayerEntered(PlayerEvent e) { Give(e.PlayerNumber); }
	override void PlayerRespawned(PlayerEvent e) { Give(e.PlayerNumber); }

	void Give(int pnum)
	{
		if (pnum < 0 || pnum >= MAXPLAYERS || !playeringame[pnum]) return;
		let p = players[pnum];
		let mo = p.mo;
		if (!mo) return;
		mState[pnum] = SS_STOWED;
		mPrevOff[pnum] = null; mPrevMain[pnum] = null;
		if (!mo.FindInventory('SSQ_Guard')) mo.GiveInventory('SSQ_Guard', 1);
		if (SVI('ssq_start', 1) == 0) return;
		if (!mo.FindInventory('SSQ_ShieldSaw'))
		{
			mo.GiveInventory('SSQ_ShieldSaw', 1);
			// the give sets PendingWeapon unless the weapon carries NO_AUTO_SWITCH; make sure
			let saw = Weapon(mo.FindInventory('SSQ_ShieldSaw'));
			if (saw && p.PendingWeapon == saw) p.PendingWeapon = WP_NOCHANGE;
			WeaponSlots.SetupWeaponSlots(mo);
		}
		mStartDrawn[pnum] = UVI(p, 'ssq_start_drawn', 0) != 0 ? 3 : 0;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++) { mProp[i] = null; mMarker[i] = null; mDisc[i] = null; }
	}

	// ---- the sim, once a tic, every machine ------------------------------------------
	override void WorldTick()
	{
		SendPose();
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let p = players[i];
			let mo = p.mo;
			if (p.playerstate != PST_LIVE || mo.health <= 0)
			{
				if (mState[i] == SS_DRAWN) Stow(i, false);
				continue;
			}
			let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
			if (!saw) { HideProps(i); continue; }

			// nothing but Draw() puts the shield in the hand: undo the engine filling an empty
			// off hand with it, or a level change re-raising it
			if (mState[i] != SS_DRAWN && p.OffhandWeapon == saw) Unstow(i);
			if (mState[i] == SS_DRAWN) { if (SVI('ssq_yield_offhand', 0) != 0) HoldOrYield(i, saw); else PinHands(i, saw); }
			if (mState[i] == SS_FLYING && !mDisc[i]) { mState[i] = SS_STOWED; }
			if (mStartDrawn[i] > 0 && mState[i] == SS_STOWED && --mStartDrawn[i] == 0) Draw(i);

			// USE: grab in the zone / holster in the zone. Level, not edge, for the grab: a use
			// already held when the hand reaches the zone grabs too.
			bool use = (p.cmd.buttons & BT_USE) != 0;
			bool usePress = use && !mUseWas[i];
			mUseWas[i] = use;
			if (mCatchGrace[i] > 0) { mCatchGrace[i]--; usePress = false; use = false; }
			// A HOLSTER ON THE PRESS MUST NOT BE A DRAW ON THE NEXT TIC. Stow fires on
			// the press; the stowed grab reads the level -- so with Use still down and
			// the hand still at the mount, the very next tic drew it again. The latch
			// holds until Use is let go.
			if (!use) mStowLatch[i] = false;
			if (mState[i] == SS_STOWED && use && !mStowLatch[i]) OnPress(i);
			else if (mState[i] == SS_DRAWN && usePress) OnPress(i);
			// HOLD to lock on, let go to throw, press again in flight to recall.
			// Either off-hand button by default -- see SecHeld.
			bool sec = SecHeld(p);
			bool secPress = sec && !mGripWas[i];
			bool secRelease = !sec && mGripWas[i];
			mGripWas[i] = sec;
			if (secRelease) OnRelease(i);
			else if (secPress && mState[i] == SS_FLYING && mDisc[i]) SSQ_Disc(mDisc[i]).Recall();

			if (mState[i] == SS_DRAWN && UVI(p, 'ssq_debug', 0) != 0 && (Level.maptime % 35) == 0)
			{
				let ps = mPose[i];
				Vector3 C = SSQ_Guard.PlateCentre(mo, ps, false);
				Vector3 n = SSQ_Guard.PlateNormal(mo, ps, false);
				Console.Printf("ssq: pose F(%.2f %.2f %.2f) L(%.2f %.2f %.2f) U(%.2f %.2f %.2f) hand(%.0f %.0f %.0f) C(%.0f %.0f %.0f) n(%.2f %.2f %.2f) R %.1f fresh %d",
					ps.F.x, ps.F.y, ps.F.z, ps.L.x, ps.L.y, ps.L.z, ps.U.x, ps.U.y, ps.U.z,
					ps.pos[0].x, ps.pos[0].y, ps.pos[0].z, C.x, C.y, C.z, n.x, n.y, n.z, SSQ_Guard.PlateRadius(false), ps.Fresh(Level.maptime));
			}
			LocksTick(i);
			Props(i);
		}
	}

	void ZoneTick(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool inZone = mState[i] == SS_STOWED && pose.Fresh(Level.maptime) && (pose.pos[0] - MountPos(mo)).Length() <= Zone(p);
		let w = p.OffhandWeapon;
		bool ours = w is "SSQ_ShieldSaw";
		if (inZone && w && !ours)
		{
			if (p.FindPSprite(PSP_OFFHANDWEAPON)) p.SetPsprite(PSP_OFFHANDWEAPON, null);
			mInZone[i] = true;
		}
		else if (mInZone[i])
		{
			mInZone[i] = false;
			if (w && !ours && !p.FindPSprite(PSP_OFFHANDWEAPON) && p.PendingWeapon == WP_NOCHANGE)
				p.SetPsprite(PSP_OFFHANDWEAPON, w.GetReadyState());
		}
	}

	// USE in the zone: holstered -> draw; drawn -> holster
	void OnPress(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool fresh = pose.Fresh(Level.maptime);
		double dist = fresh ? (pose.pos[0] - MountPos(mo)).Length() : 1e9;
		bool atMount = dist <= Reach(p);
		if (UVI(p, 'ssq_debug', 0))
		{
			// the hand relative to the headset, in cm: forward, to the off side, up
			Vector3 rel = fresh ? pose.pos[0] - (mo.pos.x, mo.pos.y, p.viewz) : (0, 0, 0);
			double a = mo.angle, k = 100.0 / SSQ_Hand.VU();
			double f = (rel.x * cos(a) + rel.y * sin(a)) * k;
			double l = (rel.x * cos(a + 90) + rel.y * sin(a + 90)) * k * (LeftHanded(p) ? -1 : 1);
			Console.Printf("ssq: press p%d state %d fresh %d mountdist %.1f  hand from headset: fwd %.0f side %.0f up %.0f cm", i, mState[i], fresh, dist, f, l, rel.z * k);
		}
		if (!atMount) return;
		if (mState[i] == SS_STOWED) Draw(i);
		else if (mState[i] == SS_DRAWN) { Stow(i, true); mStowLatch[i] = true; }
	}

	// secondary released: moving fast throws; still, it stays in the hand
	void OnRelease(int i)
	{
		if (mState[i] != SS_DRAWN) return;
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		Vector3 hv = pose.Fresh(Level.maptime) ? pose.ThrowVel(SSQ_Hand.PS(mo)) : (0, 0, 0);
		double speed = hv.Length() * TICRATE;
		// A THROW IS A FORWARD SNAP, NOT ANY FAST HAND. Letting go at the end of a block, a
		// backhand or a chop used to launch the shield because only raw speed was tested. The
		// hand has to be going out the way you are looking -- ssq_throw_forward is the cosine
		// of how far off that it may be (0.35 is about 70 degrees). 0 takes any direction back.
		double fwdmin = SV('ssq_throw_forward', 0.35);
		bool forward = true;
		if (fwdmin > 0 && speed > 0)
		{
			Vector3 look = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
			forward = (hv.Unit() dot look) >= fwdmin;
		}
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: release p%d speed %.0f/s, %d locked, forward %d", i, speed, mLocks[i].Size(), forward);
		if (speed >= SV('ssq_throw_min', 20.0) && forward) Throw(i);
		else mKeepMarks[i] = Level.maptime + SVI('ssq_keep_marks', 35);	// not a throw: hold the marks a moment
	}

	clearscope bool Holding(int i) { return true; }	// the catch needs only the hand near the disc

	// WHILE FIRE IS HELD BOTH HANDS ARE PINNED: the shield in the off hand, the gun you had in
	// the main hand. QZD's `switchhand` (an off-hand button on the Quest) nulls BOTH hands and
	// moves the gun across (player.zs SwitchWeaponHand); a weapon-cycle or a pickup switch
	// changes one. Whatever happened, it is undone this tic. Only the release moves the shield.
	// WE STOPPED FIGHTING THE ENGINE FOR THE OFF HAND.
	//
	// v0.6 pinned both hands every single tic: if anything moved a weapon it was put back the
	// same tic, forever. That was aimed at QZD's `switchhand`, which an off-hand button is
	// bound to by default (engine/vr/defbind1.txt:6-7, defbind3.txt:12,21). Reading the stock
	// source settles what it actually does (g_game.cpp:347-361 -> player.zs:2488-2502): the
	// argument is the DESTINATION hand, so it moves the weapon in the OTHER one.
	//
	//   switchhand 0  moves the OFF-hand weapon -- the shield -- into the main hand.
	//                 +WEAPON.NOHANDSWITCH on the shield blocks this outright. Already set.
	//   switchhand 1  moves the MAIN-hand gun into the off hand. It tests NoHandSwitch on the
	//                 GUN, not on us, then nulls BOTH slots -- so the shield can always be
	//                 evicted and no flag we carry can prevent it.
	//
	// So eviction is not an error to undo, it is the player putting the shield down. We take
	// it as exactly that: the shield goes back to the shoulder, the loadout is restored once,
	// and the hand is theirs. Nothing is forced, nothing is re-raised behind their back, and
	// the engine's own command keeps working the way its own menu says it does.
	//
	// The two-hand grab needs no handling here at all. It never nulls OffhandWeapon and never
	// touches the hand pose; it only disables the off-hand weapon's ready/fire/button
	// machinery (weapons.zs:415-418, player.zs:393-396, p_pspr.cpp:847-850) -- and the shield
	// does not use any of it. Every input it has is read straight off p.cmd.buttons, which is
	// in the replicated ticcmd and which the grab cannot gate. The one thing the grab does
	// take is the drawn psprite, and the world prop covers that (see the prop block).
	// THE PIN. This is what v0.6 did and what the shield is known to work with: if anything
	// moves a weapon out of the off hand, put the shield straight back the same tic. It is a
	// fight with the engine, but it is a fight the shield wins, and the weapon pack re-giving
	// its hands weapon to an 'empty' off hand is a real thing that happens every tic.
	// ssq_yield_offhand 1 picks HoldOrYield below instead.
	void PinHands(int i, SSQ_ShieldSaw saw)
	{
		let p = players[i];
		let mo = p.mo;
		bool fix = false;
		// What took the off hand this tic, if anything -- switchhand's fingerprint (below).
		Weapon took = p.OffhandWeapon;
		if (p.OffhandWeapon != saw) fix = true;
		if (p.PendingWeapon && p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon != saw && p.PendingWeapon.bOffhandWeapon) fix = true;
		if (fix)
		{
			saw.bOffhandWeapon = true;
			// IT MUST NOT MATTER WHO RAN FIRST THIS TIC. Event handlers tick in registration
			// order, which is LOAD order, so whether the saber's bridge or this handler sees the
			// off hand first depends on which pk3 the launcher listed first. Setting only
			// PendingWeapon makes us one voice among several and the last writer in the tic wins.
			// Writing the slot itself does not: whoever ran before us is overridden, and whoever
			// runs after us finds a hand that is not empty and leaves it alone -- which is all
			// either of those mods was ever waiting for. Load order stops mattering.
			p.OffhandWeapon = saw;
			p.PendingWeapon = saw;
			mo.BringUpWeapon();
			if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: pin off -> shield");
		}
		// and cancel a raise somebody else asked for while the shield is the one in the hand
		if (p.PendingWeapon && p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon != saw && p.PendingWeapon.bOffhandWeapon)
			p.PendingWeapon = WP_NOCHANGE;
		// THE MAIN HAND IS UNDONE ONLY WHEN switchhand DID IT. switchhand moves the main gun
		// INTO the off hand (sets its bOffhandWeapon, player.zs:2488-2502) -- so that gun is
		// either what took the off hand this tic or still carries the off-hand flag. Any other
		// change to the main hand is the player's own (a slot key, weapnext, running dry, a
		// pickup's auto-switch), and the shield follows it: the remembered gun becomes the one
		// now in hand. Before this, EVERY main-hand switch was put back ~12 tics later, and a
		// gun that ran dry looped forever (rig, 2026-10-26, with BD22).
		if (mPrevMain[i])
		{
			let back = Weapon(mo.FindInventory(mPrevMain[i]));
			bool switchhand = back && back != saw && (took == back || back.bOffhandWeapon);
			if (!switchhand && p.PendingWeapon == WP_NOCHANGE && p.ReadyWeapon && p.ReadyWeapon != saw && !p.ReadyWeapon.bOffhandWeapon)
				mPrevMain[i] = p.ReadyWeapon.GetClass();
			if (switchhand && p.ReadyWeapon != back && !back.bTwoHanded)
			{
				back.bOffhandWeapon = false;
				p.PendingWeapon = back;
				mo.BringUpWeapon();
				if (UVI(p, 'ssq_debug', 0)) { String rw = "-"; if (p.ReadyWeapon) rw = p.ReadyWeapon.GetClassName(); Console.Printf("ssq: pin main -> %s (now %s)", mPrevMain[i].GetClassName(), rw); }
			}
		}
	}

	// THE YIELD, off by default (ssq_yield_offhand 1). Reads an off hand taken by switchhand or
	// by a pickup as the player putting the shield down, instead of undoing it. Correct in
	// principle -- and it took the shield out of the hand entirely on a pack that re-gives its
	// hands weapon, which is why it is not the default until it has been seen to work.
	void HoldOrYield(int i, SSQ_ShieldSaw saw)
	{
		let p = players[i];
		if (mDrawGrace[i] > 0) { mDrawGrace[i]--; return; }
		if (p.OffhandWeapon == saw) return;
		if (p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon == saw) return;	// mid-raise
		// A WEAPON THAT PUT ITSELF THERE IS NOT THE PLAYER TAKING THE HAND. The pack's hands and
		// the saber's off-hand blade both appear in an empty off hand on their own; yielding to
		// those would have the shield stow itself a tic after every draw. Only a real weapon
		// arriving -- a switchhand, a pickup -- counts, and anything else gets pinned back.
		if (IsFiller(p.OffhandWeapon) || !p.OffhandWeapon) { PinHands(i, saw); return; }
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d off hand taken -- shield to the shoulder", i);
		// the player has just arranged their own hands: forget what the draw displaced, so
		// Unstow does not hand it straight back and start the fight over.
		mPrevOff[i] = null; mPrevMain[i] = null;
		Stow(i, true);
	}
	void ShownLocks(int i, out Array<Actor> found)
	{
		found.Clear();
		if (i < 0 || i >= MAXPLAYERS) return;
		for (int k = 0; k < mLocks[i].Size(); k++) if (mLocks[i][k] && mLocks[i][k].health > 0) found.Push(mLocks[i][k]);
	}

	void ClearLocks(int i)
	{
		mLocks[i].Clear();
		mLockMiss[i].Clear();
		mKeepMarks[i] = 0;
		mLastPaint[i] = 0;
		for (int k = 0; k < mLockMarks[i].Size(); k++) if (mLockMarks[i][k]) mLockMarks[i][k].Destroy();
		mLockMarks[i].Clear();
		mLockSig[i] = 0;
	}

	// IS THIS ONE STILL MINE? The keep test, deliberately looser than the acquire test:
	// alive, inside ssq_lock_keep of where the hand points, in range, in sight.
	static bool LockHolds(PlayerPawn mo, Vector3 from, Vector3 aim, Actor t)
	{
		if (!t || t.health <= 0 || !t.bShootable) return false;
		Vector3 d = t.pos + (0, 0, t.height * 0.5) - from;
		double dist = d.Length();
		if (dist < 1 || dist > SV('ssq_lock_range', 1200.0)) return false;
		if (acos(clamp((d / dist) dot aim, -1, 1)) > SV('ssq_lock_keep', 60.0)) return false;
		return mo.CheckSight(t);
	}

	// once a tic while held: keep what is locked, add what is newly aimed at, and show it.
	//
	// STICKY. v0.6 rebuilt this list from the acquire cone every single tic and re-sorted it
	// by angle, so a target fell out the moment the hand drifted 25 degrees and the disc's
	// visit order churned under the player's eyes -- "lock-on does not stay locked on".
	// Now a lock is acquired inside ssq_lock_cone and KEPT until it dies, leaves the much
	// wider ssq_lock_keep cone, goes out of sight or out of range for ssq_lock_grace tics in
	// a row, or the button comes up. Order is the order you ringed them in, which is the
	// order the disc will visit them -- it never re-sorts behind you.
	void LocksTick(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool aiming = SecHeld(p);
		// A BRIEF RELEASE DOES NOT COST YOU YOUR MARKS. Let go for under ssq_keep_marks tics --
		// to re-grip, to steady yourself -- and the list is still there when you take hold again.
		// Longer than that, or the shield leaving your hand, and it starts fresh.
		if (mState[i] != SS_DRAWN || !pose.Fresh(Level.maptime))
		{
			if (mLocks[i].Size() > 0) ClearLocks(i);
			return;
		}
		if (!aiming)
		{
			if (mLocks[i].Size() > 0 && Level.maptime > mKeepMarks[i]) ClearLocks(i);
			return;
		}

		int want = SVI('ssq_locks', 5);
		int grace = SVI('ssq_lock_grace', 14);
		while (mLockMiss[i].Size() < mLocks[i].Size()) mLockMiss[i].Push(0);

		// hold what is already locked
		for (int k = mLocks[i].Size() - 1; k >= 0; k--)
		{
			if (LockHolds(mo, pose.pos[0], pose.F, mLocks[i][k])) { mLockMiss[i][k] = 0; continue; }
			bool dead = !mLocks[i][k] || mLocks[i][k].health <= 0;
			mLockMiss[i][k] = mLockMiss[i][k] + 1;
			if (dead || mLockMiss[i][k] > grace) { mLocks[i].Delete(k); mLockMiss[i].Delete(k); }
		}

		// ONE AT A TIME, AS YOU SWEEP. Taking every target in the cone at once turns lock-on into
		// a scan: you point roughly at a crowd and five rings appear. Painting the best one every
		// ssq_paint_every tics makes it aiming -- you drag the hand across them and feel each one
		// go on, which is how the owner's lightsaber does it.
		int added = 0;
		if (mLocks[i].Size() < want && Level.maptime - mLastPaint[i] >= SVI('ssq_paint_every', 3))
		{
			Array<Actor> fresh;
			SSQ_Disc.FindTargets(mo, pose.pos[0], pose.F, fresh);
			for (int k = 0; k < fresh.Size(); k++)
			{
				let t = fresh[k];
				if (!t) continue;
				bool have = false;
				for (int j = 0; j < mLocks[i].Size(); j++) if (mLocks[i][j] == t) { have = true; break; }
				if (have) continue;
				mLocks[i].Push(t); mLockMiss[i].Push(0); added++;
				mLastPaint[i] = Level.maptime;
				break;		// the nearest to the hand's line, and only that one, this time
			}
		}
		if (added > 0)
		{
			mo.A_StartSound("ssq/lock", CHAN_6, 0, 0.8);
			SSQ_FX.Buzz(mo, 0.35, 3);	// you feel each one land, the way the saber does
		}

		// one ring per target, sized by rank: biggest over the one the disc visits first
		while (mLockMarks[i].Size() < mLocks[i].Size())
		{
			let m = Actor.Spawn('SSQ_LockMark', mo.pos);
			mLockMarks[i].Push(m);
		}
		for (int k = 0; k < mLockMarks[i].Size(); k++)
		{
			let m = mLockMarks[i][k];
			if (!m) continue;
			if (k >= mLocks[i].Size()) { m.bInvisible = true; continue; }
			let t = mLocks[i][k];
			if (!t) { m.bInvisible = true; continue; }
			// BIG ENOUGH TO SEE. These were 1.6 / 1.1 / 0.8 at 60% alpha over a monster's head,
			// which in a headset at ten metres is nothing. The one the disc visits first is twice
			// the size of the rest and fully lit, and it breathes so it reads as alive.
			double pulse = 1.0 + 0.12 * sin(Level.maptime * 9.0 + k * 40);
			m.bInvisible = false;
			m.SetOrigin(t.pos + (0, 0, t.height + 12), true);
			// around the actor's own 0.35, not around 1: the one the disc visits first is a
			// little under twice the others, which is plenty to read at range without
			// magnifying a 48-pixel picture into a dinner plate.
			m.A_SetScale(0.35 * (k == 0 ? 1.8 : (k == 1 ? 1.3 : 1.0)) * pulse * SV('ssq_lock_mark_scale', 1.0));
			m.A_SetRenderStyle(k == 0 ? 1.0 : 0.85, STYLE_Add);
			m.angle += (k == 0 ? 14 : 8);
		}
	}

	// ---- the loadout swap -------------------------------------------------------------
	void Draw(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = Weapon(mo.FindInventory('SSQ_ShieldSaw'));
		if (!saw) return;
		let cur = p.OffhandWeapon;
		// the pack's hands weapon comes back on its own (RSQ_Handler re-gives it whenever the
		// off hand is empty), so it is not remembered; anything else is
		mPrevOff[i] = (cur && cur != saw && cur.GetClassName() != 'RSQ_Hands') ? cur.GetClass() : null;
		let rw = p.ReadyWeapon;
		mPrevMain[i] = (rw && rw != saw) ? rw.GetClass() : null;	// pinned while held (switchhand undone)
		saw.bOffhandWeapon = true;
		p.OffhandWeapon = saw;	// the slot is ours THIS tic: no window for anyone to fill
		p.PendingWeapon = saw;
		// BRING IT UP OURSELVES. A switch normally happens inside the old weapon's ready state
		// (it sees PendingWeapon, lowers, raises the next) -- and the zone took that layer away.
		mo.BringUpWeapon();
		mInZone[i] = false;
		mDrawGrace[i] = 8;	// the raise takes a few tics; do not read an empty slot as eviction
		mState[i] = SS_DRAWN;
		mo.A_StartSound("ssq/draw", CHAN_6);
		SSQ_FX.Buzz(mo, 0.5, 6);
		if (UVI(p, 'ssq_debug', 0))
		{
			String po = "-", pm = "-";
			if (mPrevOff[i]) po = mPrevOff[i].GetClassName();
			if (mPrevMain[i]) pm = mPrevMain[i].GetClassName();
			Console.Printf("ssq: p%d DRAW (prev off %s, prev main %s)", i, po, pm);
		}
	}

	// put the previous weapons back; the shield is out of the hand either way
	void Unstow(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		if (p.OffhandWeapon == saw)
		{
			p.SetPsprite(PSP_OFFHANDWEAPON, null);
			p.OffhandWeapon = null;
		}
		if (p.PendingWeapon == saw) p.PendingWeapon = WP_NOCHANGE;
		if (saw) saw.StopRev();
		// THE MAIN HAND FIRST, if raising the shield emptied it (BringUpWeapon nulls a two-handed
		// main gun). This used to sit in an `else` that tested the opposite of its own `if`, so it
		// never ran and the main hand stayed empty. BringUpWeapon raises it at once and leaves
		// PendingWeapon free for the off-hand handover below.
		if (mPrevMain[i] && !p.ReadyWeapon && p.PendingWeapon == WP_NOCHANGE)
		{
			let mainBack = Weapon(mo.FindInventory(mPrevMain[i]));
			if (mainBack && mainBack != saw) { mainBack.bOffhandWeapon = false; p.PendingWeapon = mainBack; mo.BringUpWeapon(); }
		}
		// HAND THE SLOT OVER, DO NOT DROP IT. Leaving OffhandWeapon null even for one tic is an
		// invitation: the pack and the saber both fill an empty off hand on their own schedule,
		// and then two mods are writing PendingWeapon in the same tic and the last one wins.
		// Whatever we displaced goes back here and now; if we displaced nothing, we give the
		// slot to whoever would have claimed it anyway, deliberately, instead of racing them.
		if (p.PendingWeapon == WP_NOCHANGE)
		{
			Weapon back = mPrevOff[i] ? Weapon(mo.FindInventory(mPrevOff[i])) : null;
			if (!back) back = HandBack(mo);
			if (back && back != p.ReadyWeapon && back != saw)
			{
				back.bOffhandWeapon = true;
				p.OffhandWeapon = back;	// the slot is filled THIS tic, not after a raise
				p.PendingWeapon = back;
				mo.BringUpWeapon();
			}
		}
		mPrevOff[i] = null; mPrevMain[i] = null;
	}

	void Stow(int i, bool sound)
	{
		Unstow(i);
		ClearLocks(i);
		mState[i] = SS_STOWED;
		if (sound) players[i].mo.A_StartSound("ssq/stow", CHAN_6);
		if (UVI(players[i], 'ssq_debug', 0)) Console.Printf("ssq: p%d STOW", i);
	}

	void Throw(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		let pose = mPose[i];
		int rev = saw ? saw.rev : 0;
		Unstow(i);
		let d = SSQ_Disc(Actor.Spawn('SSQ_Disc', pose.pos[0]));
		if (!d) { mState[i] = SS_STOWED; ClearLocks(i); return; }
		d.Launch(mo, pose, rev);
		ClearLocks(i);
		mDisc[i] = d;
		mState[i] = SS_FLYING;
		mo.A_StartSound("ssq/throw", CHAN_6);
		SSQ_FX.Buzz(mo, 0.8, 8);
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d THROW speed %.1f/tic rev %d locks %d", i, d.vel.Length(), rev, d.locks.Size());
	}

	// the disc is home: caught (into the hand) or landed (onto the mount)
	void DiscHome(int i, bool caught)
	{
		mDisc[i] = null;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i]) return;
		mState[i] = SS_STOWED;
		if (UVI(players[i], 'ssq_debug', 0)) Console.Printf("ssq: p%d disc home, %s", i, caught ? "CAUGHT" : "landed on the mount");
		let mo = players[i].mo;
		if (!mo || mo.health <= 0) return;
		if (caught)
		{
			Draw(i);
			mCatchGrace[i] = 8;
			mo.A_StartSound("ssq/catch", CHAN_6);
			SSQ_FX.Buzz(mo, 1.0, 10);
		}
	}

	// ---- the world props -------------------------------------------------------------
	void HideProps(int i)
	{
		if (mProp[i]) mProp[i].bInvisible = true;
		if (mMarker[i]) mMarker[i].bInvisible = true;
	}

	void Props(int i)
	{
		let p = players[i];
		let mo = p.mo;
		if (!mProp[i]) mProp[i] = Actor.Spawn('SSQ_Prop', mo.pos);
		if (!mMarker[i]) mMarker[i] = Actor.Spawn('SSQ_MountMarker', mo.pos);
		let prop = mProp[i];
		let mk = mMarker[i];
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		let pose = mPose[i];
		Vector3 mount = MountPos(mo);

		// the marker: 0 never, 1 while it matters, 2 always; brighter when the hand is in reach
		int mode = UVI(p, 'ssq_marker', 1);
		bool show = mode == 2 || (mode == 1 && mState[i] != SS_FLYING);
		mk.bInvisible = !show;
		if (show)
		{
			mk.SetOrigin(mount, true);
			mk.A_SetScale(Reach(p) * 0.4);
			double d = pose.Fresh(Level.maptime) ? (pose.pos[0] - mount).Length() : 1e9;
			mk.A_SetRenderStyle(d <= Reach(p) ? 0.9 : (d <= Zone(p) ? 0.5 : 0.2), STYLE_Add);
			mk.angle += 3;
		}

		// THE SHIELD YOU CAN SEE.
		//
		// Stowed, the prop IS the shield: it hangs at the grab point in the pose the guard
		// plate is computed for (MountPlateCentre/Normal), so what blocks and what is drawn
		// are the same object. The mesh origin is the grip, which is why the actor sits at
		// the grab point itself and the disc falls below it on its own -- no drop fudge.
		// Model +x is the actor's forward and +y its left (models.cpp RenderModel over the
		// (mx, mz, my) swizzle), so pitch -90 stands the forearm axis up and roll 180 turns
		// the plate's +L side -- the side your arm is on -- forward into your back.
		if (mState[i] == SS_STOWED)
		{
			prop.bInvisible = UVI(p, 'ssq_stow_world', 0) == 0;	// owner's default: not drawn when stored
			prop.SetOrigin(mount, true);
			prop.angle = mo.angle + UV(p, 'ssq_mount_yaw', 0);
			prop.pitch = MountPropPitch() + UV(p, 'ssq_mount_pitch', 0);
			prop.roll  = MountPropRoll()  + UV(p, 'ssq_mount_roll', 0);
			prop.A_SetScale(UV(p, 'ssq_mount_scale', 1.0) * SSQ_Guard.Scale());
			prop.frame = 0;
		}
		else if (mState[i] == SS_DRAWN)
		{
			// 0 never, 1 always, 2 only for other players' eyes. PLUS: while QZD's two-hand
			// grab is held the engine stops drawing every off-hand psprite in C++
			// (hw_weapon.cpp:833,919) -- script cannot prevent it -- so the shield would
			// vanish out of your own hand. The world prop stands in for exactly that long.
			int hw = UVI(p, 'ssq_held_world', 2);
			bool grabbed = (p.WeaponState & WF_TWOHANDSTABILIZED) != 0;
			bool want = hw == 1 || (hw == 2 && multiplayer) || (hw != 0 && grabbed);
			prop.bInvisible = !want || !pose.Fresh(Level.maptime);
			if (!prop.bInvisible)
			{
				// THE PROP'S ORIGIN IS THE GRIP, not the disc. shield.md3's origin sits in the
				// hand (hand_ssq straddles it, the handle bar is 1.3 cm off it) and the world
				// block carries no Offset, so the actor goes AT THE CONTROLLER and the mesh
				// puts the disc 15.4 cm back along the forearm by itself. Placing it at the
				// plate centre, as this did, pushed the drawn shield a whole radius off the
				// hand -- the guard was right and the picture was not.
				prop.SetOrigin(pose.pos[0], true);
				prop.angle = atan2(pose.F.y, pose.F.x);
				prop.pitch = -asin(clamp(pose.F.z, -1, 1));
				prop.roll = SSQ_Hand.RollOf(pose.F, pose.L);
				prop.A_SetScale(SSQ_Guard.Scale());	// the world copy grows with the plate
				prop.frame = saw ? saw.Frame() : 0;
			}
		}
		else prop.bInvisible = true;
	}

	// ---- the muzzle: every hitscan in the level passes through here first ----------------
	//
	// Stock QZD calls this before P_LineAttack traces anything (p_map.cpp:4718) and true
	// cancels the shot outright. It is the only place a bullet can be stopped, because by the
	// time AbsorbDamage sees one it has already hit. Cheap by construction: it returns on the
	// first line for every shot in the game unless a player actually has a shield up.
	//
	// A PLAYER'S OWN SHOTS ARE NEVER TESTED. Not the gun in their hand, not the shield's own
	// return trace, not another mod's -- a shield stops what is fired AT you.
	override bool WorldHitscanPreFired(WorldEvent e)
	{
		if (SVI('ssq_guard', 1) == 0 || SVI('ssq_hitscan_guard', 1) == 0) return false;
		Actor shooter = e.Thing;
		if (!shooter || shooter.player) return false;
		// our own return shot comes off the plate from a helper (guard.zs): never eat it
		if (shooter is 'SSQ_Ricochet') return false;
		double ca = cos(e.AttackPitch);
		Vector3 dir = (cos(e.AttackAngle) * ca, sin(e.AttackAngle) * ca, -sin(e.AttackPitch));
		if (dir.Length() <= 0) return false;
		// WHERE THE SHOT REALLY STARTS, by P_LineAttack's own formula (p_map.cpp on stock QZD
		// 17.3): shootz = Center() - Floorclip + AttackOffset() + sz, and AttackOffset() is a flat
		// 8 for anything that is not a player. sz is the attack's own z offset, which the event
		// hands us as AttackZ and this never read. height * 0.75 was a guess sitting 6 units high
		// on an imp and 14 on a Cyberdemon -- against a 29 cm plate at twenty metres that is most
		// of the guard, which is why bullets that looked blockable were not.
		// LAF_OVERRIDEZ measures from the actor's feet instead.
		double mz = ((e.AttackLineFlags & LAF_OVERRIDEZ) ? 0.0 : (shooter.height * 0.5 - shooter.Floorclip + 8.0)) + e.AttackZ;
		Vector3 A = shooter.pos + (0, 0, mz);
		double dist = e.AttackDistance > 0 ? e.AttackDistance : 2048.0;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i]) continue;
			let p = players[i];
			if (!p.mo || p.mo == shooter) continue;
			if (mState[i] == SS_FLYING) continue;	// it is not in your hand to block with
			let g = SSQ_Guard(p.mo.FindInventory('SSQ_Guard'));
			if (!g) continue;
			if (g.StopsHitscan(shooter, A, dir, dist, e.Damage))
			{
				if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d ATE a hitscan from %s", i, shooter.GetClassName());
				return true;
			}
		}
		return false;
	}

	// ---- events ------------------------------------------------------------------
	// the live state in the corner, for a screenshot (Debug -> Print decisions)
	override void RenderOverlay(RenderEvent e)
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		if (!p.mo || UVI(p, 'ssq_debug', 0) == 0) return;
		int i = consoleplayer;
		String off = "-", main = "-";
		if (p.OffhandWeapon) off = p.OffhandWeapon.GetClassName();
		if (p.ReadyWeapon) main = p.ReadyWeapon.GetClassName();
		String pend = (p.PendingWeapon == WP_NOCHANGE) ? "-" : (p.PendingWeapon ? String.Format("%s", p.PendingWeapon.GetClassName()) : "null");
		let saw = SSQ_ShieldSaw(p.mo.FindInventory('SSQ_ShieldSaw'));
		int b = p.cmd.buttons;
		String line1 = String.Format("SSQ state %d  off %s  main %s  pending %s", mState[i], off, main, pend);
		String line2 = String.Format("buttons: atk %d alt %d ohatk %d ohalt %d   stabilised %d   rev %d  locks %d",
			(b & BT_ATTACK) != 0, (b & BT_ALTATTACK) != 0, (b & BT_OFFHANDATTACK) != 0, (b & BT_OFFHANDALTATTACK) != 0,
			(p.WeaponState & WF_TWOHANDSTABILIZED) != 0, saw ? saw.rev : -1, mLocks[i].Size());
		let pose = mPose[i];
		String line3 = String.Format("pose fresh %d  mountdist %.1f  zone %d", pose.Fresh(Level.maptime), pose.Fresh(Level.maptime) ? (pose.pos[0] - MountPos(p.mo)).Length() : -1.0, mInZone[i]);
		Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 40, line1, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
		Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 50, line2, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
		Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 60, line3, DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_KeepRatio, true);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i] || !players[i].mo) return;
		let mo = players[i].mo;
		if (e.Name == "ssq-pose")
		{
			double yaw, pitch, roll; int grip;
			[yaw, pitch, roll, grip] = SSQ_Hand.UnpackAng(e.Args[1]);
			mPose[i].Push(mo.pos + SSQ_Hand.UnpackPos(e.Args[0]), mo.pos, mo.angle, yaw, pitch, roll, grip != 0, Level.maptime);
			mPose[i].left = (e.Args[2] & 1) != 0;
		}
		else if (e.Name == "ssq-draw")
		{
			// the desktop route: no reach needed
			if (mState[i] == SS_STOWED) Draw(i);
			else if (mState[i] == SS_DRAWN) Stow(i, true);
			else if (mDisc[i]) SSQ_Disc(mDisc[i]).Recall();
		}
		else if (e.Name == "ssq-throw")
		{
			// throw along the aim, for a player with no hand motion to read
			if (mState[i] == SS_DRAWN) ThrowAlongAim(i);
		}
	}

	void ThrowAlongAim(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		int rev = saw ? saw.rev : 0;
		Vector3 from = mo.pos + (0, 0, p.viewz - mo.pos.z - 8);
		Vector3 dir = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
		Unstow(i);
		let d = SSQ_Disc(Actor.Spawn('SSQ_Disc', from + dir * 16));
		if (!d) { mState[i] = SS_STOWED; return; }
		d.LaunchAlong(mo, dir, SV('ssq_speed_floor', 7.0) * 3.0, 90, rev);	// flat, like a frisbee
		mDisc[i] = d;
		mState[i] = SS_FLYING;
		mo.A_StartSound("ssq/throw", CHAN_6);
		if (UVI(p, 'ssq_debug', 0))
		{
			String mw = "-"; if (p.ReadyWeapon) mw = p.ReadyWeapon.GetClassName();
			String ow = "-"; if (p.OffhandWeapon) ow = p.OffhandWeapon.GetClassName();
			Console.Printf("ssq: p%d THROW along aim, speed %.1f/tic rev %d locks %d  (main now %s, off now %s)", i, d.vel.Length(), rev, d.locks.Size(), mw, ow);
		}
	}

	// ---- the console player's side: the pose, and the raw grip ----------------------------
	// SendPose runs in WorldTick on every machine, for that machine's own console player only:
	// it reads the renderer-written fields (console pawn only) and sends them. The sim never
	// reads those fields anywhere else. OffhandDir is play-scope, so this cannot live in UiTick.
	void SendPose()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || !SSQ_Hand.InVR(mo)) return;
		int st = mState[consoleplayer];
		bool grip = (p.cmd.buttons & (BT_USE | BT_OFFHANDALTATTACK)) != 0;
		Vector3 hand = mo.OffhandPos;
		bool nearMount = (hand - MountPos(mo)).Length() <= Zone(p) * 1.5;
		bool want = st != SS_STOWED || grip || nearMount;
		if (!want) return;
		Vector3 F = SSQ_Hand.OffDir(mo, 0, 0);
		Vector3 L = SSQ_Hand.OffDir(mo, 90, 0);
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		double roll = SSQ_Hand.RollOf(F, L);
		EventHandler.SendNetworkEvent("ssq-pose", SSQ_Hand.PackPos(hand - mo.pos), SSQ_Hand.PackAng(yaw, pitch, roll, grip), LocalLeftHanded() ? 1 : 0);
	}

}
