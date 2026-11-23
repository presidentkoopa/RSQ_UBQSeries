// ============================================================================
// RSQ_Miniboss -- THE TELEGRAPHED ATTACK AND BREAK! (design/BOSS_REWORK.md 3, House of the Dead; section 9 items 1 and 3;
// the Big Bosses' own attacks from design/BIG_BOSS.md 11-15). Code only, not run (2026-11-23, owner: hold rig checks
// until we talk).
//
//   THE TELL        every N seconds while its fight runs, every Boss and Big Boss winds up its big attack: it roars (its
//                   own sight sound, heard map-wide, and the Arch-vile's charge), the room's light goes red (RSQ Glow In
//                   The Dark's map glow through fight.zs RoomGlow, a red light on the Boss, a short red fade on the view
//                   of each player near it; all of it ends with the wind-up, nothing permanent), it stands in its attack
//                   pose facing you, and WEAK POINTS appear on its body: 2 on a Boss, 3 on a Big Boss, with our
//                   crosshairs assembling on them (below). The wind-up lasts rsqmb_tell_windup (3 s).
//   N               owner 2026-11-22 23:2x (section 7): "20 s at low rank, down to 10 s at high rank". Rank is Phase C and
//                   not built: until it is, RSQ Monsters' World Tier stands in for it, read the way the fight reads it
//                   (bossfight.zs WorldTierNow: rsq_mon_worldtier by name, 1 without it): tier 1 (the lowest) ->
//                   rsqmb_tell_slow (20 s), tier 13 (White) -> rsqmb_tell_fast (10 s), in a straight line between.
//                   Counted from the end of the last wind-up or BREAK!; the first one N after the arrival's charge.
//   ACTS            every life after the first (an act: boss.zs LoseLife) winds up sooner (N x (1 - rsqmb_tell_act_sooner
//                   x (act - 1)), at least 0.3 N) and its attack hits harder (x (1 + rsqmb_tell_act_harder x (act - 1))).
//                   A life lost during a wind-up cancels it (no attack); during BREAK! ends the stagger.
//   WEAK POINTS     RSQMB_WeakPoint: small shootable actors placed on the Boss's body every tic (on its front, spread
//                   over its width and height, the layouts below), each a glowing core under its crosshair, with
//                   rsqmb_wp_health (Boss) / rsqmb_wp_health_big (Big Boss) health: only a player's attack hurts them
//                   (a monster's missile passes through). Not solid, radius 8-18: they cover only their own spot.
//   BREAK!          every weak point broken before the wind-up ends: the attack is CANCELLED, the Boss STAGGERS (its Pain
//                   state if it has one, held there; otherwise its frame held: it does not move or attack) and takes x
//                   rsqmb_break_mult (2) damage for rsqmb_break_secs (3 s); a Big Boss x rsqmb_break_mult_big (3) for
//                   rsqmb_break_secs_big (4 s) (owner 2026-11-23 03:58, decided: "Big Boss BREAK! is x3 damage for 4 s";
//                   section 9 item 3). The multiplier is on top of the thralls' cut (items.zs RSQMB_Ward). "BREAK!" is
//                   RSQ VisualRewards' world word over it (RSQVR_Service "worldword", by name); without VisualRewards a
//                   BIGFONT print on each player's view and Miniboss's own burst.
//   MISS            the wind-up ends with a weak point standing: the attack fires. Every big attack is something visible
//                   to dodge (the no-hitscan rule): projectile fans, ground waves with gaps, slow travelling beams,
//                   seekers, crawling blobs. Damage rsqmb_tell_dmg x (1 + rsqmb_tell_dmg_tier x (world tier - 1)) x the
//                   act's x, a Big Boss x rsqmb_tell_dmg_big. They hurt players only (the Boss and its thralls are
//                   passed through).
//   WHICH ATTACK    a Boss: by its kind (rsqmb_tell_attack 0 Auto): a gunner (a zombie, shotgunner, chaingunner, rifle,
//                   sergeant, commando, Spider Mastermind) a SLOW TRAVELLING BEAM (its gun's shot, made big and slow); a
//                   monster with no missile attack, or a heavy one (radius 40+ or 1000+ spawn health), a GROUND SHOCKWAVE
//                   RING with gaps; a flyer, and every other, a PROJECTILE FAN. 1 / 2 / 3 force fan / ring / beam.
//                   A Big Boss (design/BIG_BOSS.md 11-15, its personality; any other EX boss by its kind as a Boss):
//                     Obsidian Tyrant (RS_BlackCybieEX)   head, both forge arms; the hammer slam: two shockwave rings
//                                                         and five pentagram lines of fire cracking out
//                     Imp Warlord (RS_BlackImpEX)         head and the two CHARGE ORBs in his hands; the Kamehameha: a
//                                                         slow travelling beam (two from act 3, his FINAL FORM)
//                     Black Knight (RS_BlackRevenantEX)   helmet, sword arm, shield arm; slow soul seekers and a line
//                                                         of fire along the ground at you
//                     the thing from the bog (RS_BlackFatsoEX) belly, head, shoulder; the burp: crawling blobs that leave
//                                                         acid puddles. BREAK! makes it BACKFIRE: it chokes on its own acid
//                                                         (5% of its life's health)
//                     Benellus (RS_WhiteSGEX)             his face, and two GHOST GUNs beside YOU (turn your head and
//                                                         shoot left and right, a VR move); missed, both fire a slow
//                                                         spread of buckshot at you
//   THE CROSSHAIRS  "the SEGA crosshair fly-in" is RSQ SlowMo's (rsqsm/plate.zs Crosshair): drawn only for DOWN's own
//                   targets by SlowMo's plate (its model quads, its target list), with no request another mod can drive
//                   for a world spot. So the same thing is built here, with the same art: three copies of the reticle
//                   fly in from 6 sizes out, 120 degrees apart, turning as they close over 9 tics, then SlowMo's own 17
//                   baked assembly frames play (copied into sprites/rsqmb/MBX1-3 by tools/gen_weakpt.py: icons 01, 05,
//                   09, the ring ones). Sprites (they face every eye), Shaded gold. Photosensitive Mode (RSQ
//                   Accessibility): no fly-in, no flash ring (SlowMo's rule).
//   THRALLS         still cut the Boss's damage in Boss fights (fight.zs, untouched). Lives stay as acts.
//   SECTION 9.1     in a Big Boss fight (no thralls; also any fight with none), every weak point broken drops a health
//                   and armour burst (rsqmb_wp_drop_health / _armor), a full BREAK! a bigger one (rsqmb_break_drop_health /
//                   _armor): bits thrown out on the floor (RSQMB_HealthBit / RSQMB_ArmorBit) that you go and take.
//   THE MELEE FINISHERS (section 4) are finisher.zs; the thralls' stagger is kept here (ThrallStep).
// Everything of other mods is asked BY NAME (RSQVR_Service, RSQGD_Service through fight.zs, RS_ScoreService). Nothing in
// another mod is edited.
// ============================================================================

class RSQMB_Tele : Thinker
{
	const STAT_TELE = 124;      // after the actors (STAT_DEFAULT 100) have moved: the weak points sit where the Boss is now
	enum EKind { TK_FAN = 1, TK_RING, TK_BEAM }
	enum EPers { BB_NONE, BB_TYRANT, BB_WARLORD, BB_KNIGHT, BB_BOG, BB_BENELLUS }
	const RGB_TELL = 0xFF1810;  // the room's red
	const RGB_WP = 0xFF5020;    // a weak point's core
	const RGB_XH = 0xFFD030;    // its crosshair: TARGET!'s gold (fight.zs RGB_TARGET)
	const FLY_TICS = 9;         // SlowMo's fly-in (plate.zs FLY_TICS / FLY_OUT / ASM_LAST)
	const FLY_OUT = 6.0;
	const ASM_LAST = 16;

