#!/usr/bin/env python3
"""RSQ SlowMo -- the off-view turn markers (owner 2026-11-07 05:56 / 05:58; design/NEAR_DEATH.md "v3 off-view turn
markers"). Our own pixel art, nearest-neighbour, no smoothing. Every shape points RIGHT (the plate rolls it toward the
way to turn; behind you = pointing down at the bottom of the ring). Three shapes (style D, Triangle With Afterimages,
reuses A's): A a framed triangle, B a framed fat arrow (head + short shaft), C one chevron (C draws three in a row).
  graphics/rsqsmp/RSPM<s>F   the frame: a 3-band grey stepped bevel (light #d4d8e0 inner, mid #8d93a0, dark #3b404b
                             outer), black inside; drawn as it is (stays grey)
  graphics/rsqsmp/RSPM<s>0-3 the fill: diagonal stripes, white with alpha = brightness, drawn Shaded in the target's
                             colour over the frame's black; a light band sweeps diagonally across (the shimmer).
The motion (wind-up, push, overshoot, settle) is done at run time (plate.zs MarkerMotion), not in the frames.
Run: python3 SlowMo/tools/plate/gen_chevron.py"""
import os
from PIL import Image

MOD = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
G = os.path.join(MOD, 'graphics', 'rsqsmp'); os.makedirs(G, exist_ok=True)
W = H = 24
LIGHT, MID, DARK = (0xd4, 0xd8, 0xe0), (0x8d, 0x93, 0xa0), (0x3b, 0x40, 0x4b)

def tri(x, y, inset):
    cx, cy = x + 0.5, y + 0.5
    if cx < 2 + inset: return False
    return abs(cy - 12) <= (21.5 - inset * 1.6 - cx) * (10.0 / 19.5)

def arrow(x, y, inset):
    cx, cy = x + 0.5, y + 0.5
    if cx >= 10 + inset * 0.0 and abs(cy - 12) <= (22.0 - inset * 1.6 - cx) * (10.5 / 12.0): return cx >= 10 - 0 + (inset if inset else 0) * 0 and True
    return 1 + inset <= cx < 11 and abs(cy - 12) <= 4.0 - inset    # the shaft

def chevron(x, y, inset):
    cx, cy = x + 0.5, y + 0.5
    d = abs(cy - 12)
    # a ">" 9 px thick: between x = 2 + (11 - d) * 0.95 and that + 9, the point at the right
    a = 2 + (11 - d) * 0.95 + inset
    b = a + 9 - 2 * inset
    return d <= 11 - inset * 0.6 and a <= cx <= b

def layer(f, inset): return {(x, y) for x in range(W) for y in range(H) if f(x, y, inset)}

def make(tag, f):
    L0, L1, L2, L3 = layer(f, 0), layer(f, 1), layer(f, 2), layer(f, 3)
    L1 &= L0; L2 &= L1; L3 &= L2
    fr = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    for (x, y) in L0:
        c = DARK if (x, y) not in L1 else (MID if (x, y) not in L2 else (LIGHT if (x, y) not in L3 else (0, 0, 0)))
        fr.putpixel((x, y), c + (255,))
    fr.save(os.path.join(G, 'RSPM%sF.png' % tag))
    BAND = [(None, 0), (8, 1.0), (14, 0.6), (20, 0.25)]   # dull, bright, mid, dull
    for k, (bc, s) in enumerate(BAND):
        im = Image.new('RGBA', (W, H), (255, 255, 255, 0))
        for (x, y) in L3:
            a = 185 if ((x + y) // 2) % 2 == 0 else 125
            if bc is not None and abs((x + (H - y)) * 0.5 - bc) < 2.5: a = int(a + (255 - a) * s)
            im.putpixel((x, y), (255, 255, 255, a))
        im.save(os.path.join(G, 'RSPM%s%d.png' % (tag, k)))

make('A', tri)
make('B', arrow)
make('C', chevron)
print('ok')
