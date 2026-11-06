// RSQ FlashFlare -- A BURNING FLARE. One dynamic light per flare, and kept cheap (the owner, 11-03: "optimized, as much as
// possible with the dynamic light"):
//   * ONE point light per flare (A_AttachLight on the flare itself), no shadow map (LF_NOSHADOWMAP), never a spot light.
//   * The flicker is not a pulse light re-sized every frame: the size and the colour change every rsqff_flicker tics
//     (4 on the Quest preset, 3 on PCVR), a random step within a few percent; while it sputters, every 2 tics.
//   * A HARD CAP on lit flares (rsqff_cap: 3 Quest, 6 PCVR), the held one counted: when one more is lit, the oldest
//     lying flare goes dark over half a second and burns on as flame and sparks only (RSQFF_Handler.Budget).
//   * Its radius is small-ish (rsqff_radius: 140 Quest, 220 PCVR; saegiru's pulse light was 386-392); "Subdued" doubles
//     it at half the brightness (the soft look the owner liked).
//   * The flame, sparks and smoke are particles (no actors), drawn additive and full bright.
// Saegiru's flare (GLDEFS.flares REDFLARE: colour 1 0.3 0, pulsing 386-392 every 0.1 s, raised 35 units) gave the colour
// and the raised light; the light here sits 12 units over a lying flare so the walls round it light, not only the floor.
//
// The held flare's light is RSQFF_HeldLight, kept at the drawn burning end every tic by the handler; a thrown or dropped
// flare is RSQFF_Flare and carries its own. Both are RSQFF_Burner: the burn clock, the light, the particles.

class RSQFF_Burner : Actor
{
	int burnLeft, burnTotal;   // tics
	int sput;                  // tics of sputter left after the strike
	int litTic;                // when it was struck (the light budget goes dark oldest first)
	bool dark;                 // the budget took its light
	int darkFade;              // tics of the fade to dark left
	bool spent;
	int flickNext;
	double flick;              // the current flicker step (x radius)
	int green;                 // the current colour step
	bool lightOn;
	bool held;                 // the flare in a hand (the budget keeps it lit first)
	transient TextureID texFlame, texSpark, texSmoke;
	transient bool texReady;

	Default { +NOBLOCKMAP +DONTSPLASH +NOTELEPORT }

