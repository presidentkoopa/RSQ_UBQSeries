#!/usr/bin/env python3
"""RSQ Wheel: graphics/WRILOCK.png, the padlock on a card whose gun is locked to its RSQ Tactical Rig holster
(owner 2026-11-06, BUGS_1.0 item 18). Drawn for the Wheel: a 16 x 16 brass padlock with a dark outline."""
import os
from PIL import Image
W = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = [
"................",
".....######.....",
"....#oooooo#....",
"...#oo####oo#...",
"...#o#....#o#...",
"...#o#....#o#...",
"...#o#....#o#...",
".##############.",
".#YYYYYYYYYYYY#.",
".#YyyyyyyyyyyY#.",
".#Yyyyy##yyyyY#.",
".#Yyyyy##yyyyY#.",
".#Yyyyyy#yyyyY#.",
".#YyyyyyyyyyyY#.",
".#yyyyyyyyyyyy#.",
".##############.",
]
C = {'#': (20, 14, 6, 255), 'o': (200, 200, 210, 255), 'Y': (255, 222, 110, 255), 'y': (222, 170, 40, 255), '.': (0, 0, 0, 0)}
im = Image.new('RGBA', (16, 16))
for y, row in enumerate(A):
    for x, ch in enumerate(row): im.putpixel((x, y), C[ch])
im.save(os.path.join(W, 'graphics', 'WRILOCK.png'))
print('ok')
