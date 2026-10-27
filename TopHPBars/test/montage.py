#!/usr/bin/env python3
"""montage.py out.png x0 y0 x1 y1 scale label=file ... -- stack the same crop of several frames, labelled."""
import sys
from PIL import Image, ImageDraw
out = sys.argv[1]; x0, y0, x1, y1, sc = [int(v) for v in sys.argv[2:7]]
items = [a.rsplit('=', 1) for a in sys.argv[7:]]
w, h = (x1 - x0) * sc, (y1 - y0) * sc
m = Image.new('RGB', (w, (h + 16) * len(items)), (0, 0, 0)); d = ImageDraw.Draw(m)
for i, (lab, f) in enumerate(items):
    im = Image.open(f).convert('RGB').crop((x0, y0, x1, y1)).resize((w, h), Image.NEAREST)
    m.paste(im, (0, i * (h + 16) + 16)); d.text((4, i * (h + 16) + 2), lab, fill=(255, 255, 255))
m.save(out); print(out)
