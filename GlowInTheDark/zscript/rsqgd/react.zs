// RSQ Glow In The Dark -- reactions to the other RSQ mods, all found BY NAME (no mod links against another; each
// works alone). Polled a few times a second, one service call each; with the other mod absent nothing happens.
//
//   RSQ Miniboss  RSQMB_Service "miniboss" (how many alive)        -> the map turns the miniboss's colour, throbs
//                 GetObject("boss", n), "colour" on it              -> the live miniboss's own colour (its tethers' and
//                                                                      life orbs'); else blood red
//   RSQ SlowMo    RSQSM_Service "active", "scale"                   -> the glow drains toward a cold grey
//                 RSQSM_Service "down.redmap"                       -> the map deep blood red while you are DOWN
//   RSQ Score     RS_ScoreService "kill.serial" per player          -> each scored kill within 4 s climbs the chain
//   Gun Bonsai VR RSQGB_Service "level", "xp.permille", "name"     -> a gold wave rolls out from the player
//   Gun Bonsai    its own netevent "bonsai-level-up" (args 1, level) -> the same wave, when the VR patch is absent
//                 (plain Gun Bonsai 0.10.6: sent when a weapon's XP bar fills, MODDING.md "Netevents emitted")
//   DarkDoomZ     its cvar ddz_postgain (read, lowered, put back)   -> the map darkens while a miniboss lives

