#!/usr/bin/env python3
"""RSQ SlowMo -- the DOWN plate's art (owner 2026-11-07, design/NEAR_DEATH.md v3 + the 05:51 icon decision; the look is
design/mockups/down_v3_full_view_mockup.html, the 07:15 translation rules in design/mockups/README.md).
Our own art, generated. White on transparent where it is drawn Shaded in the target's colour at run time.
  graphics/rsqsmp/RSPWHT     plain white (bar slices, seven-segment segments)
  graphics/rsqsmp/RSPInnF    icon nn (01..10), whole, 64 px (the plate's slots, the turn markers' slot)
  graphics/rsqsmp/RSPAnnff   icon nn's LOCK-ON ASSEMBLY baked into frames ff 00..16 (owner 07:15: motion baked into frames
                             on a still panel), 128 px, the icon in its middle 64 px. The mockup's timing (its icon1 / icon10
                             code): k = 0..1 over 0.45 s (16 tics); the ring scales in from 2x and spins in (ease-out cubic,
                             over k 0-0.4); the four outer pieces slide in from one icon radius outside, one after another
                             (k 0.15 + 0.08 each, over 0.35); the dot fades in last (k 0.5-0.7); the flash ring grows from 1x
                             to 1.6x and fades (k 0.7-1). Frame 16 is the locked icon.
                             Strokes 5 px at 64 (the mockup's are about 3: owner 07:15 "thicker so they don't shimmer").
  Opaque solid colours (drawn Normal, so they are drawn first and never sort in front of the letters -- owner 07:05
  "fix it": the see-through backing that dimmed them):
  graphics/rsqsmp/RSPK0B     #0b0b0d  the bar's border, the clock tab's border      (mockup colours)
  graphics/rsqsmp/RSPK20     #202024  the bar's empty track
  graphics/rsqsmp/RSPK17     #170708  the clock tab's inside
  graphics/rsqsmp/RSPKDD     #dddddd  the strike-through
  graphics/rsqsmp/RSPSLOT    #0b0b0d  a dark round slot (cut out)
  graphics/rsqsmp/RSPCRK     #dddddd  the crack over a dead target's slot: the mockup's crack lines, 3 px on its 54 px slot
  sprites/rsqsm/RSPQA0       the frame the quad models hang on
  models/rsqsm/plate/quad.obj, strip8/12/24.obj   a unit quad and glyph strips (the Wheel's geometry, our own files)
(the turn markers and the world trail are gen_chevron.py's)
Run from anywhere: python3 SlowMo/tools/plate/gen_plate_art.py"""
import os, math, glob
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(os.path.dirname(HERE))
G = os.path.join(MOD, 'graphics', 'rsqsmp'); os.makedirs(G, exist_ok=True)
S = 64; K = 4; N = S * K; C = N / 2           # an icon: 64 px, drawn 4x (256), centre 128, its radius 128

def canvas(): return Image.new('L', (N, N), 0)
def save_a(a, name, size):
    """a: float alpha array 0..1 at 4x; saved white with that alpha, size x size"""
    img = Image.fromarray(np.clip(a * 255 + 0.5, 0, 255).astype(np.uint8)).resize((size, size), Image.LANCZOS)
    out = Image.new('RGBA', (size, size), (255, 255, 255, 0)); out.putalpha(img)
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
def crossbar(d, a, r, half, w):
    p = pt(a, r); q = (-math.sin(math.radians(a)) * half, math.cos(math.radians(a)) * half)
    d.line([(p[0] + q[0], p[1] + q[1]), (p[0] - q[0], p[1] - q[1])], fill=255, width=int(w))

