// =====================================================================================================================
// SCENES (2026-11-09; the start of the arcade brain, design/ARCADE_BRAIN.md). Other mods report a scene starting and
// ending by name; VisualRewards decides what the player hears. For now a scene carries music only.
//
//   RSQVR_Service GetInt("scene.push", key, priority, owner, null, music)   key: the scene ("bossfight"); music: a
//                                                                          SNDINFO name ('rsqvr/music/boss1'); owner: 0
//                                                                          everyone, or a player's number + 1 (only that
//                                                                          player hears it: "down" + n); 1 taken, 0 not
//   RSQVR_Service GetInt("scene.pop",  key)                               1 removed, 0 it wasn't there
//
// Scenes stack: the highest priority (the latest among equals) is heard. Its track fades in as a looping sound while the
// level music fades to silent underneath. A scene under the top one keeps its track playing silently (each track on its
// own channel), so when the top one goes it comes back where it has got to: a Bossfight's track goes on under DOWN, and
// if the miniboss dies while you are DOWN it is gone too and getting up brings back the level music (owner 2026-11-09).
// When no scene is left the track fades out and the level music fades back in where it has got to by then (QuestZDoom can't pause or seek music from a mod). Owner 2026-11-09: "when the fight is
// over the regular music crossfades back in where it left off."
// =====================================================================================================================
class RSQVR_Scene play
{
	String key;
	int prio;
	String music;    // a SNDINFO name, "" none
	int owner;       // -1 everyone, else the one player who hears it
}

class RSQVR_Scenes : EventHandler
{
	const CH_TOP = 32765;         // the sound channels, from here down (nothing else in the series uses them)
	const CH_MAX = 6;

	Array<RSQVR_Scene> stack;
	// the tracks playing on this machine: a scene's track stays on while its scene is on the stack (silent under a higher
	// one), and fades out and stops once its scene is gone
	Array<String> tName;
	Array<double> tLevel;
	Array<int>    tCh;
	transient bool restart;       // after a load the channels are empty: start the tracks again
	transient double musSet;      // the music volume we last set (0 after a load: set again on the first tic)

	static RSQVR_Scenes Get() { return RSQVR_Scenes(EventHandler.Find("RSQVR_Scenes")); }

