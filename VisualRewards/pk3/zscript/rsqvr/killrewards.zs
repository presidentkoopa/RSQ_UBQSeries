// KILL REWARDS -- monsters burst into bits of health, armour and ammo when they die. (RSQ VisualRewards)
//
// MOVED 2026-11-03 from RSQ Gun Bonsai VR (rsq/zscript/killrewards.zs) into RSQ VisualRewards, with the HP bars and the
// damage numbers (NEXT_PLAN_2026-11-03.md 1). Every class name (RSQ_KRHandler, RSQ_KRHealthBit / ArmorBit / AmmoBit), every
// cvar (rsqgb_kr_*), the sprites (KRBH / KRBA / KRBM) and the behaviour are unchanged, so the owner's settings and saves carry
// over and every mod that looks for them by name still finds them (RSQ Whip skips any class named "RSQ_KR...", RSQ Miniboss
// answers "bossfor rewards"). What changed: the Brutal Doom helper list is the one the bars and numbers use
// (rsqvr/helpers.zs), and nothing here links to Gun Bonsai VR any more -- its path nodes are read by name
// (RSQ_MeleeUpgradeService "plevel"), Lucky Kill asks it "kr.lucky" / "kr.luckyfx", Scavenger 3 asks "level" "Scavenger".
// Without Gun Bonsai VR every node reads 0: SoM's behaviour, as at level 0.
//
// SoM's "Universal(ish?) Kill Rewards" v1.0 (som_kr), folded into this patch on the owner's word (2026-11-02,
// GBOVR_TREES.md 3.14): "I love the current implementation, I don't want to lose anything, but the menu I do not
// understand." SoM's readme: "Feel free to use anything in this mod for yourself ... I don't need credit, unless you
// wanted to." We do: CREDITS. The behaviour is SoM's, line for line where it mattered; the menu is new (plain rows
// with presets), the cvars are ours (rsqgb_kr_*), the bit classes carry our names and sprite lumps (KRBH / KRBA /
// KRBM, SoM's three orbs; 2026-11-03 renamed from RQK*, since BD22 VR's sniper uses sprite RQKM, and given a grAb
// offset 5,15 so a landed bit sits on the floor instead of sunk under it), and two things are fixed: Range mode's inverted chance test (at 100% only bosses
// dropped), and the ammo bit reading players[consoleplayer] in the playsim (wrong player in a netgame: the toucher
// is the one who picks it up).
//
// WHAT HAPPENS. A monster dies (WorldThingDied, bIsMonster, not one of Brutal Doom's helpers: RSQVR_Helpers). N bits
// burst out of it 32 units up, thrown 1-6 sideways and up on a random heading:
//   N  By Health (default; the owner 2026-11-03 10:16, after trying Range: "I dropped a cyber demon and it shot out
//      1000 bits"): spawn health / (10 at Standard) rounded, at least 1, x the boss fountain (3) for a BOSS.
//      Range: a random 1-3 (x boss).
//   each bit rolls the drop chance (50%, SoM's som_kr_per; a boss always drops every bit), then its KIND by the mix
//   (Custom 15 / 20 / 65): health (KRBH, 25 health), armour (KRBA, 10 green armour, up to 250), ammo (KRBM, 5 rounds
//   of any gun you carry, or of the gun in your hand). Bits vanish after 7 s (SoM's 35 tics x 7; 0 = never). Bits Fly
//   to Me pulls bits inside a radius toward you (2 m; 0 = off; the Magnet node raises it).
//   The chance is rolled ONCE, per bit, in both modes (2026-11-03). SoM had two: som_kr_chance (Range, per kill) and
//   som_kr_per (per bit); the owner ran chance 100 / per 50, and this patch had been rolling its one chance twice in
//   Range (50% gave ~25%). An imp (60 hp) now rolls 6 bits, each at 50%; a boss drops all it rolls.
// "Kill Rewards: On" (rsqgb_kr_enabled) is the owner's "on by default: yes" row: bits from the first kill, no
// unlock. Off: no bits at all. The path nodes (Bit Scavenger, Rich Bits, Magnet, Lucky Kill) read their levels here by
// name once they exist; at level 0 everything is as SoM shipped it.
//
// CVARS (all server; defaults are the owner's own SoM settings, 2026-11-03; the raw numbers live on Tuning and Debug):
//   rsqgb_kr_enabled   bool   on
//   rsqgb_kr_mode      0 By Health, 1 Range                                    (0)
//   rsqgb_kr_amount    0 Few (1 per 20 health), 1 Standard (per 10), 2 Many (per 5), 3 Custom (rsqgb_kr_hp_ratio)
//   rsqgb_kr_hp_ratio  int    10      (Custom)
//   rsqgb_kr_boss      int    3       x bits for a boss (1, 3, 5)
//   rsqgb_kr_mix       0 Even, 1 Mostly Health, 2 Mostly Armour, 3 Mostly Ammo, 4 Custom (the three ratios)   (4)
//   rsqgb_kr_ratio_health / _armor / _ammo   int 0..100  15 20 65 (Custom)
//   rsqgb_kr_chance    int    50      % each bit drops (bosses always)
//   rsqgb_kr_life      int    7       seconds a bit lives, 0 = forever
//   rsqgb_kr_vanish    int    0       how it goes: 0 Blink Out, 1 Fade Out (owner 11-06; VanishTick)
//   rsqgb_kr_ammo_mode 0 the gun in hand, 1 any gun carried                    (1)
//   rsqgb_kr_ammotype1 / _ammotype2  bool  on / off   which of a gun's two ammo types count (clip mods: see SoM)
//   rsqgb_kr_magnet    float  2.0     metres bits drift to you from, 0 off (0 until 11-04; rsqvr_cfgver moves an old 0 to 2)
//   rsqgb_kr_min / _max / _rnd   Range mode: 1, 3, on
class RSQ_KRHandler : EventHandler
{
	// Brutal Doom's helpers (the boot smearers, "Because Brutal Doom..." (SoM); the head hitboxes, owner 2026-11-03: yes --
	// a BD Cyberdemon also burst its NewCybersHitBox, 1000 bits rolled): the one list the bars and numbers use too,
	// rsqvr/helpers.zs. By name: no BD, no effect.

	static int SVI(String n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }
	static double SV(String n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }
	static bool SVB(String n, bool fb) { let c = CVar.FindCVar(n); return c ? c.GetBool() : fb; }

	// THE PATH'S LEVELS (GBOVR_TREES.md 3.14 / 4.10), by name, asked once a second for every player: every bit reads
	// them every other tic, and a Cyberdemon's fountain is 1200 bits. Bit Scavenger is the path's "Scavenger" (the class
	// name RSQ_Upgrade_Scavenger is the grenade's weapon node).
	transient int lvTic;
	transient int lvScav[MAXPLAYERS], lvRich[MAXPLAYERS], lvMagnet[MAXPLAYERS], lvLucky[MAXPLAYERS];
	void Refresh()
	{
		if (lvTic > 0 && level.maptime < lvTic && level.maptime >= lvTic - 35) return;
		lvTic = level.maptime + 35;
		let s = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			lvScav[n] = 0; lvRich[n] = 0; lvMagnet[n] = 0; lvLucky[n] = 0;
			if (!s || !playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			lvScav[n]   = max(0, s.GetInt("plevel", "BitScavenger", 0, 0, pmo));
			lvRich[n]   = max(0, s.GetInt("plevel", "RichBits", 0, 0, pmo));
			lvMagnet[n] = max(0, s.GetInt("plevel", "Magnet", 0, 0, pmo));
			lvLucky[n]  = max(0, s.GetInt("plevel", "LuckyKill", 0, 0, pmo));
		}
	}
	// a player's level of a path node (0 for a monster, nobody, or a node not learned)
	static int Perk(Actor pawn, String shortName)
	{
		if (!pawn || !pawn.player) return 0;
		let h = RSQ_KRHandler(EventHandler.Find("RSQ_KRHandler"));
		if (!h) return 0;
		h.Refresh();
		int n = pawn.PlayerNumber();
		if (shortName == "BitScavenger") return h.lvScav[n];
		if (shortName == "RichBits") return h.lvRich[n];
		if (shortName == "Magnet") return h.lvMagnet[n];
		if (shortName == "LuckyKill") return h.lvLucky[n];
		return 0;
	}
	// MAGNET: bits inside 2, 3, 4 m drift to you; the Bits Fly to Me row (metres) when it reaches further. The row at 0 is
	// off, Magnet or not (owner 11-04 "Row can still turn it off"; learning Magnet sets an Off row to 2 m once, GBOVR).
	static double MagnetM(Actor pawn)
	{
		static const double M[] = { 0, 2, 3, 4 };
		double row = SV("rsqgb_kr_magnet", 2.0);
		if (row <= 0) return 0;
		return max(row, M[clamp(Perk(pawn, "Magnet"), 0, 3)]);
	}

