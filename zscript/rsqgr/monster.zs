// THE SEAM, monster side (replaces core's stub; core calls only these three).
//
//   OnHooked   once, when the claw bites a monster light enough to come
//   Tick       every tic while it is hooked; return false to let go
//   OnRelease  once, whenever it ends (let go, too far, no progress, death, level end)
//
// Core already guards: the victim gone, out of range, no closer for 52 tics, the
// player dead, a boss or anything over rsqgr_mass_max (an anchor; none of these run).
//
// TWO WAYS TO COME (rsqgr_monster_mode):
//   0 Slide -- THE DEFAULT, the owner's: it slides to you along the floor. This is
//     core's stub, kept line for line (RSQGR_Monster.Slide below).
//   1 Yank  -- it is thrown through the air to your feet in an arc: Distance Grab's
//     WorldHands path (RSQ_DistanceGrab flight.zs, rsqdg_flight_mode 2), ported number
//     for number, with its tumble and its 0.27 air. RSQGR_Flight owns it from the
//     bite until it stands on the floor again, whether or not the rope still holds it.
//
// CLASS-AGNOSTIC. Nothing here names a monster class. What is read: Mass, Radius,
// Height, bBOSS, bDONTTHRUST, bNOGRAVITY/bFLOAT, bISMONSTER, Health, its "Pain"
// state if it has one, and whether its current sprite frame is drawn as a voxel
// (RSQGR_Voxels: the VOXELDEF lumps and the voxels/ namespace, read once). So
// vanilla, Brutal Doom and a voxel monster pack (Cheello's Voxel Doom II) go
// through the same code; what differs is only what those fields say.
class RSQGR_Monster
{
	static play void OnHooked(Actor victim, PlayerPawn pmo, int hand, Vector3 hookPos)
	{
		if (!victim) return;
		victim.vel.xy = (0, 0);
		if (RSQGR_Util.Opt("rsqgr_monster_mode", 0) != 1) return;
		let fl = RSQGR_Flight.Get();
		if (fl) fl.Launch(victim, pmo, hand);
	}

	static play bool Tick(Actor victim, PlayerPawn pmo, int hand)
	{
		let fl = RSQGR_Flight.Get();
		if (fl && victim)
		{
			int s = fl.SlotOf(victim);
			if (s >= 0) return fl.OnLine(s);   // the throw owns it; false = it has landed or broken off
		}
		return Slide(victim, pmo, hand);
	}

	static play void OnRelease(Actor victim, PlayerPawn pmo, int hand)
	{
		if (!victim) return;
		let fl = RSQGR_Flight.Get();
		int s = fl ? fl.SlotOf(victim) : -1;
		if (s >= 0) { fl.Cut(s); return; }   // let go mid-throw: it flies on, on its own
		victim.vel.xy = (0, 0);
	}

