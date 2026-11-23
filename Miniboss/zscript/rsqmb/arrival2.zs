// ============================================================================
// RSQ_Miniboss -- THE ARRIVAL, AROUND YOU (design/BOSS_REWORK.md section 2, Phase A; owner 2026-11-22 / 11-23). Code only,
// not run (2026-11-23, owner: hold rig checks until we talk). Camping (section 4) is camp.zs, the Big Boss fix (section 9)
// bigfix.zs.
//
// Owner 2026-11-22: "i love the thrall boss idea but they get fucking ganked as soon as they spawn in. something about it
// isn't a challenge." The design's answer (section 0): the threat must come from where he isn't looking.
//
//   ARRIVAL: AROUND YOU (rsqmb_arrival 1, the default; 0 Classic keeps the old arrival exactly as it was)
//     THE STAGE TURN   darkness, siren (the BOSS INCOMING! banner), slow motion and the music, about 3 s (rsqmb_arr_stage;
//                      owner 2026-11-22 23:2x, section 7: "around 3 s, slow motion kept", in place of section 2's 1.5 s).
//     THE THRALLS      land AROUND the player, at his sides and behind (never within rsqmb_arr_front degrees of where he
//                      faces), in a ring rsqmb_arr_ring_min..rsqmb_arr_ring_max out (400-700: owner 2026-11-23 03:58, decided),
//                      one at a time rsqmb_arr_step_min..rsqmb_arr_step_max s apart (0.5-1 s, section 2). Each spot is
//                      traced from the player (no wall between), tested with the Boss fight's own probe (bossfight.zs Fits:
//                      the floor, the ceiling, nothing in the way) and must be in his sight (RingPlan). A slot with no room
//                      tries the angles beside it, then a ring half as near (at least 160), then any angle, then the old
//                      spot beside the Boss PlanArrival found for it; else that thrall does not come.
//     THE MARK         rsqmb_arr_mark s (0.75) before a thrall lands its spot is marked: its own crosshair (the Boss bar's
//                      RSQMBX crosshair for that thrall, as sprites QMXH) flies together on the spot in three copies from far
//                      out, turning a third of a turn as they close, then snaps whole with a white flash and holds until it
//                      lands, in the thralls' ladder colour; a sound plays from the spot as the mark appears (Doom's
//                      misc/spawn, heard from that direction). RSQ SlowMo's own DOWN fly-in (SlowMo plate.zs Crosshair) is
//                      the model; it is drawn only for SlowMo's DOWN targets and cannot be asked for a world spot from
//                      outside without changing RSQ SlowMo, so this is Miniboss's own copy of the look (RSQMB_LandMark).
//                      Photosensitive Mode (RSQ Accessibility): no fly-in and no flash, the crosshair shown steady.
//     LIVE AT ONCE     a thrall fights the moment its beam reveals it: no hold, no invulnerable charge (Reveal -> RevealLive).
//     THE BOSS         lands in front as before (PlanArrival's spot), after the last thrall; only the Boss keeps a short
//                      invulnerable landing, rsqmb_arr_bossinv s (1.5) from its bind (boss.zs ChargeStart, bossOnly).
//     HOW MANY         until Rank exists (section 1, Phase C): Thralls (rsqmb_thralls, 3) at the fight's tier 0 up to
//                      Thralls + 3 at tier 4 (bossfight.zs Tier: read from RSQ Monsters' World Tier), so 3 to 6 by default.
//                      Classic keeps its own roll (Thralls to Thralls + 2).
//     KILLED EARLY     a thrall killed before the Boss has landed is bound as a thrall already dead (BindDead): the Boss's
//                      damage cut counts it as killed, and the fight is not called off for lack of thralls.
// ============================================================================

// THE LANDING MARK: one thrall's crosshair flying together on its landing spot (see above). Driven by its own Tick, from
// the tic it was made: no handler state, so a save mid-arrival keeps it going.
class RSQMB_LandMark : Actor
{
	const FLY_OUT = 4.0;          // the copies start this many crosshair sizes out
	const FLASH = 3;              // tics of white at the snap
	const FADE = 6;               // tics it fades once its thrall has landed

