// RSQ melee upgrades for Gun Bonsai -- the shared core.
//
// Gun Bonsai is Rebecca "ToxicFrog" Kelly's (MIT). The melee upgrade paths are presidentkoopa's (this patch, same
// terms). The gloves' punch reader, Slappers Only and the moves Guard, Hadouken, Wall Splat and Heavy Hands moved to
// RSQ Melee on 2026-11-01: Melee asks this patch for upgrade levels and numbers (RSQ_MeleeUpgradeService below), and
// the glove upgrades ask Melee about the last punch (RSQML_Service), both by name.
//
// HOW THE MODS TALK. No mod links to another: the saber (RSQ_Saber) and the
// ShieldSaw ask RSQ_MeleeUpgradeService by NAME through ServiceIterator, and get 0 from
// nothing when this patch is not loaded. Every class this file names from another mod is
// reached by string, never by literal, so this patch still compiles and runs alone.

class RSQM play
{
	// The upgrade class an RSQ short name stands for.
	static String UpClass(String shortName) { return "RSQ_Upgrade_" .. shortName; }

	// ---- which weapon is which, BY CLASS NAME (the design: names only) ----------------------
	static bool IsGloveName(String n) { return n.Left(9) ~== "SPO_Glove" || n.Left(9) ~== "RSQ_Glove"; }
	static bool IsSaberName(String n) { return n ~== "UBQS_Saber" || n ~== "UBQS_SaberOff"; }
	static bool IsShieldName(String n) { return n ~== "SSQ_ShieldSaw"; }

	// (IsSlapperClass, what Slappers Only lets you keep, moved to RSQ Melee with Slappers Only on 2026-11-01; Melee asks
	// "is.melee" below for Gun Bonsai's own type inference.)

	// ---- levels ----------------------------------------------------------------------------
	// The level of an RSQ upgrade on ONE weapon's Gun Bonsai record. 0 when the weapon has
	// never been held (no record yet), or the upgrade is switched off in the status menu.
	static int LevelOn(Weapon w, String upClass)
	{
		if (!w || !w.owner) return 0;
		let stats = TFLV_PerPlayerStats.GetStatsFor(w.owner);
		if (!stats) return 0;
		let info = stats.GetInfoFor(w);
		if (!info || !info.upgrades) return 0;
		for (int i = 0; i < info.upgrades.upgrades.Size(); ++i)
		{
			let u = info.upgrades.upgrades[i];
			if (u && u.GetClassName() == upClass) return u.enabled ? int(u.level) : 0;
		}
		return 0;
	}

	// The best level of an upgrade on any weapon the player carries (the Force, which both
	// sabers share; Lunge and friends on whatever melee weapon you have).
	static int LevelAny(Actor pawn, String upClass)
	{
		if (!pawn) return 0;
		int best = 0;
		for (let it = pawn.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (w) best = max(best, LevelOn(w, upClass));
		}
		return best;
	}

	// The level of a PLAYER upgrade (Gun Bonsai's player bag): the suite's perks that are no
	// one weapon's -- the grab, the rig, slow motion, the two hands, the body.
	static int PLevel(Actor pawn, String upClass)
	{
		if (!pawn) return 0;
		let stats = TFLV_PerPlayerStats.GetStatsFor(pawn);
		if (!stats || !stats.upgrades) return 0;
		for (int i = 0; i < stats.upgrades.upgrades.Size(); ++i)
		{
			let u = stats.upgrades.upgrades[i];
			if (u && u.GetClassName() == upClass) return u.enabled ? int(u.level) : 0;
		}
		return 0;
	}

	// level time, for code inside an upgrade (whose own `level` field hides the global)
	static int Now() { return level.maptime; }

	// Is that mod loaded? Asked by one of its class names, never a literal.
	static bool Has(String cls) { return Object.FindClass(cls) != null; }

	// The first service of that name, or null.
	static Service Svc(String name) { let it = ServiceIterator.Find(name); return it.Next(); }

	// RSQ SCORE's combo ledger: this player's move `id` touched that monster ("touch", by name; nothing without it)
	static void Touch(String id, Actor pawn, Actor victim)
	{
		if (!pawn || !pawn.player || !victim) return;
		// a critical or a Finisher marks the body for Kill Rewards' Lucky Kill (killrewards.zs), Score or no Score
		if (id == "crit" || id == "headshot" || id == "backstab" || id == "finisher")
		{
			let d = RSQ_Dazed.On(victim);
			if (d) { d.luckyTic = level.maptime; d.luckyWhy = id; }
		}
		let s = Svc("RS_ScoreService");
		if (s) s.GetInt("touch", id, pawn.PlayerNumber(), 0, victim);
	}

	// A BURST (RSQ Melee's kiddolink bursts, sparks.zs RSQML_Burst, by class name: nothing without Melee). size x its 40
	// map units (x Melee's Hit Spark Size), frames = how many play (0 all): ByLevel gives 3 at level 1, two more a level,
	// the whole burst at the node's cap.
	static void Burst(String cls, Vector3 at, double size = 1.0, int frames = 0)
	{
		Class<Actor> c = cls;
		if (!c) return;
		let a = Actor.Spawn(c, at, NO_REPLACE);
		if (!a) return;
		a.Scale *= size * clamp(SV("rsqml_spark_size", 1.0), 0.25, 3.0);
		a.args[0] = frames;
	}
	static int ByLevel(int lv, int cap) { return lv >= cap ? 0 : clamp(1 + 2 * lv, 3, 9); }