	// ---- THE DEFAULT: core's stub, unchanged ------------------------------------------
	//
	// SLOW MOTION. RSQ_SlowMo slows the monster but not the player or this mod. The
	// victim is moved BY POSITION here, so the step is scaled by the world's speed
	// (RSQGR_Core.Scale()) -- at a quarter speed it comes at a quarter of the pace,
	// exactly as it would walk. Its own velocity is held at zero in the plane while
	// hooked, so nothing the monster or another mod pushes compounds with the pull,
	// and it is let go with none: no fling, in or out of slow motion.
	static play bool Slide(Actor victim, PlayerPawn pmo, int hand)
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
// path's clock and the fall's integrator advance by the world's speed (RSQGR_Core.
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
// as high, a baron (1000) 1.78x / 0.56x. Over rsqgr_yank_mass, too wide or too tall
// to throw, or DONTTHRUST: it slides instead (core makes bosses and the heaviest
// anchors before any of this runs).
//
// THE AIR (rsqdg_air_gravity 0.27, throw.zs): when the rope lets go mid-throw, or the
// path is stopped by a wall or a monster, it falls on its own at 0.27 of Doom's
// gravity from the speed it had -- authored the same way. A floater does not fall: it
// coasts to a stop (0.85 a tic) and hovers where it is.
//
// THE TUMBLE (rsqgr_yank_tumble). A sprite turns about its middle two ways: Spin is
// its angle (the sprite's own rotations show it turning round), Flip is roll with
// +ROLLSPRITE/+ROLLCENTER (end over end, the billboard turned). A voxel ignores roll
// unless its model flags say UseActorRoll/UseActorPitch: stock QZD sets those per
// actor (SetModelFlag), so a voxel monster flips for real, about its pivot, which is
// moved back onto the path by WorldOffset (RSQGR_Turn.Fix, DG's). Flip goes round in
// WHOLE turns so it lands on its feet; Spin ends facing you. All of it is put back.
//
// FROZEN WHILE THROWN. A living thing is put in its Pain state (if it has one) at
// the throw and held there (tics -1): nothing it does mid-air -- an attack, a Brutal
// Doom leap -- happens in the air. Landing gives it rsqgr_yank_stun tics more of
// that frame and lets it go on. Dead mid-air, its death plays and it keeps falling.
//
// LANDING. On the floor with damage from how fast it was going (rsqgr_yank_damage,
// 0 off): (speed - 8) x 0.8 units per tic, at most 40, the player its source. A wall
// or a monster struck on the way does the same to it and half to what it hit.
// Positions are only ever reached by TryMove, so it never ends inside a wall; at the
// end it is checked against the things around it and nudged out if it overlaps.
//
// SAVES. Everything is in this handler's fields (serialised with the level), so a
// save mid-throw loads mid-throw. Leaving the level puts every borrowed flag back.
class RSQGR_Flight : EventHandler
{
	const NFLY = 16;
	enum EPhase { FP_NONE, FP_PATH, FP_AIR }

	Actor   fa[NFLY];          // the thing
	PlayerPawn fby[NFLY];      // who threw it (damage source, live landing point)
	int     fph[NFLY];
	bool    fline[NFLY];       // still on the rope (Tick answers true)
	double  ftt[NFLY];         // path clock, in world tics (advances by Scale)
	double  fT[NFLY];          // path length, world tics
	Vector3 ffrom[NFLY];       // its middle at launch
	Vector2 fdir[NFLY];        // from you toward it at launch (where it lands)
	double  fstop[NFLY];       // how far in front of you it lands
	double  farc[NFLY];        // arc height allowed, fixed at launch
	Vector3 fv[NFLY];          // authored velocity, units per WORLD tic
	double  flastVz[NFLY];
	double  fvPrev[NFLY];      // its speed the step before (the arrival step can be a sliver)
	Vector3 flast[NFLY];       // its middle last tic
	int     fage[NFLY];        // real tics since launch
	double  fpeak[NFLY];       // highest the middle went above its launch middle (log)
	// what is borrowed, captured before anything is touched
	bool    sNoBlockMon[NFLY];
	bool    sNoGrav[NFLY], sRollSpr[NFLY], sRollCtr[NFLY], sInterp[NFLY], sVoxel[NFLY];
	double  sAngle[NFLY], sRoll[NFLY], sPitch[NFLY];
	Vector3 sOfs[NFLY];
	double  tSpin[NFLY], tFlip[NFLY];   // degrees over the whole path
	double  ftum[NFLY];                 // tumble progress, in paths (1 = the path's turns)

	static RSQGR_Flight Get() { return RSQGR_Flight(EventHandler.Find("RSQGR_Flight")); }

	int SlotOf(Actor a) const
	{
		if (!a) return -1;
		for (int i = 0; i < NFLY; i++) if (fa[i] == a && fph[i] != FP_NONE) return i;
		return -1;
	}

	bool OnLine(int s) const { return s >= 0 && s < NFLY && fph[s] == FP_PATH && fline[s]; }

	static double Grav(Actor a)
	{
		// The CLASS's gravity, not the live one: RSQ_SlowMo writes Gravity x f^2 onto
		// what it slows, and a throw that read that would fall slowed twice.
		let d = GetDefaultByType(a.GetClass());
		double g = d ? d.Gravity : 1.0;
		return level.gravity * a.CurSector.gravity * g * 0.00125;
	}

	static Vector3 MidOf(Actor a) { return (a.Pos.x, a.Pos.y, a.Pos.z + a.Height * 0.5); }

