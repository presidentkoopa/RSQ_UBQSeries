// WHERE A HAND IS AND WHERE IT POINTS, on stock QuestZDoom 17.3.
//
// Everything in this file is a read. Nothing here decides anything, nothing here
// writes to the playsim, and that is deliberate: the geometry is asked the same
// question by the cone, the lock, the carry and the visuals, and if any of them
// derived it a second way they would disagree about where your hand is. That
// disagreement reads in a headset as the aim being randomly off, which is
// unfalsifiable from inside the game and cost the desktop build a night.
//
// STOCK, NOT THE FORK. The desktop original reads `level.HandPos`,
// `pmo.MainHandRoll` and a palm bone through `TransformByNamedBone`. None of
// those exist here. The replacements are not approximations -- QuestZDoom's
// OpenXR layer writes the REAL controller pose into AttackPos/OffhandPos
// (hw_openxrdevice.cpp:593-608, from weaponoffset/offhandoffset), so the stock
// fields are the authoritative hand position rather than a fallback.
class RSQDG_Reach
{
	// ---- the hand's own axes ------------------------------------------------
	//
	// Yaw is stored MINUS 90 DEGREES and pitch is stored NEGATED. Both are
	// engine conventions, not ours, and both are visible in stock's own
	// consumers -- weaponmace.zs:69-79 does exactly this conversion, and the
	// base writer at hw_vrmodes.cpp:443-444 sets `AttackAngle = viewYaw - 90`
	// and `AttackPitch = -viewPitch`, which fixes the convention beyond doubt:
	// viewPitch is Doom's (positive DOWN), so AttackPitch is positive UP. Undo
	// the yaw offset; take the pitch as it is for vectors, negate it only for
	// engine calls that want Doom's sense (DoomPitch). (Negating it for vectors
	// too was the 2026-10-26 upside-down bug -- see Pitch.)
	//
	// Getting either wrong puts the tested volume and the drawn ray on opposite
	// sides of the hand, so the conversion lives HERE, once, and nothing else
	// in the package touches the raw fields.
	static double Yaw(PlayerPawn pmo, int hand)
	{
		return ((Ctrl(pmo, hand) == 0) ? pmo.AttackAngle : pmo.OffhandAngle) + 90;
	}

	// THE CONTROLLER PLAYING A HAND'S PART. RSQ_Accessibility's Off-Hand Modifier (One-Handed):
	// while it is held the off hand's part -- its reach, its lock, its catch -- is played by the
	// main controller, and the main hand's own part stands down (HandBusy), so one controller is
	// never two hands at once. Without it (or off) a hand is its own controller.
	static clearscope int Ctrl(PlayerPawn pmo, int hand) { return RSQDG_A11y.Ctrl(pmo, hand); }

	// PITCH, POSITIVE UP -- the convention every vector in this file (Fwd, Up,
	// Side) and every test above it (the palm gate's "not at the floor", the
	// flick's "tipped up") was written for. AttackPitch IS that already: the
	// engine stores it negated FROM DOOM'S down-positive view pitch. This used
	// to negate it a second time, which turned the hand upside down in pitch:
	// measured in the rig 2026-10-26, a hand aimed 9 deg DOWN at a floor barrel
	// found nothing and one aimed 9 deg UP took it, while the pistol's own
	// puffs and the drawn beam (a LineTrace, which takes Doom's down-positive
	// pitch) went the right way. The headset-proven QuestSaber reads it the same
	// way as here now (its fw.z = sin(AttackPitch)).
	static double Pitch(PlayerPawn pmo, int hand)
	{
		return (Ctrl(pmo, hand) == 0) ? pmo.AttackPitch : pmo.OffhandPitch;
	}

	// Doom's own convention (positive DOWN), for engine calls that take it:
	// LineTrace, AimLineAttack, LineAttack.
	static double DoomPitch(PlayerPawn pmo, int hand) { return -Pitch(pmo, hand); }

