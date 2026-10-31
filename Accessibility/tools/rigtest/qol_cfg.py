#!/usr/bin/env python3
# TEST ONLY. Writes the console scripts for the QoL round's rig runs (tools/rigtest/qol.sh).
#   qol_cfg.py steady <out.cfg>   Steady Hands: the main hand held with tremor (3 mm at 6 Hz + 2 mm noise, 0.8 deg
#                                 + 0.3 deg noise on yaw and pitch, one new pose a frame), then a fast swing 0.6 m and
#                                 60 deg across in 5 frames, held with tremor again; then Steady Hands off and the same.
#                                 Then Seated Play: headset 1.62 m, 1.20 m (seated), 1.62 m again.
import math, random, sys

BASE = (0.25, 1.3, -0.3, -11.0, -30.0, 90.0)   # x y z pitch yaw roll (the brief's aim pose)


def pose(x, y, z, p, yaw, r):
    return f'qz_rhand "{x:.4f} {y:.4f} {z:.4f} {p:.2f} {yaw:.2f} {r:.1f}"; wait 1;'


def tremor_block(lines, n, x0, yaw0, t0):
    for i in range(n):
        t = (t0 + i) / 35.0
        tr = 0.003 * math.sin(2 * math.pi * 6 * t)
        lines.append(pose(x0 + tr + random.gauss(0, 0.002), BASE[1] + random.gauss(0, 0.002), BASE[2] + tr * 0.7,
                          BASE[3] + 0.8 * math.sin(2 * math.pi * 6 * t + 1) + random.gauss(0, 0.3),
                          yaw0 + 0.8 * math.sin(2 * math.pi * 6 * t) + random.gauss(0, 0.3), BASE[5]))
    return t0 + n


def steady(out):
    random.seed(7)
    L = ['rsqat_qol 1; rsqat_every 1000; wait 20;']
    for rnd, on in (("ON", 1), ("OFF", 0)):
        L.append(f'rsqa_steady {on}; netevent rsqat_mark {on}; echo STEADY_{rnd};')
        t = tremor_block(L, 70, BASE[0], BASE[4], 0)
        L.append(f'netevent rsqat_mark {10 + on}; echo SWING_{rnd};')
        for k in range(1, 6):
            f = k / 5
            L.append(pose(BASE[0] - 0.6 * f, BASE[1], BASE[2], BASE[3], BASE[4] + 60 * f, BASE[5]))
        L.append(f'netevent rsqat_mark {20 + on}; echo HOLD_{rnd};')
        tremor_block(L, 40, BASE[0] - 0.6, BASE[4] + 60, t)
        L.append(pose(*BASE))
        L.append('wait 10;')
    L.append('rsqa_steady 1; echo SEAT_STAND; qz_hmd "0 1.62 0 0 0 0"; wait 120;')
    L.append('echo SEAT_SIT; qz_hmd "0 1.20 0 0 0 0"; wait 200;')
    L.append('echo SEAT_UP; qz_hmd "0 1.62 0 0 0 0"; wait 150;')
    L.append('echo SEAT_FORCED; rsqa_seated 1; wait 20; rsqa_seated 0; wait 20; rsqa_seated 2;')
    L.append('echo TAPS; rsqa_slow_taps 1; wait 5; rsqa_slow_taps 0; wait 5;')
    L.append('rsqat_qol 0; quit')
    open(out, 'w').write(' '.join(L) + '\n')   # ONE line: a `wait` only delays the rest of its own line


if __name__ == '__main__':
    {'steady': steady}[sys.argv[1]](sys.argv[2])