	static bool Throwable(Actor a)
	{
		if (!a || a.bDONTTHRUST || a.bBOSS) return false;
		double maxM = RSQGR_Util.Num("rsqgr_yank_mass", 1000);
		if (maxM > 0 && a.Mass > maxM) return false;
		if (a.Radius > RSQGR_Util.Num("rsqgr_yank_radius", 64)) return false;
		if (a.Height > RSQGR_Util.Num("rsqgr_yank_height", 110)) return false;
		return true;
	}

	// Where it lands: in front of you, on the line it came in on.
	Vector3 LandMid(int s)
	{
		let a = fa[s];
		let p = fby[s];
		Vector2 xy = p.Pos.xy + fdir[s] * fstop[s];
		double z;
		if (sNoGrav[s]) z = p.Pos.z + p.Height * 0.5;           // a floater comes to your middle
		else
		{
			Sector sec = level.PointInSector(xy);
			z = (sec ? sec.floorplane.ZatPoint(xy) : p.Pos.z) + a.Height * 0.5;
		}
		return (xy.x, xy.y, z);
	}

	bool Launch(Actor a, PlayerPawn pmo, int hand)
	{
		if (!a || !pmo || SlotOf(a) >= 0 || !Throwable(a)) return false;
		int s = -1;
		for (int i = 0; i < NFLY; i++) if (fph[i] == FP_NONE || !fa[i]) { s = i; break; }
		if (s < 0) return false;

		fa[s] = a; fby[s] = pmo; fline[s] = true; fage[s] = 0; fpeak[s] = 0;
		sNoGrav[s] = a.bNOGRAVITY;
		sNoBlockMon[s] = a.bNOBLOCKMONST;
		sRollSpr[s] = a.bROLLSPRITE; sRollCtr[s] = a.bROLLCENTER; sInterp[s] = a.bINTERPOLATEANGLES;
		sAngle[s] = a.Angle; sRoll[s] = a.Roll; sPitch[s] = a.Pitch; sOfs[s] = a.WorldOffset;
		sVoxel[s] = false;

		Vector2 away = a.Pos.xy - pmo.Pos.xy;
		double dl = away.Length();
		fdir[s] = dl > 0.01 ? away / dl : (cos(pmo.Angle), sin(pmo.Angle));
		fstop[s] = pmo.Radius + a.Radius + RSQGR_Util.Num("rsqgr_slide_gap", 16);

		Vector3 mid0 = MidOf(a);
		Vector3 land = LandMid(s);
		double dist = (land - mid0).Length();
		double heft = max(0.25, a.Mass / 100.0) ** 0.25;
		double upt = 15.0 * 34.0 / TICRATE;                       // rsqdg_path_speed 15 m/s
		fT[s] = clamp(dist / upt, 6.0, 70.0) * heft;              // rsqdg_path_tmin/tmax 6..70
		double want = dist * 0.15 / heft;                         // rsqdg_path_arc 0.15
		double cap = MeasureArc(a, mid0, land);
		farc[s] = (cap < 0) ? want : min(want, cap);
		ftt[s] = 0;
		ffrom[s] = mid0;
		flast[s] = mid0;
		fv[s] = (0, 0, 0);

		a.bNOGRAVITY = true;
		a.bNOBLOCKMONST = true;   // thrown, not walking: the AI's monster-blocking lines do not apply
		a.Vel = (0, 0, 0);
		if (a.bISMONSTER && a.Health > 0)
		{
			State pain = a.FindState("Pain");
			if (pain) a.SetState(pain);
			if (a && a.Health > 0) a.tics = -1;
		}
		if (!a) { fph[s] = FP_NONE; return false; }

		// the tumble
		int style = RSQGR_Util.Opt("rsqgr_yank_tumble", 1);
		double turns = RSQGR_Util.Num("rsqgr_yank_turns", 1.0);
		tSpin[s] = 0; tFlip[s] = 0; ftum[s] = 0;
		if (style == 1 || style == 3)
		{
			// whole turns, then whatever is left to end up facing you
			double face = atan2(pmo.Pos.y - land.y, pmo.Pos.x - land.x);
			double rest = Actor.DeltaAngle(a.Angle, face);
			tSpin[s] = 360.0 * max(0.0, double(int(turns + 0.5))) + rest;
		}
		if (style == 2 || style == 3)
			tFlip[s] = 360.0 * max(1.0, double(int(turns + 0.5)));
		if (tSpin[s] != 0 || tFlip[s] != 0)
		{
			a.bINTERPOLATEANGLES = true;
			if (tFlip[s] != 0) { a.bROLLSPRITE = true; a.bROLLCENTER = true; }
			if (tFlip[s] != 0 && RSQGR_Voxels.Drawn(a))
			{
				a.SetModelFlag(MDL_USEACTORPITCH);
				sVoxel[s] = true;
			}
		}
		fph[s] = FP_PATH;
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRM launch %s m=%d r=%.0f h=%.0f dist=%.0f T=%.1f arc=%.0f (want %.0f room %.0f) tumble=%d voxel=%d scale=%.2f",
				a.GetClassName(), a.Mass, a.Radius, a.Height, dist, fT[s], farc[s], want, cap, style, sVoxel[s], RSQGR_Core.Scale());
		return true;
	}

