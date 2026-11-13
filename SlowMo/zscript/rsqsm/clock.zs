// RSQ_SlowMo -- THE CLOCK. The world slows; you do not.
//
// RS_SlowMo (the owner's engine build) asks the engine for a world time scale.
// Stock QuestZDoom 17.3 has no such call, so this mod keeps the clock itself:
// every actor near a player is TIME-DILATED, not frozen. Freezing the world on
// most tics is easy, but at quarter speed the world would update nine times a
// second, and that stutters in a headset. So every slowed thing still moves every
// tic, by the slowed amount:
//
//   motion     its velocity is scaled by the factor, and its gravity by the factor
//              squared, which is exactly a slowed trajectory (a fall slows too);
//              a missile's Speed is scaled so homing and re-aiming stay slowed;
//              sliding on the ground loses speed at the slowed rate (friction^f).
//   time       every state it enters lasts 1/f as long, with the fractions carried,
//              so a monster steps, fires and dies at the slowed rate; a change of
//              factor mid-state rescales what is left of that state.
//   sound      what it is playing drops in pitch with it (rsm_sound_follow, yours).
//
// A monster's walking is a step of Speed per A_Chase, and A_Chase runs once per
// state: stretching the states slows the walking. Its Speed is NOT also scaled,
// or it would walk at f squared.
//
// THE VR RULE: nothing tracked is slowed. Players, what they carry, and the
// series' own hand-held effects (classes named RSQ*, UBQS*, SSQ*: the grab, the rig's
// props, the shield, the saber) stay on real time. Your own rockets slow (rsqsm_slow_own).
//
// THE SAME DOORS AS RS_SlowMo, so callers do not change:
//   netevent rsm_toggle | rsm_on | rsm_off
//   netevent rsm_pulse <hold ms> <depth %>   (deeper wins, longer wins, eased by
//                                             this mod's own ramps)
//   netevent rsm_state                       (prints the clock)
// and the same host settings: rsm_depth, rsm_ramp_in, rsm_ramp_out, rsm_yield.
// AND A NAMED DOOR for other mods (2026-11-02, README "For other mods"):
//   netevent rsqsm_start:<who> <hold ms> <speed %> <flags>   0 ms = 4 s, 0 % = the World Speed slider,
//                                                            flags 1 = automatic (cooldown, its option)
//   RSQSM_Service GetInt("start" | "start.auto", who, ms, speed 0..1) from synced play code.
//
// AUTOMATIC AND DELIBERATE (owner 2026-11-02: "it's firing all the fuckin time"). Every way in is a
// TRIGGER with a name (Trigger below). A deliberate one -- the key, the wrist cross, the burst, the Wheel,
// the Accessibility button, Melee's shove, the cigarette, a Saber parry or Force Speed, a ShieldSaw block,
// Grenade's Skeet Window -- is never refused for time. An automatic one -- Close-Call, Reload Slowdown, Score,
// Gun Bonsai VR, other mods, the miniboss window, Heavy Hit, the blasts and the barrels -- waits out rsqsm_auto_cooldown seconds after the last automatic pulse ENDED.
// EVERY ONE HAS ITS OWN ON/OFF SWITCH (owner 2026-11-02: "everything has an on off switch"): CatOn below,
// the Triggers page in MENUDEF. A switch only stops a START; turning slow motion off is never refused.
// rsqsm_debug 1 logs each one: its name, the tic and what happened.
//
// STANDING DOWN. Two slow-motion systems compound and cannot see each other (the
// lesson RS_SlowMo paid for). If Xortts' BTX is loaded (by class name, reached
// by string), or RS_SlowMo itself on an engine that has a world clock, this mod
// does nothing and says so, unless rsm_yield is 0.
//
// NETPLAY: the events arrive on every machine on the same tic and everything here
// is computed from synced state; only the sound pitch and the gesture read the
// local player, and the gesture only sends an event.

class RSQSM_Clock : EventHandler
{
	// ---- the clock (synced: in the save, the same on every machine) ----------
	double scale;            // the eased factor, 1 = full speed
	double target;
	bool   on;               // the held toggle
	int    pulseUntil;       // maptime the pulse holds until, 0 none
	double pulseDepth;
	String pulseSrc;         // the trigger that asked for the pulse running now (the last one let in)
	bool   pulseAuto;        // ... and whether it was automatic
	int    autoReady;        // maptime the next automatic trigger may start slow motion
	double adr;              // the adrenaline meter, 0..100
	// SLOW MOTION LENGTH (owner 11-05: yes to a "Slow Motion Length" slider): with Adrenaline off, his held slow motion (the
	// key, the wrist cross, the Wheel, the Accessibility button) lets go by itself after rsqsm_length real seconds; pressing
	// again still ends it early. With Adrenaline on the meter decides, as before. The shootdodge keeps its own end (landing).
	int    heldUntil;        // maptime the held slow motion lets go (Adrenaline off), 0 none
	int    heldWho;          // the player who held it on (his cue when it lets go)
	// ---- THE COUNTDOWN (owner 2026-11-03 19:06; 11-05 03:55 "use our new slowdown timer bar for all slowmo, when player
	// triggers it, it starts full, and drains for however long the player has set it to"; countdown.zs draws it) --------
	// Shown for EVERY slow motion: set when any trigger is let in (Trigger: every pulse, the burst, the named door), when he
	// holds it on (Aim: the key, the wrist cross, the Wheel, the Accessibility button) and when a shootdodge leaps (Dodges);
	// cleared when the world is at full speed again.
	bool   cdOn;             // a slow is running (or easing back out)
	double cdLeft;           // tics of REAL time (level.maptime is never slowed) until the world is at full speed
	double cdTotal;          // what a full bar holds: cdLeft when it last started or refilled
	double cdEndAt;          // the hold's projected real end (maptime) last tic (a later one is a refill)
	int    cdStartTic;       // maptime the bar appeared (also seeds Random colour)
	int    cdRefillTic;      // maptime of the last refill (the glint)
	int    cdEndTic;         // maptime it reached zero (the fade)
	// THE TWO BARS (owner 2026-11-06, approved layout: stored slow-mo LEFT, the automatic countdown RIGHT): the countdown bar
	// shows only while the game slowed time by itself (an automatic trigger, Trigger isAuto); his own slow motion (the key,
	// the wrist cross, the Wheel, a dodge, his own deliberate pulses) leaves it hidden (with Adrenaline on; with it off, the countdown bar shows for every slow motion: countdown.zs ShowsFor). cdAuto: the slow running now (or
	// easing out) was let in by an automatic trigger; cdAutoTic: maptime that became so (the bar's fade in).
	bool   cdAuto;
	int    cdAutoTic;
	// THE CAUSE LINE (owner 2026-11-06): what let in the slow running now, in a few words, drawn under the countdown bar while
	// it shows (countdown.zs): set by every trigger let in (Trigger: CauseWord, or the words a trigger passes, Heavy Hit's)
	String cdCause;
	bool   rival;            // decided once per map
	RSQSM_Smooth smooth;     // the walkers' step-spreader (smooth.zs), made on first use

	// ---- you, slowed (owner 2026-11-03: Xortts' Bullet Time X's model; SlowMe / Dodges below) -------
	int    dodgeTic[MAXPLAYERS];   // maptime a shootdodge began, 0 none
	double meK[MAXPLAYERS];        // the factor on this player's own movement now (1 = full speed)
	double meGrav[MAXPLAYERS];     // his gravity before it was slowed
	double meVx[MAXPLAYERS], meVy[MAXPLAYERS];   // his velocity as SlowMe left it (the momentum mode's thrust estimate)
	private transient bool dodgePend[MAXPLAYERS];   // a Shootdodge key this tic (netevent rsqsm_dodge)

	// ---- the slowed actors (parallel arrays) -----------------------------------
	Array<Actor>  act;
	Array<double> fac;       // the factor applied to it now
	Array<double> baseGrav, baseSpeed, carry;
	Array<State>  lastState;
	Array<int>    lastTics;
	Array<double> lvx, lvy, lvz;   // its velocity as this handler left it last tic

	// ---- local (this machine) ---------------------------------------------------
	private transient int gestT, gestCool;
	private transient bool gestArmed;
	private transient int  pitchTick;
	private transient bool reloadPrimed;

	// The settings the per-actor loop reads, read once a tic (Refresh), not per actor.
	private transient int    cvTic;
	private transient double cvRadius2, cvRoundBase, cvDepth;
	private transient bool   cvSlowOwn;

	const MAXSCAN = 4000;

	static RSQSM_Clock Get() { return RSQSM_Clock(EventHandler.Find("RSQSM_Clock")); }

	// ---- settings ----------------------------------------------------------------
	static double Cv(String n, double d)
	{
		let c = CVar.GetCVar(n);
		return c ? c.GetFloat() : d;
	}
	static double CvP(String n, PlayerInfo p, double d)
	{
		let c = p ? CVar.GetCVar(n, p) : null;
		return c ? c.GetFloat() : d;
	}
	static double CvLocal(String n, double d)
	{
		if (!playeringame[consoleplayer]) return d;
		return CvP(n, players[consoleplayer], d);
	}
	// DEEPER (Gun Bonsai VR, GBOVR_TREES.md 4.9; owner 11-03: the base is today's): at level 0 the World Speed row, as
	// without the patch; learned, 0.2, 0.15, 0.1 at the default World Speed (0.25; the best among the players). The row
	// still sets the depth (owner 11-04 "Row can still turn it off": Deeper has no row of its own, so World Speed scales
	// it -- the node deepens what the row sets by x0.8, 0.6, 0.4, and a shallower row gives a shallower slow motion).
	// curDepth keeps it for the drawing.
	double Depth()
	{
		double d = clamp(Cv("rsm_depth", 0.25), 0.05, 0.95);
		if (gbOn) { int l = GbMax('Deeper'); if (l >= 1) { static const double DEEP_K[] = { 0.8, 0.6, 0.4 }; double k = DEEP_K[clamp(l, 1, 3) - 1]; return clamp(d * k, 0.05, 0.95); } }
		return d;
	}
	double curDepth;

	// ---- THE GUN BONSAI VR PATCH'S LEVELS (GBOVR_TREES.md 4.9), asked by name once a second ----------------------------
	// Without the patch Gb is -1 and every row is as it was. With it: LONGER, DEEPER, CHEAPER shape your slow motion (the key
	// and the rest work from the start, owner 11-03); LEAN DODGE is the unlock of the lean (2: a lean dodges a claw too);
	// MATRIX is the full look.
	transient int gbTic;
	transient bool gbOn;
	transient int gbLonger[MAXPLAYERS], gbDeeper[MAXPLAYERS], gbCheaper[MAXPLAYERS], gbLean[MAXPLAYERS], gbMatrix[MAXPLAYERS];
	void GbRefresh()
	{
		if (gbTic > 0 && level.maptime < gbTic && level.maptime >= gbTic - 35) return;
		gbTic = level.maptime + 35;
		let svc = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		gbOn = svc != null;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			gbLonger[n] = 0; gbDeeper[n] = 0; gbCheaper[n] = 0; gbLean[n] = 0; gbMatrix[n] = 0;
			if (!svc || !playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			gbLonger[n]  = max(0, svc.GetInt("plevel", "Longer", 0, 0, pmo));
			gbDeeper[n]  = max(0, svc.GetInt("plevel", "Deeper", 0, 0, pmo));
			gbCheaper[n] = max(0, svc.GetInt("plevel", "Cheaper", 0, 0, pmo));
			gbLean[n]    = max(0, svc.GetInt("plevel", "LeanDodge", 0, 0, pmo));
			gbMatrix[n]  = max(0, svc.GetInt("plevel", "Matrix", 0, 0, pmo));
			if (!pmo.FindInventory("RSQSM_ClawDodge")) pmo.GiveInventoryType("RSQSM_ClawDodge");
		}
	}
	// a player's level of a node (-1 without the patch); who < 0: the best among the players
	clearscope int Gb(int who, Name what)
	{
		if (!gbOn) return -1;
		if (who < 0 || who >= MAXPLAYERS) return GbMax(what);
		switch (what)
		{
		case 'Longer':     return gbLonger[who];
		case 'Deeper':     return gbDeeper[who];
		case 'Cheaper':    return gbCheaper[who];
		case 'LeanDodge':  return gbLean[who];
		case 'Matrix':     return gbMatrix[who];
		}
		return -1;
	}
	clearscope int GbMax(Name what)
	{
		if (!gbOn) return -1;
		int m = 0;
		for (int n = 0; n < MAXPLAYERS; n++) if (playeringame[n]) m = max(m, Gb(n, what));
		return m;
	}
	// (SLOW MOTION was the unlock of your own triggers under the patch, 11-02; DROPPED 11-03: the key, the wrist cross, the
	// burst and the accessibility button work from the start; the levels only lengthen and deepen it. Its check was removed
	// 11-09.)
	// LONGER: the burst 4 -> 5, 6, 8 s; a full meter lasts 25% longer a level. CHEAPER: the meter spent 20% slower a level.
	int BurstMs(int who) { static const int B[] = { 4000, 5000, 6000, 8000 }; int l = Gb(who, 'Longer'); return l < 0 ? BURST_MS : B[clamp(l, 0, 3)]; }
	double AdrSecs() { int l = GbMax('Longer'); return max(1.0, Cv("rsqsm_adr_secs", 10)) * (1.0 + 0.25 * max(l, 0)); }
	double CostK() { int l = GbMax('Cheaper'); return 1.0 - 0.2 * clamp(l, 0, 3); }
	// LEAN DODGE (every machine reads it): the Lean Out of Bullets row always (off is off, with or without the patch;
	// 0.99a bug 1), and under the patch its Lean Dodge node must be learned as well (the upgrade gates turning it on)
	static bool LeanOn(int n)
	{
		if (Cv("rsqsm_lean", 1) == 0) return false;
		let c = Get();
		int g = c ? c.Gb(n, 'LeanDodge') : -1;
		return g < 0 || g >= 1;
	}
	// MATRIX: the colour drain at full (0.85 at least) while slowed, while its row is on (owner 11-04 "Row can still turn it
	// off"); learning Matrix switches the Colour Drain and Shot Trails rows on once (GBOVR's RowsOnLearn); the trails
	// themselves are drawn the same either way (round.zs)
	static clearscope bool MatrixOn()
	{
		let c = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		return c && c.GbMax('Matrix') >= 1;
	}
	// RSQ_Accessibility's Min SlowMo Ease (rsqa_slowmo_ramp) is a floor under both: no ease
	// shorter than it, so the world never lurches into or out of slow motion. 0 / absent: as set.
	// Slow Motion Length, real seconds (1..30)
	double HeldSecs() { return clamp(Cv("rsqsm_length", 6), 1.0, 30.0); }
	double RampIn()  { return max(max(0.0, Cv("rsm_ramp_in", 0.15)), RSQSM_A11y.SlowRamp()); }
	double RampOut() { return max(max(0.0, Cv("rsm_ramp_out", 0.40)), RSQSM_A11y.SlowRamp()); }

	// Slow motion is doing something this tic (the ramps count).
	bool Active() { return scale < 0.9999 || target < 0.9999; }

	// ---- the rival check -----------------------------------------------------------
	static bool RivalLoaded()
	{
		static const String rivals[] = { "BtActorInfo", "BtTimeFreeze", "BtItemData", "PostTickDummyController", "RSM_Handler" };
		for (int i = 0; i < rivals.Size(); i++)
			if (Object.FindClass(rivals[i]) != null) return true;
		return false;
	}
	bool StoodDown() { return rival && Cv("rsm_yield", 1) != 0; }

	// OnRegister also runs when a save is loaded, AFTER the synced fields are read back
	// (p_saveg.cpp), so it touches only this machine's transient state; the synced
	// defaults are set in WorldLoaded for a new level.
	override void OnRegister()
	{
		gestArmed = true;
		reloadPrimed = false;
		cvTic = -1;
	}

