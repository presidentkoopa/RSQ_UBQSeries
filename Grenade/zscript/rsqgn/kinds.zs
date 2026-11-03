// RSQ Grenade -- THE GRENADE KINDS (Gun Bonsai VR patch, GBOVR_TREES.md 4.5 Kinds; the owner's eight, 11-02). Each kind is
// an unlock on the grenade's own record; the frag is the base kind and the only one without the patch. The holding hand's
// alt trigger cycles the kinds you own (hand.zs, rsqgn_kind); the kind shows on the grenade itself, its skin recoloured
// the WIDE BAND way (tools/gen_kinds.py, MODELDEF.kinds.txt). What a kind does happens where the frag's blast happens
// (RSQGN_Thrown.Blast), from these.
class RSQGN_Kind play
{
	enum EKind { FRAG = 0, IMPACT, INCENDIARY, FREEZE, STUN, SMOKE, FLASH, CHARM, INFIGHT, COUNT }

	static String Node(int k)
	{
		static const String N[] = { "", "Impact", "Incendiary", "Freeze", "Stun", "Smoke", "Flash", "Charm", "Infight" };
		return N[clamp(k, 0, COUNT - 1)];
	}
	static Name HeldSprite(int k)
	{
		static const Name S[] = { 'QGNH', 'QGK1', 'QGK2', 'QGK3', 'QGK4', 'QGK5', 'QGK6', 'QGK7', 'QGK8' };
		return S[clamp(k, 0, COUNT - 1)];
	}
	static Name ThrownSprite(int k)
	{
		static const Name S[] = { 'QGNT', 'QGT1', 'QGT2', 'QGT3', 'QGT4', 'QGT5', 'QGT6', 'QGT7', 'QGT8' };
		return S[clamp(k, 0, COUNT - 1)];
	}
	static bool Owns(Actor who, int k) { return k == FRAG || (k > 0 && k < COUNT && RSQGN_Upg.Lv(who, Node(k)) >= 1); }
	static int Next(Actor who, int k)
	{
		for (int i = 1; i <= COUNT; i++) { int c = (k + i) % COUNT; if (Owns(who, c)) return c; }
		return FRAG;
	}
	// the share of the frag's blast damage a kind does
	static double DamageShare(Actor by, int k)
	{
		if (k == STUN) return 0.5;
		if (k == FREEZE || k >= SMOKE) return 0;
		if (k == IMPACT) { int lv = RSQGN_Upg.Lv(by, "Impact"); return lv >= 2 ? RSQGN_Upg.Num("Impact.mult", lv, 1.0) : 1.0; }
		return 1.0;
	}
	// the frag's own fireball (frag, impact, incendiary); the rest have their own look
	static bool Fireball(int k) { return k == FRAG || k == IMPACT || k == INCENDIARY; }

	// THE LOOK AND THE SOUND of a blast, by kind (the thrown grenade's Boom and the one in the hand)
	static void Look(Actor at, int k)
	{
		at.A_AlertMonsters();
		if (Fireball(k))
		{
			at.A_StartSound("rsqgn/explode", CHAN_AUTO);
			at.A_StartSound("rsqgn/farexpl", CHAN_7);
			at.A_SpawnItemEx("RSQGN_Blast", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
			return;
		}
		static const int COL[] = { 0, 0, 0, 0x46BEFF, 0xAA50FF, 0x8C8C96, 0xFFFFFF, 0xFF6EBE, 0xFF3C3C };
		static const double PITCH[] = { 1, 1, 1, 1.5, 0.6, 1.3, 1.8, 1.2, 0.9 };
		at.A_StartSound("rsqgn/explode", CHAN_AUTO, 0, k == SMOKE ? 0.35 : 0.6, ATTN_NORM, PITCH[k]);
		if (k == FLASH) at.A_SpawnItemEx("RSQGN_BlastFlareSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		Burst(at, COL[k], k == FLASH ? 60 : 36);
	}

	// a ring of coloured sparks, the kind's colour (STUN's ring, FREEZE's frost, CHARM's pink, INFIGHT's red)
	static void Burst(Actor at, int rgb, int n)
	{
		FSpawnParticleParams pp;
		pp.color1 = rgb; pp.style = STYLE_None; pp.flags = SPF_FULLBRIGHT; pp.lifetime = 24;
		pp.size = 6; pp.sizestep = -0.15; pp.startalpha = 0.9; pp.fadestep = -1;
		pp.startroll = 0; pp.rollvel = 0; pp.rollacc = 0;
		for (int i = 0; i < n; i++)
		{
			double a = i * 360.0 / n;
			pp.pos = at.pos + (0, 0, 8);
			pp.vel = (cos(a) * 6, sin(a) * 6, frandom[RSQGN_Fx](-0.5, 1.5));
			pp.accel = -pp.vel * 0.04;
			at.Level.SpawnParticle(pp);
		}
	}

	// the monsters inside r of at that it can see (bosses too: each kind decides)
	static void Inside(Actor at, double r, out Array<Actor> found)
	{
		found.Clear();
		let it = BlockThingsIterator.Create(at, r);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || !t.bIsMonster || !t.bShootable || t.health <= 0) continue;
			if (at.Distance3D(t) > r + t.radius) continue;
			if (!at.CheckSight(t, SF_IGNOREVISIBILITY)) continue;
			found.Push(t);
		}
	}

