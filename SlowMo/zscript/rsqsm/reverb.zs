// RSQ_SlowMo -- LIVEREVERB ONLY WHILE YOU ARE DOWN (owner 2026-11-11 23:56: "let's work it so that LiveReverb affects
// sounds only when we are DOWN"). By name only; nothing of LiveReverb's is changed or copied.
// WHAT LIVEREVERB DOES (its pk3, read 11-12): an ACS script keeps ONE SoundEnvironment thing (tid 1337) and writes the
// reverb it measured for the room you are in into that thing's two arguments, then activates it, which sets the
// environment of the thing's sound zone (a map with no zone lines is one zone).
// WHAT THIS DOES, with DOWN on (rsqsm_down) and LiveReverb Only When Down on (rsqsm_down_reverb), once a tic after the
// world's thinkers (so after LiveReverb's script): standing, your zone's environment is put back to 0 (Off); while you
// are DOWN, it is set from that thing's arguments, the reverb LiveReverb wants right now. Without LiveReverb (its
// DistanceCheckerCeiling class is how it is recognised), with DOWN off, or with the row off: nothing is touched, and
// LiveReverb runs as it always did. Single player's view (the console player). Sound cannot be heard on the rig:
// the thing's arguments and the switch were logged there, the result in the ear is the headset's to confirm.
class RSQSM_Reverb : EventHandler
{
	bool have, checked;
	int said;     // 0 nothing logged yet, 1 "off" logged, 2 "on" logged

	override void WorldTick()
	{
		if (!checked) { checked = true; String cn = "DistanceCheckerCeiling"; Class<Actor> c = cn; have = c != null; }
		if (!have) return;
		if (RSQSM_Down.Cv("rsqsm_down", 0) == 0 || RSQSM_Down.Cv("rsqsm_down_reverb", 1) == 0) return;
		if (consoleplayer < 0 || !playeringame[consoleplayer]) return;
		let pmo = players[consoleplayer].mo;
		let d = RSQSM_Down.Get();
		if (!pmo || !d || !pmo.CurSector) return;
		bool down = d.IsDown(consoleplayer);
		int env = 0;
		if (down)
		{
			let it = Level.CreateActorIterator(1337, "SoundEnvironment");
			let a = it.Next();
			if (a) env = (a.args[0] << 8) | a.args[1];
		}
		pmo.CurSector.SetEnvironmentID(env);
		int now = down ? 2 : 1;
		if (now != said)
		{
			said = now;
			RSQSM_Down.Log(String.Format("LiveReverb %s (environment id %d)", down ? "on: you are DOWN" : "held off: you are standing", env));
		}
	}
}
