#!/usr/bin/env python3
"""sheet.py <dir> <first> <last> <step> <out.png> [cols] [crop x0 y0 x1 y1] -- a contact sheet of rig frame dumps (TEST ONLY)"""
import sys, os
from PIL import Image, ImageDraw
d, a, b, st, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
cols = int(sys.argv[6]) if len(sys.argv) > 6 else 6
crop = tuple(map(int, sys.argv[7:11])) if len(sys.argv) > 10 else None
fs = [os.path.join(d, f'f{i:05d}.png') for i in range(a, b + 1, st) if os.path.exists(os.path.join(d, f'f{i:05d}.png'))]
ims = [Image.open(f).convert('RGB') for f in fs]
if crop: ims = [i.crop(crop) for i in ims]
w, h = ims[0].size
rows = (len(ims) + cols - 1) // cols
sh = Image.new('RGB', (cols * w, rows * (h + 14)), (0, 0, 0))
dr = ImageDraw.Draw(sh)
for k, (f, im) in enumerate(zip(fs, ims)):
    x, y = (k % cols) * w, (k // cols) * (h + 14)
    sh.paste(im, (x, y + 14)); dr.text((x + 2, y), os.path.basename(f), fill=(255, 255, 0))
sh.save(out); print(out, len(ims))
