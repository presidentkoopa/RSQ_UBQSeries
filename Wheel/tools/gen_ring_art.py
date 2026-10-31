#!/usr/bin/env python3
"""RSQ Wheel: the ring's own art, in Ermac's Force Unleashed style (owner 2026-10-31: the ring looked ugly
built from the status bar). Writes graphics/WREPLATE.png (a card: rounded panel, bright rim, mid fill),
graphics/WRESTONE.png (a bar), graphics/WREDIG0..9.png (Ermac's digits, from tools/card_art) and, between
markers, the WRE numeral cells in TEXTURES.txt and the "Ermac" font set in WRFONTS.txt.
The ring tints every plate by brightness into the card's colour (wr_q_shim.zs), so these are drawn in
grey: the rim bright, the fill mid, which comes out as Ermac's coloured panel with a light border.
wr_ring_art 1 brings the status-bar look back."""
import os
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(HERE)
G = os.path.join(W, 'graphics'); os.makedirs(G, exist_ok=True)
ART = os.path.join(HERE, 'card_art')

def plate(w, h, r, rim, fill_l, rim_l):
    im = Image.new('RGBA', (w * 4, h * 4), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, w * 4 - 1, h * 4 - 1), r * 4, fill=(rim_l,) * 3 + (255,))
    d.rounded_rectangle((rim * 4, rim * 4, w * 4 - 1 - rim * 4, h * 4 - 1 - rim * 4), max(1, r - rim) * 4, fill=(fill_l,) * 3 + (255,))
    return im.resize((w, h), Image.LANCZOS)

plate(128, 80, 10, 3, 92, 235).save(os.path.join(G, 'WREPLATE.png'))
bar = Image.new('RGBA', (64, 8), (200, 200, 200, 255)); ImageDraw.Draw(bar).line((0, 0, 63, 0), fill=(245, 245, 245, 255))
bar.save(os.path.join(G, 'WRESTONE.png'))
for i in range(10):
    Image.open(os.path.join(ART, 'digit_%d.png' % i)).convert('RGBA').save(os.path.join(G, 'WREDIG%d.png' % i))

def upsert(path, start, end, body):
    s = open(path).read() if os.path.exists(path) else ''
    if start in s:
        pre, rest = s.split(start, 1); post = rest.split(end, 1)[1]
    else:
        pre, post = s.rstrip('\n') + '\n\n', ''
    open(path, 'w').write(pre + start + '\n' + body + '\n' + end + post)

T = ['// Ermac digits for numbers, DoomFont for anything else a number shows (| - %), 12x12 cells']
for c in range(33, 96):
    ch = chr(c)
    if ch.isdigit(): T.append('Graphic "WRE%03d", 12, 12 { Patch "WREDIG%s", 0, 0 }' % (c, ch))
    else: T.append('Graphic "WRE%03d", 12, 12 { Patch "STCFN%03d", 2, 3 }' % (c, c))
T.append('Graphic "WREBLNK", 12, 12 { }')
upsert(os.path.join(W, 'TEXTURES.txt'), '// >>> WRERMAC (tools/gen_ring_art.py)', '// <<< WRERMAC', '\n'.join(T))
upsert(os.path.join(W, 'WRFONTS.txt'), '// >>> WRERMAC (tools/gen_ring_art.py)', '// <<< WRERMAC',
       'fontset Ermac      { words WRG 9 7   numbers WRE 12 12 }   // DoomFont words, Ermac\'s digits (the default)')
print('ok')
