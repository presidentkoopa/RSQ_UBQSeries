// ============================================================================
// RSQ_Miniboss -- THE BIG BOSS FIX (design/BOSS_REWORK.md section 9, owner 2026-11-23 03:41-03:45: "the big boss ... even on god
// mode i could do basically no fkin damage to it"; "consider dropping the big boss thralls"). Code only, not run
// (2026-11-23, owner: hold rig checks until we talk).
//
//   THE BIG BOSS FIX (section 9 items 1, 2, 4, 5; item 3, BREAK!, is the wind-up work's)
//     1 NO THRALLS      a Big Boss arrives alone (bossfight.zs PlanArrival: none planned), in either arrival; the thralls'
//                      damage cut never applies (boss.zs ThrallFactor: 1.0 with none), the FIRE ring is lit only while it is
//                      invulnerable, the Boss bar shows no thrall row, the banner no thralls chip.
//     2 TIME TO KILL    each life's health = the player's own recent damage per second x rsqmb_big_ttk s (60: owner
//                      2026-11-23 03:58, decided; 30-180), never under the monster's own spawn health x 0.5. Set at the
//                      bind (BigBind) and again at every life's refill (boss.zs LoseLife -> BigLifeHP); held to it once
//                      LegenDoom's rise could have healed it past it (BigTick). The Boss bar reads the monster's real
//                      health, so it shows the real numbers. THE DAMAGE PER SECOND (DpsNote): every blow a player deals to a
//                      monster (WorldThingDamaged, his own source or his missile's), what it really took (no overkill), on
//                      a token on the player (RSQMB_Dps: kept through maps and saves). Only FIGHTING TIME counts: each blow
//                      adds the time since his last blow while that is under DPS_GAP (2 s); the first blow after a longer
//                      gap counts DPS_FIRST (1 s), so a walk between fights adds nothing. Rolling: the last
//                      rsqmb_big_dpswin s (180) of that time. Under rsqmb_big_dpsmin s (10) of it, too little to judge: the
//                      life is the monster's spawn health. Players together (co-op) add up.
//     4 ACTS            lives stay 3 acts; the change is a short beat, rsqmb_big_actinv s (2) invulnerable, not 5 (boss.zs
//                      LoseLife).
//     5 BIG BOSS OFF    rsqmb_ex, as before.
//   Normal Boss fights keep their thralls and the thralls' cut.
// ============================================================================

// THE PLAYER'S DAMAGE PER SECOND (the Big Boss fix, section 9 item 2): one-second buckets of fighting time, oldest first.
class RSQMB_Dps : RSQMB_Token
{
	Array<int> bDmg, bAct;        // damage dealt / fighting tics in each bucket
	int dmgSum, actSum;
	int lastHit, mapStamp;
}

