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
//            thin. It drains smoothly; no step breaks off (owner 11-07 07:07). Bought time never stretches it. The step
//            you are in when the LAST target dies is the tier. Killing one target while others remain RESETS the bar to
//            full (owner 11-07 06:35): a fast bright refill sweep left to right (REFILL_TICS); the bar drains again once
//            the sweep is done. The DEATH IN clock is not reset.
//  TARGETS   ONE kill owed, always (owner 11-12 04:17; it was 1 + the DOWNs since the last Score life spent). Those DOWNs
//            (RSQSM_DownWatch.downs travels with you; the count goes back when Score's life count drops) shorten the
//            clock you start with instead: 9 s, then 6, then 3 (StartShare), so the bar starts 2/3 or 1/3 full; damage
//            to any monster buys it back up. The other monsters in sight carry a small crosshair and what a whole one
//            is worth (plate.zs BonusTick). The "extra target" lines below describe a case that no longer arises. Target 1: the monster that downed you if it is in your fight
//            (alive, and within FIGHT_NEAR, or in sight within FIGHT_FAR), else a boosted copy of its type spawned in view at
//            range. Every extra target: a fresh boosted copy of that type spawned in view. Boost by what is loaded:
//            LegenDoom + Champions: a legendary (LegenDoom's own guaranteed pickup) champion; LegenDoom alone: legendary;
//            Champions alone: a champion; neither: our own (DOWN red tint). A SPAWNED target with Champions is a REAL
//            Champion made by Champions itself (owner 11-07 11:0x): Champions makes champions only as monsters spawn (its
//            handler's WorldThingSpawned: its own chance, colour weights, mutations), so hidden candidates are spawned on the
//            spot and the first it makes a champion is the target (Placed / ChampRoll). The map's own monster that downed
//            you, in his fight: a champion already stays one; else (owner 11-07 11:1x) it vanishes in teleport fog and a
//            REAL Champion copy of it, made the same way, appears where it stood (SwapKiller; its tid and special go with it). All of them: a light in their colour, full-bright, 15% larger, +50% health (not with
//            LegenDoom: it sets a legendary's health). Each target gets one of ten icons (random, never twice in a DOWN).
//  UP        the last target dead: up at once. REVIVE every time (VisualRewards, sized by tier). Tier top / middle / bottom:
//            invulnerable 5 / 3 / 1 s, slow motion 3 / 1.5 / 5 s; top: Score's Revival Fire, +1 cigarette (Tactical Rig),
//            +1 grenade (Grenade). Health and armour: the bits bank (VisualRewards' Kill Rewards, kills while DOWN fly into
//            the plate), up to max health and 250 armour; no bank (VisualRewards not loaded or Kill Rewards off): the tier
//            split 100 / 66 / 33 %. Both held guns' magazines filled for free (never from the reserve). No RAGE, no Scar, no
//            Cooldown, no crate, no "Revive" award ("Revenge" stays: each target you kill).
//  FAIL      the clock at zero. With a Score life: the spawned targets go in teleport fog, the map's own monster loses its
//            mark and boost and stays. Without: dead.
//  PANEL     downhud.zs: the panel (Target lines, bar, DEATH IN) and the edge arrows on the HUD layer (owner 07:50), to the
//            approved mockup (design/mockups); plate.zs: the crosshairs on the targets and the eye-level trail, in the
//            world. Console player only.
//  NETPLAY   each player has his own DOWN; the world's slow-down is the clock's, shared as every slow motion is.
//  THE LOOK  (owner 2026-11-09 17:42-17:45; downlook.zs) going down is a slow-mo moment: the view eases down over DROP_TICS
//            (an ease in and out, not a snap) and the player himself is slowed through it (clock.zs SlowMe asks DropK);
//            the world goes black and white with a blood-red tint (each sector's own light colour and desaturation,
//            eased; console player only), the targets' small rooms stay in colour, the crosshairs and trail are drawn
//            as full-bright particles while the world is grey (the engine never desaturates those); DarkDoomZ drops to
//            DarkDoom Black (single player); our own sounds: a heavy hit and a ringing, a heartbeat, a relief on getting
//            up. The DEATH IN panel appears big in the middle of the view and sinks to its place (downhud.zs).
//
// JOINING (by name): every Service whose class name contains "RSQDownJoin" is told GetInt(event, stringArg, player, 0,
// actor): "down.start" (pawn), "down.target" (a target monster; stringArg its colour "RRGGBB"), "down.time" (the monster
// hit; "+0.4s"), "down.revenge" (a target killed by him), "down.up" (pawn; "top" / "middle" / "bottom": every revive),
// "down.revive" (pawn; TOP tier only: Tactical Rig's cigarette and Grenade's grenade answer it), "down.fail" (pawn; why).
// RSQSM_Service answers "down" / "down.hold" / "down.any" / "down.redmap" / "down.left" (intArg player), "down.mark"
// (objectArg a monster: 1 while it is a living DOWN target), "down.bank" (play: stringArg "health" / "armor", intArg
// player, doubleArg amount -> 1 banked) and GetObject "down.plate" (intArg player -> null since 11-07 07:50: the panel is HUD, the bits fly to the player).
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
	const REFILL_TICS = 10;    // the bar's refill sweep after a kill with targets left ("fast": my number, ~0.3 s)
	const DROP_TICS = 35;      // going down (owner 11-09 17:44: "a slow-mo moment", ~1 s real): the view's ease and the slow fall
	const DROP_SLOW = 0.2;     // the player's own speed at the start of the fall, easing back to full (my number)
	const ENTRY_HOLD = 35;     // Death In Entrance, Middle Then Sink: tics it holds big in the middle (~1 s, the drop)
	const ENTRY_GLIDE = 14;    // then tics it takes to glide down to its place (my number, ~0.4 s)
	const RING_SLOT = 7101;    // the ringing's own sound slot (stopped when you get up)

	// ---- synced (in the save) ----------------------------------------------------------------------------------------
	bool   downOn[MAXPLAYERS];
	int    downStart[MAXPLAYERS];                        // maptime (real time: never slowed)
	int    barStart[MAXPLAYERS];                         // maptime the bar (re)starts draining: the DOWN, or a reset's end
	int    refillTic[MAXPLAYERS], refillOldE[MAXPLAYERS];   // the last reset: when, and how far the bar had drained
	double clk[MAXPLAYERS], pool[MAXPLAYERS];           // DEATH IN, and the bought time still to pour in (tics)
	int    owed[MAXPLAYERS];
	int    beatNext[MAXPLAYERS], beatN[MAXPLAYERS];
	bool   held[MAXPLAYERS];
	int    endTic[MAXPLAYERS], endHow[MAXPLAYERS];       // 1 revived, 2 failed
	int    lastKill[MAXPLAYERS];
	int    lastKillE[MAXPLAYERS];                        // how much of the Clock was gone at that kill (the tier)
	double bankHp[MAXPLAYERS], bankAr[MAXPLAYERS];
	int    invulUntil[MAXPLAYERS];
	int    livesSeen[MAXPLAYERS];
	int    iconsUsed[MAXPLAYERS];                        // bit mask of the icons dealt this DOWN
	int    tierShown[MAXPLAYERS];
	// the targets (all players, in parallel)
	Array<Actor> tMon;
	Array<int>   tPn, tIcon, tSpawned, tDead, tCol, tBorn, tDeadTic;   // tDead 1 died, 2 gone without dying (no line)
	Array<String> tName;                                  // the plate's name for it (RSQ Score's "monster.name", else its tag)
	// the boosts (to take back from a map monster when a DOWN fails with a Score life)
	Array<Actor> bMon;
	Array<double> bSX, bSY;
	Array<int>   bHp, bBright, bOwn;
	// spawns still looking for a spot
	Array<int>   spPn, spTries, spIcon;
	Array<String> spCls;
	// with Champions loaded (owner 11-07 11:0x: REAL Champions, made by Champions itself): the spot a spawn found, and the
	// hidden candidates Champions rolls on as new spawns (Champions' own handler, WorldThingSpawned)
	Array<int>   spId, spHave, spRolls;
	Array<double> spX, spY, spZ, spAng;
	Array<String> spWhy;
	int          spNextId;
	Array<Actor> cdMon;
	Array<int>   cdId;
	// THE BONUS MONSTERS (owner 11-12 05:50: "of the closest 20 monsters lets say 10 have +0.X Sec, but as you kill one,
	// another is assigned its place so there is always 10"): only THESE (and the target) buy clock time. Chosen in play
	// (every machine the same), drawn by plate.zs.
	Array<Actor> bnMon;
	Array<int>   bnPn;
	const BONUS_MAX = 10;
	const BONUS_POOL = 20;
	const BONUS_REACH = 2048.0;
	clearscope bool IsBonus(int n, Actor a) { for (int i = 0; i < bnMon.Size(); i++) if (bnMon[i] == a && bnPn[i] == n) return true; return false; }
	private void BonusStep(int n, PlayerPawn pmo)
	{
		int have = 0;
		for (int i = bnMon.Size() - 1; i >= 0; i--)
		{
			if (bnPn[i] != n) continue;
			let a = bnMon[i];
			if (!a || a.health <= 0 || IsTarget(a)) { bnMon.Delete(i); bnPn.Delete(i); continue; }
			have++;
		}
		if (have >= BONUS_MAX) return;
		// the nearest BONUS_POOL living monsters he can see, nearest first
		Array<Actor> pool; Array<double> pd;
		let it = BlockThingsIterator.Create(pmo, BONUS_REACH);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a.health <= 0 || !IsFoe(a) || a.bDORMANT || IsTarget(a) || IsBonus(n, a)) continue;
			double d = pmo.Distance3D(a);
			if (d > BONUS_REACH || !pmo.CheckSight(a, SF_IGNOREVISIBILITY)) continue;
			int at = pd.Size();
			while (at > 0 && pd[at - 1] > d) at--;
			if (at >= BONUS_POOL) continue;
			pool.Insert(at, a); pd.Insert(at, d);
			if (pool.Size() > BONUS_POOL) { pool.Pop(); pd.Pop(); }
		}
		while (have < BONUS_MAX && pool.Size() > 0)
		{
			int k = random[RSQSMDn](0, int(pool.Size()) - 1);
			bnMon.Push(pool[k]); bnPn.Push(n);
			Log(String.Format("player %d bonus monster %d of %d: %s (%s)", n, have + 1, BONUS_MAX, pool[k].GetClassName(), WorthLabel(pool[k])));
			pool.Delete(k); pd.Delete(k);
			have++;
		}
	}
	Array<int>   tHurt;                                   // 1: he has damaged this target in this DOWN (a target swapped out for another actor then counts as his kill)
	Array<int>   tChWait;                                 // 1: a real champion whose colour token Champions has not given yet
	// the killer swapped for a real Champion copy (owner 11-07 11:1x): the map's monster that downed him (not a champion,
	// Champions loaded), its map tid and special handed to the copy; spSwapK 1 for such a spawn (it stands for the map's own)
	Array<Actor> spSwap;
	Array<int>   spSwapK, spTid, spSpec, spArg;           // spArg: five a spawn
	// the crouch
	bool   cOn[MAXPLAYERS];
	double cK[MAXPLAYERS], cVH[MAXPLAYERS], cFH[MAXPLAYERS];
	Actor  cPawn[MAXPLAYERS];
	int    cLogged[MAXPLAYERS];
	// THE BLACK AND WHITE WORLD (downlook.zs): the CONSOLE PLAYER's view only, so these differ machine to machine by design
	// (nothing the game reads: a sector's light colour and desaturation are drawn, never simulated). Saved with the game so
	// a save made mid-DOWN still puts every sector's own colour back exactly.
	double gwMix;                                         // 0 colour .. 1 grey (eased)
	int    gwN;                                           // sectors held (0: none)
	int    gwQ;                                           // the last step written
	int gwSeed;                                           // the tic the grey world was captured (Fog Colour Random's pick)
	Array<int> gwFade, gwLastFade;                         // each sector's own fade (fog) colour; what we last wrote (the red haze)
	Array<int> gwCol, gwDes, gwLastCol, gwLastDes;        // each sector's own light colour and desaturation; what we last wrote
	Array<double> gwIsl;                                  // each sector: 0 grey .. 1 a target's room kept in colour
	Array<int> gwIslOn;                                   // the sectors with an island now
	bool   ddzOn; int ddzHeld;                            // DarkDoomZ's own ddz_mode while DOWN holds it at DarkDoom Black
	transient Array<double> gwSize;                       // each sector's widest side (its lines' box), for Small Rooms

	// ---- this tic ----------------------------------------------------------------------------------------------------
	private transient int hpSeen[MAXPLAYERS];
	transient RSQSM_Plate plate;                          // the console player's crosshairs and trail (plate.zs); rebuilt after a load
	transient ui RSQSM_DownHud hud;                       // the panel and the edge arrows on the HUD layer (downhud.zs)
	override void RenderOverlay(RenderEvent e)
	{
		if (!hud) hud = new("RSQSM_DownHud");
		hud.Draw(self, e);
	}

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
	static clearscope double StartShare(int downs) { return downs <= 1 ? 1.0 : (downs == 2 ? 2.0 / 3.0 : 1.0 / 3.0); }
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
	// the bar: elapsed real tics into this DOWN, and the tier it stands at (0 top, 1 middle, 2 bottom)
	// THE BAR IS THE CLOCK (owner 11-11 23:56: "the draining meter has to line up with the timer, and account for when we
	// get time added to it"): the bar shows DEATH IN itself -- full at the Clock, empty at zero, rising as bought time
	// pours in -- and its three steps are thirds of the Clock. Was: a separate 3 x Bar Step gauge that drained by the tics
	// since the DOWN (or since a target's death reset it) and never saw bought time, so the two drifted apart.
	// Elapsed is how much of the Clock is gone; the tier is the third DEATH IN stands in.
	clearscope int Elapsed(int n) { return IsDown(n) ? int(clamp(ClockTics() - clk[n], 0.0, ClockTics())) : 0; }
	clearscope int TierAt(int e) { double s = ClockTics() / 3.0; return e < s ? 0 : (e < 2 * s ? 1 : 2); }
	double Crawl(int n)
	{
		if (!IsDown(n) || !players[n].mo) return 1.0;
		double cf = players[n].crouchfactor;
		double eng = (cf != 1) ? clamp(cf, 0.5, 1.0) : 1.0;
		return CRAWL_K / eng;
	}
	clearscope bool Invul(int n) { return n >= 0 && n < MAXPLAYERS && invulUntil[n] > level.maptime; }
	// GOING DOWN (owner 11-09 17:44): how far into the fall, 0..1 eased in and out (1 once it is over)
	clearscope double DropEase(int n)
	{
		if (!IsDown(n)) return 1.0;
		double p = clamp((level.maptime - downStart[n]) / double(DROP_TICS), 0.0, 1.0);
		return p * p * (3.0 - 2.0 * p);
	}
	// the player's own speed through the fall (clock.zs SlowMe): DROP_SLOW easing back to full; full once it is over or
	// with the Slow Fall row off. Synced numbers only: the same on every machine.
	double DropK(int n)
	{
		if (!IsDown(n) || Cv("rsqsm_down_slowfall", 1) == 0) return 1.0;
		if (level.maptime - downStart[n] >= DROP_TICS) return 1.0;
		return DROP_SLOW + (1.0 - DROP_SLOW) * DropEase(n);
	}
	// the tic after going down when the panel comes to rest (the thump in both hands): Death In Entrance 0 Middle Then
	// Sink, 1 Bottom Only, 2 Slam Up
	static clearscope int LandTic(int entry)
	{
		if (entry == 1) return 1;
		if (entry == 2) return RSQSM_DownHud.SLAM;
		return ENTRY_HOLD + ENTRY_GLIDE;
	}
	static clearscope bool AudioOn(int n) { return CvP("rsqsm_down_audio", n, 1) != 0; }

	override void WorldLoaded(WorldEvent e)
	{
		// THE TIME ROWS' NEW DEFAULTS (owner 11-12 04:22: 0.5 and 0.25 s): a config saved under the old ones (1 / 0.5 / 2 /
		// 10 s) still holds them, so once per config the four rows are set to the new defaults; after that they are his.
		let mc = CVar.FindCVar("rsqsm_down_cfg");
		if (mc && mc.GetInt() < 1)
		{
			static const String ROW[] = { "rsqsm_down_t_small", "rsqsm_down_t_soul", "rsqsm_down_t_big", "rsqsm_down_t_boss" };
			static const double VAL[] = { 0.25, 0.25, 0.5, 0.5 };
			for (int i = 0; i < 4; i++) { let c = CVar.FindCVar(ROW[i]); if (c) c.SetFloat(VAL[i]); }
			mc.SetInt(1);
		}
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
		tMon.Clear(); tPn.Clear(); tIcon.Clear(); tSpawned.Clear(); tDead.Clear(); tCol.Clear(); tBorn.Clear(); tDeadTic.Clear(); tName.Clear(); tHurt.Clear(); bnMon.Clear(); bnPn.Clear();
		bMon.Clear(); bSX.Clear(); bSY.Clear(); bHp.Clear(); bBright.Clear(); bOwn.Clear();
		spPn.Clear(); spTries.Clear(); spIcon.Clear(); spCls.Clear();
		spId.Clear(); spHave.Clear(); spRolls.Clear(); spX.Clear(); spY.Clear(); spZ.Clear(); spAng.Clear(); spWhy.Clear();
		spSwap.Clear(); spSwapK.Clear(); spTid.Clear(); spSpec.Clear(); spArg.Clear();
		cdMon.Clear(); cdId.Clear(); tChWait.Clear();
		// the look: a new map starts in its own colours (the last map gave every sector back as it ended); a DarkDoomZ
		// darkness left behind by a quit or crash mid-DOWN goes back
		GreyForget();
		DdzRecover();
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
		// the look: every sector's own colour back exactly (before a hub keeps the map), DarkDoomZ's own mode back
		GreyRelease("the map ends");
		DdzLet("the map ends");
		gone = true;     // the level is over: no tic of this handler may touch the travelling pawn again
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
					else
					{
						Heartbeat(n); WatchTargets(n);
						// THE PANEL LANDS (owner 07:55: it slams up, "a heavy controller thump"): both hands, full, as it lands
						if (level.maptime - downStart[n] == LandTic(int(CvP("rsqsm_down_entry", n, 0))))
						{
							RSQSM_Buzz.Start(pmo, 0, 1.0, 7);
							RSQSM_Buzz.Start(pmo, 1, 1.0, 7);
							Log(String.Format("player %d: the panel landed (thump: both hands, 1.0, 7 tics)", n));
						}
					}
				}
			}
			if (pmo.health <= 0 || players[n].playerstate == PST_DEAD) CrouchRestore(n, "he is dead");
			else Crouch(n, pmo, downOn[n]);
			if (downOn[n] && (level.maptime + n) % 6 == 0) BonusStep(n, pmo);
			else if (!downOn[n] && bnMon.Size()) { for (int bi = bnMon.Size() - 1; bi >= 0; bi--) if (bnPn[bi] == n) { bnMon.Delete(bi); bnPn.Delete(bi); } }
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
		// THE LOOK (downlook.zs): the console player's grey world and DarkDoomZ
		LookTick();
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

	// THE RESET (owner 11-07 06:35): a target killed while others remain -- the bar back to full with a fast bright refill
	// sweep (plate.zs draws it); it drains again from full once the sweep is done. No step ever breaks off (owner 07:07).
	private void BarReset(int n)
	{
		// (11-11: the bar is the clock now, and DEATH IN was never reset by a kill, so nothing refills here; the time a
		// kill buys still pours into the clock, and the bar rises with it)
		int e = Elapsed(n);
		Log(String.Format("player %d a target killed, %d of %d owed: the bar stays with DEATH IN (%.2f s left, %s step; no refill)",
			n, Killed(n), owed[n], clk[n] / TICRATE, TierName(TierAt(e))));
	}
	static clearscope String TierName(int t) { return t == 0 ? "top" : (t == 1 ? "middle" : "bottom"); }

	private void Heartbeat(int n)
	{
		if (level.maptime < beatNext[n]) return;
		let pmo = players[n].mo;
		double l = clk[n] / max(1.0, ClockTics());
		beatNext[n] = level.maptime + int(12 + 14 * clamp(l, 0.0, 1.0));
		beatN[n]++;
		// OUR OWN HEARTBEAT (owner 11-09 17:45, Audio Cues): a lub-dub (tools/down_audio), faster as DEATH IN runs down (the
		// gap above) and a little higher and louder too
		if (AudioOn(n))
		{
			double u = 1.0 - clamp(l, 0.0, 1.0);
			pmo.A_StartSound("rsqsm/dnbeat", CHAN_AUTO, CHANF_LOCAL, 0.7 + 0.3 * u, ATTN_NONE, 1.0 + 0.15 * u);
			RSQSM_Buzz.Start(pmo, 0, 0.35, 3);
			RSQSM_Buzz.Start(pmo, 1, 0.35, 3);
			return;
		}
		bool bd = S_GetLength("heartbeat1") > 0;
		if (bd)pmo.A_StartSound((beatN[n] & 1) ? "heartbeat1" : "heartbeat2", CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
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
		// GOING DOWN (owner 11-09 17:44: "it just shock-drops me"): the fall eases in and out over DROP_TICS (~1 s real),
		// not a straight 0.5 s line; rising stays as it was
		if (down && target < 1.0 && level.maptime - downStart[n] <= DROP_TICS)
			nk = min(k, max(target, 1.0 - (1.0 - CROUCH_K) * DropEase(n)));
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
		// STANDING IN A LIQUID (owner 11-11 23:56: "sometimes i am lowered outside of the map when i stand in liquid with MTO
		// liquids"): a liquid's foot clip (MTO Liquids' TERRAIN: 10 units) comes off the eye as well, so the 40% view sat
		// near the floor there and a small lean took the head through it. The lowered part of the drop gives the foot clip
		// back (none of it standing, all of it fully down), so the eye is 40% of standing above the liquid's floor.
		double fcBack = pmo.Floorclip > 0 ? pmo.Floorclip * clamp((1.0 - nk) / (1.0 - CROUCH_K), 0.0, 1.0) / cf : 0.0;
		pmo.ViewHeight = cVH[n] * m + fcBack;
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
	// A WHOLE MONSTER'S WORTH OF CLOCK, AS ITS LABEL (plate.zs, the bonus marks): "+1 SEC", "+0.5 SEC"
	static String WorthLabel(Actor t)
	{
		String kind;
		double per = SecsPerMonster(t, kind);
		String v = String.Format("%.2f", per);
		while (v.Length() > 1 && v.Mid(v.Length() - 1, 1) == "0") v = v.Left(v.Length() - 1);
		if (v.Mid(v.Length() - 1, 1) == ".") v = v.Left(v.Length() - 1);
		return String.Format("+%s SEC", v);
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
		if (KindOf(t, 'Cyberdemon') || KindOf(t, 'SpiderMastermind')) { kind = "boss"; return Cv("rsqsm_down_t_boss", 0.5); }
		if (KindOf(t, 'LostSoul')) { kind = "lost soul"; return Cv("rsqsm_down_t_soul", 0.25); }
		static const Name SMALL[] = { 'ZombieMan', 'ShotgunGuy', 'ChaingunGuy', 'WolfensteinSS', 'DoomImp', 'Demon', 'Spectre' };
		for (int i = 0; i < SMALL.Size(); i++) if (KindOf(t, SMALL[i])) { kind = "small"; return Cv("rsqsm_down_t_small", 0.25); }
		// my reading: a monster that is none of Doom's and replaces none of them -- small by health (up to an Imp's
		// worth of 150), else above them; a BOSS of 3000+ health counts as the Cyberdemon
		int sh = t.GetSpawnHealth();
		if (t.bBOSS && sh >= 3000) { kind = "boss (unknown)"; return Cv("rsqsm_down_t_boss", 0.5); }
		if (sh <= 150) { kind = "small (unknown)"; return Cv("rsqsm_down_t_small", 0.25); }
		kind = "big";
		return Cv("rsqsm_down_t_big", 0.5);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let t = e.Thing;
		if (!t) return;
		if (t.player) { PlayerHit(e); return; }
		if (!IsFoe(t) || e.Damage <= 0) return;
		int n = PlayerOf(e.DamageSource);
		if (n < 0 || !downOn[n]) return;
		for (int i = 0; i < tMon.Size(); i++) if (tMon[i] == t && tPn[i] == n) tHurt[i] = 1;
		// only his target and his bonus monsters buy time (owner 11-12 05:50)
		if (!IsTarget(t) && !IsBonus(n, t)) return;
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
		DownMusic(n, true);
		downStart[n] = level.maptime;
		barStart[n] = level.maptime;
		refillTic[n] = -1000; refillOldE[n] = 0;
		// ONE TARGET, A SHORTER CLOCK (owner 2026-11-12 04:17: "instead of increasing the number of kills, let's say you start
		// with 9 seconds, then your next down is 6 seconds, then your third down and beyond is 3 seconds. our segmented bar
		// let's us only need to draw it 2 / 3 or 1 / 3 full"): every DOWN owes ONE kill, the monster that downed you (or its
		// copy). The DOWNs since the last Score life spent shorten the clock you START with instead: all of it, two thirds,
		// one third (StartShare). The bar and the tier already read the clock (downhud.zs fill = clk / ClockTics, TierAt), so
		// it starts two thirds or one third full, in the middle or bottom step, and the time your damage buys (any monster,
		// up to the whole clock) lifts it back into a better step before the kill.
		clk[n] = ClockTics() * StartShare(downs);
		pool[n] = 0;
		owed[n] = 1;
		beatNext[n] = level.maptime;
		beatN[n] = 0;
		lastKill[n] = 0; lastKillE[n] = 0;
		bankHp[n] = 0; bankAr[n] = 0;
		iconsUsed[n] = 0;
		Log(String.Format("player %d went DOWN: a lethal hit (%d at %d HP from %s) held at %d HP; DEATH IN %.1f s real, bar %.1f / %.1f / %.1f s, kills owed %d (DOWN %d since a Score life), world to %d%%",
			n, dmg, pre, from, pmo.health, clk[n] / TICRATE, StepTics() / TICRATE, StepTics() / TICRATE, StepTics() / TICRATE, owed[n], downs, int(DEPTH * 100 + 0.5)));
		if (AudioOn(n))
		{
			// THE DROP'S SOUND (owner 11-09 17:45): a heavy hit, then a ringing in the ears that fades (its own slot: it stops
			// when you get up)
			pmo.A_StartSound("rsqsm/dnhit", CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
			pmo.A_StartSound("rsqsm/dnring", RING_SLOT, CHANF_LOCAL, 0.55, ATTN_NONE);
		}
		else pmo.A_StartSound("rsqsm/in", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.8, 10);
		RSQSM_Buzz.Start(pmo, 1, 0.8, 10);
		Tell("down.start", n, "", pmo);
		// TARGET 1: the killer, if in his fight; else a boosted copy of its type, in view at range
		double d = pmo.Distance3D(src);
		bool seen = src.CheckSight(pmo, SF_IGNOREVISIBILITY);
		bool inFight = src.health > 0 && (d <= FIGHT_NEAR || (seen && d <= FIGHT_FAR));
		String cls = src.GetClassName();
		if (inFight && ChampionsOn() && !IsChampion(src))
		{
			// NOT A CHAMPION, CHAMPIONS LOADED (owner 11-07 11:1x): swapped for a REAL Champion copy of it, next tic (not inside
			// the hit that downed him): it vanishes in teleport fog and the copy Champions makes appears where it stood
			Log(String.Format("player %d: %s downed him in his fight (%.0f units%s), not a champion: it is swapped for a REAL Champion copy",
				n, cls, d, seen ? ", in sight" : ""));
			QueueSpawn(n, cls);
			int q = spPn.Size() - 1;
			spSwap[q] = src;
			spWhy[q] = String.Format("the monster that downed him (%.0f units%s), swapped for a copy", d, seen ? ", in sight" : "");
		}
		else if (inFight) AddTarget(n, src, false, String.Format("the monster that downed him (%.0f units%s)", d, seen ? ", in sight" : ""));
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
		bool wait;
		[col, how, wait] = Boost(m);
		tMon.Push(m); tPn.Push(n); tIcon.Push(icon); tSpawned.Push(spawned ? 1 : 0); tDead.Push(0); tCol.Push(col);
		tBorn.Push(level.maptime); tDeadTic.Push(0); tName.Push(NameOf(m)); tChWait.Push(wait ? 1 : 0); tHurt.Push(0);
		m.target = players[n].mo;
		m.LastHeard = players[n].mo;
		m.bAMBUSH = false;
		Log(String.Format("player %d TARGET %d/%d: %s \"%s\" (%s): icon %d, colour %06X, %s; health %d of %d; plate name \"%s\"", n, Count(n), owed[n],
			m.GetClassName(), m.GetTag(), why, icon, col, how, m.health, m.GetSpawnHealth(), tName[tName.Size() - 1]));
		Tell("down.target", n, String.Format("%06X", col), m);
	}
	private void QueueSpawn(int n, String cls, int icon = 0)
	{
		spPn.Push(n); spCls.Push(cls); spTries.Push(0); spIcon.Push(icon > 0 ? icon : DealIcon(n));
		spId.Push(++spNextId); spHave.Push(0); spRolls.Push(0); spX.Push(0); spY.Push(0); spZ.Push(0); spAng.Push(0); spWhy.Push("");
		spSwap.Push(null); spSwapK.Push(0); spTid.Push(0); spSpec.Push(0); for (int a = 0; a < 5; a++) spArg.Push(0);
	}
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
			// WITH CHAMPIONS: the spot is found; Champions rolls on hidden candidates there until it makes one a champion
			if (spHave[i] != 0) { ChampRoll(i, pmo, c); continue; }
			// THE KILLER SWAPPED (a tic after the hit that downed him)
			if (spSwap[i])
			{
				if (level.maptime <= downStart[n]) continue;
				if (SwapKiller(i, pmo, c)) continue;
			}
			Actor m = c ? SpawnInView(pmo, c, spTries[i]) : null;
			if (m)
			{
				Placed(i, pmo, m, String.Format("a boosted copy spawned in view, %.0f units away", pmo.Distance2D(m)));
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
				Placed(i, pmo, m, String.Format("no room in view after %d tics: spawned out of view nearby, %.0f units away", SPAWN_TRIES, pmo.Distance2D(m)));
			}
		}
	}
	// a spawn found its spot (m stands there). Without Champions: m is the target (as before). With Champions (owner 11-07
	// 11:0x: a REAL Champion, made by Champions itself): Champions decides at each new monster's spawn (its handler's
	// WorldThingSpawned: its own chance, colour weights and mutations) and offers no other way to make one, so m and more
	// copies are its candidates there, hidden; the first it makes a champion is the target, the rest are taken back
	private void Placed(int i, PlayerPawn pmo, Actor m, String why)
	{
		int n = spPn[i];
		if (!ChampionsOn())
		{
			Reveal(m, false);
			AddTarget(n, m, true, why, spIcon[i]);
			DropSpawn(i);
			return;
		}
		spHave[i] = 1; spX[i] = m.pos.x; spY[i] = m.pos.y; spZ[i] = m.pos.z; spAng[i] = m.angle; spWhy[i] = why;
		Hide(m);
		cdMon.Push(m); cdId.Push(spId[i]);
		Name cnm = spCls[i];
		class<Actor> c = cnm;
		for (int k = 1; k < CH_PER_TIC; k++) Candidate(i, c);
		spRolls[i] += CH_PER_TIC;
		ChampRoll(i, pmo, c, true);
	}
	// the killer vanishes in teleport fog; Champions rolls on hidden copies where it stood (as Placed). It died or went
	// first: no swap, a copy spawns in view as for a killer outside his fight (false: the normal search goes on)
	private bool SwapKiller(int i, PlayerPawn pmo, class<Actor> c)
	{
		let k = spSwap[i];
		spSwap[i] = null;
		int n = spPn[i];
		if (!k || k.health <= 0 || !c)
		{
			Log(String.Format("player %d: the monster that downed him died or went before its swap: a copy spawns in view instead", n));
			spWhy[i] = "";
			return false;
		}
		Vector3 p = k.pos;
		double ang = k.angle;
		spSwapK[i] = 1; spTid[i] = k.tid; spSpec[i] = k.special;
		for (int a = 0; a < 5; a++) spArg[i * 5 + a] = k.args[a];
		String why = spWhy[i];
		Actor.Spawn("TeleportFog", p, ALLOW_REPLACE);
		Log(String.Format("player %d: %s (health %d) vanishes in teleport fog at (%.0f, %.0f, %.0f) (tid %d, special %d)", n, k.GetClassName(), k.health, p.x, p.y, p.z, k.tid, k.special));
		k.ClearCounters();
		k.Destroy();
		let m = Actor.Spawn(c, p, ALLOW_REPLACE);
		if (!m) { Log(String.Format("player %d: no copy of %s could spawn where it stood", n, c.GetClassName())); spSwapK[i] = 0; return false; }
		m.angle = ang;
		Placed(i, pmo, m, why);
		return true;
	}
	// the swapped killer's map tid and special go to its copy
	private void Inherit(int i, Actor m)
	{
		if (!m || spSwapK[i] == 0) return;
		if (spTid[i] != 0) m.ChangeTid(spTid[i]);
		m.special = spSpec[i];
		for (int a = 0; a < 5; a++) m.args[a] = spArg[i * 5 + a];
	}
	const CH_PER_TIC = 6;       // candidates Champions rolls on a tic (my number: on Hurt Me Plenty its chance is 72 in 256 each)
	const CH_ROLLS = 300;       // candidates before giving up (Champions set to make none: its chance or weights at 0)
	// what Champions made it, for the log: its colour and mutation tokens (Champions' own classes, by name)
	static String ChampWhat(Actor m)
	{
		if (!m) return "";
		String s = "";
		for (let it = m.Inv; it; it = it.Inv)
		{
			String cn = it.GetClassName();
			if (cn.Left(9) ~== "champion_" && (cn.IndexOf("Token") >= 0 || cn ~== "champion_PersistentInfo"))
				s = s .. (s != "" ? ", " : "") .. String.Format("%s x%d", cn, it.Amount);
		}
		return s;
	}
	static bool ChampionsOn() { Name hn = "champion_Handler"; class<StaticEventHandler> hc = hn; return hc && EventHandler.Find(hc) != null; }
	static bool IsChampion(Actor m) { if (!m) return false; Name pn = "champion_PersistentInfo"; class<Inventory> pc = pn; return pc && m.FindInventory(pc); }
	private Actor Candidate(int i, class<Actor> c)
	{
		if (!c) return null;
		let m = Actor.Spawn(c, (spX[i], spY[i], spZ[i]), ALLOW_REPLACE);
		if (!m) return null;
		m.angle = spAng[i];
		Hide(m);
		cdMon.Push(m); cdId.Push(spId[i]);
		return m;
	}
	// a candidate: not seen, not solid, not hit, out of the blockmap, until Champions has made it one
	static void Hide(Actor m) { m.bINVISIBLE = true; m.bSOLID = false; m.bSHOOTABLE = false; m.A_ChangeLinkFlags(1); }
	static void Reveal(Actor m, bool hidden)
	{
		if (hidden)
		{
			let d = GetDefaultByType(m.GetClass());
			m.bINVISIBLE = d.bINVISIBLE; m.bSOLID = d.bSOLID; m.bSHOOTABLE = d.bSHOOTABLE;
			m.A_ChangeLinkFlags(d.bNOBLOCKMAP ? 1 : 0);
		}
		Actor.Spawn("TeleportFog", m.pos, ALLOW_REPLACE);
		if (m.SeeState) m.SetState(m.SeeState);
	}
	private void ChampRoll(int i, PlayerPawn pmo, class<Actor> c, bool first = false)
	{
		int n = spPn[i], id = spId[i];
		Actor win = null;
		for (int k = 0; k < cdMon.Size() && !win; k++) if (cdId[k] == id && IsChampion(cdMon[k])) win = cdMon[k];
		if (win)
		{
			DropCandidates(id, win);
			Reveal(win, true);
			Inherit(i, win);
			AddTarget(n, win, spSwapK[i] == 0, String.Format("%s; a REAL Champion made by Champions itself (one of %d candidates it rolled on)", spWhy[i], spRolls[i]), spIcon[i]);
			DropSpawn(i);
			return;
		}
		if (first) return;        // Champions rolls on a new monster as it starts (its first tic): looked at next tic
		DropCandidates(id, null);
		if (spRolls[i] >= CH_ROLLS)
		{
			// Champions made none of them (its chance or weights set to 0): a plain copy, its colour token by name as before
			Log(String.Format("player %d: Champions made none of %d candidates champions (its chance or colour weights at 0?): a plain copy with a colour token", n, spRolls[i]));
			let m = Actor.Spawn(c, (spX[i], spY[i], spZ[i]), ALLOW_REPLACE);
			if (m) { m.angle = spAng[i]; Reveal(m, false); Inherit(i, m); AddTarget(n, m, spSwapK[i] == 0, spWhy[i] .. "; Champions made none", spIcon[i]); }
			DropSpawn(i);
			return;
		}
		for (int k = 0; k < CH_PER_TIC; k++) Candidate(i, c);
		spRolls[i] += CH_PER_TIC;
	}
	// the candidates of a spawn taken back (all but keep): never counted, never seen
	private void DropCandidates(int id, Actor keep)
	{
		for (int k = cdMon.Size() - 1; k >= 0; k--)
		{
			if (cdId[k] != id) continue;
			let m = cdMon[k];
			cdMon.Delete(k); cdId.Delete(k);
			if (!m || m == keep) continue;
			m.ClearCounters();
			m.Destroy();
		}
	}
	private int spPnCount(int n) { int k = 0; for (int i = 0; i < spPn.Size(); i++) if (spPn[i] == n) k++; return k; }
	private void DropSpawn(int i)
	{
		DropCandidates(spId[i], null);
		spPn.Delete(i); spCls.Delete(i); spTries.Delete(i); spIcon.Delete(i);
		spId.Delete(i); spHave.Delete(i); spRolls.Delete(i); spX.Delete(i); spY.Delete(i); spZ.Delete(i); spAng.Delete(i); spWhy.Delete(i);
		spSwap.Delete(i); spSwapK.Delete(i); spTid.Delete(i); spSpec.Delete(i); spArg.Delete(i * 5, 5);
	}
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
	// the third answer: a REAL Champion whose colour token its controller has not given yet (WatchTargets takes it then)
	private int, String, bool Boost(Actor m)
	{
		bool wait = false;
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
			if (cc < 0 && IsChampion(m))
			{
				// a REAL Champion (Champions' PersistentInfo): its colour token comes from its own controller in a tic or two
				wait = true;
				how = how .. (how != "" ? " + " : "") .. "a REAL Champions champion (Champions' own PersistentInfo and controller; colour token pending)";
			}
			else if (cc < 0)
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
			if (!wait) how = how .. (how != "" ? " + " : "") .. (IsChampion(m) ? "a REAL Champions champion (Champions' own PersistentInfo and controller)" : "Champions champion (a colour token by name)");
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
		return col, how, wait;
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
			if (m && tChWait[i] != 0)
			{
				// a REAL Champion's colour: its own token, once its controller has given it
				int cc = ChampColour(m);
				if (cc >= 0)
				{
					tCol[i] = cc; tChWait[i] = 0;
					tName[i] = NameOf(m);      // its colour words (RSQ Score's monster.name) come with the token
					m.A_AttachLight('RSQSM_DownMark', DynamicLight.PointLight, Color(255, (cc >> 16) & 255, (cc >> 8) & 255, cc & 255),
						int(max(64, m.radius * 3)), 0, 0, (0, 0, m.Height * 0.6));
					Log(String.Format("target %s: Champions gave its colour %06X (%s), %d tics after it became a target; plate name \"%s\"", m.GetClassName(), cc, ChampWhat(m), level.maptime - tBorn[i], tName[i]));
				}
			}
			else if (m && tCol[i] == LD_GOLD && level.maptime - tBorn[i] < 35 && (level.maptime & 3) == 0) LegendColour(i, m);
			if (m && m.health > 0 && ((level.maptime - tBorn[i]) % 35) == 34)
			{
				// its tier words can come later (a champion sets itself up after it is given its token)
				String nm = NameOf(m);
				if (nm != tName[i]) { Log(String.Format("target %s's plate name now \"%s\" (was \"%s\")", m.GetClassName(), nm, tName[i])); tName[i] = nm; }
			}
			// A FAKE DEATH IS THE KILL (owner 11-11 19:23: "when DOWN i cannot seem to revive when i kill a champion"):
			// Champions' Dark Red champion is buddha; at 1 HP it plays dead -- it vanishes (invisible, not shootable, moved
			// to the map's corner) and leaves a shootable corpse that must be destroyed, else it gets up again 3 s later
			// (mk-champions champ_darkred.txt). DOWN saw it alive at 1 HP and never revived him. Any target that plays dead
			// that way (1 HP or less, buddha, invisible, not shootable) counts as killed, by his hand (he is the one fighting it)
			if (m && m.health > 0 && m.health <= 1 && m.bBUDDHA && m.bINVISIBLE && !m.bSHOOTABLE)
			{
				Log(String.Format("target %s played dead at 1 HP (Champions' Dark Red, or the like): counted as killed", m.GetClassName()));
				TargetDown(i, true);
				continue;
			}
			if (m && m.health > 0) continue;
			if (m && m.health <= 0) { TargetDown(i, false); continue; }
			// SWAPPED OUT BY ITS OWN MOD (owner 11-12 04:06: "sometimes i shoot the fuckers who downed me and we do not get
			// up"; 04:17 "i agree"): Brutal Doom replaces some living monsters with another actor (its Imp in deep water
			// becomes ImpFish: Imps.dec Swim), so the target is gone with no death. One he has already damaged is his kill.
			if (tHurt[i] != 0)
			{
				Log(String.Format("player %d: target %d is gone without dying after he damaged it (swapped for another actor): counted as his kill", n, i));
				TargetDown(i, true);
				continue;
			}
			Log(String.Format("player %d: target %d is gone without dying: a fresh one in its place", n, i));
			tDead[i] = 2; tDeadTic[i] = level.maptime - 100;
			owed[n]++;     // the gone one is not a kill: one more owed, its place taken by the fresh one
			String cls = "";
			for (int j = 0; j < tMon.Size(); j++) if (tPn[j] == n && tMon[j]) { cls = tMon[j].GetClassName(); break; }
			if (cls == "") cls = "DoomImp";     // my reading: nothing left to copy -- an Imp
			QueueSpawn(n, cls, tIcon[i]);
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
		lastKillE[n] = Elapsed(n);
		let m = tMon[i];
		let pmo = players[n].mo;
		int e = Elapsed(n);
		Log(String.Format("player %d target %s died%s at %.2f s into the bar (%s step): %d of %d owed", n, m ? String.Format("%s", m.GetClassName()) : "?",
			byHim ? " by his hand" : " (not by his hand: no Revenge award)", e / double(TICRATE), TierName(TierAt(e)), Killed(n), owed[n]));
		if (byHim) { Tell("down.revenge", n, "", m); Award(pmo, "Revenge"); }
		if (downOn[n] && Killed(n) >= owed[n] && spPnCount(n) == 0) Revive(n);
		else if (downOn[n] && pmo) BarReset(n);
	}
	private void DropTarget(int i)
	{
		tMon.Delete(i); tPn.Delete(i); tIcon.Delete(i); tSpawned.Delete(i); tDead.Delete(i); tCol.Delete(i); tBorn.Delete(i); tDeadTic.Delete(i); tName.Delete(i); tChWait.Delete(i); tHurt.Delete(i);
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
		int e = lastKill[n] > 0 ? lastKillE[n] : Elapsed(n);
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
		if (AudioOn(n)) pmo.A_StartSound("rsqsm/dnrelief", CHAN_AUTO, CHANF_LOCAL, 0.9, ATTN_NONE);   // the relief (owner 11-09 17:45)
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

	// DOWN'S MUSIC (owner 2026-11-09: "when we are Down, I want this to play"). RSQ VisualRewards' scenes, by name: the
	// "down" scene is that player's alone and stands above a Bossfight's (80 over 50); when he gets up (or doesn't) it goes
	// and whatever was playing before crossfades back. Without VisualRewards, nothing changes.
	const DOWN_SCENE_PRIO = 80;
	private void DownMusic(int n, bool on)
	{
		let it = ServiceIterator.Find("RSQVR_Service");
		let vr = it.Next();
		if (!vr) return;
		String key = String.Format("down%d", n);
		if (on) { let c = CVar.FindCVar("rsqsm_down_music"); if (!c || c.GetBool()) vr.GetInt("scene.push", key, DOWN_SCENE_PRIO, n + 1, null, 'rsqvr/music/down'); }
		else vr.GetInt("scene.pop", key);
	}

	private void End(int n, bool revived)
	{
		downOn[n] = false;
		DownMusic(n, false);
		endTic[n] = level.maptime;
		endHow[n] = revived ? 1 : 2;
		Hold(n, false);
		if (players[n].mo) players[n].mo.A_StopSound(RING_SLOT);
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
	// THE PLATE'S NAME FOR A TARGET (owner 11-07): RSQ Score's "monster.name" (the game's name with Score's tier words in
	// front), asked by name; without Score, the game's own name (its tag; the class name when it has none)
	static String NameOf(Actor m)
	{
		if (!m) return "";
		let it = ServiceIterator.Find("RS_ScoreService");
		Service sv;
		while (sv = it.Next())
		{
			if (sv.GetClassName() != 'RS_ScoreService') continue;
			String s = sv.GetString("monster.name", "", 0, 0, m);
			if (s != "") return s;
		}
		return m.GetTag();
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
