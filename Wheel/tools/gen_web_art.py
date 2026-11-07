#!/usr/bin/env python3
"""RSQ Wheel: the holster web's art (owner's mock-ups 2026-11-07; design/PARKED.md "Wheel holster web").

Writes, into graphics/:
  WREWPAN.png   the web's panel: rgba(16,40,46) filled, opaque, rounded, with a #2fb8c8 border (the mock-ups' colours)
  WREWRING.png  a soft ring (drawn AddShaded, so the grey is its strength): a holster ring on the web, and the
                soft ring that flashes round a card on every toggle
  WREWLINE.png  a soft line (AddShaded): the threads from the card to the holster rings
The marine on the panel is not drawn here: it is the load order's own PLAYA1 sprite, used by name.
Run from anywhere: python3 Wheel/tools/gen_web_art.py"""
import os
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(HERE)
G = os.path.join(W, 'graphics')
SS = 4


def grey_rgba(v):
    a = np.clip(np.asarray(v, dtype=np.float32), 0, 255).astype(np.uint8)
    return Image.fromarray(np.dstack([a, a, a, np.full_like(a, 255)]), 'RGBA')


# ---- the panel: 160 x 200, radius 12, a 3 px border
w, h, r, rim = 160, 200, 12, 3
big = Image.new('RGBA', (w * SS, h * SS), (0, 0, 0, 0))
d = ImageDraw.Draw(big)
d.rounded_rectangle((0, 0, w * SS - 1, h * SS - 1), r * SS, fill=(0x2f, 0xb8, 0xc8, 255))
d.rounded_rectangle((rim * SS, rim * SS, (w - rim) * SS - 1, (h - rim) * SS - 1), (r - rim) * SS, fill=(16, 40, 46, 255))   # opaque: the panel hides what is behind it (coordinator 2026-11-07)
big.resize((w, h), Image.LANCZOS).save(os.path.join(G, 'WREWPAN.png'))

# ---- the soft ring: 64 x 64, radius 0.78 of the half size, soft both sides
n = 64
y, x = np.mgrid[0:n, 0:n] + 0.5
rr = np.hypot(x - n / 2, y - n / 2) / (n / 2)
ring = np.exp(-((rr - 0.78) / 0.085) ** 2)
grey_rgba(ring * 255).save(os.path.join(G, 'WREWRING.png'))

# ---- the line: 32 x 8, bright along the middle, soft at the edges
yy = (np.arange(8) + 0.5) / 8 * 2 - 1
col = np.exp(-(yy / 0.45) ** 2)
grey_rgba(np.repeat(col[:, None], 32, 1) * 255).save(os.path.join(G, 'WREWLINE.png'))
print('wrote WREWPAN.png WREWRING.png WREWLINE.png')
