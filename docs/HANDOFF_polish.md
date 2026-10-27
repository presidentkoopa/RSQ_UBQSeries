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

## 2026-10-27 -- dual sabers, the options page, the training remote game

Done (measured on the rig, load order bd22testv5 + VoxelPack + BD22Q, and bare Doom 2):
- Second saber works like Brutal Doom's dual guns: you start with two, and the Dual key
  (BD's +user3, or `ubqs_dual_toggle`) brings it out and puts it away. `ubqs_dual_mode`
  sets this to 1 = key, 2 = always out, 0 = one saber. Without BD the saber is slot 1.
- `ubqs_bd_sword` (on by default): Brutal Doom's DSweap counts as the saber.
- Options: one front page with the essentials. Every older page now sits under
  "Advanced: every setting", unchanged, together with the diagnostics. Every row was checked
  against CVARINFO and its option lists. The reset row now also resets `ubqs_dual_mode` and
  `ubqs_bd_sword`.
- Training remote is now a game:
  - Knock its bolts back to pay 10 x level and build a streak.
  - Each hit on it pays 50 x level x (1 + 0.1 x streak, capped at 10).
  - 4 hits knock it down for +300 x level x (1 + 0.5 x round). It comes back 3 s later
    one level harder and fires faster (gap x 0.85 per level past 3).
  - A sting resets the streak.
  - Points go to RS_Score through RS_ScoreService ("award") when it is loaded.
  - Rig check: deflect 20; hits 140/150/160; Remote Down +600; RS_Score total 1240, which
    matches.

Not done: headset feel for the remote's pace.
- For RS_Score's melee family, UBQS_SaberService now answers "blocked", "perfect", "pulled"
  (tics since, or -1) and "thrown.leg" (0 = out, 1 = home). They come from UBQS_Memory, a small
  EventHandler (64 rows, trimmed each second). The return bolt's tracer is the shooter.
  Rig check with the real BlockFx and Pull: Riposte 0.4 on a saber-blocked imp; the bolt killed its
  own shooter for Poetic Justice 0.3 + Return to Sender 0.4; "pulled" read 10 tics after a Pull.
