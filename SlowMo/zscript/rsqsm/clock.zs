// RSQ_SlowMo -- THE CLOCK. The world slows; you do not.
//
// RS_SlowMo (the owner's engine build) asks the engine for a world time scale.
// Stock QuestZDoom 17.3 has no such call, so this mod keeps the clock itself:
// every actor near a player is TIME-DILATED, not frozen. Freezing the world on
// most tics is easy, but at quarter speed the world would update nine times a
// second, and that stutters in a headset. So every slowed thing still moves every
// tic, by the slowed amount:
//
//   motion     its velocity is scaled by the factor, and its gravity by the factor
//              squared, which is exactly a slowed trajectory (a fall slows too);
//              a missile's Speed is scaled so homing and re-aiming stay slowed;
//              sliding on the ground loses speed at the slowed rate (friction^f).
//   time       every state it enters lasts 1/f as long, with the fractions carried,
//              so a monster steps, fires and dies at the slowed rate; a change of
//              factor mid-state rescales what is left of that state.
//   sound      what it is playing drops in pitch with it (rsm_sound_follow, yours).
//
// A monster's walking is a step of Speed per A_Chase, and A_Chase runs once per
// state: stretching the states slows the walking. Its Speed is NOT also scaled,
// or it would walk at f squared.
//
// THE VR RULE: nothing tracked is slowed. Players, what they carry, and the
// series' own hand-held effects (classes named RSQ*, UBQS*, SSQ*: laser, grab,
// shield, saber) stay on real time. Your own rockets slow (rsqsm_slow_own).
//
// THE SAME DOORS AS RS_SlowMo, so callers do not change:
//   netevent rsm_toggle | rsm_on | rsm_off
//   netevent rsm_pulse <hold ms> <depth %>   (deeper wins, longer wins, eased by
//                                             this mod's own ramps)
//   netevent rsm_state                       (prints the clock)
// and the same host settings: rsm_depth, rsm_ramp_in, rsm_ramp_out, rsm_yield.
//
// STANDING DOWN. Two slow-motion systems compound and cannot see each other (the
// lesson RS_SlowMo paid for). If Bullet Time X is loaded (by class name, reached
// by string), or RS_SlowMo itself on an engine that has a world clock, this mod
// does nothing and says so, unless rsm_yield is 0.
//
// NETPLAY: the events arrive on every machine on the same tic and everything here
// is computed from synced state; only the sound pitch and the gesture read the
// local player, and the gesture only sends an event.

class RSQSM_Clock : EventHandler
{
	// ---- the clock (synced: in the save, the same on every machine) ----------
	double scale;            // the eased factor, 1 = full speed
	double target;
	bool   on;               // the held toggle
	int    pulseUntil;       // maptime the pulse holds until, 0 none
	double pulseDepth;
	double adr;              // the adrenaline meter, 0..100
	bool   rival;            // decided once per map

	// ---- the slowed actors (parallel arrays) -----------------------------------
	Array<Actor>  act;
	Array<double> fac;       // the factor applied to it now
	Array<double> baseGrav, baseSpeed, carry;
	Array<State>  lastState;
	Array<int>    lastTics;
	Array<double> lvx, lvy, lvz;   // its velocity as this handler left it last tic

	// ---- local (this machine) ---------------------------------------------------
	private transient int gestT, gestCool;
	private transient bool gestArmed;
	private transient int  pitchTick;
	private transient bool reloadPrimed;

	// The settings the per-actor loop reads, read once a tic (Refresh), not per actor.
	private transient int    cvTic;
	private transient double cvRadius2, cvRoundBase, cvDepth;
	private transient bool   cvSlowOwn;

	const MAXSCAN = 4000;

	static RSQSM_Clock Get() { return RSQSM_Clock(EventHandler.Find("RSQSM_Clock")); }

