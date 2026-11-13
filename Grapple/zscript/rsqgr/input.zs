// THE INPUT. One bind, Fire Hook (KEYCONF: `+rsqgr_hook` -> `event rsqgr_presskey`), and no usercmd bit (Brutal Doom
// Quest uses all four BT_USER bits).
//
// TWO HOPS, ON PURPOSE. `event` is a LOCAL console event: it reaches ConsoleProcess here, in ui scope, on the machine
// that pressed -- the only machine whose off-hand pose is real (the VR fields are written for the camera player alone).
// So the pose is read HERE and packed into the network event every machine acts on:
//   rsqgr_fire  a0 = 1 | yaw decidegrees << 1     (yaw 0..3599)
//               a1 = pitch decidegrees + 1000        (100..1900; 0 = no pose packed: fire along the live pose)
//               a2 = hand offset from the pawn, 3 x 10 bits of half-units, +512
// A bare `netevent rsqgr_fire` still works (the live pose, right in single player).
// THE COLLAPSED POSE (both hands written to one point: a menu just closed, a level just began) is no pose: the press is
// held back until a real one arrives, at most WAIT_TICS, then dropped.
class RSQGR_Input : EventHandler
{
	const WAIT_TICS = 10;
	ui int waitTic;

	override void ConsoleProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqgr_presskey")) return;   // the release does nothing: the hook is one press
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		if (Collapsed(p.mo)) { waitTic = gametic; return; }
		SendPress(p.mo);
	}

	static clearscope bool Collapsed(PlayerPawn pmo)
	{
		return pmo && pmo.OverrideAttackPosDir && pmo.AttackPos == pmo.OffhandPos;
	}

	override void UiTick()
	{
		if (waitTic <= 0) return;
		let p = players[consoleplayer];
		if (!p || !p.mo || gametic - waitTic > WAIT_TICS)
		{
			if (RSQGR_Util.Debug()) Console.Printf("T_G2 press dropped: the pose stayed collapsed");
			waitTic = 0;
			return;
		}
		if (Collapsed(p.mo)) return;
		waitTic = 0;
		SendPress(p.mo);
	}

	ui void SendPress(PlayerPawn pmo)
	{
		int a1 = 0, a2 = 0, yawd = 0;
		if (RSQGR_Util.PoseGood(pmo))
		{
			Vector3 off = pmo.OffhandPos - pmo.Pos;
			double yaw = RSQGR_Util.HandYaw(pmo) % 360.0;
			if (yaw < 0) yaw += 360.0;
			double pit = RSQGR_Util.HandPitch(pmo);
			yawd = clamp(int(yaw * 10 + 0.5), 0, 3599);
			a1 = clamp(int(pit * 10 + (pit >= 0 ? 0.5 : -0.5)), -900, 900) + 1000;
			a2 = Pack(off);
		}
		EventHandler.SendNetworkEvent("rsqgr_fire", 1 | (yawd << 1), a1, a2);
	}

	static clearscope int Pack(Vector3 off)
	{
		int ox = clamp(int(off.x * 2 + 512.5), 0, 1023);
		int oy = clamp(int(off.y * 2 + 512.5), 0, 1023);
		int oz = clamp(int(off.z * 2 + 512.5), 0, 1023);
		return ox | (oy << 10) | (oz << 20);
	}
	static clearscope Vector3 Unpack(int a2)
	{
		return (((a2 & 1023) - 512) / 2.0, (((a2 >> 10) & 1023) - 512) / 2.0, (((a2 >> 20) & 1023) - 512) / 2.0);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqgr_fire")) return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let pmo = players[e.Player].mo;
		let core = RSQGR_Core.Get();
		if (!pmo || !core) return;
		Vector3 org, dir;
		if (e.Args[1] > 0)
		{
			org = pmo.Pos + Unpack(e.Args[2]);
			dir = RSQGR_Util.MapDir((e.Args[0] >> 1) / 10.0, (e.Args[1] - 1000) / 10.0);
		}
		else
		{
			org = RSQGR_Util.HandPos(pmo);
			dir = RSQGR_Util.MapDir(RSQGR_Util.HandYaw(pmo), RSQGR_Util.HandPitch(pmo));
		}
		core.Fire(e.Player, org, dir);
	}
}
