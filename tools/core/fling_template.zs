// ONE THROW, the series' single source (tools/core/stamp.py writes every copy; do not edit a copy). A throw is the hand at
// MIN_MPS or more, ahead of the body (Ahead); the thrown thing leaves at the hand's speed x GAIN x strength, held under CAP_MPS.
class @P@_Fling
{
	const GAIN = 4.0;
	const CAP_MPS = 30.0;
	const MIN_MPS = 1.5;
	const GRAVITY = 0.5;
	const AHEAD_COS = 0.5;

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
}
