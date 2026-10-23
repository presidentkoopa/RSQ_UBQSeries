# RS_ShieldSawQ — handoff to the local lane (2026-10-23)

State: **v0.6**, commit on `main`. Everything structural works; what is left is tuning that needs
a headset beside the editor. This file is the whole picture: what is built, how it is wired, the
four open symptoms with their likely causes and the exact code to look at, the engine facts that
bit us, and the headless harness that catches script errors before a headset run.

Design and history: `ShieldSaw_Quest_Design.md` in the zDoomVR project.

---

## 0.5 v0.7 (2026-10-23) -- the four symptoms, answered

All four of section 2 were worked, plus the off-hand fight. In short:

- **Wrong side / plate not on the geometry.** Settled by measurement, not by flipping signs:
  `ssq_plate_l` is **-7.5** (the arm is on the plate's +L side) and the face normal is exactly
  **-L**; radius 29.2 closed, 35.2 deployed. `ssq_plate_yaw` / `ssq_plate_pitch` are gone --
  there is nothing left for them to tilt. The derivation is in the header of `guard.zs`.
- **Lock-on does not stay locked.** `LocksTick` no longer rebuilds and re-sorts every tic. A
  lock is acquired in `ssq_lock_cone` and kept until it dies, leaves `ssq_lock_keep` (60 deg)
  or is out of sight for `ssq_lock_grace` tics. Acquisition order is the visit order.
- **The throw and the return.** `ThrowVel` now takes `pixelstretch` back out of the magnitude
  (vertical swings read ~20% slow before); `ssq_throw_speed` 1.6 and `ssq_speed_floor` 12; the
  disc leaves **along the first ringed target** when there is one, instead of being steered
  onto it at 22% per tic from whatever heading the swing had. A bounce during `PH_HOME` now
  drops the crumb it is fighting, and after `ssq_home_patience` tics the return goes NOCLIP and
  flies straight to the hand -- it cannot be left on the floor by the 12 s age cap any more.
- **Mount and hiding.** The stowed shield is drawn again (`ssq_stow_world`, default on) at the
  grab point itself in the measured pose -- the mesh origin is the grip, so the disc hangs
  below on its own and `ssq_mount_drop` is gone. The held world prop was being placed at the
  plate centre, a whole radius off the hand; it now sits at the controller.
- **The two-hand grab and `switchhand`.** `PinHands` is gone. Eviction is treated as the player
  putting the shield down (`HoldOrYield` -> `Stow`), `+WEAPON.NOHANDSWITCH` already blocks
  `switchhand 0`, and the grab needs no handling at all because every input is read from
  `p.cmd.buttons`, which it cannot gate. While the grab hides the off-hand psprite the world
  prop stands in. See `_reports/QZD173_MELEE_STUDY_2026-10-23.md` section 3 for the source.

**None of it has been run.** No engine was launched for this work and none should be: the owner
does the headset checks. Section 2 below is kept as written, as the record of what was wrong.

---

## 1. What it is, as of v0.6

Standalone pk3 for stock QuestZDoom 17.3 (`emawind84/gzdoom @ questzdoom`, the TeamBeef build).
No engine changes. Loads with BD22 Quest or alone. Ermac's hand on the shield (his placement).

Input is three of QZD's own **actions** (bind in Customize Controls; never a physical key):

| Action | Does |
|---|---|
| **Use**, with the off hand at the shoulder point | holstered → the shield is in the off hand; drawn → back on the shoulder |
| **Offhand Attack** held | revs the saw (blades deploy, loop pitch climbs, grinds what it touches, revved throws hit harder) |
| **Offhand Alt Attack** held | lock-on: rings over up to 5 monsters in a cone from where the off hand points |
| **Offhand Alt Attack** released while the arm is moving | throw, at the ringed targets in order; released still → stays in the hand |
| **Offhand Alt Attack** pressed while it flies | recall |

While the shield is held, **both hands are pinned**: QZD's `switchhand` button, weapon cycling,
pickups — anything that moves a weapon — is undone the same tic (`SSQ_Handler.PinHands`). Only the
release moves the shield. On throw/holster the previous off-hand weapon (or the pack's hands) and
the main gun come back.

Blocking: `SSQ_Guard : Inventory`, `AbsorbDamage` — the engine calls it on every machine for every
damage to the player (`p_interaction.cpp:1347`). The attack line (missile path / shooter→centre /
striker→centre / blast→centre) is tested against a **thick disc** (`Crosses`): radius
`ssq_plate_radius`, half-thickness `ssq_plate_thick`, centre and face from the synced hand pose
when held, from the mount when holstered. Blocked → damage 0, sparks + flash at the crossing
point (RS_CombatFX `RSS1`/`RSS0`/`RSH0`, renamed `SSQX/Y/Z`), buzz, striker reels/shoved, missile
spawned back at its source. No per-mod patches: it keys on damage, not on classes. BD22's bullets
are `FastProjectile`s and arrive as missiles.

Pose sync: the console player's machine sends `ssq-pose` once a tic (pos rel. to pawn in quarter
units, yaw/pitch/roll of the controller, handedness bit) while drawn / flying / in the zone / a
shield button held. Every machine keeps an 8-sample history per player (`SSQ_Pose`). **The sim
never reads `OffhandPos` directly** — only that history — so SP and netplay run the same code.

Haptics: `A_QuakeEx` at the player's own feet, tremor radius 4 (X = left controller, Y = right;
needs `vr_quake_haptic_level > 0`). Deterministic; only the owner feels it.

