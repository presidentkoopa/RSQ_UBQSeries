// TERMINATOR MK II (RS_BlackHKEX, hellknight/RS_HellKnight.zs:1865; design/BIG_BOSS_REMAINING_A.md 21). From its own code only.
//   opener    Homing: its two beeps (BRUC E 9 bright), then RS_BruiserMissileEx2; entered at any range (its Missile
//             reaches Homing only past 1,500: the framework's wind-up enters it directly); a MISS lets Homing run
//   points    BRUC E1: arm cannon (-0.78, 0.55), eye (+0.12, 0.86), chest core (+0.33, 0.68)
//   summons   none in its code: no GUARD
//   acts      its Phase2 line (< 5000) from life 2 (RS_Act.zs hook in its Missile); acts 2 and 3
class RSQMB_BK_RS_BlackHKEX : RSQMB_BigKit
{
	override String Card() { return "TERMINATOR MK II"; }
	override String Kind() { return "BLACK HELL KNIGHT"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, -0.78, 0.55, 0.12, 0.86, 0.33, 0.68); }
	override String Opener(RSQMB_Tele t, int act) { return "Homing"; }
}
