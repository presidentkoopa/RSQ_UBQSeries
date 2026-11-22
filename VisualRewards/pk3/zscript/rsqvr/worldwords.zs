// RSQ VisualRewards -- THE WORLD WORDS (owner 2026-11-17, approved from design/mockups/world_words/ make.py and its GIFs):
// the four reward words stand in the 3D world as signs, in place of (or as well as) their HUD banners:
//   REVENGE!   over the monster that downed you, as you kill it (RSQ SlowMo's DOWN "down.revenge": the DOWN target, the
//              monster that put you DOWN, killed by your hand; down.zs). Magenta (the band's REVENGE_COL family).
//   REVIVE!    rises from the floor in front of you where you get back up (SlowMo's "down.up", every get-up). Cyan.
//   LEVEL UP!  at the muzzle of the gun in your hand (Gun Bonsai's "bonsai-level-up": a gun's level, at that gun's hand;
//              the player's level, at the main hand's gun; damnums/events.zs). Gold.
//   1UP        a Score life: rises from where it came from (RSQ Score's life crate you took), else in front of you at
//              chest height (Score's own target, another mod's "givelife"). Gold.
// HOW A SIGN LOOKS (the mockup): a flat line of letters that always faces you (each letter a VisualThinker quad, drawn from
// the centre eye as every word here: words.zs), in the Word Font (rsqvr_wordfont) and the SOTN two-tone look (the family's
// colour on the top half of each letter, its light shade on the bottom; the outline the near-black box). The SAME APPARENT
// SIZE AT ANY DISTANCE: its capitals are 3.7 degrees tall wherever it stands (the mockup: 30 px in a 720 px view), so its
// place follows the 3D spot in perspective and its size on screen does not change. Word Size (rsqthp_dn_wordsize) scales
// it; Monster Word Size does not (that row is the words over monsters).
// HOW IT MOVES: words.zs' SOTN entrance and life, the monster words' timings: tics 0-3 the smear (width x (1 + 0.3k), the
// top slanted 0.45k ahead, k = 1 - tic/4, drawn as four slices a letter), the snap at tic 4, the flash between its two
// looks every 4 tics to tic 28 (the light look first; none with Photosensitive Mode), then it drifts up 1.4 letter heights
// (1 - exp(-t/10)), holds (35 tics in all) and fades over 10. REVIVE! rises from the floor instead of drifting (to 6 units
// under your eye, 1 - exp(-t/9)), and so does a 1UP from a crate (from the crate's middle). The same word asked again
// for the same player and the same spot while it is up pops in place (no second smear), as a monster word does.
// NEVER THROUGH THE HUD: these are world quads, so the HUD's scaling never touches them.
// THE SETTING: Reward Words (rsqvr_rewardwords, user): 0 In the World (the default: the owner asked to see them), 1 On the
// HUD (as before: the banners and the band), 2 Both. In the World, the HUD banners of these four words do not show: the
// REVIVE, +1UP, LEVEL UP! and gun LEVEL banners (banners.zs Add: not queued; their chips go with them), the REVENGE and
// REVIVE words on the band (down.zs), and the old level-up band and gun tag (events.zs).
// COST: at most WWORD_CAP signs (the oldest goes); their letters come from the monster words' one glyph pool (words.zs,
// GLYPH_CAP); a sign holds no glyph while it is hidden. They age every tic, also while the world is frozen (RSQ Wheel's
// Level.SetFrozen), so none hangs over a frozen view; a map change drops them with the pool (words.zs WorldUnloaded) and a
// loaded save drops them (WorldLoaded). An anchor that dies or goes: the sign finishes where it last was.
// Each sign belongs to one player (the one whose moment it is) and is drawn only on that player's own machine.
//
// THE REQUEST (RSQVR_Service GetInt "worldword", service.zs): stringArg "<WORD>|<place>", nameArg the colour family
// ('magenta' / 'cyan' / 'gold'; also 'revenge', 'revive', 'levelup', '1up'), objectArg the anchor, intArg the player it
// is for when the anchor is not a player (-1: anyone's view). Places:
//   over           over objectArg (a monster): 10 units over its head (its standing height), followed while it lives
//   floor          rises from the floor 72 units in front of objectArg (a player; nearer when a wall is), else at its feet
//   muzzle:<hand>  at the muzzle of that hand's gun (0 main, 1 off) of objectArg (a player), followed while he lives:
//                  any Service named "...MuzzleService" answering GetString("muzzle.at", "", hand, 0, pawn) with "x y z"
//                  (RSQ LaserSight answers from Brutal Doom VR's own muzzle table, RSQ_Muzzle's, and from its measured
//                  meshes; a weapon pack may answer for its own guns), else 20 units in front of the weapon hand
//   at:<x>,<y>,<z> rises from that point (a point within 48 units of the player is moved out to 48 in front of him)
//   ahead          in front of objectArg (a player), 48 units out at chest height
//   hand:<h>[,<f>[,<u>]]  (2026-11-22) on what that hand of objectArg (a player) holds (0 main, 1 off), followed while
//                  he lives: f cm along the hand's aim and u cm up from the controller (RSQ Grenade's kind words on the
//                  grenade in the hand: the kind's name on the grenade itself)
// Keys beside the place (2026-11-22; none of them changes a word asked without them):
//   size:<k>       its size, k x the usual (0.2 .. 3; the default 1)
//   id:<name>      a new word with the same id for the same player REPLACES the one still up (the same text pops in
//                  place), so a word asked again and again (a kind cycled fast) never stacks
//   label          a label, not a reward: drawn whatever Reward Words says (there is no HUD banner for it)
// With no place: "over" for a monster, "ahead" for a player. Returns 1 (0: no word, or nothing to anchor it to). The
// answer never depends on a player's own setting (netplay): Reward Words only decides what is drawn on each machine.
// Test (console, sv_cheats): netevent rsqvr_wwtest <n>: 0 REVENGE! over the nearest monster in view (else ahead),
// 1 REVIVE!, 2 LEVEL UP! (main hand), 3 LEVEL UP! (off hand), 4 1UP ahead, 5 1UP from a point at your feet.

