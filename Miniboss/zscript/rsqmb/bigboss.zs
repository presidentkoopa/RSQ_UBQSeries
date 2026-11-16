// ============================================================================
// RSQ_Miniboss -- THE BIG BOSS (owner 2026-11-16 08:40: "An EX Tier Boss Bar is a good idea. For now let's build it such
// that every Boss we kill, the EX bar fills by 25%, when maxxed, it calls in a Bossfight with an EX tier monster with
// thralls. Reward is a guarenteed legendary kiosk with all epic or legendary loot or whatever." 08:40: the EX-tier ones
// are called "Big Boss"). design/BIG_BOSS.md. Player-facing words say BIG BOSS; code keeps "ex" / "big".
//
//   THE BAR       the Big Boss bar ("EX bar"), on the player (RSQMB_Meter.exFill 0..1000: it rides the save and every map
//                 change, as RSQ Score's gold bank does, and is kept through a death's reload the same way: rsqmb_ex_keep).
//                 +25% (EX_STEP) for every Boss won (tierup.zs TierUpOnKill: the BOSSWIN moment, a called-in fight's Boss
//                 killed by a player). A Big Boss won adds nothing. Drawn beside the Boss meter (hud.zs DrawExBar).
//   FULL          a Big Boss is due (exReady). It is not called in: it COMES BY ITSELF as soon as the Boss fight's
//                 guardrails let it (bossfight.zs Guard: Too Early, Cooldown, Low Health, Near Exit, Too Busy, No Room;
//                 Ignore Spawn Restrictions works on it as on a Boss), but never held by the Map Limit (it would often wait a
//                 whole map). It goes before a full Boss meter; the Boss meter waits (and its Start Fight card stays grey)
//                 until the Big Boss fight is over.
//   THE FIGHT     the Boss fight's own machinery (bossfight.zs PlanArrival / StartArrival / ArrivalStep, handler.zs Bind,
//                 fight.zs): the same thralls, beams, slow motion, charge, segments, shield, lives and rules. Only the
//                 monster differs: an EX-tier monster of RSQ Monsters (BigClass below). Its health is on the Boss bar
//                 (bossbar.zs, unchanged). The Big Boss bar empties when the fight starts (its bind).
//   BANNERS       RSQ VisualRewards' (by name): BIGBOSSINCOMING (BIG BOSS INCOMING!, with BOSS INCOMING!'s siren),
//                 BIGBOSSWIN (BIG BOSS DEFEATED!), BIGBOSSLOSS (BIG BOSS WINS!); the chips as the Boss's.
//   THE WIN       as a Boss win (the world tier +1, RSQ Score's life crate, the Score row) and the Boss kiosk, every offer
//                 Epic (kiosk.zs Drop: LegenDoom's top rarity) in place of its one legendary weapon.
//   THE LOSS      as a Boss fight's (tierup.zs FightLost: a Score life spent in it, or the map left with it on): the
//                 monsters leave on beams, the world tier -1, BIG BOSS WINS!; the Big Boss bar stays empty (it emptied when
//                 the fight started), so four more Bosses bring the next one.
//   OPTIONS       Big Boss (rsqmb_ex, on) on RSQ Boss's page; test: netevent rsqmb_exfill <permille> (-1: +25%), with
//                 sv_cheats or Debug Log on; also the Test and Debug page's row.
// Rig only, not headset-confirmed.
// ============================================================================

