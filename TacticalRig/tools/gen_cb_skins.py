#!/usr/bin/env python3
"""gen_cb_skins.py -- the holster spheres' utility-place skin (MODELDEF.txt frame RSTM U), 8x8 flat like the stock
rtwire skins. The colour-blind skins it also wrote (rtwcb*.png, RSQ Accessibility's colour-blind play) went with that
mod, removed 2026-11-27.
"""
import os
from PIL import Image
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'models', 'rsqtr')
# UTILITY PLACES (owner 11-05 01:07): a colour for the places no gun goes in, picked by farthest-point search against the
# stock six: rtwireut FF00FF (16.7 from the stock six).
UTIL = {'rtwireut': 0xFF00FF}
for n, c in UTIL.items():
    Image.new('RGB', (8, 8), ((c >> 16) & 255, (c >> 8) & 255, c & 255)).save(os.path.join(out, n + '.png'))
print('wrote', len(UTIL), 'skins to', os.path.normpath(out))