	// health per bit at the Bits per Kill preset
	static int HpRatio()
	{
		switch (SVI("rsqgb_kr_amount", 1))
		{
			case 0: return 20;
			case 2: return 5;
			case 3: return max(1, SVI("rsqgb_kr_hp_ratio", 10));
		}
		return 10;
	}

	// the three weights at the What Drops preset
	static int, int, int Mix()
	{
		switch (SVI("rsqgb_kr_mix", 4))
		{
			case 1: return 4, 1, 1;
			case 2: return 1, 4, 1;
			case 3: return 1, 1, 4;
			case 4: return max(0, SVI("rsqgb_kr_ratio_health", 15)), max(0, SVI("rsqgb_kr_ratio_armor", 20)), max(0, SVI("rsqgb_kr_ratio_ammo", 65));
		}
		return 1, 1, 1;
	}

	// COUNTS AS A BOSS HERE: the engine's BOSS flag, or an RSQ Miniboss miniboss while Miniboss's "Boss Kill Rewards" is
	// on (owner 2026-11-03: a miniboss never gets the BOSS flag). Asked by name, nothing links: the monster carries
	// "RSQMB_Ward", then RSQMB_Service "bossfor" "rewards" says yes (it counts one that died this tic or the last, so
	// the order of the two WorldThingDied handlers does not matter). Without RSQ Miniboss: bBoss alone, as before.
	static bool BossHere(Actor a)
	{
		if (!a) return false;
		if (a.bBoss) return true;
		String wn = "RSQMB_Ward";
		class<Inventory> wc = wn;
		if (!wc || !a.FindInventory(wc)) return false;
		let sv = ServiceIterator.Find("RSQMB_Service").Next();
		return sv && sv.GetInt("bossfor", "rewards", 0, 0, a) == 1;
	}

	// A MINIBOSS FIGHT'S THRALL (owner 2026-11-12 20:4x: "no gun drop, no red bits drop. just champion bundle, armor and
	// ammo."): its bits are armour and ammo only; a bit that rolls health is not dropped (the armour and ammo bits roll as
	// before). Asked by name, nothing links: the monster carries "RSQMB_Called" (a called-in fight's monster, dead or
	// alive, for good) and RSQMB_Service "wasboss" says it is not the miniboss. Without RSQ Miniboss: never.
	static bool ThrallHere(Actor a)
	{
		if (!a) return false;
		String cn = "RSQMB_Called";
		class<Inventory> cc = cn;
		if (!cc || !a.FindInventory(cc)) return false;
		let sv = ServiceIterator.Find("RSQMB_Service").Next();
		return sv && sv.GetInt("wasboss", "", 0, 0, a) == 0;
	}

	// WHO DROPS GOLD (owner 2026-11-22: "Gold drops only from Champions (mk-champions), LegenDoom legendaries, and Bosses (RSQ
	// Miniboss's Boss and Big Boss). Common monsters and Boss thralls drop NO gold."). Gold From (rsqvr_gold_from): 0 Special
	// Kills Only (the default), 1 Every Kill (the old way: a Gold Share of every kill's bits, the fountains as before).
	//   3  a MAP BOSS: a monster with Doom's BOSS flag (the Cyberdemon, the Spider Mastermind: owner 2026-11-22, "Yes, they
	//      count") that is not RSQ Miniboss's Boss. Twice a Boss's fountain and nothing else (owner 2026-11-23, "Twice an RSQ
	//      Boss", after the rig: a Cyberdemon, XMVE's Thamuz, paid 1,275 gold from a Gold Share of its 912 bits, a Boss about
	//      50 to 165): 2 x the Boss Gold Fountain (40 bits, 200 gold at the defaults); its bits' gold rolls stay the health,
	//      armour and ammo bits they rolled (goldShareOff).
	//   2  a Boss: RSQ Miniboss's Boss or Big Boss, the set piece's miniboss itself (it carries RSQMB_Ward and RSQMB_Service
	//      "wasboss" says so; whatever Boss Kill Rewards says). Its Gold Share of its bits, and the Boss Gold Fountain.
	//   1  a Champion with its powers on (Champions' champion_PersistentInfo or a colour token; in Champions' dormant
	//      LegenDoom mode only once LegenDoom has transformed it, as RSQ Score's boost.zs ChampActive reads it), or a
	//      LegenDoom legendary (LDLegendaryMonsterToken: LegenDoom's own, and BD22 VR Reloaded's LD mode, which runs on it),
	//      risen or not. Its Gold Share, and the Champion Gold Fountain.
	//   0  everything else, and always a Boss's thrall (a called-in fight's monster, RSQMB_Called, or one bound to a Boss,
	//      RSQMB_Thrall), champion or legendary or not, and a Champions Indigo clone (champion_CloneToken: no kill).
	// All by name: without those mods nothing is a special kill (and with Special Kills Only no gold drops).
	static bool InvHas(Actor a, String n)
	{
		if (!a) return false;
		class<Inventory> c = n;
		return c && a.FindInventory(c);
	}
	static Service Miniboss() { return ServiceIterator.Find("RSQMB_Service").Next(); }
	static bool MbBoss(Actor a)
	{
		if (!InvHas(a, "RSQMB_Ward")) return false;
		let sv = Miniboss();
		return sv && sv.GetInt("wasboss", "", 0, 0, a) == 1;
	}
	static bool MbThrall(Actor a)
	{
		if (InvHas(a, "RSQMB_Thrall")) return !MbBoss(a);
		if (!InvHas(a, "RSQMB_Called")) return false;
		let sv = Miniboss();
		return sv && sv.GetInt("wasboss", "", 0, 0, a) == 0;
	}
	// Champions' own test (handler.txt champion_LegendoomCheck): LegenDoom mode and dormant, LegenDoom loaded
	static bool ChampDormantMode()
	{
		let c1 = CVar.FindCVar("champion_Legendoom"), c2 = CVar.FindCVar("champion_Dormant");
		if (!c1 || !c2 || c1.GetInt() == 0 || c2.GetInt() == 0) return false;
		return Wads.FindLump("LEGNDLIB") != -1 || Wads.CheckNumForFullName("acs/LEGNDLIB.o") != -1;
	}
	static bool ChampOn(Actor a)
	{
		bool champ = InvHas(a, "champion_PersistentInfo");
		for (let i = a.Inv; i && !champ; i = i.Inv)
		{
			String cn = i.GetClassName();
			if (cn.Left(9) ~== "champion_" && cn.IndexOf("Token") >= 0 && !(cn ~== "champion_NullToken") && !(cn ~== "champion_CloneToken")) champ = true;
		}
		if (!champ) return false;
		return !ChampDormantMode() || InvHas(a, "LDLegendaryMonsterTransformed");
	}
	static int GoldKind(Actor a)
	{
		if (!a || InvHas(a, "champion_CloneToken")) return 0;
		if (MbBoss(a)) return 2;
		if (MbThrall(a)) return 0;
		if (a.bBoss) return 3;     // a map boss (Cyberdemon, Spider Mastermind): owner 2026-11-22 "Yes, they count"; 11-23 twice a Boss
		if (InvHas(a, "LDLegendaryMonsterToken") || ChampOn(a)) return 1;
		return 0;
	}

