// RSQ_SlowMo -- DOWN (owner 2026-11-06 17:48, approved design: design/NEAR_DEATH.md). The mode is DOWN; getting back up
// is REVIVE. SlowMo owns it (it owns time); the other mods join by name and each still loads alone.
//
//  1 TRIGGER   a hit that would kill you holds you at 1 HP instead (any source the engine's buddha hold catches: not a
//              telefrag, not forced damage). DOWN comes first; a Score life is spent only if DOWN fails.
//              How: while DOWN is ARMED (its row on, you alive, not in its cooldown) your pawn carries the engine's buddha
//              flag (bBUDDHA), which holds a lethal hit at 1 HP after armour. Which hit was lethal is read from your
//              health just before it (RSQSM_DownWatch.ModifyDamage, the last thing the engine asks before it takes the
//              health off) against the damage the hit did (WorldThingDamaged).
//  2 WHILE DOWN the world drops to SlowMo's deepest speed (DEPTH, 0.05: the floor of every speed in this mod) for the
//              window; you keep full speed (the clock's SlowMe leaves you alone). RSQ Glow In The Dark turns the map deep
//              blood red (it asks "down.redmap"; the Red Map row). A heartbeat: Brutal Doom's heartbeat1 / heartbeat2
//              (DSHEART1 / DSHEART2, SNDINFO.Gore) when Brutal Doom is loaded, else stock Doom's plats/pt1_stop (DSPSTOP)
//              pitched down. No single hit kills you in the first GRACE tics (1 s): the hold stays on through them.
//              After them the hold is off: a hit that would kill you ends DOWN as a failure.
//  3 WINDOW    rsqsm_down_window (6 s, real time). A bar under the SlowMo bars counts it down, cause line "DOWN"
//              (countdown.zs).
//  4 REVIVE    rsqsm_down_kills (3) kills inside the window: the REVIVE word flies past (RSQ VisualRewards), time comes
//              back, health 50 (kept if already above), every carried weapon's magazine filled from its reserve
//              (ReloadAll), +1 cigarette (RSQ Tactical Rig), +1 grenade (RSQ Grenade; Brutal Doom's own with BD22 VR).
//  5 FAILING   the window ends without the kills: you die -- or, with a Score life held, Score's own hold catches the
//              killing blow and spends that life (Score asks "down.hold" and leaves you alone only while DOWN runs).
//  6 REPEAT    rsqsm_down_cool (60 s) after DOWN ends, pass or fail, before it can trigger again. Repeat Without Limit
//              (rsqsm_down_repeat, off): no cooldown at all.
//  8 SCORE     a "Down" award for each kill inside the window and a "Revive" award for getting up (RS_ScoreService
//              "award", by name; Score sets their worth).
//  9 DROPS     with Power-Up Drops on, each counted kill tells RSQ VisualRewards, which drops its medkit (+25).
// 11 NETPLAY   each player has his own DOWN; the world's slow-down is the clock's, shared as every slow motion is.
//
// JOINING (for other mods, by name, nothing links): every Service whose class name contains "RSQDownJoin" is told, in
// play scope, GetInt(event, stringArg, player number, 0, actor):
//   "down.start"   the player went DOWN (objectArg his pawn)
//   "down.kill"    a kill counted (objectArg the body; stringArg "<count> <needed> <drops 0/1>")
//   "down.revive"  he got up (objectArg his pawn)
//   "down.fail"    DOWN failed (objectArg his pawn; stringArg why)
// and RSQSM_Service answers "down" / "down.hold" (intArg player: 1 while DOWN), "down.any", "down.redmap" (1 while the
// console player is DOWN with his Red Map row on), "down.left" (real tics left, -1 none), "down.kills" / "down.need".
class RSQSM_Down : EventHandler
{
	const GRACE = 35;          // tics after the trigger in which no hit kills (owner's spec: 1 s)
	const DEPTH = 0.05;        // the world's speed while DOWN: the deepest SlowMo has
	const REVIVE_HP = 50;

