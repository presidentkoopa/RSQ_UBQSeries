// RSR-PUMP: hand-loaded shells and a hand-worked pump on the pump shotguns (BD22 Shot_Gun,
// Vanilla VR Plus VR_Shotgun), on the real VR reload's plumbing (rsr/vreload.zs). QuestZDoom 17.3,
// no engine changes (team/reload_pump/MERGE.md).
//
// Shells. The set's own reload checks start it: the weapon's hook comes after them (RSP_LoadStart).
// The off hand takes one shell with a grab away from the gun: the gun's own shell surface, held in
// Ermac's one-shell hold (ammo_hand frame 1). It goes in only at the loading port: its middle on the
// port's line, its crimp end pointing along it, and the hand pushes it home along the line. Home,
// the weapon runs the set's own per-shell step (one shell of ammo, with the set's own checks) and
// the set's own sound plays. Let go before it is home and it drops. The set's own checks end the
// reload (full, out of shells), as do fire, a full pump stroke and switching weapons.
//
// Pump. After each shot, and to chamber after loading an empty gun, the weapon's hook (after the
// set's own checks) asks whether the off hand is on the pump: steadied by the engine with the off
// controller at the pump, or the reload grab taken on the pump and held. If it is, the hand works
// it: the pump (its own surface) follows the hand along its track; at the back the set's own back
// sound plays and the spent shell comes out the set's way; forward again, the set's forward sound,
// and the gun is ready, never sooner than the set's own refire. Short strokes do nothing. With the
// hand off the pump, the set's own automatic pump runs unchanged.
//
// Input (the team's rule). The off TRIGGER (rsr_grab_buttons) grabs anywhere. The off GRIP grabs
// only where its press cannot start the engine's steadying: the off hand 50 cm or more from the gun
// hand, or vr_two_handed_weapons 0. A steadied grip is never a grab; steadied with the off controller
// at the pump is "the hand on the pump". Nothing here changes vr_two_handed_weapons.
//
// Positions: cm in the weapon controller's frame, F forward, L left, U up (rsr_pump_guns.zs).

class RSP abstract
{
	// layers (rsq/hands.zs owns 2100, 2101, 2200; rsr/vreload.zs 2102-2104, 2201; the break-open
	// reload (team/reload_break) 2105-2111, 2202)
	const PUMP = 2120;			// RSR_GunParts (main controller): the pump, where the hand has it
	const BOLT = 2121;			// RSR_GunParts: the bolt that moves with it (BD22)
	const SHELL = 2122;			// RSR_GunParts: the shell going in at the loading port
	const EJECT = 2123;			// RSR_GunParts: the set's own ejected shell (V+: its own frames)
	const HANDSHELL = 2210;		// RSQ_Hands (off controller): the shell in the hand
	const LAYER_FIRST = 2120;
	const LAYER_LAST = 2123;

	// what the off hand is doing for the gun
	const NONE = 0;
	const LOAD = 1;				// the weapon waits in its loading loop
	const PUMPING = 2;			// the weapon waits for the hand's pump stroke
	// the hand while loading
	const EMPTY = 0;
	const CARRY = 1;			// a shell in the hand
	const INSERT = 2;			// the shell in the port, as far as the hand pushes it

	const WEAPONTOP = 32;

	// cm, degrees
	const STEADY_CM = 50.0;		// the engine steadies on a grip pressed this close to the gun hand
	const STEADY_MARGIN = 1.0;	// ...so the grip grabs only this much further out
	const POUCH_MIN = 20.0;		// a shell is taken at least this far from the loading port
	const POUCH_LOW = 40.0;		// rsr_pouch 1: this far below the eyes
	const PUMP_NEAR = 8.0;		// the hand within this of the pump's track: on the pump
	const PUMP_LEAVE = 12.0;	// further than this: off it
	const BACK = 0.85;			// of the travel: at the back (the spent shell out)
	const FRONT = 0.15;			// of the travel: forward again (ready)
	const SPRING = 4.0;			// cm a tic a pump let go short of the back goes forward
	const ENTER_SIDE = 4.5;		// the shell's middle within this of the port's line goes in
	const ENTER_BEHIND = 8.0;	// ...from up to this far behind the port (it is led onto the line)
	const ENTER_AHEAD = 1.0;	// ...and no further in than this
	const ENTER_ANGLE = 35.0;	// ...its crimp end within this of the line's direction
	const LEAVE_SIDE = 6.0;		// further off the line than this: back in the hand
	const LEAVE_BEHIND = 10.0;	// pulled back further than this: back in the hand
	const SEAT = 0.6;			// home within this
	const EJECT_TICS = 6;

	static String ModeName(int m)
	{
		static const String n[] = { "NONE", "LOAD", "PUMPING" };
		return m >= 0 && m < n.Size() ? n[m] : "?";
	}

	static String HandName(int h)
	{
		static const String n[] = { "EMPTY", "CARRY", "INSERT" };
		return h >= 0 && h < n.Size() ? n[h] : "?";
	}

	clearscope static bool TestCvarOn(Name n)	// a cvar that is ON unless set to 0
	{
		let cv = CVar.FindCVar(n);
		return !cv || cv.GetInt() != 0;
	}

	clearscope static bool TestCvar(Name n)
	{
		let cv = CVar.FindCVar(n);
		return cv && cv.GetBool();
	}

	// the engine's two-hand steadying holds the gun (rsp_test_steady stands in for it headless;
	// that cvar exists only in the test pack)
	static bool Steadied(PlayerPawn mo)
	{
		return (mo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0 || TestCvar('rsp_test_steady');
	}

	clearscope static bool SteadyOn()
	{
		let cv = CVar.FindCVar('vr_two_handed_weapons');
		return !cv || cv.GetBool();
	}

	// a gun-frame offset (cm) -> a hook translation for the gun's own MODELDEF placement
	clearscope static Vector3 HookOf(int i, Vector3 d)
	{
		Vector3 sc = RSP_Guns.Scale(i);
		return (-d.y / sc.x, d.z / sc.z, -d.x / sc.y);
	}
}

// one player's shells and pump
class RSP_State play
{
	int mode;
	int gun;					// RSP_Guns index
	Weapon weap;
	int lastTick;
	int hand;					// LOAD: EMPTY / CARRY / INSERT
	bool feedOK;				// 1.43: a grab now would take a shell (rsr/vreload.zs: Use grabs then, as the trigger does)
	int minTic;					// PUMPING: the set's own refire tic
	bool done;					// PUMPING: the stroke is done (the gun is ready at minTic)
	bool waitHand;					// PUMPING after the hand loaded an empty gun: it waits for the hand (fire: the set's own pump)
	int shells;					// shells pushed home this reload

