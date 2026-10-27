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
	// headset) at eye height.
	static Vector3 Head(PlayerPawn pmo)
	{
		return (pmo.pos.x, pmo.pos.y, pmo.player ? pmo.player.viewz : pmo.pos.z + pmo.height * 0.9);
	}

	// A point fwd / left / up METRES from the head, in the body's frame.
	Vector3 At(PlayerPawn pmo, double fwdMetres, double leftMetres, double upMetres)
	{
		double c = cos(yaw), s = sin(yaw);
		double fx = c * fwdMetres - s * leftMetres;
		double fy = s * fwdMetres + c * leftMetres;
		return Head(pmo) + (fx * UPM, fy * UPM, upMetres * UPM / PIXELSTRETCH);
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
