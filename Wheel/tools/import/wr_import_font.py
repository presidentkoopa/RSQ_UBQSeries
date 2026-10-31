#!/usr/bin/env python3
"""RSQ Wheel: turn a font into glyph cells, TEXTURES entries and a WRFONTS font set, with a preview.

    python3 wr_import_font.py <font> [--name Name] [--size 16] [--aa]
                              [--cell 8x8] [--first 32] [--colour white|keep]
                              [--words auto|font|WRG] [--numbers auto|font|WRD]
                              [--into <Wheel folder>] [--avoid <pk3/wad> ...] [--preview out.png]

Reads:
  .ttf .otf .ttc   any outline font, drawn at --size pixels tall. Sharp edges by default (each pixel
                   is ink or not); --aa keeps the soft edges as grey (the ring's tint turns grey into
                   a darker shade of the colour, not see-through).
  .bdf .pcf .pcf.gz  X11 bitmap fonts, pixel for pixel.
  .png             a glyph sheet: a grid of equal cells, left to right then down. Give the cell size
                   in the name (Arcade_8x8.png, or Arcade_8x8_first33.png when the sheet does not
                   start at the space) or with --cell / --first. Pixel for pixel, never smoothed.
  a folder of PNGs one glyph each, named by the character: A.png, 065.png, digit_7.png,
                   percent.png, minus.png (the last part of the name after _ or - is the character).

The ring draws text upper-cased, one fixed-width cell per character, characters 33..95 only
(! to _ : digits, A-Z, punctuation); anything else is a blank cell. So only those 63 are made, and
a character the font lacks gets an empty cell (never a missing texture). A font with only lower
case letters lends them to the upper-case cells.

Writes (with --into): graphics/wrimport/<PFX>/<PFX><code>.png (the cells, one PNG each, named the
way the ring looks them up: <prefix><3-digit character code>), a TEXTURES block naming them, a
WRFONTS 'fontset <Name> { words .. numbers .. }' block, and the name in the Font menu. The prefix is
three letters starting with W, chosen so it clashes with nothing in the Wheel folder (or in the
--avoid files): lump names stop at 8 characters, so prefix + 3 digits must fit in 8.

--words / --numbers: a font with letters draws the words, one with all ten digits the numbers
(auto). 'font' forces this font; a prefix such as WRG or WRD keeps one of the ring's own (WRG is
DoomFont, WRD the status-bar numerals, WRY / WRN the small gold / grey numerals).

--colour: white (default for outline and bitmap fonts) draws every glyph white so the ring's
palette colours it fully; keep (default for PNG sources) keeps the picture's own shading, which the
ring then tints by brightness (dark pixels stay dark).
"""
import argparse, gzip, os, re, sys, zipfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wr_common import clean_name, upsert_block, add_menu_choice, read_blocks, BUILTIN_FONTSETS
from PIL import Image, ImageDraw, ImageFont

CODES = list(range(33, 96))           # what the ring can draw (wr_q_shim.zs buildText)
DIGITS = [ord(c) for c in '0123456789']
LETTERS = list(range(65, 91))
RING_SETS = {'WRG': (9, 7), 'WRD': (14, 16), 'WRY': (5, 6), 'WRN': (5, 6)}
NAMED = {'space': 32, 'exclam': 33, 'quote': 34, 'hash': 35, 'dollar': 36, 'percent': 37, 'amp': 38,
         'apostrophe': 39, 'lparen': 40, 'rparen': 41, 'star': 42, 'asterisk': 42, 'plus': 43, 'comma': 44,
         'minus': 45, 'dash': 45, 'period': 46, 'dot': 46, 'slash': 47, 'colon': 58, 'semicolon': 59,
         'less': 60, 'equals': 61, 'greater': 62, 'question': 63, 'at': 64, 'lbracket': 91,
         'backslash': 92, 'rbracket': 93, 'caret': 94, 'underscore': 95}


