#!/usr/bin/env python3
"""TEST ONLY: the BONES room for run_batch.sh -- one flat room 0..2048 x 0..1536, floor 0, ceiling 384, light 144 (dark enough
for candles and the beam to read). The player starts at (200, 768) facing east. Four ambushing monsters far east (Doom's
ZombieMan, DoomImp, ShotgunGuy, Demon by their DoomEdNums): with Legion of Bones loaded after Brutal Doom and the Bones Bridge
on they must come out as Brutal Doom / XMVE monsters; RSQ Miniboss's Bossfight takes its roster from them.
    python3 -I mkmap.py <out.wad>"""
import struct, sys
V = [(0, 0), (0, 1536), (2048, 1536), (2048, 0)]
th = lambda x, y, t, a=180, amb='true': ('thing { x = %d.0; y = %d.0; type = %d; angle = %d; skill1 = true; skill2 = true; skill3 = true; '
                                     'skill4 = true; skill5 = true; single = true; coop = true; dm = true; ambush = %s; }' % (x, y, t, a, amb))
out = ['namespace = "zdoom";', th(200, 768, 1, 0, 'false'),
       th(1900, 500, 3004), th(1900, 700, 3001), th(1900, 900, 9), th(1900, 1100, 3002)]
for x, y in V: out.append('vertex { x = %d.0; y = %d.0; }' % (x, y))
for i in range(4): out.append('linedef { v1 = %d; v2 = %d; sidefront = %d; blocking = true; }' % (i, (i + 1) % 4, i))
for i in range(4): out.append('sidedef { sector = 0; texturemiddle = "STARTAN2"; }')
out.append('sector { heightfloor = 0; heightceiling = 384; texturefloor = "FLOOR4_8"; textureceiling = "CEIL5_1"; lightlevel = 144; }')
tm = '\n'.join(out).encode()
lumps = [('BONES', b''), ('TEXTMAP', tm), ('ENDMAP', b'')]
data = b''; dirs = []; off = 12
for n, d in lumps: dirs.append((off, len(d), n)); data += d; off += len(d)
open(sys.argv[1], 'wb').write(b'PWAD' + struct.pack('<ii', len(lumps), off) + data + b''.join(struct.pack('<ii8s', o, s, n.encode()) for o, s, n in dirs))
