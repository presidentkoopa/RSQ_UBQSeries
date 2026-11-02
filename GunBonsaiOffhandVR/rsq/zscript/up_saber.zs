// THE SABERS' UPGRADE PATH (RSQ_Saber: UBQS_Saber, UBQS_SaberOff).
//
// Most of these change the saber's own behaviour, so the saber does the work: it asks
// RSQ_MeleeUpgradeService for its level by name ("level", "<short name>", weapon) and these
// classes are what Gun Bonsai offers, stores and shows. Without this patch the saber reads 0
// for everything and is exactly as it was.

class RSQ_Upgrade_SaberMarker : RSQ_Upgrade_Base
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info); }
	// the main saber's record (the X block and the blade lock are the main saber's; Two Sabers is learned there)
	static bool MainSaber(TFLV_WeaponInfo info) { return SaberInfo(info) && info.wpnClass ~== "UBQS_Saber"; }
	// either saber of this player holds that node
	static bool AnySaberHas(TFLV_PerPlayerStats stats, String shortName, int minLevel = 1)
	{
		if (!stats) return false;
		for (int i = 0; i < stats.weapons.Size(); i++)
		{
			let w = stats.weapons[i];
			if (SaberInfo(w) && Has(w, shortName, minLevel)) return true;
		}
		return false;
	}
}

// MOMENTUM, shown as ELEGANT WEAPON (GBOVR_TREES.md 4.2 Blade, root; the class keeps its name for saves): damage builds
// while the blade keeps moving, and drops back when it stops. (UBQS_SaberBase.MomentumTick / UpgCutMult: +10% a level
// per half second of motion, up to 2 s)
class RSQ_Upgrade_Momentum : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "Momentum") < 4; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.10 * level));
		fields.Insert("max", AsPercentIncrease(1.0 + 0.40 * level));
	}
}

// RIPOSTE EDGE, shown as AGGRESSIVE NEGOTIATIONS (4.2 Blade, after Elegant Weapon 1): a block primes the blade; the next
// cut inside the window does x1.5 (+0.25 a level).
class RSQ_Upgrade_RiposteEdge : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Momentum") && LevelOf(info, "RiposteEdge") < 4; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("mult", string.format("x%.2f", 1.5 + 0.25 * (level - 1)));
		fields.Insert("time", AsSeconds(35 + 17 * (level - 1)));
	}
}

// PIERCING RETURN: a returned bolt goes through the first body it meets (one more per level). (4.2 Deflect, after Return to
// Sender 1 or Guided Return 1.)
class RSQ_Upgrade_PiercingReturn : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		return SaberInfo(info) && (Has(info, "ReturnToSender") || Has(info, "GuidedReturn")) && LevelOf(info, "PiercingReturn") < 3;
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// SABER THROW: when its route is done, the thrown saber finds one more enemy per level. (4.2 Focus, after Battle
// Meditation 1.)
class RSQ_Upgrade_SaberThrow : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "BattleMeditation") && LevelOf(info, "SaberThrow") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", level)); }
}

// CHAIN CHOKE: a Force-choke kill jumps the grip to the nearest enemy.
// STRUCK BY THE OWNER (GBOVR_TREES.md 4.2, 11-02): no longer offered; a save that has it keeps it, and it still works.
class RSQ_Upgrade_ChainChoke : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return false; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsMeters(256 + 64 * level)); }
}

// DUAL HARMONY, shown as ASSAULT (the owner renamed it 11-02; 4.2 Dual, after Two Sabers 1): cuts that alternate between
// your two sabers stack.
class RSQ_Upgrade_DualHarmony : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && AnySaberHas(info.stats, "TwoSabers") && LevelOf(info, "DualHarmony") < 4; }
	static double Mult(uint lv, int stack) { return 1.0 + 0.10 * lv * stack; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!shot || !pawn || !pawn.player || !RSQM.IsSaberName(shot.GetClassName())) return damage;
		let h = RSQ_MeleeHandler.Get();
		if (!h) return damage;
		return damage * Mult(level, h.DualStackFor(pawn.PlayerNumber(), shot.GetClassName()));
	}
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("step", AsPercent(0.10 * level));
		fields.Insert("max", AsPercentIncrease(Mult(level, 5)));
	}
}

