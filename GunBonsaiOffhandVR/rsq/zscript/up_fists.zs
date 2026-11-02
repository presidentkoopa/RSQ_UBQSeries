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
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Launcher", 3) && LevelOf(info, "GroundPound") < 3; }
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
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands", 2) && LevelOf(info, "ClearOut") < 3; }
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
		if (target) { target.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 0.8); Burst(target, at, "FFF0D0", 14 + 4 * level, 3.0, 8); }
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
		Burst(target, target.pos + (0, 0, target.height * 0.5), "A0E0FF", 24, 4.0, 5);
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
		}
		if (target) target.A_StartSound("weapons/plasmax", CHAN_AUTO, CHANF_OVERLAP, 0.7);
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
		Burst(target, target.pos + (0, 0, target.height * 0.5), "FF7020", 16, 3.0, 7);
		return damage * FLARE;
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !Monster(target)) return;
		RSQ_Dazed.On(target).Ignite(PlayerPawn(pawn), Weapon(shot), Tics(level), TICK_DMG);
		RSQM.Touch("burn", pawn, target);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("dmg", String.Format("%d", TICK_DMG));
		fields.Insert("time", AsSeconds(Tics(level)));
		fields.Insert("mult", AsPercentIncrease(FLARE));
	}
}
