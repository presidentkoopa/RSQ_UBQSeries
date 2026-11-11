// THE BODY THE RIG HANGS ON.
//
// Hands are exact on stock QuestZDoom 17.3: the OpenXR layer writes the real
// controller poses into AttackPos / OffhandPos (and their angles) for the camera
// player. Ermac's Virtual Tactical Vest predates that and had to find the hand by
// firing an invisible missile every tic; none of that is needed here.
//
// THE BODY IS NOT THE HEAD. pmo.angle follows the headset, so a rig placed off it
// swings round every time you look sideways (the original vest did, and so did this
// rig's first version, which let the body drift back under the head: the owner's
// headset test, 10-27, "the holster slots turn with the head").
//
// So the body is anchored to the TRACKING SPACE's yaw, the frame the controllers live
// in: a snap or smooth turn rotates the whole tracking space, which shows as BOTH
// controllers' yaws moving with the pawn's angle (a tic or two apart: RSQTR_TurnKeeper
// below, 11-03); a head turn moves the angle alone. Looking around leaves the rig where
// it is; turns carry it, every one, exactly.
//
// STICK TURNS + RECENTER (the owner's choice, 11-03 18:56, after "I am constantly finding myself with the torso 90
// degrees turned when it should be facing forward, this makes the holsters useless"): the body turns ONLY with the
// tracking space (snap and smooth turns) and NEVER guesses a turn from the head or hands. Turning your actual body in
// the room cannot be seen (there is no body tracker); reaching both hands to the side while looking there looked
// exactly like it and swung the torso 90 degrees. So a real turn in the room leaves the torso where it was until you
// RECENTER it (RSQTR_Rig.RecenterTick, rig.zs): both hands held to your chest (rsqtr_recenter_hands, on), the bound
// key "Recenter Torso" (rsqtr_recenter), and on its own at map start, respawn, level change and a loaded save.
// TORSO FOLLOWS ROOM TURNS (rsqtr_body_room, on; the owner's pick, 11-03 19:31, after "if i physically stand and turn,
// it stays in place"): the one exception, a smart catch-up (RoomFollow below): the head held 45+ degrees off the torso
// for 1.5 s with the hands anywhere (11-05 00:57: "Hands anywhere but a holster"), never a hand in a holster or reaching
// far out to the side, never looking down.
// The two old guesses stay as options, both OFF: "Torso Turns With Head and Hands" (rsqtr_body_hands: head and both
// hands turning together) and "Torso Catches Up With Head" (rsqtr_body_catch: a head turned past rsqtr_body_turn
// degrees, 35, held rsqtr_body_secs, 1 s, eases the body round); neither acts while you look down (past
// rsqtr_body_down, 25 degrees).
//
// THE RIG HANGS FROM THE NECK, NOT THE FACE (rsqtr_neck, on; the owner, 11-03: "looking down and turning my head
// seems to turn the torso some"). QuestZDoom moves the pawn with the headset, and a nod swings the headset forward
// and down round the neck, so a rig hung from the headset slid forward every time you looked down at it. Across the
// floor it now hangs from a neck NECK_BACK behind and NECK_DOWN under the eyes in the head's own frame (the pawn's
// pitch is the headset's; the engine exposes no headset roll to ZScript, only HmdPosition, so a sideways head tilt
// is not taken out). At level pitch the neck sits straight under-behind the eyes, so the anchor is exactly the old
// one and every saved holster stays where it was set standing upright; only a nod is taken out. Height is unchanged
// (the pawn's view height, or the seated eyes): player.viewz does not follow a nod at all with the engine's default
// vr_crouch_use_button, and the seated eyes take the highest the headset has been lately.
//
// ROOM vs MAP: 34 map units per metre horizontally, 28.33 vertically (Doom's
// pixels are 1.2 tall). Every offset here is given in metres and converted per
// axis, the convention the rest of the series uses.
class RSQTR_Body play
{
	// THE SCALE, READ LIVE (Quest teardown 00 1.2a): map units per room metre is the player's vr_vunits_per_meter
	// (34 by default) and the vertical stretch the level's own pixelstretch (1.2). Fixed numbers put every holster
	// out of reach the moment either is changed.
	static clearscope double Upm()
	{
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double v = c ? c.GetFloat() : 34.0;
		return v > 0 ? v : 34.0;
	}
	static clearscope double Ps()
	{
		double v = level ? level.pixelstretch : 1.2;
		return v > 0 ? v : 1.2;
	}
	const SWING = 3.0;         // most degrees per tic the body turns while it catches up (an ease, not a snap)
	const STEEP = 78.0;        // degrees of head pitch past which the head's yaw is not trusted (straight up or down)
	const NECK_BACK = 0.10;    // metres: the neck pivot behind the eyes, in the head's frame (a first estimate)
	const NECK_DOWN = 0.10;    // metres: and under them

	double yaw;                // the body's heading, degrees
	int    offFor;             // tics the head has been held far round
	bool   swinging;
	bool   primed;
	RSQTR_TurnKeeper turns;    // snap / smooth turns and the head and hands turning together (below)
	int    doneAt;             // the tic Update last ran (+1): once a tic, whoever asks first (RSQTR_BodyService)

