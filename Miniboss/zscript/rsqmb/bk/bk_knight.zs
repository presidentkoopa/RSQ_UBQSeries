// THE BLACK KNIGHT (RS_BlackRevenantEX, Monsters/zscript/monsters/revenant/RS_Revenant.zs:2232). From his own code only.
// His lives are his own bodies (his Death state spawns them, :2440 and :2445): life 1 the Knight, life 2 his wraith
// RS_BlackRevEx2 (:2534), life 3 his shadow RS_BlackRevEx3 (:2454). Swapped in by bigacts.zs KnightBody from OnAct
// (ActChanged only does it for the old personality), then the act re-marked on the new body.
//   opener    life 1  ShieldBlast (:2351): DKNT P 10, shield up, then T 10 and his shield bombs and blast.
//             life 2  AoE (:2621): WRTH F 5, arms spread, then his fire rain (RS_RainFireRevEX).
//             life 3  Melee (:2505): DKNT E 6, sword back; the shadow has no other attack.
//   points    life 1  DKNT P1 (Scale 1.2, Height 56, Radius 20; offsets 52,79): helmet (-0.18, 1.56), shield (-0.3, 1.11),
//                     sword hand (+2.04, 0.92). The old layout (helmet 0.92, arms 0.5-0.6) sat on his chest and hips.
//             life 2  WRTH F1 (Scale 1, Radius 24; offsets 68,60): head (0, 0.77), both burning hands (+-1.9, 0.68).
//             life 3  DKNT E1 (Scale 1; offsets 32,78): head (0, 1.16), sword hand (+1.3, 1.15), shield (-1.15, 0.8).
//   summons   none: his code spawns no monsters for a fight (RS_RevShieldWalk/2 carry the Monster flag but are his
//             invulnerable shield; RS_BlackRevShade/2 are effects). No GUARD.
//   unsure    RS_BlackRevEx3's See (:2499, :2503) jumps to Death when no RS_BlackRevEx2 is left (A_CheckProximity, count 0,
//             CPXF_EXACT): his shadow is made to die with his wraith. As life 3 the wraith is gone, so by that line the
//             shadow walks into its Death state 12 tics after KnightBody sets it to See. Not run here; reported.
class RSQMB_BK_RS_BlackRevenantEX : RSQMB_BigKit
{
	override String Card() { return "THE BLACK KNIGHT"; }
	override String Kind() { return "BLACK REVENANT"; }
	override void Points(int act, Array<double> sx, Array<double> sy)
	{
		if (act == 2) Pts(sx, sy, 0, 0.77, 1.9, 0.68, -1.9, 0.68);
		else if (act >= 3) Pts(sx, sy, 0, 1.16, 1.3, 1.15, -1.15, 0.8);
		else Pts(sx, sy, -0.18, 1.56, -0.3, 1.11, 2.04, 0.92);
	}
	// by the body he stands in (his lives are bodies)
	override String Opener(RSQMB_Tele t, int act)
	{
		let mb = t.b.mb;
		Name n = mb ? mb.GetClassName() : 'None';     // by name: RSQ Monsters need not be loaded
		if (n == 'RS_BlackRevEx2') return "AoE";
		if (n == 'RS_BlackRevEx3') return "Melee";
		return "ShieldBlast";
	}
	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act)
	{
		if (act < 2 || RSQMB_Tele.CI('rsqmb_big_bodies', 1) == 0) return;
		t.KnightBody(h);
		t.ActMark();            // the act's token onto the new body (ActChanged marked the old one)
	}
}
// his later bodies by name, so the Boss bar keeps his name after the swap (no fight of their own)
class RSQMB_BK_RS_BlackRevEx2 : RSQMB_BK_RS_BlackRevenantEX
{
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 0.77, 1.9, 0.68, -1.9, 0.68); }
	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act) {}
}
class RSQMB_BK_RS_BlackRevEx3 : RSQMB_BK_RS_BlackRevenantEX
{
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 1.16, 1.3, 1.15, -1.15, 0.8); }
	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act) {}
}
