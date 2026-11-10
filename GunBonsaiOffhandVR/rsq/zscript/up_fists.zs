// THE FISTS TREE, the nodes new on 2026-11-02 (GBOVR_TREES.md section 4.1; every node kept by the owner, 11-02).
// The fourteen that existed before are in up_gloves.zs (their class names are kept for saves). Each fist is its own
// record, as before: a glove's upgrades apply to that glove's punches, and a node is offered to a glove only once that
// glove holds its parent (Has / PHas / LevelOf, up_gloves.zs RSQ_Upgrade_Base).
//
// WHO DOES WHAT. A node here is the upgrade: Gun Bonsai offering it, its level, its numbers. The move is RSQ Melee's;
// Melee asks this patch for a level ("level" / "unlocked" on RSQ_MeleeUpgradeService) and for the numbers
// ("upgrade.num", core.zs, which calls the static formulas below). A node that changes a punch's damage does it here,
// in ModifyDamageDealt, where the glove is the inflictor; it asks Melee about the punch through RSQML_Service by name.

// ---- A. POWER ------------------------------------------------------------------------------------------------------
// Heavy Hands (root) -> Haymaker -> Wallflower -> Knockdown; Heavy Hands 2 -> Body Blow -> Knockdown; the five below.

// a launch's height in metres for an imp-sized monster (mass 100): up map units a tic against gravity 1 a tic, the
// vertical x pixelstretch 1.2 at 34 units a metre. For the tooltips only.
class RSQ_FistMath
{
	static clearscope double LiftM(double up) { return up * up * 0.5 * 1.2 / 34.0; }
	static clearscope String Metres(double m) { return String.Format("%.1f m", m); }
	// SOMEONE READS BOTH HANDS (owner 2026-11-04 19:45): RSQ Gestures, or RSQ Melee's own copy of Gestures' two-hand reader
	// (its RSQML_GCopyService "pair.reader" 1, by name), which Melee uses when Gestures is not loaded. The two-hand moves
	// (Ground Pound, Clear Out, Absorb and Release's release, Taunt) are offered with either; nothing else changes.
	static play bool TwoHandReader()
	{
		if (RSQM.Svc("RSQG_Service")) return true;
		let s = RSQM.Svc("RSQML_GCopyService");
		return s && s.GetInt("pair.reader") == 1;
	}
}

// UPPERCUT (an unlock): without it, under Gun Bonsai VR, a rising punch is a jab and lifts nothing. Learned, a rising
// punch is an uppercut (the Super spark, the launch); levels 2 and 3 throw it higher.
class RSQ_Upgrade_Uppercut : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands") && LevelOf(info, "Uppercut") < 3; }
	// map units a tic of lift on top of the uppercut's own 5 to 9: none at level 1, +2 a level after
	static double Lift(uint lv) { return 2.0 * max(int(lv) - 1, 0); }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		// a half-speed uppercut (7 units a tic) on an imp, as the tree states it
		fields.Insert("high", RSQ_FistMath.Metres(RSQ_FistMath.LiftM(7.0 + Lift(level))));
	}
}

// LAUNCHER: what an uppercut lifts hangs in pain for the whole flight and staggers when it lands; it goes higher.
class RSQ_Upgrade_Launcher : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Uppercut", 2) && LevelOf(info, "Launcher") < 3; }
	static double Lift(uint lv) { return 3.0 * lv; }
	static int Stagger(uint lv) { return 10 + 10 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("high", RSQ_FistMath.Metres(RSQ_FistMath.LiftM(7.0 + RSQ_Upgrade_Uppercut.Lift(2) + Lift(level))));
		fields.Insert("time", AsSeconds(Stagger(level)));
	}
}

// JUGGLE: a punch on a monster you launched, inside 2 s, while it is still off the floor, hits harder and lifts it again
// (the re-lift is RSQ Melee's; the damage is here).
class RSQ_Upgrade_Juggle : RSQ_Upgrade_Base
{
	const WINDOW = 70;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher") && LevelOf(info, "Juggle") < 3; }
	static double Mult(uint lv) { return 1.5 + 0.25 * lv; }
	// tics since this player's uppercut launched it while it is still in the air, or -1 (RSQ Melee's "launch.age")
	static int LaunchAge(Actor pawn, Actor target)
	{
		let s = RSQM.Svc("RSQML_Service");
		if (!s || !pawn || !pawn.player || !target) return -1;
		return s.GetInt("launch.age", "", pawn.PlayerNumber(), 0, target);
	}
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!IsGlove(shot) || !Monster(target)) return damage;
		int age = LaunchAge(pawn, target);
		if (age < 0 || age > WINDOW) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(WINDOW));
	}
}

// METEOR: a launched monster that comes down on another hurts them both (RSQ Melee watches the fall).
class RSQ_Upgrade_Meteor : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher", 2) && LevelOf(info, "Meteor") < 3; }
	// fall = its downward speed when it hits, map units a tic
	static int Damage(uint lv, double fall) { return int(10 + 10 * lv + max(fall, 0.0)); }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("dmg", String.Format("%d", Damage(level, 0))); }
}

