#!/usr/bin/env python3
"""TEST ONLY. mapinfo.py <wad> <MAPxx> [names...]: lists sectors whose floor flat is in GLDEFS.txt's Glow list
(or matches the given names), with bbox, centre and a camera spot (inside, near a corner, facing the centre)."""
import struct, sys, os, re, math
wad, mapname = sys.argv[1], sys.argv[2]
glo = open(os.path.join(os.path.dirname(__file__), '..', '..', 'GLDEFS.txt'), encoding='latin-1').read().upper().split()
names = set(sys.argv[3:]) or set(glo)
d = open(wad, 'rb').read()
n, off = struct.unpack('<ii', d[4:12])
lumps = [struct.unpack('<ii8s', d[off+16*i:off+16*i+16]) for i in range(n)]
idx = [i for i, l in enumerate(lumps) if l[2].rstrip(b'\0').decode() == mapname][0]
def L(name):
    for j in range(idx+1, idx+12):
        if lumps[j][2].rstrip(b'\0').decode() == name: return d[lumps[j][0]:lumps[j][0]+lumps[j][1]]
V = [struct.unpack('<hh', L('VERTEXES')[i:i+4]) for i in range(0, len(L('VERTEXES')), 4)]
S = [(0,0,0,struct.unpack('<hh24xh', L('SIDEDEFS')[i:i+30])[2]) for i in range(0, len(L('SIDEDEFS')), 30)]
SE = [struct.unpack('<hh8s8shhh', L('SECTORS')[i:i+26]) for i in range(0, len(L('SECTORS')), 26)]
LD = [struct.unpack('<hhhhhhh', L('LINEDEFS')[i:i+14]) for i in range(0, len(L('LINEDEFS')), 14)]
pts = {}
for v1, v2, fl, sp, tg, s1, s2 in LD:
    for sd in (s1, s2):
        if sd >= 0:
            sec = S[sd][3]
            pts.setdefault(sec, []).extend([V[v1], V[v2]])
for i, (fh, ch, ft, ct, light, sp, tag) in enumerate(SE):
    f = ft.rstrip(b'\0').decode().upper(); c = ct.rstrip(b'\0').decode().upper()
    if f in names or c in names:
        p = pts.get(i, [])
        if not p: continue
        xs = [a for a, b in p]; ys = [b for a, b in p]
        cx, cy = sum(xs)/len(xs), sum(ys)/len(ys)
        area = (max(xs)-min(xs))*(max(ys)-min(ys))
        print('sector %d floor %s ceil %s tag %d light %d bbox %d..%d %d..%d centre %d %d area %d' % (i, f, c, tag, light, min(xs), max(xs), min(ys), max(ys), cx, cy, area))
