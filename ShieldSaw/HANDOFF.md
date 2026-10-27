# Ultra Badass ShieldSaw — handoff

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

Loads alongside the owner's **UltraBadassQuestSaber** — two separate mods, either order, either
one absent. See §6.

Packaged as `UltraBadassShieldSaw.pk3`. Classes, cvars and sprite lumps keep the `SSQ_` / `ssq_`
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
they were. (UltraBadassQuestSaber reaches the same answer for its blade lengths — that is what
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

`RSQ_Hands` re-gives itself to an empty off hand; UltraBadassQuestSaber's bridge gives
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