	// A GLOVE'S HIT THAT IS NOT A PUNCH (an element's blast, arc or burn, GBOVR_TREES.md 4.1 B): its inflictor, paid to
	// that glove (Gun Bonsai's claim) and marked PRI_NULL so no other upgrade procs from it. Without a glove the pawn is the
	// inflictor.
	static Actor GloveHit(Actor pawn, Weapon glove, Vector3 at)
	{
		if (!pawn) return null;
		if (!glove || !glove.owner) return pawn;
		let a = Actor.Spawn("RSQ_GloveHit", at, NO_REPLACE);
		if (!a) return pawn;
		a.target = pawn;
		a.weaponspecial = TFLV_Upgrade_PRI_NULL;
		a.master = glove;
		TFLV_VR_Attribution.Claim(a, glove, TFLV_VR_Attribution.HINT_MELEE);
		return a;
	}

	// The hand that caused this damage (0 main, 1 off, -1 none), read without registering.
	static int HandOf(Actor pawn, Actor shot)
	{
		let stats = TFLV_PerPlayerStats.GetStatsFor(pawn);
		return stats ? stats.HandOfShot(shot) : -1;
	}

	// RSQ SlowMo is slowing the world right now (RSQSM_Service "active", by name).
	static bool Slowed()
	{
		let s = Svc("RSQSM_Service");
		return s && s.GetInt("active") > 0;
	}

	// An item another mod may or may not define: reached through a string, never a literal (a
	// literal of an absent class fails the compile).
	static Inventory FindByName(Actor who, String cls)
	{
		if (!who) return null;
		Class<Inventory> c = cls;
		return c ? who.FindInventory(c) : null;
	}

	static double SV(String n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }
	static int SVI(String n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }

	static double UnitsPerMetre()
	{
		if (multiplayer) return 34.0;
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double u = c ? c.GetFloat() : 34.0;
		return u < 1.0 ? 34.0 : u;
	}

	// Is this monster in its attack wind-up -- its Missile or Melee sequence?
	static bool InAttack(Actor mo)
	{
		if (!mo || !mo.CurState) return false;
		State s = mo.FindState("Missile");
		if (s && mo.InStateSequence(mo.CurState, s)) return true;
		s = mo.FindState("Melee");
		if (s && mo.InStateSequence(mo.CurState, s)) return true;
		return false;
	}

	// THE HEALTH IT STARTED WITH, for an upgrade sized as "a share of its health" (Knockdown,
	// Executioner). GetSpawnHealth is the class's, x the skill -- or Champions' StartHealth, which its
	// controller raises to the boosted health once set up. LegenDoom Lite does not touch StartHealth:
	// its ACS sets a legendary's health to spawn health x LD_legendaryhealth / 100 (300 %;
	// LD_legendaryhealthboss for a boss) and refills it to that once, when it transforms
	// (LEGNDLIB.acs LDMonsterInit; the ShieldSaw's TierHealth reads it the same way). So a legendary,
	// transformed or not, started at that boosted health; measured before this, an untransformed
	// legendary Brutal Doom imp (80 -> 240) went down to the same 40 a plain imp does at level 1.
	// The class's own spawn health is the multiplier (a champion that was a legendary first already
	// carries the 300 % in its StartHealth, so the larger of the two wins). Read by name; without
	// LegenDoom Lite this is GetSpawnHealth.
	// RSQ Miniboss, by name (nothing links): this miniboss was made legendary with the HIGHER of LegenDoom's boss and
	// normal legendary health (RSQMB_Service "bossfor" "ldhealth"). Without RSQ Miniboss: false.
	static bool MinibossLDBoss(Actor v)
	{
		String wn = "RSQMB_Ward";
		class<Inventory> wc = wn;
		if (!v || !wc || !v.FindInventory(wc)) return false;
		let sv = ServiceIterator.Find("RSQMB_Service").Next();
		return sv && sv.GetInt("bossfor", "ldhealth", 0, 0, v) == 1;
	}

	static int StartHealth(Actor v)
	{
		if (!v) return 1;
		int sh = v.GetSpawnHealth();
		String tk = "LDLegendaryMonsterToken";
		class<Inventory> ct = tk;
		if (ct && v.FindInventory(ct))
		{
			let cv = CVar.FindCVar(v.bBoss ? 'LD_legendaryhealthboss' : 'LD_legendaryhealth');
			int pct = cv ? cv.GetInt() : 300;
			// a miniboss RSQ Miniboss made legendary with its "LegenDoom: Best Health" on got the HIGHER of the two (by name)
			if (!v.bBoss && MinibossLDBoss(v)) { let cb = CVar.FindCVar('LD_legendaryhealthboss'); pct = max(pct, cb ? cb.GetInt() : 200); }
			let d = GetDefaultByType(v.GetClass());
			int cls = d ? d.SpawnHealth() : sh;
			sh = max(sh, cls * (pct / 100));      // the ACS's own integer arithmetic
		}
		return max(sh, 1);
	}

	// Staggered: in its Pain sequence, or held by one of this patch's own staggers.
	static bool Staggered(Actor mo)
	{
		if (!mo || !mo.CurState) return false;
		let dz = RSQ_Dazed(mo.FindInventory("RSQ_Dazed"));
		if (dz && dz.IsStaggered()) return true;
		State s = mo.FindState("Pain");
		return s && mo.InStateSequence(mo.CurState, s);
	}

