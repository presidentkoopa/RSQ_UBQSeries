#!/usr/bin/env python3
"""gen_banners.py -- the Arcade Gold banners' and the invulnerability bar's art (tool only; never ships).

design/BANNERS_AND_HUD.md (owner 2026-11-16). Writes VisualRewards/pk3/graphics/rsqvrbn/ and the two fonts:

  RSQVRBF1.fon2 / RSQVRBF2.fon2   copies of RS Score's RSSCFON / RSSCFN2 (Blue Shadow / Jimmy via Dakka; Score/CREDITS.md),
                                  so the banners draw in the Series' fonts with or without RSQ Score loaded
  1UP / -1UP (section 4): the engine colours a font by brightness, never by row, so the banded letters are pictures made
  here from RSSCFON's own glyphs (the banded2 rule: each letter keeps its own tile; the tile goes dark and the letter takes
  its band's colour, row by row; a 1-pixel black outline; drawn at the font's own pixel size):
      RQVBO0..4   the big "1", hot bands (yellow, amber, orange, red from the top); 1..4: that band white (the shine)
      RQVBU0..4   the small raised "UP", the same
      RQVBOC / RQVBUC   the same, cold steel (the -1UP)
      RQVBMC      the minus, one cold band
  Chips: RQVBPL the dark rounded pill (drawn in three slices, ends kept, middle stretched); 16 x 16 pixel-art icons:
      RQVBIH health (green cross), RQVBIA armor (blue shield), RQVBII invulnerable (the magenta orb; also the bar's icon),
      RQVBIM ammo / mags (three rounds), RQVBIU tier up (gold arrow), RQVBID tier down / no legendary (red arrow)
      RQVBSW / RQVBSB  the tier swatch: a white rounded square (the HUD tints it) and its white border
  Motion: RQVBSP a sparkle (white plus, black outline; tinted), RQVBGL a soft white glow (the flashes, the bar's landing),
      RQVBR00..11 the +1UP's rays (12 wedges, two hot colours) turned 5 degrees a frame (60 degrees repeat), so the HUD
      never has to rotate a quad.
  The invulnerability bar's well and white fill are tools/gen_gauges.py's (RQVBIE / RQVBIW, the same art as RSQ SlowMo's
  and RSQ Miniboss's bars).

Run from anywhere: python3 VisualRewards/tools/gen_banners.py"""
import math
import os
import shutil
import struct
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
TOP = os.path.dirname(HERE)
SERIES = os.path.dirname(TOP)
PK3 = os.path.join(TOP, 'pk3')
OUT = os.path.join(PK3, 'graphics', 'rsqvrbn')
SCORE = os.path.join(SERIES, 'Score')

HOT = [(255, 224, 0), (255, 176, 0), (255, 128, 0), (240, 40, 56)]
COLD = [(235, 240, 250), (170, 180, 200), (110, 120, 145), (70, 74, 96)]
SHINE = (255, 255, 235)
INK = (8, 6, 6, 255)


def fon2(data):
    """FON2 (the engine's FSingleLumpFont::LoadFON2) -> {code: RGBA image}, height"""
    assert data[:4] == b'FON2'
    h = data[4] | (data[5] << 8)
    first, last, mono, active = data[6], data[7], data[8], data[10] + 1
    p = 14 if data[11] & 1 else 12
    count = last - first + 1
    if mono:
        widths = [struct.unpack_from('<H', data, p)[0]] * count
        p += 2
    else:
        widths = list(struct.unpack_from('<%dH' % count, data, p))
        p += 2 * count
    pal = [tuple(data[p + 3 * i:p + 3 * i + 3]) for i in range(active)]
    p += 3 * active
    out = {}
    for i in range(count):
        w = widths[i]
        if w == 0:
            continue
        n = w * h
        px = bytearray()
        while len(px) < n:
            c = data[p]
            p += 1
            if c >= 128:
                c -= 256
            if c >= 0:
                px += data[p:p + c + 1]
                p += c + 1
            elif c != -128:
                px += bytes([data[p]]) * (1 - c)
                p += 1
        im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        for y in range(h):
            for x in range(w):
                k = px[y * w + x]
                if k:
                    im.putpixel((x, y), pal[k] + (255,) if k < len(pal) else (255, 0, 255, 255))
        out[first + i] = im
    return out, h


