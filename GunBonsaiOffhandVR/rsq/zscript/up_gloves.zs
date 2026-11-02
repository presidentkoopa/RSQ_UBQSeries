// THE GLOVES' UPGRADE PATH. The gloves, the punch and the moves are RSQ Melee's since 2026-11-01 (RSQ_Melee.pk3); the
// upgrades stay here, with the SAME class names (Gun Bonsai keeps a learned upgrade by its class name, so a save keeps
// it). Every one reads the punch Melee wrote onto the glove through RSQML_Service ("punch.*", asked by name: RSQM.Punch /
// PunchPower), because in ModifyDamageDealt the glove itself is the inflictor. Without RSQ Melee there are no gloves,
// so none of these is ever offered.

class RSQ_Upgrade_Base : TFLV_Upgrade_BaseUpgrade
{
	// These effects key off their own inflictors, so Gun Bonsai's priority chain (which keeps a
	// poison DoT from proccing an explosion) has nothing to protect here.
	override bool CheckPriority(Actor inflictor) { return true; }
	static bool GloveInfo(TFLV_WeaponInfo info) { return info && RSQM.IsGloveName(info.wpnClass); }
	static bool SaberInfo(TFLV_WeaponInfo info) { return info && RSQM.IsSaberName(info.wpnClass); }
	static bool ShieldInfo(TFLV_WeaponInfo info) { return info && RSQM.IsShieldName(info.wpnClass); }
	static bool Monster(Actor t) { return t && t.bIsMonster && t.health > 0; }
	// THE LAST PUNCH, from RSQ Melee (RSQML_Service): -1 when the inflictor is not one of its gloves
	static int Punch(Actor shot, String what) { let s = RSQM.Svc("RSQML_Service"); return (s && shot) ? s.GetInt(what, "", 0, 0, shot) : -1; }
	static double PunchPower(Actor shot) { let s = RSQM.Svc("RSQML_Service"); return (s && shot) ? s.GetDouble("punch.power", "", 0, 0, shot) : -1; }
	static bool IsGlove(Actor shot) { return Punch(shot, "punch.glove") == 1; }

	// ---- PREREQUISITES (GBOVR_TREES.md section 6, item 2): how a tree node asks for its parent ---------------
	// Has(info, "Haymaker", 2): this weapon's record holds RSQ_Upgrade_Haymaker at level 2 or more (and switched on).
	// PHas(stats, "Guard"): the player's bag holds RSQ_Upgrade_Guard at level 1 or more. Both read the bag directly,
	// as RSQM.LevelOn / PLevel do, so a node's IsSuitableFor* costs one pass over a short array.
	static bool Has(TFLV_WeaponInfo info, String shortName, int minLevel = 1)
	{
		if (!info || !info.upgrades) return false;
		String cls = RSQM.UpClass(shortName);
		for (int i = 0; i < info.upgrades.upgrades.Size(); ++i)
		{
			let u = info.upgrades.upgrades[i];
			if (u && u.enabled && u.GetClassName() == cls) return int(u.level) >= minLevel;
		}
		return false;
	}
	static bool PHas(TFLV_PerPlayerStats stats, String shortName, int minLevel = 1)
	{
		if (!stats || !stats.upgrades) return false;
		String cls = RSQM.UpClass(shortName);
		for (int i = 0; i < stats.upgrades.upgrades.Size(); ++i)
		{
			let u = stats.upgrades.upgrades[i];
			if (u && u.enabled && u.GetClassName() == cls) return int(u.level) >= minLevel;
		}
		return false;
	}
	// the level this weapon's record holds of a node (0 = none), for a cap test: LevelOf(info, "HeavyHands") < 4.
	// Not "Level": ZScript identifiers are case-insensitive, and every upgrade has a `level` field (the headless run
	// of 11-02 found 20 "Numeric type expected" errors from that one name).
	static int LevelOf(TFLV_WeaponInfo info, String shortName)
	{
		if (!info || !info.upgrades) return 0;
		return int(info.upgrades.Level(RSQM.UpClass(shortName)));
	}
}

