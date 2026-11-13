// RSQ Grenade -- THE EXPLOSIONS: what plays when a barrel or a grenade goes off, where, how big, in what colour, and
// what the room does to it (owner 11-09: "ensure RSQ Grenade has options for explosion customization like colors and
// reactivity and context"; the designs he approved: the grenade blast "very pleased with all four grenade tosses",
// the contexts "i approve all barrel designs"; and "beautiful dynamic lights for these explosions ... optimized").
//
// ONE DIRECTOR A BLAST (RSQGN_Boom). It looks at the room once, picks the sequences (barrel_data.zs) and starts their
// players (barrel.zs RSQGN_BarrelFX), and runs the few things that are not data: the grenade's shrapnel, the bubbles
// under water, the blast's ONE light, the scorch decal, the chain's screen kick, and the kills (Kill Colour, Crowd).
// NOTHING HERE TOUCHES GAMEPLAY: the damage stays each blast's own A_Explode (the barrel's, thrown.zs Blast for the
// grenade); this file only looks. NO SLOW MOTION HERE: one home per mechanic (WHO_OWNS_WHAT.md) -- RSQ SlowMo owns the
// time of a barrel's blast (its Barrel Multi-Kill, Chain Reaction, Barrel Near You cues) and of a grenade's (Grenade Blast),
// clock.zs ~1490-1600; it reads the same deaths this file reads (a barrel's A_Explode is its own inflictor), and our
// barrel is still an ExplosiveBarrel to it.
//
// NETPLAY: every setting is a SERVER cvar and every random number comes from the named generator RSQGNBarrel, so every
// machine spawns the same effects (barrel.zs header says why). Particles and lights are client effects of play code
// that runs the same everywhere.
//
// THE PARTS
//   RSQGN_Fx      the settings (CVARINFO.txt: rsqgn_blast_style, rsqgn_fx_*, rsqgn_ctx*, rsqgn_chain_*, rsqgn_crowd_*)
//   RSQGN_Tint    Explosion Colour: the tint names (TRNSLATE.txt, generated) and colours
//   RSQGN_Boom    the director
//   RSQGN_ScorchMark   the wall scorch's decal shooter
//   RSQGN_GibFlash     a one-tic helper

// =====================================================================================================================
// THE SETTINGS (read when a blast starts; server cvars)
// =====================================================================================================================
class RSQGN_Fx play
{
	const LIGHT_CAP = 8;   // explosion lights alive at once, at most (past it a new blast goes without: owner, "optimized")

	static bool B(String n, bool d) { let c = CVar.FindCVar(n); return c ? c.GetBool() : d; }
	static int N(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }

	// Grenade Explosion: 1 New (this file), 0 Original (blast.zs, the UAC Survival Pack's)
	static bool NewGrenade() { return N("rsqgn_blast_style", 1) != 0; }
	// Explosion Colour: 0 Normal, 1 Room Complement, 2 Kill Colour, 3 Grenade Kind
	static int ColourMode() { return clamp(N("rsqgn_fx_colour", 0), 0, 3); }
	// Barrel Explosion Size and Barrel Blast Radius (owner 11-12 01:22), both multipliers
	static double BarrelSize() { let c = CVar.FindCVar("rsqgn_barrel_size"); return c ? clamp(c.GetFloat(), 0.5, 4.0) : 2.0; }
	static double BarrelReach() { let c = CVar.FindCVar("rsqgn_barrel_radius"); return c ? clamp(c.GetFloat(), 1.0, 3.0) : 1.5; }
	// Explosion Lights: 0 Off, 1 Simple (one flash), 2 Full (stepped)
	static int Lights() { return clamp(N("rsqgn_fx_lights", 2), 0, 2); }
	// a context's row, under the Contexts master switch
	static bool Ctx(String row) { return B("rsqgn_ctx", true) && B(row, true); }

	// CHAIN ESCALATION (chain.py LINKS): the blink before a chained barrel goes off, 10 8 6 6 4 tics down the chain
	// (the look only: the barrel stands longer, the blast keeps stock's tic, barrel.zs Death)
	static bool Escalates() { return Ctx("rsqgn_ctx_chain") && B("rsqgn_chain_escalate", true); }
	// the Kinetic sound: a barrel's (Barrel Sound, default Kinetic) or a grenade's (Grenade Sound, default Kinetic)
	static bool Kinetic(bool barrel)
	{
		let c = CVar.FindCVar(barrel ? "rsqgn_barrel_sound" : "rsqgn_grenade_sound");
		if (!c) return true;
		return barrel ? c.GetInt() == 2 : c.GetInt() == 0;
	}

	// Chain Mega Every / Chain Mushroom Every (0: never)
	static int ChainEvery(Name cv, int def) { let c = CVar.FindCVar(cv); return c ? max(0, c.GetInt()) : def; }

	// THE BLAST RADIUS DOWN A CHAIN (owner 11-10: "the radius of damage for the 3rd 4th and 5th explosion would be
	// larger"): stock 128 for the first two, then 160, 192 and 224 from the fifth on (Chain Escalation; the damage stays
	// the stock 128 at the centre)
	static int ChainRadius(int depth)
	{
		if (!Escalates() || depth < 2) return 128;
		return depth == 2 ? 160 : (depth == 3 ? 192 : 224);
	}

	static int BlinkFor(int depth)
	{
		static const int BL[] = { 10, 8, 6, 6, 4 };
		if (depth <= 0 || !Escalates()) return 10;
		return BL[min(depth, 4)];
	}

	// the sequences whose art takes the blast's tint (the fire); water, liquids, gore keep their own colours
	static bool Tintable(int seq)
	{
		return seq < RSQGN_BarrelData.BARRELS || seq == RSQGN_BarrelData.G_FLOOR || seq == RSQGN_BarrelData.G_AIR
			|| seq == RSQGN_BarrelData.G_SKEET || seq == RSQGN_BarrelData.X_CEILING || seq == RSQGN_BarrelData.X_SKY
			|| seq == RSQGN_BarrelData.X_WALLRUN;
	}

	// RSQ ACCESSIBILITY (its README: Photosensitive Mode; Comfort Vignette): read by name, nothing without it
	static bool Photosafe() { return N("rsqa_photosafe", 0) != 0; }
	static bool MotionSensitive() { return N("rsqa_vignette", 0) > 0; }

	// another mod's service by its class name (ServiceIterator.Find matches a PART of the name: check what comes back)
	static Service Svc(String cls)
	{
		let it = ServiceIterator.Find(cls);
		Service s;
		while (s = it.Next())
		{
			String n = s.GetClassName();
			if (n == cls) return s;
		}
		return null;
	}
}

