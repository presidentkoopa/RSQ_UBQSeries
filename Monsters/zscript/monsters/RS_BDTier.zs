// ============================================================================
// RS_BDTier -- Brutal Doom 22's, XMVE's and plain Doom's monsters on the colour
// ladder, IN PLACE. (Owner 2026-11-13: design/BD_XMVE_TIERING.md is the rule;
// this file builds its sections 2 to 4 and 7. Its numbers are in
// RS_BDTierData.zs, generated from design/tiering/data by tools/gen_zs.py.)
//
// THE SAME ACTOR, NEVER A NEW CLASS. A ColorfulHell colour is its own class, so
// RS_Retier swaps the body. A Brutal Doom monster keeps its body: one inventory
// item (RS_BDKit) holds its place on the ladder and sets its StartHealth, health,
// DamageMultiply, Speed, PainChance and tint, and runs the colour's behaviour.
// Brutal Doom's gore, executions, tokens and ACS checks see the class they know,
// and nothing here names a Brutal Doom class except the table of entry colours
// (strings; a class that is not loaded is simply never met).
//
// THE COLOUR. rung = entry colour + (world tier - 1) + what a fight added.
// Colour = min(13, rung); every rung past White is an EX step. A monster AT its
// entry colour is exactly as its mod ships it: no tint, no kit, every multiplier
// 1.0.
//
// THE ENTRY IS ALWAYS COMMON (owner 2026-11-13 09:57, 10:00: "0 is neutral, 1 is
// green, etc ... i told you what my order is"). Every monster as its mod ships it
// is the neutral step, and each world tier is the next colour: Common, Green,
// Blue, Purple, Cyan, Brown, Yellow, FireBlu, Gray, Red, Abyss, Black, White. No
// monster starts higher because it is stronger (this overrides the entry table of
// design/BD_XMVE_TIERING.md section 5). The ACS health-bar bosses keep "health
// curve only".
//
// BLACK AND WHITE stay different on purpose (owner 2026-11-13: "Leave them
// different"): ColorfulHell keeps its huge Black / White bosses; here they are the
// mild grade (health x1.25 and x1.5 of Abyss).
//
// THE WORLD TIER has no home yet (no turn-in code exists): it is the server cvar
// rsq_mon_worldtier, a row on the RSQ Monsters page. Raised or lowered during a
// map, every kit monster follows with the tier flash.
//
// COST. One WorldThingSpawned per actor (a cached class lookup for monsters, a
// pointer test for missiles). The kit's DoEffect is a few integer tests a tic;
// the scans (Brown's pulse, the summoner link) run once every 3 s or once a life.
// ============================================================================

