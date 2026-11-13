// 2.0.2a (owner 2026-10-28 20:27): "rocket launcher alt fire up to three lock on. hold alt to lock on to three,
// release lock on to fire. three separate enemies". Option "Rocket Launcher Lock-On Alt Fire" (rsa_rl_lock).
//
// HOLD alt fire (RocketLauncher.dec RSA_RLLock): every PAINT_TICS the enemy nearest the barrel's line, inside
// CONE degrees and in sight, is locked, up to MAXLOCK DIFFERENT enemies, each marked with QuestSaber's lock mark
// (RSVR_AxeLock, the RQLK = UBLK frames). A lock stays while it lives and is in sight.
// LET GO: one rocket per lock, each down the launcher's own Fire path (its ammo, sound, flare, recoil, at its
// own rate), and each rocket (Rocket2) homes on its lock (RSQ_RocketSeek). Let go with nothing locked: nothing.
// No rocket left: the rest of the salvo is dropped. Logs with rsq_switch_log 1.
class RSQ_RocketLock : EventHandler
{
	const MAXLOCK = 3;
	const CONE = 10.0;
	const RANGE = 4096.0;
	const PAINT_TICS = 4;

	Array<Actor> locks[MAXPLAYERS];
	Array<Actor> marks[MAXPLAYERS];
	Array<Actor> salvo[MAXPLAYERS];
	bool altPrev[MAXPLAYERS];
	int lastPaint[MAXPLAYERS];
	int firedAt[MAXPLAYERS];		// the tic a salvo rocket's Fire was started (0: none waiting)
	Actor aimed[MAXPLAYERS];		// the lock that rocket goes to

	static bool Logs(PlayerInfo p)
	{
		let c = CVar.GetCVar('rsq_switch_log', p);
		return c && c.GetInt() > 0;
	}

	void Clear(int n)
	{
		for (int i = 0; i < marks[n].Size(); i++)
			if (marks[n][i])
				marks[n][i].Destroy();
		marks[n].Clear();
		locks[n].Clear();
		salvo[n].Clear();
		firedAt[n] = 0;
		aimed[n] = null;
	}

	void Unmark(int n, Actor t)
	{
		int k = locks[n].Find(t);
		if (k >= locks[n].Size())
			return;
		if (marks[n][k])
			marks[n][k].Destroy();
		marks[n].Delete(k);
		locks[n].Delete(k);
	}

	// the barrel's line in the world: the drawn bore (muzzle.zs) in VR, the view otherwise
	static Vector3, Vector3 Aim(PlayerPawn mo)
	{
		if (!RSVR_VRHand.InVR(mo))
		{
			Vector3 d = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
			return mo.pos + (0, 0, mo.player.viewheight), d;
		}
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		Vector3 b = RSQ_Muzzle.Bore(mo.player.ReadyWeapon);
		Vector3 d = RSVR_VRHand.HandDir(mo, 0, 0, ps) * b.x + RSVR_VRHand.HandDir(mo, 90, 0, ps) * b.y
			+ RSVR_VRHand.HandDir(mo, 0, 90, ps) * b.z;
		Vector3 from;
		bool ok;
		[from, ok] = RSQ_Muzzle.Where(mo);
		return from, d.Length() > 0 ? d.Unit() : (1, 0, 0);
	}

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let p = players[n];
			let mo = p.mo;
			let w = p.ReadyWeapon;
			bool on = true &&	// this pack: the Saturn V's alt fire is always the lock-on (SPEC)
				 w && RSQ_Alias.BD(w) == 'Rocket_Launcher' && p.playerstate == PST_LIVE && mo.health > 0;	// (no LegenDoom mode here)	// LD mode (round 3): a Seeker rocket launcher's lock-on stands down
			if (!on)
			{
				if (locks[n].Size() || salvo[n].Size())
					Clear(n);
				altPrev[n] = false;
				continue;
			}
			bool alt = (p.cmd.buttons & BT_ALTATTACK) != 0;
			int now = Level.maptime;

			// a lock that died or went out of sight is let go
			for (int k = locks[n].Size() - 1; k >= 0; k--)
			{
				Actor t = locks[n][k];
				if (!t || t.health <= 0 || alt && !mo.CheckSight(t, SF_IGNOREVISIBILITY))
					Unmark(n, t);
			}
			for (int k = 0; k < marks[n].Size(); k++)
				if (marks[n][k] && locks[n][k])
					marks[n][k].SetOrigin(RSVR_AxeLock.Above(locks[n][k]), true);

			if (alt && salvo[n].Size() == 0)
				Paint(n, mo);

			// let go: the salvo, one rocket per lock
			if (altPrev[n] && !alt && locks[n].Size() > 0 && salvo[n].Size() == 0)
			{
				// 2.0.3c (owner 20:59, "both"): always a salvo of MAXLOCK rockets, dealt round the locks in turn:
				// three locks get one each, two get A B A, one gets all three
				for (int k = 0; k < MAXLOCK; k++)
					salvo[n].Push(locks[n][k % locks[n].Size()]);
				if (Logs(p))
					Console.Printf("RSQ rlock t%d: released, %d locked: firing", now, salvo[n].Size());
			}
			altPrev[n] = alt;

