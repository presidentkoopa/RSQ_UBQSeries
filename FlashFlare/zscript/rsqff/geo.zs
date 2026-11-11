// RSQ FlashFlare -- WHERE THINGS ARE: the hands, the eyes, the body the pocket hangs on, and the drawn flare's burning end.
// Everything here is the series' rig-proven geometry, copied under this pack's prefix (no pack links against another):
//   Eyes / FromEyes        RSQ Grenade hand.zs RSQGN_Geo (the headset's real height, the head's own frame)
//   HandPoint              RSQ Tactical Rig cig.zs RSQTR_Cig.HandPoint (a point of a prop baked into Brutal Doom 22 VR's
//                          hand mesh, through the engine's own hand-model transform; rig-checked there with a marker)
//   the body               RSQ Tactical Rig's body ("body.yaw", asked by name) when it is loaded; else a body of our own
//                          that turns with snap / stick turns and eases under the head while you are not looking down.
class RSQFF_Geo play
{
	// the burning end of flare_h.md3, md3 cm in the hand mesh's space (tools/gen_flare.py prints it)
	const TIP_X = 8.29;
	const TIP_Y = 2.84;
	const TIP_Z = 15.57;
	// the flare's axis in that space (the magazine hold's gripped cylinder, tools/fit_grip.py)
	const AX_X = 0.235;
	const AX_Y = -0.109;
	const AX_Z = 0.966;

	static bool InVR(PlayerPawn pmo) { return pmo && pmo.player && pmo.OverrideAttackPosDir; }
	static Vector3 Pos(PlayerPawn pmo, int h) { return h == 0 ? pmo.AttackPos : pmo.OffhandPos; }

	// THE ENGINE'S FIXED EYE HEIGHT (owner 2026-11-11, design/rigtest_2026-11-10/RESULTS_DOWNSHOT.md). With
	// vr_crouch_use_button on, QuestZDoom 17.3 places the eyes and the hands at viewz + the headset's height - a height it
	// caches ONCE (hw_openxrdevice.cpp:158-170, getDoomPlayerHeightWithoutCrouch: the pawn's ViewHeight at its first
	// frame). RSQ SlowMo's DOWN scales the pawn's ViewHeight to 40% while you are down, so pmo.ViewHeight is not that number
	// then; the pawn class's default (pmo.Default) is, crouched or not. A crouch still reaches the eyes through viewz. Code only, not shown.
	static clearscope double StandEyeHeight(PlayerPawn pmo) { return pmo ? pmo.Default.ViewHeight : 41.0; }

	static double Ps(PlayerPawn pmo)
	{
		double ps = pmo.Level.pixelstretch;
		return ps > 0 ? ps : 1.2;
	}

	static double Vu()
	{
		let cv = CVar.FindCVar("vr_vunits_per_meter");
		double v = cv ? cv.GetFloat() : 34;
		return v > 0 ? v : 34;
	}

	// a map-space vector's real length in metres
	static double Metres(PlayerPawn pmo, Vector3 v) { return (v.x, v.y, v.z * Ps(pmo)).Length() / Vu(); }

	// YOUR REAL EYES (RSQ Grenade RSQGN_Geo.Eyes): the pawn's place at the headset's height, as the engine places the hands
	static Vector3 Eyes(PlayerPawn pmo)
	{
		let p = pmo.player;
		double vz = p ? p.viewz : pmo.pos.z + pmo.height * 0.9;
		double hy = pmo.HmdPosition.y;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		if (p && hy > 0.3 && (!cb || cb.GetBool()))
		{
			let ha = CVar.FindCVar("vr_height_adjust");
			vz += (hy + (ha ? ha.GetFloat() : 0)) * Vu() / Ps(pmo) - StandEyeHeight(pmo);
		}
		return (pmo.pos.x, pmo.pos.y, vz);
	}

	// metres forward along where you look and down from the eyes, in the head's frame
	static Vector3 FromEyes(PlayerPawn pmo, double fwd, double down)
	{
		double u = Vu();
		double hp = clamp(pmo.pitch, -89, 89);
		double horiz = fwd * cos(hp) - down * sin(hp);
		double vert = -fwd * sin(hp) - down * cos(hp);
		return Eyes(pmo) + (cos(pmo.angle) * horiz * u, sin(pmo.angle) * horiz * u, vert * u / Ps(pmo));
	}

