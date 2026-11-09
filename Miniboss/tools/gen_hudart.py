#!/usr/bin/env python3
"""gen_hudart.py -- the fight's HUD stack art (hud.zs DrawStack), written into Miniboss/graphics/:
  RSQMBWH.png  8 x 8 white: the boxes (the window bar's border, track and fill, tinted by DTA_Color)
  RSQMBSH.png  16 x 16: the shield icon over the thrall bar while the miniboss is immune. PLACEHOLDER ART: the series has
               no shield art yet; this is the mockup's (design/mockups/miniboss/src/panels.py SHIELD), drawn on the
               Bossfight skull's 16 x 16 grid and outline.
python3 -I Miniboss/tools/gen_hudart.py
"""
import os
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'graphics')

SHIELD = ['.##############.',
          '#hhhhhhhhhhhhhs#',
          '#hwwwwwwwwwwwws#',
          '#hwwwwwssswwwws#',
          '#hwwwwwsdswwwws#',
          '#hwwssssdsssswd#',
          '#hwwsddddddddsd#',
          '#hwwssssdsssssd#',
          '.#wwwwwsdswwwd#.',
          '.#wwwwwsdswwwd#.',
          '..#wwwwsdswwd#..',
          '..#wwwwsssswd#..',
          '...#wwwwwwwd#...',
          '....#wwwwwd#....',
          '.....#wwdd#.....',
          '......####......']
COL = {'#': (15, 15, 15), 'h': (250, 252, 255), 'w': (196, 202, 214), 's': (150, 156, 170), 'd': (98, 104, 118)}


def main():
    Image.new('RGBA', (8, 8), (255, 255, 255, 255)).save(os.path.join(OUT, 'RSQMBWH.png'))
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    for y, row in enumerate(SHIELD):
        for x, ch in enumerate(row):
            if ch in COL:
                p[x, y] = COL[ch] + (255,)
    im.save(os.path.join(OUT, 'RSQMBSH.png'))
    print('wrote RSQMBWH.png, RSQMBSH.png')


if __name__ == '__main__':
    main()
