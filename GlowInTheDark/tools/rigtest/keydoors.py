#!/usr/bin/env python3
"""TEST ONLY. keydoors.py <wad> <MAPxx>: keyed door lines with a camera spot 192 units in front, facing them."""
import struct, sys, math
wad, mapname = sys.argv[1], sys.argv[2]
d = open(wad, 'rb').read()
n, off = struct.unpack('<ii', d[4:12])
lumps = [struct.unpack('<ii8s', d[off+16*i:off+16*i+16]) for i in range(n)]
idx = [i for i, l in enumerate(lumps) if l[2].rstrip(b'\0').decode() == mapname][0]
def L(name):
    for j in range(idx+1, idx+12):
        if lumps[j][2].rstrip(b'\0').decode() == name: return d[lumps[j][0]:lumps[j][0]+lumps[j][1]]
V = [struct.unpack('<hh', L('VERTEXES')[i:i+4]) for i in range(0, len(L('VERTEXES')), 4)]
LD = [struct.unpack('<hhhhhhh', L('LINEDEFS')[i:i+14]) for i in range(0, len(L('LINEDEFS')), 14)]
KEY = {26:'blue',27:'yellow',28:'red',32:'blue',33:'red',34:'yellow',99:'blue',133:'blue',134:'red',135:'red',136:'yellow',137:'yellow'}
for i, (v1, v2, fl, sp, tg, s1, s2) in enumerate(LD):
    if sp in KEY:
        (x1, y1), (x2, y2) = V[v1], V[v2]
        mx, my = (x1+x2)/2, (y1+y2)/2
        dx, dy = x2-x1, y2-y1; ln = math.hypot(dx, dy)
        nx, ny = dy/ln, -dx/ln   # front side normal (right of v1->v2)
        cx, cy = mx + nx*192, my + ny*192
        ang = math.degrees(math.atan2(my-cy, mx-cx)) % 360
        print('line %d %s special %d cam %d %d angle %d' % (i, KEY[sp], sp, cx, cy, ang))
