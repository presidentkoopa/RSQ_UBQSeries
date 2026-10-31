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

	Array<RSQGR_Rope> segs;     // cable look
	Array<RSQGR_Link> links;    // chain look
	transient bool hcLit;       // high contrast: claw and rope at full brightness (DrawRope)
	int gripHand;               // a hand climbing this rope, -1 none (RSQGR_Climb)
	Vector3 gripLastOff;        // that hand's offset from the pawn last tic
	bool gripPending;           // the hold is taken on the next tic, from that tic's pose
	double drawMs;        // last rope draw cost (rsqgr_debug)
	bool whipped;         // the whip's tip, wrapped round an edge or a monster (whip.zs): drawn as the whip, no claw
	Vector3 struck;       // a whip's: where it struck the wall (its anchor is on the edge's corner)

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

	override void BeginPlay()
	{
		Super.BeginPlay();
		gripHand = -1;
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

	// THE ROPE, two looks (rsqgr_rope_style):
	//
	//   0 CHAIN (default, jpalomo's look). His hook is a FastProjectile with
	//     MissileType LoreShot2: the engine's Strife chain trail, a plain TEND A sprite
	//     (normal style, scale 1, 20 tics) that jp_grapple's tenda0 replaces -- 5 x 5
	//     units (the 40 px hires drawn at the 5 px size). FastProjectile.Effect drops
	//     one every sub-step: radius 10, speed 40 -> 8 sub-steps -> a link every 5 units.
	//     Measured with his own pk3 in the rig: links every 5.0 units, the nearest 15.0
	//     units out from the hand (the missile starts a radius ahead), at most 152 at
	//     once. This draws the same links at the same size and spacing, from 15 units
	//     out, along the live rope (his trail is only the flight path and fades in 20
	//     tics; ours stays while the rope does). The first cut here drew 8-unit links
	//     starting 3 units from the controller: 1.6x his size, five times closer to
	//     the eye -- the "fat white balls in the face".
	//   1 CABLE: tube segments (models/rsqgr/rsqrope.md3); one piece when taut.
	//
	// The line: from the firing hand, through the hand that has the rope if another
	// hand is climbing it (a tail hangs between them), to the claw; it sags in a
	// parabola deep enough for the spare length when slack.
	void DrawRope()
	{
		double t0 = MSTimeF();
		// High contrast (rsqa_colorblind 4, cb.zs): the claw and the rope are lit at full
		// brightness, so a dark chain still reads in a dark room. Nothing in the grapple speaks
		// in colour (open and shut are two shapes), so the other visions need nothing.
		hcLit = RSQGR_CB.Mode() == 4;
		bBRIGHT = hcLit;
		Vector3 from = RSQGR_Util.HandPos(owner, hand);
		Vector3 to = Pos;

		Array<double> px, py, pz;
		px.Push(from.x); py.Push(from.y); pz.Push(from.z);

		Vector3 mainFrom = from;
		if (phase == PH_LATCH && gripHand >= 0 && gripHand != hand)
		{
			// the tail: from the firing hand up to the climbing hand, hanging loose
			Vector3 g = RSQGR_Util.HandPos(owner, gripHand);
			AddArc(px, py, pz, from, g, (g - from).Length() * 0.25, 6);
			mainFrom = g;
		}

		Vector3 span = to - mainFrom;
		double d = span.Length();
		double sag = 0;
		if (phase == PH_LATCH && slack && gripHand < 0)
		{
			// The rope's length is kept from the body's attach point, not the hand: the
			// spare is measured there and the sag drawn from the hand with that spare.
			double spare = ropeLen - (ClawPoint() - RSQGR_Core.AttachPoint(owner)).Length();
			if (spare > 0.5) sag = 0.5 * sqrt((d + spare) * (d + spare) - d * d);
		}
		else if (phase == PH_RETRACT) sag = d * 0.06;
		sag = min(sag, 160);
		int n = (sag > 1.5) ? clamp(int(d / 24) + 2, 4, max(1, RSQGR_Util.Opt("rsqgr_rope_segs", 12))) : 1;
		AddArc(px, py, pz, mainFrom, to, sag, n);

		double total = 0;
		for (int i = 1; i < px.Size(); i++)
			total += ((px[i], py[i], pz[i]) - (px[i - 1], py[i - 1], pz[i - 1])).Length();

		bInvisible = whipped;            // the whip has no claw: its tip is wrapped round the thing
		if (whipped || RSQGR_Util.Opt("rsqgr_rope_style", 0) == 1)
		{
			ClearLinks(0);
			PlaceCable(px, py, pz, total < 4);
		}
		else
		{
			ClearSegs(0);
			PlaceChain(px, py, pz, total);
		}
		drawMs = MSTimeF() - t0;
	}

	// points from a (exclusive) to b (inclusive) in n pieces, sagging by `sag` mid-way
	static void AddArc(Array<double> px, Array<double> py, Array<double> pz, Vector3 a, Vector3 b, double sag, int n)
	{
		Vector3 sp = b - a;
		for (int k = 1; k <= n; k++)
		{
			double t = double(k) / n;
			Vector3 q = a + sp * t;
			q.z -= sag * 4 * t * (1 - t);
			px.Push(q.x); py.Push(q.y); pz.Push(q.z);
		}
	}

	const CHAIN_START = 15.0;   // jp_grapple, measured: the nearest link to the hand
	const CHAIN_STEP = 5.0;     // and the spacing

	void PlaceChain(Array<double> px, Array<double> py, Array<double> pz, double total)
	{
		int cap = clamp(RSQGR_Util.Opt("rsqgr_chain_links", 160), 8, 400);
		double avail = total - CHAIN_START;
		int want = avail > 0 ? int(avail / CHAIN_STEP) + 1 : 0;
		double step = CHAIN_STEP;
		if (want > cap) { step = avail / (cap - 1); want = cap; }
		ClearLinks(want);
		int seg = 1;
		double segStart = 0;
		Vector3 a = (px[0], py[0], pz[0]);
		Vector3 b = (px[1], py[1], pz[1]);
		double segLen = (b - a).Length();
		double sc = RSQGR_Util.Num("rsqgr_chain_scale", 0.125);
		bool nearEye = owner.player == players[consoleplayer];
		Vector3 eye = owner.Pos + (0, 0, owner.player.viewheight);
		for (int k = 0; k < want; k++)
		{
			double at = CHAIN_START + k * step;
			while (at > segStart + segLen && seg < px.Size() - 1)
			{
				segStart += segLen;
				seg++;
				a = b;
				b = (px[seg], py[seg], pz[seg]);
				segLen = (b - a).Length();
			}
			double f = segLen > 0.001 ? clamp((at - segStart) / segLen, 0.0, 1.0) : 0.0;
			Vector3 q = a + (b - a) * f;
			// NOT IN YOUR FACE. A climbing hand holds the rope above your head, so the
			// chain runs past the eye; a 5-unit link 5 units from the eye fills the view
			// (rig frames, 10-27). jp_grapple's nearest link is 15 units from the hand and
			// his trail never comes back past you, so no link is drawn within 15 units of
			// the viewer's eye (local: only the camera player's own rope).
			bool hide = nearEye && (q - eye).Length() < CHAIN_START;
			if (k >= links.Size()) links.Push(null);
			let l = links[k];
			if (!l)
			{
				l = RSQGR_Link(Spawn("RSQGR_Link", q, NO_REPLACE));
				links[k] = l;
			}
			else l.SetOrigin(q, true);
			l.scale = (sc, sc);
			l.bINVISIBLE = hide;
			l.bBRIGHT = hcLit;
		}
	}

	void PlaceCable(Array<double> px, Array<double> py, Array<double> pz, bool none)
	{
		int n = none ? 0 : px.Size() - 1;
		ClearSegs(n);
		double w = RSQGR_Util.Num("rsqgr_rope_width", 0.6);
		if (whipped) w *= 1.15;
		for (int k = 0; k < n; k++)
		{
			Vector3 a = (px[k], py[k], pz[k]);
			Vector3 b = (px[k + 1], py[k + 1], pz[k + 1]);
			bool fresh = false;
			if (k >= segs.Size()) segs.Push(null);
			let r = segs[k];
			if (!r) { r = RSQGR_Rope(Spawn(whipped ? "RSQGR_WhipLink" : "RSQGR_Rope", a, NO_REPLACE)); segs[k] = r; fresh = true; }
			if (!fresh) r.SetOrigin(a, true);
			Vector3 m = b - a;
			Vector3 room = (m.x, m.y, m.z * RSQGR_Util.PIXELSTRETCH);
			double len = room.Length();
			r.angle = atan2(room.y, room.x);
			r.pitch = -atan2(room.z, room.xy.Length()) + 90;
			r.scale = (w, len / RSQGR_Rope.ROPE_L);
			r.bBRIGHT = hcLit;
			if (fresh) r.ClearInterpolation();
		}
	}

	void ClearSegs(int keep)
	{
		while (segs.Size() > keep)
		{
			let r = segs[segs.Size() - 1];
			if (r) r.Destroy();
			segs.Pop();
		}
	}

	void ClearLinks(int keep)
	{
		while (links.Size() > keep)
		{
			let l = links[links.Size() - 1];
			if (l) l.Destroy();
			links.Pop();
		}
	}

	override void OnDestroy()
	{
		ClearSegs(0);
		ClearLinks(0);
		Super.OnDestroy();
	}
}

// One link of the chain look: jpalomo's tenda0 (40 px, drawn at 0.125 = his 5 units),
// normal style, like the LoreShot2 trail his hook drops. Placed by its hook every tic.
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
		+FORCEXYBILLBOARD   // round when you look up the rope at it (LoreShot2 is yaw-only: squashed ovals overhead, rig frames)
		RenderStyle "Normal";
		Scale 0.125;
	}
	States
	{
	Spawn:
		RSGL A -1;
		Stop;
	}
	override void Tick() {}
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
			if (a is "RSQGR_Hook" || a is "RSQGR_Rope" || a is "RSQGR_Link") return TRACE_Skip;
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