// =====================================================================================================================
// EXPLOSION COLOUR. A tint is a TRNSLATE translation by name (TRNSLATE.txt's generated block, Grenade/tools/blast_export.py
// trnslate_block): every colour kept as its brightness, black -> the tint colour x1.5 + 0.35 a channel. WHY TRANSLATIONS
// (not pre-baked tinted sprite sets): one set of sprites serves 33 tints (8 kinds, 13 tiers, 12 room hues) at no size
// cost, and a live layer can change tint mid-blast (Kill Colour) by changing its Translation. The cost: on a true-colour
// PNG the engine reduces the sprite to the game palette before it translates it -- flat pixel-art colours survive that
// (the barrels' RSQGN_BarrelHot already relies on it for BAR1). Particles cannot take a translation: Of() applies the
// same rule to their colour. A WHITE FLASH IS NEVER TINTED (barrel_data.zs T_W marks those frames).
// =====================================================================================================================
class RSQGN_Tint play
{
	// RSQ Monsters' ladder (1 Common .. 13 White, numbered by STRENGTH since 11-11: 5 Cyan 6 Brown 7 Yellow 8 FireBlu 9 Gray
	// 10 Red 11 Abyss 12 Black 13 White) carries no tint colours; its representative colours (RS_MonsterMaster.zs
	// RS_TierForColour) are this 13-entry table, kept here and in blast_export.py TIER_COL only. Each colour keeps its
	// value; the order follows the ladder. Kill Colour takes the HIGHEST tier killed, so the strongest monster's colour.
	static int TierRGB(int t)
	{
		static const int C[] = { 0xC8C8C8, 0x3CDC46, 0x3C78FF, 0xAA46E6, 0x3CF0F0, 0x8C5A28, 0xFFC828, 0x28A0DC, 0x828282,
			0xE62828, 0x46146E, 0x191919, 0xFFFFFF };
		return (t >= 1 && t <= 13) ? C[t - 1] : -1;
	}
	// Room Complement's 12 hues (blast_export.py hue_rgb: HSV(i/12, 0.85, 1))
	static int HueRGB(int i)
	{
		static const int C[] = { 0xFF2626, 0xFF9226, 0xFFFF26, 0x92FF26, 0x26FF26, 0x26FF92, 0x26FFFF, 0x2692FF, 0x2626FF,
			0x9226FF, 0xFF26FF, 0xFF2692 };
		return C[clamp(i, 0, 11)];
	}

	// a colour through a tint (the TRNSLATE rule), for particles; tint < 0: unchanged
	static int Of(int rgb, int tint)
	{
		if (tint < 0) return rgb;
		double l = (((rgb >> 16) & 255) * 0.3 + ((rgb >> 8) & 255) * 0.59 + (rgb & 255) * 0.11) / 255.0;
		int r = int(clamp(l * (((tint >> 16) & 255) / 255.0 * 1.5 + 0.35), 0.0, 1.0) * 255);
		int g = int(clamp(l * (((tint >> 8) & 255) / 255.0 * 1.5 + 0.35), 0.0, 1.0) * 255);
		int b = int(clamp(l * ((tint & 255) / 255.0 * 1.5 + 0.35), 0.0, 1.0) * 255);
		return (r << 16) | (g << 8) | b;
	}

	// ROOM COMPLEMENT (colour.py comp: the hue turned half way round): the hue step (0..11) opposite rgb, -1 for a grey
	static int ComplementStep(int rgb)
	{
		double r = ((rgb >> 16) & 255) / 255.0, g = ((rgb >> 8) & 255) / 255.0, b = (rgb & 255) / 255.0;
		double mx = max(r, max(g, b)), mn = min(r, min(g, b));
		if (mx <= 0 || (mx - mn) / mx < 0.15) return -1;
		double h;
		double d = mx - mn;
		if (mx == r) h = (g - b) / d;
		else if (mx == g) h = 2 + (b - r) / d;
		else h = 4 + (r - g) / d;
		h *= 60;
		if (h < 0) h += 360;
		h = h >= 180 ? h - 180 : h + 180;
		return int(h / 30 + 0.5) % 12;
	}
}

// =====================================================================================================================
// THE DIRECTOR: one a blast
// =====================================================================================================================
class RSQGN_Boom : Actor
{
	Actor src;              // A_Explode's inflictor: the barrel, the thrown grenade, the grenade gone off in the hand
	bool isBarrel, air, skeet;
	int kind, depth, age, life, mainSeq;
	double yaw, k;
	Vector2 axis;
	Array<RSQGN_BarrelFX> fxs;      // the sequences it started (each a player, barrel.zs)

	// ---- THE ROOM (looked at once, at the blast) ----
	bool wallOn, ceilOn, skyOn, waterOn;
	int liquid;             // 0 none, 1 nukage, 2 lava, 3 blood
	Vector2 wallN;          // the wall's normal, out into the room
	Vector3 wallP;          // the wall point nearest the blast, at its foot height
	double wallAng, ceilZ;

	// ---- THE COLOUR ----
	Name tintName;          // 'None' or a TRNSLATE name (RSQGN_K*, RSQGN_T*, RSQGN_H*)
	int tintRGB;            // its colour (-1 none): particles, the light
	int colourMode, bestTier;

	// ---- THE KILLS ----
	Array<Actor> victims;
	bool crowdOn, crowdFired;

	// ---- THE LIGHT (one a blast) ----
	bool lit;
	int lightMode, lightRad, lastCol, lastStr, lastRad;
	double lightZ;

