# 2. The test rig

## 2.1 What it is

The rig is the real QuestZDoom 17.3 engine, built for Linux x86_64 from the exact commits in
`tools/rig/PINS`, running its **OpenXR code path**. Only the OpenXR / Android layer is replaced:
`tools/rig/engine/glue/qz_linux_glue.cpp` stands in for the headset, takes the head and both controllers
from console variables, renders with software GL (no window: EGL surfaceless), and can write the left eye
to image files. So a held gun, its hands, a reload and a scope picture can be **seen** and **logged**
without a headset.

It never ships and it is not a headset test. Whatever it shows is "rig only, not headset-confirmed".

What is in `tools/rig/`:

| file | what |
|---|---|
| `PINS` | the one engine allowed: QuestZDoom 17.3 (gzdoom 9afc750, questzdoom a85c819) and the versions it reports (engine 4.14.3, ZScript 4.14.2) |
| `bin/` | the prebuilt rig: `qzdoom`, its pk3s, `libzmusic`, a test ini, and `qz` (the launcher with the version guard) |
| `setup.sh` | one command: test packs + the engine check; `setup.sh build` rebuilds the engine from PINS |
| `engine/` | the rig build: `build.sh`, `Makefile`, `glue/qz_linux_glue.cpp`, `shim/`, `config/qzdoom.ini`, `qz` |
| `rig.py` | `run(name, script, secs, extra)`: one engine run on the owner's load order plus the probe; the log |
| `shots.py`, `cmp.py`, `cmp2.py` | frame dumps; `cmp2.py` = pack A and pack B side by side, one gun per row |
| `mags.py`, `brk.py`, `pump.py`, `m203.py`, `grip.py` | off-hand drivers for magazine, break-open, pump, M203 and grip-mode reloads |
| `spintest.py`, `holdtest3.py` | psprite drift and held-trigger fire-rate tests |
| `probe/` | a test-only ZScript pack that prints `B22 ...` lines: reload tables, state, shots, psprite offsets |

## 2.2 Setup from a fresh clone

Needs: Linux x86_64, `git`, `zip`, `unzip`, `python3` with Pillow (numpy and scipy for the hand tools), and a
GLES 2 library (Mesa: `libGLESv2.so.2`; `bin/qz` links it as `libGLESv3.so` on first run). Network access to
GitHub for the 1.92 baseline.

```sh
git clone https://github.com/presidentkoopa/RSQ_WeaponDepot.git rsq_weapondepot
cd rsq_weapondepot
sh tools/install_hooks.sh          # the no-drift commit hooks
sh tools/rig/setup.sh              # about a minute
```

Good output ends with:

```
rig ready: <clone>/tools/rig/bin/qz ( QuestZDoom qzd17.3 (9afc750917bf54870f2d16b7ba0d00f2b77e6fb5), engine 4.14.3, ZScript 4.14.2)
```

What `setup.sh` made, all under `tools/rig/build/` (gitignored):
- `BD22Q_now.pk3`: the set under work, `$RSQ_SET` (default `sets/bd22q`), built by **its own** `build.py`
  (BD22's build compresses `.md3` with LZMA and moves the FBX hand blocks to model slot 7; a plain zip of
  `src/` is not the same pack). Re-run `setup.sh` after you change the set.
- `BD22Q_192.pk3` and `src/bd22q_192/src/`: tag 1.92 of RS_Brutal22WeaponsQ, the reference holds. The hand
  tools read the extracted copy (`RSQ_GUNPACK`).
- `probe.pk3`, `upstream.pk3`: test-only packs.
- `logs/engine_check.txt`: the version guard's answer.

To build the engine yourself instead of using `bin/` (20-40 minutes, needs cmake, a C++ compiler and the SDL2 /
EGL / GLES / OpenAL / libvpx headers): `sh tools/rig/setup.sh build`, then `export B22_RIG=$PWD/tools/rig/build/rig`.

## 2.3 Game data

The owner's files are never committed. Put `doom2.wad`, `brutal22test6.pk3` and `BD_VoxelPack.pk3` in one
folder and point `RSQ_GAMEDATA` at it (default: a folder called `gamedata` beside the Depot checkout).
`B22_IWAD`, `B22_BD22`, `B22_VOX` override the three files one by one. **Use Doom 2, not Freedoom**: the
voxel pack names Doom 2's own sprites.

## 2.4 Running a pack on the owner's load order

