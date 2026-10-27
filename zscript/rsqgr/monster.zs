// THE SEAM, monster side -- a STUB owned by core so the mod works alone. The monster
// builder (branch agent-monster) replaces this file whole; the three signatures
// below are the contract and RSQGR_Core calls nothing else.
//
//   OnHooked   once, when the claw bites a monster light enough to come
//   Tick       every tic while it is hooked; return false to let go
//   OnRelease  once, whenever it ends (let go, too far, no progress, death, level end)
//
// What core already guards, so this side need not: the victim gone, out of
// range (1.5 x rsqgr_range), no closer for 52 tics, the player dead, a boss or a
// thing heavier than rsqgr_mass_max (that one is an anchor you swing from, and
// none of these are called).
//
// THE DEFAULT (the owner's): it slides to you along the floor.
//
// SLOW MOTION. RSQ_SlowMo slows the monster but not the player or this mod. The
// victim is moved BY POSITION here, so the step is scaled by the world's speed
// (RSQGR_Core.Scale()) -- at a quarter speed it comes at a quarter of the pace,
// exactly as it would walk. Its own velocity is held at zero in the plane while
// hooked, so nothing the monster or another mod pushes compounds with the pull,
// and it is let go with none: no fling, in or out of slow motion.
class RSQGR_Monster
{
	static play void OnHooked(Actor victim, PlayerPawn pmo, int hand, Vector3 hookPos)
	{
		if (!victim) return;
		victim.vel.xy = (0, 0);
	}

	static play bool Tick(Actor victim, PlayerPawn pmo, int hand)
	{
		if (!victim || !pmo || victim.Health <= 0) return false;
		Vector2 to = pmo.Pos.xy - victim.Pos.xy;
		double d = to.Length();
		double stopAt = pmo.radius + victim.radius + RSQGR_Util.Num("rsqgr_slide_gap", 16);
		if (d <= stopAt) return false;
		double step = min(RSQGR_Util.Num("rsqgr_slide_speed", 10) * RSQGR_Core.Scale(), d - stopAt);
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
		if (!victim.TryMove(np, true))
		{
			// slide along whatever stopped it, one axis at a time
			if (!victim.TryMove((np.x, victim.Pos.y), true))
				victim.TryMove((victim.Pos.x, np.y), true);
		}
		victim.vel.xy = (0, 0);
		return true;
	}

	static play void OnRelease(Actor victim, PlayerPawn pmo, int hand)
	{
		if (!victim) return;
		victim.vel.xy = (0, 0);
	}
}
