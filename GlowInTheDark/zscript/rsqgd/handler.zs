// RSQ Glow In The Dark -- the core: the map-start pass, the look (profile + colour seed), and the writer.
//
// WHERE IT COMES FROM. The owner's Glow In The Dark 1.1 (October 2021, original/ keeps it):
//  * acs/colorfulmaps.acs (from NightFright's ColorfulMaps "Lite", after Solid_Head's ColorfulMaps) walked sector
//    TAGS 0..99998 calling ACS SetSectorGlow(tag, ceiling/floor, r, g, b, 64): each channel random 25..255 (or the
//    menu's fixed colour), height 64. SetSectorGlow writes planes[pos].GlowColor/GlowHeight of every sector with
//    that tag (p_acs.cpp ACSF_SetSectorGlow); tag 0 is every UNTAGGED sector (FSectorTagIterator::Next), so all of
//    them shared one colour pair and each tag group got its own. The engine draws a plane's glow on the WALLS next
//    to it (sector_t::GetWallGlow): a band up from the floor, a band down from the ceiling. Its throttle waited a
//    tic on every tag but each 2500th, so tag N got its colour N tics in; here every group is coloured at once.
//  * gldefs.bm (after Finder153's GlowingLiquids, extended by the owner) is a GLDEFS Glow block, shipped unchanged
//    as GLDEFS.txt: every listed flat glows in its own average colour, used by the engine only when the plane's
//    GlowColor is 0 (GetWallGlow). 1.1 gave every untagged room a colour, so its liquids wore the room's colour.
//    Profiles now decide ("Liquids keep their own colour"); Liquid Colour "Like 1.1" is 1.1 exactly.
//
// WHAT THE ENGINE ALLOWS (QuestZDoom 17.3, read from its source): per plane a glow colour and height (walls only:
// a floor cannot glow on its own face, that needs UZDXREMA), per sidedef tier an additive colour (doors, switches,
// exits), sector light levels, dynamic lights. Everything here is the first two; dynamic lights are capped extras.
//
// COST (Quest first). One pass over the sectors at map start (classify, keep the map's own glow, pick colours).
// After that nothing walks the whole map per tic: a still look writes nothing; an animated look or a reaction
// re-writes the sectors near the players every 2 tics and a rolling slice of the rest (Budget per tic); the
// liquids (a short list) every 3 tics; flares and the wave touch only the sectors they cover. A plane is written
// only when its colour or height changed.

class RSQGD_Handler : EventHandler
{
	const NOWRITE = 0x7FFFFFF0;            // "never written" in the last-written tables
	const NEAR_R = 1280.0;                 // the rooms re-written first while something moves
	const FLARE_TICS = 18;
	const WAVE_SPEED = 30.0;               // map units per tic (~1050/s)
	const WAVE_W = 224.0;                  // half width of the level-up wave's band
	const BUCKET = 64.0;

	// ---- per sector (index = sector index) ----
	Array<int> origCol0, origCol1;         // the glow the map had (0 = the flat's own, -1 = off)
	Array<double> origH0, origH1;
	Array<int> liq0, liq1;                 // RSQGD_Liquid codes: 0 none, 1..N class, +100 name-heuristic only, -1 listed
	Array<int> group;                      // the 1.1 group: highest tag, 0 untagged
	Array<int> base0, base1;               // the look's colour for each plane, -1 = no glow on it
	Array<int> hsh;                        // per-sector hash (phases)
	Array<double> cdist;                   // distance from the map's middle (ripple)
	Array<int> last0, last1, lastH0, lastH1;
	Array<int> flareUntil, flareCol;
	Array<int> flares;                     // sectors with a live flare
	Array<int> liquids;                    // sectors with a liquid plane (the living list)
	Array<int> special;                    // 1 damaging floor, 2 secret (not yet found)
	Array<int> specials;
	Array<int> watch, watchF, watchC;      // tagged sectors, for flat changes
	Array<int> nearSet;
	int nearCursor;
	Array<int> darkDelta;                  // light taken away by a big moment (no DarkDoomZ), given back exactly

	// ---- the wave ----
	Array<double> wdist;
	Array<int> wbStart, wbItems;
	bool waveOn;
	int waveT0, waveCol;
	double waveMax, waveR, waveRPrev;

	// ---- the look ----
	RSQGD_Look look;
	int activeProfile;
	int seed;
	String sig;
	int cursor;
	bool dirty;
	bool ready;
	bool darkDoomZ;
	double mapCx, mapCy;
	int lastRollTic;
	int deathsSeen;
	int lightSig;
	transient bool live;                   // false straight after a savegame load

	// ---- reactions ----
	double mbMix;  int mbColour, mbLive;   // miniboss tint
	int tintUntil, tintColour;             // another mod's tint (service "event.tint")
	double smMix;                          // slow motion
	double combo; int comboN, comboTic; Array<int> lastSerial;
	Array<String> gbWeap; Array<int> gbLvl; // per player*2 + hand
	bool darkened; int ddzSaved, restoreAt;
	int keysMask;
	int testMb, testSm;

