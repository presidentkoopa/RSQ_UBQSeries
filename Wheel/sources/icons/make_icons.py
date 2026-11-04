#!/usr/bin/env python3
"""RSQ Wheel: the fist and lightsaber card icons, from the sources in this folder (owner 2026-11-03).

  ldl_SFISZ0.png -> graphics/WRIFIST.png   LegenDoom 3.0's standard fist icon (the brass knuckles, Inventory.Icon
                                           "SFISZ0" of its LDFists, decorate/Fist/Fist.dec), as is: 28x17
  dinopixel_jedi_lightsaber_danger_doughnut52.png -> graphics/WRISABER.png
                                           800x800, drawn on an 8-pixel grid: taken down to its own art pixels
                                           (nearest-neighbour, exactly 1:8, nothing resampled) and cropped: 98x98
The whip is drawn by gen_whip_icon.py.

--extract <LegenDoom_3.0.pk3> [<wad with PLAYPAL>]: re-extract ldl_SFISZ0.png from the pk3's sprites/Fist/SFISZ0.
In LegenDoom 3.0 that lump is already a PNG (RGBA, 28x17, its own colours), so it is written out byte for byte and
no palette is involved. Only if a later LegenDoom ships it as a Doom picture (columns of posts, indices into PLAYPAL)
is the wad needed: LegenDoom carries no PLAYPAL, so it would be drawn with the IWAD's (Doom 2's).
--preview <dir>: also writes each icon at 4x (nearest-neighbour) into <dir>.
Run: python3 Wheel/sources/icons/make_icons.py [--extract pk3 wad] [--preview dir]"""
import os, struct, sys, zipfile
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
G = os.path.join(os.path.dirname(os.path.dirname(HERE)), 'graphics')


def playpal(wad):
    d = open(wad, 'rb').read()
    n, off = struct.unpack('<ii', d[4:12])
    for i in range(n):
        o, s, nm = struct.unpack('<ii8s', d[off + 16 * i:off + 16 * i + 16])
        if nm.rstrip(b'\0').upper() == b'PLAYPAL':
            return [tuple(d[o + 3 * k:o + 3 * k + 3]) for k in range(256)]
    raise SystemExit('no PLAYPAL in ' + wad)


def doom_picture(d, pal):
    w, h, _lo, _to = struct.unpack('<hhhh', d[:8])
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    px = im.load()
    for x in range(w):
        p = struct.unpack('<I', d[8 + 4 * x:12 + 4 * x])[0]
        top = -1
        while d[p] != 255:
            t, ln = d[p], d[p + 1]
            top = t + top if t <= top else t      # DeePsea tall patches
            for y in range(ln):
                px[x, top + y] = pal[d[p + 3 + y]] + (255,)
            p += ln + 4
    return im


def main():
    a = sys.argv[1:]
    if '--extract' in a:
        i = a.index('--extract')
        with zipfile.ZipFile(a[i + 1]) as z:
            raw = z.read('sprites/Fist/SFISZ0')
        out = os.path.join(HERE, 'ldl_SFISZ0.png')
        if raw[:8] == b'\x89PNG\r\n\x1a\n':
            open(out, 'wb').write(raw)
        else:
            doom_picture(raw, playpal(a[i + 2])).save(out)
    fist = Image.open(os.path.join(HERE, 'ldl_SFISZ0.png')).convert('RGBA')
    fist.save(os.path.join(G, 'WRIFIST.png'))
    src = Image.open(os.path.join(HERE, 'dinopixel_jedi_lightsaber_danger_doughnut52.png')).convert('RGBA')
    assert src.size == (800, 800)
    saber = src.resize((100, 100), Image.NEAREST)
    saber = saber.crop(saber.getbbox())
    saber.save(os.path.join(G, 'WRISABER.png'))
    print('fist', fist.size, 'saber', saber.size)
    if '--preview' in a:
        d = a[a.index('--preview') + 1]
        os.makedirs(d, exist_ok=True)
        for nm in ('WRIFIST', 'WRISABER', 'WRIWHIP'):
            im = Image.open(os.path.join(G, nm + '.png'))
            im.resize((im.width * 4, im.height * 4), Image.NEAREST).save(os.path.join(d, nm + '_4x.png'))


if __name__ == '__main__':
    main()
