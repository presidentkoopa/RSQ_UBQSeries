// ============================================================================
// RSQ_Miniboss -- BOSSFIGHT (owner 2026-11-05): the miniboss is CALLED IN, never picked at level load (the old pick is
// "Classic Pick at Level Load" in Test and Debug, off).
//
//   THE METER  0..1000, kept on the player (RSQMB_Meter: it rides the save and the next map). It fills from
//              RSQ Score's style points (each kill's style bonuses and combos, read by name: RS_ScoreService
//              "kill.serial" / "kill.style": the most), kill chains (kills within 3 s), Gun Bonsai XP (RSQ Gun Bonsai
//              VR's RSQGB_Service "xp" on the hand's gun) and, slowly, time spent pushing into the map (2 points a
//              2 s in which you moved). Without RSQ Score each kill counts more (10 + spawn health / 50, at most 30).
//              x Meter Speed. Frozen while a Bossfight is arriving or alive.
//              FILLS FROM (owner 11-05: "GBOVR fills the miniboss meter? what about the Score? can we have option to toggle
//              one, the other, or both?"): rsqmb_bf_from 0 Score, 1 Gun Bonsai, 2 Both (default). Kills, chains and time
//              fill it in every setting, so it fills with neither mod. A choice whose mod is not loaded falls back to the
//              other one when that is loaded (Score chosen, no Score: Gun Bonsai XP fills it; and the other way), else to
//              kills and time alone (FillSources). A kill counts 4 while Score's style fills it, else the bigger plain value.
//   FULL       telegraphed: a sting (the IWAD's DSBOSPIT), the meter turning gold and alive (hud.zs; no words, owner 11-05), and RSQ Glow In The Dark's
//              map glow beating red (RSQGD_Service "event.tint", by name) while it waits.
//   CALL IT IN the watch check + Use (the watch check from RSQ Accessibility's RSQG_Service "inspect", else RSQ Gun Cards' copy
//              RSQGC_GCopyService, else this mod's own copy, gestcopy.zs): Use is read only while a watch check is
//              held (or let go WATCH_GRACE tics ago). Or it comes by itself rsqmb_bf_auto s after the meter filled.
//   GUARDRAILS it waits (and says why under the bar) while: the first rsqmb_bf_first s of a map; within
//              rsqmb_bf_exit of an exit line; rsqmb_bf_cooldown s after the last one; rsqmb_bf_cap a map reached; your
//              health under rsqmb_bf_minhp; more than rsqmb_bf_busy awake monsters after you within 1536; no spot.
//   THE SPOT   in view and at a distance (rsqmb_bf_near..rsqmb_bf_far, within 55 degrees of where you face), from the
//              map's own monster start spots and points along your view (the idea of Dynamic Enemy Reinforcements v3:
//              monster start spots are places a monster fits). Each is tested with a probe the size of the monster
//              that will stand there (its floor and ceiling, TestMobjLocation against walls and things), the miniboss's
//              spot must be in your sight (CheckSight), and its thralls must fit round it (at least half of them).
//   WHO        types already in this map (its own monsters' classes, as Brutal Doom / XMVE / LegenDoom left them),
//              sorted by spawn health. A tier 0..4 picks how strong, by Tier From (rsqmb_bf_tier_from, Tier()): the
//              default Whichever Is Larger of Gun Bonsai VR Level and Score Lives; Set adds Gun Bonsai player level / 2
//              + this map's RSQ Score / rsqmb_bf_tier_score + Bossfights won / 2. Tier 0 sends a middling type, tier 4
//              the strongest; thralls are weaker types (the same type when none is).
//   ARRIVAL    (reworked 2026-11-09, StartArrival below) STAGGERED: the thralls one at a time about 0.3 s apart, each on
//              an RSQ VisualRewards arrival beam (V1 or V2, the miniboss V3 or V4: a set picked at random per Bossfight) in its
//              ladder colour, held until its beam reveals it, RSQ SlowMo's edge arrows on each while out of view; then the
//              miniboss's entrance; all inside the landing's slow motion (RSQ SlowMo "start.bossfight", 4 s). Each arrives a
//              Boosted Legendary Champion (SlowMo DOWN's boost), the miniboss 1.25x with its hitbox, x1.25 speed and
//              MISSILEEVENMORE's attack chance. Without VisualRewards' beams: the original Minibosses!' teleport fog (fx.zs art)
//              and Doom's teleport sound. BIND_TICS after the last one landed (Champions has dressed them) they are bound
//              as a set piece (handler.zs Bind: segments, shield, lives, greed, colours, FX, Boss Kill Rewards, LegenDoom /
//              Champions inheritance; fight.zs runs the fight).
//   PAYOFF     its miniboss killed: a guaranteed drop (a gun from this map's weapon types you don't have, else a power-up),
//              RSQ VisualRewards' boss bits (it counts as a boss) and RSQ Score's "Bossfight" row (BfPayoff).
// Rig only, not headset-confirmed.
// ============================================================================

// ON THE PLAYER: the meter.
class RSQMB_Meter : RSQMB_Token
{
	double fill;           // 0..1000
	bool   ready;
	int    readyAt;        // level.maptime it filled (re-stamped on a new map)
	int    beaten;         // Bossfights won
	bool   called;         // the player called it in (this map)
	int    seenSerial;     // RSQ Score's kill serial read last
	int    chain, lastKill;
	double lastX, lastY;   // where you were at the last time sample
	int    gbLvl, gbXp, gbNext;
	Weapon gbGun;
	bool   prevUse;
	int    watchTic;       // level.maptime + 1 when a watch check was last held (this machine)
	int    scoreBase;      // RSQ Score's total when this map began (-1 unknown)
	int    mapStamp;       // the level it last saw (level.levelnum + 1)
}

// ON EVERY MONSTER A BOSSFIGHT BROUGHT (miniboss and thralls, dead or alive, for good): RSQMB_Service "bossfight".
class RSQMB_Called : RSQMB_Token {}

// The space test: the size of the monster asked about, never in the blockmap (nothing bumps it), never drawn.
class RSQMB_Probe : Actor
{
	Default
	{
		+SOLID
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTELEPORT
		+NOTONAUTOMAP
		+INVISIBLE
		Radius 20;
		Height 56;
	}
	States { Spawn: TNT1 A -1; Stop; }
}

