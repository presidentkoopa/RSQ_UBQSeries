# RSQ ShieldSaw — handoff

## 2026-10-31: owner's picks 12-15 and a bash you can see -- read first

Rig only (QZD 17.3 Linux, doom2 MAP01, brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded 2.0.3h + hotfix ->
RSQ_ShieldSaw + RSQ_Saber [+ RSQ_SlowMo]), **not headset-confirmed**. Probe: `tools/rigtest/ssprobe` (test only:
puts the player 90 units short of the wall north of the start with an idle imp between; real hand motion through
`qz_lhand`). Zero script errors from the pack.

| pick | what | rig (measured) |
|---|---|---|
| 12 wall slam (on) | after a bash the victim is watched 12 tics (+ any freeze); last tic's move stopped by a line (`MovementBlockingLine`, p_mobj.cpp:2231, cleared :4338; WorldTick runs before the thinkers, p_tick.cpp:171) while going into it at `ssq_slam_min` 3 u/tic or more = a slam: 2 x impact (5..40) x `ssq_slam_damage`, forced PLAIN pain, `ssq_slam_stun` 8 tics frozen, rebound 0.45 x impact off the wall (surveys/01_MELEE.md 4.7) | real bash 298 u/s: imp 80 -> 40, flew 25 u/tic, `WALL SLAM imp at 24.1 u/tic, dmg 12 (40 -> 28)` (slam damage 0.3), frozen 8 tics in pain at the wall, then off it at 10.8 u/tic |
| 15 saber over shield (on) | decided on the player's own machine (raw `AttackPos` + `AttackDir`), sent as `netevent ssq-brace`, so the sim reads a synced flag. Main weapon class `UBQS_*` (not ForceHand), `UBQS_SaberService` "saber.lit" hand 0 == 1 when it answers, blade = hand F cos50 + U sin50 from BeamAlong(5.111,6.091) to (37.94,45.216) -- the saber's resting frame worked out of its own code. Braced = 2+ of 9 blade points over the plate, within `ssq_brace_gap` 15 cm of the front. Block radius x `ssq_brace_widen` 1.3; grind and bash unchanged | estimate vs the saber's own `BladeDir()/BladeBase()/BladeLen()` in 6 poses: same direction to 0.01, base to 1 unit, length 28 vs 28.5. Toggles ON/off as the blade crosses / leaves the plate; block plate r 9.9 -> 12.9 while braced |
| 13 hit-stop (off) | `ssq_hitstop`, `ssq_hitstop_tics` 4 (01_MELEE 3.6): `freezetics` on the bashed body and on the source of a perfect block, never a player | bash: imp `freeze 4` the tic of the bash, knockback held till it thawed, then the slam as above |
| 14 perfect-block slow-mo (off) | `ssq_perfect_slowmo`: `netevent rsm_pulse 500 35` from the blocker's own machine (SlowMo clock.zs Pulse; depth = RS_Score's PULSE_DEPTH) | staged perfect (two pose samples 1 u apart along the face, real AbsorbDamage): melee 20 -> 0, `perfect block`, imp freeze 4, SlowMo scale 1000 -> 619 -> 350 for ~0.5 s -> 1000 |
| bash FX (owner, on) | `SSQ_FX.BashBurst`: BlockFlash 0.22 + SparkPuff 0.6 (through FlashOk / Dim), 8..16 sparks by bash speed, 3..8 brighter sparks thrown along the bash. No new sounds, nothing on the plate | `docs/screens/bash_fx_before_after.png`: old pk3 nothing at the bash; new a small flash and sparks at the body, sparks on the slam |

