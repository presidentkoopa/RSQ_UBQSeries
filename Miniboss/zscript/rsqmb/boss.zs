// ============================================================================
// RSQ_Miniboss -- one miniboss and its thralls (a Thinker: saved with the level).
//
// THE REWORK (owner + Claude 2026-11-09, design/MINIBOSS_REWORK.md; the rules in fight.zs):
//   SEGMENTS  one a thrall it came with, each a share of its health (its health at the bind / the thralls): the thrall bar.
//             Damage goes into the open segment first (items.zs RSQMB_Ward), then, every segment broken, its own bar.
//   SHIELD    while a thrall lives and a segment is left and no window is open, it takes NO damage (grey Xs, "GUARD!").
//   WINDOW    a thrall killed opens one on the first unbroken segment: 1 s x the thralls it came with, or until that
//             segment breaks; missed, everything tiers up (fight.zs).
//   POWERS    each thrall's Champions power is LOST with that thrall (StripPowers).
//   LIVES     it holds BUDDHA while it has a life to spare; the tic it sits at 1 hp it loses a life, refills to the most
//             health it has had (so Champions' and LegenDoom's own boosts count), is invulnerable for rsqmb_invuln s (the
//             flames), and (Tier Up Each Life) tiers up one with RSQ Monsters' flash. On its last life BUDDHA goes back to
//             what the monster had. NO THRALLS RISE (owner 08:14: the original Minibosses!' revive is gone).
//   A NEW BODY RSQ Monsters' CH tier change swaps the class (a new actor): fight.zs Follow finds it, Rebody dresses it.
//
// The FX are the original's IWAD sprites drawn as a pooled set of VisualThinkers (fx.zs); these particles are only
// the fallback when a sprite can't be found. The original's link trails were 30 ACTORS a thrall warped every tic.
// ============================================================================

class RSQMB_Boss : Thinker
{
	Actor mb;
	Array<Actor> thr;
	Array<int>   thrState;       // ST_ALIVE / ST_DEAD / ST_LOST (gone for good)
	int    total;                // thralls bound at the start (the segments, the window's seconds)
	int    lives;                // lives left, the current one included
	int    maxHP;
	bool   ownBuddha;            // the monster's own BUDDHA before we took it
	int    invulUntil;
	int    invulFrom;            // the tic it last lost a life (the flames light from it)
	// THE ARRIVAL'S CHARGE (owner 11-12 14:11: "the miniboss comes in and its bar fills up quickly, smoothly. during this
	// time, let's say all miniboss and thralls are invuln but not attacking. the miniboss bar takes 3 seconds to charge up"):
	// until chargeUntil the miniboss and its thralls are DORMANT (they do not act) and INVULNERABLE; their own flags are
	// kept and put back (ChargeEnd). The HUD's bar fills and its clock counts down over the same tics (bossbar.zs).
	int    chargeUntil;
	bool   chargeHeld;
	Array<Actor> chWho;
	Array<bool>  chDorm, chInv;
	void ChargeStart(int tics)
	{
		if (chargeHeld || tics <= 0) return;
		chargeUntil = level.maptime + tics;
		chargeHeld = true;
		chWho.Clear(); chDorm.Clear(); chInv.Clear();
		for (int i = -1; i < thr.Size(); i++)
		{
			Actor a = i < 0 ? mb : thr[i];
			if (!a) continue;
			// a landed one is already held DORMANT and INVULNERABLE by the arrival (bossfight.zs Reveal): its own are
			// not dormant, and the INVULNERABLE read there
			bool ownD = a.bDORMANT, ownI = a.bINVULNERABLE;
			let hh = H();
			if (hh) for (int k = 0; k < hh.arrMon.Size(); k++) if (hh.arrMon[k] == a) { ownD = false; ownI = k < hh.arrOwnInv.Size() ? hh.arrOwnInv[k] : false; break; }
			chWho.Push(a); chDorm.Push(ownD); chInv.Push(ownI);
			a.bDORMANT = true; a.bINVULNERABLE = true;
		}
	}
	void ChargeEnd()
	{
		if (!chargeHeld) return;
		chargeHeld = false;
		for (int i = 0; i < chWho.Size(); i++)
		{
			Actor a = chWho[i];
			if (!a) continue;
			a.bDORMANT = chDorm[i]; a.bINVULNERABLE = chInv[i];
			let hh = H();
			if (hh) hh.Wake(a);
		}
		chWho.Clear(); chDorm.Clear(); chInv.Clear();
	}
	double toughness, outMult;   // inherited: damage taken / toughness, damage dealt x outMult
	Array<String> powers;        // what it inherited, for the service and the log
	Array<int>    powerFrom;     // the thrall each power came from (-1: legendary, from them all)
	Array<int>    powerAdd;      // what it added: 1 a token given / a life added / the stat applied, 0 nothing (already its own, capped)
	bool   legendary;            // inherited LegenDoom Lite's legendary status
	Color  col;
	int    idx;
	bool   done, enraged, greedArmed;
	int    greedDeadline;
	int    diedAt;               // the tic it died (Boss Kill Rewards counts a just-killed miniboss)
	bool   called;               // a Bossfight (called in, bossfight.zs), not the classic pick
	int    tier;                 // the Bossfight's tier, 0..4
	// THE ICONS BESIDE ITS BAR (owner 11-10, design/icons style B; hud.zs DrawStack): read every half second in play
	int    ladder;               // RSQ Monsters' tier of the miniboss's body, 1..13 (its RSQMN_RosterService "tier"), 0 none
	Array<int> champIcons;       // its Champion powers, its own and inherited: 0..16 the types, 18..21 the mutations
	void ReadIcons(Service roster)
	{
		ladder = 0;
		champIcons.Clear();
		if (!mb) return;
		if (roster) { int t = roster.GetInt("tier", "", 0, 0, mb); if (t >= 1 && t <= 13) ladder = t; }
		static const String COL[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo",
			"Violet", "Pink", "Black", "Grey", "White", "Bronze", "Silver", "Gold" };
		static const String MUT[] = { "Titan", "Undying", "Ghost", "Balloon" };
		for (int i = 0; i < 17; i++) { class<Inventory> c = "champion_" .. COL[i] .. "Token"; if (c && mb.FindInventory(c)) champIcons.Push(i); }
		for (int i = 0; i < 4; i++) { class<Inventory> c = "champion_" .. MUT[i] .. "Token"; if (c && mb.FindInventory(c)) champIcons.Push(18 + i); }
	}