	// the pump
	bool held;					// the hand has it
	bool backDone;				// this stroke has been to the back
	double grabS;				// the hand's track coordinate when the pump was at 0
	double pull, pullPrev;		// cm back

	// the shell going in
	double s, sPrev;			// along the port's line, cm in from the port
	Vector3 lat, latPrev;		// the hand's sideways offset from the line (it is led onto it)

	// the grab (the input rule), read once a tic
	PlayerInfo who;				// whose cvars the assist reads (OnPump is called without the pawn)
	bool relPrev;				// the reload button last tic (the VR insert's own entry)
	int inputTic;
	bool trigPrev, gripOK;
	int usedPresses;
	bool grabDown, grabPress;	// this tic
	bool pumpGrab;				// the grab held now was taken on the pump
	bool steadied;

	int ejectTic;
	int portSel;			// 2026-10-16: 0 the loading port underneath, 1 the ejection port (BD22 shotgun)
	Weapon ejectWeap;

	RSR_State geo;				// the controller frames (rsr/vreload.zs), its own instance
	Vector3 offLocal;			// the off controller, gun frame cm

	void Log(PlayerPawn mo, String what)
	{
		if (RSR.Debug(mo.player))
			Console.Printf("rsp t%d gun %d %s/%s: %s", mo.Level.maptime, gun, RSP.ModeName(mode), RSP.HandName(hand), what);
	}

	void PlaySnd(PlayerPawn mo, String snd, int chan)
	{
		if (snd == "")
			return;
		mo.A_StartSound(snd, chan);
		if (RSR.Debug(mo.player))
			Console.Printf("rsp t%d sound %s (slot %d)", mo.Level.maptime, snd, chan);
	}

	// ---- input ----------------------------------------------------------------------------------

	// once a tic: the controller frames, and this tic's grab by the input rule
	void Input(PlayerPawn mo)
	{
		int now = mo.Level.maptime;
		who = mo.player;		// before the early return: OnPump needs it every tic
		if (inputTic == now && geo)
			return;
		inputTic = now;
		if (!geo)
			geo = new('RSR_State');
		geo.Frames(mo);
		offLocal = geo.offLocal;
		let p = mo.player;
		let rs = RSR_ReloadHandler.StateOf(mo);
		int mask = RSR.GrabMask(p);
		bool trig = (p.cmd.buttons & mask) != 0 || RSP.TestCvar('rsp_test_trigger') || rs && rs.netUse;
		bool trigPress = trig && !trigPrev;
		trigPrev = trig;
		steadied = RSP.Steadied(mo);
		bool gripDown = rs && rs.netGrip;
		int presses = rs ? rs.netPresses : 0;
		bool gripPress = presses != usedPresses;
		usedPresses = presses;
		if (gripPress)
		{
			// a grip pressed near the gun hand is the engine's steadying grip, not a grab
			gripOK = !steadied && (!RSP.SteadyOn() || offLocal.Length() >= RSP.STEADY_CM + RSP.STEADY_MARGIN);
			if (RSR.Debug(p))
				Console.Printf("rsp t%d grip pressed %.0f cm from the gun hand: %s", now, offLocal.Length(),
					gripOK ? "a grab" : steadied ? "steadying (not a grab)" : "too close: steadying's (not a grab)");
		}
		bool wasDown = grabDown;
		grabDown = trig || gripDown && gripOK && !steadied;
		grabPress = trigPress || gripPress && gripOK && !steadied;
		if (grabPress)
			pumpGrab = gun > 0 && NearPump(RSR_Assist.PumpGrab(p, gun));
		if (!grabDown)
			pumpGrab = false;
		if (RSR.Debug(p) && (grabPress || wasDown != grabDown))
			Console.Printf("rsp t%d grab %s%s%s", now, grabDown ? "down" : "up", trigPress ? " (trigger)" : "", pumpGrab ? " on the pump" : "");
	}

	// ---- the pump -----------------------------------------------------------------------------

	// =====================================================================================
	// INSERT A SHELL AT ANY TIME.
	//
	// The hand feed is not a weapon state and needs no reload button. With the gun simply up,
	// loaded or half loaded, mid-fight: grab a shell, bring it to the port, push it home. The
	// weapon's Ready picks up each RSP_ShellIn and runs the set's OWN per-shell step, so the
	// set's ammo logic and sounds are untouched. (Owner, 2026-10-13 -- "insert a shell at any
	// time" means no mode to enter, which the RSP_Insert button entry still made you do.)
	//
	// Deliberately NOT folded into LoadTick: that one is driven by the weapon's loading loop and
	// also owns the pump stroke, and this has to run when the weapon is in no loop at all. The
	// three hand cases are repeated here rather than shared so that the working loading path
	// cannot be broken by a change made for this one.
	// =====================================================================================
	void FreeFeed(PlayerPawn mo, int i)
	{
		// 2026-10-16 (owner: "we need to always be able to top off the gun"): a loading loop owns
		// the hand, and so does a pump the hand is actually working. A gun merely WAITING for the
		// pump after a shot does not: that is when a shell is usually wanted, and the old early
		// return threw every shell away while the gun was not empty.
		if (mode == RSP.LOAD || mode == RSP.PUMPING && (held || pull > 0 || backDone))
			return;
		gun = i;
		sPrev = s;
		latPrev = lat;
		Input(mo);
		switch (hand)
		{
		case RSP.EMPTY:
			if (grabPress && !pumpGrab && CanTakeShell(mo))
			{
				hand = RSP.CARRY;
				geo.Buzz(mo);
				Log(mo, String.Format("took a shell %.0f cm from the gun hand (no reload needed)", offLocal.Length()));
			}
			break;

		case RSP.CARRY:
		{
			if (!grabDown)
			{
				DropShell(mo, geo.OffPoint(RSP_Guns.ShellInHand(gun)));
				hand = RSP.EMPTY;
				break;
			}
			double sv, side, ang;
			Vector3 lv;
			double cap = RSR_Assist.PumpCapture(mo.player, gun);
			bool caught = false;
			// 2026-10-16 (owner: "why not both?"): every port is tried and the shell goes to the
			// one it is BEST lined up with (smallest miss for that port's zone). The old code took
			// the first port that would accept it, so near the receiver the underside port could
			// steal a shell meant for the ejection port -- "sometimes it goes in, sometimes not".
			double bestFit = 2.0;
			int bestPort = -1;
			double bsv = 0, bside = 0, bang = 0;
			Vector3 blv = (0, 0, 0);
			for (int pk = 0; pk < Ports(gun); pk++)
			{
				[sv, side, ang, lv] = ShellAtPortK(pk);
				double pc = cap;
				if (side < pc && sv > -max(RSP.ENTER_BEHIND, pc) && sv < pc * 0.3
					&& ang < RSR_Assist.PumpTilt(mo.player, gun))
				{
					double fit = side / pc + ang / max(1.0, RSR_Assist.PumpTilt(mo.player, gun));
					if (fit < bestFit)
					{
						bestFit = fit;
						bestPort = pk;
						bsv = sv; bside = side; bang = ang; blv = lv;
					}
				}
			}
			if (bestPort >= 0)
			{
				portSel = bestPort;
				sv = bsv; side = bside; ang = bang; lv = blv;
				caught = true;
			}
			if (caught)
			{
				hand = RSP.INSERT;
				s = sPrev = sv;
				lat = latPrev = lv;
				geo.Buzz(mo);
				Log(mo, String.Format("the shell is in the port: %.1f cm, %.1f off the line, %.0f deg", sv, side, ang));
			}
			break;
		}

		case RSP.INSERT:
		{
			double sv, side, ang;
			Vector3 lv;
			[sv, side, ang, lv] = ShellAtPort();
			if (!grabDown)
			{
				DropShell(mo, InsertPoint());
				hand = RSP.EMPTY;
				s = sPrev = 0;
				break;
			}
			double cap = RSR_Assist.PumpCapture(mo.player, gun);
			double leave = RSR_Assist.Leave(mo.player, cap);
			if (side > leave || sv < -max(RSP.LEAVE_BEHIND, leave * 1.5))
			{
				hand = RSP.CARRY;
				s = sPrev = 0;
				Log(mo, "the shell came back out");
				break;
			}
			double depth = DepthK(gun, portSel);
			s = min(sv, depth);
			lat = lv;
			if (s >= min(depth * RSR_Assist.PumpSeatFrac(mo.player, gun), depth - RSP.SEAT))
			{
				int credit = clamp(RSR.PlayerInt(mo.player, 'rsr_shell_credit', 1), 1, 4);
				mo.GiveInventory('RSP_ShellIn', credit);
				PlaySnd(mo, RSP_Guns.SndShell(gun), RSP_Guns.ChanShell(gun));
				geo.Buzz(mo);
				Log(mo, String.Format("shell home (%d credited), gun idle", credit));
				hand = RSP.EMPTY;
				s = sPrev = 0;
			}
			break;
		}
		}
	}