extend class RSQMB_Handler
{
	static double BigActSecs() { return clamp(CF('rsqmb_big_actinv', 2.0), 0.0, 30.0); }

	// ---- THE BIG BOSS'S LIFE: the player's damage per second x rsqmb_big_ttk ------------------------------------------------
	const DPS_GAP = 70;           // a blow adds the time since the last one while that is under this (2 s): a walk adds nothing
	const DPS_FIRST = 35;         // the first blow of a burst (after a gap of DPS_GAP or more) counts one second
	void DpsNote(WorldEvent e)
	{
		let v = e.Thing;
		if (!v || e.Damage <= 0 || !v.bISMONSTER || v.player || v.bFRIENDLY) return;
		Actor pl = PlayerOf(e.DamageSource);
		if (!pl) pl = PlayerOf(e.Inflictor);
		if (!pl || !pl.player || pl == v) return;
		int dealt = e.Damage + min(0, v.health);    // what it really took (no overkill)
		// A Boss's ward has already scaled the blow (items.zs RSQMB_Ward: the thralls' cut, BREAK!'s x2 / x3, its
		// toughness): put the player's own blow back, so neither a thrall-guarded Boss (x0.2) nor a BREAK! window (x3)
		// skews what the next Big Boss's lives are sized from
		let w = RSQMB_Ward(v.FindInventory("RSQMB_Ward"));
		if (w && w.boss && !w.boss.done)
		{
			double k = w.boss.ThrallFactor() * w.boss.BreakMult() / max(1.0, w.boss.toughness);
			if (k > 0.001) dealt = int(dealt / k + 0.5);
		}
		// NEVER MORE THAN A BODY'S WORTH: a Boss with a life to spare holds BUDDHA, so its health never goes under 1 and
		// "no overkill" above reads a 99,999 blow whole (rig bt5: one such blow sized the next life at 444,090). A blow
		// counts at most the most health its target can have (its own, or a Boss's life)
		int most = max(1, v.GetMaxHealth(true));
		if (w && w.boss) most = max(most, w.boss.maxHP);
		dealt = min(dealt, most);
		if (dealt <= 0) return;
		let d = RSQMB_Dps(pl.FindInventory("RSQMB_Dps"));
		if (!d) d = RSQMB_Dps(pl.GiveInventoryType("RSQMB_Dps"));
		if (!d) return;
		int now = level.maptime;
		int stamp = level.levelnum + 1;
		// the time since his last blow, while under DPS_GAP; a fresh burst (a gap of 2 s or more, a new map) counts one second
		int dt = DPS_FIRST;
		if (d.mapStamp == stamp && d.lastHit > 0 && now >= d.lastHit && now - d.lastHit < DPS_GAP) dt = now - d.lastHit;
		d.mapStamp = stamp;
		d.lastHit = now;
		int k = d.bAct.Size();
		if (k == 0 || d.bAct[k - 1] >= TICRATE) { d.bDmg.Push(0); d.bAct.Push(0); k++; }
		d.bDmg[k - 1] += dealt; d.bAct[k - 1] += dt;
		d.dmgSum += dealt; d.actSum += dt;
		int win = int(clamp(CF('rsqmb_big_dpswin', 180), 30, 900) * TICRATE);
		while (d.bAct.Size() > 1 && d.actSum - d.bAct[0] >= win)
		{
			d.dmgSum -= d.bDmg[0]; d.actSum -= d.bAct[0];
			d.bDmg.Delete(0); d.bAct.Delete(0);
		}
	}
	// a player's damage per second over his fighting time; -1 too little to judge
	static double DpsOf(Actor pmo)
	{
		let d = pmo ? RSQMB_Dps(pmo.FindInventory("RSQMB_Dps")) : null;
		if (!d || d.actSum < int(clamp(CF('rsqmb_big_dpsmin', 10), 1, 120) * TICRATE)) return -1;
		return d.dmgSum / (d.actSum / double(TICRATE));
	}
	// one life's health: the players' damage per second together x rsqmb_big_ttk; too little data: its spawn health;
	// never under its spawn health x 0.5 (section 9 item 2)
	int BigLifeHP(RSQMB_Boss b)
	{
		if (!b || !b.mb) return 1;
		int spawn = max(1, b.mb.SpawnHealth());
		double ttk = clamp(CF('rsqmb_big_ttk', 60), 30, 180);
		double dps = 0;
		bool any = false;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			double v = DpsOf(players[pn].mo);
			if (v > 0) { dps += v; any = true; }
		}
		int hp = any ? int(min(dps * ttk, 2e9)) : spawn;
		hp = max(hp, max(1, spawn / 2));
		if (debug) Console.Printf("RSQMB Big Boss life t%d: %s: damage per second %s x %.0f s -> %d health (spawn %d, floor %d)", level.maptime, b.mb.GetClassName(),
			any ? String.Format("%.1f", dps) : "too little to judge (its spawn health)", ttk, hp, spawn, spawn / 2);
		return hp;
	}
	// A BOSS'S LIFE BY TIME TO KILL TOO (owner 2026-11-23 09:13: "make miniboss fights tougher"; picked "Boss life by
	// time": the BD rifle melted them). A Boss's (not a Big Boss's) life = the players' damage per second x rsqmb_boss_ttk
	// (20 s), never under the health it was bound with (its boosted own: floor). Too little measured: that health.
	static bool BossTtkOn() { return CI('rsqmb_boss_ttk_on', 1) != 0; }
	int BossLifeHP(RSQMB_Boss b, int floor)
	{
		double ttk = clamp(CF('rsqmb_boss_ttk', 20), 5, 120), dps = 0;
		bool any = false;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			double v = DpsOf(players[pn].mo);
			if (v > 0) { dps += v; any = true; }
		}
		int hp = any ? int(min(dps * ttk, 2e9)) : floor;
		hp = max(hp, max(1, floor));
		if (debug) Console.Printf("RSQMB Boss life t%d: %s: damage per second %s x %.0f s -> %d health (floor %d)", level.maptime, b && b.mb ? b.mb.GetClassName() : 'none',
			any ? String.Format("%.1f", dps) : "too little to judge", ttk, hp, floor);
		return hp;
	}
	void BossBind(RSQMB_Boss b)
	{
		if (!b || b.big || !b.mb || !BossTtkOn()) return;
		b.bossFloor = max(1, b.mb.health);
		int hp = BossLifeHP(b, b.bossFloor);
		b.mb.health = hp;
		b.maxHP = hp;
		b.bigHp = hp;
		b.bigHpHeld = false;
	}
	// THE THRALLS, TOUGHER (the same pick): x1.5 health at Rank 0 up to x2 at Rank 100 (rsqmb_thrall_hp, rsqmb_thrall_hp_top)
	static double ThrallHpMult()
	{
		double a = clamp(CF('rsqmb_thrall_hp', 1.5), 0.5, 5.0), z = clamp(CF('rsqmb_thrall_hp_top', 2.0), 0.5, 8.0);
		return a + (z - a) * RankFrac();
	}

	// at the bind (ArrivalStep): its first life
	void BigBind(RSQMB_Boss b)
	{
		if (!b || !b.big || !b.mb) return;
		int hp = BigLifeHP(b);
		b.mb.health = hp;
		b.maxHP = hp;
		b.bigHp = hp;
		b.bigHpHeld = false;
	}
	// every tic: once LegenDoom's rise could have healed it (the charge's rise window, boss.zs Step), it is held to its life
	void BigTick()
	{
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done || !b.mb || b.bigHp <= 0 || b.bigHpHeld) continue;     // a Boss's life by time too (BossBind)
			if (level.maptime < b.chargeUntil + 36 || b.RisePending(b.mb)) continue;
			b.bigHpHeld = true;
			if (b.mb.health > b.bigHp) b.mb.health = b.bigHp;
			b.maxHP = b.bigHp;
		}
	}
}
