// RSQ_SlowMo -- DOWN IN THE WORLD: THE CROSSHAIRS ON THE TARGETS AND THE EYE-LEVEL TRAIL (owner 2026-11-07, design/NEAR_DEATH.md
// v3 to its 07:50 LAYERS answer; the look is design/mockups/down_v3_full_view_mockup.html). Console player only.
// THE PANEL (Target lines, bar, DEATH IN clock) AND THE EDGE ARROWS ARE NOT HERE: they are on the HUD layer (downhud.zs),
// drawn as RSQ Score's readout and SlowMo's own bars are, so the gun, a wall or the floor can never hide or clip them
// (owner 07:50). This file works out each target's state (which kind of pointer it needs, and the edge arrows' eased
// direction, which downhud.zs reads) and draws the two world things:
//   THE CROSSHAIR  in view (38 degrees) and in sight: it assembles on the target (17 baked frames, ~0.45 s,
//                  tools/plate/gen_plate_art.py) on one still panel over its middle, and stays; never through a wall.
//   THE TRAIL      within 75 degrees of your view (the edge arrows' hand-off, owner 07:12): six chevrons fixed in the world
//                  at eye level, from 40 units ahead of you to the target, a brightness wave running toward it (baked
//                  frames, tools/plate/gen_chevron.py); none placed behind a wall; it fades out once that target's crosshair
//                  has assembled (owner 07:47).
// Drawn the RSQ Wheel's way on stock QuestZDoom 17.3 (its wr_q_shim.zs, copied, nothing linked): unit quad models placed in
// the world every tic, facing the eye, coloured with the Shaded style. No panel moves or scales to animate (owner 07:15).
class RSQSM_PQuad : Actor
{
	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTONAUTOMAP
		+INTERPOLATEANGLES
		+NOTIMEFREEZE
		+BRIGHT
		RenderStyle "Shaded";
		StencilColor "FFFFFF";
		Alpha 1.0;
		Radius 1;
		Height 1;
	}
	States { Spawn: RSPQ A -1; Stop; }
}
class RSQSM_PStrip8 : RSQSM_PQuad {}
class RSQSM_PStrip12 : RSQSM_PQuad {}
class RSQSM_PStrip24 : RSQSM_PQuad {}

// one target's pointers
class RSQSM_TMark play
{
	Actor mon;
	int icon, col;
	bool dead;
	int deadTic;
	bool shown;                 // its crosshair is up (assembling or locked)
	int lockTic;                // when it (re)started assembling
	int edgeTic, trailTic;      // when the edge arrows / the trail came up (their frame clocks)
	int mode;                   // 0 none, 1 edge arrows (downhud.zs), 2 trail
	double eAng;                // the edge arrows' direction on the screen (degrees, 0 right, 90 up), round the eased gaze
	Actor xhair;
	Actor tF[6], tC[6], tL[6];
}

class RSQSM_Plate play
{
	int pn;
	double gYaw, gPitch;       // the eased gaze the edge arrows hang on (the RSQ Wheel's ring: a fifth of the way a tic)
	bool gSet;
	Array<RSQSM_TMark> marks;
	Vector3 r, u, nrm, eye;
	double pYaw, pTilt;

	void Init(int n) { pn = n; }
	static Actor Q(Name cls = 'RSQSM_PQuad') { class<Actor> c = cls; return c ? Actor.Spawn(c, (0, 0, 0), NO_REPLACE) : null; }
	static void Kill(Actor a) { if (a) a.Destroy(); }
	static void Off(Actor a) { if (a) a.bInvisible = true; }
	static Actor Need(Actor a, String tex = "") { if (!a) { a = Q(); if (tex != "") Skin(a, tex); } return a; }

