// ============================================================================
// RSQ_Miniboss -- the effects, in the ORIGINAL Minibosses!' art (owner 2026-11-05 01:07: "yes, the OG stuff, but
// optimize it as best we can, it is dangerous on mobile").
//
// Tartlman's Minibosses! v0.1.1 (original/zscript/minibossfx.txt, minibosscontroller.txt) drew the IWAD's own sprites
// as ACTORS in RenderStyle AddStencil, stencil red: BFS1 AB over each thrall (scale 0.5, alpha 0.5, floatbob; gone here), APLS AB
// beads along each thrall's trail (scale 1, alpha 0.3, mbos_thralldensity = 30 actors a thrall, warped every tic),
// BFE1 A-F / APBX A-E when a link breaks, BAL2 AB life orbs circling the boss (gone here), FIRE flames
// circling it while invulnerable (20 of them, FIRE D-H as they go out). Same sprites here, AddStencil in each set
// piece's own colour (RSQMB_Handler.PALETTE, the service's "colour") instead of red, drawn as cheaply as this engine
// allows:
//   - VisualThinkers, not actors (as VisualRewards' glyphs.zs): no states, no blockmap, no collision, no sprite frames
//     of our own (the IWAD's sprites are looked up as textures). They sit on a NON-TICKING statnum: the engine never
//     ticks them; one driver after every actor has moved places them, setting Prev and Pos itself (glyphs.zs' fixed
//     Put: the parameter is not named "prev", or it hides the field).
//   - The tethers are the original's in full (30 beads a link, every tic): owner 1.0 #3 (11-06).
//   - THE SPHERES ARE GONE (the rework, 2026-11-09, design/MINIBOSS_REWORK.md "Spheres"): no life orbs circling it (the HUD's
//     thin life bars replace them: "the spheres get lost in the tether art", owner) and no BFG ball over each thrall
//     ("TARGET!" over it replaces it). A lost life and its death burst in the original's BFE1 instead of BAL2.
//   - A small pool, capped by Effects Density, spawned once per map and reused: nothing is spawned or destroyed per tic.
//     The cap is the hard cap on effects drawn in the map. A free slot is Alpha 0 (the renderer skips it).
//   - Everything shown is placed every tic, interpolated. A frame's texture is written only when the frame changes.
//   - Only set pieces within Effects Range of you are drawn.
//   - The pool's sprites are thinkers, so a savegame carries them (at most the cap); after a load they are adopted
//     again, not leaked.
// If an IWAD sprite can't be found as a texture, the old particle effects are drawn instead (boss.zs FX/Burst/Shatter).
// ============================================================================

class RSQMB_Fx : VisualThinker
{
	const STAT_FX = 29;     // below STAT_FIRST_THINKING (32): never ticked; not VisualRewards' 30
	int key;                // what this slot showed last tic (-1 free)
	int seqShown, frameShown;
	Color colShown;

	void Put(Vector3 newPos, Vector3 lastPos)
	{
		Prev = lastPos;
		Pos = newPos;
		UpdateSector();
	}
}

// Placed after the actors (STAT_DEFAULT 100) have moved, like VisualRewards' DnDriver.
class RSQMB_FxDriver : Thinker
{
	override void Tick()
	{
		let h = RSQMB_Handler.Get();
		if (h) h.FxStep();
	}
}

// A one-shot (a link breaking, a life lost, the flames going out): played on a pool slot until its frames end.
class RSQMB_FxShot play
{
	Vector3 at;
	int seq, t0, id;
	Color col;
	Vector2 sc;
	double alpha;
}

// The pool and its sequences, held by the handler (transient: rebuilt after a load).
class RSQMB_FxPool play
{
	// sequences: sprite, frames, tics a frame, loops (else the last frame holds, or a one-shot ends)
	// (the rework's spheres went 11-09: BFS1 over each thrall and the BAL2 life orbs; their sequences went 11-10)
	enum ESeq { SQ_BEAD, SQ_FLAME, SQ_BREAK, SQ_BEADX, SQ_FLAMEX, SQ_COUNT }
	static const String SPR[] = { "APLS", "FIRE", "BFE1", "APBX", "FIRE" };
	static const String FRM[] = { "AB", "ABABCBCDCD", "ABCDEF", "ABCDE", "DEDEFEFGFGHGH" };
	static const int    TICS[] = { 5, 2, 5, 5, 2 };
	static const int    LOOP[] = { 1, 0, 0, 0, 0 };

