// RSQWP_Core -- one hook per hand per player, and everything they decide.
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
class RSQWP_Core : EventHandler
{
	const NHOOK = MAXPLAYERS * 2;
	const TAP_TICS = 8;       // a press this short is a tap, not a reel; RSQ_Accessibility's Slower Taps widens it x1.5 where it is read (RSQWP_A11y.Tap; a server setting)
	const TAKEUP = 10.0;      // an aimed swing's rope taken up on its own, map units a tic (swing.zs)
	const PAYOUT = 8.0;       // an aimed swing's launch: the length it followed him in, given back a tic on the way down

	RSQWP_Hook hooks[NHOOK];
	bool held[NHOOK];
	int pressTic[NHOOK];
	bool altReel[NHOOK];      // the whip weapon's alt-fire is reeling (weapon.zs)
	bool pressFired[NHOOK];   // this press fired the hook (holding it on = reel at once)
	double worldScale;
	transient RSQWP_Tracer tracer;

	clearscope static RSQWP_Core Get() { return RSQWP_Core(EventHandler.Find("RSQWP_Core")); }

	// The world's speed now (1 = not slowed). See RSQWP_Util.WorldScale.
	clearscope static double Scale()
	{
		let c = Get();
		return (c && c.worldScale > 0) ? c.worldScale : 1.0;
	}