	// THE THRALL BAR AND THE WINDOW (fight.zs)
	Array<double> segHP;         // what is left of each segment
	double segMax;               // a segment's size: its health at the bind / total (re-sized while untouched, LegenDoom
	                             // sets a legendary's health a tic or two later)
	bool   segTouched;
	int    winSeg;               // the open segment, -1 none
	int    winStart, winEnd;     // the window's tics
	int    winCredits;           // thrall kills waiting for a window
	int    lifeLostAt;           // the tic it last lost a life (the room's red, the HUD's refill)
	int    wordState;            // the words shown (fight.zs WordsStep), -9 re-send
	int    glowSent, glowTic;    // the room's glow sent last (fight.zs RoomGlow)
	int    guardTic, xTic;       // the last "GUARD!" word, the last grey X
	double carry;                // a fraction of a point carried to the next blow (items.zs)

	// COUNTS AS A BOSS (owner 2026-11-03): never the engine's BOSS flag; only the systems the owner picked, each on
	// its own switch. The two flag-borne ones are written only while their switch is on, and put back after.
	bool   ownFullSee, ownFullDeath, ownDontMorph;   // the monster's own flags, read when it was bound
	bool   roarSet, noMorphSet;                       // our flags are on it now
	int    deathFlagUntil;                            // FULLVOLDEATH outlives the death this long (its scream plays later)
	bool   ldBoss;                                    // its legendary health is LegenDoom's best (max of boss, normal): Miniboss did it
	bool   ldShPending;                               // StartHealth is ours until LegenDoom Lite's ACS has read it
	int    ldShOwn, ldShUntil, ldTarget;

	enum EState { ST_ALIVE, ST_DEAD, ST_LOST }

	private transient RSQMB_Handler hnd;
	RSQMB_Handler H() { if (!hnd) hnd = RSQMB_Handler.Get(); return hnd; }

	// ---- the rules, read by the ward (items.zs), the HUD (hud.zs) and the service -------------------------------------------
	clearscope bool Invulnerable() const { return !done && (level.maptime < invulUntil || level.maptime < chargeUntil); }

