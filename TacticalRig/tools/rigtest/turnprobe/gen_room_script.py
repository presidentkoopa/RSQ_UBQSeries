#!/usr/bin/env python3
# TEST ONLY. Writes turn_rm*.txt console scripts for the turn probe: "Torso Follows Room Turns" (rsqtr_body_room, 11-03
# 19:31, the owner: "if i physically stand and turn, it stays in place"; his pick: smart catch-up).
#  rmmeasure: poses held still, the head facing the torso, for the probe's trc line (each hand from the neck, its angle
#             off the look, its height from the eyes): gun-ready, chest, two-hand long gun low and aimed, the owner's
#             reach, a hip-holster draw, both chest holsters.
#  rmroom:    (a) real turns in the room holding a gun: 90 left at 5 deg/tic with the gun at the ready, held 3 s; back
#             90 right; 90 left with a two-hand long gun; 90 right slowly (1.5 deg/tic); then a snap (exact?).
#  rmreach:   (b) the owner's case held 3.4 s: both hands out 75-95 deg to the right while looking 90 there, 20 down
#             (gen_rec_script's reach) and level; both hands down at the right hip; the reach again with smooth turning.
#  rmglance:  (c) a look 60 left and 90 right with the hands in front of the head for 1.3 s (under 1.5 s), back; a look
#             75 left held 3 s with the hands left in front of the torso (a head-only look).
#  rmdraw:    (d) a draw from the right hip holster while looking 60 there (level, then 20 down), the other hand in front
#             of the head, the grip pressed and let go, held 3.4 s; a draw from the right chest holster, looking 50 there.
#  rmany:     11-05 00:57 (the owner, PCVR: "when I turn my actual body in real life the rig does not adjust"; his pick
#             "Hands anywhere but a holster"), everything in one run: real 90 turns left and back with the hands (a)
#             lowered at the sides, (b) at the hips, (c) at the ready, (d) one ready one hanging; (e) the owner's reach
#             (20 down and level); (f) a hip-holster draw looking 60 there; (g) glances 60 / 90 aside for 1.3 s with the
#             hands lowered and at the ready; then 8 snaps right (360).
# Stage space: metres, +x right, +y up, -z forward; yaw positive = left; qz_hmd pitch negative = looking down.
# The standing rig hangs from the pawn's view height (41 units = 1.447 m), the hands from the room floor.
import math, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
def rot(x, z, th):
    t = math.radians(th)
    return x * math.cos(t) + z * math.sin(t), -x * math.sin(t) + z * math.cos(t)
def pose(cv, x, y, z, p, yw):
    return '%s "%.4f %.4f %.4f %.1f %.1f 0"; ' % (cv, x, y, z, p, yw)
def hands(th, r, l, hp=0.0, hy=None, lth=None):
    # r, l: (x, y, z, pitch, yaw) of each hand in the frame facing th (the left hand in lth's, if given); the head at the
    # origin facing hy (default th)
    s = pose('qz_hmd', 0, 1.6, 0, hp, th if hy is None else hy)
    lt = th if lth is None else lth
    rx, rz = rot(r[0], r[2], th); lx, lz = rot(l[0], l[2], lt)
    return s + pose('qz_rhand', rx, r[1], rz, r[3], th + r[4]) + pose('qz_lhand', lx, l[1], lz, l[3], lt + l[4])