Every engine run loads doom2 -> brutal22test6 -> BD_VoxelPack -> the pack (-> the probe). One run, from
`tools/rig`:

```sh
cd tools/rig
RSQ_GAMEDATA=/path/to/gamedata flock -o -x /home/claude/rig.lock \
  python3 rig.py boot 'wait 100; quit' 150
```

- Argument 1 is the run's name (the log is `build/logs/<name>.log` plus `<name>.log.out`), 2 is one console
  script, 3 is a timeout in seconds. `B22_PK3=<pk3>` picks the pack (default `build/BD22Q_now.pk3`).
  `B22_NOPROBE=1` leaves the probe out (for old packs whose classes it does not know).
- `rig.py` adds `-warp 1 -skill 3 -nosound +logfile` itself (`-warp 1` is required: BD22's title map swallows
  `+map`, and its camera stops VR attaching).
- The script is GZDoom console commands chained with `;`. `wait N` waits N tics (35 a second). `give`,
  `use`, `+attack` / `-attack`, `+reload`, `+altattack` are what key binds send. **End with `quit`.**
- Before and after the run it prints two lines about the pack's cvars:
  `INI CVARS ... FEATURES SAVED OFF: none; not at default: ...` and `RIG CVARS ...`. Read them. A saved ini
  value hides a new default silently (chapter 6, first trap).

**The check that matters:** no `Script error` from the pack.

```sh
grep -hE "Script error|VM execution aborted|Too many|exception" build/logs/boot.log | sort | uniq -c
```

A clean BD22 boot shows only BD_VoxelPack's own four (`voxeldef.txt` lines 66, 72, 77 and 892) and BD22's
own `Unknown class name 'DeathSphereHealth'` warning. Also check that the pack was loaded at all
(`adding .../BD22Q_now.pk3, N lumps`) and that the map started (`MAP01 - Entryway`): a pack that is not found
gives a perfectly clean log.

