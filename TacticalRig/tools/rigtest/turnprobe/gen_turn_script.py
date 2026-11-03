#!/usr/bin/env python3
# TEST ONLY. Writes turn_<name>.txt console scripts for the turn probe (11-03).
#  snap:   8 snap turns right, then 8 left (QuestZDoom's own snap turn, the right stick past 0.6), head and hands still.
#  smooth: vr_snapTurn 5 (smooth), right stick held until the pawn has turned about 360, then left back.
#  room:   a real turn in the room: head AND both hands (hands forward) rotate together about the head, 5 deg a tic,
#          360 left, a 1 s hold, 360 right.
#  room2:  a real turn as a body makes it: the head leads by 4 tics, the hands follow, each wandering +-3 deg.
#  snapj:  the 8 + 8 snaps with a live head and hands: the head's yaw and pitch and each hand's yaw wander (a few
#          degrees, out of step, never still) and the hands drift a few cm, as a person standing does.
#  smoothj: the smooth 360 and back with that same wander.
#  lookj:  looking down 50 deg at the right hip, the head sweeping +-60 for 4 s while the right hand reaches about the
#          holster (+-8 cm, its yaw swinging +-40) and the left hand wanders: the body must not turn; then two snaps
#          right while still looking down: the body turns by exactly each.
#  look:   looking down 50 deg at the right hip holster (right hand there), turning the head +-60 for 4 s, left hand
#          forward: the body must not turn; then a level head look 60 left held 0.5 s and back (no turn).
# Stage space: metres, +x right, +y up, -z forward; yaw positive = left; qz_hmd pitch negative = looking down.
import math, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
def rot(x, z, th):
    t = math.radians(th)
    return x * math.cos(t) + z * math.sin(t), -x * math.sin(t) + z * math.cos(t)
def pose(cv, x, y, z, p, yw):
    return '%s "%.4f %.4f %.4f %.1f %.1f 0"; ' % (cv, x, y, z, p, yw)
def body(th, hp=0.0):
    # head at the origin, hands 0.25 to the side, 0.3 forward, both rotated by th about the head
    s = pose('qz_hmd', 0, 1.6, 0, hp, th)
    rx, rz = rot(0.25, -0.3, th); lx, lz = rot(-0.25, -0.3, th)
    s += pose('qz_rhand', rx, 1.3, rz, 30, th) + pose('qz_lhand', lx, 1.3, lz, 30, th)
    return s
PRE = 'god; notarget; wait 40; %swait 40; echo TRT_START; ' % body(0)
def snap():
    s = PRE + 'set vr_snapTurn 45; qz_rstick "0 0"; wait 10; '
    for d, x in (('R', 1), ('L', -1)):
        for i in range(8):
            s += 'echo TRT_SNAP_%s%d; qz_rstick "%d 0"; wait 6; qz_rstick "0 0"; wait 16; ' % (d, i + 1, x)
    return s + 'echo TRT_END; wait 10; quit\n'
def smooth_n(n):
    s = PRE + 'set vr_snapTurn 5; echo TRT_SMOOTH_R; qz_rstick "1 0"; wait %d; qz_rstick "0 0"; wait 30; ' % n
    s += 'echo TRT_SMOOTH_L; qz_rstick "-1 0"; wait %d; qz_rstick "0 0"; wait 30; ' % n
    return s + 'set vr_snapTurn 45; echo TRT_END; wait 10; quit\n'
# the smooth turn's speed is per rendered frame: about 360 degrees takes ~30 tics at 90 fps, ~72 at 35 fps
def smooth(): return smooth_n(30)
def smooth35(): return smooth_n(72)
def room():
    s = PRE + 'echo TRT_ROOM_L; '
    for k in range(1, 73): s += body(5 * k) + 'wait 1; '
    s += 'wait 35; echo TRT_ROOM_R; '
    for k in range(71, -1, -1): s += body(5 * k) + 'wait 1; '
    return s + 'wait 35; echo TRT_END; wait 10; quit\n'
def room2():
    # a real turn as a body makes it: the head leads by 4 tics (20 deg), the hands follow the body at 5 deg a tic, each
    # wandering +-3 deg around it (out of step), 360 left, a 1 s hold, 360 back
    def at(hd, r, l):
        s = pose('qz_hmd', 0, 1.6, 0, 0, hd)
        rx, rz = rot(0.25, -0.3, r); lx, lz = rot(-0.25, -0.3, l)
        return s + pose('qz_rhand', rx, 1.3, rz, 30, r) + pose('qz_lhand', lx, 1.3, lz, 30, l)
    s = PRE
    for d, sg in (('L', 1), ('R', -1)):
        s += 'echo TRT_ROOM2_%s; ' % d
        base = 0 if sg > 0 else 360
        for k in range(1, 81):
            hd = min(5 * k, 360); b = min(max(5 * (k - 4), 0), 360)
            r = b + 3 * math.sin(k / 3.0) * (0 < b < 360); l = b - 3 * math.sin(k / 4.0 + 1) * (0 < b < 360)
            s += at(base + sg * hd, base + sg * r, base + sg * l) + 'wait 1; '
        s += 'wait 35; '
    return s + 'echo TRT_END; wait 10; quit\n'
