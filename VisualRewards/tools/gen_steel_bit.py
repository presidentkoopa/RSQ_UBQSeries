#!/usr/bin/env python3
"""gen_steel_bit.py -- the steel bit's sprites (design/WEAPON_CONDITION.md, owner 2026-11-16: steel kill-reward bits repair
the guns in your hands): SoM's health orb (pk3/sprites/rsqkr/KRBHA0.png) recoloured to steel grey (a blue-grey body, a dark
gunmetal rim, a cold white shine), so it never reads as the armour bit's blue or the gold bit; frame B adds a white glint at
the upper right (the bit twinkles A, B, as the gold one does). Its floor offset (grAb) kept. The gold bit's tool
(gen_gold_bit.py) with steel colours. Writes pk3/sprites/rsqkr/KRBSA0.png and KRBSB0.png.
    python3 -I VisualRewards/tools/gen_steel_bit.py"""
import io, os, struct, zlib
from PIL import Image
P = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'pk3', 'sprites', 'rsqkr')
MAP = {(237, 28, 36): (150, 160, 176), (136, 0, 21): (58, 64, 76), (255, 174, 201): (232, 238, 248)}
src = open(os.path.join(P, 'KRBHA0.png'), 'rb').read()
grab = None; i = 8
while i < len(src):
    n, t = struct.unpack('>I4s', src[i:i + 8])
    if t == b'grAb': grab = src[i + 8:i + 16]
    i += 12 + n
base = Image.open(io.BytesIO(src)).convert('RGBA')


def write(im, name):
    buf = io.BytesIO(); im.save(buf, 'PNG'); d = buf.getvalue()
    if grab:
        body = b'grAb' + grab
        chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
        ihdr_end = 8 + 12 + struct.unpack('>I', d[8:12])[0]
        d = d[:ihdr_end] + chunk + d[ihdr_end:]
    open(os.path.join(P, name), 'wb').write(d)
    print(name, im.size, 'grAb', struct.unpack('>ii', grab) if grab else None)


a = base.copy(); px = a.load()
for y in range(a.size[1]):
    for x in range(a.size[0]):
        r, g, b, al = px[x, y]
        if al and (r, g, b) in MAP: px[x, y] = MAP[(r, g, b)] + (al,)
write(a, 'KRBSA0.png')
# frame B: a white glint (a small plus) on the upper right of the orb
b = a.copy(); pb = b.load()
xs = [x for x in range(b.size[0]) for y in range(b.size[1]) if pb[x, y][3]]
ys = [y for x in range(b.size[0]) for y in range(b.size[1]) if pb[x, y][3]]
cx, cy = max(xs) - 2, min(ys) + 2
for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
    if pb[cx + dx, cy + dy][3]: pb[cx + dx, cy + dy] = (255, 255, 255, 255)
write(b, 'KRBSB0.png')
