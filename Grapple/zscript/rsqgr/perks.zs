// THE HOOK'S UPGRADES (Gun Bonsai VR / Offhand patch, asked by NAME) and THE HOOK'S XP LEDGER.
//
// NO LINK EITHER WAY. The patch's player perks are read through RSQ_MeleeUpgradeService
// "plevel" (ServiceIterator, a string), once a second per player, exactly as RSQ_DistanceGrab
// reads Long Arm and friends (RSQDG_Perks). Without the patch every level is 0, every factor is
// 1 and every hook below returns at once: the grapple is exactly what it was.
//
// WHAT EACH LEVEL DOES HERE (the patch only stores, offers and shows them):
//   LongLine     the claw flies 20% further a level                      (Fire: range)
//   FastReel     FASTER CLAW + HARDER YANK (owner 11-03): the claw's flight, the OG fling (Wall Hook: OG) and the OG
//                yank (Monster Hook: OG) 10% faster a level, 4 levels (x1.4); the rope modes' reel and slide too
//   HeavyHaul    the mass limits x(1 + 0.5 lv), the yank's size limits +15% a level; a boss
//                (or anything too heavy to come) bitten is staggered 10 + 10 lv tics, once
//                per 3 s per monster
//   GetOverHere  what the hook brings to you arrives staggered 20 + 15 lv tics
//   Bowling      what the hook brings to you strikes what is in its way: 5 + 5 lv + half its
//                speed, staggered 15 + 10 lv, shoved aside -- and it comes on
//   BarbedClaw   the bite does 4 + 4 lv, tearing it out of a living monster 6 + 6 lv
//   Slingshot    letting go of a swing in the air: speed x(1 + 0.1 lv)
//   SteadyLine   hanging with the stick centred, the swing's air drag x(1 + 3 lv)
//   DoubleHook   one monster on each hand's hook: they are slammed into each other,
//                20 + 15 lv each and staggered 35 + 15 lv
// GBOVR_TREES.md 4.6 (11-02) added:
//   Grapple      THE UNLOCK: with the patch loaded the hook fires only once it is learned (core's Fire)
//   Momentum     THE UNLOCK of Swing and Momentum: with the patch, this node is the rsqgr_swing row (SwingMode)
//   ZipKick      arriving on a monster via the rope at 3 m/s or more hurts it 10 + 10 lv, x your speed over 3 m/s
//                (up to x3), and knocks it on (ZipTick)
//   Scorpion     a monster the hook brings to you is punched at full power by an empty fist, x1 + 0.25 lv, as a
//                counter (RSQ Melee's "autopunch"; OnArrive)
//   TwinLines    a wall rope from each hand at once: without it, under the patch, one at a time; 1 both, and holding
//                one's reel pulls you toward that one (core's PullAll); 2 letting one go flings you along the other
//
// The stagger is the patch's own (RSQ_MeleeUpgradeService "stagger": its RSQ_Dazed, the one
// the gloves, the Force pull and Executioner already use), so a hooked monster is a staggered
// monster to the rest of the patch too.
//
// THE LEDGER (what the patch pays XP for, by asking: see Ask). Per player, counters that only
// grow during a map: bites, yanks, units swung (airborne on a latched rope, at most
// SWING_CAP a latch), kills the hook was in on (a monster hooked, thrown, bowled or slammed by
// that player in the last 3 s) and their spawn health. And one bracket: `dealing` is the player
// number + 1 while the hook's own damage is being dealt (Hurt), so Gun Bonsai can pay it to the
// player pool instead of the gun in the main hand. Saved with the level; a new map starts at 0
// on both sides.
class RSQGR_Perks : EventHandler
{
	const NLOG = 32;
	const INVOLVED_TICS = 105;
	const SWING_CAP = 1280.0;
	const NSLAM = 8;
	const REEL_STEP = 0.10;   // Fast Reel, a level (owner 11-03: "faster claw + harder yank"; was 0.15 of the slide)

