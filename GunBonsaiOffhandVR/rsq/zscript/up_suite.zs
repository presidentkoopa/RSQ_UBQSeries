// THE REST OF THE RSQ SUITE'S UPGRADE PATHS (Gun Bonsai VR patch, rsq/).
//
// Gun Bonsai is Rebecca "ToxicFrog" Kelly's (MIT); these paths are presidentkoopa's (same terms).
//
// Two kinds. WEAPON paths (the ShieldSaw's plate and locks, the saber's turned bolts) sit on that
// weapon's record and are offered when that weapon levels. PLAYER paths sit in Gun Bonsai's player
// bag -- offered when the PLAYER levels -- because what they reward is no one weapon's: a Distance
// Grab throw, a holster draw, slow motion, the two hands together, the body. Each player path is
// offered only while its mod is loaded (asked by one of its class names, never a literal), and each
// caps its own level. No elemental damage, nothing that is rate of fire, no new resource: every
// upgrade here grows a number the suite already has, or rewards something the player already does.

// A player perk: offered only while its mod is loaded, up to its cap.
class RSQ_Perk : RSQ_Upgrade_Base
{
	virtual int Cap() { return 4; }
	virtual bool ModLoaded() { return true; }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		return stats && stats.upgrades && ModLoaded() && int(stats.upgrades.Level(GetClassName())) < Cap();
	}
	static int PN(Actor pawn) { return (pawn && pawn.player) ? pawn.PlayerNumber() : -1; }
}

// ---- WEAPON: THE SHIELDSAW -------------------------------------------------------------------

// BROADENING: the blocking plate grows from its default, +20% a level, to double at level 5. The
// ShieldSaw asks for it by name (SSQ_Guard.GrowFor); with this patch loaded it replaces the
// ShieldSaw's own Double Block Radius option, which still works without the patch.
class RSQ_Upgrade_Broadening : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && info.upgrades.Level(GetClassName()) < 5; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsPercentIncrease(1.0 + 0.2 * min(level, 5))); }
}

// LOCKSTEP (GBOVR_TREES.md 4.3 Throw, root): under this patch a throw starts at 1 lock; each level adds one, to the
// ShieldSaw's Locks row (5) at level 4 (SSQ_Disc.WantLocks).
class RSQ_Upgrade_Lockstep : RSQ_Upgrade_ShieldMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return ShieldInfo(info) && info.upgrades.Level(GetClassName()) < 4; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", 1 + min(level, 4))); }
}

// ---- WEAPON: THE SABER -----------------------------------------------------------------------

// DEFLECTOR: a bolt the saber sent back (its master is the saber: UBQS sets it on a deflect and on
// its return bolt) hits harder, +15% a level.
class RSQ_Upgrade_Deflector : RSQ_Upgrade_SaberMarker
{
	static double Mult(uint lv) { return 1.0 + 0.15 * lv; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && info.upgrades.Level(GetClassName()) < 5; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!shot || !shot.bMissile || !shot.master || !RSQM.IsSaberName(shot.master.GetClassName())) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// ---- PLAYER: RSQ DISTANCE GRAB ---------------------------------------------------------------
// A throw is no gun's: its XP goes to the player pool (PerPlayerStats.poolXP) and these are its
// upgrades. Long Arm, Iron Grip, Heavy Hitter's heave and Air Catch's radius are read by the grab
// itself (RSQDG_Perks, "plevel" by name); the damage parts are done here.

class RSQ_GrabPerk : RSQ_Perk
{
	override bool ModLoaded() { return RSQM.Has("RSQDG_ThrowService"); }
	// what the grab's ledger says about this inflictor (-1: no recent throw)
	static int Ask(String req, Actor a)
	{
		let s = RSQM.Svc("RSQDG_ThrowService");
		return (s && a) ? s.GetInt(req, "", 0, 0, a) : -1;
	}
	// a thrown object of this player's striking (not a blast it set off)
	static bool Thrown(Actor pawn, Actor shot)
	{
		if (!shot || Ask("throw.by", shot) != PN(pawn) || PN(pawn) < 0) return false;
		if (Ask("throw.blast", shot) == 1) return false;
		int age = Ask("throw.age", shot);
		return age >= 0 && age <= 105;
	}
	static bool Blast(Actor pawn, Actor shot)
	{
		return shot && PN(pawn) >= 0 && Ask("throw.by", shot) == PN(pawn) && Ask("throw.blast", shot) == 1;
	}
}

// THE DISTANCE GRAB TREE (GBOVR_TREES.md 4.7): each node after its parent
class RSQ_GrabTreePerk : RSQ_GrabPerk
{
	virtual String Parent() { return ""; }
	virtual int ParentLevel() { return 1; }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		String pa = Parent();
		return Super.IsSuitableForPlayer(stats) && (pa == "" || PHas(stats, pa, ParentLevel()));
	}
}

