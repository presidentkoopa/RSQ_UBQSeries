// RSQ_SlowMo -- DOWN'S LOOK: THE BLACK AND WHITE WORLD AND DARKDOOMZ (owner 2026-11-09 17:42: "we need to find a way to black and
// white the world"; 17:44: "tinting the map blood red", "dropping DarkDoomZ to DarkDoom Black"). Run on the rig 2026-11-09 (design/rigtest_2026-11-09); not headset-confirmed.
//
// WHAT QUESTZDOOM 17.3 ALLOWS (read in its source, tag qzd17.3, and its own shaders in qzdoom.pk3):
//  * A SECTOR'S OWN DESATURATION AND LIGHT COLOUR (Sector.SetColor(colour, desat), mapdata.zs:538; p_sectors.cpp:750 writes
//    Colormap.LightColor and .Desaturation). Every renderer applies it per draw, in the shader: OpenGL/Vulkan main.fp
//    getTexel ends "desaturate(texel)" (shaders/glsl/main.fp:254), the GLES path builds it into the shader when the factor
//    is not 0 (gles_renderstate.cpp:188 doDesaturate; shaders_gles/glsl/main.fp:84-91). No post-process pass, nothing the
//    VR eye path can skip, it eases (0..255 per sector), and it is free when off. THIS IS THE ONE USED.
//    It greys EVERYTHING drawn in that sector: walls, flats, sprites and models (a thing takes its sector's colormap,
//    hw_sprites.cpp:1250; a FULL-BRIGHT thing keeps the desaturation, only its light goes white, hw_sprites.cpp:1251-1257),
//    and the glows and dynamic lights on them too (main.fp:735-742, material_normal.fp:99-108). The one thing it does NOT
//    grey is the sector's light colour (vColor: main.fp:711, the comment at :697-706), so the blood-red tint is the light
//    colour, multiplied over the grey.
//  * What it never greys: a FULL-BRIGHT PARTICLE (hw_sprites.cpp:1492-1496: Colormap.ClearColor() zeroes its desaturation)
//    and the HUD (drawn after the scene). So DOWN's crosshairs and trail are drawn as full-bright particles while the world
//    is grey (plate.zs), and its panel and edge arrows are HUD already.
//  * Rejected: Powerup.ColorMap / player.fixedcolormap (a grey ramp, per player: hw_drawinfo.cpp:331) greys the whole 3D
//    view including the targets, cannot ease (on or off), and runs as a post-process pass on OpenGL/Vulkan
//    (hw_postprocess.cpp:534 PPColormap) but per draw on GLES. A PostProcess shader (GLDEFS + PPShader, like SlowMo's own
//    Colour Drain) is screen-wide (the targets go grey too), and GLES skips every post-process pass when its shader
//    version is "100" (gles_postprocess.cpp:64-75); it has never been shown in the headset.
//  * There is no way to keep ONE ACTOR in colour inside a greyed sector. The targets stay in colour three ways: (1) a
//    target's own room (the sector it stands in) eases back to colour when it is small (Targets' Room in Colour: Small
//    Rooms, the default; Always; Off); (2) its crosshair and trail are full-bright colour particles; (3) it is full-bright
//    (DOWN's boost) so the red light tint never reaches it: in a big room it reads bright and untinted against the dark red
//    world.
//
// LOCAL ONLY (netplay, owner 11-09: a downed player's grey world is only his): a sector's colour is drawn, never read by
// the game, so the grey is written on the CONSOLE PLAYER's machine for HIS DOWN only (as plate.zs's crosshairs are). The
// numbers are saved with the game, so a save made mid-DOWN still gives every sector its own colour back.
// EXACT RESTORE: each sector's own light colour and desaturation are kept when the grey starts and written back as they
// were when it has eased out, when the map ends (before a hub keeps it), and a sector the map or another mod recoloured
// while we held it keeps THAT colour (it becomes the one we give back; we never overwrite theirs with an old one).
// RSQ GLOW IN THE DARK: its glows are Sector.SetGlowColor/SetGlowHeight, other fields; its Red Map stays as it is. Under
// the grey its red glow is greyed by the engine (main.fp:735-742) and stays a beating band of light; the red is ours (the
// light colour). DARKDOOMZ: it sets each sector's light level and fog density (its zscript.zsc ChangeLighting), other
// fields again; GITD's own darkening uses ddz_postgain, we use ddz_mode: nothing is written twice.
extend class RSQSM_Down
{
	const GW_STEPS = 16.0;        // the fade is written in 16 steps (each sector write re-lights its attached lights: p_sectors.cpp:754)
	const GW_SMALL = 768.0;       // Small Rooms: a sector no wider than this (its lines' box, map units; my number)
	const GW_ISL_STEP = 0.1;      // a room's colour eases in or out over ~0.3 s
	// THE RED READS UNDER DARKDOOM BLACK (owner 2026-11-09 18:53, rig test: "DarkDoom Black buries the blood red ... make the
	// read stronger or more intense"). The tint above multiplies the light, so in near-black rooms there is nothing left to
	// tint. While DOWN's DarkDoomZ mode is on, two things change: the tint goes all the way to red (green and blue toward
	// 0, not 40 / 30), and every sector's FADE colour (the colour its darkness fades to: Sector.SetFade, ColorMap.FadeColor)
	// is pulled toward a deep blood red, so the darkness itself is red. Both scale with Blood Red Tint and ease with the grey;
	// both are given back exactly as the light colour is.
	const HAZE_MAX = 120.0;        // the fade colour at full (Blood Red Tint 1, DarkDoomZ on): the chosen colour, brightest channel 120 (my number)
	const TINT_FLOOR = 0.14;       // without DarkDoomZ the tint keeps this much of the other channels (blood red: 255, 36, 36)
	// FOG COLOUR (owner 2026-11-09 19:13: "choose the color of the fog ... including 'random' and 'complimentary to GITD
	// colors' but have bloodred be the default"): the colour both the tint and the red darkness go toward. Fixed colours;
	// Random, one colour a DOWN (from the tic it started: no RNG is used, so netplay's random stays in step); Complementary
	// to GITD, per sector, the opposite hue of that sector's RSQ Glow In The Dark glow (floor, else ceiling; blood red where
	// it has none). Console player only, like the rest of the grey world.
	static const int FOGS[] = { 0xFF0008, 0xFF5000, 0x30FF10, 0x1040FF, 0xA020FF, 0xFFFFFF };
	static clearscope int FogMode() { return int(CvP("rsqsm_down_fog", consoleplayer, 0)); }
	// a hue (degrees) at full saturation, as 0xRRGGBB
	static int HueRGB(double h)
	{
		h = h - 360.0 * floor(h / 360.0);
		double x = 1.0 - abs((h / 60.0) % 2.0 - 1.0);
		double r = 0, g = 0, b = 0;
		if (h < 60) { r = 1; g = x; } else if (h < 120) { r = x; g = 1; } else if (h < 180) { g = 1; b = x; }
		else if (h < 240) { g = x; b = 1; } else if (h < 300) { r = x; b = 1; } else { r = 1; b = x; }
		return (int(r * 255) << 16) | (int(g * 255) << 8) | int(b * 255);
	}
	static double HueOf(int c)
	{
		double r = ((c >> 16) & 255) / 255.0, g = ((c >> 8) & 255) / 255.0, b = (c & 255) / 255.0;
		double mx = max(r, max(g, b)), mn = min(r, min(g, b)), d = mx - mn;
		if (d < 0.0001) return -1;      // grey: no hue
		double h;
		if (mx == r) h = 60.0 * (((g - b) / d) % 6.0);
		else if (mx == g) h = 60.0 * ((b - r) / d + 2.0);
		else h = 60.0 * ((r - g) / d + 4.0);
		return h < 0 ? h + 360.0 : h;
	}
	// the colour sector s goes toward
	int FogOf(Sector s)
	{
		int m = FogMode();
		if (m >= 0 && m < FOGS.Size()) return FOGS[m];
		if (m == 6) return HueRGB(((gwSeed * 40503) & 0xFFFF) * 360.0 / 65536.0);
		if (m == 7 && s)
		{
			int g = s.GetGlowColor(Sector.floor) & 0xFFFFFF;
			if (g <= 0x010101) g = s.GetGlowColor(Sector.ceiling) & 0xFFFFFF;
			double h = g > 0x010101 ? HueOf(g) : -1;
			if (h >= 0) return HueRGB(h + 180.0);
		}
		return FOGS[0];
	}

	static clearscope bool BwOn(int n) { return CvP("rsqsm_down_bw", n, 1) != 0; }
	static clearscope double BwFade(int n) { return clamp(CvP("rsqsm_down_bw_fade", n, 1.0), 0.0, 5.0); }

	// every tic (WorldTick): the console player's grey world and DarkDoomZ
	void LookTick()
	{
		int cp = consoleplayer;
		bool alive = playeringame[cp] && players[cp].mo && players[cp].mo.health > 0 && players[cp].playerstate != PST_DEAD;
		bool want = alive && IsDown(cp) && BwOn(cp);
		double fade = BwFade(cp) * TICRATE;
		double step = fade < 1.0 ? 1.0 : 1.0 / fade;
		gwMix = want ? min(1.0, gwMix + step) : max(0.0, gwMix - step);
		if (gwMix > 0 && gwN <= 0) GreyCapture();
		if (gwN > 0)
		{
			bool isl = GreyIslands(cp, want);
			int q = int(GreyEase() * GW_STEPS + 0.5);
			if (q != gwQ || isl || (level.maptime & 7) == 0) GreyApply();
			if (gwMix <= 0 && gwIslOn.Size() == 0) GreyRelease(alive ? "eased back to colour" : "eased back to colour (he died)");
		}
		DdzTick(cp);
	}
	double GreyEase() { double m = clamp(gwMix, 0.0, 1.0); return m * m * (3.0 - 2.0 * m); }

	private void GreyCapture()
	{
		int n = Level.Sectors.Size();
		gwFade.Clear(); gwLastFade.Clear(); gwCol.Clear(); gwDes.Clear(); gwLastCol.Clear(); gwLastDes.Clear(); gwIsl.Clear(); gwIslOn.Clear();
		for (int i = 0; i < n; i++)
		{
			Sector s = Level.Sectors[i];
			int c = s.ColorMap.LightColor;
			int d = s.ColorMap.Desaturation;
			int f = s.ColorMap.FadeColor;
			gwFade.Push(f); gwLastFade.Push(f);
			gwCol.Push(c); gwDes.Push(d); gwLastCol.Push(c); gwLastDes.Push(d); gwIsl.Push(0);
		}
		gwN = n; gwQ = -1; gwSeed = level.maptime + 1;
		Log(String.Format("the grey world: %d sectors' own colours kept (console player %d)", n, consoleplayer));
	}

	// the fade colour pulled toward the haze (the fog colour, its brightest channel HAZE_MAX), a 0..1
	static int Haze(int f, double a, int fog = 0xFF0008)
	{
		if (a <= 0) return f;
		int r = (f >> 16) & 255, g = (f >> 8) & 255, b = f & 255;
		double fr = (fog >> 16) & 255, fg = (fog >> 8) & 255, fb = fog & 255, fm = max(1.0, max(fr, max(fg, fb)));
		fr *= HAZE_MAX / fm; fg *= HAZE_MAX / fm; fb *= HAZE_MAX / fm;
		r = int(r + (fr - r) * a + 0.5); g = int(g + (fg - g) * a + 0.5); b = int(b + (fb - b) * a + 0.5);
		return (f & 0xFF000000) | (r << 16) | (g << 8) | b;
	}

	// the light colour times the blood-red tint, a 0..1 (its alpha byte kept)
	// the light colour multiplied toward the fog colour (normalised, its brightest channel 1), a 0..1; without DarkDoomZ
	// each channel keeps at least TINT_FLOOR
	static int Tint(int c, double a, bool deep = false, int fog = 0xFF0008)
	{
		if (a <= 0) return c;
		int r = (c >> 16) & 255, g = (c >> 8) & 255, b = c & 255;
		double kr = (fog >> 16) & 255, kg = (fog >> 8) & 255, kb = fog & 255, km = max(1.0, max(kr, max(kg, kb)));
		double fl = deep ? 0.0 : TINT_FLOOR;
		kr = max(kr / km, fl); kg = max(kg / km, fl); kb = max(kb / km, fl);
		r = int(r * (1.0 - a + a * kr) + 0.5);
		g = int(g * (1.0 - a + a * kg) + 0.5);
		b = int(b * (1.0 - a + a * kb) + 0.5);
		return (c & 0xFF000000) | (r << 16) | (g << 8) | b;
	}

	private void GreyApply()
	{
		double e = GreyEase();
		gwQ = int(e * GW_STEPS + 0.5);
		double red = clamp(CvP("rsqsm_down_bw_red", consoleplayer, 0.6), 0.0, 1.0);
		bool deep = ddzOn;                // DOWN's DarkDoomZ mode is on: the deep tint and the red darkness
		int n = min(gwN, Level.Sectors.Size());
		int writes = 0;
		for (int i = 0; i < n; i++)
		{
			Sector s = Level.Sectors[i];
			int cc = s.ColorMap.LightColor;
			int cd = s.ColorMap.Desaturation;
			// the map (a script's Sector_SetColor) or another mod recoloured it while we held it: that is its own colour now
			if (cc != gwLastCol[i] || cd != gwLastDes[i]) { gwCol[i] = cc; gwDes[i] = cd; }
			double k = int(e * (1.0 - gwIsl[i]) * GW_STEPS + 0.5) / GW_STEPS;
			int d = gwDes[i] + int((255 - gwDes[i]) * k + 0.5);
			int fog = FogOf(s);
			int c = Tint(gwCol[i], k * red, deep, fog);
			if (c != cc || d != cd) { s.SetColor(c, d); writes++; }
			gwLastCol[i] = c; gwLastDes[i] = d;
			int cf = s.ColorMap.FadeColor;
			if (cf != gwLastFade[i]) gwFade[i] = cf;
			int f = Haze(gwFade[i], deep ? k * red : 0.0, fog);
			if (f != cf) { s.SetFade(f); writes++; }
			gwLastFade[i] = f;
		}
		if (writes > 0 && Cv("rsqsm_debug", 0) >= 2) Console.Printf("RSQ_SlowMo: DOWN t%d: grey world %.2f (step %d of 16): %d sectors written", level.maptime, e, gwQ, writes);
	}

	// every sector given back its own colour exactly, unless something else recoloured it since (then it keeps that)
	void GreyRelease(String why)
	{
		int n = min(gwN, Level.Sectors.Size());
		int back = 0, theirs = 0;
		for (int i = 0; i < n; i++)
		{
			Sector s = Level.Sectors[i];
			int cc = s.ColorMap.LightColor;
			int cd = s.ColorMap.Desaturation;
			int cf = s.ColorMap.FadeColor;
			if (cf == gwLastFade[i] && cf != gwFade[i]) s.SetFade(gwFade[i]);
			if (cc != gwLastCol[i] || cd != gwLastDes[i]) { theirs++; continue; }
			if (cc != gwCol[i] || cd != gwDes[i]) { s.SetColor(gwCol[i], gwDes[i]); back++; }
		}
		if (gwN > 0) Log(String.Format("the grey world released (%s): %d sectors given their own colour back, %d recoloured by others kept as they are", why, back, theirs));
		GreyForget();
	}
	void GreyForget()
	{
		gwMix = 0; gwN = 0; gwQ = -1;
		gwFade.Clear(); gwLastFade.Clear(); gwCol.Clear(); gwDes.Clear(); gwLastCol.Clear(); gwLastDes.Clear(); gwIsl.Clear(); gwIslOn.Clear();
	}

	// TARGETS' ROOM IN COLOUR: the sector each of the console player's living targets stands in eases back to colour
	// (0 Off, 1 Small Rooms (the default: no wider than GW_SMALL), 2 Always). True while any room is easing.
	private bool GreyIslands(int cp, bool want)
	{
		int mode = want ? clamp(int(CvP("rsqsm_down_bw_room", cp, 1)), 0, 2) : 0;
		if (gwSize.Size() != gwN) GreySizes();
		Array<int> on;
		if (mode > 0)
		{
			for (int i = 0; i < tMon.Size(); i++)
			{
				if (tPn[i] != cp || tDead[i] != 0 || !tMon[i] || !tMon[i].CurSector) continue;
				int si = tMon[i].CurSector.Index();
				if (si < 0 || si >= gwN) continue;
				if (mode == 1 && gwSize[si] > GW_SMALL) continue;
				if (on.Find(si) == on.Size()) on.Push(si);
				if (gwIslOn.Find(si) == gwIslOn.Size()) gwIslOn.Push(si);
			}
		}
		bool moving = false;
		for (int j = gwIslOn.Size() - 1; j >= 0; j--)
		{
			int si = gwIslOn[j];
			double w = on.Find(si) < on.Size() ? 1.0 : 0.0;
			double v = gwIsl[si];
			double nv = v < w ? min(w, v + GW_ISL_STEP) : max(w, v - GW_ISL_STEP);
			if (nv != v) { gwIsl[si] = nv; moving = true; }
			if (nv <= 0) gwIslOn.Delete(j);
		}
		return moving;
	}
	private void GreySizes()
	{
		gwSize.Clear();
		int n = min(gwN, Level.Sectors.Size());
		for (int i = 0; i < n; i++)
		{
			Sector s = Level.Sectors[i];
			double x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9;
			for (int j = 0; j < s.lines.Size(); j++)
			{
				let ln = s.lines[j];
				Vector2 a = ln.v1.p, b = ln.v2.p;
				x0 = min(x0, min(a.x, b.x)); x1 = max(x1, max(a.x, b.x));
				y0 = min(y0, min(a.y, b.y)); y1 = max(y1, max(a.y, b.y));
			}
			gwSize.Push(x1 >= x0 ? max(x1 - x0, y1 - y0) : 0);
		}
	}

	// ---- DARKDOOMZ (Caligari87, zlib): DarkDoom Black while you are DOWN -----------------------------------------------
	// Its own code (DarkDoomZ 3.02 zscript.zsc ChangeLighting): ddz_mode 12 "DarkDoom Black" sets every sector's light to its
	// map light - 256 (then its Min Light and Post Gain), 11 "DarkDoom Classic" - 128; ddz_PRESET only scales modes 1-4 (its
	// menudef Nice_Settings 0-8), so the mode is the cvar (the brief's "ddz_preset 12" is ddz_mode 12, its Nice_Modes). It
	// reads the cvars every tic (its UiTick sends UpdateLights) and re-lights only on a change. A SERVER cvar, so the whole
	// game's: single player only (in co-op a downed player's darkness would be everyone's). Its own mode is kept and put
	// back when DOWN ends (up, dead, the clock out, the row off, the map's end), and copied to rsqsm_ddz_saved only so a
	// quit or crash mid-DOWN is put right at the next map start (GITD's way with ddz_postgain, react.zs).
	static clearscope int DdzMode() { int s = int(Cv("rsqsm_down_ddz", 1)); return s == 1 ? 12 : (s == 2 ? 11 : 0); }
	private void DdzTick(int cp)
	{
		let m = CVar.FindCVar("ddz_mode");
		if (!m) return;
		int want = 0;
		if (!multiplayer && IsDown(cp) && players[cp].mo && players[cp].mo.health > 0) want = DdzMode();
		if (want > 0 && !ddzOn)
		{
			ddzHeld = m.GetInt();
			// (11-09) RSQ Glow In The Dark's drop darkness may be holding the mode at Black: keep the player's own, not that
			let gi = ServiceIterator.Find("RSQGD_Service");
			let gd = gi ? gi.Next() : null;
			int orig = gd ? gd.GetInt("ddz.original") : -1;
			if (orig >= 0) ddzHeld = orig;
			ddzOn = true;
			let sv = CVar.FindCVar("rsqsm_ddz_saved");
			if (sv) sv.SetInt(ddzHeld);
			if (ddzHeld != want) m.SetInt(want);
			Log(String.Format("DarkDoomZ: its mode %d kept, set to %d (%s) while DOWN", ddzHeld, want, want == 12 ? "DarkDoom Black" : "DarkDoom Classic"));
		}
		else if (want == 0 && ddzOn) DdzLet("DOWN is over");
	}
	void DdzLet(String why)
	{
		if (!ddzOn) return;
		ddzOn = false;
		let m = CVar.FindCVar("ddz_mode");
		if (m) m.SetInt(ddzHeld);
		let sv = CVar.FindCVar("rsqsm_ddz_saved");
		if (sv) sv.SetInt(-9999);
		Log(String.Format("DarkDoomZ: its own mode %d back (%s)", ddzHeld, why));
	}
	private void DdzRecover()
	{
		ddzOn = false;
		let m = CVar.FindCVar("ddz_mode");
		let sv = CVar.FindCVar("rsqsm_ddz_saved");
		if (!m || !sv || sv.GetInt() == -9999) return;
		int v = sv.GetInt();
		if (v < 0 || v > 12) v = 2;      // never trust a value outside DarkDoomZ's modes (2: its default)
		m.SetInt(v);
		sv.SetInt(-9999);
		Log(String.Format("DarkDoomZ: its mode %d put back (left behind by a quit mid-DOWN)", v));
	}
}
