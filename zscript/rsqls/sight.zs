// ULTIMATE BADASS QUEST LASER SIGHT.
//
// A laser on every gun in every mod, both hands, no per-weapon setup. It reads
// the hand's gun pose -- the same point and angles the engine fires a VR shot
// along (OverrideAttackPosDir) -- so it lands where the shot lands, for
// Brutal22Q, the WeaponDepot packs, vanilla, anything.
//
// PER HAND, EACH TIC: one trace and at most two objects.
//
//   THE BEAM  a model: three crossed planes round the bore, core + halo, soft
//             bell skin, additive -- a solid thread of light from any angle but
//             straight down it. Authored along +Z so Scale.Y is its EXACT length
//             and Scale.X its width; the actor is pitched 90 past the aim to lay
//             that axis along the beam. Depth-correct: walls cut it.
//             IT KNOWS THE ROOM: brightness falls with the sector's light level.
//             In a dark corridor the beam is a bar of light; in daylight it is a
//             faint thread and the spot does the work -- which is how real ones
//             look.
//   THE SPOT  PAINTED ON THE SURFACE, not a billboard: a WALLSPRITE turned to the
//             wall's own normal, a FLATSPRITE on floors and ceilings, a billboard
//             only on an actor. So it is round head-on and an ellipse on a wall
//             you see at an angle. Constant apparent size. A real dynamic light
//             of the beam's colour lights the surface round it (switchable).
//
// IT LEADS THE HAND. Script moves things 35 times a second; the renderer draws a
// blend of the last two tics, i.e. where the hand WAS. Placing the muzzle end
// and the spot one tic ahead cancels that (Prev + (Pos - Prev) f = hand + v f).
// RSQ_DistanceGrab D20 has the measurements: avg error 4.0 -> 1.1 cm on a slow
// sweep. The spot needs it most -- a small wrist turn moves a spot 10 m away
// across the wall fast.
//
// THE OPTIONS are UZDXREMA's laser menu, row for row where stock QuestZDoom can
// do it (docs/HANDOFF: the table): pointer and beam separately, pointer alpha and
// glow (bloom / real light / both), beam glow, emissive, taper, fade, length
// modes, target lock tighten and rate, any colour by picker -- per hand, beam and
// dot separately, per weapon slot, cycling, a headshot colour -- and IR, visible
// only through the light amplification goggles (PowerLightAmp).
//
// Visuals only. Nothing here changes damage, aim, or the playsim of any other
// mod -- it cannot break a weapon, only draw on top of it.

// THE BEAM IS THREE MODELS NOW: the core, the halo round it (its own brightness:
// "beam glow"), and a second core stacked on the first for "emissive" -- script
// cannot push one additive draw past full brightness, two can. Each has ten
// frames: A-E the taper levels, F-J the same with the fade-out texture
// (tools/gen_assets.py). The frame is chosen by writing `frame`; the dummy states
// below exist because MODELDEF only draws a frame some state names.
class RSQLS_Beam : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+INTERPOLATEANGLES +BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States
	{
	Spawn: RSLB A -1 Bright; Stop;
	Frames: RSLB ABCDEFGHIJ -1; Stop;
	}
}
class RSQLS_Emissive : RSQLS_Beam
{
	States
	{
	Spawn: RSLE A -1 Bright; Stop;
	Frames: RSLE ABCDEFGHIJ -1; Stop;
	}
}
class RSQLS_Halo : RSQLS_Beam
{
	States
	{
	Spawn: RSLH A -1 Bright; Stop;
	Frames: RSLH ABCDEFGHIJ -1; Stop;
	}
}

class RSQLS_Spot : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSLS A -1 Bright; Stop; }
}

// The pointer's glow: a wide soft bloom laid over the spot, same placement.
class RSQLS_Glow : RSQLS_Spot
{
	States { Spawn: RSLG A -1 Bright; Stop; }
}

// The haptic tick on a toggle. NOT a missile -- see RSQ_DistanceGrab feel.zs:
// Brutal22Q's recoil and flash hooks treat every player missile as a shot except
// RSVR_Buzz by name; without +MISSILE, P_CheckMissileSpawn treats this as an MBF
// grenade, the per-hand vibrate still fires, and WorldThingSpawned reports
// bMissile false to every listener.
class RSQLS_Buzz : Actor
{
	Default
	{
		+NOCLIP +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1; Speed 0;
		DamageType "RSQLSHaptic";
		RenderStyle "None";
	}
	States { Spawn: TNT1 A 1; Stop; }
}

