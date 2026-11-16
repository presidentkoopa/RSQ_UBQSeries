#!/usr/bin/env python3
"""gen_exbar.py -- the Big Boss bar's icon (bigboss.zs / hud.zs DrawExBar; owner 2026-11-16 08:40, design/BIG_BOSS.md).

    RSQMBEK0.png  16 x 16, dim: the Big Boss's skull while the bar fills (drawn whole)
    RSQMBEK1.png  16 x 16, lit: drawn over it from the bottom up to the bar's fill, as the Boss meter's crowned skull

The Boss meter's crowned skull (RSQMBSK*, VisualRewards/tools/gen_gauges.py SK: same grid, same outline) made the Big Boss's:
the skull itself GOLD (the bar's colour, the legendary colour; provisional), a ruby set in the crown, white-hot eyes. Same
size and outline, so it sits where the meter's skull sits on its row.

python3 -I Miniboss/tools/gen_exbar.py
"""
import os
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'graphics')

# the meter's skull (gen_gauges.py SK) with a ruby ('g') in the crown's middle point
EK = ['#..#...##...#..#',
      '#o#.#.#gg#.#.#o#',
      '#oo#o#oggo#o#oo#',
      '.#oooooooooooo#.',
      '.#oooooooooooo#.',
      '..############..',
      '.#wwwwwwwwwwww#.',
      '#wwwwwwwwwwwwww#',
      '#ww###wwww###ww#',
      '#ww#r#wwww#r#ww#',
      '#ww###w##w###ww#',
      '.#wwwww##wwwww#.',
      '..#wwwwwwwwww#..',
      '..#w#w#w#w#w#..',
      '...#w#w#w#w#...',
      '....########....']

LIT = {'#': (15, 15, 15), 'o': (255, 246, 200), 'g': (235, 30, 60), 'w': (250, 192, 36), 'r': (255, 252, 228)}
DIM = {'#': (15, 15, 15), 'o': (150, 135, 95), 'g': (100, 25, 35), 'w': (120, 92, 30), 'r': (70, 60, 40)}


def icon(pal):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    for y, r in enumerate(EK):
        for x, ch in enumerate(r[:16]):
            if ch in pal:
                p[x, y] = pal[ch] + (255,)
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    icon(DIM).save(os.path.join(OUT, 'RSQMBEK0.png'), optimize=True)
    icon(LIT).save(os.path.join(OUT, 'RSQMBEK1.png'), optimize=True)
    print('RSQMBEK0 / RSQMBEK1 ->', OUT, '(16 x 16, the Big Boss bar icon)')


if __name__ == '__main__':
    main()
