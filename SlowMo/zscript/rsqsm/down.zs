// RSQ_SlowMo -- DOWN -> REVENGE -> REVIVE -> RAGE (owner-approved v2, 2026-11-06 19:51: design/NEAR_DEATH.md). It replaces
// v1 (3 kills to get up, kill-drop medkits). SlowMo owns the mode and its options (it owns time); the other mods join by
// name and each still loads alone.
//
//  1 TRIGGER   a hit that would kill you holds you at 1 HP (any source the engine's buddha hold catches: not a telefrag,
//              not forced damage), before any Score life is spent. How: while DOWN is ARMED (its row on, you alive, not
//              in its cooldown) your pawn carries the engine's buddha flag (bBUDDHA). For the first GRACE tics (1 s) the
//              hold stays on: no hit can finish you. After them a killing hit ends DOWN as a failure.
//  2 BODY      THE CROUCH (see Crouch below): the view eases down to 40% of standing height (60% lower) over 0.5 s and the
//              hitbox shrinks with it, through the engine's own crouch arithmetic, in both vr_crouch_use_button modes.
//              CRAWL_K: you move at a third of your speed (RSQSM_DownWatch.GetSpeedFactor, the engine's own speed path,
//              as PowerSpeed). No input is blocked; both hands work as normal. The world goes to the deepest speed
//              (DEPTH 0.05). RSQ Glow In The Dark drains the map to red ("down.redmap"); a heartbeat (Brutal Doom's
//              heartbeat1/2, or stock DSPSTOP pitched down). "Lower View When Down" off: no crouch at all, crawl stays.
//  3 THE MARK  the monster that downed you is marked; if it is dead or gone (a barrel, splash, a telefrag, no source) the
//              strongest living monster in sight of you takes it (spawn health; ties: the nearest), else the nearest.
//              LegenDoom AND Champions loaded: LegenDoom's own forced legendary (its LDLegendaryMonsterPickupGuaranteed,
//              the pickup that runs its LDMonsterInit), and, because a Champions champion cannot be made from outside
//              its own pk3 (its controller is typed), our own boost stands in for the champion part. Otherwise our own
//              boost: a DOWN-red dynamic light on it, full-bright and tinted DOWN red (TRNSLATE RSQSM_DownMark), 15%
//              larger, +50% of its spawn health. VisualRewards draws the skull over its bar ("down.mark").
//  4 CLOCK     6 s to start (Window); each hit you LAND on a monster adds Time per Hit (0.5 s; one per monster per tic,
//              so a shotgun blast on one monster is one hit), never more than Max Window (12 s) left. The bar under the
//              SlowMo bars shows the time left against Max Window, cause line DOWN, then REVENGE once the mark is dead.
//  5 CRATE     killing the mark drops RSQSM_DownCrate where it died: BD_VoxelPack's Berserk voxel turned white with a
//              red cross (TRNSLATE RSQSM_DownCrate), else the stock Medikit sprite. It does not move to you. You crawl
//              to it, or pull it with RSQ Distance Grab (registered with its grab rule service by name). Touching it
//              (or catching it) = REVIVE. Only the downed player can take his crate.
//  6 REVIVE    time comes back, the view rises, health 50 (kept if higher), magazines filled from reserve (ReloadAll),
//              +1 cigarette (Tactical Rig), +1 grenade (Grenade), the REVIVE word (VisualRewards).
//  7 RAGE      Rage Length (5 s) after REVIVE: your damage x2 (RSQSM_DownWatch.ModifyDamage, outgoing) and no ammo used
//              (KeepAmmo: each carried weapon's magazine -- its Ammo2 when that is a magazine, BD22 VR -- or else its
//              Ammo1 -- vanilla -- is put back every tic it drops). The RAGE word (VisualRewards).
//  8 SCAR      each DOWN (passed or failed) costs Scar max health (10) until the next map (restored at WorldUnloaded).
//              No tombstone for DOWN (owner 19:58: a Score life spent gets one, through RSQ Score).
//  9 FAILING   the clock runs out, or a killing hit after the first second: you die, or a Score life catches it.
// 10 REPEAT    Cooldown (60 s) after DOWN ends; Repeat Without Limit (off) removes it.
// 11 SCORE     "Revenge" when you kill the mark (1x that kill's base), "Revive" for the crate (3x it): RS_ScoreService.
// 14 NETPLAY   each player has his own DOWN; the world's slow-down is the clock's, shared as every slow motion is.
//
// JOINING (by name): every Service whose class name contains "RSQDownJoin" is told GetInt(event, stringArg, player, 0,
// actor): "down.start" (pawn), "down.mark" (the monster; "legendary" or "own"), "down.time" (the monster hit; "+0.5s"),
// "down.revenge" (the dead mark), "down.revive" (pawn), "down.rage" (pawn), "down.fail" (pawn; why).
// RSQSM_Service answers "down" / "down.hold" / "down.any" / "down.redmap" / "down.left" / "down.rage" (intArg player)
// and "down.mark" (objectArg a monster: 1 while it carries a DOWN mark).
class RSQSM_Down : EventHandler
{
	const GRACE = 35;          // tics after the trigger in which no hit kills (owner's spec: 1 s)
	const DEPTH = 0.05;        // the world's speed while DOWN: the deepest SlowMo has
	const REVIVE_HP = 50;
	const CROUCH_K = 0.4;      // the view and hitbox at 40% of standing: "60% lower" (Crouch: why it is safe)
	const CROUCH_TICS = 17;    // ~0.5 s to ease all the way
	const CRAWL_K = 1.0 / 3.0;   // crawl speed
	const MARK_SCALE = 1.15;   // "slightly larger"
	const DOWN_RED = 0xC81010;

