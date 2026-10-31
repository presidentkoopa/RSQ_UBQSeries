// RS_ShieldSawQ -- the three states, the shoulder mount, the loadout swap, and the input.
//
//   STOWED   on the mount over your off shoulder (a world prop, guarding your back)
//   DRAWN    in your off hand: SSQ_ShieldSaw is the off-hand weapon
//   FLYING   thrown. Your previous off-hand weapon is already back, so you are never
//            empty-handed. The disc comes home along the way it went; a hand near it on the
//            way back catches it (DRAWN), otherwise it lands on the mount (STOWED).
//
// THE INPUT (owner, 2026-10-22 04:08), all synced usercmd bits, nothing to bind:
//   off hand AT THE MOUNT by the off shoulder + USE  -> the shield is in the hand (whatever was
//                                                        there steps aside and comes back after)
//   off PRIMARY held                                  -> the saw revs
//   off SECONDARY held                                -> lock-on: rings over what you aim at
//   off SECONDARY released, arm moving               -> throw, at the ringed targets in order
//   off SECONDARY released, arm still                -> nothing; it stays in the hand
//   off SECONDARY pressed while it flies              -> recall
//   USE at the mount again                            -> back on the shoulder
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
	transient bool mFistNext[MAXPLAYERS];
	transient int a11yFlash;	// the last block star / bloom's tic (Photosensitive Mode, SSQ_FX.FlashOk)	// the next store hands the off hand its fist (ssq_store_to 0)
	class<Weapon> mPrevMain[MAXPLAYERS];	// the main-hand weapon a two-handed conflict lowered
	bool  mGripWas[MAXPLAYERS];		// off secondary last tic
	bool  mUseWas[MAXPLAYERS];
	bool  mStowLatch[MAXPLAYERS];	// holstered with Use: no re-draw until Use is let go
	int   mCatchGrace[MAXPLAYERS];	// tics after a catch before the grip is read again
	int   mDrawGrace[MAXPLAYERS];	// tics after a draw before an empty off hand counts as eviction
	int   mStartDrawn[MAXPLAYERS];	// countdown to the draw at spawn (ssq_start_drawn)
	bool  mInZone[MAXPLAYERS];		// kept for the debug line; the zone-hides-the-gun pass was retired
	// THE LOCK-ON YOU SEE. While the shield is held, a cone from where the off hand points picks
	// the targets every tic; a ring hangs over each, biggest over the first the disc will visit.
	// Let go and this list is what flies, in this order.
	Array<Actor> mLocks[MAXPLAYERS];
	Array<Actor> mLockMarks[MAXPLAYERS];
	Array<int>   mLockMiss[MAXPLAYERS];	// tics each lock has been out of the keep cone or out of sight
	int   mLastPaint[MAXPLAYERS];	// the tic the last target was painted: they go on one at a time
	int   mKeepMarks[MAXPLAYERS];	// let go for less than this long and your marks are still there
	bool  mLockKey[MAXPLAYERS];	// the ShieldSaw Lock key is down (netevent ssq-lock, ssq_lock_input 1)
	bool  mLockWas[MAXPLAYERS];	// the lock input last tic
	bool  mMigrated;
	SSQ_ScoreMemory score;		// what a scorer may ask about blocks and turned shots (score.zs)
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
	// ON YOUR BACK (owner 2026-10-31, ssq_mount_spot): 1 the handle low at the small of your back, reached behind your
	// waist (clear of RSQ TacticalRig's hips, 0.30 m away); 2 behind your neck, at the top of the back between the rig's
	// two shoulder holsters (0.21 m from each, a small grab); 3 either. 0 is the old mount over the off shoulder.
	// On the back the rig keeps its off-shoulder holster.
	static clearscope int Spot(PlayerInfo p) { return clamp(UVI(p, 'ssq_mount_spot', 1), 0, 3); }
	static clearscope bool OnBack(PlayerInfo p) { int s = Spot(p); return s == 1 || s == 3; }   // the handle low
	static clearscope Vector3 NeckPos(PlayerPawn mo)
	{
		let p = mo.player;
		double a = mo.angle;
		return mo.pos + (cos(a), sin(a), 0) * CM(UV(p, 'ssq_neck_fwd', -12.0)) + (0, 0, p.viewz - mo.pos.z + CM(UV(p, 'ssq_neck_up', -20.0)));
	}
	// how far the hand is from where the shield is taken, in the units Reach() is in: with both back spots, the nearer
	// one (the neck's smaller reach scaled up to match)
	static clearscope double MountDist(PlayerPawn mo, Vector3 hand)
	{
		let p = mo.player;
		double d = (hand - MountPos(mo)).Length();
		if (Spot(p) != 3) return d;
		double nr = max(0.01, CM(UV(p, 'ssq_neck_reach', 6.0)));
		return min(d, (hand - NeckPos(mo)).Length() * Reach(p) / nr);
	}

	static clearscope Vector3 MountPos(PlayerPawn mo)
	{
		let p = mo.player;
		if (Spot(p) == 2) return NeckPos(mo);
		bool back = OnBack(p);
		double side = back ? 0.0 : CM(UV(p, 'ssq_mount_side', 12.0)) * (LeftHanded(p) ? -1 : 1);
		double fwd = back ? CM(UV(p, 'ssq_back_fwd', -25.0)) : CM(UV(p, 'ssq_mount_fwd', -27.0));
		double up = back ? CM(UV(p, 'ssq_back_up', -50.0)) : CM(UV(p, 'ssq_mount_up', -30.0));
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
		// on the back the handle is LOW and the disc hangs above it: the forearm axis points down
		Vector3 Fh = OnBack(mo.player) ? (0, 0, -1) : (0, 0, 1);
		Vector3 Lh = (cos(a), sin(a), 0);			// forward
		Vector3 Uh = Fh cross Lh;					// the player's left (shoulder) or right (back)
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
	// RSQ_Hands re-gives itself whenever the slot is null, and RSQ_Saber's bridge
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
	// The off hand's fist: the pack's empty hands (Brutal Doom Quest's RSQ_Hands), found by name.
	static clearscope Weapon FistBack(PlayerPawn mo)
	{
		Name hn = 'RSQ_Hands';
		return Weapon(mo.FindInventory(hn));
	}

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
		int mode = SVI('ssq_lock_button', 2);
		if (mode == 0) return (b & BT_OFFHANDALTATTACK) != 0;
		if (mode == 2) return (b & BT_OFFHANDATTACK) != 0;
		return (b & (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK)) != 0;
	}

	// Server settings still at the OLD defaults move to the new ones (a saved cvar outlives a
	// changed default): locks dropped 0.4 s out of view (14 tics) and the rings 1 s after letting
	// go (35); either off button threw. Now 3 s, 5 s, and the trigger.
	void MigrateLocks()
	{
		let g = CVar.FindCVar('ssq_lock_grace');
		if (g && g.GetInt() == 14) g.SetInt(105);
		let k = CVar.FindCVar('ssq_keep_marks');
		if (k && k.GetInt() == 35) k.SetInt(175);
		let b = CVar.FindCVar('ssq_lock_button');
		if (b && b.GetInt() == 1) b.SetInt(2);
	}

	// THE LOCK INPUT, ITS OWN BUTTON (the owner, 10-27: "hold trigger to rev AND lock on? ... the
	// lock on fades off after a few tics so I still can't hit shit"). Holding the trigger used to
	// rev, paint and throw at once. Now the trigger revs (and throws on release), and locking is
	// a separate hold, picked per player in ssq_lock_input:
	//   0  Use, held away from the shoulder mount (no binding needed)        <- default
	//   1  the "ShieldSaw: lock on (hold)" key -- bind the off grip or any key to it
	//   2  the old way: the throw button paints too
	bool LockHeld(int i)
	{
		let p = players[i];
		int mode = UVI(p, 'ssq_lock_input', 0);
		if (mode == 1) return mLockKey[i];
		if (mode == 2) return SecHeld(p);
		if ((p.cmd.buttons & BT_USE) == 0) return false;
		// Use at the mount is the draw / holster, not a lock
		let pose = mPose[i];
		if (!pose.Fresh(Level.maptime)) return true;
		return MountDist(p.mo, pose.pos[0]) > Reach(p);
	}

	static clearscope double Reach(PlayerInfo p)
	{
		int s = Spot(p);
		if (s == 2) return CM(UV(p, 'ssq_neck_reach', 6.0));
		return s ? CM(UV(p, 'ssq_back_reach', 10.0)) : CM(UV(p, 'ssq_mount_reach', 30.0));
	}
	// THE ZONE over the shoulder: larger than the grab reach, so the hand is inside it for tics
	// before the finger can be at the grab point
	// RSQ_Accessibility's Gesture Ease: the shoulder's zone x1..x2. 0 / absent: as set.
	static clearscope double Zone(PlayerInfo p) { return SSQ_A11y.Wide(Reach(p) * SV('ssq_zone_scale', 1.6)); }

	// ---- lifecycle ----------------------------------------------------------------
	override void OnRegister()
	{
		for (int i = 0; i < MAXPLAYERS; i++) mPose[i] = new('SSQ_Pose');
		Migrate();
	}

	// SETTINGS GENERATIONS, each once (ssq_cfgver; FindCVar, the values the config saves).
	// 1 (2026-10-31, owner: "tighten up the block to plate size"): the guard margin, the slab's depth and the early
	// turn come down to the plate itself, from whatever an older config saved.
	static void Migrate()
	{
		let ver = CVar.FindCVar('ssq_cfgver');
		if (!ver || ver.GetInt() >= 1) return;
		let pad = CVar.FindCVar('ssq_sweep_pad'); if (pad) pad.SetFloat(0.0);
		let th = CVar.FindCVar('ssq_plate_thick'); if (th) th.SetFloat(4.0);
		let ld = CVar.FindCVar('ssq_sweep_lead'); if (ld) ld.SetFloat(1.0);
		ver.SetInt(1);
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

	// THE MISSILES IN FLIGHT, for the sweep. A projectile is +NOBLOCKMAP (the PROJECTILE combo), so a
	// BlockThingsIterator never returns one -- measured on QZD 17.3: an imp ball crossing the plate
	// was absent from the iterator around it, and the sweep (SSQ_Guard.DoEffect) had never turned a
	// single shot; only the block on contact ever did. So every missile is noted as it spawns and the
	// sweep walks this list instead (pruned each tic; a few dozen entries in a firefight).
	Array<Actor> mMissiles;
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (a && a.bMissile && !(a is 'SSQ_Disc')) mMissiles.Push(a);
	}
	void PruneMissiles()
	{
		for (int k = mMissiles.Size() - 1; k >= 0; k--)
		{
			let a = mMissiles[k];
			if (!a || !a.bMissile) mMissiles.Delete(k);
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		mMissiles.Clear();
		for (int i = 0; i < MAXPLAYERS; i++) { mProp[i] = null; mMarker[i] = null; mDisc[i] = null; }
	}

	// ---- the sim, once a tic, every machine ------------------------------------------
	override void WorldTick()
	{
		if (!mMigrated) { mMigrated = true; MigrateLocks(); }
		if (!score) score = new('SSQ_ScoreMemory');
		PruneMissiles();
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
			// THE TRIGGER: held revs; let go with a forward flick throws (to the locks, or where
			// you point); press again in flight to recall. Locking is its own input (LockHeld).
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
					ps.pos[0].x, ps.pos[0].y, ps.pos[0].z, C.x, C.y, C.z, n.x, n.y, n.z, SSQ_Guard.PlateRadius(false, SSQ_Guard.GrowFor(mo)), ps.Fresh(Level.maptime));
			}
			LocksTick(i);
			Props(i);
		}
	}

	// USE in the zone: holstered -> draw; drawn -> holster
	void OnPress(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool fresh = pose.Fresh(Level.maptime);
		double dist = fresh ? MountDist(mo, pose.pos[0]) : 1e9;
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
		// the key route (ssq_shoulder_use off): the shoulder is not a grab, only the Draw key
		if (UVI(p, 'ssq_shoulder_use', 1) == 0) return;
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
		double fwdmin = SSQ_A11y.Low(SV('ssq_throw_forward', 0.35));   // Gesture Ease: x1..x0.5
		bool forward = true;
		if (fwdmin > 0 && speed > 0)
		{
			Vector3 look = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
			forward = (hv.Unit() dot look) >= fwdmin;
		}
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: release p%d speed %.0f/s, %d locked, forward %d", i, speed, mLocks[i].Size(), forward);
		if (speed >= SSQ_A11y.Low(SV('ssq_throw_min', 60.0)) && forward) Throw(i);
		else mKeepMarks[i] = max(mKeepMarks[i], Level.maptime + SVI('ssq_keep_marks', 175));	// not a throw: hold the marks
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
		// Only a hand that actually LOST the shield is put back. A raise merely ASKED FOR while
		// the shield is still in the hand is cancelled below, not answered with a re-raise:
		// with BD22Q loaded the off trigger asks for its hands weapon every tic, and re-raising
		// the shield ran its Select every tic, which zeroed the rev -- it never wound up, so the
		// blades never deployed (the owner's headset, 10-27: "the animations are gone").
		if (p.OffhandWeapon != saw) fix = true;
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
		bool aiming = LockHeld(i);
		// let go of the lock: the rings stay ssq_keep_marks tics (5 s), long enough to rev and throw
		if (!aiming && mLockWas[i]) mKeepMarks[i] = Level.maptime + SVI('ssq_keep_marks', 175);
		mLockWas[i] = aiming;
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

		// LOCKSTEP (Gun Bonsai VR patch, asked by name): one more lock a level
		int want = SVI('ssq_locks', 5) + SSQ_Upg.Lv(mo.FindInventory('SSQ_ShieldSaw'), "Lockstep");
		int grace = SVI('ssq_lock_grace', 105);
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
			// High contrast (rsqa_colorblind 4): every mark fully lit and a fifth larger, the first
			// breathing twice as deep -- the gold art carries no meaning of its own, rank is size.
			bool hc = SSQ_CB.Mode() == 4;
			double pulse = 1.0 + (hc && k == 0 ? 0.24 : 0.12) * sin(Level.maptime * 9.0 + k * 40);
			if (hc) pulse *= 1.2;
			m.bInvisible = false;
			m.SetOrigin(t.pos + (0, 0, t.height + 12), true);
			// around the actor's own 0.35, not around 1: the one the disc visits first is a
			// little under twice the others, which is plenty to read at range without
			// magnifying a 48-pixel picture into a dinner plate.
			m.A_SetScale(0.35 * (k == 0 ? 1.8 : (k == 1 ? 1.3 : 1.0)) * pulse * SV('ssq_lock_mark_scale', 1.0) * SSQ_A11y.Cue());   // Cue Size
			m.A_SetRenderStyle((k == 0 || hc) ? 1.0 : 0.85, STYLE_Add);
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
		// NOT INTO A TWO-HANDED MAIN: BringUpWeapon nulls a two-handed ReadyWeapon whenever an
		// off-hand weapon comes up (player.zs), which would empty the hand just restored above.
		if (p.PendingWeapon == WP_NOCHANGE && !(p.ReadyWeapon && p.ReadyWeapon.bTwoHanded))
		{
			Weapon back = mPrevOff[i] ? Weapon(mo.FindInventory(mPrevOff[i])) : null;
			if (!back) back = mFistNext[i] ? FistBack(mo) : HandBack(mo);
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
		// ON MANUAL STORE (ssq_store_to, the owner, 10-27): 0 the off hand goes back to its fist
		// (the pack's empty hand, so reloading works at once), 1 to the weapon it held before the
		// shield came out.
		let st = CVar.FindCVar('ssq_store_to');
		if (!st || st.GetInt() == 0) { mPrevOff[i] = null; mFistNext[i] = true; }
		Unstow(i);
		mFistNext[i] = false;
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
		d.Claim(saw);
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
		if (UVI(p, 'ssq_shoulder_use', 1) == 0) show = false;   // nothing to reach for on the key route
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
			prop.pitch = (OnBack(p) ? -MountPropPitch() : MountPropPitch()) + UV(p, 'ssq_mount_pitch', 0);
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
			// AND THE GRAB IS NOT A PREFERENCE. hw == 0 is "never draw the world copy", which is
			// a choice about what you and others see while the shield is in a normal grip -- but
			// the grab is not a matter of taste: the engine draws NO off-hand psprite at all
			// while it is held (hw_weapon.cpp:832-835 and :916-919, both keyed on the global
			// weaponStabilised that also raises WF_TWOHANDSTABILIZED at p_pspr.cpp:512-515), and
			// script cannot prevent it. So `hw != 0 && grabbed` meant a player who had turned the
			// world copy off in the options menu lost the shield out of his own hand the instant
			// the grip latched -- the exact failure this clause exists to prevent, with the
			// setting that reopens it one menu line away. The stand-in is unconditional now;
			// hw still decides the ordinary, ungrabbed case.
			bool want = hw == 1 || (hw == 2 && multiplayer) || grabbed;
			prop.bInvisible = !want || !pose.Fresh(Level.maptime);
			if (!prop.bInvisible)
			{
				// THE PROP'S ORIGIN IS THE GRIP, not the disc. shield.md3's origin sits in the
				// hand (hand_ssq straddles it, the handle bar is 1.3 cm off it) and the world
				// block carries no Offset, so the actor goes AT THE CONTROLLER and the mesh
				// puts the disc 15.4 cm back along the forearm by itself. Placing it at the
				// plate centre, as this did, pushed the drawn shield a whole radius off the
				// hand -- the guard was right and the picture was not.
				// AND IT CARRIES THE HELD OFFSETS. ModifyBobLayer3D adds ssq_held_x/y/z and
				// ssq_held_yaw/pitch/roll to the held layer every frame (shield.zs:176-177) --
				// the placement the owner dials in with the headset on -- and this prop, which
				// stands in for that layer whenever it is not drawn, was posed from the raw hand
				// with none of them. So on anyone who had touched those sliders the shield JUMPED
				// by the dialled-in offset the moment the two-hand grab started, and jumped back
				// on release. Same pose basis, same numbers.
				//
				// THE LAYER'S AXES, followed through stock QZD 17.3. The translation and the
				// three rotations are applied INSIDE the MODELDEF mesh scale (models.cpp
				// RenderHUDModel: the S(xscale,zscale,yscale) node, then T(pivot) . R(rotation.X
				// about Y) . R(rotation.Y about X) . R(rotation.Z about Z) . T(-pivot) .
				// T(translation)), and hw_vrmodes.cpp MapWeaponDir makes the layer frame
				// X = -L, Y = U, Z = -F -- which is why shield.zs packs the sliders as
				// (x, z, -y): x is the hand's right, y its forward, z its up.
				//
				// The held blocks of MODELDEF MIRROR the mesh for the other hand (SSQH is
				// Scale -1 1 1, SSQJ is Scale 1 1 1), and the nodes above sit inside that scale,
				// so the mirror conjugates them: the lateral slide and the rotations about Y and
				// Z change sign with the hand, the rotation about X does not. SSQ_Guard.Side() is
				// already exactly that sign (+1 when the off hand is the left controller, which
				// is the mirrored SSQH block), which is why the plate measurement uses it too.
				// SSQ_Prop's own mesh is NOT mirrored (Scale 0.34 0.34 0.34), so what is applied
				// here is the effective, post-mirror motion. ssq_shield_scale does not scale it:
				// it swaps the held model for a larger one rather than scaling one (MODELDEF:143)
				// and the layer translation is in mesh units either way. The one term not
				// reproduced is the rotation pivot, which this mod never sets
				// (ModifyBobPivotLayer3D is not overridden).
				double hs = SSQ_Guard.Side(p);
				double ry1 = -UV(p, 'ssq_held_yaw', 0) * hs;	// about the hand's up
				double rp1 = UV(p, 'ssq_held_pitch', 0);		// about its lateral axis
				double rr1 = -UV(p, 'ssq_held_roll', 0) * hs;	// about its forward
				double c1 = cos(ry1), s1 = sin(ry1);
				double c2 = cos(rp1), s2 = sin(rp1);
				double c3 = cos(rr1), s3 = sin(rr1);
				// the hand's axes turned by those three, written out in the hand's own basis so
				// that no function has to hand a Vector3 back: pose.zs:29-31 and guard.zs:136
				// both record that this VM drops those.
				Vector3 hF = pose.F * (c1 * c2) + pose.L * (s1 * c2) + pose.U * s2;
				Vector3 hL = pose.F * (-s1 * c3 + c1 * s2 * s3) + pose.L * (c1 * c3 + s1 * s2 * s3) + pose.U * (-c2 * s3);
				Vector3 hU = pose.F * (-s1 * s3 - c1 * s2 * c3) + pose.L * (c1 * s3 - s1 * s2 * c3) + pose.U * (c2 * c3);
				// and the slide, along the TURNED axes, because the layer's translation node sits
				// inside its rotation node (so the layer's own offset is rotated with it)
				Vector3 hoff = hF * CM(UV(p, 'ssq_held_y', 0))
					+ hL * (CM(UV(p, 'ssq_held_x', 0)) * hs)
					+ hU * CM(UV(p, 'ssq_held_z', 0));
				prop.SetOrigin(pose.pos[0] + hoff, true);
				prop.angle = atan2(hF.y, hF.x);
				prop.pitch = -asin(clamp(hF.z, -1, 1));
				prop.roll = SSQ_Hand.RollOf(hF, hL);
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
		else if (e.Name == "ssq-lock")
		{
			// RSQ_Accessibility's Hold to Toggle: a press latches the lock key, the next lets it go
			if (SSQ_A11y.HoldToggle()) { if (e.Args[0]) mLockKey[i] = !mLockKey[i]; }
			else mLockKey[i] = e.Args[0] != 0;
		}
		else if (e.Name == "ssq-throw")
		{
			// throw along the aim, for a player with no hand motion to read
			if (mState[i] == SS_DRAWN) ThrowAlongAim(i);
		}
		else if (e.Name == "rsqa_alt" && e.Args[0] == 6 && e.Args[1] && SSQ_A11y.OneHand())
		{
			// RSQ_Accessibility's Shield Throw gesture button (One-Handed): the forward flick's throw --
			// to the ringed targets when there are any, else along the aim
			if (mState[i] == SS_DRAWN) { if (mLocks[i].Size() > 0) Throw(i); else ThrowAlongAim(i); }
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
		d.Claim(saw);
		d.LaunchAlong(mo, dir, SV('ssq_speed_floor', 12.0) * 3.0, 90, rev);	// flat, like a frisbee
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
		// RSQ_Accessibility's Off-Hand Modifier (One-Handed): while it is held and the shield is on the
		// shoulder, the MAIN hand is the one that reaches for it (Use at the off shoulder draws, as ever).
		// Drawn, the plate is where the engine draws the off weapon: on the off controller.
		bool swapped = st == SS_STOWED && SSQ_A11y.Swapped(mo);
		if (swapped) hand = mo.AttackPos;
		bool nearMount = MountDist(mo, hand) <= Zone(p) * 1.5;
		bool want = st != SS_STOWED || grip || nearMount;
		if (!want) return;
		Vector3 F = swapped ? SSQ_Hand.MainDir(mo, 0, 0) : SSQ_Hand.OffDir(mo, 0, 0);
		Vector3 L = swapped ? SSQ_Hand.MainDir(mo, 90, 0) : SSQ_Hand.OffDir(mo, 90, 0);
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		double roll = SSQ_Hand.RollOf(F, L);
		EventHandler.SendNetworkEvent("ssq-pose", SSQ_Hand.PackPos(hand - mo.pos), SSQ_Hand.PackAng(yaw, pitch, roll, grip), LocalLeftHanded() ? 1 : 0);
	}

}
