#!/usr/bin/env python3
"""TEST ONLY: cut two rig runs of one monster class (rig/rc3demo through rig/rc2_full.sh: one run with the art,
+set rsrc_on 1, one with the live tint only, rsrc_on 0) into the family's sheets: the twelve colours (and as shipped)
in five poses, and as shipped | old (the live tint) | new art for one colour.

    rc3_sheets.py NEW_FRAMES OLD_FRAMES OUT_PREFIX "TITLE" COLOUR_RUNG PICKS_JSON

PICKS_JSON: {"new": {"1": [front, side, attack, dying, dead], "2": [...]}, "old": {...}}: the frame numbers of each
pose in the two halves of each run (rungs 1-7, then 8-13), picked by eye from the runs (BD's deaths are random, so a
run's timing and death differ); they are written into the sheets. Rows as rc2_sheets.py: seven and six monsters at
x -140, 52 apart, from the player at x -320 (rig01), 480x480 frames."""
import sys, os, json
import numpy as np
from PIL import Image, ImageDraw

NAMES = {1: 'as shipped', 2: 'Green', 3: 'Blue', 4: 'Purple', 5: 'Cyan', 6: 'Brown', 7: 'Yellow', 8: 'FireBlu',
         9: 'Gray', 10: 'Red', 11: 'Abyss', 12: 'Black', 13: 'White'}
PHASES = ['front', 'side', 'attack', 'dying', 'dead']
Y0, Y1, HALFW = 184, 336, 35

def col_x(rung):
    if rung <= 7: return round(240.5 - 69.5 * (rung - 4))
    return round(240.5 - 69.5 * (rung - 10.5))

def tile(frames, picks, rung, phase):
    n = picks['1' if rung <= 7 else '2'][phase]
    F = np.asarray(Image.open(os.path.join(frames, 'f%05d.ppm' % n)).convert('RGB'))
    x = col_x(rung)
    return F[Y0:Y1, max(0, x - HALFW):x + HALFW], n

def closeup(new, picks, out, title, sc=3):
    order = list(range(1, 14))
    tw, th = 2 * HALFW * sc, (Y1 - Y0) * sc
    side, top = 70, 44
    W, H = side + len(order) * (tw + 4), top + len(PHASES) * (th + 6) + 18
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((6, 4), '%s: as shipped and the twelve colours, new per-part recolour art, sector light 224.' % title, fill=(235, 235, 235))
    dr.text((6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, 480x480 frames x%d. Frame numbers per row in the corner." % sc, fill=(170, 170, 170))
    for i, rung in enumerate(order): dr.text((side + i * (tw + 4) + 4, top - 12), NAMES[rung], fill=(235, 235, 235))
    for r, ph in enumerate(PHASES):
        y = top + r * (th + 6)
        dr.text((6, y + th // 2), ph, fill=(235, 235, 235))
        for i, rung in enumerate(order):
            t, n = tile(new, picks, rung, r)
            S.paste(Image.fromarray(t).resize((tw, th), Image.NEAREST), (side + i * (tw + 4), y))
            if rung in (1, 8): dr.text((side + i * (tw + 4) + 3, y + th - 12), 'f%d' % n, fill=(200, 200, 90))
    dr.text((6, H - 14), "BD picks each death at random. The coloured balls are Brutal Doom's blood mist taking the tint (RSQ Monsters, not this art).", fill=(150, 150, 150))
    S.save(out, quality=90)

def per_colour(new, old, pn, po, out, title, rung, sc=3):
    tw, th = 2 * HALFW * sc, (Y1 - Y0) * sc
    side, top = 70, 44
    W, H = side + 3 * (tw + 6), top + len(PHASES) * (th + 6) + 16
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((6, 4), '%s, %s: as shipped | old: the live tint | new: recolour art' % (title, NAMES[rung]), fill=(235, 235, 235))
    dr.text((6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, light 224, x%d" % sc, fill=(170, 170, 170))
    for c, h in enumerate(['as shipped', 'old: live tint', 'new: recolour art']): dr.text((side + c * (tw + 6) + 4, top - 12), h, fill=(235, 235, 235))
    for r, ph in enumerate(PHASES):
        y = top + r * (th + 6)
        dr.text((6, y + th // 2), ph, fill=(235, 235, 235))
        for c, (frames, picks, rr, lab) in enumerate([(new, pn, 1, 'new'), (old, po, rung, 'old'), (new, pn, rung, 'new')]):
            t, n = tile(frames, picks, rr, r)
            S.paste(Image.fromarray(t).resize((tw, th), Image.NEAREST), (side + c * (tw + 6), y))
            dr.text((side + c * (tw + 6) + 3, y + th - 12), '%s f%d' % (lab, n), fill=(200, 200, 90))
    S.save(out, quality=90)

def main():
    new, old, pref, title, rung, pj = sys.argv[1:7]
    picks = json.loads(pj)
    closeup(new, picks['new'], pref + '_12colours_new_art.jpg', title)
    per_colour(new, old, picks['new'], picks['old'], pref + '_%02d_%s_old_vs_new.jpg' % (int(rung) - 1, NAMES[int(rung)].lower()), title, int(rung))
    print('sheets', pref)

if __name__ == '__main__':
    main()