	// ---- synced (in the save) ----------------------------------------------------------------------------------------
	bool   downOn[MAXPLAYERS];
	int    downStart[MAXPLAYERS], downEnd[MAXPLAYERS], downMax[MAXPLAYERS];   // maptime (real time: never slowed)
	int    coolUntil[MAXPLAYERS];
	int    beatNext[MAXPLAYERS], beatN[MAXPLAYERS];
	bool   reviveDue[MAXPLAYERS];
	bool   held[MAXPLAYERS];
	int    endTic[MAXPLAYERS];
	int    endHow[MAXPLAYERS];                           // 1 revived, 2 failed
	int    startTic[MAXPLAYERS];
	Actor  mark[MAXPLAYERS];
	bool   markDone[MAXPLAYERS];                         // the mark is dead: REVENGE
	Actor  crate[MAXPLAYERS];
	int    hitsAdded[MAXPLAYERS];
	Array<Actor> marked;                                 // every monster boosted by a mark (stays boosted)
	// the crouch
	bool   cOn[MAXPLAYERS];
	double cK[MAXPLAYERS], cVH[MAXPLAYERS], cFH[MAXPLAYERS];
	Actor  cPawn[MAXPLAYERS];
	int    cLogged[MAXPLAYERS];
	// rage
	int    rageUntil[MAXPLAYERS];
	Array<Inventory> rageAmmo;
	Array<int> rageAmt, rageWho;
	int    rageSaved[MAXPLAYERS];
	// the scar
	int    scar[MAXPLAYERS], scarZero[MAXPLAYERS];
	Actor  scarPawn[MAXPLAYERS];

	// ---- this tic ----------------------------------------------------------------------------------------------------
	private transient int hpSeen[MAXPLAYERS];
	private transient Array<Actor> hitMon;
	private transient int hitTicNow;

	static RSQSM_Down Get() { return RSQSM_Down(EventHandler.Find("RSQSM_Down")); }
	static clearscope double Cv(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope double CvP(String n, int pn, double d)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return Cv(n, d);
		let c = CVar.GetCVar(n, players[pn]);
		return c ? c.GetFloat() : d;
	}
	static bool On() { return Cv("rsqsm_down", 1) != 0; }
	static int WindowTics() { return int(clamp(Cv("rsqsm_down_window", 6), 2, 30) * TICRATE); }
	static int MaxTics() { return max(WindowTics(), int(clamp(Cv("rsqsm_down_max", 12), 2, 30) * TICRATE)); }
	static int HitTics() { return int(round(clamp(Cv("rsqsm_down_hit", 0.5), 0, 3) * TICRATE)); }
	static int RageTics() { return int(clamp(Cv("rsqsm_down_rage", 5), 0, 30) * TICRATE); }
	static int ScarHp() { return Cv("rsqsm_down_scar", 1) != 0 ? int(clamp(Cv("rsqsm_down_scar_hp", 10), 0, 90)) : 0; }
	static int CoolTics() { return Cv("rsqsm_down_repeat", 0) != 0 ? 0 : int(clamp(Cv("rsqsm_down_cool", 60), 0, 300) * TICRATE); }
	static bool LowView(int n) { return CvP("rsqsm_down_lowview", n, 1) != 0; }
	static bool Debug() { return Cv("rsqsm_debug", 0) != 0; }
	static void Log(String s) { if (Debug()) Console.Printf("RSQ_SlowMo: DOWN t%d: %s", level.maptime, s); }

	clearscope bool AnyOn() { for (int n = 0; n < MAXPLAYERS; n++) if (downOn[n]) return true; return false; }
	clearscope bool IsDown(int n) { return n >= 0 && n < MAXPLAYERS && downOn[n]; }
	clearscope int Left(int n) { return IsDown(n) ? max(0, downEnd[n] - level.maptime) : -1; }
	clearscope bool Raging(int n) { return n >= 0 && n < MAXPLAYERS && rageUntil[n] > level.maptime; }
	clearscope bool IsMarked(Actor a) { return a && marked.Find(a) < marked.Size(); }
	// the crawl factor on the engine's speed (RSQSM_DownWatch.GetSpeedFactor): a third overall, less what the engine's
	// own crouch already takes (MovePlayer multiplies by clamp(crouchfactor, 0.5, 1) whenever crouchfactor is not 1)
	double Crawl(int n)
	{
		if (!IsDown(n) || !players[n].mo) return 1.0;
		double cf = players[n].crouchfactor;
		double eng = (cf != 1) ? clamp(cf, 0.5, 1.0) : 1.0;
		return CRAWL_K / eng;
	}

