# Rig check: RSQ Grapple (Grapple/README.md "How to play"), 2026-11-27, agent B

Rig only, not headset. Fixed rig (`/home/claude/rigdata/rig2`; `qz_aimroll 1` in G4/G5), Freedoom 2, arena
`TestRig/maps/rig01.wad`, `pk3/RSQ_Grapple.pk3` (13:04 build), `rsqgr_debug 1` (its `T_G2` lines), plus the test-only probe
(`/home/claude/rigdata/probes/B/bprobe`). G1, G2, G4, G7, G8 add RSQ_Grenade and/or RSQ_SlowMo (the air spike's explosion and the
slow motion); G5 runs on the Brutal Doom stack (brutal22test6 + BD22 VoxelPack + BD22 VR-Reloaded 3.0rc) to have Brutal Doom VR's
bore. Logs and scripts: `design/rigcheck_2026-11-27/logs/B_G*.log` / `B_G*_script.txt`. Frames: `frames/Grapple/`. Sounds
cannot be checked (-nosound) and are left out of every verdict. Monsters' health is raised to 300 by the probe so kicks do not kill.

Rig note: a pull to a monster standing on the floor keeps you on the floor the whole way ("on the ground" in the log), so the air
spike's "while you are in the air and flying to a hooked monster" was shown with a floating Cacodemon (the pull lifts you).

