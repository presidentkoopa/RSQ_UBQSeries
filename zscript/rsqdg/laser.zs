// THE LASER, THE DOT AND THE CONE.
//
// WHAT THIS REPLACED, AND WHY. The first version drew the beam as a chain of up
// to 48 pooled sprite beads per hand. In the headset it strobed: 48 separate
// billboards each re-placed 35 times a second while the hand is rendered at
// headset rate, motes wrapping from one end of the line to the other, a pulsing
// flare. The owner's verdict, 2026-10-26: "no way this will work". Gone.
//
// WHAT IT IS NOW: three single actors per hand, each one object the renderer
// interpolates smoothly between tics.
//
//   THE BEAM  a model: three crossed planes round the bore, each a soft bell
//             across its width, core plus halo, additive. From any angle but
//             straight down the barrel it reads as a solid shaft of light.
//             LENGTH IS EXACT AND FREE: the mesh is authored along +Z, an
//             actor's Scale.Y scales only that axis (Scale.X scales both
//             horizontal ones), so Scale.Y = distance and Scale.X = width, and
//             the actor is pitched 90 degrees past the aim so its up axis lies
//             along the beam. One object, any length, depth-correct.
//   THE DOT   the bundled laser-sight's idea (QuestZDoom assets/mods/laser-
//             sight; GPL, so the idea and not the code): one glow sprite where
//             the line lands, scaled with distance so it keeps one apparent size.
//   THE CONE  DXR's grab-reach cone (hw_weapon.cpp DrawDebugWireCone +
//             DrawDebugSolidCone): wire edges, two rings and a faint shell,
//             baked by tools/gen_cone.py into one MD3 frame per degree. It is
//             the volume cone.zs actually tests, so what you see is exactly
//             what you can take.
//
// All three follow the palm and colour by state through the same translations
// the object's own flash uses: blue searching, amber considering, green locked.
//
// THE ONE LIMIT, stated: an actor moves at 35 Hz and is interpolated between
// tics, so these trail the controller by about a tic. DXR drew in C++ every
// frame and did not. If that reads in the headset, the fallback is a weapon
// psprite layer, which tracks every frame but draws over walls.

class RSQDG_Beam : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+INTERPOLATEANGLES
		+BRIGHT
		RenderStyle "Add";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		RSQB A -1 Bright;
		Stop;
	}
}

class RSQDG_ConeViz : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+INTERPOLATEANGLES
		+BRIGHT
		RenderStyle "Add";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		RSQC A -1 Bright;
		Stop;
	// Never entered: names the second sprite so the frames past 26 degrees
	// exist. The handler writes sprite and frame directly.
	Wide:
		RSQE A -1 Bright;
		Stop;
	}
}

class RSQDG_Dot : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+FORCEXYBILLBOARD
		+BRIGHT
		RenderStyle "Add";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		RSQT A -1 Bright;
		Stop;
	}
}

class RSQDG_Laser : EventHandler
{
	// Authored lengths of the two meshes (tools/gen_cone.py, L and BEAM_L).
	const CONE_L = 256.0;
	const BEAM_L = 256.0;
	const CONE_MIN_DEG = 1;
	const CONE_MAX_DEG = 48;

	private Actor beam[2];
	private Actor pip[2];
	private Actor cone[2];
	private bool  shown[6];   // beam0 beam1 dot0 dot1 cone0 cone1: visible last tic

	private SpriteID sprCone, sprConeWide;

	static RSQDG_Laser Get()
	{
		return RSQDG_Laser(EventHandler.Find("RSQDG_Laser"));
	}

	override void OnRegister()
	{
		sprCone     = Actor.GetSpriteIndex('RSQC');
		sprConeWide = Actor.GetSpriteIndex('RSQE');
	}

	// ---- THE CATCH FLASH ---------------------------------------------------
	//
	// The dot, blooming AT THE PALM for nine tics the moment something lands:
	// the visual half of the catch tick and the catch thump. Stamped with THIS
	// tic -- the catch resolves earlier in the same tic (Flight and Feel tick
	// before Laser), so age 0 is drawn the tic it happens.
	const BURST_TICS = 9;
	private int  burstAt[2];
	private bool burstOn[2];

	void Burst(int hand)
	{
		if (hand == 0 || hand == 1) { burstAt[hand] = level.maptime; burstOn[hand] = true; }
	}

	// ---- placing ------------------------------------------------------------

	// A piece that was hidden comes back by TELEPORTING to where it should be,
	// not by interpolating there from wherever it was left -- otherwise it
	// streaks in from across the room.
	private void Put(Actor a, int slot, Vector3 pos)
	{
		if (!shown[slot])
		{
			a.SetOrigin(pos, false);
			a.ClearInterpolation();
		}
		else a.SetOrigin(pos, true);
		a.bINVISIBLE = false;
		shown[slot] = true;
	}

	private void Hide(Actor a, int slot)
	{
		if (a) a.bINVISIBLE = true;
		shown[slot] = false;
	}

