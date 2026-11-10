// RSQ Grenade -- THE GRENADE KINDS (Gun Bonsai VR patch, GBOVR_TREES.md 4.5 Kinds; the owner's eight, 11-02). Each kind is
// an unlock on the grenade's own record; the frag is the base kind. Without the patch every kind is yours (11-03,
// rsqgn_kinds_free All Types; Frag Only: the frag alone). The holding hand's alt trigger cycles the kinds you own
// (hand.zs, rsqgn_kind; rsqgn_kind_alt off: it cycles nothing); the kind shows on the grenade itself, its skin recoloured
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
	// Owned: the frag always; at Frag Only (rsqgn_kinds_free 0) nothing else. At All Types (1, the default): WITHOUT the
	// patch (owner 11-03: "when we load grenade without GBOVR, does alt fire still toggle grenade types? can it?") every
	// kind; with the Gun Bonsai VR patch the kinds you have learned (owner 11-04 "Row can still turn it off": the row
	// still decides; learning a kind switches it back to All Types once, GBOVR's RowsOnLearn).
	static bool Owns(Actor who, int k)
	{
		if (k == FRAG) return true;
		if (k <= 0 || k >= COUNT) return false;
		let c = CVar.FindCVar("rsqgn_kinds_free");
		if (c && c.GetInt() == 0) return false;
		if (!RSQGN_Upg.On()) return true;
		return RSQGN_Upg.Lv(who, Node(k)) >= 1;
	}
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
	// each kind's colour (the owner's, GBOVR_TREES.md 4.5; the same as its skin, tools/gen_kinds.py); -1 the frag
	static int Colour(int k)
	{
		static const int C[] = { -1, 0xFF7814, 0xFFC828, 0x46BEFF, 0xAA50FF, 0x8C8C96, 0xFFFFFF, 0xFF6EBE, 0x3CDC5A };
		return (k >= 0 && k < COUNT) ? C[k] : -1;
	}

	// THE LOOK AND THE SOUND of a blast, by kind (the thrown grenade's Boom and the one in the hand).
	// GRENADE EXPLOSION (rsqgn_blast_style, owner 11-09): New -- the approved pixel-art blast (explosions.zs RSQGN_Boom:
	// its sequences, contexts, colour, light) -- or Original, the UAC Survival Pack's (blast.zs RSQGN_Blast). The look
	// only: the damage is thrown.zs Blast either way. The new blast plays where the kind has a fireball today (frag,
	// impact, incendiary); with Explosion Colour: Grenade Kind it plays on every kind, in the kind's colour, beside the
	// kind's own effect.
	static void Look(Actor at, int k, Actor by = null)
	{
		at.A_AlertMonsters();
		bool newBlast = RSQGN_Fx.NewGrenade();
		if (newBlast && (Fireball(k) || RSQGN_Fx.ColourMode() == 3)) RSQGN_Boom.ForGrenade(at, k);
		if (Fireball(k))
		{
			if (RSQGN_Fx.Kinetic(false))
			{
				// Kinetic (owner 11-10, "switch rocket and grenade"): a boom a touch low with a low copy under it, and three pops
				at.A_StartSound("rsqgn/k/boom", CHAN_AUTO, 0, 1.0, ATTN_NORM, 0.92);
				at.A_StartSound("rsqgn/k/boom", CHAN_AUTO, CHANF_OVERLAP, 0.55, ATTN_NORM, 0.68);
				RSQGN_Pops.Go(at.pos, 3, 2, 3, 0.8);
			}
			else at.A_StartSound("rsqgn/explode", CHAN_AUTO);
			at.A_StartSound("rsqgn/farexpl", CHAN_7);
			if (!newBlast) at.A_SpawnItemEx("RSQGN_Blast", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
			// BIG BANG: a bigger fireball over the frag's, and the blast's low end (RS Combat FX RSI9, RS Ballistics big1)
			int bb = RSQGN_Upg.Lv(by, "BigBang");
			if (bb > 0)
			{
				let b = Actor.Spawn("RSQGN_BigBlast", at.pos + (0, 0, 24));
				if (b) b.A_SetScale(1.0 + 0.3 * bb);
				at.A_StartSound("rsqgn/fx/bigbang", CHAN_6, CHANF_OVERLAP, 1.0, 0.5);
			}
			return;
		}
		static const int COL[] = { 0, 0, 0, 0x46BEFF, 0xAA50FF, 0x8C8C96, 0xFFFFFF, 0xFF6EBE, 0xFF3C3C };
		// each kind's own sound (RS Ballistics, RS Combat FX: tools/fxpull.py)
		if (k == FREEZE) at.A_StartSound("rsqgn/fx/freeze", CHAN_AUTO);
		else if (k == STUN) at.A_StartSound("rsqgn/fx/stun", CHAN_AUTO, 0, 1.0, ATTN_NORM, 0.8);
		else if (k == SMOKE) at.A_StartSound("rsqgn/fx/smoke", CHAN_AUTO);
		else if (k == FLASH) at.A_StartSound("rsqgn/fx/flash", CHAN_AUTO, 0, 1.0, ATTN_NORM, 1.5);
		else at.A_StartSound("rsqgn/fx/turn", CHAN_AUTO);
		if (k == FLASH) { at.A_SpawnItemEx("RSQGN_Bloom", 0, 0, 24, 0, 0, 0, 0, SXF_NOCHECKPOSITION); at.A_SpawnItemEx("RSQGN_BlastFlareSpawner", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION); }
		if (k == FREEZE) for (int i = 0; i < 4; i++) at.A_SpawnItemEx("RSQGN_FrostBurst", frandom[RSQGN_Fx](-32, 32), frandom[RSQGN_Fx](-32, 32), frandom[RSQGN_Fx](8, 40), 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		if (k == CHARM || k == INFIGHT)
			for (int i = 0; i < 5; i++)
			{
				let hz = Actor.Spawn("RSQGN_Haze", at.pos + (frandom[RSQGN_Fx](-64, 64), frandom[RSQGN_Fx](-64, 64), frandom[RSQGN_Fx](8, 48)));
				if (hz) hz.SetShade(COL[k]);
			}
		if (k != SMOKE) Burst(at, COL[k], k == FLASH ? 60 : 36);
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
	// `by` is the thrower (his levels shape it); what the effect leaves behind hurts as the blast's own source, at.target:
	// the shooter's when another player's shot set the grenade off (0.99a item 50: the shooter gets the kill)
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
			at.A_StartSound("rsqgn/fx/fire", CHAN_AUTO);
			let f = RSQGN_FireField(Actor.Spawn("RSQGN_FireField", at.pos, ALLOW_REPLACE));
			if (f) { f.target = at.target ? at.target : by; f.radius2 = r; f.left = (3 + lv) * TICRATE; Claim(f, by); }
			return;
		}
		if (k == SMOKE)
		{
			let s = RSQGN_Smoke(Actor.Spawn("RSQGN_Smoke", at.pos, ALLOW_REPLACE));
			if (s) { s.target = at.target ? at.target : by; s.cloud = m * (3 + lv) / 2.0; s.left = (8 + 4 * lv) * TICRATE; }
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
				else RSQGN_Daze.Freeze(t, (2 + lv) * TICRATE);	// without the patch: this mod's own (no shatter)
				RSQGN_Upg.Touch("freeze.nade", by, t);
			}
			else if (k == STUN)
			{
				if (gb) gb.GetInt("stagger", "", (2 + lv) * TICRATE, 0, t);
				else RSQGN_Daze.Stagger(t, (2 + lv) * TICRATE);
				RSQGN_Upg.Touch("stun.nade", by, t);
			}
			else if (k == FLASH)
			{
				if (gb) gb.GetInt("stagger", "", (2 + lv) * TICRATE, 0, t);
				else RSQGN_Daze.Stagger(t, (2 + lv) * TICRATE);
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

// FREEZE AND STAGGER WITHOUT THE GUN BONSAI VR PATCH (11-03, "Grenade Types Without Gun Bonsai": All Types). With the
// patch, Freeze, Stun and Flash ask its RSQ_Dazed ("freeze", "stagger"); without it they would do nothing, so they do
// this much here: FROZEN, nothing it does goes anywhere for the time (the engine's freezetics) in the Ice translation;
// STAGGERED, held in its pain frames for the time (a monster without a Pain state is held still). Bosses are not
// frozen or staggered (the patch slows them instead; that stays the patch's). No shatter without the patch.
class RSQGN_Daze : Inventory
{
	int frozenUntil, reelUntil;
	bool tinted;
	TranslationID oldTrans;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }

	static RSQGN_Daze On(Actor t)
	{
		if (!t || t.health <= 0 || !t.bIsMonster || t.bBoss) return null;
		let d = RSQGN_Daze(t.FindInventory("RSQGN_Daze"));
		if (!d) d = RSQGN_Daze(t.GiveInventoryType("RSQGN_Daze"));
		return d;
	}
	static void Freeze(Actor t, int tics)
	{
		let d = On(t);
		if (!d || tics <= 0) return;
		d.frozenUntil = max(d.frozenUntil, level.maptime + tics);
		t.freezetics = max(t.freezetics, tics);
		if (!d.tinted) { d.oldTrans = t.Translation; t.A_SetTranslation('Ice'); d.tinted = true; }
	}
	static void Stagger(Actor t, int tics)
	{
		let d = On(t);
		if (!d || tics <= 0) return;
		d.reelUntil = max(d.reelUntil, level.maptime + tics);
	}
	override void DoEffect()
	{
		Super.DoEffect();
		let t = owner;
		if (!t) return;
		if (t.health <= 0) { frozenUntil = reelUntil = 0; }
		if (tinted && level.maptime >= frozenUntil) { t.Translation = oldTrans; tinted = false; }
		if (level.maptime < reelUntil && level.maptime >= frozenUntil)
		{
			let pain = t.FindState("Pain");
			if (!pain) t.freezetics = max(t.freezetics, 2);
			else if (!t.InStateSequence(t.CurState, pain)) t.SetState(pain);
		}
	}
}

// INCENDIARY: fire over the blast's radius for 3 + a level seconds, 5 a second to every monster standing in it
// (monsters only: the blast itself already hurts its thrower). Its look is the pack's own flames, a few at a time.
// YOUR OWN FIRE (owner 11-02: "in bd22, fire hurts you, but in vanilla, it should not ... an option to toggle"):
// rsqgn_fire_self 0 Auto -- the burning ground hurts players too when Brutal Doom is loaded (its ExplosiveBarrel1,
// the class RSQ DistanceGrab's policy.zs found in brutal22test6) or BD22 VR Reloaded (RSQ_HandTone); 1 always; 2 never.
class RSQGN_FireRule play
{
	static bool SelfBurns()
	{
		let c = CVar.FindCVar("rsqgn_fire_self");
		int v = c ? c.GetInt() : 0;
		if (v == 1) return true;
		if (v == 2) return false;
		// looked up from Strings at run time: a quoted class name is resolved at compile time and fails without that mod
		String n1 = "ExplosiveBarrel1", n2 = "RSQ_HandTone";
		Class<Actor> bd = n1, bdvr = n2;
		return bd != null || bdvr != null;
	}
}

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
			A_SpawnItemEx("RSQGN_Flame", cos(a) * d, sin(a) * d, 2, 0, 0, frandom[RSQGN_Fx](0.3, 0.8), 0, SXF_NOCHECKPOSITION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE);
		}
		if (left % 7 != 0) return;
		bool selfToo = RSQGN_FireRule.SelfBurns();
		let it = BlockThingsIterator.Create(self, radius2);
		while (it.Next())
		{
			let t = it.thing;
			if (!t || !t.bShootable || t.health <= 0) continue;
			if (!t.bIsMonster && !(t.player && selfToo)) continue;
			if ((t.pos.xy - pos.xy).Length() > radius2 + t.radius || abs(t.pos.z - pos.z) > 48) continue;
			t.DamageMobj(self, target, 1, 'Fire');
			if (t.bIsMonster) RSQGN_Upg.Touch("fire.nade", target, t);
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
		for (int i = 0; i < 3; i++)	// three a pass, a dozen alive at most (each lives 60 tics)
		{
			double a = frandom[RSQGN_Fx](0, 360), d = sqrt(frandom[RSQGN_Fx](0, 1)) * cloud;
			A_SpawnItemEx("RSQGN_Puff", cos(a) * d, sin(a) * d, frandom[RSQGN_Fx](8, 48), 0, 0, 0.2, 0, SXF_NOCHECKPOSITION | SXF_ABSOLUTEPOSITION | SXF_ABSOLUTEANGLE);
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

// ---- THE KINDS' OWN ART (RS Combat FX, pulled by tools/fxpull.py) -------------------------------------------------
class RSQGN_FxBase : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +FORCEXYBILLBOARD RenderStyle "Add"; }
}
// a bomblet's small blast (RSE1)
class RSQGN_SmallBlast : RSQGN_FxBase
{
	Default { Scale 0.7; }
	States { Spawn: QGB1 ABCDEFGHIJKLMNOPQRSTUVWXY 1 Bright; Stop; }
}
// Big Bang's fireball over the frag's (RSI9), scaled by its level at the blast
class RSQGN_BigBlast : RSQGN_FxBase
{
	Default { Scale 1.2; Alpha 0.9; }
	States { Spawn: QGBB EFGHIJKLMNO 2 Bright; Stop; }
}
// Freeze's frost burst (ICEY)
class RSQGN_FrostBurst : RSQGN_FxBase
{
	Default { Scale 4.0; }
	States { Spawn: QGIC ABCFGHI 3 Bright; Stop; }
}
// Incendiary's flames on the burning ground (RSI3)
class RSQGN_Flame : RSQGN_FxBase
{
	Default { Scale 0.6; }
	States { Spawn: QGFI ABCDEFGH 2 Bright; Stop; }
}
// Smoke's puffs (RSK3): soft, grey, a slow rise
class RSQGN_Puff : RSQGN_FxBase
{
	Default { RenderStyle "Translucent"; Alpha 0.9; Scale 2.4; }
	States { Spawn: QGCL ABCDEFGHIJKL 5; Stop; }
}
// Flash's bloom (RSH0), drawn pure white
class RSQGN_Bloom : RSQGN_FxBase
{
	Default { RenderStyle "AddStencil"; StencilColor "FF FF FF"; Scale 3.0; }
	States { Spawn: QGHF ABCDEFGHIJKLMNOPQRS 1 Bright; Stop; }
}
// Charm's and Infight's haze (RSK3 again, in the kind's colour)
class RSQGN_Haze : RSQGN_FxBase
{
	Default { RenderStyle "AddStencil"; Alpha 0.5; Scale 2.2; }
	States { Spawn: QGCL ABCDEFGHIJKL 3 Bright; Stop; }
}