	// THE VR INSERT'S OWN ENTRY (kept: the reload button still starts the set's own loading
	// loop, which also lets the pump be worked. FreeFeed above is the no-button path.)
	//
	// BD22 does not route its reload button through A_WeaponReady at all -- its shotgun has
	// WRF_ALLOWRELOAD commented out and uses a "Reloading" token its ACS sets, which its
	// pump-wait states never look at. So while the gun waited for the pump the reload button
	// did nothing, and a shell could only go in when the gun was empty and took another path
	// entirely. Reading the button here and sending the weapon straight to its own RSP_VRIns
	// label skips every one of the set's gates: a shell goes in ANY TIME up to the cap.
	// (Owner, 2026-10-13.)
	//
	// Refused here rather than in the weapon, so the weapon is never sent out of a pump wait
	// it cannot come back from.
	void InsertWanted(PlayerPawn mo, int i)
	{
		bool down = (mo.player.cmd.buttons & (BT_RELOAD | (1 << 20))) != 0;
		bool edge = down && !relPrev;
		relPrev = down;
		if (!edge || mode == RSP.LOAD)
			return;
		class<Inventory> rc = RSP_Guns.Reserve(i);
		if (rc && mo.CountInv(rc) <= 0)
			return;								// nothing in reserve to insert
		class<Inventory> lc = RSP_Guns.Loaded(i);
		int cap = RSP_Guns.Cap(i);
		if (lc && cap > 0 && mo.CountInv(lc) >= cap)
			return;								// the tube is full
		mo.GiveInventory('RSP_Insert', 1);
		Log(mo, "reload pressed: the hand insert takes it");
	}

	// how far a gun-frame point is from the pump's track
	double PumpDist(Vector3 p)
	{
		Vector3 pd = RSP_Guns.Pull(gun);
		Vector3 rel = p - RSP_Guns.Grab(gun);
		double t = clamp(rel dot pd, 0, RSP_Guns.Travel(gun));
		return (rel - pd * t).Length();
	}

	// the off controller, or the middle of its closed hand, at the pump
	bool NearPump(double lim)
	{
		return min(PumpDist(offLocal), PumpDist(geo.OffPoint(RSR.PalmGrab()))) < lim;
	}

	// the hand on the pump: steadied with the off controller at it, or the grab taken on it and held
	bool OnPump(bool holding)
	{
		double g = RSR_Assist.PumpGrab(who, gun);
		if (!NearPump(holding ? RSR_Assist.Leave(who, g) * 1.2 : g))
			return false;
		return steadied || grabDown && pumpGrab;
	}

	double TrackS()
	{
		return (offLocal - RSP_Guns.Grab(gun)) dot RSP_Guns.Pull(gun);
	}

	// one tic of the hand and the pump: 1 at the back, 2 forward again after the back, 0 else
	int StrokeTick(PlayerPawn mo)
	{
		double travel = RSP_Guns.Travel(gun);
		double t = TrackS();
		if (held && !OnPump(true))
		{
			held = false;
			Log(mo, String.Format("let go of the pump at %.1f cm%s", pull, backDone ? " (it stays back)" : ""));
		}
		if (!held)
		{
			if (!backDone && pull > 0)
				pull = max(0, pull - RSP.SPRING);		// not worked: it goes back forward
			if (!OnPump(false))
				return 0;
			held = true;
			grabS = t - pull;							// the hand takes it where it is
			geo.Buzz(mo);
			Log(mo, String.Format("took the pump (%s) at %.1f cm", steadied ? "steadied" : "grab", pull));
			return 0;
		}
		double np = t - grabS;
		if (np < 0)
		{
			grabS = t;		// the hand pushes on past the front: the pump stays there
			np = 0;
		}
		else if (np > travel)
		{
			grabS = t - travel;
			np = travel;
		}
		pull = np;
		if (!backDone && pull >= RSR_Assist.PumpPullFrac(mo.player, gun) * travel)
		{
			backDone = true;
			geo.Buzz(mo);
			return 1;
		}
		if (backDone && pull <= RSR_Assist.PumpFwdFrac(mo.player, gun) * travel)
			return 2;
		return 0;
	}

	// the stroke's back and forward: the weapon does the set's own (spent shell out, chamber); the
	// set's own sounds play here, as the hand does it
	void Back(PlayerPawn mo)
	{
		mo.GiveInventory('RSP_Back', 1);
		PlaySnd(mo, RSP_Guns.SndBack(gun), RSP_Guns.ChanBack(gun));
		if (mode == RSP.PUMPING && RSP_Guns.EjectFrames(gun) > 0)
		{
			ejectTic = mo.Level.maptime;
			ejectWeap = weap;
		}
		Log(mo, "pump at the back");
	}

