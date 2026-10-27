// THE CLAW AND ITS ROPE. The claw is a visual and a container for one hand's hook
// state; RSQGR_Core decides everything in WorldTick. This actor's own Tick only
// DRAWS -- and that is why it is an actor at all: thinkers run in statnum order
// (STAT_PLAYER 33 before STAT_DEFAULT 100), and WorldTick runs before both
// (p_tick.cpp), so the player has already moved this tic by the time the claw's
// Tick lays the rope from the hand to the claw. Drawn in WorldTick, the rope's
// hand end would trail the hand by one tic of swing speed -- 20 units at the
// bottom of an arc.
//
// The claw runs in real time under RSQ_SlowMo (its RealTime test passes any class
// named "rsq...") -- it is the player's tool, like the grab's beam.
class RSQGR_Hook : Actor
{
	enum EPhase
	{
		PH_FLY,       // travelling along dir
		PH_LATCH,     // biting geometry (or a heavy monster): the player swings / yanks
		PH_BITE,      // biting a monster that comes to you (RSQGR_Monster)
		PH_HOLD,      // JP's yank: the claw stays shut a moment, then comes back
		PH_RETRACT    // coming back to the hand
	}

	PlayerPawn owner;
	int hand;
	int phase;
	int phaseAge;
	Vector3 dir;
	double traveled;
	double speed;
	double range;

	// latch
	Vector3 anchor;
	Vector3 hitDir;
	Sector anchorSec;
	int anchorPlane;      // 0 wall / none, 1 floor, 2 ceiling
	double planeOfs;
	double ropeLen;
	int losBad;
	bool reelHeld;        // reeling this tic (for the drawing and the log)
	bool slack;           // the rope may hang slack this tic (off the ground or reeling)

	// bite
	Actor victim;
	Vector3 victimOfs;
	bool heavy;           // too heavy to come: it is an anchor instead
	double bestDist;
	int noProgress;

	Array<RSQGR_Rope> segs;
	double drawMs;        // last rope draw cost (rsqgr_debug)

	Default
	{
		Radius 4;
		Height 4;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTELEPORT
		+FORCEXYBILLBOARD
		RenderStyle "Normal";
	}

	States
	{
	Spawn:
		RSGH A -1;
		Stop;
	Shut:
		RSGK A -1;
		Stop;
	}

	void SetPhase(int ph)
	{
		phase = ph;
		phaseAge = 0;
		bool shut = (ph == PH_LATCH || ph == PH_BITE || ph == PH_HOLD);
		Name want = RSQGR_Looks.Sprite(shut ? 'closed' : 'open');
		int si = GetSpriteIndex(want);
		if (si >= 0) { sprite = si; frame = 0; }
		if (ph != PH_FLY) A_StopSound(CHAN_BODY);
		if (ph == PH_RETRACT)
		{
			String s = RSQGR_Looks.Sound('retract');
			if (s != "") A_StartSound(s, CHAN_WEAPON, 0, 0.7);
		}
	}

	// Where the rope's far end is this tic.
	Vector3 ClawPoint()
	{
		if ((phase == PH_BITE || (phase == PH_LATCH && heavy)) && victim)
			return victim.Pos + victimOfs;
		return Pos;
	}

	override void Tick()
	{
		// No Super.Tick: the claw has no physics of its own and no state to run.
		if (!owner || owner.bDestroyed || !owner.player || owner.player.mo != owner)
		{
			Destroy();
			return;
		}
		phaseAge++;

		if (phase == PH_RETRACT)
		{
			Vector3 h = RSQGR_Util.HandPos(owner, hand);
			Vector3 to = h - Pos;
			double d = to.Length();
			double step = RSQGR_Util.Num("rsqgr_retract_speed", 64);
			if (d <= step + 8 || phaseAge > 70)
			{
				Destroy();
				return;
			}
			SetOrigin(Pos + to / d * step, true);
			angle = atan2(-to.y, -to.x);
		}
		else if ((phase == PH_BITE || (phase == PH_LATCH && heavy)) && victim)
		{
			SetOrigin(victim.Pos + victimOfs, true);
		}
		DrawRope();
	}