	void Update(PlayerPawn pmo)
	{
		if (doneAt == level.maptime + 1) return;
		doneAt = level.maptime + 1;
		UpdateSeat(pmo);
		double a = pmo.angle, h0 = pmo.AttackAngle, h1 = pmo.OffhandAngle;
		if (!turns) turns = new("RSQTR_TurnKeeper");
		if (!primed) { yaw = a; turns.Prime(a, h0, h1); primed = true; return; }
		// The tracking space turned (snap, smooth, or a teleport's new facing): the body turns with it, exactly
		// (RSQTR_TurnKeeper, 11-03). Never paused: a snap while looking down at a holster still carries the holsters round.
		let sn = CVar.FindCVar("vr_snapTurn");
		yaw += turns.Step(a, h0, h1, pmo.AttackPitch, pmo.OffhandPitch, level.maptime, sn ? sn.GetFloat() : 45.0);
		let p = pmo.player;
		double down = RSQTR_Rig.Num("rsqtr_body_down", p, 25.0);
		bool still = pmo.pitch > down || abs(pmo.pitch) > STEEP || RSQTR_Rig.Flag("rsqtr_edit", p, false);
		// The head and both hands turned the same way in the room (rsqtr_body_hands, OFF since 11-03 18:56: it is a
		// guess, and reaching to the side for holsters while looking there made it): the body follows them.
		yaw += turns.With(yaw, a, h0, h1, pmo.AttackPitch, pmo.OffhandPitch, !still && RSQTR_Rig.Flag("rsqtr_body_hands", p, false));
		// A real turn in the room, the hands anywhere but a holster or a reach (rsqtr_body_room, on; 11-03 19:31, 11-05 00:57): RoomFollow.
		yaw += RoomFollow(pmo, a, still);

		// A head held far round for long enough (rsqtr_body_catch, OFF since 11-03 18:56): the body has turned in the room.
		if (!RSQTR_Rig.Flag("rsqtr_body_catch", p, false)) { offFor = 0; swinging = false; return; }
		double limit = RSQTR_Rig.Num("rsqtr_body_turn", p, 35.0);
		int need = int(RSQTR_Rig.Num("rsqtr_body_secs", p, 1.0) * TICRATE);
		double off = Actor.DeltaAngle(yaw, a);
		// LOOKING DOWN AT YOURSELF IS NOT TURNING (the owner, 11-03: "looking down and turning my head seems to turn the
		// torso some"). A look down at a hip holster is 45-60 degrees of pitch, often with the head turned to that side,
		// and until 11-03 only past 78 degrees was it ignored, so a look down at a side holster held a second swung the
		// rig. Now any pitch more than rsqtr_body_down (25) below level pauses the catch-up: it neither counts toward a
		// swing nor continues one. Steeply up the head's yaw is not trusted either; in edit mode the body holds still
		// while regions are placed on it. Stick and snap turns (above) still carry the body.
		if (still)
		{
			offFor = 0;
			swinging = false;
			return;
		}
		// STICK TURNS, PLUS A SLOW CATCH-UP (the owner's pick, 10-27, after "everything moves
		// around"): a head turned past rsqtr_body_turn degrees (35) and HELD there
		// rsqtr_body_secs (1 s) is taken as the body turning, and the holsters ease round to it,
		// at most 3 degrees a tic. Glancing about never moves them.
		if (abs(off) > limit) offFor++;
		else if (!swinging) offFor = 0;
		if (offFor > need) swinging = true;
		if (swinging)
		{
			yaw += clamp(off * 0.08, -SWING, SWING);
			if (abs(off) < 4) { swinging = false; offFor = 0; }
		}
	}

	// TORSO FOLLOWS ROOM TURNS (rsqtr_body_room, on; the owner, 11-03 19:31: "the torso follows snap turn, great, but if i
	// physically stand and turn, it stays in place"; his pick: smart catch-up). There is no body tracker, so a real turn
	// in the room is read from what it looks like: the head held more than ROOM_OFF degrees off the torso for ROOM_TICS.
	// THE HANDS MAY BE ANYWHERE (the owner, 11-05 00:57, PCVR: "when I turn my actual body in real life the rig does not
	// adjust"; his pick: "Hands anywhere but a holster"). Until 11-05 both hands had to be held in front at gun-ready
	// height, so a turn with the hands lowered, hanging or at the hips never counted. Now the count stops only for:
	//  - a hand inside any holster or rig place (RSQTR_Rig.HandBusy: within its sphere; a grip or draw there is in it),
	//  - a hand REACHING (RoomHand): more than ROOM_REACH from the neck along the floor AND more than ROOM_REACH_ANG off
	//    the TORSO's facing, unless it is held like a gun (within ROOM_ANG of the look, ROOM_LOW to ROOM_HIGH from the
	//    eyes: a long gun's fore-end, a one-hand aim). The owner's old bad case, both hands reached 75-95 deg to one side
	//    while looking there, has its main hand 0.58 m out and 0.55 m under the eyes: reaching, no turn.
	//  - looking down (rsqtr_body_down), or a snap still on its way.
	// Then the torso eases round to the head (ROOM_EASE of what is left a tic, at most ROOM_MAX degrees: 16 tics for 90)
	// and lands on it exactly. A glance aside lasts under ROOM_TICS and never turns it. Snaps and smooth turns are the
	// keeper's and stay exact; this only ever turns the torso toward the head.
	// THE HAND ON PCVR (commit 264493242): OpenVR hangs the hands off the frame's interpolated eye in X/Y, so read against
	// the pawn a still hand moved by up to a tic of walking each frame and could read as reaching while you walk; the
	// hand here is RSQTR_HandSync.Fix's (the frame's offset carried to the body this tic) along the floor, the raw height.
	// Measured on the rig (turnprobe, gen_room_script.py, evidence/roomfollow_anywhere.txt).
	const ROOM_OFF = 45.0;     // degrees: the head this far off the torso...
	const ROOM_TICS = 52;      // ...for this many tics (1.5 s), no hand in a holster or reaching the whole time
	const ROOM_REACH = 0.50;   // metres from the neck along the floor: a hand further out than this...
	const ROOM_REACH_ANG = 45.0;   // ...and more than this many degrees off the torso's facing is reaching...
	const ROOM_ANG = 40.0;     // ...unless it is held like a gun: within this many degrees of the look...
	const ROOM_LOW = -0.40;    // ...no lower than this from the eyes (the owner's reach: -0.55; a hand in the chest holsters -0.61)...
	const ROOM_HIGH = 0.10;    // ...and no higher than this
	const ROOM_EASE = 0.3;     // of what is left, each tic, while it turns
	const ROOM_MAX = 12.0;     // most degrees a tic
	const ROOM_LAND = 1.0;     // degrees: this close, it lands on the head
	int roomFor;               // tics the head has been held off with no hand busy or reaching
	bool roomOn;               // easing round
	int roomTurns;             // how many times it turned (the turn probe reads it)
	double roomDist[2], roomAng[2], roomUp[2];   // each hand, this tic: from the neck (m), off the look (deg), from the eyes (m)
	bool roomIn[2];            // each hand, this tic: free (not reaching)

	double RoomFollow(PlayerPawn pmo, double a, bool still)
	{
		let p = pmo.player;
		if (!RSQTR_Rig.Flag("rsqtr_body_room", p, true) || p != players[consoleplayer]) { roomFor = 0; roomOn = false; return 0; }
		double off = Actor.DeltaAngle(yaw, a);
		roomIn[0] = RoomHand(pmo, 0, off);
		roomIn[1] = RoomHand(pmo, 1, off);
		let rig = RSQTR_Rig.Get();
		bool holster = rig && (rig.HandBusy(0) || rig.HandBusy(1));
		// looking down or a snap still on its way: no turn, and none under way
		if (still || turns.jPend != 0) { roomFor = 0; roomOn = false; return 0; }
		// AN EASE ALREADY UNDER WAY FINISHES (11-05): hands hanging at your sides sit inside the hip holsters' spheres
		// (a hand 0.25 m out at 0.82 m is 0.10 m from the hip holster's middle, radius 0.14), so as the torso came round
		// under them the holster caught the hand and stopped the turn about 30 degrees short. A hand in a holster stops
		// the count, never a turn already decided (16 tics for 90).
		if (holster && !roomOn) { roomFor = 0; return 0; }
		if (roomOn)
		{
			if (abs(off) <= ROOM_LAND) { roomOn = false; roomFor = 0; roomTurns++; return off; }
			return clamp(off * ROOM_EASE, -ROOM_MAX, ROOM_MAX);
		}
		roomFor = (abs(off) > ROOM_OFF && roomIn[0] && roomIn[1]) ? roomFor + 1 : 0;
		if (roomFor < ROOM_TICS) return 0;
		roomOn = true;
		return clamp(off * ROOM_EASE, -ROOM_MAX, ROOM_MAX);
	}

