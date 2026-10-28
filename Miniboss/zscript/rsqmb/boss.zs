// ============================================================================
// RSQ_Miniboss -- one miniboss and its thralls (a Thinker: saved with the level).
//
// Lives: the miniboss holds BUDDHA while it has a life to spare; the tic it sits at 1 hp it loses a
// life, refills to the most health it has had (so Champions' and LegenDoom Lite's own boosts count),
// and is invulnerable for rsqmb_invuln s + rsqmb_invuln_bonus s per LIVING thrall. When that ends,
// its dead thralls rise again (A_RaiseSelf, the engine's own raise: Champions re-dresses a revived
// champion itself). On its last life BUDDHA goes back to what the monster had.
//
// The FX are particles, not actors: no thinkers, no collision, nothing saved, nothing for RSQ_SlowMo to
// slow. The original's link trails were rsqmb density x thralls ACTORS warped every tic (30 x n).
// ============================================================================

class RSQMB_Boss : Thinker
{
	Actor mb;
	Array<Actor> thr;
	Array<int>   thrState;       // ST_ALIVE / ST_DEAD (will rise) / ST_LOST (gone for good)
	int    total;                // thralls bound at the start (the shield's denominator)
	int    lives;                // lives left, the current one included
	int    maxHP;
	bool   ownBuddha;            // the monster's own BUDDHA before we took it
	int    invulUntil, reviveUntil;
	double toughness, outMult;   // inherited: damage taken / toughness, damage dealt x outMult
	Array<String> powers;        // what it inherited, for the service and the log
	bool   legendary;            // inherited LegenDoom Lite's legendary status
	Color  col;
	int    idx;
	bool   done, enraged, greedArmed, greedy;
	int    greedDeadline;
	int    bornAt;

	enum EState { ST_ALIVE, ST_DEAD, ST_LOST }

	private transient RSQMB_Handler hnd;
	RSQMB_Handler H() { if (!hnd) hnd = RSQMB_Handler.Get(); return hnd; }

	// ---- the rules, read by the ward ------------------------------------------------------------
	clearscope bool Invulnerable() const { return !done && level.maptime < invulUntil; }

	clearscope int Living() const
	{
		int n = 0;
		for (int i = 0; i < thr.Size(); i++) if (thrState[i] == ST_ALIVE) n++;
		return n;
	}

	double ShieldFactor()
	{
		if (total <= 0) return 1.0;
		let h = H();
		double cut = h ? h.shield : 0.8;
		return 1.0 - cut * Living() / double(total);
	}

	double TakeFactor() { return ShieldFactor() / max(1.0, toughness); }

	// The same, readable from ui / data scope (the service): the setting read directly.
	clearscope double TakeFactorData() const
	{
		double cut = total > 0 ? clamp(RSQMB_Handler.CI('rsqmb_shield', 80), 0, 95) / 100.0 : 0;
		double sh = total > 0 ? 1.0 - cut * Living() / double(total) : 1.0;
		return sh / max(1.0, toughness);
	}

	void NoteStruck() { let h = H(); if (h) h.NoteGreed(self); }

	// ---- every tic ------------------------------------------------------------------------------
	override void Tick()
	{
		if (done || level.isFrozen()) return;
		let h = H();
		double t0 = (h && h.debug) ? MSTimeF() : 0;
		Step(h);
		if (h && h.debug) h.AddCost(MSTimeF() - t0);
	}

	private void Step(RSQMB_Handler h)
	{
		if (!mb || mb.bDestroyed || mb.health <= 0) { if (h) h.BossDied(self, null); else done = true; return; }

		if (mb.health > maxHP) maxHP = mb.health;

		// A life lost: BUDDHA held it at 1 hp.
		if (lives > 1 && mb.health <= 1) LoseLife(h);

		// Thralls: alive, dead (will rise), or gone (destroyed, gibbed away).
		for (int i = 0; i < thr.Size(); i++)
		{
			let t = thr[i];
			if (!t || t.bDestroyed) { thrState[i] = ST_LOST; continue; }
			if (thrState[i] == ST_ALIVE && t.health <= 0) thrState[i] = ST_DEAD;          // died without the event (A_Die, scripts)
			else if (thrState[i] == ST_DEAD && t.health > 0) thrState[i] = ST_ALIVE;      // raised by someone else (an Arch-vile)
		}

		// Invulnerability over: the dead rise (tried for a few seconds: a corpse must finish falling,
		// and have room).
		if (invulUntil > 0 && level.maptime == invulUntil && h && h.revive) reviveUntil = level.maptime + 5 * TICRATE;
		if (level.maptime < reviveUntil) Revive();

		if (h && h.fxOn) FX(h);
	}

	private void LoseLife(RSQMB_Handler h)
	{
		lives--;
		mb.health = max(maxHP, 1);
		double secs = h ? h.invulSecs + h.invulBonus * Living() : 5.0;
		invulUntil = level.maptime + max(1, int(secs * TICRATE));
		if (lives <= 1) mb.bBUDDHA = ownBuddha;
		mb.A_StartSound("weapons/bfgx", CHAN_AUTO, 0, 1.0, 0.5);
		if (h && h.fxOn) Burst(Mid(mb), col, 40, 6.0, 9);
		if (h && h.debug) Console.Printf("RSQMB life lost: boss %d lives %d hp %d invuln %d tics living %d", idx, lives, mb.health, invulUntil - level.maptime, Living());
	}