	// SETTINGS GENERATIONS, each once (rsqvr_cfgver; the config saves every value, so a changed CVARINFO default never
	// reaches a machine that has run the mod: its old value sticks). DistanceGrab's / ShieldSaw's pattern.
	// 1 (owner, 11-04 18:16): Bits Fly to Me 2 m by default (BUGS_0.99a item 35: at the old 0 a VR player standing still
	//   never picked a bit up), moved only from the old default 0; the damage numbers' OVERKILL word off by default.
	static void Migrate()
	{
		let ver = CVar.FindCVar("rsqvr_cfgver");
		if (!ver) return;
		if (ver.GetInt() < 1)
		{
			let c = CVar.FindCVar("rsqgb_kr_magnet"); if (c && c.GetFloat() <= 0) c.SetFloat(2.0);
			c = CVar.FindCVar("rsqthp_dmg_overkill"); if (c) c.SetBool(false);
			ver.SetInt(1);
		}
	}
	override void WorldLoaded(WorldEvent e) { Migrate(); }

	override void WorldThingDied(WorldEvent e)
	{
		if (!SVB("rsqgb_kr_enabled", true)) return;
		Actor a = e.Thing;
		if (!a || !a.bIsMonster) return;
		String cn = a.GetClassName();
		if (RSQVR_Helpers.IsHelper(a)) return;

		// who killed it, for the path nodes (the killer's perks); nobody = SoM's plain numbers
		Actor killer = (e.DamageSource && e.DamageSource.player) ? e.DamageSource : null;
		if (!killer && a.target && a.target.player) killer = a.target;

		bool boss = BossHere(a);
		bool thrall = !boss && ThrallHere(a);
		// GOLD FROM (owner 2026-11-22): may this death drop gold? Special Kills Only: a Boss, a Champion or a legendary
		// (GoldKind); Every Kill (old): every one. Read here, at the death (its tokens are there now)
		int gkind = GoldKind(a);
		goldOK = RSQ_KRGoldBit.EveryKill() || gkind > 0;
		goldShareOff = !RSQ_KRGoldBit.EveryKill() && gkind == 3;   // a map boss: its fountain only (owner 2026-11-23)
		int mult = boss ? max(0, SVI("rsqgb_kr_boss", 3)) : 1;
		int num = 0;
		if (SVI("rsqgb_kr_mode", 0) == 1)
		{
			// Range. The chance is rolled per bit in Burst only (2026-11-03: it was rolled here too, so 50% gave ~25%;
			// SoM's per-kill som_kr_chance at the owner's 100 = no roll here).
			int lo = min(SVI("rsqgb_kr_min", 1), SVI("rsqgb_kr_max", 3)), hi = max(SVI("rsqgb_kr_min", 1), SVI("rsqgb_kr_max", 3));
			num = SVB("rsqgb_kr_rnd", true) ? random[RSQKR](lo * mult, hi * mult) : hi * mult;
		}
		else
		{
			num = max(1, int(round(double(a.SpawnHealth() * mult) / HpRatio())));
		}
		// BIT SCAVENGER: +25% a level
		int scav = Perk(killer, "BitScavenger");
		if (scav > 0) num = int(round(num * (1.0 + 0.25 * scav)));
		if (num <= 0) return;
		int nh, na, nm;
		// RSQ SLOWMO'S DOWN v3 (owner 11-07, design/NEAR_DEATH.md "clock and bank"): a kill by a player who is DOWN still
		// bursts into bits, but they fly into his DOWN plate and BANK (paid on his revive as health and armour; ammo bits
		// give their ammo as they arrive -- my reading, the bank pays health and armour only). By name: RSQSM_Service.
		// Only from a kill within 3x his Bits Fly to Me reach (owner 11-07 06:55): those fly to him quickly, so they bank
		// before he gets up; a kill farther off drops ordinary bits.
		bankFor = (killer && DownNow(killer.PlayerNumber()) && a.Distance3D(killer) <= 3.0 * MagnetM(killer) * 34.0) ? killer.PlayerNumber() + 1 : 0;
		if (killer && !bankFor && DownNow(killer.PlayerNumber()) && SVB("rsqgb_kr_debug", false))
			Console.Printf("RSQ KR t%d: player %d is DOWN but %s died %.0f units away (3x Bits Fly to Me: %.0f): ordinary bits", level.maptime,
				killer.PlayerNumber(), cn, a.Distance3D(killer), 3.0 * MagnetM(killer) * 34.0);
		// THE CAP (owner 2026-11-16 11:3x, "100 bits at most"): one death throws at most MAX_BITS bit actors, the gold
		// fountain and a Lucky Kill's extra burst included. Over the cap, each bit carries the worth of several (RSQ_KRBit
		// worth: its health / armour / ammo / gold / steel x worth), so the total reward is what it was. The fountain's
		// slots come first (FOUNTAIN_SLOTS at most), then the burst; with the Lucky Kill node the burst leaves the lucky
		// share of what is left for the extra burst a tic later (1 / (1 + level) to the burst). A death under the cap is
		// untouched: the same rolls, the same bits (an imp's 6 rolls, a Baron's 300).
		int fountN = RSQ_KRGoldBit.FountainCount(a, boss, gkind);
		int fountSlots = min(fountN, FOUNTAIN_SLOTS);
		int lucky = Perk(killer, "LuckyKill");
		int left = MAX_BITS - fountSlots;
		int burstCap = lucky > 0 ? max(1, left / (1 + clamp(lucky, 1, 3))) : left;
		[nh, na, nm] = Burst(a, num, Perk(killer, "RichBits"), boss, thrall ? 1 : 0, burstCap);
		int luckyCap = max(1, left - lastSpawned);
		int shared = lastGold;
		int steelN = lastSteel;
		if (steelN > 0 && RSQ_KRSteelBit.LogOn())
			Console.Printf("RSQ KR steel t%d: %s threw %d steel bit(s), +%d condition each to the guns in hand", level.maptime, cn, steelN, RSQ_KRSteelBit.Value());
		// THE GOLD FOUNTAIN (design/KIOSK.md): a Boss, or a champion, throws gold bits of its own on top
		int fount = RSQ_KRGoldBit.Fountain(a, boss, fountSlots, gkind);
		if (shared + fount > 0 && RSQ_KRGoldBit.LogOn())
			Console.Printf("RSQ KR gold t%d: %s threw %d gold bit(s) (%d of its %d bits, %d fountain%s), worth %d each", level.maptime, cn,
				shared + fount, shared, nh + na + nm + shared, fount, RSQ_KRGoldBit.EveryKill() ? (boss ? ", a Boss" : (fount > 0 ? ", a champion" : ""))
				: (gkind == 3 ? ", a map boss: twice a Boss's fountain" : (gkind == 2 ? ", a Boss" : (gkind == 1 ? ", a champion or legendary" : ""))), RSQ_KRGoldBit.Value());
		else if (lastGoldOff > 0 && RSQ_KRGoldBit.LogOn())
			Console.Printf("RSQ KR gold t%d: %s is no special kill (Gold From: Special Kills Only%s): its %d gold roll(s) dropped nothing", level.maptime, cn,
				thrall || MbThrall(a) ? ", a Boss's thrall" : "", lastGoldOff);
		if (bankFor && SVB("rsqgb_kr_debug", false)) Console.Printf("RSQ KR t%d: player %d is DOWN: these bits fly to his plate and bank", level.maptime, bankFor - 1);
		bankFor = 0;
		// LUCKY KILL: decided next tic (RSQ Score calls a big moment in its own WorldThingDied, which may run after this one)
		if (lucky > 0) { luckyBody.Push(a); luckyBy.Push(killer); luckyNum.Push(num); luckyTic.Push(level.maptime); luckyBoss.Push(boss); luckyThrall.Push(thrall); luckyCapOf.Push(luckyCap); luckyGold.Push(goldOK && !goldShareOff); }
		goldOK = true;
		goldShareOff = false;
		// Debug Log (rsqgb_kr_debug, noarchive): one line a kill, the proof a run can grep for
		if (SVB("rsqgb_kr_debug", false))
			Console.Printf("RSQ KR t%d: %s (%d hp%s) burst into %d bits of %d rolled: %d health, %d armour, %d ammo, %d gold%s; %d bit actors (cap %d, fountain %d of %d)", level.maptime, cn, a.SpawnHealth(),
				a.bBoss ? ", boss" : (boss ? ", miniboss as boss" : (thrall ? ", miniboss thrall" : "")), nh + na + nm + shared + steelN, num, nh, na, nm, shared,
				thrall ? String.Format(" (%d health bits left out: a thrall drops none)", lastNoHealth) : "", lastSpawned, burstCap, fountSlots, fountN);
	}

