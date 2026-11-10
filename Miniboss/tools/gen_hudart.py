#!/usr/bin/env python3
"""gen_hudart.py -- the fight's HUD stack art (hud.zs DrawStack), written into Miniboss/graphics/:
  RSQMBWH.png  8 x 8 white: the boxes (the window bar's border, track and fill, tinted by DTA_Color)
python3 -I Miniboss/tools/gen_hudart.py
"""
import os
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'graphics')

def main():
    Image.new('RGBA', (8, 8), (255, 255, 255, 255)).save(os.path.join(OUT, 'RSQMBWH.png'))
    print('wrote RSQMBWH.png')


if __name__ == '__main__':
    main()