	void Forward(PlayerPawn mo)
	{
		mo.GiveInventory('RSP_Fwd', 1);
		PlaySnd(mo, RSP_Guns.SndFwd(gun), RSP_Guns.ChanFwd(gun));
		held = false;
		backDone = false;
		pull = pullPrev = 0;
		Log(mo, "pump forward: stroke done");
	}

	// a spent shell out of the ejection port: BD22's own casing, flicked out to the right and up
	void CaseOut(PlayerPawn mo, int i)
	{
		if (!geo)
			return;
		Vector3 at = i == 1 ? (17.034, 4.124, -1.390) : RSP_Guns.Port(i);	// shotguns: moved with the gun to the FBX hand (was 12.8, -2.2, 0.5)
		Name cn = 'ShotgunCasing';		// BD22's own (DECORATE: looked up at run time)
		class<Actor> cc = cn;
		if (!cc)
			return;
		let c = Actor.Spawn(cc, RSVR_VRHand.HandPos(mo) + geo.FromGun(at));
		if (!c)
			return;
		Vector3 fling = -geo.L * 3.0 + geo.U * 3.5 - geo.F * 0.5;
		c.vel = mo.vel + fling + (frandom(-0.4, 0.4), frandom(-0.4, 0.4), frandom(0, 0.6));
		c.angle = atan2(geo.F.y, geo.F.x);
		c.target = mo;
	}

	// ---- the shell ----------------------------------------------------------------------------

	// the shell in the hand against the port's line: how far in along it, how far off it, the
	// angle of its crimp end to it, and the sideways offset
	// 2026-10-16 (owner): the BD22 shotgun's ejection port, its "eject" surface on the right of
	// the receiver just ahead of and above the trigger (mesh measured: F 8.8..16.2, L -1.8..-0.7,
	// U -1.3..1.3). A shell can also be dropped in there, lying along the bore and pushed in
	// sideways, as a real pump gun's combat load; spent shells come out of it.
	clearscope static int Ports(int i) { return i == 1 && RSP.TestCvarOn('rsr_sideport') ? 2 : 1; }
	clearscope static Vector3 PortK(int i, int k) { return k == 1 ? (17.024, 4.476, -1.627) : RSP_Guns.Port(i); }	// shotguns: moved with the gun (was 12.8, -1.9, 0.2)
	clearscope static Vector3 PushK(int i, int k) { return k == 1 ? (-0.077, 0.979, 0.190) : RSP_Guns.Push(i); }	// shotguns: turned with the gun (was 0, 1, 0)
	clearscope static Vector3 BoreK(int i) { return (0.996, 0.067, 0.059); }	// shotguns: the moved Shot_Gun's bore (was 1, 0, 0)
	clearscope static double DepthK(int i, int k) { return k == 1 ? 1.5 : RSP_Guns.Depth(i); }
	const SHELL_HALF = 3.0;		// half a BD22 shell (its tube depth is the whole shell, 6 cm)

	double, double, double, Vector3 ShellAtPortK(int k)
	{
		if (k == 1)
		{
			// the side port: the shell's MIDDLE against the port, its axis along the bore
			Vector3 a1 = geo.OffDirInGun(RSP_Guns.AxisInHand(gun));
			Vector3 c1 = geo.OffPoint(RSP_Guns.ShellInHand(gun)) - a1 * SHELL_HALF;
			Vector3 rel1 = c1 - PortK(gun, 1);
			double sv1 = rel1 dot PushK(gun, 1);
			Vector3 lv1 = rel1 - PushK(gun, 1) * sv1;
			return sv1, lv1.Length(), acos(clamp(abs(a1 dot BoreK(gun)), 0, 1)), lv1;
		}
		// 1.93: ZScript cannot forward a multi-value return as one expression. This compiled with
		// "Incorrect number of return values. Got 1, but expected 4", so only the first value was
		// carried and side, ang and lv reached the caller as whatever its own locals held. The
		// UNDERSIDE port (k = 0) is the one that came through here; the side port returns inline
		// above, which is why that one behaved. Destructure, then return all four.
		double sv, side, ang;
		Vector3 lv;
		[sv, side, ang, lv] = ShellAtPort0();
		return sv, side, ang, lv;
	}

	double, double, double, Vector3 ShellAtPort()
	{
		double sv, side, ang;		// 1.93: as ShellAtPortK -- no tail-forwarding a 4-value return
		Vector3 lv;
		[sv, side, ang, lv] = ShellAtPortK(portSel);
		return sv, side, ang, lv;
	}

	double, double, double, Vector3 ShellAtPort0()
	{
		Vector3 c = geo.OffPoint(RSP_Guns.ShellInHand(gun));
		Vector3 a = geo.OffDirInGun(RSP_Guns.AxisInHand(gun));
		Vector3 push = RSP_Guns.Push(gun);
		Vector3 rel = c - RSP_Guns.Port(gun);
		double sv = rel dot push;
		Vector3 lv = rel - push * sv;
		return sv, lv.Length(), acos(clamp(a dot push, -1, 1)), lv;
	}

	// how far behind the port the shell is led onto the line. It has to be the same reach the
	// capture zone uses, or raising rsr_assist catches the shell further out than the lead-in
	// is normalised over and the shell SNAPS onto the line instead of being guided in.
	double LeadIn()
	{
		return max(RSP.ENTER_BEHIND, RSR_Assist.PumpCapture(who, gun));
	}

	// where the shell going in is drawn (gun frame): led onto the line as it comes in
	Vector3 InsertPoint()
	{
		double f = clamp(-s / LeadIn(), 0, 1);
		if (portSel == 1)		// the side port: the shell's middle -> its tip, which is what is drawn and dropped
			return PortK(gun, 1) + PushK(gun, 1) * s + lat * f + geo.OffDirInGun(RSP_Guns.AxisInHand(gun)) * SHELL_HALF;
		return RSP_Guns.Port(gun) + RSP_Guns.Push(gun) * s + lat * f;
	}

	bool CanTakeShell(PlayerPawn mo, bool quiet = false)
	{
		class<Inventory> rc = RSP_Guns.Reserve(gun);
		if (rc && mo.CountInv(rc) <= 0)
		{
			if (!quiet)
				Log(mo, "no shells left to take");
			return false;
		}
		int rp = RSR.RigPouch(mo);		// 2.0.3u: the rig's ammo pouch only (vreload.zs RSR.RigPouch)
		if (rp >= 0)
		{
			if (!quiet && rp == 0)
				Log(mo, "the rig's pouch only: the off hand is not in it");
			return rp == 1;
		}
		Vector3 palm = geo.OffPoint(RSR.PalmGrab());
		if ((palm - RSP_Guns.Port(gun)).Length() < RSP.POUCH_MIN)
			return false;
		if (RSR.PlayerInt(mo.player, 'rsr_pouch', 0) == 1)
		{
			Vector3 op = RSVR_VRHand.OffPos(mo);
			double below = (mo.player.viewz - op.z) * geo.ps * 100.0 / geo.vu;
			if (below < RSP.POUCH_LOW)
				return false;
		}
		return true;
	}

