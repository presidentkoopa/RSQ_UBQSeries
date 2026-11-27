// ============================================================================
// RSQ_Miniboss -- THE BIG BOSSES' OWN PARTS OF EXPOSED! (design/BIG_BOSS.md 11-15). Code only, not run (2026-11-23).
//
//   SUMMONS DURING EXPOSED!   "we want to have a challenge during Exposed. have it summon during its exposed window"
//                   (owner 2026-11-16 11:51, BIG_BOSS.md 11). When a Big Boss winds up (telegraph.zs WindStart), its own
//                   pressure comes in, by its personality:
//                     Obsidian Tyrant   portals: red-tier minions (RS_RedImp, RS_RedDemon) and a Moloch wraith
//                     Imp Warlord       BACKUP: imps of his family (RS_BlackImp) out of the smoke as he charges
//                     Black Knight      his SQUIRES! (RS_RedHK) charge in
//                     the bog           BURP BLOBS! crawl at you (Miniboss's own blobs, slow, half damage)
//                     Benellus          his two Shotgun Shrines (RS_ShotgunShrine, 800 HP), one each side of him
//                   rsqmb_big_summon_n (2) of them, +1 each later act, never more than rsqmb_big_summon_max (6) of a Big
//                   Boss's summons alive; the Shrines are always two (and only when fewer than two stand). They land
//                   in sight of you, 160-320 units from the Big Boss (the Shrines 120 to its sides), with a teleport
//                   fog; they are not thralls (no damage cut, no banner chip), count for no kill total, hunt you at
//                   once, and die with the Big Boss. Classes asked by name (RSQ Monsters), else Doom's own.
//   GUARD           after the window, the shield, with its summons as the wave (GuardStart below).
//   SUPERSMITH'S PENTAGRAMS   the Obsidian Tyrant's third life (act 3, Supersmith; BIG_BOSS.md 11): between wind-ups,
//                   every rsqmb_ss_penta_secs (15 s) it plants a pentagram on the floor under itself and stands on it
//                   to heal (rsqmb_ss_heal_pct, 4% of its life a second). CRITICAL TARGET! with a line down to the
//                   pentagram and a rsqmb_ss_count (3 s) countdown; the pentagram has a small HP bar
//                   (rsqmb_ss_penta_hp, 400; only a player's attack hurts it). Shot down: it stops healing and moves
//                   again. The countdown runs out with it standing: SUPERSMITH+ (owner 11:57): faster (x
//                   rsqmb_ss_plus_speed, 1.35) and its next big attack has more slams (two more rings, five more lines of
//                   fire), until its next EXPOSED! (the speed ends as that wind-up starts; the slams are that wind-up's
//                   attack). Never planted within 4 s of a wind-up.
//   BENELLUS' FOUR GHOST GUNS  act 3, ANGRIER (BIG_BOSS.md 15): four ghost guns, two of them behind you (telegraph.zs
//                   MakeWeakPoints / Place, the field RSQMB_WeakPoint.back). Missed, all four fire.
// Every number a cvar with a menu row (CVARINFO.txt / MENUDEF.txt, "Big Boss EXPOSED!").
// ============================================================================

extend class RSQMB_Handler
{
	class<Actor> swapNoRoll;     // a body this mod is swapping in right now (KnightBody): Champions' roll held off it
}

extend class RSQMB_Boss
{
	bool guardUp;               // GUARD after EXPOSED! (bigacts.zs): no damage while it holds
	int  guardUntil;
}

