// RSQ HP Bars -- Damage Numbers: what a number is made for, and everything that moves them.
//
// WHEN A NUMBER IS MADE (2026-11-03 fold, kept). damnums gave every ISMONSTER actor a ticking item that diffed its health;
// on Brutal Doom that showed 9999 over every corpse (the head hitboxes dying, HANDOFF.md 11-03). Here: one number per
// target per tic from WorldThingDamaged (damnums' Shotgun Spray: one per hit). Never for:
//   - a helper: Brutal Doom's HeadHitbox family and boot smearers by name, and any ISMONSTER -COUNTKILL thing with
//     1000+ spawn health that rides a master or can never be targeted (that is how those helpers are built);
//   - a player's own body (Numbers For "All Shootable": your hits on yourself would float in your face in VR);
//   - a hit on a thing that was already dead before it (a corpse, a body being finished);
//   - the Massacre and KillMe damage types (cheats, and Brutal Doom's own clean-up kills);
//   - a Brutal Doom body (ISMONSTER -COUNTKILL) ending itself with no source or inflictor (bleeding out, A_Die).
// A number is never more than the health the target had left: an overkill shows the health it really lost.
//
// THE OWNER'S ROUND (2026-11-03 10:44, "I love all of this, let's get on it"), each with its own menu row:
//  1 FONTS: JFO metal digits (default; JDUI by Zedas, edit by Blackmore1014, as Gun Cards ships them), Ermac's digits,
//    damnums' two Classic Doom fonts; Text Quality Quest (half-resolution glyphs, default) / PCVR. All drawn with
//    VisualThinkers (glyphs.zs): no sprite frames.
//  2 COLOUR BY HIT STRENGTH: the share of the monster's health the hit took: under 5 % white, under 15 % yellow, under
//    35 % orange, more red. Magenta (RSQTHP_DnCrit) is kept for crits, which come after 2.0; nothing uses it yet.
//  3 POP AND SETTLE: appears at 0.35, overshoots to 1.35-1.55 (bigger hits more), snaps back to 1 by its 3rd tic, drifts
//    up, fades from 0.5 s, gone at 0.9 s. A hit's number stands at the top of the head, in front of the sprite.
//  4 SIZE BY HIT and GROW WITH DISTANCE (HP Bars' own Far Size curve: x1 to 256 units, x rsqthp_far at 1024).
//  5 RUNNING TOTAL: the second hit on a monster within 3 s starts one total beside its HP bar (above the monster with no
//    bar); each hit then flies into it, the total counts up and swells, "xN" counts the hits (pellets one by one). It
//    fades out over the last 20 tics of Score's chain window: 105 tics with no hit (Score's CHAIN_GAP, combo.zs; the same
//    3 s whether Score is loaded or not, so nothing is asked of it).
//  6 THE KILL: the total (or the killing hit's number) slams to 1.6x, holds, then its glyphs break apart, spin and fade.
//    The number is the health really taken; OVERKILL is a word over it when the last hit went past zero by more than
//    half the monster's spawn health (and at least 10). No burst or spark behind it (owner: numbers yes, sprites no).
//  7 HEADSHOT: Brutal Doom's head hits, as they reach the monster (brutal22test6, read from its code and measured on the
//    rig with real bullets): a bullet's blood (Blood_* in BloodTypesMonsters.dec, Damagetype "Head") landing more
//    than 46 above the floor runs ACS "Head_Shot" (Inputs.acs), which deals Thing_Damage2(0, 30, "Head") to the
//    monster -- the same tic as the bullet, so the number is the bullet and the head bonus together. Head hitboxes
//    (HeadHitbox, Head_Sys.dec) pass theirs on with A_DamageMaster(.., "head" / "decaptate" / ...), the hitbox the
//    inflictor. Also 'MinorHead' / 'Headshot' (Score's test, combo.zs). The number is 1.25x bigger, crimson, with
//    HEADSHOT over it. No BACKSTAB anywhere. CRIT: a hook only (RSQTHP_DnService "crit").
//  8 OUT OF YOUR FACE: never nearer the eyes than MIN_EYE (about a metre); slid off either gun's aim line; only the
//    Most Numbers nearest show.
//  9 GAINS ON YOU: +health (green), +armour (blue), +ammo (gold) rise from what you picked up and fly to the wrist (ammo
//    to the hand whose gun takes it, health and armour to the off hand). With RSQ Gun Cards loaded, ammo lands on its own
//    +N there and fades into it (Gun Cards is not asked or changed: it shows its +N on the same pickup by itself).
// 10 HIT-STOP AND SLOW-MO: a number made on a monster in a hit-stop (its freezetics counting, as every series hit-stop
//    sets it) stands still at 0.9x, unpopped, until the hit-stop ends, then pops; a frozen level freezes them all. In RSQ
//    SlowMo's slow motion (RSQSM_Service "active" / "scale", asked by name) they follow world time by default, or your
//    time (Numbers in Slow-Mo).
class RSQTHP_DamNumHandler : EventHandler
{
	// ---- this tic's hits, one entry per target (per hit in Shotgun Spray) -------------------------------------------
	Array<Actor> who;
	Array<int> amt, cnt, over, typ;
	Array<bool> hHead, hKill, hCrit;
	Array<double> px, py, pz;
	Array<Name> types;

	// ---- what is in the air ------------------------------------------------------------------------------------------
	Array<RSQTHP_DnNum> nums;
	Array<RSQTHP_Glyph> pool, freeG;
	RSQTHP_DnFonts fonts;
	RSQTHP_DnDriver driver;
	const GLYPH_CAP = 160;          // every glyph of every number (a 3-digit hit is 3; a total with x12 is 6)
	const MIN_EYE = 36.0;           // never nearer the eyes than this (34 map units to a metre: the series' figure)
	const CHAIN_GAP = 105;          // Score's chain window (combo.zs CHAIN_GAP): a total fades out over its last 20 tics
	const FADE_FROM = 85;

