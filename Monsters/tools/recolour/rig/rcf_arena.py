#!/usr/bin/env python3
"""TEST ONLY: writes the census arena (rcFcensus/rcf_arena.wad is NOT kept in git; run this to make it).
    rcf_arena.py OUT.wad
MAP01: one open room 4608 x 4608 (x, y -2304..2304), floor 0, ceiling 1024, light 255. The player starts at (-2200, -2200)
facing north-east. rcFcensus lays one monster a cell, 288 units apart, inside -1600..1600."""
import sys, struct
W = 2304
verts = [(-W, -W), (W, -W), (W, W), (-W, W)]
t = ['namespace = "zdoom";']
for x, y in verts: t.append('vertex { x = %d; y = %d; }' % (x, y))
# clockwise seen from above with the room on the right of each line: (-W,-W) -> (-W,W) -> (W,W) -> (W,-W)
for v1, v2 in ((0, 3), (3, 2), (2, 1), (1, 0)):
    t.append('linedef { v1 = %d; v2 = %d; sidefront = %d; blocking = true; }' % (v1, v2, len([l for l in t if l.startswith('linedef')])))
for i in range(4): t.append('sidedef { sector = 0; texturemiddle = "STARTAN2"; }')
t.append('sector { heightfloor = 0; heightceiling = 1024; texturefloor = "FLOOR0_1"; textureceiling = "CEIL1_1"; lightlevel = 255; }')
t.append('thing { x = -2200; y = -2200; angle = 45; type = 1; skill1 = true; skill2 = true; skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }')
tm = ('\n'.join(t) + '\n').encode('ascii')
lumps = [('MAP01', b''), ('TEXTMAP', tm), ('ENDMAP', b'')]
data = b''; ents = []; off = 12
for n, b in lumps: ents.append((off, len(b), n)); data += b; off += len(b)
out = b'PWAD' + struct.pack('<ii', len(lumps), 12 + len(data)) + data + b''.join(struct.pack('<ii', o, l) + n.encode().ljust(8, b'\0') for o, l, n in ents)
open(sys.argv[1], 'wb').write(out)
print('wrote', sys.argv[1], len(out))
