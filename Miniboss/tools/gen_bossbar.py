#!/usr/bin/env python3
# RSQ Miniboss -- the miniboss bar's art, baked from the series' own art exactly as mockup "E - Arrival" was composed
# (owner 2026-11-12: the boss bar canvas, design/ in the session notes). Run from the repo root.
#   graphics/MBFG033..096  the score font (RSQ VisualRewards' QVW glyphs), gold, light at the top to deep at the foot
#   graphics/MBFS033..096  the same, silver (GUARD)
#   graphics/RSQMBHD       the head: the crowned skull with the red crosshair over it (150 x 150)
#   graphics/RSQMBX01..10  RSQ SlowMo's DOWN crosshairs (frame 16), cropped square, white (tinted at run time)
from PIL import Image
G = 'VisualRewards/pk3/graphics/rsqvrw/'; M = 'Miniboss/graphics/'; S = 'SlowMo/graphics/rsqsmp/'

def grad(g, top, bot):
    g = g.convert('RGBA'); px = g.load()
    for y in range(g.size[1]):
        t = y / max(1, g.size[1] - 1); col = [int(top[k] * (1 - t) + bot[k] * t) for k in range(3)]
        for x in range(g.size[0]):
            r, gg, b, a = px[x, y]
            if a == 0: continue
            l = max(r, gg, b) / 255.0
            px[x, y] = (int(col[0] * l), int(col[1] * l), int(col[2] * l), a) if l > 0.25 else (12, 10, 8, a)
    return g

def tint(im, rgb, a=1.0):
    im = im.convert('RGBA'); px = im.load()
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            r, g, b, al = px[x, y]; l = max(r, g, b) / 255.0
            px[x, y] = (int(rgb[0] * l), int(rgb[1] * l), int(rgb[2] * l), int(al * a))
    return im

for c in range(33, 97):
    g = Image.open(G + 'QVW%03d.png' % c).convert('RGBA')
    b = g.getbbox()
    if not b: continue
    g = g.crop((b[0], 0, b[2], g.size[1]))
    grad(g, (255, 236, 120), (240, 150, 20)).save(M + 'MBFG%03d.png' % c)
    grad(g, (210, 210, 215), (120, 120, 130)).save(M + 'MBFS%03d.png' % c)

skull = Image.open(M + 'RSQMBSK1.png').convert('RGBA')
hd = Image.new('RGBA', (150, 150), (0, 0, 0, 0))
hd.alpha_composite(skull.resize((skull.size[0] * 6, skull.size[1] * 6), Image.NEAREST), (27, 30))
r = Image.open(S + 'RSPA0216.png').convert('RGBA')
hd.alpha_composite(tint(r.crop(r.getbbox()), (255, 70, 50), 0.85).resize((150, 150), Image.LANCZOS), (0, 0))
hd.save(M + 'RSQMBHD.png')

for n in range(1, 11):
    src = Image.open(S + 'RSPA%02d16.png' % n).convert('RGBA'); src = src.crop(src.getbbox())
    m = max(src.size); sq = Image.new('RGBA', (m, m), (0, 0, 0, 0))
    sq.alpha_composite(src, ((m - src.size[0]) // 2, (m - src.size[1]) // 2))
    sq = tint(sq, (255, 255, 255)).resize((64, 64), Image.LANCZOS)
    o = Image.new('RGBA', sq.size, (0, 0, 0, 0)); o.alpha_composite(sq); o.alpha_composite(sq)
    o.save(M + 'RSQMBX%02d.png' % n)
print('ok')
