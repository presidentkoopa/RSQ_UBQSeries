# tools/rig: testing bd22q in the real engine (TEST ONLY, never ships)

> **Where this lives (2026-11-27).** This rig moved here, to RSQ_UBQSeries `tools/rig`, from RS_ModelSwapper (before that:
> RSQ_WeaponDepot). Every file is unchanged from RS_ModelSwapper commit `7c1207f`. `tools/depot.py` came with it (the
> paths `rig.py` and `inputproof.py` read), and `HANDBOOK_test_rig.md` is the handbook chapter on using it. Older notes
> below that say "the Depot" or `sets/bd22q` mean the repo this rig sits in and the set named by `$RSQ_SET`.
> Checked after the move: `bin/qz` passes its version guard and boots doom2 to MAP01 from this folder.
> `inputproof.py turn --run` passes too (0 checks failing). It runs the engine in a throwaway copy, and `qz` needs `PINS`
> beside it there: point `B22_RIG` at a folder holding `bin/`'s files plus `PINS` (`cp -r bin /tmp/r && cp PINS /tmp/r`).
> The plain `B22_RIG=bin` default stops with rc 3; it did the same in RS_ModelSwapper.


The real QuestZDoom engine -- Emawind's **QuestZDoom 17.3** (tag `qzd17.3`, gzdoom 9afc750, the
release the owner and his players run) -- built for Linux, on the OpenXR code path, with the
headset and both controllers posed from cvars. It renders the left eye to image files, so you can
SEE a held gun and its hands.

**The engine is always QuestZDoom 17.3, the commits in `PINS`.** The launcher (`engine/qz`, copied
to `bin/qz` and `build/rig/qz`) refuses to start any other engine and prints `qz: engine OK: ...` on
every launch.

**History of `bin/`.** The first prebuilt `bin/` (pushed c896330) was NOT 17.3: it was built from a
later, unreleased commit (4.15pre, ZScript 4.12), ran silently, and was removed on 2026-10-26
(32cc8df); results measured on it are void. The `bin/` here now (F12, 2026-10-26) is the correct
QuestZDoom 17.3 build, moved in from RS_ModelSwapper `gate/qz_rig/bin` (98ae205; the `qzdoom` binary
is byte-identical to a `setup.sh build` from `PINS` on this machine), with the Depot's own `engine/qz`
as its launcher. It reports `qz: engine OK: QuestZDoom qzd17.3 (9afc750...), engine 4.14.3, ZScript 4.14.2`.
On 2026-11-27 (PLAN R1) `bin/qzdoom` was rebuilt from the same `PINS` source and `s_sound_log.patch` with the R1 glue
(`qz_aimroll`, `qz_hz`, `rig_key`, `qz_state`; `engine/build.sh`, clang 18.1.3, `-j2`); the pk3s in `bin/` are unchanged
(same entries, same CRCs). With `qz_aimroll 0` it reads what the old `bin/qzdoom` read (roll 45 at pitch 30 ->
AttackRoll 38.12, AttackPitch 7.29 on both), and the 18 RSQ pk3s load with the same 81 warning lines.

