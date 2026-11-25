// CYBERTRON (RS_WhiteCybieEX, Monsters/zscript/monsters/plus/RS_PlusWhiteCybieEX.zs; design/BIG_BOSS_REMAINING_C.md 27).
// From its own code only.
//   opener    its GlitchLaser for the act: GlitchLaser (:805) act 1, GlitchLaser2 (:824) act 2, GlitchLaser3 (:856) act 3.
//             The hold is the state's first frame, MMDG E 3 (its face-target before the charge), not frame J. A MISS lets
//             the state run as written: rsplus/romeex/atk2, the J-K-L-K-J screen charge, then its laser (SweepBeam within
//             1000).
//   points    MMDG J1 (125 x 126, offsets 62,120; Scale 1.25, Radius 40, Height 110): screen (+0.03, 0.89), image-left
//             fist (+1.09, 0.56), image-right fist (-1.09, 0.56)
//   summons   its RS_GlitchBaron, from act 2 (its Phase2 / FatalBarons :198 / :222: two at 128 either side; act 3 also
//             its BaronMore pair at 218, :233). Act 1: none, no GUARD. Its own GlitchShields stay its own move.
//   acts      its 24576 and 8192 lines (Missile :248-249) from life 2 and 3 (RS_Act.zs)
//   end       its Death (:1591) spawns RS_WhiteCybieEXCore at the end of its death (about 9 s in). The fight ends with
//             the body (boss.zs: the last life's death is BossDied); nothing here holds or removes the Core, so it
//             comes as its code spawns it, a monster of its own, outside the fight. Ending the fight on the Core needs
//             the framework (see the kit report).
class RSQMB_BK_RS_WhiteCybieEX : RSQMB_BigKit
{
	override String Card() { return "CYBERTRON"; }
	override String Kind() { return "WHITE CYBERDEMON"; }
	override Name Epilogue() { return 'RS_WhiteCybieEXCore'; }   // owner call: the fight ends on its own Romero head (its death spawns it)
	override String OpenerFrame(RSQMB_Tele t, int act) { return "J"; }   // design 27: the J-K-L screen charge
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0.03, 0.89, 1.09, 0.56, -1.09, 0.56); }
	override String Opener(RSQMB_Tele t, int act) { return act >= 3 ? "GlitchLaser3" : (act == 2 ? "GlitchLaser2" : "GlitchLaser"); }

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		let mb = t.b ? t.b.mb : null;
		if (t.act < 2 || !mb) return 0;
		String cn = "RS_GlitchBaron";
		Class<Actor> c = cn;
		if (!c) return 0;
		// its own spots: 128 to each side (Phase2 / FatalBarons), from act 3 also 218 (BaronMore)
		static const double OFS[] = { 128, -128, 218, -218 };
		int spots = t.act >= 3 ? 4 : 2;
		Vector2 rt = (sin(mb.angle), -cos(mb.angle));
		int got = 0;
		for (int i = 0; i < spots && got < n; i++) if (t.SummonAt(h, c, p, rt * OFS[i], 0, 0)) got++;
		return got;
	}
}

// its Romero head, the fight's last body (bigkit.zs Epilogue): the Boss bar by the head's own Tag
class RSQMB_BK_RS_WhiteCybieEXCore : RSQMB_BigKit
{
	override String Card() { return "THE ONE BEHIND IT ALL"; }
	override String Kind() { return "WHITE CYBERDEMON"; }
}
