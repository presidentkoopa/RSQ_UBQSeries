// THE SEAM, monster side (replaces core's stub; core calls only these three).
//
//   OnHooked   once, when the claw bites a monster light enough to come
//   Tick       every tic while it is hooked; return false to let go
//   OnRelease  once, whenever it ends (let go, too far, no progress, death, level end)
//
// Core already guards: the victim gone, out of range, no closer for 52 tics, the
// player dead, a boss or anything over rsqwp_mass_max (an anchor; none of these run).
//
// TWO WAYS TO COME (rsqwp_monster_mode):
//   0 Slide -- THE DEFAULT, the owner's: it slides to you along the floor. This is
//     core's stub, kept line for line (RSQWP_Monster.Slide below).
//   1 Yank  -- it is thrown through the air to your feet in an arc: Distance Grab's
//     WorldHands path (RSQ_DistanceGrab flight.zs, rsqdg_flight_mode 2), ported number
//     for number, with its tumble and its 0.27 air. RSQWP_Flight owns it from the
//     bite until it stands on the floor again, whether or not the rope still holds it.
//
// CLASS-AGNOSTIC. Nothing here names a monster class. What is read: Mass, Radius,
// Height, bBOSS, bDONTTHRUST, bNOGRAVITY/bFLOAT, bISMONSTER, Health, its "Pain"
// state if it has one, and whether its current sprite frame is drawn as a voxel
// (RSQWP_Voxels: the VOXELDEF lumps and the voxels/ namespace, read once). So
// vanilla, Brutal Doom and a voxel monster pack (Cheello's Voxel Doom II) go
// through the same code; what differs is only what those fields say.
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
		if (d <= stopAt + 1.0) { RSQWP_Perks.OnArrive(victim, pmo); return false; }   // Get Over Here (perks.zs)
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
		RSQWP_Perks.Bowl(victim, pmo, (np.x, np.y, victim.Pos.z + victim.Height * 0.5), step / max(RSQWP_Core.Scale(), 0.0001));   // Bowling
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

// THE THROW. Every yanked thing, from the bite until it is on its feet again.
//
// WHY THE ENGINE NEVER GETS A VELOCITY (the ShieldSaw lesson, measured 10-27).
// RSQ_SlowMo slows an actor by scaling its velocity by f and its gravity by f^2, and
// catches a push given mid-slow-motion as the change since last tic (Impulses), which
// it scales by f too. But a push applied while the actor stands on the floor has its
// vertical part exempted (`touching` -> d.z = 0, vz kept whole: a launch looks like a
// landing to that test), and the actor then climbs at full speed against gravity at
// f^2: a quarter-speed world throws it 16 times higher and 4 times further. Measured
// with Brutal Doom's pinky (its pain leap): peak 27 units at full speed, 200 at a
// quarter. And every push gets one full-speed tic before Impulses sees it, because a
// push given in a player's or a monster's own Tick moves the actor that same tic.
// So this mod never hands a thrown monster to the engine's physics at all: it is
// PLACED every tic on a path, by TryMove (walls and things stop it) and SetZ (clamped
// to its floor and ceiling), with its velocity held at zero and gravity off; the
// path's clock and the fall's integrator advance by the world's speed (RSQWP_Core.
// Scale(), RSQ_SlowMo's "scale"), so at a quarter speed the very same arc takes four
// times as long. Nothing for RSQ_SlowMo to scale, so nothing for it to get wrong.
//
// THE PATH (rsqdg_flight_mode 2, rs_distance.zs RS_Pull, DG's numbers): each tic
//     mid = from + (land - from) * e,   e = t ^ 1.6        (slow, then fast: yanked)
// lifted by 4 h e (1 - e), h = 0.15 x the distance, capped ONCE at launch by the
// lowest ceiling over the route (MeasureArc). Time = distance / 15 m/s, 6..70 tics.
// `land` is in front of you, re-read every tic (you can step back while it comes).
// WEIGHT, the one thing added: time x (mass/100)^0.25 and h / (mass/100)^0.25 -- an
// imp (100) flies DG's numbers, a pinky (400) takes 1.41x as long on an arc 0.71x
// as high, a baron (1000) 1.78x / 0.56x. Over rsqwp_yank_mass, too wide or too tall
// to throw, or DONTTHRUST: it slides instead (core makes bosses and the heaviest
// anchors before any of this runs).
//
// THE AIR (rsqdg_air_gravity 0.27, throw.zs): when the rope lets go mid-throw, or the
// path is stopped by a wall or a monster, it falls on its own at 0.27 of Doom's
// gravity from the speed it had -- authored the same way. A floater does not fall: it
// coasts to a stop (0.85 a tic) and hovers where it is.
//
// THE TUMBLE (rsqwp_yank_tumble). A sprite turns about its middle two ways: Spin is
// its angle (the sprite's own rotations show it turning round), Flip is roll with
// +ROLLSPRITE/+ROLLCENTER (end over end, the billboard turned). A voxel ignores roll
// unless its model flags say UseActorRoll/UseActorPitch: stock QZD sets those per
// actor (SetModelFlag), so a voxel monster flips for real, about its pivot, which is
// moved back onto the path by WorldOffset (RSQWP_Turn.Fix, DG's). Flip goes round in
// WHOLE turns so it lands on its feet; Spin ends facing you. All of it is put back.
//
// FROZEN WHILE THROWN. A living thing is put in its Pain state (if it has one) at
// the throw and held there (tics -1): nothing it does mid-air -- an attack, a Brutal
// Doom leap -- happens in the air. Landing gives it rsqwp_yank_stun tics more of
// that frame and lets it go on. Dead mid-air, its death plays and it keeps falling.
//
// LANDING. On the floor with damage from how fast it was going (rsqwp_yank_damage,
// 0 off): (speed - 8) x 0.8 units per tic, at most 40, the player its source. A wall
// or a monster struck on the way does the same to it and half to what it hit.
// Positions are only ever reached by TryMove, so it never ends inside a wall; at the
// end it is checked against the things around it and nudged out if it overlaps.
//
// SAVES. Everything is in this handler's fields (serialised with the level), so a
// save mid-throw loads mid-throw. Leaving the level puts every borrowed flag back.
