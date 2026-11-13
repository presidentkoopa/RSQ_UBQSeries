#!/usr/bin/env python3
"""TEST ONLY: cut the rc2 rig runs (rc2_full.sh + rc2demo, one run with the old tint-bake art, one with the new art)
into the per-colour sheets and the close-up of all twelve colours.

    rc2_sheets.py OLD_FRAMES NEW_FRAMES OUTDIR

The frame numbers of each phase are picked by eye from the runs (BD's deaths are random, so a run's timing differs);
they are written into the sheets. Two halves: rungs 1-7 (as shipped, Green .. Yellow) then 8-13 (FireBlu .. White),
seven and six imps in a row at x -140, 52 apart, from the player at x -320 (rig01), 480x480 frames."""
import sys, os
import numpy as np
from PIL import Image, ImageDraw

NAMES = {1: 'as shipped', 2: 'Green', 3: 'Blue', 4: 'Purple', 5: 'Cyan', 6: 'Brown', 7: 'Yellow', 8: 'FireBlu',
         9: 'Gray', 10: 'Red', 11: 'Abyss', 12: 'Black', 13: 'White'}
FILE = {r: n.lower() for r, n in NAMES.items()}
PHASES = ['front', 'side', 'dying (frozen)', 'dead', 'legs shot: crawler', 'legs shot: dead']
# run -> half -> frame per phase (picked from the band strips of runs rc2_old / rc2_new, 2026-11-13)
PICK = {
    'old': {1: [132, 186, 294, 483, 591, 699], 2: [837, 918, 999, 1242, 1377, 1467]},
    'new': {1: [132, 213, 321, 537, 672, 858], 2: [1002, 1110, 1182, 1434, 1614, 1758]},
}
Y0, Y1, HALFW = 192, 332, 35

def col_x(rung):
    """screen centre of a rung's imp (the row is square to the view; +y is screen left)"""
    if rung <= 7: return round(240.5 - 69.5 * (rung - 4))       # rung 7 leftmost .. rung 1 rightmost
    return round(240.5 - 69.5 * (rung - 10.5))                  # rung 13 leftmost .. rung 8 rightmost

def tile(frames, run, rung, phase):
    half = 1 if rung <= 7 else 2
    n = PICK[run][half][phase]
    F = np.asarray(Image.open(os.path.join(frames, 'f%05d.ppm' % n)).convert('RGB'))
    x = col_x(rung)
    return F[Y0:Y1, max(0, x - HALFW):x + HALFW], n

def label(dr, xy, s, fill=(235, 235, 235)):
    dr.text(xy, s, fill=fill)

def per_colour(old, new, out, rung, sc=3):
    tw, th = 2 * HALFW * sc, (Y1 - Y0) * sc
    side, top = 120, 44
    W, H = side + 3 * (tw + 6), top + len(PHASES) * (th + 6) + 16
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    label(dr, (6, 4), 'BD22 Imp, %s: as shipped | old flat-tint bake | new per-part recolour art' % NAMES[rung])
    label(dr, (6, 18), 'rig only, not headset-confirmed. Owner\'s full order, -skill 6, sector light 224, 480x480 frames x%d' % sc,
          (170, 170, 170))
    for c, h in enumerate(['as shipped', 'old: tint bake', 'new: recolour art']):
        label(dr, (side + c * (tw + 6) + 4, top - 12), h)
    for r, ph in enumerate(PHASES):
        y = top + r * (th + 6)
        label(dr, (6, y + th // 2 - 10), ph)
        for c, (frames, run, rr) in enumerate([(new, 'new', 1), (old, 'old', rung), (new, 'new', rung)]):
            t, n = tile(frames, run, rr, r)
            S.paste(Image.fromarray(t).resize((tw, th), Image.NEAREST), (side + c * (tw + 6), y))
            label(dr, (side + c * (tw + 6) + 3, y + th - 12), '%s f%d' % ('new' if run == 'new' else 'old', n), (200, 200, 90))
    label(dr, (6, H - 14), 'BD picks each death at random, so a pose can differ between the two runs.', (150, 150, 150))
    S.save(out, quality=92)

def closeup(new, out, sc=4):
    order = list(range(2, 14))
    tw, th = 2 * HALFW * sc, (Y1 - Y0 - 20) * sc
    side, top = 70, 40
    W, H = side + len(order) * (tw + 4), top + 2 * (th + 6) + 10
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    label(dr, (6, 4), 'BD22 Imp: the twelve colours, new per-part recolour art, in good light (sector light 224). '
                      'rig only, not headset-confirmed. Owner\'s full order, -skill 6, 480x480 frames x%d' % sc)
    for i, rung in enumerate(order):
        label(dr, (side + i * (tw + 4) + 4, top - 14), NAMES[rung])
    for r, ph in enumerate([0, 1]):
        y = top + r * (th + 6)
        label(dr, (6, y + th // 2), PHASES[ph])
        for i, rung in enumerate(order):
            t, n = tile(new, 'new', rung, ph)
            t = t[10:-10]
            S.paste(Image.fromarray(t).resize((tw, th), Image.NEAREST), (side + i * (tw + 4), y))
    S.save(out, quality=92)

def main():
    old, new, outdir = sys.argv[1:4]
    os.makedirs(outdir, exist_ok=True)
    for rung in range(2, 14):
        per_colour(old, new, os.path.join(outdir, 'imp_%02d_%s_old_vs_new.jpg' % (rung - 1, FILE[rung])), rung)
    closeup(new, os.path.join(outdir, 'imp_12colours_new_art_closeup.jpg'))
    print('sheets in', outdir)

if __name__ == '__main__':
    main()
