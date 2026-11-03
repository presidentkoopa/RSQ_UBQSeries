#!/usr/bin/env python3
"""TEST ONLY. montage.py <out.png> <cols> <label=path>...: a labelled grid of rig frames."""
import sys
from PIL import Image, ImageDraw
out, cols = sys.argv[1], int(sys.argv[2])
items = [a.rsplit('=', 1) for a in sys.argv[3:]]
ims = []
for lab, p in items:
    try: im = Image.open(p).convert('RGB')
    except Exception: im = Image.new('RGB', (320, 320), (60, 0, 0))
    ims.append((lab, im))
w, h = ims[0][1].size
rows = (len(ims) + cols - 1) // cols
M = Image.new('RGB', (cols * w, rows * (h + 16)), (0, 0, 0))
d = ImageDraw.Draw(M)
for i, (lab, im) in enumerate(ims):
    x, y = (i % cols) * w, (i // cols) * (h + 16)
    M.paste(im, (x, y + 16)); d.text((x + 4, y + 2), lab, fill=(255, 255, 0))
M.save(out)
print(out, M.size)
