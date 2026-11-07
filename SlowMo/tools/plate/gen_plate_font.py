#!/usr/bin/env python3
"""RSQ SlowMo -- the DOWN plate's two fonts (owner 2026-11-07 06:36 / 06:40 / 06:4x, design/NEAR_DEATH.md v3 "targets on
the plate, the bar reset, the plate's font").

  RSQ Score's combo font (RSSCFN2, the font Score's breakdown -- its combos -- is drawn in) when Score is loaded, else JFO.
  SlowMo loads alone, so it carries both:

  graphics/rsqsmp/RSPCnnn.png  RSSCFN2's letters (chars 32..96: capitals, digits, punctuation), unpacked from
                               Score/RSSCFN2.fon2 (the FON2 format: the engine's own reader, FSingleLumpFont::LoadFON2:
                               header, widths, palette, packbits rows). White, brightness = the letter's brightness scaled
                               to full, alpha where the font has a pixel: the plate draws them Shaded in its colours,
                               as a font colour paints a font by brightness.
  graphics/rsqsmp/RSPJnnn.png  JFO's letters (its SmallFont: 0-9 A-Z + - / : =), copied unchanged from
                               GunCards/tools/card_art/jfo/small (JFO.pk3's Hires/SmallFont/stcfnNNN.png), as the RSQ Wheel
                               ships them (Wheel/tools/gen_jfo.py).
  TEXTURES.txt (RSPJFILL)      JFO's gaps (! . , ' ( ) ? ...) filled with the IWAD's own DoomFont letters (STCFNnnn, by lump
                               name), exactly as the Wheel does: a DoomFont letter scaled to JFO's cell height, its width
                               from the Wheel's table of DoomFont widths.
  zscript/rsqsm/platefont.zs   the metrics both fonts are laid out with (texture, advance, size, in pixels of that font).

Credits: CREDITS.txt (RSSCFN2: Jimmy, via ijon's Dakka; JFO: Zedas, Blackmore1014's edit).
Run from anywhere: python3 SlowMo/tools/plate/gen_plate_font.py"""
import os, shutil, struct
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MOD = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(MOD)
G = os.path.join(MOD, 'graphics', 'rsqsmp')
FON = os.path.join(REPO, 'Score', 'RSSCFN2.fon2')
JFO = os.path.join(REPO, 'GunCards', 'tools', 'card_art', 'jfo', 'small')
LO, HI = 32, 95            # the plate draws capitals (its text is made upper case)


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
        p = 14       # a kerning value (not used here: the plate spaces by the widths)
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
    return height, first, last, widths, pal, glyphs


def write_fon2_letters():
    height, first, last, widths, pal, glyphs = load_fon2(FON)
    lum = [0.299 * r + 0.587 * g + 0.114 * b for (r, g, b) in pal]
    top = max(lum[1:]) if len(lum) > 1 else 255
    metrics = {}
    for c in range(LO, HI + 1):
        if c < first or c > last:
            continue
        w = widths[c - first]
        metrics[c] = (w, w, height)
        if c not in glyphs or c == 32:
            continue
        gw, px = glyphs[c]
        im = Image.new('RGBA', (gw, height), (255, 255, 255, 0))
        for y in range(height):
            for x in range(gw):
                k = px[y * gw + x]
                if k == 0:
                    continue
                v = int(round(255 * min(1.0, lum[k] / top)))
                im.putpixel((x, y), (v, v, v, 255))
        im.save(os.path.join(G, 'RSPC%03d.png' % c))
    return height, metrics


# DoomFont widths (Freedoom's; Doom 2's within a pixel): the RSQ Wheel's table (Wheel/tools/gen_jfo.py)
DW = {'!': 4, '"': 7, '#': 9, '$': 7, '%': 9, '&': 8, "'": 4, '(': 6, ')': 6, '*': 8, '+': 7,
      ',': 4, '-': 7, '.': 4, '/': 7, ';': 4, '<': 6, '=': 7, '>': 6, '?': 7, '@': 9,
      '[': 6, '\\': 7, ']': 6, '^': 7, '_': 7}