// HAYMAKER: the harder you throw it, the more each level adds. (Tree, 11-02: after Heavy Hands 1; 5 levels.)
class RSQ_Upgrade_Haymaker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands") && LevelOf(info, "Haymaker") < 5; }
	static double Mult(uint lv, double power) { return 1.0 + lv * (0.15 + 0.35 * power); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		double pw = PunchPower(shot);
		if (pw < 0) return damage;
		return damage * Mult(level, pw);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("soft", AsPercentIncrease(Mult(level, 0.0)));
		fields.Insert("hard", AsPercentIncrease(Mult(level, 1.0)));
	}
}

// ONE-TWO: left, right, left -- each alternating hit inside half a second adds to the next.
class RSQ_Upgrade_OneTwo : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv, int chain) { return 1.0 + 0.15 * lv * clamp(chain - 1, 0, 4); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		int chain = Punch(shot, "punch.chain");
		if (chain < 0) return damage;
		return damage * Mult(level, chain);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.15 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 5)));
	}
}

// STAR PUNCH: clean hits bank stars (SuperPunchOut's rule); an uppercut with the trigger held
// spends one and launches what it hits.
// NO LONGER OFFERED (GBOVR_TREES.md 2.1 #5 and 4.1 A, owner 11-02): folded into Uppercut and Launcher (up_fists.zs); the
// star bank read as a second resource. The class stays so a save that learned it keeps it, and it still works there.
class RSQ_Upgrade_StarPunch : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return false; }
	static double Mult(uint lv) { return 1.5 + 0.5 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (Punch(shot, "punch.star") != 1) return damage;
		return damage * Mult(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (Punch(shot, "punch.star") != 1 || !target || target.health <= 0 || target.bDontThrust) return;
		double mk = clamp(100.0 / max(target.mass, 1.0), 0.08, 2.0);
		target.vel.z += (8.0 + 2.0 * level) * mk;
		RSQ_Dazed.On(target).Stagger(35);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", string.format("x%.1f", Mult(level)));
	}
}

// COUNTERPUNCH: hit it while it winds up an attack -- it reels, and the punch lands harder.
class RSQ_Upgrade_Counterpunch : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv) { return 1.25 + 0.25 * lv; }
	static int Tics(uint lv) { return 17 + 9 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (Punch(shot, "punch.counter") != 1) return damage;
		return damage * Mult(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (Punch(shot, "punch.counter") != 1 || !Monster(target)) return;
		RSQ_Dazed.On(target).Stagger(Tics(level));
		target.A_StartSound("rsq/counter", CHAN_AUTO, 0, 1.0);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(Tics(level)));
	}
}

// BODY BLOW: a hit below the chest winds it -- every move it makes is slower for a while. (After Heavy Hands 2; 4 levels.)
class RSQ_Upgrade_BodyBlow : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "HeavyHands", 2) && LevelOf(info, "BodyBlow") < 4; }
	static int Tics(uint lv) { return 35 + 18 * lv; }
	static double Factor(uint lv) { return min(0.4 + 0.15 * lv, 1.0); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (Punch(shot, "punch.body") != 1 || !Monster(target)) return;
		RSQ_Dazed.On(target).Wind(Tics(level), Factor(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", AsSeconds(Tics(level)));
		fields.Insert("slow", AsPercent(Factor(level) * 0.5));
	}
}

// KNOCKDOWN: enough punishment inside two seconds puts it on the floor for a count. (After Wallflower 2 or Body Blow 3;
// 5 levels.)
class RSQ_Upgrade_Knockdown : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		return GloveInfo(info) && (Has(info, "WallSplat", 2) || Has(info, "BodyBlow", 3)) && LevelOf(info, "Knockdown") < 5;
	}
	static double Share(uint lv) { return max(0.5 - 0.06 * lv, 0.15); }
	static int Count(uint lv) { return min(2 + lv, 8); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!IsGlove(shot) || !Monster(target) || target.bBoss) return;
		let dz = RSQ_Dazed.On(target);
		if (dz.IsDown()) return;
		dz.NoteHit(damage);
		if (dz.RecentDamage(70) >= RSQM.StartHealth(target) * Share(level)) dz.KnockDown(Count(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("share", AsPercent(Share(level)));
		fields.Insert("count", string.format("%d", Count(level)));
	}
}