class RSQLS_Sight : EventHandler
{
	const BEAM_L = 256.0;       // tools/gen_assets.py
	const LEAD_JUMP = 17.0;     // map units in one tic (~0.5 m) that is not a hand
	const NTAPER = 5;           // frames A-E; F-J the same with the fade texture
	static const double TAPERS[] = { 1.0, 0.7, 0.45, 0.25, 0.1 };

	private Actor beam[2];
	private Actor halo[2];
	private Actor emis[2];
	private Actor spot[2];
	private Actor glow[2];
	private bool  beamShown[2];
	private bool  spotShown[2];

	// Which hands drew a laser last tic (bit 0 main, bit 1 off), for other mods
	// through RSQLS_SightService. Console player only, like the drawing.
	transient int liveMask;
	static int LiveHands()
	{
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		return me ? me.liveMask : 0;
	}

	// The light currently attached to each spot, so it is only re-attached when
	// it changes -- A_AttachLight rebuilds the light.
	private int   lightColor[2];
	private int   lightRadius[2];
	private bool  lightOn[2];

	// Leading (see header).
	private Vector3 lastMuzzle[2], lastHit[2];
	private bool    muzzlePrimed[2], hitPrimed[2];

	// Toggle edge detection, for the haptic tick.
	private bool wasOn[2];
	private bool togglePrimed;

	// ---- placement helpers ----------------------------------------------------

	private Actor Ensure(Actor a, Class<Actor> cls)
	{
		if (a) return a;
		a = Actor.Spawn(cls, (0, 0, 0));
		if (a) a.bINVISIBLE = true;
		return a;
	}

	// A piece coming back from hidden TELEPORTS into place rather than streaking
	// in from wherever it was left.
	private static void Put(Actor a, bool wasShown, Vector3 pos)
	{
		if (!wasShown) { a.SetOrigin(pos, false); a.ClearInterpolation(); }
		else a.SetOrigin(pos, true);
		a.bINVISIBLE = false;
	}

	private static void Hide(Actor a) { if (a) a.bINVISIBLE = true; }

	private void HideBeam(int h) { Hide(beam[h]); Hide(halo[h]); Hide(emis[h]); beamShown[h] = false; }
	private void HideSpot(int h)
	{
		if (spot[h])
		{
			spot[h].bINVISIBLE = true;
			if (lightOn[h]) { spot[h].A_RemoveLight('RSQLS'); lightOn[h] = false; }
		}
		Hide(glow[h]);
		spotShown[h] = false;
		hitPrimed[h] = false;
	}
	private void HideHand(int h) { HideBeam(h); HideSpot(h); muzzlePrimed[h] = false; }

	// ---- which hands have a laser right now -----------------------------------
	private bool HandLive(PlayerInfo p, int h)
	{
		if (!RSQLS_Hand.Flag(h == 0 ? "rsqls_main" : "rsqls_off", p, true)) return false;
		Weapon w = (h == 0) ? p.ReadyWeapon : p.OffhandWeapon;
		if (!w) return false;
		// NOTHING TO AIM: a melee weapon (fist, chainsaw, the QuestSaber), or a
		// hand that is not a gun at all. CHEATNOTWEAPON is the stock marker for
		// the second -- it is what keeps a thing out of `give weapons` -- and
		// every off-hand utility in the family carries it: RS_ShieldSawQ's
		// shield, the QuestSaber's Force hand, RSQ_Hands. Found in the rig:
		// with the shield drawn, a laser came out of the shield.
		if ((w.bMELEEWEAPON || w.bCHEATNOTWEAPON) && !RSQLS_Hand.Flag("rsqls_show_melee", p, false)) return false;
		if (RSQLS_Hand.Flag("rsqls_ready_only", p, false))
		{
			int ready = (h == 0) ? (WF_WEAPONREADY | WF_WEAPONREADYALT)
			                     : (WF_OFFHANDREADY | WF_OFFHANDREADYALT);
			if (!(p.WeaponState & ready)) return false;
		}
		return true;
	}

	// ---- the toggle's tick ----------------------------------------------------
	private void Buzz(PlayerPawn pmo, int h)
	{
		if (!RSQLS_Hand.Flag("rsqls_haptics", pmo.player, true)) return;
		pmo.SpawnPlayerMissile("RSQLS_Buzz", pmo.angle, noautoaim: true,
			aimflags: (h == 1) ? ALF_ISOFFHAND : 0);
	}

