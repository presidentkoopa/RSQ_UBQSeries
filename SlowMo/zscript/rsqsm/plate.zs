// RSQ_SlowMo -- THE DOWN PLATE, THE TARGET ICONS, THE OFF-VIEW TURN MARKERS (owner 2026-11-07, design/NEAR_DEATH.md v3 and
// its 05:51 / 05:53 / 05:58 decisions). Console player only; down.zs holds every number, this only draws.
//
// HOW IT IS DRAWN: the RSQ Wheel's way on stock QuestZDoom 17.3 (its wr_q_shim.zs, copied, nothing linked): unit quad
// models (RSQSM_PQuad) and glyph strips (RSQSM_PStrip8/12/24, one DoomFont cell per surface, skinned per surface) placed
// in the world every tic, turned to face the eye, coloured with the Shaded style (a white texture's alpha in any colour).
// NOT a canvas texture (my reading of "a canvas painted every frame on a quad"): the Wheel's own code measured a canvas
// drawn in a VR mode on 17.3 as black (wr_q_shim.zs header, the 17.3 rig), so the Wheel's cards are composed quads, and
// so is this plate.
//
// THE PLATE (low in view, eased after the body's yaw, pulled in before a wall):
//   left    "DOWN!" big, the job line ("REVENGE: <monster>", "+N" for more living targets), one icon slot a kill owed
//           (cracked when that target dies), the reward bar: three steps (thin, normal, tall; the tall right end drains
//           first), smooth drain every tic, each step breaking off and falling as it runs out (down.zs: shake, clunk,
//           rumble). The bar is the first living target's colour as a moving gradient.
//   right   "DEATH IN:" small, over a seven-segment SS:hh readout (unlit segments faint, the colon blinking).
// THE TARGET ICONS: the target's icon assembles over it (about 0.4 s: the ring spins and scales in, the outer pieces slide in
// from outside, the dot pops last, then a flash ring as it locks), in the target's colour, over its health bar.
// THE TURN MARKERS: a target outside the view shows its icon on a ring round the gaze (30 degrees out), in the direction to
// turn, with the chosen marker style (Turn Marker: A Framed Triangle, B Framed Fat Arrow, C Triple Chevron (default),
// D Triangle With Afterimages) pointing that way; straight behind: at the bottom, pointing down. It slides inward as you
// turn toward it; once the monster is in view the icon flies onto it and assembles there. No sound, no distance.
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

// one target's icon over the monster and its turn marker
class RSQSM_TMark play
{
	Actor mon;
	int icon, col, lockTic, mode;      // mode 0 off view (marker), 1 flying onto it, 2 locked on it
	int flyTic;
	Vector3 flyFrom;
	bool dead;
	int deadTic;
	Actor ring, outer, pdot, flash;
	Actor mIcon;
	Array<Actor> mFrame, mFill;        // the marker's pieces (C: three; D: one plus four ghosts in mFill after the first)
	int style;
	int fillFrame;
}

class RSQSM_Plate play
{
	int pn;
	double yaw;
	bool yawSet;
	Actor back, tab, accent, tabTop;
	Actor seg[28];
	Actor colon[2];
	Actor track[3], fall[3];
	Actor slice[24];
	Actor sDown, sJob, sDeath;
	String tDown, tJob, tDeath;
	Array<Actor> slot, crack;
	Array<RSQSM_TMark> marks;
	// this tic's basis
	Vector3 c, r, u, nrm, eye;
	double pYaw, pTilt;
	double shake;

	const PDIST = 56.0;      // how far in front of the eye
	const DROP_DEG = 22.0;   // how far below the eye line
	const PW = 36.0;
	const PH = 13.0;
	const LSTEP = 0.06;

	void Init(int n) { pn = n; }

	static Actor Q(Name cls = 'RSQSM_PQuad') { class<Actor> c = cls; return c ? Actor.Spawn(c, (0, 0, 0), NO_REPLACE) : null; }

