#!/usr/bin/env python3
"""gen_weakpt.py -- the weak points' crosshairs (telegraph.zs, design/BOSS_REWORK.md 3). Tool only; never ships.
Run from the repo root (it reads RSQ SlowMo's art from git, so SlowMo need not be checked out):

    python3 Miniboss/tools/gen_weakpt.py

Writes Miniboss/sprites/rsqmb/MBX1A0..MBX3Q0.png: RSQ SlowMo's DOWN crosshair assembly (SlowMo/graphics/rsqsmp/
RSPA<icon><frame>, 17 baked frames, frame 16 the locked icon; tools/plate/gen_plate_art.py) for three of its ten icons,
one per weak point (01, 05 and 09: the ring ones; the owner likes the closing ring best, design/BIG_BOSS.md 10), as
sprites A..Q, each centred on its middle (a grAb chunk), white (tinted at run time with the Shaded style). The same
art, so the weak points' crosshairs read as the series' own.
"""
import io, os, struct, subprocess, zlib
from PIL import Image

OUT = 'Miniboss/sprites/rsqmb'
ICONS = [1, 5, 9]          # MBX1, MBX2, MBX3
FRAMES = 17


def grab_png(im, gx, gy):
    buf = io.BytesIO()
    im.save(buf, 'PNG', optimize=True)
    d = buf.getvalue()
    body = b'grAb' + struct.pack('>ii', int(gx), int(gy))
    chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    ihdr_end = 8 + 12 + struct.unpack('>I', d[8:12])[0]
    return d[:ihdr_end] + chunk + d[ihdr_end:]


def main():
    os.makedirs(OUT, exist_ok=True)
    for k, icon in enumerate(ICONS):
        for f in range(FRAMES):
            src = 'origin/main:SlowMo/graphics/rsqsmp/RSPA%02d%02d.png' % (icon, f)
            data = subprocess.run(['git', 'show', src], capture_output=True, check=True).stdout
            im = Image.open(io.BytesIO(data)).convert('RGBA')
            name = 'MBX%d%s0.png' % (k + 1, chr(ord('A') + f))
            with open(os.path.join(OUT, name), 'wb') as fh:
                fh.write(grab_png(im, im.width // 2, im.height // 2))
    print('wrote %d sprites to %s' % (len(ICONS) * FRAMES, OUT))


if __name__ == '__main__':
    main()