extend class RSQMB_Handler
{
	const EX_STEP = 250;          // a Boss won: +25% of the Big Boss bar
	const RGB_EX = 0xFFC830;      // the Big Boss bar's colour (gold, the legendary colour; provisional, owner 11-16)

	bool arrBig;                  // the arrival under way is a Big Boss's (in the save)

	static clearscope bool ExOn() { return BfOn() && CI('rsqmb_ex', 1) != 0; }
	static clearscope bool ExDue(RSQMB_Meter m) { return m && m.exReady && ExOn(); }

	// ---- the bar fills: a Boss won (tierup.zs TierUpOnKill, before its banner) ---------------------------------------------
	void ExWin(RSQMB_Boss b, Actor killer)
	{
		if (!b || b.big || !killer || !killer.player) return;
		if (!ExOn()) { if (debug) Console.Printf("RSQMB Big Boss bar: off (rsqmb_ex 0): nothing filled"); return; }
		let m = MeterOf(killer, true);
		if (!m) return;
		if (m.exReady) { if (debug) Console.Printf("RSQMB Big Boss bar: already full, a Big Boss due: it stays full"); return; }
		double was = m.exFill;
		m.exFill = min(1000.0, m.exFill + EX_STEP);
		if (m.exFill >= 1000.0) ExReady(m);
		if (debug) Console.Printf("RSQMB Big Boss bar t%d: a Boss won: %d%% -> %d%%%s", level.maptime, int(was / 10), int(m.exFill / 10),
			m.exReady ? ": FULL, a Big Boss is due" : "");
	}

	void ExReady(RSQMB_Meter m)
	{
		m.exFill = 1000;
		m.exReady = true;
		m.exReadyAt = level.maptime;
		Glow(RGB_EX, 0.8);      // RSQ Glow In The Dark's map glow in the bar's gold (the Boss meter's red, full)
	}

	// empty (the Big Boss fight's bind; the test door)
	static void ExEmpty(RSQMB_Meter m)
	{
		if (!m) return;
		m.exFill = 0; m.exReady = false; m.exReadyAt = 0;
	}

	// ---- BfTick: a due Big Boss comes by itself, ahead of a full Boss meter. True: a Big Boss is due (the Boss waits) ------
	bool ExTick()
	{
		if (!ExOn()) return false;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let m = MeterOf(players[pn].mo);
			if (!ExDue(m)) continue;
			if (level.maptime >= bfNextTry) { bfNextTry = level.maptime + 10; TryArrive(players[pn].mo, m, true); }
			return true;
		}
		return false;
	}

	// ---- WHICH EX MONSTER: THE BIG BOSS POOL ------------------------------------------------------------------------------
	// RSQ Monsters' EX tier, found, never listed here, so a new EX boss joins without an edit to this pack (coordinator
	// 2026-11-16 09:21: Colourful Hell Plus's EX bosses are being ported into RSQ Monsters). The pool is built once a map:
	//   1  EVERY LOADED MONSTER CLASS WHOSE NAME ENDS IN "EX" (RSQ Monsters' own definition of an EX form: RS_TierLadder
	//      IsEXName, its "ex" request) that RSQ Monsters puts at a boss colour: its roster service, by name, answers
	//      "class.tier" Black (12) or White (13). That takes Colorful Hell's EX bosses (RS_BlackImpEX ... RS_WhiteSGEX,
	//      RS_WhiteLSoulEX) and any new one built the same way (RS_<gate>EX), and leaves out the EX projectiles (not
	//      monsters) and minions (no ladder tier).
	//   2  THE REGISTRY: every lump named RSQBIGBS in any loaded pack (RSQBIGBS.txt; all of them are read, so each pack
	//      adds its own), one monster class name a line ("//" comments): an EX boss that is not named *EX or not on
	//      the ladder joins here (e.g. a White Mastermind). A name that is not a loaded monster class is passed over.
	// THE PICK: the pool's EX bosses of a family that is on this map come first (the map's roster types: the same family by
	// RSQ Monsters' gate, "set.class" at 12 / 13 + "EX", or by the Boss bar's clean name: CYBERDEMON, IMP ...); one of them
	// at random, else any of the pool at random. An empty pool (no RSQ Monsters, nothing registered): the map's strongest
	// type (my reading: there is no EX tier to take one from).
	transient Array<String> exPool;
	transient int exPoolMap;      // level.levelnum + 1 the pool was built for
	static bool IsMonsterClass(class<Actor> c)
	{
		if (!c) return false;
		let d = GetDefaultByType(c);
		return d && d.bISMONSTER && d.health > 0;
	}
	void ExPoolBuild()
	{
		if (exPoolMap == level.levelnum + 1 && exPool.Size()) return;
		exPoolMap = level.levelnum + 1;
		exPool.Clear();
		let mn = MnService();
		int found = 0, reg = 0;
		if (mn)
		{
			for (int i = 0; i < AllActorClasses.Size(); i++)
			{
				class<Actor> c = AllActorClasses[i];
				if (!c) continue;
				String n = c.GetClassName();
				int l = n.Length();
				if (l < 3 || n.Mid(l - 2) != "EX" || !IsMonsterClass(c)) continue;
				if (mn.GetInt("class.tier", n) < FIRST_BOSS_TIER) continue;
				if (exPool.Find(n) == exPool.Size()) { exPool.Push(n); found++; }
			}
		}
		int lump = -1;
		while ((lump = Wads.FindLump("RSQBIGBS", lump + 1)) >= 0)
		{
			Array<String> lines;
			Wads.ReadLump(lump).Split(lines, "\n");
			for (int k = 0; k < lines.Size(); k++)
			{
				String ln = lines[k];
				int cm = ln.IndexOf("//");
				if (cm >= 0) ln = ln.Left(cm);
				ln.Replace("\r", ""); ln.Replace("\t", " "); ln.Replace(" ", "");
				if (ln == "") continue;
				class<Actor> c = ln;
				if (!IsMonsterClass(c)) { if (debug) Console.Printf("RSQMB Big Boss registry: %s is not a loaded monster class: passed over", ln); continue; }
				String n = c.GetClassName();
				if (exPool.Find(n) == exPool.Size()) { exPool.Push(n); reg++; }
			}
		}
		if (debug)
		{
			String l = "";
			for (int i = 0; i < exPool.Size(); i++) l = l .. (i ? ", " : "") .. exPool[i];
			Console.Printf("RSQMB Big Boss pool: %d EX boss(es) from RSQ Monsters' EX tier%s, %d from RSQBIGBS lumps: [%s]", found, mn ? "" : " (RSQ Monsters not loaded)", reg, l);
		}
	}
	static String ExOfGate(String g)
	{
		if (g == "") return "";
		String ex = g .. "EX";
		class<Actor> xc = ex;
		if (xc) return ex;
		int n = g.Length();
		while (n > 0 && g.ByteAt(n - 1) >= 48 && g.ByteAt(n - 1) <= 57) n--;
		ex = g.Left(n) .. "EX";
		xc = ex;
		return xc ? ex : "";
	}
	String BigClass()
	{
		ExPoolBuild();
		// the map's families: their EX by RSQ Monsters' gate, and their clean names
		Array<String> gateEx, famName;
		let mn = MnService();
		for (int i = 0; i < rosterCls.Size(); i++)
		{
			if (mn)
				for (int t = FIRST_BOSS_TIER; t <= TOP_TIER; t++)
				{
					String ex = ExOfGate(mn.GetString("set.class", rosterCls[i], 3, t));
					if (ex != "") gateEx.Push(ex);
				}
			class<Actor> rc = rosterCls[i];
			if (rc) { let d = GetDefaultByType(rc); String cn = CleanNameOf(rc, d.Species, d.GetTag("")); if (cn != "") famName.Push(cn); }
		}
		Array<String> pref;
		for (int i = 0; i < exPool.Size(); i++)
		{
			String n = exPool[i];
			bool mine = gateEx.Find(n) < gateEx.Size();
			if (!mine)
			{
				class<Actor> c = n;
				let d = GetDefaultByType(c);
				String cn = CleanNameOf(c, d.Species, d.GetTag(""));
				mine = cn != "" && famName.Find(cn) < famName.Size();
			}
			if (mine) pref.Push(n);
		}
		String pick = "";
		if (pref.Size()) pick = pref[random[rsqmbbf](0, pref.Size() - 1)];
		else if (exPool.Size()) pick = exPool[random[rsqmbbf](0, exPool.Size() - 1)];
		if (debug)
		{
			String l = "";
			for (int i = 0; i < pref.Size(); i++) l = l .. (i ? ", " : "") .. pref[i];
			Console.Printf("RSQMB Big Boss: %d in the pool, this map's families' [%s] -> %s", exPool.Size(), l,
				pick != "" ? pick : "the map's strongest type (no EX boss loaded)");
		}
		return pick;
	}

	// ---- the test door: netevent rsqmb_exfill <permille> (-1: +25%, as a Boss won) -------------------------------------------
	void ExFillTest(int pn, int v)
	{
		let ch = CVar.FindCVar("sv_cheats");
		if (!(ch && ch.GetBool()) && !debug && CI('rsqmb_debug', 0) == 0) { Console.Printf("rsqmb_exfill: needs sv_cheats 1 or RSQ Boss's Debug Log"); return; }
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return;
		let m = MeterOf(players[pn].mo, true);
		if (!m) return;
		double was = m.exFill;
		if (v < 0) { if (!m.exReady) { m.exFill = min(1000.0, m.exFill + EX_STEP); if (m.exFill >= 1000) ExReady(m); } }
		else if (v >= 1000) ExReady(m);
		else { ExEmpty(m); m.exFill = v; }
		Console.Printf("RSQMB Big Boss bar (test) t%d: %d%% -> %d%%%s", level.maptime, int(was / 10), int(m.exFill / 10), m.exReady ? ", FULL: a Big Boss is due" : "");
	}

	// ---- KEPT THROUGH A DEATH'S RELOAD (as RSQ Score's gold, gold.zs): dying with no Score life reloads the map (its
	// autosave, or the map from scratch), which would take back the Bosses won since. The bar at the moment of death is
	// written to rsqmb_ex_keep (noarchive: "<map>|<fill>") and given back (the larger) when the same map loads again.
	transient int exKeep;         // -1 none; else the fill to give back once the pawn is there
	override void PlayerDied(PlayerEvent e)
	{
		if (e.PlayerNumber != consoleplayer) return;
		let m = MeterOf(players[e.PlayerNumber].mo);
		let kc = CVar.FindCVar("rsqmb_ex_keep");
		if (!m || !kc) return;
		kc.SetString(String.Format("%s|%d", level.MapName, int(m.exFill)));
		if (debug) Console.Printf("RSQMB Big Boss bar: died on %s at %d%%: kept for the reload", level.MapName, int(m.exFill / 10));
	}
	void ExKeepLoad()
	{
		exKeep = -1;
		let kc = CVar.FindCVar("rsqmb_ex_keep");
		if (!kc) return;
		String k = kc.GetString();
		if (k == "") return;
		kc.SetString("");
		Array<String> f; k.Split(f, "|");
		if (f.Size() < 2 || !(f[0] ~== level.MapName)) return;
		exKeep = f[1].ToInt();
	}
	void ExKeepTick()
	{
		if (exKeep < 0) return;
		if (level.maptime > 70) { exKeep = -1; return; }
		let m = MeterOf(players[consoleplayer].mo, true);
		if (!m) return;
		double was = m.exFill;
		if (exKeep > m.exFill && !m.exReady)
		{
			m.exFill = min(1000.0, double(exKeep));
			if (m.exFill >= 1000) ExReady(m);
		}
		if (debug) Console.Printf("RSQMB Big Boss bar: %s reloaded after a death: %d%% -> %d%% (kept)", level.MapName, int(was / 10), int(m.exFill / 10));
		exKeep = -1;
	}
}