extend class RSQGD_Handler
{
	// ServiceIterator.Find matches a PART of the name: take only the exact class.
	static Service FindSvc(String name)
	{
		let it = ServiceIterator.Find(name);
		if (!it) return null;
		Service s;
		while (s = it.Next()) if (s.GetClassName() == name) return s;
		return null;
	}

	// ---- RSQ Miniboss ----
	void PollMiniboss()
	{
		int n = 0;
		if (B("rsqgd_mb", true))
		{
			let s = FindSvc("RSQMB_Service");
			if (s) n = max(0, s.GetInt("miniboss"));
			// a new fight, or one of several minibosses gone: the colour of the first one still alive
			if (n > 0 && (mbLive == 0 || n != mbN))
			{
				mbColour = MinibossColour(s);
				if (I("rsqgd_debug", 0) > 0) Console.Printf("[RSQGD] miniboss tint: %d alive, colour %06x", n, mbColour);
			}
		}
		mbN = n;
		if (testMb > 0 && mbLive == 0) mbColour = MinibossColour(null);
		mbLive = n + testMb;
	}

	// THE DROP'S DARKNESS (owner 2026-11-09: "when the Miniboss is called in / dropped in, we go to darkdoomz blackest
	// setting ... so the player can find the miniboss"). Another mod asks "event.dark" for a few seconds; DarkDoomZ's
	// ddz_mode is held at 12, DarkDoom Black, and its own mode put back after. Single player only, as DOWN's (the mode
	// is the whole game's). It shares ddz_mode with RSQ SlowMo's DOWN: a DOWN already on is black already, so the hold
	// doesn't start; a DOWN that starts inside it asks "ddz.original" and keeps the player's own mode, not ours; at the
	// end, a DOWN still on is left to put it back.
	void DropDark()
	{
		let m = CVar.FindCVar("ddz_mode");
		if (!m) return;
		bool want = !multiplayer && darkUntil > Level.maptime;
		if (want && !ddzModeHeld)
		{
			if (AnyDown()) { darkUntil = 0; return; }
			ddzModeSaved = m.GetInt();
			ddzModeHeld = true;
			if (ddzModeSaved != 12) m.SetInt(12);
			let ds = CVar.FindCVar("rsqgd_ddz_mode_saved");
			if (ds) ds.SetInt(ddzModeSaved);
			if (I("rsqgd_debug", 0) > 0) Console.Printf("[RSQGD] drop darkness: DarkDoomZ mode %d kept, DarkDoom Black", ddzModeSaved);
		}
		else if (!want && ddzModeHeld)
		{
			ddzModeHeld = false;
			if (!AnyDown()) m.SetInt(ddzModeSaved);
			let ds = CVar.FindCVar("rsqgd_ddz_mode_saved");
			if (ds) ds.SetInt(-9999);
			if (I("rsqgd_debug", 0) > 0) Console.Printf("[RSQGD] drop darkness over: mode %d %s", ddzModeSaved, AnyDown() ? "left to DOWN" : "back");
		}
	}

	bool AnyDown()
	{
		let s = FindSvc("RSQSM_Service");
		if (!s) return false;
		for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i] && s.GetInt("down", "", i) == 1) return true;
		return false;
	}

	int MinibossColour(Service s)
	{
		int mode = I("rsqgd_mb_colour", 1);      // 0 blood red, 1 the miniboss's own (red if RSQ Miniboss gives none), 2 custom
		if (mode == 2) return I("rsqgd_mb_custom", 0xFF0000) & 0xFFFFFF;
		if (mode == 1 && s)
		{
			// the first miniboss still alive (an earlier one of this map may be dead): its own colour
			for (int i = 0; i < 64; i++)
			{
				let boss = s.GetObject("boss", "", i);
				if (!boss) break;
				if (s.GetInt("miniboss", "", 0, 0, boss) != 1) continue;
				int c = s.GetInt("colour", "", 0, 0, boss);
				if (c > 0) return c & 0xFFFFFF;
				break;
			}
		}
		return 0xB00008;
	}

	// The big moment darkens the map so the tint carries it. With DarkDoomZ: through its own post-gain setting (it
	// re-lights every sector itself when that changes; saved in rsqgd_ddz_saved first and always put back, also
	// after a quit or crash mid-fight on the next map start). Without it: each sector's light lowered and the exact
	// amount taken given back.
	// A server cvar written from play code changes on the NEXT tic (it goes through the network), so nothing here
	// reads back what it just wrote: DarkDoomZ's own value is kept in ddzSaved (the handler) and copied to
	// rsqgd_ddz_saved only so a quit or crash mid-fight can be put right on the next map start.
	void Darken(bool want)
	{
		if (want == darkened) return;
		if (want && Level.maptime < restoreAt + 3) return;     // a put-back is still on its way through the network
		int amt = clamp(I("rsqgd_mb_dark", 48), 0, 160);
		let pg = CVar.FindCVar("ddz_postgain");
		let saved = CVar.FindCVar("rsqgd_ddz_saved");
		if (want)
		{
			if (pg && saved)
			{
				ddzSaved = pg.GetInt();
				saved.SetInt(ddzSaved);
				pg.SetInt(ddzSaved - amt);
			}
			else
			{
				for (int i = 0; i < darkDelta.Size(); i++)
				{
					Sector s = Level.Sectors[i];
					int d = min(amt, max(0, s.lightlevel - 16));
					s.SetLightLevel(s.lightlevel - d);
					darkDelta[i] = d;
				}
			}
		}
		else
		{
			if (pg && saved)
			{
				pg.SetInt(ddzSaved);
				saved.SetInt(-9999);
			}
			else
			{
				for (int i = 0; i < darkDelta.Size(); i++)
				{
					if (!darkDelta[i]) continue;
					Sector s = Level.Sectors[i];
					s.SetLightLevel(s.lightlevel + darkDelta[i]);
					darkDelta[i] = 0;
				}
			}
		}
		darkened = want;
		dirty = true;
	}

	// map start / after a load: a darkness left behind by a quit mid-fight goes back (read from the archive)
	void RestoreDarkDoomZ()
	{
		// the drop darkness's mode, left at Black by a quit or a map change inside its window
		let dm = CVar.FindCVar("ddz_mode");
		let ds = CVar.FindCVar("rsqgd_ddz_mode_saved");
		if (dm && ds && ds.GetInt() != -9999 && !ddzModeHeld)
		{
			int mv = ds.GetInt();
			dm.SetInt(mv >= 0 && mv <= 12 ? mv : 2);
			ds.SetInt(-9999);
		}
		let pg = CVar.FindCVar("ddz_postgain");
		let saved = CVar.FindCVar("rsqgd_ddz_saved");
		if (!pg || !saved || saved.GetInt() == -9999) return;
		int v = saved.GetInt();
		if (v < -256 || v > 256) v = 0;      // never trust a value outside DarkDoomZ's range
		pg.SetInt(v);
		saved.SetInt(-9999);
		restoreAt = Level.maptime;
	}

	// ---- RSQ SlowMo ----
	void PollSlowMo()
	{
		double target = 0;
		if (B("rsqgd_slowmo", true))
		{
			int scale = 1000;
			let s = FindSvc("RSQSM_Service");
			if (s && s.GetInt("active") > 0) scale = s.GetInt("scale");
			if (testSm > 0) scale = min(scale, testSm);
			target = clamp((1000 - scale) / 1000.0 * 1.6, 0.0, 0.8);
		}
		double was = smMix;
		smMix = smMix < target ? min(target, smMix + 0.08) : max(target, smMix - 0.05);
		if (was > 0 && smMix == 0) dirty = true;
		// DOWN (owner 11-06, design/NEAR_DEATH.md 2): while the console player is DOWN with RSQ SlowMo's Red Map row on
		// ("down.redmap"), the whole map turns deep blood red; it comes in fast and drains back over about a second
		let s = FindSvc("RSQSM_Service");
		double dt = (s && s.GetInt("down.redmap") == 1) ? 0.92 : 0.0;
		double dw = dnMix;
		dnMix = dnMix < dt ? min(dt, dnMix + 0.25) : max(dt, dnMix - 0.12);
		if (dw != dnMix && I("rsqgd_debug", 0) > 0) Console.Printf("[RSQGD] DOWN red map %.2f", dnMix);
		if (dw > 0 && dnMix == 0) dirty = true;
	}

	// ---- RSQ Score ----
	void PollScore()
	{
		if (!B("rsqgd_combo", true)) return;
		let s = FindSvc("RS_ScoreService");
		if (!s) return;
		while (lastSerial.Size() < MAXPLAYERS) lastSerial.Push(-1);
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p]) continue;
			int ser = s.GetInt("kill.serial", "", p);
			if (ser < 0) continue;
			if (lastSerial[p] >= 0 && ser != lastSerial[p])
			{
				comboN = (Level.maptime - comboTic < 35 * 4) ? comboN + 1 : 1;
				comboTic = Level.maptime;
				combo = min(comboN, 10) * F("rsqgd_combo_gain", 0.08);
			}
			lastSerial[p] = ser;
		}
	}

	// ---- Gun Bonsai, plain: its own "bonsai-level-up" netevent (NetworkProcess) ----
	// Gun Bonsai sends it from play code when a weapon's XP bar fills (args[0] 1 = a weapon, 0 = the player's own
	// level; args[1] the level). Only the weapon one waves (the same moment the VR patch's poll waves on). With the
	// VR patch loaded its poll below does it per hand, so the event is left alone (no second wave). The event names no
	// player: every machine sends one, from its own console player, so in netplay only the first player's copy counts
	// and the wave rolls from that player.
	void BonsaiEvent(ConsoleEvent e)
	{
		if (e.Args[0] != 1) return;
		if (!B("rsqgd_wave", true) && I("rsqgd_reroll", 1) != 3) return;
		if (FindSvc("RSQGB_Service")) return;
		if (multiplayer)
		{
			int first = 0;
			while (first < MAXPLAYERS && !playeringame[first]) first++;
			if (e.Player != first) return;
		}
		let mo = players[e.Player].mo;
		if (mo) LevelUp(mo, "Gun Bonsai");
	}

	// ---- Gun Bonsai (the VR patch's service) ----
	void PollBonsai()
	{
		if (!B("rsqgd_wave", true) && I("rsqgd_reroll", 1) != 3) return;
		let s = FindSvc("RSQGB_Service");
		if (!s) return;
		while (gbLvl.Size() < MAXPLAYERS * 2) { gbLvl.Push(-1); gbWeap.Push(""); }
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p] || !players[p].mo) continue;
			let mo = players[p].mo;
			for (int hand = 0; hand < 2; hand++)
			{
				int k = p * 2 + hand;
				String w = s.GetString("name", "", hand, 0, mo);      // the gun in that hand (a swap is not a level-up)
				// Gun Bonsai says "ready to level up" when the XP bar fills (xp.permille reaches 1000); the level itself
				// only moves once an upgrade is picked. The wave goes on the first of the two, once per level.
				int lv = s.GetInt("level", "", hand, 0, mo);
				bool full = s.GetInt("xp.permille", "", hand, 0, mo) >= 1000;
				int code = lv * 2 + (full ? 1 : 0);
				if (w == gbWeap[k] && gbLvl[k] >= 0 && code > gbLvl[k] && !(lv > gbLvl[k] / 2 && (gbLvl[k] & 1))) LevelUp(mo, "Gun Bonsai VR");
				gbWeap[k] = w;
				gbLvl[k] = code;
			}
		}
	}
}