	// RSQ SlowMo's DOWN (by name): this player is DOWN now
	int bankFor;                     // set around a Burst: player + 1 whose bits bank, 0 none
	static Service SlowMo()
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RSQSM_Service') return s;
		return null;
	}
	static bool DownNow(int pn)
	{
		let s = SlowMo();
		return s && pn >= 0 && s.GetInt("down", "", pn) == 1;
	}

	// num bits out of a body, SoM's throw; Rich Bits (the killer's) draws them glowing (additive) a level
	transient int lastNoHealth;      // health bits a thrall's last Burst left out (the debug line)
	transient int lastGold;          // gold bits the last Burst made in place of other bits
	transient int lastSteel;         // steel bits the last Burst made in place of other bits
	transient int lastSpawned;       // bit actors the last Burst put in the world (<= its cap)
	transient int lastGoldOff;       // gold rolls the last Burst dropped as nothing: not a special kill (Gold From)
	// set before every Burst (WorldThingDied, the lucky burst): this death may drop gold bits. False: a bit that rolls gold
	// is not dropped, so the health, armour, ammo and steel bits are exactly what they were with gold on every kill.
	transient bool goldOK;
	transient bool goldShareOff;     // a map boss (GoldKind 3): its bits roll no gold, they stay health, armour and ammo bits
	const MAX_BITS = 100;            // bit actors one death may throw (owner 2026-11-16, "100 bits at most")
	const FOUNTAIN_SLOTS = 25;       // of them, the gold fountain's at most (its default 20 fits whole)
	// thr: 1 a thrall's, 0 not, -1 ask the body now (ThrallHere): the callers pass what they read at the death
	// cap: bit actors at most (the counts it returns are bits of value: over the cap a bit is worth several)
	int, int, int Burst(Actor a, int num, int rich, bool boss = false, int thr = -1, int cap = MAX_BITS)
	{
		if (num > cap) { int ch, ca, cm; [ch, ca, cm] = BurstCapped(a, num, rich, boss, thr, cap); return ch, ca, cm; }
		lastSpawned = 0;
		int wh, wa, wm;
		[wh, wa, wm] = Mix();
		int sum = wh + wa + wm;
		lastNoHealth = 0;
		// WHAT DROPS all 0: no health, armour or ammo bits, but gold and steel still roll their shares (C16, 2026-11-16: the
		// mix at 0 took them too); with neither, nothing
		int gold0 = RSQ_KRGoldBit.Share(), steel0 = RSQ_KRSteelBit.Share();
		if (sum <= 0 && gold0 <= 0 && steel0 <= 0) return 0, 0, 0;
		bool thrall = !boss && (thr >= 0 ? thr > 0 : ThrallHere(a));     // a miniboss fight's thrall: no health bits (ThrallHere)
		int chance = clamp(SVI("rsqgb_kr_chance", 50), 0, 100);
		int nh = 0, na = 0, nm = 0;
		int gold = RSQ_KRGoldBit.Share();
		int steel = RSQ_KRSteelBit.Share();
		lastGold = 0;
		lastSteel = 0;
		lastGoldOff = 0;
		for (int i = 0; i < num; ++i)
		{
			if (!boss && !a.bBoss && random[RSQKR](1, 100) > chance) continue;
			int r = sum > 0 ? random[RSQKR](1, sum) : 0;
			String cls;
			if (sum > 0 && r <= wh && thrall) { ++lastNoHealth; continue; }
			// GOLD (design/KIOSK.md, owner 2026-11-16): about one bit in four (Gold Share) is a gold bit instead of the health,
			// armour or ammo bit it rolled; only while RSQ Score (the bank) is loaded and Gold Bits is on
			if (gold > 0 && !goldShareOff && random[RSQKR](1, 100) <= gold)
			{
				// GOLD FROM: Special Kills Only and this is none: the gold roll drops nothing (owner 2026-11-22)
				if (!goldOK) { ++lastGoldOff; continue; }
				cls = "RSQ_KRGoldBit"; ++lastGold;
			}
			// STEEL (design/WEAPON_CONDITION.md, owner 2026-11-16): Steel Share of the rest are steel bits (they repair the guns in
			// your hands), only while RSQ Gun Cards' Weapon Condition is on
			else if (steel > 0 && random[RSQKR](1, 100) <= steel) { cls = "RSQ_KRSteelBit"; ++lastSteel; }
			else if (sum <= 0) continue;
			else if (r <= wh) { cls = "RSQ_KRHealthBit"; ++nh; }
			else if (r <= wh + wa) { cls = "RSQ_KRArmorBit"; ++na; }
			else { cls = "RSQ_KRAmmoBit"; ++nm; }
			// SoM's throw: 32 up, 1-6 out and up, a random heading
			bool ok; Actor bit;
			[ok, bit] = a.A_SpawnItemEx(cls, 0, 0, 32, random[RSQKR](1, 6), 0, random[RSQKR](1, 6), random[RSQKR](0, 360));
			// RICH BITS' LOOK (owner 11-02: "emissive", no lights): drawn additive, brighter and a little bigger a level
			if (bit && rich > 0) { bit.A_SetRenderStyle(min(1.0, 0.7 + 0.1 * rich), STYLE_Add); bit.scale *= 1.0 + 0.1 * rich; }
			if (bit && bankFor > 0) BankBit(bit, bankFor);
			if (bit) ++lastSpawned;
		}
		return nh, na, nm;
	}

	// OVER THE CAP: the same per-bit rolls as Burst (chance, the mix, thrall, gold and steel shares), counted instead of
	// thrown; then at most cap bit actors, every kind that rolled any getting at least one, each kind's count shared out
	// over its actors (worth = bits each stands for, the remainder one by one), thrown as SoM's throw.
	int, int, int BurstCapped(Actor a, int num, int rich, bool boss, int thr, int cap)
	{
		int wh, wa, wm;
		[wh, wa, wm] = Mix();
		int sum = wh + wa + wm;
		lastNoHealth = 0; lastGold = 0; lastSteel = 0; lastSpawned = 0; lastGoldOff = 0;
		if (sum <= 0 && RSQ_KRGoldBit.Share() <= 0 && RSQ_KRSteelBit.Share() <= 0) return 0, 0, 0;   // (C16: as Burst)
		bool thrall = !boss && (thr >= 0 ? thr > 0 : ThrallHere(a));
		int chance = clamp(SVI("rsqgb_kr_chance", 50), 0, 100);
		int gold = RSQ_KRGoldBit.Share();
		int steel = RSQ_KRSteelBit.Share();
		int nh = 0, na = 0, nm = 0;
		for (int i = 0; i < num; ++i)
		{
			if (!boss && !a.bBoss && random[RSQKR](1, 100) > chance) continue;
			int r = sum > 0 ? random[RSQKR](1, sum) : 0;
			if (sum > 0 && r <= wh && thrall) { ++lastNoHealth; continue; }
			if (gold > 0 && !goldShareOff && random[RSQKR](1, 100) <= gold) { if (goldOK) ++lastGold; else ++lastGoldOff; }
			else if (steel > 0 && random[RSQKR](1, 100) <= steel) ++lastSteel;
			else if (sum <= 0) continue;
			else if (r <= wh) ++nh;
			else if (r <= wh + wa) ++na;
			else ++nm;
		}
		Array<int> cnt; cnt.Push(nh); cnt.Push(na); cnt.Push(nm); cnt.Push(lastGold); cnt.Push(lastSteel);
		int total = nh + na + nm + lastGold + lastSteel;
		if (total <= 0) return 0, 0, 0;
		cap = max(1, cap);
		// slots per kind: at least one for a kind that rolled any, the rest by share (largest remainder)
		Array<int> slots; int kinds = 0;
		for (int k = 0; k < 5; ++k) { slots.Push(0); if (cnt[k] > 0) kinds++; }
		int free = cap;
		if (total <= cap) { for (int k = 0; k < 5; ++k) slots[k] = cnt[k]; free = 0; }
		else
		{
			for (int k = 0; k < 5; ++k) if (cnt[k] > 0 && free > 0) { slots[k] = 1; free--; }
			int rest = free;
			Array<double> fr;
			for (int k = 0; k < 5; ++k)
			{
				double want = cnt[k] > 0 ? double(cnt[k]) * rest / total : 0;
				int add = min(int(want), cnt[k] - slots[k]);
				slots[k] += add; free -= add; fr.Push(want - int(want));
			}
			while (free > 0)
			{
				int bk = -1;
				for (int k = 0; k < 5; ++k) if (slots[k] < cnt[k] && (bk < 0 || fr[k] > fr[bk])) bk = k;
				if (bk < 0) break;
				slots[bk]++; fr[bk] = -1; free--;
			}
		}
		Array<String> CL; CL.Push("RSQ_KRHealthBit"); CL.Push("RSQ_KRArmorBit"); CL.Push("RSQ_KRAmmoBit"); CL.Push("RSQ_KRGoldBit"); CL.Push("RSQ_KRSteelBit");
		for (int k = 0; k < 5; ++k)
		{
			int n = slots[k];
			if (n <= 0) continue;
			int each = cnt[k] / n, extra = cnt[k] % n;
			for (int j = 0; j < n; ++j)
			{
				int w = each + (j < extra ? 1 : 0);
				bool ok; Actor bit;
				class<Actor> bc = CL[k];
				[ok, bit] = a.A_SpawnItemEx(bc, 0, 0, 32, random[RSQKR](1, 6), 0, random[RSQKR](1, 6), random[RSQKR](0, 360));
				if (!bit) continue;
				++lastSpawned;
				RSQ_KRHandler.SetWorth(bit, w);
				if (rich > 0) { bit.A_SetRenderStyle(min(1.0, 0.7 + 0.1 * rich), STYLE_Add); bit.scale *= 1.0 + 0.1 * rich; }
				if (bankFor > 0) BankBit(bit, bankFor);
			}
		}
		if (SVB("rsqgb_kr_debug", false))
			Console.Printf("RSQ KR t%d: %s: %d bits of value over the %d-bit cap -> %d bit actors (health %d/%d, armour %d/%d, ammo %d/%d, gold %d/%d, steel %d/%d: actors/bits)",
				level.maptime, a.GetClassName(), total, cap, lastSpawned, slots[0], nh, slots[1], na, slots[2], nm, slots[3], lastGold, slots[4], lastSteel);
		return nh, na, nm;
	}

	// a bit standing for w bits: its worth, and a little bigger to show it (x1.1 at 2, up to x2)
	static void SetWorth(Actor bit, int w)
	{
		if (w <= 1) return;
		if (bit is "RSQ_KRHealthBit") RSQ_KRHealthBit(bit).worth = w;
		else if (bit is "RSQ_KRArmorBit") RSQ_KRArmorBit(bit).worth = w;
		else if (bit is "RSQ_KRAmmoBit") RSQ_KRAmmoBit(bit).worth = w;
		else if (bit is "RSQ_KRGoldBit") RSQ_KRGoldBit(bit).worth = w;
		else if (bit is "RSQ_KRSteelBit") RSQ_KRSteelBit(bit).worth = w;
		bit.scale *= min(2.0, 1.0 + 0.1 * sqrt(w - 1));
	}

	// LUCKY KILL (GBOVR_TREES.md 3.14, after Rich Bits 1): a kill that was a critical (Critical Hits, Headshot,
	// Backstab), a Finisher, or a big moment to RSQ Score drops double, triple, x4 -- the extra bits burst out a tic
	// later with a bigger burst. A critical or Finisher counts when it landed within a tic of the death (Gun Bonsai VR's
	// RSQ_Dazed luckyTic, set by its RSQM.Touch); Score's is its own call ("kill.big"). Nothing without the node.
	Array<Actor> luckyBody, luckyBy;
	Array<int> luckyNum, luckyTic;
	Array<bool> luckyBoss;
	Array<int> luckyCapOf;        // the bit actors left for its extra burst under the death's cap (MAX_BITS)
	Array<bool> luckyGold;        // may its extra bits be gold (goldOK, read at its death)
	Array<bool> luckyThrall;      // a thrall's, read at its death (owner 11-16 09:58: a lucky kill's extra bits a tic later
	                              // asked the body, whose inventory Brutal Doom's death can have emptied by then, and a
	                              // thrall's health bit came out: Monsters/docs/ASSEMBLY_AUDIT_2026-11-16.md item 8)
	override void WorldTick()
	{
		for (int i = luckyBody.Size() - 1; i >= 0; i--)
		{
			if (level.maptime <= luckyTic[i]) continue;
			Actor a = luckyBody[i], by = luckyBy[i];
			int num = luckyNum[i], died = luckyTic[i];
			bool boss = i < luckyBoss.Size() && luckyBoss[i];
			bool thr = i < luckyThrall.Size() && luckyThrall[i];
			int lcap = i < luckyCapOf.Size() ? luckyCapOf[i] : MAX_BITS;
			if (i < luckyCapOf.Size()) luckyCapOf.Delete(i);
			bool lgold = i >= luckyGold.Size() || luckyGold[i];
			if (i < luckyGold.Size()) luckyGold.Delete(i);
			luckyBody.Delete(i); luckyBy.Delete(i); luckyNum.Delete(i); luckyTic.Delete(i);
			if (i < luckyBoss.Size()) luckyBoss.Delete(i);
			if (i < luckyThrall.Size()) luckyThrall.Delete(i);
			if (!a || !by || !by.player) continue;
			String why = LuckyWhy(a, died);
			if (why == "") continue;
			int lv = clamp(Perk(by, "LuckyKill"), 1, 3);
			int nh, na, nm;
			goldOK = lgold;
			[nh, na, nm] = Burst(a, num * lv, Perk(by, "RichBits"), boss, thr ? 1 : 0, lcap);
			goldOK = true;
			// the big burst, its thump and Score's "lucky" touch are Gun Bonsai VR's (it owns the node), asked by name
			let gs = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
			if (gs) gs.GetInt("kr.luckyfx", "", by.PlayerNumber(), lv, a);
			if (SVB("rsqgb_kr_debug", false))
				Console.Printf("RSQ KR t%d: lucky kill (%s, Lucky Kill %d): %d more bits, x%d in all", level.maptime, why, lv, nh + na + nm, lv + 1);
		}
	}
	// why it was lucky: Gun Bonsai VR's answer ("kr.lucky": a critical or Finisher within a tic of the death, or RSQ Score's
	// big moment), "" for none or without Gun Bonsai VR
	static String LuckyWhy(Actor a, int died)
	{
		let s = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		return s ? s.GetString("kr.lucky", "", died, 0, a) : "";
	}

	// a bit bound for a DOWN plate: not picked up by touch, no gravity, through walls
	static void BankBit(Actor bit, int forPn)
	{
		if (bit is "RSQ_KRHealthBit") RSQ_KRHealthBit(bit).bankFor = forPn;
		else if (bit is "RSQ_KRArmorBit") RSQ_KRArmorBit(bit).bankFor = forPn;
		else if (bit is "RSQ_KRAmmoBit") RSQ_KRAmmoBit(bit).bankFor = forPn;
		else if (bit is "RSQ_KRGoldBit") RSQ_KRGoldBit(bit).bankFor = forPn;
		else if (bit is "RSQ_KRSteelBit") RSQ_KRSteelBit(bit).bankFor = forPn;   // (C17, 2026-11-16: steel was left on the floor)
		else return;
		bit.bSpecial = false;
		bit.bNoGravity = true;
		bit.bNoClip = true;
		bit.bBright = true;
	}
}

