// HIT SPARKS (owner, 2026-11-06, BUGS_1.0 item 40; the approved plan proof/melee/melee_sprite_plan_kof.png). The community
// sheet "ripped by shezzor", cut and recoloured by tools/hitsheet.py: the sheet's 4-frame hit -- flash > hit-stop black >
// ring -- in three size rows, in the KOF palette (the highlights stay white-hot). The Capcom vs. SNK 2 sparks used until
// 11-06 are gone; kiddolink's bought bursts (below) are unchanged, at the same moments.
//   MZO S/M/L  orange-white   jab, hook, the palm swat; the size row by swing speed (slow small, mid, fast large)
//   MZV S/M/L  violet-white   uppercut (size by speed too), the Hadouken's return (mid)
//   MZBM       blue-white     the Guard soaking a blow
//   MZRM       red-white      a counter punch (the monster in its wind-up), a perfect (Parry, Reflect Guard)
//   MZSH       the orange starburst as drawn, Melee's own gun-butt shove
//   MZDU       dust: Ground Pound, Wall Splat, the uppercut barrel kick (5 frames); the uppercut's launch (the first 2)
//   MZDZ       Heavy Hands' freeze: yellow chicks and stars circling over the monster's head
// VARIETY (owner): each blow picks at random one of three baked rotations (0, 22, 45 degrees: frames A-D, E-H, I-L) and
// a flip, so no two look alike. Drawn as painted (Translucent: the hit-stop frame is black), full bright, billboards;
// times Hit Spark Size (rsqml_spark_size). No blood frames. The four-letter names: MZ** is used by no RSQ pk3.
class RSQML_Spark : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP +FORCEXYBILLBOARD +BRIGHT
		RenderStyle "Translucent";
		Alpha 1.0;
	}

	static Actor Put(String cls, Vector3 at, double size = 1.0)
	{
		Actor a = Actor.Spawn(cls, at, NO_REPLACE);
		if (a)
		{
			CVar cv = CVar.FindCVar("rsqml_spark_size");
			double k = cv ? clamp(cv.GetFloat(), 0.25, 3.0) : 1.0;
			a.Scale *= k * size;
		}
		return a;
	}

	// where a fist met a body: on its skin, on the side the fist came from, at the fist's height, 2 units out
	static Vector3 OnSkin(Actor victim, Vector3 glove)
	{
		if (!victim) return glove;
		Vector2 d = glove.xy - victim.pos.xy;
		double l = d.Length();
		if (l < 0.5) return glove;
		Vector2 xy = victim.pos.xy + d / l * min(l, victim.radius + 2);
		return (xy.x, xy.y, clamp(glove.z, victim.pos.z + 4, victim.pos.z + victim.height));
	}

	// a landed punch: RSQML_Gloves.PK_JAB / PK_HOOK / PK_UPPER; power 0..1 the swing's speed (Deliver's lastPower);
	// counter: the monster was in its attack wind-up. (dir, viewer and hand are kept for callers; the art has no streak.)
	static void Punch(int kind, Vector3 at, Vector3 dir = (0, 0, 0), Actor viewer = null, int hand = 0, double power = 0.5, bool counter = false)
	{
		if (counter) { Put("RSQML_HitRM", at); return; }
		String row = power < 0.34 ? "S" : power < 0.67 ? "M" : "L";
		Put((kind == 2 ? "RSQML_HitV" : "RSQML_HitO") .. row, at);
	}
	static void Hadouken(Vector3 at) { Put("RSQML_HitVM", at); }
	static void Swat(Vector3 at) { Put("RSQML_HitOM", at); }
	// 35 cm from your eyes: half the size a blow's spark is
	static void Guard(Vector3 at) { Put("RSQML_HitBM", at, 0.5); }
	static void Perfect(Vector3 at, double size = 0.5) { Put("RSQML_HitRM", at, size); }
	static void Shove(Vector3 at) { Put("RSQML_HitShove", at); }
	static void Dust(Vector3 at, double size = 1.0) { Put("RSQML_Dust", at, size); }
	static void LaunchDust(Actor mo) { if (mo) Put("RSQML_DustPuff", mo.pos + (0, 0, 4)); }
	// Heavy Hands: chicks and stars circling over its head while it is frozen
	static void Dizzy(Actor mo, int tics)
	{
		if (!mo || tics <= 0) return;
		for (int k = 0; k < 4; k++)
		{
			let d = RSQML_Dizzy(Put("RSQML_Dizzy", mo.pos + (0, 0, mo.height + 4)));
			if (!d) continue;
			d.tracer = mo; d.phase = k * 90.0; d.life = max(tics, 18); d.frame = k;
		}
	}

	// THE VARIETY: one of the three baked rotations, and a flip, at random per blow
	action state A_Variety()
	{
		invoker.bXFlip = random(0, 1) == 1;
		int r = random(0, 2);
		if (r == 0) return ResolveState("R0");
		if (r == 1) return ResolveState("R22");
		return ResolveState("R45");
	}

	States { Spawn: TNT1 A 1; Stop; }
}

