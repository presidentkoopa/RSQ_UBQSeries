// THE INPUT. One bind, Fire Hook (KEYCONF: `+rsqgr_hook` -> `event rsqgr_presskey`), and no usercmd bit (Brutal Doom
// Quest uses all four BT_USER bits).
//
// TWO HOPS, ON PURPOSE. `event` is a LOCAL console event: it reaches ConsoleProcess here, in ui scope, on the machine
// that pressed -- the only machine whose hand pose is real (the VR fields are written for the camera player alone).
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
			Vector3 off = RSQGR_Util.HookRaw(pmo) - pmo.Pos;   // the hook hand's (C7: Hook Hand)
			double yaw = (RSQGR_Util.HandYaw(pmo) + RSQGR_Util.AimTrimYaw(pmo)) % 360.0;
			if (yaw < 0) yaw += 360.0;
			double pit = RSQGR_Util.HandPitch(pmo) + RSQGR_Util.AimTrimPitch(pmo);
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
			// the firing line (util.zs FireDir): the engine's controller data is this machine's player's only
			if (e.Player == consoleplayer && RSQGR_Util.PoseGood(pmo)) dir = RSQGR_Util.FireDir(pmo);
		}
		else
		{
			org = RSQGR_Util.HandPos(pmo);
			dir = RSQGR_Util.FireDir(pmo);
		}
		core.Fire(e.Player, org, dir);
	}
}

// THE AIM DOT (owner 2026-11-23: "grapple does not fire forward it fires slightly off to the right?"). The claw flies
// exactly along the hook hand's controller (its yaw and pitch: util.zs HandYaw / HandPitch, the same angles the
// engine aims a gun in that hand by), but a bare hand shows no barrel, so where the drawn hand seems to point and
// where the controller points can differ by a few degrees. While the hook is ready, a small dot sits where the claw
// would bite (the claw's own tracer, its reach), so the aim is seen, not guessed; Aim Trim turns the claw's line (and
// the dot) left or right and up or down if the hand still reads off. Your own machine only (a client effect).
class RSQGR_AimDot : EventHandler
{
	RSQGR_Tracer tr;
	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p ? p.mo : null;
		if (!pmo || pmo.health <= 0 || !RSQGR_Util.Flag("rsqgr_aim_dot", true) || !RSQGR_Util.PoseGood(pmo)) return;
		let core = RSQGR_Core.Get();
		if (!core || !core.Idle(consoleplayer)) return;
		Vector3 org = RSQGR_Util.HandPos(pmo);
		Vector3 dir = RSQGR_Util.FireDir(pmo);      // the firing line, the claw's own (util.zs)
		if (!tr) tr = new("RSQGR_Tracer");
		tr.shooter = pmo;
		if (!tr.Trace(org, level.PointInSector(org.xy), dir, RSQGR_Util.Range(), TRACE_HitSky, RSQGR_Tracer.WALLMASK, false, pmo)) return;
		if (tr.Results.HitType == TRACE_HitNone || tr.Results.HitType == TRACE_HasHitSky) return;
		Vector3 at = tr.Results.HitPos - dir * 2;
		Vector3 d = at - pmo.pos;
		// a monster it would bite: the arcade gold; the world: cyan
		int col = tr.Results.HitType == TRACE_HitActor ? 0xFFD040 : 0x40E8FF;
		double sz = clamp(tr.Results.Distance / 96.0, 3.0, 9.0);   // about the same size on screen near and far
		pmo.A_SpawnParticle(col, SPF_FULLBRIGHT, 2, sz, 0, d.x, d.y, d.z, 0, 0, 0, 0, 0, 0, 1.0);
	}
}
