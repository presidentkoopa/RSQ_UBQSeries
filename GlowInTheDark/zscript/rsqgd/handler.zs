// RSQ Glow In The Dark -- the port of the owner's Glow In The Dark 1.1 (October 2021) to ZScript.
//
// WHAT 1.1 DID, MEASURED FROM ITS FILES (original/ keeps them):
//  * acs/colorfulmaps.acs (from NightFright's ColorfulMaps "Lite", after Solid_Head's ColorfulMaps) walked
//    sector TAGS 0..99998 and called ACS SetSectorGlow(tag, ceiling/floor, r, g, b, 64) for each: a random
//    colour per channel in 25..255 (or the menu's fixed colour with "Override randomization"), height 64.
//    SetSectorGlow writes planes[pos].GlowColor/GlowHeight of every sector with that tag (p_acs.cpp
//    ACSF_SetSectorGlow). Tag 0 is every UNTAGGED sector (FSectorTagIterator::Next, p_tags.cpp), so all of
//    them shared one ceiling colour and one floor colour, and each tag group got its own pair. The engine
//    draws a plane's glow on the WALLS next to that plane (sector_t::GetWallGlow, p_sectors.cpp), so this
//    is the wall glow: a band of colour up from the floor and down from the ceiling.
//    Its throttle `if (CURRENT_SECTOR % MAX_SECTORS_PER_TIC) delay(1)` waits a tic on every tag but each
//    2500th, so tag N got its colour N tics into the map. Here every group is coloured on the first tic.
//  * gldefs.bm (built on Finder153's GlowingLiquids, extended by the owner) is a GLDEFS Glow block: every
//    listed flat glows in its own average colour (FGameTexture::GetGlowColor). It ships unchanged as
//    GLDEFS.txt. The engine only uses that glow when a plane's GlowColor is 0 (GetWallGlow), and 1.1's
//    script wrote a colour on every untagged sector, so in 1.1 the plane colour painted over most liquids.
//    "Liquids Keep Their Own Colour" (on) gives the liquid list back its own colour; off is 1.1 exactly.
//  * The entries in the list that are sprites (BD splashes) or wall textures are read by the engine's GLDEFS
//    parser but the renderer only asks floors and ceilings for glow, so they change nothing on screen. They
//    stay in the list (the owner's work, and a texture used as a flat does glow).
//
// HOW THIS WORKS (Quest first): ONE pass over the sectors when the map loads -- the original glow of each
// plane is kept, each plane's flat is classed liquid or not, and the colours are written. After that:
// once a second, the settings are compared (a change re-writes every sector with the SAME colours, no
// re-roll), and the flats of TAGGED sectors only are re-checked (a lift lowering onto nukage), because only
// tagged sectors change flats in Doom. Nothing runs per tic.
//
// Netplay: everything here is play scope and reads server cvars; the colours come from a named RNG on the
// first tic, so every machine draws the same map.

class RSQGD_Handler : EventHandler
{
	const UNSET = -2;                      // "no roll yet" in the group tables

	// per sector (index = sector index)
	Array<int> origCol0, origCol1;         // the plane glow colour the map had (0 = the flat's own, ~0 = off)
	Array<double> origH0, origH1;
	Array<bool> liq0, liq1;                // plane 0 floor, 1 ceiling: the flat is in the owner's Glow list
	Array<int> group;                      // the 1.1 group: the sector's highest tag (1.1 coloured tags in
	                                       // rising order, so the last write -- the highest -- won), 0 untagged
	// the 1.1 random rolls, one ceiling and one floor colour per group
	Array<int> rollTag, rollCeil, rollFloor;
	// tagged sectors, watched for a flat change
	Array<int> watch, watchF, watchC;      // sector index, its floor and ceiling texture last seen

	String sig;                            // the settings these colours were written with
	bool ready;
	bool darkDoomZ;                        // DarkDoomZ is loaded (found by name; see README "Plays well with")

	transient Map<String, bool> liquidSet;

	// ---- settings --------------------------------------------------------------------------------------
	clearscope static bool B(String n, bool def) { let c = CVar.FindCVar(n); return c ? c.GetBool() : def; }
	clearscope static int I(String n, int def) { let c = CVar.FindCVar(n); return c ? c.GetInt() : def; }