# ------------------------------------------------------------------------------------------
# Readers. Each returns {code: RGBA image}, all the same size (the cell).
# ------------------------------------------------------------------------------------------
def from_outline(path, size, aa):
    font = ImageFont.truetype(path, size)
    # what the font draws for a character it does not have (.notdef), to tell "missing" apart
    def mask(ch):
        m = font.getmask(ch, mode='L' if aa else '1')
        return bytes(m), m.size
    notdef = mask('￿')
    have = {}
    for c in range(33, 127):
        if mask(chr(c)) != notdef: have[c] = chr(c)
    # the cell: tallest ink above and below the baseline, widest ink, over what the ring draws
    tops, bots, wids = [], [], []
    for c in CODES:
        ch = have.get(c) or have.get(c + 32 if 65 <= c <= 90 else -1)
        if not ch: continue
        x0, y0, x1, y1 = font.getbbox(ch, anchor='ls')
        tops.append(y0); bots.append(y1); wids.append(x1 - x0)
    if not tops: raise ValueError('%s: no drawable characters 33..95' % path)
    top, bot = min(tops), max(bots)
    cw, chh = max(wids) + 1, bot - top          # +1: one clear column so neighbours never touch
    out = {}
    for c in CODES:
        ch = have.get(c) or have.get(c + 32 if 65 <= c <= 90 else -1)
        im = Image.new('RGBA', (cw, chh), (0, 0, 0, 0))
        if ch:
            x0, y0, x1, y1 = font.getbbox(ch, anchor='ls')
            ink = Image.new('L', (cw, chh), 0)
            d = ImageDraw.Draw(ink)
            d.fontmode = 'L' if aa else '1'
            ox = (cw - (x1 - x0)) // 2 - x0
            d.text((ox, -top), ch, font=font, fill=255, anchor='ls')
            if aa:
                # soft edges as grey, fully opaque where there is any ink
                px = ink.load()
                for yy in range(chh):
                    for xx in range(cw):
                        v = px[xx, yy]
                        if v: im.putpixel((xx, yy), (v, v, v, 255))
            else:
                white = Image.new('RGBA', (cw, chh), (255, 255, 255, 255))
                im = Image.composite(white, im, ink.point(lambda v: 255 if v >= 128 else 0))
        out[c] = (im, ch is not None)
    return out


def from_bitmap_font(path):
    from PIL import BdfFontFile, PcfFontFile
    fp = gzip.open(path) if path.endswith('.gz') else open(path, 'rb')
    head = fp.read(4); fp.seek(0)
    ff = PcfFontFile.PcfFontFile(fp) if head == b'\x01fcp' else BdfFontFile.BdfFontFile(fp)
    g = ff.glyph
    def get(c):
        e = g[c] if c < len(g) else None
        if not e and 65 <= c <= 90 and c + 32 < len(g): e = g[c + 32]
        return e
    ents = [get(c) for c in CODES]
    tops = [e[1][1] for e in ents if e]; bots = [e[1][3] for e in ents if e]
    wids = [max(e[0][0], e[1][2]) - min(0, e[1][0]) for e in ents if e]
    if not tops: raise ValueError('%s: no drawable characters 33..95' % path)
    top, bot, cw = min(tops), max(bots), max(wids)
    out = {}
    for c, e in zip(CODES, ents):
        im = Image.new('RGBA', (cw, bot - top), (0, 0, 0, 0))
        if e:
            d, dst, src, gim = e
            ink = gim.crop(src).convert('L')
            white = Image.new('RGBA', ink.size, (255, 255, 255, 255))
            im.paste(white, (dst[0] - min(0, dst[0]), dst[1] - top), ink)
        out[c] = (im, e is not None)
    return out


def sheet_spec(path, cell, first):
    m = re.search(r'(\d+)x(\d+)(?:_first(\d+))?', os.path.basename(path))
    if cell:
        cw, ch = (int(v) for v in cell.lower().split('x'))
    elif m:
        cw, ch = int(m.group(1)), int(m.group(2))
    else:
        raise ValueError('%s: give the cell size (--cell 8x8, or put _8x8 in the file name)' % path)
    if first is None: first = int(m.group(3)) if m and m.group(3) else 32
    return cw, ch, first


