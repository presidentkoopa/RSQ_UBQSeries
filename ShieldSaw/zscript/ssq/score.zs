// WHAT THE SHIELD KNOWS ABOUT A KILL, for a scorer (RSQ_Score) found by name: no link either way.
//
// The shield is the only one who sees a block or a turned shot -- a blocked attack does no damage,
// so a scorer never hears of it. It keeps a short memory and answers through a Service:
//   GetInt("blocked", "", 0, 0, monster)    tics since the shield blocked an attack FROM that
//                                           monster, or -1 (kept 10 s)
//   GetInt("returned", "", 0, 0, actor)     0 if that actor is a shot the shield turned, or a
//                                           monster a returned bullet hit this tic or the last; -1
// Everything here is play-scope state fed by the playsim, so every machine answers the same.
class SSQ_ScoreMemory play
{
	const KEEP = 350;			// tics a block is remembered
	Array<Actor> blockSrc;
	Array<int> blockTic;
	Array<Actor> turnedShots;	// shots the shield sent back (null once they are gone)
	Array<Actor> retHit;		// monsters a returned bullet struck
	Array<int> retTic;

	void Blocked(Actor source)
	{
		if (!source) return;
		for (int k = 0; k < blockSrc.Size(); k++)
			if (blockSrc[k] == source) { blockTic[k] = Level.maptime; return; }
		Prune();
		blockSrc.Push(source);
		blockTic.Push(Level.maptime);
	}

	void Turned(Actor shot)
	{
		if (!shot) return;
		for (int k = turnedShots.Size() - 1; k >= 0; k--) if (!turnedShots[k]) turnedShots.Delete(k);
		if (turnedShots.Size() >= 64) turnedShots.Delete(0);
		turnedShots.Push(shot);
	}

	void ReturnHit(Actor victim)
	{
		if (!victim) return;
		if (retHit.Size() >= 32) { retHit.Delete(0); retTic.Delete(0); }
		retHit.Push(victim);
		retTic.Push(Level.maptime);
	}

	private void Prune()
	{
		for (int k = blockSrc.Size() - 1; k >= 0; k--)
			if (!blockSrc[k] || Level.maptime - blockTic[k] > KEEP) { blockSrc.Delete(k); blockTic.Delete(k); }
		if (blockSrc.Size() >= 32) { blockSrc.Delete(0); blockTic.Delete(0); }
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
		return -1;
	}
}