	// one hand in the head's frame (HeadLocal: forward, left, up from the eyes, metres), measured from the neck
	// (NECK_BACK behind the eyes) along the floor; off = the head's angle off the torso. True = not reaching.
	bool RoomHand(PlayerPawn pmo, int h, double off)
	{
		Vector3 raw = h == 0 ? pmo.AttackPos : pmo.OffhandPos;
		Vector3 f = RSQTR_HandSync.Fix(pmo, raw, h);
		Vector3 l = HeadLocal(pmo, (f.x, f.y, raw.z));
		double fx = l.x + NECK_BACK;
		roomDist[h] = (fx, l.y).Length();
		roomAng[h] = roomDist[h] > 0.001 ? atan2(l.y, fx) : 0;
		roomUp[h] = l.z;
		if (roomDist[h] <= ROOM_REACH) return true;
		if (abs(Actor.DeltaAngle(0, roomAng[h] + off)) <= ROOM_REACH_ANG) return true;
		return abs(roomAng[h]) <= ROOM_ANG && l.z >= ROOM_LOW && l.z <= ROOM_HIGH;
	}

	// RECENTER (11-03 18:56): the body faces where the head faces, yaw only, from this tic on. The keeper starts again
	// from here, so nothing it was still waiting on (a snap's controllers, a turn being settled) moves it afterwards.
	int recentered;            // how many times (the turn probe reads it)
	void Recenter(PlayerPawn pmo)
	{
		yaw = pmo.angle;
		if (!turns) turns = new("RSQTR_TurnKeeper");
		turns.Prime(pmo.angle, pmo.AttackAngle, pmo.OffhandAngle);
		offFor = 0; swinging = false; primed = true;
		roomFor = 0; roomOn = false;
		recentered++;
	}

	// THE RECENTER POSE (rsqtr_recenter_hands): where a hand is against the chest point, in ROOM METRES, in the HEAD's
	// frame (forward, left, up), from your live eyes (the headset's own height: the hands are placed from it) with the
	// nod taken out (NeckShift). The head's frame, not the body's: the gesture is for a torso turned away from you, and a
	// chest point on that torso would be off to your side.
	static Vector3 HeadLocal(PlayerPawn pmo, Vector3 at)
	{
		Vector3 e = (pmo.pos.x, pmo.pos.y, pmo.HmdPosition.y > 0.3 ? RoomFloor(pmo) + EyeUnits(pmo, pmo.HmdPosition.y) : (pmo.player ? pmo.player.viewz : pmo.pos.z + 41));
		e += NeckShift(pmo);
		Vector3 d = at - e;
		double c = cos(pmo.angle), s = sin(pmo.angle), u = Upm();
		return ((d.x * c + d.y * s) / u, (-d.x * s + d.y * c) / u, d.z * Ps() / u);
	}

	// The head in the world: the pawn's place (QuestZDoom moves the pawn with the
	// headset) at eye height. Standing, that is the view height (player.viewz); seated
	// (rsqtr_seated), your seated eyes (SeatedHead).
	static Vector3 Head(PlayerPawn pmo)
	{
		if (pmo.player && pmo.player == players[consoleplayer])
		{
			let rig = RSQTR_Rig.Get();
			let b = rig ? rig.GetBody() : null;
			if (b && b.seatOn) return b.SeatedHead(pmo);
		}
		return (pmo.pos.x, pmo.pos.y, pmo.player ? pmo.player.viewz : pmo.pos.z + pmo.height * 0.9);
	}

	// SEATED (rsqtr_seated, the owner, 10-27). HOW THE ENGINE PLACES THINGS IN HEIGHT
	// (QuestZDoom 17.3, hw_openxrdevice.cpp, measured on the rig with the headset at 1.6 m and
	// 1.2 m):
	//   your eyes     floor + (headset height + vr_height_adjust) * 34 / 1.2   (what you see from)
	//   your hands    floor + (controller height + vr_height_adjust) * 34 / 1.2 (AttackPos.z)
	//   player.viewz  the PAWN's eye: floor + its ViewHeight (41) while vr_crouch_use_button is on
	//                 (the default), so it does not move when your head does; with it off, the
	//                 engine sets crouchfactor = eyes / 41 and viewz follows your eyes.
	// "floor" is viewz less the pawn's view height (button on) or less your eyes (button off),
	// which keeps the view bob and a button crouch in it, as the hands have them.
	// Standing, the rig hangs from player.viewz; it always has. Sitting down drops your eyes and
	// hands about 0.4 m while viewz stays put, so the holsters stayed at standing height. Seated,
	// the rig hangs from your SEATED EYES instead: the highest your headset has been lately (you
	// sit up to look around, you lean to reach), easing down SEAT_EASE metres a tic so it settles
	// if you slump, rising at once if you sit up or stand, and taken straight down to the headset
	// once it has stayed SEAT_DROP below for a second (you stood up and sat down again).
	const SEAT_EASE = 0.02 / 35.0;   // metres a tic: 2 cm a second (a first guess: a one-second lean to the hip moves the holsters 2 cm)
	const SEAT_DROP = 0.20;          // metres (a first guess: deeper and longer than a reach to the hip)
	bool seatOn;
	double seatEye;                  // metres: your seated eyes above the room floor
	int seatLow;                     // tics the headset has been SEAT_DROP below them

	void UpdateSeat(PlayerPawn pmo)
	{
		let c = CVar.FindCVar("rsqtr_seated");
		double h = pmo.HmdPosition.y;
		// RSQ_Accessibility's SEATED PLAY (rsqa_seated: Standing / Seated / Auto, asked through RSQA_Service by name,
		// RSQTR_A11y.Seated): when it says you are seated the rig hangs from your seated eyes too, as with this mod's
		// own Seated row. Without RSQ_Accessibility it answers no, and only rsqtr_seated decides, as before.
		seatOn = ((c && c.GetBool()) || RSQTR_A11y.Seated(pmo)) && h > 0.3;     // no headset height read: the standing rule
		if (!seatOn) { seatEye = 0; seatLow = 0; return; }
		seatLow = h < seatEye - SEAT_DROP ? seatLow + 1 : 0;
		if (seatEye <= 0 || h > seatEye || seatLow > TICRATE) { seatEye = h; seatLow = 0; }
		else seatEye = max(h, seatEye - SEAT_EASE);
	}

