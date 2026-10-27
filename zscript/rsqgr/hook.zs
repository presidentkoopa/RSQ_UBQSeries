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

	// bite
	Actor victim;
	Vector3 victimOfs;
	bool heavy;           // too heavy to come: it is an anchor instead
	double bestDist;
	int noProgress;

	Array<RSQGR_Link> links;
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

	// THE ROPE: a chain of link sprites (JP's tenda0, 40 px at 0.2 = 8 units) from the
	// hand to the claw. Taut, it is straight; slack, it sags in a parabola deep enough
	// for the spare length (half the spare, a fair stand-in for a catenary at these
	// spans); coming back, it hangs a little. Links past rsqgr_rope_links spread out
	// rather than multiply, so a long rope costs the same as a medium one.
	void DrawRope()
	{
		double t0 = MSTimeF();
		Vector3 from = RSQGR_Util.HandPos(owner, hand);
		Vector3 to = Pos;
		Vector3 span = to - from;
		double d = span.Length();
		double spacing = max(2.0, RSQGR_Util.Num("rsqgr_rope_spacing", 6));
		int maxLinks = clamp(RSQGR_Util.Opt("rsqgr_rope_links", 64), 0, 256);
		int n = (d < 8) ? 0 : clamp(int(d / spacing), 1, maxLinks);

		double sag = 0;
		if (phase == PH_LATCH && ropeLen > d) sag = 0.5 * sqrt(ropeLen * ropeLen - d * d);
		else if (phase == PH_RETRACT) sag = d * 0.06;
		else if (phase == PH_FLY) sag = min(d * 0.03, 12);
		sag = min(sag, 160);

		// grow / shrink the chain
		while (links.Size() > n)
		{
			let l = links[links.Size() - 1];
			if (l) l.Destroy();
			links.Pop();
		}
		double sc = RSQGR_Util.Num("rsqgr_rope_scale", 0.2);
		for (int k = 0; k < n; k++)
		{
			double t = (k + 0.5) / n;
			Vector3 p = from + span * t;
			p.z -= sag * 4 * t * (1 - t);
			if (k >= links.Size())
			{
				let l = RSQGR_Link(Spawn("RSQGR_Link", p, NO_REPLACE));
				l.scale = (sc, sc);
				links.Push(l);
			}
			else
			{
				let l = links[k];
				if (!l) { l = RSQGR_Link(Spawn("RSQGR_Link", p, NO_REPLACE)); links[k] = l; }
				l.scale = (sc, sc);
				l.SetOrigin(p, true);
			}
		}
		drawMs = MSTimeF() - t0;
	}

	override void OnDestroy()
	{
		for (int i = 0; i < links.Size(); i++)
			if (links[i]) links[i].Destroy();
		links.Clear();
		Super.OnDestroy();
	}
}

class RSQGR_Link : Actor
{
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
		+FORCEXYBILLBOARD
		RenderStyle "Normal";
		Scale 0.2;
	}
	States
	{
	Spawn:
		RSGR A -1;
		Stop;
	}
	// Placed by its hook every tic; nothing of its own to run.
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
			if (a is "RSQGR_Hook" || a is "RSQGR_Link") return TRACE_Skip;
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
