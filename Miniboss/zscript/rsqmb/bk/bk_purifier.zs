// PURIFIER (RS_WhiteArchEX, Monsters/zscript/monsters/plus/RS_PlusWhiteArchEX.zs; design/BIG_BOSS_REMAINING_C.md 26).
// From its own code only.
//   opener    ScreamofTime (:238). Its first frames are 0-tic actions, so the held pose is its LMWX Q 8 (:247), the planted
//             Q. Those 0-tic frames are skipped by the hold; it fades out while it wanders (Clippy), so the kit does what
//             they do first (:239-244: its clock face and effect put back over it, opaque) as the window opens. A MISS
//             lets ScreamofTime run as written (R-S-T-U: quakes, eye spawner, pillars, its Resser raising corpses).
//   points    LMWX Q0 (56 x 75, offsets 27,69; YScale 1.1; its Scripted size 20 x 80): clock face (0, 1.05), image-left
//             hand (+0.95, 0.66), image-right hand (-0.75, 0.67)
//   summons   EXPOSED!: none (the scream's own Resser comes with a MISS). GUARD: its clones, RS_WhiteArchEXClone, which
//             its CloneofTime (:355) makes; CloneofTime exists only under its 12500 line, so act 1 has no wave, no GUARD
//   acts      its 12500 line (Missile :206, StealofTime :346, CloneofTime :358) from life 2 (RS_Act.zs). Its code has no
//             second line: act 3 is act 2's kit. Its 300-second clock (ENDOFTIME, RS_PlusWVileTimer) is its own, untouched.
class RSQMB_BK_RS_WhiteArchEX : RSQMB_BigKit
{
	override String Card() { return "PURIFIER"; }
	override String Kind() { return "WHITE ARCH-VILE"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 1.05, 0.95, 0.66, -0.75, 0.67); }

	override String Opener(RSQMB_Tele t, int act)
	{
		// ScreamofTime's own first actions (:239-244), which the held pose skips
		let mb = t.b ? t.b.mb : null;
		if (mb && mb.health > 0)
		{
			String gn = "RS_GoAway", fn = "RS_FaceMOT", en = "RS_EffectMOT";   // strings: resolved at run time
			Class<Inventory> gc = gn;
			Class<Actor> fc = fn, ec = en;
			if (gc) mb.A_GiveToChildren(gc, 1);
			if (fc) mb.A_SpawnItemEx(fc, 4, 4, 84, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_SETMASTER);
			if (ec) mb.A_SpawnItemEx(ec, 4, 4, 80, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_SETMASTER);
			mb.A_SetTranslucent(1, 1);
		}
		return "ScreamofTime";
	}

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		if (!guard || t.act < 2 || !t.b.mb) return 0;
		String cn = "RS_WhiteArchEXClone";        // a string first: resolved at run time
		Class<Actor> c = cn;
		if (!c) return 0;
		int got = 0;
		for (int i = 0; i < n; i++) if (t.SummonAt(h, c, p, (0, 0), 160, 320)) got++;
		return got;
	}
}
