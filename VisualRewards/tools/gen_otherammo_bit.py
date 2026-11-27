#!/usr/bin/env python3
"""gen_otherammo_bit.py -- the light green ammo bit's sprite (owner 2026-11-27: "a new kind of bit, a different shade of green ...
these new green bits give ammo for other guns in your inventory"): SoM's ammo orb (pk3/sprites/rsqkr/KRBMA0.png, the
palette's Green) recoloured to the Wheel's green #B8FF30 (owner 2026-11-27, "use this green"; before that: "i asked for lighter or darker green and i got teal"): a pale
green body, a mid green rim, a near-white shine; told from the ammo bit by lightness, which also holds for colour-blind
players. One frame, as the ammo bit (it flickers BRIGHT in its
states). Its floor offset (grAb) kept. The steel bit's tool (gen_steel_bit.py) with these colours. Writes
pk3/sprites/rsqkr/KRBTA0.png.
    python3 -I VisualRewards/tools/gen_otherammo_bit.py"""
import io, os, struct, zlib
from PIL import Image
P = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'pk3', 'sprites', 'rsqkr')
MAP = {(28, 237, 53): (184, 255, 48), (0, 136, 1): (92, 128, 24), (188, 255, 174): (232, 255, 190)}
src = open(os.path.join(P, 'KRBMA0.png'), 'rb').read()
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
left = 0
for y in range(a.size[1]):
    for x in range(a.size[0]):
        r, g, b, al = px[x, y]
        if al and (r, g, b) in MAP: px[x, y] = MAP[(r, g, b)] + (al,)
        elif al: left += 1
if left: print('note:', left, 'pixels kept their colour (not in the map)')
write(a, 'KRBTA0.png')
