#!/usr/bin/env python3
"""bursts.py -- builds RSQ Melee's impact bursts from kiddolink's "VFX Hit Impact" (paid; the owner's purchase,
2026-11-02: "I want that one in there for sure"). Tool only; never ships.

    python Melee/tools/bursts.py [path to vfx_hit_impact.zip]     (default: the owner's Desktop copy)

The zip's sprite sheet (vfx_hit_impact/sprite_sheets_96x96/vfx_hit_effects-Sheet.png) holds five impacts, one per row,
96x96 a frame, 8 or 9 frames each. Each burst below is one row, as drawn or recoloured for an element (the owner's
contact sheet, GunBonsaiOffhandVR/docs/art/1_kiddolink.png: the mid tones take the element's colour, the highlights
stay white-hot, alpha kept). Each row is cropped to the UNION box of its frames (its axis stays put), and written as
Melee/sprites/rsqml/<NAME><frame>0.png with a grAb chunk putting the origin at the box's centre. It prints each one's
size and the Scale that makes its long side WORLD map units (34 a metre); sparks.zs RSQML_Burst uses it.

THE ART RULE (GBOVR_TREES.md 4): the hit sparks (tools/hitsheet.py, since 11-06) are the blow itself, on every punch; these bursts are what a blow DOES,
only on the moments that earn it -- combos, criticals, perfects, the elements, the launches -- and they play frames by
level (sparks.zs)."""
import io, os, sys, zipfile
from PIL import Image, PngImagePlugin

ZIP = sys.argv[1] if len(sys.argv) > 1 else r'C:/Users/Command/Desktop/vfx_hit_impact.zip'
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'sprites', 'rsqml')
SHEET = 'vfx_hit_impact/sprite_sheets_96x96/vfx_hit_effects-Sheet.png'
CELL = 96
WORLD = 40          # map units, the long side at Scale 1 of the actor (about 1.2 m); callers scale it 0.75 to 2
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# name, row (0-4 = impact 1-5), colour (None = as drawn), what it is for
BURSTS = [
    ('MLK1', 0, None, 'combos: Three-Hit, Dempsey'),
    ('MLK2', 1, None, 'criticals'),
    ('MLK3', 2, None, 'launches: the uppercut lift, Juggle'),
    ('MLK4', 3, (255, 255, 255), 'perfects, white: Parry, Reflect Guard, Backstab'),
    ('MLK5', 4, None, 'the big ones: Finisher, Meteor, Ground Pound, Slam'),
    ('MLKE', 4, (255, 255, 255), 'Explosive Fist, the Guard\'s release'),
    ('MLKF', 1, (90, 190, 255), 'Frost Fist: the shatter'),
    ('MLKS', 3, (255, 235, 70), 'Shock Fist: the arc'),
    ('MLKR', 0, (255, 120, 30), 'Fire Fist: the flare'),
    ('MLKH', 1, (255, 50, 50), 'red: Headshot, Blood Rush, Rage'),
]


def recolour(im, colour):
    if colour is None:
        return im
    im = im.convert('RGBA').copy()
    p = im.load()
    cr, cg, cb = colour
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            r, g, b, a = p[x, y]
            if a == 0:
                continue
            l = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            w = max(0.0, (l - 0.75) * 4.0)   # the highlights stay white-hot
            p[x, y] = (min(255, int(cr * l * (1 - w) + 255 * w)), min(255, int(cg * l * (1 - w) + 255 * w)),
                       min(255, int(cb * l * (1 - w) + 255 * w)), a)
    return im


def main():
    sheet = Image.open(io.BytesIO(zipfile.ZipFile(ZIP).read(SHEET))).convert('RGBA')
    cols = sheet.size[0] // CELL
    os.makedirs(OUT, exist_ok=True)
    for name, row, colour, what in BURSTS:
        frames = [sheet.crop((c * CELL, row * CELL, (c + 1) * CELL, (row + 1) * CELL)) for c in range(cols)]
        frames = [f for f in frames if f.getbbox()]
        box = None
        for f in frames:
            bb = f.getbbox()
            box = bb if box is None else (min(box[0], bb[0]), min(box[1], bb[1]), max(box[2], bb[2]), max(box[3], bb[3]))
        # centred on the cell's centre, so every frame's origin is the impact point
        half = max(CELL // 2 - box[0], box[2] - CELL // 2, CELL // 2 - box[1], box[3] - CELL // 2)
        box = (CELL // 2 - half, CELL // 2 - half, CELL // 2 + half, CELL // 2 + half)
        size = 2 * half
        for i, f in enumerate(frames):
            c = recolour(f.crop(box), colour)
            info = PngImagePlugin.PngInfo()
            info.add(b'grAb', half.to_bytes(4, 'big', signed=True) + half.to_bytes(4, 'big', signed=True))
            c.save(os.path.join(OUT, f'{name}{LETTERS[i]}0.png'), pnginfo=info, optimize=True)
        print(f'{name}: impact {row + 1}, {len(frames)} frames, {size} px, Scale {WORLD / size:.4f} for {WORLD} map units  ({what})')


if __name__ == '__main__':
    main()
