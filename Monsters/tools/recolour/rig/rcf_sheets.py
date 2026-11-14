#!/usr/bin/env python3
"""TEST ONLY: cut an rcfam rig run (rcf_script.py + rc2_full.sh) into sheets.

    rcf_sheets.py FRAMES OUTDIR TITLE SLUG CLASS_SPEC [CLASS_SPEC ...]   (CLASS_SPEC as rcf_script.py's, same order)

The frames are found, not picked by hand: rcfam shows the code of the pose being held (row * 8 + pose: front art,
front tint, side art, side tint, attack art, attack tint, dying art, dying tint; 124 the empty room) as a solid
coloured shape above the row; the last frame of each code is used. Writes, per class: SLUG_<n>_12colours.jpg (front, side, attack, dying, art) and
SLUG_<n>_<colour>_shipped_tint_art.jpg (as shipped | old tint | new art, for one colour)."""
import sys, os, glob
import numpy as np
from PIL import Image, ImageDraw

NAMES = ['as shipped', 'Green', 'Blue', 'Purple', 'Cyan', 'Brown', 'Yellow', 'FireBlu', 'Gray', 'Red', 'Abyss',
         'Black', 'White']
POSES = ['front', 'side', 'attack', 'dying']
DIST = 260.0; F = 240.6; CX = 240.5

def load(frames):
    return sorted(glob.glob(os.path.join(frames, '*.ppm')))

# what the rig's frames show for a marker channel of 0, 48, 96, 144, 192 (measured: a channel reads lower when the
# others are lit, so each level is a band); a value between the bands is a frame in transition: no code
BANDS = [(0, 20), (36, 82), (96, 142), (150, 194), (200, 255)]

def code(f):
    """the phase code rcfam shows as a solid coloured shape above the row (0: none)"""
    p = np.asarray(Image.open(f).convert("RGB"))[92:104, 235:246].reshape(-1, 3).astype(int)
    m = np.median(p, 0); k = []
    for v in m:
        lv = [i for i, (lo, hi) in enumerate(BANDS) if lo <= v <= hi]
        if not lv: return 0
        k.append(lv[0])
    return k[0] + 5 * k[1] + 25 * k[2]

def main():
    frames, outdir, title, slug = sys.argv[1:5]
    specs = sys.argv[5:]
    fs = load(frames)
    last = {}; run = {}; prev, n = 0, 0
    for f in fs:                                 # a code held for 2 frames or more; the last frame of its longest hold
        c = code(f)
        n = n + 1 if c == prev else 1; prev = c
        if c and n >= 2 and n >= run.get(c, 0): last[c] = f; run[c] = n
    rows = []
    for sp in specs:
        p = [int(x) for x in sp.split(':')]
        cls, spc, per = p[0], (p[1] if len(p) > 1 else 76), (p[2] if len(p) > 2 else 7)
        r = 1
        while r <= 13:
            n = min(per, 14 - r); rows.append((cls, spc, r, n)); r += n
    print(len(fs), 'frames; phase codes seen:', sorted(last))
    os.makedirs(outdir, exist_ok=True)
    tiles = {}                                   # (cls, rung, pose, 'art'|'tint') -> (image, frame name)
    for ri, (cls, spc, r0, n) in enumerate(rows):
        for k, pose in enumerate(POSES):
            for h, how in enumerate(('art', 'tint')):
                f = last.get(ri * 8 + 2 * k + h + 1)
                if not f: print('missing', cls, r0, pose, how); continue
                F_ = np.asarray(Image.open(f).convert('RGB'))
                for i in range(n):
                    y = -(n - 1) * spc / 2. + spc * i
                    x = int(round(CX - F * y / DIST)); hw = int(F * spc / DIST / 2)
                    tiles[(cls, r0 + i, pose, how)] = (F_[:, max(0, x - hw):x + hw], os.path.basename(f), F_)
    for sp in specs:
        cls = int(sp.split(':')[0])
        band = os.environ.get('BAND_%d' % cls) or os.environ.get('BAND', '170,300')   # the monsters' rows (260 units)
        top, bot = [int(v) for v in band.split(',')]
        title_c = os.environ.get('TITLE_%d' % cls, title)
        sheet_12(tiles, cls, top, bot, os.path.join(outdir, '%s_%02d_12colours.jpg' % (slug, cls)), title_c)
        rung = int(os.environ.get('RUNG', 3))
        sheet_cmp(tiles, cls, rung, top, bot, os.path.join(outdir, '%s_%02d_%s_shipped_tint_art.jpg' % (slug, cls, NAMES[rung - 1].lower())), title_c)

def lab(dr, xy, s, fill=(235, 235, 235)): dr.text(xy, s, fill=fill)

def sheet_12(tiles, cls, top, bot, out, title, sc=2):
    tw = max(t.shape[1] for (c, r, p, h), (t, _, _f) in tiles.items() if c == cls) * sc
    th = (bot - top) * sc; side, head = 70, 46
    W = side + 13 * (tw + 4); H = head + len(POSES) * (th + 6) + 18
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    lab(dr, (6, 4), '%s: as shipped and the twelve colours, new per-part recolour art, sector light 224' % title)
    lab(dr, (6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, rig01, 260 units, 480x480 frames x%d" % sc, (170, 170, 170))
    for r in range(1, 14): lab(dr, (side + (r - 1) * (tw + 4) + 3, head - 12), NAMES[r - 1])
    for pi, pose in enumerate(POSES):
        y = head + pi * (th + 6); lab(dr, (6, y + th // 2 - 6), pose)
        for r in range(1, 14):
            t = tiles.get((cls, r, pose, 'art'))
            if t is None: continue
            im = Image.fromarray(np.ascontiguousarray(t[0][top:bot])).resize((t[0].shape[1] * sc, th), Image.NEAREST)
            S.paste(im, (side + (r - 1) * (tw + 4), y))
    lab(dr, (6, H - 14), 'BD picks each death at random; the test lowers the kit entry colour to 1 so every colour shows.', (150, 150, 150))
    S.save(out, quality=90); print(out)

def sheet_cmp(tiles, cls, rung, top, bot, out, title, sc=3):
    tw = max(t.shape[1] for (c, r, p, h), (t, _, _f) in tiles.items() if c == cls) * sc
    th = (bot - top) * sc; side, head = 70, 46
    W = side + 3 * (tw + 6); H = head + len(POSES) * (th + 6) + 18
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    lab(dr, (6, 4), '%s, %s: as shipped | old: live tint | new: recolour art (the same frozen pose, rsq_mon_art 0 / 1)' % (title, NAMES[rung - 1]))
    lab(dr, (6, 18), "rig only, not headset-confirmed. Owner's full order, -skill 6, rig01, sector light 224, x%d" % sc, (170, 170, 170))
    for c, h in enumerate(['as shipped', 'old: live tint', 'new: art']): lab(dr, (side + c * (tw + 6) + 3, head - 12), h)
    for pi, pose in enumerate(POSES):
        y = head + pi * (th + 6); lab(dr, (6, y + th // 2 - 6), pose)
        for c, key in enumerate([(cls, 1, pose, 'art'), (cls, rung, pose, 'tint'), (cls, rung, pose, 'art')]):
            t = tiles.get(key)
            if t is None: continue
            im = Image.fromarray(np.ascontiguousarray(t[0][top:bot])).resize((t[0].shape[1] * sc, th), Image.NEAREST)
            S.paste(im, (side + c * (tw + 6), y)); lab(dr, (side + c * (tw + 6) + 3, y + th - 12), t[1], (200, 200, 90))
    S.save(out, quality=90); print(out)

if __name__ == '__main__':
    main()