// GROUND POUND: both fists swung down hard together (RSQ Gestures' "both hands down", at GroundPound.speed or more): a
// shockwave round you. With Knockdown learned on that glove, what it hits that is no boss goes down for a count of 2.
class RSQ_Upgrade_GroundPound : RSQ_Upgrade_Base
{
	// needs someone reading "both hands down": RSQ Gestures or RSQ Melee's own copy (TwoHandReader; item 24, 11-04)
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher", 3) && LevelOf(info, "GroundPound") < 3 && RSQ_FistMath.TwoHandReader(); }
	static double Radius(uint lv) { return 2.0 + 0.5 * lv; }     // metres
	static int Damage(uint lv) { return 20 + 10 * lv; }
	static double Speed() { return 3.0; }                        // m/s down, each hand
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("radius", RSQ_FistMath.Metres(Radius(level)));
		fields.Insert("dmg", String.Format("%d", Damage(level)));
	}
}

// CLEAR OUT (the owner's, 11-02: "a two hand, palm out shoving gesture to clear a wide area in front of you"): both
// palms thrust forward together (RSQ Gestures' "both palms thrust"): everything in a 90-degree wedge in front is shoved
// back hard, hurt, and staggered.
class RSQ_Upgrade_ClearOut : RSQ_Upgrade_Base
{
	// needs someone reading "both palms thrust": RSQ Gestures or RSQ Melee's own copy (TwoHandReader; item 24, 11-04)
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands", 2) && LevelOf(info, "ClearOut") < 3 && RSQ_FistMath.TwoHandReader(); }
	static double Range(uint lv) { return 2.0 + 0.5 * lv; }      // metres
	static int Damage(uint lv) { return 10 + 5 * lv; }
	static double Push(uint lv) { return 12.0 + 2.0 * lv; }       // map units a tic, on a 100-mass monster
	static int Stagger() { return 10; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("range", RSQ_FistMath.Metres(Range(level)));
		fields.Insert("dmg", String.Format("%d", Damage(level)));
	}
}

// ---- B. ELEMENTAL --------------------------------------------------------------------------------------------------
// One element per glove (owner, 11-02): learning one closes the other three on that glove; the other glove may take a
// different one. Each element's own hits -- the blast, the arc, the burn -- are paid to the glove through a helper
// (RSQM.GloveHit) that no other upgrade procs from, and they are not punches (the glove upgrades read the last punch off
// the glove itself). The look is a placeholder until the art pass (GBOVR_TREES.md 4: kiddolink's bursts by level,
// recoloured per element): particles and stock Doom sounds.
class RSQ_ElementUpgrade : RSQ_Upgrade_Base
{
	// this glove already carries an element other than `mine`
	static bool OtherElement(TFLV_WeaponInfo info, String mine)
	{
		static const String ELEMENTS[] = { "ExplosiveFist", "FrostFist", "ShockFist", "FireFist" };
		for (int i = 0; i < ELEMENTS.Size(); i++) if (ELEMENTS[i] != mine && Has(info, ELEMENTS[i])) return true;
		return false;
	}
	// offered to a glove that holds the parent, carries no other element, and is under the cap
	static bool Offer(TFLV_WeaponInfo info, String mine, String parent, int parentLv, int cap)
	{
		return GloveInfo(info) && Has(info, parent, parentLv) && !OtherElement(info, mine) && LevelOf(info, mine) < cap;
	}
	static void Burst(Actor at, Vector3 pos, Color c, int n, double speed, double size = 6)
	{
		if (!at) return;
		for (int i = 0; i < n; i++)
		{
			at.A_SpawnParticle(c, SPF_FULLBRIGHT, 18, size, 0,
				pos.x - at.pos.x, pos.y - at.pos.y, pos.z - at.pos.z,
				frandom[RSQFx](-speed, speed), frandom[RSQFx](-speed, speed), frandom[RSQFx](-speed * 0.5, speed),
				0, 0, -0.1, 1.0, -0.05);
		}
	}
}

// EXPLOSIVE FIST: a punch at half power or more blasts round the hit (you are never in it); under the Berserk the
// radius doubles.
class RSQ_Upgrade_ExplosiveFist : RSQ_ElementUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "ExplosiveFist", "Haymaker", 1, 4); }
	static double Radius(uint lv) { return 64.0 + 16.0 * lv; }   // map units
	static int Damage(uint lv) { return 10 + 5 * lv; }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !target || PunchPower(shot) < 0.5) return;
		double r = Radius(level);
		if (pawn && pawn.CountInv("PowerStrength") > 0) r *= 2;
		int dmg = Damage(level);
		Vector3 at = target.pos + (0, 0, target.height * 0.5);
		let hit = RSQM.GloveHit(pawn, Weapon(shot), at);
		int n = 0;
		let it = BlockThingsIterator.Create(target, r);
		while (it.Next())
		{
			let o = it.thing;
			if (!RSQM.IsFoe(pawn, o) || target.Distance3D(o) > r + o.radius) continue;
			o.DamageMobj(hit, pawn, dmg, 'Melee', DMG_THRUSTLESS);
			n++;
		}
		if (target) { target.A_StartSound("rsqml/fx/blast", CHAN_AUTO, CHANF_OVERLAP, 0.9); Burst(target, at, "FFF0D0", 6, 3.0, 8); }
		RSQM.Burst("RSQML_BurstE", at, r / 64.0, RSQM.ByLevel(level, 4));
		RSQM.Touch("fist.explosive", pawn, target);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("radius", RSQ_FistMath.Metres(Radius(level) / 34.0));
		fields.Insert("dmg", String.Format("%d", Damage(level)));
	}
}