	static double CF(Name n, double def) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetFloat() : def; }
	static double Step() { return 1.0 / max(1.0, CF('rsqvr_scene_fade', 2.0) * TICRATE); }

	static bool MusicOn()
	{
		let c = CVar.GetCVar('rsqvr_scene_music', players[consoleplayer]);
		return !c || c.GetBool();
	}

	int Push(String key, int prio, Name music, int owner = -1)
	{
		if (key == "") return 0;
		for (int i = 0; i < stack.Size(); i++) if (stack[i].key ~== key) { stack.Delete(i); break; }
		let s = new("RSQVR_Scene");
		String m = music;
		if (music == 'None') m = "";
		s.key = key; s.prio = prio; s.music = m; s.owner = owner;
		int at = stack.Size();
		while (at > 0 && stack[at - 1].prio > prio) at--;
		stack.Insert(at, s);
		return 1;
	}

	int Pop(String key)
	{
		for (int i = 0; i < stack.Size(); i++)
			if (stack[i].key ~== key) { stack.Delete(i); return 1; }
		return 0;
	}

	bool Mine(RSQVR_Scene s) { return s.music != "" && (s.owner < 0 || s.owner == consoleplayer); }

	// the track this machine's player hears: the top scene that is everyone's or his (worked out here, per machine: the
	// stack is the same everywhere, only what each player hears differs)
	String TopMusic()
	{
		for (int i = stack.Size() - 1; i >= 0; i--) if (Mine(stack[i])) return stack[i].music;
		return "";
	}

	bool OnStack(String music)
	{
		for (int i = 0; i < stack.Size(); i++) if (Mine(stack[i]) && stack[i].music == music) return true;
		return false;
	}

	int FreeChannel()
	{
		for (int c = CH_TOP; c > CH_TOP - CH_MAX; c--) if (tCh.Find(c) == tCh.Size()) return c;
		return -1;
	}

	Actor Ear() { return players[consoleplayer].mo; }

	// stop every scene channel on this machine's player (the pawn travels to the next map, and its looping sounds with it)
	void StopAll()
	{
		let ear = Ear();
		if (ear) for (int c = CH_TOP; c > CH_TOP - CH_MAX; c--) ear.A_StopSound(c);
	}

	// leaving the map: a scene never carries into the next one (owner 11-10: a Bossfight's track must not play on)
	override void WorldUnloaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		StopAll();
		stack.Clear(); tName.Clear(); tLevel.Clear(); tCh.Clear();
		SetMusicVolume(1.0); musSet = 2;
	}

	override void WorldLoaded(WorldEvent e)
	{
		// a new map starts with no scene and the level music at full; a loaded save puts its tracks back on their channels
		if (!e.IsSaveGame) { StopAll(); stack.Clear(); tName.Clear(); tLevel.Clear(); tCh.Clear(); SetMusicVolume(1.0); musSet = 2; }
		else restart = true;
	}

	override void WorldTick()
	{
		let ear = Ear();
		if (!ear) return;
		double vol = clamp(CF('rsqvr_scene_volume', 1.0), 0.0, 1.0);
		String heard = MusicOn() ? TopMusic() : "";
		if (restart)
		{
			restart = false;
			for (int i = 0; i < tName.Size(); i++) ear.A_StartSound(tName[i], tCh[i], CHANF_LOOP | CHANF_UI | CHANF_NOPAUSE | CHANF_NOSTOP, max(0.001, tLevel[i] * vol), ATTN_NONE);
		}
		// every track whose scene is on the stack is playing (the heard one loud, the rest silent)
		if (MusicOn())
		{
			for (int i = 0; i < stack.Size(); i++)
			{
				if (!Mine(stack[i]) || tName.Find(stack[i].music) < tName.Size()) continue;
				int ch = FreeChannel();
				if (ch < 0) continue;
				tName.Push(stack[i].music); tLevel.Push(0); tCh.Push(ch);
				ear.A_StartSound(stack[i].music, ch, CHANF_LOOP | CHANF_UI | CHANF_NOPAUSE | CHANF_NOSTOP, 0.001, ATTN_NONE);
				Dbg(String.Format("scene track %s started on channel %d", stack[i].music, ch));
			}
		}
		double top = 0;
		for (int i = tName.Size() - 1; i >= 0; i--)
		{
			double goal = tName[i] == heard ? 1.0 : 0.0;
			double was = tLevel[i];
			if (tLevel[i] < goal) tLevel[i] = min(goal, tLevel[i] + Step());
			else if (tLevel[i] > goal) tLevel[i] = max(goal, tLevel[i] - Step());
			if (was < 1 && tLevel[i] >= 1) Dbg(String.Format("scene track %s in", tName[i]));
			if (tLevel[i] <= 0 && (!MusicOn() || !OnStack(tName[i])))
			{
				ear.A_StopSound(tCh[i]);
				Dbg(String.Format("scene track %s out", tName[i]));
				tName.Delete(i); tLevel.Delete(i); tCh.Delete(i);
				continue;
			}
			ear.A_SoundVolume(tCh[i], max(0.001, tLevel[i] * vol));
			top = max(top, tLevel[i]);
		}
		// THE MUSIC KNOB ONLY WHEN IT MOVES (owner 11-10): set while a crossfade changes it, never re-set every tic, so another
		// mod's own music fade isn't overwritten while ours stands still
		double want = 1.0 - top;
		if (musSet <= 0 || abs(want - (musSet - 1)) > 0.0001) { SetMusicVolume(want); musSet = want + 1; }
	}

	static void Dbg(String s) { let c = CVar.FindCVar('rsqvr_scene_debug'); if (c && c.GetBool()) Console.Printf("RSQVR %s", s); }
}