// What every bit shares: SoM's size, the optional lifetime, the magnet.
mixin class RSQ_KRBit
{
	int worth;            // over the death's bit cap: how many bits this one stands for (0 or 1: one)
	int W() { return max(1, worth); }
	int bitLife;
	int bankFor;          // RSQ SlowMo's DOWN: player + 1 whose plate this bit flies to and banks in (0: an ordinary bit)
	int bankAge;
	bool bankGiven;

	// THE FLIGHT INTO THE PLATE (DOWN v3): a short burst out of the body first (SoM's throw, 3 tics), then straight to the
	// plate (RSQSM_Service GetObject "down.plate", by name), QUICKLY (owner 11-07 06:55: 12 units a tic, +3 a tic, so a bit at
	// 3x the 2 m reach is there in about 8 tics); there it banks (RSQSM_Service "down.bank")
	// -- health and armour by what the bit is worth to that player (Rich Bits counted); an ammo bit gives its ammo instead.
	// No plate (DOWN over, or not the console player's) or 6 s: it gives itself to the player as an ordinary bit would.
	void BankTick()
	{
		Actor pmo = null;
		if (bankFor > 0 && bankFor <= MAXPLAYERS && playeringame[bankFor - 1]) pmo = players[bankFor - 1].mo;
		if (!pmo) { Destroy(); return; }
		bankAge++;
		let sv = RSQ_KRHandler.SlowMo();
		Actor plate = null;
		bool downNow = false;
		if (sv)
		{
			plate = Actor(sv.GetObject("down.plate", "", bankFor - 1));
			downNow = sv.GetInt("down", "", bankFor - 1) == 1;
		}
		if (!downNow || bankAge > 210)
		{
			// DOWN ended before it arrived: an ordinary bit, given now
			bSpecial = true;
			bankGiven = true;
			bool ok; Actor tg;
			[ok, tg] = CallTryPickup(pmo);
			if (!ok) Destroy();
			return;
		}
		if (bankAge < 3) { vel *= 0.85; return; }
		Vector3 goal = pmo.pos + (0, 0, pmo.height * 0.5);
		if (plate) goal = plate.pos;
		Vector3 to = goal - pos;
		double l = to.Length();
		if (l < 6 || (!plate && l < pmo.radius + 8))
		{
			Arrive(pmo, sv);
			return;
		}
		vel = to / l * min(l, 12.0 + bankAge * 3.0);
	}
	void Arrive(Actor pmo, Service sv)
	{
		int pn = bankFor - 1;
		int lv = RSQ_KRHandler.Perk(pmo, "RichBits");
		String kind = "";
		double amt = 0;
		if (self is "RSQ_KRHealthBit") { kind = "health"; amt = 25 * (1 + lv) * W(); }
		else if (self is "RSQ_KRArmorBit") { kind = "armor"; amt = 10 * (1 + lv) * W(); }
		if (kind != "")
		{
			int r = 0;
			if (sv) r = sv.GetInt("down.bank", kind, pn, amt);
			if (RSQ_KRHandler.SVB("rsqgb_kr_debug", false)) Console.Printf("RSQ KR t%d: a %s bit flew into player %d's DOWN plate: +%.0f banked (%d)", level.maptime, kind, pn, amt, r);
			Destroy();
			return;
		}
		bSpecial = true;
		bankGiven = true;
		bool ok; Actor tg;
		[ok, tg] = CallTryPickup(pmo);          // the ammo bit: its ammo now
		if (!ok) Destroy();
	}
	// HOW A BIT GOES (owner 2026-11-06, BUGS_1.0 #37: "Nice fade-out: or flash fullbright a few tics, faster and faster,
	// then blink out"; he chose both, a menu choice, Blink Out the default): rsqgb_kr_vanish 0 BLINK OUT, its last BLINK_T
	// tics it flashes fullbright (a 2-tic flash, additive and full, then its own look), the gaps shrinking from 12 tics to
	// 1, then it is gone; 1 FADE OUT, its last FADE_T tics (about a second) it fades smoothly to nothing. RSQ
	// Accessibility's Photosensitive Mode always fades (no strobe).
	bool vanishing;
	int vanStyle;
	double vanAlpha;
	void VanishTick(int left)
	{
		int BLINK_T = 70;
		int FADE_T = 35;
		bool fade = RSQ_KRHandler.SVI("rsqgb_kr_vanish", 0) == 1 || RSQTHP_A11y.Photo();
		if (left > (fade ? FADE_T : BLINK_T)) return;
		if (!vanishing) { vanishing = true; vanStyle = GetRenderStyle(); vanAlpha = alpha; }
		if (fade)
		{
			if (vanStyle == STYLE_Normal) A_SetRenderStyle(vanAlpha, STYLE_Translucent);
			alpha = vanAlpha * clamp(left / double(FADE_T), 0.0, 1.0);
			bBright = false;
			return;
		}
		// the flashes: 2 tics each from the window's start, the gap after each 3/4 of the last (12 tics down to 1)
		int t = BLINK_T - left, pos = 0;
		double gap = 12;
		bool on = false;
		while (pos <= t)
		{
			if (t < pos + 2) { on = true; break; }
			pos += 2 + int(gap);
			gap = max(1.0, gap * 0.75);
		}
		bBright = on;
		if (on) A_SetRenderStyle(1.0, STYLE_Add);
		else A_SetRenderStyle(vanAlpha, vanStyle);
	}

	void BitTick()
	{
		// a bit already picked up (owned, or no longer SPECIAL: its last tic in the world, HoldAndDestroy) neither times out
		// nor flies, and is never touched again -- the engine only touches SPECIAL things. Found on the rig 2026-11-03 (the
		// merge's proof; the old Gun Bonsai VR pk3 did the same): an armour bit picked up with Magnet on was "touched" once
		// more inside Magnet's reach -> VM abort, "tried to write to address zero" in AddInventory.
		// (rig 11-09, DOWN v3) a banked bit that has given itself (DOWN over before it arrived) is done: the next tic it is
		// HoldAndDestroy, unowned and not SPECIAL, and giving it again aborted the VM in AddInventory
		if (bankGiven) return;
		if (bankFor > 0 && !Owner) { BankTick(); return; }
		if (Owner || !bSpecial) return;
		int life = RSQ_KRHandler.SVI("rsqgb_kr_life", 7);
		if (life > 0 && ++bitLife >= life * TICRATE) { Destroy(); return; }
		if (life > 0) VanishTick(life * TICRATE - bitLife);
		// Bits Fly to Me: inside the radius a bit drifts to the middle of the nearest player's body
		if (level.maptime & 1) return;
		// MAGNET (the path node) or the row, whichever reaches further, per player
		Actor best = null; double bd = 1e9;
		for (int p = 0; p < MAXPLAYERS; ++p)
		{
			if (!playeringame[p] || !players[p].mo || players[p].mo.health <= 0) continue;
			double reach = RSQ_KRHandler.MagnetM(players[p].mo) * 34.0;
			if (reach <= 0) continue;
			double d = Distance3D(players[p].mo);
			if (d < reach && d < bd) { best = players[p].mo; bd = d; }
		}
		if (!best) return;
		Vector3 to = (best.pos + (0, 0, best.height * 0.5)) - pos;
		double l = to.Length();
		// arrived: picked up here (the engine only picks an item up when the PLAYER moves into it, and a VR player standing
		// still never does)
		if (l < best.radius + radius + 8) { Touch(best); return; }
		if (l > 1) vel = to / l * min(8.0, 2.0 + l * 0.1);
		bNoGravity = true;
	}
}

