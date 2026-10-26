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
// MODES   0 off   1 dot   2 beam + dot   3 IR: only visible through the light
//         amplification goggles (PowerLightAmp), like a real IR laser and NVGs.
//
// Visuals only. Nothing here changes damage, aim, or the playsim of any other
// mod -- it cannot break a weapon, only draw on top of it.

class RSQLS_Beam : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+INTERPOLATEANGLES +BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSLB A -1 Bright; Stop; }
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

	private Actor beam[2];
	private Actor spot[2];
	private bool  beamShown[2], spotShown[2];

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

	// ---- the colours ----------------------------------------------------------
	//
	// One white texture set, tinted by translation; the light gets the same hue.
	static const Name TINT[] = { 'RSQLS_Red', 'RSQLS_Green', 'RSQLS_Blue', 'RSQLS_Cyan',
	                              'RSQLS_Magenta', 'RSQLS_Yellow', 'RSQLS_White' };
	static const int LIGHT[] = { 0xFF2010, 0x20FF30, 0x3050FF, 0x20E0FF,
	                             0xFF20E0, 0xFFE020, 0xFFFFFF };

	private static int ClampColor(int c) { return (c >= 0 && c < 7) ? c : 0; }

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

	private void HideBeam(int h) { if (beam[h]) beam[h].bINVISIBLE = true; beamShown[h] = false; }
	private void HideSpot(int h)
	{
		if (spot[h])
		{
			spot[h].bINVISIBLE = true;
			if (lightOn[h]) { spot[h].A_RemoveLight('RSQLS'); lightOn[h] = false; }
		}
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
		if ((w.bMELEEWEAPON || w.bCHEATNOTWEAPON) && RSQLS_Hand.Flag("rsqls_hide_melee", p, true)) return false;
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

	override void WorldTick()
	{
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

		int mode = RSQLS_Hand.Opt("rsqls_mode", p, 2);
		bool ir = (mode == 3);
		// IR: invisible to the naked eye. The light amplification goggles
		// (Doom's PowerLightAmp, from the Infrared pickup) show it.
		bool irVisible = ir && pmo.FindInventory("PowerLightAmp", true) != null;

		if (pmo.Health <= 0 || mode <= 0 || (ir && !irVisible))
		{
			HideHand(0); HideHand(1);
			return;
		}

		bool wantBeam = (mode >= 2);
		for (int h = 0; h < 2; h++)
		{
			if (!HandLive(p, h)) { HideHand(h); continue; }
			beam[h] = Ensure(beam[h], "RSQLS_Beam");
			spot[h] = Ensure(spot[h], "RSQLS_Spot");
			if (!beam[h] || !spot[h]) continue;
			DrawHand(h, pmo, p, wantBeam);
		}
	}

	private void DrawHand(int h, PlayerPawn pmo, PlayerInfo p, bool wantBeam)
	{
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

		// ---- colour and the room --------------------------------------------
		int col = ClampColor(RSQLS_Hand.Opt(h == 0 ? "rsqls_color_main" : "rsqls_color_off", p, 0));
		Actor onWho = (hit && t.HitType == FLineTraceData.TRACE_HitActor) ? t.HitActor : null;
		bool hostile = onWho && onWho.bISMONSTER && onWho.Health > 0 && !onWho.bFRIENDLY;
		int tcol = RSQLS_Hand.Opt("rsqls_target_color", p, 7);
		if (hostile && tcol >= 0 && tcol < 7) col = tcol;
		TranslationID tint = Translation.GetID(TINT[col]);

		// The room's light at the muzzle, 0..1. Dark rooms show the beam.
		Sector sec = Level.PointInSector(muzzle.xy);
		double lit = sec ? clamp(sec.lightlevel / 255.0, 0.0, 1.0) : 0.5;

		double yaw, pit, len;
		[yaw, pit, len] = RSQLS_Hand.RoomAim(drawEnd - drawMuzzle);

		// ---- the beam ----------------------------------------------------------
		if (wantBeam && len > 2)
		{
			let b = beam[h];
			Put(b, beamShown[h], drawMuzzle);
			beamShown[h] = true;
			b.Angle = yaw;
			b.Pitch = pit + 90;     // lay the model's up axis along the aim
			b.Roll  = 0;
			b.Scale = (RSQLS_Hand.Num("rsqls_beam_w", p, 1.0), len / BEAM_L);
			double litFade = RSQLS_Hand.Num("rsqls_beam_daylight", p, 0.35);
			double a = RSQLS_Hand.Num("rsqls_beam_a", p, 0.75) * (1.0 - (1.0 - litFade) * lit);
			b.Alpha = hostile ? min(1.0, a * 1.35) : a;
			b.Translation = tint;
		}
		else HideBeam(h);

		// ---- the spot: painted on what it hit ----------------------------------
		if (!hit || sky) { HideSpot(h); return; }

		let s = spot[h];
		Vector3 at = drawEnd;
		s.bWALLSPRITE = false;
		s.bFLATSPRITE = false;
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
			s.bWALLSPRITE = true;
			s.Angle = VectorAngle(n.x, n.y);
			at += (n.x, n.y, 0) * 0.4;           // a hair off the wall, never inside it
		}
		else if (t.HitType == FLineTraceData.TRACE_HitFloor)
		{
			s.bFLATSPRITE = true;
			at.z += 0.3;
		}
		else if (t.HitType == FLineTraceData.TRACE_HitCeiling)
		{
			s.bFLATSPRITE = true;
			at.z -= 0.3;
		}
		else
		{
			// An actor: a billboard, pulled toward you so it sits on its front.
			if (len > 1) at += (drawMuzzle - drawEnd) * (2.0 / len);
		}
		Put(s, spotShown[h], at);
		spotShown[h] = true;

		// CONSTANT APPARENT SIZE, with a floor so it never vanishes up close.
		double dist = (end - muzzle).Length();
		// About half a degree across at any range (a real laser sight reads at
		// roughly that), with a floor so it never shrinks to nothing up close.
		double sc = RSQLS_Hand.Num("rsqls_spot_size", p, 1.0) * (0.03 + dist / 2000.0);
		if (hostile) sc *= 1.25 + 0.12 * sin(level.maptime * 22.5);   // it bites
		s.Scale = (sc, sc);
		s.Alpha = 1.0;
		s.Translation = tint;

		// ---- the light ----------------------------------------------------------
		if (RSQLS_Hand.Flag("rsqls_light", p, true))
		{
			int rad = int(clamp(10.0 + dist / 90.0, 10.0, 40.0));
			if (!lightOn[h] || lightColor[h] != LIGHT[col] || abs(lightRadius[h] - rad) > 2)
			{
				s.A_AttachLight('RSQLS', DynamicLight.PointLight, LIGHT[col], rad, rad,
					DynamicLight.LF_ATTENUATE);
				lightOn[h] = true; lightColor[h] = LIGHT[col]; lightRadius[h] = rad;
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