// FROST FIST: the monster freezes solid (tinted ice); the next punch on a frozen monster shatters the ice for a much
// harder hit and ends the freeze. A boss is slowed by half instead (RSQ_Dazed.Freeze).
class RSQ_Upgrade_FrostFist : RSQ_ElementUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "FrostFist", "BodyBlow", 1, 4); }
	static int Tics(uint lv) { return 35 + 17 * lv; }          // 1 s + 0.5 s a level
	static double Shatter(uint lv) { return 2.0 + 0.5 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!IsGlove(shot) || !Monster(target)) return damage;
		let dz = RSQ_Dazed(target.FindInventory("RSQ_Dazed"));
		if (!dz || !dz.IsFrozen()) return damage;
		dz.Thaw();
		dz.shatterTic = RSQM.Now();
		Burst(target, target.pos + (0, 0, target.height * 0.5), "A0E0FF", 16, 4.0, 5);
		RSQM.Burst("RSQML_BurstF", target.pos + (0, 0, target.height * 0.5), 1.0, RSQM.ByLevel(level, 4));
		target.A_StartSound("misc/icebreak", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		RSQM.Touch("shatter", pawn, target);
		return damage * Shatter(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !Monster(target)) return;
		let dz = RSQ_Dazed.On(target);
		if (!dz || dz.shatterTic == RSQM.Now()) return;   // the punch that shattered it does not freeze it again
		dz.Freeze(Tics(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", AsSeconds(Tics(level)));
		fields.Insert("mult", String.Format("x%.1f", Shatter(level)));
	}
}

// SHOCK FIST: the hit arcs to the nearest monsters round it, each taking a share of the punch and a stagger.
class RSQ_Upgrade_ShockFist : RSQ_ElementUpgrade
{
	const RANGE = 102.0;   // 3 m
	const STAGGER = 8;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "ShockFist", "OneTwo", 1, 3); }
	static double Share(uint lv) { return 0.4 + 0.1 * lv; }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !target || damage <= 0) return;
		// the `level` nearest within RANGE of what was punched, nearest first
		Array<Actor> near;
		Array<double> dist;
		let it = BlockThingsIterator.Create(target, RANGE);
		while (it.Next())
		{
			let o = it.thing;
			if (o == target || !RSQM.IsFoe(pawn, o)) continue;
			double d = target.Distance3D(o);
			if (d > RANGE + o.radius) continue;
			int k = 0;
			while (k < dist.Size() && dist[k] <= d) k++;
			near.Insert(k, o); dist.Insert(k, d);
		}
		int arcs = min(int(level), near.Size());
		if (arcs <= 0) return;
		int dmg = max(1, int(round(damage * Share(level))));
		Vector3 from = target.pos + (0, 0, target.height * 0.6);
		let hit = RSQM.GloveHit(pawn, Weapon(shot), from);
		for (int i = 0; i < arcs; i++)
		{
			let o = near[i];
			if (!o || o.health <= 0) continue;
			Vector3 to = o.pos + (0, 0, o.height * 0.6);
			Vector3 d = to - from;
			int steps = max(4, int(d.Length() / 8));
			for (int s = 0; s <= steps; s++)
			{
				Vector3 p = from + d * (double(s) / steps) + (frandom[RSQFx](-3, 3), frandom[RSQFx](-3, 3), frandom[RSQFx](-3, 3));
				target.A_SpawnParticle("FFF060", SPF_FULLBRIGHT, 8, 4, 0, p.x - target.pos.x, p.y - target.pos.y, p.z - target.pos.z);
			}
			o.DamageMobj(hit, pawn, dmg, 'Melee', DMG_THRUSTLESS);
			if (o && o.health > 0) RSQ_Dazed.On(o).Stagger(STAGGER);
			RSQM.Touch("arc", pawn, o);
			if (o) RSQM.Burst("RSQML_BurstS", to, 0.6, RSQM.ByLevel(level, 3));
		}
		if (target) target.A_StartSound("rsqml/fx/zap", CHAN_AUTO, CHANF_OVERLAP, 0.9);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("n", String.Format("%d", level));
		fields.Insert("share", AsPercent(Share(level)));
	}
}

// FIRE FIST: the monster burns (this patch's own burn, RSQ_Dazed.Ignite, not Gun Bonsai's); punching a burning monster
// flares it for a harder hit.
class RSQ_Upgrade_FireFist : RSQ_ElementUpgrade
{
	const TICK_DMG = 3;    // every half second
	const FLARE = 1.5;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "FireFist", "HeavyHands", 2, 4); }
	static int Tics(uint lv) { return 35 * (2 + lv); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!IsGlove(shot) || !Monster(target)) return damage;
		let dz = RSQ_Dazed(target.FindInventory("RSQ_Dazed"));
		if (!dz || !dz.IsBurning()) return damage;
		Burst(target, target.pos + (0, 0, target.height * 0.5), "FF7020", 8, 3.0, 7);
		target.A_StartSound("rsqml/fx/flare", CHAN_AUTO, CHANF_OVERLAP, 0.9);
		RSQM.Burst("RSQML_BurstR", target.pos + (0, 0, target.height * 0.5), 0.75, RSQM.ByLevel(level, 4));
		return damage * FLARE;
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !Monster(target)) return;
		let dz = RSQ_Dazed.On(target);
		if (!dz.IsBurning()) target.A_StartSound("rsqml/fx/ignite", CHAN_AUTO, CHANF_OVERLAP, 0.8);
		dz.Ignite(PlayerPawn(pawn), Weapon(shot), Tics(level), TICK_DMG);
		RSQM.Touch("burn", pawn, target);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("dmg", String.Format("%d", TICK_DMG));
		fields.Insert("time", AsSeconds(Tics(level)));
		fields.Insert("mult", AsPercentIncrease(FLARE));
	}
}

