// THE INPUT. Two binds, one per hand, and no usercmd bit.
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
	override void ConsoleProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rsqgr_press")
		{
			int hand = e.Args[0] ? 1 : 0;
			let p = players[consoleplayer];
			if (!p || !p.mo) return;
			let pmo = p.mo;
			int a1 = 0, a2 = 0;
			int yawd = 0;
			if (RSQGR_Util.PoseGood(pmo, hand))
			{
				Vector3 h = RSQGR_Util.HandPos(pmo, hand);
				Vector3 off = h - pmo.Pos;
				double yaw = RSQGR_Util.HandYaw(pmo, hand);
				double pit = RSQGR_Util.HandPitch(pmo, hand);
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
		else if (e.Name ~== "rsqgr_release")
		{
			EventHandler.SendNetworkEvent("rsqgr_up", e.Args[0] ? 1 : 0);
		}
		else if (e.Name ~== "rsqgr_grip")
			EventHandler.SendNetworkEvent("rsqgr_grab", e.Args[0] ? 1 : 0, 1);
		else if (e.Name ~== "rsqgr_ungrip")
			EventHandler.SendNetworkEvent("rsqgr_grab", e.Args[0] ? 1 : 0, 0);
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
			Vector3 h = hand == 0 ? pmo.AttackPos : pmo.OffhandPos;
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
