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
      KQLF A       a Score life pip (Score/graphics/HUD_LIF1), flying to an offer on LUCKY (the mockup's)
    and THE SOTN FONT as sprites (owner 2026-11-16 06:30: the kiosk's SOTN letters were "what I liked the most"): every
    word and number on the kiosk is the owner's SOTN word sheet (design/mockups/kiosk/sotn_word_sheet.png, his upload
    16c02e30-image.png; kiosk_anim.py / sotnfont.py / ext.py cut it the same way), one picture a letter. The sheet's
    glyphs are cut out (ext.py's bands and columns), each pixel read as outline, top tone or bottom tone (the SOTN two
    tones, top half and bottom half); the letters the sheet lacks (B J Q V X Z and the marks) are drawn on the same 3 x 5
    grid in the same box. Then every glyph is painted in each colour's two tones (the sheet's own where it has the colour):
      KQ<c>0 / KQ<c>1  c: W white, N silver (neutral), D dim, Y gold, G green (Common), B blue (Uncommon), P purple (Rare),
                   O orange (Epic), C cyan (LUCKY), R red. Group 0: A-Z as frames A-Z; group 1: 0-9 as A-J, then
                   - . ! % / : + ? ( ) ' , = & # *
      KQY2 / KQY3, KQY4 / KQY5   gold's two other shades (sotnfont.py shade 1.25 and 0.8): the mockup's shimmer
LegenDoom's rarity colours are mk.py's (rsld/data.zs). The fonts are RS Score's own (Score/RSSCFON.fon2, RSSCFN2.fon2), read
with VisualRewards/tools/gen_banners.py's reader (the SOLD stamp, gone since the SOTN letters, used RSSCFON).
    python3 -I Miniboss/tools/gen_kiosk.py"""
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
    """the sign's plate; KIOSK itself is SOTN letters laid over it (kiosk.zs)"""
    return rrect(148, 38, 4, (20, 16, 8, 235), GOLD, 1)


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


# ---- THE SOTN FONT (the owner's word sheet, cut as ext.py / sotnfont.py cut it) --------------------------------------
SHEET = os.path.join(SERIES, 'design', 'mockups', 'kiosk', 'sotn_word_sheet.png')
LINES = ['CRITICAL!! GUARD MISS!!', 'CURSE STONE POISON -DOWN', '-UP STRENGTH INTELLIGENCE',
         'LUCKY DEFENCE OFFENCE', 'PROTECTION FROM FIRE DARK', 'HOLY ICE THUNDER PHYSICAL']
SHEET_COLS = [['white', 'cyan', 'green'], ['gold', 'violet', 'red'], ['silver', 'orange', 'lime']]


def cut_sheet():
    """ext.py: the sheet's 3 x 3 blocks, each a digit row then six word rows; sotnfont.py: words into letters"""
    S = Image.open(SHEET).convert('RGBA')
    bg = S.getpixel((1, 1))
    SP = S.load()

    def ink(p):
        return abs(p[0] - bg[0]) + abs(p[1] - bg[1]) + abs(p[2] - bg[2]) >= 40

    def key(im):
        im = im.copy()
        px = im.load()
        for y in range(im.height):
            for x in range(im.width):
                if not ink(px[x, y]):
                    px[x, y] = (0, 0, 0, 0)
        bb = im.getbbox()
        return im.crop(bb) if bb else im

    def bands(x0, x1, y0, y1, axis, gap=1):
        out = []
        on = False
        miss = 0
        rng = range(y0, y1) if axis == 'y' else range(x0, x1)
        for v in rng:
            hit = any(ink(SP[x, v]) for x in range(x0, x1)) if axis == 'y' else any(ink(SP[v, y]) for y in range(y0, y1))
            if hit:
                if not on:
                    s0 = v
                    on = True
                miss = 0
                last = v
            elif on:
                miss += 1
                if miss > gap:
                    out.append((s0, last + 1))
                    on = False
        if on:
            out.append((s0, last + 1))
        return out

    def letters(im, s):
        px = im.load()
        bright = [any(px[x, y][3] and max(px[x, y][:3]) > 110 for y in range(im.height)) for x in range(im.width)]
        runs = []
        on = False
        for x, b in enumerate(bright):
            if b and not on:
                s0 = x
                on = True
            if not b and on:
                runs.append((s0, x))
                on = False
        if on:
            runs.append((s0, len(bright)))
        chars = [c for c in s if c != ' ']
        if len(runs) != len(chars):
            return {}
        return {c: im.crop((max(0, x0 - 1), 0, min(im.width, x1 + 1), im.height)) for (x0, x1), c in zip(runs, chars)}

    cols = [(0, 106), (106, 212), (212, 318)]
    font = {}
    for ci, (x0, x1) in enumerate(cols):
        yb = bands(x0, x1, 0, S.height, 'y', 0)
        for ri in range(3):
            nm = SHEET_COLS[ri][ci]
            rows = yb[ri * 7:ri * 7 + 7]
            gl = {}
            for k, (a, b) in enumerate(rows[1:7]):
                segs = bands(x0, x1, a, b, 'x', 2)
                for j, (s0, s1) in enumerate(segs[:1]):
                    for c, g in letters(key(S.crop((s0, a, s1, b))), LINES[k]).items():
                        gl.setdefault(c, g)
            dy = rows[0]
            for i, (s0, s1) in enumerate(bands(x0, x1, dy[0], dy[1], 'x', 0)):
                gl['1234567890'[i]] = key(S.crop((s0, dy[0], s1, dy[1])))
            font[nm] = gl
    return font


