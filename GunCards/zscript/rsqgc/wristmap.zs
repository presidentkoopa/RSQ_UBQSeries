// THE WRIST MAP (owner 2026-10-31: "it would just be a kind of wrist minimap"). On the watch check (RSQ Gestures'
// knuckles-up inspect, as the watch card) a small round HOLOGRAM of the map floats level over the forearm, just behind
// the wrist: a miniature of the level round you, laid the way the world lies (north is north, so it lines up with
// what you see), you the white mark in the middle. rsqgc_map 0 off, 1 on the watch check, 2 always.
//
// Each wall is a flat glowing line in the world (a flat sprite: its width and its length scale apart, which a model's
// cannot). Stock QuestZDoom 17.3 cannot carry the 2D HUD onto the hand (REMA's portable HUD is an engine change), and
// its canvas textures drew wrong on the rig, so the map is built from the level's own lines.
//
// The idea of drawing the automap's lines yourself round the player, clipped to a circle, follows Lewisk3's minimap
// ("Cynic Games Minimap", MIT licence, Copyright (c) 2020 Lewisk3); the code here is new. Which lines show follows
// Doom's own automap: those you have seen, and the rest in grey with a computer area map; never a line marked not to be
// drawn; secret doors look like walls; a plain two-sided line with no step shows nothing.

class RSQGC_WristMap : EventHandler
{
	const MAXSEG = 360;
	const FOREARM = 0.16;       // metres behind the wrist along the forearm
	const LIFT = 0.05;          // metres above it
	const LINE_W = 0.0016;      // metres, a wall's width on the map

	transient Array<Actor> lines;
	transient Actor you;
	int hand;

	static clearscope int Mode() { let c = CVar.FindCVar("rsqgc_map"); return c ? c.GetInt() : 1; }
	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p ? PlayerPawn(p.mo) : null;
		let cards = RSQGC_GunCard(EventHandler.Find("RSQGC_GunCard"));
		int mode = Mode();
		bool want = false;
		hand = 1;
		if (pmo && pmo.health > 0 && cards && mode > 0)
		{
			if (mode == 2) want = true;
			else if (cards.rawWatch[1]) { want = true; hand = 1; }
			else if (cards.rawWatch[0]) { want = true; hand = 0; }
		}
		if (!want) { HideFrom(0); if (you) you.bINVISIBLE = true; return; }

		double u = 34.0;                                  // map units a metre
		Vector3 hp = RSQGC_GunCard.handPos(pmo, hand);
		Vector3 F = RSQGC_GunCard.handDir(pmo, hand);
		Vector3 c = hp - F * FOREARM * u + (0, 0, LIFT * u / 1.2);
		double rimM = Num("rsqgc_map_size", 14) / 200.0;  // the hologram's radius, metres
		double reach = max(128.0, Num("rsqgc_map_zoom", 768));
		double k = rimM * u / reach;                       // world units -> hologram units
		Vector2 at = pmo.pos.xy;
		bool all = level.allmap;
		int n = 0;
		for (int i = 0; i < level.Lines.Size() && n < MAXSEG; i++)
		{
			Line l = level.Lines[i];
			if (l.flags & Line.ML_DONTDRAW) continue;
			bool seen = (l.flags & Line.ML_MAPPED) != 0;
			if (!seen && !all) continue;
			Vector2 a = l.v1.p - at, b = l.v2.p - at;
			if ((abs(a.x) > reach && abs(b.x) > reach && a.x * b.x > 0) || (abs(a.y) > reach && abs(b.y) > reach && a.y * b.y > 0)) continue;
			int fr;
			if (!seen) fr = 4;
			else if (!l.backsector || (l.flags & Line.ML_SECRET)) fr = 0;
			else if (l.special && (l.activation & (SPAC_Use | SPAC_Cross | SPAC_Push))) fr = 3;
			else if (l.frontsector.floorplane.ZatPoint(l.v1.p) != l.backsector.floorplane.ZatPoint(l.v1.p)) fr = 1;
			else if (l.frontsector.ceilingplane.ZatPoint(l.v1.p) != l.backsector.ceilingplane.ZatPoint(l.v1.p)) fr = 2;
			else continue;
			bool ok; Vector2 qa, qb;
			[ok, qa, qb] = ClipCircle(a, b, reach);
			if (!ok) continue;
			Vector2 mid = (qa + qb) * 0.5 * k;
			Vector2 d = qb - qa;
			double len = d.Length() * k;
			if (len < 0.01) continue;
			let s = LineAt(n++);
			if (!s) continue;
			s.SetOrigin(c + (mid.x, mid.y, 0), true);
			s.angle = -atan2(d.y, d.x);     // a flat sprite turns the other way round (rig-checked: the walls meet at their corners)
			s.frame = fr;
			s.Scale = (LINE_W * u, len);
			s.Alpha = fr == 4 ? 0.5 : 0.9;
			s.bINVISIBLE = false;
		}
		HideFrom(n);
		// you, and which way you face: a short white line from the middle
		if (!you) you = Actor.Spawn("RSQGC_MapLine", c);
		if (you)
		{
			double yl = rimM * u * 0.18;
			you.SetOrigin(c + (cos(pmo.angle) * yl * 0.5, sin(pmo.angle) * yl * 0.5, 0.02), true);
			you.angle = -pmo.angle;
			you.frame = 5;
			you.Scale = (LINE_W * u * 2.5, yl);
			you.Alpha = 1.0;
			you.bINVISIBLE = false;
		}
	}

	private Actor LineAt(int i)
	{
		while (lines.Size() <= i) lines.Push(Actor.Spawn("RSQGC_MapLine", (0, 0, 0)));
		return lines[i];
	}
	private void HideFrom(int n) { for (int i = n; i < lines.Size(); i++) if (lines[i]) lines[i].bINVISIBLE = true; }

	// The part of segment a-b inside the circle of radius r round the origin.
	static bool, Vector2, Vector2 ClipCircle(Vector2 a, Vector2 b, double r)
	{
		bool ina = a.Length() <= r, inb = b.Length() <= r;
		if (ina && inb) return true, a, b;
		Vector2 d = b - a;
		double qa = d dot d;
		if (qa < 0.0001) return false, a, b;
		double qb = 2 * (a dot d), qc = (a dot a) - r * r;
		double disc = qb * qb - 4 * qa * qc;
		if (disc < 0) return false, a, b;
		double sq = sqrt(disc);
		double t0 = (-qb - sq) / (2 * qa), t1 = (-qb + sq) / (2 * qa);
		t0 = max(t0, 0.0); t1 = min(t1, 1.0);
		if (t0 > t1) return false, a, b;
		return true, a + d * t0, a + d * t1;
	}

	// this machine's own drawing, held by transient pointers: a save carries orphans, cleared on load
	override void OnRegister()
	{
		let it = ThinkerIterator.Create("RSQGC_MapLine");
		Actor a;
		while (a = Actor(it.Next())) a.Destroy();
	}
}

// One glowing line of the hologram: a flat sprite (lies level; its Scale.X its width, Scale.Y its length).
class RSQGC_MapLine : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT +FLATSPRITE
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: GCMP A -1; Stop; }
}