L = 5.0 * K   # line width: 5 px at 64 (was 3.2)
DIAG = {3, 10}   # icons whose outer pieces sit on the diagonals
def icon_layers(n):
    """the ten icons (NEAR_DEATH 05:51), in three layers: R the ring part (spins and scales in), O the outer pieces (slide in
    from outside), D the dot (last)"""
    R, O, D = canvas(), canvas(), canvas()
    r, o, dd = ImageDraw.Draw(R), ImageDraw.Draw(O), ImageDraw.Draw(D)
    if n == 1:   # ring + 4 inward triangles + dot
        ring(r, 86, L); [tri(o, a, 90, 124, 22) for a in (0, 90, 180, 270)]; dot(dd, 13)
    elif n == 2: # dashed outer ring + ring + gapped cross + dot
        ring(r, 68, L); dashed(o, 110, L, 12); gapcross(o, 26, 94, L); dot(dd, 12)
    elif n == 3: # corner brackets + ticked cross + small circle
        brackets(o, 100, 40, L); gapcross(r, 30, 84, L)
        for a in (0, 90, 180, 270): crossbar(r, a, 60, 13, L)
        ring(dd, 17, L)
    elif n == 4: # four thick broken arcs + dot
        arcs(r, 80, L * 2.0, 4, 56, 45); dot(dd, 14)
    elif n == 5: # ring with 4 notches + ticked cross
        arcs(r, 84, L, 4, 76, 45); gapcross(o, 22, 110, L)
        for a in (0, 90, 180, 270): crossbar(o, a, 46, 12, L)
        dot(dd, 9)
    elif n == 6: # small corner brackets + 4 outward-pointing small triangles + dot
        brackets(r, 56, 26, L); [tri(o, a, 122, 90, 19) for a in (0, 90, 180, 270)]; dot(dd, 12)
    elif n == 7: # dashed ring + 4 small cardinal circles + gapped cross + dot
        dashed(r, 82, L, 16, 0.5); gapcross(r, 24, 62, L)
        for a in (0, 90, 180, 270):
            x, y = pt(a, 106); o.ellipse([x - 11, y - 11, x + 11, y + 11], outline=255, width=int(L))
        dot(dd, 11)
    elif n == 8: # ring + 4 outer ticks + small circle with an X
        ring(r, 78, L); ticks(o, 92, 122, L); ring(dd, 26, L)
        for a in (45, 135, 225, 315): line_r(dd, a, 0, 26, L)
    elif n == 9: # three rings (middle dashed) + 4 ticks + dot
        ring(r, 108, L * 0.8); dashed(r, 78, L * 0.8, 14, 0.5); ring(r, 46, L * 0.8); ticks(o, 112, 126, L); dot(dd, 10)
    elif n == 10: # dashed ring + 4 diagonal inward arrows + dot
        dashed(r, 68, L, 12, 0.55, 15); [arrow_in(o, a, 126, 82, L) for a in (45, 135, 225, 315)]; dot(dd, 12)
    f = lambda im: np.asarray(im, dtype=np.float64) / 255.0
    return f(R), f(O), f(D)

def over(a, b): return 1 - (1 - a) * (1 - b)
def ease(t): t = min(1.0, max(0.0, t)); return 1 - (1 - t) ** 3

# THE ASSEMBLY FRAMES: a 128 px frame (512 at 4x), the icon (radius 128 at 4x) in its middle
FN = 2 * N; FC = FN / 2
def place(layer, scale=1.0, rot_rad=0.0, dx=0.0, dy=0.0):
    """the 256 layer, scaled/rotated about its centre and moved, onto the 512 frame"""
    im = Image.fromarray((layer * 255).astype(np.uint8))
    c, s = math.cos(rot_rad), math.sin(rot_rad)
    # output (x, y) -> input: inverse of  out = FC + d + scale * R(rot) * (in - C)
    a = c / scale; b = s / scale; d_ = -s / scale; e = c / scale
    ox, oy = FC + dx, FC + dy
    coeffs = (a, b, C - a * ox - b * oy, d_, e, C - d_ * ox - e * oy)
    out = im.transform((FN, FN), Image.AFFINE, coeffs, resample=Image.BICUBIC, fillcolor=0)
    return np.asarray(out, dtype=np.float64) / 255.0

def sectors(O, diag):
    """the outer layer split into its four pieces, by angle round the centre; with each piece's outward direction (image y down)"""
    h, w = O.shape
    yy, xx = np.mgrid[0:h, 0:w]
    ang = np.degrees(np.arctan2(yy + 0.5 - C, xx + 0.5 - C)) % 360
    # the mockup's order: icon1 up, down, left, right; icon10 top-left, top-right, bottom-right, bottom-left
    dirs = [270, 90, 180, 0] if not diag else [225, 315, 45, 135]
    out = []
    for a0 in dirs:
        dist = np.abs(((ang - a0) + 180) % 360 - 180)
        out.append((np.where(dist <= 45, O, 0.0), (math.cos(math.radians(a0)), math.sin(math.radians(a0)))))
    return out

