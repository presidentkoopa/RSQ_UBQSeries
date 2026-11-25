// PLAYER X (RS_BlackZombieEX, zombieman/RS_Zombieman.zs:1824; design/BIG_BOSS_REMAINING_A.md 17). From his own code only.
//   opener    Jammed: his own jam (PLAY E 8 bright), the blast after one that gave RS_ShotgunWhere; a MISS lets Jammed
//             run (the reload, then RBarrage / BFGBoi / Missile as written)
//   timing    the window waits for his own jam (Step: he enters Jammed); forced after 45 s since the last window
//             (owner-side call, 2026-11-25)
//   points    PLAY E1: super shotgun (-0.6, 0.53), head (0, 0.90), chest (+0.25, 0.67)
//   summons   none in his code: no GUARD
//   acts      none: no phase line, his full kit in all three acts
class RSQMB_BK_RS_BlackZombieEX : RSQMB_BigKit
{
	const FORCE_SECS = 45;
	int lastWin;                // the last window's end (or the fight's start)
	bool wasJam;                // he stood in Jammed's first frame last tic

	override String Card() { return "PLAYER X"; }
	override String Kind() { return "BLACK ZOMBIEMAN"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, -0.6, 0.53, 0, 0.90, 0.25, 0.67); }
	override String Opener(RSQMB_Tele t, int act) { return "Jammed"; }

	// his jam is the cue: the tic he enters Jammed
	override bool Step(RSQMB_Tele t, RSQMB_Handler h, int now)
	{
		let mb = t.b ? t.b.mb : null;
		if (!mb) return false;
		if (lastWin == 0) lastWin = now;
		let js = StateOf(mb, "Jammed");
		bool jam = js && mb.CurState == js;
		bool cue = jam && !wasJam;
		wasJam = jam;
		return cue;
	}
	// the clock alone does not start it: only after 45 s with no window
	override bool Due(RSQMB_Tele t, RSQMB_Handler h, int now)
	{
		if (lastWin == 0) lastWin = now;
		return now - lastWin >= FORCE_SECS * TICRATE;
	}
	override void OnMiss(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p) { lastWin = level.maptime; wasJam = true; }
	override void OnBreak(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p) { lastWin = level.maptime; }
	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act) { lastWin = level.maptime; }   // a life lost cancels the window
}