	// a shell falls: the gun's own shell as a world actor, where it is now (gun frame cm)
	void DropShell(PlayerPawn mo, Vector3 at)
	{
		Vector3 pos = RSVR_VRHand.HandPos(mo) + geo.FromGun(at);
		let d = RSP_DroppedShell(Actor.Spawn('RSP_DroppedShell', pos));
		Log(mo, "the shell drops");
		if (!d)
			return;
		d.sprite = Actor.GetSpriteIndex(RSP_Guns.SprWorld(gun));
		d.frame = 0;
		d.angle = atan2(geo.F.y, geo.F.x);
		d.pitch = -asin(clamp(geo.F.z, -1, 1));
		d.vel = mo.vel + (0, 0, -1.0);
		d.BounceSound = RSP_Guns.SndLand(gun);
		d.target = mo;
	}

	// ---- the weapon's calls -------------------------------------------------------------------

	void BeginLoad(PlayerPawn mo, Weapon w, int i)
	{
		mode = RSP.LOAD;
		gun = i;
		weap = w;
		hand = RSP.EMPTY;
		held = backDone = done = waitHand = false;
		pull = pullPrev = s = sPrev = 0;
		lat = latPrev = (0, 0, 0);
		shells = 0;
		lastTick = mo.Level.maptime;
		Log(mo, "the reload is the hand's");
	}

	void BeginPump(PlayerPawn mo, Weapon w, int i, int minTics, bool wait)
	{
		mode = RSP.PUMPING;
		gun = i;
		weap = w;
		// (hand kept: a shell the free feed carries stays in the hand through the shot and pump)
		done = backDone = false;
		waitHand = wait;
		held = !wait;
		pull = pullPrev = 0;
		grabS = TrackS();
		minTic = mo.Level.maptime + minTics;
		lastTick = mo.Level.maptime;
		if (wait)
			Log(mo, "loaded empty: the gun waits for the hand on the pump (fire: the set's own pump)");
		else
			Log(mo, String.Format("the hand is on the pump (%s): it pumps (ready no sooner than t%d)", steadied ? "steadied" : "grab", minTic));
	}

	// RSP_LoadStart: the weapon's reload, after the set's own checks
	void LoadStart(PlayerPawn mo)
	{
		let w = mo.player.ReadyWeapon;
		int i = RSP_Guns.Index(w);
		if (i <= 0 || !RSR_ReloadHandler.Wanted(mo))
			return;			// the set's own reload
		gun = i;
		Input(mo);
		if (mode == RSP.LOAD && weap == w)
		{
			lastTick = mo.Level.maptime;		// its loading loop again (after a kick): go on
		}
		else
		{
			if (mode != RSP.NONE)
				Abort(mo);
			BeginLoad(mo, w, i);
		}
		mo.GiveInventory('RSP_Go', 1);
	}

	// RSP_PumpStart: the weapon's pump, after the set's own checks. minTics: the set's own tics
	// from here to its refire
	void PumpStart(PlayerPawn mo, int minTics)
	{
		let w = mo.player.ReadyWeapon;
		int i = RSP_Guns.Index(w);
		if (i <= 0 || !RSR_ReloadHandler.Wanted(mo))
			return;			// the set's own pump
		// the hand's loading ended the set's way (an empty gun full, out of shells): it chambers by
		// hand, and the hand is at the port, so the gun waits for it (fire: the set's own pump)
		bool fromLoad = mode == RSP.LOAD && weap == w;
		if (mode == RSP.LOAD)
			Abort(mo);
		else if (mode != RSP.NONE)
			End(mo);
		gun = i;
		Input(mo);
		// The gun WAITS for the hand rather than deciding in this one tic. It used to require
		// the hand to be on the pump at the instant of the shot -- so you could not fire and
		// THEN reach for the pump, which is the natural motion -- and anything else fell
		// straight through to the set's own pump, permanently. BeginPump's waiting mode already
		// handles this properly: PumpTick holds the gun until the hand works the pump, or until
		// fire is pressed, which runs the set's own pump. (Owner, 2026-10-13: the pump shotgun
		// would not let him pump between shots.)
		bool on = OnPump(false);
		BeginPump(mo, w, i, minTics, !on);
		mo.GiveInventory('RSP_Go', 1);
	}

