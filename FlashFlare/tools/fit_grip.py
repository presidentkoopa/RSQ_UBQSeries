#!/usr/bin/env python3
"""fit_grip.py -- where a cylinder sits in a hand pose (MEASURE ONLY). The owner's rule (11-03 19:25): BD22 VR's FBX hand poses
hold tools as cylinders. For every axis on a hemisphere (5 degree steps) the finger part of the hand (md3 x > xmin) is
projected on the plane across that axis; the cylinder is the widest empty circle there that the hand wraps round
(points in at least COVER of 24 directions within 2.5 cm outside it). Prints the best axis, centre and radius.
    [NEAR=x] python3 -I tools/fit_grip.py <hand.md3> [frame] [xmin]"""
import sys, os, math
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_flare import read_md3
COVER = 0.62
NEAR = os.environ.get('NEAR')   # 'x', 'y' or 'z': only axes within 35 degrees of that one
s, n = read_md3(open(sys.argv[1], 'rb').read())
fr = int(sys.argv[2]) if len(sys.argv) > 2 else 0
xmin = float(sys.argv[3]) if len(sys.argv) > 3 else -3.0
P = np.array([p for x in s for p, _ in x['frames'][fr]])
P = P[P[:, 0] > xmin]
best = None
for el in range(0, 91, 5):
    for az in range(0, 360, 5):
        if el == 90 and az: continue
        a = np.array([math.cos(math.radians(el)) * math.cos(math.radians(az)), math.cos(math.radians(el)) * math.sin(math.radians(az)), math.sin(math.radians(el))])
        if NEAR and abs(a['xyz'.index(NEAR)]) < math.cos(math.radians(35)): continue
        u = np.cross(a, [0, 0, 1] if abs(a[2]) < 0.9 else [1, 0, 0]); u /= np.linalg.norm(u); v = np.cross(a, u)
        q = np.stack([P @ u, P @ v], 1)
        lo, hi = q.min(0), q.max(0)
        for cx in np.arange(lo[0], hi[0], 0.5):
            for cy in np.arange(lo[1], hi[1], 0.5):
                d = q - [cx, cy]; r = np.hypot(d[:, 0], d[:, 1])
                rr = r.min()
                if rr < 0.9 or (best and rr <= best[0]): continue
                ring = d[(r < rr + 2.5)]
                ang = np.floor((np.arctan2(ring[:, 1], ring[:, 0]) + math.pi) / (2 * math.pi) * 24).astype(int) % 24
                cov = len(set(ang.tolist())) / 24
                if cov >= COVER:
                    c3 = cx * u + cy * v
                    along = P[(r < rr + 2.5)] @ a
                    best = (rr, cov, tuple(a), tuple(c3 + a * along.mean()), along.min(), along.max())
r, cov, a, c, amin, amax = best
print('cylinder radius %.2f cm (cover %.2f), axis (%.3f %.3f %.3f), centre (%.2f %.2f %.2f), hand along it %.1f..%.1f' % (r, cov, *a, *c, amin - np.dot(a, c), amax - np.dot(a, c)))
