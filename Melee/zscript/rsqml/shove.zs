// THE GUN-BUTT SHOVE, THE SLOW-MO AFTER IT, THE F.E.A.R. EFFECT (RSQ Melee). Moved from RSQ Gestures on 2026-11-01
// (gestures.zs ShoveAct / ButtShove / Pulse / FEAR, the owner's #1 and #2 and his F.E.A.R. Effect).
//
// THE SWING IS READ HERE, not asked of RSQ Gestures (the owner's series rule: no mod requires another). The reader is
// Gestures' own punch-and-shove reader, copied for the main hand: a hand ring of the last RING tics of movement from
// the eyes (so walking is not a swing), a swing arms on a slow hand, counts once it has travelled ARM_M on
// consecutive tics at SWING_MPS on average, and is a shove when a GUN is in that hand (not fists, not a blade) and it
// drives forward (not drawn back, not swung down). Then the butt shove needs rsqml_shove_mps (3.6, BD22 VR Reloaded's
// BUTT_SWING). With Gestures loaded it still reads its own "shove" answer for other mods; it no longer acts on it, so
// one swing is one blow.
//
//   BUTT SHOVE   BD22 VR Reloaded's butt strike (the owner's mod; its zscript/rsvr/melee.zs, 2.0-b1m and 1.99x-lb-r7
//                agree), ported. Every number is theirs or Brutal Doom's, parsed, with the line:
//     swing  BUTT_SWING 3.6 m/s (melee.zs:168): the shove must average this (rsqml_shove_mps; theirs is measured at
//            the stock's tip, ours at the hand: there is no gun model to measure)
//     reach  BUTT_REACH 60 map units ahead along the way the swing moves, padded BUTT_PAD 12 (melee.zs:178-179: BD22's
//            own kick envelope, KickAttack Speed 30 x 2 tics + Radius 12); each body struck once per shove, and only
//            with a clear line from the hand (melee.zs Sweep / Clear)
//     blow   what it lands is BD22's KickAttack (melee.zs:851), here as plain damage: brutal22test6 Melee.dec:1727
//            KickAttack Damage 14, DamageType Kick; SuperKickAttack Damage 62 under the Berserk (:1841)
//     knock  the engine's own damage kickback (inflictor = you, so straight away from you), PLUS what Brutal Doom's
//            monsters do on a Kick (their Pain.Kick: A_FaceTarget, ThrustThing(angle + 180, back), ThrustThingZ up/4).
//            A Brutal Doom monster has that state and does it itself; a vanilla one gets the same numbers (KnockOf).
//     sound  the swing: Brutal Doom's Melee/SwingStrong (melee.zs:661), or stock Doom's skeleton/swing without it; a
//            hit: Brutal Doom's Kick/flesh (KickAttack's XDeath), or stock Doom's punch (*fist, DSPUNCH) without it
//     wait   12 tics before the next (melee.zs:663 whooshWait)
//     alert  A_AlertMonsters(200) on a hit (KickAttack's XDeath)
//   STANDS DOWN when BD22 VR Reloaded is loaded (found by class name through a String at run time): its own strike is
//                the one, whatever its rsq_butt says.
//   SLOW-MO      (on by default) a landed shove -- ours, or BD22 VR Reloaded's own with it loaded -- asks RSQ SlowMo for
//                a short pulse (rsm_pulse <ms> 35). Nothing hears it without SlowMo.
//   F.E.A.R.     while the slow motion that pulse started lasts, every shotgun hit of the shover's on a monster bleeds
//                twice (the hit's own blood again: SpawnBlood + TraceBleed), and a kill by it pays RSQ Score's
//                "F.E.A.R. Effect" award (RS_ScoreService "award", 200).
//
// NETPLAY (QZD has none; do not make it worse): the swing is read on the machine with the hands and leaves as
// rsqml_buttshove (arg0 two hands, arg1 hundredths of m/s, arg2 yaw x 1000 + pitch + 90), applied to e.Player.
class RSQML_Shove : StaticEventHandler
{
	const RING = 9;           // tics of hand movement kept (~250 ms)
	const SNAP = 8.0;         // a body turn this many degrees in one tic is a snap turn: forget motion
	const ARM_M = 0.15;       // metres of travel before a swing counts (SuperPunchOut's)
	const IN_MPS = 0.25;      // m/s that still counts as coming in
	const MAX_TICS = 14;      // longer than this is two motions
	const MAX_STALE = 3;      // tics a hand may repeat its last pose (a late frame) inside one swing
	const SWING_MPS = 2.0;    // a swing (Gestures' rsqg_punch_mps default); the butt shove then needs rsqml_shove_mps
	const REHIT = 6;          // tics before the hand arms again (Gestures' rsqg_punch_rehit default)
	const RISE = 0.5;         // the upward share that would make it an uppercut, not a forward drive (rsqg_punch_rise)
	const TOGETHER = 0.6;     // the other hand moving the same way at this share = two hands on the gun (rsqg_punch_together)

