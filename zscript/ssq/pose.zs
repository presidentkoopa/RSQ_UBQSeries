// RS_ShieldSawQ -- the off hand's pose, SYNCED.
//
// Stock QuestZDoom writes OffhandPos / OffhandAngle / OffhandPitch / OffhandRoll on the
// console player's pawn only, from the renderer, and never sends them. Anything the sim
// decides from the hand (a block, a throw, a bash, a catch) has to come from a pose every
// machine has, or the game desyncs the moment somebody raises a shield.
//
// So: the console player's UiTick reads its own fields and sends "ssq-pose" (three ints) once
// a tic while the pose matters; NetworkProcess, which runs on every peer, unpacks it into the
// per-player history below. The sim reads ONLY the history -- on the sender's machine too.
//
// Frame: F is the controller's forward, L its left, U its up (the pack's RSVR_VRHand axes),
// unit vectors in map space. Positions are map units.

class SSQ_Pose play
{
	const N = 8;
	Vector3 pos[8];		// newest first
	Vector3 F, L, U;
	int stamp[8];		// level time each sample arrived, 0 = none
	bool grip;			// the off trigger as the sender saw it
	bool left;			// the sender plays left-handed (the engine's vr_control_scheme >= 10)
	int count;

	// THE AXES ARE BUILT HERE, IN PLACE. A function returning three Vector3s came back all
	// zeros on QZD 17.3's VM (found 2026-10-22, like the `out Vector3` fault): so the raw
	// angles come in and the fields are written directly.
	void Push(Vector3 p, double yaw, double pitch, double roll, bool g, int now)
	{
		for (int k = N - 1; k > 0; k--) { pos[k] = pos[k - 1]; stamp[k] = stamp[k - 1]; }
		pos[0] = p; stamp[0] = now;
		double cp = cos(pitch);
		F.x = cp * cos(yaw); F.y = cp * sin(yaw); F.z = sin(pitch);
		double l0x = cos(yaw + 90), l0y = sin(yaw + 90), l0z = 0;
		double u0x = F.y * l0z - F.z * l0y, u0y = F.z * l0x - F.x * l0z, u0z = F.x * l0y - F.y * l0x;
		double cr = cos(roll), sr = sin(roll);
		L.x = l0x * cr + u0x * sr; L.y = l0y * cr + u0y * sr; L.z = l0z * cr + u0z * sr;
		U.x = u0x * cr - l0x * sr; U.y = u0y * cr - l0y * sr; U.z = u0z * cr - l0z * sr;
		grip = g;
		if (count < N) count++;
	}

	clearscope bool Fresh(int now) { return count > 0 && now - stamp[0] <= 3; }

	// map units per tic, from the last two samples (zero until there are two)
	Vector3 Vel()
	{
		if (count < 2 || stamp[0] == stamp[1]) return (0, 0, 0);
		return (pos[0] - pos[1]) / (stamp[0] - stamp[1]);
	}

	// velocity over a 2-tic window starting k samples back; zero if not there
	Vector3 VelAt(int k)
	{
		if (k + 2 >= count || stamp[k] == stamp[k + 2]) return (0, 0, 0);
		return (pos[k] - pos[k + 2]) / (stamp[k] - stamp[k + 2]);
	}

	// THE THROW IS THE PEAK, NOT THE RELEASE. When the finger lets go the arm is already
	// slowing, so the velocity on that tic reads low and a real throw looks like a drop. The
	// fastest 2-tic window in the last six samples is the throw, and its direction is the
	// throw's direction.
	//
	// AND THE HAND'S TRAVEL IS NOT METRIC. OffhandPos.Z is divided by pixelstretch while X
	// and Y are not (hw_openxrdevice.cpp:605-609), so the same real swing measures about 20%
	// slower straight up than straight out, and an overhand throw left the hand soft. ps puts
	// that back into the MAGNITUDE only: the direction is already correct in Doom space, so
	// the returned vector keeps its heading and carries the true speed in its length.
	Vector3 ThrowVel(double ps)
	{
		Vector3 best = (0, 0, 0);
		double bl = 0;
		for (int k = 0; k < 6; k++)
		{
			Vector3 v = VelAt(k);
			double zt = v.z * ps;
			double l = sqrt(v.x * v.x + v.y * v.y + zt * zt);
			if (l > bl) { bl = l; best = v; }
		}
		double dl = best.Length();
		if (bl > 0 && dl > 0) best = best * (bl / dl);
		return best;
	}
}

class SSQ_Hand abstract play
{
	// ---- QZD's own fields, read-only, console player only (the pack's helpers, MIT) ----
	static clearscope bool InVR(PlayerPawn mo)
	{
		return mo && mo.player && mo.player.PlayInVR && mo.OverrideAttackPosDir;
	}