	static void LoseTarget(Actor t)
	{
		if (!t) return;
		t.target = null;
		t.LastHeard = null;
		t.LastEnemy = null;
	}

	// WHAT A KIND DOES at its blast (once). r: the blast's radius (Big Bang's share in it).
	static void Effect(Actor at, Actor by, int k, double r)
	{
		if (k == FRAG || k == IMPACT) return;
		int lv = RSQGN_Upg.Lv(by, Node(k));
		if (lv <= 0) lv = 1;
		double m = RSQGN_Geo.Vu();
		let gb = RSQGN_Upg.Svc();
		Array<Actor> hit;
		if (k == INCENDIARY)
		{
			let f = RSQGN_FireField(Actor.Spawn("RSQGN_FireField", at.pos, ALLOW_REPLACE));
			if (f) { f.target = by; f.radius2 = r; f.left = (3 + lv) * TICRATE; Claim(f, by); }
			return;
		}
		if (k == SMOKE)
		{
			let s = RSQGN_Smoke(Actor.Spawn("RSQGN_Smoke", at.pos, ALLOW_REPLACE));
			if (s) { s.target = by; s.cloud = m * (3 + lv) / 2.0; s.left = (8 + 4 * lv) * TICRATE; }
			return;
		}
		Inside(at, r, hit);
		for (int i = 0; i < hit.Size(); i++)
		{
			let t = hit[i];
			if (!t || t.health <= 0) continue;
			if (k == FREEZE)
			{
				// RSQ_Dazed's freeze (the Frost Fist's; a boss slowed by half), and the next hard hit shatters it, x2
				if (gb) gb.GetInt("freeze", "", (2 + lv) * TICRATE, 2.0, t);
				RSQGN_Upg.Touch("freeze.nade", by, t);
			}
			else if (k == STUN)
			{
				if (gb) gb.GetInt("stagger", "", (2 + lv) * TICRATE, 0, t);
				RSQGN_Upg.Touch("stun.nade", by, t);
			}
			else if (k == FLASH)
			{
				if (gb) gb.GetInt("stagger", "", (2 + lv) * TICRATE, 0, t);
				LoseTarget(t);
				RSQGN_Upg.Touch("flash", by, t);
			}
			else if ((k == CHARM || k == INFIGHT) && !t.bBoss)
			{
				Class<Inventory> tc = k == CHARM ? "RSQGN_Charmed" : "RSQGN_Infight";
				let c = RSQGN_Turned(t.FindInventory(tc));
				if (!c) c = RSQGN_Turned(t.GiveInventoryType(tc));
				if (c) c.Turn(by, (10 + 5 * lv) * TICRATE);
				RSQGN_Upg.Touch(k == CHARM ? "charm" : "infight", by, t);
			}
		}
	}

	// paid to the thrower's grenade, as the thrown grenade is (hand.zs Throw)
	static void Claim(Actor a, Actor by)
	{
		let gw = by ? by.FindInventory("RSQGN_Grenade") : null;
		if (!gw || !a) return;
		a.master = gw;
		let gb = RSQGN_Upg.Svc();
		if (gb) gb.GetInt("claim", "", 0, 0, a);
	}
}

// INCENDIARY: fire over the blast's radius for 3 + a level seconds, 5 a second to every monster standing in it
// (monsters only: the blast itself already hurts its thrower). Its look is the pack's own flames, a few at a time.
class RSQGN_FireField : Actor
{
	double radius2;
	int left;
	Default { +NOBLOCKMAP +NOGRAVITY +NOINTERACTION +DONTSPLASH DamageType "Fire"; Obituary "%o was burnt by %k's grenade"; }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || IsFrozen()) return;
		if (--left <= 0) { Destroy(); return; }
		if (left % 4 == 0)
		{
			double a = frandom[RSQGN_Fx](0, 360), d = sqrt(frandom[RSQGN_Fx](0, 1)) * radius2;
			A_SpawnItemEx("RSQGN_BlastFlamesMedium", cos(a) * d, sin(a) * d, 2, 0, 0, frandom[RSQGN_Fx](0.5, 1.5), 0, SXF_NOCHECKPOSITION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE);
		}
		if (left % 7 != 0) return;
		let it = BlockThingsIterator.Create(self, radius2);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || !t.bIsMonster || !t.bShootable || t.health <= 0) continue;
			if ((t.pos.xy - pos.xy).Length() > radius2 + t.radius || abs(t.pos.z - pos.z) > 48) continue;
			t.DamageMobj(self, target, 1, 'Fire');
			RSQGN_Upg.Touch("fire.nade", target, t);
		}
	}
	States { Spawn: TNT1 A -1; Stop; }
}

