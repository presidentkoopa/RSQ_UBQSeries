#!/usr/bin/env python3
"""RSQ SlowMo -- the DOWN plate's art (owner 2026-11-07, design/NEAR_DEATH.md v3 + the 05:51 icon decision).
Our own art, generated: white on transparent (drawn Shaded in the target's colour at run time).
  graphics/rsqsmp/RSPWHT   plain white (backdrop, bar slices, seven-segment segments)
  graphics/rsqsmp/RSPInnF  icon nn (01..10) whole;  RSPInnR / RSPInnO / RSPInnD  its three assembly layers
                           (R the ring part, O the outer pieces: ticks, brackets, arrows, triangles; D the dot, last)
  graphics/rsqsmp/RSPFLSH  the lock-on flash ring;  RSPCRK the crack over a dead target's slot
  (the off-view chevron is gen_chevron.py's pixel art)
  sprites/rsqsm/RSPQA0     the frame the quad models hang on
  models/rsqsm/plate/quad.obj, strip8/12/24.obj   a unit quad and glyph strips (the Wheel's geometry, our own files)
Run from anywhere: python3 SlowMo/tools/plate/gen_plate_art.py"""
import os, math
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(os.path.dirname(HERE))
G = os.path.join(MOD, 'graphics', 'rsqsmp'); os.makedirs(G, exist_ok=True)
S = 64; K = 4; N = S * K; C = N / 2

def canvas(): return Image.new('L', (N, N), 0)
def save(img, name):
    a = img.resize((S, S), Image.LANCZOS)
    out = Image.new('RGBA', (S, S), (255, 255, 255, 0)); out.putalpha(a)
    out.save(os.path.join(G, name + '.png'))

def ring(d, r, w): d.ellipse([C - r, C - r, C + r, C + r], outline=255, width=int(w))
def dashed(d, r, w, n, fill=0.55, off=0):
    for i in range(n):
        a0 = off + i * 360 / n; a1 = a0 + 360 / n * fill
        d.arc([C - r, C - r, C + r, C + r], a0, a1, fill=255, width=int(w))
def arcs(d, r, w, n, span, off):
    for i in range(n):
        a0 = off + i * 360 / n - span / 2
        d.arc([C - r, C - r, C + r, C + r], a0, a0 + span, fill=255, width=int(w))
def dot(d, r): d.ellipse([C - r, C - r, C + r, C + r], fill=255)
def pt(a, r): return (C + math.cos(math.radians(a)) * r, C + math.sin(math.radians(a)) * r)
def line_r(d, a, r0, r1, w): d.line([pt(a, r0), pt(a, r1)], fill=255, width=int(w))
def tri(d, a, r_tip, r_base, half):
    tip = pt(a, r_tip); b = pt(a, r_base)
    px, py = -math.sin(math.radians(a)) * half, math.cos(math.radians(a)) * half
    d.polygon([tip, (b[0] + px, b[1] + py), (b[0] - px, b[1] - py)], fill=255)
def gapcross(d, r0, r1, w):
    for a in (0, 90, 180, 270): line_r(d, a, r0, r1, w)
def brackets(d, r, L, w):
    for sx in (-1, 1):
        for sy in (-1, 1):
            x, y = C + sx * r, C + sy * r
            d.line([(x, y), (x - sx * L, y)], fill=255, width=int(w)); d.line([(x, y), (x, y - sy * L)], fill=255, width=int(w))
def ticks(d, r0, r1, w, angles=(0, 90, 180, 270)):
    for a in angles: line_r(d, a, r0, r1, w)
def arrow_in(d, a, r_from, r_to, w):
    line_r(d, a, r_from, r_to + 20, w); tri(d, a, r_to, r_to + 30, 18)

