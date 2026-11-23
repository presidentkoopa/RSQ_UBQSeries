// ============================================================================
// RSQ_Miniboss -- the set piece (an EventHandler: one per level, saved with it).
//
//   BOSSFIGHT  (owner 2026-11-05) the set piece is CALLED IN: bossfight.zs (the meter, the call-in, the arrival in
//              view, the payoff), bound here (Bind). The old pick at level load ("Classic Pick at Level Load") was cut
//              2026-11-12 (owner; design/MINIBOSS_CLEANUP_AUDIT.md 3.1 c): every miniboss is a called-in one.
//   LEGENDARY  With LegenDoom Lite 4.2 or LegenDoom 3.0 (full) loaded and rsqmb_legend_thralls on, every thrall is made
//              legendary with LegenDoom's own LDLegendaryMonsterPickupGuaranteed (by name; both ship it, with the same
//              tokens and LDMonsterInit; 3.0's drop is a weapon, the LDL x BD22 VR patch's BD22 VR gun). A dormant
//              champion (Champions' champion_Dormant) wakes when its legendary transforms.
//   INHERITING see Inherit() below: the rule and its caps.
//   THE FIGHT  (owner 2026-11-17) fight.zs: living thralls cut the Boss's damage (the original's rule, items.zs), a
//              thrall's death takes its power, nothing in the fight changes colour or body (HoldTiers), the words, the
//              room's glow. (The shield segments, the windows and their slow motion, the missed-window and per-life tier-ups,
//              "GUARD!", the grey Xs and the greed rule are gone: owner 2026-11-17.)
// ============================================================================

class RSQMB_Handler : EventHandler
{
	const SELECT_AT = 10;

	// ---- synced state (in the save) --------------------------------------------------------------
	bool   chosen;          // unused since the classic pick was cut (2026-11-12); kept so old saves read the same
	Array<RSQMB_Boss> bosses;

	// ---- settings, read once a tic ---------------------------------------------------------------
	transient int    cvTic;
	transient double invulSecs;
	transient bool   fxOn, debug, scoreOn, roarOn, noMorphOn;
	transient int    depthPct;

	// ---- the cost meter (rsqmb_debug only): script time this mod spends, ms, since the last report
	transient double costMs;
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
	static clearscope bool Has(Actor a, String n)
	{
		class<Inventory> c = n;
		return a && c && a.FindInventory(c);
	}
	static clearscope class<Inventory> InvClass(String n) { class<Inventory> c = n; return c; }
	static void Give(Actor a, String n) { let c = InvClass(n); if (a && c) a.GiveInventory(c, 1); }
	static clearscope bool Loaded(String cls) { return cls != "" && Object.FindClass(cls) != null; }
	// BOSS EFFECTS (rsqmb_bossfx, CVARINFO.txt; owner 2026-11-22): Light (0, the default) draws fewer of the repeated pieces,
	// Full (1) every count as before. A server setting, read where the pieces are made.
	static clearscope bool FxLight() { return CI('rsqmb_bossfx', 0) == 0; }

	void Refresh()
	{
		if (cvTic == level.maptime) return;
		cvTic = level.maptime;
		invulSecs  = clamp(CF('rsqmb_invuln', 5.0), 0.0, 30.0);
		int dp     = CI('rsqmb_slow_depth', -1);
		depthPct   = dp > 0 ? clamp(dp, 5, 95) : int(clamp(CF('rsm_depth', 0.25), 0.05, 0.95) * 100);
		scoreOn    = CI('rsqmb_score', 1) != 0;
		debug      = CI('rsqmb_debug', 0) != 0;
		roarOn     = CI('rsqmb_boss_roar', 0) != 0;
		noMorphOn  = CI('rsqmb_boss_nomorph', 0) != 0;
		fxOn       = CLocal('rsqmb_fx', 1) != 0;
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
		ChampForce(false);   // an arrival cut short by a save, a load or a quit: Champions' own Override Chance back (bossfight.zs)
		// (the Big Boss bar kept through a death's reload: asked on the first tic, WorldTick, which a savegame load reaches too)
		// a hub level entered again: the tiers this mod gave its monsters are put back (fight.zs TierReset; owner 07:15)
		if (e.IsReopen) TierReset();
		if (e.IsSaveGame || e.IsReopen) return;
		bosses.Clear();
		bfScanned = false; bfCount = 0; bfLastTic = 0; bfAny = false; bfBoss = null; arrPhase = 0; arrQuiet = false; rerollAt = 0; arrBig = false;
	}

