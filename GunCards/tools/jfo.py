#!/usr/bin/env python3
"""RSQ Gun Cards: the JFO glyphs (owner 2026-11-03: "our font", all card text). Source art in card_art/jfo/:
small/stcfnNNN.png (JFO's SmallFont, 32 px tall) and big/fontbNNN.png (JFO's BigFont digits, 64 px tall), copied
unchanged from JFO.pk3 (Hires/SmallFont, Hires/BigFont). JDUI font by Zedas, edit by Blackmore1014 (CREDITS.txt).

TEXT QUALITY (rsqgc_text_q): 0 Quest = every glyph at half resolution (LANCZOS, as the approved mockup mock5.py's
jh / bh), 1 PCVR = full resolution. The two are baked at the same size on the card: a half-resolution glyph pixel is
twice as big, so the card looks the same, with a quarter of the voxels.

A glyph is cropped to its drawn columns (mock5.py), its full cell height kept, so every glyph of a font stands on one
line. Glyphs drawn in a short cell (the 32 x 16 '-') are centred in the line; '.' and ',' sit on its foot."""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ART = os.path.join(HERE, 'card_art', 'jfo')

SMALL_CODES = [ord(c) for c in '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ+-=/:']
BIG_CODES = [ord(c) for c in '0123456789+']
NARROW_MAX = 20   # a full-resolution glyph this wide or less takes one grid unit, others two (JFO has the two widths)


def _load(kind, code):
    if kind == 'small': p = os.path.join(ART, 'small', 'stcfn%03d.png' % code)
    else: p = os.path.join(ART, 'big', 'fontb%03d.png' % code)
    return Image.open(p).convert('RGBA')


def glyph(kind, code, half):
    """(cell image, full-resolution width): the glyph cropped to its columns, in a cell of the font's full height
    (32 small, 64 big; halved for Quest)."""
    g = _load(kind, code)
    b = g.getbbox()
    if b: g = g.crop((b[0], 0, b[2], g.size[1]))
    full_w = g.size[0]
    H = 32 if kind == 'small' else 64
    cell = Image.new('RGBA', (g.size[0], H), (0, 0, 0, 0))
    if g.size[1] >= H: dy = 0
    elif code in (44, 46): dy = H - g.size[1]
    else: dy = (H - g.size[1]) // 2
    cell.alpha_composite(g.crop((0, 0, g.size[0], min(H, g.size[1]))), (0, dy))
    if half:
        cell = cell.resize((max(1, cell.size[0] // 2), H // 2), Image.LANCZOS)
    return cell, full_w


def units(kind, code):
    """grid units a glyph advances: 1 for JFO's narrow glyphs (I : !), 2 for the rest"""
    if kind == 'big': return 2
    return 1 if glyph(kind, code, False)[1] <= NARROW_MAX else 2


def word(text, half, gap_full=2):
    """a whole word in the small font, proportional (mock5.py: each glyph's width + 2 px at full resolution, + 1 at half)"""
    cells = [glyph('small', ord(c), half)[0] for c in text]
    gap = gap_full // 2 if half else gap_full
    w = sum(c.size[0] for c in cells) + gap * (len(cells) - 1)
    im = Image.new('RGBA', (w, cells[0].size[1]), (0, 0, 0, 0))
    x = 0
    for c in cells:
        im.alpha_composite(c, (x, 0)); x += c.size[0] + gap
    return im


def opaque(im, cut=100):
    """mock5.py draws a pixel at alpha >= 100: the same cut-out for the voxels"""
    px = im.load(); n = 0
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            if px[x, y][3] >= cut: n += 1
    return n