// ---- THE OWNER'S PICKS 52-54 (2026-10-31, all "Yes"): Heavy Hands, Hadouken (was Return Fire), Wall Splat ------------
// The picks page has only the names. What each is, as built, from the Quest teardown (rsq_questenginesurvey):
//   HEAVY HANDS  surveys/01_MELEE.md 3.6 and 4.5: a landed blow stops the victim for a beat (freezetics:
//                "3 is a tap, 6 is a heavy, 10 reads as a bug") and knocks it back along the swing.
//   HADOUKEN     (named Return Fire until 2026-11-01) the literal reading: a punch that meets an enemy's missile sends it back at whoever fired it
//                (surveys/01_MELEE.md 4.11, deflecting with a moving blade, done with a moving glove).
//   WALL SPLAT   surveys/01_MELEE.md 4.7, "wall bounce": a monster punched into a wall slams into it, hurts,
//                bounces off and reels.
// THE MOVES ARE RSQ MELEE'S since 2026-11-01 (the punch reader does each one where the punch is read); these classes are
// the upgrades: Gun Bonsai offering them, their levels, their numbers. Melee asks the level (RSQ_MeleeUpgradeService
// "level") and the numbers ("upgrade.num", core.zs) by name. Without Gun Bonsai VR, Melee's own menu rows play each at
// level 1.

// HEAVY HANDS: a landed punch freezes what it hit for a beat (hit-stop), and knocks it further.
class RSQ_Upgrade_HeavyHands : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && info.upgrades.Level(GetClassName()) < 4; }
	// tics of hit-stop: 2 at level 1 up to 4 at level 3+, +2 for a punch thrown at half speed or more (6 at most,
	// the teardown's "heavy"; 10 reads as a bug)
	static int Freeze(uint lv, double power) { return min(1 + min(lv, 3), 4) + (power >= 0.5 ? 2 : 0); }
	// the glove's own knockback, +25% a level
	static double Knock(uint lv) { return 1.0 + 0.25 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("soft", AsSeconds(Freeze(level, 0.0)));
		fields.Insert("hard", AsSeconds(Freeze(level, 1.0)));
		fields.Insert("knock", AsPercentIncrease(Knock(level)));
	}
}

// HADOUKEN (the owner renamed it from Return Fire, 2026-11-01): punch an enemy's missile and it flies back at
// whoever fired it -- yours now, and harder. The CLASS keeps its old name on purpose: Gun Bonsai keeps a learned
// upgrade by its class name, so a save that has it keeps it. The name players see is language.rsq's. The returned
// missile's harder hit is applied by RSQ Melee (its RSQML_Body), at Mult.
class RSQ_Upgrade_ReturnFire : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && info.upgrades.Level(GetClassName()) < 4; }
	static double Mult(uint lv) { return 1.25 + 0.25 * lv; }
	static double Speed(uint lv) { return 1.0 + 0.15 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("speed", AsPercentIncrease(Speed(level)));
	}
}

// WALL SPLAT, shown as WALLFLOWER (the owner renamed it 11-02; the class keeps its name for saves): a monster your punch
// knocks into a wall slams into it. (After Haymaker 2; 5 levels.)
class RSQ_Upgrade_WallSplat : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && Has(info, "Haymaker", 2) && info.upgrades.Level(GetClassName()) < 5; }
	// the slam: 5 + 5 a level at the slowest slam that counts (3 map units a tic), up to twice that at 6 or more
	static int Damage(uint lv, double speed) { return int((5 + 5 * lv) * clamp(speed / 3.0, 1.0, 2.0)); }
	static int Reel(uint lv) { return 10 + 5 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("dmg", string.format("%d", Damage(level, 3.0)));
		fields.Insert("max", string.format("%d", Damage(level, 6.0)));
		fields.Insert("time", AsSeconds(Reel(level)));
	}
}

// (RSQ_Splat and RSQ_SplatHit, the slam itself, moved to RSQ Melee's splat.zs with their names on 2026-11-01.)