	// The rope let go while it was still coming: it flies on, on its own.
	void Cut(int s)
	{
		if (s < 0 || s >= NFLY || fph[s] == FP_NONE) return;
		fline[s] = false;
		if (fph[s] == FP_PATH) { fv[s] = PathVel(s); ToAir(s, "cut"); }
	}

	// The path's own velocity at its clock, per world tic (d/dtt of StepPath's point).
	// Handed to the air on a cut rather than the last step's difference, which depends
	// on how big the step was -- i.e. on the world's speed.
	private Vector3 PathVel(int s)
	{
		double total = max(1.0, fT[s]);
		double t = clamp(ftt[s] / total, 0.0001, 1.0);
		double e = t ** 1.6;
		double de = 1.6 * (t ** 0.6) / total;
		Vector3 land = fby[s] ? LandMid(s) : flast[s];
		Vector3 v = (land - ffrom[s]) * de;
		v.z += 4.0 * farc[s] * (1.0 - 2.0 * e) * de;
		return v;
	}

	private void ToAir(int s, String why)
	{
		fph[s] = FP_AIR;
		fline[s] = false;
		if (RSQGR_Util.Flag("rsqgr_debug", false) && fa[s])
			Console.Printf("T_GRM air %s (%s) v=(%.2f %.2f %.2f)", fa[s].GetClassName(), why, fv[s].x, fv[s].y, fv[s].z);
	}

	// HOW HIGH THIS PATH CAN ARC (DG's MeasureArc, verbatim in substance): the straight
	// line sampled every 24 units (4..48), the lowest ceiling and highest floor over the
	// route, 8 units of margin. -1 when nothing sampled.
	private static double MeasureArc(Actor a, Vector3 from, Vector3 to)
	{
		double span = (to - from).Length();
		int samples = clamp(int(span / 24.0), 4, 48);
		double minCeil = 1e30, maxFloor = -1e30;
		for (int i = 0; i <= samples; i++)
		{
			double t = double(i) / double(samples);
			Vector2 pt = (from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t);
			Sector sec = level.PointInSector(pt);
			if (!sec) continue;
			double c = sec.ceilingplane.ZatPoint(pt);
			double f = sec.floorplane.ZatPoint(pt);
			if (c < minCeil) minCeil = c;
			if (f > maxFloor) maxFloor = f;
		}
		if (minCeil > 1e29 || maxFloor < -1e29) return -1.0;
		double room = minCeil - maxFloor - a.Height - 8.0;
		double avail = (minCeil - a.Height * 0.5 - 8.0) - max(from.z, to.z);
		double cap = min(room, avail);
		return cap > 0.0 ? cap : 0.0;
	}

