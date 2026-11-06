#!/usr/bin/env python3
"""hitsheet.py -- builds RSQ Melee's per-blow hit sparks, the dust, the shove starburst and the dizzy chicks / stars from the
community sprite sheet "ripped by shezzor" (owner, 2026-11-06, BUGS_1.0 item 40; the approved plan is
proof/melee/melee_sprite_plan_kof.png). Tool only; never ships.

    python3 Melee/tools/hitsheet.py <path to the shezzor sheet PNG>

The cropping (cut) and the recolour (recol, the KOF palette) are the plan's own (scripts/sheet2.py), unchanged. The sheet's
4-frame hit = flash > hit-stop black > ring, in three size rows (small / mid / large). Each set is written as
Melee/sprites/rsqml/<NAME><frame>0.png, every frame on one square canvas with a grAb chunk putting the origin at its centre
(as tools/bursts.py does), so the impact point stays put. VARIETY (owner): the spark sets and the shove come at three
rotations baked as frames -- A-D 0 degrees, E-H 22, I-L 45 (the shove: A-E, F-J, K-O) -- and the game picks one and a flip
at random per blow (sparks.zs). It prints each set's canvas size and the Scale for the world size asked (map units)."""
import os, sys
import numpy as np
from PIL import Image, PngImagePlugin
from scipy import ndimage

SRC = np.array(Image.open(sys.argv[1]).convert('RGBA'))
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'sprites', 'rsqml')
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# ---- the plan's cut and recol (scripts/sheet2.py) ----
bg = np.array([42, 81, 114]); d = np.abs(SRC[..., :3].astype(int) - bg).sum(2); SRC[d < 30, 3] = 0
lab, _ = ndimage.label(ndimage.binary_dilation(SRC[..., 3] > 0, iterations=3))
cent = {i + 1: c for i, c in enumerate(ndimage.center_of_mass(np.ones_like(lab), lab, range(1, lab.max() + 1)))}


def cut(x0, y0, x1, y1):
    sub = lab[y0:y1, x0:x1]; keep = np.zeros_like(sub, bool)
    for l in np.unique(sub):
        if l == 0: continue
        cy, cx = cent[l]
        if x0 <= cx < x1 and y0 <= cy < y1: keep |= (sub == l)
    a = SRC[y0:y1, x0:x1].copy(); a[~keep, 3] = 0
    im = Image.fromarray(a); bb = im.getbbox(); return im.crop(bb) if bb else im


T = [(40, 118), (118, 236), (236, 346), (346, 580)]; Y = {'s': (28, 124), 'm': (124, 246), 'l': (246, 400)}
def burst(xoff, sz): return [cut(x0 + xoff, Y[sz][0], x1 + xoff, Y[sz][1]) for x0, x1 in T]
teal = {k: burst(0, k) for k in 'sml'}
F5 = [(30, 140), (140, 270), (270, 400), (400, 556), (556, 715)]
orange = [cut(a, 415, b, 565) for a, b in F5]; dust = [cut(a, 568, b, 700) for a, b in F5]
dizzy = [cut(*b) for b in [(750, 430, 840, 515), (850, 440, 930, 515), (750, 535, 840, 605), (850, 535, 930, 605)]]   # chick, chick, star, star (yellow)


def recol(im, c):
    a = np.array(im).astype(float); l = (0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]) / 255
    w = np.clip((l - 0.7) * 3.3, 0, 1)
    for i in range(3): a[..., i] = np.clip(c[i] * np.clip(l * 1.3, 0, 1) * (1 - w) + 255 * w, 0, 255)
    return Image.fromarray(a.astype(np.uint8))


KOF = {'O': (255, 140, 20), 'B': (60, 140, 255), 'R': (255, 40, 40), 'V': (190, 60, 255)}


def write(name, frames, world, what):
    side = max(max(f.size) for f in frames)
    side += side % 2
    for i, f in enumerate(frames):
        c = Image.new('RGBA', (side, side), (0, 0, 0, 0))
        c.alpha_composite(f, ((side - f.size[0]) // 2, (side - f.size[1]) // 2))
        info = PngImagePlugin.PngInfo()
        h = side // 2
        info.add(b'grAb', h.to_bytes(4, 'big', signed=True) + h.to_bytes(4, 'big', signed=True))
        c.save(os.path.join(OUT, f'{name}{LETTERS[i]}0.png'), pnginfo=info, optimize=True)
    print(f'{name}: {len(frames)} frames, {side} px, Scale {world / side:.4f} for {world} map units  ({what})')
    return side


def rotations(frames):
    out = list(frames)
    for deg in (22, 45):
        out += [f.rotate(deg, resample=Image.NEAREST, expand=True) for f in frames]
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    # one pixel size for every spark set, so the size rows keep their sizes: the mid set's canvas is MID_WORLD units
    MID_WORLD = 16.0
    mid_side = max(max(f.size) for f in rotations([recol(x, KOF['O']) for x in teal['m']]))
    upx = MID_WORLD / mid_side
    for col, sizes, what in [('O', 'sml', 'jab, hook, palm swat (orange-white)'), ('V', 'sml', 'uppercut, Hadouken (violet-white)'),
                             ('B', 'm', 'guard soaking a blow (blue-white)'), ('R', 'm', 'counter / perfect (red-white)')]:
        for sz in sizes:
            fr = rotations([recol(x, KOF[col]) for x in teal[sz]])
            side = max(max(f.size) for f in fr); side += side % 2
            write(f'MZ{col}{sz.upper()}', fr, side * upx, what + ', ' + {'s': 'small', 'm': 'mid', 'l': 'large'}[sz])
    write('MZSH', rotations(orange), 22.0, 'gun-butt shove: the orange starburst as drawn')
    write('MZDU', dust, 26.0, 'dust cloud: Ground Pound, Wall Splat, the uppercut barrel kick, the uppercut launch (A-B)')
    write('MZDZ', dizzy, 6.0, 'Heavy Hands dizzy: A-B chicks, C-D stars (yellow)')


if __name__ == '__main__':
    main()
