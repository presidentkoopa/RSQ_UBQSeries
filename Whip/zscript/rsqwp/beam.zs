// beam.zs -- THE WHIP'S BEAM: one owner, one pool, a hard cap, nothing left behind (owner 2026-11-17, in his headset:
// "usiong the wheel with the whips's lock on beam causers it to stack up as we move it around enventually i have like
// 5000 static beams"). Code only, not run (owner's call: no rig checks for now); not headset-confirmed.
//
// THE CAUSE. Both of the whip's dotted rays -- the Lock-On Whip's cast (swing.zs DrawAim, drawn every tic the whip is
// in hand) and its ray to the mark (whip.zs UpdateMark) -- are particles with a lifetime of ONE tic, drawn again every
// tic. The engine ages particles in P_ThinkParticles, and while the level is frozen it skips every particle that is not
// flagged SPF_NOTIMEFREEZE (QuestZDoom's p_effect.cpp: "if (Level->isFrozen() && !(particle->flags & SPF_NOTIMEFREEZE))
// continue"): such a particle does not age, so it never dies. RSQ Wheel's Freeze Time While Open (wr_freeze, on by
// default since 2026-11-16) is Level.SetFrozen(true) with the player as the time freezer. WorldTick still runs in a
// frozen level, so the whip went on drawing a whole new ray every tic from wherever the hand was, and every ray stayed
// where it was drawn -- until the engine's particle limit (r_maxparticles) was full. Any other freeze (a Time Freeze
// sphere, another mod's Level.SetFrozen) did the same. The Wheel's freeze is fine; the whip's dots relied on time running.
//
// THE FIX, all in RSQ Whip:
//   * every dot is SPF_NOTIMEFREEZE: the engine ages it and frees it after its one tic, frozen world or not;
//   * every dot goes through BeamDots, owned by one whip (index i) and counted against that whip's budget for the tic
//     (BEAM_CAP, 512) and the tic's budget for every whip together (BEAM_CAP_ALL, 1024). A dot lives one tic, so no more than
//     BEAM_CAP_ALL are ever alive. The longest ray the whip draws (Whip Reach's 60 m cap, x1.15 for a held mark) is
//     about 250 dots, so the cap never shortens a ray: the look is as it was;
//   * the rings and centres (RSQWP_LockRing / RSQWP_LockCentre) live in one slot each per whip (aimRing, aimCen,
//     markRing, markCen, markRing2, markCen2) and are re-placed every tic they are wanted (Keep). Each one removes itself
//     when its slot has not placed it for BEAM_STALE tics, so a piece whose owner stopped tending it cannot stay;
//   * everything is cleared while RSQ Wheel is open (asked by name, wr_RigService "IsOpen": nothing needed to compile,
//     nothing happens without the Wheel). The whip's own state -- its mark, its locked spot, the rope -- is kept, and
//     the beam is back the tic the ring closes. Also cleared: the whip weapon put away (weapon.zs PutAway), a map's end
//     (WorldUnloaded) and a save's load (WorldLoaded).
// Netplay: the Wheel is the console player's, so only that player's whips hide while it is open (as the Wheel's own
// freeze, which is the console player's too).
extend class RSQWP_Whip
{
	const BEAM_CAP = 512;        // dots one whip may draw in one tic (one full-length ray is ~250; two fit, the tic a mark takes over the cast)
	const BEAM_CAP_ALL = 1024;   // dots every whip together may draw in one tic
	const BEAM_STALE = 2;        // a ring or centre not placed by its slot for this many tics removes itself

	int beamTic[NW], beamN[NW];  // whip i's dots this tic (beamN counts for the tic beamTic)
	int beamAllTic, beamAllN;    // every whip's dots this tic

	// One dotted ray for whip i: full-bright additive dots every AIM_STEP from AIM_FROM out of `org` to 2 short of
	// `end`, colour `col`, alpha `alpha`; each lives one tic. Returns how many were drawn.
	int BeamDots(int i, Vector3 org, Vector3 end, int col, double alpha)
	{
		if (i < 0 || i >= NW || BeamHidden(i)) return 0;
		Vector3 span = end - org;
		double len = span.Length();
		if (len <= AIM_FROM) return 0;
		if (beamTic[i] != level.maptime) { beamTic[i] = level.maptime; beamN[i] = 0; }
		if (beamAllTic != level.maptime) { beamAllTic = level.maptime; beamAllN = 0; }
		Vector3 u = span / len;
		FSpawnParticleParams p;
		p.color1 = col;
		p.style = STYLE_Add;
		p.flags = SPF_FULLBRIGHT | SPF_NOTIMEFREEZE;   // aged and freed after its tic even in a frozen world (see the top)
		p.lifetime = 1;
		p.size = 2.0;
		p.sizestep = 0;
		p.startalpha = alpha;
		p.fadestep = 0;
		int n = 0;
		for (double t = AIM_FROM; t < len - 2; t += AIM_STEP)
		{
			if (beamN[i] >= BEAM_CAP || beamAllN >= BEAM_CAP_ALL) break;
			p.pos = org + u * t;
			level.SpawnParticle(p);
			beamN[i]++; beamAllN++; n++;
		}
		return n;
	}

	// ---- RSQ Wheel, by name ------------------------------------------------------------------------------------------

	transient Service wheelSvc;
	transient int wheelLook;     // the next maptime the service is looked for (once a second while it is not found)
	transient int wheelTic;      // the maptime wheelIsOpen was read for
	transient bool wheelIsOpen;

	bool WheelOpen()
	{
		if (wheelTic == level.maptime && wheelTic != 0) return wheelIsOpen;
		wheelTic = level.maptime;
		if (!wheelSvc && level.maptime >= wheelLook)
		{
			let it = ServiceIterator.Find("wr_RigService");
			wheelSvc = it.Next();
			wheelLook = level.maptime + TICRATE;
		}
		let pm = playeringame[consoleplayer] ? players[consoleplayer].mo : null;
		wheelIsOpen = wheelSvc && wheelSvc.GetInt("IsOpen", "", 0, 0, pm) == 1;
		return wheelIsOpen;
	}

	// Whip i's beam is not drawn: RSQ Wheel is open for the player who holds it.
	bool BeamHidden(int i)
	{
		return i >= 0 && i < NW && i / 2 == consoleplayer && WheelOpen();
	}

	// ---- clearing ----------------------------------------------------------------------------------------------------

	// The cast's ring and centre only (aimShown, and so the cursor's held spot, untouched).
	void DropAimPieces(int i)
	{
		if (aimRing[i]) aimRing[i].Destroy();
		if (aimCen[i]) aimCen[i].Destroy();
		aimRing[i] = null; aimCen[i] = null;
	}

	// Every piece of whip i's beam, now. The dots need nothing: each is gone after its own tic. What still wants a
	// piece is drawn again by its slot on the next tic it is wanted.
	void BeamClear(int i)
	{
		if (i < 0 || i >= NW) return;
		ClearAim(i);
		ClearMark(i);
	}

	// Every piece of whip i's beam, and nothing else: the cast's state (aimShown, so a locked spot's hold) is kept. A
	// save's load (whip.zs WorldLoaded).
	void BeamDropPieces(int i)
	{
		if (i < 0 || i >= NW) return;
		DropAimPieces(i);
		ClearMark(i);
	}

	// The whip weapon put away (weapon.zs PutAway): its cast is over at once, not a tic later.
	void BeamPutAway(int i)
	{
		if (i < 0 || i >= NW) return;
		aimHeld[i] = false;
		BeamClear(i);
	}
}