	// The tether is the ORIGINAL's at every density (owner 1.0 #3, 11-06: "use the miniboss art from the OG mod, not
	// the weak ass dotted tethers"): mbos_thralldensity 30 APLS beads a link, boss to thrall, placed every tic and
	// interpolated (the original's WARPF_INTERPOLATE), so it reads as a solid chain, never a few dots.
	const BEADS = 30;
	// Effects Density: Low (Quest-safe, the default) / Medium / High: the flames and the cap only
	static const int FLAMES[] = { 6, 10, 16 };     // invulnerability flames (the original: 20)
	static const int CAP[] = { 280, 320, 380 };    // most effects drawn in the map at once (8 thralls x 30 beads fit at Low)

	Array<RSQMB_Fx> pool;
	Array<RSQMB_FxShot> shots;
	Array<TextureID> tex;
	Array<int> seqStart;
	bool ok, made, adopted;
	int used, nextId;

	void Make()
	{
		made = true;
		ok = true;
		tex.Clear(); seqStart.Clear();
		for (int s = 0; s < SQ_COUNT; s++)
		{
			seqStart.Push(tex.Size());
			String f = FRM[s];
			for (int i = 0; i < int(f.Length()); i++)
			{
				TextureID t = TexMan.CheckForTexture(SPR[s] .. f.Mid(i, 1) .. "0", TexMan.Type_Sprite);
				if (!t.IsValid()) ok = false;
				tex.Push(t);
			}
		}
	}

	int Frame(int s, int age)
	{
		int n = FRM[s].Length();
		int fi = max(0, age) / TICS[s];
		if (LOOP[s]) return fi % n;
		return min(fi, n - 1);
	}
	bool Over(int s, int age) { return !LOOP[s] && age >= int(FRM[s].Length()) * TICS[s]; }

	// After a load the saved slots are taken back (the transient pool was emptied).
	void Adopt()
	{
		adopted = true;
		let it = ThinkerIterator.Create("RSQMB_Fx", RSQMB_Fx.STAT_FX);
		RSQMB_Fx f;
		while (f = RSQMB_Fx(it.Next())) { f.key = -1; f.Alpha = 0; pool.Push(f); }
	}

	// Slot k shows `key`. Moving ones (interp) are placed every tic with Prev = last tic's spot; beads only when due,
	// and never interpolated.
	void Show(RSQMB_Handler h, int key, Vector3 at, bool interp, bool due, int s, int age, Color c, Vector2 sc, double alpha, int cap)
	{
		if (used >= cap) return;
		RSQMB_Fx f;
		int fi = Frame(s, age);
		if (used < int(pool.Size())) f = pool[used];
		else
		{
			f = RSQMB_Fx(VisualThinker.Spawn("RSQMB_Fx", tex[seqStart[s] + fi], at, (0, 0, 0), alpha, SPF_FULLBRIGHT, 0, sc, (0, 0), STYLE_AddStencil));
			if (!f) return;
			f.ChangeStatNum(RSQMB_Fx.STAT_FX);
			f.key = -1;
			pool.Push(f);
			if (h.debug) h.fxSpawned++;
		}
		used++;
		if (f.key != key)
		{
			f.key = key;
			f.Put(at, at);
			f.seqShown = -1;
			if (h.debug) h.fxWrites++;
		}
		else if (due)
		{
			f.Put(at, interp ? f.Pos : at);
			if (h.debug) h.fxWrites++;
		}
		if (f.seqShown != s || f.frameShown != fi) { f.seqShown = s; f.frameShown = fi; f.Texture = tex[seqStart[s] + fi]; }
		if (f.colShown != c) { f.colShown = c; f.scolor = c; }
		if (f.Scale != sc) f.Scale = sc;
		if (f.Alpha != alpha) f.Alpha = alpha;
	}

	// One link's 30 beads in one tight loop (1.0 opt, 11-06: "i do not want to lose quality but let's try and optimize
	// this"). Draws exactly what 30 Show() calls drew (same spots, frame, colour, scale 1, alpha 0.3, Prev = last tic's
	// spot), with the work done once a link instead of once a bead: the frame and its texture once, the link's start and
	// step once (bead j = start + step * j, BeadPos's own arithmetic), and a bead that did not move is not written and not
	// re-sectored (UpdateSector, a BSP walk, only for a bead that moved). Rig-measured before/after: proof/miniboss/opt_*.
	void BeadLink(RSQMB_Handler h, int k0, Vector3 start, Vector3 step, int nb, int t, Color c, int cap)
	{
		int s = SQ_BEAD;
		int fi = Frame(s, t);
		TextureID bt = tex[seqStart[s] + fi];
		for (int j = 0; j < nb; j++)
		{
			if (used >= cap) return;
			Vector3 at = start + step * j;
			RSQMB_Fx f;
			if (used < int(pool.Size())) f = pool[used];
			else
			{
				f = RSQMB_Fx(VisualThinker.Spawn("RSQMB_Fx", bt, at, (0, 0, 0), 0.3, SPF_FULLBRIGHT, 0, (1, 1), (0, 0), STYLE_AddStencil));
				if (!f) return;
				f.ChangeStatNum(RSQMB_Fx.STAT_FX);
				f.key = -1;
				pool.Push(f);
				if (h.debug) h.fxSpawned++;
			}
			used++;
			int key = k0 | j;
			if (f.key != key)
			{
				// a slot taking this bead over: everything set, as Show did
				f.key = key;
				f.Put(at, at);
				f.seqShown = s; f.frameShown = fi; f.Texture = bt;
				f.colShown = c; f.scolor = c;
				f.Scale = (1, 1);
				f.Alpha = 0.3;
				if (h.debug) h.fxWrites++;
				continue;
			}
			// Show's Put(at, Pos): Prev = last tic's spot, Pos = this one. Unmoved and settled: nothing to write.
			if (!(f.Pos == at)) { f.Put(at, f.Pos); if (h.debug) h.fxWrites++; }
			else if (!(f.Prev == at)) f.Prev = at;
			if (f.frameShown != fi || f.seqShown != s) { f.seqShown = s; f.frameShown = fi; f.Texture = bt; }
			if (f.colShown != c) { f.colShown = c; f.scolor = c; }
		}
	}

