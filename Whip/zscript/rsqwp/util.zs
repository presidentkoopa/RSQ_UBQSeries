// RSQWP_Util -- reads only: settings and the hand.
// 2026-11-27 (owner: "i want to tone this thing down"): the smoothed aim (the mark's and the ray's), the Miniboss question
// (the yank's) and the world's clock (the leash's and the flail's) went with them.
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
class RSQWP_Util
{
	const ARM_MAX = 96.0;           // map units; a real arm reaches ~0.8 m = 27 u
	// the level's own pixel ratio, read live (Quest teardown apply/01 2.2): 1.2 on stock maps
	static clearscope double PS() { double v = level ? level.pixelstretch : 1.2; return v > 0 ? v : 1.2; }

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
		Vector3 d = (cos(pitchUp) * cos(yaw), cos(pitchUp) * sin(yaw), sin(pitchUp) / PS());
		return d.Unit();
	}

	static clearscope bool PoseGood(PlayerPawn pmo, int hand)
	{
		if (!pmo || !pmo.OverrideAttackPosDir) return false;
		// BOTH HANDS AT ONE POINT is the engine's collapsed pose (a menu just closed, a level just began --
		// hw_vrmodes.cpp writes both hands to the body): never a real pose, and a press read there fired from the
		// chest (Quest teardown apply/01 2.1b; Gun Bonsai's gloves.zs already guards it).
		if (pmo.AttackPos == pmo.OffhandPos) return false;
		Vector3 h = hand == 0 ? pmo.AttackPos : pmo.OffhandPos;
		Vector3 d = h - pmo.Pos;
		if (d.xy.Length() > ARM_MAX) return false;
		if (d.z < -ARM_MAX || d.z > pmo.Height + ARM_MAX) return false;
		return true;
	}

	// Where the hand is, in the world. Body fallback: the shooting point.
	static clearscope Vector3 HandPos(PlayerPawn pmo, int hand)
	{
		if (PoseGood(pmo, hand)) return hand == 0 ? pmo.AttackPos : pmo.OffhandPos;
		double z = pmo.Height * 0.5 + 8;
		if (pmo.player) z = pmo.player.viewz - pmo.Pos.z - 8;
		return pmo.Pos + (0, 0, z);
	}

	// Yaw (engine degrees) and pitch (positive up) of the hand, or of the view.
	static clearscope double HandYaw(PlayerPawn pmo, int hand)
	{
		if (PoseGood(pmo, hand)) return (hand == 0 ? pmo.AttackAngle : pmo.OffhandAngle) + 90;
		return pmo.Angle;
	}
	static clearscope double HandPitch(PlayerPawn pmo, int hand)
	{
		if (PoseGood(pmo, hand)) return hand == 0 ? pmo.AttackPitch : pmo.OffhandPitch;
		return -pmo.Pitch;
	}
}
