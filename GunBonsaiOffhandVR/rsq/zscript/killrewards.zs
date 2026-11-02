// KILL REWARDS -- monsters burst into bits of health, armour and ammo when they die.
//
// SoM's "Universal(ish?) Kill Rewards" v1.0 (som_kr), folded into this patch on the owner's word (2026-11-02,
// GBOVR_TREES.md 3.14): "I love the current implementation, I don't want to lose anything, but the menu I do not
// understand." SoM's readme: "Feel free to use anything in this mod for yourself ... I don't need credit, unless you
// wanted to." We do: CREDITS. The behaviour is SoM's, line for line where it mattered; the menu is new (plain rows
// with presets), the cvars are ours (rsqgb_kr_*), the bit classes carry our names and sprite lumps (RQKH / RQKA /
// RQKM, SoM's three orbs), and two things are fixed: Range mode's inverted chance test (at 100% only bosses
// dropped), and the ammo bit reading players[consoleplayer] in the playsim (wrong player in a netgame: the toucher
// is the one who picks it up).
//
// WHAT HAPPENS. A monster dies (WorldThingDied, bIsMonster, not one of Brutal Doom's boot-smear corpses). N bits
// burst out of it 32 units up, thrown 1-6 sideways and up on a random heading:
//   N  By Health (default, the owner's fountains): spawn health / (10 at Standard) rounded, at least 1; x the boss
//      fountain (3) for a BOSS.  Range: a random 1-3 (x boss).
//   each bit rolls the drop chance (100%; a boss always drops), then its KIND by the mix: health (RQKH, 25 health),
//   armour (RQKA, 10 green armour, up to 250), ammo (RQKM, 5 rounds of the gun in your hand, or of any gun you
//   carry). Bits live forever unless Bits Vanish After is set. Bits Fly to Me pulls bits inside a radius toward
//   you (0 = off; the Magnet node raises it).
// "Kill Rewards: On" (rsqgb_kr_enabled) is the owner's "on by default: yes" row: bits from the first kill, no
// unlock. Off: no bits at all. The path nodes (Scavenger, Rich Bits, Magnet, Lucky Kill) read their levels here by
// name once they exist; at level 0 everything is as SoM shipped it.
//
// CVARS (all server; the raw numbers live on Tuning and Debug so nothing of SoM's is lost):
//   rsqgb_kr_enabled   bool   on
//   rsqgb_kr_mode      0 By Health, 1 Range
//   rsqgb_kr_amount    0 Few (1 per 20 health), 1 Standard (per 10), 2 Many (per 5), 3 Custom (rsqgb_kr_hp_ratio)
//   rsqgb_kr_hp_ratio  int    10      (Custom)
//   rsqgb_kr_boss      int    3       x bits for a boss (1, 3, 5)
//   rsqgb_kr_mix       0 Even, 1 Mostly Health, 2 Mostly Armour, 3 Mostly Ammo, 4 Custom (the three ratios)
//   rsqgb_kr_ratio_health / _armor / _ammo   int  1 1 1 (Custom)
//   rsqgb_kr_chance    int    100     % a bit drops (bosses always)
//   rsqgb_kr_life      int    0       seconds a bit lives, 0 = forever
//   rsqgb_kr_ammo_mode 0 the gun in hand, 1 any gun carried
//   rsqgb_kr_ammotype1 / _ammotype2  bool  on / off   which of a gun's two ammo types count (clip mods: see SoM)
//   rsqgb_kr_magnet    float  0.0     metres bits drift to you from, 0 off
//   rsqgb_kr_min / _max / _rnd   Range mode: 1, 3, on
class RSQ_KRHandler : EventHandler
{
	static const String BLACKLIST[] = { "BootSmearerRed", "BootSmearerBlue", "BootSmearerGreen" };   // "Because Brutal Doom..." (SoM)

	static int SVI(String n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }
	static double SV(String n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }
	static bool SVB(String n, bool fb) { let c = CVar.FindCVar(n); return c ? c.GetBool() : fb; }

