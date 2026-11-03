#!/usr/bin/env python3
"""pose.py -- the qz_* cvar strings for the Windows TestRig (the fake OpenVR runtime, -qzfake).

    python TestRig/pose.py hand  F L U [pitch yaw roll]   a hand at F forward, L left, U up of the EYE, in cm
    python TestRig/pose.py hmd   [x y z pitch yaw roll]   the head (stage space, metres / degrees)
    python TestRig/pose.py level                           the defaults that aim the main-hand weapon level

Stage space is OpenVR's: +X right, +Y up, -Z forward, metres; pitch about +X (positive = up), yaw about +Y
(positive = left), roll about -Z. The eye is at (0, 1.6, 0) by default (qz_hmd). A hand pitch of +30 aims the
weapon level, because the engine applies vr_weaponRotate (-30) to the raw controller pose. Prints one line you
can pass to the runner: qz_rhand "x y z p y r".
"""
import sys

EYE = (0.0, 1.6, 0.0)

def hand(F, L, U, pitch=30.0, yaw=0.0, roll=0.0):
    return f'{EYE[0] - L / 100:.4f} {EYE[1] + U / 100:.4f} {EYE[2] - F / 100:.4f} {pitch:g} {yaw:g} {roll:g}'

def main(a):
    if not a or a[0] == 'level':
        print('qz_hmd "0 1.6 0 0 0 0"'); print('qz_rhand "0.25 1.3 -0.3 30 0 0"'); print('qz_lhand "-0.25 1.3 -0.3 30 0 0"'); return
    if a[0] == 'hand':
        v = list(map(float, a[1:]))
        print('"' + hand(*v) + '"'); return
    if a[0] == 'hmd':
        v = list(map(float, a[1:])) + [0] * 6
        print('"' + ' '.join(f'{x:g}' for x in v[:6]) + '"'); return
    print(__doc__)

if __name__ == '__main__':
    main(sys.argv[1:])
