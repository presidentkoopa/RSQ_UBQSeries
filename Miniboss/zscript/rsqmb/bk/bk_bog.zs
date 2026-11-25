// THE THING FROM THE BOG (RS_BlackFatsoEX, Monsters/zscript/monsters/fatso/RS_Fatso.zs:1644). From its own code only.
//   opener    BiggerBomb (RS_Fatso.zs:1784): BDEM H 12 A_FaceTarget, then RS_ShadowBombBigEX and on into BigBombs. In
//             both phases (Missile far, Phase2, Choose2). Burp (:1825) was not taken: its wind-up frame is G, his pain
//             frame, which would read as BREAK!.
//   points    BDEM H1 (XScale 2.15, YScale 1.45, Height 64, Radius 48; offsets 33,85): the glowing mouth (0, 1.25), his
//             low hand (+1.12, 0.52), his other forearm (-1.21, 0.84). The old layout (belly 0.42, head 0.86) sat on his
//             legs and below the mouth.
//   summons   none: his code spawns no monsters (his shots, RS_Splash11, RS_BlackFatSplash are projectiles). No GUARD.
//   acts      Phase2 from life 2 (RS_Fatso.zs:1750, RS_Act.zs): faster, Choose2 (GroundSplashes, Burp).
//   unsure    Weave1/Weave2 fire RS_ShadowBeast_Ballex2/Ballex3, which no file in Monsters defines: those volleys fire
//             nothing (a Monsters matter, not this kit's).
class RSQMB_BK_RS_BlackFatsoEX : RSQMB_BigKit
{
	override String Card() { return "THE THING FROM THE BOG"; }
	override String Kind() { return "BLACK MANCUBUS"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 1.25, 1.12, 0.52, -1.21, 0.84); }
	override String Opener(RSQMB_Tele t, int act) { return "BiggerBomb"; }
}