class RS_BDKit : Inventory
{
	int  fam, entry, rung;
	bool hpOnly;                // an ACS health-bar boss: the health curve and the tint, nothing else
	bool helper;                // called in by a Black / White monster: never calls in turn
	int  basePain;
	TranslationID baseTrans;
	double baseMCM;             // its own missile-chance multiplier (MISSILEMORE 0.5, MISSILEEVENMORE 0.125)
	double hpF, dmF, spF;       // the factors applied right now (so every change is a ratio, and other mods' own changes stay)
	int  age;
	bool raged, call50, call25;
	bool rose;                  // Abyss: it has had its one rise
	int  phaseTics, phaseStyle;
	double phaseAlpha;
	int  nextBlink, lastPuddle, lastVolley;
	int  tintId;                // [11-13 fix 6] the tier tint it wears (Look), 0 none; a Champions tint over it is taken off
	TranslationID tierTrans;    // that tint (the tier flash puts it back between flashes: the painted frame shows none)
	int  flashTic, seenTr;      // the tier flash is running (RS_LookKeep.Hold); the last translation checked for Champions'
	bool seenChamp;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
	}

	static RS_BDKit Of(Actor a)
	{
		return a ? RS_BDKit(a.FindInventory("RS_BDKit")) : null;
	}

	int  Tier()      { return min(13, rung); }
	int  Ex()        { return max(0, rung - 13); }
	bool Active()    { return !hpOnly && rung > entry; }
	bool K(int c)    { return Active() && Tier() == c; }
	bool Boss()      { return Active() && Tier() >= 12; }
	bool Rage()      { return Active() && (Tier() == 10 || Ex() > 0); }
	bool Phase()     { return Active() && (Tier() == 11 || Ex() > 0); }
	bool Blinks()    { return Active() && (Tier() == 11 || Tier() == 13); }

	static Name TintName(int t)
	{
		switch (t)
		{
			case 2:  return 'rs_bdtier_green';
			case 3:  return 'rs_bdtier_blue';
			case 4:  return 'rs_bdtier_purple';
			case 5:  return 'rs_bdtier_cyan';
			case 6:  return 'rs_bdtier_brown';
			case 7:  return 'rs_bdtier_yellow';
			case 8:  return 'rs_bdtier_fireblu';
			case 9:  return 'rs_bdtier_gray';
			case 10: return 'rs_bdtier_red';
			case 11: return 'rs_bdtier_abyss';
			case 12: return 'rs_bdtier_black';
			case 13: return 'rs_bdtier_white';
		}
		return 'None';
	}

	// Colourful Hell's gem actors keep CH's own numbering (RS_ZombiemanFX.zs)
	static Name GemName(int t)
	{
		switch (t)
		{
			case 1:  return 'RS_ColorTierIconCH';
			case 2:  return 'RS_ColorTierIconCH2';
			case 3:  return 'RS_ColorTierIconCH3';
			case 4:  return 'RS_ColorTierIconCH4';
			case 5:  return 'RS_ColorTierIconCH12';
			case 6:  return 'RS_ColorTierIconCH13';
			case 7:  return 'RS_ColorTierIconCH5';
			case 8:  return 'RS_ColorTierIconCH7';
			case 9:  return 'RS_ColorTierIconCH8';
			case 10: return 'RS_ColorTierIconCH6';
			case 11: return 'RS_ColorTierIconCH9';
			case 12: return 'RS_ColorTierIconCH10';
			case 13: return 'RS_ColorTierIconCH11';
		}
		return 'None';
	}

	// ---- the numbers ---------------------------------------------------------------------------------------
	// Every stat is moved by the RATIO between the old factor and the new one, never set from a stored base:
	// Champions, LegenDoom and Universal Entropy change the same fields, and their share has to stay.
	void Apply(bool instant, bool first)
	{
		let o = owner;
		if (!o) return;
		int t = Tier(), ex = Ex();
		double exh = 1.0, exd = 1.0;
		for (int i = 0; i < ex; i++) { exh *= 1.10; exd *= 1.05; }

		// health (design 2.4): base x M(colour) / M(entry); every EX step +10%
		// [11-13 fix 2] health ABOVE its spawn health is kept in proportion (a LegenDoom legendary's x3, which LegenDoom
		// puts in its health and never in its StartHealth; Universal Entropy's size): it was cut back to 1x before
		double nh = RS_BDTierData.HP(fam, t) / RS_BDTierData.HP(fam, entry) * exh;
		int oldFull = o.GetSpawnHealth();
		double frac = oldFull > 0 ? max(0.05, double(o.health) / oldFull) : 1.0;
		int sh = o.StartHealth > 0 ? o.StartHealth : o.default.health;
		if (hpF <= 0) hpF = 1.0;
		o.StartHealth = max(1, int(round(sh / hpF * nh)));
		hpF = nh;
		if (o.health > 0)
		{
			int full = o.GetSpawnHealth();
			int share = max(1, int(round(full * frac)));
			o.health = (!first && RS_Retier.FullHealth(instant)) ? max(full, share) : share;
		}
		if (hpOnly) { Look(); return; }

		// damage (design 3): one curve; every EX step +5%
		double nd = RS_BDTierData.Dmg(t) / RS_BDTierData.Dmg(entry) * exd;
		if (dmF <= 0) dmF = 1.0;
		o.DamageMultiply = o.DamageMultiply / dmF * nd;
		dmF = nd;

		if (!Rage()) raged = false;
		Move();
		if (!Phase()) EndPhase();
		Look();
	}

	// speed, pain chance and the attack-rate flags: also what Rage changes when it starts
	void Move()
	{
		let o = owner;
		if (!o || hpOnly) return;
		int t = Tier();
		double ns = RS_BDTierData.Spd(fam, t) / RS_BDTierData.Spd(fam, entry);
		if (ns < 1.0) ns = 1.0;                       // design 3: never below x1.00 ...
		if (K(9)) ns = 0.8;                           // ... but the Gray kit is stone
		if (raged && Rage()) ns *= 1.4;
		if (spF <= 0) spF = 1.0;
		o.Speed = o.Speed / spF * ns;
		spF = ns;

		// Brutal Doom switches the NOPAIN flag itself (76 calls), so "no pain" is PainChance 0, never the flag
		double np = basePain * RS_BDTierData.Pain(fam, t) / RS_BDTierData.Pain(fam, entry);
		if (K(9) || Boss() || (raged && Rage())) np = 0;
		o.PainChance = Active() ? int(np) : basePain;

		o.MissileChanceMult = (raged && Rage()) ? min(baseMCM, 0.125) : baseMCM;
	}

	void Look()
	{
		let o = owner;
		if (!o) return;
		// the tier tint is the look with no painted frame; RS_BDArt.zs draws the painted frame over it where one exists
		if (rung > entry) { o.A_SetTranslation(TintName(Tier())); tintId = int(o.Translation); tierTrans = o.Translation; }
		else { o.Translation = baseTrans; tintId = 0; }
	}

	// a new place on the ladder (the flash has already run, or the change is instant)
	void SetRung(int r, bool instant)
	{
		r = max(entry, r);
		if (r == rung) return;
		rung = r;
		Apply(instant, false);
		if (Blinks() && nextBlink <= 0) nextBlink = level.maptime + random[rsbdkit](6, 10) * 35;
	}

	// ---- damage in and out ---------------------------------------------------------------------------------
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (!passive || damage <= 0 || damage >= 1000000 || !owner || !Active()) return;
		double f = 1.0;
		int t = Tier();
		bool ice = damageType == 'Ice', fire = damageType == 'Fire';
		if (t == 5)       { if (ice) f *= 0.2; else if (fire || damageType == 'Melee') f *= 1.5; }
		else if (t == 7)  { if (fire) f *= 0.5; else if (ice) f *= 1.2; }
		else if (t == 8)  { if (fire) f *= 0.25; }
		else if (t == 9)  { f *= (flags & DMG_EXPLOSION) ? 0.5 : 0.65; }
		else if (t >= 12) { f *= 0.6; }
		if (Rage() && ice) f *= 1.4;
		if (Phase())
		{
			// phased: half of what comes in passes through; every hit (re)starts the second of phase
			if (phaseTics > 0 && random[rsbdkit](0, 1) == 0) f = 0;
			BeginPhase();
		}
		if (f != 1.0) newdamage = max(0, int(damage * f));
	}

	void BeginPhase()
	{
		let o = owner;
		if (!o || o.health <= 0) return;
		if (phaseTics <= 0)
		{
			phaseStyle = o.GetRenderStyle();
			phaseAlpha = o.alpha;
			o.A_SetRenderStyle(0.35, STYLE_Translucent);
		}
		phaseTics = 35;
	}

	void EndPhase()
	{
		if (phaseTics <= 0) return;
		phaseTics = 0;
		if (owner) owner.A_SetRenderStyle(phaseAlpha, phaseStyle);
	}

	// ---- every tic, on a live monster ------------------------------------------------------------------------
	override void DoEffect()
	{
		let o = owner;
		if (!o) return;
		if (o.health <= 0) { EndPhase(); return; }
		if (level.isFrozen()) return;
		age++;
		// [11-13 fix 6, RS_Carry.zs] a Champions tint put over its tier tint (a champion's controller starting, a revive,
		// Gold's own re-tint) is taken off on the next tic; never while the tier flash runs
		int tr = int(o.Translation);
		if (tintId && tr != tintId && level.maptime - flashTic > 1)
		{
			if (tr != seenTr) { seenTr = tr; seenChamp = RS_CarryLast.IsChampTint(tr); }
			if (seenChamp)
			{
				Look();
				let h = RS_CarryLast.Get();
				if (h) h.Fixed(o, "tier tint back over a Champions tint");
			}
		}
		if (age == 1) SummonerLink();

		// the tier gem (Colourful Hell's colour-blind aid, Tier Icons Above Monsters), once a second
		if ((age % 35) == 17)
		{
			let cv = CVar.FindCVar('rs_ch_colorblind');
			if (cv && cv.GetInt() == 1)
			{
				class<Actor> g = GemName(Tier());
				if (g) o.A_SpawnItemEx(g, 0, 0, o.height + 8, random[rsbdfx](1, 4), 0, random[rsbdfx](0, 2), random[rsbdfx](0, 359), SXF_NOCHECKPOSITION);
			}
		}
		if (!Active()) return;

		if (phaseTics > 0 && --phaseTics <= 0) { phaseTics = 1; EndPhase(); }

		int t = Tier();
		if (t == 5) { if ((age % 20) == 0) Hop(); }
		else if (t == 6) { if ((age % 105) == 0) SupportPulse(); }

		if (Rage())
		{
			if (!raged && (o.health * 2 <= o.GetSpawnHealth() || o.InStateSequence(o.CurState, o.ResolveState("Pain"))))
			{
				raged = true;
				Move();
			}
			if (raged && (age & 3) == 0)
				o.A_SpawnParticle("Red", SPF_FULLBRIGHT, 14, 3, 0, frandom[rsbdfx](-o.radius, o.radius), frandom[rsbdfx](-o.radius, o.radius),
					frandom[rsbdfx](8, o.height), 0, 0, 1.5);
		}

		if (Blinks())
		{
			if (nextBlink <= 0) nextBlink = level.maptime + random[rsbdkit](6, 10) * 35;
			else if (level.maptime >= nextBlink)
			{
				// Abyss: a flanking blink every 6 to 10 s; White: every 8 to 12 s
				nextBlink = level.maptime + (t == 13 ? random[rsbdkit](8, 12) : random[rsbdkit](6, 10)) * 35;
				Blink();
			}
		}

		if (Boss() && !helper)
		{
			int full = o.GetSpawnHealth();
			if (!call50 && o.health * 2 <= full) { call50 = true; CallHelp(); }
			if (t == 13 && !call25 && o.health * 4 <= full) { call25 = true; CallHelp(); }
		}
	}

	// design 2.8: a summon takes the higher of its own colour and its summoner's. The summoner is its master, or,
	// for a Lost Soul born beside a Pain Elemental (A_PainShootSkull names no master), the nearest one within reach.
	void SummonerLink()
	{
		let o = owner;
		RS_BDKit sk = Of(o.master);
		if (!sk && fam == 7 && level.maptime > 2)
		{
			let it = BlockThingsIterator.Create(o, 128);
			while (it.Next())
			{
				let m = it.thing;
				if (!m || m == o || m.health <= 0 || !m.bISMONSTER) continue;
				let k = Of(m);
				if (k && k.fam == 8 && o.Distance3D(m) < 128) { sk = k; break; }
			}
		}
		if (sk && sk.Tier() > Tier()) SetRung(sk.Tier(), true);
	}

	// Cyan: a sideways hop when the player's aim is on it
	void Hop()
	{
		let o = owner;
		let p = o.target;
		if (!p || !p.player || p.health <= 0 || o.Distance2D(p) > 1536) return;
		double aim = p.OverrideAttackPosDir ? p.AttackAngle : p.angle;
		if (abs(Actor.deltaangle(aim, p.AngleTo(o))) > 6) return;
		if (random[rsbdkit](0, 99) >= 40 || !o.CheckSight(p)) return;
		bool air = o.bFLOAT || o.bNOGRAVITY;
		if (!air && o.pos.z > o.floorz + 1) return;
		o.Thrust(8, o.AngleTo(p) + (random[rsbdkit](0, 1) ? 90 : -90));
		if (!air) o.vel.z = 6;
	}

	// Brown: every 3 s, allies within 512 get 5% of their full health back (never itself), and the nearest gets a
	// 2 s shield that halves what it takes
	void SupportPulse()
	{
		let o = owner;
		Actor near = null;
		double nd = 1e9;
		let it = BlockThingsIterator.Create(o, 512);
		while (it.Next())
		{
			let m = it.thing;
			if (!m || m == o || m.health <= 0 || !m.bISMONSTER || m.bFRIENDLY != o.bFRIENDLY) continue;
			double d = o.Distance3D(m);
			if (d > 512) continue;
			int full = m.GetSpawnHealth();
			if (m.health < full)
			{
				m.health = min(full, m.health + max(1, full / 20));
				RS_BDFx.Burst(m, "Green", 6, 2.5);
			}
			if (d < nd) { nd = d; near = m; }
		}
		if (near)
		{
			let s = RS_BDShield(near.FindInventory("RS_BDShield"));
			if (!s) { near.GiveInventory("RS_BDShield", 1); s = RS_BDShield(near.FindInventory("RS_BDShield")); }
			if (s) s.endTic = level.maptime + 70;
		}
	}

	// Abyss and White: step out beside or behind the target
	void Blink()
	{
		let o = owner;
		let tg = o.target;
		if (!tg || tg.health <= 0 || !o.CheckSight(tg)) return;
		Vector3 old = o.pos;
		double lift = (o.bFLOAT || o.bNOGRAVITY) ? max(0, o.pos.z - o.floorz) : 0;
		for (int i = 0; i < 8; i++)
		{
			// behind or beside it first; with a wall there, anywhere around it
			double a = i < 4 ? tg.angle + 180 + frandom[rsbdkit](-70, 70) : frandom[rsbdkit](0, 360);
			double d = frandom[rsbdkit](128, 256) + o.radius + tg.radius;
			double x = tg.pos.x + cos(a) * d, y = tg.pos.y + sin(a) * d;
			double z = o.GetZAt(x, y, 0, GZF_ABSOLUTEPOS) + lift;
			o.SetOrigin((x, y, z), false);
			if (o.TestMobjLocation() && o.CheckSight(tg))
			{
				Actor.Spawn("TeleportFog", old, ALLOW_REPLACE);
				Actor.Spawn("TeleportFog", o.pos, ALLOW_REPLACE);
				o.angle = o.AngleTo(tg);
				o.vel = (0, 0, 0);
				let dc = CVar.FindCVar('rsq_mon_bdtier_debug');
				if (dc && dc.GetBool()) Console.Printf("BDTIER: %s blinked %d units, try %d", o.GetClassName(), int((o.pos - old).Length()), i);
				return;
			}
		}
		o.SetOrigin(old, false);
		let dc = CVar.FindCVar('rsq_mon_bdtier_debug');
		if (dc && dc.GetBool()) Console.Printf("BDTIER: %s found no room to blink", o.GetClassName());
	}

	// Black and White: two more of its own kind arrive beside it, at the world tier. They never call in turn.
	void CallHelp()
	{
		let o = owner;
		for (int i = 0; i < 2; i++)
		{
			for (int tries = 0; tries < 6; tries++)
			{
				double a = frandom[rsbdkit](0, 360);
				double d = o.radius * 2 + 24 + tries * 16;
				double x = o.pos.x + cos(a) * d, y = o.pos.y + sin(a) * d;
				Actor h = Actor.Spawn(o.GetClass(), (x, y, o.pos.z), NO_REPLACE);
				if (!h) continue;
				if (!h.TestMobjLocation()) { h.ClearCounters(); h.Destroy(); continue; }
				h.angle = o.angle;
				h.target = o.target;
				h.bAMBUSH = false;
				h.GiveInventory("RS_BDHelperMark", 1);
				Actor.Spawn("TeleportFog", h.pos, ALLOW_REPLACE);
				break;
			}
		}
	}
}

