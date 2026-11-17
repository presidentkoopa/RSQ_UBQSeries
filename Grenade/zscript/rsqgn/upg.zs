// RSQ Grenade -- THE GUN BONSAI VR PATCH, asked by name (RSQ_MeleeUpgradeService). This mod names no class of the
// patch: absent, Svc() is null, every level reads 0, and the grenade is exactly what it was. The levels live on the
// grenade weapon's own record (RSQGN_Grenade levels like a gun: its thrown grenades are claimed for it, hand.zs Throw);
// the tree is GBOVR_TREES.md 4.5, the numbers live with the upgrades ("upgrade.num").
class RSQGN_Upg play
{
	static Service Svc()
	{
		let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
		return it.Next();
	}
	static bool On() { return Svc() != null; }
	// the level of a node on this player's grenade (who: the pawn, or the grenade weapon itself)
	static int Lv(Actor who, String upgrade)
	{
		if (!who) return 0;
		let w = Weapon(who);
		if (!w) w = Weapon(who.FindInventory("RSQGN_Grenade"));
		if (!w) return 0;
		let s = Svc();
		return s ? max(0, s.GetInt("level", upgrade, 0, 0, w)) : 0;
	}
	static double Num(String what, int lv, double fb)
	{
		let s = Svc();
		return s ? s.GetDouble("upgrade.num", what, lv, 0) : fb;
	}
	// RSQ Score's combo ledger, by name (nothing without it)
	static void Touch(String id, Actor pawn, Actor victim)
	{
		if (!pawn || !pawn.player || !victim) return;
		let it = ServiceIterator.Find("RS_ScoreService");
		let s = it.Next();
		if (s) s.GetInt("touch", id, pawn.PlayerNumber(), 0, victim);
	}
}

// SLOW MOTION AND SHOOTING (11-03), RSQ SlowMo asked by name (RSQSM_Service "scale": the world's speed in permille;
// without it the world is never slowed).
class RSQGN_Slow play
{
	static double WorldScale()
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		let s = it.Next();
		if (!s) return 1.0;
		return clamp(s.GetInt("scale", "", 0, 0, null) / 1000.0, 0.01, 1.0);
	}
	static bool Slowed() { return WorldScale() < 0.999; }
	// the speed a thrown grenade runs at: the world's; with "Faster Grenades in Slow Motion" (rsqgn_slowmo_fast) that
	// much of the way from the world's speed up to real speed ("Grenade Speed in Slow Motion", rsqgn_slowmo_speed, 0.5:
	// at a world of 0.25 the grenade runs at 0.625, visibly slow and well ahead of everything else)
	static double GrenadeFactor()
	{
		double w = WorldScale();
		if (w >= 0.9999) return 1.0;
		let own = CVar.FindCVar("rsqsm_slow_own");	// RSQ SlowMo's "your own missiles slow too" off: a grenade is yours
		if (own && !own.GetBool()) return 1.0;
		let f = CVar.FindCVar("rsqgn_slowmo_fast");
		if (!f || !f.GetBool()) return w;
		let k = CVar.FindCVar("rsqgn_slowmo_speed");
		return w + (1.0 - w) * clamp(k ? k.GetFloat() : 0.5, 0.0, 1.0);
	}
	// "Shoot Thrown Grenades" (rsqgn_shoot, on), and "Only in Slow Motion" (rsqgn_shoot_slowmo, off)
	static bool CanShoot()
	{
		let c = CVar.FindCVar("rsqgn_shoot");
		if (c && !c.GetBool()) return false;
		let o = CVar.FindCVar("rsqgn_shoot_slowmo");
		return !(o && o.GetBool()) || Slowed();
	}
}

