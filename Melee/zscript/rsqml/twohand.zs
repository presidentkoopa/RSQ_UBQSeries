// GROUND POUND and CLEAR OUT (GBOVR_TREES.md 4.1 A, Power; owner 11-02), the Fists tree's two-hand moves.
//
// (And "both hands apart", rsqg_pair 1: the Guard's Absorb and Release, guard.zs Release.)
// RSQ GESTURES READS THE HANDS. On the machine that has them it sees "both hands down" and "both palms thrust" and sends
// them as the network event rsqg_pair (arg0 the kind: 0 down, 3 palms thrust; arg1 the speed, hundredths of m/s), so the
// move happens for that player in every game at once. Without RSQ Gestures neither move happens. Gestures' Two-Hand
// Events switch is off by default; a player who has either move keeps them read by asking Gestures about them once
// every ASK_EVERY tics (its "pair.ago", which keeps the two-hand events awake for a second).
//
// THE LEVEL is the better of the two gloves' (each glove is its own Gun Bonsai record), and the blow is paid to that
// glove (RSQML.Blow). Without RSQ Gun Bonsai VR the rows Ground Pound and Clear Out (off) play each at level 1.
//   GROUND POUND  both fists swung down hard together: a shockwave round you; with Knockdown on that glove, what it hits
//                 that is no boss goes down for a count of 2 (Gun Bonsai VR's "knockdown"), else it staggers
//   CLEAR OUT     both palms thrust forward together, nothing but the gloves in either hand: everything in a 90-degree
//                 wedge in front is shoved back hard (and is armed for that glove's Wallflower), hurt, staggered
class RSQML_TwoHand : StaticEventHandler
{
	const ASK_EVERY = 17;
	const POUND_STAGGER = 15;     // without Knockdown, what the shockwave does to what it hits
	const POUND_HEIGHT = 64.0;    // map units above or below your feet that the shockwave still reaches
	const WEDGE = 45.0;           // degrees either side of where you face
	const TAUNT_STAGGER = 10;     // Taunt 3: what stands within TAUNT_NEAR m
	const TAUNT_NEAR = 3.0;
	int tauntUntil[MAXPLAYERS];   // Taunt: the next punch until this tic does double (gloves.zs Deliver)

	static RSQML_TwoHand Get() { return RSQML_TwoHand(StaticEventHandler.Find("RSQML_TwoHand")); }

	// the better glove in hand for a move, and its level (0: neither has it)
	static RSQ_Glove, int Best(PlayerPawn pmo, String short, String cvarName)
	{
		RSQ_Glove best = null;
		int lv = 0;
		for (int h = 0; h < 2; h++)
		{
			let g = RSQML_Gloves.GloveIn(pmo, h);
			if (!g) continue;
			int l = RSQML.MoveLevel(pmo, g, short, cvarName);
			if (l > lv) { lv = l; best = g; }
		}
		return best, lv;
	}

