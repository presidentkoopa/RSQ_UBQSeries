// SHOCKMASTER (RS_BlackCacoEX, cacodemon/RS_Cacodemon.zs:1747; design/BIG_BOSS_REMAINING_A.md 19). From its own code only.
//   opener    Electro3: its two-charge eye lance (HELE B C 8 bright, the loads, D); a MISS lets Electro3 run
//   points    HELE D1: eye (0, 0.54), left cheek gem (-0.84, 0.65), right cheek gem (+0.82, 0.65)
//   summons   its own RS_RedSpikeCacoEX, spawned as Electro2 / Phase2Jumps spawn them (12,128,32, SXF_SETMASTER |
//             SXF_NOCHECKPOSITION); its code spawns them 12 tics apart, so each later one starts its orbit (user_angle)
//             32 behind, as that spacing gives. EXPOSED!: Electro2's row of 3 (the framework's n + 1, its act scaling).
//             GUARD: the wave is Electro2's 6, from act 2 Phase2Jumps' 7 (spikes still standing count)
//   acts      Phase2Jumps (< 6500) from life 2 (Missile); BonusDucks (< 5000) in life 3 (Electro1/2/3/5); RS_Act.zs hooks
class RSQMB_BK_RS_BlackCacoEX : RSQMB_BigKit
{
	override String Card() { return "SHOCKMASTER"; }
	override String Kind() { return "BLACK CACODEMON"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 0.54, -0.84, 0.65, 0.82, 0.65); }
	override String Opener(RSQMB_Tele t, int act) { return "Electro3"; }

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		let mb = t.b ? t.b.mb : null;
		if (!mb) return 0;
		String sn = "RS_RedSpikeCacoEX";       // a string first: resolved at run time
		Class<Actor> c = sn;
		if (!c) return 0;
		int want;
		if (guard) want = (t.act >= 2 ? 7 : 6) - t.SumAlive();
		else want = n + 1;
		int got = 0;
		for (int i = 0; i < want; i++)
		{
			bool ok; Actor a;
			[ok, a] = mb.A_SpawnItemEx(c, 12, 128, 32, 0, 0, 0, 0, SXF_SETMASTER | SXF_NOCHECKPOSITION);
			if (!a) continue;
			a.A_SetUserVar('user_angle', -32 * i);
			if (p) a.target = p;
			t.AddSum(a);
			got++;
		}
		return got;
	}
}
