# QuestSaber — polish branch handoff (2026-10-26)

Branch `polish/quest-series`. Stock QZD 17.3, ZScript only. Not yet run on the owner's headset.

## Done (measured in the rig unless marked)
| | what | check |
|---|---|---|
| haptics | every buzz goes through one QF_WAVE quake emitter (`UBQS_Buzzer`): amplitude as asked, decays, never negative. The Quest runtime drops a buzz on a busy channel, and any quake keeps both busy, so the old 150 ms pulses were being dropped. | gdb on QzDoom_Vibrate: right channel 0.97 decaying to 0.25 |
| Force buzz | no longer a player hitscan (BD22Q's recoil/flash fired on it) | — |
| lefty | `ubqs_lefty` now defaults to -1 "Same as the game" (reads `vr_control_scheme` in single player); the old default 0 meant the auto path never ran (review) | not run left-handed |
| netgame | swing-spatial read through userinfo | not run in a netgame |
| Force jump | only with a saber or the Force hand out | — |
| tracking frame | `UBQS_FrameKeeper`: swing and Force gestures measured in the tracking space, so a snap or smooth turn (any size) is not a cut and a head turn is not a gesture | could not reproduce the old false cut in the rig either way (zombie hp stayed 40); fix is the grab's proven method |
| menu | snap slider range, one bind target per action, dead Contact rows labelled, throw-on-lock row, one global reset, orphaned tuning page removed | loads, both orders |
| service | **new** `UBQS_SaberService`: `GetInt("saber.lit", "", hand)` 1 lit or thrown / 0 doused hilt / -1 none | the distance grab reaches with a doused hilt and not with a lit one |

## Review fixes
Force-hand buzz now honours `ubqs_haptic_power`; buzzer Tick guarded after self-destroy.
Known, not changed: amplitude caps at 1.0, so the top of the power slider saturates;
FrameKeeper uses the tracked frame for the console player only (hand fields are local anyway).

## Not done / open
- Rumble strengths are first guesses; the headset decides.
- The rig engine lacks `HmdPosition`; the rig copy shims it (test only, never ships).
