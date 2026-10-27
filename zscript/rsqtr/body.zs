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
// in, the way UltraBadassQuestSaber's UBQS_FrameKeeper does it: a snap or smooth turn
// rotates the whole tracking space, which shows as BOTH controllers' yaws moving with
// the pawn's angle in the same tic; a head turn moves the angle alone. Looking around
// leaves the rig where it is; turns carry it.
//
// Turning your actual body in the room cannot be seen (there is no body tracker), so a
// head turned past rsqtr_body_turn degrees (35) and held rsqtr_body_secs (1 s) is taken as the
// body turning, and the body eases round to it; small looks to the side, and anything while you
// look steeply down, leave it.
//
// ROOM vs MAP: 34 map units per metre horizontally, 28.33 vertically (Doom's
// pixels are 1.2 tall). Every offset here is given in metres and converted per
// axis, the convention the rest of the series uses.
class RSQTR_Body play
{
	const UPM = 34.0;
	const PIXELSTRETCH = 1.2;
	const TOL = 1.5;           // degrees: both controllers moved with the pawn = a turn
	const SWING = 3.0;         // most degrees per tic the body turns while it catches up (an ease, not a snap)
	const STEEP = 78.0;        // degrees of head pitch past which the head's yaw is not trusted (near straight down)

	double yaw;                // the body's heading, degrees
	double lastA, lastH0, lastH1;
	int    offFor;             // tics the head has been held far round
	bool   swinging;
	bool   primed;

	void Update(PlayerPawn pmo)
	{
		UpdateSeat(pmo);
		double a = pmo.angle, h0 = pmo.AttackAngle, h1 = pmo.OffhandAngle;
		if (!primed) { yaw = a; lastA = a; lastH0 = h0; lastH1 = h1; primed = true; return; }
		double dA = Actor.DeltaAngle(lastA, a);
		double d0 = Actor.DeltaAngle(lastH0, h0), d1 = Actor.DeltaAngle(lastH1, h1);
		lastA = a; lastH0 = h0; lastH1 = h1;
		// The tracking space turned (snap, smooth, or a teleport's new facing): the body turns with it.
		if (abs(dA) > 0.0001 && abs(d0 - dA) < TOL && abs(d1 - dA) < TOL) yaw += dA;

		// A head held far round for long enough: the body has turned in the room.
		let p = pmo.player;
		double limit = RSQTR_Rig.Num("rsqtr_body_turn", p, 35.0);
		int need = int(RSQTR_Rig.Num("rsqtr_body_secs", p, 1.0) * TICRATE);
		double off = Actor.DeltaAngle(yaw, a);
		// LOOKING DOWN AT YOURSELF IS NOT TURNING. With the head pitched steeply the
		// headset's yaw swings wildly (the owner's headset, 10-27: "it keeps spinning all
		// around me" looking at the rig), and in edit mode the body must hold still while
		// regions are placed on it. Neither counts toward, nor continues, a swing.
		if (abs(pmo.pitch) > STEEP || RSQTR_Rig.Flag("rsqtr_edit", p, false))
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
		seatOn = c && c.GetBool() && h > 0.3;     // no headset height read: the standing rule
		if (!seatOn) { seatEye = 0; seatLow = 0; return; }
		seatLow = h < seatEye - SEAT_DROP ? seatLow + 1 : 0;
		if (seatEye <= 0 || h > seatEye || seatLow > TICRATE) { seatEye = h; seatLow = 0; }
		else seatEye = max(h, seatEye - SEAT_EASE);
	}

	// The room floor in map height, as the engine places the hands (above).
	static double RoomFloor(PlayerPawn pmo)
	{
		let p = pmo.player;
		if (!p) return pmo.pos.z;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		if (!cb || cb.GetBool()) return p.viewz - pmo.ViewHeight;
		return p.viewz - EyeUnits(pmo, pmo.HmdPosition.y);
	}

	static double EyeUnits(PlayerPawn pmo, double metres)
	{
		let ha = CVar.FindCVar("vr_height_adjust");
		return (metres + (ha ? ha.GetFloat() : 0)) * UPM / PIXELSTRETCH;
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
		return h + (fx * UPM, fy * UPM, upMetres * UPM / PIXELSTRETCH);
	}

	// Distance in the ROOM between two map points, in metres.
	static double RoomMetres(Vector3 a, Vector3 b)
	{
		Vector3 d = a - b;
		return (d.x, d.y, d.z * PIXELSTRETCH).Length() / UPM;
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
		let h = CVar.FindCVar("rsqa_handed");
		int v = h ? h.GetInt() : 0;
		if (v == 1) return false;
		if (v == 2) return true;
		return LeftHanded();
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

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH
	}

	static void Start(Actor who, int hand, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let cv = CVar.GetCVar("rsqtr_haptics", who.player);
		if (cv && !cv.GetBool()) return;
		let q = RSQTR_Buzzer(Actor.Spawn("RSQTR_Buzzer", who.pos));
		if (!q) return;
		bool lefty = RSQTR_Body.LeftHanded();
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}