// LONG ARM: the grab reaches 15% further a level.
class RSQ_Upgrade_LongArm : RSQ_GrabTreePerk
{
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsPercentIncrease(1.0 + 0.15 * level)); }
}

// IRON GRIP: heavier things come to the hand easier (+50% a level) and weigh you down less (+25%).
class RSQ_Upgrade_IronGrip : RSQ_GrabTreePerk
{
	override String Parent() { return "LongArm"; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("kg", AsPercentIncrease(1.0 + 0.5 * level));
		fields.Insert("burden", AsPercentIncrease(1.0 + 0.25 * level));
	}
}

// HEAVY HITTER: a thrown thing hits 15% harder a level, and a heavy one leaves the hand faster
// (the arm counts 25% heavier a level in the grab's own arm/(arm + kg) throw).
class RSQ_Upgrade_HeavyHitter : RSQ_GrabTreePerk
{
	override String Parent() { return "IronGrip"; }
	override int Cap() { return 5; }
	static double Mult(uint lv) { return 1.0 + 0.15 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		return Thrown(pawn, shot) ? damage * Mult(level) : damage;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// AIR CATCH: the catch window is 25% wider a level, and a thing caught back out of the air and
// thrown again hits 20% harder a level.
class RSQ_Upgrade_AirCatch : RSQ_GrabTreePerk
{
	override String Parent() { return "HeavyHitter"; }
	static double Mult(uint lv) { return 1.0 + 0.20 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!Thrown(pawn, shot) || Ask("throw.juggle", shot) < 1) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("r", AsPercentIncrease(1.0 + 0.25 * level));
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
	}
}

// POWDER KEG: the blast of a barrel a throw set off -- and of the barrels that blast sets off --
// hits 15% harder a level.
class RSQ_Upgrade_PowderKeg : RSQ_GrabTreePerk
{
	override String Parent() { return "HeavyHitter"; }
	override int Cap() { return 5; }
	static double Mult(uint lv) { return 1.0 + 0.15 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		return Blast(pawn, shot) ? damage * Mult(level) : damage;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// DEAD EYE (after Heavy Hitter 2): throw aim assist 12 -> 16, 20, 24 degrees. (RSQDG_Hold.Assist)
class RSQ_Upgrade_DeadEye : RSQ_GrabTreePerk
{
	override String Parent() { return "HeavyHitter"; }
	override int ParentLevel() { return 2; }
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("deg", string.format("%d", 12 + 4 * level)); }
}

// HEAVY LIFT (after Iron Grip 2): two palms make a thing x2.0 -> 2.5, 3.0, 3.5 lighter. (RSQDG_Hold.EffKg)
class RSQ_Upgrade_HeavyLift : RSQ_GrabTreePerk
{
	override String Parent() { return "IronGrip"; }
	override int ParentLevel() { return 2; }
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("x", string.format("x%.1f", 2.0 + 0.5 * level)); }
}

// STRAIGHT PULL (after Long Arm 2): 1 a pull you flick hard (twice the flick threshold) flies straight, no arc; 2 pulls are
// 25% faster. (RSQDG_Flight.StartPath)
class RSQ_Upgrade_StraightPull : RSQ_GrabTreePerk
{
	override String Parent() { return "LongArm"; }
	override int ParentLevel() { return 2; }
	override int Cap() { return 2; }
}

// BODY SHIELD (the unlock, after Iron Grip 1): 1 a held corpse or barrel stops shots and fireballs, and what it stops hurts
// it (a barrel can go off in your hands; a corpse wears out); 2 a corpse lasts 50% more; 3 a fireball it stops goes back at
// its shooter. Under this patch it replaces RSQ Distance Grab's Body Shield row. (RSQDG_Perks.Shield, RSQDG_Hold)
class RSQ_Upgrade_BodyShield : RSQ_GrabTreePerk
{
	override String Parent() { return "IronGrip"; }
	override int Cap() { return 3; }
}

// ---- PLAYER: RSQ TACTICAL RIG ----------------------------------------------------------------
// The rig's own record of the last holster draw (RSQTR_RigService "rig.drawtic" / "rig.drawn",
// synced play state). A draw's gun is the drawn class or its own off-hand copy (BD22Q's
// RSQ_Off_<gun> is a subclass of the gun), in either hand.

class RSQ_RigPerk : RSQ_Perk
{
	override bool ModLoaded() { return RSQM.Has("RSQTR_RigService"); }
	// tics since this player's last draw from a holster, or -1
	static int SinceDraw(Actor pawn)
	{
		let s = RSQM.Svc("RSQTR_RigService");
		if (!s || !pawn) return -1;
		int t = s.GetInt("rig.drawtic", "", 0, 0, pawn);
		return t < 0 ? -1 : RSQM.Now() - t;
	}
	static Class<Weapon> Drawn(Actor pawn)
	{
		let s = RSQM.Svc("RSQTR_RigService");
		if (!s || !pawn) return null;
		String n = s.GetString("rig.drawn", "", 0, 0, pawn);
		Class<Weapon> c = n;
		return c;
	}
	// the weapon in the hand that dealt this, if it is the drawn gun (or its off-hand copy)
	static bool ByDrawn(Actor pawn, Actor shot)
	{
		let dc = Drawn(pawn);
		if (!dc || !pawn.player) return false;
		int h = RSQM.HandOf(pawn, shot);
		Weapon w = h == 0 ? pawn.player.ReadyWeapon : (h == 1 ? pawn.player.OffhandWeapon : null);
		return w && w is dc;
	}
	// the last draw brought the gun up as a pair (its off-hand copy is in the off hand)
	static bool PairUp(Actor pawn)
	{
		let dc = Drawn(pawn);
		if (!dc || !pawn.player) return false;
		let off = pawn.player.OffhandWeapon;
		return off && off is dc && off.GetClass() != dc;
	}
}

// QUICK DRAW: the gun you just drew from a holster hits 10% harder a level, for 1 s + a quarter of
// a second a level after the draw.
class RSQ_Upgrade_QuickDraw : RSQ_RigPerk
{
	override int Cap() { return 5; }
	static int Window(uint lv) { return 35 + 9 * lv; }
	static double Mult(uint lv) { return 1.0 + 0.10 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		int since = SinceDraw(pawn);
		if (since < 0 || since > Window(level) || !ByDrawn(pawn, shot)) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(Window(level)));
	}
}