// SMOKE (the owner's pick, 11-02: "lose target", and "be sure to smartly optimize smoke"): one cloud; every half second
// one blockmap pass over the cloud and the ground around it -- a monster inside the cloud, or one whose line to its
// target crosses it, loses that target; a couple of the pack's smoke puffs a pass. Nothing runs per tic but a count.
class RSQGN_Smoke : Actor
{
	double cloud;		// its radius, map units
	int left;
	const REACH = 1536.0;	// how far round the cloud a monster's line can cross it
	Default { +NOBLOCKMAP +NOGRAVITY +NOINTERACTION +DONTSPLASH }
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || IsFrozen()) return;
		if (--left <= 0) { Destroy(); return; }
		if (left % 17 != 0) return;
		for (int i = 0; i < 2; i++)
		{
			double a = frandom[RSQGN_Fx](0, 360), d = sqrt(frandom[RSQGN_Fx](0, 1)) * cloud;
			A_SpawnItemEx("RSQGN_BlastSmoke", cos(a) * d, sin(a) * d, frandom[RSQGN_Fx](4, 40), 0, 0, 0.3, 0, SXF_NOCHECKPOSITION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE);
		}
		let it = BlockThingsIterator.Create(self, REACH);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || !t.bIsMonster || t.health <= 0 || !t.target) continue;
			if (Blinds(t)) { RSQGN_Kind.LoseTarget(t); RSQGN_Upg.Touch("smoke", target, t); }
		}
	}
	// inside the cloud, or its line to its target passes through it (across the ground)
	bool Blinds(Actor t)
	{
		Vector2 c = pos.xy;
		if ((t.pos.xy - c).Length() <= cloud + t.radius) return true;
		Vector2 a = t.pos.xy, b = t.target.pos.xy;
		Vector2 ab = b - a;
		double l2 = ab dot ab;
		if (l2 < 1) return false;
		double u = ((c - a) dot ab) / l2;
		if (u <= 0 || u >= 1) return false;
		return (a + ab * u - c).Length() <= cloud;
	}
	States { Spawn: TNT1 A -1; Stop; }
}

// CHARM and INFIGHT: a monster turned for a while. The base keeps the clock; each says what turning means.
class RSQGN_Turned : Inventory
{
	int left;
	int byPn;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
	virtual void Turn(Actor by, int tics) { left = max(left, tics); byPn = (by && by.player) ? by.PlayerNumber() : -1; }
	virtual void Undo() {}
	virtual void Keep() {}
	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner) return;
		if (owner.health <= 0 || --left <= 0) { Undo(); Destroy(); return; }
		if (left % 17 == 0) Keep();
	}
	// the nearest other live monster (not a friend), for INFIGHT and for a charmed one with nothing to fight
	Actor Nearest(double r = 1536)
	{
		Actor best = null;
		double bd = r;
		let it = BlockThingsIterator.Create(owner, r);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || t == owner || !t.bIsMonster || !t.bShootable || t.health <= 0 || t.bFriendly) continue;
			double d = owner.Distance3D(t);
			if (d < bd && owner.CheckSight(t)) { bd = d; best = t; }
		}
		return best;
	}
}

// CHARM: it fights for you for 10 + 5 s a level (friendly, on your side), then turns back. Bosses are immune.
class RSQGN_Charmed : RSQGN_Turned
{
	bool wasFriendly;
	int wasFriendPlayer;
	bool turned;
	override void Turn(Actor by, int tics)
	{
		Super.Turn(by, tics);
		if (turned || !owner) return;
		turned = true;
		wasFriendly = owner.bFriendly;
		wasFriendPlayer = owner.FriendPlayer;
		owner.bFriendly = true;
		owner.FriendPlayer = byPn + 1;
		RSQGN_Kind.LoseTarget(owner);
		Keep();
	}
	override void Keep()
	{
		if (owner && (!owner.target || owner.target.health <= 0 || owner.target.player)) owner.target = Nearest();
	}
	override void Undo()
	{
		if (!owner) return;
		owner.bFriendly = wasFriendly;
		owner.FriendPlayer = wasFriendPlayer;
		RSQGN_Kind.LoseTarget(owner);
	}
}

// INFIGHT: it turns on the nearest other monster for 10 + 5 s a level (its target kept on it every half second). Bosses
// are immune.
class RSQGN_Infight : RSQGN_Turned
{
	override void Turn(Actor by, int tics) { Super.Turn(by, tics); Keep(); }
	override void Keep()
	{
		if (!owner) return;
		if (!owner.target || owner.target.health <= 0 || owner.target.player) { owner.target = Nearest(); owner.LastHeard = owner.target; }
	}
}
