// RIG ONLY. Robot off hand for the magazine (vreload), pump (rsr_pump) and underbarrel (rsr_m203) reloads.
// rsprobe_robot: 2 magazine, 3 pump, 4 underbarrel. Gun hand at pitch 0 (gun frame lined up with the room).
// Every step steers a point of what the hand holds onto the reload's own line by feedback, after a search for the
// hand turn that lines it up (the reload's own angle).
class RSPROBE_Bot : EventHandler
{
	int t, k, mode, gi, P, Y, bP, bY, last, stage, stageTic;
	double bA;
	Vector3 cmd;
	bool cmdSet;
	bool found;	// suite: a hand turn found once is kept for every later step of the run (no search per shell)
	int fP, fY, foundFor;

	static void SetPose(Vector3 flu, double pit, double yaw)
	{
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
	static void Grip(double v) { let c = CVar.FindCVar('qzt_lgrip'); if (c) c.SetFloat(v); }
	static void Release() { let c = CVar.FindCVar('qzt_lhand'); if (c) c.SetString(""); Trig(-1); Grip(-1); }

	// feedback: move the commanded controller so `now` (a point the hand carries, gun frame) goes to `want`
	void Steer(Vector3 now, Vector3 want, Vector3 ctl, double gain = 0.5)
	{
		if (!cmdSet) { cmd = ctl; cmdSet = true; }
		cmd += (want - now) * gain;
		SetPose(cmd, P, Y);
	}
	void Place(Vector3 ctl) { cmd = ctl; cmdSet = true; SetPose(cmd, P, Y); }
	void SetStage(int ns) { stage = ns; stageTic = level.maptime; k = 0; cmdSet = false; }
	int Age() { return level.maptime - stageTic; }

	// orientation search: 13x13 at 15 deg then 11x11 at 2 deg, scoring ang() two tics after each pose.
	// Returns true while searching. `a` is the angle measured this tic.
	bool Search(double a, Vector3 park)
	{
		if (mode == 0) { gi = 0; bA = 999; mode = 1; }
		if (mode == 3) return false;
		bool coarse = mode == 1;
		int n = coarse ? 169 : 121, w = coarse ? 13 : 11;
		if (gi > 0 && (t % 2) == 0 && a < bA) { bA = a; bP = P; bY = Y; }
		if ((t % 2) == 0) gi++;
		if (gi > n)
		{
			if (coarse) { mode = 2; gi = 0; int cp = bP, cy = bY; bP = cp; bY = cy; return true; }
			mode = 3; P = bP; Y = bY; found = true; fP = bP; fY = bY;
			Console.Printf("BOT t%d hand turn pitch %d yaw %d (%.1f deg)", level.maptime, P, Y, bA);
			return false;
		}
		int g = max(gi - 1, 0);
		if (coarse) { P = -90 + 15 * (g / w); Y = -90 + 15 * (g % w); }
		else { P = bP - 10 + 2 * (g / w); Y = bY - 10 + 2 * (g % w); }
		if (!coarse && gi == 1) { P = bP - 10; Y = bY - 10; }
		Place(park);
		return true;
	}
	void Seed()
	{
		let sd = CVar.FindCVar('rsprobe_seed');
		if (sd && sd.GetString() != "")
		{
			Array<String> q;
			sd.GetString().Split(q, " ", TOK_SKIPEMPTY);
			if (q.Size() >= 2) { bP = q[0].ToInt(); bY = q[1].ToInt(); P = bP; Y = bY; mode = 3; gi = 0; bA = 999; return; }
		}
		if (found) { bP = fP; bY = fY; P = bP; Y = bY; mode = 3; gi = 0; bA = 999; return; }
		mode = 0;
	}

	override void WorldTick()
	{
		let on = CVar.FindCVar('rsprobe_robot');
		int r = on ? on.GetInt() : 0;
		if (r < 2) { if (last >= 2) Release(); last = r; return; }
		if (r != foundFor) { found = false; foundFor = r; }	// a hand turn is kept per job (magazine, pump, underbarrel), never across them
		last = r;
		let mo = players[consoleplayer].mo;
		if (!mo) return;
		t++;
		if (r == 2) Mag(mo);
		else if (r == 3) Pump(mo);
		else if (r == 4) M203(mo);
	}

	// ---------------------------------------------------------------- magazine
	void Mag(PlayerPawn mo)
	{
		let s = RSR_ReloadHandler.StateOf(mo);
		if (!s || s.phase == RSR.IDLE || s.phase == RSR.DONE || s.phase == RSR.DROP) { Release(); stage = 0; return; }
		int i = s.gun;
		Vector3 away = RSR_Guns.Well(i) + (-10, 30, -25);
		if (s.phase == RSR.EMPTY)
		{
			if (stage != 1) { SetStage(1); Seed(); }
			Place(away);
			Trig(Age() % 8 < 4 ? 0 : 1);
			return;
		}
		if (s.phase == RSR.CARRY || s.phase == RSR.INSERT)
		{
			Trig(1);
			if (stage != 2) { SetStage(2); }
			double dd, side, ang;
			[dd, side, ang] = s.MagAtWell();
			Vector3 top = s.OffPoint(RSR_Guns.TopInHand(i));
			Vector3 park = RSR_Guns.Well(i) + RSR_Guns.Axis(i) * (RSR_Guns.Mouth(i) + 15) - (top - s.offLocal);
			if (Search(ang, park)) return;
			k++;
			double want = k < 25 ? RSR_Guns.Mouth(i) + 3 : max(RSR_Guns.Mouth(i) + 3 - (k - 25) * 0.7, -1.5);
			Steer(top, RSR_Guns.Well(i) + RSR_Guns.Axis(i) * want, s.offLocal);
			if (k % 10 == 0) Console.Printf("BOT t%d mag %.1f out %.1f off %.0f deg", level.maptime, dd, side, ang);
			return;
		}
		if (s.phase == RSR.SEATED || s.phase == RSR.CHARGE)
		{
			if (stage != 3) { SetStage(3); P = 0; Y = 0; }
			Vector3 palm = s.OffPoint(RSR.PalmGrab());
			Trig(Age() < 8 || Age() > 30 && Age() < 34 ? 0 : (Age() >= 34 ? 1 : 0));
			Steer(palm, RSR_Guns.Grab(i), s.offLocal);
			if (Age() > 60) SetStage(3);
			return;
		}
		if (s.phase == RSR.PULL)
		{
			if (stage != 4) SetStage(4);
			Trig(1);
			k++;
			Vector3 palm = s.OffPoint(RSR.PalmGrab());
			Steer(palm, RSR_Guns.Grab(i) + RSR_Guns.Pull(i) * min(k * 0.8, RSR_Guns.Travel(i) + 2), s.offLocal);
			if (k > 20) Trig(0);
			return;
		}
		if (s.phase == RSR.RELEASED) Trig(0);
	}

	// ---------------------------------------------------------------- pump
	void Pump(PlayerPawn mo)
	{
		let s = RSP_Handler.StateOf(mo);
		if (level.maptime >= 142 && level.maptime <= 149)
			Console.Printf("BOTE t%d attack %.1f %.1f %.1f ang %.1f pit %.1f | off %.1f %.1f %.1f | btn %d wstate %d", level.maptime, mo.AttackPos.x - mo.pos.x, mo.AttackPos.y - mo.pos.y, mo.AttackPos.z - mo.pos.z, mo.AttackAngle, mo.AttackPitch, mo.OffhandPos.x - mo.pos.x, mo.OffhandPos.y - mo.pos.y, mo.OffhandPos.z - mo.pos.z, mo.player.cmd.buttons, mo.player.WeaponState);
		if (s && s.geo && level.maptime >= 140 && level.maptime <= 150)
			Console.Printf("BOTX t%d mode %d hand %d near %d pumpGrab %d press %d down %d dist %.1f palm %.1f gun %d off %.1f %.1f %.1f steady %d", level.maptime, s.mode, s.hand, s.NearPump(RSR_Assist.PumpGrab(mo.player, s.gun)), s.pumpGrab, s.grabPress, s.grabDown, s.PumpDist(s.offLocal), s.PumpDist(s.geo.OffPoint(RSR.PalmGrab())), s.gun, s.offLocal.x, s.offLocal.y, s.offLocal.z, RSVR_VRHand.Steadied(mo));
		if (!s || s.mode == RSP.NONE || !s.geo) { Release(); stage = 0; return; }
		int i = s.gun;
		let w = mo.player.ReadyWeapon;
		Inventory mag = w ? (w.Ammo1 && w.Ammo2 ? (w.Ammo1.MaxAmount <= w.Ammo2.MaxAmount ? w.Ammo1 : w.Ammo2) : w.Ammo2) : null;
		let wantN = CVar.FindCVar('rsprobe_shells');
		int want = wantN ? wantN.GetInt() : 99;
		bool loadMore = s.mode == RSP.LOAD && mag && mag.Amount < mag.MaxAmount && s.shells < want;
		if (s.hand == RSP.EMPTY && !loadMore)
		{
			// the stroke: the controller to the pump's grab point, take it, back, forward
			if (stage < 10) { SetStage(10); P = 0; Y = 0; }
			Vector3 g = RSP_Guns.Grab(i);
			if (stage == 10)
			{
				Trig(0);
				Steer(s.offLocal, g + (4.3, 0, -22), s.offLocal);	// the engine's off-hand position jumps by about this when the trigger goes down
				if (Age() > 20) { SetStage(11); Console.Printf("BOT t%d at the pump: controller %.1f cm, palm %.1f cm off its track (grab within %.1f)", level.maptime, s.PumpDist(s.offLocal), s.PumpDist(s.geo.OffPoint(RSR.PalmGrab())), RSR_Assist.PumpGrab(mo.player, i)); }
				return;
			}
			if (stage == 11)
			{
				let gm = CVar.FindCVar('rsprobe_pumpgrip');
				if (gm && gm.GetInt()) { Trig(0); Grip(1); } else Trig(1);
				k++;
				if (k < 6) Console.Printf("BOT t%d k%d near %d pumpGrab %d held %d grabDown %d press %d dist %.1f", level.maptime, k, s.NearPump(RSR_Assist.PumpGrab(mo.player, i)), s.pumpGrab, s.held, s.grabDown, s.grabPress, s.PumpDist(s.offLocal));
				double travel = RSP_Guns.Travel(i);
				double back = k < 4 ? 0 : (k < 4 + 12 ? (k - 4) * (travel + 1) / 12.0 : (k < 22 ? travel + 1 : max(travel + 1 - (k - 22) * (travel + 2) / 10.0, -1)));
				Steer(s.offLocal, g + RSP_Guns.Pull(i) * back, s.offLocal);
				if (k > 36) { Trig(0); Grip(0); SetStage(12); }
				return;
			}
			Trig(0);
			Place(g + (0, 30, -20));
			return;
		}
		if (s.hand == RSP.EMPTY)
		{
			if (stage != 1) { SetStage(1); Seed(); }
			Place(RSP_Guns.Port(i) + (-15, 30, -25));
			Trig(Age() % 8 < 4 ? 0 : 1);
			return;
		}
		// a shell in the hand: lined up below the underside port, then pushed in along Push
		Trig(1);
		if (stage != 2) SetStage(2);
		double sv, side, ang;
		Vector3 lv;
		[sv, side, ang, lv] = s.ShellAtPort0();
		Vector3 c = s.geo.OffPoint(RSP_Guns.ShellInHand(i));
		Vector3 park = RSP_Guns.Port(i) - RSP_Guns.Push(i) * 15 - (c - s.offLocal);
		if (Search(ang, park)) return;
		k++;
		double d = k < 25 ? -4 : min(-4 + (k - 25) * 0.6, RSP_Guns.Depth(i) + 1.5);
		Steer(c, RSP_Guns.Port(i) + RSP_Guns.Push(i) * d, s.offLocal);
		if (k % 10 == 0) Console.Printf("BOT t%d shell %.1f in %.1f off %.0f deg", level.maptime, sv, side, ang);
		if (k > 90) { mode = 0; SetStage(0); }
	}

	// ---------------------------------------------------------------- underbarrel
	void M203(PlayerPawn mo)
	{
		let s = RSM_State(RSK_M203Handler.Peek(mo));
		if (!s || !s.geo) { Release(); return; }
		int gn = s.gun;
		// tube line in the gun frame (the rifle's own frame -> gun frame)
		Vector3 rear = RSM_Geo.FromGun(gn, (RSM_Geo.TubeRear(gn) + s.pull, RSM_Geo.AxisL(gn), RSM_Geo.AxisU(gn)));
		Vector3 front = RSM_Geo.FromGun(gn, (RSM_Geo.TubeFront(gn) + s.pull, RSM_Geo.AxisL(gn), RSM_Geo.AxisU(gn)));
		Vector3 mid = (rear + front) / 2;
		Vector3 fwd = (front - rear) / max((front - rear).Length(), 0.001);
		Vector3 palm = s.geo.OffPoint(RSR.PalmGrab());
		if (t % 20 == 0) Console.Printf("BOTM t%d active %d gun %d stage %d steady %d unl %d pull %.1f open %d hand %d loaded %d tube %.1f", level.maptime, s.active, gn, stage, RSVR_VRHand.Steadied(mo), s.unlatched, s.pull, s.isOpen, s.hand, mo.CountInv('RFGLoaded'), s.TubeDist(RSM_Geo.ToGun(gn, palm)));
		if (mo.CountInv('RFGLoaded') > 0 && !s.isOpen) { Release(); stage = 0; return; }
		if (!s.isOpen)
		{
			// steadied on the tube, latch with the trigger, push it forward to open
			if (stage < 20) { SetStage(20); P = 0; Y = 0; }
			Grip(1);
			if (stage == 20) { Trig(0); Steer(palm, mid, s.geo.offLocal); if (Age() > 20) SetStage(21); return; }
			if (stage == 21) { Trig(1); Steer(palm, mid, s.geo.offLocal); if (Age() > 3) { SetStage(22); cmdSet = true; } return; }
			// steadied: the gun aims at this hand, so the hand just moves forward (open loop)
			k++;
			Trig(s.pull > 1.5 || k > 30 ? 0 : 1);		// the latch held down until the tube is moving
			SetPose(cmd + (min(k * 0.8, RSM_Geo.TravelOf(gn) + 3), 0, 0), P, Y);
			if (k > 40) SetStage(20);
			return;
		}
		Grip(0);
		if (!s.roundIn)
		{
			if (s.hand == RSM.EMPTY)
			{
				if (stage != 30) { SetStage(30); Seed(); }
				Place(mid + (-10, 30, -25));
				Trig(Age() % 8 < 4 ? 0 : 1);
				return;
			}
			// a round: its middle onto the tube axis behind the breech, nose forward, then pushed home
			Trig(1);
			if (stage != 31) SetStage(31);
			Vector3 m = s.geo.OffPoint(RSM_Geo.RoundInHand());
			Vector3 nose = RSM_Geo.DirToGun(gn, s.geo.OffDirInGun(RSM_Geo.RoundAxisInHand()));
			double ang = acos(clamp(nose.x, -1, 1));
			Vector3 seat = RSM_Geo.FromGun(gn, (RSM_Geo.TubeRear(gn) + s.pull + RSM_Geo.RoundSeat(gn) + RSM_Geo.RoundLen(gn) / 2, RSM_Geo.AxisL(gn), RSM_Geo.AxisU(gn)));
			Vector3 park = seat - fwd * 15 - (m - s.geo.offLocal);
			if (Search(ang, park)) return;
			k++;
			double d = k < 25 ? -6 : min(-6 + (k - 25) * 0.5, 1.5);
			Steer(m, seat + fwd * d, s.geo.offLocal);
			if (k % 10 == 0) Console.Printf("BOT t%d round hand %d %.0f deg", level.maptime, s.hand, ang);
			if (k > 90) { mode = 0; SetStage(0); }
			return;
		}
		// loaded and open: take the tube and pull it shut
		if (stage < 40) { SetStage(40); P = 0; Y = 0; }
		if (stage == 40) { Trig(0); Grip(0); Steer(palm, mid, s.geo.offLocal); if (Age() > 20) SetStage(41); return; }
		Trig(1);
		k++;
		SetPose(cmd - (min(k * 0.8, RSM_Geo.TravelOf(gn) + 3), 0, 0), P, Y);
		if (k > 40) { Trig(0); SetStage(40); }
	}
}
