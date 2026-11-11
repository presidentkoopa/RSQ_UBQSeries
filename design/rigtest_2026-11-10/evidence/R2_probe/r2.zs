// TEST ONLY (scratch, rig batch R2, 2026-11-11). Readouts and setters by name; changes nothing in the mods.
class R2_Probe : EventHandler
{
	PlayerPawn P() { return players[consoleplayer].mo; }
	static Service Svc(String n) { let it = ServiceIterator.Find(n); Service s; while (s = it.Next()) if (s.GetClassName() == n) return s; return null; }
	static const String CN[] = { "-", "Common", "Green", "Blue", "Purple", "Cyan", "Brown", "Yellow", "FireBlu", "Gray", "Red", "Abyss", "Black", "White" };

	// a point in the pawn's frame: forward, left, up (map units)
	String Rel(Vector3 v)
	{
		let p = P();
		if (!p) return "?";
		Vector3 d = level.Vec3Diff(p.pos, v);
		double c = cos(p.angle), s = sin(p.angle);
		return String.Format("(f %.1f l %.1f u %.1f)", d.x * c + d.y * s, -d.x * s + d.y * c, d.z);
	}

	// ---------------------------------------------------------------- the ladder: gems, the line, Score rows
	bool gems;
	int gemLines;
	Array<Actor> gemSeen;
	Array<String> gemCls; Array<int> gemCnt;
	Array<Actor> line;
	int rowsAt; Array<int> rowsWas; String rowsWho;

	int TierOf(Actor a) { let mn = Svc("RSQMN_RosterService"); return mn && a ? mn.GetInt("tier", "", 0, 0, a) : -9; }
	String Word(int t) { return (t >= 1 && t <= 13) ? CN[t] : "?"; }
	bool NameFits(Actor a, int t)
	{
		if (t < 1 || t > 13) return false;
		String n = a.GetClassName(); n = n.MakeLower();
		String w = CN[t]; w = w.MakeLower();
		if (t == 9 && n.IndexOf("grey") >= 0) return true;
		return n.IndexOf(w) >= 0;
	}

	void GemTick()
	{
		let it = ThinkerIterator.Create("RS_ColorTierIconCH");
		Actor g;
		while (g = Actor(it.Next()))
		{
			if (gemSeen.Find(g) < gemSeen.Size()) continue;
			if (g.sprite != Actor.GetSpriteIndex('TI3R')) continue;
			gemSeen.Push(g);
			String gc = g.GetClassName();
			int k = gemCls.Find(gc);
			if (k == gemCls.Size()) { gemCls.Push(gc); gemCnt.Push(0); }
			if (gemCnt[k] >= 2 || gemLines >= 60) continue;
			gemCnt[k]++; gemLines++;
			// the monster it came from: the nearest living monster (it is spawned 32 up, and flies ~1-4 a tic)
			let bi = ThinkerIterator.Create("Actor"); Actor a, best; double bd = 160;
			while (a = Actor(bi.Next())) if (a.bIsMonster && a.health > 0) { double d = a.Distance2D(g); if (d < bd) { bd = d; best = a; } }
			int fr = g.frame;
			int t = TierOf(best);
			Console.Printf("R2 GEM t%d %s frame %c (gem tier %d %s) from %s tier %d %s: %s", level.maptime, gc, 65 + fr, fr + 1, Word(fr + 1),
				best ? String.Format("%s", best.GetClassName()) : "none", t, Word(t), best && fr + 1 == t ? "MATCH" : "MISMATCH");
		}
	}