// a monster a Black / White one called in: RS_BDTierHandler reads it when the kit is given
class RS_BDHelperMark : Inventory
{
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}

// Brown's shield on an ally: half damage endTic `endTic`
class RS_BDShield : Inventory
{
	int endTic;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive && damage > 0 && damage < 1000000 && level.maptime < endTic) newdamage = max(1, damage / 2);
	}

	override void DoEffect()
	{
		if (!owner || level.maptime >= endTic) { Destroy(); return; }
		if ((level.maptime & 3) == 0 && owner.health > 0)
			owner.A_SpawnParticle("Tan", SPF_FULLBRIGHT, 10, 3, frandom[rsbdfx](0, 360), owner.radius, 0, frandom[rsbdfx](4, owner.height));
	}
}

// Yellow's burn on whatever its shot hit: 2 s, 2 fire damage every 10 tics. The damage names no source, so it
// starts no infight and never re-enters the hit hook.
class RS_BDBurn : Inventory
{
	int endTic;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	override void DoEffect()
	{
		let o = owner;
		if (!o || o.health <= 0 || level.maptime >= endTic) { Destroy(); return; }
		if ((level.maptime % 10) == 0) o.DamageMobj(null, null, 2, 'Fire', DMG_THRUSTLESS);
		if ((level.maptime & 1) == 0)
			o.A_SpawnParticle("Orange", SPF_FULLBRIGHT, 12, 4, 0, frandom[rsbdfx](-o.radius, o.radius), frandom[rsbdfx](-o.radius, o.radius),
				frandom[rsbdfx](0, o.height * 0.7), 0, 0, 2);
	}
}

// Cyan's slow on the player: 1 s at half speed
class RS_BDIceSlow : PowerSpeed
{
	Default
	{
		Powerup.Duration 35;
		Speed 0.5;
		+POWERSPEED.NOTRAIL
	}
}

// Red's death bolts and the Black / White death shower: the imp's fireball, in the kit's colour
class RS_BDBolt : DoomImpBall
{
	Default
	{
		Speed 14;
		Damage 3;
	}
}

// A patch on the floor: Green's acid (3 s, 5 poison damage a second to a player standing in it) or Yellow's flame
// (2 s; it sets a player alight). Drawn with particles only.
class RS_BDPatch : Actor
{
	int kind, life;      // kind 2 acid, 7 flame
	Actor src;
	Default
	{
		Radius 8;
		Height 8;
		+NOBLOCKMAP
		+NOINTERACTION
		+NOGRAVITY
	}

	static void Put(Vector3 at, Actor src, int kind)
	{
		// one patch a spot: a second one of the same kind within 40 units renews the first instead of stacking on it
		ThinkerIterator it = ThinkerIterator.Create("RS_BDPatch");
		RS_BDPatch q;
		while (q = RS_BDPatch(it.Next()))
		{
			if (q.kind != kind || (q.pos.xy - at.xy).Length() > 40 || abs(q.pos.z - at.z) > 64) continue;
			q.life = max(q.life, kind == 2 ? 105 : 70);
			q.src = src;
			return;
		}
		let p = RS_BDPatch(Actor.Spawn("RS_BDPatch", at, NO_REPLACE));
		if (!p) return;
		p.SetOrigin((at.x, at.y, p.floorz), false);
		p.kind = kind;
		p.src = src;
		p.life = kind == 2 ? 105 : 70;
	}

	override void Tick()
	{
		if (level.isFrozen()) return;
		if (--life <= 0) { Destroy(); return; }
		if ((life & 1) == 0)
			A_SpawnParticle(kind == 2 ? "Green" : "Orange", SPF_FULLBRIGHT, 16, 5, frandom[rsbdfx](0, 360), frandom[rsbdfx](0, 40), 0, 1,
				0, 0, kind == 2 ? 0.4 : 1.6);
		if ((life % 35) != 0) return;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i]) continue;
			let pm = players[i].mo;
			if (!pm || pm.health <= 0 || Distance2D(pm) > 48 + pm.radius || abs(pm.pos.z - pos.z) > 32) continue;
			if (kind == 2) pm.DamageMobj(self, null, 5, 'Poison', DMG_THRUSTLESS);
			else RS_BDFx.Ignite(pm);
		}
	}
}

// On a kit monster's shot: what it does where it lands. (An inventory item on the missile: its DoEffect runs with
// the missile's own tick and stops with it.)
class RS_BDShotMark : Inventory
{
	int kind;            // the colour whose impact this carries: 2 acid patch, 3 zap, 7 flame patch; 0 none (a twin's mark)
	bool done;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	override void DoEffect()
	{
		let m = owner;
		if (done || !m || kind == 0 || m.bMISSILE) return;
		done = true;                                  // it has hit: P_ExplodeMissile took its MISSILE flag
		if (kind == 2 || kind == 7) RS_BDPatch.Put(m.pos, m.target, kind);
		else if (kind == 3)
		{
			RS_BDFx.Burst(m, "LightBlue", 10, 3);
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				if (!playeringame[i]) continue;
				let pm = players[i].mo;
				if (pm && pm.health > 0 && m.Distance3D(pm) <= 48 + pm.radius && m.CheckSight(pm))
					pm.DamageMobj(m, null, 8, 'Plasma', DMG_THRUSTLESS);
			}
		}
	}
}

class RS_BDFx play
{
	static void Burst(Actor at, Color c, int n, double size)
	{
		if (!at) return;
		for (int i = 0; i < n; i++)
			at.A_SpawnParticle(c, SPF_FULLBRIGHT, 18, size, frandom[rsbdfx](0, 360), frandom[rsbdfx](0, at.radius), 0,
				frandom[rsbdfx](2, max(8, at.height)), frandom[rsbdfx](0.5, 2.5), 0, frandom[rsbdfx](0.5, 2.5));
	}

	static void Ignite(Actor v)
	{
		if (!v || v.health <= 0) return;
		let b = RS_BDBurn(v.FindInventory("RS_BDBurn"));
		if (!b) { v.GiveInventory("RS_BDBurn", 1); b = RS_BDBurn(v.FindInventory("RS_BDBurn")); }
		if (b) b.endTic = level.maptime + 70;
	}

