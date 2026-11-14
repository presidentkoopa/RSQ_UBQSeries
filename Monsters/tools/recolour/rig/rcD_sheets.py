#!/usr/bin/env python3
"""TEST ONLY: cut a rcD rig run (rcDdemo, the script from rcD_script.py) into two sheets: the twelve colours (and as
shipped) in front, side, attack, dying (frozen) and dead poses, and as shipped | live tint | new art for one colour.

    rcD_sheets.py FRAMES TITLE OUT_12 OUT_ONE COLOUR_RUNG X SPACING PER_ROW PX Y0 Y1 [SCALE]

The frames are found by the marker the demo shows in the view's lower left (red while an art window is held, blue
while the same pose is shown with the art off, i.e. the live tint): each window's middle frame is used."""
import sys, os, glob
import numpy as np
from PIL import Image, ImageDraw

NAMES = ['', 'as shipped', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss', 'Black', 'White']
PHASES = ['front', 'side', 'attack', 'dying (frozen)', 'dead']
NOTE = "rig only, not headset-confirmed. Owner's full order and saved settings, -skill 6, rig01, sector light 224."

def windows(d):
    fs = sorted(glob.glob(os.path.join(d, 'f*.ppm'))); runs = []; prev = None
    for f in fs:
        W = a_w(f); a = np.asarray(Image.open(f).convert('RGB')).astype(int)
        a = a[int(W * 0.67):int(W * 0.78), int(W * 0.125):int(W * 0.225)]   # where the marker stands (rcDdemo)
        r = ((a[..., 0] > 245) & (a[..., 1] < 10) & (a[..., 2] < 10)).sum()
        b = ((a[..., 2] > 245) & (a[..., 0] < 10) & (a[..., 1] < 10)).sum()
        n = a.shape[0] * a.shape[1] // 4
        k = 'R' if r > n else 'B' if b > n else None
        n = int(os.path.basename(f)[1:6])
        if k and runs and runs[-1][0] == k and runs[-1][2] == prev: runs[-1][2] = n
        elif k: runs.append([k, n, n])
        prev = n
    return runs

_W = {}
def a_w(f):
    if 'w' not in _W: _W['w'] = Image.open(f).size[0]
    return _W['w']

def main():
    d, title, out12, out1 = sys.argv[1:5]
    col, X, SP, PER, PX, Y0, Y1 = map(int, sys.argv[5:12]); sc = float(sys.argv[12]) if len(sys.argv) > 12 else 2.0
    runs = windows(d)
    have = [int(os.path.basename(f)[1:6]) for f in glob.glob(os.path.join(d, 'f*.ppm'))]
    rows = []; r = 1
    while r <= 13: rows.append((r, min(PER, 14 - r))); r += PER
    if len(runs) == len(rows) * 10 - 1 and runs[-1][0] == 'R': runs.append(None)   # the run quit before the last tint window
    assert len(runs) == len(rows) * 10, 'expected %d windows, found %d: %s' % (len(rows) * 10, len(runs), runs)
    W = Image.open(glob.glob(os.path.join(d, 'f*.ppm'))[0]).size[0]; D = X - PX; half = int(W / 2 * SP / 2 / D)
    tiles = {}                                                  # (rung, phase, 'art'|'tint') -> image, frame
    for ri, (first, n) in enumerate(rows):
        for ph in range(5):
            for k, kind in enumerate(('art', 'tint')):
                w = runs[ri * 10 + ph * 2 + k]
                if w is None:
                    for i in range(n): tiles[(first + i, ph, kind)] = None
                    continue
                assert w[0] == 'RB'[k]
                fn = min(have, key=lambda x: abs(x - (w[1] + w[2]) / 2))
                F = Image.open(os.path.join(d, 'f%05d.ppm' % fn)).convert('RGB')
                for i in range(n):
                    y = -(n - 1) * SP / 2 + SP * i
                    xs = int(round(W / 2 - W / 2 * y / D))
                    t = F.crop((xs - half, Y0, xs + half, Y1))
                    tiles[(first + i, ph, kind)] = (t.resize((int(t.width * sc), int(t.height * sc)), Image.NEAREST), fn)
    tw, th = tiles[(1, 0, 'art')][0].size
    # the twelve colours
    side, top = 110, 52
    S = Image.new('RGB', (side + 13 * (tw + 4), top + 5 * (th + 4) + 18), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((6, 4), title + ': as shipped and the twelve colours, new per-part art', fill=(235, 235, 235))
    dr.text((6, 18), NOTE + ' Frames %dx%d x%.1f.' % (W, W, sc), fill=(170, 170, 170))
    for c in range(1, 14): dr.text((side + (c - 1) * (tw + 4) + 3, top - 14), NAMES[c], fill=(230, 210, 90))
    for ph in range(5):
        y = top + ph * (th + 4); dr.text((6, y + th // 2 - 6), PHASES[ph], fill=(235, 235, 235))
        for c in range(1, 14):
            im, fn = tiles[(c, ph, 'art')]; S.paste(im, (side + (c - 1) * (tw + 4), y))
            dr.text((side + (c - 1) * (tw + 4) + 2, y + th - 11), 'f%d' % fn, fill=(120, 120, 120))
    dr.text((6, S.height - 14), "Brutal Doom picks each death at random, so death poses differ between monsters.", fill=(150, 150, 150))
    S.save(out12, quality=90); print('wrote', out12)
    # one colour: as shipped | live tint | new art
    side = 110
    S = Image.new('RGB', (side + 3 * (tw + 6), top + 5 * (th + 4) + 18), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((6, 4), '%s, %s: as shipped | old: live tint | new art' % (title, NAMES[col]), fill=(235, 235, 235))
    dr.text((6, 18), NOTE, fill=(170, 170, 170))
    for i, h in enumerate(['as shipped', 'old: live tint', 'new: per-part art']): dr.text((side + i * (tw + 6) + 3, top - 14), h, fill=(230, 210, 90))
    for ph in range(5):
        y = top + ph * (th + 4); dr.text((6, y + th // 2 - 6), PHASES[ph], fill=(235, 235, 235))
        for i, key in enumerate([(1, ph, 'art'), (col, ph, 'tint'), (col, ph, 'art')]):
            if tiles[key] is None: dr.text((side + i * (tw + 6) + 6, y + th // 2), 'not captured', fill=(150, 150, 150)); continue
            im, fn = tiles[key]; S.paste(im, (side + i * (tw + 6), y))
            dr.text((side + i * (tw + 6) + 2, y + th - 11), 'f%d' % fn, fill=(120, 120, 120))
    dr.text((6, S.height - 14), "The tint and the art of a pose are the same frozen moment, the art switched off and on (rsq_mon_art).", fill=(150, 150, 150))
    S.save(out1, quality=90); print('wrote', out1)

if __name__ == '__main__':
    main()