	// ---- running totals: per monster, its first hit (no total yet) or its total --------------------------------------
	Array<Actor> tAct;
	Array<int> tFirst, tFirstN, tFirstTic;
	Array<RSQTHP_DnNum> tTot;

	// ---- the crit hook (after 2.0) ------------------------------------------------------------------------------------
	Array<Actor> critWho;
	Array<int> critTil;

	// ---- gains on you -------------------------------------------------------------------------------------------------
	Actor gPawn;
	bool gInit;
	int gHealth, gArmor;
	Array<class<Ammo> > gAmmoT;
	Array<int> gAmmoN;
	Vector3 pickPos;
	int pickTic;

	// ---- settings, once a tic -------------------------------------------------------------------------------------------
	int face, q, slowMode, maxN;
	bool ramp, pop, sizeBy, grow, total, slam, overkillW, headW, comfort, gains, hitstop;
	double far, dtWorld;
	int physics;
	Name userColour;
	bool typeColours, gunCards;
	transient bool svcLooked;
	transient Service smSvc;
	// measuring (the rig probe reads these)
	int made, madeTotals, madeKills, madeHeads, madeOver, madeGains, peakGlyphs, stolen;

	static RSQTHP_DamNumHandler Get() { return RSQTHP_DamNumHandler(EventHandler.Find("RSQTHP_DamNumHandler")); }

	// ===================================================================================================================
	// WHO GETS A NUMBER (unchanged from the fold)

	// (by name, no static arrays: QZD 17.3 rejected class-level static const String arrays in this class)
	static bool IsHeadHitbox(Actor a)
	{
		Name hn = "HeadHitbox";
		class<Actor> bc = hn;
		return bc && a is bc;
	}
	static bool IsHelper(Actor a)
	{
		if (!a) return true;
		if (IsHeadHitbox(a)) return true;
		Name cn = a.GetClassName();
		if (cn == 'BootSmearerRed' || cn == 'BootSmearerBlue' || cn == 'BootSmearerGreen' || cn == 'NewCybersHitBox') return true;
		if (a.bIsMonster && !a.bCountKill && a.SpawnHealth() >= 1000 && ((a.master && a.master != a) || a.bNeverTarget)) return true;
		return false;
	}

	bool Eligible(Actor a)
	{
		if (!a || a.player) return false;
		if (!(a.bIsMonster || (rsqthp_dmg_all && a.bShootable))) return false;
		return !IsHelper(a);
	}

	// Brutal Doom's head hit, as it reaches the monster (see the header, 7)
	static bool IsHead(WorldEvent e)
	{
		Name dt = e.DamageType;
		if (dt == 'Head' || dt == 'MinorHead' || dt == 'Headshot' || dt == 'decaptate') return true;
		if (e.Inflictor && e.Inflictor != e.Thing)
		{
			if (IsHeadHitbox(e.Inflictor)) return true;
		}
		return false;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (!rsqthp_dmg) return;
		let a = e.Thing;
		if (!Eligible(a)) return;
		if (e.DamageType == 'Massacre' || e.DamageType == 'KillMe') return;
		if (a.bIsMonster && !a.bCountKill && !e.DamageSource && !e.Inflictor) return;
		int before = a.health + e.Damage;                   // the event comes after the health came off
		if (before <= 0 || e.Damage <= 0) return;           // already dead before this hit
		int lost = before - max(a.health, 0);               // never more than it had left
		if (lost <= 0) return;
		bool killed = a.health <= 0;
		int ovr = killed ? e.Damage - before : 0;           // how far past zero the killing hit went
		bool head = IsHead(e);
		bool crit = CritOn(a);
		int ti = types.Find(e.DamageType);
		if (ti == types.Size()) types.Push(e.DamageType);
		int i = rsqthp_dmg_spray ? who.Size() : who.Find(a);
		if (i == who.Size())
		{
			who.Push(a); amt.Push(0); cnt.Push(0); over.Push(0); typ.Push(0);
			hHead.Push(false); hKill.Push(false); hCrit.Push(false); px.Push(0); py.Push(0); pz.Push(0);
		}
		amt[i] += lost; cnt[i]++; typ[i] = ti;             // the last hit's type, like damnums
		if (head) hHead[i] = true;
		if (crit) hCrit[i] = true;
		if (killed) { hKill[i] = true; over[i] = max(over[i], ovr); }
		// at the top of the head, and in FRONT of the monster's sprite (its radius + 6 toward your eyes): a number in the
		// sprite's own plane is hidden by the sprite (rig frame p_font0q0, the first try: the 123 inside the Baron's head)
		Vector3 p = a.pos + (0, 0, RSQTHP_Bar.TopOf(a) * 0.9);
		let pm = players[consoleplayer].mo;
		if (pm)
		{
			Vector2 to = pm.Pos.xy - a.pos.xy;
			double tl = to.Length();
			if (tl > 1) p.xy += to / tl * min(a.radius + 6, tl * 0.5);
		}
		px[i] = p.x; py[i] = p.y; pz[i] = p.z;
	}

	// pickups vanishing near the console player: where a gain rises from
	override void WorldThingDestroyed(WorldEvent e)
	{
		let inv = Inventory(e.Thing);
		if (!inv || inv.Owner) return;
		let pmo = players[consoleplayer].mo;
		if (!pmo || pmo.Distance3D(inv) > 160) return;
		pickPos = inv.Pos + (0, 0, max(8.0, inv.Height * 0.5));
		pickTic = level.maptime;
	}

	// ---- the crit hook: RSQTHP_DnService "crit" marks a monster's hits for a few tics (nothing is drawn for it yet) ----
	void MarkCrit(Actor a, int tics)
	{
		if (!a) return;
		int i = critWho.Find(a);
		if (i == critWho.Size()) { critWho.Push(a); critTil.Push(0); }
		critTil[i] = level.maptime + max(1, tics);
	}
	bool CritOn(Actor a)
	{
		for (int i = critWho.Size() - 1; i >= 0; i--)
		{
			if (!critWho[i] || critTil[i] < level.maptime) { critWho.Delete(i); critTil.Delete(i); continue; }
			if (critWho[i] == a) return true;
		}
		return false;
	}