	// ---- THE SHRAPNEL (seqg.Shrapnel; under water ctx_g.WaterShrapnel) ----
	Array<double> shX, shY, shZ, shVX, shVY, shVZ, shGone, shWallAt, shWNX, shWNY;
	Array<int> shT0, shLife, shBig, shHit, shRetrace;
	// ---- THE BUBBLES (ctx_a.Bubbles) ----
	Array<double> buX, buY, buZ, buV, buS;
	Array<int> buT;

	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+NOTELEPORT
		+DONTSPLASH
		+CLIENTSIDEONLY
		+NOTONAUTOMAP
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// =================================================================================================================
	// A BARREL goes off (barrel.zs RSQGN_Barrel.A_RSQGN_Blast, before its A_Explode)
	// =================================================================================================================
	static RSQGN_Boom ForBarrel(Actor barrel)
	{
		// the two layered blasts (EoS layers two: the second low and pitched down) and the distant one on its own channel
		Sound nearSnd = "rsqgn/barrel/near";
		let sc = CVar.FindCVar("rsqgn_barrel_sound");
		int sm = sc ? sc.GetInt() : 2;
		if (sm == 1) nearSnd = "rsqgn/barrel/test";        // owner 11-09 test candidate
		else if (sm == 2) nearSnd = "rsqgn/k/boom";        // Kinetic (owner 11-10): his boom, then pops on the child bursts
		barrel.A_StartSound(nearSnd, CHAN_AUTO);
		barrel.A_StartSound(nearSnd, CHAN_6, CHANF_OVERLAP, 0.6, ATTN_NORM, 0.7);
		if (sm == 2)
		{
			let rb = RSQGN_Barrel(barrel);
			int dep = rb ? rb.rsqgnDepth : 0;
			RSQGN_Pops.Go(barrel.pos, 2 + min(dep, 3), 2, 3);   // two pops, one more for each link down a chain (to five)
		}
		barrel.A_StartSound("rsqgn/barrel/far", CHAN_7);
		let b = RSQGN_Boom(Actor.Spawn("RSQGN_Boom", barrel.pos));
		if (!b) return null;
		b.src = barrel;
		b.isBarrel = true;
		b.kind = -1;
		let rb = RSQGN_Barrel(barrel);
		b.depth = rb ? rb.rsqgnDepth : 0;
		b.Begin(barrel);
		return b;
	}

	// =================================================================================================================
	// A GRENADE goes off (kinds.zs RSQGN_Kind.Look, before thrown.zs Blast's A_Explodes). `at`: the thrown grenade or
	// the hand blast; k: its kind
	// =================================================================================================================
	static RSQGN_Boom ForGrenade(Actor at, int kind)
	{
		let b = RSQGN_Boom(Actor.Spawn("RSQGN_Boom", at.pos));
		if (!b) return null;
		b.src = at;
		b.kind = kind;
		b.air = at.pos.z - at.floorz > 8;           // shot or gone off above the floor: the mid-air version
		let th = RSQGN_Thrown(at);
		b.skeet = th && th.skeet;                    // shot out of the air (thrown.zs Shot): the gold reward beat
		b.Begin(at);
		return b;
	}