extend class RSQMB_Handler
{
	const BIND_TICS = 6;          // the last one landed -> bound (Champions dresses a new monster within 3 tics)
	const WATCH_GRACE = 8;        // tics after the watch check lets go that Use still calls it in
	const CHAIN_TICS = 105;       // kills within 3 s chain
	const HEART = 45;             // the glow's heartbeat period while full

	// ---- what the map holds (scanned once at SELECT_AT; in the save) ----------------------------------------------
	bool   bfScanned;
	Array<String> rosterCls;      // distinct monster types, weakest first
	Array<int>    rosterHP;
	Array<double> spX, spY, spZ;  // monster start spots (at most 400)
	Array<double> exX, exY;       // exit lines' middles
	Array<String> mapWeapons;     // weapon types lying in the map

	// ---- the Bossfight now (in the save) ----------------------------------------------------------------------------
	int    bfCount;               // Bossfights this map
	int    bfLastTic;             // the last one ended (or began) at
	bool   bfAny;                 // one has run this map (the cooldown applies)
	RSQMB_Boss bfBoss;            // the called set piece alive now
	int    arrPhase;              // 0 none, 1 landing (StartArrival .. Bind)
	bool   arrQuiet;              // a landing failed and is being retried: its slow, dark and music already played (owner 11-10: once)
	int    arrTic, arrPn, arrTier;
	Array<double> arrX, arrY, arrZ;
	Array<String> arrCls;
	Array<Actor>  arrMon;         // [0] the miniboss, then the thralls (null until landed)
	Array<int>    arrAt;          // tics after arrTic each one lands
	Array<int>    arrState;       // 0 waiting, 1 landed and held, 2 revealed, 3 did not land (ArrivalStep)
	Array<int>    arrReveal;      // the tic its beam reveals it
	Array<int>    arrCol;         // its colour, 0xRRGGBB (its ladder colour, else the set piece's palette)
	Array<int>    arrTics;        // its state's tics when it was held (put back at the reveal)
	Array<int>    arrBorn;        // the tic it landed
	int    arrBeamSet;            // 0: V1 thralls + V3 miniboss, 1: V2 thralls + V4 miniboss (owner 11:20, random per Bossfight)
	Actor  arrProbe;              // the arrival's sound source
	bool   arrForce;              // Ignore Spawn Restrictions set this one down untested: the landing keeps what lands

	// ---- for the HUD (transient) -------------------------------------------------------------------------------------
	transient String bfWhy;       // why a due Bossfight waits, the HUD's line ("No Miniboss: Low Health"; "" none)
	transient int bfNextTry;
	transient Service gdSvc, gbService;
	transient bool gdChecked;

	static clearscope bool BfOn() { return CI('rsqmb_enabled', 1) != 0; }

	// ---- the scan ---------------------------------------------------------------------------------------------------
	void BfScan()
	{
		bfScanned = true;
		rosterCls.Clear(); rosterHP.Clear(); spX.Clear(); spY.Clear(); spZ.Clear(); exX.Clear(); exY.Clear(); mapWeapons.Clear();
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			let w = Weapon(a);
			if (w)
			{
				if (!w.Owner && mapWeapons.Find(w.GetClassName()) == mapWeapons.Size()) mapWeapons.Push(w.GetClassName());
				continue;
			}
			if (!Eligible(a) || a.bBOSS || Has(a, "champion_DarkRedToken") || Has(a, "champion_UndyingToken")) continue;
			if (a.Speed <= 0 && !a.MissileState && !a.MeleeState) continue;
			if (spX.Size() < 400) { spX.Push(a.pos.x); spY.Push(a.pos.y); spZ.Push(a.pos.z); }
			String cn = a.GetClassName();
			if (rosterCls.Find(cn) < rosterCls.Size()) continue;
			int hp = GetDefaultByType(a.GetClass()).health;
			int k = rosterCls.Size();
			rosterCls.Push(cn); rosterHP.Push(hp);
			while (k > 0 && rosterHP[k - 1] > hp) { rosterCls[k] = rosterCls[k - 1]; rosterHP[k] = rosterHP[k - 1]; k--; }
			rosterCls[k] = cn; rosterHP[k] = hp;
		}
		for (int i = 0; i < level.lines.Size(); i++)
		{
			let l = level.lines[i];
			if (l.special != 243 && l.special != 244 && l.special != 74) continue;   // Exit_Normal, Exit_Secret, Teleport_NewMap
			exX.Push((l.v1.p.x + l.v2.p.x) * 0.5); exY.Push((l.v1.p.y + l.v2.p.y) * 0.5);
		}
		if (debug)
		{
			String r = "";
			for (int i = 0; i < rosterCls.Size(); i++) r = r .. (i ? ", " : "") .. rosterCls[i] .. " " .. rosterHP[i];
			Console.Printf("RSQMB bossfight scan: %d types [%s], %d spots, %d exits, %d weapon types", rosterCls.Size(), r, spX.Size(), exX.Size(), mapWeapons.Size());
		}
	}

	// ---- the meter --------------------------------------------------------------------------------------------------
	static RSQMB_Meter MeterOf(Actor p, bool make = false)
	{
		if (!p || !p.player) return null;
		let m = RSQMB_Meter(p.FindInventory("RSQMB_Meter"));
		if (!m && make)
		{
			m = RSQMB_Meter(p.GiveInventoryType("RSQMB_Meter"));
			if (m) { m.scoreBase = -1; m.lastX = p.pos.x; m.lastY = p.pos.y; }
		}
		return m;
	}

	bool BfBusy() { return arrPhase != 0 || (bfBoss && !bfBoss.done); }

	void Fill(RSQMB_Meter m, double pts, String why)
	{
		if (!m || m.ready || pts <= 0 || BfBusy() || !BfOn()) return;
		double sp = clamp(CF('rsqmb_bf_speed', 1.0), 0.0, 8.0);
		m.fill = min(1000.0, m.fill + pts * sp);
		if (debug) Console.Printf("RSQMB meter +%.1f (%s) -> %.0f", pts * sp, why, m.fill);
		if (m.fill >= 1000.0) Ready(m);
	}

	void Ready(RSQMB_Meter m)
	{
		m.ready = true;
		m.readyAt = level.maptime;
		m.called = false;
		let p = m.Owner;
		if (p && p.PlayerNumber() == consoleplayer) p.A_StartSound("brain/spit", CHAN_AUTO, CHANF_UI | CHANF_LOCAL, 1.0, ATTN_NONE);
		Glow(0xFF2010, 0.6);
		if (debug) Console.Printf("RSQMB BOSSFIGHT READY (auto in %d s)", CI('rsqmb_bf_auto', 60));
	}

	Service GdService()
	{
		if (!gdChecked)
		{
			gdChecked = true;
			let it = ServiceIterator.Find("RSQGD_Service");
			Service s;
			while (s = it.Next()) if (s.GetClassName() == 'RSQGD_Service') { gdSvc = s; break; }
		}
		return gdSvc;
	}
	void Glow(int col, double secs)
	{
		let g = GdService();
		if (g) g.GetInt("event.tint", "", col, secs);
	}

	// WHAT FILLS THE METER besides kills, chains and time (rsqmb_bf_from: 0 Score, 1 Gun Bonsai, 2 Both): RSQ Score's style
	// points, Gun Bonsai XP (RSQ Gun Bonsai VR), each only when its mod answers by name. A choice whose mod is absent falls
	// back to the other when that one is loaded. The debug log says the sources whenever they change.
	transient int fillSaid;
	bool, bool FillSources()
	{
		if (!svcChecked) FindServices();
		int pick = CI('rsqmb_bf_from', 2);
		bool sc = scoreSvc != null, gb = GbSvc() != null;
		bool useScore = sc && (pick != 1 || !gb);
		bool useGb = gb && (pick != 0 || !sc);
		int said = 1 + pick * 4 + (useScore ? 1 : 0) * 16 + (useGb ? 1 : 0) * 32;
		if (debug && said != fillSaid)
			Console.Printf("RSQMB meter fills from: kills, chains, time%s%s (chosen %s; Score %s, Gun Bonsai VR %s)",
				useScore ? ", Score style" : "", useGb ? ", Gun Bonsai XP" : "",
				pick == 0 ? "Score" : (pick == 1 ? "Gun Bonsai" : "Both"), sc ? "loaded" : "absent", gb ? "loaded" : "absent");
		fillSaid = said;
		return useScore, useGb;
	}

	Service GbSvc()
	{
		if (!gbService) { let it = ServiceIterator.Find("RSQGB_Service"); gbService = it.Next(); }
		return gbService;
	}

	// A monster died: the kill and the chain (never a Bossfight's own monsters, never while one runs).
	void BfKill(Actor victim, Actor killer)
	{
		if (!BfOn() || !killer || !killer.player || !victim || victim.player || !victim.bISMONSTER || !victim.bCOUNTKILL) return;
		if (victim.FindInventory("RSQMB_Called") || BfBusy()) return;
		let m = MeterOf(killer, true);
		if (!m || m.ready) return;
		if (!svcChecked) FindServices();
		int now = level.maptime;
		m.chain = (now - m.lastKill <= CHAIN_TICS) ? m.chain + 1 : 1;
		m.lastKill = now;
		bool useScore, useGb;
		[useScore, useGb] = FillSources();
		double pts = useScore ? 4 : min(30.0, 10 + victim.SpawnHealth() / 50.0);
		if (m.chain > 1) pts += min(30, 6 * (m.chain - 1));
		Fill(m, pts, m.chain > 1 ? String.Format("kill, chain %d", m.chain) : "kill");
	}

	// Every tic: Score's style, Gun Bonsai XP, time, the telegraph, the call-in, the arrival.
	void BfTick()
	{
		if (!bfScanned) return;
		if (!svcChecked) FindServices();
		int now = level.maptime;
		bool on = BfOn();
		bool useScore, useGb;
		[useScore, useGb] = FillSources();
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let p = players[pn].mo;
			let m = MeterOf(p, on);
			if (!m) continue;
			if (m.mapStamp != level.levelnum + 1)
			{
				// a new map: the wait for auto-arrival starts again, nothing called yet, this map's score from here
				m.mapStamp = level.levelnum + 1;
				m.readyAt = now; m.called = false; m.scoreBase = -1; m.seenSerial = 0; m.chain = 0; m.lastKill = -1000;
				m.lastX = p.pos.x; m.lastY = p.pos.y; m.gbGun = null;
			}
			if (!on) continue;
			if (scoreSvc && m.scoreBase < 0) m.scoreBase = scoreSvc.GetInt("score", "", 0, 0, p);
			// RSQ Score's style points, kill by kill (when Score is a fill source, FillSources)
			if (useScore)
			{
				int serial = scoreSvc.GetInt("kill.serial", "", pn);
				if (serial >= 0)
				{
					if (serial < m.seenSerial) m.seenSerial = 0;
					for (int k = max(m.seenSerial + 1, serial - 15); k <= serial; k++)
					{
						int style = scoreSvc.GetInt("kill.style", "", pn, k);
						let vic = Actor(scoreSvc.GetObject("kill.victim", "", pn, k));
						if (vic && vic.FindInventory("RSQMB_Called")) continue;     // a Bossfight's own monsters never fill it
						if (style > 0) Fill(m, min(120.0, style * clamp(CF('rsqmb_bf_style', 0.25), 0.0, 4.0)), String.Format("Score style %d", style));
					}
					m.seenSerial = serial;
				}
			}
			// (not a source now: keep the place, so switching it back on never counts what came meanwhile)
			else if (scoreSvc) { int ser = scoreSvc.GetInt("kill.serial", "", pn); if (ser >= 0) m.seenSerial = ser; }
			// Gun Bonsai XP on the main hand's gun, every 8 tics (not a source now: start afresh when it is again)
			if ((now + pn) % 8 == 0 && useGb) GbStep(p, m);
			else if (!useGb) m.gbGun = null;
			// pushing into the map: every 2 s you moved
			if ((now + pn) % 70 == 0)
			{
				double dx = p.pos.x - m.lastX, dy = p.pos.y - m.lastY;
				m.lastX = p.pos.x; m.lastY = p.pos.y;
				if (dx * dx + dy * dy >= 96.0 * 96.0) Fill(m, 2, "time");
			}
			if (pn == consoleplayer) WristCard(p, m);
			if (!m.ready) continue;
			// the telegraph: the glow's heartbeat (lub-dub) while it waits
			if (!BfBusy())
			{
				int ph = (now - m.readyAt) % HEART;
				if (ph == 0) HeartBeat(0xFF1810, 0.25);
				else if (ph == 9) HeartBeat(0xC01008, 0.2);
			}
			if (pn == consoleplayer && !m.called && CI('rsqmb_bf_callin', 1)) CallInput(p, m);
		}
		if (!on) { bfWhy = ""; return; }
		if (arrPhase) { ArrivalStep(); return; }
		if (bfBoss && bfBoss.done) bfBoss = null;
		// a due Bossfight: called, or the meter full long enough
		bool anyDue = false;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let m = MeterOf(players[pn].mo);
			if (!m || !m.ready) continue;
			int autoS = CI('rsqmb_bf_auto', 60);
			bool due = m.called || (autoS > 0 && now - m.readyAt >= autoS * TICRATE);
			if (!due) continue;
			anyDue = true;
			if (now >= bfNextTry) { bfNextTry = now + 10; TryArrive(players[pn].mo, m); }
			break;
		}
		if (!anyDue) bfWhy = "";
	}

	void GbStep(PlayerPawn p, RSQMB_Meter m)
	{
		let w = p.player.ReadyWeapon;
		int lv = gbService.GetInt("level", "", 0, 0, p), xp = gbService.GetInt("xp", "", 0, 0, p), nx = gbService.GetInt("xp.next", "", 0, 0, p);
		if (lv < 0 || xp < 0) { m.gbGun = null; return; }
		if (w == m.gbGun)
		{
			int d = 0;
			if (lv == m.gbLvl) d = xp - m.gbXp;
			else if (lv > m.gbLvl) d = max(0, m.gbNext - m.gbXp) + xp;
			if (d > 0) Fill(m, min(40.0, d * clamp(CF('rsqmb_bf_xp', 0.2), 0.0, 4.0)), String.Format("Gun Bonsai XP %d", d));
		}
		m.gbGun = w; m.gbLvl = lv; m.gbXp = xp; m.gbNext = nx;
	}

	// ---- the call-in: the watch check + Use (this machine's hands) ----------------------------------------------------
	static int WatchCheck(PlayerPawn pmo, int h)
	{
		let it = ServiceIterator.Find("RSQG_Service");
		Service s;
		while (s = it.Next()) return s.GetInt("inspect", "", h, 0, pmo);
		// no RSQ Accessibility: RSQ Gun Cards' copy, then our own (-1 from either: it stands down, ask the next)
		it = ServiceIterator.Find("RSQGC_GCopyService");
		while (s = it.Next()) { int g = s.GetInt("inspect", "", h, 0, pmo); if (g >= 0) return g; }
		let own = RSQMB_GCopy.Get();
		return own ? own.Inspect(pmo.PlayerNumber(), h) : -1;
	}

	void CallInput(PlayerPawn p, RSQMB_Meter m)
	{
		int now = level.maptime;
		int w0 = WatchCheck(p, 0), w1 = WatchCheck(p, 1);
		if (w0 == 2 || w1 == 2) m.watchTic = now + 1;
		if (debug && now % 35 == 0) { Vector3 bd = RSQMB_GPose.Body(p, 0); Console.Printf("RSQMB watch check: main %d off %d (main hand body %.2f %.2f %.2f roll %.0f pitch %.0f)", w0, w1, bd.x, bd.y, bd.z, RSQMB_GPose.Roll(p, 0), RSQMB_GPose.Pitch(p, 0)); }
		bool use = (p.player.cmd.buttons & BT_USE) != 0;
		bool edge = use && !m.prevUse;
		m.prevUse = use;
		if (debug && edge) Console.Printf("RSQMB call-in: Use pressed t%d, a check held %d tics ago (grace %d)", now, m.watchTic > 0 ? now + 1 - m.watchTic : -1, WATCH_GRACE);
		if (edge && m.watchTic > 0 && now + 1 - m.watchTic <= WATCH_GRACE)
		{
			EventHandler.SendNetworkEvent("rsqmb_callin");
			m.watchTic = 0;
		}
	}

	// ---- THE INNER-WRIST CARD (owner 2026-11-12 05:06: "We need an mainhand / offhand inner watch card (inside of wrist)
	// that was Start (icon) Fight? So when we offhand inner wrist check we can Use to call in miniboss fight. current call
	// in method does not work. And the icon will be our Miniboss icon, for now") ---------------------------------------
	// Turn the INSIDE of either wrist to your face and look at it: a card stands over it, START (the crowned skull)
	// FIGHT? in gold while a Bossfight is ready to call, FIGHT (skull) NOT READY in grey while the meter is still filling
	// or it is already called. With the gold card up, Use calls the Bossfight in (the same call as the watch check + Use,
	// which stays). The pose: the inner wrist's face within 60 degrees of square to your eyes (the back-of-wrist watch
	// check turned over: RSQ Gun Cards' FaceDot, negated), the wrist within 45 degrees of your gaze, held WC_HOLD tics.
	// One textured quad in the world (a VisualThinker, as the set pieces' effects), this machine only. Inner-Wrist Card
	// (rsqmb_wristcard, user, on). Rig only for the pose and the card; not headset-confirmed.
	const WC_HOLD = 4;
	const WC_WIDE = 6.0;        // the card's width, map units (about 18 cm)
	transient RSQMB_Fx wcQuad;
	transient int wcHold[2];
	transient double wcAlpha;
	transient int wcHand;
	static double InnerDot(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir || !pmo.player) return -1;
		double y = ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
		double p = (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		Vector3 f = (cos(p) * cos(y), cos(p) * sin(y), sin(p));
		Vector3 r0 = (sin(y), -cos(y), 0);
		Vector3 u0 = r0 cross f;
		double rl = Actor.Normalize180(hand == 1 ? pmo.OffhandRoll : pmo.AttackRoll);
		double b = RSQMB_GPose.IsLeft(hand) ? rl : -rl;
		Vector3 n = -(r0 * cos(b) + u0 * sin(b));
		Vector3 to = (pmo.pos.xy, pmo.player.viewz) - ((hand == 1) ? pmo.OffhandPos : pmo.AttackPos);
		to.z *= level.pixelstretch;
		double d = to.Length();
		return d > 0.01 ? (n dot to) / d : -1;
	}
	static double GazeOff(PlayerPawn pmo, int hand)
	{
		Vector3 to = ((hand == 1) ? pmo.OffhandPos : pmo.AttackPos) - (pmo.pos.xy, pmo.player.viewz);
		to.z *= level.pixelstretch;
		double d = to.Length();
		if (d < 0.01) return 0;
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		return acos(clamp((to / d) dot look, -1.0, 1.0));
	}
	void WristCard(PlayerPawn p, RSQMB_Meter m)
	{
		let wc = CVar.GetCVar('rsqmb_wristcard', p.player);
		bool want = (!wc || wc.GetBool()) && BfOn() && p.health > 0;
		int shown = -1;
		for (int h = 1; h >= 0; h--)
		{
			bool pose = want && InnerDot(p, h) >= 0.5 && GazeOff(p, h) <= 45.0;
			wcHold[h] = pose ? min(wcHold[h] + 1, 100) : 0;
			if (wcHold[h] >= WC_HOLD) shown = h;
		}
		if (debug && level.maptime % 35 == 0)
			Console.Printf("RSQMB wrist card: inner wrist main %.2f off %.2f, gaze %.0f / %.0f degrees, held %d / %d, meter %s", InnerDot(p, 0), InnerDot(p, 1), GazeOff(p, 0), GazeOff(p, 1), wcHold[0], wcHold[1], m.called ? "called" : (m.ready ? "READY" : String.Format("%d%%", int(m.fill / 10))));
		if (shown >= 0) wcHand = shown;
		wcAlpha = clamp(wcAlpha + (shown >= 0 ? 0.25 : -0.25), 0.0, 1.0);
		bool gold = m.ready && !m.called;
		if (wcAlpha <= 0) { if (wcQuad) wcQuad.Alpha = 0; return; }
		TextureID tx = TexMan.CheckForTexture(gold ? "RSQMBWC1" : "RSQMBWC0", TexMan.Type_Any);
		if (!tx.IsValid()) return;
		int tw, th; [tw, th] = TexMan.GetSize(tx);
		Vector3 hp = wcHand == 1 ? p.OffhandPos : p.AttackPos;
		Vector3 eye = (p.pos.xy, p.player.viewz);
		Vector3 to = eye - hp;
		double d = to.Length();
		Vector3 at = hp + (d > 0.01 ? to / d : (0, 0, 1)) * 3.0 + (0, 0, 4.0);     // just off the wrist toward your eyes, above it
		double sc = WC_WIDE / max(1, tw);
		if (!wcQuad)
		{
			wcQuad = RSQMB_Fx(VisualThinker.Spawn("RSQMB_Fx", tx, at, (0, 0, 0), 0, SPF_FULLBRIGHT, 0, (sc, sc), (0, 0), STYLE_Translucent));
			if (!wcQuad) return;
			wcQuad.ChangeStatNum(RSQMB_Fx.STAT_FX);
			wcQuad.key = -2;
			wcQuad.Put(at, at);
		}
		if (wcQuad.Texture != tx) wcQuad.Texture = tx;
		wcQuad.SetRenderStyle(STYLE_Translucent);
		wcQuad.Scale = (sc, sc);
		wcQuad.Alpha = wcAlpha;
		wcQuad.Put(at, wcQuad.Pos);
		// the gold card up: Use calls it in (CallInput reads watchTic, below in the same tic)
		if (gold && shown >= 0) m.watchTic = level.maptime + 1;
	}

	void CallIn(int pn)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return;
		let m = MeterOf(players[pn].mo);
		if (!m || !m.ready || m.called) return;
		m.called = true;
		bfNextTry = 0;
		players[pn].mo.A_StartSound("misc/chat", CHAN_AUTO, CHANF_UI | CHANF_LOCAL, 0.8, ATTN_NONE);
		if (debug) Console.Printf("RSQMB BOSSFIGHT CALLED IN (watch check + Use) by player %d", pn);
	}

	// ---- the guardrails, then the spot ---------------------------------------------------------------------------------
	// Each reason is the line the HUD shows under the meter while a due Bossfight waits, in the owner's words (11-05: "below
	// it we can say No Miniboss: Low Health / No Room"): No Monsters (none on the roster), Too Early (the first minute),
	// Map Limit (the map's cap), Cooldown, Low Health, Near Exit, Too Busy (a heavy fight), No Room (no spot in view).
	void TryArrive(PlayerPawn p, RSQMB_Meter m)
	{
		String why = Guard(p);
		if (why == "")
		{
			int tier = Tier(p, m);
			if (!PlanArrival(p, tier)) why = "No Miniboss: No Room";
			else { StartArrival(p, m, tier); return; }
		}
		if (arrQuiet) { arrQuiet = false; SceneMusic(false); }   // a failed landing that can't retry now: the level music comes back
		if (debug && why != bfWhy) Console.Printf("RSQMB bossfight waits: %s", why);
		bfWhy = why;
	}

	// IGNORE SPAWN RESTRICTIONS (owner 2026-11-06, rsqmb_bf_ignore, off): a due Bossfight comes regardless of the guardrails on
	// WHEN and WHERE it may land: Too Early (the map's first rsqmb_bf_first s), Low Health (under rsqmb_bf_minhp), Near Exit
	// (within rsqmb_bf_exit of an exit line), Too Busy (more than rsqmb_bf_busy awake monsters after you) and No Room (the spot:
	// PlanArrival takes the first candidate spot in front of you without the room, sight and thrall-room tests when none passes
	// them). Left as they are: No Monsters (nothing to send), and Map Limit (rsqmb_bf_cap) and Cooldown (rsqmb_bf_cooldown):
	// those limit HOW OFTEN one comes, not where or when it may spawn, and keep their own rows.
	static bool IgnoreRestrictions() { return CI('rsqmb_bf_ignore', 0) != 0; }
	String Guard(PlayerPawn p)
	{
		int now = level.maptime;
		if (rosterCls.Size() == 0) return "No Miniboss: No Monsters";
		bool ign = IgnoreRestrictions();
		if (!ign && now < CI('rsqmb_bf_first', 60) * TICRATE) return "No Miniboss: Too Early";
		if (bfCount >= CI('rsqmb_bf_cap', 2)) return "No Miniboss: Map Limit";
		if (bfAny && now - bfLastTic < CI('rsqmb_bf_cooldown', 90) * TICRATE) return "No Miniboss: Cooldown";
		if (ign)
		{
			if (debug) Console.Printf("RSQMB bossfight guardrails ignored (Ignore Spawn Restrictions): would have waited for: %s", Waits(p));
			return "";
		}
		if (p.health < CI('rsqmb_bf_minhp', 40)) return "No Miniboss: Low Health";
		double ex = CF('rsqmb_bf_exit', 768);
		for (int i = 0; i < exX.Size(); i++)
		{
			double dx = exX[i] - p.pos.x, dy = exY[i] - p.pos.y;
			if (dx * dx + dy * dy < ex * ex) return "No Miniboss: Near Exit";
		}
		int busy = 0, lim = CI('rsqmb_bf_busy', 3);
		let bi = BlockThingsIterator.Create(p, 1536);
		while (bi.Next())
		{
			let a = bi.thing;
			if (a && a.bISMONSTER && !a.bFRIENDLY && a.health > 0 && a.target == p && !a.bCORPSE && a.Distance2D(p) < 1536) busy++;
		}
		if (busy > lim) return "No Miniboss: Too Busy";
		return "";
	}
	// (for the debug log) which of the ignored guardrails would have held it: Too Early, Low Health, Near Exit, Too Busy
	String Waits(PlayerPawn p)
	{
		String w = "";
		if (level.maptime < CI('rsqmb_bf_first', 60) * TICRATE) w = w .. " Too Early";
		if (p.health < CI('rsqmb_bf_minhp', 40)) w = w .. " Low Health";
		double ex = CF('rsqmb_bf_exit', 768);
		for (int i = 0; i < exX.Size(); i++)
		{
			double dx = exX[i] - p.pos.x, dy = exY[i] - p.pos.y;
			if (dx * dx + dy * dy < ex * ex) { w = w .. " Near Exit"; break; }
		}
		int busy = 0;
		let bi = BlockThingsIterator.Create(p, 1536);
		while (bi.Next())
		{
			let a = bi.thing;
			if (a && a.bISMONSTER && !a.bFRIENDLY && a.health > 0 && a.target == p && !a.bCORPSE && a.Distance2D(p) < 1536) busy++;
		}
		if (busy > CI('rsqmb_bf_busy', 3)) w = w .. " Too Busy";
		return w == "" ? " nothing" : w;
	}

	// WHAT SETS THE TIER (owner 2026-11-06, rsqmb_bf_tier_from; his ask: "consider GBOVR player level or RS Score lives
	// remaining, whichever is larger"): 0 Set (the sum below, as it was), 1 Gun Bonsai VR Level (RSQGB_Service "player.level"),
	// 2 Score Lives (RS_ScoreService "lives", the extra lives held), 3 Whichever Is Larger (the default) of those two. Each
	// source is asked by name; a mod not loaded (or no record yet) counts 0. The number IS the tier, 0..4 (a level or a life
	// count past 4 is tier 4).
	int Tier(PlayerPawn p, RSQMB_Meter m)
	{
		int from = clamp(CI('rsqmb_bf_tier_from', 3), 0, 3);
		if (from > 0)
		{
			if (!svcChecked) FindServices();
			int gl = GbSvc() ? max(0, gbService.GetInt("player.level", "", 0, 0, p)) : 0;
			int lv = scoreSvc ? max(0, scoreSvc.GetInt("lives", "", 0, 0, p)) : 0;
			int v = from == 1 ? gl : (from == 2 ? lv : max(gl, lv));
			int tt = clamp(v, 0, 4);
			if (debug) Console.Printf("RSQMB bossfight tier %d from %s (Gun Bonsai VR level %d%s, Score lives %d%s)", tt,
				from == 1 ? "Gun Bonsai VR Level" : (from == 2 ? "Score Lives" : "Whichever Is Larger"),
				gl, GbSvc() ? "" : " (not loaded)", lv, scoreSvc ? "" : " (not loaded)");
			return tt;
		}
		int t = 0;
		int gl = GbSvc() ? gbService.GetInt("player.level", "", 0, 0, p) : -1;
		if (gl > 0) t += gl / 2;
		if (!svcChecked) FindServices();
		if (scoreSvc && m.scoreBase >= 0)
		{
			int sc = scoreSvc.GetInt("score", "", 0, 0, p);
			int per = max(100, CI('rsqmb_bf_tier_score', 4000));
			if (sc > m.scoreBase) t += (sc - m.scoreBase) / per;
		}
		t += m.beaten / 2;
		t = clamp(t, 0, 4);
		if (debug) Console.Printf("RSQMB bossfight tier %d (Gun Bonsai level %d, map score %d, won %d)", t, gl,
			(scoreSvc && m.scoreBase >= 0) ? scoreSvc.GetInt("score", "", 0, 0, p) - m.scoreBase : -1, m.beaten);
		return t;
	}

	// Who: the miniboss type by tier, the thralls weaker types.
	class<Actor> RosterAt(int i) { class<Actor> c = rosterCls[clamp(i, 0, rosterCls.Size() - 1)]; return c; }

	bool PlanArrival(PlayerPawn p, int tier)
	{
		int n = rosterCls.Size();
		int bi = int(round((n - 1) * clamp(0.5 + 0.125 * tier, 0.0, 1.0)));
		if (tier < 4 && bi > 0 && random[rsqmbbf](0, 2) == 0) bi--;
		class<Actor> bc = RosterAt(bi);
		if (!bc) return false;
		int want = clamp(CI('rsqmb_thralls', 3) + (tier >= 3 ? 1 : 0), 1, 8);
		Array<String> tc;
		int lo = int(bi * max(0.0, 0.25 + 0.1 * tier));
		for (int i = 0; i < want; i++) tc.Push(rosterCls[bi > 0 ? random[rsqmbbf](min(lo, bi - 1), bi - 1) : 0]);
		bc = ApplyFrom(bc, tc, p);   // RSQ Monsters > Bossfight: Miniboss From / Thralls From (fight.zs)
		if (!bc) return false;

		let pr = RSQMB_Probe(Actor.Spawn("RSQMB_Probe", p.pos));
		if (!pr) return false;
		double near = CF('rsqmb_bf_near', 384), far = max(near + 64, CF('rsqmb_bf_far', 1024));
		// candidates: the map's monster start spots in front of you at that distance, then points along your view
		Array<double> cx, cy, cz;
		for (int i = 0; i < spX.Size(); i++)
		{
			Vector2 d = level.Vec2Diff(p.pos.xy, (spX[i], spY[i]));
			double l = d.Length();
			if (l < near || l > far || abs(Actor.DeltaAngle(p.angle, VectorAngle(d.x, d.y))) > 55) continue;
			cx.Push(spX[i]); cy.Push(spY[i]); cz.Push(spZ[i]);
		}
		static const double RAYS[] = { 0, -18, 18, -36, 36, -50, 50 };
		for (int r = 0; r < RAYS.Size(); r++)
		{
			FLineTraceData lt;
			double ang = p.angle + RAYS[r];
			p.LineTrace(ang, far + 64, 0, TRF_THRUACTORS, p.height * 0.5, data: lt);
			double reach = min(far, lt.Distance - 48);
			for (int k = 0; k < 3; k++)
			{
				double d = reach - k * (reach - near) / 3.0;
				if (d < near) break;
				Vector2 at = p.pos.xy + (cos(ang), sin(ang)) * d;
				cx.Push(at.x); cy.Push(at.y); cz.Push(p.pos.z);
			}
		}
		bool ok = false;
		int tries = 0, nc = cx.Size();
		int start = nc > 0 ? random[rsqmbbf](0, nc - 1) : 0;
		for (int j = 0; j < nc && tries < 24 && !ok; j++)
		{
			int i = (start + j) % nc;
			tries++;
			if (!Fits(pr, bc, cx[i], cy[i], cz[i], MB_SCALE)) continue;
			double bz = pr.pos.z;
			if (!p.CheckSight(pr, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			arrX.Clear(); arrY.Clear(); arrZ.Clear(); arrCls.Clear();
			arrX.Push(cx[i]); arrY.Push(cy[i]); arrZ.Push(bz); arrCls.Push(bc.GetClassName());
			double br = GetDefaultByType(bc).radius * MB_SCALE;
			double base = VectorAngle(p.pos.x - cx[i], p.pos.y - cy[i]);
			for (int t = 0; t < tc.Size(); t++)
			{
				class<Actor> c = tc[t];
				if (!c) continue;
				double tr = GetDefaultByType(c).radius;
				double r1 = br + tr + 16, r2 = r1 + tr * 2 + 24;
				for (int k = 0; k < 16; k++)
				{
					double ring = k < 8 ? r1 : r2;
					double a = base + 90 + (k % 8) * 45 + (k >= 8 ? 22.5 : 0);
					double x = cx[i] + cos(a) * ring, y = cy[i] + sin(a) * ring;
					bool clash = false;
					for (int q = 1; q < arrX.Size(); q++)
					{
						double dx = arrX[q] - x, dy = arrY[q] - y;
						class<Actor> qc = arrCls[q];
						double rr = tr + GetDefaultByType(qc).radius + 4;
						if (dx * dx + dy * dy < rr * rr) { clash = true; break; }
					}
					if (clash || !Fits(pr, c, x, y, bz) || abs(pr.pos.z - bz) > 48) continue;
					arrX.Push(x); arrY.Push(y); arrZ.Push(pr.pos.z); arrCls.Push(c.GetClassName());
					break;
				}
			}
			if (arrX.Size() - 1 >= max(1, (tc.Size() + 1) / 2)) ok = true;
		}
		// IGNORE SPAWN RESTRICTIONS (Guard above): no candidate passed the room, sight and thrall-room tests. In turn:
		//   1  the same candidates (in front, at the set distance) without the sight test, with as many thralls as fit (1+)
		//   2  anywhere: the map's monster start spots, nearest first (128+ units away), then rings round you (384, 256, 160),
		//      the miniboss and 1+ thralls still where they fit
		//   3  the first candidate of 1 or 2 untested: the miniboss and thralls set down there whether they fit or not (the
		//      landing then keeps them: arrForce)
		arrForce = false;
		if (!ok && IgnoreRestrictions())
		{
			ok = LooseSpot(pr, p, bc, tc, cx, cy, cz);
			Array<double> ax, ay, az;
			if (!ok)
			{
				Array<double> dd;
				for (int i = 0; i < spX.Size(); i++)
				{
					double l = level.Vec2Diff(p.pos.xy, (spX[i], spY[i])).Length();
					if (l < 128) continue;
					int at = 0;
					while (at < dd.Size() && dd[at] <= l) at++;
					dd.Insert(at, l); ax.Insert(at, spX[i]); ay.Insert(at, spY[i]); az.Insert(at, spZ[i]);
				}
				static const double RING[] = { 384, 256, 160 };
				for (int r = 0; r < RING.Size(); r++)
					for (int k = 0; k < 8; k++)
					{
						double ang = p.angle + k * 45;
						ax.Push(p.pos.x + cos(ang) * RING[r]); ay.Push(p.pos.y + sin(ang) * RING[r]); az.Push(p.pos.z);
					}
				ok = LooseSpot(pr, p, bc, tc, ax, ay, az);
			}
			if (!ok)
			{
				bool useA = cx.Size() == 0;
				int n2 = useA ? ax.Size() : cx.Size();
				if (n2 > 0)
				{
					double x0 = useA ? ax[0] : cx[0], y0 = useA ? ay[0] : cy[0], z0 = useA ? az[0] : cz[0];
					Fits(pr, bc, x0, y0, z0, MB_SCALE);
					double bz = pr.pos.z;
					arrX.Clear(); arrY.Clear(); arrZ.Clear(); arrCls.Clear();
					arrX.Push(x0); arrY.Push(y0); arrZ.Push(bz); arrCls.Push(bc.GetClassName());
					double br = GetDefaultByType(bc).radius * MB_SCALE;
					double base = VectorAngle(p.pos.x - x0, p.pos.y - y0);
					for (int t = 0; t < tc.Size(); t++)
					{
						class<Actor> c = tc[t];
						if (!c) continue;
						double tr = GetDefaultByType(c).radius;
						double ring = br + tr + 16 + (t >= 8 ? tr * 2 + 24 : 0);
						double a = base + 90 + (t % 8) * 45;
						double x = x0 + cos(a) * ring, y = y0 + sin(a) * ring;
						Fits(pr, c, x, y, bz);
						arrX.Push(x); arrY.Push(y); arrZ.Push(pr.pos.z); arrCls.Push(c.GetClassName());
					}
					ok = true;
					arrForce = true;
				}
			}
			if (debug) Console.Printf("RSQMB bossfight spot (Ignore Spawn Restrictions): %s", !ok ? "none at all" : arrForce ? "set down untested"
				: String.Format("%s at %.0f units with %d thralls, past the usual tests", arrCls[0], level.Vec2Diff(p.pos.xy, (arrX[0], arrY[0])).Length(), arrX.Size() - 1));
		}
		if (ok)
		{
			pr.A_SetSize(4, 4, false);
			pr.SetOrigin((arrX[0], arrY[0], arrZ[0] + 32), false);
			arrProbe = pr;
		}
		else pr.Destroy();
		if (debug) Console.Printf("RSQMB bossfight spot: %s after %d of %d candidates (near %.0f far %.0f)%s", ok ? "found" : "none", tries, nc, near, far,
			ok ? String.Format(": %s at %.0f units with %d thralls", arrCls[0], level.Vec2Diff(p.pos.xy, (arrX[0], arrY[0])).Length(), arrX.Size() - 1) : "");
		return ok;
	}

	// The probe, the size of cls (x k: the miniboss stands 1.25x, its hitbox too), on the floor at (x, y): room under the
	// ceiling, nothing in the way.
	static bool Fits(Actor pr, class<Actor> cls, double x, double y, double zHint, double k = 1.0)
	{
		let def = GetDefaultByType(cls);
		double r = def.radius * k, h = def.height * k;
		pr.A_SetSize(r, h, false);
		pr.SetOrigin((x, y, zHint + 8), false);
		double fz = pr.floorz;
		if (pr.ceilingz - fz < h + 4) return false;
		pr.SetOrigin((x, y, fz), false);
		return pr.TestMobjLocation();
	}

	// IGNORE SPAWN RESTRICTIONS' looser spot (PlanArrival): the first candidate where the miniboss fits and at least one
	// thrall fits round it; no sight test. Fills arrX..arrCls.
	bool LooseSpot(Actor pr, PlayerPawn p, class<Actor> bc, Array<String> tc, Array<double> cx, Array<double> cy, Array<double> cz)
	{
		for (int i = 0; i < cx.Size() && i < 48; i++)
		{
			if (!Fits(pr, bc, cx[i], cy[i], cz[i], MB_SCALE)) continue;
			double bz = pr.pos.z;
			arrX.Clear(); arrY.Clear(); arrZ.Clear(); arrCls.Clear();
			arrX.Push(cx[i]); arrY.Push(cy[i]); arrZ.Push(bz); arrCls.Push(bc.GetClassName());
			double br = GetDefaultByType(bc).radius * MB_SCALE;
			double base = VectorAngle(p.pos.x - cx[i], p.pos.y - cy[i]);
			for (int t = 0; t < tc.Size(); t++)
			{
				class<Actor> c = tc[t];
				if (!c) continue;
				double tr = GetDefaultByType(c).radius;
				double r1 = br + tr + 16, r2 = r1 + tr * 2 + 24;
				for (int k = 0; k < 16; k++)
				{
					double ring = k < 8 ? r1 : r2;
					double a = base + 90 + (k % 8) * 45 + (k >= 8 ? 22.5 : 0);
					double x = cx[i] + cos(a) * ring, y = cy[i] + sin(a) * ring;
					bool clash = false;
					for (int q = 1; q < arrX.Size(); q++)
					{
						double dx = arrX[q] - x, dy = arrY[q] - y;
						class<Actor> qc = arrCls[q];
						double rr = tr + GetDefaultByType(qc).radius + 4;
						if (dx * dx + dy * dy < rr * rr) { clash = true; break; }
					}
					if (clash || !Fits(pr, c, x, y, bz) || abs(pr.pos.z - bz) > 48) continue;
					arrX.Push(x); arrY.Push(y); arrZ.Push(pr.pos.z); arrCls.Push(c.GetClassName());
					break;
				}
			}
			if (arrX.Size() >= 2) return true;
		}
		return false;
	}

	// ---- the arrival ----------------------------------------------------------------------------------------------------
	// THE ARRIVAL, STAGGERED (owner + Claude 2026-11-09 10:50-11:20, design/MINIBOSS_REWORK.md "The arrival, the HUD and the
	// beams"): the world and the player slow (RSQ SlowMo "start.bossfight", Landing Slow Motion, 4 s by default, at most 5: all
	// of it inside the one slow window); the thralls land one at a time THRALL_STEP tics apart, each on an arrival beam with its
	// sound (RSQVR_Service "beam"); then the miniboss's entrance from MB_AT; the beam set is picked at random per Bossfight
	// (owner 11:20): V1 thralls + V3 miniboss, or V2 thralls + V4 miniboss, each beam in that monster's ladder colour.
	// VisualRewards hides each monster until its beam's reveal tic; until then it is HELD here (Hold: dormant, its state
	// frozen: it neither moves, targets nor takes damage). RSQ SlowMo's edge arrows (RSQSM_Service "arrow.add") point to each
	// one while it is out of view, cleared ARROW_HOLD tics after its reveal. The miniboss's reveal sends RSQ Glow In The Dark's
	// arrival wave in its colour from where it lands. When all have landed: the bind (shield, lives, colour, powers: Bind).
	// Without VisualRewards (or its beams off: "beam" answers 0) a monster lands in the original Minibosses! teleport fog
	// (FxLand) with Doom's teleport sound and is revealed at once; without SlowMo no arrows and no slow.
	const MB_SCALE = 1.25;       // the miniboss: 1.25x (owner 07:28), its hitbox too (owner 08:57)
	const MB_SPEED = 1.25;       // ... and x1.25 speed, with MISSILEEVENMORE's attack chance (owner 08:57: "extra aggressive and fast")
	const MB_MISSILE = 0.125;    // MissileChanceMult: what MISSILEEVENMORE sets (MISSILEMORE 0.5)
	const TH_SCALE = 1.15;       // a thrall: DOWN's boost (SlowMo down.zs MARK_SCALE "slightly larger"), drawn only
	const THRALL_STEP = 10;      // tics between thralls (~0.3 s)
	const MB_AT = 46;            // the miniboss's entrance from ~1.3 s (or a step after the last thrall)
	const ARROW_HOLD = 18;       // its arrow stays this long after its reveal (~0.5 s)
	const HOLD_CAP = 210;        // the longest a beam may hold a monster hidden (6 s): past it, it is revealed anyway
	const CHAMP_AT = 4;          // tics after its spawn: Champions has rolled on it (it dresses within 3)

	void StartArrival(PlayerPawn p, RSQMB_Meter m, int tier)
	{
		arrPhase = 1;
		arrTic = level.maptime;
		arrPn = p.PlayerNumber();
		arrTier = tier;
		arrMon.Clear(); arrAt.Clear(); arrState.Clear(); arrReveal.Clear(); arrCol.Clear(); arrTics.Clear(); arrBorn.Clear();
		int nth = arrX.Size() - 1;
		for (int i = 0; i < arrX.Size(); i++)
		{
			arrMon.Push(null);
			arrAt.Push(i == 0 ? max(MB_AT, nth * THRALL_STEP) : (i - 1) * THRALL_STEP);
			arrState.Push(0); arrReveal.Push(0); arrCol.Push(0); arrTics.Push(1); arrBorn.Push(0);
		}
		arrBeamSet = random[rsqmbbf](0, 1);
		bfWhy = "";
		// a retry after a failed landing is quiet (owner 11-10): the slow motion, the dark and the music came with the first try
		bool quiet = arrQuiet;
		if (!quiet) SceneMusic(true);   // the Bossfight scene: the owner's track crossfades in (RSQ VisualRewards, by name)
		// the landing in slow motion: RSQ SlowMo's "start.bossfight" (by name; owner 2026-11-09: the countdown bar always shows
		// during a game slow). A game slow: SlowMo shows its countdown bar and the BOSSFIGHT line (Adrenaline on or off), under
		// its Triggers page's "Miniboss" switch, and it neither waits out nor starts SlowMo's shared cooldown, so the thrall
		// windows that follow still get their slow motion (an rsm_pulse here made them wait 25 s: rig 11-05). An older SlowMo
		// answers -1 to that request: then the deliberate "start" as before (no bar with Adrenaline on). 4 s by default (the
		// staggered landing fits inside it), at most 5.
		if (!svcChecked) FindServices();
		int slowMs = int(clamp(CF('rsqmb_bf_slow', 4.0), 0.0, 5.0) * 1000);
		// owner 2026-11-09: "we go to darkdoomz blackest setting and our slowest slomo so the player can find the miniboss":
		// Landing At Slowest asks SlowMo for its slowest (0.05); Landing In The Dark asks RSQ Glow In The Dark to hold DarkDoomZ
		// at DarkDoom Black for the landing ("event.dark", by name; GITD then breathes the miniboss's colour for the fight)
		double landDepth = CI('rsqmb_bf_slowest', 1) ? 0.05 : depthPct / 100.0;
		if (!quiet && smSvc && slowMs > 0 && smSvc.GetInt("start.bossfight", "bossfight", slowMs, landDepth) < 0)
			smSvc.GetInt("start", "bossfight", slowMs, landDepth);
		let gd = GdService();
		if (!quiet && gd && CI('rsqmb_bf_dark', 1)) gd.GetInt("event.dark", "", 0, max(3.0, slowMs / 1000.0) + 0.5);
		if (debug) Console.Printf("RSQMB BOSSFIGHT ARRIVING: tier %d, %s + %d thralls, beams %s, SlowMo %s, VisualRewards %s", tier, arrCls[0], nth,
			arrBeamSet == 0 ? "V1 thralls + V3 miniboss" : "V2 thralls + V4 miniboss", smSvc ? "asked" : "absent", VrService() ? "asked" : "absent");
	}

	// GRAVES RISE (owner 2026-11-06, rsqmb_bf_graves, off): with Legion of Bones and RSQ Graveyards loaded, a Bossfight calling
	// in wakes the tombstones, in the whole map or within rsqmb_bf_graves_radius (rsqmb_bf_graves_mode) of the fight's spawn
	// (1): they raise Legion of Bones undead, Graveyard's way (gy_RSQService "bones.graves", by name; Graveyard needs LoB and
	// answers 0 without it). WHEN: the moment the Bossfight lands (its fog is over and its miniboss and thralls stand): a riser
	// on a stone by the landing spot during the fog could block the miniboss's landing (rig 11-06: "failed to land", and the
	// next try woke the graves a second time), so they wake once, when it has landed. HOW MANY (owner 11-10, Graves Rise
	// Mode): one undead a tombstone, or one for each thrall a tombstone, over the whole map or within the radius; no cap. WHICH: each thrall type's own undead (Graveyard maps the type, the
	// Bones Bridge's table), in turn; Skull Zombies when none maps.
	transient Service graveSvc;
	transient bool graveChecked;
	Service GySvc()
	{
		if (!graveChecked)
		{
			graveChecked = true;
			let it = ServiceIterator.Find("gy_RSQService");
			Service s;
			while (s = it.Next()) if (s.GetClassName() == 'gy_RSQService') { graveSvc = s; break; }
		}
		return graveSvc;
	}

	void Graves(int tier, Actor spot, int thralls)
	{
		if (!CI('rsqmb_bf_graves', 0) || !spot || arrCls.Size() < 1) return;
		let g = GySvc();
		if (!g) { if (debug) Console.Printf("RSQMB graves: RSQ Graveyards not loaded"); return; }
		// owner 11-10: four modes. One Per Stone: every tombstone in range raises one. Thralls Per Stone: every tombstone in range
		// raises one undead for each thrall the fight came with (five thralls: five a stone). Range: the whole map or the radius.
		int mode = clamp(CI('rsqmb_bf_graves_mode', 0), 0, 3);
		int perStone = mode >= 2 ? clamp(thralls, 1, 32) : 1;
		String cls = "";
		for (int i = 1; i < arrCls.Size(); i++) cls = cls .. (i > 1 ? "," : "") .. arrCls[i];
		double radius = (mode == 1 || mode == 3) ? max(64.0, CF('rsqmb_bf_graves_radius', 1024)) : 0;
		int n = g.GetInt("bones.graves", cls, arrPn * 1000 + perStone, radius, spot);
		if (debug) Console.Printf("RSQMB graves: %d thralls, tier %d, %d a stone (%s of the spawn at %.0f %.0f), %d rising", thralls, tier, perStone,
			radius > 0 ? String.Format("within %.0f", radius) : "whole map", spot.pos.x, spot.pos.y, n);
	}

	// THE STONES BEAT WITH THE GLOW (owner 2026-11-06): each heartbeat of the ready meter is sent to RSQ Graveyards too
	// (gy_RSQService "stones.pulse", by name): every tombstone's candle beats with the map's glow. Graveyard holds them steady
	// in RSQ Accessibility's Photosensitive Mode.
	void HeartBeat(int col, double secs)
	{
		Glow(col, secs);
		let g = GySvc();
		if (g) g.GetInt("stones.pulse", "", col, secs);
	}

	// ---- the arrival, tic by tic ------------------------------------------------------------------------------------------
	// arrState per monster: 0 not yet landed, 1 landed and held (hidden by its beam), 2 revealed, 3 did not land
	void ArrivalStep()
	{
		int now = level.maptime;
		int age = now - arrTic;
		let p = players[arrPn].mo;
		bool allIn = true;
		int lastBorn = 0, lastReveal = 0;
		for (int i = 0; i < arrX.Size(); i++)
		{
			if (arrState[i] == 0)
			{
				if (age >= arrAt[i]) Land(i, p);
				else { allIn = false; continue; }
			}
			let a = arrMon[i];
			if (arrState[i] == 1)
			{
				if (!a || a.health <= 0) { arrState[i] = 3; continue; }
				if (now - arrBorn[i] == CHAMP_AT) ChampionFallback(a);
				if (now >= arrReveal[i]) Reveal(i, p);
				else allIn = false;
			}
			if (arrState[i] == 2 && a && now == arrReveal[i] + ARROW_HOLD) ArrowClear(a);
			if (arrState[i] == 2 && now - arrBorn[i] == CHAMP_AT) ChampionFallback(a);
			if (arrState[i] != 3) { lastBorn = max(lastBorn, arrBorn[i]); lastReveal = max(lastReveal, arrReveal[i]); }
		}
		// the miniboss did not land: whoever came stays a plain monster; the meter stays full and it tries again
		if (arrState[0] == 3) { ArrivalFailed("the miniboss did not land"); return; }
		// bound when all have landed, Champions has dressed the last (BIND_TICS) and the last arrow is cleared (ARROW_HOLD)
		if (!allIn || now - lastBorn < BIND_TICS || now < lastReveal + ARROW_HOLD) return;
		arrPhase = 0;
		arrQuiet = false;
		if (arrProbe) { arrProbe.Destroy(); arrProbe = null; }
		Actor mb = arrMon[0];
		Array<Actor> th;
		for (int i = 1; i < arrMon.Size(); i++) if (arrState[i] == 2 && arrMon[i] && arrMon[i].health > 0) th.Push(arrMon[i]);
		if (!mb || mb.health <= 0 || th.Size() == 0) { arrPhase = 1; ArrivalFailed(String.Format("miniboss %s, thralls %d", mb ? "ok" : "none", th.Size())); return; }
		Bind(mb, th);
		let b = bosses[bosses.Size() - 1];
		b.called = true;
		b.tier = arrTier;
		Graves(arrTier, mb, th.Size());
		bfBoss = b;
		bfCount++;
		bfAny = true;
		bfLastTic = level.maptime;
		let m = MeterOf(p);
		if (m) { m.fill = 0; m.ready = false; m.called = false; }
		// the shield is up: the room's glow goes cold grey, the words go up (fight.zs RoomGlow, WordsStep)
		b.wordState = -9;
		b.glowSent = -1;
		if (debug) Console.Printf("RSQMB BOSSFIGHT LANDED: boss %d %s hp %d, %d thralls, %d segments of %.0f, lives %d, map count %d", b.idx, mb.GetClassName(), mb.health,
			th.Size(), b.total, b.segMax, b.lives, bfCount);
	}

	void ArrivalFailed(String why)
	{
		if (debug) Console.Printf("RSQMB bossfight failed to land (%s): tries again", why);
		// (rig 11-09) whoever already came is taken back out, uncounted: left behind, each failed try piled boosted
		// legendary champions on the map and the next try's arrival overlapped them
		for (int i = 0; i < arrMon.Size(); i++)
		{
			let a = arrMon[i];
			arrMon[i] = null;
			if (!a) continue;
			ArrowClear(a);
			a.ClearCounters();
			a.Destroy();
		}
		arrPhase = 0;
		if (arrProbe) { arrProbe.Destroy(); arrProbe = null; }
		arrQuiet = true;     // the retry keeps the music on and plays no effects again; a retry the guardrails stop ends the scene (TryArrive)
	}

	// THE BOSSFIGHT SCENE (owner 2026-11-09: "the music change to my selection for a miniboss fight ... when the fight is over
	// the regular music crossfades back in where it left off"). RSQ VisualRewards owns the scenes (scenes.zs); without it,
	// nothing changes.
	const SCENE_PRIO = 50;
	void SceneMusic(bool on)
	{
		let vr = VrService();
		if (!vr) return;
		if (on && CI('rsqmb_bf_music', 1)) vr.GetInt("scene.push", "bossfight", SCENE_PRIO, 0, null, 'rsqvr/music/boss1');
		else if (!on) vr.GetInt("scene.pop", "bossfight");
	}

	// ONE LANDS: spawned where PlanArrival found room, boosted (SlowMo DOWN's boost: Champions, LegenDoom, its light,
	// full-bright, larger, +50% health without LegenDoom), the miniboss 1.25x with its hitbox and faster and keener to shoot,
	// held, its beam (or the old fog), its arrow
	void Land(int i, Actor p)
	{
		class<Actor> c = arrCls[i];
		Actor a = c ? Actor.Spawn(c, (arrX[i], arrY[i], arrZ[i]), ALLOW_REPLACE) : null;
		if (a && i == 0) { a.A_SetScale(a.Scale.X * MB_SCALE, a.Scale.Y * MB_SCALE); a.A_SetSize(a.radius * MB_SCALE, a.height * MB_SCALE, false); }
		// (rig 11-09) its own thralls land first and walk; one may have stepped into the miniboss's spot: move it aside
		for (int tries = 0; a && i == 0 && tries < 4 && !a.TestMobjLocation(); tries++)
		{
			let bk = a.BlockingMobj;
			if (!bk || arrMon.Find(bk) == arrMon.Size()) break;
			Vector2 d = bk.pos.xy - a.pos.xy;
			if (d.Length() < 1) d = (1, 0);
			Vector3 old = bk.pos;
			// (rig 11-10) clear of the miniboss's BOX: actors collide as axis-aligned squares, so along a diagonal the
			// radii's sum + 8 still overlapped it, and the one spot straight out was often another thrall's: most first
			// landings on rig02 failed and re-landed. Now the eight directions round it, nearest the thrall's own first.
			double ang0 = atan2(d.y, d.x);
			bool moved = false;
			for (int k = 0; k < 8 && !moved; k++)
			{
				double ang = ang0 + ((k + 1) / 2) * 45.0 * ((k % 2) ? 1 : -1);
				Vector2 u = (cos(ang), sin(ang));
				double push = (a.radius + bk.radius + 8) / max(abs(u.x), abs(u.y));
				bk.SetOrigin((a.pos.xy + u * push, bk.pos.z), false);
				moved = bk.TestMobjLocation();
			}
			if (!moved)
			{
				if (debug) Console.Printf("RSQMB arrival: thrall %s could not be moved aside (%s)", bk.GetClassName(),
					bk.BlockingMobj ? String.Format("%s", bk.BlockingMobj.GetClassName()) : (bk.BlockingLine ? "a wall" : "the floor or ceiling"));
				bk.SetOrigin(old, false);
				break;
			}
			if (debug) Console.Printf("RSQMB arrival: thrall %s moved aside for the miniboss", bk.GetClassName());
		}
		if (a && !arrForce && !a.TestMobjLocation())
		{
			if (debug) Console.Printf("RSQMB arrival: %s %d blocked by %s (r %.0f h %.0f at %.0f %.0f %.0f)", i ? "thrall" : "miniboss", i,
				a.BlockingMobj ? a.BlockingMobj.GetClassName() : (a.BlockingLine ? 'a wall' : 'the floor or ceiling'), a.radius, a.height, a.pos.x, a.pos.y, a.pos.z);
			a.ClearCounters(); a.Destroy(); a = null;
		}
		arrMon[i] = a;
		arrBorn[i] = level.maptime;
		if (!a) { arrState[i] = 3; if (debug) Console.Printf("RSQMB arrival: %s %d did not fit", i ? "thrall" : "miniboss", i); return; }
		arrState[i] = 1;
		if (p) a.angle = a.AngleTo(p);
		a.GiveInventoryType("RSQMB_Called");
		int col = ColourOf(a, bosses.Size());
		arrCol[i] = col;
		Boost(a, i == 0, col);
		Hold(i, a);
		// the beam (VisualRewards hides it until its reveal) or the original's teleport fog
		let vr = VrService();
		String kind = i == 0 ? (arrBeamSet == 0 ? "v3" : "v4") : (arrBeamSet == 0 ? "v1" : "v2");
		// nameArg role (contract addition 2026-11-09): sent, but VisualRewards ignores it now (each beam has its own sound)
		Name role = i == 0 ? 'miniboss' : 'thrall';
		int r = vr ? vr.GetInt("beam", kind, col, 1.0, a, role) : 0;
		if (r > 0) arrReveal[i] = level.maptime + min(r, HOLD_CAP);
		else
		{
			arrReveal[i] = level.maptime;
			FxLand(i);
			a.A_StartSound("misc/teleport", CHAN_AUTO, 0, 1.0, 0.4);
		}
		ArrowAdd(a, col, i == 0 ? 1.5 : 1.0);
		if (debug) Console.Printf("RSQMB arrival: %s %d %s lands (colour %06X, tier %d), %s", i ? "thrall" : "miniboss", i, a.GetClassName(), col, TierOfMon(a),
			r > 0 ? String.Format("beam %s, revealed in %d tics", kind, arrReveal[i] - level.maptime) : "teleport fog (no beam)");
	}

	void Boost(Actor a, bool isBoss, int col)
	{
		// Legendary Thralls (rsqmb_legend_thralls) rules a Bossfight too (owner 11-10); off, they get the plain health boost
		bool ld = Loaded("LDLegendaryMonsterPickupGuaranteed") && CI('rsqmb_legend_thralls', 1) != 0;
		// legendary: the thralls now (LegenDoom's own guaranteed pickup); the miniboss at the bind (handler.zs Inherit: its
		// Legendary Boss Health is asked for first)
		if (ld && !isBoss && !Has(a, "LDLegendaryMonsterToken")) Give(a, "LDLegendaryMonsterPickupGuaranteed");
		a.A_AttachLight('RSQMB_Boost', DynamicLight.PointLight, Color(255, (col >> 16) & 255, (col >> 8) & 255, col & 255),
			int(max(64, a.radius * 3)), 0, 0, (0, 0, a.Height * 0.6));
		a.bBRIGHT = true;
		if (!isBoss) a.A_SetScale(a.Scale.X * TH_SCALE, a.Scale.Y * TH_SCALE);
		if (!ld) a.health += max(1, a.GetSpawnHealth() / 2);
		if (isBoss) Aggressive(a);
	}
	// extra aggressive and fast (owner 08:57): x1.25 speed, MISSILEEVENMORE's attack chance (the greed rule's rage keeps its
	// own record of these and puts back only what it wrote)
	static void Aggressive(Actor a)
	{
		a.Speed *= MB_SPEED;
		a.MissileChanceMult = min(a.MissileChanceMult, MB_MISSILE);
	}

	// HELD until its reveal: dormant (no damage taken), its state frozen (it neither moves on its own, looks nor shoots)
	void Hold(int i, Actor a)
	{
		arrTics[i] = a.tics;
		a.bDORMANT = true;
		a.tics = -1;
		a.vel = (0, 0, a.vel.z);
	}
	void Reveal(int i, Actor p)
	{
		let a = arrMon[i];
		arrState[i] = 2;
		if (!a) return;
		a.bDORMANT = false;
		a.tics = arrTics[i] != 0 ? arrTics[i] : 1;
		if (i == 0) Wave(a, arrCol[i]);     // RSQ Glow In The Dark's arrival wave in its colour from where it lands (owner 08:53)
		if (!p || a.health <= 0) return;
		a.bAMBUSH = false;
		a.target = p;
		a.LastHeard = p;
		if (a.SeeState) a.SetState(a.SeeState);
	}

	// The original Minibosses!' teleport fog (fx.zs), for one landing without a beam: a BFG burst at chest and head, plasma
	// bursts round the feet, in its colour.
	void FxLand(int i)
	{
		if (!fxOn) return;
		Color c = arrCol[i] | 0xFF000000;
		class<Actor> cl = arrCls[i];
		double k = i == 0 ? MB_SCALE : 1.0;
		double h = (cl ? GetDefaultByType(cl).height : 56) * k, r = (cl ? GetDefaultByType(cl).radius : 20) * k;
		Vector3 at = (arrX[i], arrY[i], arrZ[i]);
		if (!UseSprites()) { RSQMB_Boss.Burst(at + (0, 0, h * 0.5), c, 24, 4.0, 8); return; }
		int cap = RSQMB_FxPool.CAP[fxDensity] * 2;
		fxp.Shot(at + (0, 0, h * 0.5), RSQMB_FxPool.SQ_BREAK, c, (1.0, 1.0), 0.8, cap);
		fxp.Shot(at + (0, 0, h), RSQMB_FxPool.SQ_BREAK, c, (0.6, 0.6), 0.6, cap);
		for (int k2 = 0; k2 < 4; k2++)
		{
			double a = k2 * 90 + (level.maptime % 90);
			fxp.Shot(at + (cos(a) * r, sin(a) * r, 8), RSQMB_FxPool.SQ_BEADX, c, (1, 1), 0.5, cap);
		}
	}
	// ---- the payoff -------------------------------------------------------------------------------------------------------
	void BfPayoff(RSQMB_Boss b, Actor killer)
	{
		bfLastTic = level.maptime;
		if (bfBoss == b) bfBoss = null;
		Actor who = killer;
		if (!who) who = players[consoleplayer].mo;
		if (killer)
		{
			// (its Score row is the one "Miniboss" row at 3x, sent by BossDied: owner 11-10, "one reward")
			let m = MeterOf(killer, true);
			if (m) m.beaten++;
		}
		// (the x3 boss bits and Score's life crate went 11-10, owner: balanced later with the arcade systems)
		Actor at = b.mb ? b.mb : who;
		if (at) Drop(at, who);
	}

	// A gun from this map's weapon types the player doesn't have; else (a mod whose map pickups are not Weapons until
	// touched, as Brutal Doom's, rig 11-05: 0 weapon types) one from the player's weapon slots, no higher than one slot above
	// the best gun held; else a power-up.
	void Drop(Actor at, Actor who)
	{
		let it = ThinkerIterator.Create("Weapon");
		Weapon w;
		while (w = Weapon(it.Next())) if (!w.Owner && mapWeapons.Find(w.GetClassName()) == mapWeapons.Size()) mapWeapons.Push(w.GetClassName());
		Array<String> can;
		for (int i = 0; i < mapWeapons.Size(); i++)
		{
			class<Weapon> c = mapWeapons[i];
			if (c && !(who && who.FindInventory(c))) can.Push(mapWeapons[i]);
		}
		if (can.Size() == 0 && who && who.player)
		{
			let ws = who.player.weapons;
			int top = 0;
			for (int sl = 1; sl <= 9; sl++)
				for (int k = 0; k < ws.SlotSize(sl); k++) { class<Weapon> c = ws.GetWeapon(sl, k); if (c && who.FindInventory(c)) top = max(top, sl); }
			for (int sl = 2; sl <= min(9, top + 1); sl++)
				for (int k = 0; k < ws.SlotSize(sl); k++)
				{
					class<Weapon> c = ws.GetWeapon(sl, k);
					// not the engine's ID24 extras (QZD 17.3 lists ID24Incinerator / ID24CalamityBlade in Doom's slots: rig 11-05)
					String cn = c ? c.GetClassName() .. "" : "";
					if (c && !who.FindInventory(c) && !GetDefaultByType(c).bCHEATNOTWEAPON && cn.Left(4) != "ID24") can.Push(cn);
				}
		}
		static const String POWER[] = { "Megasphere", "Soulsphere", "Berserk", "BlurSphere" };
		String pick;
		bool weap = can.Size() > 0;
		if (weap) pick = can[random[rsqmbbf](0, can.Size() - 1)];
		else pick = POWER[random[rsqmbbf](0, POWER.Size() - 1)];
		class<Actor> c = pick;
		let d = c ? Actor.Spawn(c, at.pos + (0, 0, at.height * 0.5), weap ? NO_REPLACE : ALLOW_REPLACE) : null;
		if (d)
		{
			d.vel = (frandom[rsqmbbf](-2, 2), frandom[rsqmbbf](-2, 2), 6);
			d.A_StartSound("misc/w_pkup", CHAN_AUTO, 0, 0.6);
		}
		if (debug) Console.Printf("RSQMB bossfight drop: %s %s (%d guns not owned of %d map types)", weap ? "gun" : "power-up", d ? d.GetClassName() : 'none', can.Size(), mapWeapons.Size());
	}

	// ---- for the console (netevent) ----------------------------------------------------------------------------------
	void BfState()
	{
		let p = players[consoleplayer].mo;
		let m = MeterOf(p);
		Console.Printf("RSQMB bossfight: meter %.0f ready %d called %d won %d | map count %d active %d arriving %d waits \"%s\" | %d types %d spots %d exits %d weapons",
			m ? m.fill : -1.0, m && m.ready, m && m.called, m ? m.beaten : 0, bfCount, bfBoss && !bfBoss.done, arrPhase, bfWhy,
			rosterCls.Size(), spX.Size(), exX.Size(), mapWeapons.Size());
	}
}