	// THE ENGINE'S FIXED EYE HEIGHT (owner 2026-11-11, design/rigtest_2026-11-10/RESULTS_DOWNSHOT.md). With
	// vr_crouch_use_button on, QuestZDoom 17.3 places the eyes and the hands at viewz + the headset's height - a height it
	// caches ONCE (hw_openxrdevice.cpp:158-170, getDoomPlayerHeightWithoutCrouch: the pawn's ViewHeight at its first
	// frame). RSQ SlowMo's DOWN scales the pawn's ViewHeight to 40% while you are down, so pmo.ViewHeight is not that number
	// then; the pawn class's default (pmo.Default) is, crouched or not. A crouch still reaches the eyes through viewz. Code only, not shown.
	static clearscope double StandEyeHeight(PlayerPawn pmo) { return pmo ? pmo.Default.ViewHeight : 41.0; }

	// The room floor in map height, as the engine places the hands (above).
	static double RoomFloor(PlayerPawn pmo)
	{
		let p = pmo.player;
		if (!p) return pmo.pos.z;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		if (!cb || cb.GetBool()) return p.viewz - StandEyeHeight(pmo);
		return p.viewz - EyeUnits(pmo, pmo.HmdPosition.y);
	}

	static double EyeUnits(PlayerPawn pmo, double metres)
	{
		let ha = CVar.FindCVar("vr_height_adjust");
		return (metres + (ha ? ha.GetFloat() : 0)) * Upm() / Ps();
	}

	Vector3 SeatedHead(PlayerPawn pmo)
	{
		return (pmo.pos.x, pmo.pos.y, RoomFloor(pmo) + EyeUnits(pmo, seatEye));
	}

	// Where your eyes are this moment (the helmet sits on them): seated, the headset's own
	// height; standing, the head the rig hangs from.
	static Vector3 LiveHead(PlayerPawn pmo)
	{
		if (pmo.player && pmo.player == players[consoleplayer])
		{
			let rig = RSQTR_Rig.Get();
			let b = rig ? rig.GetBody() : null;
			if (b && b.seatOn) return (pmo.pos.x, pmo.pos.y, RoomFloor(pmo) + EyeUnits(pmo, pmo.HmdPosition.y));
		}
		return Head(pmo);
	}

	// A point fwd / left / up METRES from the head, in the body's frame.
	Vector3 At(PlayerPawn pmo, double fwdMetres, double leftMetres, double upMetres)
	{
		double c = cos(yaw), s = sin(yaw);
		double fx = c * fwdMetres - s * leftMetres;
		double fy = s * fwdMetres + c * leftMetres;
		Vector3 h = (seatOn && pmo.player == players[consoleplayer]) ? SeatedHead(pmo) : Head(pmo);
		return h + NeckShift(pmo) + (fx * Upm(), fy * Upm(), upMetres * Upm() / Ps());
	}

	// THE NOD TAKEN OUT (rsqtr_neck, see the top): how far, along the floor, the neck is from where it would be at
	// level pitch, the headset's place being the same. Eyes to neck in the head's frame is NECK_BACK back and NECK_DOWN
	// down; looking down by t, that is -(NECK_BACK cos t + NECK_DOWN sin t) forward along the floor, against
	// -NECK_BACK at level: so the shift is NECK_BACK (1 - cos t) - NECK_DOWN sin t along where the head faces (0 at
	// level, -4 cm at 50 degrees down: the headset has come that far forward round the neck). Map units, no height.
	static Vector3 NeckShift(PlayerPawn pmo)
	{
		if (!pmo.player || !RSQTR_Rig.Flag("rsqtr_neck", pmo.player, true)) return (0, 0, 0);
		double t = clamp(pmo.pitch, -89, 89);
		double f = NECK_BACK * (1 - cos(t)) - NECK_DOWN * sin(t);
		double u = Upm();
		return (cos(pmo.angle) * f * u, sin(pmo.angle) * f * u, 0);
	}

	// Distance in the ROOM between two map points, in metres.
	static double RoomMetres(Vector3 a, Vector3 b)
	{
		Vector3 d = a - b;
		return (d.x, d.y, d.z * Ps()).Length() / Upm();
	}

	// The two hands. 0 = main, 1 = off.
	static Vector3 Hand(PlayerPawn pmo, int h) { return h == 0 ? pmo.AttackPos : pmo.OffhandPos; }

	// Which controller is the main hand: vr_control_scheme 10+ is left-handed.
	// A local cvar, read only for local feedback (rumble), never for the playsim.
	static bool LeftHanded()
	{
		let cv = CVar.FindCVar("vr_control_scheme");
		return cv && cv.GetInt() >= 10;
	}

	// Which way the BODY LAYOUT goes where no hand owns the spot (the cigarette pocket, the way a
	// stored gun hangs): RSQ_Accessibility's rsqa_handed (1 right, 2 left) when it is loaded and set,
	// else the engine's handedness. Everything a particular hand owns -- which controller is main,
	// the saber spots (each saber's own hand), the shield's shoulder, the mirror's reflected hand, the
	// rumble side -- stays on LeftHanded(): that is the engine's and no mod can move it.
	static bool LayoutLeft()
	{
		CVar h = null; { Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN; if (rsqaC) h = CVar.FindCVar("rsqa_handed"); }  // only while RSQ_Accessibility is loaded: a value left in the ini must not act on its own
		int v = h ? h.GetInt() : 0;
		if (v == 1) return false;
		if (v == 2) return true;
		return LeftHanded();
	}
}