// a 4-frame hit: flash, hit-stop, ring (A-D 0 degrees, E-H 22, I-L 45)
class RSQML_HitOS : RSQML_Spark
{
	Default { Scale 0.1081; }
	States
	{
	Spawn: TNT1 A 0 NoDelay A_Variety; Stop;
	R0:  MZOS A 2 Bright; MZOS B 2 Bright; MZOS C 2 Bright; MZOS D 3 Bright; Stop;
	R22: MZOS E 2 Bright; MZOS F 2 Bright; MZOS G 2 Bright; MZOS H 3 Bright; Stop;
	R45: MZOS I 2 Bright; MZOS J 2 Bright; MZOS K 2 Bright; MZOS L 3 Bright; Stop;
	}
}
class RSQML_HitOM : RSQML_HitOS
{
	States
	{
	R0:  MZOM A 2 Bright; MZOM B 2 Bright; MZOM C 2 Bright; MZOM D 3 Bright; Stop;
	R22: MZOM E 2 Bright; MZOM F 2 Bright; MZOM G 2 Bright; MZOM H 3 Bright; Stop;
	R45: MZOM I 2 Bright; MZOM J 2 Bright; MZOM K 2 Bright; MZOM L 3 Bright; Stop;
	}
}
class RSQML_HitOL : RSQML_HitOS
{
	States
	{
	R0:  MZOL A 2 Bright; MZOL B 2 Bright; MZOL C 2 Bright; MZOL D 3 Bright; Stop;
	R22: MZOL E 2 Bright; MZOL F 2 Bright; MZOL G 2 Bright; MZOL H 3 Bright; Stop;
	R45: MZOL I 2 Bright; MZOL J 2 Bright; MZOL K 2 Bright; MZOL L 3 Bright; Stop;
	}
}
class RSQML_HitVS : RSQML_HitOS
{
	States
	{
	R0:  MZVS A 2 Bright; MZVS B 2 Bright; MZVS C 2 Bright; MZVS D 3 Bright; Stop;
	R22: MZVS E 2 Bright; MZVS F 2 Bright; MZVS G 2 Bright; MZVS H 3 Bright; Stop;
	R45: MZVS I 2 Bright; MZVS J 2 Bright; MZVS K 2 Bright; MZVS L 3 Bright; Stop;
	}
}
class RSQML_HitVM : RSQML_HitOS
{
	States
	{
	R0:  MZVM A 2 Bright; MZVM B 2 Bright; MZVM C 2 Bright; MZVM D 3 Bright; Stop;
	R22: MZVM E 2 Bright; MZVM F 2 Bright; MZVM G 2 Bright; MZVM H 3 Bright; Stop;
	R45: MZVM I 2 Bright; MZVM J 2 Bright; MZVM K 2 Bright; MZVM L 3 Bright; Stop;
	}
}
class RSQML_HitVL : RSQML_HitOS
{
	States
	{
	R0:  MZVL A 2 Bright; MZVL B 2 Bright; MZVL C 2 Bright; MZVL D 3 Bright; Stop;
	R22: MZVL E 2 Bright; MZVL F 2 Bright; MZVL G 2 Bright; MZVL H 3 Bright; Stop;
	R45: MZVL I 2 Bright; MZVL J 2 Bright; MZVL K 2 Bright; MZVL L 3 Bright; Stop;
	}
}
class RSQML_HitBM : RSQML_HitOS
{
	States
	{
	R0:  MZBM A 2 Bright; MZBM B 2 Bright; MZBM C 2 Bright; MZBM D 3 Bright; Stop;
	R22: MZBM E 2 Bright; MZBM F 2 Bright; MZBM G 2 Bright; MZBM H 3 Bright; Stop;
	R45: MZBM I 2 Bright; MZBM J 2 Bright; MZBM K 2 Bright; MZBM L 3 Bright; Stop;
	}
}
class RSQML_HitRM : RSQML_HitOS
{
	States
	{
	R0:  MZRM A 2 Bright; MZRM B 2 Bright; MZRM C 2 Bright; MZRM D 3 Bright; Stop;
	R22: MZRM E 2 Bright; MZRM F 2 Bright; MZRM G 2 Bright; MZRM H 3 Bright; Stop;
	R45: MZRM I 2 Bright; MZRM J 2 Bright; MZRM K 2 Bright; MZRM L 3 Bright; Stop;
	}
}
// the gun-butt shove's starburst, as drawn (A-E 0 degrees, F-J 22, K-O 45)
class RSQML_HitShove : RSQML_Spark
{
	Default { Scale 0.1209; }
	States
	{
	Spawn: TNT1 A 0 NoDelay A_Variety; Stop;
	R0:  MZSH ABCDE 2 Bright; Stop;
	R22: MZSH FGHIJ 2 Bright; Stop;
	R45: MZSH KLMNO 2 Bright; Stop;
	}
}
// the dust cloud (5 frames; a flip only), and its first two frames as the uppercut's launch puff
class RSQML_Dust : RSQML_Spark
{
	Default { Scale 0.2097; -BRIGHT }
	States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.bXFlip = random(0, 1) == 1; }
		MZDU ABCDE 3;
		Stop;
	}
}
class RSQML_DustPuff : RSQML_Dust { States
	{
	Spawn:
		TNT1 A 0 NoDelay { invoker.bXFlip = random(0, 1) == 1; }
		MZDU AB 3;
		Stop;
	}
}
// Heavy Hands' dizzy: frame 0-1 a chick, 2-3 a star, circling over the frozen monster's head for its freeze
class RSQML_Dizzy : RSQML_Spark
{
	double phase;
	int life;
	Default { Scale 0.0938; }
	override void Tick()
	{
		if (!tracer || tracer.bDestroyed || tracer.health <= 0 || --life <= 0) { Destroy(); return; }
		double a = phase + level.maptime * 18.0;
		double r = max(8.0, tracer.radius * 0.6);
		SetOrigin(tracer.pos + (cos(a) * r, sin(a) * r, tracer.height + 4 + sin(a * 2) * 1.5), true);
	}
	States { Spawn: MZDZ ABCD -1 Bright; Stop; }
}

