// RS_ShieldSawQ -- the thrown disc.
//
// Launched from the synced hand velocity (every machine computes the same launch from the
// same pose history), spinning in the plane the wrist gave it (UseActorRoll), it visits up to
// ssq_locks targets found in a cone from the hand's forward at release, then comes home
// along the breadcrumbs it dropped on the way out -- never through a wall -- and either
// lands in the hand that is waiting for it (a catch) or on the mount.
//
// What it does to what it hits, by SpawnHealth: fodder is bisected and ripped through, a
// mid-tier takes the disc and is ground for a while, a heavy turns it away.

class SSQ_Disc : Actor
{
	enum EPhase { PH_OUT = 0, PH_EMBED, PH_HOME }

	PlayerPawn thrower;
	int phase;
	Array<Actor> locks;
	int lockAt;
	Array<double> crumbX, crumbY, crumbZ;	// Array<Vector3> is not allowed
	int crumbAt;
	int embedTics;
	Actor embedIn;
	Vector3 embedOfs;
	double cruise;		// units/tic
	double revFrac;
	int age;
	Actor trail;
	Array<Actor> marks;
	Actor lastHit;
	int lastHitTic;

	Default
	{
		Projectile;
		+RIPPER
		+NOGRAVITY
		+BOUNCEONWALLS
		+BOUNCEONCEILINGS
		+BOUNCEONFLOORS
		+NOBOUNCESOUND
		+HITTRACER
		+CANBOUNCEWATER
		+USEBOUNCESTATE
		BounceType "Hexen";
		BounceFactor 0.9;
		WallBounceFactor 0.9;
		BounceCount 1;
		Radius 10;
		Height 6;
		Speed 20;
		Damage 0;
		DamageType "Saw";
		RenderStyle "Normal";
		SeeSound "";
		DeathSound "";
	}

	States
	{
	Spawn:
		SSQF ABCDEFGHIJKLMNOP 1;
		Loop;
	Death:
		SSQF A 1;
		Loop;
	Bounce:
		SSQF A 0 { if (invoker.phase == PH_OUT) invoker.Home(); }
		Goto Spawn;
	}

	// ---- launch -------------------------------------------------------------------
	void Launch(PlayerPawn mo, SSQ_Pose pose, int rev)
	{
		thrower = mo;
		int n = SSQ_Handler.SVI('ssq_rev_tics', 21);
		revFrac = n > 0 ? clamp(rev / double(n), 0, 1) : 0;
		Vector3 hv = pose.ThrowVel();		// units/tic
		double keep = 30.0 / (30.0 + SSQ_Handler.SV('ssq_mass_kg', 5.0));
		double sp = hv.Length() * keep * SSQ_Handler.SV('ssq_throw_speed', 1.0) * (1.0 + revFrac * SSQ_Handler.SV('ssq_rev_throw_bonus', 0.6));
		Vector3 dir = hv.Length() > 0.01 ? hv.Unit() : pose.F;
		sp = max(sp, SSQ_Handler.SV('ssq_speed_floor', 7.0));
		// the throw plane from the wrist: the disc's face is the plate's face
		Vector3 nrm = SSQ_Guard.PlateNormal(mo, pose, false);
		// the lock cone opens along the throw, not along the controller
		Begin(mo, dir, sp, SSQ_Hand.RollOf(dir, nrm) * SSQ_Handler.SV('ssq_roll_sign', 1.0), dir);
	}

	void LaunchAlong(PlayerPawn mo, Vector3 dir, double sp, double roll, int rev)
	{
		thrower = mo;
		int n = SSQ_Handler.SVI('ssq_rev_tics', 21);
		revFrac = n > 0 ? clamp(rev / double(n), 0, 1) : 0;
		Begin(mo, dir, sp * (1.0 + revFrac * SSQ_Handler.SV('ssq_rev_throw_bonus', 0.6)), roll, dir);
	}

	void Begin(PlayerPawn mo, Vector3 dir, double sp, double roll, Vector3 aim)
	{
		target = mo;
		cruise = sp;
		vel = dir * sp;
		angle = atan2(dir.y, dir.x);
		pitch = -asin(clamp(dir.z, -1, 1));
		self.roll = roll;
		phase = PH_OUT;
		crumbX.Clear(); crumbY.Clear(); crumbZ.Clear();
		Crumb();
		FindLocks(mo, aim);
		trail = Spawn('SSQ_DiscTrail', pos);
		if (trail) trail.target = self;
	}