// THE TURN KEEPER (the owner's headset, 11-03 10:53: "the rig does not play well with snap turn, i can 360 around my
// torso and the shield doesn't move and the torso doesn't turn, or does sometimes"). How far the body turned this tic
// with the TRACKING SPACE (snap, smooth, a teleport's facing) or, with rsqtr_body_hands, with the head and both hands
// turning together in the room.
//
// WHY THE OLD SAME-TIC TEST MISSED (measured on the qzd17.3 rig, tools/rigtest/turnprobe, 11-03): the engine writes the
// controller yaws in the renderer's SetUp from doomYaw BEFORE that frame's turn is added to it (hw_openxrdevice.cpp
// 590 / 603 before updateHmdPose 739), while the turn reaches pawn.angle through the next ticcmd. So the controllers
// always trail the view by one rendered frame: a snap shows in the pawn's angle on one tic and in the controllers on
// the same tic or the next one (or, with frames dropped, several tics later), and every head step moves the controller
// yaws back by that frame's step and forward again. The old rule asked for all three in the same tic within 1.5
// degrees: over 8 snaps right then 8 left at 90 fps the old body moved -45, -45, -45, 0, -12, -60, -94, -56 and 0, 56,
// 69, 47, 45, 45, 0, 57 (missed snaps, then the head-held catch-up smearing them); RSQ ShieldSaw's copy (controllers
// exactly one tic late) 0, -9, -57, -98, -46, -45, -45, -45 and 34, 0, 0, 0, 0, -9, -15, -20. A smooth 360 left the
// old body 10 degrees off (ShieldSaw's 220-365), a real turn in the room left it 12-25 degrees short, and looking
// down at a hip holster while swinging the head slid it 13-18 degrees.
//
// 11-03 18:56 (the owner: "I am constantly finding myself with the torso 90 degrees turned"): WITH SNAP TURNING (vr_snapTurn
// over 10) ONLY SNAPS TURN THE BODY; the step matching and settling below run only for SMOOTH turning, where the stick
// turns the view a little every frame and nothing else can carry the body. (A smooth turn and a rigid turn of head and
// both hands in the room look the same to ZScript: the engine folds the stick's turn into the headset's yaw before the
// script sees either, VR_GetMove, so with smooth turning a head-and-hands turn that agrees within the tolerances below
// can still be taken as one.) TURNING WITH HEAD AND HANDS is OFF by default.
//
// NOW, three parts:
//   SNAPS (ViewJump): a head step of a snap's size in one tic waits for the controllers' matching step and the body
//   turns by exactly vr_snapTurn.
//   STEPS (Match): the head's yaw steps and the two controllers' COMMON yaw step (the smaller of the two when they turn
//   the same way, else none) each go into a short queue, and the body turns by what the two queues share, in the same
//   direction: a head turn alone shares nothing with still hands; one hand reaching shares nothing (the other hand did
//   not turn). A controller step AGAINST the head's step is the engine's late frame, so it is set aside as owed, never
//   matched, for LATE_TICS, and its return pays it off before it can be read as a turn. The two queues must also agree
//   like a turn of the tracking space does (the head's share within a third of the controllers', and within AGREE
//   degrees). A controller pointed steeply up or down (YAW_PITCH) has no yaw to go by and shares nothing.
//   SETTLING (below): the totals of every turn put right what the steps missed.
//
// TURNING WITH HEAD AND HANDS (rsqtr_body_hands, OFF since 11-03 18:56; the owner's ask, 11-03 13:00: a real 360 in the room must carry the rig):
// hands held in front of you mark where your body faces. When the head AND both controllers (each held within HAND_PITCH
// of level, so a hand hanging down or in a holster never counts) all face more than START_AT degrees to the same side of
// the body for DWELL tics, the body turns to the nearest of the three, up to CHASE degrees a tic, until it is within
// STOP_AT; for AGAIN_TICS after that, a lead of AGAIN_AT starts it again, so a real turn ends with the body on the hands.
// Looking down past the "ignore looking down" angle never starts or continues it; one hand, or the head alone, never.
//
// SETTLING (11-03, second pass; measured on the rig, turnprobe): the queues alone lost a step now and then. A smooth
// 360 at 90 fps ended with the body 5.0 degrees short of the pawn (a controller step expired unmatched), and the room
// 360 back ended 10.0 short (too small for TURNING WITH HEAD AND HANDS to start); each stayed so for good, because
// nothing looked at the totals. So every run of matched steps is now a TURN, and a turn is SETTLED SETTLE_TICS after
// its last matched step by the totals, not the steps: from just before its first step (HIST tics, never before the
// last settled turn), how far the head turned, how far each controller turned, and how far the body turned (all the
// keeper's own turns, TURNING WITH HEAD AND HANDS included). Totals cannot miss a tic: the controllers' late frame
// cancels out over a turn. Then:
//   - snaps were turned exactly when they came (SNAPS, ViewJump below) and are taken out of every total first;
//   - when the three agree (within SETTLE_TOL, or a tenth): the body's turn is made the middle one (a smooth turn, or
//     the head and hands turning together in the room), unless it is already within SETTLE_NEAR;
//   - otherwise, if the body turned further than all three did (or the other way): back to what they share; a body
//     that turned less is left (TURNING WITH HEAD AND HANDS and the head-held catch-up are still at it);
//   - a turn that TURNING WITH HEAD AND HANDS took part in is left to it.
// A turn is settled only once two rendered frames have reached the script since its last step (or SETTLE_MAX tics).
// While the stick turns smoothly, a step's match may also differ from the head's by one rendered frame's turn (up to
// vr_snapTurn degrees: the controllers trail the view by exactly one frame), so the body moves every tic instead of in
// two-tic bursts; whatever that lets through by mistake, the settling takes back.
class RSQTR_TurnKeeper play
{
	const WAIT_TICS = 6;           // tics a step waits for its match in the other queue
	const LATE_TICS = 70;           // tics a late controller step (against the head) waits for its return
	const START_AT = 20.0;        // degrees: head and both hands this far round the same way...
	const DWELL = 8;           // ...for this many tics (0.23 s) start the body turning with them
	const STOP_AT = 1.0;          // degrees: and it stops this close to the nearest of the three
	const AGAIN_AT = 4.0;      // degrees: within AGAIN_TICS of its last turn, this lead starts it again
	const AGAIN_TICS = 35;
	const CHASE = 12.0;        // most degrees a tic it turns while it catches up
	const HAND_PITCH = 50.0;   // degrees: a controller pointed further up or down than this marks no heading
	const AGREE = 6.0;         // degrees: head and controllers' shares this close (and within a third) = the tracking space
	const OWE_MAX = 20.0;      // degrees: the most a late controller is taken to owe (Owe): a frame's head step, at a slow frame
	const SNAPTOL = 0.15;      // of a snap: a head jump this close to vr_snapTurn is one snap; a controller step this close matches it
	const JUMP_DEG = 20.0;         // degrees in one tic: no head turns this fast; a jump of the view (a snap: 0.6 of vr_snapTurn)
	const JUMP_FRAMES = 2;     // rendered frames a snap's head jump waits for the controllers' (they come with the next)
	const MAX_WAIT = 35;       // tics: and no wait for a snap is longer than this (no frame drawn: a level load, a hitch)
	const SETTLE_MAX = 16;     // tics: a turn is settled this long after its last step even with no new frame seen
	const YAW_PITCH = 65.0;    // degrees: a controller pointed further up or down than this has no yaw to match
	const HIST = 20;           // tics before its first matched step a turn's totals start (covers WAIT_TICS and a slow frame)
	const SETTLE_TICS = 8;     // tics after its last matched step a turn is settled
	const SETTLE_TOL = 3.0;    // degrees: head and both controllers' totals this close together (or within a tenth) agree
	const SETTLE_NEAR = 1.0;   // degrees: a body's turn this close to what they agree on is left be

