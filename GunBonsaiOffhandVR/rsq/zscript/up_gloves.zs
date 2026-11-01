// THE GLOVES' UPGRADE PATH. Every one reads the punch the reader wrote onto the glove
// (RSQ_Glove.last*), because in ModifyDamageDealt the glove itself is the inflictor.

class RSQ_Upgrade_Base : TFLV_Upgrade_BaseUpgrade
{
	// These effects key off their own inflictors, so Gun Bonsai's priority chain (which keeps a
	// poison DoT from proccing an explosion) has nothing to protect here.
	override bool CheckPriority(Actor inflictor) { return true; }
	static bool GloveInfo(TFLV_WeaponInfo info) { return info && RSQM.IsGloveName(info.wpnClass); }
	static bool SaberInfo(TFLV_WeaponInfo info) { return info && RSQM.IsSaberName(info.wpnClass); }
	static bool ShieldInfo(TFLV_WeaponInfo info) { return info && RSQM.IsShieldName(info.wpnClass); }
	static bool Monster(Actor t) { return t && t.bIsMonster && t.health > 0; }
}

// HAYMAKER: the harder you throw it, the more each level adds.
class RSQ_Upgrade_Haymaker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv, double power) { return 1.0 + lv * (0.15 + 0.35 * power); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let g = RSQ_Glove(shot);
		if (!g) return damage;
		return damage * Mult(level, g.lastPower);
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
		let g = RSQ_Glove(shot);
		if (!g) return damage;
		return damage * Mult(level, g.lastChain);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.15 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 5)));
	}
}

// STAR PUNCH: clean hits bank stars (SuperPunchOut's rule); an uppercut with the trigger held
// spends one and launches what it hits.
class RSQ_Upgrade_StarPunch : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Mult(uint lv) { return 1.5 + 0.5 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastStar) return damage;
		return damage * Mult(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastStar || !target || target.health <= 0 || target.bDontThrust) return;
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
		let g = RSQ_Glove(shot);
		if (!g || !g.lastCounter) return damage;
		return damage * Mult(level);
	}
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastCounter || !Monster(target)) return;
		RSQ_Dazed.On(target).Stagger(Tics(level));
		target.A_StartSound("rsq/counter", CHAN_AUTO, 0, 1.0);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(Tics(level)));
	}
}

// BODY BLOW: a hit below the chest winds it -- every move it makes is slower for a while.
class RSQ_Upgrade_BodyBlow : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static int Tics(uint lv) { return 35 + 18 * lv; }
	static double Factor(uint lv) { return min(0.4 + 0.15 * lv, 1.0); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		let g = RSQ_Glove(shot);
		if (!g || !g.lastBody || !Monster(target)) return;
		RSQ_Dazed.On(target).Wind(Tics(level), Factor(level));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("time", AsSeconds(Tics(level)));
		fields.Insert("slow", AsPercent(Factor(level) * 0.5));
	}
}

// KNOCKDOWN: enough punishment inside two seconds puts it on the floor for a count.
class RSQ_Upgrade_Knockdown : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info); }
	static double Share(uint lv) { return max(0.5 - 0.06 * lv, 0.15); }
	static int Count(uint lv) { return min(2 + lv, 8); }
	override void OnDamageDealt(Actor pawn, Actor shot, Actor target, int damage)
	{
		if (!RSQ_Glove(shot) || !Monster(target) || target.bBoss) return;
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
// The gloves' reader (gloves.zs) does each one where the punch is read, and asks these for the numbers.

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
// upgrade by its class name, so a save that has it keeps it. The name players see is language.rsq's.
class RSQ_Upgrade_ReturnFire : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && info.upgrades.Level(GetClassName()) < 4; }
	static double Mult(uint lv) { return 1.25 + 0.25 * lv; }
	static double Speed(uint lv) { return 1.0 + 0.15 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let gh = RSQ_GloveHandler.Get();
		int lv = gh ? gh.ReturnedLevel(shot) : 0;
		return lv > 0 ? damage * Mult(lv) : damage;
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("speed", AsPercentIncrease(Speed(level)));
	}
}

