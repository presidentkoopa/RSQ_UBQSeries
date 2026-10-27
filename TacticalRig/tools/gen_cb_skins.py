#!/usr/bin/env python3
"""gen_cb_skins.py -- the holster spheres' colour-blind skins (rsqa_colorblind, RSQ_Accessibility).

Writes models/rsqtr/rtwcb<v><k>.png, 8x8 flat like the stock rtwire skins: v = p (protanopia and
deuteranopia), t (tritanopia), h (high contrast); k = 0 hand inside, 1-4 the holster profiles.
The colours were picked by farthest-point search over a 6-level RGB grid (each colour at least
one channel >= 204) to maximise the smallest CIEDE2000 between the five after simulation
(RSQ_Accessibility tools/cvd.py: Machado 2009 and Vienot 1999), modelled as the additive wire is
drawn (0.55 of the colour over a dark wall, 403428), "inside" fixed to the series' HAVE colour:
  p  min 21.3   t  min 29.9   h  min 17.4 (the stock five: protan 6.1, deutan 8.2, tritan 13.3
  as flat colours)
MODELDEF.txt frames RSTM F-J (p), K-O (t), P-T (h) wear them, in that order.
"""
import os
from PIL import Image
SETS = {
    'p': [0x3090FF, 0xFFFF00, 0xCC0033, 0x99FFFF, 0x0000CC],
    't': [0x00E0E0, 0xFF0000, 0x0000FF, 0xFFFFFF, 0x6600FF],
    'h': [0xFF40FF, 0x99FF00, 0xFFFFFF, 0xCC0000, 0x0000CC],
}
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'models', 'rsqtr')
for v, cols in SETS.items():
    for k, c in enumerate(cols):
        Image.new('RGB', (8, 8), ((c >> 16) & 255, (c >> 8) & 255, c & 255)).save(os.path.join(out, 'rtwcb%s%d.png' % (v, k)))
print('wrote', sum(len(c) for c in SETS.values()), 'skins to', os.path.normpath(out))