	static void Pulse(Actor pawn, int ms, int depthPct)
	{
		// RSQ SlowMo's own door (netevent rsm_pulse <hold ms> <depth %>): deeper wins, longer
		// wins. Sent by the one machine whose player earned it, so a netgame gets it once.
		if (!pawn || !pawn.player || pawn.PlayerNumber() != consoleplayer) return;
		EventHandler.SendNetworkEvent("rsm_pulse", ms, depthPct);
	}

	static void Charge(int points)
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service sv;
		while (sv = it.Next()) sv.GetInt("adrenaline.add", "", points);
	}

	static bool IsFoe(Actor pawn, Actor mo)
	{
		if (!mo || mo == pawn || !mo.bShootable || mo.health <= 0) return false;
		if (mo.player) return deathmatch;
		return mo.bIsMonster && !mo.bFriendly;
	}
}

// ---- THE SERVICE the saber and the ShieldSaw ask, by name -----------------------------------
//   "loaded"       1 (the patch is here)
//   "level"        stringArg = the upgrade's short name (e.g. "Momentum"); objectArg = a Weapon
//                  (that weapon's record) or a pawn (the best level on anything carried). >= 0.
//   "credit.push"  objectArg = a Weapon: damage the player's own body deals until "credit.pop"
//                  is paid to that weapon (the ShieldSaw's bash and grind). intArg = type hint.
//   "credit.pop"
//   "plevel"       stringArg = a PLAYER upgrade's short name, objectArg = the pawn. >= 0.
//   "claim"        objectArg = an actor whose master is a Weapon: pays it (and its puffs) to it.
//   "ram"          objectArg = a monster the ShieldSaw just bashed, intArg = player number,
//                  doubleArg = how hard: Battering Ram turns it into a missile, if learned.
//   "stagger"      objectArg = a monster, intArg = tics: held in its pain frame that long (RSQ_Dazed,
//                  the one Executioner reads). RSQ_Grapple's hook upgrades and RSQ Melee's Wall Splat ask it. 1 done, 0 not.
//   "knockdown"    objectArg = a monster (no boss), intArg = seconds: down for that count (RSQ_Dazed.KnockDown, the one
//                  Knockdown uses). RSQ Melee's Ground Pound asks it. 1 done, 0 not.
//   "is.melee"     stringArg = a weapon class name, objectArg = the pawn: 1 when Gun Bonsai's type inference calls a
//                  weapon of that class this player has used melee (WeaponInfo.IsMelee, honouring BONSAIRC). RSQ Melee's
//                  Slappers Only and Guard ask it.
//   GetDouble "upgrade.num"  stringArg = "<move>.<number>", intArg = the level, doubleArg = the move's own measure:
//                  the numbers of the moves RSQ Melee does for these upgrades (HeavyHands.freeze (punch power) /
//                  .knock, Hadouken.mult / .speed, WallSplat.damage (slam speed, map units a tic) / .reel, Guard.soak /
//                  .break; the Fists tree, up_fists.zs: Uppercut.lift, Launcher.lift / .stagger, Meteor.damage (fall
//                  speed), GroundPound.radius / .damage / .speed, ClearOut.range / .damage / .push / .stagger). The
//                  formulas live in the upgrade classes.
class RSQ_MeleeUpgradeService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "loaded") return 1;
		if (request == "level")
		{
			String uc = RSQM.UpClass(stringArg);
			let w = Weapon(objectArg);
			if (w) return RSQM.LevelOn(w, uc);
			let a = Actor(objectArg);
			if (a) return RSQM.LevelAny(a, uc);
			return 0;
		}
		// RSQ Wheel's data card: one weapon's own Gun Bonsai level, and its progress toward the
		// next in permille. -1 when that weapon has no record yet (never held).
		if (request == "weapon.level" || request == "weapon.xp")
		{
			let w = Weapon(objectArg);
			if (!w || !w.owner) return -1;
			let stats = TFLV_PerPlayerStats.GetStatsFor(w.owner);
			if (!stats) return -1;
			let info = stats.GetInfoFor(w);
			if (!info) return -1;
			if (request == "weapon.level") return int(info.level);
			return info.maxXP > 0 ? int(1000.0 * info.XP / info.maxXP) : 0;
		}
		if (request == "plevel")
		{
			// a player upgrade's level; objectArg = the pawn (the grab and the rig ask this)
			return RSQM.PLevel(Actor(objectArg), RSQM.UpClass(stringArg));
		}
		// "unlocked": 1 when the node is learned at all (level >= 1) on a Weapon's record or, with a pawn, on anything
		// carried; "punlocked": the same for a player node. The owning mods ask these by name before they let a move
		// happen under GBOVR (GBOVR_TREES.md section 6, item 3). Without this patch there is no service and the mod
		// keeps its own menu-row behaviour.
		if (request == "unlocked")
		{
			String uc = RSQM.UpClass(stringArg);
			let w = Weapon(objectArg);
			if (w) return RSQM.LevelOn(w, uc) >= 1 ? 1 : 0;
			let a = Actor(objectArg);
			return (a && RSQM.LevelAny(a, uc) >= 1) ? 1 : 0;
		}
		if (request == "punlocked") return RSQM.PLevel(Actor(objectArg), RSQM.UpClass(stringArg)) >= 1 ? 1 : 0;
		if (request == "claim")
		{
			// objectArg = an actor a mod fired for a weapon, whose MASTER is that weapon: it, and
			// what it spawns (a hitscan's puff), is paid to that weapon. intArg = type hint. The
			// ShieldSaw's returned bullet (SSQ_Ricochet) is the case: a helper fires it.
			let a = Actor(objectArg);
			let w = a ? Weapon(a.master) : null;
			if (!w || !w.owner) return 0;
			TFLV_VR_Attribution.Claim(a, w, intArg);
			return 1;
		}
		if (request == "credit.push" || request == "credit.pop")
		{
			let w = Weapon(objectArg);
			if (!w || !w.owner) return 0;
			let stats = TFLV_PerPlayerStats.GetStatsFor(w.owner);
			if (!stats) return 0;
			if (request == "credit.push") stats.PushClaim(w, intArg); else stats.PopClaim();
			return 1;
		}
		if (request == "stagger")
		{
			let mo = Actor(objectArg);
			if (!mo || mo.health <= 0 || !mo.bIsMonster || intArg <= 0) return 0;
			let d = RSQ_Dazed.On(mo);
			if (!d) return 0;
			d.Stagger(min(intArg, 350));
			return 1;
		}
		// "freeze": objectArg = a monster, intArg = tics, doubleArg = the shatter (0 none): frozen solid as the Frost Fist
		// freezes (RSQ_Dazed.Freeze; a boss slowed by half), and with a shatter the next hard hit (20+) on it does that
		// many times its damage and thaws it. RSQ Grenade's Freeze kind asks it. 1 done, 0 not.
		if (request == "freeze")
		{
			let mo = Actor(objectArg);
			if (!mo || mo.health <= 0 || !mo.bIsMonster || intArg <= 0) return 0;
			let d = RSQ_Dazed.On(mo);
			if (!d) return 0;
			d.Freeze(min(intArg, 700));
			if (doubleArg > 1 && d.IsFrozen()) d.shatterMult = max(d.shatterMult, doubleArg);
			return 1;
		}
		if (request == "knockdown")
		{
			let mo = Actor(objectArg);
			if (!mo || mo.health <= 0 || !mo.bIsMonster || mo.bBoss || intArg <= 0) return 0;
			let d = RSQ_Dazed.On(mo);
			if (!d || d.IsDown()) return 0;
			d.KnockDown(min(intArg, 10));
			return 1;
		}
		// "whip.mark" (Pistol Whip, RSQ Melee's shove): objectArg = a monster, intArg = the player number, doubleArg = the
		// multiplier: that player's next hit on it inside MARK_TICS lands harder (RSQ_Dazed.ModifyDamage). 1 done.
		if (request == "whip.mark")
		{
			let mo = Actor(objectArg);
			if (!mo || mo.health <= 0 || intArg < 0 || intArg >= MAXPLAYERS) return 0;
			let d = RSQ_Dazed.On(mo);
			if (!d) return 0;
			d.Mark(intArg, doubleArg);
			return 1;
		}
		if (request == "is.melee")
		{
			let pawn = Actor(objectArg);
			Class<Weapon> wc = stringArg;
			let stats = pawn ? TFLV_PerPlayerStats.GetStatsFor(pawn) : null;
			if (!stats || !wc) return 0;
			for (int i = 0; i < stats.weapons.Size(); ++i)
			{
				let info = stats.weapons[i];
				if (info && info.wpn && info.wpn.GetClass() == wc && info.IsMelee()) return 1;
			}
			return 0;
		}
		if (request == "ram")
		{
			let mo = Actor(objectArg);
			if (!mo || intArg < 0 || intArg >= MAXPLAYERS || !playeringame[intArg] || !players[intArg].mo) return 0;
			let pawn = players[intArg].mo;
			let saw = Weapon(RSQM.FindByName(pawn, "SSQ_ShieldSaw"));
			int lv = RSQM.LevelOn(saw, "RSQ_Upgrade_BatteringRam");
			if (lv <= 0) return 0;
			RSQ_Rammed.Launch(mo, pawn, saw, lv, doubleArg);
			return lv;
		}
		return 0;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// how fast the player's head is travelling, m/s (RSQ_MeleeHandler, as Lunge reads it): the saber's Point Taken
		if (request == "head.mps")
		{
			let h = RSQ_MeleeHandler.Get();
			let a = Actor(objectArg);
			return (h && a && a.player) ? h.headMps[a.PlayerNumber()] : 0;
		}
		// the Force's patch-only baseline: what an unlearned power is worth (rsq_force_start; 0, the default: it is off)
		if (request == "force.start") return clamp(RSQM.SV("rsq_force_start", 0.0), 0.0, 1.0);
		if (request == "upgrade.num")
		{
			int lv = max(intArg, 0);
			if (stringArg == "HeavyHands.freeze") return RSQ_Upgrade_HeavyHands.Freeze(lv, doubleArg);
			if (stringArg == "HeavyHands.knock") return RSQ_Upgrade_HeavyHands.Knock(lv);
			if (stringArg == "Hadouken.mult") return RSQ_Upgrade_ReturnFire.Mult(lv);
			if (stringArg == "Hadouken.speed") return RSQ_Upgrade_ReturnFire.Speed(lv);
			if (stringArg == "WallSplat.damage") return RSQ_Upgrade_WallSplat.Damage(lv, doubleArg);
			if (stringArg == "WallSplat.reel") return RSQ_Upgrade_WallSplat.Reel(lv);
			if (stringArg == "Guard.soak") return RSQ_Upgrade_Guard.Soak(lv);
			if (stringArg == "Guard.break") return RSQ_Upgrade_Guard.BreakAt(lv);
			// the Fists tree (up_fists.zs), A. Power
			if (stringArg == "Uppercut.lift") return RSQ_Upgrade_Uppercut.Lift(lv);
			if (stringArg == "Launcher.lift") return RSQ_Upgrade_Launcher.Lift(lv);
			if (stringArg == "Launcher.stagger") return RSQ_Upgrade_Launcher.Stagger(lv);
			if (stringArg == "Meteor.damage") return RSQ_Upgrade_Meteor.Damage(lv, doubleArg);
			if (stringArg == "GroundPound.radius") return RSQ_Upgrade_GroundPound.Radius(lv);
			if (stringArg == "GroundPound.damage") return RSQ_Upgrade_GroundPound.Damage(lv);
			if (stringArg == "GroundPound.speed") return RSQ_Upgrade_GroundPound.Speed();
			if (stringArg == "ClearOut.range") return RSQ_Upgrade_ClearOut.Range(lv);
			if (stringArg == "ClearOut.damage") return RSQ_Upgrade_ClearOut.Damage(lv);
			if (stringArg == "ClearOut.push") return RSQ_Upgrade_ClearOut.Push(lv);
			if (stringArg == "ClearOut.stagger") return RSQ_Upgrade_ClearOut.Stagger();
			// C. Combos
			if (stringArg == "Dempsey.rehit") return RSQ_Upgrade_Dempsey.Rehit(lv);
			// D. Counter
			if (stringArg == "SwatBack.mult") return RSQ_Upgrade_SwatBack.Mult(lv);
			if (stringArg == "Catch.hold") return RSQ_Upgrade_Catch.Hold(lv);
			if (stringArg == "Catch.mult") return RSQ_Upgrade_Catch.Mult(lv);
			if (stringArg == "BulletTime.mult") return RSQ_Upgrade_BulletTimeFists.Mult(lv);
			if (stringArg == "Parry.window") return RSQ_Upgrade_Parry.Window(lv);
			if (stringArg == "Parry.stagger") return RSQ_Upgrade_Parry.Stagger(lv);
			if (stringArg == "ReflectGuard.mult") return RSQ_Upgrade_ReflectGuard.Mult(lv);
			if (stringArg == "AbsorbRelease.cap") return RSQ_Upgrade_AbsorbRelease.ChargeCap(lv);
			if (stringArg == "AbsorbRelease.radius") return RSQ_Upgrade_AbsorbRelease.Radius(lv);
			// E. Grappler
			if (stringArg == "HumanShield.mult") return RSQ_Upgrade_HumanShield.Mult(lv);
			if (stringArg == "HeadlockUppercut.mult") return RSQ_Upgrade_HeadlockUppercut.Mult(lv);
			if (stringArg == "HeadlockUppercut.lift") return RSQ_Upgrade_HeadlockUppercut.Lift();
			if (stringArg == "HeavierHeadlock.mass") return RSQ_Upgrade_HeavierHeadlock.Mass(lv);
			if (stringArg == "Slam.mult") return RSQ_Upgrade_Slam.Mult(lv);
			if (stringArg == "Slam.speed") return RSQ_Upgrade_Slam.Speed();
			if (stringArg == "Slam.radius") return RSQ_Upgrade_Slam.Radius();
			if (stringArg == "Slam.stagger") return RSQ_Upgrade_Slam.Stagger();
			if (stringArg == "ThrowInto.mult") return RSQ_Upgrade_ThrowInto.Mult(lv);
			if (stringArg == "Chokehold.damage") return RSQ_Upgrade_Chokehold.Damage(lv);
			// the Saber tree (up_saber.zs)
			if (stringArg == "BattleMeditation.locks") return RSQ_Upgrade_BattleMeditation.Locks(lv);
			if (stringArg == "SaberBarrage.share") return RSQ_Upgrade_SaberBarrage.Share(lv);
			if (stringArg == "StrikeTrue.tics") return RSQ_Upgrade_StrikeTrue.Tics(lv);
			if (stringArg == "PointTaken.mult") return RSQ_Upgrade_PointTaken.Mult(lv);
			if (stringArg == "PointTaken.speed") return RSQ_Upgrade_PointTaken.Speed();
			if (stringArg == "RunThrough.tics") return RSQ_Upgrade_RunThrough.Tics(lv);
			if (stringArg == "RunThrough.finish") return RSQ_Upgrade_RunThrough.Finish();
			if (stringArg == "ReturnToSender.cone") return RSQ_Upgrade_ReturnToSender.Cone(lv);
			if (stringArg == "ReturnToSender.mirror") return RSQ_Upgrade_ReturnToSender.Mirror(lv);
			if (stringArg == "Precognition.speed") return RSQ_Upgrade_Precognition.Speed(lv);
			if (stringArg == "Precognition.width") return RSQ_Upgrade_Precognition.Width(lv);
			if (stringArg == "DoubleBladed.back") return RSQ_Upgrade_DoubleBladed.Back();
			if (stringArg == "Clash.radius") return RSQ_Upgrade_Clash.Radius(lv);
			if (stringArg == "Clash.stagger") return RSQ_Upgrade_Clash.Stagger();
			if (stringArg == "ForceSpeed.secs") return RSQ_Upgrade_ForceSpeed.Secs(lv);
			if (stringArg == "ForceLightning.damage") return RSQ_Upgrade_ForceLightning.Damage(lv);
			if (stringArg == "ForceLightning.targets") return RSQ_Upgrade_ForceLightning.Targets(lv);
			// the ShieldSaw tree (up_shield.zs)
			if (stringArg == "Cleaver.fodder") return RSQ_Upgrade_Cleaver.Fodder(lv);
			if (stringArg == "Cleaver.mid") return RSQ_Upgrade_Cleaver.Mid(lv);
			if (stringArg == "ShieldWall.ms") return RSQ_Upgrade_ShieldWall.Ms(lv);
			if (stringArg == "Reflect.mult") return RSQ_Upgrade_Reflect.Mult(lv);
			if (stringArg == "WallSlam.mult") return RSQ_Upgrade_WallSlam.Mult(lv);
			if (stringArg == "WallSlam.stun") return RSQ_Upgrade_WallSlam.Stun(lv);
			if (stringArg == "BashHitStop.tics") return RSQ_Upgrade_BashHitStop.Tics(lv);
			if (stringArg == "Charge.reach") return RSQ_Upgrade_Charge.Reach(lv);
			if (stringArg == "ShieldSize.scale") return RSQ_Upgrade_ShieldSize.Scale(lv);
			if (stringArg == "ShieldDash.m") return RSQ_Upgrade_ShieldDash.Meters(lv);
			if (stringArg == "HungryBlades.grind") return RSQ_Upgrade_HungryBlades.Grind(lv);
			if (stringArg == "BuzzsawReturn.share") return RSQ_Upgrade_BuzzsawReturn.Share(lv);
			// the Grenade tree (up_grenade.zs)
			if (stringArg == "Bandolier.carry") return RSQ_Upgrade_Bandolier.Carry(lv);
			if (stringArg == "Scavenger.share") return RSQ_Upgrade_Scavenger.Share(lv);
			if (stringArg == "StrongArm.mult") return RSQ_Upgrade_StrongArm.Mult(lv);
			if (stringArg == "FlatArc.lift") return RSQ_Upgrade_FlatArc.Lift(lv);
			if (stringArg == "FlatArc.gravity") return RSQ_Upgrade_FlatArc.Gravity(lv);
			if (stringArg == "Bounce.wall") return RSQ_Upgrade_Bounce.Wall(lv);
			if (stringArg == "ShortFuse.secs") return RSQ_Upgrade_ShortFuse.Secs(lv);
			if (stringArg == "BigBang.mult") return RSQ_Upgrade_BigBang.Mult(lv);
			if (stringArg == "Frag.mult") return RSQ_Upgrade_Frag.Mult(lv);
			if (stringArg == "Cluster.count") return RSQ_Upgrade_Cluster.Count(lv);
			if (stringArg == "Teeth.mult") return RSQ_Upgrade_Teeth.Mult(lv);
			if (stringArg == "Skeet.mult") return RSQ_Upgrade_Skeet.Mult(lv);
			if (stringArg == "SkeetWindow.tics") return RSQ_Upgrade_SkeetWindow.Tics(lv);
			if (stringArg == "Impact.mult") return RSQ_Upgrade_Impact.Mult(lv);
			// G. Gun hand, H. Taunt
			if (stringArg == "PistolWhip.stagger") return RSQ_Upgrade_PistolWhip.Stagger(lv);
			if (stringArg == "PistolWhip.mult") return RSQ_Upgrade_PistolWhip.Mult(lv);
			if (stringArg == "RifleButt.count") return RSQ_Upgrade_RifleButt.Count(lv);
			if (stringArg == "RifleButt.speed") return RSQ_Upgrade_RifleButt.Speed();
			if (stringArg == "Taunt.tics") return RSQ_Upgrade_Taunt.Tics(lv);
			if (stringArg == "Taunt.range") return RSQ_Upgrade_Taunt.Range();
			return 0;
		}
		return 0;
	}
}

