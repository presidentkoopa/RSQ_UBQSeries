// RSQ melee upgrades for Gun Bonsai -- the shared core.
//
// Gun Bonsai is Rebecca "ToxicFrog" Kelly's (MIT). The melee upgrade paths, the gloves'
// punch reader and Slappers Only are presidentkoopa's (this patch, same terms).
//
// HOW THE MODS TALK. No mod links to another: the saber (UltraBadassQuestSaber) and the
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

	// What Slappers Only lets you keep: the gloves, the sabers, the ShieldSaw, the Force hand,
	// Brutal Doom's fists, axe and sword, the BD22 pack's off-hand fist -- and anything a mod
	// itself flags as a melee weapon (the chainsaw is one).
	static bool IsSlapperClass(Class<Actor> c)
	{
		if (!c) return false;
		String n = c.GetClassName();
		if (IsGloveName(n) || IsSaberName(n) || IsShieldName(n)) return true;
		if (n ~== "Melee_Attacks" || n ~== "BrutalAxe" || n ~== "DSweap" || n ~== "RSQ_Hands" || n ~== "UBQS_ForceHand") return true;
		let w = (Class<Weapon>)(c);
		if (!w) return false;
		let d = GetDefaultByType(w);
		return d && d.bMeleeWeapon;
	}

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
//   "ram"          objectArg = a monster the ShieldSaw just bashed, intArg = player number,
//                  doubleArg = how hard: Battering Ram turns it into a missile, if learned.
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
		if (request == "credit.push" || request == "credit.pop")
		{
			let w = Weapon(objectArg);
			if (!w || !w.owner) return 0;
			let stats = TFLV_PerPlayerStats.GetStatsFor(w.owner);
			if (!stats) return 0;
			if (request == "credit.push") stats.PushClaim(w, intArg); else stats.PopClaim();
			return 1;
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
		// the Force's patch-only baseline: what an unlearned power is worth (rsq_force_start)
		if (request == "force.start") return clamp(RSQM.SV("rsq_force_start", 0.6), 0.1, 1.0);
		return 0;
	}
}

// ---- A RUMBLE on one controller -------------------------------------------------------------
// The series' haptic route, as UltraBadassQuestSaber's UBQS_Buzzer does it: A_QuakeEx QF_WAVE,
// re-issued each tic, X the left controller and Y the right. Local to its owner (tremor 8).
class RSQ_Buzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, leftTics;
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }

	static void Start(Actor who, int hand, double k, int tics)
	{
		if (!who || !who.player) return;
		bool lefty = false;
		if (!multiplayer) { let cs = CVar.FindCVar("vr_control_scheme"); lefty = cs && cs.GetInt() >= 10; }
		let q = RSQ_Buzz(Actor.Spawn("RSQ_Buzz", who.pos));
		if (!q) return;
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(k, 0.12, 1.0);
		q.total = clamp(tics, 1, 16);
		q.leftTics = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels || leftTics <= 0) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		double a = amp * leftTics / double(total) / 3.2;
		leftTics--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}
	States { Spawn: TNT1 A 20; Stop; }
}

// ---- WHAT A MONSTER CARRIES WHILE IT IS HURTING ---------------------------------------------
// One token per monster holds every timed condition the melee upgrades put on it:
//   stagger   Counterpunch: knocked out of its attack, then stood still (Executioner reads it)
//   winded    Body Blow: every state lasts longer, so it acts slower
//   down      Knockdown: on the floor for a count, doing nothing
//   disarmed  the Force pull's yank: no ranged attacks
//   recent    damage dealt by the gloves in the last 2 s, for Knockdown
class RSQ_Dazed : Inventory
{
	int staggerUntil, windedUntil, downUntil, disarmUntil;
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
