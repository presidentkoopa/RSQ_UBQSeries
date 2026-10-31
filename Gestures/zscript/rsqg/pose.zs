// RSQG_Pose -- reads only: where a hand is and how it is turned, in the player's own frame, in metres.
//
// THE HAND ON STOCK QUESTZDOOM 17.3. The OpenXR layer writes the controller pose into AttackPos /
// OffhandPos and AttackAngle / AttackPitch / AttackRoll (and Offhand*) once per rendered frame, for the
// camera player only (hw_openxrdevice.cpp 587-609). Valid while OverrideAttackPosDir is set. The yaw is
// stored minus 90 degrees and the pitch is positive UP. MAIN is the engine's main hand: the right
// controller, or the LEFT one when vr_control_scheme >= 10 (RSQ_Accessibility's Left-Handed sets it).
// Not serialized: after a load they hold zero until a frame renders, and PoseGood() refuses that.
//
// WHERE THE EYES ARE, which REMA publishes as HmdPos and QZD does not. QZD gives HmdPosition (stage
// metres, y = height) and builds the hand's height as
//     AttackPos.z = eyeZ' + (hmdY + handOffY + vr_height_adjust) * vr_vunits_per_meter / pixelstretch - H
// where H is the HMD height in map units (crouch from the headset) or the pawn's ViewHeight (crouch
// on a button; vr_crouch_use_button). So the real eye height in the map is
//     viewz + hmdHeight - H
// and the hand's height above the eyes comes out as exactly handOffY (measured on the rig: hand 0.30 m
// below the headset reads -8.5 units = -0.30 * 34 / 1.2 with either crouch setting's numbers).
// Horizontally the pawn stands where the headset is: AttackPos.xy = pawn.xy - offset * 34.
//
// METRES, AND THE VERTICAL x pixelstretch. Map space is the room squashed by level.pixelstretch (1.2)
// vertically, so a vertical map distance is multiplied by it before dividing by vr_vunits_per_meter.
class RSQG_Pose
{
	const ARM_MAX = 96.0;   // map units: a hand further than this from the body is not a real reading

	static clearscope double UnitsPerMeter()
	{
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double u = c ? c.GetFloat() : 34.0;
		return u > 1.0 ? u : 34.0;
	}

	static clearscope double Stretch()
	{
		double ps = level.pixelstretch;
		return ps > 0.1 ? ps : 1.2;
	}

	// the engine's main hand is the physical LEFT controller
	static clearscope bool MainIsLeft()
	{
		let cs = CVar.FindCVar("vr_control_scheme");
		return cs && cs.GetInt() >= 10;
	}
	// this hand (0 main, 1 off) is the physical left controller
	static clearscope bool IsLeft(int hand) { return (hand == 0) == MainIsLeft(); }

	static clearscope bool PoseGood(PlayerPawn pmo, int hand)
	{
		if (!pmo || !pmo.player || !pmo.OverrideAttackPosDir) return false;
		Vector3 h = hand == 0 ? pmo.AttackPos : pmo.OffhandPos;
		if (h.x == 0 && h.y == 0 && h.z == 0) return false;   // never written (just loaded)
		Vector3 d = h - pmo.Pos;
		if (d.xy.Length() > ARM_MAX) return false;
		if (d.z < -ARM_MAX || d.z > pmo.Height + ARM_MAX) return false;
		return true;
	}

	static clearscope Vector3 HandPos(PlayerPawn pmo, int hand)
	{
		return hand == 0 ? pmo.AttackPos : pmo.OffhandPos;
	}

	// the eyes, in the map
	static clearscope Vector3 EyePos(PlayerPawn pmo)
	{
		let p = pmo.player;
		double u = UnitsPerMeter(), ps = Stretch();
		let adj = CVar.FindCVar("vr_height_adjust");
		double hmdH = (pmo.HmdPosition.y + (adj ? adj.GetFloat() : 0)) * u / ps;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		double h = (cb && cb.GetBool()) ? pmo.ViewHeight : hmdH;
		return (pmo.Pos.x, pmo.Pos.y, p.viewz + hmdH - h);
	}

	// a map-space offset in metres, still on the map's axes
	static clearscope Vector3 Metric(Vector3 v)
	{
		return (v.x, v.y, v.z * Stretch()) / UnitsPerMeter();
	}

	// the hand from the eyes, in metres, on the map's axes (turning the head does not move it)
	static clearscope Vector3 FromEyes(PlayerPawn pmo, int hand)
	{
		return Metric(HandPos(pmo, hand) - EyePos(pmo));
	}

	// ...and in the player's own frame: x forward (where you look), y left, z up, metres
	static clearscope Vector3 Body(PlayerPawn pmo, int hand)
	{
		Vector3 d = FromEyes(pmo, hand);
		double c = cos(pmo.Angle), s = sin(pmo.Angle);
		return (d.x * c + d.y * s, -d.x * s + d.y * c, d.z);
	}

	static clearscope double Roll(PlayerPawn pmo, int hand)  { return hand == 0 ? pmo.AttackRoll : pmo.OffhandRoll; }
	static clearscope double Pitch(PlayerPawn pmo, int hand) { return hand == 0 ? pmo.AttackPitch : pmo.OffhandPitch; }
	// the hand's yaw in engine degrees (the stored -90 restored)
	static clearscope double Yaw(PlayerPawn pmo, int hand)   { return (hand == 0 ? pmo.AttackAngle : pmo.OffhandAngle) + 90; }

	// the way the hand points, in ROOM space (metric axes): the same basis RS_Gestures' HandForward uses
	static clearscope Vector3 Forward(PlayerPawn pmo, int hand)
	{
		double y = Yaw(pmo, hand), p = Pitch(pmo, hand);
		return (cos(y) * cos(p), sin(y) * cos(p), sin(p));
	}
}