Found on the way (Brutal Doom's own behaviour, not changed): a bash on an IDLE BD imp can send it to BD's
stealth-kill cutscene (its `Pain.Melee` jumps to GotoStealthKill while it holds `SKImp`), old pk3 and new -- the
camera leaves the player for a few seconds. The slam's forced pain uses the plain Pain state so a wall never adds
a second way in.

Not done: planting the shield in the floor (pick 11, not wanted).


## Branch `shieldsaw-sweep` (2026-10-30): the grind and bash sweep, per-body grind, two residual holes -- read first

Not run anywhere: **not on the owner's headset and not through a compiler.** Code only, from the
refinement pass in `RSQ_QuestEngineSurvey/apply/03_SABER_AND_SAW.md` §1.5 and §1.7. Every engine line
below was opened in `qzd17.3` for this change, not taken on the report's word (the report's own numbers
for `hw_weapon.cpp` were one line out).

| | what | why |
|---|---|---|
| THE GRIND AND BASH WERE THE LAST POINT-SAMPLED CONTACT | `HeldTick` tested one plate centre -- the one the tic ended at -- while both block paths have walked the plate across `PlateTravel()` all along (`guard.zs:378-384`, `:484-505`). The victim test is now the same three-sub-step walk, `C + travel * (1.0 - s * 0.5)`, first touch wins (`guard.zs:698-715`) | the rim is the fastest-moving part of the shield. At a plain 3 m/s the plate crossed 2.91 units between evaluations with the per-body grind, and ~11.6 units with the old tic gate, against a 29 cm rim: bodies in the gap were never tested |
| it cost nothing | `PlateTravel()` already existed, already read the synced history, and is called once per tic outside the iterator (`guard.zs:684`). Per candidate it adds two subtractions and two dot products inside a `BlockThingsIterator` that was going to run | **no new traces of any kind.** `PlateTravel` took one new default argument, `assumeHeld` (`guard.zs:344`): it gates on `plateHeld`, which only `Plate()` writes and `HeldTick` never calls |
| `ssq_grind_every` IS PER VICTIM NOW | was a global tic gate (`maptime % every == 0`): the whole grind fired on one tic in four and did nothing on the other three, so a body the rim crossed on a skipped tic was never touched however squarely the plate was on it. Now `grindWho` / `grindWhen` on `SSQ_Guard` (`guard.zs:24-35`), tested at `guard.zs:722-731`, stamped at `:737-738`, pruned at `:780-792` | the saber's shape exactly (`ubqs_cut_rate`, `QuestSaber/zscript.txt:1873`, `:1892-1893`, `:1958-1959`, `:1968-1969`); the disc does the same for one victim (`disc.zs:475`). Strictly better than a tick rate: the cap on how fast one body can be hurt is unchanged, and nothing is skipped. It is also the only form that is any use with a swept rim |
| `ssq_held_world 0` NO LONGER REOPENS THE TWO-HAND HOLE | `want` was `hw == 1 \|\| (hw == 2 && multiplayer) \|\| (hw != 0 && grabbed)`; the last clause is now plain `grabbed` (`state.zs:862-872`) | the engine draws **no** off-hand psprite while the grab is held (`hw_weapon.cpp:832-835` and `:916-919`, both on the global `weaponStabilised`, which also raises `WF_TWOHANDSTABILIZED` at `p_pspr.cpp:512-515`). With `hw == 0` the shield left your own hand the instant the grip latched -- reachable from the options menu. `hw` still decides the ordinary ungrabbed case |
| THE WORLD PROP CARRIES THE HELD OFFSETS | all six `ssq_held_*` sliders, applied to the prop in the pose basis (`state.zs:882-931`) | the psprite gets them per frame in `ModifyBobLayer3D` (`shield.zs:176-177`) and the prop got none, so on anyone who had dialled those sliders in the shield jumped by the dialled-in offset when the grab started and jumped back on release |

