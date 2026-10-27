// WHAT THE SHIELD KNOWS ABOUT A KILL, for a scorer (RSQ_Score) found by name: no link either way.
//
// The shield is the only one who sees a block or a turned shot -- a blocked attack does no damage,
// so a scorer never hears of it. It keeps a short memory and answers through a Service:
//   GetInt("blocked", "", 0, 0, monster)    tics since the shield blocked an attack FROM that
//                                           monster, or -1 (kept 10 s)
//   GetInt("returned", "", 0, 0, actor)     0 if that actor is a shot the shield turned, or a
//                                           monster a returned bullet hit this tic or the last; -1
//   GetInt("perfect", "", 0, 0, monster)    tics since a PERFECT block (the plate met the attack)
//                                           of that monster's attack, or -1 (kept 10 s)
//   GetObject("returned.from", "", 0, 0, a) the monster that FIRED a shot the shield turned (a = the
//                                           turned shot), or the shooter of a returned bullet that
//                                           hit a this tic or the last; null if neither
//   GetInt("thrown.leg", "", 0, 0, disc)    0 the disc is on its way out (or stuck grinding), 1 it
//                                           is flying home; -1 not a disc
//   GetInt("disc.grinding", "", 0, 0, disc) 0 the disc is stuck in a monster grinding it; -1 not
// Everything here is play-scope state fed by the playsim, so every machine answers the same.
class SSQ_ScoreMemory play
{
	const KEEP = 350;			// tics a block is remembered
	Array<Actor> blockSrc;
	Array<int> blockTic;
	Array<int> perfectTic;		// the last PERFECT block of that source, or -1
	Array<Actor> turnedShots;	// shots the shield sent back (null once they are gone)
	Array<Actor> turnedFrom;	// ...and the monster that fired each one
	Array<Actor> retHit;		// monsters a returned bullet struck
	Array<Actor> retFrom;		// ...and who fired that bullet
	Array<int> retTic;

	void Blocked(Actor source, bool perfect = false)
	{
		if (!source) return;
		for (int k = 0; k < blockSrc.Size(); k++)
			if (blockSrc[k] == source)
			{
				blockTic[k] = Level.maptime;
				if (perfect) perfectTic[k] = Level.maptime;
				return;
			}
		Prune();
		blockSrc.Push(source);
		blockTic.Push(Level.maptime);
		perfectTic.Push(perfect ? Level.maptime : -1);
	}

	void Turned(Actor shot, Actor from = null)
	{
		if (!shot) return;
		for (int k = turnedShots.Size() - 1; k >= 0; k--) if (!turnedShots[k]) { turnedShots.Delete(k); turnedFrom.Delete(k); }
		if (turnedShots.Size() >= 64) { turnedShots.Delete(0); turnedFrom.Delete(0); }
		turnedShots.Push(shot);
		turnedFrom.Push(from);
	}

	void ReturnHit(Actor victim, Actor from = null)
	{
		if (!victim) return;
		if (retHit.Size() >= 32) { retHit.Delete(0); retFrom.Delete(0); retTic.Delete(0); }
		retHit.Push(victim);
		retFrom.Push(from);
		retTic.Push(Level.maptime);
	}

	int SincePerfect(Actor a)
	{
		for (int k = 0; k < blockSrc.Size(); k++)
			if (blockSrc[k] == a)
			{
				if (perfectTic[k] < 0) return -1;
				int d = Level.maptime - perfectTic[k];
				return d <= KEEP ? d : -1;
			}
		return -1;
	}

	Actor ReturnedFrom(Actor a)
	{
		if (!a) return null;
		for (int k = 0; k < turnedShots.Size(); k++) if (turnedShots[k] == a) return turnedFrom[k];
		for (int k = retHit.Size() - 1; k >= 0; k--) if (retHit[k] == a && Level.maptime - retTic[k] <= 1) return retFrom[k];
		return null;
	}

	private void Prune()
	{
		for (int k = blockSrc.Size() - 1; k >= 0; k--)
			if (!blockSrc[k] || Level.maptime - blockTic[k] > KEEP) { blockSrc.Delete(k); blockTic.Delete(k); perfectTic.Delete(k); }
		if (blockSrc.Size() >= 32) { blockSrc.Delete(0); blockTic.Delete(0); perfectTic.Delete(0); }
	}

	int SinceBlocked(Actor a)
	{
		for (int k = 0; k < blockSrc.Size(); k++)
			if (blockSrc[k] == a)
			{
				int d = Level.maptime - blockTic[k];
				return d <= KEEP ? d : -1;
			}
		return -1;
	}

	bool WasReturned(Actor a)
	{
		if (!a) return false;
		for (int k = 0; k < turnedShots.Size(); k++) if (turnedShots[k] == a) return true;
		for (int k = 0; k < retHit.Size(); k++) if (retHit[k] == a && Level.maptime - retTic[k] <= 1) return true;
		return false;
	}
}

class SSQ_ScoreService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = SSQ_Handler.Get();
		if (!h || !h.score) return -1;
		let a = Actor(objectArg);
		if (request == "blocked") return h.score.SinceBlocked(a);
		if (request == "returned") return h.score.WasReturned(a) ? 0 : -1;
		if (request == "perfect") return h.score.SincePerfect(a);
		let d = SSQ_Disc(objectArg);
		if (request == "thrown.leg") return d ? (d.phase == SSQ_Disc.PH_HOME ? 1 : 0) : -1;
		if (request == "disc.grinding") return (d && d.phase == SSQ_Disc.PH_EMBED) ? 0 : -1;
		return -1;
	}

	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = SSQ_Handler.Get();
		if (!h || !h.score) return null;
		if (request == "returned.from") return h.score.ReturnedFrom(Actor(objectArg));
		return null;
	}
}
