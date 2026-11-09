// TEST ONLY (TestRig/music_test): the Bossfight music outline. "netevent rsqmus_on": the level music fades to silent
// (it keeps playing underneath) while the boss track fades in as a looping sound on your own channel; "netevent
// rsqmus_off": the boss track fades out while the level music fades back in where it has got to by then.
// rsqmus_fade (tics, default 70) is the crossfade length.
class RSQMusTest : EventHandler
{
	const CH = 32765;        // a channel nothing else in the series uses
	int dir;                 // 1 boss coming in, -1 going out, 0 still
	int t, len;
	bool playing;

	override void NetworkProcess(ConsoleEvent e)
	{
		len = max(1, CVar.FindCVar("rsqmus_fade") ? CVar.FindCVar("rsqmus_fade").GetInt() : 70);
		if (e.Name ~== "rsqmus_on") { dir = 1; t = 0; Console.Printf("RSQMUS on (crossfade %d tics)", len); }
		else if (e.Name ~== "rsqmus_off") { dir = -1; t = 0; Console.Printf("RSQMUS off (crossfade %d tics)", len); }
	}

	override void WorldTick()
	{
		if (!dir) return;
		let p = players[consoleplayer].mo;
		if (!p) return;
		t++;
		double k = clamp(double(t) / len, 0.0, 1.0);
		double boss = dir > 0 ? k : 1.0 - k;
		if (dir > 0 && !playing)
		{
			p.A_StartSound("rsqmus/boss1", CH, CHANF_LOOP | CHANF_UI | CHANF_NOPAUSE | CHANF_NOSTOP, 0.001, ATTN_NONE);
			playing = true;
			Console.Printf("RSQMUS boss track started");
		}
		if (playing) p.A_SoundVolume(CH, max(0.001, boss));
		SetMusicVolume(1.0 - boss);
		if (k >= 1.0)
		{
			if (dir < 0 && playing) { p.A_StopSound(CH); playing = false; Console.Printf("RSQMUS boss track stopped, level music back"); }
			else Console.Printf("RSQMUS boss track in, level music silent");
			dir = 0;
		}
	}
}
