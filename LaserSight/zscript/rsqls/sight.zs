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

// PHASE 3 pieces. A dot along a thrown weapon's arc; the spread ring (RSLR, a
// thin circle at 0.9 of the sprite's radius); the range readout, a quad model
// wearing the canvas texture RSLRANGE that the UI writes (see UiTick).
class RSQLS_ArcDot : RSQLS_Spot {}
class RSQLS_Ring : RSQLS_Spot
{
	States { Spawn: RSLR A -1 Bright; Stop; }
}
class RSQLS_Readout : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSLQ A -1 Bright; Stop; }
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
	transient int beamMask;   // the same, beam only
	static int BeamHands()
	{
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		return me ? me.beamMask : 0;
	}
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

	// ---- phase 3 ------------------------------------------------------------
	const ARC_N = 24;          // dots along a thrown weapon's arc, per hand
	const ARC_TICS = 140;      // the longest flight simulated: four seconds
	const RING_PX = 28.8;      // RSLR's ring radius in pixels (0.9 x 32)
	private Actor arcDot[48];  // ARC_N per hand
	private bool  arcShown[2];
	private Actor ring[2];
	private Actor readout;
	// The simulated path (no dynamic arrays of vectors on 4.12-4.14: three of doubles).
	private transient Array<double> arcX, arcY, arcZ;
	private void ArcClear() { arcX.Clear(); arcY.Clear(); arcZ.Clear(); }
	private void ArcPush(Vector3 v) { arcX.Push(v.x); arcY.Push(v.y); arcZ.Push(v.z); }
	private Vector3 ArcAt(int i) { return (arcX[i], arcY[i], arcZ[i]); }
	// The weapon pack's muzzle point (LaserMuzzleService), cached per weapon class.
	private transient String mzKey[2];
	private transient bool   mzGot[2];
	private transient double mzF[2], mzU[2], mzS[2];
	// What the readout shows: room metres to the hit (0 = nothing), its colour.
	transient double rangeM[2];
	transient int    rangeRgb[2];
	transient double readM;
	transient int    readRgb;

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
	private void HideArc(int h)
	{
		if (!arcShown[h]) return;
		for (int i = 0; i < ARC_N; i++) Hide(arcDot[h * ARC_N + i]);
		arcShown[h] = false;
	}
	private void HideHand(int h) { HideBeam(h); HideSpot(h); HideArc(h); Hide(ring[h]); rangeM[h] = 0; muzzlePrimed[h] = false; }

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
		liveMask = 0; beamMask = 0;
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
			UpdateReadout(pmo, p);
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
			// What actually drew (review, 10-26): a dot-only laser that hits nothing is no light.
			if (beamShown[h] || spotShown[h]) liveMask |= 1 << h;
			if (beamShown[h]) beamMask |= 1 << h;
		}
		UpdateReadout(pmo, p);
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
		// A weapon pack that knows where its muzzles are says so through
		// LaserMuzzleService (see MuzzleFor); otherwise the one default.
		double mf = RSQLS_Hand.Num("rsqls_muzzle_fwd",  p, 0.18);
		double mu = RSQLS_Hand.Num("rsqls_muzzle_up",   p, 0.03);
		double ms = RSQLS_Hand.Num("rsqls_muzzle_side", p, 0.0);
		if (w)
		{
			bool got; double f, u, sd;
			[got, f, u, sd] = MuzzleFor(h, w);
			if (got) { mf = f; mu = u; ms = sd; }
		}
		Vector3 muzzle = RSQLS_Hand.Grip(pmo, h) + RSQLS_Hand.GunOffset(pmo, h, mf, mu, ms);

		// A THROWN WEAPON (grenades): once it has been seen firing, the line is
		// the ballistic path its projectile will take, and the spot is where it
		// lands (learn.zs). The straight beam would point at the wrong place.
		bool arcOn = false;
		double aSp, aGr, aEl, aYw;
		if (w && RSQLS_Hand.Flag("rsqls_arc", p, true))
			[arcOn, aSp, aGr, aEl, aYw] = RSQLS_Learn.Arc(w);
		if (arcOn && !RSQLS_Hand.Flag("rsqls_arc_beam", p, false)) wantBeam = false;

		// ---- the trace: from the REAL muzzle, along the gun ------------------
		// TRF_ABSPOSITION with coordinates computed here and zero offsets:
		// P_LineTrace accumulates offsets onto an uninitialised vector exactly
		// when OverrideAttackPosDir is true, which in VR is always.
		double range = RSQLS_Hand.Num("rsqls_range", p, 2048.0);
		FLineTraceData t;
		bool hit;
		Vector3 end;
		if (arcOn)
		{
			// One tic at a time, exactly as the engine will move it: position
			// plus velocity, then gravity off the velocity. Each tic's segment is
			// a LineTrace, so the arc stops at the first wall, floor or body.
			ArcClear();
			double g = level.gravity * aGr * 0.00125;
			Sector s0 = level.PointInSector(muzzle.xy);
			if (s0) g *= s0.gravity;
			Vector3 v = RSQLS_Hand.Fwd(RSQLS_Hand.Yaw(pmo, h) + aYw, RSQLS_Hand.Pitch(pmo, h) + aEl) * aSp;
			Vector3 pos = muzzle;
			hit = false;
			ArcPush(muzzle);
			for (int i = 0; i < ARC_TICS; i++)
			{
				Vector3 np = pos + v;
				v.z -= g;
				Vector3 seg = np - pos;
				double sl = seg.Length();
				if (sl > 0.01 && pmo.LineTrace(VectorAngle(seg.x, seg.y), sl, -atan2(seg.z, seg.xy.Length()),
					TRF_ABSPOSITION, pos.z, pos.x, pos.y, t))
				{
					hit = true;
					ArcPush(t.HitLocation);
					break;
				}
				ArcPush(np);
				pos = np;
			}
			end = ArcAt(arcX.Size() - 1);
		}
		else
		{
			hit = pmo.LineTrace(RSQLS_Hand.Yaw(pmo, h), range, RSQLS_Hand.DoomPitch(pmo, h),
				TRF_ABSPOSITION, muzzle.z, muzzle.x, muzzle.y, t);
			end = hit ? t.HitLocation : (muzzle + RSQLS_Hand.Dir(pmo, h) * range);
		}
		bool sky = hit && t.HitType == FLineTraceData.TRACE_HasHitSky;
		{
			Vector3 rd = end - muzzle;
			rangeM[h] = (hit && !sky) ? (rd.x, rd.y, rd.z * RSQLS_Hand.PIXELSTRETCH).Length() / RSQLS_Hand.UPM : 0;
		}

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
		rangeRgb[h] = dotRgb;
		if (arcOn) LayArc(h, dotTint, p); else HideArc(h);

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
		if (!wantDot || !hit || sky || (dotRange > 0 && dist > dotRange)) { HideSpot(h); Hide(ring[h]); return; }

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

		// ---- the spread ring: where this gun's shots can land (learn.zs) -------
		LayRing(h, w, p, at, dist, wallS, flatS, sAngle, arcOn, dotTint, shownS);

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

	// The arc: ARC_N dots spaced evenly by length along the simulated path.
	private void LayArc(int h, TranslationID tint, PlayerInfo p)
	{
		int n = arcX.Size();
		if (n < 2) { HideArc(h); return; }
		double total = 0;
		for (int i = 1; i < n; i++) total += (ArcAt(i) - ArcAt(i - 1)).Length();
		if (total < 1) { HideArc(h); return; }
		double size = RSQLS_Hand.Num("rsqls_arc_size", p, 1.0) * 0.022;
		double alpha = clamp(RSQLS_Hand.Num("rsqls_arc_a", p, 0.8), 0.0, 1.0);
		int seg = 1;
		double segStart = 0, segLen = (ArcAt(1) - ArcAt(0)).Length();
		for (int k = 0; k < ARC_N; k++)
		{
			int slot = h * ARC_N + k;
			arcDot[slot] = Ensure(arcDot[slot], "RSQLS_ArcDot");
			let d = arcDot[slot];
			if (!d) continue;
			double want = total * (k + 1) / (ARC_N + 1);
			while (seg < n - 1 && segStart + segLen < want)
			{
				segStart += segLen;
				seg++;
				segLen = (ArcAt(seg) - ArcAt(seg - 1)).Length();
			}
			double f = segLen > 0.001 ? clamp((want - segStart) / segLen, 0.0, 1.0) : 0.0;
			Vector3 at = ArcAt(seg - 1) + (ArcAt(seg) - ArcAt(seg - 1)) * f;
			Put(d, arcShown[h], at);
			d.Scale = (size, size);
			d.Alpha = alpha;
			d.Translation = tint;
		}
		arcShown[h] = true;
	}

	// The ring: the widest spread this gun has shown, drawn at the spot as an
	// ellipse (horizontal and vertical spread separately), facing the surface the
	// way the spot does. Not on an arc, and not before the gun has fired.
	private void LayRing(int h, Weapon w, PlayerInfo p, Vector3 at, double dist,
		bool wallS, bool flatS, double sAngle, bool arcOn, TranslationID tint, bool spotWasShown)
	{
		double sh, sv;
		[sh, sv] = RSQLS_Learn.Spread(w);
		double minDeg = RSQLS_Hand.Num("rsqls_spread_min", p, 0.75);
		if (arcOn || !RSQLS_Hand.Flag("rsqls_spread", p, true) || max(sh, sv) < minDeg)
		{
			Hide(ring[h]);
			return;
		}
		ring[h] = Ensure(ring[h], "RSQLS_Ring");
		let r = ring[h];
		if (!r) return;
		if (sv < minDeg) sv = sh;    // a purely sideways spread still draws a circle's height
		if (sh < minDeg) sh = sv;
		double rh = dist * tan(sh), rv = dist * tan(sv);
		r.bWALLSPRITE = wallS; r.bFLATSPRITE = flatS; r.Angle = sAngle;
		Vector3 rat = at;
		if (wallS) rat += (cos(sAngle), sin(sAngle), 0) * 0.2;
		else if (flatS) rat.z += 0.2;
		Put(r, spotWasShown && !r.bINVISIBLE, rat);
		r.Scale = (rh / RING_PX, rv / RING_PX);
		r.Alpha = clamp(RSQLS_Hand.Num("rsqls_spread_a", p, 0.6), 0.0, 1.0);
		r.Translation = tint;
	}

	// THE PACK'S OWN MUZZLE. A weapon pack (the WeaponDepot cards, say) can tell
	// the laser where each gun's barrel ends by providing a Service:
	//   class MyPackMuzzles : Service {
	//     override String GetString(String request, String stringArg, int intArg, ...)
	//     // request "laser.muzzle", stringArg = weapon class name, intArg = hand
	//     // -> "forward up side" in METRES from the grip, or "" for "don't know"
	//   }
	// Found by name (LaserMuzzleService in the class name), asked once per weapon
	// class and cached, so neither mod links against the other.
	private bool, double, double, double MuzzleFor(int h, Weapon w)
	{
		String k = w.GetClassName();
		if (k == mzKey[h]) return mzGot[h], mzF[h], mzU[h], mzS[h];
		mzKey[h] = k;
		mzGot[h] = false;
		let it = ServiceIterator.Find("LaserMuzzleService");
		Service sv;
		while (sv = it.Next())
		{
			String r = sv.GetString("laser.muzzle", k, h, 0, w);
			if (r == "") continue;
			Array<String> f;
			r.Split(f, " ", TOK_SKIPEMPTY);
			if (f.Size() < 3) continue;
			mzF[h] = f[0].ToDouble(); mzU[h] = f[1].ToDouble(); mzS[h] = f[2].ToDouble();
			mzGot[h] = true;
			break;
		}
		return mzGot[h], mzF[h], mzU[h], mzS[h];
	}

	// THE RANGE READOUT: metres to what the main hand's laser is on (the off
	// hand's when the main has none), on a small screen by the gun or at the
	// spot. The numbers are written to the canvas texture in UiTick.
	private void UpdateReadout(PlayerPawn pmo, PlayerInfo p)
	{
		int mode = RSQLS_Hand.Opt("rsqls_readout", p, 0);
		int h = (rangeM[0] > 0) ? 0 : 1;
		if (mode <= 0 || rangeM[h] <= 0 || pmo.Health <= 0)
		{
			Hide(readout);
			readM = 0;
			return;
		}
		readout = Ensure(readout, "RSQLS_Readout");
		if (!readout) return;
		bool was = !readout.bINVISIBLE;
		Vector3 at;
		double sc = 1.0;
		if (mode == 2 && spot[h] && !spot[h].bINVISIBLE)
		{
			at = spot[h].pos + (0, 0, 4 + rangeM[h] * 0.6);
			sc = clamp(rangeM[h] / 4.0, 1.0, 8.0);
		}
		else
			at = RSQLS_Hand.Grip(pmo, h) + RSQLS_Hand.GunOffset(pmo, h, 0.08, 0.09, 0.0);
		Put(readout, was, at);
		Vector3 eye = (pmo.pos.x, pmo.pos.y, p.viewz);
		Vector3 d = eye - at;
		readout.Angle = VectorAngle(d.x, d.y);
		readout.Pitch = -atan2(d.z * RSQLS_Hand.PIXELSTRETCH, d.xy.Length());
		sc *= RSQLS_Hand.Num("rsqls_readout_size", p, 1.0);
		readout.Scale = (sc, sc);
		readM = rangeM[h];
		readRgb = rangeRgb[h];
	}

	override void UiTick()
	{
		let cv = TexMan.GetCanvas("RSLRANGE");
		if (!cv) return;
		cv.Clear(0, 0, 128, 32, Color(255, 0, 0, 0));
		if (readM <= 0) return;
		let pp = players[consoleplayer];
		int units = RSQLS_Hand.Opt("rsqls_readout_units", pp, 0);
		String txt;
		if (units == 1) txt = String.Format("%.0f ft", readM * 3.28084);
		else if (units == 2) txt = String.Format("%.0f u", readM * RSQLS_Hand.UPM);
		else txt = readM < 10 ? String.Format("%.1f m", readM) : String.Format("%.0f m", readM);
		double tw = SmallFont.StringWidth(txt) * 2.0;
		cv.DrawText(SmallFont, Font.CR_WHITE, (128 - tw) * 0.5, 16 - SmallFont.GetHeight(), txt,
			DTA_ScaleX, 2.0, DTA_ScaleY, 2.0, DTA_Color, Color(255, (readRgb >> 16) & 255, (readRgb >> 8) & 255, readRgb & 255));
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int h = 0; h < 2; h++)
		{
			arcShown[h] = false;
			beamShown[h] = false; spotShown[h] = false; lightOn[h] = false;
			muzzlePrimed[h] = false; hitPrimed[h] = false;
		}
	}
}

// WHAT THE LASER IS DOING, FOR ANY MOD THAT ASKS -- found by name, so a mod that
// asks never links against this one and an absent laser is simply no answer.
//   GetInt("laser.active", "", hand)  -> 1 if a laser (beam or dot) drew on that
//                                        hand (0 main, 1 off) last tic, else 0
//   GetInt("laser.beam", "", hand)    -> the same for the beam alone
// RSQ_DistanceGrab asks this so its grab beam stands down on a hand the laser
// already lights.
class RSQLS_SightService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "laser.active")
			return (RSQLS_Sight.LiveHands() >> (intArg & 1)) & 1;
		if (request == "laser.beam")
			return (RSQLS_Sight.BeamHands() >> (intArg & 1)) & 1;
		return -1;
	}
}