	RSQMB_Boss b;
	int  kind, pers;
	bool kindSet;
	int  act;                   // 1: its first life
	int  lostSeen;              // b.lifeLostAt last seen (an act change)
	int  nextAt;                // the next wind-up's tic (0: not scheduled)
	int  windAt, windLen;       // the wind-up on (0: none)
	State poseSt;               // the pose it holds while it winds up (its Missile state, entered without its action)
	Array<RSQMB_WeakPoint> wps;
	int  brkUntil;              // BREAK!: staggered, taking brkMult, until this tic
	double brkMult;
	bool brkFinished;           // its melee finisher was paid in this BREAK! (finisher.zs)
	int  brkCount, fired;
	double gunAng;              // Benellus: the way you faced when his ghost guns came
	// held still (the wind-up's pose, a stagger)
	Array<Actor> pinA;
	Array<int> pinUntil;
	Array<bool> pinShake;
	// THE THRALLS' STAGGER (section 4; my rule, README): staggered thralls, until when; the low-health stagger is once each
	Array<Actor> stA;
	Array<int> stUntil;
	Array<Actor> lowDone;
	Array<Actor> finDone;       // thralls whose finisher was paid (finisher.zs)

	static RSQMB_Tele Make(RSQMB_Boss b)
	{
		let t = RSQMB_Tele(new("RSQMB_Tele"));
		t.ChangeStatNum(STAT_TELE);
		t.b = b;
		t.act = 1;
		t.lostSeen = b.lifeLostAt;
		b.tele = t;
		return t;
	}

	override void Tick()
	{
		if (level.isFrozen()) return;
		let h = RSQMB_Handler.Get();
		if (!b || b.done || !b.mb || b.mb.health <= 0) { End(h); return; }
		Step(h);
	}

	// ---- the rules -------------------------------------------------------------------------------------------------
	static clearscope double CF(Name n, double d) { return RSQMB_Handler.CF(n, d); }
	static clearscope int CI(Name n, int d) { return RSQMB_Handler.CI(n, d); }
	bool Big() const { return b && b.big; }
	int WorldTier() { return clamp(RSQMB_Handler.WorldTierNow(), 1, 13); }

	// N, in tics (the header)
	int Interval()
	{
		double sSlow = clamp(CF('rsqmb_tell_slow', 20.0), 3.0, 120.0);
		double sFast = clamp(CF('rsqmb_tell_fast', 10.0), 3.0, 120.0);
		double k = RSQMB_Handler.RankFrac();   // rank.zs: Rank 0..100 (the World Tier 1..13 with Rank off)
		double s = sSlow + (sFast - sSlow) * k;
		s *= max(0.3, 1.0 - clamp(CF('rsqmb_tell_act_sooner', 0.15), 0.0, 0.5) * (act - 1));
		return max(3 * TICRATE, int(s * TICRATE));
	}

	// one hit of the big attack (the header)
	int Damage()
	{
		double d = clamp(CF('rsqmb_tell_dmg', 15.0), 1.0, 200.0);
		d *= 1.0 + clamp(CF('rsqmb_tell_dmg_tier', 0.06), 0.0, 1.0) * (WorldTier() - 1);
		d *= 1.0 + clamp(CF('rsqmb_tell_act_harder', 0.25), 0.0, 2.0) * (act - 1);
		if (Big()) d *= clamp(CF('rsqmb_tell_dmg_big', 1.5), 0.5, 5.0);
		return max(1, int(round(d)));
	}