	// RSP_LTick: every tic the weapon waits in its loading loop
	void LoadTick(PlayerPawn mo)
	{
		let w = mo.player.ReadyWeapon;
		if (mode != RSP.LOAD || weap != w)
		{
			int i = RSP_Guns.Index(w);
			if (i <= 0)
				return;
			if (mode != RSP.NONE)
				Abort(mo);
			BeginLoad(mo, w, i);		// (a saved game...): the hand loads from here
		}
		int now = mo.Level.maptime;
		lastTick = now;
		pullPrev = pull;
		sPrev = s;
		latPrev = lat;
		Input(mo);
		switch (hand)
		{
		case RSP.EMPTY:
		{
			int ev = StrokeTick(mo);
			if (ev == 1)
				Back(mo);
			else if (ev == 2)
			{
				Forward(mo);
				End(mo);		// the weapon ends the reload (RSP_LFwd)
			}
			else if (!held && pull <= 0 && grabPress && !pumpGrab && CanTakeShell(mo))
			{
				hand = RSP.CARRY;
				geo.Buzz(mo);
				Log(mo, String.Format("took a shell %.0f cm from the gun hand", offLocal.Length()));
			}
			break;
		}

		case RSP.CARRY:
		{
			if (!grabDown)
			{
				DropShell(mo, geo.OffPoint(RSP_Guns.ShellInHand(gun)));
				hand = RSP.EMPTY;
				break;
			}
			double sv, side, ang;
			Vector3 lv;
			double cap = RSR_Assist.PumpCapture(mo.player, gun);
			bool caught = false;
			// 2026-10-16 (owner: "why not both?"): every port is tried and the shell goes to the
			// one it is BEST lined up with (smallest miss for that port's zone). The old code took
			// the first port that would accept it, so near the receiver the underside port could
			// steal a shell meant for the ejection port -- "sometimes it goes in, sometimes not".
			double bestFit = 2.0;
			int bestPort = -1;
			double bsv = 0, bside = 0, bang = 0;
			Vector3 blv = (0, 0, 0);
			for (int pk = 0; pk < Ports(gun); pk++)
			{
				[sv, side, ang, lv] = ShellAtPortK(pk);
				double pc = cap;
				if (side < pc && sv > -max(RSP.ENTER_BEHIND, pc) && sv < pc * 0.3
					&& ang < RSR_Assist.PumpTilt(mo.player, gun))
				{
					double fit = side / pc + ang / max(1.0, RSR_Assist.PumpTilt(mo.player, gun));
					if (fit < bestFit)
					{
						bestFit = fit;
						bestPort = pk;
						bsv = sv; bside = side; bang = ang; blv = lv;
					}
				}
			}
			if (bestPort >= 0)
			{
				portSel = bestPort;
				sv = bsv; side = bside; ang = bang; lv = blv;
				caught = true;
			}
			if (caught)
			{
				hand = RSP.INSERT;
				s = sPrev = sv;
				lat = latPrev = lv;
				geo.Buzz(mo);
				Log(mo, String.Format("the shell is in the port: %.1f cm, %.1f off the line, %.0f deg", sv, side, ang));
			}
			break;
		}

		case RSP.INSERT:
		{
			double sv, side, ang;
			Vector3 lv;
			[sv, side, ang, lv] = ShellAtPort();
			if (!grabDown)
			{
				DropShell(mo, InsertPoint());		// let go before it is home: it falls out
				hand = RSP.EMPTY;
				s = sPrev = 0;
				break;
			}
			double cap = RSR_Assist.PumpCapture(mo.player, gun);
			double leave = RSR_Assist.Leave(mo.player, cap);
			if (side > leave || sv < -max(RSP.LEAVE_BEHIND, leave * 1.5))
			{
				hand = RSP.CARRY;
				s = sPrev = 0;
				Log(mo, "the shell came back out");
				break;
			}
			double depth = DepthK(gun, portSel);
			s = min(sv, depth);
			lat = lv;
			// home: PumpSeatFrac of the way in, never looser than RSP.SEAT cm short of home
			if (s >= min(depth * RSR_Assist.PumpSeatFrac(mo.player, gun), depth - RSP.SEAT))
			{
				// home: the weapon runs the set's own per-shell step; the set's own sound
				shells++;
				// rsr_shell_credit: one shell pushed home counts as this many, 1 to 4, so the
				// tube can be filled without eight separate inserts. The reserve still pays
				// for every one of them -- the weapon takes one from reserve per credit.
				int credit = clamp(RSR.PlayerInt(mo.player, 'rsr_shell_credit', 1), 1, 4);
				mo.GiveInventory('RSP_ShellIn', credit);
				PlaySnd(mo, RSP_Guns.SndShell(gun), RSP_Guns.ChanShell(gun));
				geo.Buzz(mo);
				Log(mo, String.Format("shell %d home", shells));
				hand = RSP.EMPTY;
				s = sPrev = 0;
				lat = latPrev = (0, 0, 0);
			}
			break;
		}
		}
	}

	// RSP_PTick: every tic the weapon waits for the hand's pump stroke
	void PumpTick(PlayerPawn mo)
	{
		let w = mo.player.ReadyWeapon;
		if (mode != RSP.PUMPING || weap != w)
		{
			mo.GiveInventory('RSP_Auto', 1);		// no stroke under way (a saved game...): the set's own pump
			return;
		}
		int now = mo.Level.maptime;
		lastTick = now;
		pullPrev = pull;
		Input(mo);
		if (!done)
		{
			int ev = StrokeTick(mo);
			if (ev == 1)
				Back(mo);
			else if (ev == 2)
			{
				Forward(mo);
				done = true;
			}
			else if (!held && pull <= 0 && !backDone && (!waitHand || (mo.player.cmd.buttons & BT_ATTACK)))
			{
				// the hand is off the pump and has not worked it (or, waiting, fire): the set's own pump
				Log(mo, waitHand ? "fire: the set's own pump" : "the hand left the pump: the set's own pump");
				mo.GiveInventory('RSP_Auto', 1);
				End(mo);
				return;
			}
		}
		// 2026-10-23: minTic is an ABSOLUTE future tic, and Level.maptime restarts at 0 on a
		// level change -- a deadline stored before an exit can never be reached, so the stroke
		// never completed and the gun stayed in PUMPING until a weapon switch aborted it. No
		// refire time is anywhere near ten seconds, so a deadline that far out is a restart.
		if (minTic > now + 350)
			minTic = now;
		if (done && now >= minTic)
		{
			Log(mo, "ready (the set's own refire time)");
			mo.GiveInventory('RSP_Ready', 1);
			End(mo);
		}
	}

	// the weapon left (switched away, died, ...): put everything away
	void Abort(PlayerPawn mo)
	{
		if (mode == RSP.LOAD && hand == RSP.CARRY)
			DropShell(mo, geo.OffPoint(RSP_Guns.ShellInHand(gun)));
		else if (mode == RSP.LOAD && hand == RSP.INSERT)
			DropShell(mo, InsertPoint());
		End(mo);
	}

	void End(PlayerPawn mo)
	{
		if (mode != RSP.NONE)
			Log(mo, "end");
		if (mode == RSP.LOAD)
			hand = RSP.EMPTY;		// the loading loop's hand; the free feed keeps its own shell
		mode = RSP.NONE;
		weap = null;
		held = backDone = done = waitHand = false;
		pull = pullPrev = s = sPrev = 0;
		lat = latPrev = (0, 0, 0);
	}

	// ---- drawing (after the psprites tick) ------------------------------------------------------

	bool InWait(PSprite psp, Weapon w, int i)
	{
		if (!psp.CurState)
			return false;
		Array<String> list;
		RSP_Guns.WaitLabels(i).Split(list, " ", TOK_SKIPEMPTY);
		for (int k = 0; k < list.Size(); k++)
		{
			if (psp.CurState == w.FindStateByString(list[k], true))
				return true;
		}
		return false;
	}