	private void Revive()
	{
		bool any = false;
		for (int i = 0; i < thr.Size(); i++)
		{
			if (thrState[i] != ST_DEAD) continue;
			let t = thr[i];
			if (!t || t.health > 0) continue;
			any = true;
			if (t.A_RaiseSelf(0))
			{
				thrState[i] = ST_ALIVE;
				let h = H();
				if (h && h.fxOn) Burst(Mid(t), col, 24, 4.0, 7);
				if (h && h.debug) Console.Printf("RSQMB thrall %d of boss %d rose (hp %d)", i, idx, t.health);
			}
		}
		if (!any) reviveUntil = 0;
	}

	// The miniboss is dead: the links break, the thralls are free monsters again.
	void Finish()
	{
		done = true;
		for (int i = 0; i < thr.Size(); i++)
		{
			let t = thr[i];
			if (!t) continue;
			t.TakeInventory("RSQMB_Thrall", 1);
			let h = H();
			if (h && h.fxOn && thrState[i] == ST_ALIVE) Shatter(Mid(t), mb ? Mid(mb) : Mid(t));
		}
	}

	// ---- FX: particles only --------------------------------------------------------------------
	static Vector3 Mid(Actor a) { return a.pos + (0, 0, a.height * 0.6); }

	static void P(Vector3 at, Color c, double size, int life, double alpha, Vector3 vel = (0, 0, 0), RSQMB_Handler h = null)
	{
		FSpawnParticleParams p;
		p.color1 = c;
		p.style = STYLE_Add;
		p.flags = SPF_FULLBRIGHT;
		p.lifetime = life;
		p.size = size;
		p.pos = at;
		p.vel = vel;
		p.startalpha = alpha;
		p.fadestep = -1;
		level.SpawnParticle(p);
		if (h && h.debug) h.fxParticles++;
	}

	static void Burst(Vector3 at, Color c, int n, double speed, double size)
	{
		for (int i = 0; i < n; i++)
		{
			double a = frandom[rsqmbfx](0, 360), v = frandom[rsqmbfx](-0.6, 0.9);
			Vector3 dir = (cos(a) * sqrt(1 - v * v), sin(a) * sqrt(1 - v * v), v);
			P(at, (i & 1) ? c : Color(255, 255, 255, 255), size, 18, 0.9, dir * speed * frandom[rsqmbfx](0.4, 1.0));
		}
	}

	void Shatter(Vector3 from, Vector3 to)
	{
		Vector3 d = level.Vec3Diff(from, to);
		int n = clamp(int(d.Length() / 48), 2, 24);
		for (int i = 0; i <= n; i++)
			P(from + d * (i / double(n)), col, 6, 14, 0.8, (frandom[rsqmbfx](-2, 2), frandom[rsqmbfx](-2, 2), frandom[rsqmbfx](0, 3)));
		Burst(from, col, 20, 4.0, 8);
	}

	private void FX(RSQMB_Handler h)
	{
		// Only what the local viewer can see from where they stand.
		let view = players[consoleplayer].mo;
		if (!view) return;
		Vector3 bm = Mid(mb);
		Vector3 dv = level.Vec3Diff(view.pos, bm);
		if (dv dot dv > h.fxRange2) return;
		int t = level.maptime;

		// Links: a dotted line from each living thrall, with beads running INTO the miniboss (who
		// feeds whom, readable at a glance). A dead thrall that will rise keeps a faint grey line.
		for (int i = 0; i < thr.Size(); i++)
		{
			let th = thr[i];
			if (!th || thrState[i] == ST_LOST) continue;
			Vector3 a = Mid(th);
			Vector3 d = level.Vec3Diff(a, bm);
			double len = d.Length();
			if (len < 1) continue;
			if (thrState[i] == ST_ALIVE)
			{
				if ((t + i) % 3 == 0)
				{
					int n = clamp(int(len / 48), 2, 28);
					for (int k = 1; k < n; k++) P(a + d * (k / double(n)), col, 4, 4, 0.55, (0, 0, 0), h);
				}
				for (int b = 0; b < 2; b++)
				{
					double s = ((t * 20.0 + b * len * 0.5) % len) / len;
					P(a + d * s, Color(255, 255, 255, 255), 9, 2, 0.9, (0, 0, 0), h);
				}
				if ((t + i) % 4 == 0) P(th.pos + (0, 0, th.height + 10), col, 8, 5, 0.9, (0, 0, 0), h);
			}
			else if (t % 8 == i % 8 && level.maptime < invulUntil + 5 * TICRATE + 1)
			{
				int n = clamp(int(len / 64), 2, 20);
				for (int k = 1; k < n; k++) P(a + d * (k / double(n)), Color(255, 144, 144, 144), 3, 9, 0.25, (0, 0, 0), h);
			}
		}

		// Lives: one orb per life left, circling above its head; the last one burns red.
		double r = max(16.0, mb.radius) * 1.2;
		double z = mb.height + 12;
		for (int i = 0; i < lives; i++)
		{
			double ang = t * 4.0 + i * 360.0 / lives;
			Color c = (lives == 1) ? Color(255, 255, 40, 40) : col;
			double sz = (lives == 1) ? 8 + 3 * sin(t * 12.0) : 8;
			P(mb.pos + (cos(ang) * r, sin(ang) * r, z), c, sz, 2, 0.95, (0, 0, 0), h);
		}

		// Invulnerable: a gold ring turning the other way, at chest height.
		if (Invulnerable() && t % 2 == 0)
		{
			double rr = max(16.0, mb.radius) * 1.6;
			for (int i = 0; i < 12; i++)
			{
				double ang = -t * 6.0 + i * 30.0;
				P(mb.pos + (cos(ang) * rr, sin(ang) * rr, mb.height * 0.5), Color(255, 255, 224, 96), 6, 3, 0.9, (0, 0, 0), h);
			}
		}
	}
}
