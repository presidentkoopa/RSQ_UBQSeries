// =====================================================================================================================
// SCENES (2026-11-09; the start of the arcade brain, design/ARCADE_BRAIN.md). Other mods report a scene starting and
// ending by name; VisualRewards decides what the player hears. For now a scene carries music only.
//
//   RSQVR_Service GetInt("scene.push", key, priority, 0, null, music)   key: the scene ("bossfight"); music: a SNDINFO
//                                                                          name ('rsqvr/music/boss1'); 1 taken, 0 not
//   RSQVR_Service GetInt("scene.pop",  key)                               1 removed, 0 it wasn't there
//
// Scenes stack: the highest priority (the latest among equals) is heard. Its track fades in as a looping sound while the
// level music fades to silent underneath; when no scene is left the track fades out and the level music fades back in
// where it has got to by then (QuestZDoom can't pause or seek music from a mod). Owner 2026-11-09: "when the fight is
// over the regular music crossfades back in where it left off."
// =====================================================================================================================
class RSQVR_Scene play
{
	String key;
	int prio;
	String music;    // a SNDINFO name, "" none
}

class RSQVR_Scenes : EventHandler
{
	const CH = 32765;             // a sound channel nothing else in the series uses

	Array<RSQVR_Scene> stack;
	String playing;               // the track on the channel ("": none)
	String want;                  // the track the top scene asks for
	double level;                 // 0 the level music alone .. 1 the scene's track alone
	transient bool restart;
	bool full;       // after a load the channel is empty: start the track again

	static RSQVR_Scenes Get() { return RSQVR_Scenes(EventHandler.Find("RSQVR_Scenes")); }

	static double CF(Name n, double def) { let c = CVar.GetCVar(n, players[consoleplayer]); return c ? c.GetFloat() : def; }
	static double Step() { return 1.0 / max(1.0, CF('rsqvr_scene_fade', 2.0) * TICRATE); }

	static bool MusicOn()
	{
		let c = CVar.GetCVar('rsqvr_scene_music', players[consoleplayer]);
		return !c || c.GetBool();
	}

	int Push(String key, int prio, Name music)
	{
		if (key == "") return 0;
		for (int i = 0; i < stack.Size(); i++) if (stack[i].key ~== key) { stack.Delete(i); break; }
		let s = new("RSQVR_Scene");
		String m = music;
		if (music == 'None') m = "";
		s.key = key; s.prio = prio; s.music = m;
		int at = stack.Size();
		while (at > 0 && stack[at - 1].prio > prio) at--;
		stack.Insert(at, s);
		Pick();
		return 1;
	}

	int Pop(String key)
	{
		for (int i = 0; i < stack.Size(); i++)
			if (stack[i].key ~== key) { stack.Delete(i); Pick(); return 1; }
		return 0;
	}

	void Pick()
	{
		want = "";
		for (int i = stack.Size() - 1; i >= 0; i--) if (stack[i].music != "") { want = stack[i].music; break; }
	}

	Actor Ear() { return players[consoleplayer].mo; }

	override void WorldLoaded(WorldEvent e)
	{
		// a new map starts with the level music at full; a loaded save puts its scene's track back on the channel
		if (!e.IsSaveGame) { stack.Clear(); want = ""; playing = ""; level = 0; SetMusicVolume(1.0); }
		else restart = true;
	}

	override void WorldTick()
	{
		let ear = Ear();
		if (!ear) return;
		bool on = MusicOn();
		String target = on ? want : "";
		if (restart)
		{
			restart = false;
			if (playing != "") ear.A_StartSound(playing, CH, CHANF_LOOP | CHANF_UI | CHANF_NOPAUSE | CHANF_NOSTOP, max(0.001, level), ATTN_NONE);
		}
		if (target != "" && playing != target)
		{
			// a different track: fade the old one out first, then the new one in
			if (playing != "" && level > 0) { level = max(0.0, level - Step()); Apply(ear); return; }
			if (playing != "") ear.A_StopSound(CH);
			playing = target;
			ear.A_StartSound(playing, CH, CHANF_LOOP | CHANF_UI | CHANF_NOPAUSE | CHANF_NOSTOP, 0.001, ATTN_NONE);
			Dbg(String.Format("scene track %s fading in", playing));
		}
		double goal = target != "" ? 1.0 : 0.0;
		if (level < goal) level = min(goal, level + Step());
		else if (level > goal) level = max(goal, level - Step());
		Apply(ear);
		if (level <= 0 && playing != "" && target == "") { ear.A_StopSound(CH); Dbg(String.Format("scene track %s out, level music back", playing)); playing = ""; }
		if (level >= 1 && !full && playing != "") { full = true; Dbg(String.Format("scene track %s in, level music silent", playing)); }
		if (level < 1) full = false;
	}

	static void Dbg(String s) { let c = CVar.FindCVar('rsqvr_scene_debug'); if (c && c.GetBool()) Console.Printf("RSQVR %s", s); }

	void Apply(Actor ear)
	{
		if (playing != "") ear.A_SoundVolume(CH, max(0.001, level * clamp(CF('rsqvr_scene_volume', 1.0), 0.0, 1.0)));
		SetMusicVolume(1.0 - level);
	}
}