	override void WorldTick()
	{
		if (level.maptime % ASK_EVERY) return;
		Service gs = null;
		bool looked = false;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let pmo = players[pn].mo;
			RSQ_Glove g;
			int a, b;
			[g, a] = Best(pmo, "GroundPound", "rsqml_groundpound");
			[g, b] = Best(pmo, "ClearOut", "rsqml_clearout");
			int c = max(RSQML_Guard.Node(pmo, "AbsorbRelease"), RSQML_Guard.Node(pmo, "Taunt"));
			if (a <= 0 && b <= 0 && c <= 0) continue;
			if (!looked) { gs = RSQML.Svc("RSQG_Service"); looked = true; }
			if (!gs) return;
			gs.GetInt("pair.ago", "", a > 0 ? 0 : b > 0 ? 3 : 1, 0, pmo);
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqg_pair") return;
		int pn = e.Player;
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn]) return;
		let pmo = players[pn].mo;
		if (!pmo || pmo.health <= 0) return;
		if (e.Args[0] == 0) Pound(pmo, e.Args[1] / 100.0);
		else if (e.Args[0] == 3) ClearOut(pmo, e.Args[1] / 100.0);
		else if (e.Args[0] == 1)
		{
			// both hands apart: the Guard's charge goes out if there is one (Absorb and Release, guard.zs), else a Taunt
			let gd = RSQML_Guard.Get();
			if (!gd || gd.Release(pmo) == 0) Taunt(pmo);
		}
	}

	// a monster's push away from you, by its weight (a boss barely moves)
	static double Heft(Actor o)
	{
		double k = clamp(100.0 / max(o.mass, 1.0), 0.1, 1.5);
		return o.bBoss ? k * 0.3 : k;
	}

	// TAUNT (Gun Bonsai VR's player node, GBOVR_TREES.md 4.1 H): empty hands or fists, both thrown apart: every monster
	// within Taunt.range that can see you turns on you, and your next punch inside Taunt.tics does double; at level 3
	// what stands within TAUNT_NEAR m staggers.
	void Taunt(PlayerPawn pmo)
	{
		int lv = RSQML_Guard.Node(pmo, "Taunt");
		if (lv <= 0) return;
		let p = pmo.player;
		if ((p.ReadyWeapon && !RSQ_Glove(p.ReadyWeapon)) || (p.OffhandWeapon && !RSQ_Glove(p.OffhandWeapon))) return;
		int pn = pmo.PlayerNumber();
		tauntUntil[pn] = level.maptime + int(RSQML.Num("Taunt.tics", lv, 0, 105));
		double upm = RSQML.UnitsPerMetre();
		double r = RSQML.Num("Taunt.range", lv, 0, 10.0) * upm;
		int n = 0;
		let it = BlockThingsIterator.Create(pmo, r);
		while (it.Next())
		{
			let o = it.thing;
			if (!RSQML.IsFoe(pmo, o) || pmo.Distance2D(o) > r || !o.CheckSight(pmo, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			o.target = pmo;
			o.lastheard = pmo;
			if (o.SeeState && (o.CurState == o.SpawnState || o.InStateSequence(o.CurState, o.SpawnState))) o.SetState(o.SeeState);
			if (lv >= 3 && pmo.Distance2D(o) <= TAUNT_NEAR * upm) RSQML.Stagger(o, TAUNT_STAGGER);
			RSQML.Touch("taunt", pmo, o);
			n++;
		}
		pmo.A_StartSound("*pain100", CHAN_VOICE, CHANF_OVERLAP, 1.0);
		if (RSQML.Debug() > 0) Console.Printf("RSQML taunt: level %d, %d turned on you, the next punch inside %d tics doubles", lv, n, tauntUntil[pn] - level.maptime);
	}

	void Pound(PlayerPawn pmo, double mps)
	{
		if (!RSQML_Gloves.GloveIn(pmo, 0) || !RSQML_Gloves.GloveIn(pmo, 1)) return;   // both fists
		RSQ_Glove g;
		int lv;
		[g, lv] = Best(pmo, "GroundPound", "rsqml_groundpound");
		if (lv <= 0) return;
		double need = RSQML.Num("GroundPound.speed", lv, 0, 3.0);
		bool dbg = RSQML.Debug() > 0;
		if (mps < need) { if (dbg) Console.Printf("RSQML ground pound: both hands down at %.2f m/s, needs %.1f", mps, need); return; }
		double r = RSQML.Num("GroundPound.radius", lv, 0, 2.5) * RSQML.UnitsPerMetre();
		int dmg = int(RSQML.Num("GroundPound.damage", lv, 0, 30));
		let gb = RSQML.GB();
		bool kd = RSQML.GBLevel(g, "Knockdown") > 0;
		Actor inf = RSQML.Blow(pmo, g, pmo.pos);
		int n = 0;
		let it = BlockThingsIterator.Create(pmo, r);
		while (it.Next())
		{
			let o = it.thing;
			if (!RSQML.IsFoe(pmo, o) || pmo.Distance2D(o) > r + o.radius) continue;
			if (o.pos.z > pmo.pos.z + POUND_HEIGHT || o.pos.z + o.height < pmo.pos.z - POUND_HEIGHT) continue;
			n++;
			RSQML.Touch("pound", pmo, o);
			o.DamageMobj(inf, pmo, dmg, 'Melee', DMG_THRUSTLESS);
			if (!o || o.health <= 0) continue;
			if (!o.bDontThrust)
			{
				Vector2 d = o.pos.xy - pmo.pos.xy;
				double l = d.Length();
				if (l > 0.5) o.vel.xy += d / l * 4.0 * Heft(o);
				o.vel.z += 3.0 * Heft(o);
			}
			if (!(kd && gb && !o.bBoss && gb.GetInt("knockdown", "", 2, 0, o) == 1)) RSQML.Stagger(o, POUND_STAGGER);
		}
		pmo.A_StartSound("rsqml/smash", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		pmo.A_QuakeEx(1, 1, 2, 8, 0, r, "", QF_SCALEDOWN);
		RSQ_Buzz.Start(pmo, 0, 1.0, 10);
		RSQ_Buzz.Start(pmo, 1, 1.0, 10);
		if (dbg) Console.Printf("RSQML ground pound: level %d at %.2f m/s, %.0f units round, %d each, %d hit%s", lv, mps, r, dmg, n, kd ? " (knockdown)" : "");
	}

	void ClearOut(PlayerPawn pmo, double mps)
	{
		let p = pmo.player;
		// empty hands or fists: nothing but the gloves in either hand
		if ((p.ReadyWeapon && !RSQ_Glove(p.ReadyWeapon)) || (p.OffhandWeapon && !RSQ_Glove(p.OffhandWeapon))) return;
		RSQ_Glove g;
		int lv;
		[g, lv] = Best(pmo, "ClearOut", "rsqml_clearout");
		if (lv <= 0) return;
		double r = RSQML.Num("ClearOut.range", lv, 0, 2.5) * RSQML.UnitsPerMetre();
		int dmg = int(RSQML.Num("ClearOut.damage", lv, 0, 15));
		double push = RSQML.Num("ClearOut.push", lv, 0, 14.0);
		int st = int(RSQML.Num("ClearOut.stagger", lv, 0, 10));
		int wsLv = RSQML.MoveLevel(pmo, g, "WallSplat", "rsqml_wallsplat");
		Actor inf = RSQML.Blow(pmo, g, pmo.pos);
		int n = 0;
		let it = BlockThingsIterator.Create(pmo, r);
		while (it.Next())
		{
			let o = it.thing;
			if (!RSQML.IsFoe(pmo, o) || pmo.Distance2D(o) > r + o.radius) continue;
			if (Actor.absangle(pmo.AngleTo(o), pmo.angle) > WEDGE) continue;
			if (o.pos.z > pmo.pos.z + pmo.height || o.pos.z + o.height < pmo.pos.z) continue;
			if (!pmo.CheckSight(o, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			n++;
			RSQML.Touch("clearout", pmo, o);
			o.DamageMobj(inf, pmo, dmg, 'Melee', DMG_THRUSTLESS);
			if (!o || o.health <= 0) continue;
			if (!o.bDontThrust)
			{
				double a = pmo.AngleTo(o);
				o.vel.xy += (cos(a), sin(a)) * push * Heft(o);
				o.vel.z += 4.0 * Heft(o);
				if (wsLv > 0) RSQ_Splat.Arm(o, pmo, g, wsLv);   // shoved into a wall, Wallflower's slam
			}
			RSQML.Stagger(o, st);
		}
		pmo.A_StartSound("rsqml/swat", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		RSQ_Buzz.Start(pmo, 0, 0.8, 8);
		RSQ_Buzz.Start(pmo, 1, 0.8, 8);
		if (RSQML.Debug() > 0) Console.Printf("RSQML clear out: level %d at %.2f m/s, %.0f units, %d each, %d shoved", lv, mps, r, dmg, n);
	}
}