// ---- C. COMBOS -----------------------------------------------------------------------------------------------------
// The chain is RSQ Melee's: "punch.chain" (One-Two: alternating hands), "punch.kinds" (this player's punches inside a
// second, oldest first, digits kind + 1: jab 1, hook 2, uppercut 3) and "punch.run" (Dempsey: alternating hooks).
// One-Two (root) is in up_gloves.zs.
class RSQ_ComboMath
{
	// how many punches "punch.kinds" holds (0 to 3)
	static int Count(int kinds) { return kinds <= 0 ? 0 : kinds < 10 ? 1 : kinds < 100 ? 2 : 3; }
}

// THREE-HIT: jab, jab, hook inside a second -- the hook hits harder and staggers.
class RSQ_Upgrade_ThreeHit : RSQ_Upgrade_Base
{
	const PATTERN = 112;   // jab, jab, hook
	const STAGGER = 10;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "OneTwo", 2) && LevelOf(info, "ThreeHit") < 3; }
	static double Mult(uint lv) { return 1.5 + 0.25 * lv; }
	static bool Landed(Actor shot) { return Punch(shot, "punch.kinds") == PATTERN; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		return Landed(shot) ? damage * Mult(level) : damage;
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!Landed(shot) || !Monster(target)) return;
		RSQ_Dazed.On(target).Stagger(STAGGER);
		RSQM.Touch("combo.3", pawn, target);
		RSQM.Burst("RSQML_Burst1", target.pos + (0, 0, target.height * 0.6), 1.0, RSQM.ByLevel(level, 3));
		target.A_StartSound("rsqml/fx/heavy", CHAN_AUTO, CHANF_OVERLAP, 0.9);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// DEMPSEY: alternating hooks, each inside 0.6 s -- each hook in the run hits harder, and in a run the glove re-arms
// faster (RSQ Melee asks Dempsey.rehit).
class RSQ_Upgrade_Dempsey : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "ThreeHit") && LevelOf(info, "Dempsey") < 3; }
	static int Rehit(uint lv) { return max(5 - int(lv), 2); }   // tics: 4, 3, 2 (6 without it)
	static double Step(uint lv) { return 0.10 * lv; }
	static double Mult(uint lv, int run) { return 1.0 + Step(lv) * max(run - 1, 0); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		int run = Punch(shot, "punch.run");
		return run >= 2 ? damage * Mult(level, run) : damage;
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (Punch(shot, "punch.run") >= 2 && target)
		{
			RSQM.Touch("combo.dempsey", pawn, target);
			RSQM.Burst("RSQML_Burst1", target.pos + (0, 0, target.height * 0.6), 0.75, RSQM.ByLevel(level, 3));
		}
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(Step(level)));
		fields.Insert("rehit", AsSeconds(Rehit(level)));
	}
}

// FINISHER: the last hit of a chain of three or more on a staggered monster with little left kills it (Executioner's
// rule, so it needs Executioner on this glove), with a slow-motion pulse (RSQ SlowMo).
class RSQ_Upgrade_Finisher : RSQ_Upgrade_Base
{
	const PULSE_MS = 300;
	const PULSE_DEPTH = 40;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		return GloveInfo(info) && Has(info, "ThreeHit", 2) && Has(info, "Executioner") && LevelOf(info, "Finisher") < 3;
	}
	static double Share(uint lv) { return 0.25 + 0.05 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!IsGlove(shot) || !Monster(target) || target.bBoss) return damage;
		int chain = max(Punch(shot, "punch.chain"), RSQ_ComboMath.Count(Punch(shot, "punch.kinds")));
		if (chain < 3 || !RSQM.Staggered(target) || target.health > RSQM.StartHealth(target) * Share(level)) return damage;
		double need = RSQ_Upgrade_Executioner.KillBlow(pawn, shot, target, attacktype);
		if (need <= 0) return damage;
		target.A_StartSound("rsq/execute", CHAN_AUTO, 0, 1.0);
		target.A_StartSound("rsqml/fx/heavy", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		RSQM.Pulse(PlayerPawn(pawn), PULSE_MS, PULSE_DEPTH);
		RSQM.Touch("finisher", pawn, target);
		RSQM.Burst("RSQML_Burst5", target.pos + (0, 0, target.height * 0.6), 1.5, 0);
		return max(damage, need);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("share", AsPercent(Share(level))); }
}

// ---- D. COUNTER ----------------------------------------------------------------------------------------------------
// Guard is the player's (up_suite.zs RSQ_Upgrade_Guard; RSQ Melee's row Start With Guard gives level 1 before it is
// learned), and so are the three nodes that grow it: Parry, Reflect Guard, Absorb and Release (RSQ Melee's guard.zs
// does each). Counterpunch, Swat Back and Hadouken are a glove's, on the player's Guard. Catch and Bullet Time Fists are
// a glove's too, after Hadouken (owner 11-02: both built for the headset pass; Catch on the open-hand frame).

// SWAT BACK: the open palm's swat sends the missile back at its shooter instead of aside.
class RSQ_Upgrade_SwatBack : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && GuardOwned(info.stats) && LevelOf(info, "SwatBack") < 3; }
	static double Mult(uint lv) { return 1.0 + 0.15 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercent(Mult(level))); }
}

