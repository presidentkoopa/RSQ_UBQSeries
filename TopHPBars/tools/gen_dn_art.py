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
        if f.startswith('RQN'):   # glyphs and panels
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
    n += panels()
    palette()
    print('gen_dn_art: %d glyph and panel textures in %s; palette in TRNSLATE.rsqthp' % (n, OUT))


# ---- the owner's design round (2026-11-03 18:05-18:12, approved from animated mockups) ----------------------------------
# PALETTE: the selectable colours. Each has 4 shades for Castlevania-style colour cycling (shade 1 is the colour itself; 0
# darker, 2 and 3 toward white); ramps from black, so the metal's shading stays. RSQTHP_P<ii><s>, ii = the menu's index
# (MENUDEF OptionValue "RSQTHP_Col"), 17 = the cool-down grey (not selectable). RSQTHP_PFL is the arrival flash (white).
# HP bars: RSQTHP_H<ii>, the same colours for coldcite's Classic frames: palette greys (80-111: the frame, the empty blocks)
# are kept, everything else is tinted by its brightness (the Cyan / Lavender / Orange scheme and Random).
PALETTE = [
    ('White', (1.00, 1.00, 1.00)), ('Silver', (0.70, 0.74, 0.82)), ('Yellow', (1.00, 0.92, 0.22)),
    ('Gold', (1.00, 0.74, 0.18)), ('Orange', (1.00, 0.48, 0.08)), ('Red', (1.00, 0.16, 0.10)),
    ('Crimson', (0.86, 0.04, 0.26)), ('Pink', (1.00, 0.50, 0.76)), ('Magenta', (1.00, 0.18, 0.95)),
    ('Lavender', (0.76, 0.60, 1.00)), ('Purple', (0.58, 0.24, 1.00)), ('Blue', (0.24, 0.40, 1.00)),
    ('Sky', (0.44, 0.76, 1.00)), ('Cyan', (0.08, 0.95, 1.00)), ('Teal', (0.08, 0.80, 0.64)),
    ('Green', (0.20, 1.00, 0.30)), ('Lime', (0.72, 1.00, 0.14)), ('Grey', (0.50, 0.50, 0.52)),
]
TRN = os.path.join(os.path.dirname(HERE), 'pk3', 'TRNSLATE.rsqthp')
MARK0 = '// ---- PALETTE (tools/gen_dn_art.py; do not hand-edit) ----'
MARK1 = '// ---- END PALETTE ----'


def palette():
    def mix(c, w, k):
        return tuple(c[i] + (w - c[i]) * k for i in range(3))
    def fmt(c):
        return '[%.2f, %.2f, %.2f]' % c
    L = [MARK0]
    for i, (nm, c) in enumerate(PALETTE):
        shades = [tuple(v * 0.84 for v in c), c, mix(c, 1.0, 0.2), mix(c, 1.0, 0.4)]   # close together: a shimmer, never a strobe
        for s, sc in enumerate(shades):
            k = 1.55
            L.append('RSQTHP_P%02d%d = "0:255=%%[0,0,0]:%s"   // %s %d' % (i, s, fmt(tuple(v * k for v in sc)), nm, s))
    L.append('RSQTHP_PFL = "0:255=%[0,0,0]:[2.40, 2.40, 2.40]"   // the arrival flash')
    for i, (nm, c) in enumerate(PALETTE):
        t = fmt(tuple(v * 2.1 for v in c))
        L.append('RSQTHP_H%02d = "0:79=%%[0,0,0]:%s", "80:111=80:111", "112:255=%%[0,0,0]:%s"   // %s' % (i, t, t, nm))
    L.append(MARK1)
    s = open(TRN).read()
    if MARK0 in s:
        s = s[:s.index(MARK0)] + s[s.index(MARK1) + len(MARK1) + 1:]
    open(TRN, 'w').write(s.rstrip('\n') + '\n' + '\n'.join(L) + '\n')


def panels():
    """the level-up band and the weapon tag's box (grey: tinted by a palette translation)"""
    from PIL import ImageDraw
    # BAND: darker at top and bottom, lighter in the centre (the owner's mockup); its ends fade out sideways
    W, H = 256, 64
    im = Image.new('RGBA', (W, H))
    px = im.load()
    for y in range(H):
        v = 1 - abs(y + 0.5 - H / 2) / (H / 2)
        g = int(255 * (0.12 + 0.45 * v))
        for x in range(W):
            e = min(1.0, min(x + 0.5, W - x - 0.5) / (W * 0.16))
            px[x, y] = (g, g, g, int(255 * (0.45 + 0.33 * v) * e))
    p = os.path.join(OUT, 'RQNBAND.png'); im.save(p, optimize=True); grab(p, W // 2, H // 2)
    # TAG: a dark rounded box (no translation) and its border (white, tinted one steady colour)
    W, H = 200, 72
    f = Image.new('RGBA', (W, H)); ImageDraw.Draw(f).rounded_rectangle([1, 1, W - 2, H - 2], radius=12, fill=(14, 14, 18, 178))
    p = os.path.join(OUT, 'RQNTAGF.png'); f.save(p, optimize=True); grab(p, W // 2, H // 2)
    b = Image.new('RGBA', (W, H)); ImageDraw.Draw(b).rounded_rectangle([1, 1, W - 2, H - 2], radius=12, outline=(235, 235, 235, 255), width=4)
    p = os.path.join(OUT, 'RQNTAGB.png'); b.save(p, optimize=True); grab(p, W // 2, H // 2)
    return 3


if __name__ == '__main__':
    main()