class RSQ_KRHealthBit : Health
{
	mixin RSQ_KRBit;
	Default
	{
		Radius 10; Height 8;
		Inventory.Amount 25;            // SoM's value (his readme says "a single point"; his code says 25)
		Inventory.PickupMessage "";
		+INVENTORY.ALWAYSPICKUP;        // never left lying because you are full; it heals what it can
	}
	override void Tick() { Super.Tick(); if (!bDestroyed) BitTick(); }
	override bool TryPickup(in out Actor toucher)
	{
		// Rich Bits: worth 2, 3, 4 x at levels 1-3
		int lv = RSQ_KRHandler.Perk(toucher, "RichBits");
		Amount = 25 * (1 + lv) * W();
		return Super.TryPickup(toucher);
	}
	States { Spawn: KRBH A 4; KRBH A 4 BRIGHT; Loop; }
}

class RSQ_KRArmorBit : BasicArmorBonus
{
	mixin RSQ_KRBit;
	Default
	{
		Radius 10; Height 8;
		Inventory.PickupMessage "";
		Armor.SavePercent 33.335;       // SoM's: green armour's rate
		Armor.SaveAmount 10;
		Armor.MaxSaveAmount 250;
	}
	override void Tick() { Super.Tick(); if (!bDestroyed) BitTick(); }
	override bool TryPickup(in out Actor toucher)
	{
		int lv = RSQ_KRHandler.Perk(toucher, "RichBits");
		SaveAmount = 10 * (1 + lv) * W();
		return Super.TryPickup(toucher);
	}
	States { Spawn: KRBA A 4; KRBA A 4 BRIGHT; Loop; }
}