	void Clear()
	{
		if (back) back.Destroy(); if (tab) tab.Destroy(); if (accent) accent.Destroy(); if (tabTop) tabTop.Destroy();
		for (int i = 0; i < 28; i++) if (seg[i]) seg[i].Destroy();
		for (int i = 0; i < 2; i++) if (colon[i]) colon[i].Destroy();
		for (int i = 0; i < 3; i++) { if (track[i]) track[i].Destroy(); if (fall[i]) fall[i].Destroy(); }
		for (int i = 0; i < 24; i++) if (slice[i]) slice[i].Destroy();
		if (sDown) sDown.Destroy(); if (sJob) sJob.Destroy(); if (sDeath) sDeath.Destroy();
		for (int i = 0; i < slot.Size(); i++) { if (slot[i]) slot[i].Destroy(); if (crack[i]) crack[i].Destroy(); }
		slot.Clear(); crack.Clear();
		for (int i = 0; i < marks.Size(); i++) DropMark(marks[i]);
		marks.Clear();
	}
	void DropMark(RSQSM_TMark m)
	{
		if (!m) return;
		if (m.ring) m.ring.Destroy(); if (m.outer) m.outer.Destroy(); if (m.pdot) m.pdot.Destroy(); if (m.flash) m.flash.Destroy();
		if (m.mIcon) m.mIcon.Destroy();
		for (int i = 0; i < m.mFrame.Size(); i++) if (m.mFrame[i]) m.mFrame[i].Destroy();
		for (int i = 0; i < m.mFill.Size(); i++) if (m.mFill[i]) m.mFill[i].Destroy();
		m.mFrame.Clear(); m.mFill.Clear();
	}

	// ---- placing ------------------------------------------------------------------------------------------------------
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
	// a quad centred at plate (x, y), w x h, layer steps toward the eye, rolled
	void Put(Actor a, double x, double y, double layer, double w, double h, double roll = 0)
	{
		if (!a) return;
		Vector3 at = c + r * (x + shake) + u * y + nrm * (layer * LSTEP);
		a.SetOrigin(at, true);
		a.angle = pYaw; a.pitch = -pTilt; a.roll = roll;
		a.scale = (max(w, 0.0001), max(h, 0.0001));
	}
	// a glyph strip: its left edge at plate x, cells of cw x ch
	void PutStrip(Actor a, double x, double y, double layer, double cw, double ch)
	{
		if (!a) return;
		Vector3 at = c + r * (x + shake) + u * y + nrm * (layer * LSTEP);
		a.SetOrigin(at, true);
		a.angle = pYaw; a.pitch = -pTilt; a.roll = 0;
		a.scale = (cw, ch);
	}
	static void SetText(Actor a, int cells, String txt)
	{
		txt = txt.MakeUpper();
		for (int k = 0; k < cells; k++)
		{
			String g = "RSPGBLNK";
			if (k < txt.Length())
			{
				int ch = txt.ByteAt(k);
				if (ch >= 33 && ch <= 95) g = String.Format("RSPG%03d", ch);
			}
			a.A_ChangeModel("", 0, "", "", k, "", g, CMDL_USESURFACESKIN);
		}
	}
	static int Mix(int a, int b, double k)
	{
		k = clamp(k, 0.0, 1.0);
		int rr = int(((a >> 16) & 255) * (1 - k) + ((b >> 16) & 255) * k);
		int gg = int(((a >> 8) & 255) * (1 - k) + ((b >> 8) & 255) * k);
		int bl = int((a & 255) * (1 - k) + (b & 255) * k);
		return (rr << 16) | (gg << 8) | bl;
	}

