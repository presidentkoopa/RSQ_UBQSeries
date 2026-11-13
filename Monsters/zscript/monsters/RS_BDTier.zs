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
// 1.0 (the rule's "relative to the entry colour"; my reading for kits and tint,
// the document does not say).
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
		double nh = RS_BDTierData.HP(fam, t) / RS_BDTierData.HP(fam, entry) * exh;
		int oldFull = o.GetSpawnHealth();
		double frac = oldFull > 0 ? clamp(double(o.health) / oldFull, 0.05, 1.0) : 1.0;
		int sh = o.StartHealth > 0 ? o.StartHealth : o.default.health;
		if (hpF <= 0) hpF = 1.0;
		o.StartHealth = max(1, int(round(sh / hpF * nh)));
		hpF = nh;
		if (o.health > 0)
		{
			int full = o.GetSpawnHealth();
			o.health = (!first && RS_Retier.FullHealth(instant)) ? full : max(1, int(round(full * frac)));
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
		if (rung > entry) o.A_SetTranslation(TintName(Tier()));
		else o.Translation = baseTrans;
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
	private int bdState;
	private Array<Actor> risers;
	private Array<int>   riseTic;

	bool On()       { if (!cvOn) cvOn = CVar.FindCVar('rsq_mon_bdtier'); return !cvOn || cvOn.GetBool(); }
	int  WorldTier(){ if (!cvWorld) cvWorld = CVar.FindCVar('rsq_mon_worldtier'); return cvWorld ? clamp(cvWorld.GetInt(), 1, 40) : 1; }
	bool Debug()    { if (!cvDebug) cvDebug = CVar.FindCVar('rsq_mon_bdtier_debug'); return cvDebug && cvDebug.GetBool(); }

	private bool BDLoaded()
	{
		if (bdState == 0)
		{
			static const String BDCLS[] = { "BrutalWeapon", "Brutal_Blood", "BD_Token" };
			bdState = -1;
			for (int i = 0; i < BDCLS.Size(); i++) { class<Actor> c = BDCLS[i]; if (c) { bdState = 1; break; } }
		}
		return bdState > 0;
	}

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

	// design 2.2 for a monster the table does not name: the highest colour whose family multiplier is at or below
	// its health / the family's base (tools/build_ladders.py entry())
	private int EntryByHealth(int fam, int hp, Name vanilla)
	{
		int base = BDLoaded() ? RS_BDTierData.BDBaseHP(fam) : 0;
		if (base <= 0)
		{
			class<Actor> vc = vanilla;
			if (vc) base = GetDefaultByType(vc).health;
		}
		if (base <= 0 || hp <= 0) return 1;
		// (ZScript names are case-blind: a `T` here and the loop's `t` would be one variable)
		double ratio = double(hp) / base;
		int n0 = 1;
		for (int c = 1; c <= 11; c++) if (RS_BDTierData.HP(fam, c) <= ratio * 1.02) n0 = c;
		double aby = RS_BDTierData.HP(fam, 11);
		if (ratio > aby * 1.3) n0 = ratio < aby * 1.5 * 1.3 ? 12 : 13;
		return n0;
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
				int f = RS_RosterHandler.FamilyId(vn);
				val = f * 1000 + EntryByHealth(f, GetDefaultByType(cls).health, vn) * 10;
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

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		if (a.bMISSILE) { Shot(a); return; }
		if (!a.bISMONSTER || a.player || a.bFRIENDLY || a.health <= 0 || !On()) return;
		if (a.FindInventory("RS_BDKit")) return;
		String cn = a.GetClassName();
		if (cn.Left(3) ~== "RS_") return;             // ColorfulHell's own: RS_Retier's ladder, not this one
		int v = Resolve(a.GetClass());
		if (v < 0) return;

		a.GiveInventory("RS_BDKit", 1);
		let k = RS_BDKit.Of(a);
		if (!k) return;
		k.fam = v / 1000;
		k.entry = clamp((v % 1000) / 10, 1, 13);
		k.hpOnly = (v % 10) != 0;
		k.helper = a.FindInventory("RS_BDHelperMark") != null;
		k.basePain = a.PainChance;
		k.baseTrans = a.Translation;
		k.baseMCM = a.MissileChanceMult;
		k.hpF = 1.0; k.dmF = 1.0; k.spF = 1.0;
		k.rung = k.entry;
		int r = k.entry + WorldTier() - 1;
		if (r > k.entry) { k.rung = r; k.Apply(true, true); }
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

	override void WorldTick()
	{
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
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rs_bdtier_dump")) return;
		int n = 0;
		ThinkerIterator it = ThinkerIterator.Create("RS_BDKit");
		RS_BDKit k;
		while (k = RS_BDKit(it.Next()))
		{
			let o = k.owner;
			if (!o) continue;
			n++;
			Console.Printf("BDTIER: %s fam %d entry %d rung %d tier %d | hp %d/%d dm %.2f spd %.2f pain %d trans %d%s", o.GetClassName(), k.fam, k.entry,
				k.rung, k.Tier(), o.health, o.GetSpawnHealth(), o.DamageMultiply, o.Speed, o.PainChance, int(o.Translation), k.hpOnly ? " hp-only" : "");
		}
		Console.Printf("BDTIER: %d kit monsters, world tier %d", n, WorldTier());
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