	// the player the fight is with: the Boss's own target if it is one, else the nearest
	PlayerPawn Victim()
	{
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

	// ---- which attack (the header) ----------------------------------------------------------------------------------------
	void PickKind()
	{
		kindSet = true;
		let mb = b.mb;
		String n = mb.GetClassName();
		if (n ~== "RS_BlackCybieEX") pers = BB_TYRANT;
		else if (n ~== "RS_BlackImpEX") pers = BB_WARLORD;
		else if (n ~== "RS_BlackRevenantEX") pers = BB_KNIGHT;
		else if (n ~== "RS_BlackFatsoEX") pers = BB_BOG;
		else if (n ~== "RS_WhiteSGEX") pers = BB_BENELLUS;
		int force = CI('rsqmb_tell_attack', 0);
		if (force >= 1 && force <= 3) { kind = force; return; }
		String l = n.MakeLower();
		static const String GUNNERS[] = { "zombie", "shotgun", "chaingun", "cguy", "sguy", "gunner", "rifle", "sergeant",
			"commando", "mastermind", "marine", "pistol", "trooper" };
		bool gunner = false;
		for (int i = 0; i < GUNNERS.Size(); i++) if (l.IndexOf(GUNNERS[i]) >= 0) { gunner = true; break; }
		if (gunner) kind = TK_BEAM;
		else if (!mb.MissileState || mb.radius >= 40 * (b.mbK > 0 ? b.mbK : 1.0) || mb.SpawnHealth() >= 1000) kind = mb.bFLOAT ? TK_FAN : TK_RING;
		else kind = TK_FAN;
	}

	// ---- every tic -----------------------------------------------------------------------------------------------------
	void Step(RSQMB_Handler h)
	{
		int now = level.maptime;
		let mb = b.mb;
		if (!kindSet) PickKind();
		PinStep(now);
		// AN ACT CHANGE (a life lost: boss.zs LoseLife stamps lifeLostAt)
		if (b.lifeLostAt != lostSeen)
		{
			lostSeen = b.lifeLostAt;
			act++;
			if (windAt) Cancel(h, "a life lost: the act changes");
			if (brkUntil > now) BreakEnd(h);
			if (penta) PentaDone(h, true);
			GuardEnd(h, "a life lost: the act changes");
			nextAt = 0;
		}
		ThrallStep(h, now);
		PentaStep(h, now);          // bigacts.zs: Supersmith's pentagrams
		if (brkUntil > 0 && now >= brkUntil) { BreakEnd(h); GuardStart(h, Victim()); }   // bigacts.zs: GUARD after EXPOSED!
		if (GuardStep(h, now)) return;        // bigacts.zs: GUARD holds the next wind-up back
		if (!RSQMB_Handler.TeleOn()) { if (windAt) Cancel(h, "switched off"); nextAt = 0; return; }
		// invulnerable: the arrival's charge or a lost life's beat. The clock starts when it can be fought.
		if (b.Invulnerable()) { if (windAt) Cancel(h, "invulnerable"); nextAt = 0; return; }
		if (windAt) { WindStep(h, now); return; }
		if (brkUntil > now) return;
		if (nextAt == 0) { nextAt = now + Interval(); return; }
		if (now < nextAt) return;
		// it winds up only where you can see it, within reach of a fight (else a second later)
		let p = Victim();
		if (!p || mb.Distance3D(p) > 3072 || !mb.CheckSight(p, SF_IGNOREVISIBILITY)) { nextAt = now + TICRATE; return; }
		WindStart(h, p, now);
	}

	// ---- the wind-up ----------------------------------------------------------------------------------------------------
	void WindStart(RSQMB_Handler h, PlayerPawn p, int now)
	{
		let mb = b.mb;
		windAt = now;
		windLen = int(clamp(CF('rsqmb_tell_windup', 3.0), 1.0, 8.0) * TICRATE);
		// the roar: its own sight sound across the map, and the Arch-vile's charge
		mb.A_StartSound(mb.SeeSound, CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
		mb.A_StartSound("vile/start", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		// the room goes red: fight.zs RoomGlow (RSQ Glow In The Dark) while windAt is set; its own red light; a short red
		// fade on the view of each player near it (dimmed with Photosensitive Mode)
		if (CI('rsqmb_tell_red', 1) != 0)
		{
			RedLight(true);
			double al = RSQMB_A11y.Photo() ? 0.12 : 0.25;
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (!playeringame[i] || !players[i].mo) continue;
				let q = players[i].mo;
				if (q.Distance3D(mb) < 2048) q.A_SetBlend(Color(255, 255, 24, 16), al, 24);
			}
		}
		// the pose: its attack state, without its action (it does not shoot), held
		poseSt = mb.MissileState ? mb.MissileState : mb.CurState;
		if (mb.MissileState) mb.SetState(mb.MissileState, true);
		if (!b.mb) return;
		Pin(mb, now + windLen + 2, false, false);
		gunAng = p.angle;
		SupersmithWind(h);          // bigacts.zs
		MakeWeakPoints(h, p);
		SummonStart(h, p);          // bigacts.zs: the Big Boss's summons during EXPOSED!
		if (h && h.debug) Console.Printf("RSQMB tell t%d: boss %d %s winds up (act %d, %d weak points of %d hp, %d tics; attack %s; next N %.1f s at world tier %d)",
			now, b.idx, mb.GetClassName(), act, wps.Size(), WpHealth(), windLen, AttackName(), Interval() / double(TICRATE), WorldTier());
	}

	String AttackName()
	{
		static const String P[] = { "", "Tyrant's hammer slam", "Warlord's Kamehameha", "Knight's seekers and fire line", "the bog's burp", "Benellus' ghost guns" };
		if (pers != BB_NONE && Big()) return P[pers];
		return kind == TK_RING ? "shockwave ring" : (kind == TK_BEAM ? "travelling beam" : "projectile fan");
	}

	int WpHealth() { return max(1, Big() ? CI('rsqmb_wp_health_big', 200) : CI('rsqmb_wp_health', 150)); }

	// THE LAYOUTS: (across its width as a share of its radius, up its height as a share of it); on its front
	void MakeWeakPoints(RSQMB_Handler h, PlayerPawn p)
	{
		Array<double> sx, sy;
		Array<bool> onP;
		bool big = Big();
		int bp = big ? pers : BB_NONE;
		switch (bp)
		{
		case BB_TYRANT:   sx.Push(0); sy.Push(0.86); sx.Push(-0.8); sy.Push(0.55); sx.Push(0.8); sy.Push(0.62); break;     // head, both forge arms
		case BB_WARLORD:  sx.Push(0); sy.Push(0.9); sx.Push(-0.85); sy.Push(0.55); sx.Push(0.85); sy.Push(0.55); break;    // head, the two charge orbs
		case BB_KNIGHT:   sx.Push(0); sy.Push(0.92); sx.Push(0.75); sy.Push(0.6); sx.Push(-0.75); sy.Push(0.52); break;    // helmet, sword arm, shield arm
		case BB_BOG:      sx.Push(0); sy.Push(0.42); sx.Push(0); sy.Push(0.86); sx.Push(0.7); sy.Push(0.72); break;        // belly, head, shoulder
		case BB_BENELLUS: sx.Push(0); sy.Push(0.8); sx.Push(-1); sy.Push(0); sx.Push(1); sy.Push(0);                // his face; the ghost guns beside you
			if (act >= 3) { sx.Push(-1); sy.Push(-1); sx.Push(1); sy.Push(-1); }                                       // ANGRIER: two more, behind you (bigacts.zs)
			break;
		default:
			if (big) { sx.Push(0); sy.Push(0.88); sx.Push(-0.6); sy.Push(0.6); sx.Push(0.6); sy.Push(0.38); }
			else { sx.Push(-0.55); sy.Push(0.72); sx.Push(0.55); sy.Push(0.45); }
		}
		let mb = b.mb;
		double r = clamp(mb.radius * 0.3, 8.0, 18.0);
		int hp = WpHealth();
		for (int i = 0; i < sx.Size(); i++)
		{
			bool gun = bp == BB_BENELLUS && i > 0;
			let w = RSQMB_WeakPoint(Actor.Spawn("RSQMB_WeakPoint", mb.pos, NO_REPLACE));
			if (!w) continue;
			w.tele = self;
			w.slot = i;
			w.side = sx[i]; w.up = sy[i];
			w.onPlayer = gun;
			w.back = gun && sy[i] < 0;
			double rr = r * ((bp == BB_WARLORD && i > 0) || (bp == BB_BOG && i == 0) ? 1.35 : 1.0);
			if (gun) rr = 14;
			w.A_SetSize(rr, rr * 2, false);
			w.health = hp;
			w.StartHealth = hp;
			w.born = level.maptime;
			w.icon = i % 3;
			w.Dress(gun, RSQMB_Handler.FxLight());
			wps.Push(w);
			Place(w, p);
			w.ClearInterpolation();
		}
	}

	// a weak point to its spot this tic
	void Place(RSQMB_WeakPoint w, PlayerPawn p)
	{
		if (!w || w.broken) return;
		let mb = b.mb;
		Vector3 at;
		if (w.onPlayer && p)
		{
			// a ghost gun: 80 units to that side of you, a little ahead, at your chest, turned with the way you faced
			double a = gunAng;
			Vector2 fw = (cos(a), sin(a)), rt = (sin(a), -cos(a));
			Vector2 xy = w.back ? p.pos.xy + rt * (70 * w.side) - fw * 70 : p.pos.xy + rt * (80 * w.side) + fw * 24;
			at = (xy, p.pos.z + p.player.viewheight - 16 - w.height / 2);
		}
		else
		{
			double a = mb.angle;
			Vector2 fw = (cos(a), sin(a)), rt = (sin(a), -cos(a));
			Vector2 xy = mb.pos.xy + fw * (mb.radius * 0.95) + rt * (w.side * mb.radius);
			at = (xy, mb.pos.z + mb.height * w.up - w.height / 2);
		}
		w.SetOrigin(at, true);
		Crosshair(w, p);
	}

	// THE CROSSHAIR (the header: SlowMo's fly-in and its assembly frames, built here)
	void Crosshair(RSQMB_WeakPoint w, PlayerPawn p)
	{
		Vector3 ctr = w.pos + (0, 0, w.height / 2);
		Vector3 eye = p ? p.pos + (0, 0, p.player.viewheight) : ctr + (64, 0, 0);
		Vector3 to = eye - ctr;
		double dl = max(1.0, to.Length());
		Vector3 dir = to / dl;
		Vector3 c = ctr + dir * (w.radius + 2);       // just in front of it, as you see it
		double sz = w.radius * 4.0;                   // the reticle's size in the world (it is ~70 of the frame's 128 px)
		double sc = sz / 70.0;
		bool photo = RSQMB_A11y.Photo();
		int age = level.maptime - w.born;
		w.mark = w.Need(w.mark);
		w.mark.A_SetScale(sc, sc);
		if (!photo && age < FLY_TICS)
		{
			double u01 = age / double(FLY_TICS), ease = 1.0 - (1.0 - u01) * (1.0 - u01);
			double far = sz * FLY_OUT * (1.0 - ease);
			// the plane facing the eye
			Vector3 rt = (dir.y, -dir.x, 0);
			if (rt.Length() < 0.001) rt = (1, 0, 0);
			rt = rt.Unit();
			Vector3 up = (rt.y * dir.z - rt.z * dir.y, rt.z * dir.x - rt.x * dir.z, rt.x * dir.y - rt.y * dir.x);
			for (int k = 0; k < 3; k++)
			{
				double a = 90.0 + 120.0 * k + 120.0 * (1.0 - ease);
				Vector3 q = c + rt * (cos(a) * far) + up * (sin(a) * far);
				w.fly[k] = w.Need(w.fly[k]);
				let f = w.fly[k];
				f.SetOrigin(q, true);
				f.frame = ASM_LAST;
				f.A_SetScale(sc * 0.6, sc * 0.6);
				f.alpha = 0.35 + 0.5 * ease;
				f.bInvisible = false;
			}
			w.mark.bInvisible = true;
			w.mark.SetOrigin(c, true);
			return;
		}
		for (int k = 0; k < 3; k++) if (w.fly[k]) { w.fly[k].Destroy(); w.fly[k] = null; }
		int f = min(ASM_LAST, max(0, age - (photo ? 0 : FLY_TICS)));
		if (photo && f >= 11) f = ASM_LAST;     // Photosensitive Mode: no flash ring
		w.mark.frame = f;
		w.mark.alpha = 1.0;
		w.mark.bInvisible = false;
		w.mark.SetOrigin(c, true);
	}

	void WindStep(RSQMB_Handler h, int now)
	{
		let mb = b.mb;
		let p = Victim();
		// facing you (12 degrees a tic), in its pose
		if (p) mb.angle += clamp(Actor.deltaangle(mb.angle, mb.AngleTo(p)), -12.0, 12.0);
		if (poseSt && mb.MissileState && !Actor.InStateSequence(mb.CurState, mb.MissileState)) mb.SetState(poseSt, true);
		if (!b.mb) return;
		if ((now - windAt) % 4 == 0 && CI('rsqmb_tell_red', 1) != 0) RedLight(true);
		int left = 0;
		for (int i = 0; i < wps.Size(); i++)
		{
			let w = wps[i];
			if (!w || w.broken || w.health <= 0) continue;
			left++;
			Place(w, p);
		}
		if (wps.Size() > 0 && left == 0) { DoBreak(h, p); return; }
		if (now - windAt >= windLen) Fire(h, p);
	}

	// a weak point broken (RSQMB_WeakPoint.Die)
	void WeakBroken(RSQMB_WeakPoint w, Actor by)
	{
		let h = RSQMB_Handler.Get();
		w.broken = true;
		w.A_StartSound("imp/shotx", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
		if (h) { let vr = h.VrService(); if (vr) vr.GetInt("pop", "", RGB_XH, 1.0, w); }
		RSQMB_Boss.Burst(w.pos + (0, 0, w.height / 2), Color(255, 255, 160, 40), RSQMB_Handler.FxLight() ? 10 : 20, 4.0, 5);
		// SECTION 9.1: a fight with no thralls (a Big Boss's) drops a health and armour burst for each one
		if (DropsOn()) RSQMB_HealthBit.Burst(w.pos + (0, 0, w.height / 2), CI('rsqmb_wp_drop_health', 10), CI('rsqmb_wp_drop_armor', 10));
		if (h && h.debug) Console.Printf("RSQMB tell t%d: boss %d weak point %d broken (%s)", level.maptime, b.idx, w.slot, by ? by.GetClassName() : 'none');
	}

	bool DropsOn() { return b && (b.big || b.total == 0); }

	// ---- BREAK! -------------------------------------------------------------------------------------------------------
	void DoBreak(RSQMB_Handler h, PlayerPawn p)
	{
		int now = level.maptime;
		let mb = b.mb;
		windAt = 0;
		ssPlusFire = false;
		ClearWeakPoints(false);
		RedLight(false);
		Unpin(mb);
		bool big = Big();
		double secs = big ? clamp(CF('rsqmb_break_secs_big', 4.0), 0.5, 15.0) : clamp(CF('rsqmb_break_secs', 3.0), 0.5, 15.0);
		brkMult = big ? clamp(CF('rsqmb_break_mult_big', 3.0), 1.0, 10.0) : clamp(CF('rsqmb_break_mult', 2.0), 1.0, 10.0);
		brkUntil = now + int(secs * TICRATE);
		brkFinished = false;
		brkCount++;
		Pin(mb, brkUntil, true, true);         // the stagger: its Pain state, held
		if (!b.mb) return;
		mb.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
		Say(h, "BREAK!", mb, p);
		if (h) { h.FxLifeLost(b); let vr = h.VrService(); if (vr) vr.GetInt("pop", "", RGB_XH, 2.0, mb); }
		if (DropsOn()) RSQMB_HealthBit.Burst(mb.pos + (0, 0, mb.height * 0.5), CI('rsqmb_break_drop_health', 40), CI('rsqmb_break_drop_armor', 25));
		// its thralls stagger with it (section 4: a staggered thrall can be finished)
		if (CI('rsqmb_break_thralls', 1) != 0)
			for (int i = 0; i < b.thr.Size(); i++)
				if (b.thrState[i] == RSQMB_Boss.ST_ALIVE && b.thr[i] && b.thr[i].health > 0) StaggerThrall(h, b.thr[i], int(secs * TICRATE));
		// the bog's BACKFIRE (BIG_BOSS.md 14): it chokes on its own acid
		if (big && pers == BB_BOG) mb.DamageMobj(null, null, max(1, int(b.maxHP * 0.05)), 'None', DMG_THRUSTLESS | DMG_NO_ARMOR);
		nextAt = brkUntil + Interval();
		if (h && h.debug) Console.Printf("RSQMB BREAK! t%d: boss %d %s staggers %.1f s taking x%.1f (break %d)", now, b.idx, b.mb ? b.mb.GetClassName() : 'gone', secs, brkMult, brkCount);
	}

	void BreakEnd(RSQMB_Handler h)
	{
		brkUntil = 0;
		if (b && b.mb) Unpin(b.mb);
		if (h && h.debug) Console.Printf("RSQMB BREAK! over t%d: boss %d", level.maptime, b ? b.idx : -1);
	}

	// a word over it: RSQ VisualRewards' world word (by name), else a BIGFONT print on each player's view
	static void Say(RSQMB_Handler h, String txt, Actor over, PlayerPawn p)
	{
		let vr = h ? h.VrService() : null;
		if (vr && over && vr.GetInt("worldword", txt .. "|over|size:1.6|label", -1, 0, over, 'gold') > 0) return;
		for (int i = 0; i < MAXPLAYERS; i++)
			if (playeringame[i] && players[i].mo) players[i].mo.A_Print(txt, 1.5, "BIGFONT");
	}

	// ---- the wind-up cut short (a life lost, switched off) ---------------------------------------------------------------
	void Cancel(RSQMB_Handler h, String why)
	{
		windAt = 0;
		ClearWeakPoints(true);
		RedLight(false);
		if (b && b.mb) { Unpin(b.mb); if (b.mb.SeeState) b.mb.SetState(b.mb.SeeState); }
		if (h && h.debug) Console.Printf("RSQMB tell t%d: boss %d wind-up cancelled (%s)", level.maptime, b ? b.idx : -1, why);
	}

	void ClearWeakPoints(bool quiet)
	{
		for (int i = 0; i < wps.Size(); i++) if (wps[i]) wps[i].Remove(quiet);
		wps.Clear();
	}

	void RedLight(bool on)
	{
		let mb = b ? b.mb : null;
		if (!mb) return;
		if (!on) { mb.A_RemoveLight('RSQMB_Tell'); return; }
		int rad = 300 + int(80 * sin(level.maptime * 24.0));
		mb.A_AttachLight('RSQMB_Tell', DynamicLight.PointLight, Color(255, 255, 24, 16), rad, 0, 0, (0, 0, mb.height * 0.6));
	}

	// ---- MISS: the attack fires ---------------------------------------------------------------------------------------
	void Fire(RSQMB_Handler h, PlayerPawn p)
	{
		let mb = b.mb;
		windAt = 0;
		RedLight(false);
		// Benellus' ghost guns fire from where they stand: kept before they go
		Array<double> gx, gy, gz;
		for (int i = 0; i < wps.Size(); i++)
		{
			let w = wps[i];
			if (w && !w.broken && w.onPlayer) { gx.Push(w.pos.x); gy.Push(w.pos.y); gz.Push(w.pos.z + w.height / 2); }
		}
		ClearWeakPoints(true);
		Unpin(mb);
		if (mb.SeeState) mb.SetState(mb.SeeState);
		if (!b.mb) return;
		fired++;
		bool plusFire = ssPlusFire;
		nextAt = level.maptime + Interval();
		if (!p) return;
		int dmg = Damage();
		Vector3 from = mb.pos + (0, 0, mb.height * 0.6) + (cos(mb.angle), sin(mb.angle), 0) * mb.radius;
		int ex = act - 1;     // a later act: more of it
		int bp = Big() ? pers : BB_NONE;
		switch (bp)
		{
		case BB_TYRANT:
			mb.A_StartSound("cyber/hoof", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			RSQMB_Wave.Ring(mb, dmg, 0);
			RSQMB_Wave.Ring(mb, dmg, 18);
			for (int k = 0; k < 5; k++) Shot("RSQMB_FireLine", mb.pos + (0, 0, 2), mb.angle + 72.0 * k, 0, 10, int(dmg * 0.75), p);
			if (ex > 0) RSQMB_Wave.Ring(mb, dmg, 36);
			if (ssPlusFire)     // SUPERSMITH+ (bigacts.zs): more slams
			{
				RSQMB_Wave.Ring(mb, dmg, 54);
				RSQMB_Wave.Ring(mb, dmg, 72);
				for (int k = 0; k < 5; k++) Shot("RSQMB_FireLine", mb.pos + (0, 0, 2), mb.angle + 36.0 + 72.0 * k, 0, 10, int(dmg * 0.75), p);
			}
			break;
		case BB_WARLORD:
			mb.A_StartSound("weapons/plasmaf", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			Beam(from, p, int(dmg * 2.5), 0);
			if (act >= 3) Beam(from, p, int(dmg * 2.5), 20);
			break;
		case BB_KNIGHT:
			mb.A_StartSound("skeleton/attack", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			for (int k = 0; k < 3 + ex; k++) Shot("RSQMB_Seeker", from, mb.AngleTo(p) + (k - (2 + ex) / 2.0) * 25.0, 0, 8, int(dmg * 1.2), p);
			Shot("RSQMB_FireLine", mb.pos + (0, 0, 2), mb.AngleTo(p), 0, 11, dmg, p);
			break;
		case BB_BOG:
			mb.A_StartSound("fatso/attack", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			for (int k = 0; k < 5 + 2 * ex; k++) Shot("RSQMB_Blob", mb.pos + (0, 0, 2) + (cos(mb.angle), sin(mb.angle), 0) * mb.radius, mb.AngleTo(p) + (k - (4 + 2 * ex) / 2.0) * 14.0, 0, 5, dmg, p);
			break;
		case BB_BENELLUS:
			mb.A_StartSound("weapons/sshotf", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
			for (int g = 0; g < gx.Size(); g++) Fan((gx[g], gy[g], gz[g]), p, 7 + 2 * ex, 30.0, 14, dmg, "RSQMB_Pellet");
			Fan(from, p, 5 + ex, 40.0, 12, dmg, "RSQMB_BigShot");
			break;
		default:
			if (kind == TK_RING)
			{
				mb.A_StartSound("cyber/hoof", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
				RSQMB_Wave.Ring(mb, dmg, 0);
				for (int k = 1; k <= ex; k++) RSQMB_Wave.Ring(mb, dmg, 18 * k);
			}
			else if (kind == TK_BEAM)
			{
				mb.A_StartSound("weapons/plasmaf", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
				Beam(from, p, int(dmg * 2.0), 0);
				if (ex > 0) Beam(from, p, int(dmg * 2.0), 24);
			}
			else
			{
				mb.A_StartSound("fatso/attack", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NONE);
				Fan(from, p, 7 + 2 * ex + (Big() ? 2 : 0), 60.0, 12, dmg, "RSQMB_BigShot");
			}
		}
		ssPlusFire = false;
		GuardStart(h, p);           // bigacts.zs: GUARD after EXPOSED!
		if (h && h.debug) Console.Printf("RSQMB tell t%d: boss %d MISSED: %s fires (act %d, %d a hit%s)", level.maptime, b.idx, AttackName(), act, dmg, plusFire ? ", SUPERSMITH+" : "");
	}

	Actor Shot(Class<Actor> cls, Vector3 from, double ang, double pit, double speed, int dmg, Actor at)
	{
		let m = RSQMB_BigShot(Actor.Spawn(cls, from, NO_REPLACE));
		if (!m) return null;
		m.target = b.mb;
		m.tracer = at;
		m.dmg = dmg;
		m.angle = ang;
		m.pitch = pit;
		m.Vel3DFromAngle(speed, ang, pit);
		return m;
	}

	// n shots spread over `spread` degrees, aimed at the player's middle
	void Fan(Vector3 from, Actor p, int n, double spread, double speed, int dmg, Class<Actor> cls)
	{
		Vector3 to = p.pos + (0, 0, p.height * 0.5) - from;
		double ang = atan2(to.y, to.x);
		double pit = -atan2(to.z, max(1.0, to.xy.Length()));
		for (int k = 0; k < n; k++)
		{
			double off = n > 1 ? -spread / 2 + spread * k / (n - 1) : 0;
			Shot(cls, from, ang + off, pit, speed, dmg, p);
		}
	}

	// a slow travelling beam at where the player stands now (it does not follow); `off` degrees to the side
	void Beam(Vector3 from, Actor p, int dmg, double off)
	{
		Vector3 to = p.pos + (0, 0, p.height * 0.5) - from;
		double ang = atan2(to.y, to.x) + off;
		double pit = -atan2(to.z, max(1.0, to.xy.Length()));
		Shot("RSQMB_BeamHead", from - (0, 0, 12), ang, pit, 9, dmg, p);
	}

	// ---- THE THRALLS' STAGGER (finisher.zs reads it) -------------------------------------------------------------------
	// MY RULE (section 4 left it open): a thrall is STAGGERED (held in its Pain state, not attacking, "FINISH!" over it)
	//   - for rsqmb_thrall_stagger_secs (2 s) once, when a blow takes it under rsqmb_thrall_stagger_hp % (25) of the most
	//     health it has had (DOOM 2016's own rule: a demon staggers when it is nearly dead), and
	//   - with its Boss on BREAK! (rsqmb_break_thralls), for the BREAK!'s length.
	// A melee strike on it then is a finisher (finisher.zs).
	void ThrallStep(RSQMB_Handler h, int now)
	{
		double pct = clamp(CF('rsqmb_thrall_stagger_hp', 25.0), 0.0, 90.0) / 100.0;
		int tics = int(clamp(CF('rsqmb_thrall_stagger_secs', 2.0), 0.0, 10.0) * TICRATE);
		if (pct > 0 && tics > 0)
			for (int i = 0; i < b.thr.Size(); i++)
			{
				let t = b.thr[i];
				if (!t || t.health <= 0 || b.thrState[i] != RSQMB_Boss.ST_ALIVE || lowDone.Find(t) < lowDone.Size()) continue;
				if (t.health > b.ThrallPeak(i) * pct) continue;
				lowDone.Push(t);
				StaggerThrall(h, t, tics);
			}
		for (int k = stA.Size() - 1; k >= 0; k--)
		{
			let t = stA[k];
			if (t && t.health > 0 && now < stUntil[k]) continue;
			if (t && h) h.WordClear("FINISH!", t);
			stA.Delete(k); stUntil.Delete(k);
		}
	}

	void StaggerThrall(RSQMB_Handler h, Actor t, int tics)
	{
		if (!t || t.health <= 0 || tics <= 0) return;
		int untilTic = level.maptime + tics;
		int k = stA.Find(t);
		if (k < stA.Size()) stUntil[k] = max(stUntil[k], untilTic);
		else { stA.Push(t); stUntil.Push(untilTic); }
		Pin(t, untilTic, true, true);
		if (h) h.WordHold("FINISH!", 0xFF8020, 0.75, t);
		if (h && h.debug) Console.Printf("RSQMB stagger t%d: a thrall %s staggers %d tics (health %d)", level.maptime, t.GetClassName(), tics, t.health);
	}

	bool Staggered(Actor a)
	{
		int now = level.maptime;
		if (!a || !b) return false;
		if (a == b.mb) return brkUntil > now;
		int k = stA.Find(a);
		return k < stA.Size() && stUntil[k] > now;
	}

	// ---- HELD STILL ---------------------------------------------------------------------------------------------------
	// A held monster's frame is kept (its tics never run out: no A_Chase, no attack, no step), its sideways speed is 0.
	// pain: put into its Pain state first, if it has one (the stagger). shake: a small shudder (+-3 degrees, net zero).
	void Pin(Actor a, int untilTic, bool pain, bool shake)
	{
		if (!a || a.health <= 0) return;
		if (pain)
		{
			let ps = a.FindState("Pain");
			if (ps && !Actor.InStateSequence(a.CurState, ps)) a.SetState(ps);
			if (!a || a.health <= 0) return;
		}
		int k = pinA.Find(a);
		if (k < pinA.Size()) { pinUntil[k] = untilTic; pinShake[k] = shake; }
		else { pinA.Push(a); pinUntil.Push(untilTic); pinShake.Push(shake); }
		Hold(a, shake);
	}
	static void Hold(Actor a, bool shake)
	{
		if (a.tics >= 0 && a.tics < 2) a.tics = 2;
		a.vel.x = 0; a.vel.y = 0;
		if (a.bNOGRAVITY || a.bFLOAT) a.vel.z = 0;
		if (shake && (level.maptime % 3) == 0) a.angle += (level.maptime % 6) < 3 ? 3.0 : -3.0;
	}
	void Unpin(Actor a)
	{
		int k = pinA.Find(a);
		if (k >= pinA.Size()) return;
		pinA.Delete(k); pinUntil.Delete(k); pinShake.Delete(k);
		if (a && a.health > 0 && a.tics > 1) a.tics = 1;
	}
	void PinStep(int now)
	{
		for (int k = pinA.Size() - 1; k >= 0; k--)
		{
			let a = pinA[k];
			if (!a || a.health <= 0 || now >= pinUntil[k])
			{
				pinA.Delete(k); pinUntil.Delete(k); pinShake.Delete(k);
				if (a && a.health > 0 && a.tics > 1) a.tics = 1;
				continue;
			}
			Hold(a, pinShake[k]);
		}
	}

	// ---- the fight is over: everything of this let go ---------------------------------------------------------------
	void End(RSQMB_Handler h)
	{
		ClearWeakPoints(true);
		PentaRelease();   // bigacts.zs
		GuardEnd(h, "the fight is over");
		SummonsEnd();
		RedLight(false);
		for (int k = 0; k < pinA.Size(); k++) { let a = pinA[k]; if (a && a.health > 0 && a.tics > 1) a.tics = 1; }
		pinA.Clear(); pinUntil.Clear(); pinShake.Clear();
		for (int k = 0; k < stA.Size(); k++) if (stA[k] && h) h.WordClear("FINISH!", stA[k]);
		stA.Clear(); stUntil.Clear();
		windAt = 0; brkUntil = 0;
		if (b && b.tele == self) b.tele = null;
		Destroy();
	}
}

// ---- the set piece's side (items.zs RSQMB_Ward reads BreakMult; finisher.zs reads tele) ---------------------------------
extend class RSQMB_Boss
{
	RSQMB_Tele tele;           // its telegraphed attack (telegraph.zs), made the first tic it is bound
	// BREAK!: x2 (a Boss) / x3 (a Big Boss) while it staggers, else 1
	double BreakMult() const { return (tele && tele.brkUntil > level.maptime) ? max(1.0, tele.brkMult) : 1.0; }
}

extend class RSQMB_Handler
{
	static clearscope bool TeleOn() { return CI('rsqmb_tell', 1) != 0; }

	// WorldTick: a telegraph for every bound Boss (it runs itself, RSQMB_Tele.Tick); the finishers due (finisher.zs)
	void TeleTick()
	{
		for (int i = 0; i < bosses.Size(); i++)
		{
			let b = bosses[i];
			if (b && !b.done && b.mb && b.mb.health > 0 && !b.tele) RSQMB_Tele.Make(b);
		}
		FinTick();
	}

	// fight.zs RoomGlow: red while it winds up
	static bool TeleRed(RSQMB_Boss b) { return b && b.tele && b.tele.windAt > 0 && CI('rsqmb_tell_red', 1) != 0; }
}

// ============================================================================
// A WEAK POINT: a small shootable spot on the Boss (or, Benellus' ghost guns, beside you). Only a player's attack hurts it
// (its source or the source of the missile that hit it); a monster's missile passes through it. Not solid, never a
// monster (no kill, no Score, no meter, no target for monsters). Its crosshair and the fly-in copies are RSQMB_WPMark.
// ============================================================================
class RSQMB_WeakPoint : Actor
{
	RSQMB_Tele tele;
	int slot, born, icon;
	double side, up;
	bool onPlayer, broken, back;   // back: one of Benellus' ANGRIER guns behind you (bigacts.zs)
	Actor mark;
	Actor fly[3];

	Default
	{
		Radius 10;
		Height 20;
		Health 150;
		Mass 100000;
		RenderStyle "AddStencil";
		StencilColor "FF5020";
		Alpha 0.9;
		Scale 0.5;
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
		+BRIGHT
		+NOICEDEATH
	}

	// the look: a glowing core (Benellus' ghost gun: the shotgun's own picture, pale)
	void Dress(bool gun, bool fewLights)
	{
		if (gun) { SetStateLabel("Gun"); SetShade(Color(255, 200, 230, 255)); A_SetScale(1.6, 1.6); }
		else { SetShade(Color(255, 255, 80, 32)); A_SetScale(radius / 20.0, radius / 20.0); }
		if (!fewLights) A_AttachLight('RSQMB_WP', DynamicLight.PointLight, Color(255, 255, 90, 30), int(radius * 5), 0, 0, (0, 0, height / 2));
	}

	Actor Need(Actor a)
	{
		if (a) return a;
		a = Actor.Spawn("RSQMB_WPMark", pos, NO_REPLACE);
		if (a)
		{
			a.sprite = GetSpriteIndex(icon == 1 ? 'MBX2' : (icon == 2 ? 'MBX3' : 'MBX1'));
			a.SetShade(RSQMB_Tele.RGB_XH);
		}
		return a;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		// a monster's missile (or anything not a player's) passes through
		if (passive && other && other.bMISSILE && !RSQMB_Handler.PlayerOf(other.target)) return false;
		return Super.CanCollideWith(other, passive);
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (broken || !tele) return 0;
		Actor p = RSQMB_Handler.PlayerOf(source);
		if (!p) p = RSQMB_Handler.PlayerOf(inflictor);
		if (!p) return 0;
		return Super.DamageMobj(inflictor, p, damage, mod, flags | DMG_THRUSTLESS, angle);
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		if (!broken && tele) tele.WeakBroken(self, source);
		broken = true;
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
		Remove(false);
	}

	// gone: its crosshair and fly-in with it; quiet (the wind-up over, the attack fired, cancelled): faded out at once
	void Remove(bool quiet)
	{
		if (mark) { mark.Destroy(); mark = null; }
		for (int k = 0; k < 3; k++) if (fly[k]) { fly[k].Destroy(); fly[k] = null; }
		A_RemoveLight('RSQMB_WP');
		if (quiet) { Destroy(); return; }
		broken = true;
		bSHOOTABLE = false;
		if (health > 0) SetStateLabel("Death");
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		// orphaned (a load, a fight gone): it goes
		if (!tele && !broken) Remove(true);
	}

	States
	{
	Spawn:
		BFS1 AB 4 BRIGHT;
		Loop;
	Gun:
		SHOT A -1 BRIGHT;
		Stop;
	Death:
		BFE1 ABCDEF 3 BRIGHT;
		Stop;
	}
}

// its crosshair (and the fly-in's three copies): SlowMo's DOWN assembly frames as sprites, Shaded gold, set frame by frame
// by RSQMB_Tele.Crosshair
class RSQMB_WPMark : Actor
{
	Default
	{
		RenderStyle "Shaded";
		StencilColor "FFD030";
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+BRIGHT
		+NOTONAUTOMAP
		+DONTSPLASH
	}
	States
	{
	Spawn:
		MBX1 A -1 BRIGHT;
		Stop;
	Frames:       // never entered: lists every frame so the engine loads them
		MBX1 ABCDEFGHIJKLMNOPQ 0;
		MBX2 ABCDEFGHIJKLMNOPQ 0;
		MBX3 ABCDEFGHIJKLMNOPQ 0;
		Stop;
	}
}

// ============================================================================
// THE BIG ATTACKS: visible, dodgeable, players only (the no-hitscan rule). Each hurts a player it meets (its own
// SpecialMissileHit: the Boss and its thralls, and any other monster, are passed through) and lives at most `life` tics.
// ============================================================================
class RSQMB_BigShot : Actor
{
	int dmg;
	int life;
	Default
	{
		Projectile;
		Radius 8;
		Height 12;
		Speed 12;
		Damage 0;
		RenderStyle "Add";
		Alpha 0.95;
		Scale 1.0;
		DeathSound "imp/shotx";
		+BRIGHT
		+NOTELEPORT
		+DONTSPLASH
		+FORCEXYBILLBOARD
		-ACTIVATEPCROSS
		-ACTIVATEIMPACT
	}
	override void BeginPlay() { Super.BeginPlay(); life = 10 * TICRATE; }
	override int SpecialMissileHit(Actor victim)
	{
		if (victim == target || !victim.player) return 1;
		if (victim.health > 0 && dmg > 0) victim.DamageMobj(self, target, dmg, 'None');
		return 0;
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen() || InStateSequence(CurState, FindState("Death"))) return;
		if (--life <= 0) ExplodeMissile();
	}
	States
	{
	Spawn:
		BAL7 AB 3 BRIGHT;
		Loop;
	Death:
		BAL7 CDE 4 BRIGHT;
		Stop;
	}
}

// Benellus' buckshot: small, quick
class RSQMB_Pellet : RSQMB_BigShot
{
	Default { Radius 5; Height 8; Scale 0.6; DeathSound ""; }
	States { Spawn: BAL1 AB 3 BRIGHT; Loop; Death: BAL1 CDE 3 BRIGHT; Stop; }
}

// THE SLOW TRAVELLING BEAM: a big slow ball leaving a beam of light behind it, back to where it was fired
class RSQMB_BeamHead : RSQMB_BigShot
{
	Default { Radius 18; Height 24; Scale 1.4; DeathSound "weapons/plasmax"; }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen() || InStateSequence(CurState, FindState("Death"))) return;
		let t = Actor.Spawn("RSQMB_BeamTrail", pos + (0, 0, 4), NO_REPLACE);
		if (t) t.A_SetScale(1.2, 1.2);
	}
	States { Spawn: BFS1 AB 3 BRIGHT; Loop; Death: BFE1 ABCDEF 4 BRIGHT; Stop; }
}
class RSQMB_BeamTrail : Actor
{
	Default { RenderStyle "Add"; Alpha 0.6; +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +BRIGHT +NOTONAUTOMAP }
	override void Tick() { Super.Tick(); if (bDestroyed || isFrozen()) return; alpha -= 0.025; if (alpha <= 0) Destroy(); }
	States { Spawn: BFS1 AB 3 BRIGHT; Loop; }
}

// THE SEEKER (the Black Knight's soul seekers): slow, turning a little toward you
class RSQMB_Seeker : RSQMB_BigShot
{
	Default { Speed 8; +SEEKERMISSILE; DeathSound "skeleton/tracex"; }
	override void BeginPlay() { Super.BeginPlay(); life = 7 * TICRATE; }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen() || InStateSequence(CurState, FindState("Death"))) return;
		if (level.maptime % 3 == 0 && tracer && tracer.health > 0) A_SeekerMissile(2, 4);
	}
	States { Spawn: FATB AB 2 BRIGHT; Loop; Death: FBXP ABC 6 BRIGHT; Stop; }
}

// A LINE OF FIRE along the ground (the Tyrant's pentagram lines, the Knight's line): it runs along the floor, leaving
// flames that fade; step aside
class RSQMB_FireLine : RSQMB_BigShot
{
	Default { Radius 16; Height 28; Speed 10; +FLOORHUGGER; DeathSound ""; }
	override void BeginPlay() { Super.BeginPlay(); life = 4 * TICRATE; }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen() || InStateSequence(CurState, FindState("Death"))) return;
		if (level.maptime % 2 == 0) Actor.Spawn("RSQMB_Ember", pos, NO_REPLACE);
	}
	States { Spawn: FIRE ABCDEFGH 2 BRIGHT; Loop; Death: FIRE GH 3 BRIGHT; Stop; }
}
class RSQMB_Ember : Actor
{
	Default { RenderStyle "Add"; Alpha 0.8; +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +BRIGHT +NOTONAUTOMAP }
	States { Spawn: FIRE ABCDEFGH 3 BRIGHT; Stop; }
}

// THE BOG'S BURP: blobs that crawl along the floor toward you and leave an acid puddle where they end
class RSQMB_Blob : RSQMB_BigShot
{
	Default { Radius 12; Height 14; Speed 5; +FLOORHUGGER; RenderStyle "AddStencil"; StencilColor "60FF30"; DeathSound "fatso/shotx"; }
	override void BeginPlay() { Super.BeginPlay(); life = 6 * TICRATE; }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen() || InStateSequence(CurState, FindState("Death"))) return;
		// it crawls: a little of the way toward you each tic, at its own speed
		if (tracer && tracer.health > 0)
		{
			double want = AngleTo(tracer);
			angle += clamp(deltaangle(angle, want), -3.0, 3.0);
			vel.xy = (cos(angle), sin(angle)) * Speed;
		}
	}
	States
	{
	Spawn:
		BAL7 AB 4 BRIGHT;
		Loop;
	Death:
		TNT1 A 0 { let pd = RSQMB_Puddle(Actor.Spawn("RSQMB_Puddle", (pos.xy, floorz), NO_REPLACE)); if (pd) { pd.target = target; pd.dmg = max(1, dmg / 4); } }
		BAL7 CDE 4 BRIGHT;
		Stop;
	}
}

// an acid puddle: hurts a player standing in it every 10 tics, fades after 6 s
class RSQMB_Puddle : Actor
{
	int dmg, age;
	Default { Radius 40; Height 4; RenderStyle "AddStencil"; StencilColor "40D020"; Alpha 0.55; Scale 2.5; +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +BRIGHT +NOTONAUTOMAP +FLATSPRITE }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen()) return;
		age++;
		if (age > 6 * TICRATE) { alpha -= 0.05; if (alpha <= 0) { Destroy(); return; } }
		if (age % 10 != 0) return;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let p = players[i].mo;
			if (p.health <= 0 || p.pos.z - floorz > 16 || (p.pos.xy - pos.xy).Length() > radius + p.radius) continue;
			p.DamageMobj(self, target, dmg, 'Slime', DMG_THRUSTLESS);
		}
	}
	States { Spawn: BAL7 A -1 BRIGHT; Stop; }
}

