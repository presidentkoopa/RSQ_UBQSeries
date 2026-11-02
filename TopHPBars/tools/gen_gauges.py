#!/usr/bin/env python3
"""gen_gauges.py -- the series' vertical gauges, made from coldcite's Top HP Bars art (tool only; never ships).

The owner, 2026-11-02: "we could repurpose and recolor the TopHPBar as a hud element for SlowMo, arrange it vertically,
change the colors or style." So coldcite's style-A bar (112 x 11, his block texture, "Feel free to use this in your
mods") is stood on end, the fill growing from the bottom, and written as two images per gauge:

    <NAME>E.png   the empty gauge: his empty bar (HP_A_00), its rim and well, rotated
    <NAME>F.png   the full gauge: his full bar (HP_A_99), the fill recoloured pixel by pixel (each pixel keeps its
                  brightness against the fill's mean, so his blocks stay; only the hue changes), rotated

A HUD draws the empty one, then the full one clipped from the top down to its fraction (smooth, not in 5 % steps).

    RSQSMG*  ->  SlowMo/graphics/             SlowMo's adrenaline meter: electric cyan
    RSQGBG*  ->  GunBonsaiOffhandVR/graphics/ Gun Bonsai VR's Berserk Meter: blood red

Run from anywhere: python TopHPBars/tools/gen_gauges.py"""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
TOP = os.path.dirname(HERE)
SERIES = os.path.dirname(TOP)
SRC = os.path.join(TOP, 'original_1.04', 'graphics')
RIM = (50, 50, 50)

GAUGES = [
    ('RSQSMG', os.path.join(SERIES, 'SlowMo', 'graphics'), (60, 220, 255)),
    ('RSQGBG', os.path.join(SERIES, 'GunBonsaiOffhandVR', 'graphics'), (230, 40, 40)),
]


def luma(p): return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]


def recolour_fill(im, colour):
    im = im.convert('RGBA').copy()
    p = im.load()
    fill = [(x, y) for y in range(im.size[1]) for x in range(im.size[0]) if p[x, y][3] > 0 and p[x, y][:3] != RIM]
    mean = sum(luma(p[x, y]) for x, y in fill) / max(1, len(fill))
    for x, y in fill:
        k = luma(p[x, y]) / mean
        p[x, y] = tuple(min(255, int(c * k)) for c in colour) + (p[x, y][3],)
    return im


def main():
    empty = Image.open(os.path.join(SRC, 'HP_A_00.png')).convert('RGBA')
    full = Image.open(os.path.join(SRC, 'HP_A_99.png')).convert('RGBA')
    for name, out, colour in GAUGES:
        os.makedirs(out, exist_ok=True)
        # rotate 90 degrees counter-clockwise: the bar's left end (where it fills from) goes to the bottom
        empty.rotate(90, expand=True).save(os.path.join(out, name + 'E.png'), optimize=True)
        recolour_fill(full, colour).rotate(90, expand=True).save(os.path.join(out, name + 'F.png'), optimize=True)
        print(f'{name}E / {name}F -> {out}  (11 x 112, fill {colour})')


if __name__ == '__main__':
    main()