def flash_ring(radius, width):
    im = Image.new('L', (FN, FN), 0)
    ImageDraw.Draw(im).ellipse([FC - radius, FC - radius, FC + radius, FC + radius], outline=255, width=int(width))
    return np.asarray(im, dtype=np.float64) / 255.0

ASM_FRAMES = 16
def assembly(n, R, O, D):
    pieces = sectors(O, n in DIAG)
    r = C   # the icon's radius at 4x
    slide = r * (0.8 if n in DIAG else 1.0)
    for fi in range(ASM_FRAMES + 1):
        k = fi / ASM_FRAMES
        a = ease(k / 0.4)
        acc = np.zeros((FN, FN))
        if a > 0: acc = over(acc, place(R, 2 - a, (1 - a) * -3.0) * a)
        for i, (P, (ux, uy)) in enumerate(pieces):
            q = ease((k - 0.15 - i * 0.08) / 0.35)
            if q <= 0: continue
            o = (1 - q) * slide
            acc = over(acc, place(P, 1.0, 0.0, ux * o, uy * o) * q)
        da = ease((k - 0.5) / 0.2)
        if da > 0: acc = over(acc, place(D) * da)
        f = (k - 0.7) / 0.3
        if 0 < f < 1: acc = over(acc, flash_ring(r * (1 + f * 0.6), 3.5 * K) * (1 - f) * 0.8)
        save_a(acc, 'RSPA%02d%02d' % (n, fi), 2 * S)

# old layers no longer drawn (11-07: the assembly is baked)
for old in glob.glob(os.path.join(G, 'RSPI[0-9][0-9][ROD].png')) + glob.glob(os.path.join(G, 'RSPFLSH.png')):
    os.remove(old)
for n in range(1, 11):
    R, O, D = icon_layers(n)
    save_a(over(over(R, O), D), 'RSPI%02dF' % n, S)
    assembly(n, R, O, D)

# the solid colours (opaque) and the slot
def solid(name, rgb, size=16):
    Image.new('RGBA', (size, size), rgb + (255,)).save(os.path.join(G, name + '.png'))
solid('RSPK0B', (0x0b, 0x0b, 0x0d)); solid('RSPK20', (0x20, 0x20, 0x24)); solid('RSPK17', (0x17, 0x07, 0x08)); solid('RSPKDD', (0xdd, 0xdd, 0xdd))
SL = Image.new('L', (N, N), 0); ImageDraw.Draw(SL).ellipse([2, 2, N - 3, N - 3], fill=255)
SL = SL.resize((S, S), Image.LANCZOS).point(lambda v: 255 if v >= 128 else 0)
slot = Image.new('RGBA', (S, S), (0x0b, 0x0b, 0x0d, 0)); slot.putalpha(SL); slot.save(os.path.join(G, 'RSPSLOT.png'))
# THE CRACK: the mockup's lines on its slot (radius 27): (-16,-18) (-2,-2) (-8,6) (14,20); (-2,-2) (16,-10); 3 px wide.
# Drawn on a 64 px square that the plate sizes as the slot's 54 px (so 1 mockup px = 64/54 texels), hard-edged (cut out).
CK = Image.new('L', (N, N), 0); d = ImageDraw.Draw(CK)
u = N / 54.0
P = lambda x, y: (C + x * u, C + y * u)
d.line([P(-16, -18), P(-2, -2), P(-8, 6), P(14, 20)], fill=255, width=int(3 * u + 0.5), joint='curve')
d.line([P(-2, -2), P(16, -10)], fill=255, width=int(3 * u + 0.5))
CK = CK.resize((S, S), Image.LANCZOS).point(lambda v: 255 if v >= 100 else 0)
ck = Image.new('RGBA', (S, S), (0xdd, 0xdd, 0xdd, 0)); ck.putalpha(CK); ck.save(os.path.join(G, 'RSPCRK.png'))
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
