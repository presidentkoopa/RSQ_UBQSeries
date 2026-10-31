// HAND OVER HAND. Hanging on the rope, take hold of it with a free hand and pull down
// to climb; let go, reach up with the other hand, take hold, pull; push up to lower
// yourself. RSQWP_Core.Swing applies it; this file says which hand may, and where it is.
//
// WHICH HAND MAY: only an EMPTY one -- a climb never takes a gun out of a hand.
//   Brutal Doom Quest (BD22_VR-Reloaded r7, read from its zscript/rsq/fists.zs and
//   hands.zs): the main hand is free when it holds BD22's fists weapon (Melee_Attacks,
//   +MELEEWEAPON +CHEATNOTWEAPON); the off hand is its own off-hand weapon RSQ_Hands,
//   which is free exactly when its free-hand layer (psprite 2200, RSQ_Layers.FREEHAND)
//   shows the closed fist, state "AmmoH" -- the same test RSQ_Hands.OffFist() makes
//   (freeFist = fh == "AmmoH"). It is read by NAME (FindStateByString on the weapon
//   the player actually holds), so nothing here links against BD22Q and the test is
//   simply false without it.
//   Without BD22Q (the universal fallback): an empty slot is a free hand, and so is the
//   engine's own Fist. No weapon is handed out for it: QZD's off-hand slot is shared by
//   every off-hand mod in the series (the saber, the shield), and an invisible fist
//   weapon parked there would take it from them.
//   rsqwp_climb_free_only 0 lets any hand climb.
//
// WHERE THE HAND IS: the controller, which only the machine holding it knows (the VR
// pose fields are written for the camera player alone). That machine streams it every
// frame while a hand is on the grab bind, as a network event (RSQWP_Input.RenderOverlay
// -> rsqwp_pose), and every machine climbs by the same numbers -- single player too,
// because only the frame knows the hand's true height (see RenderOverlay).
class RSQWP_Climb
{
	const FREEHAND_LAYER = 2200;   // BD22Q RSQ_Layers.FREEHAND

	static play bool HandFree(PlayerPawn pmo, int hand)
	{
		if (!pmo || !pmo.player) return false;
		if (!RSQWP_Util.Flag("rsqwp_climb_free_only", true)) return true;
		let p = pmo.player;
		Weapon w = hand == 0 ? p.ReadyWeapon : p.OffhandWeapon;
		if (!w) return true;
		String n = w.GetClassName();
		n = n.MakeLower();
		if (n == "rsq_hands")
		{
			let psp = p.FindPSprite(FREEHAND_LAYER);
			return psp && psp.Caller == w && psp.CurState && psp.CurState == w.FindStateByString("AmmoH");
		}
		if (n == "fist" || n == "melee_attacks") return true;
		return w.bMELEEWEAPON && w.bCHEATNOTWEAPON;
	}

	// The hand's offset from the pawn, and whether there is one to use.
	static play bool, Vector3 HandOffset(PlayerPawn pmo, int pn, int hand)
	{
		let c = RSQWP_Core.Get();
		int i = pn * 2 + hand;
		if (c && level.maptime - c.poseTic[i] <= 3) return true, c.poseOff[i];
		// no stream (no frame drawn yet): single player falls back to the live pose
		if (multiplayer || !RSQWP_Util.PoseGood(pmo, hand)) return false, (0, 0, 0);
		return true, RSQWP_Util.HandPos(pmo, hand) - pmo.Pos;
	}

	// Distance from a point to the segment a-b.
	static clearscope double ToSegment(Vector3 q, Vector3 a, Vector3 b)
	{
		Vector3 ab = b - a;
		double l2 = ab dot ab;
		double t = l2 > 0.0001 ? clamp(((q - a) dot ab) / l2, 0.0, 1.0) : 0.0;
		return (q - (a + ab * t)).Length();
	}

	// 3 x 10 bits of half-units, +512: the fire event's packing.
	static clearscope int Pack(Vector3 off)
	{
		int ox = clamp(int(off.x * 2 + 512.5), 0, 1023);
		int oy = clamp(int(off.y * 2 + 512.5), 0, 1023);
		int oz = clamp(int(off.z * 2 + 512.5), 0, 1023);
		return ox | (oy << 10) | (oz << 20);
	}
	static clearscope Vector3 Unpack(int a)
	{
		return (((a & 1023) - 512) / 2.0, (((a >> 10) & 1023) - 512) / 2.0, (((a >> 20) & 1023) - 512) / 2.0);
	}
}
