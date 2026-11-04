#!/usr/bin/env python3
"""gen_flarebox.py -- the flare box (voxel and sprite), the single flare's sprite and the flare sounds of RSQ FnF.

    python3 -I FlashFlare/tools/gen_flarebox.py --voxelpack <02_BD22_VoxelPack.pk3> --udv <Gameplay_UDV_Survival_Flares.pk3>
            [--preview <dir>]

THE VOXEL BOX (voxels/QFFBOX.kvx, VOXELDEF.txt: sprite QFFX A): BD_VoxelPack's ammo box (Voxels/Ammo/AMMOA.kvx, DooMAD's
"Ammo Box", the pack's Credits.txt), made into saegiru's flare box (FBOXA0) so voxels on and off show the same box:
  - the bullet belt hanging over its end (every voxel left of the box's end wall, x < 25) and the lid flap standing open
    above it (every voxel above the top, z < 20) are taken off; the flap's open end of the lid is closed flat in lid grey
  - the two panels of each long side become one panel (the divider and the grille made plain panel), as FBOXA0's front is
  - recoloured, shading kept: each green is the sprite's box red (49,16,16) at the green's own brightness relative to the
    panel green; each grey is the sprite's rim brown (82,57,57) at its brightness relative to the lid grey
  - "FLARE" in 2x2-voxel letters (the pack's own "UAC" letter size, 3x5 cells) across each long side, in a lighter red,
    and a small silver latch above it (FBOXA0's)
  - cropped to the box: 78 x 29 x 44 voxels, the pivot at the bottom centre. VOXELDEF scale 0.35 (BD_VoxelPack's own
    for AMMOA); the actor's Scale 0.7 (saegiru's FlareBox) makes it 19.1 x 10.8 map units, FBOXA0 at 0.7 is 19.6 x 11.2.
THE SPRITES (renamed from the UDV Survival Flares pack, pixels unchanged; grAb offsets written here):
  sprites/rsqff/QFFXA0.png  <- FBOXA0 (the box; offsets 14 16 as shipped: bottom centre)
  sprites/rsqff/QFFBA0.png  <- FLRLA0 (a flare lying on the floor, the pack's only lying-flare picture; offsets 11 11,
                               bottom centre: the pack's 1 11 hangs it off one end, which is right for its projectile only)
THE SOUNDS (renamed, unchanged): sounds/rsqff/QFFSTRT.flac <- FLRSTRT (strike), QFFBURN.flac <- FLRBURN (burning loop),
  QFFOUT.flac <- FLROUT (burnt out).
--preview writes flarebox_4x.png (the voxel drawn at 4 pixels a voxel, four sides) and the sprite beside it.
"""
import argparse, collections, io, os, random, struct, sys, zipfile, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from kvx import Kvx
from voxrender import render
from PIL import Image

BODY = (49, 16, 16)       # FBOXA0's box red (its most common colour)
RIM = (82, 57, 57)        # FBOXA0's rim
INK = (122, 58, 56)       # the letters: FBOXA0's letter red (90,41,41) lifted a little so it reads at voxel size
LATCH = (189, 189, 189)   # FBOXA0's latch
FONT = {   # 3x5
    'F': ['###', '#..', '##.', '#..', '#..'],
    'L': ['#..', '#..', '#..', '#..', '###'],
    'A': ['.#.', '#.#', '###', '#.#', '#.#'],
    'R': ['##.', '#.#', '##.', '#.#', '#.#'],
    'E': ['###', '#..', '##.', '#..', '###'],
}
BELT_X = 25               # the box's end wall (AMMOA, measured: the body's columns start here)
TOP_Z = 20                # the box's top (AMMOA, measured: the body's rows start here; above it only the flap and belt)
REF_GREEN = 6             # AMMOA's panel green, palette index (its most used colour)
REF_GREY = 31             # AMMOA's lid grey


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def png_with_grab(png_bytes, x, y):
    """the same PNG with its grAb chunk (ZDoom's sprite offset) set to x, y"""
    sig, rest = png_bytes[:8], png_bytes[8:]
    chunks = []
    while rest:
        n = struct.unpack('>I', rest[:4])[0]
        typ = rest[4:8]
        chunks.append((typ, rest[:12 + n]))
        rest = rest[12 + n:]
    body = b'grAb' + struct.pack('>ii', x, y)
    grab = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    out = [c for t, c in chunks if t != b'grAb']
    return sig + out[0] + grab + b''.join(out[1:])