// CATCH (after Hadouken 2): an open palm held still catches a missile as it reaches it, holds it 2 + lv s, and the
// hand throws it at x1.5 + 0.25 lv. (RSQ Melee gloves.zs CatchTick)
class RSQ_Upgrade_Catch : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "ReturnFire", 2) && LevelOf(info, "Catch") < 3; }
	static double Hold(uint lv) { return 2.0 + lv; }
	static double Mult(uint lv) { return 1.5 + 0.25 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", AsSeconds(int(Hold(level) * TICRATE)));
		fields.Insert("mult", AsPercent(Mult(level)));
	}
}
// BULLET TIME FISTS (after Hadouken 3; needs RSQ SlowMo): in slow motion a punch through a slowed round sends it home at
// its own damage x1.5 + 0.5 lv. (RSQ Melee gloves.zs ReturnFire)
class RSQ_Upgrade_BulletTimeFists : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "ReturnFire", 3) && RSQM.Has("RSQSM_Clock") && LevelOf(info, "BulletTimeFists") < 3; }
	static double Mult(uint lv) { return 1.5 + 0.5 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercent(Mult(level))); }
}

// A node that grows the Guard: the player's, offered while RSQ Melee is loaded, on its parent.
class RSQ_GuardPerk : RSQ_Perk
{
	override int Cap() { return 3; }
	override bool ModLoaded() { return RSQM.Svc("RSQML_Service") != null; }
	virtual bool Parent(TFLV_PerPlayerStats stats) { return GuardOwned(stats); }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats) { return Super.IsSuitableForPlayer(stats) && Parent(stats); }
}

// PARRY: a Guard whose hands are driven into the blow just before it lands takes nothing, and the attacker reels.
class RSQ_Upgrade_Parry : RSQ_GuardPerk
{
	static int Window(uint lv) { return 2 + 2 * lv; }      // tics before the impact: 4, 6, 8
	static int Stagger(uint lv) { return 17 + 9 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("window", AsSeconds(Window(level)));
		fields.Insert("time", AsSeconds(Stagger(level)));
	}
}

// REFLECT GUARD: a missile that meets the raised Guard goes back at its shooter; at level 3 a bullet does too.
class RSQ_Upgrade_ReflectGuard : RSQ_GuardPerk
{
	override bool Parent(TFLV_PerPlayerStats stats) { return PHas(stats, "Guard", 2); }
	static double Mult(uint lv) { return 1.0 + 0.25 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercent(Mult(level))); }
}

// ABSORB AND RELEASE: what the Guard takes charges it; both hands thrown apart (RSQ Gestures) let it out round you.
class RSQ_Upgrade_AbsorbRelease : RSQ_GuardPerk
{
	override bool Parent(TFLV_PerPlayerStats stats) { return PHas(stats, "ReflectGuard", 2); }
	// the release is "both hands apart": offered only with RSQ Gestures or RSQ Melee's own copy reading it (item 24, 11-04)
	override bool ModLoaded() { return Super.ModLoaded() && RSQ_FistMath.TwoHandReader(); }
	static double ChargeCap(uint lv) { return 100.0 + 50.0 * lv; }
	static double Radius(uint lv) { return 3.0 + lv; }    // metres
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("cap", String.Format("%d", int(ChargeCap(level))));
		fields.Insert("radius", RSQ_FistMath.Metres(Radius(level)));
	}
}

// ---- E. GRAPPLER ---------------------------------------------------------------------------------------------------
// The off hand's Headlock and its throw are RSQ Melee's base moves (headlock.zs). These grow it, offered only to the OFF
// glove (the hand that grapples); Melee reads them from that glove wherever it is.
class RSQ_GrappleUpgrade : RSQ_Upgrade_Base
{
	static bool OffGlove(TFLV_WeaponInfo info)
	{
		if (!GloveInfo(info)) return false;
		String n = info.wpnClass;
		return n ~== "RSQ_GloveOff" || n ~== "SPO_GloveOff";
	}
	// any glove of this player holds that node (Headlock Uppercut needs the other hand's Uppercut)
	static bool AnyGloveHas(TFLV_PerPlayerStats stats, String shortName, int minLevel = 1)
	{
		if (!stats) return false;
		for (int i = 0; i < stats.weapons.Size(); i++)
		{
			let w = stats.weapons[i];
			if (GloveInfo(w) && Has(w, shortName, minLevel)) return true;
		}
		return false;
	}
	static bool Offer(TFLV_WeaponInfo info, String mine, String parent, int parentLv, int cap)
	{
		return OffGlove(info) && (parent == "" || Has(info, parent, parentLv)) && LevelOf(info, mine) < cap;
	}
}

// HUMAN SHIELD (an unlock; RSQ Melee's row of that name is what plays it without Gun Bonsai VR): 1 the hold lasts as
// long as the grip (a minute at most), turned to face away; 2 it takes the blows meant for you from its side; 3 x1.5.
class RSQ_Upgrade_HumanShield : RSQ_GrappleUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "HumanShield", "", 0, 3); }
	static double Mult(uint lv) { return lv >= 3 ? 1.5 : 1.0; }
}

// HEADLOCK UPPERCUT: an uppercut on the monster you hold lets go and launches it higher, harder.
class RSQ_Upgrade_HeadlockUppercut : RSQ_GrappleUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		return Offer(info, "HeadlockUppercut", "HumanShield", 1, 3) && AnyGloveHas(info.stats, "Uppercut");
	}
	static double Lift() { return 1.5; }
	static double Mult(uint lv) { return 1.5 + 0.25 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// HEAVIER HEADLOCK: heavier monsters can be held (Distance Grab's Iron Grip adds 100 a level on top).
class RSQ_Upgrade_HeavierHeadlock : RSQ_GrappleUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "HeavierHeadlock", "HumanShield", 1, 3); }
	static double Mass(uint lv) { return 400.0 + 200.0 * lv; }   // 600 an Arachnotron, 800, 1000 a Baron or a Mancubus
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mass", String.Format("%d", int(Mass(level)))); }
}