	Vector3 spot;
	Actor watcher;                // the player who called the fight in (whose view the copies close in across)
	int born, landAt, col, xh;
	double sz;
	bool main, photo;
	RSQMB_LandMark pc[3];

	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTIMEFREEZE
		+BRIGHT
		+ROLLSPRITE
		+ROLLCENTER
		RenderStyle "AddStencil";
		StencilColor "FFFFFF";
		Alpha 0;
		Radius 1;
		Height 1;
	}
	States { Spawn: QMXH A -1; Stop; }

	static RSQMB_LandMark Make(Vector3 at, Actor watcher, int landAt, int col, int xh, double sz)
	{
		let m = RSQMB_LandMark(Actor.Spawn("RSQMB_LandMark", at, NO_REPLACE));
		if (!m) return null;
		m.main = true;
		m.spot = at; m.watcher = watcher; m.born = level.maptime; m.landAt = landAt; m.col = col & 0xFFFFFF;
		m.xh = clamp(xh, 1, 10); m.sz = sz;
		m.photo = RSQMB_A11y.Photo();
		m.frame = m.xh - 1;
		m.SetShade(m.col);
		for (int k = 0; k < 3 && !m.photo; k++)
		{
			let c = RSQMB_LandMark(Actor.Spawn("RSQMB_LandMark", at, NO_REPLACE));
			if (!c) continue;
			c.frame = m.xh - 1;
			c.SetShade(m.col);
			m.pc[k] = c;
		}
		return m;
	}

	override void OnDestroy()
	{
		for (int k = 0; k < 3; k++) if (pc[k]) { pc[k].Destroy(); pc[k] = null; }
		Super.OnDestroy();
	}

	override void Tick()
	{
		if (!main) return;            // a copy: placed by its mark
		int now = level.maptime;
		int age = now - born;
		// its thrall has landed: it fades, then goes
		if (now >= landAt)
		{
			double k = 1.0 - (now - landAt) / double(FADE);
			if (k <= 0) { Destroy(); return; }
			for (int i = 0; i < 3; i++) if (pc[i]) pc[i].Alpha = 0;
			Alpha = 0.9 * k;
			SetShade(col);
			return;
		}
		// the copies close in across the watcher's view: the plane facing him through the spot
		Vector3 eye = watcher ? watcher.pos + (0, 0, watcher.player ? watcher.player.viewheight : watcher.height * 0.8) : spot - (64, 0, 0);
		Vector3 d = spot - eye;
		double dl = d.Length();
		Vector3 dir = dl > 1 ? d / dl : (1, 0, 0);
		Vector3 rt = (dir.y, -dir.x, 0);
		if (rt.Length() < 0.01) rt = (1, 0, 0);
		rt = rt.Unit();
		Vector3 up = (rt cross dir).Unit();
		int lead = max(1, landAt - born);
		int fly = photo ? 0 : clamp(int(lead * 0.6), 6, 18);
		double scK = sz / 64.0;
		if (age < fly)
		{
			double u01 = age / double(fly), ease = 1.0 - (1.0 - u01) * (1.0 - u01);
			double far = sz * FLY_OUT * (1.0 - ease);
			for (int i = 0; i < 3; i++)
			{
				let c = pc[i];
				if (!c) continue;
				double a = 90.0 + 120.0 * i + 120.0 * (1.0 - ease);
				c.SetOrigin(spot + rt * (cos(a) * far) + up * (sin(a) * far), true);
				c.Scale = (scK * 0.6, scK * 0.6);
				c.roll = 120.0 * (1.0 - ease) + 120.0 * i;
				c.Alpha = 0.35 + 0.5 * ease;
			}
			Alpha = 0;
			return;
		}
		for (int i = 0; i < 3; i++) if (pc[i]) pc[i].Alpha = 0;
		int snap = age - fly;
		bool white = !photo && snap < FLASH;
		SetShade(white ? 0xFFFFFF : col);
		double pop = white ? 1.25 - 0.08 * snap : 1.0;
		Scale = (scK * pop, scK * pop);
		roll = 0;
		// it holds until the thrall lands, breathing (steady in Photosensitive Mode)
		Alpha = photo ? 0.85 : 0.75 + 0.2 * sin(snap * 24.0);
	}
}