	// targets in a cone from a point along an aim, nearest angle first, line of sight required.
	// Used every tic while the shield is held (SSQ_Handler.LocksTick: the markers you see) and
	// once more at launch, so what flies is what was shown.
	static void FindTargets(PlayerPawn mo, Vector3 from, Vector3 aim, out Array<Actor> found)
	{
		found.Clear();
		int want = SSQ_Handler.SVI('ssq_locks', 5);
		if (want <= 0) return;
		double cone = SSQ_Handler.SV('ssq_lock_cone', 16.0);
		double range = SSQ_Handler.SV('ssq_lock_range', 1200.0);
		Array<Actor> cand; Array<double> score;
		let it = ThinkerIterator.Create('Actor', STAT_DEFAULT);
		Actor t;
		while (t = Actor(it.Next()))
		{
			if (t == mo || !t.bShootable || t.health <= 0 || (!t.bIsMonster && !t.player)) continue;
			if (t.player && !deathmatch) continue;
			if (t.bFriendly && !deathmatch) continue;
			Vector3 d = t.pos + (0, 0, t.height * 0.5) - from;
			double dist = d.Length();
			if (dist > range || dist < 1) continue;
			double ang = acos(clamp((d / dist) dot aim, -1, 1));
			if (ang > cone) continue;
			if (!mo.CheckSight(t)) continue;
			double sc = ang + dist / range * 4.0;
			int k = 0;
			while (k < cand.Size() && score[k] <= sc) k++;
			cand.Insert(k, t); score.Insert(k, sc);
		}
		for (int i = 0; i < cand.Size() && i < want; i++) found.Push(cand[i]);
	}

	// the list at launch: what the player was shown while holding (SSQ_Handler), else a fresh
	// cone along the throw
	void FindLocks(PlayerPawn mo, Vector3 aim)
	{
		locks.Clear();
		lockAt = 0;
		let h = SSQ_Handler.Get();
		Array<Actor> shown;
		if (h) h.ShownLocks(mo.PlayerNumber(), shown);
		if (shown.Size() == 0) FindTargets(mo, pos, aim, shown);
		for (int i = 0; i < shown.Size(); i++)
		{
			if (!shown[i] || shown[i].health <= 0) continue;
			locks.Push(shown[i]);
			let m = Spawn('SSQ_LockMark', shown[i].pos + (0, 0, shown[i].height + 8));
			if (m) { m.tracer = shown[i]; marks.Push(m); }
		}
		if (locks.Size() > 0) A_StartSound("ssq/lock", CHAN_6);
	}

	Actor CurrentLock()
	{
		while (lockAt < locks.Size())
		{
			let t = locks[lockAt];
			if (t && t.health > 0) return t;
			lockAt++;
		}
		return null;
	}

	// ---- flight -------------------------------------------------------------------
	override void Tick()
	{
		if (IsFrozen()) return;
		age++;
		if (!thrower || thrower.health <= 0) { Home(); }
		if (age > 35 * 12) { Done(false); return; }

		if (phase == PH_OUT)
		{
			let t = CurrentLock();
			if (t)
			{
				Vector3 d = (t.pos + (0, 0, t.height * 0.5)) - pos;
				double dist = d.Length();
				if (dist > 1)
				{
					Vector3 want = d / dist * cruise;
					vel = vel * 0.78 + want * 0.22;
					double vl = vel.Length();
					if (vl > 0) vel = vel / vl * cruise;
				}
			}
			else if (locks.Size() == 0 ? age > 35 * 2 : age > 8) Home();
			if (age % max(1, SSQ_Handler.SVI('ssq_crumb_every', 4)) == 0) Crumb();
		}
		else if (phase == PH_EMBED)
		{
			if (!embedIn || embedIn.health <= 0 || embedTics <= 0) { Home(); }
			else
			{
				SetOrigin(embedIn.pos + embedOfs, true);
				vel = (0, 0, 0);
				embedTics--;
				if (embedTics % 3 == 0)
				{
					embedIn.DamageMobj(self, thrower, SSQ_Handler.SVI('ssq_embed_dps', 3) * 3, 'Saw');
					A_StartSound("ssq/grind", CHAN_5, 0, 0.8);
					SSQ_FX.Sparks(self, pos, (0, 0, 1), 3);
				}
			}
		}
		else if (phase == PH_HOME)
		{
			let h = SSQ_Handler.Get();
			int pnum = thrower ? thrower.PlayerNumber() : -1;
			// a hand waiting for it catches it
			if (h && pnum >= 0 && SSQ_Handler.SVI('ssq_catch', 1) != 0 && h.Holding(pnum))
			{
				let pose = h.PoseOf(pnum);
				if (pose.Fresh(Level.maptime) && (pose.pos[0] - pos).Length() <= SSQ_Handler.SV('ssq_catch_radius', 24.0))
				{ Done(true); return; }
			}
			Vector3 goal = (crumbAt >= 0 && crumbAt < crumbX.Size()) ? (crumbX[crumbAt], crumbY[crumbAt], crumbZ[crumbAt]) : (thrower ? SSQ_Handler.MountPos(thrower) : pos);
			Vector3 d = goal - pos;
			double dist = d.Length();
			double sp = SSQ_Handler.SV('ssq_return_speed', 22.0);
			if (dist <= sp * 1.2)
			{
				if (crumbAt >= 0) { crumbAt--; }
				else { Done(false); return; }
			}
			else vel = d / dist * sp;
			// shortcut: skip crumbs the disc can already see past
			if (crumbAt > 0 && thrower && CheckSight(thrower)) crumbAt = -1;
		}

		// the disc keeps its launch orientation; the mesh frames do the spinning
		Super.Tick();
		if (trail) trail.SetOrigin(pos, true);
		for (int i = 0; i < marks.Size(); i++)
		{
			let m = marks[i];
			if (!m) continue;
			if (!m.tracer || m.tracer.health <= 0 || (i < lockAt)) { m.Destroy(); marks[i] = null; continue; }
			m.SetOrigin(m.tracer.pos + (0, 0, m.tracer.height + 8), true);
			m.angle += 9;
		}
	}