## Start here (one command)
```
sh tools/rig/setup.sh                 # seconds: test packs + check that tools/rig/bin is 17.3
#   or: sh tools/rig/setup.sh build   # ~20-40 min: engine from PINS into build/rig/ (then B22_RIG=tools/rig/build/rig)
cd tools/rig
RSQ_GAMEDATA=<folder with doom2.wad, brutal22test6.pk3, BD_VoxelPack.pk3> \
  flock -o -x /home/claude/rig.lock python3 cmp2.py build/BD22Q_192.pk3 build/BD22Q_now.pk3 BrutalPistol,Plasma_Gun t1
#  -> build/shots/cmp2_t1.png : each gun held, 1.92 on the left, the depot's current set on the right
```
Gun names are BD22's classes (`BrutalPistol`, `Plasma_Gun`, ...). The example used to say
`Pistol,PlasmaGun`: that runs and writes the PNG, but no pistol is drawn and the PlasmaGun row shows
the start rifle (measured on a fresh clone, F12).
`setup.sh` zips `build/probe.pk3`, `build/upstream.pk3`,
`build/BD22Q_now.pk3` (the set under work, `$RSQ_SET` or `sets/bd22q`, built by its own `build.py`) and `build/BD22Q_192.pk3` (tag 1.92 of
RS_Brutal22WeaponsQ, the owner's baseline), then checks the rig is 17.3. Re-run it after changing
the set (it re-zips BD22Q_now). `rig.py` uses `B22_RIG` if set, else `bin/`, and stops with
a message if it has no engine. On a shared machine run one engine at a time: `flock -o -x` as above (`-o`: a child such as a stray Xvfb never inherits the lock).

## Posing the hands
- `qz_hmd "x y z pitch yaw roll"` places the head; `qz_rhand` / `qz_lhand` place the controllers
  (metres, degrees, stage space). `qz_rhand "0.0 1.68 -0.40 20 -70 0"` shows the held gun side-on
  in front of the eye; `"0.0 1.50 -0.30 30 0 0"` from behind.
- `rig.lpose(F, L, U)` / `engine/pose.py F L U`: an off-hand point given in the gun's frame (cm)
  -> the `qz_lhand` value. `handrot.py` has the rotation maths for the off hand.
- Frame dumps: `QZ_DUMP_EVERY=N QZ_DUMP_DIR=<dir>` with `QZ_RES=480`; `shots.shoot()` wraps it.
- Sound log: `QZ_SNDLOG=1` prints `QZSND <tic> <sound> ch vol src <class>` for every sound start.

## Input: hand roll, body turn, menus (PLAN R1, 2026-11-27)
Everything below is the glue (`engine/glue/qz_linux_glue.cpp`); the engine's own input code
(`VrInputDefault.cpp`, `hw_openxrdevice.cpp`, `menu.cpp`) runs unchanged. `python3 inputproof.py roll|turn|menu --run`
proves each on the engine (B22_RIG, B22_IWAD, B22_BUILD; `RIG_LOCK=<file>` for flock) and exits 1 on a failed check.

**The cvars.** Poses: `"x y z pitch yaw roll"`, metres and degrees, OpenXR stage space (+X right, +Y up, -Z forward).
`qz_rtrigger` `qz_rgrip` `qz_ltrigger` `qz_lgrip` 0..1 (over 0.5 = pressed). `qz_rstick` / `qz_lstick` `"x y"`, -1..1.
`qz_rbuttons` / `qz_lbuttons`: xrButton bits, held while set: A 1, B 2, X 256, Y 512, the menu button 1048576
(xrButton_Enter, either hand), stick click 2147483648 (xrButton_Joystick), thumbrest 16. What the engine makes of
them, right-handed (`VrInputDefault.cpp`): trigger -> `RTrigger` (fire); A -> `Pad_A` (use; Enter in a menu); B ->
`Pad_B` (Back in a menu); gun-hand grip -> `LTrigger` and the shift layer (`vr_secondary_button_mappings`, which also
stops turning); right stick y -> `MWheelUp/Down` and `Axis4Plus/Minus` (Up / Down in a menu); right stick x -> the
turn; left stick -> walking (`Axis1/2`); X -> `Pad_X`, Y -> `Pad_Y`; left trigger -> `LShift`; menu button -> `Escape`.
`vr_control_scheme 10` (left-handed): the left controller is the gun hand (its pose -> Attack*, its stick turns,
X / Y act as A / B). A cvar is a held button: set it, `wait 3`, set it back (the menu sees one press).

**Hand roll: `qz_aimroll 1`.** With `qz_aimroll 0` (the default, as before R1) a hand's angles are the raw controller's
and the engine then pitches that by `vr_weaponRotate` (-30) about the controller's own axis
(`TBXR_Common.cpp` `QuatToYawPitchRoll`, called from `VrInputDefault.cpp:160` and `:195`), so the roll is not kept:
roll 45 at pitch 30 reads `AttackRoll 38.12`, `AttackPitch 7.29`, `AttackAngle` 20.88 off. With `qz_aimroll 1` the
roll is put after that turn: `AttackRoll` / `OffhandRoll` read the roll you set exactly, and pitch / yaw read as with
roll 0 (`AttackPitch = pitch - 30`, `AttackAngle = view - 90 + yaw`: hand pitch 60 reads `AttackPitch 30`).
Measured on both hands, rolls 0 / 30 / 45 / 90 / -60 / 135 / -170 and one pitched and yawed pose, right- and
left-handed: 16 of 16 exact (`inputproof.py roll`). Roll 0 gives the same pose in both modes, so every roll-0 pose
and result is unchanged. `handrot.py` (and `brk.py`, `m203.py`, `pump.py`, `msload.py` through it) models mode 0:
keep `qz_aimroll 0` for them. Positive roll turns the gun clockwise as the player sees it (frame looked at).

**Body turn: the engine's own.** Nothing to add: the right stick's x is the engine's turn (`VrInputDefault.cpp:263-303`,
`snapTurn` -> `VR_GetMove` yaw -> `updateHmdPose` -> `G_AddViewAngle`). `vr_snapTurn` over 10 = a snap of that many
degrees per flick: x past 0.6 turns once, the stick must come back under 0.4 before the next (holding it turns once);
x 1 turns right (angle down), -1 left. `vr_snapTurn` 10 or less = smooth: `vr_snapTurn * nonLinearFilter(x)` degrees
EVERY RENDER FRAME (deadzone 0.1, power 2.2: x 1 -> 1.0, x 0.6 -> 0.274). Measured: snaps of 45 / 30 / 90 exact both
ways, x 0.65 turns, 0.55 does not, gun-hand grip held does not, left-handed turns from `qz_lstick`; `qz_hmd` yaw 90
turns the player 90. Smooth at `vr_snapTurn 5`: 4.999 and 1.373 degrees a frame for x 1 and -0.6.
**`qz_hz <n>`** (env `QZ_HZ`) holds the render loop to n frames a second, as the headset's display rate does: with
`qz_hz 72` a full stick turns 360 degrees in 35 tics, as a Quest at 72 Hz; unpaced the rig ran 120-260 frames a
second at `QZ_RES 200` (load decides), so smooth turn is that much faster. `qz_hz` only slows: a rig slower than n
(big `QZ_RES`, frame dumps) stays slower.

