#!/usr/bin/env python3
# TEST ONLY. A labelled contact sheet of rig frame dumps:  sheet.py <frame dir> <first> <last> <out.png> [crop]
# crop "x0 y0 x1 y1" (fractions) to zoom on the middle of the view.
import sys, os
from PIL import Image, ImageDraw
d, a, b, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
crop = [float(v) for v in sys.argv[5].split()] if len(sys.argv) > 5 else None
fs = [f for f in sorted(os.listdir(d)) if f.endswith(".ppm") and a <= int(f[1:6]) <= b]
ims = []
for f in fs:
    im = Image.open(os.path.join(d, f)).convert("RGB")
    if crop:
        w, h = im.size
        im = im.crop((int(crop[0] * w), int(crop[1] * h), int(crop[2] * w), int(crop[3] * h))).resize((240, 240))
    ImageDraw.Draw(im).text((3, 3), f[1:6], fill=(255, 255, 0))
    ims.append(im)
cols = 4
rows = (len(ims) + cols - 1) // cols
W, H = ims[0].size
sheet = Image.new("RGB", (W * cols, H * rows))
for i, im in enumerate(ims):
    sheet.paste(im, ((i % cols) * W, (i // cols) * H))
sheet.save(out)
print(len(ims), "frames ->", out)