def opaque_mask(im):
    """RGBA; a sheet with no transparency uses its top-left pixel's colour as the background"""
    im = im.convert('RGBA')
    if im.getextrema()[3][0] == 255:
        bg = im.getpixel((0, 0))
        px = im.load()
        for y in range(im.size[1]):
            for x in range(im.size[0]):
                if px[x, y][:3] == bg[:3]: px[x, y] = (0, 0, 0, 0)
    return im


def from_sheet(path, cell, first):
    cw, ch, first = sheet_spec(path, cell, first)
    im = opaque_mask(Image.open(path))
    cols = im.size[0] // cw
    rows = im.size[1] // ch
    got = {}
    for k in range(cols * rows):
        code = first + k
        g = im.crop(((k % cols) * cw, (k // cols) * ch, (k % cols + 1) * cw, (k // cols + 1) * ch))
        if g.getbbox(): got[code] = g
    out = {}
    for c in CODES:
        g = got.get(c) or (got.get(c + 32) if 65 <= c <= 90 else None)
        out[c] = (g if g else Image.new('RGBA', (cw, ch), (0, 0, 0, 0)), g is not None)
    return out


def code_from_name(fn):
    base = os.path.splitext(os.path.basename(fn))[0]
    last = re.split(r'[_\-\s]', base)[-1]
    if last.lower() in NAMED: return NAMED[last.lower()]
    if re.fullmatch(r'\d{3}', last): return int(last)
    if re.fullmatch(r'0x[0-9a-fA-F]{2}', last): return int(last, 16)
    if len(last) == 1: return ord(last.upper())
    return None


def from_folder(path):
    files = {}
    for fn in sorted(os.listdir(path)):
        if not fn.lower().endswith('.png'): continue
        c = code_from_name(fn)
        if c is not None and 33 <= c <= 95: files[c] = opaque_mask(Image.open(os.path.join(path, fn)))
    if not files: raise ValueError('%s: no PNGs named by character' % path)
    cw = max(i.size[0] for i in files.values()); ch = max(i.size[1] for i in files.values())
    out = {}
    for c in CODES:
        im = Image.new('RGBA', (cw, ch), (0, 0, 0, 0))
        g = files.get(c)
        if g: im.paste(g, ((cw - g.size[0]) // 2, ch - g.size[1]))   # centred, sitting on the bottom
        out[c] = (im, g is not None)
    return out


def load(path, a):
    low = path.lower()
    if os.path.isdir(path): return from_folder(path), 'keep'
    if low.endswith(('.ttf', '.otf', '.ttc')): return from_outline(path, a.size, a.aa), 'white'
    if low.endswith(('.bdf', '.pcf', '.pcf.gz')): return from_bitmap_font(path), 'white'
    if low.endswith('.png'): return from_sheet(path, a.cell, a.first), 'keep'
    raise ValueError('%s: not a font these tools read' % path)


def to_white(im):
    w = Image.new('RGBA', im.size, (255, 255, 255, 255))
    a = im.getchannel('A').point(lambda v: 255 if v >= 128 else 0)
    return Image.composite(w, Image.new('RGBA', im.size, (0, 0, 0, 0)), a)


# ------------------------------------------------------------------------------------------
# Prefixes in use: never take one the Wheel folder or the --avoid files already have.
# ------------------------------------------------------------------------------------------
def used_prefixes(wheel, avoid):
    used = set(RING_SETS)
    pat = re.compile(r'^([A-Z0-9]{3})\d{3}$')
    if wheel:
        for fn in ('TEXTURES.txt', 'WRFONTS.txt'):
            p = os.path.join(wheel, fn)
            if os.path.exists(p):
                t = open(p, encoding='utf-8').read().upper()
                used.update(re.findall(r'"([A-Z0-9]{3})\d{3}"', t))
                used.update(re.findall(r'(?:WORDS|NUMBERS)\s+([A-Z0-9]+)', t))
        for root, _, files in os.walk(os.path.join(wheel, 'graphics')):
            for f in files:
                m = pat.match(os.path.splitext(f)[0].upper())
                if m: used.add(m.group(1))
    for f in avoid or []:
        try:
            if zipfile.is_zipfile(f):
                names = [os.path.splitext(os.path.basename(n))[0].upper() for n in zipfile.ZipFile(f).namelist()]
            else:
                import struct
                d = open(f, 'rb').read()
                n, off = struct.unpack('<ii', d[4:12])
                names = [d[off + 16 * i + 8:off + 16 * i + 16].rstrip(b'\0').decode('latin1').upper() for i in range(n)]
            for nm in names:
                m = pat.match(nm)
                if m: used.add(m.group(1))
        except Exception as e:
            print('  --avoid %s: could not read (%s)' % (f, e))
    return used


def pick_prefix(name, used, previous=None):
    if previous and previous not in used - {previous}: return previous
    letters = [c for c in name.upper() if c.isalpha()] + list('ABCDEFGHIJKLMNOPQSTUVXYZ')
    tried = []
    for i in range(len(letters)):
        for j in range(i + 1, len(letters)):
            p = 'W' + letters[i] + letters[j]
            if p.startswith('WR'): continue          # WR.. is the ring's own
            if p not in used: return p
            tried.append(p)
    raise ValueError('no free prefix')


def side(want, has_all, pfx, cw, chh, default):
    if want == 'font' or (want == 'auto' and has_all): return pfx, cw, chh
    p = default if want in ('auto', 'font') else want.upper()
    if p not in RING_SETS: raise ValueError('--words/--numbers: %s is not one of %s' % (p, ', '.join(RING_SETS)))
    return (p,) + RING_SETS[p]


def preview(name, pfx, cells, words, numbers, out, tint=(0xEF, 0x9F, 0x27)):
    cw, chh = next(iter(cells.values()))[0].size
    s = max(1, min(6, 48 // max(chh, 1)))
    W = max(16 * (cw * s + 4) + 16, 520)
    H = 30 + 4 * (chh * s + 6) + 30 + chh * s * 2 + 40
    im = Image.new('RGB', (W, H), (28, 30, 36))
    d = ImageDraw.Draw(im)
    d.text((8, 6), 'fontset %s  cells %s000..  %dx%d  words %s  numbers %s  (red: not in the font, blank cell)' % (
        name, pfx, cw, chh, words[0], numbers[0]), fill=(230, 230, 230))
    for k, c in enumerate(CODES):
        g, ok = cells[c]
        x, y = 8 + (k % 16) * (cw * s + 4), 24 + (k // 16) * (chh * s + 6)
        d.rectangle([x - 1, y - 1, x + cw * s, y + chh * s], outline=(70, 70, 80) if ok else (160, 40, 40))
        im.paste(g.resize((cw * s, chh * s), Image.NEAREST), (x, y), g.resize((cw * s, chh * s), Image.NEAREST))
    # a line as the ring lays it out: fixed cells side by side, tinted the way the ring tints
    y = 24 + 4 * (chh * s + 6) + 12
    d.text((8, y), 'as a card line (cells side by side, tinted):', fill=(200, 200, 200))
    x = 8; y += 14
    for ch in 'PISTOL 200%':
        c = ord(ch)
        if c in cells:
            g = cells[c][0].resize((cw * s * 2 // 2, chh * s), Image.NEAREST)
            px = g.load()
            for yy in range(g.size[1]):
                for xx in range(g.size[0]):
                    r, gg, b, a = px[xx, yy]
                    if a:
                        l = (0.299 * r + 0.587 * gg + 0.114 * b) / 255.0
                        v = min(1.0, l * 2.2); gr = l * 255 * 0.45
                        px[xx, yy] = tuple(int(min(255, t * v + gr)) for t in tint) + (255,)
            im.paste(g, (x, y), g)
        x += cw * s
    im.save(out)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('font')
    ap.add_argument('--name')
    ap.add_argument('--size', type=int, default=16, help='outline fonts: pixel height to draw at (default 16)')
    ap.add_argument('--aa', action='store_true', help='outline fonts: keep soft edges (default: sharp)')
    ap.add_argument('--cell', help='PNG sheets: cell size WxH')
    ap.add_argument('--first', type=int, help='PNG sheets: character code of the first cell (default 32)')
    ap.add_argument('--colour', choices=['white', 'keep'], help='see above')
    ap.add_argument('--words', default='auto'); ap.add_argument('--numbers', default='auto')
    ap.add_argument('--into', help='a Wheel folder to write into')
    ap.add_argument('--out', help='without --into: a folder for the cells and text (default ./<Name>_font)')
    ap.add_argument('--avoid', nargs='*', default=[], help='pk3/wad files whose lump names to keep clear of')
    ap.add_argument('--preview')
    a = ap.parse_args(argv)

    name = a.name or clean_name(a.font.rstrip('/'))
    if name.lower() in [b.lower() for b in BUILTIN_FONTSETS]: name += 'Imp'
    cells, colour = load(a.font.rstrip('/'), a)
    colour = a.colour or colour
    if colour == 'white': cells = {c: (to_white(g), ok) for c, (g, ok) in cells.items()}
    cw, chh = cells[65][0].size
    have = {c for c, (g, ok) in cells.items() if ok}
    if not have: sys.exit('%s: nothing drawable in 33..95' % a.font)

    root = a.into or a.out or ('%s_font' % name)
    os.makedirs(root, exist_ok=True)
    prev = None
    for body in read_blocks(os.path.join(root, 'WRFONTS.txt'), 'fontset').get(name, '').splitlines():
        m = re.search(r'prefix (\w+)', body)
        if m: prev = m.group(1)
    pfx = pick_prefix(name, used_prefixes(root, a.avoid), prev)
    words = side(a.words, all(c in have for c in LETTERS), pfx, cw, chh, 'WRG')
    numbers = side(a.numbers, all(c in have for c in DIGITS), pfx, cw, chh, 'WRD')

    gdir = os.path.join(root, 'graphics', 'wrimport', pfx)
    if os.path.isdir(gdir):
        for f in os.listdir(gdir): os.remove(os.path.join(gdir, f))
    os.makedirs(gdir, exist_ok=True)
    T = ['// font set %s (prefix %s) from %s by wr_import_font.py: one %dx%d cell per character' % (
        name, pfx, os.path.basename(a.font.rstrip('/')), cw, chh)]
    for c in CODES:
        g, ok = cells[c]
        lump = '%s%03d' % (pfx, c)
        if ok:
            g.save(os.path.join(gdir, lump + '.png'))
            T.append('Graphic "%s", %d, %d { Patch "graphics/wrimport/%s/%s.png", 0, 0 }' % (lump, cw, chh, pfx, lump))
        else:
            T.append('Graphic "%s", %d, %d { }   // not in the font' % (lump, cw, chh))
    F = ['// prefix %s, from %s by wr_import_font.py (%d of 63 characters)' % (pfx, os.path.basename(a.font.rstrip('/')), len(have)),
         'fontset %s { words %s %d %d   numbers %s %d %d }' % ((name,) + words + numbers)]
    upsert_block(os.path.join(root, 'TEXTURES.txt'), 'fontcells', name, '\n'.join(T))
    upsert_block(os.path.join(root, 'WRFONTS.txt'), 'fontset', name, '\n'.join(F))
    if a.into: add_menu_choice(a.into, 'wr_FontSets', name, name)
    pv = a.preview or os.path.join(root, 'import_previews', '%s_font.png' % name)
    os.makedirs(os.path.dirname(os.path.abspath(pv)), exist_ok=True)
    preview(name, pfx, cells, words, numbers, pv)
    print('font set %s: prefix %s, %dx%d cells, %d of 63 characters, words %s, numbers %s; preview %s' % (
        name, pfx, cw, chh, len(have), words[0], numbers[0], pv))
    return name


if __name__ == '__main__':
    main()
