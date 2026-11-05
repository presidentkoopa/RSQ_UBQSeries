// ============================================================================
// THE REVIVAL FIRE (owner 11-05: "the score, it fires off a column of fire like in the original when we use a life,
// right? ... i wanted an optimized version of that").
//
// THE ORIGINAL, parsed from Dakka's decorate/main/scorestuff.dec and acs/score/score_reward.h (ijon, WTFPL):
// Score_CheckRevival spawns DakkaReviveExplosion 32 above the player and gives RevivalIntervention (all damage x0,
// Powerup.Duration -2 = 70 tics). The explosion plays dakka/revive, does A_Explode(384, 256, no self-damage), then for
// 71 tics turns 2.5 degrees a tic and each tic spawns 8 RevivalFlame (one per 45-degree spoke, 80 out, on the floor,
// rising 2.5 a tic, +-0.5 sideways, alive 48 tics) and 8 RevivalFlameGround (80 out, sliding 0.8..1.2 a tic along the
// ring, 12 tics), then a last burst of 32 rising at 2.0. Every one of those flames spawns a RevivalFlameVisual (a 5-tic
// sprite) every tic it lives: about 1,150 flames and, at the peak, over a thousand sprites alive at once.
//
// THIS ONE draws the same picture with a fixed pool: 16 rising flames (2 per spoke, half a climb apart) and 16 ground
// flames (one every 22.5 degrees, wide and low, so they join into a ring), spawned ONCE when the revival starts and moved by this controller every tic -- each flame climbs, and at the
// top it is sent back to the floor at the ring's angle of that moment, so the climbing flames lag the turning ring and
// the column twists like the original's. The last burst re-launches the same 16 at 22.5-degree steps. 33 actors in all
// (the controller and its 32 flames), one dynamic light, nothing spawned after the first tic. The flames do not deal
// damage of their own (the original's did 1 or 2 a tic inside 64 of each flame); the blast is the original's.
//
// The sprite is doom2.wad's Arch-vile fire (FIRE A-H): Dakka's flame sprite DFLM is not ijon's (its CREDITS give the
// minigun flames as Duke Nukem 3D / Hexen), so it is not carried. Fullbright, additive.
//
// The rising flames are drawn tall (scale 0.6 x 1.0) so the two on a spoke overlap into one tongue of fire.
// (A first pool, 16 + 8 flames all at scale 0.5 / 0.32, read as scattered flames beside the original's solid ring on
// the rig, 11-05; this one is denser. Code only since: not rig-tested, not headset-confirmed.)
//
// IN VR the player stands inside the ring: the ring follows the player and keeps its 80-unit radius (2.5 m), so no
// flame comes nearer the eyes than about 68 units even when the player walks during it.
// ============================================================================

class RS_ScoreReviveFire : Actor
{
	const FIRE_SPOKES    = 8;
	const FIRE_RISERS    = 16;     // 2 per spoke
	const FIRE_GROUNDS   = 16;     // 2 per spoke, every 22.5 degrees
	const FIRE_CLIMB     = 24;     // a rising flame's climb, tics (half the original's 48 at the same 2.5 a tic: a sprite is
	                          // much taller than one of the original's particles, so the column reaches the same height)
	const FIRE_GLIDE     = 12;     // a ground flame's slide, tics (the original's 12)
	const FIRE_TICS = 70;     // the original's firestep > 70
	const FIRE_R    = 80.0;
	const FIRE_SPIN      = 2.5;    // degrees a tic
	const FIRE_RISE      = 2.5;    // units a tic while the ring turns, 2.0 in the last burst (the original's)
	const FIRE_BURSTUP  = 2.0;

	Actor riser[FIRE_RISERS];
	Actor ground[FIRE_GROUNDS];
	double rAng[FIRE_RISERS], rOut[FIRE_RISERS], rSide[FIRE_RISERS], rK[FIRE_RISERS];
	double gAng[FIRE_GROUNDS], gSide[FIRE_GROUNDS];
	int step;
	double spin;
	bool fire;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOTONAUTOMAP
		+FORCERADIUSDMG
		+NODAMAGETHRUST
		Radius 4;
		Height 4;
		RenderStyle "None";
		Obituary "%k witnessed %o's revival.";
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// The revival: the blast now, and the fire if this player has it on ("Revival Fire", rs_score_revivefire).
	static RS_ScoreReviveFire Begin(Actor who, bool withFire)
	{
		if (!who) return null;
		let c = RS_ScoreReviveFire(Actor.Spawn("RS_ScoreReviveFire", who.pos + (0, 0, 32), ALLOW_REPLACE));
		if (!c) return null;
		c.target = who;            // the blast's source: the player, who it never hurts (no XF_HURTSOURCE, as the original)
		c.angle  = who.angle;
		c.spin   = who.angle;
		c.fire   = withFire;
		c.A_Explode(384, 256, 0);
		if (withFire) c.MakePool();
		return c;
	}