	// n bolts in a ring from a dying monster, tinted to its colour
	static void Bolts(Actor from, int n, Name tint)
	{
		double a0 = frandom[rsbdfx](0, 360);
		for (int i = 0; i < n; i++)
		{
			let b = Actor.Spawn("RS_BDBolt", from.pos + (0, 0, from.height * 0.5), NO_REPLACE);
			if (!b) continue;
			b.target = from;
			b.angle = a0 + i * 360.0 / n;
			b.VelFromAngle(b.Speed);
			b.vel.z = frandom[rsbdfx](0, 3);
			if (tint != 'None') b.A_SetTranslation(tint);
			b.GiveInventory("RS_BDShotMark", 1);      // a mark with no kind: the shot hook leaves it alone
		}
	}
}

// ============================================================================
// The handler: who gets a kit, the shots, the deaths, the world tier.
// ============================================================================
class RS_BDTierHandler : EventHandler
{
	// the table (RS_BDTierData.Row), parsed once a map
	private Array<Name> rowName;
	private Array<int>  rowFam, rowEntry, rowHp;
	private bool rowsBuilt;
	// each class met, resolved once: fam * 1000 + entry * 10 + hpOnly; -1 no family; -2 exempt
	private Array<class<Actor> > seenCls;
	private Array<int> seenVal;

	private CVar cvOn, cvWorld, cvDebug;
	private int lastWorld;
	private Array<Actor> risers;
	private Array<int>   riseTic;

	bool On()       { if (!cvOn) cvOn = CVar.FindCVar('rsq_mon_bdtier'); return !cvOn || cvOn.GetBool(); }
	int  WorldTier(){ if (!cvWorld) cvWorld = CVar.FindCVar('rsq_mon_worldtier'); return cvWorld ? clamp(cvWorld.GetInt(), 1, 40) : 1; }
	bool Debug()    { if (!cvDebug) cvDebug = CVar.FindCVar('rsq_mon_bdtier_debug'); return cvDebug && cvDebug.GetBool(); }

	private void BuildRows()
	{
		rowsBuilt = true;
		rowName.Clear(); rowFam.Clear(); rowEntry.Clear(); rowHp.Clear();
		Array<String> p;
		for (int i = 0; i < RS_BDTierData.RowCount(); i++)
		{
			p.Clear();
			String r = RS_BDTierData.Row(i);
			r.Split(p, ":");
			if (p.Size() < 4) continue;
			rowName.Push(p[0]);
			rowFam.Push(p[1].ToInt());
			rowEntry.Push(p[2].ToInt());
			rowHp.Push(p[3].ToInt());
		}
	}

	// design 2.1: the family is the one it acts like: its own row, else up its parents (a row, an id class, what a
	// class replaces)
	private int Resolve(class<Actor> cls)
	{
		for (int i = 0; i < seenCls.Size(); i++) if (seenCls[i] == cls) return seenVal[i];
		if (!rowsBuilt) BuildRows();
		int val = -1;
		for (class<Actor> k = cls; k && val == -1; k = (class<Actor>)(k.GetParentClass()))
		{
			Name kn = k.GetClassName();
			if (kn == 'Actor') break;
			// a class defined twice is renamed by the engine to "name@file@lump" (XMVE's second paingasm, in
			// darkcardinalboss.txt): it is still that monster
			String ks = kn;
			int at = ks.IndexOf("@");
			if (at > 0) kn = ks.Left(at);
			for (int r = 0; r < rowName.Size(); r++)
			{
				if (rowName[r] != kn) continue;
				val = rowFam[r] < 0 ? -2 : rowFam[r] * 1000 + rowEntry[r] * 10 + rowHp[r];
				break;
			}
			if (val != -1) break;
			Name vn = 'None';
			if (RS_RosterHandler.FamilyId(kn) >= 0) vn = kn;
			else
			{
				class<Actor> rp = Actor.GetReplacee(k);
				if (rp && rp != k && RS_RosterHandler.FamilyId(rp.GetClassName()) >= 0) vn = rp.GetClassName();
			}
			if (vn != 'None')
			{
				// every monster enters at the neutral step, Common (the owner's order, see the top of this file)
				val = RS_RosterHandler.FamilyId(vn) * 1000 + 1 * 10;
			}
		}
		seenCls.Push(cls);
		seenVal.Push(val);
		return val;
	}

	override void WorldLoaded(WorldEvent e)
	{
		lastWorld = WorldTier();
	}

	// ---- THE COLOUR FOLLOWS THE BODY (owner 2026-11-13: "there are a lot of frames, gore frames, second wind things,
	// final stand things ... i am concerned with a high quality result") --------------------------------------------
	// A monster's colour is its kit's, and every frame it plays itself shows it. But Brutal Doom's deaths are full of
	// OTHER actors: the dying crawlers, the last stands, the corpses, the limbs and chunks. Each piece that came out of a
	// coloured body gets an RS_BDHue with the body's colour (RS_BDArt.zs: the painted frames where they exist, the tier
	// tint where they do not). Which body it came out of:
	//   - its master (a summoner, SXF_SETMASTER);
	//   - for a thing that is not a monster, its target: Brutal Doom throws its pieces (A_CustomMissile, A_SpawnItem) and
	//     the thrower is the new thing's target. A maker that is still there and holds no colour (a monster at its entry
	//     colour, dead or alive, or one of its pieces) gives none: its pieces never take a neighbour's colour (fault found
	//     2026-11-13: imps closer than 64 units handed each other their colour). A monster's target is its enemy, never
	//     its maker (SXF_TRANSFERPOINTERS copies the body's), so a monster piece skips this step;
	//   - its maker already removed (Brutal Doom spawns the next stage and removes itself in the same state, so by the
	//     new thing's first tick its maker is gone): the NEAREST body removed within 64 units in the last 3 tics, coloured
	//     or not (a body at its entry colour leaves a record too, so a neighbour's colour is not taken when it is nearer);
	//   - [11-13 dying-body census, rig rcF] or a body that DIED within 64 units in the last 4 s and is still there: Brutal
	//     Doom's men end a death on `TNT1 A -1` (never removed) after spawning their crawler or corpse, and a death stage
	//     can spawn its corpse seconds later (the Chaingunner's blasted, burning and headless crawlers and their corpses,
	//     the Arch-vile's armless crawler's corpse held no colour before);
	//   - a player's fatality (Brutal Doom: the monster dies and gives the player GoFatality; the PLAYER then plays the kill
	//     and throws the gore and the corpse, RapedArachnotron and its kin, as their maker): the colour of the monster that
	//     player killed last, while the player holds GoFatality and 2 tics after. The player's own fatality frames (ARF1 ...)
	//     are drawn from the art while it lasts (RS_BDFatalHue: the art only, never the tint, the player's colours put back).
	// A family monster that rises out of a body mid-map (a death stage that counts no kill, such as the Arch-vile's armless
	// crawler; or the same class born again on the spot, as Brutal Doom's taunt does: Death.Taunt spawns a fresh copy and
	// removes itself) gets the body's place on the ladder, not the world tier's (it came back as shipped before).
	// A thing named like an effect ("dust", "burn", "rifle" ...) whose states draw a sprite that has painted art is a body
	// (RevenantDust is the Revenant's painted bone dust, BurningCacodemon its own HEAD frames, the Evil Marines' "Rifle"
	// corpses): it follows the body. Blood (by its parent class) and other mods' things keep their own look always.
	// Blood (the owner's rule: blood keeps its own colour), smoke, fire, sparks, casings, puffs and pickups keep their own
	// look, by class name (below, cached per class); one that arrives wearing a tier tint (SXF_TRANSFERTRANSLATION) has
	// it taken off again. Brutal Doom's blood mist (SuperGore and its kin) was missed by the names before (2026-11-13:
	// it took the tint, and on FireBlu, Red and Gray it showed as coloured squares).
	private Array<int> tintIds;
	private Array<double> gonX, gonY, gonZ;
	private Array<int> gonCol, gonTic, gonRung;
	private Array<int> gonFam;               // the removed body's family (its kit's), -1 none
	private Array<Actor> diedA;              // bodies that died lately and may still be there (pieces' makers)
	private Array<int> diedCol, diedRung, diedTic;
	private int lastKillCol[MAXPLAYERS], lastKillTic[MAXPLAYERS], fatCol[MAXPLAYERS], fatSeen[MAXPLAYERS];
	private bool fatOn[MAXPLAYERS];
	private transient class<Inventory> fatTok;
	private transient bool fatTokRead;
	const DIED_TICS = 140;
	private Map<Name, int> ownLook;          // class -> 1 keeps its own look, 0 follows the body
	private Map<Name, int> logged;           // debug: classes already logged this map

