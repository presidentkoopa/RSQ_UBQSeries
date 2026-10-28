## Branch `agent-compat` (2026-10-27): Champions + LegenDoom Lite -- read first

Not yet run on the owner's headset, and NOT run on the rig either: the grip has no headless entry (its
gesture needs real hand poses). Compiled and loaded clean in the owner's order and vanilla, save/load twice,
MAP02. By code (Champions and LegenDoom Lite parsed):
- GripTick re-asks Grippable every tic: the choke itself brings a legendary to half, LegenDoom transforms
  it, and a dormant champion sets up on that tic (Gold Mass x12 = 1200 > ubqs_grip_mass 600, Bronze
  0x7FFFFFFF, Titan BOSS) -- the grip kept holding it. A Dark Red at 1 health turns unshootable and is
  parked at (16384,16384); the hold dragged it back and its pain state woke it. Now dropped (not flung);
  extras (Force Choke 3+) the same.
- Push, pull, shockwave, landing slam and the cut's shove leave Mass 0x7FFFFFFF (Champions' immovable)
  unmoved; the clamp floors (2.0 / 0.08) still slid it. Damage unchanged.
- Headset: choke a legendary champion through its transform -- it should drop from the hand.

## Branch `agent-lh` (2026-10-27): left-handed blade direction -- read first

Not yet run on the owner's headset. `UBQS_Data.BladeDirOf` flipped the frame's yaw and twirl by
`off ? 1 : -1`; the engine reflects the hand on the physical LEFT controller (hw_vrmodes.cpp
GetWeaponTransform), which is the MAIN hand when vr_control_scheme >= 10. It now uses
`WorldMirror(off)` -- the rule the world saber already picks its parity class by; right-handed it is
the same value. Rig D, controllers posed as exact mirror images, main saber, blade direction in the
body frame (fwd, left, up):

| frame | right-handed | left-handed before | left-handed now |
|---|---|---|---|
| 0 idle | 0.717 0.027 0.697 | 0.717 -0.027 0.697 | 0.717 -0.027 0.697 |
| 3 chop | 0.437 -0.219 0.872 | 0.556 0.348 0.755 | 0.437 0.219 0.872 |
| 10 side cut | 0.939 -0.272 0.209 | 0.286 -0.435 0.854 | 0.939 0.272 0.209 |
| 12 side cut | 0.450 0.690 0.567 | 0.994 -0.101 0.029 | 0.450 -0.690 0.567 |
| 23 twirl | 0.625 -0.731 -0.275 | -0.448 -0.429 0.784 | 0.625 0.731 -0.275 |

Now the exact mirror image in every frame; before, the swing frames were up to ~70 degrees off the
drawn blade for a left-hander (hits, glow, deflects). Everything else in the saber already followed the
engine (world-saber parity, Force hand = OffhandPos, rumble via ubqs_lefty / vr_control_scheme).
Full order + suite, and vanilla, both handednesses: save, load twice, MAP02, no script error but
BD_VoxelPack's voxeldef lines. Headset: a left-handed side cut -- the glow and the hits should sit on
the drawn blade.

## Branch `agent-block` (2026-10-27): the blade blocks Brutal Doom's attacks -- read first

Not yet run on the owner's headset. Rig = QZD 17.3 Linux, doom2 MAP01, the owner's load order
(brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded_1.99x-lb-r7-saveload -> saber), one saber
(`ubqs_dual_mode 0`) held still across the line from the monster to the player's middle (rig hand
pose `0.25 1.15 -0.3 -20 90 0`). Probe in the session scratchpad `blk/probe` (counts the damage the
player takes from a real BD monster firing its own attack for 30 s).

Why it failed (parsed from brutal22test6, not guessed): BD's monsters make 4375 A_CustomMissile calls
and no live bullet attack. Its zombies' bullets are FastProjectile tracers (MonsterTracer, radius 2,
speed 50); its claws, bites and punches are short missiles fired from Melee states (ImpAttack,
DemonAttack, BaronAttack...: Spawn chain ends after speed x tics = 16 to 168 units). The saber's
contact block returned for every missile and every blast, so only the sweep could stop BD, and the
sweep only sees a claw along the claw's own knee-high path. RS_ShieldSawQ decides every hit on contact
(guard.zs AbsorbDamage); the saber now does the same:
- claw (`UBQS_Memory.IsClaw`: a missile whose Spawn chain stops within 192 units of travel) = melee:
  the attacker's own line against the blade (BladeInPath, ubqs_blade_guard), stagger, one bolt per
  bite; claws are left out of the sweep's missile list
- shot (`ContactBlock`): its own path (two tics back, a body width forward) against the swept blade,
  width ubqs_blade_guard + its radius; a copy goes back by the deflect's aim rule, the original dies
- blast: from where it went off to your middle; a missile already stopped on contact is stopped when
  it goes off on your box (remembered a second)

| attack (30 s) | no saber | before (HEAD bc01328+a462cad) | after |
|---|---|---|---|
| BD imp claw, 56 units, blade in its line | 93 hits, 1860 dmg | 93 hits, 1860 dmg | 0 hits / 132 claws, 0 dmg |
| same, blade NOT in its line (control) | -- | -- | 57 of 58 claws hit (it is not a free pass) |
| BD rifle zombie tracers, 300 units | 120 hits / 364, 720 dmg | 33 / 385, 198 dmg | 22 / 364, 132 dmg |
| BD imp fireballs, 400 units | 27 hits, 540 dmg | 0 (sweep) | 0 |

Save at tic 600 and `-loadgame` on the full load order: runs on, claws still blocked, no script error
(2 claws landed in the first tics after the load, before the engine writes the hand pose). Vanilla
doom2 alone: imp claws still blocked (old path), no script error. The only script errors in every
run are BD_VoxelPack's own voxeldef.txt lines 66/72/77/892.

Not done / headset: the leftover tracer hits are shots whose path misses the blade band (6 units
each side, `ubqs_blade_guard`, the owner's "small hitbox"); whether that is too small against BD is
his call -- the slider is already on the menu (Blade Block Reach).

## Branch `agent-upgrades` (2026-10-27): Gun Bonsai melee upgrades

## Branch `agent-up2` (2026-10-27) -- read first

Not yet run on the owner's headset. Rig = QZD 17.3 Linux, freedoom2 / doom2, the owner's load order
+ Gun Bonsai 0.10.6 + the VR patch `agent-up2` (probes `up2/sxa`, `up2/sxe` in the session scratchpad).

| | what | rig (measured) |
|---|---|---|
| THE BLADE'S SWEEP NEVER SAW A MISSILE | a projectile is +NOBLOCKMAP (PROJECTILE), so the BlockThingsIterator in `Deflect` and `SpinDeflect` never returned one; only the block on contact (DamageMobj) turned shots. `UBQS_Memory.missiles` (WorldThingSpawned, pruned each tic) is walked instead | before: an imp ball aimed at a still, held blade flew through it and stopped on the player; after: turned at 63 units, master = the saber, back at the imp |
| Force Pull 3+ yank | the monster's likeliest DropItem is spawned (with replacement) and lobbed at the hand, once per monster; its own death drop is then removed (`UBQS_Memory.Yank`, WorldThingSpawned) | vanilla zombieman: a clip lands 20 units from the player; its death drops nothing (control zombieman: 1 clip). Brutal Doom zombie: its PistolSpawner / RifleSpawner flies to the player and is picked up ("You got the Assault Rifle") |
| Riposte Edge | x1.5 at level 1 (+0.25 a level), was x2 | a real `CutAlong`: 30 unprimed, 45 primed; the prime is spent on the cut |


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