	// Place the middle at `mid`: Z first, clamped to the room, then XY by TryMove (a
	// real move that walls and things stop), lifted 6/12/18 if boxed in (DG). Returns
	// false when it could not move; `hit` is what stopped it, if a thing did.
	private transient bool zBlocked;
	private transient Line blockLine;   // PlaceMid's last vertical move was refused by a thing
	private bool PlaceMid(Actor a, Vector3 mid, out Actor hit)
	{
		hit = null;
		blockLine = null;
		double z = mid.z - a.Height * 0.5;
		double keep = a.Pos.z;
		a.SetZ(clamp(z, a.floorz, max(a.floorz, a.ceilingz - a.Height)));
		// SetZ knows floors and ceilings, not things: coming down on a head (or up into a
		// belly) it would sink in. The vertical part is refused instead.
		zBlocked = false;
		if (a.Pos.z != keep && !a.TestMobjLocation())
		{
			a.SetZ(keep);
			zBlocked = true;
		}
		if (a.TryMove(mid.xy, 1)) return true;
		hit = a.BlockingMobj;
		blockLine = a.BlockingLine;
		for (int lift = 1; lift <= 3; lift++)
		{
			double tz = a.Pos.z + lift * 6.0;
			if (tz + a.Height > a.ceilingz) break;
			double was = a.Pos.z;
			a.SetZ(tz);
			if (a.TryMove(mid.xy, 1)) { hit = null; return true; }
			a.SetZ(was);
		}
		return false;
	}

	override void WorldTick()
	{
		double sc = RSQGR_Core.Scale();
		bool dbg = RSQGR_Util.Flag("rsqgr_debug", false);
		for (int s = 0; s < NFLY; s++)
		{
			if (fph[s] == FP_NONE) continue;
			let a = fa[s];
			if (!a || a.bDestroyed) { fph[s] = FP_NONE; fa[s] = null; continue; }
			if (!fby[s] || fby[s].bDestroyed) { if (fph[s] == FP_PATH) ToAir(s, "thrower gone"); }
			fage[s]++;
			bool alive = a.Health > 0;
			// held in its pain frame while thrown (another hit re-enters pain: re-held)
			if (alive && a.bISMONSTER && a.tics > 0) a.tics = -1;
			a.Vel = (0, 0, 0);

			Vector3 before = MidOf(a);
			if (fph[s] == FP_PATH) StepPath(s, a, sc);
			else StepAir(s, a, sc);
			if (fph[s] == FP_NONE || !fa[s]) continue;

			Vector3 now = MidOf(a);
			fpeak[s] = max(fpeak[s], now.z - ffrom[s].z);
			StepTumble(s, a, sc);
			if (dbg)
				Console.Printf("T_GRM %d %s ph=%d tt=%.2f/%.1f sc=%.2f mid=(%.1f %.1f %.1f) step=%.2f v=(%.2f %.2f %.2f) ang=%.0f roll=%.0f pitch=%.0f hp=%d",
					fage[s], a.GetClassName(), fph[s], ftt[s], fT[s], sc, now.x, now.y, now.z, (now - before).Length(),
					fv[s].x, fv[s].y, fv[s].z, a.Angle, a.Roll, a.Pitch, a.Health);
		}
	}

	private void StepPath(int s, Actor a, double sc)
	{
		ftt[s] = min(fT[s], ftt[s] + sc);
		double t = ftt[s] / max(1.0, fT[s]);
		double e = t ** 1.6;                                      // rsqdg_path_accel 1.6
		Vector3 land = fby[s] ? LandMid(s) : flast[s];
		Vector3 want = ffrom[s] + (land - ffrom[s]) * e;
		want.z += 4.0 * farc[s] * e * (1.0 - e);

		Vector3 was = MidOf(a);
		Actor hit;
		bool moved = PlaceMid(a, want, hit);
		Vector3 now = MidOf(a);
		// the authored velocity, per WORLD tic (a step of sc world tics just happened)
		fvPrev[s] = fv[s].Length();
		flastVz[s] = fv[s].z;
		if (sc > 0.0001) fv[s] = (now - was) / sc;
		flast[s] = now;

		if (!moved)
		{
			// Stopped by a wall or a thing. You, stepping into its landing: no harm.
			double sp = fv[s].Length();
			Vector3 tryV = (want - was) / max(sc, 0.0001);
			sp = max(sp, tryV.Length());
			if (hit != fby[s]) Impact(s, a, hit, sp, "struck");
			fv[s].x = 0; fv[s].y = 0; fv[s].z = min(fv[s].z, 0.0);   // stopped dead: it does not climb on
			if (fa[s]) ToAir(s, hit ? "blocked by a thing" : "blocked by a wall");
			return;
		}
		if (ftt[s] >= fT[s])
		{
			// Arrived. On the floor (a walker always is: the arc ends at e = 1 on it) it
			// lands now; a floater, or one whose landing spot is lower, carries on as air.
			if (!sNoGrav[s] && a.Pos.z > a.floorz + 0.5) { ToAir(s, "arrived above the floor"); return; }
			Land(s, a, "arrived");
		}
	}