	clearscope int Living() const
	{
		int n = 0;
		for (int i = 0; i < thr.Size(); i++) if (thrState[i] == ST_ALIVE) n++;
		return n;
	}
	clearscope int SegsLeft() const
	{
		int n = 0;
		for (int i = 0; i < segHP.Size(); i++) if (segHP[i] > 0) n++;
		return n;
	}
	// the first unbroken segment (the thrall bar drains left to right), -1 none
	clearscope int OpenSeg() const
	{
		for (int i = 0; i < segHP.Size(); i++) if (segHP[i] > 0) return i;
		return -1;
	}
	// SHIELD UP: a thrall stands, a segment is left, no window is open: no damage at all
	clearscope bool ShieldUp() const { return !done && winSeg < 0 && SegsLeft() > 0 && Living() > 0; }
	// 0 shield up, 1 a window, 2 one-on-one (no segment left, or no thrall standing: its segments take damage freely)
	clearscope int FightState() const
	{
		if (winSeg >= 0) return 1;
		if (SegsLeft() == 0 || Living() == 0) return 2;
		return 0;
	}
	// the damage it takes now, as a share (the service's "shield"): 0 shielded or invulnerable
	clearscope double TakeFactorData() const
	{
		if (Invulnerable() || ShieldUp()) return 0;
		return 1.0 / max(1.0, toughness);
	}

	void NoteStruck() { let h = H(); if (h) h.NoteGreed(self); }

	// ---- every tic ------------------------------------------------------------------------------
	override void Tick()
	{
		if (done)
		{
			if (deathFlagUntil > 0 && level.maptime >= deathFlagUntil) { deathFlagUntil = 0; if (mb) mb.bFULLVOLDEATH = ownFullDeath; }
			return;
		}
		if (level.isFrozen()) return;
		let h = H();
		double t0 = (h && h.debug) ? MSTimeF() : 0;
		Step(h);
		if (h && h.debug) h.AddCost(MSTimeF() - t0);
	}

	private void Step(RSQMB_Handler h)
	{
		// its body swapped by an RSQ Monsters tier change this tic: not a death (fight.zs Follow finds the new one)
		if ((!mb || mb.bDestroyed) && h && h.Following(self, -1)) return;
		if (!mb || mb.bDestroyed || mb.health <= 0) { if (h) h.BossDied(self, null); else done = true; return; }

		if (chargeHeld && level.maptime >= chargeUntil) ChargeEnd();
		if (ldShPending) LDHealthDone(h);
		if (mb.health > maxHP) maxHP = mb.health;
		// the segments follow its health until the first blow lands (LegenDoom sets a legendary's health a tic or two late)
		if (!segTouched && total > 0 && maxHP / double(total) > segMax)
		{
			segMax = maxHP / double(total);
			for (int i = 0; i < segHP.Size(); i++) segHP[i] = segMax;
		}
		if (h) Flags(h.roarOn, h.noMorphOn, h.debug);
		if (h && level.maptime % 10 == idx % 10) col = h.ColourOf(mb, idx) | 0xFF000000;

		// A life lost: BUDDHA held it at 1 hp.
		if (lives > 1 && mb.health <= 1) LoseLife(h);

		// Thralls: alive, dead, or gone (destroyed, gibbed away). Dead ones stay dead (no revive since the rework).
		for (int i = 0; i < thr.Size(); i++)
		{
			let t = thr[i];
			if (!t || t.bDestroyed)
			{
				if (h && h.Following(self, i)) continue;      // its body is being swapped (a tier change)
				if (thrState[i] == ST_ALIVE && h) h.ThrallGone(self, i);
				thrState[i] = ST_LOST;
				continue;
			}
			if (thrState[i] == ST_ALIVE && t.health <= 0) { thrState[i] = ST_DEAD; if (h) h.ThrallKilled(self, i, t, null); }   // died without the event
			else if (thrState[i] == ST_DEAD && t.health > 0) thrState[i] = ST_ALIVE;      // raised by someone else (an Arch-vile)
		}

		if (invulUntil > 0 && level.maptime == invulUntil && h) h.FxInvulEnd(self);

		if (h && h.fxOn && !h.UseSprites()) FX(h);   // the particle fallback; the sprites are fx.zs
	}

