// RSQ_SlowMo -- LIVEREVERB ONLY WHILE YOU ARE DOWN (owner 2026-11-11 23:56: "let's work it so that LiveReverb affects
// sounds only when we are DOWN"). By name only; nothing of LiveReverb's is changed or copied.
// WHAT LIVEREVERB DOES (its pk3, read 11-12): an ACS script keeps ONE SoundEnvironment thing (tid 1337) and writes the
// reverb it measured for the room you are in into that thing's two arguments, then activates it, which sets the
// environment of the thing's sound zone (a map with no zone lines is one zone). It does that every tic.
// WHAT THIS DOES, with DOWN on (rsqsm_down) and LiveReverb Only When Down on (rsqsm_down_reverb): standing, your zone's
// environment is put back to 0 (Off); while you are DOWN, it is set from that thing's arguments, the reverb LiveReverb
// wants right now. Without LiveReverb (its DistanceCheckerCeiling class is how it is recognised), with DOWN off, or with
// the row off: nothing is touched, and LiveReverb runs as it always did. Single player's view (the console player).
// WHEN (fixed 11-17, owner: "Fix it so it holds"): the write must be the LAST one of the tic, after LiveReverb's.
// The engine's tic (P_Ticker) is: players -> event handlers' WorldTick -> the thinkers, stat list by stat list, 0 to 127.
// LiveReverb's script runs in the ACS thinker, stat list 103 (STAT_SCRIPTS), so it runs AFTER every WorldTick: the old
// write here sat in WorldTick and was overwritten in the same tic, and the option did nothing (rig, 11-16). The write is
// now made by RSQSM_ReverbLate, a plain Thinker moved to stat list 127 (MAX_STATNUM, the last one the engine ticks), so
// it runs after the ACS thinker every tic. ECHO: the tic LiveReverb's thing is spawned (a new map), the thing activates
// itself once more in its own PostBeginPlay, in the engine's "fresh thinkers" pass that comes after every stat list; so
// that tic the late thinker makes a one-tic echo (a fresh thinker in stat list 127 makes the engine run one more pass,
// after the thing's), and the echo writes again. Shown on the rig 11-17 (SlowMo/docs/rig_2026-11-17_reverb_order/);
// sound cannot be heard on the rig, so the result in the ear is the headset's to confirm.
class RSQSM_Reverb : EventHandler
{
	bool have, checked;
	int said;     // 0 nothing logged yet, 1 "off" logged, 2 "on" logged
	RSQSM_ReverbLate late;
	Actor seen;   // LiveReverb's SoundEnvironment as last seen (a new one gets the ECHO)

	override void WorldTick()
	{
		if (!checked) { checked = true; String cn = "DistanceCheckerCeiling"; Class<Actor> c = cn; have = c != null; }
		if (!have) return;
		// The late thinker is made once a level (a saved game brings its own back with the level).
		if (!late)
		{
			let it = ThinkerIterator.Create("RSQSM_ReverbLate", Thinker.MAX_STATNUM);
			RSQSM_ReverbLate t;
			while (t = RSQSM_ReverbLate(it.Next())) if (t.echo == 0) { late = t; break; }
			if (!late)
			{
				late = new("RSQSM_ReverbLate");
				late.ChangeStatNum(Thinker.MAX_STATNUM);
			}
		}
	}

	// Called by RSQSM_ReverbLate, once a tic, after the ACS thinker (LiveReverb's script); echo 1 and 2 are the ECHO.
	void Hold(int echo)
	{
		if (!have) return;
		if (RSQSM_Down.Cv("rsqsm_down", 0) == 0 || RSQSM_Down.Cv("rsqsm_down_reverb", 1) == 0) return;
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let pmo = players[consoleplayer].mo;
		let d = RSQSM_Down.Get();
		if (!pmo || !d || !pmo.CurSector) return;
		bool down = d.IsDown(consoleplayer);
		let it = Level.CreateActorIterator(1337, "SoundEnvironment");
		let a = it.Next();
		int env = 0;
		if (down && a) env = (a.args[0] << 8) | a.args[1];
		pmo.CurSector.SetEnvironmentID(env);
		// ECHO: a new thing this tic (echo 0), or the first echo passing it on (two, in case the first is ticked in the same pass)
		if ((echo == 0 && a && a != seen) || echo == 1)
		{
			if (echo == 0) seen = a;
			let e = new("RSQSM_ReverbLate");
			e.echo = echo + 1;
			e.ChangeStatNum(Thinker.MAX_STATNUM);
		}
		int now = down ? 2 : 1;
		if (now != said)
		{
			said = now;
			RSQSM_Down.Log(String.Format("LiveReverb %s (environment id %d)", down ? "on: you are DOWN" : "held off: you are standing", env));
		}
	}
}

// Ticks in stat list 127 (see WHEN above): after the ACS thinker, so its write is the one that stands at the end of the tic.
class RSQSM_ReverbLate : Thinker
{
	int echo;   // 0 the one that ticks every tic; 1 or 2 a one-tic ECHO (see WHEN above), gone after its tick
	override void Tick()
	{
		let h = RSQSM_Reverb(EventHandler.Find("RSQSM_Reverb"));
		if (h) h.Hold(echo);
		if (echo > 0) Destroy();
	}
}