	override void WorldLoaded(WorldEvent e)
	{
		rival = RivalLoaded();
		if (e.IsSaveGame) return;
		// A level never starts slowed (and nothing carries over: the arrays are empty).
		on = false; target = 1; scale = 1; pulseUntil = 0; pulseDepth = 1; pulseSrc = ""; pulseAuto = false; autoReady = 0;
		heldUntil = 0; heldWho = -1;
		cdOn = false; cdLeft = 0; cdTotal = 0; cdEndAt = 0; cdStartTic = 0; cdRefillTic = 0; cdEndTic = 0;
		cdAuto = false; cdAutoTic = 0; cdCause = ""; hhLast = 0;
		rsWho = -1; for (int i = 0; i < MAXPLAYERS * 2; i++) { rlActive[i] = false; rlW[i] = null; }
		ClearAll();
		for (int i = 0; i < MAXPLAYERS; i++) { dodgeTic[i] = 0; meK[i] = 1; meGrav[i] = 0; meVx[i] = 0; meVy[i] = 0; freeUntil[i] = 0; g2FreeUntil[i] = 0; smokeUntil[i] = 0; smokeResume[i] = 0; }
		// THE SMOKE GOES ON (owner 11-11): what was left of a smoke's slow motion when the last level ended (WorldUnloaded),
		// started again on this one's first tic (SmokeKeep), at the same depth and Move at Full Speed rule. Read here, before
		// Brutal Doom clears the inventory as a level starts.
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let t = RSQSM_AdrToken(players[i].mo.FindInventory("RSQSM_AdrToken"));
			if (!t || t.smokeLeft <= 0) continue;
			smokeResume[i] = t.smokeLeft; smokeDepth[i] = t.smokeDepth; smokeMove[i] = t.smokeMove;
			t.smokeLeft = 0;
			Log("smoke", String.Format("player %d carries %d tics of the smoke's slow motion into this level", i, smokeResume[i]));
		}
		// An EventHandler is rebuilt on every map, so the meter is carried on the player.
		adr = 0;
		if (Cv("rsqsm_adr_keep", 1) != 0)
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (!playeringame[i] || !players[i].mo) continue;
				let t = RSQSM_AdrToken(players[i].mo.FindInventory("RSQSM_AdrToken"));
				if (t) { adr = t.meter; break; }
			}
		if (rival)
		{
			if (StoodDown())
				Console.Printf("\c[Red]RSQ_SlowMo: another slow-motion mod is loaded (Xortts' BTX or RS_SlowMo).\n"
					.."\c[Grey]  Two slow-motion systems compound and cannot see each other. RSQ_SlowMo has STOOD DOWN.\n"
					.."  Set rsm_yield 0 to run anyway, or unload one.");
			else
				Console.Printf("\c[Orange]RSQ_SlowMo: another slow-motion mod is loaded and rsm_yield is 0: running anyway. THE TWO WILL COMPOUND.");
		}
	}

	// Leaving the level: every slowed thing is put back (a hub keeps them), and the
	// meter goes with the players to the next one.
	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = act.Size() - 1; i >= 0; i--) Drop(i);
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let pmo = players[i].mo;
			MeRestore(i);
			let t = RSQSM_AdrToken(pmo.FindInventory("RSQSM_AdrToken"));
			if (!t) t = RSQSM_AdrToken(pmo.GiveInventoryType("RSQSM_AdrToken"));
			if (t) t.meter = adr;
			// the smoke's slow motion still running goes with him (owner 11-11: nothing but death and DOWN ends it)
			if (t)
			{
				t.smokeLeft = smokeUntil[i] > level.maptime ? smokeUntil[i] - level.maptime : 0;
				t.smokeDepth = smokeDepth[i]; t.smokeMove = smokeMove[i];
				if (t.smokeLeft > 0) Log("smoke", String.Format("level ends: player %d's smoke slow motion has %d tics left, carried to the next level", i, t.smokeLeft));
			}
		}
	}

	private void ClearAll()
	{
		act.Clear(); fac.Clear(); baseGrav.Clear(); baseSpeed.Clear(); carry.Clear();
		lastState.Clear(); lastTics.Clear(); lvx.Clear(); lvy.Clear(); lvz.Clear();
	}

	// ---- the doors ---------------------------------------------------------------------
	// THE PULSES THIS TIC FROM rsm_pulse, held until WorldTick (the same tic: every network event of a tic
	// runs before the level ticks) so their sender can be told apart -- RS_SlowMo's door carries no name.
	// Transient: nothing is pending across a save.
	private transient Array<int> pendMs, pendDepth, pendWho;
	private transient int pendTic;
	private transient int fearTic[MAXPLAYERS];
	private transient int smokeTic[MAXPLAYERS];
	private transient int skeetTic[MAXPLAYERS];       // RSQ Grenade's Skeet Window marked its pulse this tic
	private transient int quickTic[MAXPLAYERS];       // RSQ Grenade's Quick Grenade marked its pulse this tic
	private transient int remoteTic[MAXPLAYERS];      // RSQ Saber's training remote marked its pulse this tic
	private transient int smokeFree[MAXPLAYERS];   // the smoke's pulse asked that this player move at full speed (Rig arg 3)
	int freeUntil[MAXPLAYERS];                     // ...until this maptime (the smoke's length plus the way out)
	// THE SMOKE'S SLOW MOTION IS KEPT (owner 2026-11-11 13:54: "i don't want anything ending cig slmo except Quick/Dead ...
	// or Death"). Each smoker's own end, apart from the shared pulse, so nothing else cuts it short (SmokeKeep): a held
	// toggle (the key, the Wheel: it outranks a pulse and zeroes it), a miniboss window taking the pulse over and ending
	// early, a reload's cut. Only his death and his DOWN end it. A level change carries what is left (WorldUnloaded ->
	// RSQSM_AdrToken -> WorldLoaded -> resumed on the new level's first tics, SmokeResume).
	int    smokeUntil[MAXPLAYERS];      // maptime the smoke's slow motion holds until, 0 none
	double smokeDepth[MAXPLAYERS];
	bool   smokeMove[MAXPLAYERS];       // Move at Full Speed While Smoking was asked
	int    smokeResume[MAXPLAYERS];     // tics carried in from the last level, started on this one's first tic (0 none)

	override void NetworkProcess(ConsoleEvent e)
	{
		// rsm_toggle's first argument says who: 1 the wrist cross, 2 this mod's key (KEYCONF). Bare, it is RSQ
		// Accessibility's button when that mod is loaded (rsqa_core.zs sends it bare), else a key bound by hand.
		if (e.Name ~== "rsm_toggle")
		{
			int a = e.Args[0];
			if (a == 1) Aim(!on, e.Player, "wristcross", CAT_WRIST);
			else if (a == 2 || !A11yLoaded()) Aim(!on, e.Player, "key", CAT_KEY);
			else Aim(!on, e.Player, "a11y.button", CAT_A11Y);
		}
		// rsm_on: RSQ Wheel opening (the series' only sender, Wheel zscript.zs)
		else if (e.Name ~== "rsm_on")   Aim(true, e.Player, "wheel", CAT_WHEEL);
		// the Shootdodge key (KEYCONF): the leap is made in WorldTick, after the engine's own player think of this tic
		else if (e.Name ~== "rsqsm_dodge") { if (e.Player >= 0 && e.Player < MAXPLAYERS) dodgePend[e.Player] = true; }
		else if (e.Name ~== "rsm_off")  Aim(false, e.Player, "rsm_off");
		else if (e.Name ~== "rsm_pulse")
		{
			if (pendTic != level.maptime) { pendTic = level.maptime; pendMs.Clear(); pendDepth.Clear(); pendWho.Clear(); }
			pendMs.Push(e.Args[0]); pendDepth.Push(e.Args[1]); pendWho.Push(e.Player);
		}
		// RSQ Melee sends its F.E.A.R. window with the shove's pulse, from the same machine on the same tic
		// (Melee shove.zs Pulse): seen by name, it marks that pulse as the shove (deliberate).
		else if (e.Name ~== "rsqml_fear") { if (e.Player >= 0 && e.Player < MAXPLAYERS) fearTic[e.Player] = level.maptime; }
		// RSQ Tactical Rig's cigarette names its pulse the same way (cig.zs, sent with its rsm_pulse on the same tic): that
		// pulse is the smoke, whatever its length (0.99a bug 43: Gun Bonsai VR's Smoker lengthens it, so length can't tell)
		else if (e.Name ~== "rsqgn_skeetslowmo") { if (e.Player >= 0 && e.Player < MAXPLAYERS) skeetTic[e.Player] = level.maptime; }
		else if (e.Name ~== "rsqgn_quickslowmo") { if (e.Player >= 0 && e.Player < MAXPLAYERS) quickTic[e.Player] = level.maptime; }
		else if (e.Name ~== "ubqs_remoteslowmo") { if (e.Player >= 0 && e.Player < MAXPLAYERS) remoteTic[e.Player] = level.maptime; }
		else if (e.Name ~== "rsqtr_cigslowmo") { if (e.Player >= 0 && e.Player < MAXPLAYERS) { smokeTic[e.Player] = level.maptime; smokeFree[e.Player] = e.Args[2]; } }
		else if (e.Name ~== "rsqsm_start" || e.Name.Left(12) ~== "rsqsm_start:")
		{
			String who = e.Name.Length() > 12 ? e.Name.Mid(12) : "netevent";
			bool isAuto = (e.Args[2] & 1) != 0;
			double sp = e.Args[1] > 0 ? e.Args[1] / 100.0 : 0;
			Start(who, e.Args[0], sp, isAuto, e.Player);
		}
		else if (e.Name ~== "rsqsm_burst") Burst(e.Player);
		else if (e.Name ~== "rsm_state")
			Console.Printf("slow motion: %s, scale %.2f heading for %.2f (depth %.2f), %d actors slowed, adrenaline %.0f%s%s%s",
				on ? "ON" : "off", scale, target, Depth(), act.Size(), adr,
				pulseUntil > 0 ? String.Format(", pulse %.2f for %d tics (%s)", pulseDepth, pulseUntil - level.maptime, pulseSrc) : "",
				autoReady > level.maptime ? String.Format(", automatic triggers wait %.1f s", (autoReady - level.maptime) / double(TICRATE)) : "",
				StoodDown() ? ", STOOD DOWN (rival loaded)" : "");
	}

	// WHO SENT AN rsm_pulse (RS_SlowMo's door has no name). Read from the callers' own code, 2026-11-02:
	//   RSQ Melee shove            rsm_pulse <rsqml_shove_slowmo_ms> 35, then rsqml_fear the same tic  -> deliberate
	//   RSQ Tactical Rig cigarette rsm_pulse <smoke ms> <rsqtr_cig_depth>, then rsqtr_cigslowmo the same tic -> deliberate
	//   RSQ Saber perfect parry (ubqs_parry_slowmo), RSQ ShieldSaw perfect block (ssq_perfect_slowmo): both
	//     rsm_pulse 500 35, told apart by whose option is on and what the sender holds (ParryOrBlock) -> deliberate
	//   RSQ ShieldSaw block under Gun Bonsai's Shield Wall: rsm_pulse 750/1000/1250 35 -> deliberate (ShieldSaw Block)
	//   RSQ Saber Force Speed (Gun Bonsai patch): rsm_pulse <secs x 1000> 35 -> deliberate (no switch: a power you use)
	//   RSQ Grenade Skeet Window: rsm_pulse <tics> <rsm_depth>, then rsqgn_skeetslowmo the same tic -> deliberate
	//   RSQ VisualRewards (damage numbers' level-up): rsm_pulse 500 30 -> other mods (automatic)
	//   RSQ Miniboss's slow window (RSQMB_Service "window" > 0, by name), re-sent each second            -> automatic
	//   RSQ Score (Score handler.zs): big moment 600 35; hit-stop (115 + rsm_ramp_in x 1000) 5            -> automatic
	//   Gun Bonsai VR patch (up_melee.zs, up_suite.zs): Adrenaline min(300+150 lv, 1500) max(60-5 lv, 30);
	//     Showdown 450/600/750 45; Time Dilation 400/550/700 at rsm_depth                                -> automatic
	//   anything else: other / unknown mods                                                              -> automatic
	// A mod that wants its own name and rules uses the named door instead (rsqsm_start:<who>).
	private void ResolvePulses()
	{
		if (pendTic != level.maptime) return;
		for (int i = 0; i < pendMs.Size(); i++)
		{
			int ms = pendMs[i], dp = pendDepth[i], who = pendWho[i];
			double depth = clamp(dp / 100.0, 0.05, 1.0);
			bool okWho = who >= 0 && who < MAXPLAYERS && playeringame[who];
			if (okWho && fearTic[who] == level.maptime) { Trigger("melee.shove", CAT_SHOVE, ms, depth, false, who); continue; }
			if (okWho && smokeTic[who] == level.maptime)
			{
				SmokeStart(who, ms, depth, smokeFree[who] != 0, "the flick");
				continue;
			}
			// GRENADE'S SKEET WINDOW (its "rsqgn_skeetslowmo" the same tic, by name): deliberate -- your throw earned it; its
			// own row (rsqgn_skeet_window) already decided. Was taken for Gun Bonsai's Time Dilation (same ms and depth).
			if (okWho && skeetTic[who] == level.maptime) { Trigger("grenade.skeet", CAT_NONE, ms, depth, false, who); continue; }
			// RSQ GRENADE'S QUICK GRENADE (owner 11-10, its "rsqgn_quickslowmo" the same tic, by name): a deliberate throw from
			// the quick key, slowed so the grenade can be shot in the air; its row here is Quick Grenade (Your Triggers)
			if (okWho && quickTic[who] == level.maptime) { Trigger("grenade.quick", CAT_QUICKNADE, ms, depth, false, who); continue; }
			// RSQ SABER'S TRAINING REMOTE (owner 11-10, its "ubqs_remoteslowmo" the same tic): a deflect, or the remote downed
			if (okWho && remoteTic[who] == level.maptime) { Trigger("saber.remote", CAT_REMOTE, ms, depth, false, who); continue; }
			// RSQ SABER and RSQ SHIELDSAW send at 35 %: the parry and the block at 500 ms, a block under Gun Bonsai's Shield
			// Wall at its own length (750 / 1000 / 1250), the Saber's Force Speed at its seconds (3 s and up). Until 11-09
			// only exactly 500 ms was recognised: the rest fell to Other Mods (automatic, cooldown, the wrong switch).
			if (dp == 35 && ms != 500)
			{
				int pb2 = ParryOrBlock(okWho ? who : -1, true);
				if (pb2 & 2) { Trigger("shieldsaw.block", CAT_BLOCK, ms, depth, false, who); continue; }
				if (pb2 & 1) { Trigger("saber.forcespeed", CAT_NONE, ms, depth, false, who); continue; }
			}
			if (ms == 500 && dp == 35)
			{
				int pb = ParryOrBlock(okWho ? who : -1);
				if (pb == 1) { Trigger("saber.parry", CAT_PARRY, ms, depth, false, who); continue; }
				if (pb == 2) { Trigger("shieldsaw.block", CAT_BLOCK, ms, depth, false, who); continue; }
				if (pb == 3)
				{
					// both could have sent it (a saber in one hand, the ShieldSaw in the other): needs both switches
					if (!CatOn(CAT_PARRY, who) || !CatOn(CAT_BLOCK, who)) { Log("parry.or.block", "refused: Saber Parry or ShieldSaw Block switch is off"); continue; }
					Trigger("parry.or.block", CAT_PARRY, ms, depth, false, who); continue;
				}
			}
			if (MinibossWindow() > 0) { Trigger("miniboss", CAT_MINIBOSS, ms, depth, true, who); continue; }
			if (IsScorePulse(ms, dp)) { Trigger("score", CAT_SCORE, ms, depth, true, who); continue; }
			if (IsBonsaiPulse(ms, dp)) { Trigger("gunbonsai", CAT_GBVR, ms, depth, true, who); continue; }
			Trigger("othermod", CAT_OTHER, ms, depth, true, who);
		}
		pendMs.Clear(); pendDepth.Clear(); pendWho.Clear();
	}

	// THE SMOKE STARTS (the flick, or what was left of it carried into a new level): the pulse as any trigger's, and the
	// smoker's own end kept (smokeUntil). Kept too while slow motion is held on (Trigger: "not needed"): it takes over
	// when the hold lets go. Not kept when its switch is off or SlowMo stood down.
	private void SmokeStart(int who, int ms, double depth, bool move, String how)
	{
		// RSQ Tactical Rig's Move at Full Speed While Smoking (owner 11-05): the smoker is not slowed for its length
		if (move) freeUntil[who] = level.maptime + ms * TICRATE / 1000 + int(Cv("rsm_ramp_out", 0.4) * TICRATE) + 1;
		bool ok = Trigger("smoke", CAT_SMOKE, ms, depth, false, who);
		if (!ok && !(on && !StoodDown() && CatOn(CAT_SMOKE, who))) return;
		smokeUntil[who] = level.maptime + int(ceil(clamp(ms, 30, PULSE_MAX_MS) * TICRATE / 1000.0));
		// added on after a running slow (Trigger stacked it): the smoke runs to the combined end, walking free all of it
		if (ok && pulseUntil > smokeUntil[who]) smokeUntil[who] = pulseUntil;
		if (move) freeUntil[who] = max(freeUntil[who], smokeUntil[who] + int(Cv("rsm_ramp_out", 0.4) * TICRATE) + 1);
		smokeDepth[who] = clamp(depth, 0.05, 1.0);
		smokeMove[who] = move;
		Log("smoke", String.Format("%s: player %d's smoke slow motion kept until t%d (%d tics) at %d%%%s", how, who, smokeUntil[who],
			smokeUntil[who] - level.maptime, int(smokeDepth[who] * 100 + 0.5), move ? ", he moves at full speed" : ""));
	}

	// Only death and DOWN end a smoke (owner 11-11). The pulse is cut only where the smoke was what held it (a pulse
	// running past the smoke's end is another trigger's and keeps its own time); another smoker's time stays.
	private void SmokeEnd(int n, String why)
	{
		int was = smokeUntil[n];
		smokeUntil[n] = 0;
		smokeResume[n] = 0;
		freeUntil[n] = min(freeUntil[n], level.maptime);
		int other = 0;
		for (int i = 0; i < MAXPLAYERS; i++) if (i != n && smokeUntil[i] > level.maptime) other = max(other, smokeUntil[i]);
		bool cut = !on && pulseUntil > level.maptime && pulseUntil <= was && pulseUntil > other;
		if (cut) pulseUntil = max(level.maptime, other);
		Log("smoke", String.Format("player %d's smoke slow motion ENDS: %s (%d tics were left)%s", n, why, max(0, was - level.maptime),
			cut ? String.Format(", pulse now until t%d", pulseUntil) : ", the pulse is not the smoke's alone and keeps its time"));
	}

	// Every tic, before the clock picks its target: carried-in smoke resumed, death and DOWN end a smoke, and a smoke still
	// running holds the pulse to its own end (deeper wins, longer wins, as Pulse merges) once nothing outranks it.
	private void SmokeKeep()
	{
		let dn = RSQSM_Down.Get();
		int best = 0, who = -1;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			bool alive = playeringame[n] && players[n].mo && players[n].mo.health > 0 && players[n].playerstate != PST_DEAD;
			if (smokeResume[n] > 0 && alive && level.maptime >= 1)
			{
				int left = smokeResume[n];
				smokeResume[n] = 0;
				SmokeStart(n, int(ceil(left * 1000.0 / TICRATE)), smokeDepth[n], smokeMove[n], String.Format("resumed on the new level (%d tics carried)", left));
			}
			if (smokeUntil[n] <= 0) continue;
			if (!alive) { SmokeEnd(n, "death"); continue; }
			if (dn && dn.IsDown(n)) { SmokeEnd(n, "DOWN"); continue; }
			if (smokeUntil[n] <= level.maptime) { smokeUntil[n] = 0; Log("smoke", String.Format("player %d's smoke slow motion ran its time", n)); continue; }
			if (smokeUntil[n] > best) { best = smokeUntil[n]; who = n; }
		}
		if (who < 0 || on || StoodDown() || pulseUntil >= best) return;
		if (pulseUntil <= level.maptime)
		{
			// the other trigger's slow (or the held one) is over: the smoke's own takes the clock back
			Log("smoke", String.Format("the smoke takes the slow motion back (from %s), until t%d", pulseSrc != "" ? pulseSrc : (cdOn ? "a held slow motion" : "nothing"), best));
			pulseDepth = smokeDepth[who];
			pulseSrc = "smoke";
			pulseAuto = false;
			CountdownStart("smoke");
			SetCdAuto(true);     // the cigarette shows the green world bar (owner 11-11)
			cdCause = CauseWord("smoke");
		}
		else pulseDepth = min(pulseDepth, smokeDepth[who]);
		pulseUntil = best;
	}

	static bool Loaded(Name cn) { class<Object> c = cn; return c != null; }
	static bool A11yLoaded() { return Loaded('RSQA_Menu'); }
	static bool OptOn(Name n) { let c = CVar.FindCVar(n); return c && c.GetInt() != 0; }
	static bool HoldsKind(int who, Name cn)
	{
		if (who < 0) return false;
		class<Actor> c = cn;
		if (!c) return false;
		let p = players[who];
		return (p.ReadyWeapon && p.ReadyWeapon is c) || (p.OffhandWeapon && p.OffhandWeapon is c);
	}
	// 500 ms at 35 %: 1 RSQ Saber's parry, 2 RSQ ShieldSaw's block, 3 could be either, 0 neither. A sender counts only
	// with its mod loaded, its slow-mo option on, and (if a player is known) its weapon in one of his hands.
	// anyLen (not 500 ms): the saber counts without its parry option (Force Speed is a power you use, not the parry);
	// the ShieldSaw still needs its Perfect-Block Slow-Mo row (Shield Wall only sends with it on)
	private int ParryOrBlock(int who, bool anyLen = false)
	{
		bool sb = (anyLen || OptOn('ubqs_parry_slowmo')) && Loaded('UBQS_SaberBase') && (who < 0 || HoldsKind(who, 'UBQS_SaberBase'));
		bool ss = OptOn('ssq_perfect_slowmo') && Loaded('SSQ_ShieldSaw') && (who < 0 || HoldsKind(who, 'SSQ_ShieldSaw'));
		return (sb ? 1 : 0) + (ss ? 2 : 0);
	}
	// RSQ Score's two pulses (Score handler.zs PULSE_MS/PULSE_DEPTH, HitStopMs/HITSTOP_DEPTH), with Score loaded
	static bool IsScorePulse(int ms, int dp)
	{
		if (!Loaded('RS_ScoreHandler')) return false;
		if (ms == 600 && dp == 35) return true;
		let c = CVar.FindCVar("rsm_ramp_in");
		return dp == 5 && ms == 115 + int(clamp(c ? c.GetFloat() : 0.0, 0.0, 1.0) * 1000);
	}
	// the Gun Bonsai VR patch's three perks that pulse (up_melee.zs Adrenaline, up_suite.zs Showdown, Time Dilation)
	static bool IsBonsaiPulse(int ms, int dp)
	{
		if (!Loaded('RSQ_Upgrade_Adrenaline')) return false;
		for (int lv = 1; lv <= 20; lv++)
			if (ms == min(300 + 150 * lv, 1500) && dp == max(60 - 5 * lv, 30)) return true;
		if (dp == 45 && (ms == 450 || ms == 600 || ms == 750)) return true;
		let c = CVar.FindCVar("rsm_depth");
		return (ms == 400 || ms == 550 || ms == 700) && dp == int(clamp(c ? c.GetFloat() : 0.25, 0.05, 0.95) * 100);
	}

	private transient bool mbLooked;
	private transient Service mbSvc;
	private int MinibossWindow()
	{
		if (!mbLooked) { mbLooked = true; let it = ServiceIterator.Find("RSQMB_Service"); mbSvc = it.Next(); }
		return mbSvc ? mbSvc.GetInt("window") : 0;
	}

	private void Aim(bool want, int who, String why = "toggle", int cat = CAT_NONE)
	{
		if (StoodDown()) return;
		// a switched-off trigger cannot START it; stopping is never refused
		if (want && !on && !CatOn(cat, who)) { Log(why, String.Format("refused: its switch is off (%s)", CatName(cat))); return; }
		if (want && Cv("rsqsm_adrenaline", 0) != 0 && adr < Cv("rsqsm_adr_min", 25))
		{
			// Not enough in the meter: a short, low buzz on the hand that asked.
			if (who >= 0 && who < MAXPLAYERS && playeringame[who] && players[who].mo)
			{
				RSQSM_Buzz.Start(players[who].mo, 0, 0.25, 3);
				players[who].mo.A_StartSound("*usefail", CHAN_AUTO, CHANF_LOCAL, 0.6);   // stock DSNOWAY (SNDINFO.txt)
			}
			Log(why, "refused: not enough adrenaline");
			return;
		}
		bool was = on;
		on = want;
		// THE WHEEL HOLDS FOR AS LONG AS IT IS OPEN (owner 2026-11-09 21:13): with Adrenaline off its slow motion has no
		// Slow Motion Length; the Wheel's rsm_off when it closes ends it. Every other held start keeps the length.
		if (on && !was) { heldUntil = cat == CAT_WHEEL ? 0 : level.maptime + int(ceil(HeldSecs() * TICRATE)); heldWho = who; }
		if (!on) heldUntil = 0;
		if (on) { pulseUntil = 0; CountdownStart(why, true); SetCdAuto(false); cdCause = CauseWord(why); }     // the toggle outranks a pulse; the bar starts (or refills) full
		// A CUE ONLY FOR A CHANGE. An rsm_off to a clock already off (the Wheel closing after the
		// adrenaline meter refused its rsm_on; a meter that ran dry) played the way-out sound and
		// rumble with nothing ending (measured on the rig, bugfix pass 10-31: rsm_off with the clock
		// off -> two rumble cues).
		if (on == was) return;
		Log(why, on ? String.Format("held ON at %d%%", int(Depth() * 100 + 0.5)) : "held off");
		if (who >= 0 && who < MAXPLAYERS && playeringame[who] && players[who].mo)
		{
			players[who].mo.A_StartSound(on ? "rsqsm/in" : "rsqsm/out", CHAN_AUTO, 0, 0.8);
			RSQSM_Buzz.Start(players[who].mo, 0, on ? 0.6 : 0.3, on ? 8 : 4);
			RSQSM_Buzz.Start(players[who].mo, 1, on ? 0.6 : 0.3, on ? 8 : 4);
		}
	}

	// ---- the triggers ---------------------------------------------------------------------------
	// ONE SWITCH PER TRIGGER (the Triggers page). User switches (the player's own inputs) are read for the
	// player who sent it; server ones are the world's.
	enum ECat { CAT_NONE, CAT_CLOSECALL, CAT_RELOAD, CAT_OTHER, CAT_MINIBOSS, CAT_KEY, CAT_WRIST, CAT_BURST, CAT_WHEEL,
		CAT_A11Y, CAT_SHOVE, CAT_SMOKE, CAT_PARRY, CAT_BLOCK, CAT_SCORE, CAT_GBVR, CAT_DODGE, CAT_GRENADE, CAT_OU, CAT_HEAVY,
		CAT_BLOCKON, CAT_BMULTI, CAT_BCHAIN, CAT_BNEAR, CAT_QUICKNADE, CAT_REMOTE, CAT_GSLAM }
	static double CvWho(String n, int who, double d)
	{
		return (who >= 0 && who < MAXPLAYERS && playeringame[who]) ? CvP(n, players[who], d) : Cv(n, d);
	}
	static bool CatOn(int cat, int who = -1)
	{
		switch (cat)
		{
		case CAT_KEY:       return CvWho("rsqsm_trig_key", who, 1) != 0;
		case CAT_DODGE:     return CvWho("rsqsm_trig_dodge", who, 1) != 0;
		case CAT_WRIST:     return CvWho("rsqsm_gesture", who, 1) != 0;
		case CAT_BURST:     return CvWho("rsqsm_trig_burst", who, 1) != 0;
		case CAT_WHEEL:     return CvWho("rsqsm_trig_wheel", who, 1) != 0;
		case CAT_A11Y:      return CvWho("rsqsm_trig_a11y", who, 1) != 0;
		case CAT_SHOVE:     return Cv("rsqsm_trig_shove", 1) != 0;
		case CAT_SMOKE:     return Cv("rsqsm_trig_smoke", 1) != 0;
		case CAT_PARRY:     return Cv("rsqsm_trig_parry", 1) != 0;
		case CAT_BLOCK:     return Cv("rsqsm_trig_block", 1) != 0;
		case CAT_MINIBOSS:  return Cv("rsqsm_auto_miniboss", 1) != 0;
		case CAT_CLOSECALL: return Cv("rsqsm_closecall", 0) != 0;
		case CAT_RELOAD:    return CvWho("rsqsm_reload", who, 0) != 0;
		case CAT_SCORE:     return Cv("rsqsm_trig_score", 1) != 0;
		case CAT_GBVR:      return Cv("rsqsm_trig_gbvr", 1) != 0;
		case CAT_OTHER:     return Cv("rsqsm_auto_other", 1) != 0;
		case CAT_GRENADE:   return Cv("rsqsm_trig_grenade", 0) != 0;
		case CAT_OU:        return Cv("rsqsm_trig_ou", 0) != 0;
		case CAT_HEAVY:     return Cv("rsqsm_trig_heavy", 1) != 0;
		case CAT_BLOCKON:   return Cv("rsqsm_trig_barrel_lock", 1) != 0;
		case CAT_BMULTI:    return Cv("rsqsm_trig_barrel_multi", 1) != 0;
		case CAT_BCHAIN:    return Cv("rsqsm_trig_barrel_chain", 1) != 0;
		case CAT_BNEAR:     return Cv("rsqsm_trig_barrel_near", 1) != 0;
		case CAT_QUICKNADE: return Cv("rsqsm_trig_quicknade", 1) != 0;
		case CAT_REMOTE:    return Cv("rsqsm_trig_remote", 1) != 0;
		case CAT_GSLAM:     return Cv("rsqsm_trig_grappleslam", 1) != 0;
		}
		return true;
	}
	static String CatName(int cat)
	{
		static const String names[] = { "-", "Close-Call", "Reload Slowdown", "Other / Unknown Mods", "Miniboss Window",
			"Manual Key", "Wrist Cross", "Burst", "Wheel", "Accessibility Button", "Melee Shove", "Cigarette",
			"Saber Parry", "ShieldSaw Block", "Score", "Gun Bonsai VR", "Crisis Dive", "Grenade Blast", "Over-Under Blast",
			"Heavy Hit Slowdown", "Locked Barrel", "Barrel Multi-Kill", "Chain Reaction", "Barrel Near You", "Quick Grenade", "Training Remote", "Grapple-Slam" };
		return (cat >= 0 && cat < names.Size()) ? names[cat] : "?";
	}
	double Cooldown() { return clamp(Cv("rsqsm_auto_cooldown", 25), 0.0, 120.0); }

	void Log(String src, String what)
	{
		if (Cv("rsqsm_debug", 0) == 0) return;
		Console.Printf("RSQ_SlowMo: trigger %s t%d: %s", src, level.maptime, what);
	}

	// ONE WAY IN FOR EVERY PULSE. Every trigger needs its switch; a deliberate one is never refused for time; an
	// automatic one also waits out the cooldown -- except one that only stretches the pulse it started itself (the
	// miniboss window re-asks each second). Answers whether it was let in.
	// cause: the words under the countdown bar ("" = CauseWord(src)). shared: false for an automatic trigger with a cooldown
	// of its own (Heavy Hit Slowdown, unless its Cooldown row says Use Shared): it neither waits out nor starts the shared one.
	// exact: never added on after a running slow (the smoke's adding-up below is skipped): longer wins, so a caller that asks
	// again and again (Grapple 2.0's kick-chain, g2.slow) gets what it asks for and never more
	bool Trigger(String src, int cat, int ms, double depth, bool isAuto, int who = -1, String cause = "", bool shared = true, bool exact = false)
	{
		if (StoodDown()) { Log(src, "refused: stood down (another slow-motion mod)"); return false; }
		if (on) { Log(src, "not needed: slow motion is held on"); return false; }
		if (!CatOn(cat, who)) { Log(src, String.Format("refused: its switch is off (%s)", CatName(cat))); return false; }
		if (isAuto && shared)
		{
			bool stretch = pulseUntil > 0 && pulseAuto && pulseSrc == src;
			if (!stretch && level.maptime < autoReady)
			{
				Log(src, String.Format("refused: automatic cooldown, %.1f s left", (autoReady - level.maptime) / double(TICRATE)));
				return false;
			}
		}
		bool fresh = pulseUntil <= 0;
		// THE CIGARETTE AND THE WORLD'S SLOW MOTION ADD UP (owner 11-11): a smoke lit during a running slow adds its time
		// after it; a world slow (an automatic trigger, or the revive) during a smoke adds its time after the smoke's
		bool world = isAuto || src ~== "down.up";
		bool smoking = false;
		for (int i = 0; i < MAXPLAYERS; i++) if (smokeUntil[i] > level.maptime) smoking = true;
		bool stack = !exact && pulseUntil > level.maptime && ((src ~== "smoke") || (world && smoking));
		Pulse(ms, depth, stack);
		if (stack && world)
			for (int i = 0; i < MAXPLAYERS; i++)
				if (smokeUntil[i] > level.maptime)
				{
					// one combined slow: the smoke's own end (and its full-speed walk) runs to the combined end
					smokeUntil[i] = max(smokeUntil[i], pulseUntil);
					if (smokeMove[i]) freeUntil[i] = max(freeUntil[i], pulseUntil + int(Cv("rsm_ramp_out", 0.4) * TICRATE) + 1);
				}
		pulseSrc = src;
		pulseAuto = isAuto;
		CountdownStart(src);     // every slow motion runs the countdown (owner 11-05 03:55); CountdownTick refills it when the end moves later
		                         // (not on every ask: the miniboss window re-asks each second)
		SetCdAuto(world || src ~== "smoke");   // ... and the green world bar shows for an automatic one (owner 11-06), the revive
		                         // and the cigarette (owner 11-11: "why the hell is there not a world slomo bar when we revive")
		cdCause = cause != "" ? cause : CauseWord(src);
		if (isAuto && shared) autoReady = max(autoReady, pulseUntil + int(Cooldown() * TICRATE));
		Log(src, String.Format("%s %d ms at %d%% (%s), pulse until t%d, cause line \"%s\"", fresh ? "started" : stack ? "added on" : "merged", ms, int(depth * 100 + 0.5),
			isAuto ? (shared ? "automatic" : "automatic, own cooldown") : "deliberate", pulseUntil, cdCause));
		return true;
	}

	// THE CAUSE LINE'S WORDS for each trigger (owner 2026-11-06: "one short line naming what caused it, for EVERY automatic
	// slowdown"; 07:00: with Adrenaline off, his OWN slow motion shows the bar and its line too). With Adrenaline on only an
	// automatic slow shows the bar (the stored bar is the meter), so only those words are seen then. A named-door caller
	// (rsqsm_start:<who>) is shown by its own name.
	static String CauseWord(String src)
	{
		static const String keys[] = { "grenade", "overunder", "reload", "closecall", "miniboss", "score", "gunbonsai", "othermod",
			"smoke", "melee.shove", "saber.parry", "shieldsaw.block", "parry.or.block", "wristcross.burst", "bossfight", "heavyhit",
			"key", "wristcross", "wheel", "a11y.button", "shootdodge", "barrel.lockon", "barrel.multikill", "barrel.chain", "barrel.near" };
		static const String words[] = { "GRENADE BLAST", "OVER-UNDER BLAST", "RELOAD", "CLOSE CALL", "MINIBOSS", "SCORE", "GUN BONSAI", "OTHER MOD",
			"CIGARETTE", "SHOVE", "PARRY", "BLOCK", "PARRY", "BURST", "MINIBOSS INCOMING", "HEAVY HIT",
			"SLOW MOTION", "WRIST CROSS", "WHEEL", "SLOW MOTION", "CRISIS DIVE", "LOCKED BARREL", "BARREL MULTI-KILL", "CHAIN REACTION", "BARREL BLAST" };
		for (int i = 0; i < keys.Size(); i++) if (src ~== keys[i]) return words[i];
		String w = src;
		w.Replace(".", " ");
		w.Replace("_", " ");
		return w.MakeUpper();
	}

	// THE NAMED DOOR (netevent rsqsm_start:<who>, RSQSM_Service "start"): 0 ms = 4 s, speed 0 = the slider.
	// Both kinds come under the Other / Unknown Mods switch; only the automatic kind waits out the cooldown.
	const START_MS = 4000;
	bool Start(String who, int ms, double speed, bool isAuto, int sender = -1)
	{
		if (ms <= 0) ms = START_MS;
		double depth = speed > 0 ? clamp(speed, 0.05, 1.0) : Depth();
		return Trigger(who, CAT_OTHER, ms, depth, isAuto, sender);
	}

	// ---- GRAPPLE 2.0'S DOORS (design/PLANNED_PROJECTS.md "Grapple 2.0", owner 2026-11-12 / 11-13; RSQSM_Service "g2.*") --------
	// Grapple 2.0 asks by name; nothing links. Rig only, not headset-confirmed.
	//   G2Slow     the kick-chain's slow motion (1.5, 1.2, 0.9 ... s, each link asking again): a GAME slow (the world bar and
	//              the reason line under it, Adrenaline on or off) at the World Speed slider's speed, under the Triggers page's
	//              Other / Unknown Mods switch, with NO shared cooldown (it neither waits one out nor starts one, or the
	//              second link of a chain would be refused), never added on after a running slow (exact): longer wins, so the
	//              hold is at least what was asked and never more than the longest ask still running.
	//   G2AddTime  more time on the slow running now (the double jump's +0.5 s, the time markers' +0.25 / +0.5 s): its end
	//              moves later by exactly that much (the countdown bar refills), the reason line shows the reason. Nothing
	//              running: nothing added. Same switch. The 30 s cap of every pulse holds.
	//   G2Slam     the air spike's landing (Grapple-Slam, its own row beside Barrel Near You): Barrel Near You's slow
	//              motion (Blast Time, the World Speed slider's speed), an automatic GAME slow, but with no shared cooldown:
	//              the spike lands inside the chain's own slow motion, which a shared cooldown would refuse.
	//   G2Free     his own movement at full speed (Slow Me Too skipped) for some tics (SlowMe): the fling and the ledge save
	const G2_CAP_TICS = 1050;   // PULSE_MAX_MS (30 s) in tics
	int g2FreeUntil[MAXPLAYERS];   // maptime this player's movement is left at full speed until (G2Free), 0 none
	bool G2Slow(String reason, int tics, int who)
	{
		if (tics <= 0) return false;
		// tics -> ms so that Pulse's ceil(ms x 35 / 1000) gives back exactly `tics`
		int ms = int(min(tics, G2_CAP_TICS) * 1000.0 / TICRATE);
		return Trigger("grapple", CAT_OTHER, ms, Depth(), true, who, reason != "" ? reason : "GRAPPLE", false, true);
	}
	bool G2AddTime(String reason, int tics, int who)
	{
		if (tics <= 0) return false;
		if (StoodDown()) { Log("grapple.addtime", "refused: stood down (another slow-motion mod)"); return false; }
		if (!CatOn(CAT_OTHER, who)) { Log("grapple.addtime", "refused: its switch is off (Other / Unknown Mods)"); return false; }
		int now = level.maptime, cap = now + G2_CAP_TICS;
		if (on)
		{
			// held on with a set end (Adrenaline off: Slow Motion Length): that end moves; held with no end (the Wheel, or the
			// meter): nothing to add to
			if (heldUntil <= now) { Log("grapple.addtime", "not added: slow motion is held on with no set end"); return false; }
			heldUntil = min(heldUntil + tics, cap);
		}
		else
		{
			if (pulseUntil <= now) { Log("grapple.addtime", "not added: no slow motion running"); return false; }
			pulseUntil = min(pulseUntil + tics, cap);
		}
		if (reason != "") cdCause = reason;
		Log("grapple.addtime", String.Format("+%d tics, %s now until t%d, cause line \"%s\"", tics, on ? "held slow" : "pulse", on ? heldUntil : pulseUntil, cdCause));
		return true;
	}
	bool G2Slam(int who)
	{
		return Trigger("grapple.slam", CAT_GSLAM, BlastMs(), Depth(), true, who, "Grapple-Slam!", false);
	}
	// tics > 0: his movement at full speed for that many real tics from now (kept to the latest end asked), his flight and
	// gravity put back at full time AT ONCE (MeRestore), so a velocity set right after this call is never rescaled; answers 1.
	// tics <= 0: asks only: 1 when his movement runs at full speed this tic, 0 while Slow Me Too (or a dive) slows it.
	int G2Free(int n, int tics)
	{
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n] || !players[n].mo) return 0;
		if (tics <= 0) return (meK[n] <= 0 || meK[n] >= 0.9999) ? 1 : 0;
		g2FreeUntil[n] = max(g2FreeUntil[n], level.maptime + min(tics, G2_CAP_TICS));
		MeRestore(n);
		meVx[n] = players[n].mo.vel.x; meVy[n] = players[n].mo.vel.y;
		return 1;
	}

	// RS_SlowMo's pulse, same arguments and the same rules: hold `ms`, at `depth` of
	// full speed; the ramps are this mod's; deeper wins and longer wins; the held
	// toggle outranks it; both clamped so no caller can freeze the world for good.
	// THE HOLD'S CAP IS 30 s, NOT 5. Ermac's cigarette (RSQ_TacticalRig rsqtr_cig_secs) asks for 15 s by
	// default (6 until 11-11) and up to 30 from its menu; a 5 s cap cut every one of those short (measured on the rig,
	// bugfix pass 10-31: rsm_pulse 6000 25 held 175 tics, not 210).
	const PULSE_MAX_MS = 30000;
	// stack: this pulse's time is ADDED after the running pulse's end (the cigarette and the world's slow motion,
	// owner 11-11: "it adds to any existing slomo or any worldslomo is added to it"); otherwise longer wins.
	private void Pulse(int ms, double depth, bool stack = false)
	{
		if (StoodDown() || on) return;
		int base = (stack && pulseUntil > level.maptime) ? pulseUntil : level.maptime;
		int holdUntil = base + int(ceil(clamp(ms, 30, PULSE_MAX_MS) * TICRATE / 1000.0));
		depth = clamp(depth, 0.05, 1.0);
		if (pulseUntil > 0)
		{
			pulseUntil = max(pulseUntil, holdUntil);
			pulseDepth = min(pulseDepth, depth);
		}
		else
		{
			pulseUntil = holdUntil;
			pulseDepth = depth;
		}
	}

	// SM7 (owner's QoL option, rsqsm_gesture_burst): the wrist cross asks for a 4 s pulse at the set depth
	// instead of the held toggle. It is the pulse above (eased by the ramps, a held toggle outranks it); with
	// the adrenaline meter on it needs the same minimum as the toggle and spends 4 s of the meter.
	const BURST_MS = 4000;
	private void Burst(int who)
	{
		if (StoodDown() || on) return;
		bool adrOn = Cv("rsqsm_adrenaline", 0) != 0;
		Actor mo = (who >= 0 && who < MAXPLAYERS && playeringame[who]) ? players[who].mo : null;
		if (!CatOn(CAT_BURST, who)) { Log("wristcross.burst", "refused: its switch is off (Burst)"); return; }
		int ms = BurstMs(who);
		if (adrOn && adr < Cv("rsqsm_adr_min", 25))
		{
			if (mo) { RSQSM_Buzz.Start(mo, 0, 0.25, 3); mo.A_StartSound("*usefail", CHAN_AUTO, CHANF_LOCAL, 0.6); }
			Log("wristcross.burst", "refused: not enough adrenaline");
			return;
		}
		if (adrOn) adr = max(0.0, adr - 100.0 * (ms / 1000.0) / AdrSecs() * CostK());
		Trigger("wristcross.burst", CAT_BURST, ms, Depth(), false, who);
		if (mo)
		{
			mo.A_StartSound("rsqsm/in", CHAN_AUTO, 0, 0.8);
			RSQSM_Buzz.Start(mo, 0, 0.6, 8);
			RSQSM_Buzz.Start(mo, 1, 0.6, 8);
		}
	}

	// ---- THE COUNTDOWN (owner 2026-11-03 19:06: "this would help the player understand when they will be back in real
	// time"; 11-05 03:55: "use our new slowdown timer bar for all slowmo, when player triggers it, it starts full, and drains
	// for however long the player has set it to") -----------------------------------------------------------------------
	// EVERY slow motion, his own and every mod's. `refill` (he holds it on, a shootdodge leaps) makes a running bar full again
	// at the new time left on the next tic; CountdownTick refills it whenever the projected end moves later (a new or longer
	// pulse, adrenaline earned while held).
	private void CountdownStart(String src, bool refill = false)
	{
		if (cdOn)
		{
			if (refill) { cdTotal = 0; cdEndAt = 0; cdRefillTic = level.maptime; }
			return;
		}
		cdOn = true;
		cdStartTic = level.maptime;
		cdEndAt = 0;
		cdTotal = 0;
		Log(src, "countdown bar: slow motion, counting down to real time");
	}
	private void SetCdAuto(bool a)
	{
		if (a && !cdAuto) cdAutoTic = level.maptime;
		cdAuto = a;
	}
	private void CountdownEnd(String why)
	{
		if (!cdOn) return;
		cdOn = false;
		cdLeft = 0;
		cdEndTic = level.maptime;
		Log("countdown", String.Format("countdown bar: gone (%s)", why));
	}
	// THE TIME LEFT, in REAL tics (level.maptime and TICRATE are never slowed; a pulse's ms and every setting below are real
	// seconds): what is left of the hold, then the ease back out from the depth the clock will be at when the hold ends (the
	// ease covers the whole way 0..1 in RampOut seconds, so from scale s it takes (1 - s) of it). Both fall by one a tic, so
	// the bar empties evenly into the ease and reaches zero as the world reaches full speed.
	//   a pulse (every mod, the burst, the named door)   its own ms (the burst: BurstMs, 4 s, Gun Bonsai VR's Longer 5/6/8 s)
	//   the miniboss window                              it re-asks each second: its hold is the window's end
	//   held on / a shootdodge in the air, Adrenaline on  the time the meter has left (adr x Full Meter (s), Longer, Cheaper):
	//                                                    it drains with the meter; adrenaline earned meanwhile refills it
	//   held on, Adrenaline off                          Slow Motion Length (rsqsm_length, real seconds, default 6)
	//   a shootdodge alone, Adrenaline off               no set end (it ends on landing): the bar sits full until he lands
	private void CountdownTick()
	{
		if (!cdOn) return;
		double rampOut = RampOut() * TICRATE;
		bool dodge = DodgeOn();
		bool holding = on || dodge;
		int holdEnd = pulseUntil;
		if (pulseUntil > 0 && pulseSrc == "miniboss") holdEnd = max(holdEnd, level.maptime + MinibossWindow());
		double hl = max(0, holdEnd - level.maptime);
		bool adrOn = Cv("rsqsm_adrenaline", 0) != 0;
		if (holding && adrOn) hl = max(hl, adr * AdrSecs() * TICRATE / (100.0 * max(CostK(), 0.05)));
		bool timed = on && !adrOn && heldUntil > 0;     // held on, Adrenaline off: Slow Motion Length
		if (timed) hl = max(hl, heldUntil - level.maptime);
		bool endless = holding && !adrOn && !timed;
		if (hl > 0 || endless)
		{
			// the depth when the hold ends: the deepest asked for, unless the ease in cannot reach it by then
			double d = 1.0;
			if (on) d = Depth();
			if (holdEnd > level.maptime) d = min(d, pulseDepth);
			if (dodge) d = min(d, DodgeDepth());
			double rin = RampIn() * TICRATE;
			double atEnd = (rin > 0.001 && !endless) ? max(d, scale - hl / rin) : d;
			atEnd = min(atEnd, max(scale, d));
			cdLeft = hl + (1.0 - atEnd) * rampOut;
		}
		else
		{
			cdLeft = (1.0 - scale) * rampOut;
			if (scale >= 0.9999 || cdLeft <= 0.0) { CountdownEnd("real time"); return; }
		}
		double endAt = level.maptime + hl;
		// a fresh start or refill (cdTotal 0), an endless hold (always full), or a hold that now ends later (by more than the
		// tic a ms-to-tic rounding can move it) fills the bar to the time left
		if (cdTotal <= 0 || endless) cdTotal = max(cdLeft, 1.0);
		else if (hl > 0 && cdEndAt > 0 && endAt > cdEndAt + 1.0)
		{
			cdTotal = max(cdLeft, 1.0);
			cdRefillTic = level.maptime;
			Log(pulseSrc, String.Format("countdown bar: refilled, %.1f s to real time", cdLeft / TICRATE));
		}
		cdTotal = max(cdTotal, cdLeft);
		cdEndAt = hl > 0 ? endAt : 0;
		if (Cv("rsqsm_debug", 0) >= 2) Console.Printf("RSQ_SlowMo: countdown t%d left %.1f of %.1f tics (scale %.2f)", level.maptime, cdLeft, cdTotal, scale);
	}

	// ---- SHOOTDODGE AND "SLOW ME TOO" (owner 2026-11-03: "it should work like this" -- Xortts' Bullet Time X) --------
	// Bullet Time X's dodge: a key forces a jump, time slows while you are off the floor and comes back when you land;
	// and the player's OWN movement is divided along with the world's. Here: netevent rsqsm_dodge (KEYCONF "Shootdodge")
	// -> Dodges(), in WorldTick after the engine's player think of that tic (so the no-momentum VR move, which zeroes a
	// grounded player's velocity every tic, cannot eat the leap on the tic it is made): the engine's own jump (CheckJump,
	// its sound) plus a thrust the way the stick points (rsqsm_dodge_leap; forward with the stick centred) -> the clock
	// heads for rsqsm_dodge_depth until he is on the ground again (player.onground), dead, out of adrenaline, or 6 s pass.
	// Your own movement is slowed through a dodge whatever Slow Me Too says (that is the dive), by rsqsm_dodge_me of the
	// world's slowing: at the world's full 10% a jump would hang ten times as long (measured headless 11-03: 5.2 s in
	// the air), so the default is half (k = 0.1 ^ 0.5 = 0.32: a dive of about 1.7 s, Max Payne's).
	// YOUR OWN MOVEMENT (rsqsm_me "Slow Me Too", rsqsm_me_ratio): the engine's MovePlayer resets the pawn's Speed every
	// tic and, without vr_momentum, zeroes his velocity on the ground and thrusts the whole step anew, so nothing set on
	// the pawn survives it. SlowMe instead scales what that tic PRODUCED, in WorldTick, before the pawn moves:
	//   on the ground without momentum   the step the engine just thrust is scaled by k;
	//   with momentum, or in the air     the thrust it just added is scaled; what he already carried (last tic's
	//                                    velocity, less the floor's friction) is rescaled only when k changes;
	//   vertically                       his velocity by k and his gravity by k squared, a slowed trajectory (the rule
	//                                    the clock applies to everything else); a jump the engine or the dodge just
	//                                    added is converted on the tic it happens.
	// k = the clock's factor ^ rsqsm_me_ratio (1: as slow as the world; 0.5: half as slowed; 0: not at all). Head and
	// hands are tracked and never slowed. Everything is put back when the clock is at full speed (MeRestore).
	const DODGE_MAX_TICS = 6 * TICRATE;
	const BURST_TICS = 8;
	double dodgeBurst[MAXPLAYERS];
	double DodgeDepth() { return clamp(Cv("rsqsm_dodge_depth", 0.10), 0.05, 0.95); }
	bool DodgeOn() { for (int n = 0; n < MAXPLAYERS; n++) if (dodgeTic[n] > 0) return true; return false; }
	private void Dodges()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			bool pend = dodgePend[n];
			dodgePend[n] = false;
			if (!playeringame[n] || !players[n].mo) { dodgeTic[n] = 0; continue; }
			let p = players[n];
			let pmo = p.mo;
			if (dodgeTic[n] > 0)
			{
				int age = level.maptime - dodgeTic[n];
				if (pmo.health <= 0 || age >= DODGE_MAX_TICS || (age >= 2 && p.onground))
				{
					Log("shootdodge", pmo.health <= 0 ? "ended: dead" : age >= DODGE_MAX_TICS ? "ended: 6 s" : "landed");
					dodgeTic[n] = 0;
				}
				// the start's burst bleeds off over BURST_TICS, leaving the leap's own speed for the rest of the arc
				else if (age >= 1 && age <= BURST_TICS && dodgeBurst[n] > 0)
				{
					double sp = pmo.vel.xy.Length();
					if (sp > 0.5) pmo.vel.xy -= pmo.vel.xy / sp * min(sp, dodgeBurst[n] / BURST_TICS);
				}
				continue;
			}
			if (!pend) continue;
			if (StoodDown()) { Log("shootdodge", "refused: stood down (another slow-motion mod)"); continue; }
			if (!CatOn(CAT_DODGE, n)) { Log("shootdodge", "refused: its switch is off (Shootdodge)"); continue; }
			if (pmo.health <= 0 || !p.onground || p.crouchfactor < 0.75 || pmo.waterlevel >= 2 || !level.IsJumpingAllowed())
			{
				Log("shootdodge", "refused: not standing on the ground (or no jumping here)");
				continue;
			}
			if (Cv("rsqsm_adrenaline", 0) != 0 && adr < Cv("rsqsm_adr_min", 25))
			{
				RSQSM_Buzz.Start(pmo, 0, 0.25, 3);
				pmo.A_StartSound("*usefail", CHAN_AUTO, CHANF_LOCAL, 0.6);
				Log("shootdodge", "refused: not enough adrenaline");
				continue;
			}
			// THE LEAP: the engine's own jump, then a thrust the way the stick points (forward if it is centred)
			p.cmd.buttons |= BT_JUMP;
			p.jumpTics = 0;
			pmo.CheckJump();
			double a = pmo.angle;
			Vector2 fwd = (cos(a), sin(a)), right = (sin(a), -cos(a));
			Vector2 st = (p.cmd.forwardmove, p.cmd.sidemove);
			Vector2 dir = st.Length() > 1 ? (fwd * st.x + right * st.y).Unit() : fwd;
			// MAX PAYNE, NOT MAX LAME (owner 11-12 14:11: "our crisis dive needs to be longer, and more of an arc over
			// distance with more oomph at the start"): a faster leap (16 units a tic, was 12), LIFT on top of the jump for a
			// higher, longer arc (Dive Lift, rsqsm_dodge_lift, 3: about 22 tics in the air where the jump alone gave 16),
			// and a BURST at the start that bleeds off over BURST_TICS (Dive Burst, rsqsm_dodge_burst, 8). About 10 m where
			// it was 5.5. Code only: loads, not run on the rig, not headset-confirmed.
			double leap = clamp(Cv("rsqsm_dodge_leap", 16), 0.0, 40.0);
			double burst = clamp(Cv("rsqsm_dodge_burst", 8), 0.0, 30.0);
			pmo.vel.xy += dir * (leap + burst);
			pmo.vel.z += clamp(Cv("rsqsm_dodge_lift", 3), 0.0, 12.0);
			dodgeBurst[n] = burst;
			dodgeTic[n] = level.maptime;
			CountdownStart("shootdodge", true);
			SetCdAuto(false);
			cdCause = CauseWord("shootdodge");
			pmo.A_StartSound("rsqsm/in", CHAN_AUTO, 0, 0.8);
			RSQSM_Buzz.Start(pmo, 0, 0.6, 8);
			RSQSM_Buzz.Start(pmo, 1, 0.6, 8);
			Log("shootdodge", String.Format("leap %.0f units a tic the way the stick points, world to %d%%", leap, int(DodgeDepth() * 100 + 0.5)));
		}
	}
	private void SlowMe()
	{
		bool momentum = true;
		let mc = CVar.FindCVar("vr_momentum");
		if (mc) momentum = mc.GetInt() != 0;
		double ratio = clamp(Cv("rsqsm_me_ratio", 1.0), 0.0, 1.0);
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) { meK[n] = 1; continue; }
			let p = players[n];
			let pmo = p.mo;
			double k = 1.0;
			if (scale < 0.9999 && !StoodDown())
			{
				if (dodgeTic[n] > 0) { double dr = clamp(Cv("rsqsm_dodge_me", 0.5), 0.0, 1.0); if (dr > 0) k = scale ** dr; }
				else if (CvWho("rsqsm_me", n, 1) != 0 && ratio > 0) k = scale ** ratio;
			}
			if (level.maptime < freeUntil[n]) k = 1.0;   // smoking: full speed (Tactical Rig asked, above)
			if (level.maptime < g2FreeUntil[n]) k = 1.0; // Grapple 2.0's fling (RSQSM_Service "g2.fullspeed", G2Free below)
			let dn = RSQSM_Down.Get();
			// DOWN: never slowed by the clock (the crawl is its own, down.zs Crawl), EXCEPT the fall itself (owner 11-09 17:44:
			// going down is a slow-mo moment): his own speed eases from a fifth back to full over the drop (down.zs DropK)
			if (dn && dn.IsDown(n)) k = dn.DropK(n);
			double was = (meK[n] <= 0 || meK[n] > 1) ? 1.0 : meK[n];
			if (k >= 0.9999)
			{
				if (was < 0.9999) MeRestore(n);
				meVx[n] = pmo.vel.x; meVy[n] = pmo.vel.y;
				continue;
			}
			if (was >= 0.9999) meGrav[n] = pmo.Gravity;   // the first slowed tic: remember his gravity
			// HORIZONTAL
			bool fresh = !momentum && p.onground && !p.keepmomentum;
			if (fresh) pmo.vel.xy *= k;
			else
			{
				double fric, mf;
				[fric, mf] = pmo.GetFriction();
				Vector2 kept = (meVx[n], meVy[n]) * (p.onground ? fric : 1.0) * (k / was);
				Vector2 thrust = pmo.vel.xy - (meVx[n], meVy[n]) * (p.onground ? fric : 1.0);
				pmo.vel.xy = kept + thrust * k;
			}
			// VERTICAL: a jump made this tic (CheckJump leaves jumpTics at -1) is converted whole; else what is in
			// flight is rescaled when the factor moves
			if (p.jumpTics == -1) pmo.vel.z *= k;
			else if (abs(k - was) > 0.0001) pmo.vel.z *= k / was;
			pmo.Gravity = meGrav[n] * k * k;
			meK[n] = k;
			meVx[n] = pmo.vel.x; meVy[n] = pmo.vel.y;
		}
	}
	// his gravity back, his flight at full time
	private void MeRestore(int n)
	{
		if (n < 0 || n >= MAXPLAYERS) return;
		double was = (meK[n] <= 0 || meK[n] > 1) ? 1.0 : meK[n];
		if (was < 0.9999 && playeringame[n] && players[n].mo)
		{
			let pmo = players[n].mo;
			if (meGrav[n] > 0) pmo.Gravity = meGrav[n];
			pmo.vel.z /= was;
			if (!players[n].onground) pmo.vel.xy /= was;   // (a grounded player's step is the engine's again next tic)
		}
		meK[n] = 1;
	}

	// ---- SM2 close calls (owner's QoL option, rsqsm_closecall; automatic) ------------------------
	// A rocket or fireball about to hit a player up close sets off a short pulse, so he can step aside.
	// "About to hit": its path relative to him (its velocity minus his) passes within his radius + its
	// radius + 8 units of his body's axis, between his feet and head, within CC_TICS tics, and it is
	// within CC_RANGE now. A rocket or fireball, not a bullet: a missile not fired by a player whose
	// full-speed Speed is under 40 (Brutal Doom's MonsterTracer bullets fly at 50, its imp fireball
	// FireBall_ at 16 and the rocket at 20: parsed from brutal22test6 Tracers.dec, Imps.dec,
	// Explosives.dec); this mod's own rounds never count. Each missile sets it off once.
	// THE WATCH LIST IS FED BY THE SPAWN EVENT, not a blockmap search: a projectile is +NOBLOCKMAP (the
	// Projectile flag set), so BlockThingsIterator never finds one (measured on the rig: an imp fireball
	// flown straight at the pawn set nothing off through it).
	const CC_TICS = 14;
	const CC_RANGE = 400;
	private Array<Actor> ccWatch;
	void WatchCloseCall(Actor m)
	{
		if (!m || !m.bMISSILE || m is "RSQSM_Round" || Cv("rsqsm_closecall", 0) == 0) return;
		if (GetDefaultByType(m.GetClass()).Speed >= 40) return;
		ccWatch.Push(m);
	}
	private void CloseCalls()
	{
		if (ccWatch.Size() == 0) return;
		bool want = !on && Cv("rsqsm_closecall", 0) != 0;
		for (int i = ccWatch.Size() - 1; i >= 0; i--)
		{
			Actor m = ccWatch[i];
			if (!want || !m || m.bDestroyed || !m.bMISSILE || m.InStateSequence(m.CurState, m.FindState("Death"))) { ccWatch.Delete(i); continue; }
			if (m.target && m.target.player) continue;
			for (int p = 0; p < MAXPLAYERS; p++)
			{
				if (!playeringame[p] || !players[p].mo || players[p].mo.health <= 0) continue;
				let mo = players[p].mo;
				if (m == mo) continue;
				Vector3 d = level.Vec3Diff(m.pos, mo.pos);       // from the missile to his feet
				Vector3 v = m.vel - mo.vel;
				double vv = v.xy dot v.xy;
				if (vv < 0.01 || d.xy.Length() > CC_RANGE) continue;
				double t = (d.xy dot v.xy) / vv;                  // tics to its closest pass, flat
				if (t < 0 || t > CC_TICS) continue;
				double miss = (d.xy - v.xy * t).Length();
				double z = m.pos.z + v.z * t - mo.pos.z;           // its height over his feet then
				if (miss > mo.radius + m.radius + 8 || z < -m.height || z > mo.height + 8) continue;
				ccWatch.Delete(i);
				int ms = int(clamp(Cv("rsqsm_closecall_ms", 700), 100, 5000));
				Trigger("closecall", CAT_CLOSECALL, ms, Depth(), true, p);
				Dev(String.Format("RSQ_SlowMo: close call at tic %d, %s %.1f tics from player %d (passes %.0f units off)",
					level.maptime, m.GetClassName(), t, p, miss));
				break;
			}
		}
	}

	static void Dev(String s)
	{
		let dv = CVar.FindCVar("developer");
		if (dv && dv.GetInt() >= 1) Console.Printf("%s", s);
	}
	// ---- every tic ---------------------------------------------------------------------
	override void WorldTick()
	{
		GbRefresh();
		curDepth = Depth();
		LocalGesture();
		if (StoodDown()) return;
		HeavyHits();             // last tic's hits, against the snapshots taken at the end of last tic's WorldTick
		ResolvePulses();
		CloseCalls();

		// SLOW MOTION LENGTH: with Adrenaline off, the held slow motion lets go by itself when its time is up
		if (on && heldUntil > 0 && Cv("rsqsm_adrenaline", 0) == 0 && level.maptime >= heldUntil) Aim(false, heldWho, "length");
		// THE MINIBOSS WINDOW ENDS WHEN IT ENDS (owner 11-10: the bar must be honest): its pulse never outlasts what RSQ
		// Miniboss says is left, so a segment broken early ends the slow (and the countdown bar) with the window
		if (pulseUntil > level.maptime && pulseSrc == "miniboss") pulseUntil = min(pulseUntil, level.maptime + MinibossWindow());
		// THE SMOKE KEEPS ITS TIME (owner 11-11): only death and DOWN end it
		SmokeKeep();
		// Where the clock is heading: the toggle, then a pulse, then full speed.
		if (on) target = Depth();
		else if (pulseUntil > 0)
		{
			if (level.maptime < pulseUntil) target = pulseDepth;
			else { pulseUntil = 0; target = 1; }
		}
		else target = 1;
		// a shootdodge in flight pulls the clock to its own depth, under whatever else asks
		Dodges();
		if (DodgeOn()) target = min(target, DodgeDepth());
		// DOWN (down.zs, owner 11-06): while any player is DOWN the world goes to the deepest speed, under whatever else asks
		let dn = RSQSM_Down.Get();
		if (dn && dn.AnyOn()) target = min(target, RSQSM_Down.DEPTH);

		// Ease, never snap: each ramp is the time to cross the whole way.
		if (scale != target)
		{
			double secs = (target < scale) ? RampIn() : RampOut();
			if (secs <= 0.001) scale = target;
			else
			{
				double step = 1.0 / (secs * TICRATE);
				if (abs(target - scale) <= step) scale = target;
				else scale += (target > scale) ? step : -step;
			}
		}

		Adrenaline();
		Reloads();
		Blasts();
		BarrelCues();
		SlowMe();
		CountdownTick();
		HeavySnap();             // his vertical speed and armour now, for the next tic's hits

		bool running = Active();
		if (!running && act.Size() == 0) return;
		Refresh();
		if (running && (act.Size() == 0 || level.maptime % 17 == 0)) Gather();
		Process();
		// the walkers' steps are spread by a thinker that runs after the actors (smooth.zs)
		if (running && Cv("rsqsm_smooth", 1) != 0) smooth = RSQSM_Smooth.Ensure(smooth);
		if (!running) ClearAll();     // back at full speed and every actor restored
	}

	// ---- who is slowed ---------------------------------------------------------------------
	private void Refresh()
	{
		if (cvTic == level.maptime) return;
		cvTic = level.maptime;
		double r = Cv("rsqsm_radius", 3000);
		cvRadius2 = r * r;
		cvDepth = Depth();
		cvRoundBase = max(1.0, Cv("rsqsm_round_speed", 14)) / cvDepth;
		cvSlowOwn = Cv("rsqsm_slow_own", 1) != 0;
	}

	private transient Map<Name, int> byClass;   // 1 real time by name, 2 not (0 unknown)

	bool RealTime(Actor a)
	{
		if (!a || a.player) return true;
		if (a is "Inventory" && Inventory(a).Owner) return true;
		if (a.bDORMANT) return true;
		// The series' own actors run in real time, decided by class name ONCE per class (the
		// runtime audit, 10-27: the string work per actor per gather cost 0.6 ms/tic on BD gore maps).
		Name cn = a.GetClassName();
		int known = byClass.GetIfExists(cn);
		if (known == 0)
		{
			String n = a.GetClassName();
			n = n.MakeLower();
			bool rt = n.Left(11) != "rsqsm_round" && (n.Left(3) == "rsq" || n.Left(4) == "ubqs" || n.Left(3) == "ssq");
			known = rt ? 1 : 2;
			byClass.Insert(cn, known);
		}
		if (known == 1) return true;
		// Your own missiles, when that is switched off -- and ALWAYS while you are DOWN (v3, owner 11-07: "your own shots fly at
		// normal speed", SlowMo's own-rockets-slow forced off for the downed player). Every player projectile whose shooter
		// (target) is the downed player: rockets, plasma, and Brutal Doom's own bullet tracers (its DecorativeTracer beside the
		// rifle's hitscan; a hitscan is instant anyway).
		if (a.bMISSILE && a.target && a.target.player)
		{
			if (!cvSlowOwn) return true;
			let dn = RSQSM_Down.Get();
			int sn = a.target.PlayerNumber();
			if (dn && dn.IsDown(sn)) return true;
			// WHILE SMOKING (owner 2026-11-09 21:52: "all shots full speed while smoking"): the smoker's shots fly at full
			// speed for as long as he does (freeUntil, Move at Full Speed While Smoking)
			if (sn >= 0 && sn < MAXPLAYERS && level.maptime < freeUntil[sn]) return true;
		}
		return false;
	}

	bool NearAPlayer(Actor a)
	{
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p] || !players[p].mo) continue;
			Vector3 d = level.Vec3Diff(players[p].mo.pos, a.pos);
			if (d dot d <= cvRadius2) return true;
		}
		return false;
	}

	// SPAWNED: WorldThingSpawned comes from PostBeginPlay, just before the thing's first
	// tic -- after whoever spawned it has set its velocity (dthinker.cpp, p_mobj.cpp). So
	// its velocity, Speed and gravity are final and are all scaled now, before it ever
	// moves at full speed. A round arrives already slowed (it sets preFactor).
	// known: the caller has already made sure it is not listed (Gather), so the list is not searched
	void Consider(Actor a, bool spawned, bool known = false)
	{
		if (RealTime(a)) return;
		if (act.Size() >= MAXSCAN) return;
		// Once only: a thing spawned before this tic's scan is found by the scan AND by the spawn
		// hook. Twice listed, each copy took the other's stretch for a new state, so its tics grew
		// 16x a tic until it froze, and its pushes were scaled twice.
		if (!known && act.Find(a) < act.Size()) return;
		int i = act.Size();
		double f = spawned ? FactorFor(a, a.Speed) : 1.0;
		double pre = 1.0;
		let rnd = RSQSM_Round(a);
		if (rnd && rnd.preFactor > 0) { pre = rnd.preFactor; f = pre; }
		act.Push(a);
		fac.Push(f);
		baseGrav.Push(a.Gravity);
		baseSpeed.Push(rnd && rnd.preFactor > 0 ? rnd.baseSpeed : a.Speed);
		carry.Push(0);
		lastState.Push(spawned ? null : a.CurState);   // a new thing's first state is stretched at the first look
		lastTics.Push(a.tics);
		if (spawned && f < 0.9999 && pre == 1.0)
		{
			a.vel *= f;
			if (a.bMISSILE) a.Speed = baseSpeed[i] * f;
			a.Gravity = baseGrav[i] * f * f;
		}
		lvx.Push(a.vel.x); lvy.Push(a.vel.y); lvz.Push(a.vel.z);
	}

	// Things already in the world near a player (the first look, then every 17 tics for
	// what has come into range). Missiles spawned while it runs arrive through
	// WorldThingSpawned.
	//
	// IS IT LISTED ALREADY, WITHOUT SEARCHING THE LIST FOR EVERY ACTOR (that was n^2/2 compares: the
	// first look searched a growing list for each of up to 4000 actors, every later look searched
	// the whole list for each). The list is built in the order the iterator walks the level -- the
	// first look in that order, spawns in the order they first tick, which is the order the engine
	// appends them to its thinker list -- and Drop keeps the order. So the walk below steps through
	// `act` alongside the iterator: the next listed entry IS the actor, one compare. Only an actor
	// out of step (one that came into range at a later look, or that changed thinker list) is
	// searched for, and the walk jumps ahead to where it was found. The answer is always exact --
	// "listed" only on a match, "not listed" only after a full search -- only the cost depends on
	// the order. On the first look nothing can be listed (each actor is walked once), so nothing is
	// searched at all. (A Map lookup was measured too: ZScript maps take only int or String keys
	// and an Actor has no number, so the key had to be its address formatted as text, and that cost
	// as much as the search it replaced: 1.6 ms against 1.5 at 3543 actors.)
	private void Gather()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		bool first = act.Size() == 0;
		int j = 0, n = act.Size();
		while ((a = Actor(it.Next())) && act.Size() < MAXSCAN)
		{
			if (!NearAPlayer(a) || RealTime(a)) continue;     // the cheap distance test first
			if (!first)
			{
				while (j < n && !act[j]) j++;                 // gone, dropped next Process
				if (j < n && act[j] == a) { j++; continue; }
				int k = act.Find(a);
				if (k < act.Size()) { if (k >= j && k < n) j = k + 1; continue; }
			}
			Consider(a, false, true);
		}
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (e.Thing && e.Thing.bMISSILE && !StoodDown()) WatchCloseCall(e.Thing);
		if (e.Thing && !StoodDown()) WatchBlast(e.Thing);
		if (Active() && !StoodDown() && e.Thing) { Refresh(); Consider(e.Thing, true); }
	}

	// The factor an actor wants: the clock near a player, full speed out of range.
	// A fast, small missile (a bullet fired as a projectile, Brutal Doom's way) is
	// slowed further, to the round speed, so it can be seen and dodged too.
	double FactorFor(Actor a, double base)
	{
		double s = scale;
		if (s >= 0.9999) return 1.0;
		Refresh();
		if (!NearAPlayer(a)) return 1.0;
		// ENEMY bullets only. Your own (Brutal Doom's rifle fires a DecorativeTracer at 140 beside its
		// hitscan) slow with the world like your rockets: at the round speed they crawled at a tenth of
		// full speed, long after the shot they show had landed (measured on the rig, bugfix pass 10-31:
		// your tracer 14 units a tic at world speed 0.25, where 35 is the world's).
		if (a.bMISSILE && a.radius <= 8 && !(a is "RSQSM_Round") && !(a.target && a.target.player) && base > cvRoundBase * 1.05)
		{
			double k = clamp((1.0 - s) / max(1.0 - cvDepth, 0.01), 0.0, 1.0);
			return s * (1.0 - k * (1.0 - cvRoundBase / base));
		}
		return s;
	}

	// A dodgeable round's speed at full time, so that at the set depth it flies at
	// rsqsm_round_speed.
	double RoundBase() { Refresh(); return cvRoundBase; }

	private void Process()
	{
		double follow = clamp(CvLocal("rsm_sound_follow", 1.0), 0.0, 1.0);
		bool doPitch = (++pitchTick % 4) == 0;
		bool wakes = Cv("rsqsm_wakes", 1) != 0;
		for (int i = act.Size() - 1; i >= 0; i--)
		{
			Actor a = act[i];
			if (!a || a.bDestroyed)
			{
				Drop(i);
				continue;
			}
			double want = FactorFor(a, baseSpeed[i]);
			double f = fac[i];

			// A script that set its own gravity or speed since last tic (Brutal Doom's gibs
			// do, in their first state) is taken as the new base, not overwritten.
			if (abs(a.Gravity - baseGrav[i] * f * f) > 0.000001) baseGrav[i] = a.Gravity / (f * f);
			if (a.bMISSILE && abs(a.Speed - baseSpeed[i] * f) > 0.0001) baseSpeed[i] = a.Speed / f;
			if (f < 0.9999) Impulses(a, i, f);

			// A state entered since last tic lasts 1/f as long (at the factor it was entered
			// under; a change of factor is applied after, to what is left of it).
			if (f < 0.9999 && a.tics > 0 && !a.isFrozen())
			{
				// Counting down as usual is the same state one tic shorter. The same state
				// with the same count is a thing not ticking -- unless the count is 1,
				// which is a one-tic state looping onto itself.
				bool same = a.CurState == lastState[i];
				bool counting = same && a.tics == lastTics[i] - 1;
				bool stalled = same && a.tics == lastTics[i] && a.tics > 1;
				bool entered = !counting && !stalled;
				if (entered)
				{
					double t = a.tics / f + carry[i];
					int nt = max(1, int(t));
					carry[i] = t - nt;
					a.tics = nt;
				}
			}
			if (abs(want - f) > 0.0001)
			{
				double r = want / f;
				a.vel *= r;
				if (a.bMISSILE) a.Speed = baseSpeed[i] * want;
				// Gravity is written whatever NOGRAVITY says now: dying clears that flag
				// (a cacodemon's corpse falls), and a flag set later must not keep f^2.
				a.Gravity = baseGrav[i] * want * want;
				if (a.tics > 0)
				{
					double t = a.tics / r + carry[i];
					int nt = max(1, int(t));
					carry[i] = t - nt;
					a.tics = nt;
				}
				fac[i] = want;
			}

			lastState[i] = a.CurState;
			lastTics[i] = a.tics;

			if (want < 0.9999)
			{
				// Sliding on the ground loses speed at the slowed rate -- but only where the engine
				// took speed off it in the first place. P_XYMovement skips friction for MF_MISSILE,
				// MF_SKULLFLY and MF8_NOFRICTION (p_mobj.cpp:2442-2445), so a charging Lost Soul, a
				// mid-A_SkullAttack anything, and any +NOFRICTION mod actor were being compensated
				// for a friction they never paid, and bled speed in slow motion. A frozen thing paid
				// none either (p_mobj.cpp:3948-3952).
				if (a.pos.z <= a.floorz + 0.01 && !a.bNOGRAVITY && !a.bMISSILE && !a.bSKULLFLY
					&& !a.bNOFRICTION && !a.isFrozen() && (a.vel.x != 0 || a.vel.y != 0))
				{
					double fr, mf;
					[fr, mf] = a.GetFriction();
					if (fr > 0 && fr < 1) { double k = fr ** (want - 1.0); a.vel.x *= k; a.vel.y *= k; }
				}
				if (doPitch) Repitch(a, 1.0 - (1.0 - want) * follow);
				if (wakes && a.bMISSILE && (level.maptime + i) % 2 == 0) Wake(a);
			}
			else if (doPitch) Repitch(a, 1.0);

			if (want >= 0.9999 && (!Active() || !NearAPlayer(a))) { Drop(i); continue; }
			lvx[i] = a.vel.x; lvy[i] = a.vel.y; lvz[i] = a.vel.z;
		}
	}

	// A push given at full strength in slowed time (a thrust, a jump, a script that
	// sets a velocity, Brutal Doom's tracers kicking themselves sideways) is a change
	// of velocity, and velocities here are per tic: it is scaled by the factor too.
	// What the engine itself did since last tic is predicted and left alone: gravity
	// (already scaled), ground friction (compensated below), a missile re-aimed from
	// its own (scaled) Speed. Bouncers, things that hit a wall or a thing, and
	// landings are left alone too: a reflection or a stop is not a push.
	private void Impulses(Actor a, int i, double f)
	{
		// NOTHING IS PREDICTED FOR A FROZEN THING, because the engine did nothing to it:
		// AActor::Tick returns on freezetics (p_mobj.cpp:3948-3952) before gravity, friction,
		// the movement and the state machine. Predicting a tic of gravity for one anyway read
		// as a scripted push of the whole gravity step, so -(1-f) of it was written back as
		// velocity every tic it stayed frozen (0.75 units/tic at depth 0.25, past the 0.5 gate
		// below), invisible while frozen and a kick downward the moment it unfroze. isFrozen()
		// (actor.zs:513) short-circuits on freezetics (actorinlines.h:174-177), so this covers
		// every freeze route: another mod's time sphere, Level.SetFrozen, anything.
		if (a.isFrozen()) return;
		if (a.bBOUNCEONWALLS || a.bBOUNCEONFLOORS || a.bBOUNCEONCEILINGS || a.BlockingLine || a.BlockingMobj) return;
		Vector3 expect = (lvx[i], lvy[i], lvz[i]);
		bool onFloor = a.pos.z <= a.floorz + 0.01;
		if (!a.bNOGRAVITY && !onFloor) expect.z -= level.gravity * a.CurSector.gravity * a.Gravity * 0.00125;
		// Only where the engine applies friction at all: P_XYMovement skips it for MF_MISSILE,
		// MF_SKULLFLY and MF8_NOFRICTION alike (p_mobj.cpp:2442-2445).
		if (onFloor && !a.bNOGRAVITY && !a.bMISSILE && !a.bSKULLFLY && !a.bNOFRICTION)
		{
			double fr, mf;
			[fr, mf] = a.GetFriction();
			expect.x *= fr; expect.y *= fr;
		}
		Vector3 d = a.vel - expect;
		bool touching = onFloor || a.pos.z + a.height >= a.ceilingz - 0.01;
		// Pushed up off the floor (a bash, a pain leap) is a push, not a landing: slowed like any
		// other. Kept at full speed under f^2 gravity, a quarter-speed leap went 16x higher.
		if (onFloor && a.vel.z > 0.01) touching = false;
		if (touching) d.z = 0;          // a landing or a bump on the ceiling
		if (d.Length() <= 0.5) return;
		if (a.bMISSILE && abs(a.vel.Length() - a.Speed) <= a.Speed * 0.05 + 0.01) return;
		// A RETURN IS NOT A PUSH (owner 2026-11-03: "punching back a fireball"). A shot sent back -- Melee's punch and
		// swat, the saber's blade, the whip's crack, the shield -- is re-aimed by its returner from its SLOWED Speed or
		// velocity (Melee SendBack, the saber's BatBack: max(Speed, vel) x a multiplier), so it is already at the world's
		// pace; only the 5% rule above let a x1.0 return through, and a faster one (Hadouken x1.25+, the blade's x1.2,
		// Return Crack 2+) was read as a full-strength push and had its reversal scaled by f: at a quarter speed it
		// came out still flying AT the player at 44% of its pace. A missile whose velocity turned back on itself
		// (against what it carried) is a return: left as its returner set it.
		if (a.bMISSILE && expect.Length() > 0.01 && (a.vel dot expect) < 0) return;
		double vz = touching ? a.vel.z : expect.z + d.z * f;
		a.vel = (expect.x + d.x * f, expect.y + d.y * f, vz);
	}

	private void Drop(int i)
	{
		Actor a = act[i];
		// ITS SOUND GOES BACK TO FULL PITCH WITH IT. The pitch is retuned only every 4th tic (Process), so a
		// thing let go on any other tic -- the end of the ease-out, or walking out of range -- kept the last
		// lowered pitch on whatever it was still playing; a looping sound stayed low for good (bugfix pass
		// 10-31; read from the code, the rig cannot read a pitch back).
		if (a && !a.bDestroyed && a.IsActorPlayingSound(0)) Repitch(a, 1.0);
		if (a && !a.bDestroyed && fac[i] != 1.0)
		{
			double r = 1.0 / fac[i];
			a.vel *= r;
			if (a.bMISSILE) a.Speed = baseSpeed[i];
			a.Gravity = baseGrav[i];
			if (a.tics > 0) a.tics = max(1, int(a.tics / r));
		}
		act.Delete(i); fac.Delete(i); baseGrav.Delete(i); baseSpeed.Delete(i); carry.Delete(i);
		lastState.Delete(i); lastTics.Delete(i); lvx.Delete(i); lvy.Delete(i); lvz.Delete(i);
	}

	// FROM CHANNEL 0, NOT 1. CHAN_AUTO is channel 0 (base.zs:6) and a sound started on it
	// STAYS on 0: the engine sets CHANF_OVERLAP and lets them all overlap there rather than
	// hijacking another slot (s_sound.cpp:536-541). Starting at 1 left every explicit
	// CHAN_AUTO sound at full pitch while its actor slowed, and stock content uses CHAN_AUTO
	// constantly (actor.zs's land and grunt, shared/spark.zs) -- as does this mod.
	// The two calls read 0 differently and both are safe: A_SoundPitch(0) retunes channel 0
	// only (ChangeSoundPitch matches chan->EntChannel == channel, s_sound.cpp:1057-1068),
	// while IsActorPlayingSound(0) answers "playing anything, on any channel"
	// (IsSourcePlayingSomething: channel == 0 matches every channel, s_sound.cpp:1151-1164).
	// So at ch 0 the guard is a superset: it can never skip a channel-0 sound, and the most
	// it costs is one A_SoundPitch that finds nothing there.
	private static void Repitch(Actor a, double pitch)
	{
		pitch = clamp(pitch, 0.4, 1.0);
		for (int ch = 0; ch <= 7; ch++)
			if (a.IsActorPlayingSound(ch)) a.A_SoundPitch(ch, pitch);
	}

	// The bent air behind a slowed missile: a short, fading wake.
	private static void Wake(Actor a)
	{
		if (a.bINVISIBLE || a.vel.Length() < 0.5) return;
		FSpawnParticleParams p;
		p.color1 = "DDE6FF";
		p.style = STYLE_Add;
		p.flags = SPF_FULLBRIGHT;
		p.lifetime = 18;
		p.size = 3;
		p.sizestep = 0.25;
		p.pos = a.pos + (0, 0, a.height * 0.5);
		p.startalpha = 0.35;
		p.fadestep = -1;
		level.SpawnParticle(p);
	}

	// ---- the adrenaline meter (rsqsm_adrenaline) ----------------------------------------------
	// Earned from kills and from the rounds and hurts you take; spent while the held
	// slow motion runs. Off, slow motion is free.
	void AddAdrenaline(double n)
	{
		if (Cv("rsqsm_adrenaline", 0) == 0) return;
		double was = adr;
		adr = clamp(adr + n, 0.0, 100.0);
		if (was < 100 && adr >= 100)
			for (int p = 0; p < MAXPLAYERS; p++)
				if (playeringame[p] && players[p].mo) players[p].mo.A_StartSound("rsqsm/ready", CHAN_AUTO, 0, 0.7);
	}

	private void Adrenaline()
	{
		if (Cv("rsqsm_adrenaline", 0) == 0 || (!on && !DodgeOn())) return;
		adr -= 100.0 / (AdrSecs() * TICRATE) * CostK();	// LONGER and CHEAPER (Gun Bonsai VR)
		if (adr <= 0) { adr = 0; if (on) Aim(false, -1); for (int n = 0; n < MAXPLAYERS; n++) dodgeTic[n] = 0; }
	}

	// A KILL IS COUNTED WHERE THE DAMAGE NAMES ITS SOURCE. WorldThingDied only carries the inflictor,
	// and a hitscan's inflictor is its puff, which points at nobody unless the puff is PUFFGETSOWNER:
	// measured, a player's pistol kill earned no adrenaline. The killing blow's WorldThingDamaged has
	// the source itself; a death that never passes through damage (a script's A_Die) still counts
	// through WorldThingDied as before.
	private transient Actor lastKilled;
	override void WorldThingDied(WorldEvent e)
	{
		if (e.Thing && !StoodDown()) BarrelDeath(e);
		if (!e.Thing || !e.Thing.bISMONSTER || e.Thing == lastKilled) return;
		Actor src = e.Inflictor;
		if (src && !src.player) src = src.target;
		if (src && src.player) AddAdrenaline(Cv("rsqsm_adr_kill", 12));
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (e.Thing && e.Thing.player && e.Damage > 0) AddAdrenaline(e.Damage * 0.5);
		if (e.Thing && e.Thing.player && e.Damage > 0 && !StoodDown()) HeavyNote(e);
		if (e.Thing && e.Thing.bISMONSTER && e.Thing.health <= 0 && e.Thing != lastKilled)
		{
			Actor src = e.DamageSource;
			if (src && !src.player && src.FriendPlayer > 0) src = players[src.FriendPlayer - 1].mo;
			if (src && src.player) { lastKilled = e.Thing; AddAdrenaline(Cv("rsqsm_adr_kill", 12)); }
		}
	}

	// ---- a reload buys a moment (rsqsm_reload, each player's own choice) ----------------------
	// Two signs, either one: the weapon's Reload sequence starts playing, or ammo moves
	// from the reserve into the magazine on one tic (one count falls as the other
	// rises; a pickup only ever raises). The second catches Brutal Doom's reloads,
	// which reach their animation through their own tokens and jumps rather than by
	// playing on from "Reload" (measured: BD22 Rifle, magazine 20 -> 31, reserve 30 ->
	// 19, while the Reload sequence check saw nothing). An automatic trigger: its option, the
	// cooldown, and the World Speed slider's speed (Trigger).
	//
	// EACH HAND, AND HOW LONG (owner 2026-11-09 17:24: "slomo needs context options for player reloading, single weapon or
	// both, either say that reloading triggers a flat X tics of slomo, or, reload slomo is indefinite until reload is
	// complete (or both?)"; rig only, not headset-confirmed). Both hands are watched the same way: the main hand's weapon
	// (PSP_WEAPON) and the off hand's (PSP_OFFHANDWEAPON: Brutal Doom 22 VR Reloaded's dual wield, whose off gun reloads by
	// its flick into the gun's own Reload). A hand is RELOADING while its weapon plays its reload (Reload, BD22 VR Reloaded's RSR_Stock,
	// FinishReloading), waits for a hand reload (RSR_Wait: the off hand fetching a magazine; RSB_Wait: a break-open gun held
	// open) or plays its flick reload (RSQ_FlickReload); all found by state NAME on the weapon itself, nothing linked.
	//   Reload Hands (rsqsm_reload_hand): 0 Either Hand, 1 Main Hand Only, 2 Off Hand Only, 3 Both Hands at Once (the second
	//     hand starts while the first is still reloading).
	//   Reload Length (rsqsm_reload_len): 0 Fixed Time (Reload Time (ms), as before); 1 Until the Reload Ends; 2 Until It
	//     Ends, at Most the Fixed Time.
	// A RELOAD ENDS when the hand's weapon is ready to fire again (its own A_WeaponReady: the engine's ready flag for that
	// hand, which every state change clears) or back in its Ready sequence, and no longer reloading; or when that hand's
	// weapon changes (switched, put away, dropped, thrown), or the player dies; a new map starts at full speed. Until the
	// reload ends lasts while ANY hand that counts is still reloading (with Both Hands: until both are done). It can never
	// stay slowed: Until the Reload Ends asks for RELOAD_CAP_MS at most (a hand reload left waiting ends there), the other
	// for Reload Time. Ending early only cuts the reload's own part: another trigger's time that was running stays.
	const RELOAD_CAP_MS = 10000;
	private transient bool reloadBusy[MAXPLAYERS * 2];         // last tic: the hand was reloading (the start's edge)
	private transient int  lastA1[MAXPLAYERS * 2], lastA2[MAXPLAYERS * 2];
	private transient Weapon lastW[MAXPLAYERS * 2];
	// a hand's reload running now (synced: every machine works it out from the same play state)
	bool   rlActive[MAXPLAYERS * 2];
	Weapon rlW[MAXPLAYERS * 2];
	int    rlTic[MAXPLAYERS * 2];
	// the reload slow motion being tracked to its end (Until the Reload Ends / at most the fixed time)
	int    rsWho;          // the player, -1 none
	int    rsHands;        // hand mask that counts (1 main, 2 off)
	int    rsPrevUntil;    // pulseUntil before the reload's own was let in (another trigger's time, kept on a cut)
	int    rsPrevReady;    // autoReady likewise
	int    rsTic;          // maptime it was let in

	static clearscope String HandWord(int h) { return h == 0 ? "main" : "off"; }

	// the hand is reloading now, and how it shows (for the log)
	static bool, String HandReloading(PlayerInfo p, int h)
	{
		let w = h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
		let ps = p.GetPSprite(h == 0 ? PSP_WEAPON : PSP_OFFHANDWEAPON);
		if (!w || !ps || !ps.CurState || ps.Caller != w) return false, "";
		State cs = ps.CurState;
		// the reload's own animation: BD22's Reload; BD22 VR Reloaded moves it under RSR_Stock (measured on the rig 11-09: the
		// Rifle's stock reload plays from RSR_Stock, never seen from "Reload", and its magazine fills 25 tics in) and its
		// last part under FinishReloading (BD22's own label: the bolt, A_WeaponReady without fire); a full magazine's Inspect
		// is no reload
		// (FindState takes a label written out: a Name from an array does not convert)
		State st = w.FindState("Reload");
		if (st && Actor.InStateSequence(cs, st)) return true, "Reload";
		st = w.FindState("RSR_Stock");
		if (st && Actor.InStateSequence(cs, st)) return true, "RSR_Stock";
		st = w.FindState("FinishReloading");
		if (st && Actor.InStateSequence(cs, st)) return true, "FinishReloading";
		st = w.FindState("RSQ_FlickReload");
		if (st && Actor.InStateSequence(cs, st)) return true, "RSQ_FlickReload";
		State hw = w.FindState("RSR_Wait");
		if (hw && cs == hw) return true, "RSR_Wait";
		State bw = w.FindState("RSB_Wait");
		if (bw && cs == bw) return true, "RSB_Wait";
		return false, "";
	}
	// the hand's weapon is ready to fire again (its own A_WeaponReady this state) or back in its Ready sequence
	static bool HandReady(PlayerInfo p, int h)
	{
		let w = h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
		if (!w) return false;
		if (p.WeaponState & (h == 0 ? WF_WEAPONREADY : WF_OFFHANDREADY)) return true;
		let ps = p.GetPSprite(h == 0 ? PSP_WEAPON : PSP_OFFHANDWEAPON);
		State rd = w.FindState("Ready");
		return ps && ps.CurState && rd && Actor.InStateSequence(ps.CurState, rd);
	}

	private void Reloads()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n]) { for (int h = 0; h < 2; h++) rlActive[n * 2 + h] = false; continue; }
			let p = players[n];
			bool alive = p.mo && p.health > 0 && p.playerstate == PST_LIVE;
			bool wanted = alive && CvP("rsqsm_reload", p, 0) != 0;
			// RELOAD: ALWAYS, OR ONLY UNDER LOW HEALTH (owner 11-06, BUGS_1.0 #10): Reload When = Low Health asks his health
			// to be at or under Low Health At
			if (wanted && CvP("rsqsm_reload_when", p, 0) == 1 && !(p.mo && p.health > 0 && p.health <= LowAt())) wanted = false;
			int hm = int(CvP("rsqsm_reload_hand", p, 0));
			int counts = hm == 1 ? 1 : hm == 2 ? 2 : 3;
			int startMask = 0;
			for (int h = 0; h < 2; h++)
			{
				int k = n * 2 + h;
				let w = h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
				bool r; String how;
				[r, how] = HandReloading(p, h);
				bool moved = false;
				int a1 = (w && w.Ammo1) ? w.Ammo1.Amount : 0;
				int a2 = (w && w.Ammo2) ? w.Ammo2.Amount : 0;
				if (w && w == lastW[k] && w.Ammo1 && w.Ammo2 && w.Ammo1 != w.Ammo2)
					moved = (a2 > lastA2[k] && a1 < lastA1[k]) || (a1 > lastA1[k] && a2 < lastA2[k]);
				// AMMO MOVED counts as a start only while the gun is not in its Ready state (a hand reload's own animation): ammo
				// shuffled with the gun ready (an instant move, another mod's give / take) made a 1-tic "reload" whose slow
				// motion could eat the Auto Cooldown just before the real one (rig 2026-11-09)
				bool began = reloadPrimed && alive && ((r && !reloadBusy[k]) || (moved && !HandReady(p, h)));
				// the hand's reload, start to end (watched whatever the options: it is the slow motion's end)
				if (rlActive[k])
				{
					String why = "";
					if (!alive) why = "player dead";
					else if (w != rlW[k]) why = "weapon changed";
					else if (!r && HandReady(p, h)) why = "reload done";
					if (why != "")
					{
						rlActive[k] = false;
						Log("reload", String.Format("%s hand %s reload ends (%s) after %d tics", HandWord(h), rlW[k] ? rlW[k].GetClassName() : 'none', why, level.maptime - rlTic[k]));
					}
				}
				if (began && !rlActive[k])
				{
					rlActive[k] = true; rlW[k] = w; rlTic[k] = level.maptime;
					if (w) Log("reload", String.Format("%s hand %s reload starts (%s)", HandWord(h), w.GetClassName(), moved && !r ? "ammo moved" : how));
					if (counts & (1 << h)) startMask |= 1 << h;
				}
				reloadBusy[k] = r;
				lastW[k] = w; lastA1[k] = a1; lastA2[k] = a2;
			}
			int activeMask = (rlActive[n * 2] ? 1 : 0) | (rlActive[n * 2 + 1] ? 2 : 0);
			bool go = wanted && startMask != 0 && (hm != 3 || activeMask == 3);
			if (go)
			{
				int lm = int(CvP("rsqsm_reload_len", p, 0));
				int fixedMs = int(CvP("rsqsm_reload_ms", p, 1200));
				int ms = lm == 1 ? RELOAD_CAP_MS : fixedMs;
				int prevUntil = (pulseUntil > level.maptime) ? pulseUntil : 0;
				int prevReady = autoReady;
				if (Trigger("reload", CAT_RELOAD, ms, Depth(), true, n) && lm != 0)
				{
					if (rsWho != n || pulseSrc != "reload") { rsPrevUntil = prevUntil; rsPrevReady = prevReady; }
					rsWho = n; rsHands = hm == 3 ? 3 : counts; rsTic = level.maptime;
					Log("reload", String.Format("held until the reload ends (%s; %s), at most %d ms", lm == 1 ? "Until the Reload Ends" : "at most the fixed time",
						hm == 0 ? "either hand" : hm == 1 ? "main hand" : hm == 2 ? "off hand" : "both hands", ms));
				}
			}
		}
		reloadPrimed = true;     // the first tic after a load only looks
		ReloadEnd();
	}

	// the tracked reload slow motion: cut when no hand that counts is still reloading, or stop tracking when something else
	// took the pulse over (held on, another trigger let in after it) or it ran out (the cap or the fixed time)
	private void ReloadEnd()
	{
		if (rsWho < 0) return;
		int n = rsWho;
		if (on || pulseUntil <= level.maptime || !(pulseSrc ~== "reload"))
		{
			Log("reload", on ? "tracking stops: slow motion held on" : pulseUntil <= level.maptime ? String.Format("ends at its time limit after %d tics", level.maptime - rsTic) : "tracking stops: another trigger took the slow motion over");
			rsWho = -1;
			return;
		}
		bool still = false;
		for (int h = 0; h < 2; h++) if ((rsHands & (1 << h)) && rlActive[n * 2 + h]) still = true;
		if (still) return;
		int cut = max(level.maptime, rsPrevUntil);
		pulseUntil = cut;
		autoReady = max(rsPrevReady, cut + int(Cooldown() * TICRATE));
		Log("reload", String.Format("ends with the reload after %d tics (pulse now until t%d)", level.maptime - rsTic, cut));
		rsWho = -1;
	}

	// ---- BLASTS (owner 2026-11-06, BUGS_1.0 #10: "grenade blast, over-under rifle or machinegun secondary blast"; the Low
	// Health trigger added with them was removed the same day, owner's spec). Automatic triggers, each its own row, off by
	// default: the cooldown and the World Speed slider's speed (Trigger), the hold from Blast Time (3 s, owner 11-06). Found
	// BY NAME, nothing linked:
	//   GRENADE      Brutal Doom's hand grenade (HandGrenade, HandGrenadeAlt: BD22 VR Grenades.dec; its Explode state, not
	//                its Death, which is the grenade landing), RSQ Grenade's thrown one (RSQGN_Thrown: its Boom state) and
	//                the one that goes off in the hand (RSQGN_HandBlast: its spawn is the blast)
	//   OVER-UNDER   the 40 mm under BD22 VR's Rifle and Machinegun (Rifle.dec FireGrenade / RSM_AltGrenade, Machinegun.dec:
	//                A_FireCustomMissile("ShortGrenade")): its Death state, or its end
	// Only a player's own (its target, the shooter, is a player). A watched one that is simply gone counts as a blast.
	const BL_GRENADE = 1;
	const BL_OU = 2;
	private Array<Actor> blWatch;
	private Array<int> blKind;
	private Array<int> blOwner;   // the player whose it was when last seen alive (-1 none): a destroyed one's target is lost
	static int BlastKind(Actor a)
	{
		Name c = a.GetClassName();
		if (c == 'HandGrenade' || c == 'HandGrenadeAlt' || c == 'RSQGN_Thrown' || c == 'RSQGN_HandBlast') return BL_GRENADE;
		if (c == 'ShortGrenade') return BL_OU;
		return 0;
	}
	static int OwnerOf(Actor a) { return (a && !a.bDestroyed && a.target && a.target.player) ? a.target.PlayerNumber() : -1; }
	void WatchBlast(Actor a)
	{
		if (Cv("rsqsm_trig_grenade", 0) == 0 && Cv("rsqsm_trig_ou", 0) == 0) return;
		int k = BlastKind(a);
		if (k == 0) return;
		if (a.GetClassName() == 'RSQGN_HandBlast') { BlastAt(OwnerOf(a), k); return; }   // in the hand: its spawn is the blast
		blWatch.Push(a);
		blKind.Push(k);
		blOwner.Push(OwnerOf(a));
	}
	static bool InSeq(Actor a, State s) { return s && a.CurState && Actor.InStateSequence(a.CurState, s); }
	private void Blasts()
	{
		for (int i = blWatch.Size() - 1; i >= 0; i--)
		{
			Actor a = blWatch[i];
			bool boom;
			if (!a || a.bDestroyed) boom = true;
			else
			{
				int o = OwnerOf(a);
				if (o >= 0) blOwner[i] = o;
				if (a.FindState("Explode", true) || a.FindState("Boom", true)) boom = InSeq(a, a.FindState("Explode", true)) || InSeq(a, a.FindState("Boom", true));
				else boom = InSeq(a, a.FindState("Death", true)) || InSeq(a, a.FindState("XDeath", true));
			}
			if (!boom) continue;
			int k = blKind[i], who = blOwner[i];
			blWatch.Delete(i);
			blKind.Delete(i);
			blOwner.Delete(i);
			BlastAt(who, k);
		}
	}
	private void BlastAt(int who, int k)
	{
		String src = k == BL_GRENADE ? "grenade" : "overunder";
		if (who < 0 || who >= MAXPLAYERS || !playeringame[who]) { Log(src, "blast: not a player's, ignored"); return; }
		Trigger(src, k == BL_GRENADE ? CAT_GRENADE : CAT_OU, BlastMs(), Depth(), true, who);
	}
	int BlastMs() { return int(clamp(Cv("rsqsm_blast_ms", 3000), 100, 5000)); }
	// ---- BARREL CUES (owner 2026-11-07 11:25-11:27, design/SLOWMO_BARRELS.md, approved): four automatic triggers, each its
	// own row, all ON by default, each with its own cause line; the cooldown, the World Speed slider's speed and the hold
	// from Blast Time (Trigger), like the grenade's blast.
	//   1 LOCKED BARREL      a locked barrel throw or uppercut barrel lands on its locked monster and goes off (RSQ
	//                        Distance Grab's Barrel Lock-On, asked by name: LockedBarrel below)
	//   2 BARREL MULTI-KILL  one barrel's blast kills 2 or more monsters (the kills of one blast land in one tic)
	//   3 CHAIN REACTION     a barrel's blast sets off another barrel
	//   4 BARREL BLAST       any barrel goes off within 2 m of a player (BARREL_NEAR_M; the series' 34 map units a metre,
	//                        heights x1.2: Metres), from the barrel's middle to the nearest point of his body
	// A BARREL is Doom's ExplosiveBarrel or anything that replaces it (Brutal Doom's ExplosiveBarrel1 replaces it with no
	// parent, so the replacement chain is walked, as RSQ Melee's IsBarrel and Distance Grab's StandsFor do). A barrel GOES
	// OFF when it dies (its death is its explosion: Doom's and Brutal Doom's barrels both explode from Death). ITS BLAST is
	// what killed with it: the barrel itself (Doom's A_Explode) or a thing the dead barrel spawned (Brutal Doom's
	// BarrelExplosionDamage, its target the barrel: A_SpawnItemEx). The deaths of a tic are gathered and the cue is picked
	// the next tic, so one blast that is several cues at once shows the first of 1, 2, 3, 4 (the others are in the log).
	const BARREL_NEAR_M = 2.0;
	enum EBarrelCue { BC_LOCK = 1, BC_MULTI = 2, BC_CHAIN = 4, BC_NEAR = 8 }
	private transient int bcTic;              // the tic the deaths below belong to
	private transient int bcPend;             // the cues seen that tic (EBarrelCue bits)
	private transient int bcWho[4];           // the player each cue is for (-1 none known)
	private transient Array<Actor> bcBarrel;  // barrels whose blast killed a monster that tic ...
	private transient Array<int> bcKills;     // ... and how many
	private transient Array<Actor> bcVictim;  // the monsters counted (each once)
	static bool BarrelClass(Actor a)
	{
		if (!a || a.player || a.bISMONSTER) return false;
		Class<Actor> c = a.GetClass();
		for (int d = 0; c && d <= 4; d++)
		{
			for (class<Object> p = c; p; p = p.GetParentClass()) if (p.GetClassName() == 'ExplosiveBarrel') return true;
			Class<Actor> r = Actor.GetReplacee(c);
			if (!r || r == c) break;
			c = r;
		}
		return false;
	}
	// the gone-off barrel whose blast this inflictor is, or null
	static Actor BlastBarrel(Actor inf)
	{
		if (!inf) return null;
		if (BarrelClass(inf)) return inf.health <= 0 ? inf : null;
		if (inf.target && BarrelClass(inf.target) && inf.target.health <= 0) return inf.target;
		return null;
	}
	// the player who set it off, if one did (a barrel's target is what killed it)
	static int BarrelOwner(Actor b)
	{
		if (!b) return -1;
		Actor t = b.target;
		for (int i = 0; i < 4 && t && !t.player; i++) t = BarrelClass(t) ? t.target : null;   // up a chain
		return (t && t.player) ? t.PlayerNumber() : -1;
	}
	// the nearest living player within BARREL_NEAR_M of this barrel's middle, or -1
	static int BarrelNear(Actor b)
	{
		Vector3 m = b.Pos + (0, 0, b.Height * 0.5);
		int best = -1;
		double bestM = BARREL_NEAR_M;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0) continue;
			let pmo = players[n].mo;
			double z = clamp(m.z, pmo.Pos.z, pmo.Pos.z + pmo.Height);
			double d = Metres((m.x - pmo.Pos.x, m.y - pmo.Pos.y, m.z - z));
			if (d <= bestM) { bestM = d; best = n; }
		}
		return best;
	}
	private void BarrelPend(int cue, int who, String what)
	{
		int i = cue == BC_LOCK ? 0 : cue == BC_MULTI ? 1 : cue == BC_CHAIN ? 2 : 3;
		if (!(bcPend & cue)) bcWho[i] = who;
		bcPend |= cue;
		Log(i == 0 ? "barrel.lockon" : i == 1 ? "barrel.multikill" : i == 2 ? "barrel.chain" : "barrel.near", "seen: " .. what);
	}
	private void BarrelDeath(WorldEvent e)
	{
		if (!CatOn(CAT_BLOCKON) && !CatOn(CAT_BMULTI) && !CatOn(CAT_BCHAIN) && !CatOn(CAT_BNEAR)) return;
		if (bcTic != level.maptime)
		{
			bcTic = level.maptime;
			bcBarrel.Clear(); bcKills.Clear(); bcVictim.Clear();
		}
		Actor t = e.Thing;
		Actor b = BlastBarrel(e.Inflictor);
		if (BarrelClass(t))
		{
			int who = BarrelOwner(t);
			if (LockedBarrel(t)) BarrelPend(BC_LOCK, who, String.Format("%s landed on its locked monster and went off", t.GetClassName()));
			if (b && b != t) BarrelPend(BC_CHAIN, who, String.Format("%s set off by another barrel's blast (%s)", t.GetClassName(), e.Inflictor.GetClassName()));
			// RSQ Grenade's Neon Crescent spike (its service's "g2.neon", Grapple 2.0's air spike) is a barrel blast to every cue
			// but this one: its slow motion is Grapple-Slam's (G2Slam), asked by Grapple 2.0 itself
			int n = t.GetClassName() == 'RSQGN_NeonSpike' ? -1 : BarrelNear(t);
			if (n >= 0) BarrelPend(BC_NEAR, n, String.Format("%s went off within %.1f m of player %d", t.GetClassName(), BARREL_NEAR_M, n));
			return;
		}
		if (!b || !t.bISMONSTER || t.player || bcVictim.Find(t) < bcVictim.Size()) return;
		bcVictim.Push(t);
		int k = bcBarrel.Find(b);
		if (k >= bcBarrel.Size()) { bcBarrel.Push(b); bcKills.Push(0); }
		bcKills[k]++;
		if (bcKills[k] == 2) BarrelPend(BC_MULTI, BarrelOwner(b), String.Format("%s's blast killed 2 monsters (%s)", b.GetClassName(), t.GetClassName()));
	}
	private void BarrelCues()
	{
		if (!bcPend || bcTic >= level.maptime) return;
		static const int cue[] = { BC_LOCK, BC_MULTI, BC_CHAIN, BC_NEAR };
		static const int cat[] = { CAT_BLOCKON, CAT_BMULTI, CAT_BCHAIN, CAT_BNEAR };
		static const String src[] = { "barrel.lockon", "barrel.multikill", "barrel.chain", "barrel.near" };
		int pend = bcPend;
		bcPend = 0;
		for (int i = 0; i < 4; i++)
		{
			if (!(pend & cue[i])) continue;
			if (Trigger(src[i], cat[i], BlastMs(), Depth(), true, bcWho[i])) return;
		}
	}
	// CUE 1: was this barrel thrown or uppercut at a locked monster, and did it land on it? Asked by name of RSQ Distance
	// Grab's Barrel Lock-On (RSQDG_ThrowService "lockon.met": 1 once that barrel's steering ended on its locked monster,
	// set just before its blow lands). Without Distance Grab: never.
	private transient Service dgSvc;
	private transient bool dgLooked;
	bool LockedBarrel(Actor b)
	{
		if (!b) return false;
		if (!dgLooked) { dgLooked = true; dgSvc = ServiceIterator.Find("RSQDG_ThrowService").Next(); }
		return dgSvc && dgSvc.GetInt("lockon.met", "", 0, 0, b) == 1;
	}

	// Low Health At (Reload When = Low Health)
	static int LowAt() { return int(clamp(Cv("rsqsm_lowhp_at", 25), 1, 100)); }

	// ---- HEAVY HIT SLOWDOWN (owner 2026-11-06, his approved spec) -------------------------------------------------------
	// A HEAVY HIT: all the damage a player takes in one tic (what WorldThingDamaged reports: health lost, after armour) adds
	// up to Heavy Hit Size % of his MAX health (GetMaxHealth(true), 75 % by default). It slows the world for HH_MS (3 s) at the
	// World Speed slider's speed, a normal pulse (Slow Me Too slows him with it). It fires when that tic's damage came from:
	//   a LegenDoom legendary (LDLegendaryMonsterToken / LDLegendaryMonsterTransformed), a Champions champion
	//   (champion_PersistentInfo), RSQ Miniboss's miniboss or one of its thralls (RSQMB_Service "miniboss" / "thrall", by
	//   name), a +BOSS monster, or a big demon (BigKind: a Cyberdemon, Spider Mastermind, Baron of Hell, Hell Knight, Mancubus,
	//   Arch-Vile or Revenant by class, parent or the class it or a parent replaces: Brutal Doom's and XMVE's included);
	// or, whatever hit him, when one of the four extras (each its own row, on) is true of it:
	//   ARCH-VILE BLAST  an Arch-Vile's flame attack: the source is an Arch-Vile (BigKind) and the damage is its fire (damage
	//                    type Fire, or the inflictor is not the vile itself: A_VileAttack's blast comes from its fire)
	//   BLASTED          the hit threw him up: his vertical speed rose by HH_BLAST_VZ (10) map units a tic or more over that
	//                    tic (a jump is 8; a jump made the same tic is taken off first)
	//   HIT FROM BEHIND  the attacker's middle was over HH_VIEW (60) degrees off where his head faced (yaw and pitch: in VR
	//                    the pawn's angle and pitch are the headset's), so outside his view (Score's No-Look uses 60 too)
	//   ARMOUR BROKEN    he had armour before the tic and has none after it
	// NEVER on a hit that kills him, nor while he is DOWN (down.zs owns those). ITS COOLDOWN (rsqsm_heavy_cool): Once per 20 s, Once
	// per 60 s (from the last heavy-hit slowdown's start), Use Shared (the Auto Cooldown every automatic trigger shares), No
	// Limit (default). While RSQ Miniboss's Bossfight is on (RSQMB_Service "bossfight": arriving, or its miniboss alive) every
	// heavy hit fires, whatever the row says. The cause line names it: ARCH-VILE BLAST, HEAVY HIT: <the monster's tag>,
	// BLASTED, HIT FROM BEHIND, ARMOUR BROKEN, in that order of precedence.
	const HH_MS = 3000;
	const HH_BLAST_VZ = 10.0;
	const HH_VIEW = 60.0;
	int hhLast;                                   // maptime the last heavy-hit slowdown started (0 none this map)
	private transient int    hhDmg[MAXPLAYERS];   // this tic's damage so far
	private transient bool   hhSpecial[MAXPLAYERS], hhVile[MAXPLAYERS], hhBehind[MAXPLAYERS];
	private transient Array<String> hhName;       // the special attacker's tag (MAXPLAYERS long once used)
	private transient double hhVz[MAXPLAYERS];    // his vertical speed at the end of last tic's WorldTick
	private transient int    hhArm[MAXPLAYERS];   // ... and his armour
	private transient bool   hhPrimed;

	static bool HasInv(Actor a, String n) { class<Inventory> c = n; return c && a.FindInventory(c, true); }
	// a big demon: a Cyberdemon, Spider Mastermind, Baron of Hell, Hell Knight, Mancubus, Arch-Vile or Revenant by class or
	// parent, or a class (or a parent of it) that replaces one. vileOnly: the Arch-Vile alone.
	static bool Descends(class<Object> c, class<Object> base)
	{
		for (; c; c = c.GetParentClass()) if (c == base) return true;
		return false;
	}
	static bool BigKind(Actor a, bool vileOnly = false)
	{
		static const Name big[] = { 'Archvile', 'Cyberdemon', 'SpiderMastermind', 'BaronOfHell', 'HellKnight', 'Fatso', 'Revenant' };
		int nk = vileOnly ? 1 : big.Size();
		for (class<Object> k = a.GetClass(); k; k = k.GetParentClass())
		{
			class<Actor> c = (class<Actor>)(k);
			for (int d = 0; c && d < 8; d++)
			{
				for (int i = 0; i < nk; i++) { class<Object> bc = big[i]; if (bc && Descends(c, bc)) return true; }
				class<Actor> r = Actor.GetReplacee(c);
				if (!r || r == c) break;
				c = r;
			}
		}
		return false;
	}
	private transient bool hhMbLooked;
	private transient Service hhMb;
	private Service HhMbSvc()
	{
		if (!hhMbLooked) { hhMbLooked = true; hhMb = ServiceIterator.Find("RSQMB_Service").Next(); }
		return hhMb;
	}
	// what kind of attacker it is, "" none of the special kinds
	private String SpecialKind(Actor src)
	{
		if (HasInv(src, "LDLegendaryMonsterToken") || HasInv(src, "LDLegendaryMonsterTransformed")) return "legendary";
		if (HasInv(src, "champion_PersistentInfo")) return "champion";
		let mb = HhMbSvc();
		if (mb && mb.GetInt("miniboss", "", 0, 0, src) == 1) return "miniboss";
		if (mb && mb.GetInt("thrall", "", 0, 0, src) == 1) return "thrall";
		if (src.bBOSS) return "boss";
		if (BigKind(src)) return "big demon";
		return "";
	}
	private void HeavyNote(WorldEvent e)
	{
		if (Cv("rsqsm_trig_heavy", 1) == 0) return;
		int n = e.Thing.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS) return;
		if (hhName.Size() < MAXPLAYERS) for (int i = hhName.Size(); i < MAXPLAYERS; i++) hhName.Push("");
		hhDmg[n] += e.Damage;
		Actor src = e.DamageSource;
		if (!src || src == e.Thing || src.player) return;
		String k = SpecialKind(src);
		if (k != "" && !hhSpecial[n]) { hhSpecial[n] = true; hhName[n] = src.GetTag(); }
		if (BigKind(src, true) && (e.DamageType == 'Fire' || (e.Inflictor && e.Inflictor != src))) hhVile[n] = true;
		let pmo = e.Thing;
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 d = level.Vec3Diff(eye, src.pos + (0, 0, src.height * 0.5));
		if (d.Length() > 0.01)
		{
			Vector3 f = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
			double off = acos(clamp(d.Unit() dot f, -1.0, 1.0));
			if (off > HH_VIEW) hhBehind[n] = true;
		}
		String via = e.Inflictor ? String.Format("%s", e.Inflictor.GetClassName()) : "none";
		Log("heavyhit", String.Format("player %d took %d (%s from %s \"%s\" via %s, type %s)%s, %d this tic", n, e.Damage,
			k != "" ? k : "ordinary", src.GetClassName(), src.GetTag(), via, e.DamageType,
			hhBehind[n] ? ", from outside his view" : "", hhDmg[n]));
	}
	static int ArmourOf(Actor a) { let ar = a ? a.FindInventory("BasicArmor") : null; return ar ? ar.Amount : 0; }
	private bool BossfightOn() { let mb = HhMbSvc(); return mb && mb.GetInt("bossfight") == 1; }
	private void HeavyHits()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			int dmg = hhDmg[n];
			bool special = hhSpecial[n], vile = hhVile[n], behind = hhBehind[n];
			String name = hhName.Size() > n ? hhName[n] : "";
			hhDmg[n] = 0; hhSpecial[n] = false; hhVile[n] = false; hhBehind[n] = false;
			if (dmg <= 0 || !hhPrimed || !playeringame[n] || !players[n].mo || Cv("rsqsm_trig_heavy", 1) == 0) continue;
			let p = players[n];
			let pmo = p.mo;
			int maxHp = max(1, pmo.GetMaxHealth(true));
			double pct = clamp(Cv("rsqsm_heavy_pct", 75), 1, 1000);
			double need = maxHp * pct / 100.0;
			if (p.health <= 0 || pmo.health <= 0) { Log("heavyhit", String.Format("not fired: %d this tic killed player %d (Second Wind's, not ours)", dmg, n)); continue; }
			let dn = RSQSM_Down.Get();
			if (dn && dn.IsDown(n)) { Log("heavyhit", String.Format("not fired: player %d is DOWN (a lethal hit is DOWN's)", n)); continue; }
			if (dmg < need) { Log("heavyhit", String.Format("not fired: %d this tic is under %.0f%% of max health %d (%.1f needed)", dmg, pct, maxHp, need)); continue; }
			double rise = pmo.vel.z - hhVz[n];
			if (p.jumpTics == -1) rise -= pmo.JumpZ;
			bool blasted = rise >= HH_BLAST_VZ;
			bool broken = hhArm[n] > 0 && ArmourOf(pmo) <= 0;
			bool xVile = vile && Cv("rsqsm_heavy_vile", 1) != 0;
			bool xBlast = blasted && Cv("rsqsm_heavy_blasted", 1) != 0;
			bool xBehind = behind && Cv("rsqsm_heavy_behind", 1) != 0;
			bool xArm = broken && Cv("rsqsm_heavy_armour", 1) != 0;
			String what = String.Format("%d this tic of max health %d (%.0f%% needed %.1f): attacker %s, vile fire %d, vertical speed up %.1f, outside view %d, armour %d -> %d",
				dmg, maxHp, pct, need, special ? name : "not special", int(vile), rise, int(behind), hhArm[n], ArmourOf(pmo));
			String cause = "";
			if (xVile) cause = "ARCH-VILE BLAST";
			else if (special) cause = "HEAVY HIT: " .. name.MakeUpper();
			else if (xBlast) cause = "BLASTED";
			else if (xBehind) cause = "HIT FROM BEHIND";
			else if (xArm) cause = "ARMOUR BROKEN";
			if (cause == "") { Log("heavyhit", "not fired: heavy, but nothing it needs (" .. what .. ")"); continue; }
			int mode = int(Cv("rsqsm_heavy_cool", 3));
			bool fight = BossfightOn();
			int now = level.maptime;
			if (!fight && (mode == 0 || mode == 1) && hhLast > 0)
			{
				int wait = (mode == 0 ? 20 : 60) * TICRATE;
				if (now - hhLast < wait) { Log("heavyhit", String.Format("refused: its own cooldown (Once per %d s), %.1f s left (%s)", mode == 0 ? 20 : 60, (hhLast + wait - now) / double(TICRATE), what)); continue; }
			}
			Log("heavyhit", String.Format("heavy hit qualifies, cause line \"%s\" (%s)%s", cause, what, fight ? ", miniboss fight on: no cooldown" : ""));
			if (Trigger("heavyhit", CAT_HEAVY, HH_MS, Depth(), true, n, cause, mode == 2 && !fight)) hhLast = now;
		}
	}
	private void HeavySnap()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			bool ok = playeringame[n] && players[n].mo;
			hhVz[n] = ok ? players[n].mo.vel.z : 0;
			hhArm[n] = ok ? ArmourOf(players[n].mo) : 0;
		}
		hhPrimed = true;
	}

	// ---- the gesture (local; it only sends the toggle) ------------------------------------------
	// Cross your wrists in front of your face and hold them there a moment.
	// CROSSED, NOT ONLY CLOSE (2026-11-02). The test was "hands within 16 cm in front of the face", which a
	// two-hand pistol grip and a hand reload both are: on the rig each toggled slow motion (poses 6 cm and
	// 8 cm apart, the main hand on its own side; tools/rigtest/poses.txt, log before_poses). Crossed wrists put
	// the main hand on the OFF hand's side of it: now the main hand must be at least CROSS_M across (the
	// body's right axis; mirrored for a left-handed control scheme, vr_control_scheme >= 10).
	const CROSS_M = 0.03;
	private void LocalGesture()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return;
		if (CvP("rsqsm_gesture", p, 1) == 0) return;
		if (gestCool > 0) { gestCool--; return; }
		let pmo = p.mo;
		Vector3 head = (pmo.pos.xy, p.viewz);
		Vector3 a = pmo.AttackPos, b = pmo.OffhandPos;
		double together = Metres(a - b);
		Vector2 fwd = (cos(pmo.angle), sin(pmo.angle));
		Vector3 mid = (a + b) * 0.5;
		Vector3 d = mid - head;
		double ahead = (d.xy dot fwd) / 34.0;
		double up = d.z * 1.2 / 34.0;
		// RSQ_Accessibility's Gesture Ease widens the gap and the box in front of the face (x1..x2)
		// and shortens the hold (x1..x0.5); 0 / absent: exactly as tuned.
		double ease = RSQSM_A11y.Ease();
		double box = 1.0 + ease;
		let sch = CVar.FindCVar("vr_control_scheme");
		double across = ((a.x - b.x) * sin(pmo.angle) - (a.y - b.y) * cos(pmo.angle)) / 34.0;   // main right of off, metres
		if (sch && sch.GetInt() >= 10) across = -across;
		bool pose = together < RSQSM_A11y.Wide(CvP("rsqsm_gesture_gap", p, 0.16)) && across <= -CROSS_M
			&& ahead > 0.12 / box && ahead < 0.6 * box && up > -0.40 * box && up < 0.15 * box;
		if (!pose) { gestT = 0; gestArmed = true; return; }
		if (!gestArmed) return;
		if (++gestT >= max(1, int(RSQSM_A11y.Low(CvP("rsqsm_gesture_hold", p, 12)) + 0.5)))
		{
			// SM7 (owner's QoL option, rsqsm_gesture_burst): a 4 s burst instead of the toggle
			if (CvP("rsqsm_gesture_burst", p, 0) != 0) EventHandler.SendNetworkEvent("rsqsm_burst");
			else EventHandler.SendNetworkEvent("rsm_toggle", 1);     // 1: the wrist cross (for the trigger log)
			gestT = 0;
			gestArmed = false;      // apart again before the next one
			gestCool = 20;
		}
	}

	static double Metres(Vector3 d) { return (d.x, d.y, d.z * 1.2).Length() / 34.0; }
}