	void Begin(Actor from)
	{
		yaw = frandom[RSQGNBarrel](0, 360);
		axis = (cos(yaw), sin(yaw));
		k = 1.0;
		tintName = 'None';
		tintRGB = -1;
		colourMode = RSQGN_Fx.ColourMode();
		double zc = isBarrel ? 24 : (air ? 0 : 18);  // where the blast's heart is above its base (EoS 24 up; seqg Z(18))

		// ---- THE ROOM ----
		if (RSQGN_Fx.B("rsqgn_ctx", true))
		{
			// WATER (ctx_a / ctx_g): the blast point under water -- the exploding thing fully submerged (waterlevel 3)
			waterOn = RSQGN_Fx.Ctx("rsqgn_ctx_water") && ((from && from.waterlevel >= 3) || waterlevel >= 3);
			// WALL: a wall within 40 map units of the blast's heart (8 short traces round it)
			if (RSQGN_Fx.Ctx("rsqgn_ctx_wall")) wallOn = FindWall(zc);
			if (wallOn) { axis = (-wallN.y, wallN.x); yaw = VectorAngle(axis.x, axis.y); }   // it fans out ALONG the wall
			bool sky = CurSector && CurSector.GetTexture(Sector.ceiling) == skyflatnum;
			// LOW CEILING: floor to ceiling under 96 map units, and not sky
			ceilOn = !waterOn && !sky && RSQGN_Fx.Ctx("rsqgn_ctx_ceiling") && ceilingz - floorz < 96;
			ceilZ = ceilingz;
			// OPEN SKY: the sky over the blast
			skyOn = !waterOn && sky && RSQGN_Fx.Ctx("rsqgn_ctx_sky");
			// LIQUID FLOOR: on (or just over) nukage, lava or blood
			if (!waterOn && RSQGN_Fx.Ctx("rsqgn_ctx_liquid") && pos.z - floorz < 16 && CurSector) liquid = LiquidOf(CurSector);
			crowdOn = RSQGN_Fx.Ctx("rsqgn_ctx_crowd");
		}

		// ---- THE COLOUR ----
		// the kind's colour where the kind has a fireball today (Impact, Incendiary; the frag is its own fire), and on
		// every kind with Explosion Colour: Grenade Kind
		if (!isBarrel && kind > 0 && (colourMode == 3 || RSQGN_Kind.Fireball(kind)))
		{
			Name kn = String.Format("RSQGN_K%d", kind);
			SetTint(kn, RSQGN_Kind.Colour(kind));
		}
		if (colourMode == 1) RoomTint();

		// ---- WHAT PLAYS ----
		int s;
		bool finale = false;          // a chain's mega or mushroom barrel (flip.zs)
		int flipSeq = 0;
		double flipK = 1.0;
		double ko = isBarrel ? 1.0 : 0.7;            // a barrel overlay on a grenade (no grenade version was designed): smaller
		if (isBarrel)
		{
			int choice = RSQGN_BarrelSwap.Kind();
			s = (choice >= 5 && choice <= 10) ? choice - 5 : random[RSQGNBarrel](0, RSQGN_BarrelData.BARRELS - 1);
			// CHAIN (owner 11-10): the barrels down a chain grow (#5 x1.25, #6, #6 x1.2, the biggest x1.4); every Chain Mega
			// Every'th barrel (3) is the mega blast MEGA2, every Chain Mushroom Every'th (5) the mushroom mega, big ("make it
			// big"); the mushroom wins when both land. Their place in the barrel tables (cap, debris, light) stays the
			// biggest of the six, which then doesn't play
			if (depth >= 1 && RSQGN_Fx.Escalates())
			{
				int link = depth + 1;                     // the barrel's number down the chain: the one set off first is 1
				int megaN = RSQGN_Fx.ChainEvery("rsqgn_chain_mega", 3), mushN = RSQGN_Fx.ChainEvery("rsqgn_chain_mush", 5);
				if (depth == 1) { s = 0; k = 1.25; }
				else if (depth == 2) { s = 1; k = 1.0; }
				else if (depth == 3) { s = 1; k = 1.2; }
				else { s = RSQGN_BarrelData.BIGGEST; k = 1.4; }
				if (mushN > 0 && link % mushN == 0) { s = RSQGN_BarrelData.BIGGEST; finale = true; flipSeq = RSQGN_FlipData.MUSH; flipK = 1.5; }
				else if (megaN > 0 && link % megaN == 0) { s = RSQGN_BarrelData.BIGGEST; finale = true; flipSeq = RSQGN_FlipData.MEGA; flipK = 1.0; }
			}
		}
		else s = air ? RSQGN_BarrelData.G_AIR : RSQGN_BarrelData.G_FLOOR;
		if (waterOn) s = isBarrel ? RSQGN_BarrelData.X_WATER_B : RSQGN_BarrelData.X_WATER_G;   // the underwater swap: no fire
		// BARRELS TWICE AS LARGE (owner 2026-11-12 01:22: "make our explosions for barrels 2x as large and extend the blast
		// radius"): every barrel blast's art (the six, the chain's bigger links, the mega and the mushroom) is drawn at
		// Barrel Explosion Size (rsqgn_barrel_size, 2.0) times what it was. The look only; the reach is Barrel Blast Radius
		// (barrel.zs A_RSQGN_Blast). A grenade's blast is unchanged.
		if (isBarrel) { double bs = RSQGN_Fx.BarrelSize(); k *= bs; flipK *= bs; }
		// THE NEON CRESCENT WEARS THE ROOM'S COLOUR (owner 11-12 01:22: "our colored barrel explosion could ... breathe with
		// the world (just that one though, having it always be pink clashes with the world sometimes)"): with Explosion
		// Colour on Normal, the Neon Crescent (the one barrel blast with a colour of its own) takes the hue of the room's
		// RSQ Glow In The Dark glow, so it goes with the room it is in. A room with no glow, or no Glow In The Dark: its
		// own pink, as before. The other five stay fire. Row: Neon Crescent: Room Colour (rsqgn_neon_room, on).
		if (isBarrel && !waterOn && !finale && s == NEON_CRESCENT && colourMode == 0 && RSQGN_Fx.B("rsqgn_neon_room", true)) RoomHueTint();
		mainSeq = s;
		if (finale && !waterOn)
		{
			RSQGN_Flip.PlayAt(pos, flipSeq, flipK);
			if (RSQGN_Fx.Kinetic(true))
			{
				// the mega's long roll over the barrel's boom, and the boil's pops
				A_StartSound(flipSeq == RSQGN_FlipData.MUSH ? "rsqgn/k/mush" : "rsqgn/k/mega", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM);
				RSQGN_Pops.Go(pos, flipSeq == RSQGN_FlipData.MUSH ? 7 : 6, 3, 4);
			}
		}
		else RSQGN_BarrelFX.PlayFX(pos, s, self, k, !waterOn);
		if (!waterOn)
		{
			if (skeet) RSQGN_BarrelFX.PlayFX(pos, RSQGN_BarrelData.G_SKEET, self, 1.0);
			if (ceilOn) RSQGN_BarrelFX.PlayFX((pos.x, pos.y, ceilingz), RSQGN_BarrelData.X_CEILING, self, k * ko);
			if (skyOn) RSQGN_BarrelFX.PlayFX(pos, RSQGN_BarrelData.X_SKY, self, k * ko);
			if (wallOn) RSQGN_BarrelFX.PlayFX(pos, RSQGN_BarrelData.X_WALLRUN, self, k * (isBarrel ? 1.0 : 0.8));
			if (liquid > 0) RSQGN_BarrelFX.PlayFX((pos.x, pos.y, floorz), RSQGN_BarrelData.X_NUKAGE + liquid - 1, self, k * (isBarrel ? 1.0 : 0.8));
			if (wallOn) Scorch(zc);
		}
		if (waterOn) Bubbles(zc);
		if (!isBarrel) Shrapnel(zc);

		// THE CHAIN'S KICK (chain.py KICK: from the third link up) -- the stock quake, short and small; never with RSQ
		// Accessibility's Photosensitive Mode or a Comfort Vignette set
		if (isBarrel && depth >= 2 && RSQGN_Fx.Ctx("rsqgn_ctx_chain") && RSQGN_Fx.B("rsqgn_chain_kick", true)
			&& !RSQGN_Fx.Photosafe() && !RSQGN_Fx.MotionSensitive())
		{
			A_QuakeEx(0, 0, depth >= 4 ? 2 : 1, depth >= 4 ? 7 : (depth == 3 ? 4 : 3), 0, 640, "", QF_SCALEDOWN);
			RSQGN_Buzzer.QuakeFelt(self, 640);   // RSQ_Accessibility's Rumble Backup, by name (weapon.zs)
		}

		// ---- THE LIGHT ----
		lightMode = RSQGN_Fx.Lights();
		lightRad = int(RSQGN_BarrelData.Q_LRAD(mainSeq) * k);
		if (lightRad <= 0) lightRad = 160;
		lightZ = isBarrel ? 16 : (air ? 0 : 16);
		let bk = RSQGN_BarrelBook.Get();
		if (lightMode > 0 && bk && bk.lights < RSQGN_Fx.LIGHT_CAP) { lit = true; bk.lights++; }
		lastCol = -1;
		if (bk) bk.booms.Push(self);

		life = 90;
		for (int i = 0; i < fxs.Size(); i++) if (fxs[i]) life = max(life, RSQGN_BarrelData.Q_LEN(fxs[i].seq));
		age = 0;
		Step();
	}

	override void Tick()
	{
		if (IsFrozen()) return;
		age++;
		if (age >= life) { Destroy(); return; }
		Step();
	}

	void Step()
	{
		if (shT0.Size()) StepShrapnel();
		if (buT.Size()) StepBubbles();
		if (lit) LightStep();
	}

	override void OnDestroy()
	{
		LightOff();
		Super.OnDestroy();
	}

	// =================================================================================================================
	// COLOUR
	// =================================================================================================================
	void SetTint(Name n, int rgb)
	{
		if (rgb < 0) return;
		tintName = n;
		tintRGB = rgb;
		lastCol = -1;                                   // the light takes it on its next step
		for (int i = fxs.Size() - 1; i >= 0; i--)
		{
			if (!fxs[i]) { fxs.Delete(i); continue; }
			fxs[i].Retint();
		}
	}

	// ROOM COMPLEMENT: the room's RSQ Glow In The Dark glow (its floor's, else its ceiling's), turned half way round the
	// hue circle. Only with Glow In The Dark loaded and on; a room with no glow keeps Normal.
	void RoomTint()
	{
		let s = RSQGN_Fx.Svc("RSQGD_Service");
		if (!s || s.GetInt("enabled") != 1 || !CurSector) return;
		int g = int(CurSector.GetGlowColor(Sector.floor)) & 0xFFFFFF;
		if (g == 0) g = int(CurSector.GetGlowColor(Sector.ceiling)) & 0xFFFFFF;
		int h = g ? RSQGN_Tint.ComplementStep(g) : -1;
		if (h < 0) return;
		Name hn = String.Format("RSQGN_H%02d", h);
		SetTint(hn, RSQGN_Tint.HueRGB(h));
	}

