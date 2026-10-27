## Branch `agent-upgrades` (2026-10-27): Gun Bonsai melee upgrades

Not yet run on the owner's headset. The saber asks the Gun Bonsai VR patch for its upgrade levels by
NAME (`UBQS_Upg` at the end of zscript.txt -> `RSQ_MeleeUpgradeService`), cached once a second.
Without the patch every level reads 0 and the Force is today's (rig, saber + BD only: push 20.9,
scale 1.00, grip mass 600).

- XP credit (measured): the return bolt's `master` and the thrown blade's `tracer` are the saber, so
  Gun Bonsai pays the saber that did it (before: both were guessed and went to the main hand).
  Deflected missiles get `master` = the saber when nothing uses it. The Force item's `master` is a
  saber (off-hand first), so Force damage is paid to a saber.
- Momentum (`UpgCutMult`): +10%/level per half second of blade motion, up to 2 s; 6 still tics reset.
- Riposte Edge (`Prime` from BlockFx and BatBack): next landing cut within 1 s (+0.5 s/level) x2
  (+0.25/level).
- Piercing Return (`UBQS_Bolt.pierce`): rig, near imp 80 -> 60 and far imp 60 -> 40 with one bolt.
- Saber Throw (`UBQS_Thrown.ExtraHop`): rig, a free throw cut one imp, then found and killed two more.
- The Force, with the patch: unlearned at `rsq_force_start` (0.6); level 1 = today; +15%/level.
  Push 2+ wider cone, 3+ shockwave all round (rig: imp behind you thrown, 80 -> 70). Pull 2+ stun on
  arrival (rig: held in Pain ~44 tics), 3+ no ranged attacks for 2 s+ (rig: Missile refused).
  Choke 2+ lift and crush (x1.5/s up to x3), 3+ holds level-2 extra (rig: two imps choked at once);
  Chain Choke jumps the grip on a kill (rig: A killed in the grip -> grip on B). Jump 2+ landing slam
  (rig: real `+jump`, two imps 80 -> 51 and thrown).
- Dual Harmony is done by the patch itself (alternating saber inflictors), no saber code.

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
