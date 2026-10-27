#!/usr/bin/env python3
"""phases.py <frames dir> <out.png> [per=3] -- for each frame id the probe drew (thpt_shot), take `per`
frames spread across that id's window and lay them out one row per id, labelled."""
import sys, glob, os
from PIL import Image, ImageDraw
d, out = sys.argv[1], sys.argv[2]; per = int(sys.argv[3]) if len(sys.argv) > 3 else 3
def code(f):
    im = Image.open(f).convert('RGB'); bs = max(4, im.size[0] // 50); v = 0
    for b in range(8):
        p = im.getpixel((b * bs + bs // 2, bs // 2))
        if p[0] > 200 and p[1] < 60 and p[2] > 200: v |= 1 << b
    return v
groups = {}
for f in sorted(glob.glob(os.path.join(d, 'f*.png'))):
    v = code(f)
    if v: groups.setdefault(v, []).append(f)
w, h = Image.open(next(iter(groups.values()))[0]).size
m = Image.new('RGB', (w * per, (h + 14) * len(groups))); dr = ImageDraw.Draw(m)
for r, (v, fs) in enumerate(sorted(groups.items())):
    pick = [fs[int(i * (len(fs) - 1) / max(1, per - 1))] for i in range(per)] if len(fs) >= per else fs
    for c, f in enumerate(pick):
        m.paste(Image.open(f).convert('RGB'), (c * w, r * (h + 14) + 14))
        dr.text((c * w + 4, r * (h + 14)), 'id %d  %s' % (v, os.path.basename(f)), fill=(255, 255, 0))
m.save(out); print(out, {k: len(v) for k, v in groups.items()})
