// TEST ONLY -- never shipped (test/build_test.sh). Spawns a row of monsters at set health, logs
// every bar, draws a frame id into the eye, answers as a fake series marker service, benchmarks.
class RSQTHPT_Probe : EventHandler
{
	Array<Actor> row;
	int setupAt;
	int tumbleT;
	Vector3 tumbleFrom;

	static RSQTHPT_Probe Get() { return RSQTHPT_Probe(EventHandler.Find("RSQTHPT_Probe")); }
	static clearscope int CI(Name n) { let c = CVar.FindCVar(n); return c ? c.GetInt() : 0; }
	static clearscope double CF(Name n) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : 0; }
	static clearscope String CS(Name n) { let c = CVar.FindCVar(n); return c ? c.GetString() : ""; }

	override void WorldLoaded(WorldEvent e)
	{
		// a thinker ticked after every actor (statnum 120 > STAT_DEFAULT 100): sees bars where they are drawn
		let l = new("RSQTHPT_Late");
		l.ChangeStatNum(120);
	}

	override void WorldTick()
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo) return;
		int t = level.maptime;
		int at = CI('thpt_at');
		if (t == at) SpawnRow(pmo);
		if (t == at + 2) Hurt();
		if (t == at + 4) Overheal();
		if (t == at + 6 && CI('thpt_hold')) for (int i = 0; i < row.Size(); i++) if (row[i] && row[i].health > 0) row[i].Deactivate(null);
		int h0 = CI('thpt_hurt'), hn = max(1, CI('thpt_hurtn')), hg = max(1, CI('thpt_hurtgap'));
		bool hurtNow = h0 > 0 && t >= h0 && (t - h0) % hg == 0 && (t - h0) / hg < hn;
		if (hurtNow) for (int i = 0; i < row.Size(); i++) if (row[i] && row[i].health > 0)
		{
			bool d = row[i].bDormant;
			row[i].bDormant = false;
			int amt = CI('thpt_hurtamt');
			row[i].DamageMobj(null, null, amt > 0 ? amt : max(1, row[i].SpawnHealth() / 10), 'None', DMG_NO_PAIN);
			row[i].bDormant = d;
			Console.Printf("THPT_HURT t%d %d %s hp %d/%d", t, i, row[i].GetClassName(), row[i].health, row[i].SpawnHealth());
		}
		Tumble();
		int lg = CI('thpt_log');
		if (lg > 0 && t % lg == 0) LogBars();
		if (row.Size() <= 12 && CI('thpt_logrow') > 0 && t % CI('thpt_logrow') == 0)
			for (int i = 0; i < row.Size(); i++) if (row[i])
				Console.Printf("THPT_ROW t%d %d %s hp %d/%d start %d scale %.2f style %d alpha %.2f bob %d", t, i, row[i].GetClassName(), row[i].health, row[i].SpawnHealth(), row[i].StartHealth, row[i].Scale.Y, row[i].GetRenderStyle(), row[i].Alpha, row[i].bFloatBob);
		if (CI('thpt_bench') == t) Bench();
		if (CI('thpt_census') == t) Census();
		if (CI('thpt_svclog') > 0 && t % CI('thpt_svclog') == 0) SvcLog();
	}

	void SpawnRow(PlayerPawn pmo)
	{
		Array<String> cls, pcts;
		CS('thpt_cls').Split(cls, ",");
		CS('thpt_pcts').Split(pcts, ",");
		double d = CF('thpt_dist'), gap = CF('thpt_gap');
		int n = pcts.Size();
		int rows = max(1, CI('thpt_rows'));
		for (int i = 0; i < n * rows; i++)
		{
			int col = i % n, rw = i / n;
			double side = (col - (n - 1) / 2.0) * gap;
			Vector3 sp = pmo.Vec3Angle(d + rw * gap, pmo.angle) + (cos(pmo.angle - 90), sin(pmo.angle - 90), 0) * side;
			class<Actor> c = cls[i % cls.Size()];
			let a = Actor.Spawn(c, sp, ALLOW_REPLACE);
			if (a) { a.angle = pmo.angle + 180; a.SetZ(a.floorz); }
			row.Push(a);
			if (rows == 1) Console.Printf("THPT_SPAWN %d %s at (%.0f %.0f %.0f) spawnhp %d", i, a ? a.GetClassName() : 'null', sp.x, sp.y, sp.z, a ? a.SpawnHealth() : 0);
		}
		Array<String> ld;
		CS('thpt_ld').Split(ld, ",", TOK_SKIPEMPTY);
		for (int k = 0; k < ld.Size(); k++)
		{
			int i = ld[k].ToInt();
			if (i < 0 || i >= row.Size() || !row[i]) continue;
			String pk = "LDLegendaryMonsterPickupGuaranteed";
			class<Inventory> pc = pk;
			if (pc) row[i].GiveInventory(pc, 1);
			Console.Printf("THPT_LD %d %s given %s (class %s)", i, row[i].GetClassName(), pk, pc ? "found" : "MISSING");
		}
	}

	void Hurt()
	{
		Array<String> pcts;
		CS('thpt_pcts').Split(pcts, ",");
		for (int i = 0; i < row.Size(); i++)
		{
			let a = row[i];
			if (!a) continue;
			int want = int(a.SpawnHealth() * pcts[i % pcts.Size()].ToDouble() / 100);
			if (want < a.health && want > 0) a.DamageMobj(null, null, a.health - want, 'None', DMG_NO_PAIN);
			if (row.Size() <= 12) Console.Printf("THPT_HURT0 %d %s hp %d/%d", i, a.GetClassName(), a.health, a.SpawnHealth());
		}
	}

	// above spawn health WITHOUT a damage event, the way LegenDoom Lite's ACS does it
	void Overheal()
	{
		Array<String> pcts;
		CS('thpt_pcts').Split(pcts, ",");
		for (int i = 0; i < row.Size(); i++)
		{
			let a = row[i];
			if (!a) continue;
			int want = int(a.SpawnHealth() * pcts[i % pcts.Size()].ToDouble() / 100);
			if (want > a.SpawnHealth()) { a.health = want; Console.Printf("THPT_OVER %d %s hp %d/%d", i, a.GetClassName(), a.health, a.SpawnHealth()); }
		}
	}

	// a monster carried along an arc and rolled, the way RSQ_Grapple's yank moves it (in WorldTick)
	void Tumble()
	{
		int ti = CI('thpt_tumble');
		if (ti < 0 || ti >= row.Size() || !row[ti]) return;
		let a = row[ti];
		int at = CI('thpt_at') + 20;
		int t = level.maptime - at;
		if (t < 0 || t > 70) return;
		if (t == 0) { tumbleFrom = a.Pos; a.bRollSprite = true; a.bRollCenter = true; a.bNoGravity = true; }
		double u = t / 70.0;
		Vector3 np = tumbleFrom + (0, 0, sin(u * 180) * 96);
		np.xy = tumbleFrom.xy + (cos(a.angle), sin(a.angle)) * u * 96;
		a.SetOrigin(np, true);
		if (CI('thpt_tumblepitch')) a.Pitch = t * 360.0 / 35.0; else a.Roll = t * 360.0 / 35.0;
		if (t == 70) { a.Roll = 0; a.Pitch = 0; a.bRollSprite = false; a.bNoGravity = false; }
	}

	void LogBars()
	{
		let h = RSQTHP_Handler.Get();
		if (!h) return;
		for (int i = 0; i < h.bars.Size(); i++)
		{
			let b = h.bars[i];
			if (!b || !b.who) continue;
			let w = b.who;
			String ov = b.over ? String.Format("%s%c", SprName(h, b.over.sprite), 65 + b.over.frame) : "-";
			String mk = b.mark ? String.Format("%s%c", SprName(h, b.mark.sprite), 65 + b.mark.frame) : "-";
			Console.Printf("THPT_BAR t%d %s hp %d/%d bar %s%c over %s mark %s dz %.2f top %.2f tgt %.2f dxy %.3f prevdz %.2f roll %.0f sc %.3f a %.2f st %d inv %d br %d",
				level.maptime, w.GetClassName(), w.health, w.SpawnHealth(), SprName(h, b.sprite), 65 + b.frame, ov, mk,
				b.Pos.z - w.Pos.z, b.top, b.topTarget, (b.Pos.xy - w.Pos.xy).Length(), b.Prev.z - w.Prev.z, w.Roll, b.Scale.X, b.Alpha, b.GetRenderStyle(), b.bInvisible, b.bBright);
		}
		// coldcite's own bars and items, if his pk3 is loaded (by name: this probe does not link to him)
		int cb = 0, ci = 0;
		String n1 = "Z_TopHP", n2 = "Z_MyTopHP";
		class<Thinker> cbc = n1;
		if (cbc) { let it = ThinkerIterator.Create(cbc); while (it.Next()) cb++; }
		class<Thinker> cic = n2;
		if (cic) { let it = ThinkerIterator.Create(cic, Thinker.STAT_INVENTORY); while (it.Next()) ci++; }
		let pl = players[consoleplayer];
		if (CI('thpt_hands')) Console.Printf("THPT_HANDS t%d ready %s off %s pending %s buttons %x", level.maptime,
			pl.ReadyWeapon ? pl.ReadyWeapon.GetClassName() : 'none', pl.OffhandWeapon ? pl.OffhandWeapon.GetClassName() : 'none',
			pl.PendingWeapon && pl.PendingWeapon != WP_NOCHANGE ? pl.PendingWeapon.GetClassName() : 'none', pl.cmd.buttons);
		if (CI('thpt_hands') && pl.mo) Console.Printf("THPT_HANDS2 force %d angle %.1f pos (%.0f %.0f)", Has(pl.mo, "UBQS_Force"), pl.mo.angle, pl.mo.pos.x, pl.mo.pos.y);
		Console.Printf("THPT_COUNT t%d bars %d tracked %d spawned %d scheme %d set %d | coldcite bars %d items %d", level.maptime, h.bars.Size(), h.mons.Size(), h.spawnedBars, h.scheme, h.set, cb, ci);
	}

	static String SprName(RSQTHP_Handler h, int spr)
	{
		static const String mains[] = { "RSYA", "RSYB", "RSYC", "RSYD", "RSYE" };
		for (int s = 0; s < 5; s++)
		{
			if (h.sprMain[s] == spr) return mains[s];
			for (int p = 0; p < 5; p++) if (h.sprOver[s * 5 + p] == spr) return String.Format("RS%d%d", s + 1, p);
		}
		if (h.sprMark == spr) return "RSYZ";
		return String.Format("?%d", spr);
	}

	static int Has(Actor a, String cn) { class<Inventory> c = cn; return (c && a.FindInventory(c)) ? 1 : 0; }

	// every monster on the map: health against spawn health, StartHealth, and whether it has a bar
	void Census()
	{
		let h = RSQTHP_Handler.Get();
		int over = 0, full = 0, hurt = 0, withBar = 0, overBar = 0, n = 0;
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (!a.bIsMonster || a.health <= 0) continue;
			n++;
			int sh = a.SpawnHealth();
			bool hasBar = false, hasOver = false;
			if (h) for (int i = 0; i < h.bars.Size(); i++) if (h.bars[i] && h.bars[i].who == a) { hasBar = true; hasOver = h.bars[i].over != null; }
			if (a.health > sh) over++; else if (a.health == sh) full++; else hurt++;
			if (hasBar) withBar++;
			if (hasOver) overBar++;
			if (a.health != sh && n <= 40)
				Console.Printf("THPT_MON %s hp %d/%d start %d bar %d overstrip %d champ %d legend %d", a.GetClassName(), a.health, sh, a.StartHealth, hasBar, hasOver,
					Has(a, "champion_PersistentInfo"), Has(a, "LDLegendaryMonsterToken"));
		}
		Console.Printf("THPT_CENSUS t%d monsters %d | over spawn %d, at spawn %d, below %d | with bar %d, with overheal strip %d", level.maptime, n, over, full, hurt, withBar, overBar);
	}

	// what the series' services answer about the row, straight from them (by name)
	void SvcLog()
	{
		static const String names[] = { "RSQGR_Service", "SSQ_ScoreService", "UBQS_SaberService" };
		static const String reqs[] = { "hooked", "yanked", "stunned", "locked", "gripped" };
		String line = String.Format("THPT_SVC t%d", level.maptime);
		for (int i = 0; i < row.Size(); i++)
		{
			if (!row[i]) continue;
			line = line .. String.Format(" | %d:", i);
			for (int r = 0; r < reqs.Size(); r++)
			{
				int best = -1;
				for (int n = 0; n < names.Size(); n++)
				{
					let it = ServiceIterator.Find(names[n]);
					Service sv;
					while (sv = it.Next()) best = max(best, sv.GetInt(reqs[r], "", 0, 0, row[i]));
				}
				line = line .. String.Format(" %s=%d", reqs[r], best);
			}
		}
		Console.Printf("%s", line);
	}

	void Bench()
	{
		let h = RSQTHP_Handler.Get();
		if (!h) return;
		int nb = 0;
		for (int i = 0; i < h.bars.Size(); i++) if (h.bars[i]) nb++;
		int N = 2000;
		double t0 = MSTimeF();
		for (int r = 0; r < N; r++)
			for (int i = 0; i < h.bars.Size(); i++) if (h.bars[i]) h.bars[i].Update();
		double t1 = MSTimeF();
		// the changing path: health differs every call (frame rebuilt every time)
		for (int r = 0; r < N; r++)
			for (int i = 0; i < h.bars.Size(); i++) if (h.bars[i]) { h.bars[i].built = false; h.bars[i].haveTop = false; h.bars[i].Update(); }
		double t2 = MSTimeF();
		// the handler's per-tic work (settings + poll)
		for (int r = 0; r < N; r++) h.WorldTick();
		double t3 = MSTimeF();
		Console.Printf("THPT_BENCH bars %d tracked %d | steady %.3f us/bar-tic | rebuild %.3f us/bar | handler tick %.3f us (%d tracked)",
			nb, h.mons.Size(), (t1 - t0) * 1000.0 / (N * max(1, nb)), (t2 - t1) * 1000.0 / (N * max(1, nb)), (t3 - t2) * 1000.0 / N, h.mons.Size());
	}

	int IndexOf(Actor a) { return row.Find(a) < row.Size() ? row.Find(a) : -1; }

	override void RenderOverlay(RenderEvent e)
	{
		int shot = CI('thpt_shot');
		if (shot <= 0) return;
		int w = Screen.GetWidth();
		int bs = max(4, w / 50);
		for (int b = 0; b < 8; b++)
			Screen.Dim((shot & (1 << b)) ? Color(255, 255, 0, 255) : Color(255, 0, 0, 0), 1.0, b * bs, 0, bs, bs);
	}
}