// PAIR DRAW: drawing a gun as a pair (both hands at once) -- both hands hit 8% harder a level for
// 2 s + half a second a level.
class RSQ_Upgrade_PairDraw : RSQ_RigPerk
{
	// GBOVR_TREES.md 4.8: after Quick Draw 1
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats) { return Super.IsSuitableForPlayer(stats) && PHas(stats, "QuickDraw"); }
	override int Cap() { return 3; }
	static int Window(uint lv) { return 70 + 17 * lv; }
	static double Mult(uint lv) { return 1.0 + 0.08 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		int since = SinceDraw(pawn);
		if (since < 0 || since > Window(level) || !PairUp(pawn) || !ByDrawn(pawn, shot)) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", AsPercentIncrease(Mult(level)));
		fields.Insert("time", AsSeconds(Window(level)));
	}
}

// SHOWDOWN: a kill with the gun you just drew (within 2 s) slows the world for a moment through
// RSQ SlowMo (rsm_pulse). Needs the rig and SlowMo.
class RSQ_Upgrade_Showdown : RSQ_RigPerk
{
	// GBOVR_TREES.md 4.8: after Quick Draw 2
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats) { return Super.IsSuitableForPlayer(stats) && PHas(stats, "QuickDraw", 2); }
	override int Cap() { return 3; }
	override bool ModLoaded() { return RSQM.Has("RSQTR_RigService") && RSQM.Has("RSQSM_Service"); }
	static int Ms(uint lv) { return 300 + 150 * lv; }
	override void OnKill(PlayerPawn pawn, Actor shot, Actor target)
	{
		int since = SinceDraw(pawn);
		if (since < 0 || since > 70 || !ByDrawn(pawn, shot)) return;
		RSQM.Pulse(pawn, Ms(level), 45);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", string.format("%.2fs", Ms(level) / 1000.0)); }
}

// ---- PLAYER: RSQ SLOWMO ----------------------------------------------------------------------
// RSQSM_Service "active" (slow motion is doing something), "adrenaline.add", and rsm_pulse.

