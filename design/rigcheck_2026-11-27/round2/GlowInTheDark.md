# Rig check round 2: RSQ Glow In The Dark (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

**Rig note (added later, round 2):** rig2's ini has `gl_lights=false`, and these runs did not turn it on, so no dynamic light (flare, torch, glow lights) was drawn in this file's frames. The light verdicts here come from the probes' reads of the lights (radius, count, colour), not from lit frames. The beam/cone models are not dynamic lights and do show.

Rows that round 1 (`merge_main/design/rigcheck_2026-11-27/GlowInTheDark.md`) left CAN'T TEST, now run. README line numbers are
today's `merge_main/GlowInTheDark/README.md`.
Rig: `rig2`, `qz_hz 35`, Freedoom 2. A TEST-ONLY map `R2GD01` (in the R2 probe, never ships; generator
`rigdata/probes/R2/src/mkgd.py`): a room (light 192) holding a NUKAGE1 pool, a pool of `XSLUDGE1` (a flat alias of NUKAGE1 whose
name only says liquid), a hurt floor (damage 10, FLOOR0_1), a GATE1 pad, a dark room (light 48) with a NUKAGE1 pool, a secret
sector (Boom special 1024), and on the north wall a switch (special 20, use), an exit switch (243, use), a red locked door (13,
lock 1) and an ordinary door (12); a red keycard, a soulsphere, a medikit, a clip and a shotgun lie on the floor.
pk3: current main `RSQ_GlowInTheDark` (+ `RSQ_Score` in R2_GD1), copied 14:45. `rsqgd_debug 1`.
Test-only probe `r2gd.pk3` prints the mod's own state per sector (`R2GD ... sec`: liquid code `liq` (0 none, 2 listed,
103 = 3 + 100 guessed by name), `spec` (1 hurt floor, 2 secret, 3 pad), the floor glow colour and height it wrote with
`SetGlowColor` / `SetGlowHeight`, the ceiling's), each glowing line (`kind` 1 door, 2 locked, 3 switch, 4 exit; `lock`), each
item it brightened (`bright`, `lit` = its light), its lights and its combo gain. Logs: `/home/claude/rigcheck_round2/logs/R2_GD1..GD5.log`.
Frames: `/home/claude/rigcheck_round2/frames/GlowInTheDark/`. A probe readout printed right after a `wait` can show the next
command's setting already applied; option rows were re-run (R2_GD2) with the readout in the middle of each block.

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 16 | A listed liquid: walls glow in its colour, 128 up, breathing at its own pace (16) | WORKS | R2_GD1.log:118 (NUKAGE1 `liq 2`, green glow `3DF228` h 155), 339, 375 (`37DA24` h 145, `44FF2E` h 168: breathing) | Round 1 could not find one in frames |
| 17 | A pack's liquid not in the list, named like one: glows the same (17) | WORKS | R2_GD1.log:119 (`XSLUDGE1 liq 103`, glow `778B1E` h 153, breathing at 340, 376) | |
| 18 | Hurt floor (not a liquid): walls throb red (18) | WORKS | R2_GD1.log:120 (`spec 1`, `861600`), 377 (`FF2D00` h 99): red, throbbing | The 40-a-minute rate not timed |
| 19 | Teleporter pad (GATE...): cyan shimmer (19) | WORKS | R2_GD1.log:121, 342, 378 (`spec 3`, `2CB9EC` -> `3DFDFF` -> `259AC5`) | |
| 20-22 | Switch amber, exit green breathing, locked door in its key's colour (20-22) | WORKS | R2_GD1.log:125-128 (switch kind 3, exit kind 4, locked kind 2 lock 1 red, door kind 1); frame gd4_walls_key.png (the four wall pieces: amber, green, red, cool blue) | Breathing rates not timed |
| 23 | Pick up that door's key: brighter, faster (23) | WORKS (brighter) | gd4_walls_key.png (the red locked piece clearly brighter after `give RedCard`: frames f106/f136 against f58/f84) | "Faster" not timed |
| 24 | Ordinary door: a faint cool edge (24) | WORKS | R2_GD1.log:128 (kind 1); gd4_walls_key.png (right piece, dim blue) | |
| 25 | Keys and powerups drawn bright; picked up, normal again (25) | WORKS (lying) | R2_GD1.log:129-133 (RedCard and Soulsphere `bright 1`; Medikit, Clip, Shotgun `bright 0`) | Picked-up half not tried |
| 26 | Dark room: glow up to 1.6x as strong, 1.4x as tall (26) | WORKS | R2_GD1.log:118 vs 123 (the same NUKAGE1: light 120 room `3DF228` h 155; light 30 room `55FF38` h 196) | |
| 27 | Kill something standing in a liquid: the pool flares 18 tics (27) | WORKS | R2_GD1.log:375 (pool `44FF2E` h 168, ceiling `522B88` 74), 407 (imp killed in it: `84FF58` h 311, ceiling `91FFB9` h 210), 434 (`68FF45` h 246, fading), 470 (back) | |
| 32 | Step Profile (32) | WORKS | R2_GD1.log:1015 (`rsqgd_profile` 2), 1065 (3 after the Profile row and DPad right) | |
| 33 | Pair Darkness to Profile (33) | WORKS | R2_GD1.log:1080-1082 (ddz_mode 2, ddz_preset 3), 1097-1099 (after the row: preset 2) | |
| 35 | Reroll Never: the same colours every map, from the seed (35) | WORKS | R2_GD2.log:739 (`base 405494`, glow `4F68B8`), 773 (next load: `seed 1337`), 815 (same colours); R2_GD5.log:317, 454 (seed 1337 after each death reload, same colours 384, 523) | |
| 36 | Reroll On Death: new colours when the map is loaded again (36) | WORKS | R2_GD5.log:66/108 (seed 111262128, room `7DF2F0`), 139 (death), 177/246 (reload: seed 33095286, room `A0A85C`) | |
| 37 | Reroll Level Up (37) | CAN'T TEST | | Gun Bonsai not on this machine |
| 38 | Reroll Timed: new colours every N minutes (38) | WORKS | R2_GD2.log:898 (Every 1 min: room `DEF168` at t39), 3035 (`CAC2CD` at t2239) | |
| 39 | Secret Rooms Shimmer: gold until found (39) | WORKS | R2_GD3.log:117-199 (the secret sector `spec 2`, gold `F6C83E` / `FCCE3F` / `EDC13B` / `BE9B30` breathing), 223 (`A secret is revealed!`), 278 (its glow now the room's); 376 (option off: the room's colour) | |
| 40 | Liquid Colour: Room Colour (40) | WORKS | R2_GD2.log:178-183 (both pools take the room's `4F68B8` / `617FDF`) | |
| 41 | Liquid Colour: Own Colour (41) | WORKS | R2_GD2.log:254-259 (pools green again: `39E326`, `53FF37`) | |
| 42 | One Colour Per: Each Room (42) | WORKS | R2_GD2.log:356-363 (each sector its own base colour) | |
| 43 | Blend Rooms (43) | WORKS | R2_GD2.log:431-438 (each room's base pulled toward its neighbours: e.g. room 0 `D1BA9D` -> `A4B16D`, secret room `2EBF54` -> `80BD79`) | |
| 44 | Keys and Pickups: Plus Health / Plus Ammo (44) | WORKS | R2_GD2.log:551 (Plus Health: Medikit `bright 1`), 631-633 (Plus Ammo: Medikit, Clip, Shotgun `bright 1`) | |
| 45 | Lights over pools / on items (45) | WORKS | R2_GD2.log:702-707 (RedCard and Soulsphere `lit 1`, `lights 3` = the 3 pools) | |
| 154 | With RSQ Score: combo glow +8% a kill, up to 10 (154) | WORKS | R2_GD1.log:423 (combo 0.08 after one kill), 550 (0.32 after four in a chain), 701 (0.20, fading after 4 s) | |

Counts (this round, 24 rows): WORKS 23, CAN'T TEST 1 (#37 Gun Bonsai), PARTLY 0, BROKEN 0.
