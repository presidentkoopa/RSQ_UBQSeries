// ONE THROW for the saber: tools/core/stamp.py writes the class below from tools/core/fling_template.zs. Do not edit.
class UBQS_Fling
{
	const GAIN = 4.0;
	const CAP_MPS = 30.0;
	const MIN_MPS = 2.2;
	const GRAVITY = 0.5;
	const AHEAD_COS = 0.5;
	const MARK_MPS = 1.0;
	const MARK_COS = 0.5;
	const TURN_DEG = 9.0;

	// a motion `fwd` ahead of the body and `side` across it is a throw's: within 60 degrees of ahead across the ground
	static bool Ahead(double fwd, double side)
	{
		double a = sqrt(fwd * fwd + side * side);
		return a > 0.000001 && fwd >= AHEAD_COS * a;
	}

	// what the hand's velocity is multiplied by: GAIN x strength, the result held under CAP_MPS
	static double Mult(double handMps, double strength)
	{
		if (handMps <= 0) return 0;
		return min(handMps * GAIN * max(strength, 0.0), CAP_MPS) / handMps;
	}

	// a release with something marked is a throw when the hand moves at MARK_MPS or more, toward the mark (`hand` and
	// `toMark` any length, the same frame)
	static bool TowardMark(double handMps, Vector3 hand, Vector3 toMark)
	{
		double a = hand.Length(), b = toMark.Length();
		if (handMps < MARK_MPS || a < 0.000001 || b < 0.000001) return false;
		return (hand / a) dot (toMark / b) >= MARK_COS;
	}

	// a homing throw's heading this tic: `dir` turned toward `want` by at most TURN_DEG (both unit vectors); closer than
	// `near` map units it goes straight there (no orbiting a target it is about to hit)
	static Vector3 Turn(Vector3 dir, Vector3 want, double dist, double near)
	{
		if (dist <= near) return want;
		double c = clamp(dir dot want, -1.0, 1.0);
		double ang = acos(c);
		if (ang <= TURN_DEG) return want;
		double k = TURN_DEG / ang;
		Vector3 v = dir * (1.0 - k) + want * k;
		return v.Length() > 0.000001 ? v.Unit() : want;
	}
}