	String Settings()
	{
		return String.Format("%d %d %d %d %d %d %d %d %d %d %d %d", B("rsqgd_planes", true), B("rsqgd_liquids", true),
			B("rsqgd_liquid_own", true), B("rsqgd_fixed", false), I("rsqgd_height", 64),
			I("rsqgd_ceil_r", 135), I("rsqgd_ceil_g", 135), I("rsqgd_ceil_b", 135),
			I("rsqgd_floor_r", 135), I("rsqgd_floor_g", 135), I("rsqgd_floor_b", 135), B("rsqgd_enabled", true));
	}

	// ---- the owner's list ------------------------------------------------------------------------------
	bool IsLiquidName(String n)
	{
		if (liquidSet.CountUsed() == 0)
		{
			for (int i = 0; i < RSQGD_LiquidNames.NAMES.Size(); i++) liquidSet.Insert(RSQGD_LiquidNames.NAMES[i], true);
		}
		n = n.MakeUpper();
		return liquidSet.CheckKey(n);
	}

	bool IsLiquidTex(TextureID t)
	{
		if (!t.IsValid()) return false;
		return IsLiquidName(TexMan.GetName(t));
	}

	// ---- map start -------------------------------------------------------------------------------------
	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;          // the save carries the planes and these tables
		int n = Level.Sectors.Size();
		origCol0.Clear(); origCol1.Clear(); origH0.Clear(); origH1.Clear(); liq0.Clear(); liq1.Clear(); group.Clear();
		rollTag.Clear(); rollCeil.Clear(); rollFloor.Clear(); watch.Clear(); watchF.Clear(); watchC.Clear();
		for (int i = 0; i < n; i++)
		{
			Sector s = Level.Sectors[i];
			origCol0.Push(int(s.GetGlowColor(Sector.floor)));
			origCol1.Push(int(s.GetGlowColor(Sector.ceiling)));
			origH0.Push(s.GetGlowHeight(Sector.floor));
			origH1.Push(s.GetGlowHeight(Sector.ceiling));
			liq0.Push(IsLiquidTex(s.GetTexture(Sector.floor)));
			liq1.Push(IsLiquidTex(s.GetTexture(Sector.ceiling)));
			int g = 0;
			int nt = s.CountTags();
			for (int t = 0; t < nt; t++) g = max(g, s.GetTag(t));
			group.Push(g);
			if (nt > 0)
			{
				watch.Push(i);
				watchF.Push(int(s.GetTexture(Sector.floor)));
				watchC.Push(int(s.GetTexture(Sector.ceiling)));
			}
		}
		// The rolls: 1.1 drew ceiling r,g,b then floor r,g,b per tag in rising order. Groups are rolled in
		// rising order here too, all on the first tic.
		Array<int> tags;
		for (int i = 0; i < n; i++) if (tags.Find(group[i]) == tags.Size()) tags.Push(group[i]);
		for (int a = 1; a < tags.Size(); a++)
		{
			int v = tags[a], b = a - 1;
			while (b >= 0 && tags[b] > v) { tags[b + 1] = tags[b]; b--; }
			tags[b + 1] = v;
		}
		for (int i = 0; i < tags.Size(); i++)
		{
			rollTag.Push(tags[i]);
			rollCeil.Push(RollColor());
			rollFloor.Push(RollColor());
		}
		String ddz = "DarkDoomZ_Handler";     // a variable: a literal would be resolved (and fail) at compile time
		class<Object> cls = ddz;
		darkDoomZ = cls != null;
		ready = true;
		ApplyAll();
		if (I("rsqgd_debug", 0) > 0)
		{
			int nl = 0;
			for (int i = 0; i < n; i++) if (liq0[i] || liq1[i]) nl++;
			Console.Printf("[RSQGD] map %s: %d sectors, %d groups, %d with a glowing flat, %d tagged watched, DarkDoomZ %s",
				Level.MapName, n, tags.Size(), nl, watch.Size(), darkDoomZ ? "found" : "not loaded");
		}
	}

	static int RollColor()
	{
		return (random[RSQGD](25, 255) << 16) | (random[RSQGD](25, 255) << 8) | random[RSQGD](25, 255);
	}

	int RollFor(int grp, bool ceil)
	{
		for (int i = 0; i < rollTag.Size(); i++) if (rollTag[i] == grp) return ceil ? rollCeil[i] : rollFloor[i];
		return 0x878787;
	}

	// ---- writing ---------------------------------------------------------------------------------------
	// One plane of one sector, from the settings:
	//   a listed flat, liquids on, "keep own colour" on    -> 0: the engine draws the flat's own colour
	//   floor/ceiling glow on                               -> the group's colour (fixed or rolled), height
	//   a listed flat, liquids on                           -> what the map had (0 = the flat's own colour)
	//   a listed flat, liquids off, the map had 0           -> ~0: switched off
	//   otherwise                                           -> what the map had
	void ApplyPlane(int i, int pos, bool on, bool planes, bool liquids, bool own, bool fixed, int height,
		int fixedCeil, int fixedFloor)
	{
		Sector s = Level.Sectors[i];
		bool ceil = pos == Sector.ceiling;
		bool liq = ceil ? liq1[i] : liq0[i];
		int orig = ceil ? origCol1[i] : origCol0[i];
		double oh = ceil ? origH1[i] : origH0[i];
		int col = orig;
		double h = oh;
		if (!on) { }
		else if (liq && liquids && own) { col = 0; }
		else if (planes)
		{
			col = fixed ? (ceil ? fixedCeil : fixedFloor) : RollFor(group[i], ceil);
			if (col == 0) col = 0x010101;   // 0 would hand the plane to its flat; black stays black
			h = height;
		}
		else if (liq && !liquids && orig == 0) { col = -1; }
		s.SetGlowColor(pos, col);
		s.SetGlowHeight(pos, h);
	}

	void ApplySector(int i)
	{
		bool on = B("rsqgd_enabled", true);
		bool planes = B("rsqgd_planes", true), liquids = B("rsqgd_liquids", true), own = B("rsqgd_liquid_own", true);
		bool fixed = B("rsqgd_fixed", false);
		int height = I("rsqgd_height", 64);
		int fc = (clamp(I("rsqgd_ceil_r", 135), 0, 255) << 16) | (clamp(I("rsqgd_ceil_g", 135), 0, 255) << 8) | clamp(I("rsqgd_ceil_b", 135), 0, 255);
		int ff = (clamp(I("rsqgd_floor_r", 135), 0, 255) << 16) | (clamp(I("rsqgd_floor_g", 135), 0, 255) << 8) | clamp(I("rsqgd_floor_b", 135), 0, 255);
		ApplyPlane(i, Sector.floor, on, planes, liquids, own, fixed, height, fc, ff);
		ApplyPlane(i, Sector.ceiling, on, planes, liquids, own, fixed, height, fc, ff);
	}

	void ApplyAll()
	{
		bool on = B("rsqgd_enabled", true);
		bool planes = B("rsqgd_planes", true), liquids = B("rsqgd_liquids", true), own = B("rsqgd_liquid_own", true);
		bool fixed = B("rsqgd_fixed", false);
		int height = I("rsqgd_height", 64);
		int fc = (clamp(I("rsqgd_ceil_r", 135), 0, 255) << 16) | (clamp(I("rsqgd_ceil_g", 135), 0, 255) << 8) | clamp(I("rsqgd_ceil_b", 135), 0, 255);
		int ff = (clamp(I("rsqgd_floor_r", 135), 0, 255) << 16) | (clamp(I("rsqgd_floor_g", 135), 0, 255) << 8) | clamp(I("rsqgd_floor_b", 135), 0, 255);
		int n = min(Level.Sectors.Size(), group.Size());
		for (int i = 0; i < n; i++)
		{
			ApplyPlane(i, Sector.floor, on, planes, liquids, own, fixed, height, fc, ff);
			ApplyPlane(i, Sector.ceiling, on, planes, liquids, own, fixed, height, fc, ff);
		}
		sig = Settings();
	}

	// ---- once a second ---------------------------------------------------------------------------------
	override void WorldTick()
	{
		if (!ready || (Level.maptime % 35) != 17) return;
		if (Settings() != sig) ApplyAll();
		for (int k = 0; k < watch.Size(); k++)
		{
			Sector s = Level.Sectors[watch[k]];
			int f = int(s.GetTexture(Sector.floor)), c = int(s.GetTexture(Sector.ceiling));
			if (f == watchF[k] && c == watchC[k]) continue;
			int i = watch[k];
			watchF[k] = f; watchC[k] = c;
			liq0[i] = IsLiquidTex(s.GetTexture(Sector.floor));
			liq1[i] = IsLiquidTex(s.GetTexture(Sector.ceiling));
			ApplySector(i);
		}
	}

	// ---- for the service -------------------------------------------------------------------------------
	clearscope int CountLiquidSectors() const
	{
		int n = 0;
		for (int i = 0; i < liq0.Size(); i++) if (liq0[i] || liq1[i]) n++;
		return n;
	}
}
