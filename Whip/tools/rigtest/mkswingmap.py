#!/usr/bin/env python3
"""TEST ONLY (never ships). SWINGTST, the aimed swing's map (UDMF, nodes built by the engine):

  A   west ledge   x 0..384     y 0..1024   floor 96, ceiling 288      the start (player at 300, 512, facing east)
  P   the pit      x 384..1920  y 0..1024   floor -768, ceiling 192    45 m across: ceiling anchors, the south wall (y 0)
  M   a landing    x 1050..1350 y 0..1024   floor -260, ceiling 192    in the pit: where one swing's let-go lands
  B   east ledge   x 1920..2304 y 0..1024   floor -64, ceiling 288     where a chain lands
  SK  sky yard     x 0..384     y 1024..1536 floor 96, ceiling 256 F_SKY1   north of A: a ray up into it is refused

    python3 mkswingmap.py OUT.wad
"""
import struct, sys

V = []; vid = {}
def v(x, y):
    if (x, y) not in vid: vid[(x, y)] = len(V); V.append((x, y))
    return vid[(x, y)]
S = []
def sector(**k): S.append(k); return len(S) - 1
edges = {}
def on_seg(p, a, b):
    if p == a or p == b: return False
    if a[0] == b[0] == p[0]: return min(a[1], b[1]) < p[1] < max(a[1], b[1])
    if a[1] == b[1] == p[1]: return min(a[0], b[0]) < p[0] < max(a[0], b[0])
    return False
def add_rect(sec, x0, y0, x1, y1, splits=()):
    pts4 = [(x0, y0), (x0, y1), (x1, y1), (x1, y0)]   # clockwise (y up): the right side is inside
    for i in range(4):
        a, b = pts4[i], pts4[(i + 1) % 4]
        pts = [a] + sorted([p for p in splits if on_seg(p, a, b)], key=lambda p: (p[0] - a[0]) ** 2 + (p[1] - a[1]) ** 2) + [b]
        for j in range(len(pts) - 1): edges[(pts[j], pts[j + 1])] = sec

A = sector(f=96, c=288, ft="FLOOR4_8", ct="CEIL5_1")
P = sector(f=-768, c=192, ft="NUKAGE1", ct="CEIL5_1")
B = sector(f=-64, c=288, ft="FLOOR4_8", ct="CEIL5_1")
SK = sector(f=96, c=256, ft="FLOOR4_8", ct="F_SKY1")
M = sector(f=-260, c=192, ft="FLOOR4_8", ct="CEIL5_1")
add_rect(A, 0, 0, 384, 1024)
add_rect(P, 384, 0, 1050, 1024)
add_rect(M, 1050, 0, 1350, 1024)
add_rect(P, 1350, 0, 1920, 1024)
add_rect(B, 1920, 0, 2304, 1024)
add_rect(SK, 0, 1024, 384, 1536)

done = set(); lines = []
for (a, b), sec in edges.items():
    if (a, b) in done: continue
    back = edges.get((b, a))
    done.add((a, b))
    if back is not None: done.add((b, a))
    lines.append([v(*a), v(*b), sec, back])

out = ['namespace = "zdoom";',
       'thing { x = 300.0; y = 512.0; type = 1; angle = 0; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }']
for (x, y) in V: out.append('vertex { x = %d.0; y = %d.0; }' % (x, y))
sides = []
def side(sec, other):
    s = 'sidedef { sector = %d; ' % sec
    s += 'texturemiddle = "STARTAN2"; ' if other is None else 'texturetop = "STARTAN2"; texturebottom = "STARTAN2"; '
    s += '}'; sides.append(s); return len(sides) - 1
for (v1, v2, f, b) in lines:
    fs = side(f, b); bs = side(b, f) if b is not None else None
    s = 'linedef { v1 = %d; v2 = %d; sidefront = %d; ' % (v1, v2, fs)
    s += ('sideback = %d; twosided = true; ' % bs) if bs is not None else 'blocking = true; '
    s += '}'; out.append(s)
out += sides
for k in S:
    out.append('sector { heightfloor = %d; heightceiling = %d; texturefloor = "%s"; textureceiling = "%s"; lightlevel = 200; }'
               % (k['f'], k['c'], k['ft'], k['ct']))
tm = '\n'.join(out).encode()
lumps = [('SWINGTST', b''), ('TEXTMAP', tm), ('ENDMAP', b'')]
data = b''; dirs = []; off = 12
for n, d in lumps: dirs.append((off, len(d), n)); data += d; off += len(d)
w = b'PWAD' + struct.pack('<ii', len(lumps), off) + data + b''.join(struct.pack('<ii8s', o, s, n.encode()) for o, s, n in dirs)
open(sys.argv[1], 'wb').write(w); print(len(V), 'verts', len(lines), 'lines', len(S), 'sectors')
