// RSQ VisualRewards -- THE ARRIVAL BEAMS (2026-11-09). RSQVR_Service "beam" (service.zs; the shared contract of the
// Bossfight rework build): a monster ALREADY SPAWNED at its spot arrives on one of the four approved beams.
//
//   V1  the beam opens around it (End of Starchild's death-pillar MOTION, our own beam), rings drop down it
//   V2  arcade: a floor ring flash, the beam slams down, rings ride up it, the monster white -> its colour -> itself
//   V3  the Z-Fighter column that hides it: INDOOR (the ceiling above is within the column's reach, ~166 units at
//       size 1: the column is cut at the real ceiling, the splash hangs from it, sparks drop) or OUTDOOR (sky, or a
//       ceiling out of reach: a stepped taper climbs out of sight, flame licks trail upward), picked here
//   V4  boss: six beams spiral in, merge, a skull pillar, the monster arrives
// THE SPEC is the owner's approved mockups (tools/beam_spec/: variants_v2.py V1b V2b V4b, variants_v3.py V3c; renders
// in renders/arrival_beams/). Each Vn function below follows its mockup tic by tic, in the mockups' units (1 texel =
// 1 map unit for a monster as tall as an imp) times the size: size 1.0 = sized to the monster's own height (its Height
// over the imp's 56), the caller's doubleArg on top. The art is tools/gen_beams.py's export (beam_data.zs).
//
// HOW THE MONSTER IS HIDDEN. The director (RSQVR_Beam, an ordinary saved actor at the monster) sets the monster's
// bINVISIBLE render flag the tic the beam is asked for and keeps the value it had. For the mockups' silhouette tics
// it is drawn as a Stencil in a band colour (its render style, alpha and fill colour are kept first). On the reveal tic
// all three and bINVISIBLE go back to exactly what they were. bINVISIBLE is a render flag only: the monster still
// thinks, moves and can be hit (the caller keeps it from acting: see RSQ Miniboss). A monster that dies mid-beam is
// shown at once (its death plays); one that is removed is simply let go (nothing is touched again); a director that is
// removed early (map change, a script) puts the monster back in OnDestroy. A save mid-beam keeps the director and what
// it saved. A second beam on a monster that already has one is refused (0).
//
// TIME. The beams run on game tics, not the world's slowed time: a Bossfight's arrival plays inside RSQ SlowMo's
// landing slow, and the returned reveal (tics from the call) is in the same tics the caller counts with level.maptime.
// SOUND (the owner's arrival sounds, SNDINFO.txt), one per beam (owner 2026-11-09 18:38-18:40; nameArg no longer picks
// it): V1 ONPARE8, V2 ONPARE2, V3 PL00_U (the riser), V4 PL01_U (stand-in: the owner is sourcing a longer boss sound),
// each on the beam's first tic. No hit on the reveal: ONPARE6 (rsqvr/beam/hit) is the miniboss fight's segment-break
// sound. Full volume to
// 400 units, silent at 1800 (arrivals land 12-32 m away).
// It holds while the level is frozen (the time-freeze sphere). Nothing it does is random but for named RNG in the
// director (synced); every piece it draws is a CLIENTSIDEONLY actor (as RSQ Grenade's blast layers).
//
// COLOUR. intArg 0xRRGGBB: the four flat bands (dark, mid = the colour, light, near-white core) through one runtime
// translation per colour (RSQVR_FxHandler.Trans); one-colour pieces (rings, discs, sparks) are white drawn AddShaded.
// A very dark colour (the ladder's Black tier) is drawn see-through instead of added, as the mockups' 'alpha' mode.
//
// PHOTOSENSITIVE MODE (RSQ Accessibility rsqa_photosafe, read for the console player's view only): no white
// silhouette (the light band instead), the white flash pieces (the V2 ring flash and impact bar, V3's impact dome and
// splash, the V4 merge bar) at 40%. Arrival Beams (rsqvr_beams, a server setting) off: "beam" answers 0 and nothing is
// hidden.

// ---- one piece of a beam: a billboard or a flat, its sprite, frame, size and colour set by the director each tic ----
class RSQVR_BeamPiece : Actor
{
	int shownAt;          // the director's clock when last placed (older: hidden)
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+CLIENTSIDEONLY
		+BRIGHT
		RenderStyle "Add";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;    // the sprite and frame are set by the director
		Stop;
	}
}

// ---- a spark or a flame: moves itself (the mockups' Sparks and flames_up), its colour cooling with age ------------------
class RSQVR_BeamSpark : RSQVR_BeamPiece
{
	int holdTics, age, life, rgb, frBase, mode;   // mode 0 spark (shaded by band), 1 flame (banded frames: hot then cool)
	double grav, floorLimit;
	bool dark;

	override void Tick()
	{
		if (level.IsFrozen()) return;
		if (holdTics > 0)
		{
			holdTics--;
			if (holdTics == 0) { bInvisible = false; ClearInterpolation(); }
			return;
		}
		Super.Tick();                             // moves it by its velocity (NOINTERACTION)
		if (bDestroyed) return;
		age++;
		if (age >= life || pos.z < floorLimit) { Destroy(); return; }
		vel.z -= grav;
		Recolour();
	}

