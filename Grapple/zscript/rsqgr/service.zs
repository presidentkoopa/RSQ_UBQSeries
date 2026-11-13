// WHAT GRAPPLE 2.0 DID, FOR ANY MOD THAT ASKS -- found by name, so nothing links against this pack and an absent grapple
// is simply no answer. Written for RSQ Score's Big Pass (its rows wait for it; owner 2026-11-13: "Grapple 2.0 reports
// its events by name now").
//
//   let s = ServiceIterator.Find("RSQGR_Service").Next();
//   int n = s ? s.GetInt("g2.chain", "", 0, 0, pawn) : -1;
//
// THE PLAYER (objectArg = the player's pawn)
//   "g2.chain"       the kick-chain now: kicks since you last stood on the floor (0: none)
//   "g2.chain.best"  the longest kick-chain this map
//   "g2.kicks"       kicks this map (a guarded miniboss's bounce is not a kick)
//   "g2.lastkick"    the tic (level.maptime) of your last kick, -1 never
//   "g2.mode"        what the hook is doing now: 0 nothing, 1 GET OVER HERE, 2 the air pull, 3 the air spike's moment,
//                    4 a spiked monster falling, 5 you on your way to a heavy one, 6 up onto a ledge, 7 Scorpion Pull's hold
//   "g2.air"         1 in the air after a kick-off (until you land), 0 not
//   "g2.doublejump"  1 while this kick-off's double jump is still yours, 0 not
//   "g2.events"      how many events this map (below)
//   "g2.event.tic"   intArg n: the tic of your n-th latest event (0 the latest), -1 none
//   "g2.last"        stringArg an event name: the tic of your latest event of that name, -1 none
//   GetString("g2.event", "", n, 0, pawn)   the name of your n-th latest event (0 the latest), "" none
// THE MONSTER (objectArg = the monster)
//   "g2.kicked"      the tic it was last kicked (or bounced off, guarded), -1 never
//   "g2.yanked"      the tic it was last bitten light (GET OVER HERE, or pulled up in the air), -1 never
//   "g2.spiked"      the tic it was last air-spiked, -1 never
//   "g2.by"          the player number who did the last of those, -1
// EVENT NAMES (in the order they happen):
//   miss               the hook reached nothing (or the sky)
//   bite.wall / bite.floor / bite.ceiling   a fling (jpalomo's thrust)
//   bite.ledge, ledge.land, ledge.fail      a ledge lip: carried up and onto it (or it failed)
//   bite.light, getoverhere, getoverhere.land   a light monster on the ground: yanked, landed in front of you
//   bite.light, airpull, airhold            in the air: pulled up to you, held for the air spike
//   airspike, spike.land                    both hands down: spiked; it hit the floor (Neon Crescent, Grapple-Slam)
//   air.drop                                the air hold ran out with no swing: it drops
//   bite.heavy, kick / kick.kill            you pulled to a heavy one, the kick (kick.kill: the kick killed it)
//   guard                                   a guarded miniboss: the bounce, no damage
//   pull.lost / pull.blocked                the pull ended short (it died first / a wall)
//   doublejump, markers, marker             the double jump, the time markers placed, a marked monster hooked
//   hang                                    fired in the air in a kick-chain: you hang where you are until it bites
//   chain.end                               you landed, or the claw you hung for bit nothing: the kick-chain ends
//                                           (g2.chain read just before is its length)
//   scorpion.hold, scorpion.yank, scorpion.timeout   Scorpion Pull
// Anything else: -1 (GetInt) or "" (GetString) -- including every request name of the old RSQ Grapple (hooked, swinging,
// climbing, xp.*, ...), so a mod still asking those reads "no grapple".
class RSQGR_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request.Left(3) != "g2.") return -1;
		let c = RSQGR_Core.Get();
		if (!c) return -1;
		let pmo = PlayerPawn(objectArg);
		if (pmo && pmo.player)
		{
			int pn = pmo.PlayerNumber();
			if (pn < 0 || pn >= MAXPLAYERS) return -1;
			if (request == "g2.chain") return c.chain[pn];
			if (request == "g2.chain.best") return c.bestChain[pn];
			if (request == "g2.kicks") return c.kicks[pn];
			if (request == "g2.lastkick") return c.lastKick[pn];
			if (request == "g2.mode") return c.mode[pn];
			if (request == "g2.air") return c.airChain[pn] ? 1 : 0;
			if (request == "g2.doublejump") return (c.airChain[pn] && c.djReady[pn]) ? 1 : 0;
			if (request == "g2.events") return c.evCount[pn];
			if (request == "g2.event.tic") { int i = Nth(c, pn, intArg); return i >= 0 ? c.evTic[i] : -1; }
			if (request == "g2.last")
			{
				for (int i = c.evName.Size() - 1; i >= 0; i--) if (c.evPn[i] == pn && c.evName[i] == stringArg) return c.evTic[i];
				return -1;
			}
			return -1;
		}
		let a = Actor(objectArg);
		if (!a) return -1;
		int r = -1;
		for (int i = 0; i < c.recMon.Size(); i++) if (c.recMon[i] == a) { r = i; break; }
		if (request == "g2.kicked") return r >= 0 ? c.recKick[r] : -1;
		if (request == "g2.yanked") return r >= 0 ? c.recYank[r] : -1;
		if (request == "g2.spiked") return r >= 0 ? c.recSpike[r] : -1;
		if (request == "g2.by") return r >= 0 ? c.recBy[r] : -1;
		return -1;
	}

	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "g2.event") return "";
		let c = RSQGR_Core.Get();
		let pmo = PlayerPawn(objectArg);
		if (!c || !pmo || !pmo.player) return "";
		int i = Nth(c, pmo.PlayerNumber(), intArg);
		return i >= 0 ? c.evName[i] : "";
	}

	// the index of player pn's n-th latest event, -1
	static int Nth(RSQGR_Core c, int pn, int n)
	{
		for (int i = c.evName.Size() - 1; i >= 0; i--)
		{
			if (c.evPn[i] != pn) continue;
			if (n-- <= 0) return i;
		}
		return -1;
	}
}