	private void HideHand(int h)
	{
		Hide(beam[h], h);
		Hide(pip[h], 2 + h);
		Hide(cone[h], 4 + h);
	}

	private void HideAll()
	{
		HideHand(0);
		HideHand(1);
	}

	private Actor Ensure(Actor a, Class<Actor> cls)
	{
		if (a) return a;
		a = Actor.Spawn(cls, (0, 0, 0));
		if (a) a.bINVISIBLE = true;
		return a;
	}

	// Room-space yaw and pitch (Doom convention: pitch positive is DOWN) of a
	// map-space vector. ROOM space, because every model here is drawn with
	// CORRECTPIXELSTRETCH: authored in room proportions, compressed vertically
	// by the renderer after rotation. So it is aimed by the room direction and
	// sized by the room length, and lands exactly on the map-space endpoint.
	private static double, double, double RoomAim(Vector3 d)
	{
		Vector3 r = (d.x, d.y, d.z * RSQDG_Reach.PIXELSTRETCH);
		double len = r.Length();
		double yaw = VectorAngle(r.x, r.y);
		double pit = -atan2(r.z, r.xy.Length());
		return yaw, pit, len;
	}

	private TranslationID Tint(int state)
	{
		if (state == 2) return Translation.GetID("RSQDG_Locked");
		if (state == 1) return Translation.GetID("RSQDG_Considered");
		return Translation.GetID("RSQDG_Idle");
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) { HideAll(); return; }
		let pmo = p.mo;

		if (pmo.Health <= 0 || !RSQDG_Reach.Flag("rsqdg_on", p, true)) { HideAll(); return; }

		// A BAD POSE DRAWS NOTHING, rather than a beam out of the chest. The
		// hand fields collapse to the body when a menu is open.
		let aim  = RSQDG_Aim.Get();
		if (!aim || !aim.PoseGood()) { HideAll(); return; }

		let grab = RSQDG_Grab.Get();
		let fl   = RSQDG_Flight.Get();
		let hold = RSQDG_Hold.Get();

		bool wantBeam = RSQDG_Reach.Flag("rsqdg_beam", p, true);
		bool wantDot  = RSQDG_Reach.Flag("rsqdg_dot",  p, true);
		bool wantCone = RSQDG_Reach.Flag("rsqdg_cone", p, true);

