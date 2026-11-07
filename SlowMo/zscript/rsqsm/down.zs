// RSQ_SlowMo -- DOWN v3 (owner-approved, design/NEAR_DEATH.md: the v2 spec at its top, then every "v3" section, which wins).
// SlowMo owns the mode and its options (it owns time); the other mods join by name and each still loads alone.
//
//  TRIGGER   a hit that would kill you holds you at 1 HP (the engine's buddha flag while DOWN is armed: its row on, you
//            alive), before any Score life is spent. A MONSTER must be to blame: the damage source (a missile's shooter; a
//            barrel's: whoever set it off, the engine's own credit; a monster's helper: its master). A barrel nobody set off,
//            a crusher ('Crush'), a fall ('Falling'), your own shot, a hazard: NO DOWN, the hold lets go and the normal death
//            follows (a Score life catches it as usual).
//  WHILE     hits cannot kill you (the hold stays on all DOWN long); only the clock ends it. THE BODY (v2, kept): the crouch
//            (40% of standing, eased), crawl speed (a third), the world at SlowMo's deepest (DEPTH), Red Map (RSQ Glow In The
//            Dark), the heartbeat. Your own shots fly at normal speed (clock.zs RealTime: own-rockets-slow forced off for you).
//  CLOCK     DEATH IN: 9 s of REAL time (Clock), never above it. Damage you deal to any monster buys clock time as a SHARE of
//            its spawn health: a whole monster's worth = 1 s (humanoids, Imp, Pinky), 0.5 s (Lost Soul), 2 s (anything
//            above), 10 s (Cyberdemon, Spider Mastermind); a modded monster counts as what it replaces (Actor.GetReplacee,
//            then its parents). Bought time goes to a pool that pours in at most 0.75 s a second, so the clock still drains
//            at a quarter speed at best (Slowest Drain); clock + pool never over 9 s. At zero: Score is asked for a life
//            (its buddha catches the killing blow), else you die.
//  BAR       the reward gauge, not a second clock: three steps of 3 s (Bar Step), tall (right end, drains first), normal,
//            thin. Bought time never stretches it. The step you are in when the LAST target dies is the tier.
//  TARGETS   kills owed = 1 + the DOWNs since the last Score life spent (RSQSM_DownWatch.downs travels with you; the count
//            goes back when Score's life count drops). Target 1: the monster that downed you if it is in your fight
//            (alive, and within FIGHT_NEAR, or in sight within FIGHT_FAR), else a boosted copy of its type spawned in view at
//            range. Every extra target: a fresh boosted copy of that type spawned in view. Boost by what is loaded:
//            LegenDoom + Champions: a legendary (LegenDoom's own guaranteed pickup) champion (a Champions colour token,
//            given by name as RSQ Miniboss does); LegenDoom alone: legendary; Champions alone: a champion; neither: our
//            own (DOWN red tint). All of them: a light in their colour, full-bright, 15% larger, +50% health (not with
//            LegenDoom: it sets a legendary's health). Each target gets one of ten icons (random, never twice in a DOWN).
//  UP        the last target dead: up at once. REVIVE every time (VisualRewards, sized by tier). Tier top / middle / bottom:
//            invulnerable 5 / 3 / 1 s, slow motion 3 / 1.5 / 5 s; top: Score's Revival Fire, +1 cigarette (Tactical Rig),
//            +1 grenade (Grenade). Health and armour: the bits bank (VisualRewards' Kill Rewards, kills while DOWN fly into
//            the plate), up to max health and 250 armour; no bank (VisualRewards not loaded or Kill Rewards off): the tier
//            split 100 / 66 / 33 %. Both held guns' magazines filled for free (never from the reserve). No RAGE, no Scar, no
//            Cooldown, no crate, no "Revive" award ("Revenge" stays: each target you kill).
//  FAIL      the clock at zero. With a Score life: the spawned targets go in teleport fog, the map's own monster loses its
//            mark and boost and stays. Without: dead.
//  PLATE     plate.zs: the canvas-like plate drawn the RSQ Wheel's way (model quads in the world), the target icons over
//            the monsters, the off-view turn markers. Console player only.
//  NETPLAY   each player has his own DOWN; the world's slow-down is the clock's, shared as every slow motion is.
//
// JOINING (by name): every Service whose class name contains "RSQDownJoin" is told GetInt(event, stringArg, player, 0,
// actor): "down.start" (pawn), "down.target" (a target monster; stringArg its colour "RRGGBB"), "down.time" (the monster
// hit; "+0.4s"), "down.revenge" (a target killed by him), "down.up" (pawn; "top" / "middle" / "bottom": every revive),
// "down.revive" (pawn; TOP tier only: Tactical Rig's cigarette and Grenade's grenade answer it), "down.fail" (pawn; why).
// RSQSM_Service answers "down" / "down.hold" / "down.any" / "down.redmap" / "down.left" (intArg player), "down.mark"
// (objectArg a monster: 1 while it is a living DOWN target), "down.bank" (play: stringArg "health" / "armor", intArg
// player, doubleArg amount -> 1 banked) and GetObject "down.plate" (intArg player -> the plate's anchor actor, or null).
class RSQSM_Down : EventHandler
{
	const DEPTH = 0.05;        // the world's speed while DOWN: the deepest SlowMo has
	const CROUCH_K = 0.4;      // the view and hitbox at 40% of standing: "60% lower" (Crouch: why it is safe)
	const CROUCH_TICS = 17;    // ~0.5 s to ease all the way
	const CRAWL_K = 1.0 / 3.0; // crawl speed
	const MARK_SCALE = 1.15;   // "slightly larger"
	const DOWN_RED = 0xE01818;
	// "in your fight" (my reading, the doc gives no number): alive and within FIGHT_NEAR, or in sight within FIGHT_FAR
	const FIGHT_NEAR = 1024;
	const FIGHT_FAR = 2048;
	const SPAWN_TRIES = 70;    // tics a spawn keeps looking for a spot in view before it is dropped (logged)

	// ---- synced (in the save) ----------------------------------------------------------------------------------------
	bool   downOn[MAXPLAYERS];
	int    downStart[MAXPLAYERS];                        // maptime (real time: never slowed)
	double clk[MAXPLAYERS], pool[MAXPLAYERS];           // DEATH IN, and the bought time still to pour in (tics)
	int    owed[MAXPLAYERS];
	int    beatNext[MAXPLAYERS], beatN[MAXPLAYERS];
	bool   held[MAXPLAYERS];
	int    endTic[MAXPLAYERS], endHow[MAXPLAYERS];       // 1 revived, 2 failed
	int    lastKill[MAXPLAYERS];
	int    stepsGone[MAXPLAYERS];                        // bar steps that have broken off (bits 0 tall, 1 normal, 2 thin)
	int    stepTic[24];                            // maptime each step broke off (the plate's falling piece)
	int    shakeTic[MAXPLAYERS];
	double bankHp[MAXPLAYERS], bankAr[MAXPLAYERS];
	int    invulUntil[MAXPLAYERS];
	int    livesSeen[MAXPLAYERS];
	int    iconsUsed[MAXPLAYERS];                        // bit mask of the icons dealt this DOWN
	int    tierShown[MAXPLAYERS];
	// the targets (all players, in parallel)
	Array<Actor> tMon;
	Array<int>   tPn, tIcon, tSpawned, tDead, tCol, tBorn, tDeadTic;
	// the boosts (to take back from a map monster when a DOWN fails with a Score life)
	Array<Actor> bMon;
	Array<double> bSX, bSY;
	Array<int>   bHp, bBright, bOwn;
	// spawns still looking for a spot
	Array<int>   spPn, spTries, spIcon;
	Array<String> spCls;
	// the crouch
	bool   cOn[MAXPLAYERS];
	double cK[MAXPLAYERS], cVH[MAXPLAYERS], cFH[MAXPLAYERS];
	Actor  cPawn[MAXPLAYERS];
	int    cLogged[MAXPLAYERS];

