// ============================================================================
// RSQ_Miniboss -- RANK AND THE DIRECTOR (design/BOSS_REWORK.md 1, Phase C; Battle Garegga's rank, Left 4 Dead's director).
// Owner 2026-11-23 05:0x: "rank leans, not locks"; "meter + call, director times it".
//
//   RANK            one number per game, 0-100 (the server cvar rsqmb_rank: a savegame holds it, as it holds the World
//                   Tier). It replaces the World Tier as the game's difficulty (Difficulty: Rank, rsqmb_rank_on; off: the
//                   World Tier exactly as before). -1 = not started: the first tic with Rank on starts it from the World
//                   Tier as it stands (the middle of that colour), so turning Rank on never drops a game to Common.
//   ITS COLOUR      every RANK_BAND (8) points is the next colour: 0-7 Common, 8-15 Green ... 96-100 White (13 colours, the
//                   ladder's). Rank WRITES RSQ Monsters' World Tier (rsq_mon_worldtier, by name, as tierup.zs does), so
//                   everything that reads the World Tier follows with no change of its own: the colours monsters stand at
//                   (RSQ Monsters moves the living ones with its tier flash), the Boss's colour and its thralls' (fight.zs),
//                   the thrall count (arrival2.zs ThrallWant), Boss health and lives that follow the colour. A change waits
//                   while a fight is landing or on (nothing in a fight changes colour, owner 11-17) and is written after it.
//                   Crossing a colour needs RANK_HYS points past its edge, so Rank sitting on an edge does not flicker the map.
//   IT RISES        a kill (RANK_KILL), more in a chain of kills (RANK_CHAIN a step, up to RANK_CHAIN_MAX steps); every
//                   RANK_CALM_SECS in a fight-free combat (a monster after you within 1536) without being hurt (RANK_CALM);
//                   a Boss won: one colour up from Rank's colour, never below the colour the map stands at (tierup.zs
//                   TierUpNow); won without being hurt in that fight: RANK_CLEAN more.
//   IT FALLS        heavy damage: RANK_HEAVY_FRAC of your health in RANK_HEAVY_SECS (RANK_HEAVY, then once each
//                   RANK_HEAVY_SECS); going DOWN (RSQ SlowMo "down", by name: RANK_DOWN); a Score life spent outside a
//                   fight (RSQ Score "lives", by name: RANK_LIFE; in a fight that is a loss, below); dying (RANK_DEATH: a
//                   reload puts the saved Rank back, so this counts only where no save is loaded); a Boss lost: one colour
//                   down from Rank's colour, never above the colour the map stands at (tierup.zs TierDownNow).
//   NO DRIFT        nothing moves it in a quiet stretch (no monster after you), so a long walk neither punishes nor rewards.
//                   (Section 1 said "drifts toward where the player is playing": read here as "only play moves it".)
//   x Rank Speed    (rsqmb_rank_speed) scales every rise and fall from play; a Boss's colour step is always one colour.
//   ALSO DRIVEN     the wind-up's timing (telegraph.zs Interval: 20 s at Rank 0 to 10 s at Rank 100, a straight line,
//                   in place of the World Tier's 13 steps); which monster type the Boss is (PlanArrival: Rank LEANS, the
//                   owner's pick: it sets where on the map's roster the pick centres, and a wide random spread lets any
//                   type come). Score's multiplier from Rank is RSQ Score's (built 2026-11-23: handler.zs RankMult asks RSQMB_Service "rank").
//
//   THE DIRECTOR    (rsqmb_dir) it decides WHEN, not whether. INTENSITY 0..1, every 7 tics, from the damage you took lately
//                   (an average that halves every 4 s), the monsters after you within 1536 and your health under 60.
//     HOLD          a Boss called with the watch check (or due by itself) waits while intensity is at or over DIR_HOT, for
//                   at most rsqmb_dir_hold seconds ("Boss: Get Ready" under the meter), then comes whatever. A call from
//                   the Start Fight card is NEVER held (the card skips every rule).
//     COASTING      while the meter is full and intensity is under DIR_COAST, every tic counts twice toward the fight
//                   coming by itself (rsqmb_bf_auto), so a player who is coasting gets it about twice as soon.
//     RELAX         after every Boss or Big Boss fight ends (won or lost), rsqmb_dir_relax seconds of relax: the meter does
//                   not fill, and monsters after you fire less from range (their MinMissileChance raised to DIR_RELAX_MMC,
//                   each one's own value put back after; the engine's range roll: at 255 a monster past ~255 units almost
//                   never takes the shot). No new spawns of our own happen in it either (the Boss cooldown already holds).
//
// Code only until the rig runs it; then rig only, not headset-confirmed.
// ============================================================================