	// ---- the colours (UZDXREMA's colour block, on runtime translations) -------
	//
	// Order of precedence, lowest first: the colour mode's base colour; the
	// weapon slot's colour; a colour the WEAPON asks for (any loaded mod's
	// LaserColorService -- absent-safe, found by name at run time); cycling;
	// on a live hostile the target colour; on a lined-up headshot the headshot
	// colour. Returns 0xRRGGBB.
	private int ColorOf(PlayerInfo p, int h, Weapon w, bool isDot, bool hostile, bool head)
	{
		int mode = RSQLS_Hand.Opt("rsqls_color_mode", p, 1);
		int beamCol = RSQLS_Hand.Opt((mode == 0 || h == 0) ? "rsqls_col_main" : "rsqls_col_off", p, 0xFF2010);
		int c = beamCol;
		bool own = false;    // the dot has its own colour (mode 2)
		if (isDot && mode == 2)
		{
			c = RSQLS_Hand.Opt(h == 0 ? "rsqls_col_dot_main" : "rsqls_col_dot_off", p, 0xFF2010);
			own = true;
		}

		if (w && !own && RSQLS_Hand.Flag("rsqls_col_per_slot", p, false))
		{
			int sl = w.SlotNumber;
			if (sl >= 0 && sl <= 9)
				c = RSQLS_Hand.Opt(String.Format("rsqls_col_slot%d", sl), p, c);
		}

		if (w)
		{
			let it = ServiceIterator.Find("LaserColorService");
			Service sv;
			while (sv = it.Next())
			{
				int r = sv.GetInt("laser.color", w.GetClassName(), h, isDot ? 1.0 : 0.0, w, 'RSQ_LaserSight');
				if (r >= 0) { c = r & 0xFFFFFF; break; }
			}
		}

		if (RSQLS_Hand.Flag("rsqls_cycle", p, false) && (!isDot || RSQLS_Hand.Flag("rsqls_cycle_dot", p, true)))
		{
			double speed = RSQLS_Hand.Num("rsqls_cycle_speed", p, 60.0);
			// 36 hues (10 degrees apart) so the translation cache holds them all.
			double deg = level.maptime * speed / TICRATE + h * 180.0;
			c = RSQLS_Colors.Hue(floor(deg / 10.0) * 10.0);
		}

		if (hostile && RSQLS_Hand.Flag("rsqls_lock", p, true) && RSQLS_Hand.Flag("rsqls_target_recolor", p, false))
			c = RSQLS_Hand.Opt("rsqls_col_target", p, 0xFFE020);

		if (head && RSQLS_Hand.Flag("rsqls_head", p, false))
		{
			int hc = RSQLS_Hand.Opt("rsqls_col_head", p, 0xFFFFFF);
			if (RSQLS_Hand.Flag("rsqls_head_pulse", p, true))
			{
				double hz = RSQLS_Hand.Num("rsqls_head_pulse_hz", p, 4.0);
				double ph = 0.5 + 0.5 * sin(level.maptime * hz * 360.0 / TICRATE);
				// Quantised to 8 steps, again for the cache.
				c = RSQLS_Colors.Mix(c, hc, floor(ph * 8.0) / 8.0);
			}
			else c = hc;
		}
		return c & 0xFFFFFF;
	}

	override void WorldTick()
	{
		liveMask = 0;
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;

		// Toggle feedback first, whatever else is going on.
		for (int h = 0; h < 2; h++)
		{
			bool on = RSQLS_Hand.Flag(h == 0 ? "rsqls_main" : "rsqls_off", p, true);
			if (togglePrimed && on != wasOn[h]) Buzz(pmo, h);
			wasOn[h] = on;
		}
		togglePrimed = true;

		bool wantDot  = RSQLS_Hand.Flag("rsqls_pointer", p, true);
		bool wantBeam = RSQLS_Hand.Flag("rsqls_beam", p, true);
		// IR: invisible to the naked eye. The light amplification goggles
		// (Doom's PowerLightAmp, from the Infrared pickup) show it.
		bool ir = RSQLS_Hand.Flag("rsqls_ir", p, false);
		bool irVisible = ir && pmo.FindInventory("PowerLightAmp", true) != null;

		if (pmo.Health <= 0 || !RSQLS_Hand.Flag("rsqls_on", p, true)
			|| (!wantDot && !wantBeam) || (ir && !irVisible))
		{
			HideHand(0); HideHand(1);
			return;
		}

		for (int h = 0; h < 2; h++)
		{
			if (!HandLive(p, h)) { HideHand(h); continue; }
			beam[h] = Ensure(beam[h], "RSQLS_Beam");
			halo[h] = Ensure(halo[h], "RSQLS_Halo");
			emis[h] = Ensure(emis[h], "RSQLS_Emissive");
			spot[h] = Ensure(spot[h], "RSQLS_Spot");
			glow[h] = Ensure(glow[h], "RSQLS_Glow");
			if (!beam[h] || !halo[h] || !emis[h] || !spot[h] || !glow[h]) continue;
			DrawHand(h, pmo, p, wantBeam, wantDot);
			liveMask |= 1 << h;
		}
	}

