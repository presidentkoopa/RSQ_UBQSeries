// BENELLUS (RS_WhiteSGEX, Monsters/zscript/monsters/shotgunner/RS_Shotgunner.zs:2068; Tag "BENELLUS,GOD OF SHOTGUNS,
// ANGRIER": the angry form of RS_WhiteSG2). From his own code only.
//   opener    ShotgunRounded (RS_Shotgunner.zs:2176): BENE ABCD 2, then 20 tics of his sparks gathering, then his
//             punisher (RS_Shotgunpunisher) on you and his two Shrines. Held on its first frame (BENE A 2); a MISS lets
//             it run as his code has it.
//   points    BENE A0 (Scale 1.25, Height 56, Radius 20; offsets 39,87): his face (0, 1.34), the shotgun across his chest
//             (-1.19, 0.89), his body at the bandolier (+0.56, 0.51). No ghost guns.
//   summons   his Shotgun Shrines (RS_ShotgunShrine, ShotgunnerFX.zs:959, a Monster, 800 HP), as ShotgunRounded / Shrines
//             place them (:2182-2183, :2187-2188): one each side of him, 1-178 units out, -128..128 along. Never more than
//             two standing: Shrines he already put up himself (his attacks, his Pain :2163) are taken as the wave, and
//             only the missing side gets one. EXPOSED! and GUARD alike.
//   acts      his Gifts (RS_MineShotgun) from life 2 (RS_Shotgunner.zs:2283, RS_Act.zs).
class RSQMB_BK_RS_WhiteSGEX : RSQMB_BigKit
{
	override String Card() { return "BENELLUS"; }
	override String Kind() { return "GOD OF SHOTGUNS"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 1.34, -1.19, 0.89, 0.56, 0.51); }
	override String Opener(RSQMB_Tele t, int act) { return "ShotgunRounded"; }

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		let mb = t.b.mb;
		String sn = "RS_ShotgunShrine";       // a string first: resolved at run time, so RSQ Monsters need not be loaded
		Class<Actor> c = sn;
		if (!c || !mb) return 0;
		Vector2 fw = (cos(mb.angle), sin(mb.angle)), lf = (-sin(mb.angle), cos(mb.angle));
		// his Shrines standing near him, on which side of him
		bool onL = false, onR = false;
		int have = 0;
		let it = ThinkerIterator.Create(c);
		Actor a;
		while ((a = Actor(it.Next())))
		{
			if (a.health <= 0 || a.Distance2D(mb) > 1024) continue;
			t.AddSum(a);
			have++;
			if ((level.Vec2Diff(mb.pos.xy, a.pos.xy) dot lf) >= 0) onL = true; else onR = true;
		}
		int got = 0;
		for (int s = 0; s < 2 && have + got < 2 && got < n; s++)
		{
			bool left = s == 0;
			if (left ? onL : onR) continue;
			Vector2 ofs = fw * frandom[rsqmbsum](-128, 128) + lf * (left ? frandom[rsqmbsum](1, 178) : -frandom[rsqmbsum](1, 178));
			if (t.SummonAt(h, c, p, ofs, 0, 0)) got++;
		}
		if (got > 0) mb.A_StartSound("weapons/sshotl", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);   // his SeeSound, the Shrines' too
		return have + got;
	}
}
