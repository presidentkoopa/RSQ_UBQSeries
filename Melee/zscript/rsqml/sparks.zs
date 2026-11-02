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

	// a landed punch: RSQML_Gloves.PK_JAB / PK_HOOK / PK_UPPER
	static void Punch(int kind, Vector3 at)
	{
		static const String cls[] = { "RSQML_SparkNormal", "RSQML_SparkSpecial", "RSQML_SparkSuper" };
		Put(cls[clamp(kind, 0, 2)], at);
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
class RSQML_SparkSpecial : RSQML_Spark
{
	Default { Scale 0.0833; }
	States { Spawn: MLSS ABCDEFGHIJKLMNO 1 Bright; Stop; }
}
class RSQML_SparkSuper : RSQML_Spark
{
	Default { Scale 0.0938; }
	States { Spawn: MLSU ABCDEFGHIJKLMNO 1 Bright; Stop; }
}
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
