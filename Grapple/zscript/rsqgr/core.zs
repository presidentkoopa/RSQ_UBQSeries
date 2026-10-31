// RSQGR_Core -- one hook per hand per player, and everything they decide.
//
// WHEN. WorldTick runs after P_PlayerThink (the player's input thrust and friction
// are already in his velocity) and before the thinkers move anything (p_tick.cpp).
// So the rope is solved HERE, on the velocity the player is about to move by:
// whatever this writes is exactly what the engine's own movement then carries
// out, with its own collision. The player is never placed by position, so the
// rope can never put him inside a wall -- a wall simply stops him, as it would
// any other move.
//
// The engine moves first and applies gravity after (P_ZMovement: AddZ(Vel.Z), then
// FallAndSink), so the position the player will reach this tic is exactly
// pos + vel, and the rope's constraint is applied to that.
class RSQGR_Core : EventHandler
{
	const NHOOK = MAXPLAYERS * 2;
	// THE TAP WINDOW (owner's QoL pick GR8): a press released within rsqgr_tap_tics tics is a tap (let go); held
	// longer it reels. Was the constant 8; the default stays 8.
	static clearscope int TapTics() { return clamp(RSQGR_Util.Opt("rsqgr_tap_tics", 8), 1, 35); }

	RSQGR_Hook hooks[NHOOK];
	bool held[NHOOK];
	int pressTic[NHOOK];
	bool pressFired[NHOOK];   // this press fired the hook (holding it on = reel at once)
	double worldScale;
	transient RSQGR_Tracer tracer;

	clearscope static RSQGR_Core Get() { return RSQGR_Core(EventHandler.Find("RSQGR_Core")); }

	// The world's speed now (1 = not slowed). See RSQGR_Util.WorldScale.
	clearscope static double Scale()
	{
		let c = Get();
		return (c && c.worldScale > 0) ? c.worldScale : 1.0;
	}

