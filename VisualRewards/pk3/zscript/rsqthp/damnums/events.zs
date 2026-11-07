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
// THE OWNER'S DESIGN (2026-11-03 18:05-18:12, approved from animated mockups; references Borderlands 3 and Castlevania SotN):
//  A COMBAT NUMBERS
//   - Each hit's number is SMALL (the size of the icons beside the HP bar, twice the bar's scale; it does not grow with
//     distance unless Grow with Distance is on). It pops at the hit with a white flash for 2-3 tics, snaps out with a small
//     overshoot, arcs up and out -- successive hits on one monster alternate left / right and step outward, so they never
//     overlap -- and is gone in 0.75 s. It appears on the side of the monster facing you and is kept clear of walls and
//     the ceiling: traced from the monster to its spot, and along its whole arc, before it is shown (Clear of Walls).
//   - Colour by damage type (BD22's bullets, shells, fire, plasma, explosives, melee, saws, the series' Saber and Force ...),
//     with Castlevania-style colour cycling: a 4-shade ramp of its colour shifting every 2 tics, letter by letter.
//   - THE RUNNING TOTAL sits centred above the HP bar from the chain's second hit: it rolls up like a counter and bounces on
//     each hit. THE COMBO "xN" sits beside the bar. Both step colour per hit (white, yellow, orange, red by default), grow a
//     little up to x5 and hold that size, shake a bit from x5, and cool down (colour drains, then fades) over RSQ Score's
//     chain window: 105 tics without a hit (Score's CHAIN_GAP, combo.zs; the same 3 s with or without Score). A low ceiling
//     puts the total beside the bar; a wall on the combo's side puts the combo on the other side.
//   - THE KILL: the total punches once (OVERKILL above it when the last hit went past zero by more than half the monster's
//     spawn health, at least 10), holds, then fades. With no total the killing hit's own number punches.
//   - HEADSHOT (Brutal Doom's head hits, read from brutal22test6, measured 11-03: its blood landing above 46 runs ACS
//     "Head_Shot" -> Thing_Damage2(0, 30, "Head"); head hitboxes pass "head" on): a gold word over a bigger number, a sharp
//     jolt and gold / white colour cycling. CRIT: a hook only (RSQTHP_DnService "crit").
//  B PLAYER LEVEL-UP (Gun Bonsai's network event "bonsai-level-up", first argument 0, second the new level -- sent by Gun
//     Bonsai 0.10.6's PerPlayerStats.Fanfare and by RSQ Gun Bonsai VR's copy of it; read by name, nothing links): a band
//     across the view, darker at the top and bottom, "LEVEL UP" scrolling across it -- in very fast, slow through the middle
//     (readable about 0.45 s), fast out -- with "PLAYER LV n" and "+1 UPGRADE" trailing at their own speeds; 1.26 s in all.
//     In VR it stands in the world about 2 m in front of your eyes (nearer if a wall is closer), follows your gaze lazily
//     and faces you: both eyes see it at one depth, so it reads like a sign, not a smear on the lens. Optional: a short
//     RSQ SlowMo pulse through the readable part (its network event "rsm_pulse", by name).
//  C WEAPON LEVEL-UP (the same event, first argument 1): a small tag rises off the gun: the gun's name types in letter by
//     letter (a white flash per letter), "LV n" stamps in with one punch, NEW UPGRADE flickers green; the border one steady
//     colour; then it fades. The gun's name and hand come from RSQ Gun Bonsai VR's RSQGB_Service when it is there (by name),
//     else from the gun in your main hand.
//  D COLOURS: every element has its colour row with a Random choice (fresh random colours every time); the HP bars get a
//     Cyan / Lavender / Orange scheme and Random (bar.zs). RSQ_Accessibility's colour-blind palette, when on, overrides the
//     bars as before and swaps the default combo ramp for a safe one.
// Kept from the morning round: fonts and Text Quality, gains on you, hit-stop and slow motion, out of your face, Most
// Numbers. Drawn with VisualThinkers from textures (glyphs.zs): no sprite frames, one pool of at most 200 glyphs.
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
	const GLYPH_CAP = 200;          // every glyph of every number (a 3-digit hit is 3; a banner about 30)
	const MIN_EYE = 36.0;           // never nearer the eyes than this (34 map units to a metre: the series' figure)
	const CHAIN_GAP = 105;          // Score's chain window (combo.zs CHAIN_GAP)
	const FADE_FROM = 85;           // a total fades over the window's last 20 tics ...
	const DRAIN_FROM = 50;          // ... after its colour drains
	const NCOL = 17;                // selectable palette colours (TRNSLATE RSQTHP_P<ii><s>); 17 is the cool-down grey
	const GREY = 17;
	const RND_CHOICE = 98;   // "Random" in the colour rows
	const BANNER_DUR = 44;          // the player level-up band: 1.26 s
	const TAG_DUR = 70;             // the weapon level-up tag: 2 s

	// ---- running totals: per monster, its first hit (no total yet) or its total --------------------------------------
	Array<Actor> tAct;
	Array<int> tFirst, tFirstN, tFirstTic, tLane;
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

	// ---- settings, every 8 tics ---------------------------------------------------------------------------------------
	int face, q, slowMode, maxN;
	bool pop, sizeBy, grow, total, slam, overkillW, headW, comfort, gains, hitstop;
	bool combo, flash, cycle, shake, clear, lvlOn, lvlSlow, wpnOn, photo;
	int hitCol, totCol, rampSel, headCol, bandCol, textCol, tagCol, cb;
	double far, dtWorld, hitH, numSize, wordSize, landH;
	int physics;
	Name userColour;
	bool typeColours, gunCards;
	transient bool svcLooked;
	transient Service smSvc;
	transient Array<Name> palN;
	// measuring (the rig probe reads these)
	int made, madeTotals, madeKills, madeHeads, madeOver, madeGains, peakGlyphs, stolen, madeBanners, madeTags, clamped;

	static RSQTHP_DamNumHandler Get() { return RSQTHP_DamNumHandler(EventHandler.Find("RSQTHP_DamNumHandler")); }

	// ===================================================================================================================
	// WHO GETS A NUMBER (unchanged from the fold)

	// Brutal Doom's helpers: the one shared list (rsqvr/helpers.zs), also used by the HP bars and Kill Rewards
	static bool IsHeadHitbox(Actor a) { return RSQVR_Helpers.IsHeadHitbox(a); }
	static bool IsHelper(Actor a) { return RSQVR_Helpers.IsHelper(a); }

	bool Eligible(Actor a)
	{
		if (!a || a.player) return false;
		if (!(a.bIsMonster || (rsqthp_dmg_all && a.bShootable))) return false;
		return !IsHelper(a);
	}

	// Brutal Doom's head hit, as it reaches the monster (see the header)
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
		amt[i] += lost; cnt[i]++;
		// the type that names the hit: a head hit's own type ("Head") says nothing of the gun, so the bullet's is kept
		if (!head || typ[i] == 0 && cnt[i] == 1) typ[i] = ti;
		if (head) hHead[i] = true;
		if (crit) hCrit[i] = true;
		if (killed) { hKill[i] = true; over[i] = max(over[i], ovr); }
		// WHERE YOU HIT IT (owner 11-03 18:36: "a super tiny 20 appears from where I hit it"): the inflictor's spot -- a
		// hitscan's puff (the engine hands a bullet's damage over with its puff, a temporary one when none shows), a
		// missile where it struck -- when it is at the monster; else (melee, a script's damage) the monster's middle. A
		// headshot stands at the top of the head. Then in FRONT of the sprite (a number in the sprite's own plane is hidden
		// by it: rig frame p_font0q0, 11-03): out to the monster's radius + 3 on your side.
		Vector3 p = a.pos + (0, 0, a.Height * 0.6);
		let inf = e.Inflictor;
		if (inf && inf != a && inf != e.DamageSource && (inf.Pos.xy - a.Pos.xy).Length() < a.radius + 40 && inf.Pos.z > a.Pos.z - 8 && inf.Pos.z < a.Pos.z + a.Height + 24)
			p = inf.Pos;
		// (a killing hit: the engine has already put it in its death frames, often short or lying down -- its standing height)
		if (head) p = a.pos + (0, 0, killed ? GetDefaultByType(a.GetClass()).Height * 0.9 : RSQTHP_Bar.TopOf(a) * 0.9);
		let pm = players[consoleplayer].mo;
		if (pm)
		{
			Vector2 to = pm.Pos.xy - a.pos.xy;
			double tl = to.Length();
			if (tl > 1)
			{
				Vector2 u = to / tl;
				double front = (p.xy - a.pos.xy) dot u;
				double want = min(a.radius + 3, tl * 0.5);
				if (front < want) p.xy += u * (want - front);
			}
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
	// GUN BONSAI'S LEVEL-UPS, by name: its network event "bonsai-level-up" (args: 0 the player / 1 a gun, the new level).
	// Gun Bonsai 0.10.6 sends it from PerPlayerStats.Fanfare and WeaponInfo.Fanfare (its flash and sound go with it); RSQ
	// Gun Bonsai VR's copies send the same. Shown only on the machine of the player who levelled.
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "bonsai-level-up")) return;
		if (e.Player != consoleplayer) return;
		let pmo = PlayerPawn(players[consoleplayer].mo);
		if (!pmo) return;
		if (!fonts) fonts = new("RSQTHP_DnFonts");
		ReadSettings();
		if (e.Args[0] == 0) { if (lvlOn) Banner(pmo, e.Args[1]); }
		else if (e.Args[0] == 1) { if (wpnOn) Tag(pmo, e.Args[1]); }
	}

	void Banner(PlayerPawn pmo, int lv)
	{
		for (int i = 0; i < nums.Size(); i++) if (nums[i] && nums[i].kind == RSQTHP_DnNum.K_BANNER) nums[i].Free(self);
		let n = NewNum(RSQTHP_DnNum.K_BANNER, pmo, pmo.Pos);
		n.level = lv;
		n.fam = Pick(textCol);
		n.famWord = Pick(bandCol);
		n.alpha = 0;
		madeBanners++;
	}

	void Tag(PlayerPawn pmo, int lv)
	{
		// which gun: RSQ Gun Bonsai VR's service (by name) knows each hand's level; the hand at (or one below, its level-up
		// still pending) the new level. Without it: the main hand's gun.
		int hand = 0;
		String nm = "";
		let it = ServiceIterator.Find("RSQGB_Service");
		let sv = it.Next();
		if (sv)
		{
			int l0 = sv.GetInt("level", "", 0, 0, pmo), l1 = sv.GetInt("level", "", 1, 0, pmo);
			if (!(l0 == lv || l0 == lv - 1) && (l1 == lv || l1 == lv - 1)) hand = 1;
			nm = sv.GetString("name", "", hand, 0, pmo);
		}
		if (nm == "")
		{
			Weapon w = hand == 1 ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
			if (w) nm = w.GetTag();
		}
		if (nm == "") nm = "WEAPON";
		for (int i = 0; i < nums.Size(); i++) if (nums[i] && nums[i].kind == RSQTHP_DnNum.K_TAG && nums[i].hand == hand) nums[i].Free(self);
		let n = NewNum(RSQTHP_DnNum.K_TAG, pmo, HandPos(pmo, hand));
		n.level = lv; n.label = nm; n.hand = hand;
		n.fam = 3;                       // "LV n": gold, alive
		n.famWord = Pick(tagCol);        // the border: one steady colour
		n.alpha = 0;
		madeTags++;
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
		pop = CvI('rsqthp_dmg_pop', 1) != 0;
		sizeBy = CvI('rsqthp_dmg_size', 0) != 0;
		grow = CvI('rsqthp_dmg_grow', 0) != 0;
		total = CvI('rsqthp_dmg_total', 1) != 0;
		slam = CvI('rsqthp_dmg_slam', 1) != 0;
		overkillW = CvI('rsqthp_dmg_overkill', 0) != 0;
		headW = CvI('rsqthp_dmg_head', 1) != 0;
		comfort = CvI('rsqthp_dmg_comfort', 1) != 0;
		maxN = clamp(CvI('rsqthp_dmg_max', 12), 2, 64);
		gains = CvI('rsqthp_dmg_gains', 1) != 0;
		hitstop = CvI('rsqthp_dmg_hitstop', 1) != 0;
		slowMode = CvI('rsqthp_dmg_slowmo', 0);
		physics = CvI('rsqthp_dmg_physics', 0);
		userColour = CvS('rsqthp_dmg_colour', "RSQTHP_DamDefault");
		typeColours = CvI('rsqthp_dmg_types', 1) != 0;
		combo = CvI('rsqthp_dn_combo', 1) != 0;
		flash = CvI('rsqthp_dn_flash', 1) != 0;
		cycle = CvI('rsqthp_dn_cycle', 1) != 0;
		shake = CvI('rsqthp_dn_shake', 1) != 0;
		clear = CvI('rsqthp_dn_clear', 1) != 0;
		hitCol = CvI('rsqthp_dn_hitcol', -2);
		totCol = CvI('rsqthp_dn_totcol', -1);
		rampSel = CvI('rsqthp_dn_ramp', 0);
		headCol = CvI('rsqthp_dn_headcol', 3);
		lvlOn = CvI('rsqthp_lvl', 1) != 0;
		lvlSlow = CvI('rsqthp_lvl_slow', 0) != 0;
		wpnOn = CvI('rsqthp_lvl_wpn', 1) != 0;
		bandCol = CvI('rsqthp_lvl_bandcol', 3);
		textCol = CvI('rsqthp_lvl_textcol', 3);
		tagCol = CvI('rsqthp_lvl_tagcol', 3);
		photo = RSQTHP_A11y.Photo();
		cb = 0; { Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN; if (rsqaC) cb = CvI('rsqa_colorblind', 0); }
		let cf = CVar.FindCVar('rsqthp_far');
		far = cf ? max(1.0, cf.GetFloat()) : 2.0;
		// SIZES (owner's headset, 11-03 18:28-18:29: "they are fuckin huge", "super tiny stuff", "the text is also really, really
		// damn big"): a hit's digits 2.5 map units tall at Number Size 1 (7 cm: 1.4 degrees at 3 m, 0.53 at 8 m, 0.21 at 20 m),
		// never more than 1.8 degrees however near; words 0.42 of that at Word Size 1. On the wrist a gain lands at RSQ Gun
		// Cards' small digits (0.7 x rsqgc_world_scale, read by name; 0.98 at its default 1.4).
		numSize = clamp(CVar.FindCVar('rsqthp_dn_size') ? CVar.FindCVar('rsqthp_dn_size').GetFloat() : 1.0, 0.25, 4.0);
		wordSize = clamp(CVar.FindCVar('rsqthp_dn_wordsize') ? CVar.FindCVar('rsqthp_dn_wordsize').GetFloat() : 1.0, 0.25, 4.0);
		hitH = 2.5 * numSize;
		let gcs = CVar.FindCVar('rsqgc_world_scale');
		landH = 0.7 * (gcs ? clamp(gcs.GetFloat(), 0.3, 4.0) : 1.4);
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
	// THE PALETTE (tools/gen_dn_art.py writes TRNSLATE's RSQTHP_P<ii><s>: 17 colours + grey, 4 shades each, and the flash)
	Name PalName(int fam, int shade)
	{
		if (palN.Size() == 0)
		{
			for (int i = 0; i <= GREY; i++)
				for (int s = 0; s < 4; s++) palN.Push(String.Format("RSQTHP_P%02d%d", i, s));
		}
		if (shade >= 4) return 'RSQTHP_PFL';
		return palN[clamp(fam, 0, GREY) * 4 + clamp(shade, 0, 3)];
	}
	Name FlashName() { return photo ? PalName(0, 3) : Name('RSQTHP_PFL'); }   // Photosensitive Mode: no full-white flash
	// a menu choice -> a colour (Random: a fresh one each time it is asked)
	static int Pick(int choice)
	{
		if (choice >= 0 && choice < NCOL) return choice;
		return random[rsqthpdn](0, NCOL - 1);
	}
	// Castlevania's colour cycling: a short ramp shifting every 2 tics (4 with Photosensitive Mode), glyph by glyph
	// (headset 11-03 18:28 "why are all of my damnums having a seizure?": every step is now at least 4 tics, 8 with
	// Photosensitive Mode, and the shades are close together -- a slow shimmer, never a strobe; the white flash is never in it)
	int Shade(int i, bool fast = false)
	{
		if (!cycle) return 1;
		int per = photo ? 8 : (fast ? 4 : 5);
		static const int R[] = { 1, 2, 3, 2 };
		return R[(level.maptime / per + i) % 4];
	}

	// the combo ramps (MENUDEF "RSQTHP_Ramps"); colour-blind (RSQ_Accessibility) swaps the default for a safe one
	void RampOf(int sel, out Array<int> r)
	{
		r.Clear();
		if (sel == 0 && cb >= 1 && cb <= 2) sel = 10;          // protan / deutan: white, sky, yellow, magenta
		else if (sel == 0 && cb == 3) sel = 11;                // tritan: white, cyan, pink, red
		static const int RA[] = {
			0, 2, 4, 5,       // 0 White Yellow Orange Red (the mockup)
			13, 12, 9, 8,     // 1 Cyan Sky Lavender Magenta
			15, 2, 4, 5,      // 2 Green Yellow Orange Red
			0, 12, 11, 10,    // 3 Ice: White Sky Blue Purple
			16, 3, 4, 6,      // 4 Lime Gold Orange Crimson
			13, 9, 7, 4,      // 5 Cyan Lavender Pink Orange
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 12, 2, 8,      // 10 colour-blind (protan / deutan)
			0, 13, 7, 5       // 11 colour-blind (tritan)
		};
		if (sel < 0 || sel > 11 || (sel > 5 && sel < 10))
		{
			for (int k = 0; k < 4; k++) r.Push(random[rsqthpdn](0, NCOL - 1));
			return;
		}
		for (int k = 0; k < 4; k++) r.Push(RA[sel * 4 + k]);
	}

	// a hit's colour by its damage type (Brutal Doom 22, BD22 VR Reloaded and the series' mods, read from their code)
	static int TypeFam(Name dt)
	{
		switch (dt)
		{
		case 'Shotgun': case 'SSG': case 'MonsterShotgunBullet':
			return 2;                                   // shells: yellow
		case 'Fire': case 'Flames': case 'Burn': case 'HumanBBQ': case 'LavaSplash': case 'SfestFireball':
			return 4;                                   // fire: orange
		case 'GreenFire':
			return 16;
		case 'Plasma':
			return 13;                                  // plasma: cyan
		case 'Explosive': case 'ExplosiveImpact': case 'Explosives': case 'Explosion': case 'Explode': case 'Rocket':
		case 'Blast': case 'Nuke': case 'Shrapnel': case 'BarrelExploded': case 'Landmine': case 'SfestExplode': case 'TankShell':
			return 5;                                   // explosives: red
		case 'Desintegrate': case 'Disintegrate': case 'BFG': case 'BFGSplash':
			return 16;                                  // BFG: lime
		case 'Railgun':
			return 11;                                  // rail: blue
		case 'Melee': case 'Kick': case 'HeadKick': case 'LowKick': case 'ExtremePunches': case 'ExtremeKicks': case 'SuperPunch':
		case 'Stomp': case 'StompWall': case 'Trample': case 'HeavyTrample': case 'Extreme': case 'Punch': case 'Fist':
			return 7;                                   // melee: pink
		case 'Saw': case 'Cut': case 'Rip': case 'Chainsaw':
			return 6;                                   // saws and blades: crimson
		case 'Saber':
			return 12;                                  // the series' Saber: sky
		case 'Force':
			return 9;                                   // the series' Force: lavender
		case 'Ice':
			return 12;
		case 'Electric': case 'Lightning':
			return 2;
		case 'Poison': case 'PoisonCloud': case 'Gravity':
			return 10;
		}
		return 0;                                       // bullets and the rest: white
	}

	static int StrengthFam(double share)
	{
		if (share < 0.05) return 0;
		if (share < 0.15) return 2;
		if (share < 0.35) return 4;
		return 5;
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

	void FreeAll(bool numbersOnly = false)
	{
		for (int i = 0; i < nums.Size(); i++)
		{
			let n = nums[i];
			if (!n) continue;
			if (numbersOnly && (n.kind == RSQTHP_DnNum.K_BANNER || n.kind == RSQTHP_DnNum.K_TAG)) continue;
			n.Free(self);
		}
		tAct.Clear(); tFirst.Clear(); tFirstN.Clear(); tFirstTic.Clear(); tTot.Clear(); tLane.Clear();
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

	// Size by Hit (off by default: the owner's numbers are small and even): a little bigger for a bigger share
	double HitSize(double share)
	{
		if (!sizeBy) return 1.0;
		return 0.85 + 0.4 * clamp(log(1 + share * 12) / log(13), 0.0, 1.0);
	}

	// damnums' colours (Hit Colours "damnums'"): the font's, the Number Colour row's, or the damage type's
	Name DamnumsColour(Name dtype)
	{
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

	// the pop: 0.45 -> 1.25 (tic 1) -> 1.06 -> 1.0 by tic 3 (a number held in a hit-stop starts from 0.9)
	static double PopCurve(double t, double from = 0.45)
	{
		if (t <= 0) return from;
		if (t <= 1) return from + (1.25 - from) * t;
		if (t <= 2) return 1.25 + (1.06 - 1.25) * (t - 1);
		if (t <= 3) return 1.06 - 0.06 * (t - 2);
		return 1.0;
	}
	// the kill: one punch, then it settles
	static double Punch(double e) { return 1.0 + 0.6 * exp(-max(0.0, e) / 4.0); }

	// ===================================================================================================================
	// MAKING NUMBERS
	RSQTHP_DnNum NewNum(int kind, Actor a, Vector3 p)
	{
		let n = new("RSQTHP_DnNum");
		n.kind = kind; n.who = a; n.p0 = p; n.at = p; n.atPrev = p;
		n.born = level.maptime; n.lastHit = level.maptime;
		n.alpha = 1; n.scaleNow = 1; n.size = 1; n.popFrom = 0.45; n.comboSide = 1;
		nums.Push(n);
		return n;
	}

	RSQTHP_DnNum NewHit(Actor a, Vector3 p, int lost, int nh, bool head, bool kill, int ovr, Name dtype, bool crit, int lane)
	{
		double full = Full(a);
		double share = lost / full;
		let n = NewNum(RSQTHP_DnNum.K_HIT, a, p);
		n.value = lost; n.nHits = nh;
		n.head = head; n.crit = crit; n.kill = kill;
		n.size = HitSize(share);
		n.lane = lane;
		if (head && headW) { n.size *= 1.35; n.words |= RSQTHP_DnNum.W_HEAD; n.famWord = Pick(headCol); madeHeads++; }
		if (kill && overkillW && ovr >= max(10, int(full * 0.5))) { n.words |= RSQTHP_DnNum.W_OVERKILL; madeOver++; }
		// its colour
		if (head && headW) n.fam = n.famWord;
		else if (hitCol == -2) n.fam = TypeFam(dtype);
		else if (hitCol == -1) n.fam = StrengthFam(share);
		else if (hitCol == -3) n.trans = DamnumsColour(dtype);
		else n.fam = Pick(hitCol);
		n.frozen = hitstop && a && a.freezetics > 0;
		if (pop && !(head && headW)) PlaceJet(n, a);
		else if (pop) PlaceArc(n, a);
		else
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

	// ---- clear of walls and ceilings: where a hit's number may go ---------------------------------------------------
	// Its arc: out along the view's right (side +-1, alternating per monster) and up. Traced before it is shown: the
	// monster to its spot (a wall between: pulled back in front of it), its spot against the ceiling (lowered under it),
	// and the whole arc on each side (shortened where it would meet a wall or the ceiling; the freer side wins when the
	// planned one is blocked). The arc is in the world (the view's right when it was made), so a turn of the head never
	// swings a number into a wall.
	const ARC_OUT = 1.9;     // how far out, in digit heights (plus its lane)
	const ARC_UP = 1.7;      // how far up
	void PlaceArc(RSQTHP_DnNum n, Actor a)
	{
		let pmo = players[consoleplayer].mo;
		double H = hitH * n.size;
		int side = (n.lane & 1) ? -1 : 1;
		double lane = (n.lane / 2) % 3;
		double reach = H * (ARC_OUT + 0.55 * lane), up = H * (ARC_UP + 0.35 * lane);
		double yaw = pmo ? (pmo.player.camera ? pmo.player.camera.Angle : pmo.Angle) : 0;
		Vector3 r = (sin(yaw), -cos(yaw), 0);
		n.arcR = r * side; n.arcOut = reach; n.arcUp = up;
		if (!clear || !pmo) return;
		double half = H * 0.7;          // half its height at the pop's peak, and a margin
		Vector3 p = n.p0;
		FLineTraceData d;
		bool cl = false;
		// 1. the monster to its spot
		if (a)
		{
			Vector3 from = (a.Pos.xy, p.z);
			Vector3 v = p - from;
			double vl = v.Length();
			if (vl > 1 && Trace(pmo, from, v / vl, vl + 2, d)) { p = from + v / vl * max(0.0, d.Distance - 3); cl = true; }
		}
		// 2. the ceiling over it (and its monster's: a low door frame)
		double cz = level.PointInSector(p.xy).ceilingplane.ZAtPoint(p.xy);
		if (a) cz = min(cz, a.ceilingz);
		double fz = level.PointInSector(p.xy).floorplane.ZAtPoint(p.xy);
		if (p.z + half > cz - 1) { p.z = max(fz + half, cz - 1 - half); cl = true; }
		up = clamp(cz - 1 - half - p.z, 0.0, up);
		// 3. the arc, each side
		double best = -1, bestUp = 0, bestOut = 0; int bestSide = side;
		for (int k = 0; k < 2; k++)
		{
			int s = k == 0 ? side : -side;
			Vector3 v = r * s * (reach + H) + (0, 0, up + half);
			double vl = v.Length();
			double f = 1.0;
			if (vl > 0.5 && Trace(pmo, p, v / vl, vl, d)) f = max(0.0, (d.Distance - 1.5) / vl);
			double o = reach * f, u = up * f;
			if (k == 0 && f >= 0.6) { best = o; bestUp = u; bestOut = o; bestSide = s; break; }
			if (o > best) { best = o; bestUp = u; bestOut = o; bestSide = s; }
		}
		if (bestSide != side || bestOut < reach - 0.01 || bestUp < up - 0.01) cl = true;
		n.p0 = p; n.at = p; n.atPrev = p;
		n.arcR = r * bestSide; n.arcOut = bestOut; n.arcUp = bestUp;
		if (cl) clamped++;
	}
	// ---- a normal hit: a little fountain jet (owner 11-03 18:36, "more like the little jets than the big jets") -------
	// Launched up and out of the monster (a random direction around the side facing you, +-80 degrees), at a slightly
	// different speed and angle each time so successive hits spray; gravity brings it over the top; it spins in the view
	// at its own random speed (most a little, some a lot, either way); faded by 0.63 s. Clear of Walls: the launch is
	// shortened so the jet's top stays under the ceiling and its path (to the top, then down to where it fades) misses
	// every wall.
	const JET_G = 0.09;          // gravity, map units per tic per tic
	const JET_LIFE = 22;         // tics
	void PlaceJet(RSQTHP_DnNum n, Actor a)
	{
		let pmo = players[consoleplayer].mo;
		n.jet = true;
		double towardYou = pmo ? atan2(pmo.Pos.y - n.p0.y, pmo.Pos.x - n.p0.x) : 0;
		double ang = towardYou + frandom[rsqthpdn](-80, 80);
		double hs = frandom[rsqthpdn](0.12, 0.34) * numSize;
		double vz = frandom[rsqthpdn](0.85, 1.30) * numSize;     // with gravity x Number Size: the same timing at any size
		n.vel = (cos(ang) * hs, sin(ang) * hs, vz);
		n.jetPos = n.p0;
		n.grav = numSize;
		n.spin = (frandom[rsqthpdn](0, 1) < 0.7 ? frandom[rsqthpdn](0.5, 3.5) : frandom[rsqthpdn](7, 18)) * (random[rsqthpdn](0, 1) ? 1 : -1);
		n.roll = frandom[rsqthpdn](-12, 12);
		if (!clear || !pmo) return;
		double H = hitH * n.size, half = H * 0.7;
		Vector3 p = n.p0;
		bool cl = false;
		double cz = level.PointInSector(p.xy).ceilingplane.ZAtPoint(p.xy);
		if (a) cz = min(cz, a.ceilingz);
		double fz = level.PointInSector(p.xy).floorplane.ZAtPoint(p.xy);
		if (p.z + half > cz - 1) { p.z = max(fz + half, cz - 1 - half); cl = true; }
		// the top: vz^2 / 2g above the start, kept under the ceiling
		double g = JET_G * n.grav;
		double room = max(0.0, cz - 1 - half - p.z);
		if (n.vel.z * n.vel.z / (2 * g) > room) { n.vel.z = sqrt(2 * g * room); cl = true; }
		// its path: start -> top -> its end, each leg traced
		double tTop = n.vel.z / g;
		Vector3 top = p + (n.vel.xy * tTop, n.vel.z * n.vel.z / (2 * g));
		double tl = JET_LIFE;
		Vector3 fin = p + (n.vel.xy * tl, n.vel.z * tl - 0.5 * g * tl * tl);
		fin.z = max(fin.z, fz + half);
		FLineTraceData d;
		Vector3 v = top - p;
		double vl = v.Length();
		double f = 1.0;
		if (vl > 0.5 && Trace(pmo, p, v / vl, vl + half, d)) f = max(0.0, (d.Distance - half) / (vl + half));
		v = fin - top; vl = v.Length();
		if (f >= 1.0 && vl > 0.5 && Trace(pmo, top, v / vl, vl + half, d)) f = min(f, 0.5 + 0.5 * max(0.0, (d.Distance - half) / (vl + half)));
		if (f < 1.0) { n.vel.x *= f; n.vel.y *= f; n.vel.z *= max(f, 0.35); cl = true; }
		n.p0 = p; n.jetPos = p; n.at = p; n.atPrev = p;
		if (cl) clamped++;
	}

	// a wall or plane along v from p, within dist (monsters do not count)
	static bool Trace(Actor caller, Vector3 p, Vector3 v, double dist, out FLineTraceData d)
	{
		double ang = atan2(v.y, v.x), pit = -atan2(v.z, v.xy.Length());
		return caller.LineTrace(ang, dist, pit, TRF_ABSPOSITION | TRF_THRUACTORS, p.z, p.x, p.y, d)
			&& d.HitType != FLineTraceData.TRACE_HitNone && d.HitType != FLineTraceData.TRACE_HitActor;
	}

	int FindT(Actor a)
	{
		for (int i = tAct.Size() - 1; i >= 0; i--)
		{
			let tt = tTot[i];
			bool stale = !tAct[i] || (tt ? (tt.st == RSQTHP_DnNum.S_DONE || tt.kill) : level.maptime - tFirstTic[i] > CHAIN_GAP);
			if (stale) { tAct.Delete(i); tFirst.Delete(i); tFirstN.Delete(i); tFirstTic.Delete(i); tTot.Delete(i); tLane.Delete(i); continue; }
			if (tAct[i] == a) return i;
		}
		return -1;
	}

	// a monster's next lane (successive hits alternate sides and step outward); kept per monster for its chain
	int LaneOf(Actor a)
	{
		if (!a) return 0;
		int k = FindT(a);
		if (k < 0) { tAct.Push(a); tFirst.Push(0); tFirstN.Push(0); tFirstTic.Push(level.maptime); tTot.Push(null); tLane.Push(0); k = tAct.Size() - 1; }
		return tLane[k]++;
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
			int lane = LaneOf(a);
			bool chain = (total || combo) && a;
			int k = chain ? FindT(a) : -1;
			RSQTHP_DnNum tot = k >= 0 ? tTot[k] : null;
			if (tot && level.maptime - tot.lastHit > CHAIN_GAP) tot = null;
			if (kill) madeKills++;
			// the hit's own number, always
			let n = NewHit(a, p, lost, cnt[i], head, kill && !tot, kill && !tot ? over[i] : 0, dt, hCrit[i], lane);
			if (!chain || k < 0) continue;
			if (!tot && level.maptime - tFirstTic[k] <= CHAIN_GAP && tFirstN[k] > 0)
			{
				// the chain's second hit: the total starts with the first hit in it
				tot = NewNum(RSQTHP_DnNum.K_TOTAL, a, p);
				tot.value = tFirst[k]; tot.shown = tFirst[k]; tot.hits = tFirstN[k];
				RampOf(rampSel, tot.ramp);
				tot.fam = totCol >= 0 ? Pick(totCol) : -1;
				tTot[k] = tot;
				madeTotals++;
			}
			if (tot)
			{
				tot.value += lost; tot.hits += cnt[i]; tot.lastHit = level.maptime; tot.bumpT = tot.t;
				if (kill)
				{
					// THE KILL ON A TOTAL: it punches once (OVERKILL above it), holds, fades
					tot.shown = tot.value;
					if (overkillW && over[i] >= max(10, int(Full(a) * 0.5))) { tot.words |= RSQTHP_DnNum.W_OVERKILL; madeOver++; }
					tot.kill = true;
					tot.st = RSQTHP_DnNum.S_KILL; tot.stT = tot.t;
				}
			}
			else { tFirst[k] = lost; tFirstN[k] = cnt[i]; tFirstTic[k] = level.maptime; }
			if (kill) { tAct.Delete(k); tFirst.Delete(k); tFirstN.Delete(k); tFirstTic.Delete(k); tTot.Delete(k); tLane.Delete(k); }
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
		n.fam = kind == 0 ? 15 : (kind == 1 ? 12 : 3);     // health green, armour sky, ammo gold
		n.size = 1;
		n.landOnCards = gunCards && kind == 2;     // Gun Cards shows +N for ammo only
		madeGains++;
	}

	// ===================================================================================================================
	// RSQ SLOWMO'S DOWN v2 (owner-approved 11-06 19:51, design/NEAR_DEATH.md 12; rsqvr/down.zs tells these)
	// TIME ADDED: each hit that adds time to the DOWN clock pops "+0.5s" at the monster hit (its standing height, out in
	// front of it on your side), on your time (DOWN slows the world to 5%), in the DOWN colour (crimson; RSQ
	// Accessibility's colour-blind combo ramp's last colour instead). THE WORDS: REVENGE (the mark killed), REVIVE (the
	// crate taken) and RAGE (its 5 s) fly past on the level-up band in the numbers' font (JFO), each its own colour.
	const TIME_COL = 6;             // crimson: DOWN's colour
	const REVENGE_COL = 8;          // magenta
	const REVIVE_COL = 13;          // cyan
	const RAGE_COL = 4;             // orange
	int madeDown;
	void DownTime(Actor mon, String label)
	{
		if (!rsqthp_dmg || !mon) return;
		if (!fonts) fonts = new("RSQTHP_DnFonts");
		ReadSettings();
		Vector3 p = mon.pos + (0, 0, mon.Height * 0.9);
		let pm = players[consoleplayer].mo;
		if (pm)
		{
			Vector2 to = pm.Pos.xy - mon.pos.xy;
			double tl = to.Length();
			if (tl > 1) p.xy += to / tl * min(mon.radius + 6, tl * 0.5);
		}
		let n = NewNum(RSQTHP_DnNum.K_SEQ, mon, p);
		n.label = label;
		n.special = true;
		n.fam = TIME_COL;
		if (cb != 0) { Array<int> r; RampOf(0, r); n.fam = r[r.Size() - 1]; }
		n.size = 1.35;
		madeDown++;
		let dc = CVar.FindCVar("rsqsm_debug");
		if (dc && dc.GetBool()) Console.Printf("RSQ VisualRewards: DOWN time \"%s\" (colour %d) at %.0f %.0f %.0f over %s", n.label, n.fam, p.x, p.y, p.z, mon.GetClassName());
	}
	// one word at a time: REVIVE and RAGE come on the same tic, so a word asked while another DOWN word is still on the
	// band waits for it (WorldTick)
	Array<String> qWord;
	Array<int> qCol;
	bool DownWordShowing()
	{
		for (int i = 0; i < nums.Size(); i++) if (nums[i] && nums[i].kind == RSQTHP_DnNum.K_BANNER && nums[i].special) return true;
		return false;
	}
	void DownWord(PlayerPawn pmo, String word, int col, bool queued = false)
	{
		if (!queued && (DownWordShowing() || qWord.Size() > 0)) { qWord.Push(word); qCol.Push(col); return; }
		if (!fonts) fonts = new("RSQTHP_DnFonts");
		ReadSettings();
		for (int i = 0; i < nums.Size(); i++) if (nums[i] && nums[i].kind == RSQTHP_DnNum.K_BANNER) nums[i].Free(self);
		let n = NewNum(RSQTHP_DnNum.K_BANNER, pmo, pmo.Pos);
		n.label = word;
		n.special = true;
		n.slowSent = true;          // never the level-up band's slow-motion pulse
		n.fam = col;
		n.famWord = Pick(bandCol);
		n.alpha = 0;
		madeBanners++;
		let dc = CVar.FindCVar("rsqsm_debug");
		if (dc && dc.GetBool()) Console.Printf("RSQ VisualRewards: DOWN word %s (colour %d) on the band", word, col);
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
	override void WorldTick()
	{
		EnsureDriver();
		if (qWord.Size() > 0 && !DownWordShowing() && players[consoleplayer].mo)
		{
			String w = qWord[0]; int c = qCol[0];
			qWord.Delete(0); qCol.Delete(0);
			DownWord(players[consoleplayer].mo, w, c, true);
		}
	}

	Vector3 eye;
	Vector3 aimO0, aimD0, aimO1, aimD1;
	bool aimOn0, aimOn1;
	double camYaw, camPitch;
	Vector3 camR, camU;         // the view's right and up

	int readAt;
	void Step()
	{
		// the settings, every 8 tics (a menu change shows within a quarter second)
		if (level.maptime >= readAt || level.maptime < readAt - 8) { ReadSettings(); readAt = level.maptime + 8; }
		if (!fonts) fonts = new("RSQTHP_DnFonts");
		bool dn = rsqthp_dmg;
		if (!dn) { FreeAll(true); ClearPending(); gInit = false; }
		bool lf = level.IsFrozen();
		double sp = WorldSpeed();
		dtWorld = lf ? 0 : (slowMode == 1 ? 1.0 : sp);
		if (dn)
		{
			ProcessPending();
			if (gains) TrackGains(); else gInit = false;
		}

		let p = players[consoleplayer];
		let pmo = p.mo;
		if (!pmo) return;
		eye = (pmo.Pos.xy, p.viewz);
		let cam = p.camera ? p.camera : Actor(pmo);
		camYaw = cam.Angle; camPitch = cam.Pitch;
		camR = (sin(camYaw), -cos(camYaw), 0);
		camU = (sin(camPitch) * cos(camYaw), sin(camPitch) * sin(camYaw), cos(camPitch));
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
			Advance(n, pmo, lf);
			if (n.st != RSQTHP_DnNum.S_DONE) Draw(n, pmo);
		}
		for (int i = nums.Size() - 1; i >= 0; i--) if (!nums[i] || nums[i].st == RSQTHP_DnNum.S_DONE) nums.Delete(i);
		Cull();
	}

	// ---- its clock and its state ----------------------------------------------------------------------------------
	void Advance(RSQTHP_DnNum n, PlayerPawn pmo, bool levelFrozen)
	{
		double dt = n.drawn ? dtWorld : 0.0;      // its first tic is drawn at clock 0 (the pop's small start)
		// the level-up displays run on your time (a slow-motion pulse never drags them out), and stand still in a menu
		if (n.kind == RSQTHP_DnNum.K_BANNER || n.kind == RSQTHP_DnNum.K_TAG) dt = (n.drawn && !levelFrozen) ? 1.0 : 0.0;
		// RSQ SlowMo's DOWN: the time added on your time (DOWN slows the world to 5%)
		if (n.special) dt = (n.drawn && !levelFrozen) ? 1.0 : 0.0;
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
				if (pop && n.jet)
				{
					// the jet: ballistic, spinning, fading from tic 12
					n.scaleNow = n.size * (t < 2 ? 0.6 + 0.4 * t / 2.0 : 1.0);
					if (!n.frozen && !n.kill)
					{
						n.jetPos += n.vel * dt;
						n.vel.z -= JET_G * n.grav * dt;
						n.roll += n.spin * dt;
					}
					n.alpha = t < 12 ? 1.0 : 1.0 - (t - 12) / double(JET_LIFE - 12);
				}
				else if (pop)
				{
					n.scaleNow = n.size * PopCurve(t, n.popFrom);
					n.alpha = t < 16 ? 1.0 : 1.0 - (t - 16) / 10.0;
				}
				else
				{
					n.scaleNow = n.size;
					n.tossVZ -= (physics == 1 ? 0 : 0.4) * dt;
					n.tossX += n.tossVX * dt; n.tossY += n.tossVY * dt; n.tossZ += n.tossVZ * dt;
					n.alpha = t < 10 ? 1.0 : 1.0 - (t - 10) * 0.05;
				}
				if (n.kill && slam && t >= 3 && !n.frozen) { n.st = RSQTHP_DnNum.S_KILL; n.stT = t; }
				else if (n.alpha <= 0 || t >= 40) n.Free(self);
			}
			else if (n.st == RSQTHP_DnNum.S_KILL) Kill(n, t);
			break;

		case RSQTHP_DnNum.K_TOTAL:
			if (n.st == RSQTHP_DnNum.S_LIVE)
			{
				// rolls up like a counter
				if (n.shown < n.value) n.shown = min(double(n.value), n.shown + max(1.0, (n.value - n.shown) * 0.35) * max(dt, 0.0));
				int age = level.maptime - n.lastHit;
				n.alpha = age <= FADE_FROM ? 1.0 : 1.0 - double(age - FADE_FROM) / (CHAIN_GAP - FADE_FROM);
				if (!n.who || n.who.health <= 0) n.alpha = min(n.alpha, 1.0 - (level.maptime - max(n.lastHit, n.born)) / 12.0);
				if (n.alpha <= 0) n.Free(self);
			}
			else if (n.st == RSQTHP_DnNum.S_KILL) Kill(n, t);
			break;

		case RSQTHP_DnNum.K_GAIN:
			if (n.st == RSQTHP_DnNum.S_LIVE)
			{
				n.scaleNow = PopCurve(t, 0.35);
				n.rise = max(0.0, t - 2) * 0.6;
				n.alpha = 1;
				if (t >= 8) { n.st = RSQTHP_DnNum.S_FLY; n.stT = t; n.flyAt = n.at; n.flyScale = n.scaleNow; }
			}
			else if (n.st == RSQTHP_DnNum.S_FLY)
			{
				// shrinks on the way in: on the wrist it is about 7 cm tall a forearm from your eyes, not a hand's width
				double e = clamp((t - n.stT) / 12.0, 0.0, 1.0);
				n.scaleNow = 1.0 + (min(1.0, landH / hitH) - 1.0) * e;
				if (e >= 1) { n.st = RSQTHP_DnNum.S_LAND; n.stT = t; }
			}
			else if (n.st == RSQTHP_DnNum.S_LAND)
			{
				double e = t - n.stT;
				n.scaleNow = min(1.0, landH / hitH);
				// with Gun Cards: fades into its own +N (4 tics); without: stays on the wrist a moment, then fades
				double hold = n.landOnCards ? 0 : 20, fade = n.landOnCards ? 4 : 8;
				n.alpha = e <= hold ? 1.0 : 1.0 - (e - hold) / fade;
				if (n.alpha <= 0) n.Free(self);
			}
			break;

		case RSQTHP_DnNum.K_BANNER:
			n.alpha = clamp(min(t / 5.0, (BANNER_DUR - t) / 6.0), 0.0, 1.0);
			// the slow-motion pulse, through the readable part (RSQ SlowMo's door, by name: rsm_pulse <ms> <depth %>)
			if (lvlSlow && !n.slowSent && t >= BANNER_DUR / 2 - 8)
			{
				n.slowSent = true;
				EventHandler.SendNetworkEvent("rsm_pulse", 500, 30);
			}
			if (t >= BANNER_DUR) n.Free(self);
			break;

		case RSQTHP_DnNum.K_TAG:
			n.alpha = clamp(min(t / 4.0, (TAG_DUR - t) / 8.0), 0.0, 1.0);
			if (t >= TAG_DUR) n.Free(self);
			break;

		case RSQTHP_DnNum.K_SEQ:
			// RSQ SlowMo's DOWN time added ("+0.5s"): pops, holds, drifts up, fades (1.7 s)
			n.scaleNow = n.size * PopCurve(t, 0.35);
			n.rise = max(0.0, t - 8) * 0.22;
			n.alpha = t < 44 ? 1.0 : 1.0 - (t - 44) / 16.0;
			if (t >= 60) n.Free(self);
			break;
		}
	}

	// the kill: one punch, a hold, a fade (no sprite, no burst)
	void Kill(RSQTHP_DnNum n, double t)
	{
		double e = t - n.stT;
		n.scaleNow = (n.kind == RSQTHP_DnNum.K_HIT ? n.size : 1.0) * Punch(e);
		n.alpha = e < 14 ? 1.0 : 1.0 - (e - 14) / 10.0;
		if (e >= 24) n.Free(self);
	}

	// ---- where it stands, and its glyphs ----------------------------------------------------------------------------
	void Draw(RSQTHP_DnNum n, PlayerPawn pmo)
	{
		Vector3 at, prev;
		bool keepAway = true;
		double base = 1.0;          // world units per layout unit
		n.Layout(self);
		double H = RSQTHP_DnFonts.BASEH[face];
		// per part: where (view offsets, layout units), how big, how clear
		double digX = 0, digY = 0, digK = 1, comX = 0, comY = 0, comK = 1, wordY = 0, jx = 0, jy = 0;
		RSQTHP_Bar bar = null;
		switch (n.kind)
		{
		case RSQTHP_DnNum.K_HIT:
		{
			base = hitH / H;
			if (!pop && n.st == RSQTHP_DnNum.S_LIVE) at = n.p0 + (n.tossX, n.tossY, n.tossZ);
			else if (n.jet) at = n.jetPos;
			else if (n.st == RSQTHP_DnNum.S_KILL || n.kill) at = n.p0;
			else
			{
				// the arc: snaps out, up and out (eased), then drifts down a touch as it fades
				double t = n.t;
				double eo = 1.0 - (1.0 - clamp(t / 14.0, 0.0, 1.0)) ** 2;
				double eu = sin(clamp(t / 11.0, 0.0, 1.0) * 90.0);
				double drop = max(0.0, t - 14) * 0.03 * hitH;
				double o = n.arcOut * (0.25 + 0.75 * eo);
				double u = max(0.0, n.arcUp * eu - drop);
				at = n.p0 + n.arcR * o + (0, 0, u);
			}
			// HEADSHOT: a sharp jolt over its first tics
			if (n.head && headW && n.t < 5)
			{
				static const double J[] = { 0.55, -0.4, 0.25, -0.12, 0.05 };
				jx = J[clamp(int(n.t), 0, 4)] * H;
			}
			break;
		}
		case RSQTHP_DnNum.K_TOTAL:
		{
			// above its HP bar: the digits centred over it, the combo beside it (scaled with the bar, which grows with range)
			bar = BarOf(n.who);
			double sy = 0.3, up = 0, barHalf = -1;
			if (n.who && bar && !bar.bInvisible)
			{
				sy = bar.Scale.Y;
				up = bar.Pos.z - bar.who.Pos.z;
				barHalf = 56 * bar.Scale.X + (bar.stat != null ? 26 * sy : 0) + 2.5;
			}
			else if (n.who) { up = RSQTHP_Bar.TopOf(n.who) * 1.15 + 6; let cs = CVar.FindCVar('rsqthp_scale'); sy = cs ? cs.GetFloat() : 0.3; }
			base = hitH / H;        // no growth with range (headset 11-03): the total 1.2x a hit, the combo a word
			double grw = 1.0 + 0.06 * min(n.hits, 5);
			double ab = n.t - n.bumpT;
			double bounce = (n.bumpT > 0 || n.hits > 0) && ab < 10 ? 1.0 + 0.25 * exp(-ab / 3.0) * cos(ab * 75.0) : 1.0;
			bounce = 1.0 + (bounce - 1.0) * 0.6;       // calm: a small bounce
			digK = 1.2 * grw * bounce;
			comK = grw * bounce;
			if (n.st == RSQTHP_DnNum.S_KILL) { digK = 1.2 * grw * Punch(n.t - n.stT); comK = grw; }
			// the room: a low ceiling puts the total beside the bar, a wall on the combo's side moves the combo (every 8 tics)
			if (n.who && n.st == RSQTHP_DnNum.S_LIVE && (level.maptime >= n.roomAt || !n.drawn)) Room(n, pmo, up, barHalf, base, H, digK, comK);
			double bh = 5.5 * sy / base + 0.62 * H * digK;      // half the bar + half the digits, layout units
			double gap = 0.18 * H;
			double half = barHalf >= 0 ? barHalf / base : n.width * 0.5 * digK;
			if (n.totalMode == 0) { digX = 0; digY = bh + gap; }
			else if (n.totalMode == 1) { digX = -n.comboSide * (half + gap + n.width * 0.5 * digK); digY = 0; }
			else { digX = 0; digY = -(bh + gap); }
			comX = n.comboSide * (half + gap + n.comboW * 0.5 * comK); comY = 0;
			if (barHalf < 0) { digY = 0; digX = 0; comX = n.width * 0.5 * digK + gap + n.comboW * 0.5 * comK; n.comboSide = 1; }
			wordY = digY;
			// a shake from x5 (and through the kill's punch)
			if (shake && n.hits >= 5 && n.st == RSQTHP_DnNum.S_LIVE && level.maptime - n.lastHit < DRAIN_FROM)
			{
				// a smooth wobble (about 5 and 7 cycles a second, out of step), not a per-tic random jump
				double amp = 0.05 * H * min(1.0, 0.5 + 0.1 * (n.hits - 5));
				jx = amp * sin(n.t * 50.0); jy = amp * sin(n.t * 73.0 + 40.0);
			}
			if (n.st == RSQTHP_DnNum.S_KILL || !n.who) { at = n.at - n.slide; break; }
			at = n.who.Pos + (0, 0, up);
			break;
		}
		case RSQTHP_DnNum.K_GAIN:
		{
			keepAway = false;
			base = hitH / H;
			Vector3 wr = WristOf(pmo, n.hand);
			if (n.st == RSQTHP_DnNum.S_LIVE) at = n.p0 + (0, 0, n.rise);
			else if (n.st == RSQTHP_DnNum.S_FLY)
			{
				double e = clamp((n.t - n.stT) / 12.0, 0.0, 1.0);
				e = e * e;
				at = n.flyAt + (wr - n.flyAt) * e;
			}
			else at = wr;
			break;
		}
		case RSQTHP_DnNum.K_SEQ:
			base = hitH / H;
			at = n.p0 + (0, 0, n.rise);
			break;
		case RSQTHP_DnNum.K_BANNER:
		{
			// 64 map units (about 2 m) along your gaze, nearer if a wall is closer; it follows your gaze lazily
			keepAway = false;
			double pit = clamp(camPitch, -25.0, 25.0);
			Vector3 gz = (cos(pit) * cos(camYaw), cos(pit) * sin(camYaw), -sin(pit));
			FLineTraceData d;
			double bd = 64;
			if (Trace(pmo, eye, gz, 72, d)) bd = clamp(d.Distance - 6, 16.0, 64.0);
			n.bandD = bd;
			Vector3 want = eye + gz * bd;
			n.p0 = n.drawn ? n.p0 + (want - n.p0) * 0.3 : want;
			at = n.p0;
			base = (n.p0 - eye).Length() / 64.0 * wordSize;
			break;
		}
		case RSQTHP_DnNum.K_TAG:
		{
			// rises off the gun and follows it (eased)
			keepAway = false;
			Vector3 want = HandPos(pmo, n.hand) + (0, 0, 3);
			// never nearer the eyes than 22 (a hand brought up to the face): pushed out along your line to it
			Vector3 ve = want - eye;
			if (ve.Length() < 22) want = eye + (ve.Length() > 0.01 ? ve.Unit() : (cos(camYaw), sin(camYaw), 0)) * 22;
			n.p0 = n.drawn ? n.p0 + (want - n.p0) * 0.4 : want;
			double tt = min(1.0, n.t / 10.0);
			double c1 = 1.70158, c3 = c1 + 1;
			double eob = 1 + c3 * (tt - 1) ** 3 + c1 * (tt - 1) ** 2;
			at = n.p0 + (0, 0, 5.0 * eob);
			base = 0.6 * wordSize;     // RSQ Gun Cards' sizes: the name as its title (0.84), LV n as its big digits (1.68)
			break;
		}
		}

		// out of your face: off either gun's aim line (eased), and never nearer the eyes than MIN_EYE
		double fk = (n.kind == RSQTHP_DnNum.K_HIT) ? FarK(at) : 1.0;
		double S = n.scaleNow * fk * base;
		if (n.kind == RSQTHP_DnNum.K_TOTAL || (n.kind >= RSQTHP_DnNum.K_BANNER && n.kind != RSQTHP_DnNum.K_SEQ)) S = fk * base;
		if (n.kind <= RSQTHP_DnNum.K_GAIN)
		{
			// near you never more than 1.8 degrees tall (tan 1.8 = 0.0314); a gain on its way to your wrist never more than
			// 2.5 degrees, the size RSQ Gun Cards' small digits measured on the rig beside it (p8_hands: its card's digits
			// about 4.5 degrees at its hand, the reserve half that)
			double dd = max(1.0, (at - eye).Length());
			double tall = (n.kind == RSQTHP_DnNum.K_GAIN) ? hitH * n.scaleNow : hitH * (n.kind == RSQTHP_DnNum.K_TOTAL ? 1.2 : n.size);
			double tanMax = (n.kind == RSQTHP_DnNum.K_GAIN && n.st != RSQTHP_DnNum.S_LIVE) ? 0.0437 : 0.0314;
			if (tall > dd * tanMax) S *= dd * tanMax / tall;
		}
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
			// eased slowly, and only for a real change: a tracked hand's tremor must not shake a number (headset 11-03)
			if ((want - n.slide).Length() > 0.75) n.slide += (want - n.slide) * 0.12;
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
		bool first = !n.drawn;
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
		double a = clamp(n.alpha, 0.0, 1.0);
		Vector3 toEye = n.dist > 0.01 ? (at - eye) / n.dist : (0, 0, 0);
		// the banner's lines scroll: in very fast, slow through the middle, fast out (x = K u^3, u from 1 to -1)
		double u = 1.0 - 2.0 * n.t / BANNER_DUR;
		double u3 = u * u * u;
		int ng = min(n.gl.Size(), n.gCode.Size());
		for (int i = 0; i < ng; i++)
		{
			let g = n.gl[i];
			if (!g) continue;
			int part = n.gPart[i];
			double ox = 0, oy = 0, k = 1, depth = 0, ga = a;
			double w, h;
			TextureID tx;
			Name tr;
			int tex = n.gTex[i];
			bool newG = first;
			// its texture
			if (tex == RSQTHP_DnNum.T_GLYPH) tx = fonts.Glyph(n.gFont[i], q, n.gCode[i], w, h);
			else
			{
				tx = TexMan.CheckForTexture(tex == RSQTHP_DnNum.T_BAND ? "RQNBAND" : (tex == RSQTHP_DnNum.T_TAGF ? "RQNTAGF" : "RQNTAGB"), TexMan.Type_Any);
				int iw, ih; [iw, ih] = TexMan.GetSize(tx); w = iw; h = ih;
			}
			if (!tx.IsValid() || h <= 0) { g.Alpha = 0; continue; }
			// its place
			switch (n.kind)
			{
			case RSQTHP_DnNum.K_HIT:
			case RSQTHP_DnNum.K_GAIN:
			case RSQTHP_DnNum.K_SEQ:
				ox = jx; break;
			case RSQTHP_DnNum.K_TOTAL:
				if (part == RSQTHP_DnNum.P_COMBO)
				{
					if (!combo) { g.Alpha = 0; continue; }
					ox = comX + jx; oy = comY + jy; k = comK;
				}
				else if (part == RSQTHP_DnNum.P_WORD) { ox = digX; oy = wordY; k = digK; }
				else
				{
					if (!total) { g.Alpha = 0; continue; }
					ox = digX + jx; oy = digY + jy; k = digK;
				}
				break;
			case RSQTHP_DnNum.K_BANNER:
				if (part == RSQTHP_DnNum.P_BG) { depth = 1.0; ga = a * 0.9; }
				else if (part == RSQTHP_DnNum.P_DIG) ox = 120.0 * u3;
				else if (part == RSQTHP_DnNum.P_SUB1) ox = 150.0 * u3;
				else ox = 185.0 * u3;
				if (part != RSQTHP_DnNum.P_BG) ga = 1.0;
				break;
			case RSQTHP_DnNum.K_TAG:
				if (part == RSQTHP_DnNum.P_BG) depth = 0.25;
				else if (part == RSQTHP_DnNum.P_BORDER) depth = 0.15;
				else if (part == RSQTHP_DnNum.P_LV && n.t >= 6) k = 1.0 + 0.3 * exp(-(n.t - 6) / 3.0);
				break;
			}
			// typed in: not there before its time; a white flash on arrival
			bool flashNow = false;
			if (n.gT0[i] >= 0)
			{
				if (n.t < n.gT0[i]) { g.Alpha = 0; g.Put(at, at); continue; }
				if (n.t < n.gT0[i] + 2) flashNow = true;
			}
			// its colour
			int fm = n.gFam[i] >= 0 ? n.gFam[i] : n.fam;
			if (n.kind == RSQTHP_DnNum.K_TOTAL && n.gFam[i] < 0)
			{
				fm = n.fam >= 0 ? n.fam : (n.ramp.Size() >= 4 ? n.ramp[n.ComboStep()] : 0);
			}
			// calm by default (headset 11-03 18:29): plain hits, totals and gains hold one colour; the Castlevania life (flash,
			// cycling, letters bobbing) is for HEADSHOTS (and crits later), and the level-up displays
			bool headLife = (n.kind == RSQTHP_DnNum.K_HIT && n.head && headW) || (n.special && n.kind != RSQTHP_DnNum.K_BANNER);
			int sh = 1;
			if (headLife) sh = Shade(i, true);
			else if ((n.kind == RSQTHP_DnNum.K_BANNER && part == RSQTHP_DnNum.P_DIG) || (n.kind == RSQTHP_DnNum.K_TAG && part == RSQTHP_DnNum.P_LV)) sh = Shade(i);
			if (n.kind == RSQTHP_DnNum.K_TAG && part == RSQTHP_DnNum.P_NEW) sh = ((int(n.t) / 3) & 1) ? 3 : 1;   // the green flicker
			if (n.kind == RSQTHP_DnNum.K_TOTAL && n.st == RSQTHP_DnNum.S_LIVE)
			{
				// cooling down: the colour drains, then greys and fades
				int age = level.maptime - n.lastHit;
				if (age > FADE_FROM) { fm = GREY; sh = 1; }
				else if (age > DRAIN_FROM) sh = 0;
			}
			if (headLife && flash && n.t < 2.5 && !n.frozen && !photo) flashNow = true;
			// a headshot's letters bob, one after another (gentle: 0.1 of a digit, about 1.4 cycles a second)
			if (headLife && cycle && !photo) oy += 0.1 * n.gH[i] * sin(n.t * 14.0 - i * 55.0);
			if (tex == RSQTHP_DnNum.T_BAND) tr = PalName(n.famWord, 0);
			else if (tex == RSQTHP_DnNum.T_TAGF) tr = 'RSQTHP_DnRaw';
			else if (tex == RSQTHP_DnNum.T_TAGB) tr = PalName(n.famWord, 1);      // one steady colour
			else if (flashNow) tr = FlashName();
			else if (n.trans != 'None' && n.gFam[i] < 0 && n.kind == RSQTHP_DnNum.K_HIT) tr = n.trans;
			else tr = PalName(fm, sh);
			g.Look(tx, tr);
			// its size
			double sc = n.gH[i] * k * S / h;
			if (tex == RSQTHP_DnNum.T_GLYPH) g.Scale = (sc, sc);
			else
			{
				double ww = tex == RSQTHP_DnNum.T_BAND ? 210.0 : n.gW[i];
				g.Scale = (ww * k * S / w, sc);
			}
			double gx = (ox + n.gX[i] * k) * S, gy = (oy + n.gY[i] * k) * S;
			g.Alpha = ga;
			if (n.jet && n.kind == RSQTHP_DnNum.K_HIT)
			{
				// a spinning jet: the whole number turns in the view (each glyph rolled, its column turned about the number's
				// middle), placed in the world so the engine interpolates every glyph between tics
				double cr = cos(n.roll), sr = sin(n.roll);
				double rx = gx * cr - gy * sr, ry = gx * sr + gy * cr;
				g.Offset = (0, 0);
				g.SetRolling(true, n.roll);
				Vector3 gp = at + camR * rx + camU * ry + toEye * (depth + i * 0.03) * S;
				g.Put(gp, newG ? gp : g.Pos);
				continue;
			}
			g.Offset = (gx, -gy * ps);
			// each glyph a hair behind the one before it: see-through quads at one depth swap order as the head moves (flicker)
			depth += i * 0.03;
			Vector3 gp = at + toEye * depth * S;
			g.Put(gp, newG ? gp : prev + toEye * depth * S);
		}
	}

	// a total's room: under a low ceiling the total goes beside the bar, against a wall the combo goes to the other side
	void Room(RSQTHP_DnNum n, PlayerPawn pmo, double up, double barHalf, double base, double H, double digK, double comK)
	{
		n.roomAt = level.maptime + 8;
		if (!clear || !n.who) { n.totalMode = 0; n.comboSide = 1; return; }
		Vector3 c = n.who.Pos + (0, 0, up);
		Vector3 r = (sin(camYaw), -cos(camYaw), 0);
		double half = barHalf >= 0 ? barHalf : n.width * 0.5 * digK * base;
		double comboReach = half + (0.2 * H + n.comboW * comK) * base + 1;
		FLineTraceData d;
		bool rightBlocked = Trace(pmo, c, r, comboReach, d);
		bool leftBlocked = Trace(pmo, c, -r, comboReach, d);
		// ... or hidden from you behind a wall nearer than it (a doorway's edge between your eyes and that end of the bar)
		if (!rightBlocked) rightBlocked = Hidden(pmo, c + r * comboReach);
		if (!leftBlocked) leftBlocked = Hidden(pmo, c - r * comboReach);
		int was = n.comboSide * 10 + n.totalMode;
		n.comboSide = (rightBlocked && !leftBlocked) ? -1 : 1;
		double cz = min(n.who.ceilingz, level.PointInSector(c.xy).ceilingplane.ZAtPoint(c.xy));
		double topNeed = (5.5 * 0.3 + (0.18 + 1.24 * digK) * H * base) + 1;
		if (c.z + topNeed <= cz) n.totalMode = 0;
		else n.totalMode = ((n.comboSide == 1 && !leftBlocked) || (n.comboSide == -1 && !rightBlocked)) ? 1 : 2;
		if (n.comboSide * 10 + n.totalMode != was) clamped++;
	}

	// is a spot hidden from your eyes by a wall?
	bool Hidden(PlayerPawn pmo, Vector3 spot)
	{
		Vector3 v = spot - eye;
		double vl = v.Length();
		if (vl < 1) return false;
		FLineTraceData d;
		return Trace(pmo, eye, v / vl, vl - 1, d);
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

	// only the Most Numbers nearest the eyes show (gains on you and the level-up displays always do)
	void Cull()
	{
		Array<double> d;
		for (int i = 0; i < nums.Size(); i++)
			if (nums[i].kind < RSQTHP_DnNum.K_GAIN || nums[i].kind == RSQTHP_DnNum.K_TOTAL) d.Push(nums[i].dist);
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
			if (n.kind >= RSQTHP_DnNum.K_GAIN) { n.hidden = false; continue; }
			// a little give at the cut, so a number on the edge does not blink in and out as the head moves
			double give = n.hidden ? 0 : 24;
			bool hide = n.dist > cut + give || (n.dist == cut && kept >= maxN);
			if (!hide && kept >= maxN + 2) hide = true;
			if (!hide) kept++;
			n.hidden = hide;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		ClearPending();
		nums.Clear();
		tAct.Clear(); tFirst.Clear(); tFirstN.Clear(); tFirstTic.Clear(); tTot.Clear(); tLane.Clear();
	}
}

// For other mods, by name (nothing links): RSQTHP_DnService.
//   GetInt("crit", "", tics, 0, monster) -> 1: hits on that monster in the next `tics` tics (default 2) are marked as
//   crits. Nothing is drawn for a crit yet: the CRIT word comes after 2.0, from a rebuilt Critical Shots (owner,
//   2026-11-03). -1: no Damage Numbers handler.
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