	double lastA, lastH0, lastH1;
	Array<double> hAmt, cAmt;  // pending steps, head and controllers; each queue is all one sign
	Array<int> hEnd, cEnd;     // the tic each pending step expires
	int withFor;               // tics head and hands have been round the same way (TURNING WITH HEAD AND HANDS)
	bool withOn;
	int withLast;              // the last tic it turned the body
	Array<double> lAmt, mAmt;  // what each late controller still owes (main, off): its steps against the head, waiting to come back
	Array<int> lEnd, mEnd;
	// SETTLING: the last HIST tics (head, each controller, the body's turn, the tic), and the open turn's totals
	Array<double> rA, r0, r1, rB, rJ, rW;
	Array<int> rT;
	bool tOn;
	int tLast, tSettled;
	double tA, t0, t1, tB, tJ, tW;
	double jPend;              // SNAPS: the head's jump waiting for the controllers (ViewJump)
	int jEnd, jFrames;
	bool jGot0, jGot1;
	int frames, tFrames;       // rendered frames seen (Step), and at the open turn's last matched step
	double lastSettle;         // the last settling's correction (the probe reads it)

	void Prime(double a, double h0, double h1)
	{
		lastA = a; lastH0 = h0; lastH1 = h1;
		hAmt.Clear(); hEnd.Clear(); cAmt.Clear(); cEnd.Clear(); lAmt.Clear(); lEnd.Clear(); mAmt.Clear(); mEnd.Clear();
		rA.Clear(); r0.Clear(); r1.Clear(); rB.Clear(); rJ.Clear(); rW.Clear(); rT.Clear();
		withFor = 0; withOn = false; tOn = false; tSettled = 0; lastSettle = 0; jPend = 0; frames = tFrames = 0;
	}

	// this tic's turn of the body, degrees; snap = vr_snapTurn (a snap when over 10, a smooth turn's most per frame
	// when 10 or less)
	double Step(double a, double h0, double h1, double p0, double p1, int now, double snap)
	{
		double dA = Actor.DeltaAngle(lastA, a);
		double d0 = Actor.DeltaAngle(lastH0, h0), d1 = Actor.DeltaAngle(lastH1, h1);
		lastA = a; lastH0 = h0; lastH1 = h1;
		// this tic's record (the body's share is filled in by Note), and the open turn's totals
		rA.Push(dA); r0.Push(d0); r1.Push(d1); rB.Push(0); rJ.Push(0); rW.Push(0); rT.Push(now);
		while (rT.Size() > HIST) { rA.Delete(0); r0.Delete(0); r1.Delete(0); rB.Delete(0); rJ.Delete(0); rW.Delete(0); rT.Delete(0); }
		if (tOn) { tA += dA; t0 += d0; t1 += d1; }
		// a rendered frame reached the script: the controller yaws are written once a frame (a live hand never holds
		// exactly still). Under load the rig rendered one frame in 9 tics, and every wait counted in tics ran out.
		if (abs(d0) > 0.0001 || abs(d1) > 0.0001) frames++;
		double j = ViewJump(dA, d0, d1, now, snap);
		// SNAP TURNING (vr_snapTurn over 10: the engine has no smooth turn then, hw_openxrdevice / VrInputDefault.cpp 269):
		// the tracking space turns ONLY by snaps, so only a snap turns the body, by exactly vr_snapTurn (ViewJump). No
		// step matching and no settling: those read the head and hands turning together as a turn, and reaching both hands
		// to the side while looking there turned the torso 90 degrees (the owner's headset, 11-03 18:56).
		if (snap > 10)
		{
			hAmt.Clear(); hEnd.Clear(); cAmt.Clear(); cEnd.Clear(); tOn = false;
			Note(j);
			return j;
		}
		// A CONTROLLER POINTED STEEPLY UP OR DOWN HAS NO YAW TO GO BY (measured on the rig: a hand held down at a hip
		// holster read yaws swinging through 180 degrees while it moved a few centimetres). Its steps match nothing; a
		// snap still needs only the other controller (ViewJump).
		if (abs(p0) > YAW_PITCH) d0 = 0;
		if (abs(p1) > YAW_PITCH) d1 = 0;
		double m = Match(dA, d0, d1, now, snap);
		if (j != 0 || m != 0)
		{
			if (!tOn) Open();
			tLast = now;
			tFrames = frames;
		}
		if (j != 0) { rJ[rJ.Size() - 1] += j; tJ += j; }
		Note(j + m);
		m += j;
		if (tOn && now - tLast >= SETTLE_TICS && (frames - tFrames >= 2 || now - tLast >= SETTLE_MAX)) m += Settle(now, snap);
		return m;
	}

	// SNAPS (and any other one-tic jump of the view, a teleport's new facing): a head step of JUMP_DEG or more in one tic is
	// no head (a person's quickest look is a few degrees a tic) and goes in no queue. It waits JUMP_FRAMES frames for
	// the controllers: each one's step that matches it (within SNAPTOL of a snap, or 3 degrees) is taken out of that
	// controller's step, and once both have matched (or one, when the wait runs out: a hand pointed straight down has no
	// yaw to speak of) the body turns by EXACTLY the snap. A head jump the controllers never follow turns nothing.
	// (11-03, second pass: the shared queues let a head swing in the tics before a snap eat it; measured on the rig, the
	// body missed a snap made while looking down at a holster and turned 89 degrees on the next one.)
	double ViewJump(double dA, out double d0, out double d1, int now, double snap)
	{
		double jmin = snap > 10 ? 0.6 * snap : JUMP_DEG;
		if (abs(dA) > jmin)
		{
			jPend = (snap > 10 && abs(abs(dA) - snap) < SNAPTOL * snap + 3) ? (dA > 0 ? snap : -snap) : dA;
			jEnd = now + MAX_WAIT;
			jFrames = frames;
			jGot0 = jGot1 = false;
		}
		if (jPend == 0) return 0;
		// a controller stepping AGAINST the jump first is the engine's late frame after a head that moved (the
		// controllers go back by the head's step, then forward again): no snap. Measured on the rig: the head set 60
		// degrees round and back in one tic each, and that return matched the controllers' coming back.
		if ((d0 * jPend < 0 && abs(d0) > 0.5 * abs(jPend)) || (d1 * jPend < 0 && abs(d1) > 0.5 * abs(jPend))) { jPend = 0; return 0; }
		double tol = max(SNAPTOL * abs(jPend), 3.0);
		if (!jGot0 && abs(d0 - jPend) < tol) { d0 -= jPend; jGot0 = true; }
		if (!jGot1 && abs(d1 - jPend) < tol) { d1 -= jPend; jGot1 = true; }
		// the frame after the snap's carries it to the controllers: two frames on (or MAX_WAIT tics), the wait is over
		bool over = now >= jEnd || frames - jFrames >= JUMP_FRAMES;
		if ((jGot0 && jGot1) || (over && (jGot0 || jGot1)))
		{
			double r = jPend;
			jPend = 0;
			return r;
		}
		if (over) jPend = 0;
		return 0;
	}