def make_box(src):
    k = src
    vox = {v: c for v, c in k.vox.items() if v[0] >= BELT_X and v[2] >= TOP_Z}
    xs, ys, zs = k.size
    # close the top: every column of the box gets its top voxel at z 20..21 (the flap's hinge left holes)
    for x in range(BELT_X, xs):
        for y in range(1, 29):
            col = [z for (vx, vy, z) in [(x, y, z) for z in range(TOP_Z, zs)] if (vx, vy, z) in vox]
            if not col:
                continue
            if min(col) > TOP_Z + 1:
                for z in range(TOP_Z + 1, min(col)):
                    vox[(x, y, z)] = REF_GREY if z == TOP_Z + 1 else 28
    # the flap's hinge end of the lid (the 24 columns from the end wall, measured) lay open and dark inside: closed flat at
    # the lid's height (z 21) in lid grey, as the rest of the lid is; the dark rim along the top edges (y 2-3, 26-27) stays
    for x in range(BELT_X + 1, BELT_X + 24):
        for y in range(4, 26):
            vox.pop((x, y, TOP_Z), None)
            vox[(x, y, TOP_Z + 1)] = REF_GREY
    k2 = Kvx()
    k2.pal = list(k.pal)
    # crop
    k2.vox = {(x - BELT_X, y, z - TOP_Z): c for (x, y, z), c in vox.items()}
    k2.size = (xs - BELT_X, ys, zs - TOP_Z)
    k2.pivot = (k.pivot[0] - BELT_X, k.pivot[1], k.pivot[2] - TOP_Z)
    return k2


def faces(k):
    """each long side: (outward y step, the y to scan from, does its text run with x rising)"""
    xs, ys, zs = k.size
    return [(+1, ys - 1, True), (-1, 0, False)]   # back (y high): x rising; front (y 0): x falling (as "UAC" ran)


def surface(k, x, z, step, y0):
    y = y0
    while 0 <= y < k.size[1]:
        if (x, y, z) in k.vox:
            return y
        y -= step
    return None


def one_panel(k, rng):
    """the two panels of each long side made one: the raised panel's box filled flat, panel greens at random"""
    xs, ys, zs = k.size
    greens = [c for c in k.vox.values() if c in (5, 6, 16)]
    for step, y0, _ in faces(k):
        depth = {}
        for x in range(xs):
            for z in range(zs):
                y = surface(k, x, z, step, y0)
                if y is not None:
                    depth[(x, z)] = y
        out = max(depth.values()) if step > 0 else min(depth.values())
        raised = [(x, z) for (x, z), y in depth.items() if y == out and 4 <= z <= 38 and 3 <= x <= xs - 4
                  and k.vox[(x, y, z)] in (0, 5, 6, 16, 23, 25)]
        x0 = min(x for x, z in raised); x1 = max(x for x, z in raised)
        z0 = min(z for x, z in raised); z1 = max(z for x, z in raised)
        for x in range(x0, x1 + 1):
            for z in range(z0, z1 + 1):
                y = depth.get((x, z))
                if y is None:
                    continue
                # bring it out to the panel's plane, panel green
                yy = y
                while yy != out:
                    yy += step
                    k.vox[(x, yy, z)] = 6
                k.vox[(x, out, z)] = rng.choice(greens)
        yield step, out, (x0, x1, z0, z1)


def recolour(k):
    used = set(k.vox.values())
    g = k.pal[REF_GREEN]; gl = lum(g)
    gr = k.pal[REF_GREY]; grl = lum(gr)
    pal = list(k.pal)
    for i in used:
        r, gg, b = k.pal[i]
        if gg > r + 1 and gg > b:      # a green
            f = lum(k.pal[i]) / gl
            pal[i] = tuple(max(0, min(63, round(c / 4.0 * f))) for c in BODY)
        else:                           # a grey (or any brown left)
            f = lum(k.pal[i]) / grl
            pal[i] = tuple(max(0, min(63, round(c / 4.0 * f))) for c in RIM)
    free = [i for i in range(256) if i not in used]
    ink, latch = free[-1], free[-2]
    pal[ink] = tuple(round(c / 4.0) for c in INK)
    pal[latch] = tuple(round(c / 4.0) for c in LATCH)
    k.pal = pal
    return ink, latch


