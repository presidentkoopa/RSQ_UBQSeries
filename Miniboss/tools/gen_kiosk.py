#!/usr/bin/env python3
"""gen_kiosk.py -- the Boss kiosk's art (design/KIOSK.md; the look: design/mockups/kiosk/kiosk_TARGET.png and
kiosk_lucky_anim.gif, drawn by kiosk_anim.py / mk.py). Tool only; never ships. Writes:

  sprites/kiosk/   the kiosk's sprites, every one centred on its middle (a grAb chunk), 4 texels a mockup pixel (so the
                   engine's filtering never softens a pixel edge):
      KQHD A / B   the header plate with KIOSK in gold bands (A) and its white-hot look (B): the SOTN flicker
      KQCD A-D     the compare card's frame, edged in the rarity's colour (Common, Uncommon, Rare, Epic)
      KQPP A-E     a price plate edged in the rarity's colour (E: gold, the plate of a sold offer)
      KQCT A       the counter (its top bar, the slatted front)
      KQCL A-D     an offer's light column (drawn additive)
      KQGL A-D     an offer's glow (drawn additive)
      KQFL A       the LUCKY flash (additive, white)
      KQSD A       the SOLD stamp (red bands, tilted)
      KQDT A       a dot of the pointing beam (additive, red)
    and two fonts as sprites, one picture a letter (the kiosk spells its words letter by letter, as the Wheel does):
      KQ<c>0 / KQ<c>1  RS Score's small font (RSSCFN2), tinted by brightness (its dark outline kept) in colour <c>:
                   W white, N neutral, D dim, Y gold, G Common green, B Uncommon blue, P Rare purple, O Epic orange,
                   C cyan (LUCKY), R red. Group 0: A-Z as frames A-Z; group 1: 0-9 as A-J, then - . ! % / : + ? ( ) ' , = & # *
      KQK0 / KQK1  RS Score's big font (RSSCFON) in the banners' gold bands (gen_banners.py glyph); KQH0 / KQH1 its
                   white-hot look (the prices' SOTN flicker)
  zscript/rsqmb/kiosk_font.zs   the letters' widths (font pixels) for the layout

LegenDoom's rarity colours are mk.py's (rsld/data.zs). The fonts are RS Score's own (Score/RSSCFON.fon2, RSSCFN2.fon2), read
with VisualRewards/tools/gen_banners.py's reader.   python3 -I Miniboss/tools/gen_kiosk.py"""
import io
import math
import os
import struct
import sys
import zlib
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(HERE)
SERIES = os.path.dirname(MOD)
sys.path.insert(0, os.path.join(SERIES, 'VisualRewards', 'tools'))
import gen_banners as gb  # noqa: E402

OUT = os.path.join(MOD, 'sprites', 'kiosk')
ZS = os.path.join(MOD, 'zscript', 'rsqmb', 'kiosk_font.zs')
T = 4                                   # texels a mockup pixel

RAR = [((90, 230, 90), (30, 110, 40)),      # Common
       ((90, 150, 255), (30, 50, 140)),     # Uncommon
       ((200, 110, 255), (80, 30, 130)),    # Rare
       ((255, 160, 40), (140, 70, 10))]     # Epic
GOLD = (255, 205, 40)
COLS = {'W': (240, 240, 245), 'N': (205, 205, 215), 'D': (120, 120, 135), 'Y': GOLD, 'G': RAR[0][0], 'B': RAR[1][0],
        'P': RAR[2][0], 'O': RAR[3][0], 'C': (140, 255, 255), 'R': (255, 90, 90)}
G1 = '0123456789-.!%/:+?()\',=&#*'
GOLDBANDS = [(255, 236, 140), (255, 205, 40), (240, 160, 20), (200, 110, 10)]


def grab_png(im, gx, gy):
    """PNG bytes with a grAb chunk (the sprite's offset)"""
    buf = io.BytesIO()
    im.save(buf, 'PNG', optimize=True)
    d = buf.getvalue()
    body = b'grAb' + struct.pack('>ii', int(gx), int(gy))
    chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    ihdr_end = 8 + 12 + struct.unpack('>I', d[8:12])[0]
    return d[:ihdr_end] + chunk + d[ihdr_end:]