	// ---- synced (in the save) ----------------------------------------------------------------------------------------
	bool   downOn[MAXPLAYERS];
	int    downStart[MAXPLAYERS], downEnd[MAXPLAYERS];   // maptime (real time: maptime is never slowed)
	int    kills[MAXPLAYERS], need[MAXPLAYERS];
	int    coolUntil[MAXPLAYERS];                        // maptime DOWN may trigger again (0 none)
	int    beatNext[MAXPLAYERS], beatN[MAXPLAYERS];
	bool   reviveDue[MAXPLAYERS];
	bool   held[MAXPLAYERS];                             // this handler set his pawn's bBUDDHA (and must take it off)
	int    endTic[MAXPLAYERS];                           // maptime DOWN last ended (the bar's fade)
	bool   endRevived[MAXPLAYERS];
	int    startTic[MAXPLAYERS];                         // maptime DOWN last started this tic (Heavy Hit Slowdown stands aside)
	Array<Actor> counted;                                // the kills counted this DOWN (any player's: the body)
	Array<int>   countedBy;

	// ---- this tic ----------------------------------------------------------------------------------------------------
	private transient int hpSeen[MAXPLAYERS];            // his health at the end of the last look (a fallback)

	static RSQSM_Down Get() { return RSQSM_Down(EventHandler.Find("RSQSM_Down")); }
	static clearscope double Cv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static bool On() { return Cv("rsqsm_down", 1) != 0; }
	static int NeedSet() { return int(clamp(Cv("rsqsm_down_kills", 3), 1, 10)); }
	static int WindowTics() { return int(clamp(Cv("rsqsm_down_window", 6), 2, 30) * TICRATE); }
	static int CoolTics() { return Cv("rsqsm_down_repeat", 0) != 0 ? 0 : int(clamp(Cv("rsqsm_down_cool", 60), 0, 300) * TICRATE); }
	static bool Debug() { return Cv("rsqsm_debug", 0) != 0; }
	static void Log(String s) { if (Debug()) Console.Printf("RSQ_SlowMo: DOWN t%d: %s", level.maptime, s); }