	// a turn starts: its totals from the last HIST tics (none from before the last settling)
	void Open()
	{
		tOn = true; tA = t0 = t1 = tB = tJ = tW = 0;
		for (int i = 0; i < rT.Size(); i++)
		{
			if (rT[i] <= tSettled) continue;
			tA += rA[i]; t0 += r0[i]; t1 += r1[i]; tB += rB[i]; tJ += rJ[i]; tW += rW[i];
		}
	}

	// the body turned by t this tic (any of the keeper's turns)
	void Note(double t)
	{
		if (t == 0) return;
		if (rB.Size() > 0) rB[rB.Size() - 1] += t;
		if (tOn) tB += t;
	}

	// SETTLING (above): the correction that makes the body's turn what the totals say
	double Settle(int now, double snap)
	{
		tOn = false;
		tSettled = now;
		// the snaps were turned exactly (ViewJump): only what the three turned besides them is looked at
		double a = tA - tJ, c0 = t0 - tJ, c1 = t1 - tJ, b = tB - tJ;
		// the turn the three agree on: the middle one of head and controllers (one hand or the head moving on its own
		// does not move it), and how far apart they are
		double lo = min(a, min(c0, c1)), hi = max(a, max(c0, c1));
		double mid = a + c0 + c1 - lo - hi;
		bool together = c0 * c1 > 0 && c0 * a > 0;
		double want = b;
		// TURNING WITH HEAD AND HANDS took part: it turns the body to where head and hands face now, not by what they
		// turned in this window, and it carries on until it is there; totals would only undo it (measured on the rig: a
		// real turn's settling pulled the body back 25 degrees, and the chase brought it round again)
		if (abs(tW) > 0.01) want = b;
		else if (together && hi - lo <= max(SETTLE_TOL, 0.1 * abs(mid)))
		{
			// they agree: a smooth turn, or head and hands turning together; a body already this close is left be
			if (abs(b - mid) > SETTLE_NEAR) want = mid;
		}
		else
		{
			// they do not: the steps matched were no turn of the tracking space (a head swinging while the hands
			// moved). A body turned further than all three (or against them) goes back to what they share; measured on
			// the rig, looking down at a hip holster with the head sweeping and the hands moving, this took the body
			// back from 31 degrees.
			double share = together ? (c0 > 0 ? 1 : -1) * min(abs(a), min(abs(c0), abs(c1))) : 0;
			if (b * share < 0 || abs(b) > abs(share) + SETTLE_NEAR) want = share;
		}
		// what was pending is part of this turn: settled with it
		hAmt.Clear(); hEnd.Clear(); cAmt.Clear(); cEnd.Clear();
		double c = want - b;
		lastSettle = c;
		if (abs(c) < 0.01) return 0;
		Note(c);
		return c;
	}

	// the step matcher: what the head's and the controllers' queues share this tic
	double Match(double dA, double d0, double d1, int now, double snap)
	{
		if (abs(dA) > (snap > 10 ? 0.6 * snap : JUMP_DEG)) dA = 0;	// a snap's head step: ViewJump's
		Expire(hAmt, hEnd, now);
		Expire(cAmt, cEnd, now);
		Expire(lAmt, lEnd, now);
		Expire(mAmt, mEnd, now);
		// each late controller coming back first pays off what it owes; a new step against the head's is owed, never
		// matched (measured at 35 fps: the controllers trail the head by one frame's step, +0.4, +1.0, +1.4, +1.9
		// while it sped up, back to 0 as it stopped; matched, that moved the torso 1.9 degrees). Kept per controller: a
		// hand pointed down (at a holster) swings its yaw about, and a shared reading lost the other hand's debt.
		d0 = Owe(lAmt, lEnd, d0, dA, now, snap);
		d1 = Owe(mAmt, mEnd, d1, dA, now, snap);
		double c = 0;
		if (d0 * d1 > 0) c = abs(d0) < abs(d1) ? d0 : d1;
		Add(hAmt, hEnd, dA, now + WAIT_TICS);
		Add(cAmt, cEnd, c, now + WAIT_TICS);
		double sH = Sum(hAmt), sC = Sum(cAmt);
		if (sH * sC <= 0) return 0;
		double m = abs(sH) < abs(sC) ? sH : sC;
		if (abs(sH - sC) > min(abs(sC) / 3.0, AGREE) + 0.5 + (snap > 0 && snap <= 10 ? snap : 0)) return 0;
		Take(hAmt, hEnd, m);
		Take(cAmt, cEnd, m);
		return m;
	}

	// TURNING WITH HEAD AND HANDS: this tic's turn of the body (yaw) toward the head (a) and the controllers (h0, h1
	// as the engine gives them: a controller held straight ahead reads the pawn's angle less 90; p0, p1 their pitch).
	// allowed: the switch is on and nothing holds the body still (looking down, edit mode).
	double With(double yaw, double a, double h0, double h1, double p0, double p1, bool allowed)
	{
		double o = Actor.DeltaAngle(yaw, a), o0 = Actor.DeltaAngle(yaw, h0 + 90), o1 = Actor.DeltaAngle(yaw, h1 + 90);
		bool same = allowed && jPend == 0 && abs(p0) <= HAND_PITCH && abs(p1) <= HAND_PITCH && o * o0 > 0 && o * o1 > 0;
		double near = min(abs(o), min(abs(o0), abs(o1)));
		if (!same || near < STOP_AT) { withFor = 0; withOn = false; return 0; }
		if (!withOn)
		{
			// just after it turned with you, a smaller lead starts it again (a real turn's head and hands lead and stop
			// at their own pace: measured on the rig, the body caught the trailing hands, stopped, and was left 18.6
			// degrees short when they stopped under START_AT)
			double start = level.maptime - withLast <= AGAIN_TICS ? AGAIN_AT : START_AT;
			withFor = near > start ? withFor + 1 : 0;
			if (withFor < DWELL) return 0;
			withOn = true;
		}
		withLast = level.maptime;
		double t = clamp((o > 0 ? 1 : -1) * near * 0.5, -CHASE, CHASE);
		// what this turn covers is no longer pending: the queues must not turn the body by it a second time
		if (Sum(hAmt) * t > 0 && Sum(cAmt) * t > 0) { Take(hAmt, hEnd, t); Take(cAmt, cEnd, t); }
		Note(t);
		if (rW.Size() > 0) rW[rW.Size() - 1] += t;
		if (tOn) tW += t;
		return t;
	}