	// One beam piece: placed, aimed, sized, framed, tinted.
	private static void Lay(Actor b, bool shown, Vector3 at, double yaw, double pit,
		double w, double len, int fr, double alpha, TranslationID tint)
	{
		if (alpha <= 0.004) { b.bINVISIBLE = true; return; }
		Put(b, shown, at);
		b.Angle = yaw;
		b.Pitch = pit + 90;     // lay the model's up axis along the aim
		b.Roll  = 0;
		b.Scale = (w, len / BEAM_L);
		b.frame = fr;
		b.Alpha = min(1.0, alpha);
		b.Translation = tint;
	}

	private void DrawHand(int h, PlayerPawn pmo, PlayerInfo p, bool wantBeam, bool wantDot)
	{
		Weapon w = (h == 0) ? p.ReadyWeapon : p.OffhandWeapon;

		// ---- the muzzle: a physical offset from the grip, in metres --------
		Vector3 muzzle = RSQLS_Hand.Grip(pmo, h) + RSQLS_Hand.Offset(pmo, h,
			RSQLS_Hand.Num("rsqls_muzzle_fwd",  p, 0.18),
			RSQLS_Hand.Num("rsqls_muzzle_up",   p, 0.03),
			RSQLS_Hand.Num("rsqls_muzzle_side", p, 0.0));

		// ---- the trace: from the REAL muzzle, along the gun ------------------
		// TRF_ABSPOSITION with coordinates computed here and zero offsets:
		// P_LineTrace accumulates offsets onto an uninitialised vector exactly
		// when OverrideAttackPosDir is true, which in VR is always.
		double range = RSQLS_Hand.Num("rsqls_range", p, 2048.0);
		FLineTraceData t;
		bool hit = pmo.LineTrace(RSQLS_Hand.Yaw(pmo, h), range, RSQLS_Hand.Pitch(pmo, h),
			TRF_ABSPOSITION, muzzle.z, muzzle.x, muzzle.y, t);
		bool sky = hit && t.HitType == FLineTraceData.TRACE_HasHitSky;
		Vector3 end = hit ? t.HitLocation : (muzzle + RSQLS_Hand.Dir(pmo, h) * range);

		// ---- lead: draw a tic ahead (see header) ---------------------------
		double lead = clamp(RSQLS_Hand.Num("rsqls_lead", p, 1.0), 0.0, 2.0);
		Vector3 drawMuzzle = muzzle, drawEnd = end;
		if (muzzlePrimed[h])
		{
			Vector3 v = muzzle - lastMuzzle[h];
			if (v.Length() <= LEAD_JUMP) drawMuzzle = muzzle + v * lead;
		}
		lastMuzzle[h] = muzzle; muzzlePrimed[h] = true;
		if (hit && !sky && hitPrimed[h])
		{
			Vector3 v = end - lastHit[h];
			// The far end legitimately moves much faster than the hand; only a
			// jump onto a different surface is refused.
			if (v.Length() <= LEAD_JUMP * 12) drawEnd = end + v * lead;
		}
		if (hit && !sky) { lastHit[h] = end; hitPrimed[h] = true; }
		else hitPrimed[h] = false;

		// ---- what it is on ------------------------------------------------------
		Actor onWho = (hit && t.HitType == FLineTraceData.TRACE_HitActor) ? t.HitActor : null;
		bool hostile = onWho && onWho.bISMONSTER && onWho.Health > 0 && !onWho.bFRIENDLY;
		// A LINED-UP HEADSHOT, approximately: the hit lands in the top fifth of
		// the body. What counts as a head is the gameplay mod's business; this
		// only shows it (UZDXREMA's Headshot Reaction, as near as script gets).
		bool head = hostile && t.HitLocation.z >= onWho.Pos.z + onWho.Height * 0.8;

		int beamRgb = ColorOf(p, h, w, false, hostile, head);
		int dotRgb  = ColorOf(p, h, w, true,  hostile, head);
		TranslationID beamTint = RSQLS_Colors.Tint(beamRgb);
		TranslationID dotTint  = RSQLS_Colors.Tint(dotRgb);

		// The room's light at the muzzle, 0..1. Dark rooms show the beam.
		Sector sec = Level.PointInSector(muzzle.xy);
		double lit = sec ? clamp(sec.lightlevel / 255.0, 0.0, 1.0) : 0.5;

		// ---- the beam ----------------------------------------------------------
		Vector3 toEnd = drawEnd - drawMuzzle;
		double yaw, pit, len;
		[yaw, pit, len] = RSQLS_Hand.RoomAim(toEnd);
		// LENGTH: full (to what it hits), half, or a fixed reach. Lengths here are
		// room length, which is what Scale.Y measures.
		int lmode = RSQLS_Hand.Opt("rsqls_beam_length", p, 0);
		double drawn = len;
		if (lmode == 1) drawn = len * 0.5;
		else if (lmode == 2) drawn = min(len, RSQLS_Hand.Num("rsqls_beam_fixed", p, 200.0));
		// FADE: drawn no further than this, dying away over its last half.
		double fade = RSQLS_Hand.Num("rsqls_beam_fade", p, 0.0);
		bool fading = fade > 0;
		if (fading) drawn = min(drawn, fade);
		// TAPER: the nearest pre-built frame.
		double tp = clamp(RSQLS_Hand.Num("rsqls_beam_taper", p, 1.0), 0.05, 1.0);
		int fr = 0;
		for (int k = 1; k < NTAPER; k++)
			if (abs(TAPERS[k] - tp) < abs(TAPERS[fr] - tp)) fr = k;
		if (fading) fr += NTAPER;

		if (wantBeam && drawn > 2)
		{
			double litFade = RSQLS_Hand.Num("rsqls_beam_daylight", p, 0.35);
			double a = RSQLS_Hand.Num("rsqls_beam_a", p, 0.75) * (1.0 - (1.0 - litFade) * lit);
			if (hostile && RSQLS_Hand.Flag("rsqls_lock", p, true)) a *= 1.35;
			double bw = RSQLS_Hand.Num("rsqls_beam_w", p, 1.0);
			double emissive = clamp(RSQLS_Hand.Num("rsqls_beam_emissive", p, 1.0), 1.0, 2.0);
			double glowA = a * clamp(RSQLS_Hand.Num("rsqls_beam_glow", p, 1.0), 0.0, 3.0) * 0.6;
			bool shown = beamShown[h];
			Lay(beam[h], shown, drawMuzzle, yaw, pit, bw, drawn, fr, a, beamTint);
			Lay(halo[h], shown, drawMuzzle, yaw, pit, bw, drawn, fr, glowA, beamTint);
			Lay(emis[h], shown, drawMuzzle, yaw, pit, bw, drawn, fr, a * (emissive - 1.0), beamTint);
			beamShown[h] = true;
		}
		else HideBeam(h);

		// ---- the spot: painted on what it hit ----------------------------------
		double dist = (end - muzzle).Length();
		double dotRange = RSQLS_Hand.Num("rsqls_dot_range", p, 0.0);
		if (!wantDot || !hit || sky || (dotRange > 0 && dist > dotRange)) { HideSpot(h); return; }

		let s = spot[h];
		Vector3 at = drawEnd;
		bool wallS = false, flatS = false;
		double sAngle = s.Angle;
		if (t.HitType == FLineTraceData.TRACE_HitWall && t.HitLine)
		{
			// The wall's own normal, turned to face the MUZZLE. Not from
			// FLineTraceData.LineSide: trusting that flag's sense put the spot
			// 0.4 units on the far side of the wall, where the depth test hid it
			// (found in the rig, 2026-10-26). Facing the gun is true by
			// construction, whichever way the line was drawn.
			Vector2 d = t.HitLine.delta;
			Vector2 n = (d.y, -d.x);
			double nl = n.Length();
			if (nl > 0) n /= nl;
			if ((n dot (muzzle.xy - end.xy)) < 0) n = -n;
			wallS = true;
			sAngle = VectorAngle(n.x, n.y);
			at += (n.x, n.y, 0) * 0.4;           // a hair off the wall, never inside it
		}
		else if (t.HitType == FLineTraceData.TRACE_HitFloor)
		{
			flatS = true;
			at.z += 0.3;
		}
		else if (t.HitType == FLineTraceData.TRACE_HitCeiling)
		{
			flatS = true;
			at.z -= 0.3;
		}
		else
		{
			// An actor: a billboard, pulled toward you so it sits on its front.
			if (len > 1) at += (drawMuzzle - drawEnd) * (2.0 / len);
		}
		s.bWALLSPRITE = wallS; s.bFLATSPRITE = flatS; s.Angle = sAngle;
		bool shownS = spotShown[h];
		Put(s, shownS, at);
		spotShown[h] = true;

		// CONSTANT APPARENT SIZE: about half a degree across at any range (a real
		// laser sight reads at roughly that), with a floor so it never shrinks to
		// nothing up close.
		double sc = RSQLS_Hand.Num("rsqls_spot_size", p, 1.0) * (0.03 + dist / 2000.0);
		if (hostile && RSQLS_Hand.Flag("rsqls_lock", p, true))
		{
			// TARGET LOCK: it TIGHTENS onto the target and bites at the pulse rate.
			double tighten = clamp(RSQLS_Hand.Num("rsqls_lock_tighten", p, 0.0), 0.0, 0.9);
			double hz = RSQLS_Hand.Num("rsqls_lock_rate", p, 2.2);
			sc *= (1.0 - tighten) * (1.25 + 0.12 * sin(level.maptime * hz * 360.0 / TICRATE));
		}
		s.Scale = (sc, sc);
		s.Alpha = clamp(RSQLS_Hand.Num("rsqls_spot_a", p, 1.0), 0.0, 1.0);
		s.Translation = dotTint;

		// ---- the glow: off, a bloom, a real light, or both ----------------------
		int gmode = RSQLS_Hand.Opt("rsqls_glow", p, 3);
		double gscale = clamp(RSQLS_Hand.Num("rsqls_glow_scale", p, 1.8), 1.1, 4.0);
		double gint = clamp(RSQLS_Hand.Num("rsqls_glow_int", p, 1.0), 0.1, 4.0);
		let g = glow[h];
		if (gmode == 1 || gmode == 3)
		{
			g.bWALLSPRITE = wallS; g.bFLATSPRITE = flatS; g.Angle = sAngle;
			// A hair in front of the spot so the two never fight for depth.
			Vector3 gat = at;
			if (wallS) gat += (cos(sAngle), sin(sAngle), 0) * 0.1;
			else if (flatS) gat.z += (t.HitType == FLineTraceData.TRACE_HitFloor) ? 0.1 : -0.1;
			Put(g, shownS && !g.bINVISIBLE, gat);
			g.Scale = (sc * gscale, sc * gscale);
			g.Alpha = clamp(0.30 * gint * s.Alpha, 0.0, 1.0);
			g.Translation = dotTint;
		}
		else Hide(g);

		if (gmode >= 2)
		{
			int rad = int(clamp((10.0 + dist / 90.0) * gscale / 1.8, 6.0, 96.0));
			// Intensity scales the light's colour: the only brightness a point
			// light has.
			int lc = RSQLS_Colors.Mix(0, dotRgb, clamp(gint, 0.0, 1.0));
			if (!lightOn[h] || lightColor[h] != lc || abs(lightRadius[h] - rad) > 2)
			{
				s.A_AttachLight('RSQLS', DynamicLight.PointLight, lc, rad, rad,
					DynamicLight.LF_ATTENUATE);
				lightOn[h] = true; lightColor[h] = lc; lightRadius[h] = rad;
			}
		}
		else if (lightOn[h]) { s.A_RemoveLight('RSQLS'); lightOn[h] = false; }
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int h = 0; h < 2; h++)
		{
			beamShown[h] = false; spotShown[h] = false; lightOn[h] = false;
			muzzlePrimed[h] = false; hitPrimed[h] = false;
		}
	}
}

// WHAT THE LASER IS DOING, FOR ANY MOD THAT ASKS -- found by name, so a mod that
// asks never links against this one and an absent laser is simply no answer.
//   GetInt("laser.active", "", hand)  -> 1 if a laser (beam or dot) drew on that
//                                        hand (0 main, 1 off) last tic, else 0
// RSQ_DistanceGrab asks this so its grab beam stands down on a hand the laser
// already lights.
class RSQLS_SightService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "laser.active")
			return (RSQLS_Sight.LiveHands() >> (intArg & 1)) & 1;
		return -1;
	}
}