	// any player DOWN now (the clock drops the world to DEPTH)
	clearscope bool AnyOn() { for (int n = 0; n < MAXPLAYERS; n++) if (downOn[n]) return true; return false; }
	clearscope bool IsDown(int n) { return n >= 0 && n < MAXPLAYERS && downOn[n]; }
	clearscope int Left(int n) { return IsDown(n) ? max(0, downEnd[n] - level.maptime) : -1; }

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		// a new level: nobody is DOWN; the cooldown is per map (the clock is rebuilt every map, like this handler)
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			downOn[n] = false; downStart[n] = 0; downEnd[n] = 0; kills[n] = 0; need[n] = 0; coolUntil[n] = 0;
			beatNext[n] = 0; beatN[n] = 0; reviveDue[n] = false; held[n] = false; endTic[n] = 0; endRevived[n] = false; startTic[n] = -1;
		}
		counted.Clear(); countedBy.Clear();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		// never carry the hold into the next level (the pawn travels)
		for (int n = 0; n < MAXPLAYERS; n++) Hold(n, false);
	}

	// ---- the hold: the engine's buddha flag on his pawn, only while ARMED or in the GRACE -------------------------
	bool Armed(int n)
	{
		if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0 || players[n].playerstate == PST_DEAD) return false;
		let c = RSQSM_Clock.Get();
		if (c && c.StoodDown()) return false;
		if (downOn[n]) return level.maptime - downStart[n] < GRACE;
		if (!On()) return false;
		// Repeat Without Limit: no cooldown at all, a running one included
		return Cv("rsqsm_down_repeat", 0) != 0 || level.maptime >= coolUntil[n];
	}
	private void Hold(int n, bool want)
	{
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) { held[n] = false; return; }
		if (want && !held[n])
		{
			if (pmo.bBUDDHA) return;          // someone else's: not ours to take off later
			pmo.bBUDDHA = true; held[n] = true;
		}
		else if (!want && held[n]) { pmo.bBUDDHA = false; held[n] = false; }
	}

	// ---- every tic ----------------------------------------------------------------------------------------------------
	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			if (!pmo.FindInventory("RSQSM_DownWatch")) pmo.GiveInventoryType("RSQSM_DownWatch");
			if (downOn[n])
			{
				if (reviveDue[n]) Revive(n);
				else if (pmo.health <= 0) Fail(n, "he died (a hit the hold could not catch)");
				else if (level.maptime >= downEnd[n]) Fail(n, String.Format("the window ended with %d of %d kills", kills[n], need[n]));
				else Heartbeat(n);
			}
			Hold(n, Armed(n));
			hpSeen[n] = pmo.health;
		}
	}

	// THE HEARTBEAT: Brutal Doom's (DSHEART1 / DSHEART2) when it is loaded, else stock Doom's DSPSTOP pitched down; heard
	// by the downed player only (CHANF_LOCAL). It quickens as the window runs out (every 26 tics down to every 12).
	private void Heartbeat(int n)
	{
		if (level.maptime < beatNext[n]) return;
		let pmo = players[n].mo;
		double left = double(downEnd[n] - level.maptime) / max(1, downEnd[n] - downStart[n]);
		beatNext[n] = level.maptime + int(12 + 14 * clamp(left, 0.0, 1.0));
		beatN[n]++;
		bool bd = S_GetLength("heartbeat1") > 0;
		if (bd) pmo.A_StartSound((beatN[n] & 1) ? "heartbeat1" : "heartbeat2", CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
		else pmo.A_StartSound("plats/pt1_stop", CHAN_AUTO, CHANF_LOCAL, 0.9, ATTN_NONE, 0.55);
		Log(String.Format("player %d heartbeat %d: %s, next in %d tics", n, beatN[n], bd ? ((beatN[n] & 1) ? "heartbeat1 (Brutal Doom DSHEART1)" : "heartbeat2 (Brutal Doom DSHEART2)") : "plats/pt1_stop (stock DSPSTOP) at pitch 0.55", beatNext[n] - level.maptime));
		RSQSM_Buzz.Start(pmo, 0, 0.35, 3);
		RSQSM_Buzz.Start(pmo, 1, 0.35, 3);
	}

	// ---- the hits -----------------------------------------------------------------------------------------------------
	override void WorldThingDamaged(WorldEvent e)
	{
		let t = e.Thing;
		if (!t) return;
		if (t.player) { PlayerHit(e); return; }
		if (!t.bISMONSTER || t.health > 0 || t.bFRIENDLY) return;
		// Brutal Doom's helpers (head hitboxes and the like: ISMONSTER, -COUNTKILL, 1000+ health) are no kill
		if (!t.bCOUNTKILL && t.GetSpawnHealth() >= 1000) return;
		Actor src = e.DamageSource;
		if (src && !src.player && src.FriendPlayer > 0 && src.FriendPlayer <= MAXPLAYERS) src = players[src.FriendPlayer - 1].mo;
		if (!src || !src.player) return;
		int n = src.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS || !downOn[n] || reviveDue[n]) return;
		for (int i = 0; i < counted.Size(); i++) if (counted[i] == t) return;
		counted.Push(t); countedBy.Push(n);
		kills[n]++;
		bool drops = Cv("rsqsm_down_drops", 1) != 0;
		Log(String.Format("player %d's kill %d of %d counted: %s \"%s\" (%.1f s left)%s", n, kills[n], need[n], t.GetClassName(), t.GetTag(),
			(downEnd[n] - level.maptime) / double(TICRATE), drops ? ", Power-Up Drops on" : ""));
		Tell("down.kill", n, String.Format("%d %d %d", kills[n], need[n], drops ? 1 : 0), t);
		Award(src, "Down");
		if (kills[n] >= need[n])
		{
			reviveDue[n] = true;          // REVIVE on this tic's WorldTick (not inside the engine's damage call)
			Award(src, "Revive");
		}
	}

	private void PlayerHit(WorldEvent e)
	{
		let pmo = e.Thing;
		int n = pmo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS || e.Damage <= 0) return;
		// his health just before this hit: the watch's reading of this very hit, else the last one seen
		int pre = hpSeen[n];
		let w = RSQSM_DownWatch(pmo.FindInventory("RSQSM_DownWatch"));
		if (w && w.fresh) { pre = w.preHp; w.fresh = false; }
		bool lethal = e.Damage >= pre && pre > 0;
		hpSeen[n] = pmo.health;
		if (!lethal) return;
		String from = e.DamageSource ? String.Format("%s", e.DamageSource.GetClassName()) : "nothing";
		if (downOn[n])
		{
			int age = level.maptime - downStart[n];
			if (age < GRACE) { Log(String.Format("player %d: a lethal hit (%d at %d HP from %s) in the grace (%d tics in): held at %d HP", n, e.Damage, pre, from, age, pmo.health)); return; }
			Fail(n, String.Format("a lethal hit after the grace (%d at %d HP from %s)", e.Damage, pre, from));
			return;
		}
		if (!held[n] || pmo.health != 1)
		{
			if (On() && pmo.health > 0)
			{
				String why = !playeringame[n] ? "" : (level.maptime < coolUntil[n] && Cv("rsqsm_down_repeat", 0) == 0 ? String.Format("its cooldown, %.1f s left", (coolUntil[n] - level.maptime) / double(TICRATE)) : "not armed");
				Log(String.Format("player %d: a lethal hit (%d at %d HP from %s), DOWN not triggered: %s (health now %d)", n, e.Damage, pre, from, why, pmo.health));
			}
			else if (On()) Log(String.Format("player %d: a lethal hit (%d at %d HP from %s), DOWN not triggered (not armed): he died", n, e.Damage, pre, from));
			return;
		}
		Start(n, e.Damage, pre, from);
	}

	private void Start(int n, int dmg, int pre, String from)
	{
		let pmo = players[n].mo;
		downOn[n] = true;
		downStart[n] = level.maptime;
		downEnd[n] = level.maptime + WindowTics();
		kills[n] = 0;
		need[n] = NeedSet();
		reviveDue[n] = false;
		beatNext[n] = level.maptime;
		beatN[n] = 0;
		startTic[n] = level.maptime;
		for (int i = countedBy.Size() - 1; i >= 0; i--) if (countedBy[i] == n) { counted.Delete(i); countedBy.Delete(i); }
		Log(String.Format("player %d went DOWN: a lethal hit (%d at %d HP from %s) held at %d HP; window %.1f s, %d kills to REVIVE, world to %d%%",
			n, dmg, pre, from, pmo.health, WindowTics() / double(TICRATE), need[n], int(DEPTH * 100 + 0.5)));
		pmo.A_StartSound("rsqsm/in", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.8, 10);
		RSQSM_Buzz.Start(pmo, 1, 0.8, 10);
		Tell("down.start", n, "", pmo);
	}

	private void Revive(int n)
	{
		let pmo = players[n].mo;
		End(n, true);
		int was = pmo.health;
		if (pmo.health < REVIVE_HP) pmo.A_SetHealth(REVIVE_HP);
		String rl;
		int filled = ReloadAll(pmo, rl);
		Log(String.Format("player %d REVIVED with %d kills: health %d -> %d; magazines filled from their reserves: %d (%s); cooldown %s",
			n, kills[n], was, pmo.health, filled, rl == "" ? "none" : rl, CoolTics() > 0 ? String.Format("%.0f s", CoolTics() / double(TICRATE)) : "none (Repeat Without Limit)"));
		pmo.A_StartSound("rsqsm/out", CHAN_AUTO, CHANF_LOCAL, 1.0);
		pmo.A_StartSound("misc/p_pkup", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.7, 8);
		RSQSM_Buzz.Start(pmo, 1, 0.7, 8);
		Tell("down.revive", n, "", pmo);
	}

	private void Fail(int n, String why)
	{
		let pmo = players[n].mo;
		End(n, false);
		Tell("down.fail", n, why, pmo);
		if (!pmo || pmo.health <= 0) { Log(String.Format("player %d: DOWN failed (%s): dead", n, why)); return; }
		// the killing blow: his health twice over plus one, past armour, protection and the skill's damage factor; with
		// a Score life held, Score's own hold (the engine's buddha cheat) catches it at 1 HP and Score spends the life
		int hp = pmo.health;
		pmo.DamageMobj(null, null, hp * 2 + 1, 'None', DMG_NO_ARMOR | DMG_NO_PROTECT | DMG_NO_FACTOR | DMG_THRUSTLESS | DMG_NO_ENHANCE);
		Log(String.Format("player %d: DOWN failed (%s): the killing blow at %d HP -> health %d (%s)", n, why, hp, pmo.health,
			pmo.health > 0 ? "a Score life holds him" : "dead"));
	}

	private void End(int n, bool revived)
	{
		downOn[n] = false;
		reviveDue[n] = false;
		endTic[n] = level.maptime;
		endRevived[n] = revived;
		int cool = CoolTics();
		coolUntil[n] = level.maptime + cool;
		Hold(n, false);
		for (int i = countedBy.Size() - 1; i >= 0; i--) if (countedBy[i] == n) { counted.Delete(i); countedBy.Delete(i); }
		// he stays at full speed while the world eases back (the clock's SlowMe)
		let c = RSQSM_Clock.Get();
		if (c) c.freeUntil[n] = max(c.freeUntil[n], level.maptime + int(c.RampOut() * TICRATE) + 2);
	}

	// ---- RELOAD EVERY CARRIED WEAPON (owner 11-06: "BD22 VR's guns keep a magazine (Ammo2) fed from a reserve (Ammo1)"):
	// each carried weapon whose second ammo is a MAGAZINE gets it filled to its MaxAmount from its first ammo (the reserve),
	// as far as the reserve goes (with infinite ammo: filled, the reserve untouched). A second ammo is a magazine when no
	// weapon class anywhere uses it as its FIRST ammo: BD22's Machinegun's second ammo is AmmoRocket, the rocket and
	// grenade launchers' reserve, so it is left alone. Vanilla weapons have no second ammo: nothing to do.
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
	int ReloadAll(Actor pmo, out String what)
	{
		what = "";
		if (!reservesBuilt) BuildReserves();
		bool inf = sv_infiniteammo || pmo.FindInventory("PowerInfiniteAmmo", true);
		int n = 0;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || !w.Ammo1 || !w.Ammo2 || w.Ammo1.GetClass() == w.Ammo2.GetClass()) continue;
			if (reserves.Find(w.Ammo2.GetClassName()) < reserves.Size()) continue;
			int room = w.Ammo2.MaxAmount - w.Ammo2.Amount;
			if (room <= 0) continue;
			int take = inf ? room : min(room, w.Ammo1.Amount);
			if (take <= 0) continue;
			int was2 = w.Ammo2.Amount, was1 = w.Ammo1.Amount;
			w.Ammo2.Amount += take;
			if (!inf) w.Ammo1.Amount -= take;
			n++;
			what = what .. String.Format("%s%s %s %d->%d from %s %d->%d", what == "" ? "" : "; ", w.GetClassName(), w.Ammo2.GetClassName(), was2,
				w.Ammo2.Amount, w.Ammo1.GetClassName(), was1, w.Ammo1.Amount);
		}
		return n;
	}

	// ---- telling the others, by name ---------------------------------------------------------------------------------
	static void Tell(String what, int n, String s, Actor a)
	{
		let it = ServiceIterator.Find("RSQDownJoin");
		Service sv;
		int k = 0;
		while (sv = it.Next()) { sv.GetInt(what, s, n, 0, a); k++; }
		Log(String.Format("told %d joined mod(s): %s %s", k, what, s));
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

// HIS HEALTH JUST BEFORE A HIT (RSQSM_Down.PlayerHit). The engine asks every item a player carries to modify the damage
// (passive) right before armour and the health coming off; this reads the health then and changes nothing.
class RSQSM_DownWatch : Inventory
{
	int preHp;
	bool fresh;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		newdamage = damage;
		if (!passive || !Owner) return;
		preHp = Owner.health;
		fresh = true;
	}
}
