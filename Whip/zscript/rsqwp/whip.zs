// THE WHIP (PROJECT WHIP, 2026-10-30). rsqwp_whip 1 turns the hook binds into a bullwhip.
//
// A REAL WHIP, SIMULATED (rebuilt 11-02 on a validated research whip: Moses C. Nah, MIT Newman Lab, "Whip Project --
// Targeting with a Whip", github MosesAndLily/whip-project-targeting, BSD-3; its numbers are used, see the constants).
// The thong is a chain of NN links, position-based (XPBD): every tic SUB sub-steps, each one integrating the links,
// then the reference whip's BEND SPRING AND DAMPER at every joint, then the links held to length. One model always:
// no rest/active/calm switching -- the same sub-steps, springs, damping and speed cap whatever the whip is doing.
// The handle is driven along a smooth path (the hand followed critically damped, sub-step by sub-step), so a hand
// that jumps a little each tic never kicks the thong. Nothing is scripted:
//
//   * THE CRACK is the tip going fast: when the tip's speed in a tic passes the crack speed
//     (rsqwp_whip_crack, room units a tic) it cracks THERE, where the loop arrived. A lazy
//     swing never cracks; a lift and a snap of the forearm, or a flick of the wrist, does.
//     The handle is a rigid 24 cm stick in your hand, so turning the wrist whips the thong.
//   * THE DROOP is gravity on a slack thong, so it says how much the whip is loaded.
//   * IT HITS what it touches when it is moving fast (the outer half of the thong, swept
//     from where each link was to where it is, so a fast lash cannot pass through a thing
//     between two tics), harder the faster; the crack hits hardest, knocks the thing into its
//     Pain (which breaks off the attack it was winding up), throws a switch it lands on, and
//     flicks a loose pickup to you. A fast tip that meets something ABOVE the hand wraps round
//     it and becomes core's rope: swing, reel and let go are core's own.
//
// THE BINDS (the hook's two). Real (rsqwp_whip_mode 0): hold the bind and the whip uncoils
// from that hand; it hangs from the hand and does what your hand does; let go and it rolls up.
// Assist (1): a press throws a lash for you (the same simulated whip, the handle driven over
// the shoulder and snapped down) and it rolls up after. With RSQ_Accessibility's Hold to
// Toggle, Real is press-out, press-in.
//
// ROOM SPACE. The engine squashes map Z by pixelstretch (1.2), so the chain is simulated in
// room units (map z x 1.2), where lengths and speeds mean the same in every direction, and
// put back into map space to draw and to trace.
//
// NO EDIT TO CORE'S INPUT. This handler runs after core's on the same network event
// (registered after RSQWP_Input in MAPINFO): when the whip is on, the claw core just fired
// (phase FLY, age 0) is taken back before it moves a unit.
class RSQWP_Whip : EventHandler
{
	const NW = MAXPLAYERS * 2;
	// THE LENGTH (owner 11-02: "Length = MIT's exactly"): the reference whip's own 25 links of 0.072 m = 1.8 m of
	// thong (3D_model_w_whip.xml: body_whip_node1..25, 0.0720 apart), in room units (34 a metre): a link is 2.448.
	const NN = 25;               // links in the thong; node 0 is the handle's tip
	const NP = NN + 1;
	const LINK = 2.448;          // 0.072 m x 34 room units a metre
	const HANDLEN = 8.0;          // the handle, map units (~24 cm)
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

	PlayerPawn wby[NW];
	int     wstate[NW];
	int     wmode[NW];           // 0 real, 1 assist
	int     wage[NW];
	double  wext[NW];            // kept at 1 (11-02: the coil, cp, is what shortens the whip now; the probe reads it)
	double  wlen[NW];            // the thong's full length, room units
	Vector3 wp[NW * NP];         // nodes, room space, now
	Vector3 wq[NW * NP];         // and one sub-step ago
	Vector3 wt[NW * NP];         // nodes in map space at the start of this tic (the sweep's start)
	Vector3 hb[NW], hd[NW];      // last tic's handle base (room) and direction (room, unit)
	double  tipSpd[NW];          // fastest the tip went this tic, room units a tic
	bool    armed[NW];
	bool    swished[NW];
	int     calm[NW];
	int     cracks[NW];          // cracks this draw (debug and the service)
	bool    pend[NW];            // past the crack speed, waiting for the peak
	double  pkSpd[NW], rearm[NW];
	Vector3 pkAt[NW], pkVel[NW];
	int     crackTic[NW];
	int     fullTics[NW];        // tics the thong has been out enough to crack (CRACK_COILED links or fewer still coiled)
	int     lk[NW];              // the lasso: how many links the off hand holds (where it gripped; LassoHeld)
	bool    lassoed[NW];         // the flight under way is a lasso's throw (Reach: Lasso 2's longer hold, Bola)
	double  handSpd[NW];         // the handle tip's recent speed, room units a tic (decays 7% a tic: the wave takes a third of a second to reach the tip)
	Actor   whit[NW * 4];        // the last few things this lash has hit (once each per lash)
	int     whitTic[NW * 4];
	bool    whitCrack[NW * 4];
	int     lashUntil[NW];       // the crack's lash: the thong still lands as hard as the crack for a few tics
	// LOCK (rsqwp_whip_aim 2): the other hand points, the whip hand's alt-fire holds the lock
	bool    lockHeld[NW];
	bool    byWeapon[NW];        // this whip is the RSQWP_WhipWeapon's (weapon.zs): alt-fire locks, its model holds the handle
	int     lockLeft[NW];        // tics the lock lasts after the button is let go
	Actor   lockOn[NW];          // the locked monster or pickup, or
	Vector3 lockAt[NW];          // the point on a locked switch line
	bool    lockLine[NW];
	int     reachTic[NW];        // a locked crack's flight: tics left to reach the target
	Actor   reachFor[NW];
	Vector3 reachPt[NW];
	double  baseLen[NW];
	Vector3 pumpOff[NW];         // the whip hand's offset from the body last tic (the arm pump)
	int     mantleTic[MAXPLAYERS];   // tics left of a mantle (rising, then onto the top)
	double  mantleTop[MAXPLAYERS];   // the floor he is going up onto
	Vector2 mantleFwd[MAXPLAYERS];   // and which way it lies
	Vector2 mantleLip[MAXPLAYERS];   // the lip, in 2D
	bool    pumpHad[NW];
	// THE WHIP WEAPON (weapon.zs, owner 2026-10-31): mark with the trigger, cycle with alt-fire, pull by gesture, lasso
	bool    markHeld[NW];        // the trigger is held: the whip hand marks
	bool    markNext[NW];        // alt-fire: the mark moves on to the next nearest
	Line    markLine[NW];        // a marked switch
	bool    markKept[NW];        // the mark is held where the hand no longer points (rsqwp_whip_marklock)
	int     wrapTic[NW];         // when the whip wrapped round wrapOn (rsqwp_whip_yankgrace)
	bool    graceArm[NW];        // the grace is over but the pull under way when it ended does not count yet
	Array<Actor> knocked;        // missiles a crack knocked away (rsqwp_whip_fireball_knock 1): logged where they blow up
	Array<double> knockX, knockY, knockZ;
	Actor   wrapOn[NW];          // the monster the whip is wrapped round, waiting for the pull
	int     wrapUntil[NW];
	Vector3 pullOff[NW];         // the whip hand's offset from the body last tic
	bool    pullHad[NW];
	double  pullPk[NW];          // the pull so far (its peak, map units a tic)
	bool    lassoOn[NW], lassoWas[NW];
	Vector3 lassoP0[NW], lassoP1[NW];   // the off hand holding the thong, last tic and now (room)
	// THE WHIRL (11-02, owner: "most fun for the player"): the circle the off hand draws while it holds the lasso
	double  lw[NW];              // the whirl assist, 0..1: ramps in while the hand circles, out after (never a flip)
	Vector3 lc[NW];              // the circle's centre (room; carried with the body)
	Vector3 lom[NW];             // its angular velocity (rad a tic, the axis by the right-hand rule)
	double  lvw[NW];             // the tip's speed over the whirl (smoothed): what a let-go throws at
	bool    lcHad[NW];
	// owner's picks 2026-10-31 (teardown apply/08 3.1, apply/01 4.2 and 5.2, surveys/01_MELEE 3.6 and 4.11, 06_GRAB 4.6)
	double  crackV[NW];          // the tip's speed at the last crack (room units a tic): the crack's damage and its lash's
	bool    offGripKey[MAXPLAYERS];  // the off controller's grip key is down (raw key scan, rsqwp_keys_off): the Quest lasso
	transient bool gripSettled;  // the first tic after a load: no key reads as held (its release never comes)
	double  flailL[NW];          // a wrapped monster: the rope's length to it (map units, flat) ...
	double  flailOff[NW];        // ... and its bearing from the whip hand's yaw when it was wrapped
	bool    flailPin[NW];        // it was pinned in its Pain state (tics -1) while it swings, and is let go on unwrap
	Actor   smashOn[NW];         // the monster it last smashed into, and when (once per FLAIL_AGAIN tics)
	int     smashTic[NW];
	Array<Actor> missiles;       // missiles alive in the level (Crack Fireballs): a PROJECTILE is NOBLOCKMAP, no iterator finds it
	transient Array<Actor> cA;
	transient Array<Line> cL;
	transient Array<double> cK;
	transient Array<double> cPx, cPy, cPz;
	RSQWP_Rope wl[NW * NP];      // the drawn whip: piece 0 the handle, 1..NN the thong
	transient RSQWP_Tracer tracer;
	transient bool stopped[NP];  // Collide: the links a wall stopped this tic
	// THE BODY'S FRAME (owner 11-02: "whip fires on snap turn", "even just walking around with the whip it's going
	// insane"). The thong was simulated in the world, so everything the BODY did reached it as a swing: walking dragged
	// it, a snap turn swung the hand (and the handle) 45 degrees round the body in one tic. Now the chain is carried
	// rigidly with the body every tic -- moved with the pawn and turned with the tracking space (Carry) -- before it is
	// simulated, so only what the hand does RELATIVE TO THE BODY moves it (and only that counts toward a crack).
	Vector3 bodyAt[NW];          // the pawn's position last tic (map)
	bool    bodyHad[NW];
	double  fkH0[MAXPLAYERS], fkH1[MAXPLAYERS];  // both controllers' world yaws last tic
	Vector2 fkR0[MAXPLAYERS], fkR1[MAXPLAYERS];  // and where they were off the pawn (flat)
	bool    fkHad[MAXPLAYERS];
	double  frameTurn[MAXPLAYERS];               // how far the tracking space turned this tic (a snap or stick turn)
	int     turnTic[MAXPLAYERS];                 // the last tic it turned
	// THE DELIBERATE ATTACK (owner 11-02: "when we bring the whip back over our controller it needs to somehow go rigid
	// and attack in a deliberate sense"). Deliberate() and Sim.
	double  stiff[NW];           // 0 slack .. 1 rigid: the thong is pulled toward a straight line out of the handle
	int     windTics[NW];        // tics the hand has been wound up (at or over the shoulder, the handle up and back)
	int     windEnd[NW];         // the tic the wind-up was left (a swing may start within SWING_WAIT of it)
	bool    swinging[NW];        // wound up and now driving forward: the thong follows the handle like a rod
	bool    released[NW];        // the swing has let the thong go (its crack may come now)
	double  swingPk[NW];         // the handle's fastest in this swing
	// THE HANDLE'S PATH (11-02): the hand followed critically damped (rsqwp_whip_smooth), integrated sub-step by sub-step,
	// so the handle's speed never jumps at a tic's edge. In the body's frame like the chain (Carry).
	Vector3 fb[NW], fv[NW];      // the followed hand (room) and its speed (room units a tic)
	Vector3 fd[NW], fdv[NW];     // the followed handle direction (not kept unit) and its rate
	double  segWas[NW];          // last tic's link length (a change rescales the chain instead of yanking it)
	double  flo[NW * NP], cei[NW * NP];  // each link's floor and ceiling (room z), from its last Collide: the sub-steps meet them
	// RESTING ON A WALL (11-02): the wall a link was last stopped by or put back from (Collide, Mend): every sub-step
	// keeps it on this side (WallKeep). A thong lying at a wall's foot crept in by less than the sweep's threshold each
	// tic, Mend put it back, and after 6 tics of that it was laid out again from the hand (rig 11-02: a Straighten).
	Line    wln[NW * NP];        // the wall's line (none: no contact)
	Vector2 wnv[NW * NP];        // its normal, toward the link's side
	double  wnd[NW * NP];        // the plane: n . xy >= this (0.5 off the wall)
	double  wlo[NW * NP], whi[NW * NP];  // a two-sided line blocks only under its opening's bottom / over its top (room z)
	int     stuckTics[NW];       // tics in a row a link was found on the far side of a wall (Repair)
	int     straightTic[NW];     // the last straighten (Repair)
	int     tendTic[NW];         // the whip weapon tended this hand this tic (weapon.zs Tend); a weapon whip nobody tends is gone
	int     handMoveAt[MAXPLAYERS];  // Whip In: the next tic the whip may be moved to its hand
	// THE COIL (owner 11-02: "we hold it coiled ... shorten the length of it and extend it during the attack"). Not
	// attacking, the inner links lie in a coil held at the handle (pinned to it, drawn as the thong) and only a short
	// tail hangs live from the coil's end. A wind-up pays the coil out link by link at the handle's end; a quiet whip
	// reels back in. cp is how many links are coiled (fractional), cps how fast that changes (links a tic, + = reeling
	// in): it is accelerated toward its goal, never flipped, so neither the payout nor the reel ever starts in one tic.
	double  cp[NW];              // links in the coil (0 = all out .. COIL_REST at rest .. NN rolled up)
	double  cps[NW];             // its rate, links a tic
	double  cgoal[NW];           // where it is going
	int     quiet[NW];           // tics the whip has been quiet (no wind-up, no swing, the tip and hand slow)
	Vector2 ch[NW];              // the coil's heading (flat, the handle's way): the coil hangs in that vertical plane
	double  lb[NW];              // the lasso's hold: 0..1, how firmly the off hand's piece is held on its line
	RSQWP_LockRing markRing[NW]; // the lock mark (the series' diamond): gold ring ...
	RSQWP_LockCentre markCen[NW];// ... white centre

	static RSQWP_Whip Get() { return RSQWP_Whip(EventHandler.Find("RSQWP_Whip")); }

