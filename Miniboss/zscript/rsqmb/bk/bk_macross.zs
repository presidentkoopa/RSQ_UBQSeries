// MACROSS MISSILE SWARM (RS_BlackSPEX, spider/RS_Spider.zs; design/BIG_BOSS_REMAINING_B.md 22). From its own code only.
//   opener    act 1 its own Miss2 (the rocket salvo), acts 2-3 its own Miss8 (the six blue 0-damage sight-lines, then six
//             yellow bombs). Held as SetState(st, true) leaves it: Miss2's first frame, BSP2 A 6 Bright; Miss8's 0-tic
//             A_Jump is skipped, so BSP2 A 10 Bright. Not frame Q (the framework holds a state's first frame only).
//             A MISS lets the state run as written: Miss2's rockets hang 12 tics, then fly; Miss8 first rolls its own
//             A_Jump(128) into Miss1-4, else the lines and bombs.
//   points    BSP2 Q1: brain dome (+0.05, 0.74), left pod (+0.13, 0.30), right pod (-0.04, 0.30)
//   summons   none in its code (missiles and its tier icon only): no GUARD
//   acts      its 7000 line (Missile -> ChoicesMore) from life 2 (RS_Act.zs hook); its code has no third set: act 3 is set 2
class RSQMB_BK_RS_BlackSPEX : RSQMB_BigKit
{
	override String Card() { return "MACROSS MISSILE SWARM"; }
	override String Kind() { return "BLACK ARACHNOTRON"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0.05, 0.74, 0.13, 0.30, -0.04, 0.30); }
	override String OpenerFrame(RSQMB_Tele t, int act) { return "Q"; }       // design 22: frame Q (BSP2 Q1)
	override String Opener(RSQMB_Tele t, int act) { return act >= 2 ? "Miss8" : "Miss2"; }
}
