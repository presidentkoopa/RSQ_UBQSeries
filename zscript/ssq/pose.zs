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
	Vector3 pos[3];		// newest first
	Vector3 F, L, U;
	int stamp[3];		// level time each sample arrived, 0 = none
	bool grip;			// the off grip as the sender saw it (a hint; decisions use the edge events)
	int count;

	void Push(Vector3 p, Vector3 f, Vector3 l, Vector3 u, bool g, int now)
	{
		pos[2] = pos[1]; pos[1] = pos[0]; pos[0] = p;
		stamp[2] = stamp[1]; stamp[1] = stamp[0]; stamp[0] = now;
		F = f; L = l; U = u; grip = g;
		if (count < 3) count++;
	}

	bool Fresh(int now) { return count > 0 && now - stamp[0] <= 3; }

	// map units per tic, from the last two samples (zero until there are two)
	Vector3 Vel()
	{
		if (count < 2 || stamp[0] == stamp[1]) return (0, 0, 0);
		return (pos[0] - pos[1]) / (stamp[0] - stamp[1]);
	}

	// a smoother velocity for the throw: the fit over three samples when they exist
	Vector3 ThrowVel()
	{
		if (count < 3 || stamp[0] == stamp[2]) return Vel();
		return (pos[0] - pos[2]) / (stamp[0] - stamp[2]);
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
