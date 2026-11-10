// RSQWP_Looks / RSQWP_Perks -- what the rope code (forked from RSQ_Grapple's core) asks of the hook's look sets and of
// Grapple's perks. RSQ Whip has no look sets (its own sounds and a spark of particles). RSQWP_Perks: Fast Reel, Steady
// Line and Slingshot from Gun Bonsai VR's whip tree (11-10); the leash's four (OnBite, OnArrive, Bowl, mass) are stubs;
// Hurt, which every point the whip deals goes through. The service is service.zs.
class RSQWP_Looks
{
	static String Sound(Name what)
	{
		if (what == 'hitflesh') return "rsqwp/hit";
		if (what == 'crack') return "rsqwp/crack";
		return "";
	}
	static Name Sprite(Name what) { return 'TNT1'; }

	// A burst of sparks: hot at a crack, dark red on flesh.
	static play void Spark(Vector3 at, Name what)
	{
		let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		if (!c) return;
		color col = what == 'flesh' ? 0xA01010 : 0xFFE8B0;
		int n = what == 'crack' ? 10 : 6;
		for (int k = 0; k < n; k++)
		{
			double a = frandom(0, 360), p = frandom(-60, 60), v = frandom(1.5, 4.0);
			c.A_SpawnParticle(col, SPF_FULLBRIGHT, 8, 2.5, 0, 0, 0, 0, cos(a) * cos(p) * v, sin(a) * cos(p) * v, sin(p) * v, 0, 0, -0.15, 1.0, -1, -0.15);
		}
	}
}

