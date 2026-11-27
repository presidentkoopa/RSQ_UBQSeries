# RSQ Saber: rig check round 2 (2026-11-27), row #41

**IWAD:** Doom II (`doom2.wad`).

Rig: rig2 (copied per run), rig only, plain Doom, map R2TR01, `RSQ_Saber.pk3` (R2 copy) + TEST-ONLY probe `r2qs.pk3`
(`/home/claude/rigdata/probes/R2/qssrc`).
- Settings: `ubqs_remote_level 1`, `ubqs_deflect_aim 0` (turned shots go at the shooter). Two sabers held vertical in
  front of the chest (round 1's B_S6 pose).
- The remote was opened with `ubqs_remote_toggle`, the command the menu's Training Remote row runs (round 1 #40 pressed
  the row itself).
- **The probe held the remote straight ahead.** Every tic it set the remote's own dance values: `om 0`, `th 0`,
  `rad/radWant 112`, `hgt/hgtWant 0`. The remote still flew itself there, fired, was knocked away and fell by its own code.
- Why: round 1's CAN'T TEST was that a still rig blade cannot follow a circling remote. This run checks what a hit does,
  not whether a player can land one.
- Run R2_QS1 (log and script in `logs/`), frame `frames/QuestSaber/qs1_row41_remote_hit_down_rise.png`.

| # | README claim (line) | Verdict | Evidence | What actually happened |
|---|---|---|---|---|
| 41 | Turn a bolt back into the remote: a hit, knocked away. Four hits within the round's 30 s: REMOTE DOWN, 25 health, after 3 s it rises one round harder (54) | WORKS (remote held in front by the probe) | R2_QS1.log:109 ("Training remote: deflect its stings"). First hit :226 (t156: `struck 1`, `vel 9.0`). Each hit adds `vel` 8.9-9.1, the remote is pushed out (t308 -> t315: 112 -> 121 units). Down: :472 "REMOTE DOWN! +300", :478 (t378, the 4th hit: `round 1`, `level 2`, `downUntil 482`, hp 50 -> 75), :486-594 (falls to z 0, rises at t482 = 104 tics later, ~3 s), :582 "TRAINING REMOTE: round 2". Again: :1012-1013 "REMOTE DOWN! +900 / round 2 cleared", :1018 (hp 71 -> 96, level 3), :1127 "round 3". Frame: f372 a red bolt at the remote; f399 / f438 the remote lying on the floor; f495 back up at eye height | The "harder" is read as the level (1 -> 2 -> 3) and the shot pace. The bolts' 2 damage shows as hp 75 -> 73 -> 71 between the downs (:784 at t665, :980 at t840) |

## Counts
1 row: WORKS 1 (with the remote held still by a test probe; whether a moving player can hit the circling remote is not
part of this verdict).