**Menus: the controller, or `rig_key`.** The fake buttons reach menus exactly as a Quest's do (they always did): the
menu button opens the main menu, the right stick moves, A selects, B backs out; a mod's menu answers inside menu
code (`DMenu::CallMenuEvent` raises `DMenu::InMenu`), so `KeyBindings.SetBind` on Yes works and `bind k` shows it.
**`rig_key <keyname> [down|up|tap]`** (tap by default) posts one `EV_KeyDown` / `EV_KeyUp` through `D_PostEvent`, the
call a controller button makes: key names as `bind` takes them (`Pad_A`, `Pad_B`, `Axis4Plus`, `Axis4Minus`, `Escape`,
`RTrigger`, `K`, `#37`). It goes console -> menu -> bindings like any key: `rig_key Pad_A` in a menu is Enter,
`rig_key K` in the game runs K's binding. **A Quest stick in a yes/no box closes it unanswered:** a stick move sends
`MWheelDown` with `Axis4Minus`, and `MessageBoxMenu.OnInputEvent` closes on any raw key down (measured: the box shut,
the option menu under it moved a row). On a Quest a yes/no is answered with A (Yes is preselected) or B. `rig_key
Axis4Minus` sends the one key and moves the selection, which a Quest cannot: use `qz_rstick` to test what a player
gets, `rig_key` to reach a row. `probe_input/` (`setup.sh` zips it to `build/probe_input.pk3`): `netevent rp_pose`
(one `RP` line: player angle, every hand field), `netevent rp_every N`, an `RPM` line on every menu / row change, and
`openmenu RigProbeMenu` (an option row, and a yes/no whose Yes calls `KeyBindings.SetBind(K, "echo RIGPROBE_BOUND")`).
**`qz_state`** prints what the engine read: render frame count, menu / game state, head angles, `snapTurn`, `doomYaw`,
the weapon and off-hand angles, `vr_control_scheme`, `vr_snapTurn`, `qz_aimroll`, `qz_hz`.

