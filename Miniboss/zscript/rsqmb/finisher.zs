// ============================================================================
// RSQ_Miniboss -- THE MELEE FINISHERS (design/BOSS_REWORK.md 4, DOOM 2016's glory kills, our way). Code only, not run
// (2026-11-23, owner: hold rig checks until we talk).
//
//   WHAT            a STAGGERED thrall (telegraph.zs ThrallStep: under rsqmb_thrall_stagger_hp % of its health, once, or
//                   with its Boss on BREAK!), or the Boss itself during BREAK!, hit by a MELEE STRIKE of a player: a
//                   health and armour burst straight to that player (rsqmb_fin_health / rsqmb_fin_armor; the Boss's x2),
//                   a Score pop (RSQ Score's "award", by name: rsqmb_fin_score points, the Boss's x2, on Score's Base row,
//                   since Score has no "Finisher" row of its own), RSQ VisualRewards' toasts (+n HEALTH, +n ARMOR), its
//                   pop and a FINISHER! word over the target (by name; without VisualRewards a BIGFONT print). A thrall
//                   finished dies (rsqmb_fin_kill: the next tic, an Extreme death: Brutal Doom's gibs). Once a thrall;
//                   the Boss once a BREAK!.
//   WHICH MELEE     owner 2026-11-23 03:58, decided: "melee finishers count ALL of punch/kick/headlock (RSQ Melee + BD22
//                   kick), Saber, ShieldSaw and Whip". Read from each mod's code (none of them is edited; this only reads
//                   the blow in WorldThingDamaged), each group its own switch, all on:
//                     Fists and Kicks (rsqmb_fin_fists)  DamageType Melee (RSQ Melee's punches, headlock combo, chokehold,
//                                                        club, launch and bowl: gloves.zs, headlock.zs, club.zs, launch.zs;
//                                                        BD22's punch, MeleeStrike1's family; RSQ Grapple's kick and the
//                                                        ShieldSaw's shield bash, both Melee), Kick (RSQ Melee's kick,
//                                                        shove.zs; BD22's kick, KickAttack's family: KickPuff,
//                                                        SuperKickPuff), Fatality, SuperPunch, Stealth (BD22's own); or a
//                                                        blow whose inflictor is BD22's MeleeStrike1 or KickAttack
//                     Saber (rsqmb_fin_saber)            DamageType Saber (RSQ Saber: the blade, its throw)
//                     ShieldSaw (rsqmb_fin_shieldsaw)    DamageType Saw dealt by the player himself (the grind,
//                                                        guard.zs) or by an SSQ_ actor (the disc, disc.zs)
//                     Whip (rsqmb_fin_whip)              DamageType Whip (RSQ Whip's own type, whip.zs DmgType)
//                     BD22 Blades (rsqmb_fin_blades)     BD22's axe, chainsaw and sword: inflictor AxeAttack, DSAttack or
//                                                        SawDamageHorizontal, or DamageType Saw / Cut within reach
//                                                        (rsqmb_fin_reach m past the target's edge: its bullet puffs that
//                                                        carry Cut are not melee). Not named by the owner; melee all the
//                                                        same, so on
//                   The blow must be a player's (its source, or its inflictor's shooter). 0-damage probes (RSQ Melee's and
//                   BD22 VR's haptic types, BD22's downed-enemy probe) do not count.
// ============================================================================