	// ---- THE GUN BONSAI VR PATCH'S WHIP TREE (GBOVR_TREES.md 4.4) ----------------------------------------------------
	// The whip weapon's node levels, asked by name once a second (RSQ_MeleeUpgradeService "level", on the weapon's own
	// record). Without the patch Gb is -1 everywhere and every row is as it was. With it, the rows the tree takes over
	// (Lasso, Snag, Mantle, Keep the Swing's Speed, Crack Fireballs, knock away, hit-stop) are its nodes. Three class
	// names carry "Whip" (WhipStun, WhipStrikeTrue, WhipMomentum): Stun, Strike True and Momentum are other trees'.
	const G_STING = 0;
	const G_STUN = 1;
	const G_CRACKSHOT = 2;
	const G_RETURN = 3;
	const G_STRIKE = 4;
	const G_LONG = 5;
	const G_QUICK = 6;
	const G_HEAVY = 7;
	const G_LASSO = 8;
	const G_BOLA = 9;
	const G_SNAG = 10;
	const G_MANTLE = 11;
	const G_MOMENTUM = 12;
	const G_TARZAN = 13;
	const G_PULL = 14;
	const G_N = 15;
	static const String GBN[] = { "Sting", "WhipStun", "CrackShot", "ReturnCrack", "WhipStrikeTrue", "LongThong", "QuickMark",
		"HeavyYank", "Lasso", "Bola", "Snag", "Mantle", "WhipMomentum", "Tarzan", "PullAndPunch" };
	transient int gbTic;
	transient bool gbOn;
	transient int gbLv[MAXPLAYERS * 15];
	void GbRefresh()
	{
		if (gbTic > 0 && level.maptime < gbTic && level.maptime >= gbTic - 35) return;
		gbTic = level.maptime + 35;
		let svc = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		gbOn = svc != null;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			Inventory w = (svc && playeringame[n] && players[n].mo) ? players[n].mo.FindInventory("RSQWP_WhipWeapon") : null;
			for (int g = 0; g < G_N; g++) gbLv[n * G_N + g] = w ? max(0, svc.GetInt("level", GBN[g], 0, 0, w)) : 0;
		}
	}
	// a player's level of a whip node: -1 without the patch, 0 for nobody
	static int Gb(Actor pmo, int g)
	{
		let w = Get();
		if (!w || !w.gbOn) return -1;
		if (!pmo || !pmo.player) return 0;
		return w.gbLv[pmo.PlayerNumber() * G_N + g];
	}
	// an option row the tree takes over: the row without the patch, the node learned with it
	static bool Unlock(Actor pmo, int g, String cv, bool fb)
	{
		int l = Gb(pmo, g);
		return l < 0 ? RSQWP_Util.Flag(cv, fb) : l >= 1;
	}
	static bool GbAny(int g)
	{
		for (int n = 0; n < MAXPLAYERS; n++) if (playeringame[n] && players[n].mo && Gb(players[n].mo, g) >= 1) return true;
		return false;
	}
	// LONG THONG: the thong x1.25, 1.5, 1.75 (2.25, 2.7, 3.15 m); every link longer, the same 25
	static double LongK(Actor pmo) { return 1.0 + 0.25 * clamp(Gb(pmo, G_LONG), 0, 3); }
	// HEAVY YANK: the mass under which a yanked monster flies to you 400 -> 600, 800, 1000 (the Light Monster row's
	// number when that is more)
	static double LightMass(Actor pmo)
	{
		double l = RSQWP_Util.Num("rsqwp_whip_light", 400);
		int h = Gb(pmo, G_HEAVY);
		return h > 0 ? max(l, 400.0 + 200.0 * h) : l;
	}
	// SNAG 2: edges from the hand's height up snag (the Edge Height row, 16 above it, at level 1 and without the patch)
	static double SnagAbove(Actor pmo) { return Gb(pmo, G_SNAG) >= 2 ? 0.0 : RSQWP_Util.Num("rsqwp_whip_above", 16); }
	// MOMENTUM 2-3: the rope swing's speed cap 30 -> 36, 42 (the swing only: the flail and the yank keep the row's)
	static double SwingCap(Actor pmo)
	{
		double c = RSQWP_Util.Num("rsqwp_max_speed", 30);
		int l = Gb(pmo, G_MOMENTUM);
		return l >= 2 ? c + 6.0 * (l - 1) : c;
	}
	// Gun Bonsai VR's "stagger" / "knockdown" (by name; nothing without it)
	static void Ask(String req, Actor v, int n)
	{
		let s = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		if (s && v) s.GetInt(req, "", n, 0, v);
	}
	// RSQ Score's combo ledger (by name; nothing without it)
	static void Touch(String id, Actor pawn, Actor victim)
	{
		if (!pawn || !pawn.player || !victim) return;
		let s = ServiceIterator.Find("RS_ScoreService").Next();
		if (s) s.GetInt("touch", id, pawn.PlayerNumber(), 0, victim);
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

	// Is a whip out in this hand? (the service and the hook ask)
	static bool IsOut(PlayerPawn pmo, int hand)
	{
		let w = Get();
		if (!w || !pmo || !pmo.player) return false;
		int i = pmo.PlayerNumber() * 2 + (hand & 1);
		return w.wstate[i] != ST_IDLE && w.wby[i] == pmo;
	}

	// ---- input ------------------------------------------------------------------------------

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		int hand = e.Args[0] & 1;
		int i = e.Player * 2 + hand;
		let pmo = players[e.Player].mo;
		if (!pmo) return;
		if (false) {}
		else if (e.Name ~== "rsqwp_up")
		{
			if (wstate[i] == ST_OUT && wmode[i] == 0 && wby[i] == pmo) RollUp(i);
		}
		else if (e.Name ~== "rsqwp_lock")
		{
			lockHeld[i] = e.Args[1] != 0;
			if (lockHeld[i]) lockLeft[i] = 35;
		}
		else if (e.Name ~== "rsqwp_hp0" || e.Name ~== "rsqwp_hp1")
		{
			int j = e.Player * 2 + (e.Name ~== "rsqwp_hp1" ? 1 : 0);
			hpRel[j] = (e.Args[0] / 256.0, e.Args[1] / 256.0, e.Args[2] / 256.0);
			hpTic[j] = level.maptime;
		}
		else if (e.Name ~== "rsqwp_aimkey")
		{
			aimBtn[e.Player] = e.Args[0] != 0;
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW aim key %s t%d", aimBtn[e.Player] ? "down" : "up", level.maptime);
		}
		else if (e.Name ~== "rsqwp_ogrip")
		{
			offGripKey[e.Player] = e.Args[0] != 0;
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW grip key (off) %s t%d", offGripKey[e.Player] ? "down" : "up", level.maptime);
		}
	}

	// ---- the Quest lasso (pick 7) -----------------------------------------------------------

	// Is the off hand closing on this whip? Its grip -- the raw key, or a grab bind (Grab Whip (Off), or
	// RSQ_DistanceGrab's grips) -- held, with the off controller within rsqwp_lasso_reach of the handle or
	// the inner thong (the links up to twice where the lasso holds it). Once it holds the thong it keeps it
	// while the grip stays down: a whirling hand is the thong. Positions only (apply/01 5.2), so it is the
	// same on Quest (OpenXR, no two-hand latch) and on SteamVR.
	bool OffHandCloses(int i, PlayerPawn pmo)
	{
		if (!pmo || !pmo.player || wstate[i] != ST_OUT || wby[i] != pmo) return false;
		int pn = pmo.PlayerNumber();
		let core = RSQWP_Core.Get();
		bool grip = offGripKey[pn] || (core && core.grabHeld[pn * 2 + 1]);
		if (!grip) return false;
		if (lassoOn[i]) return true;
		if (!RSQWP_Util.PoseGood(pmo, 1)) return false;
		double reach = RSQWP_Util.Num("rsqwp_lasso_reach", 0.30);
		Vector3 off = ToRoom(BodyHand(pmo, 1));
		int o = i * NP;
		double best = (off - hb[i]).Length();
		for (int k = 0; k < NP; k++) best = min(best, (off - wp[o + k]).Length());
		double m = best / 34.0;      // room units to metres, as RSQWP_Util.Metres counts them
		if (m > reach) return false;
		if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d LASSO grip t%d: the off hand %.2f m from the thong (%s)", i, level.maptime, m, offGripKey[pn] ? "grip key" : "grab bind");
		return true;
	}

	// THE OFF CONTROLLER'S GRIP, for the Quest lasso (owner's pick 7; teardown apply/01 5.2: from the hand's
	// position, never the SteamVR latch). Stock QuestZDoom never puts the grip in cmd.buttons (surveys/08 W5);
	// it arrives as a key, read here by scan code as RSQ_DistanceGrab's near.zs and RSQ_TacticalRig read it
	// (rsqdg_keys_off "443 436"). Never eaten: the press still reaches every other mod and bind.
	ui String offKeysFrom;
	ui Array<int> offKeys;
	ui bool offKeyDown;
	ui void ReadOffKey(InputEvent e)
	{
		let cv = CVar.FindCVar("rsqwp_keys_off");
		String s = cv ? cv.GetString() : "443 436";
		if (!(s == offKeysFrom))
		{
			offKeysFrom = s;
			offKeys.Clear();
			Array<String> w;
			s.Split(w, " ", TOK_SKIPEMPTY);
			for (int k = 0; k < w.Size(); k++) offKeys.Push(w[k].ToInt());
		}
		if (offKeys.Find(e.KeyScan) >= offKeys.Size()) return;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (RSQWP_Util.Opt("rsqwp_debug", 0) == 4) Console.Printf("T_WPWK key %d %s", e.KeyScan, down ? "down" : "up");
		if (down == offKeyDown) return;
		offKeyDown = down;
		EventHandler.SendNetworkEvent("rsqwp_ogrip", down ? 1 : 0);
	}

	// LOCK's button: whatever is bound to +altattack. While a whip is out in this machine's hand
	// and Whip Aim is Lock, that press and release go to the whip (and not to the gun in the hand).
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp) return false;
		ReadOffKey(e);
		if (AimKey(e)) return true;
		if (RSQWP_Util.Opt("rsqwp_whip_aim", 1) != 2) return false;
		let b = Bindings.GetBinding(e.KeyScan);
		if (!(b ~== "+altattack")) return false;
		let p = players[consoleplayer];
		if (!p || !p.mo) return false;
		for (int hand = 0; hand < 2; hand++)
		{
			int i = consoleplayer * 2 + hand;
			if (wstate[i] == ST_IDLE || wby[i] != p.mo || byWeapon[i]) continue;
			EventHandler.SendNetworkEvent("rsqwp_lock", hand, e.Type == InputEvent.Type_KeyDown ? 1 : 0);
			return true;
		}
		return false;
	}

	// THE AIMED SWING's button (swing.zs): the other hand's alt-fire while the whip weapon is in hand -- +oh_altatk
	// with the whip in the main hand, +altattack with it in the off hand. Eaten here (press and its release), so the
	// gun or the hand in that hand does not alt-fire as well; the whip hears it as rsqwp_aimkey. A release is eaten
	// only when its press was.
	ui bool aimEat;
	ui int aimEatKey;
	ui bool AimKey(InputEvent e)
	{
		if (e.Type == InputEvent.Type_KeyUp)
		{
			if (!aimEat || e.KeyScan != aimEatKey) return false;
			aimEat = false;
			EventHandler.SendNetworkEvent("rsqwp_aimkey", 0);
			return true;
		}
		if (!RSQWP_Util.Flag("rsqwp_swing", true) || !RSQWP_Util.Flag("rsqwp_on", true)) return false;
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.Health <= 0) return false;
		int wh = (p.ReadyWeapon is "RSQWP_WhipWeapon") ? 0 : ((p.OffhandWeapon is "RSQWP_WhipWeapon") ? 1 : -1);
		if (wh < 0) return false;
		let b = Bindings.GetBinding(e.KeyScan);
		if (!(b ~== (wh == 0 ? "+oh_altatk" : "+altattack"))) return false;
		aimEat = true;
		aimEatKey = e.KeyScan;
		EventHandler.SendNetworkEvent("rsqwp_aimkey", 1);
		return true;
	}

	void Start(int i, PlayerPawn pmo, int hand, int mode)
	{
		bool fresh = wstate[i] == ST_IDLE || wby[i] != pmo;
		wby[i] = pmo;
		wmode[i] = clamp(mode, 0, 1);
		wstate[i] = ST_OUT;
		wage[i] = 0;
		wlen[i] = WhipLen() * LongK(pmo);     // LONG THONG (Gun Bonsai VR)
		wext[i] = 1.0;
		armed[i] = true; swished[i] = false; calm[i] = 0; cracks[i] = 0; pend[i] = false; rearm[i] = 0; crackTic[i] = -100; fullTics[i] = wmode[i] == 1 ? -100000 : 0; handSpd[i] = 0; lashUntil[i] = -100; reachTic[i] = 0; baseLen[i] = wlen[i];
		for (int k = 0; k < 4; k++) { whit[i * 4 + k] = null; whitTic[i * 4 + k] = -1000; whitCrack[i * 4 + k] = false; }
		Vector3 b, d;
		[b, d] = Handle(i, pmo, hand);
		hb[i] = b; hd[i] = d;
		bodyAt[i] = pmo.pos; bodyHad[i] = true;
		stiff[i] = 0; windTics[i] = 0; windEnd[i] = -100; swinging[i] = false; released[i] = false; swingPk[i] = 0; stuckTics[i] = 0; straightTic[i] = -100;
		Follow(i, b, d);
		quiet[i] = 0; lb[i] = 0;
		// out of the hand COILED (Assist throws it straight out at full length); taken up again while it was rolling
		// up, it goes back to its rest coil from where it is
		cgoal[i] = wmode[i] == 1 ? 0.0 : double(COIL_REST);
		// a chain (swing.zs): let go of an aimed swing's rope and the thong comes straight off it, out, not coiled
		if (outNow[i]) { cgoal[i] = 0; cp[i] = 0; cps[i] = 0; fresh = true; }
		outNow[i] = false;
		if (fresh)
		{
			cp[i] = cgoal[i]; cps[i] = 0; ch[i] = (0, 0);
			LayOut(i, b, d);
		}
		Noise(pmo, 'unfurl', ToMap(b));
		if (wmode[i] == 1) Throw(i, pmo, hand);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d start mode %d len %.0f", i, wmode[i], wlen[i]);
	}

	// the whip weapon's trigger let go: roll it up (Real), as the bind's release does
	void WeaponUp(int i, PlayerPawn pmo)
	{
		if (wstate[i] == ST_OUT && wmode[i] == 0 && wby[i] == pmo) RollUp(i);
	}

	void RollUp(int i)
	{
		if (wstate[i] != ST_OUT) return;
		wstate[i] = ST_ROLL;
		if (wby[i]) Noise(wby[i], 'unfurl', ToMap(hb[i]));
	}

	// ---- the hand ---------------------------------------------------------------------------

	// The handle's base (the hand, room space) and its direction (room, unit). Assist drives
	// the direction over the shoulder and down; Real is the controller as it is.
	Vector3, Vector3 Handle(int i, PlayerPawn pmo, int hand)
	{
		Vector3 b = ToRoom(BodyHand(pmo, hand));
		double yaw = RSQWP_Util.HandYaw(pmo, hand);
		double pit = RSQWP_Util.HandPitch(pmo, hand);
		if (wmode[i] == 1) pit += AssistPitch(wage[i]);
		Vector3 d = (cos(pit) * cos(yaw), cos(pit) * sin(yaw), sin(pit));
		return b, d.Unit();
	}

	// A lash thrown for you: lift over the shoulder (7 tics), hold (2), snap down (3), follow.
	static double AssistPitch(int age)
	{
		if (age < 7) { double t = age / 7.0; return 115.0 * (t * t * (3 - 2 * t)); }
		if (age < 9) return 115.0;
		if (age < 12) { double t = (age - 9) / 3.0; return 115.0 - 140.0 * t; }
		return -25.0;
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

	// Crack Fireballs: every missile is noted as it is spawned (a PROJECTILE is NOBLOCKMAP, so no
	// BlockThingsIterator ever returns one); the list is pruned as they explode (MF_MISSILE cleared).
	override void WorldThingSpawned(WorldEvent e)
	{
		if (e.Thing && e.Thing.bMISSILE && (gbOn ? GbAny(G_CRACKSHOT) : RSQWP_Util.Flag("rsqwp_whip_fireball", false))) missiles.Push(e.Thing);
	}

	void WorldTick2()
	{
		if (!gripSettled)
		{
			gripSettled = true;
			for (int pn = 0; pn < MAXPLAYERS; pn++) offGripKey[pn] = false;
		}
		if (knocked.Size()) KnockedTick();
		if (fetchItem.Size()) FetchTick();
		if (missiles.Size() && level.maptime % 8 == 0)
			for (int k = missiles.Size() - 1; k >= 0; k--)
				if (!missiles[k] || missiles[k].bDestroyed || !missiles[k].bMISSILE) missiles.Delete(k);
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
		ArmPump();
		Mantle();
		TrackFrame();
		WhipIn();
		for (int i = 0; i < NW; i++) AimTick(i);     // the aimed swing's ray (swing.zs): on a rope too
		for (int i = 0; i < NW; i++)
		{
			if (wstate[i] == ST_IDLE)
			{
				continue;
			}
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
			if (wstate[i] == ST_OUT)
			{
				// the crack waits for most of the thong (owner 11-02: a fast throw peaked while the last links still paid out
				// and never cracked; the whole thong out for 2 tics made the earliest crack ~0.34 s after the wind-up)
				if (cp[i] <= CRACK_COILED) fullTics[i]++; else fullTics[i] = 0;
				if (wmode[i] == 1 && wage[i] > 24) RollUp(i);
			}
			if (wstate[i] == ST_ROLL && cp[i] >= NN - 0.001) { Halt(i); continue; }
			Vector3 b, d;
			[b, d] = Handle(i, pmo, hand);
			// a hand that jumped (a teleport, a load: 24 room units a tic is 24 m/s, no arm does that):
			// lay the whip out again from where it is, and it must not count as a lash
			// (in the body's frame now -- Carry took the body's own move and turn out -- so this is the hand alone)
			if ((b - hb[i]).Length() > 24)
			{
				Straighten(i, b, d);
				hb[i] = b; hd[i] = d;
				handSpd[i] = 0; pend[i] = false;
			}
			for (int k = 0; k < NP; k++) wt[i * NP + k] = ToMap(wp[i * NP + k]);
			// how hard the hand has driven the handle lately (its tip's speed, decaying): a crack
			// needs the hand behind it -- a whip that only falls or settles never cracks. Relative to the body.
			double hs = ((b + d * HANDLEN) - (hb[i] + hd[i] * HANDLEN)).Length();
			handSpd[i] = max(handSpd[i] * 0.93, hs);
			Deliberate(i, pmo, hand, d, hs);
			if (byWeapon[i]) Mark(i, pmo, hand); else Lock(i, pmo, hand);
			Reach(i, pmo, hand);
			HoldWrap(i, pmo, hand);
			CoilTic(i, hs);
			if (lassoOn[i])
			{
				lassoP1[i] = ToRoom(BodyHand(pmo, 1 - hand));
				if (!lassoWas[i]) { lassoP0[i] = lassoP1[i]; lk[i] = LassoHeld(i, b, d); }
			}
			Whirl(i);
			Vector3 peakAt, peakVel;
			double tA = MSTimeF();
			[peakAt, peakVel] = Sim(i, hb[i], hd[i], b, d);
			msSim += MSTimeF() - tA;
			if (lassoWas[i] && !lassoOn[i]) LassoThrow(i, pmo, hand);
			lassoWas[i] = lassoOn[i];
			lassoP0[i] = lassoP1[i];
			hb[i] = b; hd[i] = d;
			tA = MSTimeF();
			bool snagged = Collide(i, pmo, hand);
			msCol += MSTimeF() - tA;
			if (snagged) continue;     // snagged: core has it now
			Mend(i, pmo, b, d);
			Lash(i, pmo, hand, peakAt, peakVel);
			if (wstate[i] == ST_IDLE) continue;
			if (level.maptime <= lashUntil[i] && missiles.Size() && Unlock(pmo, G_CRACKSHOT, "rsqwp_whip_fireball", false)) Swat(i, pmo, hand);
			UpdateMark(i);
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
		// on a rope too (11-03): the arm pump reads the hand against the body (BodyHand), and without these the engine's
		// AttackPos.z -- the interpolated eye's -- wobbled by a tic of the swing's vertical speed and read as hauls (rig:
		// "haul 10.7" with the hand still, a 22 a tic swing pumped to the 30 cap)
		let core = RSQWP_Core.Get();
		bool roped = core && (core.hooks[pn * 2] || core.hooks[pn * 2 + 1]);
		if (wstate[pn * 2] == ST_IDLE && wstate[pn * 2 + 1] == ST_IDLE && !roped) return;
		if (mo.AttackPos == mo.OffhandPos) return;      // the collapsed pose (a menu, a save): never a hand
		for (int hand = 0; hand < 2; hand++)
		{
			Vector3 h = RSQWP_Util.Ctrl(mo, hand) == 0 ? mo.AttackPos : mo.OffhandPos;
			Vector3 rel = (h.x - mo.pos.x, h.y - mo.pos.y, h.z - e.ViewPos.z);
			if (abs(rel.x) > 200 || abs(rel.y) > 200 || abs(rel.z) > 200) continue;
			EventHandler.SendNetworkEvent(hand ? "rsqwp_hp1" : "rsqwp_hp0", int(rel.x * 256), int(rel.y * 256), int(rel.z * 256));
		}
	}

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
		fb[i] = Xf(fb[i], r0, r1, c, s);
		fv[i] = (fv[i].x * c - fv[i].y * s, fv[i].x * s + fv[i].y * c, fv[i].z);
		fd[i] = (fd[i].x * c - fd[i].y * s, fd[i].x * s + fd[i].y * c, fd[i].z);
		fdv[i] = (fdv[i].x * c - fdv[i].y * s, fdv[i].x * s + fdv[i].y * c, fdv[i].z);
		lassoP0[i] = Xf(lassoP0[i], r0, r1, c, s);
		lc[i] = Xf(lc[i], r0, r1, c, s);
		lom[i] = (lom[i].x * c - lom[i].y * s, lom[i].x * s + lom[i].y * c, lom[i].z);
		ch[i] = (ch[i].x * c - ch[i].y * s, ch[i].x * s + ch[i].y * c);
		pkAt[i] = ToMap(Xf(ToRoom(pkAt[i]), r0, r1, c, s));
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
	const CRACK_COILED = 6.0;     // a crack may come with this many links still coiled (19 of 25 out): ~6 tics into the
	                              // payout, not ~10 (owner 11-02, "crack while paying out")
	const PAY_MAX = 3.5;          // paying out: at most this many links a tic (8.6 room units a tic) ...
	const PAY_ACC = 1.0;          // ... reached and left at this rate (links a tic a tic): 21 links out in ~10 tics (0.28 s)
	const REEL_MAX = 1.2;         // reeling in after a quiet spell: at most this, links a tic ...
	const REEL_ACC = 0.25;        // ... 21 links in in ~19 tics (0.55 s)
	const REEL_CAP = 5.0;         // while it reels in, no free link faster than this (room units a tic): the hand guides
	                              // it home (rig 11-02: uncapped, the dragged tail swung up into the coil at 26 a tic)
	const ROLL_MAX = 3.5;         // put away (the holster, the bind let go): the rest rolled up this fast
	const QUIET_TICS = 30;        // quiet this long (0.86 s) and it reels back into the coil ...
	const QUIET_TIP = 3.0;        // ... quiet = the tip slower than this (room units a tic, ~3 m/s) ...
	const QUIET_HAND = 1.2;       // ... and the handle's tip slower than this, no wind-up, swing, lasso, wrap or flight

	// how many nodes after the handle's tip are pinned (the coil's, else the lasso's piece)
	int Pinned(int i)
	{
		int c = int(cp[i]);
		if (c > 0) return min(c, NN);
		return lassoOn[i] ? lk[i] : 0;
	}

	// THE LASSO'S HELD PIECE (rescaled 11-02): as many links as lie between the handle's tip and where the off hand took
	// hold, 3 to LASSO_K. It was a fixed 5, a 0.94 m piece of 6.4-unit links; with MIT's 2.448 that was 0.36 m, and an
	// off hand further out stretched links 1-5 to reach it (the review: "inner stretch 20%").
	int LassoHeld(int i, Vector3 b, Vector3 d)
	{
		double seg = max(0.5, wext[i] * wlen[i] / NN);
		double reach = (lassoP1[i] - (b + d * HANDLEN)).Length();
		return clamp(int(reach / seg + 0.5), 3, LASSO_K);
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
		return (RSQWP_Util.Ctrl(pmo, i & 1) == 0) != leftHanded ? 1.0 : -1.0;
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

	// THE COIL'S GOAL each tic: all out for a wind-up or a swing (the attack), a lasso, a wrap or a flight, an Assist
	// lash; rolled up when put away; back to rest after QUIET_TICS of quiet; otherwise it stays where it is. Then its
	// rate is eased toward the goal (accelerated, and slowed to arrive): never a step.
	void CoilTic(int i, double hs)
	{
		bool attack = windTics[i] >= WIND_TICS || swinging[i] || (stiff[i] > 0.01 && !released[i]);
		bool busy = lassoOn[i] || lassoWas[i] || wrapOn[i] || reachTic[i] > 0 || lw[i] > 0.01 || pend[i];
		if (wstate[i] == ST_ROLL) cgoal[i] = NN;
		else if (attack || busy || wmode[i] == 1) { cgoal[i] = 0; quiet[i] = 0; }
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
	// and the lag runs out through the tip -- the crack (Lash) -- then it goes slack and settles. Anything else
	// (lowering the arm, a slow sweep) lets the stiffness go in a few tics. A wind-up also re-arms the crack.
	void Deliberate(int i, PlayerPawn pmo, int hand, Vector3 d, double hs)
	{
		if (wmode[i] == 1 || lassoOn[i] || wrapOn[i] || reachTic[i] > 0 || wstate[i] != ST_OUT)
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
				armed[i] = true;
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

	// ---- the lock mark ------------------------------------------------------------------------------------------

	// THE SERIES' LOCK DIAMOND (owner, approved): a white centre in a gold ring, over what a crack will fly to (the
	// mark, or Lock's lock), 4 frames at 3 tics as RSQ Saber's UBQS_LockMark, scale 0.35 x RSQ Accessibility's Cue
	// Size. The ring's gold goes through the colour-blind palette (the HAVE role: it is locked).
	void UpdateMark(int i)
	{
		bool on = (lockOn[i] && !lockOn[i].bDestroyed) || lockLine[i];
		if (!on || !wby[i]) { ClearMark(i); return; }
		Vector3 at = lockOn[i] ? lockOn[i].pos + (0, 0, lockOn[i].height + 8) : lockAt[i];
		double sc = 0.35 * RSQWP_A11y.Cue();
		if (!markRing[i]) { markRing[i] = RSQWP_LockRing(Actor.Spawn("RSQWP_LockRing", at, NO_REPLACE)); if (markRing[i]) markRing[i].ClearInterpolation(); }
		if (!markCen[i]) { markCen[i] = RSQWP_LockCentre(Actor.Spawn("RSQWP_LockCentre", at, NO_REPLACE)); if (markCen[i]) markCen[i].ClearInterpolation(); }
		if (markRing[i])
		{
			markRing[i].SetOrigin(at, true);
			markRing[i].scale = (sc, sc);
			markRing[i].SetShade(RSQWP_CB.Pick(RSQWP_CB.CB_HAVE, RSQWP_LockRing.GOLD));
		}
		if (markCen[i]) { markCen[i].SetOrigin(at, true); markCen[i].scale = (sc, sc); }
		// QUICK MARK 3's second mark
		let b2 = lock2[i];
		if (b2 && !b2.bDestroyed && !(Inventory(b2) && Inventory(b2).Owner))
		{
			Vector3 at2 = b2.pos + (0, 0, b2.height + 8);
			if (!markRing2[i]) markRing2[i] = RSQWP_LockRing(Actor.Spawn("RSQWP_LockRing", at2, NO_REPLACE));
			if (!markCen2[i]) markCen2[i] = RSQWP_LockCentre(Actor.Spawn("RSQWP_LockCentre", at2, NO_REPLACE));
			if (markRing2[i]) { markRing2[i].SetOrigin(at2, true); markRing2[i].scale = (sc, sc); markRing2[i].SetShade(RSQWP_CB.Pick(RSQWP_CB.CB_HAVE, RSQWP_LockRing.GOLD)); }
			if (markCen2[i]) { markCen2[i].SetOrigin(at2, true); markCen2[i].scale = (sc, sc); }
		}
		else ClearMark2(i);
	}
	Actor lock2[NW], reach2[NW];
	RSQWP_LockRing markRing2[NW];
	RSQWP_LockCentre markCen2[NW];
	void ClearMark2(int i)
	{
		if (markRing2[i]) markRing2[i].Destroy();
		if (markCen2[i]) markCen2[i].Destroy();
		markRing2[i] = null; markCen2[i] = null;
	}

	void ClearMark(int i)
	{
		ClearMark2(i);
		if (markRing[i]) markRing[i].Destroy();
		if (markCen[i]) markCen[i].Destroy();
		markRing[i] = null; markCen[i] = null;
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
		// THE LENGTH CHANGED (a reach or a wrap's rope coming back): every link and its last place are scaled together
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
		// the whirl (Whirl, x lw): the damper and the drag eased off, and the loop helped round the hand's circle
		double w = lw[i];
		double loose = 1.0 - WHIRL_LOOSE * w;
		double gam = REF_C_K * dampK * loose / bendK / h;
		double drag = 1.0 - clamp(RSQWP_Util.Num("rsqwp_whip_drag", 1.0), 0.0, 10.0) * loose / 35.0 * h;
		// THE COIL this tic: from cp0 links coiled, at cps a tic (CoilTic); its heading eased from h0 to h1
		double cp0 = cp[i], rate = cps[i];
		double cs = CoilSide(i);
		double cpEnd = clamp(cp0 + rate, 0.0, double(NN));
		int cMin = int(min(cp0, cpEnd));
		Vector2 h0 = ch[i];
		CoilHeading(i, d1);
		Vector2 h1 = ch[i];
		// the lasso's hold comes in over 6 tics once the whole thong is out (it was pinned in one sub-step: a 41 room
		// units a tic jolt as the grip closed, rig 11-02)
		if (lassoOn[i] && cMin == 0) lb[i] = min(1.0, lb[i] + 1.0 / 6.0); else if (!lassoOn[i]) lb[i] = 0;
		double hold = 0.04 + 0.96 * lb[i] * lb[i];
		Vector3 wax = (0, 0, 0);
		double wom = 0, wfe = 0;
		int wk1 = NN;
		int kp0 = Pinned(i);
		if (w > 0.001 && lom[i].Length() > 0.001)
		{
			wax = lom[i].Unit();
			// the loop turns with the hand (a little faster), its tip never over WHIRL_VMAX
			double rmax = (NN - kp0) * seg + max(5.0, (lassoP1[i] - lc[i]).Length());
			wom = min(lom[i].Length() * WHIRL_BOOST, WHIRL_VMAX / rmax);
			wfe = w * (1.0 - exp(-WHIRL_G * h));
			// let go and thrown, Reach lays the outer half out: the help goes out on the inner half only
			if (reachTic[i] > 0) wk1 = NN / 2 - 1;
		}
		double cap = (rate > 0 ? REEL_CAP : VMAX) * h;
		double fric = FRIC ** h;
		// the hand followed critically damped: 2nd order, omega = 2 / lag (a steady motion trails by lag tics)
		double lag = RSQWP_Util.Num("rsqwp_whip_smooth", 0.8);
		double om = lag >= 0.2 ? 2.0 / min(lag, 4.0) : 0.0;
		Vector3 g = (0, 0, -GRAV * h * h);
		bool guide = stiff[i] > 0.01 && !lassoOn[i];
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
			int kp = c > 0 ? c : (lassoOn[i] ? lk[i] : 0);
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
			// THE LASSO (smoothed 11-02, owner: "grabbing with offhand and twirling works, but janky as hell"): the inner
			// piece is laid straight from the handle to the off hand; only the thong beyond the off hand is free. Held
			// firmly only once the coil is out, and then over 6 tics (lb)
			if (lassoOn[i] && c == 0)
			{
				Vector3 held = lassoP0[i] + (lassoP1[i] - lassoP0[i]) * t;
				for (int k = 1; k <= lk[i]; k++)
				{
					Vector3 line = anchor + (held - anchor) * (double(k) / lk[i]);
					wp[o + k] = wq[o + k] + (line - wq[o + k]) * hold;
				}
			}
			// THE WHIRL: each free link eased toward its speed round the circle's axis (the tangent only: the loop's
			// own turning holds it out, as a real one)
			if (wfe > 0)
			{
				for (int k = kp + 1; k <= wk1; k++)
				{
					Vector3 rel = wp[o + k] - lc[i];
					Vector3 rho = rel - wax * (rel dot wax);
					double pl = rho.Length();
					if (pl < 0.5) continue;
					Vector3 tt = (wax cross rho) / pl;
					double cur = (wp[o + k] - wq[o + k]) dot tt;
					wp[o + k] = wp[o + k] + tt * ((wom * pl * h - cur) * wfe);
				}
			}
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
			// THE LENGTH: every link held to seg (equal masses; the handle's tip, the coil and the off hand's piece do not move)
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

	// Floors, ceilings and walls, swept from where each link was at the start of the tic. The
	// outer half of the thong also meets things (hits) and, fast and above the hand, snags.
	// The coil's links are the handle's (held in the hand): not swept.
	bool Collide(int i, PlayerPawn pmo, int hand)
	{
		int o = i * NP;
		let tr = GetTracer();
		tr.shooter = pmo;
		Vector3 handAt = RSQWP_Util.HandPos(pmo, hand);
		double handZ = handAt.z;
		double hitSpd = RSQWP_Util.Num("rsqwp_whip_crack", 20) * 0.45;
		bool snagOn = Unlock(pmo, G_SNAG, "rsqwp_whip_snag", true) && wstate[i] == ST_OUT && !casting[i]
			&& !(aimOk[i] && aimHeld[i] && level.maptime - aimTic[i] <= 1);   // the Snag node under Gun Bonsai VR; not on the way to an aimed anchor, nor while the ray is on one (the crack goes there)
		int nStop = 0;
		int kc = int(cp[i]);
		for (int k = 0; k < NP; k++) stopped[k] = k <= kc;
		for (int k = kc + 1; k < NP; k++)
		{
			Vector3 m = ToMap(wp[o + k]);
			Vector3 m0 = wt[o + k];
			WallClear(o + k, m);
			double spd = (wp[o + k] - ToRoom(m0)).Length();     // room units this tic
			bool outer = k >= NN / 2;
			Vector3 mv = m - m0;
			double ml = mv.Length();
			if (ml > 0.5)
			{
				Vector3 dir = mv / ml;
				bool lashing = level.maptime <= lashUntil[i];
				bool any = tr.Trace(m0, level.PointInSector(m0.xy), dir, ml + 0.5, 0, RSQWP_Tracer.WALLMASK, !(outer && spd >= (lashing ? hitSpd * 0.5 : hitSpd)), pmo);
				if (any && tr.Results.HitType == TRACE_HitActor && tr.Results.HitActor)
				{
					// in the crack's lash (the tics after it, while the loop unrolls and the thong
					// lands) a fast link strikes as hard as the crack itself
					// (not the monster it is wrapped round: the thong is laid along to it and would sting it every
					// 12 tics of a swing -- rig 10-31, and each hurt broke its pin in Pain)
					bool lash = level.maptime <= lashUntil[i] && spd >= hitSpd * 0.5;
					if (tr.Results.HitActor != wrapOn[i])
						Hit(i, pmo, hand, tr.Results.HitActor, tr.Results.HitPos, lash ? crackV[i] : spd, lash);
				}
				// a floor or a ceiling crossed: the sub-steps already met it (flo/cei) and the clamp below puts the link on
				// its own sector's; stopping it at the straight sweep's crossing point teleported a link sliding along
				// the floor back to where the chord met it (rig 11-02: a link 96% too long after the crack landed)
				else if (any && tr.Results.HitType != TRACE_HitNone && tr.Results.HitType != TRACE_HitFloor && tr.Results.HitType != TRACE_HitCeiling)
				{
					Vector3 at = tr.Results.HitPos;
					bool edge; double ez;
					[edge, ez] = Edge(tr, at);
					if (RSQWP_Util.Opt("rsqwp_debug", 0) == 4 && k >= NN / 2)
						Console.Printf("T_WPWC %d t%d link %d hit %d at (%.0f %.0f %.0f) spd %.1f edge %d ez %.0f handZ %.0f", i, level.maptime, k, tr.Results.HitType, at.x, at.y, at.z, spd, edge, ez, handZ);
					if (snagOn && edge && k >= NN * 2 / 3 && spd >= hitSpd * 0.4 && at.z > handZ + SnagAbove(pmo))
					{
						if (Snag(i, pmo, hand, (at.x, at.y, ez), dir, tr.Results.HitSector, at)) return true;
					}
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

	const LOCK_RANGE = 512.0;    // map units (~15 m)
	const LOCK_CONE = 7.0;       // degrees round the pointing hand
	const REACH_TICS = 5;

	// LOCK: while the whip hand's alt-fire is held, the OTHER hand points; the nearest monster,
	// loose pickup or switch along that ray (within LOCK_CONE degrees, in sight) is locked, marked
	// with a small ring of sparks, and a tick in the pointing hand says so. The lock lasts a second
	// after the button is let go. The next crack goes to it (Crack, Reach).
	void Lock(int i, PlayerPawn pmo, int hand)
	{
		if (lockLeft[i] > 0 && !lockHeld[i]) lockLeft[i]--;
		if (lockLeft[i] <= 0) { lockOn[i] = null; lockLine[i] = false; return; }
		if (lockOn[i] && (lockOn[i].bDestroyed || (lockOn[i].Health <= 0 && lockOn[i].bISMONSTER))) lockOn[i] = null;
		int ph = 1 - hand;
		if (lockHeld[i])
		{
			// the pointing hand's smoothed aim (Steady Hands, util.zs AimPos); off / absent: the raw hand
			Vector3 org = RSQWP_Util.AimPos(pmo, ph);
			Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.AimYaw(pmo, ph), RSQWP_Util.AimPitch(pmo, ph));
			Actor was = lockOn[i];
			bool wasLine = lockLine[i];
			Actor best = null;
			double bestA = LOCK_CONE;
			let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, LOCK_RANGE, false);
			while (it.Next())
			{
				let a = it.thing;
				if (!a || a == pmo || a.player || a.bDestroyed) continue;
				bool mon = a.bSHOOTABLE && !a.bNONSHOOTABLE && a.Health > 0 && !a.bMISSILE && !(a is "RSQWP_Rope");
				let inv = Inventory(a);
				bool item = inv && !inv.Owner && inv.bSPECIAL;
				if (!mon && !item) continue;
				Vector3 c = a.pos + (0, 0, a.height * 0.5);
				Vector3 to = c - org;
				double d = to.Length();
				if (d < 8 || d > LOCK_RANGE) continue;
				double ang = acos(clamp((to / d) dot dir, -1.0, 1.0));
				// a wide target may be off the ray by its own radius
				double slack = atan2(a.radius, d);
				if (ang - slack > bestA) continue;
				if (!pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
				best = a; bestA = ang - slack;
			}
			lockOn[i] = best;
			lockLine[i] = false;
			if (!best)
			{
				// a switch on the ray
				let tr = GetTracer();
				tr.shooter = pmo;
				if (tr.Trace(org, level.PointInSector(org.xy), dir, LOCK_RANGE, 0, RSQWP_Tracer.WALLMASK, true, pmo)
					&& tr.Results.HitType == TRACE_HitWall && tr.Results.HitLine && tr.Results.HitLine.special
					&& (tr.Results.HitLine.activation & (SPAC_Use | SPAC_Impact | SPAC_UseThrough)))
				{
					lockLine[i] = true;
					lockAt[i] = tr.Results.HitPos - dir * 2;
				}
			}
			if ((lockOn[i] && lockOn[i] != was) || (lockLine[i] && !wasLine)) Buzz(pmo, ph, 0.3, 2);
		}
		// the mark: the series' lock diamond over the locked thing (UpdateMark, every tic)
	}

	// ---- the whip weapon: mark, pull, lasso (owner 2026-10-31) ---------------------------------

	const MARK_CONE = 20.0;      // degrees round the whip hand for monsters and other pickups
	const PRIO_CONE = 70.0;      // switches, keys and powerups: anywhere roughly ahead, within rsqwp_whip_prio
	const WRAP_TICS = 70;        // how long the whip stays wrapped round a monster waiting for the pull
	const PULL_MIN = 1.5;        // the hand going back from the target, map units a tic (~1.5 m/s): a tug
	const PULL_FULL = 4.0;       // ~4 m/s: a violent pull, the full yank
	const LASSO_K = 13;          // at most this many links in the off hand's piece (0.94 m, the old piece's length)
	const LASSO_MIN = 6.0;       // the tip's speed (room units a tic) a let-go must have to fly
	const YANK_GRACE = 12;       // rsqwp_whip_yankgrace: tics after a wrap before a pull can yank (~1/3 s)

	static bool IsDoor(int sp)
	{
		return (sp >= 10 && sp <= 14) || sp == 105 || sp == 106 || sp == 202 || sp == 249;
	}
	static bool Priority(Inventory inv)
	{
		return inv is "Key" || inv is "PowerupGiver" || inv.bCOUNTITEM || inv.bBIGPOWERUP;
	}

	private void AddCand(Actor a, Line l, Vector3 p, double key)
	{
		int n = cK.Size();
		int at = n;
		while (at > 0 && cK[at - 1] > key) at--;
		cA.Insert(at, a); cL.Insert(at, l); cPx.Insert(at, p.x); cPy.Insert(at, p.y); cPz.Insert(at, p.z); cK.Insert(at, key);
	}

	// MARK: while the trigger is held the whip hand points. The candidates are switches, keys and powerups within
	// rsqwp_whip_prio (nearest first), then monsters and pickups along the hand (within MARK_CONE, LOCK_RANGE,
	// nearest first). The mark stays on what it is on while that is still a candidate; alt-fire moves it to the
	// next. Let go of the trigger and the mark is lost. The next crack flies to it (Crack, Reach).
	void Mark(int i, PlayerPawn pmo, int hand)
	{
		if (!markHeld[i])
		{
			lockOn[i] = null; lockLine[i] = false; lockLeft[i] = 0; markLine[i] = null; markNext[i] = false; lock2[i] = null;
			return;
		}
		// the whip hand's smoothed aim (Steady Hands, util.zs AimPos) picks the mark; off / absent: the raw hand
		Vector3 org = RSQWP_Util.AimPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.AimYaw(pmo, hand), RSQWP_Util.AimPitch(pmo, hand));
		// QUICK MARK (Gun Bonsai VR): pickups and switches marked 2 m further a level
		double prio = max(0.0, RSQWP_Util.Num("rsqwp_whip_prio", 256)) + 68.0 * max(0, Gb(pmo, G_QUICK));
		cA.Clear(); cL.Clear(); cPx.Clear(); cPy.Clear(); cPz.Clear(); cK.Clear();
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, LOCK_RANGE, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || a.bDestroyed) continue;
			bool mon = a.bSHOOTABLE && !a.bNONSHOOTABLE && a.Health > 0 && !a.bMISSILE && a.bISMONSTER && !(a is "RSQWP_Rope");
			if (a.bINVISIBLE || a.sprite == Actor.GetSpriteIndex('TNT1')) continue;   // a spawner or a marker, not a thing to see
			let inv = Inventory(a);
			bool item = inv && !inv.Owner && inv.bSPECIAL;
			if (!mon && !item) continue;
			Vector3 c = a.pos + (0, 0, a.height * 0.5);
			Vector3 to = c - org;
			double d = to.Length();
			if (d < 8 || d > LOCK_RANGE) continue;
			double ang = acos(clamp((to / d) dot dir, -1.0, 1.0)) - atan2(a.radius, d);
			bool first = item && Priority(inv) && d <= prio && ang <= PRIO_CONE;
			if (!first && ang > MARK_CONE) continue;
			if (!pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			AddCand(a, null, c, first ? d : 100000 + d);
		}
		if (prio > 0 && RSQWP_Util.Flag("rsqwp_whip_lines", true))
		{
			let tr = GetTracer();
			tr.shooter = pmo;
			let li = BlockLinesIterator.CreateFromPos(org, 64, prio);
			while (li.Next())
			{
				Line l = li.CurLine;
				if (!l || !l.special || IsDoor(l.special) || !(l.activation & (SPAC_Use | SPAC_Impact | SPAC_UseThrough))) continue;
				Vector2 a = l.v1.p, dl = l.delta;
				double len2 = dl dot dl;
				if (len2 <= 0) continue;
				double t = clamp(((org.xy - a) dot dl) / len2, 0.05, 0.95);
				Vector2 p2 = a + dl * t;
				Sector s = level.PointOnLineSide(org.xy, l) == 0 ? l.frontsector : l.backsector;
				if (!s) continue;
				double fz = s.floorplane.ZatPoint(p2), cz = s.ceilingplane.ZatPoint(p2);
				// a two-sided line: its switch is on the step or the lintel, else the middle of the wall
				Sector o2 = level.PointOnLineSide(org.xy, l) == 0 ? l.backsector : l.frontsector;
				double z = clamp(org.z, fz + 8, max(fz + 8, cz - 8));
				if (o2)
				{
					double ofz = o2.floorplane.ZatPoint(p2), ocz = o2.ceilingplane.ZatPoint(p2);
					if (ofz > fz + 8) z = (fz + min(ofz, cz)) * 0.5;
					else if (ocz < cz - 8) z = (max(ocz, fz) + cz) * 0.5;
				}
				Vector3 p = (p2.x, p2.y, z);
				Vector3 to = p - org;
				double d = to.Length();
				if (d < 4 || d > prio) continue;
				double ang = acos(clamp((to / d) dot dir, -1.0, 1.0));
				if (ang > PRIO_CONE) continue;
				// in sight: the first wall along the way is this one
				Vector3 u = to / d;
				if (tr.Trace(org, level.PointInSector(org.xy), u, d + 4, 0, RSQWP_Tracer.WALLMASK, true, pmo)
					&& tr.Results.HitType != TRACE_HitNone && tr.Results.HitLine != l && tr.Results.Distance < d - 2) continue;
				AddCand(null, l, p - u * 2, d);
			}
		}
		int n = cK.Size();
		int cur = -1;
		for (int k = 0; k < n; k++)
			if ((lockOn[i] && cA[k] == lockOn[i]) || (!lockOn[i] && markLine[i] && cL[k] == markLine[i])) { cur = k; break; }
		int pick = cur;
		// LOCK THE MARK (owner's pick 2026-10-31, on): the hand left what is marked (the lift before an overhead
		// crack points it at the ceiling, or at a zombie 340 units off on MAP01) -- the mark stays where it is
		// while that is still there to crack (alive, in range, in sight). Only alt-fire moves it on.
		// (alt-fire with nothing else there to move to keeps it too)
		bool keep = cur < 0 && (!markNext[i] || n == 0) && RSQWP_Util.Flag("rsqwp_whip_marklock", true) && StillMarkable(i, pmo, org);
		if (keep) pick = -2;
		else if (n == 0) pick = -1;
		else if (markNext[i]) pick = (cur + 1) % n;
		else if (cur < 0) pick = 0;
		markNext[i] = false;
		Actor wasA = lockOn[i]; Line wasL = markLine[i];
		if (pick == -2)
		{
			if (lockOn[i]) lockAt[i] = lockOn[i].pos + (0, 0, lockOn[i].height * 0.5);
			lockLeft[i] = 35;
			if (!markKept[i] && RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d MARK t%d kept on %s (locked: the hand points away, %d other candidate(s) there)", i, level.maptime,
					lockOn[i] ? String.Format("%s", lockOn[i].GetClassName()) : String.Format("line %d", markLine[i].Index()), n);
		}
		else if (pick < 0) { lockOn[i] = null; markLine[i] = null; lockLine[i] = false; lockLeft[i] = 0; }
		else
		{
			lockOn[i] = cA[pick]; markLine[i] = cL[pick]; lockLine[i] = cL[pick] != null; lockAt[i] = (cPx[pick], cPy[pick], cPz[pick]);
			lockLeft[i] = 35;
		}
		markKept[i] = pick == -2;
		// QUICK MARK 3 (Gun Bonsai VR; owner 11-02, "one crack for both"): a pickup marked, the next pickup is marked too and
		// the crack fetches both, the first and then the second in the same flight
		lock2[i] = null;
		if (Gb(pmo, G_QUICK) >= 3 && lockOn[i] is "Inventory")
			for (int k = 0; k < n; k++) if (cA[k] && cA[k] != lockOn[i] && cA[k] is "Inventory") { lock2[i] = cA[k]; break; }
		if (lockOn[i] != wasA || markLine[i] != wasL)
		{
			if (pick >= 0) Buzz(pmo, hand, 0.3, 2);
			if (RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d MARK t%d -> %s (%d of %d)", i, level.maptime,
					lockOn[i] ? String.Format("%s", lockOn[i].GetClassName()) : (markLine[i] ? String.Format("line %d special %d", markLine[i].Index(), markLine[i].special) : "nothing"), pick + 1, n);
		}
		// the mark itself is the series' lock diamond, drawn by UpdateMark every tic
	}

	// the marked thing is still one to crack, wherever the hand points now: a monster alive, a pickup not taken,
	// within LOCK_RANGE of the hand and in sight; a switch within LOCK_RANGE
	bool StillMarkable(int i, PlayerPawn pmo, Vector3 org)
	{
		let a = lockOn[i];
		if (a)
		{
			if (a.bDestroyed) return false;
			let inv = Inventory(a);
			if (inv) { if (inv.Owner || !inv.bSPECIAL) return false; }
			else if (a.Health <= 0 || !a.bSHOOTABLE) return false;
			if ((a.pos + (0, 0, a.height * 0.5) - org).Length() > LOCK_RANGE) return false;
			return pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY);
		}
		if (markLine[i]) return (lockAt[i] - org).Length() <= LOCK_RANGE;
		return false;
	}

	// WRAPPED round a monster (a marked crack or a lasso landed on it): the thong stays laid out to it, and a pull
	// back of the whip hand -- the hand going away from the monster, against the body, so walking does not count --
	// yanks it when the pull ends (Yank: how hard is the pull's peak). Nothing in WRAP_TICS and it lets go.
	void HoldWrap(int i, PlayerPawn pmo, int hand)
	{
		Vector3 hp = BodyHand(pmo, hand);
		Vector3 off = hp - pmo.pos;
		Vector3 d = off - pullOff[i];
		bool had = pullHad[i];
		pullOff[i] = off; pullHad[i] = true;
		let v = wrapOn[i];
		if (!v) return;
		// the trigger still held keeps hold of it (the flail); let go and it slips off WRAP_TICS later
		if (markHeld[i] && RSQWP_Util.Flag("rsqwp_whip_flail", true)) wrapUntil[i] = max(wrapUntil[i], level.maptime + max(wrapLen[i], WRAP_TICS));
		if (v.bDestroyed || v.Health <= 0 || level.maptime > wrapUntil[i] || reachTic[i] > 0) { if (reachTic[i] <= 0) EndWrap(i); return; }
		Flail(i, pmo, hand, v, hp);
		if (!wrapOn[i] || v.bDestroyed || v.Health <= 0) { EndWrap(i); return; }
		BolaTick(i, v);
		Vector3 c = v.pos + (0, 0, v.height * 0.6);
		Vector3 roomTo = ToRoom(c) - ToRoom(hp);
		double dist = roomTo.Length();
		if (dist > LOCK_RANGE * 1.3) { EndWrap(i); return; }
		// the thong stays out to it: the outer half laid along the line, the tip on the monster
		wlen[i] = max(baseLen[i], dist + 8);
		int o = i * NP;
		for (int k = NN / 2; k < NP; k++)
		{
			double u = double(k - NN / 2) / (NN - NN / 2);
			Vector3 want = ToRoom(hp) + roomTo * (0.5 + 0.5 * u);
			// moved WITH its last place, so the lay-out puts no speed into the link (Verlet reads speed from the two:
			// moving only the one flung the thong round when the wrap let go)
			Vector3 dv = (want - wp[o + k]) * 0.5;
			wp[o + k] = wp[o + k] + dv;
			wq[o + k] = wq[o + k] + dv;
		}
		if (!had || d.Length() > 24) return;
		Vector3 toV = (c - hp).Unit();
		double pull = -(d dot toV);
		// YANK GRACE (option, owner 2026-10-31, off): for YANK_GRACE tics after the wrap nothing counts as the pull --
		// a crack's follow-through, the hand still dropping, would yank it at once -- and a pull still under way when
		// the grace ends does not count either: the hand has to stop first
		if (graceArm[i])
		{
			bool inGrace = level.maptime - wrapTic[i] < YANK_GRACE;
			if (inGrace || pull >= PULL_MIN)
			{
				if (pull >= PULL_MIN && RSQWP_Util.Flag("rsqwp_debug", false))
					Console.Printf("T_WPW %d YANK held off t%d (%d tics after the wrap%s): pull %.1f", i, level.maptime, level.maptime - wrapTic[i], inGrace ? ", in the grace" : ", the pull from the grace still going", pull);
				pullPk[i] = 0;
				return;
			}
			graceArm[i] = false;
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d YANK grace over t%d (%d tics after the wrap)", i, level.maptime, level.maptime - wrapTic[i]);
		}
		if (pull >= PULL_MIN) { pullPk[i] = max(pullPk[i], pull); return; }
		if (pullPk[i] >= PULL_MIN) Yank(i, pmo, hand, v, pullPk[i]);
		pullPk[i] = 0;
	}

	// THE YANK. How hard: 0 a tug (PULL_MIN) .. 1 violent (PULL_FULL). Light monsters (mass up to rsqwp_whip_light)
	// are pulled off their feet on an arc toward you -- most of the way on a violent pull; medium ones stagger part
	// of the way; at rsqwp_whip_heavy mass, a boss or a thing that cannot be thrust, it does not move: the yank
	// swings you toward it in an arc instead.
	void Yank(int i, PlayerPawn pmo, int hand, Actor v, double peak)
	{
		double s = clamp((peak - PULL_MIN) / (PULL_FULL - PULL_MIN), 0.0, 1.0);
		double light = LightMass(pmo);
		double heavyM = RSQWP_Util.Num("rsqwp_whip_heavy", 1000);
		bool heavy = v.bBOSS || v.bDONTTHRUST || v.Mass >= heavyM;
		Vector3 to = pmo.pos - v.pos;
		double dist = to.xy.Length();
		Vector2 u = dist > 0.01 ? to.xy / dist : (0, 0);
		String what;
		if (!heavy)
		{
			bool isLight = v.Mass <= light;
			double frac = isLight ? 0.25 + 0.65 * s : 0.08 + 0.3 * s;
			double travel = max(0.0, dist - pmo.radius - v.radius - 16) * frac;
			double T = 14;
			double g = v.bNOGRAVITY ? 0 : level.gravity * v.Gravity / 800.0;
			double lift = isLight ? 0.5 * g * T : 0.5 * g * T * 0.4;
			v.vel = (u.x * travel / T, u.y * travel / T, lift + max(0.0, to.z) / T);
			if (isLight && s >= 0.5 && v.bISMONSTER)
			{
				State pain = v.FindState("Pain");
				if (pain && !v.InStateSequence(v.CurState, pain)) v.SetState(pain);
			}
			if (isLight && v.Mass > RSQWP_Util.Num("rsqwp_whip_light", 400)) Touch("yank.heavy", pmo, v);
			// PULL AND PUNCH (Gun Bonsai VR, after Heavy Yank 1): it arrives staggered 17 + 9 lv tics past its flight (RSQ
			// Melee's Counterpunch reads a staggered monster), so the free hand's punch lands as a counter
			int pp = Gb(pmo, G_PULL);
			if (isLight && pp > 0 && v.bISMONSTER) { Ask("stagger", v, int(T) + 17 + 9 * pp); Touch("pull.punch", pmo, v); }
			BolaYank(i, v.vel);
			what = isLight ? "light: pulled" : "medium: staggers";
		}
		else
		{
			double sp = 6 + 10 * s;
			pmo.vel.xy = pmo.vel.xy * 0.3 - u * sp;
			pmo.vel.z = max(pmo.vel.z, 4 + 5 * s);
			double top = RSQWP_Util.Num("rsqwp_max_speed", 30);
			if (top > 0 && pmo.vel.Length() > top) pmo.vel *= top / pmo.vel.Length();
			pmo.player.keepmomentum = true;
			what = "heavy: you swing to it";
		}
		Noise(pmo, 'swish', v.pos + (0, 0, v.height * 0.6));
		Buzz(pmo, hand, 0.5 + 0.5 * s, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d YANK t%d %s mass %d pull %.1f (%.0f%%) %s", i, level.maptime, v.GetClassName(), v.Mass, peak, s * 100, what);
		EndWrap(i);
	}

	// ---- the leashed monster as a flail (owner's pick 9; teardown apply/01 4.2) --------------------

	const FLAIL_AGAIN = 10;      // tics before the same monster can be smashed into again
	// THE WHIP'S OWN DAMAGE TYPE (owner 11-02: "attacking enemy and bring it to me causes me to do a brutaldoom melee,
	// this then bugs out the whip"). Every hurt was DamageType 'Melee', and Brutal Doom's monsters answer a 'Melee'
	// hurt with their stealth kill: Pain.Melee / Death.Melee -> StealthKill -> A_GiveToTarget GoFatality, GoSpecial
	// and SK<monster> to the player (brutal22test6 Imps.dec 343-348, 738-739, 1297-1305; XMVE's the same), and the
	// player's Brutal Doom class then plays its fatality / execution (rig 11-02, the owner's order: a whip kill on an
	// imp that had not seen you gave GoFatality + SKImp + GoSpecial and the player jumped into his fatality states).
	// 'Whip' is a type no Brutal Doom or XMVE actor has a state or factor for: their plain Pain and Death, full damage.
	static Name DmgType() { return 'Whip'; }

	static bool HeavyThing(Actor v)
	{
		return v.bBOSS || v.bDONTTHRUST || v.Mass >= RSQWP_Util.Num("rsqwp_whip_heavy", 1000);
	}

	// The whip lands round a monster (a marked crack, or the lasso): it waits for the pull, and -- the flail --
	// it is held at the rope's length from the whip hand, on the bearing it had from the hand's yaw. A light one
	// (rsqwp_whip_light) is lifted off its feet: pinned in its Pain state (tics -1, monster.zs's way: it stays in
	// the blockmap, shootable and movable, and nothing it was winding up fires in mid-swing) until it is let go.
	void BeginWrap(int i, PlayerPawn pmo, int hand, Actor v, bool lasso = false)
	{
		EndWrap(i);
		// LASSO 2 (Gun Bonsai VR): a lassoed monster is held 50% longer
		wrapLen[i] = (lasso && Gb(pmo, G_LASSO) >= 2) ? WRAP_TICS * 3 / 2 : WRAP_TICS;
		wrapOn[i] = v; wrapUntil[i] = level.maptime + wrapLen[i]; pullHad[i] = false; pullPk[i] = 0;
		wrapTic[i] = level.maptime; graceArm[i] = RSQWP_Util.Flag("rsqwp_whip_yankgrace", false);
		Vector3 hp = BodyHand(pmo, hand);
		Vector2 to = v.pos.xy - hp.xy;
		flailL[i] = max(to.Length(), v.radius + 8);
		flailOff[i] = Actor.DeltaAngle(RSQWP_Util.HandYaw(pmo, hand), atan2(to.y, to.x));
		flailPin[i] = false;
		if (RSQWP_Util.Flag("rsqwp_whip_flail", true) && !HeavyThing(v) && v.Mass <= LightMass(pmo) && v.bISMONSTER)
		{
			State pain = v.FindState("Pain");
			if (pain)
			{
				if (!v.InStateSequence(v.CurState, pain)) v.SetState(pain);
				if (v && !v.bDestroyed && v.Health > 0) { v.tics = -1; flailPin[i] = true; }
			}
		}
		if (lasso) { Touch("lasso", pmo, v); Bola(i, pmo, v); }
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d WRAP t%d %s mass %d at %.0f, bearing %.0f off the hand%s, held %d tics", i, level.maptime, v.GetClassName(), v.Mass, flailL[i], flailOff[i], flailPin[i] ? ", lifted (pinned in Pain)" : "", wrapLen[i]);
	}
	int wrapLen[NW];

	// BOLA (Gun Bonsai VR, GBOVR_TREES.md 4.4 Lasso, after Lasso 2): the lasso takes one more monster a level, the nearest
	// light ones within 2.5 m of the first. They are tied to it (pinned in Pain, as the flail pins it), kept beside it as it
	// swings, and fly with it on a yank.
	const BOLA_R = 85.0;
	Actor tied[NW * 2];
	Vector3 tiedOff[NW * 2];
	void Bola(int i, PlayerPawn pmo, Actor v)
	{
		int lv = Gb(pmo, G_BOLA);
		if (lv <= 0 || !v) return;
		double light = LightMass(pmo);
		let it = BlockThingsIterator.Create(v, BOLA_R);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == v || a == pmo || a.player || !a.bISMONSTER || a.Health <= 0 || HeavyThing(a) || a.Mass > light) continue;
			if (v.Distance3D(a) > BOLA_R + a.radius) continue;
			int slot = -1;
			for (int k = 0; k < min(lv, 2); k++) if (!tied[i * 2 + k]) { slot = k; break; }
			if (slot < 0) break;
			tied[i * 2 + slot] = a;
			tiedOff[i * 2 + slot] = a.pos - v.pos;
			State pain = a.FindState("Pain");
			if (pain)
			{
				if (!a.InStateSequence(a.CurState, pain)) a.SetState(pain);
				if (a && !a.bDestroyed && a.Health > 0) a.tics = -1;
			}
		}
		int n = (tied[i * 2] ? 1 : 0) + (tied[i * 2 + 1] ? 1 : 0);
		if (n > 0) Touch("bola", pmo, v);
		if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW %d BOLA t%d: %d more tied to %s", i, level.maptime, n, v.GetClassName());
	}
	// the tied ones keep beside the first (placed, never flung by velocity: monster.zs's SlowMo lesson)
	void BolaTick(int i, Actor v)
	{
		for (int k = 0; k < 2; k++)
		{
			let a = tied[i * 2 + k];
			if (!a) continue;
			if (a.bDestroyed || a.Health <= 0) { tied[i * 2 + k] = null; continue; }
			Vector2 off = tiedOff[i * 2 + k].xy;
			double ol = off.Length();
			Vector2 want = v.pos.xy + (ol > 0.01 ? off / ol * min(ol, v.radius + a.radius + 4) : (0, 0));
			if (!a.TryMove(want, true)) a.TryMove((want.x, a.pos.y), true);
			a.SetZ(max(a.floorz, v.pos.z));
		}
	}
	void BolaYank(int i, Vector3 vel) { for (int k = 0; k < 2; k++) if (tied[i * 2 + k]) tied[i * 2 + k].vel = vel; }
	void BolaFree(int i)
	{
		for (int k = 0; k < 2; k++)
		{
			let a = tied[i * 2 + k];
			if (a && !a.bDestroyed && a.Health > 0 && a.tics == -1) a.tics = 1;
			tied[i * 2 + k] = null;
		}
	}

	void EndWrap(int i)
	{
		BolaFree(i);
		let v = wrapOn[i];
		wrapOn[i] = null;
		// what was borrowed goes back (monster.zs Restore: tics = 1, it goes on from its Pain frame)
		if (flailPin[i] && v && !v.bDestroyed && v.Health > 0 && v.tics == -1) v.tics = 1;
		flailPin[i] = false;
		// the thong laid out to it comes back to its length by the rescale in Sim (no speed put in), not by damping
	}

	// Each tic of the wrap: the monster's place is the whip hand + the rope's length along the hand's yaw + the
	// bearing it was wrapped at, so it swings round as the arm does. It is PLACED there by TryMove (never by
	// velocity: monster.zs's SlowMo lesson), at most rsqwp_max_speed a tic for a light one, half that for a
	// heavier one (a heavy one does not swing: the yank swings you). Stopped by another monster at speed, it
	// smashes into it: Grapple's thrown-body damage (monster.zs Damage: (speed - 8) x 0.8, at most 40) to the
	// one it hit -- stagger too, its Pain forced (surveys/01_MELEE 4.7) and a shove the way it was swung --
	// and half to the swung one, as Grapple's Impact splits it.
	void Flail(int i, PlayerPawn pmo, int hand, Actor v, Vector3 hp)
	{
		if (!RSQWP_Util.Flag("rsqwp_whip_flail", true) || HeavyThing(v)) return;
		bool light = v.Mass <= LightMass(pmo);
		// re-pinned every tic, as monster.zs does: a hurt (a smash's share, a gun) puts it back in Pain with tics
		if (flailPin[i] && v.Health > 0)
		{
			State pain = v.FindState("Pain");
			if (pain && !v.InStateSequence(v.CurState, pain)) v.SetState(pain);
			if (v && !v.bDestroyed && v.Health > 0) v.tics = -1;
			if (!v || v.bDestroyed || v.Health <= 0) return;
		}
		double sc = RSQWP_Core.Scale();
		double ang = RSQWP_Util.HandYaw(pmo, hand) + flailOff[i];
		Vector2 want = hp.xy + Actor.AngleToVector(ang, flailL[i]);
		Vector2 to = want - v.pos.xy;
		double d = to.Length();
		double cap = max(1.0, RSQWP_Util.Num("rsqwp_max_speed", 30)) * (light ? 1.0 : 0.5) * sc;
		if (v.bNOGRAVITY || v.bFLOAT)
		{
			double dz = (hp.z - v.Height * 0.5) - v.pos.z;
			v.SetZ(clamp(v.pos.z + clamp(dz, -cap, cap), v.floorz, max(v.floorz, v.ceilingz - v.Height)));
		}
		if (d < 0.5) { v.vel.xy = (0, 0); return; }
		double step = min(d, cap);
		Vector2 dir = to / d;
		Vector2 np = v.pos.xy + dir * step;
		Vector2 was = v.pos.xy;
		if (!v.TryMove(np, true))
		{
			let hit = v.BlockingMobj;
			double spd = step / max(sc, 0.0001);      // full-time speed of the swing
			if (hit && hit != pmo && !hit.player && hit.bSHOOTABLE && hit.Health > 0 && hit.bISMONSTER
				&& !(hit == smashOn[i] && level.maptime - smashTic[i] < FLAIL_AGAIN))
				Smash(i, pmo, hand, v, hit, spd, dir);
			if (v && !v.bDestroyed && !v.TryMove((np.x, v.pos.y), true)) v.TryMove((v.pos.x, np.y), true);
		}
		if (v && !v.bDestroyed) v.vel.xy = (0, 0);
		if (RSQWP_Util.Opt("rsqwp_debug", 0) >= 2 && v)
			Console.Printf("T_WPW %d FLAIL t%d %s moved %.1f (wanted %.1f) bearing %.0f", i, level.maptime, v.GetClassName(), (v.pos.xy - was).Length(), d, ang);
	}

	void Smash(int i, PlayerPawn pmo, int hand, Actor v, Actor hit, double spd, Vector2 dir)
	{
		int dmg = clamp(int((spd - 8.0) * 0.8), 0, 40);
		smashOn[i] = hit; smashTic[i] = level.maptime;
		int hp0 = hit.Health;
		if (dmg > 0) { RSQWP_Events.Whipped(hit, pmo); RSQWP_Perks.Hurt(hit, v, pmo, dmg, DmgType()); }
		bool stag = false;
		if (hit && !hit.bDestroyed && hit.Health > 0)
		{
			stag = hit.TriggerPainChance(DmgType(), true);
			hit.vel.xy += dir * min(8.0, spd * 0.5);
		}
		if (dmg > 1 && v && !v.bDestroyed && v.Health > 0) { RSQWP_Events.Whipped(v, pmo); RSQWP_Perks.Hurt(v, null, pmo, dmg / 2, DmgType()); }
		Noise(pmo, 'hit', hit ? hit.pos + (0, 0, hit.height * 0.5) : v.pos);
		RSQWP_Looks.Spark(v ? v.pos + (0, 0, v.height * 0.5) : pmo.pos, 'flesh');
		Buzz(pmo, hand, 0.7, 5);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d SMASH t%d %s into %s at speed %.1f: dmg %d (hp %d -> %d), stagger %d, the swung one takes %d", i, level.maptime,
				v ? v.GetClassName() : 'gone', hit ? hit.GetClassName() : 'gone', spd, dmg, hp0, hit ? hit.Health : 0, stag, dmg / 2);
	}

	// THE WHIRL (11-02; owner: "free to choose this for what is most fun for the player"). The rebuilt leather
	// (MIT's damper) is right for a whip driven at its root, but a 0.3 m circle of the off hand could only swing the
	// 2.8 m beyond it at 6.5 room units a tic (was 22.5), and a let-go at a slow point dropped it. The lasso is its own
	// deliberate act, so while the off hand draws a circle the thong is helped round it:
	//  - Whirl (a tic): the circle's centre (the hand's path averaged) and its angular velocity (the hand round that
	//    centre, smoothed). How round and fast it is gives a target 0..1; lw ramps toward it (WHIRL_IN up, WHIRL_OUT
	//    down a tic), so the help comes in and goes out over a few tics, never in one.
	//  - Sim (a sub-step, x lw): every free link is eased toward turning with the hand's circle (its speed round the
	//    axis, WHIRL_G a tic, the tip capped at WHIRL_VMAX), and the bend damper and the air drag are eased off by
	//    WHIRL_LOOSE. Nothing else changes; at lw 0 (every swing, crack, hold, walk) the model is exactly as it was.
	//  - LassoThrow: a let-go throws along the circle's tangent at the tip, at least as fast as the whirl was going.
	const WHIRL_IN = 0.15;       // the assist gained a tic while the hand circles (full in ~7 tics, 0.2 s)
	const WHIRL_OUT = 0.25;      // and lost a tic once it stops or lets go (4 tics)
	const WHIRL_W0 = 0.06;       // the hand round its circle: no help under this (rad a tic: one turn in 3 s) ...
	const WHIRL_W1 = 0.16;       // ... full help from this (one turn in 1.1 s)
	const WHIRL_R0 = 2.0;        // and its circle's radius: none under this (room units, 6 cm) ...
	const WHIRL_R1 = 5.0;        // ... full from this (15 cm)
	const WHIRL_G = 0.5;         // how fast a link is brought to the circle's speed (a tic)
	const WHIRL_VMAX = 32.0;     // the whirl's tip at most this fast (room units a tic, ~32 m/s; the old model's 22.5)
	const WHIRL_BOOST = 1.25;    // the loop turns this much faster than the hand (a small circle flings a long loop)
	const WHIRL_LOOSE = 0.6;     // at full whirl the bend damper and the air drag are this much weaker

	void Whirl(int i)
	{
		double want = 0;
		if (lassoOn[i])
		{
			Vector3 p = lassoP1[i];
			if (!lcHad[i]) { lc[i] = p; lom[i] = (0, 0, 0); lvw[i] = 0; lcHad[i] = true; }
			lc[i] += (p - lc[i]) * 0.1;
			Vector3 r = p - lc[i];
			double r2 = r dot r;
			Vector3 om = r2 > 0.25 ? (r cross (p - lassoP0[i])) / r2 : (0, 0, 0);
			lom[i] += (om - lom[i]) * 0.3;
			double rr = sqrt(r2) / 0.85;   // the averaged centre trails a circle by ~15% of its radius
			want = clamp((lom[i].Length() - WHIRL_W0) / (WHIRL_W1 - WHIRL_W0), 0.0, 1.0) * clamp((rr - WHIRL_R0) / (WHIRL_R1 - WHIRL_R0), 0.0, 1.0);
			lvw[i] += (tipSpd[i] - lvw[i]) * 0.2;
		}
		// the let-go tic keeps its whirl for the throw (LassoThrow), then it goes out
		if (lassoWas[i] && !lassoOn[i]) return;
		if (want > lw[i]) lw[i] = min(want, lw[i] + WHIRL_IN);
		else lw[i] = max(want, lw[i] - WHIRL_OUT);
		if (lw[i] <= 0 && !lassoOn[i]) lcHad[i] = false;
	}

	// THE LASSO let go: the thong was whirling on the off hand; the grip let go, it flies on the way its tip was
	// going (flat; whirling: along the circle's tangent at the tip, at least as fast as the whirl), to the monster
	// nearest that way (within 25 degrees and twice the whip's length) and wraps round it, ready for the pull -- or
	// out to full length if nothing is there. Not whirled and too slow, it just drops.
	void LassoThrow(int i, PlayerPawn pmo, int hand)
	{
		int o = i * NP;
		Vector3 tv = wp[o + NN] - ToRoom(wt[o + NN]);
		double sp = tv.Length();
		double w = lw[i];
		if (w > 0.001 && lom[i].Length() > 0.001)
		{
			Vector3 ax = lom[i].Unit();
			Vector3 rel = wp[o + NN] - lc[i];
			Vector3 tt = ax cross (rel - ax * (rel dot ax));
			double tl = tt.Length();
			double ws = max(sp, lvw[i]);
			if (tl > 0.001) tv = tt * (ws * w / tl) + tv * (1.0 - w);
			sp = max(sp, w * lvw[i]);
		}
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LASSO let go t%d tip speed %.1f (whirl %.2f at %.1f)%s", i, level.maptime, sp, w, lvw[i], sp < LASSO_MIN ? " (too slow: it drops)" : "");
		if (sp < LASSO_MIN || reachTic[i] > 0) return;
		Vector3 dir = ToMap(tv);
		if (dir.xy.Length() < 0.01) return;
		dir = (dir.xy.Unit(), 0);
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		double reach = LassoReach(i);
		Actor best = null;
		double bestA = 25.0;
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, reach, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || a.Health <= 0 || !a.bSHOOTABLE || a.bNONSHOOTABLE || a.bMISSILE || !a.bISMONSTER) continue;
			Vector3 to = a.pos + (0, 0, a.height * 0.5) - org;
			double d = to.xy.Length();
			if (d < 8 || d > reach + a.radius) continue;
			double ang = acos(clamp((to.xy / d) dot dir.xy, -1.0, 1.0)) - atan2(a.radius, d);
			if (ang > bestA || !pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			best = a; bestA = ang;
		}
		reachFor[i] = best;
		reachPt[i] = best ? best.pos + (0, 0, best.height * 0.6) : org + dir * (wlen[i] / RSQWP_Util.PS());
		reachTic[i] = REACH_TICS;
		lassoed[i] = true;           // Lasso 2 and Bola read it on arrival (Reach)
		crackV[i] = sp;              // it lands as hard as it was whirled
		// a lasso is thrown, not cracked: Reach's flight is no crack (rig 11-02: one thrown into the air cracked where it
		// landed, before and after the whirl), so the crack re-arms only once the thong has calmed (Lash)
		armed[i] = false; pend[i] = false;
		Noise(pmo, 'swish', org);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LASSO thrown -> %s, %.0f deg off your facing", i, best ? String.Format("%s", best.GetClassName()) : "the air", Actor.DeltaAngle(pmo.angle, atan2(dir.y, dir.x)));
	}

	// THE LASSO'S CATCH REACH (owner 11-02): tied to the whip's length at 4x -- 7.2 m for MIT's 1.8 m, more with a
	// longer whip -- under the lock's range (15 m). It was 2x, which halved to 3.6 m when the whip became 1.8 m.
	const LASSO_REACH_K = 4.0;
	double LassoReach(int i) { return min(LOCK_RANGE, wlen[i] * LASSO_REACH_K); }

	// A locked crack's flight: the thong pays out to the target over REACH_TICS (its length grows
	// to the distance and the outer links are drawn along the line to it, the physics doing the
	// rest), and strikes there: a monster takes the full crack (and, with the whip bind still
	// held and Whip Leash on, is caught on core's line and pulled), a pickup is flicked to you, a
	// switch is thrown. Then the thong comes back to its own length.
	void Reach(int i, PlayerPawn pmo, int hand)
	{
		if (reachTic[i] <= 0)
		{
			if (!wrapOn[i] && wlen[i] > baseLen[i]) wlen[i] = max(baseLen[i], wlen[i] - 24);
			return;
		}
		if (reachFor[i] && !reachFor[i].bDestroyed) reachPt[i] = reachFor[i].pos + (0, 0, reachFor[i].height * 0.6);
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 roomTo = ToRoom(reachPt[i]) - ToRoom(org);
		double dist = roomTo.Length();
		wlen[i] = max(baseLen[i], dist + 8);
		double f = 1.0 - double(reachTic[i] - 1) / REACH_TICS;    // 0.2 .. 1.0
		int o = i * NP;
		// lay the outer half along the line to the target, the tip at f of the way
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
		// arrival
		if (casting[i]) { casting[i] = false; SwingLatch(i, pmo, hand); return; }   // the aimed swing (swing.zs)
		bool fromLasso = lassoed[i];
		lassoed[i] = false;
		Vector3 at = reachPt[i];
		let v = reachFor[i];
		reachFor[i] = null;
		if (!v && !lockLine[i] && wmode[i] == 1)
		{
			// Assist's lash into the air: an ordinary crack at the end of it
			Crack(i, pmo, hand, at, roomTo / max(1.0, dist) * 30);
			return;
		}
		Noise(pmo, 'crack', at, i);
		RSQWP_Looks.Spark(at, 'crack');
		Buzz(pmo, hand, 1.0, 5);
		let inv = Inventory(v);
		if (inv && !inv.Owner)
		{
			let mark = Actor.Spawn("RSQWP_WhipTip", inv.pos, NO_REPLACE);
			if (mark) Fetch(pmo, mark, 8 + inv.radius);
			// QUICK MARK 3: on to the second mark in the same crack
			let nx = Inventory(reach2[i]);
			reach2[i] = null;
			if (nx && !nx.bDestroyed && !nx.Owner) { reachFor[i] = nx; reachPt[i] = nx.pos + (0, 0, nx.height * 0.6); reachTic[i] = REACH_TICS; }
		}
		else if (v && v.Health > 0)
		{
			// it strikes as hard as the crack that sent it (a lasso's throw: as fast as its tip was going)
			Hit(i, pmo, hand, v, at, max(crackV[i], RSQWP_Util.Num("rsqwp_whip_crack", 20)), true);
			if (byWeapon[i] && v && v.Health > 0 && v.bISMONSTER)
			{
				// the whip weapon: it wraps round the monster and waits for the pull (HoldWrap), and swings with the arm
				BeginWrap(i, pmo, hand, v, fromLasso);
			}
			else if (v && v.Health > 0 && v.bISMONSTER && RSQWP_Util.Flag("rsqwp_whip_leash", true) && BindHeld(pmo, hand)) Leash(i, pmo, hand, v, at);
		}
		else if (!v && RSQWP_Util.Flag("rsqwp_whip_lines", true))
		{
			Switches(pmo, at, 24);
		}
	}

	// ASSIST'S REACH (owner 11-02): 2.2x the whip's length, ~4 m for MIT's 1.8 m (it was 1.1x of the old 3.76 m whip,
	// the same ~4 m) -- and further with Long Thong
	const ASSIST_REACH_K = 2.2;

	// ASSIST's lash: thrown for you, along where the hand points, the way a locked crack flies
	// (Reach): to the monster nearest that line within 15 degrees and the whip's length (a
	// little more), else to full length in the air, where it cracks (Crack: Assist's reach round
	// the tip, switches, pickups).
	void Throw(int i, PlayerPawn pmo, int hand)
	{
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, hand), RSQWP_Util.HandPitch(pmo, hand));
		double reach = wlen[i] * ASSIST_REACH_K;
		Actor best = null;
		double bestA = 15.0;
		let it = BlockThingsIterator.CreateFromPos(org.x, org.y, org.z, 64, reach, false);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a == pmo || a.player || a.Health <= 0 || !a.bSHOOTABLE || a.bNONSHOOTABLE || a.bMISSILE || !a.bISMONSTER) continue;
			Vector3 to = a.pos + (0, 0, a.height * 0.5) - org;
			double d = to.Length();
			if (d < 8 || d > reach + a.radius) continue;
			double ang = acos(clamp((to / d) dot dir, -1.0, 1.0)) - atan2(a.radius, d);
			if (ang > bestA || !pmo.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			best = a; bestA = ang;
		}
		reachFor[i] = best;
		if (best) reachPt[i] = best.pos + (0, 0, best.height * 0.6);
		else
		{
			// full length, or the wall first
			let tr = GetTracer();
			tr.shooter = pmo;
			double len = wlen[i] / RSQWP_Util.PS() * 0.9 + (wlen[i] * 0.9 - wlen[i] / RSQWP_Util.PS() * 0.9) * (1 - abs(dir.z));   // map units, near enough
			if (tr.Trace(org, level.PointInSector(org.xy), dir, len, 0, RSQWP_Tracer.WALLMASK, true, pmo) && tr.Results.HitType != TRACE_HitNone)
				len = max(8.0, tr.Results.Distance - 4);
			reachPt[i] = org + dir * len;
		}
		reachTic[i] = REACH_TICS;
	}

	// Is this player's whip bind still down? (core keeps it: held[] from press to release)
	static bool BindHeld(PlayerPawn pmo, int hand)
	{
		let core = RSQWP_Core.Get();
		if (!core || !pmo || !pmo.player) return false;
		return core.held[pmo.PlayerNumber() * 2 + hand];
	}

	// The leash: core's own hook, built bitten into the monster exactly as core's Fly does when a
	// claw hits a thing, so the pull, the yank, the weight test and letting go are all core's.
	// The whip goes back into the hand.
	void Leash(int i, PlayerPawn pmo, int hand, Actor v, Vector3 at)
	{
		let core = RSQWP_Core.Get();
		if (!core || core.hooks[i]) return;
		let h = RSQWP_Hook(Actor.Spawn("RSQWP_Hook", at, NO_REPLACE));
		if (!h) return;
		Vector3 hand0 = RSQWP_Util.HandPos(pmo, hand);
		Vector3 ldir = (at - hand0).Unit();
		h.owner = pmo; h.hand = hand; h.dir = ldir;
		h.speed = max(4.0, RSQWP_Util.Num("rsqwp_speed", 40));
		h.range = max(64.0, RSQWP_Util.Num("rsqwp_range", 1024));
		h.angle = atan2(ldir.y, ldir.x);
		h.traveled = (at - hand0).Length();
		h.whipped = true;
		core.hooks[i] = h;
		h.SetOrigin(at, true);
		h.victim = v;
		Vector3 ofs = at - v.Pos;
		ofs.xy = ofs.xy.Length() > v.radius ? ofs.xy.Unit() * v.radius : ofs.xy;
		ofs.z = clamp(ofs.z, 0, v.Height);
		h.victimOfs = ofs;
		h.heavy = RSQWP_Core.TooHeavy(h, v);
		if (h.heavy)
		{
			h.anchor = v.Pos + h.victimOfs;
			core.Latch(h, i);
		}
		else
		{
			Vector3 dv = v.Pos - pmo.Pos;
			h.bestDist = dv.xy.Length();
			h.noProgress = 0;
			h.SetPhase(RSQWP_Hook.PH_BITE);
			RSQWP_Monster.OnHooked(v, pmo, hand, at);
		}
		RSQWP_Events.Bitten(pmo, v, hand, h.heavy);
		RSQWP_Perks.OnBite(h, v);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d LEASH t%d %s (%s) -> core's line", i, level.maptime, v.GetClassName(), h.heavy ? "too heavy: an anchor" : "comes to you");
		Halt(i);
	}

	// An edge within WRAP of the crack: a two-sided line the tip is beside (in 2D), with a lintel
	// just above the tip or a ledge lip just below it. The nearest one is snagged.
	const WRAP = 12.0;
	bool WrapNear(int i, PlayerPawn pmo, int hand, Vector3 at)
	{
		let it = BlockLinesIterator.CreateFromPos(at, 64, WRAP + 8);
		Line best = null;
		double bestD = WRAP, bestZ = 0;
		Vector2 bestP;
		while (it.Next())
		{
			Line l = it.CurLine;
			if (!l || !l.frontsector || !l.backsector) continue;
			Vector2 a = l.v1.p, d = l.delta;
			double len2 = d dot d;
			if (len2 <= 0) continue;
			double t = clamp(((at.xy - a) dot d) / len2, 0.0, 1.0);
			Vector2 p = a + d * t;
			double dist = (at.xy - p).Length();
			if (dist > bestD) continue;
			double openTop = min(l.frontsector.ceilingplane.ZatPoint(p), l.backsector.ceilingplane.ZatPoint(p));
			double openBot = max(l.frontsector.floorplane.ZatPoint(p), l.backsector.floorplane.ZatPoint(p));
			if (openTop - openBot < 4) continue;
			double fullTop = max(l.frontsector.ceilingplane.ZatPoint(p), l.backsector.ceilingplane.ZatPoint(p));
			double fullBot = min(l.frontsector.floorplane.ZatPoint(p), l.backsector.floorplane.ZatPoint(p));
			double z = 0;
			bool ok = false;
			if (fullTop - openTop > 4 && abs(at.z - openTop) <= WRAP) { z = openTop - 1; ok = true; }        // a lintel or beam
			else if (openBot - fullBot > 4 && abs(at.z - openBot) <= WRAP) { z = openBot + 1; ok = true; }   // a ledge's lip
			if (!ok) continue;
			best = l; bestD = dist; bestZ = z; bestP = p;
		}
		if (!best) return false;
		// which way the whip came at it: from the hand's side of the line
		Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
		Vector2 toLine = bestP - h0.xy;
		Vector3 dir = toLine.Length() > 0.01 ? (toLine.Unit(), 0) : (1, 0, 0);
		Sector sec = level.PointOnLineSide(h0.xy, best) == 0 ? best.backsector : best.frontsector;
		// the wall it wraps: the face just above (a beam) or just below (a lip) the corner
		Vector3 struck = (bestP.x, bestP.y, bestZ > at.z ? bestZ + 4 : bestZ - 4);
		if (bestZ > (best.frontsector.floorplane.ZatPoint(bestP) + best.backsector.floorplane.ZatPoint(bestP)) * 0.5 + 8
			&& bestZ < min(best.frontsector.ceilingplane.ZatPoint(bestP), best.backsector.ceilingplane.ZatPoint(bestP)))
			struck.z = bestZ + 4;            // a beam: its face is above the corner
		else struck.z = bestZ - 4;           // a lip: its face is below
		return Snag(i, pmo, hand, (bestP.x, bestP.y, bestZ), dir, sec, struck);
	}

	// Something a whip can wrap round: an EDGE, not a flat wall. A two-sided line hit just under
	// its lintel (the top of the opening: a doorway's head, a beam) or just under its ledge lip
	// (the top of a step or a ledge), or a 3D floor's side near its top. A plain wall, a floor or
	// a ceiling has nothing to wrap round, and a crack against it just cracks.
	//
	// Returns the edge's height too: the whip wraps ROUND the edge, so the line's anchor goes on
	// the corner itself (a lintel's underside, a lip's top) -- not on the face it struck, where a
	// body swinging under a beam would lose sight of it and the rope would slip.
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

	// The tic's fastest tip: the swish as it loads, and the crack AT THE PEAK -- once the tip has
	// passed the crack speed, the crack waits for the tic its speed turns down, and happens where
	// the tip was fastest: where the loop arrived. A throw can crack twice (on a hard lift as well
	// as on the snap, as a real one does): after a crack it re-arms once the tip has dropped below
	// 70% of that crack's speed.
	void Lash(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 vel)
	{
		double crackSpd = max(4.0, RSQWP_Util.Num("rsqwp_whip_crack", 20));
		double sp = tipSpd[i];
		if (RSQWP_Util.Opt("rsqwp_debug", 0) >= 2)
			Console.Printf("T_WPW %d t%d tip %.1f armed %d coil %.2f full %d hand %.1f pend %d tip(%.1f %.1f %.1f) ms %.3f", i, level.maptime, sp, armed[i], cp[i], fullTics[i], handSpd[i], pend[i], at.x, at.y, at.z, tickMs);
		// whirling, wrapped round a monster, or flying out to one (Reach drags the outer links: rig 10-31, a lasso's
		// throw cracked at 108 on its way out and the crack's speed then counted as the throw's): no crack
		if (lassoOn[i] || wrapOn[i] || reachTic[i] > 0) { pend[i] = false; return; }
		// a tic the tracking space turned (a snap or stick turn) never starts a crack (Carry already took the turn
		// out of the thong; this is the belt to its braces)
		if (wby[i] && turnTic[i / 2] == level.maptime) { pend[i] = false; return; }
		// THE WIND-UP NEVER CRACKS (rig 11-02: the stiffening thong rising off the floor went 115 room units a tic and
		// cracked three times before the swing). While wound up, or stiff with no swing yet, nothing cracks; the swing's
		// crack comes as it drives and lets go (Deliberate).
		if (windTics[i] > 0 || (stiff[i] > 0.01 && !swinging[i] && !released[i])) { pend[i] = false; return; }
		if (sp >= crackSpd * 0.55 && !swished[i] && cp[i] <= CRACK_COILED)
		{
			swished[i] = true;
			Noise(pmo, 'swish', at);
		}
		if (pend[i])
		{
			if (sp > pkSpd[i]) { pkSpd[i] = sp; pkAt[i] = at; pkVel[i] = vel; return; }
			pend[i] = false;
			armed[i] = false;
			rearm[i] = pkSpd[i] * 0.7;
			crackTic[i] = level.maptime;
			tipSpd[i] = pkSpd[i];
			Crack(i, pmo, hand, pkAt[i], pkVel[i]);
			return;
		}
		if (armed[i] && sp >= crackSpd && fullTics[i] >= 1 && wstate[i] == ST_OUT && handSpd[i] >= 2.0)
		{
			pend[i] = true; pkSpd[i] = sp; pkAt[i] = at; pkVel[i] = vel;
			return;
		}
		// ONE SWING, ONE CRACK (owner 11-02: "attack in a deliberate sense"). The crack re-armed as soon as the tip fell
		// to 70% of the last crack's speed, so a throw cracked two or three times (rig 11-02: 5 cracks in 2 swings).
		// Now it re-arms only once the thong has calmed (under 45% of the crack speed for 3 tics) or on a new wind-up.
		if (sp < crackSpd * 0.45) { if (++calm[i] >= 3) { armed[i] = true; swished[i] = false; } }
		else calm[i] = 0;
	}

	RSQWP_Tracer GetTracer()
	{
		if (!tracer) tracer = new("RSQWP_Tracer");
		return tracer;
	}

	// THE ARM PUMP (rsqwp_arm_pump). Swinging on the whip (a snag: core's line, drawn as the whip),
	// haul down on it -- the whip hand moving away from the anchor, relative to the body, as you
	// pull yourself up a rope -- and the swing gains speed along the way it is going, as a kick on
	// a rope swing does. Capped per tic and by core's top speed; only in the air, only moving.
	// Runs after core's tic, so core reads it next tic as a push, as it does the stick's pump.
	void ArmPump()
	{
		double k = RSQWP_Util.Num("rsqwp_arm_pump", 0.12);
		let core = RSQWP_Core.Get();
		for (int i = 0; i < NW; i++)
		{
			let pmo = players[i / 2].mo;
			let h = core ? core.hooks[i] : null;
			if (k <= 0 || !playeringame[i / 2] || !pmo || !h || !h.whipped || h.phase != RSQWP_Hook.PH_LATCH || h.owner != pmo)
			{
				pumpHad[i] = false;
				continue;
			}
			int hand = i & 1;
			Vector3 off = BodyHand(pmo, hand) - pmo.pos;
			bool had = pumpHad[i];
			Vector3 d = off - pumpOff[i];
			pumpOff[i] = off; pumpHad[i] = true;
			if (!had || d.Length() > 24) continue;
			bool air = pmo.pos.z > pmo.floorz + 0.5 && !pmo.bOnMobj;
			double sp = pmo.vel.Length();
			if (!air || sp < 3) continue;
			Vector3 toA = h.anchor - RSQWP_Util.HandPos(pmo, hand);
			double la = toA.Length();
			if (la < 1) continue;
			double pull = -(d dot (toA / la));          // the hand going away from the anchor: a haul
			if (pull <= 1.0) continue;
			double add = min(0.8, pull * k);
			pmo.vel += pmo.vel / sp * add;
			double top = RSQWP_Util.Num("rsqwp_max_speed", 30);
			if (top > 0 && pmo.vel.Length() > top) pmo.vel *= top / pmo.vel.Length();
			if (RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d PUMP t%d haul %.1f +%.2f -> speed %.1f", i, level.maptime, pull, add, pmo.vel.Length());
		}
	}

	// THE MANTLE (rsqwp_mantle). On a line (whip or hook) caught on a LEDGE LIP -- the anchor near
	// the top of a wall whose far side is a floor he fits on -- he goes up and over it, by physics
	// (no teleport): reeled or climbed until the lip is about at his chest, or a free hand on the
	// Grab bind laid on the lip (within GRAB_LIP of the anchor) while the lip is in an arm's reach
	// of his feet. He is given exactly the upward speed that clears the lip (v = sqrt(2 g h), a
	// little over), the line lets go, and once he is above the lip he is carried forward onto the
	// top until his body is past the edge (player.keepmomentum keeps the push through the landing).
	const GRAB_LIP = 20.0;

	void Mantle()
	{
		let core = RSQWP_Core.Get();
		if (!core) return;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.Health <= 0) { mantleTic[pn] = 0; continue; }
			if (mantleTic[pn] > 0)
			{
				// carrying him over: rising until above the top, then forward until past the lip
				mantleTic[pn]--;
				pmo.player.keepmomentum = true;
				if (pmo.pos.z >= mantleTop[pn] - 0.5)
				{
					Vector2 past = mantleLip[pn] + mantleFwd[pn] * (pmo.radius + 6);
					if ((past - pmo.pos.xy) dot mantleFwd[pn] > 0)
						pmo.vel.xy = mantleFwd[pn] * 5;
					else { pmo.vel.xy *= 0.5; mantleTic[pn] = 0; }
				}
				continue;
			}
			// the Mantle node under Gun Bonsai VR (2: from a swing too), the row without
			int mlv = Gb(pmo, G_MANTLE);
			if (mlv < 0 ? !RSQWP_Util.Flag("rsqwp_mantle", true) : mlv < 1) continue;
			for (int hand = 0; hand < 2; hand++)
			{
				int i = pn * 2 + hand;
				let h = core.hooks[i];
				if (!h || h.phase != RSQWP_Hook.PH_LATCH || h.owner != pmo || h.anchorPlane != 0 || h.heavy) continue;
				// the far side of the wall the anchor is on: a floor near the anchor's height, with room
				Vector2 fwd = h.hitDir.xy;
				if (fwd.Length() < 0.01) continue;
				fwd = fwd.Unit();
				Vector2 beyond = h.anchor.xy + fwd * 12;
				let sec = level.PointInSector(beyond);
				double top = sec.floorplane.ZatPoint(beyond);
				double room = sec.ceilingplane.ZatPoint(beyond) - top;
				if (top < h.anchor.z - 32 || top > h.anchor.z + 24 || room < pmo.height) continue;
				if (top <= pmo.pos.z + 4) continue;                       // nothing to climb onto
				// reeled or climbed up to it: the lip at his chest
				// (or reeled all the way in: the rope at its shortest, the lip just over his head)
				// (MANTLE 2: or swung up to it -- in the air, the lip at the chest, within an arm and a stride of the anchor)
				bool reached = (mlv >= 2 && pmo.pos.z > pmo.floorz + 1 && pmo.pos.z + pmo.height * 0.7 >= top && (pmo.pos.xy - h.anchor.xy).Length() <= pmo.radius + 56)
					|| (pmo.pos.z + pmo.height * 0.7 >= top && (pmo.pos.xy - h.anchor.xy).Length() <= pmo.radius + 28)
					|| ((RSQWP_Core.AttachPoint(pmo) - h.anchor).Length() <= RSQWP_Util.Num("rsqwp_min_len", 32) + 10 && top - pmo.pos.z <= pmo.height + 24);
				// or a free hand laid on the lip
				bool grabbed = false;
				for (int gh = 0; gh < 2; gh++)
				{
					if (!core.grabHeld[pn * 2 + gh]) continue;
					if ((RSQWP_Util.HandPos(pmo, gh) - h.anchor).Length() <= GRAB_LIP && top - pmo.pos.z <= pmo.height + 14) grabbed = true;
				}
				if (!reached && !grabbed) continue;
				double rise = top - pmo.pos.z + 3;
				double g = max(0.01, pmo.GetGravity());
				pmo.vel.z = sqrt(2 * g * rise) + 0.5;
				pmo.vel.xy = (0, 0);
				mantleTic[pn] = 35;
				mantleTop[pn] = top;
				mantleFwd[pn] = fwd;
				mantleLip[pn] = h.anchor.xy;
				pmo.player.keepmomentum = true;
				core.LetGo(h, false);
				Buzz(pmo, hand, 0.5, 4);
				if (RSQWP_Util.Flag("rsqwp_debug", false))
					Console.Printf("T_WPW MANTLE t%d player %d %s: from z %.0f onto %.0f (rise %.0f, vz %.1f)", level.maptime, pn, grabbed ? "hand on the lip" : "reeled up", pmo.pos.z, top, rise, pmo.vel.z);
				break;
			}
		}
	}

	// ---- what it does -----------------------------------------------------------------------

	// The thing a lash touched. A fast link stings (part of the damage, by speed); the crack
	// is the full blow and the stun.
	void Hit(int i, PlayerPawn pmo, int hand, Actor v, Vector3 at, double spd, bool crack)
	{
		if (!v || v == pmo || v.Health <= 0 || !v.bSHOOTABLE || v.bNONSHOOTABLE) return;
		// once per thing per lash: a sting once per 12 tics, the crack once (it may follow a sting)
		for (int k = 0; k < 4; k++)
			if (whit[i * 4 + k] == v && level.maptime - whitTic[i * 4 + k] < 12 && (!crack || whitCrack[i * 4 + k])) return;
		int slot = 0;
		for (int k = 1; k < 4; k++) if (whitTic[i * 4 + k] < whitTic[i * 4 + slot]) slot = k;
		whit[i * 4 + slot] = v; whitTic[i * 4 + slot] = level.maptime; whitCrack[i * 4 + slot] = crack;
		double crackSpd = max(4.0, RSQWP_Util.Num("rsqwp_whip_crack", 20));
		double maxDmg = RSQWP_Util.Opt("rsqwp_whip_damage", 12);
		// A HARDER CRACK HURTS MORE (owner's pick 6; teardown apply/08 3.1 and apply/01 2.4): the crack's damage
		// is the tip's speed at the crack between the crack speed (k 0: a quarter) and rsqwp_whip_hardcrack (k 1:
		// all of rsqwp_whip_damage, now the top end). Assist throws the lash for you: always the top. A sting (a fast
		// link, no crack) stays under the softest crack: that quarter, times its speed over the crack speed (rig, 10-31:
		// the old sting, up to half, out-hurt a soft crack's quarter -- 6 against 3).
		double hk = CrackK(i, spd);
		int dmg = crack ? max(1, int(maxDmg * (0.25 + 0.75 * hk) + 0.5)) : int(maxDmg * 0.25 * clamp(spd / crackSpd, 0.15, 1.0) + 0.5);
		if (maxDmg <= 0) dmg = 0;
		// STING (Gun Bonsai VR): a crack does 25% more a level
		int sting = Gb(pmo, G_STING);
		if (crack && sting > 0) { dmg = int(dmg * (1.0 + 0.25 * sting) + 0.5); Touch("crack", pmo, v); }
		int hp0 = v.Health;
		if (dmg > 0) { RSQWP_Events.Whipped(v, pmo); RSQWP_Perks.Hurt(v, pmo, pmo, dmg, DmgType()); }
		bool stunned = false;
		if (crack && v && v.Health > 0 && v.bISMONSTER && RSQWP_Util.Flag("rsqwp_whip_stun", true))
		{
			State pain = v.FindState("Pain");
			if (pain && !v.InStateSequence(v.CurState, pain)) { v.SetState(pain); stunned = true; }
			else stunned = pain != null;
		}
		// HIT-STOP (option, owner's pick 10; surveys/01_MELEE 3.6): the cracked monster freezes for a beat --
		// 3 tics for the lightest crack ("a tap") to 6 for the hardest ("a heavy"); 10 reads as a bug.
		// STRIKE TRUE (Gun Bonsai VR): the option becomes levels, 3 / 4 / 6 tics whatever the crack
		int frz = 0;
		int stl = Gb(pmo, G_STRIKE);
		if (crack && v && !v.bDestroyed && v.Health > 0 && v.bISMONSTER && (stl > 0 || (stl < 0 && RSQWP_Util.Flag("rsqwp_whip_hitstop", false))))
		{
			static const int ST[] = { 0, 3, 4, 6 };
			frz = stl > 0 ? ST[clamp(stl, 1, 3)] : int(3 + 3 * hk + 0.5);
			v.freezetics = max(v.freezetics, frz);
		}
		// STUN (Gun Bonsai VR): the pain a crack causes is held 10 + 10 lv tics
		int sn = Gb(pmo, G_STUN);
		if (crack && stunned && sn > 0 && v && !v.bDestroyed && v.Health > 0) { Ask("stagger", v, 10 + 10 * sn); Touch("crack.stun", pmo, v); }
		String s = RSQWP_Looks.Sound('hitflesh');
		if (s != "") { let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE); if (c) c.A_StartSound(s, CHAN_VOICE, 0, crack ? 1.0 : 0.6); }
		if (crack) RSQWP_Looks.Spark(at, 'flesh');
		Buzz(pmo, hand, crack ? 0.8 : 0.35, crack ? 6 : 3);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d %s %s at speed %.1f (k %.2f): dmg %d, hp %d -> %d, pain %d, hit-stop %d", i, crack ? "CRACK hit" : "sting", v ? v.GetClassName() : 'gone', spd, crack ? hk : 0.0, dmg, hp0, v ? v.Health : 0, stunned, frz);
	}

	// How hard a crack was, 0..1, from the tip's speed at it.
	double CrackK(int i, double spd)
	{
		if (wmode[i] == 1) return 1.0;
		double lo = max(4.0, RSQWP_Util.Num("rsqwp_whip_crack", 20));
		double hi = max(lo + 1.0, RSQWP_Util.Num("rsqwp_whip_hardcrack", 43));
		return clamp((spd - lo) / (hi - lo), 0.0, 1.0);
	}

	// CRACK FIREBALLS (option, owner's pick 8; surveys/06_GRAB 4.6 "swat down", 01_MELEE 4.11's segment test):
	// in a crack's lash, a fast outer link whose sweep this tic passes within the missile's radius (+4) of the
	// missile's own path (from where it was a tic ago to where it goes next) explodes it there (ExplodeMissile:
	// its own death -- an imp's ball pops, a rocket blows up where it is). Only a monster's missile, never a
	// player's. 06_GRAB's caveat (35 Hz) is why the missile's path both ways is swept, not its point.
	void Swat(int i, PlayerPawn pmo, int hand)
	{
		int o = i * NP;
		double hitSpd = RSQWP_Util.Num("rsqwp_whip_crack", 20) * 0.45 * 0.5;
		for (int n = missiles.Size() - 1; n >= 0; n--)
		{
			let m = missiles[n];
			if (!m || m.bDestroyed || !m.bMISSILE) continue;
			// a monster's shot only: not a player's, and not an effect flagged MISSILE with no shooter (rig 10-31, BD order:
			// a PlasmaSmoke puff was popped along with the imp's ball)
			if (!m.target || !m.target.bISMONSTER || m.target.player) continue;
			Vector3 m0 = m.pos - m.vel, m1 = m.pos + m.vel;
			if ((m.pos - ToMap(wp[o + NN])).Length() > wlen[i] + m.vel.Length() + 64) continue;
			for (int k = NN * 2 / 3; k < NP; k++)
			{
				Vector3 a = wt[o + k], b = ToMap(wp[o + k]);
				if ((ToRoom(b) - ToRoom(a)).Length() < hitSpd) continue;
				double d = SegSeg(a, b, m0, m1);
				if (d > m.radius + 4) continue;
				let cls = m.GetClassName();
				Vector3 at = m.pos;
				bool knock = CrackMissile(pmo, m, b - a);
				Noise(pmo, 'crack', at, i);
				RSQWP_Looks.Spark(at, 'crack');
				Buzz(pmo, hand, 0.8, 4);
				if (RSQWP_Util.Flag("rsqwp_debug", false))
				{
					if (knock)
						Console.Printf("T_WPW %d FIREBALL t%d %s knocked away at (%.0f %.0f %.0f), link %d %.1f from its path: speed %.1f, heading %.0f (straight away from you: %.0f), climbing %.0f deg", i, level.maptime, cls, at.x, at.y, at.z, k, d,
							m.vel.Length(), VectorAngle(m.vel.x, m.vel.y), VectorAngle(at.x - pmo.pos.x, at.y - pmo.pos.y), atan2(m.vel.z, m.vel.xy.Length()));
					else
						Console.Printf("T_WPW %d FIREBALL t%d %s cracked out of the air at (%.0f %.0f %.0f), link %d %.1f from its path, %.0f from you", i, level.maptime, cls, at.x, at.y, at.z, k, d, (at - pmo.pos).Length());
				}
				break;
			}
		}
	}

	// A CRACKED MISSILE. Without the patch: knocked away (rsqwp_whip_fireball_knock 1) or blown up where it is. Under the
	// Gun Bonsai VR patch (GBOVR_TREES.md 4.4 Crack): RETURN CRACK sends it back at its shooter (its damage x1 + 0.25 lv);
	// else it blows up, and CRACK SHOT 2-3 hurts what stands within 2 / 2.5 m of it by the missile's own damage (owner
	// 11-02). True when it was sent away rather than blown up.
	bool CrackMissile(PlayerPawn pmo, Actor m, Vector3 sweep)
	{
		int ret = Gb(pmo, G_RETURN);
		if (ret > 0) { ReturnTo(pmo, m, ret); return true; }
		if (ret < 0 && RSQWP_Util.Opt("rsqwp_whip_fireball_knock", 0) == 1) { Knock(pmo, m, sweep); return true; }
		int cs = Gb(pmo, G_CRACKSHOT);
		int md = cs >= 2 ? m.GetMissileDamage(7, 1) : 0;
		Vector3 at = m.pos;
		Actor shooter = m.target;
		m.ExplodeMissile(null, null);
		if (cs > 0) Touch("crack.shot", pmo, shooter);
		if (md > 0)
		{
			double r = 34.0 * (1.0 + 0.5 * cs);
			let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
			if (c) { c.target = pmo; c.A_Explode(md, int(r), 0, false, int(r)); }
			if (RSQWP_Util.Flag("rsqwp_debug", false)) Console.Printf("T_WPW CRACK SHOT t%d: %d round it within %.0f", level.maptime, md, r);
		}
		return false;
	}

	// RETURN CRACK: the missile goes back at the monster that shot it, harder a level; it is yours now (target = you: it
	// does not hit you, it hits its shooter) and a seeker stops seeking you
	void ReturnTo(PlayerPawn pmo, Actor m, int lv)
	{
		Actor shooter = m.target;
		double spd = max(m.vel.Length(), m.Speed);
		Vector3 dir = m.vel.Length() > 0.001 ? -m.vel.Unit() : (Actor.AngleToVector(pmo.angle, 1), 0);
		if (shooter && !shooter.bDestroyed && shooter.Health > 0)
		{
			Vector3 to = shooter.pos + (0, 0, shooter.height * 0.5) - m.pos;
			if (to.Length() > 0.001) dir = to.Unit();
		}
		m.vel = dir * spd;
		m.angle = VectorAngle(dir.x, dir.y);
		m.pitch = -asin(clamp(dir.z, -1.0, 1.0));
		m.SetDamage(max(1, int(m.GetMissileDamage(7, 1) * (1.0 + 0.25 * lv) + 0.5)));
		m.target = pmo;
		m.tracer = null;
		Touch("crack.return", pmo, shooter);
		knocked.Push(m); knockX.Push(m.pos.x); knockY.Push(m.pos.y); knockZ.Push(m.pos.z);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW RETURN CRACK t%d %s back at %s, damage %d", level.maptime, m.GetClassName(), shooter ? String.Format("%s", shooter.GetClassName()) : "nothing", m.GetMissileDamage(0, 1));
	}

	// CRACKED ROCKETS, knock away (rsqwp_whip_fireball_knock 1, owner 2026-10-31: "knock away and explode"): the cracked
	// missile is sent off along the crack's sweep (the struck link's motion this tic) at its own speed (or its Speed,
	// whichever is more), so it blows up somewhere away from you instead of at the crack. Never back at you: the part
	// of the sweep toward you is taken out, and it flies at most 15 degrees down (an overhead crack sweeps down -- the
	// rocket would hit the floor at your feet) and at most 30 up. It is yours now (target = you, as a reflected
	// missile: it does not hit you, it hits the monster that shot it), and a seeker stops seeking you.
	void Knock(PlayerPawn pmo, Actor m, Vector3 sweep)
	{
		Vector3 dir = sweep.Length() > 0.001 ? sweep.Unit() : (Actor.AngleToVector(pmo.angle, 1), 0);
		Vector2 away = m.pos.xy - pmo.pos.xy;
		away = away.Length() > 0.001 ? away.Unit() : Actor.AngleToVector(pmo.angle, 1);
		Vector2 h = (dir.x, dir.y);
		double toward = h dot away;
		if (toward < 0.3) h += away * (0.3 - toward);
		double fl = h.Length();
		if (fl < 0.001) { h = away; fl = 1; }
		double pz = clamp(atan2(dir.z, fl), -15.0, 30.0);
		Vector2 f = h / fl;
		dir = (f * cos(pz), sin(pz));
		double spd = max(m.vel.Length(), m.Speed);
		m.vel = dir * spd;
		m.angle = VectorAngle(dir.x, dir.y);
		m.pitch = -pz;
		m.target = pmo;
		m.tracer = null;
		knocked.Push(m); knockX.Push(m.pos.x); knockY.Push(m.pos.y); knockZ.Push(m.pos.z);
	}

	// the knocked missiles: where each blew up (debug), and how far from you
	void KnockedTick()
	{
		for (int n = knocked.Size() - 1; n >= 0; n--)
		{
			let m = knocked[n];
			if (m && !m.bDestroyed && m.bMISSILE) continue;
			if (m && !m.bDestroyed && RSQWP_Util.Flag("rsqwp_debug", false))
			{
				let pm = PlayerPawn(m.target);
				Vector3 k0 = (knockX[n], knockY[n], knockZ[n]);
				Console.Printf("T_WPW FIREBALL t%d %s blew up at (%.0f %.0f %.0f), %.0f from where it was cracked, %.0f from you", level.maptime, m.GetClassName(), m.pos.x, m.pos.y, m.pos.z,
					(m.pos - k0).Length(), pm ? (m.pos - pm.pos).Length() : -1.0);
			}
			knocked.Delete(n); knockX.Delete(n); knockY.Delete(n); knockZ.Delete(n);
		}
	}

	// Closest distance between two segments (map space).
	static double SegSeg(Vector3 p1, Vector3 q1, Vector3 p2, Vector3 q2)
	{
		Vector3 d1 = q1 - p1, d2 = q2 - p2, r = p1 - p2;
		double a = d1 dot d1, e = d2 dot d2, f = d2 dot r;
		double s = 0, t = 0;
		if (a <= 1e-9 && e <= 1e-9) return r.Length();
		if (a <= 1e-9) t = clamp(f / e, 0.0, 1.0);
		else
		{
			double c = d1 dot r;
			if (e <= 1e-9) s = clamp(-c / a, 0.0, 1.0);
			else
			{
				double b = d1 dot d2, den = a * e - b * b;
				s = den > 1e-9 ? clamp((b * f - c * e) / den, 0.0, 1.0) : 0.0;
				t = (b * s + f) / e;
				if (t < 0) { t = 0; s = clamp(-c / a, 0.0, 1.0); }
				else if (t > 1) { t = 1; s = clamp((b - c) / a, 0.0, 1.0); }
			}
		}
		return ((p1 + d1 * s) - (p2 + d2 * t)).Length();
	}

	void Crack(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 vel)
	{
		cracks[i]++;
		crackV[i] = tipSpd[i];       // the tip's speed at the peak (Lash): what this crack and its lash land with
		lashUntil[i] = level.maptime + 8;
		// THE AIMED SWING (swing.zs): the other hand's ray on a valid spot -- the crack sends the whip there to swing from
		if (SwingCast(i, pmo, hand, at)) return;
		if ((RSQWP_Util.Opt("rsqwp_whip_aim", 1) == 2 || byWeapon[i]) && (lockOn[i] || lockLine[i]) && lockLeft[i] > 0)
		{
			// LOCK: the crack sends the thong out to the target, however far (up to the lock's
			// range): it pays out over REACH_TICS and strikes on arrival (Reach)
			reachFor[i] = lockOn[i];
			reachPt[i] = lockOn[i] ? lockOn[i].pos + (0, 0, lockOn[i].height * 0.6) : lockAt[i];
			reachTic[i] = REACH_TICS;
			Noise(pmo, 'crack', at, i);
			Buzz(pmo, hand, 1.0, 5);
			if (RSQWP_Util.Flag("rsqwp_debug", false))
			{
				Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
				Console.Printf("T_WPW %d CRACK #%d t%d LOCKED -> %s at %.0f units", i, cracks[i], level.maptime,
					lockOn[i] ? lockOn[i].GetClassName() : 'line', (reachPt[i] - h0).Length());
			}
			reach2[i] = (lockOn[i] is "Inventory") ? lock2[i] : null;
			lock2[i] = null;
			lockLeft[i] = 0; lockOn[i] = null; lockLine[i] = false;
			return;
		}

		Noise(pmo, 'crack', at, i);
		RSQWP_Looks.Spark(at, 'crack');
		Buzz(pmo, hand, 1.0, 5);
		bool dbg = RSQWP_Util.Flag("rsqwp_debug", false);
		bool assist = RSQWP_Util.Opt("rsqwp_whip_aim", 1) == 1;
		double reach = assist ? max(8.0, RSQWP_Util.Num("rsqwp_whip_assist", 40)) : 12.0;
		Vector3 vdir = vel.Length() > 0.01 ? ToMap(vel).Unit() : (0, 0, 0);

		// a crack right by an EDGE above the hand (a beam's underside, a ledge's lip) wraps round it,
		// as a tip hitting it would: the loop arriving next to a beam throws the popper over it
		if (Unlock(pmo, G_SNAG, "rsqwp_whip_snag", true) && wstate[i] == ST_OUT && wmode[i] == 0)
		{
			Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
			if (at.z > h0.z + SnagAbove(pmo) && WrapNear(i, pmo, hand, at)) return;
		}

		// the thing it cracks on: nearest the tip within reach (Free: touching it), and the tip
		// must see it (no cracking through a wall)
		let mark = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		Actor best = null;
		double bestD = reach;
		if (mark)
		{
			let it = BlockThingsIterator.Create(mark, reach + 64);
			while (it.Next())
			{
				let a = it.thing;
				if (!a || a == pmo || a.player || a.Health <= 0 || !a.bSHOOTABLE || a.bNONSHOOTABLE || a.bMISSILE) continue;
				if (a is "RSQWP_Rope" || a is "RSQWP_Hook" || a is "RSQWP_WhipTip") continue;
				// distance from the tip to the thing's body (a cylinder)
				Vector2 dxy = a.pos.xy - at.xy;
				double hd2 = max(0.0, dxy.Length() - a.radius);
				double vz = at.z < a.pos.z ? a.pos.z - at.z : (at.z > a.pos.z + a.height ? at.z - a.pos.z - a.height : 0);
				double dist = sqrt(hd2 * hd2 + vz * vz);
				if (dist > bestD) continue;
				if (!mark.CheckSight(a, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
				best = a; bestD = dist;
			}
		}
		if (best) Hit(i, pmo, hand, best, at, tipSpd[i], true);

		// a switch (or any line you could use) the crack lands on
		int lines = 0;
		if (RSQWP_Util.Flag("rsqwp_whip_lines", true)) lines = Switches(pmo, at, reach);
		// a loose pickup within reach is flicked to you
		int fetched = 0;
		if (RSQWP_Util.Flag("rsqwp_whip_fetch", true) && mark) fetched = Fetch(pmo, mark, reach * 1.5);
		if (dbg) Console.Printf("T_WPW %d CRACK #%d t%d speed %.1f at (%.0f %.0f %.0f) %.0f from the hand: target %s, lines %d, fetched %d",
			i, cracks[i], level.maptime, tipSpd[i], at.x, at.y, at.z, (at - ToMap(hb[i])).Length(), best ? best.GetClassName() : 'none', lines, fetched);
	}

	// Lines with a use (or impact) special whose wall the tip is within reach of: thrown, as if
	// the player had pressed them -- locks still ask for their key.
	int Switches(PlayerPawn pmo, Vector3 at, double reach)
	{
		int n = 0;
		let it = BlockLinesIterator.CreateFromPos(at, 64, reach);
		while (it.Next())
		{
			Line l = it.CurLine;
			if (!l || !l.special || !(l.activation & (SPAC_Use | SPAC_Impact | SPAC_UseThrough))) continue;
			// distance from the tip to the line, in 2D
			Vector2 a = l.v1.p, d = l.delta;
			double len2 = d dot d;
			double t = len2 > 0 ? clamp(((at.xy - a) dot d) / len2, 0.0, 1.0) : 0.0;
			if ((at.xy - (a + d * t)).Length() > reach) continue;
			int side = level.PointOnLineSide(pmo.pos.xy, l);
			int type = (l.activation & SPAC_Impact) ? SPAC_Impact : ((l.activation & SPAC_UseThrough) ? SPAC_UseThrough : SPAC_Use);
			if (l.Activate(pmo, side, type)) n++;
		}
		return n;
	}

	// A FETCHED PICKUP IS TAKEN WHEN IT REACHES YOU (owner 11-02): the engine picks an item up only when the player moves
	// into it, so one landing on a VR player standing still lay at his feet. Within reach of the body it is touched
	// (Inventory.Touch: the pickup's own sound, message and flash); after 2 s in the air it is left where it is.
	Array<Inventory> fetchItem;
	Array<PlayerPawn> fetchBy;
	Array<int> fetchTic;
	void FetchTick()
	{
		for (int n = fetchItem.Size() - 1; n >= 0; n--)
		{
			let inv = fetchItem[n];
			let pmo = fetchBy[n];
			bool done = !inv || inv.bDestroyed || inv.Owner || !pmo || pmo.Health <= 0 || level.maptime - fetchTic[n] > 70;
			if (!done && pmo.Distance2D(inv) <= pmo.radius + inv.radius + 16 && inv.pos.z <= pmo.pos.z + pmo.height && inv.pos.z + inv.height >= pmo.pos.z - 8)
			{
				inv.Touch(pmo);
				done = true;
			}
			if (done) { fetchItem.Delete(n); fetchBy.Delete(n); fetchTic.Delete(n); }
		}
	}

	// Pickups lying loose near the crack fly to the player on an arc that lands on him.
	int Fetch(PlayerPawn pmo, Actor mark, double reach)
	{
		int n = 0;
		let it = BlockThingsIterator.Create(mark, reach);
		while (it.Next())
		{
			let inv = Inventory(it.thing);
			if (!inv || inv.Owner || !inv.bSPECIAL) continue;
			if ((inv.pos - mark.pos).Length() > reach) continue;
			Vector3 to = (pmo.pos.x, pmo.pos.y, pmo.pos.z + pmo.height * 0.4) - inv.pos;
			double T = 16;
			double g = level.gravity * inv.Gravity / 800.0;
			if (inv.bNOGRAVITY) g = 0;
			inv.vel = (to.x / T, to.y / T, to.z / T + 0.5 * g * T);
			fetchItem.Push(inv); fetchBy.Push(pmo); fetchTic.Push(level.maptime);
			n++;
		}
		return n;
	}

	// Core's hook, built as a claw that hit this spot would have been (core.zs Fly's geometry
	// branch), then handed to core's own Latch(): the whip's tip wrapped round it.
	private bool Snag(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 dir, Sector sec, Vector3 struck)
	{
		let core = RSQWP_Core.Get();
		if (!core || core.hooks[i]) return false;
		let h = RSQWP_Hook(Actor.Spawn("RSQWP_Hook", at, NO_REPLACE));
		if (!h) return false;
		Vector3 hand0 = RSQWP_Util.HandPos(pmo, hand);
		Vector3 ldir = (at - hand0).Unit();
		h.owner = pmo;
		h.hand = hand;
		h.dir = ldir;
		h.speed = max(4.0, RSQWP_Util.Num("rsqwp_speed", 40));
		h.range = max(64.0, RSQWP_Util.Num("rsqwp_range", 1024));
		h.angle = atan2(ldir.y, ldir.x);
		h.traveled = (at - hand0).Length();
		h.anchor = at - (dir.xy.Length() > 0.01 ? (dir.xy.Unit() * 0.5, 0) : (0, 0, 0));   // on the corner, a hair on the near side
		h.hitDir = (dir.xy.Length() > 0.01 ? (dir.xy.Unit(), 0) : ldir);
		h.SetOrigin(h.anchor, true);
		h.anchorSec = sec;
		h.anchorPlane = 0;              // an edge is a wall's: core checks the wall is still there
		h.whipped = true;
		h.struck = struck - h.hitDir * 0.5;
		core.hooks[i] = h;
		core.Latch(h, i);
		Noise(pmo, 'crack', at, i);
		Buzz(pmo, hand, 0.7, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d SNAG t%d at (%.0f %.0f %.0f), %.0f above the hand -> core's rope", i, level.maptime, at.x, at.y, at.z, at.z - hand0.z);
		Halt(i);
		return true;
	}

	// ---- looks ------------------------------------------------------------------------------

	// The whip's sounds, at a point, through a tiny actor that carries them.
	// LIGHT AND HEAVY CRACKS (the owner, 11-01: "I literally named a crack Light and Heavy, so maybe don't
	// make them random"): the crack's hardness is the same CrackK the damage uses -- the tip's speed between
	// the crack speed (rsqwp_whip_crack) and the full crack (rsqwp_whip_hardcrack) -- so the heavy crack is
	// exactly a crack that hurts more than halfway. Snags and fireball swats follow the same rule.
	void Noise(PlayerPawn pmo, Name what, Vector3 at, int i = -1)
	{
		String s;
		double vol = 1.0;
		if (what == 'crack') s = (i >= 0 && i < NW && CrackK(i, crackV[i]) >= 0.5) ? "rsqwp/whip/crackheavy" : "rsqwp/whip/cracklight";
		else if (what == 'swish') { s = "rsqwp/whip/swish"; vol = 0.7; }
		else if (what == 'unfurl') { s = "rsqwp/whip/unfurl"; vol = 0.45; }
		else if (what == 'hit') s = "rsqwp/hit";
		if (s == "") return;
		let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		if (c) c.A_StartSound(s, CHAN_VOICE, 0, vol);
	}

	// A pulse in the hand holding the whip (the series' route: RSQ ShieldSaw's QF_WAVE quake,
	// felt with vr_quake_haptic_level > 0).
	void Buzz(PlayerPawn pmo, int hand, double amp, int tics)
	{
		if (!pmo || !pmo.player || pmo.player != players[consoleplayer]) return;
		amp *= RSQWP_A11y.Rumble();   // RSQ_Accessibility's Rumble Strength x0..2 (0 = none); 1 without it
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
			r.bINVISIBLE = false;
			if (!fresh) r.SetOrigin(pa, true);
			Vector3 room = ToRoom(pb - pa);
			double l = room.Length();
			if (l < 0.01) { r.scale = (w, 0.001); continue; }
			r.angle = atan2(room.y, room.x);
			r.pitch = -atan2(room.z, room.xy.Length()) + 90;
			r.scale = (w, l / RSQWP_Rope.ROPE_L);
			if (fresh) r.ClearInterpolation();
		}
	}

	void Halt(int i)
	{
		wstate[i] = ST_IDLE;
		EndWrap(i);
		byWeapon[i] = false; lassoOn[i] = false; lassoWas[i] = false; markHeld[i] = false; markLine[i] = null;
		lw[i] = 0; lcHad[i] = false; lvw[i] = 0;
		wby[i] = null;
		lockOn[i] = null; lockLine[i] = false; lockLeft[i] = 0; lockHeld[i] = false; lock2[i] = null; reach2[i] = null; reachTic[i] = 0; reachFor[i] = null;
		casting[i] = false;
		stiff[i] = 0; swinging[i] = false; windTics[i] = 0; stuckTics[i] = 0; bodyHad[i] = false;
		ClearMark(i);
		for (int k = 0; k < NP; k++)
		{
			if (wl[i * NP + k]) wl[i * NP + k].Destroy();
			wl[i * NP + k] = null;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < NW; i++) { if (wstate[i] != ST_IDLE) Halt(i); ClearAim(i); casting[i] = false; }
		for (int pn = 0; pn < MAXPLAYERS; pn++) aimBtn[pn] = false;
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

// THE LOCK MARK: the series' lock diamond (owner, approved): a WHITE centre in a GOLD ring, 48x48, 4 frames at 3 tics,
// as RSQ Saber's UBQS_LockMark (scale 0.35 x Cue Size, additive, fullbright, always facing you). The ring's art is
// white and drawn AddShaded in gold (RSQWP_Whip.UpdateMark sets the shade, through the colour-blind palette); the
// centre is drawn as it is. Placed every tic by RSQWP_Whip.UpdateMark; nothing of its own.
class RSQWP_LockRing : Actor
{
	const GOLD = 0xFFD040;       // the series' gold (RSQ Score's GOLD)
	Default
	{
		Scale 0.35;
		Alpha 0.95;
		RenderStyle "AddShaded";
		StencilColor "FF D0 40";
		+NOINTERACTION
		+NOBLOCKMAP
		+BRIGHT
		+NOGRAVITY
		+NOTONAUTOMAP
		+FORCEXYBILLBOARD
		+DONTSPLASH
	}
	States
	{
	Spawn:
		WPKR ABCD 3 Bright;
		Loop;
	}
}

class RSQWP_LockCentre : Actor
{
	Default
	{
		Scale 0.35;
		Alpha 0.95;
		RenderStyle "Add";
		+NOINTERACTION
		+NOBLOCKMAP
		+BRIGHT
		+NOGRAVITY
		+NOTONAUTOMAP
		+FORCEXYBILLBOARD
		+DONTSPLASH
	}
	States
	{
	Spawn:
		WPKC ABCD 3 Bright;
		Loop;
	}
}

// RSQ HP BARS' MARKERS (owner 11-02): a monster the whip has wrapped (a marked crack, the lasso) or tied to it (Bola)
// shows HP Bars' HOOKED mark (handler.zs MarkersOf asks every service whose name holds "RSQTHP_Marker").
class RSQTHP_MarkerWhip : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "hooked") return 0;
		let mo = Actor(objectArg);
		let w = RSQWP_Whip.Get();
		if (!mo || !w) return 0;
		for (int i = 0; i < RSQWP_Whip.NW; i++)
		{
			if (w.wrapOn[i] == mo) return 1;
			if (w.tied[i * 2] == mo || w.tied[i * 2 + 1] == mo) return 1;
		}
		return 0;
	}
}
