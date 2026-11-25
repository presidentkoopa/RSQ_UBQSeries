// WARFACE (RS_BlackCGuyEX, chaingunner/RS_Chaingunner.zs; design/BIG_BOSS_REMAINING_A.md 18). From its own code only.
//   opener    BigBomb: his own 40-tic charge (HCPO E); a MISS lets BigBomb run (RS_CGBigEx)
//   points    HCPO E1: chaingun (-0.5, 0.53), ammo belt (+0.35, 0.63), head (0, 0.84)
//   summons   none in his code: no GUARD
//   acts      his Phase2 line (< 5000) from life 2 (RS_Act.zs hook in his Missile)
class RSQMB_BK_RS_BlackCGuyEX : RSQMB_BigKit
{
	override String Card() { return "WARFACE"; }
	override String Kind() { return "BLACK CHAINGUNNER"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, -0.5, 0.53, 0.35, 0.63, 0, 0.84); }
	override String Opener(RSQMB_Tele t, int act) { return "BigBomb"; }
}