	// ===================================================================================================================
	// SETTINGS
	static clearscope int CvI(Name n, int d) { let c = CVar.GetCvar(n, players[consoleplayer]); return c ? c.GetInt() : d; }
	static clearscope String CvS(Name n, String d) { let c = CVar.GetCvar(n, players[consoleplayer]); return c ? c.GetString() : d; }

	void ReadSettings()
	{
		face = clamp(CvI('rsqthp_dmg_face', 0), 0, RSQTHP_DnFonts.F_COUNT - 1);
		if (face == RSQTHP_DnFonts.F_SMALL) face = RSQTHP_DnFonts.F_JFO;
		q = CvI('rsqthp_dmg_q', 0) ? 1 : 0;
		ramp = CvI('rsqthp_dmg_ramp', 1) != 0;
		pop = CvI('rsqthp_dmg_pop', 1) != 0;
		sizeBy = CvI('rsqthp_dmg_size', 1) != 0;
		grow = CvI('rsqthp_dmg_grow', 1) != 0;
		total = CvI('rsqthp_dmg_total', 1) != 0;
		slam = CvI('rsqthp_dmg_slam', 1) != 0;
		overkillW = CvI('rsqthp_dmg_overkill', 1) != 0;
		headW = CvI('rsqthp_dmg_head', 1) != 0;
		comfort = CvI('rsqthp_dmg_comfort', 1) != 0;
		maxN = clamp(CvI('rsqthp_dmg_max', 12), 2, 64);
		gains = CvI('rsqthp_dmg_gains', 1) != 0;
		hitstop = CvI('rsqthp_dmg_hitstop', 1) != 0;
		slowMode = CvI('rsqthp_dmg_slowmo', 0);
		physics = CvI('rsqthp_dmg_physics', 0);
		userColour = CvS('rsqthp_dmg_colour', "RSQTHP_DamDefault");
		typeColours = CvI('rsqthp_dmg_types', 1) != 0;
		let cf = CVar.FindCVar('rsqthp_far');
		far = cf ? max(1.0, cf.GetFloat()) : 2.0;
	}

	// the speed of the world this tic: RSQ SlowMo's, asked by name (1 without it)
	double WorldSpeed()
	{
		if (!svcLooked) { svcLooked = true; let it = ServiceIterator.Find("RSQSM_Service"); smSvc = it.Next(); }
		if (!smSvc || smSvc.GetInt("active") != 1) return 1.0;
		int s = smSvc.GetInt("scale");
		return s > 0 ? clamp(s / 1000.0, 0.02, 1.0) : 1.0;
	}

	// ===================================================================================================================
	// THE POOL
	RSQTHP_Glyph Acquire(Vector3 at)
	{
		RSQTHP_Glyph g = null;
		while (freeG.Size() && !g) { g = freeG[freeG.Size() - 1]; freeG.Pop(); }
		if (!g && pool.Size() < GLYPH_CAP)
		{
			double w, h;
			TextureID t0 = fonts.Glyph(RSQTHP_DnFonts.F_JFO, 0, 48, w, h);
			g = RSQTHP_Glyph(VisualThinker.Spawn("RSQTHP_Glyph", t0, at, (0, 0, 0), 0.0, SPF_FULLBRIGHT, 0, (1, 1), (0, 0), STYLE_Translucent));
			if (g) { g.ChangeStatNum(RSQTHP_Glyph.STAT_GLYPH); pool.Push(g); }
		}
		if (g) peakGlyphs = max(peakGlyphs, pool.Size() - freeG.Size());
		return g;
	}
	void Release(RSQTHP_Glyph g)
	{
		if (!g) return;
		g.Hide();
		g.SetRolling(false);
		freeG.Push(g);
	}
	int LiveGlyphs() { return pool.Size() - freeG.Size(); }

	void FreeAll()
	{
		for (int i = 0; i < nums.Size(); i++) if (nums[i]) nums[i].Free(self);
		nums.Clear();
		tAct.Clear(); tFirst.Clear(); tFirstN.Clear(); tFirstTic.Clear(); tTot.Clear();
	}
	void ClearPending()
	{
		who.Clear(); amt.Clear(); cnt.Clear(); over.Clear(); typ.Clear();
		hHead.Clear(); hKill.Clear(); hCrit.Clear(); px.Clear(); py.Clear(); pz.Clear();
		if (types.Size() > 64) types.Clear();
	}

	// ===================================================================================================================
	// LOOKS
	static double Full(Actor a)
	{
		if (!a) return 100;
		let h = RSQTHP_Handler.Get();
		return max(1, h ? h.FullOf(a, 0) : a.SpawnHealth());
	}

	// bigger hits bigger: by the share of the monster's health, with a floor from the raw damage (a 300 on a boss)
	double HitSize(double share, int lost)
	{
		if (!sizeBy) return 1.0;
		double s = 0.6 + 0.9 * clamp(log(1 + share * 12) / log(13), 0.0, 1.0);
		s = max(s, 0.6 + 0.12 * log10(max(1, lost)));
		return clamp(s, 0.6, 1.5);
	}

	static Name RampOf(double share)
	{
		if (share < 0.05) return 'RSQTHP_DnWhite';
		if (share < 0.15) return 'RSQTHP_DnYellow';
		if (share < 0.35) return 'RSQTHP_DnOrange';
		return 'RSQTHP_DnRed';
	}

	Name ColourOf(double share, Name dtype, bool head)
	{
		if (head && headW) return 'RSQTHP_DnHead';
		if (ramp) return RampOf(share);
		// Colour by Hit Strength off: damnums' rules -- the font's colour, the user's, or the damage type's
		Name tr = (face == RSQTHP_DnFonts.F_CLASSIC || face == RSQTHP_DnFonts.F_CLASSIC_SMALL) ? 'RSQTHP_DamRed' : 'RSQTHP_DnRaw';
		if (userColour != 'RSQTHP_DamDefault') tr = userColour;
		if (typeColours && dtype != 'None')
		{
			String tc = TypeColour(dtype);
			if (tc != "") tr = tc;
		}
		return tr;
	}