	// AttackRoll, not MainHandRoll. The fork renamed it; stock's name is the
	// original and is what actor.zs:270 declares.
	static double Roll(PlayerPawn pmo, int hand)
	{
		return ((Ctrl(pmo, hand) == 0) ? pmo.AttackRoll : pmo.OffhandRoll);
	}

	// Wrapped to -180..180, so a wrist a degree past the wrap is a degree away
	// and not 359.
	static double NormDeg(double d)
	{
		while (d > 180) d -= 360;
		while (d < -180) d += 360;
		return d;
	}

	// ---- THE PALM GATE ------------------------------------------------------
	//
	// WHERE THE HAND IS, not what it is doing. A button alone says "grab", but
	// it cannot say "I meant to reach" -- so without this the hand pulls things
	// across the room while held in a gun grip, and the only warning is that it
	// happened.
	//
	// TURN YOUR PALM OUT AND THE REACH ARMS. That is the whole gesture, and
	// pairing it with the button is what makes a stray press harmless rather
	// than merely unlikely: a press needs the pose, and the pose on its own
	// does nothing.
	//
	// AND THE POSE GATES, IT DOES NOT TRIGGER. A pose is LOCAL -- the VR fields
	// are written for the camera player only -- so a pose-only trigger cannot
	// be replicated, which is exactly the rule the owner's own DXR gesture table
	// encodes as "gate 0 = pose-only = NOT multiplayer-safe". The netevent
	// travels; the pose decides whether it meant anything.
	//
	// ROLL IS COMPARED AS A DISTANCE FROM A TARGET, USING THE ABSOLUTE ROLL, so
	// one number covers both wrists: a right hand turning palm-out rolls one way
	// and a left hand the other.
	//
	// ROLL ALONE IS NOT SAFE, and this is the part that is easy to miss. An idle
	// hand rests within any useful tolerance of the roll target, so roll by
	// itself arms the reach whenever you are not thinking about it. PITCH is
	// what has no overlap: a hand hanging at your side sits around forty degrees
	// below level, and a hand reaching at something does not.
	static play bool PalmOk(PlayerPawn pmo, PlayerInfo p, int hand)
	{
		if (HandBusy(p, hand)) return false;
		if (!Flag("rsqdg_palm", p, true)) return true;

		// RSQ_Accessibility's Gesture Ease: the roll tolerance x1..x2 (30 -> 60 degrees) and the
		// pitch floor lowered by as much again (-30 -> -60); 0 / absent: exactly as tuned.
		double rl  = abs(NormDeg(Roll(pmo, hand)));
		double tgt = Num("rsqdg_palm_roll", p, 90.0);
		double tol = RSQDG_A11y.Wide(Num("rsqdg_palm_tol",  p, 30.0));
		if (abs(rl - tgt) > tol) return false;

		// Not pointing at the floor. -180 or below disables the half.
		double minPitch = Num("rsqdg_palm_pitch", p, -30.0);
		if (minPitch > -180) minPitch -= RSQDG_A11y.Ease() * 30.0;
		if (minPitch > -180 && Pitch(pmo, hand) < minPitch) return false;

		return true;
	}

