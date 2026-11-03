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