READY_R = (0.25, 1.3, -0.3, 30, 0); READY_L = (-0.25, 1.3, -0.3, 30, 0)
CHEST_R = (0.07, 1.30, -0.12, 60, 30); CHEST_L = (-0.07, 1.30, -0.12, 60, -30)
# a two-hand long gun: the main hand at the grip by the chest, the off hand on the fore-end ahead of it; low ready and aimed
LONG_R = (0.10, 1.36, -0.22, 0, 0); LONG_L = (0.00, 1.38, -0.55, 0, 0)
AIM_R = (0.08, 1.45, -0.30, 0, 0); AIM_L = (0.02, 1.47, -0.62, 0, 0)
# the owner's reach (gen_rec_script.py reach_seq): head 90 right and 20 down
REACH_R = (0.45, 1.05, 0.05, -20, -95); REACH_L = (0.30, 1.15, -0.20, -10, -75)
# both hands down at the right hip
HIP_R = (0.30, 0.80, 0.05, -40, -90); HIP_L = (0.15, 0.85, -0.10, -40, -60)
# the right hip holster (torso frame: 0 forward, 0.18 right, 0.70 under the 1.447 m view height) and the right chest one
HOLHIP_R = (0.18, 0.75, 0.0, -60, 0); HOLCH_R = (0.12, 0.99, -0.10, 0, 0)
HOLCH_L = (-0.12, 0.99, -0.10, 0, 0)
# hands lowered at the sides (hanging), at the hips, one ready one hanging (11-05)
LOW_R = (0.24, 0.82, 0.00, -80, 0); LOW_L = (-0.24, 0.82, 0.00, -80, 0)
HIPS2_R = (0.20, 0.95, 0.02, -60, 0); HIPS2_L = (-0.20, 0.95, 0.02, -60, 0)
def body(th): return hands(th, READY_R, READY_L)
PRE = 'god; notarget; wait 40; %swait 40; echo TRT_START; set vr_snapTurn 45; ' % body(0)
END = 'echo TRT_END; wait 10; quit\n'
def lerp(a, b, t): return tuple(x + (y - x) * t for x, y in zip(a, b))
def room(a, b, step=5.0, r=READY_R, l=READY_L):
    s, n = '', max(1, int(round(abs(b - a) / step)))
    for k in range(1, n + 1): s += hands(a + (b - a) * k / n, r, l) + 'wait 1; '
    return s
def held(n, txt): return (txt + 'wait 1; ') * n
def rmmeasure():
    s = PRE
    for tag, txt in (('READY', body(0)), ('CHEST', hands(0, CHEST_R, CHEST_L)), ('LONGGUN', hands(0, LONG_R, LONG_L)),
                     ('AIMED', hands(0, AIM_R, AIM_L)), ('REACH', hands(0, REACH_R, REACH_L, -20, -90)),
                     ('HIPS', hands(0, HIP_R, HIP_L, -20, -90)), ('HIPDRAW', hands(0, HOLHIP_R, READY_L, 0, -60, -60)),
                     ('CHESTHOLSTERS', hands(0, HOLCH_R, HOLCH_L))):
        s += 'echo TRT_M_%s; ' % tag + held(20, txt)
    return s + END
def rmroom():
    s = PRE + 'echo TRT_ROOM90L; ' + room(0, 90) + 'wait 105; '
    s += 'echo TRT_ROOM90R_BACK; ' + room(90, 0) + 'wait 105; '
    s += 'echo TRT_ROOM90L_LONGGUN; ' + hands(0, LONG_R, LONG_L) + 'wait 10; ' + room(0, 90, 5, LONG_R, LONG_L) + 'wait 105; '
    s += 'echo TRT_ROOM90R_SLOW; ' + room(90, 0, 1.5) + 'wait 105; '
    s += 'echo TRT_SNAP_AFTER; qz_rstick "1 0"; wait 6; qz_rstick "0 0"; wait 30; '
    return s + END
def reach(tag, R, L, hp, hold):
    s = 'echo TRT_%s; ' % tag
    for k in range(1, 21):
        t = k / 20.0
        s += hands(0, lerp(READY_R, R, t), lerp(READY_L, L, t), hp * t, -90 * t) + 'wait 1; '
    s += 'wait %d; ' % hold
    for k in range(19, -1, -1):
        t = k / 20.0
        s += hands(0, lerp(READY_R, R, t), lerp(READY_L, L, t), hp * t, -90 * t) + 'wait 1; '
    return s + 'wait 30; '
def rmreach():
    s = PRE + reach('REACH_DOWN20', REACH_R, REACH_L, -20, 120) + reach('REACH_LEVEL', REACH_R, REACH_L, 0, 120)
    s += reach('HIPS', HIP_R, HIP_L, -20, 120)
    s += 'set vr_snapTurn 5; ' + reach('REACH_SMOOTH', REACH_R, REACH_L, -20, 120) + 'set vr_snapTurn 45; wait 10; '
    return s + END
def glance(tag, hy, n):
    s = 'echo TRT_%s; ' % tag
    for k in range(1, 9): s += hands(hy * k / 8.0, READY_R, READY_L) + 'wait 1; '
    s += 'wait %d; ' % n
    for k in range(7, -1, -1): s += hands(hy * k / 8.0, READY_R, READY_L) + 'wait 1; '
    return s + 'wait 40; '
