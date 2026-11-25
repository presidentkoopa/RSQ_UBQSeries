// EVERLASTING WHITE SPIDEY (RS_WhiteMindES, Monsters/zscript/monsters/plus/RS_PlusWhiteMind.zs; design/BIG_BOSS_REMAINING_C.md
// 28). From its own code only.
//   opener    act 1 Shocker (:389), acts 2-3 Shocker2 (:400, its Melee). Their first frame is a 0-tic A_CheckSight, so the
//             held pose is W5PD F 4 (the BFG charge's first frame), not E. A MISS lets the state run as written (bfgf,
//             F-F-F-E-E, then 96 / 192 RS_ESZapper).
//   points    W5PD E1 (122 x 78, offsets 61,78; Scale 1.62, Radius 100, Height 100): core (+0.02, 0.68), image-left gun
//             (+0.26, 0.44), image-right gun (-0.24, 0.44)
//   summons   act 1 none, no GUARD. Act 2 its Sentinels, RS_MiniSentinelSpider (:505, out of its body). Act 3 its Orb of
//             Chaos, RS_OrbOfChaos (what CHAOSCHAOS's RS_WhiteSpidChaosBall becomes, :835); one at a time. Both are the
//             EXPOSED! summons and the GUARD wave for their act.
//   acts      its 13000 and 6000 lines (FlyingCheck :101, Charge :183 / :189, Missile :195-196, CloseJumps :252 / :259 /
//             :263) from life 2 and 3 (RS_Act.zs). Its regeneration (HealThing(4, 20000) in See / Flying) is its own.
class RSQMB_BK_RS_WhiteMindES : RSQMB_BigKit
{
	override String Card() { return "EVERLASTING WHITE SPIDEY"; }
	override String Kind() { return "WHITE SPIDER MASTERMIND"; }
	override String OpenerFrame(RSQMB_Tele t, int act) { return "E"; }   // design 28: the BFG charge (F to E)
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0.02, 0.68, 0.26, 0.44, -0.24, 0.44); }
	override String Opener(RSQMB_Tele t, int act) { return act >= 2 ? "Shocker2" : "Shocker"; }

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		let mb = t.b ? t.b.mb : null;
		if (t.act < 2 || !mb) return 0;
		if (t.act == 2)
		{
			String sn = "RS_MiniSentinelSpider";
			Class<Actor> c = sn;
			if (!c) return 0;
			int got = 0;
			for (int i = 0; i < n; i++) if (t.SummonAt(h, c, p, (0, 0), mb.radius, mb.radius + 128)) got++;
			if (got > 0) mb.A_StartSound("rsplus/spmtarg2", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);   // its Sentinels' sound
			return got;
		}
		// act 3: its Orb of Chaos, one standing at a time
		String on = "RS_OrbOfChaos";
		Class<Actor> oc = on;
		if (!oc) return 0;
		for (int i = 0; i < t.sums.Size(); i++) if (t.sums[i] && t.sums[i].health > 0 && t.sums[i] is oc) return 1;
		return t.SummonAt(h, oc, p, (0, 0), 160, 320) ? 1 : 0;
	}
}