	override void WorldLoaded(WorldEvent e)
	{
		GrabRule();
		if (e.IsSaveGame) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			downOn[n] = false; downStart[n] = 0; downEnd[n] = 0; downMax[n] = 0; coolUntil[n] = 0;
			beatNext[n] = 0; beatN[n] = 0; reviveDue[n] = false; held[n] = false; endTic[n] = 0; endHow[n] = 0; startTic[n] = -1;
			mark[n] = null; markDone[n] = false; crate[n] = null; cOn[n] = false; rageUntil[n] = 0; scar[n] = 0;
		}
		marked.Clear(); rageAmmo.Clear(); rageAmt.Clear(); rageWho.Clear();
	}

	// THE NEXT MAP: nothing carries over. The pawn travels, so everything this put on it comes off exactly here: the hold,
	// the crouch (its standing heights put back), the scar (its max health put back).
	override void WorldUnloaded(WorldEvent e)
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			Hold(n, false);
			CrouchRestore(n, "the map ends");
			ScarRestore(n);
			downOn[n] = false; rageUntil[n] = 0;
		}
		gone = true;      // the level is over: no tic of this handler may touch the travelling pawn again
	}
	private transient bool gone;

	// RSQ DISTANCE GRAB (by name): the crate is a thing its hand may pull (its rule service, "grab.rule"; FnF's flare is
	// in its table the same way). Weight 2.0, a flare's. Without Distance Grab nothing answers.
	private void GrabRule()
	{
		let it = ServiceIterator.Find("RSQDG_GrabRuleService");
		Service s;
		while (s = it.Next())
		{
			if (s.GetInt("grab.hello", "", 0, 0, null, '') != 1) continue;
			int r = s.GetInt("grab.rule", "RSQSM_DownCrate", 0, 0, null, 'RSQ_SlowMo');
			s.GetInt("grab.weight", "RSQSM_DownCrate", 0, 2.0, null, '');
			Log(String.Format("RSQ Distance Grab: the crate registered as grabbable (%d)", r));
			return;
		}
	}

	// ---- the hold ---------------------------------------------------------------------------------------------------
	bool Armed(int n)
	{
		if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0 || players[n].playerstate == PST_DEAD) return false;
		let c = RSQSM_Clock.Get();
		if (c && c.StoodDown()) return false;
		if (downOn[n]) return level.maptime - downStart[n] < GRACE;
		if (!On()) return false;
		return Cv("rsqsm_down_repeat", 0) != 0 || level.maptime >= coolUntil[n];
	}
	private void Hold(int n, bool want)
	{
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) { held[n] = false; return; }
		if (want && !held[n])
		{
			if (pmo.bBUDDHA) return;
			pmo.bBUDDHA = true; held[n] = true;
		}
		else if (!want && held[n]) { pmo.bBUDDHA = false; held[n] = false; }
	}

	// ---- every tic ----------------------------------------------------------------------------------------------------
	override void WorldTick()
	{
		if (gone) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			if (!pmo.FindInventory("RSQSM_DownWatch")) pmo.GiveInventoryType("RSQSM_DownWatch");
			if (downOn[n])
			{
				if (reviveDue[n]) Revive(n);
				else if (pmo.health <= 0) Fail(n, "he died (a hit the hold could not catch)");
				else if (level.maptime >= downEnd[n]) Fail(n, markDone[n] ? "the clock ran out before the crate" : "the clock ran out before the mark died");
				else { Heartbeat(n); WatchMark(n); }
			}
			if (pmo.health <= 0 || players[n].playerstate == PST_DEAD) CrouchRestore(n, "he is dead");
			else Crouch(n, pmo, downOn[n]);
			if (rageUntil[n] > 0)
			{
				if (level.maptime < rageUntil[n] && pmo.health > 0) KeepAmmo(n, pmo);
				else EndRage(n);
			}
			Hold(n, Armed(n));
			hpSeen[n] = pmo.health;
		}
	}

	private void Heartbeat(int n)
	{
		if (level.maptime < beatNext[n]) return;
		let pmo = players[n].mo;
		double left = double(downEnd[n] - level.maptime) / max(1, downMax[n]);
		beatNext[n] = level.maptime + int(12 + 14 * clamp(left, 0.0, 1.0));
		beatN[n]++;
		bool bd = S_GetLength("heartbeat1") > 0;
		if (bd) pmo.A_StartSound((beatN[n] & 1) ? "heartbeat1" : "heartbeat2", CHAN_AUTO, CHANF_LOCAL, 1.0, ATTN_NONE);
		else pmo.A_StartSound("plats/pt1_stop", CHAN_AUTO, CHANF_LOCAL, 0.9, ATTN_NONE, 0.55);
		if (beatN[n] % 4 == 1) Log(String.Format("player %d heartbeat %d: %s", n, beatN[n], bd ? "Brutal Doom heartbeat1/2" : "stock plats/pt1_stop at pitch 0.55"));
		RSQSM_Buzz.Start(pmo, 0, 0.35, 3);
		RSQSM_Buzz.Start(pmo, 1, 0.35, 3);
	}

	// ==================================================================================================================
	// THE CROUCH (spec 2). What the engine does (QuestZDoom 17.3, player.zs; the survey 09_MOVEMENT 3.5, 00_CAPABILITIES
	// gotcha 4): PlayerPawn.Tick sets Height = FullHeight * crouchfactor, CrouchMove sets viewheight = ViewHeight *
	// crouchfactor. With vr_crouch_use_button 1 crouchfactor comes from the crouch button (CheckCrouch, clamped 0.5..1);
	// with 0 the VR layer OVERWRITES crouchfactor from the head's height every frame (crouching = 10), so a script cannot
	// hold crouchfactor in that mode. What a script CAN hold in both modes is the other factor of the same products: the
	// pawn's standing heights, ViewHeight and FullHeight. So DOWN scales those by m = CROUCH_K / crouchfactor (at most 1):
	// view and hitbox end at 40% of standing whatever the mode, and a player already crouched deeper (button or head)
	// keeps his own depth. Eased over 0.5 s both ways; the view written each tic as CrouchMove writes it. Read nothing
	// local: the same on every machine.
	// 60% LOWER, AND WHY IT IS SAFE (else it would be 50%): (1) the view: CalcHeight never puts the eye below floorz + 4
	// or above ceilingz - 4 (in a liquid with floor clip it sits at floor + 4); the head-tracked mode already lets a player
	// crouch below 0.5 unclamped. (2) collision: a shorter pawn always fits where it stood. (3) getting stuck: rising is
	// only taken a step at a time when the taller pawn fits under the ceiling (else it waits, crawling, as the engine's
	// own uncrouch does). The standing heights are put back EXACTLY (the saved numbers) when the rise ends, on death and
	// at the map's end.
	private void Crouch(int n, PlayerPawn pmo, bool down)
	{
		let p = players[n];
		double target = (down && LowView(n)) ? CROUCH_K : 1.0;
		if (!cOn[n])
		{
			if (target >= 1.0) return;
			cOn[n] = true; cK[n] = 1.0; cVH[n] = pmo.ViewHeight; cFH[n] = pmo.FullHeight; cPawn[n] = pmo; cLogged[n] = 0;
			Log(String.Format("player %d crouch: down to %.0f%% of standing over %d tics (ViewHeight %.1f FullHeight %.1f saved; crouchfactor %.2f, vr_crouch_use_button %s)",
				n, CROUCH_K * 100, CROUCH_TICS, cVH[n], cFH[n], p.crouchfactor, n == consoleplayer ? String.Format("%d", int(Cv("vr_crouch_use_button", 1))) : "?"));
		}
		if (cPawn[n] != pmo) { cOn[n] = false; return; }       // a new pawn (respawn): never touch it
		double cf = max(p.crouchfactor, 0.05);   // the head-height mode can read above 1 (a tall player)
		double step = (1.0 - CROUCH_K) / CROUCH_TICS;
		double k = cK[n];
		double nk = k < target ? min(target, k + step) : max(target, k - step);
		if (nk > k)
		{
			// rising: only when the taller pawn fits under the ceiling here
			double fh = cFH[n] * min(1.0, nk / cf);
			if (pmo.pos.z + fh * cf > pmo.ceilingz)
			{
				if (cLogged[n] != 2) { cLogged[n] = 2; Log(String.Format("player %d crouch: no room to rise (ceiling %.0f over feet %.0f), waiting", n, pmo.ceilingz, pmo.pos.z)); }
				nk = k;
			}
		}
		cK[n] = nk;
		if (nk >= 1.0) { CrouchRestore(n, "risen"); return; }
		double m = min(1.0, nk / cf);
		pmo.ViewHeight = cVH[n] * m;
		pmo.FullHeight = cFH[n] * m;
		pmo.Height = pmo.FullHeight * cf;
		p.viewheight = pmo.ViewHeight * cf;
		p.crouchviewdelta = p.viewheight - pmo.ViewHeight;
		if (nk <= CROUCH_K && cLogged[n] == 0)
		{
			cLogged[n] = 1;
			Log(String.Format("player %d crouch held: view %.1f of %.1f standing, height %.1f of %.1f (crouchfactor %.2f x heights %.2f), crawl x%.2f",
				n, p.viewheight, cVH[n], pmo.Height, cFH[n], cf, m, Crawl(n)));
		}
	}
	private void CrouchRestore(int n, String why)
	{
		if (n < 0 || n >= MAXPLAYERS || !cOn[n]) return;
		cOn[n] = false;
		let pmo = PlayerPawn(cPawn[n]);
		cPawn[n] = null;
		if (!pmo || !pmo.player) return;
		pmo.ViewHeight = cVH[n];
		pmo.FullHeight = cFH[n];
		let p = pmo.player;
		if (pmo.health > 0 && p.playerstate != PST_DEAD)
		{
			pmo.Height = cFH[n] * p.crouchfactor;
			p.viewheight = cVH[n] * p.crouchfactor;
			p.crouchviewdelta = p.viewheight - cVH[n];
		}
		Log(String.Format("player %d crouch restored (%s): ViewHeight %.1f FullHeight %.1f, view %.1f, height %.1f", n, why, pmo.ViewHeight, pmo.FullHeight, p.viewheight, pmo.Height));
	}

	// ---- the hits -----------------------------------------------------------------------------------------------------
	static int PlayerOf(Actor src)
	{
		if (!src) return -1;
		if (!src.player && src.FriendPlayer > 0 && src.FriendPlayer <= MAXPLAYERS) src = players[src.FriendPlayer - 1].mo;
		if (!src || !src.player) return -1;
		return src.PlayerNumber();
	}
	static bool IsFoe(Actor t)
	{
		if (!t || t.player || !t.bISMONSTER || t.bFRIENDLY) return false;
		// Brutal Doom's helpers (head hitboxes and the like: ISMONSTER, -COUNTKILL, 1000+ health) are not monsters
		if (!t.bCOUNTKILL && t.GetSpawnHealth() >= 1000) return false;
		return true;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let t = e.Thing;
		if (!t) return;
		if (t.player) { PlayerHit(e); return; }
		if (!IsFoe(t) || e.Damage <= 0) return;
		int n = PlayerOf(e.DamageSource);
		// THE MARK DIES (by anyone's hand: the crate drops; "Revenge" is the downed player's own kill)
		if (t.health <= 0)
			for (int k = 0; k < MAXPLAYERS; k++)
				if (downOn[k] && mark[k] == t && !markDone[k]) MarkKilled(k, n == k);
		if (n < 0 || !downOn[n] || reviveDue[n]) return;
		// TIME PER HIT: one per monster per tic (a shotgun's pellets on one monster are one hit)
		if (hitTicNow != level.maptime) { hitTicNow = level.maptime; hitMon.Clear(); }
		if (hitMon.Find(t) < hitMon.Size()) return;
		hitMon.Push(t);
		int add = HitTics();
		if (add <= 0) return;
		int was = downEnd[n] - level.maptime;
		downEnd[n] = min(downEnd[n] + add, level.maptime + downMax[n]);
		int got = downEnd[n] - level.maptime - was;
		hitsAdded[n]++;
		Log(String.Format("player %d hit %s (%d damage): +%.1f s -> %.1f s left (cap %.0f s)", n, t.GetClassName(), e.Damage, got / double(TICRATE),
			(downEnd[n] - level.maptime) / double(TICRATE), downMax[n] / double(TICRATE)));
		if (got > 0) Tell("down.time", n, String.Format("+%.1fs", add / double(TICRATE)), t);
	}

	private void PlayerHit(WorldEvent e)
	{
		let pmo = e.Thing;
		int n = pmo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS || e.Damage <= 0) return;
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
			if (On()) Log(String.Format("player %d: a lethal hit (%d at %d HP from %s), DOWN not triggered (%s): health %d", n, e.Damage, pre, from,
				level.maptime < coolUntil[n] && Cv("rsqsm_down_repeat", 0) == 0 ? String.Format("its cooldown, %.1f s left", (coolUntil[n] - level.maptime) / double(TICRATE)) : "not armed", pmo.health));
			return;
		}
		Start(n, e.Damage, pre, from, e.DamageSource);
	}

	private void Start(int n, int dmg, int pre, String from, Actor src)
	{
		let pmo = players[n].mo;
		downOn[n] = true;
		downStart[n] = level.maptime;
		downEnd[n] = level.maptime + WindowTics();
		downMax[n] = MaxTics();
		reviveDue[n] = false;
		beatNext[n] = level.maptime;
		beatN[n] = 0;
		startTic[n] = level.maptime;
		markDone[n] = false;
		hitsAdded[n] = 0;
		if (crate[n]) { crate[n].Destroy(); crate[n] = null; }
		Log(String.Format("player %d went DOWN: a lethal hit (%d at %d HP from %s) held at %d HP; clock %.1f s (max %.1f s, +%.1f s a hit), world to %d%%",
			n, dmg, pre, from, pmo.health, WindowTics() / double(TICRATE), downMax[n] / double(TICRATE), HitTics() / double(TICRATE), int(DEPTH * 100 + 0.5)));
		pmo.A_StartSound("rsqsm/in", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.8, 10);
		RSQSM_Buzz.Start(pmo, 1, 0.8, 10);
		ApplyScar(n, pmo);
		Tell("down.start", n, "", pmo);
		MarkFoe(n, src);
	}

	// ---- THE MARK (spec 3) ---------------------------------------------------------------------------------------------
	private void MarkFoe(int n, Actor src)
	{
		let pmo = players[n].mo;
		Actor m = null;
		String how;
		// the shooter of a missile is its source already (DamageSource); a monster's own helper answers to its master
		if (src && !src.player && !IsFoe(src) && src.master && IsFoe(src.master)) src = src.master;
		if (src && IsFoe(src) && src.health > 0) { m = src; how = "the monster that downed him"; }
		else
		{
			m = Pick(pmo);
			how = String.Format("%s (the source, %s, is %s)", m ? "the strongest monster in sight" : "none", src ? String.Format("%s", src.GetClassName()) : "nothing",
				!src ? "gone" : (src.health <= 0 ? "dead" : "not a monster"));
			if (m && !m.CheckSight(pmo, SF_IGNOREVISIBILITY)) how = "the nearest monster (none in sight)";
		}
		mark[n] = m;
		if (!m) { Log(String.Format("player %d: no living monster to mark", n)); return; }
		String boost = Boost(m);
		Log(String.Format("player %d MARKED %s \"%s\" (%s): %s; health %d of %d", n, m.GetClassName(), m.GetTag(), how, boost, m.health, m.GetSpawnHealth()));
		Tell("down.mark", n, boost.Left(9) == "legendary" ? "legendary" : "own", m);
	}
	private Actor Pick(Actor pmo)
	{
		let it = ThinkerIterator.Create("Actor", Thinker.STAT_DEFAULT);
		Actor a, best, near;
		int bh = -1; double bd = 1e18, nd = 1e18;
		while (a = Actor(it.Next()))
		{
			if (!IsFoe(a) || a.health <= 0 || !a.bSHOOTABLE) continue;
			double d = pmo.Distance3DSquared(a);
			if (d < nd) { nd = d; near = a; }
			if (!a.CheckSight(pmo, SF_IGNOREVISIBILITY)) continue;
			int h = a.GetSpawnHealth();
			if (h > bh || (h == bh && d < bd)) { bh = h; bd = d; best = a; }
		}
		return best ? best : near;
	}
	static bool ClassLoaded(String n) { Name nm = n; class<Actor> c = nm; return c != null; }
	// the boost; a monster already marked by an earlier DOWN keeps the one it has
	private String Boost(Actor m)
	{
		if (IsMarked(m)) return "already boosted by an earlier DOWN";
		marked.Push(m);
		bool ld = ClassLoaded("LDLegendaryMonsterPickupGuaranteed"), ch = ClassLoaded("champion_Token");
		String r;
		bool legend = false;
		if (ld && ch)
		{
			// LEGENDOOM'S OWN FORCED LEGENDARY (MonsterGen.dec LDLegendaryMonsterPickupGuaranteed -> LEGENDARIFYSuccess: its
			// marker, then ACS LDMonsterInit as the monster: the token, LD_legendaryhealth, the transform at half health).
			// Champions has no outside door to make a champion (its controller is typed): our own boost stands in for it.
			Name gn = "LDLegendaryMonsterPickupGuaranteed", tn = "LDLegendaryMonsterToken";
			class<Inventory> g = gn, tk = tn;
			if (g && (!tk || m.CountInv(tk) == 0)) m.GiveInventory(g, 1);
			legend = true;
			r = "legendary (LegenDoom's LDLegendaryMonsterPickupGuaranteed) + our own boost for the Champions part (no outside door to a champion)";
		}
		// OUR OWN BOOST: the light, full-bright, the red tint, a little larger, +50% (LegenDoom sets a legendary's health)
		m.A_AttachLight('RSQSM_DownMark', DynamicLight.PointLight, Color(255, (DOWN_RED >> 16) & 255, (DOWN_RED >> 8) & 255, DOWN_RED & 255),
			int(max(64, m.radius * 3)), 0, 0, (0, 0, m.Height * 0.6));
		m.bBRIGHT = true;
		m.A_SetTranslation('RSQSM_DownMark');
		m.A_SetScale(m.Scale.X * MARK_SCALE, m.Scale.Y * MARK_SCALE);
		int was = m.health;
		if (!legend) m.health += max(1, m.GetSpawnHealth() / 2);
		if (r == "") r = String.Format("our own boost (%s): DOWN-red light, full-bright, red tint, x%.2f size, health %d -> %d",
			ld ? "LegenDoom without Champions" : (ch ? "Champions without LegenDoom" : "neither LegenDoom nor Champions"), MARK_SCALE, was, m.health);
		return r;
	}
	// a mark gone without dying (removed) passes to another; a mark that died with no hit seen (A_Die) still drops the crate
	private void WatchMark(int n)
	{
		if (markDone[n]) return;
		let m = mark[n];
		if (m && m.health > 0) return;
		if (m && m.health <= 0) { MarkKilled(n, false); return; }
		if (level.maptime == downStart[n]) return;
		Log(String.Format("player %d: the mark is gone without dying: a new one", n));
		MarkFoe(n, null);
	}
	private void MarkKilled(int n, bool byHim)
	{
		let m = mark[n];
		markDone[n] = true;
		let pmo = players[n].mo;
		Vector3 at = m ? m.pos : pmo.pos;
		let c = RSQSM_DownCrate(Actor.Spawn("RSQSM_DownCrate", at + (0, 0, 8), NO_REPLACE));
		if (c)
		{
			c.forPlayer = n;
			c.Look();
			c.vel = (0, 0, 3);
			crate[n] = c;
		}
		Log(String.Format("player %d REVENGE: the mark %s died%s; the crate dropped at %.0f %.0f %.0f (%s); %.1f s left",
			n, m ? String.Format("%s", m.GetClassName()) : "?", byHim ? " by his hand" : " (not by his hand: no Revenge award)", at.x, at.y, at.z,
			c && c.voxel ? "BD_VoxelPack's Berserk voxel, white with a red cross" : "the stock Medikit sprite", (downEnd[n] - level.maptime) / double(TICRATE)));
		Tell("down.revenge", n, "", m);
		if (byHim) Award(pmo, "Revenge");
	}
	// the crate taken (RSQSM_DownCrate.TryPickup): REVIVE on this tic's WorldTick, not inside the engine's pickup
	void CrateTaken(int n)
	{
		if (!IsDown(n)) return;
		reviveDue[n] = true;
		crate[n] = null;
		Log(String.Format("player %d took the crate", n));
	}

	private void Revive(int n)
	{
		let pmo = players[n].mo;
		End(n, true);
		int was = pmo.health;
		if (pmo.health < REVIVE_HP) pmo.A_SetHealth(min(REVIVE_HP, pmo.GetMaxHealth(true)));
		String rl;
		int filled = ReloadAll(pmo, rl);
		Log(String.Format("player %d REVIVED: health %d -> %d (max %d); magazines filled from their reserves: %d (%s); cooldown %s",
			n, was, pmo.health, pmo.GetMaxHealth(true), filled, rl == "" ? "none" : rl, CoolTics() > 0 ? String.Format("%.0f s", CoolTics() / double(TICRATE)) : "none (Repeat Without Limit)"));
		pmo.A_StartSound("rsqsm/out", CHAN_AUTO, CHANF_LOCAL, 1.0);
		pmo.A_StartSound("misc/p_pkup", CHAN_AUTO, CHANF_LOCAL, 1.0);
		RSQSM_Buzz.Start(pmo, 0, 0.7, 8);
		RSQSM_Buzz.Start(pmo, 1, 0.7, 8);
		Tell("down.revive", n, "", pmo);
		Award(pmo, "Revive");
		StartRage(n, pmo);
	}

	private void Fail(int n, String why)
	{
		let pmo = players[n].mo;
		End(n, false);
		Tell("down.fail", n, why, pmo);
		if (!pmo || pmo.health <= 0) { Log(String.Format("player %d: DOWN failed (%s): dead", n, why)); return; }
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
		endHow[n] = revived ? 1 : 2;
		coolUntil[n] = level.maptime + CoolTics();
		Hold(n, false);
		if (crate[n]) { crate[n].Destroy(); crate[n] = null; }
		let c = RSQSM_Clock.Get();
		if (c) c.freeUntil[n] = max(c.freeUntil[n], level.maptime + int(c.RampOut() * TICRATE) + 2);
	}

	// ---- RAGE (spec 7) ------------------------------------------------------------------------------------------------
	private void StartRage(int n, PlayerPawn pmo)
	{
		int t = RageTics();
		if (t <= 0) return;
		rageUntil[n] = level.maptime + t;
		rageSaved[n] = 0;
		for (int i = rageWho.Size() - 1; i >= 0; i--) if (rageWho[i] == n) { rageAmmo.Delete(i); rageAmt.Delete(i); rageWho.Delete(i); }
		KeepAmmo(n, pmo);
		Log(String.Format("player %d RAGE for %.1f s: damage x2, no ammo used (%d ammo kinds held)", n, t / double(TICRATE), Kinds(n)));
		Tell("down.rage", n, "", pmo);
	}
	private int Kinds(int n) { int k = 0; for (int i = 0; i < rageWho.Size(); i++) if (rageWho[i] == n) k++; return k; }
	// NO AMMO USED, generically: for each carried weapon, the ammo a shot spends -- its magazine (Ammo2, when that is a
	// magazine: no weapon anywhere uses it as its first ammo; BD22 VR) or else its Ammo1 (vanilla, and BD22's guns with
	// no magazine) -- is held at the highest amount seen during RAGE: put back every tic it dropped, followed when it rises.
	// A reserve feeding a magazine is left alone (a reload still costs the reserve; the magazine never needs one).
	private void KeepAmmo(int n, PlayerPawn pmo)
	{
		if (!reservesBuilt) BuildReserves();
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w) continue;
			Inventory a = null;
			if (w.Ammo2 && w.Ammo1 && w.Ammo1.GetClass() != w.Ammo2.GetClass() && reserves.Find(w.Ammo2.GetClassName()) == reserves.Size()) a = w.Ammo2;
			else if (w.Ammo1) a = w.Ammo1;
			if (!a) continue;
			int i;
			for (i = 0; i < rageAmmo.Size(); i++) if (rageAmmo[i] == a && rageWho[i] == n) break;
			if (i == rageAmmo.Size()) { rageAmmo.Push(a); rageAmt.Push(a.Amount); rageWho.Push(n); continue; }
			if (a.Amount < rageAmt[i])
			{
				rageSaved[n] += rageAmt[i] - a.Amount;
				Log(String.Format("player %d RAGE: %s %d -> %d put back (no ammo used; %d saved so far)", n, a.GetClassName(), a.Amount, rageAmt[i], rageSaved[n]));
				a.Amount = rageAmt[i];
			}
			else rageAmt[i] = a.Amount;
		}
	}
	private void EndRage(int n)
	{
		Log(String.Format("player %d RAGE ended: %d rounds saved", n, rageSaved[n]));
		rageUntil[n] = 0;
		for (int i = rageWho.Size() - 1; i >= 0; i--) if (rageWho[i] == n) { rageAmmo.Delete(i); rageAmt.Delete(i); rageWho.Delete(i); }
	}

	// ---- THE SCAR (spec 8) --------------------------------------------------------------------------------------------
	private void ApplyScar(int n, PlayerPawn pmo)
	{
		int s = ScarHp();
		if (s <= 0) return;
		if (scarPawn[n] != pmo) { scar[n] = 0; scarPawn[n] = pmo; scarZero[n] = pmo.MaxHealth <= 0 ? 1 : 0; }
		int was = pmo.GetMaxHealth(false);
		int now = max(10, was - s);
		pmo.MaxHealth = now;
		scar[n] += was - now;
		Log(String.Format("player %d SCAR: max health %d -> %d (-%d this map) until the next map", n, was, now, scar[n]));
	}
	private void ScarRestore(int n)
	{
		let pmo = PlayerPawn(scarPawn[n]);
		if (!pmo || scar[n] <= 0) { scar[n] = 0; scarPawn[n] = null; return; }
		if (scarZero[n]) pmo.MaxHealth = 0;
		else pmo.MaxHealth += scar[n];
		Log(String.Format("player %d scar healed at the map's end: max health back to %d", n, pmo.GetMaxHealth(false)));
		scar[n] = 0; scarPawn[n] = null;
	}

	// ---- RELOAD EVERY CARRIED WEAPON (REVIVE): each magazine (Ammo2 that no weapon uses as its first ammo) filled to its
	// MaxAmount from its reserve (Ammo1), as far as the reserve goes. Vanilla weapons have no second ammo: nothing to do.
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
		if (what != "down.time") Log(String.Format("told %d joined mod(s): %s %s", k, what, s));
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

