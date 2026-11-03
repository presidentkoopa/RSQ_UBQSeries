// swing.zs -- THE AIMED SWING ANCHOR (owner, approved 2026-11-03).
//
// While the whip weapon is in hand, the OTHER hand's alt-fire (the off hand's, with the whip in the main hand) casts
// an aim ray from that hand: a thin dotted line and the series' diamond where the whip would anchor -- gold when it
// may (a wall or a ceiling within Whip Swing Reach), red when it may not (out of reach, sky, a floor, a portal, a
// 3D middle texture, a polyobject). With the ray on a valid spot, the whip hand's own deliberate crack (wind-up and
// swing, unchanged) sends the whip there: it stretches out to the spot as a marked crack flies (Reach), latches,
// gives a small hop if you are standing, and from then it is the rope every snag becomes (core.zs: pendulum, reel,
// pump, climb, let go, momentum kept).
//
// Anchor (surveys/05_GRAPPLE_ROPES.md 3.1): the trace gives no normal, so it is rebuilt -- a ceiling's from its
// plane, a wall's from its line (right-hand normal of the front side, negated on the back) -- and then pointed
// toward the hand (the survey asks for the sign to be checked: both are logged). The anchor sits SWING_OFF map units
// off the surface along it, so the rope never pulls into the geometry. Ceilings follow their plane (a lift, a
// crusher: core.UpdateAnchor); walls are re-checked every 4 tics, traced along the normal into the face.
// Refused (survey 5.5, 5.7): sky (a ceiling of the sky flat, or a two-sided line's upper part between two sky
// ceilings), any portal on the way (FLineTraceData.NumPortals, a line portal hit), floors, 3D middle textures and
// polyobjects (their line's normal may not be the drawn face).
//
// Netplay: like the mark (Mark), the aim reads the local hand pose in play; single player is exact.
extend class RSQWP_Whip
{
	const SWING_OFF = 4.0;       // the anchor this far off the surface, along its normal (map units)
	const SWING_HOP = 6.0;       // a standing player is lifted this much on the latch (map units a tic; a jump is 8)
	const AIM_GRACE = 6;         // the aim let go this many tics before the crack still casts (~0.17 s)
	const AIM_STEP = 10.0;       // the dotted ray: a dot every this many map units ...
	const AIM_FROM = 6.0;        // ... from this far out of the hand
	const AIM_RED = 0xFF4030;    // the refused ray (the colour-blind palette's IDLE role takes it over)

	bool    aimHeld[NW];         // the other hand's alt-fire is held (weapon.zs Tend: the button, or the eaten key)
	int     aimTic[NW];          // the tic Tend last said so
	bool    aimBtn[MAXPLAYERS];  // that key, eaten in InputProcess so the gun in that hand does not alt-fire too
	bool    aimShown[NW];
	bool    aimOk[NW];           // this tic's ray ends on an anchor
	Name    aimWhy[NW];          // what it hit: 'ceiling', 'wall', or why not
	Vector3 aimEnd[NW];          // where the ray ends (map)
	double  aimM[NW];            // how far, metres
	// the last valid anchor (cast within AIM_GRACE of letting the button go)
	int     okTic[NW];
	Vector3 okAt[NW], okHit[NW], okN[NW];
	Sector  okSec[NW];
	int     okPlane[NW];         // 2 a ceiling that follows its plane, 0 a wall (or a 3D floor's underside)
	// the cast under way (Reach) and the anchor it flies to
	bool    casting[NW];
	Vector3 castAt[NW], castHit[NW], castN[NW];
	Sector  castSec[NW];
	int     castPlane[NW];
	bool    outNow[NW];          // the next Start leaves the thong out (a chain: it comes straight off the rope)
	RSQWP_LockRing aimRing[NW];
	RSQWP_LockCentre aimCen[NW];

	// Whip Swing Reach, as map units of straight-line distance (34 room units a metre; RSQWP_Util.Metres)
	static double SwingReachM() { return clamp(RSQWP_Util.Num("rsqwp_swing_reach", 9), 3.0, 20.0); }

	// ---- the aim, every tic -----------------------------------------------------------------------------------

	void AimTick(int i)
	{
		int pn = i / 2;
		int hand = i & 1;
		let pmo = playeringame[pn] ? players[pn].mo : null;
		bool on = pmo && pmo.Health > 0 && aimHeld[i] && level.maptime - aimTic[i] <= 1
			&& RSQWP_Util.Flag("rsqwp_swing", true) && RSQWP_Util.Flag("rsqwp_on", true);
		if (!on)
		{
			if (aimShown[i]) ClearAim(i);
			aimOk[i] = false;
			if (pmo && level.maptime - aimTic[i] > 1) aimBtn[pn] = false;   // the weapon is gone: no key stays held
			return;
		}
		int ah = 1 - hand;
		Vector3 org = RSQWP_Util.AimPos(pmo, ah);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.AimYaw(pmo, ah), RSQWP_Util.AimPitch(pmo, ah));
		double ps = RSQWP_Util.PS();
		double roomPerMap = sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * ps * dir.z * ps);   // room units per map unit along dir
		double maxL = SwingReachM() * 34.0 / max(0.01, roomPerMap);
		FLineTraceData d;
		pmo.LineTrace(atan2(dir.y, dir.x), maxL, -asin(clamp(dir.z, -1.0, 1.0)), TRF_ABSPOSITION | TRF_THRUACTORS, org.z, org.x, org.y, d);
		Name why = 'none';
		Vector3 n = (0, 0, 0);
		int plane = 0;
		Vector3 hit = d.HitLocation;
		double nSurvey = 0;
		if (d.NumPortals > 0) why = 'portal';
		else if (d.HitType == TRACE_HitNone) { why = 'out of reach'; hit = org + dir * maxL; }
		else if (d.HitType == TRACE_HitFloor) why = 'floor';
		else if (d.HitType == TRACE_HitCeiling)
		{
			if (!d.Hit3DFloor && d.HitSector && d.HitSector.GetTexture(Sector.ceiling) == skyflatnum) why = 'sky';
			else
			{
				why = 'ceiling';
				n = d.Hit3DFloor ? (0, 0, -1) : (d.HitSector ? d.HitSector.ceilingplane.Normal : (0, 0, -1));
				plane = (!d.Hit3DFloor && d.HitSector) ? 2 : 0;
			}
		}
		else if (d.HitType == TRACE_HitWall && d.HitLine)
		{
			Line l = d.HitLine;
			bool skyWall = l.frontsector && l.backsector && d.LinePart == 0
				&& l.frontsector.GetTexture(Sector.ceiling) == skyflatnum && l.backsector.GetTexture(Sector.ceiling) == skyflatnum;
			if (l.isLinePortal()) why = 'portal';
			else if (skyWall) why = 'sky';
			else if ((l.sidedef[0] && (l.sidedef[0].Flags & Side.WALLF_POLYOBJ)) || (l.sidedef[1] && (l.sidedef[1].Flags & Side.WALLF_POLYOBJ))) why = 'polyobject';
			else if ((l.flags & Line.ML_3DMIDTEX) && d.LinePart == 1 && !d.Hit3DFloor) why = '3D midtex';
			else
			{
				why = 'wall';
				Vector2 dl = l.delta.Unit();
				n = (dl.y, -dl.x, 0);              // the front side's normal (survey 3.1) ...
				if (d.LineSide == Line.back) n = -n;   // ... negated on the back
			}
		}
		else why = 'no surface';
		bool ok = why == 'ceiling' || why == 'wall';
		Vector3 at = hit;
		if (ok)
		{
			// THE SIGN, checked (survey 3.1: "verify the sign empirically once"): the normal must face the hand
			Vector3 back = org - hit;
			nSurvey = n dot back;
			if (nSurvey < 0) n = -n;
			if (n.Length() < 0.5) { ok = false; why = 'no surface'; }
			else
			{
				n = n.Unit();
				at = hit + n * SWING_OFF;
				// the anchor must be in the open (a corner may leave the 4-unit step inside another face)
				Sector s = level.PointInSector(at.xy);
				if (!s || at.z <= s.floorplane.ZatPoint(at.xy) + 1 || at.z >= s.ceilingplane.ZatPoint(at.xy) - 1) { ok = false; why = 'no room'; }
			}
		}
		bool changed = ok != aimOk[i] || why != aimWhy[i];
		aimOk[i] = ok; aimWhy[i] = why; aimEnd[i] = ok ? at : hit;
		aimM[i] = RSQWP_Util.Metres(hit - org);
		if (ok)
		{
			okTic[i] = level.maptime; okAt[i] = at; okHit[i] = hit; okN[i] = n; okPlane[i] = plane;
			okSec[i] = d.HitSector;
		}
		if (changed && RSQWP_Util.Flag("rsqwp_debug", false))
		{
			if (ok) Console.Printf("T_WPW %d AIM t%d VALID %s at (%.0f %.0f %.0f) %.1f m, normal (%.2f %.2f %.2f) (survey's sign %s), anchor (%.0f %.0f %.0f)", i, level.maptime, why, hit.x, hit.y, hit.z, aimM[i], n.x, n.y, n.z, nSurvey >= 0 ? "faces the hand" : "flipped", at.x, at.y, at.z);
			else Console.Printf("T_WPW %d AIM t%d INVALID: %s (%.1f m, portals %d)", i, level.maptime, why, aimM[i], d.NumPortals);
		}
		DrawAim(i, org, ok, ok ? at : hit, dir);
	}

	// The ray: a thin dotted line of full-bright particles from the hand to where it ends (gold: the whip would
	// anchor there; red: it would not), and the series' diamond on the spot (gold ring and white centre) or a red
	// ring where a refused ray ends. Colour-blind palette: COULD / IDLE.
	void DrawAim(int i, Vector3 org, bool ok, Vector3 end, Vector3 dir)
	{
		aimShown[i] = true;
		int col = ok ? RSQWP_CB.Pick(RSQWP_CB.CB_COULD, RSQWP_LockRing.GOLD) : RSQWP_CB.Pick(RSQWP_CB.CB_IDLE, AIM_RED);
		Vector3 span = end - org;
		double len = span.Length();
		if (len > AIM_FROM)
		{
			Vector3 u = span / len;
			FSpawnParticleParams p;
			p.color1 = col;
			p.style = STYLE_Add;
			p.flags = SPF_FULLBRIGHT;
			p.lifetime = 1;
			p.size = 2.0;
			p.sizestep = 0;
			p.startalpha = ok ? 0.9 : 0.6;
			p.fadestep = 0;
			for (double t = AIM_FROM; t < len - 2; t += AIM_STEP)
			{
				p.pos = org + u * t;
				level.SpawnParticle(p);
			}
		}
		double sc = 0.35 * RSQWP_A11y.Cue() * clamp(RSQWP_Util.Metres(span) / 5.0, 1.0, 3.0) * (ok ? 1.0 : 0.6);
		if (!aimRing[i]) { aimRing[i] = RSQWP_LockRing(Actor.Spawn("RSQWP_LockRing", end, NO_REPLACE)); if (aimRing[i]) aimRing[i].ClearInterpolation(); }
		if (aimRing[i])
		{
			aimRing[i].SetOrigin(end, true);
			aimRing[i].scale = (sc, sc);
			aimRing[i].SetShade(col);
		}
		if (ok)
		{
			if (!aimCen[i]) { aimCen[i] = RSQWP_LockCentre(Actor.Spawn("RSQWP_LockCentre", end, NO_REPLACE)); if (aimCen[i]) aimCen[i].ClearInterpolation(); }
			if (aimCen[i]) { aimCen[i].SetOrigin(end, true); aimCen[i].scale = (sc, sc); }
		}
		else if (aimCen[i]) { aimCen[i].Destroy(); aimCen[i] = null; }
	}

	void ClearAim(int i)
	{
		aimShown[i] = false;
		if (aimRing[i]) aimRing[i].Destroy();
		if (aimCen[i]) aimCen[i].Destroy();
		aimRing[i] = null; aimCen[i] = null;
	}

	// ---- the cast ---------------------------------------------------------------------------------------------

	// Called first thing by a crack of the whip weapon. The ray held on a valid spot (or let go of within AIM_GRACE
	// with a valid spot): the thong flies there (Reach) and latches (SwingLatch). The ray held on a refused spot:
	// an ordinary crack, and the log says why.
	bool SwingCast(int i, PlayerPawn pmo, int hand, Vector3 at)
	{
		if (!byWeapon[i] || !RSQWP_Util.Flag("rsqwp_swing", true)) return false;
		bool held = aimHeld[i] && level.maptime - aimTic[i] <= 1;
		bool use = held ? aimOk[i] : (level.maptime - okTic[i] <= AIM_GRACE && okTic[i] > 0);
		if (!use)
		{
			if (held && RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d CAST t%d refused: %s (%.1f m) -- an ordinary crack", i, level.maptime, aimWhy[i], aimM[i]);
			return false;
		}
		castAt[i] = okAt[i]; castHit[i] = okHit[i]; castN[i] = okN[i]; castSec[i] = okSec[i]; castPlane[i] = okPlane[i];
		casting[i] = true;
		okTic[i] = -100;                // one cast per aim
		reachFor[i] = null;
		reachPt[i] = castAt[i];
		Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
		double dist = (castAt[i] - h0).Length();
		reachTic[i] = clamp(int(dist / 64.0 + 0.5), REACH_TICS, 8);
		lockLeft[i] = 0; lockOn[i] = null; lockLine[i] = false; lock2[i] = null; reach2[i] = null;
		Noise(pmo, 'crack', at, i);
		Buzz(pmo, hand, 1.0, 5);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d CAST #%d t%d -> %s anchor (%.0f %.0f %.0f), %.1f m, flies %d tics", i, cracks[i], level.maptime,
				castPlane[i] == 2 ? "ceiling" : "wall", castAt[i].x, castAt[i].y, castAt[i].z, RSQWP_Util.Metres(castAt[i] - h0), reachTic[i]);
		return true;
	}

	// The thong reached the aimed spot: core's hook, built as Snag builds it, at the anchor off the surface. A
	// ceiling follows its plane; a wall (or a 3D floor's underside) is re-checked along the normal into the face.
	void SwingLatch(int i, PlayerPawn pmo, int hand)
	{
		let core = RSQWP_Core.Get();
		if (!core) return;
		let old = core.hooks[i];
		if (old)
		{
			if (old.phase != RSQWP_Hook.PH_RETRACT) return;
			old.Destroy(); core.hooks[i] = null;
		}
		Vector3 at = castAt[i];
		let h = RSQWP_Hook(Actor.Spawn("RSQWP_Hook", at, NO_REPLACE));
		if (!h) return;
		Vector3 hand0 = RSQWP_Util.HandPos(pmo, hand);
		Vector3 ldir = (at - hand0).Unit();
		h.owner = pmo;
		h.hand = hand;
		h.dir = ldir;
		h.speed = max(4.0, RSQWP_Util.Num("rsqwp_speed", 40));
		h.range = max(max(64.0, RSQWP_Util.Num("rsqwp_range", 1024)), SwingReachM() * 34.0);
		h.angle = atan2(ldir.y, ldir.x);
		h.traveled = (at - hand0).Length();
		h.anchor = at;
		h.hitDir = -castN[i];           // into the face: core's wall check traces from struck along it
		h.SetOrigin(at, true);
		// A WALL: the arc's bottom is straight under the anchor, so an anchor 4 units off the face would hang the body
		// inside the wall's reach (rig: the swing ran into the wall at the bottom and died there). The rope's point is
		// put the body's radius further out; the rope is still drawn to the face (the hook's place).
		if (castPlane[i] != 2 && abs(castN[i].z) < 0.5)
		{
			h.anchor = castHit[i] + castN[i] * (pmo.radius + SWING_OFF);
			h.SetOrigin(castHit[i] + castN[i] * 1.0, true);
		}
		h.anchorSec = castSec[i];
		h.anchorPlane = 0;
		if (castPlane[i] == 2 && castSec[i])
		{
			h.anchorPlane = 2;
			h.planeOfs = at.z - castSec[i].ceilingplane.ZatPoint(at.xy);
		}
		h.whipped = true;
		h.aimed = true;
		h.launch = true;
		h.struck = castHit[i];          // on the face itself (core: struck - hitDir x 6 = 6 out, traced 16 in)
		core.hooks[i] = h;
		core.Latch(h, i);
		bool grounded = pmo.pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
		double hop = 0;
		if (h.phase == RSQWP_Hook.PH_LATCH)
		{
			// A SWING FROM THE GROUND: the arc's bottom must clear the floor under the anchor (feet and 8 units), or a
			// standing player only drags along it. Longer than that, the rope is taken up to it (core.Swing, at
			// TAKEUP a tic, as a reel), lifting him into the arc. Too low an anchor for any swing: no take-up.
			double attachH = pmo.Height * RSQWP_Util.Num("rsqwp_attach", 0.6);
			Vector3 an = h.anchor;
			Sector us = level.PointInSector(an.xy);
			double fz = us ? us.floorplane.ZatPoint(an.xy) : pmo.floorz;
			double want = an.z - fz - attachH - 8;
			double minLen = RSQWP_Util.Num("rsqwp_min_len", 32);
			h.autoLen = (want >= minLen && want < h.ropeLen - 1) ? want : 0;
			h.fullLen = h.autoLen > 0 ? 0 : h.ropeLen;
			if (grounded) { hop = SWING_HOP; pmo.vel.z = max(pmo.vel.z, hop); }
		}
		Noise(pmo, 'crack', at, i);
		Buzz(pmo, hand, 0.7, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d SWING LATCH t%d %s at (%.0f %.0f %.0f), rope %.0f, take-up to %.0f, hop %.0f, player (%.0f %.0f %.0f) vel (%.1f %.1f %.1f)", i, level.maptime,
				h.anchorPlane == 2 ? "ceiling" : "wall", h.anchor.x, h.anchor.y, h.anchor.z, h.ropeLen, h.autoLen, hop, pmo.pos.x, pmo.pos.y, pmo.pos.z, pmo.vel.x, pmo.vel.y, pmo.vel.z);
		Halt(i);
	}
}
