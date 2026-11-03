// THE GRENADE'S UPGRADE PATH (RSQ_Grenade: RSQGN_Grenade; GBOVR_TREES.md 4.5). The grenade is a weapon of its own and
// its thrown grenades are claimed for it (RSQ Grenade hand.zs Throw), so it levels like a gun. Like the saber and the
// ShieldSaw, the grenade asks for its levels by name (RSQGN_Upg) and does the work; these classes are what Gun
// Bonsai offers, stores and shows, and hold the numbers ("upgrade.num"). Without this patch the grenade reads 0 for
// everything and is exactly as it was.

class RSQ_Upgrade_GrenadeMarker : RSQ_Upgrade_Base
{
	static bool GrenadeInfo(TFLV_WeaponInfo info) { return info && info.wpnClass ~== "RSQGN_Grenade"; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info); }
}

// ---- CARRY ---------------------------------------------------------------------------------------------------------

// BANDOLIER (root): carry 8 -> 10, 12, 14, 16 (a backpack doubles whatever it is). (RSQGN_Handler.Carry)
class RSQ_Upgrade_Bandolier : RSQ_Upgrade_GrenadeMarker
{
	static int Carry(uint lv) { return 2 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && LevelOf(info, "Bandolier") < 4; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", 8 + Carry(level))); }
}

// SCAVENGER, the grenade's (after Bandolier 1): grenades scattered a map 4 + 2 -> 6 + 3, 8 + 4, 10 + 5 (singles + packs,
// the odds rising with them); 3: one Kill Rewards ammo bit in four is a grenade. (RSQGN_Scatter, RSQ_KRAmmoBit)
class RSQ_Upgrade_Scavenger : RSQ_Upgrade_GrenadeMarker
{
	static double Share(uint lv) { return 1.0 + 0.5 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "Bandolier") && LevelOf(info, "Scavenger") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level)
	{
		fields.Insert("s", string.format("%d", int(4 * Share(level) + 0.5)));
		fields.Insert("p", string.format("%d", int(2 * Share(level) + 0.5)));
	}
}

// ---- THROW ---------------------------------------------------------------------------------------------------------

// STRONG ARM (root): throw strength x1.0 -> 1.25, 1.5, 1.75 (on the Throw Strength row). (RSQGN_Handler.SendThrow)
class RSQ_Upgrade_StrongArm : RSQ_Upgrade_GrenadeMarker
{
	static double Mult(uint lv) { return 1.0 + 0.25 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && LevelOf(info, "StrongArm") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", string.format("x%.2f", Mult(level))); }
}

// FLAT ARC (after Strong Arm 1): arc 0.35 -> 0.25, 0.15 and gravity 0.27 -> 0.22, 0.18 (shares of the rows, so a changed
// row keeps its shape): it flies flatter and further. (SendThrow, Throw)
class RSQ_Upgrade_FlatArc : RSQ_Upgrade_GrenadeMarker
{
	static double Lift(uint lv) { return lv >= 2 ? 0.15 / 0.35 : lv == 1 ? 0.25 / 0.35 : 1.0; }
	static double Gravity(uint lv) { return lv >= 2 ? 0.18 / 0.27 : lv == 1 ? 0.22 / 0.27 : 1.0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "StrongArm") && LevelOf(info, "FlatArc") < 2; }
}

// BOUNCE (after Strong Arm 1): wall bounce 0.25 -> 0.4, 0.55, 0.7: bank shots round corners. (Throw)
class RSQ_Upgrade_Bounce : RSQ_Upgrade_GrenadeMarker
{
	static double Wall(uint lv) { return 0.15 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "StrongArm") && LevelOf(info, "Bounce") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("k", AsPercent(0.25 + Wall(level))); }
}

// ---- FUSE ----------------------------------------------------------------------------------------------------------

// COOK SENSE (root): 1 a tick in the holding hand at each second of the fuse; 2 the flash runs amber, then red. (Level 3,
// the spoken count, waits on its voice: capped at 2 until then.) (RSQGN_Handler.WorldTick, AmberAt)
class RSQ_Upgrade_CookSense : RSQ_Upgrade_GrenadeMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && LevelOf(info, "CookSense") < 2; }
}