// HIS HEALTH JUST BEFORE A HIT (passive), RAGE's x2 on the damage he deals (not passive: the engine asks the SOURCE's items
// to modify outgoing damage), and the crawl (GetSpeedFactor: the engine's own speed path, as PowerSpeed).
class RSQSM_DownWatch : Inventory
{
	int preHp;
	bool fresh;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		newdamage = damage;
		if (!Owner || !Owner.player) return;
		if (passive) { preHp = Owner.health; fresh = true; return; }
		let d = RSQSM_Down.Get();
		if (d && damage > 0 && d.Raging(Owner.PlayerNumber()))
		{
			newdamage = damage * 2;
			RSQSM_Down.Log(String.Format("player %d RAGE: damage %d -> %d", Owner.PlayerNumber(), damage, newdamage));
		}
	}
	override double GetSpeedFactor()
	{
		if (!Owner || !Owner.player) return 1;
		let d = RSQSM_Down.Get();
		return d ? d.Crawl(Owner.PlayerNumber()) : 1;
	}
}

// THE CRATE (spec 5): dropped by the mark's death, for the downed player only. Touching it -- or catching it with RSQ Distance
// Grab, which hands what it catches over through the same pickup -- is REVIVE. It does not move toward anyone. With
// BD_VoxelPack (a voxel for PSTR A in the voxels namespace, which is where the engine looks) it is that pack's Berserk
// pack turned white with a red cross (TRNSLATE RSQSM_DownCrate); without, the stock Medikit sprite. A class named RSQ*:
// SlowMo's clock leaves it on real time.
class RSQSM_DownCrate : Inventory
{
	int forPlayer;
	bool voxel;
	Default
	{
		Inventory.PickupMessage "";
		Inventory.PickupSound "misc/health_pkup";
		Tag "Crate";
		Radius 16;
		Height 16;
		+DONTGIB
		+INVENTORY.NEVERRESPAWN
	}
	States
	{
	Spawn:
		PSTR A -1;
		Stop;
	Plain:
		MEDI A -1;
		Stop;
	}
	void Look()
	{
		voxel = Wads.CheckNumForName("PSTRA", Wads.ns_voxels) >= 0;
		if (voxel) A_SetTranslation('RSQSM_DownCrate');
		else SetStateLabel("Plain");
	}
	override bool TryPickup(in out Actor toucher)
	{
		let d = RSQSM_Down.Get();
		if (!d || !toucher || !toucher.player) return false;
		int n = toucher.PlayerNumber();
		if (n != forPlayer || !d.IsDown(n)) return false;
		d.CrateTaken(n);
		GoAwayAndDie();
		return true;
	}
}