	// which of the twelve tints a translation is: its colour 2..13, 0 none
	private int OurTint(int tr)
	{
		if (tr == 0) return 0;
		if (tintIds.Size() == 0)
			for (int c = 2; c <= 13; c++) tintIds.Push(int(Translation.GetID(RS_BDKit.TintName(c))));
		for (int i = 0; i < tintIds.Size(); i++) if (tintIds[i] == tr) return i + 2;
		return 0;
	}

	// an effect or a pickup, by its class name (cached per class): it keeps its own colours. Partly by WORDS, not only by
	// substrings: "gun" in DeadChaingunGuy, "ring" in SmearingXDeath, "explo" in ImpHeadExplode (a gore group) made bodies
	// and gore keep their own look before (found 2026-11-13). Checked against every BD22 + XMVE class name (rig tool
	// Monsters/tools/recolour/rig/ownlook_names.py).
	//   another mod's (champion_, LD, RSQ, RS_, SSQ, UE_ at the start of the name);
	//   anywhere in the name: blood, gore, mist, smoke, flame, spark, puff, particle, explosion, bullet, ...
	//   a word that starts so: fire, light, shell, water, dust, trail, ring, burn, drop, rifle, ammo, clip, mag, ...
	//   a word holding "gun" (shotgun, chaingun) when no word names a body (guy, gunner, zombie, dead, head, arm, ...):
	//   FakeChaingunSprite and ChaingunDrop keep their look, DeadChaingunGuy follows the body
	private bool KeepsOwnLook(Actor a)
	{
		if (a is "Inventory") return true;
		Name cn = a.GetClassName();
		int v; bool ok;
		[v, ok] = ownLook.CheckValue(cn);
		if (ok) return v != 0;
		v = OwnLookName(cn) ? 1 : 0;
		// and anything a blood class is the parent of, named so or not
		bool blood = false;
		for (class<Actor> k = a.GetClass(); k; k = (class<Actor>)(k.GetParentClass()))
		{
			String kn = k.GetClassName();
			if (kn ~== "Actor") break;
			if (kn ~== "Blood" || kn ~== "SuperGore" || kn ~== "BloodMist") { v = 1; blood = true; break; }
		}
		// [11-13 census] named like an effect, but its states draw painted body art: a body (see "the colour follows the body")
		// (never blood, mist or gore by name, nor fire, smoke and the other effects: Brutal Doom's blood mist draws the gore
		// sprites XDT1 that the gore pass painted; the owner's rule keeps blood its own colour)
		if (v && !blood && !OtherModName(cn) && !EffectName(cn) && RS_BDArt.Get().ClassHasArt(a)) v = 0;
		ownLook.Insert(cn, v);
		return v != 0;
	}

	static bool OwnLookName(String n)
	{
		// [11-13] + "crater" (BD's floor and ceiling craters, DetectFloorCraterSmall), "shard" (MetalShard1-3, CrashMetalShards),
		// words "junk" (XJunk1-5: machine scrap) and "metal": not a body (the gore pass's census, commit c1db29d98b);
		// "icechunk" (XIceChunk1-3, the ice of a shattered frozen body: ice keeps its own, as in the family files)
		static const String SUB[] = { "blood", "gore", "smearer", "smoke", "flame", "flare", "spark", "puff", "tracer", "casing",
			"plasma", "splash", "steam", "brass", "fog", "particle", "flashlight", "shrapnel", "explosion", "bullet", "mist",
			"crater", "shard", "icechunk" };
		static const String WORD[] = { "fire", "light", "shell", "water", "dust", "trail", "shock", "ring", "ember", "burn", "drop",
			"rifle", "weapon", "ammo", "clip", "mag", "junk", "metal" };
		static const String BODYW[] = { "guy", "gunner", "zombie", "man", "marine", "dead", "head", "gib", "death", "half", "dying",
			"frozen", "major", "soldier", "trooper", "corpse", "body", "torso", "arm", "leg", "grabbed", "throwed", "punched", "execute" };
		if (OtherModName(n)) return true;
		String low = n.MakeLower();
		for (int i = 0; i < SUB.Size(); i++) if (low.IndexOf(SUB[i]) >= 0) return true;
		String w = " " .. Words(n) .. " ";
		for (int i = 0; i < WORD.Size(); i++) if (w.IndexOf(" " .. WORD[i]) >= 0) return true;
		Array<String> ws;
		w.Split(ws, " ", TOK_SKIPEMPTY);
		bool gun = false, isBody = false;
		for (int i = 0; i < ws.Size(); i++)
		{
			if (ws[i].IndexOf("gun") >= 0) gun = true;
			for (int j = 0; j < BODYW.Size() && !isBody; j++) if (ws[i].IndexOf(BODYW[j]) >= 0) isBody = true;
		}
		return gun && !isBody;
	}

	// other mods' things that ride on a monster (Champions' icons, leaves and balloons, LegenDoom's, Universal Entropy's,
	// the series' own): never a piece of its body (rig rcE_p3: Champions' icons took the tier tint through their master)
	// [11-13] and Legion of Bones' classes by name (in his order; it has no prefix): its risers (SkullZombieSpawn and
	// kin: a skeleton climbing out of a corpse, then its own monster, which gets its own kit if it has a family), its
	// bones, fire and shots: another mod's, never a piece of the body it rises from
	static bool OtherModName(String n)
	{
		static const String MODS[] = { "champion_", "ld", "rsq", "rs_", "ssq", "ue_" };
		static const String LOB[] = {
			"Abhorrent", "AbhorrentShot", "AbhorrentShotTrail", "AbhorrentSpawn", "AbhorrentSpawner", "Arachnobone", "ArachnoboneShot", "ArachnoboneSpawn",
			"ArachnoboneSpawner", "Balrog", "BalrogBall", "BalrogBuffEffectSpawner", "BalrogFire", "BalrogFireBuffEffect", "BalrogFireGiver", "BalrogFireSpawner",
			"BalrogSpawn", "BalrogSpawner", "BloodSpitTrail", "Bone", "Bone1", "Bone2", "BoneGib", "CacoLich",
			"CacoLichBall", "CacoLichFlame", "CacoLichSpawn", "CacoLichSpawner", "ChaingunnerSkull", "ConqCountdown", "ConqCube", "ConqCubeShot",
			"ConqMiniNuke", "ConqNuke", "ConqRailPow", "ConqRailShot", "ConqRailTrail", "ConqSpawnCube", "Conqueror", "ConquerorSpawn",
			"ConquerorSpawner", "DragonSoul", "DragonSoulFlame", "DragonSoulSpawner", "FakeGhostSpectre", "GhostBlood", "GhostSpectre", "GhostSpectreSpawn",
			"GhostSpectreSpawner", "GhostSpectreTrail1", "GhostSpectreTrail2", "GhostSpectreTrail3", "GhostSpectreTrail4", "HotHead", "InfightController", "LOBArachnotron",
			"LOBArchvile", "LOBBaronOfHell", "LOBCacodemon", "LOBChaingunGuy", "LOBDeadDoomImp", "LOBDeadShotgunGuy", "LOBDeadZombieMan", "LOBDemon",
			"LOBDoomImp", "LOBHellKnight", "LOBLostSoul", "LOBMancubus", "LOBRevenant", "LOBShotgunGuy", "LOBSpectre", "LOBSpiderMastermind",
			"LOBZombieMan", "MonsterTracer", "Painbringer", "PainbringerSpawner", "PhantomRevenant", "PhantomRevenant2", "PhantomRevenantSpawn", "PhantomRevenantSpawner",
			"PhantomRevenantTrail1", "PhantomRevenantTrail2", "PhantomRevenantTrail3", "PhantomRevenantTrail4", "PhantomRevenantTrail5", "PhantomRevenantTrail6", "PowerBalrogFireBuff", "PowerBalrogFireBuffGiver",
			"Reaper", "ReaperBloodSkull", "ReaperBloodSkullGiver", "ReaperBloodSkullSpawner", "ReaperBloodSpit", "ReaperFire", "ReaperFireStart", "ReaperFireTrail",
			"ReaperSpawn", "ReaperSpawner", "ReaperStealthFire", "RetroSkeleton", "RetroSkeletonFlame", "RetroSkeletonSpawner", "SKFlameTrail", "SkeletonDemon",
			"SkeletonDemonSpawn", "SkeletonDemonSpawner", "SkeletonImp", "SkeletonImpArm", "SkeletonImpBall", "SkeletonImpLeg", "SkeletonImpSpawn", "SkeletonImpSpawner",
			"SkullBloodDrip", "SkullChaingunner", "SkullChaingunnerSpawn", "SkullChaingunnerSpawner", "SkullChaingunnerTracer", "SkullShotgunner", "SkullShotgunnerSpawn", "SkullShotgunnerSpawner",
			"SkullShotgunnerTracer", "SkullZombie", "SkullZombieSpawn", "SkullZombieSpawner", "SkullZombieTracer", "SlayerKnight", "SlayerKnightFlame", "SlayerKnightFlame2",
			"SlayerKnightSpawn", "SlayerKnightSpawner", "SoulBallHoming", "SoulBallNormal", "SoulTrail", "Tracer", "UndeadSpawnFire", "ZombieTracer" };
		String low = n.MakeLower();
		for (int i = 0; i < MODS.Size(); i++) if (low.Left(MODS[i].Length()) == MODS[i]) return true;
		for (int i = 0; i < LOB.Size(); i++) if (n ~== LOB[i]) return true;
		return false;
	}