	// a damage type's colour from LANGUAGE: ours first, then damnums' own names (a mod written for damnums)
	static String TypeColour(Name damagetype)
	{
		String key = "RSQTHP_DMG_TYPECOLOR_" .. damagetype;
		String v = StringTable.Localize("$" .. key);
		if (v != key) return v;
		key = "DAMNUM_TYPECOLOR_" .. damagetype;
		v = StringTable.Localize("$" .. key);
		if (v != key && v.Left(3) == "Dam") return "RSQTHP_" .. v;
		return "";
	}

	// pop and settle: 0.35 -> peak (1.35 small hits .. 1.55 big) at tic 1 -> 1.12 -> 1.0 at tic 3
	// (from: where it starts, 0.35; a number held in a hit-stop starts from 0.9, where it stood)
	static double PopCurve(double t, double sz, double from = 0.35)
	{
		double peak = 1.35 + 0.2 * clamp((sz - 0.6) / 0.9, 0.0, 1.0);
		if (t <= 0) return from;
		if (t <= 1) return from + (peak - from) * t;
		if (t <= 2) return peak + (1.12 - peak) * (t - 1);
		if (t <= 3) return 1.12 - 0.12 * (t - 2);
		return 1.0;
	}

	// ===================================================================================================================
	// MAKING NUMBERS
	RSQTHP_DnNum NewNum(int kind, Actor a, Vector3 p)
	{
		let n = new("RSQTHP_DnNum");
		n.kind = kind; n.who = a; n.p0 = p; n.at = p; n.atPrev = p;
		n.born = level.maptime; n.lastHit = level.maptime;
		n.alpha = 1; n.scaleNow = 1; n.size = 1; n.popFrom = 0.35;
		nums.Push(n);
		return n;
	}

	RSQTHP_DnNum NewHit(Actor a, Vector3 p, int lost, int nh, bool head, bool kill, int ovr, Name dtype, bool crit)
	{
		double full = Full(a);
		double share = lost / full;
		let n = NewNum(RSQTHP_DnNum.K_HIT, a, p);
		n.value = lost; n.nHits = nh;
		n.head = head; n.crit = crit; n.kill = kill;
		n.size = HitSize(share, lost);
		if (head && headW) { n.size = min(1.6, n.size * 1.25); n.words |= RSQTHP_DnNum.W_HEAD; madeHeads++; }
		if (kill && overkillW && ovr >= max(10, int(full * 0.5))) { n.words |= RSQTHP_DnNum.W_OVERKILL; madeOver++; }
		n.trans = ColourOf(share, dtype, head);
		n.jitX = frandom[rsqthpdn](-3.0, 3.0);
		n.frozen = hitstop && a && a.freezetics > 0;
		if (!pop)
		{
			// damnums' toss (a kick toward the console player +-20 degrees, up 3-4, gravity 0.4) or float (up 1)
			let pmo = players[consoleplayer].mo;
			double ang = pmo ? atan2(pmo.Pos.y - p.y, pmo.Pos.x - p.x) + frandom[rsqthpdn](-20, 20) : 0;
			if (physics == 1) { n.tossVX = 0; n.tossVY = 0; n.tossVZ = 1; }
			else { n.tossVX = cos(ang); n.tossVY = sin(ang); n.tossVZ = frandom[rsqthpdn](3.0, 4.0); }
		}
		made++;
		return n;
	}

	int FindT(Actor a)
	{
		for (int i = tAct.Size() - 1; i >= 0; i--)
		{
			let tt = tTot[i];
			bool stale = !tAct[i] || (tt ? (tt.st == RSQTHP_DnNum.S_DONE || tt.kill) : level.maptime - tFirstTic[i] > CHAIN_GAP);
			if (stale) { tAct.Delete(i); tFirst.Delete(i); tFirstN.Delete(i); tFirstTic.Delete(i); tTot.Delete(i); continue; }
			if (tAct[i] == a) return i;
		}
		return -1;
	}

	void ProcessPending()
	{
		for (int i = 0; i < who.Size(); i++)
		{
			let a = who[i];
			Vector3 p = (px[i], py[i], pz[i]);
			int lost = amt[i];
			bool kill = hKill[i], head = hHead[i];
			Name dt = types[typ[i]];
			if (!total || !a)
			{
				let n = NewHit(a, p, lost, cnt[i], head, kill, over[i], dt, hCrit[i]);
				if (kill) madeKills++;
				continue;
			}
			int k = FindT(a);
			RSQTHP_DnNum tot = k >= 0 ? tTot[k] : null;
			if (tot && level.maptime - tot.lastHit > CHAIN_GAP) tot = null;
			if (kill)
			{
				madeKills++;
				if (tot)
				{
					// THE KILL ON A TOTAL: every hit in flight lands at once, the last one too; the total slams
					tot.value += lost; tot.hits += cnt[i];
					tot.arrived = tot.value; tot.shown = tot.value; tot.hitsShown = tot.hits;
					for (int j = 0; j < nums.Size(); j++) if (nums[j] && nums[j].into == tot) nums[j].Free(self);
					double full = Full(a);
					if (head && headW) { tot.words |= RSQTHP_DnNum.W_HEAD; madeHeads++; }
					if (overkillW && over[i] >= max(10, int(full * 0.5))) { tot.words |= RSQTHP_DnNum.W_OVERKILL; madeOver++; }
					tot.kill = true; tot.lastHit = level.maptime;
					tot.trans = (head && headW) ? Name('RSQTHP_DnHead') : (ramp ? RampOf(tot.value / full) : tot.trans);
					if (slam) { tot.st = RSQTHP_DnNum.S_SLAM; tot.stT = tot.t; }
				}
				else NewHit(a, p, lost, cnt[i], head, true, over[i], dt, hCrit[i]);
				if (k >= 0) { tAct.Delete(k); tFirst.Delete(k); tFirstN.Delete(k); tFirstTic.Delete(k); tTot.Delete(k); }
				continue;
			}
			let n = NewHit(a, p, lost, cnt[i], head, false, 0, dt, hCrit[i]);
			if (!tot && k >= 0 && level.maptime - tFirstTic[k] <= CHAIN_GAP)
			{
				// the second hit within the chain window: the total starts with the first hit in it
				tot = NewNum(RSQTHP_DnNum.K_TOTAL, a, p);
				tot.value = tFirst[k]; tot.arrived = tFirst[k]; tot.shown = tFirst[k];
				tot.hits = tFirstN[k]; tot.hitsShown = tFirstN[k];
				tot.trans = ramp ? RampOf(tot.value / Full(a)) : n.trans;
				tTot[k] = tot;
				madeTotals++;
			}
			if (tot)
			{
				tot.value += lost; tot.hits += cnt[i]; tot.lastHit = level.maptime;
				n.into = tot; n.amount = lost;
			}
			else if (k < 0)
			{
				tAct.Push(a); tFirst.Push(lost); tFirstN.Push(cnt[i]); tFirstTic.Push(level.maptime); tTot.Push(null);
			}
			else { tFirst[k] = lost; tFirstN[k] = cnt[i]; tFirstTic[k] = level.maptime; }
		}
		ClearPending();
	}