// WALL SPLAT: a monster your punch knocks into a wall slams into it.
class RSQ_Upgrade_WallSplat : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GloveInfo(info) && info.upgrades.Level(GetClassName()) < 5; }
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

// WHAT A PUNCHED MONSTER CARRIES WHILE IT FLIES (Wall Splat). Armed by the punch; looks at the monster's own
// movement once a tic. MovementBlockingLine is the engine's "a wall refused this tic's velocity move" (it is cleared
// before every XY move and set only when the move is refused: p_mobj.cpp AActor::Tick, P_XYMovement), and a monster
// that is blocked has its velocity zeroed there -- so the speed it hit with is the one remembered from the tic before.
// Walking (A_Chase's own steps) never sets it. The frozen tics of a hit-stop do not count: a frozen monster's Tick
// stops before its inventory's DoEffect.
class RSQ_Splat : Inventory
{
	PlayerPawn by;
	Weapon glove;
	int lv, left;
	Vector2 lastVel;

	const WINDOW = 12;          // tics of flight a punch arms it for
	const MIN_SPEED = 3.0;      // map units a tic into the wall (the teardown's BOUNCE_MIN_SPEED)
	const RESTITUTION = 0.45;   // the teardown's BOUNCE_RESTITUTION

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	static void Arm(Actor mo, PlayerPawn pawn, Weapon glove, int lv)
	{
		if (!mo || mo.health <= 0 || mo.bDontThrust || mo.player) return;
		let s = RSQ_Splat(mo.FindInventory("RSQ_Splat"));
		if (!s) s = RSQ_Splat(mo.GiveInventoryType("RSQ_Splat"));
		if (!s) return;
		s.by = pawn; s.glove = glove; s.lv = lv;
		s.left = WINDOW;
		s.lastVel = mo.vel.xy;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		let mo = owner;
		if (!mo || mo.health <= 0 || left <= 0) { Destroy(); return; }
		left--;
		double sp = lastVel.Length();
		if (mo.MovementBlockingLine && sp >= MIN_SPEED)
		{
			Slam(mo, sp);
			Destroy();
			return;
		}
		lastVel = mo.vel.xy;
	}

	private void Slam(Actor mo, double sp)
	{
		int dmg = RSQ_Upgrade_WallSplat.Damage(lv, sp);
		bool dbg = RSQM.SVI("rsq_punch_debug", 0) != 0;
		if (dbg) Console.Printf("RSQ wall splat: %s at %.1f u/tic -> %d", mo.GetClassName(), sp, dmg);
		// THE SLAM IS THE GLOVE'S, but not a punch: paid to the glove through a helper it claims (the way the
		// ShieldSaw's returned bullet is paid), so Gun Bonsai credits that glove while the glove upgrades -- which
		// read the last punch off the glove itself (RSQ_Glove(shot)) -- do not count the slam as that punch again.
		Actor inf = by;
		if (glove && glove.owner)
		{
			let hit = Actor.Spawn("RSQ_SplatHit", mo.pos, NO_REPLACE);
			if (hit)
			{
				hit.master = glove;
				hit.target = by;
				TFLV_VR_Attribution.Claim(hit, glove, TFLV_VR_Attribution.HINT_MELEE);
				inf = hit;
			}
		}
		mo.SpawnBlood(mo.pos + (0, 0, mo.height * 0.5), VectorAngle(-lastVel.x, -lastVel.y), dmg);
		mo.A_StartSound("rsq/smash", CHAN_AUTO, 0, 1.0);
		mo.DamageMobj(inf, by, dmg, 'Melee', DMG_THRUSTLESS);
		if (!mo || mo.health <= 0) return;
		mo.vel.xy = -lastVel * RESTITUTION;
		mo.freezetics = max(mo.freezetics, 5);   // the teardown's slam hit-stop
		RSQ_Dazed.On(mo).Stagger(RSQ_Upgrade_WallSplat.Reel(lv));
		if (by) { RSQ_Buzz.Start(by, 0, 0.5, 6); RSQ_Buzz.Start(by, 1, 0.5, 6); }
	}
}

// The slam's inflictor: nothing but a name Gun Bonsai can pay to the glove.
class RSQ_SplatHit : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }
	States { Spawn: TNT1 A 2; Stop; }
}