**Still not possible.** Keyboard text (`EV_GUI_KeyDown` / `EV_GUI_Char`): no text entry or y/n letters (a Quest has
none either). The laser pointer / mouse in menus. A netevent runs a tic or two after it is sent: pose, wait 2+ tics,
then read. `wait` inside an alias still does not fire. The engine saves `vr_control_scheme` / `vr_snapTurn` to the ini
on exit: set them back, or run in a copy of the rig (`inputproof.py` does).

## What is here
| file | what |
|---|---|
| `PINS` | the one engine allowed: QuestZDoom 17.3 commits and the versions a correct build reports |
| `bin/` | the prebuilt QuestZDoom 17.3 rig (engine, its pk3s, libzmusic, test ini, `qz` launcher with the guard). `bin/saves/` and `bin/libGLESv3.so` are made at run time (gitignored) |
| `setup.sh` | the one command above; checks the rig is 17.3, or builds from `PINS` (`build`) |
| `engine/` | the rig build: `build.sh` + `Makefile`, `glue/qz_linux_glue.cpp` (OpenXR stand-in, poses from cvars, the qzt_* test-driver hook, frame dump; `qz_aimroll`, `qz_hz`, `rig_key`, `qz_state` since R1), `shim/` (NDK/JNI header stand-ins), `config/qzdoom.ini` (test ini), `pose.py`, `qz` (launcher with the version guard) |
| `s_sound_log.patch` | test-only `QZ_SNDLOG` in the engine's StartSound |
| `rig.py` | `run(name, script, secs, extra)`: one engine run on the load order + probe; logs to `build/logs/`. Env: `B22_PK3`, `B22_RIG`, `B22_NOPROBE`, `QZ_RES` |
| `shots.py`, `cmp.py`, `cmp2.py` | frame dumps; `cmp2.py <pkA> <pkB> <Gun,...> <tag> [pose]` = A left, B right |
| `mags.py` | magazine reloads driven by the off hand (`with_pouch` for wells near the rest pose) |
| `pump.py`, `brk.py`, `m203.py`, `grip.py` | pump, break-open, M203 and grip-mode drivers |
| `spintest.py` | walk / fire / reload, logs psp.x/psp.y and flash count |
| `holdtest3.py` | trigger held 140 tics per gun, QZD as is vs upstream attackdown (`build/upstream.pk3`) |
| `probe/` | the `B22 ...` log lines (reload tables, state, shots, psp, casings, axe lock) |
| `probe_input/` | `RP` / `RPM` lines (player angle, hand fields, menu rows) and `RigProbeMenu` with a yes/no that binds K on Yes (R1) |
| `inputproof.py` | `roll` / `turn` / `menu` `[--run]`: the input proofs above, checked (R1) |

Load order is always doom2 -> brutal22test6 -> BD_VoxelPack -> pack (CLAUDE.md). The full how-to is docs/handbook/02_test_rig.md.
BD_VoxelPack prints four `voxeldef.txt` script errors on its own; they are not ours.

## Traps (each cost a run)
- `-warp 1` is required: BD22's title map swallows `+map` and its AimingCamera stops VR attaching.
  `QZ_RES=200` for speed, 480 for pictures.
- `playerclass=$TAGBD_CLASS_RIFLE` (in the ini), or you get a random class (Purist has no reload).
- `rsq_extra_weapons 1` for the hidden guns. `give <class>` explicitly; `give all` gives Purist guns.
- The off hand is the gun hand mirrored in L; side wells need a 180 degree yaw (`mags.at`).
- `CanTakeMag` refuses a hand within 20 cm of the magazine (`POUCH_MIN`): reach to a pouch first.
- Give a gun ~150 tics to finish its select animation before testing it.
- `wait` inside an alias does not fire; runs end by `timeout`.
- The engine's `screenshot` command returns garbage in VR mode; use the frame dump.
- `B22_NOPROBE=1` for old packs whose class names the probe does not know.
- The engine rewrites `bin/config/qzdoom.ini` (tracked) on exit -- on the F12 runs only its first,
  timestamp line. `git checkout tools/rig/bin/config/qzdoom.ini` before committing.
- Never chain pipeline stages with `;` after a failing stage. Use `set -o pipefail` and `&&`.
