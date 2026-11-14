#!/usr/bin/env python3
"""TEST ONLY: cut the shared gore's rig runs (rcGdemo + rcE_full.sh, 640x640 frames) into sheets in MonsterRecolour/docs/.
The frames are found, not picked by hand: rcGdemo shows the code of the pose being held as a solid coloured shape above
the scene (rcg_phase, as rcfam's); the last frame of the longest run of each code is used.

    rcg_sheets.py pieces NEW_FRAMES OLD_FRAMES OUT.jpg     rcg_script.py pieces 1,2,13,9,3,4,10,5,6,8,7 24 -320 0
    rcg_sheets.py gibs   NEW_FRAMES OLD_FRAMES OUT.jpg PICKS rcg_script.py sheet 0,9,4,12
NEW: RSQ_BDXMTiers_<Colour> with the gore art; OLD: the same pk3s without it (the gore on the live tint, as before)."""
import sys, os, glob
import numpy as np
from PIL import Image, ImageDraw

NOTE = "rig only, not headset-confirmed. Owner's full order and saved settings, -skill 6, rig01, sector light 224, 640x640 frames."
ORDER = 'left to right: Green, White, Black, Gray, Red, FireBlu'
BANDS = [(0, 20), (36, 82), (96, 142), (150, 194), (200, 255)]
PIECES = ['Guts (GUTS)', 'XDeathArm1 (XARM)', 'XDeathArm2 (XARM)', 'Gib_Arm (XDT5)', 'XDeathOrgan1 (XME8)',
          'XDeathStomach (XSTO)', 'XDeathGuts (XME4)', 'Brains4 (BRIB, BRIN)', 'BrainsSergeantHeadPiece (BR7B)',
          'Teeth (XTET)', 'XDeathSkinPiece1 (XSKI)']
GIBS = ['RifleZombie', 'Imp', 'ShotgunGuy1', 'BullDemon (the Demon family\'s own art was not in these runs)']


def code(f):
    p = np.asarray(Image.open(f).convert('RGB'))[123:139, 313:328].reshape(-1, 3).astype(int)
    m = np.median(p, 0); k = []
    for v in m:
        lv = [i for i, (lo, hi) in enumerate(BANDS) if lo <= v <= hi]
        if not lv: return 0
        k.append(lv[0])
    return k[0] + 5 * k[1] + 25 * k[2]


def codes(d):
    """code -> the last frame of its longest run of consecutive dumped frames"""
    fs = sorted(glob.glob(os.path.join(d, '*.ppm')))
    cs = [code(f) for f in fs]
    first = cs.index(1) if 1 in cs else 0          # the first dumps are the title screen (it can read as a code): from code 1 on
    fs, cs = fs[first:], cs[first:]
    runs = {}; prev = None; cur = []
    for f, c in list(zip(fs, cs)) + [(None, None)]:
        if c != prev and cur:
            if prev and (prev not in runs or len(cur) > len(runs[prev])): runs[prev] = cur
            cur = []
        if f: cur.append(f)
        prev = c
    return {c: r[-1] for c, r in runs.items()}


def crop(f, box, sc):
    im = Image.open(f).convert('RGB').crop(box)
    return im.resize((int(im.width * sc), int(im.height * sc)), Image.LANCZOS)


def sheet(out, title, heads, rows, note2):
    """rows: (label, [images]) with one image per head"""
    tw = max(im.width for _, ims in rows for im in ims if im); th = max(im.height for _, ims in rows for im in ims if im)
    W = 10 + len(heads) * (tw + 6); H = 60 + len(rows) * (th + 20) + 18
    S = Image.new('RGB', (W, H), (22, 22, 24)); dr = ImageDraw.Draw(S)
    dr.text((8, 4), title, fill=(235, 235, 235)); dr.text((8, 18), NOTE, fill=(170, 170, 170))
    for i, h in enumerate(heads): dr.text((10 + i * (tw + 6), 40), h, fill=(120, 200, 255))
    y = 56
    for lab, ims in rows:
        dr.text((10, y), lab, fill=(230, 210, 90)); y += 14
        for i, im in enumerate(ims):
            if im: S.paste(im, (10 + i * (tw + 6), y))
            else: dr.text((14 + i * (tw + 6), y + th // 2), '(no frame with this code)', fill=(150, 150, 150))
        y += th + 6
    dr.text((8, H - 16), note2, fill=(150, 150, 150))
    S.save(out, quality=90)
    print('wrote', out, S.size)


def main():
    kind, new, old, out = sys.argv[1:5]
    cn, co = codes(new), codes(old)
    if kind == 'pieces':
        air, low, sc = (0, 250, 640, 470), (0, 420, 640, 640), 0.75      # landed pieces lie lower in the frame
        rows = []
        for k, name in enumerate(PIECES):
            ims = [crop(c[n], air, sc) if n in c else None for c in (co, cn) for n in (2 * k + 1,)] + \
                  [crop(c[n], low, sc) if n in c else None for c in (co, cn) for n in (2 * k + 2,)]
            rows.append(('%s, dropped as Brutal Doom throws it, one per colour (%s)' % (name, ORDER), ims))
        sheet(out, "Brutal Doom's shared gore pieces in six colours: old (the live tier tint) and new (painted art: reds kept, flesh coloured)",
              ['OLD, in the air', 'NEW, in the air', 'OLD, landed', 'NEW, landed'], rows,
              'Each piece is an RS_BDHue piece of that colour (rcGdemo rcg_pieces), drawn by RSQ Monsters\' RS_BDArt. Guts, organs, brains, teeth stay as shipped; skin (palette 48-79, 236-239) takes the colour.')
    else:
        # the gib runs' dumps are sparse (the rig was shared) and Brutal Doom's mist covers the marker while it bursts, so
        # the frames are picked by eye from the runs' strips: PICKS = "new: a,b,l a,b,l ...; old: ..." (alive, bursting,
        # landed per class)
        pk = {}
        for part in sys.argv[5].split(';'):
            k, v = part.split(':'); pk[k.strip()] = [[int(x) for x in t.split(',')] for t in v.split()]
        fr = lambda d, n: os.path.join(d, 'f%05d.ppm' % n)
        up, low, sc = (0, 230, 640, 520), (0, 380, 640, 600), 0.62
        rows = []
        for k, name in enumerate(GIBS):
            a, b, l = pk['new'][k]; oa, ob, ol = pk['old'][k]
            ims = [crop(fr(new, a), up, sc), crop(fr(old, ob), up, sc), crop(fr(new, b), up, sc),
                   crop(fr(old, ol), low, sc), crop(fr(new, l), low, sc)]
            rows.append(('%s x6, gibbed (Brutal Doom\'s extreme death), %s. Frames: new %d %d %d, old %d %d' % (name, ORDER, a, b, l, ob, ol), ims))
        sheet(out, 'Gibbed monsters in six colours: the shared gore before (live tint) and after (painted art)',
              ['alive (new)', 'OLD, bursting', 'NEW, bursting', 'OLD, landed', 'NEW, landed'], rows,
              "Pieces held to fall straight down (rcg_hold); BD picks each death and throw at random, so old and new differ in where pieces fly.")

if __name__ == '__main__':
    main()