	// ---- settings cached once a second (a cvar lookup per plane would cost more than the glow) ----
	bool cOn, cPlanes, cLiquids, cLiving, cHazards, cSecrets, cThings, cDark, cSplash;
	int cOwn, cHeight, cBudget;

	void CacheSettings()
	{
		cOn = B("rsqgd_enabled", true); cPlanes = B("rsqgd_planes", true); cLiquids = B("rsqgd_liquids", true);
		cLiving = B("rsqgd_living", true); cHazards = B("rsqgd_hazards", true); cSecrets = B("rsqgd_secrets", false);
		cThings = B("rsqgd_things", true); cDark = B("rsqgd_darkboost", true); cSplash = B("rsqgd_splash", true);
		cOwn = I("rsqgd_liquid_own", 1); cHeight = I("rsqgd_height", 64); cBudget = max(16, I("rsqgd_budget", 128));
	}

	// ---- counters (debug line) ----
	int writes, writesTic;
	double msTic, msPeak;

	// ---- settings --------------------------------------------------------------------------------------
	clearscope static bool B(String n, bool def) { let c = CVar.FindCVar(n); return c ? c.GetBool() : def; }
	clearscope static int I(String n, int def) { let c = CVar.FindCVar(n); return c ? c.GetInt() : def; }
	clearscope static double F(String n, double def) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : def; }

	// every setting that changes the colours (re-written within a second when one moves)
	String Settings()
	{
		static const String NAMES[] = {
			"rsqgd_enabled", "rsqgd_planes", "rsqgd_liquids", "rsqgd_liquid_own", "rsqgd_living", "rsqgd_height",
			"rsqgd_profile", "rsqgd_groupby", "rsqgd_darkboost", "rsqgd_blend", "rsqgd_strength",
			"rsqgd_ceil_r", "rsqgd_ceil_g", "rsqgd_ceil_b", "rsqgd_floor_r", "rsqgd_floor_g", "rsqgd_floor_b",
			"rsqgd_c_floor_mode", "rsqgd_c_ceil_mode", "rsqgd_c_palette", "rsqgd_c_jitter", "rsqgd_c_strength",
			"rsqgd_c_floor_gain", "rsqgd_c_ceil_gain", "rsqgd_c_shape", "rsqgd_c_rate", "rsqgd_c_depth",
			"rsqgd_c_liquid", "rsqgd_hazards", "rsqgd_secrets", "rsqgd_things", "rsqgd_things_doors",
			"rsqgd_things_strength", "rsqgd_reroll", "rsqgd_seed", "rsqgd_items" };
		String s = "";
		for (int i = 0; i < NAMES.Size(); i++)
		{
			let c = CVar.FindCVar(NAMES[i]);
			s = s .. (c ? c.GetString() : "?") .. " ";
		}
		return s;
	}

	// ---- colour helpers --------------------------------------------------------------------------------
	clearscope static int Pack(int r, int g, int b) { return (clamp(r, 0, 255) << 16) | (clamp(g, 0, 255) << 8) | clamp(b, 0, 255); }
	clearscope static int Scale(int c, double k)
	{
		return Pack(int(((c >> 16) & 255) * k + 0.5), int(((c >> 8) & 255) * k + 0.5), int((c & 255) * k + 0.5));
	}
	clearscope static int Mix(int a, int b, double t)
	{
		t = clamp(t, 0.0, 1.0);
		int ar = (a >> 16) & 255, ag = (a >> 8) & 255, ab = a & 255;
		return Pack(int(ar + (((b >> 16) & 255) - ar) * t + 0.5), int(ag + (((b >> 8) & 255) - ag) * t + 0.5), int(ab + ((b & 255) - ab) * t + 0.5));
	}
	clearscope static int Add(int a, int b)
	{
		return Pack(((a >> 16) & 255) + ((b >> 16) & 255), ((a >> 8) & 255) + ((b >> 8) & 255), (a & 255) + (b & 255));
	}
	// grey of the same brightness, leaning cold: slow motion's drained look
	clearscope static int Drain(int c)
	{
		int y = (((c >> 16) & 255) * 30 + ((c >> 8) & 255) * 59 + (c & 255) * 11) / 100;
		return Pack(y * 80 / 100, y * 92 / 100, y * 115 / 100 + 10);
	}
	clearscope static int RotHue(int c, double deg)
	{
		double r = ((c >> 16) & 255) / 255., g = ((c >> 8) & 255) / 255., b = (c & 255) / 255.;
		double mx = max(r, max(g, b)), mn = min(r, min(g, b)), d = mx - mn, h = 0;
		if (d > 0)
		{
			if (mx == r) h = 60 * ((g - b) / d);
			else if (mx == g) h = 60 * ((b - r) / d + 2);
			else h = 60 * ((r - g) / d + 4);
		}
		double s = mx > 0 ? d / mx : 0, v = mx;
		h += deg;
		h -= 360 * floor(h / 360);
		double hp = h / 60;
		int seg = int(hp) % 6;
		double f = hp - floor(hp), p = v * (1 - s), q = v * (1 - s * f), t = v * (1 - s * (1 - f));
		if (seg == 0) { r = v; g = t; b = p; }
		else if (seg == 1) { r = q; g = v; b = p; }
		else if (seg == 2) { r = p; g = v; b = t; }
		else if (seg == 3) { r = p; g = q; b = v; }
		else if (seg == 4) { r = t; g = p; b = v; }
		else { r = v; g = p; b = q; }
		return Pack(int(r * 255 + 0.5), int(g * 255 + 0.5), int(b * 255 + 0.5));
	}
	clearscope static int Hash(int x)
	{
		x ^= (x >>> 16); x *= 0x7feb352d; x ^= (x >>> 15); x *= 0x846ca68b; x ^= (x >>> 16);
		return x;
	}

	// the pulse shapes, 0..1 (all slow; nothing flashes)
	clearscope static double Wave01(int shape, double x)
	{
		if (shape == 2)
		{
			double f = x - floor(x);
			double a = (f / 0.07), b = ((f - 0.28) / 0.07);
			return clamp(exp(-a * a) + 0.6 * exp(-b * b), 0.0, 1.0);
		}
		if (shape == 3)
		{
			double v = 0.5 * sin(x * 360) + 0.3 * sin(x * 360 * 2.7 + 50) + 0.2 * sin(x * 360 * 5.3 + 120);
			return 0.5 + 0.5 * v;
		}
		return 0.5 + 0.5 * sin(x * 360);
	}

	// ---- map start -------------------------------------------------------------------------------------
	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		int n = Level.Sectors.Size();
		origCol0.Clear(); origCol1.Clear(); origH0.Clear(); origH1.Clear(); liq0.Clear(); liq1.Clear(); group.Clear();
		base0.Clear(); base1.Clear(); hsh.Clear(); cdist.Clear(); last0.Clear(); last1.Clear(); lastH0.Clear(); lastH1.Clear();
		flareUntil.Clear(); flareCol.Clear(); flares.Clear(); liquids.Clear(); special.Clear(); specials.Clear();
		watch.Clear(); watchF.Clear(); watchC.Clear(); darkDelta.Clear();

		double x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
		for (int i = 0; i < Level.Vertexes.Size(); i++)
		{
			Vector2 p = Level.Vertexes[i].p;
			x0 = min(x0, p.x); x1 = max(x1, p.x); y0 = min(y0, p.y); y1 = max(y1, p.y);
		}
		mapCx = (x0 + x1) / 2; mapCy = (y0 + y1) / 2;

		for (int i = 0; i < n; i++)
		{
			Sector s = Level.Sectors[i];
			origCol0.Push(int(s.GetGlowColor(Sector.floor)));
			origCol1.Push(int(s.GetGlowColor(Sector.ceiling)));
			origH0.Push(s.GetGlowHeight(Sector.floor));
			origH1.Push(s.GetGlowHeight(Sector.ceiling));
			liq0.Push(RSQGD_Liquid.Classify(s.GetTexture(Sector.floor), s, Sector.floor));
			liq1.Push(RSQGD_Liquid.Classify(s.GetTexture(Sector.ceiling), s, Sector.ceiling));
			if (liq0[i] != 0 || liq1[i] != 0) liquids.Push(i);
			int g = 0, nt = s.CountTags();
			for (int t = 0; t < nt; t++) g = max(g, s.GetTag(t));
			group.Push(g);
			if (nt > 0)
			{
				watch.Push(i);
				watchF.Push(int(s.GetTexture(Sector.floor)));
				watchC.Push(int(s.GetTexture(Sector.ceiling)));
			}
			base0.Push(-1); base1.Push(-1);
			hsh.Push(Hash(i * 7919 + 13));
			cdist.Push((s.centerspot - (mapCx, mapCy)).Length());
			last0.Push(NOWRITE); last1.Push(NOWRITE); lastH0.Push(NOWRITE); lastH1.Push(NOWRITE);
			flareUntil.Push(0); flareCol.Push(0);
			int sp = 0;
			if (s.damageamount > 0 && liq0[i] == 0) sp = 1;
			else if (s.isSecret()) sp = 2;
			else if (TexMan.GetName(s.GetTexture(Sector.floor)).Left(4) ~== "GATE") sp = 3;   // teleporter pads
			special.Push(sp);
			if (sp) specials.Push(i);
			darkDelta.Push(0);
		}

		String ddz = "DarkDoomZ_Handler";      // a variable: a literal would be resolved (and fail) at compile time
		class<Object> cls = ddz;
		darkDoomZ = cls != null;

		// the colour seed (see ChooseSeed) and the look
		let ses = RSQGD_Session(StaticEventHandler.Find("RSQGD_Session"));
		seed = ChooseSeed(ses);
		deathsSeen = ses ? ses.deaths : 0;
		lastRollTic = 0;
		live = true;
		CacheSettings();
		RestoreDarkDoomZ();
		RebuildLook();
		ScanThings();
		SpawnLiquidLights();
		ready = true;
		for (int i = 0; i < n; i++) WriteSector(i);
		sig = Settings();
		lightSig = LightSample();
		if (I("rsqgd_debug", 0) > 0)
		{
			Console.Printf("[RSQGD] map %s: %d sectors, %d liquid, %d hazard/secret, %d lines glowing, profile %s, seed %d, DarkDoomZ %s",
				Level.MapName, n, liquids.Size(), specials.Size(), lnIdx.Size(), look.title, seed, darkDoomZ ? "found" : "not loaded");
		}
	}

	// THE COLOUR SEED. Every random colour is a hash of (seed, room, plane): the same seed gives the same map, so a
	// setting moved re-tints without reshuffling. When it changes follows Re-roll Colours:
	//   0 Never           the seed in rsqgd_seed (Shuffle Now writes a new one there)
	//   1 Every Map       a new seed each map (1.1's way)
	//   2 On Each Death   a new seed after the player died (also across a reload of the map or a save)
	//   3 On Each Level-Up / 4 Every N Minutes   kept across maps (in the session), new on the event
	int ChooseSeed(RSQGD_Session ses)
	{
		int mode = I("rsqgd_reroll", 1);
		if (mode == 0) return I("rsqgd_seed", 1337);
		bool roll = mode == 1 || !ses || ses.seed == 0 || (mode == 2 && ses.deaths != ses.deathsAtRoll);
		if (roll && ses) { ses.seed = random[RSQGDSeed](1, 0x7FFFFFF); ses.deathsAtRoll = ses.deaths; }
		return ses ? ses.seed : random[RSQGDSeed](1, 0x7FFFFFF);
	}

	void Reroll()
	{
		let ses = RSQGD_Session(StaticEventHandler.Find("RSQGD_Session"));
		int s = random[RSQGDSeed](1, 0x7FFFFFF);
		if (ses) { ses.seed = s; ses.deathsAtRoll = ses.deaths; }
		if (I("rsqgd_reroll", 1) == 0) { s = s & 0xFFFF; let c = CVar.FindCVar("rsqgd_seed"); if (c) c.SetInt(s); }
		seed = s;
		lastRollTic = Level.maptime;
		RebuildLook();
		dirty = true;
		cursor = 0;
		sig = Settings();
	}

	// ---- the look: the profile's colours for every plane (a pass over the sectors, only when it changes) ----
	void RebuildLook()
	{
		if (!look) look = new("RSQGD_Look");
		int p = I("rsqgd_profile", 2);
		if (p == 1) p = RSQGD_Profiles.FIRST_NAMED + (Hash(seed ^ 0x51ED) & 0x7FFFFFFF) % (RSQGD_Profiles.Count() - RSQGD_Profiles.FIRST_NAMED);
		activeProfile = p;
		if (p == 0) look.FromCustom(); else look.FromRow(p);
		look.strength *= F("rsqgd_strength", 1.0);
		if (p != 0) look.height = look.height * I("rsqgd_height", 64) / 64.0;
		int gb = I("rsqgd_groupby", 0);
		bool byTag = gb == 1 || (gb == 0 && (p == 2 || p == 0));
		int n = group.Size();
		for (int i = 0; i < n; i++)
		{
			int key = byTag ? group[i] : i + 100000;
			base0[i] = PickColour(look.floorAny, look.floorPal, key, 1);
			base1[i] = PickColour(look.ceilAny, look.ceilPal, key, 2);
		}
		if (B("rsqgd_blend", false)) BlendNeighbours();
	}

	int PickColour(bool any, Array<int> pal, int key, int plane)
	{
		int h = Hash(Hash(key * 31 + plane) ^ seed);
		if (any)
		{
			// 1.1: each channel random(25, 255)
			return Pack(25 + (h & 0xFF) % 231, 25 + ((h >> 8) & 0xFF) % 231, 25 + ((Hash(h) >> 4) & 0xFF) % 231);
		}
		if (pal.Size() == 0) return -1;
		int c = pal[(h >>> 1) % pal.Size()];
		if (look.jitter > 0) c = Scale(c, 1.0 + look.jitter * ((((h >> 12) & 0xFF) / 127.5) - 1.0));
		return c;
	}

	// Seamless rooms (RS Radiance's idea): each room's floor colour pulled halfway toward its neighbours' average,
	// so a room made of several sectors reads as one colour. One pass over the lines.
	void BlendNeighbours()
	{
		int n = group.Size();
		Array<int> sr0, sg0, sb0, cnt;
		for (int i = 0; i < n; i++) { sr0.Push(0); sg0.Push(0); sb0.Push(0); cnt.Push(0); }
		for (int l = 0; l < Level.Lines.Size(); l++)
		{
			Line ln = Level.Lines[l];
			if (!ln.frontsector || !ln.backsector) continue;
			int a = ln.frontsector.Index(), b = ln.backsector.Index();
			if (a == b || base0[a] < 0 || base0[b] < 0) continue;
			sr0[a] += (base0[b] >> 16) & 255; sg0[a] += (base0[b] >> 8) & 255; sb0[a] += base0[b] & 255; cnt[a]++;
			sr0[b] += (base0[a] >> 16) & 255; sg0[b] += (base0[a] >> 8) & 255; sb0[b] += base0[a] & 255; cnt[b]++;
		}
		for (int i = 0; i < n; i++)
			if (cnt[i] > 0 && base0[i] >= 0) base0[i] = Mix(base0[i], Pack(sr0[i] / cnt[i], sg0[i] / cnt[i], sb0[i] / cnt[i]), 0.5);
	}

	// ---- one plane -------------------------------------------------------------------------------------
	bool Touched(int i)
	{
		if (mbMix > 0.001 || smMix > 0.001 || combo > 0.001 || flareUntil[i] > Level.maptime) return true;
		return waveOn && abs(wdist[i] - waveR) < WAVE_W;
	}

	void ComputePlane(int i, bool ceil, out int col, out double h)
	{
		int orig = ceil ? origCol1[i] : origCol0[i];
		col = orig;
		h = ceil ? origH1[i] : origH0[i];
		if (!cOn) return;
		double t = Level.maptime / 35.0;
		int lq = ceil ? liq1[i] : liq0[i];
		int own = cOwn;                        // 0 like 1.1, 1 the profile decides, 2 always their own colour
		bool liquidsOn = cLiquids;
		bool living = cLiving;
		int b = ceil ? base1[i] : base0[i];
		int c = -2;
		double k = 1, hh = look.height;

		if (lq != 0 && liquidsOn && own != 0)
		{
			int cls = RSQGD_Liquid.ClassOf(lq);
			bool listed = RSQGD_Liquid.Listed(lq);
			int style = own == 2 ? 0 : look.liquid;
			if (cls <= 0)
			{
				// listed, class unknown: only the flat's own colour is known (the engine's)
				if (!Touched(i)) { col = 0; return; }
				c = b >= 0 ? b : 0x606060;
			}
			else
			{
				if (style == 0 && !living && listed && !Touched(i)) { col = 0; return; }
				int lc = RSQGD_Liquid.Colour(cls);
				if (style == 1 && b >= 0) lc = Mix(lc, b, 0.5);
				else if (style == 2 && b >= 0) lc = b;
				c = lc;
				hh = 128 * cHeight / 64.0;
				if (living)
				{
					double w = 0.5 + 0.5 * sin((t * RSQGD_Liquid.Rate(cls) / 60.0 + (hsh[i] & 1023) / 1024.0) * 360);
					k *= 0.72 + 0.45 * w;
					hh *= 0.85 + 0.3 * w;
				}
			}
		}

		if (c == -2)
		{
			int sp = special[i];
			if (sp == 1 && cHazards && !ceil)
			{
				// a floor that hurts and is not a known liquid: a slow red warning throb
				c = 0xC02000;
				double w = 0.5 + 0.5 * sin(t * 40 / 60.0 * 360);
				k *= 0.55 + 0.6 * w;
				hh = 72 * (0.8 + 0.4 * w);
			}
			else if (sp == 2 && cSecrets && Level.Sectors[i].isSecret())
			{
				c = 0xFFD040;
				double w = 0.5 + 0.5 * sin((t * 20 / 60.0 + (hsh[i] & 255) / 256.0) * 360);
				k *= 0.3 + 0.5 * w;
				hh = 48;
			}
			else if (sp == 3 && cThings)
			{
				// a teleporter pad: a cyan shimmer up the walls around it
				c = 0x30C8FF;
				double w = 0.5 + 0.5 * sin((t * 30 / 60.0 + (hsh[i] & 255) / 256.0) * 360);
				k *= 0.6 + 0.5 * w;
				hh = 96 * (0.8 + 0.4 * w);
			}
			else
			{
				if (!cPlanes || b < 0)
				{
					// no floor/ceiling glow here: the map's own, or the listed flat's own switched off
					if (lq != 0 && RSQGD_Liquid.Listed(lq) && orig == 0 && !liquidsOn) col = -1;
					if (!Touched(i)) return;
					b = 0x404040;
				}
				c = b;
				k *= look.strength * (ceil ? look.ceilGain : look.floorGain);
				if (look.shape == 4) c = RotHue(c, t * look.rate * 6.0);       // rate = turns per minute
				else if (look.shape > 0)
				{
					double x = t * look.rate / 60.0 + (hsh[i] & 255) / 1024.0;
					if (look.shape == 5) x = t * look.rate / 60.0 - cdist[i] / 1024.0;
					double w = Wave01(look.shape == 5 ? 1 : look.shape, x);
					k *= 1 - look.depth + look.depth * w;
					hh *= 1 - look.depth * 0.3 + look.depth * 0.3 * w;
				}
			}
		}

		if (cDark)
		{
			double dk = clamp((200 - Level.Sectors[i].lightlevel) / 200.0, 0.0, 1.0);
			k *= 1 + 0.6 * dk;
			hh *= 1 + 0.4 * dk;
		}
		if (combo > 0) { k *= 1 + combo; hh *= 1 + combo * 0.6; }
		c = Scale(c, k);
		if (smMix > 0) c = Mix(c, Drain(c), smMix);
		if (mbMix > 0)
		{
			double beat = Wave01(2, t * 72 / 60.0);
			c = Mix(c, Scale(mbColour, 0.5 + 0.7 * beat), mbMix);
			hh += mbMix * (24 + 64 * beat);
		}
		if (tintUntil > Level.maptime) c = Mix(c, tintColour, 0.7);
		if (waveOn)
		{
			double dw = abs(wdist[i] - waveR);
			if (dw < WAVE_W)
			{
				double a = 1 - dw / WAVE_W;
				a *= a * clamp(1.2 - waveR / max(waveMax, 1.0), 0.25, 1.0);
				c = Add(Scale(c, 1 - 0.7 * a), Scale(waveCol, 1.3 * a));
				hh += 160 * a;
			}
		}
		int fu = flareUntil[i];
		if (fu > Level.maptime)
		{
			double a = (fu - Level.maptime) / double(FLARE_TICS);
			c = Add(c, Scale(flareCol[i], 1.4 * min(a, 1.0)));
			hh += 140 * min(a, 1.0);
		}
		if (c == 0) c = 0x010101;          // 0 would hand the plane to its flat; black stays black
		col = c;
		h = clamp(hh, 0.0, 2048.0);
	}

	void WriteSector(int i)
	{
		Sector s = Level.Sectors[i];
		int c; double h;
		ComputePlane(i, false, c, h);
		int hi = int(h);
		if (c != last0[i] || hi != lastH0[i]) { s.SetGlowColor(Sector.floor, c); s.SetGlowHeight(Sector.floor, h); last0[i] = c; lastH0[i] = hi; writes++; }
		ComputePlane(i, true, c, h);
		hi = int(h);
		if (c != last1[i] || hi != lastH1[i]) { s.SetGlowColor(Sector.ceiling, c); s.SetGlowHeight(Sector.ceiling, h); last1[i] = c; lastH1[i] = hi; writes++; }
	}

	bool Animating()
	{
		return (look && look.shape > 0) || mbMix > 0.001 || smMix > 0.001 || combo > 0.001 || tintUntil > Level.maptime - 2
			|| (cSecrets && specials.Size() > 0);
	}

	int LightSample()
	{
		int n = Level.Sectors.Size(), s = 0;
		for (int k = 0; k < 16 && n > 0; k++) s = s * 31 + Level.Sectors[(k * 7919) % n].lightlevel;
		return s;
	}

	void BuildNear()
	{
		nearSet.Clear();
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p] || !players[p].mo) continue;
			Vector2 at = players[p].mo.pos.xy;
			for (int i = 0; i < group.Size(); i++)
			{
				if ((Level.Sectors[i].centerspot - at).Length() < NEAR_R && nearSet.Find(i) == nearSet.Size()) nearSet.Push(i);
			}
		}
	}

	// ---- the tic ---------------------------------------------------------------------------------------
	override void WorldTick()
	{
		if (!ready) return;
		double t0 = MSTimeF();
		int now = Level.maptime;
		writesTic = writes;
		if (!live) { live = true; CacheSettings(); AfterLoad(); }

		if (now % 35 == 17) Second();
		if (now % 10 == 3) { PollMiniboss(); PollBonsai(); }
		if (now % 4 == 1) { PollSlowMo(); PollScore(); }
		Darken(mbLive > 0 && B("rsqgd_mb_darken", true) && B("rsqgd_mb", true));
		double mbT = (mbLive > 0 && B("rsqgd_mb", true)) ? 0.85 : 0.0;
		if (mbMix != mbT) { mbMix = mbMix < mbT ? min(mbT, mbMix + 0.03) : max(mbT, mbMix - 0.02); if (mbMix < 0.001) dirty = true; }
		if (combo > 0 && now - comboTic > 35 * 4) { combo = max(0.0, combo - 0.01); if (combo == 0) dirty = true; }
		if (tintUntil == now) dirty = true;

		bool anim = Animating();
		// one budget per tic (Quality): two thirds to the rooms near the players (cycling), the rest to the map
		int left = cBudget;
		if (anim && nearSet.Size() > 0)
		{
			int m = min(nearSet.Size(), cBudget * 2 / 3);
			for (int k = 0; k < m; k++) { nearCursor = (nearCursor + 1) % nearSet.Size(); WriteSector(nearSet[nearCursor]); }
			left -= m;
		}
		if (cLiving && now % 3 == 0) for (int k = 0; k < liquids.Size(); k++) WriteSector(liquids[k]);
		if (now % 3 == 1) for (int k = 0; k < specials.Size(); k++) { int sp = special[specials[k]]; if (sp == 1 || sp == 3) WriteSector(specials[k]); }
		for (int k = flares.Size() - 1; k >= 0; k--)
		{
			int i = flares[k];
			WriteSector(i);
			if (flareUntil[i] <= now) flares.Delete(k);
		}
		if (waveOn) WaveTick();
		if (dirty || anim)
		{
			// still map, a change to show: the whole budget; while something moves, the near rooms carry it and
			// the rest of the map follows in sixteenths
			int n = group.Size(), budget = anim ? clamp(n / 16, 8, max(8, left)) : cBudget;
			for (int k = 0; k < budget && n > 0; k++)
			{
				WriteSector(cursor);
				cursor++;
				if (cursor >= n) { cursor = 0; if (!anim) { dirty = false; break; } }
			}
		}
		ThingsTick();
		writesTic = writes - writesTic;
		msTic = MSTimeF() - t0;
		msPeak = max(msPeak, msTic);
	}

	void Second()
	{
		CacheSettings();
		if (Settings() != sig)
		{
			sig = Settings();
			if (I("rsqgd_reroll", 1) == 0) seed = I("rsqgd_seed", 1337);
			RebuildLook();
			ScanThings();
			dirty = true;
		}
		int ls = LightSample();
		if (ls != lightSig) { lightSig = ls; if (B("rsqgd_darkboost", true)) dirty = true; }
		for (int k = 0; k < watch.Size(); k++)
		{
			Sector s = Level.Sectors[watch[k]];
			int f = int(s.GetTexture(Sector.floor)), c = int(s.GetTexture(Sector.ceiling));
			if (f == watchF[k] && c == watchC[k]) continue;
			int i = watch[k];
			watchF[k] = f; watchC[k] = c;
			liq0[i] = RSQGD_Liquid.Classify(s.GetTexture(Sector.floor), s, Sector.floor);
			liq1[i] = RSQGD_Liquid.Classify(s.GetTexture(Sector.ceiling), s, Sector.ceiling);
			if ((liq0[i] != 0 || liq1[i] != 0) && liquids.Find(i) == liquids.Size()) liquids.Push(i);
			WriteSector(i);
		}
		if (Animating() || waveOn) BuildNear();
		int mins = I("rsqgd_reroll_min", 5);
		if (I("rsqgd_reroll", 1) == 4 && mins > 0 && Level.maptime - lastRollTic >= mins * 60 * 35) Reroll();
		CheckKeysHeld();
		ItemLightsSecond();
		if (I("rsqgd_debug", 0) >= 2)
			Console.Printf("[RSQGD] tic %d: %.3f ms (peak %.3f), %d writes so far this tic, %d total, near %d, lights %d, mb %.2f sm %.2f combo %.2f wave %d profile %s",
				Level.maptime, msTic, msPeak, writes - writesTic, writes, nearSet.Size(), LiveLights(), mbMix, smMix, combo, waveOn, look.title);
	}

	// a savegame came back: re-roll on a death if that is the setting, and re-write the map once
	void AfterLoad()
	{
		let ses = RSQGD_Session(StaticEventHandler.Find("RSQGD_Session"));
		if (I("rsqgd_reroll", 1) == 2 && ses && ses.deaths != deathsSeen) { deathsSeen = ses.deaths; Reroll(); }
		for (int i = 0; i < last0.Size(); i++) { last0[i] = NOWRITE; last1[i] = NOWRITE; }
		dirty = true;
		cursor = 0;
		RestoreDarkDoomZ();
		darkened = false;
		for (int i = 0; i < darkDelta.Size(); i++) darkDelta[i] = 0;
	}

	override void PlayerDied(PlayerEvent e)
	{
		if (I("rsqgd_reroll", 1) == 2 && multiplayer) Reroll();   // single player: the reload re-rolls
	}

	// ---- flares ----------------------------------------------------------------------------------------
	void Flare(int i, int col, int tics = FLARE_TICS)
	{
		if (i < 0 || i >= flareUntil.Size()) return;
		flareUntil[i] = Level.maptime + tics;
		flareCol[i] = col;
		if (flares.Find(i) == flares.Size()) flares.Push(i);
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (!ready || !e.thing || !cSplash || !cOn) return;
		let s = e.thing.CurSector;
		if (!s || e.thing.pos.z - e.thing.floorz > 24) return;
		int i = s.Index();
		int lq = liq0[i];
		if (lq == 0) return;
		int cls = RSQGD_Liquid.ClassOf(lq);
		Flare(i, cls > 0 ? Scale(RSQGD_Liquid.Colour(cls), 0.9) : 0x909090);
	}

	// ---- the level-up wave -----------------------------------------------------------------------------
	void StartWave(Vector2 at, int col)
	{
		if (!B("rsqgd_enabled", true) || !B("rsqgd_wave", true)) return;
		int n = group.Size();
		wdist.Clear();
		waveMax = 0;
		for (int i = 0; i < n; i++)
		{
			double d = (Level.Sectors[i].centerspot - at).Length();
			wdist.Push(d);
			waveMax = max(waveMax, d);
		}
		waveMax = min(waveMax, 6000.0);
		int nb = int(waveMax / BUCKET) + 2;
		wbStart.Clear(); wbItems.Clear();
		for (int b = 0; b <= nb; b++) wbStart.Push(0);
		for (int i = 0; i < n; i++) { int b = min(int(wdist[i] / BUCKET), nb - 1); wbStart[b + 1]++; }
		for (int b = 1; b <= nb; b++) wbStart[b] += wbStart[b - 1];
		Array<int> fill; fill.Copy(wbStart);
		for (int i = 0; i < n; i++) wbItems.Push(0);
		for (int i = 0; i < n; i++) { int b = min(int(wdist[i] / BUCKET), nb - 1); wbItems[fill[b]] = i; fill[b]++; }
		waveOn = true;
		waveT0 = Level.maptime;
		waveCol = col;
		waveR = 0; waveRPrev = 0;
	}

	void WaveTick()
	{
		waveRPrev = waveR;
		waveR = (Level.maptime - waveT0) * WAVE_SPEED;
		bool done = waveR - WAVE_W > waveMax;
		int nb = wbStart.Size() - 1;
		int b0 = max(0, int((waveRPrev - WAVE_W) / BUCKET) - 1), b1 = min(nb - 1, int((waveR + WAVE_W) / BUCKET));
		if (done) { waveOn = false; b0 = max(0, int((waveRPrev - WAVE_W) / BUCKET) - 1); b1 = nb - 1; }
		for (int b = b0; b <= b1; b++) for (int k = wbStart[b]; k < wbStart[b + 1]; k++) WriteSector(wbItems[k]);
	}

	// ---- network events: the menu's Shuffle Now and the test triggers ---------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!ready) return;
		if (e.Name ~== "rsqgd_shuffle")
		{
			int p = I("rsqgd_profile", 2);
			if (p >= RSQGD_Profiles.FIRST_NAMED)
			{
				int n = RSQGD_Profiles.Count() - RSQGD_Profiles.FIRST_NAMED;
				int np = RSQGD_Profiles.FIRST_NAMED + (p - RSQGD_Profiles.FIRST_NAMED + random[RSQGDSeed](1, n - 1)) % n;
				let c = CVar.FindCVar("rsqgd_profile");
				if (c) c.SetInt(np);
			}
			Reroll();
			return;
		}
		// TEST TRIGGERS (console, for the rig and for trying the reactions without the other mods):
		//   netevent rsqgd_test_mb 1|0     a miniboss is alive / gone
		//   netevent rsqgd_test_wave       a level-up wave from the player
		//   netevent rsqgd_test_combo N    a kill chain of N
		//   netevent rsqgd_test_slowmo P   slow motion at P permille of full speed (1000 = off)
		//   netevent rsqgd_test_flare      a splash flare on the player's sector
		//   netevent rsqgd_test_reroll     a re-roll (as a death or level-up would)
		let mo = players[e.Player].mo;
		if (e.Name ~== "rsqgd_test_mb") { testMb = e.Args[0]; mbColour = MinibossColour(null); }
		else if (e.Name ~== "rsqgd_test_wave" && mo) LevelUp(mo);
		else if (e.Name ~== "rsqgd_test_combo") { comboN = e.Args[0]; combo = min(comboN, 10) * F("rsqgd_combo_gain", 0.08); comboTic = Level.maptime; }
		else if (e.Name ~== "rsqgd_test_slowmo") testSm = e.Args[0];
		else if (e.Name ~== "rsqgd_test_flare" && mo) Flare(mo.CurSector.Index(), 0xC0C0C0, 35);
		else if (e.Name ~== "rsqgd_test_reroll") Reroll();
	}

	void LevelUp(Actor who)
	{
		if (who) StartWave(who.pos.xy, I("rsqgd_wave_color", 0xFFC020) & 0xFFFFFF);
		if (I("rsqgd_reroll", 1) == 3) Reroll();
	}

	// ---- for the service -------------------------------------------------------------------------------
	clearscope int CountLiquidSectors() const { return liquids.Size(); }
	clearscope bool IsLiquid(int i) const { return i >= 0 && i < liq0.Size() && (liq0[i] != 0 || liq1[i] != 0); }
}

// The session: what must outlive a map and a savegame load (static handlers are neither per map nor saved).
class RSQGD_Session : StaticEventHandler
{
	int deaths, deathsAtRoll, seed;
	Map<String, bool> names;
	override void PlayerDied(PlayerEvent e) { deaths++; }
}
