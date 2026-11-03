// KILL REWARDS -- monsters burst into bits of health, armour and ammo when they die.
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
// WHAT HAPPENS. A monster dies (WorldThingDied, bIsMonster, not one of Brutal Doom's boot-smear corpses). N bits
// burst out of it 32 units up, thrown 1-6 sideways and up on a random heading:
//   N  By Health (default; the owner 2026-11-03 10:16, after trying Range: "I dropped a cyber demon and it shot out
//      1000 bits"): spawn health / (10 at Standard) rounded, at least 1, x the boss fountain (3) for a BOSS.
//      Range: a random 1-3 (x boss).
//   each bit rolls the drop chance (50%, SoM's som_kr_per; a boss always drops every bit), then its KIND by the mix
//   (Custom 15 / 20 / 65): health (KRBH, 25 health), armour (KRBA, 10 green armour, up to 250), ammo (KRBM, 5 rounds
//   of any gun you carry, or of the gun in your hand). Bits vanish after 7 s (SoM's 35 tics x 7; 0 = never). Bits Fly
//   to Me pulls bits inside a radius toward you (0 = off; the Magnet node raises it).
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
//   rsqgb_kr_ammo_mode 0 the gun in hand, 1 any gun carried                    (1)
//   rsqgb_kr_ammotype1 / _ammotype2  bool  on / off   which of a gun's two ammo types count (clip mods: see SoM)
//   rsqgb_kr_magnet    float  0.0     metres bits drift to you from, 0 off
//   rsqgb_kr_min / _max / _rnd   Range mode: 1, 3, on
class RSQ_KRHandler : EventHandler
{
	static const String BLACKLIST[] = { "BootSmearerRed", "BootSmearerBlue", "BootSmearerGreen",   // "Because Brutal Doom..." (SoM)
		"NewCybersHitBox" };
	// Brutal Doom's head hitboxes (owner 2026-11-03: yes): HeadHitbox is +ISMONSTER -COUNTKILL, 9999 hp, and dies with the
	// monster it rides, so a BD Cyberdemon also burst its NewCybersHitBox (1000 bits rolled). Every class descended from
	// one of these is skipped too (in brutal22test6: NewCybersHitBox, the Noble/Baron/Knight/Boss/Dying_Noble headshots,
	// Dying_Headshot, Slumped*_Headshot, Vile_HeadHitbox, Mancu/Bones headshots, the SaciLol ones). By name: no BD, no effect.
	static const String BLACKBASE[] = { "HeadHitbox" };

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
	// MAGNET: bits inside 2, 3, 4 m drift to you; the Bits Fly to Me row (metres) when it reaches further
	static double MagnetM(Actor pawn)
	{
		static const double M[] = { 0, 2, 3, 4 };
		return max(SV("rsqgb_kr_magnet", 0.0), M[clamp(Perk(pawn, "Magnet"), 0, 3)]);
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

	override void WorldThingDied(WorldEvent e)
	{
		if (!SVB("rsqgb_kr_enabled", true)) return;
		Actor a = e.Thing;
		if (!a || !a.bIsMonster) return;
		String cn = a.GetClassName();
		for (int i = 0; i < BLACKLIST.Size(); ++i) if (cn == BLACKLIST[i]) return;
		for (int i = 0; i < BLACKBASE.Size(); ++i) { class<Actor> bc = BLACKBASE[i]; if (bc && a is bc) return; }

		// who killed it, for the path nodes (the killer's perks); nobody = SoM's plain numbers
		Actor killer = (e.DamageSource && e.DamageSource.player) ? e.DamageSource : null;
		if (!killer && a.target && a.target.player) killer = a.target;

		bool boss = BossHere(a);
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
		[nh, na, nm] = Burst(a, num, Perk(killer, "RichBits"), boss);
		// LUCKY KILL: decided next tic (RSQ Score calls a big moment in its own WorldThingDied, which may run after this one)
		int lucky = Perk(killer, "LuckyKill");
		if (lucky > 0) { luckyBody.Push(a); luckyBy.Push(killer); luckyNum.Push(num); luckyTic.Push(level.maptime); luckyBoss.Push(boss); }
		// Debug Log (rsqgb_kr_debug, noarchive): one line a kill, the proof a run can grep for
		if (SVB("rsqgb_kr_debug", false))
			Console.Printf("RSQ KR t%d: %s (%d hp%s) burst into %d bits of %d rolled: %d health, %d armour, %d ammo", level.maptime, cn, a.SpawnHealth(),
				a.bBoss ? ", boss" : (boss ? ", miniboss as boss" : ""), nh + na + nm, num, nh, na, nm);
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
		}
		return nh, na, nm;
	}