	void Recolour()
	{
		if (mode == 1)
		{
			frame = RSQVR_BeamData.FR_FRM(frBase + (age < 3 ? 0 : 5));   // hot, then cool (flames_up: a < 3)
			return;
		}
		int band = min(3, 4 * age / max(1, life));
		frame = RSQVR_BeamData.FR_FRM(RSQVR_BeamData.F_SPARK + (vel.z > 0 ? 0 : 1));   // its trail behind it
		SetShade(RSQVR_FxHandler.BandCol(rgb, band));
	}
}

// ---- the director ------------------------------------------------------------------------------------------------------
class RSQVR_Beam : Actor
{
	const IMP_H = 56.0;      // the mockups' monster (an imp): size 1 sizes the beam to a monster this tall

	Actor mon;
	int bKind;               // 1..4
	int role;                // 1 miniboss, 2 thrall, 3 chump (kept for callers; sounds now go by beam)
	int rgb;
	double sz;               // map units per mockup unit
	int clock, startTic, reveal, total;
	bool dark;
	bool indoor;             // V3
	double ceilU;            // V3 indoor: the ceiling's height above the base, in mockup units
	double baseZ;
	// the monster's own look, kept while it is hidden or a silhouette
	bool hidden, wasInvisible, silOn, released;
	int keptStyle;
	double keptAlpha;
	Color keptFill;
	// the pieces
	Array<RSQVR_BeamPiece> slots;
	transient bool photo;
	transient Vector3 camR, toEye;
	transient double push;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "None";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// the reveal tic and the length of each kind (tics from the call), from the mockups
	static int RevealOf(int k) { return k == 1 ? 7 : (k == 2 ? 12 : (k == 3 ? 19 : 31)); }
	static int LengthOf(int k) { return k == 1 ? 24 : (k == 2 ? 34 : (k == 3 ? 30 : 68)); }
	// the role (nameArg): 1 miniboss, 2 thrall, 3 chump; none or unknown: V3 / V4 a miniboss, V1 / V2 a thrall
	static int RoleOf(Name r, int k)
	{
		if (r == 'miniboss') return 1;
		if (r == 'thrall') return 2;
		if (r == 'chump') return 3;
		return k >= 3 ? 1 : 2;
	}
	// the sound the beam starts with, one per beam (owner 18:50, SNDINFO.txt): V1 / V2 / V4 the locked RVQB sounds, V3 PL00_U
	static String SoundOf(int k)
	{
		static const String T[] = { "rsqvr/beam/v1", "rsqvr/beam/v2", "rsqvr/beam/rise", "rsqvr/beam/v4" };
		return T[clamp(k, 1, 4) - 1];
	}
	static int KindOf(String s)
	{
		s = s.MakeLower();
		if (s == "v1") return 1;
		if (s == "v2") return 2;
		if (s == "v3") return 3;
		if (s == "v4") return 4;
		return 0;
	}

	// RSQVR_Service "beam": returns the reveal tic (> 0), or 0 when nothing played
	static int StartBeam(String kindName, int colour, double size, Actor m, Name roleName = 'None')
	{
		int k = KindOf(kindName);
		if (k == 0 || !m || m.bDestroyed || m.health <= 0) return 0;
		let cv = CVar.FindCVar('rsqvr_beams');
		if (cv && !cv.GetBool()) return 0;
		let h = RSQVR_FxHandler.Get();
		if (!h) return 0;
		if (h.BeamOn(m)) return 0;
		let b = RSQVR_Beam(Actor.Spawn("RSQVR_Beam", m.Pos));
		if (!b) return 0;
		b.Begin(k, colour & 0xFFFFFF, size, m, RoleOf(roleName, k));
		h.beams.Push(b);
		return b.reveal;
	}

