// RSQ Saber -- SHOW SABERS WITHOUT THE RIG (owner 11-04: "Give them a spot without the Rig"). Rig only, not
// headset-confirmed.
// With Show Sabers on (ubqs_show, each player's own) and RSQ Tactical Rig NOT loaded (no RSQTR_RigService), each saber you
// own and do not hold hangs at the hip exactly where, and as, the Rig hangs it in its saber holsters: the main saber on
// the main hand's side, the second saber (when Dual Sabers allows one) on the off hand's side; mirrored for a left-handed
// control scheme. With the Rig loaded this draws nothing: the Rig draws them (rig.zs DrawMarkers reads ubqs_show).
// THE RIG'S MEASURED NUMBERS, copied (TacticalRig rig.zs RSQTR_Region DF/DL/DU, places 9 and 10; Hang(); body.zs At(),
// NeckShift(); fit.zs Compose(), Basis(); RSQTRFIT.txt's UBQS_Saber line, from tools/measure_pickups.py):
//   the spot: 0.02 m forward, 0.21 m out to its side, 0.84 m under the eyes, in the body's frame. No rig torso here, so
//     the body's frame is the player's yaw (the Rig's own fallback before its body is primed), hung from player.viewz
//     with the Rig's neck shift (the nod taken out: neck 0.10 m behind and 0.10 m under the eyes)
//   the hang: pitch 80 (hanging down), roll 10 outward (left spot -10, right spot +10; a left-handed layout flips it)
//   the fit: the saber's own pickup mesh (UBSP frame N, the Rig's "wear" frame; MODELDEF.hip) at 0.25 m long
//     (rsqtr_icon_m's default; the hilt is squat 0.84 so the Rig caps it there), mesh length 42.07 map units, the
//     correcting turn yaw 180 / pitch 50.2, its middle (0.01, -17.96, -4.99) put on the spot; translucent 0.85, bright
class UBQS_HipShow : EventHandler
{
	const SPOT_F = 0.02;
	const SPOT_L = 0.21;
	const SPOT_U = -0.84;
	const HANG_PITCH = 80;
	const HANG_ROLL = 10;
	const FIT_M = 0.25;
	const FIT_LEN = 42.07;
	const FIT_YAW = 180.0;
	const FIT_PITCH = 50.2;
	const FIT_CX = 0.01;
	const FIT_CY = -17.96;
	const FIT_CZ = -4.99;
	const NECK_BACK = 0.10;
	const NECK_DOWN = 0.10;

	Actor shown[MAXPLAYERS * 2];      // 0 main saber, 1 second saber

	static bool RigLoaded() { return ServiceIterator.Find("RSQTR_RigService").Next() != null; }
	static bool LeftHanded() { let cv = CVar.FindCVar("vr_control_scheme"); return cv && cv.GetInt() >= 10; }
	static double Upm() { let c = CVar.FindCVar("vr_vunits_per_meter"); double v = c ? c.GetFloat() : 34.0; return v > 0 ? v : 34.0; }
	static double Ps() { double v = level ? level.pixelstretch : 1.2; return v > 0 ? v : 1.2; }