	// ===================================================================================================================
	// GAINS ON YOU
	static Vector3 HandPos(PlayerPawn pmo, int hand)
	{
		if (pmo.OverrideAttackPosDir) return (hand == 1) ? pmo.OffhandPos : pmo.AttackPos;
		double yaw = pmo.angle;
		double side = (hand == 1) ? -1.0 : 1.0;
		Vector3 head = pmo.Pos + (0, 0, pmo.player.viewheight);
		return head + (cos(yaw), sin(yaw), 0) * 22.0 + (cos(yaw - 90), sin(yaw - 90), 0) * (side * 11.0) - (0, 0, 8.0);
	}
	static Vector3 HandDir(PlayerPawn pmo, int hand)
	{
		double y, p;
		if (pmo.OverrideAttackPosDir)
		{
			y = ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
			p = (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		}
		else { y = pmo.angle; p = -pmo.pitch; }
		double cp = cos(p);
		return (cp * cos(y), cp * sin(y), sin(p));
	}
	// the wrist: a hand's position, a little back along its aim
	static Vector3 WristOf(PlayerPawn pmo, int hand) { return HandPos(pmo, hand) - HandDir(pmo, hand) * 5.0; }

	void Gain(int kind, int amount, PlayerPawn pmo, Vector3 src0, int hand)
	{
		if (amount <= 0) return;
		for (int i = 0; i < nums.Size(); i++)
		{
			let n = nums[i];
			if (n && n.kind == RSQTHP_DnNum.K_GAIN && n.gainKind == kind && n.hand == hand && n.st == RSQTHP_DnNum.S_LIVE && n.t < 6)
			{ n.value += amount; return; }
		}
		let n = NewNum(RSQTHP_DnNum.K_GAIN, pmo, src0);
		n.value = amount; n.gainKind = kind; n.hand = hand;
		n.trans = kind == 0 ? Name('RSQTHP_DnHealth') : (kind == 1 ? Name('RSQTHP_DnArmour') : Name('RSQTHP_DnAmmo'));
		n.size = 1;
		n.landOnCards = gunCards && kind == 2;     // Gun Cards shows +N for ammo only
		madeGains++;
	}

	void TrackGains()
	{
		let p = players[consoleplayer];
		let pmo = p.mo;
		if (!pmo || pmo.health <= 0) { gInit = false; return; }
		if (pmo != gPawn) { gPawn = pmo; gInit = false; }
		bool picked = level.maptime - pickTic <= 1;
		Vector3 fallback = pmo.Pos + (cos(pmo.angle) * 20, sin(pmo.angle) * 20, 12);
		Vector3 here = picked ? pickPos : fallback;
		int hp = pmo.health;
		let ba = pmo.FindInventory("BasicArmor");
		int ar = ba ? ba.Amount : 0;
		// only what a pickup gave: a pickup vanished beside you this tic or the last (regeneration, a reload moving rounds
		// between Brutal Doom's ammo items, a script's health change: no number)
		if (gInit && picked)
		{
			if (hp > gHealth) Gain(0, hp - gHealth, pmo, here, 1);
			if (ar > gArmor) Gain(1, ar - gArmor, pmo, here, 1);
		}
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let am = Ammo(it);
			if (!am) continue;
			class<Ammo> ac = am.GetClass();
			int k = gAmmoT.Find(ac);
			int was = 0;
			bool fresh = false;
			if (k == gAmmoT.Size()) { gAmmoT.Push(ac); gAmmoN.Push(0); fresh = gInit; }
			else was = gAmmoN[k];
			if (gInit && am.Amount > was)
			{
				// a first pickup of an ammo type is the pickup itself, now in your pocket: it still stands where it lay
				Vector3 src = here;
				if (fresh && (am.Pos - pmo.Pos).Length() < 160 && am.Pos != (0, 0, 0)) { src = am.Pos + (0, 0, 8); picked = true; }
				if (picked || fresh)
				{
					int hand = 0;
					if (p.ReadyWeapon && (p.ReadyWeapon.AmmoType1 == ac || p.ReadyWeapon.AmmoType2 == ac)) hand = 0;
					else if (p.OffhandWeapon && (p.OffhandWeapon.AmmoType1 == ac || p.OffhandWeapon.AmmoType2 == ac)) hand = 1;
					Gain(2, am.Amount - was, pmo, src, hand);
				}
			}
			gAmmoN[gAmmoT.Find(ac)] = am.Amount;
		}
		gHealth = hp; gArmor = ar; gInit = true;
	}