	void Draw(PlayerPawn mo)
	{
		let p = mo.player;
		let w = p.ReadyWeapon;
		int i = RSP_Guns.Index(w);
		let psp = p.FindPSprite(PSP_WEAPON);
		bool active = mode != RSP.NONE && w && w == weap && i > 0;
		bool shown = active && (held || pull > 0) && !done;
		if (psp && active && InWait(psp, w, i))
		{
			if (shown)
			{
				psp.Sprite = Actor.GetSpriteIndex(RSP_Guns.SprGun(i));	// the gun without its pump
				psp.Frame = 0;
			}
			else
			{
				SpriteID spr;
				int fr;
				if (RSR.SpriteOf(RSP_Guns.ReadySprite(i), spr, fr))
				{
					psp.Sprite = spr;
					psp.Frame = fr;
				}
			}
		}
		int now = mo.Level.maptime;
		int k = now - ejectTic;
		int ej = i > 0 ? min(RSP.EJECT_TICS, RSP_Guns.EjectFrames(i)) : 0;
		bool eject = w && w == ejectWeap && k >= 0 && k < ej;
		// The hand's own shell must NOT depend on a weapon state: FreeFeed carries and inserts
		// with the gun idle (mode NONE), so gating these on `active` hid the shell entirely the
		// moment the feed stopped needing a loading loop. They follow `hand` instead.
		bool mine = i > 0 && i == gun;
		bool shell = mine && hand == RSP.INSERT;
		bool handShell = mine && hand == RSP.CARRY;
		let parts = RSR_GunParts(mo.FindInventory('RSR_GunParts'));
		if (!parts && (shown || shell || handShell || eject))
		{
			mo.GiveInventory('RSR_GunParts', 1);
			parts = RSR_GunParts(mo.FindInventory('RSR_GunParts'));
		}
		Name sp = i > 0 ? RSP_Guns.SprPart(i) : 'TNT1';
		RSR.SetPart(p, RSP.PUMP, parts, shown, sp, 0);
		RSR.SetPart(p, RSP.BOLT, parts, shown && RSP_Guns.BoltRatio(i) > 0, sp, 1);
		RSR.SetPart(p, RSP.SHELL, parts, shell, sp, 2);
		RSR.SetPart(p, RSP.EJECT, parts, eject, sp, 3 + max(k, 0));
		Actor hands = p.OffhandWeapon;
		RSR.SetPart(p, RSP.HANDSHELL, hands is 'RSQ_Hands' ? hands : null, handShell, sp, 2);
	}
}

// what the weapon gives itself to talk to this; never kept
class RSP_Call : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		let mo = PlayerPawn(toucher);
		if (mo && mo.player)
		{
			let s = RSP_Handler.StateOf(mo);
			if (s)
				Called(mo, s, Amount);
		}
		return false;
	}

	virtual void Called(PlayerPawn mo, RSP_State s, int amount) {}
}

class RSP_LoadStart : RSP_Call
{
	override void Called(PlayerPawn mo, RSP_State s, int amount) { s.LoadStart(mo); }
}

class RSP_PumpStart : RSP_Call		// the amount given: the set's own tics to its refire
{
	override void Called(PlayerPawn mo, RSP_State s, int amount) { s.PumpStart(mo, amount); }
}

class RSP_LTick : RSP_Call
{
	override void Called(PlayerPawn mo, RSP_State s, int amount) { s.LoadTick(mo); }
}

class RSP_PTick : RSP_Call
{
	override void Called(PlayerPawn mo, RSP_State s, int amount) { s.PumpTick(mo); }
}

// what this tells the weapon (the weapon takes them)
class RSP_Go : RSVR_Token {}
class RSP_ShellIn : RSVR_Token { Default { Inventory.MaxAmount 8; } }	// one per credited shell
class RSP_Insert : RSVR_Token {}		// the reload button: start the hand insert now
class RSP_Back : RSVR_Token {}
class RSP_CaseOut : RSVR_Token { Default { Inventory.MaxAmount 4; } }	// 2026-10-16: a spent shell, out of the ejection port
class RSP_Fwd : RSVR_Token {}
class RSP_Auto : RSVR_Token {}
class RSP_Ready : RSVR_Token {}

// every sprite name these layers show (MODELDEF.rsrpump), so the engine knows them; never spawned
class RSP_Sprites : Actor
{
	States
	{
	Spawn:
		RQUG A 0;
		RQUP ABCDEFGHI 0;
		RQUW A 0;
		RQUH A 0;
		RQUQ ABCDEFGHI 0;
		RQUX A 0;
		RQUN A 0;
		Stop;
	}
}

// a shell let go before it was home: the gun's own shell surface at world scale (MODELDEF.rsrpump)
class RSP_DroppedShell : RSR_DroppedMag
{
	Default
	{
		Radius 1;
		Height 1;
		BounceFactor 0.4;
		WallBounceFactor 0.4;
	}
}

class RSP_Handler : EventHandler
{
	RSP_State st[MAXPLAYERS];

	clearscope static RSP_Handler Get()
	{
		return RSP_Handler(EventHandler.Find('RSP_Handler'));
	}

