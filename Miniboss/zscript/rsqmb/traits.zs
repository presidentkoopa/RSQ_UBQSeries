// ============================================================================
// RSQ_Miniboss -- BOSS TRAITS (the owner's pick, 2026-11-25): every normal Boss fight (never a Big Boss) rolls ONE of four
// traits and shows it, one word, in the trait's colour, under the Boss's name on the Boss bar from the landing on
// (owner: "'Summoner!' is enough, who needs the explanation"). Code only, not run (owner: no rig checks until the Boss
// work is all coded).
//
//   ALL        a steady aura in the trait's colour (a ring of particles at its feet, a light at its feet in that colour);
//              every trick is wound up at least 1 s: the aura flares, a sound (Doom's own, by name), ONE word over it
//              (RSQ VisualRewards "word", by name). Photosensitive Mode (RSQMB_A11y.Photo): the flare is a steady brighter
//              glow, nothing pulses. Colour-blind play (RSQ Accessibility's rsqa_colorblind, read as RSQ Score reads it):
//              the trait's letter in brackets before its word ([S] SUMMONER!, [C] CHARGER!, [H] SHIELDED!, [P]
//              SPLITTER!; three of the four start with S, so Shielded is H and Splitter P: the owner's call to change).
//   SUMMONER   (green) every rsqmb_trait_sum_secs (15 s) it stands and casts: SUMMON! over it, green rings on the floor
//              where its fodder will land, rsqmb_trait_sum_cast (1.5 s) ahead; then 2-3 (rsqmb_trait_sum_min/_max) land
//              on the rings in a teleport fog. Hurting it during the cast cuts it short: each rsqmb_trait_sum_cut % of its
//              life's health dealt in the cast takes one ring away (all of them: nothing lands). FODDER: the lower
//              families (Imp, Demon, Spectre, Lost Soul; the zombie families only when the map has them: hitscan),
//              RSQ Monsters' ColorfulHell class at the World Tier (RSQMN_RosterService "set.class", by name), else
//              Doom's own (with whatever replaces it). Not thralls (no damage cut, no bar), no Champion roll, out of the
//              map's kill count, no Boss meter fill and no gun drop (RSQMB_Called), never more than
//              rsqmb_trait_sum_cap (6) alive, and they die with the Boss.
//   CHARGER    (orange-red) every rsqmb_trait_chg_secs (10 s): it plants itself, CHARGE!, two stamps (a small quake:
//              QuestZDoom sends it to the controllers; RSQ Accessibility's Rumble Backup buzz too, by name) and a bright
//              line on the floor from it to you; at the second stamp the line locks, and at rsqmb_trait_chg_wind
//              (1.2 s) it rushes along it at rsqmb_trait_chg_speed. SIDESTEPPED: it hits the wall (or skids to a stop
//              past where you stood) and is STUNNED rsqmb_trait_chg_stun (2 s): held in its pain state, taking x
//              rsqmb_trait_chg_stun_mult (1.5) damage (the telegraph's weak points belong to its wind-up, so the stun
//              is a stagger and a multiplier). HIT: rsqmb_trait_chg_dmg and knocked back rsqmb_trait_chg_push, and its
//              next charge comes x rsqmb_trait_chg_sooner (0.5) the wait. A body rush, no hitscan.
//   SHIELDED   (steel blue) a shell over its front half: a blow from within rsqmb_trait_shd_arc (90) degrees of where it
//              faces is turned (where a missile or a splash came from, else where the attacker stands): sparks, and
//              "BLOCKED" in grey at most once a second. From behind: full damage. rsqmb_trait_shd_points (3) WEAK!
//              points on the shell's rim (the telegraph's own RSQMB_WeakPoint, its crosshair and WEAK!): break them all
//              and the shell shatters, full damage for the rest of that life; a new life brings the shell back. (My
//              rule: a BREAK! stagger opens the shell too, so its x2 can land.)
//   SPLITTER   (purple) near the end of each life but the last (1 s ahead: its life's health left under the players'
//              damage per second x 1 s, or under rsqmb_trait_spl_warn % of it): SPLITTING! held over it and a glowing
//              crack up its front. On losing the life it becomes two: itself and a copy of its own class beside it,
//              both scaled x rsqmb_trait_spl_scale (0.7) again each split, the life's health split between them, each
//              dealing x rsqmb_trait_spl_dmg (0.75), each with the purple aura. Both must die to end that life: while
//              the copy stands the Boss's body cannot go under 2 health; spent, it kneels (held in its pain state)
//              until the copy is dead, then the life is lost (the last life: it dies, the copy's killer its killer).
//              The Boss bar shows the two together (its body's health, 0 once spent, + the copy's).
// Hooks (the smallest): fight.zs FightTick -> TraitTick; items.zs RSQMB_Ward -> TraitBlocks / TraitMult / TraitClamp /
// TraitHurt / TraitOut; telegraph.zs Step holds its wind-up while a trick runs (TraitBusy); bossbar.zs the word (BBTrait)
// and the bar's health (TraitBarHP). Debug lines (rsqmb_debug 1): "RSQMB trait ...".
// ============================================================================

extend class RSQMB_Boss
{
	int  trait;                 // RSQMB_Trait.TR_*, 0 none (a Big Boss; traits off)
	bool traitSet;              // rolled (TraitTick)
	RSQMB_Trait trt;            // its trait's thinker

	clearscope bool TraitBusy() const { return trt && trt.Busy(); }
	// items.zs RSQMB_Ward
	bool TraitBlocks(Actor inflictor, Actor source) { return trt && trt.Blocks(inflictor, source); }
	clearscope double TraitMult() const { return trt ? trt.TakeMult() : 1.0; }
	int TraitClamp(int nd) { return trt ? trt.HoldHit(nd) : nd; }
	void TraitHurt(int nd) { if (trt && nd > 0) trt.Hurt(nd); }
	clearscope double TraitOut() const { return trt ? trt.OutMult() : 1.0; }
	// bossbar.zs: the health the bar shows (SPLITTER: the body and its copy together)
	clearscope int TraitBarHP() const
	{
		if (!mb) return 0;
		if (!trt || trt.kind != RSQMB_Trait.TR_SPLITTER) return mb.health;
		return (trt.splSpent ? 0 : mb.health) + trt.CopyHP();
	}
}