	private void StepAir(int s, Actor a, double sc)
	{
		Vector3 v = fv[s];
		if (sNoGrav[s])
		{
			v *= 0.85 ** sc;                                      // a floater coasts and hovers
			if (v.Length() < 0.3) { fv[s] = v; Land(s, a, "hovering"); return; }
		}
		// EXACT for any step size (x = v t - g t^2 / 2, then v -= g t), so a quarter-speed
		// world draws the very same parabola in four times as many steps.
		double g = 0;
		if (!sNoGrav[s] && a.Pos.z > a.floorz + 0.01)
			g = Grav(a) * RSQGR_Util.Num("rsqgr_yank_air", 0.27);   // rsqdg_air_gravity
		Vector3 want = MidOf(a) + v * sc - (0, 0, 0.5 * g * sc * sc);
		v.z -= g * sc;
		Actor hit;
		Vector3 was = MidOf(a);
		bool moved = PlaceMid(a, want, hit);
		if (!moved)
		{
			double sp = v.xy.Length();
			if (hit != fby[s] && sp > 2.0) Impact(s, a, hit, sp, "struck in the air");
			if (!fa[s]) return;
			v.x = 0; v.y = 0;
		}
		// the ceiling stops the climb, the floor ends it
		if (v.z > 0 && a.Pos.z + a.Height >= a.ceilingz - 0.01) v.z = 0;
		// Come down on something (your head, another monster): it does not sit there --
		// it is pushed off sideways, away from the middle of what it is on, and falls.
		if (zBlocked && v.z < 0)
		{
			v.z = 0;
			Actor under = null;
			let it = BlockThingsIterator.Create(a, 8);
			while (it.Next())
			{
				let t = it.thing;
				if (t == a || !t.bSOLID || t.bNOBLOCKMAP) continue;
				if (abs(t.Pos.z + t.Height - a.Pos.z) > 12) continue;
				if ((t.Pos.xy - a.Pos.xy).Length() > t.Radius + a.Radius) continue;
				under = t;
				break;
			}
			Vector2 off = under ? a.Pos.xy - under.Pos.xy : (fby[s] ? a.Pos.xy - fby[s].Pos.xy : (1, 0));
			if (off.Length() < 0.01) off = (cos(a.Angle), sin(a.Angle));
			// just enough to clear it in four world tics
			double need = under ? max(1.0, under.Radius + a.Radius + 1.0 - (a.Pos.xy - under.Pos.xy).Length()) : 4.0;
			v.xy = off.Unit() * (need / 4.0);
			if (RSQGR_Util.Flag("rsqgr_debug", false))
				Console.Printf("T_GRM on top of %s: pushed off", under ? under.GetClassName() : 'something');
		}
		fv[s] = v;
		if (!sNoGrav[s] && a.Pos.z <= a.floorz + 0.01 && v.z <= 0) Land(s, a, "fell");
	}