		for (int h = 0; h < 2; h++)
		{
			beam[h] = Ensure(beam[h], "RSQDG_Beam");
			pip[h]  = Ensure(pip[h],  "RSQDG_Dot");
			cone[h] = Ensure(cone[h], "RSQDG_ConeViz");
			if (!beam[h] || !pip[h] || !cone[h]) continue;
			DrawHand(h, pmo, p, aim, grab, fl, hold, wantBeam, wantDot, wantCone);
		}
	}

	private void DrawHand(int h, PlayerPawn pmo, PlayerInfo p, RSQDG_Aim aim,
		RSQDG_Grab grab, RSQDG_Flight fl, RSQDG_Hold hold,
		bool wantBeam, bool wantDot, bool wantCone)
	{
		Vector3 palm = RSQDG_Reach.Palm(pmo, h);

		// ---- the catch flash outranks everything for its nine tics ----
		if (burstOn[h])
		{
			int age = level.maptime - burstAt[h];
			if (age >= 0 && age < BURST_TICS && RSQDG_Reach.Flag("rsqdg_catch_flash", p, true))
			{
				Hide(beam[h], h);
				Hide(cone[h], 4 + h);
				double t = double(age) / BURST_TICS;
				let d = pip[h];
				Put(d, 2 + h, palm);
				double s = 0.10 + 0.35 * t;
				d.Scale = (s, s);
				d.Alpha = 0.9 * (1.0 - t) * (1.0 - t);
				d.Translation = Tint(2);
				return;
			}
			burstOn[h] = false;
		}

		// NOTHING WHILE SOMETHING IS IN THE AIR OR IN THE HAND. The object
		// crossing the room at you is the feedback by then.
		if ((fl && fl.Flying(h)) || (hold && hold.HandIsFull(h))) { HideHand(h); return; }

		Actor locked = grab ? grab.Locked(h) : null;
		Actor aimed  = locked ? locked : aim.TargetFor(h);
		int state = locked ? 2 : (aimed ? 1 : 0);

		// THE PALM GATE, read the same way the cone reads it, so what you see
		// and what will happen cannot disagree. A lock survives looking away,
		// so it draws regardless.
		bool armed = locked || RSQDG_Reach.PalmOk(pmo, p, h);
		if (!armed) { HideHand(h); return; }

		// ---- where the line ends ----
		Vector3 to;
		bool onThing = (aimed != null);
		if (onThing)
		{
			to = (aimed.Pos.x, aimed.Pos.y, aimed.Pos.z + aimed.Height * 0.5);
		}
		else
		{
			if (!RSQDG_Reach.Flag("rsqdg_laser_idle", p, true))
			{
				Hide(beam[h], h); Hide(pip[h], 2 + h);
				DrawCone(h, pmo, p, palm, wantCone, state);
				return;
			}
			// CLIPPED AT THE FIRST SURFACE. TRF_ABSPOSITION with the coordinates
			// computed here and ZERO offsets -- P_LineTrace accumulates offsets
			// onto an uninitialised vector exactly when OverrideAttackPosDir is
			// true, which in VR is always.
			double reach = RSQDG_Reach.Num("rsqdg_reach", p, 512.0);
			FLineTraceData t;
			bool hit = pmo.LineTrace(RSQDG_Reach.Yaw(pmo, h), reach, RSQDG_Reach.Pitch(pmo, h),
				TRF_ABSPOSITION | TRF_THRUACTORS, palm.z, palm.x, palm.y, t);
			to = hit ? t.HitLocation : (palm + RSQDG_Reach.Dir(pmo, h) * reach);
		}

		double yaw, pit, len;
		[yaw, pit, len] = RoomAim(to - palm);
		TranslationID tint = Tint(state);

		// Dimmer when it has found nothing, so "considering something" is a
		// change the eye catches rather than a colour you have to read.
		double dim = onThing ? 1.0 : 0.5;

		// ---- the beam ----
		if (wantBeam && len > 2)
		{
			let b = beam[h];
			Put(b, h, palm);
			b.Angle = yaw;
			// +90: the beam lies along the model's UP axis, so the actor is
			// pitched a quarter turn past the aim to lay that axis along it.
			b.Pitch = pit + 90;
			b.Roll  = 0;
			double w = RSQDG_Reach.Num("rsqdg_beam_w", p, 1.0);
			b.Scale = (w, len / BEAM_L);
			b.Alpha = RSQDG_Reach.Num("rsqdg_beam_a", p, 0.8) * dim;
			b.Translation = tint;
		}
		else Hide(beam[h], h);

		// ---- the dot ----
		if (wantDot)
		{
			let d = pip[h];
			// Held a hair short of the surface so it is never half inside it.
			Vector3 back = (len > 1) ? (palm - to) * (1.5 / len) : (0, 0, 0);
			Put(d, 2 + h, to + back);
			// SCALED WITH DISTANCE, so it keeps one apparent size: the
			// laser-sight's rule. And it breathes, on the object flash's
			// period, when it is on something.
			double s = RSQDG_Reach.Num("rsqdg_dot_size", p, 1.0) * (0.04 + len / 2400.0);
			if (onThing)
			{
				double period = max(2.0, RSQDG_Reach.Num("rsqdg_flash", p, 24.0));
				s *= 1.0 + 0.18 * sin(360.0 * (level.time / period));
			}
			d.Scale = (s, s);
			d.Alpha = 0.95 * dim + 0.05;
			d.Translation = tint;
		}
		else Hide(pip[h], 2 + h);

		DrawCone(h, pmo, p, palm, wantCone, state);
	}

	// ---- the cone: the volume cone.zs actually tests ----
	private void DrawCone(int h, PlayerPawn pmo, PlayerInfo p, Vector3 palm, bool wantCone, int state)
	{
		if (!wantCone) { Hide(cone[h], 4 + h); return; }

		double reach  = RSQDG_Reach.Num("rsqdg_reach",  p, 512.0);
		double spread = RSQDG_Reach.Num("rsqdg_spread", p, 12.0);
		if (reach <= 0 || spread <= 0) { Hide(cone[h], 4 + h); return; }

		let c = cone[h];
		Put(c, 4 + h, palm);

		// Aimed by the hand's ROOM direction -- the same direction cone.zs
		// tests along (it scales Dir's Z by pixelstretch before comparing).
		double yaw, pit, len;
		[yaw, pit, len] = RoomAim(RSQDG_Reach.Dir(pmo, h));
		c.Angle = yaw;
		c.Pitch = pit;
		c.Roll  = 0;

		// THE FRAME IS THE SPREAD, THE SCALE IS THE REACH. One MD3 frame per
		// degree of half-angle (width and length cannot scale independently on
		// a mesh along +X), uniform scale for length.
		int deg = clamp(int(spread + 0.5), CONE_MIN_DEG, CONE_MAX_DEG);
		int i = deg - CONE_MIN_DEG;
		c.sprite = (i < 26) ? sprCone : sprConeWide;
		c.frame  = i % 26;
		double s = reach / CONE_L;
		c.Scale = (s, s);

		// FAINT. It is long, it surrounds your view, and it is reference, not
		// the thing you look at. Brighter once it has something in it.
		double a = RSQDG_Reach.Num("rsqdg_cone_a", p, 0.45);
		c.Alpha = (state == 0) ? a * 0.6 : a;
		c.Translation = Tint(state);
	}

	// A level change destroys the actors; the pointers clear themselves, and
	// the visible flags must too so the next spawn teleports into place.
	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < 6; i++) shown[i] = false;
		burstOn[0] = false; burstOn[1] = false;
	}
}
