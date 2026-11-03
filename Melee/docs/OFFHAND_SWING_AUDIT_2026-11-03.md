# Off-hand swing audit (2026-11-03)

Owner's report (11:15): "I feel like I have to slash 2-4x as hard with my offhand to make a connect with the axe. I want
this investigated and I want to know if it plagues our entire melee system."

Investigation only. Nothing in any repo was changed or committed. The one fix tested below was a throwaway copy of the
BD22 VR pk3 in the scratchpad. It is not in any repo.

## For the owner, in plain words

**What causes it.** It is not how hard you swing. Both hands' swing speed is read the same way, at the same moment,
against the same threshold. Your off hand also gets a full-speed reading on the rig: about 7 m/s on the same chop as
the main hand. The problem is which way the code thinks the off-hand axe's blade is facing. It has the blade upside
down.

The engine draws the left-hand weapon as a mirror image. BD22 VR's hand tracker
(`rs_brutal22weaponsq/src/zscript/rsq/pose.zs`) takes that mirrored "left" direction for the off hand and then works
out "up" from it. The result is an "up" pointing down. Because of that, the axe code places the off-hand axe's blade
about 44 cm on the wrong side of your wrist. It also believes the cutting edge faces where the back of the axe head
(the spine) actually is.

The axe only cuts when the edge leads the swing, a rule you asked for on 10-13. So with the off hand:
- a normal chop, a downward drop, a wrist snap or a lunging chop **never** cut on the rig, at any speed tried (up to
  about 30 m/s at the blade, 7x the threshold);
- a cut only happens when the motion happens to line up with the spine: a side slash with the wrist turned the
  "wrong" way, or a forward stab with the hand pointing down.

That is why it feels like you have to swing 2-4x harder. Swinging harder doesn't help. It only lands when a wild,
hard swing happens to point the spine forward for a tic.

**Does it affect all melee?** No. Only one system has it: **BD22 VR Reloaded's off-hand axe**, both its slash and its
throw. All the other melee code reads the hands by position, or by the hand's yaw and pitch only. Measured on the
rig: the RSQ Melee glove punch connects at the same speed with either hand (2.19 m/s, the 2.0 m/s threshold). The
main-hand axe connects at 4.5 m/s. The table below covers every system.

**Proposed fix (one line, BD22 VR repo, needs your yes).** In `src/zscript/rsvr/melee.zs` `RSVR_Hand.Frame()`, line
766: `fU = ph.U;` becomes `fU = off ? -ph.U : ph.U;`. With that line in a test copy on the rig, the off-hand axe
behaved like the main hand on every swing type. It cut on the same swings and at the same minimum speed (about 4.5
m/s at the blade), and it missed on the same spine-first swings that the main hand misses. **Rig only, not
headset-confirmed.**

## Details

### 1. The axe and how a swing connects (BD22 VR Reloaded 2.0.3p)

The axe swing, the off-hand axe and the throw are all in `rs_brutal22weaponsq/src/zscript/rsvr/melee.zs`. The pk3
`pk3/03_BD22_VR-Reloaded_2.0.3p.pk3` holds the same files: `melee.zs`, `pose.zs` and `vrhand.zs` are byte-identical.

- **Which hand is read:** each hand has its own `RSVR_Hand` (`hands[]` and `offHands[]`, melee.zs:25-26, ticked at
  122/128). `KindOfOff` (665) gives only the off-hand axe (`RSQ_Off_BrutalAxe`) a blade. The pose comes from the
  synced history `RSQ_PoseHandler.Of(mo, off ? OFF : MAIN)` (`Frame()`, 755-776). That history is filled once a tic
  from `AttackPos`/`OffhandPos` plus `HandDir`/`OffDir(yaw 0)` and `OffDir(yaw 90)` (pose.zs:289-292, packed by
  `Send`, 301).
- **The blade point:** `Place()` (781-807) puts the model's `BladeIn` (top of the head) and `BladeOut` (the edge)
  into the world. It uses the hand frame `fF`/`fR`/`fU`, `vr_weaponScale`, `vr_3dweaponOffset*`, the r12 move
  `RSVR_MeleeMove.Apply` (axe: +13 cm forward, +4.6 cm up) and `pixelstretch` on z.
- **Speed and sampling:** a one-sample delta of the edge point in the body's own frame (`BodyFrame`, 1356). It is
  divided by the gap between the stamps (`gap = max(1, pStamp - prevStamp)`), with no smoothing (936-942). Units are
  map units a tic.
- **Threshold:** `thr = AXE_SWING 3.0 m/s * vu/35 * rsvr_melee_swing * 1.5` (922-925): **4.5 m/s at the edge point**,
  the same for both hands. `vr_vunits_per_meter` (default 34) is read in `Frame()`.
