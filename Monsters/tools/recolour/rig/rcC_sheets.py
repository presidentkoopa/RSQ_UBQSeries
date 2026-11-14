#!/usr/bin/env python3
"""TEST ONLY: cut one rcC rig run (rcCdemo: a row of one class, art on then art off for every pose) into the family's
sheets: the twelve colours (front, side, attack, death) and, for one colour, as shipped | live tint | new art.

    rcC_sheets.py FRAMES OUTDIR NAME "TITLE" PICKS [COLOUR]

PICKS: phase=frame numbers, comma separated, for the two halves (rungs 1-7 then 8-13), 'a' (art) and 't' (tint):
  "front=50/58,172/182 side=68/78,192/206 attack=86/96,220/232 dying=112/120,0/0 dead=126/150,280/290"
(each half: art/tint; 0 = none). The frame numbers are picked from the run (frame-to-frame differences show where the
art goes off and on, BD's deaths are random); they are written into the sheets. Row geometry: rcCdemo's row at x -110,
52 apart, the player at x -320 (rig01), 480x480 frames: a monster is 240 * 52 / 210 = 59.4 pixels from the next."""
import sys, os
import numpy as np
from PIL import Image, ImageDraw

NAMES = {1: 'as shipped', 2: 'Green', 3: 'Blue', 4: 'Purple', 5: 'Cyan', 6: 'Brown', 7: 'Yellow', 8: 'FireBlu',
         9: 'Gray', 10: 'Red', 11: 'Abyss', 12: 'Black', 13: 'White'}
DX, SP = 210.0, 52.0
Y0, Y1, HALFW = int(os.environ.get('Y0', 176)), int(os.environ.get('Y1', 336)), 30

def col_x(rung):
    n, i = (7, rung - 1) if rung <= 7 else (6, rung - 8)
    y = -(n - 1) * SP / 2 + SP * i
    return int(round(240 - 240 * y / DX))

def parse(picks):
    out = {}
    for w in picks.split():
        k, v = w.split('=')
        out[k] = [tuple(int(x) for x in h.split('/')) for h in v.split(',')]
    return out

def tile(frames, n, rung):
    F = np.asarray(Image.open(os.path.join(frames, 'f%05d.ppm' % n)).convert('RGB'))
    x = col_x(rung)
    return F[Y0:Y1, max(0, x - HALFW):x + HALFW]

def label(dr, xy, s, fill=(235, 235, 235)):
    dr.text(xy, s, fill=fill)

def twelve(frames, out, name, title, P, rows, sc=3):
    order = list(range(1, 14))
    tw, th = 2 * HALFW * sc, (Y1 - Y0) * sc
    side, top = 70, 44
    W, H = side + len(order) * (tw + 4), top + len(rows) * (th + 6) + 16
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    label(dr, (6, 4), '%s: as shipped, then the twelve colours, new per-part recolour art (art on), in good light (sector light 224).' % title)
    label(dr, (6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, 480x480 frames x%d; frame numbers under each tile." % sc, (170, 170, 170))
    for i, rung in enumerate(order):
        label(dr, (side + i * (tw + 4) + 4, top - 12), NAMES[rung])
    for r, ph in enumerate(rows):
        y = top + r * (th + 6)
        label(dr, (6, y + th // 2), ph)
        for i, rung in enumerate(order):
            n = P[ph][0 if rung <= 7 else 1][0]
            if not n: continue
            S.paste(Image.fromarray(tile(frames, n, rung)).resize((tw, th), Image.NEAREST), (side + i * (tw + 4), y))
            label(dr, (side + i * (tw + 4) + 3, y + th - 12), 'f%d' % n, (200, 200, 90))
    S.save(out, quality=90)

def old_new(frames, out, title, P, rows, rung, sc=3):
    tw, th = 2 * HALFW * sc, (Y1 - Y0) * sc
    side, top = 120, 44
    W, H = side + 3 * (tw + 6), top + len(rows) * (th + 6) + 16
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    label(dr, (6, 4), '%s, %s: as shipped | old: the live tint | new: per-part recolour art' % (title, NAMES[rung]))
    label(dr, (6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, sector light 224, x%d. Same pose, the art" % sc, (170, 170, 170))
    label(dr, (6, 30), 'switched off (rsrc_on 0) and on again in one run.', (170, 170, 170))
    for c, h in enumerate(['as shipped', 'old: live tint', 'new: recolour art']):
        label(dr, (side + c * (tw + 6) + 4, top - 12), h)
    half = 0 if rung <= 7 else 1
    rows = [ph for ph in rows if P[ph][half][0]]
    H = top + len(rows) * (th + 6) + 16
    S = S.crop((0, 0, W, H)); dr = ImageDraw.Draw(S)
    for r, ph in enumerate(rows):
        a, t = P[ph][half]
        y = top + r * (th + 6)
        label(dr, (6, y + th // 2 - 10), ph)
        for c, (n, rr) in enumerate([(a, 1 if half == 0 else None), (t, rung), (a, rung)]):
            if rr is None:                              # the as-shipped monster is in the first half only
                n, rr = P[ph][0][0], 1
            if not n: continue
            S.paste(Image.fromarray(tile(frames, n, rr)).resize((tw, th), Image.NEAREST), (side + c * (tw + 6), y))
            label(dr, (side + c * (tw + 6) + 3, y + th - 12), 'f%d' % n, (200, 200, 90))
    label(dr, (6, H - 14), 'BD picks each death at random.', (150, 150, 150))
    S.save(out, quality=90)

def main():
    frames, outdir, name, title, picks = sys.argv[1:6]
    rung = int(sys.argv[6]) if len(sys.argv) > 6 else 8
    P = parse(picks)
    os.makedirs(outdir, exist_ok=True)
    rows12 = [r for r in ('front', 'side', 'attack') if r in P] + (['dead'] if 'dead' in P else ['dying'] if 'dying' in P else [])
    twelve(frames, os.path.join(outdir, '%s_12colours_new_art.jpg' % name), name, title, P, rows12)
    rowsON = [r for r in ('front', 'side', 'attack', 'dying', 'dead') if r in P]
    old_new(frames, os.path.join(outdir, '%s_%02d_%s_old_vs_new.jpg' % (name, rung - 1, NAMES[rung].lower())), title, P, rowsON, rung)
    print('sheets in', outdir)

if __name__ == '__main__':
    main()
