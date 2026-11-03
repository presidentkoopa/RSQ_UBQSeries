// ============================================================================
// RSQGD_Service -- RSQ Glow In The Dark, for other mods, found by name (nothing links):
//   let it = ServiceIterator.Find("RSQGD_Service"); Service s = it ? it.Next() : null;
//   if (s && s.GetClassName() == 'RSQGD_Service') ... s.GetInt("enabled") ...
// (ServiceIterator.Find matches on a PART of the name, so check the class name of what comes back.)
// -1 means "no answer" (the handler is not running).
//
//   version        1 (this skeleton); later versions add requests, never change these
//   enabled        1 when the mod is on (rsqgd_enabled), else 0
//   planes         1 when floor and ceiling glow is on
//   liquids        1 when glowing flats (the owner's list) glow
//   liquid         intArg = sector index: 1 if its floor or ceiling is in the owner's Glow list, else 0
//                  (no sector given, intArg < 0: how many sectors on this map have one)
//   darkdoomz      1 when DarkDoomZ is loaded (found by its handler's name), else 0
//
// Events from other mods (miniboss arrived, level up, ...) will come in as requests here; none are acted on
// in this version. Play, ui and data scope all answer the same.
// ============================================================================

class RSQGD_Service : Service
{
	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQGD_Handler(EventHandler.Find("RSQGD_Handler"));
		if (!h) return -1;
		if (request ~== "version") return 1;
		if (request ~== "enabled") return RSQGD_Handler.B("rsqgd_enabled", true) ? 1 : 0;
		if (request ~== "planes") return RSQGD_Handler.B("rsqgd_planes", true) ? 1 : 0;
		if (request ~== "liquids") return RSQGD_Handler.B("rsqgd_liquids", true) ? 1 : 0;
		if (request ~== "liquid")
		{
			if (intArg < 0) return h.CountLiquidSectors();
			if (intArg >= h.liq0.Size()) return 0;
			return (h.liq0[intArg] || h.liq1[intArg]) ? 1 : 0;
		}
		if (request ~== "darkdoomz") return h.darkDoomZ ? 1 : 0;
		return -1;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}

	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}
}