	// blood, mist, gore, fire and the effects by name: never taken for a body by the art test above
	static bool EffectName(String n)
	{
		static const String FX[] = { "blood", "mist", "gore", "smearer", "smoke", "flame", "flare", "spark", "puff", "splash",
			"steam", "fog", "particle", "explosion", "fire", "ember", "crater", "shard", "junk", "metal", "plasma", "shock", "icechunk" };
		String low = n.MakeLower();
		for (int i = 0; i < FX.Size(); i++) if (low.IndexOf(FX[i]) >= 0) return true;
		return false;
	}

	// a class name as lower-case words: a break at _ and digits, before a capital after a small letter, and before the
	// last capital of a run that a small letter follows ("BDExplosion" -> "bd explosion")
	static String Words(String n)
	{
		String w = "";
		int len = n.Length();
		for (int i = 0; i < len; i++)
		{
			int c = n.ByteAt(i);
			bool up = c >= 65 && c <= 90, lo = c >= 97 && c <= 122;
			if (!up && !lo) { w = w .. " "; continue; }
			if (up && i > 0)
			{
				int p = n.ByteAt(i - 1), q = i + 1 < len ? n.ByteAt(i + 1) : 0;
				bool pLo = p >= 97 && p <= 122, pUp = p >= 65 && p <= 90, qLo = q >= 97 && q <= 122;
				if (pLo || (pUp && qLo)) w = w .. " ";
			}
			w.AppendCharacter(up ? c + 32 : c);
		}
		return w;
	}

	// a thing's colour: its kit's or hue's; a thing with neither, its tier tint (a kit monster's tinted shot)
	private int Col(Actor m)
	{
		if (RS_BDHue.Known(m)) return RS_BDHue.ColourOf(m);
		return OurTint(int(m.Translation));
	}

	// the colour (2..13) of the body this actor came out of, 0 none
	private int TintFrom(Actor a, out String why)
	{
		let m = a.master;
		if (m && m != a) { int c = Col(m); if (c) { why = "master " .. m.GetClassName(); return c; } }
		let t = a.target;
		// (a maker that is itself an effect, blood or a pickup is no authority: its pieces go by where they stand)
		if (t && t != a && !a.bISMONSTER && !t.player && !(RS_BDHue.ColourOf(t) == 0 && !t.bISMONSTER && KeepsOwnLook(t)))
		{
			int c = Col(t);
			why = (c ? "maker " : "maker holds none ") .. t.GetClassName();
			return c;
		}
		// across the floor, not through the air: Brutal Doom throws a body's pieces from 30 to 60 units above where it stood,
		// so a 3D distance could favour a neighbour standing 40 units to the side (rig rcE_gp, 2026-11-13)
		int best, br, bt; double bd; String bw;
		[best, br, bt, bd, bw] = NearestBody(a, true);
		if (bt >= 0) { why = String.Format("%s %d units away", bw, int(bd)); return best; }
		// no body here: a player in a fatality throws the victim's gore and corpse where the player stands, seconds after
		// the victim was removed: the victim's colour (none: the player's own things)
		if (t && t.player && !a.bISMONSTER)
		{
			int pn = t.PlayerNumber();
			if (pn >= 0 && pn < MAXPLAYERS && fatOn[pn]) { why = "fatality of a body " .. (fatCol[pn] ? RS_BDArt.COLOUR[fatCol[pn]] : "with no colour"); return fatCol[pn]; }
		}
		why = "no maker";
		return 0;
	}

	// the nearest body (across the floor, within 64 units) removed in the last 3 tics, or (withDied) that died in the last
	// DIED_TICS and is still there; fam >= 0: only a removed body of that family. Returns colour, rung (0: none), tic (-1:
	// none found), distance, which.
	private int, int, int, double, String NearestBody(Actor a, bool withDied, int fam = -1, double reach = 64.0001)
	{
		int best = 0, brung = 0, bt = -1; double bd = reach; String bw = "";
		for (int i = gonTic.Size() - 1; i >= 0; i--)
		{
			if (level.maptime - gonTic[i] > 3) { gonX.Delete(i); gonY.Delete(i); gonZ.Delete(i); gonCol.Delete(i); gonTic.Delete(i); gonRung.Delete(i); gonFam.Delete(i); continue; }
			if (abs(a.pos.z - gonZ[i]) > 96) continue;
			if (fam >= 0 && gonFam[i] != fam) continue;
			double d = (a.pos.xy - (gonX[i], gonY[i])).Length();
			// the nearest; at the same distance, the latest
			if (d < bd || (d == bd && gonTic[i] > bt)) { bd = d; best = gonCol[i]; brung = gonRung[i]; bt = gonTic[i]; bw = "removed body"; }
		}
		for (int i = diedTic.Size() - 1; i >= 0; i--)
		{
			let b = diedA[i];
			if (!b || level.maptime - diedTic[i] > DIED_TICS || b.health > 0) { diedA.Delete(i); diedCol.Delete(i); diedRung.Delete(i); diedTic.Delete(i); continue; }
			if (!withDied || b == a || abs(a.pos.z - b.pos.z) > 96) continue;
			double d = (a.pos.xy - b.pos.xy).Length();
			if (d < bd || (d == bd && diedTic[i] > bt)) { bd = d; best = diedCol[i]; brung = diedRung[i]; bt = diedTic[i]; bw = "body that died"; }
		}
		return best, brung, bt, bd, bw;
	}

	// a body's place on the ladder, as a rung that shows its colour (0: it holds none)
	static int RungOf(Actor b)
	{
		if (!b) return 0;
		for (let i = b.Inv; i; i = i.Inv)
		{
			let k = RS_BDKit(i);
			if (k) return k.rung > k.entry ? k.rung : 0;
			let h = RS_BDHue(i);
			if (h) return h.col;
		}
		return 0;
	}

	// a family monster that rises out of a body mid-map: the body's rung (0: none, or not such a monster). A death stage
	// (counts no kill): its dead master, or the nearest body removed or died. Any other: only a body of its own family
	// removed on the spot (16 units) in the last 3 tics: born again (Brutal Doom's Death.Taunt spawns the replaced class,
	// "ChaingunGuy", which his order's random spawners can turn into a Major: the same family, not the same class).
	private int BodyRung(Actor a, int fam)
	{
		if (level.maptime <= 2) return 0;
		bool stage = !a.bCOUNTKILL;
		if (stage)
		{
			let m = a.master;
			if (m && m != a && m.health <= 0 && RS_BDHue.Known(m)) return RungOf(m);
		}
		int c, r, t; double d; String w;
		if (stage) { [c, r, t, d, w] = NearestBody(a, true); }
		else { [c, r, t, d, w] = NearestBody(a, false, fam, 16.0001); }
		if (t >= 0 && r > 0 && Debug()) Console.Printf("BDTIER: %s rose out of a %s (rung %d, %s %d units away)", a.GetClassName(), stage ? "body" : "body of its own family", r, w, int(d));
		return t >= 0 ? r : 0;
	}

	private void Carry(Actor a)
	{
		if (RS_BDHue.Known(a)) return;
		int worn = OurTint(int(a.Translation));
		String why = "worn";
		if (KeepsOwnLook(a))
		{
			// blood and the rest keep their own look, even when they arrive in the body's tint
			if (worn) a.Translation = GetDefaultByType(a.GetClass()).Translation;
			if (worn && Debug()) LogOnce(a, 0, "keeps its own look: the tier tint it arrived in taken off");
			return;
		}
		int c = worn ? worn : TintFrom(a, why);
		if (c) RS_BDHue.Put(a, c);
		if (Debug()) LogOnce(a, c, why);
	}