	// ---- settings ----------------------------------------------------------------
	static double Cv(String n, double d)
	{
		let c = CVar.GetCVar(n);
		return c ? c.GetFloat() : d;
	}
	static double CvP(String n, PlayerInfo p, double d)
	{
		let c = p ? CVar.GetCVar(n, p) : null;
		return c ? c.GetFloat() : d;
	}
	static double CvLocal(String n, double d)
	{
		if (!playeringame[consoleplayer]) return d;
		return CvP(n, players[consoleplayer], d);
	}
	double Depth()   { return clamp(Cv("rsm_depth", 0.25), 0.05, 0.95); }
	double RampIn()  { return max(0.0, Cv("rsm_ramp_in", 0.15)); }
	double RampOut() { return max(0.0, Cv("rsm_ramp_out", 0.40)); }

	// Slow motion is doing something this tic (the ramps count).
	bool Active() { return scale < 0.9999 || target < 0.9999; }

	// ---- the rival check -----------------------------------------------------------
	static bool RivalLoaded()
	{
		static const String rivals[] = { "BtActorInfo", "BtTimeFreeze", "BtItemData", "PostTickDummyController", "RSM_Handler" };
		for (int i = 0; i < rivals.Size(); i++)
			if (Object.FindClass(rivals[i]) != null) return true;
		return false;
	}
	bool StoodDown() { return rival && Cv("rsm_yield", 1) != 0; }

	// OnRegister also runs when a save is loaded, AFTER the synced fields are read back
	// (p_saveg.cpp), so it touches only this machine's transient state; the synced
	// defaults are set in WorldLoaded for a new level.
	override void OnRegister()
	{
		gestArmed = true;
		reloadPrimed = false;
		cvTic = -1;
	}

