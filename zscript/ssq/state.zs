// RS_ShieldSawQ -- the three states, the shoulder mount, the loadout swap, and the input.
//
//   STOWED   on the mount over your off shoulder (a world prop, guarding your back)
//   DRAWN    in your off hand: SSQ_ShieldSaw is the off-hand weapon
//   FLYING   thrown. Your previous off-hand weapon is already back, so you are never
//            empty-handed. The disc comes home along the way it went; a hand near it on the
//            way back catches it (DRAWN), otherwise it lands on the mount (STOWED).
//
// INPUT IS EDGES, NOT A HELD GRIP. On stock QZD an off grip held within ~50 cm of the gun
// hand turns on the engine's two-hand stabilise, which hides every off-hand weapon layer and
// skips its buttons. So the grip is never held to keep the shield: press at the shoulder to
// draw, press while the hand is moving to throw, press at the shoulder (or slowly) to stow,
// press while it flies to recall. The rev is the off TRIGGER, a synced usercmd bit.
//
// The grip reaches the sim two ways, both per player and both synced:
//   - a usercmd bit (ssq_grip_button, BT_USER1 by default: bind the off grip to +user1)
//   - raw key codes (ssq_grip_keys) read by InputProcess on the console player and sent as
//     "ssq-grip" edges. The BD22 Quest pack's axe throw reads the grip the same way.
// Either way the decision runs here, in WorldTick, from the SYNCED pose (pose.zs).

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
	bool  mGripNet[MAXPLAYERS];		// the raw-key route's latch
	bool  mGripWas[MAXPLAYERS];
	int   mCatchGrace[MAXPLAYERS];	// tics after a catch before the grip is read again
	int   mStartDrawn[MAXPLAYERS];	// countdown to the draw at spawn (ssq_start_drawn)

	// ui side (console player only)
	ui bool  uiKeyDown;
	ui String uiKeysFrom;
	ui Array<int> uiKeys;

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

	static clearscope bool LeftHanded(PlayerInfo p) { return UVI(p, 'ssq_lefthanded', 0) != 0; }

	// ---- the mount: a point over the off shoulder, relative to the body ----------------
	// Forward is the pawn's yaw (the head's, in VR); up is from the eye (viewz, which the sim
	// has for every player). The off side is the left for a right-handed scheme.
	static clearscope int MountMode(PlayerInfo p) { return UVI(p, 'ssq_mount_mode', 1); }

	static clearscope Vector3 MountPos(PlayerPawn mo)
	{
		let p = mo.player;
		bool hip = MountMode(p) == 2;
		double side = CM(UV(p, hip ? 'ssq_hip_side' : 'ssq_mount_side', 8.0)) * (LeftHanded(p) ? -1 : 1);
		double fwd = CM(UV(p, hip ? 'ssq_hip_fwd' : 'ssq_mount_fwd', -7.0));
		double up = CM(UV(p, hip ? 'ssq_hip_up' : 'ssq_mount_up', -4.0));
		double a = mo.angle;
		Vector3 f = (cos(a), sin(a), 0);
		Vector3 l = (cos(a + 90), sin(a + 90), 0);
		return mo.pos + f * fwd + l * side + (0, 0, p.viewz - mo.pos.z + up);
	}

	static clearscope double Reach(PlayerInfo p) { return CM(UV(p, 'ssq_mount_reach', 10.0)); }

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
			if (mState[i] == SS_DRAWN && p.OffhandWeapon != saw && p.PendingWeapon != saw)
			{
				// something else took the hand (a pickup switch): the shield goes home
				Stow(i, false);
			}
			if (mState[i] == SS_FLYING && !mDisc[i]) { mState[i] = SS_STOWED; }
			if (mStartDrawn[i] > 0 && mState[i] == SS_STOWED && --mStartDrawn[i] == 0) Draw(i);

			// the grip: a usercmd bit or the raw-key latch
			int bit = UVI(p, 'ssq_grip_button', 0);
			bool grip = mGripNet[i] || (bit != 0 && (p.cmd.buttons & bit) != 0);
			bool press = grip && !mGripWas[i];
			mGripWas[i] = grip;
			if (mCatchGrace[i] > 0) { mCatchGrace[i]--; press = false; }
			if (press) OnPress(i);

			Props(i);
		}
	}

	// the grip press: what it means depends on where the hand is and how fast it moves
	void OnPress(int i)
	{
		let p = players[i];
		let mo = p.mo;
		let pose = mPose[i];
		bool fresh = pose.Fresh(Level.maptime);
		double dist = fresh ? (pose.pos[0] - MountPos(mo)).Length() : 1e9;
		int mode = MountMode(p);
		bool reach = mode != 0 && UVI(p, 'ssq_reach', 1) != 0;
		bool atMount = !reach || dist <= Reach(p);
		double speed = fresh ? pose.ThrowVel().Length() * TICRATE : 0;
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: press p%d state %d fresh %d mountdist %.1f speed %.0f/s", i, mState[i], fresh, dist, speed);

		switch (mState[i])
		{
		case SS_STOWED:
			if (atMount) Draw(i);
			break;
		case SS_DRAWN:
			// with no reach rule the press means throw if the arm is moving, else put it away
			if (reach && atMount) Stow(i, true);
			else if (speed >= SV('ssq_throw_min', 25.0)) Throw(i);
			else Stow(i, true);
			break;
		case SS_FLYING:
			if (mDisc[i]) SSQ_Disc(mDisc[i]).Recall();
			break;
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
		mPrevMain[i] = (rw && rw.bTwoHanded) ? rw.GetClass() : null;
		saw.bOffhandWeapon = true;
		p.PendingWeapon = saw;
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
		if (mPrevOff[i] && p.PendingWeapon == WP_NOCHANGE)
		{
			let back = Weapon(mo.FindInventory(mPrevOff[i]));
			if (back && back != p.ReadyWeapon) { back.bOffhandWeapon = true; p.PendingWeapon = back; }
		}
		else if (mPrevMain[i] && !p.ReadyWeapon && p.PendingWeapon == WP_NOCHANGE)
		{
			let back = Weapon(mo.FindInventory(mPrevMain[i]));
			if (back) { back.bOffhandWeapon = false; p.PendingWeapon = back; }
		}
		mPrevOff[i] = null; mPrevMain[i] = null;
	}

	void Stow(int i, bool sound)
	{
		Unstow(i);
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
		if (!d) { mState[i] = SS_STOWED; return; }
		d.Launch(mo, pose, rev);
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
			bool near = pose.Fresh(Level.maptime) && (pose.pos[0] - mount).Length() <= Reach(p);
			mk.A_SetRenderStyle(near ? 0.9 : 0.25, STYLE_Add);
			mk.angle += 3;
		}

		int mmode = MountMode(p);
		if (mmode == 0) mk.bInvisible = true;

		// the shield prop
		if (mState[i] == SS_STOWED && mmode == 0)
		{
			// on the forearm: the world prop rides the synced hand pose, blades in
			prop.bInvisible = !pose.Fresh(Level.maptime);
			if (!prop.bInvisible)
			{
				Vector3 c = SSQ_Guard.PlateCentre(mo, pose, false);
				prop.SetOrigin(c, true);
				prop.angle = atan2(pose.F.y, pose.F.x);
				prop.pitch = -asin(clamp(pose.F.z, -1, 1));
				prop.roll = SSQ_Hand.RollOf(pose.F, pose.L) * SV('ssq_roll_sign', 1.0);
				prop.A_SetScale(1.0);
				prop.frame = 0;
			}
		}
		else if (mState[i] == SS_STOWED)
		{
			prop.bInvisible = false;
			double yaw = mo.angle + 90 + UV(p, 'ssq_mount_yaw', 0);
			prop.SetOrigin(mount - (0, 0, CM(UV(p, 'ssq_mount_drop', 11.0))), true);
			prop.angle = yaw;
			prop.pitch = UV(p, 'ssq_mount_pitch', 0);
			prop.roll = UV(p, 'ssq_mount_roll', 0);
			prop.A_SetScale(UV(p, 'ssq_mount_scale', 1.0));
			prop.frame = 0;
		}
		else if (mState[i] == SS_DRAWN)
		{
			int hw = UVI(p, 'ssq_held_world', 2);
			bool want = hw == 1 || (hw == 2 && multiplayer);
			prop.bInvisible = !want || !pose.Fresh(Level.maptime);
			if (!prop.bInvisible)
			{
				// the plate's centre and axes, the same numbers the guard uses: the prop's
				// forward is the controller's forward, its face is +L
				Vector3 c = SSQ_Guard.PlateCentre(mo, pose, false);
				prop.SetOrigin(c, true);
				prop.angle = atan2(pose.F.y, pose.F.x);
				prop.pitch = -asin(clamp(pose.F.z, -1, 1));
				prop.roll = SSQ_Hand.RollOf(pose.F, pose.L) * SV('ssq_roll_sign', 1.0);
				prop.A_SetScale(1.0);
				prop.frame = saw ? saw.Frame() : 0;
			}
		}
		else prop.bInvisible = true;
	}

	// ---- events ------------------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i] || !players[i].mo) return;
		let mo = players[i].mo;
		if (e.Name == "ssq-pose")
		{
			double yaw, pitch, roll; int grip;
			[yaw, pitch, roll, grip] = SSQ_Hand.UnpackAng(e.Args[1]);
			Vector3 F, L, U;
			[F, L, U] = SSQ_Hand.Basis(yaw, pitch, roll);
			mPose[i].Push(mo.pos + SSQ_Hand.UnpackPos(e.Args[0]), F, L, U, grip != 0, Level.maptime);
		}
		else if (e.Name == "ssq-grip") mGripNet[i] = e.Args[0] != 0;
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
		if (UVI(p, 'ssq_debug', 0)) Console.Printf("ssq: p%d THROW along aim, speed %.1f/tic rev %d locks %d", i, d.vel.Length(), rev, d.locks.Size());
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
		int bit = UVI(p, 'ssq_grip_button', 0);
		bool grip = mGripNet[consoleplayer] || (bit != 0 && (p.cmd.buttons & bit) != 0);
		Vector3 hand = mo.OffhandPos;
		bool nearMount = (hand - MountPos(mo)).Length() <= Reach(p) * 2.0;
		bool want = st != SS_STOWED || grip || nearMount || MountMode(p) == 0;
		if (!want) return;
		Vector3 F = SSQ_Hand.OffDir(mo, 0, 0);
		Vector3 L = SSQ_Hand.OffDir(mo, 90, 0);
		double yaw = atan2(F.y, F.x);
		double pitch = asin(clamp(F.z, -1, 1));
		double roll = SSQ_Hand.RollOf(F, L);
		EventHandler.SendNetworkEvent("ssq-pose", SSQ_Hand.PackPos(hand - mo.pos), SSQ_Hand.PackAng(yaw, pitch, roll, grip), 0);
	}

	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return false;
		let p = players[consoleplayer];
		let cv = CVar.GetCVar('ssq_grip_keys', p);
		String keys = cv ? cv.GetString() : "";
		if (keys != uiKeysFrom)
		{
			uiKeysFrom = keys;
			uiKeys.Clear();
			Array<String> w;
			keys.Split(w, " ", TOK_SKIPEMPTY);
			for (int j = 0; j < w.Size(); j++) uiKeys.Push(w[j].ToInt());
		}
		if (UVI(p, 'ssq_debug', 0) && e.Type == InputEvent.Type_KeyDown) Console.Printf("ssq: key %d down", e.KeyScan);
		if (uiKeys.Size() == 0 || uiKeys.Find(e.KeyScan) == uiKeys.Size()) return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (down == uiKeyDown) return false;		// key repeat
		uiKeyDown = down;
		EventHandler.SendNetworkEvent("ssq-grip", down ? 1 : 0, e.KeyScan);
		return false;	// never eaten: the grip keeps whatever else it does
	}
}