	// Damage from speed, to it and half to what it hit. Everything borrowed goes back
	// first: a death here must leave a corpse that falls and behaves as one.
	private void Impact(int s, Actor a, Actor hit, double speed, String why)
	{
		int dmg = Damage(speed);
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRM impact %s (%s) speed %.1f dmg %d%s", a.GetClassName(), why, speed, dmg,
				hit ? String.Format(" -> %s %d", hit.GetClassName(), dmg / 2) : (blockLine ? String.Format(" (line %d)", blockLine.Index()) : " (nothing named)"));
		if (dmg <= 0) return;
		let src = fby[s];
		if (hit && hit.bSHOOTABLE && hit != src) hit.DamageMobj(null, src, max(1, dmg / 2), 'Melee');
		if (!a) return;
		a.DamageMobj(null, src, dmg, 'Melee');
	}

	static int Damage(double speed)
	{
		if (RSQGR_Util.Opt("rsqgr_yank_damage", 1) == 0) return 0;
		return clamp(int((speed - 8.0) * 0.8), 0, 40);
	}

	private void Land(int s, Actor a, String why)
	{
		double speed = max(fv[s].Length(), fph[s] == FP_PATH ? fvPrev[s] : 0.0);
		double down = -fv[s].z;
		if (fph[s] == FP_PATH) down = max(down, -flastVz[s]);
		let src = fby[s];
		bool dbg = RSQGR_Util.Flag("rsqgr_debug", false);
		Restore(s);
		// overlapping a thing after the last vertical move: nudge out (8 tries round it)
		if (!a.TestMobjLocation())
		{
			Vector2 c = a.Pos.xy;
			bool ok = false;
			for (int k = 0; k < 8 && !ok; k++)
			{
				double an = k * 45.0;
				ok = a.TryMove(c + (cos(an), sin(an)) * (a.Radius + 4), 1) && a.TestMobjLocation();
			}
			if (dbg) Console.Printf("T_GRM overlap at landing -> %s", ok ? "nudged out" : "left (nothing free)");
		}
		if (a.bISMONSTER && a.Health > 0)
		{
			if (src) a.Angle = a.AngleTo(src);
			a.tics = max(1, RSQGR_Util.Opt("rsqgr_yank_stun", 8));
		}
		int dmg = sNoGrav[s] ? 0 : Damage(max(down, speed * 0.5));
		if (dbg)
			Console.Printf("T_GRM land %s (%s) after %d tics speed %.1f down %.1f peak %.1f dmg %d at (%.1f %.1f %.1f) floorz %.1f fits %d",
				a.GetClassName(), why, fage[s], speed, down, fpeak[s], dmg, a.Pos.x, a.Pos.y, a.Pos.z, a.floorz, a.TestMobjLocation());
		if (dmg > 0) a.DamageMobj(null, src, dmg, 'Melee');
	}

	// Put back everything borrowed, and free the slot.
	private void Restore(int s)
	{
		let a = fa[s];
		if (a)
		{
			a.bNOGRAVITY = sNoGrav[s];
			a.bNOBLOCKMONST = sNoBlockMon[s];
			a.bROLLSPRITE = sRollSpr[s];
			a.bROLLCENTER = sRollCtr[s];
			a.bINTERPOLATEANGLES = sInterp[s];
			a.Roll = sRoll[s];
			a.Pitch = sPitch[s];
			a.WorldOffset = sOfs[s];
			if (sVoxel[s]) a.ClearModelFlag(MDL_USEACTORPITCH);
			a.Vel = (0, 0, 0);
			if (a.bISMONSTER && a.Health > 0 && a.tics < 0) a.tics = 1;
		}
		fa[s] = null;
		fby[s] = null;
		fph[s] = FP_NONE;
		fline[s] = false;
		sVoxel[s] = false;
	}

	// A constant rate in world time: the path's turns over the path's length. In the air
	// it carries on at that rate -- the spin to its last whole turn plus the facing, the
	// flip to its next whole turn -- and then holds, so it never snaps round on landing.
	private void StepTumble(int s, Actor a, double sc)
	{
		if (tSpin[s] == 0 && tFlip[s] == 0) return;
		double rate = sc / max(1.0, fT[s]);
		ftum[s] = (fph[s] == FP_PATH) ? ftt[s] / max(1.0, fT[s]) : ftum[s] + rate;
		if (tSpin[s] != 0) a.Angle = sAngle[s] + tSpin[s] * min(1.0, ftum[s]);
		if (tFlip[s] != 0)
		{
			double turn = tFlip[s] * ftum[s];
			if (fph[s] != FP_PATH) turn = min(turn, 360.0 * ceil(turn / 360.0 - 0.0001));
			double before = sVoxel[s] ? a.Pitch : a.Roll;
			if (sVoxel[s])
			{
				// end over end for a voxel is PITCH (about its side axis, as you see it come)
				a.Pitch = sPitch[s] + turn;
				a.WorldOffset = sOfs[s] + RSQGR_Turn.Fix(a, a.Height * 0.5, true, 0, (before + a.Pitch) * 0.5);
			}
			else a.Roll = sRoll[s] + turn;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int s = 0; s < NFLY; s++) if (fph[s] != FP_NONE) Restore(s);
	}
}