	void Clear()
	{
		for (int i = 0; i < marks.Size(); i++) DropMark(marks[i]);
		marks.Clear();
	}
	void DropMark(RSQSM_TMark m)
	{
		if (!m) return;
		Kill(m.xhair);
		for (int i = 0; i < 6; i++) { Kill(m.tF[i]); Kill(m.tC[i]); Kill(m.tL[i]); }
	}
	static void Skin(Actor a, String tex) { if (a) a.A_ChangeModel("", 0, "", "", 0, "", tex); }
	static void Shade(Actor a, int rgb, double alpha, bool add = false)
	{
		if (!a) return;
		a.bInvisible = alpha <= 0.002;
		a.A_SetRenderStyle(clamp(alpha, 0.0, 1.0), add ? STYLE_AddShaded : STYLE_Shaded);
		a.SetShade(Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255));
	}
	static void Plain(Actor a, double alpha)
	{
		if (!a) return;
		a.bInvisible = alpha <= 0.002;
		a.A_SetRenderStyle(clamp(alpha, 0.0, 1.0), STYLE_Translucent);
	}
	// a basis facing the eye from p (the Wheel's BillboardBasis)
	void Face(Vector3 p, Vector3 e)
	{
		Vector3 d = e - p;
		pYaw = atan2(d.y, d.x);
		pTilt = atan2(d.z, d.xy.Length());
		double cy = cos(pYaw), sy = sin(pYaw), ct = cos(pTilt), st = sin(pTilt);
		r = (-sy, cy, 0);
		u = (-cy * st, -sy * st, ct);
		nrm = r cross u;
	}
	// a quad at a world point, facing the eye
	void PutAt(Actor a, Vector3 p, double w, double h, double roll, double layer = 0)
	{
		if (!a) return;
		Face(p, eye);
		a.SetOrigin(p + nrm * (layer * 0.05), true);
		a.angle = pYaw; a.pitch = -pTilt; a.roll = roll;
		a.scale = (max(w, 0.0001), max(h, 0.0001));
	}
	void Tick(RSQSM_Down d) { if (players[pn].mo) MarksTick(d); }

	// ---- THE CROSSHAIRS, THE EDGE ARROWS, THE TRAIL ------------------------------------------------------------------
	const VIEW_DEG = 38.0;     // in view: within this of the gaze, and in sight
	const TRAIL_DEG = 75.0;    // within this the trail takes over from the edge arrows (owner 07:12, "about 75 degrees")
	const TRAIL_FADE = 10;     // tics the trail takes to fade once the crosshair has assembled ("fades out": my number, ~0.3 s)
	const ASM_LAST = 16;       // the assembly's last frame (the locked icon)
	const TRAIL_FR = 24;
	const TRAIL_H = 6.0;       // a trail chevron's height in the world (its 22 cells; 16 wide): ~8.6 degrees at 40 units, the edge chevrons' 88 px

	RSQSM_TMark MarkOf(Actor m)
	{
		for (int i = 0; i < marks.Size(); i++) if (marks[i] && marks[i].mon == m) return marks[i];
		return null;
	}
	// the mockup's light tint (hsl(H, 80%, 75%)) of a target colour
	static clearscope int Light(int col) { return RSQSM_DownHud.Light(col); }

	void MarksTick(RSQSM_Down d)
	{
		let pmo = players[pn].mo;
		eye = pmo.pos + (0, 0, players[pn].viewheight);
		// the eased gaze (the RSQ Wheel's ring: a fifth of the way a tic)
		if (!gSet) { gYaw = pmo.angle; gPitch = pmo.pitch; gSet = true; }
		gYaw += Actor.deltaangle(gYaw, pmo.angle) * 0.2;
		gPitch += (pmo.pitch - gPitch) * 0.2;
		for (int i = 0; i < d.tMon.Size(); i++)
		{
			if (d.tPn[i] != pn || !d.tMon[i]) continue;
			let m = MarkOf(d.tMon[i]);
			if (!m)
			{
				if (d.tDead[i] != 0) continue;
				m = RSQSM_TMark(new("RSQSM_TMark"));
				m.mon = d.tMon[i]; m.icon = d.tIcon[i];
				marks.Push(m);
			}
			m.col = d.tCol[i];
			if (d.tDead[i] != 0 && !m.dead) { m.dead = true; m.deadTic = level.maptime; }
		}
		Vector3 gaze = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		for (int i = marks.Size() - 1; i >= 0; i--)
		{
			let m = marks[i];
			if (!m.mon || (m.dead && level.maptime - m.deadTic > 6) || (!d.IsTarget(m.mon) && !m.dead))
			{
				DropMark(m); marks.Delete(i); continue;
			}
			Vector3 ctr = m.mon.pos + (0, 0, m.mon.height * 0.5);
			Vector3 to = ctr - eye;
			double dist = max(1.0, to.Length());
			Vector3 dir = to / dist;
			double off = acos(clamp(dir dot gaze, -1.0, 1.0));
			bool sight = pmo.CheckSight(m.mon, SF_IGNOREVISIBILITY);
			// the crosshair: in view and in sight; it assembles each time it comes up
			bool want = !m.dead ? (sight && off <= VIEW_DEG) : m.shown;
			if (want && !m.shown) m.lockTic = level.maptime;
			m.shown = want;
			if (want) Crosshair(m, ctr, dir, m.dead ? 1.0 - (level.maptime - m.deadTic) / 6.0 : 1.0);
			else Off(m.xhair);
			// the edge arrows or the trail
			int mode = m.dead ? 0 : (off > TRAIL_DEG ? 1 : 2);
			if (mode != m.mode)
			{
				if (mode == 1) m.edgeTic = level.maptime;
				if (mode == 2) m.trailTic = level.maptime;
				m.mode = mode;
			}
			if (mode == 1) Edge(m, dir);
			// the trail, until the crosshair has assembled on it; then it fades out (owner 07:47)
			double ta = 1.0;
			if (m.shown && !m.dead) ta = clamp(1.0 - (level.maptime - (m.lockTic + ASM_LAST)) / double(TRAIL_FADE), 0.0, 1.0);
			if (mode == 2 && ta > 0) Trail(m, ctr, ta); else HideTrail(m);
		}
	}

	// THE CROSSHAIR: one still panel over the monster (its middle, just in front of it), the assembly in its frames
	void Crosshair(RSQSM_TMark m, Vector3 ctr, Vector3 dir, double fade)
	{
		m.xhair = Need(m.xhair);
		int f = min(ASM_LAST, level.maptime - m.lockTic);
		if (RSQSM_A11y.Photo() && f >= 11) f = ASM_LAST;     // Photosensitive Mode: no flash ring
		Skin(m.xhair, String.Format("RSPA%02d%02d", m.icon, f));
		// the icon 3/4 of the monster's height across, the frame twice the icon; a fixed size in the world
		double sz = max(40.0, m.mon.height * 0.75) * 2.0;
		Vector3 p = ctr - dir * (m.mon.radius + 4);
		PutAt(m.xhair, p, sz, sz, 0);
		Shade(m.xhair, m.col, clamp(fade, 0.0, 1.0));
	}

	// THE EDGE ARROWS' DIRECTION (drawn on the HUD, downhud.zs): the way to turn, on the screen, round the EASED gaze (so the
	// arrows swing round with the RSQ Wheel's deliberate easing as you turn); straight behind: at the bottom, pointing down
	void Edge(RSQSM_TMark m, Vector3 dir)
	{
		double gp = -gPitch;
		Vector3 gr = (sin(gYaw), -cos(gYaw), 0);
		Vector3 gu = (-cos(gYaw) * sin(gp), -sin(gYaw) * sin(gp), cos(gp));
		double xr = dir dot gr, yu = dir dot gu;
		bool behind = abs(Actor.deltaangle(gYaw, atan2(dir.y, dir.x))) > 150.0;
		double ang = atan2(yu, xr);
		if (behind || (abs(xr) < 0.001 && abs(yu) < 0.001)) ang = -90;
		m.eAng = ang;
	}

	// THE TRAIL: six chevrons fixed in the world at eye level, from just in front of you (40 units ahead along your view's
	// heading, at eye level) to the target's middle (where its crosshair sits), each turned toward it as you see it; a
	// brightness wave running toward the target (frame t - 3 i); none placed past a wall (each point is traced from the eye)
	void Trail(RSQSM_TMark m, Vector3 ctr, double alpha)
	{
		let pmo = players[pn].mo;
		Vector3 st = eye + (cos(pmo.angle), sin(pmo.angle), 0) * 40.0;
		Vector3 to = ctr - st;
		double len = to.Length();
		if (len < 8) { HideTrail(m); return; }
		Vector3 en = ctr - to / len * min(len * 0.5, max(40.0, m.mon.height * 0.75) * 0.6);   // short of the crosshair
		int t = RSQSM_A11y.Photo() ? 6 : level.maptime - m.trailTic;
		double w = TRAIL_H * 16.0 / 22.0;
		for (int i = 0; i < 6; i++)
		{
			Vector3 p = st + (en - st) * (i / 5.0);
			Vector3 fe = p - eye;
			double fl = fe.Length();
			FLineTraceData lt;
			if (fl > 1 && pmo.LineTrace(atan2(fe.y, fe.x), fl, -atan2(fe.z, max(0.001, fe.xy.Length())), TRF_THRUACTORS, players[pn].viewheight, 0, 0, lt)
				&& lt.HitType != FLineTraceData.TRACE_HitNone && lt.Distance < fl - 2)
			{
				Off(m.tF[i]); Off(m.tC[i]); Off(m.tL[i]); continue;
			}
			Face(p, eye);
			Vector3 v = ctr - p;
			double roll = atan2(v dot u, v dot r);
			int f = RSQSM_A11y.Photo() ? 6 : ((t - 3 * i) % TRAIL_FR + TRAIL_FR) % TRAIL_FR;
			m.tF[i] = Need(m.tF[i], "RSPTRF"); m.tC[i] = Need(m.tC[i]); m.tL[i] = Need(m.tL[i]);
			Skin(m.tC[i], String.Format("RSPTC%02d", f)); Skin(m.tL[i], String.Format("RSPTL%02d", f));
			PutAt(m.tF[i], p, w, TRAIL_H, roll, 0); Plain(m.tF[i], alpha);
			PutAt(m.tC[i], p, w, TRAIL_H, roll, 1); Shade(m.tC[i], m.col, alpha);
			PutAt(m.tL[i], p, w, TRAIL_H, roll, 2); Shade(m.tL[i], Light(m.col), alpha, true);
		}
	}
	void HideTrail(RSQSM_TMark m) { for (int i = 0; i < 6; i++) { Off(m.tF[i]); Off(m.tC[i]); Off(m.tL[i]); } }
}