	// THE ROPE: tube segments (models/rsqgr/rsqrope.md3) from the hand to the claw.
	// Taut, it is ONE straight segment however long. Slack, it sags in a parabola
	// deep enough for the spare length (half the spare: a fair stand-in for a
	// catenary at these spans) drawn as up to rsqgr_rope_segs straight pieces.
	// Coming back, it hangs a little.
	void DrawRope()
	{
		double t0 = MSTimeF();
		Vector3 from = RSQGR_Util.HandPos(owner, hand);
		Vector3 to = Pos;
		Vector3 span = to - from;
		double d = span.Length();

		double sag = 0;
		if (phase == PH_LATCH && slack)
		{
			// The rope's length is kept from the body's attach point, not the hand: the
			// spare is measured there and the sag drawn from the hand with that spare.
			double spare = ropeLen - (ClawPoint() - RSQGR_Core.AttachPoint(owner)).Length();
			if (spare > 0.5) sag = 0.5 * sqrt((d + spare) * (d + spare) - d * d);
		}
		else if (phase == PH_RETRACT) sag = d * 0.06;
		sag = min(sag, 160);
		int n = 0;
		if (d >= 4)
			n = (sag > 1.5) ? clamp(int(d / 24) + 2, 4, max(1, RSQGR_Util.Opt("rsqgr_rope_segs", 12))) : 1;

		while (segs.Size() > n)
		{
			let r = segs[segs.Size() - 1];
			if (r) r.Destroy();
			segs.Pop();
		}
		double w = RSQGR_Util.Num("rsqgr_rope_width", 0.6);
		Vector3 a = from;
		for (int k = 0; k < n; k++)
		{
			double t = (k + 1.0) / n;
			Vector3 b = from + span * t;
			b.z -= sag * 4 * t * (1 - t);
			bool fresh = false;
			if (k >= segs.Size()) { segs.Push(null); }
			let r = segs[k];
			if (!r) { r = RSQGR_Rope(Spawn("RSQGR_Rope", a, NO_REPLACE)); segs[k] = r; fresh = true; }
			if (!fresh) r.SetOrigin(a, true);
			Vector3 m = b - a;
			Vector3 room = (m.x, m.y, m.z * RSQGR_Util.PIXELSTRETCH);
			double len = room.Length();
			r.angle = atan2(room.y, room.x);
			r.pitch = -atan2(room.z, room.xy.Length()) + 90;
			r.scale = (w, len / RSQGR_Rope.ROPE_L);
			if (fresh) { r.ClearInterpolation(); }
			a = b;
		}
		drawMs = MSTimeF() - t0;
	}

	override void OnDestroy()
	{
		for (int i = 0; i < segs.Size(); i++)
			if (segs[i]) segs[i].Destroy();
		segs.Clear();
		Super.OnDestroy();
	}
}

// One straight piece of rope: a tube model, placed by its hook every tic.
class RSQGR_Rope : Actor
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
		RSGM A -1;
		Stop;
	}
	override void Tick() {}
}

// The flight's eyes: one LineTracer, walls by their blocking flags, actors by
// whether a claw could bite them.
class RSQGR_Tracer : LineTracer
{
	Actor shooter;

	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitActor)
		{
			let a = Results.HitActor;
			if (!a || a == shooter) return TRACE_Skip;
			if (a.player) return TRACE_Skip;                         // no hooking people
			if (a is "RSQGR_Hook" || a is "RSQGR_Rope") return TRACE_Skip;
			if (!a.bSHOOTABLE || a.bNONSHOOTABLE || a.Health <= 0) return TRACE_Skip;
			if (a.bMISSILE) return TRACE_Skip;
			return TRACE_Stop;
		}
		return TRACE_Stop;
	}

	// The two-sided lines a hook stops at in their open middle: the ones that stop
	// shots and missiles. Everything else passes through the opening.
	const WALLMASK = Line.ML_BLOCKEVERYTHING | Line.ML_BLOCKPROJECTILE | Line.ML_BLOCKHITSCAN;
}
