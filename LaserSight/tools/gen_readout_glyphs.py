#!/usr/bin/env python3
"""Generate the range readout's glyphs (owner 2026-11-10: "Redo it as glyphs"). Deterministic.

    python3 tools/gen_readout_glyphs.py [--font path.ttf]

  graphics/rsqls/RSLNnnn.png   one glyph per character, nnn its ASCII code: 0-9 . m f t u

QuestZDoom 17.3 draws a canvas texture black or not at all in VR (rig group P4, 11-10, L5), so the readout is no
longer a canvas: like RSQ Score's wrist digits and the Saber's training-remote panel, each character is a billboard
actor whose picture is set through picnum and drawn AddShaded in the dot's colour (sight.zs, THE RANGE READOUT).
The series' own glyph sets have no lowercase (Doom's STCFN, RSSCFON, JFO), and the units are "m", "ft" and "u", so
these are rendered from DejaVu Sans Bold (tools/fonts/, Bitstream Vera licence, tools/fonts/DejaVu_LICENSE.txt).

Every glyph is WHITE on clear (AddShaded draws by brightness; the shade is the colour), on the same 48 px tall
canvas with one baseline, so a row of them lines up; each is its own advance wide; its grAb is the canvas centre,
so the actor's position is the glyph cell's centre. A digit is DIGIT_PX tall: sight.zs scales by that.
"""
import os, sys, struct, zlib
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
FONT = os.path.join(HERE, 'fonts', 'DejaVuSans-Bold.ttf')
CHARS = '0123456789.mftu'
H = 48            # canvas height (sight.zs GLYPH_PX)
BASE = 40         # baseline row
SIZE = 44         # font size in px: a digit is then 32 px tall (DIGIT_PX, checked below)


def png(path, im, grab):
    w, h = im.size
    raw = b''.join(b'\0' + bytes(v for x in range(w) for v in im.getpixel((x, y))) for y in range(h))
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
                           + chunk(b'grAb', struct.pack('>ii', *grab)) + chunk(b'IDAT', zlib.compress(raw, 9))
                           + chunk(b'IEND', b''))


def main():
    font_path = FONT
    if '--font' in sys.argv: font_path = sys.argv[sys.argv.index('--font') + 1]
    font = ImageFont.truetype(font_path, SIZE)
    out = os.path.join(ROOT, 'graphics', 'rsqls')
    os.makedirs(out, exist_ok=True)
    for ch in CHARS:
        adv = font.getlength(ch)
        w = int(round(adv)) + 2
        w += w % 2                                   # even, so grAb is the exact centre
        mask = Image.new('L', (w, H), 0)
        ImageDraw.Draw(mask).text(((w - adv) / 2.0, BASE), ch, font=font, fill=255, anchor='ls')
        im = Image.new('RGBA', (w, H))
        im.putdata([(255, 255, 255, a) if a else (0, 0, 0, 0) for a in mask.getdata()])
        name = 'RSLN%03d' % ord(ch)
        png(os.path.join(out, name + '.png'), im, (w // 2, H // 2))
        bb = mask.getbbox()
        print('%s %r  %dx%d  ink rows %d-%d' % (name, ch, w, H, bb[1], bb[3] - 1))


if __name__ == '__main__':
    main()
