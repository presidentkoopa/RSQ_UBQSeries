#!/usr/bin/env python3
"""find.py <dir> <color> -- frames ranked by how many pixels of a spark colour they show (TEST ONLY).
colour: blue (Special/Guard), purple (Super), orange (Normal), cyan (Hadouken hit)"""
import sys, glob, os
from PIL import Image
d, c = sys.argv[1], sys.argv[2]
test = {'blue': lambda r, g, b: b > 200 and r < 140 and g < 200, 'purple': lambda r, g, b: r > 180 and b > 180 and g < 120,
        'orange': lambda r, g, b: r > 220 and 80 < g < 200 and b < 80, 'cyan': lambda r, g, b: g > 200 and b > 220 and r < 170}[c]
out = []
for f in sorted(glob.glob(d + '/*.png')):
    im = Image.open(f).convert('RGB').resize((80, 80))
    n = sum(1 for p in im.get_flattened_data() if test(*p))
    if n: out.append((n, os.path.basename(f)))
first = sorted(out, key=lambda x: x[1])[:3]
print('first:', first, ' top:', sorted(out, reverse=True)[:6])
