// ============================================================================
// RSQGD_Service -- RSQ Glow In The Dark, for other mods, found by name (nothing links):
//   let it = ServiceIterator.Find("RSQGD_Service"); Service s = it ? it.Next() : null;
//   if (s && s.GetClassName() == 'RSQGD_Service') ... s.GetInt("enabled") ...
// (ServiceIterator.Find matches on a PART of the name, so check the class name of what comes back.)
// -1 means "no answer" (the handler is not running).
//
// READS (play, ui and data scope)
//   version        2
//   enabled        1 when the mod is on (rsqgd_enabled), else 0
//   planes         1 when floor and ceiling glow is on
//   liquids        1 when liquids glow
//   liquid         intArg = sector index: 1 if its floor or ceiling is a liquid, else 0 (intArg < 0: how many)
//   darkdoomz      1 when DarkDoomZ is loaded (found by its handler's name), else 0
//   profile        the profile showing now (its row; Random Profile answers the row it drew)
//   GetString("profile") its name
//
// EVENTS (play scope only, GetInt; return 1 when taken). For another mod's big moments:
//   event.wave     a wave rolls out from objectArg (an Actor); intArg = colour 0xRRGGBB (0 = the wave colour)
//   event.flare    a flare on objectArg's sector, or intArg = a sector index; doubleArg = colour (0 = white)
//   event.tint     the whole map's glow leans to intArg's colour for doubleArg seconds (0 = 2 s)
//   event.reroll   new colours now (as Re-roll would)
// ============================================================================

class RSQGD_Service : Service
{
	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQGD_Handler(EventHandler.Find("RSQGD_Handler"));
		if (!h) return -1;
		if (request ~== "version") return 2;
		if (request ~== "enabled") return RSQGD_Handler.B("rsqgd_enabled", true) ? 1 : 0;
		if (request ~== "planes") return RSQGD_Handler.B("rsqgd_planes", true) ? 1 : 0;
		if (request ~== "liquids") return RSQGD_Handler.B("rsqgd_liquids", true) ? 1 : 0;
		if (request ~== "liquid") return intArg < 0 ? h.CountLiquidSectors() : (h.IsLiquid(intArg) ? 1 : 0);
		if (request ~== "darkdoomz") return h.darkDoomZ ? 1 : 0;
		if (request ~== "profile") return h.activeProfile;
		if (request ~== "ddz.original") return h.ddzModeHeld ? h.ddzModeSaved : -1;   // the player's own DarkDoomZ mode while "event.dark" holds it
		return -1;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQGD_Handler(EventHandler.Find("RSQGD_Handler"));
		if (h && h.ready && request.Left(6) ~== "event.")
		{
			let a = Actor(objectArg);
			if (request ~== "event.wave")
			{
				if (!a) return 0;
				h.StartWave(a.pos.xy, intArg > 0 ? intArg & 0xFFFFFF : RSQGD_Handler.I("rsqgd_wave_color", 0xFFC020) & 0xFFFFFF);
				return 1;
			}
			if (request ~== "event.flare")
			{
				int i = a && a.CurSector ? a.CurSector.Index() : intArg;
				h.Flare(i, doubleArg > 0 ? int(doubleArg) & 0xFFFFFF : 0xC0C0C0);
				return 1;
			}
			if (request ~== "event.tint")
			{
				h.tintColour = intArg & 0xFFFFFF;
				h.tintUntil = Level.maptime + int((doubleArg > 0 ? doubleArg : 2.0) * 35);
				h.BuildNear();
				return 1;
			}
			if (request ~== "event.reroll") { h.Reroll(); return 1; }
			if (request ~== "event.dark")
			{
				h.darkUntil = max(h.darkUntil, Level.maptime + int((doubleArg > 0 ? doubleArg : 4.0) * 35));
				return 1;
			}
			return 0;
		}
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}

	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg);
	}

	override String GetStringData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQGD_Handler(EventHandler.Find("RSQGD_Handler"));
		if (!h || !(request ~== "profile")) return "";
		return RSQGD_Profiles.NameOf(h.activeProfile);
	}
	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetStringData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override String GetStringUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetStringData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
}
