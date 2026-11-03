# TestRig — the Windows headless VR rig (never ships)

The owner's desktop QuestZDoom 17.3 build (`E:\DOOMWork\QZD17-engine`, the OpenVR path he plays with SteamVR)
with its OpenVR runtime **faked**: the headset and both controllers are posed from console cvars, so a saber can be
held across a shot, a shield raised, a whip arm swung, with no headset and no SteamVR. The Windows twin of the
Linux rig in RSQ_WeaponDepot `tools/rig` (which fakes the OpenXR layer), with the same cvar names.

Built and proven 2026-11-03: the right hand's position and angles, the left hand's, the head's yaw and the trigger
all reach the player's fields every series mod reads (`AttackPos` / `AttackAngle` / `AttackPitch` / `AttackRoll`,
`OffhandPos` / …, `OverrideAttackPosDir` 1) — `TestRig/probe` prints them.

## What is here

| File | What |
|---|---|
| `engine.patch` | The engine change: `src/rendering/gl/stereo3d/gl_openvr_fake.cpp` + `.h` (new: the fake OpenVR function tables, answering from cvars), a few lines in `gl_openvr.cpp` (take the fake tables when `-qzfake`, skip the compositor submit and the runtime shutdown), one line in `src/CMakeLists.txt`. `git apply TestRig/engine.patch` in the engine tree, then build. Default off: without `-qzfake` the engine is exactly as before. |
| `probe/` + `probe.pk3` | `RSQPoseProbe`: `netevent rig_pose` prints the player's hand fields; `netevent rig_pose_every N` prints every N tics. |
| `pose.py` | Turns "a hand F cm forward, L left, U up of the eye" into a `qz_rhand` string. |
| `saberprobe/` + `.pk3` | `netevent sbt_arm` (the saber in hand), `netevent sbt_ball D Z` (an imp fireball at the player); logs its flight. |
| `meleeprobe/` + `.pk3` | `netevent mhp_arm` (Melee's glove in hand), `netevent mhp_shot` (an imp fires one hitscan at the player two tics later), `netevent mhp_fly` (a missile of class `mhp_class` at the player); logs who got hurt. Swing the hand across the line with `qz_rhand` poses one tic apart (0.1 m a tic = 3.5 m/s). Proved Melee's bullet Hadouken 2026-11-03, and a BD22 tracer at 140 u/tic. |
| `geoprobe/` + `.pk3` | `netevent geo_here` (your sector), `netevent geo_scan STEP` / `geo_scan_at X Y STEP`: a 9 x 9 grid of floor heights, to find a lip or a corner in a map without a map viewer. |
| `maps/make_rig01.py` → `maps/rig01.wad` | **The rig's own arena:** a 1024 x 1024 room, floor 0, ceiling 256; the east half a raised block (floor 120) with a true two-sided step face at x = 0; a free-standing 80 x 64 pillar at x −176..−96, y 220..284. Player start (−320, 0) facing east. Load it with `-Files maps/rig01.wad,<mod>.pk3,...`. Proved the Grapple's mantle and corner wrap 2026-11-03. The generator says why the winding matters (a line's front is its right-hand side: the room boundary runs clockwise, a pillar counter-clockwise). |
| `../tools/qzd_hidden_run.ps1 -Pose` | The hidden runner with the rig on: `vr_mode 10`, `-qzfake`, `vr_joy_mode 0`. |

## Build the engine with it

```
cd E:\DOOMWork\QZD17-engine
git apply E:\DOOMWork\RSQ_UBQSeries\TestRig\engine.patch
"C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" --build build --config Release --target zdoom
```
(Visual Studio 18 2026, incremental: two files and a link. The patch is against the tree as of 2026-11-03; it is
already applied in the owner's engine folder, so `git apply` there says "already exists" — that is fine.)

## Run

```
powershell -File tools\qzd_hidden_run.ps1 -Pose -Files <pk3s>,TestRig\probe.pk3 -Map MAP01 -WaitTics 40 `
    -Commands "netevent rig_pose,qz_rhand 0.40:1.50:-0.50:60:45:0,wait 5,netevent rig_pose" -Tag mytest
```
The log (its path is printed) has `qz_fake: OpenVR runtime faked` near the top (the runner warns if it is missing)
and the probe's `POSE` lines. Set a pose, `wait` at least 2 tics, then read: poses are taken each render frame.

## The cvars

| cvar | default | what |
|---|---|---|
| `qz_hmd "x y z pitch yaw roll"` | `0 1.6 0 0 0 0` | the head: stage space, metres and degrees |
| `qz_rhand` / `qz_lhand` | `0.25 1.3 -0.3 60 0 0` / `-0.25 1.3 -0.3 60 0 0` | the controllers |
| `qz_rtrigger` `qz_rgrip` `qz_ltrigger` `qz_lgrip` | 0 | 0..1; over 0.5 is pressed (the OpenVR trigger / grip buttons too) |
| `qz_rbuttons` / `qz_lbuttons` | 0 | extra raw OpenVR button bits: A = 1<<7, ApplicationMenu (B) = 1<<1, stick click = 1<<32 |
| `qz_rstick` / `qz_lstick "x y"` | `0 0` | the thumbsticks |
| `qz_fov` / `qz_ipd` | 90 / 0.064 | the fake eyes |
| `qz_fake_log` | 0 | 1: print every haptic pulse the game asks for |
| `qz_fake_state` (command) | | prints whether the fake is on and every pose |

**Stage space is OpenVR's:** +X right, +Y up, −Z forward, metres. Pitch about +X (positive = up), yaw about +Y
(positive = left), roll about −Z. **Numbers may be split by colons** (`0.25:1.3:-0.3:60:0:0`) — a value with spaces
cannot pass through the runner's quoting.

**Level aim is pitch 60** on this path: `AttackPitch = raw − 60` (measured 2026-11-03: raw 0 → −60, 60 → 0, 89 →
29, 120 → 60; the Linux OpenXR glue's +30 does not carry over). **Keep a hand's raw pitch inside −29 … 149:** at
exactly ±90 of aim the engine's matrix→Euler decode (`gl_openvr.cpp eulerAnglesFromQuat`, an `asin`) goes NaN and
every hand field with it (`AttackPos NaN`, and a loaded saber aborts the VM with "division by zero"); past that it
wraps with yaw and roll at 180. A blade straight up is raw −29 (aim −89); straight down is raw 149. Yaw 45 reads as
`AttackAngle` +45 of the view. A head yaw of 90 turns the player 90 and the hands stay where they are in the room, as
a real headset would.

## First result: the saber blocks (2026-11-03)

`saberprobe/` (+ `saberprobe.pk3`): `netevent sbt_arm` gives and raises the saber, `netevent sbt_ball D Z` fires an
imp fireball at the player from D units at height Z and logs its flight every tic. With the blade held level across
the body at the ball's height (`qz_rhand 0.3:1.0:-0.4:60:90:0`, `ubqs_diag 3`):

```
SBX_DEFLECT t127 in-player-tick DoomImpBall ... near 4.17 need 7.50 -> DEFLECTED
SBT t128 ball 42.0 in front, z 34.7, target DoomPlayer -> going away
```
The sweep turned it 30 units out, the ball became the player's and flew back at x1.2; no hurt line. (The saber's
own frame reads `AttackPitch −89` as a blade pointing down-forward and raw 149 as back over the shoulder: pose a
blade across with yaw, or measure the tip in the SBX line first.) This is how the README limit "a blocked shot can
carry on up to one tic past you" was retired.

The packed `.pk3`s are not in git (the repo ignores pk3s outside `pk3/`): pack a probe from its folder before a run,
e.g. `python -c "import zipfile; z=zipfile.ZipFile('TestRig/saberprobe.pk3','w',8); [z.write('TestRig/saberprobe/'+f,f) for f in ('zscript.txt','MAPINFO.txt')]; z.close()"`
(the same for `probe/` and `meleeprobe/`).

## What it proves and what it cannot

The series' hand-reading code runs against posed hands on the real 17.3 engine: blade sweeps, shield plates, whip
arms, grips in holsters, gestures. It renders to the hidden window (`vr_desktop_view 0` is the left eye; the engine's
`screenshot` command captures it). It cannot tell you how anything feels, or what a Quest's own tracking does.

## Grapple results (2026-11-03, on rig01.wad)

- **Mantle:** hook the step face (`qz_rhand 0.2:1.5:-0.3:70:0:0`, `netevent rsqgr_fire 0`), the pull hangs you at it
  (`arrive 32.0 from the claw, hangs` at z 48), the left stick forward (`qz_lstick 0:1`) → `mantle: a lip 71 up, hop
  12.6` → `mantled onto the ledge at 120`.
- **Rope wraps corners:** `rsqgr_swing 1`, hook the north wall over the pillar (`72.5:72.6:0`), release the press
  (`netevent rsqgr_up 0`), walk east behind the pillar → `rope wraps a corner (1), 312 taken up`; walk back west →
  `rope straightens off a corner (0 left), 312 let back out`.
- The hook's own log is `rsqgr_debug 1` (`T_GR` lines). A fire press that is still held when the hook latches REELS
  (swing mode): release it with `netevent rsqgr_up 0` before walking.

## Traps

- **The runner's config keeps cvars between runs** (`%TEMP%\qzd_hidden_run\qzd_hidden_rsq.ini`): a `rsqgr_swing 1` set
  in one test is still on in the next. Set every mode a test depends on in its own `-Commands`.
- `vr_joy_mode` must be 0 (the runner sets it): the mode caches it in a `static` on its first frame and only mode 0
  recomputes the hands' offsets every frame (`HandleControllerState`).
- The left stick (`qz_lstick`) is movement; the right stick is the engine's weapon/turn stick. With the player facing
  east (rig01) `qz_lstick 0:1` walks east. `qz_rhand` yaw is relative to the view: yaw −90 fires east when facing north.
- Render models never load (`LoadRenderModel_Async` says not supported), so no controller model is drawn: expected.
- A new runtime call the mode makes that the fake does not fill is a null function pointer: a crash at once, by
  design, so it is found rather than silently wrong. Add the member in `gl_openvr_fake.cpp`.
