// THE BODY THE RIG HANGS ON.
//
// Hands are exact on stock QuestZDoom 17.3: the OpenXR layer writes the real
// controller poses into AttackPos / OffhandPos (and their angles) for the camera
// player. Ermac's Virtual Tactical Vest predates that and had to find the hand by
// firing an invisible missile every tic; none of that is needed here.
//
// THE BODY IS NOT THE HEAD. pmo.angle follows the headset, so a rig placed off it
// swings round every time you look sideways -- the original vest did exactly that.
// So the body keeps its own yaw: it stays put while you look around inside a dead
// zone, follows when the head goes past it, drifts back to centre slowly, and
// takes a snap or smooth turn whole (the pawn's angle jumping by more than a head
// can turn in one tic is a turn, not a look).
//
// ROOM vs MAP: 34 map units per metre horizontally, 28.33 vertically (Doom's
// pixels are 1.2 tall). Every offset here is given in metres and converted per
// axis, the convention the rest of the series uses.
class RSQTR_Body play
{
	const UPM = 34.0;
	const PIXELSTRETCH = 1.2;
	const DEADZONE = 35.0;     // degrees of head turn the body ignores
	const DRIFT = 0.6;         // degrees per tic the body eases back under the head
	const TURN_JUMP = 20.0;    // degrees in one tic that are a turn, not a look

	double yaw;                // the body's heading, degrees
	double lastHead;
	bool primed;

	void Update(PlayerPawn pmo)
	{
		double head = pmo.angle;
		if (!primed) { yaw = head; lastHead = head; primed = true; return; }
		double jump = Actor.DeltaAngle(lastHead, head);
		lastHead = head;
		if (abs(jump) >= TURN_JUMP) { yaw += jump; return; }     // a snap turn carries the body
		double off = Actor.DeltaAngle(yaw, head);
		if (off > DEADZONE) yaw += off - DEADZONE;
		else if (off < -DEADZONE) yaw += off + DEADZONE;
		else yaw += clamp(off, -DRIFT, DRIFT) * (abs(off) > 2.0 ? 1.0 : 0.0);
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