	// ---- levels (transient: asked again on the first use after a load) --------------------
	transient int pkTic[MAXPLAYERS];
	transient int lvLine[MAXPLAYERS], lvReel[MAXPLAYERS], lvHaul[MAXPLAYERS], lvGoh[MAXPLAYERS], lvBowl[MAXPLAYERS];
	transient int lvBarb[MAXPLAYERS], lvSling[MAXPLAYERS], lvSteady[MAXPLAYERS], lvDouble[MAXPLAYERS];
	transient int lvGrapple[MAXPLAYERS], lvMomentum[MAXPLAYERS], lvZip[MAXPLAYERS], lvScorp[MAXPLAYERS], lvTwin[MAXPLAYERS];
	transient bool patchOn;		// the patch answers (the unlocks gate only then)
	// ZIP KICK: the last tic a rope held this player, the speed he had a tic ago, and who it struck lately
	int ropeTic[MAXPLAYERS];
	double lastSpd[MAXPLAYERS];
	Actor zkA[NLOG];
	int zkTic[NLOG];

	// ---- the ledger --------------------------------------------------------------------------
	int xBites[MAXPLAYERS], xYanks[MAXPLAYERS], xKills[MAXPLAYERS], xKillHP[MAXPLAYERS], xSlams[MAXPLAYERS];
	double xSwing[MAXPLAYERS];
	double swingThis[MAXPLAYERS * 2];
	RSQGR_Hook swingHook[MAXPLAYERS * 2];
	Vector3 lastPos[MAXPLAYERS];
	bool hadPos[MAXPLAYERS];
	Actor lgA[NLOG];
	int lgPn[NLOG], lgTic[NLOG];
	int dealing;
	// Heavy Haul's cooldown and Bowling's "struck already" (actor, until-tic)
	Actor cdA[NLOG];
	int cdTic[NLOG];
	Actor bwA[NLOG], bwBy[NLOG];
	int bwTic[NLOG];
	// Double Hook: pairs being slammed together
	Actor slA[NSLAM], slB[NSLAM];
	PlayerPawn slBy[NSLAM];
	int slLv[NSLAM], slAge[NSLAM];

	static clearscope RSQGR_Perks Get() { return RSQGR_Perks(EventHandler.Find("RSQGR_Perks")); }

	// ---- levels -------------------------------------------------------------------------------