// ---- THE BURSTS (2026-11-02): kiddolink's "VFX Hit Impact" (paid, the owner's: "I want that one in there for sure"),
// built by tools/bursts.py. The art rule (GBOVR_TREES.md 4): the hit spark above is the blow on every punch; a burst is
// what a blow DOES, only on the moments that earn it: combos, criticals, perfects, the elements, the launches. 40 map
// units across at size 1 (callers: 0.75 a combo step, 1.5 a Finisher or a critical, 2 the Guard's release), times Hit
// Spark Size. FRAMES BY LEVEL: args[0] is how many frames play (0 = all): 3 at a node's level 1, two more a level, the
// whole burst at its cap (ByLevel). Drawn as painted (Translucent, the art's own alpha), full bright.
//   RSQML_Burst1  impact 1, as drawn            combos (Three-Hit, Dempsey)
//   RSQML_Burst2  impact 2, as drawn            criticals
//   RSQML_Burst3  impact 3, as drawn            launches (the uppercut's lift)
//   RSQML_Burst4  impact 4, white               perfects (Parry, Reflect Guard), Juggle, Backstab, Clear Out
//   RSQML_Burst5  impact 5, as drawn            the big ones (Finisher, Meteor, Ground Pound, Slam)
//   RSQML_BurstE  impact 5, white               Explosive Fist, the Guard's release
//   RSQML_BurstF  impact 2, frost               Frost Fist's shatter
//   RSQML_BurstS  impact 4, shock yellow        Shock Fist's arc
//   RSQML_BurstR  impact 1, fire                Fire Fist
//   RSQML_BurstH  impact 2, red                 Headshot, Blood Rush, an earned Berserk
// RSQ Gun Bonsai VR spawns them by class name (RSQM.Burst) and sets args[0] and the size the same way.
class RSQML_Burst : RSQML_Spark
{
	int shown;
	Default { RenderStyle "Translucent"; Alpha 1.0; }

