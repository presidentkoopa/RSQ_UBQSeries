# RSQ Laser Sight: rig check round 2 (2026-11-27), row #34

**IWAD:** Doom II (`doom2.wad`).

Rig: rig2 (copied per run), rig only.
- Map: R2GD01, which has a dark room (sector light 48) that the rig draws black.
- Runs:
  - R2_LS1: plain Doom pistol. Only the dot is drawn, no beam, so nothing to sparkle.
  - R2_LS2: the Brutal Doom stack, BD `Shot_Gun`, muzzle in the lit room (light 192).
  - R2_LS3: the same with the muzzle inside the dark room and `rsqls_beam_len 8`. Frames at 600 px.
- Each run: Beam Sparkle off for 70 tics, on for 70, off again for 70.
- Logs and scripts in `logs/`; frame `frames/LaserSight/ls3_row34_beam_sparkle.png`.
- Method: a per-pixel median of the first off window is the background. For every frame, count the pixels that are black
  in the background and at least 10 levels brighter in the frame. The tic label's row is left out. The frame-to-tic map
  comes from the tic number drawn in each frame (f68 = t167 start of "on", f90 = t236 "off again").

| # | README claim (line) | Verdict | Evidence | What actually happened |
|---|---|---|---|---|
| 34 | Beam Sparkle on: now and then a small spark beside the beam, in the beam's colour whitened (47) | WORKS (faint) | R2_LS3: new pixels on the black floor round the beam: **0 in every one of the 26 frames of the first off window (f42-f67) and in all 20 frames of the second (f91-f110)**; during "on" (f68-f90) f75 (3 px), f81 (6 px), f88 (3 px), f89 (2 px), each a dot 1-3 px beside the red beam line, colour (49-62, 25-32, 23-30) (a whitened red at low alpha); frame ls3_row34_beam_sparkle.png (f81 and f88: the dot beside the beam; f60 and f100, sparkle off: none at the same places) | The sparks are very faint: about 1/4 alpha additive, a few pixels at 600 px, seen only over a black floor. R2_LS2, with the muzzle in the lit room, showed none at all: the code scales the alpha down by the room's light. Matches the code's "almost imperceptibly" |

## Counts
1 row: WORKS 1 (faint).