| # | README claim (line) | Verdict | Evidence | What actually happened (BROKEN / PARTLY) |
|---|---|---|---|---|
| 1 | L12 Fire Hook: claw from the off hand along the gun line, 40 a tic, out to 780; bites the first wall, floor, ceiling or live monster | WORKS | B_G1.log:164, 219 (wall, 310 out, 8 tics); B_G1.log:2658 (DoomImp); B_G4.log:4248 (ceiling); B_G5.log:127 vs 145 (firing line on/off, BD bore) | Note: on the BD stack the off hand's line sits 4 deg right and 3 deg up of the controller (B_G5.log:127, dir 1.00 -0.07 0.05), the main hand's 4 deg left and 3 deg up (B_G5.log:199). It was not compared with a real gun fired from the off hand |
| 2 | L13 Let go of Fire Hook: nothing, one press | WORKS | B_G1.log:497-545 (one press and release: one claw, one bite, nothing on release) | |
| 3 | L14 Aim dot: cyan on the world, gold on a monster | WORKS | frames/Grapple/row3_aimdot_zoom.png (B_G6: gold dot on the imp at t39, cyan dot on the wall at t55, none with Aim Dot off); frames/Grapple/row3_aimdot_640.png, row3_aimdot_crop.png | Note: the dot is 1-3 pixels in a 640-pixel render (size 3 at these distances); it cannot be seen at all in the 200-pixel renders |
| 4 | L15 Hook a wall, floor or ceiling: one shove toward the bite, harder farther away, upward when above | WORKS | B_G1.log:220 (305 out -> vel 25.0); B_G1.log:1828 (95 out -> 7.0); B_G4.log:4249 (ceiling 719 out -> vel 58.1, z +15.8) | The 16-tic hold before the claw comes back was not timed |
| 5 | L16 Hook a step face within 40 under its top or a floor too high: lifted up and set on top | WORKS | B_G1.log:2949 then 3118 (LEDGE LIP, on top at z 124, top 120, 26 tics); B_G3.log:1639 then 1973 | The 45-tic give-up was not tried |
| 6 | L17 Hook a live monster: fly to it, kick 30 damage, knocked back and stunned, thrown off away and about 1.5 m up | WORKS | B_G1.log:2658-2750 (PULL 21.8 a tic; BDMG 30 Melee; DIZZY 53 tics; KICK-OFF out (-1, 0), up 42.5 units) | |
| 7 | L18 Air spike while in the air flying to a hooked monster: claw lets go, monster driven down 30 a tic, blood, six flames, ring shoves and stuns within 160; then you fall, no kick | WORKS | B_G4.log:352-375 (AIR SPIKE; Cacodemon z 80 -> 0 in 3 tics; NeonSpike 128; blood x4, fire x6); B_G8.log:389-421 (imp 113 from the landing point pushed, vel 8.2: "shockwave pushed 1"); B_G8.log:443-488 (you fall: vz -4, -8, floor); no KICK line in either | The stun of the ring is not logged on its own; the shove is |
| 8 | L19 Air spike within 15 tics after a kick, in the air | WORKS | B_G2.log:786-802 (KICK-OFF t192, AIR SPIKE t197, SPIKE LANDED) | |
| 9 | L20 Swing both hands down on the ground: nothing | WORKS | B_G1.log:2458-2472 ("not the air spike's moment (mode 0, on the ground), nothing") | |
| 10 | L21 Aim at nothing within reach: claw comes back empty | WORKS | B_G1.log:933 (Range 256: MISS after 7 tics); B_G4.log:5888 | |
| 11 | L22 Press again while a claw flies: another claw, each acts on what it reaches | WORKS | B_G1.log:1313-1391 (claw #5 while #4 flies; both bite walls, two flings) | |
| 12 | L23 Press while flying to a monster / lifted onto a ledge: ignored; a claw arriving then lets go | WORKS | B_G1.log:2700 (claw #8 arrives during the pull: lets go, comes back); B_G1.log:4002 ("press ignored: the hook is busy (mode 6)", ledge) | The spiked-fall case was not tried |
| 13 | L24 Kick a second monster before landing: count goes 2, 3; landing ends it | WORKS | B_G4.log:934 (KICK 2, word "KICK! x2"); B_G4.log:1032 (LANDED: chain ends at 2) | Note: aim assist picked the kicked imp again (the nearest marked to the line), so kick 2 was on the same imp |
| 14 | L25 Fire in the air after a kick: hang until the claw bites, then the bite plays | WORKS | B_G1.log:2904-2947 (HANG at z 76.8 for 5 tics, held, then the bite); B_G3.log:1534-1637 (11 tics) | The "reaches nothing: drop, chain ends" branch was not run |
| 15 | L26 Press again while hanging: claws reeled in, drop, chain ends | WORKS | B_G2.log:1375-1376 (1 claw reeled in, fall from z 17.4, CANCEL PRESS ends the chain) | |
| 16 | L27 Jump in the air after a kick: double jump about 1.5 m; up to five monsters in reach marked | WORKS | B_G1.log:2848-2850 (DOUBLE JUMP 42.5 units; MARKERS 4 of 4); B_G4.log:815-817 (3 of 3) | |
| 17 | L28 Fire in the air with a marked monster within 10 deg of the aim: claw turns to it | WORKS | B_G4.log:851-852 ("aim assist: snapped 8.6 degrees to marked DoomImp") | |
| 18 | L29 Hook a marked monster: mark taken off, pays its time | WORKS | B_G4.log:886 ("MARKER HOOKED: DoomImp, +0.25 sec (9 tics) -> g2.addtime 1") | |
| 19 | L30 Double Jump Always: one double jump in any jump or fall | WORKS | B_G1.log:5637; B_G4.log:3545 ("DOUBLE JUMP (always): up 42.5 units") | |
| 20 | L31 Two-handed: claw down the steadied gun's line, no Aim Trim | WORKS | B_G4.log:5737-5738 (twohand 1; dir 0.97 0.24 0.08); B_G2.log:ROW20 the same | The main hand was yawed 30 deg right and the off hand put on the gun ahead of it; the claw went 14 deg left and 5 deg up, which is the line from the main hand to the off hand (computed from the poses), not the main hand's own yaw and not the view. Aim Trim with two hands was not tried |
| 21 | L32 Land: kick count ends, marks cleared, double jump back | WORKS | B_G1.log:3135, B_G4.log:1032 (LANDED ends the chain); later double jumps in the same runs | Mark clearing is not logged on its own |
| 22 | L33 Die: claw removed, kick count ends | WORKS | B_G1.log:7441-7468 (RSQGR_Claw count 1, suicide, count 0) | |
| 23 | L34 Hook Hand: Main Hand | WORKS | B_G1.log:6477 (claw from (-310 -9), the right hand, along its yaw); B_G5.log:199 | |
| 24 | L35 Aim Trim sideways / vertical: claw and dot turn up to 15 deg | WORKS | B_G1.log:5906 (Aim Trim 15: dir 0.97 0.26, 15 deg left) | The dot's turn was not looked at |
| 25 | L36 Firing Line off: hand's own yaw and pitch; two-handing, where you look | WORKS | B_G5.log:127 vs 145, 163 vs 181, 199 vs 217, 235 vs 253 (on: bore and roll in the line; off: 1.00 0.00 0.00); B_G4.log:6024-6025 (two-handing, off: 1.00 0.00 0.00, the view) | |
| 26 | L37 Range: the claw reaches that far (dot, marks, assist too) | WORKS | B_G1.log:887, 933 (Range 256: "out to 256", miss at 256) | Dot, marks and assist at other ranges not tried |
| 27 | L38 `rsqgr_apex_hover 1`, then kick off or double jump: slow motion at the top (1 s after a kick-off, 0.7 s after a double jump) | FIXED (was PARTLY) | Works: B_G4.log:3052 (kick-off from a floating Cacodemon: APEX Kick-Off, 35 tics); B_G7.log:520 (double jump after a kick: APEX DoubleJump!, 25 tics). Fails: B_G2.log:1694-1752, B_G4.log:1718-1882, B_G4.log:2340-2485, B_G7.log:402 (kick-off from an imp on the floor, cvar true at B_G2.log:1604 / B_G7.log:241: no APEX line, LANDED 20 tics later) | After a kick-off from a monster on the floor, the slow at the top never comes (4 of 4 tries). Likely cause (code read, not proven): KickOff sets apexWatch (core.zs:881), but AirTick clears it the same tic when OnGround is still true (core.zs:1109), because you stand on the floor until the new speed moves you. A plain Double Jump Always jump gives no apex either (B_G4.log:3545); the README's "double jump" may mean only the one after a kick **FIXED 2026-11-27 (fix2):** the cause was as read: KickOff sets the watch (core.zs:882) and AirTick cleared it the same tic because you still stood on the floor. A rise still under way (rising, vel.z > 0) is no longer read as ground for the watch (core.zs:1115-1116). Kick-off from an imp on the floor, hover on: F2_G2.log:3087 (KICK-OFF t519) then :3151-3152 (t529 "APEX (Kick-Off) at z 47.2", SlowMo "merged 1000 ms at 25%"); F2_G4.log:1484 then :1541-1542 (t278 -> t288), :1982 then :2036 (t357 -> t367). The unfixed pack on the same script: F2_G2main.log:3079 then :3205 (LANDED, no APEX). Air kick-off and double jump unchanged: F2_G4.log:2687 (APEX at z 120.5), F2_G7.log:300 (APEX DoubleJump!). README L38 now says "kick off, or double jump after a kick-off" and that Double Jump Always's own jump gets none (owner 11-24: "no slow mo, just when we do it from kickoff"; B_G4.log:3545, F2_G4.log:3126) |
| 28 | L39 `netevent rsqgr_fire`: fires like the key | WORKS | B_G1.log:163-220 (ROW28: claw #1, wall bite, fling) | |

Counts at the check: WORKS 27, PARTLY 1, BROKEN 0. After fix2 (2026-11-27): WORKS 27, FIXED 1 (row 27).

## Fixes, 2026-11-27 (fix2, owner: "Fix all")

Rebuilt `pk3/RSQ_Grapple.pk3`; load-checked alone (F2_load_Grapple.log) and on the Brutal Doom stack (F2_load_full.log).
Rig only, not headset.
- Row 27 (no apex after a kick-off from the floor). Cause: KickOff sets `apexWatch` and the rise's speed (core.zs:882), but you
  still stand on the floor that tic, and AirTick cleared the watch on "ground" (was core.zs:1110). Fix: a rise under way (rising,
  vel.z > 0) is not ground for the watch (core.zs:1115-1116), as the LANDED test already reads it. README L38 made exact: the apex
  follows a kick-off or the double jump after one; Double Jump Always's own jump gets none (the code, and the owner's 11-24 words).
- Note: in F2_G2 the double jump at t306 hung and bit a ledge lip (LANDED t335) where the unfixed pack (F2_G2main.log) flung
  off a wall (LANDED t327). The claw left from z 81 against 79 (the rig's hand-sync timing); `apexWatch` is read nowhere with
  `rsqgr_apex_hover` off, as it was there, so this is not the change.