	// the room's own glow hue (not its complement): the Neon Crescent's colour (Begin)
	const NEON_CRESCENT = 5;    // barrel_data.zs: the six are 0 .. 5 in the owner's order, #10 Neon Crescent the last
	void RoomHueTint()
	{
		let s = RSQGN_Fx.Svc("RSQGD_Service");
		if (!s || s.GetInt("enabled") != 1 || !CurSector) return;
		int g = int(CurSector.GetGlowColor(Sector.floor)) & 0xFFFFFF;
		if (g == 0) g = int(CurSector.GetGlowColor(Sector.ceiling)) & 0xFFFFFF;
		int h = g ? RSQGN_Tint.ComplementStep(g) : -1;
		if (h < 0) return;
		h = (h + 6) % 12;          // ComplementStep turns the hue half way round (6 of the 12 steps): turned back
		Name hn = String.Format("RSQGN_H%02d", h);
		SetTint(hn, RSQGN_Tint.HueRGB(h));
	}

	// =================================================================================================================
	// THE KILLS (barrel.zs RSQGN_BarrelBook.WorldThingDied: a death whose inflictor is this blast's src)
	// =================================================================================================================
	void OnKill(Actor t)
	{
		if (!t || !t.bIsMonster) return;
		// KILL COLOUR (colour.py b): the tier colour of the highest-tier monster it kills, from the tic the kill lands.
		// The tier is RSQ Monsters', asked by name (RSQMN_RosterService "tier"): nothing without RSQ Monsters.
		if (colourMode == 2)
		{
			let s = RSQGN_Fx.Svc("RSQMN_RosterService");
			int tier = s ? s.GetInt("tier", "", 0, 0, t) : -1;
			if (tier > bestTier && tier <= 13)
			{
				bestTier = tier;
				Name tn = String.Format("RSQGN_T%02d", tier);
				SetTint(tn, RSQGN_Tint.TierRGB(tier));
			}
		}
		// CROWD (crowd.py): a blast that kills 3 or more -- each of those deaths a gib burst. Its beat of slow motion is
		// NOT started here: RSQ SlowMo's Barrel Multi-Kill (2+) and Grenade Blast cues own that time (WHO_OWNS_WHAT.md);
		// crowd.py's held-frame flat flash goes with that slow motion and is not drawn either.
		if (!crowdOn || age > 6) return;
		victims.Push(t);
		if (crowdFired) { Gib(t); return; }
		if (victims.Size() < 3) return;
		crowdFired = true;
		for (int i = 0; i < victims.Size(); i++) Gib(victims[i]);
	}

	// a death's gib burst (crowd.py): Meat Grinder's blood burst and chunks, blood bits, and the body's 1-tic white pop.
	// The corpse itself stays (a monster's own death is its mod's; this is drawn over it).
	void Gib(Actor v)
	{
		if (!v) return;
		double h = GetDefaultByType(v.GetClass()).Height;
		RSQGN_BarrelFX.PlayFX(v.pos + (0, 0, h * 0.55), RSQGN_BarrelData.X_GIB, self);
		let f = Actor.Spawn("RSQGN_GibFlash", v.pos);
		if (f)
		{
			f.sprite = v.sprite;
			f.frame = v.frame;
			f.angle = v.angle;
			f.scale = v.scale;
			f.A_SetRenderStyle(0.9, STYLE_Stencil);
			f.SetShade(0xFFFFFF);
		}
	}

	// =================================================================================================================
	// THE ROOM
	// =================================================================================================================
	bool FindWall(double zc)
	{
		FLineTraceData t;
		Vector3 from = pos + (0, 0, zc);
		double best = 40.01;
		bool got = false;
		for (int i = 0; i < 8; i++)
		{
			LineTrace(i * 45.0, 40, 0, TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, t);
			if (t.HitType != TRACE_HitWall || !t.HitLine) continue;
			double d = (t.HitLocation.xy - from.xy).Length();
			if (d >= best) continue;
			Vector2 dl = t.HitLine.delta;
			if (dl.Length() < 0.001) continue;
			Vector2 n = (dl.y, -dl.x);
			n = n.Unit();
			if ((from.xy - t.HitLocation.xy) dot n < 0) n = -n;
			best = d; got = true;
			wallN = n;
			wallP = (t.HitLocation.x, t.HitLocation.y, pos.z);
			wallAng = VectorAngle(n.x, n.y);
		}
		return got;
	}

	// a liquid floor by its flat's name (RSQ Glow In The Dark liquid.zs's lists, cut to the three that were designed),
	// else the map's TERRAIN saying liquid and hurting (nukage)
	static int LiquidOf(Sector s)
	{
		String n = TexMan.GetName(s.GetTexture(Sector.floor));
		n = n.MakeUpper();
		if (n.IndexOf("BLOOD") >= 0 || n.IndexOf("BLOD") >= 0) return 3;
		if (n.IndexOf("LAVA") >= 0 || n.IndexOf("MAGMA") >= 0 || n == "RROCK05" || n == "RROCK06" || n == "RROCK07"
			|| n == "RROCK08" || n == "SLIME09" || n == "SLIME10" || n == "SLIME11" || n == "SLIME12") return 2;
		if (n.IndexOf("NUK") >= 0 || n.IndexOf("ACID") >= 0 || n.IndexOf("TOXIC") >= 0 || n.IndexOf("OOZE") >= 0) return 1;
		if (n.Left(5) == "SLIME" && n != "SLIME13" && n != "SLIME14" && n != "SLIME15" && n != "SLIME16") return 1;
		let td = s.GetFloorTerrain(Sector.floor);
		if (td && td.IsLiquid && s.damageamount > 0) return 1;
		return 0;
	}

	// WALL: the scorch on the wall (ctx_g WallG.fg: hot bands, then soot) -- two decals (DECALDEF.txt), both FADING out
	// on their own faders. Owner 11-09: "its scorch marks need to fade away, not just cut out." They used to be sprayed
	// with A_SprayDecal, which makes engine IMPACT decals: those share one pool with every bullet hole and blood splat,
	// capped by cl_maxdecals (20 on QuestZDoom 17.3), and when the pool is full the engine DESTROYS the oldest one at
	// once (a_decals.cpp DImpactDecal::CheckMax) -- the soot cut out as soon as BD22 sprayed a few more blood decals.
	// Now they are shot the way a map's Decal thing shoots its decal (Decal.SpawnDecal -> ShootDecal(..., permanent)):
	// outside that pool, so nothing cuts them, and the DECALDEF fader fades each one to nothing and removes it.
	void Scorch(double zc)
	{
		RSQGN_ScorchMark.Shoot(pos + (0, 0, zc), wallAng, RSQGN_ScorchMark.ID_SOOT);
		RSQGN_ScorchMark.Shoot(pos + (0, 0, zc), wallAng, RSQGN_ScorchMark.ID_HOT);
	}