	void Begin(int k, int colour, double size, Actor m, int r)
	{
		bKind = k; rgb = colour; mon = m; role = r;
		if (size <= 0) size = 1.0;
		sz = clamp(size * max(m.Height, 16.0) / IMP_H, 0.3, 6.0);
		dark = RSQVR_FxHandler.IsDark(rgb);
		reveal = RevealOf(k);
		total = LengthOf(k);
		startTic = level.maptime;
		// the base: the floor under it, unless it floats well above it (then its own height)
		baseZ = (m.Pos.z - m.floorz > 24) ? m.Pos.z : m.floorz;
		SetOrigin((m.Pos.xy, baseZ), false);
		if (bKind == 3)
		{
			// sky, or a ceiling beyond the column's reach -> outdoor; else indoor at that ceiling
			bool sky = m.CurSector && m.CurSector.GetTexture(Sector.ceiling) == skyflatnum;
			double room = m.ceilingz - baseZ;
			indoor = !sky && room <= RSQVR_BeamData.COL_H * sz;
			ceilU = max(8.0, room / sz);
		}
		A_StartSound(SoundOf(bKind), CHAN_AUTO, CHANF_DEFAULT, 1.0, ATTN_NORM);
		MonHide();
		clock = 0;
		BeamStep();
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || level.IsFrozen()) return;
		if (level.maptime <= startTic + clock) return;    // one step a tic, the first the tic it was asked for
		clock++;
		if (clock >= total) { Destroy(); return; }
		BeamStep();
	}

	void BeamStep()
	{
		// the monster: it follows it (it is kept from acting, but can be pushed); dead -> shown at once; gone -> let go
		if (mon && mon.bDestroyed) mon = null;
		if (!mon) released = true;
		else if (!released)
		{
			if (mon.health <= 0) MonReal();
			else
			{
				double bz = (mon.Pos.z - mon.floorz > 24) ? mon.Pos.z : mon.floorz;
				SetOrigin((mon.Pos.xy, bz), true);
				baseZ = bz;
			}
		}
		// the view (pieces are drawn for the console player's eyes: billboards across the view, pushed toward it)
		photo = RSQTHP_A11y.Photo();
		let p = players[consoleplayer];
		let cam = p.camera ? p.camera : Actor(p.mo);
		if (cam)
		{
			double yaw = cam.Angle;
			camR = (sin(yaw), -cos(yaw), 0);
			Vector3 d = cam.Pos - Pos;
			d.z = 0;
			toEye = d.Length() > 0.01 ? d / d.Length() : (0, 0, 0);
		}
		push = (mon ? mon.radius * 0.6 : 8.0) + 1.0;
		switch (bKind)
		{
		case 1: V1(clock); break;
		case 2: V2(clock); break;
		case 3: V3(clock); break;
		default: V4(clock); break;
		}
		if (clock >= reveal) MonReal();
		for (int i = 0; i < slots.Size(); i++)
			if (slots[i] && slots[i].shownAt != clock) slots[i].bInvisible = true;
	}

	override void OnDestroy()
	{
		MonReal();
		for (int i = 0; i < slots.Size(); i++) if (slots[i]) slots[i].Destroy();
		slots.Clear();
		Super.OnDestroy();
	}

	// ================================================================================================================
	// THE MONSTER
	void MonHide()
	{
		if (!mon || hidden || released) return;
		wasInvisible = mon.bInvisible;
		mon.bInvisible = true;
		hidden = true;
	}
	// drawn as a flat silhouette: band -1 white (Photosensitive Mode: the light band), 0..3 the colour's bands
	void MonSil(int band, double a = 1.0)
	{
		if (!mon || released) return;
		if (band < 0 && photo) band = 1;
		if (!silOn)
		{
			keptStyle = mon.GetRenderStyle(); keptAlpha = mon.Alpha; keptFill = mon.fillcolor;
			silOn = true;
		}
		mon.bInvisible = wasInvisible;
		mon.A_SetRenderStyle(a, STYLE_Stencil);
		mon.SetShade(band < 0 ? Color(255, 255, 255, 255) : RSQVR_FxHandler.BandCol(rgb, band));
	}
	void MonReal()
	{
		if (released) return;
		released = true;
		if (!mon || mon.bDestroyed) return;
		if (silOn) { mon.A_SetRenderStyle(keptAlpha, keptStyle); mon.SetShade(keptFill); silOn = false; }
		if (hidden) { mon.bInvisible = wasInvisible; hidden = false; }
	}

	// ================================================================================================================
	// THE PIECES
	RSQVR_BeamPiece Slot(int i)
	{
		while (slots.Size() <= i) slots.Push(null);
		let p = slots[i];
		if (!p || p.bDestroyed)
		{
			p = RSQVR_BeamPiece(Actor.Spawn("RSQVR_BeamPiece", Pos));
			slots[i] = p;
			if (!p) return null;
			p.bInvisible = true;
			p.shownAt = -1;
		}
		return p;
	}

	void Place(RSQVR_BeamPiece p, int fr, Vector3 at, double sx, double sy)
	{
		let h = RSQVR_FxHandler.Get();
		if (h) p.sprite = h.Spr(RSQVR_BeamData.FR_SPR(fr));
		p.frame = RSQVR_BeamData.FR_FRM(fr);
		p.Scale = (sx / RSQVR_BeamData.EXPORT_K, sy / RSQVR_BeamData.EXPORT_K);
		bool fresh = p.shownAt != clock - 1;
		p.SetOrigin(at, !fresh);
		if (fresh) p.ClearInterpolation();
		p.bInvisible = false;
		p.shownAt = clock;
	}

	// a billboard in the four bands: frame fr, x across the view and z up, w x h (mockup units); flash: a white flash
	void Bill(int i, int fr, double x, double z, double w, double hgt, double a = 1.0, bool flash = false)
	{
		BillAt(i, fr, camR.xy * x, z, w, hgt, a, flash);
	}
	void BillAt(int i, int fr, Vector2 off, double z, double w, double hgt, double a = 1.0, bool flash = false)
	{
		if (a <= 0 || w < 0.05 || hgt < 0.05) return;
		let p = Slot(i);
		if (!p) return;
		let h = RSQVR_FxHandler.Get();
		double tw = max(1, RSQVR_BeamData.FR_W(fr)), th = max(1, RSQVR_BeamData.FR_H(fr));
		Vector3 at = Pos + ((off * sz) + toEye.xy * push, z * sz);
		Place(p, fr, at, w * sz / tw, hgt * sz / th);
		p.bFlatSprite = false;
		if (flash && photo) a *= RSQTHP_A11y.DIM_K;
		int st = dark ? STYLE_Translucent : STYLE_Add;
		if (p.Alpha != a || p.GetRenderStyle() != st) p.A_SetRenderStyle(a, st);
		if (h) p.Translation = h.Trans(rgb, false);
	}

	// a flat on the floor (or at height z): kind 0 a disc, 1..3 a ring that many texels thick; radius r; one colour, the
	// band's times kk (the mockups' scaled(cols[b], kk))
	void Flat(int i, int kindF, double r, double z, int band, double kk = 1.0, double a = 1.0, bool flash = false)
	{
		if (r < 0.5 || a <= 0) return;
		let p = Slot(i);
		if (!p) return;
		// the nearest exported radius, scaled the rest of the way (a ring keeps about its thickness)
		int best = 0;
		for (int n = 1; n < RSQVR_BeamData.NRADII; n++)
			if (abs(RSQVR_BeamData.RADIUS(n) - r) < abs(RSQVR_BeamData.RADIUS(best) - r)) best = n;
		int fr = (kindF == 0 ? RSQVR_BeamData.F_DISC : RSQVR_BeamData.F_RING1 + (clamp(kindF, 1, 3) - 1) * RSQVR_BeamData.NRADII) + best;
		double k = r / RSQVR_BeamData.RADIUS(best) * sz;
		Place(p, fr, Pos + (0, 0, z * sz + 0.3 + 0.05 * i), k, k);
		p.bFlatSprite = true;
		p.Angle = 0;
		if (flash && photo) a *= RSQTHP_A11y.DIM_K;
		int st = dark ? STYLE_Shaded : STYLE_AddShaded;
		if (p.Alpha != a || p.GetRenderStyle() != st) p.A_SetRenderStyle(a, st);
		p.SetShade(RSQVR_FxHandler.BandCol(rgb, band, dark ? 1.0 : kk));
	}

	// the mockups' Sparks: n sparks a tic apart in threes, from a disc of `spread` around the base, thrown out and up,
	// falling under grav, cooling a band a quarter of their life (all in mockup units, times the size)
	void Sparks(int n, double spread, double vzLo, double vzHi, double vx, double grav, int lifeLo, int lifeHi,
		double zLo, double zHi)
	{
		for (int i = 0; i < n; i++)
		{
			double an = frandom[rsqvrbeam](0, 360);
			double rr = frandom[rsqvrbeam](0, spread);
			double hv = frandom[rsqvrbeam](-vx, vx);
			double av = frandom[rsqvrbeam](0, 360);
			Vector3 at = Pos + (cos(an) * rr * sz, sin(an) * rr * sz, frandom[rsqvrbeam](zLo, zHi) * sz + 0.5);
			let s = RSQVR_BeamSpark(Actor.Spawn("RSQVR_BeamSpark", at));
			if (!s) continue;
			s.rgb = rgb; s.dark = dark; s.mode = 0;
			s.holdTics = i % 3; s.bInvisible = s.holdTics > 0;
			s.life = random[rsqvrbeam](lifeLo, lifeHi);
			s.grav = grav * sz;
			s.floorLimit = Pos.z;
			s.vel = (cos(av) * hv * sz, sin(av) * hv * sz, frandom[rsqvrbeam](vzLo, vzHi) * sz);
			let h = RSQVR_FxHandler.Get();
			if (h) s.sprite = h.Spr(RSQVR_BeamData.FR_SPR(RSQVR_BeamData.F_SPARK));
			s.Scale = (sz / RSQVR_BeamData.EXPORT_K, sz / RSQVR_BeamData.EXPORT_K);
			s.A_SetRenderStyle(1.0, dark ? STYLE_Shaded : STYLE_AddShaded);
			s.Recolour();
		}
	}

	// variants_v3.flames_up: a flame off the column's side at z0, climbing 11 a tic and drifting out, hot for 3 tics
	void Flame(double z0, double half, int life)
	{
		int side = random[rsqvrbeam](0, 1) ? 1 : -1;
		int ln = random[rsqvrbeam](5, 9);
		double x = side * (half + 1 + random[rsqvrbeam](0, 1));
		Vector3 at = Pos + ((camR.xy * x * sz) + toEye.xy * push, z0 * sz);
		let s = RSQVR_BeamSpark(Actor.Spawn("RSQVR_BeamSpark", at));
		if (!s) return;
		s.rgb = rgb; s.dark = dark; s.mode = 1;
		s.life = life;
		s.grav = 0;
		s.floorLimit = Pos.z - 1;
		s.frBase = RSQVR_BeamData.F_FLAME + (side > 0 ? 0 : 10) + (ln - 5);
		s.vel = (camR.x * side * 0.6 * sz, camR.y * side * 0.6 * sz, 11 * sz);
		let h = RSQVR_FxHandler.Get();
		if (h) { s.sprite = h.Spr(RSQVR_BeamData.FR_SPR(RSQVR_BeamData.F_FLAME)); s.Translation = h.Trans(rgb, false); }
		s.Scale = (sz / RSQVR_BeamData.EXPORT_K, sz / RSQVR_BeamData.EXPORT_K);
		s.A_SetRenderStyle(1.0, dark ? STYLE_Translucent : STYLE_Add);
		s.Recolour();
	}

	// variants_v2.licks: `count` tongues off the column's sides this tic, rows 15-90% up its height
	void Licks(int first, int count, double colW, double colH)
	{
		for (int i = 0; i < count; i++)
		{
			double z = colH * frandom[rsqvrbeam](0.10, 0.85);
			int side = random[rsqvrbeam](0, 1) ? 1 : -1;
			int ln = random[rsqvrbeam](3, 7);
			double ex = side * (colW * 0.5 - 0.5);
			int fr = RSQVR_BeamData.F_LICK + (side > 0 ? 0 : 5) + (ln - 3);
			Bill(first + i, fr, ex, z, RSQVR_BeamData.FR_W(fr), RSQVR_BeamData.FR_H(fr));   // anchored at its root (gen_beams.py)
		}
	}

	// ================================================================================================================
	// V1 (variants_v2.V1b): EoS growth over 6 tics, 2 held, then narrowing x0.84 a tic (alpha holds 4, then -0.1); a
	// floor light of two bands under it; three rings drop down the beam and land as floor rings; the monster is a
	// see-through core silhouette for 2 tics (the mockup's scanlines) and itself from tic 7, inside the narrowing beam.
	void V1(int k)
	{
		if (k < 21)
		{
			double sx, sy, a;
			[sx, sy, a] = RSQVR_BeamTab.V1S(k);
			double r = 32 * sx * 0.75 + 5;
			Flat(0, 0, r, 0, 2, 0.55, a);
			Flat(1, 0, r * 0.6, 0, 1, 0.6, a);
			Bill(2, RSQVR_BeamData.F_BEAM + k % 3, 0, 0, 32 * sx, 80 * sy, a);
		}
		double H = 80 * RSQVR_BeamTab.GrowY(6);
		int jl = int((-5 + sqrt(25 + 6.4 * H)) / 3.2);
		for (int d = 0; d < 3; d++)
		{
			int j = k - (6 + 3 * d);
			if (j < 0) continue;
			double z = H - (5 * j + 1.6 * j * j);
			if (z > 0) Flat(3 + d, 1, 5 + 1.6 * j, z, min(2, j / 3));
			else
			{
				int jj = j - jl - 1;
				if (jj >= 0 && jj < 4) Flat(3 + d, 1, 16 + 6 * jj, 0, min(3, 1 + jj));
			}
		}
		if (k == 5 || k == 6) MonSil(0, photo ? 0.5 * RSQTHP_A11y.DIM_K : 0.5);
	}

	// V2 (variants_v2.V2b): ring flash on the floor (tics 0-5), the beam slams down in 3 steps (2-4), peaks and holds
	// (5-9), then narrows x0.82 a tic; a squashed impact bar (5-7); four rings ride up it; 22 sparks; the monster white
	// (5-9), light (10), mid (11), itself (12).
	void V2(int k)
	{
		double H = 170;
		if (k <= 5)
		{
			int b = RSQVR_BeamTab.V2FlashB(k);
			Flat(0, 2, RSQVR_BeamTab.V2FlashR(k), 0, b, 1.0, 1.0, b == 0);
			if (k <= 1) Flat(1, 0, k == 0 ? 5 : 8, 0, 0, 1.0, 1.0, true);
		}
		if (k >= 5 && k <= 21)
		{
			int st = k <= 8 ? 0 : (k <= 13 ? 1 : (k <= 18 ? 2 : 3));
			Flat(2, 0, RSQVR_BeamTab.V2Glow(st, 0), 0, 3, 0.9);
			Flat(3, 0, RSQVR_BeamTab.V2Glow(st, 1), 0, 2, 0.7);
			Flat(4, 0, RSQVR_BeamTab.V2Glow(st, 2), 0, 1, 0.7);
		}
		if (k >= 5 && k <= 9) MonSil(-1);
		else if (k == 10) MonSil(1);
		else if (k == 11) MonSil(2);
		int fr = RSQVR_BeamData.F_BEAM + (k + 2) % 3;          // BEAM[t % 3], t = k + the mockup's 8 lead-in tics
		if (k >= 2 && k <= 4)
		{
			double f = k == 2 ? 0.66 : (k == 3 ? 0.33 : 0.0);
			int cut = k == 2 ? RSQVR_BeamData.F_BEAM + 3 : (k == 3 ? RSQVR_BeamData.F_BEAM + 4 : RSQVR_BeamData.F_BEAM + 1);
			Bill(5, cut, 0, H * f, k == 2 ? 10 : (k == 3 ? 13 : 16), H * (1 - f));
		}
		else if (k >= 5 && k <= 9) Bill(5, fr, 0, 0, 26 * RSQVR_BeamTab.V2Peak(k - 5), H);
		else if (k >= 10)
		{
			int j = k - 9;
			double w = 26 * 0.82 ** j;
			double a = j < 3 ? 1.0 : 1.0 - 0.1 * (j - 2);
			if (a > 0 && w >= 0.7) Bill(5, fr, 0, 0, w, H, a);
		}
		if (k >= 5 && k <= 7)
		{
			int q = k - 5;
			Bill(6, RSQVR_BeamData.F_BEAM + (k + 2) % 3, 0, 0, q == 0 ? 66 : (q == 1 ? 54 : 40), q == 0 ? 9 : (q == 1 ? 7 : 4),
				q == 0 ? 1.0 : (q == 1 ? 0.8 : 0.6), true);
		}
		for (int i = 0; i < 4; i++)
		{
			int j = k - (5 + 2 * i);
			if (j >= 0 && j < 12) Flat(7 + i, 1, 18 - j * 0.7, 4 + j * 13, min(3, j / 3));
		}
		if (k == 5) Sparks(22, 10, 2.5, 5.5, 1.6, 0.45, 10, 18, 0, 6);
	}

	// V3 (variants_v3.V3c): impact dome / splash / burst on the floor (0-7); the column rises (3-6), fat (7-8), straight
	// (9-11), thin (12-14), its bands crawling up and licks off its sides; then narrows x0.74 a tic from 15; a pulsing
	// floor ring and stepped glow; the monster white (15-17), light (18), itself (19); a final pop at 20.
	// INDOOR: the column cut at the ceiling (squashed to it), a lit patch and spreading ring under the ceiling, the splash
	// hanging from it, sparks dropping. OUTDOOR: the tapered column climbs out of sight, flames trail up off its top.
	void V3(int k)
	{
		int END = 15;
		int j = k - END;
		if (k <= END + 7)
		{
			int st = k < 6 ? 0 : (k < END + 2 ? 1 : 2);
			Flat(0, 0, RSQVR_BeamTab.V3Glow(st, 0), 0, 3, 0.9);
			Flat(1, 0, RSQVR_BeamTab.V3Glow(st, 1), 0, 2, 0.7);
			Flat(2, 0, RSQVR_BeamTab.V3Glow(st, 2), 0, 1, 0.6);
			if (k < END + 4)
			{
				double rr; int rb;
				if (k < 6) { rr = RSQVR_BeamTab.V3RingR(k); rb = RSQVR_BeamTab.V3RingB(k); }
				else { int q = k % 4; rr = 41 + (q == 0 ? 0 : (q == 1 ? 2 : (q == 2 ? 4 : 2))); rb = q == 0 ? 2 : (q == 1 ? 1 : (q == 2 ? 2 : 3)); }
				Flat(3, 1, rr, 0, rb);
			}
		}
		if (indoor && k >= 6 && k <= END + 4)
		{
			int st = k < 10 ? 0 : (k < END + 1 ? 1 : 2);
			Flat(4, 0, RSQVR_BeamTab.V3Ceil(st, 0), ceilU - 0.6, 3, 0.8);
			Flat(5, 0, RSQVR_BeamTab.V3Ceil(st, 1), ceilU - 0.7, 2, 0.6);
			Flat(6, 0, RSQVR_BeamTab.V3Ceil(st, 2), ceilU - 0.8, 1, 0.5);
		}
		if (j >= 0 && j <= 2) MonSil(-1);
		else if (j == 3) MonSil(1);
		// the column
		int col = -1; double sy = 1.0;
		if (k >= 3 && k <= 6) { col = 0; sy = (k - 2) * 0.25; }
		else if (k >= 7 && k <= 8) col = 0;
		else if (k >= 9 && k <= 11) col = 1;
		else if (k >= 12 && k <= 14) col = 2;
		int ph = k % 5;
		double colH = RSQVR_BeamData.COL_H;
		if (col >= 0)
		{
			int colSet = col == 0 ? RSQVR_BeamData.F_COL2 : (col == 1 ? RSQVR_BeamData.F_COL1 : RSQVR_BeamData.F_COL0);
			int fr; double hgt;
			if (indoor)
			{
				if (colH * sy < ceilU) { fr = colSet + 5 + ph; hgt = colH * sy; }        // capped, still below the ceiling
				else { fr = colSet + ph; hgt = ceilU; }                                // cut at the ceiling
			}
			else { fr = colSet + 10 + ph; hgt = RSQVR_BeamData.FR_H(colSet + 10) * sy; }  // tapered, out of sight
			double w = RSQVR_BeamData.FR_W(fr);
			Bill(7, fr, 0, 0, w, hgt);
			if (k >= 5) Licks(20, 8, w, indoor ? hgt : colH * sy);
		}
		if (j >= 0)
		{
			int fr = indoor ? RSQVR_BeamData.F_COL0 + ph : RSQVR_BeamData.F_COL0 + 10 + ph;
			double w = RSQVR_BeamData.FR_W(fr) * 0.74 ** (j + 1);
			double a = j <= 3 ? 1.0 : 1.0 - 0.15 * (j - 3);
			if (a > 0 && w >= 0.7) Bill(8, fr, 0, 0, w, indoor ? ceilU : RSQVR_BeamData.FR_H(fr), a);
		}
		// the column's top
		if (indoor)
		{
			if (k >= 6 && k <= 10)
			{
				int q = k - 6;
				double csx = RSQVR_BeamTab.V3CapX(q), csy = RSQVR_BeamTab.V3CapY(q);
				int dn = q < 3 ? 0 : q - 2;
				int fr = RSQVR_BeamData.F_ZFX + 3 + dn;
				double h = RSQVR_BeamData.FR_H(fr) * csy;
				Bill(9, fr, 0, ceilU - h, RSQVR_BeamData.FR_W(fr) * csx, h, 1.0, q == 0);
			}
			if (k >= 6 && k <= 11)
			{
				int q = k - 6;
				Flat(10, 1, RSQVR_BeamTab.V3CeilRingR(q), ceilU - 1, RSQVR_BeamTab.V3RingB(q));
			}
			if (k == 7) Sparks(16, 34, -1.2, 0, 0.5, 0.45, 10, 16, ceilU - 4, ceilU - 1);
			if (k == 9) Sparks(10, 26, -1.0, 0, 0.4, 0.45, 9, 14, ceilU - 4, ceilU - 1);
		}
		else if (k >= 5 && k <= 16)
		{
			// two flames a tic off the column's sides, 150-220 up, while it stands (flames_up k0 5, k1 END + 1)
			int c = k <= 8 ? 0 : (k <= 11 ? 1 : 2);
			int fr = (c == 0 ? RSQVR_BeamData.F_COL2 : (c == 1 ? RSQVR_BeamData.F_COL1 : RSQVR_BeamData.F_COL0)) + 10;
			for (int n = 0; n < 2; n++)
			{
				double z0 = frandom[rsqvrbeam](150, 220);
				double u = clamp((z0 - colH) / (RSQVR_BeamData.FR_H(fr) - colH), 0.0, 1.0);
				double half = RSQVR_BeamData.FR_W(fr) * 0.5 * (1 - u) ** 1.25;
				Flame(z0, half, min(8, END + 5 - k));
			}
		}
		// the impact on the floor
		int zd = RSQVR_BeamData.F_ZFX, zs = RSQVR_BeamData.F_ZFX + 1, zb = RSQVR_BeamData.F_ZFX + 2;
		if (k == 0) Bill(11, zd, 0, 0, RSQVR_BeamData.FR_W(zd) * 0.75, RSQVR_BeamData.FR_H(zd) * 0.75, 1.0, true);
		if (k == 1) Bill(11, zd, 0, 0, RSQVR_BeamData.FR_W(zd), RSQVR_BeamData.FR_H(zd), 1.0, true);
		if (k == 2) Bill(11, zs, 0, 0, RSQVR_BeamData.FR_W(zs) * 0.85, RSQVR_BeamData.FR_H(zs) * 0.85);
		if (k == 3) Bill(11, zs, 0, 0, RSQVR_BeamData.FR_W(zs), RSQVR_BeamData.FR_H(zs));
		if (k >= 4 && k <= 7)
		{
			int q = k - 4;
			double s = q == 0 ? 1.0 : (q == 1 ? 1.05 : (q == 2 ? 1.1 : 1.12));
			Bill(12, zb, 0, 0, RSQVR_BeamData.FR_W(zb) * s, RSQVR_BeamData.FR_H(zb) * s, q == 0 ? 1.0 : (q == 1 ? 0.8 : (q == 2 ? 0.6 : 0.35)));
		}
		// the final pop as it narrows away
		if (j == 5) Sparks(12, 4, 2, 5, 2.2, 0.45, 6, 11, 0, 6);
		if (j >= 5 && j <= 7)
		{
			int q = j - 5;
			double s = q == 0 ? 0.45 : (q == 1 ? 0.6 : 0.7);
			Bill(13, zs, 0, 0, RSQVR_BeamData.FR_W(zs) * s, RSQVR_BeamData.FR_H(zs) * s, q == 0 ? 1.0 : (q == 1 ? 0.75 : 0.45));
			Flat(14, 1, q == 0 ? 14 : (q == 1 ? 22 : 28), 0, q);
		}
	}

	// V4 (variants_v2.V4b): six EoS beams appear a tic apart on a ring of 58 around it, spin faster and faster from tic 8,
	// the ring closes from 10 and they merge at 18 (a flash bar); the skull pillar plays 46 tics (its plan: RSQVR_BeamTab
	// V4Plan); the monster white (26-29), light (30), itself (31).
	void V4(int k)
	{
		int MERGE = 18;
		double R = 58.0;
		if (k <= MERGE)
		{
			double rr = R;
			if (k >= 10) { double f = min(1.0, (k - 10) / double(MERGE - 10)); rr = R * (1 - f * f * (3 - 2 * f)); }
			double spin = 1.2 * max(0.0, k - 8.0) ** 2;
			for (int b = 0; b < 6; b++)
			{
				int jb = k - b;
				if (jb < 0) continue;
				double ang = 120 + b * 60 + spin;
				int g = min(jb, 5) + 1;
				double sx = RSQVR_BeamTab.GrowX(g), sy = RSQVR_BeamTab.GrowY(g);
				BillAt(b, RSQVR_BeamData.F_BEAM + jb % 3, (cos(ang) * rr, sin(ang) * rr), 0, 32 * sx, 80 * sy * 0.75);
			}
			Flat(6, 3, rr + 8, 0, 3, 0.8);
			if (k >= 10) Flat(7, 0, max(4.0, rr * 0.6), 0, 2, 0.5);
		}
		int p = k - MERGE;
		if (p >= 0 && p < 46)
		{
			if (p < 9) { Flat(8, 0, 44, 0, 3, 0.9); Flat(9, 0, 28, 0, 2, 0.6); }
			else if (p < 40) { Flat(8, 0, 38, 0, 3, 0.8); Flat(9, 0, 22, 0, 2, 0.5); }
			int fi; double sx, sy, a;
			[fi, sx, sy, a] = RSQVR_BeamTab.V4Plan(p);
			int fr = RSQVR_BeamData.F_SKULL + fi;
			Bill(10, fr, 0, 0, RSQVR_BeamData.FR_W(fr) * sx, RSQVR_BeamData.FR_H(fr) * sy, a);
		}
		if (k >= MERGE + 8 && k <= MERGE + 11) MonSil(-1);
		else if (k == MERGE + 12) MonSil(1);
		if (k == MERGE) Bill(11, RSQVR_BeamData.F_BEAM, 0, 0, 84, 10, 1.0, true);
		if (k == MERGE + 1) Bill(11, RSQVR_BeamData.F_BEAM + 1, 0, 0, 64, 6, 0.7, true);
	}
}