// THE EFFECTS' CLOCK (owner 2026-11-16 05:27: "how can we slow down our explosions when there is slowdown? the barrels
// don't really last long whereas bd22 barrels do"; approved 05:33). RSQ SlowMo slows an actor by stretching its states and
// scaling its motion; this pack's barrel and blast players keep their own clock in script (each counts its age every tic:
// barrel.zs RSQGN_BarrelFX / Layer / Ember / Debris, explosions.zs RSQGN_Boom, flip.zs, pops.zs, kinds.zs FireField and
// Smoke), which SlowMo cannot stretch from outside, and engine particles are not actors at all. So each of them asks SlowMo
// for the world's speed (RSQSM_Service "scale", by name) and runs at it: its age, life and fuse advance by it each tic,
// its velocity and gravity are put at it (gravity at its square), and a particle is spawned with its velocity scaled down
// and its lifetime up. SlowMo keeps these classes on real time (its SeriesRule leaves them off its list), so nothing is
// slowed twice; its state-driven blasts (blast.zs, kinds.zs FxBase) it slows itself. Without SlowMo, or at full speed,
// W() is exactly 1 and every effect is what it was.
class RSQGN_Clock play
{
	// the world's speed now, 0.05..1 (1 without RSQ SlowMo); asked once a tic (RSQGN_BarrelBook keeps it)
	static double W()
	{
		let b = RSQGN_BarrelBook.Get();
		if (b) return b.WorldSpeed();
		return Ask(null);
	}
	static double Ask(Service s)
	{
		if (!s) { let it = ServiceIterator.Find("RSQSM_Service"); s = it.Next(); }
		int r = s ? s.GetInt("scale", "", 0, 0, null) : 1000;
		return (r > 0 && r < 1000) ? clamp(r / 1000.0, 0.05, 1.0) : 1.0;
	}
	// a particle's lifetime, velocity and acceleration at the world's speed w (the engine moves a particle by its velocity
	// each tic and ages it a tic each tic: slowed, it moves w as far, gains w x w as much speed, and lives 1/w as long)
	static int Life(int ttl, double w) { return w < 1.0 ? max(1, int(ttl / w + 0.5)) : ttl; }
}

