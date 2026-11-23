// ============================================================================
// RSQ_Miniboss -- YHOLL'S LEGENDOOM LITE, BUILT IN (owner 2026-11-23 05:52: "we will need to build legendoomlite into
// minibosses as well and have it standdown when legendoom itself loaded").
//
//   HIS DECORATE, HIS CLASS NAMES  decorate/ldlite/, filter/*/decorate.txt: his actors, generated from original/LegenDoomLite
//                   by tools/gen_ldlite.py. Every class keeps his name, which is LegenDoom's: so every RSQ mod, Champions and
//                   BD22 VR Reloaded see a Lite legendary by the names they already look for (LDLegendaryMonsterToken,
//                   LDLegendaryMonsterTransformed, ...).
//   HIS ACS, HERE   his LEGNDLIB library is not built in this pack (no ACS compiler in the RSQ tools). What it did is below,
//                   called from his DECORATE through RSQLDL_* functions on two ZScript bases (his LDCustomFunction now
//                   inherits RSQMB_LDLFn, his LDMaxHax RSQMB_LDLHax):
//                     LDWorldInit (OPEN)   RSQMB_LDLHandler: the choosers for this skill a tic into the map (4 more with
//                                          Shades of Doom), again every rsqmb_ldl_legendarynightimer s with Legendaries
//                                          Over Time
//                     LDMonsterInit        RSQMB_LDLMon, an item on the monster instead of an ACS loop a tic per monster
//                     Draw_Pentagram       RSQMB_LDLPenta, the same circle and star of particles, the same fade
//                     PlayerCount, LD_*    RSQLDL_Players(); his cvars read in DECORATE (GetCVar), renamed rsqmb_ldl_*
//                     the compat checks    RSQLDL_Compat: DRLA, Guncaster, Hideous Destructor, as he tested for them
//   STANDS DOWN     while LegenDoom itself is loaded (its LD_legendarymonsters cvar or its LDPistol class exists): no
//                   chooser is spawned, so nothing here runs. LegenDoom's own copies of the shared classes are the ones in
//                   use then (the engine keeps the first definition and renames ours with a warning: "Tried to define class
//                   ... more than once"), and the cvars, sounds, menu and LANGUAGE ids here are RSQ's own, so nothing of
//                   LegenDoom's is replaced. Switch: LegenDoom Lite (rsqmb_ldl, on).
//   THE LIGHTS      (owner: "you are free to optimize the dynamic lights") every evolved legendary left an afterimage each
//                   tic, each with its own flickering light for about 8 tics: some 8 dynamic lights a legendary. The
//                   afterimages keep their look and lose their light; the monster carries ONE light of the same
//                   definition (his GLDEFS, GLDEFS.ldlite, attached by name), from its transformation to its death.
// Rig only once shown; until then code only.
// ============================================================================

class RSQMB_LDL play
{
	static bool LegenDoomHere()
	{
		if (CVar.FindCVar("LD_legendarymonsters")) return true;
		String n = "LDPistol";
		class<Actor> c = n;
		return c != null;
	}
	static bool On() { let c = CVar.FindCVar("rsqmb_ldl"); return !c || c.GetBool(); }
	static int CI(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static double CF(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static bool Has(String n) { class<Actor> c = n; return c != null; }
	// another mod's item, by name (Hideous Destructor's, when it is loaded)
	static void GiveBy(Actor o, String n, int amt) { class<Inventory> c = n; if (c) o.GiveInventory(c, amt); }
	// his compat checks (he spawned one of each mod's actors to see if it existed): 1 DRLA, 2 Guncaster, 3 Hideous
	// Destructor, 4 Shades of Doom
	static int Compat(int w)
	{
		if (w == 1) return Has("RLArsenalThingo") ? 1 : 0;
		if (w == 2) return Has("GnuCustard") ? 1 : 0;
		if (w == 3) return Has("HDDebris") ? 1 : 0;
		if (w == 4) return Has("DeadCyanZombieman2") ? 1 : 0;
		return 0;
	}
	static int Players() { int n = 0; for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i]) n++; return n; }

}

// his LDCustomFunction's base: what his CustomInventory pickups called in ACS (self is the monster picking it up)
class RSQMB_LDLFn : CustomInventory
{
	action int RSQLDL_Players() { return RSQMB_LDL.Players(); }
	action int RSQLDL_Compat(int w) { return RSQMB_LDL.Compat(w); }
	action void RSQLDL_Init()
	{
		if (!self.FindInventory("RSQMB_LDLMon")) self.GiveInventoryType("RSQMB_LDLMon");
	}
	action void RSQLDL_Pentagram(double diam, int r, int g, int b)
	{
		let p = RSQMB_LDLPenta(Actor.Spawn("RSQMB_LDLPenta", self.pos, ALLOW_REPLACE));
		if (p) { p.rad = diam; p.col = (r << 16) | (g << 8) | b; }
	}
	action void RSQLDL_HDCurser(int m, int d) {}   // his LDLite_HDCurser: Hideous Destructor only (its NecroGhost), not ported
}
// his LDMaxHax's base (the choosers and the loot): the compat checks
class RSQMB_LDLHax : Actor
{
	action int RSQLDL_Players() { return RSQMB_LDL.Players(); }
	action int RSQLDL_Compat(int w) { return RSQMB_LDL.Compat(w); }
	action void RSQLDL_HDCurser(int m, int d) {}   // his LDLite_HDCurser: Hideous Destructor only (its NecroGhost), not ported
}