def look():
    s = PRE + 'echo TRT_LOOK_DOWN_HIP; '
    lx, lz = -0.25, -0.3
    for k in range(140):
        yw = 60 * math.sin(2 * math.pi * k / 70.0)
        s += pose('qz_hmd', 0, 1.6, 0, -50, yw) + pose('qz_rhand', 0.20, 0.92, 0.02, -60, 10) + pose('qz_lhand', lx, 1.3, lz, 30, 0) + 'wait 1; '
    s += body(0) + 'wait 20; echo TRT_LOOK_LEVEL_60; ' + pose('qz_hmd', 0, 1.6, 0, 0, 60) + 'wait 17; ' + pose('qz_hmd', 0, 1.6, 0, 0, 0) + 'wait 30; '
    return s + 'echo TRT_END; wait 10; quit\n'
def wander(k, ph):
    # a live pose's wander, degrees: slow sway plus a quicker tremor, out of step per part (ph)
    return 3.0 * math.sin(k / 23.0 + ph) + 0.8 * math.sin(k / 3.7 + 2 * ph) + 0.3 * math.sin(k * 1.3 + ph)
def live(k, th):
    hy = th + wander(k, 0.0); hp = 2.0 * math.sin(k / 31.0)
    s = pose('qz_hmd', 0.01 * math.sin(k / 19.0), 1.6, 0.01 * math.sin(k / 27.0), hp, hy)
    ry = th + wander(k, 1.7); ly = th + wander(k, 3.1)
    rx, rz = rot(0.25 + 0.03 * math.sin(k / 17.0), -0.3 + 0.02 * math.sin(k / 13.0), th)
    lx, lz = rot(-0.25 + 0.03 * math.sin(k / 15.0 + 1), -0.3 + 0.02 * math.sin(k / 11.0 + 2), th)
    return s + pose('qz_rhand', rx, 1.3, rz, 30 + 5 * math.sin(k / 9.0), ry) + pose('qz_lhand', lx, 1.3, lz, 30 + 5 * math.sin(k / 10.0), ly)
def snapj():
    s = PRE + 'set vr_snapTurn 45; qz_rstick "0 0"; wait 10; '
    k = 0
    for d, x in (('R', 1), ('L', -1)):
        for i in range(8):
            s += 'echo TRT_SNAP_%s%d; ' % (d, i + 1)
            for t in range(22):
                if t == 0: s += 'qz_rstick "%d 0"; ' % x
                if t == 6: s += 'qz_rstick "0 0"; '
                s += live(k, 0) + 'wait 1; '; k += 1
    return s + 'echo TRT_END; wait 10; quit\n'
def smoothj():
    s = PRE + 'set vr_snapTurn 5; '
    k = 0
    for d, x in (('R', 1), ('L', -1)):
        s += 'echo TRT_SMOOTH_%s; ' % d
        for t in range(60):
            if t == 0: s += 'qz_rstick "%d 0"; ' % x
            if t == 30: s += 'qz_rstick "0 0"; '
            s += live(k, 0) + 'wait 1; '; k += 1
    return s + 'set vr_snapTurn 45; echo TRT_END; wait 10; quit\n'
def lookj():
    s = PRE + 'echo TRT_LOOK_DOWN_HIP; '
    for k in range(140):
        yw = 60 * math.sin(2 * math.pi * k / 70.0)
        rx = 0.20 + 0.08 * math.sin(k / 7.0); rz = 0.02 + 0.08 * math.sin(k / 5.0)
        s += pose('qz_hmd', 0, 1.6, 0, -50 + 5 * math.sin(k / 11.0), yw) + pose('qz_rhand', rx, 0.92, rz, -60, 10 + 40 * math.sin(k / 6.0))
        lx, lz = -0.25 + 0.04 * math.sin(k / 9.0), -0.3 + 0.04 * math.sin(k / 8.0)
        s += pose('qz_lhand', lx, 1.3, lz, 30, wander(k, 3.1)) + 'wait 1; '
    s += 'set vr_snapTurn 45; '
    for i in range(2):
        s += 'echo TRT_LOOK_DOWN_SNAP%d; qz_rstick "1 0"; wait 4; qz_rstick "0 0"; wait 16; ' % (i + 1)
    s += body(0) + 'wait 20; '
    return s + 'echo TRT_END; wait 10; quit\n'
for n, f in (('snap', snap), ('snapj', snapj), ('smoothj', smoothj), ('lookj', lookj), ('smooth', smooth), ('smooth35', smooth35), ('room', room), ('room2', room2), ('look', look)):
    if len(sys.argv) > 1 and sys.argv[1] not in (n, 'all'): continue
    open(os.path.join(HERE, 'turn_%s.txt' % n), 'w').write(f())