extend class RSQMB_Handler
{
	// ---- the settings (CVARINFO.txt; MENUDEF.txt RSQ Boss > Arrival / Big Boss, Test and Debug) ------------------------
	static clearscope bool AroundYouOn() { return CI('rsqmb_arrival', 1) != 0; }
	static double StageSecs() { return clamp(CF('rsqmb_arr_stage', 3.0), 0.0, 5.0); }
	static int BossInvTics() { return max(1, int(clamp(CF('rsqmb_arr_bossinv', 1.5), 0.0, 10.0) * TICRATE)); }
	static int MarkTics() { return int(clamp(CF('rsqmb_arr_mark', 0.75), 0.25, 2.0) * TICRATE); }

	bool arrAround;               // the arrival under way is Around You (set at StartArrival: a menu change mid-landing waits)
	Array<bool> arrMarked;        // its landing mark has been made (Around You)
	int arrMarkLead;              // tics a mark comes before its thrall lands

	// ---- HOW MANY THRALLS (bossfight.zs PlanArrival) ---------------------------------------------------------------------
	// Around You: Thralls at the fight's tier 0 up to Thralls + 3 at tier 4 (section 2,
	// "3 at low rank, up to 6", the tier standing in for Rank until Phase C). Classic: the old roll (owner 11-12 14:24).
	int ThrallWant(int tier, bool big, int tbase)
	{
		if (!AroundYouOn()) return clamp(random[rsqmbbf](tbase + (tier >= 3 ? 1 : 0), tbase + 2), 1, 8);
		return clamp(tbase + int(round(3.0 * clamp(tier, 0, 4) / 4.0)), 1, 8);
	}
	// how many thralls must fit beside the Boss's spot for PlanArrival to take it: none when none are planned or Around You
	// (the ring places them, RingPlan), else half (as before)
	static int ThrallNeed(int n)
	{
		if (n <= 0 || AroundYouOn()) return 0;
		return max(1, (n + 1) / 2);
	}

	// ---- THE RING (PlanArrival, once the Boss's spot is found) -------------------------------------------------------------
	const RING_DZ = 192.0;        // a ring spot's floor at most this far above or below the player's
	const RING_NEAREST = 160.0;   // the nearer ring (a slot with no room at the set one) never closer than this
	void RingPlan(Actor pr, PlayerPawn p, Array<String> tc)
	{
		if (!AroundYouOn() || tc.Size() == 0 || arrX.Size() < 1) return;
		// the spots PlanArrival found beside the Boss: each thrall's last resort
		Array<double> fx, fy, fz;
		Array<String> fc;
		for (int q = 1; q < arrX.Size(); q++) { fx.Push(arrX[q]); fy.Push(arrY[q]); fz.Push(arrZ[q]); fc.Push(arrCls[q]); }
		arrX.Resize(1); arrY.Resize(1); arrZ.Resize(1); arrCls.Resize(1);
		double rmin = max(64.0, CF('rsqmb_arr_ring_min', 400)), rmax = max(rmin + 32, CF('rsqmb_arr_ring_max', 700));
		double front = clamp(CF('rsqmb_arr_front', 60), 0.0, 150.0);
		double arc = 360.0 - 2 * front;
		int n = tc.Size();
		// the slots, evenly round the arc (his sides and behind), in a random order: he can't tell where the next comes from
		Array<int> slot;
		for (int t = 0; t < n; t++) slot.Insert(random[rsqmbbf](0, slot.Size()), t);
		int ring = 0, near = 0, any = 0, old = 0, none = 0;
		for (int t = 0; t < n; t++)
		{
			class<Actor> c = tc[t];
			if (!c) continue;
			double a0 = p.angle + front + arc * (slot[t] + 0.5) / n + frandom[rsqmbbf](-arc / (n * 4.0), arc / (n * 4.0));
			static const double NEXT[] = { 0, -20, 20, -40, 40 };
			bool got = false;
			for (int k = 0; k < NEXT.Size() && !got; k++) got = RingSpot(pr, p, c, a0 + NEXT[k], rmin, rmax);
			if (got) { ring++; continue; }
			double r2 = max(RING_NEAREST, rmin * 0.5);
			for (int k = 0; k < NEXT.Size() && !got; k++) got = RingSpot(pr, p, c, a0 + NEXT[k], r2, rmax);
			if (got) { near++; continue; }
			for (int k = 0; k < 16 && !got; k++) got = RingSpot(pr, p, c, p.angle + k * 22.5, r2, rmax);
			if (got) { any++; continue; }
			int f = fc.Find(tc[t]);
			if (f < fc.Size())
			{
				arrX.Push(fx[f]); arrY.Push(fy[f]); arrZ.Push(fz[f]); arrCls.Push(fc[f]);
				fx.Delete(f); fy.Delete(f); fz.Delete(f); fc.Delete(f);
				old++;
				continue;
			}
			none++;
		}
		if (debug) Console.Printf("RSQMB arrival Around You: %d thralls planned: %d in the ring (%.0f-%.0f, %.0f degrees clear in front), %d nearer, %d at any angle, %d beside the Boss, %d did not fit",
			n, ring, rmin, rmax, front, near, any, old, none);
	}

	// one ring spot along angle ang from the player: traced (no wall between), the probe the thrall's size fits, in sight
	bool RingSpot(Actor pr, PlayerPawn p, class<Actor> c, double ang, double rmin, double rmax)
	{
		let def = GetDefaultByType(c);
		FLineTraceData lt;
		p.LineTrace(ang, rmax + 64, 0, TRF_THRUACTORS, p.height * 0.5, data: lt);
		double reach = min(rmax, lt.Distance - (def.radius + 16));
		if (reach < rmin) return false;
		Vector2 u = (cos(ang), sin(ang));
		for (int k = 0; k < 6; k++)
		{
			double d = reach - k * (reach - rmin) / 5.0;
			if (d < rmin) break;
			Vector2 at = p.pos.xy + u * d;
			if (!level.IsPointInLevel((at, p.pos.z))) continue;
			bool clash = false;
			for (int q = 0; q < arrX.Size(); q++)
			{
				class<Actor> qc = arrCls[q];
				double qr = qc ? GetDefaultByType(qc).radius : 32;
				if (q == 0) qr *= (arrMbK > 0 ? arrMbK : MB_SCALE);
				double rr = def.radius + qr + 8;
				double dx = arrX[q] - at.x, dy = arrY[q] - at.y;
				if (dx * dx + dy * dy < rr * rr) { clash = true; break; }
			}
			if (clash || !Fits(pr, c, at.x, at.y, p.pos.z) || abs(pr.pos.z - p.pos.z) > RING_DZ) continue;
			if (!p.CheckSight(pr, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)) continue;
			arrX.Push(at.x); arrY.Push(at.y); arrZ.Push(pr.pos.z); arrCls.Push(c.GetClassName());
			return true;
		}
		return false;
	}

	// ---- THE TIMES (StartArrival, Around You) -------------------------------------------------------------------------------
	// the thralls one after another, rsqmb_arr_step_min..max s apart, the first after its mark's lead; the Boss one step after
	// the last (no thralls: as before, MB_AT)
	void ArrTimes(int nth)
	{
		arrMarked.Clear();
		for (int i = 0; i < arrAt.Size(); i++) arrMarked.Push(false);
		arrMarkLead = MarkTics();
		int s0 = int(clamp(CF('rsqmb_arr_step_min', 0.5), 0.1, 5.0) * TICRATE);
		int s1 = max(s0, int(clamp(CF('rsqmb_arr_step_max', 1.0), 0.1, 5.0) * TICRATE));
		int t = CHAMP_LEAD + arrMarkLead + 2;
		for (int i = 1; i < arrAt.Size(); i++)
		{
			arrAt[i] = t;
			t += random[rsqmbbf](s0, s1);
		}
		arrAt[0] = nth > 0 ? t : CHAMP_LEAD + MB_AT;
		if (debug)
		{
			String l = "";
			for (int i = 1; i < arrAt.Size(); i++) l = l .. (i > 1 ? " " : "") .. arrAt[i];
			Console.Printf("RSQMB arrival Around You: stage turn %.1f s, thralls land at tics [%s] (each marked %d tics before), the Boss at %d, its landing invulnerable %d tics",
				StageSecs(), l, arrMarkLead, arrAt[0], BossInvTics());
		}
	}

	// ---- THE MARK (ArrivalStep, each thrall still to land) -----------------------------------------------------------------
	void MarkStep(int i, int age, Actor p)
	{
		if (!arrAround || i <= 0 || i >= arrX.Size()) return;
		while (arrMarked.Size() <= i) arrMarked.Push(false);
		if (arrMarked[i] || age < arrAt[i] - arrMarkLead) return;
		arrMarked[i] = true;
		class<Actor> c = arrCls[i];
		double h = c ? GetDefaultByType(c).height : 56;
		int col = LadderRGB(min(TOP_TIER, WorldTierNow() + 1));     // the thralls' colour (fight.zs ApplyFrom: world tier + 1)
		if (col < 0) col = RGB_TARGET;
		static const int XH[] = { 3, 7, 5, 4, 6, 1, 2, 8 };          // the Boss bar's crosshair for that thrall (bossbar.zs)
		double sz = max(40.0, h * 0.75) * 2.0;
		let m = RSQMB_LandMark.Make((arrX[i], arrY[i], arrZ[i] + h * 0.5), p, arrTic + arrAt[i], col, XH[(i - 1) % XH.Size()], sz);
		if (m) m.A_StartSound("misc/spawn", CHAN_AUTO, 0, 1.0, 0.5);
		if (debug) Console.Printf("RSQMB arrival: thrall %d's spot marked (%s, lands in %d tics, %.0f units from you)", i, arrCls[i], arrTic + arrAt[i] - level.maptime,
			p ? level.Vec2Diff(p.pos.xy, (arrX[i], arrY[i])).Length() : 0.0);
	}

	// ---- LIVE AT ONCE (bossfight.zs Reveal, a thrall, Around You): no hold, no invulnerable charge ------------------------
	void RevealLive(int i, Actor p)
	{
		let a = arrMon[i];
		if (!a) return;
		while (arrOwnInv.Size() <= i) arrOwnInv.Push(false);
		arrOwnInv[i] = a.bINVULNERABLE;
		a.bDORMANT = false;
		Wake(a);
		if (debug) Console.Printf("RSQMB arrival: thrall %d %s revealed and fighting", i, a.GetClassName());
	}

	// ---- KILLED BEFORE THE BOSS LANDED (ArrivalStep, after Bind, Around You): bound as thralls already dead -----------------
	void BindDead(RSQMB_Boss b)
	{
		int n = 0;
		for (int i = 1; i < arrMon.Size() && i < arrState.Size(); i++)
		{
			if (arrState[i] != 2) continue;
			let a = arrMon[i];
			if (a && a.health > 0) continue;
			b.thr.Push(a);
			b.thrState.Push(RSQMB_Boss.ST_DEAD);
			n++;
		}
		b.total = b.thr.Size();
		if (debug && n) Console.Printf("RSQMB bound: %d thrall(s) killed before the Boss landed count as killed (living %d of %d, it takes x%.2f)", n, b.Living(), b.total, b.ThrallFactor());
	}

}
