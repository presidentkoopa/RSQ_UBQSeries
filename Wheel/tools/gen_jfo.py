#!/usr/bin/env python3
"""RSQ Wheel: the JFO font (owner 2026-11-06: "the nice font", item 14 of BUGS_1.0.md). JFO is the JDUI font by
Zedas, in Blackmore1014's edit "JDUI Brutal Doom Ultimate Edition": the same glyph files RSQ Gun Cards and RSQ
VisualRewards ship (GunCards/tools/card_art/jfo, copied unchanged from JFO.pk3's Hires/SmallFont/stcfnNNN.png and
Hires/BigFont/fontbNNN.png), with the same credit (CREDITS.txt).

Writes graphics/WRJSnnn.png (small font) and graphics/WRJBnnn.png (big digits), and between markers the "JFO" font
set in WRFONTS.txt and its cells in TEXTURES.txt.

WORDS ARE PROPORTIONAL, ON A HALF-CELL GRID (as Gun Cards lays JFO out: a glyph 2 units, a narrow one 1, a space 1).
A half cell is 17 x 32: a JFO glyph (32 wide) takes two halves, <pfx><code>a and <pfx><code>b, with a pixel of air
each side; a narrow one (I and :, 16 wide) takes one. The ring counts the halves a character has from which of
<pfx><code>a / b / c exist (wr_q_shim.zs buildText), so nothing here is repeated in code.
JFO carries 41 glyphs (0-9 A-Z + - / : =). Anything else a name holds (. , ( ) ' ! ? % & ...) is the IWAD's own
DoomFont glyph scaled to the same cap height (a DoomFont pixel is about a quarter of a half cell), so no character
is lost. Numbers use JFO's big digits; - and % in a number are the small font's '-' and DoomFont's '%'."""
import os, shutil
HERE = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(HERE)
G = os.path.join(W, 'graphics')
SRC = os.path.join(os.path.dirname(W), 'GunCards', 'tools', 'card_art', 'jfo')
from PIL import Image

small, big = {}, {}
for f in sorted(os.listdir(os.path.join(SRC, 'small'))):
    c = int(f[5:8]); small[c] = Image.open(os.path.join(SRC, 'small', f)).size
    shutil.copyfile(os.path.join(SRC, 'small', f), os.path.join(G, 'WRJS%03d.png' % c))
for f in sorted(os.listdir(os.path.join(SRC, 'big'))):
    c = int(f[5:8]); big[c] = Image.open(os.path.join(SRC, 'big', f)).size
    shutil.copyfile(os.path.join(SRC, 'big', f), os.path.join(G, 'WRJBnnn.png'.replace('nnn', '%03d' % c)))

# DoomFont widths (Freedoom's; Doom 2's within a pixel: tools/gen_assets.py)
DW = {'!': 4, '"': 7, '#': 9, '$': 7, '%': 9, '&': 8, "'": 4, '(': 6, ')': 6, '*': 8, '+': 7,
      ',': 4, '-': 7, '.': 4, '/': 7, ';': 4, '<': 6, '=': 7, '>': 6, '?': 7, '@': 9,
      '[': 6, '\\': 7, ']': 6, '^': 7, '_': 7}
HX, HY = 17, 32           # a half cell
T = ['// The JFO font set (tools/gen_jfo.py). Words: half cells 17x32 (a = left, b = right, c = third). Numbers: 64x64.',
     'Graphic "WRJBLNK", 17, 32 { }']
for c in range(33, 96):
    ch = chr(c)
    if c in small:
        w, h = small[c]
        dy = (HY - h) // 2 if h < HY else 0
        if w <= 16:
            T.append('Graphic "WRJ%03da", %d, %d { Patch "WRJS%03d", 1, %d }' % (c, HX, HY, c, dy))
        else:
            T.append('Graphic "WRJ%03da", %d, %d { Patch "WRJS%03d", 1, %d }' % (c, HX, HY, c, dy))
            T.append('Graphic "WRJ%03db", %d, %d { Patch "WRJS%03d", %d, %d }' % (c, HX, HY, c, 1 - HX, dy))
    else:
        # DoomFont at JFO's cap height: a half cell is 4 x 7 DoomFont pixels (aspect 0.57 against 17 / 32 = 0.53)
        w = DW.get(ch, 7)
        n = max(1, -(-w // 4))
        x0 = (n * 4 - w) // 2
        for k in range(n):
            T.append('Graphic "WRJ%03d%s", 4, 7 { Patch "STCFN%03d", %d, 0 }' % (c, 'abc'[k], c, x0 - 4 * k))
T.append('Graphic "WRKBLNK", 64, 64 { }')
for c in range(33, 96):
    if c in big: T.append('Graphic "WRK%03d", 64, 64 { Patch "WRJB%03d", 0, 0 }' % (c, c))
    elif c == 45: T.append('Graphic "WRK045", 32, 32 { Patch "WRJS045", 0, 8 }')
    else: T.append('Graphic "WRK%03d", 12, 12 { Patch "STCFN%03d", 2, 3 }' % (c, c))


def upsert(path, start, end, body):
    s = open(path).read() if os.path.exists(path) else ''
    if start in s:
        pre, rest = s.split(start, 1); post = rest.split(end, 1)[1]
    else:
        pre, post = s.rstrip('\n') + '\n\n', '\n'
    open(path, 'w').write(pre + start + '\n' + body + '\n' + end + post)


upsert(os.path.join(W, 'TEXTURES.txt'), '// >>> WRJFO (tools/gen_jfo.py)', '// <<< WRJFO', '\n'.join(T))
upsert(os.path.join(W, 'WRFONTS.txt'), '// >>> WRJFO (tools/gen_jfo.py)', '// <<< WRJFO',
       'fontset JFO        { halves WRJ 17 32   numbers WRK 1 1 }   // JFO words (proportional, half cells), JFO big digits (the default)')
print('ok: %d small, %d big' % (len(small), len(big)))