	// Leaving the level with a fight on is a loss (tierup.zs LossOnLeave, rule doc 4, 2026-11-16).
	override void WorldUnloaded(WorldEvent e) { LossOnLeave(e); TierUpFlush(); }

	// THE BIG BOSS BAR KEPT THROUGH A DEATH'S RELOAD (bigboss.zs ExKeepLoad), asked on the FIRST TIC after this level began or
	// was loaded: this handler is saved with the level, and on a savegame load it gets no WorldLoaded (rig 2026-11-16 gd3 and
	// fix_mbgcgd: a non-static handler's WorldLoaded did not run on "load"), while a transient field is false again after
	// any load. (bug check E item 3 / NEW-MB-A)
	transient bool liveTic;
	override void WorldTick()
	{
		Refresh();
		double t0 = debug ? MSTimeF() : 0;
		Tick2();
		BfTick();
		FightTick();
		CampTick();                      // camp.zs: camping in a fight sends a thrall straight at you (design/BOSS_REWORK.md 4)
		if (bosses.Size()) BigTick();    // bigfix.zs: a Big Boss held to its life's health once LegenDoom's rise is past
		TeleTick();                      // telegraph.zs: every Boss's telegraphed attack and BREAK! (BOSS_REWORK.md 3); finisher.zs's finishers
		if (tuAt.Size()) TierUpTick();   // tierup.zs
		LossTick();                      // tierup.zs: a Score life spent during a fight is a loss; the beams out; the tier-downs
		if (!liveTic) { liveTic = true; ExKeepLoad(); RageLegacy(); }   // bigboss.zs: a death's reload (a new map start or a savegame load); a save from before greed went
		HoldTiers();                     // fight.zs: nothing in a fight changes colour or body (owner 2026-11-17)
		ExKeepTick();                    // bigboss.zs: the Big Boss bar given back after a death's reload
		if ((bosses.Size() || arrPhase || (fxp && fxp.shots.Size())) && fxOn && UseSprites()) FxEnsureDriver();
		if (debug) { double dt = MSTimeF() - t0; costMs += dt; costTics++; }
	}

	void AddCost(double ms) { costMs += ms; }

	private void Tick2()
	{
		int now = level.maptime;
		if (!bfScanned && now >= SELECT_AT) BfScan();
	}

	// ---- who may be a set piece's type: a counting, hostile, non-player monster (bossfight.zs BfScan) -------------
	static bool Eligible(Actor a)
	{
		return a && !a.player && a.bISMONSTER && a.bCOUNTKILL && !a.bFRIENDLY && a.health > 10
			&& !a.FindInventory("RSQMB_Token", true) && !Has(a, "champion_CloneToken");
	}

	static const Color PALETTE[] = { "FF3CC8", "40E0FF", "FFB020", "A060FF" };

	// THE ORIGINAL'S minibosscolor (minibosscontroller.txt: r, g and b each random(0, 255), once a miniboss): the stencil
	// shade of every effect of its set piece (fx.zs)
	static Color RandomFxColour()
	{
		return Color(255, random[rsqmbfx](0, 255), random[rsqmbfx](0, 255), random[rsqmbfx](0, 255));
	}

