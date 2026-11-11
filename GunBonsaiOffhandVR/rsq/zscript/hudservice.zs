// THE HAND GAUGES' PLACE, for a HUD placed under them (owner 11-11: RSQ Score's line, centred just below the
// two gauges), asked by name from ui code:
//   GetIntUI("gauges.bottom")   permille of the screen's height: the bottom of the lowest hand gauge drawn this
//   frame (Dual HUD: either hand's; Dual HUD off: the single gauge). -1 while no gauge is drawn (no weapon, the
//   automap, screenblocks 12, a menu open). The test and anchors are the ones the gauges are drawn with
//   (TFLV_EventHandler.GaugesBottom, ca.ancilla.bonsai/EventHandler.zsc).
// (Until 11-11 this service reported the ShieldSaw gauge's band, "shield.gauge.*"; that gauge is removed.)
class RSQ_HudService : Service
{
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "gauges.bottom") return -1;
		let eh = TFLV_EventHandler(StaticEventHandler.Find("TFLV_EventHandler"));
		if (!eh) return -1;
		double b = eh.GaugesBottom(consoleplayer);
		return b < 0 ? -1 : int(ceil(1000 * b));
	}
}
