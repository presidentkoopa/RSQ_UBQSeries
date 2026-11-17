// ============================================================================
// RSQ_Miniboss -- THE FIGHT (owner 2026-11-17: the original Minibosses!' rule back, the 11-09 rework's shield, windows and
// tier-ups gone). The damage itself in items.zs (RSQMB_Ward), the set piece's state in boss.zs, the arrival in
// bossfight.zs, the HUD in bossbar.zs.
//
//   THE THRALLS     while thralls live, the Boss takes damage x (1 - 0.8 x living / the thralls it came with), in floating
//                   point (the original's integer division made it all or nothing): 20 % with every thrall up, each kill
//                   more, 100 % with none left; a multiplier on top of any damage factor it has (items.zs). The ring of FIRE
//                   round it is that shield (the original's art, fx.zs / boss.zs FxStep). "TARGET!" is held over each thrall
//                   ("word.hold"). The room's glow holds a steady cold grey (RSQGD_Service "event.tint" 8A93A6).
//   A THRALL KILLED its power leaves the miniboss (Strip: the power THAT thrall gave it, owner 06:42 "LOSE"); its marker and
//                   trail explode (the original's imp/shotx, BFE1 and APBX: fx.zs).
//   NO THRALL LEFT  one-on-one: "TARGET!" over the miniboss, the room its colour.
//   A LIFE LOST     (boss.zs LoseLife) the main bar empties, the next thin life bar rises into it; the original's 5 s of
//                   invulnerability with the FIRE ring; the room glows red, then its colour. NO COLOUR CHANGE and NO THRALLS
//                   RISE.
//   NOTHING CHANGES MID-FIGHT (owner 2026-11-17: the Boss and its thralls keep their colour and their body from landing to
//                   death): this mod asks no tier-up during a fight, of them or of the map, and HoldTiers below turns back
//                   any tier change RSQ Monsters starts on them (the World Tier moving, a console retier) before it swaps.
//   ITS DEATH       a map-wide wave in its colour (RSQGD "event.wave"), then RSQ Glow In The Dark's colours re-roll
//                   (RSQGD "event.reroll", 2 s later); Score's row as before (handler.zs BossDied; the loot is other mods', bossfight.zs BfPayoff).
//                   The World Tier +1 for a win and -1 for a loss stay (tierup.zs: after the fight).
//   MINIBOSS TIERS  (before 2026-11-17 a fight tiered monsters up) every tier this mod gave is put back when a hub level is
//                   entered again (WorldLoaded IsReopen): kept for a save from before.
// Everything is asked BY NAME (nothing links): RSQVR_Service (words, pops, beams), RSQSM_Service (arrows, the landing slow),
// RSQGD_Service (glow), RSQMN_RosterService (tiers). A mod absent: that part is skipped, quietly.
// Rig 11-09 (TestRig/bossfight_rig), not headset-confirmed.
// ============================================================================