	override void WorldLoaded(WorldEvent e)
	{
		rival = RivalLoaded();
		if (e.IsSaveGame) return;
		// A level never starts slowed (and nothing carries over: the arrays are empty).
		on = false; target = 1; scale = 1; pulseUntil = 0; pulseDepth = 1;
		ClearAll();
		// An EventHandler is rebuilt on every map, so the meter is carried on the player.
		adr = 0;
		if (Cv("rsqsm_adr_keep", 1) != 0)
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (!playeringame[i] || !players[i].mo) continue;
				let t = RSQSM_AdrToken(players[i].mo.FindInventory("RSQSM_AdrToken"));
				if (t) { adr = t.meter; break; }
			}
		if (rival)
		{
			if (StoodDown())
				Console.Printf("\c[Red]RSQ_SlowMo: another slow-motion mod is loaded (Bullet Time X or RS_SlowMo).\n"
					.."\c[Grey]  Two slow-motion systems compound and cannot see each other. RSQ_SlowMo has STOOD DOWN.\n"
					.."  Set rsm_yield 0 to run anyway, or unload one.");
			else
				Console.Printf("\c[Orange]RSQ_SlowMo: another slow-motion mod is loaded and rsm_yield is 0: running anyway. THE TWO WILL COMPOUND.");
		}
	}

	// Leaving the level: every slowed thing is put back (a hub keeps them), and the
	// meter goes with the players to the next one.
	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = act.Size() - 1; i >= 0; i--) Drop(i);
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let pmo = players[i].mo;
			let t = RSQSM_AdrToken(pmo.FindInventory("RSQSM_AdrToken"));
			if (!t) t = RSQSM_AdrToken(pmo.GiveInventoryType("RSQSM_AdrToken"));
			if (t) t.meter = adr;
		}
	}

	private void ClearAll()
	{
		act.Clear(); fac.Clear(); baseGrav.Clear(); baseSpeed.Clear(); carry.Clear();
		lastState.Clear(); lastTics.Clear(); lvx.Clear(); lvy.Clear(); lvz.Clear();
	}

	// ---- the doors ---------------------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rsm_toggle")    Aim(!on, e.Player);
		else if (e.Name ~== "rsm_on")   Aim(true, e.Player);
		else if (e.Name ~== "rsm_off")  Aim(false, e.Player);
		else if (e.Name ~== "rsm_pulse") Pulse(e.Args[0], e.Args[1]);
		else if (e.Name ~== "rsm_state")
			Console.Printf("slow motion: %s, scale %.2f heading for %.2f (depth %.2f), %d actors slowed, adrenaline %.0f%s%s",
				on ? "ON" : "off", scale, target, Depth(), act.Size(), adr,
				pulseUntil > 0 ? String.Format(", pulse %.2f for %d tics", pulseDepth, pulseUntil - level.maptime) : "",
				StoodDown() ? ", STOOD DOWN (rival loaded)" : "");
	}

	private void Aim(bool want, int who)
	{
		if (StoodDown()) return;
		if (want && Cv("rsqsm_adrenaline", 0) != 0 && adr < Cv("rsqsm_adr_min", 25))
		{
			// Not enough in the meter: a short, low buzz on the hand that asked.
			if (who >= 0 && who < MAXPLAYERS && playeringame[who] && players[who].mo)
			{
				RSQSM_Buzz.Start(players[who].mo, 0, 0.25, 3);
				players[who].mo.A_StartSound("rsqsm/empty", CHAN_AUTO, CHANF_LOCAL, 0.6);
			}
			return;
		}
		on = want;
		if (on) pulseUntil = 0;     // the toggle outranks a pulse
		if (who >= 0 && who < MAXPLAYERS && playeringame[who] && players[who].mo)
		{
			players[who].mo.A_StartSound(on ? "rsqsm/in" : "rsqsm/out", CHAN_AUTO, 0, 0.8);
			RSQSM_Buzz.Start(players[who].mo, 0, on ? 0.6 : 0.3, on ? 8 : 4);
			RSQSM_Buzz.Start(players[who].mo, 1, on ? 0.6 : 0.3, on ? 8 : 4);
		}
	}

	// RS_SlowMo's pulse, same arguments and the same rules: hold `ms`, at `depthPct`
	// percent speed; the ramps are this mod's; deeper wins and longer wins; the held
	// toggle outranks it; both clamped so no caller can freeze the world for good.
	private void Pulse(int ms, int depthPct)
	{
		if (StoodDown() || on) return;
		int holdUntil = level.maptime + int(ceil(clamp(ms, 30, 5000) * TICRATE / 1000.0));
		double depth = clamp(depthPct / 100.0, 0.05, 1.0);
		if (pulseUntil > 0)
		{
			pulseUntil = max(pulseUntil, holdUntil);
			pulseDepth = min(pulseDepth, depth);
		}
		else
		{
			pulseUntil = holdUntil;
			pulseDepth = depth;
		}
	}

	// ---- every tic ---------------------------------------------------------------------
	override void WorldTick()
	{
		LocalGesture();
		if (StoodDown()) return;

		// Where the clock is heading: the toggle, then a pulse, then full speed.
		if (on) target = Depth();
		else if (pulseUntil > 0)
		{
			if (level.maptime < pulseUntil) target = pulseDepth;
			else { pulseUntil = 0; target = 1; }
		}
		else target = 1;

		// Ease, never snap: each ramp is the time to cross the whole way.
		if (scale != target)
		{
			double secs = (target < scale) ? RampIn() : RampOut();
			if (secs <= 0.001) scale = target;
			else
			{
				double step = 1.0 / (secs * TICRATE);
				if (abs(target - scale) <= step) scale = target;
				else scale += (target > scale) ? step : -step;
			}
		}

		Adrenaline();
		Reloads();

		bool running = Active();
		if (!running && act.Size() == 0) return;
		Refresh();
		if (running && (act.Size() == 0 || level.maptime % 17 == 0)) Gather();
		Process();
		if (!running) ClearAll();     // back at full speed and every actor restored
	}

	// ---- who is slowed ---------------------------------------------------------------------
	private void Refresh()
	{
		if (cvTic == level.maptime) return;
		cvTic = level.maptime;
		double r = Cv("rsqsm_radius", 3000);
		cvRadius2 = r * r;
		cvDepth = Depth();
		cvRoundBase = max(1.0, Cv("rsqsm_round_speed", 14)) / cvDepth;
		cvSlowOwn = Cv("rsqsm_slow_own", 1) != 0;
	}

	bool RealTime(Actor a)
	{
		if (!a || a.player) return true;
		if (a is "Inventory" && Inventory(a).Owner) return true;
		if (a.bDORMANT) return true;
		String n = a.GetClassName();
		n = n.MakeLower();
		if (n.Left(11) == "rsqsm_round") return false;    // our own rounds slow like any bullet
		if (n.Left(3) == "rsq" || n.Left(4) == "ubqs" || n.Left(3) == "ssq") return true;
		// Your own missiles, when that is switched off.
		if (a.bMISSILE && a.target && a.target.player && !cvSlowOwn) return true;
		return false;
	}

	bool NearAPlayer(Actor a)
	{
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p] || !players[p].mo) continue;
			Vector3 d = level.Vec3Diff(players[p].mo.pos, a.pos);
			if (d dot d <= cvRadius2) return true;
		}
		return false;
	}

	// SPAWNED: WorldThingSpawned comes from PostBeginPlay, just before the thing's first
	// tic -- after whoever spawned it has set its velocity (dthinker.cpp, p_mobj.cpp). So
	// its velocity, Speed and gravity are final and are all scaled now, before it ever
	// moves at full speed. A round arrives already slowed (it sets preFactor).
	void Consider(Actor a, bool spawned)
	{
		if (RealTime(a)) return;
		if (act.Size() >= MAXSCAN) return;
		int i = act.Size();
		double f = spawned ? FactorFor(a, a.Speed) : 1.0;
		double pre = 1.0;
		let rnd = RSQSM_Round(a);
		if (rnd && rnd.preFactor > 0) { pre = rnd.preFactor; f = pre; }
		act.Push(a);
		fac.Push(f);
		baseGrav.Push(a.Gravity);
		baseSpeed.Push(rnd && rnd.preFactor > 0 ? rnd.baseSpeed : a.Speed);
		carry.Push(0);
		lastState.Push(spawned ? null : a.CurState);   // a new thing's first state is stretched at the first look
		lastTics.Push(a.tics);
		if (spawned && f < 0.9999 && pre == 1.0)
		{
			a.vel *= f;
			if (a.bMISSILE) a.Speed = baseSpeed[i] * f;
			a.Gravity = baseGrav[i] * f * f;
		}
		lvx.Push(a.vel.x); lvy.Push(a.vel.y); lvz.Push(a.vel.z);
	}

	// Things already in the world near a player (the first look, then every 17 tics for
	// what has come into range). Missiles spawned while it runs arrive through
	// WorldThingSpawned.
	private void Gather()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		bool first = act.Size() == 0;
		while ((a = Actor(it.Next())) && act.Size() < MAXSCAN)
		{
			if (RealTime(a) || !NearAPlayer(a)) continue;
			if (!first && act.Find(a) < act.Size()) continue;
			Consider(a, false);
		}
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (Active() && !StoodDown() && e.Thing) { Refresh(); Consider(e.Thing, true); }
	}

	// The factor an actor wants: the clock near a player, full speed out of range.
	// A fast, small missile (a bullet fired as a projectile, Brutal Doom's way) is
	// slowed further, to the round speed, so it can be seen and dodged too.
	double FactorFor(Actor a, double base)
	{
		double s = scale;
		if (s >= 0.9999) return 1.0;
		Refresh();
		if (!NearAPlayer(a)) return 1.0;
		if (a.bMISSILE && a.radius <= 8 && !(a is "RSQSM_Round") && base > cvRoundBase * 1.05)
		{
			double k = clamp((1.0 - s) / max(1.0 - cvDepth, 0.01), 0.0, 1.0);
			return s * (1.0 - k * (1.0 - cvRoundBase / base));
		}
		return s;
	}

	// A dodgeable round's speed at full time, so that at the set depth it flies at
	// rsqsm_round_speed.
	double RoundBase() { Refresh(); return cvRoundBase; }

	private void Process()
	{
		double follow = clamp(CvLocal("rsm_sound_follow", 1.0), 0.0, 1.0);
		bool doPitch = (++pitchTick % 4) == 0;
		bool wakes = Cv("rsqsm_wakes", 1) != 0;
		for (int i = act.Size() - 1; i >= 0; i--)
		{
			Actor a = act[i];
			if (!a || a.bDestroyed)
			{
				Drop(i);
				continue;
			}
			double want = FactorFor(a, baseSpeed[i]);
			double f = fac[i];

			// A script that set its own gravity or speed since last tic (Brutal Doom's gibs
			// do, in their first state) is taken as the new base, not overwritten.
			if (abs(a.Gravity - baseGrav[i] * f * f) > 0.000001) baseGrav[i] = a.Gravity / (f * f);
			if (a.bMISSILE && abs(a.Speed - baseSpeed[i] * f) > 0.0001) baseSpeed[i] = a.Speed / f;
			if (f < 0.9999) Impulses(a, i, f);

			// A state entered since last tic lasts 1/f as long (at the factor it was entered
			// under; a change of factor is applied after, to what is left of it).
			if (f < 0.9999 && a.tics > 0 && !a.isFrozen())
			{
				// Counting down as usual is the same state one tic shorter. The same state
				// with the same count is a thing not ticking -- unless the count is 1,
				// which is a one-tic state looping onto itself.
				bool same = a.CurState == lastState[i];
				bool counting = same && a.tics == lastTics[i] - 1;
				bool stalled = same && a.tics == lastTics[i] && a.tics > 1;
				bool entered = !counting && !stalled;
				if (entered)
				{
					double t = a.tics / f + carry[i];
					int nt = max(1, int(t));
					carry[i] = t - nt;
					a.tics = nt;
				}
			}
			if (abs(want - f) > 0.0001)
			{
				double r = want / f;
				a.vel *= r;
				if (a.bMISSILE) a.Speed = baseSpeed[i] * want;
				// Gravity is written whatever NOGRAVITY says now: dying clears that flag
				// (a cacodemon's corpse falls), and a flag set later must not keep f^2.
				a.Gravity = baseGrav[i] * want * want;
				if (a.tics > 0)
				{
					double t = a.tics / r + carry[i];
					int nt = max(1, int(t));
					carry[i] = t - nt;
					a.tics = nt;
				}
				fac[i] = want;
			}

			lastState[i] = a.CurState;
			lastTics[i] = a.tics;

			if (want < 0.9999)
			{
				// Sliding on the ground loses speed at the slowed rate.
				if (a.pos.z <= a.floorz + 0.01 && !a.bNOGRAVITY && !a.bMISSILE && (a.vel.x != 0 || a.vel.y != 0))
				{
					double fr, mf;
					[fr, mf] = a.GetFriction();
					if (fr > 0 && fr < 1) { double k = fr ** (want - 1.0); a.vel.x *= k; a.vel.y *= k; }
				}
				if (doPitch) Repitch(a, 1.0 - (1.0 - want) * follow);
				if (wakes && a.bMISSILE && (level.maptime + i) % 2 == 0) Wake(a);
			}
			else if (doPitch) Repitch(a, 1.0);

			if (want >= 0.9999 && (!Active() || !NearAPlayer(a))) { Drop(i); continue; }
			lvx[i] = a.vel.x; lvy[i] = a.vel.y; lvz[i] = a.vel.z;
		}
	}

	// A push given at full strength in slowed time (a thrust, a jump, a script that
	// sets a velocity, Brutal Doom's tracers kicking themselves sideways) is a change
	// of velocity, and velocities here are per tic: it is scaled by the factor too.
	// What the engine itself did since last tic is predicted and left alone: gravity
	// (already scaled), ground friction (compensated below), a missile re-aimed from
	// its own (scaled) Speed. Bouncers, things that hit a wall or a thing, and
	// landings are left alone too: a reflection or a stop is not a push.
	private void Impulses(Actor a, int i, double f)
	{
		if (a.bBOUNCEONWALLS || a.bBOUNCEONFLOORS || a.bBOUNCEONCEILINGS || a.BlockingLine || a.BlockingMobj) return;
		Vector3 expect = (lvx[i], lvy[i], lvz[i]);
		bool onFloor = a.pos.z <= a.floorz + 0.01;
		if (!a.bNOGRAVITY && !onFloor) expect.z -= level.gravity * a.CurSector.gravity * a.Gravity * 0.00125;
		if (onFloor && !a.bNOGRAVITY && !a.bMISSILE)
		{
			double fr, mf;
			[fr, mf] = a.GetFriction();
			expect.x *= fr; expect.y *= fr;
		}
		Vector3 d = a.vel - expect;
		bool touching = onFloor || a.pos.z + a.height >= a.ceilingz - 0.01;
		if (touching) d.z = 0;          // a landing or a bump on the ceiling
		if (d.Length() <= 0.5) return;
		if (a.bMISSILE && abs(a.vel.Length() - a.Speed) <= a.Speed * 0.05 + 0.01) return;
		double vz = touching ? a.vel.z : expect.z + d.z * f;
		a.vel = (expect.x + d.x * f, expect.y + d.y * f, vz);
	}

	private void Drop(int i)
	{
		Actor a = act[i];
		if (a && !a.bDestroyed && fac[i] != 1.0)
		{
			double r = 1.0 / fac[i];
			a.vel *= r;
			if (a.bMISSILE) a.Speed = baseSpeed[i];
			a.Gravity = baseGrav[i];
			if (a.tics > 0) a.tics = max(1, int(a.tics / r));
		}
		act.Delete(i); fac.Delete(i); baseGrav.Delete(i); baseSpeed.Delete(i); carry.Delete(i);
		lastState.Delete(i); lastTics.Delete(i); lvx.Delete(i); lvy.Delete(i); lvz.Delete(i);
	}

	private static void Repitch(Actor a, double pitch)
	{
		pitch = clamp(pitch, 0.4, 1.0);
		for (int ch = 1; ch <= 7; ch++)
			if (a.IsActorPlayingSound(ch)) a.A_SoundPitch(ch, pitch);
	}

	// The bent air behind a slowed missile: a short, fading wake.
	private static void Wake(Actor a)
	{
		if (a.bINVISIBLE || a.vel.Length() < 0.5) return;
		FSpawnParticleParams p;
		p.color1 = "DDE6FF";
		p.style = STYLE_Add;
		p.flags = SPF_FULLBRIGHT;
		p.lifetime = 18;
		p.size = 3;
		p.sizestep = 0.25;
		p.pos = a.pos + (0, 0, a.height * 0.5);
		p.startalpha = 0.35;
		p.fadestep = -1;
		level.SpawnParticle(p);
	}

	// ---- the adrenaline meter (rsqsm_adrenaline) ----------------------------------------------
	// Earned from kills and from the rounds and hurts you take; spent while the held
	// slow motion runs. Off, slow motion is free.
	void AddAdrenaline(double n)
	{
		if (Cv("rsqsm_adrenaline", 0) == 0) return;
		double was = adr;
		adr = clamp(adr + n, 0.0, 100.0);
		if (was < 100 && adr >= 100)
			for (int p = 0; p < MAXPLAYERS; p++)
				if (playeringame[p] && players[p].mo) players[p].mo.A_StartSound("rsqsm/ready", CHAN_AUTO, 0, 0.7);
	}

	private void Adrenaline()
	{
		if (Cv("rsqsm_adrenaline", 0) == 0 || !on) return;
		adr -= 100.0 / max(1.0, Cv("rsqsm_adr_secs", 10) * TICRATE);
		if (adr <= 0) { adr = 0; Aim(false, -1); }
	}

	// A KILL IS COUNTED WHERE THE DAMAGE NAMES ITS SOURCE. WorldThingDied only carries the inflictor,
	// and a hitscan's inflictor is its puff, which points at nobody unless the puff is PUFFGETSOWNER:
	// measured, a player's pistol kill earned no adrenaline. The killing blow's WorldThingDamaged has
	// the source itself; a death that never passes through damage (a script's A_Die) still counts
	// through WorldThingDied as before.
	private transient Actor lastKilled;
	override void WorldThingDied(WorldEvent e)
	{
		if (!e.Thing || !e.Thing.bISMONSTER || e.Thing == lastKilled) return;
		Actor src = e.Inflictor;
		if (src && !src.player) src = src.target;
		if (src && src.player) AddAdrenaline(Cv("rsqsm_adr_kill", 12));
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (e.Thing && e.Thing.player && e.Damage > 0) AddAdrenaline(e.Damage * 0.5);
		if (e.Thing && e.Thing.bISMONSTER && e.Thing.health <= 0 && e.Thing != lastKilled)
		{
			Actor src = e.DamageSource;
			if (src && !src.player && src.FriendPlayer > 0) src = players[src.FriendPlayer - 1].mo;
			if (src && src.player) { lastKilled = e.Thing; AddAdrenaline(Cv("rsqsm_adr_kill", 12)); }
		}
	}

	// ---- a reload buys a moment (rsqsm_reload, each player's own choice) ----------------------
	// Two signs, either one: the weapon's Reload sequence starts playing, or ammo moves
	// from the reserve into the magazine on one tic (one count falls as the other
	// rises; a pickup only ever raises). The second catches Brutal Doom's reloads,
	// which reach their animation through their own tokens and jumps rather than by
	// playing on from "Reload" (measured: BD22 Rifle, magazine 20 -> 31, reserve 30 ->
	// 19, while the Reload sequence check saw nothing). The BD22 set's immersive
	// reloads, or anything else, can also call rsm_pulse directly.
	private transient bool wasReloading[MAXPLAYERS];
	private transient int  lastA1[MAXPLAYERS], lastA2[MAXPLAYERS];
	private transient Weapon lastW[MAXPLAYERS];
	private void Reloads()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n]) continue;
			let p = players[n];
			let w = p.ReadyWeapon;
			bool wanted = w && CvP("rsqsm_reload", p, 0) != 0;
			bool r = false, moved = false;
			int a1 = (w && w.Ammo1) ? w.Ammo1.Amount : 0;
			int a2 = (w && w.Ammo2) ? w.Ammo2.Amount : 0;
			if (wanted)
			{
				State rs = w.FindState("Reload");
				let ps = p.GetPSprite(PSP_WEAPON);
				r = rs && ps && ps.CurState && Actor.InStateSequence(ps.CurState, rs);
				if (w == lastW[n] && w.Ammo1 && w.Ammo2 && w.Ammo1 != w.Ammo2)
					moved = (a2 > lastA2[n] && a1 < lastA1[n]) || (a1 > lastA1[n] && a2 < lastA2[n]);
			}
			if (reloadPrimed && ((r && !wasReloading[n]) || moved))
				Pulse(int(CvP("rsqsm_reload_ms", p, 1200)), int(CvP("rsqsm_reload_depth", p, 40)));
			wasReloading[n] = r;
			lastW[n] = w; lastA1[n] = a1; lastA2[n] = a2;
		}
		reloadPrimed = true;     // the first tic after a load only looks
	}

	// ---- the gesture (local; it only sends the toggle) ------------------------------------------
	// Cross your wrists in front of your face and hold them there a moment.
	private void LocalGesture()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) return;
		if (CvP("rsqsm_gesture", p, 1) == 0) return;
		if (gestCool > 0) { gestCool--; return; }
		let pmo = p.mo;
		Vector3 head = (pmo.pos.xy, p.viewz);
		Vector3 a = pmo.AttackPos, b = pmo.OffhandPos;
		double together = Metres(a - b);
		Vector2 fwd = (cos(pmo.angle), sin(pmo.angle));
		Vector3 mid = (a + b) * 0.5;
		Vector3 d = mid - head;
		double ahead = (d.xy dot fwd) / 34.0;
		double up = d.z * 1.2 / 34.0;
		bool pose = together < CvP("rsqsm_gesture_gap", p, 0.16) && ahead > 0.12 && ahead < 0.6 && up > -0.40 && up < 0.15;
		if (!pose) { gestT = 0; gestArmed = true; return; }
		if (!gestArmed) return;
		if (++gestT >= int(CvP("rsqsm_gesture_hold", p, 12)))
		{
			EventHandler.SendNetworkEvent("rsm_toggle");
			gestT = 0;
			gestArmed = false;      // apart again before the next one
			gestCool = 20;
		}
	}

	static double Metres(Vector3 d) { return (d.x, d.y, d.z * 1.2).Length() / 34.0; }
}