def write_jfo_letters():
    # the Wheel's grid: a JFO cell 32 high, a glyph 32 wide (I and : 16) with a pixel of air each side; a space a half cell
    # (17); a DoomFont letter fills 4 x 7 DoomFont pixels per 17 x 32 half cell
    CH = 32
    metrics, fills = {}, []
    have = {}
    for f in sorted(os.listdir(JFO)):
        c = int(f[5:8]); have[c] = Image.open(os.path.join(JFO, f)).size
        shutil.copyfile(os.path.join(JFO, f), os.path.join(G, 'RSPJ%03d.png' % c))
    for c in range(LO, HI + 1):
        if c == 32:
            metrics[c] = (17, 17, CH); continue
        if c in have:
            w, h = have[c]
            metrics[c] = (w + 2, w, h)
        else:
            dw = DW.get(chr(c), 7)
            fills.append('Graphic "RSPJ%03d", %d, 7 { Patch "STCFN%03d", 0, 0 }' % (c, dw, c))
            gw = dw * 17.0 / 4.0
            metrics[c] = (gw + 2, gw, CH)
    return CH, metrics, fills


def upsert(path, start, end, body):
    s = open(path).read() if os.path.exists(path) else ''
    if start in s:
        pre, rest = s.split(start, 1); post = rest.split(end, 1)[1]
    else:
        pre, post = s.rstrip('\n') + '\n\n', '\n'
    open(path, 'w').write(pre + start + '\n' + body + '\n' + end + post)


def main():
    os.makedirs(G, exist_ok=True)
    ch, cm = write_fon2_letters()
    jh, jm, fills = write_jfo_letters()
    upsert(os.path.join(MOD, 'TEXTURES.txt'), '// >>> RSPJFILL (tools/plate/gen_plate_font.py)', '// <<< RSPJFILL',
           '// JFO\'s gaps on the plate: the IWAD\'s DoomFont letters, as the RSQ Wheel fills them (its gen_jfo.py)\n' + '\n'.join(fills))
    def arr(m, k, fmt):
        return ', '.join(fmt % (m[c][k] if c in m else 0) for c in range(LO, HI + 1))
    zs = ['// RSQ SlowMo -- the DOWN plate\'s font metrics. GENERATED by tools/plate/gen_plate_font.py: do not edit.',
          '// Per character %d..%d: advance, glyph width, glyph height, in pixels of that font; its cap (cell) height.' % (LO, HI),
          '// score = RSQ Score\'s combo font (RSSCFN2, textures RSPCnnn), else JFO (RSPJnnn, DoomFont in its gaps).',
          '// (The tables are local to each function: a class-level static const array is not found from a static function.)',
          'class RSQSM_PlateFont play',
          '{',
          '\tconst LO = %d;' % LO,
          '\tconst HI = %d;' % HI,
          '\tstatic clearscope double Cap(bool score) { return score ? %d : %d; }' % (ch, jh)]
    for fn, k in (('Adv', 0), ('Wid', 1), ('Hgt', 2)):
        zs += ['\tstatic clearscope double %s(bool score, int c)' % fn, '\t{',
               '\t\tstatic const double CT[] = { %s };' % arr(cm, k, '%g'),
               '\t\tstatic const double JT[] = { %s };' % arr(jm, k, '%g'),
               '\t\tif (c < %d || c > %d) return 0;' % (LO, HI),
               '\t\treturn score ? CT[c - %d] : JT[c - %d];' % (LO, LO), '\t}']
    zs += ['}', '']
    open(os.path.join(MOD, 'zscript', 'rsqsm', 'platefont.zs'), 'w').write('\n'.join(zs))
    print('ok: RSSCFN2 %d letters (height %d), JFO %d letters + %d DoomFont fills' %
          (sum(1 for c in cm if c != 32), ch, len(jm) - len(fills) - 1, len(fills)))


if __name__ == '__main__':
    main()