	static Actor At(String cls, Vector3 at, double size = 1.0, int frames = 0)
	{
		Actor a = Put(cls, at);
		if (a) { a.Scale *= size; a.args[0] = frames; }
		return a;
	}
	// 3 frames at level 1, two more a level, the whole burst at the node's cap
	static int ByLevel(int lv, int cap) { return lv >= cap ? 0 : clamp(1 + 2 * lv, 3, 9); }

	action state A_Burst()
	{
		invoker.shown++;
		if (invoker.args[0] > 0 && invoker.shown > invoker.args[0]) return ResolveState("Null");
		return null;
	}
}
class RSQML_Burst1 : RSQML_Burst { Default { Scale 0.4348; } States { Spawn: MLK1 ABCDEFGH 2 Bright A_Burst; Stop; } }
class RSQML_Burst2 : RSQML_Burst { Default { Scale 0.4167; } States { Spawn: MLK2 ABCDEFGH 2 Bright A_Burst; Stop; } }
class RSQML_Burst3 : RSQML_Burst { Default { Scale 0.5556; } States { Spawn: MLK3 ABCDEFGHI 2 Bright A_Burst; Stop; } }
class RSQML_Burst4 : RSQML_Burst { Default { Scale 0.4348; } States { Spawn: MLK4 ABCDEFGHI 2 Bright A_Burst; Stop; } }
class RSQML_Burst5 : RSQML_Burst { Default { Scale 0.4444; } States { Spawn: MLK5 ABCDEFGH 2 Bright A_Burst; Stop; } }
class RSQML_BurstE : RSQML_Burst { Default { Scale 0.4444; } States { Spawn: MLKE ABCDEFGH 2 Bright A_Burst; Stop; } }
class RSQML_BurstF : RSQML_Burst { Default { Scale 0.4167; } States { Spawn: MLKF ABCDEFGH 2 Bright A_Burst; Stop; } }
class RSQML_BurstS : RSQML_Burst { Default { Scale 0.4348; } States { Spawn: MLKS ABCDEFGHI 2 Bright A_Burst; Stop; } }
class RSQML_BurstR : RSQML_Burst { Default { Scale 0.4348; } States { Spawn: MLKR ABCDEFGH 2 Bright A_Burst; Stop; } }
class RSQML_BurstH : RSQML_Burst { Default { Scale 0.4167; } States { Spawn: MLKH ABCDEFGH 2 Bright A_Burst; Stop; } }

// THE SHOCK RING (owner 2026-11-10): the Force Push ring (RSQ Saber's CombatFX shockwave UXRG, 17 frames that grow,
// copied here as RQRG so Melee needs no Saber) for CLEAR OUT, standing up in front of you as Push draws it; and for
// GROUND POUND laid flat on the floor (+FLATSPRITE), sized so its last frame reaches the move's reach. Additive,
// tinted pale blue (AddShaded), gone when its frames are done. Not shown on the rig yet.
class RSQML_Ring : Actor
{
	int life, total;
	double a0;
	Default
	{
		RenderStyle "AddShaded"; Radius 1; Height 1;
		+NOINTERACTION +NOBLOCKMAP +BRIGHT +NOGRAVITY +NOTONAUTOMAP +DONTSPLASH +NOTELEPORT +ROLLSPRITE +ROLLCENTER
	}
	const FRAMES = 17;
	const LAST_PX = 154.0;        // the ring's width in its last frame, pixels (RQRGQ0's drawn ring, measured)

