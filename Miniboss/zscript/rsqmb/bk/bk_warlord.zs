// IMP WARLORD (RS_BlackImpEX, Monsters/zscript/monsters/imp/RS_Imp.zs:1557). From his own code only.
//   opener    Kamehameha (RS_Imp.zs:1650): AGUR W, hands out, the two RS_BlackImpEXcharge orbs at (1, +-32, 42) beside
//             them, 18 tics charging. Held on its first frame (W 2); a MISS lets it run: the charge and his beam.
//   points    AGUR W1 (XScale 1.05, YScale 1.4, Height 56, Radius 20; offsets 36,58): head (0, 1.27), both hands where
//             the charge orbs form (+-1.68, 0.58). The old layout (head 0.9, orbs +-0.85) sat on his chest and hips.
//   summons   none: his code spawns no monsters (RS_DeathBreathDI, RS_BlackImpEXcharge, RS_BlackImpSmokeOut and his
//             balls are projectiles). No GUARD.
//   acts      his seeker rain (SpamShotRain) from life 2 (RS_Imp.zs:1645, RS_Act.zs).
class RSQMB_BK_RS_BlackImpEX : RSQMB_BigKit
{
	override String Card() { return "IMP WARLORD"; }
	override String Kind() { return "SMOKING BLACK IMP"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 1.27, -1.68, 0.58, 1.68, 0.58); }
	override String Opener(RSQMB_Tele t, int act) { return "Kamehameha"; }
}