	static play int Lv(PlayerPawn pmo, Name what)
	{
		let me = Get();
		if (!me || !pmo || !pmo.player) return 0;
		int pn = pmo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS) return 0;
		me.Refresh(pn, pmo);
		switch (what)
		{
		case 'LongLine':    return me.lvLine[pn];
		case 'FastReel':    return me.lvReel[pn];
		case 'HeavyHaul':   return me.lvHaul[pn];
		case 'GetOverHere': return me.lvGoh[pn];
		case 'Bowling':     return me.lvBowl[pn];
		case 'BarbedClaw':  return me.lvBarb[pn];
		case 'Slingshot':   return me.lvSling[pn];
		case 'SteadyLine':  return me.lvSteady[pn];
		case 'DoubleHook':  return me.lvDouble[pn];
		case 'Grapple':     return me.lvGrapple[pn];
		case 'Momentum':    return me.lvMomentum[pn];
		case 'ZipKick':     return me.lvZip[pn];
		case 'Scorpion':    return me.lvScorp[pn];
		case 'TwinLines':   return me.lvTwin[pn];
		}
		return 0;
	}

	// AN UNLOCK'S STATE, clearscope (read from the cache WorldTick keeps fresh): -1 without the patch (the mod's own rows
	// decide), else that player's level of it. 'Momentum' and 'TwinLines' are read here.
	static clearscope int Gate(PlayerPawn pmo, Name what)
	{
		let me = Get();
		if (!me || !me.patchOn || !pmo || !pmo.player) return -1;
		int pn = pmo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS) return -1;
		if (what == 'Momentum') return me.lvMomentum[pn];
		if (what == 'TwinLines') return me.lvTwin[pn];
		if (what == 'Grapple') return me.lvGrapple[pn];
		return -1;
	}
	// THE GRAPPLE UNLOCK: with the patch loaded and the node not learned, the hook does not fire
	static play bool Locked(PlayerPawn pmo)
	{
		let me = Get();
		if (!me || !pmo || !pmo.player) return false;
		me.Refresh(pmo.PlayerNumber(), pmo);
		return me.patchOn && me.lvGrapple[pmo.PlayerNumber()] < 1;
	}

	void Refresh(int pn, PlayerPawn pawn)
	{
		if (pkTic[pn] > 0 && level.maptime < pkTic[pn] && level.maptime >= pkTic[pn] - 35) return;
		pkTic[pn] = level.maptime + 35;
		lvLine[pn] = 0; lvReel[pn] = 0; lvHaul[pn] = 0; lvGoh[pn] = 0; lvBowl[pn] = 0;
		lvBarb[pn] = 0; lvSling[pn] = 0; lvSteady[pn] = 0; lvDouble[pn] = 0;
		lvGrapple[pn] = 0; lvMomentum[pn] = 0; lvZip[pn] = 0; lvScorp[pn] = 0; lvTwin[pn] = 0;
		let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
		let svc = it.Next();
		patchOn = svc != null;
		if (!svc) return;
		lvGrapple[pn]  = max(0, svc.GetInt("plevel", "Grapple", 0, 0, pawn));
		lvMomentum[pn] = max(0, svc.GetInt("plevel", "SwingMomentum", 0, 0, pawn));
		lvZip[pn]      = max(0, svc.GetInt("plevel", "ZipKick", 0, 0, pawn));
		lvScorp[pn]    = max(0, svc.GetInt("plevel", "Scorpion", 0, 0, pawn));
		lvTwin[pn]     = max(0, svc.GetInt("plevel", "TwinLines", 0, 0, pawn));
		lvLine[pn]   = max(0, svc.GetInt("plevel", "LongLine", 0, 0, pawn));
		lvReel[pn]   = max(0, svc.GetInt("plevel", "FastReel", 0, 0, pawn));
		lvHaul[pn]   = max(0, svc.GetInt("plevel", "HeavyHaul", 0, 0, pawn));
		lvGoh[pn]    = max(0, svc.GetInt("plevel", "GetOverHere", 0, 0, pawn));
		lvBowl[pn]   = max(0, svc.GetInt("plevel", "Bowling", 0, 0, pawn));
		lvBarb[pn]   = max(0, svc.GetInt("plevel", "BarbedClaw", 0, 0, pawn));
		lvSling[pn]  = max(0, svc.GetInt("plevel", "Slingshot", 0, 0, pawn));
		lvSteady[pn] = max(0, svc.GetInt("plevel", "SteadyLine", 0, 0, pawn));
		lvDouble[pn] = max(0, svc.GetInt("plevel", "DoubleHook", 0, 0, pawn));
	}

	// A setting grown by a level (1 without the patch).
	static play double Factor(PlayerPawn pmo, Name what)
	{
		switch (what)
		{
		case 'range': return 1.0 + 0.20 * Lv(pmo, 'LongLine');
		case 'reel':  return 1.0 + REEL_STEP * Lv(pmo, 'FastReel');   // Fast Reel: claw, fling, yank (and the rope modes)
		case 'mass':  return 1.0 + 0.50 * Lv(pmo, 'HeavyHaul');
		case 'size':  return 1.0 + 0.15 * Lv(pmo, 'HeavyHaul');
		}
		return 1.0;
	}

	// Steady Line: extra drag on the swing, only while the stick is centred (a pump still pumps).
	static play double SteadyDrag(PlayerPawn pmo, double baseDrag, bool stickCentred)
	{
		int lv = stickCentred ? Lv(pmo, 'SteadyLine') : 0;
		return lv > 0 ? baseDrag * (3.0 * lv) : 0.0;
	}

	// ---- the bracket and the ledger -----------------------------------------------------------

	// The hook's own damage. Everything the hook hurts goes through here, so Gun Bonsai (asking
	// "hook.dealing") pays it to the player pool, and a kill it makes is the hook's.
	static play int Hurt(Actor victim, Actor inflictor, Actor src, int dmg, Name mod, int flags = 0)
	{
		if (!victim || dmg <= 0) return 0;
		let me = Get();
		let p = PlayerPawn(src);
		int keep = me ? me.dealing : 0;
		if (me && p && p.player) { me.dealing = p.PlayerNumber() + 1; me.Note(victim, p); }
		int r = victim.DamageMobj(inflictor, src, dmg, mod, flags);
		if (me) me.dealing = keep;
		return r;
	}

	// This player's hook is in on this monster now.
	void Note(Actor a, PlayerPawn p)
	{
		if (!a || !p || !p.player) return;
		int pn = p.PlayerNumber();
		int k = -1, oldest = -1;
		for (int i = 0; i < NLOG; i++)
		{
			if (lgA[i] == a) { k = i; break; }
			if (k < 0 && !lgA[i]) k = i;
			if (oldest < 0 || lgTic[i] < lgTic[oldest]) oldest = i;
		}
		if (k < 0) k = oldest;
		lgA[k] = a; lgPn[k] = pn; lgTic[k] = level.maptime;
	}

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		for (int i = 0; i < NLOG; i++)
		{
			if (lgA[i] != a) continue;
			lgA[i] = null;
			int pn = lgPn[i];
			if (level.maptime - lgTic[i] > INVOLVED_TICS || !a.bIsMonster || pn < 0 || pn >= MAXPLAYERS) return;
			xKills[pn]++;
			xKillHP[pn] += max(1, a.GetSpawnHealth());
			if (RSQGR_Util.Flag("rsqgr_debug", false))
				Console.Printf("T_GRP kill p%d %s hp %d (kills %d)", pn, a.GetClassName(), a.GetSpawnHealth(), xKills[pn]);
			return;
		}
	}

	// What the patch asks, through RSQGR_Service (service.zs forwards "xp.*" and "hook.dealing").
	int Ask(String request, Object about)
	{
		let a = Actor(about);
		if (request.Left(3) ~== "xp." || request ~== "hook.dealing")
		{
			let p = PlayerPawn(a);
			if (!p || !p.player) return -1;
			int pn = p.PlayerNumber();
			if (pn < 0 || pn >= MAXPLAYERS) return -1;
			if (request ~== "hook.dealing") return dealing == pn + 1 ? 1 : 0;
			if (request ~== "xp.bites") return xBites[pn];
			if (request ~== "xp.yanks") return xYanks[pn];
			if (request ~== "xp.kills") return xKills[pn];
			if (request ~== "xp.killhp") return xKillHP[pn];
			if (request ~== "xp.slams") return xSlams[pn];
			if (request ~== "xp.swing") return int(xSwing[pn]);
		}
		return -1;
	}

	// ---- the tic: swing distance, who is on a line now, Double Hook's slams ------------------

	override void WorldTick()
	{
		let core = RSQGR_Core.Get();
		let fl = RSQGR_Flight.Get();
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo) { hadPos[pn] = false; continue; }
			double moved = hadPos[pn] ? (pmo.Pos - lastPos[pn]).Length() : 0;
			if (moved > 64) moved = 0;   // a teleport, not a swing
			lastPos[pn] = pmo.Pos;
			hadPos[pn] = true;
			Refresh(pn, pmo);   // once a second at most: SwingMode and the Twin Lines gate read the cache
			if (!core) continue;
			ZipTick(core, pmo, pn);
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			for (int hand = 0; hand < 2; hand++)
			{
				int i = pn * 2 + hand;
				let h = core.hooks[i];
				if (!h) { swingHook[i] = null; continue; }
				if (h != swingHook[i]) { swingHook[i] = h; swingThis[i] = 0; }
				if (h.phase == RSQGR_Hook.PH_LATCH && !grounded && moved > 0 && swingThis[i] < SWING_CAP)
				{
					double add = min(moved, SWING_CAP - swingThis[i]);
					swingThis[i] += add;
					xSwing[pn] += add;
				}
				if (h.victim && (h.phase == RSQGR_Hook.PH_BITE || h.phase == RSQGR_Hook.PH_LATCH || h.phase == RSQGR_Hook.PH_HOLD)) Note(h.victim, pmo);
			}
		}
		if (fl)
			for (int s = 0; s < RSQGR_Flight.NFLY; s++)
				if (fl.fph[s] != RSQGR_Flight.FP_NONE && fl.fa[s] && fl.fby[s]) Note(fl.fa[s], fl.fby[s]);
		for (int k = 0; k < NSLAM; k++) if (slA[k] || slB[k]) StepSlam(k);
	}

	// ZIP KICK: the player was on a rope within the last 10 tics, moving 3 m/s or more a tic ago, and his move this tic
	// was stopped by a monster (the players think before WorldTick, so BlockingMobj is this tic's): it is struck, hurt
	// 10 + 10 lv x his speed over 3 m/s (up to x3) and knocked on along his way. Once a second per monster.
	void ZipTick(RSQGR_Core core, PlayerPawn pmo, int pn)
	{
		for (int k = 0; k < 2; k++)
		{
			let hk = core.hooks[pn * 2 + k];
			if (hk && hk.phase == RSQGR_Hook.PH_LATCH) ropeTic[pn] = level.maptime;
		}
		// THE OG FLING counts as the rope (Wall Hook: OG, the default): a fling in the last 10 tics, or the flight it
		// started still in the air
		bool air = pmo.Pos.z > pmo.floorz + 0.5 && !pmo.bOnMobj;
		if (level.maptime - core.flungTic[pn] <= 10 || (air && level.maptime - ropeTic[pn] <= 1 && core.flungTic[pn] > 0 && level.maptime - core.flungTic[pn] < 175)) ropeTic[pn] = level.maptime;
		double was = lastSpd[pn];
		lastSpd[pn] = pmo.vel.Length();
		int lv = lvZip[pn];
		if (lv <= 0 || level.maptime - ropeTic[pn] > 10) return;
		let v = pmo.BlockingMobj;
		if (!v || !v.bIsMonster || !v.bShootable || v.health <= 0 || v.bFriendly) return;
		double ms = was * TICRATE / RSQGR_Util.Num("vr_vunits_per_meter", 34);
		if (ms < 3.0) return;
		for (int i = 0; i < NLOG; i++) if (zkA[i] == v && level.maptime - zkTic[i] < 35) return;
		int slot = 0;
		for (int i = 0; i < NLOG; i++) if (!zkA[i] || level.maptime - zkTic[i] >= 35) { slot = i; break; }
		zkA[slot] = v; zkTic[slot] = level.maptime;
		int dmg = int((10 + 10 * lv) * clamp(ms / 3.0, 1.0, 3.0));
		Vector3 dir = pmo.vel.Length() > 0.1 ? pmo.vel.Unit() : (v.pos - pmo.pos).Unit();
		Hurt(v, pmo, pmo, dmg, 'Melee', DMG_THRUSTLESS);
		if (v && v.health > 0 && !v.bDontThrust) v.vel += dir * min(was, 20.0) * clamp(100.0 / max(v.Mass, 1), 0.1, 2.0);
		let sc = ServiceIterator.Find("RS_ScoreService").Next();
		if (sc && v) sc.GetInt("touch", "zip.kick", pn, 0, v);
		if (RSQGR_Util.Flag("rsqgr_debug", false)) Console.Printf("T_GRP zip kick %s at %.1f m/s: %d", v ? v.GetClassName() : 'gone', ms, dmg);
	}

	// ---- the hooks the grapple calls ------------------------------------------------------------

	// The claw has just bitten a monster (core's Fly, after it decided bite or anchor).
	static play void OnBite(RSQGR_Hook h, Actor v)
	{
		let me = Get();
		if (!me || !h || !v || !h.owner || !h.owner.player) return;
		let pmo = h.owner;
		int pn = pmo.PlayerNumber();
		me.xBites[pn]++;
		me.Note(v, pmo);
		let fl = RSQGR_Flight.Get();
		if (fl && fl.SlotOf(v) >= 0) me.xYanks[pn]++;
		bool dbg = RSQGR_Util.Flag("rsqgr_debug", false);
		if (dbg) Console.Printf("T_GRP bite p%d h%d %s mass %d boss %d heavy %d (bites %d yanks %d)", pn, h.hand, v.GetClassName(), v.Mass, v.bBOSS, h.heavy, me.xBites[pn], me.xYanks[pn]);

		// HEAVY HAUL: a boss on the line staggers, once per 3 s
		int haul = Lv(pmo, 'HeavyHaul');
		if (h.heavy && haul > 0 && v.Health > 0 && v.bIsMonster && me.CoolOK(v))
		{
			int t = 10 + 10 * haul;
			int ok = Stagger(v, t);
			if (dbg) Console.Printf("T_GRP haul %s staggered %d tics (%d)", v.GetClassName(), t, ok);
		}
		// BARBED CLAW: the bite
		int barb = Lv(pmo, 'BarbedClaw');
		if (barb > 0 && v.Health > 0 && v.bShootable)
		{
			int hp0 = v.Health;
			Hurt(v, h, pmo, 4 + 4 * barb, 'Melee', DMG_THRUSTLESS);
			if (dbg) Console.Printf("T_GRP barb bite %s %d -> %d", v.GetClassName(), hp0, v ? v.Health : 0);
		}
		// DOUBLE HOOK: the other hand already has one coming
		int dbl = Lv(pmo, 'DoubleHook');
		if (dbl > 0 && !h.heavy && v && v.Health > 0)
		{
			let core = RSQGR_Core.Get();
			let o = core ? core.hooks[pn * 2 + (1 - h.hand)] : null;
			// (an OG throw's claw holds its victim for its 16 shut tics: PH_HOLD)
			if (o && (o.phase == RSQGR_Hook.PH_BITE || o.phase == RSQGR_Hook.PH_HOLD) && !o.heavy && o.victim && o.victim != v && o.victim.Health > 0)
				me.StartSlam(v, o.victim, pmo, dbl, h, o);
		}
	}

	// The claw is coming out (core's LetGo, before it lets go).
	static play void OnLetGo(RSQGR_Hook h, bool byPlayer)
	{
		if (!h || !h.owner || !h.owner.player) return;
		let pmo = h.owner;
		bool dbg = RSQGR_Util.Flag("rsqgr_debug", false);
		// BARBED CLAW: tearing it out of a living monster
		let v = h.victim;
		if (v && v.Health > 0 && v.bShootable && (h.phase == RSQGR_Hook.PH_BITE || h.phase == RSQGR_Hook.PH_HOLD || (h.phase == RSQGR_Hook.PH_LATCH && h.heavy)))
		{
			int barb = Lv(pmo, 'BarbedClaw');
			if (barb > 0)
			{
				int hp0 = v.Health;
				Hurt(v, h, pmo, 6 + 6 * barb, 'Melee', DMG_THRUSTLESS);
				if (dbg) Console.Printf("T_GRP barb tear %s %d -> %d", v.GetClassName(), hp0, v ? v.Health : 0);
			}
		}
		// SLINGSHOT: let go of a swing in the air and it carries you further
		if (byPlayer && h.phase == RSQGR_Hook.PH_LATCH)
		{
			int sl = Lv(pmo, 'Slingshot');
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			if (sl > 0 && !grounded)
			{
				Vector3 v0 = pmo.vel;
				pmo.vel *= 1.0 + 0.10 * sl;
				if (dbg) Console.Printf("T_GRP sling vel (%.2f %.2f %.2f) -> (%.2f %.2f %.2f)", v0.x, v0.y, v0.z, pmo.vel.x, pmo.vel.y, pmo.vel.z);
			}
		}
	}

	// What the hook brought has arrived in front of you (a landing, or the end of a slide).
	static play void OnArrive(Actor v, PlayerPawn pmo)
	{
		if (!v || !pmo || v.Health <= 0 || !v.bIsMonster) return;
		// SCORPION (Gun Bonsai VR, 4.6): an empty fist punches it at full power as a counter (RSQ Melee's "autopunch")
		int sc = Lv(pmo, 'Scorpion');
		if (sc > 0)
		{
			let ml = ServiceIterator.Find("RSQML_Service").Next();
			int done = ml ? ml.GetInt("autopunch", "", pmo.PlayerNumber(), 1.0 + 0.25 * sc, v) : 0;
			if (done > 0) { let ss = ServiceIterator.Find("RS_ScoreService").Next(); if (ss && v) ss.GetInt("touch", "scorpion", pmo.PlayerNumber(), 0, v); }
			if (RSQGR_Util.Flag("rsqgr_debug", false)) Console.Printf("T_GRP scorpion %s: punched %d", v ? v.GetClassName() : 'gone', done);
			if (!v || v.Health <= 0) return;
		}
		int goh = Lv(pmo, 'GetOverHere');
		if (goh <= 0) return;
		int t = 20 + 15 * goh;
		int ok = Stagger(v, t);
		if (RSQGR_Util.Flag("rsqgr_debug", false)) Console.Printf("T_GRP goh %s arrives staggered %d tics (%d)", v.GetClassName(), t, ok);
	}

	// BOWLING. `a` is about to be moved to `want` (its middle) by the hook. Whatever stands in
	// that spot is struck, staggered and shoved off the line, so `a` comes on. `speed` is
	// units per world tic. Returns how many it struck.
	static play int Bowl(Actor a, PlayerPawn pmo, Vector3 want, double speed)
	{
		if (!a || !pmo) return 0;
		int lv = Lv(pmo, 'Bowling');
		if (lv <= 0) return 0;
		let me = Get();
		if (!me) return 0;
		Vector2 dir = want.xy - a.Pos.xy;
		double dl = dir.Length();
		if (dl < 0.01) return 0;
		dir /= dl;
		double wantZ = want.z - a.Height * 0.5;
		int n = 0;
		let it = BlockThingsIterator.Create(a, a.Radius + dl + 16);
		while (it.Next())
		{
			let o = it.thing;
			if (!o || o == a || o == pmo || o.player || !o.bShootable || !o.bSolid || o.Health <= 0) continue;
			if ((o.Pos.xy - want.xy).Length() > a.Radius + o.Radius + 2) continue;
			if (o.Pos.z > wantZ + a.Height || o.Pos.z + o.Height < wantZ) continue;
			if (me.Struck(a, o)) continue;
			me.MarkStruck(a, o);
			n++;
			int dmg = 5 + 5 * lv + int(speed * 0.5);
			int hp0 = o.Health;
			RSQGR_Events.Struck(a, o, pmo);   // service.zs: a pin, for a scorer (noted before the blow)
			Hurt(o, a, pmo, dmg, 'Melee', DMG_THRUSTLESS);
			if (!o) continue;
			if (o.Health > 0 && o.bIsMonster) Stagger(o, 15 + 10 * lv);
			// shove it off the line, to whichever side it already leans, a little forward too
			Vector2 rel = o.Pos.xy - a.Pos.xy;
			Vector2 side = (-dir.y, dir.x);
			if ((rel dot side) < 0) side = -side;
			double need = a.Radius + o.Radius + 4 - abs(rel dot side);
			bool shoved = false;
			if (!o.bDontThrust && o.Health > 0)
			{
				for (int k = 0; k < 3 && !shoved; k++)
				{
					Vector2 to = o.Pos.xy + side * (need + 8 * k) + dir * 8;
					shoved = o.TryMove(to, 1);
					if (!shoved) { to = o.Pos.xy - side * (need + a.Radius + o.Radius + 8 * k) + dir * 8; shoved = o.TryMove(to, 1); }
				}
			}
			if (RSQGR_Util.Flag("rsqgr_debug", false))
				Console.Printf("T_GRP bowl %s -> %s speed %.1f dmg %d hp %d -> %d shoved %d", a.GetClassName(), o.GetClassName(), speed, dmg, hp0, o ? o.Health : 0, shoved);
		}
		return n;
	}

	// The patch's stagger (RSQ_Dazed), by name. 0 without the patch.
	static play int Stagger(Actor v, int tics)
	{
		let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
		let svc = it.Next();
		return svc ? svc.GetInt("stagger", "", tics, 0, v) : 0;
	}

	bool CoolOK(Actor v)
	{
		int k = -1, oldest = 0;
		for (int i = 0; i < NLOG; i++)
		{
			if (cdA[i] == v) { if (level.maptime < cdTic[i]) return false; k = i; break; }
			if (k < 0 && !cdA[i]) k = i;
			if (cdTic[i] < cdTic[oldest]) oldest = i;
		}
		if (k < 0) k = oldest;
		cdA[k] = v; cdTic[k] = level.maptime + 105;
		return true;
	}

	bool Struck(Actor by, Actor o)
	{
		for (int i = 0; i < NLOG; i++) if (bwA[i] == o && bwBy[i] == by && level.maptime < bwTic[i]) return true;
		return false;
	}
	void MarkStruck(Actor by, Actor o)
	{
		int k = 0;
		for (int i = 0; i < NLOG; i++) { if (!bwA[i] || level.maptime >= bwTic[i]) { k = i; break; } if (bwTic[i] < bwTic[k]) k = i; }
		bwA[k] = o; bwBy[k] = by; bwTic[k] = level.maptime + 35;
	}

	// ---- DOUBLE HOOK ----------------------------------------------------------------------------
	// Both claws let go of their monsters' flight or slide and the two are dragged into each
	// other along the floor (a floater meets at the other's height): 18 units per world tic each,
	// by TryMove, so a wall stops them like anything else. They meet when the move is refused by
	// the other one, or touch, or after 2 s.
	void StartSlam(Actor a, Actor b, PlayerPawn by, int lv, RSQGR_Hook ha, RSQGR_Hook hb)
	{
		int k = -1;
		for (int i = 0; i < NSLAM; i++) if (!slA[i] && !slB[i]) { k = i; break; }
		if (k < 0) return;
		let fl = RSQGR_Flight.Get();
		if (fl) { fl.Free(a); fl.Free(b); }
		let core = RSQGR_Core.Get();
		// the claws come back; their monsters are this slam's now (no tear: it is not torn out)
		ha.victim = null; hb.victim = null;
		if (core) { core.LetGo(ha, false); core.LetGo(hb, false); }
		slA[k] = a; slB[k] = b; slBy[k] = by; slLv[k] = lv; slAge[k] = 0;
		a.vel = (0, 0, 0); b.vel = (0, 0, 0);
		Stagger(a, 70); Stagger(b, 70);
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRP slam start %s <-> %s dist %.1f lv %d", a.GetClassName(), b.GetClassName(), a.Distance2D(b), lv);
	}

	void StepSlam(int k)
	{
		let a = slA[k], b = slB[k];
		let by = slBy[k];
		if (!a || !b || a.Health <= 0 || b.Health <= 0 || !by) { EndSlam(k, false); return; }
		slAge[k]++;
		double step = 18.0 * RSQGR_Core.Scale();
		bool met = a.Distance2D(b) <= a.Radius + b.Radius + 2;
		if (!met)
		{
			bool ma = MoveToward(a, b, step);
			bool mb = MoveToward(b, a, step);
			met = ma || mb || a.Distance2D(b) <= a.Radius + b.Radius + 2;
		}
		a.vel.xy = (0, 0); b.vel.xy = (0, 0);
		if (met) { EndSlam(k, true); return; }
		if (slAge[k] > 70) EndSlam(k, false);
	}

	// One step of `m` toward `to`; true when `to` is what refused it.
	bool MoveToward(Actor m, Actor to, double step)
	{
		Vector2 d = to.Pos.xy - m.Pos.xy;
		double l = d.Length();
		double gap = l - (m.Radius + to.Radius + 1);
		if (gap <= 0) return true;
		double s = min(step, gap);
		if (m.bNoGravity || m.bFloat)
		{
			double dz = (to.Pos.z + to.Height * 0.5) - (m.Pos.z + m.Height * 0.5);
			m.SetZ(clamp(m.Pos.z + clamp(dz, -s, s), m.floorz, max(m.floorz, m.ceilingz - m.Height)));
		}
		if (m.TryMove(m.Pos.xy + d / l * s, 1)) return false;
		return m.BlockingMobj == to;
	}

	void EndSlam(int k, bool met)
	{
		let a = slA[k], b = slB[k];
		let by = slBy[k];
		int lv = slLv[k];
		slA[k] = null; slB[k] = null; slBy[k] = null;
		if (!met || !a || !b || !by) return;
		int dmg = 20 + 15 * lv;
		int ha = a.Health, hb = b.Health;
		RSQGR_Events.Struck(b, a, by);   // service.zs: each struck the other (noted before the blows)
		RSQGR_Events.Struck(a, b, by);
		Hurt(a, b, by, dmg, 'Melee', DMG_THRUSTLESS);
		if (b) Hurt(b, a, by, dmg, 'Melee', DMG_THRUSTLESS);
		int st = 35 + 15 * lv;
		if (a && a.Health > 0) Stagger(a, st);
		if (b && b.Health > 0) Stagger(b, st);
		if (a) a.A_StartSound("misc/gibbed", CHAN_AUTO, 0, 0.8);
		if (by && by.player) xSlams[by.PlayerNumber()]++;
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRP slam met after %d tics: dmg %d each, hp %d -> %d and %d -> %d, staggered %d",
				slAge[k], dmg, ha, a ? a.Health : 0, hb, b ? b.Health : 0, st);
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		dealing = 0;
	}
}