	void Scan(int tag)
	{
		let it = ThinkerIterator.Create("Actor"); Actor a;
		int n = 0, bad = 0;
		while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0)
		{
			int t = TierOf(a);
			bool ok = NameFits(a, t);
			let mn = Svc("RSQMN_RosterService");
			int ex = mn ? mn.GetInt("ex", "", 0, 0, a) : -9;
			n++; if (!ok) bad++;
			Console.Printf("R2 MON tag %d %s tier %d %s%s %s", tag, a.GetClassName(), t, Word(t), ex == 1 ? " EX" : "", ok ? "name fits" : "NAME DOES NOT FIT");
		}
		Console.Printf("R2 MONSUM tag %d t%d: %d monsters, %d whose class name is not their tier's colour", tag, level.maptime, n, bad);
	}

	void SpawnLine(int fam)
	{
		let p = P();
		line.Clear();
		for (int t = 1; t <= 13; t++)
		{
			Name cn = RS_TierLadder.ClassFor(fam, t);
			double side = (t - 7) * 40.0;
			Vector3 at = p.Vec3Offset(cos(p.angle) * 320 - sin(p.angle) * side, sin(p.angle) * 320 + cos(p.angle) * side, 0);
			let a = Actor.Spawn(cn, at, NO_REPLACE);
			if (a) { a.angle = a.AngleTo(p); a.ReactionTime = 9999; }
			line.Push(a);
			Console.Printf("R2 LINE spawn tier %d (%s): %s -> %s", t, Word(t), cn, a ? String.Format("%s", a.GetClassName()) : "none");
		}
	}

	void LineTiers()
	{
		for (int i = 0; i < line.Size(); i++)
		{
			let a = line[i];
			if (!a) { Console.Printf("R2 LINETIER %d gone", i + 1); continue; }
			int t = TierOf(a);
			Console.Printf("R2 LINETIER asked %d %s: %s reads tier %d %s: %s", i + 1, Word(i + 1), a.GetClassName(), t, Word(t), t == i + 1 ? "OK" : "WRONG");
		}
	}

	RS_ScoreTracker Tracker() { let p = P(); return p ? RS_ScoreTracker(p.FindInventory("RS_ScoreTracker")) : null; }

	void KillOne(int i)
	{
		let p = P();
		if (i < 1 || i > line.Size() || !line[i - 1] || line[i - 1].health <= 0) { Console.Printf("R2 KILL %d: none", i); return; }
		let a = line[i - 1];
		let tr = Tracker();
		rowsWas.Clear();
		if (tr) for (int k = 0; k < tr.rowValue.Size(); k++) rowsWas.Push(tr.rowTic[k] > 0 ? tr.rowValue[k] : 0);
		rowsWho = String.Format("%s tier %d %s", a.GetClassName(), TierOf(a), Word(TierOf(a)));
		Console.Printf("R2 KILL t%d line %d: %s", level.maptime, i, rowsWho);
		a.DamageMobj(p, p, a.health + 100, 'None', DMG_FORCED);
		rowsAt = level.maptime + 2;
	}

	void RowsTick()
	{
		if (rowsAt <= 0 || level.maptime < rowsAt) return;
		rowsAt = 0;
		let tr = Tracker();
		let sh = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
		if (!tr || !sh) { Console.Printf("R2 ROWS no tracker/handler"); return; }
		String s = "", tiers = "";
		for (int k = 0; k < tr.rowValue.Size() && k < sh.rowName.Size(); k++)
		{
			int was = k < rowsWas.Size() ? rowsWas[k] : 0;
			int now = tr.rowTic[k] > 0 ? tr.rowValue[k] : 0;
			if (now > was)
			{
				s = s .. String.Format("[%s +%d] ", sh.rowName[k], now - was);
				if (sh.rowName[k].IndexOf(" Tier") >= 0) tiers = tiers .. sh.rowName[k] .. " ";
			}
		}
		Console.Printf("R2 ROWS t%d kill of %s: tier row(s) paid: %s| all rows: %s", level.maptime, rowsWho, tiers == "" ? "none " : tiers, s == "" ? "none" : s);
	}

	// ---------------------------------------------------------------- Miniboss (MB_TIER2 probe readouts)
	void MbScan(int tag)
	{
		let mb = Svc("RSQMB_Service");
		let it = ThinkerIterator.Create("Actor"); Actor a;
		String bs = "", ts = "";
		int nt = 0;
		while (a = Actor(it.Next())) if (a.bIsMonster && a.health > 0 && a.FindInventory("RSQMB_Called"))
		{
			bool isB = mb && mb.GetInt("miniboss", "", 0, 0, a) == 1;
			int t = TierOf(a);
			let mn = Svc("RSQMN_RosterService");
			int ex = mn ? mn.GetInt("ex", "", 0, 0, a) : -9;
			String one = String.Format("%s(tier %d %s%s, hp %d)", a.GetClassName(), t, Word(t), ex == 1 ? " EX" : "", a.health);
			if (isB) bs = bs .. one .. " "; else { ts = ts .. one .. " "; nt++; }
		}
		Console.Printf("R2 MBSCAN t%d tag %d: MINIBOSS %s| %d thralls: %s", level.maptime, tag, bs == "" ? "none " : bs, nt, ts);
	}

	Actor Miniboss()
	{
		let mb = Svc("RSQMB_Service");
		let it = ThinkerIterator.Create("Actor"); Actor a;
		while (mb && (a = Actor(it.Next()))) if (a.bIsMonster && a.health > 0 && mb.GetInt("miniboss", "", 0, 0, a) == 1) return a;
		return null;
	}

	// ---------------------------------------------------------------- shots (DOWN) and the buzz
	int shotUntil, shotLines;
	int lastShots;
	bool lsLog; String lsWas;
	bool handsLog;

	void Where(int tag)
	{
		let p = P();
		Vector3 m; bool ok;
		[m, ok] = RSQ_Muzzle.Where(p);
		let dn = RSQSM_Down.Get();
		Console.Printf("R2 WHERE t%d tag %d DOWN %d viewz-floor %.1f ViewHeight %.1f default %.1f | hand AttackPos %s | muzzle Where %s%s | off hand %s | angle %.1f AttackAngle %.1f",
			level.maptime, tag, dn ? dn.IsDown(p.PlayerNumber()) : -1, p.player.viewz - p.pos.z, p.ViewHeight, p.Default.ViewHeight,
			Rel(p.AttackPos), Rel(m), ok ? "" : " (guard: the hand)", Rel(p.OffhandPos), p.angle, p.AttackAngle);
	}

	void Holsters(int tag)
	{
		let p = P();
		let rig = RSQTR_Rig.Get();
		if (!rig) { Console.Printf("R2 HOLSTER no rig"); return; }
		String s = "";
		static const int R[] = { 0, 1, 3, 4, 5, 6, 7, 12, 13 };
		for (int i = 0; i < R.Size(); i++) s = s .. String.Format("%s %s; ", RSQTR_Region.NAMES[R[i]], Rel(rig.RegionAt(p, R[i])));
		Console.Printf("R2 HOLSTER t%d tag %d RoomFloor-pawn %.1f | main hand %s off hand %s | %s", level.maptime, tag, RSQTR_Body.RoomFloor(p) - p.pos.z, Rel(p.AttackPos), Rel(p.OffhandPos), s);
	}

	override bool WorldHitscanPreFired(WorldEvent e)
	{
		if (e.Thing && e.Thing.player && (shotUntil > level.maptime || e.AttackDistance < 1))
			Console.Printf("R2 PREFIRED t%d dist %.1f dmg %d flags %X puff %s from %s", level.maptime, e.AttackDistance, e.Damage, e.AttackLineFlags,
				e.AttackPuffType ? String.Format("%s", e.AttackPuffType.GetClassName()) : "none", Rel(e.AttackPos));
		return false;
	}
	override void WorldHitscanFired(WorldEvent e)
	{
		if (e.Thing && e.Thing.player && shotUntil > level.maptime && shotLines++ < 30)
			Console.Printf("R2 FIRED t%d (SlowMo trail start) AttackPos %s to %s flags %X", level.maptime, Rel(e.AttackPos), Rel(e.DamagePosition), e.AttackLineFlags);
	}
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		if (a is "RSQ_Flash") Console.Printf("R2 FLASH t%d at %s", level.maptime, Rel(a.pos));
		if (shotUntil > level.maptime && shotLines < 30)
		{
			String n = a.GetClassName();
			bool mine = a.target && a.target.player;
			if (mine || n.IndexOf("Tracer") >= 0 || n.IndexOf("Round") >= 0)
			{
				shotLines++;
				Console.Printf("R2 SPAWN t%d %s at %s vel (%.1f %.1f %.1f)%s", level.maptime, n, Rel(a.pos), a.vel.x, a.vel.y, a.vel.z, mine ? " (player's)" : "");
			}
		}
	}

	// ---------------------------------------------------------------- per tic
	override void WorldTick()
	{
		let p = P();
		if (!p) return;
		if (gems) GemTick();
		RowsTick();
		let rc = RSQ_Recoil(EventHandler.Find("RSQ_Recoil"));
		if (rc && rc.shots[0] != lastShots) { Console.Printf("R2 KICK t%d recoil shots %d -> %d", level.maptime, lastShots, rc.shots[0]); lastShots = rc.shots[0]; }
		if (lsLog)
		{
			static const int L[] = { 2140, 2141, 1000140, 1000141 };
			String s = "";
			for (int i = 0; i < L.Size(); i++)
			{
				let ps = p.player.FindPSprite(L[i]);
				s = s .. String.Format("%d=%s ", L[i], ps && ps.CurState ? "1" : "0");
			}
			s = s .. String.Format("| inspect main %d off %d", RSQLS_Sight.WatchCheck(p, 0), RSQLS_Sight.WatchCheck(p, 1));
			if (s != lsWas) { Console.Printf("R2 LASER t%d %s", level.maptime, s); lsWas = s; }
		}
		if (handsLog && level.maptime % 35 == 0) Hands();
	}

	void Hands()
	{
		let p = P();
		let pl = p.player;
		let h = p.FindInventory("RSQ_Hands");
		String ps = "";
		for (let s = pl.psprites; s; s = s.Next)
			ps = ps .. String.Format("%d:%s:%s ", s.ID, s.Caller ? String.Format("%s", s.Caller.GetClassName()) : "-", s.CurState ? (s.bInvisible ? "inv" : "on") : "-");
		Console.Printf("R2 HANDS t%d ready %s off %s pending %s | RSQ_Hands item %d, Shown %d (rsq_hands %d, InVR %d), HandTable.Index(ready) %d | layers %s",
			level.maptime, pl.ReadyWeapon ? String.Format("%s", pl.ReadyWeapon.GetClassName()) : "none",
			pl.OffhandWeapon ? String.Format("%s", pl.OffhandWeapon.GetClassName()) : "none",
			pl.PendingWeapon == WP_NOCHANGE ? "NOCHANGE" : (pl.PendingWeapon ? String.Format("%s", pl.PendingWeapon.GetClassName()) : "null"),
			h != null, RSQ_Hands.Shown(p), CVar.GetCVar("rsq_hands", pl) ? CVar.GetCVar("rsq_hands", pl).GetInt() : -1, RSVR_VRHand.InVR(p),
			RSQ_HandTable.Index(pl.ReadyWeapon), ps);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		let p = P();
		if (!p) return;
		String n = e.Name;
		if (n ~== "r2_gems") { gems = e.Args[0] != 0; Console.Printf("R2 GEMS %d", gems); }
		else if (n ~== "r2_scan") Scan(e.Args[0]);
		else if (n ~== "r2_line") SpawnLine(e.Args[0]);
		else if (n ~== "r2_linetiers") LineTiers();
		else if (n ~== "r2_kill") KillOne(e.Args[0]);
		else if (n ~== "r2_mbscan") MbScan(e.Args[0]);
		else if (n ~== "r2_mbhp")    // the miniboss to 1 hp: its life bar empties (boss.zs Step: lives > 1 && health <= 1)
		{
			let a = Miniboss();
			if (a) { Console.Printf("R2 MBHP t%d %s tier %d %s hp %d -> 1", level.maptime, a.GetClassName(), TierOf(a), Word(TierOf(a)), a.health); a.health = 1; }
			else Console.Printf("R2 MBHP t%d: no miniboss", level.maptime);
		}
		else if (n ~== "r2_killthrall")
		{
			let mb = Svc("RSQMB_Service");
			let it = ThinkerIterator.Create("Actor"); Actor a;
			while (mb && (a = Actor(it.Next()))) if (a.bIsMonster && a.health > 0 && a.FindInventory("RSQMB_Called") && mb.GetInt("miniboss", "", 0, 0, a) != 1)
			{ Console.Printf("R2 KILLTHRALL t%d %s tier %d", level.maptime, a.GetClassName(), TierOf(a)); a.DamageMobj(p, p, a.health + 100, 'None', DMG_FORCED); break; }
		}
		else if (n ~== "r2_shots") { shotUntil = level.maptime + max(1, e.Args[0]); shotLines = 0; Console.Printf("R2 SHOTS t%d logging %d tics", level.maptime, e.Args[0]); Where(e.Args[1]); }
		else if (n ~== "r2_where") Where(e.Args[0]);
		else if (n ~== "r2_holsters") Holsters(e.Args[0]);
		else if (n ~== "r2_lslog") { lsLog = e.Args[0] != 0; lsWas = ""; }
		else if (n ~== "r2_hands") { handsLog = e.Args[0] != 0; Hands(); }
		else if (n ~== "r2_buzz")    // one RSQ Accessibility buzz on the main hand, by its own route
		{
			bool went = RSQA_Buzz.Backup(p, false, "R2probe", false);
			Console.Printf("R2 BUZZ t%d RSQA_Buzz.Backup -> %d", level.maptime, went);
		}
		else if (n ~== "r2_plv" || n ~== "r2_wlv")
		{
			let st = TFLV_PerPlayerStats.GetStatsFor(p);
			if (!st) { Console.Printf("R2 LV no stats"); return; }
			if (n ~== "r2_plv") { st.level = e.Args[0]; Console.Printf("R2 PLV player level %d", st.level); }
			else { let info = st.CreateInfoForHand(e.Args[0]); if (info) { info.level = e.Args[1]; Console.Printf("R2 WLV hand %d %s level %d", e.Args[0], info.wpn ? info.wpn.GetClassName() : 'none', info.level); } }
		}
	}
}