	// =================================================================================================================
	// THE LIGHT: one dynamic light a blast, on this actor, in STEPPED beats (owner 11-09: "beautiful dynamic lights ...
	// optimized"). A_AttachLight with LF_NOSHADOWMAP: a plain point light that never renders a shadow map; it is only
	// re-attached when its step changes (an unchanged A_AttachLight is never called), and removed the tic its last beat
	// ends. At most RSQGN_Fx.LIGHT_CAP blasts own a light at once (RSQGN_BarrelBook.lights); past it a blast has none.
	//   punch   tics 0-2 (the flash and its silhouette): white-yellow, full radius (under water: pale cold blue-white)
	//   fire    while the sequence's own light track (barrel_data.zs G_LIGHT) is at half or more: the fire's colour at
	//           that strength -- orange, the tint (Room / Kill / Kind), or the liquid's mix
	//   glow    then, while the track lasts and the embers burn (24 tics): a dim red at 30%, 60% of the radius
	//   off     (under water: 2 cold tics after the punch, then off)
	// Simple: the punch only. Off: none.
	// =================================================================================================================
	void LightStep()
	{
		int col = 0, rad = lightRad;
		double str = 0;
		int env = age < RSQGN_BarrelData.Q_LLEN(mainSeq) ? RSQGN_BarrelData.G_LIGHT(RSQGN_BarrelData.Q_LOFS(mainSeq) + age) : 0;
		if (age < 3) { col = waterOn ? 0xD8ECFF : 0xFFF4C8; str = 1.0; }
		else if (lightMode < 2) str = 0;
		else if (waterOn) { if (age < 5) { col = 0x78C8F0; str = 0.5; } }
		else if (env >= 50) { col = FireCol(); str = env / 100.0; }
		else if (env > 0 || age < 24) { col = GlowCol(); str = 0.3; rad = int(lightRad * 0.6); }
		if (str <= 0) { LightOff(); return; }
		int s100 = int(str * 100);
		if (col == lastCol && s100 == lastStr && rad == lastRad) return;
		lastCol = col; lastStr = s100; lastRad = rad;
		Color c = Color(255, int(((col >> 16) & 255) * str), int(((col >> 8) & 255) * str), int((col & 255) * str));
		A_AttachLight('RSQGNBlast', DynamicLight.PointLight, c, rad, 0, DynamicLight.LF_NOSHADOWMAP, (0, 0, lightZ));
	}

	void LightOff()
	{
		if (!lit) return;
		lit = false;
		A_RemoveLight('RSQGNBlast');
		let bk = RSQGN_BarrelBook.Get();
		if (bk && bk.lights > 0) bk.lights--;
	}

	// the fire's colour: a liquid's mix (liquid.py: fire x .45 + the liquid x .55), the tint at full brightness, or the
	// sequence's own
	int FireCol()
	{
		if (liquid > 0) return RSQGN_BarrelData.Q_LCOL(RSQGN_BarrelData.X_NUKAGE + liquid - 1);
		if (tintRGB >= 0) return BrightOf(tintRGB);
		return RSQGN_BarrelData.Q_LCOL(mainSeq);
	}
	int GlowCol()
	{
		if (liquid > 0 || tintRGB >= 0) return FireCol();
		return 0xC83810;
	}
	static int BrightOf(int rgb)
	{
		int r = (rgb >> 16) & 255, g = (rgb >> 8) & 255, b = rgb & 255;
		int m = max(r, max(g, b));
		if (m <= 0) return 0x404040;   // a black tint (tier 12, Black) lights as a dim grey
		return ((r * 255 / m) << 16) | ((g * 255 / m) << 8) | (b * 255 / m);
	}

	// =================================================================================================================
	// PARTICLES: hard pixels (the player's Particle Style decides square or round: Square is the pixel-art look)
	// =================================================================================================================
	void Pix(Vector3 p, int rgb, double size, int ttl, Vector3 v, Vector3 acc, bool glow, double a)
	{
		FSpawnParticleParams pp;
		pp.color1 = rgb;
		pp.style = glow ? STYLE_Add : STYLE_Translucent;
		pp.flags = glow ? SPF_FULLBRIGHT : 0;
		pp.lifetime = ttl;
		pp.size = size;
		pp.sizestep = 0;
		pp.startalpha = a;
		pp.fadestep = glow ? -1 : 0;
		pp.startroll = 0;
		pp.rollvel = 0;
		pp.rollacc = 0;
		pp.pos = p;
		pp.vel = v;
		pp.accel = acc;
		Level.SpawnParticle(pp);
	}

