// =====================================================================
// RS_MonsterAim -- predictive lead-fire, the real find from digging
// through CH's ACS (miscFuncs.acs's ProjInt_Brute). CH's version numerically
// brute-forces an intercept time in ACS fixed-point because that's all
// DECORATE-era Doom modding had available -- no closed-form solve, no
// real doubles, no early-out. ZScript has both, so this solves the same
// "where do I aim a fixed-speed projectile to hit a moving target"
// problem directly: constant-velocity intercept is a quadratic in time,
// solved once, not iteratively refined.
//
// Not wired into any monster yet -- this is the shared utility, ready
// for a monster's Missile state to call once one wants to lead its shots
// instead of firing at the target's current position.
// =====================================================================

class RS_MonsterAim : Object
{
	// Solves for the smallest positive t such that a projectile fired
	// from shooterPos at projSpeed, straight-line, meets a target
	// currently at targetPos moving at targetVel (assumed constant over
	// the flight). Returns false (no solution -- target is outpacing the
	// projectile, or moving directly away faster than it can close) if
	// no positive real root exists; callers should fall back to aiming
	// at the target's current position in that case.
	// RETURNS the aim point rather than filling an `out Vector3`. That is
	// not a style choice: GZDoom's JIT cannot emit a vector out-parameter,
	// and the earlier signature made this function's CALLER fail to JIT
	// with "Unknown REGT value passed to EmitPARAM" -- silently dropping
	// GetLeadAngle to the interpreter. Scalar out-params (out bool, out
	// double) are fine; only vectors break. Vector RETURNS are proven here
	// -- see Leech.zsc:8's WigglePos.
	// `solved` is false when no positive real root exists; aim point is
	// then the target's present position and the shot simply does not lead.
	static Vector3 PredictInterceptPoint(Vector3 shooterPos, Vector3 targetPos, Vector3 targetVel, double projSpeed, out bool solved)
	{
		solved = false;
		Vector3 aimPoint = targetPos;
		Vector3 d = targetPos - shooterPos;

		// |d + v*t|^2 = (speed*t)^2
		// t^2 (v.v - speed^2) + t (2 d.v) + d.d = 0
		double a = (targetVel dot targetVel) - (projSpeed * projSpeed);
		double b = 2.0 * (d dot targetVel);
		double c = d dot d;

		double t;

		if (abs(a) < 1e-6)
		{
			// Linear case (target speed ~= projectile speed on the
			// closing axis) -- b*t + c = 0.
			if (abs(b) < 1e-6)
				return aimPoint;
			t = -c / b;
		}
		else
		{
			double disc = (b * b) - (4.0 * a * c);
			if (disc < 0)
				return aimPoint;

			double sq = sqrt(disc);
			double t1 = (-b + sq) / (2.0 * a);
			double t2 = (-b - sq) / (2.0 * a);

			// Smallest positive root -- earliest valid intercept.
			if (t1 > 0 && t2 > 0)
				t = min(t1, t2);
			else if (t1 > 0)
				t = t1;
			else if (t2 > 0)
				t = t2;
			else
				return aimPoint;
		}

		aimPoint = targetPos + targetVel * t;
		solved = true;
		return aimPoint;
	}

	// Convenience wrapper for the common case: lead a shot at another
	// actor, falling back to its current position if no intercept
	// solution exists. Returns the angle/pitch to fire at, ready to hand
	// straight to A_CustomMissile's angle offset or A_FaceTarget-style
	// aiming.
	static void GetLeadAngle(Actor shooter, Actor target, double projSpeed, out double angle, out double pitch)
	{
		// No fallback branch needed: PredictInterceptPoint already returns
		// the target's present position when it cannot solve, which is
		// exactly the fallback this used to write by hand. `solved` is kept
		// so a caller that wants to know can ask.
		bool solved;
		Vector3 aimPoint = PredictInterceptPoint(shooter.pos, target.pos, target.vel, projSpeed, solved);

		Vector3 delta = aimPoint - shooter.pos;
		angle = VectorAngle(delta.x, delta.y);
		double horiz = (delta.xy).Length();
		pitch = -VectorAngle(horiz, delta.z);
	}
}
