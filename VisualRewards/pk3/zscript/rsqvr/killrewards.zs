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

	// RSQ MINIBOSS'S BOSSFIGHT (owner 11-05: "tons of Kill Rewards bits"): a called-in miniboss is worth this many times
	// the boss bits (RSQMB_Service "bossfor" "rewards.x", by name; 1 for any other boss, or without Miniboss).
	static int BossfightX(Actor a)
	{
		String wn = "RSQMB_Ward";
		class<Inventory> wc = wn;
		if (!a || !wc || !a.FindInventory(wc)) return 1;
		let sv = ServiceIterator.Find("RSQMB_Service").Next();
		return sv ? clamp(sv.GetInt("bossfor", "rewards.x", 0, 0, a), 1, 20) : 1;
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
		int mult = boss ? max(0, SVI("rsqgb_kr_boss", 3)) * BossfightX(a) : 1;
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
		bankFor = (killer && DownNow(killer.PlayerNumber())) ? killer.PlayerNumber() + 1 : 0;
		[nh, na, nm] = Burst(a, num, Perk(killer, "RichBits"), boss);
		if (bankFor && SVB("rsqgb_kr_debug", false)) Console.Printf("RSQ KR t%d: player %d is DOWN: these bits fly to his plate and bank", level.maptime, bankFor - 1);
		bankFor = 0;
		// LUCKY KILL: decided next tic (RSQ Score calls a big moment in its own WorldThingDied, which may run after this one)
		int lucky = Perk(killer, "LuckyKill");
		if (lucky > 0) { luckyBody.Push(a); luckyBy.Push(killer); luckyNum.Push(num); luckyTic.Push(level.maptime); luckyBoss.Push(boss); }
		// Debug Log (rsqgb_kr_debug, noarchive): one line a kill, the proof a run can grep for
		if (SVB("rsqgb_kr_debug", false))
			Console.Printf("RSQ KR t%d: %s (%d hp%s) burst into %d bits of %d rolled: %d health, %d armour, %d ammo", level.maptime, cn, a.SpawnHealth(),
				a.bBoss ? ", boss" : (boss ? ", miniboss as boss" : ""), nh + na + nm, num, nh, na, nm);
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
	int, int, int Burst(Actor a, int num, int rich, bool boss = false)
	{
		int wh, wa, wm;
		[wh, wa, wm] = Mix();
		int sum = wh + wa + wm;
		if (sum <= 0) return 0, 0, 0;
		int chance = clamp(SVI("rsqgb_kr_chance", 50), 0, 100);
		int nh = 0, na = 0, nm = 0;
		for (int i = 0; i < num; ++i)
		{
			if (!boss && !a.bBoss && random[RSQKR](1, 100) > chance) continue;
			int r = random[RSQKR](1, sum);
			String cls;
			if (r <= wh) { cls = "RSQ_KRHealthBit"; ++nh; }
			else if (r <= wh + wa) { cls = "RSQ_KRArmorBit"; ++na; }
			else { cls = "RSQ_KRAmmoBit"; ++nm; }
			// SoM's throw: 32 up, 1-6 out and up, a random heading
			bool ok; Actor bit;
			[ok, bit] = a.A_SpawnItemEx(cls, 0, 0, 32, random[RSQKR](1, 6), 0, random[RSQKR](1, 6), random[RSQKR](0, 360));
			// RICH BITS' LOOK (owner 11-02: "emissive", no lights): drawn additive, brighter and a little bigger a level
			if (bit && rich > 0) { bit.A_SetRenderStyle(min(1.0, 0.7 + 0.1 * rich), STYLE_Add); bit.scale *= 1.0 + 0.1 * rich; }
			if (bit && bankFor > 0) BankBit(bit, bankFor);
		}
		return nh, na, nm;
	}

	// LUCKY KILL (GBOVR_TREES.md 3.14, after Rich Bits 1): a kill that was a critical (Critical Hits, Headshot,
	// Backstab), a Finisher, or a big moment to RSQ Score drops double, triple, x4 -- the extra bits burst out a tic
	// later with a bigger burst. A critical or Finisher counts when it landed within a tic of the death (Gun Bonsai VR's
	// RSQ_Dazed luckyTic, set by its RSQM.Touch); Score's is its own call ("kill.big"). Nothing without the node.
	Array<Actor> luckyBody, luckyBy;
	Array<int> luckyNum, luckyTic;
	Array<bool> luckyBoss;
	override void WorldTick()
	{
		for (int i = luckyBody.Size() - 1; i >= 0; i--)
		{
			if (level.maptime <= luckyTic[i]) continue;
			Actor a = luckyBody[i], by = luckyBy[i];
			int num = luckyNum[i], died = luckyTic[i];
			bool boss = i < luckyBoss.Size() && luckyBoss[i];
			luckyBody.Delete(i); luckyBy.Delete(i); luckyNum.Delete(i); luckyTic.Delete(i);
			if (i < luckyBoss.Size()) luckyBoss.Delete(i);
			if (!a || !by || !by.player) continue;
			String why = LuckyWhy(a, died);
			if (why == "") continue;
			int lv = clamp(Perk(by, "LuckyKill"), 1, 3);
			int nh, na, nm;
			[nh, na, nm] = Burst(a, num * lv, Perk(by, "RichBits"), boss);
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
	int bitLife;
	int bankFor;          // RSQ SlowMo's DOWN: player + 1 whose plate this bit flies to and banks in (0: an ordinary bit)
	int bankAge;

	// THE FLIGHT INTO THE PLATE (DOWN v3): a short burst out of the body first (SoM's throw, 6 tics), then straight to the
	// plate (RSQSM_Service GetObject "down.plate", by name), faster and faster; there it banks (RSQSM_Service "down.bank")
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
			bool ok; Actor tg;
			[ok, tg] = CallTryPickup(pmo);
			if (!ok) Destroy();
			return;
		}
		if (bankAge < 6) { vel *= 0.85; return; }
		Vector3 goal = pmo.pos + (0, 0, pmo.height * 0.5);
		if (plate) goal = plate.pos;
		Vector3 to = goal - pos;
		double l = to.Length();
		if (l < 6 || (!plate && l < pmo.radius + 8))
		{
			Arrive(pmo, sv);
			return;
		}
		vel = to / l * min(l, 4.0 + bankAge * 0.6);
	}
	void Arrive(Actor pmo, Service sv)
	{
		int pn = bankFor - 1;
		int lv = RSQ_KRHandler.Perk(pmo, "RichBits");
		String kind = "";
		double amt = 0;
		if (self is "RSQ_KRHealthBit") { kind = "health"; amt = 25 * (1 + lv); }
		else if (self is "RSQ_KRArmorBit") { kind = "armor"; amt = 10 * (1 + lv); }
		if (kind != "")
		{
			int r = 0;
			if (sv) r = sv.GetInt("down.bank", kind, pn, amt);
			if (RSQ_KRHandler.SVB("rsqgb_kr_debug", false)) Console.Printf("RSQ KR t%d: a %s bit flew into player %d's DOWN plate: +%.0f banked (%d)", level.maptime, kind, pn, amt, r);
			Destroy();
			return;
		}
		bSpecial = true;
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
		if (bankFor > 0 && !Owner) { BankTick(); return; }
		if (Owner || !bSpecial) return;
		int life = RSQ_KRHandler.SVI("rsqgb_kr_life", 7);
		if (life > 0 && ++bitLife >= life * TICRATE) { Destroy(); return; }
		if (life > 0) VanishTick(life * TICRATE - bitLife);
		// Bits Fly to Me: inside the radius a bit drifts to the nearest player's hand height
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
	override void Tick() { Super.Tick(); BitTick(); }
	override bool TryPickup(in out Actor toucher)
	{
		// Rich Bits: worth 2, 3, 4 x at levels 1-3
		int lv = RSQ_KRHandler.Perk(toucher, "RichBits");
		Amount = 25 * (1 + lv);
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
	override void Tick() { Super.Tick(); BitTick(); }
	override bool TryPickup(in out Actor toucher)
	{
		int lv = RSQ_KRHandler.Perk(toucher, "RichBits");
		SaveAmount = 10 * (1 + lv);
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
	override void Tick() { Super.Tick(); BitTick(); }

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
		{
			// names through Strings: a literal is checked when the pack compiles, and without RSQ Grenade that is an error
			String gwn = "RSQGN_Grenade", gamn = "RSQGN_Ammo";
			Class<Inventory> gwc = gwn;
			Class<Inventory> gam = gamn;
			let gw = gwc ? Weapon(pmo.FindInventory(gwc)) : null;
			let gs = gw ? ServiceIterator.Find("RSQ_MeleeUpgradeService").Next() : null;
			if (gw && gam && gs && gs.GetInt("level", "Scavenger", 0, 0, gw) >= 3 && random[RSQKR](0, 3) == 0)
			{
				pmo.GiveInventory(gam, 1);
				GoAwayAndDie();
				return true;
			}
		}
		if (ammos.Size() > 0)
		{
			let am = ammos[random[RSQKR](0, ammos.Size() - 1)];
			int lv = RSQ_KRHandler.Perk(pmo, "RichBits");
			pmo.GiveInventory(am, 5 + 3 * lv);     // Rich Bits: 8, 11, 14
		}
		GoAwayAndDie();
		return true;
	}
	States { Spawn: KRBM A 4; KRBM A 4 BRIGHT; Loop; }
}

// THE PATH (Bit Scavenger, Rich Bits, Magnet, Lucky Kill) is Gun Bonsai VR's: its rsq/zscript/up_killrewards.zs.
