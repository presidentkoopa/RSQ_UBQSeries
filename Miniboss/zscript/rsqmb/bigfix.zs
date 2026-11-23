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
			if (!b || b.done || !b.big || !b.mb || b.bigHp <= 0 || b.bigHpHeld) continue;
			if (level.maptime < b.chargeUntil + 36 || b.RisePending(b.mb)) continue;
			b.bigHpHeld = true;
			if (b.mb.health > b.bigHp) b.mb.health = b.bigHp;
			b.maxHP = b.bigHp;
		}
	}
}