// ---- THE FORCE (UBQS_Force: push, pull, choke, jump) -----------------------------------------
// With this patch loaded an unlearned power starts weaker (rsq_force_start, 60%); level 1 is
// the saber's own full strength and each level after adds to it -- and changes it:
class RSQ_Upgrade_ForcePush : RSQ_Upgrade_SaberMarker
{
	// (4.2 The Force: after Force Sensitive, 4 levels)
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && AnySaberHas(info.stats, "ForceSensitive") && LevelOf(info, "ForcePush") < 4; }
	// 2+: the cone opens 10 degrees a level. 3+: it is a shockwave all round you as well.
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); }
}
class RSQ_Upgrade_ForcePull : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && AnySaberHas(info.stats, "ForceSensitive") && LevelOf(info, "ForcePull") < 4; }
	// 2+: what arrives is stunned. 3+: the pull yanks its weapon away (no ranged attacks).
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); }
}
// (shown as FORCE GRIP since 11-02; the class keeps its name for saves)
class RSQ_Upgrade_ForceChoke : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && AnySaberHas(info.stats, "ForceSensitive") && LevelOf(info, "ForceChoke") < 4; }
	// 2+: it lifts them and the grip crushes harder the longer you hold. 3+: it holds more than one.
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); fields.Insert("n", string.format("%d", max(1, level - 1))); }
}
class RSQ_Upgrade_ForceJump : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && AnySaberHas(info.stats, "ForceSensitive") && LevelOf(info, "ForceJump") < 3; }
	// 2+: landing from a Force jump is a slam that throws everything near you.
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("pwr", AsPercent(level <= 0 ? 0.6 : 1.0 + 0.15 * (level - 1))); }
}

// ---- THE SABER TREE, new nodes (GBOVR_TREES.md 4.2; the owner kept every node, 11-02, names "Star-Warsy" at a
// film-goer's level). The saber does each move and asks its level by name (UBQS_Upg.Lv); its numbers come from
// "upgrade.num". SEVERAL OF THESE WERE THE SABER'S OWN BEHAVIOUR, and under Gun Bonsai VR they become unlocks, the way
// the Uppercut did on the gloves: without Gun Bonsai VR the saber is exactly what it was.

// ---- FOCUS (the marks) ----
// BATTLE MEDITATION: under Gun Bonsai VR a throw starts with one mark; each level adds one (5 at level 4, the saber's own
// default). The Lock-On Targets row is the saber's without the patch.
class RSQ_Upgrade_BattleMeditation : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "BattleMeditation") < 4; }
	static int Locks(uint lv) { return 1 + lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", Locks(level))); }
}
// SABER BARRAGE: the thrown saber cuts what it passes on its way home (an unlock under Gun Bonsai VR; it always did
// without it), for a share of a cut.
class RSQ_Upgrade_SaberBarrage : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "BattleMeditation", 2) && LevelOf(info, "SaberBarrage") < 3; }
	static double Share(uint lv) { return 0.5 + 0.15 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("share", AsPercent(Share(level))); }
}
// RETURNING BLADE: the thrown saber flies its marks again before it comes home (2: a third time).
class RSQ_Upgrade_ReturningBlade : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "SaberBarrage") && LevelOf(info, "ReturningBlade") < 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", String.Format("%d", level)); }
}

// ---- BLADE (the forms) ----
// STRIKE TRUE: a cut freezes what it hits for a beat (the Hit-Stop row's three settings as levels under Gun Bonsai VR).
class RSQ_Upgrade_StrikeTrue : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Momentum") && LevelOf(info, "StrikeTrue") < 3; }
	static int Tics(uint lv) { return lv >= 3 ? 6 : lv == 2 ? 4 : lv == 1 ? 3 : 0; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(Tics(level))); }
}
// KYBER ATTUNEMENT: the blade grows, 54 -> 65 -> 76 -> 88 -> 99 cm (the saber's five lengths as levels; the Blade Length
// row is the floor).
class RSQ_Upgrade_KyberAttunement : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Momentum", 2) && LevelOf(info, "KyberAttunement") < 4; }
	static int Cm(uint lv) { static const int C[] = { 54, 65, 76, 88, 99 }; return C[clamp(int(lv), 0, 4)]; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("cm", String.Format("%d cm", Cm(level))); }
}
// HIGH GROUND: a cut on a monster with little left cuts it apart (no bosses).
class RSQ_Upgrade_HighGround : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "RiposteEdge", 2) && LevelOf(info, "HighGround") < 3; }
	static double Share(uint lv) { return 0.20 + 0.05 * lv; }
	override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage, Name attacktype)
	{
		if (!shot || !RSQM.IsSaberName(shot.GetClassName()) || !Monster(target) || target.bBoss) return damage;
		if (target.health > RSQM.StartHealth(target) * Share(level)) return damage;
		// past its gib health, so it dies in pieces (its XDeath; Brutal Doom's own gib death)
		RSQM.Touch("sever", pawn, target);
		return max(damage, double(target.health - target.GetGibHealth() + 1) * 1.5);   // GetGibHealth is negative (-spawn health)
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("share", AsPercent(Share(level))); }
}

// ---- STAB ----
// POINT TAKEN: a stab driven in with your body (the head moving forward) hits much harder.
class RSQ_Upgrade_PointTaken : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "PointTaken") < 3; }
	static double Mult(uint lv) { return 2.0 + 0.25 * lv; }
	static double Speed() { return 0.8; }   // m/s, the head forward
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", String.Format("x%.2f", Mult(level))); }
}
// RUN THROUGH: a stabbed monster is held on the blade; pull the blade out and a monster with little left is finished.
class RSQ_Upgrade_RunThrough : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "PointTaken") && LevelOf(info, "RunThrough") < 3; }
	static int Tics(uint lv) { return int(17.5 + 8.75 * lv); }
	static double Finish() { return 0.15; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(Tics(level))); }
}