	void Home()
	{
		if (phase == PH_HOME) return;
		phase = PH_HOME;
		embedIn = null;
		crumbAt = crumbX.Size() - 1;
	}

	void Crumb() { crumbX.Push(pos.x); crumbY.Push(pos.y); crumbZ.Push(pos.z); }

	void Recall() { Home(); }

	// home: caught or landed
	void Done(bool caught)
	{
		let h = SSQ_Handler.Get();
		if (h && thrower) h.DiscHome(thrower.PlayerNumber(), caught);
		if (trail) trail.Destroy();
		for (int i = 0; i < marks.Size(); i++) if (marks[i]) marks[i].Destroy();
		Destroy();
	}

	// ---- hitting ------------------------------------------------------------------
	override int SpecialMissileHit(Actor victim)
	{
		if (!victim || victim == thrower || victim == embedIn) return 1;
		if (victim == target) return 1;
		if (!victim.bShootable || victim.health <= 0) return 1;
		if (victim.player && !deathmatch) return 1;
		if (victim == lastHit && Level.maptime - lastHitTic < 6) return 1;
		lastHit = victim; lastHitTic = Level.maptime;

		double scale = SSQ_Handler.SV('ssq_cut_damage', 1.0) * (1.0 + revFrac * SSQ_Handler.SV('ssq_rev_throw_bonus', 0.6));
		int base = int((24 + random(0, 20)) * scale);
		int sh = victim.SpawnHealth();
		bool tiers = SSQ_Handler.SVI('ssq_tiers', 1) != 0;
		int fodder = SSQ_Handler.SVI('ssq_tier_fodder', 70);
		int mid = SSQ_Handler.SVI('ssq_tier_mid', 600);
		bool wasLock = locks.Find(victim) < locks.Size();

		if (tiers && !victim.bBoss && sh <= fodder)
		{
			// bisect: past the gib threshold every time
			int gib = max(victim.health + abs(victim.GibHealth) + 1, base);
			bool ne = victim.bNoExtremeDeath;
			victim.bNoExtremeDeath = false;
			victim.DamageMobj(self, thrower, gib, 'Saw', DMG_FORCED);
			if (victim && victim.health > 0) victim.bNoExtremeDeath = ne;
			A_StartSound("ssq/hit", CHAN_5);
			SSQ_FX.Sparks(self, pos, (0, 0, 1), 6);
			Next(wasLock);
			return 1;
		}
		if (tiers && !victim.bBoss && sh <= mid && phase == PH_OUT)
		{
			victim.DamageMobj(self, thrower, base, 'Saw');
			if (victim && victim.health > 0)
			{
				phase = PH_EMBED;
				embedIn = victim;
				embedOfs = pos - victim.pos;
				embedTics = SSQ_Handler.SVI('ssq_embed_tics', 21);
				A_StartSound("ssq/hit", CHAN_5);
				Next(wasLock);
				return 1;
			}
			Next(wasLock);
			return 1;
		}
		// heavy, or tiers off: a glance
		int dmg = tiers ? int(base * SSQ_Handler.SV('ssq_glance_scale', 0.4)) : base;
		victim.DamageMobj(self, thrower, max(1, dmg), 'Saw');
		A_StartSound("ssq/bounce", CHAN_5);
		SSQ_FX.Sparks(self, pos, (0, 0, 1), 8);
		if (tiers)
		{
			Vector3 away = (pos - (victim.pos + (0, 0, victim.height * 0.5))).Unit();
			vel = away * cruise;
			Next(wasLock);
			if (!CurrentLock()) Home();
		}
		return 1;
	}

	void Next(bool wasLock)
	{
		if (wasLock) lockAt++;
		// the last lock is done: home. A free throw (no locks) flies on until a wall or its time
		if (phase == PH_OUT && locks.Size() > 0 && !CurrentLock()) Home();
	}
}

class SSQ_DiscTrail : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.6;
	}
	States
	{
	Spawn:
		SSQF A 1 { if (target) { angle = target.angle; pitch = target.pitch; roll = target.roll; } else Destroy(); }
		Loop;
	}
}

class SSQ_LockMark : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		RenderStyle "Add";
		Alpha 0.8;
	}
	States
	{
	Spawn:
		SSQL ABCD 3 Bright;
		Loop;
	}
}