// AFTER EVERY ACTOR HAS TICKED (what the renderer will draw): the bar's offset from its thing in
// the plane, and whether its previous position (interpolation start) is the thing's previous one.
class RSQTHPT_Late : Thinker
{
	override void Tick()
	{
		int lg = RSQTHPT_Probe.CI('thpt_late');
		if (lg <= 0 || level.maptime % lg) return;
		let h = RSQTHP_Handler.Get();
		if (!h) return;
		double maxXY = 0, maxPrevXY = 0, maxMove = 0; int n = 0;
		String who = "";
		for (int i = 0; i < h.bars.Size(); i++)
		{
			let b = h.bars[i];
			if (!b || !b.who) continue;
			n++;
			double dxy = (b.Pos.xy - b.who.Pos.xy).Length();
			double pxy = (b.Prev.xy - b.who.Prev.xy).Length();
			double dzerr = abs((b.Pos.z - b.who.Pos.z) - (b.Prev.z - b.who.Prev.z));
			double mv = (b.who.Pos - b.who.Prev).Length();
			if (mv > maxMove) { maxMove = mv; who = b.who.GetClassName(); }
			maxXY = max(maxXY, dxy); maxPrevXY = max(maxPrevXY, max(pxy, dzerr));
		}
		Console.Printf("THPT_LATE t%d bars %d | max |bar-thing| xy %.4f | max prev mismatch %.4f | fastest thing moved %.2f this tic (%s)", level.maptime, n, maxXY, maxPrevXY, maxMove, who);
	}
}

// the series' marker contract, answered for the test (class name contains "RSQTHP_Marker")
class RSQTHP_MarkerTestService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		int m = RSQTHPT_Probe.CI('thpt_mark');
		if (m == 0) return -1;
		let p = RSQTHPT_Probe.Get();
		if (!p) return -1;
		int i = p.IndexOf(Actor(objectArg));
		if (i < 0) return -1;
		int bits = m < 0 ? ((i + 1) & 15) : m;
		int want = request == "hooked" ? 1 : request == "stunned" ? 2 : request == "locked" ? 4 : request == "gripped" ? 8 : 0;
		return (bits & want) ? 1 : -1;
	}
}
