#!/usr/bin/env python3
"""Cut a rig run's frames into a per-colour sheet: one column per imp of the demo row (as shipped, then Green .. White),
one row per chosen frame. Columns are found from the alive frame against the empty room.

    rig_sheet.py FRAMES_DIR X_FIRST X_LAST OUT.png Y0 Y1 SCALE FRAME[:label] [FRAME[:label] ...]

X_FIRST / X_LAST: the screen x of the first imp (as shipped) and the last (White). The demo row stands on a line
square to the view, so the imps are evenly spaced on screen (a pinhole projection of a line at one depth).
"""
import sys, glob, os
import numpy as np
from PIL import Image, ImageDraw

NAMES = ['as shipped', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']

def load(d, n):
    return np.asarray(Image.open(os.path.join(d, 'f%05d.ppm' % n)).convert('RGB')).astype(int)

def main():
    d, xf, xl, out, y0, y1, sc = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4], int(sys.argv[5]), int(sys.argv[6]), int(sys.argv[7])
    rows = []
    for a in sys.argv[8:]:
        n, _, lab = a.partition(':'); rows.append((int(n), lab or 'f%d' % int(n)))
    centres = [round(xf + (xl - xf) * i / 12) for i in range(13)]
    half = int(abs(xl - xf) / 12 / 2)
    tw, th, lab_h, side = half * 2 * sc, (y1 - y0) * sc, 14, 80
    sheet = Image.new('RGB', (side + tw * 13, lab_h + th * len(rows)), (24, 24, 24))
    dr = ImageDraw.Draw(sheet)
    for i in range(13):
        dr.text((side + i * tw + 3, 1), NAMES[i], fill=(230, 230, 230))
    for r, (n, lab) in enumerate(rows):
        F = load(d, n)[y0:y1].astype(np.uint8)
        dr.text((3, lab_h + r * th + th // 2 - 6), lab, fill=(230, 230, 230))
        for i, c in enumerate(centres):
            tile = Image.fromarray(F[:, c - half:c + half]).resize((tw, th), Image.NEAREST)
            sheet.paste(tile, (side + i * tw, lab_h + r * th))
    sheet.save(out)
    print(out, sheet.size)

if __name__ == '__main__':
    main()