	void Shot(Vector3 at, int s, Color c, Vector2 sc, double alpha, int cap)
	{
		if (shots.Size() >= cap / 3) return;   // the one-shots never take more than a third of the pool
		let o = new("RSQMB_FxShot");
		o.at = at; o.seq = s; o.t0 = level.maptime; o.col = c; o.sc = sc; o.alpha = alpha; o.id = nextId++;
		shots.Push(o);
	}
}

extend class RSQMB_Handler
{
	transient RSQMB_FxPool fxp;
	transient RSQMB_FxDriver fxDriver;
	transient int fxDensity;
	transient int fxShown, fxWrites, fxSpawned, fxPeak;

	// Sprites, or the particle fallback (an IWAD sprite missing).
	bool UseSprites()
	{
		if (!fxp) fxp = new("RSQMB_FxPool");
		if (!fxp.made) fxp.Make();
		return fxp.ok;
	}

	void FxEnsureDriver()
	{
		if (fxDriver) return;
		let it = ThinkerIterator.Create("RSQMB_FxDriver", 125);
		fxDriver = RSQMB_FxDriver(it.Next());
		if (!fxDriver) { fxDriver = new("RSQMB_FxDriver"); fxDriver.ChangeStatNum(125); }
	}

	static Vector3 FlamePos(RSQMB_Boss b, int k, int n, int t)
	{
		let a = b.mb;
		double ang = t * 3.0 + k * 360.0 / max(1, n);         // mbos_invulnspinspeed 3
		double r = a.radius * 1.5;
		return a.pos + (cos(ang) * r, sin(ang) * r, 0);
	}

	// Bead j of n on a link, exactly where the original warped it: from the boss's middle (j = 0) toward the thrall's
	// feet plus the boss's half height, in n even steps (minibosscontroller.txt: incr = (thrall.pos - a.pos) / n).
	static Vector3 BeadPos(Actor boss, Actor th, int j, int n)
	{
		Vector3 d = level.Vec3Diff(boss.pos, th.pos) / double(max(1, n));
		return boss.pos + (0, 0, boss.height * 0.5) + d * j;
	}

	// ---- the events (boss.zs, handler.zs call these) ---------------------------------------------
	void FxBreak(RSQMB_Boss b, Actor th)
	{
		if (!fxOn || !b || !th) return;
		if (!b.mb || !UseSprites()) { if (b.mb) b.Shatter(RSQMB_Boss.Mid(th), RSQMB_Boss.Mid(b.mb)); return; }
		int cap = RSQMB_FxPool.CAP[fxDensity];
		fxp.Shot(th.pos + (0, 0, th.height), RSQMB_FxPool.SQ_BREAK, b.col, (0.5, 0.5), 0.5, cap);
		int nb = RSQMB_FxPool.BEADS;
		for (int j = 0; j < nb; j++) fxp.Shot(BeadPos(b.mb, th, j, nb), RSQMB_FxPool.SQ_BEADX, b.col, (1, 1), 0.3, cap);
	}

	void FxLifeLost(RSQMB_Boss b)
	{
		if (!fxOn || !b || !b.mb) return;
		if (!UseSprites()) { RSQMB_Boss.Burst(RSQMB_Boss.Mid(b.mb), b.col, 40, 6.0, 9); return; }
		// a BFG burst over its head (the life orb that used to go there is gone since the rework)
		fxp.Shot(b.mb.pos + (0, 0, b.mb.height * 0.9), RSQMB_FxPool.SQ_BREAK, b.col, (0.8, 0.8), 0.9, RSQMB_FxPool.CAP[fxDensity]);
	}

	void FxBossDied(RSQMB_Boss b)
	{
		if (!fxOn || !b || !b.mb) return;
		if (!UseSprites()) { RSQMB_Boss.Burst(RSQMB_Boss.Mid(b.mb), b.col, 48, 7.0, 10); return; }
		fxp.Shot(RSQMB_Boss.Mid(b.mb), RSQMB_FxPool.SQ_BREAK, b.col, (1.2, 1.2), 0.9, RSQMB_FxPool.CAP[fxDensity]);
		fxp.Shot(b.mb.pos + (0, 0, b.mb.height), RSQMB_FxPool.SQ_BREAK, b.col, (0.7, 0.7), 0.7, RSQMB_FxPool.CAP[fxDensity]);
	}

	void FxInvulEnd(RSQMB_Boss b)
	{
		if (!fxOn || !b || !b.mb || !UseSprites()) return;
		int nf = RSQMB_FxPool.FLAMES[fxDensity];
		for (int k = 0; k < nf; k++)
			fxp.Shot(FlamePos(b, k, nf, level.maptime), RSQMB_FxPool.SQ_FLAMEX, b.col, (0.3, 0.5), 0.5, RSQMB_FxPool.CAP[fxDensity]);
	}

	// ---- every tic, after the actors have moved --------------------------------------------------
	void FxStep()
	{
		double t0 = debug ? MSTimeF() : 0;
		FxStep2();
		if (debug) { costMs += MSTimeF() - t0; fxShown += fxp ? fxp.used : 0; if (fxp && fxp.used > fxPeak) fxPeak = fxp.used; }
	}

	private void FxStep2()
	{
		if (!fxp || !fxp.made || !fxp.ok) return;
		if (!fxp.adopted) fxp.Adopt();
		if (level.isFrozen()) return;
		int last = fxp.used;
		fxp.used = 0;
		let view = players[consoleplayer].mo;
		if (fxOn && view)
		{
			int d = fxDensity, cap = RSQMB_FxPool.CAP[d], nb = RSQMB_FxPool.BEADS, nf = RSQMB_FxPool.FLAMES[d];
			int t = level.maptime;
			for (int bi = 0; bi < bosses.Size(); bi++)
			{
				let b = bosses[bi];
				if (!b || b.done || !b.mb || b.mb.health <= 0) continue;
				Vector3 bm = RSQMB_Boss.Mid(b.mb);
				Vector3 dv = level.Vec3Diff(view.pos, bm);
				if (dv dot dv > fxRange2) continue;
				int kb = bi << 16;    // a boss's keys: group << 10 (thrall 0-13, 14 flames, 15 orbs), then the item
				// each living thrall: its trail of beads to the boss (no BFG ball over it since the rework: "TARGET!" is there)
				for (int i = 0; i < b.thr.Size() && i < 14; i++)
				{
					let th = b.thr[i];
					if (!th || b.thrState[i] != RSQMB_Boss.ST_ALIVE) continue;
					int ki = kb | (i << 10);
					// the original's trail: 30 APLS beads (scale 1, alpha 0.3), every tic, interpolated; BeadPos's spots,
					// worked out once a link (BeadLink)
					fxp.BeadLink(self, ki | (1 << 9), b.mb.pos + (0, 0, b.mb.height * 0.5), level.Vec3Diff(b.mb.pos, th.pos) / double(nb), nb, t, b.col, cap);
				}
				// (no life orbs since the rework: the HUD's thin life bars)
				// invulnerable: the flames circling it, lit from the moment it lost the life
				if (b.Invulnerable())
				{
					for (int k = 0; k < nf; k++)
						fxp.Show(self, kb | (14 << 10) | k, FlamePos(b, k, nf, t), true, true, RSQMB_FxPool.SQ_FLAME, t - b.invulFrom, b.col, (0.3, 0.5), 0.5, cap);
				}
			}
			// one-shots, where they were struck
			for (int k = fxp.shots.Size() - 1; k >= 0; k--)
			{
				let o = fxp.shots[k];
				int age = t - o.t0;
				if (fxp.Over(o.seq, age)) { fxp.shots.Delete(k); continue; }
				int sk = (1 << 24) | (o.id & 0xFFFFF);
				if (age % RSQMB_FxPool.TICS[o.seq] != 0 && fxp.used < fxp.pool.Size() && fxp.pool[fxp.used].key == sk) { fxp.used++; continue; }
				fxp.Show(self, sk, o.at, false, false, o.seq, age, o.col, o.sc, o.alpha, cap);
			}
		}
		else fxp.shots.Clear();
		// the slots no longer used go dark (once)
		for (int k = fxp.used; k < last && k < fxp.pool.Size(); k++)
		{
			let f = fxp.pool[k];
			if (f) { f.Alpha = 0; f.key = -1; }
		}
	}
}
