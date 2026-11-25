// OBSIDIAN TYRANT (RS_BlackCybieEX, Monsters/zscript/monsters/plus/RS_PlusBlackCybieEX.zs). From its own code only.
//   opener    HellShotCombo (RS_PlusBlackCybieEX.zs:299): HSMI I 12 A_FaceTarget, its arm-cannon wind-up, in its PH1 and
//             PH2 pools (every act). A MISS lets it run: two hell-shot volleys, then its hammer (Melee).
//   points    HSMI I1 (Scale 0.93, Height 110, Radius 40; sprite offsets 86,170): head (0, 1.06), hammer (+1.42, 0.85),
//             arm cannon (-0.63, 0.74). The old layout (head 0.86) sat on its chest.
//   summons   its hell portal, RS_PortalSummons (Phase2 :240, Phase3 :247, Summons :357; a RandomSpawner, its roster in
//             cacodemon/RS_CacodemonFX.zs:316). Its code opens portals only from Phase 2 on, so act 1 summons nothing
//             (no GUARD in act 1). A monster is picked from the portal's own roster, weighted as RandomSpawner weighs it
//             (the spawner itself would be gone a tic after it lands, so it is not spawned as-is).
//   acts      its own Phase2/Phase3 lines (:215-216, RS_Act.zs). Phase 3 (Supersmith) has its own heal pentagram
//             (HealUP :397, RS_PentaHealCybEX + HealThing), so the framework's pentagram (bigacts.zs PentaStep, gated
//             on BB_TYRANT) stays off with this kit.
class RSQMB_BK_RS_BlackCybieEX : RSQMB_BigKit
{
	override String Card() { return "OBSIDIAN TYRANT"; }
	override String Kind() { return "HELL SMITH"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 1.06, 1.42, 0.85, -0.63, 0.74); }
	override String Opener(RSQMB_Tele t, int act) { return "HellShotCombo"; }

	// one monster off its portal's roster (RS_PortalSummons' DropItems), weighted by amount as RandomSpawner does
	static Class<Actor> PortalPick()
	{
		String sn = "RS_PortalSummons";
		Class<Actor> sc = sn;
		if (!sc) return null;
		let def = GetDefaultByType(sc);
		int tot = 0;
		for (DropItem di = def.GetDropItems(); di; di = di.Next)
		{
			if (di.Name == 'None') continue;
			Class<Actor> c = di.Name;
			if (c) tot += max(1, di.Amount);
		}
		if (tot <= 0) return null;
		int r = random[rsqmbsum](0, tot - 1);
		for (DropItem di = def.GetDropItems(); di; di = di.Next)
		{
			if (di.Name == 'None') continue;
			Class<Actor> c = di.Name;
			if (!c) continue;
			r -= max(1, di.Amount);
			if (r < 0) return c;
		}
		return null;
	}

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		if (t.act < 2 || !t.b.mb) return 0;      // its portals are Phase 2's and 3's
		int got = 0;
		for (int i = 0; i < n; i++)
		{
			let c = PortalPick();
			if (c && t.SummonAt(h, c, p, (0, 0), 160, 320)) got++;
		}
		if (got > 0) t.b.mb.A_StartSound("cyber/hoof", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);   // its Summons state's sound
		return got;
	}
}