// WHERE A TURNED VOXEL'S MIDDLE GOES, AND THE OFFSET THAT PUTS IT BACK (DG's RSQDG_Turn,
// with the pitch passed in). models.cpp turns a model about its origin: yaw, then pitch
// (-pitch about its side axis) when UseActorPitch, then roll when UseActorRoll. A KVX
// voxel's origin is its pivot; BD_VoxelPack puts it at the bottom of every voxel
// (measured), so turning one swings it about its feet. Fix returns the WorldOffset
// (render-only) that keeps a point `u` units above the origin where it was.
// TO CHECK WITH CHEELLO'S VOXELS: where their pivots are. At the feet this is right;
// at the middle the offset should be zero (and this would move it off by u).
class RSQGR_Turn
{
	static Vector3 Fix(Actor a, double u, bool usePitch, double roll, double pitch)
	{
		double r = roll;
		double pt = usePitch ? -pitch : 0.0;
		double ya = a.Angle;
		double y0 = u * cos(r), z0 = -u * sin(r);
		double x1 = -y0 * sin(pt), y1 = y0 * cos(pt), z1 = z0;
		double wx = x1 * cos(ya) - z1 * sin(ya);
		double wy = x1 * sin(ya) + z1 * cos(ya);
		return (-wx, -wy, u - y1);
	}
}

// WHICH THINGS ARE DRAWN AS VOXELS (DG's RSQDG_Voxels, unchanged in substance): read
// from the same data the engine reads, once -- every VOXELDEF `sprite = "lump"` key and
// every lump in the voxels/ namespace -- kept as (SpriteID, frame) pairs.
class RSQGR_Voxels : StaticEventHandler
{
	private Array<int> sprites;
	private Array<int> frames;
	private bool built;

	static bool Drawn(Actor a)
	{
		if (!a) return false;
		let me = RSQGR_Voxels(StaticEventHandler.Find("RSQGR_Voxels"));
		if (!me) return false;
		if (!me.built) me.Build();
		int s = a.sprite, f = a.frame;
		for (int i = 0; i < me.sprites.Size(); i++)
			if (me.sprites[i] == s && (me.frames[i] == f || me.frames[i] < 0)) return true;
		return false;
	}

	override void WorldLoaded(WorldEvent e) { if (!built) Build(); }

	private void Add(String key)
	{
		if (key.Length() < 4) return;
		key = key.MakeUpper();
		int f = -1;
		if (key.Length() >= 5)
		{
			f = key.ByteAt(4) - 65;
			if (f < 0 || f > 28) return;
		}
		int s = Actor.GetSpriteIndex(key.Left(4));
		if (s <= 0) return;
		for (int i = 0; i < sprites.Size(); i++)
			if (sprites[i] == s && frames[i] == f) return;
		sprites.Push(s);
		frames.Push(f);
	}

	private void Build()
	{
		built = true;
		int n = Wads.GetNumLumps();
		for (int i = 0; i < n; i++)
			if (Wads.GetLumpNamespace(i) == Wads.ns_voxels)
				Add(Wads.GetLumpName(i));
		int lump = -1;
		while ((lump = Wads.FindLump("VOXELDEF", lump + 1)) >= 0)
		{
			String txt = Wads.ReadLump(lump);
			Array<String> lines;
			txt.Split(lines, "\n");
			int depth = 0;
			for (int k = 0; k < lines.Size(); k++)
			{
				String ln = lines[k];
				int c = ln.IndexOf("//");
				if (c >= 0) ln = ln.Left(c);
				if (depth == 0)
				{
					int eq = ln.IndexOf("=");
					if (eq > 0)
					{
						String keys = ln.Left(eq);
						keys.Replace("\"", " ");
						keys.Replace(",", " ");
						keys.Replace("\t", " ");
						Array<String> parts;
						keys.Split(parts, " ", TOK_SKIPEMPTY);
						for (int q = 0; q < parts.Size(); q++) Add(parts[q]);
					}
				}
				for (int j = 0; j < ln.Length(); j++)
				{
					int ch = ln.ByteAt(j);
					if (ch == 123) depth++;
					else if (ch == 125 && depth > 0) depth--;
				}
			}
		}
	}
}