// ---- DEFLECT ----
// Under Gun Bonsai VR a turned shot goes straight off the blade, like a mirror, until one of these is learned (the
// "Where Turned Shots Go" setting is the saber's without the patch).
// RETURN TO SENDER: a turned shot goes back at whoever fired it -- 1 when you are looking toward the shooter (within
// Cone), 2 when it is anywhere in front of you, 3 always.
class RSQ_Upgrade_ReturnToSender : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Deflector") && LevelOf(info, "ReturnToSender") < 3; }
	static double Cone(uint lv) { return lv >= 3 ? 180.0 : lv == 2 ? 90.0 : 30.0; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("cone", level >= 3 ? "always" : String.Format("within %d degrees of where you look", int(Cone(level)))); }
}
// GUIDED RETURN: a turned shot goes where you look (help onto the enemy nearest your gaze); 2: where your off hand points.
class RSQ_Upgrade_GuidedReturn : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Deflector") && LevelOf(info, "GuidedReturn") < 2; }
}
// PRECOGNITION: the blade parries at a slower swing (1 / (1 + 0.35 lv) of the speed) and blocks a wider line.
class RSQ_Upgrade_Precognition : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && Has(info, "Deflector", 2) && LevelOf(info, "Precognition") < 3; }
	static double Speed(uint lv) { return 1.0 / (1.0 + 0.35 * lv); }
	static double Width(uint lv) { return 1.5 + 0.5 * lv; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("speed", AsPercent(Speed(level)));
		fields.Insert("width", String.Format("%.1f", Width(level)));
	}
}

// ---- DUAL ----
// TWO SABERS: the second saber is an unlock under Gun Bonsai VR (the Start With Dual Sabers row still switches it off).
class RSQ_Upgrade_TwoSabers : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return MainSaber(info) && LevelOf(info, "TwoSabers") < 1; }
}
// DOUBLE-BLADED (the owner, 11-02: "second blade on the saber should be an unlock too"): 1 the saber's second blade can be
// lit; 2 it cuts on the backswing (75%); 3 the twirl cuts all round you.
class RSQ_Upgrade_DoubleBladed : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && LevelOf(info, "DoubleBladed") < 3; }
	static double Back() { return 0.75; }
}
// CROSS GUARD: the X (the two blades held crossed) turns what it stops: 1 straight back, 2 at the shooter, 3 and opening
// the X pushes what is in front of you away.
class RSQ_Upgrade_CrossGuard : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return MainSaber(info) && Has(info, "TwoSabers") && LevelOf(info, "CrossGuard") < 3; }
}
// CLASH: bringing the two blades together releases a shockwave that staggers what stands round you.
class RSQ_Upgrade_Clash : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return MainSaber(info) && Has(info, "CrossGuard", 2) && LevelOf(info, "Clash") < 2; }
	static double Radius(uint lv) { return 2.0 + lv; }   // metres
	static int Stagger() { return 20; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("radius", String.Format("%.0f m", Radius(level))); }
}

// ---- THE FORCE ----
// FORCE SENSITIVE: under Gun Bonsai VR there is no Force until this is learned (an unlearned power then works at the
// patch's start share, rsq_force_start, as before). Without the patch the Force is the saber's own, as always.
class RSQ_Upgrade_ForceSensitive : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return SaberInfo(info) && !AnySaberHas(info.stats, "ForceSensitive"); }
}
// FORCE SPEED: the Force hand held up and still for a second, with nothing to grip, starts slow motion (RSQ SlowMo).
// (The tree's "Force Sensitive 2" read as Force Sensitive and any power at level 2: Force Sensitive has one level.)
class RSQ_Upgrade_ForceSpeed : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		if (!SaberInfo(info) || !AnySaberHas(info.stats, "ForceSensitive") || LevelOf(info, "ForceSpeed") >= 3) return false;
		return AnySaberHas(info.stats, "ForcePush", 2) || AnySaberHas(info.stats, "ForcePull", 2)
			|| AnySaberHas(info.stats, "ForceChoke", 2) || AnySaberHas(info.stats, "ForceJump", 2);
	}
	static double Secs(uint lv) { return 2.0 + lv; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", String.Format("%.0f s", Secs(level))); }
}
// FORCE LIGHTNING: the Force hand turned palm-down (QuestZDoom reads no fingers: palm-down stands in for "fingers
// spread") and aimed at a monster for half a second, then flicked: lightning into it for a second, chaining on.
class RSQ_Upgrade_ForceLightning : RSQ_Upgrade_SaberMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		return SaberInfo(info) && AnySaberHas(info.stats, "ForcePush", 2) && AnySaberHas(info.stats, "ForceChoke", 2) && LevelOf(info, "ForceLightning") < 3;
	}
	static int Damage(uint lv) { return 5 + 3 * lv; }    // a tic, for a second
	static int Targets(uint lv) { return lv + 1; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("dmg", String.Format("%d", Damage(level)));
		fields.Insert("n", String.Format("%d", Targets(level)));
	}
}