extend class RSQMB_Handler
{
	const RANK_BAND = 8.0;          // points per colour
	const RANK_HYS = 1.0;           // points past a colour's edge before the World Tier follows
	const RANK_KILL = 0.05;
	const RANK_CHAIN = 0.03;        // a step of a kill chain (bossfight.zs CHAIN_TICS)
	const RANK_CHAIN_MAX = 6;
	const RANK_CALM = 0.3;
	const RANK_CALM_SECS = 10;
	const RANK_CLEAN = 2.0;
	const RANK_HEAVY = 2.0;
	const RANK_HEAVY_FRAC = 0.5;
	const RANK_HEAVY_SECS = 3;
	const RANK_DOWN = 3.0;
	const RANK_LIFE = 4.0;
	const RANK_DEATH = 6.0;
	const DIR_HOT = 0.7;
	const DIR_COAST = 0.15;
	const DIR_RELAX_MMC = 255;
	const DIR_BUSY_CAP = 8;         // monsters after you at which the director's intensity is full (DirTick)

	// ---- Rank's state (transient: the number itself is the cvar; these are only this map's counters) ----------------
	transient int rkChain, rkLastKill;
	transient int rkCalmFrom;       // the tic the current unhurt combat stretch began (0: not in combat)
	// RANK PER MAP, NOT PER KILL (owner 2026-11-24 23:28: "i am ranking up way too fast. on moc black metal, im at rank 24
	// halfway through the first map"; his target sets measured, tools: Maps of Chaos OVERKILL 9..549 monsters a map,
	// median 220; The Way id Did (Doom II) median 123; (Ultimate Doom) median 115). A flat +0.05 a kill plus up to +0.18 for
	// a chain was tuned for 30-100 monster maps: half of a 174-monster map with chains running gave ~20 points (3 colours).
	// Now a map's kills share RANK_MAP_KILLS between them (level.total_monsters, which counts what a spawn adjuster or a
	// script adds), a full chain doubling a kill's share; and calm combat gives at most RANK_MAP_CALM a map. A perfect clear
	// of any map is about 2-4 points, half a colour; the colour steps come from Bosses. Losses are as before.
	const RANK_MAP_KILLS = 2.0;
	const RANK_MAP_CALM = 1.0;
	transient int rkMapKey;
	transient double rkMapCalm;
	transient int rkHurtAt;         // the last tic a player was hurt
	transient Array<int> rkHitAt;   // recent damage to players: tic, amount (pairs), for heavy damage
	transient int rkHeavyAt;
	transient bool rkWasDown[MAXPLAYERS];
	transient int rkLives[MAXPLAYERS];
	transient bool rkFightHurt;     // a player was hurt during the fight running now (the clean win)
	transient bool rkWasBusy;
	transient int rkPendTier;       // a World Tier change waiting for the fight to end (0: none)
	// ---- the director ----
	transient double drDmg;         // the damage average (halves every 4 s)
	transient double drInt;         // intensity 0..1
	transient int drBusy;
	transient int drHoldFrom;       // the tic the director began holding the due fight (0: not holding)
	transient int drRelaxTill;
	transient Array<Actor> drCalmA;
	transient Array<int> drCalmMmc;

	static clearscope bool RankOn() { return CI('rsqmb_rank_on', 1) != 0; }
	static clearscope bool DirOn() { return CI('rsqmb_dir', 1) != 0; }
	static clearscope double RankNow() { let c = CVar.FindCVar('rsqmb_rank'); return c ? c.GetFloat() : -1; }
	// Rank as 0..1, for whatever reads it (the wind-up's timing); the World Tier's place on 1..13 when Rank is off
	static double RankFrac()
	{
		if (RankOn()) { double r = RankNow(); if (r >= 0) return clamp(r / 100.0, 0.0, 1.0); }
		return (clamp(WorldTierNow(), 1, 13) - 1) / 12.0;
	}
	// the ladder's colour (fight.zs LadderRGB, copied: the HUD reads it), Black lifted so the word shows on a dark view
	static clearscope int RankRGB(int t)
	{
		static const int RGB[] = { 0xC8C8C8, 0x3CDC46, 0x3C78FF, 0xAA46E6, 0x3CF0F0, 0x8C5A28, 0xFFC828,
			0x28A0DC, 0x828282, 0xE62828, 0x8A3CD0, 0x909098, 0xFFFFFF };
		return (t >= 1 && t <= 13) ? RGB[t - 1] : 0xFFFFFF;
	}
	static clearscope int TierOfRank(double r) { return clamp(1 + int(floor(clamp(r, 0.0, 100.0) / RANK_BAND)), 1, TOP_TIER); }

	// A SERVER CVAR WRITE LANDS A TIC LATER (rig 2026-11-23 rk2: four kills in one tic added once), so what this side last
	// wrote is kept and read back for RANK_SHADOW tics
	const RANK_SHADOW = 4;
	// the World Tier as this side last saw or wrote it: a different value is someone else's (the World Tier slider, a
	// Boss's colour step), and Rank follows it (owner 2026-11-24: "adjusting the tier slider does nothing")
	transient int rkTierSeen;
	transient double rkShadow;
	transient int rkShadowAt;
	double RankCur() { return (rkShadowAt > 0 && gametic - rkShadowAt <= RANK_SHADOW) ? rkShadow : RankNow(); }
	// the colour a Boss won (+1) or lost (-1) goes to: with Rank on, one colour from RANK's colour, but a win never lowers the
	// colour the map stands at and a loss never raises it (rig rk3: Rank fell two colours during a fight, the win stepped up
	// from there and the map went DOWN a colour after a win); off, the World Tier +- 1 as before
	int RankStepTier(int was, int dir)
	{
		int t = clamp(was + dir, 1, TOP_TIER);
		if (RankOn() && RankCur() >= 0 && CeilOn())
		{
			// the ceiling (above): the colour Rank will stand at after the step, inside the map's window
			t = TierOfRank(clamp(RankCur() + dir * RANK_BOSS_STEP, RankFloor(), RankCeil()));
			return dir > 0 ? max(t, was) : min(t, was);
		}
		if (RankOn() && RankCur() >= 0)
		{
			t = clamp(TierOfRank(RankCur()) + dir, 1, TOP_TIER);
			t = dir > 0 ? max(t, was) : min(t, was);
		}
		return t;
	}
	// ---- THE CEILING BY THE MAP (owner 2026-11-25: "we need to hit our max tier either in the last map or the second to last
	// map (and it can't be white, it'll take forever)"; picked "the ceiling rises with the map"). Measured on his three target
	// sets (tools: Maps of Chaos, The Way id Did II and Ultimate): no rise per kill or per Boss lands a chosen map in sets of
	// different lengths, because every Boss win counts on every map. So the map decides how high Rank may go and play decides
	// where inside the window under it: the CEILING is a colour from Common on the first map to CEIL_TOP (10, Red) on the
	// second-to-last, evenly; Rank is held between the start of the colour WINDOW - 1 below it and the top of the ceiling's own
	// colour (RankSet, RankTick). A Boss win is RANK_BOSS_STEP more Rank, a loss as much less (RankToTier), never a whole colour.
	// Where the map is: MAPxx of 30 (MAP31 / MAP32, the secret levels, sit at MAP15); ExMy of 8 a episode, over the episodes the
	// game has (E4M1 there: four; M9, the secret level, sits at M4). Any other name: no ceiling, Rank as before. Rank Ceiling
	// (rsqmb_rank_ceiling, on). Rig only, not headset-confirmed.
	const CEIL_TOP = 10;
	const CEIL_WINDOW = 3;
	const RANK_BOSS_STEP = 4.0;
	static bool CeilOn() { let c = CVar.FindCVar('rsqmb_rank_ceiling'); return (!c || c.GetBool()) && MapStep() >= 0; }
	// the map's place in its set: (index from 0, count of maps); -1 when the name says nothing
	static int, int MapStep()
	{
		String n = level.MapName.MakeUpper();
		if (n.Left(3) == "MAP" && n.Length() == 5)
		{
			int k = n.Mid(3).ToInt(10);
			if (k < 1) return -1, 0;
			if (k > 30) k = 15;
			return k - 1, 30;
		}
		if (n.Length() == 4 && n.Left(1) == "E" && n.Mid(2, 1) == "M")
		{
			int e = n.Mid(1, 1).ToInt(10), m = n.Mid(3, 1).ToInt(10);
			if (e < 1 || m < 1) return -1, 0;
			if (m > 8) m = 4;
			int eps = 1;
			for (int x = 2; x <= 6; x++) if (LevelInfo.MapExists(String.Format("E%dM1", x))) eps = x;
			return (e - 1) * 8 + m - 1, eps * 8;
		}
		// A HUB OF MANY SETS (owner 2026-11-25, Compendium MegaWAD SuperMix: MM101, TW232, ETE134 ...): a name that ends in
		// two digits is map NN of the set its other letters name (MM1 + 01); the set's count is its highest NN this game
		// has (gaps allowed). Each set climbs to Red as its own megawad.
		int len = n.Length();
		if (len >= 3)
		{
			int d1 = n.ByteAt(len - 2) - 48, d2 = n.ByteAt(len - 1) - 48;
			if (d1 >= 0 && d1 <= 9 && d2 >= 0 && d2 <= 9)
			{
				String pre = n.Left(len - 2);
				int k = d1 * 10 + d2;
				if (k < 1) return -1, 0;
				int top = k, miss = 0;
				int from = k;
				if (k >= 31) { top = 1; from = 1; }     // a secret map (31, 32): the middle of its set, as MAP31 is
				for (int x = from + 1; x <= 40 && miss < 3; x++)
				{
					if (LevelInfo.MapExists(String.Format("%s%02d", pre, x))) { top = x; miss = 0; }
					else miss++;
				}
				if (k >= 31) return max(0, top / 2 - 1), top;
				return k - 1, top;
			}
		}
		return -1, 0;
	}
	// the ceiling's colour on this map: Common on the first, CEIL_TOP on the second-to-last and after
	static int CeilTier()
	{
		int i, n;
		[i, n] = MapStep();
		if (i < 0 || n < 3) return CEIL_TOP;
		double p = clamp(i / double(n - 2), 0.0, 1.0);
		return clamp(1 + int(round((CEIL_TOP - 1) * p)), 1, CEIL_TOP);
	}
	static double RankCeil() { return CeilTier() * RANK_BAND - RANK_HYS - 0.01; }
	static double RankFloor() { return max(0, (CeilTier() - CEIL_WINDOW - 1) * RANK_BAND); }

	void RankSet(double r, String why)
	{
		let c = CVar.FindCVar('rsqmb_rank');
		if (!c) return;
		double was = RankCur();
		r = clamp(r, 0.0, 100.0);
		if (CeilOn()) r = clamp(r, RankFloor(), RankCeil());
		if (abs(r - was) < 0.0001) return;
		c.SetFloat(r);
		rkShadow = r; rkShadowAt = gametic;
		if (debug) Console.Printf("RSQMB rank %.2f -> %.2f (%s), colour %s", was, r, why, TierText(TierOfRank(r)));
	}
	// a Score life earned (+rsqmb_rank_life_won, 4: half a colour) or lost (-rsqmb_rank_life_lost, 8: a colour), RSQ Score
	void RankLife(bool won)
	{
		if (!RankOn() || RankCur() < 0) return;
		double d = won ? CF('rsqmb_rank_life_won', 4.0) : -CF('rsqmb_rank_life_lost', 8.0);
		RankSet(RankCur() + d, won ? "a Score life earned" : "a Score life lost");
	}
	void RankAdd(double d, String why)
	{
		if (!RankOn()) return;
		double r = RankCur();
		if (r < 0) return;
		RankSet(r + d * clamp(CF('rsqmb_rank_speed', 1.0), 0.0, 4.0), why);
	}

	// tierup.zs: a Boss won or lost moved the World Tier one colour; Rank goes with it (into that colour, just past its edge)
	void RankToTier(int t, bool up)
	{
		if (!RankOn()) return;
		double r = RankCur();
		if (r < 0) return;
		if (CeilOn()) { RankSet(r + (up ? RANK_BOSS_STEP : -RANK_BOSS_STEP), up ? "a Boss won (inside the map's window)" : "a Boss lost (inside the map's window)"); return; }
		double lo = (t - 1) * RANK_BAND, hi = t * RANK_BAND;
		if (up) RankSet(max(r, lo + RANK_HYS + 0.5), String.Format("a Boss won: colour %s", TierText(t)));
		else RankSet(min(r, hi - RANK_HYS - 0.5), String.Format("a Boss lost: colour %s", TierText(t)));
	}

	// ---- the hooks (handler.zs) ---------------------------------------------------------------------------------------
	void RankKill(Actor victim, Actor killer)
	{
		if (!RankOn() || !killer || !killer.player || !victim || victim.player || !victim.bISMONSTER || !victim.bCOUNTKILL) return;
		int now = level.maptime;
		rkChain = (now - rkLastKill <= CHAIN_TICS) ? rkChain + 1 : 1;
		rkLastKill = now;
		double share = RANK_MAP_KILLS / max(level.total_monsters, 1);
		double chainK = 1.0 + double(min(rkChain - 1, RANK_CHAIN_MAX)) / RANK_CHAIN_MAX;   // 1x alone .. 2x at a full chain
		RankAdd(share * chainK, rkChain > 1 ? String.Format("kill, chain %d (map of %d)", rkChain, level.total_monsters) : String.Format("kill (map of %d)", level.total_monsters));
	}
	void RankPlayerDied(Actor p)
	{
		if (!p || !p.player) return;
		RankAdd(-RANK_DEATH, "died");
	}
	void RankDamaged(WorldEvent e)
	{
		let p = e.Thing;
		if (!p || !p.player || e.Damage <= 0) return;
		int now = level.maptime;
		rkHurtAt = now;
		rkCalmFrom = 0;
		if (BfBusy()) rkFightHurt = true;
		drDmg += e.Damage;
		if (!RankOn()) return;
		rkHitAt.Push(now); rkHitAt.Push(e.Damage);
		int sum = 0;
		for (int i = 0; i < rkHitAt.Size(); i += 2)
		{
			if (now - rkHitAt[i] > RANK_HEAVY_SECS * TICRATE) { rkHitAt.Delete(i, 2); i -= 2; continue; }
			sum += rkHitAt[i + 1];
		}
		int maxHp = max(1, p.player.mo ? p.player.mo.GetMaxHealth(true) : 100);
		if (sum >= maxHp * RANK_HEAVY_FRAC && now - rkHeavyAt >= RANK_HEAVY_SECS * TICRATE)
		{
			rkHeavyAt = now;
			RankAdd(-RANK_HEAVY, String.Format("heavy damage, %d in %d s", sum, RANK_HEAVY_SECS));
		}
	}

	// tierup.zs TierUpOnKill: a Boss won without being hurt in its fight
	void RankCleanWin()
	{
		if (!rkFightHurt) RankAdd(RANK_CLEAN, "a clean Boss win");
	}

	// ---- every tic (handler.zs WorldTick) ------------------------------------------------------------------------------
	void RankTick()
	{
		int now = level.maptime;
		bool busy = BfBusy();
		if (busy && !rkWasBusy) rkFightHurt = false;                    // a fight begins
		if (!busy && rkWasBusy && DirOn())                              // a fight ends: relax
		{
			drRelaxTill = now + clamp(CI('rsqmb_dir_relax', 20), 0, 120) * TICRATE;
			if (debug) Console.Printf("RSQMB director t%d: a fight ended, relax %d s", now, CI('rsqmb_dir_relax', 20));
		}
		rkWasBusy = busy;
		DirTick(now, busy);
		if (!RankOn()) { rkPendTier = 0; return; }
		let wc = TuWorld();
		double r = RankCur();
		if (r < 0)
		{
			// first tic with Rank on: start from the World Tier as it stands, the middle of its colour
			int w = wc ? clamp(wc.GetInt(), 1, TOP_TIER) : 1;
			RankSet((w - 1) * RANK_BAND + RANK_BAND * 0.5, String.Format("Rank starts at Monster Tier %s", TierText(w)));
			return;
		}
		if (now % 7 != 3) return;
		// a new map moves the window: Rank is brought into it (RankSet clamps)
		if (CeilOn() && (r < RankFloor() || r > RankCeil())) RankSet(r, String.Format("the map's window (%s up to %s)", TierText(TierOfRank(RankFloor())), TierText(CeilTier())));
		// players: DOWN (SlowMo), a Score life spent outside a fight
		if (!svcChecked) FindServices();
		let sm = smSvc;   // handler.zs FindServices
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let pmo = players[pn].mo;
			bool dn = sm && sm.GetInt("down", "", pn) == 1;
			if (dn && !rkWasDown[pn]) RankAdd(-RANK_DOWN, "went DOWN");
			rkWasDown[pn] = dn;
			int lv = scoreSvc ? scoreSvc.GetInt("lives", "", 0, 0, pmo) : -1;
			if (lv >= 0)
			{
				if (rkLives[pn] > 0 && lv < rkLives[pn] - 1 && !busy) RankAdd(-RANK_LIFE, "a Score life spent");
				rkLives[pn] = lv + 1;           // stored +1, so 0 means "not seen yet"
			}
		}
		// calm combat: in combat (the director's count) and not hurt for RANK_CALM_SECS
		if (drBusy > 0 && !busy)
		{
			if (rkCalmFrom == 0) rkCalmFrom = now;
			else if (now - rkCalmFrom >= RANK_CALM_SECS * TICRATE)
			{
				rkCalmFrom = now;
				int mk = level.totaltime - level.maptime + 1;
				if (rkMapKey != mk) { rkMapKey = mk; rkMapCalm = 0; }
				double give = min(RANK_CALM * 0.5, RANK_MAP_CALM - rkMapCalm);
				if (give > 0) { rkMapCalm += give; RankAdd(give, String.Format("%d s in combat unhurt (%.1f of %.1f this map)", RANK_CALM_SECS, rkMapCalm, RANK_MAP_CALM)); }
			}
		}
		else if (drBusy == 0) rkCalmFrom = 0;
		// the World Tier follows the colour (past the hysteresis), but never during a fight
		if (!wc) return;
		// a Boss's win or loss is about to move the colour (tierup.zs): it writes it, not this
		if (tuAt.Size() || tdAt.Size()) return;
		int cur = clamp(wc.GetInt(), 1, TOP_TIER);
		if (rkTierSeen == 0) rkTierSeen = cur;
		else if (cur != rkTierSeen)
		{
			// set from outside (the slider, a Boss won or lost): Rank goes to the middle of that colour, so the two agree
			rkTierSeen = cur;
			rkPendTier = 0;
			RankSet((cur - 1) * RANK_BAND + RANK_BAND * 0.5, String.Format("Monster Tier set to %s", TierText(cur)));
			return;
		}
		r = RankCur();
		int want = cur;
		if (r >= cur * RANK_BAND + RANK_HYS) want = TierOfRank(r);
		else if (r < (cur - 1) * RANK_BAND - RANK_HYS) want = TierOfRank(r);
		if (want == cur) { rkPendTier = 0; return; }
		if (busy) { if (rkPendTier != want && debug) Console.Printf("RSQMB rank: colour %s waits for the fight to end", TierText(want)); rkPendTier = want; return; }
		wc.SetInt(want);
		rkTierSeen = want;
		rkPendTier = 0;
		if (debug) Console.Printf("RSQMB rank %.2f: Monster Tier %s -> %s", r, TierText(cur), TierText(want));
	}


	// ---- the director ----------------------------------------------------------------------------------------------------
	void DirTick(int now, bool busy)
	{
		// the damage average halves every 4 s (0.5 ^ (1/140) a tic)
		drDmg *= 0.99506;
		if (now % 7 == 0)
		{
			int n = 0, hp = 100;
			for (int pn = 0; pn < MAXPLAYERS; pn++)
			{
				if (!playeringame[pn] || !players[pn].mo) continue;
				let p = players[pn].mo;
				hp = min(hp, p.health);
				// (performance, 2026-11-27) the count is read only up to DIR_BUSY_CAP (intensity's clamp(n / 8), drBusy as "any"):
				// past it the rest of the 1536-unit block scan changed nothing but the debug line's number, so it stops there
				// (the full count while the debug log is on)
				if (n >= DIR_BUSY_CAP && !debug) continue;
				let bi = BlockThingsIterator.Create(p, 1536);
				while (bi.Next())
				{
					let a = bi.thing;
					if (a && a.bISMONSTER && !a.bFRIENDLY && a.health > 0 && a.target == p && !a.bCORPSE && a.Distance2D(p) < 1536)
					{
						n++;
						if (n >= DIR_BUSY_CAP && !debug) break;
					}
				}
			}
			drBusy = n;
			double d = clamp(drDmg / 60.0, 0.0, 1.0);
			double b = clamp(n / double(DIR_BUSY_CAP), 0.0, 1.0);
			double h = clamp((60 - hp) / 60.0, 0.0, 1.0);
			drInt = clamp(0.5 * d + 0.35 * b + 0.3 * h, 0.0, 1.0);
			if (debug && now % 70 == 0) Console.Printf("RSQMB director t%d: intensity %.2f (damage %.0f, %d after you, health %d)%s", now, drInt, drDmg, n, hp,
				now < drRelaxTill ? " RELAX" : (drInt >= DIR_HOT ? " HOT" : (drInt < DIR_COAST ? " coasting" : "")));
		}
		RelaxTick(now);
	}

	// the meter does not fill in a relax (bossfight.zs Fill)
	clearscope bool DirRelaxing() { return DirOn() && level.maptime < drRelaxTill; }

	// bossfight.zs, the due fight: "" to go, or the line under the meter while the director holds it. Never a card call.
	String DirHold(RSQMB_Meter m, bool big)
	{
		if (!DirOn() || !m || (big ? m.exForce : m.force)) { drHoldFrom = 0; return ""; }
		int now = level.maptime;
		int cap = clamp(CI('rsqmb_dir_hold', 6), 0, 30) * TICRATE;
		if (drInt < DIR_HOT || cap <= 0) { drHoldFrom = 0; return ""; }
		if (drHoldFrom == 0) { drHoldFrom = now; if (debug) Console.Printf("RSQMB director t%d: intensity %.2f, the fight is held (at most %d s)", now, drInt, cap / TICRATE); }
		if (now - drHoldFrom >= cap) return "";
		return big ? "Big Boss: Get Ready" : "Boss: Get Ready";
	}
	void DirHoldDone() { drHoldFrom = 0; }

	// bossfight.zs, the fight coming by itself: tics a full meter has waited, counting double while the player coasts
	transient int drCoast;
	int DirWaited(int readyAt)
	{
		int now = level.maptime;
		if (DirOn() && drInt < DIR_COAST) drCoast++;
		return (now - readyAt) + (DirOn() ? drCoast : 0);
	}
	void DirCoastReset() { drCoast = 0; }

	// RELAX: monsters after a player fire less from range; each one's own MinMissileChance comes back after
	void RelaxTick(int now)
	{
		bool on = now < drRelaxTill;
		if (!on)
		{
			if (drCalmA.Size())
			{
				for (int i = 0; i < drCalmA.Size(); i++) if (drCalmA[i]) drCalmA[i].MinMissileChance = drCalmMmc[i];
				if (debug) Console.Printf("RSQMB director t%d: relax over, %d monster(s) back to their own aim", now, drCalmA.Size());
				drCalmA.Clear(); drCalmMmc.Clear();
			}
			return;
		}
		if (now % 17 != 5) return;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let p = players[pn].mo;
			let bi = BlockThingsIterator.Create(p, 1536);
			while (bi.Next())
			{
				let a = bi.thing;
				if (!a || !a.bISMONSTER || a.bFRIENDLY || a.health <= 0 || a.target != p || drCalmA.Find(a) < drCalmA.Size()) continue;
				drCalmA.Push(a); drCalmMmc.Push(a.MinMissileChance);
				a.MinMissileChance = max(a.MinMissileChance, DIR_RELAX_MMC);
			}
		}
	}
}