	const BUTT_REACH = 60.0;
	const BUTT_PAD = 12.0;
	const BUTT_WAIT = 12;
	const BUTT_DMG = 14;
	const BUTT_DMG_ZERK = 62;
	const BUTT_ALERT = 200.0;
	const PULSE_DEPTH = 35;   // % world speed: RSQ Score's PULSE_DEPTH, which ShieldSaw's perfect block also asks

	// the hands (console player): ring of velocities, metres a second on the map's axes
	bool live[2];
	Vector3 prevRel[2];
	double rvx[18], rvy[18], rvz[18];
	int ringAt[2], ringN[2];
	double prevAngle;
	bool swapWas;
	// the main hand's swing
	bool pArmed;
	double pTravel;
	int pTics, pStale, lastSwing;
	Vector3 pDir;
	int lastButt;
	// BD22 VR Reloaded is loaded (ours stands down); its KickAttacks seen spawning, the last one fired by you, and the
	// last main-hand shove with its butt strike possible (gametics, 0 = none / used)
	bool bdq;
	Array<Actor> bdKicks;
	Array<int> bdKickAt;
	int bdKickTic, bdShoveTic;
	// F.E.A.R.: whose window is open (-1 none), until when at the latest, whether SlowMo has been seen slowing, the
	// monsters already paid for
	int fearPn, fearTill, fearFrom;
	bool fearSlow;
	Array<Actor> fearPaid;
	transient Service svcSlowMo, svcGrapple, svcWheel;
	int svcLook, quietTill;
	// the award's name low in the view
	String sayName;
	int sayTic;

	static RSQML_Shove Get() { return RSQML_Shove(StaticEventHandler.Find("RSQML_Shove")); }

	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static int Dbg() { return RSQML.Debug(); }

	override void OnRegister() { bdq = BD22QLoaded(); fearPn = -1; }
	override void WorldLoaded(WorldEvent e)
	{
		bdq = BD22QLoaded(); fearPn = -1; fearPaid.Clear(); bdKicks.Clear(); bdKickAt.Clear(); bdKickTic = 0; bdShoveTic = 0;
		live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; pArmed = false; Reset();
		lastButt = 0; lastSwing = 0; quietTill = 0; svcLook = 0;
	}
	override void WorldUnloaded(WorldEvent e) { fearPn = -1; fearPaid.Clear(); bdKicks.Clear(); bdKickAt.Clear(); }

	// BD22 VR Reloaded (the owner's Brutal Doom VR mod), by class name through a String: RSVR_MeleeHandler owns its butt
	// strike (melee.zs:20), RSQ_Hands is its off-hand fists (hands.zs:138). Both are in 2.0-b1m and 1.99x-lb-r7.
	static bool BD22QLoaded()
	{
		static const String names[] = { "RSVR_MeleeHandler", "RSQ_Hands" };
		for (int i = 0; i < names.Size(); i++)
			if (Object.FindClass(names[i]) != null) return true;
		return false;
	}

