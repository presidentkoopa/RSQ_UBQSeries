// WHAT AM I POINTING AT. Pure geometry, no state, no side effects.
//
// REACH AND SPREAD ARE SEPARATE NUMBERS. How FAR you can pull from and how
// PRECISELY you have to point are different complaints with different fixes, and
// a single "cone size" slider forces one to be wrong to make the other right.
// That is inherited from the desktop build and it is the single most useful
// thing in the original design.
class RSQDG_Cone play
{
	// The best thing in this hand's cone, or null.
	//
	// SCORED ON ANGLE FIRST, distance second, because pointing is what you are
	// actually doing. A nearer object well off your axis is not what you meant;
	// the thing you are pointing straight at is, even if something else is
	// closer to your hand.
	static Actor Best(PlayerPawn pmo, PlayerInfo p, int hand)
	{
		// THE PALM GATE IS ON THE TARGET, not on the drawing, and that is the
		// whole point of it. Gating only the beam would hide the ray and leave
		// the grab reaching exactly as before -- the hand still pulling things
		// across the room from a gun grip, with nothing on screen to say it was
		// about to. No target means no beam, no lock and no pull, all from one
		// test.
		if (!RSQDG_Reach.PalmOk(pmo, p, hand)) return null;

		double reach  = RSQDG_Reach.Num("rsqdg_reach",  p, 512.0);
		double spread = RSQDG_Reach.Num("rsqdg_spread", p, 12.0);
		if (reach <= 0 || spread <= 0) return null;

		Vector3 origin = RSQDG_Reach.Palm(pmo, hand);
		Vector3 dir    = RSQDG_Reach.Dir(pmo, hand);

		// THE CONE IS MEASURED IN THE ROOM, NOT IN MAP SPACE, and this is a
		// correction to the desktop original rather than a port of it.
		//
		// Map space is vertically compressed by `pixelstretch` (1.2), so a
		// plain dot product against a fixed cos(spread) gives a cone that is
		// 20% TIGHTER VERTICALLY than horizontally. Pointing at something above
		// you would need more precision than pointing at something beside you,
		// for no reason the player could ever discover.
		//
		// Both the direction and the offset get their Z scaled by pixelstretch
		// before the comparison, which makes the test a real cone in the room.
		Vector3 pdir = (dir.x, dir.y, dir.z * RSQDG_Reach.PIXELSTRETCH);
		double pdl = pdir.Length();
		if (pdl < 1e-6) return null;
		pdir = pdir / pdl;

		// Compared as a COSINE, so the test is one dot product and no inverse
		// trig runs per candidate. cos is monotonically decreasing over 0..180,
		// so "within the spread" is "dot product at least this big".
		double cosLimit = cos(spread);

		Actor best = null;
		double bestScore = -2.0;

		// THE ITERATOR'S Z ARGUMENTS DO NOT FILTER ANYTHING. Its bounding box
		// is built from (x, y, checkradius) only -- p_maputl.cpp:1075-1086 and
		// :1143 -- so the `checkz`/`checkh` pair is accepted and ignored. The
		// vertical-span idiom that looks like it bounds the search is a no-op,
		// and a cone that trusted it would happily pick targets three floors
		// up. Every Z test in this function is done below, by hand.
		BlockThingsIterator it =
			BlockThingsIterator.CreateFromPos(origin.x, origin.y, origin.z, reach, reach, false);
		while (it.Next())
		{
			Actor a = it.thing;
			if (!a || a == pmo) continue;
			if (!Grabbable(a, pmo, p)) continue;

			// THE MIDDLE OF THE THING, not its origin. A Doom actor's origin is
			// the floor of its volume, so aiming at a barrel by eye and testing
			// against its feet means pointing at the floor in front of it.
			Vector3 mid = (a.Pos.x, a.Pos.y, a.Pos.z + a.Height * 0.5);
			Vector3 d = mid - origin;

			// Range in the ROOM, for the same reason as the cone above: a
			// reach expressed in map units would be a different real distance
			// vertically than horizontally.
			Vector3 pd = (d.x, d.y, d.z * RSQDG_Reach.PIXELSTRETCH);
			double dist = pd.Length();
			if (dist > reach || dist < 0.01) continue;

			double c = (pd / dist) dot pdir;
			if (c < cosLimit) continue;

			// THROUGH A WALL IS NOT POINTING AT IT. Checked last, because it is
			// the only expensive test here and by this point at most a handful
			// of candidates have survived the cheap ones.
			if (RSQDG_Reach.Flag("rsqdg_sight", p, true) && !pmo.CheckSight(a))
				continue;

			// Angle dominates; distance only separates two things you are
			// pointing at equally well.
			double score = c - (dist / reach) * 0.25;
			if (score > bestScore) { bestScore = score; best = a; }
		}
		return best;
	}

	// ---- what may be taken -------------------------------------------------
	//
	// Deliberately conservative and deliberately SEPARATE from the geometry
	// above, so the cone can be tested and tuned before anything can decide
	// what a thing becomes when you catch it. The full policy -- what an object
	// is taken AS, which pose the hand makes, whether it needs two hands --
	// belongs in its own file and is not this function's business.
	static bool Grabbable(Actor a, PlayerPawn pmo, PlayerInfo p)
	{
		// A LIVING MONSTER IS NEVER GRABBABLE, and this is a design rule rather
		// than a limitation. The desktop policy states the reason outright: a
		// distance grab that takes a live monster "is a way of deleting
		// monsters". A corpse is a prop, and one worth having.
		//
		// This is also why the question "does a held monster keep thinking"
		// never arises for this mechanic, however much it matters to a claw.
		if (a.bISMONSTER)
		{
			if (a.Health > 0) return false;
			return RSQDG_Reach.Flag("rsqdg_corpses", p, false);
		}

		// Nothing already owned by an inventory -- that is an item inside
		// somebody, and steering it would move it around inside their pockets.
		let inv = Inventory(a);
		if (inv && inv.Owner) return false;

		// A pickup, or something solid enough to be a prop. bSPECIAL is the
		// pickup-on-touch flag, which is what every collectable carries.
		if (a.bSPECIAL) return true;
		if (a.bSOLID && !a.bNOBLOCKMAP) return true;

		return false;
	}
}