	// ===================================================================================================================
	// MOVING THEM (the driver, after every actor)
	override void WorldLoaded(WorldEvent e)
	{
		EnsureDriver();
		Name gc = "RSQGC_GunCard";
		class<Object> gcc = gc;
		gunCards = gcc != null;
	}
	void EnsureDriver()
	{
		if (!fonts) fonts = new("RSQTHP_DnFonts");
		if (driver) return;
		driver = new("RSQTHP_DnDriver");
		driver.h = self;
		driver.ChangeStatNum(125);        // after the actors (STAT_DEFAULT 100) and HP Bars' bars
	}
	override void WorldTick() { EnsureDriver(); }

	Vector3 eye;
	Vector3 aimO0, aimD0, aimO1, aimD1;
	bool aimOn0, aimOn1;

	int readAt;
	void Step()
	{
		// the settings, every 8 tics (18 cvar reads; a menu change shows within a quarter second)
		if (level.maptime >= readAt || level.maptime < readAt - 8) { ReadSettings(); readAt = level.maptime + 8; }
		if (!fonts) fonts = new("RSQTHP_DnFonts");
		if (!rsqthp_dmg) { if (nums.Size()) FreeAll(); ClearPending(); return; }
		bool lf = level.IsFrozen();
		double sp = WorldSpeed();
		dtWorld = lf ? 0 : (slowMode == 1 ? 1.0 : sp);
		ProcessPending();
		if (gains) TrackGains(); else gInit = false;

		let p = players[consoleplayer];
		let pmo = p.mo;
		if (!pmo) return;
		eye = (pmo.Pos.xy, p.viewz);
		aimOn0 = false; aimOn1 = false;
		if (comfort)
		{
			if (p.ReadyWeapon) { aimOn0 = true; aimO0 = pmo.OverrideAttackPosDir ? HandPos(pmo, 0) : eye; aimD0 = HandDir(pmo, 0); }
			if (p.OffhandWeapon && pmo.OverrideAttackPosDir) { aimOn1 = true; aimO1 = HandPos(pmo, 1); aimD1 = HandDir(pmo, 1); }
		}

		for (int i = 0; i < nums.Size(); i++)
		{
			let n = nums[i];
			if (!n || n.st == RSQTHP_DnNum.S_DONE) continue;
			Advance(n, pmo);
			if (n.st != RSQTHP_DnNum.S_DONE) Draw(n, pmo);
		}
		for (int i = nums.Size() - 1; i >= 0; i--) if (!nums[i] || nums[i].st == RSQTHP_DnNum.S_DONE) nums.Delete(i);
		Cull();
	}

	// ---- its clock and its state ----------------------------------------------------------------------------------
	void Advance(RSQTHP_DnNum n, PlayerPawn pmo)
	{
		double dt = n.drawn ? dtWorld : 0.0;      // its first tic is drawn at clock 0 (the pop's small start)
		if (n.frozen)
		{
			if (hitstop && n.who && n.who.freezetics > 0) { dt = 0; n.t = 0; n.popFrom = 0.9; }
			else n.frozen = false;
		}
		n.t += dt;
		double t = n.t;
		switch (n.kind)
		{
		case RSQTHP_DnNum.K_HIT:
			if (n.st == RSQTHP_DnNum.S_LIVE)
			{
				if (pop)
				{
					n.scaleNow = n.size * PopCurve(t, n.size, n.popFrom);
					if (!n.frozen) n.rise = max(0.0, t - 2) * 0.4;
					n.alpha = t < 18 ? 1.0 : 1.0 - (t - 18) / 12.0;
				}
				else
				{
					n.scaleNow = n.size;
					n.tossVZ -= (physics == 1 ? 0 : 0.4) * dt;
					n.tossX += n.tossVX * dt; n.tossY += n.tossVY * dt; n.tossZ += n.tossVZ * dt;
					n.alpha = t < 10 ? 1.0 : 1.0 - (t - 10) * 0.05;
				}
				double join = n.head ? 10 : 3;
				if (n.into && t >= join && !n.frozen)
				{
					n.st = RSQTHP_DnNum.S_FLY; n.stT = t;
					n.flyAt = n.at; n.flyShift = n.jitX; n.flyScale = n.scaleNow;
				}
				else if (n.kill && slam && t >= 3 && !n.frozen) { n.st = RSQTHP_DnNum.S_SLAM; n.stT = t; }
				else if (n.alpha <= 0 || t >= 40) n.Free(self);
			}
			else if (n.st == RSQTHP_DnNum.S_FLY)
			{
				let tot = n.into;
				if (!tot || tot.st == RSQTHP_DnNum.S_DONE) { n.alpha -= 0.25 * max(dt, 0.25); if (n.alpha <= 0) n.Free(self); break; }
				if (t - n.stT >= 6)
				{
					tot.arrived = min(tot.value, tot.arrived + n.amount);
					tot.hitsShown = min(tot.hits, tot.hitsShown + n.nHits);
					tot.bumpT = tot.t;
					n.Free(self);
				}
			}
			else Finale(n, t);
			break;

		case RSQTHP_DnNum.K_TOTAL:
			if (n.st == RSQTHP_DnNum.S_LIVE)
			{
				if (n.shown < n.arrived) n.shown = min(double(n.arrived), n.shown + max(1.0, (n.arrived - n.shown) * 0.35) * max(dt, 0.0));
				double sw = (n.t - n.bumpT < 2 && n.bumpT > 0) ? 1.25 : 1.0;
				double full = Full(n.who);
				n.size = HitSize(n.value / full, n.value) * 0.95;
				if (ramp) n.trans = RampOf(n.shown / full);
				n.scaleNow = n.size * sw * (t < 3 ? PopCurve(t, n.size) : 1.0);
				int age = level.maptime - n.lastHit;
				n.alpha = age <= FADE_FROM ? 1.0 : 1.0 - double(age - FADE_FROM) / (CHAIN_GAP - FADE_FROM);
				if (!n.who || n.who.health <= 0) n.alpha = min(n.alpha, 1.0 - (level.maptime - max(n.lastHit, n.born)) / 12.0);
				if (n.alpha <= 0) n.Free(self);
			}
			else Finale(n, t);
			break;

		case RSQTHP_DnNum.K_GAIN:
			if (n.st == RSQTHP_DnNum.S_LIVE)
			{
				n.scaleNow = PopCurve(t, 1.0);
				n.rise = max(0.0, t - 2) * 0.6;
				n.alpha = 1;
				if (t >= 8) { n.st = RSQTHP_DnNum.S_FLY; n.stT = t; n.flyAt = n.at; n.flyScale = n.scaleNow; }
			}
			else if (n.st == RSQTHP_DnNum.S_FLY)
			{
				// shrinks on the way in: on the wrist it is about 7 cm tall a forearm from your eyes, not a hand's width
				double e = clamp((t - n.stT) / 12.0, 0.0, 1.0);
				n.scaleNow = 1.0 - 0.72 * e;
				if (e >= 1) { n.st = RSQTHP_DnNum.S_LAND; n.stT = t; }
			}
			else if (n.st == RSQTHP_DnNum.S_LAND)
			{
				double e = t - n.stT;
				n.scaleNow = 0.28;
				// with Gun Cards: fades into its own +N (4 tics); without: stays on the wrist a moment, then fades
				double hold = n.landOnCards ? 0 : 20, fade = n.landOnCards ? 4 : 8;
				n.alpha = e <= hold ? 1.0 : 1.0 - (e - hold) / fade;
				if (n.alpha <= 0) n.Free(self);
			}
			break;
		}
	}