extend class RSQMB_Handler
{
	// ---- other mods, by EXACT class name (ServiceIterator.Find matches a part of the name) --------------------------
	transient Service vrSvc, mnSvc;
	transient bool vrChecked, mnChecked;
	static Service SvcNamed(String n)
	{
		let it = ServiceIterator.Find(n);
		Service s;
		while (s = it.Next()) if (s.GetClassName() == n) return s;
		return null;
	}
	Service VrService() { if (!vrChecked) { vrChecked = true; vrSvc = SvcNamed("RSQVR_Service"); } return vrSvc; }
	Service MnService() { if (!mnChecked) { mnChecked = true; mnSvc = SvcNamed("RSQMN_RosterService"); } return mnSvc; }

	// the words (RSQVR_Service, the shared contract /tmp/contract.md 2026-11-09): "TARGET!" gold
	const RGB_TARGET = 0xFFD030;
	const RGB_SHIELDGLOW = 0x8A93A6;   // the cold grey room while a thrall stands (the mockup's event.tint value, p2)
	const RGB_LIFELOST = 0xFF2020;
	void Word(String txt, int rgb, double secs, Actor a) { let s = VrService(); if (s && a) s.GetInt("word", txt, rgb, secs, a); }
	void WordHold(String txt, int rgb, double size, Actor a) { let s = VrService(); if (s && a && a.health > 0) s.GetInt("word.hold", txt, rgb, size, a); }
	void WordClear(String txt, Actor a) { let s = VrService(); if (s && a) s.GetInt("word.clear", txt, 0, 0, a); }
	void ArrowAdd(Actor a, int rgb, double size) { if (!svcChecked) FindServices(); if (smSvc && a) smSvc.GetInt("arrow.add", "rsqmb", rgb & 0xFFFFFF, size, a); }
	void ArrowClear(Actor a) { if (!svcChecked) FindServices(); if (smSvc && a) smSvc.GetInt("arrow.clear", "rsqmb", 0, 0, a); }
	void Wave(Actor at, int rgb) { let g = GdService(); if (g && at) g.GetInt("event.wave", "", rgb & 0xFFFFFF, 0, at); }

	// ---- colours ----------------------------------------------------------------------------------------------------
	// THE RSQ LADDER (RSQ Monsters, numbered by STRENGTH since 11-11: 1 Common 2 Green 3 Blue 4 Purple 5 Cyan 6 Brown
	// 7 Yellow 8 FireBlu 9 Gray 10 Red 11 Abyss 12 Black 13 White), RS_MonsterMaster.zs RS_TierForColour's own values (its
	// "representative values"; Black shown as a dark grey so its bar is not invisible on the HUD). Each colour keeps its
	// own value; only the order changed.
	static int LadderRGB(int t)
	{
		static const int RGB[] = { 0xC8C8C8, 0x3CDC46, 0x3C78FF, 0xAA46E6, 0x3CF0F0, 0x8C5A28, 0xFFC828,
			0x28A0DC, 0x828282, 0xE62828, 0x46146E, 0x505058, 0xFFFFFF };
		return (t >= 1 && t <= 13) ? RGB[t - 1] : -1;
	}
	// a monster's RSQ ladder tier (RSQMN_RosterService "tier"; ColorfulHell), -1 not on the ladder or RSQ Monsters absent
	int TierOfMon(Actor a)
	{
		let s = MnService();
		if (!s || !a) return -1;
		int t = s.GetInt("tier", "", 0, 0, a);
		return t >= 1 ? t : -1;
	}
	// its colour: its ladder colour, else the set piece's palette colour (the original look, any other monster)
	int ColourOf(Actor a, int idx)
	{
		int c = LadderRGB(TierOfMon(a));
		if (c >= 0) return c;
		return int(PALETTE[idx % PALETTE.Size()]) & 0xFFFFFF;
	}
	// a Champions power's colour (its token's colour: SlowMo down.zs ChampColour's table; the mutations my picks)
	static int PowerRGB(String n)
	{
		static const String NAMES[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo", "Violet",
			"Pink", "Magenta", "Black", "Grey", "White", "Bronze", "Silver", "Gold", "Titan", "Undying", "Ghost", "Balloon" };
		static const int RGB[] = { 0xA01010, 0xFF2828, 0xFF8820, 0xFFE030, 0x20A030, 0x40F040, 0x30E8E8, 0x3868FF, 0x6030C0, 0xB050F0,
			0xFF88C8, 0xFF30FF, 0x707070, 0xB0B0B0, 0xF0F0F0, 0xC08040, 0xD0D0E8, 0xFFC828, 0xFF6020, 0xA0FFA0, 0xC0C0FF, 0xFF80C0 };
		for (int i = 0; i < NAMES.Size(); i++) if (NAMES[i] == n) return RGB[i];
		return -1;
	}
	// what Champions made it: a colour token (the four its own handler acts on when given by name: SlowMo down.zs Boost)
	static bool HasChampColour(Actor m)
	{
		static const String COLS[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo", "Violet",
			"Pink", "Magenta", "Black", "Grey", "White", "Bronze", "Silver", "Gold" };
		for (int i = 0; i < COLS.Size(); i++) if (Has(m, "champion_" .. COLS[i] .. "Token")) return true;
		return false;
	}
	static bool IsChampion(Actor m) { return Has(m, "champion_PersistentInfo") || HasChampColour(m); }
	// BOOSTED LEGENDARY CHAMPION (owner: "the miniboss and its thralls are the only monsters to arrive boosted legendary
	// champions"; SlowMo/zscript/rsqsm/down.zs Boost, its fallback path): Champions rolls on every new monster itself as it
	// spawns; one it did not make a champion is given a colour token by name (Yellow, White, Dark Green or Cyan: the ones
	// Champions' own handler acts on). (DOWN's full way, hidden candidates until Champions picks one, is not used: a landing
	// cannot wait for its rolls.)
	static void ChampionFallback(Actor m)
	{
		if (!m || m.health <= 0 || !Loaded("champion_Token") || IsChampion(m)) return;
		static const String TOK[] = { "Yellow", "White", "DarkGreen", "Cyan" };
		Give(m, "champion_" .. TOK[random[rsqmbbf](0, TOK.Size() - 1)] .. "Token");
	}

	// ---- the fight, every tic (WorldTick) ------------------------------------------------------------------------------
	int rerollAt;                 // RSQ Glow In The Dark's colours re-roll at this tic (after a death's wave), 0 none
	void FightTick()
	{
		int now = level.maptime;
		Follow();
		if (rerollAt > 0 && now >= rerollAt)
		{
			rerollAt = 0;
			let g = GdService();
			if (g) g.GetInt("event.reroll", "", 0, 0, null);
			if (debug) Console.Printf("RSQMB death: Glow In The Dark colours re-rolled");
		}
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done || !b.mb) continue;
			WordsStep(b);
			RoomGlow(b);
		}
	}

	// ---- a thrall killed: its power goes (its link explodes by itself: boss.zs FxStep) ----------------------------------
	void ThrallKilled(RSQMB_Boss b, int i, Actor a, Actor killer)
	{
		int pc = b.StripPowers(i, self);
		ArrowClear(a);
		b.wordState = -9;
		b.glowSent = -1;
		if (debug) Console.Printf("RSQMB thrall %d of boss %d killed: power colour %06X, living %d of %d, the boss takes x%.2f", i, b.idx, pc,
			b.Living(), b.total, b.ThrallFactor());
	}

	// ---- NOTHING IN A FIGHT CHANGES (owner 2026-11-17: "they keep their colour and their body from landing to death") -------
	// RSQ Monsters changes a monster's tier with a flash first and the swap (or its kit's new rung) 5 to 25 tics later
	// (RS_Retier: an RS_RetierJob, its own target tier). Every HOLD_EVERY tics, if any such job runs at all (one walk over the
	// thinkers), each monster of a fight that is on or landing is asked about: one with a change coming (RSQMN_RosterService
	// "tier.next") is asked back to the tier it has ("retier" with its own tier: the job's target becomes that, its wait
	// starts over, and when it fires nothing changes). It still flashes its own colour for those tics: only RSQ Monsters
	// itself could skip a fight's monsters outright. Nothing linked: by name.
	const HOLD_EVERY = 4;
	transient bool rtLooked;
	transient class<Thinker> rtJob;
	void HoldTiers()
	{
		if (level.maptime % HOLD_EVERY != 0 || (bosses.Size() == 0 && !arrPhase)) return;
		if (!rtLooked) { rtLooked = true; String jn = "RS_RetierJob"; class<Thinker> jc = jn; rtJob = jc; }
		if (!rtJob) return;
		let s = MnService();
		if (!s) return;
		let it = ThinkerIterator.Create(rtJob, Thinker.STAT_DEFAULT);
		if (!it.Next()) return;
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done) continue;
			HoldTier(s, b.mb);
			for (int k = 0; k < b.thr.Size(); k++) if (b.thrState[k] == RSQMB_Boss.ST_ALIVE) HoldTier(s, b.thr[k]);
		}
		if (arrPhase) for (int k = 0; k < arrMon.Size(); k++) HoldTier(s, arrMon[k]);
	}
	void HoldTier(Service s, Actor a)
	{
		if (!a || a.health <= 0) return;
		int nx = s.GetInt("tier.next", "", 0, 0, a);
		if (nx < 1) return;
		int t = TierOfMon(a);
		if (t < 1 || nx == t) return;
		s.GetInt("retier", "", t, 0, a);
		if (debug) Console.Printf("RSQMB t%d: RSQ Monsters began to take %s from tier %d to %d mid-fight: asked back to %d", level.maptime, a.GetClassName(), t, nx, t);
	}

	// RE-FINDING A BODY (kept for a save made before 2026-11-17, when a fight asked tier changes that swap a body; nothing asks
	// one now, so nothing is followed). RS_Retier.Swap spawns
	// the new class where the old one stood and destroys the old (its RS_RetierJob, 5-25 tics after the ask). Every monster
	// asked is followed for FOLLOW_TICS: when its pointer goes null, the new body is the living monster within a unit of where
	// it last stood whose last live tier change was this tic or the last (RSQMN_RosterService "tier.ago"). The tokens a swap
	// loses are given again (Champions' four by-name colours and Titan, LegenDoom's legendary), and a set piece's own body
	// is dressed again (boss.zs Rebody). The tier it had before the first ask is kept (tfOrig) for the hub reset.
	const FOLLOW_TICS = 140;
	Array<Actor> tfMon;
	Array<int> tfOrig, tfUntil, tfRole;
	Array<double> tfX, tfY, tfZ;
	Array<RSQMB_Boss> tfBoss;
	Array<String> tfTok;

	// a set piece's body is being swapped right now (boss.zs: do not take a null pointer for a death)
	bool Following(RSQMB_Boss b, int role)
	{
		int now = level.maptime;
		for (int k = 0; k < tfMon.Size(); k++)
			if (tfBoss[k] == b && tfRole[k] == role && !tfMon[k] && tfUntil[k] >= now) return true;
		return false;
	}

	void Follow()
	{
		int now = level.maptime;
		EnsureTf();
		for (int k = 0; k < tfMon.Size(); k++)
		{
			// a Champions record held for a body whose spawn event never came (carry.zs): let it go
			if (tfInfo[k] && (tfUntil[k] < now || (tfHeldAt[k] > 0 && now - tfHeldAt[k] > 10)))
			{
				if (!tfInfo[k].Owner) tfInfo[k].Destroy();
				tfInfo[k] = null;
				if (debug) Console.Printf("RSQMB carry: a Champions record held for %s was never claimed", tfRole[k] < 0 ? "the miniboss" : String.Format("thrall %d", tfRole[k]));
			}
			if (tfUntil[k] < now) continue;
			let a = tfMon[k];
			if (a) { if (a.health > 0) { tfX[k] = a.pos.x; tfY[k] = a.pos.y; tfZ[k] = a.pos.z; } else tfUntil[k] = 0; continue; }
			let s = MnService();
			if (!s) continue;
			// caught as it spawned (carry.zs): that one, no search
			Actor caught = tfNext[k];
			if (caught && caught.health > 0 && tfMon.Find(caught) == tfMon.Size()) { FollowGot(k, caught); continue; }
			let bi = BlockThingsIterator.CreateFromPos(tfX[k], tfY[k], tfZ[k], 64, 32, false);
			// (rig 11-09) the new body stands where the old one was on the swap tic, and a monster on the move covers up to its
			// speed (x1.25 for a miniboss) in the tic between: the nearest freshly swapped monster within 48 units, not 1
			Actor got = null;
			double best = 48.0;
			while (bi.Next())
			{
				let c = bi.thing;
				if (!c || c.health <= 0 || !c.bISMONSTER || c.player || tfMon.Find(c) < tfMon.Size()) continue;
				double d = (c.pos.xy - (tfX[k], tfY[k])).Length();
				if (d > best) continue;
				int ago = s.GetInt("tier.ago", "", 0, 0, c);
				if (ago < 0 || ago > 2) continue;
				got = c;
				best = d;
			}
			if (!got) continue;
			FollowGot(k, got);
		}
	}

	// the new body found: its tokens again, a set piece's body dressed again and made to rise (boss.zs Rebody, Reborn)
	void FollowGot(int k, Actor got)
	{
		tfMon[k] = got;
		tfNext[k] = null;
		Array<String> toks;
		String tk = tfTok[k];
		tk.Split(toks, ",", TOK_SKIPEMPTY);
		for (int i = 0; i < toks.Size(); i++)
		{
			if (toks[i] == "LDLegendaryMonsterToken") { if (!Has(got, "LDLegendaryMonsterToken")) Give(got, "LDLegendaryMonsterPickupGuaranteed"); }
			else if (!Has(got, toks[i])) Give(got, toks[i]);
		}
		let b = tfBoss[k];
		if (b && !b.done)
		{
			b.Rebody(tfRole[k], got, self);
			b.Reborn(got, tfFrac[k], tk.IndexOf("LDLegendaryMonsterToken") >= 0);
		}
		if (debug) Console.Printf("RSQMB tier swap followed: %s (%s) at %.0f %.0f, tokens again [%s]%s", got.GetClassName(),
			b ? (tfRole[k] < 0 ? "the miniboss" : String.Format("thrall %d", tfRole[k])) : "a map monster", tfX[k], tfY[k], tfTok[k],
			b ? String.Format(", Champion %s, health share %.2f", tfCarry[k] ? "carried" : "not carried (none)", tfFrac[k]) : "");
	}

	// MINIBOSS-INDUCED TIERS RESET ON A MAP CHANGE (owner 07:15): a hub level entered again puts every monster this mod tiered
	// back to the tier it had (instantly, no flash). Any other map change leaves the old map's monsters behind anyway.
	void TierReset()
	{
		let s = MnService();
		int n = 0;
		for (int k = 0; k < tfMon.Size(); k++)
		{
			let a = tfMon[k];
			if (!s || !a || a.health <= 0) continue;
			if (TierOfMon(a) != tfOrig[k] && s.GetInt("retier", "", tfOrig[k], 1, a) == 1) n++;
		}
		if (debug && tfMon.Size()) Console.Printf("RSQMB hub re-entered: %d of %d miniboss-tiered monsters put back", n, tfMon.Size());
		tfMon.Clear(); tfOrig.Clear(); tfUntil.Clear(); tfRole.Clear(); tfX.Clear(); tfY.Clear(); tfZ.Clear(); tfBoss.Clear(); tfTok.Clear();
		for (int k = 0; k < tfInfo.Size(); k++) if (tfInfo[k] && !tfInfo[k].Owner) tfInfo[k].Destroy();
		tfNext.Clear(); tfFrac.Clear(); tfCarry.Clear(); tfInfo.Clear(); tfHeldAt.Clear();
	}

	// ---- the words over them (RSQVR_Service word.hold) --------------------------------------------------------------------
	//   0 a thrall stands: "TARGET!" over each living thrall, none over the miniboss
	//   2 one-on-one (no thrall standing): "TARGET!" over the miniboss, none over thralls
	//   3 invulnerable (a life just lost): no "TARGET!" over the miniboss until it can be shot again (owner 11-10: TARGET!
	//     appears over it WHEN IT CAN BE SHOT), none over thralls
	void WordsStep(RSQMB_Boss b)
	{
		int st = b.Invulnerable() ? 3 : (b.Guarded() ? 0 : 2);
		if (st == b.wordState) return;
		b.wordState = st;
		if (st == 0 || st == 3) WordClear("TARGET!", b.mb); else WordHold("TARGET!", RGB_TARGET, 1.2, b.mb);     // (owner 11-12 14:11: "TARGET and GUARD are way too big, it's all I can see": 2.0 -> 0.8; owner 11-16 03:15, PRESENTATION_GUIDE.md 4b, "one size up": x1.5, my step -> 1.2)
		for (int i = 0; i < b.thr.Size(); i++)
		{
			let t = b.thr[i];
			if (!t) continue;
			if (b.thrState[i] != RSQMB_Boss.ST_ALIVE || st >= 2) WordClear("TARGET!", t);
			else WordHold("TARGET!", RGB_TARGET, 0.75, t);     // (11-16 one size up: 0.5 -> 0.75)
		}
	}

	// ---- the fight room's glow (RSQGD_Service "event.tint": the whole map's glow leans to it) ------------------------------
	// a thrall stands: steady cold grey; a life lost: red, then its colour; one-on-one: its colour. Sent on a change and kept
	// alive every GLOW_EVERY tics.
	const GLOW_EVERY = 10;
	void RoomGlow(RSQMB_Boss b)
	{
		int now = level.maptime;
		int col;
		double secs = 0.5;
		if (b.lifeLostAt > 0 && now - b.lifeLostAt < 20) col = RGB_LIFELOST;
		else if (b.Guarded()) col = RGB_SHIELDGLOW;
		else col = int(b.col) & 0xFFFFFF;
		if (col == b.glowSent && now - b.glowTic < GLOW_EVERY) return;
		b.glowSent = col;
		b.glowTic = now;
		Glow(col, secs);
	}

	// ---- its death: the map-wide wave in its colour, then the re-roll --------------------------------------------------------
	void FightDeath(RSQMB_Boss b)
	{
		if (b.mb) Wave(b.mb, int(b.col) & 0xFFFFFF);
		rerollAt = level.maptime + 2 * TICRATE;
		for (int i = 0; i < b.thr.Size(); i++) if (b.thr[i]) WordClear("TARGET!", b.thr[i]);
	}

}