def stamp(k, panels, ink, latch):
    text = 'FLARE'
    cells_w = len(text) * 3 + (len(text) - 1)
    for step, out, (x0, x1, z0, z1) in panels:
        w = cells_w * 2
        cx = (x0 + x1 + 1) // 2
        start = cx - w // 2
        ztop = (z0 + z1 + 1) // 2 - 5
        for li, ch in enumerate(text):
            for row in range(5):
                for col in range(3):
                    if FONT[ch][row][col] != '#':
                        continue
                    cell = li * 4 + col
                    for dx in range(2):
                        for dz in range(2):
                            u = cell * 2 + dx
                            # x rising on the back, falling on the front (each reads left to right from outside)
                            x = start + u if step > 0 else start + w - 1 - u
                            z = ztop + row * 2 + dz
                            if (x, out, z) in k.vox:
                                k.vox[(x, out, z)] = ink
        # the latch: 6 wide, 7 tall, over the panel's top edge, centred (FBOXA0's is 2 x 3 of its 28 x 16)
        for x in range(cx - 3, cx + 3):
            for z in range(z0 - 3, z0 + 4):
                y = surface(k, x, z, step, k.size[1] - 1 if step > 0 else 0)
                if y is not None:
                    k.vox[(x, y, z)] = latch


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--voxelpack', required=True)
    ap.add_argument('--udv', required=True)
    ap.add_argument('--preview')
    a = ap.parse_args()
    vp = zipfile.ZipFile(a.voxelpack)
    tmp = io.BytesIO(vp.read('Voxels/Ammo/AMMOA.kvx'))
    src_path = os.path.join(HERE, 'src', 'AMMOA.kvx')
    os.makedirs(os.path.dirname(src_path), exist_ok=True)
    open(src_path, 'wb').write(tmp.getvalue())
    src = Kvx.read(src_path)
    print('AMMOA.kvx: %d x %d x %d voxels, pivot %s, %d voxels' % (src.size + (src.pivot, len(src.vox))))
    k = make_box(src)
    rng = random.Random(30791)          # saegiru's FlareBox editor number: the panel noise is the same every run
    panels = list(one_panel(k, rng))
    ink, latch = recolour(k)
    stamp(k, panels, ink, latch)
    os.makedirs(os.path.join(ROOT, 'voxels'), exist_ok=True)
    outp = os.path.join(ROOT, 'voxels', 'QFFBOX.kvx')
    k.write(outp)
    back = Kvx.read(outp)
    assert back.vox == k.vox and back.size == k.size, 'kvx round trip'
    print('QFFBOX.kvx: %d x %d x %d voxels, pivot %s, %d voxels; panels %s' % (k.size + (k.pivot, len(k.vox), [p[2] for p in panels])))
    print('  at VOXELDEF scale 0.35 x actor scale 0.7: %.1f long, %.1f deep, %.1f tall (map units)' %
          (k.size[0] * 0.245, k.size[1] * 0.245, k.size[2] * 0.245))

    udv = zipfile.ZipFile(a.udv)
    S = os.path.join(ROOT, 'sprites', 'rsqff')
    for src_name, dst, grab in (('SPRITES/FBOXA0.png', 'QFFXA0.png', (14, 16)), ('SPRITES/FLRLA0.png', 'QFFBA0.png', (11, 11))):
        b = png_with_grab(udv.read(src_name), *grab)
        open(os.path.join(S, dst), 'wb').write(b)
        im = Image.open(io.BytesIO(b))
        print('%s <- %s, %dx%d, offsets %d %d' % (dst, src_name, im.width, im.height, grab[0], grab[1]))
    SD = os.path.join(ROOT, 'sounds', 'rsqff')
    os.makedirs(SD, exist_ok=True)
    for src_name, dst in (('SOUNDS/FLRSTRT', 'QFFSTRT.flac'), ('SOUNDS/FLRBURN', 'QFFBURN.flac'), ('SOUNDS/FLROUT', 'QFFOUT.flac')):
        open(os.path.join(SD, dst), 'wb').write(udv.read(src_name))
        print('%s <- %s' % (dst, src_name))

    if a.preview:
        os.makedirs(a.preview, exist_ok=True)
        ims = [render(k, yaw=y, elev=25, scale=4)[0] for y in (-30, 30, 150, 210)]
        spr = Image.open(os.path.join(S, 'QFFXA0.png')).convert('RGBA')
        spr = spr.resize((spr.width * 11, spr.height * 11), Image.NEAREST)   # 28 px at 0.7 = 78 voxels at 0.245: x11 ~ x4
        W = sum(i.width for i in ims) + spr.width + 20 * 6
        H = max(max(i.height for i in ims), spr.height) + 40
        out = Image.new('RGBA', (W, H), (72, 72, 84, 255))
        x = 20
        for i in ims:
            out.alpha_composite(i, (x, 20)); x += i.width + 20
        out.alpha_composite(spr, (x, 20 + (max(i.height for i in ims) - spr.height)))
        out.save(os.path.join(a.preview, 'flarebox_4x.png'))
        print('preview', os.path.join(a.preview, 'flarebox_4x.png'))


if __name__ == '__main__':
    main()
