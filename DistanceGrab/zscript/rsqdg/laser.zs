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

	// ---- LEADING THE HAND ----------------------------------------------------
	//
	// WHY THESE LAG AND THE GUN DOES NOT. The renderer draws at headset rate and
	// places the weapon from the controller pose it read THAT frame. Script runs
	// at 35 Hz: these actors are placed once per tic from where the hand was then,
	// and the renderer draws a blend of the last two tics -- by construction, where
	// the hand WAS, between 0 and 1 tic ago. Up to 28 ms behind a fast hand.
	//
	// THE FIX: place them where the hand WILL BE one tic from now. The renderer
	// draws Prev + (Pos - Prev) * f; with Pos = hand + v and Prev = last tic's
	// hand + v, that is hand + v * f -- exactly where a steadily moving hand is
	// at fraction f of the way to the next tic. The interpolation lag and the lead
	// cancel. The cost: a brief overshoot of about one tic's travel when a fast
	// swing stops dead. rsqdg_lead scales it; 0 is off.
	//
	// Velocity is plain world-space differencing of the palm. Not the throw's
	// tracking-frame velocity: walking and turning DO move the hand on screen,
	// and the drawing has to follow them. A jump (a menu collapse, a teleport)
	// leads nothing.
	private Vector3 leadPalm[2], leadDir[2];
	private Vector3 lastPalm[2], lastDir[2], lastTo[2];
	private bool    leadPrimed[2], toPrimed[2];
	private double  leadTics;
	const LEAD_JUMP = 17.0;   // map units in one tic (~0.5 m) that is not a hand moving

	private void UpdateLead(int h, PlayerPawn pmo, PlayerInfo p)
	{
		Vector3 palm = RSQDG_Reach.Palm(pmo, h);
		Vector3 dir  = RSQDG_Reach.Dir(pmo, h);
		Vector3 v = (0, 0, 0), dv = (0, 0, 0);
		if (leadPrimed[h])
		{
			v  = palm - lastPalm[h];
			dv = dir - lastDir[h];
			if (v.Length() > LEAD_JUMP) { v = (0, 0, 0); dv = (0, 0, 0); }
		}
		leadPalm[h] = palm + v * leadTics;
		Vector3 d = dir + dv * leadTics;
		double dl = d.Length();
		leadDir[h] = (dl > 1e-6) ? d / dl : dir;
		lastPalm[h] = palm;
		lastDir[h]  = dir;
		leadPrimed[h] = true;
	}

	// The idle beam's far end slides along whatever it hits as the hand sweeps;
	// it is led the same way, or the beam would bend toward last tic's wall spot.
	private Vector3 LeadTo(int h, Vector3 to)
	{
		Vector3 r = to;
		if (toPrimed[h])
		{
			Vector3 v = to - lastTo[h];
			if (v.Length() <= LEAD_JUMP * 8) r = to + v * leadTics;   // far end moves faster
		}
		lastTo[h] = to;
		toPrimed[h] = true;
		return r;
	}

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

	static TranslationID Tint(int state)
	{
		if (state == 2) return Translation.GetID("RSQDG_Locked" .. RSQDG_CB.Suffix());
		if (state == 1) return Translation.GetID("RSQDG_Considered" .. RSQDG_CB.Suffix());
		return Translation.GetID("RSQDG_Idle" .. RSQDG_CB.Suffix());
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

		leadTics = clamp(RSQDG_Reach.Num("rsqdg_lead", p, 1.0), 0.0, 2.0);
		UpdateLead(0, pmo, p);
		UpdateLead(1, pmo, p);

		bool wantBeam = RSQDG_Reach.Flag("rsqdg_beam", p, true);
		bool wantDot  = RSQDG_Reach.Flag("rsqdg_dot",  p, true);
		bool wantCone = RSQDG_Reach.Flag("rsqdg_cone", p, true);

		for (int h = 0; h < 2; h++)
		{
			beam[h] = Ensure(beam[h], "RSQDG_Beam");
			pip[h]  = Ensure(pip[h],  "RSQDG_Dot");
			cone[h] = Ensure(cone[h], "RSQDG_ConeViz");
			if (!beam[h] || !pip[h] || !cone[h]) continue;
			// TWO BEAMS FROM ONE HAND IS ONE TOO MANY (G6). When RSQ_LaserSight is
			// already drawing on this hand, the grab's beam stands down; the dot and
			// the cone stay, since they say what the GRAB would take. rsqdg_beam_yield 0
			// keeps both.
			bool wb = wantBeam && !(RSQDG_Reach.Flag("rsqdg_beam_yield", p, true) && LaserOn(h));
			DrawHand(h, pmo, p, aim, grab, fl, hold, wb, wantDot, wantCone);
		}
	}

	// Asked of RSQ_LaserSight by service name, so this links against nothing and
	// an absent laser just answers nothing (no service -> false).
	private static bool LaserOn(int h)
	{
		let it = ServiceIterator.Find("RSQLS_SightService");
		Service sv;
		while (sv = it.Next())
			if (sv.GetInt("laser.beam", "", h) == 1) return true;   // a beam, not a dot: the dot does not double ours
		return false;
	}

	private void DrawHand(int h, PlayerPawn pmo, PlayerInfo p, RSQDG_Aim aim,
		RSQDG_Grab grab, RSQDG_Flight fl, RSQDG_Hold hold,
		bool wantBeam, bool wantDot, bool wantCone)
	{
		// WHERE TO DRAW the hand end: led a tic ahead (see UpdateLead). The REAL
		// palm is still what the trace starts from, so what the beam finds is
		// what the hand is actually pointing at.
		Vector3 palm = leadPalm[h];
		Vector3 realPalm = RSQDG_Reach.Palm(pmo, h);

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
				toPrimed[h] = false;
				Hide(beam[h], h); Hide(pip[h], 2 + h);
				DrawCone(h, pmo, p, palm, wantCone, state);
				return;
			}
			// CLIPPED AT THE FIRST SURFACE. TRF_ABSPOSITION with the coordinates
			// computed here and ZERO offsets -- P_LineTrace accumulates offsets
			// onto an uninitialised vector exactly when OverrideAttackPosDir is
			// true, which in VR is always.
			// ALONG THE HAND AS THE CONE TESTS IT. Dir is a ROOM direction (the
			// controller's real pitch), and map space is the room squashed 1.2x
			// vertically -- so in map units the hand points along (x, y, z / 1.2).
			// Traced at the raw pitch, the line ran steeper than the hand and the
			// cone around it (measured: 25.7 deg up drawn at 30.0).
			double reach = RSQDG_Reach.Num("rsqdg_reach", p, 512.0);
			Vector3 rd = RSQDG_Reach.Dir(pmo, h);
			Vector3 md = (rd.x, rd.y, rd.z / RSQDG_Reach.PIXELSTRETCH);
			double mpit = -atan2(md.z, md.xy.Length());
			FLineTraceData t;
			bool hit = pmo.LineTrace(RSQDG_Reach.Yaw(pmo, h), reach * md.Length(), mpit,
				TRF_ABSPOSITION | TRF_THRUACTORS, realPalm.z, realPalm.x, realPalm.y, t);
			to = hit ? t.HitLocation : (realPalm + md * reach);
			to = LeadTo(h, to);
		}
		if (onThing) toPrimed[h] = false;   // a thing's middle does not slide

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
			// EVERY STATE IS ITS OWN LINE (rs_grabviz.zs DrawAimBeams): WorldHands
			// gives idle, considering and locked each a thickness and an opacity --
			// 0.4 / 0.7 / 0.9 thick, 0.35 / 1.0 / 1.0 opaque -- because they are three
			// different messages and telling them apart at a glance is why the line
			// is drawn at all. Locked is the full rsqdg_beam_w; the others in
			// WorldHands' proportion to it.
			double w = RSQDG_Reach.Num("rsqdg_beam_w", p, 1.0) * ((state == 2) ? 1.0 : ((state == 1) ? 0.7 / 0.9 : 0.4 / 0.9));
			b.Scale = (w, len / BEAM_L);
			b.Alpha = RSQDG_Reach.Num("rsqdg_beam_a", p, 0.8) * ((state == 0) ? 0.35 : 1.0);
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
		// leadDir is a ROOM direction already; RoomAim takes a MAP vector, so it
		// is handed the map form (z / 1.2) and gives the room pitch back. Feeding
		// it the room vector raw stretched the pitch twice: the drawn cone sat
		// 1.9 deg off the tested one at 9.5 deg down and 4.3 deg off at 25.7 up
		// (measured, rig, 10-27).
		Vector3 ld = leadDir[h];
		double yaw, pit, len;
		[yaw, pit, len] = RoomAim((ld.x, ld.y, ld.z / RSQDG_Reach.PIXELSTRETCH));
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
		leadPrimed[0] = false; leadPrimed[1] = false;
		toPrimed[0] = false; toPrimed[1] = false;
		for (int i = 0; i < 6; i++) shown[i] = false;
		burstOn[0] = false; burstOn[1] = false;
	}
}
