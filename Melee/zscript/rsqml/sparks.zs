// HIT SPARKS (2026-11-02; the owner: "we need different hitsprites for different attacks so we know they are truly
// different"). His art: Capcom vs. SNK 2's hit sparks (ripped by Phantom.of.the.Server), one kind per blow, and the
// Hadouken hit from Random Sprite Rips (the same ripper). Built by Melee/tools/sparks.py: keyed, cropped to each
// sequence's union box (the art's axis stays put), shrunk, origin at the box's centre; the Scale below is the one the
// tool printed for the world size it was asked (map units, 34 a metre).
//
// Sizes (owner 2026-11-02: "pretty big... they should be like monster head height"): about a monster's head, then
// times Hit Spark Size (rsqml_spark_size, 1.0).
//   MLSN  Normal Spark   a jab / straight                    15 frames, 14 units tall (was 44)
//   MLSS  Special Spark  a hook / side swing, the palm swat  15 frames, 16 (was 50)
//   MLSU  Super Spark    an uppercut, the Hadouken's return  15 frames, 18 (was 60)
//   MLGD  Guard          the guard taking a blow             24 frames, 8 (was 18; drawn about 35 cm from your eyes)
//   MLHD  Hadouken hit   with the Super Spark on a return     6 frames, 12 (was 30)
//
// Additive, full bright, billboards; no blockmap, no gravity, nothing touches them. The four-letter names were checked
// against every RSQ pk3, the load order's Brutal Doom, BD22 VR and XMVE pk3s (lumps and actor text): no other user.
class RSQML_Spark : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP +FORCEXYBILLBOARD +BRIGHT
		RenderStyle "Add";
		Alpha 1.0;
	}

	static Actor Put(String cls, Vector3 at)
	{
		Actor a = Actor.Spawn(cls, at, NO_REPLACE);
		if (a)
		{
			CVar cv = CVar.FindCVar("rsqml_spark_size");
			double k = cv ? clamp(cv.GetFloat(), 0.25, 3.0) : 1.0;
			a.Scale *= k;
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

	// a landed punch: RSQML_Gloves.PK_JAB / PK_HOOK / PK_UPPER.
	// THE STREAK FOLLOWS THE FIST (2026-11-02; the owner: jab, hook and uppercut "need work... better, not bigger"). Each
	// CvS2 spark comes at four angles (sparks.py: 1 = 79, 2 = 56, 3 = 34, 4 = 11 degrees, each falling to the right). The
	// blow's travel, as the puncher sees it (across: the view's right; up: the vertical x pixelstretch), picks the
	// nearest, mirrored when it rises to the right. A blow driven straight in (little across or up) takes the 56-degree
	// one, mirrored for the off hand, so the two hands' jabs cross.
	static void Punch(int kind, Vector3 at, Vector3 dir = (0, 0, 0), Actor viewer = null, int hand = 0)
	{
		static const String cls[] = { "RSQML_SparkNormal", "RSQML_SparkSpecial", "RSQML_SparkSuper" };
		int v = 1;
		bool flip = false;
		if (viewer && dir.Length() > 0.0001)
		{
			Vector2 right = (sin(viewer.angle), -cos(viewer.angle));
			double ps = level.pixelstretch > 0.1 ? level.pixelstretch : 1.2;
			double rgt = dir.xy dot right, up = dir.z * ps;
			double across = sqrt(rgt * rgt + up * up);
			if (across < 0.3 * dir.Length()) { v = 2; flip = hand == 1; }
			else
			{
				double a = atan2(abs(up), abs(rgt));   // 0 across the view, 90 straight up or down
				v = a >= 67.5 ? 1 : a >= 45.0 ? 2 : a >= 22.5 ? 3 : 4;
				flip = rgt * up > 0;
			}
		}
		String c = cls[clamp(kind, 0, 2)];
		if (v > 1) c = String.Format("%s%d", c, v);
		Actor s = Put(c, at);
		if (s && flip) s.bXFlip = true;
	}
	static void Hadouken(Vector3 at) { Put("RSQML_SparkSuper", at); Put("RSQML_SparkHadouken", at); }
	static void Swat(Vector3 at) { Put("RSQML_SparkSpecial", at); }
	static void Guard(Vector3 at) { Put("RSQML_SparkGuard", at); }

	States { Spawn: TNT1 A 1; Stop; }
}

class RSQML_SparkNormal : RSQML_Spark
{
	Default { Scale 0.0729; }
	States { Spawn: MLSN ABCDEFGHIJKLMNO 1 Bright; Stop; }
}
class RSQML_SparkNormal2 : RSQML_SparkNormal { States { Spawn: MLN2 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkNormal3 : RSQML_SparkNormal { States { Spawn: MLN3 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkNormal4 : RSQML_SparkNormal { States { Spawn: MLN4 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkSpecial : RSQML_Spark
{
	Default { Scale 0.0833; }
	States { Spawn: MLSS ABCDEFGHIJKLMNO 1 Bright; Stop; }
}
class RSQML_SparkSpecial2 : RSQML_SparkSpecial { States { Spawn: MLP2 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkSpecial3 : RSQML_SparkSpecial { States { Spawn: MLP3 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkSpecial4 : RSQML_SparkSpecial { States { Spawn: MLP4 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkSuper : RSQML_Spark
{
	Default { Scale 0.0938; }
	States { Spawn: MLSU ABCDEFGHIJKLMNO 1 Bright; Stop; }
}
class RSQML_SparkSuper2 : RSQML_SparkSuper { States { Spawn: MLU2 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkSuper3 : RSQML_SparkSuper { States { Spawn: MLU3 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkSuper4 : RSQML_SparkSuper { States { Spawn: MLU4 ABCDEFGHIJKLMNO 1 Bright; Stop; } }
class RSQML_SparkGuard : RSQML_Spark
{
	Default { Scale 0.0899; }
	States { Spawn: MLGD ABCDEFGHIJKLMNOPQRSTUVWX 1 Bright; Stop; }
}
class RSQML_SparkHadouken : RSQML_Spark
{
	Default { Scale 0.1017; }
	States { Spawn: MLHD ABCDEF 2 Bright; Stop; }
}

// ---- THE BURSTS (2026-11-02): kiddolink's "VFX Hit Impact" (paid, the owner's: "I want that one in there for sure"),
// built by tools/bursts.py. The art rule (GBOVR_TREES.md 4): the CvS2 spark above is the blow on every punch; a burst is
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