	// flat: on the floor; reach: the ring's radius at its last frame, map units; tpf: tics a frame
	static RSQML_Ring At(Vector3 at, bool flat, double reach, double alpha = 0.85, int tpf = 1, Color shade = 0xB8D8FF)
	{
		let r = RSQML_Ring(Actor.Spawn("RSQML_Ring", at, NO_REPLACE));
		if (!r) return null;
		r.sprite = GetSpriteIndex('RQRG');
		r.frame = 0;
		double sc = reach * 2.0 / LAST_PX;
		r.scale = (sc, sc);
		r.bFlatSprite = flat;
		if (!flat) r.bForceXYBillboard = true;
		r.roll = frandom[RSQMLRing](0, 360);
		r.total = FRAMES * max(tpf, 1);
		r.life = r.total;
		r.a0 = alpha;
		r.alpha = alpha;
		r.SetShade(shade);
		return r;
	}
	override void Tick()
	{
		if (isFrozen()) return;
		if (--life < 0) { Destroy(); return; }
		int tpf = max(1, total / FRAMES);
		frame = clamp((total - life - 1) / tpf, 0, FRAMES - 1);
		alpha = a0 * min(1.0, (life / double(total)) * 2.5);
	}
	States { Spawn: RQRG A -1 Bright; Stop; }
}

// GROUND POUND'S PIXEL SHOCKWAVE (owner 2026-11-10: "repurpose [our explosions' pixel shockwave], scale it, recolor it
// grey or give it some rainbow life and some glow"). RSQ Grenade's dashed pixel ring (its blast QE09 C-T, 18 frames
// growing 21 to 89 px), copied here grey as RQSW so Melee works without Grenade, laid flat on the floor, sized so its last
// frame reaches the move's reach, and tinted through the rainbow as it rolls out (AddShaded, a new hue every tic), with a
// fainter, wider copy a few tics behind it for the glow. Not shown on the rig yet.
class RSQML_PixelWave : Actor
{
	int age, delay;
	double hue0;
	Default
	{
		RenderStyle "AddShaded"; Radius 1; Height 1;
		+NOINTERACTION +NOBLOCKMAP +BRIGHT +NOGRAVITY +NOTONAUTOMAP +DONTSPLASH +NOTELEPORT +FLATSPRITE
	}
	const FRAMES = 18;
	const LAST_PX = 89.0;

	static void At(Vector3 at, double reach)
	{
		double h0 = frandom[RSQMLWave](0, 360);
		for (int k = 0; k < 2; k++)
		{
			let w = RSQML_PixelWave(Actor.Spawn("RSQML_PixelWave", at + (0, 0, 1 + k), NO_REPLACE));
			if (!w) continue;
			w.sprite = GetSpriteIndex('RQSW');
			double sc = reach * 2.0 / LAST_PX * (k == 0 ? 1.0 : 1.15);
			w.scale = (sc, sc);
			w.alpha = k == 0 ? 1.0 : 0.45;
			w.delay = k * 3;
			w.hue0 = h0 + k * 40;
			w.bInvisible = w.delay > 0;
			w.Shade();
		}
	}
	void Shade()
	{
		// HSV to RGB at full saturation and value: the hue walks 20 degrees a tic
		double h = (hue0 + age * 20.0) % 360.0;
		double x = 1.0 - abs((h / 60.0) % 2.0 - 1.0);
		double r = 0, g = 0, b = 0;
		if (h < 60) { r = 1; g = x; } else if (h < 120) { r = x; g = 1; } else if (h < 180) { g = 1; b = x; }
		else if (h < 240) { g = x; b = 1; } else if (h < 300) { r = x; b = 1; } else { r = 1; b = x; }
		SetShade(Color(255, int(r * 255), int(g * 255), int(b * 255)));
	}
	override void Tick()
	{
		if (isFrozen()) return;
		if (delay > 0) { delay--; if (delay == 0) bInvisible = false; return; }
		if (age >= FRAMES) { Destroy(); return; }
		frame = age;
		Shade();
		age++;
	}
	States { Spawn: RQSW A -1 Bright; Stop; }
}