class RSQWP_Perks
{
	// THE ROPE PERKS (owner's pick 2026-11-10, design/WHIP_DEAD_FEATURES.md 4): Gun Bonsai VR's whip-tree nodes (up_whip.zs),
	// asked by name once a second with the rest of the tree (whip.zs GbRefresh, Gb: -1 without the patch, so every factor
	// is 1 and nothing is done). Every number is RSQ Grapple's own (Grapple/zscript/rsqgr/perks.zs RSQGR_Perks, parsed):
	//   Fast Reel     REEL_STEP 0.10 a level: the rope's reel and the leash's slide x(1 + 0.10 lv)          (Factor 'reel')
	//   Steady Line   the swing's air drag + drag x 3 lv while the stick is centred                        (SteadyDrag)
	//   Slingshot     a let-go in the air: the speed x(1 + 0.10 lv)                                           (OnLetGo)
	// and, since Whip and Gun's Leash came back (11-10), the four that need a monster on the core's line:
	//   Heavy Lash    the mass limit x(1 + 0.5 lv); a heavy one (too heavy, a boss) leashed staggers 10 + 10 lv tics,
	//                 once per 3 s per monster                                                    (Factor 'mass', OnBite)
	//   Barbed Claw   the leash's bite 4 + 4 lv; torn out of a living monster 6 + 6 lv                  (OnBite, OnLetGo)
	//   Get Over Here what the leash brings arrives staggered 20 + 15 lv tics                                (OnArrive)
	//   Bowling       what the leash brings strikes what stands in its way: 5 + 5 lv + half its speed,
	//                 staggered 15 + 10 lv, shoved aside, and it comes on (once a second per pair)              (Bowl)
	// (Grapple's Heavy Haul also widens its yank's size limit 15% a level: the whip's leash has no size limit.) The
	// stagger is Gun Bonsai VR's own (its "stagger", RSQ_Dazed); the damage is the whip's (Hurt: its XP, its 'Whip' type).
	static play int Lv(Actor who, int g) { return max(0, RSQWP_Whip.Gb(who, g)); }
	static play bool Dbg() { return RSQWP_Util.Flag("rsqwp_debug", false); }
	static play double Factor(Actor who, Name what)
	{
		if (what == 'reel') return 1.0 + 0.10 * Lv(who, RSQWP_Whip.G_REEL);
		if (what == 'mass') return 1.0 + 0.50 * Lv(who, RSQWP_Whip.G_HAUL);
		return 1.0;
	}
	static play double SteadyDrag(PlayerPawn pmo, double k, bool still)
	{
		int lv = still ? Lv(pmo, RSQWP_Whip.G_STEADY) : 0;
		return lv > 0 ? k * (3.0 * lv) : 0.0;
	}
	// the whip's line is coming out (core.zs LetGo, after the grace)
	static play void OnLetGo(RSQWP_Hook h, bool byPlayer)
	{
		if (!h || !h.owner || !h.owner.player) return;
		let pmo = h.owner;
		// BARBED CLAW: torn out of a living monster
		let v = h.victim;
		if (v && v.Health > 0 && v.bShootable && (h.phase == RSQWP_Hook.PH_BITE || h.phase == RSQWP_Hook.PH_HOLD || (h.phase == RSQWP_Hook.PH_LATCH && h.heavy)))
		{
			int barb = Lv(pmo, RSQWP_Whip.G_BARB);
			if (barb > 0)
			{
				int hp0 = v.Health;
				Hurt(v, h, pmo, 6 + 6 * barb, RSQWP_Whip.DmgType(), DMG_THRUSTLESS);
				if (Dbg()) Console.Printf("T_WPW BARBED tear %s %d -> %d", v.GetClassName(), hp0, v ? v.Health : 0);
			}
		}
		// SLINGSHOT: let go of a swing in the air (alt-fire, a latched rope)
		if (!byPlayer || h.phase != RSQWP_Hook.PH_LATCH) return;
		int sl = Lv(pmo, RSQWP_Whip.G_SLING);
		bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
		if (sl <= 0 || grounded) return;
		Vector3 v0 = pmo.vel;
		pmo.vel *= 1.0 + 0.10 * sl;
		if (Dbg()) Console.Printf("T_WPW SLINGSHOT %d t%d vel (%.2f %.2f %.2f) %.2f -> (%.2f %.2f %.2f) %.2f", sl, level.maptime, v0.x, v0.y, v0.z, v0.Length(), pmo.vel.x, pmo.vel.y, pmo.vel.z, pmo.vel.Length());
	}
	// the leash has just caught a monster (whip.zs Leash, after it decided slide or anchor)
	static play void OnBite(RSQWP_Hook h, Actor v)
	{
		if (!h || !v || !h.owner || !h.owner.player) return;
		let pmo = h.owner;
		// HEAVY HAUL: a heavy one on the line staggers, once per 3 s
		int haul = Lv(pmo, RSQWP_Whip.G_HAUL);
		let core = RSQWP_Core.Get();
		if (h.heavy && haul > 0 && v.Health > 0 && v.bIsMonster && core && core.PerkCool(v))
		{
			int t = 10 + 10 * haul;
			RSQWP_Whip.Ask("stagger", v, t);
			if (Dbg()) Console.Printf("T_WPW HAUL %s (heavy) staggered %d tics", v.GetClassName(), t);
		}
		// BARBED CLAW: the bite
		int barb = Lv(pmo, RSQWP_Whip.G_BARB);
		if (barb > 0 && v.Health > 0 && v.bShootable)
		{
			int hp0 = v.Health;
			Hurt(v, h, pmo, 4 + 4 * barb, RSQWP_Whip.DmgType(), DMG_THRUSTLESS);
			if (Dbg()) Console.Printf("T_WPW BARBED bite %s %d -> %d", v.GetClassName(), hp0, v ? v.Health : 0);
		}
	}
	// GET OVER HERE: what the leash brought has arrived in front of you (monster.zs Slide)
	static play void OnArrive(Actor v, PlayerPawn pmo)
	{
		if (!v || !pmo || v.Health <= 0 || !v.bIsMonster) return;
		int goh = Lv(pmo, RSQWP_Whip.G_GOH);
		if (goh <= 0) return;
		int t = 20 + 15 * goh;
		RSQWP_Whip.Ask("stagger", v, t);
		if (Dbg()) Console.Printf("T_WPW GET OVER HERE %s arrives staggered %d tics", v.GetClassName(), t);
	}
	// BOWLING: `a` is about to be moved to `want` (its middle) by the leash; whatever stands there is struck, staggered and
	// shoved off the line, so `a` comes on. `speed` is map units a world tic. (Grapple's Bowl, line for line.)
	static play void Bowl(Actor a, PlayerPawn pmo, Vector3 want, double speed)
	{
		if (!a || !pmo) return;
		int lv = Lv(pmo, RSQWP_Whip.G_BOWL);
		let core = RSQWP_Core.Get();
		if (lv <= 0 || !core) return;
		Vector2 dir = want.xy - a.Pos.xy;
		double dl = dir.Length();
		if (dl < 0.01) return;
		dir /= dl;
		double wantZ = want.z - a.Height * 0.5;
		let it = BlockThingsIterator.Create(a, a.Radius + dl + 16);
		while (it.Next())
		{
			let o = it.thing;
			if (!o || o == a || o == pmo || o.player || !o.bShootable || !o.bSolid || o.Health <= 0) continue;
			if ((o.Pos.xy - want.xy).Length() > a.Radius + o.Radius + 2) continue;
			if (o.Pos.z > wantZ + a.Height || o.Pos.z + o.Height < wantZ) continue;
			if (core.Bowled(a, o)) continue;
			int dmg = 5 + 5 * lv + int(speed * 0.5);
			int hp0 = o.Health;
			Hurt(o, a, pmo, dmg, RSQWP_Whip.DmgType(), DMG_THRUSTLESS);
			if (!o) continue;
			if (o.Health > 0 && o.bIsMonster) RSQWP_Whip.Ask("stagger", o, 15 + 10 * lv);
			// shove it off the line, to whichever side it already leans, a little forward too
			Vector2 rel = o.Pos.xy - a.Pos.xy;
			Vector2 side = (-dir.y, dir.x);
			if ((rel dot side) < 0) side = -side;
			double need = a.Radius + o.Radius + 4 - abs(rel dot side);
			bool shoved = false;
			if (!o.bDontThrust && o.Health > 0)
			{
				for (int k = 0; k < 3 && !shoved; k++)
				{
					Vector2 to = o.Pos.xy + side * (need + 8 * k) + dir * 8;
					shoved = o.TryMove(to, 1);
					if (!shoved) { to = o.Pos.xy - side * (need + a.Radius + o.Radius + 8 * k) + dir * 8; shoved = o.TryMove(to, 1); }
				}
			}
			if (Dbg()) Console.Printf("T_WPW BOWL %s -> %s speed %.1f dmg %d hp %d -> %d shoved %d", a.GetClassName(), o.GetClassName(), speed, dmg, hp0, o ? o.Health : 0, shoved);
		}
	}
	// Every point the whip deals goes through here. GUN BONSAI VR (2026-11-02, GBOVR_TREES.md section 1): the whip
	// weapon earns it. Gun Bonsai credits a hit by its inflictor, and the whip's inflictors are the player (a crack),
	// nothing (the swung monster's own hurt) or the swung monster (a flail smash), never RSQWP_WhipWeapon, so before
	// the patch the XP went to whichever hand Gun Bonsai guessed. Now the hit is dealt inside the patch's claim
	// bracket (RSQ_MeleeUpgradeService "credit.push" / "credit.pop", asked by name: no Gun Bonsai needed to compile,
	// nothing happens without the patch), which pays damage by the player's own body to the weapon that opened it.
	// The bracket covers an inflictor that is the player or nothing; a smash's inflictor is the swung monster, so
	// inside the bracket that hit is dealt as the player's with no thrust (Smash does its own knock).
	// flags: DMG_THRUSTLESS from a crack or sting with Crack Knocks Enemies Back off (whip.zs Hit)
	static play void Hurt(Actor v, Actor inflictor, Actor source, int dmg, Name kind, int flags = 0)
	{
		if (!v || v.Health <= 0) return;
		Weapon wh = null;
		Service gb = null;
		let pmo = PlayerPawn(source);
		if (pmo)
		{
			wh = Weapon(pmo.FindInventory("RSQWP_WhipWeapon"));
			if (wh) { let it = ServiceIterator.Find("RSQ_MeleeUpgradeService"); gb = it.Next(); }
		}
		bool bracket = gb && wh && gb.GetInt("credit.push", "", 0, 0, wh) == 1;
		if (bracket && inflictor && inflictor != source) v.DamageMobj(source, source, dmg, kind, DMG_THRUSTLESS);
		else v.DamageMobj(inflictor, source, dmg, kind, flags);
		if (bracket) gb.GetInt("credit.pop", "", 0, 0, wh);
	}
}