			if (salvo[n].Size() == 0)
				continue;
			// a Fire started and no rocket came out (no ammo, or BD22 sent it elsewhere): the salvo is over
			if (firedAt[n] > 0 && now - firedAt[n] > 6)
			{
				if (Logs(p))
					Console.Printf("RSQ rlock t%d: no rocket came out, salvo dropped", now);
				Clear(n);
				continue;
			}
			if (firedAt[n] == 0 && (p.WeaponState & WF_WEAPONREADY))
			{
				// the next lock still alive
				while (salvo[n].Size() && (!salvo[n][0] || salvo[n][0].health <= 0))
					salvo[n].Delete(0);
				if (salvo[n].Size() == 0)
				{
					Clear(n);
					continue;
				}
				State f = w.FindState('Fire');
				if (!f)
				{
					Clear(n);
					continue;
				}
				aimed[n] = salvo[n][0];
				firedAt[n] = now;
				p.SetPsprite(PSP_WEAPON, f, false, w);
			}
		}
	}

	void Paint(int n, PlayerPawn mo)
	{
		if (locks[n].Size() >= MAXLOCK || Level.maptime - lastPaint[n] < PAINT_TICS)
			return;
		Vector3 from, aim;
		[from, aim] = Aim(mo);
		Actor best = null;
		let cc = CVar.GetCVar('rsa_rl_lock_cone', mo.player);
		double cone = cc ? clamp(cc.GetFloat(), 1.0, 45.0) : CONE;
		double bestAng = cone;
		int seen = 0;
		double nearAng = 999;
		String nearWhat = "";
		let it = BlockThingsIterator.CreateFromPos(from.x, from.y, from.z - RANGE, RANGE * 2.0, RANGE, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || t == mo || t.player || !t.bIsMonster || !t.bShootable || t.bFriendly || t.bDormant || t.health <= 0)
				continue;
			if (locks[n].Find(t) < locks[n].Size())
				continue;	// three DIFFERENT enemies
			Vector3 to = t.pos + (0, 0, t.height * 0.5) - from;
			double dist = to.Length();
			if (dist < 1 || dist > RANGE)
				continue;
			double ang = acos(clamp((to / dist) dot aim, -1, 1));
			seen++;
			if (ang < nearAng)
			{
				nearAng = ang;
				nearWhat = String.Format("%s %.0f units sight %d", t.GetClassName(), dist, mo.CheckSight(t, SF_IGNOREVISIBILITY));
			}
			if (ang >= bestAng || !mo.CheckSight(t, SF_IGNOREVISIBILITY))
				continue;
			bestAng = ang;
			best = t;
		}
		if (!best)
		{
			if (Logs(mo.player) && Level.maptime % 10 == 0)
				Console.Printf("RSQ rlock t%d: holding, nothing within %.0f deg: %d monsters in range, nearest %.0f deg off (%s)", Level.maptime, cone, seen, nearAng, nearWhat);
			return;
		}
		lastPaint[n] = Level.maptime;
		locks[n].Push(best);
		marks[n].Push(Actor.Spawn('RSVR_AxeLock', RSVR_AxeLock.Above(best), ALLOW_REPLACE));
		mo.A_StartSound("misc/i_pkup", CHAN_AUTO, CHANF_OVERLAP, 0.6);
		if (Logs(mo.player))
			Console.Printf("RSQ rlock t%d: locked %d/%d %s at %.1f deg", Level.maptime, locks[n].Size(), MAXLOCK, best.GetClassName(), bestAng);
	}

	// the salvo's rocket: it goes to its lock
	override void WorldThingSpawned(WorldEvent e)
	{
		let r = e.thing;
		if (!r || !(r is 'RSQWS_SaturnRocket') || !r.target || !r.target.player)
			return;
		int n = r.target.PlayerNumber();
		if (n < 0 || firedAt[n] == 0)
			return;
		Actor t = aimed[n];
		firedAt[n] = 0;
		aimed[n] = null;
		if (salvo[n].Size())
			salvo[n].Delete(0);
		if (salvo[n].Find(t) >= salvo[n].Size())
			Unmark(n, t);	// its last rocket is away
		if (!t || t.health <= 0)
			return;
		RSQ_RocketSeek.Start(r, t);
		if (Logs(r.target.player))
			Console.Printf("RSQ rlock t%d: rocket away to %s, %d left", Level.maptime, t.GetClassName(), salvo[n].Size());
		if (salvo[n].Size() == 0)
			Clear(n);
	}
}

// a salvo rocket steered onto its monster: up to TURN degrees a tic, at its own speed, for 5 seconds
class RSQ_RocketSeek : Thinker
{
	const TURN = 8.0;
	Actor r, tgt;
	int endTic;
	double spd;

	static void Start(Actor r, Actor tgt)
	{
		let s = new('RSQ_RocketSeek');
		s.r = r;
		s.tgt = tgt;
		s.spd = max(r.vel.Length(), r.Speed);
		s.endTic = r.Level.maptime + 175;
		r.tracer = tgt;
	}

	override void Tick()
	{
		if (!r || !tgt || tgt.health <= 0 || r.Level.maptime > endTic || spd <= 0 || r.InStateSequence(r.CurState, r.FindState('Death')))
		{
			Destroy();
			return;
		}
		Vector3 to = tgt.pos + (0, 0, tgt.height * 0.5) - r.pos;
		double d = to.Length();
		if (d < 1)
			return;
		Vector3 want = to / d;
		Vector3 cur = r.vel.Length() > 0 ? r.vel.Unit() : want;
		double ang = acos(clamp(cur dot want, -1, 1));
		Vector3 nd = want;
		if (ang > TURN)
		{
			double t = TURN / ang;
			nd = (cur * (1 - t) + want * t).Unit();
		}
		r.vel = nd * spd;
		r.angle = VectorAngle(nd.x, nd.y);
		r.pitch = -asin(clamp(nd.z, -1, 1));
	}
}
