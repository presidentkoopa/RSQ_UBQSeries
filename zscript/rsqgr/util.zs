// RSQGR_Util -- reads only: settings, the hand, the world's clock.
//
// THE HAND. On stock QuestZDoom 17.3 the OpenXR layer writes the real controller
// pose into AttackPos/OffhandPos and AttackAngle/AttackPitch (hw_openxrdevice.cpp
// 587-609), for the camera player only, once per rendered frame. Two engine
// conventions: the yaw is stored minus 90 degrees and the pitch is positive UP
// (hw_vrmodes.cpp 443-444 writes AttackAngle = viewYaw - 90, AttackPitch =
// -viewPitch). The direction is a ROOM direction; map space is the room squashed
// by pixelstretch (1.2) vertically, so in map units the hand points along
// (x, y, z / 1.2) -- measured in the rig against the engine's own AttackDir.
//
// NOT SERIALIZED, and that is the trap after a load: AttackPos, the angles and
// OverrideAttackPosDir are plain fields with no Serialize entry (p_mobj.cpp), so
// until the first frame renders after a load they hold zero and AttackDir (a
// function pointer the renderer installs, hw_vrmodes.cpp 439) is null. Nothing
// here calls AttackDir, and a pose that is not believable (override off, or the
// hand further than ARM_MAX from the body) falls back to the body's own aim.
class RSQGR_Util
{
	const ARM_MAX = 96.0;           // map units; a real arm reaches ~0.8 m = 27 u
	const PIXELSTRETCH = 1.2;

	static clearscope double Num(String n, double d)
	{
		let c = CVar.FindCVar(n);
		return c ? c.GetFloat() : d;
	}
	static clearscope int Opt(String n, int d)
	{
		let c = CVar.FindCVar(n);
		return c ? c.GetInt() : d;
	}
	static clearscope bool Flag(String n, bool d)
	{
		let c = CVar.FindCVar(n);
		return c ? c.GetBool() : d;
	}

	// Map-space unit direction from a room yaw (degrees, engine sense restored)
	// and a room pitch (positive up).
	static clearscope Vector3 MapDir(double yaw, double pitchUp)
	{
		Vector3 d = (cos(pitchUp) * cos(yaw), cos(pitchUp) * sin(yaw), sin(pitchUp) / PIXELSTRETCH);
		return d.Unit();
	}

	// RSQ_Accessibility's Off-Hand Modifier (One-Handed): while it is held the off hook is fired
	// from the main controller, so one hand reaches both hooks. Absent / off: hand is hand.
	static clearscope int Ctrl(PlayerPawn pmo, int hand) { return RSQGR_A11y.Ctrl(pmo, hand); }

	static clearscope bool PoseGood(PlayerPawn pmo, int hand)
	{
		if (!pmo || !pmo.OverrideAttackPosDir) return false;
		hand = Ctrl(pmo, hand);
		Vector3 h = hand == 0 ? pmo.AttackPos : pmo.OffhandPos;
		Vector3 d = h - pmo.Pos;
		if (d.xy.Length() > ARM_MAX) return false;
		if (d.z < -ARM_MAX || d.z > pmo.Height + ARM_MAX) return false;
		return true;
	}

	// Where the hand is, in the world. Body fallback: the shooting point.
	static clearscope Vector3 HandPos(PlayerPawn pmo, int hand)
	{
		if (PoseGood(pmo, hand)) return Ctrl(pmo, hand) == 0 ? pmo.AttackPos : pmo.OffhandPos;
		double z = pmo.Height * 0.5 + 8;
		if (pmo.player) z = pmo.player.viewz - pmo.Pos.z - 8;
		return pmo.Pos + (0, 0, z);
	}

	// Yaw (engine degrees) and pitch (positive up) of the hand, or of the view.
	static clearscope double HandYaw(PlayerPawn pmo, int hand)
	{
		if (PoseGood(pmo, hand)) return (Ctrl(pmo, hand) == 0 ? pmo.AttackAngle : pmo.OffhandAngle) + 90;
		return pmo.Angle;
	}
	static clearscope double HandPitch(PlayerPawn pmo, int hand)
	{
		if (PoseGood(pmo, hand)) return Ctrl(pmo, hand) == 0 ? pmo.AttackPitch : pmo.OffhandPitch;
		return -pmo.Pitch;
	}

	// THE WORLD'S CLOCK. RSQ_SlowMo slows every thing near a player that is not the
	// player's own (RSQSM_Service "scale", permille; -1 or absent = full speed). The
	// player and this mod's own actors run in real time (its RealTime test passes any
	// class whose name starts "rsq"). So: a monster moved BY POSITION here must be
	// moved scale times as far per tic; a velocity GIVEN to a monster is a push, and
	// RSQ_SlowMo's Impulses() scales a push by the factor itself -- so a velocity is
	// given at full-time size and never pre-scaled, or it would be scaled twice.
	static play double WorldScale()
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service s;
		while (s = it.Next())
		{
			int v = s.GetInt("scale", "", 0, 0, null);
			if (v >= 0) return clamp(v / 1000.0, 0.01, 1.0);
		}
		return 1.0;
	}

	static clearscope double Metres(Vector3 v)
	{
		double z = v.z * PIXELSTRETCH;
		return sqrt(v.x * v.x + v.y * v.y + z * z) / 34.0;
	}
}