	// =================================================================================================================
	// THE SHRAPNEL (seqg.Shrapnel, re-simulated): 44 hard streaks, out to 200-255 units in ~5 tics. Each: a launch tic
	// (0 0 0 0 1 1 2), a speed (a big one every 4th, or 60%: 0.68-1.0 x 50 units a tic; else 0.3-0.55 x 50), drag 0.8 a
	// tic, gravity 1.4, 4 sub-steps a tic; the streak is the path of its last tic in flat colour steps by speed (white head
	// over 25 units a tic). On the floor: a ricochet (x0.3 up, x0.55 along), a 2-tic spark cross, a hot pepper mark that
	// cools to a dark speck. Floor version: every 5th skims the floor, the rest go up and out (the mockup's -6..186 deg
	// side angle, laid round a random direction); mirrored pairs. Air version: all round.
	// A WALL stops it in the game (the mockup's floor version had none): a trace along its flight finds the wall, and it
	// ricochets off it (ctx_g WallShrapnel: back at 0.4, 0.7 up) with a spark and a pock that stays -- the WALL context's
	// "sparks bounce off it", here for every grenade, because a fragment through a wall would be wrong anywhere.
	// UNDER WATER (ctx_g.WaterShrapnel): 34, -4..88 deg, 0.5-1 x 44, stopped within a short way (x0.5 a tic), sinking,
	// pale cold streaks, a trail of bubbles; no heat, no marks.
	// =================================================================================================================
	void Shrapnel(double zc)
	{
		static const int T0S[] = { 0, 0, 0, 0, 1, 1, 2 };
		int n = waterOn ? 34 : 44;
		double vmax = waterOn ? 44 : 50;
		for (int i = 0; i < n; i++)
		{
			double yw, el, v;
			int t0 = 0, lf = random[RSQGNBarrel](9, 14), big = (i % 4 == 0) ? 1 : 0;
			if (waterOn)
			{
				if (i % 2 == 0) { yw = frandom[RSQGNBarrel](0, 360); el = frandom[RSQGNBarrel](-4, 88); v = frandom[RSQGNBarrel](0.5, 1.0) * vmax; }
				else { yw = shWNX[i - 1] + 180; el = shWNY[i - 1]; v = shGone[i - 1]; }
				t0 = random[RSQGNBarrel](0, 2) == 2 ? 1 : 0;
				lf = 10;
			}
			else if (air || i % 2 == 0)
			{
				t0 = T0S[random[RSQGNBarrel](0, 6)];
				yw = frandom[RSQGNBarrel](0, 360);
				if (air) el = asin(frandom[RSQGNBarrel](-1, 1));
				else
				{
					double side = (i % 5 == 0) ? frandom[RSQGNBarrel](-6, 10) : frandom[RSQGNBarrel](-6, 186);
					el = side <= 90 ? side : 180 - side;
				}
				v = (big != 0 || frandom[RSQGNBarrel](0, 1) < 0.6) ? frandom[RSQGNBarrel](0.68, 1.0) * vmax : frandom[RSQGNBarrel](0.3, 0.55) * vmax;
			}
			else
			{
				// the floor version's mirrored pair: the other side, about the same speed
				yw = shWNX[i - 1] + 180; el = shWNY[i - 1]; v = shGone[i - 1] * frandom[RSQGNBarrel](0.9, 1.1);
				t0 = shT0[i - 1];
			}
			Vector3 d = (cos(el) * cos(yw), cos(el) * sin(yw), sin(el));
			shX.Push(pos.x + d.x * 3); shY.Push(pos.y + d.y * 3); shZ.Push(pos.z + zc + d.z * 3);
			shVX.Push(d.x * v); shVY.Push(d.y * v); shVZ.Push(d.z * v);
			shT0.Push(t0); shLife.Push(lf); shBig.Push(big); shHit.Push(0); shRetrace.Push(0);
			// (for the pair-maker above, these hold the launch yaw / elevation / speed until the first trace replaces them)
			shWNX.Push(yw); shWNY.Push(el); shGone.Push(v);
			shWallAt.Push(-1);
		}
	}

	// the wall ahead of fragment i along its flight (one trace; again after a ricochet, twice at most): how far it may go
	void TraceAhead(int i)
	{
		Vector3 v = (shVX[i], shVY[i], shVZ[i]);
		double sp = v.Length();
		shGone[i] = 0;
		shWallAt[i] = 1e9;
		if (sp < 0.5 || shRetrace[i] > 2) return;
		shRetrace[i]++;
		FLineTraceData t;
		double reach = sp * 5 + 8;                       // drag 0.8 a tic: it never goes further than 5x a tic's speed
		LineTrace(VectorAngle(v.x, v.y), reach, VectorAngle(v.xy.Length(), -v.z), TRF_ABSPOSITION | TRF_THRUACTORS,
			shZ[i], shX[i], shY[i], t);
		if (t.HitType != TRACE_HitWall || !t.HitLine) return;
		Vector2 dl = t.HitLine.delta;
		if (dl.Length() < 0.001) return;
		Vector2 n = (dl.y, -dl.x);
		n = n.Unit();
		if (v.xy dot n > 0) n = -n;
		shWallAt[i] = (t.HitLocation - (shX[i], shY[i], shZ[i])).Length() - 1;
		shWNX[i] = n.x; shWNY[i] = n.y;
	}

	void StepShrapnel()
	{
		static const int HOT4[] = { 0xFFFFF0, 0xFFE882, 0xFFA528, 0xBE3C00 };
		static const int HOT3[] = { 0xFFE678, 0xFF8C14, 0x962800 };
		static const int HOT2[] = { 0xFF8C1E, 0x8C2400 };
		static const int COLD[] = { 0xEBF5FA, 0x96B9CD, 0x506E82 };
		int live = 0;
		for (int i = 0; i < shT0.Size(); i++)
		{
			int dt = age - shT0[i];
			if (dt < 0) { live++; continue; }
			if (dt >= shLife[i]) continue;
			live++;
			if (dt == 0) TraceAhead(i);
			Vector3 a = (shX[i], shY[i], shZ[i]);
			Vector3 p = a;
			Vector3 v = (shVX[i], shVY[i], shVZ[i]);
			double fz = Level.PointInSector(p.xy).floorplane.ZAtPoint(p.xy);
			if (waterOn)
			{
				p += v;
				shGone[i] += v.Length();
				if (shGone[i] >= shWallAt[i]) shLife[i] = dt;   // the wall stops it (no ricochet under water)
				if (p.z < fz + 1) p.z = fz + 1;
				v *= 0.5; v.z -= 0.32;
			}
			else for (int s = 0; s < 4; s++)
			{
				Vector3 st = v * 0.25;
				p += st;
				v.z -= 1.4 / 4;
				shGone[i] += st.Length();
				if (shGone[i] >= shWallAt[i])              // the wall: ricochet back off it
				{
					Vector2 n = (shWNX[i], shWNY[i]);
					Vector2 h = v.xy - n * 2 * (v.xy dot n);
					v = (h.x * 0.4, h.y * 0.4, v.z * 0.7);
					SparkCross(p, 0xFFF0B4);
					Pix(p + (n.x * 0.5, n.y * 0.5, 0), 0x100E0D, 1.6, 70, (0, 0, 0), (0, 0, 0), false, 0.9);   // the pock
					shX[i] = p.x; shY[i] = p.y; shZ[i] = p.z; shVX[i] = v.x; shVY[i] = v.y; shVZ[i] = v.z;
					TraceAhead(i);
				}
				if (p.z <= fz && v.z < 0)                  // the floor: ricochet low, mark it once
				{
					p.z = fz;
					v = (v.x * 0.55, v.y * 0.55, -v.z * 0.3);
					if (shHit[i] == 0)
					{
						shHit[i] = 1;
						SparkCross(p + (0, 0, 1), 0xFFFAC8);
						Pix(p + (0, 0, 0.5), Tinted(0xFFD76E), 2.4, 9, (0, 0, 0), (0, 0, 0), true, 1.0);                                     // hot, cooling
						Pix(p + (0, 0, 0.4), 0x2C221E, 1.2, 70, (0, 0, 0), (0, 0, 0), false, 0.9);          // the speck that stays
					}
				}
			}
			if (!waterOn) v *= 0.8;
			shX[i] = p.x; shY[i] = p.y; shZ[i] = p.z; shVX[i] = v.x; shVY[i] = v.y; shVZ[i] = v.z;
			// the streak: head at the new position, back along this tic's path, coloured in steps by speed
			double spd = v.Length();
			int nc = 0;
			if (waterOn) { if ((p - a).Length() < 2) continue; nc = 3; }
			else if (spd > 25) nc = 4;
			else if (spd > 11) nc = 3;
			else if (spd > 4) nc = 2;
			else continue;
			double len = (p - a).Length();
			int np = clamp(int(len / 6), 2, 6);
			for (int j = 0; j < np; j++)
			{
				double f = j / double(np - 1);
				int ci = min(nc - 1, int(f * nc));
				int col = waterOn ? COLD[ci] : Tinted(nc == 4 ? HOT4[ci] : nc == 3 ? HOT3[ci] : HOT2[ci]);
				Pix(p + (a - p) * f * 0.95, col, (j == 0 && shBig[i] != 0) ? 3.2 : 2.0, 2, (0, 0, 0), (0, 0, 0), !waterOn, 1.0);
			}
			// under water: a trail of bubbles off each fragment, its first four tics (ctx_g.WaterShrapnel)
			if (waterOn && dt >= 1 && dt <= 4)
				Pix(p, 0xA0D7F5, 1.0, 60, (0, 0, frandom[RSQGNBarrel](0.6, 1.3)), (0, 0, 0.08), false, 1.0);
		}
		if (!live) { shT0.Clear(); }
	}

