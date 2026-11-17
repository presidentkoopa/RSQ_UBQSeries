// ============================================================================
// RSQ_Miniboss -- the effects.
//
// THE THRALL LINK, THE THRALL MARKER AND THE SHIELD RING ARE THE ORIGINAL'S, EXACTLY (owner 2026-11-17: "get the
// connecting-thrall art and miniboss shield from here", Tartlman's Minibosses! pk3, minibossfx.txt and
// minibosscontroller.txt). They are ACTORS, as in the original, with the original's defaults and states line for line
// (the three classes below), each piece warped every tic by the set piece (boss.zs FxStep, the original controller's
// arithmetic):
//   RSQMB_ThrallFx       one over each thrall, warped to it at zofs = its height. BFS1 AB 5 tics BRIGHT, looping;
//                        AddStencil, scale 0.5, alpha 0.5, FLOATBOB. Its thrall dead: imp/shotx, BFE1 A-F 5 tics.
//   RSQMB_ThrallTrailFx  30 a thrall (mbos_thralldensity's default); piece j at the boss + (thrall - boss) x j / 30, plus
//                        half the boss's height. APLS AB 5 tics BRIGHT, looping; AddStencil, scale 1, alpha 0.3. Its
//                        thrall dead: APBX A-E 5 tics.
//   RSQMB_InvulnFx       20 (mbos_invulndensity's default) in a ring at 1.5 x the boss's radius, turning
//                        3 / (radius / 20) degrees a tic (mbos_invulnspinspeed 3). FIRE ABABCBCDCD 2 tics, then FIRE D
//                        held, BRIGHT; AddStencil, alpha 0.5, xscale 0.3, yscale 0.5, floatbob strength 0.5, FLOATBOB.
//                        Going out: FIRE DEDEFEFGFGHGH 2 tics. Here it is the SHIELD: lit while a thrall lives (the
//                        boss's damage cut, items.zs) and through the invulnerability after a lost life, as the original.
// Every piece's stencil shade is the set piece's own random colour (boss.zs fxCol: the original's minibosscolor, one random
// RGB a miniboss). The pooled VisualThinker beads and flames, the bead spacing and the particle fallback that drew these
// before are gone.
//
// THE POOL below draws only the one-shot bursts that are not the original's (a life lost, the death, the landing's fog
// without RSQ VisualRewards' beams): the IWAD's BFE1 / APBX as non-ticking VisualThinkers, placed after every actor has
// moved, at most CAP at once. An IWAD sprite missing: engine particles (boss.zs Burst).
// ============================================================================

class RSQMB_ThrallFx : Actor
{
	Default
	{
		RenderStyle "AddStencil";
		StencilColor "Red";
		Scale 0.5;
		Alpha 0.5;
		+NOINTERACTION
		+FLOATBOB
	}

	States
	{
	Spawn:
		BFS1 AB 5 BRIGHT;
		Loop;
	Explode:
		TNT1 A 0 A_StartSound("imp/shotx", CHAN_BODY);
		BFE1 ABCDEF 5 BRIGHT;
		TNT1 A -1;
		Stop;
	ExplodeDestroy:
		TNT1 A 0 A_StartSound("imp/shotx", CHAN_BODY);
		BFE1 ABCDEF 5 BRIGHT;
		Stop;
	}
}

class RSQMB_ThrallTrailFx : Actor
{
	Default
	{
		RenderStyle "AddStencil";
		StencilColor "Red";
		Scale 1.0;
		Alpha 0.3;
		+NOINTERACTION
	}

	States
	{
	Spawn:
		APLS AB 5 BRIGHT;
		Loop;
	Explode:
		APBX ABCDE 5 BRIGHT;
		TNT1 A -1;
		Stop;
	ExplodeDestroy:
		APBX ABCDE 5 BRIGHT;
		Stop;
	}
}

class RSQMB_InvulnFx : Actor
{
	Default
	{
		RenderStyle "AddStencil";
		StencilColor "Red";
		FloatBobStrength 0.5;
		Alpha 0.5;
		YScale 0.5;
		XScale 0.3;
		+NOINTERACTION
		+FLOATBOB
	}

	States
	{
	Spawn:
		FIRE ABABCBCDCD 2 BRIGHT;
		Goto Main;
	Main:
		FIRE D -1 BRIGHT;
		Stop;
	Explode:
		FIRE DEDEFEFGFGHGH 2 BRIGHT;
		Stop;
	}
}

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