- **Gates (959-975):** `rise > 0.15` counts as a wind-up. **Edge leading:** `cos(motion, BladeOut - BladeIn) >=
  rsvr_axe_edge 0.5`, a test from r6 (owner item 9).
- **Hit test:** `Sweep()` moves the head-to-edge segment, extended 1.33x from the hand (`AXE_RANGE`, 1052), against
  the body cylinders, with a 3-unit pad and a line-of-sight check from the hand.

### 2. Off-hand-only causes checked

| Suspect | Finding |
|---|---|
| Off pose written a tic late, or interpolated differently (QZD 17.3) | No. Both hands are written in the same function, one after the other, from the same input frame. OpenXR: `hw_openxrdevice.cpp:589-610` (offsets from `VrInputDefault.cpp:146-191`, same code for each hand). PCVR/SteamVR (the owner's `vr_mode 10`): `gl_openvr.cpp:2525-2550`, both from `GetWeaponTransform`. Neither hand is smoothed. |
| Velocity from a stale sample | No. Both hands go through the same per-tic netevent, stamps and `Fresh()` (pose.zs). Rig: identical per-tic speeds for mirrored swings (chop over 6 tics: main 6.60-7.04 m/s, off 5.51-6.96 m/s). |
| OffhandPos is a weapon offset point, not the hand | No. Both positions are the controller origin, built the same way (translation column of the hand matrix). |
| Threshold in the main hand's frame / main hand's history | No. `thr` has no hand term. `offHands[]` has its own history and its own `prevRel`. |
| Psprite / ready pose | The off axe's Ready is `AXEG A` (Axe.dec:458-461), which `ReadyPose` accepts on `PSP_OFFHANDWEAPON`. |
| Left-handed schemes | Both packing and engine swap via `vr_control_scheme`. Not a second fault. The mirrored hand is still the off hand. |
| **Mirrored frame** | **Yes: this is the cause.** See below. |

**The cause, with evidence.** The engine mirrors the left-hand weapon: `VRMode::GetWeaponTransform` does
`out->scale(-1, 1, 1)` for the left controller (`hw_vrmodes.cpp:469`). `OffhandDir` uses that matrix
(`MapWeaponDir`, 409-411), so `OffDir(mo, 90, 0)` returns the controller's **right**. `vrhand.zs` already notes
this mirroring. `RSQ_PoseNet.RollOf` (pose.zs:208) packs a roll that reproduces that mirrored left. `RSQ_Pose.Push`
(pose.zs:54-77) then rebuilds U as `F x L`, which for a mirrored L gives **U = -up**. Logged on the rig with both
controllers held level (`qz_rhand 0.25 1.3 -0.35 30 0 0` and its mirror):

```
Umain 0.00 -0.00 1.00   Uoff -0.00 0.00 -1.00   Lmain -1.00 0 0   Loff 1.00 0 0   Fmain 0 1 0   Foff 0 1 0
```

`melee.zs` `Place()` uses `fR = -ph.L` (765), which for the off hand is the mirrored side and so matches the mirrored
drawing. But it also uses `fU = ph.U` (766), which is upside down, and the drawing is not. The off axe's edge point
(hand frame 38.3 cm forward, 22.1 cm up) and head point (26.6, 31.4) are computed **22 cm and 31 cm below the
controller instead of above**, so they sit 44 cm and 63 cm (15 and 21 map units) from where the axe is drawn. The edge
direction `BladeOut - BladeIn`, forward-and-down on the drawn axe, becomes forward-and-UP. That is the drawn spine.
The edge-leading gate therefore rejects every real chop. Measured edge cosines on the same swings: main +0.80 to +0.98,
off -0.16 to -0.84.

The axe **throw** (`Throw()`, 1438-1467) reads the speed of the same mis-placed edge point, so it is affected too.
Not measured separately.

### 3. Rig measurement

How it was run: `tools/rig17` engine (`/home/claude/g9/rig`, QZD 17.3 qzd17.3 tag, Linux OpenXR stand-in). Load
order: doom2 -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3p -> 04-07 XMVE -> GunBonsai-0.10.6
-> all 18 RSQ pk3s (snapshot taken at 11:53 with SHA1SUMS, because other lanes were rebuilding `pk3/` during the
runs). `-singletics`. Script errors: only BD_VoxelPack's 4 voxeldef ones, which belong to the parent mod.

A test-only probe gives the player both axes (main hand `BrutalAxe` and off hand `RSQ_Off_BrutalAxe`, as the Dual key
does). It drives the same scripted swing through `qz_rhand` and, mirrored (x, yaw and roll negated), through
`qz_lhand`. Each swing is run at 11 durations (24 down to 2 tics). The probe places a held PistolZombie in front of
the swinging hand and logs, per tic, the speed each hand's `RSVR_Hand` sees, its power (speed / thr), the rise, the
edge cosine, and every `AxeAttack` spawned.

**Caveat:** the rig box was shared with 3 other lanes' rigs (load average 8-10 on 2 cores). The console's pose steps
sometimes bunched together, so some tics carry two or more steps of motion. Peak speeds per trial are noisy for that
reason. The per-tic gate results below don't depend on it.

Per-tic results. "Fast tics" are tics at or above the speed threshold that are not rising, i.e. tics where only the
edge test decides. "Min connecting" is the slowest tic that passed every gate.

| Swing (main; off = mirror) | Hand | Fast tics | Passed edge test | Min connecting (m/s at edge) | Trials with a hit |
|---|---|---|---|---|---|
| Chop (raised 50 deg up -> 50 deg down, 0.6 m drop) | main | 29 | 29 | 4.60 | 7/11 |
| | **off** | 22 | **0** | **never (fails up to 32.1)** | **0/11** |
| Drop (pure downward, controller level) | main | 14 | 14 | 4.63 | 3/11 |
| | **off** | 13 | **0** | **never (fails up to 12.6)** | **0/11** |
| Wrist snap (100 deg pitch, no travel) | main | 18 | 17 | 4.60 | 6/11 |
| | **off** | 23 | **0** | **never (fails up to 15.2)** | **0/11** |
| Lunging chop (forward + down) | main | 34 | 34 | 4.52 | 9/11 |
| | **off** | 29 | **0** | **never (fails up to 17.7)** | **0/11** |
| Side slash, wrist rolled edge-first | main | 32 | 32 | 5.25 | 8/11 |
| | **off** | 16 | **0** | **never (fails up to 33.3)** | **0/11** |
| Side slash, wrist rolled spine-first | main | 30 | 0 | never (correct) | 0/11 |
| | off | 33 | **33** | 4.53 | 9/11 |
| Forward stab, hand pointing down | main | 6 | 0 | never | 0/11 |
| | off | 9 | 9 | 5.53 | 2/11 |

The off hand's speed reading is never lower than the main hand's. It is rejected by the edge test, except on swings
that lead with the drawn spine. Those swings are exactly the ones the main hand correctly refuses.

**With the one-line fix** (`fU = off ? -ph.U : ph.U`, test copy `03_fixtest.pk3`, same order):

| Swing | Main: passed / fast, min m/s, hits | Off: passed / fast, min m/s, hits |
|---|---|---|
| Chop | 13/13, 4.52, 2/11 | 2/2, 4.54, 2/11 |
| Drop | 6/6, 4.63, 2/11 | 4/4, 6.43, 2/11 |
| Wrist snap | 16/17, 4.80, 1/11 | 16/17, 5.06, 4/11 |
| Lunging chop | 23/23, 4.52, 7/11 | 8/8, 4.52, 5/11 |
| Side, edge-first | 38/38, 5.02, 7/11 | 17/17, 4.50, 5/11 |
| Side, spine-first | 0/3, never | 0/11, never |
| Stab, pointing down | 0/7, never | 0/13, never |

The fewer fast tics in these runs come from more bunching on the busier box, not from the fix. After the fix both
hands pass and refuse the same swings, at the same about 4.5 m/s. **Rig only, not headset-confirmed.**

### 4. The whole melee system

"Speed read" is where the hand's speed comes from. Measured minimums are from this rig session. "code" means the
system was audited in its code but not run here.

| System | Speed read (file:line) | Threshold | Main min | Off min | Gap? |
|---|---|---|---|---|---|
| **BD22 VR off-hand axe slash** | melee.zs:936-942 (edge point, body frame); frame 755-776; edge gate 965-975 | 4.5 m/s at edge (`AXE_SWING` 3.0 x1.5 x `rsvr_melee_swing`); edge cos >= `rsvr_axe_edge` 0.5 | 4.52-4.63 | **never on a real chop**; only spine-first 4.53 | **YES: mirrored frame (pose.zs + melee.zs:766)** |
| **BD22 VR off-hand axe throw** | melee.zs:1438-1467 (fastest step of the same edge point) | `THROW_MIN` 2.5 m/s | not measured | not measured | **YES (same point; wrong side of the wrist)** |
| BD22 VR sword, chainsaw, gun-butt strikes, pistol whip | melee.zs:936-942 | sword 5.25, butt 3.6, whip `rsq_whip_speed` 5.0 m/s | (as before) | main hand only (`KindOfOff`, 665) | No off-hand version |
| BD22 VR fists (punch with either hand, `RSQ_Fists`) | fists.zs:66-67 (AttackPos / OffhandPos), 140-150 | `PUNCH` 2.5 m/s, 70% forward | code | code | No (positions only, same class for each hand) |
| RSQ Melee punch / gloves | gloves.zs:335-356 (pos vs pawn.Prev, one tic), gate 364/424 | `rsqml_punch_min_speed` 2.0 m/s average over 0.15 m | **2.19** | **2.19** | **No (measured)** |
| RSQ Melee Hadouken / swat / catch | gloves.zs:396, 599, 795 (same per-hand velocity) | 2.0 m/s; swat `SWAT_MPS` | code | code | No |
| RSQ Melee shove / pistol whip | shove.zs:140-170 (ring), 193 reads hand 0 only | `SWING_MPS` 2.0, `rsqml_shove_mps` 3.6 | code | main hand only | No (main hand only by design) |
| RSQ Melee Headlock throw | headlock.zs:363-377 `PalmVel` | off palm only | - | code | No (one hand) |
| RSQ Melee Guard parry | guard.zs:34 `PARRY_MPS` 1.0, both hands | 1.0 m/s | code | code | No |
| RSQ Saber | QuestSaber/zscript.txt:1241-1303 (tip speed less the body's) | `ubqs_swing_cut` 8.0 u/tic | code | code | No: blade direction handles the off-hand mirror explicitly (line 38); no edge gate |
| RSQ ShieldSaw | ssq/guard.zs:401, 981 `pose.Vel()` | off hand only | - | code | No (one hand). Its `SSQ_Pose` builds the same mirrored frame (pose.zs:161), but its shapes were fitted on that one hand. |
| RSQ Whip | whip.zs:1586, 2598 (tip); hand from AttackPos/OffhandPos + yaw/pitch only (util.zs:104-121) | `rsqwp_whip_crack` 20 | code | code | No |
| Tactical Rig gun throw | rig.zs:1287-1297 `SwingPeak` (fastest 2-tic window, body frame) | `rsqtr_throw_speed` 2.5 m/s, both hands | code | code | No (main hand also throws on Use: a different input, not speed) |
| Distance Grab yank (flick) | grab.zs:328-331 `PeakPitchUp(hand)` | `rsqdg_flick_deg` 5 deg/tic | code | code | No (pitch only; pitch is not mirrored) |
| Gun Bonsai VR melee upgrades | up_fists.zs, up_melee.zs: numbers only, read through RSQ Melee | - | - | - | No own hand read |

The pattern to watch for: only code that builds a full hand basis (left/up) from `OffhandDir(yaw 90)` and then places
a model point fitted on the main hand can go wrong. Inside BD22 VR, `RSQ_PoseHandler.Of` has exactly one reader:
melee.zs `Frame()`. So the fix in one place covers the slash, the throw and the off axe's sweep position.

### 5. Proposed fix (needs the owner's yes; BD22 VR repo)

`rs_brutal22weaponsq/src/zscript/rsvr/melee.zs`, `RSVR_Hand.Frame()`, line 766:

```
fU = off ? -ph.U : ph.U;   // the off frame arrives mirrored (OffhandDir yaw 90 is the hand's right), so F x L is down
```

`fR = -ph.L` stays as it is: it is already mirrored the way the off model is drawn. The cleaner alternative is to fix
it where the pose is built: send the real left (`-OffDir(90)`) for the off hand in pose.zs and mirror `fR` in melee.
That is a larger change for the same result. Before anything goes to the headset: rebuild with `python build.py`,
run the owner's order for script errors, and re-run this probe.

### 6. Would the Windows rig help? (commit 54cf2a464, `TestRig/`)

Yes, as a confirmation step. It runs the owner's actual PCVR build, through the OpenVR path (`gl_openvr.cpp`, a fake
runtime posed from `qz_rhand`/`qz_lhand`). This Linux rig runs the OpenXR stand-in. The mirror is in code both paths
share (`hw_vrmodes.cpp` `GetWeaponTransform` / `MapWeaponDir`, which `gl_openvr.cpp` calls), so the same result is
expected. Logging `RSQ_PoseHandler.Of(mo, 1).U` there with the controller level (it should read about (0, 0, -1)
before the fix) would confirm it on his engine in one run. It may also avoid the bunched pose steps this shared box
caused. It only runs on his PC.

### Test files (scratchpad, never shipped)

`/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/axp/`: `probe/` (the AXProbe pk3
source), `gen.py` (swing scripts), `run.sh`, `ana.py`/`ana2.py`, `logs/` (`m_*` before the fix, `f_*` with it,
`m_punch` the gloves), `fix/03_fixtest.pk3` (the test copy with the one-line change), `snap/` (the RSQ pk3 snapshot
with SHA1SUMS).