// WHAT THE GRENADE TELLS OTHER MODS, by name. "cooked", objectArg = a thrown grenade: the tics it cooked in the hand before
// it was thrown, -1 for anything else (Gun Bonsai VR's Slow Burn). "fuse.count" / "fuse.amber", intArg = a player number:
// while the grenade in that player's hand cooks AND they have COOK SENSE 3 (Gun Bonsai VR patch), its whole seconds left /
// 1 for the fuse's first half (the amber flash), -1 otherwise (RSQ Gun Cards draws the count on the grenade's card).
class RSQGN_Service : Service
{
	// THE MENU (MENU_PASS_BRIEF.md, owner 11-04): GetIntUI("menu.locked", f), asked by the RSQGNGbOption rows only while
	// RSQ Gun Bonsai VR is loaded. "SkeetWindow": 1 until the console player's grenade has Skeet Window (the row does
	// nothing without it: thrown.zs). "KindsFree": 1 until the console player has learned a grenade kind (with none
	// learned only the frag exists, so the row has nothing to switch; learned, Frag Only / All Types decides: kinds.zs
	// Owns). Read from RSQGN_Handler's once-a-second cache (hand.zs MenuRefresh).
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request ~== "menu.locked")) return 0;
		let h = RSQGN_Handler(EventHandler.Find("RSQGN_Handler"));
		if (!h || !players[consoleplayer].mo) return 1;
		if (stringArg ~== "KindsFree") return h.menuKinds >= 1 ? 0 : 1;
		if (stringArg ~== "SkeetWindow") return h.menuSkeet >= 1 ? 0 : 1;
		return 0;
	}

	// "kind.name": intArg a kind -> "Freeze Grenade" (the Weapon Wheel's fan of kinds)
	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "kind.name") return "";
		String n = RSQGN_Kind.Node(intArg);
		return (n == "" ? "Frag" : n) .. " Grenade";
	}

	// "kind.share" intArg a kind, objectArg whose it is -> the share of the frag's blast damage that kind does (kinds.zs
	// DamageShare: stun half, freeze, smoke, flash, charm and infight none). BD22 VR Reloaded's launcher asks it for the
	// round's own hit (2.0.5d).
	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "kind.share") return RSQGN_Kind.DamageShare(Actor(objectArg), clamp(intArg, 0, RSQGN_Kind.COUNT - 1));
		return 0;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// GRAPPLE 2.0'S AIR SPIKE (owner 2026-11-13 00:1x): "g2.neon", stringArg "" (or "safe"), intArg 0 (or 1 + the number
		// of the player to credit), objectArg the actor at the spot -> #10 Neon Crescent goes off where that actor stands,
		// through the barrels' own blast (barrel.zs RSQGN_NeonSpike: the look, the colour, the light, the sound, the barrel's
		// A_Explode). CREDIT: the player intArg names; with intArg 0, the actor itself if it is a player's pawn, else its
		// `target` if that is a player's pawn (a spiked monster's target is the player it is after), else nobody. "safe":
		// the blast spares the credited player (a barrel's own blast hurts whoever set it off). Answers 1 gone off, 0 not
		// (no actor, or the Barrels row is off). From synced play code only. Rig only, not headset-confirmed.
		if (request == "g2.neon")
		{
			let at = Actor(objectArg);
			if (!at || !RSQGN_BarrelSwap.On()) return 0;
			Actor who = null;
			if (intArg > 0 && intArg <= MAXPLAYERS && playeringame[intArg - 1]) who = players[intArg - 1].mo;
			else if (at.player) who = at;
			else if (at.target && at.target.player) who = at.target;
			return RSQGN_NeonSpike.SetOff(at, who, stringArg ~== "safe") ? 1 : 0;
		}
		if (request == "cooked")
		{
			let g = RSQGN_Thrown(objectArg);
			return g ? g.cooked : -1;
		}
		// the throw's facts, for a scorer (RSQ Score, 11-03): objectArg = a thrown grenade -> 1 / 0, -1 not a grenade
		if (request == "teeth" || request == "skeet" || request == "impact")
		{
			let g = RSQGN_Thrown(objectArg);
			// BD22 VR Reloaded's hand grenade shot in the air (its rsg/grenade.zs Shoot, 2.0.3r): the blast it leaves
			// carries the token RSG_Skeet, looked up by name (nothing of BD22 VR is named at compile time)
			if (!g && request == "skeet")
			{
				let a = Actor(objectArg);
				String tn = "RSG_Skeet";
				class<Inventory> tc = tn;
				if (a && tc) return a.FindInventory(tc) ? 1 : 0;
			}
			if (!g) return -1;
			if (request == "teeth") return g.teeth ? 1 : 0;
			if (request == "skeet") return g.skeet ? 1 : 0;
			return g.impactHit ? 1 : 0;
		}
		// "turned.by", objectArg = a monster: the player whose Infight or Charm grenade turned it (while it lasts), -1 not
		// turned (RSQ Score's Civil War / Turncoat, 11-03: a kill by a monster you turned is yours, not everyone's Infighter)
		if (request == "turned.by")
		{
			let a = Actor(objectArg);
			let t = a ? RSQGN_Turned(a.FindInventory("RSQGN_Turned", true)) : null;
			return t ? t.byPn : -1;
		}
		// THE WEAPON WHEEL'S FAN OF KINDS (RSQ Wheel, owner 11-02): "kinds.owned" intArg player -> a bit a kind (the frag's
		// always), "kind" -> the kind in hand, "kind.set" intArg player, doubleArg the kind -> 1 when taken (owned, no pin
		// pulled), "kind.colour.of" intArg a kind -> its colour (-1 the frag)
		if (request == "kinds.owned" || request == "kind" || request == "kind.set")
		{
			let h = RSQGN_Handler.Get();
			int n = intArg;
			if (!h || n < 0 || n >= MAXPLAYERS || !playeringame[n] || !players[n].mo) return 0;
			let pmo = players[n].mo;
			if (request == "kind") return h.kind[n];
			if (request == "kinds.owned") { int m = 0; for (int k = 0; k < RSQGN_Kind.COUNT; k++) if (RSQGN_Kind.Owns(pmo, k)) m |= 1 << k; return m; }
			int want = int(doubleArg);
			if (h.spoon[n] || !RSQGN_Kind.Owns(pmo, want)) return 0;
			h.kind[n] = want;
			return 1;
		}
		// THE UNDER-BARREL LAUNCHERS' GRENADES (owner 2026-11-17: "we grab grenade, alt fire cycle to the one we want ... and
		// we load it into the launcher"; BD22 VR Reloaded 2.0.5d, its rsr/rsr_m203.zs, asks these by name):
		// "kind.next" intArg player, doubleArg the hand (0 main, 1 off) -> the grenade taken from RSQ Tactical Rig's grenade
		// spot for the launcher is cycled by that hand's alt trigger with the SAME rules as the grenade in the hand (the alt
		// trigger's cycle, hand.zs "rsqgn_kind": Alt Fire Cycles Grenade Types, Owns, never with a spoon flown) and it is the
		// SAME choice: the player's kind changes. Answers the kind now (the same one when nothing cycled), -1 no player.
		if (request == "kind.next")
		{
			let h = RSQGN_Handler.Get();
			int n = intArg;
			if (!h || n < 0 || n >= MAXPLAYERS || !playeringame[n] || !players[n].mo) return -1;
			let pmo = players[n].mo;
			if (h.spoon[n] || !RSQGN_Handler.PFlag(players[n], "rsqgn_kind_alt", true)) return h.kind[n];
			int k = RSQGN_Kind.Next(pmo, h.kind[n]);
			if (k == h.kind[n]) return k;
			h.kind[n] = k;
			pmo.A_StartSound("rsqgn/bounce", CHAN_AUTO, CHANF_OVERLAP, 0.6, ATTN_NORM, 1.3);
			RSQGN_Buzzer.Start(pmo, clamp(int(doubleArg), 0, 1), 0.3, 3);
			if (RSQGN_Handler.Debug(players[n])) Console.Printf("RSQGN kind p%d t%d: %s (the launcher's grenade)", n, level.maptime, k == 0 ? "Frag" : RSQGN_Kind.Node(k));
			return k;
		}
		// "burst" intArg a kind, objectArg the actor where it bursts (its target: whose it is, who gets the kills) -> that
		// kind's blast there through this pack's own path (RSQGN_RoundBlast: the kind's Look, then Blast's two parts, Effect
		// and Cluster: the frag's fireball and damage, the freeze, the fire, the stun, the smoke, the flash, the charm, the
		// infight), as a grenade going off. 1 done, 0 not (no actor). From synced play code only.
		if (request == "burst")
		{
			let at = Actor(objectArg);
			if (!at) return 0;
			let b = RSQGN_RoundBlast(Actor.Spawn("RSQGN_RoundBlast", at.pos, ALLOW_REPLACE));
			if (!b) return 0;
			b.target = at.target;
			b.kind = clamp(intArg, 0, RSQGN_Kind.COUNT - 1);
			if (at.target && at.target.player && RSQGN_Handler.Debug(at.target.player))
				Console.Printf("RSQGN launcher round t%d: %s at (%.0f %.0f %.0f)", level.maptime, b.kind == 0 ? "Frag" : RSQGN_Kind.Node(b.kind), at.pos.x, at.pos.y, at.pos.z);
			return 1;
		}
		if (request == "kind.colour.of") return RSQGN_Kind.Colour(intArg);
		// "kind.colour": intArg player -> the colour of the kind in that player's hand (the alt trigger's pick), -1 the frag
		// (RSQ Tactical Rig tints its grenade spot's light with it)
		if (request == "kind.colour")
		{
			int n = intArg;
			if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return -1;
			return RSQGN_Kind.Colour(RSQGN_Handler.KindOf(n));
		}
		if (request == "fuse.count" || request == "fuse.amber")
		{
			let h = RSQGN_Handler.Get();
			int n = intArg;
			if (!h || n < 0 || n >= MAXPLAYERS || !playeringame[n] || !players[n].mo) return -1;
			let pmo = players[n].mo;
			if (!h.spoon[n] || RSQGN_Handler.HandOf(players[n]) < 0 || RSQGN_Upg.Lv(pmo, "CookSense") < 3) return -1;
			int fuse = RSQGN_Handler.FuseTics(pmo);
			int left = max(fuse - (level.maptime - h.cookTic[n]), 0);
			if (request == "fuse.amber") return left * 2 > fuse ? 1 : 0;
			return (left + TICRATE - 1) / TICRATE;
		}
		return 0;
	}
}