	// debug (rsq_mon_bdtier_debug): each class's first carry this map
	private void LogOnce(Actor a, int c, String why)
	{
		Name cn = a.GetClassName();
		let every = CVar.FindCVar('rsq_mon_art_debug');
		if (logged.CheckKey(cn) && !(every && every.GetBool())) return;
		logged.Insert(cn, 1);
		Console.Printf("BDCARRY t%d %s -> %s (%s)", level.maptime, cn, c ? RS_BDArt.COLOUR[c] : "none", why);
	}

	override void WorldThingDestroyed(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.bMISSILE && a.GetMissileDamage(0, 1) > 0) return;
		// a body or a coloured piece leaves a record of where it stood (a body at its entry colour too, with no colour)
		bool known = RS_BDHue.Known(a);
		if (!known && !a.bISMONSTER) return;
		gonX.Push(a.pos.x); gonY.Push(a.pos.y); gonZ.Push(a.pos.z); gonCol.Push(known ? RS_BDHue.ColourOf(a) : 0); gonTic.Push(level.maptime);
		let gk = RS_BDKit.Of(a);
		gonRung.Push(known ? RungOf(a) : 0); gonFam.Push(gk ? gk.fam : -1);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		if (a.bMISSILE)
		{
			// an attack: the kit's own shot rules. [11-13 census] But a body THROWN as a missile that hurts (Brutal Doom's
			// ExtremePunchedChaingunguy: the punched body flies off its dead maker) is a piece of the body: its maker is gone
			// or dead and it draws painted art (a fireball draws none)
			if (a.GetMissileDamage(0, 1) > 0)
			{
				if (On() && (!a.target || a.target.health <= 0) && RS_BDArt.Get().ClassHasArt(a)) Carry(a);
				else Shot(a);
			}
			else if (On()) Carry(a);                      // a limb or a chunk thrown off the body
			return;
		}
		if (!On()) return;
		if (!a.bISMONSTER) { if (!a.player) Carry(a); return; }          // a corpse, a dying body, a piece
		// [11-13 census] a FRIENDLY death stage (Brutal Doom's BurningCacodemon: +FRIENDLY so the others leave it be, no
		// kill of its own) follows the body it rose out of; a friendly that counts as a kill is an ally, and so is any
		// "marine" (Brutal Doom's helper marines Marine_Fist and kin are friendly with no kill too): left alone
		if (a.bFRIENDLY && !a.player && !a.bCOUNTKILL && a.health > 0 && level.maptime > 2)
		{
			String fl = a.GetClassName(); fl = fl.MakeLower();
			if (fl.IndexOf("marine") < 0) Carry(a);
			return;
		}
		if (a.player || a.bFRIENDLY || a.health <= 0) return;
		if (a.FindInventory("RS_BDKit")) return;
		String cn = a.GetClassName();
		if (cn.Left(3) ~== "RS_") return;             // ColorfulHell's own: RS_Retier's ladder, not this one
		int v = Resolve(a.GetClass());
		// a monster with no family that rises out of a tinted body (a last stand, a crawler): the body's colour, no kit
		if (v < 0)
		{
			if (v == -1 && Debug() && !(a is "Inventory")) Console.Printf("BDTIER: MISS %s (parent %s, replaces %s)", cn, a.GetParentClass().GetClassName(),
				Actor.GetReplacee(a.GetClass()).GetClassName());
			if (level.maptime > 2) Carry(a);
			return;
		}