	// one controller's step after its debt: a step back pays it off; a step against the head's step is owed
	// (11-03, second pass) A snap's step pays no debt and is never owed (snaps are ViewJump's), and what a controller
	// owes is capped at OWE_MAX: measured on the rig, a hand reaching about a hip holster (its yaw swinging +-40
	// degrees) while the head swept +-60 ran up debts of tens of degrees, and the next snap's controller step went to
	// paying them: the body missed that snap, then turned 89 degrees on the one after. The engine's late frame is never
	// more than a frame's head step (16-19 degrees seen on the rig when its frames came in bursts; a 6-degree cap let
	// that through as a 16-degree turn).
	static double Owe(Array<double> q, Array<int> e, double d, double dA, int now, double snap)
	{
		if (snap > 10 && abs(d) > 0.5 * snap) return d;
		d = Cancel(q, e, d);
		if (d * dA < 0 && abs(d) <= abs(dA) + 0.5 && abs(Sum(q) + d) <= OWE_MAX) { Add(q, e, d, now + LATE_TICS); return 0; }
		return d;
	}

	static double Sum(Array<double> q) { double s = 0; for (int i = 0; i < q.Size(); i++) s += q[i]; return s; }

	static void Expire(Array<double> q, Array<int> e, int now)
	{
		for (int i = q.Size() - 1; i >= 0; i--) if (e[i] < now) { q.Delete(i); e.Delete(i); }
	}

	// a new step: one against the queue cancels its oldest entries first, so the queue keeps one sign
	static void Add(Array<double> q, Array<int> e, double v, int endTic)
	{
		v = Cancel(q, e, v);
		if (abs(v) >= 0.0001) { q.Push(v); e.Push(endTic); }
	}

	// a step against the queue takes its oldest entries away; what is left of the step comes back
	static double Cancel(Array<double> q, Array<int> e, double v)
	{
		while (q.Size() > 0 && q[0] * v < 0 && abs(v) >= 0.0001)
		{
			if (abs(q[0]) <= abs(v)) { v += q[0]; q.Delete(0); e.Delete(0); }
			else { q[0] += v; v = 0; }
		}
		return abs(v) < 0.0001 ? 0 : v;
	}

	// take a matched amount out, oldest first (same sign as the queue)
	static void Take(Array<double> q, Array<int> e, double m)
	{
		double r = abs(m);
		while (q.Size() > 0 && r > 0)
		{
			double x = abs(q[0]);
			if (x <= r + 0.0001) { r -= x; q.Delete(0); e.Delete(0); }
			else { q[0] = q[0] > 0 ? x - r : r - x; r = 0; }
		}
	}
}

// THE BODY FOR OTHER MODS (11-03): RSQ ShieldSaw hangs its shield on this body when both are loaded, so the shield and
// the holsters turn together, every snap. Found by name: GetDouble("body.yaw", "", 0, 0, pawn) is the body's heading in
// degrees for the console player's pawn, brought up to date this tic first (whichever event handler asks first); any
// other pawn, or a body not yet started, answers 999. GetDouble("body.recenter", ...) recenters it (11-03 18:56).
class RSQTR_BodyService : Service
{
	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "body.yaw" && request != "body.recenter") return 999;
		let pmo = PlayerPawn(objectArg);
		let rig = RSQTR_Rig.Get();
		if (!rig || !pmo || !pmo.player || pmo.player != players[consoleplayer]) return 999;
		let b = rig.GetBody();
		if (!b) return 999;
		b.Update(pmo);
		// "body.recenter" (11-03 18:56): RSQ ShieldSaw's own Recenter key, with the shield on this body, recenters it here
		// (with the click and the tick); answers the new heading
		if (request == "body.recenter") { rig.DoRecenter(pmo); return b.yaw; }
		return b.primed ? b.yaw : 999;
	}
}

// A RUMBLE WITH A LENGTH AND A STRENGTH, on one controller. The series' route:
// A_QuakeEx QF_WAVE re-issued every tic drives the per-hand vibrate the Quest
// runtime honours (X = left controller, Y = right), amplitude decaying.
class RSQTR_Buzzer : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;
	int delay;      // tics before this pulse starts (the second pulse of Refuse's double)

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH
	}

	// THE HOLSTERS' FEEL (owner 2026-11-08, "sound and buzz vocabulary"): a hand entering a holster, a store and a draw are
	// each ONE pulse (Start); a refused press is the only DOUBLE pulse: two short pulses with a gap (Refuse).
	const REFUSE_AMP = 0.3;
	const REFUSE_TICS = 3;
	const REFUSE_GAP = 4;      // tics of quiet between the two pulses
	static void Refuse(Actor who, int hand)
	{
		Start(who, hand, REFUSE_AMP, REFUSE_TICS);
		Start(who, hand, REFUSE_AMP, REFUSE_TICS, REFUSE_TICS + REFUSE_GAP);
	}

	static void Start(Actor who, int hand, double strength, int tics, int after = 0)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let cv = CVar.GetCVar("rsqtr_haptics", who.player);
		if (cv && !cv.GetBool()) return;
		// RUMBLE STRENGTH (RSQ_Accessibility's rsqa_rumble_scale, RSQTR_A11y.Rumble: x0..2, 0 = none; 1 without it).
		// Every Tactical Rig rumble comes through here.
		double rs = RSQTR_A11y.Rumble();
		if (rs <= 0) return;
		strength *= rs;
		let q = RSQTR_Buzzer(Actor.Spawn("RSQTR_Buzzer", who.pos));
		if (!q) return;
		bool lefty = RSQTR_Body.LeftHanded();
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
		q.delay = clamp(after, 0, 16);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (delay > 0) { delay--; return; }
		if (tleft <= 0) return;
		if (tleft == total && feels.player && RSQTR_Rig.Flag("rsqtr_messages", feels.player, false))
			Console.Printf("T_BUZZ t%d %s hand %.2f for %d tics", level.maptime, left ? "left" : "right", amp, total);
		if (tleft == total) RSQTR_A11y.RumbleBackup(feels, left);   // RSQ_Accessibility's Rumble Backup, at Quake Haptics 0 (a11y.zs)
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 40; Stop; }
}