extend class RSQMB_Handler
{
	int arrTrait, arrTraitTic;  // the trait rolled for the Boss landing now (its bar shows it from the landing)

	static clearscope bool TraitsOn() { return CI('rsqmb_traits', 1) != 0; }
	static clearscope bool TraitAllowed(int k)
	{
		switch (k)
		{
		case RSQMB_Trait.TR_SUMMONER: return CI('rsqmb_trait_summoner', 1) != 0;
		case RSQMB_Trait.TR_CHARGER:  return CI('rsqmb_trait_charger', 1) != 0;
		case RSQMB_Trait.TR_SHIELDED: return CI('rsqmb_trait_shielded', 1) != 0;
		case RSQMB_Trait.TR_SPLITTER: return CI('rsqmb_trait_splitter', 1) != 0;
		}
		return false;
	}
	int RollTrait()
	{
		if (!TraitsOn()) return 0;
		Array<int> ok;
		for (int k = 1; k <= 4; k++) if (TraitAllowed(k)) ok.Push(k);
		if (ok.Size() == 0) return 0;
		return ok[random[rsqmbtr](0, ok.Size() - 1)];
	}

	// fight.zs FightTick, every tic
	void TraitTick()
	{
		if (arrPhase != 0 && arrTraitTic != arrTic)
		{
			arrTraitTic = arrTic;
			arrTrait = arrBig ? 0 : RollTrait();
			if (debug) Console.Printf("RSQMB trait t%d: the landing Boss rolls %s", level.maptime, arrBig ? "none (a Big Boss)" : RSQMB_Trait.NameOf(arrTrait));
		}
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (!b || b.done || !b.mb || b.traitSet) continue;
			b.traitSet = true;
			b.trait = b.big ? 0 : (arrTrait > 0 ? arrTrait : RollTrait());
			arrTrait = 0;
			if (b.trait > 0) RSQMB_Trait.Make(b);
			if (debug) Console.Printf("RSQMB trait t%d: boss %d %s is %s", level.maptime, b.idx, b.mb.GetClassName(), b.trait > 0 ? RSQMB_Trait.NameOf(b.trait) : "no trait");
		}
	}

	// bossbar.zs: the trait's word under the bar, in its colour (the silver score font, tinted)
	ui void BBTrait(RSQMB_Boss b, RSQMB_Handler hd, double ar)
	{
		int k = b ? b.trait : (hd && hd.arrPhase != 0 ? hd.arrTrait : 0);
		if (k <= 0 || ar <= 0) return;
		String w = RSQMB_Trait.Shown(RSQMB_Trait.NameOf(k), k);
		Color c = RGBc(RSQMB_Trait.RGBOf(k));
		BBWordTint(w, 192, 132, 24, Color(255, 0, 0, 0), ar * 0.7);   // a dark drop shadow
		BBWordTint(w, 190, 130, 24, c, ar);
	}
	ui void BBWordTint(String s, double mx, double my, double hgt, Color c, double a)
	{
		double k = hgt / 48.0;
		double cx = mx;
		for (int i = 0; i < int(s.Length()); i++)
		{
			int ch = s.ByteAt(i);
			if (ch >= 97 && ch <= 122) ch -= 32;
			TextureID g = TexMan.CheckForTexture(String.Format("MBFS%03d", ch), TexMan.Type_Any);
			if (ch == 32 || !g.IsValid()) { cx += 18 * k; continue; }
			Vector2 gs = TexMan.GetScaledSize(g);
			double gw = gs.x * k;
			Screen.DrawTexture(g, false, BX(cx), BY(my), DTA_DestWidthF, gw * bbSx, DTA_DestHeightF, hgt * bbSy, DTA_Color, c, DTA_Alpha, a * bbA);
			cx += gw + 2 * k;
		}
	}
}

// ============================================================================
// THE TRAIT: one thinker a Boss, after its telegraph (STAT_TELE 124) every tic
// ============================================================================
class RSQMB_Trait : Thinker
{
	const STAT_TRAIT = 125;
	enum EKind { TR_NONE, TR_SUMMONER, TR_CHARGER, TR_SHIELDED, TR_SPLITTER }
	enum EChg { CH_IDLE, CH_WIND, CH_RUSH, CH_SKID, CH_STUN }

	RSQMB_Boss b;
	int  kind, lostSeen, nextAt, flareUntil, lightTic;

	// SUMMONER
	int  sumAt, sumUntil, sumDealt;
	Array<double> sX, sY, sZ;
	Array<String> sCls;
	Array<Actor> fodder;
	// CHARGER
	int  chg, chgAt, chgUntil, chgBlocks;
	double chgDX, chgDY, chgLen, chgRun, chgSpd;
	bool chgLocked, chgSoon;
	// SHIELDED
	bool shdUp;
	int  shdWordAt, shdSndAt;
	Array<RSQMB_RimPoint> rim;
	// SPLITTER
	Array<Actor> spl;
	bool splWarn, splSpent;
	int  splWarnAt, splGen;
	double splK;
	Actor splKiller;
	Array<double> crkX, crkZ;   // the crack's points (across its width as a share of its radius, up its height)

	// ---- the trait's look and words -------------------------------------------------------------------------------
	static clearscope int RGBOf(int k)
	{
		static const int RGB[] = { 0xC8C8C8, 0x40F060, 0xFF5A1E, 0x6E9BD0, 0xB050F0 };
		return (k >= 0 && k <= 4) ? RGB[k] : 0xC8C8C8;
	}
	static clearscope String NameOf(int k)
	{
		static const String N[] = { "-", "SUMMONER!", "CHARGER!", "SHIELDED!", "SPLITTER!" };
		return (k >= 0 && k <= 4) ? N[k] : "-";
	}
	static clearscope String LetterOf(int k)
	{
		static const String L[] = { "", "S", "C", "H", "P" };
		return (k >= 0 && k <= 4) ? L[k] : "";
	}
	// rsqa_colorblind (RSQ Accessibility, read only while it is loaded: RSQMB_A11y's guard), 0 off
	static clearscope bool CBOn() { return clamp(RSQMB_A11y.I('rsqa_colorblind'), 0, 4) > 0; }
	static clearscope String Shown(String w, int k) { return CBOn() ? String.Format("[%s] %s", LetterOf(k), w) : w; }

	static clearscope double CF(Name n, double d) { return RSQMB_Handler.CF(n, d); }
	static clearscope int CI(Name n, int d) { return RSQMB_Handler.CI(n, d); }

	static RSQMB_Trait Make(RSQMB_Boss b)
	{
		let t = RSQMB_Trait(new("RSQMB_Trait"));
		t.ChangeStatNum(STAT_TRAIT);
		t.b = b;
		t.kind = b.trait;
		t.lostSeen = b.lifeLostAt;
		t.splK = 1.0;
		b.trt = t;
		if (t.kind == TR_SHIELDED) t.shdUp = true;
		return t;
	}

	clearscope bool Busy() const
	{
		if (kind == TR_SUMMONER) return sumAt > 0;
		if (kind == TR_CHARGER) return chg != CH_IDLE;
		if (kind == TR_SPLITTER) return splSpent;
		return false;
	}

	void Dbg(RSQMB_Handler h, String s)
	{
		if (h && h.debug) Console.Printf("RSQMB trait t%d: boss %d %s: %s", level.maptime, b ? b.idx : -1, NameOf(kind), s);
	}