def text(font, s, gap):
    gl = [font.get(ord(c)) for c in s]
    h = max(g.height for g in gl if g)
    w = sum(g.width + gap for g in gl if g) - gap
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    x = 0
    for g in gl:
        im.alpha_composite(g, (x, h - g.height))
        x += g.width + gap
    return im


def pad(im, p):
    o = Image.new('RGBA', (im.width + 2 * p, im.height + 2 * p), (0, 0, 0, 0))
    o.alpha_composite(im, (p, p))
    return o


def outline(m, w=1, col=INK):
    a = m.split()[3].point(lambda v: 255 if v > 0 else 0).filter(ImageFilter.MaxFilter(2 * w + 1))
    o = Image.new('RGBA', m.size, col)
    o.putalpha(a)
    o.alpha_composite(m)
    return o


def banded(font, s, bands):
    """the banded2 rule: the letter keeps its tile; the tile goes dark, the letter takes the band by row"""
    m = pad(text(font, s, 3), 2)
    L = m.convert('L').load()
    A = m.split()[3].load()
    o = Image.new('RGBA', m.size, (0, 0, 0, 0))
    po = o.load()
    ys = [y for y in range(m.height) if any(A[x, y] for x in range(m.width))]
    y0, y1 = min(ys), max(ys) + 1
    for y in range(m.height):
        b = bands[min(len(bands) - 1, max(0, int((y - y0) * len(bands) / (y1 - y0))))]
        for x in range(m.width):
            if not A[x, y]:
                continue
            t = L[x, y] / 255.0
            k = 0.18 + 0.82 * max(0.0, (t - 0.25) / 0.7)
            po[x, y] = tuple(min(255, int(c * k)) for c in b) + (255,)
    o = outline(o, 1)
    return o.crop(o.getbbox())


def save(im, name):
    im.save(os.path.join(OUT, name + '.png'), optimize=True)


# ---- the 16 x 16 icons (the series' pixel art: '#' a near-black outline, as RSQMBSK* / RSQSMHG) ----------------------
def grid(rows, pal):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    for y, r in enumerate(rows):
        assert len(r) == 16, (y, r)
        for x, ch in enumerate(r):
            if ch in pal:
                p[x, y] = pal[ch]
    return im


O = (15, 15, 15, 255)
CROSS = ['................',
         '.....######.....',
         '.....#lggg#.....',
         '.....#lggd#.....',
         '.....#lggd#.....',
         '######lggd######',
         '#lllllgggggggggd#'[:16],
         '#lggggggggggggd#',
         '#lggggggggggggd#',
         '#gddddggggddddd#',
         '######lggd######',
         '.....#lggd#.....',
         '.....#lggd#.....',
         '.....#gddd#.....',
         '.....######.....',
         '................']
CROSS[6] = '#llllllgggggggd#'
SHIELD = ['................',
          '..############..',
          '.#llllllbbbbbb#.',
          '.#lbbbbbbbbbbd#.',
          '.#lbbbbbbbbbbd#.',
          '.#lbbbbbbbbbbd#.',
          '.#lbbbbbbbbbbd#.',
          '.#lbbbbbbbbbbd#.',
          '..#lbbbbbbbbd#..',
          '..#lbbbbbbbbd#..',
          '...#lbbbbbbd#...',
          '...#lbbbbbbd#...',
          '....#lbbbbd#....',
          '.....#bbdd#.....',
          '......####......',
          '................']
ROUNDS = ['................',
          '..#....#....#...',
          '.#l#..#l#..#l#..',
          '.#ld#.#ld#.#ld#.',
          '.#ld#.#ld#.#ld#.',
          '#####.#####.####',
          '#wwd#.#wwd#.#wwd#'[:16],
          '#wwd#.#wwd#.#wwd',
          '#wwd#.#wwd#.#wwd',
          '#wwd#.#wwd#.#wwd',
          '#wwd#.#wwd#.#wwd',
          '#wwd#.#wwd#.#wwd',
          '#####.#####.####',
          '#ccc#.#ccc#.#ccc',
          '#####.#####.####',
          '................']