	// ---- every tic -----------------------------------------------------------------------------------------------------
	void Tick(RSQSM_Down d)
	{
		let pmo = players[pn].mo;
		if (!pmo) return;
		eye = pmo.pos + (0, 0, players[pn].viewheight);
		bool down = d.IsDown(pn);
		// the plate's place: eased after the body's yaw, low in view, pulled in before a wall
		if (!yawSet) { yaw = pmo.angle; yawSet = true; }
		yaw += Actor.deltaangle(yaw, pmo.angle) * 0.25;
		double dist = PDIST;
		FLineTraceData lt;
		if (pmo.LineTrace(yaw, PDIST + 8, DROP_DEG, TRF_THRUACTORS, players[pn].viewheight, 0, 0, lt) && lt.HitType != FLineTraceData.TRACE_HitNone)
			dist = clamp(lt.Distance - 8, 20.0, PDIST);
		c = eye + (cos(yaw) * cos(DROP_DEG), sin(yaw) * cos(DROP_DEG), -sin(DROP_DEG)) * dist;
		double sc = dist / PDIST;                 // a plate pulled in shrinks with it (same size in view)
		Face(c, eye);
		int st = d.shakeTic[pn];
		int sa = level.maptime - st;
		shake = (sa >= 0 && sa < 8 && !RSQSM_A11y.Photo()) ? sin(level.maptime * 137.0) * 0.5 * (1.0 - sa / 8.0) * sc : 0.0;
		// the target this plate names (the first one living), and its colour
		int first = -1, alive = 0, mine = 0;
		for (int i = 0; i < d.tMon.Size(); i++)
		{
			if (d.tPn[i] != pn) continue;
			mine++;
			if (d.tDead[i] != 0) continue;
			alive++;
			if (first < 0) first = i;
		}
		int col = first >= 0 ? d.tCol[first] : RSQSM_Down.DOWN_RED;
		if (!down) { Hide(); MarksTick(d); return; }

		// ---- the backdrop and the tab -------------------------------------------------------------------------------
		if (!back) back = Q();
		if (!tab) tab = Q();
		if (!accent) accent = Q();
		Put(back, 0, 0, 0, PW * sc, PH * sc); Shade(back, 0x050202, 0.62);
		Put(tab, 12.0 * sc, 0, 1, 11.0 * sc, 12.0 * sc); Shade(tab, 0x1A0606, 0.75);
		Put(accent, 0, (PH * 0.5 - 0.2) * sc, 1, PW * sc, 0.35 * sc); Shade(accent, col, 0.9);

		// ---- DOWN! and the job line ------------------------------------------------------------------------------------
		if (!sDown) { sDown = Q('RSQSM_PStrip8'); tDown = ""; }
		if (tDown != "DOWN!") { tDown = "DOWN!"; SetText(sDown, 8, tDown); }
		double ch = 3.4 * sc, cw = ch * 9.0 / 7.0;
		PutStrip(sDown, -17.0 * sc, 3.1 * sc, 2, cw, ch); Shade(sDown, 0xFF2A1A, 1.0);
		String job = "REVENGE";
		if (first >= 0 && d.tMon[first]) job = String.Format("REVENGE: %s", d.tMon[first].GetTag());
		if (alive > 1) job = job .. String.Format(" +%d", alive - 1);
		if (job.Length() > 24) job = job.Left(24);
		if (!sJob) { sJob = Q('RSQSM_PStrip24'); tJob = ""; }
		if (tJob != job) { tJob = job; SetText(sJob, 24, job); }
		double jw = min(1.75, 22.0 / max(1, int(job.Length()))), jh = jw * 7.0 / 9.0;
		PutStrip(sJob, -17.0 * sc, -0.2 * sc, 2, jw * sc, jh * sc); Shade(sJob, 0xE8E0D8, 1.0);

		// ---- the icon slots (one a kill owed) --------------------------------------------------------------------------
		int need = max(d.owed[pn], mine);
		while (slot.Size() < need) { slot.Push(Q()); crack.Push(Q()); if (crack[crack.Size() - 1]) Skin(crack[crack.Size() - 1], "RSPCRK"); }
		double step = min(2.7, 22.0 / max(1, need)), isz = min(2.4, step * 0.9);
		int si = 0;
		for (int i = 0; i < d.tMon.Size() && si < slot.Size(); i++)
		{
			if (d.tPn[i] != pn) continue;
			let s = slot[si];
			Skin(s, String.Format("RSPI%02dF", d.tIcon[i]));
			double x = (-17.0 + step * 0.5 + step * si) * sc, y = -2.9 * sc;
			Put(s, x, y, 2, isz * sc, isz * sc);
			Shade(s, d.tCol[i], (d.tDead[i] != 0) ? 0.35 : 1.0);
			Put(crack[si], x, y, 3, isz * sc * 1.05, isz * sc * 1.05);
			Shade(crack[si], 0xFFFFFF, (d.tDead[i] != 0) ? 0.95 : 0.0);
			si++;
		}
		while (si < slot.Size())
		{
			// owed, not spawned yet: the slot waits, dim
			Skin(slot[si], "RSPI01R");
			double x = (-17.0 + step * 0.5 + step * si) * sc;
			Put(slot[si], x, -2.9 * sc, 2, isz * sc, isz * sc);
			Shade(slot[si], col, 0.25);
			Shade(crack[si], 0xFFFFFF, 0.0);
			si++;
		}

		// ---- the reward bar ---------------------------------------------------------------------------------------------
		double e = d.Elapsed(pn), stp = RSQSM_Down.StepTics();
		static const double SH[] = { 2.2, 1.4, 0.8 };      // tall (right, drains first), normal, thin (left)
		static const double SX[] = { 1.3333, -6.0, -13.3333 };   // centres, the bar from -17 to 5
		double sw = 22.0 / 3.0, by = -5.7;
		for (int k = 0; k < 3; k++)
		{
			double rem = clamp((stp * (k + 1) - e) / stp, 0.0, 1.0);
			bool gone = (d.stepsGone[pn] & (1 << k)) != 0;
			if (!track[k]) track[k] = Q();
			double hy = by + SH[k] * 0.5;
			if (!gone) { Put(track[k], SX[k] * sc, hy * sc, 1, sw * sc * 0.98, SH[k] * sc); Shade(track[k], Mix(col, 0, 0.75), 0.85); }
			else
			{
				// broken off: it falls, turns and fades over a second
				int ft = level.maptime - d.stepTic[pn * 3 + k];
				double fk = clamp(ft / 35.0, 0.0, 1.0);
				Put(track[k], (SX[k] + fk * 2.5) * sc, (hy - 9.0 * fk * fk) * sc, 1, sw * sc * 0.98, SH[k] * sc, fk * 70);
				Shade(track[k], Mix(col, 0, 0.6), 0.85 * (1.0 - fk));
			}
			// the fill: 8 slices, the moving gradient, draining from the right
			for (int j = 0; j < 8; j++)
			{
				int si2 = k * 8 + j;
				if (!slice[si2]) slice[si2] = Q();
				double l = SX[k] - sw * 0.5 + sw * j / 8.0;
				double fillR = SX[k] - sw * 0.5 + sw * rem;
				double w0 = clamp(fillR - l, 0.0, sw / 8.0);
				if (w0 <= 0.001) { slice[si2].bInvisible = true; continue; }
				double g = 0.5 + 0.5 * sin(level.maptime * 9.0 - (l * 26.0));
				int sc2 = Mix(col, 0xFFFFFF, 0.08 + 0.32 * g);
				if (g < 0.2) sc2 = Mix(col, 0, 0.25);
				Put(slice[si2], (l + w0 * 0.5) * sc, hy * sc, 2, w0 * sc, SH[k] * 0.86 * sc);
				Shade(slice[si2], sc2, 1.0);
			}
		}

		// ---- DEATH IN: SS:hh --------------------------------------------------------------------------------------------
		if (!sDeath) { sDeath = Q('RSQSM_PStrip12'); tDeath = ""; }
		if (tDeath != "DEATH IN:") { tDeath = "DEATH IN:"; SetText(sDeath, 12, tDeath); }
		PutStrip(sDeath, 7.0 * sc, 4.3 * sc, 2, 1.08 * sc, 0.84 * sc); Shade(sDeath, 0xD0C8C0, 1.0);
		double secs = max(0.0, d.clk[pn] / TICRATE);
		int ss = min(99, int(secs)), hh = min(99, int((secs - int(secs)) * 100));

		static const double DX[] = { 8.3, 10.6, 13.3, 15.6 };
		static const int MASK[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };   // a b c d e f g
		double dw = 1.9, dh = 3.6, t = 0.38, dy = -0.6;
		int lit = 0xFF2A1A;
		for (int di = 0; di < 4; di++)
		{
			for (int s7 = 0; s7 < 7; s7++)
			{
				int idx = di * 7 + s7;
				if (!seg[idx]) seg[idx] = Q();
				double x = DX[di], y = dy, w = t, h = t;
				switch (s7)
				{
				case 0: y = dy + dh * 0.5; w = dw; break;
				case 1: x = DX[di] + dw * 0.5; y = dy + dh * 0.25; h = dh * 0.5; break;
				case 2: x = DX[di] + dw * 0.5; y = dy - dh * 0.25; h = dh * 0.5; break;
				case 3: y = dy - dh * 0.5; w = dw; break;
				case 4: x = DX[di] - dw * 0.5; y = dy - dh * 0.25; h = dh * 0.5; break;
				case 5: x = DX[di] - dw * 0.5; y = dy + dh * 0.25; h = dh * 0.5; break;
				case 6: w = dw; break;
				}
				Put(seg[idx], x * sc, y * sc, 3, w * sc, h * sc);
				int dq = di == 0 ? ss / 10 : (di == 1 ? ss % 10 : (di == 2 ? hh / 10 : hh % 10));
				bool on = (MASK[dq] & (1 << s7)) != 0;
				Shade(seg[idx], lit, on ? 1.0 : 0.12);
			}
		}
		bool blink = RSQSM_A11y.Photo() || ((level.maptime / 17) & 1) == 0;
		for (int k = 0; k < 2; k++)
		{
			if (!colon[k]) colon[k] = Q();
			Put(colon[k], 11.95 * sc, (dy + (k != 0 ? -0.85 : 0.85)) * sc, 3, 0.45 * sc, 0.45 * sc);
			Shade(colon[k], lit, blink ? 1.0 : 0.12);
		}
		MarksTick(d);
	}

