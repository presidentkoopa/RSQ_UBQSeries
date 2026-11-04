// RSQ Glow In The Dark -- which flats are liquids, and what colour each one glows.
//
// A plane's code: 0 not a liquid; -1 in the owner's Glow list (GLDEFS.txt) but of no known kind (the engine still
// knows its own colour: plane glow 0); 1..N a known kind in the list; 100+kind a kind found only by its NAME (an
// unknown map pack's flat that says NUKAGE, LAVA, SLIME... in its name, or that the map's TERRAIN calls liquid):
// no GLDEFS glow exists for it, so its colour is always written.
//
// The kinds' colours approximate each flat's own average (the engine's GLDEFS glow is the average x 0.6); living
// liquids need them written out, because a plane given 0 can only show the engine's still colour.

class RSQGD_Liquid play
{
	enum EKind
	{
		K_WATER = 1, K_NUKAGE, K_SLIME, K_LAVA, K_BLOOD, K_SLUDGE, K_SCREEN, K_EXIT, K_SNOW, K_PURPLE, K_BLUEFIRE,
		K_GREYPOIS, K_BROWNPOIS, K_GREENWATER, K_COUNT
	}

	clearscope static int Colour(int cls)
	{
		static const int COLOURS[] = {
		0x000000,
		0x2050D0,   // water
		0x30C020,   // nukage
		0x607018,   // slime / sludge (brown-green)
		0xF05010,   // lava, magma, fire
		0xB00010,   // blood
		0xD04810,   // orange sludge (SLIME09-12, RROCK05-08)
		0x3090F0,   // screens
		0xF02818,   // exit signs
		0xB0D8FF,   // snow / ice
		0x8030D0,   // purple water
		0x2850FF,   // blue fire
		0x709070,   // grey poison
		0x705020,   // brown poison
		0x20A060    // green water
		};
		return (cls > 0 && cls < K_COUNT) ? COLOURS[cls] : 0x808080;
	}
	// living-liquid breathing, cycles per minute (lava slow and heavy, water quick and light)
	clearscope static int Rate(int cls)
	{
		static const int RATES[] = { 0, 14, 20, 10, 8, 9, 9, 30, 24, 6, 12, 26, 12, 12, 14 };
		return (cls > 0 && cls < K_COUNT) ? RATES[cls] : 12;
	}

	clearscope static int ClassOf(int code) { return code > 100 ? code - 100 : code; }
	clearscope static bool Listed(int code) { return code != 0 && code < 100; }

	static bool Pre(String n, String p) { return n.Left(p.Length()) == p; }

	// the kind from a name in (or like one in) the owner's list
	static int KindOf(String n)
	{
		if (Pre(n, "FWATER") || Pre(n, "SWATER") || Pre(n, "WFALL") || Pre(n, "WF4LL") || Pre(n, "SFALL")
			|| Pre(n, "FHDW") || Pre(n, "WSPL") || Pre(n, "SPHW")) return K_WATER;
		if (Pre(n, "NUKAGE") || Pre(n, "NUKE") || Pre(n, "NKSH") || Pre(n, "NSPL") || Pre(n, "SPHG") || Pre(n, "GFALL")) return K_NUKAGE;
		if (Pre(n, "SLIME09") || Pre(n, "SLIME1") || Pre(n, "RROCK05") || Pre(n, "RROCK06") || Pre(n, "RROCK07") || Pre(n, "RROCK08"))
		{
			if (n == "SLIME13" || n == "SLIME14" || n == "SLIME15" || n == "SLIME16") return 0;   // plain metal floors
			return K_SLUDGE;
		}
		if (Pre(n, "SLIME") || Pre(n, "SLUDGE") || Pre(n, "FHDS") || Pre(n, "SLMFAL") || Pre(n, "SLIM")) return K_SLIME;
		if (Pre(n, "FIREBLU")) return K_BLUEFIRE;
		if (Pre(n, "LAVA") || Pre(n, "FIRELAV") || Pre(n, "FIREMAG") || Pre(n, "FIREWAL") || Pre(n, "MAGMA") || Pre(n, "QLAVA")
			|| Pre(n, "XLAV") || Pre(n, "LFALL") || Pre(n, "LVAS") || Pre(n, "LSPL") || Pre(n, "LVA") || Pre(n, "FHDM")) return K_LAVA;
		if (Pre(n, "BLOOD") || Pre(n, "BLOD") || Pre(n, "BFALL") || Pre(n, "BSPL") || Pre(n, "BSPH") || Pre(n, "FHDB")
			|| Pre(n, "BLUDE") || Pre(n, "SPHR") || Pre(n, "SPHB")) return K_BLOOD;
		if (Pre(n, "COMP") || Pre(n, "RWDMON")) return K_SCREEN;
		if (Pre(n, "EXIT")) return K_EXIT;
		if (Pre(n, "SNOW")) return K_SNOW;
		if (Pre(n, "PURW")) return K_PURPLE;
		if (Pre(n, "GRAYPOIS")) return K_GREYPOIS;
		if (Pre(n, "BRNPOIS")) return K_BROWNPOIS;
		if (Pre(n, "GRWAT")) return K_GREENWATER;
		return 0;
	}

	// a flat NOT in the list: does its name (or the map's TERRAIN) say liquid? (Oblige, OTEX, megawads)
	static int Heuristic(String n, Sector s, int pos)
	{
		if (n == "SLIME13" || n == "SLIME14" || n == "SLIME15" || n == "SLIME16" || n == "F_SKY1") return 0;
		if (n.IndexOf("NUK") >= 0 || n.IndexOf("ACID") >= 0 || n.IndexOf("TOXIC") >= 0 || n.IndexOf("OOZE") >= 0) return K_NUKAGE;
		if (n.IndexOf("LAVA") >= 0 || n.IndexOf("MAGMA") >= 0) return K_LAVA;
		if (n.IndexOf("BLOOD") >= 0 || n.IndexOf("BLOD") >= 0) return K_BLOOD;
		if (n.IndexOf("WATER") >= 0 || n.IndexOf("WATR") >= 0) return K_WATER;
		if (n.IndexOf("SLIM") >= 0 || n.IndexOf("SLUDG") >= 0) return K_SLIME;
		if (n.IndexOf("POIS") >= 0) return K_GREYPOIS;
		if (pos == Sector.floor)
		{
			let td = s.GetFloorTerrain(Sector.floor);
			if (td && td.IsLiquid) return s.damageamount > 0 ? K_NUKAGE : K_WATER;
		}
		return 0;
	}

	static int Classify(TextureID t, Sector s, int pos)
	{
		if (!t.IsValid()) return 0;
		String n = TexMan.GetName(t);
		n = n.MakeUpper();
		if (RSQGD_LiquidNames.Has(n))
		{
			int k = KindOf(n);
			return k > 0 ? k : -1;
		}
		if (!RSQGD_Handler.B("rsqgd_guess", true)) return 0;
		int h = Heuristic(n, s, pos);
		return h > 0 ? 100 + h : 0;
	}
}

extend class RSQGD_LiquidNames
{
	// a Map kept by the session (built once per game, not per map; 591 names)
	play static bool Has(String n)
	{
		let ses = RSQGD_Session(StaticEventHandler.Find("RSQGD_Session"));
		Array<String> all;
		if (!ses)
		{
			Fill(all);
			return all.Find(n) < all.Size();
		}
		if (ses.names.CountUsed() == 0) { Fill(all); for (int i = 0; i < all.Size(); i++) ses.names.Insert(all[i], true); }
		return ses.names.CheckKey(n);
	}
}