// A NEW GAME STARTS AT THE STARTING RANK (owner 2026-11-23 09:13: "sometimes i start a game with a high rank, is that normal
// or does it carry over in ini?"). It carried over: Rank and the World Tier it writes are server cvars, kept in the ini, so
// a new game began where the last one stopped. Now a new game sets Rank to Starting Rank (rsqmb_rank_start, 0) and RSQ
// Monsters' World Tier (by name) to that Rank's colour. A savegame still brings back its own (the engine keeps server
// cvars in a save). Rank off: the World Tier is left as the page sets it, as before.
class RSQMB_RankNewGame : StaticEventHandler
{
	override void NewGame()
	{
		if (!RSQMB_Handler.RankOn()) return;
		let st = CVar.FindCVar('rsqmb_rank_start');
		double r = clamp(st ? st.GetFloat() : 0.0, 0.0, 100.0);
		let rc = CVar.FindCVar('rsqmb_rank');
		if (rc) rc.SetFloat(r);
		let wt = CVar.FindCVar('rsq_mon_worldtier');
		if (wt) wt.SetInt(RSQMB_Handler.TierOfRank(r));
		if (RSQMB_Handler.CI('rsqmb_debug', 0)) Console.Printf("RSQMB rank: a new game starts at Rank %.0f (Monster Tier %d)", r, RSQMB_Handler.TierOfRank(r));
	}
}