	// the player the fight is with (telegraph.zs Victim's rule)
	PlayerPawn Victim()
	{
		if (b.tele) return b.tele.Victim();
		let mb = b.mb;
		if (mb.target && mb.target.player && mb.target.health > 0) return PlayerPawn(mb.target);
		PlayerPawn best = null;
		double bd = 1e12;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo || players[i].mo.health <= 0) continue;
			double d = mb.Distance3D(players[i].mo);
			if (d < bd) { bd = d; best = players[i].mo; }
		}
		return best;
	}

	// it may start a trick now: it can be fought, no GUARD, no wind-up or BREAK! of its telegraph on
	bool Free(int now)
	{
		if (b.Invulnerable() || b.guardUp || splSpent) return false;
		let t = b.tele;
		if (t && (t.windAt > 0 || t.brkUntil > now)) return false;
		return true;
	}

	// a word over it: VisualRewards' one-off word, else a BIGFONT print
	void Say(RSQMB_Handler h, String txt, int rgb, double secs, Actor over, bool printToo = true, bool letter = true)
	{
		String w = letter ? Shown(txt, kind) : txt;
		if (h && h.debug) Console.Printf("RSQMB word t%d: \"%s\" over %s", level.maptime, w, over ? over.GetClassName() : 'nothing');
		let vr = h ? h.VrService() : null;
		if (vr && over) { vr.GetInt("word", w, rgb, secs, over); return; }
		if (!printToo) return;
		for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i] && players[i].mo) players[i].mo.A_Print(w, secs, "BIGFONT");
	}

	void Flare(int tics) { flareUntil = max(flareUntil, level.maptime + tics); }

	// ---- every tic ----------------------------------------------------------------------------------------------------
	override void Tick()
	{
		if (level.isFrozen()) return;
		let h = RSQMB_Handler.Get();
		if (!b || b.done || !b.mb) { End(h); return; }
		let mb = b.mb;
		if (mb.health <= 0) return;
		int now = level.maptime;
		if (b.lifeLostAt != lostSeen) { lostSeen = b.lifeLostAt; LifeLost(h, now); }
		PlayerPawn p = Victim();
		switch (kind)
		{
		case TR_SUMMONER: SumStep(h, now, p); break;
		case TR_CHARGER:  ChgStep(h, now, p); break;
		case TR_SHIELDED: ShdStep(h, now, p); break;
		case TR_SPLITTER: SplStep(h, now, p); break;
		}
		if (!b || !b.mb) return;
		bool relight = now - lightTic >= (now < flareUntil ? 2 : 8) || lightTic > now;
		if (relight) lightTic = now;
		Aura(b.mb, now, relight);
		for (int i = 0; i < spl.Size(); i++) if (spl[i] && spl[i].health > 0) Aura(spl[i], now, relight);
	}

	// THE AURA: a ring of particles at its feet and a light there, in the trait's colour; a flare while a trick winds up
	// (bigger, brighter; pulsing but for Photosensitive Mode)
	void Aura(Actor a, int now, bool relight)
	{
		bool flare = now < flareUntil;
		bool photo = RSQMB_A11y.Photo();
		int rgb = RGBOf(kind);
		Color c = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		if (relight)
		{
			double pulse = flare ? (photo ? 1.5 : 1.5 + 0.35 * sin(now * 30.0)) : 1.0;
			a.A_AttachLight('RSQMB_Trait', DynamicLight.PointLight, c, int(max(48, a.radius * 2.4) * pulse), 0, 0, (0, 0, 8));
		}
		if ((now + b.idx) % 3 != 0) return;
		int n = RSQMB_Handler.FxLight() ? 10 : 18;
		double r = a.radius * (flare ? 1.6 : 1.35);
		double sz = flare ? 7 : 5;
		double al = flare ? 0.95 : 0.6;
		double spin = now * 2.0;
		for (int k = 0; k < n; k++)
		{
			double ang = spin + 360.0 / n * k;
			Vector3 at = a.pos + (cos(ang) * r, sin(ang) * r, 2);
			Vector3 v = (flare && !photo) ? (0, 0, frandom[rsqmbtr](0.6, 1.6)) : (0, 0, 0.15);
			RSQMB_Boss.P(at, c, sz, 4, al, v);
		}
	}

	// ---- a life lost (boss.zs LoseLife stamps lifeLostAt): each trait's answer -------------------------------------------
	void LifeLost(RSQMB_Handler h, int now)
	{
		nextAt = 0;
		switch (kind)
		{
		case TR_SUMMONER: if (sumAt) SumEnd(h, "a life lost"); break;
		case TR_CHARGER:  if (chg != CH_IDLE) ChgEnd(h, "a life lost"); break;
		case TR_SHIELDED: ShellUp(h, "a new life"); break;
		case TR_SPLITTER: Split(h, now); break;
		}
	}

	// a held pose (the telegraph's Pin: the frame kept, no step, no attack)
	void Pin(int untilTic, bool pain, bool shake) { if (b.tele && b.mb) b.tele.Pin(b.mb, untilTic, pain, shake); }
	void Unpin() { if (b.tele && b.mb) b.tele.Unpin(b.mb); }

	// the wait for the next trick: started when it can be fought, held a second while it cannot start one
	bool Due(int now, int interval)
	{
		if (b.Invulnerable()) { nextAt = 0; return false; }
		if (nextAt == 0) { nextAt = now + interval; return false; }
		if (now < nextAt) return false;
		if (!Free(now)) { nextAt = now + TICRATE; return false; }
		return true;
	}

	// =====================================================================================================================
	// SUMMONER
	// =====================================================================================================================
	int SumInterval() { return int(clamp(CF('rsqmb_trait_sum_secs', 15.0), 3.0, 120.0) * TICRATE); }
	int SumAlive()
	{
		for (int i = fodder.Size() - 1; i >= 0; i--) if (!fodder[i] || fodder[i].health <= 0) fodder.Delete(i);
		return fodder.Size();
	}

	// the fodder: a lower family (the zombie families only when the map has them), RSQ Monsters' ColorfulHell class at the
	// World Tier, else Doom's own with what replaces it
	class<Actor> FodderClass(RSQMB_Handler h)
	{
		Array<int> fams;
		fams.Push(3); fams.Push(4); fams.Push(5); fams.Push(7);      // Imp, Demon, Spectre, Lost Soul
		for (int i = 0; i < h.rosterCls.Size(); i++)
		{
			int f = h.FamOf(h.rosterCls[i]);
			if (f >= 0 && f <= 2 && fams.Find(f) == fams.Size()) fams.Push(f);
		}
		int f = fams[random[rsqmbtr](0, fams.Size() - 1)];
		let s = h.MnService();
		String cn = s ? s.GetString("set.class", RSQMB_MixTab.Fam(f), 3, max(1, RSQMB_Handler.WorldTierNow())) : "";
		class<Actor> c = cn;
		if (!c)
		{
			String vn = RSQMB_MixTab.Fam(f);
			c = vn;
			if (c) c = Actor.GetReplacement(c);
		}
		return c;
	}

	void SumStep(RSQMB_Handler h, int now, PlayerPawn p)
	{
		if (sumAt > 0)
		{
			SumRings(now);
			if (now >= sumUntil) SumLand(h, p);
			return;
		}
		if (!Due(now, SumInterval())) return;
		if (!p || !b.mb.CheckSight(p, SF_IGNOREVISIBILITY)) { nextAt = now + TICRATE; return; }
		SumStart(h, now, p);
	}

	void SumStart(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		int lo = clamp(CI('rsqmb_trait_sum_min', 2), 1, 8), hi = clamp(CI('rsqmb_trait_sum_max', 3), lo, 8);
		int want = min(random[rsqmbtr](lo, hi), clamp(CI('rsqmb_trait_sum_cap', 6), 0, 24) - SumAlive());
		nextAt = 0;
		if (want <= 0) { nextAt = now + SumInterval(); Dbg(h, String.Format("no cast: %d fodder alive, the cap", SumAlive())); return; }
		sX.Clear(); sY.Clear(); sZ.Clear(); sCls.Clear();
		let pr = Actor.Spawn("RSQMB_Probe", mb.pos, NO_REPLACE);
		if (!pr) return;
		for (int k = 0; k < want; k++)
		{
			class<Actor> c = FodderClass(h);
			if (!c) continue;
			double rr = GetDefaultByType(c).radius;
			for (int t = 0; t < 10; t++)
			{
				double a = frandom[rsqmbtr](0, 360), d = frandom[rsqmbtr](128, 320);
				Vector2 xy = mb.pos.xy + (cos(a), sin(a)) * d;
				if (!RSQMB_Handler.Fits(pr, c, xy.x, xy.y, mb.pos.z)) continue;
				if ((pr.pos.xy - p.pos.xy).Length() < 96 + rr) continue;
				if (!pr.CheckSight(p, SF_IGNOREVISIBILITY)) continue;
				bool clash = false;
				for (int q = 0; q < sX.Size(); q++) if ((pr.pos.xy - (sX[q], sY[q])).Length() < rr * 2 + 16) clash = true;
				if (clash) continue;
				sX.Push(pr.pos.x); sY.Push(pr.pos.y); sZ.Push(pr.pos.z); sCls.Push(c.GetClassName());
				break;
			}
		}
		pr.Destroy();
		if (sX.Size() == 0) { nextAt = now + 3 * TICRATE; Dbg(h, "no room for its fodder: again in 3 s"); return; }
		int cast = int(max(1.0, CF('rsqmb_trait_sum_cast', 1.5)) * TICRATE);
		sumAt = now;
		sumUntil = now + cast;
		sumDealt = 0;
		Flare(cast);
		Pin(sumUntil + 1, false, false);
		mb.A_StartSound("brain/spit", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		Say(h, "SUMMON!", RGBOf(kind), cast / double(TICRATE), mb);
		String l = "";
		for (int i = 0; i < sCls.Size(); i++) l = l .. (i ? ", " : "") .. sCls[i];
		Dbg(h, String.Format("casts: %d rings for [%s], %d tics; each %d damage cuts one", sX.Size(), l, cast, SumCutHP()));
	}

	int SumCutHP() { return max(1, int(b.maxHP * clamp(CF('rsqmb_trait_sum_cut', 10.0), 1.0, 100.0) / 100.0)); }

	// the rings on the floor where they will land, brighter as the landing nears
	void SumRings(int now)
	{
		if (now & 1) return;
		int rgb = RGBOf(TR_SUMMONER);
		Color c = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		double k = clamp((now - sumAt) / double(max(1, sumUntil - sumAt)), 0.0, 1.0);
		bool photo = RSQMB_A11y.Photo();
		int n = RSQMB_Handler.FxLight() ? 14 : 24;
		for (int i = 0; i < sX.Size(); i++)
		{
			class<Actor> cc = sCls[i];
			double r = (cc ? GetDefaultByType(cc).radius : 20) + 10;
			double rr = photo ? r : r * (1.0 + 0.12 * sin(now * 20.0));
			for (int q = 0; q < n; q++)
			{
				double a = 360.0 / n * q + now * 3.0;
				RSQMB_Boss.P((sX[i] + cos(a) * rr, sY[i] + sin(a) * rr, sZ[i] + 2), c, 5, 3, 0.45 + 0.5 * k);
			}
			RSQMB_Boss.P((sX[i], sY[i], sZ[i] + 4), c, 8, 3, 0.3 + 0.5 * k, (0, 0, 1.5));
		}
	}

	// hurt during the cast: every SumCutHP of damage takes a ring away
	void SumHurt(int dmg)
	{
		if (sumAt <= 0) return;
		let h = RSQMB_Handler.Get();
		sumDealt += dmg;
		int per = SumCutHP();
		while (sumDealt >= per && sX.Size() > 0)
		{
			sumDealt -= per;
			int k = sX.Size() - 1;
			RSQMB_Boss.Burst((sX[k], sY[k], sZ[k] + 8), Color(255, 0x40, 0xF0, 0x60), RSQMB_Handler.FxLight() ? 6 : 12, 3.0, 4);
			sX.Delete(k); sY.Delete(k); sZ.Delete(k); sCls.Delete(k);
			Dbg(h, String.Format("hurt in the cast: a ring goes, %d left", sX.Size()));
		}
		if (sX.Size() == 0)
		{
			if (b.mb) b.mb.A_StartSound("imp/shotx", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
			SumEnd(h, "cut short: nothing lands");
		}
	}

	void SumLand(RSQMB_Handler h, PlayerPawn p)
	{
		int got = 0;
		for (int i = 0; i < sX.Size(); i++)
		{
			class<Actor> c = sCls[i];
			if (!c) continue;
			if (h) h.swapNoRoll = c;            // carry.zs: Champions does not roll fodder
			let a = Actor.Spawn(c, (sX[i], sY[i], sZ[i]), NO_REPLACE);
			if (h) h.swapNoRoll = null;
			if (!a) continue;
			if (!a.TestMobjLocation()) { a.ClearCounters(); a.Destroy(); continue; }
			a.ClearCounters();
			a.GiveInventoryType("RSQMB_Called");  // a fight's monster: no Boss meter fill, no gun drop
			Actor.Spawn("TeleportFog", a.pos, ALLOW_REPLACE);
			if (p) { a.target = p; a.LastHeard = p; if (a.SeeState) a.SetState(a.SeeState); }
			if (!a) continue;
			fodder.Push(a);
			got++;
		}
		Dbg(h, String.Format("fodder lands: %d of %d rings (%d alive)", got, sX.Size(), SumAlive()));
		SumEnd(h, "");
	}

	void SumEnd(RSQMB_Handler h, String why)
	{
		sumAt = 0; sumUntil = 0; sumDealt = 0;
		sX.Clear(); sY.Clear(); sZ.Clear(); sCls.Clear();
		flareUntil = 0;
		Unpin();
		nextAt = level.maptime + SumInterval();
		if (why != "") Dbg(h, "cast over (" .. why .. ")");
	}

	// =====================================================================================================================
	// CHARGER
	// =====================================================================================================================
	int ChgInterval() { return int(clamp(CF('rsqmb_trait_chg_secs', 10.0), 3.0, 120.0) * TICRATE); }
	int ChgWind() { return int(max(1.0, CF('rsqmb_trait_chg_wind', 1.2)) * TICRATE); }

	void ChgStep(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		switch (chg)
		{
		case CH_IDLE:
		{
			int iv = ChgInterval();
			if (chgSoon && nextAt == 0) iv = int(iv * clamp(CF('rsqmb_trait_chg_sooner', 0.5), 0.1, 1.0));
			if (!Due(now, iv)) return;
			if (!p || !mb.CheckSight(p, SF_IGNOREVISIBILITY) || mb.Distance2D(p) < mb.radius + 96 || mb.Distance2D(p) > 2048) { nextAt = now + TICRATE; return; }
			chgSoon = false;
			ChgStart(h, now, p);
			return;
		}
		case CH_WIND:  ChgWindStep(h, now, p); return;
		case CH_RUSH:  ChgRushStep(h, now, p); return;
		case CH_SKID:  ChgSkidStep(h, now); return;
		case CH_STUN:  if (now >= chgUntil) ChgEnd(h, "the stun is over"); return;
		}
	}

	void ChgStart(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		chg = CH_WIND;
		chgAt = now;
		chgUntil = now + ChgWind();
		chgLocked = false;
		nextAt = 0;
		ChgAim(p);
		Flare(chgUntil - now);
		Pin(chgUntil + 1, false, false);
		mb.A_StartSound(mb.SeeSound, CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		Say(h, "CHARGE!", RGBOf(kind), (chgUntil - now) / double(TICRATE) + 0.3, mb);
		Dbg(h, String.Format("winds up its charge (%d tics) at %s %.0f units away", chgUntil - now, p.GetClassName(), mb.Distance2D(p)));
	}

	void ChgAim(PlayerPawn p)
	{
		let mb = b.mb;
		if (!p) return;
		Vector2 d = level.Vec2Diff(mb.pos.xy, p.pos.xy);
		double l = max(1.0, d.Length());
		chgDX = d.x / l; chgDY = d.y / l;
		chgLen = clamp(l + 192, 384.0, 1536.0);
	}

	// a stamp: a small quake (QuestZDoom sends it to the controllers), RSQ Accessibility's Rumble Backup, dust
	void Stamp(RSQMB_Handler h, int n)
	{
		let mb = b.mb;
		mb.A_StartSound("cyber/hoof", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		mb.A_Quake(RSQMB_A11y.Photo() ? 1 : 3, 8, 0, 1024, "");
		if (RSQMB_A11y.I('rsqa_rumble_backup') != 0 && consoleplayer >= 0 && playeringame[consoleplayer] && players[consoleplayer].mo
			&& mb.Distance2D(players[consoleplayer].mo) < 1024)
		{
			let s = RSQMB_A11y.Svc();
			if (s) { s.GetInt("buzz", "RSQMB", consoleplayer, 1); s.GetInt("buzz", "RSQMB", consoleplayer, 0); }
		}
		RSQMB_Boss.Burst(mb.pos + (0, 0, 4), Color(255, 0xC8, 0xB0, 0x90), RSQMB_Handler.FxLight() ? 8 : 16, 3.0, 4);
		Dbg(h, String.Format("stamp %d", n));
	}

	void ChgWindStep(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		int len = chgUntil - chgAt, age = now - chgAt;
		int s1 = chgAt + int(len * 0.3), s2 = chgAt + int(len * 0.65);
		if (!chgLocked && p)
		{
			ChgAim(p);
			mb.angle += clamp(Actor.deltaangle(mb.angle, atan2(chgDY, chgDX)), -15.0, 15.0);
		}
		if (now == s1) Stamp(h, 1);
		if (now == s2)
		{
			Stamp(h, 2);
			chgLocked = true;
			mb.angle = atan2(chgDY, chgDX);
			Dbg(h, String.Format("the line locks: %.0f units along %.0f degrees", chgLen, mb.angle));
		}
		ChgLine(now, chgLocked);
		if (now >= chgUntil) ChgRushStart(h, now);
	}

	// THE LINE on the floor from it along the charge, every second tic
	void ChgLine(int now, bool locked)
	{
		if (now & 1) return;
		let mb = b.mb;
		int rgb = RGBOf(TR_CHARGER);
		Color c = locked ? Color(255, 255, 220, 160) : Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		double step = RSQMB_Handler.FxLight() ? 24 : 16;
		for (double s = mb.radius; s <= chgLen; s += step)
		{
			Vector2 xy = mb.pos.xy + (chgDX, chgDY) * s;
			let sec = level.PointInSector(xy);
			double z = sec.floorplane.ZatPoint(xy) + 2;
			RSQMB_Boss.P((xy, z), c, locked ? 7 : 5, 3, locked ? 0.95 : 0.6);
		}
	}

	void ChgRushStart(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		Unpin();
		chg = CH_RUSH;
		chgAt = now;
		chgUntil = now + 3 * TICRATE;      // at most 3 s of rushing
		chgRun = 0;
		chgBlocks = 0;
		chgSpd = clamp(CF('rsqmb_trait_chg_speed', 26.0), 8.0, 64.0);
		if (mb.SeeState) mb.SetState(mb.SeeState);
		if (!b.mb) return;
		mb.A_StartSound("skull/attack", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		Dbg(h, String.Format("rushes at %.0f a tic", chgSpd));
	}

	// one tic of the rush, in steps no longer than half its radius (no wall is stepped over)
	void ChgRushStep(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		if (mb.tics >= 0 && mb.tics < 2) mb.tics = 2;   // its own AI held: the rush moves it
		mb.vel.xy = (0, 0);
		ChgLine(now, true);
		double left = chgSpd;
		double sub = max(4.0, mb.radius * 0.5);
		while (left > 0)
		{
			double st = min(sub, left);
			left -= st;
			if (p && ChgTouch(p)) { ChgHit(h, now, p); return; }
			Vector2 np = mb.pos.xy + (chgDX, chgDY) * st;
			if (!mb.TryMove(np, 1))
			{
				let bm = mb.BlockingMobj;
				if (bm && bm.player) { ChgHit(h, now, PlayerPawn(bm)); return; }
				if (bm && bm.bSHOOTABLE && !bm.bDONTTHRUST)
				{
					// a monster in the way is shoved aside; three shoves in one rush stop it as a wall would
					bm.vel.xy += (-chgDY, chgDX) * (((now + chgBlocks) & 1) ? 8 : -8);
					if (++chgBlocks < 3) continue;
				}
				ChgWall(h, now);
				return;
			}
			chgRun += st;
		}
		if (p && ChgTouch(p)) { ChgHit(h, now, p); return; }
		if (chgRun >= chgLen || now >= chgUntil) { chg = CH_SKID; chgAt = now; Dbg(h, String.Format("missed: skids after %.0f units", chgRun)); }
	}

	bool ChgTouch(Actor p)
	{
		let mb = b.mb;
		if (!p || p.health <= 0) return false;
		if (level.Vec2Diff(mb.pos.xy, p.pos.xy).Length() > mb.radius + p.radius + 6) return false;
		return p.pos.z < mb.pos.z + mb.height && p.pos.z + p.height > mb.pos.z;
	}

	void ChgSkidStep(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		if (mb.tics >= 0 && mb.tics < 2) mb.tics = 2;
		double k = 1.0 - (now - chgAt) / 8.0;
		if (k <= 0) { ChgStun(h, now, false); return; }
		if (now & 1) RSQMB_Boss.P(mb.pos + (0, 0, 2), Color(255, 0xC8, 0xB0, 0x90), 6, 10, 0.7, (frandom[rsqmbtr](-1, 1), frandom[rsqmbtr](-1, 1), 0.8));
		if (!mb.TryMove(mb.pos.xy + (chgDX, chgDY) * chgSpd * k * 0.5, 1)) ChgStun(h, now, true);
	}

	void ChgWall(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		mb.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 0.8, ATTN_NORM);
		mb.A_Quake(RSQMB_A11y.Photo() ? 1 : 4, 10, 0, 1024, "");
		RSQMB_Boss.Burst(mb.pos + (chgDX, chgDY, 0) * mb.radius + (0, 0, mb.height * 0.5), Color(255, 0xC8, 0xB0, 0x90), RSQMB_Handler.FxLight() ? 12 : 24, 5.0, 5);
		ChgStun(h, now, true);
	}

	void ChgStun(RSQMB_Handler h, int now, bool wall)
	{
		chg = CH_STUN;
		chgAt = now;
		chgUntil = now + int(clamp(CF('rsqmb_trait_chg_stun', 2.0), 0.5, 10.0) * TICRATE);
		if (b.mb) b.mb.vel.xy = (0, 0);
		Pin(chgUntil, true, true);
		let vr = h ? h.VrService() : null;
		if (vr && b.mb) vr.GetInt("pop", "", RGBOf(kind), 1.5, b.mb);
		Dbg(h, String.Format("%s: stunned %d tics, takes x%.2f", wall ? "hits the wall" : "skids to a stop", chgUntil - now, StunMult()));
	}

	double StunMult() { return clamp(CF('rsqmb_trait_chg_stun_mult', 1.5), 1.0, 5.0); }

	void ChgHit(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		double dmg = clamp(CF('rsqmb_trait_chg_dmg', 20.0), 0.0, 200.0) * (1.0 + clamp(CF('rsqmb_tell_dmg_tier', 0.06), 0.0, 1.0) * (clamp(RSQMB_Handler.WorldTierNow(), 1, 13) - 1));
		int d = int(round(dmg));
		if (d > 0) p.DamageMobj(mb, mb, d, 'Melee', DMG_THRUSTLESS);
		double push = clamp(CF('rsqmb_trait_chg_push', 20.0), 0.0, 60.0);
		if (p) { p.vel.xy += (chgDX, chgDY) * push; p.vel.z += push * 0.3; }
		mb.A_StartSound("demon/melee", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		mb.vel.xy = (0, 0);
		chgSoon = true;
		Dbg(h, String.Format("HIT %s for %d, knocked back %.0f: the next charge comes sooner", p ? p.GetClassName() : 'nobody', d, push));
		ChgEnd(h, "");
	}

	void ChgEnd(RSQMB_Handler h, String why)
	{
		chg = CH_IDLE;
		flareUntil = 0;
		Unpin();
		if (b.mb && b.mb.health > 0 && b.mb.tics > 1) b.mb.tics = 1;
		nextAt = 0;
		if (why != "") Dbg(h, "charge over (" .. why .. ")");
	}

	// =====================================================================================================================
	// SHIELDED
	// =====================================================================================================================
	void ShdStep(RSQMB_Handler h, int now, PlayerPawn p)
	{
		if (!shdUp) return;
		// its rim points: made once the telegraph is there (their crosshair is its), placed every tic
		if (rim.Size() == 0 && b.tele) MakeRim(h, p);
		int left = 0;
		for (int i = 0; i < rim.Size(); i++)
		{
			let w = rim[i];
			if (!w || w.broken || w.health <= 0) continue;
			left++;
			PlaceRim(w, p);
		}
		if (rim.Size() > 0 && left == 0) { Shatter(h); return; }
		ShellFx(now);
	}

	void MakeRim(RSQMB_Handler h, PlayerPawn p)
	{
		let mb = b.mb;
		int n = clamp(CI('rsqmb_trait_shd_points', 3), 1, 6);
		double arc = clamp(CF('rsqmb_trait_shd_arc', 90.0), 30.0, 180.0);
		double r = clamp(mb.radius * 0.3, 8.0, 18.0);
		int hp = max(1, CI('rsqmb_trait_shd_wp_hp', 120));
		let vr = h ? h.VrService() : null;
		for (int i = 0; i < n; i++)
		{
			let w = RSQMB_RimPoint(Actor.Spawn("RSQMB_RimPoint", mb.pos, NO_REPLACE));
			if (!w) continue;
			w.tele = b.tele;               // the telegraph's weak point: only a player's attack hurts it
			w.trt = self;
			w.slot = i;
			// round the rim: the two edges at mid height, then the top; more spread between
			double a, up;
			if (n == 1) { a = 0; up = 0.95; }
			else if (i == 0) { a = arc * 0.92; up = 0.55; }
			else if (i == 1) { a = -arc * 0.92; up = 0.55; }
			else { int m = n - 2; double u = m > 1 ? (i - 2) / double(m - 1) : 0.5; a = arc * 0.6 * (2 * u - 1); up = 0.9; }
			w.side = a; w.up = up;
			w.A_SetSize(r, r * 2, false);
			w.health = hp;
			w.StartHealth = hp;
			w.born = level.maptime;
			w.icon = i % 3;
			w.Dress(false, RSQMB_Handler.FxLight());
			rim.Push(w);
			if (vr) vr.GetInt("word.hold", "WEAK!", 0xFFD030, 1.0, w);
			PlaceRim(w, p);
			w.ClearInterpolation();
		}
		Dbg(h, String.Format("the shell's rim: %d WEAK! points of %d health, the shell turns blows within %.0f degrees of its front", rim.Size(), hp, arc));
	}

	void PlaceRim(RSQMB_RimPoint w, PlayerPawn p)
	{
		if (!w || w.broken) return;
		let mb = b.mb;
		double a = mb.angle + w.side;
		Vector2 xy = mb.pos.xy + (cos(a), sin(a)) * (mb.radius * 1.1);
		w.SetOrigin((xy, mb.pos.z + mb.height * w.up - w.height / 2), true);
		if (b.tele) b.tele.Crosshair(w, p);
	}

	// the shell: a half dome of steel-blue points over its front, every third tic
	void ShellFx(int now)
	{
		if ((now + b.idx) % 3 != 1) return;
		let mb = b.mb;
		int rgb = RGBOf(TR_SHIELDED);
		Color c = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		bool few = RSQMB_Handler.FxLight();
		int rows = few ? 3 : 4, cols = few ? 7 : 11;
		double arc = clamp(CF('rsqmb_trait_shd_arc', 90.0), 30.0, 180.0);
		double r = mb.radius * 1.15;
		for (int ri = 0; ri < rows; ri++)
		{
			double up = (ri + 0.5) / rows;
			double rr = r * (0.75 + 0.25 * sin(up * 180.0));
			for (int ci = 0; ci < cols; ci++)
			{
				double a = mb.angle - arc + 2 * arc * ci / (cols - 1);
				RSQMB_Boss.P(mb.pos + (cos(a) * rr, sin(a) * rr, mb.height * up), c, 3, 4, 0.4);
			}
		}
	}

	// items.zs: does the shell turn this blow?
	bool Blocks(Actor inflictor, Actor source)
	{
		if (kind != TR_SHIELDED || !shdUp || !b.mb) return false;
		if (b.BreakMult() > 1.0) return false;       // BREAK! opens it (my rule: the stagger's x2 lands)
		let mb = b.mb;
		Actor from = null;
		if (inflictor && inflictor != mb && (inflictor.bMISSILE || !source)) from = inflictor;
		else if (source && source != mb) from = source;
		if (!from) return false;
		Vector2 d = level.Vec2Diff(mb.pos.xy, from.pos.xy);
		if (d.Length() < 1) return false;
		double arc = clamp(CF('rsqmb_trait_shd_arc', 90.0), 30.0, 180.0);
		if (abs(Actor.deltaangle(mb.angle, atan2(d.y, d.x))) > arc) return false;
		// turned: sparks where it struck the shell, BLOCKED at most once a second
		int now = level.maptime;
		double l = d.Length();
		Vector3 at = mb.pos + (d.x / l * mb.radius * 1.15, d.y / l * mb.radius * 1.15, clamp(from.pos.z - mb.pos.z + from.height * 0.5, 4.0, mb.height));
		RSQMB_Boss.Burst(at, Color(255, 0xD8, 0xE8, 0xFF), RSQMB_Handler.FxLight() ? 4 : 8, 3.0, 3);
		if (now - shdSndAt >= 6) { shdSndAt = now; mb.A_StartSound("plats/pt1_stop", CHAN_AUTO, CHANF_OVERLAP, 0.6, ATTN_NORM, 1.5); }
		if (now - shdWordAt >= TICRATE)
		{
			shdWordAt = now;
			let h = RSQMB_Handler.Get();
			Say(h, "BLOCKED", 0x9AA0AA, 0.6, mb, false, false);
		}
		return true;
	}

	void RimBroken(RSQMB_RimPoint w, Actor by)
	{
		let h = RSQMB_Handler.Get();
		w.broken = true;
		w.A_StartSound("imp/shotx", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		let vr = h ? h.VrService() : null;
		if (vr) { vr.GetInt("pop", "", RGBOf(TR_SHIELDED), 1.0, w); vr.GetInt("word.clear", "WEAK!", 0, 0, w); }
		RSQMB_Boss.Burst(w.pos + (0, 0, w.height / 2), Color(255, 0x9A, 0xC0, 0xF0), RSQMB_Handler.FxLight() ? 10 : 20, 4.0, 5);
		int left = 0;
		for (int i = 0; i < rim.Size(); i++) if (rim[i] && !rim[i].broken && rim[i].health > 0) left++;
		Dbg(h, String.Format("a rim point broken by %s, %d left", by ? by.GetClassName() : 'none', left));
	}

	void Shatter(RSQMB_Handler h)
	{
		let mb = b.mb;
		shdUp = false;
		ClearRim(true);
		mb.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		int rgb = RGBOf(TR_SHIELDED);
		RSQMB_Boss.Burst(mb.pos + (0, 0, mb.height * 0.5), Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255), RSQMB_Handler.FxLight() ? 20 : 40, 6.0, 6);
		let vr = h ? h.VrService() : null;
		if (vr) vr.GetInt("pop", "", rgb, 2.0, mb);
		Dbg(h, "the shell shatters: full damage for the rest of this life");
	}

	void ShellUp(RSQMB_Handler h, String why)
	{
		ClearRim(true);
		shdUp = true;
		if (b.mb) b.mb.A_StartSound("champion/silver/shield", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		Flare(TICRATE);
		Dbg(h, "the shell is back (" .. why .. ")");
	}

	void ClearRim(bool quiet)
	{
		let h = RSQMB_Handler.Get();
		let vr = h ? h.VrService() : null;
		for (int i = 0; i < rim.Size(); i++)
		{
			let w = rim[i];
			if (!w) continue;
			if (vr) vr.GetInt("word.clear", "WEAK!", 0, 0, w);
			w.trt = null;
			w.Remove(quiet);
		}
		rim.Clear();
	}

	// =====================================================================================================================
	// SPLITTER
	// =====================================================================================================================
	clearscope int CopyHP() const
	{
		int n = 0;
		for (int i = 0; i < spl.Size(); i++) if (spl[i] && !spl[i].bDestroyed && spl[i].health > 0) n += spl[i].health;
		return n;
	}
	int CopiesAlive()
	{
		for (int i = spl.Size() - 1; i >= 0; i--)
		{
			let a = spl[i];
			if (a && !a.bDestroyed && a.health > 0) continue;
			if (a && !a.bDestroyed)
			{
				let tk = RSQMB_SplitTok(a.FindInventory("RSQMB_SplitTok"));
				if (tk && tk.lastBy) splKiller = tk.lastBy;
			}
			spl.Delete(i);
		}
		return spl.Size();
	}

	void SplStep(RSQMB_Handler h, int now, PlayerPawn p)
	{
		let mb = b.mb;
		int alive = CopiesAlive();
		// spent while its copy stands: it kneels; the copy dead, the life is lost (the last: it dies)
		if (alive > 0 && !splSpent && mb.health <= 2) { splSpent = true; Pin(now + 3600 * TICRATE, true, false); Dbg(h, String.Format("its body is spent: it kneels until its copy (%d health) dies", CopyHP())); }
		if (splSpent)
		{
			if (alive > 0) { Pin(now + 3600 * TICRATE, true, false); return; }
			splSpent = false;
			Unpin();
			if (b.lives > 1) { mb.health = 1; Dbg(h, "both halves down: the life ends"); }
			else
			{
				Dbg(h, String.Format("both halves down on its last life: it dies (killer %s)", splKiller ? splKiller.GetClassName() : 'none'));
				mb.DamageMobj(null, splKiller, mb.health + 1000, 'None', DMG_FORCED | DMG_THRUSTLESS | DMG_NO_ARMOR);
			}
			return;
		}
		// the warning, a second ahead (not on its last life: there is no life to split into)
		if (b.lives <= 1 || b.Invulnerable()) { if (splWarn) WarnOff(h, "no life to split"); return; }
		if ((now + b.idx) % 3 != 0 && !splWarn) return;
		int left = mb.health + CopyHP();
		double dps = 0;
		for (int pn = 0; pn < MAXPLAYERS; pn++) if (playeringame[pn] && players[pn].mo) { double v = RSQMB_Handler.DpsOf(players[pn].mo); if (v > 0) dps += v; }
		double thr = max(b.maxHP * clamp(CF('rsqmb_trait_spl_warn', 15.0), 1.0, 60.0) / 100.0, dps * 1.0);
		if (!splWarn && left <= thr)
		{
			splWarn = true;
			splWarnAt = now;
			Flare(3600 * TICRATE);
			crkX.Clear(); crkZ.Clear();
			for (int i = 0; i < 9; i++) { crkX.Push(frandom[rsqmbtr](-0.35, 0.35)); crkZ.Push(0.1 + 0.85 * i / 8.0); }
			mb.A_StartSound("vile/start", CHAN_AUTO, CHANF_OVERLAP, 0.8, ATTN_NORM);
			let vr = h ? h.VrService() : null;
			String w = Shown("SPLITTING!", kind);
			if (vr) vr.GetInt("word.hold", w, RGBOf(kind), 1.0, mb);
			else for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i] && players[i].mo) players[i].mo.A_Print(w, 1.5, "BIGFONT");
			if (h && h.debug) Console.Printf("RSQMB word t%d: \"%s\" held over %s", now, w, mb.GetClassName());
			Dbg(h, String.Format("SPLITTING!: %d health left of its life (warn under %.0f, damage per second %.1f)", left, thr, dps));
		}
		else if (splWarn && left > thr * 2) WarnOff(h, "healed past the warning");
		if (splWarn) Crack(now);
	}

	void WarnOff(RSQMB_Handler h, String why)
	{
		splWarn = false;
		flareUntil = 0;
		let vr = h ? h.VrService() : null;
		if (vr && b.mb) vr.GetInt("word.clear", Shown("SPLITTING!", kind), 0, 0, b.mb);
		if (why != "") Dbg(h, "SPLITTING! off (" .. why .. ")");
	}

	// the glowing crack up its front, every second tic
	void Crack(int now)
	{
		if (now & 1) return;
		let mb = b.mb;
		int rgb = RGBOf(TR_SPLITTER);
		Color c = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		double a = mb.angle;
		Vector2 fw = (cos(a), sin(a)), rt = (sin(a), -cos(a));
		for (int i = 0; i + 1 < crkX.Size(); i++)
		{
			for (int s = 0; s < 3; s++)
			{
				double u = s / 3.0;
				double x = crkX[i] + (crkX[i + 1] - crkX[i]) * u, z = crkZ[i] + (crkZ[i + 1] - crkZ[i]) * u;
				Vector2 xy = mb.pos.xy + fw * (mb.radius * 1.02) + rt * (x * mb.radius);
				RSQMB_Boss.P((xy, mb.pos.z + mb.height * z), s == 0 ? Color(255, 255, 255, 255) : c, 4, 3, 0.95);
			}
		}
	}

	// the life lost: two smaller, weaker halves of the life's health
	void Split(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		WarnOff(h, "");
		if (splSpent) { splSpent = false; Unpin(); }
		double f = clamp(CF('rsqmb_trait_spl_scale', 0.7), 0.3, 1.0);
		int total = max(2, mb.health);
		// the copy's spot first: beside it, at the size it will have
		class<Actor> c = mb.GetClass();
		double nr = mb.radius * f, nh = mb.height * f;
		let pr = Actor.Spawn("RSQMB_Probe", mb.pos, NO_REPLACE);
		if (!pr) return;
		Vector2 rt = (sin(mb.angle), -cos(mb.angle));
		bool found = false;
		Vector3 at = mb.pos;
		for (int t = 0; t < 8 && !found; t++)
		{
			double side = (t & 1) ? -1 : 1;
			double dist = mb.radius + nr + 12 + 16 * (t / 2);   // clear of its own (unshrunk) body
			Vector2 xy = mb.pos.xy + rt * side * dist;
			pr.A_SetSize(nr, nh, false);
			pr.SetOrigin((xy, mb.pos.z + 8), false);
			double fz = pr.floorz;
			if (pr.ceilingz - fz < nh + 4) continue;
			pr.SetOrigin((xy, mb.bNOGRAVITY || mb.bFLOAT ? clamp(mb.pos.z, fz, pr.ceilingz - nh) : fz), false);
			if (!pr.TestMobjLocation() || !pr.CheckSight(mb, SF_IGNOREVISIBILITY)) continue;
			at = pr.pos;
			found = true;
		}
		pr.Destroy();
		if (!found) { Dbg(h, "no room beside it for a copy: it stays whole this life"); return; }
		if (h) h.swapNoRoll = c;       // carry.zs: Champions does not roll the copy
		let cp = Actor.Spawn(c, at, NO_REPLACE);
		if (h) h.swapNoRoll = null;
		if (!cp) return;
		splGen++;
		splK *= f;
		// both halves at the new size (its ceiling fit, boss.zs FitCeiling, works in ratios: the shrink is kept)
		mb.A_SetScale(mb.Scale.X * f, mb.Scale.Y * f);
		mb.A_SetSize(mb.radius * f, mb.height * f, false);
		cp.A_SetScale(mb.Scale.X, mb.Scale.Y);
		cp.A_SetSize(mb.radius, mb.height, false);
		int half = max(1, total / 2);
		mb.health = max(2, total - half);
		cp.health = half;
		cp.angle = mb.angle;
		cp.ClearCounters();
		cp.GiveInventoryType("RSQMB_Called");
		let tk = RSQMB_SplitTok(cp.GiveInventoryType("RSQMB_SplitTok"));
		if (tk) tk.outK = clamp(CF('rsqmb_trait_spl_dmg', 0.75), 0.1, 1.0);
		cp.bBRIGHT = true;
		RSQMB_Handler.Aggressive(cp);
		let p = Victim();
		if (p) { cp.target = p; cp.LastHeard = p; if (cp.SeeState) cp.SetState(cp.SeeState); }
		if (!cp) return;
		spl.Push(cp);
		int rgb = RGBOf(TR_SPLITTER);
		Color pc = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		mb.A_StartSound("misc/teleport", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		RSQMB_Boss.Burst(mb.pos + (0, 0, mb.height * 0.5), pc, RSQMB_Handler.FxLight() ? 16 : 32, 5.0, 6);
		let vr = h ? h.VrService() : null;
		if (vr) { vr.GetInt("pop", "", rgb, 1.5, mb); vr.GetInt("pop", "", rgb, 1.5, cp); }
		Dbg(h, String.Format("SPLIT %d: two halves at x%.2f, %d + %d health of %d, the copy deals x%.2f", splGen, splK, mb.health, cp.health, total, tk ? tk.outK : 1.0));
	}

	// ---- items.zs, the damage rules ----------------------------------------------------------------------------------
	// what a blow on it keeps: x the stun's multiplier while a CHARGER is stunned
	clearscope double TakeMult() const
	{
		if (kind == TR_CHARGER && chg == CH_STUN && level.maptime < chgUntil) return clamp(CF('rsqmb_trait_chg_stun_mult', 1.5), 1.0, 5.0);
		return 1.0;
	}
	// SPLITTER: while its copy stands the body holds at 2 health
	int HoldHit(int nd)
	{
		if (kind != TR_SPLITTER || !b.mb || nd <= 0) return nd;
		if (CopiesAlive() == 0) return nd;
		return clamp(nd, 0, max(0, b.mb.health - 2));
	}
	void Hurt(int nd) { if (kind == TR_SUMMONER) SumHurt(nd); }
	// SPLITTER: a half deals x rsqmb_trait_spl_dmg once it has split
	clearscope double OutMult() const
	{
		if (kind == TR_SPLITTER && splGen > 0) return clamp(CF('rsqmb_trait_spl_dmg', 0.75), 0.1, 1.0);
		return 1.0;
	}

	// ---- the fight is over: everything of it let go ----------------------------------------------------------------
	void End(RSQMB_Handler h)
	{
		ClearRim(true);
		// its fodder and its copy die with it (no source: nobody is paid for them)
		for (int i = 0; i < fodder.Size(); i++)
		{
			let a = fodder[i];
			if (a && a.health > 0) a.DamageMobj(null, null, a.health + 1000, 'None', DMG_FORCED | DMG_THRUSTLESS | DMG_NO_ARMOR);
		}
		fodder.Clear();
		for (int i = 0; i < spl.Size(); i++)
		{
			let a = spl[i];
			if (a && a.health > 0) a.DamageMobj(null, null, a.health + 1000, 'None', DMG_FORCED | DMG_THRUSTLESS | DMG_NO_ARMOR);
		}
		spl.Clear();
		if (b && b.mb)
		{
			b.mb.A_RemoveLight('RSQMB_Trait');
			if (splWarn) { let vr = h ? h.VrService() : null; if (vr) vr.GetInt("word.clear", Shown("SPLITTING!", kind), 0, 0, b.mb); }
		}
		if (h && h.debug) Console.Printf("RSQMB trait t%d: boss %d %s: the fight is over, its fodder and copies go", level.maptime, b ? b.idx : -1, NameOf(kind));
		if (b && b.trt == self) b.trt = null;
		Destroy();
	}
}

// SHIELDED's rim point: the telegraph's weak point (its look, its crosshair, only a player's attack hurts it), told to its
// trait when it breaks instead of to the telegraph's wind-up
class RSQMB_RimPoint : RSQMB_WeakPoint
{
	RSQMB_Trait trt;
	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		if (!broken && trt) trt.RimBroken(self, source);
		broken = true;                 // RSQMB_WeakPoint.Die: not the wind-up's
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!trt && !broken) Remove(true);
	}
}

// on a SPLITTER's copy: who hit it last (its killer is the Boss's killer on the last life), and its weaker blows
class RSQMB_SplitTok : RSQMB_Token
{
	Actor lastBy;
	double outK;
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (damage <= 0) return;
		if (passive)
		{
			Actor p = RSQMB_Handler.PlayerOf(source);
			if (!p) p = RSQMB_Handler.PlayerOf(inflictor);
			if (p) lastBy = p;
		}
		else if (outK > 0 && outK < 1.0) newdamage = max(1, int(round(damage * outK)));
	}
}