	static double SNum(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static bool SFlag(String n, bool d) { let c = CVar.FindCVar(n); return c ? c.GetBool() : d; }

	void Ignite(int burn, int sputter)
	{
		burnTotal = max(1, burn);
		burnLeft = burnTotal;
		sput = sputter;
		litTic = level.maptime;
		flick = 1.0;
		green = 70;
		if (SFlag("rsqff_sound", true)) A_StartSound("rsqff/burn", CHAN_BODY, CHANF_LOOPING, 0.28, 1.4);
	}

	// carried on from another burner (the hand's light into the thrown flare)
	void TakeOver(RSQFF_Burner from)
	{
		burnTotal = from.burnTotal; burnLeft = from.burnLeft; sput = from.sput; litTic = from.litTic;
		dark = from.dark; darkFade = from.darkFade; flick = from.flick; green = from.green;
		if (SFlag("rsqff_sound", true)) A_StartSound("rsqff/burn", CHAN_BODY, CHANF_LOOPING, 0.28, 1.4);
	}

	virtual Vector3 TipOffset() { return (0, 0, 0); }
	virtual double LightZ() { return 0; }

	void GoDark()
	{
		if (dark || spent) return;
		dark = true;
		darkFade = 15;
	}

	void LightOff()
	{
		if (lightOn) A_RemoveLight('rsqff');
		lightOn = false;
	}

	virtual void Spend()
	{
		spent = true;
		LightOff();
		A_StopSound(CHAN_BODY);
		if (SFlag("rsqff_sound", true)) A_StartSound("rsqff/out", CHAN_BODY, 0, 0.5, 1.4);
		Smoke(6, true);
	}

	// one burning tic
	void BurnTick()
	{
		if (spent) return;
		if (burnLeft <= 0) { Spend(); return; }
		burnLeft--;
		if (sput > 0) sput--;
		Lamp();
		Particles();
	}

	// THE ONE LIGHT, re-set only on a flicker step (A_AttachLight replaces the light of the same name)
	void Lamp()
	{
		if (dark && darkFade <= 0) { LightOff(); return; }
		bool step = level.maptime >= flickNext;
		if (!step && darkFade <= 0) return;
		int every = sput > 0 ? 2 : clamp(int(SNum("rsqff_flicker", 4)), 1, 35);
		if (step)
		{
			flickNext = level.maptime + every;
			if (sput > 0) flick = frandom[RSQFF_Light](0.25, 0.95);
			else flick = clamp(flick + frandom[RSQFF_Light](-0.07, 0.07), 0.86, 1.06);
			green = clamp(green + random[RSQFF_Light](-12, 12), 45, 95);
		}
		double rad = clamp(SNum("rsqff_radius", 140), 32, 600) * flick;
		double bright = 1.0;
		// the last two seconds it dies away
		int fade = 2 * TICRATE;
		if (burnLeft < fade) rad *= 0.25 + 0.75 * burnLeft / double(fade);
		if (burnLeft < fade) bright = 0.4 + 0.6 * burnLeft / double(fade);
		if (dark) { darkFade--; rad *= max(0.0, darkFade / 15.0); }
		if (SFlag("rsqff_subdued", false)) { rad *= 2; bright *= 0.5; }
		if (rad < 4) { LightOff(); return; }
		Color c = Color(255, int(255 * bright), int(green * bright), int(26 * bright));
		A_AttachLight('rsqff', DynamicLight.PointLight, c, int(rad), 0, DynamicLight.LF_NOSHADOWMAP, (0, 0, LightZ()));
		lightOn = true;
	}

	void Tex()
	{
		if (texReady) return;
		texReady = true;
		texFlame = TexMan.CheckForTexture("RQFFLAM", TexMan.Type_Any);
		texSpark = TexMan.CheckForTexture("RQFSPRK", TexMan.Type_Any);
		texSmoke = TexMan.CheckForTexture("RQFSMOK", TexMan.Type_Any);
	}

	// THE FLAME AND SPARKS: particles at the burning end (no actors). Fewer on the Quest preset's slower flicker.
	void Particles()
	{
		Tex();
		Vector3 t = TipOffset();
		double lv = burnLeft < 2 * TICRATE ? 0.5 : 1.0;
		// the flame: a puff a tic, rising and shrinking
		A_SpawnParticleEx(0xFFFFFF, texFlame, STYLE_Add, SPF_FULLBRIGHT, 7, frandom[RSQFF_Fx](3.0, 4.5) * lv * (sput > 0 ? frandom[RSQFF_Fx](0.4, 1.3) : 1.0),
			0, t.x, t.y, t.z, frandom[RSQFF_Fx](-0.15, 0.15), frandom[RSQFF_Fx](-0.15, 0.15), frandom[RSQFF_Fx](0.25, 0.55), 0, 0, 0.02, 0.95, -1, -0.35);
		if (SFlag("rsqff_sparks", true))
		{
			int n = sput > 0 ? 3 : (level.maptime % 3 == 0 ? 1 : 0);
			for (int i = 0; i < n; i++)
			{
				double sp = sput > 0 ? 2.2 : 1.3;
				A_SpawnParticleEx(0xFFFFFF, texSpark, STYLE_Add, SPF_FULLBRIGHT, random[RSQFF_Fx](9, 16), frandom[RSQFF_Fx](0.8, 1.4), 0, t.x, t.y, t.z,
					frandom[RSQFF_Fx](-sp, sp), frandom[RSQFF_Fx](-sp, sp), frandom[RSQFF_Fx](0.3, sp), 0, 0, -0.12, 1.0, -1, -0.03);
			}
		}
		if (SFlag("rsqff_smoke", false) && level.maptime % 4 == 0) Smoke(1, false);
	}

	void Smoke(int n, bool force)
	{
		if (!force && !SFlag("rsqff_smoke", false)) return;
		Tex();
		Vector3 t = TipOffset();
		for (int i = 0; i < n; i++)
			A_SpawnParticleEx(0xFFFFFF, texSmoke, STYLE_Translucent, 0, 40, frandom[RSQFF_Fx](3, 5), 0, t.x, t.y, t.z + 1,
				frandom[RSQFF_Fx](-0.12, 0.12), frandom[RSQFF_Fx](-0.12, 0.12), frandom[RSQFF_Fx](0.35, 0.6), 0, 0, 0, 0.35, -1, 0.25);
	}

	override void OnDestroy()
	{
		A_StopSound(CHAN_BODY);
		Super.OnDestroy();
	}
}

// THE HELD FLARE'S LIGHT: an invisible point the handler keeps at the drawn burning end (geo.zs Tip) every tic.
class RSQFF_HeldLight : RSQFF_Burner
{
	Default { +NOINTERACTION +NOGRAVITY RenderStyle "None"; }
	override void Tick()
	{
		if (IsFrozen()) return;
		BurnTick();
	}
	override double LightZ() { return 2; }
	States { Spawn: TNT1 A -1; Stop; }
}

// IN THE BLOCKMAP (owner 11-06, BUGS_1.0 item 4: "Cannot target Flare with distance grab"). A Projectile is NOBLOCKMAP by
// default, and RSQ Distance Grab finds what it can take through the blockmap (cone.zs BlockThingsIterator), so a flare on
// the floor was never even seen by its cone, whatever its rule said. -NOBLOCKMAP puts it there; it is not solid, so nothing
// bumps into it. It is a missile only while it flies (Tick below), and Distance Grab takes it once it lies.
// IT HITS (item 4, fire.zs): a flying flare that strikes a monster does a little damage, and with Brutal Doom sets the kinds
// that burn on fire. SHOT OUT (item 11, "Shoot Out Flares", off): a dropped or thrown flare can be shot (SHOOTABLE, never
// auto-aimed at); any damage puts it out (Spend) and it takes none.
// THROWN, DROPPED, LYING. The flight is RSQ Grenade's (thrown.zs, the owner's RS_Grenade numbers; 11-05 05:14 "needs to
// throw like grenade does"): its gravity 0.27 and its lazy tumble (3.5 degrees a tic, the second axis 0.43 of it); the
// bounces stay a flare's, lighter. A projectile that bounces off floors, walls and monsters, then lies down and slides to a
// stop, still burning. It hurts nothing. Burnt out, it lies dark for HUSK seconds (10, fixed) and goes.
class RSQFF_Flare : RSQFF_Burner
{
	const HALF = 3.9;          // map units from the centre to the burning end (11.5 cm x 0.34; models/rsqff/flare.md3)
	const HUSK = 10;           // seconds a spent flare lies before it goes
	int age, spentAt;
	int ownerNum;
	Actor lastHit;             // the monster this flight already struck (once each)

