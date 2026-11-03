# HANDOFF -- RSQ_Whip (PROJECT WHIP), 2026-10-30

## 2026-11-02 (GBOVR pass): the recode reviewed, the owner's seven decisions -- Windows QZD 17.3 headless, not the rig
A read-only review of the recode (MIT length) found numbers sized for the old 6.4-unit links. The owner decided all
seven (11-02). Tested on the owner's Windows QZD 17.3 with the series probe (`GunBonsaiOffhandVR/tools/fistsprobe`,
`fp_wp`), which calls the whip's own functions; that engine cannot move a VR hand, so **no swing was run** (the Linux
rig's `qz_rhand` cvars are not on that build). With no tracked hand the whip holds the handle at the eyes, so
Assist's throw and Reach's flight do run.
- **Reach's speed bookkeeping fixed** (`Reach`): the link's last sub-step is set a sixteenth of the tic's move
  behind, so the sim reads the move as a per-tic speed. Assist's throw: the sim read 3-11 room/tic while the tip
  moved 10-25 a tic (was 100-490).
- **Hardest crack 50 -> 43**, and the cvar renamed `rsqwp_whip_hardcrack` (every archived cvar is written to the ini,
  so a saved 50 would have stayed). Damage by tip speed 20/30/35/43/50: 3/7/9/12/12 (was 3/6/8/10/12).
- **A crack with the last links still paying out** (`CRACK_COILED` 6: 19 of 25 out, 1 tic): about 6 tics into the
  payout, not ~10. Probed: 5 links coiled -> ready; 7 -> not. Whether a fast real throw now cracks: headset.
- **The lasso's catch reach** = 4x the whip's length (`LassoReach`, `LASSO_REACH_K`): 7.2 m (was 2x: 3.6 m).
- **The lasso's held piece** = the links between the handle's tip and where the off hand took hold (`LassoHeld`, 3 to
  `LASSO_K` 13 = 0.94 m, the old piece): 0.3 m -> 4 links, 0.6 m -> 8, 1.2 m -> 13. The grip may take the thong
  anywhere along it. A fixed 5 (0.36 m now) stretched links 1-5 toward an off hand further out.
- **`GRAZE_U` 6 -> 2.3** map units (about a link, as 6 was for 6.4-unit links).
- Comment nits from the review (handSpd's merged comment, COIL_A's side, "21 links in").
Not changed: Assist's throw reach (`Throw`: 1.1x the length, ~2 m, not in the decisions).
- **Snag and the rope re-tested** (owner: before the Rope branch) on WHIPTEST: a crack just under the beam's edge
  (z 72, 37 above the hand) became core's rope; stepped off the lip, you swung out to x 560 and back onto the ledge
  (fell 17, not 512). A still player on the ground is stopped dead by QZD, so the probe put you just past the lip.

### The Gun Bonsai VR Whip tree (GBOVR_TREES.md 4.4), built the same day
`whip.zs` GbRefresh / Gb / Unlock (the levels by name once a second, -1 without the patch); `core.zs` Carry, CapSpeed,
Comfort and Tarzan; `weapon.zs` the lasso. Probed headless (`fp_wt*`), numbers in GBOVR_TREES.md 4.4 BUILT. Fields
renamed for ZScript's case-blind names: Bola's tied monsters are `tied[]`, not `bola[]`. Not run: a real swing, Mantle
2 (a swing up to a lip), Lasso 2's longer hold in a real throw. Found on the way, not changed: a fetched pickup flies on
an arc meant to land on you, and an item is picked up only when the player moves into it (QZD); in the probe the
fetched items stopped 40-60 units short on MAP01. Headset: does a fetched pickup reach you and get taken.

## 2026-11-02 (latest): MIT's length, held coiled, uncoils for the attack -- rig only, not headset-confirmed
Owner (headset): "That whip looks hella long dude, almost like a noodle ... we hold it coiled ... shorten the length
of it and extend it during the attack?" Decisions: length = MIT's exactly; coiled at rest; ramped uncoil/reel.

### Done (whip.zs; measured on the rig, qzd17.3, doom2 MAP01, BEFORE = 9c32f28a8 via `git archive`, same probe)
- **Length = the reference's** (parsed from 3D_model_w_whip.xml): 25 links x 0.072 m = 1.8 m (was 20 x 6.4 room =
  3.76 m). LINK = 0.072 x 34 = 2.448 room units. The joint's omega^2 = 114 / 2.448^4 = 3.175 /tic^2 = the reference's
  k/(m l^2) = 3890 /s^2; c/k 13.31 tics. **Leather Damping default x1 (the reference; was x0.25).** The Whip Length
  slider and rsqwp_whip_reach are gone. `LenMult()` (1) is the one place a "super whip" would double the links.