	// The hook a hand of a player has out, if any (for the seam's other side).
	clearscope static RSQGR_Hook HookOf(PlayerPawn pmo, int hand)
	{
		let c = Get();
		if (!c || !pmo || !pmo.player) return null;
		int pn = pmo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS || (hand & ~1)) return null;
		return c.hooks[pn * 2 + hand];
	}

	RSQGR_Tracer GetTracer()
	{
		if (!tracer) tracer = new("RSQGR_Tracer");
		return tracer;
	}

	// ---- input ------------------------------------------------------------------

	void Press(int pn, int hand, Vector3 org, Vector3 dir)
	{
		if (!RSQGR_Util.Flag("rsqgr_on", true)) return;
		let pmo = players[pn].mo;
		if (!pmo || pmo.Health <= 0) return;
		int i = pn * 2 + hand;
		held[i] = true;
		pressTic[i] = level.maptime;
		pressFired[i] = false;
		let h = hooks[i];
		if (h && h.phase != RSQGR_Hook.PH_RETRACT && h.phase != RSQGR_Hook.PH_HOLD)
		{
			if (h.phase == RSQGR_Hook.PH_FLY) LetGo(h, false);   // recall a miss
			// latched / biting: this press is a tap (let go) or a hold (reel)
			return;
		}
		if (h) { h.Destroy(); hooks[i] = null; }
		Fire(pmo, pn, hand, org, dir);
		pressFired[i] = true;
	}

	void Release(int pn, int hand)
	{
		int i = pn * 2 + hand;
		bool wasHeld = held[i];
		held[i] = false;
		let h = hooks[i];
		if (!h || !wasHeld || pressFired[i]) return;
		if (level.maptime - pressTic[i] <= TapTics()
			&& (h.phase == RSQGR_Hook.PH_LATCH || h.phase == RSQGR_Hook.PH_BITE))
			LetGo(h, true);
	}

	// ---- fire -------------------------------------------------------------------

	void Fire(PlayerPawn pmo, int pn, int hand, Vector3 org, Vector3 dir)
	{
		// A hand pushed through a wall would fire from behind it: if the line from the
		// eye to the hand is blocked, the claw starts at the eye instead.
		Vector3 eye = pmo.Pos + (0, 0, pmo.player.viewz - pmo.Pos.z);
		Vector3 toHand = org - eye;
		double th = toHand.Length();
		if (th > 0.5)
		{
			let tr = GetTracer();
			tr.shooter = pmo;
			if (tr.Trace(eye, level.PointInSector(eye.xy), toHand / th, th, 0, RSQGR_Tracer.WALLMASK, true, pmo)
				&& tr.Results.HitType != TRACE_HitNone)
				org = eye;
		}

		let h = RSQGR_Hook(Actor.Spawn("RSQGR_Hook", org, NO_REPLACE));
		if (!h) return;
		h.owner = pmo;
		h.hand = hand;
		h.dir = dir;
		h.speed = max(4.0, RSQGR_Util.Num("rsqgr_speed", 40)) * RSQGR_Perks.Factor(pmo, 'reel');     // Fast Reel (perks.zs)
		h.range = max(64.0, RSQGR_Util.Num("rsqgr_range", 1024)) * RSQGR_Perks.Factor(pmo, 'range'); // Long Line
		h.angle = atan2(dir.y, dir.x);
		h.SetPhase(RSQGR_Hook.PH_FLY);
		hooks[pn * 2 + hand] = h;

		String s = RSQGR_Looks.Sound('fire');
		if (s != "") h.A_StartSound(s, CHAN_WEAPON);
		s = RSQGR_Looks.Sound('loop');
		if (s != "") h.A_StartSound(s, CHAN_BODY, CHANF_LOOPING, 0.6);
		Log(h, "fire");
	}

	// ---- let go -----------------------------------------------------------------

	void LetGo(RSQGR_Hook h, bool byPlayer)
	{
		if (!h) return;
		// the coast is for a FLIGHT the rope gave (let go in the air, or while it was moving him): a let-go
		// standing on the floor -- a monster pulled in, a slack rope -- leaves the stick's own feel alone
		// (not a Split Pull's arrival on the floor: rig, it left the walk slow for the 18 coast tics)
		if (h.owner && h.owner.player && RopeFlew(h.owner)) coastUntil[h.owner.PlayerNumber()] = level.maptime + COAST_TICS;
		RSQGR_Perks.OnLetGo(h, byPlayer);   // Barbed Claw's tear, Slingshot (perks.zs)
		if (h.phase == RSQGR_Hook.PH_BITE && h.victim && h.owner && !h.heavy)
			RSQGR_Monster.OnRelease(h.victim, h.owner, h.hand);
		// A hop off the top: let go within reach of a wall's latch while reeling and the
		// player gets a small lift -- enough to get a foot over a ledge.
		if (byPlayer && h.phase == RSQGR_Hook.PH_LATCH && h.owner && h.anchorPlane == 0 && !h.heavy)
		{
			double hop = RSQGR_Util.Num("rsqgr_hop", 6);
			Vector3 b = AttachPoint(h.owner);
			if (hop > 0 && (h.anchor - b).Length() < RSQGR_Util.Num("rsqgr_min_len", 32) + 24 && h.anchor.z > h.owner.Pos.z)
				h.owner.vel.z = max(h.owner.vel.z, hop);
		}
		h.victim = null;
		h.SetPhase(RSQGR_Hook.PH_RETRACT);
		Log(h, byPlayer ? "letgo" : "drop");
	}

	void Drop(int i)
	{
		let h = hooks[i];
		if (h) LetGo(h, false);
	}

	// ---- the tic ----------------------------------------------------------------

	double tickMs;   // last WorldTick's cost (rsqgr_debug)

	// Not saved: after a load (or on a new map) it reads false on the first tic.
	transient bool settled;

	// THE FIRST TIC AFTER A LOAD. WorldLoaded runs before a saved handler's fields are
	// read back (rig: a hold reset there came back from the save and kept climbing), so
	// the reset is done here, on the first tic this handler object has not seen: no
	// bind reads as held (a release that happened before the save never comes), no hand
	// holds the rope, no streamed pose is fresh.
	void Settle()
	{
		settled = true;
		for (int i = 0; i < NHOOK; i++)
		{
			held[i] = false; pressFired[i] = false; grabHeld[i] = false; wantGrip[i] = false; poseTic[i] = -100;
			if (hooks[i]) hooks[i].ClearGrips();
		}
	}

	override void WorldTick()
	{
		double t0 = MSTimeF();
		if (!settled) Settle();
		worldScale = RSQGR_Util.WorldScale();
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			for (int hand = 0; hand < 2; hand++)
			{
				int i = pn * 2 + hand;
				let h = hooks[i];
				if (!h) continue;
				if (h.bDestroyed) { hooks[i] = null; continue; }
				if (!pmo || h.owner != pmo) { h.Destroy(); hooks[i] = null; continue; }
				if (pmo.Health <= 0 && h.phase != RSQGR_Hook.PH_RETRACT) { LetGo(h, false); continue; }
				if (h.phase == RSQGR_Hook.PH_RETRACT) continue;
				if (h.phase == RSQGR_Hook.PH_FLY) Fly(h, i);
				else if (h.phase == RSQGR_Hook.PH_BITE) Bite(h, i);
				else if (h.phase == RSQGR_Hook.PH_HOLD) { if (h.phaseAge >= 16) LetGo(h, false); }
			}
			if (pmo && pmo.Health > 0) Swing(pmo, pn);
			if (pmo && pmo.Health > 0 && RSQGR_A11y.Vignette() > 0) Comfort(pmo, pn);
		}
		AimDot();
		tickMs = MSTimeF() - t0;
	}

	// ---- the aim dot (owner's QoL option GR6, rsqgr_aim_dot) ----------------------
	// A faint dot where the claw would bite, for THIS machine's player only (a particle: nothing in the
	// world, nothing synced), while a hand is empty (the climb's free-hand test, always strict here), has no
	// hook out, and points: its pose is real and the hand is held out at least DOT_REACH units ahead of the
	// body. The same trace the claw flies (Fly: RSQGR_Tracer, WALLMASK, monsters it can bite), to its range.
	const DOT_REACH = 8.0;   // ~0.24 m (34 units a metre)
	void AimDot()
	{
		if (!RSQGR_Util.Flag("rsqgr_aim_dot", false) || !RSQGR_Util.Flag("rsqgr_on", true)) return;
		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.Health <= 0) return;
		let pmo = p.mo;
		for (int hand = 0; hand < 2; hand++)
		{
			if (hooks[consoleplayer * 2 + hand] || !RSQGR_Util.PoseGood(pmo, hand) || !RSQGR_Climb.HandFree(pmo, hand, true)) continue;
			Vector3 org = RSQGR_Util.HandPos(pmo, hand);
			Vector2 fwd = Actor.AngleToVector(pmo.Angle, 1);
			Vector3 rel = org - pmo.Pos;
			if ((rel.xy dot fwd) < DOT_REACH) continue;
			Vector3 dir = RSQGR_Util.MapDir(RSQGR_Util.HandYaw(pmo, hand), RSQGR_Util.HandPitch(pmo, hand));
			double range = max(64.0, RSQGR_Util.Num("rsqgr_range", 1024)) * RSQGR_Perks.Factor(pmo, 'range');
			let tr = GetTracer();
			tr.shooter = pmo;
			if (!tr.Trace(org, level.PointInSector(org.xy), dir, range, TRACE_HitSky, RSQGR_Tracer.WALLMASK, false, pmo)) continue;
			int ht = tr.Results.HitType;
			if (ht == TRACE_HitNone || ht == TRACE_HasHitSky || ht == TRACE_CrossingPortal) continue;
			FSpawnParticleParams pp;
			pp.color1 = ht == TRACE_HitActor ? 0xFFC8A0 : 0xE8F0FF;
			pp.style = STYLE_Add;
			pp.flags = SPF_FULLBRIGHT;
			pp.lifetime = 2;
			pp.size = 4;
			pp.startalpha = 0.35;
			pp.fadestep = 0;
			pp.pos = tr.Results.HitPos - dir * 2;
			level.SpawnParticle(pp);
			if (RSQGR_Util.Opt("rsqgr_debug", 0) >= 1 && level.maptime % 5 == 0)
				Console.Printf("T_GR t%d h%d aim dot at (%.1f %.1f %.1f) on %s, %.0f units", level.maptime, hand, pp.pos.x, pp.pos.y, pp.pos.z,
					ht == TRACE_HitActor ? "a monster" : "geometry", tr.Results.Distance);
		}
	}

	// RSQ_Accessibility's Comfort Vignette: a swing in the air, a reel, a climb or a yank is a
	// comfort moment, as strong as the body is moving fast (0.35 at rest on the rope, full at
	// rsqgr_max_speed). Standing on the ground with the rope slack is not.
	void Comfort(PlayerPawn pmo, int pn)
	{
		double k = 0;
		for (int hand = 0; hand < 2; hand++)
		{
			let h = hooks[pn * 2 + hand];
			if (!h) continue;
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			if (h.phase == RSQGR_Hook.PH_HOLD || (h.phase == RSQGR_Hook.PH_LATCH && (!grounded || h.reelHeld || h.gripHand >= 0)))
				k = 1;
		}
		if (k <= 0) return;
		double top = max(1.0, RSQGR_Util.Num("rsqgr_max_speed", 30));
		RSQGR_A11y.Comfort(pmo, clamp(0.35 + 0.65 * pmo.vel.Length() / top, 0.35, 1.0));
	}

	// ---- flight -----------------------------------------------------------------

	void Fly(RSQGR_Hook h, int i)
	{
		double step = min(h.speed, h.range - h.traveled);
		if (step <= 0) { LetGo(h, false); return; }
		let tr = GetTracer();
		tr.shooter = h.owner;
		Vector3 p = h.Pos;
		bool hit = tr.Trace(p, level.PointInSector(p.xy), h.dir, step, TRACE_HitSky, RSQGR_Tracer.WALLMASK, false, h.owner);
		int ht = tr.Results.HitType;
		if (!hit || ht == TRACE_HitNone || ht == TRACE_CrossingPortal)
		{
			h.SetOrigin(p + h.dir * step, true);
			h.traveled += step;
			return;
		}
		if (ht == TRACE_HasHitSky) { h.SetOrigin(tr.Results.HitPos - h.dir * 2, true); LetGo(h, false); return; }

		Vector3 at = tr.Results.HitPos;
		h.traveled += tr.Results.Distance;
		if (ht == TRACE_HitActor)
		{
			let v = tr.Results.HitActor;
			h.SetOrigin(at, true);
			h.victim = v;
			Vector3 ofs = at - v.Pos;
			ofs.xy = ofs.xy.Length() > v.radius ? ofs.xy.Unit() * v.radius : ofs.xy;
			ofs.z = clamp(ofs.z, 0, v.Height);
			h.victimOfs = ofs;
			h.heavy = TooHeavy(h, v);
			String s = RSQGR_Looks.Sound('hitflesh');
			if (s != "") h.A_StartSound(s, CHAN_VOICE);
			RSQGR_Looks.Spark(at, 'flesh');
			if (h.heavy)
			{
				h.anchor = v.Pos + h.victimOfs;
				Latch(h, i);
			}
			else
			{
				Vector3 dv = v.Pos - h.owner.Pos;
				h.bestDist = dv.xy.Length();
				h.noProgress = 0;
				h.SetPhase(RSQGR_Hook.PH_BITE);
				RSQGR_Monster.OnHooked(v, h.owner, h.hand, at);
				Log(h, "bite");
				Thump(h, "bite");
			}
			RSQGR_Events.Bitten(h.owner, v, h.hand, h.heavy);   // service.zs: for other mods to read
			RSQGR_Perks.OnBite(h, v);   // perks.zs: Gun Bonsai patch upgrades + XP ledger
			return;
		}

		// HOOK A SWITCH OR A DOOR (owner's QoL option GR5, rsqgr_use_lines): a wall with a special the player could
		// USE is used, from range, by the engine's own Line.Activate (SPAC_Use, as P_UseLines would with the player
		// as the activator: keys, locks and messages are the engine's), and the claw comes back instead of biting
		if (ht == TRACE_HitWall && UseLine(h, tr.Results.HitLine, tr.Results.Side, at)) return;

		// geometry: wall, floor, ceiling, 3D floor side or plane
		h.anchor = at - h.dir * 1.0;
		h.hitDir = h.dir;
		h.SetOrigin(h.anchor, true);
		h.anchorSec = tr.Results.HitSector;
		h.anchorPlane = 0;
		if (!tr.Results.ffloor && h.anchorSec)
		{
			if (ht == TRACE_HitCeiling) { h.anchorPlane = 2; h.planeOfs = h.anchor.z - h.anchorSec.ceilingplane.ZatPoint(h.anchor.xy); }
			else if (ht == TRACE_HitFloor) { h.anchorPlane = 1; h.planeOfs = h.anchor.z - h.anchorSec.floorplane.ZatPoint(h.anchor.xy); }
		}
		String s = RSQGR_Looks.Sound('hitwall');
		if (s != "") h.A_StartSound(s, CHAN_VOICE);
		RSQGR_Looks.Spark(at, 'wall');
		Latch(h, i);
	}

	bool UseLine(RSQGR_Hook h, Line ln, int side, Vector3 at)
	{
		if (!ln || !ln.special || !h.owner || !RSQGR_Util.Flag("rsqgr_use_lines", false)) return false;
		if (!(ln.activation & (SPAC_Use | SPAC_UseThrough | SPAC_UseBack))) return false;
		// the back of a line only when it may be used from the back (P_UseTraverse's rule)
		if (side != 0 && !(ln.activation & SPAC_UseBack)) return false;
		int sp = ln.special;
		int how = (side != 0) ? SPAC_UseBack : ((ln.activation & SPAC_Use) ? SPAC_Use : SPAC_UseThrough);
		bool done = ln.Activate(h.owner, side, how);
		h.SetOrigin(at - h.dir * 2, true);
		if (RSQGR_Util.Opt("rsqgr_debug", 0) >= 1)
			Console.Printf("T_GR t%d h%d use line %d special %d side %d -> %s", level.maptime, h.hand, ln.Index(), sp, side, done ? "used" : "refused");
		Thump(h, "use");
		LetGo(h, false);
		return true;
	}

	void Latch(RSQGR_Hook h, int i)
	{
		let pmo = h.owner;
		Vector3 b = AttachPoint(pmo);
		h.ropeLen = (h.anchor - b).Length();
		h.losBad = 0;
		h.wasTaut = false;
		h.slackMax = 0;
		Thump(h, "latch");
		if (RSQGR_Util.Opt("rsqgr_geo_mode", 0) == 1)
		{
			// JP's yank, parsed from hook.acs Hook_HitWall + function.acs: ThrustThing
			// toward the hook by (2D distance / 12), nolimit; ThrustThingZ "down" by
			// (zdist/4)/4 added, with zdist = player z - hook z (integer units) --
			// i.e. vel.z += (hook z - player z) / 16, upward when the hook is above.
			Vector3 d = h.anchor - pmo.Pos;
			double d2 = d.xy.Length();
			if (d2 > 0.01) pmo.vel.xy += d.xy / d2 * (int(d2) / 12);
			pmo.vel.z += (int(d.z) / 4) / 4.0;
			CapSpeed(pmo);
			h.SetPhase(RSQGR_Hook.PH_HOLD);
			Log(h, "yank");
			return;
		}
		h.SetPhase(RSQGR_Hook.PH_LATCH);
		Log(h, "latch");
	}

	// ---- the thump (rsqgr_thump) ------------------------------------------------
	//
	// A THUMP IN THE HAND when the claw bites (a wall, a monster) and when the rope catches a falling body.
	// The stock route, Quest teardown 99 1a "The other route: LineAttack" and apply/01 7: P_LineAttack
	// buzzes the firing hand (150 ms at 0.8) whenever a player calls it with damage > 0, before it traces
	// anything and whatever LAF_NOINTERACT says (p_map.cpp 4756-4768), on the user's own left/right
	// (vr_control_scheme, flipped by LAF_ISOFFHAND). 0.1 units with LAF_NOINTERACT: nothing in the world
	// is touched. Not A_QuakeEx: that one is random noise, depends on vr_quake_haptic_level and shoves
	// the player unless its radius is zeroed (99 1a). The same route RSQ_DistanceGrab's pulse uses.
	// One pulse blocks that hand's channel for its 150 ms (gl_openvr.cpp 517-528), so one thump per
	// hook per THUMP_GAP tics.
	const THUMP_GAP = 10;
	const SLACK_IDLE = 105;   // GR4: 3 s at 35 tics
	// GR1: the brake's share of the tangential speed taken each tic while the stick is held back
	const CALM_K = 0.15;
	const TAUT_VR = 3.0;   // u/tic outward when the rope catches him, or it is only the rope settling
	const SLACK_MIN = 12.0; // units of slack it must have hung with first

	void Thump(RSQGR_Hook h, String why)
	{
		if (!h || !h.owner || !h.owner.player || h.owner.Health <= 0) return;
		if (!RSQGR_Util.Flag("rsqgr_thump", true)) return;
		if (level.maptime - h.lastThump < THUMP_GAP) return;
		h.lastThump = level.maptime;
		let pmo = h.owner;
		int ctrl = RSQGR_Util.Ctrl(pmo, h.hand);   // the controller playing that hand's part now
		pmo.LineAttack(pmo.Angle, 0.1, 0, 1, 'None', "RSQGR_NullPuff", LAF_NOINTERACT | (ctrl == 1 ? LAF_ISOFFHAND : 0));
		if (RSQGR_Util.Opt("rsqgr_debug", 0) >= 1)
			Console.Printf("T_GR t%d h%d thump %s ctrl%d", level.maptime, h.hand, why, ctrl);
	}

	// ---- a monster on the line --------------------------------------------------

	// too heavy to come: an anchor instead (at the bite, and re-asked every tic of the pull)
	static bool TooHeavy(RSQGR_Hook h, Actor v)
	{
		double mmax = RSQGR_Util.Num("rsqgr_mass_max", 1000) * RSQGR_Perks.Factor(h.owner, 'mass');   // Heavy Haul
		return v.bBOSS || (mmax > 0 && v.Mass > mmax) || v.bDORMANT;
	}

	void Bite(RSQGR_Hook h, int i)
	{
		let v = h.victim;
		if (!v || v.bDestroyed) { h.victim = null; LetGo(h, false); return; }
		// IT CHANGED UNDER THE CLAW. "Too heavy to come" was decided once, at the bite; a monster can
		// become heavy on the line: a Champions champion dormant until LegenDoom Lite transforms it (at
		// half health) sets up on that tic (Gold Mass x12, Bronze 0x7FFFFFFF, a Titan mutation BOSS).
		// And Champions' Dark Red at 1 health turns unshootable and is moved to the far corner of the
		// map until it gets up -- reeling it would drag it back, invisible. Either way the line lets go.
		if (v.Health > 0 && (!v.bShootable || TooHeavy(h, v))) { LetGo(h, false); return; }
		// the core's own guards, so the other side of the seam gets them for free:
		// out of range, or no closer for a second and a half.
		Vector3 dv = v.Pos - h.owner.Pos;
		double d = dv.xy.Length();
		if (d > h.range * 1.5) { LetGo(h, false); return; }
		// THE LASSO (rsqgr_monster_mode 2) holds it at length on purpose: no "no closer" guard for it
		// (Quest teardown apply/01 4.2 step 3); the held bind reels it in, as it reels a wall rope
		if (RSQGR_Monster.Holds(v))
		{
			h.noProgress = 0;
			h.reelHeld = held[i] && (pressFired[i] || level.maptime - pressTic[i] > TapTics());
		}
		else if (d < h.bestDist - 0.25) { h.bestDist = d; h.noProgress = 0; }
		else if (++h.noProgress > 52) { LetGo(h, false); return; }
		if (!RSQGR_Monster.Tick(v, h.owner, h.hand)) { LetGo(h, false); return; }
		if (h.phaseAge % 2 == 0) Log(h, "pull");
	}

	// ---- the swing --------------------------------------------------------------

	// Where the rope meets the body: about the hands' height on a standing player,
	// lower with him when he crouches (Height follows the crouch, VR's included).
	static Vector3 AttachPoint(PlayerPawn pmo)
	{
		return pmo.Pos + (0, 0, pmo.Height * RSQGR_Util.Num("rsqgr_attach", 0.6));
	}

	static void CapSpeed(PlayerPawn pmo)
	{
		double cap = RSQGR_Util.Num("rsqgr_max_speed", 30);
		double s = pmo.vel.Length();
		if (cap > 0 && s > cap) pmo.vel *= cap / s;
	}

	Vector3 lastPos[MAXPLAYERS], lastSet[MAXPLAYERS];   // where the rope left him, and how fast
	bool tracked[MAXPLAYERS];

	// MOMENTUM SURVIVES THE LANDING (Quest teardown apply/01 6). With vr_momentum off -- its default -- the engine
	// multiplies a grounded player's horizontal velocity by 0.0001 every tic unless player.keepmomentum is set
	// (player.zs MovePlayer), so a swing that touched down stopped dead and a grounded reel restarted from nothing
	// each tic. Set while any hook holds, and for COAST_TICS after a let-go so the flight carries through the
	// touch-down; the engine clears it itself once the player is nearly still (vr_momentum_threshold).
	const COAST_TICS = 18;
	int coastUntil[MAXPLAYERS];
	int pulledTic[MAXPLAYERS];   // the last tic Split Pull drew this player toward a monster (monster.zs)

	// ONLY WHILE THE ROPE IS MOVING HIM. keepmomentum is more than "no wipe": in its branch the engine also
	// leaves Speed at Default.Speed instead of Default.Speed * 8 (player.zs 1378 vs 1382, Quest teardown
	// 09_MOVEMENT), so stick walking turns into Doom's slow, sliding walk for as long as it is set. Set for
	// every latched or biting hook (10-31), it did that whenever a rope was merely OUT: standing under a
	// slack rope, or reeling a monster in on foot (rig: keepmomentum 1, Speed 1 the whole pull). So: in the
	// air on a rope, the rope solving his velocity last tic (a reel or a climb on the floor), Split Pull
	// drawing him in, or the coast after a let-go in the air.
	// RopeFlew: in the air on a rope, or the rope solving his velocity (a reel or climb) -- a flight worth
	// coasting on after a let-go
	bool RopeFlew(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return false;
		int pn = pmo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS) return false;
		bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
		return !grounded || tracked[pn];
	}

	// Set at the END of Swing, from what the rope did THIS tic: it protects the next tic's P_PlayerThink,
	// which is where the wipe runs (p_tick.cpp: the players think before WorldTick).
	void KeepMomentum(PlayerPawn pmo, int pn)
	{
		if (!pmo || !pmo.player || RSQGR_Util.Num("rsqgr_momentum", 1) <= 0) return;
		bool holding = false;
		for (int k = 0; k < 2; k++)
		{
			let hk = hooks[pn * 2 + k];
			if (hk && hk.phase == RSQGR_Hook.PH_LATCH) holding = true;
		}
		bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
		bool moving = (holding && (!grounded || tracked[pn])) || level.maptime - pulledTic[pn] <= 0;
		// a swing that touches down still on the rope coasts on like a let-go one (the engine ends it once slow);
		// a pull along the floor (Split Pull) gets no coast: it stops where it arrives, and the walk comes
		// straight back (rig: 18 tics of slow walk after a Split Pull arrival before this)
		if (moving && !grounded) coastUntil[pn] = max(coastUntil[pn], level.maptime + COAST_TICS);
		if (moving || level.maptime < coastUntil[pn]) pmo.player.keepmomentum = true;
	}

	void Swing(PlayerPawn pmo, int pn)
	{
		bool any = false;
		bool truthTaken = false;
		bool roped = false;
		for (int hand = 0; hand < 2; hand++)
		{
			int i = pn * 2 + hand;
			let h = hooks[i];
			if (!h || h.phase != RSQGR_Hook.PH_LATCH) continue;
			if (!UpdateAnchor(h)) { LetGo(h, false); continue; }
			any = true;

			Vector3 a = h.anchor;
			Vector3 b = AttachPoint(pmo);
			Vector3 r = b - a;
			double d = r.Length();
			if (d < 0.01) continue;
			Vector3 n = r / d;
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			double minLen = RSQGR_Util.Num("rsqgr_min_len", 32);
			double maxLen = h.range * 1.25;

			// REEL: holding the bind takes the rope in. The press that fired keeps
			// reeling the moment it latches (hold = zip); a new press reels only once
			// it outlasts a tap, so a tap to let go does not tug first.
			h.reelHeld = held[i] && (pressFired[i] || level.maptime - pressTic[i] > TapTics());
			if (h.reelHeld)
			{
				h.ropeLen = min(h.ropeLen, d);
				h.ropeLen = max(minLen, h.ropeLen - RSQGR_Util.Num("rsqgr_reel_speed", 12) * RSQGR_Perks.Factor(pmo, 'reel'));
			}
			// CLIMB: a free hand on the grab bind, touching the rope, takes hold of it.
			double climbStep = 0;
			double along = 0;
			bool climbing = Climb(h, pmo, pn, a, b, n, d, minLen, maxLen, climbStep, along);
			bool pullUp = climbing && climbStep < 0;

			h.slack = !grounded || h.reelHeld || h.gripHand >= 0;
			if (d > maxLen + 64) { LetGo(h, false); continue; }
			if (grounded && !h.reelHeld && !pullUp)
			{
				// On your feet the rope pays out and takes in with you, so stepping off a
				// ledge swings at once from that length rather than dropping into slack.
				h.ropeLen = clamp(d, minLen, maxLen);
				h.wasTaut = false;
				h.slackMax = 0;
				// A ROPE LYING SLACK ON THE FLOOR LETS GO (owner's QoL pick GR4, rsqgr_slack_letgo): standing, not
				// reeling or holding it, with the claw no higher than where the rope meets the body -- a rope that
				// cannot hold him up and lies along the floor -- for SLACK_IDLE tics (3 s), it lets go by itself
				if (RSQGR_Util.Flag("rsqgr_slack_letgo", true) && !h.heavy && h.gripHand < 0 && a.z <= b.z)
				{
					if (++h.floorIdle >= SLACK_IDLE) { Log(h, "slack on the floor 3 s: lets go"); h.floorIdle = 0; LetGo(h, false); continue; }
				}
				else h.floorIdle = 0;
				if (level.maptime % 4 == (pn + hand) % 4)
				{
					if (!Sees(pmo, b, a)) { if (++h.losBad >= 3) { LetGo(h, false); continue; } }
					else h.losBad = 0;
				}
				if (level.maptime % 2 == 0) Log(h, "ground");
				continue;
			}

			h.floorIdle = 0;
			// WHAT HE REALLY DID LAST TIC. A wall or a ceiling stops the player but the
			// engine leaves the blocked part in his velocity (measured: reeling into a wall,
			// vel grew 14.7 -> 17.6 u/tic over 8 tics with the pawn not moving), and the
			// rope would keep adding to it -- a fling the moment he let go. So the velocity
			// solved here is what he actually moved last tic, plus whatever the engine and
			// his input changed since the rope set it (gravity, air control).
			if (!truthTaken)
			{
				truthTaken = true;
				if (tracked[pn])
				{
					Vector3 moved = pmo.Pos - lastPos[pn];
					if (moved.Length() < 64) pmo.vel = moved + (pmo.vel - lastSet[pn]);
				}
			}
			Vector3 v = pmo.vel;
			// THE ROPE CATCHES HIM: slack (or just stepped off) last tic, and this tic's step would stretch it
			// while he is moving outward -- a thump in the hand that fired it (rsqgr_thump)
			// (a real catch: it hung at least SLACK_MIN slack first -- a climb's or a swing's own couple of
			// units of give is not one; rig: three false thumps a climb before this)
			bool tautNow = (b + v - a).Length() >= h.ropeLen - 0.5;
			if (!tautNow) h.slackMax = max(h.slackMax, h.ropeLen - d);
			if (tautNow && !h.wasTaut && !grounded && h.slackMax >= SLACK_MIN && (v dot n) >= TAUT_VR) Thump(h, "taut");
			if (tautNow) h.slackMax = 0;
			h.wasTaut = tautNow && !grounded;
			// remove the outward part once the rope is taut
			if (d >= h.ropeLen - 0.5)
			{
				double vr = v dot n;
				if (vr > 0) v -= n * vr;
			}
			// and take back any stretch the step would leave
			Vector3 p = b + v;
			Vector3 pa = p - a;
			double pd = pa.Length();
			if (pd > h.ropeLen && pd > 0.01)
			{
				// Projecting the step back onto the rope's sphere cuts the chord short and
				// bleeds speed every tic (measured: a free swing lost ~20% of its height
				// per half swing). So a free swing keeps the speed it had before the
				// projection -- a rope does no work on what hangs from it. Reeling is work,
				// and keeps what the projection gives.
				double vt = v.Length();
				Vector3 corr = a + pa / pd * h.ropeLen - p;
				double cmax = RSQGR_Util.Num("rsqgr_reel_speed", 12) * RSQGR_Perks.Factor(pmo, 'reel') + 8;
				double cl = corr.Length();
				if (cl > cmax) corr *= cmax / cl;
				v += corr;
				double vl = v.Length();
				if (!h.reelHeld && !climbing && d <= h.ropeLen + 1.0 && vl > 0.01) v *= vt / vl;
			}

			// A reel pulls in at about its own speed, not faster: the correction above
			// stacks on momentum and measured up to 29 u/tic reeling to a Cyberdemon.
			if (h.reelHeld)
			{
				double vin = -(v dot n);
				double vmax = RSQGR_Util.Num("rsqgr_reel_speed", 12) * RSQGR_Perks.Factor(pmo, 'reel') * 1.5;
				if (vin > vmax) v += n * (vin - vmax);
			}

			// The climbing hand moves the body exactly as far as it moved along the rope
			// (1:1, capped by rsqgr_climb_cap): the radial speed IS the hand's step, both
			// ways, so pulling down lifts you and pushing up lowers you at the hand's pace
			// -- no spring, no smoothing to lag behind the arm.
			if (climbing)
				v += n * (climbStep - (v dot n));

			if (!grounded && d >= h.ropeLen - 1.0)
			{
				// PUMP: the movement stick leans the swing, tangentially only.
				let cmd = pmo.player.cmd;
				double fwd = cmd.forwardmove / 12800.0;
				double side = cmd.sidemove / 10240.0;
				// CALM THE SWING (owner's QoL pick GR1, rsqgr_calm): the stick pulled back past half is a brake, not a
				// pump -- the swing's tangential speed is cut by CALM_K a tic below (see THE SWING DIES DOWN)
				bool calm = fwd <= -0.5 && RSQGR_Util.Flag("rsqgr_calm", true);
				if (calm) fwd = 0;
				if (fwd != 0 || side != 0)
				{
					Vector2 f2 = Actor.AngleToVector(pmo.Angle, 1);
					Vector2 s2 = (f2.y, -f2.x);
					Vector3 push = (f2.x * fwd + s2.x * side, f2.y * fwd + s2.y * side, 0);
					push -= n * (push dot n);
					v += push * RSQGR_Util.Num("rsqgr_pump", 0.25);
				}
				// THE SWING DIES DOWN. Two losses on the TANGENTIAL speed only (the radial
				// part is the rope's): air drag in proportion to speed (rsqgr_drag, per tic)
				// and a small constant rope/body friction (rsqgr_rope_friction, u/tic per
				// tic) that finishes the last small swings -- drag alone would leave a
				// 1-degree sway going for a minute. Tuned in a model of this integrator
				// (40 deg, L 200..643): ~12% of the amplitude per half swing, settled in
				// 8-10 half swings. When the swing is that small and slow near the bottom,
				// it stops: hanging still under the anchor. The stick pump (0.25) is ten
				// times the friction, so a pumped swing keeps going.
				Vector3 vt = v - n * (v dot n);
				double st = vt.Length();
				if (st > 0)
				{
					double k = clamp(RSQGR_Util.Num("rsqgr_drag", 0.002), 0.0, 0.2);
					k = min(k + RSQGR_Perks.SteadyDrag(pmo, k, fwd == 0 && side == 0), 0.2);   // Steady Line
					double f = max(0.0, RSQGR_Util.Num("rsqgr_rope_friction", 0.025));
					if (calm) k = max(k, CALM_K);
					double ns = max(0.0, st * (1.0 - k) - f);
					double ang = acos(clamp(-n.z, -1.0, 1.0));   // from hanging straight down
					if (ns <= f && (ang < 1.5 || calm) && fwd == 0 && side == 0) ns = 0;
					v = (v - vt) + vt * (ns / st);
				}
			}
			pmo.vel = v;
			CapSpeed(pmo);
			roped = true;

			// The rope must see its anchor. Swing round a corner and it slips: checked
			// every 4 tics, three misses in a row let go.
			if (level.maptime % 4 == (pn + hand) % 4)
			{
				if (!Sees(pmo, b, a)) { if (++h.losBad >= 3) { LetGo(h, false); continue; } }
				else h.losBad = 0;
			}
			if (level.maptime % 2 == 0 || (climbing && climbStep != 0)) Log(h, (climbing && climbStep != 0) ? "climb" : h.reelHeld ? "reel" : (h.gripHand >= 0 ? "hold" : "swing"));
		}
		tracked[pn] = roped;
		if (roped) { lastPos[pn] = pmo.Pos; lastSet[pn] = pmo.vel; }
		KeepMomentum(pmo, pn);
	}

	// ---- hand over hand (climb.zs says which hand may and where it is) -------------

	bool grabHeld[NHOOK];     // the grab bind is down (rsqgr_grip, or RSQ_DistanceGrab's grips)
	bool wantGrip[NHOOK];     // a press not yet turned into a hold (the hand may still be reaching)
	Vector3 poseOff[NHOOK];   // netgame: the hand's offset from the pawn, streamed (rsqgr_pose)
	int poseTic[NHOOK];

	void Grab(int pn, int hand, bool down)
	{
		int i = pn * 2 + hand;
		grabHeld[i] = down;
		wantGrip[i] = down;
		if (down) return;
		for (int k = 0; k < 2; k++)
		{
			let h = hooks[pn * 2 + k];
			if (h && h.gripOn[hand])
			{
				h.gripOn[hand] = false;
				h.gripPend[hand] = false;
				if (!h.gripOn[1 - hand]) h.gripHand = -1;
				else if (h.gripHand == hand) h.gripHand = 1 - hand;
				Log(h, String.Format("unhold h%d", hand));
			}
		}
	}

	// Takes or keeps the hold, moves the rope's length by the hand, returns whether the
	// hand moved the body this tic and by how much along the rope (negative = up it).
	bool Climb(RSQGR_Hook h, PlayerPawn pmo, int pn, Vector3 a, Vector3 b, Vector3 n, double d,
		double minLen, double maxLen, out double step, out double along)
	{
		step = 0;
		along = 0;
		if (RSQGR_Util.Opt("rsqgr_climb", 1) == 0) { h.ClearGrips(); return false; }
		// BOTH HANDS ON ONE ROPE (rsqgr_two_hands, Quest teardown apply/01 5.2): a new press that touches the
		// rope JOINS the hand already on it; letting go of one leaves the other holding. Off: the new hand
		// takes the rope over from the other, as before.
		bool two = RSQGR_Util.Flag("rsqgr_two_hands", true);
		bool wasHeld = h.GripCount() > 0;
		for (int g = 0; g < 2; g++)
		{
			int gi = pn * 2 + g;
			if (!wantGrip[gi] || h.gripOn[g]) { if (h.gripOn[g]) wantGrip[gi] = false; continue; }
			bool ok; Vector3 off;
			[ok, off] = RSQGR_Climb.HandOffset(pmo, pn, g);
			if (!ok || !RSQGR_Climb.HandFree(pmo, g)) continue;
			Vector3 hp = pmo.Pos + off;
			if (RSQGR_Climb.ToSegment(hp, a, b) > RSQGR_A11y.Wide(RSQGR_Util.Num("rsqgr_grab_reach", 16))) continue;   // Gesture Ease: x1..x2
			if (!two) { h.gripOn[1 - g] = false; h.gripPend[1 - g] = false; }
			h.gripOn[g] = true;
			h.gripPend[g] = true;
			wantGrip[gi] = false;
			Log(h, String.Format("take h%d", g));
		}
		if (h.GripCount() == 0) { h.gripHand = -1; return false; }

		// BY EACH HAND'S STEP, not its place: a hand moved this much since last tic, measured along the
		// rope as it hangs now. Taken from the place instead (rope length = hold point - hand offset along
		// the rope), a still hand on a swinging body drifted the length 6-14 units a swing as the rope
		// turned (rig, full order). Faster than the cap: the excess slips through the hand rather than
		// being owed -- the body never catches up with motion the arm made a tic ago.
		// TWO HANDS: the AVERAGE of their steps, never the sum (the teardown's warning: a sum makes frantic
		// shaking the fastest climb). Both pulling together climb as one hand does; one still hand halves
		// the other's stroke; and each hand's tremor is halved.
		double cap = RSQGR_Util.Num("rsqgr_climb_cap", 8);
		double sum = 0;
		int n2 = 0;
		bool fresh = false;
		double topAlong = 1e9;
		int top = -1;
		for (int g = 0; g < 2; g++)
		{
			if (!h.gripOn[g]) continue;
			bool ok = false; Vector3 off = (0, 0, 0);
			if (RSQGR_Climb.HandFree(pmo, g)) { [ok, off] = RSQGR_Climb.HandOffset(pmo, pn, g); }
			if (!ok) { h.gripOn[g] = false; h.gripPend[g] = false; Log(h, String.Format("slip h%d", g)); continue; }
			double al = ((pmo.Pos + off) - b) dot n;   // + = further down the rope than the body's attach point
			if (al < topAlong) { topAlong = al; top = g; }
			if (h.gripPend[g])
			{
				h.gripLast[g] = off;       // where the hand closed
				h.gripPend[g] = false;
				fresh = true;
				continue;
			}
			sum += clamp(-((off - h.gripLast[g]) dot n), -cap, cap);
			h.gripLast[g] = off;
			n2++;
		}
		h.gripHand = top;
		if (top < 0) return false;
		along = topAlong;
		if (n2 == 0)
		{
			// only a hand that has just closed: the rope's length is taken from here (unless a hand was
			// already holding it, whose length stands)
			if (fresh && !wasHeld) h.ropeLen = clamp(d, minLen, maxLen);
			return false;
		}
		double delta = sum / n2;
		double nl = clamp(h.ropeLen + delta, minLen, maxLen);
		delta = nl - h.ropeLen;
		h.ropeLen += delta;
		step = delta;
		// HOLDING is the answer even when the hand is still: the body then hangs from
		// the hand with no radial speed of its own, so a stroke stops when the arm does
		// instead of coasting on (rig: 27 units of overshoot after a stroke ended).
		return true;
	}

	// Follows a moving plane, a moving heavy monster; checks a wall is still there.
	bool UpdateAnchor(RSQGR_Hook h)
	{
		if (h.heavy)
		{
			if (!h.victim || h.victim.bDestroyed || h.victim.Health <= 0) return false;
			h.anchor = h.victim.Pos + h.victimOfs;
			return true;
		}
		if (h.anchorSec && h.anchorPlane == 2)
		{
			h.anchor.z = h.anchorSec.ceilingplane.ZatPoint(h.anchor.xy) + h.planeOfs;
			if (h.anchorSec.ceilingplane.ZatPoint(h.anchor.xy) - h.anchorSec.floorplane.ZatPoint(h.anchor.xy) < 2) return false;
			h.SetOrigin(h.anchor, true);
		}
		else if (h.anchorSec && h.anchorPlane == 1)
		{
			h.anchor.z = h.anchorSec.floorplane.ZatPoint(h.anchor.xy) + h.planeOfs;
			h.SetOrigin(h.anchor, true);
		}
		else if (h.phaseAge % 4 == 1)
		{
			// a wall: is it still there? (a door's upper wall rises away; a polyobject goes)
			let tr = GetTracer();
			tr.shooter = h.owner;
			Vector3 s = h.anchor - h.hitDir * 6;
			if (!tr.Trace(s, level.PointInSector(s.xy), h.hitDir, 16, TRACE_HitSky, RSQGR_Tracer.WALLMASK, true, h.owner)
				|| tr.Results.HitType == TRACE_HitNone || tr.Results.HitType == TRACE_HasHitSky)
				return false;
		}
		return true;
	}

	bool Sees(PlayerPawn pmo, Vector3 from, Vector3 to)
	{
		Vector3 d = to - from;
		double l = d.Length();
		if (l < 16) return true;
		let tr = GetTracer();
		tr.shooter = pmo;
		if (!tr.Trace(from, level.PointInSector(from.xy), d / l, l - 8, 0, RSQGR_Tracer.WALLMASK, true, pmo)) return true;
		return tr.Results.HitType == TRACE_HitNone;
	}

	// ---- housekeeping -----------------------------------------------------------

	// A level's actors die with it; the table must not point at them on the next.
	// After a load the table is rebuilt from the claws actually in the level, and
	// every bind reads as up (a release that happened before the save never comes).
	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < NHOOK; i++) { hooks[i] = null; held[i] = false; pressFired[i] = false; grabHeld[i] = false; wantGrip[i] = false; poseTic[i] = -100; }
		if (!e.IsSaveGame) return;
		let it = ThinkerIterator.Create("RSQGR_Hook");
		RSQGR_Hook h;
		while (h = RSQGR_Hook(it.Next()))
		{
			if (!h.owner || !h.owner.player) { h.Destroy(); continue; }
			int i = h.owner.PlayerNumber() * 2 + h.hand;
			if (i < 0 || i >= NHOOK || hooks[i]) { h.Destroy(); continue; }
			hooks[i] = h;
			h.ClearGrips();   // a hold does not survive a load: the bind's release may never come
		}
		// stray rope pieces and links whose hook is gone
		Array<Actor> keep;
		for (int i = 0; i < NHOOK; i++)
		{
			if (!hooks[i]) continue;
			for (int k = 0; k < hooks[i].segs.Size(); k++) keep.Push(hooks[i].segs[k]);
			for (int k = 0; k < hooks[i].links.Size(); k++) keep.Push(hooks[i].links[k]);
		}
		let lt = ThinkerIterator.Create("Actor");
		Actor l;
		while (l = Actor(lt.Next()))
			if ((l is "RSQGR_Rope" || l is "RSQGR_Link") && keep.Find(l) == keep.Size()) l.Destroy();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < NHOOK; i++)
		{
			if (hooks[i]) hooks[i].Destroy();
			hooks[i] = null;
			held[i] = false;
		}
	}

	// ---- measurement (rsqgr_debug 1) --------------------------------------------

	void Log(RSQGR_Hook h, String what)
	{
		if (RSQGR_Util.Opt("rsqgr_debug", 0) < 1 || !h || !h.owner) return;
		let p = h.owner;
		Vector3 b = AttachPoint(p);
		Console.Printf("T_GR t%d h%d %s pos(%.1f %.1f %.1f) vel(%.2f %.2f %.2f) claw(%.1f %.1f %.1f) L%.1f d%.1f segs%d ms%.3f/%.3f scale%.2f grip%d free%d%d hoff%.2f pt%d%s",
			level.maptime, h.hand, what, p.Pos.x, p.Pos.y, p.Pos.z, p.vel.x, p.vel.y, p.vel.z,
			h.Pos.x, h.Pos.y, h.Pos.z, h.ropeLen, (h.anchor - b).Length(), h.segs.Size() + h.links.Size(), h.drawMs, tickMs, worldScale, h.gripHand, RSQGR_Climb.HandFree(p, 0), RSQGR_Climb.HandFree(p, 1), h.gripHand >= 0 ? poseOff[p.PlayerNumber() * 2 + h.gripHand].z : 0., h.gripHand >= 0 ? poseTic[p.PlayerNumber() * 2 + h.gripHand] : -1,
			h.victim ? String.Format(" victim %s (%.1f %.1f %.1f)", h.victim.GetClassName(), h.victim.Pos.x, h.victim.Pos.y, h.victim.Pos.z) : "");
	}
}