def classes(g):
    """a sheet glyph as a grid: '#' outline, 't' top tone (the darker), 'b' bottom tone, ' ' clear"""
    px = g.load()
    tones = sorted(set(sum(px[x, y][:3]) for x in range(g.width) for y in range(g.height) if px[x, y][3] and max(px[x, y][:3]) >= 60))
    cut = (tones[0] + tones[-1]) / 2.0 if tones else 0
    rows = []
    for y in range(g.height):
        r = ''
        for x in range(g.width):
            p = px[x, y]
            if not p[3]:
                r += ' '
            elif max(p[:3]) < 60:
                r += '#'
            else:
                r += 't' if sum(p[:3]) < cut else 'b'
        rows.append(r)
    return rows


# the letters and marks the sheet does not have, on its 3 x 5 grid (1 lit); boxed and toned as the sheet's
EXTRA = {
    'B': ['11 ', '1 1', '11 ', '1 1', '11 '], 'J': ['  1', '  1', '  1', '1 1', '111'], 'Q': ['111', '1 1', '1 1', '111', '  1'],
    'V': ['1 1', '1 1', '1 1', '1 1', ' 1 '], 'X': ['1 1', '1 1', ' 1 ', '1 1', '1 1'], 'Z': ['111', '  1', ' 1 ', '1  ', '111'],
    '.': [' ', ' ', ' ', ' ', '1'], ',': [' ', ' ', ' ', '1', '1'], "'": ['1', '1', ' ', ' ', ' '], ':': [' ', '1', ' ', '1', ' '],
    '/': ['  1', '  1', ' 1 ', '1  ', '1  '], '%': ['1 1', '  1', ' 1 ', '1  ', '1 1'], '+': ['   ', ' 1 ', '111', ' 1 ', '   '],
    '?': ['111', '  1', ' 11', '   ', ' 1 '], '(': [' 1', '1 ', '1 ', '1 ', ' 1'], ')': ['1 ', ' 1', ' 1', ' 1', '1 '],
    '=': ['   ', '111', '   ', '111', '   '], '&': [' 1 ', '1 1', ' 1 ', '1 1', ' 11'], '#': ['1 1', '111', '1 1', '111', '1 1'],
    '*': ['   ', '1 1', ' 1 ', '1 1', '   '],
}


def drawn(mask):
    """a 3 x 5 (or narrower) mask in the sheet's box: a 1-pixel outline all round, top two rows the top tone"""
    w = len(mask[0]) + 2
    rows = ['#' * w]
    for y, m in enumerate(mask):
        rows.append('#' + ''.join(('t' if y < 2 else 'b') if c == '1' else '#' for c in m) + '#')
    rows.append('#' * w)
    return rows


def paint(rows, top, bot, f=1.0):
    """the grid in two tones; f: sotnfont.py's shade (brighter above 1, with a touch of white)"""
    def sh(c):
        v = [min(255, int(k * f + (255 * (f - 1) if f > 1 else 0) * 0.25)) for k in c]
        return tuple(v) + (255,)
    im = Image.new('RGBA', (len(rows[0]), len(rows)), (0, 0, 0, 0))
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c == '#':
                im.putpixel((x, y), (8, 8, 8, 255))
            elif c == 't':
                im.putpixel((x, y), sh(top))
            elif c == 'b':
                im.putpixel((x, y), sh(bot))
    return im


