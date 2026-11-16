#!/usr/bin/env python3
"""gen_exbar.py -- the Big Boss bar's icon (bigboss.zs / hud.zs DrawExBar; owner 2026-11-16 08:40, design/BIG_BOSS.md).

    RSQMBEK0.png  16 x 16, dim: the Big Boss's skull while the bar fills (drawn whole)
    RSQMBEK1.png  16 x 16, lit: drawn over it from the bottom up to the bar's fill, as the Boss meter's crowned skull

The Boss meter's crowned skull (RSQMBSK*, VisualRewards/tools/gen_gauges.py SK: same grid) made the Big Boss's, to match
the bar (owner 11-16 09:5x: "Black with a red edge"): the skull and crown BLACK, its edge (the outline) RED, a ruby set in
the crown, red eyes. Same size, so it sits where the meter's skull sits on its row. (Gold before, provisional.)

    RSQMBWC2.png  the Start Fight card while a Big Boss is due (bossfight.zs WristCard): BIG (skull) BOSS! in the banners'
                  red letters (RSSCFON's, VisualRewards' RQVBE*, the red bands), on the card's dark plate with a red border; the gold card
                  (RSQMBWC1, START (skull) FIGHT?) is a Boss's. 92 px high as the others.

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

LIT = {'#': (225, 32, 26), 'o': (44, 40, 48), 'g': (255, 60, 50), 'w': (24, 22, 28), 'r': (255, 70, 40)}
DIM = {'#': (110, 22, 20), 'o': (26, 24, 28), 'g': (95, 20, 20), 'w': (16, 15, 18), 'r': (80, 22, 18)}
LETTERS = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'VisualRewards', 'pk3',
                       'graphics', 'rsqvrbn')


def icon(pal):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    for y, r in enumerate(EK):
        for x, ch in enumerate(r[:16]):
            if ch in pal:
                p[x, y] = pal[ch] + (255,)
    return im


def letter(c, k):
    im = Image.open(os.path.join(LETTERS, 'RQVBE%03d.png' % ord(c))).convert('RGBA')
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def outlined(im, o, col=(10, 6, 6, 255)):
    out = Image.new('RGBA', (im.width + 2 * o, im.height + 2 * o), (0, 0, 0, 0))
    a = im.split()[3]
    sil = Image.new('RGBA', im.size, col)
    for dx in range(-o, o + 1):
        for dy in range(-o, o + 1):
            if dx or dy:
                out.paste(sil, (o + dx, o + dy), a)
    out.paste(im, (o, o), im)
    return out


def card():
    k, o, gap = 6, 3, 6
    words = ['BIG', None, 'BOSS!']
    pieces = []
    for w in words:
        if w is None:
            sk = icon(LIT).resize((72, 72), Image.NEAREST)
            pieces.append(sk)
            continue
        ls = [letter(c, k) for c in w]      # (the banded letters carry their own outline)
        wd = sum(l.width for l in ls) + gap * (len(ls) - 1)
        img = Image.new('RGBA', (wd, max(l.height for l in ls)), (0, 0, 0, 0))
        x = 0
        for l in ls:
            img.paste(l, (x, 0), l)
            x += l.width + gap
        pieces.append(img)
    pad, sp = 22, 24
    W = sum(p.width for p in pieces) + sp * (len(pieces) - 1) + 2 * pad
    H = 92
    im = Image.new('RGBA', (W, H), (14, 10, 10, 215))
    px = im.load()
    for x in range(W):
        for y in range(H):
            if x < 3 or y < 3 or x >= W - 3 or y >= H - 3:
                px[x, y] = (220, 30, 24, 255)
    x = pad
    for p in pieces:
        im.paste(p, (x, (H - p.height) // 2), p)
        x += p.width + sp
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    card().save(os.path.join(OUT, 'RSQMBWC2.png'), optimize=True)
    print('RSQMBWC2 ->', OUT, '(the Start Fight card while a Big Boss is due)')
    icon(DIM).save(os.path.join(OUT, 'RSQMBEK0.png'), optimize=True)
    icon(LIT).save(os.path.join(OUT, 'RSQMBEK1.png'), optimize=True)
    print('RSQMBEK0 / RSQMBEK1 ->', OUT, '(16 x 16, the Big Boss bar icon)')


if __name__ == '__main__':
    main()