// RSQ SLOWMO'S DOWN (owner 11-06, design/NEAR_DEATH.md 4): getting up (REVIVE) gives one grenade, up to its normal carry.
// This pack's own grenade while it runs (RSQGN_Ammo: 8, a backpack 16, Gun Bonsai VR's Bandolier); with Brutal Doom VR
// Reloaded's own grenade in charge (this pack standing down for it, RSQGN_Handler.Active), Brutal Doom's GrenadeAmmo, by
// name, up to its own MaxAmount (BD's Ammo.dec: 5, a backpack more). SlowMo tells every service named "...RSQDownJoin"
// by name (its down.zs Tell); nothing links.
class RSQGN_RSQDownJoin : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "down.revive") return 0;
		let pmo = PlayerPawn(objectArg);
		if (!pmo || !pmo.player) return 0;
		let dc = CVar.FindCVar("rsqsm_debug");     // RSQ SlowMo's debug log
		bool msg = dc && dc.GetBool();
		String an = "RSQGN_Ammo";
		if (!RSQGN_Handler.Active())
		{
			if (!RSQGN_Handler.BDVR()) { if (msg) Console.Printf("RSQ Grenade: REVIVE: the grenade is switched off, no grenade"); return 0; }
			an = "GrenadeAmmo";
		}
		class<Inventory> ac = an;
		if (!ac) return 0;
		if (an == "RSQGN_Ammo") RSQGN_Handler.Carry(pmo);
		let am = pmo.FindInventory(ac);
		int had = am ? am.Amount : 0;
		pmo.GiveInventory(ac, 1);
		am = pmo.FindInventory(ac);
		if (msg) Console.Printf("RSQ Grenade: REVIVE: %s %d -> %d (carry %d)", an, had, am ? am.Amount : 0, am ? am.MaxAmount : -1);
		return 1;
	}
}
