#!/usr/bin/env python3
"""TUNING ONLY (never ships): whip.zs's chain, line for line, in Python, driven by the same
keyframed hand motions as the rig probe (tools/rigtest/whipprobe), so the constants can be
searched in seconds instead of rig runs. Room units (34 a metre), Y up here; tics.

    python3 tools/whipsim.py            print tip-speed peaks for each motion with the defaults
"""
import math, sys

M = 34.0

K3 = [(0, 0.20, 1.35, -0.35, 10, 0), (9, 0.22, 1.80, -0.05, 85, 0), (12, 0.22, 1.82, -0.02, 95, 0),
      (15, 0.20, 1.40, -0.50, -15, 0), (22, 0.20, 1.30, -0.45, -20, 0), (70, 0.20, 1.35, -0.35, 10, 0)]
K4 = [(0, 0.20, 1.40, -0.40, 35, 0), (6, 0.20, 1.42, -0.40, 60, 0), (8, 0.20, 1.38, -0.42, -30, 0),
      (14, 0.20, 1.38, -0.42, -30, 0), (50, 0.20, 1.40, -0.40, 35, 0)]
K5 = [(0, 0.45, 1.30, -0.10, 0, -60), (8, 0.55, 1.35, 0.10, 5, -110), (11, 0.20, 1.35, -0.50, 0, 30),
      (16, 0.05, 1.30, -0.45, -5, 50), (70, 0.45, 1.30, -0.10, 0, -60)]
K6 = [(0, 0.20, 1.30, -0.35, 0, 0), (35, 0.20, 1.60, -0.35, 40, 0), (70, 0.20, 1.30, -0.35, 0, 0)]
K2 = [(t, 0.20, 1.35, -0.40, 5, 40 * math.sin(t * 2 * math.pi / 140)) for t in range(0, 141, 5)]
MOTIONS = {'overhead': K3, 'wrist': K4, 'sidearm': K5, 'slowlift': K6, 'sweep': K2}


def load_rec(path):
    """A rig recording (whipprobe wpr_log 2: T_H lines): the hand in map units from the pawn, yaw
    and pitch (AttackAngle+90-angle, AttackPitch). Returned as room-space poses per tic, X forward,
    Y up, Z left -- the sim's frame."""
    import re
    out = []
    for l in open(path):
        m = re.match(r'T_H t(\d+) hand\(([-\d.]+) ([-\d.]+) ([-\d.]+)\) yaw ([-\d.]+) pit ([-\d.]+)', l)
        if not m: continue
        x, y, z, yw, pt = [float(v) for v in m.groups()[1:]]
        pr, yr = math.radians(pt), math.radians(yw)
        out.append(((x, z * 1.2, y), (math.cos(pr) * math.cos(yr), math.sin(pr), math.cos(pr) * math.sin(yr))))
    return out


def pose(K, t):
    period = K[-1][0]
    tt = t % period
    for a, b in zip(K, K[1:]):
        if a[0] <= tt <= b[0]:
            u = (tt - a[0]) / (b[0] - a[0]) if b[0] > a[0] else 0
            v = [a[c] + (b[c] - a[c]) * u for c in range(1, 6)]
            break
    x, y, z, p, yw = v
    pos = (x * M, y * M, -z * M)          # forward = -stage z
    pr, yr = math.radians(p), math.radians(yw)
    d = (math.cos(pr) * math.sin(-yr) * -1, math.sin(pr), math.cos(pr) * math.cos(yr))
    # forward is +z here, right is +x; yaw positive turns left
    d = (-math.cos(pr) * math.sin(yr), math.sin(pr), math.cos(pr) * math.cos(yr))
    return pos, d


def add(a, b): return (a[0] + b[0], a[1] + b[1], a[2] + b[2])
def sub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def mul(a, s): return (a[0] * s, a[1] * s, a[2] * s)
def ln(a): return math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2])


def run(K, P, tics=140, warm=40, verbose=False):
    if isinstance(K, list) and K and isinstance(K[0][0], tuple):
        R = K
        def pz(t): return R[min(len(R) - 1, max(0, t))]
        tics = len(R)
    else:
        def pz(t): return pose(K, t)
    NN, SUB, ITER = P['NN'], P['SUB'], P['ITER']
    L, HAND, GRAV, DAMP, MAXSTEP = P['L'], P['HAND'], P['GRAV'], P['DAMP'], P['MAXSTEP']
    taper, tip, expo, stiff = P['taper'], P['tipm'], P['expo'], P['stiff']
    seg = L / NN
    inv = [0.0] + [1.0 / (((1 - taper * k / NN) ** expo) + tip) for k in range(1, NN + 1)]
    b, d = pz(0)
    a = add(b, mul(d, HAND))
    p = [add(a, (0, -seg * k, 0)) for k in range(NN + 1)]
    q = list(p)
    floor = 0.0
    hb, hd = b, d
    speeds = []
    for t in range(-warm, tics):
        b1, d1 = pz(max(0, t))
        best = 0
        for s in range(1, SUB + 1):
            u = s / SUB
            base = add(hb, mul(sub(b1, hb), u))
            dr = add(hd, mul(sub(d1, hd), u)); dl = ln(dr); dr = mul(dr, 1 / dl)
            anc = add(base, mul(dr, HAND))
            for k in range(1, NN + 1):
                v = mul(sub(p[k], q[k]), DAMP)
                vl = ln(v)
                if vl > MAXSTEP: v = mul(v, MAXSTEP / vl)
                q[k] = p[k]
                p[k] = add(add(p[k], v), (0, -GRAV / (SUB * SUB), 0))
            q[0] = p[0]; p[0] = anc
            for it in range(ITER):
                want = add(anc, mul(dr, seg))
                p[1] = add(p[1], mul(sub(want, p[1]), stiff))
                for k in range(NN):
                    dd = sub(p[k + 1], p[k]); l = ln(dd)
                    if l < 1e-4: continue
                    diff = (l - seg) / l
                    w0, w1 = inv[k], inv[k + 1]; sm = w0 + w1
                    p[k] = add(p[k], mul(dd, diff * w0 / sm))
                    p[k + 1] = sub(p[k + 1], mul(dd, diff * w1 / sm))
            for k in range(1, NN + 1):
                if p[k][1] < floor:
                    v = sub(p[k], q[k])
                    p[k] = (p[k][0], floor, p[k][2]); q[k] = (p[k][0] - v[0] * 0.6, floor, p[k][2] - v[2] * 0.6)
            sp = ln(sub(p[NN], q[NN])) * SUB
            best = max(best, sp)
        hb, hd = b1, d1
        if t >= 0: speeds.append(best)
    return speeds


DEF = dict(NN=20, SUB=8, ITER=6, L=128.0, HAND=8.0, GRAV=0.30, DAMP=0.9995, MAXSTEP=11.0, taper=0.85, tipm=0.02, expo=2.5, stiff=1.0)

if __name__ == '__main__':
    P = dict(DEF)
    for a in sys.argv[1:]:
        k, v = a.split('='); P[k] = type(DEF[k])(float(v)) if k in DEF else float(v)
    import glob, os
    recs = sorted(glob.glob('/home/claude/scratch/rec*.txt'))
    if recs: MOTIONS = {os.path.basename(r): load_rec(r) for r in recs}
    for name, K in MOTIONS.items():
        sp = run(K, P)
        print('%-9s peak %5.1f  (tics %s)' % (name, max(sp), ' '.join('%.0f' % s for s in sp[:30])))
