// RS_ShieldSawQ -- the three states, the loadout swap, and the input.
//
// 2026-11-27 (owner: "the saw is a weapon we start with available in the wheel. it lives in the offhand. it gets there
// with a button press. we can optionally mount it on the offhand shoulder ... it does not live anywhere by default"):
//   STOWED   away: not in a hand and not on the body. MOUNTED (assigned to RSQ Tactical Rig's off shoulder holster from
//            RSQ Wheel's holster assignment screen; asked by name, MountTick) it hangs on that shoulder (a world prop).
//   DRAWN    in your off hand: SSQ_ShieldSaw is the off-hand weapon
//   FLYING   thrown. Your previous off-hand weapon is already back, so you are never
//            empty-handed. The disc comes home along the way it went; a hand near it on the
//            way back catches it (DRAWN), otherwise it goes to the shoulder (mounted) or away (STOWED).
//
// THE INPUT (owner 2026-11-27: "ONE BUTTON TO PUT SAW IN OFFHAND OR SWAP FOR PREVIOUS WEAPON. MAINHAND FIRE TO PAINT
// TARGET, FLICK TO THROW, HARDER THROW TO THROW HARDER AND MORE DAMAGE. OFFHAND FIRE REV / UNLOCK TARGET."):
//   the key (ssq_draw, netevent ssq-draw)             -> away: into the off hand. In the off hand: away, and the off
//                                                        hand gets the weapon it held before. In flight: it comes home
//   MAIN hand primary fire held, saw in the off hand  -> rings over what the MAIN hand aims at (LocksTick; the gun fires too)
//   OFF hand primary fire held                        -> the saw revs (shield.zs)
//   OFF hand primary fire pressed                     -> every ring is cleared
//   a forward swing of the off arm at Throw Speed     -> throw, at the ringed targets in order, else along the swing
//                                                        (FlickTick; no button)
//   hand near the returning disc (Catch on Return)    -> caught
// The decision runs here, in WorldTick, from the SYNCED pose (pose.zs).

class SSQ_Handler : EventHandler
{
	enum EState { SS_STOWED = 0, SS_DRAWN, SS_FLYING }

	int   mState[MAXPLAYERS];
	SSQ_Pose mPose[MAXPLAYERS];
	Actor mProp[MAXPLAYERS];		// the shield as a world actor: on the shoulder (mounted), or in the hand for others
	Actor mDisc[MAXPLAYERS];
	class<Weapon> mPrevOff[MAXPLAYERS];	// what the draw displaced (null: nothing, or the pack's hands)
	transient int a11yFlash;	// the last block star / bloom's tic (Photosensitive Mode, SSQ_FX.FlashOk)
	class<Weapon> mPrevMain[MAXPLAYERS];	// the main-hand weapon a two-handed conflict lowered
	bool  mGripWas[MAXPLAYERS];		// off primary fire last tic (its press clears the rings, 2026-11-27)
	// 2026-11-27 (owner: "FLICK TO THROW"; "there should not be a throw button"): no throw for the first tics after the saw
	// comes into the hand (Draw), and the tic a forward swing was seen (maptime + 1; 0 none): it throws the tic after,
	// unless the bash took it (FlickTick)
	int   mThrowHold[MAXPLAYERS];
	int   mFlickTic[MAXPLAYERS];
	// 2026-11-27 (owner: "MAINHAND FIRE TO PAINT TARGET"): where the MAIN hand is and points, as the player's own machine
	// last said (netevent ssq-aim, SendAim), and when (maptime + 1; 0 never)
	Vector3 mMainFrom[MAXPLAYERS], mMainAim[MAXPLAYERS];
	int   mMainTic[MAXPLAYERS];
	// 2026-11-27 (owner: "we can optionally mount it on the offhand shoulder"): mounted on RSQ Tactical Rig's off shoulder
	// holster, and where that is (MountTick, asked by name every tic)
	bool  mMounted[MAXPLAYERS];
	Vector3 mMountAt[MAXPLAYERS];
	int   mDrawGrace[MAXPLAYERS];	// tics after a draw before an empty off hand counts as eviction
	int   mCycleTic[MAXPLAYERS];	// the last Next / Prev Offhand Weapon press (ssq_offhand_cycle), gametic + 1; 0 none
	int   mStartDrawn[MAXPLAYERS];	// countdown to the draw at spawn (ssq_start_drawn)
	// THE LOCK-ON YOU SEE. While the shield is held, a cone from where the off hand points picks
	// the targets every tic; a ring hangs over each, biggest over the first the disc will visit.
	// Let go and this list is what flies, in this order.
	Array<Actor> mLocks[MAXPLAYERS];
	Array<Actor> mLockMarks[MAXPLAYERS];
	Array<int>   mLockMiss[MAXPLAYERS];	// tics each lock has been out of the keep cone or out of sight
	int   mLastPaint[MAXPLAYERS];	// the tic the last target was painted: they go on one at a time
	int   mKeepMarks[MAXPLAYERS];	// let go for less than this long and your marks are still there
	bool  mLockWas[MAXPLAYERS];	// the lock input last tic
	SSQ_ScoreMemory score;		// what a scorer may ask about blocks and turned shots (score.zs)
	// SABER OVER SHIELD (pick 15): the stance, as the player's own machine last said (netevent ssq-brace)
	bool  mBraced[MAXPLAYERS];
	int   mSpartan[MAXPLAYERS];	// SPARTAN (Gun Bonsai VR patch): each player's level, kept for SSQ_Guard.Spartan (clearscope)
	transient int mBraceSent;	// this machine's last sent value + 1 (0 = nothing sent yet)
	// THE BODY THE MOUNTED SAW FACES WITH (owner's headset, 11-02: "attached to helmet and not body"): the body's yaw,
	// synced from each player's own machine (netevent ssq-body, BodyKeep). Until one arrives (or off VR): the
	// pawn's angle, as before. (2026-11-27: its height, the standing eyes, went with the spots on the body.)
	double mBodyYaw[MAXPLAYERS];
	bool   mBodyHave[MAXPLAYERS];
	// ...and the keeper on this machine, for its own console player only (re-primed from mBodyYaw on load)
	transient double kYaw, kLastA, kLastH0, kLastH1, kSentYaw;
	transient SSQ_TurnKeeper kTurns;	// the body's turns with the tracking space (turnkeep.zs)
	transient bool kPrimed, kSent;
	// (2026-11-27: the chest gesture and the recenter command are gone with the spot on the body; these two stay declared
	// for TacticalRig/tools/rigtest/turnprobe, which reads them: kRecentered counts the keeper's own starts, kRecGap is 0)
	transient int kRecentered;
	transient double kRecGap[2];
	transient Actor kMo;
	// WALL SLAM (pick 12): bodies a bash threw, watched for the wall that stops them
	Array<Actor>  mSlamWho;
	Array<int>    mSlamBy, mSlamUntil;
	Array<double> mSlamVX, mSlamVY;


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
	double mSizeK[MAXPLAYERS];	// SHIELD SIZE: each player's scale from the patch (1 without it)
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