	// The hook a hand of a player has out, if any (for the seam's other side).
	clearscope static RSQWP_Hook HookOf(PlayerPawn pmo, int hand)
	{
		let c = Get();
		if (!c || !pmo || !pmo.player) return null;
		int pn = pmo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS || (hand & ~1)) return null;
		return c.hooks[pn * 2 + hand];
	}

	RSQWP_Tracer GetTracer()
	{
		if (!tracer) tracer = new("RSQWP_Tracer");
		return tracer;
	}

	// ---- input ------------------------------------------------------------------

	void Press(int pn, int hand, Vector3 org, Vector3 dir)
	{
		if (!RSQWP_Util.Flag("rsqwp_on", true)) return;
		let pmo = players[pn].mo;
		if (!pmo || pmo.Health <= 0) return;
		int i = pn * 2 + hand;
		held[i] = true;
		pressTic[i] = level.maptime;
		pressFired[i] = false;
		let h = hooks[i];
		if (h && h.phase != RSQWP_Hook.PH_RETRACT && h.phase != RSQWP_Hook.PH_HOLD)
		{
			if (h.phase == RSQWP_Hook.PH_FLY) LetGo(h, false);   // recall a claw in flight: nothing makes one (design/WHIP_DEAD_FEATURES.md, Fly)
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
		if (level.maptime - pressTic[i] <= RSQWP_A11y.Tap(TAP_TICS)
			&& (h.phase == RSQWP_Hook.PH_LATCH || h.phase == RSQWP_Hook.PH_BITE))
			LetGo(h, true);
	}

	// ---- fire -------------------------------------------------------------------

	// No claw in this mod: a bind press with no line out starts the whip in that hand (whip.zs). The binds have had no
	// keys since 11-10 (design/WHIP_DEAD_FEATURES.md, the bind whip).
	void Fire(PlayerPawn pmo, int pn, int hand, Vector3 org, Vector3 dir)
	{
		let w = RSQWP_Whip.Get();
		if (w) w.Start(pn * 2 + hand, pmo, hand, RSQWP_Util.Opt("rsqwp_whip_mode", 0));
	}

	// ---- let go -----------------------------------------------------------------

	void LetGo(RSQWP_Hook h, bool byPlayer)
	{
		if (!h) return;
		if (h.phase == RSQWP_Hook.PH_BITE && h.victim && h.owner && !h.heavy)
			RSQWP_Monster.OnRelease(h.victim, h.owner, h.hand);
		// A hop off the top: let go within reach of a wall's latch while reeling and the
		// player gets a small lift -- enough to get a foot over a ledge.
		if (byPlayer && h.phase == RSQWP_Hook.PH_LATCH && h.owner && h.anchorPlane == 0 && !h.heavy)
		{
			double hop = RSQWP_Util.Num("rsqwp_hop", 6);
			Vector3 b = AttachPoint(h.owner);
			if (hop > 0 && (h.anchor - b).Length() < RSQWP_Util.Num("rsqwp_min_len", 32) + 24 && h.anchor.z > h.owner.Pos.z)
				h.owner.vel.z = max(h.owner.vel.z, hop);
		}
		if (byPlayer && h.phase == RSQWP_Hook.PH_LATCH && h.owner && !h.heavy) Grace(PlayerPawn(h.owner));
		// SLINGSHOT (fx.zs RSQWP_Perks): after the grace has picked the let-go's speed (it would put the old speed back)
		RSQWP_Perks.OnLetGo(h, byPlayer);
		h.victim = null;
		h.SetPhase(RSQWP_Hook.PH_RETRACT);
		if (h.owner) Carry(PlayerPawn(h.owner));
		Log(h, byPlayer ? "letgo" : "drop");
	}

	// KEEP THE SWING'S SPEED (rsqwp_carry). With the engine's "Slidey movement" off (vr_momentum,
	// the default) player.zs MovePlayer cuts a grounded player's speed to 0.0001 of itself every
	// tic unless player.keepmomentum is set -- a swing that lands stops dead. keepmomentum is the
	// engine's own exit: set while the rope carries him and when he lets go; the engine clears it
	// by itself once he has slowed below vr_momentum_threshold, and Doom's friction does the rest.
	// Core ticks before any thinker (WorldTick), so it holds on the tic it is set.
	static void Carry(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player || !RSQWP_Whip.Unlock(pmo, RSQWP_Whip.G_MOMENTUM, "rsqwp_carry", true)) return;   // the Momentum node under Gun Bonsai VR
		if (pmo.vel.xy.Length() < 2) return;
		pmo.player.keepmomentum = true;
	}

	// THE RELEASE GRACE WINDOW (surveys/05_GRAPPLE_ROPES.md 4.2). Hands are read 35 times a second and a let-go lands
	// late: the swing's speed of the last GRACE_TICS tics in the air is kept (vHist, Swing), and on a let-go the
	// fastest of them is what he flies off with -- ~85 ms of grace for letting go at the bottom of the arc.
	const GRACE_TICS = 3;
	Vector3 vHist[MAXPLAYERS * 4];
	int vHistN[MAXPLAYERS], vHistAt[MAXPLAYERS];
	void Grace(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return;
		int pn = pmo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS || vHistN[pn] <= 0) return;
		if (pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj) return;
		Vector3 was = pmo.vel;
		Vector3 best = was;
		int from = -1;
		for (int k = 0; k < min(GRACE_TICS, vHistN[pn]); k++)
		{
			Vector3 v = vHist[pn * 4 + ((vHistAt[pn] - k + 4) % 4)];
			if (v.Length() > best.Length() + 0.01) { best = v; from = k; }
		}
		if (from >= 0) { pmo.vel = best; CapSpeed(pmo); }
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WP t%d GRACE vel (%.1f %.1f %.1f) %.1f -> (%.1f %.1f %.1f) %.1f (%s)", level.maptime, was.x, was.y, was.z, was.Length(),
				pmo.vel.x, pmo.vel.y, pmo.vel.z, pmo.vel.Length(), from < 0 ? "kept: no faster tic" : String.Format("from %d tic(s) back", from));
		vHistN[pn] = 0;
	}

	void Drop(int i)
	{
		let h = hooks[i];
		if (h) LetGo(h, false);
	}

	// ---- the tic ----------------------------------------------------------------

	double tickMs;   // last WorldTick's cost (rsqwp_debug)

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
			held[i] = false; pressFired[i] = false; grabHeld[i] = false; keyHeld[i] = false; touchHeld[i] = false; touchOn[i] = 0; touchArmed[i] = false; wantGrip[i] = false; poseTic[i] = -100;
			if (hooks[i]) { hooks[i].gripHand = -1; hooks[i].gripPending = false; }
		}
	}

	override void WorldTick()
	{
		double t0 = MSTimeF();
		if (!settled) Settle();
		worldScale = RSQWP_Util.WorldScale();
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
				if (pmo.Health <= 0 && h.phase != RSQWP_Hook.PH_RETRACT) { LetGo(h, false); continue; }
				if (h.phase == RSQWP_Hook.PH_RETRACT) continue;
				if (h.phase == RSQWP_Hook.PH_FLY) Fly(h, i);
				else if (h.phase == RSQWP_Hook.PH_BITE) Bite(h, i);
				else if (h.phase == RSQWP_Hook.PH_HOLD) { if (h.phaseAge >= 16) LetGo(h, false); }
			}
			if (pmo && pmo.Health > 0) TouchTick(pmo, pn);
			if (pmo && pmo.Health > 0) Swing(pmo, pn);
			if (pmo && pmo.Health > 0 && RSQWP_A11y.Vignette() > 0) Comfort(pmo, pn);
		}
		tickMs = MSTimeF() - t0;
	}

	// RSQ_Accessibility's Comfort Vignette: a swing in the air, a reel or a climb is a comfort moment (and PH_HOLD,
	// the yank nothing starts: design/WHIP_DEAD_FEATURES.md), as strong as the body is moving fast (0.35 at rest on the rope, full at
	// rsqwp_max_speed). Standing on the ground with the rope slack is not.
	void Comfort(PlayerPawn pmo, int pn)
	{
		double k = 0;
		for (int hand = 0; hand < 2; hand++)
		{
			let h = hooks[pn * 2 + hand];
			if (!h) continue;
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			if (h.phase == RSQWP_Hook.PH_HOLD || (h.phase == RSQWP_Hook.PH_LATCH && (!grounded || h.reelHeld || h.gripHand >= 0)))
				k = 1;
		}
		if (k <= 0) return;
		double top = max(1.0, RSQWP_Whip.SwingCap(pmo));
		RSQWP_A11y.Comfort(pmo, clamp(0.35 + 0.65 * pmo.vel.Length() / top, 0.35, 1.0));
	}

	// ---- flight -----------------------------------------------------------------

	// A CLAW IN FLIGHT (RSQ Grapple's, forked). Nothing in this mod makes one: every RSQWP_Hook is built latched or
	// bitten (whip.zs Snag / Leash, swing.zs). Kept for the owner's choice: design/WHIP_DEAD_FEATURES.md, Fly.
	void Fly(RSQWP_Hook h, int i)
	{
		double step = min(h.speed, h.range - h.traveled);
		if (step <= 0) { LetGo(h, false); return; }
		let tr = GetTracer();
		tr.shooter = h.owner;
		Vector3 p = h.Pos;
		bool hit = tr.Trace(p, level.PointInSector(p.xy), h.dir, step, TRACE_HitSky, RSQWP_Tracer.WALLMASK, false, h.owner);
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
			String s = RSQWP_Looks.Sound('hitflesh');
			if (s != "") h.A_StartSound(s, CHAN_VOICE);
			RSQWP_Looks.Spark(at, 'flesh');
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
				h.SetPhase(RSQWP_Hook.PH_BITE);
				RSQWP_Monster.OnHooked(v, h.owner, h.hand, at);
				Log(h, "bite");
			}
			RSQWP_Events.Bitten(h.owner, v, h.hand, h.heavy);   // service.zs: for other mods to read
			RSQWP_Perks.OnBite(h, v);   // Heavy Haul, Barbed Claw (fx.zs); a claw's bite: nothing makes one (Fly)
			return;
		}

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
		String s = RSQWP_Looks.Sound('hitwall');
		if (s != "") h.A_StartSound(s, CHAN_VOICE);
		RSQWP_Looks.Spark(at, 'wall');
		Latch(h, i);
	}

	void Latch(RSQWP_Hook h, int i)
	{
		let pmo = h.owner;
		Vector3 b = AttachPoint(pmo);
		h.ropeLen = (h.anchor - b).Length();
		h.losBad = 0;
		// THE PH_HOLD YANK: rsqwp_geo_mode is not defined, so this never runs. Kept for the owner's choice:
		// design/WHIP_DEAD_FEATURES.md, the PH_HOLD yank.
		if (RSQWP_Util.Opt("rsqwp_geo_mode", 0) == 1)
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
			h.SetPhase(RSQWP_Hook.PH_HOLD);
			Log(h, "yank");
			return;
		}
		h.SetPhase(RSQWP_Hook.PH_LATCH);
		Log(h, "latch");
	}

	// ---- a monster on the line --------------------------------------------------

	// too heavy to come: an anchor instead (at the bite, and re-asked every tic of the pull)
	static bool TooHeavy(RSQWP_Hook h, Actor v)
	{
		double mmax = RSQWP_Util.Num("rsqwp_mass_max", 1000) * RSQWP_Perks.Factor(h.owner, 'mass');   // Heavy Haul (fx.zs)
		// an RSQ Miniboss miniboss with Miniboss's "Can't Be Yanked" on: an anchor, as a boss is
		return v.bBOSS || (mmax > 0 && v.Mass > mmax) || v.bDORMANT || RSQWP_Util.MinibossAs(v, "yank");
	}

	void Bite(RSQWP_Hook h, int i)
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
		if (d < h.bestDist - 0.25) { h.bestDist = d; h.noProgress = 0; }
		else if (++h.noProgress > 52) { LetGo(h, false); return; }
		if (!RSQWP_Monster.Tick(v, h.owner, h.hand)) { LetGo(h, false); return; }
		if (h.phaseAge % 2 == 0) Log(h, "pull");
	}

	// ---- the swing --------------------------------------------------------------

	// Where the rope meets the body: about the hands' height on a standing player,
	// lower with him when he crouches (Height follows the crouch, VR's included).
	// TARZAN (Gun Bonsai VR, GBOVR_TREES.md 4.4 Rope, after Momentum 2): swinging into a monster at 3 m/s or more hurts
	// it 10 + 10 lv times your speed over the swing's cap, and knocks it flat (Gun Bonsai VR's "knockdown", a second);
	// the same monster once a second. Nothing without the node.
	Actor tzLast[MAXPLAYERS];
	int tzTic[MAXPLAYERS];
	void Tarzan(PlayerPawn pmo)
	{
		int lv = RSQWP_Whip.Gb(pmo, RSQWP_Whip.G_TARZAN);
		if (lv <= 0 || !pmo.player) return;
		int pn = pmo.PlayerNumber();
		double sp = pmo.vel.Length();
		if (sp < 3.0 * 34.0 / 35.0) return;
		let it = BlockThingsIterator.Create(pmo, sp + 32);
		while (it.Next())
		{
			let m = it.thing;
			if (!m || m == pmo || m.player || !m.bISMONSTER || m.Health <= 0 || !m.bSHOOTABLE) continue;
			if (m == tzLast[pn] && level.maptime - tzTic[pn] < 35) continue;
			if (pmo.Distance2D(m) > pmo.radius + m.radius + sp) continue;
			if (m.pos.z > pmo.pos.z + pmo.height || m.pos.z + m.height < pmo.pos.z - 8) continue;
			if (((m.pos.xy - pmo.pos.xy) dot pmo.vel.xy) <= 0) continue;     // swinging INTO it
			double share = clamp(sp / max(1.0, RSQWP_Whip.SwingCap(pmo)), 0.0, 1.0);
			int dmg = max(1, int((10 + 10 * lv) * share + 0.5));
			int hp0 = m.Health;
			RSQWP_Whip.Touch("tarzan", pmo, m);   // RSQ Score: named BEFORE the blow, so a kill by it reads as the swing's (11-03)
			RSQWP_Perks.Hurt(m, pmo, pmo, dmg, RSQWP_Whip.DmgType());
			if (m && !m.bDestroyed && m.Health > 0) { RSQWP_Whip.Ask("knockdown", m, 1); m.vel.xy += pmo.vel.xy * 0.5; }
			tzLast[pn] = m; tzTic[pn] = level.maptime;
			if (RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WP TARZAN t%d %s at %.1f a tic (%.0f%% of the cap): %d, hp %d -> %d", level.maptime, m ? m.GetClassName() : 'gone', sp, share * 100, dmg, hp0, m ? m.Health : 0);
		}
	}

	static Vector3 AttachPoint(PlayerPawn pmo)
	{
		return pmo.Pos + (0, 0, pmo.Height * RSQWP_Util.Num("rsqwp_attach", 0.6));
	}

	static void CapSpeed(PlayerPawn pmo)
	{
		double cap = RSQWP_Whip.SwingCap(pmo);     // Momentum 2-3 raise it (Gun Bonsai VR)
		double s = pmo.vel.Length();
		if (cap > 0 && s > cap) pmo.vel *= cap / s;
	}

	// THE REEL'S RATE: Reel Speed (rsqwp_reel_climb) x the perk factor, eased in over REEL_EASE tics of holding
	const REEL_EASE = 6;
	static double ReelFull(PlayerPawn pmo) { return max(0.25, RSQWP_Util.Num("rsqwp_reel_climb", 3)) * RSQWP_Perks.Factor(pmo, 'reel'); }
	static double ReelRate(RSQWP_Hook h, PlayerPawn pmo) { return ReelFull(pmo) * min(1.0, (h.reelTics + 1.0) / REEL_EASE); }

	Vector3 lastPos[MAXPLAYERS], lastSet[MAXPLAYERS];   // where the rope left him, and how fast
	bool tracked[MAXPLAYERS];

	void Swing(PlayerPawn pmo, int pn)
	{
		SwingInput(pmo, pn);     // swing.zs: this tic's jump and off-grip presses (the starts)
		bool any = false;
		bool truthTaken = false;
		bool roped = false;
		for (int hand = 0; hand < 2; hand++)
		{
			int i = pn * 2 + hand;
			let h = hooks[i];
			if (!h || h.phase != RSQWP_Hook.PH_LATCH) continue;
			if (!UpdateAnchor(h)) { LetGo(h, false); continue; }
			any = true;

			Vector3 a = h.anchor;
			Vector3 b = AttachPoint(pmo);
			Vector3 r = b - a;
			double d = r.Length();
			if (d < 0.01) continue;
			Vector3 n = r / d;
			bool grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
			double minLen = RSQWP_Util.Num("rsqwp_min_len", 32);
			double maxLen = h.range * 1.25;
			// swing.zs: a gun into the off hand lets go only with Off Hand Free While Snagged off; grip / jump start the swing
			if (SwingWatch(h, pmo, pn)) continue;
			if (SwingStart(h, pmo, pn, grounded, minLen)) grounded = pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;

			// REEL: holding the bind takes the rope in. The press that fired keeps
			// reeling the moment it latches (hold = zip); a new press reels only once
			// it outlasts a tap, so a tap to let go does not tug first.
			h.reelHeld = held[i] && (pressFired[i] || level.maptime - pressTic[i] > RSQWP_A11y.Tap(TAP_TICS));
			// A CLIMB, NOT A WINCH (owner 11-03: "slower whip reel in, too fast now, supposed to simulate climbing"): Reel
			// Speed (rsqwp_reel_climb, 3 a tic, ~3 m/s; it was 12) reached over REEL_EASE tics from the press
			double reelRate = ReelRate(h, pmo);
			if (h.reelHeld)
			{
				h.fullLen = 0;           // a reel chooses the length: the launch's pay-back is over (rig 11-03: it paid the climb back out)
				h.reelTics++;
				h.ropeLen = min(h.ropeLen, d);
				h.ropeLen = max(minLen, h.ropeLen - reelRate);
			}
			else h.reelTics = 0;
			// TAKE-UP (swing.zs SwingLatch): an aimed swing's rope too long for its arc to clear the floor is taken in on
			// its own, as a reel at TAKEUP a tic, to autoLen -- the swing that lifts a standing player. Then it is free.
			bool takeUp = h.autoLen > 0 && h.ropeLen > h.autoLen + 0.5;
			if (h.autoLen > 0 && !takeUp) h.autoLen = 0;
			if (takeUp && !h.reelHeld)
			{
				h.ropeLen = min(h.ropeLen, d);
				h.ropeLen = max(h.autoLen, h.ropeLen - (h.takeRate > 0 ? h.takeRate : TAKEUP));
			}
			bool reeling = h.reelHeld || takeUp;
			// THE LAUNCH (swing.zs): an aimed swing's rope is taut from the latch, so the hop or a step toward the anchor
			// does not leave it slack and drop him (rig: 200 units of free fall before it caught). Until it first pulls
			// in the air (or a second), its length follows him in, never out; from then on it is the ordinary rope.
			if (h.launch)
			{
				if (!grounded)
				{
					if (d < h.ropeLen - 1.0) h.ropeLen = max(minLen, d);
					else if (h.phaseAge > 1) h.launch = false;
				}
				if (h.phaseAge > 35) h.launch = false;
			}
			// ... and once it pulls, the length it lost following him in is paid back out on the way down (never on the
			// way up: lengthening a falling pendulum is what gravity's work goes into), so the arc still swings from
			// the length it latched at (rig: a step off the lip toward the anchor took 312 down to 251 and the
			// bottom of the arc 40 units higher). It stops at the bottom of the first arc.
			else if (h.fullLen > h.ropeLen + 0.5 && !grounded && !h.reelHeld && h.gripHand < 0 && !takeUp)
			{
				if (pmo.vel.z < 0) h.ropeLen = min(h.fullLen, h.ropeLen + PAYOUT);
				else h.fullLen = 0;
			}
			// CLIMB: a free hand on the grab bind, touching the rope, takes hold of it.
			double climbStep = 0;
			double along = 0;
			bool climbing = Climb(h, pmo, pn, a, b, n, d, minLen, maxLen, climbStep, along);
			bool pullUp = climbing && climbStep < 0;

			h.slack = !grounded || reeling || h.gripHand >= 0;
			if (d > maxLen + 64) { LetGo(h, false); continue; }
			if (grounded && !reeling && !pullUp)
			{
				// On your feet the rope pays out and takes in with you, so stepping off a
				// ledge swings at once from that length rather than dropping into slack.
				h.ropeLen = clamp(d, minLen, maxLen);
				if (level.maptime % 4 == (pn + hand) % 4)
				{
					if (!Sees(pmo, b, a)) { if (++h.losBad >= 3) { LetGo(h, false); continue; } }
					else h.losBad = 0;
				}
				if (level.maptime % 2 == 0) Log(h, "ground");
				continue;
			}

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
					if (moved.Length() < 64)
					{
						Vector3 tv = moved + (pmo.vel - lastSet[pn]);
						// AN AIMED SWING FROM A WALL rubs that wall (swing.zs): the arc dips toward the face it hangs
						// from, and the engine's slide along it can stop him for a tic, which read as the swing's end
						// (rig: 17.7 -> 4.6 along the wall in one tic). What the slide took ALONG that wall is given
						// back; what went into it stays gone.
						Vector3 toFace = h.struck - pmo.Pos;
						Vector2 n2 = h.hitDir.xy;
						if (h.aimed && h.anchorPlane == 0 && abs(h.hitDir.z) < 0.5 && n2.Length() > 0.5 && (toFace.xy dot n2.Unit()) < pmo.radius + 4)
						{
							n2 = n2.Unit();
							Vector2 lost = lastSet[pn].xy - moved.xy;
							Vector2 along = lost - n2 * (lost dot n2);
							if (along.Length() > 1.0) tv.xy += along;
						}
						pmo.vel = tv;
					}
				}
			}
			Vector3 v = pmo.vel;
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
				double cmax = ReelFull(pmo) + 8;
				double cl = corr.Length();
				if (cl > cmax) corr *= cmax / cl;
				v += corr;
				double vl = v.Length();
				if (!reeling && !climbing && d <= h.ropeLen + 1.0 && vl > 0.01) v *= vt / vl;
			}

			// A reel pulls in at about its own speed, not faster: the correction above
			// stacks on momentum and measured up to 29 u/tic reeling to a Cyberdemon.
			if (reeling)
			{
				double vin = -(v dot n);
				double vmax = (h.reelHeld ? max(reelRate, 1.0) : (h.takeRate > 0 ? h.takeRate : TAKEUP)) * 1.5;
				if (vin > vmax) v += n * (vin - vmax);
			}

			// The climbing hand moves the body exactly as far as it moved along the rope
			// (1:1, capped by rsqwp_climb_cap): the radial speed IS the hand's step, both
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
				if (fwd != 0 || side != 0)
				{
					Vector2 f2 = Actor.AngleToVector(pmo.Angle, 1);
					Vector2 s2 = (f2.y, -f2.x);
					Vector3 push = (f2.x * fwd + s2.x * side, f2.y * fwd + s2.y * side, 0);
					push -= n * (push dot n);
					v += push * RSQWP_Util.Num("rsqwp_pump", 0.25);
				}
				// THE SWING DIES DOWN. Two losses on the TANGENTIAL speed only (the radial
				// part is the rope's): air drag in proportion to speed (rsqwp_drag, per tic)
				// and a small constant rope/body friction (rsqwp_rope_friction, u/tic per
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
					double k = clamp(RSQWP_Util.Num("rsqwp_drag", 0.002), 0.0, 0.2);
					k = min(k + RSQWP_Perks.SteadyDrag(pmo, k, fwd == 0 && side == 0), 0.2);   // Steady Line (fx.zs)
					double f = max(0.0, RSQWP_Util.Num("rsqwp_rope_friction", 0.025));
					double ns = max(0.0, st * (1.0 - k) - f);
					double ang = acos(clamp(-n.z, -1.0, 1.0));   // from hanging straight down
					if (ns <= f && ang < 1.5 && fwd == 0 && side == 0) ns = 0;
					v = (v - vt) + vt * (ns / st);
				}
			}
			pmo.vel = v;
			CapSpeed(pmo);
			roped = true;
			if (!grounded) Tarzan(pmo);
			Carry(pmo);

			// The rope must see its anchor. Swing round a corner and it slips: checked
			// every 4 tics, three misses in a row let go.
			if (level.maptime % 4 == (pn + hand) % 4)
			{
				if (!Sees(pmo, b, a)) { if (++h.losBad >= 3) { LetGo(h, false); continue; } }
				else h.losBad = 0;
			}
			if (level.maptime % 2 == 0 || (climbing && climbStep != 0)) Log(h, (climbing && climbStep != 0) ? "climb" : h.reelHeld ? "reel" : takeUp ? "takeup" : (h.gripHand >= 0 ? "hold" : "swing"));
		}
		tracked[pn] = roped;
		if (roped) { lastPos[pn] = pmo.Pos; lastSet[pn] = pmo.vel; }
		// the release grace window's record: the speed the rope leaves him with, each tic in the air (Grace)
		if (roped && !(pmo.Pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj))
		{
			vHistAt[pn] = (vHistAt[pn] + 1) % 4;
			vHist[pn * 4 + vHistAt[pn]] = pmo.vel;
			vHistN[pn] = min(vHistN[pn] + 1, 4);
		}
		else vHistN[pn] = 0;
	}

	// ---- hand over hand (climb.zs says which hand may and where it is) -------------

	bool grabHeld[NHOOK];     // the grab bind is down (rsqwp_grip, or RSQ_DistanceGrab's grips)
	bool wantGrip[NHOOK];     // a press not yet turned into a hold (the hand may still be reaching)
	Vector3 poseOff[NHOOK];   // netgame: the hand's offset from the pawn, streamed (rsqwp_pose)
	int poseTic[NHOOK];

	// TWO WAYS TO HOLD, KEPT APART: a key (the grip's code, a Distance Grab key) and a touch (TouchTick). grabHeld is
	// either; a key's release never lets go of a touch hold, and a touch's release never lets go of a key's.
	bool keyHeld[NHOOK], touchHeld[NHOOK];
	void Grab(int pn, int hand, bool down, bool touch = false)
	{
		int i = pn * 2 + hand;
		if (touch) touchHeld[i] = down; else keyHeld[i] = down;
		grabHeld[i] = keyHeld[i] || touchHeld[i];
		if (down) { wantGrip[i] = true; return; }
		if (grabHeld[i]) return;   // the other way still holds
		wantGrip[i] = false;
		for (int k = 0; k < 2; k++)
		{
			let h = hooks[pn * 2 + k];
			if (h && h.gripHand == hand) { h.gripHand = -1; Log(h, "unhold"); }
		}
	}

	// ---- THE TOUCH HOLD (owner 2026-11-10: "Grip codes + touch fallback") -------------------------------------------
	// The grip's key codes are flaky on stock QZD 17.3 (owner: "qzd 17.3 doesnt play too well with grab"), so an EMPTY
	// hand also takes the rope with no button: laid on the rope and held still a moment. All in play, from the hand pose
	// every machine has (climb.zs HandOffset: the pose streamed by input.zs RenderOverlay), so every machine takes the
	// same hold on the same tic. The hold is the key's own (Grab(.., true)): Climb takes it, and Rope Climbing and Free Hand
	// Only rule it as ever; on a waiting aimed swing it is the off hand's grip (swing.zs SwingStart), as a key's is
	// (and, as with a key, that start is not yet a climbing hold). rsqwp_touch ("Touch Holds Rope") off: keys only.
	//   ON THE ROPE: within the grab's own reach of the rope's line (rsqwp_grab_reach, with Gesture Ease, as Climb takes a
	//     key's hold), and at least TOUCH_OUT_M out along it from where it meets the body: a hand hanging at your side is
	//     near the rope's root (the attach point is 0.6 of your height) and never takes it.
	//   ARMED: the hand has been off the rope (past the reach) since the rope bit, since its last touch hold, or since a key
	//     held it. A hand that was on the rope's line as it
	//     snagged (the off hand aiming the beam) is not grabbing; it must come to the rope.
	//   STILL: over TOUCH_TICS tics the hand, relative to the body, moved under TOUCH_STILL_MS on average (metres: XY over
	//     vr_vunits_per_meter, Z times pixelstretch first, as the series' throw samplers measure).
	//   EMPTY: strictly (HandFree strict): a touch never takes the rope with a gun in that hand.
	// Let go: the hand more than TOUCH_LEAVE reaches off every rope, no rope out, or the row turned off. A key's hold keeps
	// its own release (the key up); neither release ends the other's hold (Grab).
	const TOUCH_TICS = 6;          // ~0.17 s held still on the rope
	const TOUCH_STILL_MS = 0.4;    // m/s, the hand relative to the body, averaged over TOUCH_TICS
	const TOUCH_OUT_M = 0.3;       // m out along the rope from the body's attach point
	const TOUCH_LEAVE = 2.0;       // x the grab reach: a touch hold lets go past this
	int touchOn[NHOOK];            // 1 + tics the hand has been still on the rope (0: not counting)
	bool touchArmed[NHOOK];        // the hand has been off the rope since it came out
	Vector3 touchFrom[NHOOK];      // the hand's offset when this still spell began

	static double TouchMetres(Vector3 v)
	{
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double vu = c ? c.GetFloat() : 34.0;
		if (vu <= 1.0) vu = 34.0;
		double ps = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
		double z = v.z * ps;
		return sqrt(v.x * v.x + v.y * v.y + z * z) / vu;
	}

	// once a tic per player, before the ropes run (WorldTick), so a hold taken here is climbed on this tic
	void TouchTick(PlayerPawn pmo, int pn)
	{
		bool on = RSQWP_Util.Flag("rsqwp_touch", true) && RSQWP_Util.Opt("rsqwp_climb", 1) != 0;
		double reach = RSQWP_A11y.Wide(RSQWP_Util.Num("rsqwp_grab_reach", 16));
		int latched = 0;
		for (int k = 0; k < 2; k++) { let h = hooks[pn * 2 + k]; if (h && h.phase == RSQWP_Hook.PH_LATCH) latched++; }
		bool dbg = RSQWP_Util.Opt("rsqwp_debug", 0) >= 1;
		for (int g = 0; g < 2; g++)
		{
			int i = pn * 2 + g;
			bool ok; Vector3 off;
			[ok, off] = RSQWP_Climb.HandOffset(pmo, pn, g);
			// the nearest rope: how far off its line, and how far out along it from the body
			double dist = 1e9;
			Vector3 perp = (0, 0, 0), outV = (0, 0, 0);
			for (int k = 0; ok && k < 2; k++)
			{
				let h = hooks[pn * 2 + k];
				if (!h || h.phase != RSQWP_Hook.PH_LATCH) continue;
				Vector3 a = h.anchor, b = AttachPoint(pmo), hp = pmo.Pos + off;
				Vector3 ab = a - b;
				double l2 = ab dot ab;
				double t = l2 > 0.0001 ? clamp(((hp - b) dot ab) / l2, 0.0, 1.0) : 0.0;
				Vector3 q = b + ab * t;
				double dd = (hp - q).Length();
				if (dd < dist) { dist = dd; perp = hp - q; outV = q - b; }
			}
			if (touchHeld[i])
			{
				String why = !on ? "Touch Holds Rope is off" : latched == 0 ? "no rope out" : (ok && dist > reach * TOUCH_LEAVE) ? "the hand left the rope" : "";
				if (why == "") continue;
				if (dbg) Console.Printf("T_WP t%d h%d TOUCH LET GO: %s (%.2f m off the rope, lets go past %.2f m)", level.maptime, g, why,
					dist < 1e8 ? TouchMetres(perp) : -1., reach * TOUCH_LEAVE / 34.0);
				Grab(pn, g, false, true);
				touchArmed[i] = latched > 0 && ok && dist > reach;
				touchOn[i] = 0;
				continue;
			}
			if (!on || latched == 0) { touchOn[i] = 0; touchArmed[i] = false; continue; }
			// a key's hold: the touch stands aside, and after the key is let go the hand must leave the rope before a touch
			// takes it again (or letting go by the key, the hand still on the rope, would be taken straight back)
			if (keyHeld[i]) { touchArmed[i] = false; touchOn[i] = 0; continue; }
			if (!ok) { touchOn[i] = 0; continue; }
			if (dist > reach) { touchArmed[i] = true; touchOn[i] = 0; continue; }
			if (!touchArmed[i] || TouchMetres(outV) < TOUCH_OUT_M || !RSQWP_Climb.HandFree(pmo, g, true)) { touchOn[i] = 0; continue; }
			if (touchOn[i] == 0) { touchFrom[i] = off; touchOn[i] = 1; continue; }
			if (++touchOn[i] - 1 < TOUCH_TICS) continue;
			double ms = TouchMetres(off - touchFrom[i]) * 35.0 / TOUCH_TICS;
			if (ms >= TOUCH_STILL_MS) { touchFrom[i] = off; touchOn[i] = 1; continue; }   // still moving: the spell starts again here
			if (dbg) Console.Printf("T_WP t%d h%d TOUCH HOLD: still %.2f m/s over %d tics, %.2f m off the rope (reach %.2f m), %.2f m out along it",
				level.maptime, g, ms, TOUCH_TICS, TouchMetres(perp), reach / 34.0, TouchMetres(outV));
			touchOn[i] = 0;
			touchArmed[i] = false;
			Grab(pn, g, true, true);
		}
	}

	// Takes or keeps the hold, moves the rope's length by the hand, returns whether the
	// hand moved the body this tic and by how much along the rope (negative = up it).
	bool Climb(RSQWP_Hook h, PlayerPawn pmo, int pn, Vector3 a, Vector3 b, Vector3 n, double d,
		double minLen, double maxLen, out double step, out double along)
	{
		step = 0;
		along = 0;
		if (RSQWP_Util.Opt("rsqwp_climb", 1) == 0) { h.gripHand = -1; return false; }
		// a new press takes the rope over from the other hand once it touches it
		for (int g = 0; g < 2; g++)
		{
			int gi = pn * 2 + g;
			if (!wantGrip[gi] || h.gripHand == g) { if (h.gripHand == g) wantGrip[gi] = false; continue; }
			bool ok; Vector3 off;
			[ok, off] = RSQWP_Climb.HandOffset(pmo, pn, g);
			if (!ok || !RSQWP_Climb.HandFree(pmo, g)) continue;
			Vector3 hp = pmo.Pos + off;
			if (RSQWP_Climb.ToSegment(hp, a, b) > RSQWP_A11y.Wide(RSQWP_Util.Num("rsqwp_grab_reach", 16))) continue;   // Gesture Ease: x1..x2
			h.gripHand = g;
			h.gripPending = true;
			wantGrip[gi] = false;
			Log(h, String.Format("take h%d", g));
		}
		if (h.gripHand < 0) return false;
		if (!RSQWP_Climb.HandFree(pmo, h.gripHand)) { h.gripHand = -1; return false; }
		bool ok; Vector3 off;
		[ok, off] = RSQWP_Climb.HandOffset(pmo, pn, h.gripHand);
		if (!ok) { h.gripHand = -1; return false; }
		Vector3 hp = pmo.Pos + off;
		along = (hp - b) dot n;            // + = the hand is further down the rope than the body's attach point
		if (h.gripPending)
		{
			h.gripLastOff = off;           // where the hand closed
			h.gripPending = false;
			h.ropeLen = clamp(d, minLen, maxLen);
			return false;
		}
		// BY THE HAND'S STEP, not its place: the hand moved this much since last tic,
		// measured along the rope as it hangs now. Taken from the place instead (rope
		// length = hold point - hand offset along the rope), a still hand on a swinging
		// body drifted the length 6-14 units a swing as the rope turned (rig, full order).
		Vector3 dOff = off - h.gripLastOff;
		h.gripLastOff = off;
		double delta = -(dOff dot n);
		double cap = RSQWP_Util.Num("rsqwp_climb_cap", 8);
		// faster than the cap: the excess slips through the hand rather than being owed --
		// the body never catches up with motion the arm made a tic ago
		delta = clamp(delta, -cap, cap);
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
	bool UpdateAnchor(RSQWP_Hook h)
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
			// (a whip wrapped round an edge anchors on the corner; its wall is where it struck)
			Vector3 s = (h.whipped ? h.struck : h.anchor) - h.hitDir * 6;
			if (!tr.Trace(s, level.PointInSector(s.xy), h.hitDir, 16, TRACE_HitSky, RSQWP_Tracer.WALLMASK, true, h.owner)
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
		if (!tr.Trace(from, level.PointInSector(from.xy), d / l, l - 8, 0, RSQWP_Tracer.WALLMASK, true, pmo)) return true;
		return tr.Results.HitType == TRACE_HitNone;
	}

	// ---- housekeeping -----------------------------------------------------------

	// A level's actors die with it; the table must not point at them on the next.
	// After a load the table is rebuilt from the claws actually in the level, and
	// every bind reads as up (a release that happened before the save never comes).
	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < NHOOK; i++) { hooks[i] = null; held[i] = false; pressFired[i] = false; grabHeld[i] = false; keyHeld[i] = false; touchHeld[i] = false; touchOn[i] = 0; touchArmed[i] = false; wantGrip[i] = false; poseTic[i] = -100; }
		if (!e.IsSaveGame) return;
		let it = ThinkerIterator.Create("RSQWP_Hook");
		RSQWP_Hook h;
		while (h = RSQWP_Hook(it.Next()))
		{
			if (!h.owner || !h.owner.player) { h.Destroy(); continue; }
			int i = h.owner.PlayerNumber() * 2 + h.hand;
			if (i < 0 || i >= NHOOK || hooks[i]) { h.Destroy(); continue; }
			hooks[i] = h;
			h.gripHand = -1;   // a hold does not survive a load: the bind's release may never come
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
			if ((l is "RSQWP_Rope" || l is "RSQWP_Link") && keep.Find(l) == keep.Size()) l.Destroy();
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

	// ---- measurement (rsqwp_debug 1) --------------------------------------------

	void Log(RSQWP_Hook h, String what)
	{
		if (RSQWP_Util.Opt("rsqwp_debug", 0) < 1 || !h || !h.owner) return;
		let p = h.owner;
		Vector3 b = AttachPoint(p);
		Console.Printf("T_WP t%d h%d %s pos(%.1f %.1f %.1f) vel(%.2f %.2f %.2f) claw(%.1f %.1f %.1f) L%.1f d%.1f segs%d ms%.3f/%.3f scale%.2f grip%d free%d%d hoff%.2f pt%d%s",
			level.maptime, h.hand, what, p.Pos.x, p.Pos.y, p.Pos.z, p.vel.x, p.vel.y, p.vel.z,
			h.Pos.x, h.Pos.y, h.Pos.z, h.ropeLen, (h.anchor - b).Length(), h.segs.Size() + h.links.Size(), h.drawMs, tickMs, worldScale, h.gripHand, RSQWP_Climb.HandFree(p, 0), RSQWP_Climb.HandFree(p, 1), h.gripHand >= 0 ? poseOff[p.PlayerNumber() * 2 + h.gripHand].z : 0., h.gripHand >= 0 ? poseTic[p.PlayerNumber() * 2 + h.gripHand] : -1,
			h.victim ? String.Format(" victim %s (%.1f %.1f %.1f)", h.victim.GetClassName(), h.victim.Pos.x, h.victim.Pos.y, h.victim.Pos.z) : "");
	}
}
