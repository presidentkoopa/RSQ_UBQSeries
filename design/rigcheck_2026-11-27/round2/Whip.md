# RSQ Whip: rig check round 2 (2026-11-27), rows #13 and #21

**IWAD:** Doom II (`doom2.wad`).

Rig: rig2 (copied per run), rig only, map R2TR01, `rsqwp_debug 1` (`T_WPW` lines).
- R2_WP1: plain Doom, `RSQ_Whip` + `RSQ_Score` (`rs_score_debug 1`).
- R2_WP2: the Brutal Doom stack (brutal22test6, VoxelPack, VR-Reloaded 3.0rc) + `RSQ_Whip`, because the hand on the
  handle is BD22 VR's model.
- The Ground Crack is round 1's flick (raise to 1.5 m over 11 tics, then down 0.13 m a tic for 3 tics and stop).
- The kill was the probe's `c_kill` (a blow by the player). Monsters were followed every tic with `r2_monwatch`.
- Logs and scripts in `logs/`, frames in `frames/Whip/`.

| # | README claim (line) | Verdict | Evidence | What actually happened |
|---|---|---|---|---|
| 13 | Catch a monster in the shockwave: Score is told; kill it within 2 s while it is still in the air and Score gives its Ground Crack row (24) | WORKS | R2_WP1.log:187 (`GROUND CRACK t102: down 4.6 m/s`), 198 (`IMPACT t106: 1 in the shockwave, 1 thrown up`), 201-208 (the imp lifted, z 10 -> 34), 211 (`RS_Score[killer]: ... Combo Chain[2-Tool] 0.250 \| Ground Crack 0.300`; the chain reads `whip.ground>gun`, :213, so Score got the touch), 215 (killed at t111, z 40). Control: 402 (second crack, the imp thrown), 571-575 (killed on the floor at t258, 56 tics after the impact: no Ground Crack row) | Round 1 saw no touch line because Score logs the touch only through the kill's row and chain |
| 21 | Hand on the Handle off: no hand drawn on the handle; the whip draws its own handle (32) | WORKS | R2_WP2 (whip in the main hand, hand raised in view); frame wp2_row21_hand_on_handle_on_off.png: f60 (T106, On): BD22 VR's hand closed round the handle; f75 / f85 (T137 / T158, Off, `rsqwp_hand_handle 0` set at t126): the coil and its own short handle, no hand; f95 (T180, On again at t167): the hand is back | |

## Counts
2 rows: WORKS 2.