	static RSP_State StateOf(PlayerPawn mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS)
			return null;
		if (!h.st[n])
			h.st[n] = new('RSP_State');
		return h.st[n];
	}

	clearscope static RSP_State Peek(Actor mo)
	{
		let h = Get();
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		return n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
	}

	// the off hand's grip key is eaten while the hand loads or pumps (rsr/vreload.zs InputProcess)
	clearscope static bool Busy(int n)
	{
		let h = Get();
		let s = h && n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
		return s && s.mode != RSP.NONE;
	}

	// 1.43 rsr/vreload.zs: the Use key grabs a shell now (the free feed would take one)
	clearscope static bool Feedable(int n)
	{
		let h = Get();
		let s = h && n >= 0 && n < MAXPLAYERS ? h.st[n] : null;
		return s && (s.feedOK || s.hand != RSP.EMPTY);
	}

	// rsq/hands.zs: the free hand's state while the hand loads or pumps ("" = the hands' own)
	clearscope static String FreeHand(Actor mo)
	{
		let s = Peek(mo);
		if (!s)
			return "";
		// The shell hold does NOT depend on a weapon state either: FreeFeed carries a shell with
		// the gun idle, and gating this on the LOAD mode left the hand open round a shell it was
		// holding. The pump poses below still need a mode, since only a stroke sets `held`.
		if (s.hand == RSP.CARRY || s.hand == RSP.INSERT)
			return "RspShell";			// Ermac's one-shell hold (the shell is layer 2210 / 2122)
		if (s.mode == RSP.NONE)
			return "";
		if (s.held && !s.steadied && RSP.SteadyOn())
			return "AmmoH";				// a closed hand on the pump (the grab; no support hand then)
		return "";						// free, or steadied: the hands' own (the support hand rides the pump)
	}

	// rsq/hands.zs ModifyBobLayer3D: the support hand rides the pump (hand-model units)
	clearscope static Vector3 SupportShift(Actor owner, double ticfrac)
	{
		let s = Peek(owner);
		if (!s || s.mode == RSP.NONE || !owner.player || owner.player.ReadyWeapon != s.weap || s.gun <= 0)
			return (0, 0, 0);
		return RSP_Guns.SupportHook(s.gun) * (s.pullPrev + (s.pull - s.pullPrev) * ticfrac);
	}

	// rsq/hands.zs ModifyBobLayer3D: the layers this places
	clearscope static bool Places(Actor owner, int layer)
	{
		if (layer >= RSP.LAYER_FIRST && layer <= RSP.LAYER_LAST || layer == RSP.HANDSHELL)
			return true;
		// TEST ONLY (rsr_test_offdraw): the free hand at the scripted off hand, with a pump gun
		return layer == 2200 && RSP.TestCvar('rsr_test_offdraw') && owner && owner.player && RSP_Guns.Index(owner.player.ReadyWeapon) > 0;
	}

	clearscope static Vector3, Vector3 Place(Actor owner, Vector3 t, Vector3 r, int layer, double ticfrac)
	{
		let s = Peek(owner);
		if (!s)
			return t, r;
		int i = s.gun;
		if (i <= 0 && owner.player)
			i = RSP_Guns.Index(owner.player.ReadyWeapon);
		if (i <= 0)
			return t, r;
		double pl = s.pullPrev + (s.pull - s.pullPrev) * ticfrac;
		switch (layer)
		{
		case RSP.PUMP:
			return t + RSP_Guns.PumpHook(i) * pl, r;
		case RSP.BOLT:
			return t + RSP_Guns.PumpHook(i) * (RSP_Guns.BoltRatio(i) * pl), r;
		case RSP.SHELL:
		{
			double sv = s.sPrev + (s.s - s.sPrev) * ticfrac;
			Vector3 lv = s.latPrev + (s.lat - s.latPrev) * ticfrac;
			double lead = max(RSP.ENTER_BEHIND, RSR_Assist.PumpCapture(owner.player, i));
			Vector3 d = RSP_Guns.Push(i) * sv + lv * clamp(-sv / lead, 0, 1);
			if (s.portSel == 1)		// the side port: the same shell, lying along the bore, moved to the port
				d = RSP_State.PortK(i, 1) - RSP_Guns.Port(i) + RSP_State.BoreK(i) * RSP_State.SHELL_HALF + RSP_State.PushK(i, 1) * sv + lv * clamp(-sv / lead, 0, 1);
			return t + RSP_Guns.PortHook(i) + RSP.HookOf(i, d), r;
		}
		case RSP.EJECT:
		{
			int k = clamp(owner.Level.maptime - s.ejectTic, 0, RSP.EJECT_TICS - 1);
			return t + RSP_Guns.EjectHook(i, k), r;
		}
		case RSP.HANDSHELL:
		{
			Vector3 hr = RSP_Guns.HandRot(i);
			return t + RSP_Guns.HandHook(i) + Unturn(hr, DeskShift(s, RSP_Guns.Scale(i))), r + hr;
		}
		case 2200:
			return t + DeskShift(s, (-1, 1, 1)), r;
		}
		return t, r;
	}

	// v turned back by a hook's turn (yaw, pitch, roll; models.cpp RenderHUDModel's order), so a
	// move added before the turn lands as v after it
	clearscope static Vector3 Unturn(Vector3 a, Vector3 v)
	{
		if (v.Length() == 0)
			return v;
		double cx = cos(a.x), sx = sin(a.x), cy = cos(a.y), sy = sin(a.y), cz = cos(a.z), sz = sin(a.z);
		Vector3 r0 = (cx * cz + sx * sy * sz, -cx * sz + sx * sy * cz, sx * cy);
		Vector3 r1 = (cy * sz, cy * cz, -sy);
		Vector3 r2 = (-sx * cz + cx * sy * sz, sx * sz + cx * sy * cz, cx * cy);
		return r0 * v.x + r1 * v.y + r2 * v.z;
	}

	// TEST ONLY (rsr_test_offdraw): on a desktop both hands are drawn at the view; move the off
	// hand's layers by where the scripted off hand is
	clearscope static Vector3 DeskShift(RSP_State s, Vector3 scale)
	{
		if (!RSP.TestCvar('rsr_test_offdraw'))
			return (0, 0, 0);
		Vector3 c = s.offLocal;
		return (-c.y / scale.x, c.z / scale.z, -c.x / scale.y);
	}

	// 2026-10-23 (owner): a new map starts clean. Level.maptime restarts at 0, so anything
	// still half-done across an exit is timed against a clock that no longer exists, and some
	// of it could never finish. This is the quiet put-away -- NOT Abort(), which drops the
	// magazine or shell into the world and would litter the new map. Fires for a loaded
	// savegame too, which is wanted.
	override void WorldLoaded(WorldEvent e)
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || !st[n])
				continue;
			st[n].End(players[n].mo);
		}
	}

	override void WorldTick()
	{
		int now = Level.maptime;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			if (!st[n])
				st[n] = new('RSP_State');
			let s = st[n];
			let w = mo.player.ReadyWeapon;
			int i = RSP_Guns.Index(w);
			s.feedOK = false;
			if (i > 0 && RSR_ReloadHandler.Wanted(mo))
			{
				// 2026-10-16: the weapon's spent shell, out of the gun's ejection port
				for (int nc = mo.CountInv('RSP_CaseOut'); nc > 0; nc--)
				{
					mo.TakeInventory('RSP_CaseOut', 1);
					s.Input(mo);
					s.CaseOut(mo, i);
				}
				if (s.mode == RSP.NONE)
					s.gun = i;
				s.Input(mo);		// the grab's edges and where it was taken, every tic with the gun
				s.InsertWanted(mo, i);
				s.FreeFeed(mo, i);	// a shell straight into the port, no reload button, any time
				// 1.43 (owner: "with use it just appears in offhand"): where a trigger grab would take a
				// shell now, the Use key grabs too (the tube has room, the hand is free and away from the port)
				class<Inventory> lc = RSP_Guns.Loaded(i);
				int cap = RSP_Guns.Cap(i);
				s.feedOK = s.hand == RSP.EMPTY && s.geo
					&& !(s.mode == RSP.LOAD || s.mode == RSP.PUMPING && (s.held || s.pull > 0 || s.backDone))
					&& !(lc && cap > 0 && mo.CountInv(lc) >= cap) && s.CanTakeShell(mo, true);
			}
			else if (s.mode == RSP.NONE && s.hand != RSP.EMPTY)
			{
				// the gun is gone, or VR reloading is off, and the free feed still had a shell
				s.hand = RSP.EMPTY;
				s.s = s.sPrev = 0;
			}
			if (s.mode != RSP.NONE)
			{
				bool gone = mo.health <= 0 || w != s.weap || now - s.lastTick > 2;
				if (gone)
				{
					if (RSR.Debug(mo.player))
						Console.Printf("rsp t%d: the weapon left the wait (%s %s)%s", now, RSP.ModeName(s.mode), RSP.HandName(s.hand), w != s.weap ? ": switched away" : "");
					s.Abort(mo);
				}
			}
			s.Draw(mo);
		}
	}
}
