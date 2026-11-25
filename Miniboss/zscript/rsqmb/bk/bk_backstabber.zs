// THE BACKSTABBER UNSILENCED (RS_BlackSpectreEX, plus/RS_PlusSpectreEX.zs; design/BIG_BOSS_REMAINING_B.md 23). From its
// own code only.
//   opener    its own GETTO -> BACKSTABBUU. When the window is due (Due) its own count user_hm is set to 10 and it is sent
//             to GETTO as written: the shriek (GKEX A 20), then A_Warp to 38 behind you (blocked: your right, your left).
//             The tic it is in BACKSTABBUU, the window starts (Step) and holds BACKSTABBUU's first frame, GKEX A 5 Bright
//             (not F: the framework holds a state's first frame only). Its GETTO left without the stab (pain; every warp
//             blocked: GotoMode2) asks again once; a second time the window opens where it stands.
//             A MISS lets BACKSTABBUU run: red sparks, GKEX F 15, its two A_CustomMeleeAttack(40-99), GetBackhere.
//   points    GKEX F1: head (-0.06, 0.53), left claw (+1.30, 0.47), right claw (-1.26, 0.33)
//   summons   none in its code (its ghosts are NOINTERACTION afterimages): no GUARD
//   acts      no phase lines in its code: each life its whole kit
class RSQMB_BK_RS_BlackSpectreEX : RSQMB_BigKit
{
	int armAt;          // the tic it was sent to GETTO (0: not)
	int tries;

	override String Card() { return "THE BACKSTABBER UNSILENCED"; }
	override String Kind() { return "BLACK SPECTRE"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, -0.06, 0.53, 1.30, 0.47, -1.26, 0.33); }
	override String OpenerFrame(RSQMB_Tele t, int act) { return "F"; }       // design 23: frame F (GKEX F1)
	override String Opener(RSQMB_Tele t, int act) { return "BACKSTABBUU"; }

	// the clock is due: its own count to 10 and its own GETTO; the window waits for BACKSTABBUU
	override bool Due(RSQMB_Tele t, RSQMB_Handler h, int now)
	{
		let mb = t.b ? t.b.mb : null;
		if (!mb) return true;
		if (armAt > 0) return false;
		if (tries >= 2) { tries = 0; return true; }
		let p = t.Victim();
		if (!p || mb.Distance3D(p) > 3072 || !mb.CheckSight(p, SF_IGNOREVISIBILITY)) return true;   // the framework waits a second
		State g = StateOf(mb, "GETTO");
		if (!g) return true;
		mb.A_SetUserVar('user_hm', 10);
		mb.SetState(g);
		if (!mb || mb.health <= 0) return true;
		armAt = now;
		tries++;
		if (h && h.debug) Console.Printf("RSQMB EXPOSED! t%d: boss %d's own count set to 10: its GETTO (try %d)", now, t.b.idx, tries);
		return false;
	}

	override bool Step(RSQMB_Tele t, RSQMB_Handler h, int now)
	{
		if (armAt == 0) return false;
		let mb = t.b ? t.b.mb : null;
		if (!mb || mb.health <= 0) { armAt = 0; return false; }
		State bs = StateOf(mb, "BACKSTABBUU");
		if (bs && Actor.InStateSequence(mb.CurState, bs)) { armAt = 0; tries = 0; return true; }
		State g = StateOf(mb, "GETTO");
		if (!g || !Actor.InStateSequence(mb.CurState, g) || now - armAt > 2 * TICRATE) armAt = 0;   // left GETTO without its stab
		return false;
	}

	override void OnEnd(RSQMB_Tele t, RSQMB_Handler h) { armAt = 0; tries = 0; }
}