// (RSQ_Buzz, the rumble, moved to RSQ Melee with its name on 2026-11-01: its gloves and Guard were its only users.)

// ---- WHAT A MONSTER CARRIES WHILE IT IS HURTING ---------------------------------------------
// One token per monster holds every timed condition the melee upgrades put on it:
//   stagger   Counterpunch: knocked out of its attack, then stood still (Executioner reads it)
//   winded    Body Blow: every state lasts longer, so it acts slower
//   down      Knockdown: on the floor for a count, doing nothing
//   disarmed  the Force pull's yank: no ranged attacks
//   recent    damage dealt by the gloves in the last 2 s, for Knockdown
//   frozen    Frost Fist: solid (the engine's freezetics), tinted ice; a boss is winded instead (11-02)
//   burning   Fire Fist: this patch's own burn, paid to the glove that lit it (11-02)
class RSQ_Dazed : Inventory
{
	int staggerUntil, windedUntil, downUntil, disarmUntil;
	int frozenUntil, shatterTic;
	double shatterMult;                // "freeze" with a shatter: the next hard hit on it while frozen does this many times
	int critUntil;                     // Critical Hits: stunned by a critical until this tic
	int luckyTic;                      // Kill Rewards' Lucky Kill: the tic a critical or a Finisher last landed (RSQM.Touch)
	String luckyWhy;
	int markUntil, markPn, markUsed;   // Pistol Whip: that player's next hit lands harder until this tic
	double markMult;
	const MARK_TICS = 70;
	const SHATTER_HIT = 20;            // what counts as a hard hit for the shatter
	bool tinted;
	TranslationID oldTranslation;
	int burnUntil, burnNext, burnDmg;
	PlayerPawn burnBy;
	Weapon burnGlove;
	double windFactor;
	int downCount, downNext;
	Array<int> hitTic;
	Array<int> hitDmg;

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }

	static RSQ_Dazed On(Actor mo)
	{
		if (!mo) return null;
		let d = RSQ_Dazed(mo.FindInventory("RSQ_Dazed"));
		if (!d) d = RSQ_Dazed(mo.GiveInventoryType("RSQ_Dazed"));
		return d;
	}

	bool IsStaggered() { return level.maptime < staggerUntil || level.maptime < downUntil; }
	bool IsDown() { return level.maptime < downUntil; }
	bool IsFrozen() { return level.maptime < frozenUntil; }
	bool IsBurning() { return level.maptime < burnUntil; }

	// FROZEN (Frost Fist): nothing it does goes anywhere for `tics` (the engine's freezetics), drawn in the engine's Ice
	// translation; a boss is slowed by half instead (Wind at full factor)
	void Freeze(int tics)
	{
		if (!owner || owner.health <= 0 || tics <= 0) return;
		if (owner.bBoss) { Wind(tics, 1.0); return; }
		frozenUntil = max(frozenUntil, level.maptime + tics);
		owner.freezetics = max(owner.freezetics, tics);
		if (!tinted) { oldTranslation = owner.Translation; owner.A_SetTranslation('Ice'); tinted = true; }
	}
	void Thaw()
	{
		frozenUntil = 0;
		if (owner) owner.freezetics = 0;
		if (owner && tinted) owner.Translation = oldTranslation;
		tinted = false;
	}

	// PISTOL WHIP's mark (RSQ Melee's shove asks "whip.mark"): player pn's next hit inside MARK_TICS, the shove itself
	// excepted, does x mult (every hit of that one tic: a shotgun's pellets)
	void Mark(int pn, double mult)
	{
		markPn = pn;
		markMult = mult;
		markUntil = level.maptime + MARK_TICS;
		markUsed = -1;
	}
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		// THE SHATTER ("freeze" with a shatter: RSQ Grenade's Freeze): a hard hit on it while frozen breaks the ice
		if (passive && shatterMult > 1 && damage >= SHATTER_HIT && IsFrozen())
		{
			newdamage = int(round(damage * shatterMult));
			shatterMult = 0;
			shatterTic = level.maptime;
			Thaw();
			if (owner) owner.A_StartSound("misc/icebreak", CHAN_AUTO, CHANF_OVERLAP, 1.0);
			return;
		}
		if (!IsFrozen()) shatterMult = 0;
		if (!passive || damage <= 0 || !source || !source.player || damageType == 'Kick') return;
		int now = level.maptime;
		if (now > markUntil || source.PlayerNumber() != markPn) return;
		if (markUsed >= 0 && markUsed != now) { markUntil = 0; return; }
		markUsed = now;
		newdamage = int(round(damage * markMult));
	}

	// BURNING (Fire Fist): `dmg` every half second for `tics`, paid to the glove that lit it
	void Ignite(PlayerPawn by, Weapon glove, int tics, int dmg)
	{
		if (!owner || owner.health <= 0) return;
		if (!IsBurning()) burnNext = level.maptime + 17;
		burnUntil = max(burnUntil, level.maptime + tics);
		burnDmg = max(burnDmg, dmg);
		burnBy = by;
		burnGlove = glove;
	}

	// Hold it in its pain frame for `tics`. A monster with no Pain state is still held where it is.
	void Stagger(int tics)
	{
		if (!owner || owner.health <= 0) return;
		staggerUntil = max(staggerUntil, level.maptime + tics);
		State p = owner.FindState("Pain");
		if (p) owner.SetState(p);
		if (owner.tics >= 0 && owner.tics < tics) owner.tics = tics;
	}

	void Wind(int tics, double factor)
	{
		windedUntil = max(windedUntil, level.maptime + tics);
		windFactor = max(windFactor, factor);
	}

	// The count. It goes down, the count is spoken (SuperPunchOut's announcer, 1..n), it gets up.
	void KnockDown(int seconds)
	{
		if (!owner || owner.health <= 0 || IsDown()) return;
		downUntil = level.maptime + seconds * 35 + 8;
		downCount = 0;
		downNext = level.maptime + 8;
		hitTic.Clear(); hitDmg.Clear();
		owner.A_StartSound("rsq/knocked", CHAN_AUTO, 0, 1.0);
		owner.vel.xy *= 0.3;
	}

	int RecentDamage(int window)
	{
		int sum = 0;
		for (int i = hitTic.Size() - 1; i >= 0; i--)
		{
			if (level.maptime - hitTic[i] > window) { hitTic.Delete(i); hitDmg.Delete(i); continue; }
			sum += hitDmg[i];
		}
		return sum;
	}
	void NoteHit(int dmg) { hitTic.Push(level.maptime); hitDmg.Push(dmg); }

	override void DoEffect()
	{
		Super.DoEffect();
		let mo = owner;
		if (!mo || mo.health <= 0) return;
		int now = level.maptime;
		// the freeze is over (a frozen monster does not tick, so this runs on its first tic after): its own colours back
		if (tinted && now >= frozenUntil) Thaw();
		if (now < burnUntil)
		{
			if (now % 3 == 0) mo.A_SpawnParticle("FF7020", SPF_FULLBRIGHT, 14, 6, 0,
				frandom[RSQFx](-mo.radius, mo.radius), frandom[RSQFx](-mo.radius, mo.radius), frandom[RSQFx](0, mo.height),
				0, 0, frandom[RSQFx](0.5, 1.5), 0, 0, 0.02, 1.0, -0.06);
			if (now >= burnNext)
			{
				burnNext = now + 17;
				let hit = RSQM.GloveHit(burnBy, burnGlove, mo.pos + (0, 0, mo.height * 0.5));
				mo.DamageMobj(hit ? hit : Actor(burnBy), burnBy, burnDmg, 'Fire', DMG_THRUSTLESS);
				if (!mo || mo.health <= 0) return;
			}
		}
		else burnDmg = 0;
		if (now < downUntil)
		{
			// DOWN: frozen in its pain frame, nothing it does goes anywhere
			State p = mo.FindState("Pain");
			if (p && !mo.InStateSequence(mo.CurState, p)) mo.SetState(p);
			if (mo.tics >= 0 && mo.tics < 2) mo.tics = 2;
			mo.vel.xy *= 0.5;
			if (now >= downNext && downCount < 10)
			{
				downCount++;
				downNext = now + 35;
				mo.A_StartSound(String.Format("rsq/count/%d", downCount), CHAN_AUTO, 0, 0.9);
			}
			return;
		}
		if (now < staggerUntil && mo.tics >= 0 && mo.tics < 1) mo.tics = 1;
		// WINDED: every state it enters lasts longer, which is slower walking, slower aiming,
		// slower everything -- the way RSQ SlowMo slows a monster, for one monster.
		if (now < windedUntil && mo.tics > 0 && (now % 2) == 0 && frandom[RSQWind](0, 1) < windFactor) mo.tics++;
		// DISARMED: no ranged attack while it lasts -- it goes back to chasing you
		if (now < disarmUntil)
		{
			State m = mo.FindState("Missile");
			if (m && mo.InStateSequence(mo.CurState, m)) { State s = mo.FindState("See"); if (s) mo.SetState(s); }
		}
	}
}