def save(im, name, gx=None, gy=None):
    if gx is None:
        gx, gy = im.width // 2, im.height // 2
    with open(os.path.join(OUT, name + '.png'), 'wb') as f:
        f.write(grab_png(im, gx, gy))


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def tint(im, col):
    """mk.py's tint: the dark outline kept, the rest coloured by its brightness"""
    o = im.copy()
    px = o.load()
    for y in range(o.height):
        for x in range(o.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if r < 60:
                px[x, y] = (8, 6, 12, a)
            else:
                k = r / 255.0
                px[x, y] = (int(col[0] * k), int(col[1] * k), int(col[2] * k), a)
    return o


def frame_of(ch):
    if 'A' <= ch <= 'Z':
        return 0, ch
    i = G1.find(ch)
    if i < 0:
        return None
    return 1, chr(ord('A') + i)


def hot(bands, k=0.6):
    return [tuple(int(c + (255 - c) * k) for c in b) for b in bands]


# ---- panels ----------------------------------------------------------------------------------------------------------
def rrect(w, h, r, fill, edge, ew):
    im = Image.new('RGBA', (w * T, h * T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, w * T - 1, h * T - 1), r * T, fill=fill, outline=edge, width=ew * T)
    return im


def bandword(font, s, bands, px):
    """a word in RSSCFON's banded look (gen_banners.glyph per letter, 3 px apart), each font pixel px texels"""
    gl = [gb.glyph(font, c, bands) for c in s]
    w = sum(g.width for g in gl if g) + 1 * (len(gl) - 1)
    h = max(g.height for g in gl if g)
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    x = 0
    for g in gl:
        if g:
            im.alpha_composite(g, (x, 0))
            x += g.width + 1
    return up(im, px)


def header(f1, look):
    im = rrect(148, 38, 4, (20, 16, 8, 235), GOLD, 1)
    bands = GOLDBANDS if look == 0 else hot(GOLDBANDS)
    w = bandword(f1, 'KIOSK', bands, 5)
    im.alpha_composite(w, ((im.width - w.width) // 2, 4 * T))
    return im


def card(r):
    col, dark = RAR[r]
    im = rrect(232, 112, 4, (14, 12, 22, 240), col, 1)
    d = ImageDraw.Draw(im)
    d.rectangle((4 * T, 4 * T, 228 * T - 1, 18 * T - 1), fill=tuple(c // 3 for c in col) + (255,))
    d.rectangle((6 * T, 85 * T, 226 * T - 1, 85 * T + T - 1), fill=(70, 60, 40, 255))
    return im


def plate(col):
    return rrect(76, 20, 3, (20, 16, 8, 255), col, 1)


def counter():
    im = Image.new('RGBA', (380 * T, 75 * T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, 380 * T - 1, 9 * T - 1), fill=(44, 40, 54, 255), outline=GOLD, width=T)
    d.rectangle((0, 9 * T, 380 * T - 1, 75 * T - 1), fill=(22, 20, 28, 255), outline=(150, 120, 30, 255), width=T)
    for x in range(18, 380, 24):
        d.rectangle((x * T, 12 * T, x * T + T - 1, 72 * T - 1), fill=(70, 60, 30, 255))
    return im


def column(col):
    w, h = 40, 72
    im = Image.new('RGBA', (w * T, h * T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    # wider at the counter (bottom), as the mockup's light
    d.polygon([((w / 2 - 12) * T, 6 * T), ((w / 2 + 12) * T, 6 * T), ((w / 2 + 18) * T, (h - 2) * T), ((w / 2 - 18) * T, (h - 2) * T)],
              fill=col + (150,))
    return im.filter(ImageFilter.GaussianBlur(4 * T))


def glow(col, w=92, h=36, a=200):
    im = Image.new('RGBA', ((w + 24) * T, (h + 24) * T), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.ellipse((12 * T, 12 * T, (w + 12) * T, (h + 12) * T), fill=col + (a,))
    return im.filter(ImageFilter.GaussianBlur(7 * T))


def sold(f1):
    w = bandword(f1, 'SOLD', [(255, 120, 110), (240, 40, 56), (200, 20, 30), (140, 10, 20)], 3)
    pad = Image.new('RGBA', (w.width + 40, w.height + 40), (0, 0, 0, 0))
    pad.alpha_composite(w, (20, 20))
    return pad.rotate(12, resample=Image.NEAREST, expand=True)


def dot():
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.ellipse((2, 2, 13, 13), fill=(255, 60, 50, 255))
    return im.filter(ImageFilter.GaussianBlur(1.5))


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith('.png'):
            os.remove(os.path.join(OUT, f))
    f1, h1 = gb.fon2(open(os.path.join(SERIES, 'Score', 'RSSCFON.fon2'), 'rb').read())
    f2, h2 = gb.fon2(open(os.path.join(SERIES, 'Score', 'RSSCFN2.fon2'), 'rb').read())
    save(header(f1, 0), 'KQHDA0')
    save(header(f1, 1), 'KQHDB0')
    for r in range(4):
        L = 'ABCD'[r]
        save(card(r), 'KQCD%s0' % L)
        save(plate(RAR[r][0]), 'KQPP%s0' % L)
        save(column(RAR[r][0]), 'KQCL%s0' % L)
        save(glow(RAR[r][0]), 'KQGL%s0' % L)
    save(plate(GOLD), 'KQPPE0')
    save(counter(), 'KQCTA0', 190 * T, 0)          # its top edge on the counter's height
    save(glow((255, 255, 255), 140, 70, 230), 'KQFLA0')
    save(sold(f1), 'KQSDA0')
    save(dot(), 'KQDTA0')
    # the small font in ten colours
    widths2 = {}
    for c, col in COLS.items():
        for code, g in f2.items():
            ch = chr(code)
            fr = frame_of(ch)
            if not fr:
                continue
            widths2[ch] = g.width
            save(up(tint(g, col), T), 'KQ%s%d%s0' % (c, fr[0], fr[1]))
    # the big banded font, two looks
    widths1 = {}
    for code in f1:
        ch = chr(code)
        fr = frame_of(ch)
        if not fr:
            continue
        for look, bands in (('K', GOLDBANDS), ('H', hot(GOLDBANDS))):
            g = gb.glyph(f1, ch, bands)
            if g is None:
                continue
            widths1[ch] = g.width
            save(up(g, T), 'KQ%s%d%s0' % (look, fr[0], fr[1]))
    # the widths, for the layout (kiosk.zs)
    chars = ''.join(chr(c) for c in range(33, 91))
    def table(wd):
        return ', '.join(str(wd.get(ch, 0)) for ch in chars)
    with open(ZS, 'w') as f:
        f.write('// GENERATED by tools/gen_kiosk.py -- do not hand-edit. The kiosk\'s two sprite fonts: each letter\'s width in\n')
        f.write('// font pixels, for the characters 33 (!) .. 90 (Z); 0 = not in the font. SMALL_H / BIG_H: the cell heights.\n')
        f.write('class RSQMB_KioskFont\n{\n')
        f.write('\tconst SMALL_H = %d;\n\tconst BIG_H = %d;\n\tconst TEX = %d;\n' % (h2, h1 + 2, T))
        f.write('\tstatic int SmallW(int c)\n\t{\n\t\tstatic const int W[] = { %s };\n\t\treturn (c >= 33 && c <= 90) ? W[c - 33] : 0;\n\t}\n' % table(widths2))
        f.write('\tstatic int BigW(int c)\n\t{\n\t\tstatic const int W[] = { %s };\n\t\treturn (c >= 33 && c <= 90) ? W[c - 33] : 0;\n\t}\n' % table(widths1))
        f.write('}\n')
    n = len([f for f in os.listdir(OUT) if f.endswith('.png')])
    print('wrote %d sprites to %s and %s' % (n, OUT, ZS))


if __name__ == '__main__':
    main()
