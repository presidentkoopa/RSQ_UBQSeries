#!/usr/bin/env python3
"""gen_gold_coin.py -- the gold coin by the bank on Score's HUD (gold.zs, hud.zs DrawGold; design/KIOSK.md, 2026-11-16).
16 x 16 pixel art in the series' icon style ('#' the near-black outline). Writes graphics/RSSCGOLD.png.
    python3 -I Score/tools/gen_gold_coin.py"""
import os
from PIL import Image
# the coin: a disc (outline, lit upper left, dark lower right) with a G stamped in its middle
G = [".###.", "#...#", "#....", "#.###", "#...#", ".###."]
PAL = {'#': (24, 14, 4, 255), 'h': (255, 250, 210, 255), 'l': (255, 222, 90, 255), 'o': (240, 170, 30, 255),
       'd': (170, 100, 10, 255), 'g': (120, 64, 0, 255)}
im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
for y in range(16):
    for x in range(16):
        dx, dy = x - 7.5, y - 7.5
        r = (dx * dx + dy * dy) ** 0.5
        if r > 7.6:
            continue
        if r > 6.5:
            c = '#'
        else:
            k = (dx + dy) / 9.0
            c = 'h' if (k < -0.75 and r > 5.0) else 'l' if k < -0.35 else 'o' if k < 0.45 else 'd'
        im.putpixel((x, y), PAL[c])
for gy, row in enumerate(G):
    for gx, ch in enumerate(row):
        if ch == '#':
            im.putpixel((5 + gx, 5 + gy), PAL['g'])
out = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'graphics', 'RSSCGOLD.png')
im.save(out)
print(out)