// his LDMonsterInit, on the monster
class RSQMB_LDLMon : Inventory
{
	int spawnHp, realHp;
	bool started, evolved, ended;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; +INVENTORY.UNCLEARABLE; }

	void Start()
	{
		started = true;
		let o = Owner;
		if (o.CountInv("LDLegendaryMonsterToken") > 0) { ended = true; return; }
		o.GiveInventory("LDLegendaryMonsterToken", 1);
		if (RSQMB_LDL.CI("rsqmb_ldl_legendarydebug", 0)) Console.Printf("\cdLD DEBUG\c-: \ca%s\c- has been \cdLEGENDARIFIED\c-", o.GetClassName());
		spawnHp = o.SpawnHealth();
		realHp = spawnHp;
		if (!RSQMB_LDL.Has("DRPGLegenDoomActive"))
		{
			// his integer sums: a 300 cvar is x3
			if (o.bBOSS) spawnHp *= RSQMB_LDL.CI("rsqmb_ldl_legendaryhealthboss", 200) / 100;
			else spawnHp *= RSQMB_LDL.CI("rsqmb_ldl_legendaryhealth", 300) / 100;
			if (RSQMB_LDL.Compat(3)) RSQMB_LDL.GiveBy(o, "HDLDLInit", spawnHp);
			o.health = spawnHp;
		}
	}

	override void DoEffect()
	{
		super.DoEffect();
		let o = Owner;
		if (!o || ended) return;
		if (!started) { Start(); if (ended) return; }
		int hp = o.health;
		if (evolved) o.GiveInventory("LDLegendaryMonsterVisualEffectMaker", 1);
		else if (hp > 0 && hp <= spawnHp / 2)
		{
			if (RSQMB_LDL.Compat(3)) RSQMB_LDL.GiveBy(o, "HDLDLLegendarify", 1);
			o.health = spawnHp;
			if (o.bBOSS) { o.GiveInventory("LDLegendaryMonsterBossStatBoost", 1); o.DamageMultiply = RSQMB_LDL.CF("rsqmb_ldl_legendarydamageboss", 1.5); }
			else { o.GiveInventory("LDLegendaryMonsterStatBoost", 1); o.DamageMultiply = RSQMB_LDL.CF("rsqmb_ldl_legendarydamage", 2.0); }
			evolved = true;
			Glow(o, true);
		}
		if (o.health <= 0)
		{
			ended = true;
			Glow(o, false);
			bool boss = o.bBOSS;
			String pre = boss ? "rsqmb_ldl_bosshealthtier" : "rsqmb_ldl_healthtier";
			int tier = 0;
			for (int k = 5; k >= 1; k--) if (realHp >= RSQMB_LDL.CI(pre .. k, 0)) { tier = k; break; }
			Toss(o, String.Format(boss ? "LDLiteBossTier%dItem" : "LDLiteTier%dItem", tier));
			o.GiveInventory("LDLegendaryMonsterDed", 1);
		}
	}

	// his TossItem: 4 units right and forward, 24 up, thrown 8 units a tic the way it faced
	static void Toss(Actor o, String item)
	{
		class<Actor> c = item;
		if (!c) return;
		let a = Actor.Spawn(c, o.pos + (4, 4, 24), ALLOW_REPLACE);
		if (!a) return;
		a.angle = o.angle;
		a.vel = (cos(o.angle) * 8, sin(o.angle) * 8, -4);
	}

	// ONE LIGHT ON THE MONSTER, the one his afterimages carried for its colour (his VisualEffectMaker's order of tests)
	static void Glow(Actor o, bool on)
	{
		if (!on) { o.A_RemoveLight('RSQMB_LDLGlow'); return; }
		static const String COL[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo", "Violet",
			"Pink", "Magenta", "Black", "Grey", "White", "Bronze", "Silver", "Gold" };
		String ln = "LDMonsterGlowStandard1";
		for (int i = 0; i < COL.Size(); i++)
		{
			String tn = "champion_" .. COL[i] .. "Token";
			class<Inventory> tc = tn;
			if (tc && o.FindInventory(tc)) { ln = "LDMonsterGlow" .. COL[i]; break; }
		}
		bool ok = o.A_AttachLightDef('RSQMB_LDLGlow', ln);   // his GLDEFS light (GLDEFS.ldlite), by its name
		if (RSQMB_LDL.CI("rsqmb_ldl_legendarydebug", 0)) Console.Printf("RSQMB LegenDoom Lite: %s glows %s (%s)", o.GetClassName(), ln, ok ? "attached" : "NOT attached");
	}
}