**How the slider axes were derived, since it is the one part with no measurement behind it.** The layer's
translation and its three rotations are applied *inside* the MODELDEF mesh scale (`models.cpp`
`RenderHUDModel`: `S(xscale,zscale,yscale)`, then `T(pivot) . R(rotation.X about Y) . R(rotation.Y about X)
. R(rotation.Z about Z) . T(-pivot) . T(translation)`), and `hw_vrmodes.cpp MapWeaponDir` makes the layer
frame `X = -L, Y = U, Z = -F` -- which is why `shield.zs:176` packs the sliders as `(x, z, -y)`. The held
MODELDEF blocks mirror the mesh for the other hand (`SSQH` is `Scale -1 1 1`, `SSQJ` is `Scale 1 1 1`), and
the mirror conjugates everything about that X axis, so the lateral slide and the rotations about Y and Z
change sign with the hand and the rotation about X does not. `SSQ_Guard.Side()` is already that sign.
`SSQ_Prop` is not mirrored (`Scale 0.34 0.34 0.34`), so the code applies the effective post-mirror motion;
the rotated basis is written out in scalar components because `pose.zs:29-31` and `guard.zs:136` both record
that this VM drops a returned `Vector3`. **If the prop's trim rotates the wrong way for your hand, the two
signs to flip are `ry1` and `rr1` at `state.zs:911` and `:913`.** The slide is the part that stops the jump
and is independent of them. The one term not reproduced is the rotation pivot, which this mod never sets.

**Two things to watch in the headset.**

1. **The grind now evaluates every tic while revved**, so the `BlockThingsIterator` and its `CheckSight`
   run every tic instead of one in four whenever the saw is spinning. Nothing else in the loop changed and
   the bash always ran at that rate, but it is a real cost increase on Quest.