extend class RSQVR_Word
{
	bool world;            // a world word (this file); drawn by WorldStep, never stacked with the monster words
	int wKind, wHand, wPn, wBorn;
	Vector3 wAt;           // the spot it rises from / stands at / the muzzle this tic
	bool wFollow;          // still following its anchor (a living monster, a living player's gun)
	double wFwd, wUp;      // hand: the place along the hand's aim and up, cm (2026-11-22)
	String wId;            // id: a new word with this id replaces this one
	bool wLabel;           // label: drawn whatever Reward Words says
}

extend class RSQVR_FxHandler
{
	enum EWorldKind { WK_OVER, WK_RISE, WK_MUZZLE, WK_AHEAD, WK_HAND };
	enum ERewardPlace { RW_WORLD, RW_HUD, RW_BOTH };
	const WWORD_CAP = 6;
	const WW_TAN = 0.06467;          // tan(3.7 degrees): a capital's height on screen at any distance
	const WW_LIFE = 35;              // the monster words' one-off life (words.zs WordOnce: 1 s), then the 10-tic fade
	const WW_AHEAD = 48.0;           // "in front of you": 1.4 m
	const WW_FLOOR_AHEAD = 72.0;     // REVIVE!: from the floor 2.1 m ahead (the mockup)
	const WW_HAND_AHEAD = 20.0;      // no muzzle known: this far in front of the weapon hand
	Array<RSQVR_Word> wwords;
	transient double wwSize;
	transient int wwPlace;

	// Reward Words for player pn (its user cvar: synced, so play code may read any player's): 0 World, 1 HUD, 2 Both
	static clearscope int RewardPlace(int pn)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) pn = consoleplayer;
		let c = CVar.GetCvar('rsqvr_rewardwords', players[pn]);
		return c ? clamp(c.GetInt(), RW_WORLD, RW_BOTH) : RW_WORLD;
	}
	static clearscope bool RewardWorld(int pn) { return RewardPlace(pn) != RW_HUD; }
	static clearscope bool RewardHud(int pn) { return RewardPlace(pn) != RW_WORLD; }

	// the families the game already uses for these words (the mockup's pairs: top, bottom): REVENGE magenta (the band's
	// REVENGE_COL 8), REVIVE cyan (REVIVE_COL 13), LEVEL UP and 1UP the series' arcade gold
	static int, int FamilyRgb(Name fam)
	{
		if (fam == 'magenta' || fam == 'revenge') return 0xE628DC, 0xFFAAF5;
		if (fam == 'cyan' || fam == 'revive') return 0x14C8E6, 0x96FAFF;
		return 0xF09614, 0xFFEC78;
	}

	int WorldWord(String spec, Name fam, int pn, Actor a)
	{
		Array<String> parts;
		spec.Split(parts, "|");
		if (parts.Size() < 1 || parts[0] == "") return 0;
		String txt = parts[0].MakeUpper();
		if (a && a.bDestroyed) a = null;
		PlayerPawn pawn = null;
		if (a && a.player) pawn = PlayerPawn(a);
		if (pawn) pn = pawn.PlayerNumber();
		int kind = pawn ? WK_AHEAD : WK_OVER;
		int hand = 0;
		bool haveAt = false;
		Vector3 at = (0, 0, 0);
		double sz = 1.0;
		double hf = 0;
		double hu = 0;
		String wid = "";
		bool label = false;
		for (int i = 1; i < parts.Size(); i++)
		{
			Array<String> kv;
			parts[i].Split(kv, ":");
			if (kv.Size() < 1) continue;
			String k = kv[0].MakeLower();
			String v = kv.Size() > 1 ? kv[1] : "";
			if (k == "over") kind = WK_OVER;
			else if (k == "floor") kind = WK_RISE;
			else if (k == "muzzle") { kind = WK_MUZZLE; hand = clamp(v.ToInt(), 0, 1); }
			else if (k == "ahead") kind = WK_AHEAD;
			else if (k == "hand")
			{
				Array<String> hv;
				v.Split(hv, ",");
				kind = WK_HAND;
				hand = hv.Size() > 0 ? clamp(hv[0].ToInt(), 0, 1) : 0;
				if (hv.Size() > 1) hf = hv[1].ToDouble();
				if (hv.Size() > 2) hu = hv[2].ToDouble();
			}
			else if (k == "size") sz = clamp(v.ToDouble(), 0.2, 3.0);
			else if (k == "id") wid = v;
			else if (k == "label") label = true;
			else if (k == "at")
			{
				Array<String> c;
				v.Split(c, ",");
				if (c.Size() >= 3) { at = (c[0].ToDouble(), c[1].ToDouble(), c[2].ToDouble()); haveAt = true; kind = WK_RISE; }
			}
		}
		if (!a && !haveAt) return 0;
		// the places that need a player fall back to the actor itself
		if (!pawn && (kind == WK_MUZZLE || kind == WK_AHEAD || kind == WK_HAND)) kind = WK_OVER;
		if (!a && kind != WK_RISE) return 0;

		// where it starts
		Vector3 src = (0, 0, 0);
		if (kind == WK_RISE)
		{
			if (haveAt)
			{
				src = at;
				if (pawn && (at.xy - pawn.Pos.xy).Length() < WW_AHEAD) { src = Ahead(pawn, WW_AHEAD); src.z = at.z; }
			}
			else if (pawn) { src = Ahead(pawn, WW_FLOOR_AHEAD); src.z = FloorAt(src, pawn); }
			else src = a.Pos;
		}
		else if (kind == WK_MUZZLE) src = MuzzleAt(pawn, hand);
		else if (kind == WK_HAND) src = HandAt(pawn, hand, hf, hu);
		else if (kind == WK_AHEAD) { src = Ahead(pawn, WW_AHEAD); src.z = pawn.player ? pawn.player.viewz - 12 : pawn.Pos.z + pawn.Height * 0.6; }

		// id: the word up with this id for this player goes (the same text pops in place instead, below)
		if (wid != "")
		{
			for (int i = wwords.Size() - 1; i >= 0; i--)
			{
				let w = wwords[i];
				if (!w || w.wId != wid || w.wPn != pn) continue;
				if (w.text == txt && w.wKind == kind && w.t < w.life)
				{
					w.who = a; w.wHand = hand; w.wFwd = hf; w.wUp = hu; w.wAt = src; w.size = sz;
					if (w.wBorn != level.maptime) { w.t = 0; Repop(w); }
					return 1;
				}
				FreeWord(w);
				wwords.Delete(i);
			}
		}
		// the same word for the same player on the same spot while it is up: it pops in place (the same tic: it is one)
		for (int i = 0; i < wwords.Size(); i++)
		{
			let w = wwords[i];
			if (!w || w.text != txt || w.wPn != pn || w.wKind != kind || w.t >= w.life) continue;
			bool same = (kind == WK_OVER || kind == WK_MUZZLE || kind == WK_HAND) ? (w.who == a && w.wHand == hand) : (w.wAt - src).Length() < 32;
			if (!same) continue;
			if (w.wBorn != level.maptime) { w.t = 0; Repop(w); }
			return 1;
		}

		if (wwords.Size() >= WWORD_CAP) { FreeWord(wwords[0]); wwords.Delete(0); }
		int top, bot;
		[top, bot] = FamilyRgb(fam);
		let nw = new("RSQVR_Word");
		nw.world = true;
		nw.text = txt;
		nw.rgb = top; nw.rgb2 = bot; nw.sotn = true;
		nw.life = WW_LIFE;
		nw.size = sz;
		nw.wFwd = hf; nw.wUp = hu; nw.wId = wid; nw.wLabel = label;
		nw.et = -1;
		nw.wKind = kind; nw.wHand = hand; nw.wPn = pn; nw.wBorn = level.maptime;
		nw.wAt = src;
		nw.who = a;
		nw.wFollow = a && a.health > 0 && (kind == WK_OVER || kind == WK_MUZZLE || kind == WK_HAND);
		if (a)
		{
			// over a monster: its standing height (a body falling over keeps its place, not its corpse's height)
			let def = GetDefaultByType(a.GetClass());
			nw.lastPos = a.Pos; nw.lastH = max(a.Height, def ? def.Height : a.Height); nw.lastCeil = a.ceilingz;
		}
		else { nw.lastPos = src; nw.lastH = 0; nw.lastCeil = src.z - 1; }
		wwords.Push(nw);
		let dc = CVar.FindCVar("rsqsm_debug");
		String famS = fam;
		if (dc && dc.GetBool())
			Console.Printf("RSQ VisualRewards: world word %s (%s, kind %d, hand %d, player %d) from %.0f %.0f %.0f%s", txt, famS, kind, hand, pn,
				src.x, src.y, src.z, a ? String.Format(" on %s", a.GetClassName()) : "");
		return 1;
	}

	// a point dist in front of the player at his eye's height, stopped 8 short of a wall (traced from the eye)
	static Vector3 Ahead(PlayerPawn p, double dist)
	{
		double ez = p.player ? p.player.viewz : p.Pos.z + p.Height * 0.8;
		Vector2 dir = (cos(p.angle), sin(p.angle));
		FLineTraceData tr;
		double d = dist;
		// TRF_ABSPOSITION with the eye as the start: in VR (OverrideAttackPosDir) relative offsets are not safe (LaserSight)
		if (p.LineTrace(p.angle, dist + 8, 0, TRF_ABSPOSITION | TRF_THRUACTORS, ez, p.Pos.x, p.Pos.y, tr) && tr.HitType != TRACE_HitNone)
			d = clamp(tr.Distance - 8, 12.0, dist);
		return (p.Pos.xy + dir * d, ez);
	}
	// the floor at a spot; a ledge or pit more than 48 units off his own floor: his own floor
	static double FloorAt(Vector3 at, Actor p)
	{
		let s = Level.PointInSector(at.xy);
		double fz = s ? s.floorplane.ZatPoint(at.xy) : p.floorz;
		return abs(fz - p.floorz) > 48 ? p.floorz : fz;
	}
	// THE MUZZLE of a hand's gun (see the header): a "...MuzzleService" by name, else in front of the weapon hand
	static Vector3 MuzzleAt(PlayerPawn pmo, int hand)
	{
		if (!pmo) return (0, 0, 0);
		let it = ServiceIterator.Find("MuzzleService");
		Service sv;
		while (sv = it.Next())
		{
			String r = sv.GetString("muzzle.at", "", hand, 0, pmo);
			if (r == "") continue;
			Array<String> f;
			r.Split(f, " ", TOK_SKIPEMPTY);
			if (f.Size() < 3) continue;
			return (f[0].ToDouble(), f[1].ToDouble(), f[2].ToDouble());
		}
		return RSQTHP_DamNumHandler.HandPos(pmo, hand) + RSQTHP_DamNumHandler.HandDir(pmo, hand) * WW_HAND_AHEAD;
	}

	// THE HAND (2026-11-22): what a player's hand holds, f cm along its aim and u cm up from the controller (the hand's own
	// position and aim, the engine's fields: no frame is rendered for it). Its roll and its sideways offset are not read:
	// a few cm on a word over what it holds.
	static Vector3 HandAt(PlayerPawn pmo, int hand, double f, double u)
	{
		if (!pmo) return (0, 0, 0);
		let vc = CVar.FindCVar("vr_vunits_per_meter");
		double vu = vc ? vc.GetFloat() : 34.0;
		if (vu <= 0) vu = 34.0;
		double ps = pmo.Level.pixelstretch;
		if (ps <= 0) ps = 1.2;
		Vector3 at = RSQTHP_DamNumHandler.HandPos(pmo, hand) + RSQTHP_DamNumHandler.HandDir(pmo, hand) * (f * vu / 100.0);
		at.z += u * vu / 100.0 / ps;
		return at;
	}

	// ---- each tic (DrawStep, after the monster words) -----------------------------------------------------------------
	void WorldStep(Vector3 eye, bool haveCam, double ps)
	{
		let c = CVar.GetCvar('rsqthp_dn_wordsize', players[consoleplayer]);
		wwSize = c ? clamp(c.GetFloat(), 0.25, 4.0) : 1.0;
		wwPlace = RewardPlace(consoleplayer);
		for (int i = wwords.Size() - 1; i >= 0; i--)
		{
			let w = wwords[i];
			if (!w) { wwords.Delete(i); continue; }
			if (w.who && w.who.bDestroyed) w.who = null;
			if (w.wFollow)
			{
				if (!w.who || w.who.health <= 0) w.wFollow = false;
				else if (w.wKind == WK_OVER) { w.lastPos = w.who.Pos; w.lastCeil = w.who.ceilingz; }
				else if (w.wKind == WK_MUZZLE) w.wAt = MuzzleAt(PlayerPawn(w.who), w.wHand);
				else if (w.wKind == WK_HAND) w.wAt = HandAt(PlayerPawn(w.who), w.wHand, w.wFwd, w.wUp);
			}
			// they age every tic, the world frozen or not (RSQ Wheel): a sign never hangs over a frozen view
			w.t++;
			if (w.et >= 0) w.et++;
			if (w.t >= w.life + 10) { FreeWord(w); wwords.Delete(i); continue; }
			if (!haveCam || (wwPlace == RW_HUD && !w.wLabel) || (w.wPn >= 0 && w.wPn != consoleplayer)) { HideWord(w); continue; }
			DrawWord(w, eye, 0, ps, 0);
		}
	}

	// where a world word's foot stands this tic (before its drift up)
	Vector3 WorldBase(RSQVR_Word w, Vector3 eye)
	{
		if (w.wKind == WK_OVER) return (w.lastPos.xy, w.lastPos.z + w.lastH + 10);
		if (w.wKind == WK_MUZZLE) return w.wAt + (0, 0, 2);
		if (w.wKind == WK_HAND) return w.wAt;
		if (w.wKind == WK_RISE)
		{
			double z0 = w.wAt.z, z1 = max(z0, eye.z - 6);
			return (w.wAt.xy, z0 + (z1 - z0) * (1.0 - exp(-w.t / 9.0)));
		}
		return w.wAt;
	}
	// map units per font pixel for the same apparent size at any distance (its capitals WW_TAN x the distance tall)
	// (2026-11-22: k, the word's own size: the size: key, 1 without it)
	double WorldUnit(Vector3 foot, Vector3 eye, double k = 1.0) { return max((eye - foot).Length(), 16.0) * WW_TAN * wwSize * k / WF_FH(wfont); }

	void DropWorldWords()
	{
		for (int i = 0; i < wwords.Size(); i++) FreeWord(wwords[i]);
		wwords.Clear();
	}

	// ---- the test hook (sv_cheats) ------------------------------------------------------------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqvr_wwtest")) return;
		let ch = CVar.FindCVar("sv_cheats");
		if (!ch || !ch.GetBool()) return;
		if (e.Player < 0 || !playeringame[e.Player] || !players[e.Player].mo) return;
		let mo = players[e.Player].mo;
		switch (e.Args[0])
		{
		case 0:
		{
			Actor best = null;
			double bd = 2048;
			let bi = BlockThingsIterator.Create(mo, 2048);
			while (bi.Next())
			{
				let m = bi.thing;
				if (!m || !m.bIsMonster || m.health <= 0 || !mo.CheckSight(m)) continue;
				double d = mo.Distance3D(m);
				if (d < bd && abs(Actor.DeltaAngle(mo.angle, mo.AngleTo(m))) < 45) { bd = d; best = m; }
			}
			if (best) WorldWord("REVENGE!|over", 'magenta', e.Player, best);
			else WorldWord("REVENGE!|ahead", 'magenta', e.Player, mo);
			break;
		}
		case 1: WorldWord("REVIVE!|floor", 'cyan', e.Player, mo); break;
		case 2: WorldWord("LEVEL UP!|muzzle:0", 'gold', e.Player, mo); break;
		case 3: WorldWord("LEVEL UP!|muzzle:1", 'gold', e.Player, mo); break;
		case 4: WorldWord("1UP|ahead", 'gold', e.Player, mo); break;
		case 5: WorldWord(String.Format("1UP|at:%.2f,%.2f,%.2f", mo.Pos.x, mo.Pos.y, mo.Pos.z + 16), 'gold', e.Player, mo); break;
		}
	}
}
