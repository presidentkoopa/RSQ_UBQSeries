# The arcade brain (long-term plan)

Owner 2026-11-09: "We will use this system for more than just minibosses ... Our Down/Revive System, our various arena
concepts, our EX tier enemies, this is getting bigger than current modules. I'd suggest we need some kind of
ArcadeBrain." Then: "Or maybe that's what VisualRewards always was?" Agreed the same evening: **RSQ VisualRewards
becomes the arcade brain** ("ScreenAndScene" is the idea; **not renamed for now**). "We will merge all these eventually
but keeping them separate for development is good. I think this arcadebrain discussion is the beginning of what will be
that merge, over time."

## Why

Each mod drives the shared levers itself today: Miniboss asks SlowMo for slow motion, Glow In The Dark for glow,
VisualRewards for beams. That's fine with one event at a time. With two (DOWN in the middle of a Bossfight, an EX arrival
during an arena wave) each mod grabs the music, the darkness and the time, and nobody knows what to put back
afterwards. One place has to decide, and one place has to remember what was there before.

## The shape

- **The mods report, the brain decides.** Miniboss reports "Bossfight called in", "window open", "fight over"; SlowMo
  "DOWN", "REVIVE"; later the arenas and EX monsters report theirs. They stop setting the music, darkness, time and glow
  themselves.
- **Each event maps to a scene:** which track, how dark (DarkDoomZ, inside Glow In The Dark), how slow (SlowMo), what
  glow and breathe (Glow In The Dark), which arrows and words.
- **Scenes stack.** DOWN during a Bossfight sits on top; at REVIVE it pops and the Bossfight scene comes back as it
  was; when the fight ends it pops and the level comes back. Restoring what was there before only works if one place
  holds the stack.
- **Priorities settle clashes.** The owner sets the order (for example DOWN over Bossfight over arena wave over
  ambient).
- **By name, as everything in the series.** The brain is RSQVR_Service; each mod still loads and works without it.
- **The music lives here:** scene tracks, staged sequences, stingers for context events (design/ARCADE_DYNAMIC_MUSIC.md).

## Open, the owner's call

- Presentation and pacing only (music, darkness, time, glow, HUD cues), or does the brain also run encounters
  (spawning arena waves, EX arrivals, Bossfights)? The first is buildable soon; the second makes it the arcade's
  director and is a much bigger build.
- The scene priorities.
- When VisualRewards is renamed, and when the mods merge into it.

## Built so far

- **2026-11-09, scene music** (rig only, not heard: the rig has no audio). `RSQVR_Service`
  `GetInt("scene.push", key, priority, 0, null, music)` and `GetInt("scene.pop", key)` (VisualRewards
  `zscript/rsqvr/scenes.zs`). The top scene's track fades in over 2 s as a looping sound while the level music fades to
  silent underneath; with no scene left it fades out and the level music fades back in where it has got to by then
  (QuestZDoom can't pause or seek music from a mod). A new map starts clean; a loaded save puts the track back. Menu:
  Arrivals and Words > **Scene Music** (on, per player).
- RSQ Miniboss pushes "bossfight" with the owner's track (`rsqvr/music/boss1`, his "20 organic beat", cut to loop) when
  a Bossfight is called in, and pops it when the miniboss dies. A failed landing pops and the retry pushes again (the
  music only dips). Rig 11-09: fades in at the call-in, holds through a failed landing and its retry, fades back out at
  the miniboss's death.
- Not yet: the darkness, slowest slow-mo and GITD breathe of the owner's Bossfight outline (outline only, not ordered);
  any other scene.
