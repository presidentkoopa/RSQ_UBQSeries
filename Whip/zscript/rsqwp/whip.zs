// THE WHIP: a bullwhip, the slot-1 weapon (weapon.zs, owner 2026-10-31: "whip is a weapon").
//
// 2026-11-27 (owner: "the whip is been conceptually cool but a huge pain in the ass. what i want is to do a big wide
// swing and damage + knockback + slomo in a nearly 120 arc on front of me, and if i crack down to the ground the impact
// sends out a shockwave and sends enemies airborne with contextual slowmo", and "i want to tone this thing down"):
// the whip has TWO MOVES now, both in lash.zs: the Wide Swing and the Ground Crack. This file is what is left under
// them: the simulated thong that follows the hand, the hand that holds it, and the tic that runs both. The pointed
// crack, the mark, the lock, the wrap, the yank, the flail, the lasso, the rope and everything else that was here went.
//
// A REAL WHIP, SIMULATED (rebuilt 11-02 on a validated research whip: Moses C. Nah, MIT Newman Lab, "Whip Project --
// Targeting with a Whip", github MosesAndLily/whip-project-targeting, BSD-3; its numbers are used, see the constants).
// The thong is a chain of NN links, position-based (XPBD): every tic SUB sub-steps, each one integrating the links,
// then the reference whip's BEND SPRING AND DAMPER at every joint, then the links held to length. One model always.
// The handle is driven along a smooth path (the hand followed critically damped, sub-step by sub-step), so a hand
// that jumps a little each tic never kicks the thong. The thong hits nothing: it is what you see.
//
// ROOM SPACE. The engine squashes map Z by pixelstretch (1.2), so the chain is simulated in
// room units (map z x 1.2), where lengths and speeds mean the same in every direction, and
// put back into map space to draw and to trace.
class RSQWP_Whip : EventHandler
{
	const NW = MAXPLAYERS * 2;
	// THE LENGTH (owner 11-02: "Length = MIT's exactly"): the reference whip's own 25 links of 0.072 m = 1.8 m of
	// thong (3D_model_w_whip.xml: body_whip_node1..25, 0.0720 apart), in room units (34 a metre): a link is 2.448.
	const NN = 25;               // links in the thong; node 0 is the handle's tip
	const NP = NN + 1;
	const LINK = 2.448;          // 0.072 m x 34 room units a metre
	const HANDLEN = 8.0;          // the handle, map units (~24 cm)
	const DETACH = 32.0;          // room units (~0.94 m): the thong's root this far from the handle's tip has come off it (WorldTick2)
	// A longer whip later (owner: a doubled "super whip" maybe) is LenMult() 2: every link twice as long, the same 25
	// nodes; the bend below (EI/lam over the link's length^4) and the coil's loop size follow the link by themselves.
	static double LenMult() { return 1.0; }
	static double WhipLen() { return NN * LINK * LenMult(); }

	// THE MODEL (11-02). Room units (34 a metre; map z x 1.2) and tics (35 a second). Measured on the rig: tools/rigtest
	// whp_metrics.py, HANDOFF.md.
	const SUB = 16;              // sub-steps a tic, always (rig: 16 x 2 passes keeps a link within ~1% at rest)
	const ITER = 2;              // length passes a sub-step
	const GRAV = 0.2723;         // 9.81 m/s^2 = 9.81 x 34 / 35^2 room units / tic^2
	const VMAX = 150.0;          // the speed cap, ALWAYS on: no link moves faster than this, room units a tic (~150 m/s)
	const FRIC = 0.6;            // a link lying on the floor keeps this share of its sliding speed a tic
	// The reference whip (3D_model_w_whip.xml): 25 nodes of 0.012 kg, 0.072 m apart; 2-DOF hinges, k = 0.242 N m/rad,
	// c = 0.092 N m s/rad. As a rod: bending rigidity EI = k l = 0.01742 N m^2, mass per length lam = 0.1667 kg/m,
	// bending damping c l = 0.006624 N m^2 s. Ours is that chain node for node (25 links of 2.448 room units):
	//   EI/lam = 0.1045 m^4/s^2 x 34^4 / 35^2 = 114.0 room^4/tic^2  -> a joint's omega^2 = 114 / 2.448^4 = 3.175 /tic^2,
	//            which is the reference joint's own k / (m l^2) = 0.242 / (0.012 x 0.072^2) = 3890 /s^2 = 3.175 /tic^2
	//   c/k    = 0.3802 s x 35              = 13.31 tics            -> the reference joint's damper against its spring
	// The reference's first joint is free because it is the hand (its arm is the handle). Ours is the end of a rigid
	// 24 cm handle the thong is set into, so it has the same spring and damper as every other joint.
	const REF_EI_LAM = 114.0;
	const REF_C_K = 13.31;