	// A HAND THAT IS ALREADY SOMEONE ELSE'S GESTURE STANDS DOWN.
	//
	// A saber or a shield is swung, and a swing is full of wrist roll and
	// pitch -- palm out, tip up -- which is exactly this mechanic's gesture. In
	// the rig, with RSQ_Saber in the right hand, the grab locked and
	// pulled a barrel off an ordinary roll-and-flick. So a hand stands down while
	// it holds:
	//   - a MELEE weapon (the saber, a chainsaw, a fist): swung, never pointed;
	//   - a hand the tactical rig is using (RSQ_TacticalRig answers "rig.busy");
	//   - another mod's hand system, found BY NAME AT RUN TIME so nothing links
	//     against it and an absent mod is just a string that never matches --
	//     RS_ShieldSawQ (SSQ_) and RSQ_Saber's Force hand (UBQS_),
	//     which has its own pull, push and grip on the same off hand.
	// The empty-hand fillers (RSQ_Hands and the like) are not busy: an empty hand
	// is exactly the hand that should reach. rsqdg_yield 0 turns this off.
	static play bool HandBusy(PlayerInfo p, int hand)
	{
		// THE OFF-HAND MODIFIER (One-Handed): held, the main controller is playing the off hand's
		// part -- so the main hand's own part stands down, and the off hand's part asks nothing
		// about what either hand holds: holding the modifier IS the intent to reach.
		if (p && p.mo && RSQDG_A11y.Swapped(p.mo)) return hand == 0;
		if (!p || !Flag("rsqdg_yield", p, true)) return false;
		// RSQ_TacticalRig: a hand reaching into a holster or its radial, or holding a
		// door, the cigarette or the Zippo, is the rig's. Asked by service name, so an
		// absent rig gives no answer.
		// TWO-HANDING. A hand close to the other one while the main hand holds a gun is
		// steadying it, and canting a steadied rifle to the side ("SWAT style") rolls
		// both palms out -- the grab's own gesture (the owner's headset test, 10-27). So
		// both hands stand down inside rsqdg_steady_m of each other (the engine's own
		// two-hand steadying reaches 0.5 m).
		if (p.mo && p.ReadyWeapon && !p.ReadyWeapon.bMELEEWEAPON)
		{
			double steady = Num("rsqdg_steady_m", p, 0.45);
			if (steady > 0 && Metres(p.mo.AttackPos - p.mo.OffhandPos) < steady) return true;
		}
		let rit = ServiceIterator.Find("RSQTR_RigService");
		Service rs;
		while (rs = rit.Next())
			if (rs.GetInt("rig.busy", "", hand, 0, p.mo) == 1) return true;
		Weapon w = (hand == 0) ? p.ReadyWeapon : p.OffhandWeapon;
		if (!w) return false;
		// GetClassName can come back lower-cased (seen in the rig), so compare lower-cased.
		String n = w.GetClassName();
		n = n.MakeLower();
		// BY EVIDENCE, NOT BY NAME ALONE (G1). RSQ_Saber answers "saber.lit"
		// through its UBQS_SaberService: 0 means a hilt with the blade switched off, which
		// is not being swung, so that hand may reach. Asked by service name, so an absent
		// or older saber gives no answer and the hand stays busy as before. (The psprite
		// frame was the first idea and does not work: with the world saber on, the
		// default, the layer is blanked to frame 18 whatever the blade does -- rig, 10-26.)
		if (n.IndexOf("ubqs_saber") == 0)
		{
			let it = ServiceIterator.Find("UBQS_SaberService");
			Service sv;
			while (sv = it.Next())
				if (sv.GetInt("saber.lit", "", hand, 0, p.mo) == 0) return false;
			return true;
		}
		// THE BARE HAND IS AN EMPTY HAND, not a melee weapon to swing (the owner, 10-27: "I don't see
		// distance grabbing working at all"): Brutal Doom's fists (Melee_Attacks, +MELEEWEAPON) are
		// what the main hand holds once its gun is holstered, and the vanilla Fist the same. They reach.
		if (n == "fist" || (w.bMELEEWEAPON && w.bCHEATNOTWEAPON)) return false;
		if (w.bMELEEWEAPON) return true;
		return n.IndexOf("ssq_") == 0 || n.IndexOf("ubqs_") == 0;
	}