	override void WorldTick()
	{
		bool rig = RigLoaded();
		let d = CVar.FindCVar("ubqs_dual");
		let m = CVar.FindCVar("ubqs_dual_mode");
		bool dualOk = (!d || d.GetBool()) && (!m || m.GetInt() != 0);
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			PlayerPawn pmo = (!rig && playeringame[n] && players[n].mo) ? PlayerPawn(players[n].mo) : null;
			bool on = pmo && pmo.health > 0 && players[n].playerstate == PST_LIVE;
			if (on) { let c = CVar.GetCVar("ubqs_show", players[n]); on = !c || c.GetBool(); }
			for (int k = 0; k < 2; k++)
			{
				let w = on ? Weapon(pmo.FindInventory(k == 0 ? "UBQS_Saber" : "UBQS_SaberOff")) : null;
				bool want = w && !w.bPOWERED_UP && w.Amount > 0 && (k == 0 || dualOk)
					&& w != players[n].ReadyWeapon && w != players[n].OffhandWeapon;
				int i = n * 2 + k;
				if (!want) { if (shown[i]) shown[i].bINVISIBLE = true; continue; }
				shown[i] = Hang(shown[i], pmo, k);
			}
		}
	}

	// the main saber on the main hand's side: the body's right for a right-handed scheme (the Rig's SaberHome)
	Actor Hang(Actor a, PlayerPawn pmo, int k)
	{
		bool lh = LeftHanded();
		bool leftSide = (k == 0) == lh;
		double yaw = pmo.angle;
		double u = Upm();
		double side = leftSide ? SPOT_L : -SPOT_L;
		double c = cos(yaw), s = sin(yaw);
		double pt = clamp(pmo.pitch, -89, 89);
		double nf = (NECK_BACK * (1 - cos(pt)) - NECK_DOWN * sin(pt)) * u;
		Vector3 head = (pmo.pos.x, pmo.pos.y, pmo.player ? pmo.player.viewz : pmo.pos.z + pmo.height * 0.9);
		Vector3 at = head + (cos(pmo.angle) * nf, sin(pmo.angle) * nf, 0)
			+ ((c * SPOT_F - s * side) * u, (s * SPOT_F + c * side) * u, SPOT_U * u / Ps());
		if (!a) a = Actor.Spawn("UBQS_HipSaber", at, NO_REPLACE);
		if (!a) return null;
		double rl = leftSide ? -HANG_ROLL : HANG_ROLL;
		if (lh) rl = -rl;                       // the Rig's Hang: a left-handed layout flips the roll
		double sc = FIT_M * u / FIT_LEN;
		a.Scale = (sc, sc);
		double oa, op, orl;
		[oa, op, orl] = Compose(yaw, HANG_PITCH, rl, FIT_YAW, FIT_PITCH);
		a.angle = oa; a.pitch = op; a.roll = orl;
		Vector3 bF, bL, bU;
		[bF, bL, bU] = Basis(oa, op, orl);
		Vector3 ctr = (FIT_CX, FIT_CY, FIT_CZ) * sc;
		a.SetOrigin(at - (bF * ctr.x + bL * ctr.y + bU * ctr.z), true);
		a.bINVISIBLE = false;
		return a;
	}

	// TacticalRig fit.zs Compose: the hang (a, p, r) followed by the mesh's correcting turn (cy, cp)
	static double, double, double Compose(double a, double p, double r, double cy, double cp)
	{
		Vector3 F, L, U;
		[F, L, U] = Basis(a, p, r);
		Vector3 f2 = (cos(cy) * cos(cp), sin(cy), -cos(cy) * sin(cp));
		Vector3 l2 = (-sin(cy) * cos(cp), cos(cy), sin(cy) * sin(cp));
		Vector3 nF = F * f2.x + L * f2.y + U * f2.z;
		Vector3 nL = F * l2.x + L * l2.y + U * l2.z;
		double oa = atan2(nF.y, nF.x);
		double op = -asin(clamp(nF.z, -1.0, 1.0));
		Vector3 F0, L0, U0;
		[F0, L0, U0] = Basis(oa, op, 0);
		return oa, op, atan2(nL dot U0, nL dot L0);
	}

	// TacticalRig fit.zs Basis: forward, left, up of yaw a (left +), pitch p (nose down +), roll r
	static Vector3, Vector3, Vector3 Basis(double a, double p, double r)
	{
		double ca = cos(a), sa = sin(a), cp = cos(p), sp = sin(p), cr = cos(r), sr = sin(r);
		Vector3 F = (ca * cp, sa * cp, -sp);
		Vector3 L0 = (-sa, ca, 0);
		Vector3 U0 = (ca * sp, sa * sp, cp);
		return F, L0 * cr + U0 * sr, U0 * cr - L0 * sr;
	}
}

// the saber at the hip: the saber's own pickup mesh, frame N (MODELDEF.hip; both sabers use the same block)
class UBQS_HipSaber : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		RenderStyle "Translucent"; Alpha 0.85;
		Radius 1; Height 1;
	}
	States { Spawn: UBSP N -1; Stop; }
}