// The ammo bit: 5 rounds of one ammo type the TOUCHER uses (SoM read players[consoleplayer], which is the wrong
// player in a netgame; the toucher is the one who picked it up). "The gun in hand" = the toucher's ready weapon
// (either hand's: the main hand first, the off hand if the main hand holds nothing that uses ammo); "any gun" =
// one of every weapon carried, at random. A toucher with no gun that uses ammo still picks it up and gets nothing
// (SoM's rule).
class RSQ_KRAmmoBit : Inventory
{
	mixin RSQ_KRBit;
	Default
	{
		Radius 10; Height 8;
		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
		+INVENTORY.ALWAYSPICKUP;
	}
	override void Tick() { Super.Tick(); if (!bDestroyed) BitTick(); }

	static void AmmoOf(Weapon w, Array<Class<Ammo> > list)
	{
		if (!w) return;
		if (RSQ_KRHandler.SVB("rsqgb_kr_ammotype1", true) && w.AmmoType1) list.Push(w.AmmoType1);
		if (RSQ_KRHandler.SVB("rsqgb_kr_ammotype2", false) && w.AmmoType2) list.Push(w.AmmoType2);
	}

	override bool TryPickup(in out Actor toucher)
	{
		let pmo = PlayerPawn(toucher);
		if (!pmo || !pmo.player) return false;
		Array<Class<Ammo> > ammos;
		if (RSQ_KRHandler.SVI("rsqgb_kr_ammo_mode", 1) == 0)
		{
			AmmoOf(pmo.player.ReadyWeapon, ammos);
			if (ammos.Size() == 0) AmmoOf(pmo.player.OffhandWeapon, ammos);
		}
		else
		{
			for (Inventory it = pmo.Inv; it; it = it.Inv) AmmoOf(Weapon(it), ammos);
		}
		// SCAVENGER 3 (the grenade's, GBOVR_TREES.md 4.5 Carry): one bit in four is a grenade instead (by name; nothing
		// without RSQ Grenade)
		// Over a death's bit cap one bit stands for W() bits: each of them rolls on its own, as separate bits would (W() 1:
		// the one roll, as before).
		{
			// names through Strings: a literal is checked when the pack compiles, and without RSQ Grenade
			String gwn = "RSQGN_Grenade", gamn = "RSQGN_Ammo";
			Class<Inventory> gwc = gwn;
			Class<Inventory> gam = gamn;
			let gw = gwc ? Weapon(pmo.FindInventory(gwc)) : null;
			let gs = gw ? ServiceIterator.Find("RSQ_MeleeUpgradeService").Next() : null;
			bool scav3 = gw && gam && gs && gs.GetInt("level", "Scavenger", 0, 0, gw) >= 3;
			int lv = RSQ_KRHandler.Perk(pmo, "RichBits");
			for (int b = 0; b < W(); ++b)
			{
				if (scav3 && random[RSQKR](0, 3) == 0) { pmo.GiveInventory(gam, 1); continue; }
				if (ammos.Size() > 0)
				{
					let am = ammos[random[RSQKR](0, ammos.Size() - 1)];
					pmo.GiveInventory(am, 5 + 3 * lv);     // Rich Bits: 8, 11, 14
				}
			}
		}
		GoAwayAndDie();
		return true;
	}
	States { Spawn: KRBM A 4; KRBM A 4 BRIGHT; Loop; }
}

// THE PATH (Bit Scavenger, Rich Bits, Magnet, Lucky Kill) is Gun Bonsai VR's: its rsq/zscript/up_killrewards.zs.

// THE GOLD BIT (design/KIOSK.md, owner 2026-11-16 04:47-04:52: "gold will come from... bits?"; his answer "Both"): a Kill
// Rewards bit in gold (sprite KRBG, SoM's orb recoloured, twinkling: tools/gen_gold_bit.py). It bursts out with the others,
// flies to you, blinks out like every bit (RSQ_KRBit), and banks its gold in RSQ Score by name (RS_ScoreService "gold.add").
//   GOLD FROM       rsqvr_gold_from (owner 2026-11-22): 0 SPECIAL KILLS ONLY (the default): only a Boss (RSQ Miniboss's Boss or
//                   Big Boss), a Champion or a LegenDoom legendary drops gold (RSQ_KRHandler.GoldKind); a common monster and a
//                   Boss's thrall drop none (a map's BOSS-flag monster counts as a Boss), and a gold roll of theirs drops nothing, so their health, armour, ammo and steel
//                   bits are exactly what they were. 1 EVERY KILL (old): every kill, the fountains as below in brackets
//   GOLD SHARE      rsqvr_gold_share % of a kill's bits are gold in place of the health / armour / ammo bit they rolled (25)
//   GOLD PER BIT    rsqvr_gold_value gold each
//   THE FOUNTAIN    a Boss throws rsqvr_gold_fountain more, a Champion or a legendary rsqvr_gold_champion more (Every Kill: a
//                   Boss is Kill Rewards' boss, the engine's BOSS flag or RSQ Miniboss's Boss, and a champion is Champion()
//                   below, a legendary champion); thrown high, every one (no drop chance)
//   ONLY WITH SCORE no RSQ Score, no bank: no gold bits at all (Gold Bits on or off)
//   THE LOG         Gold Log (rsqvr_gold_log): a line for every kill that threw gold, and one for every gold bit picked up
// Rich Bits does not change a gold bit's worth (my reading: the kiosk's prices are tuned against plain gold).
// Rig only, not headset-confirmed.
class RSQ_KRGoldBit : Inventory
{
	mixin RSQ_KRBit;
	bool fromFountain;
	Default
	{
		Radius 10; Height 8;
		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
		+INVENTORY.ALWAYSPICKUP;
	}
	override void Tick() { Super.Tick(); if (!bDestroyed) BitTick(); }

	static bool LogOn() { return RSQ_KRHandler.SVB("rsqvr_gold_log", false); }
	static int Value() { return max(0, RSQ_KRHandler.SVI("rsqvr_gold_value", 5)); }
	// Gold From (owner 2026-11-22): 0 Special Kills Only (RSQ_KRHandler.GoldKind), 1 Every Kill (the old way)
	static bool EveryKill() { return RSQ_KRHandler.SVI("rsqvr_gold_from", 0) == 1; }

