# RSQ Graveyards: rig check round 2 (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

Rig: rig2 (fixed scratch rig, A button = Use), Freedoom 2, plain Doom, rig only (not headset). README: `RSQ_Graveyard.pk3`
README.md (R2 copy in `/home/claude/rigdata/probes/R2/pk3/`, byte-identical to merge_main's). Probe `r2gy.pk3` (TEST ONLY):
stone class, key, place, scale, tint, words; `r2gy_n` counts the stones and the store; `r2gy_fill` adds records to the store.
Maps: R2MAP01 (GY1) and R2GD01 (a light-192 room with a light-48 dark room, GY2 to GY6).
Runs (logs and scripts in `/home/claude/rigcheck_round2/logs/`):
- R2_GY1: Graveyard + VisualRewards.
- R2_GY2: Graveyard + lobstub (agent C's TEST-ONLY Legion of Bones stand-in) + `r2lobcv.pk3` (TEST ONLY: `LOB_Respawn` = 0).
- R2_GY3: Graveyard + Miniboss, ini seeded with `gy_bones_chance=50`, `gy_cfgver=0`.
- R2_GY5, R2_GY6: Graveyard + Score.
- R2_GYC_c1..c13 and R2_GYC_real: the crash hunt.
Frames: `/home/claude/rigcheck_round2/frames/Graveyard/`.

**Rig note.** rig2's ini has `gl_lights=false`, so dynamic lights are not drawn unless a run sets `gl_lights 1`. GY1 ran
without it. Its "candle on/off" picture showed only the Living Stones tint, so it was dropped. Every candle verdict below
comes from GY2 / GY3 / GY5, which set `gl_lights 1`.

## Found this round
1. **A MAP WITH ABOUT 110 STORED DEATHS CRASHES THE ENGINE AT EVERY LOAD OF THAT MAP** (segfault, "on Quest this would exit to
   home"). This is far below the README's 200 cap.
   - Real deaths: R2_GYC_real died 120 times on R2GD01, one death and reload after another.
     - `R2_GYC_real.log:5328` "map up: 110 stones" loads.
     - `:5376` "map up: 111 stones in the store" is followed by `:5380` `CRASH: signal 11`.
   - What sets the limit is the length of the stones' text, not how many there are or how far apart they stand. Filled-store runs, same map:

     | Run | Records | Obituary | Event bytes | Result |
     |---|---|---|---|---|
     | c5 | 100 | short | | loads |
     | c11 | 106 | short | ~12.1 KB | loads |
     | c9 | 112 | short | ~12.8 KB | crash |
     | c6 / c7 | 150 / 198 | short, packed 16 apart / spread 150 apart | | crash |
     | c13 | 85 | real-length ("Here lies Player, killed by Zombieman." + date + map time) | ~12.4 KB | loads |
     | c12 | 100 | real-length | ~14.6 KB | crash |
   - Cause (read, `zscript/gy_EventHandler.zs:79-82`): at map start the handler sends one network event per stone, in the
     same tic. Each event's name carries the stone's key, its place and the whole obituary (`spawnEventName`: about
     120-135 bytes each). Past about 12.5 KB of event names the engine crashes.
   - A real keyed death with a killer is about 135 bytes, so a map crashes at roughly 90-110 stones, depending on the obituaries.
2. **A saved game's standing stones are not kept on load: every stone is removed and pops in again.** This covers every
   death stored since keys came in (2026-11-10).
   - The record is stored with its death key: `R2_GY3.log:338` `gy_locations` = `301:560:-0:1:n0.8.8.301.560.-0.1`.
   - The stone stands with a different key: `:341` key `p301.000000/560.000000/-0.000000/1`, the place form.
   - So on load `:369` reads "1 stone in the store, 0 kept standing, 1 removed". The stone is made again and pops from 0.05
     (`:374` age 0, `:391` 1.347 at age 8).
   - Also seen in `R2_GY2.log:281` ("0 kept standing, 2 removed").
   - Cause (read): `networkProcess` (gy_EventHandler.zs:123-137) builds the stone from `gy_Death.fromString(rest)`, which has
     no key. `spawnStone` then gives the stone `sendKey(death)` = the `p` form, while `worldTick` compares against the
     record's `n` key.
   - The same mismatch would stop `gy_Stone.removeKeyed` (the cap's "taken off the map") from finding the stones it trims.
     That can't be reached anyway because of finding 1.
   - A Score gold stone is the exception: it is made with its `n` key (`R2_GY5.log:149`).

## Table

| README claim (line) | Verdict | Evidence | What actually happened (BROKEN/PARTLY) |
|---|---|---|---|
| Die alone: death stored (map, spot, words, date, map time); the stone stands from the next load, not at once (14) | WORKS | R2_GY1.log:118 "map up: 1 stone in the store" after the death and reload (none stood before it: :66, :86 `stones 0`); R2_GY3.log:338 (the stored record); frame gy1_near_far_words.png (HERE LIES PLAYER / the date / MAP TIME) | r2_kill has no source, so no "killed by" in these words |
| Die in a netgame: the stone at once on every machine (15) | CAN'T TEST | single-player rig | |
| Enter a map: a stone at each spot, one of four pictures by the spot (16) | WORKS | R2_GY2.log:261-262 (`gy_Stone1` at 101 560, x+y mod 4 = 1; `gy_Stone2` at 402 560, mod 4 = 2); R2_GY5.log:149 (`gy_Stone2` at 250 600); R2_GYC_c11.log (106 stones stand at their spots) | |
| ... "Stones already standing in a loaded save stay as they stood" (16) | **BROKEN** | R2_GY3.log:338, 341, 369, 374-391; R2_GY2.log:281 | Every stone is removed and made again on load, and pops in again: finding 2 |
| Pop-in: tiny to 1.35x over 24 tics, settles; the whole graveyard over about 1 s; a later stone pops at once (17) | WORKS | R2_GY1.log:120-169 (0.05 -> 1.347 -> 1.0 in 24 tics); R2_GY6.log:84-759 (20 stones start their pops at t1, 6, 11 ... 31, five tics apart, all done by t56 = 1.6 s); R2_GY6.log:799-914 (Score's gold stone, made at t65 in play, pops at once: age 0 at t65) | "About one second" measured 1.6 s for 20 stones (the stagger grows with the count) |
| Breathing: slow squash and stretch, about 7 s a breath (18) | WORKS | R2_GY1.log:209-335 (scale 0.95 <-> 1.05, about 240 tics a breath = 6.9 s) | |
| Candle: within 640 its light fades up over 20 tics (radius 72) and flickers; walk away, it fades out (19) | WORKS | frame gy2_cull_640_fade.png: the stone in the light-48 room is not lit at 650 (f640), fades up at 620 (f650 -> f670) and fades out after you step back to 650 (f696 -> f720). Crop means: rises 31.4 -> 37.1 over 18 frames, falls 36.9 -> 32.2 over 15 frames (R2_GY2.log:757-896 marks) | Flicker: next rows |
| Living Stones: light and tint breathe cool blue to warm yellow, one breath every 2 s, all together (20) | WORKS | R2_GY1.log:137-360 (mode 0: pulse 0.89, 0.99 ... repeats every 70 tics = 2.0 s, light 92 140 188 (blue) <-> 204 196 116 (yellow)); frame gy2_chaos_flicker_light_living_cull_hold.png (living on: a blue stone and blue candle pool) | |
| Use on a stone: its words for about 4 s; Use again restarts them (21) | WORKS | R2_GY1.log:604 (`words 1` after Use); frame gy1_near_far_words.png | |
| Use without the words: the obituary in the console (22) | WORKS | round 1 (C_gy1.log:959, 975) | not re-run |
| Remove Map Gravestones (23) / the console's `gy_remove_map` (25) | WORKS | R2_GY1.log:1185-1201 (3 stones -> "Gravestones on this map are removed." -> `stones 0`) | Run by console command. The menu button runs the same netevent (read), not pressed on the rig |
| Remove All Gravestones (24) / `gy_remove_all` (25) | WORKS | R2_GY1.log:1320-1335 ("All gravestones are removed." -> `stones 0`) | Other maps' records are not counted separately (the whole store is cleared, read: gy_Storage.clearAll) |
| Die more than 200 times on one map: the oldest go, 200 stand at most (26) | **BROKEN** | R2_GYC_real.log:5376-5380; R2_GYC_c9 / c12 (crash) vs c11 / c13 (loads) | The map crashes the engine at its first load past about 110 stones (about 12.5 KB of spawn events), so the 200 cap is never reached: finding 1 |
| A Score life spent: a gold stone at once, stronger, steadier gold candle (27) | WORKS | R2_GY5.log:82-94 ("a Score life spent: gold tombstone (kind 2) at 250 600"); :149 (`gy_Stone2`, standing at once in play); frame gy5_gold_living.png | |
| Kill a monster: 15 in 100 rise after 0-20 s (28) | WORKS (stand-in) | round 1 | Legion of Bones is not on this machine |
| Something on the corpse: wait again (at least 1 s); after 4 holds it rises at the nearest free spot (29) | WORKS (stand-in) | R2_GY2.log:908 (Zombieman died at 128 -600, rises in 25 tics); :938 t659 "something on the Zombieman corpse ... the wait starts again" (the player stands on it); :1080 t799 "SkullZombieSpawn RISES at 137 -637 ... after 4 holds" (140 tics = 4 x 35 later, 37 units off the corpse beside the player); :1082 the stand-in's rise | Legion of Bones' own riser replaced by agent C's stand-in; `LOB_Respawn` 0 set by a test cvar |
| Legion of Bones' own monsters (30); What Stops a Rise: Nothing (38); Random Delay Off (39); Bones Bridge Off (40) | CAN'T TEST | need Legion of Bones itself (not on this machine) | |
| Animate Gravestones Off: still at full size (31) | WORKS | R2_GY1.log:684 (scale 1.000 1.000) | |
| Pop In on Spawn Off: full size, no pop (32) | WORKS | R2_GY1.log after 1117 (no pop lines after the reload; the stone at scale ~1) | |
| Grave Light Off: no candle (33) | WORKS | frame gy2_chaos_flicker_light_living_cull_hold.png "light_off" (the floor round the stone goes black, the stone dark); floor mean 21.0 -> 8.9 over about 19 frames (fades out) | |
| Candle Flicker Off: burns steady (34) | WORKS | R2_GY2 frames (dark-room floor round the stone, Living off, still view). Flicker on: 66 frames, 20.4-21.4, sd 0.23, a slow waver. Flicker off: 21.0-21.1 flat | The flicker is gentle (about 5% of the pool's brightness on this rig) |
| Living Stones Off: own colour and a warm candle; gold stays gold with an amber candle (35) | WORKS | R2_GY1.log:727 (trans 0); frame gy2_... "light_on_living_off" (tan stone, warm pool) vs "living_on" (blue); frame gy5_gold_living.png (gold stone, amber floor with Living off; a yellow-green breathing tint with it on) | |
| Living Stones Mode Wave: by distance, one breath per 512 units (36) | WORKS | R2_GY1.log:995-1005 (two stones in mode 1 at different distances: pulse 0.89 vs 0.96, 0.99 vs 0.63) | |
| Living Stones Mode Chaos: each at its own pace from its own start (37) | WORKS | R2_GY2.log:271-343 (mode 2: 0.00 vs 0.83, 0.26 vs 0.50, 0.74 vs 0.17, 1.00 vs 0.00 ...); frame gy2_... "chaos" (one stone blue, the other yellow-green at the same moment) | In GY1 the two stones (0,0) and (300,300) hashed alike (3x+7y mod 1000 = 0 for both), so they breathed together (R2_GY1.log:1041-1083). A real collision, about 1 in 1000 pairs |
| Miniboss heartbeat: each candle swells up to 1.6x, leans to the beat's colour, the stone full bright (95) | WORKS | R2_GY3.log:458-666 ("FIGHT READY", then "miniboss heartbeat ff1810 0.25 s: 1 stone pulse" / "c01008 0.20 s", 9 tics apart, every 45 tics); frame gy3_heartbeat.png (lub f135 and dub f144: the stone pale and full bright, a red pool; between the beats f163: a blue dim stone) | |
| Rise Chance saved at 50 moves to 15 once (Limits 116) | WORKS | R2_GY3 ini seeded `gy_bones_chance=50`, `gy_cfgver=0` (run.sh echo); R2_GY3.log:233-234 / 240 (`gy_bones_chance` 15, `gy_cfgver` 1) | The save-game half not run |

## Counts
Table rows: WORKS 22 (2 with the stand-in), BROKEN 2, CAN'T TEST 2, PARTLY 0.
- BROKEN:
  - the 200-stone cap: the engine crashes past about 110 stones a map.
  - a loaded save keeps standing stones: they are removed and pop in again.
- CAN'T TEST: netgame; Legion of Bones' own rows (missing pk3).
