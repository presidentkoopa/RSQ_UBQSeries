#!/usr/bin/env python3
"""gen_keyring.py -- the keyring (owner 2026-10-31: "we don't have a keyring model"): a steel ring 5 cm across with a
0.5 cm wire, in MAP units (34 a metre) so MODELDEF draws it at Scale 1; and its 8x8 steel skin.
Writes models/rsqtr/rtkeyring.md3 and rtkeyring.png."""
import math, os, sys
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
from gen_handprops import write_md3, enc_n
M = os.path.join(os.path.dirname(HERE), 'models', 'rsqtr')
UPM = 34.0
R, r = 0.025 * UPM, 0.0025 * UPM       # ring radius, wire radius (map units): 5 cm across, big enough to see looking down
NU, NV = 24, 8
verts, uvs, tris = [], [], []
for i in range(NU + 1):
    u = 2 * math.pi * i / NU
    for j in range(NV + 1):
        v = 2 * math.pi * j / NV
        # the ring stands upright (in the X-Z plane), its hole facing forward, hanging from the belt
        x = (R + r * math.cos(v)) * math.cos(u); z = (R + r * math.cos(v)) * math.sin(u); y = r * math.sin(v)
        n = (math.cos(v) * math.cos(u), math.sin(v), math.cos(v) * math.sin(u))
        verts.append(((x, y, z), enc_n(n))); uvs.append((i / NU, j / NV))
for i in range(NU):
    for j in range(NV):
        a = i * (NV + 1) + j; b = a + NV + 1
        tris += [(a, b, a + 1), (a + 1, b, b + 1)]
surf = dict(name=b'keyring'.ljust(64, b'\0'), shaders=[b'rtkeyring.png'.ljust(64, b'\0')], tris=tris, uvs=uvs, frames=[verts])
write_md3(os.path.join(M, 'rtkeyring.md3'), [surf], 1)
im = Image.new('RGB', (8, 8))
for yy in range(8):
    for xx in range(8): im.putpixel((xx, yy), (150 + 12 * (yy % 4), 154 + 12 * (yy % 4), 162 + 12 * (yy % 4)))
im.save(os.path.join(M, 'rtkeyring.png'))
print('keyring: %d verts, %d tris, %.2f map units across' % (len(verts), len(tris), 2 * (R + r)))
