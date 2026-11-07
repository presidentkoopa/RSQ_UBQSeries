#!/usr/bin/env python3
"""RSQ Wheel: the holster web's ring numbers in RSQ Score's combo font (owner 2026-11-07 10:29).

  The ring numbers use RSQ Score's combo font (RSSCFN2, the font Score's breakdown is drawn in) when Score is loaded,
  and JFO (graphics/WRJBnnn.png, already in the Wheel) when it is not. The Wheel loads alone, so it carries the ten
  RSSCFN2 digits itself, under its own names:

  graphics/WRSC048.png .. WRSC057.png   the digits 0-9 of Score/RSSCFN2.fon2, unpacked the way RSQ SlowMo unpacks it
                                        (SlowMo/tools/plate/gen_plate_font.py: the FON2 format, the engine's own reader
                                        FSingleLumpFont::LoadFON2). White, brightness = the font's own brightness scaled
                                        to full (so its dark shadow pixels stay a dark backing), alpha where the font has
                                        a pixel. Cut to the rows the digits use and scaled up SCALE x, nearest-neighbour,
                                        so the engine's filtering does not blur the pixels.

Credits: CREDITS.txt (RSSCFN2: Jimmy, via ijon's Dakka, as RSQ Score and RSQ SlowMo carry it).
Run from anywhere: python3 Wheel/tools/gen_web_digits.py"""
import os, struct
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
W = os.path.dirname(HERE)
REPO = os.path.dirname(W)
G = os.path.join(W, 'graphics')
FON = os.path.join(REPO, 'Score', 'RSSCFN2.fon2')
SCALE = 10


def load_fon2(path):
    d = open(path, 'rb').read()
    assert d[:4] == b'FON2', 'not a FON2 font'
    height = d[4] | (d[5] << 8)
    first, last = d[6], d[7]
    mono = d[8]
    active = d[10] + 1
    count = last - first + 1
    p = 12
    if d[11] & 1:
        p = 14
    if mono:
        w0 = struct.unpack_from('<H', d, p)[0]; widths = [w0] * count; p += 2
    else:
        widths = list(struct.unpack_from('<%dH' % count, d, p)); p += 2 * count
    pal = [tuple(d[p + 3 * i: p + 3 * i + 3]) for i in range(active)]; p += 3 * active
    glyphs = {}
    for i in range(count):
        w = widths[i]
        if w == 0:
            continue
        n = w * height; out = bytearray()
        while len(out) < n:
            code = d[p]; p += 1
            if code >= 128: code -= 256
            if code >= 0:
                out += d[p:p + code + 1]; p += code + 1
            elif code != -128:
                out += bytes([d[p]]) * (1 - code); p += 1
        glyphs[first + i] = (w, bytes(out[:n]))
    return height, pal, glyphs


def main():
    height, pal, glyphs = load_fon2(FON)
    lum = [0.299 * r + 0.587 * g + 0.114 * b for (r, g, b) in pal]
    top = max(lum[1:])
    digits = range(48, 58)
    # the rows any digit uses (one baseline for all ten)
    rows = [y for y in range(height) if any(glyphs[c][1][y * glyphs[c][0] + x] for c in digits for x in range(glyphs[c][0]))]
    y0, y1 = min(rows), max(rows) + 1
    for c in digits:
        gw, px = glyphs[c]
        im = Image.new('RGBA', (gw, y1 - y0), (255, 255, 255, 0))
        for y in range(y0, y1):
            for x in range(gw):
                k = px[y * gw + x]
                if k == 0:
                    continue
                v = int(round(255 * min(1.0, lum[k] / top)))
                im.putpixel((x, y - y0), (v, v, v, 255))
        im = im.resize((gw * SCALE, (y1 - y0) * SCALE), Image.NEAREST)
        im.save(os.path.join(G, 'WRSC%03d.png' % c))
    print('ok: RSSCFN2 digits 0-9, rows %d-%d of %d, x%d -> graphics/WRSC048-057.png' % (y0, y1 - 1, height, SCALE))


if __name__ == '__main__':
    main()