	private void LoseLife(RSQMB_Handler h)
	{
		lives--;
		mb.health = max(maxHP, 1);
		double secs = h ? h.invulSecs : 5.0;
		invulFrom = level.maptime;
		invulUntil = level.maptime + max(1, int(secs * TICRATE));
		lifeLostAt = level.maptime;
		glowSent = -1;
		if (lives <= 1) mb.bBUDDHA = ownBuddha;
		mb.A_StartSound("weapons/bfgx", CHAN_AUTO, 0, 1.0, 0.5);
		if (h) h.FxLifeLost(self);
		// TIER UP EACH LIFE (owner 07:28, rsqmb_tier_life): one step up the ladder, with RSQ Monsters' flash
		bool up = h && h.tierLife && h.RetierBy(mb, 1, self, -1);
		if (h && h.debug) Console.Printf("RSQMB life lost: boss %d lives %d hp %d invuln %d tics%s", idx, lives, mb.health, invulUntil - level.maptime, up ? ", tier +1 asked" : "");
	}

	// ---- powers lost with their thrall (owner 06:42: "LOSE") -------------------------------------------------------------
	// Each power the miniboss inherited came from one thrall (powerFrom); that thrall killed, it goes: a token given is
	// taken back, a life it added is taken (never its last), Black's damage and the toughness come off. Returns the first
	// lost power's colour (the pop's), -1 none.
	int StripPowers(int ti, RSQMB_Handler h)
	{
		int rgb = -1;
		for (int k = powers.Size() - 1; k >= 0; k--)
		{
			if (k >= powerFrom.Size() || powerFrom[k] != ti) continue;
			String n = powers[k];
			bool added = k < powerAdd.Size() && powerAdd[k] != 0;
			if (added && mb)
			{
				if (n == "Yellow" || n == "White" || n == "DarkGreen" || n == "Cyan" || n == "Titan")
				{
					let tc = RSQMB_Handler.InvClass("champion_" .. n .. "Token");
					if (tc) mb.TakeInventory(tc, 999);
				}
				else if (n == "DarkRed" || n == "Undying") { if (lives > 1) lives--; if (lives <= 1) mb.bBUDDHA = ownBuddha; }
				else if (n == "Black") outMult = max(1.0, outMult / 1.5);
				else toughness = max(1.0, toughness - 0.5);
			}
			int c = RSQMB_Handler.PowerRGB(n);
			if (c >= 0) rgb = c;
			if (h && h.debug) Console.Printf("RSQMB power lost: boss %d loses %s with thrall %d%s", idx, n, ti, added ? "" : " (it had added nothing)");
			powers.Delete(k); powerFrom.Delete(k);
			if (k < powerAdd.Size()) powerAdd.Delete(k);
		}
		return rgb;
	}