	static clearscope double VU()
	{
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		return vu > 0 ? vu : 34;
	}

	static clearscope double PS(PlayerPawn mo)
	{
		double ps = mo.Level.pixelstretch;
		return ps > 0 ? ps : 1.2;
	}

	// a unit vector of a direction in the OFF controller's frame (yaw 0 pitch 0 = forward,
	// yaw 90 = left, pitch 90 = up), the hand transform's vertical squash taken back out
	static Vector3 OffDir(PlayerPawn mo, double yaw, double pitch)
	{
		double ps = PS(mo);
		Vector3 ap = mo.OffhandDir(mo, mo.angle + yaw, mo.pitch + pitch);
		double cp = cos(ap.y);
		Vector3 v = (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y) * ps);
		double l = v.Length();
		if (l <= 0) return (1, 0, 0);
		return v / l;
	}

	// ---- packing ------------------------------------------------------------------
	// arg1: x, y relative to the pawn in quarter units (11 bits signed each), z in quarter
	//       units (10 bits signed)
	// arg2: yaw of F (10 bits, 0..360), pitch of F (10 bits, -90..90), roll of L about F
	//       (10 bits, -180..180), grip (1 bit)
	static clearscope int ClampI(int v, int lo, int hi) { return v < lo ? lo : (v > hi ? hi : v); }

	static clearscope int PackPos(Vector3 rel)
	{
		int x = ClampI(int(round(rel.x * 4)), -1024, 1023) & 0x7FF;
		int y = ClampI(int(round(rel.y * 4)), -1024, 1023) & 0x7FF;
		int z = ClampI(int(round(rel.z * 4)), -512, 511) & 0x3FF;
		return x | (y << 11) | (z << 22);
	}

	static clearscope Vector3 UnpackPos(int a)
	{
		int x = a & 0x7FF; if (x >= 1024) x -= 2048;
		int y = (a >> 11) & 0x7FF; if (y >= 1024) y -= 2048;
		int z = (a >> 22) & 0x3FF; if (z >= 512) z -= 1024;
		return (x / 4.0, y / 4.0, z / 4.0);
	}

	static clearscope int PackAng(double yaw, double pitch, double roll, bool grip)
	{
		int iy = ClampI(int(round((yaw % 360.0 + 360.0) % 360.0 / 360.0 * 1023.0)), 0, 1023);
		int ip = ClampI(int(round((pitch + 90.0) / 180.0 * 1023.0)), 0, 1023);
		int ir = ClampI(int(round(((roll + 180.0) % 360.0 + 360.0) % 360.0 / 360.0 * 1023.0)), 0, 1023);
		return iy | (ip << 10) | (ir << 20) | ((grip ? 1 : 0) << 30);
	}

	static clearscope double, double, double, int UnpackAng(int a)
	{
		double yaw = (a & 0x3FF) / 1023.0 * 360.0;
		double pitch = ((a >> 10) & 0x3FF) / 1023.0 * 180.0 - 90.0;
		double roll = ((a >> 20) & 0x3FF) / 1023.0 * 360.0 - 180.0;
		int grip = (a >> 30) & 1;
		return yaw, pitch, roll, grip;
	}

	// the basis from the packed angles: F from yaw/pitch, L0 the horizontal left of F, U0 = F x L0,
	// then L and U rolled about F
	// (returns, not out params: the JIT cannot pass an out Vector3)
	static clearscope Vector3, Vector3, Vector3 Basis(double yaw, double pitch, double roll)
	{
		double cp = cos(pitch);
		Vector3 F = (cp * cos(yaw), cp * sin(yaw), sin(pitch));
		Vector3 L0 = (cos(yaw + 90), sin(yaw + 90), 0);
		Vector3 U0 = (F.y * L0.z - F.z * L0.y, F.z * L0.x - F.x * L0.z, F.x * L0.y - F.y * L0.x);
		double cr = cos(roll), sr = sin(roll);
		Vector3 L = L0 * cr + U0 * sr;
		Vector3 U = U0 * cr - L0 * sr;
		return F, L, U;
	}

	// the roll of the controller's real left axis about F, measured against the horizontal
	// left, so the receiving side's Basis() rebuilds the same L and U the sender had
	static clearscope double RollOf(Vector3 F, Vector3 Lreal)
	{
		double yaw = atan2(F.y, F.x);
		Vector3 L0 = (cos(yaw + 90), sin(yaw + 90), 0);
		Vector3 U0 = (F.y * L0.z - F.z * L0.y, F.z * L0.x - F.x * L0.z, F.x * L0.y - F.y * L0.x);
		return atan2(Lreal dot U0, Lreal dot L0);
	}
}