// SLAM: the off hand swung down hard while holding drives the monster into the floor; what stands round it staggers.
class RSQ_Upgrade_Slam : RSQ_GrappleUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "Slam", "HeavierHeadlock", 1, 3); }
	static double Mult(uint lv) { return 1.0 + 0.25 * lv; }
	static double Speed() { return 3.0; }
	static double Radius() { return 1.5; }
	static int Stagger() { return 15; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// THROW INTO: a monster thrown out of the Headlock hits harder; Melee's own toss bends onto a monster.
class RSQ_Upgrade_ThrowInto : RSQ_GrappleUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "ThrowInto", "HumanShield", 2, 3); }
	static double Mult(uint lv) { return 1.0 + 0.25 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// CHOKEHOLD: a held monster is hurt every second.
class RSQ_Upgrade_Chokehold : RSQ_GrappleUpgrade
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return Offer(info, "Chokehold", "HumanShield", 2, 3); }
	static int Damage(uint lv) { return 2 + lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("dmg", String.Format("%d", Damage(level))); }
}

// ---- F. BERSERK ----------------------------------------------------------------------------------------------------
// Doom's Berserk pack is the fists' power-up: a punch does x5 while you hold it (RSQ Melee, base). These grow it.
class RSQ_BerserkMath
{
	// holding the Berserk: Doom's PowerStrength, or Berserk Meter's earned one (a subclass)
	static bool On(Actor pawn) { return pawn && pawn.FindInventory("PowerStrength", true) != null; }
}

// RAGE: while the Berserk lasts every other node this glove has counts one level higher (2: and RSQ Melee doubles the
// hit-stop; 3: and its knockback x1.5). The raise is done on the levels themselves, so RSQ Melee's moves and this
// patch's own nodes all see it, and taken back the moment the Berserk ends or the glove leaves the hand; Has / LevelOf
// look through it, so it never offers a child early.
class RSQ_Upgrade_Rage : RSQ_Upgrade_Base
{
	bool raisedNow;
	Array<String> raised;   // the classes this Rage raised
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && LevelOf(info, "Rage") < 3; }
	bool Raises(TFLV_Upgrade_BaseUpgrade u) { return raisedNow && u && u != self && raised.Find(u.GetClassName()) < raised.Size(); }

	private TFLV_WeaponInfo MyInfo(Actor owner)
	{
		let st = TFLV_PerPlayerStats.GetStatsFor(owner);
		if (!st) return null;
		for (int h = 0; h < 2; h++)
		{
			let info = st.GetInfoForHand(h);
			if (info && info.upgrades && info.upgrades.upgrades.Find(self) < info.upgrades.upgrades.Size()) return info;
		}
		return null;
	}
	void Raise(TFLV_WeaponInfo info)
	{
		if (raisedNow || !info) return;
		raised.Clear();
		for (int i = 0; i < info.upgrades.upgrades.Size(); ++i)
		{
			let u = RSQ_Upgrade_Base(info.upgrades.upgrades[i]);
			if (!u || u == self || !u.enabled) continue;
			u.level++;
			u.rageUp = 1;
			raised.Push(u.GetClassName());
		}
		raisedNow = true;
	}
	void Lower(TFLV_WeaponInfo info)
	{
		if (!raisedNow) return;
		raisedNow = false;
		if (info)
			for (int i = 0; i < info.upgrades.upgrades.Size(); ++i)
			{
				let u = info.upgrades.upgrades[i];
				if (u && u != self && raised.Find(u.GetClassName()) < raised.Size() && u.level > 1) u.level--;
				let b = RSQ_Upgrade_Base(u);
				if (b && b != self) b.rageUp = 0;
			}
		raised.Clear();
	}
	override void Tick(Actor owner)
	{
		bool zerk = RSQ_BerserkMath.On(owner);
		if (zerk == raisedNow) return;
		let info = MyInfo(owner);
		if (!info) return;
		if (zerk) Raise(info); else Lower(info);
	}
	override void OnDeactivate(TFLV_PerPlayerStats stats, TFLV_WeaponInfo info) { Lower(info); }
	override void GetTooltipFields(Dictionary fields, uint level) {}
}

// BLOOD RUSH (the owner reworked it 11-02: armour, not health -- Kill Rewards already drops health): a fist kill while
// you hold the Berserk gives armour.
class RSQ_Upgrade_BloodRush : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Rage") && LevelOf(info, "BloodRush") < 3; }
	static int Armour(uint lv) { return 5 + 5 * lv; }
	override void OnKill(PlayerPawn pawn, Actor shot, Actor target)
	{
		if (!pawn || !IsGlove(shot) || !RSQ_BerserkMath.On(pawn)) return;
		let ab = BasicArmorBonus(Actor.Spawn("RSQ_BloodRushArmor", pawn.pos, NO_REPLACE));
		if (!ab) return;
		ab.SaveAmount = Armour(level);
		if (!ab.CallTryPickup(pawn)) ab.Destroy();
		pawn.A_SetBlend("FF2020", 0.25, 10);
		RSQM.Touch("bloodrush", pawn, target);
		if (target) RSQM.Burst("RSQML_BurstH", target.pos + (0, 0, target.height * 0.5), 1.0, RSQM.ByLevel(level, 3));
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", Armour(level))); }
}
class RSQ_BloodRushArmor : BasicArmorBonus
{
	Default { Armor.SavePercent 33.335; Armor.MaxSaveAmount 200; +INVENTORY.ALWAYSPICKUP +INVENTORY.QUIET; Inventory.PickupMessage ""; }
}

