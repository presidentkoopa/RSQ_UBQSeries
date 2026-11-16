// ============================================================================
// RSQ_Miniboss -- MINIBOSS KILLS TIER UP MONSTERS (owner 2026-11-15 19:41: "every miniboss we kill, tiers up monsters 1,
// and we have that as an on / off. just for now so I have something to play"; 19:22: the words "like our other ones
// saying Boss Defeated! and then Enemy Tier Up!"). rsqmb_tierup, ON.
//
//   THE WIN        a called-in fight's MINIBOSS killed by a player (handler.zs BossDied with a killer: the same win
//                  BfPayoff counts). A thrall's death, a miniboss killed by something that is not a player, or removed
//                  without dying, counts nothing.
//   THE WORDS      "BOSS DEFEATED!" (MINIBOSS DEFEATED! before 2026-11-16) in gold over where it died at once; a beat later (TU_BEAT) "ENEMIES TIER UP!" in
//                  red above it, both RSQ VisualRewards' held words (RSQVR_Service "word.hold", size TU_SIZE),
//                  on a small anchor left where it died (its body may be gone by then: Brutal Doom's deaths remove it).
//                  The anchor goes after TU_LIFE tics and the words fade with it.
//   THE TIER-UP    on that beat RSQ Monsters' world tier (its server cvar rsq_mon_worldtier, "World Tier (test)", set BY
//                  NAME: this pack still loads alone) goes up by 1, at most 13 (White). RSQ Monsters itself makes every
//                  living monster on the map follow, with its tier flash (RS_BDTier.zs WorldTick). Already at 13: no
//                  tier-up and no tier-up word. RSQ Monsters not loaded, or its ladder off (rsq_mon_bdtier): nothing at all.
//   JUST FOR NOW   the world tier is a saved setting today: it carries into the next game until it is reset on RSQ
//                  Monsters' page (World Tier (test)).
//
// THE WIN AND THE LOSS (design/DOWN_LIVES_MINIBOSS_TIERS.md 4, owner 2026-11-16; BANNERS_AND_HUD.md 3 and 6). Player-facing
// words say BOSS (owner: "player-facing it should be called Boss"); code and cvars keep "miniboss".
//   WIN          the above (BOSS DEFEATED!, ENEMIES TIER UP!, world tier +1), RSQ VisualRewards' BOSSWIN banner (by name,
//                "banner" "BOSSWIN|tierup:<the new world tier>"), and RSQ Score's LIFE CRATE (RSQ_ScoreLifeCrate, asked by name only
//                when Score is loaded) where the miniboss died: gold, there until it is taken, floating back up if it
//                falls out of reach (Score lifecrate.zs); touching it is +1 Score life (+1UP).
//   LOSS         a Score life SPENT during the fight (Score's "lives" read by name every tic: the count drops while the
//                player lives; a failed DOWN's, or a killing hit no monster dealt), or leaving the map with the fight on:
//                the miniboss and its thralls leave on RSQ VisualRewards' beams (asked by name; without them teleport fog)
//                and are removed (not killed: no legendary, no drops, no kill). BOSS WINS! in red where the miniboss
//                stood, a beat later ENEMIES TIER DOWN! and the world tier -1 (at least 1); the BOSSLOSS banner
//                ("tierdown:<the new world tier>|nolegendary:"). Leaving the map: the tier goes down at once, no words; the banner shows
//                on the next map (RSQMB_Meter.lossTier travels with the player). "Miniboss Kills Tier Up Monsters"
//                (rsqmb_tierup) is the one switch for the +1 and the -1 (rule doc 5).
//   A FIGHT IS ON from its bind (the set piece bound) until its miniboss dies; a landing still in progress (its 5 s) is not
//                counted (my reading: nothing has been fought yet). Dying with no life: nothing is counted (the reload).
// ============================================================================

class RSQMB_WordSpot : Actor
{
	int life;
	Default { Radius 1; Height 16; +NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +NOTIMEFREEZE; RenderStyle "None"; }
	override void Tick() { if (--life <= 0) Destroy(); }
	States { Spawn: TNT1 A -1; Stop; }
}