`python3 rig.py --cvars <pk3> <ini>` checks any ini (the owner's too) for pack cvars saved away from their
defaults, without a run.

## 2.5 Posing the head and hands

The glue reads these cvars every frame (stage space: metres, x right, y up, z back; then pitch, yaw, roll in
degrees):

| cvar | default | what |
|---|---|---|
| `qz_hmd "x y z p y r"` | `0 1.6 0 0 0 0` | the head |
| `qz_rhand "..."` | `0.25 1.3 -0.3 30 0 0` | the right (gun) controller; pitch 30 is level once `vr_weaponRotate -30` applies |
| `qz_lhand "..."` | `-0.25 1.3 -0.3 30 0 0` | the left (off) controller |
| `qz_rtrigger`, `qz_rgrip`, `qz_ltrigger`, `qz_lgrip` | 0 | 0..1, above 0.5 is pressed |
| `qz_rbuttons`, `qz_lbuttons` | 0 | raw button bits (A=1 B=2 X=0x100 Y=0x200 ...) |
| `qz_rstick`, `qz_lstick` | `0 0` | thumbsticks. **`+forward` does nothing in VR mode: walk with `qz_lstick "0 1"`** |

Set them inside the console script (`qz_lhand "-0.1 1.3 -0.5 30 0 0"; wait 10; qz_lgrip 1`) or as env vars
`QZ_HMD`, `QZ_RHAND`, `QZ_LHAND` for the start pose. A test pack can drive the hands per tic from ZScript by
setting `qzt_lhand`, `qzt_rhand`, `qzt_ltrigger`, ... (a non-empty value replaces the `qz_` one); the melee
tests use this for swings.

Handy poses: `qz_rhand "0.0 1.68 -0.40 20 -70 0"` shows the held gun side-on in front of the eye;
`"0.0 1.50 -0.30 30 0 0"` from behind. `rig.lpose(F, L, U)` turns a point in the gun's frame (cm) into the
`qz_lhand` value that puts the off controller there, oriented like the gun hand. Remember the off hand is
mirrored (chapter 1.5).

## 2.6 Frames: dump, convert, delete

```sh
QZ_RES=480 QZ_DUMP_EVERY=2 QZ_DUMP_DIR=/some/dir B22_PK3=... python3 rig.py shot 'wait 100; ...; quit' 300
```

writes `f00000.ppm` ... every N rendered frames of the left eye. `QZ_RES=200` is the default (fast); 480 for
pictures you look at, 960 for the scope. `shots.shoot(tag, pk3, body)` wraps this. **Convert the frames you
keep to PNG and delete the `.ppm` files at once**: an unthrottled dump filled the shared disk twice.
`cmp2.py` does it for you:

```sh
cd tools/rig
RSQ_GAMEDATA=/path/to/gamedata flock -o -x /home/claude/rig.lock \
  python3 cmp2.py build/BD22Q_192.pk3 build/BD22Q_now.pk3 BrutalPistol,Rifle t1
# -> build/shots/cmp2_t1.png: each gun held, 1.92 on the left, the set under work on the right
```

Gun names are the mod's class names (`BrutalPistol`, `Plasma_Gun`), not display names: a wrong name still
writes a PNG, holding the start rifle. The engine's own `screenshot` command returns garbage in VR mode;
use the dump.

For one gun from the eye and the side, at rest, steadied and firing, beside its 1.92 render, use
`tools/handfit/port/gate_gun.py sheet` and `compose` (chapter 3).

## 2.7 Logs

- `build/logs/<name>.log`: the engine's `+logfile`. A fatal script error reaches only this file, not the
  redirected output: always read it.
- `<name>.log.out`: stdout and stderr (the launcher's `qz: engine OK` line is here).
- The probe prints `B22 GUN` (the pack's reload table per gun), `B22 S` (what each hand holds), `B22 T`
  (reload phases), `B22 SHOT`, `B22 PSP` and more. The drivers read them: `mags.py` takes every magazine's
  geometry from `B22 GUN` lines in `logs/boot.log`, so nothing is typed in. Boot the pack first.
- `QZ_SNDLOG=1` prints `QZSND <tic> <sound> ...` for every sound started (the prebuilt engine has it).
- To prove a code path ran, add a `Console.Printf("MYTAG ...")` in a throwaway build, run, grep, then delete
  it. A clean compile is exactly what dead code looks like.

## 2.8 One engine at a time: the lock

The machine is shared and small. Every engine run takes the rig lock, exclusively:

```sh
flock -o -x /home/claude/rig.lock <command>
```

- `-x`: one engine at a time. Two engines at once on 2 cores time out, get killed for memory, and turn
  held-gesture tests into false failures.
- `-o`: the lock is not passed to child processes. Without it an orphaned Xvfb once inherited the lock,
  held it after its parent died and stalled every run for 20 minutes.
- The path is a convention of this machine; the tools read it from `RSQ_RIGLOCK` (default: `rig.lock`
  beside the Depot checkout). `gate_gun.py` and `tools/int20_rig/run.sh` take the same lock themselves, so do
  not wrap them in another `flock`.

## 2.9 Resources

- The cloud box has **2 cores and 8 GB**. An engine run uses 250-800 MB. Run one engine at a time and at
  most one heavy job (a hand fit) beside it. More lanes made everything slower and got fits killed.
- Timing-sensitive tests (flicks, held gestures) give false failures when the load average is above about
  2 (the M79 failed 3 of 3 at 2.5 and passed at 1.35). Check `uptime` first; re-run before believing a fail.
- Disk: frame dumps are big. Delete `.ppm` as soon as the PNG exists; keep run output in `work/` (gitignored).

## 2.10 The ini

The engine rewrites `tools/rig/bin/config/qzdoom.ini` (tracked) when it exits. Before committing:

```sh
git checkout tools/rig/bin/config/qzdoom.ini
```

`gate_gun.py` restores it after every run. `tools/int20_rig/run.sh` never touches it: it runs on a private
copy of the rig in `work/int20_rig/bin` and copies the **fresh default ini** `tools/int20_rig/ini.f20` in
before every run (written by the engine itself on a boot with no ini, with only `playerclass` set to Rifle
Start, as New Game would). Use that for anything about defaults.

The ini must hold `playerclass=$TAGBD_CLASS_RIFLE` for BD22: with the engine's default every run is a
random class, Purist included (Purist has no reloading), and the sweep's Brutal guns come up as Purist guns.
Hidden guns (MP40, MG42, ...) need `rsq_extra_weapons 1` before `give`, and `give all` gives Purist guns:
give each class by name.

## 2.11 The version guard

`bin/qz` refuses to start an engine that does not report what `PINS` says, and prints
`qz: engine OK: QuestZDoom qzd17.3 (9afc750...)` on every launch. A rig from a later, unreleased commit once ran
silently for a day (4.15pre, ZScript 4.12) and every result from it had to be thrown away. If you see anything
but `engine OK`, stop.