// SHORT FUSE (after Cook Sense 1): fuse 3.0 -> 2.5, 2.0 s (the Fuse row less half a second a level). (FuseTics)
class RSQ_Upgrade_ShortFuse : RSQ_Upgrade_GrenadeMarker
{
	static double Secs(uint lv) { return 0.5 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "CookSense") && LevelOf(info, "ShortFuse") < 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%.1f s", 3.0 - Secs(level))); }
}

// ---- BLAST (the frag's own numbers) -------------------------------------------------------------------------------

// BIG BANG (root): both radii +15% a level (200 / 255 -> 290 / 370 at 3). (RSQGN_Thrown.Blast)
class RSQ_Upgrade_BigBang : RSQ_Upgrade_GrenadeMarker
{
	static double Mult(uint lv) { return 1.0 + 0.15 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && LevelOf(info, "BigBang") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("r", AsPercentIncrease(Mult(level))); }
}

// FRAG (after Big Bang 1): both damages +15% a level (85 / 75 -> 123 / 109 at 3). (RSQGN_Thrown.Blast)
class RSQ_Upgrade_Frag : RSQ_Upgrade_GrenadeMarker
{
	static double Mult(uint lv) { return 1.0 + 0.15 * int(lv); }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "BigBang") && LevelOf(info, "Frag") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("d", AsPercentIncrease(Mult(level))); }
}

// CLUSTER (after Frag 2): the blast throws 2 + lv bomblets (30 over 96 each) 2-4 m out, fused 1 s. (RSQGN_Thrown.Cluster)
class RSQ_Upgrade_Cluster : RSQ_Upgrade_GrenadeMarker
{
	static int Count(uint lv) { return lv > 0 ? 2 + int(lv) : 0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "Frag", 2) && LevelOf(info, "Cluster") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("n", string.format("%d", Count(level))); }
}

// STICKY (after Frag 1): the grenade sticks to the first monster it touches (2: or a wall) and goes off there.
// (RSQGN_Thrown.Stick)
class RSQ_Upgrade_Sticky : RSQ_Upgrade_GrenadeMarker
{
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "Frag") && LevelOf(info, "Sticky") < 2; }
}

// ---- STYLE ---------------------------------------------------------------------------------------------------------

// TEETH (root): 1 a pin pulled with your teeth pays Score's `teeth`; 2-3 and the throw that follows does +15%, +30%.
// (RSQGN_Handler: teethPin, Throw)
class RSQ_Upgrade_Teeth : RSQ_Upgrade_GrenadeMarker
{
	static double Mult(uint lv) { return lv >= 3 ? 1.30 : lv == 2 ? 1.15 : 1.0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && LevelOf(info, "Teeth") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", AsPercentIncrease(Mult(level))); }
}

// SKEET (after Strong Arm 2): shooting your own grenade in the air bursts it there at x1.25 + 0.25 a level.
// (RSQGN_Handler.WorldHitscanPreFired, rsqgn_skeet)
class RSQ_Upgrade_Skeet : RSQ_Upgrade_GrenadeMarker
{
	static double Mult(uint lv) { return lv > 0 ? 1.25 + 0.25 * int(lv) : 1.0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "StrongArm", 2) && LevelOf(info, "Skeet") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("mult", string.format("x%.2f", Mult(level))); }
}

// SKEET WINDOW (after Skeet 1; needs RSQ SlowMo): eight tics after a throw, slow motion for 10 + 5 tics a level and the
// grenade drawn full bright: a window to line up the shot. RSQ Grenade's Skeet Window row turns the slow motion off.
// (RSQGN_Thrown.SkeetWindow)
class RSQ_Upgrade_SkeetWindow : RSQ_Upgrade_GrenadeMarker
{
	static int Tics(uint lv) { return lv > 0 ? 10 + 5 * int(lv) : 0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "Skeet") && LevelOf(info, "SkeetWindow") < 3; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", AsSeconds(Tics(level))); }
}

// ---- THE SLOWMO LINK -----------------------------------------------------------------------------------------------