Files:

```
zscript/ssq/pose.zs    SSQ_Pose (history, axes built IN PLACE, peak-speed throw velocity); SSQ_Hand (QZD fields, packing)
zscript/ssq/state.zs   SSQ_Handler: states, mount point, zone, input edges, PinHands, locks you see, props, debug HUD, net events
zscript/ssq/guard.zs   SSQ_Guard: plate geometry, AbsorbDamage, Crosses (thick disc), deflect, grind, bash, debug ring
zscript/ssq/shield.zs  SSQ_ShieldSaw (off-hand Weapon): states, rev, ModifyBobLayer3D (live cvars + forward to RSQ_Hands), SSQ_FX
zscript/ssq/disc.zs    SSQ_Disc: launch, steering through the lock list, tiers, breadcrumb return, catch; trail, lock mark
zscript/ssq/props.zs   SSQ_Prop (holster / others' view), SSQ_MountMarker, block flash & spark actors
```

Debug (Options → RS ShieldSawQ Options → Debug):
- **Print decisions and key codes** (`ssq_debug`): console lines on press/release/draw/throw/home,
  every guard decision with the full geometry (`A B C n`), the pose once a second while held
  (`F L U hand C n R fresh`), and a **3-line HUD** top-left: state / weapons in each hand /
  pending; the four fire bits + stabilise bit + rev + lock count; pose freshness + distance to the
  mount point + in-zone.
- **Draw the guard plate** (`ssq_debug_ring`): 36 red particles on the plate rim, a red centre, a
  **green spoke along the face normal**, a blue dot at the controller, white dots along the
  controller's forward.

---

## 2. The four open symptoms, with where to look

### 2.1 "Ring on the wrong side of the shield"

The plate is placed relative to the controller by three cm offsets and faces along `+L`
(controller left, `s` = +1 right-handed / −1 left-handed):

```
guard.zs  PlateCentre():  C = hand + F*ssq_plate_f + L*(ssq_plate_l*s) + U*ssq_plate_u
guard.zs  PlateNormal():  n = L*s  (tilted by ssq_plate_yaw toward F, ssq_plate_pitch toward U)
CVARINFO: ssq_plate_f -15.4, ssq_plate_l 8.4, ssq_plate_u -5.0  (cm; derived from the mesh and
          Ermac's MODELDEF placement, never seen in a headset)
```

Those numbers came from mapping `shield.md3` through the HUD-model chain in `models.cpp
RenderHUDModel` (mesh x→forward, mesh y→left after `Scale -1`, mesh z→up; disc centre at mesh
(−9.4, −8.4, 0) relative to the hand at (4.3, 1.8, 0)). "Wrong side" means the `L` sign (or the
mirror the engine applies to the left controller) is the opposite of what I assumed. **Tuning:**
with the ring on, flip `ssq_plate_l` to `-8.4`; if the ring is then on the shield but the green
spoke points into your arm instead of out of the face, `ssq_plate_yaw 180`. Adjust `ssq_plate_f`
(along the forearm) and `ssq_plate_u` until the red ring hugs the drawn rim. Then bake the numbers
into CVARINFO. Because the block is a thick disc (`ssq_plate_thick` 25 cm), blocking already works
even with the sign wrong; this is for the sparks to land on the face and the lock cone to be sane.

Also worth checking in the same look: `ssq_roll_sign` (−1 if the ring rolls the wrong way when you
twist the wrist) — it also decides the disc's flight plane at launch (`disc.zs Launch`).

### 2.2 "Lock-on does not stay locked on"