// A RUMBLE WITH A LENGTH AND A STRENGTH, on one controller: the series' route
// (A_QuakeEx QF_WAVE re-issued every tic; X = left, Y = right; lefty when
// vr_control_scheme >= 10). Local player only; rsqsm_haptics.
class RSQSM_Buzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;

	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH }

	static void Start(Actor who, int hand, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let cv = CVar.GetCVar("rsqsm_haptics", who.player);
		if (cv && !cv.GetBool()) return;
		// RUMBLE STRENGTH (RSQ_Accessibility's rsqa_rumble_scale, RSQSM_A11y.Rumble: x0..2, 0 = none; 1 without it).
		// Every SlowMo rumble comes through here.
		double rs = RSQSM_A11y.Rumble();
		if (rs <= 0) return;
		strength *= rs;
		let q = RSQSM_Buzz(Actor.Spawn("RSQSM_Buzz", who.pos));
		if (!q) return;
		let sch = CVar.FindCVar("vr_control_scheme");
		bool lefty = sch && sch.GetInt() >= 10;
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		if (tleft == total) RSQSM_A11y.RumbleBackup(feels, left);   // RSQ_Accessibility's Rumble Backup, at Quake Haptics 0 (a11y.zs)
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}

// The adrenaline meter, carried with the player from level to level (an EventHandler
// is rebuilt on every map).
class RSQSM_AdrToken : Inventory
{
	double meter;
	int    smokeLeft;      // tics of the smoke's slow motion carried to the next level (clock.zs WorldUnloaded / WorldLoaded)
	double smokeDepth;
	bool   smokeMove;
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.KEEPDEPLETED
	}
}

