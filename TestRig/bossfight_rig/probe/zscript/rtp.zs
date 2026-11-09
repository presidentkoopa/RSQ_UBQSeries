// RIG PROBE (test only, never ships)
class RTP_Handler : EventHandler
{
	Array<Actor> bm; Array<int> bmStart; Array<int> bmRet; Array<bool> bmSeen;
	Actor watchBoss; int logEvery; int autoStep; int autoAt; int autoHits; Array<Actor> brl; Array<int> brlHp;

	static Service Svc(String n) { let it = ServiceIterator.Find(n); return it.Next(); }
	static bool IsBarrel(Actor a) { String n = a.GetClassName(); return n.IndexOf("Barrel") >= 0; }
	static String BN(Actor a) { if (!a) return "none"; String n = a.GetClassName(); return n; }
	Actor P() { return players[consoleplayer].mo; }
	Vector3 Ahead(double d, double side = 0)
	{
		let p = P();
		return (p.pos.xy + Actor.AngleToVector(p.angle, d) + Actor.AngleToVector(p.angle - 90, side), p.floorz);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		let p = P();
		if (e.Name ~== "rt_auto") { autoStep = 1; autoAt = level.maptime; Console.Printf("RTP t%d AUTO armed", level.maptime); }
		else if (e.Name ~== "rt_beams")
		{
			let vr = Svc("RSQVR_Service");
			Console.Printf("RTP beams: service %s", vr ? "found" : "MISSING");
			static const String K[] = { "v1", "v2", "v3", "v4" };
			static const String R[] = { "chump", "thrall", "thrall", "miniboss" };
			static const int C[] = { 0x3CDC46, 0x3C78FF, 0xE62828, 0xAA46E6 };
			for (int i = 0; i < 4; i++)
			{
				let a = Actor.Spawn(i == 3 ? "BaronOfHell" : "DoomImp", Ahead(320, (i - 1.5) * 96), ALLOW_REPLACE);
				if (!a) continue;
				a.angle = a.AngleTo(p); a.bDormant = true;
				int r = vr ? vr.GetInt("beam", K[i], C[i], 1.0, a, R[i]) : -1;
				bm.Push(a); bmStart.Push(level.maptime); bmRet.Push(r); bmSeen.Push(false);
				Console.Printf("RTP beam %s on %s: returned %d (invisible now %d)", K[i], a.GetClassName(), r, a.bInvisible);
			}
		}
		else if (e.Name ~== "rt_words")
		{
			let vr = Svc("RSQVR_Service");
			for (int i = 0; i < bm.Size(); i++) if (bm[i])
			{
				int a1 = vr.GetInt("word", "GUARD!", 0xC0C8D0, 1.0, bm[i]);
				int a2 = vr.GetInt("word.hold", "TARGET!", 0xFFD040, i == 3 ? 2.0 : 1.0, bm[i]);
				int a3 = vr.GetInt("pop", "", 0xE62828, 1.0, bm[i]);
				Console.Printf("RTP words on %d: word %d hold %d pop %d", i, a1, a2, a3);
			}
		}
		else if (e.Name ~== "rt_wordclear")
		{
			let vr = Svc("RSQVR_Service");
			for (int i = 0; i < bm.Size(); i++) if (bm[i]) Console.Printf("RTP clear %d: %d", i, vr.GetInt("word.clear", "TARGET!", 0, 0, bm[i]));
		}
		else if (e.Name ~== "rt_spawnmix")   // the map's roster: a few types behind the player, along the west wall
		{
			static const String M[] = { "ZombieMan", "ShotgunGuy", "DoomImp", "DoomImp", "Demon", "Cacodemon", "HellKnight", "BaronOfHell" };
			for (int i = 0; i < M.Size(); i++)
			{
				let a = Actor.Spawn(M[i], (-470, -400 + i * 110, 0), ALLOW_REPLACE);
				if (a) { a.bDormant = true; a.bNoGravity = false; Console.Printf("RTP roster %s", a.GetClassName()); }
			}
		}
		else if (e.Name ~== "rt_barrels")
		{
			int n = max(1, e.Args[0]);
			for (int i = 0; i < n; i++)
			{
				let b = Actor.Spawn("ExplosiveBarrel", Ahead(200 + 40 * (i / 3), (i % 3 - 1) * 40), ALLOW_REPLACE);
				if (b) { brl.Push(b); brlHp.Push(b.health); Console.Printf("RTP barrel %d: %s at %.0f %.0f", brl.Size() - 1, b.GetClassName(), b.pos.x, b.pos.y); }
			}
		}
		else if (e.Name ~== "rt_shootbarrel")
		{
			let it = ThinkerIterator.Create("Actor"); Actor a; Actor best; double bd = 1e9;
			while (a = Actor(it.Next())) if (a.bShootable && a.health > 0 && IsBarrel(a)) { double d = p.Distance3D(a); if (d < bd) { bd = d; best = a; } }
			if (best) { Console.Printf("RTP shoot barrel %s at %.0f", best.GetClassName(), bd); best.DamageMobj(p, p, 1000, 'None'); }
		}
		else if (e.Name ~== "rt_mb")   // the bossfight: log its state; Args[0] 1 hit the miniboss, 2 kill one thrall, 3 kill every thrall, 4 hit the miniboss hard
		{
			let mb = Svc("RSQMB_Service");
			Actor boss; Array<Actor> th;
			let it = ThinkerIterator.Create("Actor"); Actor a;
			while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0)
			{
				if (mb.GetInt("miniboss", "", 0, 0, a) == 1) boss = a;
				else if (mb.GetInt("thrall", "", 0, 0, a) == 1) th.Push(a);
			}
			Console.Printf("RTP mb: boss %s hp %d, %d thralls, segs %d, shielded %d, window %d, lives %d, tier %d",
				BN(boss), boss ? boss.health : 0, th.Size(),
				boss ? mb.GetInt("segments", "", 0, 0, boss) : -1, boss ? mb.GetInt("shielded", "", 0, 0, boss) : -1,
				boss ? mb.GetInt("window", "", 0, 0, boss) : -1, boss ? mb.GetInt("lives", "", 0, 0, boss) : -1,
				boss ? mb.GetInt("tier", "", 0, 0, boss) : -1);
			for (int i = 0; i < th.Size(); i++) Console.Printf("RTP   thrall %s hp %d", th[i].GetClassName(), th[i].health);
			if (e.Args[0] == 1 && boss) { int h0 = boss.health; boss.DamageMobj(p, p, 40, 'None'); Console.Printf("RTP hit boss 40: %d -> %d", h0, boss.health); }
			if (e.Args[0] == 4 && boss) { int h0 = boss.health; boss.DamageMobj(p, p, 400, 'None'); Console.Printf("RTP hit boss 400: %d -> %d", h0, boss.health); }
			if (e.Args[0] == 2 && th.Size()) { th[0].DamageMobj(p, p, th[0].health + 100, 'None'); Console.Printf("RTP killed thrall %s", th[0].GetClassName()); }
			if (e.Args[0] == 3) for (int i = 0; i < th.Size(); i++) th[i].DamageMobj(p, p, th[i].health + 100, 'None');
		}
	}

	override void WorldTick()
	{
		RunAuto();
		for (int i = 0; i < brl.Size(); i++)
		{
			int h = brl[i] ? brl[i].health : -999;
			if (h != brlHp[i]) { Console.Printf("RTP t%d barrel %d hp %d -> %d", level.maptime, i, brlHp[i], h); brlHp[i] = h; }
		}
		for (int i = 0; i < bm.Size(); i++)
		{
			if (!bm[i] || bmSeen[i]) continue;
			if (!bm[i].bInvisible) { bmSeen[i] = true; Console.Printf("RTP beam %d revealed after %d tics (returned %d) style %d alpha %.2f", i, level.maptime - bmStart[i], bmRet[i], bm[i].GetRenderStyle(), bm[i].alpha); }
		}
	}

	// THE FIGHT, DRIVEN BY ITS OWN STATE (rt_auto): shield hit -> thrall killed, window MISSED -> thrall killed, segment
	// BROKEN in the window -> every thrall killed -> the miniboss hammered through its lives -> dead
	void RunAuto()
	{
		if (autoStep <= 0) return;
		let mb = Svc("RSQMB_Service");
		if (!mb) return;
		Actor boss; Array<Actor> th;
		let it = ThinkerIterator.Create("Actor"); Actor a;
		while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0)
		{
			if (mb.GetInt("miniboss", "", 0, 0, a) == 1) boss = a;
			else if (mb.GetInt("thrall", "", 0, 0, a) == 1) th.Push(a);
		}
		int now = level.maptime, since = now - autoAt;
		let p = P();
		int segs = boss ? mb.GetInt("segments", "", 0, 0, boss) : -1, win = boss ? mb.GetInt("window", "", 0, 0, boss) : -1;
		int sh = boss ? mb.GetInt("shielded", "", 0, 0, boss) : -1, lives = boss ? mb.GetInt("lives", "", 0, 0, boss) : -1;
		String st = String.Format("boss %s hp %d, %d thralls [%s], segs %d, shielded %d, window %d, lives %d", BN(boss), boss ? boss.health : 0, th.Size(), ThNames(th), segs, sh, win, lives);
		if (autoStep == 1 && boss && segs > 0 && since > 35) { Console.Printf("RTP t%d S1 LANDED: %s", now, st); int h0 = boss.health; boss.DamageMobj(p, p, 40, 'None'); Console.Printf("RTP t%d S1 shield hit 40: hp %d -> %d", now, h0, boss.health); Go(2); }
		else if (autoStep == 2 && since > 20 && th.Size()) { th[0].DamageMobj(p, p, th[0].health + 100, 'None'); Console.Printf("RTP t%d S2 thrall killed, now %s", now, st); Go(3); }
		else if (autoStep == 3 && since > 5 && win <= 0) { Console.Printf("RTP t%d S3 window over unbroken (missed): %s", now, st); Go(4); }
		else if (autoStep == 4 && since > 70) { Console.Printf("RTP t%d S4 after the miss: %s", now, st); if (th.Size()) { th[0].DamageMobj(p, p, th[0].health + 100, 'None'); Go(5); } else Go(6); }
		else if (autoStep == 5 && since > 3 && win > 0) { int s0 = segs; boss.DamageMobj(p, p, 2000, 'None'); Console.Printf("RTP t%d S5 hit in the window: segs %d -> %d, %s", now, s0, mb.GetInt("segments", "", 0, 0, boss), st); Go(6); }
		else if (autoStep == 6 && since > 60) { Console.Printf("RTP t%d S6 kill every thrall: %s", now, st); for (int i = 0; i < th.Size(); i++) th[i].DamageMobj(p, p, th[i].health + 100, 'None'); Go(7); }
		else if (autoStep == 7 && since > 10)
		{
			if (!boss) { Console.Printf("RTP t%d S7 MINIBOSS DEAD", now); Go(8); return; }
			if (since % 12 == 0)
			{
				int h0 = boss.health, l0 = lives;
				boss.DamageMobj(p, p, 2000, 'None');
				Console.Printf("RTP t%d S7 hammer: hp %d -> %d, lives %d, segs %d, %d thralls", now, h0, boss ? boss.health : 0, l0, segs, th.Size());
			}
		}
		else if (autoStep == 8 && since > 70) { Console.Printf("RTP t%d S8 DONE", now); autoStep = 0; }
	}
	void Go(int s) { autoStep = s; autoAt = level.maptime; }
	static String ThNames(Array<Actor> th) { String s = ""; for (int i = 0; i < th.Size(); i++) s = s .. (i ? "," : "") .. th[i].GetClassName(); return s; }
}
