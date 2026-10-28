// ============================================================================
// RSQ_Miniboss -- the set piece (an EventHandler: one per level, saved with it).
//
//   CHOOSING   At tic 10 (after LegenDoom Lite marks its legendaries, tic 1-2, and Champions' delayer,
//              tic 3), rsqmb_per_map minibosses, picked from the strongest third of the level's
//              monsters weighted by spawn health (never a BOSS-flagged one, a Dark Red or an Undying
//              champion, whose own death tricks fight the lives), each with the rsqmb_thralls best
//              monsters within rsqmb_radius (none stronger than it): champions first, then
//              legendaries, then the nearest.
//              Class names are never used, so it is the same on Doom's monsters and Brutal Doom's.
//   LEGENDARY  With LegenDoom Lite loaded and rsqmb_legend_thralls on, every thrall is made legendary
//              with LegenDoom Lite's own LDLegendaryMonsterPickupGuaranteed (by name). A dormant
//              champion (Champions' champion_Dormant) wakes when its legendary transforms.
//   INHERITING see Inherit() below: the rule and its caps.
//   SLOW TIME  A thrall's death opens a window (rsqmb_slow s) and asks RSQ_SlowMo for it by its own
//              event (rsm_pulse, re-sent each second while the window lasts: SlowMo holds the longest).
//              Another thrall's death in the window adds rsqmb_slow_chain s, up to rsqmb_slow_max s.
//   GREED      A player who strikes the miniboss while its thralls live arms its greed. When the slow
//              window runs out (or, struck with no window running, rsqmb_slow s later) with the
//              miniboss alive and a thrall still standing, EVERY monster is enraged until it dies:
//              speed x rsqmb_rage_speed, the missile-attack threshold halved, reaction spent.
//              Clearing the thralls first disarms it. Restored exactly (RSQMB_Rage, items.zs).
// ============================================================================

class RSQMB_Handler : EventHandler
{
	const SELECT_AT = 10;

	// ---- synced state (in the save) --------------------------------------------------------------
	bool   chosen;
	Array<RSQMB_Boss> bosses;
	int    windowEnd, nextPulse;
	int    rageCount;
	Array<Actor> raged;

	// ---- settings, read once a tic ---------------------------------------------------------------
	transient int    cvTic;
	transient double shield, invulSecs, invulBonus, rageSpeed, fxRange2;
	transient bool   revive, fxOn, debug, greedOn, scoreOn;
	transient int    slowTics, chainTics, maxTics, depthPct;

	// ---- the cost meter (rsqmb_debug only): script time this mod spends, ms, since the last report
	transient double costMs, costPeak;
	transient int    costTics, fxParticles;

	// ---- other mods, found by name once ----------------------------------------------------------
	transient bool   svcChecked;
	transient Service smSvc, scoreSvc;

	static RSQMB_Handler Get() { return RSQMB_Handler(EventHandler.Find("RSQMB_Handler")); }

	static clearscope int CI(Name n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static clearscope double CF(Name n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static double CLocal(Name n, double d)
	{
		if (!playeringame[consoleplayer]) return d;
		let c = CVar.GetCVar(n, players[consoleplayer]);
		return c ? c.GetFloat() : d;
	}
	static bool Has(Actor a, String n)
	{
		class<Inventory> c = n;
		return a && c && a.FindInventory(c);
	}
	static class<Inventory> InvClass(String n) { class<Inventory> c = n; return c; }
	static void Give(Actor a, String n) { let c = InvClass(n); if (a && c) a.GiveInventory(c, 1); }
	static bool Loaded(String cls) { return cls != "" && Object.FindClass(cls) != null; }

	void Refresh()
	{
		if (cvTic == level.maptime) return;
		cvTic = level.maptime;
		shield     = clamp(CI('rsqmb_shield', 80), 0, 95) / 100.0;
		invulSecs  = clamp(CF('rsqmb_invuln', 5.0), 0.0, 30.0);
		invulBonus = clamp(CF('rsqmb_invuln_bonus', 1.0), 0.0, 10.0);
		revive     = CI('rsqmb_revive', 1) != 0;
		slowTics   = int(clamp(CF('rsqmb_slow', 4.0), 0.5, 20.0) * TICRATE);
		chainTics  = int(clamp(CF('rsqmb_slow_chain', 3.0), 0.0, 20.0) * TICRATE);
		maxTics    = max(slowTics, int(clamp(CF('rsqmb_slow_max', 12.0), 1.0, 60.0) * TICRATE));
		int dp     = CI('rsqmb_slow_depth', -1);
		depthPct   = dp > 0 ? clamp(dp, 5, 95) : int(clamp(CF('rsm_depth', 0.25), 0.05, 0.95) * 100);
		greedOn    = CI('rsqmb_greed', 1) != 0;
		rageSpeed  = clamp(CF('rsqmb_rage_speed', 2.0), 1.0, 4.0);
		scoreOn    = CI('rsqmb_score', 1) != 0;
		debug      = CI('rsqmb_debug', 0) != 0;
		fxOn       = CLocal('rsqmb_fx', 1) != 0;
		double fr  = CLocal('rsqmb_fx_range', 4000);
		fxRange2   = fr * fr;
	}

	private void FindServices()
	{
		svcChecked = true;
		let it = ServiceIterator.Find("RSQSM_Service");
		smSvc = it.Next();
		it = ServiceIterator.Find("RS_ScoreService");
		scoreSvc = it.Next();
	}

	// ---- the level -------------------------------------------------------------------------------
	override void OnRegister() { cvTic = -1; svcChecked = false; }

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame || e.IsReopen) return;
		chosen = false; bosses.Clear(); windowEnd = 0; nextPulse = 0; rageCount = 0; raged.Clear();
	}

