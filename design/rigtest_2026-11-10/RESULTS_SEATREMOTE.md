# Seated Auto while DOWN, and a block for the training remote (owner's calls, 2026-11-11)

One launch (`run.sh`, the owner's full order, Gun Bonsai VR loaded, MAP01) with `r10.pk3` and the SR probe
(`evidence/SR_rig_probe/`). Script: `evidence/SEAT_DOWN_REMOTE_BLOCK_script.txt`. No script error from our pk3s (the
four in the log are BD_VoxelPack's voxeldef). All **rig only, not headset-confirmed**.

| Check | What was shown | Evidence |
|---|---|---|
| Seated Auto, a 0.5 m drop for 3 s while DOWN: not seated | `rsqa_seated` 2, nothing measured, standing at 1.60 m (reference learned 1.60 at t42). DOWN by a lethal hit (`r10_hitme 500`, t122: held at 1 HP, SlowMo's `down` answer 1). Headset to 1.10 m t168-t301 (3.8 s); the seated eyes jumped to 1.10 at t203 and stayed there 2.8 s, drop 0.50 m: **seated 0** on every sample | `evidence/SEAT_DOWN_log.txt` (SEAT_DOWN_*, SR SEAT lines) |
| Get up, the same drop: seated | Head back to 1.60, the target killed (t310): UP, `down` 0. At 1.60 for 3 s, standing. Headset to 1.10 (t427): the seated eyes to 1.10 by t462, **seated 1** by t532 (2 s), drop 0.50; up to 1.60: standing again by t602 (1 s) | `evidence/SEAT_DOWN_log.txt` (SEAT_UP_*) |
| Without SlowMo nothing changes | **not shown** (no run without SlowMo). Code: no `RSQSM_Service`, or no answer, is "not down" (`Accessibility/zscript/rsqa_qol.zs`, `IsDown`) | - |
| Starting a map sitting | unchanged (owner): Auto waits until it has seen you stand. Not re-run | - |
| A block counts for the remote (Gun Bonsai VR, Deflector not learned) | The remote held 8 units past the blade tip (as in LAST). Four bolts stopped dead: `SBX_BLOCK t789 / t849 / t910 / t962 ... stopped on the blade (Deflector not learned)`. Each the same tic: deflects +1, streak +1 (1, 2, 3, 4), round hits (pips) 1, 2, 3, points paid; SlowMo `rsm_pulse (300 35)` + `ubqs_remoteslowmo` arrived t792 / t850 / t914 / t964 and started **300 ms at 35%** (pulse 11 tics). The fourth block: REMOTE DOWN +600, its 1500 ms merged (pulse 53 tics). Stung 0; no bolt sent back | `evidence/REMOTE_BLOCK_log.txt` |

Not looked at in frames: the wrist panel's pips (the count is the log's).

Code: `Accessibility/zscript/rsqa_qol.zs` (`IsDown`, asked in `SeatTick`: while DOWN, Auto's switch timer is held at
0 and nothing switches; the eyes are still tracked). `QuestSaber/zscript.txt` (`UBQS_SaberBase.BatBack`'s block branch
calls `UBQS_RemoteBolt.CountBlock`: the deflect's own count, then the remote's own hit, `DamageMobj`; the bolt is still
destroyed). SlowMo unchanged: its `down` answer already existed.