	void Bind(Actor mb, Array<Actor> th)
	{
		let b = RSQMB_Boss(new("RSQMB_Boss"));
		b.mb = mb;
		b.idx = bosses.Size();
		b.col = ColourOf(mb, b.idx) | 0xFF000000;    // its RSQ ladder colour (fight.zs), else the palette as before
		b.fxCol = RandomFxColour();
		b.toughness = 1.0;
		b.outMult = 1.0;
		b.wordState = -9;
		b.glowSent = -1;
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
		b.ownFullSee = mb.bFULLVOLSEE; b.ownFullDeath = mb.bFULLVOLDEATH; b.ownDontMorph = mb.bDONTMORPH;
		Refresh();
		b.Flags(roarOn, noMorphOn, debug);
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

	// the lives Inherit() will add, worked out from the thralls that have landed (the same rule and caps, nothing given):
	// the HUD shows the real count during a Bossfight's landing, so the bars don't jump at the bind (owner 11-10)
	clearscope int LifeBonusPreview()
	{
		if (!CI('rsqmb_inherit', 1) || !Loaded("champion_Token")) return 0;
		int cap = PowerCap();
		Array<String> pw;
		int lifeBonus = 0;
		for (int i = 1; i < arrMon.Size() && pw.Size() < cap; i++)
		{
			let t = arrMon[i];
			if (i >= arrState.Size() || arrState[i] != 2 || !t || t.health <= 0) continue;
			for (int c = 0; c < COLOURS.Size() && pw.Size() < cap; c++)
			{
				String n = COLOURS[c];
				if (!Has(t, "champion_" .. n .. "Token") || pw.Find(n) < pw.Size()) continue;
				pw.Push(n);
				if ((n == "DarkRed" || n == "Undying") && lifeBonus < 2) lifeBonus++;
			}
		}
		return lifeBonus;
	}

	// FIVE POWERS (owner 11-12 14:24: "at most five different powers"): Power Cap's default is 5; a saved 4, the old
	// default, reads as 5 (a saved value outlives a new default)
	static clearscope int PowerCap() { int c = clamp(CI('rsqmb_inherit_max', 5), 0, 12); return c == 4 ? 5 : c; }
	int Inherit(RSQMB_Boss b, bool anyLegend)
	{
		if (!CI('rsqmb_inherit', 1)) return 0;
		let mb = b.mb;
		int cap = PowerCap();
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
					b.powerFrom.Push(i);     // lost with this thrall (owner 06:42: LOSE; boss.zs StripPowers)
					int added = 0;
					if (n == "Yellow" || n == "White" || n == "DarkGreen" || n == "Cyan" || n == "Titan")
					{
						if (!Has(mb, tok)) { Give(mb, tok); added = 1; }
					}
					else if (n == "DarkRed" || n == "Undying") { if (lifeBonus < 2) { lifeBonus++; added = 1; } }
					else if (n == "Black") { if (b.outMult < 2.0) { b.outMult = min(2.0, b.outMult * 1.5); added = 1; } }
					else if (b.toughness < 2.0) { b.toughness = min(2.0, b.toughness + 0.5); added = 1; }
					b.powerAdd.Push(added);
				}
			}
		}
		if (anyLegend && Loaded("LDLegendaryMonsterPickupGuaranteed"))
		{
			b.legendary = true;
			b.powers.Push("Legendary");
			b.powerFrom.Push(-1);
			b.powerAdd.Push(0);
			if (!Has(mb, "LDLegendaryMonsterToken"))
			{
				LDBossHealth(b);
				Give(mb, "LDLegendaryMonsterPickupGuaranteed");
			}
		}
		return lifeBonus;
	}

	// LEGENDOOM: BEST HEALTH (rsqmb_boss_ldhealth, owner 2026-11-03: the HIGHER of LegenDoom's boss and normal legendary
	// health; with LegenDoom Lite's defaults, 300 % normal vs 200 % boss, that is the normal 300 %). Where a miniboss's legendary health is set: not
	// here. LegenDoom Lite's guaranteed pickup runs its ACS, LEGNDLIB.acs LDMonsterInit, which reads the monster's
	// spawn health (APROP_SpawnHealth = StartHealth, or the class's health, x the skill) ONCE, multiplies it by
	// LD_legendaryhealthboss / 100 if CheckFlag(BOSS) else LD_legendaryhealth / 100 (integer division of the
	// percentage), sets that health, keeps the number in a script local and refills to it once at its half (the
	// transform). The miniboss is never BOSS-flagged, so it would get LD_legendaryhealth. Without touching the flag,
	// it is given the better number by its spawn health: when the boss factor is the higher, StartHealth is scaled by
	// boss / normal for the tic or two until the ACS has read it (LDHealthDone puts it back), so the set health and the
	// transform's refill are both spawn x LD_legendaryhealthboss / 100 (to within the rounding of one StartHealth point
	// x the normal factor). When the normal factor is the higher (or equal), LegenDoom's own result already is it.
	// LegenDoom 3.0 (full) has LD_legendarymonsters (LEGENDMON.acs LDMonsterInit): 0 "Disabled" gives a legendary NO
	// health at all (no x LD_legendaryhealth, no transform), 1 "Enabled" and 2 "Mod behaviour only" give it as Lite does.
	// LegenDoom Lite 4.2 has no such cvar (CI's default 1: always on). With it at 0 there is no legendary health to make
	// the better of, so nothing is asked and "ldhealth" stays 0 (rig 11-04: it answered 1 on a plain 80 hp imp).
	void LDBossHealth(RSQMB_Boss b)
	{
		if (CI('rsqmb_boss_ldhealth', 1) == 0) return;
		let mb = b.mb;
		if (CI('LD_legendarymonsters', 1) == 0)
		{
			if (debug) Console.Printf("RSQMB LegenDoom best health: %s skipped, LD_legendarymonsters 0 (LegenDoom gives legendaries no health)", mb.GetClassName());
			return;
		}
		int nm = CI('LD_legendaryhealth', 300) / 100, bm = CI('LD_legendaryhealthboss', 200) / 100;
		int spawn = mb.SpawnHealth();
		int best = max(nm, bm);
		b.ldTarget = spawn * best;
		b.ldBoss = true;     // its legendary health is spawn x max(boss, normal) / 100: the readers' rule (RSQMB_Service "ldhealth")
		if (nm <= 0 || best == nm)
		{
			// the normal factor is the better (or LegenDoom's 0): LegenDoom's own result stands, nothing to scale
			if (debug) Console.Printf("RSQMB LegenDoom best health: %s spawn %d x %d (normal %d%%) >= boss x %d (%d%%): LegenDoom's own number",
				mb.GetClassName(), spawn, nm, CI('LD_legendaryhealth', 300), bm, CI('LD_legendaryhealthboss', 200));
			return;
		}
		b.ldBoss = false;    // set again by LDHealthDone once LegenDoom has given it
		int own = mb.StartHealth;
		int base = own > 0 ? own : GetDefaultByType(mb.GetClass()).health;
		b.ldShOwn = own;
		mb.StartHealth = max(1, int(round(base * double(bm) / nm)));
		b.ldShPending = true;
		b.ldShUntil = level.maptime + TICRATE;
		if (debug) Console.Printf("RSQMB LegenDoom best health asked: %s spawn %d x %d (boss %d%%) not x %d (%d%%): StartHealth %d -> %d for its ACS",
			mb.GetClassName(), spawn, bm, CI('LD_legendaryhealthboss', 200), nm, CI('LD_legendaryhealth', 300), own, mb.StartHealth);
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
		DpsNote(e);   // bigfix.zs: the player's damage per second, for the Big Boss's health (design/BOSS_REWORK.md 9)
		FinDamaged(e);     // finisher.zs: a melee strike on a staggered thrall or a Boss in BREAK! (BOSS_REWORK.md 4)
		if (!e.Thing || e.Thing.health > 0 || bosses.Size() == 0) return;
		Death(e.Thing, PlayerOf(e.DamageSource));
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (e.Thing && bosses.Size() > 0) Death(e.Thing, PlayerOf(e.Inflictor));
		if (e.Thing && bfScanned)
		{
			Actor k = PlayerOf(e.Inflictor);
			if (!k && e.Thing.target && e.Thing.target.player) k = e.Thing.target;
			BfKill(e.Thing, k);
		}
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
		// (imp/shotx: its marker plays it as it explodes, the original's way: fx.zs RSQMB_ThrallFx)
		ThrallKilled(b, i, a, killer);     // fight.zs: its power lost
		if (debug) Console.Printf("RSQMB thrall %d of boss %d died (killer %s) living %d", i, b.idx, killer ? "player" : "none", b.Living());
	}

	// a living thrall destroyed without dying (removed by a script, gibbed away): counted as killed
	void ThrallGone(RSQMB_Boss b, int i)
	{
		if (debug) Console.Printf("RSQMB thrall %d of boss %d gone without dying: counted as killed", i, b.idx);
		ThrallKilled(b, i, null, null);
	}

	void BossDied(RSQMB_Boss b, Actor killer)
	{
		if (b.done) return;
		b.Finish();
		FxBossDied(b);
		FightDeath(b);     // fight.zs: the map-wide wave in its colour, then the re-roll
		BfPayoff(b, killer);
		SceneMusic(false);   // the fight is over: the level music crossfades back (bossfight.zs)
		// one row, "Miniboss Called": 3x the kill (owner 11-10: "one reward"). Every miniboss is a called-in one now (the
		// classic pick, which paid "Miniboss" at 1x, was cut 2026-11-12).
		if (killer) Award(killer, "Miniboss Called", 1500);
		TierUpOnKill(b, killer);   // tierup.zs: Miniboss Kills Tier Up Monsters (owner 11-15 19:41)
		if (debug) Console.Printf("RSQMB boss %d died (killer %s)", b.idx, killer ? "player" : "none");
	}

	// ---- greed is gone (owner 2026-11-17): a save from before, loaded with monsters it enraged, gets them back as they were
	void RageLegacy()
	{
		let it = ThinkerIterator.Create("RSQMB_Rage");
		Array<RSQMB_Rage> old;
		RSQMB_Rage r;
		while (r = RSQMB_Rage(it.Next())) old.Push(r);
		for (int i = 0; i < old.Size(); i++)
		{
			r = old[i];
			if (r.Owner && !r.Owner.bDestroyed) r.Restore(r.Owner);
			r.Destroy();
		}
		if (debug && old.Size()) Console.Printf("RSQMB: %d monster(s) a save's greed rule had enraged put back", old.Size());
	}

	transient RSQMB_SwapCatch swapCatch;
	// LEGENDOOM'S AFTER-IMAGES (owner 2026-11-22: "the legendoom lighting effect ... a hit on my pc"). LegenDoom 3.0 (its own
	// pk3, not edited) gives every transformed legendary monster a ghost every tic (LEGENDMON.acs, the
	// LDLegendaryMonsterVisualEffectMaker): a fading copy, LDLegendaryMonsterVisualEffectStandard or one of its colours, each
	// with a flicker light of 80 to 100 (lights/monsters.light) for its 4 to 5 tics, so about 5 lights on every such monster
	// at once. Boss Effects Light keeps the ghosts of two tics in four (the tics whose bit 1 is clear: both of LegenDoom's
	// alternating shades still show) and ends the others the tic they spawn: about half the ghosts and half the lights, on
	// every legendary (the ghost carries no master, so whose it is cannot be told). Full: every one, as LegenDoom draws it.
	// Found by name: without LegenDoom there is no such class and nothing is looked at.
	transient bool ldGhostLooked;
	transient class<Actor> ldGhost;
	override void WorldThingSpawned(WorldEvent e)
	{
		if (!ldGhostLooked)
		{
			ldGhostLooked = true;
			String gn = "LDLegendaryMonsterVisualEffectStandard";
			class<Actor> gc = gn;
			ldGhost = gc;
		}
		if (ldGhost && e.Thing && (level.maptime & 2) != 0 && e.Thing is ldGhost && FxLight())
		{
			// gone at once and unseen: hidden, and into the engine's Null state (TNT1, no light; it ends itself next tic).
			// Not destroyed here, so every other mod's WorldThingSpawned still gets a live e.Thing
			e.Thing.bInvisible = true;
			e.Thing.SetStateLabel("Null");
			return;
		}
		// a swapped set-piece body has been past Champions' handler now: its temporary NullToken off (carry.zs)
		if (!swapCatch) swapCatch = RSQMB_SwapCatch.Get();
		if (swapCatch && swapCatch.nullTemp.Size()) swapCatch.TakeNull(e.Thing);
	}
	// ---- RSQ_Score, by name: the awards (Score's own rows read Miniboss through its service) ----------
	void Award(Actor who, String label, int points)
	{
		if (!scoreOn || !who || !who.player) return;
		if (!svcChecked) FindServices();
		if (scoreSvc) scoreSvc.GetInt("award", label, points, 0, who);
		if (debug) Console.Printf("RSQMB award \"%s\" %d -> %s", label, points, scoreSvc ? "RS_ScoreService" : "(no Score)");
	}

	// ---- console doors ----------------------------------------------------------------------
	//   netevent rsqmb_state     prints every miniboss
	//   netevent rsqmb_callin    calls a full Bossfight meter in (bossfight.zs CallIn)
	//   netevent rsqmb_fill <permille>  sets the meter (test; 1000 = full now)
	//   netevent rsqmb_exfill <permille>  sets the Big Boss bar (test; -1 = +25%, 1000 = full now: bigboss.zs)
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rsqmb_state") { PrintState(); BfState(); }
		else if (e.Name ~== "rsqmb_callin") CallIn(e.Player, e.Args[0] == 1);
		else if (e.Name ~== "rsqmb_exfill") ExFillTest(e.Player, e.Args[0]);
		else if (e.Name ~== "rsqmb_fill")
		{
			// test door: the meter to Args[0] permille (1000: full now)
			let m = MeterOf(players[e.Player].mo, true);
			if (m) { m.ready = false; m.fill = clamp(e.Args[0], 0, 999); if (e.Args[0] >= 1000) Ready(m); }
		}
	}

	void PrintState()
	{
		if (debug && costTics > 0)
			Console.Printf("RSQMB cost: %.4f ms/tic script over %d tics, particles %.1f/tic, one-shot sprites %.1f/tic shown (peak %d, pool %d), %.1f moves/tic, %d spawned",
				costMs / costTics, costTics, fxParticles / double(costTics), fxShown / double(costTics), fxPeak, fxp ? fxp.pool.Size() : 0,
				fxWrites / double(costTics), fxSpawned);
		costMs = 0; costTics = 0; fxParticles = 0; fxShown = 0; fxWrites = 0; fxSpawned = 0; fxPeak = 0;
		Console.Printf("RSQ_Miniboss: %d miniboss(es), SlowMo %s, Score %s",
			bosses.Size(), Loaded("RSQSM_Service") ? "yes" : "no", Loaded("RS_ScoreService") ? "yes" : "no");
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b) continue;
			String pw = "";
			for (int k = 0; k < b.powers.Size(); k++) pw = pw .. (k ? "," : "") .. b.powers[k];
			Console.Printf("  boss %d %s hp %d/%d lives %d living %d/%d invuln %d takes %.2f (thralls x%.2f) scale x%.2f tough %.2f out %.2f powers [%s]%s",
				i, b.mb ? b.mb.GetClassName() : 'gone', b.mb ? b.mb.health : 0, b.maxHP, b.lives, b.Living(), b.total,
				max(0, b.invulUntil - level.maptime), b.TakeFactorData(), b.ThrallFactor(), b.mbK > 0 ? b.mbK : MB_SCALE,
				b.toughness, b.outMult, pw, b.done ? " DONE" : "");
		}
	}
}