extend class RSQMB_Tele
{
	Array<Actor> sums;          // its summons alive (they die with it)
	RSQMB_SSPenta penta;        // Supersmith's pentagram standing
	int  pentaNext, pentaEnd, pentaShown;
	bool ssPlus, ssPlusFire;
	double ssBaseSpeed;

	// ---- SUMMONS DURING EXPOSED! -----------------------------------------------------------------------------------
	int SumAlive()
	{
		for (int i = sums.Size() - 1; i >= 0; i--) if (!sums[i] || sums[i].health <= 0) sums.Delete(i);
		return sums.Size();
	}

	static Class<Actor> ByName(String n, String fallback)
	{
		Class<Actor> c = n;
		if (!c) c = fallback;
		return c;
	}

	// one summon to a spot near `from` that it fits and you can see
	Actor SummonAt(RSQMB_Handler h, Class<Actor> c, PlayerPawn p, Vector2 fixedOfs, double dmin, double dmax)
	{
		let mb = b.mb;
		if (!c || !mb) return null;
		for (int t = 0; t < 8; t++)
		{
			Vector2 xy;
			if (fixedOfs != (0, 0)) xy = mb.pos.xy + fixedOfs * (1.0 + 0.15 * t);
			else
			{
				double a = frandom[rsqmbsum](0, 360), d = frandom[rsqmbsum](dmin, dmax);
				xy = mb.pos.xy + (cos(a), sin(a)) * d;
			}
			let a = Actor.Spawn(c, (xy, mb.pos.z), ALLOW_REPLACE);
			if (!a) continue;
			if (!a.bFLOAT && !a.bNOGRAVITY) a.SetZ(a.floorz);
			else a.SetZ(clamp(mb.pos.z + mb.height * 0.5, a.floorz, max(a.floorz, a.ceilingz - a.height)));
			bool ok = (a.bNOCLIP || a.TestMobjLocation()) && a.pos.z >= a.floorz - 1 && a.pos.z + a.height <= a.ceilingz + 1
				&& (!p || a.CheckSight(p, SF_IGNOREVISIBILITY));
			if (!ok) { a.ClearCounters(); a.Destroy(); continue; }
			a.ClearCounters();
			Actor.Spawn("TeleportFog", a.pos, ALLOW_REPLACE);
			if (p) { a.target = p; a.LastHeard = p; if (a.SeeState) a.SetState(a.SeeState); }
			sums.Push(a);
			if (h && h.debug) Console.Printf("RSQMB EXPOSED! t%d: boss %d summons %s at %.0f units from it", level.maptime, b.idx, a.GetClassName(),
				level.Vec2Diff(mb.pos.xy, a.pos.xy).Length());
			return a;
		}
		if (h && h.debug) Console.Printf("RSQMB EXPOSED! t%d: boss %d found no spot for %s", level.maptime, b.idx, c.GetClassName());
		return null;
	}

	// at the wind-up's start (telegraph.zs WindStart), a Big Boss only; guard: GUARD's wave (GuardStart)
	void SummonStart(RSQMB_Handler h, PlayerPawn p, bool guard = false)
	{
		if (!Big() || CI('rsqmb_big_summons', 1) == 0) return;
		let mb = b.mb;
		int ex = act - 1;
		int n = clamp(CI('rsqmb_big_summon_n', 2), 0, 12) + ex;
		int room = max(0, clamp(CI('rsqmb_big_summon_max', 6), 0, 24) - SumAlive());
		// bigkit.zs: only monsters its own code spawns (none: nothing comes, and no GUARD)
		let k = Kit();
		if (k)
		{
			int want = guard ? max(1, min(n, room)) : min(n, room);
			int got = want > 0 ? k.Summon(self, h, p, guard, want) : 0;
			if (h && h.debug) Console.Printf("RSQMB %s t%d: boss %d's own summons: %d", guard ? "GUARD" : "EXPOSED!", level.maptime, b.idx, got);
			return;
		}
		if (pers == BB_NONE) return;
		switch (pers)
		{
		case BB_TYRANT:
		{
			n = min(n, room);
			if (n > 0) mb.A_StartSound("brain/spit", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			bool wraith = false;
			for (int k = 0; k < sums.Size(); k++) if (sums[k] && sums[k].GetClassName() == 'RS_MolochWraith') wraith = true;
			for (int k = 0; k < n; k++)
			{
				Class<Actor> c;
				if (!wraith) { c = ByName("RS_MolochWraith", "LostSoul"); wraith = true; }
				else c = (k & 1) ? ByName("RS_RedDemon", "Demon") : ByName("RS_RedImp", "DoomImp");
				SummonAt(h, c, p, (0, 0), 160, 320);
			}
			break;
		}
		case BB_WARLORD:
			n = min(n + 1, room);
			if (n > 0) mb.A_StartSound("imp/sight", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			for (int k = 0; k < n; k++) SummonAt(h, ByName("RS_BlackImp", "DoomImp"), p, (0, 0), 160, 320);
			break;
		case BB_KNIGHT:
			n = min(n, room);
			if (n > 0) mb.A_StartSound("knight/sight", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			for (int k = 0; k < n; k++) SummonAt(h, ByName("RS_RedHK", "HellKnight"), p, (0, 0), 160, 320);
			if (n > 0) Say(h, "SQUIRES!", mb, p);
			break;
		case BB_BOG:
		{
			// GUARD: his swamp spawn (Mancubus-family) are the wave (BIG_BOSS.md 14)
			if (guard)
			{
				n = min(max(1, n - 1), room);
				if (n > 0) mb.A_StartSound("fatso/sight", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
				for (int k = 0; k < n; k++) SummonAt(h, ByName("RS_RedFatso", "Fatso"), p, (0, 0), 192, 384);
				break;
			}
			// BURP BLOBS!: projectiles, not monsters (no cap)
			if (!p) break;
			mb.A_StartSound("fatso/raiseguns", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			int dmg = max(1, Damage() / 2);
			for (int k = 0; k < n; k++)
				Shot("RSQMB_Blob", mb.pos + (0, 0, 2) + (cos(mb.angle), sin(mb.angle), 0) * mb.radius,
					mb.AngleTo(p) + (k - (n - 1) / 2.0) * 30.0, 0, 3, dmg, p);
			Say(h, "BURP BLOBS!", mb, p);
			break;
		}
		case BB_BENELLUS:
		{
			// his two Shotgun Shrines, one each side of him; only while fewer than two of them stand
			int have = 0;
			for (int k = 0; k < sums.Size(); k++) if (sums[k] && sums[k].GetClassName() == 'RS_ShotgunShrine') have++;
			String shn = "RS_ShotgunShrine";     // a string first: resolved at run time, so RSQ Monsters need not be loaded
			Class<Actor> c = shn;
			if (!c || have >= 2) break;
			mb.A_StartSound("weapons/sshotl", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			Vector2 rt = (sin(mb.angle), -cos(mb.angle));
			for (int s = 0; s < 2 - have; s++) SummonAt(h, c, p, rt * (s == 0 ? 120 : -120), 0, 0);
			if (guard) Say(h, "SHOOT THE SHRINES!", mb, p);
			break;
		}
		}
	}

	// the Big Boss gone: its summons with it (no source: nobody is paid for them)
	void SummonsEnd()
	{
		for (int i = 0; i < sums.Size(); i++)
		{
			let a = sums[i];
			if (a && a.health > 0) a.DamageMobj(null, null, a.health + 1000, 'None', DMG_FORCED | DMG_THRUSTLESS | DMG_NO_ARMOR);
		}
		sums.Clear();
	}

	// ---- EACH LIFE ITS OWN PHASE (owner 2026-11-23: "Force its own phases"; BIG_BOSS.md 11-15) ---------------------------
	// RSQ Monsters' EX bosses change phase by their own health (RS_Act.zs); a Big Boss's health is refilled each life, so the
	// act decides instead: the token RSQMB_ActPhase, its amount the act (RSQMN_Act.At / Of read it by name). The Hell Smith:
	// life 2 its Phase 2 (the Smithy: portal summons, BigHell, lightning), life 3 its Phase 3 (Supersmith); the bog: life 2
	// and 3 its Phase 2; the Imp Warlord: his seeker rain from life 2; Benellus: his Gifts from life 2. The Black Knight's
	// lives are bodies (his own kit spawns them on his death, which a Big Boss's lives never reach): life 2 his wraith
	// (RS_BlackRevEx2), life 3 his shadow (RS_BlackRevEx3), swapped in where he stands, the fight kept on the new body.
	void ActMark()
	{
		if (!Big() || !b.mb) return;
		Class<Inventory> c = "RSQMB_ActPhase";
		int have = b.mb.CountInv(c);
		if (have < act) b.mb.GiveInventory(c, act - have);
		else if (have > act) b.mb.TakeInventory(c, have - act);
	}

	void ActChanged(RSQMB_Handler h)
	{
		if (!Big()) { BossActUp(h); return; }
		if (pers == BB_KNIGHT && CI('rsqmb_big_bodies', 1) != 0) KnightBody(h);
		ActMark();
		if (Kit()) Kit().OnAct(self, h, act);
		if (h && h.debug) Console.Printf("RSQMB act t%d: boss %d %s life %d (its own phase %d)", level.maptime, b.idx, b.mb ? b.mb.GetClassName() : 'gone', act, act);
	}

	// A BOSS STEPS UP EACH LIFE (owner 2026-11-23 09:32, "yes": "a colour step up the tier ladder, a bit faster, and a fresh
	// thrall or two"). A Boss's (not a Big Boss's) life after the first: its colour one step up the ladder on its bar, its
	// glow and its light (the monster's own body and colour stay: since 2026-11-17 nothing in a fight swaps its body, fight.zs
	// HoldTiers); x(1 + rsqmb_boss_act_speed x (life - 1)) its speed (0.15); rsqmb_boss_act_thralls (1) fresh thralls of its
	// own thralls' kind landing near it, bound to it as thralls (they cut its damage and must die as any thrall; RSQMB_Called
	// as every thrall, 2026-11-27). Each life lost also throws a burst of ammo bits at its feet through RSQ VisualRewards
	// (boss.zs LoseLife, owner 2026-11-27: "Ammo burst when the Boss steps up").
	double actBaseSpeed;
	void BossActUp(RSQMB_Handler h)
	{
		let mb = b.mb;
		if (!mb || !h || CI('rsqmb_boss_actup', 1) == 0) return;
		int ex = act - 1;
		// faster
		if (actBaseSpeed <= 0) actBaseSpeed = mb.Speed;
		mb.Speed = actBaseSpeed * (1.0 + clamp(CF('rsqmb_boss_act_speed', 0.15), 0.0, 1.0) * ex);
		// a colour up: its bar, its glow, its light
		int t0 = h.TierOfMon(mb);
		int t = clamp((t0 > 0 ? t0 : 1) + ex, 1, 13);
		int rgb = RSQMB_Handler.LadderRGB(t);
		b.col = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
		b.glowSent = -1;
		mb.A_AttachLight('RSQMB_Boost', DynamicLight.PointLight, Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255), int(max(64, mb.radius * 3)), 0, 0, (0, 0, mb.Height * 0.6));
		// fresh thralls of its own thralls' kind
		Class<Actor> tc = null;
		for (int i = 0; i < b.thr.Size() && !tc; i++) if (b.thr[i]) tc = b.thr[i].GetClass();
		int n = clamp(CI('rsqmb_boss_act_thralls', 1), 0, 6);
		let p = Victim();
		if (h.debug) Console.Printf("RSQMB act t%d: fresh thralls: %d of %s for %s", level.maptime, n, tc ? tc.GetClassName() : 'none', p ? p.GetClassName() : 'nobody');
		int got = 0;
		for (int k = 0; k < n && tc; k++)
		{
			let a = SummonAt(h, tc, p, (0, 0), 128, 256);
			if (!a) continue;
			sums.Delete(sums.Find(a));      // a thrall, not a Big Boss's summon
			a.health = max(1, int(a.health * RSQMB_Handler.ThrallHpMult()));
			b.thr.Push(a);
			b.thrState.Push(RSQMB_Boss.ST_ALIVE);
			let tok = RSQMB_Thrall(a.GiveInventoryType("RSQMB_Thrall"));
			if (tok) tok.boss = b;
			// marked as every thrall the fight brings (the landing, SUMMONER!'s fodder, SPLITTER!'s copy): no Boss meter fill
			// and no gun drop (thralldrops.zs). 2026-11-27, owner: "thralls drop bits, not guns"
			a.GiveInventoryType("RSQMB_Called");
			b.total++;
			got++;
		}
		b.wordState = -9;
		if (h.debug) Console.Printf("RSQMB act t%d: boss %d %s life %d steps up: colour tier %d -> %d, speed %.1f, %d fresh thrall%s (%d living of %d)", level.maptime, b.idx, mb.GetClassName(),
			act, t0, t, mb.Speed, got, got == 1 ? "" : "s", b.Living(), b.total);
	}

	void KnightBody(RSQMB_Handler h)
	{
		let old = b.mb;
		if (!old) return;
		String cn = act == 2 ? "RS_BlackRevEx2" : (act >= 3 ? "RS_BlackRevEx3" : "");
		Class<Actor> c = cn;
		if (!c) return;
		if (h) h.swapNoRoll = c;           // carry.zs: Champions does not roll the new body
		let nb = Actor.Spawn(c, old.pos, NO_REPLACE);
		if (h) h.swapNoRoll = null;
		if (!nb) return;
		nb.angle = old.angle;
		nb.target = old.target;
		int hp = old.health, mx = b.maxHP;
		ClearWeakPoints(true);
		Unpin(old);
		b.Rebody(-1, nb, h);
		nb.health = max(1, hp);
		b.maxHP = mx;
		if (nb.SeeState) nb.SetState(nb.SeeState);
		Actor.Spawn("TeleportFog", old.pos, ALLOW_REPLACE);
		old.ClearCounters();
		old.Destroy();
		if (h && h.debug) Console.Printf("RSQMB act t%d: the Black Knight's life %d is his %s (%d health kept)", level.maptime, act, c.GetClassName(), hp);
	}

	// ---- GUARD AFTER EXPOSED! (BIG_BOSS.md 11-15; owner 2026-11-23: built, cap "20 s") --------------------------------------
	// After its window (the attack fired, or BREAK!'s stagger over) a Big Boss puts its shield up (no damage: the Boss bar's
	// GUARD, items.zs RSQMB_Ward) and its own summons come as the wave (SummonStart, guard: the bog's swamp spawn instead of
	// blobs, Benellus' Shrines with SHOOT THE SHRINES!). The shield drops when every summon of its is dead, or after
	// rsqmb_big_guard_secs (20 s). No wind-up while it holds; the next one comes Interval() after the drop. A life lost, or
	// the fight over, drops it.
	void GuardStart(RSQMB_Handler h, PlayerPawn p)
	{
		if (!Big() || (pers == BB_NONE && !Kit()) || CI('rsqmb_big_guard', 1) == 0 || !b.mb || b.mb.health <= 0) return;
		SummonStart(h, p, true);
		if (SumAlive() == 0) { if (h && h.debug) Console.Printf("RSQMB GUARD t%d: boss %d has no summons standing: no GUARD", level.maptime, b.idx); return; }
		b.guardUp = true;
		b.guardUntil = level.maptime + int(clamp(CF('rsqmb_big_guard_secs', 20.0), 3.0, 120.0) * TICRATE);
		b.mb.A_StartSound("misc/invuln", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		if (h && h.debug) Console.Printf("RSQMB GUARD t%d: boss %d shield up, %d summons are the wave, until t%d", level.maptime, b.idx, SumAlive(), b.guardUntil);
	}

	// every tic (telegraph.zs Step): true while it holds (no wind-up)
	bool GuardStep(RSQMB_Handler h, int now)
	{
		if (!b || !b.guardUp) return false;
		if (SumAlive() == 0) { GuardEnd(h, "its wave is dead"); return false; }
		if (now >= b.guardUntil) { GuardEnd(h, "the time cap"); return false; }
		if (windAt) Cancel(h, "GUARD");
		if ((now & 1) == 0) Tethers();
		return true;
	}

	// THE LINES (owner 2026-11-25: "why am i shooting these imps ... if the weak points are on his body?"; "a line yes", no
	// word): while the shield holds, a line of light from each summon that holds it to the Big Boss, so the wave reads as
	// the shield's. Drawn every second tic (particles live 3), a dot every TETHER_STEP units, at mid height.
	const TETHER_STEP = 24.0;
	const TETHER_RGB = 0x66CCFF;
	void Tethers()
	{
		let mb = b.mb;
		if (!mb) return;
		Vector3 to = mb.pos + (0, 0, mb.height * 0.5);
		for (int i = 0; i < sums.Size(); i++)
		{
			let a = sums[i];
			if (!a || a.health <= 0) continue;
			Vector3 from = a.pos + (0, 0, a.height * 0.5);
			Vector3 d = level.Vec3Diff(from, to);
			double len = d.Length();
			if (len < 1) continue;
			int n = clamp(int(len / TETHER_STEP), 2, 80);
			FSpawnParticleParams pp;
			pp.color1 = TETHER_RGB;
			pp.texture = TexMan.CheckForTexture("", TexMan.Type_Any);
			pp.style = STYLE_Add;
			pp.flags = SPF_FULLBRIGHT;
			pp.lifetime = 3;
			pp.size = 4;
			pp.startalpha = 0.8;
			pp.fadestep = -1;
			for (int k = 0; k <= n; k++)
			{
				pp.pos = level.Vec3Offset(from, d * (k / double(n)));
				level.SpawnParticle(pp);
			}
		}
	}

	void GuardEnd(RSQMB_Handler h, String why)
	{
		if (!b || !b.guardUp) return;
		b.guardUp = false;
		b.guardUntil = 0;
		if (b.mb && b.mb.health > 0) b.mb.A_StartSound("misc/i_pkup", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		nextAt = level.maptime + Interval();
		if (h && h.debug) Console.Printf("RSQMB GUARD t%d: boss %d shield down (%s)", level.maptime, b ? b.idx : -1, why);
	}

	// ---- SUPERSMITH'S PENTAGRAMS -------------------------------------------------------------------------------------
	bool SupersmithOn() { return Big() && pers == BB_TYRANT && act >= 3 && CI('rsqmb_ss_penta', 1) != 0; }

	// every tic (telegraph.zs Step, before its early returns)
	void PentaStep(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		// SUPERSMITH+ held: the Hell Smith's own walk sets its speed back to 20 every loop (A_SetSpeed(20)); whenever it is
		// back at that walking speed it gets the boost again (its charge, A_SetSpeed(99), is left alone). Rig bb1, 11-23.
		if (ssPlus && mb && abs(mb.Speed - ssBaseSpeed) < 0.01) mb.Speed = ssBaseSpeed * clamp(CF('rsqmb_ss_plus_speed', 1.35), 1.0, 3.0);
		if (penta)
		{
			if (penta.broken || penta.bDestroyed || penta.health <= 0) { PentaDone(h, true); return; }
			// it heals standing on it
			double perTic = b.maxHP * clamp(CF('rsqmb_ss_heal_pct', 4.0), 0.0, 50.0) / 100.0 / TICRATE;
			penta.healAcc += perTic;
			int add = int(penta.healAcc);
			if (add > 0) { penta.healAcc -= add; mb.health = min(max(mb.health, b.maxHP), mb.health + add); }
			int left = (pentaEnd - now + TICRATE - 1) / TICRATE;
			if (left != pentaShown && left > 0) { pentaShown = left; PentaWord(h, left); }
			if (now >= pentaEnd) PentaDone(h, false);
			return;
		}
		if (!SupersmithOn()) return;
		if (pentaNext == 0) { pentaNext = now + 6 * TICRATE; return; }
		if (now < pentaNext || windAt || brkUntil > now || b.Invulnerable()) return;
		if (nextAt > 0 && nextAt - now < 4 * TICRATE) return;
		PentaPlant(h, now);
	}

	void PentaPlant(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		let pe = RSQMB_SSPenta(Actor.Spawn("RSQMB_SSPenta", (mb.pos.xy, mb.floorz), NO_REPLACE));
		if (!pe) { pentaNext = now + TICRATE; return; }
		pe.tele = self;
		pe.rad = clamp(mb.radius * 1.6, 48.0, 120.0);
		int hp = max(1, CI('rsqmb_ss_penta_hp', 400));
		pe.health = hp;
		pe.StartHealth = hp;
		penta = pe;
		int secs = clamp(CI('rsqmb_ss_count', 3), 1, 10);
		pentaEnd = now + secs * TICRATE;
		pentaShown = 0;
		Pin(mb, pentaEnd + 1, false, false);       // it stands on it
		mb.A_StartSound("vile/raise", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
		pe.A_StartSound("brain/cube", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		if (h && h.debug) Console.Printf("RSQMB SUPERSMITH t%d: boss %d plants a pentagram (%d hp, %d s, heals %.1f%% a second)", now, b.idx, hp, secs,
			CF('rsqmb_ss_heal_pct', 4.0));
	}

	// CRITICAL TARGET! n over the pentagram: VisualRewards' held monster word (the size of WEAK! over a weak point), each
	// second's count put up in place of the last one (until 2026-11-27 a world word at size 1.2: the CRITICAL! cause,
	// telegraph.zs Say)
	void PentaWord(RSQMB_Handler h, int left)
	{
		let vr = h ? h.VrService() : null;
		String t = String.Format("CRITICAL TARGET! %d", left);
		if (vr && penta)
		{
			if (penta.word != "" && penta.word != t) vr.GetInt("word.clear", penta.word, 0, 0, penta);
			penta.word = t;
			if (vr.GetInt("word.hold", t, 0xE628DC, 1.0, penta) > 0) return;
		}
		for (int i = 0; i < MAXPLAYERS; i++)
			if (playeringame[i] && players[i].mo) players[i].mo.A_Print(t, 1.1, "BIGFONT");
	}

	// shot down (broken) or the countdown out (SUPERSMITH+)
	void PentaDone(RSQMB_Handler h, bool broken)
	{
		int now = level.maptime;
		let mb = b.mb;
		if (penta && !penta.bDestroyed) penta.Fade(broken);
		penta = null;
		pentaNext = now + int(clamp(CF('rsqmb_ss_penta_secs', 15.0), 4.0, 120.0) * TICRATE);
		if (mb) Unpin(mb);
		if (broken)
		{
			if (h) { let vr = h.VrService(); if (vr && mb) vr.GetInt("pop", "", 0xFF2030, 1.5, mb); }
			if (h && h.debug) Console.Printf("RSQMB SUPERSMITH t%d: boss %d's pentagram shot down", now, b.idx);
			return;
		}
		if (!mb) return;
		if (!ssPlus)
		{
			ssPlus = true;
			ssBaseSpeed = mb.Speed;
			mb.Speed = ssBaseSpeed * clamp(CF('rsqmb_ss_plus_speed', 1.35), 1.0, 3.0);
		}
		ssPlusFire = true;
		mb.A_StartSound(mb.SeeSound, CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
		Say(h, "SUPERSMITH+", mb, null);
		if (h && h.debug) Console.Printf("RSQMB SUPERSMITH+ t%d: boss %d speed %.1f -> %.1f, its next big attack has more slams", now, b.idx, ssBaseSpeed, mb.Speed);
	}

	// a wind-up starts: SUPERSMITH+'s speed ends (its extra slams stay for this wind-up's attack); a pentagram goes
	void SupersmithWind(RSQMB_Handler h)
	{
		if (penta) { penta.Fade(false); penta = null; }
		if (ssPlus && b.mb) b.mb.Speed = ssBaseSpeed;
		ssPlus = false;
	}

	void PentaRelease()
	{
		if (penta) { penta.Fade(false); penta = null; }
		if (ssPlus && b && b.mb) b.mb.Speed = ssBaseSpeed;
		ssPlus = false;
		ssPlusFire = false;
	}
}

// ============================================================================
// SUPERSMITH'S PENTAGRAM: a red pentagram of particles on the floor, shootable (players only), its HP bar and the line up to
// CRITICAL TARGET! drawn over it. Its box is low and wide, on the floor.
// ============================================================================
class RSQMB_SSPenta : Actor
{
	RSQMB_Tele tele;
	double rad, healAcc;
	bool broken, fading;
	int fadeLeft;
	String word;           // the CRITICAL TARGET! word held over it now (PentaWord), cleared as it fades

	Default
	{
		Radius 32;
		Height 24;
		Health 400;
		Mass 100000;
		RenderStyle "None";
		+SHOOTABLE
		-SOLID
		+NOGRAVITY
		+NOBLOOD
		+DONTTHRUST
		+NOTARGET
		+NEVERTARGET
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTAUTOAIMED
		+NOICEDEATH
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (passive && other && other.bMISSILE && !RSQMB_Handler.PlayerOf(other.target)) return false;
		return Super.CanCollideWith(other, passive);
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (broken || fading || !tele) return 0;
		Actor p = RSQMB_Handler.PlayerOf(source);
		if (!p) p = RSQMB_Handler.PlayerOf(inflictor);
		if (!p) return 0;
		return Super.DamageMobj(inflictor, p, damage, mod, flags | DMG_THRUSTLESS, angle);
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		broken = true;
		bSHOOTABLE = false;
		A_StartSound("imp/shotx", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		RSQMB_Boss.Burst(pos + (0, 0, 8), Color(255, 255, 40, 40), RSQMB_Handler.FxLight() ? 10 : 20, 4.0, 5);
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}

	// gone: fades out over a second
	void Fade(bool wasBroken)
	{
		if (fading) return;
		fading = true;
		broken = broken || wasBroken;
		bSHOOTABLE = false;
		fadeLeft = TICRATE;
		tele = null;
		let h = RSQMB_Handler.Get();
		let vr = h ? h.VrService() : null;
		if (vr && word != "") vr.GetInt("word.clear", word, 0, 0, self);
		word = "";
	}

	void Pt(double x, double y, double z, int col, double a, double sz = 5)
	{
		A_SpawnParticle(col, SPF_FULLBRIGHT, 3, sz, 0, x - pos.x, y - pos.y, z - pos.z, 0, 0, 0, 0, 0, 0, a, 0);
	}

	override void Tick()
	{
		if (isFrozen()) return;
		if (fading) { if (--fadeLeft <= 0) { Destroy(); return; } }
		else if (!tele) { Destroy(); return; }
		if (level.maptime & 1) return;      // drawn every second tic (particles live 3)
		double a = fading ? fadeLeft / double(TICRATE) : 1.0;
		double z = pos.z + 1;
		int red = 0xFF2010;
		// the ring and the star
		for (int k = 0; k < 72; k++) Pt(pos.x + cos(k * 5.0) * rad, pos.y + sin(k * 5.0) * rad, z, red, a);
		double px[5], py[5];
		for (int k = 0; k < 5; k++) { px[k] = pos.x + cos(90.0 + 72.0 * k) * rad; py[k] = pos.y + sin(90.0 + 72.0 * k) * rad; }
		for (int k = 0; k < 5; k++)
		{
			int j = (k + 2) % 5;
			double dx = px[j] - px[k], dy = py[j] - py[k];
			int n = max(2, int(sqrt(dx * dx + dy * dy) / 6));
			for (int l = 0; l <= n; l++) Pt(px[k] + dx * l / n, py[k] + dy * l / n, z, red, a);
		}
		if (fading) return;
		// the line up to CRITICAL TARGET! and its HP bar
		double top = z + 96;
		for (double lz = z + 8; lz < top - 10; lz += 6) Pt(pos.x, pos.y, lz, 0xFF60C0, 0.9, 3);
		double frac = StartHealth > 0 ? clamp(health / double(StartHealth), 0.0, 1.0) : 0;
		// the bar runs across the way you see it
		Actor v = players[consoleplayer].mo;
		double ang = v ? AngleTo(v) + 90.0 : 0;
		Vector2 across = (cos(ang), sin(ang));
		double w = 48;
		for (double s = 0; s <= w; s += 3)
		{
			Vector2 xy = pos.xy + across * (s - w / 2);
			Pt(xy.x, xy.y, top - 6, (s / w) <= frac ? 0xFF2020 : 0x302020, 0.95, 4);
		}
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	Death:
		TNT1 A 1;
		Wait;
	}
}

// a Big Boss's act, for RSQ Monsters' EX bosses (RS_Act.zs, by name): its amount is the act
class RSQMB_ActPhase : Inventory
{
	Default
	{
		Inventory.MaxAmount 9;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}
}