def rmglance():
    s = PRE + glance('GLANCE60L_1.3S', 60, 37) + glance('GLANCE90R_1.3S', -90, 37)
    s += 'echo TRT_LOOK75L_HANDS_AT_TORSO; '
    for k in range(1, 9): s += hands(0, READY_R, READY_L, 0, 75 * k / 8.0) + 'wait 1; '
    s += 'wait 105; '
    for k in range(7, -1, -1): s += hands(0, READY_R, READY_L, 0, 75 * k / 8.0) + 'wait 1; '
    return s + 'wait 30; ' + END
def draw(tag, R, hy, hp, hold):
    # the drawing hand in the torso's frame (facing 0), the other hand in front of the head (facing hy)
    s = 'echo TRT_%s; ' % tag
    for k in range(1, 11):
        t = k / 10.0
        s += hands(0, lerp(READY_R, R, t), READY_L, hp * t, hy * t, hy * t) + 'wait 1; '
    for k in range(hold):
        if k == 30: s += 'netevent rsqtr_grip 0 1; '
        if k == 40: s += 'netevent rsqtr_grip 0 0; '
        s += hands(0, R, READY_L, hp, hy, hy) + 'wait 1; '
    for k in range(9, -1, -1):
        t = k / 10.0
        s += hands(0, lerp(READY_R, R, t), READY_L, hp * t, hy * t, hy * t) + 'wait 1; '
    return s + 'wait 30; '
def rmdraw():
    s = PRE + draw('HIPDRAW_LEVEL', HOLHIP_R, -60, 0, 120) + draw('HIPDRAW_DOWN20', HOLHIP_R, -60, -20, 120)
    s += draw('CHESTDRAW_LOOK50', HOLCH_R, -50, 0, 120)
    return s + END
def rmany():
    s = PRE
    for tag, R, L in (('LOWERED', LOW_R, LOW_L), ('HIPS', HIPS2_R, HIPS2_L), ('READY', READY_R, READY_L), ('READY_HANGING', READY_R, LOW_L)):
        s += 'echo TRT_ANY_POSE_%s; ' % tag + held(30, hands(0, R, L))
        s += 'echo TRT_ROOM90L_%s; ' % tag + room(0, 90, 5, R, L) + 'wait 105; '
        s += 'echo TRT_ROOM90R_BACK_%s; ' % tag + room(90, 0, 5, R, L) + 'wait 105; '
    s += 'echo TRT_ANY_POSE_READY2; ' + held(30, body(0))
    s += reach('REACH_DOWN20', REACH_R, REACH_L, -20, 120) + reach('REACH_LEVEL', REACH_R, REACH_L, 0, 120)
    s += draw('HIPDRAW_LEVEL', HOLHIP_R, -60, 0, 120)
    s += glance('GLANCE60L_1.3S_READY', 60, 37) + glance('GLANCE90R_1.3S_READY', -90, 37)
    s += 'echo TRT_GLANCE_LOWERED; ' + held(20, hands(0, LOW_R, LOW_L))
    for tag, hy in (('GLANCE60L_1.3S_LOWERED', 60), ('GLANCE90R_1.3S_LOWERED', -90)):
        s += 'echo TRT_%s; ' % tag
        for k in range(1, 9): s += hands(hy * k / 8.0, LOW_R, LOW_L) + 'wait 1; '
        s += 'wait 37; '
        for k in range(7, -1, -1): s += hands(hy * k / 8.0, LOW_R, LOW_L) + 'wait 1; '
        s += 'wait 40; '
    s += 'echo TRT_SNAPS8; ' + held(10, body(0))
    for k in range(8): s += 'qz_rstick "1 0"; wait 6; qz_rstick "0 0"; wait 20; '
    return s + 'wait 20; ' + END
for n, f in (('rmany', rmany), ('rmmeasure', rmmeasure), ('rmroom', rmroom), ('rmreach', rmreach), ('rmglance', rmglance), ('rmdraw', rmdraw)):
    if len(sys.argv) > 1 and sys.argv[1] not in (n, 'all'): continue
    open(os.path.join(HERE, 'turn_%s.txt' % n), 'w').write(f())
