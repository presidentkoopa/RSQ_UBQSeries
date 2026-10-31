# tools/rigtest — exercising the grab in the real engine (TEST ONLY, never ships)

Uses the RSQ_WeaponDepot rig (`tools/rig/bin`): QuestZDoom for Linux on the
OpenXR path, with the headset and controllers posed from console cvars. Caveat:
that prebuilt engine is an **earlier 17.x (ZScript 4.12)**, not the 17.3 tag —
see docs/DECISIONS.md. Freedoom 2 works as the IWAD.

The probe (`probe/`) is a separate pk3 that watches the grab only through its
public doors: it is a `GrabEventService` (prints `T_EVENT`), it logs every
`RSQDG_Buzz` spawn and whether it is a missile (`T_BUZZ`), and every tic prints
the hand pose and the grab's state (`T_STATE`) plus, for each object it spawned,
every test the cone applies (`T_OBJ`: range, angle, policy rule, sight, kg).
`rsqdgt_scene "Class:dist:side,..."` spawns objects in front of the player on
tic 20, after turning to the longest clear heading.

`GDB=1` runs under gdb with a breakpoint on `QzDoom_Vibrate` that prints
`T_VIBRATE dur chan amp` (args read from xmm0 / edi / xmm1 — the binary has
symbols but no debug info). Channel 1 = right, 0 = left.

## Poses that work (right hand; vr_weaponRotate -30 is applied after the roll)
    AIM    qz_rhand "0.25 1.3 -0.3 -11 -30 90"  palm out, ~10 deg down, straight ahead
    FLICK  pitch -11 -> 2 -> 15 over two tics (hand tips UP ~13 deg/tic), then roll 0
(Corrected 2026-10-26 with the pitch-sign fix: the old AIM "15 -30 90" pointed
~13 deg UP, and the old FLICK 15 -> -12 tipped the hand DOWN; the mirrored grab
read both the other way round. Ground truth: the pistol's puffs.)
    CATCH  back to AIM
Left hand mirror: qz_lhand "-0.25 1.3 -0.3 -11 30 -90". Walk: qz_lstick "0 1".

## The checks run on 2026-10-26 (all pass)
    clip pull + catch-and-use     lock t30, launch t47, catch t62; 4 buzzes = 4 vibrates
    barrel vs nearer clip         barrel chosen (weight 4 vs 0.6); 60 kg, share 0.14, 4.5 m/s
    barrel catch                  held, double tick; pings 13/11/10 tics apart then quiet
    policy                        HealthBonus/TechLamp/Soulsphere refused; switch flips sphere
    off hand                      lock vibrates chan 0
    missed catch                  pull.missed, dropped
    walk then open hand           0.0 m/s -> hold.drop   (world-frame code threw it)
    jerk hand then open           10.5 m/s -> hold.throw
    save mid-flight, load         pull completes, no errors

## Round 2 checks (2026-10-26, ultimate grab) -- all pass
Timing: console `wait N` counts GAME TICS (measured: marks at t33/68/103 for
waits of 35). The flick only launches on the RELEASE that follows it (palm roll
back within ~7 tics), so a pull is: AIM, wait, FLICK (pitch 2, -12), roll 0,
wait 2, AIM to catch. A probe cannot set `qz_rhand` itself: engine cvars refuse
`SetString` outside menu code (VM abort), so poses are scripted with `wait`.

    rumble route (gdb)       330 quake writes, amp 0.00..1.00, none negative,
                             main hand only; lock 0.18, launch 0.75, flight
                             0.14->0.34 with 0.60 ramp ticks, quiet, catch 1.00
    pulse route (gdb)        rsqdg_rumble 0: 7 x 150 ms vibrates, 0 quake writes
    spring carry             barrel settles 0.59 m ahead of palm; strain
                             0.59 -> 0.00 in ~16 tics; burden 0.67
    pin + break              rsqdg_hold_dist 30: barrel pinned at the wall,
                             strain 25 m, rumble 0.6, let go at tic 18
    weighted throw           forward hand ~7 m/s -> barrel 2.3 m/s, clip 8.1 m/s
    impact                   clip hit ShotgunGuy at 8.9 m/s for 1 (overlap path)
    explode                  barrel at hand height: no (6 m/s threshold, gravity-
                             corrected); BD22 ExplosiveBarrel1 at threshold 2:
                             went off at 4.1 m/s (replacee chain)
    save/load mid-carry      carry and burden continue; release clears burden
    glow                     frame dumps: green twin over the locked barrel
    BD22 load order          no script errors from this pack

## Round 3 checks (2026-10-26, polish branch) -- all pass
    G1 saber hilt         saber lit: palmok 0; douse: lock; relight: busy again
    G2 dwell 20           lock t41 (t21 without)
    G6 beam yield         laser on pistol: main grab beam hidden, off shown
    G3 arc                barrel 210u: 16 tics at apex 1 m (room 68 midway)
    G6 dot-only laser     rsqls_beam 0: grab beam comes back
    regression            grab+laser+shield+saber, both orders: no errors

## Pitch-sign fix (2026-10-26) -- all pass
    aimed 9 deg down at a floor barrel   locks it (before: nothing)
    aimed 9 deg up                       no target (before: took the floor barrel)
    corrected AIM + upward FLICK         lock t21, launch t47, caught t91
    downward flick                       no pull; palm roll back just unlocks

## Owner picks 19-24 (2026-10-31): picks_gen.py + picks_rig.sh, doom2 + BD order
Probe additions: `rsqdgt_net "tic:name:a1:a2;..."` sends a network event that tic, and the console's own
`netevent rsqdg_ngrip <hand> <1|0>` presses/releases a grip (what near.zs's InputProcess sends), so the
walk-up grab and the Headlock run on the rig. `rsqdgt_switch <tic>` puts the right palm 3 units in front of the
nearest Use-special line that is not a manual door. `T_MON` prints each spawned monster's health, freezetics and
pain. (`rsqdgt_poses` still cannot work: qz_rhand refuses SetString outside menu code.)

    19 swing     walk-up barrel swept across a HellKnight: "swung BarrelVOX hit HellKnight2 at 5.1 m/s for 51",
                 hp 500 -> 449, pushed; one hit per sweep (the barrel stays inside it for several tics)
    23 collar    Headlock (netevent), wind-up + fast forward: "threw PistolZombie at 2.4 m/s (300 kg)", hit the
                 HellKnight for 56 (and its BD headshot helper for 56), and took 56 itself
    24 2-tic     a stale rig frame: "hand 2-tic 10.5, 1-tic peak 21.0" -- the old reading doubled the throw
    22 hit-stop  rsqdg_hitstop 4: Cacodemon frz 4,3,2 standing still with vel 13.2 waiting
    21 switch    roll 0 on the line: nothing for 40 tics; roll 96: "palm on switch line 3 (special 11): flipped"
