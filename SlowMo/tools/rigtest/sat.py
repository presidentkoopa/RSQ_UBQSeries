#!/usr/bin/env python3
# TEST ONLY. Mean saturation and luminance of each rig frame dump (left eye):  sat.py <frame dir> [png out]
# HSV saturation of the frame's pixels; the colour drain (rsqsm_drain) should lower saturation
# while the luminance stays about the same.
import sys, os
from PIL import Image
d = sys.argv[1]
files = sorted(f for f in os.listdir(d) if f.endswith(".ppm"))
for f in files:
    im = Image.open(os.path.join(d, f)).convert("RGB")
    hsv = im.convert("HSV")
    s = list(hsv.getdata(1)); v = list(hsv.getdata(2))
    print(f, "sat %.1f  val %.1f" % (sum(s) / len(s), sum(v) / len(v)))
if len(sys.argv) > 2 and len(files) >= 2:
    a = Image.open(os.path.join(d, files[2])).convert("RGB"); b = Image.open(os.path.join(d, files[-2])).convert("RGB")
    out = Image.new("RGB", (a.width * 2, a.height)); out.paste(a, (0, 0)); out.paste(b, (a.width, 0))
    out.save(sys.argv[2])