	// ---- the basis ----------------------------------------------------------
	//
	// Three orthogonal axes from the three Euler angles, in the order the
	// renderer applies them. Hand-rolled rather than taken from a native
	// because there is no native that returns a hand's basis: AttackDir()
	// exists but, from ZScript, RETURNS (yawDegrees, pitchDegrees, 0) and not a
	// vector at all (p_actionfunctions.cpp:5694-5712 -- it converts the C++
	// function's unit vector back into angles before returning it). Treating
	// its result as a direction is a silent, plausible-looking bug, and stock
	// uses it correctly as a pair of angles at attacks.zs:489-490.
	//
	// It also cannot be called from `ui` scope -- Actor methods are play -- so a
	// visual layer needs this anyway.
	static Vector3 Fwd(double yaw, double pit, double rol)
	{
		return (cos(pit) * cos(yaw), cos(pit) * sin(yaw), sin(pit));
	}

	static Vector3 Side(double yaw, double pit, double rol)
	{
		// The un-rolled sideways axis, then rolled about forward. Roll is the
		// only wrist channel the engine gives us (actor.zs:274) and it is the
		// difference between a palm-up and a palm-down grab, so it is not
		// optional even though nothing else here consumes it yet.
		Vector3 s = (sin(yaw), -cos(yaw), 0);
		Vector3 u = (-sin(pit) * cos(yaw), -sin(pit) * sin(yaw), cos(pit));
		return s * cos(rol) + u * sin(rol);
	}

	static Vector3 Up(double yaw, double pit, double rol)
	{
		Vector3 s = (sin(yaw), -cos(yaw), 0);
		Vector3 u = (-sin(pit) * cos(yaw), -sin(pit) * sin(yaw), cos(pit));
		return u * cos(rol) - s * sin(rol);
	}

	// The hand's forward axis, ready to dot against.
	static Vector3 Dir(PlayerPawn pmo, int hand)
	{
		return Fwd(Yaw(pmo, hand), Pitch(pmo, hand), Roll(pmo, hand));
	}

	// ---- where the hand is -------------------------------------------------
	//
	// THE REAL CONTROLLER, and on stock that is simply AttackPos/OffhandPos.
	//
	// Worth being explicit about why, because the desktop comment next to this
	// says the opposite and would mislead anyone porting it back. On the FORK,
	// AttackPos is canonical playsim state rebuilt from the replicated usercmd,
	// so in a netgame it is the pawn's SHOOTING POINT -- the middle of the body
	// -- and reaching from there would have every co-op player grabbing things
	// out of their own chest. That is why the fork added `level.HandPos`.
	//
	// On stock QuestZDoom the renderer writes the controller pose straight into
	// these fields for the camera player (hw_openxrdevice.cpp:587-609), so they
	// ARE the hand. The fork's problem does not exist here, and neither does its
	// fix: `level.HandPos` is zero hits on this engine.
	//
	// THE CONSEQUENCE IS A NETPLAY ONE AND IT IS NOT OPTIONAL. Both writers key
	// on `r_viewpoint.camera` (hw_vrmodes.cpp:434, hw_openxrdevice.cpp:551) and
	// touch only that player's pawn, so for every OTHER player on this machine
	// these fields hold class defaults. There is no path by which a peer's hand
	// pose reaches us. So this is a LOCAL read for a LOCAL decision; what it
	// decides travels afterwards as a command carrying a network ID, never as a
	// position.
	static Vector3 Palm(PlayerPawn pmo, int hand)
	{
		return (Ctrl(pmo, hand) == 0) ? pmo.AttackPos : pmo.OffhandPos;
	}

	// ---- units -------------------------------------------------------------
	//
	// 34 MAP UNITS PER METRE HORIZONTALLY, 28.333 VERTICALLY, and the asymmetry
	// is real rather than a bug to work around.
	//
	// `vr_vunits_per_meter` is 34 (hw_vrmodes.cpp:94) and XY uses it bare, but Z
	// is divided by `pixelstretch`, default 1.2 (g_mapinfo.cpp:314), because the
	// renderer stretches the vertical axis by that factor when it builds the
	// projection. Doom's map space is itself vertically compressed relative to
	// the room you are standing in.
	//
	// Two things follow, and the desktop build gets both wrong by using a flat
	// 34 on every axis:
	//
	//   - A speed or distance threshold taken from a raw vector length is
	//     DIRECTION-DEPENDENT BY 20%. A hand moved a metre upward measures
	//     differently from a metre forward.
	//   - A physically spherical volume is an ELLIPSOID in map units.
	//
	// Sanity check against stock numbers: the player is 56 units tall and 32
	// wide, giving 56 * 1.2 / 34 = 1.98 m and 32 / 34 = 0.94 m. Both correct.
	const UNITS_PER_METRE_XY = 34.0;
	const PIXELSTRETCH       = 1.2;

