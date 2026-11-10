// THE SEAM, monster side (core calls only these three): a monster on the core's line, which only the Leash makes
// (whip.zs Leash: Whip and Gun's marked crack with the trigger held, since 11-10; the old bind whip's has no input). The
// slot-1 whip with an empty other hand wraps and yanks its own way (whip.zs BeginWrap / Yank) and never comes here.
//
//   OnHooked   once, when the line bites a monster light enough to come
//   Tick       every tic while it is on the line; return false to let go
//   OnRelease  once, whenever it ends (let go, too far, no progress, death, level end)
//
// Core already guards: the victim gone, out of range, no closer for 52 tics, the
// player dead, a boss or anything over rsqwp_mass_max (an anchor; none of these run).
//
// ONE WAY TO COME: it slides to you along the floor (Slide below, RSQ Grapple's stub, kept line for line).
// CLASS-AGNOSTIC: nothing here names a monster class; what is read is Radius, Height, bNOGRAVITY / bFLOAT and Health.
class RSQWP_Monster
{
	static play void OnHooked(Actor victim, PlayerPawn pmo, int hand, Vector3 hookPos)
	{
		if (!victim) return;
		victim.vel.xy = (0, 0);
	}

	static play bool Tick(Actor victim, PlayerPawn pmo, int hand)
	{
		return Slide(victim, pmo, hand);
	}

	static play void OnRelease(Actor victim, PlayerPawn pmo, int hand)
	{
		if (!victim) return;
		victim.vel.xy = (0, 0);
	}

	// ---- THE DEFAULT: core's stub, unchanged ------------------------------------------
	//
	// SLOW MOTION. RSQ_SlowMo slows the monster but not the player or this mod. The
	// victim is moved BY POSITION here, so the step is scaled by the world's speed
	// (RSQWP_Core.Scale()) -- at a quarter speed it comes at a quarter of the pace,
	// exactly as it would walk. Its own velocity is held at zero in the plane while
	// hooked, so nothing the monster or another mod pushes compounds with the pull,
	// and it is let go with none: no fling, in or out of slow motion.
	static play bool Slide(Actor victim, PlayerPawn pmo, int hand)
	{
		if (!victim || !pmo || victim.Health <= 0) return false;
		Vector2 to = pmo.Pos.xy - victim.Pos.xy;
		double d = to.Length();
		double stopAt = pmo.radius + victim.radius + RSQWP_Util.Num("rsqwp_slide_gap", 16);
		if (d <= stopAt + 1.0) { RSQWP_Perks.OnArrive(victim, pmo); return false; }   // Get Over Here (fx.zs)
		double step = min(RSQWP_Util.Num("rsqwp_slide_speed", 10) * RSQWP_Perks.Factor(pmo, 'reel') * RSQWP_Core.Scale(), d - stopAt);
		Vector2 dir = to / d;
		Vector2 np = victim.Pos.xy + dir * step;

		// A floater comes to your height too; a walker stays on the floor.
		if (victim.bNOGRAVITY || victim.bFLOAT)
		{
			double dz = (pmo.Pos.z + pmo.Height * 0.5) - (victim.Pos.z + victim.Height * 0.5);
			double sz = clamp(dz, -step, step);
			double nz = clamp(victim.Pos.z + sz, victim.floorz, victim.ceilingz - victim.Height);
			victim.SetZ(nz);
		}
		RSQWP_Perks.Bowl(victim, pmo, (np.x, np.y, victim.Pos.z + victim.Height * 0.5), step / max(RSQWP_Core.Scale(), 0.0001));   // Bowling (fx.zs)
		if (!victim.TryMove(np, true))
		{
			// slide along whatever stopped it, one axis at a time
			if (!victim.TryMove((np.x, victim.Pos.y), true))
				victim.TryMove((victim.Pos.x, np.y), true);
		}
		victim.vel.xy = (0, 0);
		return true;
	}
}

// The leash perks' memory (Grapple's CoolOK and Struck, kept on the core): Heavy Haul's 3 s per monster, Bowling's one
// strike a second per pair.
extend class RSQWP_Core
{
	const PKN = 32;
	Actor pcA[PKN];
	int pcTic[PKN];
	Actor bwA[PKN], bwBy[PKN];
	int bwTic[PKN];
	bool PerkCool(Actor v)
	{
		int k = -1, oldest = 0;
		for (int i = 0; i < PKN; i++)
		{
			if (pcA[i] == v) { if (level.maptime < pcTic[i]) return false; k = i; break; }
			if (k < 0 && !pcA[i]) k = i;
			if (pcTic[i] < pcTic[oldest]) oldest = i;
		}
		if (k < 0) k = oldest;
		pcA[k] = v; pcTic[k] = level.maptime + 105;
		return true;
	}
	// true when `by` already struck `o` within the last second; else it is noted as struck now
	bool Bowled(Actor by, Actor o)
	{
		for (int i = 0; i < PKN; i++) if (bwA[i] == o && bwBy[i] == by && level.maptime < bwTic[i]) return true;
		int k = 0;
		for (int i = 0; i < PKN; i++) { if (!bwA[i] || level.maptime >= bwTic[i]) { k = i; break; } if (bwTic[i] < bwTic[k]) k = i; }
		bwA[k] = o; bwBy[k] = by; bwTic[k] = level.maptime + 35;
		return false;
	}
}