	// ---- the body the mounted saw faces with ------------------------------------------------
	// 2026-11-27 (owner: "it does not live anywhere by default"; "we can optionally mount it on the offhand shoulder. when
	// doing so, it takes the left shoulder slot"): ShieldSaw has no spot of its own on the body any more (the lower back,
	// the neck, the shoulder, their grab with Use, their marker, the chest gesture and the recenter command are gone).
	// MOUNTED, the saw away hangs at RSQ Tactical Rig's off shoulder holster (MountTick asks the Rig by name), and faces
	// with the body:
	//   YAW   the body's (BodyKeep below): the Rig's own body when it answers and Turn With the Rig is on (ssq_rig_body),
	//         else the keeper copied from the Rig (turnkeep.zs: snap and smooth turns turn it, a head turn does not).
	// Off VR the body is the pawn.
	static clearscope double BodyYaw(PlayerPawn mo)
	{
		let h = Get();
		int n = mo.PlayerNumber();
		if (h && n >= 0 && n < MAXPLAYERS && h.mBodyHave[n]) return h.mBodyYaw[n];
		return mo.angle;
	}

	// THE BODY KEEPER: this machine's console player only (the controller yaws are written for the camera player
	// alone), sent to every machine as netevent ssq-body so every sim turns the mounted saw the same way.
	void BodyKeep()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || !SSQ_Hand.InVR(mo)) return;
		double a = mo.angle, h0 = mo.AttackAngle, h1 = mo.OffhandAngle;
		// ON THE RIG'S BODY (ssq_rig_body, on; 11-03): with RSQ TacticalRig loaded the shield hangs on the rig's own body
		// (asked by name, RSQTR_BodyService "body.yaw"), so the shield and the holsters turn together, every snap and
		// every smooth turn, and never apart. Without the rig (or the row off) the keeper below, the rig's rule copied.
		double rigYaw = 999;
		if (UVI(p, 'ssq_rig_body', 1) != 0)
		{
			let it = ServiceIterator.Find('RSQTR_BodyService');
			Service sv;
			while (sv = it.Next()) { rigYaw = sv.GetDouble('body.yaw', '', 0, 0, mo); if (rigYaw != 999) break; }
		}
		if (rigYaw != 999)
		{
			kYaw = Actor.Normalize180(rigYaw);
			kPrimed = false;	// the keeper starts again from here if the rig's body stops answering
			kMo = mo;	// (and then faces the head, as after a recenter)
		}
		else if (!kPrimed || kMo != mo)
		{
			// map start, a level change, a loaded save (the keeper is transient) and a new pawn (respawn) start the body
			// facing where the head faces
			kYaw = a;
			kRecentered++;
			kLastA = a; kLastH0 = h0; kLastH1 = h1;
			if (!kTurns) kTurns = new('SSQ_TurnKeeper');
			kTurns.Prime(a, h0, h1);
			kPrimed = true; kMo = mo;
			kSent = false;
		}
		else
		{
			// THE TRACKING SPACE TURNED (snap, smooth, a teleport's facing): SSQ_TurnKeeper, the rig's rule (11-03). The
			// controller yaws reach the script 0, 1 or 2 tics after the pawn's angle (measured on the rig).
			if (!kTurns) { kTurns = new('SSQ_TurnKeeper'); kTurns.Prime(kLastA, kLastH0, kLastH1); }
			let sn = CVar.FindCVar('vr_snapTurn');
			kYaw += kTurns.Step(a, h0, h1, mo.AttackPitch, mo.OffhandPitch, Level.maptime, sn ? sn.GetFloat() : 45.0);
			kLastA = a; kLastH0 = h0; kLastH1 = h1;
			// 2026-11-27 (owner: "it does not live anywhere by default"): Body Turns With Hands and Body Catches Up are gone
			// (they only moved the spot on the body); the keeper's own bookkeeping for them is kept in step, never allowed
			kYaw += kTurns.With(kYaw, a, h0, h1, mo.AttackPitch, mo.OffhandPitch, false);
			kYaw = Actor.Normalize180(kYaw);
		}
		if (kSent && abs(Actor.DeltaAngle(kSentYaw, kYaw)) < 0.25) return;
		kSent = true;
		kSentYaw = kYaw;
		// args: the body's yaw in hundredths of a degree
		EventHandler.SendNetworkEvent("ssq-body", int(round((kYaw % 360.0 + 360.0) % 360.0 * 100.0)));
	}

	// ---- THE MOUNT (2026-11-27, owner: "we can optionally mount it on the offhand shoulder. when doing so, it takes the
	// left shoulder slot"; "CAN BE ASSIGNED BUT ONLY TO OFFHAND SHOULDER") ------------------------------------------
	// Asked of RSQ Tactical Rig by name, every tic, for every player: RSQTR_RigService "rig.locked" for "SSQ_ShieldSaw"
	// gives the holster the saw is assigned to (-1: none, or no Rig: no mount), "region.x" / ".y" / ".z" where that
	// holster is. The assignment is made and cleared on RSQ Wheel's holster assignment screen and kept by the Rig.
	void MountTick(int i, PlayerPawn mo)
	{
		mMounted[i] = false;
		let it = ServiceIterator.Find("RSQTR_RigService");
		Service sv;
		while (sv = it.Next())
		{
			int r = sv.GetInt("rig.locked", "SSQ_ShieldSaw", 0, 0, mo);
			if (r < 0) continue;
			double x = sv.GetDouble("region.x", "", r, 0, mo), y = sv.GetDouble("region.y", "", r, 0, mo), z = sv.GetDouble("region.z", "", r, 0, mo);
			if (x > 9e8 || y > 9e8 || z > 9e8) continue;	// the Rig cannot say where (it is switched off)
			mMountAt[i] = (x, y, z);
			mMounted[i] = true;
			break;
		}
	}
	// where the mounted saw hangs (the Rig's off shoulder holster), and where the returning disc flies to when no hand
	// catches it (disc.zs). Not mounted there is no such place: the disc flies to the middle of the player and goes away
	// there (DiscHome)
	static clearscope Vector3 MountPos(PlayerPawn mo)
	{
		let h = Get();
		int n = mo.PlayerNumber();
		if (h && n >= 0 && n < MAXPLAYERS && h.mMounted[n]) return h.mMountAt[n];
		return mo.pos + (0, 0, mo.height * 0.5);
	}

	// THE HOLSTERED POSE, DERIVED FROM THE MESH, not from hand-set offsets.
	//
	// MountPos is the grab point: where the hand is when it reaches over the shoulder (2026-11-27: the Rig's holster).
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
		double a = BodyYaw(mo);	// the body's facing, not the head's
		Vector3 Fh = (0, 0, 1);	// (2026-11-27: the lower back spot, handle low, is gone; the shoulder's pose is the one left)
		Vector3 Lh = (cos(a), sin(a), 0);			// forward
		Vector3 Uh = Fh cross Lh;					// the player's left (shoulder) or right (back)
		double k = SSQ_Guard.Scale(mo.PlayerNumber());
		return MountPos(mo)
			+ Fh * (CM(SV('ssq_plate_f', -15.4)) * k)
			+ Lh * (CM(SV('ssq_plate_l', -7.5)) * k)
			+ Uh * (CM(SV('ssq_plate_u', -5.0)) * k);
	}

	static clearscope Vector3 MountPlateNormal(PlayerPawn mo)
	{
		double a = BodyYaw(mo);
		return (-cos(a), -sin(a), 0);	// -Lh: behind you
	}

	// the prop's own angles for that frame. models.cpp RenderModel composes
	// rotate(-angle,Y) . rotate(-pitch,Z) . rotate(-roll,X) on a vertex swizzled to
	// (mx, mz, my), so model +x is the actor's forward and model +y its left, applied roll
	// first, then pitch, then yaw. The mesh's face normal is its y (shieldsaw.md3 is 8 units
	// thick in y and 58 across in x and z, measured), the handle on +y.
	// FLAT ON THE BACK (owner 2026-11-08: "flat along the back, face out like a plate on a
	// backpack", every spot): pitch -90 (shoulder, neck) or +90 (back) stands the forearm
	// axis up or down, and yaw -90 off the body turns the mesh's +y (handle side) FORWARD
	// into your back, so the outer face looks behind you and the disc lies in the back's
	// plane -- exactly MountPlateCentre/Normal's frame (Fh, Lh forward, Uh = Fh x Lh).
	// Until 11-08 this was yaw 0, roll 180, which put the mesh's +y to the body's RIGHT:
	// the disc stood edge-on off the back, a fin, while the guard plate faced behind.
	static clearscope double MountPropYaw() { return -90.0; }
	static clearscope double MountPropPitch() { return -90.0; }
	static clearscope double MountPropRoll() { return 0.0; }

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

	// the off-hand weapon another mod would hand back when we let go, if there is one: RSQ Saber's off blade, else the
	// pack's empty hands (Brutal Doom Quest's RSQ_Hands), found by name
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

	// 2026-11-27 (owner: "there should not be a throw button (maybe for rsq access)"; "OFFHAND REVS AND UNLOCKS"): the
	// Throw Button and Lock On With choices (SecHeld, LockHeld) and MigrateLocks are gone. The rings go on with the MAIN
	// hand's primary fire (LocksTick), the throw is the off arm's swing (FlickTick), and off primary fire revs
	// (shield.zs) and, on its press, clears the rings (WorldTick).

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
		if (!ver || ver.GetInt() >= 6) return;
		if (ver.GetInt() < 5)
		{
			MigrateTo4(ver);
			// 5 (2026-11-10, owner, design/KEYBINDS_PLAN.md): the Lock key is gone; locking is "hold the trigger", like the whip
			// and the saber: Lock On With moves to Hold the Trigger (2) whatever was saved (Use stays a choice on the menu)
			let li = CVar.FindCVar('ssq_lock_input'); if (li) li.SetInt(2);
			ver.SetInt(5);
		}
		// 6 (2026-11-22, owner: "all the throwing isn't smooth ... it takes too much effort"): the series' one throw feel
		// (pose.zs SSQ_Fling): Throw Hand Speed 2.5 -> 1.5 m/s, only off the old default (a value chosen is kept)
		let tm = CVar.FindCVar('ssq_throw_arm'); if (tm && abs(tm.GetFloat() - 2.5) < 0.001) tm.SetFloat(SSQ_Fling.MIN_MPS);
		ver.SetInt(6);
	}
	static void MigrateTo4(CVar ver)
	{
		if (ver.GetInt() >= 4) return;
		int from = ver.GetInt();
		// 4 (2026-11-03 18:56, "Stick turns + recenter"): the body never guesses a turn from the head or hands, so
		// "Body Turns With Head and Hands" goes off (it was on from 11-03 13:00) whatever was saved
		let bh = CVar.FindCVar('ssq_body_hands'); if (bh) bh.SetInt(0);
		if (from >= 3) { ver.SetInt(4); return; }
		if (from < 2)
		{
			// 2 (2026-10-31, owner: "it sends the projectile directly back to the attacker"): turned shots glance off the
			// plate and follow your swing, unless an older config chose something other than the old default
			let am = CVar.FindCVar('ssq_deflect_aim'); if (am && am.GetInt() == 1) am.SetInt(3);
			if (from < 1)
			{
				let pad = CVar.FindCVar('ssq_sweep_pad'); if (pad) pad.SetFloat(0.0);
				let th = CVar.FindCVar('ssq_plate_thick'); if (th) th.SetFloat(4.0);
				let ld = CVar.FindCVar('ssq_sweep_lead'); if (ld) ld.SetFloat(1.0);
			}
		}
		// 3 (2026-11-02, owner: "cannot reach small of back or neck"): the back spots are room centimetres on the body
		// now, with far larger grabs; whatever an older config saved under the old meaning goes back to the new defaults
		static const Name spots[] = { 'ssq_back_fwd', 'ssq_back_up', 'ssq_back_reach', 'ssq_neck_fwd', 'ssq_neck_up', 'ssq_neck_reach' };
		for (int k = 0; k < 6; k++) { let cv = CVar.FindCVar(spots[k]); if (cv) cv.ResetToDefault(); }
		ver.SetInt(4);
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
		for (int i = 0; i < MAXPLAYERS; i++) { mProp[i] = null; mDisc[i] = null; }
	}

	// ---- the sim, once a tic, every machine ------------------------------------------
	// THE MENU'S GUN BONSAI VR GATING (SSQ_ScoreService GetIntUI "menu.locked", score.zs): the console player's levels of
	// the upgrades that replace a row (0 BackPlate, 1 ShieldWall, 2 BashHitStop), asked once a second here in play. -1:
	// Gun Bonsai VR not loaded.
	transient int menuLv[3];
	transient int menuTic;
	void MenuRefresh()
	{
		if (menuTic > 0 && level.maptime >= menuTic && level.maptime < menuTic + 35) return;
		menuTic = max(level.maptime, 1);
		let mo = players[consoleplayer].mo;
		bool on = SSQ_Upg.On();
		let saw = mo ? mo.FindInventory('SSQ_ShieldSaw') : null;
		static const String U[] = { "BackPlate", "ShieldWall", "BashHitStop" };
		for (int i = 0; i < 3; i++) menuLv[i] = on ? SSQ_Upg.Lv(saw, U[i]) : -1;
	}

	override void WorldTick()
	{
		MenuRefresh();
		// SHIELD SIZE (Gun Bonsai VR patch): each player's shield scale, kept here for SSQ_Guard.Scale (clearscope)
		for (int sk = 0; sk < MAXPLAYERS; sk++)
		{
			bool here = playeringame[sk] && players[sk].mo;
			mSizeK[sk] = here ? SSQ_Guard.SizeFor(players[sk].mo) : 1.0;
			mSpartan[sk] = here ? SSQ_Upg.Lv(players[sk].mo.FindInventory('SSQ_ShieldSaw'), "Spartan") : 0;
		}
		if (!score) score = new('SSQ_ScoreMemory');
		PruneMissiles();
		BodyKeep();
		SendPose();
		SendAim();
		SendBrace();
		SlamTick();
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
			if (mState[i] != SS_DRAWN) mBraced[i] = false;
			MountTick(i, mo);

			// nothing but Draw() puts the shield in the hand: undo the engine filling an empty
			// off hand with it, or a level change re-raising it
			// ... unless the player cycled to it (Next / Prev Offhand Weapon, ssq_offhand_cycle): then it is drawn
			if (mState[i] == SS_STOWED && (p.OffhandWeapon == saw || p.PendingWeapon == saw) && CycledLately(i)) { mCycleTic[i] = 0; Draw(i); }
			if (mState[i] != SS_DRAWN && p.OffhandWeapon == saw) Unstow(i);
			// A WHEEL PICK IN THE OFF HAND IS THE PLAYER PUTTING THE SHIELD DOWN (owner 11-13: "when we have the shieldsaw in hand
			// i want to be able to select from the wheel with my offhand and have it equip, the saw is fighting me"): RSQ Wheel
			// put a weapon in the off hand in the last 2 tics (wr_RigService "offhand.pick", by name). The shield goes away
			// (to the shoulder when mounted) and the picked weapon stays, under either Off-Hand Switch setting.
			if (mState[i] == SS_DRAWN && p.OffhandWeapon && p.OffhandWeapon != saw && WheelPickedOff()) YieldToPick(i, saw);
			if (mState[i] == SS_DRAWN) { if (SVI('ssq_yield_offhand', 0) != 0) HoldOrYield(i, saw); else PinHands(i, saw); }
			if (mState[i] == SS_FLYING && !mDisc[i]) { mState[i] = SS_STOWED; }
			if (mStartDrawn[i] > 0 && mState[i] == SS_STOWED && --mStartDrawn[i] == 0) Draw(i);

			// 2026-11-27 (owner: "OFFHAND FIRE REV / UNLOCK TARGET"; "OFFHAND REVS AND UNLOCKS"): the PRESS of off primary
			// fire clears every ring (holding it revs: shield.zs). It rings nothing, letting it go throws nothing, and in
			// flight it does not recall: only the key does (owner: "if i want to recall shieldsaw, i press the bind").
			// Use is not read at all: no drawing or putting back at a spot on the body ("it does not live anywhere").
			bool off = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;
			if (off && !mGripWas[i] && mState[i] == SS_DRAWN && mLocks[i].Size() > 0)
			{
				if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d off primary fire pressed: %d rings cleared", i, mLocks[i].Size());
				ClearLocks(i);
			}
			mGripWas[i] = off;
			// FLICK TO THROW (owner 2026-11-27), no button
			if (mThrowHold[i] > 0) mThrowHold[i]--;
			FlickTick(i);

			if (mState[i] == SS_DRAWN && UVI(p, 'ssq_debug', 0) != 0 && (Level.maptime % 35) == 0)
			{
				let ps = mPose[i];
				Vector3 C = SSQ_Guard.PlateCentre(mo, ps, false);
				Vector3 n = SSQ_Guard.PlateNormal(mo, ps, false);
				Console.Printf("ssq: pose F(%.2f %.2f %.2f) L(%.2f %.2f %.2f) U(%.2f %.2f %.2f) hand(%.0f %.0f %.0f) C(%.0f %.0f %.0f) n(%.2f %.2f %.2f) R %.1f fresh %d",
					ps.F.x, ps.F.y, ps.F.z, ps.L.x, ps.L.y, ps.L.z, ps.U.x, ps.U.y, ps.U.z,
					ps.pos[0].x, ps.pos[0].y, ps.pos[0].z, C.x, C.y, C.z, n.x, n.y, n.z, SSQ_Guard.PlateRadius(false, SSQ_Guard.GrowFor(mo), mo.PlayerNumber()), ps.Fresh(Level.maptime));
			}
			LocksTick(i);
			Props(i);
		}
	}

	bool CycledLately(int i) { return mCycleTic[i] > 0 && gametic - mCycleTic[i] <= 20; }

	// NEXT / PREV OFFHAND WEAPON, as a key (ssq_offhand_cycle): a key whose binding is QuestZDoom's off-hand weapon cycle
	// ("weapnext 1" / "weapprev 1") going down sends one network event (the way RSQ Tactical Rig's cigarette reads the same
	// keys). The key is never eaten: the engine's own switch still runs.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown) return false;
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return false;
		if (UVI(players[consoleplayer], 'ssq_offhand_cycle', 0) == 0) return false;
		String b = Bindings.GetBinding(e.KeyScan);
		b = b.MakeLower();
		if (b.IndexOf("weapnext 1") >= 0) EventHandler.SendNetworkEvent("ssq-cycle", 1);
		else if (b.IndexOf("weapprev 1") >= 0) EventHandler.SendNetworkEvent("ssq-cycle", -1);
		return false;
	}

	// FLICK TO THROW, NO BUTTON (owner 2026-11-27: "FLICK TO THROW, HARDER THROW TO THROW HARDER AND MORE DAMAGE"; "there
	// should not be a throw button"). With the saw in the off hand, a forward swing of the off arm at Throw Speed
	// (ssq_throw_arm) or more throws it: at the ringed monsters in order when there are rings, else along the swing
	// (disc.zs Launch, its flight rules as they were). How hard the arm swings is the throw's bonus (disc.zs Launch).
	// It was the release of the throw button, and with rings on a slower swing toward the first ring; the button is gone
	// and one swing does for both.
	// SO IT DOES NOT FIRE BY ACCIDENT:
	//   - not in the first THROW_HOLD tics after the saw comes into the hand (Draw sets mThrowHold: the key, the Wheel,
	//     the shoulder, a catch), longer than the pose history the swing is read from;
	//   - A BASH IS A BASH: the swing seen this tic throws on the NEXT tic, and only if the bash did not take it. The
	//     bash runs after this in the same tic (guard.zs HeldTick, from the weapon's own tic) and starts its cooldown
	//     (bashCool) only when the shove landed on a body in reach; while that cooldown runs nothing is thrown.
	const THROW_HOLD = 10;
	void FlickTick(int i)
	{
		bool seen = mFlickTic[i] > 0 && Level.maptime - (mFlickTic[i] - 1) == 1;	// a swing was seen last tic
		mFlickTic[i] = 0;
		if (mState[i] != SS_DRAWN) return;
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		if (mThrowHold[i] > 0 || !pose.Fresh(Level.maptime)) return;
		let g = SSQ_Guard(mo.FindInventory('SSQ_Guard'));
		if (g && g.bashCool > 0)
		{
			if (seen && UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d the swing was a bash, not a throw", i);
			return;
		}
		if (seen) { Throw(i); return; }
		Vector3 hv = pose.ThrowVel(SSQ_Hand.PS(mo));
		double speed = hv.Length() * TICRATE;
		double ms = speed / max(SSQ_Hand.VU(), 1.0);   // ONE THROW: real m/s, against ssq_throw_arm like the series' others
		if (ms < SSQ_A11y.Low(SV('ssq_throw_arm', SSQ_Fling.MIN_MPS))) return;   // Gesture Ease: x1..x0.5
		// A THROW IS A FORWARD SNAP, NOT ANY FAST HAND. The end of a block, a backhand or a chop must not launch the
		// shield. The hand has to be going out the way you are looking -- ssq_throw_forward is the cosine
		// of how far off that it may be (0.35 is about 70 degrees). 0 takes any direction back.
		double fwdmin = SSQ_A11y.Low(SV('ssq_throw_forward', 0.35));   // Gesture Ease: x1..x0.5
		bool forward = true;
		if (fwdmin > 0 && speed > 0)
		{
			Vector3 look = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
			forward = (hv.Unit() dot look) >= fwdmin;
		}
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: swing p%d speed %.2f m/s, %d locked, forward %d", i, ms, mLocks[i].Size(), forward);
		if (forward) mFlickTic[i] = Level.maptime + 1;
	}

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
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d off hand taken -- the shield goes away", i);
		// the player has just arranged their own hands: forget what the draw displaced, so
		// Unstow does not hand it straight back and start the fight over.
		mPrevOff[i] = null; mPrevMain[i] = null;
		Stow(i, true);
	}
	static bool WheelPickedOff()
	{
		let it = ServiceIterator.Find("wr_RigService");
		Service sv;
		while (sv = it.Next())
		{
			int ago = sv.GetInt("offhand.pick");
			if (ago >= 0 && ago <= 2) return true;
		}
		return false;
	}

	// the Wheel's pick keeps the off hand; the shield only leaves (no slot handed back, unlike Stow / Unstow)
	void YieldToPick(int i, SSQ_ShieldSaw saw)
	{
		let p = players[i];
		if (p.PendingWeapon == saw) p.PendingWeapon = WP_NOCHANGE;
		saw.StopRev();
		ClearLocks(i);
		mPrevOff[i] = null; mPrevMain[i] = null;
		mState[i] = SS_STOWED;
		p.mo.A_StartSound("ssq/stow", CHAN_6);
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d the Wheel put %s in the off hand -- the shield goes away", i, p.OffhandWeapon.GetClassName());
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
		// 2026-11-27 (owner: "MAINHAND FIRE TO PAINT TARGET"): with the saw in the off hand, holding the MAIN hand's primary
		// fire rings targets, the one nearest the MAIN hand's aim line (mMainFrom / mMainAim: the player's own machine sends
		// them, SendAim). The button is only read, never taken: the main hand's gun fires as it always does. It was the off
		// hand's throw button (or Use), along the off hand's line.
		bool aiming = (p.cmd.buttons & BT_ATTACK) != 0 && mMainTic[i] > 0 && Level.maptime - (mMainTic[i] - 1) <= 3;
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

		// LOCKSTEP (Gun Bonsai VR patch, asked by name): the same count the throw uses
		int want = SSQ_Disc.WantLocks(mo);
		int grace = SVI('ssq_lock_grace', 105);
		while (mLockMiss[i].Size() < mLocks[i].Size()) mLockMiss[i].Push(0);

		// hold what is already locked
		for (int k = mLocks[i].Size() - 1; k >= 0; k--)
		{
			if (LockHolds(mo, mMainFrom[i], mMainAim[i], mLocks[i][k])) { mLockMiss[i][k] = 0; continue; }   // the main hand's aim (Steady Hands' when on)
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
			SSQ_Disc.FindTargets(mo, mMainFrom[i], mMainAim[i], fresh);   // the main hand's aim (Steady Hands' when on)
			for (int k = 0; k < fresh.Size(); k++)
			{
				let t = fresh[k];
				if (!t) continue;
				bool have = false;
				for (int j = 0; j < mLocks[i].Size(); j++) if (mLocks[i][j] == t) { have = true; break; }
				if (have) continue;
				mLocks[i].Push(t); mLockMiss[i].Push(0); added++;
				mLastPaint[i] = Level.maptime;
				break;		// the nearest to the main hand's line, and only that one, this time
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
			// breathing twice as deep -- rank is size, never colour.
			bool hc = SSQ_CB.Mode() == 4;
			double pulse = 1.0 + (hc && k == 0 ? 0.24 : 0.12) * sin(Level.maptime * 9.0 + k * 40);
			if (hc) pulse *= 1.2;
			m.bInvisible = false;
			m.SetOrigin(t.pos + (0, 0, t.height + 12), true);
			// around the actor's own 0.35, not around 1: the one the disc visits first is a
			// little under twice the others, which is plenty to read at range without
			// magnifying a 48-pixel picture into a dinner plate.
			m.A_SetScale(0.35 * (k == 0 ? 1.8 : (k == 1 ? 1.3 : 1.0)) * pulse * SV('ssq_lock_mark_scale', 1.0) * SSQ_A11y.Cue());   // Cue Size
			m.A_SetRenderStyle((k == 0 || hc) ? 1.0 : 0.85, STYLE_AddShaded);	// the ring; its centre copies the alpha
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
		mDrawGrace[i] = 8;	// the raise takes a few tics; do not read an empty slot as eviction
		mThrowHold[i] = THROW_HOLD;	// no flick throws it in its first tics in the hand (FlickTick, 2026-11-27)
		mFlickTic[i] = 0;
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
		// 2026-11-27 (owner: "ONE BUTTON TO PUT SAW IN OFFHAND OR SWAP FOR PREVIOUS WEAPON"): putting the saw away always
		// hands the off hand the weapon it held before the saw (Unstow). The On Manual Store choice (ssq_store_to: the
		// fist, or that weapon) is gone.
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
		Unstow(i);
		let d = SSQ_Disc(Actor.Spawn('SSQ_Disc', pose.pos[0]));
		if (!d) { mState[i] = SS_STOWED; ClearLocks(i); return; }
		d.Claim(saw);
		d.Launch(mo, pose);	// (2026-11-27: the rev no longer goes with it; the swing is the bonus, disc.zs Launch)
		ClearLocks(i);
		mDisc[i] = d;
		mState[i] = SS_FLYING;
		mo.A_StartSound("ssq/throw", CHAN_6);
		SSQ_FX.Buzz(mo, 0.8, 8);
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d THROW speed %.1f/tic swing bonus %.2f locks %d", i, d.vel.Length(), d.revFrac, d.locks.Size());
	}

	// the disc is home: caught (into the hand), or not: MOUNTED it goes to the shoulder, else it goes away (owner
	// 2026-11-27: "it does not live anywhere by default"). Both are SS_STOWED; Props draws it only when mounted.
	void DiscHome(int i, bool caught)
	{
		mDisc[i] = null;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i]) return;
		mState[i] = SS_STOWED;
		if (UVI(players[i], 'ssq_debug', 0)) Console.Printf("ssq: p%d disc home, %s", i, caught ? "CAUGHT" : (mMounted[i] ? "to the shoulder" : "away"));
		let mo = players[i].mo;
		if (!mo || mo.health <= 0) return;
		if (caught)
		{
			Draw(i);
			mo.A_StartSound("ssq/catch", CHAN_6);
			SSQ_FX.Buzz(mo, 1.0, 10);
		}
	}

	// ---- the world props -------------------------------------------------------------
	void HideProps(int i)
	{
		if (mProp[i]) mProp[i].bInvisible = true;
	}

	void Props(int i)
	{
		let p = players[i];
		let mo = p.mo;
		if (!mProp[i]) mProp[i] = Actor.Spawn('SSQ_Prop', mo.pos);
		let prop = mProp[i];
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		let pose = mPose[i];
		// (2026-11-27, owner: "it does not live anywhere by default": the mount's marker is gone with the grab it marked)

		// THE SHIELD YOU CAN SEE.
		//
		// Mounted and away, the prop IS the shield: it hangs at the grab point in the pose the guard
		// plate is computed for (MountPlateCentre/Normal), so what blocks and what is drawn
		// are the same object. The mesh origin is the grip, which is why the actor sits at
		// the grab point itself and the disc falls below it on its own -- no drop fudge.
		// Model +x is the actor's forward and +y its left (models.cpp RenderModel over the
		// (mx, mz, my) swizzle), so pitch -90 stands the forearm axis up and yaw -90 off the
		// body turns the plate's +L side -- the side your arm is on -- forward into your back:
		// flat on the back, face out (MountPropYaw, 11-08).
		if (mState[i] == SS_STOWED)
		{
			// SHOW SHIELDSAW (ssq_show, on; owner 11-04: "Always show ... saw. Toggle show ___ on/off in each mod's options"):
			// the stowed shield is drawn where it hangs. 2026-11-27 (owner: "it does not live anywhere by default"): that is
			// RSQ Tactical Rig's off shoulder holster, and only while the saw is mounted there (MountTick); not mounted, the
			// saw away is nowhere and nothing is drawn.
			prop.bInvisible = !mMounted[i] || UVI(p, 'ssq_show', 1) == 0;
			prop.SetOrigin(MountPos(mo), true);
			prop.angle = BodyYaw(mo) + MountPropYaw() + UV(p, 'ssq_back_yaw', 0);
			prop.pitch = MountPropPitch() + UV(p, 'ssq_back_pitch', 0);
			prop.roll  = MountPropRoll()  + UV(p, 'ssq_back_roll', 0);
			prop.A_SetScale(UV(p, 'ssq_mount_scale', 1.0) * SSQ_Guard.Scale(mo.PlayerNumber()));
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
				prop.A_SetScale(SSQ_Guard.Scale(p.mo.PlayerNumber()));	// the world copy grows with the plate
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
	// the live state in the corner, for a screenshot (Debug Log)
	override void RenderOverlay(RenderEvent e)
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		if (!p.mo || UVI(p, 'ssq_debug', 0) == 0 || menuactive != Menu.Off) return;   // the debug lines: not over a menu (owner 11-11)
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
		String line3 = String.Format("pose fresh %d  mounted %d  body yaw %.0f head %.0f", pose.Fresh(Level.maptime), mMounted[i], BodyYaw(p.mo), p.mo.angle);
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
			Vector3 bodyNow = SSQ_HandSync.Body(mo);	// the pawn's X/Y and the view's height (SSQ_HandSync)
			mPose[i].Push(bodyNow + SSQ_Hand.UnpackPos(e.Args[0]), bodyNow, mo.angle, yaw, pitch, roll, grip != 0, Level.maptime);
			mPose[i].left = (e.Args[2] & 1) != 0;
			// Args[2]: bit 0 left-handed; bits 1-20 the smoothed aim's yaw / pitch (10 bits each) with bit 21 saying it
			// is there (Steady Hands on at the sender); bits 22-29 were the sender's seat drop in cm (Seated Play), 0 since
			// 2026-11-27 (it lowered the spot on the body, which is gone)
			if ((e.Args[2] >> 21) & 1)
			{
				double ay = ((e.Args[2] >> 1) & 0x3FF) / 1023.0 * 360.0, ap = ((e.Args[2] >> 11) & 0x3FF) / 1023.0 * 180.0 - 90.0;
				mPose[i].A = (cos(ap) * cos(ay), cos(ap) * sin(ay), sin(ap));
			}
			mPose[i].seatCm = (e.Args[2] >> 22) & 0xFF;
		}
		else if (e.Name == "ssq-aim")
		{
			// 2026-11-27 (owner: "MAINHAND FIRE TO PAINT TARGET"): the MAIN hand's place and aim from the player's own
			// machine (SendAim), packed as the pose is
			double yaw, pitch, roll; int grip;
			[yaw, pitch, roll, grip] = SSQ_Hand.UnpackAng(e.Args[1]);
			mMainFrom[i] = SSQ_HandSync.Body(mo) + SSQ_Hand.UnpackPos(e.Args[0]);
			mMainAim[i] = (cos(pitch) * cos(yaw), cos(pitch) * sin(yaw), sin(pitch));
			mMainTic[i] = Level.maptime + 1;
		}
		else if (e.Name == "ssq-body")
		{
			// the body's yaw from the player's own machine (BodyKeep), in hundredths of a degree
			mBodyYaw[i] = Actor.Normalize180(e.Args[0] / 100.0);
			mBodyHave[i] = true;
		}
		else if (e.Name == "ssq-draw")
		{
			// THE ONE BUTTON (owner 2026-11-27: "ONE BUTTON TO PUT SAW IN OFFHAND OR SWAP FOR PREVIOUS WEAPON"; "if i want
			// to recall shieldsaw, i press the bind for 'shieldsaw'"): away, it comes into the off hand; in the off hand,
			// it goes away and the off hand gets the weapon it held before (Stow); in flight, it is called home. RSQ Wheel's
			// card and RSQ Tactical Rig's off shoulder grip (mounted) send this same event.
			if (mState[i] == SS_STOWED) Draw(i);
			else if (mState[i] == SS_DRAWN) Stow(i, true);
			else if (mDisc[i]) SSQ_Disc(mDisc[i]).Recall();
		}
		else if (e.Name == "ssq-cycle")
		{
			// NEXT / PREV OFFHAND WEAPON (ssq_offhand_cycle, off; owner, BUGS_1.0 item 17): the shield is one of the off
			// hand's weapons in the cycle (slot 1), as well as everything else that draws it. The engine's own switch for
			// the same key press arrives as its own command; this decides, from the engine's own pick (player.zs
			// PickNextWeapon / PickPrevWeapon, hand 1), whether the press lands on the shield or leaves it.
			if (UVI(players[i], 'ssq_offhand_cycle', 0) == 0) return;
			let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
			if (!saw) return;
			mCycleTic[i] = gametic + 1;
			if (mState[i] == SS_STOWED)
			{
				Weapon pick = e.Args[0] > 0 ? mo.PickNextWeapon(1) : mo.PickPrevWeapon(1);
				if (pick == saw || players[i].PendingWeapon == saw || players[i].OffhandWeapon == saw) { mCycleTic[i] = 0; Draw(i); }
				if (UVI(players[i], 'ssq_debug', 0)) { String pn = "nothing"; if (pick) pn = pick.GetClassName(); Console.Printf("ssq: p%d cycle %s while stowed: the pick is %s", i, e.Args[0] > 0 ? "next" : "prev", pn); }
			}
			else if (mState[i] == SS_DRAWN)
			{
				// the pick from the shield (it is the off hand's weapon now), then the shield goes away and the
				// pick comes up in the off hand
				Weapon pick = e.Args[0] > 0 ? mo.PickNextWeapon(1) : mo.PickPrevWeapon(1);
				if (!pick || pick == saw) return;
				mPrevOff[i] = pick.GetClass();
				Unstow(i);
				ClearLocks(i);
				mState[i] = SS_STOWED;
				mo.A_StartSound("ssq/stow", CHAN_6);
				if (UVI(players[i], 'ssq_debug', 0)) Console.Printf("ssq: p%d cycle %s while drawn: the shield goes away, %s to the off hand", i, e.Args[0] > 0 ? "next" : "prev", pick.GetClassName());
			}
		}
		else if (e.Name == "ssq-brace")
		{
			bool b = e.Args[0] != 0 && mState[i] == SS_DRAWN;
			if (b != mBraced[i] && UVI(players[i], 'ssq_debug', 0))
				Console.Printf("ssq: p%d saber over shield %s (block x%.2f)", i, b ? "ON" : "off", b ? clamp(SV('ssq_brace_widen', 1.3), 1.0, 2.0) : 1.0);
			mBraced[i] = b;
		}
		else if (e.Name == "rsqa_alt" && e.Args[0] == 6 && e.Args[1] && SSQ_A11y.OneHand())
		{
			// RSQ_Accessibility's Shield Throw gesture button (One-Handed): the forward flick's throw --
			// to the ringed targets when there are any, else along the aim. The one throw button left (owner 2026-11-27:
			// "there should not be a throw button (maybe for rsq access)"); the ssq_throw console command is gone.
			if (mState[i] == SS_DRAWN) { if (mLocks[i].Size() > 0) Throw(i); else ThrowAlongAim(i); }
		}
	}

	void ThrowAlongAim(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let saw = SSQ_ShieldSaw(mo.FindInventory('SSQ_ShieldSaw'));
		// 2026-11-27 (owner: "HARDER THROW TO THROW HARDER AND MORE DAMAGE"): the bonus is the arm's swing now, not the rev,
		// and this throw has no swing: none
		int rev = 0;
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

	// ---- WALL SLAM (owner's pick 12; Quest teardown surveys/01_MELEE.md 4.7) -----------------------
	// A bashed body is watched for 12 tics (longer while a hit-stop holds it). The engine stops a monster
	// that walks into a wall dead: P_XYMovement zeroes its XY velocity and leaves the line in
	// MovementBlockingLine (p_mobj.cpp:2231, :2400-2402), and clears that field at the start of each move
	// (:4338). WorldTick runs before the thinkers (p_tick.cpp:171-173), so here we see the result of last
	// tic's move against the velocity we saw before it: struck a line, and was going INTO it at
	// ssq_slam_min or more, is a slam. Once per bash.
	void ArmSlam(Actor t, int pnum)
	{
		if (!t || SVI('ssq_slam', 1) == 0) return;
		t.MovementBlockingLine = null;	// a stale line from its own walking is not this shove's wall
		int k = mSlamWho.Find(t);
		if (k >= mSlamWho.Size())
		{
			if (mSlamWho.Size() >= 32) { mSlamWho.Delete(0); mSlamBy.Delete(0); mSlamUntil.Delete(0); mSlamVX.Delete(0); mSlamVY.Delete(0); }
			mSlamWho.Push(t); mSlamBy.Push(pnum); mSlamUntil.Push(0); mSlamVX.Push(0); mSlamVY.Push(0);
			k = mSlamWho.Size() - 1;
		}
		mSlamBy[k] = pnum;
		mSlamUntil[k] = Level.maptime + 12 + max(t.freezetics, 0);
		mSlamVX[k] = t.vel.x; mSlamVY[k] = t.vel.y;
	}

	void SlamTick()
	{
		for (int k = mSlamWho.Size() - 1; k >= 0; k--)
		{
			Actor v = mSlamWho[k];
			if (!v || v.health <= 0 || v.bMissile || Level.maptime > mSlamUntil[k] || SVI('ssq_slam', 1) == 0)
			{
				mSlamWho.Delete(k); mSlamBy.Delete(k); mSlamUntil.Delete(k); mSlamVX.Delete(k); mSlamVY.Delete(k);
				continue;
			}
			if (v.freezetics > 0) { mSlamUntil[k] = max(mSlamUntil[k], Level.maptime + v.freezetics + 2); continue; }
			Line ln = v.MovementBlockingLine;
			if (ln)
			{
				// the wall's normal, toward the side the body is on
				Vector2 d = ln.delta;
				Vector2 nrm = (d.y, -d.x);
				double nl = nrm.Length();
				if (nl > 0)
				{
					nrm /= nl;
					if ((v.pos.xy - ln.v1.p) dot nrm < 0) nrm = -nrm;
					double impact = -((mSlamVX[k], mSlamVY[k]) dot nrm);
					if (impact >= SV('ssq_slam_min', 3.0))
					{
						Slam(v, mSlamBy[k], nrm, impact);
						mSlamWho.Delete(k); mSlamBy.Delete(k); mSlamUntil.Delete(k); mSlamVX.Delete(k); mSlamVY.Delete(k);
						continue;
					}
				}
			}
			mSlamVX[k] = v.vel.x; mSlamVY[k] = v.vel.y;
		}
	}

	void Slam(Actor v, int pnum, Vector2 nrm, double impact)
	{
		PlayerPawn mo = (pnum >= 0 && pnum < MAXPLAYERS && playeringame[pnum]) ? players[pnum].mo : null;
		// WALL SLAM (Gun Bonsai VR patch): +50% a level, and stunned 10 + 10 tics a level longer
		int wsl = mo ? SSQ_Upg.Lv(mo.FindInventory('SSQ_ShieldSaw'), "WallSlam") : 0;
		int dmg = int(clamp(impact * 2.0, 5, 40) * SV('ssq_slam_damage', 1.0) * (wsl > 0 ? SSQ_Upg.Num("WallSlam.mult", wsl, 1.0) : 1.0));
		if (wsl > 0) SSQ_Upg.Touch("slam.saw", mo, v);
		if (mo) SSQ_Upg.Touch("shield.slam", mo, v);   // RSQ Score (11-03): the wall slam is its own tool, named before its blow
		Vector3 at = v.pos + (-nrm.x * v.radius, -nrm.y * v.radius, v.height * 0.5);
		int hp = v.health;
		if (dmg > 0)
		{
			let saw = mo ? mo.FindInventory('SSQ_ShieldSaw') : null;
			let upg = SSQ_Upg.Any();
			if (upg && saw) upg.GetInt("credit.push", "", 2, 0, saw);
			SSQ_FX.Hit(v, mo, mo, dmg, 'Melee');
			if (upg && saw) upg.GetInt("credit.pop", "", 0, 0, saw);
		}
		if (mo && mo.player && UVI(mo.player, 'ssq_debug', 0))
			Console.Printf("ssq: WALL SLAM %s at %.1f u/tic into the wall, dmg %d (hp %d -> %d), stun %d", v ? v.GetClassName() : 'gone', impact, dmg, hp, v ? v.health : 0, SVI('ssq_slam_stun', 8));
		if (mo) SSQ_FX.At(mo, at, "ssq/bash", CHAN_5, 0.9, 0.8);
		if (mo && mo.player && UVI(mo.player, 'ssq_feedback', 1) != 0) SSQ_FX.Sparks(mo, at, (nrm.x, nrm.y, 0.2), 10);
		if (!v || v.health <= 0) return;
		// stunned: the pain state, held, and a small rebound off the wall once it thaws (01_MELEE 4.7: 0.45)
		// The PLAIN pain state, not Pain.Melee: Brutal Doom's Pain.Melee sends an unaware monster into its
		// stealth-kill cutscene (brutal22test6 actors/Enemies/Imps.dec Pain.Melee -> GotoStealthKill; on the rig
		// a bash on an idle BD imp already does this, old pk3 and new, and the camera leaves the player). A wall
		// must not add a second way in. Plain Pain also takes the stealth flag away.
		v.TriggerPainChance('None', true);
		v.freezetics = max(v.freezetics, clamp(SVI('ssq_slam_stun', 8), 0, 35) + (wsl > 0 ? int(SSQ_Upg.Num("WallSlam.stun", wsl, 0)) : 0));
		if (!v.bDontThrust && v.Mass < 0x7FFFFFFF) v.vel.xy = nrm * impact * 0.45;
	}

	// ---- SABER OVER SHIELD: decided here, on the player's own machine (pick 15) --------------------
	// Read only through what is public: the main-hand weapon's class name (RSQ Saber's are UBQS_*, the Force
	// hand excepted), its blade lit (UBQS_SaberService "saber.lit", hand 0, when it answers), and the raw hand
	// fields. The blade's line is the saber's resting frame worked through from its own code: the blade leaves
	// the hand's forward 50 degrees toward the hand's up (QuestSaber zscript.txt UBQS_Data.Up(0) = 50, Yaw(0) = 0)
	// and runs from BeamAlong(5.111, 6.091) to BeamAlong(37.940, 45.216) along it (3.3 to 31.3 units at
	// ubqs_size 1, vr_weaponScale 1). The plate is the synced one. Braced = two or more of nine points along
	// the blade lie over the plate's face (within its rim) and within ssq_brace_gap of the front.
	static double SaberAlong(double sz, double mx, double mz)
	{
		let wsc = CVar.FindCVar('vr_weaponScale');
		double k = 1.6080 * sz * (wsc ? wsc.GetFloat() : 1.0);
		return SSQ_Hand.VU() * 0.01 * ((5.0 - 8.0 + k * mz) * sin(50.0) - (30.0 - 29.0 - k * mx) * cos(50.0));
	}

	bool BraceNow()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return false;
		if (SVI('ssq_brace', 1) == 0) return false;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || mo.health <= 0 || !SSQ_Hand.InVR(mo) || mState[consoleplayer] != SS_DRAWN) return false;
		let pose = mPose[consoleplayer];
		if (!pose || !pose.Fresh(Level.maptime)) return false;
		let w = p.ReadyWeapon;
		if (!w) return false;
		String cn = w.GetClassName();
		if (!(cn.Left(5) ~== "UBQS_") || cn ~== "UBQS_ForceHand") return false;
		let svc = ServiceIterator.Find("UBQS_SaberService").Next();
		if (svc && svc.GetInt("saber.lit", "", 0, 0, mo) != 1) return false;
		let szc = CVar.GetCVar('ubqs_size', p);
		double sz = szc ? clamp(szc.GetFloat(), 0.7, 1.3) : 1.0;
		Vector3 hand = mo.AttackPos;
		Vector3 F = SSQ_Hand.MainDir(mo, 0, 0);
		Vector3 U = SSQ_Hand.MainDir(mo, 0, 90);
		Vector3 bd = F * cos(50.0) + U * sin(50.0);
		double a0 = SaberAlong(sz, 5.111, 6.091), a1 = SaberAlong(sz, 37.940, 45.216);
		Vector3 C = SSQ_Guard.PlateCentre(mo, pose, false);
		Vector3 n = SSQ_Guard.PlateNormal(mo, pose, false);
		double R = SSQ_Guard.PlateRadius(false, 1.0, mo.PlayerNumber());
		double gap = CM(SV('ssq_brace_gap', 15.0));
		int over = 0;
		for (int s = 0; s <= 8; s++)
		{
			Vector3 q = hand + bd * (a0 + (a1 - a0) * s / 8.0) - C;
			double al = q dot n;
			if (al < -CM(2.0) || al > gap) continue;
			if ((q - n * al).Length() <= R) over++;
		}
		if (UVI(p, 'ssq_debug', 0) && (Level.maptime % 35) == 0)
		{
			Vector3 b0 = hand + bd * a0, b1 = hand + bd * a1;
			Console.Printf("ssq: brace test %s over %d/9 blade (%.0f %.0f %.0f)->(%.0f %.0f %.0f) dir(%.2f %.2f %.2f) plate C(%.0f %.0f %.0f) n(%.2f %.2f %.2f)", cn, over,
				b0.x, b0.y, b0.z, b1.x, b1.y, b1.z, bd.x, bd.y, bd.z, C.x, C.y, C.z, n.x, n.y, n.z);
		}
		return over >= 2;
	}

	void SendBrace()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		int now = BraceNow() ? 2 : 1;
		if (now == mBraceSent) return;
		if (mBraceSent == 0 && now == 1) { mBraceSent = 1; return; }
		mBraceSent = now;
		EventHandler.SendNetworkEvent("ssq-brace", now - 1);
	}

	// ---- the console player's side: the pose --------------------------------------------
	// SendPose runs in WorldTick on every machine, for that machine's own console player only:
	// it reads the renderer-written fields (console pawn only) and sends them. The sim never
	// reads those fields anywhere else. OffhandDir is play-scope, so this cannot live in UiTick.
	void SendPose()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || !SSQ_Hand.InVR(mo)) return;
		// 2026-11-27 (owner: "it does not live anywhere by default"): the pose is wanted only while the saw is in the hand
		// or in flight (the block, the bash, the swing, the catch). Away, no hand reaches for it: the pose near the spot on
		// the body, Use, the seat drop and RSQ Accessibility's Off-Hand Modifier reach are gone with that spot.
		if (mState[consoleplayer] == SS_STOWED) return;
		Vector3 hand = mo.OffhandPos;
		Vector3 F = SSQ_Hand.OffDir(mo, 0, 0);
		Vector3 L = SSQ_Hand.OffDir(mo, 90, 0);
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		double roll = SSQ_Hand.RollOf(F, L);
		int extra = LocalLeftHanded() ? 1 : 0;
		// STEADY HANDS (RSQ_Accessibility AC6, a11y.zs): the aim the throw's aim share uses is turned by how far
		// the smoothed hand differs from the raw one (yaw and pitch), and sent beside the raw pose. Off / absent: not sent.
		int ctl = 1;
		if (SSQ_A11y.SteadyOn(mo))
		{
			double ry = mo.OffhandAngle, rp = mo.OffhandPitch;
			double ay = yaw + Actor.DeltaAngle(ry, SSQ_A11y.SteadyAngle(mo, ctl, "angle"));
			double ap = clamp(pitch + (SSQ_A11y.SteadyAngle(mo, ctl, "pitch") - rp), -90.0, 90.0);
			int iy = SSQ_Hand.ClampI(int(round((ay % 360.0 + 360.0) % 360.0 / 360.0 * 1023.0)), 0, 1023);
			int ip = SSQ_Hand.ClampI(int(round((ap + 90.0) / 180.0 * 1023.0)), 0, 1023);
			extra |= (iy << 1) | (ip << 11) | (1 << 21);
		}
		// 2026-11-03 (owner: "strafing left and right causes the melee 'whoosh'"): the frame's hand carried to where the body
		// is this tic, measured from the body at the VIEW's height (SSQ_HandSync): a tic with no frame read a still hand as
		// a step-long swing, and a stair's view dip as a drop of the hand
		hand = SSQ_HandSync.Fix(mo, hand, ctl);
		EventHandler.SendNetworkEvent("ssq-pose", SSQ_Hand.PackPos(hand - SSQ_HandSync.Body(mo)), SSQ_Hand.PackAng(yaw, pitch, roll, false), extra);
	}

	// 2026-11-27 (owner: "MAINHAND FIRE TO PAINT TARGET"): the MAIN hand's place and aim, for the rings (LocksTick). Sent as
	// the pose is, by this machine for its own player, and only while it is wanted: the saw in the off hand and main
	// primary fire held. With RSQ Accessibility's Steady Hands on, the smoothed aim (as the off hand's was).
	void SendAim()
	{
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo || !SSQ_Hand.InVR(mo)) return;
		if (mState[consoleplayer] != SS_DRAWN || (p.cmd.buttons & BT_ATTACK) == 0) return;
		Vector3 F = SSQ_Hand.MainDir(mo, 0, 0);
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		if (SSQ_A11y.SteadyOn(mo))
		{
			yaw += Actor.DeltaAngle(mo.AttackAngle, SSQ_A11y.SteadyAngle(mo, 0, "angle"));
			pitch = clamp(pitch + (SSQ_A11y.SteadyAngle(mo, 0, "pitch") - mo.AttackPitch), -90.0, 90.0);
		}
		Vector3 hand = SSQ_HandSync.Fix(mo, mo.AttackPos, 0);
		EventHandler.SendNetworkEvent("ssq-aim", SSQ_Hand.PackPos(hand - SSQ_HandSync.Body(mo)), SSQ_Hand.PackAng(yaw, pitch, 0, false));
	}

}
