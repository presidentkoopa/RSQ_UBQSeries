// ============================================================================
// RSQ_Miniboss -- THE FIGHT, REWORKED (owner + Claude 2026-11-09, design/MINIBOSS_REWORK.md; mockups
// design/mockups/miniboss/p1..p7). The rules here; the damage itself in items.zs (RSQMB_Ward), the set piece's state in
// boss.zs, the arrival in bossfight.zs, the HUD stack in hud.zs.
//
//   THE THRALL BAR  one SEGMENT per thrall it came with (b.total), each a share of the miniboss's health (its health at the
//                   bind / thralls): a pool on top of its own bar. "thralls = number of segments you have to whittle down
//                   before it's one-on-one with the miniboss itself, who has 1 full hp bar remaining" (owner).
//   SHIELD UP       while a thrall lives, a segment is left and no window is open: shots on it do NO damage. Grey Xs bounce
//                   off where they hit (items.zs RSQMB_XFx: the damage-number X, Doom's own small-font X STCFN088) and
//                   "GUARD!" pops over it (RSQVR_Service "word", silver). "TARGET!" is held over each thrall ("word.hold").
//                   The room's glow holds a steady cold grey (RSQGD_Service "event.tint" 8A93A6, the mockup's value).
//   A THRALL KILLED its power leaves the miniboss (Strip: the power THAT thrall gave it, owner 06:42 "LOSE"), a pixel pop in
//                   that power's colour (RSQVR "pop"; without it the original's break burst), the world slows (rsm_pulse,
//                   as before) and the SHIELD DROPS: a WINDOW of 1 s x the thralls it came with (owner 06:43: "three
//                   seconds if 3, four if 4, five if 5") on the first unbroken segment, closed early when that segment
//                   breaks (owner 06:42: "whichever comes first"). A big pulsing "TARGET!" over the miniboss (word.hold
//                   size 2), the thralls' shrink (0.6); the room glows gold, pulsing (steady in Photosensitive Mode).
//                   A kill while a window is open waits its turn (winCredits): the next window opens when this one closes.
//   THE WINDOW BAR  DOWN's reward bar on the HUD (hud.zs): one step a thrall, 1 s each, draining tallest first. BROKEN in
//                   time: Score pays by the step it broke in, the first the most (RS_ScoreService "award" "Thrall Slow Kill",
//                   100 x the steps left: with no kill that tic Score pays the flat points on that row).
//   WINDOW MISSED   the segment survived: the miniboss and its living thralls TIER UP by how much was left (owner 07:13: a
//                   sliver +1, about half +2, untouched +3), with RSQ Monsters' own tier flash (RSQMN_RosterService
//                   "retier", RS_Retier.Request: CH swaps the body, MG changes in place). Tier-Up Hits the Whole Map
//                   (rsqmb_tier_mapwide, ON, owner 07:15): every monster on the map RSQ Monsters can tier. The shield is
//                   back up. A CH swap destroys the body: the new one is FOUND (Follow, below) and dressed again.
//   ONE-ON-ONE      no segment left (or no thrall alive): no thrall bar, "TARGET!" over the miniboss, the room its colour.
//   A LIFE LOST     (boss.zs LoseLife) the main bar empties, the next thin life bar rises into it; it tiers up one with the
//                   flash (Tier Up Each Life, rsqmb_tier_life, ON, owner 07:28); the room glows red, then its new colour
//                   (owner 08:53). NO THRALLS RISE (owner 08:14: the original's revive is gone).
//   ITS DEATH       a map-wide wave in its colour (RSQGD "event.wave"), then RSQ Glow In The Dark's colours re-roll
//                   (RSQGD "event.reroll", 2 s later); the loot and Score's rows as before (bossfight.zs BfPayoff).
//   MINIBOSS TIERS  every tier this mod gave is put back when a hub level is entered again (WorldLoaded IsReopen); on any
//                   other map change the monsters are gone with their map. Tiers from RSQ Score or Gun Bonsai VR are theirs.
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

	// the words (RSQVR_Service, the shared contract /tmp/contract.md 2026-11-09): "TARGET!" gold, "GUARD!" silver
	const RGB_TARGET = 0xFFD030;
	const RGB_GUARD = 0xD0D4DC;
	const RGB_SHIELDGLOW = 0x8A93A6;   // the cold grey room (the mockup's event.tint value, p2)
	const RGB_GOLD = 0xFFC830;
	const RGB_GOLDLOW = 0x7A5A10;
	const RGB_LIFELOST = 0xFF2020;
	void Word(String txt, int rgb, double secs, Actor a) { let s = VrService(); if (s && a) s.GetInt("word", txt, rgb, secs, a); }
	void WordHold(String txt, int rgb, double size, Actor a) { let s = VrService(); if (s && a && a.health > 0) s.GetInt("word.hold", txt, rgb, size, a); }
	void WordClear(String txt, Actor a) { let s = VrService(); if (s && a) s.GetInt("word.clear", txt, 0, 0, a); }
	bool Pop(int rgb, Actor a) { let s = VrService(); return s && a && s.GetInt("pop", "", rgb & 0xFFFFFF, 1.0, a) > 0; }
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
			WindowStep(b);
			WordsStep(b);
			if (b.called) RoomGlow(b);
		}
	}

	// ---- the window ------------------------------------------------------------------------------------------------------
	// a thrall died: its power goes, the pop, then a window (or a turn in line for one)
	void ThrallKilled(RSQMB_Boss b, int i, Actor a, Actor killer)
	{
		int pc = b.StripPowers(i, self);
		int col = pc >= 0 ? pc : (int(b.col) & 0xFFFFFF);
		if (!Pop(col, a)) FxBreak(b, a);
		else if (b.mb) FxLink(b, a);
		ArrowClear(a);
		if (b.SegsLeft() > 0)
		{
			b.winCredits++;
			if (b.winSeg < 0) OpenWin(b, killer);
		}
		b.wordState = -9;
		if (debug) Console.Printf("RSQMB thrall %d of boss %d killed: power colour %06X, segments left %d, window %s, credits %d",
			i, b.idx, col, b.SegsLeft(), b.winSeg >= 0 ? "open" : "shut", b.winCredits);
	}

	void OpenWin(RSQMB_Boss b, Actor who)
	{
		int seg = b.OpenSeg();
		if (seg < 0) { b.winCredits = 0; return; }
		b.winCredits = max(0, b.winCredits - 1);
		int now = level.maptime;
		b.winSeg = seg;
		b.winStart = now;
		b.winEnd = now + max(1, b.total) * TICRATE;
		windowEnd = max(windowEnd, b.winEnd);     // RSQ SlowMo is asked each second while it lasts (Tick2, rsm_pulse)
		nextPulse = now;
		b.wordState = -9;
		b.glowSent = -1;
		if (b.mb) b.mb.A_StartSound("misc/p_pkup", CHAN_AUTO, CHANF_UI, 1.0, ATTN_NONE);
		if (debug) Console.Printf("RSQMB window OPEN: boss %d segment %d (%.0f of %.0f) for %d s", b.idx, seg, b.segHP[seg], b.segMax, b.total);
	}

	// the latest open window of any miniboss (0 none): what SlowMo is told is left (service "window", Tick2's pulse)
	void WindowEndNow()
	{
		int e = 0;
		for (int i = 0; i < bosses.Size(); i++) { let o = bosses[i]; if (o && !o.done && o.winSeg >= 0) e = max(e, o.winEnd); }
		windowEnd = e;
	}

	void WindowStep(RSQMB_Boss b)
	{
		if (b.winSeg < 0)
		{
			if (b.winCredits > 0 && b.SegsLeft() > 0) OpenWin(b, null);
			return;
		}
		if (level.maptime < b.winEnd) return;
		// MISSED: the segment survived the window (owner 07:13): a sliver left +1, about half +2, untouched +3
		int seg = b.winSeg;
		double f = b.segMax > 0 ? b.segHP[seg] / b.segMax : 1.0;
		int by = f >= 0.99 ? 3 : (f >= 1.0 / 3.0 ? 2 : 1);
		b.winSeg = -1;
		b.wordState = -9;
		b.glowSent = -1;
		WindowEndNow();
		int n = TierUp(b, by);
		if (debug) Console.Printf("RSQMB window MISSED: boss %d segment %d left %.0f%%: tier +%d, %d monsters asked%s", b.idx, seg, f * 100, by, n,
			tierMapWide ? " (map-wide)" : "");
	}

	// the open segment broke (items.zs, the blow that broke it): Score's pay by the step it broke in, the first the most
	void SegBroken(RSQMB_Boss b, int seg, Actor who)
	{
		int now = level.maptime;
		bool inWin = seg == b.winSeg;
		if (inWin)
		{
			int left = clamp(int(ceil((b.winEnd - now) / double(TICRATE))), 1, max(1, b.total));
			Actor p = PlayerOf(who);
			if (p) Award(p, "Thrall Slow Kill", 100 * left);
			b.winSeg = -1;
			WindowEndNow();     // the window closed early: SlowMo's slow and its bar end with it (owner 11-10)
			if (debug) Console.Printf("RSQMB segment %d BROKEN in the window, step %d of %d (%d left): pays %d", seg, b.total - left + 1, b.total, left, 100 * left);
		}
		else if (debug) Console.Printf("RSQMB segment %d broken (no window: no thrall stands)", seg);
		if (b.mb)
		{
			b.mb.A_StartSound("weapons/bfgx", CHAN_AUTO, 0, 1.0, 0.5);
			if (fxOn && UseSprites()) fxp.Shot(RSQMB_Boss.Mid(b.mb), RSQMB_FxPool.SQ_BREAK, b.col, (1, 1), 0.8, RSQMB_FxPool.CAP[fxDensity]);
		}
		b.wordState = -9;
		b.glowSent = -1;
	}

	// ---- tier-ups (RSQ Monsters, by name) ------------------------------------------------------------------------------
	transient bool tierMapWide, tierLife;
	// the miniboss and its living thralls, and (Tier-Up Hits the Whole Map) every other monster RSQ Monsters can tier
	int TierUp(RSQMB_Boss b, int by)
	{
		int n = 0;
		if (RetierBy(b.mb, by, b, -1)) n++;
		for (int i = 0; i < b.thr.Size(); i++)
			if (b.thrState[i] == RSQMB_Boss.ST_ALIVE && RetierBy(b.thr[i], by, b, i)) n++;
		if (!tierMapWide) return n;
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (!a.bISMONSTER || a.player || a.health <= 0 || a.bFRIENDLY || a == b.mb || b.thr.Find(a) < b.thr.Size()) continue;
			if (RetierBy(a, by, null, 0)) n++;
		}
		return n;
	}

	// RE-FINDING A BODY (the brief: "CH swap destroys and respawns the actor: re-find the new body"). RS_Retier.Swap spawns
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

	bool RetierBy(Actor a, int by, RSQMB_Boss b, int role)
	{
		let s = MnService();
		if (!s || !a || a.health <= 0 || by <= 0) return false;
		int t = TierOfMon(a);
		if (t < 1) return false;
		int nx = s.GetInt("tier.next", "", 0, 0, a);
		int cur = max(t, nx);
		int want = min(TOP_TIER, cur + by);   // the ladder is the strength order (11-11): +by is that many steps stronger
		if (want <= cur) return false;
		if (s.GetInt("retier", "", want, 0, a) != 1) return false;
		int k = tfMon.Find(a);
		EnsureTf();
		if (k == tfMon.Size())
		{
			tfMon.Push(a); tfOrig.Push(t); tfUntil.Push(0); tfRole.Push(role); tfX.Push(0); tfY.Push(0); tfZ.Push(0); tfBoss.Push(b); tfTok.Push("");
			tfNext.Push(null); tfFrac.Push(1.0); tfCarry.Push(0); tfInfo.Push(null); tfHeldAt.Push(0);
		}
		tfUntil[k] = level.maptime + FOLLOW_TICS;
		tfBoss[k] = b; tfRole[k] = role;
		tfX[k] = a.pos.x; tfY[k] = a.pos.y; tfZ[k] = a.pos.z;
		// a set piece's own body keeps EVERY Champions token it had (carry.zs builds its controllers again); a map monster
		// keeps what it did before (the four by-name colours, Titan, LegenDoom's legendary)
		tfTok[k] = KeptTokens(a, b != null);
		tfNext[k] = null; tfCarry[k] = 0; tfHeldAt[k] = 0;
		// its share of health (RSQ Monsters' rule: the wound is carried, rsq_mon_retier_health 2 is always full): of the most
		// it has had (the miniboss: maxHP; a thrall: boss.zs thrPeak)
		double full = b ? (role < 0 ? b.maxHP : b.ThrallPeak(role)) : 0;
		tfFrac[k] = (full > 0 && CI('rsq_mon_retier_health', 1) < 2) ? clamp(a.health / full, 0.05, 1.0) : 1.0;
		if (debug && b) Console.Printf("RSQMB tier asked t%d: %s %s tier %d -> %d, health %d of %.0f (share %.2f), tokens [%s]", level.maptime,
			role < 0 ? "the miniboss" : String.Format("thrall %d", role), a.GetClassName(), cur, want, a.health, full, tfFrac[k], tfTok[k]);
		return true;
	}

	// the tokens a CH swap would lose and that work when given by name; for a set piece's own body (all) every Champions
	// colour and mutation token too (its icons and its bar colour; the powers come back with its controllers, carry.zs)
	String KeptTokens(Actor a, bool all = false)
	{
		static const String KEEP[] = { "champion_YellowToken", "champion_WhiteToken", "champion_DarkGreenToken", "champion_CyanToken",
			"champion_TitanToken", "LDLegendaryMonsterToken" };
		String s = "";
		for (int i = 0; i < KEEP.Size(); i++) if (Has(a, KEEP[i])) s = s .. KEEP[i] .. ",";
		if (!all) return s;
		for (int i = 0; i < COLOURS.Size(); i++)
		{
			String tk = "champion_" .. COLOURS[i] .. "Token";
			if (s.IndexOf(tk .. ",") < 0 && Has(a, tk)) s = s .. tk .. ",";
		}
		return s;
	}

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
	//   0 shield up: "TARGET!" over each living thrall (size 1), none over the miniboss
	//   1 window: a big pulsing "TARGET!" over the miniboss (size 2), the thralls' shrunk (0.6)
	//   2 one-on-one (no segment left, or no thrall standing): "TARGET!" over the miniboss (size 2), none over thralls
	//   3 invulnerable (a life just lost): no "TARGET!" over the miniboss until it can be shot again (owner 11-10: TARGET!
	//     appears over it WHEN IT CAN BE SHOT), none over thralls
	void WordsStep(RSQMB_Boss b)
	{
		if (b.guardTic > 0 && level.maptime - b.guardTic == 35 && b.mb) WordClear("GUARD!", b.mb);
		int st = b.Invulnerable() ? 3 : b.FightState();
		if (st == b.wordState) return;
		b.wordState = st;
		if (st == 0 || st == 3) WordClear("TARGET!", b.mb); else WordHold("TARGET!", RGB_TARGET, 0.8, b.mb);     // (owner 11-12 14:11: "TARGET and GUARD are way too big, it's all I can see": 2.0 -> 0.8)
		for (int i = 0; i < b.thr.Size(); i++)
		{
			let t = b.thr[i];
			if (!t) continue;
			if (b.thrState[i] != RSQMB_Boss.ST_ALIVE || st >= 2) WordClear("TARGET!", t);
			else WordHold("TARGET!", RGB_TARGET, st == 1 ? 0.35 : 0.5, t);     // (1.0 / 0.6 -> 0.5 / 0.35)
		}
	}

	// ---- the fight room's glow (RSQGD_Service "event.tint": the whole map's glow leans to it) ------------------------------
	// shield up: steady cold grey; a window: gold, pulsing (steady in Photosensitive Mode); a life lost: red, then its new
	// colour; one-on-one: its colour. Sent on a change and kept alive every GLOW_EVERY tics.
	const GLOW_EVERY = 10;
	const PULSE = 9;
	void RoomGlow(RSQMB_Boss b)
	{
		int now = level.maptime;
		int col;
		double secs = 0.5;
		int st = b.FightState();
		if (b.lifeLostAt > 0 && now - b.lifeLostAt < 20) col = RGB_LIFELOST;
		else if (st == 0) col = RGB_SHIELDGLOW;
		else if (st == 1)
		{
			bool hi = RSQMB_A11y.Photo() || ((now - b.winStart) / PULSE) % 2 == 0;
			col = hi ? RGB_GOLD : RGB_GOLDLOW;
			secs = 0.35;
		}
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
		if (b.called) rerollAt = level.maptime + 2 * TICRATE;
		for (int i = 0; i < b.thr.Size(); i++) if (b.thr[i]) WordClear("TARGET!", b.thr[i]);
	}

	// ---- the link's beads breaking where a pop stood in (the tether still snaps) --------------------------------------------
	void FxLink(RSQMB_Boss b, Actor th)
	{
		if (!fxOn || !b || !th || !b.mb || !UseSprites()) return;
		int cap = RSQMB_FxPool.CAP[fxDensity];
		int nb = RSQMB_FxPool.BEADS;
		for (int j = 0; j < nb; j++) fxp.Shot(BeadPos(b.mb, th, j, nb), RSQMB_FxPool.SQ_BEADX, b.col, (1, 1), 0.3, cap);
	}

	// ---- the grey Xs and "GUARD!" (items.zs RSQMB_Ward, a blow on the shielded miniboss) ------------------------------------
	Array<RSQMB_XFx> xfx;
	void GuardHit(RSQMB_Boss b, Actor inflictor, Actor source)
	{
		let mb = b.mb;
		if (!mb) return;
		int now = level.maptime;
		// (a small held word, not the full-size pop -- owner 11-12 14:11; WordsStep lets it go 1 s after the last blocked hit)
		b.guardHitTic = now;   // the HUD bar's GUARD shakes (bossbar.zs, owner 15:56)
		if (now - b.guardTic >= 18) { b.guardTic = now; WordHold("GUARD!", RGB_GUARD, 0.5, mb); }
		if (!fxOn || now - b.xTic < 2) return;
		b.xTic = now;
		for (int i = xfx.Size() - 1; i >= 0; i--) if (!xfx[i]) xfx.Delete(i);
		if (xfx.Size() >= 12) return;
		// where it hit: the puff or missile when it stands at the miniboss, else its side facing the shooter
		Vector3 c = RSQMB_Boss.Mid(mb);
		Vector3 at = c;
		Actor hitBy = (inflictor && inflictor != source) ? inflictor : null;
		if (hitBy && level.Vec3Diff(c, hitBy.pos).Length() < mb.radius * 2 + 48) at = hitBy.pos;
		else if (source) { Vector2 d = level.Vec2Diff(c.xy, source.pos.xy); double l = d.Length(); if (l > 1) at = c + (d.x / l * mb.radius, d.y / l * mb.radius, 0); }
		Vector2 away = level.Vec2Diff(c.xy, at.xy);
		double ol = away.Length();
		Vector2 dir;
		if (ol > 1) dir = away / ol;
		else { double ra = frandom[rsqmbfx](0, 360); dir = (cos(ra), sin(ra)); }
		let x = RSQMB_XFx.Make(at, (dir.x * 2.6, dir.y * 2.6, frandom[rsqmbfx](2.5, 4.0)));
		if (x) xfx.Push(x);
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
	// strength list this used before the renumber (StepOf / LadderOf) is gone. A tier-up in a fight (a missed window, a
	// life lost, the whole map: RetierBy) is "+N on the ladder", so it climbs in strength too.
	const TOP_TIER = 13;
	const THRALL_TIER_CAP = 11;   // Abyss
	const FIRST_BOSS_TIER = 12;   // Black; 13 White

	static String ColourName(int t)
	{
		static const String N[] = { "-", "Common", "Green", "Blue", "Purple", "Cyan", "Brown", "Yellow", "FireBlu", "Gray", "Red", "Abyss", "Black", "White" };
		return t >= 1 && t <= 13 ? N[t] : "-";
	}
	static String TierText(int t) { return t > 0 ? String.Format("%s(%d)", ColourName(t), t) : "-"; }

	static bool IsFists(Weapon w)
	{
		if (!w) return true;
		if (w is "Fist") return true;
		static const Name FISTS[] = { 'Melee_Attacks', 'RSQ_Hands', 'RSQ_Glove', 'RSQ_GloveOff', 'SPO_Glove', 'SPO_GloveOff', 'DWep_Fists' };
		class<Actor> c = w.GetClass();
		for (int d = 0; c && d < 4; d++)
		{
			Name n = c.GetClassName();
			for (int k = 0; k < FISTS.Size(); k++) if (n == FISTS[k]) return true;
			if (c is "Fist") return true;
			class<Actor> r = Actor.GetReplacee(c);
			if (r == c) break;
			c = r;
		}
		return false;
	}

	// one hand's Gun Bonsai VR weapon level: 0 for an empty hand (BD22 VR's free hand RSQ_Hands too), the fists or gloves,
	// or no record
	int HandLevel(PlayerPawn p, int hand)
	{
		if (!p || !p.player || !GbSvc()) return 0;
		Weapon w = hand == 1 ? p.player.OffhandWeapon : p.player.ReadyWeapon;
		if (!w || IsFists(w)) return 0;
		return max(0, gbService.GetInt("level", "", hand, 0, p));
	}

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
		// the start colours (unchanged), kept for the bonus: 0 = not on the ladder
		Array<int> tStart;
		int topThrall = 0;
		for (int i = 0; i < tc.Size(); i++)
		{
			if (tMode != 4)
			{
				int tt = max(1, s.GetInt("class.tier", tc[i]));
				tc[i] = IntoSet(s, tc[i], SetOfMenu(tMode), tt);
				topThrall = max(topThrall, tt);
				tStart.Push(tt);
			}
			else tStart.Push(ClassSet(s, tc[i]) > 0 ? max(1, s.GetInt("class.tier", tc[i])) : 0);
		}
		int bStart = 0;
		if (bSet > 0)
		{
			int bt = max(1, s.GetInt("class.tier", bn));
			if (topThrall > 0) bt = max(bt, topThrall + 1);
			bStart = min(13, bt);
			bn = IntoSet(s, bn, bSet, bStart);
		}
		else if (ClassSet(s, bn) > 0) bStart = max(1, s.GetInt("class.tier", bn));

		// THE COLOUR BONUS (above), on the ladder's own numbers (strength order since 11-11)
		if (GbSvc() && p)
		{
			int pl = max(0, gbService.GetInt("player.level", "", 0, 0, p));
			int wm = HandLevel(p, 0), wo = HandLevel(p, 1);
			int tBonus = (wm + wo + 2) / 4;   // 0.25 a level, half up
			String st = "", fin = "";
			int topNow = 0;
			for (int i = 0; i < tc.Size(); i++)
			{
				int s0 = tStart[i];
				if (s0 <= 0) { st = st .. " -"; fin = fin .. " -"; continue; }
				// the bonus stops at Abyss; a start colour already above it (a map's own Black or White) is kept, never lowered
				int s1 = max(s0, min(THRALL_TIER_CAP, s0 + tBonus));
				if (s1 != s0) { String nn = IntoSet(s, tc[i], 3, s1); if (nn != "") tc[i] = nn; }
				topNow = max(topNow, s1);
				st = st .. " " .. TierText(s0); fin = fin .. " " .. TierText(s1);
			}
			int b0 = bStart, b1 = b0;
			String ex = "";
			if (b0 > 0)
			{
				b1 = min(TOP_TIER, b0 + pl);
				// at least one tier above its strongest thrall (raised, never lowered)
				if (topNow > 0) b1 = max(b1, min(TOP_TIER, topNow + 1));
				if (b1 != b0) { String nn = IntoSet(s, bn, 3, b1); if (nn != "") bn = nn; }
				// a boss colour this mod gave it: RSQ Monsters' EX roll for this family at this colour (none for the others); a
				// map's own boss-colour miniboss left where it was has had its own roll
				if (b1 >= FIRST_BOSS_TIER && (b1 != b0 || bSet > 0)) { ex = s.GetString("set.class.ex", bn, 3, b1); if (ex != "") bn = ex; }
			}
			if (debug) Console.Printf("RSQMB colour bonus t%d (ladder tiers, strength order): start miniboss %s, thralls%s | Gun Bonsai VR player level %d -> miniboss +%d | weapon levels main %d + off %d = %d -> thralls +%d (x0.25, half up) | final miniboss %s%s (%s), thralls%s (thralls stop at %s, top %s)",
				level.maptime, TierText(b0), st, pl, b0 > 0 ? pl : 0, wm, wo, wm + wo, tBonus, TierText(b1), ex != "" ? " EX" : "", bn, fin,
				TierText(THRALL_TIER_CAP), TierText(TOP_TIER));
		}
		else if (debug) Console.Printf("RSQMB colour bonus t%d: none (%s)", level.maptime, GbSvc() ? "no player" : "Gun Bonsai VR not loaded");

		class<Actor> nc = bn;
		if (debug) Console.Printf("RSQMB Miniboss From %d / Thralls From %d: %s", bfv, tfv, nc ? bn : "(none)");
		return nc ? nc : bc;
	}

}