	// a ricochet's spark: a tiny hard cross, 2 tics
	void SparkCross(Vector3 p, int col)
	{
		col = Tinted(col);
		Pix(p, col, 1.6, 2, (0, 0, 0), (0, 0, 0), true, 1.0);
		for (int s = -1; s <= 1; s += 2)
		{
			Pix(p + (2 * s, 0, 0), col, 1.2, 2, (0, 0, 0), (0, 0, 0), true, 1.0);
			Pix(p + (0, 2 * s, 0), col, 1.2, 2, (0, 0, 0), (0, 0, 0), true, 1.0);
			Pix(p + (0, 0, 2 * s), col, 1.2, 2, (0, 0, 0), (0, 0, 0), true, 1.0);
		}
	}

	int Tinted(int rgb) { return RSQGN_Tint.Of(rgb, tintRGB); }

	// =================================================================================================================
	// THE BUBBLES (ctx_a.Bubbles): born on a growing dome round the blast (the gas pushing out), then they rise, faster
	// as they go. The dome's push is the gas-dome sprite's (in the data); each bubble appears where the dome put it and
	// rises. Their pop on the surface is not drawn (the game cannot find the water's surface over a blast with stock
	// calls): each fades after 40-70 tics instead.
	//   barrel: 64 on a 56-unit dome 24 up at tic 2, 22 on a 24-unit dome 40 higher at tic 11 (water_barrel)
	//   grenade: 70 on a 64-unit dome at tic 2, 30 on a 32-unit dome 48 higher at tic 9 (water_grenade)
	// =================================================================================================================
	void Bubbles(double zc)
	{
		if (isBarrel) { Dome(2, 64, 56, zc, 6); Dome(11, 22, 24, zc + 40, 3); }
		else { Dome(2, 70, 64, zc, 6); Dome(9, 30, 32, zc + 48, 3); }
	}
	void Dome(int start, int n, double R, double zc, int domeT)
	{
		static const int SZ[] = { 8, 8, 8, 16, 16, 16, 24, 24, 32 };   // map units x10: a mockup bubble's 1-4 px
		for (int i = 0; i < n / 2; i++)
		{
			double el = frandom[RSQGNBarrel](0, 90), rad = frandom[RSQGNBarrel](0.55, 1.0) * R, yw = frandom[RSQGNBarrel](0, 360);
			double sz = SZ[random[RSQGNBarrel](0, 8)] * 0.1;
			int t = start + random[RSQGNBarrel](0, 3) + random[RSQGNBarrel](domeT - 2, domeT + 2);
			double v0 = frandom[RSQGNBarrel](0.5, 1.1);
			for (int s = -1; s <= 1; s += 2)
			{
				buX.Push(pos.x + s * cos(el) * cos(yw) * rad); buY.Push(pos.y + s * cos(el) * sin(yw) * rad);
				buZ.Push(pos.z + zc + sin(el) * rad); buV.Push(v0); buS.Push(sz); buT.Push(t);
			}
		}
	}
	void StepBubbles()
	{
		int left = 0;
		for (int i = 0; i < buT.Size(); i++)
		{
			if (buT[i] > age) { left++; continue; }
			if (buT[i] < age) continue;
			double acc = 0.07 * (1 + buS[i] * 0.45);
			Pix((buX[i], buY[i], max(buZ[i], floorz + 1)), 0x9EDBFF, buS[i], random[RSQGNBarrel](40, 70), (0, 0, buV[i]), (0, 0, acc), false, 0.95);
		}
		if (!left) buT.Clear();
	}
}

// the scorch's sprayer: stands where the blast's heart is, faces the wall, sprays, and is gone the same tic
// the scorch's decal shooter: the engine's Decal thing (decal.zs), which shoots a PERMANENT decal (not counted against
// cl_maxdecals, never cut out by it) at the wall 64 units behind it. Its decal is picked by the DECALDEF number in
// args[0] + args[1] * 256; the engine's own BeginPlay shoots before Spawn returns (args still 0), so this one waits
// for Shoot() to set them.
class RSQGN_ScorchMark : Decal
{
	const ID_SOOT = 30471;   // DECALDEF.txt RSQGNScorch
	const ID_HOT = 30472;    // DECALDEF.txt RSQGNScorchHot

	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH Radius 1; Height 1; }

	override void BeginPlay() { }

	// at: a point in front of the wall; facing: the wall's outward normal angle (the decal is shot at facing + 180)
	static void Shoot(Vector3 at, double facing, int id)
	{
		let d = RSQGN_ScorchMark(Actor.Spawn("RSQGN_ScorchMark", at));
		if (!d) return;
		d.angle = facing;
		d.args[0] = id & 255;
		d.args[1] = id >> 8;
		d.SpawnDecal();
		d.Destroy();
	}
}

// the crowd's pop (crowd.py: "the body pops: white flash of its shape"): the monster's own frame, drawn white, 1 tic
class RSQGN_GibFlash : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +BRIGHT +NOTONAUTOMAP Radius 1; Height 1; }
	States { Spawn: TNT1 A 1 Bright; Stop; }   // its sprite and frame are the monster's, set when it is spawned
}
