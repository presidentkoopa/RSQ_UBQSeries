// The ShieldSaw's gauge (rsq_hud_shield; drawn by ca.ancilla.bonsai/HUD.zsc DrawShield).
// THE SHIELD GAUGE'S PLACE, for a HUD that has to make room (RSQ Score moves its line below it while the
// gauge is on), asked by name from ui code:
//   GetIntUI("shield.gauge.top") / ("shield.gauge.h")   permille of the screen's height; -1 while the
//   gauge is off (rsq_hud_shield) for this machine's player
//   GetIntUI("shield.gauge.drop")   how far below the hand gauges' top the shield gauge ends (its drop
//   under their bars plus its height): what a display under it moves down by
class RSQ_HudService : Service
{
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request == "shield.gauge.top" || request == "shield.gauge.h" || request == "shield.gauge.drop")) return -1;
		let cv = CVar.GetCVar("rsq_hud_shield", players[consoleplayer]);
		if (!cv || !cv.GetBool()) return -1;
		double top, h;
		[top, h] = TFLV_HUD.ShieldBand();
		if (request == "shield.gauge.drop")
		{
			let ty = CVar.GetCVar("bonsai_vr_hud_main_y", players[consoleplayer]);
			double sc = TFLV_Settings.GetDouble("bonsai_hud_size");
			if (sc > 1) sc = sc / 1080;
			double row = (ty && ty.GetFloat() >= 0 && ty.GetFloat() <= 1) ? (1 - sc) * ty.GetFloat() : 0.02;
			return int(1000 * max(0.0, top + h - row));
		}
		return int(1000 * (request == "shield.gauge.top" ? top : h));
	}
}
