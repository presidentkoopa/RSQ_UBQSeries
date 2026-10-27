#!/usr/bin/env python3
"""shots.py <frames dir> [crop x0 y0 x1 y1] -- decode the frame id the probe draws into the eye
(8 blocks, top-left: magenta = 1) and keep the LAST frame of each id as shot_<id>.png (cropped/scaled x2)."""
import sys, glob, os
from PIL import Image
d = sys.argv[1]
crop = [int(v) for v in sys.argv[2:6]] if len(sys.argv) >= 6 else None
last = {}
for f in sorted(glob.glob(os.path.join(d, 'f*.png'))):
    im = Image.open(f).convert('RGB'); w, h = im.size
    bs = max(4, w // 50); v = 0
    for b in range(8):
        p = im.getpixel((b * bs + bs // 2, bs // 2))
        if p[0] > 200 and p[1] < 60 and p[2] > 200: v |= 1 << b
    if v: last[v] = f
for v, f in sorted(last.items()):
    im = Image.open(f)
    if crop: im = im.crop(crop).resize(((crop[2]-crop[0])*2, (crop[3]-crop[1])*2), Image.NEAREST)
    out = os.path.join(d, 'shot_%d.png' % v); im.save(out); print(v, os.path.basename(f), '->', out)