	const ST_IDLE = 0;
	const ST_OUT = 1;
	const ST_ROLL = 2;
	// 2026-11-27 (owner: "i want to tone this thing down"): the fields of the crack, the mark, the lock, the wrap, the
	// flail, the lasso and the rope went with them; these are the thong's, the hand's and the weapon's
	PlayerPawn wby[NW];
	int     wstate[NW];
	int     wage[NW];
	double  wext[NW];            // kept at 1 (11-02: the coil, cp, is what shortens the whip now)
	double  wlen[NW];            // the thong's full length, room units
	Vector3 wp[NW * NP];         // nodes, room space, now
	Vector3 wq[NW * NP];         // and one sub-step ago
	Vector3 wt[NW * NP];         // nodes in map space at the start of this tic (the sweep's start)
	Vector3 hb[NW], hd[NW];      // last tic's handle base (room) and direction (room, unit)
	Vector3 ab[NW], ad[NW];      // the same for the AIM line (the controller's): the wind-up reads it (Hand on the Handle)
	double  tipSpd[NW];          // fastest the tip went this tic, room units a tic
	double  handSpd[NW];         // the handle tip's recent speed, room units a tic (decays 7% a tic)
	bool    byWeapon[NW];        // this whip is the RSQWP_WhipWeapon's (weapon.zs): its model holds the handle
	int     reachTic[NW];        // the Ground Crack's flight (lash.zs): tics left until the thong lands
	Vector3 reachPt[NW];         // and where on the floor it lands (map)
	double  baseLen[NW];
	RSQWP_Rope wl[NW * NP];      // the drawn whip: piece 0 the handle, 1..NN the thong
	transient RSQWP_Tracer tracer;
	transient bool stopped[NP];  // Collide: the links a wall stopped this tic
	// THE BODY'S FRAME (owner 11-02: "whip fires on snap turn", "even just walking around with the whip it's going
	// insane"). The chain is carried rigidly with the body every tic -- moved with the pawn and turned with the tracking
	// space (Carry) -- before it is simulated, so only what the hand does RELATIVE TO THE BODY moves it.
	Vector3 bodyAt[NW];          // the pawn's position last tic (map)
	bool    bodyHad[NW];
	double  fkH0[MAXPLAYERS], fkH1[MAXPLAYERS];  // both controllers' world yaws last tic
	Vector2 fkR0[MAXPLAYERS], fkR1[MAXPLAYERS];  // and where they were off the pawn (flat)
	bool    fkHad[MAXPLAYERS];
	double  frameTurn[MAXPLAYERS];               // how far the tracking space turned this tic (a snap or stick turn)
	int     turnTic[MAXPLAYERS];                 // the last tic it turned (lash.zs: neither move starts on it)
	// THE WIND-UP (owner 11-02: "when we bring the whip back over our controller it needs to somehow go rigid"). Deliberate() and Sim.
	double  stiff[NW];           // 0 slack .. 1 rigid: the thong is pulled toward a straight line out of the handle
	int     windTics[NW];        // tics the hand has been wound up (at or over the shoulder, the handle up and back)
	int     windEnd[NW];         // the tic the wind-up was left (a swing may start within SWING_WAIT of it)
	bool    swinging[NW];        // wound up and now driving forward: the thong follows the handle like a rod
	bool    released[NW];        // the swing has let the thong go
	double  swingPk[NW];         // the handle's fastest in this swing
	// THE HANDLE'S PATH (11-02): the hand followed critically damped (rsqwp_whip_smooth), integrated sub-step by sub-step,
	// so the handle's speed never jumps at a tic's edge. In the body's frame like the chain (Carry).
	Vector3 fb[NW], fv[NW];      // the followed hand (room) and its speed (room units a tic)
	Vector3 fd[NW], fdv[NW];     // the followed handle direction (not kept unit) and its rate
	double  segWas[NW];          // last tic's link length (a change rescales the chain instead of yanking it)
	double  flo[NW * NP], cei[NW * NP];  // each link's floor and ceiling (room z), from its last Collide: the sub-steps meet them
	// RESTING ON A WALL (11-02): the wall a link was last stopped by or put back from (Collide, Mend): every sub-step
	// keeps it on this side.
	Line    wln[NW * NP];        // the wall's line (none: no contact)
	Vector2 wnv[NW * NP];        // its normal, toward the link's side
	double  wnd[NW * NP];        // the plane: n . xy >= this (0.5 off the wall)
	double  wlo[NW * NP], whi[NW * NP];  // a two-sided line blocks only under its opening's bottom / over its top (room z)
	int     stuckTics[NW];       // tics in a row a link was found on the far side of a wall (Mend)
	int     straightTic[NW];     // the last straighten (Mend)
	int     tendTic[NW];         // the whip weapon tended this hand this tic (weapon.zs Tend); a weapon whip nobody tends is gone
	bool    snapDraw[NW];        // the next Draw puts every piece where it is with no interpolation (Seat, Straighten on a jump)
	int     handMoveAt[MAXPLAYERS];  // Whip In: the next tic the whip may be moved to its hand
	// THE COIL (owner 11-02: "we hold it coiled ... shorten the length of it and extend it during the attack"). cp is how
	// many links are coiled (fractional), cps how fast that changes (links a tic, + = reeling in).
	double  cp[NW];              // links in the coil (0 = all out .. COIL_REST at rest .. NN rolled up)
	double  cps[NW];             // its rate, links a tic
	double  cgoal[NW];           // where it is going
	int     quiet[NW];           // tics the whip has been quiet (no wind-up, no swing, the tip and hand slow)
	Vector2 ch[NW];              // the coil's heading (flat, the handle's way): the coil hangs in that vertical plane
	static RSQWP_Whip Get() { return RSQWP_Whip(EventHandler.Find("RSQWP_Whip")); }
	// ---- THE GUN BONSAI VR PATCH'S WHIP TREE -----------------------------------------------------------------------
	// 2026-11-27 (owner: "i want to tone this thing down"): of the patch's whip nodes only LONG THONG still has
	// something to change here (the thong's length); the nodes of the moves that went are no longer read. Asked by name
	// once a second (RSQ_MeleeUpgradeService "level", on the weapon's own record); without the patch it is 0.
	transient int gbTic;
	transient int gbLong[MAXPLAYERS];
	void GbRefresh()
	{
		if (gbTic > 0 && level.maptime < gbTic && level.maptime >= gbTic - 35) return;
		gbTic = level.maptime + 35;
		let svc = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		// the patch's Unlock RSQ Features off ("loaded" 0, owner 2026-11-22): as without it
		if (svc && svc.GetInt("loaded") != 1) svc = null;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			Inventory w = (svc && playeringame[n] && players[n].mo) ? players[n].mo.FindInventory("RSQWP_WhipWeapon") : null;
			gbLong[n] = w ? max(0, svc.GetInt("level", "LongThong", 0, 0, w)) : 0;
		}
	}
	// LONG THONG: the thong x1.25, 1.5, 1.75 (2.25, 2.7, 3.15 m); every link longer, the same 25
	static double LongK(Actor pmo)
	{
		let w = Get();
		if (!w || !pmo || !pmo.player) return 1.0;
		return 1.0 + 0.25 * clamp(w.gbLong[pmo.PlayerNumber()], 0, 3);
	}

	static clearscope Vector3 ToRoom(Vector3 m) { return (m.x, m.y, m.z * RSQWP_Util.PS()); }
	static clearscope Vector3 ToMap(Vector3 r) { return (r.x, r.y, r.z / RSQWP_Util.PS()); }

	override void OnRegister()
	{
		for (int i = 0; i < NW; i++) if (!wby[i]) wstate[i] = ST_IDLE;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		for (int i = 0; i < NW; i++) { wstate[i] = ST_IDLE; wby[i] = null; }
	}

	// ---- input ------------------------------------------------------------------------------

	// 2026-11-27 (owner: "i want to tone this thing down"): the only events left are the hand's own place, sent each frame
	// by the machine that holds the controller (RenderOverlay). The bind whip's, the lock's, the aim key's and the off
	// grip's went.
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		if (e.Name ~== "rsqwp_hp0" || e.Name ~== "rsqwp_hp1")
		{
			int j = e.Player * 2 + (e.Name ~== "rsqwp_hp1" ? 1 : 0);
			hpRel[j] = (e.Args[0] / 256.0, e.Args[1] / 256.0, e.Args[2] / 256.0);
			hpTic[j] = level.maptime;
		}
	}

	// The whip comes into a hand (weapon.zs Tend): out of the hand coiled, a short tail hanging.
	void Start(int i, PlayerPawn pmo, int hand)
	{
		bool fresh = wstate[i] == ST_IDLE || wby[i] != pmo;
		wby[i] = pmo;
		wstate[i] = ST_OUT;
		wage[i] = 0;
		wlen[i] = WhipLen() * LongK(pmo);     // LONG THONG (Gun Bonsai VR)
		wext[i] = 1.0;
		handSpd[i] = 0; reachTic[i] = 0; baseLen[i] = wlen[i];
		LsReset(i);                           // lash.zs: the hand that drew it is not a swing or a crack
		lsLast[i] = level.maptime;
		Vector3 b, d;
		[b, d] = Handle(i, pmo, hand);
		hb[i] = b; hd[i] = d;
		Vector3 aimB, aimD;
		[aimB, aimD] = AimHandle(i, pmo, hand);
		ab[i] = aimB; ad[i] = aimD;
		bodyAt[i] = pmo.pos; bodyHad[i] = true;
		stiff[i] = 0; windTics[i] = 0; windEnd[i] = -100; swinging[i] = false; released[i] = false; swingPk[i] = 0; stuckTics[i] = 0; straightTic[i] = -100;
		Follow(i, b, d);
		quiet[i] = 0;
		// out of the hand COILED; taken up again while it was rolling up, it goes back to its rest coil from where it is
		cgoal[i] = double(COIL_REST);
		if (fresh)
		{
			cp[i] = cgoal[i]; cps[i] = 0; ch[i] = (0, 0);
			LayOut(i, b, d);
			snapDraw[i] = true;
		}
		Noise(pmo, 'unfurl', ToMap(b));
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d start len %.0f", i, wlen[i]);
	}

	// the whip weapon put away: roll it up
	void WeaponUp(int i, PlayerPawn pmo)
	{
		if (wstate[i] == ST_OUT && wby[i] == pmo) RollUp(i);
	}

	// SEAT THE WHIP ON THE HAND THAT DREW IT (owner 11-05 04:17: "when whip is taken from holster, the whip and handle are
	// far, far apart ... before we holstered it, it was fine, but now it's like two separate pieces"). The weapon came into
	// this hand while the whip was still out: the thong is laid out again from this hand's drawn handle (Handle), still,
	// the handle's smoothed path restarted there, the body's frame re-taken, and the next Draw puts every piece there with
	// no interpolation (snapDraw). Code only, not rig-tested, not headset-confirmed.
	void Seat(int i, PlayerPawn pmo, int hand)
	{
		if (!pmo || wstate[i] == ST_IDLE) return;
		Vector3 b, d;
		[b, d] = Handle(i, pmo, hand);
		Vector3 aimB, aimD;
		[aimB, aimD] = AimHandle(i, pmo, hand);
		bodyAt[i] = pmo.pos; bodyHad[i] = true;
		Straighten(i, b, d);
		hb[i] = b; hd[i] = d;
		ab[i] = aimB; ad[i] = aimD;
		handSpd[i] = 0; LsReset(i);
		snapDraw[i] = true;
		if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d SEAT t%d: drawn into the hand, the thong laid out from its handle", i, level.maptime);
	}

	void RollUp(int i)
	{
		if (wstate[i] != ST_OUT) return;
		wstate[i] = ST_ROLL;
		if (wby[i]) Noise(wby[i], 'unfurl', ToMap(hb[i]));
	}

	// The handle's base (the hand, room space) and its direction (room, unit): the controller as it is.
	Vector3, Vector3 Handle(int i, PlayerPawn pmo, int hand)
	{
		Vector3 b, d;
		[b, d] = AimHandle(i, pmo, hand);
		if (!byWeapon[i] || !HandOnHandle(pmo)) return b, d;
		// HAND ON THE HANDLE (owner 2026-11-03 19:25: the FBX hand's magazine hold, "assume the hand is set to receive a
		// vertical cylinder ... the whip handle"): the weapon whip's handle is the one drawn in that grip (MODELDEF
		// RSQWP_WhipWeapon, tools/gen_whiphand.py), RSQ Saber's hilt line: GRIP_UP above the aim, turned with the
		// controller's roll, its butt below the fist (handfit.zs). The simulated handle starts at the same butt and runs
		// the same line, so the thong leaves the drawn handle's tip. The wind-up still reads the aim line
		// (AimHandle: Deliberate, the hand's speed), so it is judged exactly as before.
		double yaw = RSQWP_Util.HandYaw(pmo, hand);
		double pit = RSQWP_Util.HandPitch(pmo, hand);
		double rol = hand == 0 ? pmo.AttackRoll : pmo.OffhandRoll;
		Vector3 fw = (cos(pit) * cos(yaw), cos(pit) * sin(yaw), sin(pit));
		Vector3 flatRight = (sin(yaw), -cos(yaw), 0);
		Vector3 levelUp = flatRight cross fw;
		double r = -rol;                 // the engine draws the hand rolled by -AttackRoll (RSQ Saber's BladeDirOf)
		Vector3 upv = levelUp * cos(r) - flatRight * sin(r);
		Vector3 right = flatRight * cos(r) + levelUp * sin(r);
		let cv = CVar.FindCVar('vr_control_scheme');
		bool leftHanded = cv && cv.GetInt() >= 10;
		bool physRight = (hand == 0) != leftHanded;
		Vector3 cardX = physRight ? right * HANDX_SIGN : -right * HANDX_SIGN;   // the engine mirrors the physical left hand
		let vu = CVar.FindCVar('vr_vunits_per_meter');
		double k = (vu ? vu.GetFloat() : 34.0) * 0.01;   // cm -> room units
		b += (fw * RSQWP_HandFit.BUTT_FWD + upv * RSQWP_HandFit.BUTT_UP + cardX * RSQWP_HandFit.BUTT_X) * k;
		d = fw * cos(RSQWP_HandFit.GRIP_UP) + upv * sin(RSQWP_HandFit.GRIP_UP);
		return b, d.Unit();
	}
	const HANDX_SIGN = 1.0;          // card +X along the physical right hand's right (rig-checked: the thong at the drawn tip)

	// the controller's own line (as the handle always was): the base at the hand, along the aim
	Vector3, Vector3 AimHandle(int i, PlayerPawn pmo, int hand)
	{
		Vector3 b = ToRoom(BodyHand(pmo, hand));
		double yaw = RSQWP_Util.HandYaw(pmo, hand);
		double pit = RSQWP_Util.HandPitch(pmo, hand);
		Vector3 d = (cos(pit) * cos(yaw), cos(pit) * sin(yaw), sin(pit));
		return b, d.Unit();
	}

	// Hand on the Handle (rsqwp_hand_handle, the player's own setting, on by default)
	static bool HandOnHandle(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return false;
		let cv = CVar.GetCVar("rsqwp_hand_handle", pmo.player);
		return !cv || cv.GetInt() != 0;
	}

	// ---- the tic ----------------------------------------------------------------------------

	double tickMs;               // last tic's cost, all whips (rsqwp_debug 2)

	override void WorldTick()
	{
		double t0 = MSTimeF();
		GbRefresh();
		WorldTick2();
		tickMs = MSTimeF() - t0;
		msSum += tickMs; msMax = max(msMax, tickMs); msN++;
		if (msN >= 70)
		{
			if (RSQWP_Util.Opt("rsqwp_debug", 0) == 3) Console.Printf("T_WPWMS t%d mean %.3f max %.3f ms over %d tics (sim %.3f, sweeps %.3f, draw %.3f)", level.maptime, msSum / msN, msMax, msN, msSim / msN, msCol / msN, msDraw / msN);
			msSum = 0; msMax = 0; msN = 0; msSim = 0; msCol = 0; msDraw = 0;
		}
	}
	double msSum, msMax, msSim, msCol, msDraw;
	int msN;

	// 2026-11-27 (owner: "what i want is to do a big wide swing ... and if i crack down to the ground", "i want to tone
	// this thing down"): one whip, one tic. The thong follows the hand (Carry, Deliberate, CoilTic, Sim, Collide, Mend,
	// Draw); the hand is read for the two moves (lash.zs LashTick) and a Ground Crack's thong flies to the floor (Reach).
	// The mark, the lock, the wrap, the lasso, the rope, the fetch and the fireballs are gone from here.
	void WorldTick2()
	{
		// the whip weapon is in every player's slot 1 while RSQ Whip is on (no console needed)
		if (level.maptime % 35 == 1 && RSQWP_Util.Flag("rsqwp_on", true) && RSQWP_Util.Flag("rsqwp_whip_weapon", true))
			for (int pn = 0; pn < MAXPLAYERS; pn++)
			{
				let pm = playeringame[pn] ? players[pn].mo : null;
				if (!pm || pm.Health <= 0 || pm.FindInventory("RSQWP_WhipWeapon")) continue;
				// as RSQ ShieldSaw gives its saw: never switch to it on the give, then set the slots up again so
				// KEYCONF's addslotdefault puts it in slot 1 whatever the player class (any mod's) lists
				pm.GiveInventory("RSQWP_WhipWeapon", 1);
				let wh = Weapon(pm.FindInventory("RSQWP_WhipWeapon"));
				if (wh && players[pn].PendingWeapon == wh) players[pn].PendingWeapon = WP_NOCHANGE;
				WeaponSlots.SetupWeaponSlots(pm);
			}
		TrackFrame();
		WhipIn();
		for (int i = 0; i < NW; i++)
		{
			if (wstate[i] == ST_IDLE) continue;
			let pmo = wby[i];
			if (!pmo || pmo.Health <= 0 || !RSQWP_Util.Flag("rsqwp_on", true)) { Halt(i); continue; }
			// ONE WHIP (owner 11-02: "moving whip to offhand causes me to have one in each hand"). The engine's hand
			// switch (PlayerPawn.SwitchWeaponHand: switchhand, Whip In, any mod's) moves the weapon by setting the hands'
			// pointers -- the old hand's Deselect never runs, so PutAway never ran and that hand's whip kept simulating
			// beside the new one. A weapon whip its weapon no longer tends (not in that hand any more) is gone.
			if (byWeapon[i] && level.maptime - tendTic[i] > 1)
			{
				if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d gone t%d: the whip weapon is no longer in that hand", i, level.maptime);
				Halt(i);
				continue;
			}
			int hand = i & 1;
			int pn = i / 2;
			wage[i]++;
			Carry(i, pmo, frameTurn[pn]);
			if (wstate[i] == ST_ROLL && cp[i] >= NN - 0.001) { Halt(i); continue; }
			Vector3 b, d;
			[b, d] = Handle(i, pmo, hand);
			Vector3 aimB, aimD;
			[aimB, aimD] = AimHandle(i, pmo, hand);
			// THE THONG OFF ITS HANDLE (owner 11-05 04:17: "the whip and handle are far, far apart"), or a hand that jumped
			// (a teleport, a load: 24 room units a tic is 24 m/s, no arm does that): its root (node 0) further from the
			// handle's tip than any lag of the smoothed handle reaches is a whip that came apart from its handle -- laid
			// out again from the hand
			double rootOff = ((hb[i] + hd[i] * HANDLEN) - wp[i * NP]).Length();
			double rootSlack = DETACH + handSpd[i] * (1.0 + 2.0 * clamp(RSQWP_Util.Num("rsqwp_whip_smooth", 0.8), 0.0, 4.0));
			if ((b - hb[i]).Length() > 24 || rootOff > rootSlack)
			{
				if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d RESEAT t%d: hand moved %.1f, thong root %.1f off the handle's tip (rootSlack %.1f)", i, level.maptime, (b - hb[i]).Length(), rootOff, rootSlack);
				Straighten(i, b, d);
				hb[i] = b; hd[i] = d;
				ab[i] = aimB; ad[i] = aimD;
				handSpd[i] = 0;
				snapDraw[i] = true;
			}
			for (int k = 0; k < NP; k++) wt[i * NP + k] = ToMap(wp[i * NP + k]);
			// how hard the hand has driven the handle lately (the AIM line's tip, decaying), relative to the body
			double hs = ((aimB + aimD * HANDLEN) - (ab[i] + ad[i] * HANDLEN)).Length();
			ab[i] = aimB; ad[i] = aimD;
			handSpd[i] = max(handSpd[i] * 0.93, hs);
			Deliberate(i, pmo, hand, aimD, hs);
			LashTick(i, pmo, hand);       // THE TWO MOVES (lash.zs): the Wide Swing, the Ground Crack
			Reach(i, pmo, hand);          // a Ground Crack's thong on its way to the floor
			CoilTic(i, hs);
			Vector3 peakAt, peakVel;
			double tA = MSTimeF();
			[peakAt, peakVel] = Sim(i, hb[i], hd[i], b, d);
			msSim += MSTimeF() - tA;
			hb[i] = b; hd[i] = d;
			tA = MSTimeF();
			Collide(i, pmo, hand);
			msCol += MSTimeF() - tA;
			Mend(i, pmo, b, d);
			tA = MSTimeF();
			Draw(i);
			msDraw += MSTimeF() - tA;
		}
	}

	// ---- the body's frame -------------------------------------------------------------------------------------

	// THE HAND AGAINST THE BODY, STEADY (rig 11-02: a still hand on a walking body moved 13 units up and down -- 46.2 to
	// 33.3 over the pawn -- and once 5 sideways; the whip read it as the arm and cracked). AttackPos.z is written per
	// rendered frame from the INTERPOLATED eye, view bob included (hw_openxrdevice.cpp: CenterEyePos.Z + the
	// controller's height); input.zs found the same for climbing. So the machine with the hands measures each frame
	// the controller against that same frame's eye (RenderEvent.ViewPos: height) and against the pawn (flat), and
	// sends it (rsqwp_hp0 / rsqwp_hp1, 1/256 unit); the whip puts it back on the pawn and its steady eye height
	// (SteadyEye: no bob, no step dip, no interpolation). Without a fresh one (2 tics), the engine's pose as before.
	Vector3 hpRel[NW];
	int     hpTic[NW];

	// the eye's steady height over the pawn: what player.viewheight settles to (P_CalcHeight's defaultviewheight,
	// real crouching included), without the dip a step or a landing puts in it for a few tics (rig: 41 -> 34 -> 41 on
	// every stair, which moved a still hand 7 units and cracked the whip) and without the bob
	static double SteadyEye(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return 0;
		return pmo.ViewHeight + pmo.player.crouchviewdelta;
	}

	Vector3 BodyHand(PlayerPawn pmo, int hand)
	{
		if (!pmo || !pmo.player) return RSQWP_Util.HandPos(pmo, hand);
		int j = pmo.PlayerNumber() * 2 + (hand & 1);
		if (level.maptime - hpTic[j] > 2 || !RSQWP_Util.PoseGood(pmo, hand)) return RSQWP_Util.HandPos(pmo, hand);
		return pmo.pos + (hpRel[j].x, hpRel[j].y, SteadyEye(pmo) + hpRel[j].z);
	}

	override void RenderOverlay(RenderEvent e)
	{
		let p = players[consoleplayer];
		if (!p || !p.mo || !p.mo.OverrideAttackPosDir) return;
		let mo = p.mo;
		int pn = consoleplayer;
		if (wstate[pn * 2] == ST_IDLE && wstate[pn * 2 + 1] == ST_IDLE) return;
		if (mo.AttackPos == mo.OffhandPos) return;      // the collapsed pose (a menu, a save): never a hand
		for (int hand = 0; hand < 2; hand++)
		{
			Vector3 h = hand == 0 ? mo.AttackPos : mo.OffhandPos;
			// PCVR (vr_mode 10, OpenVR) hangs the hands off the frame's interpolated eye in X/Y too (gl_openvr.cpp:1282
			// GetHandTransform: r_viewpoint.CenterEyePos = RenderEvent.ViewPos), and draws the handle there; against the pawn
			// the thong's root trailed the drawn handle by up to a tic of the body's motion. Measured from what this renderer
			// hung the hand on, as the series' HandSync does since 264493242. OpenXR (Quest): the pawn's X/Y as before.
			Vector3 ref = OpenVR() ? e.ViewPos : (mo.pos.x, mo.pos.y, e.ViewPos.z);
			Vector3 rel = h - ref;
			if (abs(rel.x) > 200 || abs(rel.y) > 200 || abs(rel.z) > 200) continue;
			EventHandler.SendNetworkEvent(hand ? "rsqwp_hp1" : "rsqwp_hp0", int(rel.x * 256), int(rel.y * 256), int(rel.z * 256));
		}
	}

	// QuestZDoom 17.3's VR_OPENVR (hw_vrmodes.h): PCVR through SteamVR
	static ui bool OpenVR() { let c = CVar.FindCVar('vr_mode'); return c && c.GetInt() == 10; }

	const TURN_TOL = 1.5;        // degrees: both controllers' yaws moved by the same amount within this ...
	const TURN_POS = 4.0;        // ... and both turned round the pawn by it within this (map units)

	// THE TRACKING SPACE'S TURN THIS TIC. On QuestZDoom the pawn's angle follows the HEADSET, so it is not the
	// turn: a head turn changes it and leaves the controllers where they were. A snap or stick turn turns the whole
	// tracking space -- both controllers' yaws by the same amount AND both their places round the pawn by it, in the
	// same tic. (The rig: the pawn's angle took the 45 one tic before the controllers did, so RSQ_Saber's way --
	// the angle and both yaws together -- would have missed it; the controllers alone see it whole.) A real arm can
	// only fool this by turning both wrists and both hands round the body by the same angle in one tic.
	void TrackFrame()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			frameTurn[pn] = 0;
			let pm = playeringame[pn] ? players[pn].mo : null;
			if (!pm || !pm.OverrideAttackPosDir || pm.AttackPos == pm.OffhandPos) { fkHad[pn] = false; continue; }
			double h0 = pm.AttackAngle, h1 = pm.OffhandAngle;
			Vector2 r0 = pm.AttackPos.xy - pm.pos.xy, r1 = pm.OffhandPos.xy - pm.pos.xy;
			if (fkHad[pn])
			{
				double d0 = Actor.DeltaAngle(fkH0[pn], h0), d1 = Actor.DeltaAngle(fkH1[pn], h1);
				// both controllers turned (rig 11-02: one hand's yaw noise, the other still, passed as sub-degree "turns"
				// that cancelled the noisy swing's crack)
				if (abs(d0) > 0.25 && abs(d1) > 0.25 && d0 * d1 > 0 && abs(d0 - d1) < TURN_TOL
					&& (Rot2(fkR0[pn], d0) - r0).Length() < TURN_POS && (Rot2(fkR1[pn], d0) - r1).Length() < TURN_POS)
				{
					frameTurn[pn] = (d0 + d1) * 0.5;
					turnTic[pn] = level.maptime;
					if (RSQWP_Util.Opt("rsqwp_debug", 0) >= 2) Console.Printf("T_WPW turn t%d player %d: %.1f deg (the tracking space)", level.maptime, pn, frameTurn[pn]);
				}
			}
			fkH0[pn] = h0; fkH1[pn] = h1; fkR0[pn] = r0; fkR1[pn] = r1; fkHad[pn] = true;
		}
	}

	static clearscope Vector2 Rot2(Vector2 v, double a)
	{
		double c = cos(a), s = sin(a);
		return (v.x * c - v.y * s, v.x * s + v.y * c);
	}
	static clearscope Vector3 Xf(Vector3 p, Vector3 r0, Vector3 r1, double c, double s)
	{
		Vector3 d = p - r0;
		return r1 + (d.x * c - d.y * s, d.x * s + d.y * c, d.z);
	}

	// CARRY THE WHIP WITH THE BODY: every node (now and a sub-step ago, so its speed comes along too), the handle,
	// and the lasso's hold are moved with the pawn and turned round it by the tracking space's turn. Walking,
	// a lift, a teleport, a snap turn or Brutal Doom moving you (a fatality) then put no motion into the thong at all.
	void Carry(int i, PlayerPawn pmo, double turn)
	{
		Vector3 nowAt = pmo.pos;
		if (!bodyHad[i]) { bodyAt[i] = nowAt; bodyHad[i] = true; return; }
		Vector3 r0 = ToRoom(bodyAt[i]), r1 = ToRoom(nowAt);
		bodyAt[i] = nowAt;
		if (r0 == r1 && turn == 0) return;
		double c = cos(turn), s = sin(turn);
		int o = i * NP;
		for (int k = 0; k < NP; k++)
		{
			wp[o + k] = Xf(wp[o + k], r0, r1, c, s);
			wq[o + k] = Xf(wq[o + k], r0, r1, c, s);
		}
		hb[i] = Xf(hb[i], r0, r1, c, s);
		hd[i] = (hd[i].x * c - hd[i].y * s, hd[i].x * s + hd[i].y * c, hd[i].z);
		ab[i] = Xf(ab[i], r0, r1, c, s);
		ad[i] = (ad[i].x * c - ad[i].y * s, ad[i].x * s + ad[i].y * c, ad[i].z);
		fb[i] = Xf(fb[i], r0, r1, c, s);
		fv[i] = (fv[i].x * c - fv[i].y * s, fv[i].x * s + fv[i].y * c, fv[i].z);
		fd[i] = (fd[i].x * c - fd[i].y * s, fd[i].x * s + fd[i].y * c, fd[i].z);
		fdv[i] = (fdv[i].x * c - fdv[i].y * s, fdv[i].x * s + fdv[i].y * c, fdv[i].z);
		ch[i] = (ch[i].x * c - ch[i].y * s, ch[i].x * s + ch[i].y * c);
		// A TURN OR A STEP carried links lying on the floor into it (a thong draped over a ledge, turned with you,
		// ends up under the ledge's top: rig 11-02, lifted by Collide and snapped back at 37 room units a tic). Such
		// links are lifted onto the floor here, with their last place, and the chain is held to length round them.
		if (turn == 0 && abs(r1.z - r0.z) < 2) return;
		int nLift = 0;
		int kc = int(cp[i]);
		for (int k = 0; k < NP; k++) stopped[k] = k <= kc;
		for (int k = kc + 1; k < NP; k++)
		{
			Vector3 m = ToMap(wp[o + k]);
			double fz, cz;
			[fz, cz] = OpenAt(m);
			flo[o + k] = fz * RSQWP_Util.PS(); cei[o + k] = cz * RSQWP_Util.PS();
			double dz = 0;
			if (m.z < fz) dz = (fz - m.z) * RSQWP_Util.PS();
			else if (m.z > cz) dz = (cz - m.z) * RSQWP_Util.PS();
			if (abs(dz) < 0.01) continue;
			wp[o + k] += (0, 0, dz); wq[o + k] += (0, 0, dz);
			stopped[k] = true; nLift++;
		}
		if (nLift) Relax(i);
	}

	// ---- the coil ---------------------------------------------------------------------------------------------
	//
	// Held coiled, the thong's first links lie on a loop that hangs from the handle's tip (a circle of COIL_R in the
	// vertical plane of the handle's heading, going forward and down from the tip, round under the hand, its loops
	// stepped COIL_P to the side), pinned there and moved with the handle like the handle itself. The rest -- a tail
	// of COIL_TAIL links -- is simulated as ever, hanging from the coil's end. Paying out unpins the coil's last link:
	// it was on the coil, moving with it, so it goes on from exactly there at exactly that speed (no pop). Reeling in
	// draws the free link next to the coil onto its place on the loop over the time it takes to reel one link, then
	// pins it. Nothing else about the model changes: the same springs, dampers and sub-steps on whatever is free.
	const COIL_TAIL = 4;          // links left hanging at rest: 4 x 7.2 cm = 0.29 m
	const COIL_REST = NN - COIL_TAIL;
	const COIL_R = 5.0;           // the loop's radius, room units (15 cm: a 30 cm coil), x LenMult
	const COIL_A = 45.0;          // where the handle's tip sits on the loop (degrees from its top, toward the side it hangs to)
	const COIL_P = 1.6;           // each loop's step to the side, room units
	const PAY_MAX = 3.5;          // paying out: at most this many links a tic (8.6 room units a tic) ...
	const PAY_ACC = 1.0;          // ... reached and left at this rate (links a tic a tic): 21 links out in ~10 tics (0.28 s)
	const REEL_MAX = 1.2;         // reeling in after a quiet spell: at most this, links a tic ...
	const REEL_ACC = 0.25;        // ... 21 links in in ~19 tics (0.55 s)
	const REEL_CAP = 5.0;         // while it reels in, no free link faster than this (room units a tic): the hand guides
	                              // it home (rig 11-02: uncapped, the dragged tail swung up into the coil at 26 a tic)
	const ROLL_MAX = 3.5;         // put away (the holster, the bind let go): the rest rolled up this fast
	const QUIET_TICS = 30;        // quiet this long (0.86 s) and it reels back into the coil ...
	const QUIET_TIP = 3.0;        // ... quiet = the tip slower than this (room units a tic, ~3 m/s) ...
	const QUIET_HAND = 1.2;       // ... and the handle's tip slower than this, no wind-up, swing or flight

	// how many nodes after the handle's tip are pinned (the coil's)
	int Pinned(int i)
	{
		return clamp(int(cp[i]), 0, NN);
	}

	// a place on the coil, a links in from the handle's tip (fractional: the coil's end between two nodes). The loops
	// face you (the plane across the handle's heading, so the eyes behind the hand see them round, not edge-on), hang
	// toward the body (side +1: to the heading's left, inward for the right hand) and step forward along the heading
	static Vector3 CoilAt(double a, Vector3 tip, Vector2 h, double seg, double side = 1.0, double lm = 1.0)
	{
		double r = COIL_R * LenMult() * lm;
		double dth = 2.0 * asin(min(0.95, seg / (2.0 * r)));
		double ph = COIL_A + a * dth;
		Vector3 sd = (-h.y * side, h.x * side, 0);
		Vector3 c = tip - ((0, 0, cos(COIL_A)) + sd * sin(COIL_A)) * r;
		return c + ((0, 0, cos(ph)) + sd * sin(ph)) * r + (h, 0) * (COIL_P * LenMult() * lm * a * dth / 360.0);
	}

	// the coil's size follows the whip's own length (Long Thong: a longer thong coils in bigger loops)
	double CoilK(int i) { return baseLen[i] / (NN * LINK * LenMult()); }

	// the coil hangs toward the body: to the heading's left in the right hand, to its right in the left
	double CoilSide(int i)
	{
		let pmo = wby[i];
		if (!pmo) return 1.0;
		let cv = CVar.FindCVar('vr_control_scheme');
		bool leftHanded = cv && cv.GetInt() >= 10;      // as Buzz: the main controller is the left one
		return ((i & 1) == 0) != leftHanded ? 1.0 : -1.0;
	}

	// the coil's heading follows the handle's (flat) way, eased, and is kept while the handle points straight up or down
	void CoilHeading(int i, Vector3 d)
	{
		Vector2 f = d.xy;
		double fl = f.Length();
		if (ch[i].Length() < 0.5) ch[i] = fl > 0.01 ? f / fl : (1, 0);
		if (fl < 0.25 * max(0.001, d.Length())) return;
		Vector2 n = ch[i] + (f / fl - ch[i]) * 0.35;
		double nl = n.Length();
		if (nl > 0.001) ch[i] = n / nl;
	}

	// THE COIL'S GOAL each tic: all out for a wind-up or a swing, or a Ground Crack's flight; rolled up when put away;
	// back to rest after QUIET_TICS of quiet; otherwise it stays where it is. Then its rate is eased toward the goal
	// (accelerated, and slowed to arrive): never a step.
	void CoilTic(int i, double hs)
	{
		bool attack = windTics[i] >= WIND_TICS || swinging[i] || (stiff[i] > 0.01 && !released[i]);
		bool busy = reachTic[i] > 0;
		if (wstate[i] == ST_ROLL) cgoal[i] = NN;
		else if (attack || busy) { cgoal[i] = 0; quiet[i] = 0; }
		else
		{
			if (windTics[i] == 0 && stiff[i] < 0.01 && tipSpd[i] < QUIET_TIP && hs < QUIET_HAND) quiet[i]++;
			else quiet[i] = 0;
			if (quiet[i] >= QUIET_TICS && cgoal[i] < COIL_REST)
			{
				cgoal[i] = COIL_REST;
				if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d REEL t%d: quiet %d tics, back into the coil", i, level.maptime, quiet[i]);
			}
		}
		bool paying = cgoal[i] < cp[i];
		double vmax = paying ? PAY_MAX : (wstate[i] == ST_ROLL ? ROLL_MAX : REEL_MAX);
		double acc = paying ? PAY_ACC : (wstate[i] == ST_ROLL ? PAY_ACC : REEL_ACC);
		double gap = cgoal[i] - cp[i];
		// the speed that still stops on the goal (v^2 = 2 a d), signed
		double want = (gap >= 0 ? 1 : -1) * min(vmax, sqrt(2.0 * acc * abs(gap)));
		double was = cps[i];
		if (cps[i] < want) cps[i] = min(want, cps[i] + acc);
		else cps[i] = max(want, cps[i] - acc);
		// it lands on the goal, never past it (a tic's step is cps)
		if ((gap >= 0 && cps[i] > gap) || (gap <= 0 && cps[i] < gap)) cps[i] = gap;
		if (cps[i] < -0.001 && was >= -0.001 && RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d UNCOIL t%d: paying out from %.1f to %.0f", i, level.maptime, cp[i], cgoal[i]);
	}

	// Laid out still: the coil's links on the coil, the rest hanging from its end (each link's last place = its place:
	// no speed). Start, Straighten.
	void LayOut(int i, Vector3 b, Vector3 d)
	{
		int o = i * NP;
		Vector3 tip = b + d * HANDLEN;
		double seg = max(0.5, wext[i] * wlen[i] / NN);
		CoilHeading(i, d);
		int c = int(cp[i]);
		Vector3 at = tip;
		for (int k = 0; k < NP; k++)
		{
			if (k <= c) at = k == 0 ? tip : CoilAt(k, tip, ch[i], seg, CoilSide(i), CoilK(i));
			else at += (0, 0, -seg);
			wp[o + k] = at; wq[o + k] = at;
			wt[o + k] = ToMap(at);
			flo[o + k] = -1e9; cei[o + k] = 1e9; wln[o + k] = null;
		}
		segWas[i] = seg;
	}

	// ---- the deliberate attack ---------------------------------------------------------------------------------

	const WIND_UP = 0.45;        // the handle at least this far up (sin of its pitch: ~27 degrees) ...
	const WIND_AHEAD = 0.35;     // ... and pointing no further ahead than this (cos to the body's facing): up and back
	const WIND_EYE = 14.0;       // ... with the hand no lower than this under the eyes (map units, ~40 cm): the shoulder
	const WIND_TICS = 2;         // held this long, the thong stiffens
	const WIND_RAMP = 0.12;      // stiffness gained a tic while wound up (the thong rises behind you over ~8 tics)
	const SWING_GO = 2.5;        // the handle's tip this fast (room units a tic) after a wind-up: the swing
	const SWING_WAIT = 10;       // a swing must start within this many tics of leaving the wind-up
	const RELEASE = 0.55;        // the swing lets the thong go when the handle slows below this of its peak
	const GUIDE_W = 1.5;         // at full stiffness each link is drawn to the line out of the handle as a spring of this
	                             // frequency (rad a tic), critically damped against the line's own motion ...
	const GUIDE_TIP = 0.75;      // ... less toward the popper (the tip lags the rod and whips over at the release)

	// THE WIND-UP stiffens the thong: the hand at or over the shoulder with the handle pointing up and back. Held
	// WIND_TICS, the thong is drawn toward a straight line out of the handle (Sim: GUIDE_W, less toward the tip), so
	// it rises behind you as one piece instead of flopping. THE SWING: from there the handle drives forward and the
	// thong follows it like a rod, the tip lagging; when the handle slows (RELEASE of its peak) the thong is let go
	// and the lag runs out through the tip -- then it goes slack and settles. Anything else
	// (lowering the arm, a slow sweep) lets the stiffness go in a few tics. (2026-11-27: this only shapes the thong now; it makes no hit.)
	void Deliberate(int i, PlayerPawn pmo, int hand, Vector3 d, double hs)
	{
		if (reachTic[i] > 0 || wstate[i] != ST_OUT)
		{
			windTics[i] = 0; swinging[i] = false; stiff[i] = max(0.0, stiff[i] - 0.34);
			return;
		}
		Vector3 hp = BodyHand(pmo, hand);
		double eye = pmo.pos.z + (pmo.player ? SteadyEye(pmo) : pmo.Height * 0.8);
		Vector2 fwd = Actor.AngleToVector(pmo.angle, 1);
		bool wound = d.z >= WIND_UP && (d.xy dot fwd) <= WIND_AHEAD && hp.z >= eye - WIND_EYE;
		if (wound)
		{
			windTics[i]++;
			windEnd[i] = level.maptime;
			swinging[i] = false;
			released[i] = false;
			swingPk[i] = 0;
			if (windTics[i] >= WIND_TICS)
			{
				if (stiff[i] < 0.01 && RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d WIND-UP t%d: the thong stiffens", i, level.maptime);
				stiff[i] = min(1.0, stiff[i] + WIND_RAMP);
			}
			return;
		}
		bool wasWound = windTics[i] >= WIND_TICS;
		windTics[i] = 0;
		if (!swinging[i] && !released[i] && stiff[i] > 0.01 && level.maptime - windEnd[i] <= SWING_WAIT && hs >= SWING_GO)
		{
			swinging[i] = true;
			swingPk[i] = hs;
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d SWING t%d: hand %.1f", i, level.maptime, hs);
		}
		if (swinging[i])
		{
			swingPk[i] = max(swingPk[i], hs);
			stiff[i] = min(1.0, stiff[i] + 0.25);
			if (hs < swingPk[i] * RELEASE)
			{
				swinging[i] = false;
				released[i] = true;
				stiff[i] = 0.3;          // let go of the rod: the lag runs out through the tip
				if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d RELEASE t%d: hand %.1f of peak %.1f", i, level.maptime, hs, swingPk[i]);
			}
			return;
		}
		// lowered without a swing, or the swing is over: slack again
		stiff[i] = max(0.0, stiff[i] - ((wasWound || level.maptime - windEnd[i] <= SWING_WAIT) ? 0.08 : 0.3));
	}

	// ---- never inside geometry --------------------------------------------------------------------------------

	const STUCK_MAX = 6;         // tics in a row with a link mended back out of a wall before the whip is laid out again

	// MEND THE CHAIN (owner 11-02: "it sticks into geometry and wiggles like hell"). The sweeps in Collide stop a
	// link that MOVES into a wall, but a link can also be PUT past one -- a wrap or a locked crack lays the outer half
	// along the line to a monster (HoldWrap, Reach), the length shrinking back after a wrap drags links round a
	// corner -- and then every tic the solver pulled it back through the wall and the sweep stopped it there: stuck,
	// shaking. Each tic, from the handle's tip out, each link must be in sight of the one before; one that is not
	// is put back on this side of what is between them, stopped. Stuck for STUCK_MAX tics in a row: the whip is laid
	// out again from the hand (Straighten); stuck again soon after: it is paid out again from the hand (re-coiled).
	void Mend(int i, PlayerPawn pmo, Vector3 b, Vector3 d)
	{
		int o = i * NP;
		let tr = GetTracer();
		tr.shooter = pmo;
		// the handle's tip (or the coil's end: the coil is held in the hand), from the body: a real hand can be through a
		// wall, and then there is nothing to mend from
		int kc = min(int(cp[i]), NN);
		Vector3 a = ToMap(wp[o + kc]);
		Vector3 from = pmo.pos + (0, 0, pmo.Height * 0.5);
		Vector3 fa = a - from;
		double fl = fa.Length();
		if (fl > 0.5 && tr.Trace(from, level.PointInSector(from.xy), fa / fl, fl, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType != TRACE_HitNone && tr.Results.Distance < fl - 0.5)
			return;
		int mended = 0;
		for (int k = 0; k < NP; k++) stopped[k] = k <= kc;
		for (int k = kc + 1; k < NP; k++)
		{
			Vector3 m = ToMap(wp[o + k]);
			Vector3 am = m - a;
			double l = am.Length();
			if (l > 0.05)
			{
				Vector3 u = am / l;
				// walls only: a floor or ceiling between two links is met by the floor clamp (Sim, Collide), and mending
				// it shortened a link that the next sub-step snapped back (rig 11-02: a 56 room units a tic spike at rest)
				if (tr.Trace(a, level.PointInSector(a.xy), u, l, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType == TRACE_HitWall && tr.Results.Distance < l - 0.25
					&& !Graze(tr, tr.Results.HitPos))
				{
					// put back across the wall along its normal, 0.75 on this side, keeping its place along the wall (it
					// was pulled back toward the link before, a link's length short, and the next sub-step snapped it out
					// again: rig 11-02, a thong piled at a wall's foot jolted at 30-50 room units a tic and cracked)
					Vector3 hp = tr.Results.HitPos;
					Vector3 back = a + u * max(0.0, tr.Results.Distance - 0.75);
					Line ml2 = tr.Results.HitLine;
					if (ml2)
					{
						Vector2 nd = (ml2.delta.y, -ml2.delta.x);
						double ndl = nd.Length();
						if (ndl > 0.0001)
						{
							nd /= ndl;
							if ((nd dot u.xy) > 0) nd = -nd;
							Vector3 nv = (nd, 0);
							Vector3 put = m - nv * ((m - hp) dot nv) + nv * 0.75;
							// only if that place is in sight of the link before it (else as before)
							Vector3 pa2 = put - a;
							double pl2 = pa2.Length();
							if (pl2 < 0.05 || !(tr.Trace(a, level.PointInSector(a.xy), pa2 / pl2, pl2, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType == TRACE_HitWall))
							{
								back = put;
								WallSet(o + k, ml2, nd, hp);
							}
						}
					}
					m = back;
					wp[o + k] = ToRoom(m);
					wq[o + k] = wp[o + k];
					stopped[k] = true;
					mended++;
				}
			}
			a = m;
		}
		if (!mended) { stuckTics[i] = 0; return; }
		Relax(i);    // the chain held to length round the mended links (it snapped back next sub-step: rig 11-02, 43 room units a tic)
		stuckTics[i]++;
		if (RSQWP_Util.Opt("rsqwp_debug", 0) >= 2) Console.Printf("T_WPW %d mend t%d: %d link(s) put back out of a wall (%d tics running)", i, level.maptime, mended, stuckTics[i]);
		if (stuckTics[i] < STUCK_MAX) return;
		bool again = level.maptime - straightTic[i] < 35;
		if (again) { cp[i] = max(cp[i], double(COIL_REST)); cps[i] = 0; cgoal[i] = cp[i]; quiet[i] = 0; }     // stuck again straight after: back in the coil
		Straighten(i, b, d);
		straightTic[i] = level.maptime;
		stuckTics[i] = 0;
		if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d STRAIGHTEN t%d: links kept ending up in a wall%s", i, level.maptime, again ? " (again: re-coiled from the hand)" : "");
	}

	// The floor and ceiling a link meets (map z, 0.4 inside). A link lying against a step's face sits ON the line, where
	// PointInSector may answer the upper sector: its floor was the step's top, 50 units over the link, and the clamp threw
	// links up the face (rig 11-02). A link well under the floor it was given is on a boundary: the lowest floor (and the
	// highest ceiling) of the sectors just round it count.
	static double, double OpenAt(Vector3 m)
	{
		let sec = level.PointInSector(m.xy);
		double fz = sec.floorplane.ZatPoint(m.xy), cz = sec.ceilingplane.ZatPoint(m.xy);
		if (m.z < fz - 2 || m.z > cz + 2)
		{
			static const double OX[] = { 1.5, -1.5, 0, 0 };
			static const double OY[] = { 0, 0, 1.5, -1.5 };
			for (int n = 0; n < 4; n++)
			{
				Vector2 p = m.xy + (OX[n], OY[n]);
				let s2 = level.PointInSector(p);
				if (s2 == sec) continue;
				fz = min(fz, s2.floorplane.ZatPoint(p));
				cz = max(cz, s2.ceilingplane.ZatPoint(p));
			}
		}
		return fz + 0.4, cz - 0.4;
	}

	// A link only BENT ROUND an edge, not through a wall: the segment to it cuts a ledge's lip, a lintel or a corner
	// (a line's end) by up to GRAZE_U, so Mend leaves it alone. Mending it collapsed the thong onto the lip and the next
	// tic snapped it back (rig 11-02: a thong lying over a step's lip, the tip jerked 83 units up at 257 room
	// units a tic). A thong lying over an edge is bent round it; Collide's sweeps keep its links out of the wall.
	const GRAZE_U = 2.3;          // map units: about a link (6.0 when a link was 6.4; rescaled 11-02 for MIT's 2.448)
	static bool Graze(RSQWP_Tracer tr, Vector3 at)
	{
		Line l = tr.Results.HitLine;
		if (l && ((at.xy - l.v1.p).Length() <= GRAZE_U || (at.xy - l.v2.p).Length() <= GRAZE_U)) return true;
		bool edge; double ez;
		[edge, ez] = Edge(tr, at);
		return edge && abs(at.z - ez) <= GRAZE_U;
	}

	// Laid out again from the handle's tip, hanging, still (each link's last place = its place: no speed). The floor
	// and walls are met by the next tic's Collide and Mend. The handle's path starts again at the hand.
	void Straighten(int i, Vector3 b, Vector3 d)
	{
		LayOut(i, b, d);
		stiff[i] = 0; swinging[i] = false;
		Follow(i, b, d);
	}

	// A link against a wall: remember the wall (its plane, and for a two-sided line the opening it does not block)
	void WallSet(int j, Line l, Vector2 n, Vector3 at)
	{
		wln[j] = l; wnv[j] = n; wnd[j] = (n dot at.xy) + 0.5;
		wlo[j] = 1e9; whi[j] = -1e9;          // one-sided: it blocks at every height
		if (l && l.frontsector && l.backsector)
		{
			double ps = RSQWP_Util.PS();
			wlo[j] = max(l.frontsector.floorplane.ZatPoint(at.xy), l.backsector.floorplane.ZatPoint(at.xy)) * ps;
			whi[j] = min(l.frontsector.ceilingplane.ZatPoint(at.xy), l.backsector.ceilingplane.ZatPoint(at.xy)) * ps;
		}
	}

	// the contact is over once the link is 4 units clear of the wall or past the line's ends
	void WallClear(int j, Vector3 m)
	{
		Line l = wln[j];
		if (!l) return;
		Vector2 d = l.delta;
		double ll = d.Length();
		double u = ll > 0.0001 ? ((m.xy - l.v1.p) dot d) / ll : 0;
		if ((wnv[j] dot m.xy) - wnd[j] > 4.0 || u < -2.0 || u > ll + 2.0) wln[j] = null;
	}

	// the handle's path starts again at the hand, still
	void Follow(int i, Vector3 b, Vector3 d)
	{
		fb[i] = b; fv[i] = (0, 0, 0); fd[i] = d; fdv[i] = (0, 0, 0);
	}

	// ---- one whip, in the hand you chose (Whip In) --------------------------------------------------------------

	// WHIP IN (owner 11-02: "need option: Whip in: Mainhand / Offhand", rsqwp_whip_hand, a user setting). The whip
	// weapon belongs to the chosen hand: out of both hands it is flagged for that hand, so selecting it (slot 1 in
	// that hand, or `use`) brings it up there; held in the other hand, it is moved by the engine's own hand switch
	// (PlayerPawn.SwitchWeaponHand), at most once a second. The old hand's whip goes (WorldTick2: untended).
	void WhipIn()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			let pm = playeringame[pn] ? players[pn].mo : null;
			if (!pm || !pm.player || pm.Health <= 0 || pm.player.playerstate != PST_LIVE) continue;
			let wh = Weapon(pm.FindInventory("RSQWP_WhipWeapon"));
			if (!wh) continue;
			let cv = CVar.GetCVar("rsqwp_whip_hand", pm.player);
			int want = cv ? clamp(cv.GetInt(), 0, 1) : 0;
			let p = pm.player;
			bool inMain = p.ReadyWeapon == wh, inOff = p.OffhandWeapon == wh;
			if (!inMain && !inOff)
			{
				if (p.PendingWeapon != wh) wh.bOffhandWeapon = want == 1;
				continue;
			}
			if ((want == 1 && inOff) || (want == 0 && inMain)) continue;
			if (p.PendingWeapon != WP_NOCHANGE || level.maptime < handMoveAt[pn]) continue;
			handMoveAt[pn] = level.maptime + 35;
			wh.bNoHandSwitch = false;
			pm.SwitchWeaponHand(want);
			if (RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW Whip In t%d player %d: moved to the %s hand (main %s, off %s)", level.maptime, pn, want ? "off" : "main",
					p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none', p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
		}
	}

	// THE THONG, one tic: SUB sub-steps from last tic's hand (b0, d0) to this tic's (b1, d1), the same every tic.
	// Each sub-step: the handle moves along its smooth path (the hand followed critically damped); every link moves
	// on by its own speed (air drag, gravity, the speed cap); the wind-up draws the thong toward the line out of the
	// handle (stiff, Deliberate); the reference whip's spring and damper bend every joint straighter; the links are
	// held to their length; links under a floor or over a ceiling are stopped there (sliding on the floor). Returns
	// where the tip was when it went fastest this tic (map space) and its velocity there (room units a tic).
	Vector3, Vector3 Sim(int i, Vector3 b0, Vector3 d0, Vector3 b1, Vector3 d1)
	{
		int o = i * NP;
		double seg = max(0.5, wext[i] * wlen[i] / NN);
		// THE LENGTH CHANGED (a Ground Crack's flight coming back): every link and its last place are scaled together
		// from the handle, so the change puts no jolt into the thong
		if (segWas[i] > 0.0001 && abs(seg - segWas[i]) > 0.0001)
		{
			double r = seg / segWas[i];
			Vector3 ap = wp[o], aq = wq[o], cp2 = wp[o], cq = wq[o];
			for (int k = 1; k < NP; k++)
			{
				Vector3 dp = wp[o + k] - ap, dq = wq[o + k] - aq;
				ap = wp[o + k]; aq = wq[o + k];
				cp2 = cp2 + dp * r; cq = cq + dq * r;
				wp[o + k] = cp2; wq[o + k] = cq;
			}
		}
		segWas[i] = seg;
		double h = 1.0 / SUB;
		// the bend: XPBD on C = p[j+1] - 2 p[j] + p[j-1] (|C| = seg x the bend angle); with equal links the masses
		// cancel into the joint's own frequency (compl = 1 / (omega h)^2) and the damper's ratio (gam = c/k / h)
		double bendK = clamp(RSQWP_Util.Num("rsqwp_whip_bend", 1.0), 0.05, 20.0);
		// the reference's own damper (x1, rsqwp_whip_bend_damp; owner 11-02: "the math is correct with MIT")
		double dampK = clamp(RSQWP_Util.Num("rsqwp_whip_bend_damp", 1.0), 0.0, 20.0);
		// at most as stiff as the whole whip's links (a reach or a wrap lengthens them; nothing makes them shorter)
		double segB = max(seg, baseLen[i] / NN);
		double seg2 = segB * segB;
		double wb2 = REF_EI_LAM * bendK / (seg2 * seg2);
		double compl = 1.0 / (wb2 * h * h);
		double gam = REF_C_K * dampK / bendK / h;
		double drag = 1.0 - clamp(RSQWP_Util.Num("rsqwp_whip_drag", 1.0), 0.0, 10.0) / 35.0 * h;
		// THE COIL this tic: from cp0 links coiled, at cps a tic (CoilTic); its heading eased from h0 to h1
		double cp0 = cp[i], rate = cps[i];
		double cs = CoilSide(i);
		double cpEnd = clamp(cp0 + rate, 0.0, double(NN));
		Vector2 h0 = ch[i];
		CoilHeading(i, d1);
		Vector2 h1 = ch[i];
		double cap = (rate > 0 ? REEL_CAP : VMAX) * h;
		double fric = FRIC ** h;
		// the hand followed critically damped: 2nd order, omega = 2 / lag (a steady motion trails by lag tics)
		double lag = RSQWP_Util.Num("rsqwp_whip_smooth", 0.8);
		double om = lag >= 0.2 ? 2.0 / min(lag, 4.0) : 0.0;
		Vector3 g = (0, 0, -GRAV * h * h);
		bool guide = stiff[i] > 0.01;
		Vector3 B = fb[i], BV = fv[i], D = fd[i], DV = fdv[i];
		double pl = D.Length();
		Vector3 pd = pl > 0.001 ? D / pl : d0;         // the handle's direction and tip a sub-step ago
		Vector3 pa = wp[o];
		double cpPrev = cp0;
		Vector3 pE = cp0 > 0 ? CoilAt(cp0, pa, h0, seg, cs, CoilK(i)) : pa;   // the coil's end a sub-step ago
		double best = -1;
		Vector3 bestAt = ToMap(wp[o + NN]), bestVel = (0, 0, 0);
		for (int s = 1; s <= SUB; s++)
		{
			double t = s * h;
			Vector3 tb = b0 + (b1 - b0) * t;
			Vector3 td = d0 + (d1 - d0) * t;
			if (om > 0)
			{
				Vector3 acc = (tb - B) * (om * om) - BV * (2 * om);
				BV += acc * h; B += BV * h;
				acc = (td - D) * (om * om) - DV * (2 * om);
				DV += acc * h; D += DV * h;
			}
			else { B = tb; D = td; }
			double dl = D.Length();
			Vector3 dir = dl > 0.001 ? D / dl : d1;
			Vector3 anchor = B + dir * HANDLEN;
			double cpn = clamp(cp0 + rate * t, 0.0, double(NN));
			int c = int(cpn);
			Vector2 hv = h0 + (h1 - h0) * t;
			double hvl = hv.Length();
			hv = hvl > 0.001 ? hv / hvl : h1;
			int kp = c;     // the coil's links are pinned
			for (int k = 1; k < NP; k++)
			{
				Vector3 v = (wp[o + k] - wq[o + k]) * drag;
				double vl = v.Length();
				if (vl > cap) v *= cap / vl;
				wq[o + k] = wp[o + k];
				wp[o + k] = wp[o + k] + v + g;
			}
			wq[o] = wp[o];
			wp[o] = anchor;
			// THE COIL: its links on the loop hanging from the handle's tip, moved with it (a link just let out of it goes
			// on from its place on the loop at the loop's own speed: its last place was there too)
			for (int k = 1; k <= c && k < NP; k++) wp[o + k] = CoilAt(k, anchor, hv, seg, cs, CoilK(i));
			Vector3 E = cpn > 0 ? CoilAt(cpn, anchor, hv, seg, cs, CoilK(i)) : anchor;
			// THE WIND-UP AND THE SWING (Deliberate): each free link drawn to its place on the line out of the handle --
			// out of the coil's end while it still pays out -- as a spring of GUIDE_W x stiff (less toward the popper)
			// critically damped against the line's own motion (XPBD), so it rises as one piece and follows the handle like
			// a rod, the tip lagging -- and never flung there
			if (guide)
			{
				for (int k = kp + 1; k < NP; k++)
				{
					double oh = GUIDE_W * stiff[i] * (1.0 - GUIDE_TIP * double(k) / NN) * h;
					if (oh < 0.0001) continue;
					double gg = 2.0 / oh;
					Vector3 want = E + dir * (seg * (k - cpn));
					Vector3 cc = wp[o + k] - want;
					Vector3 dc = (wp[o + k] - wq[o + k]) - (want - (pE + pd * (seg * (k - cpPrev))));
					wp[o + k] = wp[o + k] - (cc + dc * gg) * (oh * oh / (1.0 + (1.0 + gg) * oh * oh));
				}
			}
			// THE BEND (the reference's springs and dampers): the handle's joint first, against a fixed point one
			// link back up the handle, then every joint of the thong (the coil's last pinned link is the first free
			// link's fixed neighbour)
			if (kp == 0)
			{
				Vector3 pv = anchor - dir * seg, qv = pa - pd * seg;
				Vector3 cc = wp[o + 1] - anchor * 2 + pv;
				Vector3 dc = (wp[o + 1] - wq[o + 1]) - (anchor - pa) * 2 + (pv - qv);
				wp[o + 1] = wp[o + 1] - (cc + dc * gam) / ((1.0 + gam) + compl);
			}
			for (int j = max(1, kp); j < NN; j++)
			{
				double wa = j - 1 > kp ? 1.0 : 0.0;
				double wm = j > kp ? 1.0 : 0.0;
				Vector3 cc = wp[o + j + 1] - wp[o + j] * 2 + wp[o + j - 1];
				Vector3 dc = (wp[o + j + 1] - wq[o + j + 1]) - (wp[o + j] - wq[o + j]) * 2 + (wp[o + j - 1] - wq[o + j - 1]);
				Vector3 corr = (cc + dc * gam) / (-((1.0 + gam) * (wa + 4.0 * wm + 1.0) + compl));
				if (wa > 0) wp[o + j - 1] = wp[o + j - 1] + corr;
				if (wm > 0) wp[o + j] = wp[o + j] - corr * 2;
				wp[o + j + 1] = wp[o + j + 1] + corr;
			}
			// THE LENGTH: every link held to seg (equal masses; the handle's tip, the coil does not move)
			for (int it = 0; it < ITER; it++)
			{
				for (int k = kp; k < NN; k++)
				{
					Vector3 dd = wp[o + k + 1] - wp[o + k];
					double l = dd.Length();
					if (l < 0.0001) continue;
					if (k > kp)
					{
						Vector3 c2 = dd * (0.5 * (l - seg) / l);
						wp[o + k] = wp[o + k] + c2;
						wp[o + k + 1] = wp[o + k + 1] - c2;
					}
					else wp[o + k + 1] = wp[o + k + 1] - dd * ((l - seg) / l);
				}
			}
			// REELING IN: the free link next to the coil is drawn onto its place on the loop, arriving as the coil
			// reaches it (each sub-step it covers its share of what is left), then it is pinned there
			if (rate > 0 && c < NN)
			{
				int n = c + 1;
				double f = cpn - c, df = rate * h;
				double frac = min(1.0, df / max(df, 1.0 - f + df));
				wp[o + n] = wp[o + n] + (CoilAt(n, anchor, hv, seg, cs, CoilK(i)) - wp[o + n]) * frac;
			}
			// the floor and the ceiling each link last met (Collide): stopped there, sliding on the floor
			for (int k = kp + 1; k < NP; k++)
			{
				Vector3 p = wp[o + k];
				if (p.z < flo[o + k])
				{
					Vector3 q = wq[o + k];
					wp[o + k] = (p.x, p.y, flo[o + k]);
					// its speed into the floor goes (kept, the push up became a fling: rig 11-02, walking down stairs)
					wq[o + k] = (p.x - (p.x - q.x) * fric, p.y - (p.y - q.y) * fric, flo[o + k]);
				}
				else if (p.z > cei[o + k]) { wp[o + k] = (p.x, p.y, cei[o + k]); wq[o + k] = (wq[o + k].x, wq[o + k].y, cei[o + k]); }
				// a wall it rests on (WallSet): kept on this side, its speed into the wall gone, sliding along it
				if (wln[o + k])
				{
					p = wp[o + k];
					if (p.z < wlo[o + k] || p.z > whi[o + k])
					{
						Vector2 n = wnv[o + k];
						double sd = (n dot p.xy) - wnd[o + k];
						if (sd < 0)
						{
							Vector2 nxy = p.xy - n * sd;
							Vector2 q2 = wq[o + k].xy;
							double vn = ((nxy - q2) dot n);
							if (vn < 0) q2 += n * vn;
							wp[o + k] = (nxy, p.z);
							wq[o + k] = (q2, wq[o + k].z);
						}
					}
				}
			}
			pa = anchor; pd = dir; pE = E; cpPrev = cpn;
			Vector3 tv = (wp[o + NN] - wq[o + NN]) * SUB;
			double sp = tv.Length();
			if (sp > best) { best = sp; bestAt = ToMap(wp[o + NN]); bestVel = tv; }
		}
		cp[i] = cpEnd;
		fb[i] = B; fv[i] = BV; fd[i] = D; fdv[i] = DV;
		// never a broken number: a NaN anywhere (it cannot come from the model; belt and braces) lays the whip out again
		Vector3 tp = wp[o + NN];
		if (tp.x != tp.x || tp.y != tp.y || tp.z != tp.z) { Straighten(i, b1, d1); best = 0; bestAt = ToMap(wp[o + NN]); bestVel = (0, 0, 0); }
		tipSpd[i] = best;
		return bestAt, bestVel;
	}

	// The chain held to length again round the links marked in stopped[] (they do not move); each moved link is moved
	// with its last place, so the move is not turned into speed. After Collide's stops and Carry's lifts.
	void Relax(int i)
	{
		int o = i * NP;
		double seg = max(0.5, wext[i] * wlen[i] / NN);
		int k0 = Pinned(i);
		// 12 passes, every other one from the tip back: the 25 short links of the reference whip carry a correction
		// across the chain far more slowly than the old 20 long ones did (rig 11-02: 4 one-way passes left a link
		// 7x long where the tip was stopped on MAP01's platform lip)
		for (int it = 0; it < 12; it++)
		{
			for (int kk = k0; kk < NN; kk++)
			{
				int k = (it & 1) ? NN - 1 - (kk - k0) : kk;
				bool f0 = k > k0 && !stopped[k], f1 = !stopped[k + 1];
				if (!f0 && !f1) continue;
				Vector3 dd = wp[o + k + 1] - wp[o + k];
				double l = dd.Length();
				if (l < 0.0001) continue;
				Vector3 c = dd * ((l - seg) / l);
				if (f0 && f1) { wp[o + k] += c * 0.5; wq[o + k] += c * 0.5; wp[o + k + 1] -= c * 0.5; wq[o + k + 1] -= c * 0.5; }
				else if (f0) { wp[o + k] += c; wq[o + k] += c; }
				else { wp[o + k + 1] -= c; wq[o + k + 1] -= c; }
			}
		}
	}

	// Floors, ceilings and walls, swept from where each link was at the start of the tic. The coil's links are the
	// handle's (held in the hand): not swept. 2026-11-27 (owner: "exactly" two moves, "i want to tone this thing down"):
	// the thong meets no thing any more -- no sting on what it passes through, no edge to catch.
	bool Collide(int i, PlayerPawn pmo, int hand)
	{
		int o = i * NP;
		let tr = GetTracer();
		tr.shooter = pmo;
		int nStop = 0;
		int kc = int(cp[i]);
		for (int k = 0; k < NP; k++) stopped[k] = k <= kc;
		for (int k = kc + 1; k < NP; k++)
		{
			Vector3 m = ToMap(wp[o + k]);
			Vector3 m0 = wt[o + k];
			WallClear(o + k, m);
			Vector3 mv = m - m0;
			double ml = mv.Length();
			if (ml > 0.5)
			{
				Vector3 dir = mv / ml;
				bool any = tr.Trace(m0, level.PointInSector(m0.xy), dir, ml + 0.5, 0, RSQWP_Tracer.WALLMASK, true, pmo);
				// a floor or a ceiling crossed: the sub-steps already met it (flo/cei) and the clamp below puts the link on
				// its own sector's; stopping it at the straight sweep's crossing point teleported a link sliding along
				// the floor back to where the chord met it (rig 11-02: a link 96% too long after the crack landed)
				if (any && tr.Results.HitType != TRACE_HitNone && tr.Results.HitType != TRACE_HitFloor && tr.Results.HitType != TRACE_HitCeiling)
				{
					Vector3 at = tr.Results.HitPos;
					// THE WALL'S RESPONSE (11-02): the link keeps the part of its move ALONG the wall and loses only the
					// part into it (it stopped dead before: a tip at the foot of a step was put back there every tic while
					// the wind-up pulled it up the face -- rig 11-02, a link 250% long for 12 tics); its speed into the wall
					// goes, its speed along it keeps FRIC a tic
					Line wl2 = tr.Results.HitLine;
					Vector3 nv = (0, 0, 0);
					if (wl2)
					{
						Vector2 nd = (wl2.delta.y, -wl2.delta.x);
						double ndl = nd.Length();
						if (ndl > 0.0001) { nd /= ndl; if ((nd dot dir.xy) > 0) nd = -nd; nv = (nd, 0); WallSet(o + k, wl2, nd, at); }
					}
					Vector3 rest = m - at;
					Vector3 tang = nv == (0, 0, 0) ? (0, 0, 0) : rest - nv * (rest dot nv);
					Vector3 from = at + (nv == (0, 0, 0) ? -dir : nv) * 0.5;
					m = from;
					double tl = tang.Length();
					if (tl > 0.05)
					{
						Vector3 tu = tang / tl;
						if (tr.Trace(from, level.PointInSector(from.xy), tu, tl + 0.5, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType != TRACE_HitNone && tr.Results.HitType != TRACE_HitActor)
							m = from + tu * max(0.0, tr.Results.Distance - 0.5);
						else m = from + tang;
					}
					Vector3 v = wp[o + k] - wq[o + k];
					double vn = v dot nv;
					if (vn < 0) v -= nv * vn;
					wp[o + k] = ToRoom(m);
					wq[o + k] = wp[o + k] - v * FRIC;
					stopped[k] = true; nStop++;
					continue;
				}
			}
			// the floor and the ceiling under and over the link
			double fz, cz;
			[fz, cz] = OpenAt(m);
			flo[o + k] = fz * RSQWP_Util.PS(); cei[o + k] = cz * RSQWP_Util.PS();
			if (m.z < fz || m.z > cz)
			{
				m.z = m.z < fz ? fz : cz;
				Vector3 r = ToRoom(m);
				Vector3 v = wp[o + k] - wq[o + k];
				wq[o + k] = r - (v.x * FRIC, v.y * FRIC, 0);   // drags along the floor
				// a link lifted onto a floor (or put under a ceiling) is held there for the relax only if it was moved
				// much: one that just slid over a lip's corner is still the chain's to relax (rig 11-02: a link lifted 1.4 onto
				// MAP01's platform lip and held there left the next one, stopped under the lip, a link 7x long)
				if (abs(r.z - wp[o + k].z) > 3.0) { stopped[k] = true; nStop++; }
				wp[o + k] = r;
			}
		}
		// A LINK STOPPED BY A WALL (or put back on a floor it fell through between sub-steps) left its neighbours a link
		// too far or too near (the stop is at the tic's straight sweep, the sub-steps were not straight): the chain is
		// held to length again round the stopped links, so the next tic does not start by snapping it back (rig 11-02:
		// the snap-back was a 40-60 room units a tic jolt of the tip as the thong lay over a step's lip).
		if (nStop) Relax(i);
		return false;
	}

	const REACH_TICS = 5;

	// A GROUND CRACK'S FLIGHT (lash.zs GroundCrack sets reachPt and reachTic): the thong pays out to the spot on the floor
	// over REACH_TICS (its length grows to the distance and the outer links are drawn along the line to it, the physics
	// doing the rest) and lands there: the impact (lash.zs GroundImpact). Then it comes back to its own length.
	// 2026-11-27 (owner: "if i crack down to the ground the impact sends out a shockwave"): this was the pointed crack's
	// flight to a monster, a pickup or a switch; the floor is the only place it goes now.
	void Reach(int i, PlayerPawn pmo, int hand)
	{
		if (reachTic[i] <= 0)
		{
			if (wlen[i] > baseLen[i]) wlen[i] = max(baseLen[i], wlen[i] - 24);
			return;
		}
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 roomTo = ToRoom(reachPt[i]) - ToRoom(org);
		double dist = roomTo.Length();
		wlen[i] = max(baseLen[i], dist + 8);
		double f = 1.0 - double(reachTic[i] - 1) / REACH_TICS;    // 0.2 .. 1.0
		int o = i * NP;
		// lay the outer half along the line to the spot, the tip at f of the way
		for (int k = NN / 2; k < NP; k++)
		{
			double u = double(k - NN / 2) / (NN - NN / 2);
			Vector3 want = ToRoom(org) + roomTo * (f * (0.5 + 0.5 * u));
			// the move is this tic's, so the link's last sub-step is a sixteenth of it behind: the sim reads speed as
			// (wp - wq) x SUB (11-02 review: wq = the old place read a tic's move as a sub-step's, 100-490 room/tic)
			Vector3 mv = (want - wp[o + k]) * 0.6;
			wp[o + k] = wp[o + k] + mv;
			wq[o + k] = wp[o + k] - mv / SUB;
		}
		reachTic[i]--;
		if (reachTic[i] > 0) return;
		GroundImpact(i, pmo, hand, reachPt[i]);
	}

	// An EDGE, not a flat wall (Mend's Graze reads it: a link only bent round a lip or a lintel is left alone). A
	// two-sided line hit just under its lintel or just under its ledge lip, or a 3D floor's side near its top.
	static bool, double Edge(RSQWP_Tracer tr, Vector3 at)
	{
		if (tr.Results.HitType != TRACE_HitWall) return false, 0;
		if (tr.Results.ffloor)
		{
			double top = tr.Results.ffloor.top.ZatPoint(at.xy);
			return at.z <= top + 1 && top - at.z <= 16, top + 1;
		}
		Line l = tr.Results.HitLine;
		if (!l || !l.frontsector || !l.backsector) return false, 0;
		double openTop = min(l.frontsector.ceilingplane.ZatPoint(at.xy), l.backsector.ceilingplane.ZatPoint(at.xy));
		double openBot = max(l.frontsector.floorplane.ZatPoint(at.xy), l.backsector.floorplane.ZatPoint(at.xy));
		if (openTop - openBot < 4) return false, 0;                         // a closed door is a wall
		if (at.z >= openTop - 1) return at.z - openTop <= 24, openTop - 1;   // under a lintel or beam
		if (at.z <= openBot + 1) return openBot - at.z <= 16, openBot + 1;   // just under a ledge's lip
		return false, 0;
	}

	RSQWP_Tracer GetTracer()
	{
		if (!tracer) tracer = new("RSQWP_Tracer");
		return tracer;
	}

	// THE WHIP'S OWN DAMAGE TYPE (owner 11-02: "attacking enemy and bring it to me causes me to do a brutaldoom melee,
	// this then bugs out the whip"). Every hurt was DamageType 'Melee', and Brutal Doom's monsters answer a 'Melee'
	// hurt with their stealth kill: Pain.Melee / Death.Melee -> StealthKill -> A_GiveToTarget GoFatality, GoSpecial
	// and SK<monster> to the player (brutal22test6 Imps.dec 343-348, 738-739, 1297-1305; XMVE's the same), and the
	// player's Brutal Doom class then plays its fatality / execution (rig 11-02, the owner's order: a whip kill on an
	// imp that had not seen you gave GoFatality + SKImp + GoSpecial and the player jumped into his fatality states).
	// 'Whip' is a type no Brutal Doom or XMVE actor has a state or factor for: their plain Pain and Death, full damage.
	static Name DmgType() { return 'Whip'; }

	// ---- looks ------------------------------------------------------------------------------

	// The whip's sounds, at a point, through a tiny actor that carries them. 2026-11-27 (owner: "big wide swing", "crack
	// down to the ground"): the light crack is the Wide Swing's, the heavy one the Ground Crack's impact; the swish is
	// the Ground Crack leaving the hand.
	void Noise(PlayerPawn pmo, Name what, Vector3 at)
	{
		String s;
		double vol = 1.0;
		if (what == 'crack') s = "rsqwp/whip/cracklight";
		else if (what == 'crackheavy') s = "rsqwp/whip/crackheavy";
		else if (what == 'swish') { s = "rsqwp/whip/swish"; vol = 0.7; }
		else if (what == 'unfurl') { s = "rsqwp/whip/unfurl"; vol = 0.45; }
		if (s == "") return;
		let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		if (c) c.A_StartSound(s, CHAN_VOICE, 0, vol);
	}

	// A pulse in the hand holding the whip (the series' route: RSQ ShieldSaw's QF_WAVE quake,
	// felt with vr_quake_haptic_level > 0).
	void Buzz(PlayerPawn pmo, int hand, double amp, int tics)
	{
		if (!pmo || !pmo.player || pmo.player != players[consoleplayer]) return;
		if (amp <= 0) return;
		let q = RSQWP_WhipBuzz(Actor.Spawn("RSQWP_WhipBuzz", pmo.pos, NO_REPLACE));
		if (!q) return;
		let cv = CVar.FindCVar('vr_control_scheme');
		bool leftHanded = cv && cv.GetInt() >= 10;
		bool right = (hand == 0) != leftHanded;
		q.feels = pmo; q.left = !right; q.amp = amp; q.total = tics; q.tleft = tics;
	}

	// The handle and the plaited thong: core's rope tube (rsqrope.md3) in the whip's skins,
	// tapering from the handle to the popper.
	void Draw(int i)
	{
		int o = i * NP;
		double w0 = RSQWP_Util.Num("rsqwp_rope_width", 0.6) * 1.15;
		Vector3 base = ToMap(hb[i]);
		for (int k = 0; k < NP; k++)
		{
			Vector3 pa = k == 0 ? base : ToMap(wp[o + k - 1]);
			Vector3 pb = ToMap(wp[o + k]);
			double w = k == 0 ? 0.69 * 1.7 : w0 * max(0.18, 1.0 - 0.8 * (k - 1.0) / NN);   // the handle keeps its size whatever the thong's thickness
			RSQWP_Rope r = wl[o + k];
			bool fresh = false;
			if (!r)
			{
				r = RSQWP_Rope(Actor.Spawn(k == 0 ? "RSQWP_WhipHandle" : "RSQWP_WhipLink", pa, NO_REPLACE));
				wl[o + k] = r;
				fresh = true;
			}
			if (!r) continue;
			// HAND ON THE HANDLE: the weapon's own model draws the handle in the hand (no lag against the hand); this
			// world piece stays hidden, the thong starts at its tip all the same
			r.bINVISIBLE = k == 0 && byWeapon[i] && wby[i] && HandOnHandle(wby[i]) && !RSQWP_Util.Flag("rsqwp_handtest", false);
			if (!fresh) r.SetOrigin(pa, !snapDraw[i]);     // a snap (Seat, a re-laid thong): no smear from where it was
			Vector3 room = ToRoom(pb - pa);
			double l = room.Length();
			if (l < 0.01) { r.scale = (w, 0.001); if (fresh || snapDraw[i]) r.ClearInterpolation(); continue; }
			r.angle = atan2(room.y, room.x);
			r.pitch = -atan2(room.z, room.xy.Length()) + 90;
			r.scale = (w, l / RSQWP_Rope.ROPE_L);
			if (fresh || snapDraw[i]) r.ClearInterpolation();
		}
		snapDraw[i] = false;
	}

	void Halt(int i)
	{
		wstate[i] = ST_IDLE;
		byWeapon[i] = false;
		wby[i] = null;
		reachTic[i] = 0;
		stiff[i] = 0; swinging[i] = false; windTics[i] = 0; stuckTics[i] = 0; bodyHad[i] = false;
		LsReset(i);
		for (int k = 0; k < NP; k++)
		{
			if (wl[i * NP + k]) wl[i * NP + k].Destroy();
			wl[i * NP + k] = null;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < NW; i++) if (wstate[i] != ST_IDLE) Halt(i);
	}
}

// The thong's pieces and the handle: core's rope tube with the whip's skins (MODELDEF).
// Subclasses of RSQWP_Rope, so every tracer that skips the rope skips the whip.
class RSQWP_WhipLink : RSQWP_Rope {}
class RSQWP_WhipHandle : RSQWP_Rope {}

// Carries a sound at a point (the tip, the crack), then goes.
class RSQWP_WhipTip : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
	}
	States
	{
	Spawn:
		TNT1 A 90;
		Stop;
	}
}

// A pulse in one controller: X of a QF_WAVE quake drives the left, Y the right, faded over
// its length (RSQ ShieldSaw's SSQ_Buzzer; felt with vr_quake_haptic_level > 0).
class RSQWP_WhipBuzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;
	Default { +NOINTERACTION +NOBLOCKMAP +DONTSPLASH +NOTIMEFREEZE }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels || tleft <= 0) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		double a = amp * tleft / double(max(1, total)) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}
	States { Spawn: TNT1 A 40; Stop; }
}

// RSQ VISUALREWARDS' MARKERS (owner 11-02): it asks every service whose name holds "RSQTHP_Marker" whether a monster
// shows the WHIPPED mark (handler.zs MarkersOf). 2026-11-27 (owner: "i want to tone this thing down"): the wrap, the
// lasso and the Bola that set the mark went, so nothing is whipped that way: the answer is always 0. The class is
// kept so the question still has someone to answer it.
class RSQTHP_MarkerWhip : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return 0;
	}
}