`state.zs LocksTick()` rebuilds the list **every tic** from a cone of `ssq_lock_cone` (25°) around
the controller's forward `pose.F`, nearest-angle-first, line of sight required, and the rings
follow the list. So a target drops out the moment the hand drifts 25° off it, and the order
re-sorts as you move. That is "does not stay locked".

Suggested rule (not built): **sticky locks** — once a target is in the list it stays until (a) the
alt button is released, (b) it dies, (c) it leaves a wider *keep* cone (say 60°) or line of sight
for > N tics. New targets are added from the acquire cone only while the list has room. Keep the
order of acquisition (first ringed = first visited) instead of re-sorting. All of that is local to
`LocksTick` and `ShownLocks`; the disc reads the list once at launch (`disc.zs FindLocks`).

Also: the aim axis is the controller's forward (`pose.F`). If the ring from 2.1 shows the face is
really along `L`, consider aiming the cone along the *face normal* or along the arm — the owner
should say which feels right.

### 2.3 "Shield does not return to the shoulder"

The return (`disc.zs Tick`, phase `PH_HOME`) walks the breadcrumbs back
(`crumbX/Y/Z`, one every `ssq_crumb_every` = 4 tics outbound), then flies to
`SSQ_Handler.MountPos(thrower)`. It ends with `Done(false)` when within `ssq_return_speed*1.2`
of the current goal and no crumbs remain. Things to check in order:

1. **Ends in a wall / floor**: `+BOUNCEONWALLS/FLOORS/CEILINGS` with `+USEBOUNCESTATE` — the
   `Bounce` state calls `Home()` only when `phase == PH_OUT`; a bounce *during* the return does
   nothing, so a crumb path that clips a corner can leave it bouncing. Fix: on bounce in
   `PH_HOME`, skip to the next crumb (`crumbAt--`) or straight to the mount.
2. **The shortcut**: `if (crumbAt > 0 && CheckSight(thrower)) crumbAt = -1;` jumps straight to the
   mount as soon as the disc can see the thrower — the mount point is 27 cm behind and 30 cm
   below the headset (`ssq_mount_fwd/up`), i.e. **inside the player's body**; the disc is
   `+MISSILE` with radius 10, so it can collide with the player? No — `target` = the thrower, and
   missiles pass their shooter. But it can still hit the *floor* (mount z is low) and bounce.
   Try raising `ssq_mount_up` for the return goal, or end the return at the headset instead and
   let `DiscHome` snap the state.
3. **Age limit**: `age > 35*12` → `Done(false)` after 12 s regardless; if it "never" returns, it is
   stuck for < 12 s and then lands. That's the bounce case above.
4. The owner's "weird slow-throw motion" (2.4) may actually *be* the return phase seen from the
   wrong angle: `ssq_return_speed` 22 units/tic is fast; the breadcrumb walk is a straight line
   per crumb, so it zig-zags on a curved throw. Look at it with `ssq_debug` on: `disc home` prints
   when it lands.

### 2.4 "Some weird slow-throw motion"

Three candidates, all in `disc.zs`:

- **Launch speed**: `Launch()` uses the **peak** 2-tic hand velocity over the last 6 samples
  (`SSQ_Pose.ThrowVel`, units/tic) × `30/(30+ssq_mass_kg)` × `ssq_throw_speed` × rev bonus, floored
  at `ssq_speed_floor` (7). A slow-ish swing at the 20 units/s threshold launches at ~0.6
  units/tic → floored to 7. 7 units/tic = 7 m/s-ish at 34 u/m... that is slow for a thrown disc.
  Raise `ssq_speed_floor` to ~16 and `ssq_throw_speed` to ~1.5, or map hand speed through a curve.
- **Steering**: with a lock, `vel = vel*0.78 + want*0.22` then renormalised to `cruise` — it
  cannot speed up beyond the launch speed, and it banks toward the first target from tic 1. If the
  launch was along the swing but the target is behind the hand, it loops. Consider launching
  *toward the first lock* when one exists.
- **No lock, free throw**: flies 2 s (`age > 35*2 → Home()`), then turns around. A gentle lob
  that returns after 2 s reads as "weird slow motion".

Check with `ssq_debug`: the `THROW ... speed X/tic` line prints the launch speed; `release p0
speed N/s, K locked` prints the measured hand speed and lock count.

---

## 3. Engine facts that cost time (QZD 17.3 stock, `qzd173-pinned`)