	static bool LeftHanded()
	{
		let cs = CVar.FindCVar("vr_control_scheme");
		return cs && cs.GetInt() >= 10;
	}

	// THE POCKET: on the chest, toward the MAIN hand's side, taken by the OFF hand reaching across (the cigarette pocket of
	// RSQ Tactical Rig is the mirror of it, taken by the main hand). Hung from the neck, not the face (Tactical Rig body.zs:
	// a nod swings the headset forward round the neck; the neck is 0.10 m behind and under the eyes in the head's frame),
	// turned by the body's yaw. Free of every Tactical Rig place: 0.21 m over its main-side chest holster, 0.25 m from
	// the shoulder, the cigarette pocket on the other side.
	static Vector3 Pocket(PlayerPawn pmo, double bodyYaw)
	{
		let p = pmo.player;
		double f = CVar.GetCVar("rsqff_pocket_f", p) ? CVar.GetCVar("rsqff_pocket_f", p).GetFloat() : 0.12;
		double l = CVar.GetCVar("rsqff_pocket_l", p) ? CVar.GetCVar("rsqff_pocket_l", p).GetFloat() : 0.15;
		double u = CVar.GetCVar("rsqff_pocket_u", p) ? CVar.GetCVar("rsqff_pocket_u", p).GetFloat() : -0.28;
		// toward the main hand: the right for a right-handed player (a negative "left")
		double left = LeftHanded() ? l : -l;
		Vector3 neck = FromEyes(pmo, -0.10, 0.10);
		double vu = Vu();
		f += 0.10; u += 0.10;     // the neck back to the eyes' line in the body's frame
		Vector2 fw = (cos(bodyYaw), sin(bodyYaw)), lf = (-sin(bodyYaw), cos(bodyYaw));
		Vector2 xy = (fw * f + lf * left) * vu;
		return neck + (xy.x, xy.y, u * vu / Ps(pmo));
	}

	// A POINT OF THE FLARE DRAWN IN THE OFF HAND: md3 cm (mx, my, mz) of flare_h.md3 through the engine's hand-model
	// transform (RSQ Tactical Rig RSQTR_Cig.HandPoint, unchanged but for the hand: always the off hand here).
	static Vector3 HandPoint(PlayerPawn pmo, int h, double mx, double my, double mz)
	{
		let wsv = CVar.FindCVar("vr_weaponScale");
		double ws = wsv ? wsv.GetFloat() : 1.02;
		Vector3 v = (-ws * my, ws * mz - 10 + 5, -ws * mx - 24 + 30) * 0.01;
		bool rightHanded = !LeftHanded();
		int idx = (h == 1) ? (rightHanded ? 0 : 1) : (rightHanded ? 1 : 0);
		Weapon w = h == 0 ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
		if (idx == 0 && !(w && w.bNoAutoReverse)) v.x = -v.x;
		double yw = h == 0 ? pmo.AttackAngle : pmo.OffhandAngle;
		double pt = h == 0 ? pmo.AttackPitch : pmo.OffhandPitch;
		double rl = -(h == 0 ? pmo.AttackRoll : pmo.OffhandRoll);
		v = (v.x * cos(rl) - v.y * sin(rl), v.x * sin(rl) + v.y * cos(rl), v.z);
		v = (v.x, v.y * cos(pt) - v.z * sin(pt), v.y * sin(pt) + v.z * cos(pt));
		v = (v.x * cos(yw) + v.z * sin(yw), v.y, -v.x * sin(yw) + v.z * cos(yw));
		double vu = Vu();
		return Pos(pmo, h) + (vu * v.x, -vu * v.z, vu * v.y / Ps(pmo));
	}

	static Vector3 Tip(PlayerPawn pmo) { return HandPoint(pmo, 1, TIP_X, TIP_Y, TIP_Z); }
	// the flare's direction in the world, butt to burning end (for a flare that leaves the hand)
	static Vector3 Axis(PlayerPawn pmo)
	{
		Vector3 a = HandPoint(pmo, 1, TIP_X, TIP_Y, TIP_Z), b = HandPoint(pmo, 1, TIP_X - AX_X * 10, TIP_Y - AX_Y * 10, TIP_Z - AX_Z * 10);
		Vector3 d = a - b;
		d.z *= Ps(pmo);
		double l = d.Length();
		return l > 0 ? d / l : (1, 0, 0);
	}
}