ARROW_UP = ['................',
            '.......##.......',
            '......#ll#......',
            '.....#lllo#.....',
            '....#llloo#.....',
            '...#lloooood#...',
            '..#llooooooood#.'[:16],
            '.#llooooooooood#',
            '.#######ood####.',
            '.......#ood#....',
            '.......#ood#....',
            '.......#ood#....',
            '.......#ood#....',
            '.......#odd#....',
            '.......#####....',
            '................']


def fix(rows):
    # every row exactly 16, centred art kept as drawn
    return [(r + '................')[:16] for r in rows]


def arrow_rows():
    # a clean symmetric up arrow, drawn by rule (head 7 rows, shaft 5)
    rows = []
    for y in range(16):
        r = ['.'] * 16
        if 1 <= y <= 7:
            half = y            # the head widens a pixel a row
            l, rr = 8 - half, 7 + half
            l, rr = max(l, 1), min(rr, 14)
            for x in range(l, rr + 1):
                r[x] = 'o'
            r[l] = '#'
            r[rr] = '#'
            if y == 7:
                for x in range(l, rr + 1):
                    r[x] = '#'
            elif y >= 2:
                r[l + 1] = 'l'
                r[rr - 1] = 'd'
        elif 8 <= y <= 13:
            for x in range(5, 11):
                r[x] = 'o'
            r[5] = '#'
            r[10] = '#'
            r[6] = 'l'
            r[9] = 'd'
            if y == 13:
                for x in range(5, 11):
                    r[x] = '#'
        if y == 1:
            r = ['.'] * 16
            r[7] = '#'
            r[8] = '#'
        if y == 7:
            # the head's underside, with the shaft through it
            for x in range(1, 15):
                r[x] = '#'
            for x in range(6, 10):
                r[x] = 'o'
            r[6] = 'l'
            r[9] = 'd'
        rows.append(''.join(r))
    return rows