	void Hide()
	{
		if (back) back.bInvisible = true; if (tab) tab.bInvisible = true; if (accent) accent.bInvisible = true;
		for (int i = 0; i < 28; i++) if (seg[i]) seg[i].bInvisible = true;
		for (int i = 0; i < 2; i++) if (colon[i]) colon[i].bInvisible = true;
		for (int i = 0; i < 3; i++) if (track[i]) track[i].bInvisible = true;
		for (int i = 0; i < 24; i++) if (slice[i]) slice[i].bInvisible = true;
		if (sDown) sDown.bInvisible = true; if (sJob) sJob.bInvisible = true; if (sDeath) sDeath.bInvisible = true;
		for (int i = 0; i < slot.Size(); i++) { if (slot[i]) slot[i].bInvisible = true; if (crack[i]) crack[i].bInvisible = true; }
	}

	// ---- THE ICONS OVER THE TARGETS, AND THE TURN MARKERS ---------------------------------------------------------------
	const VIEW_DEG = 38.0;     // in view: within this of the gaze (my reading of "in view": a comfortable cone)
	const RING_DEG = 30.0;     // the markers' ring: the edge of comfortable view
	const RING_D = 48.0;
	const ASM_TICS = 14;       // ~0.4 s (Assemble)
	const FLY = 8;

