// THE INPUT. One bind, Fire Hook, its hand a menu option (owner 11-10), and no usercmd bit.
//
// Brutal Doom Quest uses all four BT_USER bits, so the hook rides its own KEYCONF
// aliases. `+rsqgr_main` is not a buttonMap action, so it falls through to alias
// lookup, and key-up rewrites the leading `+` to `-`: a real press/release pair.
//
// TWO HOPS, ON PURPOSE. The alias runs `event rsqgr_press <hand>` -- a LOCAL
// console event (events.cpp CCMD(event)), which reaches ConsoleProcess here in ui
// scope on the machine that pressed. That is the only machine whose hand pose is
// real: the VR fields are written for the camera player alone and hold defaults
// for everyone else. So the pose is read HERE and packed into the network event
// that follows (rsqgr_fire), and every machine fires the same hook from the same
// hand along the same line. A bare `netevent rsqgr_fire <hand>` (no pose packed)
// still works: it fires along the firing player's live pose, right in single
// player.
//
//   rsqgr_fire  a0 = hand | yaw decidegrees << 1     (yaw 0..3599)
//               a1 = pitch decidegrees + 1000        (100..1900; 0 = no pose packed)
//               a2 = hand offset from the pawn, 3 x 10 bits of half-units, +512
//   rsqgr_up    a0 = hand
class RSQGR_Input : EventHandler
{
	// THE GRIPS HOLD THE ROPE (owner 2026-11-10: "The grip grabs the rope"). Stock QuestZDoom never puts a controller's
	// grip in cmd.buttons; it arrives as a key, read here by scan code as RSQ Distance Grab (near.zs), RSQ Tactical Rig
	// and the Whip's lasso read it (rsqgr_keys_main "446", rsqgr_keys_off "443 436"). Each edge becomes this pack's own
	// grab event, so no key bind and no other mod is needed. Never eaten: the press still reaches every other mod.
	ui String gripFrom[2];
	ui Array<int> gripMain, gripOff;
	ui bool gripDown[2];
	ui void GripKeys(int h)
	{
		let cv = CVar.FindCVar(h ? "rsqgr_keys_off" : "rsqgr_keys_main");
		String s = cv ? cv.GetString() : (h ? "443 436" : "446");
		if (s == gripFrom[h]) return;
		gripFrom[h] = s;
		Array<String> w;
		s.Split(w, " ", TOK_SKIPEMPTY);
		if (h) { gripOff.Clear(); for (int k = 0; k < w.Size(); k++) gripOff.Push(w[k].ToInt()); }
		else { gripMain.Clear(); for (int k = 0; k < w.Size(); k++) gripMain.Push(w[k].ToInt()); }
	}
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		GripKeys(0); GripKeys(1);
		int h = -1;
		if (gripMain.Find(e.KeyScan) < gripMain.Size()) h = 0;
		else if (gripOff.Find(e.KeyScan) < gripOff.Size()) h = 1;
		if (h < 0) return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (down == gripDown[h]) return false;
		gripDown[h] = down;
		EventHandler.SendNetworkEvent("rsqgr_grab", h, down ? 1 : 0);
		return false;
	}

	// RSQ_Accessibility's Hold to Toggle: the hook bind's press latches on (fire, then reel while
	// latched, as a held bind does) and the next press lets it go (a release within a tap of the
	// press lets go of the rope, as ever). Releases are ignored. This machine's side only.
	ui bool tog[2];

	// ONE KEY (owner 11-10, design/KEYBINDS_PLAN.md): "Fire Hook" (+rsqgr_hook) fires from the hand the menu's Fire Hook
	// From row picks (rsqgr_key_hand: 0 main, 1 off); it becomes the per-hand press and release below. The rope is taken
	// with RSQ Distance Grab's grips (rsqgr_grab_dg). The old per-hand and Grab Rope keys are gone.
	override void ConsoleProcess(ConsoleEvent e)
	{
		String n = e.Name;
		int a = e.Args[0];
		if (n ~== "rsqgr_presskey" || n ~== "rsqgr_releasekey")
		{
			let cv = CVar.GetCVar("rsqgr_key_hand", players[consoleplayer]);
			a = (cv && cv.GetInt() == 1) ? 1 : 0;
			n = (n ~== "rsqgr_presskey") ? "rsqgr_press" : "rsqgr_release";
		}
		Process(n, a);
	}
	ui void Process(String name, int arg0)
	{
		if ((name ~== "rsqgr_press" || name ~== "rsqgr_release") && RSQGR_A11y.HoldToggle())
		{
			int th = arg0 ? 1 : 0;
			if (name ~== "rsqgr_release") return;
			// a latch whose hook is gone (it came back by itself) is not on any more
			let pp = players[consoleplayer];
			if (tog[th] && pp && pp.mo && !RSQGR_Core.HookOf(pp.mo, th)) tog[th] = false;
			tog[th] = !tog[th];
			if (!tog[th]) { EventHandler.SendNetworkEvent("rsqgr_up", th); return; }
		}
		if (name ~== "rsqgr_press")
		{
			int hand = arg0 ? 1 : 0;
			let p = players[consoleplayer];
			if (!p || !p.mo) return;
			// THE COLLAPSED POSE: in VR, but both hands written to one point (a menu just closed, a level just
			// began: hw_vrmodes.cpp SetUp, Quest teardown apply/01 2.1). PoseGood refuses it, and the press then
			// fired along the BODY fallback -- from the chest, along the view (rig, 10-31). Held instead until a
			// real pose arrives (a frame or two), then fired from the hand; dropped after WAIT_TICS.
			if (Collapsed(p.mo)) { waitTic[hand] = gametic; waitUp[hand] = false; return; }
			SendPress(p.mo, hand);
		}
		else if (name ~== "rsqgr_release")
		{
			int hand = arg0 ? 1 : 0;
			if (waitTic[hand] > 0) { waitUp[hand] = true; return; }   // a tap while held back: fire, then let go
			EventHandler.SendNetworkEvent("rsqgr_up", hand);
		}
	}

	const WAIT_TICS = 10;
	ui int waitTic[2];         // the gametic a press was held back at, 0 none
	ui bool waitUp[2];

	static clearscope bool Collapsed(PlayerPawn pmo)
	{
		return pmo && pmo.OverrideAttackPosDir && pmo.AttackPos == pmo.OffhandPos;
	}

	// a press held back from a collapsed pose goes out on the first tic the hand is real
	override void UiTick()
	{
		for (int hand = 0; hand < 2; hand++)
		{
			if (waitTic[hand] <= 0) continue;
			let p = players[consoleplayer];
			if (!p || !p.mo || gametic - waitTic[hand] > WAIT_TICS)
			{
				if (RSQGR_Util.Opt("rsqgr_debug", 0) >= 1) Console.Printf("T_GR h%d press dropped: the pose stayed collapsed", hand);
				waitTic[hand] = 0;
				continue;
			}
			if (Collapsed(p.mo)) continue;
			if (RSQGR_Util.Opt("rsqgr_debug", 0) >= 1) Console.Printf("T_GR h%d press held %d tics for the collapsed pose", hand, gametic - waitTic[hand]);
			waitTic[hand] = 0;
			SendPress(p.mo, hand);
			if (waitUp[hand]) EventHandler.SendNetworkEvent("rsqgr_up", hand);
		}
	}

	ui void SendPress(PlayerPawn pmo, int hand)
	{
		{
			int a1 = 0, a2 = 0;
			int yawd = 0;
			if (RSQGR_Util.PoseGood(pmo, hand))
			{
				// Steady Hands (RSQ_Accessibility, util.zs AimPos): the hook leaves along the smoothed aim. Off: the raw hand.
				Vector3 h = RSQGR_Util.AimPos(pmo, hand);
				Vector3 off = h - pmo.Pos;
				double yaw = RSQGR_Util.AimYaw(pmo, hand);
				double pit = RSQGR_Util.AimPitch(pmo, hand);
				yaw = yaw % 360.0; if (yaw < 0) yaw += 360.0;
				yawd = clamp(int(yaw * 10 + 0.5), 0, 3599);
				a1 = clamp(int(pit * 10 + (pit >= 0 ? 0.5 : -0.5)), -900, 900) + 1000;
				int ox = clamp(int(off.x * 2 + 512.5), 0, 1023);
				int oy = clamp(int(off.y * 2 + 512.5), 0, 1023);
				int oz = clamp(int(off.z * 2 + 512.5), 0, 1023);
				a2 = ox | (oy << 10) | (oz << 20);
			}
			EventHandler.SendNetworkEvent("rsqgr_fire", hand | (yawd << 1), a1, a2);
		}
	}

	// THE CLIMBING HAND'S POSE, streamed from the machine that holds the controller,
	// every rendered frame while that hand is on the grab bind and a rope is out (the
	// last one before a tic is the one the tic uses). Sent in single player too: not
	// for the network but for a clean height.
	//
	// THE HEIGHT IS NOT CLEAN IN PLAY. AttackPos.Z is written per frame from the
	// INTERPOLATED eye (hw_openxrdevice.cpp: r_viewpoint.CenterEyePos.Z + controller
	// height), while X/Y come from the pawn's raw position. Read against pmo.Pos in
	// play, a still hand on a rising body wobbles by up to a tic of vertical speed
	// (rig: AttackPos.z - pmo.z went 36.8 -> 43.0 -> 51.5 -> 58.1 at frac 0.53/0.25/0.81
	// while the hand did not move), and climbing fed on it: the body overshot and came
	// back 14-17 units a stroke. Against the frame's own eye (RenderEvent.ViewPos) it is
	// constant (-4.17 every frame of the same run), so the height is taken there and
	// put back on the eye's height above the pawn (player.viewheight). Not on
	// player.viewz - pos.z: viewz is set in P_PlayerThink BEFORE the pawn moves that tic,
	// so it trails a moving body by a tic of vertical speed, and the climb chased it in
	// a 6-tic, 16-unit loop with the hand held still (rig).
	override void RenderOverlay(RenderEvent e)
	{
		let c = RSQGR_Core.Get();
		let p = players[consoleplayer];
		if (!c || !p || !p.mo || !p.mo.OverrideAttackPosDir) return;
		int pn = consoleplayer;
		if (!c.hooks[pn * 2] && !c.hooks[pn * 2 + 1]) return;
		let pmo = p.mo;
		for (int hand = 0; hand < 2; hand++)
		{
			if (!c.grabHeld[pn * 2 + hand] || !RSQGR_Util.PoseGood(pmo, hand)) continue;
			Vector3 h = RSQGR_Util.Ctrl(pmo, hand) == 0 ? pmo.AttackPos : pmo.OffhandPos;
			Vector3 off = (h.x - pmo.Pos.x, h.y - pmo.Pos.y, (h.z - e.ViewPos.z) + p.viewheight);
			EventHandler.SendNetworkEvent("rsqgr_pose", hand, RSQGR_Climb.Pack(off));
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let core = RSQGR_Core.Get();
		if (!core) return;
		if (e.Name ~== "rsqgr_fire")
		{
			int hand = e.Args[0] & 1;
			let pmo = players[e.Player].mo;
			if (!pmo) return;
			Vector3 org, dir;
			if (e.Args[1] > 0)
			{
				double yaw = (e.Args[0] >> 1) / 10.0;
				double pit = (e.Args[1] - 1000) / 10.0;
				int a2 = e.Args[2];
				Vector3 off = (((a2 & 1023) - 512) / 2.0, (((a2 >> 10) & 1023) - 512) / 2.0, (((a2 >> 20) & 1023) - 512) / 2.0);
				org = pmo.Pos + off;
				dir = RSQGR_Util.MapDir(yaw, pit);
			}
			else
			{
				org = RSQGR_Util.HandPos(pmo, hand);
				dir = RSQGR_Util.MapDir(RSQGR_Util.HandYaw(pmo, hand), RSQGR_Util.HandPitch(pmo, hand));
			}
			core.Press(e.Player, hand, org, dir);
		}
		else if (e.Name ~== "rsqgr_up")
		{
			core.Release(e.Player, e.Args[0] & 1);
		}
		else if (e.Name ~== "rsqgr_grab")
			core.Grab(e.Player, e.Args[0] & 1, e.Args[1] != 0);
		else if (e.Name ~== "rsqgr_pose")
		{
			int i = e.Player * 2 + (e.Args[0] & 1);
			core.poseOff[i] = RSQGR_Climb.Unpack(e.Args[1]);
			core.poseTic[i] = level.maptime;
		}
		// RSQ_DistanceGrab's own grab binds (rsqdg_press / rsqdg_release <hand>) are where
		// the owner keeps the grips; heard here too, so the grips take hold of the rope.
		else if ((e.Name ~== "rsqdg_press" || e.Name ~== "rsqdg_release") && RSQGR_Util.Flag("rsqgr_grab_dg", true))
			core.Grab(e.Player, e.Args[0] & 1, e.Name ~== "rsqdg_press");
	}
}
