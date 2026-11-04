#!/usr/bin/env python3
"""gen_cdbar.py -- the Real-Time Countdown bar's art (tool only; never ships).

The owner, 2026-11-03 19:06: "another UI bar, like the two you designed ... horizontal". The same family as the SlowMo
and Berserk gauges (VisualRewards/tools/gen_gauges.py): coldcite's Top HP Bars style-A bar (112 x 11, "Feel free to use
this in your mods"), here left lying as he drew it, the fill draining from the right:

    RSQSMHE.png   the empty bar: his rim (HP_A_00), with a dark, half-clear well so the green reads on a bright wall
    RSQSMHW.png   the full bar in white (HP_A_99, each pixel's brightness kept against the fill's mean, so his blocks
                  stay): the HUD tints it and draws its light (the sweeping band, the glint) with it

Reads coldcite's originals from VisualRewards/original_1.04 (read only). Run from anywhere: python SlowMo/tools/gen_cdbar.py"""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(HERE)
SRC = os.path.join(os.path.dirname(MOD), 'VisualRewards', 'original_1.04', 'graphics')
OUT = os.path.join(MOD, 'graphics')
RIM = (50, 50, 50)
WELL = (6, 14, 8, 120)


def luma(p): return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]


def main():
    empty = Image.open(os.path.join(SRC, 'HP_A_00.png')).convert('RGBA')
    full = Image.open(os.path.join(SRC, 'HP_A_99.png')).convert('RGBA')
    e = empty.copy(); pe = e.load()
    w = full.copy(); pw = w.load()
    fill = [(x, y) for y in range(w.size[1]) for x in range(w.size[0]) if pw[x, y][3] > 0 and pw[x, y][:3] != RIM]
    mean = sum(luma(pw[x, y]) for x, y in fill) / max(1, len(fill))
    for x, y in fill:
        if pe[x, y][3] == 0: pe[x, y] = WELL
        k = min(255, int(255 * luma(pw[x, y]) / mean))
        pw[x, y] = (k, k, k, pw[x, y][3])
    os.makedirs(OUT, exist_ok=True)
    e.save(os.path.join(OUT, 'RSQSMHE.png'), optimize=True)
    w.save(os.path.join(OUT, 'RSQSMHW.png'), optimize=True)
    print('RSQSMHE / RSQSMHW -> %s (%d x %d)' % (OUT, w.size[0], w.size[1]))


if __name__ == '__main__':
    main()
