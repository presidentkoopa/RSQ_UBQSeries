// =====================================================================================================================
// THE FLIPBOOKS (2026-11-09): the approved ROCKET blast (floor and air) and the MEGA blast (MEGA2, the chain finale),
// exported frame by frame from their mockups by tools/flip_export.py (flip_data.zs). One billboard plays a sequence a
// frame a tic at the mockup's scale, full-bright, with one point light following the mockup's glow (Explosion Lights:
// Off none; Simple and Full the same light). Played by bdlaunch.zs (Brutal Doom's rockets) and explosions.zs (a chain's
// finale).
// =====================================================================================================================
class RSQGN_Flip : Actor
{
	int seq, t, n;
	transient Array<SpriteID> spr;
	bool lit;
	int lastStep;

	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+NOTELEPORT
		+DONTSPLASH
		+CLIENTSIDEONLY
		+NOTONAUTOMAP
		+BRIGHT
		RenderStyle "Translucent";
		Alpha 1.0;
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// `at`: the blast point; a floor sequence stands on the floor under it. k: an extra scale (1 the mockup's size)
	static RSQGN_Flip Play(Vector3 at, int which, double k = 1.0)
	{
		if (which < 0 || which >= RSQGN_FlipData.COUNT) return null;
		let f = RSQGN_Flip(Actor.Spawn("RSQGN_Flip", at));
		if (!f) return null;
		if (RSQGN_FlipData.OnFloor(which)) f.SetZ(f.floorz);
		f.seq = which;
		f.n = RSQGN_FlipData.Frames(which);
		double s = RSQGN_FlipData.Scale(which) * k;
		f.Scale = (s, s);
		f.Show();
		return f;
	}

	void Names()
	{
		spr.Clear();
		int a = RSQGN_FlipData.NameFirst(seq), c = RSQGN_FlipData.NameCount(seq);
		for (int i = 0; i < c; i++) spr.Push(GetSpriteIndex(RSQGN_FlipData.NameAt(a + i)));
	}

	void Show()
	{
		if (t >= n) { if (lit) A_RemoveLight('rsqgnflip'); Destroy(); return; }
		if (spr.Size() == 0) Names();
		int ni = t / 26;
		if (ni < spr.Size()) { sprite = spr[ni]; frame = t % 26; }
		// the glow, in steps of a tenth (flat bands, and the light is only re-attached when its step changes: "optimized")
		int step = int(RSQGN_FlipData.GlowAt(RSQGN_FlipData.GlowFirst(seq) + t) * 10 + 0.5);
		if (RSQGN_Fx.Lights() > 0 && step > 0)
		{
			if (step != lastStep)
			{
				double g = step / 10.0;
				int c = RSQGN_FlipData.GlowCol(seq);
				A_AttachLight('rsqgnflip', DynamicLight.PointLight, Color(255, int(((c >> 16) & 255) * g), int(((c >> 8) & 255) * g), int((c & 255) * g)),
					int(RSQGN_FlipData.GlowRad(seq) * Scale.X / RSQGN_FlipData.Scale(seq)), 0, DynamicLight.LF_NOSHADOWMAP, (0, 0, 24));
				lastStep = step;
			}
			lit = true;
		}
		else if (lit) { A_RemoveLight('rsqgnflip'); lit = false; lastStep = 0; }
	}

	override void Tick()
	{
		t++;
		Show();
	}
}