def orb():
    """the invulnerability orb: a magenta sphere lit from the top left, a hard glint, a pale rim light at the bottom
    right and the series' near-black outline; posterised to five shades so it reads as pixel art"""
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    p = im.load()
    shades = [(96, 10, 80), (165, 18, 128), (225, 32, 172), (255, 52, 196), (255, 130, 224)]
    cx = cy = 7.5
    R = 6.95
    lx, ly, lz = -0.5, -0.55, 0.67
    for y in range(16):
        for x in range(16):
            dx, dy = (x - cx) / R, (y - cy) / R
            d2 = dx * dx + dy * dy
            if d2 <= 1.0:
                nz = math.sqrt(max(0.0, 1.0 - d2))
                l = 0.3 + 0.7 * max(0.0, dx * lx + dy * ly + nz * lz)
                k = max(0, min(4, int((l - 0.3) / 0.7 * 5.0)))
                p[x, y] = shades[k] + (255,)
                if 0.55 < d2 <= 0.86 and dx > 0.2 and dy > 0.2:
                    p[x, y] = (255, 150, 226, 255)     # the rim light: a pale crescent at the bottom right
    q = im.copy().load()
    for y in range(16):
        for x in range(16):
            if q[x, y][3] > 0:
                # the outer ring of the sphere becomes the outline
                if any(not (0 <= x + a < 16 and 0 <= y + b < 16) or q[x + a, y + b][3] == 0
                       for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    p[x, y] = O
    for (x, y) in ((4, 4), (5, 4), (4, 5), (5, 5)):
        p[x, y] = (255, 255, 255, 255)
    p[6, 4] = (255, 214, 244, 255)
    p[4, 6] = (255, 214, 244, 255)
    p[7, 3] = (255, 180, 236, 255)
    return im


def rays(frame, n=12, size=256):
    """12 wedges from the middle, the two hot colours by turns, soft toward the end; turned 5 degrees a frame"""
    o = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(o)
    R = size / 2
    for i in range(n):
        a = math.radians(i * 360.0 / n + frame * 5.0)
        a2 = a + math.radians(11)
        col = HOT[i % 2]
        d.polygon([(R, R), (R + R * math.cos(a), R + R * math.sin(a)), (R + R * math.cos(a2), R + R * math.sin(a2))],
                  fill=col + (255,))
    # fade toward the ends and clear the middle (the badge sits there)
    a = o.split()[3].load()
    for y in range(size):
        for x in range(size):
            r = math.hypot(x - R, y - R) / R
            f = 0.0 if r > 1 else (min(1.0, r / 0.18) * (1.0 - r) ** 0.7)
            a[x, y] = int(a[x, y] * f)
    return o


def glow(size=128):
    o = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    a = o.split()[3].load()
    R = size / 2
    for y in range(size):
        for x in range(size):
            r = math.hypot(x + 0.5 - R, y + 0.5 - R) / R
            a[x, y] = int(255 * max(0.0, 1.0 - r) ** 1.6)
    o.putalpha(o.split()[3])
    out = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    out.putalpha(Image.frombytes('L', (size, size), bytes(a[x, y] for y in range(size) for x in range(size))))
    return out


def pill(size=32, r=9):
    """the chip's dark rounded pill, drawn 4x and brought down (smooth corners)"""
    k = 4
    big = Image.new('RGBA', (size * k, size * k), (0, 0, 0, 0))
    ImageDraw.Draw(big).rounded_rectangle((0, 0, size * k - 1, size * k - 1), r * k, fill=(12, 10, 8, 215))
    return big.resize((size, size), Image.LANCZOS)


def swatch(border):
    k = 4
    big = Image.new('RGBA', (16 * k, 16 * k), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    if border:
        d.rounded_rectangle((0, 0, 16 * k - 1, 16 * k - 1), 4 * k, outline=(255, 255, 255, 255), width=2 * k)
    else:
        d.rounded_rectangle((k, k, 15 * k - 1, 15 * k - 1), 3 * k, fill=(255, 255, 255, 255))
    return big.resize((16, 16), Image.LANCZOS)


def sparkle():
    im = Image.new('RGBA', (7, 7), (0, 0, 0, 0))
    p = im.load()
    for i in range(1, 6):
        p[3, i] = (255, 255, 255, 255)
        p[i, 3] = (255, 255, 255, 255)
    return outline(im, 1)


def main():
    os.makedirs(OUT, exist_ok=True)
    for src, dst in (('RSSCFON.fon2', 'RSQVRBF1.fon2'), ('RSSCFN2.fon2', 'RSQVRBF2.fon2')):
        shutil.copyfile(os.path.join(SCORE, src), os.path.join(PK3, dst))
    f1, _ = fon2(open(os.path.join(SCORE, 'RSSCFON.fon2'), 'rb').read())
    for k in range(5):
        b = list(HOT)
        if k:
            b[k - 1] = SHINE
        save(banded(f1, '1', b), 'RQVBO%d' % k)
        save(banded(f1, 'UP', b), 'RQVBU%d' % k)
    save(banded(f1, '1', COLD), 'RQVBOC')
    save(banded(f1, 'UP', COLD), 'RQVBUC')
    save(banded(f1, '-', [COLD[1]]), 'RQVBMC')
    save(pill(), 'RQVBPL')
    save(grid(fix(CROSS), {'#': O, 'l': (190, 255, 170, 255), 'g': (70, 215, 70, 255), 'd': (25, 120, 30, 255)}), 'RQVBIH')
    save(grid(fix(SHIELD), {'#': O, 'l': (190, 220, 255, 255), 'b': (80, 150, 255, 255), 'd': (30, 70, 160, 255)}), 'RQVBIA')
    save(orb(), 'RQVBII')
    save(grid(fix(ROUNDS), {'#': O, 'l': (255, 250, 230, 255), 'd': (160, 160, 165, 255), 'w': (235, 235, 235, 255),
                            'c': (200, 160, 70, 255)}), 'RQVBIM')
    up = grid(arrow_rows(), {'#': O, 'l': (255, 240, 170, 255), 'o': (255, 200, 60, 255), 'd': (190, 120, 20, 255)})
    save(up, 'RQVBIU')
    dn = grid(arrow_rows(), {'#': O, 'l': (255, 170, 160, 255), 'o': (255, 70, 60, 255), 'd': (150, 25, 20, 255)})
    save(dn.transpose(Image.FLIP_TOP_BOTTOM), 'RQVBID')
    save(swatch(False), 'RQVBSW')
    save(swatch(True), 'RQVBSB')
    save(sparkle(), 'RQVBSP')
    save(glow(), 'RQVBGL')
    for i in range(12):
        save(rays(i), 'RQVBR%02d' % i)
    print('banner art ->', OUT)


if __name__ == '__main__':
    main()
