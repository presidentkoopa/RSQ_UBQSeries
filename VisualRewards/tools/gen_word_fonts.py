#!/usr/bin/env python3
"""gen_word_fonts.py -- the Word Font choice's glyphs (owner 11-16): the words over monsters (rsqvr/words.zs) in five
fonts. Tool only; never ships. Do not hand-edit what it writes.

    python3 -I VisualRewards/tools/gen_word_fonts.py

Each font is one texture per character nnn (33..96), named QW<F>W<nnn>, all of one height (the font's cell), with a grAb
offset at its centre (as gen_beams.py's QVWnnn), and the SOTN two-tone halves over it as TEXTURES definitions (as
gen_sotn_halves.py does for QVWnnn): QW<F>H / QW<F>L the top and bottom half, QW<F>T / QW<F>B each half in a full-size cell
with the glyph's own centre offset. The split is on a whole font row (the cell's rows // 2).

  F  menu            source                                                        texture px per font px
  S  Score Small     RS Score's RSSCFN2, VisualRewards' own copy pk3/RSQVRBF2.fon2  4 (nearest: crisp under filtering)
  O  SOTN            the letters cut from the owner's word sheet (tools/word_fonts/  4
                     sotn_sheet_white.png: its white set), the ones the sheet lacks
                     drawn here in its style (SOTN_EXTRA)
  J  JFO             the damage numbers' JFO small letters (tools/dn_art/jfo_small,  1 (it is smooth art, not pixels)
                     levelled and cropped as gen_dn_art.py does), ! . , ' made here
                     from its own I
  D  Doom small      the IWAD's own STCFN patches, by TEXTURES (no IWAD art copied):  1
                     their red ramp (176..190) re-mapped to a grey ramp and the dark
                     (191, 45..47) to near-black, so the words colour them as they
                     colour the others
Score Big (RSSCFON) is gen_beams.py's QVWnnn and gen_sotn_halves.py's QVT / QVB, unchanged.

WHAT IT WRITES  pk3/graphics/rsqvrwf/QW{S,O,J}Wnnn.png (the folder is this tool's alone: it is cleared first)
                pk3/TEXTURES.rsqvrwf (QWDWnnn, and the halves of all four)
and prints each font's cell height and its H's ink height (words.zs sizes each font by it: WF_FH).
"""
import os, struct, zlib
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
VR = os.path.dirname(HERE)
PK3 = os.path.join(VR, 'pk3')
OUT = os.path.join(PK3, 'graphics', 'rsqvrwf')
TEX = os.path.join(PK3, 'TEXTURES.rsqvrwf')
FN2 = os.path.join(PK3, 'RSQVRBF2.fon2')                   # = Score/RSSCFN2.fon2 (VisualRewards' copy: works without Score)
SOTN_SHEET = os.path.join(HERE, 'word_fonts', 'sotn_sheet_white.png')
JFO = os.path.join(HERE, 'dn_art', 'jfo_small')


def grab_png(path, rgba, gx, gy):
    """save RGBA (uint8 HxWx4) with a grAb chunk (ZDoom's offset) after IHDR"""
    Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
    d = open(path, 'rb').read()
    body = b'grAb' + struct.pack('>ii', int(gx), int(gy))
    chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    i = 8 + 12 + struct.unpack('>I', d[8:12])[0]
    open(path, 'wb').write(d[:i] + chunk + d[i:])


