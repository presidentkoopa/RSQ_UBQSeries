// WHAT AM I POINTING AT. Pure geometry, no state, no side effects.
//
// REACH AND SPREAD ARE SEPARATE NUMBERS. How FAR you can pull from and how
// PRECISELY you have to point are different complaints with different fixes, and
// a single "cone size" slider forces one to be wrong to make the other right.
// That is inherited from the desktop build and it is the single most useful
// thing in the original design.
class RSQDG_Cone play
{
	// sqrt of the CAP on any weight (RSQDG_Policy.MAX_WEIGHT, 16). Used only to
	// prune: a candidate whose geometric cost could not beat the best so far
	// even at the heaviest weight anything is allowed to carry is skipped
	// before policy and sight are asked. Exact rather than heuristic -- every
	// weight is clamped to the cap where it is set, so this can never drop a
	// target that would have won.
	const MAX_SQRT_WEIGHT = 4.0;

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
		double bestCost = 1e30;

		// The policy is asked per candidate; fetched once per scan.
		let pol = RSQDG_Policy.Get();
		if (!pol) return null;
		bool sightOn = RSQDG_Reach.Flag("rsqdg_sight", p, true);

		// ALREADY TAKEN IS NOT A CANDIDATE. Found in the rig, 2026-10-26: you
		// turn your palm back out to catch, the cone finds the very object
		// flying at you, and it is LOCKED AGAIN mid-air -- a stray lock tick,
		// a launch the next release would refuse, and a stale lock on whatever
		// the hand then catches. Something in the air or in a hand belongs to
		// the flight or the hold, and the cone does not get a say in it.
		let fl   = RSQDG_Flight.Get();
		let hold = RSQDG_Hold.Get();

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

			// CHEAPEST TEST FIRST, and the order is the Quest budget. The walk
			// above visits every actor within the reach -- monsters, lamps,
			// gibs -- and the dot product has already thrown most of them out.
			// Only what is actually inside the cone is asked about policy, and
			// only a candidate that could still WIN pays for a sight check.
			double geo = (1.0 - c) / max(1e-6, 1.0 - cosLimit) + (dist / reach) * 0.25;
			if (geo / MAX_SQRT_WEIGHT >= bestCost) continue;   // cannot win even at the top weight

			if ((fl && fl.IsFlying(a)) || (hold && hold.IsHeld(a))) continue;

			let rule = pol.Decide(a, pmo, p);
			if (!rule) continue;

			// THE COST, and weight divides it.
			//
			// Angle off-axis, normalised so the edge of the cone is 1.0, plus a
			// quarter of the normalised distance. Angle dominates because
			// pointing is what you are doing; distance only separates two things
			// you are pointing at equally well.
			//
			// THEN DIVIDED BY sqrt(weight), the desktop's own scale: weight 4
			// "counts as half as far off", 0.25 "twice as far". A preference,
			// never a veto -- everything that reached this line is admitted, and
			// weight only re-orders the admitted. So a barrel beside a clip wins
			// when you point between them, and the clip still wins when it is
			// the only thing you are pointing at.
			double cost = geo / sqrt(rule.weight);
			if (cost >= bestCost) continue;

			// THROUGH A WALL IS NOT POINTING AT IT. Last, because it is the only
			// expensive test, and by now the candidate would actually win.
			if (sightOn && !pmo.CheckSight(a)) continue;

			bestCost = cost;
			best = a;
		}
		return best;
	}

	// WHAT MAY BE TAKEN is not this file's business any more -- see policy.zs.
	// It used to be `bSPECIAL || (bSOLID && !bNOBLOCKMAP)`, which made every
	// tech column and tree in a map pullable and a +1 bonus as wanted as a medikit.
}