// ---- BATTERING RAM: a bashed monster is a missile for a moment ------------------------------
// Whatever it flies into takes the hit, and so does it. Paid to the ShieldSaw (the inflictor is
// the weapon itself, which Gun Bonsai's patch reads as the weapon's own claim).
class RSQ_Rammed : Inventory
{
	PlayerPawn by;
	Weapon saw;
	int lv, untilTic;
	Array<Actor> struck;

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	static void Launch(Actor mo, PlayerPawn pawn, Weapon saw, int lv, double how)
	{
		if (!mo || mo.health <= 0) return;
		let r = RSQ_Rammed(mo.FindInventory("RSQ_Rammed"));
		if (!r) r = RSQ_Rammed(mo.GiveInventoryType("RSQ_Rammed"));
		if (!r) return;
		r.by = pawn; r.saw = saw; r.lv = lv;
		r.untilTic = level.maptime + 21;
		r.struck.Clear();
		// a harder bash throws further: the shield's own shove, again, per level
		double k = clamp(how / 45.0, 0.5, 2.0) * (0.25 * lv) * clamp(100.0 / max(mo.mass, 1), 0.08, 2.0);
		if (!mo.bDontThrust) mo.vel.xy *= 1.0 + k;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		let mo = owner;
		if (!mo || mo.health <= 0 || level.maptime > untilTic) { Destroy(); return; }
		double sp = mo.vel.xy.Length();
		if (sp < 3.0) return;
		let it = BlockThingsIterator.Create(mo, mo.radius + 48);
		while (it.Next())
		{
			let o = it.thing;
			if (!o || o == mo || o == by || !o.bShootable || o.health <= 0 || o.player) continue;
			if (struck.Find(o) < struck.Size()) continue;
			if (mo.Distance2D(o) > mo.radius + o.radius + 4) continue;
			if (abs((o.pos.z + o.height * 0.5) - (mo.pos.z + mo.height * 0.5)) > (o.height + mo.height) * 0.5) continue;
			struck.Push(o);
			int dmg = int((6 + 4 * lv) + sp * (0.6 + 0.3 * lv));
			Actor inf = saw ? Actor(saw) : Actor(by);
			o.DamageMobj(inf, by, dmg, 'Melee', DMG_THRUSTLESS);
			if (mo && mo.health > 0) mo.DamageMobj(inf, by, dmg / 2, 'Melee', DMG_THRUSTLESS);
			if (o && !o.bDontThrust) o.vel.xy += mo.vel.xy * 0.6 * clamp(mo.mass / max(o.mass, 1.0), 0.2, 1.5);
			if (mo) { mo.vel.xy *= 0.4; mo.A_StartSound("rsq/ram", CHAN_AUTO, 0, 1.0); }
			if (!mo || mo.health <= 0) return;
		}
	}
}

// A glove's hit that is not a punch (RSQM.GloveHit): nothing but a name Gun Bonsai can pay to the glove.
class RSQ_GloveHit : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }
	States { Spawn: TNT1 A 2; Stop; }
}

// RSQ HP BARS' MARKERS (owner 11-02: the new monster states on the bars). HP Bars asks every service whose name holds
// "RSQTHP_Marker" (handler.zs MarkersOf) for hooked / stunned / locked / gripped. Ours answers STUNNED (its star) for a
// monster held in its pain (RSQ_Dazed: a stagger, a knockdown) or stunned by a Critical; frozen shows already as the
// snowflake (Freeze sets the freeze count HP Bars reads). Nothing is made on a monster to answer: no RSQ_Dazed, no star.
class RSQTHP_MarkerGBVR : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "stunned") return 0;
		let mo = Actor(objectArg);
		let d = mo ? RSQ_Dazed(mo.FindInventory("RSQ_Dazed")) : null;
		return (d && (d.IsStaggered() || level.maptime < d.critUntil)) ? 1 : 0;
	}
}
