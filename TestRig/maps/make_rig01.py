#!/usr/bin/env python3
"""make_rig01.py -- writes TestRig/maps/rig01.wad: a test arena for the rig (UDMF, Doom 2 textures).

    python TestRig/maps/make_rig01.py

MAP01: a 1024 x 1024 room, floor 0, ceiling 256. The EAST half (x >= 0) is a raised block, floor 120, with a true
two-sided step face at x = 0 (a lip you can mantle onto). A free-standing 80 x 64 pillar at x -176..-96,
y 220..284 (a corner for the rope to wrap round). The player starts at (-320, 0) facing east. Load it with -file
after the mod under test; the hidden runner takes -Map MAP01 as usual.
"""
import os, struct

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'rig01.wad')

W, H = 512, 512          # the room is +-W by +-H
FLOOR_HI = 120           # the step
PX0, PX1, PY0, PY1 = -176, -96, 220, 284   # the pillar (north of where a swing rope's first reel drifts the player)

verts = []
def V(x, y):
    verts.append((x, y)); return len(verts) - 1

lines, sides, sectors = [], [], []
def S(sector, tex='STARTAN2', upper='-', lower='-'):
    sides.append((sector, tex, upper, lower)); return len(sides) - 1
def L(v1, v2, front, back=None, blocking=True):
    lines.append((v1, v2, front, back, blocking))

# sectors: 0 the low west half, 1 the raised east half
sectors.append((0, 256, 'FLOOR0_1', 'CEIL1_1', 192))
sectors.append((FLOOR_HI, 256, 'FLOOR0_1', 'CEIL1_1', 192))

# WINDING: a line's FRONT is its right-hand side (looking from v1 to v2). The room's boundary runs CLOCKWISE so the
# room is on the right of every wall; the pillar runs COUNTER-clockwise so the room is on the right of its walls too
# (the void inside is on the left, with no sector). The first cut had both the other way round: the hook flew
# through the step and the pull snagged on nothing (rig, 11-03).
a = V(-W, -H); b = V(0, -H); c = V(W, -H); d = V(W, H); e = V(0, H); f = V(-W, H)
L(a, f, S(0)); L(f, e, S(0)); L(e, d, S(1)); L(d, c, S(1)); L(c, b, S(1)); L(b, a, S(0))
# the step face: two-sided, x = 0 from south to north: the right side (front) is EAST, the raised sector 1
L(b, e, S(1, '-', '-', '-'), S(0, '-', '-', 'STARTAN2'), blocking=False)
# the pillar: four one-sided lines, the room on their right
p0 = V(PX0, PY0); p1 = V(PX1, PY0); p2 = V(PX1, PY1); p3 = V(PX0, PY1)
L(p0, p1, S(0)); L(p1, p2, S(0)); L(p2, p3, S(0)); L(p3, p0, S(0))

t = ['namespace = "zdoom";']
for (x, y) in verts: t.append('vertex { x = %d; y = %d; }' % (x, y))
for (v1, v2, fr, bk, blk) in lines:
    s = 'linedef { v1 = %d; v2 = %d; sidefront = %d;' % (v1, v2, fr)
    if bk is not None: s += ' sideback = %d; twosided = true;' % bk
    if blk and bk is None: s += ' blocking = true;'
    t.append(s + ' }')
for (sec, tex, up, lo) in sides:
    t.append('sidedef { sector = %d; texturemiddle = "%s"; texturetop = "%s"; texturebottom = "%s"; }' % (sec, tex, up, lo))
for (fl, ce, tf, tc, li) in sectors:
    t.append('sector { heightfloor = %d; heightceiling = %d; texturefloor = "%s"; textureceiling = "%s"; lightlevel = %d; }' % (fl, ce, tf, tc, li))
t.append('thing { x = -320; y = 0; angle = 0; type = 1; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }')
textmap = '\n'.join(t) + '\n'

lumps = [('MAP01', b''), ('TEXTMAP', textmap.encode('ascii')), ('ENDMAP', b'')]
data = b''
dirents = []
off = 12
for name, body in lumps:
    dirents.append((off, len(body), name)); data += body; off += len(body)
hdr = b'PWAD' + struct.pack('<ii', len(lumps), 12 + len(data))
dirbytes = b''.join(struct.pack('<ii', o, n) + name.encode('ascii').ljust(8, b'\0') for (o, n, name) in dirents)
open(OUT, 'wb').write(hdr + data + dirbytes)
print('wrote', OUT, len(hdr + data + dirbytes), 'bytes')