// FOR OTHER MODS, found by name (nothing links): GetInt("adrenaline.add", "", points) adds to
// the shared adrenaline meter (nothing while the meter is off) and answers the meter after it,
// 0..100. GetInt("adrenaline") reads it. GetInt("slowmo.active") (or "active") is 1 while the world
// is slowed (held, a pulse, or easing), 0 when not or stood down -- RSQ_Score's slow-motion bonus and the
// Gun Bonsai VR patch's slow-motion perks read it; GetInt("scale") is the world's speed in permille.
// START SLOW MOTION (2026-11-02): GetInt("start", who, ms, speed) -- deliberate, never refused for time --
// or GetInt("start.auto", who, ms, speed) -- automatic: waits out the cooldown. GetInt("start.bossfight", "", ms, speed) is RSQ
// Miniboss's landing only: automatic (the countdown bar shows), under the "Miniboss" switch, no shared cooldown. The first two need the Triggers page's
// "Other / Unknown Mods" switch on (rsqsm_auto_other). who: a name for the trigger log; ms: the hold (0 = 4 s); speed: the world's speed 0.05..1
// (0 = the player's World Speed slider). Answers 1 let in, 0 refused. Call it from synced play code (the
// same on every machine, e.g. a WorldTick or an actor's tic); from one machine's local code, send the
// network event `rsqsm_start:<who> <ms> <speed %> <flags>` instead (flags 1 = automatic).
// EDGE ARROWS (2026-11-09, arrows.zs; RSQ Miniboss points at its arriving thralls and the miniboss with them):
// GetInt("arrow.add", key, rgb, size, actor) puts a DOWN-style HUD edge arrow (the Turn Marker art and row, the >75 degree
// rule, behind you = at the bottom) on the console player's HUD, pointing at the actor in colour 0xRRGGBB, shown only while
// the actor is more than 75 degrees off his view; size 1.0 normal, 1.5 big (0 = 1.0; 0.5..2). Several at once; the same key
// on the same actor again recolours / resizes it in place. GetInt("arrow.clear", key, 0, 0, actor) takes it off (actor
// null: every arrow with that key). An arrow also goes when its actor dies or is gone, and with the map. Hidden while the
// console player is DOWN (DOWN's own arrows first). Answers 1; arrow.add answers 0 for no living actor or a full list (32).
// From synced play code only.
// GRAPPLE 2.0 (2026-11-13): "g2.slow" / "g2.addtime" / "g2.slam" / "g2.fullspeed" (in GetInt below; clock.zs G2Slow ...).
// -1: unknown request.
// The Gun Bonsai VR patch's Adrenaline upgrade charges it on melee kills.
class RSQSM_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// EDGE ARROWS (arrows.zs): before the clock, they do not need it
		if (request ~== "arrow.add" || request ~== "arrow.clear")
		{
			let ar = RSQSM_Arrows.Get();
			if (!ar) return 0;
			if (request ~== "arrow.add") return ar.AddArrow(stringArg, Actor(objectArg), intArg, doubleArg);
			return ar.ClearArrows(stringArg, Actor(objectArg));
		}
		let c = RSQSM_Clock.Get();
		if (!c) return -1;
		if (request ~== "adrenaline.add") { c.AddAdrenaline(intArg); return int(c.adr); }
		if (request ~== "adrenaline") return int(c.adr);
		if (request ~== "slowmo.active") return (!c.StoodDown() && c.Active()) ? 1 : 0;
		// slow motion is doing something this tic (1) or not (0), and how slow, in permille
		// of full speed (1000 = not slowed) -- the Gun Bonsai VR patch's slow-motion perks
		if (request ~== "active") return (c.Active() && !c.StoodDown()) ? 1 : 0;
		if (request ~== "scale") return int(clamp(c.scale, 0.0, 1.0) * 1000);
		// HELD OR PULSING, NOT JUST EASING BACK (owner 2026-10-31: the ring slows time even while slow motion eases out):
		// 1 while something is still asking for slow motion (the held toggle or a pulse), 0 once it is only fading back
		if (request ~== "running") return (!c.StoodDown() && (c.target < 0.9999 || c.DodgeOn())) ? 1 : 0;
		// FOR A SCORER (RSQ Score, 11-03; its sheet C2, C3): WHAT is slowing the world now. "trigger.auto": 1 an automatic
		// trigger (one that waits out the cooldown: Score's own pulses, the miniboss window, Gun Bonsai VR's perks, a
		// reload, an unknown mod), 0 a deliberate one (the key, the wrist cross, the burst, the Wheel, a shove, a parry,
		// a block, the cigarette), -1 nothing slowing. The held toggle is deliberate; a pulse is whatever let it in; the
		// ease back out keeps the answer of what ran. "trigger.score": 1 while the pulse running is Score's own (its big
		// moment or hit-stop, ResolvePulses), 0 another's, -1 nothing slowing.
		if (request ~== "trigger.auto")
		{
			if (c.StoodDown() || !c.Active()) return -1;
			if (c.DodgeOn()) return 0;                      // a shootdodge is his own (11-03)
			if (c.pulseUntil > level.maptime) return c.pulseAuto ? 1 : 0;
			if (c.on) return 0;
			return c.pulseAuto ? 1 : 0;
		}
		if (request ~== "trigger.score")
		{
			if (c.StoodDown() || !c.Active()) return -1;
			return (c.pulseUntil > level.maptime && c.pulseSrc == "score") ? 1 : 0;
		}
		// GRAPPLE 2.0 (clock.zs G2Slow / G2AddTime / G2Slam / G2Free; README "For other mods"). objectArg: the player's pawn
		// (a PlayerPawn; anything else: no player, the switches read as the world's). From synced play code only.
		//   "g2.slow", reason, tics      start (or extend to at least) a game slow of `tics` real tics, the reason under the
		//                                world bar; 1 let in, 0 refused (Other / Unknown Mods off, held on, stood down)
		//   "g2.addtime", reason, tics   `tics` more on the slow running now; 1 added, 0 nothing running (or refused)
		//   "g2.slam"                    Grapple-Slam (its own row): Barrel Near You's slow; 1 let in, 0 its row off / refused
		//   "g2.fullspeed", "", tics     tics > 0: his own movement at full speed for that long (1); tics 0: 1 when it is at full
		//                                speed now, 0 while Slow Me Too slows it. The factor to multiply motion by is then 1.
		if (request.Left(3) ~== "g2.")
		{
			let pmo = PlayerPawn(objectArg);
			int pn = (pmo && pmo.player) ? pmo.PlayerNumber() : -1;
			if (request ~== "g2.slow") return c.G2Slow(stringArg, intArg, pn) ? 1 : 0;
			if (request ~== "g2.addtime") return c.G2AddTime(stringArg, intArg, pn) ? 1 : 0;
			if (request ~== "g2.slam") return c.G2Slam(pn) ? 1 : 0;
			if (request ~== "g2.fullspeed") return c.StoodDown() ? 1 : c.G2Free(pn, intArg);
			return -1;
		}
		if (request ~== "start" || request ~== "start.auto")
			return c.Start(stringArg.Length() ? stringArg : "service", intArg, doubleArg, request ~== "start.auto") ? 1 : 0;
		// THE BOSSFIGHT LANDING (owner 2026-11-09: the countdown bar always shows during a game slow): RSQ Miniboss's arrival.
		// A GAME slow (automatic: the countdown bar and its BOSSFIGHT line show, Adrenaline on or off) under the Triggers page's
		// "Miniboss" switch, with no shared cooldown (it neither waits one out nor starts one), so the thrall windows that
		// follow still get their slow motion. "start" was used before: deliberate, so with Adrenaline on no bar showed.
		// RSQ MELEE'S LAUNCHED BARREL (owner 11-12 05:11: "contextual slo mo ... 3 seconds or explosion, whichever happens
		// first"): "start.barrel" a game slow (the countdown bar, its line BARREL), no shared cooldown, under the Other /
		// Unknown Mods switch; "stop" stringArg the trigger's name: that slow, if it is the one running, ends now.
		// "down.target" objectArg a monster: 0 not a DOWN target; else 1 + the step of the bar its player is in now (1 the
		// bottom third, 2 the middle, 3 the top). BD22 VR Reloaded's LegenDoom drops ask at its death (owner 11-12 14:11).
		if (request ~== "down.target")
		{
			let dn = RSQSM_Down(EventHandler.Find("RSQSM_Down"));
			let who = Actor(objectArg);
			if (!dn || !who) return 0;
			for (int i = 0; i < dn.tMon.Size(); i++)
				if (dn.tMon[i] == who) return clamp(3 - dn.TierAt(dn.Elapsed(dn.tPn[i])), 1, 3);
			return 0;
		}
		if (request ~== "start.barrel")
			return c.Trigger("barrel", RSQSM_Clock.CAT_OTHER, intArg > 0 ? intArg : 3000, doubleArg > 0 ? clamp(doubleArg, 0.05, 1.0) : c.Depth(), true, -1, "BARREL", false) ? 1 : 0;
		if (request ~== "stop")
		{
			if (c.pulseUntil <= level.maptime || !(c.pulseSrc ~== stringArg)) return 0;
			c.pulseUntil = level.maptime;
			return 1;
		}
		if (request ~== "start.bossfight")
		{
			int ms = intArg > 0 ? intArg : RSQSM_Clock.START_MS;
			double depth = doubleArg > 0 ? clamp(doubleArg, 0.05, 1.0) : c.Depth();
			return c.Trigger("bossfight", RSQSM_Clock.CAT_MINIBOSS, ms, depth, true, -1, "", false) ? 1 : 0;
		}
		// THE COUNTDOWN (countdown.zs): tics of real time until full speed while any slow motion runs, -1 when none
		if (request ~== "countdown") return c.cdOn ? int(ceil(c.cdLeft)) : -1;
		// DOWN (down.zs, v3): "down" / "down.hold" intArg player -> 1 while he is DOWN (RSQ Score leaves its lives alone then),
		// "down.any" any player, "down.redmap" 1 while the console player is DOWN with his Red Map row on (RSQ Glow In The
		// Dark), "down.left" real tics left on DEATH IN (-1 not DOWN), "down.mark" / "down.target" objectArg a monster -> 1
		// while it is a living DOWN target (RSQ VisualRewards keeps its bar up), "down.bank" (stringArg "health" / "armor",
		// intArg player, doubleArg amount -> 1 banked: RSQ VisualRewards' bits flown into the plate)
		if (request ~== "down.bank") { let d = RSQSM_Down.Get(); return (d && d.Bank(intArg, stringArg, doubleArg)) ? 1 : 0; }
		if (request.Left(4) ~== "down") return DownAsk(request, intArg, objectArg);
		return -1;
	}
	// "down.plate": the DOWN panel's anchor in the world -- none since 11-07 07:50 (the panel is on the HUD layer): null, so
	// VisualRewards' banking bits fly to the player himself
	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return null;
	}
	static clearscope int DownAsk(String request, int n, Object o = null)
	{
		let d = RSQSM_Down(EventHandler.Find("RSQSM_Down"));
		if (!d) return -1;
		if (request ~== "down" || request ~== "down.hold") return d.IsDown(n) ? 1 : 0;
		if (request ~== "down.any") return d.AnyOn() ? 1 : 0;
		if (request ~== "down.redmap")
		{
			if (!playeringame[consoleplayer] || !d.IsDown(consoleplayer)) return 0;
			let cv = CVar.GetCVar("rsqsm_down_redmap", players[consoleplayer]);
			return (!cv || cv.GetBool()) ? 1 : 0;
		}
		if (request ~== "down.left") return d.Left(n);
		if (request ~== "down.mark" || request ~== "down.target") return d.IsTarget(Actor(o)) ? 1 : 0;
		return -1;
	}
	// FROM A HUD (ui scope). "countdown": as above. "countdown.bottom": the screen pixel row just under the countdown bar's
	// slot while its row is on (RSQ Score moves its combo rows below it, by name), -1 when the bar is switched off.
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let c = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		if (request ~== "countdown") return (c && c.cdOn) ? int(ceil(c.cdLeft)) : -1;
		if (request.Left(4) ~== "down") return DownAsk(request, intArg, objectArg);
		if (request ~== "countdown.bottom")
		{
			if (!c || (c.rival && RSQSM_Countdown.SCv("rsm_yield", 1) != 0) || !RSQSM_Countdown.AnyOn()) return -1;
			return RSQSM_Countdown.Bottom();
		}
		// THE MENU: "menu.locked", "LeanDodge" -> 1 while the Gun Bonsai VR patch is loaded and the console player has
		// not learned Lean Dodge (LeanOn: the upgrade gates the Lean Out of Bullets row), else 0. From GbRefresh's cache.
		// Not in a game: 1 (nothing is learned yet).
		if (request ~== "menu.locked")
		{
			if (gamestate != GS_LEVEL || !c) return 1;
			if (!(stringArg ~== "LeanDodge")) return 0;
			int g = c.Gb(consoleplayer, 'LeanDodge');
			return (g >= 0 && g < 1) ? 1 : 0;
		}
		return -1;
	}
}


