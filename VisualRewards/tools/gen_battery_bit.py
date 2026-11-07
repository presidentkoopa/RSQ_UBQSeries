#!/usr/bin/env python3
"""gen_battery_bit.py -- the battery bit's sprite (RSQ FnF's "Bones Drop Battery Bits", owner 2026-11-06): SoM's health orb
(pk3/sprites/rsqkr/KRBHA0.png) recoloured to a battery yellow, its three colours mapped one for one, its floor offset (grAb)
kept. Writes pk3/sprites/rsqkr/KRBBA0.png.   python3 -I VisualRewards/tools/gen_battery_bit.py"""
import io, os, struct, zlib
from PIL import Image
P = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'pk3', 'sprites', 'rsqkr')
MAP = {(237, 28, 36): (255, 214, 32), (136, 0, 21): (176, 120, 0), (255, 174, 201): (255, 248, 196)}
src = open(os.path.join(P, 'KRBHA0.png'), 'rb').read()
grab = None; i = 8
while i < len(src):
    n, t = struct.unpack('>I4s', src[i:i + 8])
    if t == b'grAb': grab = src[i + 8:i + 16]
    i += 12 + n
im = Image.open(io.BytesIO(src)).convert('RGBA'); px = im.load()
for y in range(im.size[1]):
    for x in range(im.size[0]):
        r, g, b, a = px[x, y]
        if a and (r, g, b) in MAP: px[x, y] = MAP[(r, g, b)] + (a,)
buf = io.BytesIO(); im.save(buf, 'PNG'); d = buf.getvalue()
if grab:
    body = b'grAb' + grab
    chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    ihdr_end = 8 + 12 + struct.unpack('>I', d[8:12])[0]
    d = d[:ihdr_end] + chunk + d[ihdr_end:]
open(os.path.join(P, 'KRBBA0.png'), 'wb').write(d)
print('KRBBA0.png', im.size, 'grAb', struct.unpack('>ii', grab) if grab else None)