// =====================================================================================================================
// RSQ MONSTERS > BOSSFIGHT: MINIBOSS FROM / THRALLS FROM (owner 2026-11-09 07:45, "your rules are good"; owner 06:39:
// a Brutal Doom miniboss gets tiered ColorfulHell thralls). The picks are made from the map's own monsters as before,
// then each is turned into the same family from the chosen set (RSQMN_RosterService "set.class"). Picked from a set,
// a thrall keeps the colour it had on the map (Common when it had none) and the miniboss stands at least one colour
// above its strongest thrall (Claude's rule from 06:34, the owner's "your rules are good"). Without RSQ Monsters, or
// on Same as Monster Set / Map's Own Monsters, nothing changes.
// =====================================================================================================================
extend class RSQMB_Handler
{
	// 1 ColorfulHell, -1 not on the ladder (by type)
	int ClassSet(Service s, String cls) { return s.GetInt("class.set", cls); }

	// one pick into ColorfulHell (RSQ Monsters' set 3) at a tier; the pick itself when CH has nothing for its family
	String IntoSet(Service s, String cls, int set, int tier)
	{
		String n = s.GetString("set.class", cls, set, tier);
		return n == "" ? cls : n;
	}

	// the menu value into a set: anything but Same As / Map's Own is ColorfulHell (MeatGrinder went 11-10, owner; the
	// old MeatGrinder (2) and Mixed (3) values read as ColorfulHell)
	static int SetOfMenu(int v) { return (v >= 1 && v <= 3) ? 3 : 0; }

	// THE COLOUR BONUS (owner 2026-11-11 14:07-14:12, reworked 14:51-14:55: climb the STRENGTH order). With RSQ Gun
	// Bonsai VR loaded (RSQGB_Service, by name), at the arrival tic, once, on top of the start colours above (unchanged):
	//   the miniboss  +1 tier a Gun Bonsai VR PLAYER level ("player.level"), all the way to Black (12, its boss roll may
	//                 come out EX the way RSQ Monsters rolls it: "set.class.ex") and White (13, the Shotgunner's and the
	//                 Lost Soul's EX colour);
	//   each thrall   +0.25 tier a WEAPON level, the main hand's and the off hand's Gun Bonsai VR levels added ("level",
	//                 intArg 0 / 1), rounded half up (5 levels 1.25 -> +1, 6 levels 1.5 -> +2). An empty hand, the fists,
	//                 gloves, RSQ_Hands, or a gun with no record counts 0. The bonus stops at Abyss (11): never Black, White
	//                 or EX;
	//   then          the miniboss is raised (never lowered) to one tier above its strongest thrall.
	// Only a pick on the ladder gets colours (a Brutal Doom / Vanilla pick kept as it is gets none, as before). Play code,
	// read from synced records, so every machine picks the same.
	// THE LADDER IS THE STRENGTH ORDER (owner 11-11: "the tier number IS the strength"). RSQ Monsters numbers its ladder
	// weakest first (measured 11-11 from each colour's health, mean rank over the 17 families, EX excluded;
	// Monsters/README.md "The ladder"): 1 Common, 2 Green, 3 Blue, 4 Purple, 5 Cyan, 6 Brown, 7 Yellow, 8 FireBlu, 9 Gray,
	// 10 Red, 11 Abyss, 12 Black (boss), 13 White (boss). So the bonus adds to the tier number itself; the separate
	// strength list this used before the renumber (StepOf / LadderOf) is gone. (A fight's tier-ups went 2026-11-17: nothing
	// in a fight changes colour.)
	const TOP_TIER = 13;
	const THRALL_TIER_CAP = 11;   // Abyss
	const FIRST_BOSS_TIER = 12;   // Black; 13 White

	static String ColourName(int t)
	{
		static const String N[] = { "-", "Common", "Green", "Blue", "Purple", "Cyan", "Brown", "Yellow", "FireBlu", "Gray", "Red", "Abyss", "Black", "White" };
		return t >= 1 && t <= 13 ? N[t] : "-";
	}
	static String TierText(int t) { return t > 0 ? String.Format("%s(%d)", ColourName(t), t) : "-"; }

	class<Actor> ApplyFrom(class<Actor> bc, Array<String> tc, PlayerPawn p = null)
	{
		let s = MnService();
		if (!s || !bc) return bc;
		int bfv = clamp(CI('rsq_mon_bf_boss', 0), 0, 3), tfv = clamp(CI('rsq_mon_bf_thralls', 0), 0, 4);
		String bn = bc.GetClassName();
		int bSet = SetOfMenu(bfv);   // 0: the map's own
		// Same as Miniboss: the miniboss's set; one from Brutal Doom or Vanilla (no ladder) gets ColorfulHell thralls
		int tMode = tfv;
		if (tfv == 0)
		{
			if (bSet == 3) tMode = 1;
			else tMode = ClassSet(s, bn) > 0 ? 4 : 1;
		}
		// THE COLOURS: THE WORLD TIER ONLY (design/DOWN_LIVES_MINIBOSS_TIERS.md 4, owner 2026-11-16 01:2x: "World tier only",
		// "No cap"): every thrall at world tier + 1, the miniboss at world tier + 2, on RSQ Monsters' ladder (strength order).
		// No cap but the ladder's own end (White, 13): at the top tiers they are ColorfulHell's full Black and White bosses
		// (the miniboss's boss colour takes RSQ Monsters' EX roll, as before). The old start colours (each type's own tier,
		// the miniboss one above its strongest thrall), Gun Bonsai VR's colour bonus and the Abyss cap for thralls are gone.
		// A type with no ladder (a Brutal Doom or Vanilla pick kept as it is) gets no colour here: RSQ Monsters' kit puts it
		// at the world tier itself when it spawns.
		int world = WorldTierNow();
		int thT = min(TOP_TIER, world + 1), mbT = min(TOP_TIER, world + 2);
		String fin = "";
		for (int i = 0; i < tc.Size(); i++)
		{
			int st = tMode != 4 ? SetOfMenu(tMode) : (ClassSet(s, tc[i]) > 0 ? ClassSet(s, tc[i]) : 0);
			if (st > 0) { String nn = IntoSet(s, tc[i], st, thT); if (nn != "") tc[i] = nn; }
			fin = fin .. " " .. (st > 0 ? TierText(thT) : "-");
		}
		int ms = bSet > 0 ? bSet : (ClassSet(s, bn) > 0 ? ClassSet(s, bn) : 0);
		String ex = "";
		if (ms > 0)
		{
			String nn = IntoSet(s, bn, ms, mbT);
			if (nn != "") bn = nn;
			if (mbT >= FIRST_BOSS_TIER) { ex = s.GetString("set.class.ex", bn, 3, mbT); if (ex != "") bn = ex; }
		}
		if (debug) Console.Printf("RSQMB fight colours t%d: world tier %d -> miniboss %s%s (%s), thralls%s",
			level.maptime, world, ms > 0 ? TierText(mbT) : "- (no ladder)", ex != "" ? " EX" : "", bn, fin);

		class<Actor> nc = bn;
		if (debug) Console.Printf("RSQMB Miniboss From %d / Thralls From %d: %s", bfv, tfv, nc ? bn : "(none)");
		return nc ? nc : bc;
	}

}