	// The true physical length of a map-space vector, in metres.
	static double Metres(Vector3 v)
	{
		double z = v.z * PIXELSTRETCH;
		return sqrt(v.x * v.x + v.y * v.y + z * z) / UNITS_PER_METRE_XY;
	}

	static double MetresToUnits(double m)
	{
		return m * UNITS_PER_METRE_XY;
	}

	// ---- cvar reads --------------------------------------------------------
	//
	// Through CVar.GetCVar(name, player) rather than FindCVar, so a `user` cvar
	// resolves against THAT player. FindCVar reads whatever this client has set,
	// which is a desync the moment it is used in play scope.
	static double Num(String n, PlayerInfo p, double d)
	{
		let c = CVar.GetCVar(n, p);
		double v = c ? c.GetFloat() : d;
		// the five settings Gun Bonsai's VR patch can grow (RSQDG_Perks); 1 without it
		if (n.Left(6) == "rsqdg_" && (n == "rsqdg_reach" || n == "rsqdg_pull_kg" || n == "rsqdg_burden_kg"
			|| n == "rsqdg_arm_kg" || n == "rsqdg_catch_radius"))
			v *= RSQDG_Perks.Factor(n, p);
		return v;
	}

	static bool Flag(String n, PlayerInfo p, bool d)
	{
		let c = CVar.GetCVar(n, p);
		return c ? c.GetBool() : d;
	}

	static int Opt(String n, PlayerInfo p, int d)
	{
		let c = CVar.GetCVar(n, p);
		return c ? c.GetInt() : d;
	}
}


// GUN BONSAI'S VR PATCH, ASKED BY NAME (RSQ_MeleeUpgradeService "plevel": a PLAYER upgrade's level).
// A throw is no gun's, so the grab's perks are the player's own, and each grows one of the grab's
// own settings for that player only. Without the patch every level is 0 and every factor 1: the
// grab is exactly what it was. Levels are asked once a second per player and kept on RSQDG_Throw.
//   Long Arm     rsqdg_reach         +15% a level
//   Iron Grip    rsqdg_pull_kg       +50% a level (heavier things come easier), rsqdg_burden_kg +25%
//   Heavy Hitter rsqdg_arm_kg        +25% a level (a heavy thing leaves the hand faster)
//   Air Catch    rsqdg_catch_radius  +25% a level
class RSQDG_Perks
{
	// read anywhere (the grab's cvar reads are data scope); RSQDG_Throw.WorldTick refreshes the levels
	static double Factor(String n, PlayerInfo p)
	{
		if (!p || !p.mo) return 1.0;
		let th = RSQDG_Throw(EventHandler.Find("RSQDG_Throw"));
		if (!th) return 1.0;
		int pn = p.mo.PlayerNumber();
		if (pn < 0 || pn >= MAXPLAYERS) return 1.0;
		if (n == "rsqdg_reach") return 1.0 + 0.15 * th.pkReach[pn];
		if (n == "rsqdg_pull_kg") return 1.0 + 0.50 * th.pkGrip[pn];
		if (n == "rsqdg_burden_kg") return 1.0 + 0.25 * th.pkGrip[pn];
		if (n == "rsqdg_arm_kg") return 1.0 + 0.25 * th.pkHeave[pn];
		if (n == "rsqdg_catch_radius") return 1.0 + 0.25 * th.pkCatch[pn];
		return 1.0;
	}
}
