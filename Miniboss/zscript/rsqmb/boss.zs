// ============================================================================
// RSQ_Miniboss -- one miniboss and its thralls (a Thinker: saved with the level).
//
// THE FIGHT (owner 2026-11-17, the original Minibosses!' rule back; the rules in fight.zs):
//   THRALLS   while thralls live they cut the Boss's damage: x (1 - 0.8 x living / the thralls it came with), in floating
//             point (the original's integer division made it all or nothing), on top of any factor it has (items.zs
//             RSQMB_Ward). All up: 20 %; none left: 100 %. The ring of FIRE round it is that shield (fx.zs).
//   POWERS    each thrall's Champions power is LOST with that thrall (StripPowers).
//   LIVES     it holds BUDDHA while it has a life to spare; the tic it sits at 1 hp it loses a life, refills to the most
//             health it has had (so Champions' and LegenDoom's own boosts count) and is invulnerable for rsqmb_invuln s
//             (the FIRE ring). On its last life BUDDHA goes back to what the monster had. NO THRALLS RISE.
//   NOTHING CHANGES MID-FIGHT (owner 2026-11-17): the Boss and its thralls keep their colour and their body from landing
//             to death (no tier-ups; fight.zs HoldTiers stops RSQ Monsters' tier changes on them).
//   THE CEILING (owner 2026-11-17: "the boss is too big for the ceiling in many maps"): its 1.25x is capped to the room
//             it stands in and the room ahead of it (FitCeiling), never under 1.0x.
//   A NEW BODY (an RSQ Monsters body swap from a save made before 2026-11-17): fight.zs Follow finds it, Rebody dresses it.
//
// THE ART is the original's, as actors (fx.zs): the marker over each thrall, the trail to it, the FIRE ring. FxStep below
// is the original controller's arithmetic, every tic.
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
	int    invulFrom;            // the tic it last lost a life
	// THE ARRIVAL'S CHARGE (owner 11-12 14:11: "the miniboss comes in and its bar fills up quickly, smoothly. during this
	// time, let's say all miniboss and thralls are invuln but not attacking. the miniboss bar takes 3 seconds to charge up"):
	// until chargeUntil the miniboss and its thralls are DORMANT (they do not act) and INVULNERABLE; their own flags are
	// kept and put back (ChargeEnd). The HUD's bar fills and its clock counts down over the same tics (bossbar.zs).
	int    chargeUntil, chargeLen;
	bool   chargeHeld;
	Array<Actor> chWho;
	Array<bool>  chDorm, chInv;
	// bossOnly (ARRIVAL AROUND YOU, arrival2.zs; design/BOSS_REWORK.md 2: "Only the Boss keeps a short invulnerable landing"):
	// the thralls already fight, only the Boss is held
	void ChargeStart(int tics, bool bossOnly = false)
	{
		if (chargeHeld || tics <= 0) return;
		chargeUntil = level.maptime + tics;
		chargeLen = tics;
		chargeHeld = true;
		chWho.Clear(); chDorm.Clear(); chInv.Clear();
		for (int i = -1; i < (bossOnly ? 0 : thr.Size()); i++)
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
	// RISEN AND BOOSTED FROM THE START (owner 2026-11-12 18:06): a LegenDoom legendary is dormant until half its health,
	// when LegenDoom's own script (LEGENDMON.acs LDMonsterInit) heals it full and gives it its stat boost -- and Champions'
	// Booster then boosts it too. Here each one is taken to just under half once, while it cannot be hurt and does not act,
	// so LegenDoom raises it the next tic by its own rules. Only with LegenDoom's Legendary Monsters on full (its own
	// LD_legendarymonsters 1: the setting that rises and heals); otherwise it is left as it is. Without LegenDoom: the
	// built-in LegenDoom Lite (ldlite.zs), which always rises at half (2026-11-23).
	Array<Actor> risen;
	void RiseOne(Actor a)
	{
		if (!a || a.health <= 2 || risen.Find(a) < risen.Size()) return;
		if (a.CountInv("LDLegendaryMonsterToken") <= 0) return;
		if (a.CountInv("LDLegendaryMonsterTransformed") > 0) { risen.Push(a); risenHp.Push(0); return; }
		let lm = CVar.FindCVar("LD_legendarymonsters");
		if (lm && lm.GetInt() != 1) return;   // no LegenDoom (no such cvar): the built-in LegenDoom Lite (ldlite.zs), which always rises at half
		risen.Push(a);
		// LegenDoom raises it once its health is at or under half of what LegenDoom gave it. Taken to 2 (it cannot be hurt
		// while the charge holds it), LegenDoom heals it the next tic; whatever it had above LegenDoom's number (Champions'
		// Red, our own boost) is given back once it has risen (RiseRestore).
		risenHp.Push(a.health);
		a.health = 2;   // 2, not 1: at 1 the miniboss's lives would read it as a life lost (rig run mbwatch2)
		let h = H();
		if (h && h.debug) Console.Printf("RSQMB rise: %s taken to %d for LegenDoom to raise it", a.GetClassName(), a.health);
	}
	Array<int> risenHp;
	bool RisePending(Actor a)
	{
		int i = risen.Find(a);
		return i < risen.Size() && i < risenHp.Size() && risenHp[i] > 0;
	}
	void RiseRestore()
	{
		for (int i = 0; i < risen.Size() && i < risenHp.Size(); i++)
		{
			let a = risen[i];
			if (!a || risenHp[i] <= 0 || a.CountInv("LDLegendaryMonsterTransformed") <= 0) continue;
			if (a.health > 0 && a.health < risenHp[i]) a.health = risenHp[i];
			risenHp[i] = 0;
		}
	}

	// A NEW BODY RISES TOO (2026-11-12, carry.zs): RSQ Monsters' tier change swaps a set-piece monster's body; the new one gets
	// its Champion back (carry.zs) and its legendary (fight.zs Follow), and rises here as at the arrival (RiseOne). It is held
	// INVULNERABLE until it has risen (it stands at 2 hp for a tic), then gets its share of health back: the share of the
	// most it had that the old body still had (the wound carried, RSQ Monsters' own rule), of the most the new body reached
	// (its legendary health, Champions' boost). Its target, which the rise clears (LegenDoom's A_ClearTarget), back after.
	const REBORN_WAIT = 105;       // at most this long (3 s) for LegenDoom
	Array<Actor> rbMon, rbTarget;
	Array<int> rbFrom, rbPeak;
	Array<double> rbFrac;
	Array<bool> rbOwnInv, rbLegend;
	Array<int> thrPeak;            // the most health each thrall has had (its health share at a swap)
	int ThrallPeak(int i)
	{
		int p = i < thrPeak.Size() ? thrPeak[i] : 0;
		let t = i < thr.Size() ? thr[i] : null;
		return t ? max(p, t.health) : p;
	}
	void Reborn(Actor a, double frac, bool legend)
	{
		if (!a || rbMon.Find(a) < rbMon.Size()) return;
		rbMon.Push(a); rbTarget.Push(a.target); rbFrom.Push(level.maptime); rbPeak.Push(a.health); rbFrac.Push(frac);
		rbOwnInv.Push(a.bINVULNERABLE); rbLegend.Push(legend);
		a.bINVULNERABLE = true;
	}
	private void RebornStep()
	{
		int now = level.maptime;
		let lm = CVar.FindCVar("LD_legendarymonsters");
		bool ldRises = RSQMB_Handler.Loaded("LDLegendaryMonsterToken") && (!lm || lm.GetInt() == 1);
		for (int k = rbMon.Size() - 1; k >= 0; k--)
		{
			let a = rbMon[k];
			bool gone = !a || a.health <= 0;
			int age = now - rbFrom[k];
			bool done = gone;
			if (!gone)
			{
				if (rbLegend[k]) { RiseOne(a); RiseRestore(); }
				if (!RisePending(a)) rbPeak[k] = max(rbPeak[k], a.health);
				bool risen = a.CountInv("LDLegendaryMonsterTransformed") > 0 && !RisePending(a);
				done = risen || age >= REBORN_WAIT || ((!rbLegend[k] || !ldRises) && age >= 4);
			}
			if (!done) continue;
			if (!gone)
			{
				// still held by the arrival's charge: ChargeEnd puts its own flag back
				if (chWho.Find(a) == chWho.Size()) a.bINVULNERABLE = rbOwnInv[k];
				int full = max(rbPeak[k], a.health);
				a.health = max(2, int(round(full * rbFrac[k])));
				if (a == mb) maxHP = max(maxHP, full);
				else { int ti = thr.Find(a); if (ti < thr.Size()) { while (thrPeak.Size() <= ti) thrPeak.Push(0); thrPeak[ti] = full; } }
				let tg = rbTarget[k];
				if (tg && tg.health > 0 && !a.target) { a.target = tg; a.LastHeard = tg; }
				let h = H();
				if (h && h.debug) Console.Printf("RSQMB reborn: %s %s after %d tics, %s, health %d of %d (share %.2f)", a == mb ? "the miniboss" : "a thrall",
					a.GetClassName(), age, a.CountInv("LDLegendaryMonsterTransformed") > 0 ? "risen" : (rbLegend[k] ? "NOT risen" : "not legendary"),
					a.health, full, rbFrac[k]);
			}
			rbMon.Delete(k); rbTarget.Delete(k); rbFrom.Delete(k); rbPeak.Delete(k); rbFrac.Delete(k); rbOwnInv.Delete(k); rbLegend.Delete(k);
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
	Color  col;                  // its ladder colour (the Boss bar, the room's glow)
	Color  fxCol;                // THE ORIGINAL'S minibosscolor: one random RGB, the stencil shade of every effect it has
	int    idx;
	bool   done;
	int    diedAt;               // the tic it died (Boss Kill Rewards counts a just-killed miniboss)
	bool   called;               // a Bossfight (called in, bossfight.zs): every miniboss since the classic pick was cut (2026-11-12); kept for old saves and the service's "tier"
	int    tier;                 // the Bossfight's tier, 0..4
	bool   big;                  // a BIG BOSS (bigboss.zs): an EX-tier monster called in by the full Big Boss bar
	int    bigHp;                // ...its life's health by time to kill (bigfix.zs BigLifeHP), 0 none
	bool   bigHpHeld;            // ...held to it once LegenDoom's rise was past (bigfix.zs BigTick)
	// THE ICONS BESIDE ITS BAR (owner 11-10, design/icons style B): drawn only by the old HUD stack, cut 2026-11-12 (hud.zs);
	// no longer read (ReadIcons cut 2026-11-16, NEW-MB-C); the fields kept because old saves serialize them
	int    ladder;               // RSQ Monsters' tier of the miniboss's body, 1..13 (its RSQMN_RosterService "tier"), 0 none
	Array<int> champIcons;       // its Champion powers, its own and inherited: 0..16 the types, 18..21 the mutations
	int    lifeLostAt;           // the tic it last lost a life (the room's red, the HUD's refill)
	int    wordState;            // the words shown (fight.zs WordsStep), -9 re-send
	int    glowSent, glowTic;    // the room's glow sent last (fight.zs RoomGlow)
	int    guardHitTic;          // the last blow it shrugged off while invulnerable (the HUD bar's GUARD shakes, bossbar.zs)
	double mbK;                  // the scale it stands at, 1.0 .. MB_SCALE (FitCeiling); 0 a save from before: MB_SCALE
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
	// GUARDED: a thrall stands (the FIRE ring is lit, its damage is cut)
	clearscope bool Guarded() const { return !done && Living() > 0; }
	// THE THRALLS' CUT (the original's DamageFactor = 1 - 0.8 x living / thralls, its integer division fixed): what a blow
	// keeps of itself, 0.2 with every thrall up, 1.0 with none
	clearscope double ThrallFactor() const
	{
		if (total <= 0) return 1.0;
		return clamp(1.0 - 0.8 * (Living() / double(total)), 0.2, 1.0);
	}
	// the damage it takes now, as a share (the service's "shield"): 0 invulnerable
	clearscope double TakeFactorData() const
	{
		if (Invulnerable()) return 0;
		return ThrallFactor() / max(1.0, toughness);
	}

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
		// ARRIVE RISEN (owner 2026-11-12 18:06): while the charge runs, every legendary of the encounter rises (RiseOne)
		if (chargeUntil > 0 && level.maptime < chargeUntil + 35) { RiseOne(mb); for (int i = 0; i < thr.Size(); i++) RiseOne(thr[i]); RiseRestore(); }
		if (ldShPending) LDHealthDone(h);
		if (rbMon.Size()) RebornStep();
		if (mb.health > maxHP && !RisePending(mb)) maxHP = mb.health;
		if (h) Flags(h.roarOn, h.noMorphOn, h.debug);
		if (h && level.maptime % 10 == idx % 10) col = h.ColourOf(mb, idx) | 0xFF000000;

		// A life lost: BUDDHA held it at 1 hp.
		if (lives > 1 && mb.health <= 1 && !RisePending(mb)) LoseLife(h);

		// Thralls: alive, dead, or gone (destroyed, gibbed away). Dead ones stay dead (no revive since the rework).
		while (thrPeak.Size() < thr.Size()) thrPeak.Push(0);
		for (int i = 0; i < thr.Size(); i++)
		{
			let t = thr[i];
			if (t && !t.bDestroyed && t.health > thrPeak[i] && !RisePending(t) && rbMon.Find(t) == rbMon.Size()) thrPeak[i] = t.health;
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

		// THE CEILING: every FIT_EVERY tics (owner 2026-11-17)
		if ((level.maptime + idx) % FIT_EVERY == 0) FitCeiling(h);

		// THE ORIGINAL'S ART: the links, the markers, the ring (fx.zs)
		FxStep(h);
	}

	private void LoseLife(RSQMB_Handler h)
	{
		lives--;
		// THE BIG BOSS FIX (bigfix.zs, design/BOSS_REWORK.md 9 items 2 and 4): a Big Boss's next life is the player's damage
		// per second now x rsqmb_big_ttk (60 s, owner 2026-11-23 03:58), and the act change a short beat (rsqmb_big_actinv, 2 s)
		if (big && h) { bigHp = h.BigLifeHP(self); maxHP = bigHp; }
		mb.health = max(maxHP, 1);
		double secs = h ? (big ? h.BigActSecs() : h.invulSecs) : 5.0;
		invulFrom = level.maptime;
		invulUntil = level.maptime + max(1, int(secs * TICRATE));
		lifeLostAt = level.maptime;
		glowSent = -1;
		if (lives <= 1) mb.bBUDDHA = ownBuddha;
		mb.A_StartSound("weapons/bfgx", CHAN_AUTO, 0, 1.0, 0.5);
		if (h) h.FxLifeLost(self);
		// (no tier-up: nothing in the fight changes colour, owner 2026-11-17; Tier Up Each Life is gone)
		if (h && h.debug) Console.Printf("RSQMB life lost: boss %d lives %d hp %d invuln %d tics", idx, lives, mb.health, invulUntil - level.maptime);
	}

	// ---- powers lost with their thrall (owner 06:42: "LOSE") -------------------------------------------------------------
	// Each power the miniboss inherited came from one thrall (powerFrom); that thrall killed, it goes: a token given is
	// taken back, a life it added is taken (never its last), Black's damage and the toughness come off. Returns the first
	// lost power's colour (for the log), -1 none.
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
			// its scale capped to the room it stands in (FitCeiling's rule)
			double ks = RSQMB_Handler.CapScale(a.height, a.ceilingz - a.floorz);
			a.A_SetScale(a.Scale.X * ks, a.Scale.Y * ks);
			a.A_SetSize(a.radius * ks, a.height * ks, false);
			mbK = ks;
			RSQMB_Handler.Aggressive(a);
			maxHP = max(1, a.health);
			for (int k = 0; k < powers.Size(); k++)
			{
				String n = powers[k];
				if (k < powerAdd.Size() && powerAdd[k] != 0 && (n == "Yellow" || n == "White" || n == "DarkGreen" || n == "Cyan" || n == "Titan")
					&& !RSQMB_Handler.Has(a, "champion_" .. n .. "Token"))
					RSQMB_Handler.Give(a, "champion_" .. n .. "Token");
			}
		}
		else if (role < thr.Size())
		{
			thr[role] = a;
			let tok = RSQMB_Thrall(a.GiveInventoryType("RSQMB_Thrall"));
			if (tok) tok.boss = self;
			a.A_SetScale(a.Scale.X * RSQMB_Handler.TH_SCALE, a.Scale.Y * RSQMB_Handler.TH_SCALE);
		}
		// boosted again (every miniboss is a called-in one since the classic pick was cut, 2026-11-12); Boss Effects Light: the
		// group's one light is the Boss's (bossfight.zs Boost)
		int rgb = h ? h.ColourOf(a, idx) : (int(col) & 0xFFFFFF);
		if (role < 0 || !RSQMB_Handler.FxLight())
			a.A_AttachLight('RSQMB_Boost', DynamicLight.PointLight, Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255),
				int(max(64, a.radius * 3)), 0, 0, (0, 0, a.Height * 0.6));
		a.bBRIGHT = true;
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

	// The miniboss is dead: the links break, the thralls are free monsters again. quiet: the fight called off or lost (the
	// links and the ring go without their burst)
	void Finish(bool quiet = false)
	{
		done = true;
		FxEnd(quiet);
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
		}
	}

	// ---- the one-shots' particle fallback (an IWAD sprite missing: fx.zs) ------------------------------------------------------
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

	// ---- THE ORIGINAL'S ART (Tartlman's Minibosses! minibosscontroller.txt; owner 2026-11-17) ----------------------------
	// The original's controller, every tic, on actors (fx.zs): each thrall's marker warped to it at zofs = its height, its
	// FX_TRAIL trail pieces at the boss + (thrall - boss) x j / FX_TRAIL plus half the boss's height (absolute offsets), the
	// marker and trail exploding when the thrall dies and set back to their Spawn loop while it lives (as the original, which
	// sets a piece back to its first Spawn frame whenever it is not on it), back again if it is raised. The ring: FX_RING
	// pieces at 1.5 x the boss's radius, turning FX_SPIN / (radius / 20) degrees a tic, lit while it is GUARDED (a thrall
	// stands) or invulnerable (the arrival's charge, a lost life), going out when neither is true.
	// Every piece is spawned whatever Effects says (the same thinkers on every machine); Effects off only hides them.
	// BOSS EFFECTS (rsqmb_bossfx, owner 2026-11-22: "i like the sprites and the lights but maybe i dont need so many of them"):
	// Light (the default) draws FX_TRAIL_LIGHT beads a link, each twice as far from the next (the link spans the same line),
	// and FX_RING_LIGHT flames in the ring; Full the original's FX_TRAIL / FX_RING. The same sprites, colours, styles and
	// motion either way. The counts are chosen when the pieces are made (fxN for the links, the ring's own size), so a change
	// of the setting takes at the next fight or ring. CHEAPER EVERY TIC, both settings, nothing seen differently: a link whose
	// thrall and Boss have not moved since the last tic is not warped again (its pieces are already there), and the Spawn
	// states the original sets each piece back to are found once, not every tic for every piece.
	const FX_TRAIL = 30;   // mbos_thralldensity's default (Full)
	const FX_TRAIL_LIGHT = 15;
	const FX_RING = 20;    // mbos_invulndensity's default (Full)
	const FX_RING_LIGHT = 12;
	const FX_SPIN = 3.0;   // mbos_invulnspinspeed's default
	Array<Actor>  fxMark;  // a thrall's marker (RSQMB_ThrallFx), null for one dead when they were made
	Array<Actor>  fxTrail; // thrall i's trail at i x TrailN() .. (RSQMB_ThrallTrailFx)
	Array<bool>   fxDead;  // its link has exploded (the original's thralldead)
	Array<Actor>  fxRing;  // the ring while lit (RSQMB_InvulnFx)
	Array<double> fxAng;
	double fxSpin;
	bool   fxMade, fxHidden;
	int    fxN;            // beads a link, chosen at FxMake (0: a save from before Boss Effects, made with FX_TRAIL)
	// where each link was last warped to (transient: after a load every link is warped again once)
	transient Array<double> fxLastX, fxLastY, fxLastZ, fxLastH;
	transient Vector3 fxLastMb;
	transient double fxLastMbH;
	transient State fxSpTrail, fxSpMark;

	int TrailN() const { return fxN > 0 ? fxN : FX_TRAIL; }

	static void FxShow(Actor f, bool hide) { if (f) f.bInvisible = hide; }

	private void FxMake(bool hide)
	{
		fxMade = true;
		if ((int(fxCol) & 0xFFFFFF) == 0) fxCol = RSQMB_Handler.RandomFxColour();   // a save from before: its colour now
		fxMark.Clear(); fxTrail.Clear(); fxDead.Clear();
		fxN = RSQMB_Handler.FxLight() ? FX_TRAIL_LIGHT : FX_TRAIL;
		fxLastX.Clear(); fxLastY.Clear(); fxLastZ.Clear(); fxLastH.Clear();
		int tn = TrailN();
		for (int i = 0; i < thr.Size(); i++)
		{
			let t = thr[i];
			bool live = t && !t.bDestroyed && thrState[i] == ST_ALIVE && t.health > 0;
			Actor m = live ? Actor.Spawn("RSQMB_ThrallFx", t.pos + (0, 0, t.height), NO_REPLACE) : null;
			if (m) { m.SetShade(fxCol); FxShow(m, hide); }
			fxMark.Push(m);
			fxDead.Push(!live);
			for (int j = 0; j < tn; j++)
			{
				Actor f = live ? Actor.Spawn("RSQMB_ThrallTrailFx", mb.pos + (0, 0, mb.height / 2), NO_REPLACE) : null;
				if (f) { f.SetShade(fxCol); FxShow(f, hide); }
				fxTrail.Push(f);
			}
		}
		fxHidden = hide;
	}

	private void FxLinkState(int i, StateLabel lb)
	{
		let m = fxMark[i];
		if (m) m.SetStateLabel(lb);
		int tn = TrailN();
		for (int j = 0; j < tn; j++)
		{
			let f = fxTrail[i * tn + j];
			if (f) f.SetStateLabel(lb);
		}
	}

	// the original sets each piece back to its Spawn state whenever it is not on Spawn's first frame (sp: that class's
	// Spawn state, found once)
	static void FxRespawn(Actor f, State sp)
	{
		if (f && sp && f.CurState != sp) f.SetState(sp);
	}

	private void FxRingOn(bool hide)
	{
		double r = max(1.0, mb.radius);
		fxSpin = FX_SPIN / (r / 20.0);
		fxRing.Clear(); fxAng.Clear();
		int rn = RSQMB_Handler.FxLight() ? FX_RING_LIGHT : FX_RING;
		for (int k = 0; k < rn; k++)
		{
			double ang = 360.0 / rn * k;
			Actor f = Actor.Spawn("RSQMB_InvulnFx", mb.pos + (cos(ang) * mb.radius * 1.5, sin(ang) * mb.radius * 1.5, 0), NO_REPLACE);
			if (f) { f.SetShade(fxCol); FxShow(f, hide); }
			fxRing.Push(f);
			fxAng.Push(ang);
		}
	}

	private void FxRingOff()
	{
		for (int k = 0; k < fxRing.Size(); k++) if (fxRing[k]) fxRing[k].SetStateLabel("Explode");
		fxRing.Clear(); fxAng.Clear();
	}

	private void FxStep(RSQMB_Handler h)
	{
		bool hide = h && !h.fxOn;
		if (!fxMade) FxMake(hide);
		if (hide != fxHidden)
		{
			fxHidden = hide;
			for (int i = 0; i < fxMark.Size(); i++) FxShow(fxMark[i], hide);
			for (int i = 0; i < fxTrail.Size(); i++) FxShow(fxTrail[i], hide);
			for (int i = 0; i < fxRing.Size(); i++) FxShow(fxRing[i], hide);
		}
		// THE LINKS (the original's thrall loop, in its order)
		int tn = TrailN();
		bool mbMoved = mb.pos != fxLastMb || mb.height != fxLastMbH;
		fxLastMb = mb.pos; fxLastMbH = mb.height;
		while (fxLastX.Size() < fxMark.Size()) { fxLastX.Push(1e9); fxLastY.Push(1e9); fxLastZ.Push(1e9); fxLastH.Push(-1); }
		for (int i = 0; i < thr.Size() && i < fxMark.Size(); i++)
		{
			if (fxTrail.Size() < (i + 1) * tn) break;
			let t = thr[i];
			if (!t || t.bDestroyed)
			{
				// gone with no body to follow (removed, gibbed away): its link breaks where it last stood (the original left
				// a destroyed thrall's link looping there)
				if (!fxDead[i]) { fxDead[i] = true; FxLinkState(i, "Explode"); }
				continue;
			}
			if (fxDead[i] && t.health > 0) fxDead[i] = false;   // raised (an Arch-vile)
			let m = fxMark[i];
			// warped only when the thrall or the Boss moved (or grew) since the last tic: else every piece is where it was
			bool tMoved = t.pos.x != fxLastX[i] || t.pos.y != fxLastY[i] || t.pos.z != fxLastZ[i] || t.height != fxLastH[i];
			if (tMoved || mbMoved)
			{
				fxLastX[i] = t.pos.x; fxLastY[i] = t.pos.y; fxLastZ[i] = t.pos.z; fxLastH[i] = t.height;
				if (m) m.Warp(t, 0, 0, t.height, 0, WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE);
				Vector3 d = (t.pos - mb.pos) / double(tn);
				for (int j = 0; j < tn; j++)
				{
					let f = fxTrail[i * tn + j];
					if (f) f.Warp(mb, d.x * j, d.y * j, d.z * j + mb.height / 2, 0, WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE | WARPF_ABSOLUTEOFFSET);
				}
			}
			if (!fxDead[i] && t.health <= 0) { fxDead[i] = true; FxLinkState(i, "Explode"); }
			else if (!fxDead[i])
			{
				for (int j = 0; j < tn; j++)
				{
					let f = fxTrail[i * tn + j];
					if (f && !fxSpTrail) fxSpTrail = f.FindState("Spawn");
					FxRespawn(f, fxSpTrail);
				}
				if (m && !fxSpMark) fxSpMark = m.FindState("Spawn");
				FxRespawn(m, fxSpMark);
			}
		}
		// THE RING: the shield while a thrall stands, and the invulnerability (the charge, a lost life)
		bool ring = Living() > 0 || Invulnerable();
		if (ring && fxRing.Size() == 0) FxRingOn(hide);
		else if (!ring && fxRing.Size() > 0) FxRingOff();
		for (int k = 0; k < fxRing.Size() && k < fxAng.Size(); k++)
		{
			let f = fxRing[k];
			if (!f) continue;
			f.Warp(mb, cos(fxAng[k]) * mb.radius * 1.5, sin(fxAng[k]) * mb.radius * 1.5, 0, 0, WARPF_ABSOLUTEOFFSET | WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE);
			fxAng[k] += fxSpin;
		}
	}

	// the fight is over (Finish): each living thrall's link explodes where it is (the original's explodedestroy, imp/shotx
	// and all) and is gone; a dead one's spent pieces go; the ring goes out. quiet (the fight lost or called off): all of
	// it removed at once.
	private void FxEnd(bool quiet)
	{
		for (int i = 0; i < fxMark.Size(); i++)
		{
			bool burst = !quiet && i < fxDead.Size() && !fxDead[i];
			int tn = TrailN();
			for (int j = -1; j < tn; j++)
			{
				int n = i * tn + j;
				Actor f = j < 0 ? fxMark[i] : (n < fxTrail.Size() ? fxTrail[n] : null);
				if (!f) continue;
				if (burst) f.SetStateLabel("ExplodeDestroy");
				else if (quiet || f.tics == -1) f.Destroy();   // a spent explosion (TNT1 held) or the fight called off
			}
		}
		fxMark.Clear(); fxTrail.Clear(); fxDead.Clear();
		if (quiet) { for (int k = 0; k < fxRing.Size(); k++) if (fxRing[k]) fxRing[k].Destroy(); fxRing.Clear(); fxAng.Clear(); }
		else FxRingOff();
	}

	// ---- THE CEILING (owner 2026-11-17: "the boss is too big for the ceiling in many maps") ---------------------------------
	// Its 1.25x (MB_SCALE: sprite, radius and height) is capped so its height fits under the ceiling with MB_MARGIN units to
	// spare, never under 1.0x (RSQMB_Handler.CapScale): at the landing (bossfight.zs Land) and here, every FIT_EVERY tics, by
	// the room where it stands and the room one step ahead of where it walks (its movedir), so it shrinks before a low
	// passage and can follow you in, and grows back (only where the bigger box fits) when it is out again. Its 1.25x speed
	// and its other boosts are not touched.
	const FIT_EVERY = 4;
	private void FitCeiling(RSQMB_Handler h)
	{
		let a = mb;
		if (!a || a.health <= 0) return;
		double k = mbK > 0 ? mbK : RSQMB_Handler.MB_SCALE;
		double h1 = a.height / k;                  // its height at 1.0x
		if (h1 <= 0) return;
		double room = a.ceilingz - a.floorz;
		if (a.movedir < 8)
		{
			double ang = a.movedir * 45.0;
			double ahead = a.radius + max(8.0, a.Speed) * 2;
			FCheckPosition tm;
			if (a.CheckPosition(a.pos.xy + (cos(ang), sin(ang)) * ahead, false, tm)) room = min(room, tm.ceilingz - tm.floorz);
		}
		double want = RSQMB_Handler.CapScale(h1, room);
		if (abs(want - k) < 0.01) return;
		double f = want / k;
		// shrinking always fits; growing only where the bigger box does (A_SetSize's own test), else it waits
		if (!a.A_SetSize(a.radius * f, a.height * f, want > k)) return;
		a.A_SetScale(a.Scale.X * f, a.Scale.Y * f);
		mbK = want;
		if (h && h.debug) Console.Printf("RSQMB ceiling: boss %d %s x%.2f -> x%.2f (room %.0f, height %.0f)", idx, a.GetClassName(), k, want, room, a.height);
	}
}
