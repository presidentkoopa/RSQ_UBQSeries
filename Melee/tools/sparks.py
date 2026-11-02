#!/usr/bin/env python3
"""sparks.py -- builds RSQ Melee's hit-spark sprites from the owner's staged art (tool only; never ships).

    python3 Melee/tools/sparks.py [art root]     (default /mnt/user-data/uploads/Desktop; on the owner's PC C:/Users/Command/Desktop)

Source: Capcom vs. SNK 2 hit sparks and Random Sprite Rips, both ripped by Phantom.of.the.Server (credits:
Melee/CREDITS.txt). The PCX files are paletted, index 0 = the magenta key (255,0,255). Each sequence is cropped to the
UNION box of its frames (so the art's own axis stays put from frame to frame), shrunk so its long side is at most MAX
pixels, keyed (alpha 0 on the key and on pure black, 255 elsewhere; the sparks draw additive, so black adds nothing),
and written as Melee/sprites/rsqml/<NAME><frame>0.png with a grAb chunk putting the origin at the box's centre.
It prints each sequence's size and the actor Scale that gives it the world size asked below (map units)."""
import os, sys, glob
from PIL import Image, PngImagePlugin

ROOT = sys.argv[1] if len(sys.argv) > 1 else '/mnt/user-data/uploads/Desktop'
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'sprites', 'rsqml')
MAX = 192
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# name, frames (glob or a sheet), world size of the long side in map units (34 a metre): the sizes sparks.zs draws
# (about a monster's head; the owner, 11-02: "better, not bigger")
SEQS = [
    ('MLSN', 'CvS2hitsparks/NormalSpark/1/*.pcx', 14),    # jab / straight
    ('MLSS', 'CvS2hitsparks/SpecialSpark/1/*.pcx', 16),   # hook / side swing, and the open-palm swat
    ('MLSU', 'CvS2hitsparks/SuperSpark/1/*.pcx', 18),     # uppercut, and the Hadouken's return
    ('MLGD', 'CvS2hitsparks/Guard/*.pcx', 8),             # the guard flash (drawn close to your face)
]
# THE STREAK FOLLOWS THE FIST (2026-11-02). CvS2's "colours" 2-4 of each spark are the same streak at other angles:
# measured on the art (the brightest pixels' principal axis), 1 = 79, 2 = 56, 3 = 34, 4 = 11 degrees, each falling to
# the right. sparks.zs picks the one nearest the blow's travel as the puncher sees it, mirrored for the other diagonal.
for kind, short, world in (('NormalSpark', 'N', 14), ('SpecialSpark', 'P', 16), ('SuperSpark', 'U', 18)):
    for v in '234':
        SEQS.append(('ML' + short + v, 'CvS2hitsparks/%s/%s/*.pcx' % (kind, v), world))
# the Hadouken hit burst: one sheet, six frames in a row
SHEETS = [('MLHD', 'RandomSpriteRips/xvsfryuhadoukenhit.pcx', 6, 12)]


def keyed(im):
    """paletted PCX -> RGBA, index 0 (the key) transparent"""
    rgb = im.convert('RGB')
    idx = im.load()
    px = rgb.load()
    w, h = im.size
    out = Image.new('RGBA', (w, h))
    o = out.load()
    for y in range(h):
        for x in range(w):
            if idx[x, y] == 0:
                o[x, y] = (0, 0, 0, 0)
            else:
                r, g, b = px[x, y]
                o[x, y] = (r, g, b, 0 if max(r, g, b) < 24 else 255)
    return out


def write(name, frames, world):
    box = None
    for f in frames:
        bb = f.getbbox()
        if bb:
            box = bb if box is None else (min(box[0], bb[0]), min(box[1], bb[1]), max(box[2], bb[2]), max(box[3], bb[3]))
    w, h = box[2] - box[0], box[3] - box[1]
    k = min(1.0, MAX / max(w, h))
    ow, oh = max(1, round(w * k)), max(1, round(h * k))
    os.makedirs(OUT, exist_ok=True)
    for i, f in enumerate(frames):
        c = f.crop(box)
        # shrink with the key as black (premultiplied), then key again
        black = Image.new('RGBA', c.size, (0, 0, 0, 255))
        black.alpha_composite(c)
        s = black.convert('RGB').resize((ow, oh), Image.LANCZOS)
        a = s.convert('L').point(lambda v: 0 if v < 6 else 255)
        s = s.convert('RGBA')
        s.putalpha(a)
        info = PngImagePlugin.PngInfo()
        info.add(b'grAb', (ow // 2).to_bytes(4, 'big', signed=True) + (oh // 2).to_bytes(4, 'big', signed=True))
        s.save(os.path.join(OUT, f'{name}{LETTERS[i]}0.png'), pnginfo=info, optimize=True)
    print(f'{name}: {len(frames)} frames, {ow}x{oh} px, Scale {world / max(ow, oh):.4f} for {world} map units')


for name, pat, world in SEQS:
    files = sorted(glob.glob(os.path.join(ROOT, pat)))
    write(name, [keyed(Image.open(f)) for f in files], world)
for name, sheet, n, world in SHEETS:
    im = keyed(Image.open(os.path.join(ROOT, sheet)))
    fw = im.size[0] // n
    write(name, [im.crop((i * fw, 0, (i + 1) * fw, im.size[1])) for i in range(n)], world)