	// Leaving the level: everything the greed rule changed is put back (a hub keeps its monsters).
	override void WorldUnloaded(WorldEvent e) { RestoreAll(); }

	override void WorldTick()
	{
		Refresh();
		double t0 = debug ? MSTimeF() : 0;
		Tick2();
		if (debug) { double dt = MSTimeF() - t0; costMs += dt; costTics++; }
	}

	void AddCost(double ms) { costMs += ms; }

	private void Tick2()
	{
		int now = level.maptime;
		if (!chosen && now >= SELECT_AT)
		{
			chosen = true;
			if (CI('rsqmb_enabled', 1) && random[rsqmb](1, 100) <= CI('rsqmb_map_chance', 100)) Choose(CI('rsqmb_per_map', 1));
		}
		if (bosses.Size() == 0) return;

		// The slow window: SlowMo is asked again each second while it lasts (it keeps the longest hold).
		if (windowEnd > now && now >= nextPulse)
		{
			nextPulse = now + TICRATE;
			if (!svcChecked) FindServices();
			if (smSvc)
			{
				int ms = min(5000, (windowEnd - now) * 1000 / TICRATE);
				EventHandler.SendNetworkEvent("rsm_pulse", ms, depthPct);
			}
		}

		// Greed comes due.
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || !b.greedArmed) continue;
			if (b.done || b.Living() == 0) { b.greedArmed = false; continue; }
			b.greedDeadline = max(b.greedDeadline, windowEnd);
			if (now >= b.greedDeadline) { b.greedArmed = false; Enrage(b); }
		}

		// The enraged show it: a red spark rising off each one near the viewer, every 8 tics.
		if (rageCount > 0 && fxOn && now % 8 == 0) RageFX();
	}

	// ---- choosing --------------------------------------------------------------------------------
	static bool Eligible(Actor a)
	{
		return a && !a.player && a.bISMONSTER && a.bCOUNTKILL && !a.bFRIENDLY && a.health > 10
			&& !a.FindInventory("RSQMB_Token", true) && !Has(a, "champion_CloneToken");
	}

	void Choose(int count)
	{
		if (count <= 0) return;
		double t0 = MSTimeF();
		Choose2(count);
		if (debug) Console.Printf("RSQMB choose: %.3f ms (once)", MSTimeF() - t0);
	}

	private void Choose2(int count)
	{
		double radius = clamp(CI('rsqmb_radius', 1024), 256, 4096);
		int want = clamp(CI('rsqmb_thralls', 3), 1, 8);

		Array<Actor> mons;
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next())) if (Eligible(a)) mons.Push(a);

		// Miniboss candidates, strongest first (insertion sort: once a level, a few hundred at most).
		Array<Actor> cand;
		for (int i = 0; i < mons.Size(); i++)
		{
			let m = mons[i];
			if (m.bBOSS || Has(m, "champion_DarkRedToken") || Has(m, "champion_UndyingToken")) continue;
			int k = cand.Size();
			cand.Push(m);
			while (k > 0 && cand[k - 1].SpawnHealth() < m.SpawnHealth()) { cand[k] = cand[k - 1]; k--; }
			cand[k] = m;
		}

		Array<Actor> taken;
		for (int placed = 0, tries = 0; placed < count && tries < 24 && cand.Size() > 0; tries++)
		{
			// From the strongest third, weighted by spawn health: a Baron among imps is nearly always it.
			int pool = max(1, (cand.Size() + 2) / 3);
			double sum = 0;
			for (int k = 0; k < pool; k++) sum += max(1, cand[k].SpawnHealth());
			double r = frandom[rsqmb](0, sum);
			int pick = pool - 1;
			for (int k = 0; k < pool; k++) { r -= max(1, cand[k].SpawnHealth()); if (r <= 0) { pick = k; break; } }
			let mb = cand[pick];
			cand.Delete(pick);
			if (taken.Find(mb) < taken.Size() || TooClose(mb, radius * 1.5)) continue;
			Array<Actor> th;
			PickThralls(mb, mons, taken, radius, want, th);
			if (th.Size() == 0) continue;
			taken.Push(mb);
			for (int k = 0; k < th.Size(); k++) taken.Push(th[k]);
			Bind(mb, th);
			placed++;
		}
	}

	private bool TooClose(Actor mb, double dist)
	{
		for (int i = 0; i < bosses.Size(); i++)
			if (bosses[i] && bosses[i].mb && !bosses[i].done && bosses[i].mb.Distance3D(mb) < dist) return true;
		return false;
	}

	// Best first: a champion (+4), a legendary (+2), already transformed (+1); then the nearest.
	private void PickThralls(Actor mb, Array<Actor> mons, Array<Actor> taken, double radius, int want, out Array<Actor> th)
	{
		Array<Actor> c;
		Array<double> key;
		for (int i = 0; i < mons.Size(); i++)
		{
			let m = mons[i];
			if (m == mb || m.health <= 10 || taken.Find(m) < taken.Size()) continue;
			if (m.SpawnHealth() > mb.SpawnHealth()) continue;     // a Baron never serves an imp
			double d = mb.Distance3D(m);
			if (d > radius) continue;
			int score = 0;
			if (m.FindInventory("RSQMB_Token", true)) continue;
			let ct = InvClass(champTok);
			if (ct && m.FindInventory(ct, true)) score += 4;
			if (Has(m, "LDLegendaryMonsterToken")) score += 2;
			if (Has(m, "LDLegendaryMonsterTransformed")) score += 1;
			double k = score * 100000.0 - d;
			int j = c.Size();
			c.Push(m); key.Push(k);
			while (j > 0 && key[j - 1] < k) { c[j] = c[j - 1]; key[j] = key[j - 1]; j--; }
			c[j] = m; key[j] = k;
		}
		for (int i = 0; i < c.Size() && th.Size() < want; i++) th.Push(c[i]);
	}

	const champTok = "champion_Token";
	static const Color PALETTE[] = { "FF3CC8", "40E0FF", "FFB020", "A060FF" };

	void Bind(Actor mb, Array<Actor> th)
	{
		let b = RSQMB_Boss(new("RSQMB_Boss"));
		b.mb = mb;
		b.idx = bosses.Size();
		b.col = PALETTE[b.idx % PALETTE.Size()];
		b.toughness = 1.0;
		b.outMult = 1.0;
		b.bornAt = level.maptime;
		bool ld = Loaded("LDLegendaryMonsterToken");
		bool makeLegend = ld && CI('rsqmb_legend_thralls', 1) != 0;
		bool anyLegend = false;
		for (int i = 0; i < th.Size(); i++)
		{
			let t = th[i];
			b.thr.Push(t);
			b.thrState.Push(RSQMB_Boss.ST_ALIVE);
			let tok = RSQMB_Thrall(t.GiveInventoryType("RSQMB_Thrall"));
			if (tok) tok.boss = b;
			if (Has(t, "LDLegendaryMonsterToken")) anyLegend = true;
			else if (makeLegend && Loaded("LDLegendaryMonsterPickupGuaranteed"))
			{
				Give(t, "LDLegendaryMonsterPickupGuaranteed");
				anyLegend = true;
			}
		}
		b.total = th.Size();
		let w = RSQMB_Ward(mb.GiveInventoryType("RSQMB_Ward"));
		if (w) w.boss = b;
		int lifeBonus = Inherit(b, anyLegend);
		b.lives = clamp(CI('rsqmb_lives', 3), 1, 9) + lifeBonus;
		b.ownBuddha = mb.bBUDDHA;
		if (b.lives > 1) mb.bBUDDHA = true;
		b.maxHP = mb.health;
		bosses.Push(b);

		String pw = "";
		for (int i = 0; i < b.powers.Size(); i++) pw = pw .. (i ? ", " : "") .. b.powers[i];
		if (debug)
			Console.Printf("RSQMB bound: boss %d %s hp %d lives %d thralls %d powers [%s] tough %.2f out %.2f",
				b.idx, mb.GetClassName(), mb.health, b.lives, b.total, pw, b.toughness, b.outMult);
	}

	// ---- inheriting --------------------------------------------------------------------------
	// WHAT A "POWER" IS, read from the two mods' code:
	//   Champions: a colour (champion_<Colour>Token + a controller thinker that does the work) and a
	//   mutation (champion_TitanToken / UndyingToken / GhostToken / BalloonToken). A Hybrid carries two
	//   colour tokens. A controller cannot be made from outside without linking (its fields are typed),
	//   so a colour passes on in one of three ways:
	//     TOKEN  Yellow, White, Dark Green, Cyan, Titan: the token itself is given, and Champions' own
	//            handler does the rest (Yellow's faster missiles, White's slowing hits, Dark Green's
	//            poison, Cyan's knockback, Titan's three-way shots). Under champion_Dormant these sleep
	//            until the miniboss is a TRANSFORMED legendary, exactly as on a champion.
	//     LIFE   Dark Red (rises once), Undying (a heart keeps it up): +1 life each, at most +2.
	//     STAT   Black (Champions doubles its damage): +50% damage dealt (it stacks on LegenDoom's x2).
	//            Every other colour or mutation: +50% toughness (damage taken / toughness), at most x2.
	//   LegenDoom Lite: legendary status (LDLegendaryMonsterToken; Transformed at half health). Any
	//   legendary thrall makes the miniboss legendary too (LegenDoom Lite's own guaranteed pickup).
	// STACKING: the same colour twice counts once; at most rsqmb_inherit_max distinct powers, taken in
	// thrall order (best first); legendary is not counted against the cap.
	static const String COLOURS[] = {
		"DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo", "Violet",
		"Pink", "Magenta", "Black", "Grey", "White", "Bronze", "Silver", "Gold",
		"Titan", "Undying", "Ghost", "Balloon" };

	int Inherit(RSQMB_Boss b, bool anyLegend)
	{
		if (!CI('rsqmb_inherit', 1)) return 0;
		let mb = b.mb;
		int cap = clamp(CI('rsqmb_inherit_max', 4), 0, 12);
		int lifeBonus = 0;
		if (Loaded("champion_Token"))
		{
			for (int i = 0; i < b.thr.Size() && b.powers.Size() < cap; i++)
			{
				let t = b.thr[i];
				for (int c = 0; c < COLOURS.Size() && b.powers.Size() < cap; c++)
				{
					String n = COLOURS[c];
					String tok = "champion_" .. n .. "Token";
					if (!Has(t, tok) || b.powers.Find(n) < b.powers.Size()) continue;
					b.powers.Push(n);
					if (n == "Yellow" || n == "White" || n == "DarkGreen" || n == "Cyan" || n == "Titan")
					{
						if (!Has(mb, tok)) Give(mb, tok);
					}
					else if (n == "DarkRed" || n == "Undying") lifeBonus = min(2, lifeBonus + 1);
					else if (n == "Black") b.outMult = min(2.0, b.outMult * 1.5);
					else b.toughness = min(2.0, b.toughness + 0.5);
				}
			}
		}
		if (anyLegend && Loaded("LDLegendaryMonsterPickupGuaranteed"))
		{
			b.legendary = true;
			b.powers.Push("Legendary");
			if (!Has(mb, "LDLegendaryMonsterToken")) Give(mb, "LDLegendaryMonsterPickupGuaranteed");
		}
		return lifeBonus;
	}

	// ---- deaths and blows ------------------------------------------------------------------------
	static Actor PlayerOf(Actor src)
	{
		if (!src) return null;
		if (src.player) return src;
		if (src.FriendPlayer > 0 && playeringame[src.FriendPlayer - 1]) return players[src.FriendPlayer - 1].mo;
		if (src.target && src.target.player) return src.target;     // a puff or a missile
		return null;
	}

	// The killing blow names its source (a hitscan's WorldThingDied names only the puff).
	override void WorldThingDamaged(WorldEvent e)
	{
		if (!e.Thing || e.Thing.health > 0 || bosses.Size() == 0) return;
		Death(e.Thing, PlayerOf(e.DamageSource));
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (e.Thing && bosses.Size() > 0) Death(e.Thing, PlayerOf(e.Inflictor));
	}

	private void Death(Actor a, Actor killer)
	{
		let w = RSQMB_Ward(a.FindInventory("RSQMB_Ward"));
		if (w && w.boss && !w.boss.done) { BossDied(w.boss, killer); return; }
		let t = RSQMB_Thrall(a.FindInventory("RSQMB_Thrall"));
		if (!t || !t.boss || t.boss.done) return;
		let b = t.boss;
		int i = b.thr.Find(a);
		if (i >= b.thr.Size() || b.thrState[i] != RSQMB_Boss.ST_ALIVE) return;
		b.thrState[i] = RSQMB_Boss.ST_DEAD;
		bool inSlow = WindowActive();
		OpenWindow();
		a.A_StartSound("imp/shotx", CHAN_AUTO, 0, 1.0, 0.6);
		if (fxOn && b.mb) b.Shatter(RSQMB_Boss.Mid(a), RSQMB_Boss.Mid(b.mb));
		if (killer && inSlow) Award(killer, "Thrall Slow Kill", 100);
		if (debug) Console.Printf("RSQMB thrall %d of boss %d died (killer %s) living %d window %d tics%s",
			i, b.idx, killer ? "player" : "none", b.Living(), windowEnd - level.maptime, inSlow ? " CHAIN" : "");
	}

	void BossDied(RSQMB_Boss b, Actor killer)
	{
		if (b.done) return;
		bool greedy = b.Living() > 0 && !b.enraged;
		b.Finish();
		if (fxOn && b.mb) RSQMB_Boss.Burst(RSQMB_Boss.Mid(b.mb), b.col, 48, 7.0, 10);
		if (b.enraged) EndRage(b);
		if (killer)
		{
			Award(killer, "Miniboss", 500);
			if (greedy) Award(killer, "Greedy", 1000);
		}
		if (debug) Console.Printf("RSQMB boss %d died (killer %s)%s rage %d", b.idx, killer ? "player" : "none", (killer && greedy) ? " GREEDY" : "", rageCount);
	}

	// ---- the slow window ---------------------------------------------------------------------
	bool WindowActive() { return windowEnd > level.maptime; }

	void OpenWindow()
	{
		Refresh();
		int now = level.maptime;
		if (windowEnd > now) windowEnd = min(now + maxTics, windowEnd + chainTics);
		else windowEnd = now + slowTics;
		nextPulse = now;
	}

	// ---- greed -------------------------------------------------------------------------------
	void NoteGreed(RSQMB_Boss b)
	{
		Refresh();
		if (!greedOn || b.done || b.enraged || b.greedArmed || b.Living() == 0) return;
		b.greedArmed = true;
		b.greedy = true;
		b.greedDeadline = WindowActive() ? windowEnd : level.maptime + slowTics;
		if (debug) Console.Printf("RSQMB greed armed on boss %d: due in %d tics", b.idx, b.greedDeadline - level.maptime);
	}

	void Enrage(RSQMB_Boss b)
	{
		if (b.enraged || b.done) return;
		b.enraged = true;
		rageCount++;
		if (rageCount == 1)
		{
			double t0 = MSTimeF();
			let it = ThinkerIterator.Create("Actor");
			Actor a;
			while (a = Actor(it.Next())) RageOne(a);
			let pmo = players[consoleplayer].mo;
			if (pmo) pmo.A_StartSound("brain/sight", CHAN_AUTO, CHANF_UI, 0.8, ATTN_NONE);
			if (debug) Console.Printf("RSQMB rage start: %.3f ms (once)", MSTimeF() - t0);
		}
		if (debug) Console.Printf("RSQMB GREED: boss %d enraged, %d monsters x%.1f speed", b.idx, raged.Size(), rageSpeed);
	}

	void RageOne(Actor a)
	{
		if (!a || a.player || !a.bISMONSTER || a.bFRIENDLY || a.health <= 0 || !a.bSHOOTABLE || a.FindInventory("RSQMB_Rage")) return;
		// Brutal Doom's gore and props carry ISMONSTER: a thing that neither walks nor shoots is not one.
		if (a.Speed <= 0 && !a.MissileState && !a.MeleeState) return;
		let r = RSQMB_Rage(a.GiveInventoryType("RSQMB_Rage"));
		if (!r) return;
		r.Apply(a, rageSpeed);
		raged.Push(a);
	}

	void EndRage(RSQMB_Boss b)
	{
		b.enraged = false;
		rageCount--;
		if (rageCount <= 0) RestoreAll();
	}

	void RestoreAll()
	{
		for (int i = 0; i < raged.Size(); i++)
		{
			let a = raged[i];
			if (!a || a.bDestroyed) continue;
			let r = RSQMB_Rage(a.FindInventory("RSQMB_Rage"));
			if (!r) continue;
			r.Restore(a);
			r.Destroy();
		}
		raged.Clear();
		rageCount = 0;
	}

	override void WorldThingSpawned(WorldEvent e) { if (rageCount > 0) RageOne(e.Thing); }
	override void WorldThingRevived(WorldEvent e) { if (rageCount > 0) RageOne(e.Thing); }

	private void RageFX()
	{
		let view = players[consoleplayer].mo;
		if (!view) return;
		for (int i = 0; i < raged.Size(); i++)
		{
			let a = raged[i];
			if (!a || a.health <= 0) continue;
			Vector3 d = level.Vec3Diff(view.pos, a.pos);
			if (d dot d > 2500.0 * 2500.0) continue;
			RSQMB_Boss.P(a.pos + (frandom[rsqmbfx](-a.radius, a.radius) * 0.5, frandom[rsqmbfx](-a.radius, a.radius) * 0.5, a.height + 4),
				Color(255, 255, 32, 16), 6, 12, 0.85, (0, 0, 1.2), self);
		}
	}

	// ---- RSQ_Score, by name: just the push (its rows come later) ----------------------------------
	void Award(Actor who, String label, int points)
	{
		if (!scoreOn || !who || !who.player) return;
		if (!svcChecked) FindServices();
		if (scoreSvc) scoreSvc.GetInt("award", label, points, 0, who);
		if (debug) Console.Printf("RSQMB award \"%s\" %d -> %s", label, points, scoreSvc ? "RS_ScoreService" : "(no Score)");
	}

	// ---- console doors ----------------------------------------------------------------------
	//   netevent rsqmb_state     prints every miniboss
	//   netevent rsqmb_choose    picks minibosses again now (ignores the map chance)
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rsqmb_state") PrintState();
		else if (e.Name ~== "rsqmb_choose") { Refresh(); Choose(max(1, CI('rsqmb_per_map', 1))); PrintState(); }
	}

	void PrintState()
	{
		if (debug && costTics > 0)
			Console.Printf("RSQMB cost: %.4f ms/tic script over %d tics, particles %.1f/tic", costMs / costTics, costTics, fxParticles / double(costTics));
		costMs = 0; costTics = 0; fxParticles = 0;
		Console.Printf("RSQ_Miniboss: %d miniboss(es), window %d tics, rage %d (%d monsters), SlowMo %s, Score %s",
			bosses.Size(), max(0, windowEnd - level.maptime), rageCount, raged.Size(),
			Loaded("RSQSM_Service") ? "yes" : "no", Loaded("RS_ScoreService") ? "yes" : "no");
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b) continue;
			String pw = "";
			for (int k = 0; k < b.powers.Size(); k++) pw = pw .. (k ? "," : "") .. b.powers[k];
			Console.Printf("  boss %d %s hp %d/%d lives %d living %d/%d invuln %d shield %.2f tough %.2f out %.2f powers [%s]%s%s%s",
				i, b.mb ? b.mb.GetClassName() : 'gone', b.mb ? b.mb.health : 0, b.maxHP, b.lives, b.Living(), b.total,
				max(0, b.invulUntil - level.maptime), b.ShieldFactor(), b.toughness, b.outMult, pw,
				b.done ? " DONE" : "", b.enraged ? " ENRAGED" : "", b.greedArmed ? " GREED-ARMED" : "");
		}
	}
}