// his Draw_Pentagram: a circle of 360 points and a five-line star, the monster's diameter x 2 wide, fading in over ~13 tics
// and out over ~127, where the monster transformed
class RSQMB_LDLPenta : Actor
{
	double rad;
	int col, alpha;
	bool fading;
	Default { +NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +NOTIMEFREEZE; RenderStyle "None"; }
	override void PostBeginPlay() { super.PostBeginPlay(); alpha = 1; }
	void Pt(double x, double y)
	{
		// (17.3 has no absolute-position flag: without SPF_RELPOS the offsets are world axes from this actor)
		A_SpawnParticle(col, SPF_FULLBRIGHT, random[rsqldl](5, 7), random[rsqldl](1, 3), 0, x - pos.x, y - pos.y, 0,
			0, 0, 0, 0, 0, 0, alpha / 255.0, 1.0);
	}
	override void Tick()
	{
		if (rad <= 0) { Destroy(); return; }
		for (int k = 360; k > 0; k--) Pt(pos.x + cos(k) * rad, pos.y + sin(k) * rad);
		double px[5], py[5];
		for (int k = 5; k > 0; k--) { px[k - 1] = pos.x + cos(72.0 * k) * rad; py[k - 1] = pos.y + sin(72.0 * k) * rad; }
		int p1 = 0, p2 = 2;
		int n = int(rad * 1.9);
		for (int k = 0; k < 5; k++)
		{
			double vec = VectorAngle(px[p2] - px[p1], py[p2] - py[p1]);
			for (int l = n; l > 0; l--) Pt(px[p1] + l * cos(vec), py[p1] + l * sin(vec));
			p1 = p2; p2 = (p1 + 2) % 5;
		}
		if (!fading) { alpha += 20; if (alpha > 255) { alpha = 255; fading = true; } }
		else { alpha -= 2; if (alpha < 2) { Destroy(); return; } }
	}
}

// his LDWorldInit
class RSQMB_LDLHandler : EventHandler
{
	int initAt, nextAt;
	override void WorldLoaded(WorldEvent e)
	{
		initAt = 0; nextAt = 0;
		if (!RSQMB_LDL.On()) return;
		if (RSQMB_LDL.LegenDoomHere())
		{
			if (RSQMB_LDL.CI("rsqmb_ldl_legendarydebug", 0) || RSQMB_LDL.CI("rsqmb_debug", 0)) Console.Printf("RSQMB LegenDoom Lite: LegenDoom is loaded, standing down");
			return;
		}
		initAt = 1 + (RSQMB_LDL.Compat(4) ? 4 : 0);
	}
	override void WorldTick()
	{
		int now = level.maptime;
		if (initAt > 0 && now >= initAt)
		{
			initAt = 0;
			Choose();
			if (RSQMB_LDL.CI("rsqmb_ldl_legendarynightmare", 0)) nextAt = now + 35 * max(1, RSQMB_LDL.CI("rsqmb_ldl_legendarynightimer", 60));
		}
		if (nextAt > 0 && now >= nextAt)
		{
			nextAt = 0;
			if (RSQMB_LDL.On() && RSQMB_LDL.CI("rsqmb_ldl_legendarynightmare", 0))
			{
				Choose();
				nextAt = now + 35 * max(1, RSQMB_LDL.CI("rsqmb_ldl_legendarynightimer", 60));
			}
		}
	}
	void Choose()
	{
		static const String CH[] = { "LDLegendaryMonsterChooserEasy", "LDLegendaryMonsterChooserNormal", "LDLegendaryMonsterChooserHard",
			"LDLegendaryMonsterChooserUV", "LDLegendaryMonsterChooserNightmare", "LDLegendaryMonsterChooserNightmare",
			"LDLegendaryMonsterChooserNightmare", "LDLegendaryMonsterChooserNightmare" };
		int skill = G_SkillPropertyInt(SKILLP_ACSReturn);
		let dr = CVar.FindCVar("DRLA_is_monsters_loaded");
		if (dr && dr.GetInt() && skill == 7) skill = 2;
		skill = clamp(skill, 0, CH.Size() - 1);
		class<Actor> c = CH[skill];
		if (!c) return;
		// his grid: each chooser reaches 16384 (a cube), 4 x 4 x 4 of them cover the whole map
		int n = 0;
		for (int x = -32768; x < 32768; x += 16384)
			for (int y = -32768; y < 32768; y += 16384)
				for (int z = -32768; z < 32768; z += 16384)
					if (Actor.Spawn(c, (x, y, z), ALLOW_REPLACE)) n++;
		if (RSQMB_LDL.CI("rsqmb_ldl_legendarydebug", 0) || RSQMB_LDL.CI("rsqmb_debug", 0)) Console.Printf("RSQMB LegenDoom Lite t%d: %d choosers (%s)", level.maptime, n, CH[skill]);
	}
}
