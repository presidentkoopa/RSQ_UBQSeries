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
    AIM    qz_rhand "0.25 1.3 -0.3 15 -30 90"   palm out, ~13 deg down, straight ahead
    FLICK  pitch 15 -> 2 -> -12 over two tics (hand tips UP ~13 deg/tic), then roll 0
    CATCH  back to AIM
Left hand mirror: qz_lhand "-0.25 1.3 -0.3 15 30 -90". Walk: qz_lstick "0 1".

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
