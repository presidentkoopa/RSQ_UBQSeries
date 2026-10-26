// WHERE A HAND'S GUN IS AND WHERE IT POINTS, on stock QuestZDoom 17.x.
//
// A local copy of RSQ_DistanceGrab's reach.zs basis, under this package's own
// prefix, so neither pack needs the other loaded. Every convention here is the
// engine's, verified there:
//
//   Yaw   = AttackAngle + 90   (hw_vrmodes.cpp writes viewYaw - 90)
//   Pitch = AttackPitch        (written as -viewPitch, so positive is UP)
//   the hand fields ARE the controller (hw_openxrdevice.cpp writes the real pose
//   into AttackPos/OffhandPos for the camera player), and a LineAttack fired by
//   a weapon in VR goes along exactly these angles from exactly this point
//   (OverrideAttackPosDir) -- which is why the laser lands where the shot lands.
//
// ROOM vs MAP: 34 map units per metre horizontally, 28.33 vertically -- Doom's
// world is drawn stretched 1.2 in Z. Physical offsets (the muzzle) are given in
// metres and converted per axis, or a gun held level would aim high.
class RSQLS_Hand
{
	const UPM = 34.0;          // map units per metre, horizontal
	const PIXELSTRETCH = 1.2;

	static double Yaw(PlayerPawn pmo, int h)   { return ((h == 0) ? pmo.AttackAngle : pmo.OffhandAngle) + 90; }
	// Positive UP: AttackPitch already is (the engine negated Doom's view pitch).
	// Negating it again was the 2026-10-26 upside-down bug shared with the grab:
	// the muzzle offset and the no-hit end went the wrong way vertically.
	static double Pitch(PlayerPawn pmo, int h) { return (h == 0) ? pmo.AttackPitch : pmo.OffhandPitch; }
	// Doom's sense (positive DOWN), for LineTrace and friends.
	static double DoomPitch(PlayerPawn pmo, int h) { return -Pitch(pmo, h); }
	static double Roll(PlayerPawn pmo, int h)  { return (h == 0) ? pmo.AttackRoll : pmo.OffhandRoll; }
	static Vector3 Grip(PlayerPawn pmo, int h) { return (h == 0) ? pmo.AttackPos : pmo.OffhandPos; }

	static Vector3 Fwd(double y, double p)
	{
		return (cos(p) * cos(y), cos(p) * sin(y), sin(p));
	}

	// The gun's own up axis, roll included -- the muzzle of a gun canted on its
	// side is not above the grip.
	static Vector3 Up(double y, double p, double r)
	{
		Vector3 s = (sin(y), -cos(y), 0);
		Vector3 u = (-sin(p) * cos(y), -sin(p) * sin(y), cos(p));
		return u * cos(r) - s * sin(r);
	}

	static Vector3 Side(double y, double p, double r)
	{
		Vector3 s = (sin(y), -cos(y), 0);
		Vector3 u = (-sin(p) * cos(y), -sin(p) * sin(y), cos(p));
		return s * cos(r) + u * sin(r);
	}

	static Vector3 Dir(PlayerPawn pmo, int h) { return Fwd(Yaw(pmo, h), Pitch(pmo, h)); }

	// A physical offset in METRES along the gun's own axes, as a map-space point.
	// (The parameter was once `upM` -- which ZScript, being case-blind, read as
	// the constant UPM: every offset was scaled by 0.03 instead of 34 and the
	// muzzle sat on the grip, every gun, from v1 until the rig caught it on
	// 2026-10-26.)
	static Vector3 GunOffset(PlayerPawn pmo, int h, double fwdMetres, double upMetres, double sideMetres)
	{
		double y = Yaw(pmo, h);
		double pt = Pitch(pmo, h);
		double r = Roll(pmo, h);
		Vector3 m = Fwd(y, pt) * fwdMetres + Up(y, pt, r) * upMetres + Side(y, pt, r) * sideMetres;
		return (m.x * UPM, m.y * UPM, m.z * UPM / PIXELSTRETCH);
	}

	// Room-space yaw, pitch (Doom convention: positive DOWN) and length of a
	// map-space vector -- what a CORRECTPIXELSTRETCH model is aimed and sized by.
	static double, double, double RoomAim(Vector3 d)
	{
		Vector3 r = (d.x, d.y, d.z * PIXELSTRETCH);
		return VectorAngle(r.x, r.y), -atan2(r.z, r.xy.Length()), r.Length();
	}

	static double Num(String n, PlayerInfo p, double d) { let c = CVar.GetCVar(n, p); return c ? c.GetFloat() : d; }
	static bool   Flag(String n, PlayerInfo p, bool d)  { let c = CVar.GetCVar(n, p); return c ? c.GetBool() : d; }
	static int    Opt(String n, PlayerInfo p, int d)    { let c = CVar.GetCVar(n, p); return c ? c.GetInt() : d; }
}