// A RUMBLE WITH A LENGTH AND A STRENGTH, on one controller: the series' route
// (A_QuakeEx QF_WAVE re-issued every tic; X = left, Y = right; lefty when
// vr_control_scheme >= 10). Local player only; rsqsm_haptics.
class RSQSM_Buzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;

	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH }

	static void Start(Actor who, int hand, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let cv = CVar.GetCVar("rsqsm_haptics", who.player);
		if (cv && !cv.GetBool()) return;
		let q = RSQSM_Buzz(Actor.Spawn("RSQSM_Buzz", who.pos));
		if (!q) return;
		let sch = CVar.FindCVar("vr_control_scheme");
		bool lefty = sch && sch.GetInt() >= 10;
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}

// The adrenaline meter, carried with the player from level to level (an EventHandler
// is rebuilt on every map).
class RSQSM_AdrToken : Inventory
{
	double meter;
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.KEEPDEPLETED
	}
}

// FOR OTHER MODS, found by name (nothing links): GetInt("adrenaline.add", "", points) adds to
// the shared adrenaline meter (nothing while the meter is off) and answers the meter after it,
// 0..100. GetInt("adrenaline") reads it. GetInt("slowmo.active") (or "active") is 1 while the world
// is slowed (held, a pulse, or easing), 0 when not or stood down -- RSQ_Score's Bullet Time and the
// Gun Bonsai VR patch's slow-motion perks read it; GetInt("scale") is the world's speed in permille.
// -1: unknown request.
// The Gun Bonsai VR patch's Adrenaline upgrade charges it on melee kills.
class RSQSM_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let c = RSQSM_Clock.Get();
		if (!c) return -1;
		if (request ~== "adrenaline.add") { c.AddAdrenaline(intArg); return int(c.adr); }
		if (request ~== "adrenaline") return int(c.adr);
		if (request ~== "slowmo.active") return (!c.StoodDown() && c.Active()) ? 1 : 0;
		// slow motion is doing something this tic (1) or not (0), and how slow, in permille
		// of full speed (1000 = not slowed) -- the Gun Bonsai VR patch's slow-motion perks
		if (request ~== "active") return (c.Active() && !c.StoodDown()) ? 1 : 0;
		if (request ~== "scale") return int(clamp(c.scale, 0.0, 1.0) * 1000);
		return -1;
	}
}