	static Service Bank()
	{
		let it = ServiceIterator.Find("RS_ScoreService");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RS_ScoreService') return s;
		return null;
	}

	// the share of bits that are gold, 0 when there is no bank or Gold Bits is off
	static int Share()
	{
		if (!RSQ_KRHandler.SVB("rsqvr_gold", true) || !Bank()) return 0;
		return clamp(RSQ_KRHandler.SVI("rsqvr_gold_share", 25), 0, 100);
	}

	// A CHAMPION HERE is the Series' elite: a Champion (Champions' champion_PersistentInfo, or a colour token given by name)
	// that is also a LegenDoom legendary (LDLegendaryMonsterToken): a boosted legendary champion, as BD22 VR Reloaded's
	// legendary drops and a Boss's thralls count them. Not every Champion: on the owner's skill (Black Metal) Champions makes
	// every monster one (its chance is (4 + 10 x skill) x (skill + 1) / 256), and a fountain on every kill is not "a few
	// gold bits from every kill" (rig kq_econ1: 150 kills, 150 fountains). My reading, design/KIOSK.md.
	static bool Champion(Actor a)
	{
		String ln = "LDLegendaryMonsterToken";
		class<Inventory> lc = ln;
		if (!lc || !a.FindInventory(lc)) return false;
		String pn = "champion_PersistentInfo";
		class<Inventory> pc = pn;
		if (pc && a.FindInventory(pc)) return true;
		for (let i = a.Inv; i; i = i.Inv) { String cn = i.GetClassName(); if (cn.Left(9) ~== "champion_" && cn.IndexOf("Token") >= 0 && !(cn ~== "champion_NullToken")) return true; }
		return false;
	}

	// a Boss's or a champion's fountain: how many it threw
	// the fountain's gold bits for this death (no spawning): the per-death cap reserves their slots first
	// gkind: RSQ_KRHandler.GoldKind at the death (Special Kills Only: 3 twice the Boss Gold Fountain (a map boss, 2026-11-23),
	// 2 the Boss Gold Fountain, 1 the Champion Gold Fountain,
	// 0 none). Every Kill (the old way): Kill Rewards' boss, or Champion() above, as before 2026-11-22.
	static int FountainCount(Actor a, bool boss, int gkind = 0)
	{
		if (!a || !RSQ_KRHandler.SVB("rsqvr_gold", true) || !Bank()) return 0;
		int n;
		if (EveryKill()) n = boss ? RSQ_KRHandler.SVI("rsqvr_gold_fountain", 20) : (Champion(a) ? RSQ_KRHandler.SVI("rsqvr_gold_champion", 6) : 0);
		else n = gkind == 3 ? 2 * RSQ_KRHandler.SVI("rsqvr_gold_fountain", 20)      // a map boss: twice a Boss (owner 2026-11-23)
			: (gkind == 2 ? RSQ_KRHandler.SVI("rsqvr_gold_fountain", 20) : (gkind == 1 ? RSQ_KRHandler.SVI("rsqvr_gold_champion", 6) : 0));
		return clamp(n, 0, 200);
	}
	// slots: bit actors it may throw (the cap, RSQ_KRHandler.FOUNTAIN_SLOTS); more gold bits than slots ride as worth
	static int Fountain(Actor a, bool boss, int slots = 200, int gkind = 0)
	{
		int n = FountainCount(a, boss, gkind);
		if (n <= 0) return 0;
		int m = clamp(slots, 1, n);
		int each = n / m, extra = n % m;
		for (int i = 0; i < m; ++i)
		{
			bool ok; Actor bit;
			[ok, bit] = a.A_SpawnItemEx("RSQ_KRGoldBit", 0, 0, 32, frandom[RSQKR](1, 5), 0, frandom[RSQKR](5, 11), random[RSQKR](0, 360));
			if (bit) { RSQ_KRGoldBit(bit).fromFountain = true; RSQ_KRHandler.SetWorth(bit, each + (i < extra ? 1 : 0)); }
		}
		return n;
	}

	override bool TryPickup(in out Actor toucher)
	{
		let pmo = PlayerPawn(toucher);
		if (!pmo || !pmo.player) return false;
		let s = Bank();
		int v = Value() * W();
		int bank = s ? s.GetInt("gold.add", fromFountain ? "gold bit (fountain)" : "gold bit", v, 0, pmo) : -1;
		if (LogOn()) Console.Printf("RSQ KR gold t%d: a gold bit%s picked up by player %d: +%d -> bank %d", level.maptime, fromFountain ? " (fountain)" : "",
			pmo.PlayerNumber(), v, bank);
		pmo.A_StartSound("misc/i_pkup", CHAN_ITEM, CHANF_OVERLAP, 0.5, ATTN_NORM, 1.6);
		GoAwayAndDie();
		return true;
	}
	States { Spawn: KRBG A 4 BRIGHT; KRBG B 4 BRIGHT; Loop; }
}

// THE STEEL BIT (design/WEAPON_CONDITION.md, owner 2026-11-16: "steel kill-reward bits ... +1 per bit per held gun"): a Kill
// Rewards bit in steel grey (sprite KRBS, SoM's orb recoloured, twinkling: tools/gen_steel_bit.py). It bursts out with the
// others, flies to you, blinks out like every bit (RSQ_KRBit), and repairs each gun in your hands by Condition per Steel Bit
// (1), through RSQ Gun Cards by name (RSQGC_Service "cnd.repair").
//   STEEL SHARE     rsqvr_steel_share % of a kill's bits (those not already gold) are steel in place of the health / armour /
//                   ammo bit they rolled (15)
//   ONLY WITH       RSQ Gun Cards' Weapon Condition on (rsqgc_cnd, off by default): off, or no Gun Cards, no steel bits at all
//   THE LOG         Steel Log (rsqvr_steel_log): a line for every kill that threw steel, and one for every steel bit picked up
// Rig only, not headset-confirmed.
class RSQ_KRSteelBit : Inventory
{
	mixin RSQ_KRBit;
	Default
	{
		Radius 10; Height 8;
		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
		+INVENTORY.ALWAYSPICKUP;
	}
	override void Tick() { Super.Tick(); if (!bDestroyed) BitTick(); }

	static bool LogOn() { return RSQ_KRHandler.SVB("rsqvr_steel_log", false); }
	static int Value() { return max(0, RSQ_KRHandler.SVI("rsqvr_steel_value", 1)); }

	static Service Cards()
	{
		let it = ServiceIterator.Find("RSQGC_Service");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RSQGC_Service') return s;
		return null;
	}

	// the share of bits that are steel, 0 when Weapon Condition is off (or no Gun Cards) or Steel Bits is off
	static int Share()
	{
		if (!RSQ_KRHandler.SVB("rsqvr_steel", true)) return 0;
		let s = Cards();
		if (!s || s.GetInt("cnd.on") != 1) return 0;
		return clamp(RSQ_KRHandler.SVI("rsqvr_steel_share", 15), 0, 100);
	}

	override bool TryPickup(in out Actor toucher)
	{
		let pmo = PlayerPawn(toucher);
		if (!pmo || !pmo.player) return false;
		let s = Cards();
		int v = Value() * W();
		int got = s ? s.GetInt("cnd.repair", "steel bit", v, 0, pmo) : 0;
		if (LogOn()) Console.Printf("RSQ KR steel t%d: a steel bit picked up by player %d: +%d to %d gun(s) in hand", level.maptime, pmo.PlayerNumber(), v, got);
		pmo.A_StartSound("misc/i_pkup", CHAN_ITEM, CHANF_OVERLAP, 0.5, ATTN_NORM, 0.8);
		if (got > 0) pmo.A_StartSound("weapons/sshotl", CHAN_AUTO, CHANF_OVERLAP, 0.35, ATTN_NORM, 1.4);
		GoAwayAndDie();
		return true;
	}
	States { Spawn: KRBS A 4 BRIGHT; KRBS B 4 BRIGHT; Loop; }
}