// BERSERK METER: fist damage fills a meter; full, it gives a Berserk for a while without a pack.
class RSQ_Upgrade_BerserkMeter : RSQ_Upgrade_Base
{
	const FULL = 300;
	int meter;
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Rage", 2) && LevelOf(info, "BerserkMeter") < 3; }
	static int Tics(uint lv) { return 35 * (20 + 5 * lv); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !pawn || damage <= 0 || RSQ_BerserkMath.On(pawn)) return;
		meter += damage;
		if (meter < FULL) return;
		meter = 0;
		pawn.GiveInventory("RSQ_EarnedStrength", 1);
		let p = RSQ_EarnedStrength(pawn.FindInventory("RSQ_EarnedStrength"));
		if (p) { p.left = Tics(level); p.total = p.left; }
		pawn.A_StartSound("misc/p_pkup", CHAN_AUTO, CHANF_OVERLAP, 1.0);
		pawn.A_SetBlend("FF2020", 0.35, 18);
		RSQM.Touch("berserk.earned", pawn, target);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("full", String.Format("%d", FULL));
		fields.Insert("time", AsSeconds(Tics(level)));
	}
}
// A Berserk earned by the meter: Doom's PowerStrength (so a punch, the shove and anything that asks for the Berserk sees
// it), but it runs out.
class RSQ_EarnedStrength : PowerStrength
{
	int left, total;   // tics left, and what it started with (the gauge drains by them: rsq/ui/gauges.zs)
	override void Tick()
	{
		Super.Tick();
		if (--left <= 0) Destroy();
	}
}

// ---- G. GUN HAND ---------------------------------------------------------------------------------------------------
// The gun-butt shove is RSQ Melee's (with BD22 VR Reloaded loaded, its own strike). These are glove nodes (the Fists
// tree); the shove reads the best of either glove.
class RSQ_Upgrade_PistolWhip : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && LevelOf(info, "PistolWhip") < 3; }
	static int Stagger(uint lv) { return 10 * lv; }
	static double Mult(uint lv) { return 1.25 + 0.25 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", AsSeconds(Stagger(level)));
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
	}
}
class RSQ_Upgrade_RifleButt : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "PistolWhip", 2) && LevelOf(info, "RifleButt") < 3; }
	static int Count(uint lv) { return 2 + lv; }
	static double Speed() { return 4.0; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("count", String.Format("%d", Count(level))); }
}

// ---- H. TAUNT (a player node; RSQ Melee does it on RSQ Gestures' "both hands apart") --------------------------------
class RSQ_Upgrade_Taunt : RSQ_Perk
{
	override int Cap() { return 3; }
	override bool ModLoaded() { return RSQM.Svc("RSQML_Service") != null && RSQ_FistMath.TwoHandReader(); }   // "both hands apart", Gestures' or Melee's copy
	static int Tics(uint lv) { return 35 * (2 + lv); }
	static double Range() { return 10.0; }   // metres
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(Tics(level))); }
}

// ---- I. CRITICAL HITS (player nodes; the owner's example, Mikk's Critical Shots, as a concept only) ------------------
class RSQ_CritPerk : RSQ_Perk
{
	override int Cap() { return 3; }
	// a melee blow: Melee's damage types, or an inflictor that is a weapon Gun Bonsai calls melee
	static bool MeleeHit(Actor pawn, Actor shot, Name attacktype)
	{
		if (attacktype == 'Melee' || attacktype == 'Kick') return true;
		let w = Weapon(shot);
		if (!w) return false;
		let st = TFLV_PerPlayerStats.GetStatsFor(pawn);
		let info = st ? st.GetInfoFor(w) : null;
		return info && info.IsMelee();
	}
	static void Sparkle(Actor at, Vector3 pos, Color c, int n)
	{
		for (int i = 0; i < n; i++)
			at.A_SpawnParticle(c, SPF_FULLBRIGHT, 16, 6, 0, pos.x - at.pos.x, pos.y - at.pos.y, pos.z - at.pos.z,
				frandom[RSQFx](-3, 3), frandom[RSQFx](-3, 3), frandom[RSQFx](-1, 3), 0, 0, -0.1, 1.0, -0.06);
	}
}

