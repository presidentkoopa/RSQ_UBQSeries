#!/usr/bin/env python3
# TEST ONLY. Writes turn_rec*.txt console scripts for the turn probe: "Stick turns + recenter" (11-03 18:56).
#  recreach: the owner's case. Looking 90 deg right (and 20 down) while both hands reach out to that side (each hand
#            its own path and yaw), held 1 s, and back; once with snap turning (vr_snapTurn 45), once smooth (5).
#  recroom:  a real 90 deg turn left in the room (head and hands together): the torso stays; then both hands held to
#            the chest (the recenter pose, in the new facing) for 0.7 s: the torso snaps to the head; a snap right after;
#            then a real turn back to 0 and the bound key's command (rsqtr_recenter / ssq_recenter).
#  rechold:  seated (the chest holsters then reach the recenter pose), torso facing the head, poses that must NOT
#            recenter: one hand at a chest holster drawing (grip pressed and let go), both hands at the chest with a grip
#            held, both there only 0.3 s, both there with Use held, both hands in the two chest holsters (and in the pose)
#            1.1 s; then a real 60 deg turn and the real pose: recenters.
#  reclife:  a real 90 deg turn, then save + load (recentered), another 90, a level change to MAP02 (recentered), another
#            90, then death and the respawn (single player: the level restarts) (recentered).
# Stage space: metres, +x right, +y up, -z forward; yaw positive = left; qz_hmd pitch negative = looking down.
import math, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
def rot(x, z, th):
    t = math.radians(th)
    return x * math.cos(t) + z * math.sin(t), -x * math.sin(t) + z * math.cos(t)
def pose(cv, x, y, z, p, yw):
    return '%s "%.4f %.4f %.4f %.1f %.1f 0"; ' % (cv, x, y, z, p, yw)
def hands(th, r, l, hp=0.0, hy=None):
    # r, l: (x, y, z, pitch, yaw) of each hand in the frame facing th; the head at the origin facing hy (default th)
    s = pose('qz_hmd', 0, 1.6, 0, hp, th if hy is None else hy)
    rx, rz = rot(r[0], r[2], th); lx, lz = rot(l[0], l[2], th)
    return s + pose('qz_rhand', rx, r[1], rz, r[3], th + r[4]) + pose('qz_lhand', lx, l[1], lz, l[3], th + l[4])
READY_R = (0.25, 1.3, -0.3, 30, 0); READY_L = (-0.25, 1.3, -0.3, 30, 0)
# the recenter pose: controllers held against the sternum, 0.12 m in front of and 0.30 m under the eyes, 0.07 m either
# side of the centre, pointing up and in (as hands hold controllers flat to the chest)
CHEST_R = (0.07, 1.30, -0.12, 60, 30); CHEST_L = (-0.07, 1.30, -0.12, 60, -30)
def body(th): return hands(th, READY_R, READY_L)
PRE = 'god; notarget; wait 40; %swait 40; echo TRT_START; ' % body(0)
END = 'echo TRT_END; wait 10; quit\n'
def lerp(a, b, t): return tuple(x + (y - x) * t for x, y in zip(a, b))
def room(a, b, step=5):
    s, n = '', int(abs(b - a) / step)
    for k in range(1, n + 1): s += body(a + (b - a) * k / n) + 'wait 1; '
    return s
def reach_seq(tag):
    # look 90 right (yaw -90) and 20 down while both hands go out to the right: the right hand out and down to the right
    # hip's side, the left across the body to the right; each yaw its own; 20 tics out, 35 held, 20 back
    R1 = (0.45, 1.05, 0.05, -20, -95); L1 = (0.30, 1.15, -0.20, -10, -75)
    s = 'echo TRT_REACH_%s; ' % tag
    for k in range(1, 21):
        t = k / 20.0
        s += hands(0, lerp(READY_R, R1, t), lerp(READY_L, L1, t), -20 * t, -90 * t) + 'wait 1; '
    s += 'wait 35; '
    for k in range(19, -1, -1):
        t = k / 20.0
        s += hands(0, lerp(READY_R, R1, t), lerp(READY_L, L1, t), -20 * t, -90 * t) + 'wait 1; '
    return s + 'wait 30; '