	private void MakePool()
	{
		for (int i = 0; i < FIRE_RISERS; i++)
		{
			riser[i] = Actor.Spawn("RS_ScoreReviveFlame", pos, NO_REPLACE);
			if (riser[i]) riser[i].bInvisible = true;
		}
		for (int i = 0; i < FIRE_GROUNDS; i++)
		{
			ground[i] = Actor.Spawn("RS_ScoreReviveFlame", pos, NO_REPLACE);
			if (ground[i]) { ground[i].bInvisible = true; ground[i].Scale = (0.6, 0.4); }
		}
		// one light for the whole column, steady (no flicker: Photosensitive Mode has nothing to cap)
		A_AttachLight('RSScoreRevive', 0, 0xFF7A30, 160, 0, 8, (0, 0, 8));   // point light, LF_ATTENUATE
	}

	override void OnDestroy()
	{
		for (int i = 0; i < FIRE_RISERS; i++) if (riser[i]) riser[i].Destroy();
		for (int i = 0; i < FIRE_GROUNDS; i++) if (ground[i]) ground[i].Destroy();
		Super.OnDestroy();
	}

	override void Tick()
	{
		if (IsFrozen()) return;
		step++;

		// the ring stays round the player (VR: the player is always inside it, never in the flames)
		if (target) SetOrigin(target.pos + (0, 0, 32), true);
		double floor = target ? target.floorz : pos.z - 32;

		if (!fire || step > FIRE_TICS + 1 + FIRE_CLIMB)
		{
			if (step > 8) Destroy();   // the original held its explosion 8 tics past the last flame launch
			return;
		}

		spin += FIRE_SPIN;
		bool ring = step <= FIRE_TICS;

		// the rising flames
		for (int i = 0; i < FIRE_RISERS; i++)
		{
			let f = riser[i];
			if (!f) continue;
			int s = i % FIRE_SPOKES, j = i / FIRE_SPOKES;
			int ph;
			double up;
			if (ring)
			{
				ph = step - 1 - j * (FIRE_CLIMB / 2);
				if (ph < 0) continue;
				ph %= FIRE_CLIMB;
				up = FIRE_RISE;
				if (ph == 0) Launch(i, spin + 45.0 * s, 0.5);
			}
			else
			{
				ph = step - FIRE_TICS - 1;
				up = FIRE_BURSTUP;
				if (ph == 0) Launch(i, spin + 45.0 * s + 22.5 * j, 0.5);
				if (ph >= FIRE_CLIMB) { f.bInvisible = true; continue; }
			}
			double t = ph * rK[i];
			Place(f, rAng[i], FIRE_R + rOut[i] * t, rSide[i] * t, floor + up * t, ph == 0);
			f.frame = clamp(ph * 8 / FIRE_CLIMB, 0, 7);
		}

		// the ground flames, sliding along the ring while it turns
		for (int i = 0; i < FIRE_GROUNDS; i++)
		{
			let f = ground[i];
			if (!f) continue;
			if (!ring) { f.bInvisible = true; continue; }
			int ph = (step - 1 + i * 3) % FIRE_GLIDE;
			bool fresh = ph == 0 || step == 1;   // the first tic sets every one, whatever its phase
			if (fresh) { gAng[i] = spin + 22.5 * i; gSide[i] = frandom(0.8, 1.2); }
			Place(f, gAng[i], FIRE_R, gSide[i] * ph, floor, fresh);
			f.frame = clamp(ph * 3 / FIRE_GLIDE, 0, 2);
		}

		// the light eases out over the last burst
		if (!ring && (step - FIRE_TICS) % 3 == 0)
		{
			int rad = int(160 * (1.0 - double(step - FIRE_TICS) / (FIRE_CLIMB + 1)));
			if (rad > 8) A_AttachLight('RSScoreRevive', 0, 0xFF7A30, rad, 0, 8, (0, 0, 8));
			else A_RemoveLight('RSScoreRevive');
		}
	}

	private void Launch(int i, double a, double spread)
	{
		rAng[i]  = a;
		rOut[i]  = frandom(-spread, spread);    // the original's x velocity, frandom(-0.5, 0.5)
		rSide[i] = frandom(-spread, spread);    // and its y velocity
		rK[i]    = frandom(0.9, 1.1);           // A_ScaleVelocity(random(90, 110) / 100.0)
	}

	// a flame at angle a, r out from the centre, `side` along the ring, at height z
	private void Place(Actor f, double a, double r, double side, double z, bool jump)
	{
		double c = cos(a), s = sin(a);
		Vector3 at = (pos.x + c * r - s * side, pos.y + s * r + c * side, z);
		f.SetOrigin(at, !jump);
		if (jump) f.ClearInterpolation();
		f.bInvisible = false;
	}
}

// One flame of the pool: a sprite and nothing else. The controller places it and picks its frame every tic.
class RS_ScoreReviveFlame : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOTONAUTOMAP
		+BRIGHT
		+DONTSPLASH
		Radius 1;
		Height 1;
		RenderStyle "Add";
		Alpha 0.85;
		XScale 0.6;
		YScale 1.0;
	}

	States
	{
	Spawn:
		FIRE A -1 Bright;
		Stop;
	}

	override void Tick() {}   // no movement, no states: the controller does everything (a pooled sprite costs nothing to think)
}

// The original's RevivalIntervention: no damage at all while the revival plays (70 tics there; here until the last
// burst is done, 70 + 24). The player is in buddha too while lives are held.
class RS_ScoreReviveGuard : Powerup
{
	Default
	{
		Powerup.Duration 95;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive && damage > 0) newdamage = 0;
	}
}