// THE GROUND SHOCKWAVE RING: a ring of fire running out along the floor from the Boss, with two gaps to step into (or
// jump it). Its hurt is worked out (a player on the floor where the ring passes, outside a gap, once a ring), so a gap
// is a gap however far it has run; the flames are only what you see.
class RSQMB_Wave : Actor
{
	int dmg, delay, age;
	double rr, spd, maxR;
	Array<double> gapA;
	double gapW;
	Array<Actor> hit;
	Array<Actor> vis;
	Array<double> visA;

	Default { Radius 1; Height 1; RenderStyle "None"; +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTONAUTOMAP }

	// a ring from the Boss's feet, `delay` tics from now
	static void Ring(Actor mb, int dmg, int delay)
	{
		let w = RSQMB_Wave(Actor.Spawn("RSQMB_Wave", mb.pos + (0, 0, 24), NO_REPLACE));
		if (!w) return;
		w.target = mb;
		w.dmg = dmg;
		w.delay = delay;
		w.rr = mb.radius;
		w.spd = 9;
		w.maxR = 1400;
		w.gapW = 22;      // half a gap, degrees
		double g0 = frandom[rsqmbtell](0, 360);
		w.gapA.Push(g0);
		w.gapA.Push(g0 + frandom[rsqmbtell](120, 240));
	}