		a.GiveInventory("RS_BDKit", 1);
		let k = RS_BDKit.Of(a);
		if (!k) return;
		k.fam = v / 1000;
		k.entry = 1;                                 // the owner's order: as shipped is the neutral step, for every monster
		k.hpOnly = (v % 10) != 0;
		k.helper = a.FindInventory("RS_BDHelperMark") != null;
		k.basePain = a.PainChance;
		k.baseTrans = a.Translation;
		k.baseMCM = a.MissileChanceMult;
		k.hpF = 1.0; k.dmF = 1.0; k.spF = 1.0;
		k.rung = k.entry;
		int r = k.entry + WorldTier() - 1;
		// [11-13 census] risen out of a body (a death stage, or born again on the spot): the body's place on the ladder; a
		// death stage never calls for help (it is the same monster, dying)
		int br = BodyRung(a, k.fam);
		if (br > 0) { r = br; if (!a.bCOUNTKILL) k.helper = true; }
		if (r > k.entry) { k.rung = r; k.Apply(true, true); }
		RS_BDArt.Watch(a, k);                        // the painted frames for its colour (RS_BDArt.zs), now or after a change
		if (Debug()) Console.Printf("BDTIER: %s family %d entry %d rung %d hp %d", cn, k.fam, k.entry, k.rung, a.health);
	}

	// a kit monster's shot (design 4: BD's own projectiles are never edited; the missile's target is who fired it)
	private void Shot(Actor m)
	{
		let k = RS_BDKit.Of(m.target);
		if (!k || !k.Active() || m.FindInventory("RS_BDShotMark")) return;
		if (m.GetMissileDamage(0, 1) <= 0) return;      // smoke, blood, casings: not an attack
		int t = k.Tier();
		m.GiveInventory("RS_BDShotMark", 1);
		let mk = RS_BDShotMark(m.FindInventory("RS_BDShotMark"));
		if (!mk) return;
		if (t == 2) mk.kind = 2;                      // Green: an acid patch where it lands
		else if (t == 3)                              // Blue: +20% speed, a small zap where it lands
		{
			mk.kind = 3;
			m.vel *= 1.2;
		}
		else if (t == 4)                              // Purple: one more shot an attack, 6 degrees off
		{
			if (k.lastVolley != level.maptime) { k.lastVolley = level.maptime; Twin(m, random[rsbdkit](0, 1) ? 6 : -6, 'None'); }
		}
		else if (t == 5) m.A_SetTranslation('rs_bdtier_cyan');     // Cyan: an ice shot (the slow is in the hit hook)
		else if (t == 7) mk.kind = 7;                 // Yellow: flame where it lands
		else if (t == 8) Twin(m, 4, 'rs_bdtier_blue');             // FireBlu: every missile has a blue twin
		else if (t == 9) m.A_SetTranslation('rs_bdtier_gray');     // Gray: a stone shot
	}

	private void Twin(Actor m, double off, Name tint)
	{
		let b = Actor.Spawn(m.GetClass(), m.pos, NO_REPLACE);
		if (!b) return;
		b.GiveInventory("RS_BDShotMark", 1);          // marked before its own spawn event: never twinned again
		b.target = m.target;
		b.tracer = m.tracer;
		b.angle = m.angle + off;
		b.pitch = m.pitch;
		b.vel.xy = Actor.RotateVector(m.vel.xy, off);
		b.vel.z = m.vel.z;
		if (tint != 'None') b.A_SetTranslation(tint);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let v = e.Thing;
		if (!v || e.Damage <= 0) return;
		let k = RS_BDKit.Of(e.DamageSource);
		if (!k || !k.Active() || e.DamageSource == v) return;
		if (e.Inflictor is "RS_BDPatch") return;
		int t = k.Tier();
		if (t == 2)
		{
			// Green: a hit leaves a 3 s acid patch under what it hit (one a second for each monster)
			if (level.maptime - k.lastPuddle >= 35) { k.lastPuddle = level.maptime; RS_BDPatch.Put(v.pos, e.DamageSource, 2); }
		}
		else if (t == 5) { if (v.player) v.GiveInventory("RS_BDIceSlow", 1); }
		else if (t == 7) RS_BDFx.Ignite(v);
	}

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		// [11-13 census] a body that died: a maker for the pieces it spawns while it lies there (see TintFrom), and a
		// player's last kill (a fatality's colour)
		bool known = RS_BDHue.Known(a);
		if (known || a.bISMONSTER)
		{
			diedA.Push(a); diedCol.Push(known ? RS_BDHue.ColourOf(a) : 0); diedRung.Push(known ? RungOf(a) : 0); diedTic.Push(level.maptime);
			Actor by = e.Inflictor;
			if (by && !by.player && by.target && by.target.player) by = by.target;
			if (!by || !by.player) by = a.target;
			if (by && by.player)
			{
				int pn = by.PlayerNumber();
				if (pn >= 0 && pn < MAXPLAYERS) { lastKillCol[pn] = known ? RS_BDHue.ColourOf(a) : 0; lastKillTic[pn] = level.maptime; }
			}
		}
		let k = RS_BDKit.Of(a);
		if (!k) return;
		k.EndPhase();                                 // a body that died mid-phase gets its own look back
		if (!k.Active()) return;
		int t = k.Tier();
		if (t == 8)
		{
			// FireBlu: a death blast, 64 damage over 128
			RS_BDFx.Burst(a, "Red", 12, 5);
			RS_BDFx.Burst(a, "Blue", 12, 5);
			a.A_Explode(64, 128, XF_NOTMISSILE, false, 0, 0, 10, "BulletPuff", 'Fire');
		}
		if (k.Rage()) RS_BDFx.Bolts(a, random[rsbdkit](3, 5), 'rs_bdtier_red');
		if (t >= 12) { RS_BDFx.Bolts(a, 8, RS_BDKit.TintName(t)); RS_BDFx.Burst(a, t == 13 ? "White" : "DarkGray", 24, 5); }
		if (k.Phase() && !k.rose)
		{
			// Abyss: it rises once, 3 s on, if its body still can
			k.rose = true;
			risers.Push(a);
			riseTic.Push(level.maptime + 105);
		}
	}

	override void WorldThingRevived(WorldEvent e)
	{
		let k = RS_BDKit.Of(e.Thing);
		if (!k) return;
		k.raged = false; k.phaseTics = 0;
		k.Move();
		k.Look();
	}

	// [11-13 census] a player's fatality: from the tic the player holds Brutal Doom's GoFatality (given by the monster's
	// fatality death) to 2 tics after it is taken: the colour of the body that player killed last (in the 8 tics before),
	// for the gore and corpse the player throws (TintFrom), and the player's own fatality frames drawn from the art
	private void Fatalities()
	{
		if (!fatTokRead) { fatTokRead = true; String tn = "GoFatality"; fatTok = tn; }
		if (!fatTok) return;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pm = players[pn].mo;
			if (!pm) continue;
			if (pm.FindInventory(fatTok))
			{
				if (!fatOn[pn])
				{
					fatOn[pn] = true;
					fatCol[pn] = level.maptime - lastKillTic[pn] <= 8 ? lastKillCol[pn] : 0;
					if (fatCol[pn] && On()) RS_BDFatalHue.Put(pm, fatCol[pn]);
					if (Debug()) Console.Printf("BDCARRY t%d player %d fatality: %s", level.maptime, pn, fatCol[pn] ? RS_BDArt.COLOUR[fatCol[pn]] : "no colour");
				}
				fatSeen[pn] = level.maptime;
			}
			else if (fatOn[pn] && level.maptime - fatSeen[pn] > 2)
			{
				fatOn[pn] = false;
				RS_BDFatalHue.TakeOff(pm);
			}
		}
	}

	override void WorldTick()
	{
		Fatalities();
		for (int i = risers.Size() - 1; i >= 0; i--)
		{
			if (level.maptime < riseTic[i]) continue;
			let a = risers[i];
			risers.Delete(i); riseTic.Delete(i);
			if (a && a.health <= 0 && a.CanRaise() && a.A_RaiseSelf()) RS_BDFx.Burst(a, "Purple", 16, 4);
		}

		// the world tier moved during the map: every kit monster follows, with the flash (design 7.2)
		if ((level.maptime & 7) != 0) return;
		int w = WorldTier();
		if (w == lastWorld) return;
		int d = w - lastWorld;
		lastWorld = w;
		if (!On()) return;
		int n = 0;
		ThinkerIterator it = ThinkerIterator.Create("RS_BDKit");
		RS_BDKit k;
		while (k = RS_BDKit(it.Next()))
		{
			let o = k.owner;
			if (!o || o.health <= 0) continue;
			let j = RS_Retier.JobFor(o);
			RS_Retier.RequestKit(o, max(k.entry, (j && j.kitRung > 0 ? j.kitRung : k.rung) + d), false);
			n++;
		}
		// ColorfulHell's monsters follow too (the swap, with the flash), never below Common or above White
		int cn = 0;
		ThinkerIterator ai = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(ai.Next()))
		{
			if (!a.bISMONSTER || a.health <= 0 || a.bFRIENDLY) continue;
			String an = a.GetClassName();
			if (!(an.Left(3) ~== "RS_") || RS_TierLadder.FamilyOfAny(an) < 0) continue;
			let cj = RS_Retier.JobFor(a);
			int cur = cj ? cj.targetTier : RS_TierLadder.TierOfAny(an);
			RS_Retier.Request(a, clamp(cur + d, 1, RS_TierLadder.MaxTier()));
			cn++;
		}
		if (Debug()) Console.Printf("BDTIER: world tier %d: %d kit monsters and %d ColorfulHell monsters follow", w, n, cn);
	}

	//   netevent rs_bdtier_dump    every kit monster: class, family, entry, rung, health, damage, speed, pain chance
	//   netevent rs_bdtier_classes every monster class loaded that would get NO kit (no family found), with its parent and
	//                              what it replaces: the missed classes, whether or not this map spawns them
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rs_bdtier_classes")
		{
			int all = 0, kit = 0, ex = 0, miss = 0, unc = 0;
			for (int i = 0; i < AllActorClasses.Size(); i++)
			{
				class<Actor> c = AllActorClasses[i];
				if (!c) continue;
				let d = GetDefaultByType(c);
				if (!d || !d.bISMONSTER) continue;
				String n = c.GetClassName();
				if (n.Left(3) ~== "RS_") continue;
				all++;
				int v = Resolve(c);
				if (v >= 0) { kit++; continue; }
				if (v == -2) { ex++; continue; }
				// one that does not count as a kill is a death stage, a decoy, a helper or a pickup: the tint follows the
				// body onto those (Carry), no kit; listed only by count
				if (!d.bCOUNTKILL) { unc++; continue; }
				miss++;
				Console.Printf("BDTIER: NOFAMILY %s (parent %s, replaces %s, health %d)", n, c.GetParentClass().GetClassName(),
					Actor.GetReplacee(c).GetClassName(), d.health);
			}
			Console.Printf("BDTIER: %d monster classes loaded: %d get a kit, %d exempt, %d counted with no family, %d not counted with no family",
				all, kit, ex, miss, unc);
			return;
		}
		if (!(e.Name ~== "rs_bdtier_dump")) return;
		int n = 0;
		ThinkerIterator it = ThinkerIterator.Create("RS_BDKit");
		RS_BDKit k;
		while (k = RS_BDKit(it.Next()))
		{
			let o = k.owner;
			if (!o) continue;
			n++;
			// what else rides on it (Champions, LegenDoom change the same fields)
			String also = "";
			for (let it2 = o.Inv; it2; it2 = it2.Inv)
			{
				String inn = it2.GetClassName();
				String low = inn.MakeLower();
				if (low.IndexOf("champion") >= 0 || low.IndexOf("ldlegendary") >= 0) also = also .. " " .. inn;
			}
			Console.Printf("BDTIER: %s fam %d entry %d rung %d tier %d | hp %d/%d base %d dm %.2f spd %.2f/%.2f pain %d/%d trans %d%s%s", o.GetClassName(), k.fam, k.entry,
				k.rung, k.Tier(), o.health, o.GetSpawnHealth(), o.default.health, o.DamageMultiply, o.Speed, o.default.Speed, o.PainChance, o.default.PainChance,
				int(o.Translation), k.hpOnly ? " hp-only" : "", also);
		}
		Console.Printf("BDTIER: %d kit monsters, world tier %d", n, WorldTier());
		// every living monster that is not ColorfulHell's and has NO kit, by class (-1 no family found, -2 exempt)
		Array<Name> mn; Array<int> mc, mv;
		ThinkerIterator mi = ThinkerIterator.Create("Actor");
		Actor m;
		while (m = Actor(mi.Next()))
		{
			if (!m.bISMONSTER || m.health <= 0 || m.player || m.bFRIENDLY || m.FindInventory("RS_BDKit")) continue;
			String mcn = m.GetClassName();
			if (mcn.Left(3) ~== "RS_") continue;
			Name nm = m.GetClassName();
			int at = mn.Find(nm);
			if (at < mn.Size()) { mc[at]++; continue; }
			mn.Push(nm); mc.Push(1); mv.Push(Resolve(m.GetClass()));
		}
		int miss = 0;
		for (int i = 0; i < mn.Size(); i++) { miss += mc[i]; Console.Printf("BDTIER: NOKIT %s x%d (lookup %d)", mn[i], mc[i], mv[i]); }
		Console.Printf("BDTIER: %d living monsters with no kit, %d classes", miss, mn.Size());
		// ColorfulHell's, counted by class with their health
		ThinkerIterator ai = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(ai.Next()))
		{
			if (!a.bISMONSTER || a.health <= 0) continue;
			String an = a.GetClassName();
			if (!(an.Left(3) ~== "RS_") || RS_TierLadder.FamilyOfAny(an) < 0) continue;
			Console.Printf("BDTIER: CH %s tier %d | hp %d/%d (class %d)", an, RS_TierLadder.TierOfAny(an), a.health, a.GetSpawnHealth(), a.default.health);
		}
	}
}
