// RSQ Whip -- SHOW WHIP WITHOUT THE RIG (owner 11-04: "Give them a spot without the Rig"). Rig only, not headset-confirmed.
// With Show Whip on (rsqwp_show, each player's own) and RSQ Tactical Rig NOT loaded (no RSQTR_RigService), the whip, while
// you own it and it is in neither hand (nor being raised), hangs coiled at the main hand's hip exactly where, and as, the
// Rig hangs it in its whip holster. With the Rig loaded this draws nothing: the Rig draws it (rig.zs DrawStowed reads
// rsqwp_show).
// THE RIG'S NUMBERS, copied (TacticalRig rig.zs RSQTR_Region place 11 and DrawStowed; body.zs At(), NeckShift()):
//   0.06 m back, 0.30 m out toward the MAIN hand (a little behind and outside the saber spot, 0.02 / 0.21), 0.84 m under
//   the eyes, in the body's frame -- no rig torso here, so the player's yaw -- hung from player.viewz with the Rig's neck
//   shift (neck 0.10 m behind and 0.10 m under the eyes); the coil flat against the hip, facing out (angle = the yaw,
//   pitch 0), leaned 8 degrees out at the bottom (roll); a left-handed control scheme puts it on the left hip, the roll
//   mirrored; RSQWP_Stowed's MODELDEF sizes and centres the mesh (scale 1, the Rig's Stored Gun Size default).
class RSQWP_HipShow : EventHandler
{
	const SPOT_F = -0.06;
	const SPOT_L = 0.30;
	const SPOT_U = -0.84;
	const ROLL = 8;
	const NECK_BACK = 0.10;
	const NECK_DOWN = 0.10;

	Actor shown[MAXPLAYERS];

	override void WorldTick()
	{
		bool rig = ServiceIterator.Find("RSQTR_RigService").Next() != null;
		let cs = CVar.FindCVar("vr_control_scheme");
		bool lh = cs && cs.GetInt() >= 10;
		let uc = CVar.FindCVar("vr_vunits_per_meter");
		double u = uc && uc.GetFloat() > 0 ? uc.GetFloat() : 34.0;
		double ps = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			PlayerPawn pmo = (!rig && playeringame[n] && players[n].mo) ? PlayerPawn(players[n].mo) : null;
			bool want = pmo && pmo.health > 0 && players[n].playerstate == PST_LIVE;
			if (want) { let c = CVar.GetCVar("rsqwp_show", players[n]); want = !c || c.GetBool(); }
			Weapon w = want ? Weapon(pmo.FindInventory("RSQWP_WhipWeapon")) : null;
			let p = players[n];
			want = w && p.ReadyWeapon != w && p.OffhandWeapon != w && p.PendingWeapon != w;
			if (!want) { if (shown[n]) shown[n].bINVISIBLE = true; continue; }
			double yaw = pmo.angle;
			double side = lh ? SPOT_L : -SPOT_L;           // toward the main hand: the body's right for a right-hander
			double c = cos(yaw), s = sin(yaw);
			double pt = clamp(pmo.pitch, -89, 89);
			double nf = (NECK_BACK * (1 - cos(pt)) - NECK_DOWN * sin(pt)) * u;
			Vector3 at = (pmo.pos.x, pmo.pos.y, p.viewz) + (c * nf, s * nf, 0)
				+ ((c * SPOT_F - s * side) * u, (s * SPOT_F + c * side) * u, SPOT_U * u / ps);
			if (!shown[n]) shown[n] = Actor.Spawn("RSQWP_Stowed", at, NO_REPLACE);
			let a = shown[n];
			if (!a) continue;
			a.SetOrigin(at, true);
			a.angle = yaw;
			a.pitch = 0;
			a.roll = lh ? -ROLL : ROLL;                   // the Rig's -side * STOW_WHIP_ROLL (side -1 on the right hip)
			a.bINVISIBLE = false;
		}
	}
}
