// "COULD" AND "HAVE", AS LIGHT.
//
// The saber's UBQS_GripGlow, already shipping on Quest (report §8.3): a second
// actor that wears the target's own sprite -- same sprite, frame, angle, scale,
// flips, offset -- drawn AddStencil in one flat colour, a hair toward the
// viewer. So the thing itself lights up in its own silhouette. No art, no model,
// nothing about the target touched: its translation, flags and render style stay
// exactly as they were, which the colour-flash route (tell.zs) cannot promise.
//
// TWO STRENGTHS SO THE TWO STATES NEVER LOOK ALIKE, as the saber runs them:
//   could  (the cone is on it)        amber, dim, a slow breath
//   have   (locked: taken at range)    green, bright, breathing twice as fast
// In flight and in the hand there is no glow -- the object is coming at you or
// in your hand, and has nothing left to say.
//
// The handler decides WHAT it wears and how bright; its own Tick decides WHERE,
// after the host has moved (see Tick).
class RSQDG_Glow : Actor
{
	Default
	{
		RenderStyle "AddStencil";
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+BRIGHT
		Alpha 0;
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// What it is wearing, and how. Set by the handler; the PLACEMENT happens in
	// this actor's own Tick.
	//
	// WHY HERE AND NOT IN THE HANDLER (review): the engine clears every
	// actor's interpolation before WorldTick (p_tick.cpp:156-159) and the host
	// MOVES after it, in RunThinkers. Placed from WorldTick, the twin read the
	// host's position before the host moved -- one tic behind it, and never
	// interpolating. Ticking as a thinker, spawned after its host and so later
	// in the same list, it reads where the host has just moved to, and its own
	// Prev (cleared to last tic's spot) gives it the same blend the host has.
	Actor host;
	Vector3 eye;

	override void Tick()
	{
		if (!host || bINVISIBLE) return;
		if (host.bINVISIBLE || host.sprite == 0) { Hide(); return; }
		sprite   = host.sprite;
		frame    = host.frame;
		angle    = host.angle;
		bXFlip   = host.bXFlip;
		bYFlip   = host.bYFlip;
		SpriteOffset = host.SpriteOffset;
		// A whisker larger, so the light reads as a rim past the edge as well
		// as a wash over the face.
		Scale    = host.Scale * 1.06;

		// 1.5 units toward the viewer, so the twin is drawn in front of the
		// host's sprite, never behind it.
		Vector2 d = eye.xy - host.Pos.xy;
		double l = d.Length();
		Vector3 off = (l > 0.01) ? (d.x / l * 1.5, d.y / l * 1.5, 0) : (0, 0, 0);
		SetOrigin(host.Pos + off, true);
	}

	void Follow(Actor h, Vector3 toward, double alph, Color col)
	{
		bool fresh = (host != h) || bINVISIBLE;
		host = h;
		eye = toward;
		SetShade(col);
		Alpha = alph;
		bINVISIBLE = false;
		// A NEW host: jump there, no blend from wherever the twin last was.
		if (fresh && h)
		{
			SetOrigin(h.Pos, false);
			Tick();
		}
	}

	void Hide()
	{
		bINVISIBLE = true;
		Alpha = 0;
		host = null;
	}
}
