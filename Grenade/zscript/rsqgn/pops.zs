// =====================================================================================================================
// THE KINETIC SOUND (owner 2026-11-10: "we need sounds for our explosions, the animation is more kinetic than doom's
// burst"): one boom, then a run of short pops on the tics the animation's bursts land (the barrels' child bursts, the
// rocket's spray, the mega's boil). RSQGN_Pops is a silent, unseen point that plays them where the blast was.
// =====================================================================================================================
class RSQGN_Pops : Actor
{
	int t, n;
	int at[8];
	double vol;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTONAUTOMAP
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	// count pops, the first `first` tics after the boom, then `gap` tics apart (each a tic or two off, so a run never
	// sounds like a metronome)
	static void Go(Vector3 pos, int count, int first, int gap, double vol = 0.85)
	{
		count = clamp(count, 0, 8);
		if (count == 0) return;
		let p = RSQGN_Pops(Actor.Spawn("RSQGN_Pops", pos));
		if (!p) return;
		p.n = count; p.vol = vol;
		int tt = first;
		for (int i = 0; i < count; i++) { p.at[i] = tt + random[RSQGN_Fx](-1, 1); tt += gap + random[RSQGN_Fx](0, gap / 2); }
	}

	override void Tick()
	{
		t++;
		bool left = false;
		for (int i = 0; i < n; i++)
		{
			if (at[i] == t) A_StartSound("rsqgn/k/pop", CHAN_AUTO, CHANF_OVERLAP, vol, ATTN_NORM, frandom[RSQGN_Fx](0.9, 1.12));
			if (at[i] > t) left = true;
		}
		if (!left) Destroy();
	}
}
