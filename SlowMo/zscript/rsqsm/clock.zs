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
// the Accessibility button, Melee's shove, the cigarette, a Saber parry, a ShieldSaw block -- is never
// refused for time. An automatic one -- Close-Call, Reload Slowdown, Score, Gun Bonsai VR, other mods, the
// miniboss window -- waits out rsqsm_auto_cooldown seconds after the last automatic pulse ENDED.
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
	bool   rival;            // decided once per map
	RSQSM_Smooth smooth;     // the walkers' step-spreader (smooth.zs), made on first use

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
	double Depth()   { return clamp(Cv("rsm_depth", 0.25), 0.05, 0.95); }
	// RSQ_Accessibility's Min SlowMo Ease (rsqa_slowmo_ramp) is a floor under both: no ease
	// shorter than it, so the world never lurches into or out of slow motion. 0 / absent: as set.
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
		ClearAll();
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
			let t = RSQSM_AdrToken(pmo.FindInventory("RSQSM_AdrToken"));
			if (!t) t = RSQSM_AdrToken(pmo.GiveInventoryType("RSQSM_AdrToken"));
			if (t) t.meter = adr;
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
		else if (e.Name ~== "rsm_off")  Aim(false, e.Player, "rsm_off");
		else if (e.Name ~== "rsm_pulse")
		{
			if (pendTic != level.maptime) { pendTic = level.maptime; pendMs.Clear(); pendDepth.Clear(); pendWho.Clear(); }
			pendMs.Push(e.Args[0]); pendDepth.Push(e.Args[1]); pendWho.Push(e.Player);
		}
		// RSQ Melee sends its F.E.A.R. window with the shove's pulse, from the same machine on the same tic
		// (Melee shove.zs Pulse): seen by name, it marks that pulse as the shove (deliberate).
		else if (e.Name ~== "rsqml_fear") { if (e.Player >= 0 && e.Player < MAXPLAYERS) fearTic[e.Player] = level.maptime; }
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
	//   RSQ Tactical Rig cigarette rsm_pulse <rsqtr_cig_secs x 1000> <rsqtr_cig_depth> (the sender's own) -> deliberate
	//   RSQ Saber perfect parry (ubqs_parry_slowmo), RSQ ShieldSaw perfect block (ssq_perfect_slowmo): both
	//     rsm_pulse 500 35, told apart by whose option is on and what the sender holds (ParryOrBlock) -> deliberate
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
			if (okWho)
			{
				let cs = CVar.GetCVar("rsqtr_cig_secs", players[who]);
				let cd = CVar.GetCVar("rsqtr_cig_depth", players[who]);
				if (cs && cd && ms == int(cs.GetFloat() * 1000) && dp == cd.GetInt()) { Trigger("smoke", CAT_SMOKE, ms, depth, false, who); continue; }
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
	private int ParryOrBlock(int who)
	{
		bool sb = OptOn('ubqs_parry_slowmo') && Loaded('UBQS_SaberBase') && (who < 0 || HoldsKind(who, 'UBQS_SaberBase'));
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
		if (on) pulseUntil = 0;     // the toggle outranks a pulse
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
		CAT_A11Y, CAT_SHOVE, CAT_SMOKE, CAT_PARRY, CAT_BLOCK, CAT_SCORE, CAT_GBVR }
	static double CvWho(String n, int who, double d)
	{
		return (who >= 0 && who < MAXPLAYERS && playeringame[who]) ? CvP(n, players[who], d) : Cv(n, d);
	}
	static bool CatOn(int cat, int who = -1)
	{
		switch (cat)
		{
		case CAT_KEY:       return CvWho("rsqsm_trig_key", who, 1) != 0;
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
		}
		return true;
	}
	static String CatName(int cat)
	{
		static const String names[] = { "-", "Close-Call", "Reload Slowdown", "Other / Unknown Mods", "Miniboss Window",
			"Manual Key", "Wrist Cross", "Burst", "Wheel", "Accessibility Button", "Melee Shove", "Cigarette",
			"Saber Parry", "ShieldSaw Block", "Score", "Gun Bonsai VR" };
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
	bool Trigger(String src, int cat, int ms, double depth, bool isAuto, int who = -1)
	{
		if (StoodDown()) { Log(src, "refused: stood down (another slow-motion mod)"); return false; }
		if (on) { Log(src, "not needed: slow motion is held on"); return false; }
		if (!CatOn(cat, who)) { Log(src, String.Format("refused: its switch is off (%s)", CatName(cat))); return false; }
		if (isAuto)
		{
			bool stretch = pulseUntil > 0 && pulseAuto && pulseSrc == src;
			if (!stretch && level.maptime < autoReady)
			{
				Log(src, String.Format("refused: automatic cooldown, %.1f s left", (autoReady - level.maptime) / double(TICRATE)));
				return false;
			}
		}
		bool fresh = pulseUntil <= 0;
		Pulse(ms, depth);
		pulseSrc = src;
		pulseAuto = isAuto;
		if (isAuto) autoReady = max(autoReady, pulseUntil + int(Cooldown() * TICRATE));
		Log(src, String.Format("%s %d ms at %d%% (%s), pulse until t%d", fresh ? "started" : "merged", ms, int(depth * 100 + 0.5),
			isAuto ? "automatic" : "deliberate", pulseUntil));
		return true;
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

	// RS_SlowMo's pulse, same arguments and the same rules: hold `ms`, at `depth` of
	// full speed; the ramps are this mod's; deeper wins and longer wins; the held
	// toggle outranks it; both clamped so no caller can freeze the world for good.
	// THE HOLD'S CAP IS 30 s, NOT 5. Ermac's cigarette (RSQ_TacticalRig rsqtr_cig_secs) asks for 6 s by
	// default and up to 20 from its menu; a 5 s cap cut every one of those short (measured on the rig,
	// bugfix pass 10-31: rsm_pulse 6000 25 held 175 tics, not 210).
	const PULSE_MAX_MS = 30000;
	private void Pulse(int ms, double depth)
	{
		if (StoodDown() || on) return;
		int holdUntil = level.maptime + int(ceil(clamp(ms, 30, PULSE_MAX_MS) * TICRATE / 1000.0));
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
		if (adrOn && adr < Cv("rsqsm_adr_min", 25))
		{
			if (mo) { RSQSM_Buzz.Start(mo, 0, 0.25, 3); mo.A_StartSound("*usefail", CHAN_AUTO, CHANF_LOCAL, 0.6); }
			Log("wristcross.burst", "refused: not enough adrenaline");
			return;
		}
		if (adrOn) adr = max(0.0, adr - 100.0 * (BURST_MS / 1000.0) / max(1.0, Cv("rsqsm_adr_secs", 10)));
		Trigger("wristcross.burst", CAT_BURST, BURST_MS, Depth(), false, who);
		if (mo)
		{
			mo.A_StartSound("rsqsm/in", CHAN_AUTO, 0, 0.8);
			RSQSM_Buzz.Start(mo, 0, 0.6, 8);
			RSQSM_Buzz.Start(mo, 1, 0.6, 8);
		}
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
		LocalGesture();
		if (StoodDown()) return;
		ResolvePulses();
		CloseCalls();

		// Where the clock is heading: the toggle, then a pulse, then full speed.
		if (on) target = Depth();
		else if (pulseUntil > 0)
		{
			if (level.maptime < pulseUntil) target = pulseDepth;
			else { pulseUntil = 0; target = 1; }
		}
		else target = 1;

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
		// Your own missiles, when that is switched off.
		if (a.bMISSILE && a.target && a.target.player && !cvSlowOwn) return true;
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
		if (Cv("rsqsm_adrenaline", 0) == 0 || !on) return;
		adr -= 100.0 / max(1.0, Cv("rsqsm_adr_secs", 10) * TICRATE);
		if (adr <= 0) { adr = 0; Aim(false, -1); }
	}

	// A KILL IS COUNTED WHERE THE DAMAGE NAMES ITS SOURCE. WorldThingDied only carries the inflictor,
	// and a hitscan's inflictor is its puff, which points at nobody unless the puff is PUFFGETSOWNER:
	// measured, a player's pistol kill earned no adrenaline. The killing blow's WorldThingDamaged has
	// the source itself; a death that never passes through damage (a script's A_Die) still counts
	// through WorldThingDied as before.
	private transient Actor lastKilled;
	override void WorldThingDied(WorldEvent e)
	{
		if (!e.Thing || !e.Thing.bISMONSTER || e.Thing == lastKilled) return;
		Actor src = e.Inflictor;
		if (src && !src.player) src = src.target;
		if (src && src.player) AddAdrenaline(Cv("rsqsm_adr_kill", 12));
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (e.Thing && e.Thing.player && e.Damage > 0) AddAdrenaline(e.Damage * 0.5);
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
	private transient bool wasReloading[MAXPLAYERS];
	private transient int  lastA1[MAXPLAYERS], lastA2[MAXPLAYERS];
	private transient Weapon lastW[MAXPLAYERS];
	private void Reloads()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n]) continue;
			let p = players[n];
			let w = p.ReadyWeapon;
			bool wanted = w && CvP("rsqsm_reload", p, 0) != 0;
			bool r = false, moved = false;
			int a1 = (w && w.Ammo1) ? w.Ammo1.Amount : 0;
			int a2 = (w && w.Ammo2) ? w.Ammo2.Amount : 0;
			if (wanted)
			{
				State rs = w.FindState("Reload");
				let ps = p.GetPSprite(PSP_WEAPON);
				r = rs && ps && ps.CurState && Actor.InStateSequence(ps.CurState, rs);
				if (w == lastW[n] && w.Ammo1 && w.Ammo2 && w.Ammo1 != w.Ammo2)
					moved = (a2 > lastA2[n] && a1 < lastA1[n]) || (a1 > lastA1[n] && a2 < lastA2[n]);
			}
			if (reloadPrimed && ((r && !wasReloading[n]) || moved))
				Trigger("reload", CAT_RELOAD, int(CvP("rsqsm_reload_ms", p, 1200)), Depth(), true, n);
			wasReloading[n] = r;
			lastW[n] = w; lastA1[n] = a1; lastA2[n] = a2;
		}
		reloadPrimed = true;     // the first tic after a load only looks
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
// or GetInt("start.auto", who, ms, speed) -- automatic: waits out the cooldown. Both need the Triggers page's
// "Other / Unknown Mods" switch on (rsqsm_auto_other). who: a name for the trigger log; ms: the hold (0 = 4 s); speed: the world's speed 0.05..1
// (0 = the player's World Speed slider). Answers 1 let in, 0 refused. Call it from synced play code (the
// same on every machine, e.g. a WorldTick or an actor's tic); from one machine's local code, send the
// network event `rsqsm_start:<who> <ms> <speed %> <flags>` instead (flags 1 = automatic).
// -1: unknown request.
// The Gun Bonsai VR patch's Adrenaline upgrade charges it on melee kills.
class RSQSM_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
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
		if (request ~== "running") return (!c.StoodDown() && c.target < 0.9999) ? 1 : 0;
		if (request ~== "start" || request ~== "start.auto")
			return c.Start(stringArg.Length() ? stringArg : "service", intArg, doubleArg, request ~== "start.auto") ? 1 : 0;
		return -1;
	}
}