// A one-shot (a life lost, the death, the landing's fog): played on a pool slot until its frames end.
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
	// sequences: sprite, frames, tics a frame (one-shots: the last frame ends it)
	enum ESeq { SQ_BREAK, SQ_BEADX, SQ_COUNT }
	static const String SPR[] = { "BFE1", "APBX" };
	static const String FRM[] = { "ABCDEF", "ABCDE" };
	static const int    TICS[] = { 5, 5 };
	const CAP = 280;           // most one-shot pieces drawn at once (the one-shots take at most a third of it)

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
		return min(max(0, age) / TICS[s], n - 1);
	}
	bool Over(int s, int age) { return age >= int(FRM[s].Length()) * TICS[s]; }

	// After a load the saved slots are taken back (the transient pool was emptied).
	void Adopt()
	{
		adopted = true;
		let it = ThinkerIterator.Create("RSQMB_Fx", RSQMB_Fx.STAT_FX);
		RSQMB_Fx f;
		while (f = RSQMB_Fx(it.Next())) { f.key = -1; f.Alpha = 0; pool.Push(f); }
	}

	// Slot `used` shows `key`, standing still where it was struck.
	void Show(RSQMB_Handler h, int key, Vector3 at, int s, int age, Color c, Vector2 sc, double alpha)
	{
		if (used >= CAP) return;
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
		if (f.seqShown != s || f.frameShown != fi) { f.seqShown = s; f.frameShown = fi; f.Texture = tex[seqStart[s] + fi]; }
		if (f.colShown != c) { f.colShown = c; f.scolor = c; }
		if (f.Scale != sc) f.Scale = sc;
		if (f.Alpha != alpha) f.Alpha = alpha;
	}

	void Shot(Vector3 at, int s, Color c, Vector2 sc, double alpha)
	{
		if (shots.Size() >= CAP / 3) return;   // the one-shots never take more than a third of the pool
		let o = new("RSQMB_FxShot");
		o.at = at; o.seq = s; o.t0 = level.maptime; o.col = c; o.sc = sc; o.alpha = alpha; o.id = nextId++;
		shots.Push(o);
	}
}

extend class RSQMB_Handler
{
	transient RSQMB_FxPool fxp;
	transient RSQMB_FxDriver fxDriver;
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

	// ---- the one-shots (boss.zs, handler.zs call these): in the set piece's own colour (boss.zs fxCol) ----------------
	void FxLifeLost(RSQMB_Boss b)
	{
		if (!fxOn || !b || !b.mb) return;
		if (!UseSprites()) { RSQMB_Boss.Burst(RSQMB_Boss.Mid(b.mb), b.fxCol, 40, 6.0, 9); return; }
		// a BFG burst over its head
		fxp.Shot(b.mb.pos + (0, 0, b.mb.height * 0.9), RSQMB_FxPool.SQ_BREAK, b.fxCol, (0.8, 0.8), 0.9);
	}

	void FxBossDied(RSQMB_Boss b)
	{
		if (!fxOn || !b || !b.mb) return;
		if (!UseSprites()) { RSQMB_Boss.Burst(RSQMB_Boss.Mid(b.mb), b.fxCol, 48, 7.0, 10); return; }
		fxp.Shot(RSQMB_Boss.Mid(b.mb), RSQMB_FxPool.SQ_BREAK, b.fxCol, (1.2, 1.2), 0.9);
		fxp.Shot(b.mb.pos + (0, 0, b.mb.height), RSQMB_FxPool.SQ_BREAK, b.fxCol, (0.7, 0.7), 0.7);
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
		if (fxOn)
		{
			int t = level.maptime;
			// one-shots, where they were struck
			for (int k = fxp.shots.Size() - 1; k >= 0; k--)
			{
				let o = fxp.shots[k];
				int age = t - o.t0;
				if (fxp.Over(o.seq, age)) { fxp.shots.Delete(k); continue; }
				int sk = (1 << 24) | (o.id & 0xFFFFF);
				if (age % RSQMB_FxPool.TICS[o.seq] != 0 && fxp.used < fxp.pool.Size() && fxp.pool[fxp.used].key == sk) { fxp.used++; continue; }
				fxp.Show(self, sk, o.at, o.seq, age, o.col, o.sc, o.alpha);
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
