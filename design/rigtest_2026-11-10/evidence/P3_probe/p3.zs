// TEST ONLY (scratch, rig1110 group P3): readouts and a scripted miniboss fight. Never ships.
class P3_Probe : EventHandler
{
	PlayerPawn P() { return players[consoleplayer].mo; }
	static Service Svc(String n) { let it = ServiceIterator.Find(n); return it.Next(); }
	RSQMB_Handler HD() { return RSQMB_Handler(EventHandler.Find("RSQMB_Handler")); }

	// ---- B1: block the miniboss's landing spot once ----
	bool blockArmed; Actor blocker; bool blockDone;
	// ---- B2: DarkRed tokens on landing thralls ----
	bool darkRed;
	// ---- the fight ----
	int fStep, fAt; bool fBreakFirst;
	// ---- watches ----
	int lastPhase; bool lastQuiet; int lastPrevLv; int lastBoundLives;
	double lastMus; int lastTracks; double lastLvl; bool lastPlaying;
	int lastPulse; String lastSrc; bool lastCd;
	Array<Actor> stones; Array<Actor> seenBoom; int deathTic; int lastDark;
	ui int uiLastLv; ui int uiLastSegs; ui bool uiLastShown;

	override void WorldLoaded(WorldEvent e)
	{
		let p = P();
		Console.Printf("P3 WORLDLOADED t%d map %s save %d: scene channel 32765 playing %d", level.maptime, level.MapName, e.IsSaveGame, p ? p.IsActorPlayingSound(32765) : -1);
	}
	override void WorldUnloaded(WorldEvent e)
	{
		let p = P();
		Console.Printf("P3 WORLDUNLOADED t%d: scene channel 32765 playing %d", level.maptime, p ? p.IsActorPlayingSound(32765) : -1);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		String n = a.GetClassName();
		if (n == "RSQ_ScoreLifeCrate") Console.Printf("P3 SPAWN t%d LIFE CRATE at %.0f %.0f", level.maptime, a.pos.x, a.pos.y);
		if (n.Left(10) == "RSQGN_Flip") Console.Printf("P3 SPAWN t%d %s at %.0f %.0f", level.maptime, n, a.pos.x, a.pos.y);
	}

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		let b = RSQGN_Barrel(a);
		if (b) Console.Printf("P3 BARREL t%d died at %.0f %.0f: depth %d (link %d), blink %d, blast radius %d, set off by %s", level.maptime, a.pos.x, a.pos.y,
			b.rsqgnDepth, b.rsqgnDepth + 1, b.rsqgnBlink, RSQGN_Fx.ChainRadius(b.rsqgnDepth), e.Inflictor ? e.Inflictor.GetClassName() : 'none');
		let mb = Svc("RSQMB_Service");
		if (mb && a.bIsMonster && mb.GetInt("miniboss", "", 0, 0, a) == 1) { deathTic = level.maptime; Console.Printf("P3 MINIBOSS DIED t%d %s", level.maptime, a.GetClassName()); }
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		let p = P();
		if (!p) return;
		String n = e.Name;
		if (n ~== "p3_block") { blockArmed = e.Args[0] != 0; blockDone = false; Console.Printf("P3 BLOCK armed %d", blockArmed); }
		else if (n ~== "p3_darkred") { darkRed = e.Args[0] != 0; Console.Printf("P3 DARKRED %d", darkRed); }
		else if (n ~== "p3_fight") { fStep = 1; fAt = level.maptime; fBreakFirst = e.Args[0] != 0; Console.Printf("P3 FIGHT armed t%d break first window %d", level.maptime, fBreakFirst); }
		else if (n ~== "p3_stone")   // x y: a tombstone there
		{
			Vector2 xy = (e.Args[0], e.Args[1]);
			double fz = level.PointInSector(xy).floorplane.ZAtPoint(xy);
			let s = Actor.Spawn("gy_Stone", (xy, fz), NO_REPLACE);
			if (s) stones.Push(s);
			Console.Printf("P3 STONE %d at %.0f %.0f %.0f: %s", stones.Size() - 1, xy.x, xy.y, fz, s ? "placed" : "none");
		}
		else if (n ~== "p3_pillar")   // x y: a solid tech column there
		{
			Vector2 xy = (e.Args[0], e.Args[1]);
			double fz = level.PointInSector(xy).floorplane.ZAtPoint(xy);
			let s = Actor.Spawn("TechPillar", (xy, fz), NO_REPLACE);
			Console.Printf("P3 PILLAR at %.0f %.0f: %s solid %d radius %.0f", xy.x, xy.y, s ? s.GetClassName() : 'none', s ? s.bSolid : 0, s ? s.radius : 0);
		}
		else if (n ~== "p3_tp") { p.SetOrigin((e.Args[0], e.Args[1], p.floorz), false); p.angle = e.Args[2]; Console.Printf("P3 TP t%d to %.0f %.0f angle %d", level.maptime, p.pos.x, p.pos.y, e.Args[2]); }
		else if (n ~== "p3_clear")
		{
			int k = 0; let it = ThinkerIterator.Create("Actor"); Actor a;
			while (a = Actor(it.Next())) if (a.bIsMonster && !a.player) { a.ClearCounters(); a.Destroy(); k++; }
			Console.Printf("P3 CLEAR t%d %d monsters removed", level.maptime, k);
		}
		else if (n ~== "p3_barrel")   // x y kind(0 ExplosiveBarrel, 1 ExplosiveBarrel1)
		{
			Vector2 xy = (e.Args[0], e.Args[1]);
			String cn = e.Args[2] ? "ExplosiveBarrel1" : "ExplosiveBarrel";
			let a = Actor.Spawn(cn, (xy, level.PointInSector(xy).floorplane.ZAtPoint(xy)), ALLOW_REPLACE);
			Console.Printf("P3 BARREL spawned %s -> %s at %.0f %.0f (rsqgn_barrel_replace_bd %d)", cn, a ? a.GetClassName() : 'none', xy.x, xy.y, CVar.FindCVar("rsqgn_barrel_replace_bd").GetInt());
		}
		else if (n ~== "p3_barrels")   // count barrels in the map by class
		{
			Array<String> cls; Array<int> cnt;
			let it = ThinkerIterator.Create("Actor"); Actor a;
			while (a = Actor(it.Next())) { String c = a.GetClassName(); if (c.IndexOf("Barrel") < 0 || a.bMissile || a.health <= 0) continue; int i = cls.Find(c); if (i == cls.Size()) { cls.Push(c); cnt.Push(1); } else cnt[i]++; }
			String s = ""; for (int i = 0; i < cls.Size(); i++) s = s .. String.Format("%s x%d  ", cls[i], cnt[i]);
			Console.Printf("P3 BARRELS t%d tag %d: %s", level.maptime, e.Args[0], s == "" ? "none" : s);
		}
		else if (n ~== "p3_shoot")   // the barrel nearest x y, shot by the player
		{
			Vector2 xy = (e.Args[0], e.Args[1]);
			let it = ThinkerIterator.Create("RSQGN_Barrel"); Actor a, best; double bd = 1e9;
			while (a = Actor(it.Next())) if (a.health > 0) { double d = (a.pos.xy - xy).Length(); if (d < bd) { bd = d; best = a; } }
			if (best) { Console.Printf("P3 SHOOT t%d barrel at %.0f %.0f", level.maptime, best.pos.x, best.pos.y); best.DamageMobj(p, p, 100, 'None', DMG_THRUSTLESS); }
		}
		else if (n ~== "p3_deflect")   // a remote bolt the player sent back, alive a few tics before it reaches its remote
		{
			let it = ThinkerIterator.Create("UBQS_Remote"); let r = UBQS_Remote(it.Next());
			if (!r) { Console.Printf("P3 DEFLECT t%d: no remote", level.maptime); return; }
			Vector3 c = r.pos + (0, 0, r.height * 0.5);
			Vector3 dir = (c - p.pos); dir.z = 0; dir = dir.Unit();
			let b = UBQS_RemoteBolt(Actor.Spawn("UBQS_RemoteBolt", c - dir * 40));
			if (b) { b.target = p; b.home = r; b.vel = dir * 5; }
			Console.Printf("P3 DEFLECT t%d bolt %s, remote deflects %d", level.maptime, b ? "sent back" : "none", r.deflects);
		}
		else if (n ~== "p3_fog")
		{
			int ns = level.Sectors.Size(); double fog = 0; int nz = 0;
			for (int i = 0; i < ns; i++) { int f = level.Sectors[i].ColorMap.FogDensity; fog += f; if (f) nz++; }
			Console.Printf("P3 FOG t%d tag %d: rsqgd_enabled %d ddz_fog %d; %d sectors, %d with fog, mean fog density %.1f; player's sector %d", level.maptime, e.Args[0],
				CVar.FindCVar("rsqgd_enabled").GetInt(), CVar.FindCVar("ddz_fog").GetInt(), ns, nz, ns ? fog / ns : 0.0, p.cursector.ColorMap.FogDensity);
		}
		else if (n ~== "p3_scan")   // what lies in the world: life crates, kill reward bits, undead
		{
			int crates = 0, hb = 0, ab = 0, mbits = 0, und = 0, risers = 0;
			let it = ThinkerIterator.Create("Actor"); Actor a;
			while (a = Actor(it.Next()))
			{
				String c = a.GetClassName();
				if (c == "RSQ_ScoreLifeCrate") crates++;
				else if (c == "RSQ_KRHealthBit") hb++; else if (c == "RSQ_KRArmorBit") ab++; else if (c == "RSQ_KRAmmoBit") mbits++;
				else if (a.bIsMonster && a.health > 0 && gy_Bones.IsLob(c)) und++;
				else if (c.IndexOf("Spawn") > 0 && (c.Left(5) == "Skull" || c.Left(8) == "Skeleton")) risers++;
			}
			Console.Printf("P3 SCAN t%d tag %d: life crates %d; kill reward bits health %d armour %d ammo %d; LoB undead alive %d, rising %d", level.maptime, e.Args[0], crates, hb, ab, mbits, und, risers);
		}
		else if (n ~== "p3_legend")   // each Bossfight monster: legendary token, health vs spawn health
		{
			let mb = Svc("RSQMB_Service");
			let it = ThinkerIterator.Create("Actor"); Actor a;
			while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0 && a.FindInventory("RSQMB_Called"))
			{
				bool isB = mb && mb.GetInt("miniboss", "", 0, 0, a) == 1;
				String toks = ""; for (let i = a.Inv; i; i = i.Inv) { String c = i.GetClassName(); if (c.Left(2) == "LD") toks = toks .. c .. " "; }
				Console.Printf("P3 LEGEND t%d tag %d %s %s: hp %d / spawn %d, rsqmb_legend_thralls %d, LD items [%s]", level.maptime, e.Args[0], isB ? "MINIBOSS" : "thrall", a.GetClassName(), a.health, a.SpawnHealth(),
					CVar.FindCVar("rsqmb_legend_thralls").GetInt(), toks);
			}
		}
		else if (n ~== "p3_classic")
		{
			let hd = HD();
			if (!hd) return;
			for (int i = 0; i < hd.bosses.Size(); i++) { let b = hd.bosses[i]; if (b) Console.Printf("P3 CLASSIC t%d boss %d %s called %d done %d lives %d thralls %d dist %.0f", level.maptime, i, b.mb ? b.mb.GetClassName() : 'none', b.called, b.done, b.lives, b.thr.Size(), b.mb ? p.Distance3D(b.mb) : -1); }
			Console.Printf("P3 CLASSIC t%d %d bosses, bfBoss %d, arrPhase %d", level.maptime, hd.bosses.Size(), hd.bfBoss != null, hd.arrPhase);
		}
	}

	override void WorldTick()
	{
		let p = P();
		if (!p) return;
		let hd = HD();
		int now = level.maptime;
		if (hd)
		{
			// B1: the blocker on the miniboss's spot the tic the landing starts, taken away once the failure made it quiet
			if (blockArmed && !blockDone && hd.arrPhase == 1 && !blocker && hd.arrX.Size() > 0 && !hd.arrQuiet)
			{
				blocker = Actor.Spawn("TechPillar", (hd.arrX[0], hd.arrY[0], hd.arrZ[0]), NO_REPLACE);
				Console.Printf("P3 BLOCK t%d a TechPillar on the miniboss's spot %.0f %.0f", now, hd.arrX[0], hd.arrY[0]);
			}
			if (blocker && hd.arrQuiet) { blocker.Destroy(); blocker = null; blockDone = true; blockArmed = false; Console.Printf("P3 BLOCK t%d the landing failed (arrQuiet): the pillar taken away", now); }
			if (hd.arrPhase != lastPhase || hd.arrQuiet != lastQuiet) { Console.Printf("P3 ARR t%d phase %d quiet %d", now, hd.arrPhase, hd.arrQuiet); lastPhase = hd.arrPhase; lastQuiet = hd.arrQuiet; }
			// B2: DarkRed on every thrall that has landed
			if (darkRed && hd.arrPhase == 1)
				for (int i = 1; i < hd.arrMon.Size(); i++) { let t = hd.arrMon[i]; if (t && t.health > 0 && !t.FindInventory("champion_DarkRedToken")) { t.GiveInventoryType("champion_DarkRedToken"); Console.Printf("P3 DARKRED t%d thrall %d %s given champion_DarkRedToken", now, i, t.GetClassName()); } }
			if (hd.arrPhase == 1)
			{
				int pv = hd.LifeBonusPreview();
				if (pv != lastPrevLv) { Console.Printf("P3 LIVES t%d landing: LifeBonusPreview %d (rsqmb_lives %d)", now, pv, CVar.FindCVar("rsqmb_lives").GetInt()); lastPrevLv = pv; }
			}
			if (hd.bfBoss && !hd.bfBoss.done && hd.bfBoss.lives != lastBoundLives) { Console.Printf("P3 LIVES t%d bound boss lives %d", now, hd.bfBoss.lives); lastBoundLives = hd.bfBoss.lives; }
		}
		// music (V1, V2)
		let sc = RSQVR_Scenes.Get();
		if (sc)
		{
			double lv = sc.tLevel.Size() ? sc.tLevel[0] : -1;
			bool pl = p.IsActorPlayingSound(32765);
			if (sc.musSet != lastMus || sc.tName.Size() != lastTracks || pl != lastPlaying)
				Console.Printf("P3 MUSIC t%d musSet %.3f (music volume %.3f) tracks %d level %.3f channel playing %d", now, sc.musSet, sc.musSet - 1, sc.tName.Size(), lv, pl);
			lastMus = sc.musSet; lastTracks = sc.tName.Size(); lastPlaying = pl;
		}
		// SlowMo's pulse and bar (S1, S4)
		let ck = RSQSM_Clock(EventHandler.Find("RSQSM_Clock"));
		if (ck && (ck.pulseUntil != lastPulse || ck.pulseSrc != lastSrc || ck.cdOn != lastCd))
		{
			Console.Printf("P3 SLOW t%d pulse %s%s, bar %d", now, ck.pulseUntil > now ? String.Format("until t%d (%d tics left) from ", ck.pulseUntil, ck.pulseUntil - now) : "none", ck.pulseUntil > now ? ck.pulseSrc : "", ck.cdOn);
			lastPulse = ck.pulseUntil; lastSrc = ck.pulseSrc; lastCd = ck.cdOn;
		}
		// GITD's dark hold
		// barrels' blasts
		let it = ThinkerIterator.Create("RSQGN_Boom"); RSQGN_Boom bm;
		while (bm = RSQGN_Boom(it.Next())) if (seenBoom.Find(bm) == seenBoom.Size() && bm.age > 0)
		{
			seenBoom.Push(bm);
			Console.Printf("P3 BOOM t%d at %.0f %.0f barrel %d depth %d mainSeq %d k %.2f", now, bm.pos.x, bm.pos.y, bm.isBarrel, bm.depth, bm.mainSeq, bm.k);
		}
		RunFight();
	}

	override void RenderOverlay(RenderEvent e)
	{
		let hd = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!hd) return;
		bool shown = RSQMB_Handler.StackShown();
		int segs, lv; bool win;
		[segs, win, lv] = RSQMB_Handler.StackParts(hd);
		if (shown != uiLastShown || lv != uiLastLv || segs != uiLastSegs)
		{
			Console.Printf("P3 HUDSTACK maptime %d shown %d segs %d window %d life bars %d (arrPhase %d)", level.maptime, shown, segs, win, lv, hd.arrPhase);
			uiLastShown = shown; uiLastLv = lv; uiLastSegs = segs;
		}
	}

	override void UiTick()
	{
		let c = CVar.GetCVar("p3_menusel", players[consoleplayer]);
		if (!c || c.GetInt() < 0) return;
		let m = OptionMenu(Menu.GetCurrentMenu());
		if (!m || !m.mDesc) return;
		int want = c.GetInt();
		if (want >= 1000)   // dump the rows, then off
		{
			for (int i = 0; i < m.mDesc.mItems.Size(); i++) Console.Printf("P3 MENU %s [%d] \"%s\" %s", m.mDesc.mMenuName, i, m.mDesc.mItems[i].mLabel, m.mDesc.mItems[i].GetClassName());
			c.SetInt(-1);
			return;
		}
		want = min(want, m.mDesc.mItems.Size() - 1);
		if (m.mDesc.mSelectedItem != want) { m.mDesc.mSelectedItem = want; m.mDesc.mScrollPos = max(0, want - 8); }
	}

	// THE FIGHT (rtp's, with the first window broken early when asked): land, shield hit, a thrall killed, the window
	// broken 8 tics in (or missed), more thralls, every thrall, the miniboss hammered through its lives
	void RunFight()
	{
		if (fStep <= 0) return;
		let mb = Svc("RSQMB_Service");
		if (!mb) return;
		Actor boss; Array<Actor> th;
		let it = ThinkerIterator.Create("Actor"); Actor a;
		while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0)
		{
			if (mb.GetInt("miniboss", "", 0, 0, a) == 1) boss = a;
			else if (mb.GetInt("thrall", "", 0, 0, a) == 1) th.Push(a);
		}
		int now = level.maptime, since = now - fAt;
		let p = P();
		int segs = boss ? mb.GetInt("segments", "", 0, 0, boss) : -1, win = boss ? mb.GetInt("window", "", 0, 0, boss) : -1;
		int lives = boss ? mb.GetInt("lives", "", 0, 0, boss) : -1;
		String st = String.Format("boss %s hp %d, %d thralls, segs %d, window %d, lives %d", boss ? boss.GetClassName() : 'none', boss ? boss.health : 0, th.Size(), segs, win, lives);
		if (fStep == 1 && boss && segs > 0 && since > 35) { Console.Printf("P3F t%d F1 LANDED: %s", now, st); boss.DamageMobj(p, p, 40, 'None'); Go(2); }
		else if (fStep == 2 && since > 20 && th.Size()) { th[0].DamageMobj(p, p, th[0].health + 100, 'None'); Console.Printf("P3F t%d F2 thrall killed (window opens)", now); Go(fBreakFirst ? 21 : 3); }
		else if (fStep == 21 && since >= 8 && win > 0) { int s0 = segs; boss.DamageMobj(p, p, 2000, 'None'); Console.Printf("P3F t%d F21 hit 8 tics into the window: segs %d -> %d, window now %d", now, s0, mb.GetInt("segments", "", 0, 0, boss), mb.GetInt("window", "", 0, 0, boss)); Go(22); }
		else if (fStep == 22 && since > 90) { if (th.Size()) { th[0].DamageMobj(p, p, th[0].health + 100, 'None'); Console.Printf("P3F t%d F22 thrall killed (window opens, let it run out)", now); Go(3); } else Go(6); }
		else if (fStep == 3 && since > 5 && win <= 0) { Console.Printf("P3F t%d F3 window over: %s", now, st); Go(4); }
		else if (fStep == 4 && since > 70) { if (th.Size()) { th[0].DamageMobj(p, p, th[0].health + 100, 'None'); Console.Printf("P3F t%d F4 thrall killed", now); Go(5); } else Go(6); }
		else if (fStep == 5 && since > 3 && win > 0) { boss.DamageMobj(p, p, 2000, 'None'); Console.Printf("P3F t%d F5 hit in the window: %s", now, st); Go(6); }
		else if (fStep == 6 && since > 60) { Console.Printf("P3F t%d F6 kill every thrall: %s", now, st); for (int i = 0; i < th.Size(); i++) th[i].DamageMobj(p, p, th[i].health + 100, 'None'); Go(7); }
		else if (fStep == 7 && since > 10)
		{
			if (!boss) { Console.Printf("P3F t%d F7 MINIBOSS DEAD", now); Go(8); return; }
			if (since % 12 == 0) { int h0 = boss.health; boss.DamageMobj(p, p, 2000, 'None'); Console.Printf("P3F t%d F7 hammer: hp %d -> %d, lives %d", now, h0, boss ? boss.health : 0, lives); }
		}
		else if (fStep == 8 && since > 70) { Console.Printf("P3F t%d F8 DONE", now); fStep = 0; }
	}
	void Go(int s) { fStep = s; fAt = level.maptime; }
}