	RSQSM_TMark MarkOf(Actor m)
	{
		for (int i = 0; i < marks.Size(); i++) if (marks[i] && marks[i].mon == m) return marks[i];
		return null;
	}
	static int StyleNow(int pn)
	{
		let c = CVar.GetCVar("rsqsm_down_marker", players[pn]);
		return c ? clamp(c.GetInt(), 0, 3) : 2;
	}

	void MarksTick(RSQSM_Down d)
	{
		let pmo = players[pn].mo;
		// one mark per target of this player
		for (int i = 0; i < d.tMon.Size(); i++)
		{
			if (d.tPn[i] != pn || !d.tMon[i]) continue;
			let m = MarkOf(d.tMon[i]);
			if (!m)
			{
				if (d.tDead[i] != 0) continue;
				m = RSQSM_TMark(new("RSQSM_TMark"));
				m.mon = d.tMon[i]; m.icon = d.tIcon[i]; m.col = d.tCol[i]; m.mode = -1; m.style = -1;
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
			Vector3 top = m.mon.pos + (0, 0, m.mon.height + 26);
			Vector3 to = top - eye;
			double dist = max(1.0, to.Length());
			Vector3 dir = to / dist;
			double off = acos(clamp(dir dot gaze, -1.0, 1.0));
			bool inView = off <= VIEW_DEG && m.mon.CheckSight(pmo, SF_IGNOREVISIBILITY);
			if (m.mode == -1) { m.mode = inView ? 2 : 0; m.lockTic = level.maptime; }
			if (m.mode == 0 && inView) { m.mode = 1; m.flyTic = level.maptime; m.flyFrom = m.mIcon ? m.mIcon.pos : top; }
			if (m.mode == 2 && !inView && off > VIEW_DEG + 8) m.mode = 0;    // a little slack before it leaves again
			double fade = m.dead ? 1.0 - (level.maptime - m.deadTic) / 6.0 : 1.0;
			if (m.mode == 0) { HideIcon(m); Marker(m, gaze, dir, off, fade); continue; }
			HideMarker(m);
			if (m.mode == 1)
			{
				double k = (level.maptime - m.flyTic) / double(FLY);
				if (k >= 1.0) { m.mode = 2; m.lockTic = level.maptime; }
				else
				{
					if (!m.mIcon) { m.mIcon = Q(); Skin(m.mIcon, String.Format("RSPI%02dF", m.icon)); }
					Vector3 p = m.flyFrom + (top - m.flyFrom) * (k * k * (3 - 2 * k));
					Face(p, eye);
					double sz = clamp((p - eye).Length() * 0.06, 2.5, 40.0);
					m.mIcon.SetOrigin(p, true); m.mIcon.angle = pYaw; m.mIcon.pitch = -pTilt; m.mIcon.roll = 0;
					m.mIcon.scale = (sz, sz);
					Shade(m.mIcon, m.col, fade);
					continue;
				}
			}
			if (m.mIcon) m.mIcon.bInvisible = true;
			Assemble(m, top, dist, fade);
		}
	}

	// THE LOCK-ON: ring spins and scales in (0-6), the outer pieces slide in from outside (3-9), the dot pops (9-12), the
	// flash ring (12-20)
	void Assemble(RSQSM_TMark m, Vector3 top, double dist, double fade)
	{
		if (!m.ring) { m.ring = Q(); Skin(m.ring, String.Format("RSPI%02dR", m.icon)); }
		if (!m.outer) { m.outer = Q(); Skin(m.outer, String.Format("RSPI%02dO", m.icon)); }
		if (!m.pdot) { m.pdot = Q(); Skin(m.pdot, String.Format("RSPI%02dD", m.icon)); }
		if (!m.flash) { m.flash = Q(); Skin(m.flash, "RSPFLSH"); }
		Face(top, eye);
		double sz = clamp(dist * 0.06, 6.0, 48.0);
		int t = level.maptime - m.lockTic;
		double k;
		// ring
		k = clamp(t / 6.0, 0.0, 1.0);
		IconPart(m.ring, top, 0, sz * (0.2 + 0.8 * k), (1.0 - k) * 180.0, m.col, k * fade);
		// outer
		k = clamp((t - 3) / 6.0, 0.0, 1.0);
		IconPart(m.outer, top, 1, sz * (2.2 - 1.2 * k * (2 - k)), 0, m.col, (t >= 3 ? k : 0.0) * fade);
		// dot
		k = clamp((t - 9) / 3.0, 0.0, 1.0);
		double ds = t < 9 ? 0.0 : (k < 0.6 ? 1.4 * k / 0.6 : 1.4 - 0.4 * (k - 0.6) / 0.4);
		IconPart(m.pdot, top, 2, sz * max(ds, 0.01), 0, m.col, (t >= 9 ? 1.0 : 0.0) * fade);
		// flash
		k = clamp((t - 12) / 8.0, 0.0, 1.0);
		double fa = (t >= 12 && t < 20) ? 0.9 * (1.0 - k) : 0.0;
		if (RSQSM_A11y.Photo()) fa *= 0.4;
		IconPart(m.flash, top, 3, sz * (1.0 + 0.8 * k), 0, m.col, fa * fade, true);
	}
	void IconPart(Actor a, Vector3 p, int layer, double sz, double roll, int col, double alpha, bool add = false)
	{
		if (!a) return;
		a.SetOrigin(p + nrm * (layer * 0.08), true);
		a.angle = pYaw; a.pitch = -pTilt; a.roll = roll;
		a.scale = (max(sz, 0.001), max(sz, 0.001));
		Shade(a, col, alpha, add);
	}
	void HideIcon(RSQSM_TMark m)
	{
		if (m.ring) m.ring.bInvisible = true; if (m.outer) m.outer.bInvisible = true;
		if (m.pdot) m.pdot.bInvisible = true; if (m.flash) m.flash.bInvisible = true;
	}
	void HideMarker(RSQSM_TMark m)
	{
		for (int i = 0; i < m.mFrame.Size(); i++) if (m.mFrame[i]) m.mFrame[i].bInvisible = true;
		for (int i = 0; i < m.mFill.Size(); i++) if (m.mFill[i]) m.mFill[i].bInvisible = true;
	}

	// THE MOTION (owner 05:58): a ~0.85 s loop -- wind-up (back 2 px, 0.92 wide), the push (accelerating 9 px forward,
	// 1.22 wide, the fill flaring), overshoot and recoil, settle. Returns the offset in pixels, the width and the flare.
	static double, double, double MarkerMotion(double t)
	{
		double p = (t % 30.0) / 30.0;
		if (p < 0) p += 1.0;
		if (p < 0.35) { double k = p / 0.35; k = k * k * (3 - 2 * k); return -2.0 * k, 1.0 - 0.08 * k, 1.0; }
		if (p < 0.55) { double k = (p - 0.35) / 0.20; k = k * k; return -2.0 + 11.0 * k, 0.92 + 0.30 * k, 1.0 + 0.6 * k; }
		if (p < 0.70) { double k = (p - 0.55) / 0.15; return 9.0 + 1.5 * sin(k * 180.0), 1.22 - 0.25 * k, 1.6 - 0.5 * k; }
		double kk = (p - 0.70) / 0.30; kk = kk * kk * (3 - 2 * kk);
		return 9.0 * (1.0 - kk), 0.97 + 0.03 * kk, 1.1 - 0.1 * kk;
	}

	// THE TURN MARKER: the icon on the ring round the gaze, in the direction to turn; the marker beyond it pointing there
	void Marker(RSQSM_TMark m, Vector3 gaze, Vector3 dir, double off, double fade)
	{
		let pmo = players[pn].mo;
		// the gaze's right and up
		double gy = pmo.angle, gp = -pmo.pitch;
		Vector3 gr = (sin(gy), -cos(gy), 0);
		Vector3 gu = (-cos(gy) * sin(gp), -sin(gy) * sin(gp), cos(gp));
		double xr = dir dot gr, yu = dir dot gu;
		// straight behind by the turn it takes (yaw), not by the full 3D angle: the rig run of 11-07 had a target behind and
		// above, gaze a little down, drawn at the top pointing up
		bool behind = abs(Actor.deltaangle(pmo.angle, atan2(dir.y, dir.x))) > 150.0;
		double ang = atan2(yu, xr);
		if (behind || (abs(xr) < 0.001 && abs(yu) < 0.001)) ang = -90;   // straight behind: at the bottom, pointing down
		// slides inward as you turn toward it: the edge of the ring from behind, 70% of it as it comes into view
		double k = clamp((off - VIEW_DEG) / (180.0 - VIEW_DEG), 0.0, 1.0);
		double rad = RING_D * tan(RING_DEG) * (0.7 + 0.3 * k);
		Vector3 ctr = eye + gaze * RING_D;
		Vector3 p = ctr + (gr * cos(ang) + gu * sin(ang)) * rad;
		Face(p, eye);
		// the screen direction on this quad's own basis (the quad faces the eye; r and u are near the gaze's)
		double roll = ang;
		if (!m.mIcon) { m.mIcon = Q(); Skin(m.mIcon, String.Format("RSPI%02dF", m.icon)); }
		m.mIcon.SetOrigin(p, true); m.mIcon.angle = pYaw; m.mIcon.pitch = -pTilt; m.mIcon.roll = 0;
		m.mIcon.scale = (4.0, 4.0);
		Shade(m.mIcon, m.col, fade);
		// the marker pieces
		int style = StyleNow(pn);
		int pieces = style == 2 ? 3 : (style == 3 ? 1 : 1);
		int fills = style == 3 ? 5 : pieces;
		if (style != m.style)
		{
			for (int i = 0; i < m.mFrame.Size(); i++) if (m.mFrame[i]) m.mFrame[i].Destroy();
			for (int i = 0; i < m.mFill.Size(); i++) if (m.mFill[i]) m.mFill[i].Destroy();
			m.mFrame.Clear(); m.mFill.Clear();
			m.style = style; m.fillFrame = -1;
			for (int i = 0; i < pieces; i++) { let f = Q(); Skin(f, String.Format("RSPM%sF", Shape(style))); m.mFrame.Push(f); }
			for (int i = 0; i < fills; i++) m.mFill.Push(Q());
		}
		int ff = RSQSM_A11y.Photo() ? 0 : (level.maptime / 4) % 4;
		if (ff != m.fillFrame)
		{
			m.fillFrame = ff;
			for (int i = 0; i < m.mFill.Size(); i++) Skin(m.mFill[i], String.Format("RSPM%s%d", Shape(style), ff));
		}
		Vector3 dv = gr * cos(ang) + gu * sin(ang);      // outward, the way to turn
		double px = 3.0 / 24.0;                          // a marker 3 units for its 24 pixels
		double base = 3.4;                               // its centre beyond the icon
		double t = level.maptime - m.lockTic;
		bool calm = RSQSM_A11y.Photo();
		for (int i = 0; i < pieces; i++)
		{
			double o, wx, fl;
			[o, wx, fl] = MarkerMotion(calm ? 0.0 : t - i * 3);       // C: each a beat (~0.09 s) after the one behind
			Vector3 at = p + dv * (base + i * 1.9 + o * px);
			PutMarker(m.mFrame[i], at, roll, 3.0 * wx, 3.0, 0, 0xFFFFFF, fade, false);
			PutMarker(m.mFill[i], at, roll, 3.0 * wx, 3.0, 1, Brighten(m.col, fl), fade, true);
		}
		if (style == 3)
		{
			// D: four fading ghost copies behind it, only during the fast push
			double o, wx, fl;
			[o, wx, fl] = MarkerMotion(calm ? 0.0 : t);
			double phs = ((t % 30.0) / 30.0);
			bool push = !calm && phs >= 0.35 && phs < 0.62;
			for (int g = 1; g < 5; g++)
			{
				Vector3 at = p + dv * (base + (o - g * 2.2) * px);
				double ga = g == 1 ? 0.5 : (g == 2 ? 0.35 : (g == 3 ? 0.22 : 0.12));
				PutMarker(m.mFill[g], at, roll, 3.0 * wx, 3.0, 1, m.col, push ? ga * fade : 0.0, true);
			}
		}
	}
	static String Shape(int style) { return style == 1 ? "B" : (style == 2 ? "C" : "A"); }
	static int Brighten(int col, double k) { return k <= 1.0 ? col : Mix(col, 0xFFFFFF, clamp((k - 1.0) * 0.6, 0.0, 0.6)); }
	void PutMarker(Actor a, Vector3 at, double roll, double w, double h, int layer, int col, double alpha, bool shaded)
	{
		if (!a) return;
		a.SetOrigin(at + nrm * (layer * 0.05), true);
		a.angle = pYaw; a.pitch = -pTilt; a.roll = roll;
		a.scale = (w, h);
		if (shaded) Shade(a, col, alpha);
		else Plain(a, alpha);
	}
}