def recreach():
    s = PRE + 'set vr_snapTurn 45; ' + reach_seq('SNAP')
    s += 'set vr_snapTurn 5; ' + reach_seq('SMOOTH') + 'set vr_snapTurn 45; '
    return s + END
def chest(th, n): return (hands(th, CHEST_R, CHEST_L) + 'wait 1; ') * n
def recroom():
    s = PRE + 'set vr_snapTurn 45; echo TRT_ROOM90; ' + room(0, 90) + 'wait 35; '
    s += 'echo TRT_RECENTER_GESTURE; ' + chest(90, 25) + body(90) + 'wait 20; '
    s += 'echo TRT_SNAP_AFTER; qz_rstick "1 0"; wait 6; qz_rstick "0 0"; wait 20; '
    s += 'echo TRT_ROOM_BACK; ' + room(90, 0) + 'wait 35; '
    s += 'echo TRT_KEY; rsqtr_recenter; ssq_recenter; wait 30; '
    return s + END
def rechold():
    # SEATED (rsqtr_seated 1): the rig hangs from the eyes (1.6 m here), so the chest holsters (0.46 under them, 0.12 to
    # each side, 0.10 forward) come within reach of the recenter pose: the hardest case. The torso faces the head.
    s = PRE + 'set vr_snapTurn 45; set rsqtr_seated 1; wait 10; '
    th = 0
    HOL_R = (0.12, 1.14, -0.10, 0, 0); SIDE_L = (-0.25, 0.95, 0.0, -70, 0)
    # both hands in both chest holsters AND within the recenter pose's 0.20 m: 0.10 to each side, 0.42 under the eyes
    IN_R = (0.10, 1.18, -0.10, 0, 0); IN_L = (-0.10, 1.18, -0.10, 0, 0)
    s += 'echo TRT_HOLSTER_ONE_HAND; '
    for k in range(40):
        if k == 12: s += 'netevent rsqtr_grip 0 1; '
        if k == 20: s += 'netevent rsqtr_grip 0 0; '
        s += hands(th, HOL_R, SIDE_L) + 'wait 1; '
    s += body(th) + 'wait 15; echo TRT_CHEST_GRIP_HELD; netevent rsqtr_grip 1 1; ' + chest(th, 30) + 'netevent rsqtr_grip 1 0; ' + body(th) + 'wait 15; '
    s += 'echo TRT_CHEST_SHORT; ' + chest(th, 10) + body(th) + 'wait 15; '
    s += 'echo TRT_CHEST_USE_HELD; +use; ' + chest(th, 30) + '-use; ' + body(th) + 'wait 15; '
    s += 'echo TRT_BOTH_CHEST_HOLSTERS; ' + (hands(th, IN_R, IN_L) + 'wait 1; ') * 40 + body(th) + 'wait 15; '
    s += 'echo TRT_ROOM60; ' + room(0, 60) + 'wait 30; '
    s += 'echo TRT_CHEST_POSE; ' + chest(60, 25) + body(60) + 'wait 20; set rsqtr_seated 0; '
    return s + END
def reclife():
    s = PRE + 'set vr_snapTurn 45; echo TRT_ROOM90A; ' + room(0, 90) + 'wait 20; '
    s += 'echo TRT_SAVELOAD; save rsqtr_rectest; wait 20; load rsqtr_rectest; wait 40; '
    s += 'echo TRT_ROOM90B; ' + room(90, 180) + 'wait 20; '
    # a level change with no intermission (the probe's trt_nextmap: Level.ChangeLevel MAP02, CHANGELEVEL_NOINTERMISSION):
    # the tally screen waits for a press the console script cannot time
    s += 'echo TRT_MAPCHANGE; netevent trt_nextmap; wait 60; '
    s += 'echo TRT_ROOM90C; ' + room(180, 270) + 'wait 20; '
    s += 'echo TRT_RESPAWN; god; kill; wait 70; +use; wait 3; -use; wait 60; '
    return s + END
for n, f in (('recreach', recreach), ('recroom', recroom), ('rechold', rechold), ('reclife', reclife)):
    if len(sys.argv) > 1 and sys.argv[1] not in (n, 'all'): continue
    open(os.path.join(HERE, 'turn_%s.txt' % n), 'w').write(f())
