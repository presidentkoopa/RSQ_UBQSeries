#!/usr/bin/env python3
"""gen_dn_art.py -- the Damage Numbers' glyph textures (RSQ HP Bars), from tools/dn_art/. Do not hand-edit the output.

Writes pk3/graphics/rsqthpdn/RQN<F><Q><HH>.png: font F, quality Q (0 Quest, 1 PCVR), HH the glyph's ASCII code in hex.
They are TEXTURES (graphics/), not sprites: the numbers are drawn with the engine's VisualThinker, so they cost no sprite
frames at all (the load order is near the engine's 65,535). Each glyph is cropped to its ink sideways (its own advance
width), keeps the font's inked rows (one baseline for the font), and carries a grAb offset at its centre, so a VisualThinker
at a point draws the glyph centred on it.

  J  JFO metal digits (+ 0-9), JFO's BigFont        PCVR 64 px cell, Quest 32 px (half resolution, like Gun Cards)
  S  JFO small letters and digits (the words, "x")  PCVR 32 px, Quest 16 px
  E  Ermac's digits (+ 0-9), 12 px pixel art        PCVR x4 nearest (48 px), Quest x2 (24 px): crisp under filtering
  C  damnums' Doom Classic digits (0-9), 14x16      PCVR x4 nearest, Quest x2
  D  damnums' Doom Small digits (0-9), 8x7          PCVR x4 nearest, Quest x2

JFO's grey metal is levelled so its brightest pixel is white: the colours (TRNSLATE ramps from black) then reach full
strength. Sources: tools/dn_art/ (JFO copied unchanged from GunCards/tools/card_art/jfo, Ermac's from
GunCards/tools/card_art, damnums' from its sprites)."""
import os, struct, zlib
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, 'dn_art')
OUT = os.path.join(os.path.dirname(HERE), 'pk3', 'graphics', 'rsqthpdn')   # its own folder: gen_art.py clears graphics/rsqthp


def grab(png_path, x, y):
    """insert a grAb chunk (ZDoom's offset) after IHDR"""
    d = open(png_path, 'rb').read()
    body = b'grAb' + struct.pack('>ii', x, y)
    chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    i = 8 + 12 + struct.unpack('>I', d[8:12])[0]
    open(png_path, 'wb').write(d[:i] + chunk + d[i:])


def level(im):
    """stretch the metal's grey so its brightest pixel is white (alpha kept)"""
    r, g, b, a = im.split()
    mx = max(c.getextrema()[1] for c in (r, g, b)) or 255
    k = 255.0 / mx
    lut = [min(255, int(round(v * k))) for v in range(256)]
    return Image.merge('RGBA', (r.point(lut), g.point(lut), b.point(lut), a))


def rows(ims):
    """the font's inked rows (union over its glyphs): one baseline, no empty band above or below"""
    y0, y1 = 10 ** 6, -1
    for im in ims:
        bb = im.getchannel('A').point(lambda v: 255 if v > 24 else 0).getbbox()
        if bb:
            y0, y1 = min(y0, bb[1]), max(y1, bb[3])
    return y0, y1


def crop_x(im):
    bb = im.getchannel('A').point(lambda v: 255 if v > 24 else 0).getbbox()
    if not bb:
        return im
    x0, x1 = max(0, bb[0] - 1), min(im.width, bb[2] + 1)
    return im.crop((x0, 0, x1, im.height))


def emit(font, q, code, im):
    name = 'RQN%s%d%02X' % (font, q, code)
    p = os.path.join(OUT, name + '.png')
    im.save(p, optimize=True)
    grab(p, im.width // 2, im.height // 2)
    return name


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.startswith('RQN'):
            os.remove(os.path.join(OUT, f))
    n = 0
    # JFO big and small
    for font, sub, pre in (('J', 'jfo_big', 'fontb'), ('S', 'jfo_small', 'stcfn')):
        files = sorted(os.listdir(os.path.join(SRC, sub)))
        srcs = [level(Image.open(os.path.join(SRC, sub, f)).convert('RGBA')) for f in files]
        y0, y1 = rows(srcs)
        y0, y1 = max(0, y0 - 1) & ~1, min(srcs[0].height, y1 + 1)
        y1 += (y1 - y0) & 1
        for f, im in zip(files, srcs):
            code = int(f[len(pre):len(pre) + 3])
            im = im.crop((0, y0, im.width, y1))
            full = crop_x(im)
            emit(font, 1, code, full)
            half = im.resize((im.width // 2, im.height // 2), Image.LANCZOS)
            emit(font, 0, code, crop_x(half))
            n += 2
    # Ermac's digits
    for f in sorted(os.listdir(os.path.join(SRC, 'ermac'))):
        s = f[len('digit_'):-4]
        code = ord('+') if s == 'plus' else ord(s)
        im = Image.open(os.path.join(SRC, 'ermac', f)).convert('RGBA')
        for q, k in ((1, 4), (0, 2)):
            emit('E', q, code, crop_x(im.resize((im.width * k, im.height * k), Image.NEAREST)))
            n += 1
    # damnums' Doom fonts (frames A-J are 0-9)
    for f in sorted(os.listdir(os.path.join(SRC, 'classic'))):
        font = 'C' if f.startswith('QC') else 'D'
        code = ord('0') + (ord(f[4]) - ord('A'))
        im = Image.open(os.path.join(SRC, 'classic', f)).convert('RGBA')
        for q, k in ((1, 4), (0, 2)):
            emit(font, q, code, crop_x(im.resize((im.width * k, im.height * k), Image.NEAREST)))
            n += 1
    print('gen_dn_art: %d glyph textures in %s' % (n, OUT))


if __name__ == '__main__':
    main()