- **The coil** (`cp` links coiled, rate `cps`, goal `cgoal`; CoilTic, CoilAt, LayOut, Sim): at rest 21 links lie on a
  30 cm loop hung from the handle's tip (facing you, inward, stepped along the heading), pinned to it; a 4-link tail
  (0.29 m) is simulated. Goal 0 (all out) on the wind-up (windTics >= 2), a swing, the lasso grip, a wrap, a flight,
  Assist; back to rest after 30 quiet tics (tip < 3, handle tip < 1.2, nothing going on); NN when put away (then
  Halt). The rate accelerates toward the goal and slows to land on it: payout max 3.5 links/tic, 1.0/tic^2 (~10
  tics); reel max 1.2, 0.25/tic^2 (17 tics measured). Payout unpins the coil's last link (it was moving with the
  coil, so it goes on at that speed); reel draws the next free link onto its loop place over one link's reel time.
  While reeling, free links are capped at 5 room/tic. The wind-up guide's line starts at the coil's end. The crack
  needs 2 tics fully out. Collide/Mend/Carry skip the coil's links.
- **Lasso:** uncoils on the grip; the off hand's 5-link piece is taken over 6 tics once the thong is out (`lb`).
- Fixes found on the way: Relax 12 passes, alternating (short links); a link floor-lifted by under 3 units is no
  longer held fixed in the relax (it left a link 7x long at MAP01's lip: swing lerr max 632% -> 61%); a tracking-space
  turn now needs BOTH controllers turned (one hand's yaw noise passed as sub-degree turns and cancelled the jitter
  run's crack).

| run (whp_metrics.py) | BEFORE 9c32f28a8 | AFTER |
|---|---|---|
| idle t>=30: tip max / KE max | 0.3 / 0.1 | 0.0 / 0.0 |
| walk 3 s, hand still: tip max / KE / jerk max / link-in-wall tics / tip max dev (body frame) | 38.2 / 632 / 26.4 / 195 / 80.8 | 0.0 / 0.0 / 0.0 / 0 / 0.1 |
| snap x4: tip max / KE / dev | 0.1 / 2.0 / 9.9 | 0.0 / 0.0 / 0.1 |
| jitter, noisy hold t30-157: tip max / KE / jerk RMS | 0.3 / 1.7 / 0.43 | 0.8 / 2.9 / 0.36 |
| sway: tip max / KE | 0.3 / 2.5 | 0.6 / 3.0 |
| swing (2 wind-ups): cracks, peaks | 2, 87 / 80 (1 peak each) | 2, 43 / 44 (1 peak each, heavy, k 0.74) |
| swing: lerr mean / max | 1.64 / 75% | 1.41 / 61% |
| jitter whole (noisy swing): cracks | 1 | 1 (peak 43) |
| wall (2 swings): cracks | 2 | 2 (37 / 37, 1 peak each) |
| yank: mark, crack, wrap, yank | yes | crack 42 -> DoomImp 60->50, WRAP, YANK light (no BD token) |
| lasso0..7: thrown / whirl mean / cracks after | (HEAD: 8/8, 28.5) | 8/8, 25.6-26.8, 0; let-go 26.4-27.4, all round |
| lasso grip: tip speed first tics | 41 jolt | 1.3, ramps to 21 by t40 |
| two whips, ms/tic mean | 0.79-0.92 | 1.02-1.08 |
- Coil run (`whp_scripts.py coil`): wind-up t70 -> UNCOIL, tip under 13.7 while paying out (no crack); crack t87 at
  42.5; quiet -> REEL t172, tip max 8.4 while reeling (26 before the reel cap), coiled by t189.
- Frames (chase camera behind, `coilv`: the arm 0.25 m further out), scratchpad
  `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/`: `strip_coil_idle.png` (coil + tail
  still, frames 150-190), `strip_coil_uncoil.png` (205-217: the coil rises with the hand and pays out behind),
  `strip_coil_crack.png` (218-226), `strip_coil_reel.png` (305-345: the thong drawn back, the coil re-forms).
- Script errors: doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. Full order (01, 02, 03 2.0.3n from the BD22 repo,
  04-07, GunBonsai 0.10.6, all RSQ): 4, all 02_BD22_VoxelPack's voxeldef. Every scenario run: 0.

### Not done / open
- Not headset-tested. Feel guesses: tail 0.29 m, coil 30 cm, payout 0.3 s, quiet 0.86 s, reel 0.5 s, reel cap 5.
- A swing without the wind-up never uncoils, so never cracks (owner's spec: the wind-up pays out).
- The 1.8 m crack is about half the old tip speed; damage and the heavy/light split still use 20 / 50 (heavy at 43).
- The lasso's held piece is not on its line while the coil pays out (6-10 tics); probe "inner stretch" 20% mean.
- Not re-run: snag/rope, flail into others, Assist style, left-handed (the coil hangs inward per hand).

## 2026-11-02 (later still): the lasso whirls fast and throws from anywhere -- rig only, not headset-confirmed
Owner: make the lasso fun "regardless of cost to us". After the physics rebuild it whirled at 6.5 room units/tic
(was 22.5) and a let-go at a slow point dropped it.

### Done (measured; rig qzd17.3, doom2 MAP01, BEFORE = 9c32f28a8 via `git archive`, same probe)
- **Whirl help** (whip.zs `Whirl`, Sim, `LassoThrow`): the off hand's circle is tracked each tic (its centre is the
  hand's path averaged, its angular velocity is the hand around that centre, smoothed). How round and fast the
  circle is gives a target 0..1, and `lw` ramps toward it (+0.15 a tic in, -0.25 out). Per sub-step x lw: every
  free link is eased toward turning with the circle (WHIRL_G 0.5/tic, the loop at 1.25x the hand, tip capped at
  32), and the bend damper and the drag are eased off by 60%. At lw 0 the model is exactly 9c32f28a8's.
- **Let-go:** along the circle's tangent at the tip, at max(tip speed, lw x the whirl's smoothed tip speed).
  The drop rule (LASSO_MIN 6) is unchanged for a lasso that was not whirled.
- **No crack from a thrown lasso:** BEFORE, a lasso thrown into the air cracked where it landed: Reach's per-tic
  move is read as a sub-step speed, 156 room/tic. It also does so AFTER (491) without this fix. A throw now
  disarms the crack until the thong calms.
- Rig: scenario `lasso0..lasso7` (whp_scripts.py: the 0.30 m overhead circle, 14 tics a turn, started k x 45 deg
  on, so the t150 let-go is at 8 points of the circle); `tools/rigtest/lasso_metrics.py` reads them.

| | BEFORE | AFTER |
|---|---|---|
| whirl tip speed, t40-149, mean (min), 8 runs | 2.5-6.3 (0.2-1.0) | 28.5-28.8 (20.1-25.2) |
| let-go at 8 points: thrown | 5 of 8 (3 dropped at 2.4, 5.1, 5.6) | 8 of 8, at 30.8-31.7 |
| throw direction (deg off facing) | not logged | -172, 123, 86, 46, 15, -20, -59, -111 (all round) |
| tip out after let-go, max flat | 22-145 | 145-157 (the thong is 128 + handle) |
| cracks after the let-go | 5 of 8 runs | 0 |
| imp 220 ahead, let go at 15 deg | dropped (4.8) | thrown -> DoomImp, hit 6, WRAP, pinned |
| Leather Damping x1 | lasso could not lift (2.7) | whirl 28.5, thrown |

Ramp-in (lasso0, tip speed from the grip): 7.5 8.1 8.3 8.8 9.4 10.3 11.0 ... 18.1 25.4 25.0 22.1 ... 25.3 (no step).
The 41 room/tic in the first tics after the grip comes from the latch pinning links 1-5. It was the same BEFORE.

Unchanged (whp_metrics.py, BEFORE -> AFTER identical to the printed digit unless noted): idle, sway, snap
(t>=30), walk, swing (2 cracks, peaks 87/80, one each), wall (2 cracks, 68/67): every column the same except ms.
Jitter: lerr 0.63 -> 0.62%, wall tics 75 -> 78, KE 25035 -> 25038, same peaks and 1 crack. That is run-to-run noise:
lw stays 0 there, so the code path is the same.

Frames (chase camera, behind), scratchpad `/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/
scratchpad/`: `strip_A_whirl.png` (frames 236-248, one turn: the loop flat and out, sweeping round overhead) vs
`strip_B_whirl.png` (the thong hangs by the body); `strip_A_throw.png` (288-304: the let-go, the loop flies out to
the imp ahead) vs `strip_B_throw.png` (dropped).

Script errors: doom2 + GunBonsai 0.10.6 + all RSQ pk3s: 0. Full order (01, 02, 03 2.0.3n, 04-07, GunBonsai 0.10.6,
all RSQ): 4, all 02_BD22_VoxelPack's own voxeldef. Every scenario run: 0.

### Not done / open
- Not headset-tested. Feel guesses: the 32 m/s cap, loop 1.25x the hand, help from 1 turn in 3 s (full at 1.1 s)
  and a 6-15 cm circle, ramps 7/4 tics. Only the rig's perfect circle was tested; a real wobbly circle was not.
- Reach's flight still reads a per-tic move as a sub-step speed (tip 100-490 room/tic in flight, BEFORE too).
  The lasso no longer cracks from it. Not changed for the marked crack.
- Cost while whirling not measured separately (about 15 extra vector ops per link per sub-step).


## 2026-11-02 (later): the thong's physics rebuilt on a research whip -- rig only, not headset-confirmed
Owner (headset): "The whip is erratic ... i can't describe it more than that." He approved a rebuild on a validated
whip model. Reference: Moses C. Nah, MIT Newman Lab, "Whip Project - Targeting with a Whip"
(MosesAndLily/whip-project-targeting, BSD-3; models/3D_model_w_whip.xml): 25 nodes x 0.012 kg, 0.072 m links,
2-DOF hinges k 0.242 N m/rad, c 0.092 N m s/rad, first joint free; MuJoCo 1e-4 s Euler.

Rig: qzd17.3 (tools/rig17 engine), doom2 MAP01 (its start platform has a 50-unit drop just ahead: the thong lands
over that lip in several runs, a good stress case). Probe `tools/rigtest/whp` with `whp_metric 1` (a `whp_M` line a
tic; `2` dumps the chain), scenarios `whp_scripts.py idle sway walk snap swing jitter wall two`, metrics
`whp_metrics.py` (`--from 30` for the static ones: the whip is drawn at t0 and falls ~15 tics). BEFORE = `git
archive HEAD Whip`, same probe.

### What made it erratic (measured, BEFORE)
- **Regime switches.** Sim picked its damping (calm 0.96 / active 0.9995 / settle 0.80 a sub-step), its speed cap
  (1.2 / 11 / 2.5 a sub-step) and its sub-steps (3 / 8) from the hand's speed every tic. Logged per tic: 10 switches
  in the swing run, 33 in the jitter run (the hand's noise flipped calm/active 10+ times while just held), 22 in the
  wall run. Entering the wind-up regime took the tip from 0.3 to 29.2 room units a tic in one tic; after the wall
  hits the sub-steps flipped 3/8 every few tics with tip-speed jumps of x20-45. 3 -> 8 sub-steps also multiplied
  every link's speed by 8/3 (Verlet keeps a per-sub-step move).
- **No bend stiffness.** Only the wind-up's pull to the handle line; the chain had no shape of its own, so the
  rigid rod either held (swing run: the thong a straight rod, frames) or flopped.
- **The geometry response.** Collide stopped a link dead where the tic's straight sweep met a wall, floor or
  ceiling, though the sub-steps' path was curved: the wall run ended stretched 30% on average (max 724%).
- Per-tic hand jumps, linearly interpolated over the sub-steps: the handle's speed jumped at every tic's edge.

### The new model (zscript/rsqwp/whip.zs Sim; prototype tools/whipsim_xpbd.py)
- XPBD, **16 sub-steps x 2 length passes a tic, always** (no rest/active modes). Per sub-step: the handle moves
  along its path; links integrate (air drag, gravity 0.2723 = 9.81 x 34 / 35^2 room/tic^2, the speed cap 150
  room/tic, always on); the wind-up guide; the bend springs/dampers; lengths; floor/ceiling (each link's from its
  last Collide, sliding keeps 0.6 of its speed a tic); a wall the link rests on (below).
- **Bend (the reference):** C = p[j+1] - 2p[j] + p[j-1] at every joint. A driven free chain depends only on EI/lam
  and c/k: EI = k l = 0.01742 N m^2, lam = 0.1667 kg/m, EI/lam = 0.1045 m^4/s^2 = **114.0 room^4/tic^2** (x 34^4 /
  35^2); c/k = 0.3802 s = **13.31 tics**. Ours keeps the visible length (rsqwp_whip_reach 128 = 3.76 m + the 8-unit
  handle) and 20 links of 6.4: a joint's omega^2 = 114 / 6.4^4 = 0.068 /tic^2. Uniform mass as the reference (the old
  1 -> 1/34 taper is gone). The handle joint has the same spring (the reference's free first joint is its hand; ours
  is the end of a rigid handle the thong is set into). Stiffness never above the full whip's (an uncoiling short
  thong was a rigid rod).
- **Damping default x0.25 of the reference** (rsqwp_whip_bend_damp): at x1 the off-hand lasso could not lift the
  thong (whirl tip 2.7 room/tic, let-go 0.1: it dropped); x0.5 6.9, x0.25 7.6, x0.1 8.9 (the old model 22.5). Crack
  and noisy hold were as clean at x0.25 as at x1; x0.1 began to double-peak a swing. The owner may set x1.
- **Hand smoothing:** the hand followed critically damped (omega = 2 / rsqwp_whip_smooth, default 0.8 tics),
  integrated per sub-step from last tic's raw pose to this tic's. Measured lag: **0.70 tics** (swing, sway, wall),
  0.65 (jitter) -- under 1.
- **One damping model** = the bend damper + linear air drag (rsqwp_whip_drag 1/s). CALM/SETTLE/MAXSTEP/WIND_STEP
  and settle[] are gone. A length change (uncoil, roll up, reach, wrap) rescales the chain with its last places.
- **Wind-up guide:** each link pulled to its place on the handle's line as an XPBD spring of 1.5 x stiff rad/tic
  (less toward the tip), critically damped against the line's own motion (it was a per-sub-step fraction).
- **Geometry, continuous:** a wall hit keeps the move along the wall (speed into it removed, along it x0.6) and the
  link then RESTS on that wall: every sub-step keeps it on this side (WallSet/WallClear: the line, its normal, the
  height band a two-sided line blocks; dropped 4 units clear or past the line's ends). Floor/ceiling crossings go to
  the floor clamp, which removes speed into the floor. After Collide's stops, Carry's lifts (a turn or step put links
  under a floor) and Mend's fixes, the chain is relaxed to length with links moving with their last places (Relax).
  OpenAt: a link on a step's line takes the lowest floor round it. Mend: walls only; a segment bent round a lip or
  corner by up to 6 units is left alone (Graze); a mended link is pushed out along the wall's normal.
- New sliders (Tuning and Debug, Reset All): Leather Stiffness 1, Leather Damping 0.25, Whip Air Drag 1, Hand Smoothing 0.8.

### Before -> after (rig, final code)
| run | link error mean/max | tip max (room/tic) | flips/s | tip jerk RMS/max | KE max | mend tics | cracks |
|---|---|---|---|---|---|---|---|
| idle (t>=30) | 2.55/13.7% -> 0.04/0.04% | 0.3 -> 0.3 | 0 -> 0 | 0.00/0.06 -> 0.00/0.00 | 0.6 -> 0.1 | 0 -> 0 | 0 -> 0 |
| sway (t>=30) | 0.66/1.4% -> 0.04/0.04% | 0.3 -> 0.3 | 0 -> 0 | 0.08/0.31 -> 0.10/0.43 | 2.8 -> 2.5 | 0 -> 0 | 0 -> 0 |
| walk 3 s, hand still | 8.2/390% -> 0.19/7.6% | 35.2 -> 38.2 (one sub-step at a mend, MAP01 stairs) | 0.21 -> 0.21 | 4.69/62.6 -> 2.16/26.4 | 1322 -> 632 | 6 -> 1 | 0 -> 0 |
| snap x4, hand still (t>=30) | 1.2/1.2% -> 0.05/0.05% | 0.3 -> 0.1 | 0 -> 0 | 0.00 -> 0.00 | 0.0 -> 2.0 | 0 -> 0 | 0 -> 0 |
| swing (2 wind-up + crack) | 11.4/146% -> 1.6/76% | 112 -> 88 | 1.05 -> 0.26 | 16.8/111 -> 10.2/69.5 | 46668 -> 25303 | 1 -> 0 | 2 -> 2 |
| jitter: noisy hold t30-157 | ~/17% -> 0.31% | 0.30 -> 0.26 | 0 -> 0 | 0.32/0.81 -> 0.43/1.08 | 10.3 -> 1.7 | 0 -> 0 | 0 -> 0 |
| jitter: whole (+ noisy swing) | 6.2/80% -> 0.63/75% | 112 -> 91 | 0.62 -> 0.31 | 11.2/113 -> 7.5/77.3 | 46738 -> 25025 | 0 -> 0 | 1 -> 1 |
| wall (40 units, 2 swings) | 35.7/724% -> 0.93/95% (stretch 30.4/724 -> 0.12/7.5%) | 165 -> 68 | 0.10 -> 0.31 | 9.3/61.6 -> 6.7/69.6 | 12013 -> 20584 | 2 -> 0 | 3 -> 2 |
- **One crack per swing, one tip-speed peak:** swing windows BEFORE 2 peaks each (112 then 60, 6 tics apart),
  AFTER 1 peak each (87, 80: heavy, CrackK >= 0.5); the noisy swing 2 maxima (91, 59) and one crack. Wall BEFORE 3
  cracks (an extra 101 against the wall), AFTER 2. Yank BEFORE cracked again right after the yank; AFTER crack ->
  wrap -> yank, once. Lasso: AFTER let go at 9.1, thrown (BEFORE 11.1); whirl tip mean 6.5 (BEFORE 22.5).
- No energy blow-up (fastest node 82 room/tic, under the cap); no Straighten in the final runs.
- Link-error maxima AFTER are links folded short where the thong piles at a wall or lip, and the 1-2 tics a crack's
  tip falls past MAP01's start-platform lip (stretch, the long side, is the honest number).
- The noisy hold's jerk RMS is a little higher (0.43 vs 0.32) because the old model clamped every link to 1.2 room
  units a sub-step while calm; its tip still moves less (0.26 vs 0.30) and KE is 1.7 vs 10.3. An earlier run where
  the thong lay on the floor gave 0.12 (where it lands at the draw varies run to run).
- **Cost** (rsqwp_debug 3, desktop rig): one whip 0.40-0.45 ms/tic mean (before 0.24-0.35); **two whips** (weapon +
  Whip (Off), both swinging) **0.79-0.92 ms mean, max 1.2-2.3** (before 0.48-0.72); sim 0.45-0.54 of it.
- **Frames** (chase camera, behind): scratchpad `strip_B_windup.png`, `strip_B_crack.png` (before) and
  `strip_A_windup.png`, `strip_A_crack.png` (after); windup t62-80, crack t81-94. Before: the thong a straight rod
  through the crack. After: a loop rolls out along it (t83) and the tip whips over. The wind-up is above/behind the
  chase camera and barely shows in either.
- Script errors: doom2 + GunBonsai 0.10.6 + all 18 RSQ pk3s: 0. Full order (01, 02, 03 2.0.3m, 04-07, GunBonsai
  0.10.6, all RSQ): 5, all 02_BD22_VoxelPack's own (4 voxeldef + DeathSphere_Vox). Every scenario run: 0.

### Not done / open
- Nothing headset-tested. Feel is the owner's call: reference leather, damping x0.25, smoothing 0.8, drag 1, guide 1.5.
- **No crack without the wind-up** on the rig: the scripted sidearm/overhead snaps start with 2.5 m of thong on the
  floor and peak 3-15 room/tic (prototype); the old tapered thong cracked them. The deliberate wind-up cracks.
- (Fixed in the section above: the lasso whirled slower than before and could drop.)
- A Mend while walking (MAP01 stairs) still gives one sub-step jolt (38 internal).
- Cost ~1.3x the old per whip; Quest not measured. tools/whipsim.py is the old model; whipsim_xpbd.py the new.
- Not re-run after the rebuild: flail into others, snag/rope, Assist style, left-handed.

## 2026-11-02: the owner's headset report, fixed on the rig (not headset-confirmed)
Rig: qzd17.3 (tools/rig17 engine, /home/claude/g9/rig), probe `tools/rigtest/whp/` + `whp.sh` + `whp_scripts.py`
(one tic per `wait 1` at vid_maxfps 35). The probe logs `whp_` lines. BEFORE = `git archive HEAD Whip`, AFTER =
this tree. doom2 MAP01. "BD" = the owner's order with every committed RSQ pk3 except GunBonsaiVR.

### Done (measured)
| item | cause | fix | before -> after |
|---|---|---|---|
| snap turn fires it | the chain was simulated in the world: a snap swung the hand and handle 45 deg round the body in one tic | `Carry` moves and turns every node with the body. `TrackFrame` finds the tracking-space turn from both controllers: same yaw change, both turned round the pawn. The pawn's angle on the rig took the snap a tic before the controllers. Lash skips a turning tic | 4 snaps, hand still: cracks 5 -> 0, tip max speed 45.3 -> 0.3, tip drift (body frame) 166 -> 0.7 room units |
| walking goes insane | the world-space chain was dragged along. AttackPos.z also follows the interpolated eye, view bob and the step dip (a still hand moved 33..52 over the pawn on MAP01's stairs) | `Carry`. `BodyHand`: the hand is measured per frame against that frame's eye (RenderOverlay -> rsqwp_hp0/1) and put back on `SteadyEye` (ViewHeight + crouchviewdelta). Calm damping 0.96 a sub-step and a step cap of 1.2 while the hand is calm | walk 3 s down and up stairs, hand still: cracks 1 -> 0, tip max deviation 139.9 -> 18.8 (the thong lying on the steps), link-in-wall tics 35 -> 0 |
| deliberate attack | nothing scripted. After a crack it re-armed at 70% of the crack speed, so one throw cracked 2-3 times | `Deliberate`: wound up (handle >= 27 deg up, not forward, hand >= eye-14) for 2 tics, then the thong is guided to a line out of the handle (GUIDE 0.30, less toward the tip). The swing drives it like a rod and releases at 55% of peak. No crack while wound up. It re-arms only when calm or on a new wind-up | 2 scripted wind-up + swings: cracks 5 -> 2 (one per swing, tip 112 / 136) |
| yank -> BD melee -> stuck | the whip's DamageType 'Melee': BD's monsters answer it with their stealth kill (Pain/Death.Melee -> StealthKill -> GoFatality, GoSpecial and SK<monster> given to the player). Also HoldWrap moved links without their Verlet history (flung on unwrap), and nothing got a link back out of a wall | `DmgType()` = 'Whip'. `Mend` traces the chain link to link each tic and puts any link past a wall back on this side. Stuck for 6 tics: `Straighten`; again within 35 tics: re-coil. HoldWrap moves wp and wq together. EndWrap settles for 12 tics | whip kill on an idle BD imp: GoFatality+SKImp+GoSpecial and the player jumps to his fatality state -> no token. Yank run (BD): link-in-wall tics 78 -> 0. Mended links: 152 -> 0 tics |
| off-hand twirl jank | the inner piece was pinned at both hands and length-solved between them, so the solver fought itself | links 1..5 are laid straight from the handle to the off hand; only the thong beyond is solved | whirl 135 tics: link-3 accel mean 3.30 -> 1.86, max 12.8 -> 9.6. Let-go tip speed 28.3 -> 8.5 (still over LASSO_MIN 6; watch it) |
| two whips | SwitchWeaponHand sets the hand pointers and skips Deselect, so PutAway never ran and the old hand's whip went on | `tendTic`: a weapon whip that its weapon no longer tends is halted. `WhipIn` + `rsqwp_whip_hand` (user, menu "Whip In", Main/Off, in Reset All) | switchhand 1: 2 whips for good -> 1 (at most a 2-tic overlap). Off Hand: 1 whip in the off hand for 300 tics on the BD order (BD's rsq_hands did not take it back) |
| lock icon | particle rings | `RSQWP_LockRing` (WPKR, AddShaded, CB HAVE over gold FFD040) + `RSQWP_LockCentre` (WPKC), 0.35 x Cue, 4 frames x 3 tics, grAb 24,24 | frames: white diamond in a gold ring over the marked imp |
| cost | | | swing run mean 0.19-0.38 ms/tic (before 0.20-0.35) |
Script errors: plain doom2 0. BD order: only BD_VoxelPack's 4 voxeldef.

### Not done / open
- Nothing headset-tested. Not measured: the real arm's wind-up angles, real smooth turn, left-handed, Quest cost.
- The exact owner trigger for "BD melee" was not reproduced in his words (an ALERTED monster yanked to you). The
  'Melee' -> fatality hand-off was reproduced and is gone; whether it was his case: headset.
- BD's off-hand fist (RSQ_Hands, fists.zs) still punches on a forward jab of the off hand during the lasso if
  rsq_punch is on: that is BD's, not touched.


Not run on the owner's headset. Rig: QZD 17.3 (RSQ_WeaponDepot tools/rig/bin), freedoom2 MAP01 and WHIPTEST
(tools/rigtest/mkwhipmap.py: a ledge, a pit, a beam over it, a 96-unit block, a switch pillar). Hands driven per tic by
tools/rigtest/whipprobe (the rig's qzt_rhand), runner tools/rigtest/whip.sh (BD=1 the owner's BD order, GRAPPLE=1 also
loads pk3/RSQ_Grapple.pk3).

## Owner's picks 2026-10-31 (6, 7, 9 yes; 8, 10 options, off) -- rig only, not headset-confirmed
All on doom2 + brutal22test6 + BD_VoxelPack + BD22 VR-Reloaded 2.0.3h + hotfix + RSQ_Whip, the whip weapon in hand, map
WHIPTEST (`map WHIPTEST` after `-warp 1`). Only BD_VoxelPack's 4 voxeldef script errors. Scenarios: whipprobe `wpr_scen`
10 (flail) / 11 (lasso), `wpr_ballat` (an imp ball each cycle), `wpr_slow`, `wpr_log 4` keys / 5 monsters.

### Done (measured)
| pick | built | rig log |
|---|---|---|
| 6 crack damage by tip speed (apply/08 3.1, apply/01 2.4) | crack = damage x (0.25 + 0.75k), k from the crack speed (20) to `rsqwp_whip_fullcrack` (50, the top of whipsim's measured overhead/side-arm range); `rsqwp_whip_damage` is the top. Stings now stay under the softest crack (a quarter x speed/crack speed); the old half-damage sting out-hurt a soft crack (6 against 3). Assist: always the top | MAP01 motion 3: tip 21.2 -> 3, 24.9 -> 4, 47.8 -> 11, 101.8 -> 12 |
| 7 Quest lasso (apply/01 5.2) | the off grip key read raw (`rsqwp_keys_off` "443 436", DG's codes; never eaten) or a grab bind, with the off controller within `rsqwp_lasso_reach` 0.30 m of the handle or the inner thong; kept while the grip is down | `vr_two_handed_weapons 0`: key 443 down, "off hand 0.11 m from the thong", LASSO on by the off hand, whirl, let go at tip 30.9, roped an imp. Frames: BD's left hand holds the whirling thong |
| 7 latch kept | WF_TWOHANDSTABILIZED still turns it on | default settings: "LASSO on by the two-hand latch" on the OpenXR rig |
| 9 flail (apply/01 4.2) | wrapped/lassoed monster held at the wrap distance from the whip hand, on its bearing off the hand's yaw; placed by TryMove (cap `rsqwp_max_speed`, half for over `rsqwp_whip_light`; heavy = no swing); light ones pinned in Pain (re-pinned every tic, put back on unwrap); a monster it is stopped by takes Grapple's (speed-8)x0.8 (max 40), forced Pain and a shove, the swung one half. Trigger held keeps hold. `rsqwp_whip_flail` | marked crack: imp swung from bearing 0 to -52 deg, SMASH into both side imps (speed 11-12, dmg 2-3, stagger). Lasso: 8 SMASHes at speed 28-30, dmg 15-17 |
| 8 fireball (option, 06_GRAB 4.6, 01_MELEE 4.11) | in a crack's lash, a fast outer link's sweep within radius+4 of a monster missile's path -> ExplodeMissile. Missiles listed on spawn (PROJECTILE is NOBLOCKMAP: no iterator finds one) | 2 DoomImpBalls cracked (t494, t630); a BD PlasmaSmoke (no shooter) was popped before the monster-shooter filter, not after |
| 10 hit-stop (option, 01_MELEE 3.6) | freezetics 3 + 3k | freeze 5 -> 3 -> 1 -> 0, state tics held at 2 |
| fixes found on the way | no crack while the lash flies out to a target (a lasso throw cracked at 108 on the way); the thong no longer stings the monster it is wrapped round; `gen_reset.py` handles noarchive and string cvars (Reset All checked: keys back to "443 436") |  |
| cost | rsqwp_debug 3, desktop, BD order | 0.16-0.20 ms out, 0.26 whirling, 0.39 mean / 0.86 max flailing into 8 imps |

### Owner's answers 2026-10-31 (later): lock the mark (yes), yank grace (option), cracked rockets (choice) -- rig only
Same order (doom2 + BD + VR-Reloaded + hotfix), doom2 MAP01, whipprobe; only BD_VoxelPack's voxeldef script errors.
| pick | built | rig log |
|---|---|---|
| lock the mark (`rsqwp_whip_marklock`, on) | Mark: the hand no longer points at the marked thing -> it stays marked while it is alive / untaken, within 512 and in sight (StillMarkable). Alt-fire still moves it; alt-fire with nothing else in the cone keeps it | scen 10, imp 200 ahead. Before: t88 "MARK -> RifleZombie" on the lift. After: "t88 MARK kept on DoomImp (2 other candidates there)", CRACK #1 t112 LOCKED -> DoomImp. Alt-fire: t80 DoomImp -> RifleZombie, then kept through the lift, cracked and wrapped the zombie at 335 |
| yank grace (`rsqwp_whip_yankgrace`, option off) | HoldWrap: no pull counts for YANK_GRACE 12 tics after BeginWrap, nor a pull still under way when it ends (the hand must stop first) | probe motion 9 (K3's crack + the arm snapping back 0.4 m in 6 tics). Off: WRAP t143 -> YANK t152 (23%), WRAP t220 -> YANK t222. On: WRAP t139, "YANK held off" t146..t151 (pull 2.0-2.1), grace over t152, next yank t206 (the next lift); WRAP t915 held off t916..t921 |
| cracked rockets (`rsqwp_whip_fireball_knock`, 0 default) | 0 = ExplodeMissile at the crack (as before). 1 = Knock: velocity along the struck link's sweep, part toward you removed (>= 0.3 away), pitch clamped -15..+30, speed max(its speed, Speed), target = you (it no longer hits you, can hit its shooter), tracer cleared | probe `wpr_ballcls Rocket`, `wpr_ballat "220 0 40 10"`, motion 3. 0: 5 rockets exploded 64-81 from you. 1: knocked at speed 20, blew up 180-335 from the crack, 254-414 from you (3 of 3 logged) |

### Not done / open
- The knocked rocket climbs at the clamp's 30 deg on the rig's overhead crack (the link sweeps up after the crack)
  and burst on the ceiling at z 256 on MAP01 (other crack styles not measured). Feel not headset-confirmed.
- Not on a headset. Feel: full crack 50, lasso reach 0.30 m, flail speed cap 30, smash damage is Grapple's thrown-body formula.
- The teardown's "SteamVR only" for the latch is wrong for this engine: QZD's own Quest input sets it (VrInputDefault.cpp
  130-141, off grip within 0.50 m, `vr_two_handed_weapons` true by default), and the rig latched. The position route
  covers the setting off, and a hand more than 0.50 m away that closes on the thong.
- (Fixed by the owner's answers above: the lift moving the mark; the follow-through yank, as the Yank Grace option.)
- A fireball explosion near you (a rocket) still hurts you; the missile keeps its shooter.

History: built inside RSQ_Grapple first (commit cc32dbc), then split out on the owner's word (10-30: "Grapple should stay
intact"): RSQ_Grapple is back to exactly what it was before; this mod carries its own copy of the line.

## What it is
- Thong: 20 links, Verlet, 8 sub-steps x 6 constraint passes a tic (3 sub-steps at rest), room units (map z x 1.2), mass
  falling to ~1/30 at the popper. A 24 cm rigid handle. Constants searched in tools/whipsim.py on rig-recorded hand paths.
- CRACK = the tip's speed passing rsqwp_whip_crack (20 room units/tic) with the hand having driven it lately; at the speed's
  peak. Fast outer links sting; the crack and its 8-tic lash land rsqwp_whip_damage and the Pain stun.
- Snag only on EDGES (lintel/beam underside, ledge lip, 3D floor top): a fast link striking one, or a crack within 12 units
  of one. The anchor goes on the corner; the existence check traces the struck face (hook.struck).
- Lock: the whip hand's +altattack (swallowed in InputProcess while a whip is out) holds a lock from the other hand
  (512 units, 7 deg); the crack flies there in 5 tics; bind held on a monster = leash (the line bites; slide to you).
- Line (forked core): swing, reel, stick pump, arm pump, climb, tap to let go with keepmomentum, mantle over a lip.

## Measured (standalone RSQ_Whip.pk3)
| what | result |
|---|---|
| slow motions | sweep +-40 deg over 4 s: 0 cracks; slow lift: 0 |
| thrown motions | overhead (4 throws): 6 cracks, crack hit imp 60 -> 48 + Pain; side-arm: 10 cracks, 1 hit |
| snag + mantle | WHIPTEST block from 30 units: snag on the lip, MANTLE from z 34 onto 96 |
| lock + leash | imp at 300: LOCKED crack 283 units, hit 60 -> 48 + Pain, LEASH, pulled in (13 pull logs) |
| with RSQ_Grapple + BD order | both load; whip cracks and hits; Grapple's off-hand hook fires, bites, pulls; only BD_VoxelPack's 4 voxeldef script errors |
| cost | 0.13-0.16 ms/tic out and still, 0.23-0.26 lashing (sim 0.12, sweeps 0.03, draw 0.03), desktop, BD order |
| measured before the split (same code, in Grapple) | beam swing kept on the corner anchor; arm pump +0.27 u/tic a haul; Assist hit/air crack; switch thrown by Assist and by Lock; save/load twice replays the same cracks |

## Open
- Feel, headset: crack speed 20, handle 24 cm, length 3.8 m, lock cone 7 deg, arm pump 0.12, mantle.
- Snag reach: scripted throws are chaotic (the same throw caught the block's lip from 30 units, not from 50+).
- Quest cost (Debug Log = Cost).
- No Gun Bonsai / RSQ_Score / TopHPBars hooks (RSQ_Grapple's service and perks were not forked): add a service if wanted.
- Left-handed mirror and the SteamVR two-hand latch not run.