	bool Wanted() { return bdq ? Opt("rsqml_shove_slowmo", 1) != 0 : Opt("rsqml_shove", 1) != 0; }

	void Reset() { pTravel = 0; pTics = 0; pStale = 0; pDir = (0, 0, 0); }

	PlayerPawn Me()
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return null;
		let p = players[consoleplayer];
		return (p && p.mo && p.mo.health > 0) ? p.mo : null;
	}

	override void WorldTick()
	{
		if (Wanted()) Read();
		else if (live[0] || live[1]) { live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; pArmed = false; Reset(); }
		if (bdq) WatchBDButt();
		if (fearPn >= 0) FearTick();
	}

	// ---- the hands ---------------------------------------------------------------------------------------------
	Vector3 VelAgo(int h, int ago)
	{
		int i = (ringAt[h] - ago + RING * 4) % RING;
		return (rvx[h * RING + i], rvy[h * RING + i], rvz[h * RING + i]);
	}

	void Read()
	{
		let pmo = Me();
		if (!pmo) { live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; return; }
		if (abs(Actor.DeltaAngle(prevAngle, pmo.Angle)) >= SNAP) { live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; }
		prevAngle = pmo.Angle;
		// RSQ Accessibility's Off-Hand Modifier: held, the main controller plays the off hand, so the main hand swings
		// nothing of its own; pressing or letting go jumps a pose, which is no movement: start again
		bool sw = RSQML_A11y.Ctrl(pmo, 1) == 0;
		if (sw != swapWas) { swapWas = sw; live[0] = false; live[1] = false; ringN[0] = 0; ringN[1] = 0; pArmed = false; Reset(); }
		Vector3 eye = RSQML_Hands.EyePos(pmo);
		double u = RSQML.UnitsPerMetre(), ps = RSQML.Stretch();
		for (int h = 0; h < 2; h++)
		{
			Vector3 hp; bool ok;
			[hp, ok] = RSQML_Hands.Pos(pmo, h);
			if (!ok || (sw && h == 0)) { live[h] = false; ringN[h] = 0; continue; }
			Vector3 d = hp - eye;
			Vector3 rel = (d.x, d.y, d.z * ps) / u;
			if (live[h])
			{
				Vector3 v = (rel - prevRel[h]) * TICRATE;
				int at = (ringAt[h] + 1) % RING;
				ringAt[h] = at;
				rvx[h * RING + at] = v.x; rvy[h * RING + at] = v.y; rvz[h * RING + at] = v.z;
				if (ringN[h] < RING) ringN[h]++;
			}
			prevRel[h] = rel;
			live[h] = true;
		}
		if (Quiet(pmo)) { pArmed = false; Reset(); return; }
		Swing(pmo);
	}

	// QUIET (Gestures' GE1): on RSQ Grapple's rope (climbing, swinging, reeling) or with RSQ Wheel's ring open, and RING
	// tics after, nothing is a swing. Asked by name; neither mod is touched.
	bool Quiet(PlayerPawn pmo)
	{
		if (gametic >= svcLook)
		{
			if (!svcGrapple) svcGrapple = RSQML.Svc("RSQGR_Service");
			if (!svcWheel) svcWheel = RSQML.Svc("wr_RigService");
			svcLook = gametic + TICRATE;
		}
		bool q = (svcGrapple && (svcGrapple.GetInt("climbing", "", 0, 0, pmo) == 1 || svcGrapple.GetInt("swinging", "", 0, 0, pmo) == 1
			|| svcGrapple.GetInt("reeling", "", 0, 0, pmo) == 1)) || (svcWheel && svcWheel.GetInt("IsOpen", "", 0, 0, pmo) == 1);
		if (q) quietTill = gametic + RING;
		return gametic < quietTill;
	}

	// THE SWING (Gestures' Punch1 for the main hand, the shove branch)
	void Swing(PlayerPawn pmo)
	{
		if (!live[0] || ringN[0] <= 0) { pArmed = false; Reset(); return; }
		Vector3 v = VelAgo(0, 0);
		// a tic that repeats the last pose exactly is a late frame, not a stop (the hand is written per rendered frame)
		if (v == (0, 0, 0) && pTics > 0 && pStale < MAX_STALE) { pStale++; return; }
		pStale = 0;
		double mps = v.Length();
		if (!pArmed)
		{
			if (gametic - lastSwing >= REHIT && mps < SWING_MPS * 0.6) pArmed = true;
			return;
		}
		if (mps >= IN_MPS && pTics < MAX_TICS) { pTravel += mps / TICRATE; pTics++; pDir += v / TICRATE; }
		else { Reset(); return; }
		if (pTravel < ARM_M) return;
		double avg = pTravel * TICRATE / pTics;
		if (avg < SWING_MPS) return;
		Vector3 swing = pDir;
		Vector3 un = v.Unit();
		pArmed = false; lastSwing = gametic; Reset();
		if (!GunIn(pmo)) return;
		// not a drive forward: drawn BACK (toward you, not rising) or swung DOWN (Brutal Doom VR's butt strike drives
		// forward too: melee.zs rsvr_butt_fwd)
		Vector2 face = (cos(pmo.Angle), sin(pmo.Angle));
		if (((un.xy dot face) < -0.3 && un.z <= RISE) || un.z < -RISE)
		{
			if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: not a shove, %.2f m/s: %s (t%d)", avg, un.z < -RISE ? "swung down" : "drawn back", level.maptime);
			return;
		}
		bool two = (pmo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0
			|| (live[1] && ringN[1] > 0 && (VelAgo(1, 0) dot un) >= mps * TOGETHER);
		if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: shove%s, main hand, %.2f m/s, with %s (t%d)", two ? " (two hands)" : "", avg, pmo.player.ReadyWeapon.GetClassName(), level.maptime);
		ShoveAct(pmo, two, avg, swing);
	}

	// A GUN IN THE MAIN HAND: not fists (Brutal Doom's Melee_Attacks, Brutal Doom VR's RSQ_Hands, vanilla's Fist), not a
	// blade or anything else flagged melee (the gloves, the saber, BD22's axe and chainsaw).
	static bool GunIn(PlayerPawn pmo)
	{
		let w = pmo.player ? pmo.player.ReadyWeapon : null;
		if (!w) return false;
		Name cn = w.GetClassName();
		if (cn == 'Melee_Attacks' || cn == 'RSQ_Hands' || cn == 'Fist') return false;
		if (w.bMeleeWeapon || cn == 'DSweap' || cn == 'Chain_saw' || cn == 'RSQ_Off_BrutalAxe') return false;
		return true;
	}

	void ShoveAct(PlayerPawn pmo, bool two, double avg, Vector3 swing)
	{
		if (bdq)
		{
			// BD22 VR Reloaded is loaded: ours does nothing. Its own strike is watched for the slow-mo only.
			if (Opt("rsqml_shove_slowmo", 1) && BDButtPossible(pmo)) bdShoveTic = gametic;
			if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: butt shove stands down: BD22 VR Reloaded is loaded (t%d)", level.maptime);
			return;
		}
		if (!Opt("rsqml_shove", 1)) return;
		double need = Num("rsqml_shove_mps", 3.6);
		if (avg < need)
		{
			if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: butt shove too slow, %.2f m/s of %.2f (t%d)", avg, need, level.maptime);
			return;
		}
		if (lastButt > 0 && gametic - lastButt < BUTT_WAIT) return;
		lastButt = gametic;
		// the swing's direction in map units (the vertical back out of metres: / pixelstretch)
		Vector3 d = (swing.x, swing.y, swing.z / RSQML.Stretch());
		if (d.Length() < 0.0001) d = (cos(pmo.Angle), sin(pmo.Angle), 0);
		d = d.Unit();
		int yaw = int(round(VectorAngle(d.x, d.y))) % 360;
		if (yaw < 0) yaw += 360;
		int pit = clamp(int(round(asin(clamp(d.z, -1, 1)))), -90, 90) + 90;
		EventHandler.SendNetworkEvent("rsqml_buttshove", two ? 1 : 0, int(round(avg * 100)), yaw * 1000 + pit);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rsqml_buttshove") ButtShove(e);
		else if (e.Name ~== "rsqml_fear") FearOpen(e.Player, e.Args[0]);
	}

	void ButtShove(ConsoleEvent e)
	{
		if (bdq || e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let pmo = players[e.Player].mo;
		if (!pmo || pmo.health <= 0) return;
		double yaw = e.Args[2] / 1000, pit = (e.Args[2] % 1000) - 90;
		Vector3 d = (cos(yaw) * cos(pit), sin(yaw) * cos(pit), sin(pit));
		// the hand (QuestZDoom writes it for the local player; anything else swings from the eyes)
		Vector3 a; bool ok;
		[a, ok] = RSQML_Hands.Pos(pmo, 0);
		if (!ok) a = (pmo.pos.x, pmo.pos.y, pmo.player.viewz);
		Vector3 b = a + d * BUTT_REACH;
		pmo.A_StartSound(RSQML.HasSound("Melee/SwingStrong") ? "Melee/SwingStrong" : "skeleton/swing", CHAN_WEAPON, CHANF_OVERLAP);

		// who is in the envelope: the segment hand -> reach, padded, checked every 4 units (melee.zs Sweep's steps)
		Vector3 c = (a + b) / 2;
		double r = BUTT_REACH / 2 + BUTT_PAD;
		int steps = int(BUTT_REACH / 4) + 1;
		Array<Actor> struck;
		let it = BlockThingsIterator.CreateFromPos(c.x, c.y, c.z - r, 2 * r, r, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || t == pmo || t.player || !t.bSHOOTABLE || t.bFRIENDLY || t.bDORMANT || t.health <= 0) continue;
			if (struck.Find(t) != struck.Size()) continue;
			for (int i = 0; i <= steps; i++)
			{
				Vector3 q = a + (b - a) * (i / double(steps));
				if (!Touches(t, q, BUTT_PAD)) continue;
				Vector3 at = (t.pos.x, t.pos.y, clamp(q.z, t.pos.z + 1, t.pos.z + max(t.height - 1, 1)));
				if (Clear(pmo, a, at)) struck.Push(t);
				break;
			}
		}

		int dmg = pmo.CountInv("PowerStrength") > 0 ? BUTT_DMG_ZERK : BUTT_DMG;
		int landed = 0;
		for (int i = 0; i < struck.Size(); i++)
		{
			Actor t = struck[i];
			if (!t || t.health <= 0) continue;
			bool bdPain = t.FindStateByString("Pain.Kick", true) != null;
			t.DamageMobj(pmo, pmo, dmg, 'Kick');
			landed++;
			if (t && !t.bDestroyed && t.health > 0 && !bdPain) Knock(pmo, t);
			if (Dbg() >= 1)
				Console.Printf("\c[Gold]rsqml: butt shove hit %s for %d%s, health %d, vel %.1f %.1f %.1f (t%d)", t.GetClassName(), dmg,
					bdPain ? " (its own Pain.Kick knocks it)" : "", t ? t.health : 0, t ? t.vel.x : 0, t ? t.vel.y : 0, t ? t.vel.z : 0, level.maptime);
		}
		if (landed > 0)
		{
			if (RSQML.HasSound("Kick/flesh") && struck[0] && !struck[0].bDestroyed) struck[0].A_StartSound("Kick/flesh", CHAN_AUTO);
			else pmo.A_StartSound("*fist", CHAN_AUTO);
			pmo.A_AlertMonsters(BUTT_ALERT);
			RSQ_Buzz.Start(pmo, 0, 0.6, 6);
			// SLOW-MO: from the shover's own machine only, so a netgame gets one event
			if (e.Player == consoleplayer) Pulse("our butt shove");
		}
		else if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: butt shove, %.2f m/s%s: nothing in reach (t%d)", e.Args[1] / 100.0, e.Args[0] ? " (two hands)" : "", level.maptime);
	}

	// SLOW-MO: RSQ SlowMo's own pulse door (its README "For other mods"); absent SlowMo hears nothing
	void Pulse(String why)
	{
		if (!Opt("rsqml_shove_slowmo", 1)) return;
		int ms = clamp(Opt("rsqml_shove_slowmo_ms", 300), 30, 2000);
		EventHandler.SendNetworkEvent("rsm_pulse", ms, PULSE_DEPTH);
		// the F.E.A.R. window opens with it (synced: every machine keeps the same window)
		EventHandler.SendNetworkEvent("rsqml_fear", int(ceil(ms * TICRATE / 1000.0)) + FEAR_CAP);
		if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: rsm_pulse %d ms at %d%% after %s (t%d)", ms, PULSE_DEPTH, why, level.maptime);
	}

	// Brutal Doom's Pain.Kick numbers (brutal22test6 actors/Enemies), on the vanilla monster each one replaces:
	// ThrustThing(angle + 180, back) after A_FaceTarget and ThrustThingZ(up x 4, added; the engine divides by 4,
	// p_lnspec.cpp LS_ThrustThingZ). Pinkies, cacodemons, revenants, mancubi, arachnotrons, archviles, pain elementals
	// and the bosses have no thrust there; they get the engine's kickback only.
	static void KnockOf(Actor t, out double back, out double up)
	{
		back = 0; up = 0;
		if (RSQML.Descends(t, 'ZombieMan') || RSQML.Descends(t, 'ShotgunGuy')) { back = 10; up = 30 / 4.; }   // Zombiemen.dec RifleZombie, Sergeants.dec ShotgunGuy1
		else if (RSQML.Descends(t, 'DoomImp')) { back = 5; up = 20 / 4.; }                                     // Imps.dec Imp
		else if (RSQML.Descends(t, 'Spectre')) up = 30 / 4.;                                                    // Spectre.dec Spectro
		else if (RSQML.Descends(t, 'HellKnight')) up = 5 / 4.;                                                  // Knight.dec HellKnight2 (before the Baron: it inherits from it)
		else if (RSQML.Descends(t, 'ChaingunGuy') || RSQML.Descends(t, 'BaronOfHell') || RSQML.Descends(t, 'WolfensteinSS')) up = 15 / 4.;   // Comando.dec, Baron.dec, BWSS.dec
	}
	static void Knock(PlayerPawn pmo, Actor t)
	{
		double back, up;
		KnockOf(t, back, up);
		if (back > 0) t.Thrust(back, pmo.AngleTo(t));
		if (up > 0) t.vel.z += up;
	}
	static bool Touches(Actor t, Vector3 q, double pad)
	{
		if (q.z < t.pos.z - pad || q.z > t.pos.z + t.height + pad) return false;
		double ddx = q.x - t.pos.x, ddy = q.y - t.pos.y, rr = t.radius + pad;
		return ddx * ddx + ddy * ddy <= rr * rr;
	}
	// nothing solid between the hand and that point (melee.zs Clear)
	static bool Clear(Actor mo, Vector3 from, Vector3 to)
	{
		Vector3 d = to - from;
		double len = d.Length();
		if (len < 1) return true;
		FLineTraceData tr;
		mo.LineTrace(VectorAngle(d.x, d.y), len, -asin(clamp(d.z / len, -1, 1)), TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, tr);
		return tr.HitType == TRACE_HitNone || tr.HitType == TRACE_HitActor;
	}

	// ---- SLOW-MO with BD22 VR Reloaded's own butt strike ------------------------------------------------------
	// Its strike can be possible only with its rsq_butt on and one of its long guns up (melee.zs KindOf:403-421). It
	// lands as BD22's KickAttack (SuperKickAttack under the Berserk), spawned at the body it struck and fired by you
	// (melee.zs Launch: a.target = you). Its gun bash is RSQ_BashAttack, a different class, so it is not counted. A
	// KickAttack of yours within RING tics of your main-hand shove = its butt strike.
	static bool BDButtPossible(PlayerPawn pmo)
	{
		let cb = CVar.FindCVar("rsq_butt");
		if (!cb || cb.GetInt() == 0) return false;
		let w = pmo.player ? pmo.player.ReadyWeapon : null;
		if (!w) return false;
		Name n = w.GetClassName();
		return n == 'Rifle' || n == 'Shot_Gun' || n == 'SSG' || n == 'AssaultShotgun' || n == 'MP40' || n == 'BrutalSMG'
			|| n == 'Machinegun' || n == 'MG42';
	}
	override void WorldThingSpawned(WorldEvent e)
	{
		if (!bdq || !e.Thing || !Opt("rsqml_shove_slowmo", 1)) return;
		Name n = e.Thing.GetClassName();
		if (n != 'KickAttack' && n != 'SuperKickAttack') return;
		// its target is set just after it spawns (melee.zs Launch), so it is looked at from the next tic
		bdKicks.Push(e.Thing);
		bdKickAt.Push(gametic);
	}
	void WatchBDButt()
	{
		let pmo = Me();
		for (int i = bdKicks.Size() - 1; i >= 0; i--)
		{
			Actor k = bdKicks[i];
			if (k && pmo && k.target == pmo) bdKickTic = bdKickAt[i];
			if (!k || k.target || gametic - bdKickAt[i] > 2) { bdKicks.Delete(i); bdKickAt.Delete(i); }
		}
		if (bdKickTic > 0 && bdShoveTic > 0 && abs(bdKickTic - bdShoveTic) <= RING)
		{
			if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: BD22 VR Reloaded's butt strike landed (KickAttack t%d, shove t%d)", bdKickTic, bdShoveTic);
			bdKickTic = 0; bdShoveTic = 0;
			Pulse("BD22 VR Reloaded's butt strike");
		}
		if (bdKickTic > 0 && gametic - bdKickTic > RING) bdKickTic = 0;
		if (bdShoveTic > 0 && gametic - bdShoveTic > RING) bdShoveTic = 0;
	}

	// ---- F.E.A.R. EFFECT (owner 2026-11-01: "Butt-shove, slow mo shotgun blasts will produce 2x gore during that window,
	// ensure rs Score recognizes that move and names it 'F.E.A.R. Effect'") ---------------------------------------
	// THE WINDOW is the slow motion the shove's pulse started: open from rsqml_fear (sent with the pulse), closed when
	// RSQ SlowMo says it is no longer slowing or easing ("slowmo.active", RSQSM_Service) after it was, or if it never
	// starts within FEAR_START tics (SlowMo absent, standing down, or its held toggle already on: no pulse, no window),
	// and never longer than the pulse plus FEAR_CAP tics.
	// SHOTGUN = Doom's Shotgun / SuperShotgun and anything inheriting or replacing them, and Brutal Doom's shotguns
	// (Shot_Gun, SSG, AssaultShotgun: brutal22test6 actors/Weapons), all by name at run time.
	const FEAR_CAP = 105;      // tics past the pulse's hold (3 s): the window can never stay open longer
	const FEAR_START = 4;      // tics for SlowMo to start slowing before the window gives up
	const FEAR_POINTS = 200;   // RSQ Score points: Grapple's Indiana Jones pays 150 + more for longer gaps
	const FEAR_LABEL = "F.E.A.R. Effect";
	const SHOW = 52;           // tics the award's name stays low in the view (1.5 s)

	void FearOpen(int pn, int tics)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return;
		fearPn = pn; fearFrom = gametic; fearTill = gametic + clamp(tics, 1, 175); fearSlow = false;
		fearPaid.Clear();
		if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: F.E.A.R. window opens (t%d)", level.maptime);
	}
	void FearClose(String why)
	{
		if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: F.E.A.R. window closes: %s (t%d)", why, level.maptime);
		fearPn = -1; fearPaid.Clear();
	}
	void FearTick()
	{
		if (gametic > fearTill) { FearClose("its cap"); return; }
		if (!svcSlowMo) svcSlowMo = RSQML.Svc("RSQSM_Service");
		int act = svcSlowMo ? svcSlowMo.GetInt("slowmo.active") : -1;
		if (act == 1) fearSlow = true;
		else if (fearSlow) FearClose("slow motion is over");
		else if (gametic - fearFrom > FEAR_START) FearClose("slow motion never started");
	}
	bool FearOn(Actor src) { return fearPn >= 0 && src && players[fearPn].mo == src && gametic <= fearTill; }

	static bool IsShotgun(Weapon w)
	{
		if (!w) return false;
		static const String names[] = { "Shotgun", "SuperShotgun", "Shot_Gun", "SSG", "AssaultShotgun" };
		class<Actor> rep = Actor.GetReplacee(w.GetClass());
		for (int i = 0; i < names.Size(); i++)
		{
			Name n = names[i];
			if (RSQML.Descends(w, n)) return true;
			for (class<Object> c = rep; c; c = c.GetParentClass()) if (c.GetClassName() == n) return true;
		}
		return false;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (fearPn < 0) return;
		let t = e.Thing;
		if (!t || !t.bIsMonster || e.Damage <= 0 || e.DamageType == 'Kick' || !FearOn(e.DamageSource)) return;
		let pmo = PlayerPawn(e.DamageSource);
		if (!pmo || !pmo.player || !IsShotgun(pmo.player.ReadyWeapon)) return;
		// 2x gore: the hit's own blood, once more
		if (!t.bNoBlood)
		{
			Vector3 at = t.pos + (0, 0, t.height * 0.5);
			if (e.Inflictor && e.Inflictor != pmo && t.Distance3D(e.Inflictor) < t.radius + t.height) at = e.Inflictor.pos;
			t.SpawnBlood(at, pmo.AngleTo(t) + 180, e.Damage);
			Actor bl = pmo;
			if (e.Inflictor && e.Inflictor != pmo) bl = e.Inflictor;
			t.TraceBleed(e.Damage, bl);
		}
		if (Dbg() >= 2) Console.Printf("\c[Gold]rsqml: F.E.A.R. hit %s for %d, health %d (t%d)", t.GetClassName(), e.Damage, t.health, level.maptime);
		if (t.health > 0 || fearPaid.Find(t) != fearPaid.Size()) return;
		fearPaid.Push(t);
		Service sc = RSQML.Svc("RS_ScoreService");
		int got = sc ? sc.GetInt("award", FEAR_LABEL, FEAR_POINTS, 0, pmo) : -1;
		if (fearPn == consoleplayer) { sayName = FEAR_LABEL; sayTic = gametic; }
		if (Dbg() >= 1) Console.Printf("\c[Gold]rsqml: F.E.A.R. Effect, %s killed by %s -> RSQ Score %d (t%d)", t.GetClassName(), pmo.player.ReadyWeapon.GetClassName(), got, level.maptime);
	}

	// the award's name, small, grey, half-transparent, low in the view, fading over its last half second
	override void RenderOverlay(RenderEvent e)
	{
		if (sayName == "") return;
		int age = gametic - sayTic;
		if (age < 0 || age >= SHOW) return;
		double a = 0.55 * min(1.0, (SHOW - age) / 18.0);
		double vw = 640, vh = 400;
		Screen.DrawText(SmallFont, Font.CR_GRAY, (vw - SmallFont.StringWidth(sayName)) / 2, vh * 0.72, sayName,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, a);
	}
}