	// ---- this tic ----------------------------------------------------------------------------------------------------
	private transient int hpSeen[MAXPLAYERS];
	transient RSQSM_Plate plate;                          // the console player's plate (plate.zs); rebuilt after a load

	static RSQSM_Down Get() { return RSQSM_Down(EventHandler.Find("RSQSM_Down")); }
	static clearscope double Cv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope double CvP(String n, int pn, double d)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return Cv(n, d);
		let c = CVar.GetCVar(n, players[pn]);
		return c ? c.GetFloat() : d;
	}
	static bool On() { return Cv("rsqsm_down", 0) != 0; }
	static clearscope double ClockTics() { return clamp(Cv("rsqsm_down_clock", 9), 2, 30) * TICRATE; }
	static clearscope double StepTics() { return clamp(Cv("rsqsm_down_step", 3), 0.5, 10) * TICRATE; }
	static double MinDrain() { return clamp(Cv("rsqsm_down_drain", 0.25), 0.0, 1.0); }
	static bool LowView(int n) { return CvP("rsqsm_down_lowview", n, 1) != 0; }
	static bool Debug() { return Cv("rsqsm_debug", 0) != 0; }
	static void Log(String s) { if (Debug()) Console.Printf("RSQ_SlowMo: DOWN t%d: %s", level.maptime, s); }

	clearscope bool AnyOn() { for (int n = 0; n < MAXPLAYERS; n++) if (downOn[n]) return true; return false; }
	clearscope bool IsDown(int n) { return n >= 0 && n < MAXPLAYERS && downOn[n]; }
	clearscope int Left(int n) { return IsDown(n) ? max(0, int(ceil(clk[n]))) : -1; }
	clearscope bool IsTarget(Actor a)
	{
		if (!a) return false;
		for (int i = 0; i < tMon.Size(); i++) if (tMon[i] == a && (tDead[i] == 0)) return true;
		return false;
	}
	clearscope bool IsMarked(Actor a) { return IsTarget(a); }
	// the bar: elapsed real tics into this DOWN, and the tier it stands at (0 top, 1 middle, 2 bottom)
	clearscope int Elapsed(int n) { return IsDown(n) ? level.maptime - downStart[n] : 0; }
	clearscope int TierAt(int e) { double s = StepTics(); return e < s ? 0 : (e < 2 * s ? 1 : 2); }
	double Crawl(int n)
	{
		if (!IsDown(n) || !players[n].mo) return 1.0;
		double cf = players[n].crouchfactor;
		double eng = (cf != 1) ? clamp(cf, 0.5, 1.0) : 1.0;
		return CRAWL_K / eng;
	}
	clearscope bool Invul(int n) { return n >= 0 && n < MAXPLAYERS && invulUntil[n] > level.maptime; }

	override void WorldLoaded(WorldEvent e)
	{
		// a save keeps the plate's quads but not the transient plate that drove them: clear them, the plate rebuilds
		if (e.IsSaveGame)
		{
			let it = ThinkerIterator.Create("RSQSM_PQuad");
			Actor a;
			Array<Actor> kill;
			while (a = Actor(it.Next())) kill.Push(a);
			for (int i = 0; i < kill.Size(); i++) if (kill[i]) kill[i].Destroy();
			return;
		}
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			downOn[n] = false; downStart[n] = 0; clk[n] = 0; pool[n] = 0; owed[n] = 0; beatNext[n] = 0; beatN[n] = 0; held[n] = false;
			endTic[n] = 0; endHow[n] = 0; cOn[n] = false; invulUntil[n] = 0; bankHp[n] = 0; bankAr[n] = 0; livesSeen[n] = -1;
		}
		tMon.Clear(); tPn.Clear(); tIcon.Clear(); tSpawned.Clear(); tDead.Clear(); tCol.Clear(); tBorn.Clear(); tDeadTic.Clear();
		bMon.Clear(); bSX.Clear(); bSY.Clear(); bHp.Clear(); bBright.Clear(); bOwn.Clear();
		spPn.Clear(); spTries.Clear(); spIcon.Clear(); spCls.Clear();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			Hold(n, false);
			CrouchRestore(n, "the map ends");
			downOn[n] = false;
		}
		if (plate) { plate.Clear(); plate = null; }
		gone = true;      // the level is over: no tic of this handler may touch the travelling pawn again
	}
	private transient bool gone;

	// ---- the hold ---------------------------------------------------------------------------------------------------
	bool Armed(int n)
	{
		if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0 || players[n].playerstate == PST_DEAD) return false;
		if (downOn[n]) return true;                 // v3: hits cannot kill you while DOWN; only the clock ends it
		let c = RSQSM_Clock.Get();
		if (c && c.StoodDown()) return false;
		return On();
	}
	private void Hold(int n, bool want)
	{
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) { held[n] = false; return; }
		if (want && !held[n])
		{
			if (pmo.bBUDDHA) return;
			pmo.bBUDDHA = true; held[n] = true;
		}
		else if (!want && held[n]) { pmo.bBUDDHA = false; held[n] = false; }
	}

	// ---- every tic ----------------------------------------------------------------------------------------------------
	override void WorldTick()
	{
		if (gone) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			let w = RSQSM_DownWatch(pmo.FindInventory("RSQSM_DownWatch"));
			if (!w) { pmo.GiveInventoryType("RSQSM_DownWatch"); w = RSQSM_DownWatch(pmo.FindInventory("RSQSM_DownWatch")); }
			WatchLives(n, pmo, w);
			if (downOn[n])
			{
				if (pmo.health <= 0) Fail(n, "he died (a hit the hold could not catch)");
				else
				{
					ClockTick(n);
					if (clk[n] <= 0) Fail(n, String.Format("the clock ran out (%d of %d targets dead)", Killed(n), OwedOf(n)));
					else { Heartbeat(n); WatchTargets(n); BarSteps(n, pmo); }
				}
			}
			if (pmo.health <= 0 || players[n].playerstate == PST_DEAD) CrouchRestore(n, "he is dead");
			else Crouch(n, pmo, downOn[n]);
			Hold(n, Armed(n));
			hpSeen[n] = pmo.health;
		}
		Spawns();
		// THE PLATE (plate.zs): the console player's, built while he is DOWN, gone when not
		int cp = consoleplayer;
		bool want = IsDown(cp);
		for (int i = 0; i < tMon.Size() && !want; i++) if (tPn[i] == cp && tDead[i] != 0 && level.maptime - tDeadTic[i] < 20) want = true;
		if (want && !plate) { plate = RSQSM_Plate(new("RSQSM_Plate")); plate.Init(cp); }
		if (plate)
		{
			if (!want || !playeringame[cp] || !players[cp].mo) { plate.Clear(); plate = null; }
			else plate.Tick(self);
		}
		// targets of a DOWN that ended are forgotten once their icon is done
		for (int i = tMon.Size() - 1; i >= 0; i--)
		{
			int pn = tPn[i];
			if (!downOn[pn] && ((tDead[i] == 0) || level.maptime - tDeadTic[i] > 20)) DropTarget(i);
		}
	}

	// THE SCORE LIFE COUNT (by name): the kills owed go back to 1 when a life is spent (Score's count drops)
	private void WatchLives(int n, PlayerPawn pmo, RSQSM_DownWatch w)
	{
		if ((level.maptime & 3) != 0 && livesSeen[n] >= 0) return;
		int lv = ScoreLives(pmo);
		if (lv < 0) return;
		if (livesSeen[n] >= 0 && lv < livesSeen[n] && w && w.downs > 0)
		{
			Log(String.Format("player %d spent a Score life (%d -> %d): kills owed back to 1 (was %d DOWNs)", n, livesSeen[n], lv, w.downs));
			w.downs = 0;
		}
		livesSeen[n] = lv;
	}
	static int ScoreLives(Actor pmo)
	{
		let it = ServiceIterator.Find("RS_ScoreService");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RS_ScoreService') return s.GetInt("lives", "", 0, 0, pmo);
		return -1;
	}

	// DEATH IN: one real tic a tic; the pool pours in at most (1 - Slowest Drain) a tic; never above the Clock
	private void ClockTick(int n)
	{
		double pour = min(pool[n], 1.0 - MinDrain());
		pool[n] -= pour;
		clk[n] = min(ClockTics(), clk[n] - 1.0 + pour);
	}

	// THE BAR'S STEPS: each breaks off as it runs out (shake, clunk, rumble)
	private void BarSteps(int n, PlayerPawn pmo)
	{
		int e = Elapsed(n);
		double s = StepTics();
		for (int k = 0; k < 3; k++)
		{
			if ((stepsGone[n] & (1 << k)) != 0) continue;
			if (e < s * (k + 1)) continue;
			stepsGone[n] |= 1 << k;
			stepTic[n * 3 + k] = level.maptime;
			shakeTic[n] = level.maptime;
			pmo.A_StartSound("plats/pt1_stop", CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
			RSQSM_Buzz.Start(pmo, 0, 0.9, 8);
			RSQSM_Buzz.Start(pmo, 1, 0.9, 8);
			Log(String.Format("player %d bar: the %s step broke off at %.2f s (clunk plats/pt1_stop, rumble); tier now %s", n,
				k == 0 ? "tall" : (k == 1 ? "normal" : "thin"), e / double(TICRATE), TierName(min(2, k + 1))));
		}
	}
	static clearscope String TierName(int t) { return t == 0 ? "top" : (t == 1 ? "middle" : "bottom"); }

	private void Heartbeat(int n)
	{
		if (level.maptime < beatNext[n]) return;
		let pmo = players[n].mo;
		double l = clk[n] / max(1.0, ClockTics());
		beatNext[n] = level.maptime + int(12 + 14 * clamp(l, 0.0, 1.0));
		beatN[n]++;
		bool bd = S_GetLength("heartbeat1") > 0;
		if (bd) pmo.A_StartSound((beatN[n] & 1) ? "heartbeat1" : "heartbeat2", CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
		else pmo.A_StartSound("plats/pt1_stop", CHAN_AUTO, CHANF_LOCAL, 0.9, ATTN_NONE, 0.55);
		RSQSM_Buzz.Start(pmo, 0, 0.35, 3);
		RSQSM_Buzz.Start(pmo, 1, 0.35, 3);
	}

	// ==================================================================================================================
	// THE CROUCH (spec 2). What the engine does (QuestZDoom 17.3, player.zs; the survey 09_MOVEMENT 3.5, 00_CAPABILITIES
	// gotcha 4): PlayerPawn.Tick sets Height = FullHeight * crouchfactor, CrouchMove sets viewheight = ViewHeight *
	// crouchfactor. With vr_crouch_use_button 1 crouchfactor comes from the crouch button (CheckCrouch, clamped 0.5..1);
	// with 0 the VR layer OVERWRITES crouchfactor from the head's height every frame (crouching = 10), so a script cannot
	// hold crouchfactor in that mode. What a script CAN hold in both modes is the other factor of the same products: the
	// pawn's standing heights, ViewHeight and FullHeight. So DOWN scales those by m = CROUCH_K / crouchfactor (at most 1):
	// view and hitbox end at 40% of standing whatever the mode, and a player already crouched deeper (button or head)
	// keeps his own depth. Eased over 0.5 s both ways; the view written each tic as CrouchMove writes it. Read nothing
	// local: the same on every machine.
	// 60% LOWER, AND WHY IT IS SAFE (else it would be 50%): (1) the view: CalcHeight never puts the eye below floorz + 4
	// or above ceilingz - 4 (in a liquid with floor clip it sits at floor + 4); the head-tracked mode already lets a player
	// crouch below 0.5 unclamped. (2) collision: a shorter pawn always fits where it stood. (3) getting stuck: rising is
	// only taken a step at a time when the taller pawn fits under the ceiling (else it waits, crawling, as the engine's
	// own uncrouch does). The standing heights are put back EXACTLY (the saved numbers) when the rise ends, on death and
	// at the map's end.
	private void Crouch(int n, PlayerPawn pmo, bool down)
	{
		let p = players[n];
		double target = (down && LowView(n)) ? CROUCH_K : 1.0;
		if (!cOn[n])
		{
			if (target >= 1.0) return;
			cOn[n] = true; cK[n] = 1.0; cVH[n] = pmo.ViewHeight; cFH[n] = pmo.FullHeight; cPawn[n] = pmo; cLogged[n] = 0;
			Log(String.Format("player %d crouch: down to %.0f%% of standing over %d tics (ViewHeight %.1f FullHeight %.1f saved; crouchfactor %.2f, vr_crouch_use_button %s)",
				n, CROUCH_K * 100, CROUCH_TICS, cVH[n], cFH[n], p.crouchfactor, n == consoleplayer ? String.Format("%d", int(Cv("vr_crouch_use_button", 1))) : "?"));
		}
		if (cPawn[n] != pmo) { cOn[n] = false; return; }       // a new pawn (respawn): never touch it
		double cf = max(p.crouchfactor, 0.05);   // the head-height mode can read above 1 (a tall player)
		double step = (1.0 - CROUCH_K) / CROUCH_TICS;
		double k = cK[n];
		double nk = k < target ? min(target, k + step) : max(target, k - step);
		if (nk > k)
		{
			// rising: only when the taller pawn fits under the ceiling here
			double fh = cFH[n] * min(1.0, nk / cf);
			if (pmo.pos.z + fh * cf > pmo.ceilingz)
			{
				if (cLogged[n] != 2) { cLogged[n] = 2; Log(String.Format("player %d crouch: no room to rise (ceiling %.0f over feet %.0f), waiting", n, pmo.ceilingz, pmo.pos.z)); }
				nk = k;
			}
		}
		cK[n] = nk;
		if (nk >= 1.0) { CrouchRestore(n, "risen"); return; }
		double m = min(1.0, nk / cf);
		pmo.ViewHeight = cVH[n] * m;
		pmo.FullHeight = cFH[n] * m;
		pmo.Height = pmo.FullHeight * cf;
		p.viewheight = pmo.ViewHeight * cf;
		p.crouchviewdelta = p.viewheight - pmo.ViewHeight;
		if (nk <= CROUCH_K && cLogged[n] == 0)
		{
			cLogged[n] = 1;
			Log(String.Format("player %d crouch held: view %.1f of %.1f standing, height %.1f of %.1f (crouchfactor %.2f x heights %.2f), crawl x%.2f",
				n, p.viewheight, cVH[n], pmo.Height, cFH[n], cf, m, Crawl(n)));
		}
	}
	private void CrouchRestore(int n, String why)
	{
		if (n < 0 || n >= MAXPLAYERS || !cOn[n]) return;
		cOn[n] = false;
		let pmo = PlayerPawn(cPawn[n]);
		cPawn[n] = null;
		if (!pmo || !pmo.player) return;
		pmo.ViewHeight = cVH[n];
		pmo.FullHeight = cFH[n];
		let p = pmo.player;
		if (pmo.health > 0 && p.playerstate != PST_DEAD)
		{
			pmo.Height = cFH[n] * p.crouchfactor;
			p.viewheight = cVH[n] * p.crouchfactor;
			p.crouchviewdelta = p.viewheight - cVH[n];
		}
		Log(String.Format("player %d crouch restored (%s): ViewHeight %.1f FullHeight %.1f, view %.1f, height %.1f", n, why, pmo.ViewHeight, pmo.FullHeight, p.viewheight, pmo.Height));
	}


	// ---- the hits -----------------------------------------------------------------------------------------------------
	static int PlayerOf(Actor src)
	{
		if (!src) return -1;
		if (!src.player && src.FriendPlayer > 0 && src.FriendPlayer <= MAXPLAYERS) src = players[src.FriendPlayer - 1].mo;
		if (!src || !src.player) return -1;
		return src.PlayerNumber();
	}
	static bool IsFoe(Actor t)
	{
		if (!t || t.player || !t.bISMONSTER || t.bFRIENDLY) return false;
		// Brutal Doom's helpers (head hitboxes and the like: ISMONSTER, -COUNTKILL, 1000+ health) are not monsters
		if (!t.bCOUNTKILL && t.GetSpawnHealth() >= 1000) return false;
		return true;
	}

	// TIME PER WHOLE MONSTER (v3 "clock and bank", "getting up"): by what the monster is, or what it replaces
	static bool KindOf(Actor t, Name base)
	{
		class<Actor> bc = base;
		if (!bc) return false;
		if (t is bc) return true;
		class<Actor> r = Actor.GetReplacee(t.GetClass());
		if (r && r != t.GetClass() && (r is bc)) return true;
		// a modded monster's parents (a BD class that inherits a vanilla one but replaces nothing itself)
		for (class<Object> po = t.GetParentClass(); po; po = po.GetParentClass())
		{
			class<Actor> p = (class<Actor>)(po);
			if (!p) break;
			class<Actor> rp = Actor.GetReplacee(p);
			if (rp && (rp is bc)) return true;
		}
		return false;
	}
	static double SecsPerMonster(Actor t, out String kind)
	{
		if (KindOf(t, 'Cyberdemon') || KindOf(t, 'SpiderMastermind')) { kind = "boss"; return Cv("rsqsm_down_t_boss", 10); }
		if (KindOf(t, 'LostSoul')) { kind = "lost soul"; return Cv("rsqsm_down_t_soul", 0.5); }
		static const Name SMALL[] = { 'ZombieMan', 'ShotgunGuy', 'ChaingunGuy', 'WolfensteinSS', 'DoomImp', 'Demon', 'Spectre' };
		for (int i = 0; i < SMALL.Size(); i++) if (KindOf(t, SMALL[i])) { kind = "small"; return Cv("rsqsm_down_t_small", 1); }
		// my reading: a monster that is none of Doom's and replaces none of them -- small by health (up to an Imp's
		// worth of 150), else above them; a BOSS of 3000+ health counts as the Cyberdemon
		int sh = t.GetSpawnHealth();
		if (t.bBOSS && sh >= 3000) { kind = "boss (unknown)"; return Cv("rsqsm_down_t_boss", 10); }
		if (sh <= 150) { kind = "small (unknown)"; return Cv("rsqsm_down_t_small", 1); }
		kind = "big";
		return Cv("rsqsm_down_t_big", 2);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let t = e.Thing;
		if (!t) return;
		if (t.player) { PlayerHit(e); return; }
		if (!IsFoe(t) || e.Damage <= 0) return;
		int n = PlayerOf(e.DamageSource);
		if (n < 0 || !downOn[n]) return;
		// THE TIME BOUGHT: the damage that landed (never more than the health it had) as a share of its spawn health
		int eff = t.health > 0 ? e.Damage : max(0, e.Damage + t.health);
		int sh = max(1, t.GetSpawnHealth());
		String kind;
		double per = SecsPerMonster(t, kind);
		double add = double(eff) / sh * per * TICRATE;
		double room = max(0.0, ClockTics() - clk[n] - pool[n]);
		double got = min(add, room);
		if (got <= 0) return;
		pool[n] += got;
		Log(String.Format("player %d hit %s (%s, %.1f s a whole one): %d of %d health -> +%.2f s bought (%.2f asked; clock %.2f s, pool %.2f s)",
			n, t.GetClassName(), kind, per, eff, sh, got / TICRATE, add / TICRATE, clk[n] / TICRATE, pool[n] / TICRATE));
		if (got >= 0.05 * TICRATE) Tell("down.time", n, String.Format("+%.1fs", max(0.1, got / TICRATE)), t);
	}

	override void WorldThingDied(WorldEvent e)
	{
		let t = e.Thing;
		if (!t || t.player) return;
		for (int i = 0; i < tMon.Size(); i++)
		{
			if (tMon[i] != t || tDead[i] != 0) continue;
			int n = tPn[i];
			// the killer: the engine hands WorldThingDied only the inflictor (the rig run of 11-07: DamageSource was empty, so
			// no kill counted as his); a missile's shooter is its target
			int by = PlayerOf(e.DamageSource);
			if (by < 0) by = PlayerOf(e.Inflictor);
			if (by < 0 && e.Inflictor) by = PlayerOf(e.Inflictor.target);
			TargetDown(i, by == n);
		}
	}

	private void PlayerHit(WorldEvent e)
	{
		let pmo = e.Thing;
		int n = pmo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS || e.Damage <= 0) return;
		int pre = hpSeen[n];
		let w = RSQSM_DownWatch(pmo.FindInventory("RSQSM_DownWatch"));
		if (w && w.fresh) { pre = w.preHp; w.fresh = false; }
		bool lethal = e.Damage >= pre && pre > 0;
		hpSeen[n] = pmo.health;
		if (!lethal || downOn[n]) return;           // while DOWN the hold keeps him at 1 HP: only the clock ends it
		if (!held[n] || pmo.health != 1) return;
		// WHO IS TO BLAME
		Actor src = e.DamageSource;
		String from = src ? String.Format("%s", src.GetClassName()) : "nothing";
		if (e.Inflictor && e.Inflictor != src) from = from .. String.Format(" via %s", e.Inflictor.GetClassName());
		String no = "";
		String dtype = e.DamageType;
		if (e.DamageType == 'Falling') no = "a fall";
		else if (e.DamageType == 'Crush') no = "a crusher";
		else if (!src) no = e.Inflictor ? "a barrel (or the like) nobody set off" : "no source (a hazard)";
		else if (src.player) no = "his own doing";
		else
		{
			if (!IsFoe(src) && src.master && IsFoe(src.master)) src = src.master;
			if (!IsFoe(src)) no = String.Format("not a monster (%s)", src.GetClassName());
		}
		if (no != "")
		{
			Log(String.Format("player %d: a lethal hit (%d at %d HP from %s, type %s): NO DOWN (%s): the normal death (a Score life may catch it)",
				n, e.Damage, pre, from, dtype, no));
			Hold(n, false);
			pmo.DamageMobj(null, null, pmo.health * 2 + 1, 'None', DMG_NO_ARMOR | DMG_NO_PROTECT | DMG_NO_FACTOR | DMG_THRUSTLESS | DMG_NO_ENHANCE);
			return;
		}
		Start(n, e.Damage, pre, from, src);
	}

	private void Start(int n, int dmg, int pre, String from, Actor src)
	{
		let pmo = players[n].mo;
		let w = RSQSM_DownWatch(pmo.FindInventory("RSQSM_DownWatch"));
		int downs = 1;
		if (w) { w.downs++; downs = w.downs; }
		downOn[n] = true;
		downStart[n] = level.maptime;
		clk[n] = ClockTics();
		pool[n] = 0;
		owed[n] = downs;
		beatNext[n] = level.maptime;
		beatN[n] = 0;
		lastKill[n] = 0;
		stepsGone[n] = 0;
		shakeTic[n] = -100;
		bankHp[n] = 0; bankAr[n] = 0;
		iconsUsed[n] = 0;
		for (int k = 0; k < 3; k++) stepTic[n * 3 + k] = 0;
		Log(String.Format("player %d went DOWN: a lethal hit (%d at %d HP from %s) held at %d HP; DEATH IN %.1f s real, bar %.1f / %.1f / %.1f s, kills owed %d (DOWN %d since a Score life), world to %d%%",
			n, dmg, pre, from, pmo.health, ClockTics() / TICRATE, StepTics() / TICRATE, StepTics() / TICRATE, StepTics() / TICRATE, owed[n], downs, int(DEPTH * 100 + 0.5)));
		pmo.A_StartSound("rsqsm/in", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.8, 10);
		RSQSM_Buzz.Start(pmo, 1, 0.8, 10);
		Tell("down.start", n, "", pmo);
		// TARGET 1: the killer, if in his fight; else a boosted copy of its type, in view at range
		double d = pmo.Distance3D(src);
		bool seen = src.CheckSight(pmo, SF_IGNOREVISIBILITY);
		bool inFight = src.health > 0 && (d <= FIGHT_NEAR || (seen && d <= FIGHT_FAR));
		String cls = src.GetClassName();
		if (inFight) AddTarget(n, src, false, String.Format("the monster that downed him (%.0f units%s)", d, seen ? ", in sight" : ""));
		else
		{
			Log(String.Format("player %d: %s downed him from outside his fight (%s, %.0f units%s): a boosted copy spawns in view", n, cls,
				src.health > 0 ? "alive" : "dead", d, seen ? ", in sight" : ", out of sight"));
			QueueSpawn(n, cls);
		}
		for (int k = 1; k < owed[n]; k++) QueueSpawn(n, cls);
		Spawns();
	}

	// ---- THE TARGETS ----------------------------------------------------------------------------------------------------
	private int DealIcon(int n)
	{
		Array<int> free;
		for (int k = 1; k <= 10; k++) if ((iconsUsed[n] & (1 << k)) == 0) free.Push(k);
		// my reading: more than ten owed in one DOWN -- the ten are dealt again
		if (free.Size() == 0) { iconsUsed[n] = 0; for (int k = 1; k <= 10; k++) free.Push(k); }
		int ic = free[random[RSQSMDn](0, int(free.Size()) - 1)];
		iconsUsed[n] |= 1 << ic;
		return ic;
	}
	private void AddTarget(int n, Actor m, bool spawned, String why, int icon = 0)
	{
		if (icon <= 0) icon = DealIcon(n);
		int col;
		String how;
		[col, how] = Boost(m);
		tMon.Push(m); tPn.Push(n); tIcon.Push(icon); tSpawned.Push(spawned ? 1 : 0); tDead.Push(0); tCol.Push(col);
		tBorn.Push(level.maptime); tDeadTic.Push(0);
		m.target = players[n].mo;
		m.LastHeard = players[n].mo;
		m.bAMBUSH = false;
		Log(String.Format("player %d TARGET %d/%d: %s \"%s\" (%s): icon %d, colour %06X, %s; health %d of %d", n, Count(n), owed[n],
			m.GetClassName(), m.GetTag(), why, icon, col, how, m.health, m.GetSpawnHealth()));
		Tell("down.target", n, String.Format("%06X", col), m);
	}
	private void QueueSpawn(int n, String cls) { spPn.Push(n); spCls.Push(cls); spTries.Push(0); spIcon.Push(DealIcon(n)); }
	int Count(int n) { int k = 0; for (int i = 0; i < tPn.Size(); i++) if (tPn[i] == n) k++; return k; }
	int Killed(int n) { int k = 0; for (int i = 0; i < tPn.Size(); i++) if (tPn[i] == n && tDead[i] != 0) k++; return k; }
	int OwedOf(int n) { return owed[n]; }

	// A SPAWN IN VIEW, AT RANGE: the first free spot along the view (0, then +-12, +-24 ... 60 degrees), far first (640 down
	// to 192 units), on the floor, that the monster fits and that sees him. Retried each tic until SPAWN_TRIES.
	private void Spawns()
	{
		for (int i = spPn.Size() - 1; i >= 0; i--)
		{
			int n = spPn[i];
			if (!downOn[n] || !players[n].mo) { DropSpawn(i); continue; }
			let pmo = players[n].mo;
			Name cnm = spCls[i];
			class<Actor> c = cnm;
			Actor m = c ? SpawnInView(pmo, c, spTries[i]) : null;
			if (m)
			{
				Actor.Spawn("TeleportFog", m.pos, ALLOW_REPLACE);
				AddTarget(n, m, true, String.Format("a boosted copy spawned in view, %.0f units away", pmo.Distance2D(m)), spIcon[i]);
				if (m.SeeState) m.SetState(m.SeeState);
				DropSpawn(i);
				continue;
			}
			if (!c)
			{
				Log(String.Format("player %d: %s is not a class: no spawn", n, spCls[i]));
				DropSpawn(i);
				continue;
			}
			// NO ROOM IN VIEW WITHIN 2 S (owner 11-07 06:23): it spawns OUT of view nearby instead (the turn marker points
			// to it); no kill is ever dropped -- it keeps looking, all round, near first
			if (++spTries[i] >= SPAWN_TRIES)
			{
				m = SpawnNearby(pmo, c, spTries[i] - SPAWN_TRIES);
				if (!m) continue;
				Actor.Spawn("TeleportFog", m.pos, ALLOW_REPLACE);
				AddTarget(n, m, true, String.Format("no room in view after %d tics: spawned out of view nearby, %.0f units away", SPAWN_TRIES, pmo.Distance2D(m)), spIcon[i]);
				if (m.SeeState) m.SetState(m.SeeState);
				DropSpawn(i);
			}
		}
	}
	private int spPnCount(int n) { int k = 0; for (int i = 0; i < spPn.Size(); i++) if (spPn[i] == n) k++; return k; }
	private void DropSpawn(int i) { spPn.Delete(i); spCls.Delete(i); spTries.Delete(i); spIcon.Delete(i); }
	private Actor SpawnInView(PlayerPawn pmo, class<Actor> c, int tryNo)
	{
		static const double DISTS[] = { 640, 512, 384, 288, 192 };
		static const double ANGS[] = { 0, 12, -12, 24, -24, 36, -36, 48, -48, 60, -60 };
		// a few spots a tic (the rest next tic), so the search never costs much
		int total = int(DISTS.Size() * ANGS.Size());
		int j0 = (tryNo * 7) % total;
		for (int k = 0; k < 7; k++)
		{
			int j = (j0 + k) % total;
			int na = int(ANGS.Size());
			double dd = DISTS[j / na], aa = pmo.angle + ANGS[j % na];
			Vector2 xy = pmo.pos.xy + (cos(aa), sin(aa)) * dd;
			if (!level.IsPointInLevel((xy, pmo.pos.z))) continue;
			let m = Actor.Spawn(c, (xy, Actor.ONFLOORZ), ALLOW_REPLACE);
			if (!m) continue;
			if (!m.TestMobjLocation() || !m.CheckSight(pmo, SF_IGNOREVISIBILITY) || abs(m.pos.z - pmo.pos.z) > 256)
			{
				m.ClearCounters();
				m.Destroy();
				continue;
			}
			m.angle = m.AngleTo(pmo);
			return m;
		}
		return null;
	}

	// OUT OF VIEW, NEARBY (the fallback): all round him (every 30 degrees), near first (192 to 640 units), on the floor, where
	// the monster fits; not in sight is fine
	private Actor SpawnNearby(PlayerPawn pmo, class<Actor> c, int tryNo)
	{
		static const double NDISTS[] = { 192, 288, 384, 512, 640 };
		int total = 12 * 5;
		int j0 = (tryNo * 7) % total;
		for (int k = 0; k < 7; k++)
		{
			int j = (j0 + k) % total;
			double dd = NDISTS[j / 12], aa = pmo.angle + 180.0 + (j % 12) * 30.0;
			Vector2 xy = pmo.pos.xy + (cos(aa), sin(aa)) * dd;
			if (!level.IsPointInLevel((xy, pmo.pos.z))) continue;
			let m = Actor.Spawn(c, (xy, Actor.ONFLOORZ), ALLOW_REPLACE);
			if (!m) continue;
			if (!m.TestMobjLocation() || abs(m.pos.z - pmo.pos.z) > 256)
			{
				m.ClearCounters();
				m.Destroy();
				continue;
			}
			m.angle = m.AngleTo(pmo);
			return m;
		}
		return null;
	}

	// THE BOOST. Returns the target's colour (the bar's and the icon's) and what was done.
	static bool ClassLoaded(String n) { Name nm = n; class<Actor> c = nm; return c != null; }
	// the colour of the Champions colour token it carries, -1 none
	static int ChampColour(Actor m)
	{
		// (local: the run of 11-07 06:4x found a class-level static const array unknown inside this static function)
		static const String CH_COLS[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo", "Violet",
			"Pink", "Magenta", "Black", "Grey", "White", "Bronze", "Silver", "Gold" };
		static const int CH_RGB[] = { 0xA01010, 0xFF2828, 0xFF8820, 0xFFE030, 0x20A030, 0x40F040, 0x30E8E8, 0x3868FF, 0x6030C0, 0xB050F0,
			0xFF88C8, 0xFF30FF, 0x707070, 0xB0B0B0, 0xF0F0F0, 0xC08040, 0xD0D0E8, 0xFFC828 };
		for (int i = 0; i < CH_COLS.Size(); i++)
		{
			Name tn = "champion_" .. CH_COLS[i] .. "Token";
			class<Inventory> tc = tn;
			if (tc && m.FindInventory(tc)) return CH_RGB[i];
		}
		return -1;
	}
	private int, String Boost(Actor m)
	{
		bool ld = ClassLoaded("LDLegendaryMonsterPickupGuaranteed"), ch = ClassLoaded("champion_Token");
		int col = DOWN_RED;
		String how;
		bool own = !ld && !ch;
		if (ld)
		{
			Name gn = "LDLegendaryMonsterPickupGuaranteed", tn = "LDLegendaryMonsterToken";
			class<Inventory> g = gn, tk = tn;
			if (g && (!tk || m.CountInv(tk) == 0)) m.GiveInventory(g, 1);
			col = LD_GOLD;       // until its own glow colour is found (LegendColour, its first second; my reading: gold if none)
			how = "LegenDoom legendary (its own guaranteed pickup)";
		}
		if (ch)
		{
			int cc = ChampColour(m);
			if (cc < 0)
			{
				// a champion by a Champions colour token given by name (the ones Champions' own handler acts on by itself:
				// RSQ Miniboss's reading of its code); one at random
				static const String TOK[] = { "Yellow", "White", "DarkGreen", "Cyan" };
				String pick = TOK[random[RSQSMDn](0, TOK.Size() - 1)];
				Name tn = "champion_" .. pick .. "Token";
				class<Inventory> tc = tn;
				if (tc) m.GiveInventory(tc, 1);
				cc = ChampColour(m);
			}
			if (cc >= 0) col = cc;
			how = how .. (how != "" ? " + " : "") .. "Champions champion";
		}
		if (own) how = "our own boost (neither LegenDoom nor Champions loaded): DOWN red";
		// what every target gets: its colour's light, full-bright, larger, +50% (not with LegenDoom: it sets the health)
		if (bMon.Find(m) == bMon.Size())
		{
			bMon.Push(m); bSX.Push(m.Scale.X); bSY.Push(m.Scale.Y); bBright.Push(m.bBRIGHT ? 1 : 0); bOwn.Push(own ? 1 : 0);
			int add = ld ? 0 : max(1, m.GetSpawnHealth() / 2);
			bHp.Push(add);
			m.A_AttachLight('RSQSM_DownMark', DynamicLight.PointLight, Color(255, (col >> 16) & 255, (col >> 8) & 255, col & 255),
				int(max(64, m.radius * 3)), 0, 0, (0, 0, m.Height * 0.6));
			m.bBRIGHT = true;
			if (own) m.A_SetTranslation('RSQSM_DownMark');
			m.A_SetScale(m.Scale.X * MARK_SCALE, m.Scale.Y * MARK_SCALE);
			m.health += add;
			how = how .. String.Format("; light, full-bright, x%.2f size, +%d health", MARK_SCALE, add);
		}
		return col, how;
	}
	// the map's own monster loses its mark and boost (a failed DOWN with a Score life)
	private void Unboost(Actor m)
	{
		int i = bMon.Find(m);
		if (i == bMon.Size() || !m) return;
		m.A_RemoveLight('RSQSM_DownMark');
		m.bBRIGHT = bBright[i] != 0;
		if (bOwn[i]) m.Translation = GetDefaultByType(m.GetClass()).Translation;
		m.A_SetScale(bSX[i], bSY[i]);
		if (m.health > 0) m.health = max(1, m.health - bHp[i]);
		Log(String.Format("%s loses its mark and boost and stays (health %d)", m.GetClassName(), m.health));
		bMon.Delete(i); bSX.Delete(i); bSY.Delete(i); bHp.Delete(i); bBright.Delete(i); bOwn.Delete(i);
	}

	// a target gone without dying (removed by something): a fresh one in its place
	const LD_GOLD = 0xFFC830;
	private void WatchTargets(int n)
	{
		for (int i = 0; i < tMon.Size(); i++)
		{
			if (tPn[i] != n || tDead[i] != 0) continue;
			let m = tMon[i];
			if (m && tCol[i] == LD_GOLD && level.maptime - tBorn[i] < 35 && (level.maptime & 3) == 0) LegendColour(i, m);
			if (m && m.health > 0) continue;
			if (m && m.health <= 0) { TargetDown(i, false); continue; }
			Log(String.Format("player %d: target %d is gone without dying: a fresh one in its place", n, i));
			tDead[i] = 1; tDeadTic[i] = level.maptime - 100;
			owed[n]++;     // the gone one is not a kill: one more owed, its place taken by the fresh one
			String cls = "";
			for (int j = 0; j < tMon.Size(); j++) if (tPn[j] == n && tMon[j]) { cls = tMon[j].GetClassName(); break; }
			if (cls == "") cls = "DoomImp";     // my reading: nothing left to copy -- an Imp
			spPn.Push(n); spCls.Push(cls); spTries.Push(0); spIcon.Push(tIcon[i]);
		}
	}
	// A LEGENDOOM LEGENDARY'S OWN GLOW COLOUR (LegenDoom without Champions): the colour of a stencil-drawn effect actor bound
	// to it (master, tracer or target), read at run time; LegenDoom is not here to parse, so nothing is assumed
	private void LegendColour(int i, Actor m)
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (a == m || (a.master != m && a.tracer != m && a.target != m) || a.bISMONSTER) continue;
			int st = a.GetRenderStyle();
			if (st != STYLE_Stencil && st != STYLE_AddStencil && st != STYLE_Shaded && st != STYLE_AddShaded) continue;
			Color fc = a.fillcolor;
			int c = (fc.r << 16) | (fc.g << 8) | fc.b;
			if (c == 0) continue;
			tCol[i] = c;
			Log(String.Format("%s's own legendary glow colour %06X (from %s)", m.GetClassName(), c, a.GetClassName()));
			return;
		}
	}
	private void TargetDown(int i, bool byHim)
	{
		int n = tPn[i];
		tDead[i] = 1;
		tDeadTic[i] = level.maptime;
		lastKill[n] = level.maptime;
		let m = tMon[i];
		let pmo = players[n].mo;
		int e = level.maptime - downStart[n];
		Log(String.Format("player %d target %s died%s at %.2f s into the bar (%s step): %d of %d owed", n, m ? String.Format("%s", m.GetClassName()) : "?",
			byHim ? " by his hand" : " (not by his hand: no Revenge award)", e / double(TICRATE), TierName(TierAt(e)), Killed(n), owed[n]));
		if (byHim) { Tell("down.revenge", n, "", m); Award(pmo, "Revenge"); }
		if (downOn[n] && Killed(n) >= owed[n] && spPnCount(n) == 0) Revive(n);
	}
	private void DropTarget(int i)
	{
		tMon.Delete(i); tPn.Delete(i); tIcon.Delete(i); tSpawned.Delete(i); tDead.Delete(i); tCol.Delete(i); tBorn.Delete(i); tDeadTic.Delete(i);
	}

	// ---- THE BANK (VisualRewards' bits, "down.bank") -------------------------------------------------------------------
	bool Bank(int n, String what, double amt)
	{
		if (!IsDown(n) || amt <= 0) return false;
		if (what ~== "armor" || what ~== "armour") bankAr[n] += amt; else bankHp[n] += amt;
		Log(String.Format("player %d bank: +%.0f %s -> health %.0f, armour %.0f", n, amt, what, bankHp[n], bankAr[n]));
		return true;
	}
	static bool BankAvailable()
	{
		// (an EventHandler, not an Actor: looked up as any class -- the rig run of 11-07 found the Actor lookup always empty)
		Name hn = 'RSQ_KRHandler';
		class<Object> hc = hn;
		return hc != null && Cv("rsqgb_kr_enabled", 0) != 0;
	}

	// ---- UP (the last target dead) --------------------------------------------------------------------------------------
	private void Revive(int n)
	{
		let pmo = players[n].mo;
		if (!pmo) return;
		int e = (lastKill[n] > 0 ? lastKill[n] : level.maptime) - downStart[n];
		int tier = TierAt(e);
		tierShown[n] = tier;
		End(n, true);
		String tn = TierName(tier);
		static const String INV[] = { "rsqsm_down_inv_top", "rsqsm_down_inv_mid", "rsqsm_down_inv_low" };
		static const String SLO[] = { "rsqsm_down_slow_top", "rsqsm_down_slow_mid", "rsqsm_down_slow_low" };
		static const String SPL[] = { "rsqsm_down_split_top", "rsqsm_down_split_mid", "rsqsm_down_split_low" };
		static const double INVD[] = { 5, 3, 1 };
		static const double SLOD[] = { 3, 1.5, 5 };
		static const double SPLD[] = { 100, 66, 33 };
		double invS = clamp(Cv(INV[tier], INVD[tier]), 0, 30), sloS = clamp(Cv(SLO[tier], SLOD[tier]), 0, 30);
		invulUntil[n] = level.maptime + int(invS * TICRATE);
		// HEALTH AND ARMOUR
		int hp0 = pmo.health, mx = pmo.GetMaxHealth(true);
		let ar = BasicArmor(pmo.FindInventory("BasicArmor"));
		int ar0 = ar ? ar.Amount : 0;
		String src;
		int arCap = int(clamp(Cv("rsqsm_down_bank_armor", 250), 0, 999));
		if (BankAvailable())
		{
			pmo.A_SetHealth(min(mx, hp0 + int(bankHp[n])));
			GiveArmor(pmo, min(arCap, ar0 + int(bankAr[n])));
			src = String.Format("the bits bank (%.0f health, %.0f armour banked)", bankHp[n], bankAr[n]);
		}
		else
		{
			double k = clamp(Cv(SPL[tier], SPLD[tier]), 0, 100) / 100.0;
			pmo.A_SetHealth(max(hp0, int(round(mx * k))));
			// my reading: the armour share is of a green armour's 100
			GiveArmor(pmo, max(ar0, int(round(100 * k))));
			src = String.Format("no bank (VisualRewards' Kill Rewards not loaded or off): the tier split %d%%", int(k * 100 + 0.5));
		}
		ar = BasicArmor(pmo.FindInventory("BasicArmor"));
		String rl = ReloadHeld(pmo);
		Log(String.Format("player %d UP (REVIVE), %s tier (the last kill %.2f s into the bar): invulnerable %.1f s, slow motion %.1f s; health %d -> %d (max %d), armour %d -> %d from %s; both held guns: %s",
			n, tn, e / double(TICRATE), invS, sloS, hp0, pmo.health, mx, ar0, ar ? ar.Amount : 0, src, rl));
		pmo.A_StartSound("rsqsm/out", CHAN_AUTO, CHANF_LOCAL, 1.0);
		pmo.A_StartSound("misc/p_pkup", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.7, 8);
		RSQSM_Buzz.Start(pmo, 1, 0.7, 8);
		Tell("down.up", n, tn, pmo);
		if (tier == 0)
		{
			Tell("down.revive", n, "", pmo);                      // Tactical Rig +1 cigarette, Grenade +1 grenade (top only)
			let it = ServiceIterator.Find("RS_ScoreService");
			Service sv;
			while (sv = it.Next()) if (sv.GetClassName() == 'RS_ScoreService') Log(String.Format("RSQ Score's Revival Fire: %d", sv.GetInt("revivefire", "", 0, 0, pmo)));
		}
		let c = RSQSM_Clock.Get();
		if (c && sloS > 0)
		{
			bool ok = c.Trigger("down.up", RSQSM_Clock.CAT_NONE, int(sloS * 1000), c.Depth(), false, n, "REVIVE");
			Log(String.Format("player %d revive slow motion %.1f s: %s", n, sloS, ok ? "started" : "refused (see the clock's line)"));
		}
	}
	static void GiveArmor(Actor pmo, int amt)
	{
		let ar = BasicArmor(pmo.FindInventory("BasicArmor"));
		if (!ar || amt <= ar.Amount) return;
		ar.Amount = amt;
		ar.MaxAmount = max(ar.MaxAmount, amt);
		if (ar.SavePercent <= 0) ar.SavePercent = 0.33335;
		if (ar.ArmorType == 'None') ar.ArmorType = 'GreenArmor';
	}

	private void Fail(int n, String why)
	{
		let pmo = players[n].mo;
		End(n, false);
		Tell("down.fail", n, why, pmo);
		if (!pmo || pmo.health <= 0) { Log(String.Format("player %d: DOWN failed (%s): dead", n, why)); return; }
		int hp = pmo.health;
		pmo.DamageMobj(null, null, hp * 2 + 1, 'None', DMG_NO_ARMOR | DMG_NO_PROTECT | DMG_NO_FACTOR | DMG_THRUSTLESS | DMG_NO_ENHANCE);
		bool lived = pmo.health > 0;
		Log(String.Format("player %d: DOWN failed (%s): the killing blow at %d HP -> health %d (%s)", n, why, hp, pmo.health,
			lived ? "a Score life holds him" : "dead"));
		if (!lived) return;
		// FAILING WITH A SCORE LIFE: the spawned targets go in teleport fog; the map's own killer loses its mark and stays
		for (int i = 0; i < tMon.Size(); i++)
		{
			if (tPn[i] != n || tDead[i] != 0) continue;
			let m = tMon[i];
			tDead[i] = 1; tDeadTic[i] = level.maptime - 100;
			if (!m) continue;
			if (tSpawned[i] != 0)
			{
				Actor.Spawn("TeleportFog", m.pos, ALLOW_REPLACE);
				Log(String.Format("player %d: the spawned target %s despawns in teleport fog", n, m.GetClassName()));
				int bi = bMon.Find(m);
				if (bi < bMon.Size()) { bMon.Delete(bi); bSX.Delete(bi); bSY.Delete(bi); bHp.Delete(bi); bBright.Delete(bi); bOwn.Delete(bi); }
				m.ClearCounters();
				m.Destroy();
			}
			else Unboost(m);
		}
		for (int i = spPn.Size() - 1; i >= 0; i--) if (spPn[i] == n) DropSpawn(i);
	}

	private void End(int n, bool revived)
	{
		downOn[n] = false;
		endTic[n] = level.maptime;
		endHow[n] = revived ? 1 : 2;
		Hold(n, false);
		let c = RSQSM_Clock.Get();
		if (c) c.freeUntil[n] = max(c.freeUntil[n], level.maptime + int(c.RampOut() * TICRATE) + 2);
	}

	// BOTH HELD GUNS RELOADED FOR FREE (v3): each held weapon's magazine (its Ammo2, when that is a magazine: no weapon uses
	// it as its first ammo; BD22 VR) filled to its MaxAmount, never taken from the reserve. A gun without a magazine
	// (vanilla) has nothing to reload (my reading).
	private transient Array<Name> reserves;
	private transient bool reservesBuilt;
	private void BuildReserves()
	{
		reservesBuilt = true;
		reserves.Clear();
		for (int i = 0; i < AllActorClasses.Size(); i++)
		{
			class<Weapon> wc = (class<Weapon>)(AllActorClasses[i]);
			if (!wc) continue;
			let d = GetDefaultByType(wc);
			if (d.AmmoType1) { Name nm = d.AmmoType1.GetClassName(); if (reserves.Find(nm) == reserves.Size()) reserves.Push(nm); }
		}
	}
	String ReloadHeld(Actor pmo)
	{
		if (!reservesBuilt) BuildReserves();
		String what = "";
		for (int h = 0; h < 2; h++)
		{
			let w = h == 0 ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
			String nm = h == 0 ? "main" : "off";
			if (!w) { what = what .. String.Format("%s%s: none", what == "" ? "" : "; ", nm); continue; }
			if (h == 1 && w == pmo.player.ReadyWeapon) continue;
			if (!w.Ammo1 || !w.Ammo2 || w.Ammo1.GetClass() == w.Ammo2.GetClass() || reserves.Find(w.Ammo2.GetClassName()) < reserves.Size())
			{
				what = what .. String.Format("%s%s %s: no magazine", what == "" ? "" : "; ", nm, w.GetClassName());
				continue;
			}
			int was = w.Ammo2.Amount, res = w.Ammo1.Amount;
			w.Ammo2.Amount = w.Ammo2.MaxAmount;
			what = what .. String.Format("%s%s %s %s %d -> %d (reserve %s %d untouched)", what == "" ? "" : "; ", nm, w.GetClassName(),
				w.Ammo2.GetClassName(), was, w.Ammo2.Amount, w.Ammo1.GetClassName(), res);
		}
		return what;
	}

	// ---- telling the others, by name ---------------------------------------------------------------------------------
	static void Tell(String what, int n, String s, Actor a)
	{
		let it = ServiceIterator.Find("RSQDownJoin");
		Service sv;
		int k = 0;
		while (sv = it.Next()) { sv.GetInt(what, s, n, 0, a); k++; }
		if (what != "down.time") Log(String.Format("told %d joined mod(s): %s %s", k, what, s));
	}
	static void Award(Actor who, String label)
	{
		let it = ServiceIterator.Find("RS_ScoreService");
		Service sv;
		while (sv = it.Next())
		{
			if (sv.GetClassName() != 'RS_ScoreService') continue;
			int r = sv.GetInt("award", label, 1, 0, who);
			Log(String.Format("RSQ Score award \"%s\": %d", label, r));
		}
	}
}

// HIS HEALTH JUST BEFORE A HIT (passive), the invulnerability after getting up (passive: no damage taken), the crawl
// (GetSpeedFactor: the engine's own speed path, as PowerSpeed), and the DOWNs since the last Score life (travels with him).
class RSQSM_DownWatch : Inventory
{
	int preHp;
	bool fresh;
	int downs;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		newdamage = damage;
		if (!Owner || !Owner.player || !passive) return;
		let d = RSQSM_Down.Get();
		if (d && damage > 0 && d.Invul(Owner.PlayerNumber()))
		{
			newdamage = 0;
			return;
		}
		preHp = Owner.health; fresh = true;
	}
	override double GetSpeedFactor()
	{
		if (!Owner || !Owner.player) return 1;
		let d = RSQSM_Down.Get();
		return d ? d.Crawl(Owner.PlayerNumber()) : 1;
	}
}