	// the kill: slam, hold, break apart
	void Finale(RSQTHP_DnNum n, double t)
	{
		double e = t - n.stT;
		if (n.st == RSQTHP_DnNum.S_SLAM)
		{
			n.alpha = 1;
			n.scaleNow = n.size * (e < 2 ? 1.0 + 0.3 * e : 1.6);
			if (e >= 12) n.StartBreak();
		}
		else if (n.st == RSQTHP_DnNum.S_BREAK)
		{
			double dt = dtWorld;
			for (int i = 0; i < n.bX.Size(); i++)
			{
				n.bX[i] += n.bVX[i] * dt;
				n.bY[i] += n.bVY[i] * dt;
				n.bVY[i] -= 0.14 * dt;
				n.bRoll[i] += n.bSpin[i] * dt;
			}
			n.alpha = 1.0 - e / 14.0;
			if (e >= 14) n.Free(self);
		}
	}

	// ---- where it stands, and its glyphs ----------------------------------------------------------------------------
	void Draw(RSQTHP_DnNum n, PlayerPawn pmo)
	{
		Vector3 at, prev;
		double shift = n.jitX;
		bool keepAway = true;
		n.Layout(self);
		switch (n.kind)
		{
		case RSQTHP_DnNum.K_HIT:
			if (n.st == RSQTHP_DnNum.S_FLY && n.into)
			{
				let tot = n.into;
				double e = clamp((n.t - n.stT) / 6.0, 0.0, 1.0);
				e = e * e;
				at = n.flyAt + (tot.at - n.flyAt) * e;
				shift = n.flyShift + (tot.shiftX - n.flyShift) * e;
				n.scaleNow = n.flyScale + (tot.scaleNow * 0.8 - n.flyScale) * e;
			}
			else if (!pop && n.st == RSQTHP_DnNum.S_LIVE) at = n.p0 + (n.tossX, n.tossY, n.tossZ);
			else at = n.p0 + (0, 0, n.rise);
			break;
		case RSQTHP_DnNum.K_TOTAL:
		{
			// beside the monster's HP bar, its left edge just past the bar's right end (and past the bar's right-hand
			// icon); above the monster when it has no bar
			double barHalf = -1, up = 0, sy = 0;
			RSQTHP_Bar b = BarOf(n.who);
			if (n.who && b && !b.bInvisible)
			{
				sy = b.Scale.Y;
				up = b.Pos.z - b.who.Pos.z + 5.5 * sy;
				barHalf = 56 * b.Scale.X + (b.stat != null ? 26 * sy : 0) + 2.5;
			}
			else if (n.who) up = RSQTHP_Bar.TopOf(n.who) * 1.15 + 6;
			// the kill: it stays where it stood (the bar goes and the body drops under it), growing about its centre
			if (n.st == RSQTHP_DnNum.S_SLAM || n.st == RSQTHP_DnNum.S_BREAK || !n.who) { at = n.at - n.slide; shift = n.shiftX; break; }
			at = n.who.Pos + (0, 0, up);
			n.shiftX = barHalf >= 0 ? barHalf + n.width * n.scaleNow * FarK(at) * 0.5 : 0;
			shift = n.shiftX;
			break;
		}
		case RSQTHP_DnNum.K_GAIN:
		{
			keepAway = false;
			Vector3 wr = WristOf(pmo, n.hand);
			if (n.st == RSQTHP_DnNum.S_LIVE) at = n.p0 + (0, 0, n.rise);
			else if (n.st == RSQTHP_DnNum.S_FLY)
			{
				double e = clamp((n.t - n.stT) / 12.0, 0.0, 1.0);
				e = e * e;
				at = n.flyAt + (wr - n.flyAt) * e;
			}
			else at = wr;
			shift = 0;
			break;
		}
		}

		// out of your face: off either gun's aim line (eased), and never nearer the eyes than MIN_EYE
		double fk = FarK(at);
		double S = n.scaleNow * fk;
		if (keepAway && comfort)
		{
			Vector3 want = (0, 0, 0);
			double ext = max(n.width, n.height) * S * 0.5;
			for (int hd = 0; hd < 2; hd++)
			{
				if (!(hd ? aimOn1 : aimOn0)) continue;
				Vector3 ao = hd ? aimO1 : aimO0, ad = hd ? aimD1 : aimD0;
				Vector3 w = at - ao;
				double along = w dot ad;
				if (along <= 8) continue;
				Vector3 perp = w - ad * along;
				double d = perp.Length();
				double need = ext + 4 + along * 0.035;      // the number's half size + about 2 degrees
				if (d < need)
				{
					Vector3 dir = d > 0.01 ? perp / d : (0, 0, 1);
					want += dir * (need - d);
				}
			}
			n.slide += (want - n.slide) * 0.5;
			at += n.slide;
			Vector3 v = at - eye;
			double dl = v.Length();
			if (dl < MIN_EYE)
			{
				Vector3 u = dl > 0.01 ? v / dl : (cos(pmo.angle), sin(pmo.angle), 0);
				at += u * MIN_EYE - v;
			}
		}
		// the renderer slides each glyph from last tic's spot to this one's (a new number: no slide)
		prev = n.drawn ? n.at : at;
		n.drawn = true;
		n.atPrev = n.at;
		n.at = at;
		n.dist = (at - eye).Length();

		// beyond the nearest Most Numbers: it gives its glyphs back to the pool (it keeps its place and clock, and takes
		// glyphs again when it is among the nearest)
		if (n.hidden)
		{
			for (int i = 0; i < n.gl.Size(); i++) Release(n.gl[i]);
			n.gl.Clear();
			return;
		}
		if (!n.Fit(self))
		{
			if (StealFor(n)) n.Fit(self);
		}
		double ps = level.pixelstretch;
		double a = n.hidden ? 0 : clamp(n.alpha, 0.0, 1.0);
		bool breaking = n.st == RSQTHP_DnNum.S_BREAK;
		double drop = (n.st == RSQTHP_DnNum.S_SLAM) ? max(0.0, 1.0 - (n.t - n.stT) / 3.0) * 10.0 : 0;
		int ng = min(n.gl.Size(), n.gCode.Size());
		for (int i = 0; i < ng; i++)
		{
			let g = n.gl[i];
			if (!g) continue;
			double w, h;
			TextureID tx = fonts.Glyph(n.gFont[i], q, n.gCode[i], w, h);
			if (!tx.IsValid() || h <= 0) { g.Alpha = 0; continue; }
			Name tr = n.gTrans[i] == 'None' ? n.trans : n.gTrans[i];
			g.Look(tx, tr);
			double sc = n.gH[i] * S / h;
			g.Scale = (sc, sc);
			double ox = shift + n.gX[i] * S, oy = n.gY[i] * S;
			if (n.gY[i] > n.height * 0.5) oy += drop;      // a word drops in over a slamming number
			if (breaking && i < n.bX.Size()) { ox += n.bX[i] * fk; oy += n.bY[i] * fk; g.SetRolling(true, n.bRoll[i]); }
			g.Offset = (ox, -oy * ps);
			g.Alpha = a;
			g.Put(at, prev);
		}
	}

