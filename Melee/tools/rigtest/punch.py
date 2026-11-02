#!/usr/bin/env python3
"""punch.py -- console text for the rig: a rest pose, a wait, then one punch of the given hand (TEST ONLY).
punch.py <hand r|l> <wait tics> <x> <y> <z0> <z1> <steps> [dx] [dy] [pitch]
Stage metres: +x right, +y up, -z forward. Moves (x,y,z0) -> (x+dx, y+dy, z1) over <steps> tics, holds 10, rests."""
import sys
a = sys.argv[1:]
h = 'qz_rhand' if a[0] == 'r' else 'qz_lhand'
w = int(a[1]); x, y, z0, z1 = map(float, a[2:6]); n = int(a[6])
dx = float(a[7]) if len(a) > 7 else 0.0; dy = float(a[8]) if len(a) > 8 else 0.0; pit = float(a[9]) if len(a) > 9 else 30
out = [f'{h} "{x} {y} {z0} {pit} 0 0"', f'wait {w}']
for k in range(1, n + 1):
    f = k / n
    out += [f'{h} "{x + dx * f:.3f} {y + dy * f:.3f} {z0 + (z1 - z0) * f:.3f} {pit} 0 0"', 'wait 1']
out += ['wait 10', f'{h} "{x} {y} {z0} {pit} 0 0"']
print('; '.join(out))