extend class RSQMB_Handler
{
	enum EFinGroup { FG_FISTS, FG_SABER, FG_SHIELDSAW, FG_WHIP, FG_BLADES }

	// the finishers due (paid the next tic: never inside the blow's own damage)
	Array<Actor> finWho, finBy;
	Array<int> finGroup;

	static bool Descends(Actor a, Name n)
	{
		if (!a) return false;
		for (class<Object> c = a.GetClass(); c; c = c.GetParentClass()) if (c.GetClassName() == n) return true;
		return false;
	}

	// which melee group a blow is, -1 none (the header)
	static int MeleeGroup(WorldEvent e, Actor p)
	{
		Name t = e.DamageType;
		Actor inf = e.Inflictor;
		if (t == 'Whip') return FG_WHIP;
		if (t == 'Saber') return FG_SABER;
		String ic = "";
		if (inf) ic = inf.GetClassName();
		if (t == 'Saw' && inf && (inf == p || ic.Left(4) == "SSQ_")) return FG_SHIELDSAW;
		if (t == 'Melee' || t == 'Kick' || t == 'Fatality' || t == 'SuperPunch' || t == 'Stealth') return FG_FISTS;
		if (Descends(inf, 'MeleeStrike1') || Descends(inf, 'KickAttack')) return FG_FISTS;
		if (Descends(inf, 'AxeAttack') || Descends(inf, 'DSAttack') || Descends(inf, 'SawDamageHorizontal')) return FG_BLADES;
		if (t == 'Saw' || t == 'Cut')
		{
			let v = e.Thing;
			double reach = clamp(CF('rsqmb_fin_reach', 2.5), 0.5, 10.0) * 32.0;
			if (v && p && v.Distance2D(p) <= v.radius + p.radius + reach) return FG_BLADES;
		}
		return -1;
	}

	static bool GroupOn(int g)
	{
		switch (g)
		{
		case FG_FISTS: return CI('rsqmb_fin_fists', 1) != 0;
		case FG_SABER: return CI('rsqmb_fin_saber', 1) != 0;
		case FG_SHIELDSAW: return CI('rsqmb_fin_shieldsaw', 1) != 0;
		case FG_WHIP: return CI('rsqmb_fin_whip', 1) != 0;
		case FG_BLADES: return CI('rsqmb_fin_blades', 1) != 0;
		}
		return false;
	}
	static String GroupName(int g)
	{
		static const String N[] = { "fists and kicks", "saber", "ShieldSaw", "whip", "BD22 blades" };
		return g >= 0 && g < N.Size() ? N[g] : "?";
	}

	// WorldThingDamaged (handler.zs): a melee strike on a staggered thrall or on a Boss in BREAK!
	void FinDamaged(WorldEvent e)
	{
		if (!e.Thing || e.Damage <= 0 || bosses.Size() == 0 || CI('rsqmb_fin', 1) == 0) return;
		let b = RSQMB_Service.BossOf(e.Thing);
		if (!b || b.done || !b.tele) return;
		Actor p = PlayerOf(e.DamageSource);
		if (!p) p = PlayerOf(e.Inflictor);
		if (!p) return;
		let t = b.tele;
		bool isBoss = b.mb == e.Thing;
		if (!t.Staggered(e.Thing)) return;
		if (isBoss ? t.brkFinished : t.finDone.Find(e.Thing) < t.finDone.Size()) return;
		int g = MeleeGroup(e, p);
		if (g < 0 || !GroupOn(g)) return;
		if (isBoss) t.brkFinished = true; else t.finDone.Push(e.Thing);
		finWho.Push(e.Thing); finBy.Push(p); finGroup.Push(g);
		if (debug) Console.Printf("RSQMB FINISHER t%d: %s %s by %s (%s, %s %d)", level.maptime, isBoss ? "the Boss" : "a thrall", e.Thing.GetClassName(),
			p.player ? "a player" : "?", GroupName(g), e.DamageType, e.Damage);
	}

	// TeleTick (telegraph.zs): pay them
	void FinTick()
	{
		for (int i = 0; i < finWho.Size(); i++)
		{
			let v = finWho[i];
			let p = finBy[i];
			if (!p || !p.player) continue;
			let b = v ? RSQMB_Service.BossOf(v) : null;
			bool isBoss = b && b.mb == v;
			int k = isBoss ? 2 : 1;
			int hp = max(0, CI('rsqmb_fin_health', 25)) * k, ar = max(0, CI('rsqmb_fin_armor', 15)) * k, sc = max(0, CI('rsqmb_fin_score', 250)) * k;
			int gotH = 0, gotA = 0;
			int h0 = p.health;
			if (hp > 0) { p.GiveBody(hp); gotH = p.health - h0; }
			if (ar > 0) gotA = GiveArmour(p, ar);
			if (sc > 0) Award(p, "Finisher", sc);
			let vr = VrService();
			if (vr)
			{
				if (gotH > 0) vr.GetInt("toast", String.Format("health|+%d HEALTH", gotH), 0, 0, p);
				if (gotA > 0) vr.GetInt("toast", String.Format("armor|+%d ARMOR", gotA), 0, 0, p);
				if (v) vr.GetInt("pop", "", 0xFF8020, 1.5, v);
			}
			if (v) RSQMB_Tele.Say(self, "FINISHER!", v, PlayerPawn(p));
			p.A_StartSound("misc/p_pkup", CHAN_AUTO, CHANF_LOCAL | CHANF_OVERLAP, 1.0, ATTN_NONE);
			// a thrall finished dies (Extreme: Brutal Doom's gibs); never the Boss
			if (v && !isBoss && v.health > 0 && CI('rsqmb_fin_kill', 1) != 0)
				v.DamageMobj(p, p, v.health + 1000, 'Extreme', DMG_FORCED | DMG_NO_ARMOR | DMG_THRUSTLESS);
			if (debug) Console.Printf("RSQMB FINISHER paid t%d: +%d health, +%d armour, %d Score (%s)", level.maptime, gotH, gotA, sc, isBoss ? "the Boss, x2" : "a thrall");
		}
		finWho.Clear(); finBy.Clear(); finGroup.Clear();
	}

	// armour as an armour bonus gives it (to 200); the points actually added
	static int GiveArmour(Actor p, int n)
	{
		let ab = BasicArmorBonus(Actor.Spawn("RSQMB_ArmorBit", p.pos, NO_REPLACE));
		if (!ab) return 0;
		let had = BasicArmor(p.FindInventory("BasicArmor"));
		int a0 = had ? had.Amount : 0;
		ab.SaveAmount = n;
		bool took = ab.CallTryPickup(p);
		if (ab && !ab.bDestroyed && !ab.Owner) ab.Destroy();   // an armour bonus is used up at once: nothing left lying
		if (!took) return 0;
		let now = BasicArmor(p.FindInventory("BasicArmor"));
		return (now ? now.Amount : 0) - a0;
	}
}