def emit(font, c, a, k):
    """a: HxWx4 uint8 at font pixels; written k x k nearest, offset at its centre"""
    if k != 1:
        a = a.repeat(k, 0).repeat(k, 1)
    h, w = a.shape[:2]
    grab_png(os.path.join(OUT, 'QW%sW%03d.png' % (font, c)), a, w // 2, h // 2)
    return w, h


# ===================================================================================================================
# S: SCORE SMALL (RSSCFN2; FON2 read as gen_beams.py's load_fon2, levelled the same way)
def load_fon2(path):
    d = open(path, 'rb').read()
    assert d[:4] == b'FON2'
    height = d[4] | (d[5] << 8)
    first, last = d[6], d[7]
    mono = d[8]
    active = d[10] + 1
    count = last - first + 1
    p = 12; kern = 0
    if d[11] & 1:
        kern = struct.unpack_from('<h', d, 12)[0]; p = 14
    if mono:
        w0 = struct.unpack_from('<H', d, p)[0]; widths = [w0] * count; p += 2
    else:
        widths = list(struct.unpack_from('<%dH' % count, d, p)); p += 2 * count
    pal = [tuple(d[p + 3 * i: p + 3 * i + 3]) for i in range(active)]; p += 3 * active
    glyphs = {}
    for i in range(count):
        w = widths[i]
        if w == 0: continue
        n = w * height; out = bytearray()
        while len(out) < n:
            code = d[p]; p += 1
            if code >= 128: code -= 256
            if code >= 0:
                out += d[p:p + code + 1]; p += code + 1
            elif code != -128:
                out += bytes([d[p]]) * (1 - code); p += 1
        glyphs[first + i] = (w, bytes(out[:n]))
    return height, first, last, widths, pal, glyphs, kern


def font_small():
    height, first, last, widths, pal, glyphs, kern = load_fon2(FN2)
    lum = [0.299 * r + 0.587 * g + 0.114 * b for (r, g, b) in pal]
    top = max(lum[1:])
    ink0, ink1 = 99, -1
    for c in range(33, 97):
        if c not in glyphs: continue
        gw, px = glyphs[c]
        a = np.zeros((height, gw, 4), np.uint8)
        for y in range(height):
            for x in range(gw):
                k = px[y * gw + x]
                if k == 0: continue
                v = int(round(255 * min(1.0, lum[k] / top)))
                a[y, x] = (v, v, v, 255)
                if c == ord('H'): ink0, ink1 = min(ink0, y), max(ink1, y)
        emit('S', c, a, 4)
    return dict(cell=height, ink=ink1 - ink0 + 1, kern=kern, space=widths[32 - first] + kern, k=4)


# ===================================================================================================================
# O: SOTN (the owner's word sheet, its white set: each word one dark box, the letters' faces lit in two greys, the top two
# face rows the darker (the digits' top three); letters 5 face rows, digits 6; neighbours share the box's 1 px column)
SOTN_LINES = ['1234567890', 'CRITICAL!! GUARD MISS!!', 'CURSE STONE POISON -DOWN', '-UP STRENGTH INTELLIGENCE',
              'LUCKY DEFENCE OFFENCE', 'PROTECTION FROM FIRE DARK', 'HOLY ICE THUNDER PHYSICAL']
# the characters the sheet lacks, drawn in its style (x = face); 5 rows like its letters. The same shapes as the Boss
# kiosk's SOTN letters (Miniboss/tools/gen_kiosk.py EXTRA), so the Series draws one SOTN alphabet
SOTN_EXTRA = {
    'B': ['xx.', 'x.x', 'xx.', 'x.x', 'xx.'], 'J': ['..x', '..x', '..x', 'x.x', 'xxx'],
    'Q': ['xxx', 'x.x', 'x.x', 'xxx', '..x'], 'V': ['x.x', 'x.x', 'x.x', 'x.x', '.x.'],
    'X': ['x.x', 'x.x', '.x.', 'x.x', 'x.x'], 'Z': ['xxx', '..x', '.x.', 'x..', 'xxx'],
    '!': ['x', 'x', 'x', '.', 'x'], '?': ['xxx', '..x', '.xx', '...', '.x.'], '.': ['.', '.', '.', '.', 'x'],
    ',': ['.', '.', '.', 'x', 'x'], "'": ['x', 'x', '.', '.', '.'], '"': ['x.x', 'x.x', '...', '...', '...'],
    ':': ['.', 'x', '.', 'x', '.'], '+': ['...', '.x.', 'xxx', '.x.', '...'], '/': ['..x', '..x', '.x.', 'x..', 'x..'],
    '(': ['.x', 'x.', 'x.', 'x.', '.x'], ')': ['x.', '.x', '.x', '.x', 'x.'], '%': ['x.x', '..x', '.x.', 'x..', 'x.x'],
    '=': ['...', 'xxx', '...', 'xxx', '...'], '*': ['...', 'x.x', '.x.', 'x.x', '...'],
    '#': ['x.x', 'xxx', 'x.x', 'xxx', 'x.x'], '&': ['.x.', 'x.x', '.x.', 'x.x', '.xx'],
}
SOTN_CELL = 8
SOTN_GREY = (8, 152, 224)          # the box, the darker face, the lighter face (the sheet's white set)


def sotn_masks():
    im = Image.open(SOTN_SHEET).convert('RGBA')
    px = im.load()
    rows, on = [], False
    for y in range(im.height):
        hit = any(px[x, y][3] for x in range(im.width))
        if hit and not on: s = y; on = True
        if not hit and on: rows.append((s, y)); on = False
    if on: rows.append((s, im.height))
    assert len(rows) == len(SOTN_LINES), rows
    G = {}
    for (y0, y1), line in zip(rows, SOTN_LINES):
        lit = lambda x, y: px[x, y][3] and max(px[x, y][:3]) > 110
        bright = [any(lit(x, y) for y in range(y0, y1)) for x in range(im.width)]
        runs, on = [], False
        for x, b in enumerate(bright):
            if b and not on: x0 = x; on = True
            if not b and on: runs.append((x0, x)); on = False
        if on: runs.append((x0, im.width))
        chars = [c for c in line if c != ' ']
        assert len(runs) == len(chars), (line, len(runs))
        for (x0, x1), c in zip(runs, chars):
            G.setdefault(c, [''.join('x' if lit(x, y) else '.' for x in range(x0, x1)) for y in range(y0 + 1, y1 - 1)])
    for c, m in SOTN_EXTRA.items():
        G[c] = m                    # (the sheet's '!' is shaded oddly where it stands doubled: ours)
    return G


def font_sotn():
    G = sotn_masks()
    for ch, m in G.items():
        rows, w = len(m), len(m[0])
        dark = 3 if rows == 6 else 2            # the darker face rows (digits 3, letters 2)
        a = np.zeros((SOTN_CELL, w + 2, 4), np.uint8)
        y0 = SOTN_CELL - (rows + 2)            # bottom aligned: the letters' box one row lower than the digits'
        g = lambda v: int(round(255 * v / SOTN_GREY[2]))
        a[y0:, :] = (g(SOTN_GREY[0]),) * 3 + (255,)
        for y in range(rows):
            for x in range(w):
                if m[y][x] == 'x':
                    v = g(SOTN_GREY[1] if y < dark else SOTN_GREY[2])
                    a[y0 + 1 + y, 1 + x] = (v, v, v, 255)
        emit('O', ord(ch), a, 4)
    return dict(cell=SOTN_CELL, ink=7, kern=-1, space=3, k=4, chars=''.join(sorted(G)))


# ===================================================================================================================
# J: JFO (gen_dn_art.py's PCVR small glyphs: levelled, the font's inked rows, cropped sideways to the ink +-1)
def level(im):
    r, g, b, a = im.split()
    mx = max(c.getextrema()[1] for c in (r, g, b)) or 255
    lut = [min(255, int(round(v * 255.0 / mx))) for v in range(256)]
    return Image.merge('RGBA', (r.point(lut), g.point(lut), b.point(lut), a))


def ink_box(im):
    return im.getchannel('A').point(lambda v: 255 if v > 24 else 0).getbbox()


def crop_x(im):
    bb = ink_box(im)
    if not bb: return im
    return im.crop((max(0, bb[0] - 1), 0, min(im.width, bb[2] + 1), im.height))


def font_jfo():
    files = sorted(os.listdir(JFO))
    srcs = {int(f[5:8]): level(Image.open(os.path.join(JFO, f)).convert('RGBA')) for f in files}
    y0, y1 = 10 ** 6, -1
    for im in srcs.values():
        bb = ink_box(im)
        if bb: y0, y1 = min(y0, bb[1]), max(y1, bb[3])
    y0, y1 = max(0, y0 - 1) & ~1, min(32, y1 + 1)
    y1 += (y1 - y0) & 1
    G = {c: crop_x(im.crop((0, y0, im.width, y1))) for c, im in srcs.items()}
    # from its own I: ! (the stroke, a gap, a square), . (the square), , (the same), ' (the stroke's top third)
    I = G[ord('I')]; h = I.height; bb = ink_box(I); top, bot = bb[1], bb[3]; side = bb[2] - bb[0]
    def piece(a, b):
        out = Image.new('RGBA', I.size, (0, 0, 0, 0))
        out.alpha_composite(I.crop((0, a, I.width, b)), (0, a))
        return out
    cap = bot - top
    sq0 = bot - min(side, cap // 3)
    ex = piece(top, sq0 - max(3, cap // 6))
    ex.alpha_composite(piece(sq0, bot))
    G[ord('!')] = ex
    G[ord('.')] = piece(sq0, bot)
    G[ord(',')] = piece(sq0, bot)
    G[ord("'")] = piece(top, top + cap // 3)
    hb = ink_box(G[ord('H')]); ink = hb[3] - hb[1]
    for c, im in G.items():
        emit('J', c, np.array(im), 1)
    return dict(cell=y1 - y0, ink=ink, kern=0, space=(y1 - y0) // 3, k=1, chars=''.join(chr(c) for c in sorted(G)))


# ===================================================================================================================
# D: DOOM SMALL (the IWAD's STCFN033..095 by TEXTURES; sizes and top offsets as doom2.wad's, measured 11-16)
STCFN = {33: (4, 7, 0), 34: (7, 4, 0), 35: (7, 7, 0), 36: (7, 8, 0), 37: (9, 7, 0), 38: (8, 7, 0), 39: (4, 4, 0),
         40: (7, 7, 0), 41: (7, 7, 0), 42: (7, 7, 0), 43: (5, 5, -1), 44: (4, 4, -3), 45: (6, 3, -2), 46: (4, 3, -4),
         47: (7, 7, 0), 48: (8, 7, 0), 49: (5, 7, 0), 50: (8, 7, 0), 51: (8, 7, 0), 52: (7, 7, 0), 53: (7, 7, 0),
         54: (8, 7, 0), 55: (8, 7, 0), 56: (8, 7, 0), 57: (8, 7, 0), 58: (4, 7, 0), 59: (4, 7, 0), 60: (5, 7, 0),
         61: (5, 5, -1), 62: (5, 7, 0), 63: (8, 7, 0), 64: (9, 8, 0), 65: (8, 7, 0), 66: (8, 7, 0), 67: (8, 7, 0),
         68: (8, 7, 0), 69: (8, 7, 0), 70: (8, 7, 0), 71: (8, 7, 0), 72: (8, 7, 0), 73: (4, 7, 0), 74: (8, 7, 0),
         75: (8, 7, 0), 76: (8, 7, 0), 77: (9, 7, 0), 78: (8, 7, 0), 79: (8, 7, 0), 80: (8, 7, 0), 81: (8, 8, 0),
         82: (8, 7, 0), 83: (7, 7, 0), 84: (8, 7, 0), 85: (8, 7, 0), 86: (7, 7, 0), 87: (9, 7, 0), 88: (9, 7, 0),
         89: (8, 7, 0), 90: (7, 7, 0), 91: (5, 7, 0), 92: (7, 7, 0), 93: (5, 7, 0), 94: (7, 5, 0), 95: (8, 3, -4)}
DOOM_CELL = 8
DOOM_TRANS = '"176:190=[255,255,255]:[136,136,136]", "191:191=[20,20,20]:[20,20,20]", "45:47=[20,20,20]:[20,20,20]"'


def font_doom(L):
    sizes = {}
    for c, (w, h, to) in STCFN.items():
        L += ['Graphic "QWDW%03d", %d, %d' % (c, w, DOOM_CELL), '{', '\tOffset %d, %d' % (w // 2, DOOM_CELL // 2),
              '\tPatch "STCFN%03d", 0, %d' % (c, -to), '\t{', '\t\tTranslation %s' % DOOM_TRANS, '\t}', '}', '']
        sizes[c] = (w, DOOM_CELL)
    return sizes, dict(cell=DOOM_CELL, ink=7, kern=0, space=4, k=1)


# ===================================================================================================================
def halves(L, font, sizes, k):
    for c in sorted(sizes):
        w, h = sizes[c]
        t = (h // k // 2) * k                 # on a whole font row
        g = 'QW%sW%03d' % (font, c)
        L += ['Graphic "QW%sH%03d", %d, %d' % (font, c, w, t), '{', '\tPatch "%s", 0, 0' % g, '}',
              'Graphic "QW%sL%03d", %d, %d' % (font, c, w, h - t), '{', '\tPatch "%s", 0, %d' % (g, -t), '}',
              'Graphic "QW%sT%03d", %d, %d' % (font, c, w, h), '{', '\tOffset %d, %d' % (w // 2, h // 2),
              '\tPatch "QW%sH%03d", 0, 0' % (font, c), '}',
              'Graphic "QW%sB%03d", %d, %d' % (font, c, w, h), '{', '\tOffset %d, %d' % (w // 2, h // 2),
              '\tPatch "QW%sL%03d", 0, %d' % (font, c, t), '}', '']


def png_sizes(font):
    out = {}
    for f in os.listdir(OUT):
        if f.startswith('QW%sW' % font):
            out[int(f[4:7])] = Image.open(os.path.join(OUT, f)).size
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        os.remove(os.path.join(OUT, f))
    info = {'S': font_small(), 'O': font_sotn(), 'J': font_jfo()}
    L = ['// GENERATED by tools/gen_word_fonts.py -- do not hand-edit.',
         '// The Word Font choice (rsqvr/words.zs, rsqvr_wordfont): Doom small over the IWAD\'s own STCFN patches (QWDWnnn),',
         '// and the SOTN two-tone halves of Score Small (S), SOTN (O), JFO (J) and Doom small (D): QW<F>H / QW<F>L the halves,',
         '// QW<F>T / QW<F>B each half in a full-size cell with the glyph\'s own centre offset (as TEXTURES.rsqvrsotn for QVW).',
         '']
    dsz, info['D'] = font_doom(L)
    for f in 'SOJ':
        halves(L, f, png_sizes(f), info[f]['k'])
    halves(L, 'D', dsz, 1)
    open(TEX, 'w').write('\n'.join(L))
    n = len(os.listdir(OUT))
    for f, d in info.items():
        print('%s: cell %d font px, ink %d, kern %d, space %d, x%d %s' % (f, d['cell'], d['ink'], d['kern'], d['space'], d['k'],
                                                                         d.get('chars', '')))
    print('wrote %d PNGs in %s and %s' % (n, OUT, TEX))


if __name__ == '__main__':
    main()