	bool InGap(double a)
	{
		for (int i = 0; i < gapA.Size(); i++) if (abs(deltaangle(a, gapA[i])) < gapW) return true;
		return false;
	}

	override void Tick()
	{
		if (isFrozen()) return;
		if (delay > 0) { delay--; return; }
		if (age == 0) MakeVis();
		age++;
		rr += spd;
		if (rr > maxR) { for (int i = 0; i < vis.Size(); i++) if (vis[i]) vis[i].Destroy(); Destroy(); return; }
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let p = players[i].mo;
			if (p.health <= 0 || hit.Find(p) < hit.Size()) continue;
			double d = (p.pos.xy - pos.xy).Length();
			if (abs(d - rr) > 20 + p.radius || p.pos.z - p.floorz > 20) continue;
			if (InGap(atan2(p.pos.y - pos.y, p.pos.x - pos.x))) continue;
			if (!CheckSight(p, SF_IGNOREVISIBILITY)) continue;
			hit.Push(p);
			p.DamageMobj(self, target, dmg, 'None', DMG_THRUSTLESS);
		}
		for (int i = 0; i < vis.Size(); i++)
		{
			let f = vis[i];
			if (!f) continue;
			Vector2 xy = pos.xy + (cos(visA[i]), sin(visA[i])) * rr;
			let sec = level.PointInSector(xy);
			f.SetOrigin((xy, sec.floorplane.ZatPoint(xy)), true);
		}
	}

	void MakeVis()
	{
		int n = RSQMB_Handler.FxLight() ? 24 : 36;
		for (int k = 0; k < n; k++)
		{
			double a = 360.0 / n * k;
			if (InGap(a)) continue;
			let f = Actor.Spawn("RSQMB_RingFlame", pos, NO_REPLACE);
			if (!f) continue;
			vis.Push(f);
			visA.Push(a);
		}
	}
}
class RSQMB_RingFlame : Actor
{
	Default { RenderStyle "Add"; Alpha 0.9; Scale 0.8; +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +BRIGHT +NOTONAUTOMAP }
	States { Spawn: FIRE ABCDEFGH 2 BRIGHT; Loop; }
}

