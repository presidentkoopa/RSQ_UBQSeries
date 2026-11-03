#!/usr/bin/env python3
"""gen_red.py -- TEST/BUILD TOOL (never ships). Writes models/rsqgn/nade_red.png, the fuse flash's red skin:
Gomuz's own nade.png recoloured (each pixel's brightness kept, its colour pushed to a hot red). Nothing drawn new.
    python3 Grenade/tools/gen_red.py"""
import os
from PIL import Image
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'models', 'rsqgn')
im = Image.open(os.path.join(D, 'nade.png')).convert('RGB')
px = im.load()
for y in range(im.size[1]):
    for x in range(im.size[0]):
        r, g, b = px[x, y]
        l = 0.299 * r + 0.587 * g + 0.114 * b
        px[x, y] = (min(255, int(110 + l * 1.2)), int(l * 0.22), int(l * 0.18))
im.save(os.path.join(D, 'nade_red.png'))
print('wrote', os.path.join(D, 'nade_red.png'))
# COOK SENSE 2 (Gun Bonsai VR patch, 11-02): the first half of the fuse flashes amber, the same recolour pushed to amber
im = Image.open(os.path.join(D, 'nade.png')).convert('RGB')
px = im.load()
for y in range(im.size[1]):
    for x in range(im.size[0]):
        r, g, b = px[x, y]
        l = 0.299 * r + 0.587 * g + 0.114 * b
        px[x, y] = (min(255, int(120 + l * 1.15)), min(255, int(60 + l * 0.75)), int(l * 0.12))
im.save(os.path.join(D, 'nade_amber.png'))
print('wrote', os.path.join(D, 'nade_amber.png'))
