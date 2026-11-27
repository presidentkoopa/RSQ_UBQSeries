# Rig check round 2: RSQ Gun Cards (2026-11-27)

**IWAD:** every verdict in this file came from Freedoom 2 runs (`freedoom2.wad`); none from Doom II (the switch to `doom2.wad` came after these runs, 2026-11-27 ~16:15).

Rows that round 1 (`/home/claude/rigcheck_ab/rigcheck_2026-11-27/GunCards.md`) left CAN'T TEST, now run. README line numbers are
today's `merge_main/GunCards/README.md`.
Rig: `rig2`, `qz_aimroll 1`, `qz_hz 35`, Freedoom 2, map `R2MAP01` (test-only room). pk3: current main build (copied 14:45).
R2_C1: `RSQ_GunCards` + `RSQ_Grenade` + `RSQ_VisualRewards` (plain Doom); R2_C2, R2_C4: `RSQ_GunCards` alone; R2_C3: Brutal Doom stack
(brutal22test6 + BD22 VoxelPack + BD22 VR-Reloaded 3.0rc) + `RSQ_GunCards`. `rsqgc_debug_log 1`. Watch pose as round 1 found
(hand 0.10 m to its side, 0.20 under, 0.25 ahead of the eyes, yaw 60 toward the body, roll 180).
Test-only probe `r2gc.pk3` (never ships) prints the card handler's own state per hand (`R2GC` lines): the small card's fade
`show`, how many small-card layers and watch-card layers are drawn, loaded / cap / reserve, the magazine colour the card uses
(`RSQGC_GunCard.MagColour`), "+N" and its end tic, inspect / reload linger ends, the tilt, the gun's spot, `wchk` (the off-hand
two-hand rule applied), launcher rounds, has-magazine. **Reading note:** a probe line printed right after a `wait` shows the
`show` value of the block before it (the next block's pose is already applied, its effect is not yet); the verdicts below
read them that way (checked with `a_pose` in R2_C2.log:116-163). Menus were driven on the rig: the probe's `r2_selname` picks a
row by its label, `rig_key DPadRight` moves a slider/option (a keyboard `RightArrow` does not reach rig menus, R2_C1.log:1199-1227),
`rig_key Pad_A` answers a yes/no. Logs + scripts: `/home/claude/rigcheck_round2/logs/R2_C1..C4.log`. Frames:
`/home/claude/rigcheck_round2/frames/GunCards/`. The cards are small at 480 px: numbers can only be seen, not read, in zooms.
In the Brutal Doom run the hands did not follow the posed hands in the frames (as in round 1), so BD rows rest on the log.

| # | README claim (line) | Verdict | Evidence | What happened |
|---|---|---|---|---|
| 2 | Off-hand gun from a pack with RSQGCOFF: mirrored small card on that wrist (15) | WORKS | R2_C3.log:275 (66 off-hand guns listed), 302 (off hand `RSQ_Off_BrutalPistol`), 319 (off hand: 7 small-card layers, `show` rising); c3_bd.png t340 (a small card at the off-hand forearm) | |
| 3 | Magazine count green above half, yellow to a quarter, red at a quarter or less (16) | PARTLY | R2_C3.log:173 (Rifle 31/31: `magcol 50E050` green), 189 (13/31: `F0D030` yellow), 203 (7/31: `FF5040` red) | The card's colour choice is right at all three steps; the main-hand card itself was not visible in the Brutal Doom frames (hands not posed there), so the drawn colour was not seen |
| 5 | Ammo pickup: "+N" in the reserve's place for 52 tics (18) | WORKS | R2_C1.log:117 (before: `plus 0`), 260 (Clip walked over at t66: `plus 10 till 118` = 52 tics); c1_plusN_zoom.png (a third line under the big number at t70 and t100, gone at t55 and t125) | |
| 11 | Off-hand watch check while that hand steadies the gun: nothing (24) | WORKS | R2_C2.log:600 (reader: off hand met), 604-643 (off hand within reach of the gun hand: `wchk 0`, `show 0`, no card); 758-764 (same check with the hands apart: `wchk 1`, card fading in) | Was inconclusive in round 1 |
| 13 | Cooking RSQ Grenade: seconds left on the small card, amber then red (26) | CAN'T TEST | R2_C1.log:1633 (cooking), 1669 (the grenade's card shows `loaded 8`, the grenade count; no `fuse count` line) | Needs RSQ Grenade's "Cook Sense 3", a Gun Bonsai VR node (Grenade upg.zs `fuse.count` answers -1 without it); Gun Bonsai is not on this machine |
| 14 | Show Cards: On Look (27) | WORKS | R2_C2.log:117 (gun at the default hand pose, 44 degrees off the look: `show 0`), 141 (gun 0.4 m ahead, 7 degrees off: `show 1`); R2_C1.log:293, 311 | |
| 15 | Show Cards: Inspect: watch check shows the small card, 70 tics after (28) | WORKS | R2_C1.log:329-343 (`show 0` before), 375 (after the check: `show 1`, `inspectTill 324` = 70 tics on) | With Watch Card Off, as the row says |
| 16 | Show Cards: On Reload (29) | WORKS | R2_C1.log:510 (`show 0`), 531 (reload held: `show 1`, `reloadTill 453` = 70 tics after the release) | |
| 17 | Show Cards: Off (30) | WORKS | frame c1_off_world_hn.png t150 (no card at the pistol hand), against t990 (card back) | The fuse half cannot be shown (row 13) |
| 18 | Watch Card: Always: watch card with the small card beside it; turned away, the small card alone (31) | WORKS | R2_C2.log:216 (check pose: small-card layers 4 and watch layers 13 together), 225-290 (turned away, inside the 70-tic linger: both), 303-360 (after the linger: small card alone) | Round 1 could not separate it; with On Check the small card goes during the check (R2_C1.log:677: small 0, watch 22) |
| 19 | Watch Card: Off: a check shows nothing (32) | WORKS | R2_C1.log:375 (check met with Watch Card Off: watch-card layers 0) | |
| 22 | Gun Bonsai on Card (35) | CAN'T TEST | | Gun Bonsai is not on this machine |
| 23 | Both Guns One Card: one card on the main hand, the off-hand rounds in its small number; the off hand's card goes (36) | PARTLY | R2_C3.log:319 (off: off hand's card 7 layers), 338 (on: off hand's card 0 layers, `show 0`); c3_bd.png t380 (no card at the off hand) | The off-hand card goes as claimed; the main card's small number was not seen (BD frames) |
| 24 | Hide at Eye (37) | WORKS | R2_C2.log:380-420 (gun at the eye: `show` 0.75 -> 0 in 3 tics, stays 0), 424 (option off: back) | |
| 25 | Tilt to Eyes: the small card turns toward your eyes, at most 20 degrees each way (38) | BROKEN | frames c2_tilt.png and c1_tilt.png: wrist rolled 40 or -40 with Tilt on (t318, t358; t806, t822): the card is gone from view; roll 0 with Tilt on (c1 t838): the card is pushed to the bottom edge of the view; Tilt off at the same rolls (t338, t378; t852): the card sits beside the hand as normal. R2_C1.log:976, 994 (`tilt -80.00 80.00` at both rolls); R2_C2.log:436 | With Tilt to Eyes on the card does not turn by a few degrees beside the wrist: it leaves the hand and goes out of view |
| 26 | Draw in World: flat signs at the hand facing your eye (39) | WORKS | R2_C1.log:1052 (5 world-card actors, small-card layers 0, 1029); frames c1_world_watch.png t872-896 (the watch card as a flat sign at the wrist, facing the eye), c1_off_world_hn.png t870 (small card as a sign) | |
| 32 | Steel bits restore condition (45) | WORKS | R2_C1.log:1892 (Pistol set to 50), 1908-1909 (`repair +1 (steel bit): Pistol 50 -> 51`) | |
| 33 | REPAIR at RSQ Miniboss's kiosk (46) | CAN'T TEST | | The kiosk needs LegenDoom (round 1 Miniboss), not on this machine |
| 35 | Spot Up / Side / In on a gun: that gun's card moves, saved for its class on this machine (48) | WORKS | R2_C2.log:534-553 (`spot saved pistol ... up 2.0`), 573 (`rsqgc_spots` holds it), 575 (the card's spot `0.0 2.0 0.0`); R2_C4.log:132 and R2_C4_saved_qzdoom.ini:1226 (written to the config at exit) | |
| 36 | Edit Spot For: Off Hand (49) | WORKS | R2_C3.log:373-395 (spot saved for `rsq_off_brutalpistol`, the off hand's card spot moves, main unchanged) | |
| 37 | Reset This Gun / Reset All Spots, confirmed (50) | WORKS | R2_C1.log:1318-1323 (yes/no, `spot reset pistol`), 1367-1371 (`every saved spot reset`) | |
| 38 | Hide HUD Health / Ammo switch BD22 VR's setting (51) | WORKS | R2_C3.log:429-431 (`rsq_hud_nohp` / `rsq_hud_noammo` true after the rows); c3_bd.png t500 (status bar numbers gone, against t110) | |
| 39 | Hand Numbers (52) | WORKS | frame c1_off_world_hn.png t990 (lines of text mid-screen) | Text too small to read at 480 px |
| 41 | Watch check with a no-ammo weapon: Weapon card with its name (54) | WORKS | R2_C1.log:1410 (`watch card hand 0 built: Chainsaw loaded -1 reserve -1`), 1425 (watch layers 22) | Name text not read |
| 42 | Melee kill credits a no-ammo weapon (55) | WORKS | R2_C1.log:1499 (`kill DoomImp -> main hand Chainsaw (1 this level)`) | |
| 44 | Brutal Doom Purist / NoReloading: AMMO with the pile, no reserve (57) | WORKS | R2_C3.log:458 (NoReloading: Rifle `loaded 200 cap 200 reserve -1 hasmag 0`), 471 (Purist token: the same, launcher -1) | |
| 45 | LAUNCHER line on BD22 VR's Rifle (58) | PARTLY | R2_C3.log:173, 232 (the card reads the Rifle's launcher: 0 rounds), 219 (watch card built) | LAUNCHER 0 is what the card is given; the line was not read in a frame and a loaded launcher (LAUNCHER 1) was not produced |

Counts (this round, 27 rows): WORKS 20, PARTLY 3 (#3, #23, #45: parts not seen), BROKEN 1 (#25 Tilt to Eyes), CAN'T TEST 3 (#13 and #22 Gun Bonsai, #33 LegenDoom).