// The mockups' small tables (a class-level static const array does not resolve on this build: each table is local to its
// static function).
class RSQVR_BeamTab play
{
	// EoS growth (variants_v2.growth): 2.0 x 0.1 -> 0.7056 x 1.744 over 6 tics, eased in log space; i = 1..6
	static double GrowX(int i) { double f = 1 - (1 - clamp(i, 1, 6) / 6.0) ** 1.7; return 2.0 * (0.7056 / 2.0) ** f; }
	static double GrowY(int i) { double f = 1 - (1 - clamp(i, 1, 6) / 6.0) ** 1.7; return 0.1 * (1.744 / 0.1) ** f; }
	// V1b's beam: (scale x, scale y, alpha) per tic, 21 tics
	static double, double, double V1S(int k)
	{
		if (k < 6) return GrowX(k + 1), GrowY(k + 1), 1.0;
		if (k < 8) return GrowX(6), GrowY(6), 1.0;
		int j = k - 7;
		return GrowX(6) * 0.84 ** j, GrowY(6), j <= 4 ? 1.0 : 1.0 - 0.1 * (j - 4);
	}
	static int V2FlashR(int k) { static const int T[] = { 7, 14, 21, 28, 34, 39 }; return T[clamp(k, 0, 5)]; }
	static int V2FlashB(int k) { static const int T[] = { 0, 0, 1, 1, 2, 3 }; return T[clamp(k, 0, 5)]; }
	static double V2Peak(int q) { static const double T[] = { 1.4, 1.25, 1.12, 1.0, 1.0 }; return T[clamp(q, 0, 4)]; }
	static int V2Glow(int st, int i) { static const int T[] = { 32, 22, 12, 26, 16, 8, 18, 10, 0, 10, 0, 0 }; return T[clamp(st, 0, 3) * 3 + clamp(i, 0, 2)]; }
	static int V3Glow(int st, int i) { static const int T[] = { 34, 22, 12, 30, 18, 8, 18, 8, 0 }; return T[clamp(st, 0, 2) * 3 + clamp(i, 0, 2)]; }
	static int V3Ceil(int st, int i) { static const int T[] = { 32, 20, 10, 26, 14, 6, 14, 6, 0 }; return T[clamp(st, 0, 2) * 3 + clamp(i, 0, 2)]; }
	static int V3RingR(int k) { static const int T[] = { 20, 27, 33, 38, 41, 43 }; return T[clamp(k, 0, 5)]; }
	static int V3RingB(int k) { static const int T[] = { 0, 1, 1, 2, 2, 3 }; return T[clamp(k, 0, 5)]; }
	static int V3CeilRingR(int q) { static const int T[] = { 24, 34, 42, 48, 52, 55 }; return T[clamp(q, 0, 5)]; }
	static double V3CapX(int q) { static const double T[] = { 1.0, 1.3, 1.55, 1.75, 1.85 }; return T[clamp(q, 0, 4)]; }
	static double V3CapY(int q) { static const double T[] = { 0.6, 0.75, 0.6, 0.45, 0.3 }; return T[clamp(q, 0, 4)]; }
	// V4b's skull pillar plan, 46 tics: (frame 0..18, scale x, scale y, alpha)
	static int, double, double, double V4Plan(int p)
	{
		if (p < 3) { double s = p == 0 ? 0.6 : (p == 1 ? 0.8 : 1.0); return 0, s, s, 1.0; }
		if (p < 6) return 1, 1.0, p == 3 ? 0.85 : (p == 4 ? 0.95 : 1.0), 1.0;
		if (p < 12) { int q = p - 6; return 2 + q / 2, 1.0, (q % 2) == 0 ? 0.9 : 1.0, 1.0; }
		if (p < 34) return 5 + (p - 12) % 11, 1.0, 1.0, 1.0;
		if (p < 43) return 16 + (p - 34) / 3, 1.0, 1.0, 1.0;
		int q = clamp(p - 43, 0, 2);
		return 18, q == 0 ? 0.8 : (q == 1 ? 0.6 : 0.4), 1.0, q == 0 ? 0.75 : (q == 1 ? 0.5 : 0.25);
	}
}