	// ---- a new body (fight.zs Follow: RSQ Monsters' CH tier change swapped the class) -------------------------------------
	// role -1 the miniboss, else thrall `role`. The set piece's own tokens and what this mod did to it are given again.
	void Rebody(int role, Actor a, RSQMB_Handler h)
	{
		if (!a) return;
		a.GiveInventoryType("RSQMB_Called");
		if (role < 0)
		{
			mb = a;
			let w = RSQMB_Ward(a.GiveInventoryType("RSQMB_Ward"));
			if (w) w.boss = self;
			ownBuddha = a.bBUDDHA;
			ownFullSee = a.bFULLVOLSEE; ownFullDeath = a.bFULLVOLDEATH; ownDontMorph = a.bDONTMORPH;
			roarSet = false; noMorphSet = false;
			if (lives > 1) a.bBUDDHA = true;
			if (called)
			{
				a.A_SetScale(a.Scale.X * RSQMB_Handler.MB_SCALE, a.Scale.Y * RSQMB_Handler.MB_SCALE);
				a.A_SetSize(a.radius * RSQMB_Handler.MB_SCALE, a.height * RSQMB_Handler.MB_SCALE, false);
				RSQMB_Handler.Aggressive(a);
			}
			maxHP = max(1, a.health);
			for (int k = 0; k < powers.Size(); k++)
			{
				String n = powers[k];
				if (k < powerAdd.Size() && powerAdd[k] != 0 && (n == "Yellow" || n == "White" || n == "DarkGreen" || n == "Cyan" || n == "Titan"))
					RSQMB_Handler.Give(a, "champion_" .. n .. "Token");
			}
		}
		else if (role < thr.Size())
		{
			thr[role] = a;
			let tok = RSQMB_Thrall(a.GiveInventoryType("RSQMB_Thrall"));
			if (tok) tok.boss = self;
			if (called) a.A_SetScale(a.Scale.X * RSQMB_Handler.TH_SCALE, a.Scale.Y * RSQMB_Handler.TH_SCALE);
		}
		if (called)
		{
			int rgb = h ? h.ColourOf(a, idx) : (int(col) & 0xFFFFFF);
			a.A_AttachLight('RSQMB_Boost', DynamicLight.PointLight, Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255),
				int(max(64, a.radius * 3)), 0, 0, (0, 0, a.Height * 0.6));
			a.bBRIGHT = true;
		}
		wordState = -9;
		glowSent = -1;
	}

	// ---- counts as a boss: the flag-borne switches ---------------------------------------------
	// Map-wide Roar: FULLVOLSEE + FULLVOLDEATH (the sight and death sounds unattenuated, as a BOSS's are: p_enemy.cpp
	// A_Look, actor.zs A_Scream). Can't Be Morphed: DONTMORPH (morph.zs MorphMonster refuses it). Written only on a
	// change of the switch, so a flag someone else sets meanwhile is left alone while the switch stays put.
	void Flags(bool roar, bool noMorph, bool dbg)
	{
		if (!mb) return;
		bool changed = false;
		if (roar != roarSet)
		{
			roarSet = roar;
			mb.bFULLVOLSEE = roar || ownFullSee;
			mb.bFULLVOLDEATH = roar || ownFullDeath;
			changed = true;
		}
		if (noMorph != noMorphSet)
		{
			noMorphSet = noMorph;
			mb.bDONTMORPH = noMorph || ownDontMorph;
			changed = true;
		}
		if (changed && dbg) LogFlags("set");
	}

	void LogFlags(String why)
	{
		Console.Printf("RSQMB flags %s: boss %d %s FULLVOLSEE %d FULLVOLDEATH %d DONTMORPH %d BOSS %d (roar %d nomorph %d; own %d %d %d)",
			why, idx, mb ? mb.GetClassName() : 'gone', mb && mb.bFULLVOLSEE, mb && mb.bFULLVOLDEATH, mb && mb.bDONTMORPH, mb && mb.bBOSS,
			roarSet, noMorphSet, ownFullSee, ownFullDeath, ownDontMorph);
	}

	// LegenDoom: Best Health, the second half: LegenDoom Lite's ACS (LEGNDLIB.acs LDMonsterInit) has read our StartHealth
	// (it gives LDLegendaryMonsterToken first thing, then sets the health, in one run): the monster's own goes back.
	void LDHealthDone(RSQMB_Handler h)
	{
		String tk = "LDLegendaryMonsterToken";
		class<Inventory> ct = tk;
		bool got = ct && mb.FindInventory(ct);
		if (!got && level.maptime < ldShUntil) return;
		ldShPending = false;
		mb.StartHealth = ldShOwn;
		ldBoss = got;
		if (h && h.debug)
			Console.Printf("RSQMB LegenDoom best health: boss %d %s legendary %d hp %d (asked %d; StartHealth back to %d, SpawnHealth %d)",
				idx, mb.GetClassName(), got, mb.health, ldTarget, mb.StartHealth, mb.SpawnHealth());
	}

	// The miniboss is dead: the links break, the thralls are free monsters again.
	void Finish()
	{
		done = true;
		ChargeEnd();
		diedAt = level.maptime;
		if (mb)
		{
			if (ldShPending) { ldShPending = false; mb.StartHealth = ldShOwn; }
			// no longer a miniboss: its own flags back (the death sound's after its scream has had time to play)
			if (noMorphSet) { noMorphSet = false; mb.bDONTMORPH = ownDontMorph; }
			if (roarSet) { roarSet = false; mb.bFULLVOLSEE = ownFullSee; deathFlagUntil = level.maptime + 3 * TICRATE; }
			let h = H();
			if (h && h.debug) LogFlags("at death");
		}
		// Died with lives to spare (a telefrag or forced damage skips BUDDHA): give the monster its own
		// BUDDHA back, or an Arch-vile raise would leave it unkillable (final review).
		if (mb) mb.bBUDDHA = ownBuddha;
		for (int i = 0; i < thr.Size(); i++)
		{
			let t = thr[i];
			if (!t) continue;
			t.TakeInventory("RSQMB_Thrall", 1);
			let h = H();
			if (h && thrState[i] == ST_ALIVE) h.FxBreak(self, t);
		}
	}

	// ---- FX: the particle fallback (fx.zs draws the sprites) --------------------------------------------------------------------
	static Vector3 Mid(Actor a) { return a.pos + (0, 0, a.height * 0.6); }

	static void P(Vector3 at, Color c, double size, int life, double alpha, Vector3 vel = (0, 0, 0), RSQMB_Handler h = null)
	{
		FSpawnParticleParams p;
		p.color1 = c;
		p.style = STYLE_Add;
		p.flags = SPF_FULLBRIGHT;
		p.lifetime = life;
		p.size = size;
		p.pos = at;
		p.vel = vel;
		p.startalpha = alpha;
		p.fadestep = -1;
		level.SpawnParticle(p);
		if (h && h.debug) h.fxParticles++;
	}

	static void Burst(Vector3 at, Color c, int n, double speed, double size)
	{
		for (int i = 0; i < n; i++)
		{
			double a = frandom[rsqmbfx](0, 360), v = frandom[rsqmbfx](-0.6, 0.9);
			Vector3 dir = (cos(a) * sqrt(1 - v * v), sin(a) * sqrt(1 - v * v), v);
			P(at, (i & 1) ? c : Color(255, 255, 255, 255), size, 18, 0.9, dir * speed * frandom[rsqmbfx](0.4, 1.0));
		}
	}

	void Shatter(Vector3 from, Vector3 to)
	{
		Vector3 d = level.Vec3Diff(from, to);
		int n = clamp(int(d.Length() / 48), 2, 24);
		for (int i = 0; i <= n; i++)
			P(from + d * (i / double(n)), col, 6, 14, 0.8, (frandom[rsqmbfx](-2, 2), frandom[rsqmbfx](-2, 2), frandom[rsqmbfx](0, 3)));
		Burst(from, col, 20, 4.0, 8);
	}

	private void FX(RSQMB_Handler h)
	{
		// Only what the local viewer can see from where they stand.
		let view = players[consoleplayer].mo;
		if (!view) return;
		Vector3 bm = Mid(mb);
		Vector3 dv = level.Vec3Diff(view.pos, bm);
		if (dv dot dv > h.fxRange2) return;
		int t = level.maptime;

		// Links: a dotted line from each living thrall, with beads running INTO the miniboss (who feeds whom, readable at a
		// glance). No life orbs and no ball over each thrall since the rework (the HUD's life bars and "TARGET!" replace them).
		for (int i = 0; i < thr.Size(); i++)
		{
			let th = thr[i];
			if (!th || thrState[i] != ST_ALIVE) continue;
			Vector3 a = Mid(th);
			Vector3 d = level.Vec3Diff(a, bm);
			double len = d.Length();
			if (len < 1) continue;
			if ((t + i) % 3 == 0)
			{
				int n = clamp(int(len / 48), 2, 28);
				for (int k = 1; k < n; k++) P(a + d * (k / double(n)), col, 4, 4, 0.55, (0, 0, 0), h);
			}
			for (int b = 0; b < 2; b++)
			{
				double s = ((t * 20.0 + b * len * 0.5) % len) / len;
				P(a + d * s, Color(255, 255, 255, 255), 9, 2, 0.9, (0, 0, 0), h);
			}
		}

		// Invulnerable: a gold ring turning the other way, at chest height.
		if (Invulnerable() && t % 2 == 0)
		{
			double rr = max(16.0, mb.radius) * 1.6;
			for (int i = 0; i < 12; i++)
			{
				double ang = -t * 6.0 + i * 30.0;
				P(mb.pos + (cos(ang) * rr, sin(ang) * rr, mb.height * 0.5), Color(255, 255, 224, 96), 6, 3, 0.9, (0, 0, 0), h);
			}
		}
	}
}
