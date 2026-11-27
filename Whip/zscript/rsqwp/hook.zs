// One straight piece of the whip: a tube model (the thong's links and the handle are its subclasses, whip.zs), placed by
// the whip every tic.
// 2026-11-27 (owner: "i want to tone this thing down"): the hook, its rope and its chain went with the swinging and the
// leash; this file keeps the two pieces the thong still needs.
class RSQWP_Rope : Actor
{
	const ROPE_L = 32.0;   // tools/gen_rope.py
	Default
	{
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTELEPORT
		+INTERPOLATEANGLES
		RenderStyle "Normal";
	}
	States
	{
	Spawn:
		RSWP A -1;
		Stop;
	}
	override void Tick() {}
}

// The thong's eyes: one LineTracer, walls by their blocking flags (the whip's own traces ignore every actor).
class RSQWP_Tracer : LineTracer
{
	Actor shooter;

	override ETraceStatus TraceCallback()
	{
		// UNREACHABLE since 2026-11-27 (owner: "i want to tone this thing down"): every trace the whip still makes ignores all
		// actors (whip.zs Mend, Collide; lash.zs GroundCrack), so no actor is ever handed to this branch. Left as it was.
		if (Results.HitType == TRACE_HitActor)
		{
			let a = Results.HitActor;
			if (!a || a == shooter) return TRACE_Skip;
			if (a.player) return TRACE_Skip;
			if (a is "RSQWP_Rope") return TRACE_Skip;
			if (!a.bSHOOTABLE || a.bNONSHOOTABLE || a.Health <= 0) return TRACE_Skip;
			if (a.bMISSILE) return TRACE_Skip;
			return TRACE_Stop;
		}
		return TRACE_Stop;
	}

	// The two-sided lines the thong stops at in their open middle: the ones that stop
	// shots and missiles. Everything else passes through the opening.
	const WALLMASK = Line.ML_BLOCKEVERYTHING | Line.ML_BLOCKPROJECTILE | Line.ML_BLOCKHITSCAN;
}