	// LUCKY KILL (GBOVR_TREES.md 3.14, after Rich Bits 1): a kill that was a critical (Critical Hits, Headshot,
	// Backstab), a Finisher, or a big moment to RSQ Score drops double, triple, x4 -- the extra bits burst out a tic
	// later with a bigger burst. A critical or Finisher counts when it landed within a tic of the death (RSQ_Dazed
	// luckyTic, set by RSQM.Touch); Score's is its own call ("kill.big"). Nothing without the node.
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
			RSQM.Burst("RSQML_Burst5", a.pos + (0, 0, a.height * 0.6), 1.5 + 0.5 * lv, 0);
			a.A_StartSound("rsqml/fx/heavy", CHAN_AUTO, CHANF_OVERLAP, 1.0);
			RSQM.Touch("lucky", by, a);
			if (SVB("rsqgb_kr_debug", false))
				Console.Printf("RSQ KR t%d: lucky kill (%s, Lucky Kill %d): %d more bits, x%d in all", level.maptime, why, lv, nh + na + nm, lv + 1);
		}
	}
	static String LuckyWhy(Actor a, int died)
	{
		let d = RSQ_Dazed(a.FindInventory("RSQ_Dazed"));
		if (d && d.luckyTic > 0 && died - d.luckyTic <= 1) return d.luckyWhy;
		let s = ServiceIterator.Find("RS_ScoreService").Next();
		if (s && s.GetInt("kill.big", "", 0, 0, a) == 1) return "Score big moment";
		return "";
	}
}

// What every bit shares: SoM's size, the optional lifetime, the magnet.
mixin class RSQ_KRBit
{
	int bitLife;

	void BitTick()
	{
		int life = RSQ_KRHandler.SVI("rsqgb_kr_life", 7);
		if (life > 0 && ++bitLife >= life * TICRATE) { Destroy(); return; }
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
			if (gw && gam && RSQM.LevelOn(gw, "RSQ_Upgrade_Scavenger") >= 3 && random[RSQKR](0, 3) == 0)
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


// ---- THE PATH (GBOVR_TREES.md 3.14 / 4.10; player nodes, credit SoM for the bits) -----------------------------------
class RSQ_KRPerk : RSQ_Perk
{
	override int Cap() { return 3; }
	virtual String Parent() { return ""; }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		String pa = Parent();
		return Super.IsSuitableForPlayer(stats) && (pa == "" || PHas(stats, pa));
	}
}
// BIT SCAVENGER, shown as "Gastropub" (owner 11-02) (root): +25% bits a kill a level.
class RSQ_Upgrade_BitScavenger : RSQ_KRPerk
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pct", string.format("%d%%", 25 * level)); }
}
// RICH BITS (after Bit Scavenger 1): a health or armour bit is worth 2, 3, 4 times; an ammo bit 8, 11, 14 rounds.
class RSQ_Upgrade_RichBits : RSQ_KRPerk
{
	override String Parent() { return "BitScavenger"; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("x", string.format("%d", 1 + level));
		fields.Insert("ammo", string.format("%d", 5 + 3 * level));
	}
}
// MAGNET (after Bit Scavenger 1): bits inside 2, 3, 4 m drift to you.
class RSQ_Upgrade_Magnet : RSQ_KRPerk
{
	override String Parent() { return "BitScavenger"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("m", string.format("%d", 1 + level)); }
}
// LUCKY KILL (after Rich Bits 1): a critical, a Finisher or a Score big moment drops double, triple, x4.
class RSQ_Upgrade_LuckyKill : RSQ_KRPerk
{
	override String Parent() { return "RichBits"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("x", string.format("%d", 1 + level)); }
}