// ---- THE REST OF THE GUNSLINGER TREE (GBOVR_TREES.md 4.8): the rig's own options as unlocks, and the gun throw --------
class RSQ_RigTreePerk : RSQ_RigPerk
{
	virtual String Parent() { return ""; }
	virtual int ParentLevel() { return 1; }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		String pa = Parent();
		return Super.IsSuitableForPlayer(stats) && (pa == "" || PHas(stats, pa, ParentLevel()));
	}
}
// AMMO READOUT (root, the unlock): the small digits above each full holster (the rig's Ammo Count row under this patch).
class RSQ_Upgrade_AmmoReadout : RSQ_RigTreePerk { override int Cap() { return 1; } }
// GUN TOSS (root): a thrown gun hurts x1.5, 2.0, 2.5 and staggers 10 tics a level longer.
class RSQ_Upgrade_GunToss : RSQ_RigTreePerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", string.format("x%.1f", 1.0 + 0.5 * level)); }
}
// BOOMERANG GUN (after Gun Toss 2): a thrown gun that hits a monster flies back to the holster it came from (2: to your hand).
class RSQ_Upgrade_BoomerangGun : RSQ_RigTreePerk
{
	override String Parent() { return "GunToss"; }
	override int ParentLevel() { return 2; }
	override int Cap() { return 2; }
}
// KEYS BY HAND (root, the unlock): grip the keyring, touch the keys to a locked door (the rig's Keys to Doors row).
class RSQ_Upgrade_KeysByHand : RSQ_RigTreePerk { override int Cap() { return 1; } }
// SMOKER (root, the unlock): the cigarette pocket and its ritual, and the slow motion after (the rig's Cigarettes row).
class RSQ_Upgrade_Smoker : RSQ_RigTreePerk { override int Cap() { return 1; } }
// CHAIN SMOKER (after Smoker 1): the pack 3 -> 4, 5, 6.
class RSQ_Upgrade_ChainSmoker : RSQ_RigTreePerk
{
	override String Parent() { return "Smoker"; }
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", 3 + level)); }
}
// RSQ LASERSIGHT's two (they hang from Quick Draw, so they need the rig too)
class RSQ_LaserPerk : RSQ_RigTreePerk
{
	override bool ModLoaded() { return Super.ModLoaded() && RSQM.Has("RSQLS_Sight"); }
}
// TARGET LOCK (after Quick Draw 1, the unlock): the dot grows and pulses on a live monster; 2 it turns the target colour.
class RSQ_Upgrade_TargetLock : RSQ_LaserPerk
{
	override String Parent() { return "QuickDraw"; }
	override int Cap() { return 2; }
}
// HEADSHOT REACTION (after Target Lock 1, the unlock): the top fifth of a monster turns the dot the headshot colour; 2 a gun
// hit there counts as a Headshot (Critical Hits' node), asked of the laser ("head.on").
class RSQ_Upgrade_HeadshotReaction : RSQ_LaserPerk
{
	override String Parent() { return "TargetLock"; }
	override int Cap() { return 2; }
}

class RSQ_SlowPerk : RSQ_Perk
{
	override bool ModLoaded() { return RSQM.Has("RSQSM_Service"); }
}

