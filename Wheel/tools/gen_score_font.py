#!/usr/bin/env python3
"""RSQ Wheel: RSQ Score's fonts as Wheel font sets (owner 2026-11-09 11:26: "my weapon wheel is unreadable, why? we have
all these fonts to pick from").

WHY: JFO's small glyphs (tools/gen_jfo.py) are 32 px stone letters whose ink fills most of the cell, with counters
1-3 px wide and a grey bevel. In the headset the ring's words are 5-10 screen pixels tall, so the engine draws the
cells from their small mipmaps, where a 32 px JFO letter is averaged down to a few pixels and its counters vanish:
every letter becomes a solid slab (the owner's 11-09 headset screenshot). RSQ Score's own font (RSSCFON, the font
"SCORE:" is drawn in, which read in the same screenshot) is a 12-row block font with 2 px strokes and 2 px gaps and
a dark outline: built for being read small.

Writes, from Score/RSSCFON.fon2 and Score/RSSCFN2.fon2 (unpacked with gen_web_digits.load_fon2, the engine's FON2
format), between markers in TEXTURES.txt and WRFONTS.txt:

  fontset Score  words in RSSCFON (the "SCORE:" font) in half cells WRVnnn[a|b] 8 x 12 font pixels,
                 numbers in its digits, cells WRUnnn 12 x 12            (the default from 11-09)
  fontset Combo  words in RSSCFN2 (Score's combo/breakdown font), half cells WRCnnn[a|b] 4 x 7,
                 numbers WRHnnn 7 x 7

graphics/WRVSnnn.png / WRCSnnn.png: one glyph each, scaled up SCALE x nearest-neighbour (so a close look does not blur
the pixels; far away the engine's mipmaps average whole font pixels). Colours as Score draws them (TEXTCOLO
RSScore_White: the font's darkest colour, its outline, dark; the rest 192-255), with the outline darker still
(16) so it stays dark after the ring's colour ramp (wr_BB.TransFor lifts dark greys toward the colour).

Words are proportional on a half-cell grid, as JFO's (wr_BB.buildHalves): a glyph takes as many halves as its width
needs, centred in them (Score: half cells 8 px, so A-Z and M N W take two and I . : one, and letters keep a pixel of
air between them, which a blurred far view needs); a space is one blank half.
Credits: CREDITS.txt (via ijon's Dakka, as RSQ Score carries them: RSSCFON by Blue Shadow, RSSCFN2 by Jimmy).
Run from anywhere: python3 Wheel/tools/gen_score_font.py"""
import os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
W = os.path.dirname(HERE)
REPO = os.path.dirname(W)
G = os.path.join(W, 'graphics')
sys.path.insert(0, HERE)
from gen_web_digits import load_fon2  # noqa: E402

OUTLINE = 16

# name, fon2, glyph png prefix, half-cell prefix, half width (font px), numbers prefix, number cell width, scale
SETS = [
    ('Score', 'RSSCFON', 'WRVS', 'WRV', 8, 'WRU', 12, 4,
     'RSQ Score\'s "SCORE:" font (RSSCFON), proportional; its digits (the default)'),
    ('Combo', 'RSSCFN2', 'WRCS', 'WRC', 4, 'WRH', 7, 6,
     'RSQ Score\'s combo font (RSSCFN2), proportional; its digits'),
]


def glyph_png(path, w, h, px, pal, scale):
    lum = [0.299 * r + 0.587 * g + 0.114 * b for (r, g, b) in pal]
    used = sorted(set(k for k in px if k))
    dark = min(used, key=lambda k: lum[k])
    rest = [k for k in used if k != dark] or [dark]
    lo, hi = min(lum[k] for k in rest), max(lum[k] for k in rest)
    im = Image.new('RGBA', (w, h), (255, 255, 255, 0))
    for y in range(h):
        for x in range(w):
            k = px[y * w + x]
            if not k:
                continue
            if k == dark and len(used) > 1:
                v = OUTLINE
            else:
                v = int(round(192 + 63 * ((lum[k] - lo) / (hi - lo) if hi > lo else 1.0)))
            im.putpixel((x, y), (v, v, v, 255))
    im.resize((w * scale, h * scale), Image.NEAREST).save(path)


def build(name, fon, gpfx, hpfx, hw, npfx, nw, scale, note):
    height, pal, glyphs = load_fon2(os.path.join(REPO, 'Score', fon + '.fon2'))
    H, S = height, scale
    T = ['// The %s font set (tools/gen_score_font.py, from Score/%s.fon2, x%d). Words: half cells %d x %d font px'
         ' (a = left, b, c). Numbers: %d x %d.' % (name, fon, S, hw, H, nw, H),
         'Graphic "%sBLNK", %d, %d { }' % (hpfx, hw * S, H * S)]
    for c in range(33, 96):
        if c not in glyphs:
            continue
        gw, px = glyphs[c]
        glyph_png(os.path.join(G, '%s%03d.png' % (gpfx, c)), gw, H, px, pal, S)
        n = max(1, -(-gw // hw))
        assert n <= 3, (name, chr(c), gw)
        x0 = (n * hw - gw) // 2
        for k in range(n):
            T.append('Graphic "%s%03d%s", %d, %d { Patch "%s%03d", %d, 0 }'
                     % (hpfx, c, 'abc'[k], hw * S, H * S, gpfx, c, (x0 - hw * k) * S))
    T.append('Graphic "%sBLNK", %d, %d { }' % (npfx, nw * S, H * S))
    for c in range(33, 96):
        if c in glyphs:
            gw = glyphs[c][0]
            T.append('Graphic "%s%03d", %d, %d { Patch "%s%03d", %d, 0 }'
                     % (npfx, c, nw * S, H * S, gpfx, c, ((nw - gw) // 2) * S))
    f = 'fontset %-10s { halves %s %d %d   numbers %s %d %d }   // %s' % (name, hpfx, hw, H, npfx, nw, H, note)
    return T, f


def upsert(path, start, end, body):
    s = open(path).read() if os.path.exists(path) else ''
    if start in s:
        pre, rest = s.split(start, 1); post = rest.split(end, 1)[1]
    else:
        pre, post = s.rstrip('\n') + '\n\n', '\n'
    open(path, 'w').write(pre + start + '\n' + body + '\n' + end + post)


def main():
    tex, fonts = [], []
    for s in SETS:
        T, f = build(*s)
        tex += T; fonts.append(f)
    upsert(os.path.join(W, 'TEXTURES.txt'), '// >>> WRSCORE (tools/gen_score_font.py)', '// <<< WRSCORE', '\n'.join(tex))
    upsert(os.path.join(W, 'WRFONTS.txt'), '// >>> WRSCORE (tools/gen_score_font.py)', '// <<< WRSCORE', '\n'.join(fonts))
    print('ok: %d TEXTURES lines; %s' % (len(tex), ', '.join(s[0] for s in SETS)))


if __name__ == '__main__':
    main()