// SLOW BURN (after Cook Sense 1; needs RSQ SlowMo): a kill by a grenade that cooked a second or more, while the world is
// slowed, re-pulses slow motion 0.5 + 0.25 s a level. (The cook is the grenade's, asked by name: RSQGN_Service "cooked".)
class RSQ_Upgrade_SlowBurn : RSQ_Upgrade_GrenadeMarker
{
	static int Ms(uint lv) { return lv > 0 ? 500 + 250 * int(lv) : 0; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info) { return GrenadeInfo(info) && Has(info, "CookSense") && LevelOf(info, "SlowBurn") < 3; }
	override void OnKill(PlayerPawn pawn, Actor shot, Actor target)
	{
		if (!RSQM.Slowed() || !shot) return;
		let s = RSQM.Svc("RSQGN_Service");
		if (!s || s.GetInt("cooked", "", 0, 0, shot) < TICRATE) return;
		RSQM.Touch("slow.burn", pawn, target);
		RSQM.Pulse(pawn, Ms(level), int(clamp(RSQM.SV("rsm_depth", 0.25), 0.05, 0.95) * 100));
	}
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("time", string.format("%.2fs", Ms(level) / 1000.0)); }
}

// ---- THE KINDS (each an unlock on the grenade's record; the frag is the base). RSQ Grenade's kinds.zs does them; the
// holding hand's alt trigger cycles the ones you own. ---------------------------------------------------------------

class RSQ_Upgrade_GrenadeKind : RSQ_Upgrade_GrenadeMarker
{
	virtual String Parent() { return ""; }
	virtual int ParentLevel() { return 1; }
	virtual int Cap() { return 3; }
	override bool IsSuitableForWeapon(TFLV_WeaponInfo info)
	{
		String me = GetClassName();
		return GrenadeInfo(info) && Has(info, Parent(), ParentLevel()) && LevelOf(info, me.Mid(12)) < Cap();
	}
	static int Secs(int base, int per, uint lv) { return base + per * max(int(lv), 1); }
}

// IMPACT (after Cook Sense 1): bursts on first contact, no fuse; 2: +15% damage.
class RSQ_Upgrade_Impact : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "CookSense"; }
	override int Cap() { return 2; }
	static double Mult(uint lv) { return lv >= 2 ? 1.15 : 1.0; }
}
// INCENDIARY (after Big Bang 1): the blast leaves fire over its radius for 3 + lv s, 5 a second to monsters in it.
class RSQ_Upgrade_Incendiary : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "BigBang"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%d", Secs(3, 1, level))); }
}
// FREEZE (after Frag 1): no blast damage; monsters inside freeze solid 2 + lv s (bosses slowed); a hard hit shatters, x2.
class RSQ_Upgrade_Freeze : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "Frag"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%d", Secs(2, 1, level))); }
}
// STUN (after Cook Sense 1): half the blast's damage; monsters inside are staggered 2 + lv s.
class RSQ_Upgrade_Stun : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "CookSense"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%d", Secs(2, 1, level))); }
}
// SMOKE (after Cook Sense 2): a cloud 3 + lv m wide for 8 + 4 lv s; monsters inside it, or whose line to their target
// crosses it, lose that target every half second.
class RSQ_Upgrade_Smoke : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "CookSense"; }
	override int ParentLevel() { return 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("m", string.format("%d", Secs(3, 1, level))); fields.Insert("s", string.format("%d", Secs(8, 4, level))); }
}
// FLASH (after Cook Sense 2): no damage; monsters inside are stunned 2 + lv s and lose their target.
class RSQ_Upgrade_Flash : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "CookSense"; }
	override int ParentLevel() { return 2; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%d", Secs(2, 1, level))); }
}
// CHARM (after Flash 1): monsters inside fight for you for 10 + 5 lv s; bosses immune.
class RSQ_Upgrade_Charm : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "Flash"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%d", Secs(10, 5, level))); }
}
// INFIGHT (after Flash 1): monsters inside turn on the nearest monster for 10 + 5 lv s; bosses immune.
class RSQ_Upgrade_Infight : RSQ_Upgrade_GrenadeKind
{
	override String Parent() { return "Flash"; }
	override void GetTooltipFields(Dictionary fields, uint level) { fields.Insert("s", string.format("%d", Secs(10, 5, level))); }
}
