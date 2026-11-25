// ============================================================================
// RSQ_Miniboss -- EACH BIG BOSS FROM ITS OWN CODE (owner 2026-11-25: "DESIGN IT ACCORDING TO ITS CODE ... YOU SHOULD NOT
// NEED TO INVENT SHIT"). Code only, not run.
//
// A Big Boss's kit: one class per Big Boss, named RSQMB_BK_<its monster's class> (looked up by name, no scan), in its
// own file under zscript/rsqmb/bk/. The framework (telegraph.zs, bigacts.zs) asks it:
//   Card / Kind     its card's name and kind line; Card is its Boss bar name too
//   Points(act)     its weak points, (side, up) pairs as MakeWeakPoints places them; the card shows act 1's
//   Opener(act)     the state of ITS OWN the window holds (EXPOSED!). Held without its action; BREAK! holds it in Pain
//                   and the state never runs; a MISS lets the state run as its code has it. No attack of ours.
//   Summon          only monsters its own code spawns (EXPOSED! and the GUARD wave); none: no GUARD
//   OnAct           a life lost: anything of its own that changes with the act (the act's phase itself is the
//                   RSQMB_ActPhase token its Monsters code reads, RS_Act.zs RSQMN_Act.At / Of)
//   Due / Step      its own timing (Player X: the window waits for his jam)
// A Big Boss with no kit keeps the old generic attacks.
// ============================================================================

class RSQMB_BigKit
{
	// ---- what it is (any scope: the card and the Boss bar read these) ----------------------------------------------
	virtual String Card() { return ""; }
	virtual String Kind() { return ""; }
	virtual void Points(int act, Array<double> sx, Array<double> sy) {}

	// ---- how it fights (play) --------------------------------------------------------------------------------------
	// the state label the window holds, this act; "" = its Missile state
	virtual play String Opener(RSQMB_Tele t, int act) { return ""; }
	// its own monsters for EXPOSED! (guard false) or the GUARD wave (guard true); n is the framework's count for the
	// act. Spawn with t.SummonAt (it lands in sight and is tracked) or put a monster it already has into t.sums
	// (t.AddSum). Answers how many came.
	virtual play int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n) { return 0; }
	virtual play void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act) {}
	// false: not yet, whatever the clock says (asked when the clock is due)
	virtual play bool Due(RSQMB_Tele t, RSQMB_Handler h, int now) { return true; }
	// every tic of the fight, before the window logic; true: start the window now (its own cue)
	virtual play bool Step(RSQMB_Tele t, RSQMB_Handler h, int now) { return false; }
	virtual play void OnMiss(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p) {}
	virtual play void OnBreak(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p) {}
	virtual play void OnEnd(RSQMB_Tele t, RSQMB_Handler h) {}

	// ---- the lookup ------------------------------------------------------------------------------------------------
	static RSQMB_BigKit Lookup(Name monster)
	{
		if (monster == 'None') return null;
		String n = "RSQMB_BK_" .. monster;
		class<RSQMB_BigKit> c = n;
		return c ? RSQMB_BigKit(new(c)) : null;
	}
	static RSQMB_BigKit LookupActor(Actor a) { return a ? Lookup(a.GetClassName()) : null; }

	// helpers for kits
	static void Pts(Array<double> sx, Array<double> sy, double x0, double y0, double x1 = -9, double y1 = -9, double x2 = -9, double y2 = -9)
	{
		sx.Push(x0); sy.Push(y0);
		if (x1 > -9) { sx.Push(x1); sy.Push(y1); }
		if (x2 > -9) { sx.Push(x2); sy.Push(y2); }
	}
	// a state of its own by label, or null
	static play State StateOf(Actor a, String label) { return (a && label != "") ? a.FindStateByString(label) : null; }
}

extend class RSQMB_Tele
{
	RSQMB_BigKit bkit;
	bool kitLooked;
	State openSt;               // the kit's opener this window (MISS lets it run)
	String openName;

	RSQMB_BigKit Kit()
	{
		if (!kitLooked) { kitLooked = true; if (Big() && b.mb) bkit = RSQMB_BigKit.LookupActor(b.mb); }
		return bkit;
	}
	void AddSum(Actor a) { if (a && sums.Find(a) == sums.Size()) sums.Push(a); }
}