	// the player path's levels, by name (0 until the nodes exist and are learned)
	static int Perk(Actor pawn, String shortName)
	{
		if (!pawn) return 0;
		let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
		Service s = it.Next();
		return s ? s.GetInt("plevel", shortName, 0, 0, pawn) : 0;
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
		switch (SVI("rsqgb_kr_mix", 0))
		{
			case 1: return 4, 1, 1;
			case 2: return 1, 4, 1;
			case 3: return 1, 1, 4;
			case 4: return max(0, SVI("rsqgb_kr_ratio_health", 1)), max(0, SVI("rsqgb_kr_ratio_armor", 1)), max(0, SVI("rsqgb_kr_ratio_ammo", 1));
		}
		return 1, 1, 1;
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (!SVB("rsqgb_kr_enabled", true)) return;
		Actor a = e.Thing;
		if (!a || !a.bIsMonster) return;
		String cn = a.GetClassName();
		for (int i = 0; i < BLACKLIST.Size(); ++i) if (cn == BLACKLIST[i]) return;

		// who killed it, for the path nodes (the killer's perks); nobody = SoM's plain numbers
		Actor killer = (e.DamageSource && e.DamageSource.player) ? e.DamageSource : null;
		if (!killer && a.target && a.target.player) killer = a.target;

		int mult = a.bBoss ? max(0, SVI("rsqgb_kr_boss", 3)) : 1;
		int num = 0;
		if (SVI("rsqgb_kr_mode", 0) == 1)
		{
			// Range. SoM's chance test was inverted (random > chance), so at 100% only bosses ever dropped; fixed.
			if (a.bBoss || random[RSQKR](1, 100) <= clamp(SVI("rsqgb_kr_chance", 100), 0, 100))
			{
				int lo = min(SVI("rsqgb_kr_min", 1), SVI("rsqgb_kr_max", 3)), hi = max(SVI("rsqgb_kr_min", 1), SVI("rsqgb_kr_max", 3));
				num = SVB("rsqgb_kr_rnd", true) ? random[RSQKR](lo * mult, hi * mult) : hi * mult;
			}
		}
		else
		{
			num = max(1, int(round(double(a.SpawnHealth() * mult) / HpRatio())));
		}
		// Scavenger: +25% a level
		int scav = Perk(killer, "Scavenger");
		if (scav > 0) num = int(round(num * (1.0 + 0.25 * scav)));
		// Lucky Kill: a critical, a Finisher or a Score big moment doubles and more (read later, when those exist)
		if (num <= 0) return;

		int wh, wa, wm;
		[wh, wa, wm] = Mix();
		int sum = wh + wa + wm;
		if (sum <= 0) return;
		int chance = clamp(SVI("rsqgb_kr_chance", 100), 0, 100);
		int nh = 0, na = 0, nm = 0;
		for (int i = 0; i < num; ++i)
		{
			if (!a.bBoss && random[RSQKR](1, 100) > chance) continue;
			int r = random[RSQKR](1, sum);
			String cls;
			if (r <= wh) { cls = "RSQ_KRHealthBit"; ++nh; }
			else if (r <= wh + wa) { cls = "RSQ_KRArmorBit"; ++na; }
			else { cls = "RSQ_KRAmmoBit"; ++nm; }
			// SoM's throw: 32 up, 1-6 out and up, a random heading
			a.A_SpawnItemEx(cls, 0, 0, 32, random[RSQKR](1, 6), 0, random[RSQKR](1, 6), random[RSQKR](0, 360));
		}
		// Debug Log (rsqgb_kr_debug, noarchive): one line a kill, the proof a run can grep for
		if (SVB("rsqgb_kr_debug", false))
			Console.Printf("RSQ KR t%d: %s (%d hp%s) burst into %d bits: %d health, %d armour, %d ammo", level.maptime, cn, a.SpawnHealth(),
				a.bBoss ? ", boss" : "", nh + na + nm, nh, na, nm);
	}
}

// What every bit shares: SoM's size, the optional lifetime, the magnet.
mixin class RSQ_KRBit
{
	int bitLife;

	void BitTick()
	{
		int life = RSQ_KRHandler.SVI("rsqgb_kr_life", 0);
		if (life > 0 && ++bitLife >= life * TICRATE) { Destroy(); return; }
		// Bits Fly to Me: inside the radius a bit drifts to the nearest player's hand height
		double m = RSQ_KRHandler.SV("rsqgb_kr_magnet", 0.0);
		if (m <= 0 || (level.maptime & 1)) return;
		double units = m * 34.0;
		Actor best = null; double bd = units;
		for (int p = 0; p < MAXPLAYERS; ++p)
		{
			if (!playeringame[p] || !players[p].mo || players[p].mo.health <= 0) continue;
			double d = Distance3D(players[p].mo);
			double reach = units * (1.0 + 0.5 * RSQ_KRHandler.Perk(players[p].mo, "Magnet"));
			if (d < reach && d < bd) { best = players[p].mo; bd = d; }
		}
		if (!best) return;
		Vector3 to = (best.pos + (0, 0, best.height * 0.5)) - pos;
		double l = to.Length();
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
	States { Spawn: RQKH A 4; RQKH A 4 BRIGHT; Loop; }
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
	States { Spawn: RQKA A 4; RQKA A 4 BRIGHT; Loop; }
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
		if (RSQ_KRHandler.SVI("rsqgb_kr_ammo_mode", 0) == 0)
		{
			AmmoOf(pmo.player.ReadyWeapon, ammos);
			if (ammos.Size() == 0) AmmoOf(pmo.player.OffhandWeapon, ammos);
		}
		else
		{
			for (Inventory it = pmo.Inv; it; it = it.Inv) AmmoOf(Weapon(it), ammos);
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
	States { Spawn: RQKM A 4; RQKM A 4 BRIGHT; Loop; }
}