	double FarK(Vector3 at)
	{
		if (!grow) return 1.0;
		double d = (at - eye).Length();
		return 1.0 + (far - 1.0) * clamp((d - 256) / 768.0, 0.0, 1.0);
	}

	RSQTHP_Bar BarOf(Actor a)
	{
		if (!a) return null;
		let h = RSQTHP_Handler.Get();
		if (!h || !h.on) return null;
		for (int i = 0; i < h.bars.Size(); i++) if (h.bars[i] && h.bars[i].who == a) return h.bars[i];
		return null;
	}

	// the pool is out of glyphs: the oldest plain hit number (not a kill, not a total, not a gain) gives its glyphs up
	bool StealFor(RSQTHP_DnNum want)
	{
		RSQTHP_DnNum old = null;
		for (int i = 0; i < nums.Size(); i++)
		{
			let n = nums[i];
			if (!n || n == want || n.kind != RSQTHP_DnNum.K_HIT || n.kill || n.st == RSQTHP_DnNum.S_DONE || !n.gl.Size()) continue;
			if (!old || n.born < old.born) old = n;
		}
		if (!old) return false;
		old.Free(self);
		stolen++;
		return true;
	}

	// only the Most Numbers nearest the eyes show (gains on you always do)
	void Cull()
	{
		Array<double> d;
		for (int i = 0; i < nums.Size(); i++)
			if (nums[i].kind != RSQTHP_DnNum.K_GAIN) d.Push(nums[i].dist);
		double cut = 1e12;
		if (d.Size() > maxN)
		{
			for (int i = 1; i < d.Size(); i++)
			{
				double v = d[i]; int j = i - 1;
				while (j >= 0 && d[j] > v) { d[j + 1] = d[j]; j--; }
				d[j + 1] = v;
			}
			cut = d[maxN - 1];
		}
		int kept = 0;
		for (int i = 0; i < nums.Size(); i++)
		{
			let n = nums[i];
			if (n.kind == RSQTHP_DnNum.K_GAIN) { n.hidden = false; continue; }
			bool hide = n.dist > cut || (n.dist == cut && kept >= maxN);
			if (!hide) kept++;
			n.hidden = hide;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		ClearPending();
		nums.Clear();
		tAct.Clear(); tFirst.Clear(); tFirstN.Clear(); tFirstTic.Clear(); tTot.Clear();
	}
}

// For other mods, by name (nothing links): RSQTHP_DnService.
//   GetInt("crit", "", tics, 0, monster) -> 1: hits on that monster in the next `tics` tics (default 2) are marked as
//   crits. Nothing is drawn for a crit yet: the CRIT word and the magenta tier (RSQTHP_DnCrit) come after 2.0, from a
//   rebuilt Critical Shots (owner, 2026-11-03). -1: no Damage Numbers handler.
class RSQTHP_DnService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQTHP_DamNumHandler.Get();
		if (!h) return -1;
		if (request ~== "crit") { h.MarkCrit(Actor(objectArg), intArg > 0 ? intArg : 2); return 1; }
		return -1;
	}
}