- **VM drops multiple `Vector3` returns and `out Vector3` params** (silently zero / JIT abort).
  Never return or out-pass vectors. `SSQ_Pose.Push` builds axes in place; `SSQ_Guard.Plate()` and
  `Crosses()` write member fields. Scalars and `out Array<Actor>` are fine.
- `abs(x) < 1e-6` did not stop a true zero divide in `Crosses` on this build; use `x == 0 ||
  x != x || (x < 1e-6 && x > -1e-6)` with plain literals.
- `Array<Vector3>` is not allowed (use three `Array<double>`).
- `OffhandDir`, `GetSpriteIndex`, `Spawn` are play-scope: the pose is sampled and sent from
  `WorldTick` for the console player, not from `UiTick`.
- MODELDEF only knows a sprite that some **state** names; a sprite written to a layer at run time
  must appear in a dummy state or startup dies with "Unknown sprite" — in a dialog, not on stdout.
- `P_PlayerThink` (weapon buttons, fire) runs **before** `WorldTick` in a tic (`p_tick.cpp:166-173`).
- `switchhand <0|1>` is a console command (`g_game.cpp:334`) calling `PlayerPawn.SwitchWeaponHand`,
  which nulls both hands and moves the gun across; the Quest layer binds it to an off-hand button.
  It is not a net command (QZD's own desync).
- Weapon switches happen inside the *old* weapon's ready state; if that layer is gone, nobody
  performs the switch — call `mo.BringUpWeapon()` yourself after setting `PendingWeapon`.
- The off-hand weapon's `ModifyBobLayer3D` is called for every layer not owned by the ready
  weapon; the pack's gun-side hands depend on `RSQ_Hands`' hook, so ours forwards to it (found by
  a run-time `Name`, no compile-time link).
- Left-handed is the engine's `vr_control_scheme >= 10` (local cvar) — carried in the pose event's
  arg3 bit 0 so peers mirror correctly.
- The controller relative to the headset: pawn XY **is** the HMD XY; `player.viewz` tracks the HMD
  height; `OffhandPos − (pawn.x, pawn.y, viewz)` is the controller relative to the head
  (`gl_openxrdevice.cpp:586-593`). Measured grab point: 27 cm back, 12 cm to the off side, 30 cm
  below the headset (owner, 03:17) → `ssq_mount_fwd/side/up`.
- Haptics: `vrmode->Vibrate` is reachable from script only via the quake route or a player
  `LineAttack`; the quake one is used.

---

## 4. The headless harness (catches every script error before a headset run)

Linux build of upstream `emawind84/gzdoom @ questzdoom` (two harness-only patches needed on Linux:
null `cmdlineprofile` in `m_misc.cpp M_GetActiveProfile`, short rows in
`stringtable.cpp ParseLanguageCSV`). Run under Xvfb + llvmpipe; a fatal script error shows as a
**dialog**, so the harness screenshots the display on a timeout.

```
test.sh "<console command string>" [seconds]
  packs the pk3 (excluding .git/docs), runs -warp 1 with +ssq_debug 1 +sv_cheats 1 and the
  command string as ONE +"..." argument (QZD's `wait` only defers the rest of the same string),
  greps the log for ssq:/errors, screenshots stuck.png if it does not exit.
```

Useful scripts:
- block, holstered: `wait 140; summon DoomImp; wait 10; turn180; wait 300; quit`
- draw/throw/return by the desktop keys: `wait 140; netevent ssq-draw; wait 70; netevent ssq-throw; wait 175; quit`
- **inject a hand pose** (the sim reads only the net event, so this exercises the real path):
  pack args with the Python in the session log (`packpos(x,y,z)` quarter units rel. to the pawn,
  `packang(yaw,pitch,roll,grip)`), then `netevent ssq-pose A B 0` once a tic. A hand 16 units in
  front at z 26 facing the imp blocked claw and fireball on the **held** plate; `+oh_altatk` held
  over it gave `1 locked`.
- hand switch: `switchhand 1` mid-hold → both pins print and the throw still shows the pistol in
  the main hand.

---

## 5. What the owner has decided (do not re-open)

Shoulder only, nothing drawn when holstered, no placement/controls menus, hand always on the
shield, left-handed from the engine, the three actions above, grab on the first tic (no wait),
stray-shot prevention by the zone (Use is not a fire button, so it no longer matters), lock-on =
up to five, throw = release at speed, missed catch → mount, blocked missiles → return to sender,
holstered shield guards the back, name `RS_ShieldSawQ`. Options menu = exactly the list in
`MENUDEF.txt` top level, no descriptors.