extend class RSQMB_Handler
{
	const TU_BEAT = 35;           // tics from "BOSS DEFEATED!" (or "BOSS WINS!") to the tier change and its word
	const TU_LIFE = 175;          // tics the anchor (and so its words) stays
	const TU_SIZE = 1.2;          // VisualRewards' word size (1 its monster words; 2, TARGET!'s, ran past a 90-degree view at
	                              // the owner's Word Size 1.5 for these 18 letters: rig run tuA)
	const RGB_DEFEATED = 0xFFC830;
	const RGB_TIERUP = 0xFF3020;

	Array<int> tuAt;              // a tier-up due at that tic (one a miniboss killed)
	Array<RSQMB_WordSpot> tuSpot; // ...and the anchor its word goes on

	// RSQ Monsters' world tier cvar, or null when it is absent or its ladder is switched off (then nothing happens)
	static CVar TuWorld()
	{
		let on = CVar.FindCVar('rsq_mon_bdtier');
		if (on && !on.GetBool()) return null;
		return CVar.FindCVar('rsq_mon_worldtier');
	}

	// BossDied (handler.zs), after the payoff
	void TierUpOnKill(RSQMB_Boss b, Actor killer)
	{
		if (!b || !killer || !killer.player) return;
		DropLifeCrate(b);
		let wc0 = TuWorld();
		bool up = CI('rsqmb_tierup', 1) != 0 && wc0 && wc0.GetInt() < TOP_TIER;
		Banner(up ? String.Format("BOSSWIN|tierup:%d", clamp(wc0.GetInt() + 1, 1, TOP_TIER)) : "BOSSWIN", killer);
		if (CI('rsqmb_tierup', 1) == 0) { if (debug) Console.Printf("RSQMB tier-up on kill: off (rsqmb_tierup 0)"); return; }
		let wc = TuWorld();
		if (!wc) { if (debug) Console.Printf("RSQMB tier-up on kill: no RSQ Monsters world tier (not loaded, or its ladder off): nothing"); return; }
		RSQMB_WordSpot spot = null;
		let mb = b.mb;
		if (mb)
		{
			spot = RSQMB_WordSpot(Actor.Spawn("RSQMB_WordSpot", mb.pos, NO_REPLACE));
			if (spot)
			{
				spot.life = TU_LIFE;
				spot.Height = max(mb.Height, mb.default.Height);
				WordHold("BOSS DEFEATED!", RGB_DEFEATED, TU_SIZE, spot);
			}
		}
		tuAt.Push(level.maptime + TU_BEAT);
		tuSpot.Push(spot);
		if (debug) Console.Printf("RSQMB tier-up on kill t%d: miniboss %s killed by a player, world tier %d now, +1 in %d tics",
			level.maptime, mb ? mb.GetClassName() : 'gone', wc.GetInt(), TU_BEAT);
	}

	// WorldTick (handler.zs)
	void TierUpTick()
	{
		for (int i = 0; i < tuAt.Size(); i++)
		{
			if (level.maptime < tuAt[i]) continue;
			let spot = tuSpot[i];
			tuAt.Delete(i); tuSpot.Delete(i); i--;
			TierUpNow(spot);
		}
	}

	// the world tier +1 (at most White, 13); the word on the anchor when there is one
	void TierUpNow(Actor spot)
	{
		let wc = TuWorld();
		if (!wc) return;
		int was = wc.GetInt();
		if (was >= TOP_TIER)
		{
			if (debug) Console.Printf("RSQMB tier-up on kill t%d: world tier %d, already at the top (%d): no tier-up", level.maptime, was, TOP_TIER);
			return;
		}
		int now = max(1, was + 1);
		wc.SetInt(now);   // (a server cvar: the engine applies it a tic later, and RSQ Monsters' followers within 8 more)
		if (spot) WordHold("ENEMIES TIER UP!", RGB_TIERUP, TU_SIZE, spot);
		if (debug) Console.Printf("RSQMB tier-up on kill t%d: world tier %d -> %d (%s)", level.maptime, was, now, TierText(now));
	}

	// leaving the level with a tier-up still due: it is given now (no word)
	void TierUpFlush()
	{
		for (int i = 0; i < tuAt.Size(); i++) TierUpNow(null);
		tuAt.Clear(); tuSpot.Clear();
	}

	// ---- THE WIN'S 1UP: RSQ Score's life crate where the miniboss died (BANNERS_AND_HUD.md 6) ---------------------------
	void DropLifeCrate(RSQMB_Boss b)
	{
		Name cn = 'RSQ_ScoreLifeCrate';
		class<Actor> cc = cn;
		if (!cc) { if (debug) Console.Printf("RSQMB win: no life crate (RSQ Score not loaded)"); return; }
		let mb = b.mb;
		if (!mb) { if (debug) Console.Printf("RSQMB win: no life crate (the miniboss's body is gone: no spot)"); return; }
		let c = Actor.Spawn(cc, mb.pos, NO_REPLACE);
		if (debug) Console.Printf("RSQMB win t%d: RSQ Score's life crate %s at %.0f %.0f %.0f (where %s died)", level.maptime,
			c ? "dropped" : "could not spawn", mb.pos.x, mb.pos.y, mb.pos.z, mb.GetClassName());
	}

	// ---- RSQ VisualRewards' Arcade Gold banners (the contract: design/BANNERS_AND_HUD.md "Banner service contract") --------
	void Banner(String what, Actor pmo)
	{
		let s = VrService();
		int r = (s && pmo) ? s.GetInt("banner", what, 0, 0, pmo) : -9;
		if (debug) Console.Printf("RSQMB banner \"%s\" -> %s", what, s ? String.Format("%d", r) : "no RSQ VisualRewards");
	}

	// ---- THE FIGHT'S DOWN TARGET (RSQMB_Service GetObject "fight.target"; RSQ SlowMo asks) -------------------------------
	clearscope Actor FightTarget(Actor pmo)
	{
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done || !b.mb || b.mb.health <= 0) continue;
			Actor best = null;
			double bd = 1e12;
			for (int k = 0; k < b.thr.Size(); k++)
			{
				let t = b.thr[k];
				if (!t || t.health <= 0 || b.thrState[k] != RSQMB_Boss.ST_ALIVE) continue;
				double d = pmo ? pmo.Distance3D(t) : 0;
				if (d < bd) { bd = d; best = t; }
			}
			return best ? best : b.mb;
		}
		return null;
	}
	clearscope bool FightOn()
	{
		for (int i = 0; i < bosses.Size(); i++) { let b = bosses[i]; if (b && !b.done && b.mb && b.mb.health > 0) return true; }
		return false;
	}

	// ---- THE LOSS --------------------------------------------------------------------------------------------------------
	const OUT_TICS = 10;          // tics a monster stays (hidden by its beam) before it is removed
	int livesSeen[MAXPLAYERS];    // RSQ Score's lives last tic (-1 unknown)
	bool livesInit;
	Array<Actor> outMon;          // leaving on a beam: removed at outAt
	Array<int> outAt;
	Array<int> tdAt;              // a tier-down due at that tic (a fight lost)
	Array<RSQMB_WordSpot> tdSpot;

	// WorldTick (handler.zs): a Score life spent while a fight is on; the beams' removals; the tier-downs due; a loss
	// carried over from the last map
	void LossTick()
	{
		if (!livesInit) { livesInit = true; for (int n = 0; n < MAXPLAYERS; n++) livesSeen[n] = -1; }
		if (!svcChecked) FindServices();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			int lv = scoreSvc ? scoreSvc.GetInt("lives", "", 0, 0, pmo) : -1;
			bool spent = lv >= 0 && livesSeen[n] >= 0 && lv < livesSeen[n] && pmo.health > 0 && players[n].playerstate != PST_DEAD;
			livesSeen[n] = lv;
			if (spent && FightOn()) FightLost(pmo, String.Format("player %d spent a Score life (%d left)", n, lv), false);
			// a fight lost by leaving the last map: its banner now that this one is under way
			let m = MeterOf(pmo);
			if (m && m.lossTier != 0 && level.maptime >= 20)
			{
				Banner(m.lossTier > 0 ? String.Format("BOSSLOSS|tierdown:%d|nolegendary:", m.lossTier) : "BOSSLOSS|nolegendary:", pmo);
				m.lossTier = 0;
			}
		}
		for (int i = outMon.Size() - 1; i >= 0; i--)
		{
			if (level.maptime < outAt[i]) continue;
			let a = outMon[i];
			outMon.Delete(i); outAt.Delete(i);
			if (a && !a.bDestroyed) { a.ClearCounters(); a.Destroy(); }
		}
		for (int i = 0; i < tdAt.Size(); i++)
		{
			if (level.maptime < tdAt[i]) continue;
			let spot = tdSpot[i];
			tdAt.Delete(i); tdSpot.Delete(i); i--;
			TierDownNow(spot);
		}
	}

	// the fight is lost: every fight that is on ends, its monsters leave on beams; the words, the tier -1, the banner
	void FightLost(Actor pmo, String why, bool leaving)
	{
		RSQMB_WordSpot spot = null;
		int left = 0;
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done) continue;
			let mb = b.mb;
			if (!leaving && mb && !spot)
			{
				spot = RSQMB_WordSpot(Actor.Spawn("RSQMB_WordSpot", mb.pos, NO_REPLACE));
				if (spot) { spot.life = TU_LIFE; spot.Height = max(mb.Height, mb.default.Height); }
			}
			b.Finish();
			if (b.enraged) EndRage(b);
			if (bfBoss == b) bfBoss = null;
			if (!leaving)
			{
				if (mb && mb.health > 0) { BeamOut(mb, int(b.col) & 0xFFFFFF, true); left++; }
				for (int k = 0; k < b.thr.Size(); k++) { let t = b.thr[k]; if (t && t.health > 0) { BeamOut(t, int(b.col) & 0xFFFFFF, false); left++; } }
			}
		}
		bfLastTic = level.maptime;
		WindowEndNow();
		if (!leaving) SceneMusic(false);
		bool on = CI('rsqmb_tierup', 1) != 0;
		let wc = TuWorld();
		int was = wc ? wc.GetInt() : 0;
		int now = (on && wc) ? max(1, was - 1) : was;
		if (debug) Console.Printf("RSQMB FIGHT LOST t%d (%s)%s: %d monster(s) leave on beams, no legendary; world tier %d -> %d%s", level.maptime, why,
			leaving ? " by leaving the map" : "", left, was, now, !on ? " (rsqmb_tierup off: no change)" : (!wc ? " (no RSQ Monsters world tier)" : ""));
		if (leaving)
		{
			if (on && wc && now != was) wc.SetInt(now);
			for (int n = 0; n < MAXPLAYERS; n++)
			{
				if (!playeringame[n] || !players[n].mo) continue;
				let m = MeterOf(players[n].mo, true);
				if (m) m.lossTier = (now != was) ? now : -1;
			}
			return;
		}
		if (spot) WordHold("BOSS WINS!", RGB_TIERUP, TU_SIZE, spot);
		Banner(now != was ? String.Format("BOSSLOSS|tierdown:%d|nolegendary:", now) : "BOSSLOSS|nolegendary:", pmo);
		if (on && wc && now != was) { tdAt.Push(level.maptime + TU_BEAT); tdSpot.Push(spot); }
	}

	// one monster leaves: RSQ VisualRewards' beam hides it now (the miniboss V4, a thrall V1), it is removed OUT_TICS later;
	// without the beams: teleport fog and removed now. Held still meanwhile (dormant, unhurtable).
	void BeamOut(Actor a, int rgb, bool boss)
	{
		ArrowClear(a);
		WordClear("TARGET!", a);
		let vr = VrService();
		int r = vr ? vr.GetInt("beam", boss ? "v4" : "v1", rgb, 1.0, a, boss ? 'miniboss' : 'thrall') : 0;
		if (debug) Console.Printf("RSQMB leaves t%d: %s %s, %s", level.maptime, boss ? "the miniboss" : "a thrall", a.GetClassName(),
			r > 0 ? String.Format("on a beam, removed in %d tics", OUT_TICS) : "teleport fog (no beam), removed now");
		if (r <= 0)
		{
			Actor.Spawn("TeleportFog", a.pos, ALLOW_REPLACE);
			a.ClearCounters();
			a.Destroy();
			return;
		}
		a.bDORMANT = true; a.bINVULNERABLE = true; a.bSHOOTABLE = false;
		a.vel = (0, 0, 0);
		outMon.Push(a); outAt.Push(level.maptime + OUT_TICS);
	}

	// the world tier -1 (at least 1); its word on the anchor
	void TierDownNow(Actor spot)
	{
		let wc = TuWorld();
		if (!wc) return;
		int was = wc.GetInt();
		int now = max(1, was - 1);
		if (now == was) return;
		wc.SetInt(now);
		if (spot) WordHold("ENEMIES TIER DOWN!", RGB_TIERUP, TU_SIZE, spot);
		if (debug) Console.Printf("RSQMB fight lost t%d: world tier %d -> %d (%s)", level.maptime, was, now, TierText(now));
	}

	// leaving the level: a fight on is lost (the tier -1 now); a tier-down still due is given now (no word)
	void LossOnLeave(WorldEvent e)
	{
		for (int i = 0; i < tdAt.Size(); i++) TierDownNow(null);
		tdAt.Clear(); tdSpot.Clear();
		if (e.NextMap != "" && FightOn())
		{
			Actor p = null;
			for (int n = 0; n < MAXPLAYERS && !p; n++) if (playeringame[n]) p = players[n].mo;
			FightLost(p, String.Format("left the map for %s with the fight on", e.NextMap), true);
		}
	}
}