// CRITICAL HITS: a hit landed during a monster's attack wind-up is a critical: harder, and it is stunned a second;
// hits on a stunned monster land harder too; at most 3 criticals in 15 tics. Level 1 melee only; level 2 adds guns.
// With Counterpunch on the punching glove the two stack once: the stun, and Counterpunch's own bigger multiplier. A
// Three-Hit's third hit always counts as a critical.
class RSQ_Upgrade_CriticalHits : RSQ_CritPerk
{
	const STUN = 35;
	const BURST_MAX = 3;
	const BURST_TICS = 15;
	Array<int> critTics;
	int lastCritTic;
	Actor lastCrit;
	static double Mult(uint lv) { return 1.5 + 0.25 * lv; }
	static double Stunned(uint lv) { return 1.25 + 0.25 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!Monster(target)) return damage;
		bool melee = MeleeHit(pawn, shot, attacktype);
		if (!melee && level < 2) return damage;
		int now = RSQM.Now();
		// the stun is kept on the monster's RSQ_Dazed, made only by a critical (11-10: it was given to every monster this
		// touched, and nothing on a monster that never took a critical reads it); a monster without one is not stunned
		let dz = RSQ_Dazed(target.FindInventory("RSQ_Dazed"));
		bool combo = IsGlove(shot) && Punch(shot, "punch.kinds") == RSQ_Upgrade_ThreeHit.PATTERN && Glove3Hit(pawn, shot);
		if ((RSQM.InAttack(target) || combo) && Room(now))
		{
			critTics.Push(now);
			lastCritTic = now;
			lastCrit = target;
			if (!dz) dz = RSQ_Dazed.On(target);
			if (dz) dz.critUntil = now + STUN;
			Vector3 at = shot && shot != pawn && !IsGlove(shot) ? shot.pos : target.pos + (0, 0, target.height * 0.6);
			String sparkName = "RSQML_SparkSuper";   // through a String: a literal is checked at compile time (an error without RSQ Melee)
			Class<Actor> spark = sparkName;          // RSQ Melee's Super Spark, by name (none without it)
			if (spark) Actor.Spawn(spark, at, NO_REPLACE);
			target.A_StartSound("rsqml/fx/heavy", CHAN_AUTO, CHANF_OVERLAP, 1.0);
			RSQM.Burst("RSQML_Burst2", at, 1.5, 0);
			RSQM.Touch("crit", pawn, target);
			// Counterpunch on this glove: its stagger and multiplier stand, this one is not added on top
			if (IsGlove(shot) && Punch(shot, "punch.counter") == 1 && GloveHas(pawn, shot, "Counterpunch")) return damage;
			return damage * Mult(level);
		}
		if (dz && dz.critUntil > now) return damage * Stunned(level);
		return damage;
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (target && target == lastCrit && lastCritTic == RSQM.Now() && target.health > 0) RSQ_Dazed.On(target).Stagger(STUN);
	}
	bool Room(int now)
	{
		for (int i = critTics.Size() - 1; i >= 0; i--) if (now - critTics[i] >= BURST_TICS) critTics.Delete(i);
		return critTics.Size() < BURST_MAX;
	}
	static bool GloveHas(Actor pawn, Actor shot, String shortName)
	{
		let st = TFLV_PerPlayerStats.GetStatsFor(pawn);
		let w = Weapon(shot);
		return st && w && Has(st.GetInfoFor(w), shortName);
	}
	static bool Glove3Hit(Actor pawn, Actor shot) { return GloveHas(pawn, shot, "ThreeHit"); }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("stun", AsPercentIncrease(Stunned(level)));
	}
}

// HEADSHOT: a hit in the top fifth of a monster (a punch: where the glove met it; a gun: where the shot landed). The
// pellets of one blast after the first count half.
class RSQ_Upgrade_Headshot : RSQ_CritPerk
{
	const TOP = 0.8;
	int lastTic;
	Actor lastOn;
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats) { return Super.IsSuitableForPlayer(stats) && PHas(stats, "CriticalHits"); }
	static double Mult(uint lv) { return 2.0 + 0.5 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!Monster(target) || target.height <= 0) return damage;
		double frac = -1;
		if (IsGlove(shot)) { int hh = Punch(shot, "punch.height"); if (hh >= 0) frac = hh / 1000.0; }
		else if (shot && shot != pawn) frac = (shot.pos.z - target.pos.z) / target.height;
		// HEADSHOT REACTION 2 (RSQ LaserSight's node): a gun hit with the laser's dot on its head counts (the laser answers
		// only at that level). REMA port: the laser's dot is local state. A gun hit is any hit that is not a punch or a
		// melee blow. A hitscan's inflictor is normally its puff (GZDoom's P_LineAttack; the frac line above already reads
		// a gun hit's height off the shot's pos for that reason) and a converted bullet is a projectile, so the old test
		// "shot == pawn" let almost no gun hit through (11-10).
		if (frac < TOP && !IsGlove(shot) && !MeleeHit(pawn, shot, attacktype)) { let ls = RSQM.Svc("RSQLS_SightService"); if (ls && ls.GetInt("head.on", "", 0, 0, target) == 1) frac = 1.0; }
		if (frac < TOP) return damage;
		int now = RSQM.Now();
		double m = Mult(level);
		if (lastOn == target && lastTic == now) m = 1.0 + (m - 1.0) * 0.5;
		else
		{
			RSQM.Burst("RSQML_BurstH", target.pos + (0, 0, target.height * 0.9), 0.75, RSQM.ByLevel(level, 3));
			target.A_StartSound("rsqml/fx/heavy", CHAN_AUTO, CHANF_OVERLAP, 0.7);
			RSQM.Touch("headshot", pawn, target);
		}
		lastOn = target; lastTic = now;
		return damage * m;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", String.Format("x%.1f", Mult(level))); }
}

// BACKSTAB: a melee hit from behind (within 60 degrees of its back); a kill this way is silent.
class RSQ_Upgrade_Backstab : RSQ_CritPerk
{
	const BACK = 120.0;   // degrees from where it faces to you
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats) { return Super.IsSuitableForPlayer(stats) && PHas(stats, "CriticalHits"); }
	static double Mult(uint lv) { return 3.0 + lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!Monster(target) || !pawn || !MeleeHit(pawn, shot, attacktype)) return damage;
		if (Actor.absangle(target.angle, target.AngleTo(pawn)) < BACK) return damage;
		double d = damage * Mult(level);
		if (d >= target.health) target.DeathSound = "";
		RSQM.Burst("RSQML_Burst4", target.pos + (0, 0, target.height * 0.6), 1.0, RSQM.ByLevel(level, 3));
		RSQM.Touch("backstab", pawn, target);
		return d;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", String.Format("x%d", int(Mult(level)))); }
}