def tones(gl):
    """a sheet colour's (top, bottom) tones, read off its 0"""
    rows = classes(gl['0'])
    px = gl['0'].load()
    t = b = None
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c == 't' and t is None:
                t = px[x, y][:3]
            if c == 'b' and b is None:
                b = px[x, y][:3]
    return t or b, b or t       # one tone only (the sheet's green): both halves alike


def sotn_set():
    """{char: grid}, and every colour's tones"""
    font = cut_sheet()
    grids = {c: classes(g) for c, g in font['white'].items()}
    for c, m in EXTRA.items():
        grids.setdefault(c, drawn(m))
    st = {nm: tones(font[nm]) for nm in font}
    def mix(c, k):
        return tuple(int(v * k) for v in c)
    pal = {
        'W': st['white'], 'N': (mix(st['silver'][0], 0.85), mix(st['silver'][1], 0.92)), 'D': (mix(st['silver'][0], 0.5), mix(st['silver'][1], 0.55)),
        'Y': st['gold'], 'G': st['lime'], 'B': ((56, 100, 232), (110, 170, 255)), 'P': ((150, 70, 220), (210, 140, 255)),
        'O': st['orange'], 'C': st['cyan'], 'R': st['red'],
    }
    return grids, pal


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith('.png'):
            os.remove(os.path.join(OUT, f))
    f1, h1 = gb.fon2(open(os.path.join(SERIES, 'Score', 'RSSCFON.fon2'), 'rb').read())
    save(header(f1, 0), 'KQHDA0')
    for r in range(4):
        L = 'ABCD'[r]
        save(card(r), 'KQCD%s0' % L)
        save(plate(RAR[r][0]), 'KQPP%s0' % L)
        save(column(RAR[r][0]), 'KQCL%s0' % L)
        save(glow(RAR[r][0]), 'KQGL%s0' % L)
    save(plate(GOLD), 'KQPPE0')
    save(counter(), 'KQCTA0', 190 * T, 0)          # its top edge on the counter's height
    save(glow((255, 255, 255), 140, 70, 230), 'KQFLA0')
    save(dot(), 'KQDTA0')
    pip = Image.open(os.path.join(SERIES, 'Score', 'graphics', 'HUD_LIF1.png')).convert('RGBA')
    save(up(pip, T), 'KQLFA0')
    # THE SOTN FONT
    grids, pal = sotn_set()
    widths = {}
    for c, (top, bot) in pal.items():
        for ch, rows in grids.items():
            fr = frame_of(ch)
            if not fr:
                continue
            widths[ch] = len(rows[0])
            save(up(paint(rows, top, bot), T), 'KQ%s%d%s0' % (c, fr[0], fr[1]))
            if c == 'Y':   # the shimmer's two other shades
                save(up(paint(rows, top, bot, 1.25), T), 'KQY%d%s0' % (fr[0] + 2, fr[1]))
                save(up(paint(rows, top, bot, 0.8), T), 'KQY%d%s0' % (fr[0] + 4, fr[1]))
    heights = sorted(set(len(r) for r in grids.values()))
    chars = ''.join(chr(c) for c in range(33, 91))
    with open(ZS, 'w') as f:
        f.write('// GENERATED by tools/gen_kiosk.py -- do not hand-edit. The kiosk\'s SOTN letters (the owner\'s word sheet): each\n')
        f.write('// letter\'s width in font pixels, outline included (neighbours share one outline column), for the characters 33 (!)\n')
        f.write('// .. 90 (Z); 0 = not in the font. H: a letter\'s height (digits are a pixel taller; centred alike).\n')
        f.write('class RSQMB_KioskFont\n{\n')
        f.write('\tconst H = %d;\n\tconst TEX = %d;\n' % (heights[0], T))
        f.write('\tstatic int W(int c)\n\t{\n\t\tstatic const int T[] = { %s };\n\t\treturn (c >= 33 && c <= 90) ? T[c - 33] : 0;\n\t}\n'
                % ', '.join(str(widths.get(ch, 0)) for ch in chars))
        f.write('}\n')
    n = len([f for f in os.listdir(OUT) if f.endswith('.png')])
    print('wrote %d sprites to %s and %s; %d SOTN letters (%d cut from the sheet)' % (n, OUT, ZS, len(grids), len(grids) - len(EXTRA)))


if __name__ == '__main__':
    main()