	Default
	{
		Projectile;
		-NOGRAVITY;
		Radius 2;
		Height 2;
		Mass 5;
		Speed 10;
		Damage 0;
		Gravity 0.27;
		+MOVEWITHSECTOR;
		BounceType "Doom";
		BounceFactor 0.35;
		WallBounceFactor 0.3;
		+BOUNCEONACTORS;
		+ALLOWBOUNCEONACTORS;
		+CANBOUNCEWATER;
		+THRUGHOST;
		-NOBLOCKMAP;
		+NOBLOOD;
		+NOTAUTOAIMED;
		+DONTTHRUST;
		Health 5;
		BounceSound "rsqff/bounce";
	}

	// FnF's own throw (a missile): the first touch of each monster this flight, while it really flies
	override int SpecialMissileHit(Actor victim)
	{
		if (victim && victim != target && victim != lastHit && victim.bSHOOTABLE && victim.bISMONSTER && victim.Health > 0
			&& vel.Length() > 2.0)
		{
			lastHit = victim;
			RSQFF_Fire.Hit(self, victim, target, true, !spent);
		}
		return -1;
	}

	// SHOT OUT: any damage puts a burning flare out; it never takes any
	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (bSHOOTABLE && !spent)
		{
			if (RSQFF_Fire.Debug()) Console.Printf("RSQFF shot out t%d: %s (%d %s damage)", level.maptime, inflictor ? inflictor.GetClassName() : 'nothing', damage, mod);
			Spend();
			bSHOOTABLE = false;
		}
		return 0;
	}

	// the burning end, from the centre along where the flare points
	override Vector3 TipOffset()
	{
		double cp = cos(pitch);
		return (cos(angle) * cp * HALF, sin(angle) * cp * HALF, -sin(pitch) * HALF + 0.6);
	}
	override double LightZ() { return 12; }

	override void Spend()
	{
		Super.Spend();
		spentAt = level.maptime;
		SetStateLabel("Spent");
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || IsFrozen()) return;
		age++;
		// SHOOT OUT FLARES (rsqff_shootout): shootable while it burns, unless something holds it (pass-through)
		if (age % 8 == 1)
		{
			bool shoot = !spent && !bTHRUACTORS && SFlag("rsqff_shootout", false);
			if (bSHOOTABLE != shoot) bSHOOTABLE = shoot;
		}
		bool grounded = pos.z <= floorz + 0.25 || bOnMobj;
		// at rest it is no longer a missile (RSQ Grenade thrown.zs: a missile that rolls into a wall would die on it)
		if (bMissile && (!bBOUNCEONWALLS || (grounded && abs(vel.z) < 0.6))) { bMissile = false; lastHit = null; }
		if (!grounded)
		{
			pitch += 3.5;           // RSQ Grenade thrown.zs: about one lazy turn per two seconds
			roll += 3.5 * 0.43;
		}
		else
		{
			// lying: the burning end a touch up, the short way round; slides to a stop
			pitch = Normalize180(pitch - Normalize180(pitch + 4) * 0.3);
			roll = 0;
			vel.x *= 0.8;
			vel.y *= 0.8;
			if (vel.xy.Length() < 0.12) { vel.x = 0; vel.y = 0; }
		}
		if (!spent) BurnTick();
		else if (level.maptime - spentAt > HUSK * TICRATE) Destroy();
	}

	States
	{
	Spawn:
		QFFW A -1;
		Stop;
	Spent:
		QFFW B -1;
		Stop;
	Unlit:
		QFFW C -1;
		Stop;
	}
}