// LEAN DODGE 2 (Gun Bonsai VR, GBOVR_TREES.md 4.9): while the world is slowed, a monster's claw (a hit up close whose
// inflictor is the monster itself) misses a player leaning across its line -- the lean the rounds already read (body.zs).
// Inert without the patch (Gb -1) and below level 2.
class RSQSM_ClawDodge : Inventory
{
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }
	override void AbsorbDamage(int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags)
	{
		let pmo = PlayerPawn(Owner);
		if (!pmo || !pmo.player || damage <= 0 || !source || source.player || inflictor != source || (flags & DMG_EXPLOSION)) return;
		let c = RSQSM_Clock.Get();
		if (!c || c.scale > 0.95 || c.Gb(pmo.PlayerNumber(), 'LeanDodge') < 2 || !RSQSM_Clock.LeanOn(pmo.PlayerNumber())) return;
		if (pmo.Distance2D(source) > source.radius + pmo.radius + 72) return;
		let b = RSQSM_Body(EventHandler.Find("RSQSM_Body"));
		if (!b) return;
		int n = pmo.PlayerNumber();
		Vector2 leanV = (b.leanX[n], b.leanY[n]);
		if (leanV.Length() < 1) return;
		Vector2 dir = (pmo.pos.xy - source.pos.xy);
		if (dir.Length() < 0.01) return;
		dir = dir.Unit();
		double across = abs(dir.x * leanV.y - dir.y * leanV.x);
		if (across < 2.0) return;	// leaning along the claw's line is no dodge
		newdamage = 0;
		let sc = ServiceIterator.Find("RS_ScoreService").Next();
		if (sc) sc.GetInt("touch", "lean", n, 0, source);
		if (RSQSM_Clock.Cv("rsqsm_debug", 0) != 0) Console.Printf("RSQ_SlowMo: leaned out of %s's claw (%.1f across its line)", source.GetClassName(), across);
	}
}