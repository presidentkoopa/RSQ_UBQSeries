#!/usr/bin/env python3
"""TEST ONLY: cut an rcC strip run (one row of thirteen per class: as shipped + the twelve colours, 40 apart at x -60,
the player at x -320 on rig01, 480x480 frames) into one sheet: per class a front row and a dead row.

    rcC_strip_sheet.py FRAMES OUT.jpg "TITLE" Class:front:dead[:untinted[:label1:label2]] ...   (frame numbers, 0 = none)
untinted: how many of the first rungs RSQ Monsters left without a tint (the run log's 'RC2 imp i rung r trans 0': a class
whose ladder starts above Green keeps those rungs as shipped); their tiles are marked, not the art's doing."""
import sys, os
import numpy as np
from PIL import Image, ImageDraw

NAMES = ['as shipped', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']
Y0, Y1, HW, SC = 196, 330, 18, 3

def col_x(i):
    y = -240 + 40 * i
    return int(round(240 - 240 * y / 260.0))

def main():
    frames, out, title = sys.argv[1:4]
    rows = []
    for a in sys.argv[4:]:
        w = a.split(':'); c, f, d = w[:3]; u = int(w[3]) if len(w) > 3 else 1
        l1, l2 = (w[4], w[5]) if len(w) > 5 else ('front', 'dead')
        for lab, n in ((l1, int(f)), (l2, int(d))):
            if n: rows.append((c, lab, n, u))
    tw, th = 2 * HW * SC, (Y1 - Y0) * SC
    side, top = 150, 44
    W, H = side + 13 * (tw + 3), top + len(rows) * (th + 4) + 6
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((6, 4), title, fill=(235, 235, 235))
    dr.text((6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, sector light 224, art on; 480x480 frames x%d, frame number per row." % SC, fill=(170, 170, 170))
    for i, n in enumerate(NAMES): dr.text((side + i * (tw + 3) + 2, top - 12), n, fill=(235, 235, 235))
    for r, (c, lab, n, u) in enumerate(rows):
        F = np.asarray(Image.open(os.path.join(frames, 'f%05d.ppm' % n)).convert('RGB'))
        y = top + r * (th + 4)
        dr.text((6, y + th // 2 - 12), c, fill=(235, 235, 235)); dr.text((6, y + th // 2), '%s f%d' % (lab, n), fill=(200, 200, 90))
        for i in range(13):
            x = col_x(i)
            t = F[Y0:Y1, max(0, x - HW):x + HW]
            S.paste(Image.fromarray(t).resize((tw, th), Image.NEAREST), (side + i * (tw + 3), y))
            if 0 < i < u:
                dr.rectangle([side + i * (tw + 3), y, side + i * (tw + 3) + tw - 1, y + 13], fill=(0, 0, 0))
                dr.text((side + i * (tw + 3) + 2, y + 1), 'no tint (ladder)', fill=(255, 120, 120))
    S.save(out, quality=90); print(out, S.size)

if __name__ == '__main__':
    main()
