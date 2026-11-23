// RS_Act -- A BIG BOSS'S LIFE CHOOSES ITS PHASE (owner 2026-11-23: "Force its own phases", design/BIG_BOSS.md 11-15).
// Colourful Hell's EX bosses change phase by their own health (the Hell Smith at 14000 and 4000, the bog at 5500). RSQ
// Miniboss gives a Big Boss its lives as acts and refills its health each life (to a time-to-kill figure), so those health
// lines would fire at random. While RSQ Miniboss marks the monster with its act (the token RSQMB_ActPhase, by name; its
// amount is the act, 1..3), the act chooses the phase instead: phase n from act n. Without the token (any other fight, or
// without RSQ Miniboss) every check is the monster's own, unchanged.
class RSQMN_Act play
{
	// the act RSQ Miniboss marks it with (0: none)
	static int Of(Actor a)
	{
		if (!a) return 0;
		String n = "RSQMB_ActPhase";   // a string first: resolved at run time, so RSQ Miniboss need not be loaded
		Class<Inventory> c = n;
		return c ? a.CountInv(c) : 0;
	}
	// should it be in `phase` (2, 3) now: the act when marked, else its own health line
	static bool At(Actor a, int phase, int hpBelow)
	{
		int act = Of(a);
		if (act > 0) return act >= phase;
		return a && a.health < hpBelow;
	}
}