// THE SLOWMO TREE (GBOVR_TREES.md 4.9): each node after its parent. RSQ SlowMo reads the levels by name (its clock).
class RSQ_SlowTreePerk : RSQ_SlowPerk
{
	virtual String Parent() { return "SlowMotion"; }
	virtual int ParentLevel() { return 1; }
	override bool IsSuitableForPlayer(TFLV_PerPlayerStats stats)
	{
		String pa = Parent();
		return Super.IsSuitableForPlayer(stats) && (pa == "" || PHas(stats, pa, ParentLevel()));
	}
}
// SLOW MOTION (the unlock, root): your own key, wrist cross, burst and accessibility button start slow motion only once
// this is learned (other mods' pulses still fire).
class RSQ_Upgrade_SlowMotion : RSQ_SlowTreePerk { override String Parent() { return ""; } override int Cap() { return 1; } }
// LONGER (after Slow Motion): the burst 4 -> 5, 6, 8 s; a full meter lasts 25% longer a level.
class RSQ_Upgrade_Longer : RSQ_SlowTreePerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { static const int B[] = { 4, 5, 6, 8 }; fields.Insert("s", string.format("%d", B[clamp(int(level), 0, 3)])); }
}
// DEEPER (after Slow Motion): the world's speed while slowed 0.5 unlearned -> 0.35, 0.25, 0.1.
class RSQ_Upgrade_Deeper : RSQ_SlowTreePerk
{
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { static const int D[] = { 50, 35, 25, 10 }; fields.Insert("pct", string.format("%d%%", D[clamp(int(level), 0, 3)])); }
}
// CHEAPER (after Longer 1): with the adrenaline meter on, slow motion costs 20% less a level.
class RSQ_Upgrade_Cheaper : RSQ_SlowTreePerk
{
	override String Parent() { return "Longer"; }
	override int Cap() { return 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pct", string.format("%d%%", 20 * level)); }
}
// LEAN DODGE (the unlock, after Dodger 1): leaning out of a slowed round's path makes it miss; 2 a lean dodges a claw too.
class RSQ_Upgrade_LeanDodge : RSQ_SlowTreePerk { override String Parent() { return "Dodger"; } override int Cap() { return 2; } }
// MATRIX (after Deeper 3): the colour drain and the shot trails at full while slowed.
class RSQ_Upgrade_Matrix : RSQ_SlowTreePerk { override String Parent() { return "Deeper"; } override int ParentLevel() { return 3; } override int Cap() { return 1; } }

// MARKSMAN: everything you hit while the world is slowed takes 8% more a level.
class RSQ_Upgrade_Marksman : RSQ_SlowTreePerk
{
	override String Parent() { return "Deeper"; }
	override int Cap() { return 5; }
	static double Mult(uint lv) { return 1.0 + 0.08 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		return RSQM.Slowed() ? damage * Mult(level) : damage;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// DODGER: while the world is slowed you take 8% less a level (up to 32%).
class RSQ_Upgrade_Dodger : RSQ_SlowTreePerk
{
	override String Parent() { return "Deeper"; }
	static double Mult(uint lv) { return 1.0 - 0.08 * min(lv, 4); }
	override double ModifyDamageReceived(Actor pawn, Actor shot, Actor attacker, double damage, Name attacktype)
	{
		return RSQM.Slowed() ? damage * Mult(level) : damage;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("cut", AsPercent(1.0 - Mult(level))); }
}

// SECOND WIND: every kill charges the adrenaline meter 3 more a level (when SlowMo's meter is on).
class RSQ_Upgrade_SecondWind : RSQ_SlowTreePerk
{
	override String Parent() { return "Cheaper"; }
	override void OnKill(PlayerPawn pawn, Actor shot, Actor target) { RSQM.Charge(3 * level); }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", 3 * level)); }
}

// TIME DILATION: a kill while the world is slowed keeps it slowed: a pulse of 0.4 s + 0.15 s a level,
// and 2 adrenaline a level back to pay for a held slow motion.
class RSQ_Upgrade_TimeDilation : RSQ_SlowTreePerk
{
	override String Parent() { return "Marksman"; }
	override int Cap() { return 3; }
	static int Ms(uint lv) { return 250 + 150 * lv; }
	override void OnKill(PlayerPawn pawn, Actor shot, Actor target)
	{
		if (!RSQM.Slowed()) return;
		RSQM.Pulse(pawn, Ms(level), int(clamp(RSQM.SV("rsm_depth", 0.25), 0.05, 0.95) * 100));
		RSQM.Charge(2 * level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", string.format("%.2fs", Ms(level) / 1000.0)); }
}

// ---- PLAYER: TWO HANDS -----------------------------------------------------------------------
// Read off the patch's two live infos: which hand caused a hit (PerPlayerStats.HandOfShot) and when
// each hand last fired (RSQ_MeleeHandler, from each hand's psprite).

class RSQ_DualPerk : RSQ_Perk
{
	static RSQ_MeleeHandler H() { return RSQ_MeleeHandler.Get(); }
	// the hand that dealt this holds a gun (the gloves and sabers have their own two-hand upgrades)
	static int GunHand(Actor pawn, Actor shot)
	{
		int h = RSQM.HandOf(pawn, shot);
		if (h < 0 || !pawn.player) return -1;
		let stats = TFLV_PerPlayerStats.GetStatsFor(pawn);
		let info = stats ? stats.GetInfoForHand(h) : null;
		if (!info || info.IsMelee()) return -1;
		return h;
	}
}

// AKIMBO: while both hands are firing (each inside the last third of a second), 6% more a level.
class RSQ_Upgrade_Akimbo : RSQ_DualPerk
{
	override int Cap() { return 5; }
	static double Mult(uint lv) { return 1.0 + 0.06 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let h = H(); int pn = PN(pawn);
		if (!h || pn < 0 || GunHand(pawn, shot) < 0) return damage;
		int now = RSQM.Now();
		if (now - h.atkMain[pn] > 12 || now - h.atkOff[pn] > 12) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// CROSSFIRE: one hand on each target -- a hit on something other than what your other hand hit in
// the last second does 10% more a level.
class RSQ_Upgrade_Crossfire : RSQ_DualPerk
{
	static double Mult(uint lv) { return 1.0 + 0.10 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let h = H(); int pn = PN(pawn);
		int hand = GunHand(pawn, shot);
		if (!h || pn < 0 || hand < 0 || !target) return damage;
		Actor other = hand == 0 ? h.tgtOff[pn] : h.tgtMain[pn];
		int otic = hand == 0 ? h.tgtOffTic[pn] : h.tgtMainTic[pn];
		if (!other || other == target || other.health <= 0 || RSQM.Now() - otic > 35) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// ALTERNATOR: left, right, left -- each hit with the other hand's gun inside two thirds of a second
// adds 4% a level to the next, up to four in a row.
class RSQ_Upgrade_Alternator : RSQ_DualPerk
{
	static double Mult(uint lv, int stack) { return 1.0 + 0.04 * lv * clamp(stack, 0, 4); }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let h = H(); int pn = PN(pawn);
		int hand = GunHand(pawn, shot);
		if (!h || pn < 0 || hand < 0) return damage;
		return damage * Mult(level, h.AltStackFor(pn, hand));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.04 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 4)));
	}
}

// ---- PLAYER: THE BODY (what the game can read reliably in VR) ----------------------------------
// The head's own travel (HmdPosition, differenced in RSQ_MeleeHandler) and the off-hand trigger.

// EVASION: moving your head at 1.2 m/s or more, you take 8% less a level (up to 32%).
class RSQ_Upgrade_Evasion : RSQ_Perk
{
	static double Mult(uint lv) { return 1.0 - 0.08 * min(lv, 4); }
	override double ModifyDamageReceived(Actor pawn, Actor shot, Actor attacker, double damage, Name attacktype)
	{
		let h = RSQ_MeleeHandler.Get(); int pn = PN(pawn);
		if (!h || pn < 0 || h.headMps[pn] < 1.2) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("cut", AsPercent(1.0 - Mult(level))); }
}

// SOUTHPAW: whatever your off hand holds hits 6% harder a level.
class RSQ_Upgrade_Southpaw : RSQ_Perk
{
	static double Mult(uint lv) { return 1.0 + 0.06 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		return RSQM.HandOf(pawn, shot) == 1 ? damage * Mult(level) : damage;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// STEADY AIM: a bullet fired with your head still (under 0.2 m/s) hits 5% harder a level.
class RSQ_Upgrade_SteadyAim : RSQ_Perk
{
	static double Mult(uint lv) { return 1.0 + 0.05 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		let h = RSQ_MeleeHandler.Get(); int pn = PN(pawn);
		if (!h || pn < 0 || h.headMps[pn] >= 0.2) return damage;
		let stats = TFLV_PerPlayerStats.GetStatsFor(pawn);
		int n = stats ? stats.hitscanStack.Size() : 0;
		if (n <= 0 || stats.hitscanHints[n - 1] != TFLV_VR_Attribution.HINT_HITSCAN) return damage;
		return damage * Mult(level);
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// GUARD (the owner's pick 55, 2026-10-31, "Yes"; Quest teardown surveys/01_MELEE.md 4.4 and apply/02_MELEE_BUILD.md
// 2.2 and 5, "a guard path as an RSQ_Perk -- guard belongs to the player, not a weapon"). THE MOVE IS RSQ MELEE'S since
// 2026-11-01 (its guard.zs: the pose, the soak, the step back, the knock, the break); this is the upgrade: offered when
// the player levels while RSQ Melee is loaded, its level, and its numbers, which Melee asks for by name ("upgrade.num"):
// you take 60% at level 1, 10% less a level, down to 30%; a blow of 35 or more at level 1 (+10 a level) breaks it.
class RSQ_Upgrade_Guard : RSQ_Perk
{
	static double Soak(uint lv) { return max(0.7 - 0.1 * lv, 0.3); }
	static int BreakAt(uint lv) { return 25 + 10 * lv; }
	// the move is RSQ Melee's: offered only while it is loaded (its service, asked by name)
	override bool ModLoaded() { return RSQM.Svc("RSQML_Service") != null; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("take", AsPercent(Soak(level)));
		fields.Insert("brk", string.format("%d", BreakAt(level)));
	}
}
