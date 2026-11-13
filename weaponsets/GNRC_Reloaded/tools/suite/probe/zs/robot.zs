// RIG ONLY. A robot off hand for the break-open reload (rsr_break.zs). It takes a round, finds the hand turn that
// lines the round up with an empty chamber's bore (searching pitch / yaw, reading the reload's own AtChamber), then
// slides the tip down the bore until it seats. Poses assume both controllers at pitch 0 (gun frame = room: rig.lpose).
class RSPROBE_Robot : EventHandler
{
	int step, k, mode, gi, bestP, bestY, lastCh;
	double bestA;
	Vector3 cmd;
	bool cmdSet;
	static void Pose(Vector3 flu, double pit = 0, double yaw = 0)
	{
		// relative to wherever the gun hand is (qz_rhand), at pitch 0
		double rx = 0.25, ry = 1.3, rz = -0.3;
		let rh = CVar.FindCVar('qz_rhand');
		if (rh)
		{
			Array<String> pp;
			rh.GetString().Split(pp, " ", TOK_SKIPEMPTY);
			if (pp.Size() >= 3) { rx = pp[0].ToDouble(); ry = pp[1].ToDouble(); rz = pp[2].ToDouble(); }
		}
		let c = CVar.FindCVar('qzt_lhand');
		if (c) c.SetString(String.Format("%.4f %.4f %.4f %.1f %.1f 0", rx - flu.y / 100.0, ry + flu.z / 100.0, rz - flu.x / 100.0, pit, yaw));
	}
	static void Trig(double v) { let c = CVar.FindCVar('qzt_ltrigger'); if (c) c.SetFloat(v); }
	static void Off() { let c = CVar.FindCVar('qzt_lhand'); if (c) c.SetString(""); Trig(-1); }

	override void WorldTick()
	{
		let on = CVar.FindCVar('rsprobe_robot');
		if (!on || on.GetInt() == 0) return;
		let mo = players[consoleplayer].mo;
		if (!mo) return;
		let s = RSB_Handler.StateOf(mo);
		if (!s || s.phase != RSB.OPEN) { if (step) Off(); step = 0; mode = 0; return; }
		int fr = -1;
		for (int c = 0; c < s.nch; c++) if (s.ch[c] == RSB.EMPTY) { fr = c; break; }
		if (fr < 0) { Off(); step = 0; mode = 0; return; }
		if (s.hand == RSB.FREE)
		{
			let sd = CVar.FindCVar('rsprobe_seed');
			if (sd && sd.GetString() != "")
			{
				Array<String> q;
				sd.GetString().Split(q, " ", TOK_SKIPEMPTY);
				if (q.Size() >= 2) { bestP = q[0].ToInt(); bestY = q[1].ToInt(); }
			}
			Pose((-10, 45, -20));
			Trig(step % 6 < 3 ? 0 : 1);
			step++;
			mode = (sd && sd.GetString() != "") ? 1 : 0; gi = 0; k = 0; bestA = 999;
			return;
		}
		Trig(1);
		step++;
		// the pose to test or use, and where the round's tip goes for it
		int P, Y;
		if (mode == 0)
		{
			// 13 x 13 grid, 15 degrees, 2 tics each: score the pose set two tics ago
			if (gi > 0 && (step % 2) == 0)
			{
				double ss, side, ang;
				[ss, side, ang] = s.AtChamber(fr);
				int pg = gi - 1;
				if (ang < bestA) { bestA = ang; bestP = -90 + 15 * (pg / 13); bestY = -90 + 15 * (pg % 13); }
			}
			if ((step % 2) == 0) gi++;
			if (gi > 169) { mode = 1; gi = 0; Console.Printf("ROBOT t%d grid best pitch %d yaw %d at %.0f deg", level.maptime, bestP, bestY, bestA); }
			P = -90 + 15 * ((gi - 1) / 13); Y = -90 + 15 * ((gi - 1) % 13);
			if (gi < 1) { P = 0; Y = 0; }
		}
		else if (mode == 1)
		{
			// refine: +-10 in 2 degree steps around the best
			int cx = bestP, cy = bestY;
			if (gi > 0 && (step % 2) == 0)
			{
				double ss, side, ang;
				[ss, side, ang] = s.AtChamber(fr);
				int pg = gi - 1;
				int tp = cx - 10 + 2 * (pg / 11), ty = cy - 10 + 2 * (pg % 11);
				if (ang < bestA) { bestA = ang; bestP = tp; bestY = ty; }
			}
			if ((step % 2) == 0) gi++;
			if (gi > 121) { mode = 2; k = 0; Console.Printf("ROBOT t%d fine best pitch %d yaw %d at %.1f deg", level.maptime, bestP, bestY, bestA); }
			P = cx - 10 + 2 * ((gi - 1) / 11); Y = cy - 10 + 2 * ((gi - 1) % 11);
			if (mode == 2) { P = bestP; Y = bestY; }
		}
		else { P = bestP; Y = bestY; }
		Vector3 b, t;
		[b, t] = s.RoundInHand();
		Vector3 tipOfs = t - s.offLocal;
		double dep = s.Depth(fr);
		double ss = mode == 2 ? (k < 25 ? dep + 4 : max(dep + 4 - (k - 25) * 0.6, -1.5)) : dep + 12;		// line up outside the mouth first, then push		// searching: well out of the bore
		Vector3 want = s.TipAt(fr, s.theta) + s.BoreAt(fr, s.theta) * ss;
		if (mode == 2)
		{
			// feedback: move the commanded hand by half of where the tip is off, every tic
			if (!cmdSet) { cmd = want - tipOfs; cmdSet = true; }
			cmd += (want - t) * 0.5;
			Pose(cmd, P, Y);
		}
		else
		{
			cmdSet = false;
			Pose(want - tipOfs, P, Y);
		}
		if (mode == 2)
		{
			k++;
			if (k % 6 == 0)
			{
				double a1, a2, a3;
				[a1, a2, a3] = s.AtChamber(fr);
				Console.Printf("ROBOT t%d chamber %d hand %d at %.1f out, %.1f off, %.0f deg", level.maptime, fr, s.hand, a1, a2, a3);
			}
			if (k > 90) mode = 0;
		}
	}
}