// ============================================================================
// THE HEALTH AND ARMOUR BURSTS (section 9.1; finisher.zs gives its own straight to the player): bits thrown out where a weak
// point broke or the Boss stood, each 5 health or 5 armour, there for 30 s. Health tops up to your full health (no more);
// armour as an armour bonus does (to 200).
// ============================================================================
class RSQMB_HealthBit : Health
{
	int age;
	Default
	{
		Inventory.Amount 5;
		Inventory.PickupMessage "";
		Inventory.PickupSound "misc/health_pkup";
		Scale 0.8;
		+INVENTORY.NOSCREENFLASH
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || Owner || isFrozen()) return;
		if (++age > 30 * TICRATE) Destroy();
	}
	States { Spawn: BON1 ABCDCB 4 BRIGHT; Loop; }

	// health and armour points out of `at` as bits of 5 (at most 12 of each)
	static void Burst(Vector3 at, int hp, int ar)
	{
		int nh = min(12, (max(0, hp) + 4) / 5), na = min(12, (max(0, ar) + 4) / 5);
		for (int i = 0; i < nh + na; i++)
		{
			let it = Actor.Spawn(i < nh ? "RSQMB_HealthBit" : "RSQMB_ArmorBit", at, NO_REPLACE);
			if (!it) continue;
			double a = frandom[rsqmbtell](0, 360);
			it.vel = (cos(a) * frandom[rsqmbtell](2, 5), sin(a) * frandom[rsqmbtell](2, 5), frandom[rsqmbtell](4, 8));
		}
	}
}
class RSQMB_ArmorBit : BasicArmorBonus
{
	int age;
	Default
	{
		Armor.SavePercent 33.335;
		Armor.SaveAmount 5;
		Armor.MaxSaveAmount 200;
		Inventory.PickupMessage "";
		Inventory.PickupSound "misc/armor_pkup";
		Scale 0.8;
		+INVENTORY.NOSCREENFLASH
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || Owner || isFrozen()) return;
		if (++age > 30 * TICRATE) Destroy();
	}
	States { Spawn: BON2 ABCDCB 4 BRIGHT; Loop; }
}