L = 3.2 * K   # line width
def icon(n):
    R, O, D = canvas(), canvas(), canvas()
    r, o, dd = ImageDraw.Draw(R), ImageDraw.Draw(O), ImageDraw.Draw(D)
    if n == 1:   # ring + 4 inward triangles + dot
        ring(r, 88, L); [tri(o, a, 92, 124, 20) for a in (0, 90, 180, 270)]; dot(dd, 12)
    elif n == 2: # dashed outer ring + ring + gapped cross + dot
        ring(r, 70, L); dashed(o, 112, L, 12); gapcross(o, 26, 96, L); dot(dd, 11)
    elif n == 3: # corner brackets + ticked cross + small circle
        brackets(o, 100, 40, L); gapcross(r, 30, 84, L); ticks(r, 0, 0, 1); [line_r(r, a, 56, 56, 1) for a in ()]
        for a in (0, 90, 180, 270):
            p = pt(a, 60); q = (-math.sin(math.radians(a)) * 12, math.cos(math.radians(a)) * 12)
            r.line([(p[0] + q[0], p[1] + q[1]), (p[0] - q[0], p[1] - q[1])], fill=255, width=int(L))
        ring(dd, 16, L)
    elif n == 4: # four thick broken arcs + dot
        arcs(r, 82, L * 2.2, 4, 56, 45); dot(dd, 13)
    elif n == 5: # ring with 4 notches + ticked cross
        arcs(r, 84, L, 4, 76, 45); gapcross(o, 22, 110, L)
        for a in (0, 90, 180, 270):
            p = pt(a, 44); q = (-math.sin(math.radians(a)) * 10, math.cos(math.radians(a)) * 10)
            o.line([(p[0] + q[0], p[1] + q[1]), (p[0] - q[0], p[1] - q[1])], fill=255, width=int(L))
        dot(dd, 7)
    elif n == 6: # small corner brackets + 4 outward-pointing small triangles + dot
        brackets(r, 56, 26, L); [tri(o, a, 120, 90, 17) for a in (0, 90, 180, 270)]; dot(dd, 11)
    elif n == 7: # dashed ring + 4 small cardinal circles + gapped cross + dot
        dashed(r, 84, L, 16, 0.5); gapcross(r, 24, 64, L)
        for a in (0, 90, 180, 270):
            x, y = pt(a, 106); o.ellipse([x - 9, y - 9, x + 9, y + 9], outline=255, width=int(L))
        dot(dd, 10)
    elif n == 8: # ring + 4 outer ticks + small circle with an X
        ring(r, 80, L); ticks(o, 92, 120, L); ring(dd, 24, L)
        for a in (45, 135, 225, 315): line_r(dd, a, 0, 24, L)
    elif n == 9: # three rings (middle dashed) + 4 ticks + dot
        ring(r, 110, L * 0.8); dashed(r, 80, L, 14, 0.5); ring(r, 48, L * 0.8); ticks(o, 112, 124, L); dot(dd, 9)
    elif n == 10: # dashed ring + 4 diagonal inward arrows + dot
        dashed(r, 70, L, 12, 0.55, 15); [arrow_in(o, a, 126, 82, L) for a in (45, 135, 225, 315)]; dot(dd, 11)
    F = Image.fromarray(__import__('numpy').maximum(__import__('numpy').maximum(__import__('numpy').array(R), __import__('numpy').array(O)), __import__('numpy').array(D)))
    tag = 'RSPI%02d' % n
    save(R, tag + 'R'); save(O, tag + 'O'); save(D, tag + 'D'); save(F, tag + 'F')

for n in range(1, 11): icon(n)
# flash ring, crack, chevrons
F = canvas(); ring(ImageDraw.Draw(F), 110, 7 * K); save(F, 'RSPFLSH')
CK = canvas(); d = ImageDraw.Draw(CK)
for seg in [[(40, 10), (110, 80), (95, 130), (150, 170), (140, 230), (190, 250)], [(110, 80), (170, 60), (230, 30)], [(150, 170), (220, 160)], [(95, 130), (30, 170)]]:
    d.line([(x * K / 4 * 4 / 4, y) for x, y in seg], fill=255, width=int(3 * K), joint='curve')
save(CK, 'RSPCRK')
W = Image.new('RGBA', (16, 16), (255, 255, 255, 255)); W.save(os.path.join(G, 'RSPWHT.png'))
# the sprite frame the models hang on
SP = os.path.join(MOD, 'sprites', 'rsqsm'); os.makedirs(SP, exist_ok=True)
Image.new('RGBA', (4, 4), (255, 255, 255, 0)).save(os.path.join(SP, 'RSPQA0.png'))
# geometry: a unit quad facing +x (the Wheel's convention), and strips of unit cells running along the actor's right
M = os.path.join(MOD, 'models', 'rsqsm', 'plate'); os.makedirs(M, exist_ok=True)
def obj(path, cells, quad=False):
    v, f = [], []
    for k in range(cells):
        if quad: z0, z1 = 0.5, -0.5
        else: z0, z1 = -k, -k - 1
        v += [(0, 0.5, z0), (0, 0.5, z1), (0, -0.5, z1), (0, -0.5, z0)]
    with open(path, 'w') as fh:
        fh.write('# generated by SlowMo/tools/plate/gen_plate_art.py -- RSQ SlowMo DOWN plate\n')
        for x in v: fh.write('v %g %g %g\n' % x)
        fh.write('vt 0 1\nvt 1 1\nvt 1 0\nvt 0 0\nvn 1 0 0\n')
        for k in range(cells):
            b = k * 4
            fh.write('usemtl RSPWHT\nf %d/1/1 %d/3/1 %d/2/1\nf %d/1/1 %d/4/1 %d/3/1\n' % (b + 1, b + 3, b + 2, b + 1, b + 4, b + 3))
obj(os.path.join(M, 'quad.obj'), 1, True)
for c in (8, 12, 24): obj(os.path.join(M, 'strip%d.obj' % c), c)
print('ok')
