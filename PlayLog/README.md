# RSQ PlayLog

A recorder for tuning the series. With Record Play Log on it writes lines starting `RSQLOG` to the console: each map,
each hand swing and how fast it was, each kill, each hit you take, each death, and the frame rate. The engine's log
file can copy the console to a text file to send back. It changes nothing in the game.

<a name="how-to-play"></a>
## How to play

| Do this | What happens | Needs |
|---|---|---|
| Turn on Record Play Log (Options > RSQ Play Log) | From now on the lines below are written to the console | Record Play Log: On (default Off) |
| Press Start Log File (same page) | The engine's `logfile rsqplay.txt` runs: everything the console prints from now is copied into rsqplay.txt (the tip says: in the game's own folder; pressing it again starts the file over) | |
| Press Stop Log File | The engine's `logfile` runs: the copying stops | |
| Start a map | `MAP`: the map's lump, its title, how many monsters, the skill. Not on loading a saved game | Record Play Log: On (default Off) |
| Leave a map | `END`: the seconds spent, kills of total, how many times you died | Record Play Log: On (default Off) |
| Swing either hand faster than 1.0 m/s against your body, then slow it under 0.6 m/s for 2 tics | `SWING`: which hand (main or off), its top speed in m/s, how many tics, how much of it went ahead of you and how much up, the weapon that hand holds, and "throw-fast" when the top speed reached 2.2 m/s | Record Play Log: On (default Off); VR hands |
| Bring the off hand within 0.8 m of your eyes | `WRIST` every 7 tics and on every change: the watch check and the pulse check for the off hand, and why each one's pose is not met | Record Play Log: On (default Off); VR hands; RSQ Accessibility |
| Kill a monster (you are the one it was fighting) | `KILL`: the monster, its spawn health, what killed it (the projectile or puff, else your main hand's weapon), how far in metres, the damage type | Record Play Log: On (default Off) |
| Get hurt | `HURT`: how much, by what, the damage type, the health left | Record Play Log: On (default Off) |
| Die | `DIED`: by what, and the monster that was fighting you | Record Play Log: On (default Off) |
| Play on | `FPS` once a second: how many times the screen was drawn and the longest wait between two draws in ms. `HITCH` for each wait of 50 ms or more, at most 3 a second | Record Play Log: On (default Off) |
| Press Reset All | Record Play Log goes back to Off | |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Play Log

| Option | Default | What it does |
|---|---|---|
| Record Play Log | Off | Writes how you really play (swings, kills, hurts, deaths, maps) to the console for tuning; it changes nothing in the game. |
| Start Log File | (button) | Starts writing the console to rsqplay.txt in the game's own folder; starting it again starts the file over. |
| Stop Log File | (button) | Stops writing the log file. |
| Test and Debug | (page) | Starting and stopping the log file rsqplay.txt. |
| Reset All | (button) | Puts every RSQ Play Log setting back to its default. |
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Accessibility | The `WRIST` lines ask its `RSQG_Service` for "inspect" (the watch check), "pulse" (the pulse check) and "pose.why" (why each is not met), for the off hand. Without it no `WRIST` line is written |
| RSQ Gun Cards | Nothing: its `RSQGC_GCopyService` answers the same three requests, but this mod asks only `RSQG_Service` by that exact class name |
| Every mod | `KILL`, `SWING` and `DIED` name the weapons and monsters by their class names, whichever mod they come from |

This mod answers no service of its own.

## Limits

- It only writes: nothing in the game changes.
- The lines go to the console. A file needs Start Log File, and that file holds everything the console prints, not only the `RSQLOG` lines.
- About 50 bytes a second from `FPS` alone (about 180 KB an hour), more with swings, hits and `WRIST` lines (up to 5 a second while the off hand is at your face). Nothing caps the file.
- Only your own player is logged, on your own machine.
- Out of VR (no hand positions) there are no `SWING` or `WRIST` lines. None while you are dead either.
- A hand that moves more than 30 m/s in one tic is skipped (a teleport or a frame gap).
- A kill counts only when the monster's target was you.
- After a saved game is loaded, `END` counts the seconds and deaths from the load, not from the map's start.
- Its page is "RSQ Play Log" in the main Options menu, not under Radiant Silvergun Options. Its Test and Debug page is empty.
- There is no key.

## Credits

The old README had no credits. The code names no outside work: `zscript/rsqpl/handsync.zs` is the series' shared hand
fix (tools/handsync), and the rest was written for the series. The engine is QuestZDoom (Emawind and Team Beef).

---
Written from the code at commit a283738bb, 2026-11-27.