2. **`PlateTravel()` is deliberately absolute**, as it is for the block (`pose.zs:72-74`): it walks the plate
   through world space, and bodies are in world space too. That means walking forward at Doom run speed
   (~16.6 units a tic) sweeps the grind that far back along the path the plate really did take. That is
   physically what happened and `CheckSight` and the tight `onPlate` box still gate it, but if it reads as
   the grind reaching backwards while you walk, the body-frame difference (`pose.Vel()`, which already has
   the player's own travel removed) is the alternative -- say so and it is a one-line change.

Out of scope on purpose, from the same report: `+SHIELDREFLECT` (random ±45° off a *body* yaw via a playsim
RNG draw, `p_mobj.cpp:3468-3477` -- contraindicated, and the owner's netplay rule forbids it), the angular
lerp of the sweeps (report 03 §0.3, S-M), the peak-window perfect test (§1.4), the perfect-block haptic
envelope (§1.6), and the saber half entirely.

## Branch `agent-compat` (2026-10-27): Champions + LegenDoom Lite -- read first

Not yet run on the owner's headset. Rig C = QZD 17.3 Linux, doom2 MAP01, the owner's order (brutal22test6 ->
BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions -> LegenDoom Lite 4.2 -> suite -> Gun Bonsai 0.10.6 + VR patch)
and vanilla doom2 + Champions + LegenDoom Lite + suite; Champions' setting champion_Legendoom 1,
champion_Dormant 1, champion_Booster 1. Probe: the session scratchpad cp/probe (forces tiers through
champion_debug_forced / champion_OverrideChance 256, legendaries through LDLegendaryMonsterPickupGuaranteed).
Save, load twice, MAP02: no script error but BD_VoxelPack's voxeldef lines.

- Disc tiers by the health it has to lose: max(spawn health, health), plus an untransformed LegenDoom
  legendary's refill (spawn x LD_legendaryhealth/100, the ACS's arithmetic). Measured, ssq_bd22 1: a
  legendary BD imp (80 / 240) died to one disc hit before (forced bisect, its second life skipped); now it
  takes the grind (240 -> 150) and the disc goes on.
- No bisect through BUDDHA: the bisect is DMG_FORCED, which skips monster buddha (p_interaction.cpp). A Dark
  Red champion died to the disc outright before; now it is ground to 1 and plays dead as Champions intends.
- The embed ends when the victim stops being shootable: a hiding Dark Red is parked at (16384,16384);
  measured, the disc followed it there and stayed. Now it goes home.
- Bash: Thrust() checks no flag, so DONTTHRUST and max-mass (Champions' Bronze, 0x7FFFFFFF) bodies slid.
  Not thrust now. (Code only: the bash needs a headset swing.)

## Branch `agent-up2` (2026-10-27): plate growth, a sweep that sees missiles, credit for returned bullets -- read first

Not yet run on the owner's headset. Rig = QZD 17.3 Linux, doom2 MAP01 (and freedoom2), the owner's
load order + Gun Bonsai 0.10.6 + the VR patch `agent-up2`. Probe `up2/sxa` in the session scratchpad.

| | what | rig (measured) |
|---|---|---|
| THE SWEEP NEVER SAW A MISSILE | a projectile is +NOBLOCKMAP (the PROJECTILE combo), so the BlockThingsIterator in `SSQ_Guard.DoEffect` never returned one: an imp ball crossing the plate was absent from the iterator, and only the block on body contact ever turned a shot. Now `SSQ_Handler` keeps the missiles in flight (`mMissiles`, WorldThingSpawned, pruned each tic) and the sweep walks that list | before: ball flew through the plate at 53 units; after: turned at ~110 units, back into the baron |
| Broadening | `PlateRadius(blades, grow)`; `SSQ_Guard.GrowK()` asks the patch for "Broadening" once a second: 1 + 0.2 x level, double at 5. With the patch loaded this replaces `ssq_block_double`; without it the option still doubles | patch: 9.93 / 11.91 / 13.90 / 15.88 / 17.87 / 19.86 at levels 0-5, level 6 stays 19.86; option on with the patch: 9.93. No patch: option 0 9.93, option 1 19.86 |
| Lockstep | `ssq_locks` + level (FindTargets and LocksTick) | 9 imps: 5 locks, 7 with Lockstep 2 |
| returned bullet XP | `SSQ_Ricochet` gets `FriendPlayer` and `master` = the saw and is claimed through the patch ("claim"); the patch brackets its trace | zombie 10 -> -5, ShieldSaw XP +10, main-hand 0 |
| swept shot XP | BatBack sets `master` = the saw and tells the score memory it was turned (Rebound and a scorer now see swept shots too) | baron hit, ShieldSaw XP +12.5, main-hand 0 |
| bash | real `HeldTick`, pose pushed into the synced history with a plate moving 140 u/s along its face | imp 80 -> 49, ShieldSaw XP +31, main 0. NOTE: headless, `HeldTick` was not reached from the saw's Ready state; the probe called it |
| Bulwark | real `AbsorbDamage`, plate 15 u/s into the shot | perfect -1 without, 0 (this tic) with Bulwark 2 |
| Rebound | returned bullets x(1.1 + 0.15 x level) (was 1.25 + 0.25) | -- |

Why the earlier bash/Bulwark tests read 0: the rig's own headless controller sends an `ssq-pose` every
tic with the same stamp as a probe's, so two samples share a tic and `Vel()` is 0. The probe now
puts its own previous sample back behind its new one.

---

## Branch `agent-upgrades` (2026-10-27): Gun Bonsai melee upgrades — read first

Not yet run on the owner's headset. Rig = stock QZD 17.3 Linux build, freedoom2 MAP01, the owner's
load order (brutal22test6, BD_VoxelPack, BD22_VR-Reloaded_2.0-b1m, the Radiant Silvergun Quest series, RSQ_Score, Gun
Bonsai 0.10.6, the Gun Bonsai VR patch `agent-upgrades`).

The shield asks the Gun Bonsai VR patch for its upgrade levels BY NAME (`SSQ_Upg`, score.zs ->
`RSQ_MeleeUpgradeService`). Without the patch every level reads 0 and nothing changes (rig: loads
and runs alone with BD, 0 script errors).

| | what | rig |
|---|---|---|
| XP credit | the disc's `master` is the ShieldSaw (`SSQ_Disc.Claim`), the bash and grind are bracketed with the patch's `credit.push/pop` (they keep the pawn as inflictor for RS_Score), a turned missile's `master` is the saw | measured: before, disc / bash / grind XP all went to the main-hand saber; after, to the ShieldSaw (disc: real `ssq-throw`; grind: real HeldTick fed synthetic `ssq-pose` events) |
| Ricochet | a wall turns the disc toward the nearest visible enemy instead of home, one per level (looked for over 4 tics after the wall: at the wall itself CheckSight fails) | real throw: turned and embedded in a new target |
| Meat Grinder | a kill while embedded sends it at the next lock at `ssq_cruise_max`; 2+ finds a new one if there is none; grind +25%/level after 1 | real throw: embedded, kill, flew at 34 u/tic into the next imp and killed it |
| Hunter's Return | on the way home it swerves into enemies within 160+32/level of it, one per level | real throw: imp beside the return path 80 -> 2 |
| Bulwark | perfect block needs `ssq_perfect_speed / (1 + 0.35 x level)` | NOT measured (needs plate velocity) |
| Rebound | returned bullets x(1.25+0.25 x level) here; turned missiles get the same from the patch | turned 20-damage missile: 20 -> 30 at level 1 |
| Battering Ram | after a bash the patch makes the monster a missile (`ram`) | service call on a flying imp: 14 to the one it hit, 7 to itself |

Known limit: a returned bullet is fired by `SSQ_Ricochet`, so Gun Bonsai cannot credit its damage
to anyone (no player source). Rebound still multiplies it.

---

## Polish branch `polish/quest-series` (2026-10-26) — read first

Not yet run on the owner's headset. Rig = QZD 4.12-era Linux build, freedoom2.

| | what | check |
|---|---|---|
| S1 | switching main weapons with the shield drawn: the switchhand fingerprint (`took == back || back.bOffhandWeapon`) tells a real hand swap from an ordinary switch | rig: Rifle and saber switches keep the shield drawn |
| S3 | stow latch: one Use press cannot draw and stow in the same breath | — |
| S4 | a returned bullet is fired by a non-player helper (`SSQ_Ricochet`): a player LineAttack in VR is re-aimed down the main controller and buzzes the main hand | — |
| S2/S5/S6/S7/S8 | dead BounceCount gone; embed goes on to the next lock; Next() outside tiers; main restore before the off-hand handover; null guards | — |
| haptics | `SSQ_FX.Buzz` -> `SSQ_Buzzer` QF_WAVE emitter on the off hand (lefty-aware) | gdb: chan 0 (left) on draw |
| defaults | code fallbacks now equal CVARINFO defaults (mount, zone, throw min, speed floor, perfect/bash speed, lock cone) | — |
| menu | every cvar on a menu: new **Advanced** page (lock button, off-hand switch, back-mount, held nudge, timings...); size slider step 0.125; one reset row covering all 90 cvars | regression loads; menu opened in the rig |
| comments | dead ZoneTick removed; rev button, sprite count, WorldTick, throw-speed arithmetic (a 6 m/s swing is ~8 u/tic, so the 12 floor sets it), embed_dps is per tic | — |

Independent review, fixed: stowing with a two-handed main weapon emptied the main hand again
(BringUpWeapon nulls a two-handed main when an off-hand weapon rises) -> the off-hand handover is
skipped then; a free throw with Hit Tiers off went home after its first glance -> flies on again;
a monster hit by a returned bullet chased the vanishing helper -> retargets the player; buzzer
Tick after self-destroy -> guarded.

Open: feel numbers (rumble strength, throw min 60 u/s) are headset questions. Known limit: a
returned bullet is credited to the helper, so co-op friendly-fire rules do not apply to it.

---

## v0.7 handoff (2026-10-23)

A shield that is also a throwable saw disc, in the off hand, for **stock QuestZDoom 17.3**
(`emawind84/gzdoom @ questzdoom`, TeamBeef's build). Standalone pk3, no engine changes, and none
are permitted: anything it needs it does in ZScript or it does not do.

Loads alongside the owner's **RSQ_Saber** — two separate mods, either order, either
one absent. See §6.

Packaged as `RSQ_ShieldSaw.pk3`. Classes, cvars and sprite lumps keep the `SSQ_` / `ssq_`
prefix: renaming those would break saved games and the git remote for nothing.

---

## 1. What it does

Input is QZD's own **actions** (bind in Customize Controls; never a physical key):

| Action | Does |
|---|---|
| **Use**, off hand at the shoulder point | holstered → shield in hand; drawn → back on the shoulder |
| **Offhand Attack** *or* **Offhand Alt Attack**, held | revs the saw and paints lock-on targets |
| the same, released while the arm snaps forward | throws, at the ringed targets in order |
| the same, released still, or not forward | nothing; it stays in your hand, marks kept a second |
| the same, pressed while it flies | recall |

Either off-hand button, because QZD's stock binds put `+oh_altatk` behind a grip shift — the same
grip that arms the two-hand grab, so on a Quest the alt alone was unreachable in practice
(`ssq_lock_button`: 0 alt only, 1 either, 2 trigger only).

Defence is four separate things:

- **The sweep** (`ssq_sweep`) — every tic, missiles whose path crosses the plate in the next
  `ssq_sweep_lead` tics are turned, including ones that would have missed. Proactive.
- **The muzzle** (`ssq_hitscan_guard`) — `WorldHitscanPreFired` cancels a bullet before it is
  ever traced if its ray crosses the plate and is coming at you. A stopped bullet goes back out.
- **AbsorbDamage** — the backstop, for melee, blasts and anything the first two did not catch.
- **The bash** — drive the plate forward at `ssq_bash_speed` and everything within
  `ssq_bash_reach` of it is damaged, shoved and lifted off the floor.

A turned shot goes where `ssq_deflect_aim` says: back at the shooter, **where you are looking**
(the default, helped onto an enemy within `ssq_deflect_assist`), or mirrored off the face.

**Perfect block**: the plate moving *into* the attack at `ssq_perfect_speed` when it lands. The
shot returns 60% faster, melee always staggers and shoves, and it tells you — a tone higher, a
longer buzz, a white bloom at the contact point.

---

## 2. The geometry, which is measured and not guessed

`shield.md3` followed through the stock HUD-model chain (`models_md3.cpp BuildVertexBuffer`,
`models.cpp RenderHUDModel`, `hw_vrmodes.cpp MapWeaponDir`) reduces, in the off controller's own
frame and in cm, to `F = mx - 6`, `L = my` (right-handed scheme; `-my` left), `U = mz - 5`.

The meshes measure:

```
shield_rim     centre F -15.36  L -8.37  U -4.93   radius 28.46 / 29.27
shield_back    centre F -15.40  L -6.60  U -5.00   radius 29.04
shield_front   the saw housing, L -16.03 .. -8.86, in-plane radius 29.16
saw blades     L -8.70 .. -8.02, tip radius 29.2 retracted, 35.2 deployed
shield_handle  a bar at F -1.3, L -4.5, spanning U -13.8 .. +4.4: the grip
hand_ssq       straddles the origin, F -13.3..9.1  L -3.9..8.5  U -11.7..3.0
```

So the disc sits **15.4 cm back along the forearm, 7.5 cm to the controller's RIGHT and 5 cm
down**, radius 29.2 closed and 35.2 with the blades out, and the **arm is on the plate's +L
side** — the face looks the other way, `-L`, to within 0.001. v0.6 had that sign inverted and the
normal pointing into the forearm, which was both "the shield guards the wrong side" and "the
plate is not on the geometry". `ssq_plate_yaw` and `ssq_plate_pitch` are gone; there is nothing
left for them to tilt.

**The mesh origin is the grip.** That is why the world prop sits at the controller and the disc
hangs 15 cm back by itself, and why the stowed shield hangs below the grab point with no drop
fudge. `ssq_debug_ring` draws the plate: rim, a green spoke along the face normal, the hand.

---

## 3. Size: five baked meshes

MODELDEF fixes a model's size at load, and the only thing a mod may change per frame is which
**sprite** the layer carries. So `ssq_shield_scale` (1.0–1.5) picks between five baked blocks —
`SSH1..SSH5` right-handed, `SSJ1..SSJ5` left — and `SSQ_ShieldSaw.HeldSprite()` does the
picking. The same number scales the guard plate, so what you see and what blocks stay one object.

The sizes are in the **mesh**, not the block: `shield_s2..s5.md3` and `shieldsaw_s2..s5.md3` are
the originals scaled about their own origin. A block's `Scale` would have grown the hand with the
shield; scaling about the grip leaves the hand, the grip point and the `Offset` exactly where
they were. (RSQ_Saber reaches the same answer for its blade lengths — that is what
its ten thousand sprite lumps are: labels, one per baked block.)

---

## 4. Engine facts that cost time (stock QZD 17.3 = `670d19eba6^`, NOT the local HEAD)

- The checkout at `E:\DOOMWork\QZD17-engine` carries the owner's own additions at HEAD
  (`ButtonInject`, `RegisterModelStateFrame`, `SetModelSurfaceOffset`, …). **None of them exist
  on the engine this pk3 runs on.** Verify every symbol against `670d19eba6^`.
- The VM drops **multiple `Vector3` returns and `out Vector3` params** (silently zero / JIT
  abort). `Array<Vector3>` is not allowed either (three `Array<double>`).
- `abs(x) < 1e-6` did not stop a true zero divide; use `x == 0 || x != x || (x < 1e-6 && x > -1e-6)`.
- `LineAttack` takes **11** arguments, not 12: `(angle, distance, pitch, damage, type, puff,
  flags, victim, offsetz, forward, side)`.
- `ModifyBobLayer3D` returns a translation and a rotation. **There is no scale**, which is why
  §3 exists.
- `OffhandPos.Z` is divided by `pixelstretch` while X and Y are not
  (`hw_openxrdevice.cpp:605-609`), so hand travel is **not metric**: a vertical swing reads ~20%
  slow. `SSQ_Pose.ThrowVel(ps)` takes that back out of the magnitude only.
- MODELDEF only knows a sprite that some **state** names; a sprite written to a layer at run time
  must appear in a dummy state or startup dies with "Unknown sprite" — in a dialog, not on stdout.
- `P_PlayerThink` runs **before** `WorldTick` in a tic (`p_tick.cpp:166-173`).
- `switchhand` is a console command, not a net command, and its argument is the **destination**
  hand — so it moves the weapon in the *other* one. `+WEAPON.NOHANDSWITCH` blocks `switchhand 0`
  only; `switchhand 1` nulls both slots and no flag of ours prevents it.
- The two-hand grab never touches `OffhandWeapon` or the hand pose. It only disables the off-hand
  weapon's ready/fire/button machinery and hides its psprite in C++. Every input here is read
  from `p.cmd.buttons`, which it cannot gate; the world prop covers the hidden psprite.
- `vr_quake_haptic_level > 0` is required for `A_QuakeEx` haptics to be felt.
- Full study: `E:\DOOMWork\_reports\QZD173_MELEE_STUDY_2026-10-23.md` (its §9 is fork material —
  off limits for this mod).

---

## 5. Files

```
zscript/ssq/pose.zs    SSQ_Pose (history, axes in place, true-speed ThrowVel); SSQ_Hand
zscript/ssq/state.zs   SSQ_Handler: states, mount, zone, input, sticky locks, the muzzle hook,
                       PinHands / HoldOrYield, props, debug HUD, net events
zscript/ssq/guard.zs   SSQ_Guard: plate geometry, the sweep, the hitscan stop, AbsorbDamage,
                       Crosses, DeflectDir/GazeTarget, grind, bash, debug ring
zscript/ssq/shield.zs  SSQ_ShieldSaw (off-hand Weapon): rev, baked-size HeldSprite,
                       ModifyBobLayer3D (live cvars, forwards to RSQ_Hands), SSQ_FX
zscript/ssq/disc.zs    SSQ_Disc: launch along the first lock, steering, tiers, the return that
                       cannot fail, catch, trail, SSQ_LockMark
zscript/ssq/props.zs   SSQ_Prop (holster / others' view), SSQ_MountMarker, block flash, sparks
```

---

## 6. Living beside other off-hand mods

`RSQ_Hands` re-gives itself to an empty off hand; RSQ_Saber's bridge gives
`UBQS_SaberOff` to one every tic while dual is on. Both are right to, neither knows about us, and
**event handlers tick in load order** — so being correct could not depend on running first.

- The shield **writes the slot itself** (`p.OffhandWeapon = saw`) on draw and in `PinHands`,
  rather than asking via `PendingWeapon`. Whoever ran before is overridden; whoever runs after
  finds a hand that is not empty and leaves it alone.
- On stow it **hands the slot over in the same tic** — to what it displaced, or deliberately to
  whoever would have claimed it (`HandBack`).
- `IsFiller` names the weapons that put themselves there, by class name at run time, so an absent
  mod is a null and never a compile error.
- `ssq_yield_offhand 1` is the other policy: treat a *deliberate* switch as the player putting
  the shield down. Off by default.

Checked: shield alone, saber alone, shield first, saber first — all compile clean. No class,
cvar, sprite, model or sound name is shared.

---

## 7. Decided, do not re-open

Shoulder mount only; nothing drawn when stowed and no blocking when stowed (both switchable,
both off — a shield you cannot see should not stop bullets); hand always on the shield;
left-handed comes from the engine; lock-on up to five; throw is a release at speed in the
direction you are looking; a missed catch lands on the mount; blocked missiles go back; the
options menu is the list in `MENUDEF.txt`, no descriptors.


## 2026-10-27 (owner's headset rounds)

- **Rev fixed with BD22Q.** BD22Q asked for its hands weapon in the off hand every tic; PinHands
  answered with BringUpWeapon, whose Select zeroed the rev, so it never wound up and the blades never
  opened (rig probe: rev stuck at 1 with BD22Q, 21 without). A raise merely asked for while the shield
  is in the hand is now cancelled, not answered. Rig with BD22Q: rev 21, frames 5-7.
- **Brutal Doom v22 monster compatibility** (`ssq_bd22`): sliced up to 250 spawn health, grinding up
  to 1200 (BD health measured: imp 80, demon 200, revenant 250, baron 1200). Rig: a BD imp was ground
  down over ~16 tics with it off, bisected in one hit with it on.
- **Lock-on is its own button** (`ssq_lock_input`: Use away from the mount by default, a bindable
  "ShieldSaw: lock on (hold)" key, or the throw button as before). The trigger revs and throws on a
  flicked release (`ssq_lock_button` default 2). Locks kept 105 tics out of sight (was 14), rings 175
  tics after letting go (was 35); saved old defaults are moved. Rig: Use held 25 tics locked a BD imp;
  the lock held ~5 s after letting go; saved 14/35/1 read back 105/175/2.
- **Draw from the shoulder with Use** (`ssq_shoulder_use`): off, only the Draw key draws and the rig
  keeps the shoulder.
- **SSQ_ScoreService** (score.zs): blocks and turned shots for a scorer, by name. A returned bullet's
  helper is a MISSILE now, so its kill is credited to the player who turned it.
- **SSQ_ScoreService answers more** (score.zs; for RSQ_Score's second melee round): `perfect` (tics
  since a PERFECT block of that monster -- the Blocked hook moved below the perfect test in guard.zs),
  `GetObject("returned.from", shot or monster)` (who fired a shot the shield turned, or the bullet it
  sent back), `thrown.leg` (disc out 0 / home 1, from its phase), `disc.grinding` (0 while stuck in a
  monster). Rig (RSQ_Score probe mlprobe): a perfect block then a kill paid Perfect Riposte 0.7; a
  shot turned by the shield killing its own shooter paid Poetic Justice; a disc out-kill then a home-
  kill paid Boomerang (with `ssq_bd22 1`); a BD imp ground by the stuck disc paid Ground Down.
- Not felt in a headset: the flick throw with the trigger alone, Use as the lock button.
