# Training remote wrist panel, 3 layouts (owner 11-10: off wrist like Score; hit pips, streak, round, :30 timer).
# Glyphs float with no backing (QZD 17.3 draws a canvas black in VR, so like Score's wrist each glyph is a billboard).
# Fonts: VisualRewards' QVW word glyphs, JFO big digits for the timer.
import os
from PIL import Image, ImageDraw, ImageFilter
R = '/home/claude/rsq_ubqseries/VisualRewards/'
OUT = os.path.dirname(os.path.abspath(__file__))
GOLD = (255, 208, 64); BLUE = (90, 170, 255); DIM = (70, 70, 90); RED = (255, 70, 50)

def qvw(ch):
    p = R + 'pk3/graphics/rsqvrw/QVW%03d.png' % ord(ch)
    return Image.open(p).convert('RGBA') if os.path.exists(p) else None
def jfo(ch):
    p = R + 'tools/dn_art/jfo_big/fontb%03d.png' % ord(ch)
    return Image.open(p).convert('RGBA') if os.path.exists(p) else qvw(ch)

def tint(g, c):
    r, gg, b, a = g.split(); l = Image.merge('RGB', (r, gg, b)).convert('L')
    return Image.merge('RGBA', [l.point(lambda v, k=k: int(v * c[k] / 255)) for k in range(3)] + [a])

def word(txt, src, h, c, gap=2):
    out = []
    for ch in txt:
        g = src(ch)
        if g is None: out.append(None); continue
        s = h / g.height; out.append(tint(g.resize((max(1, int(g.width * s)), h), Image.NEAREST), c))
    w = sum((g.width if g else h // 2) + gap for g in out)
    im = Image.new('RGBA', (max(1, w), h), (0, 0, 0, 0)); x = 0
    for g in out:
        if g: im.alpha_composite(g, (x, 0)); x += g.width + gap
        else: x += h // 2 + gap
    return im

def pips(n_hit, size, gap, horizontal=True):
    w = 4 * size + 3 * gap
    im = Image.new('RGBA', (w, size) if horizontal else (size, w), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    for i in range(4):
        o = i * (size + gap); box = [o, 0, o + size - 1, size - 1] if horizontal else [0, o, size - 1, o + size - 1]
        cx, cy = (box[0] + box[2]) / 2, (box[1] + box[3]) / 2; r = size / 2 - 1
        poly = [(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)]
        if i < n_hit: d.polygon(poly, fill=RED + (255,))
        else: d.polygon(poly, outline=DIM + (255,), width=2)
    return im

def glow(layer):
    g = layer.filter(ImageFilter.GaussianBlur(6)); out = Image.new('RGBA', layer.size, (0, 0, 0, 0))
    out.alpha_composite(g); out.alpha_composite(g); out.alpha_composite(layer); return out

def scene(title, build, sub):
    W, H = 560, 520
    bg = Image.new('RGBA', (W, H), (0, 0, 0, 255)); d = ImageDraw.Draw(bg)
    for y in range(H): d.line([(0, y), (W, y)], fill=(16 + y // 40, 14 + y // 50, 22 + y // 30, 255))
    # the off-hand controller, seen from above-behind, as on the watch check
    d.rounded_rectangle([215, 330, 345, 500], radius=40, fill=(38, 38, 44, 255), outline=(90, 90, 100, 255), width=2)
    d.ellipse([200, 300, 360, 380], outline=(110, 110, 120, 255), width=6)
    d.ellipse([255, 345, 285, 375], fill=(60, 60, 70, 255)); d.ellipse([290, 360, 312, 382], fill=(60, 60, 70, 255))
    layer = Image.new('RGBA', (W, H), (0, 0, 0, 0)); build(layer)
    bg.alpha_composite(glow(layer))
    bg.alpha_composite(word(title, qvw, 22, (230, 230, 240)), (14, 12))
    y = 44
    for line in sub:
        bg.alpha_composite(word(line, qvw, 12, (150, 150, 170), gap=1), (14, y)); y += 17
    return bg

def centre(layer, im, cx, y): layer.alpha_composite(im, (int(cx - im.width / 2), y))

# A: one line across the wrist, like Score's digits
def A(L):
    row = [word('R3', qvw, 26, BLUE), pips(2, 22, 6), word('X4', qvw, 26, GOLD), word(':27', jfo, 30, GOLD)]
    w = sum(i.width for i in row) + 18 * 3; x = 280 - w // 2
    for i in row: L.alpha_composite(i, (x, 230 + (30 - i.height) // 2)); x += i.width + 18

# B: stacked, the timer big on top
def B(L):
    centre(L, word(':27', jfo, 64, GOLD), 280, 130)
    centre(L, pips(2, 26, 10), 280, 206)
    r = word('R3', qvw, 22, BLUE); s = word('X4', qvw, 22, GOLD)
    L.alpha_composite(r, (280 - 20 - r.width, 248)); L.alpha_composite(s, (280 + 20, 248))

# C: the four pips round the timer, round and streak either side
def C(L):
    cx, cy = 280, 200
    t = word(':27', jfo, 52, GOLD); L.alpha_composite(t, (cx - t.width // 2, cy - 26))
    for i, (dx, dy) in enumerate([(0, -58), (88, 0), (0, 58), (-88, 0)]):
        p = pips(1 if i < 2 else 0, 24, 0); p = p.crop((0, 0, 24, 24))
        L.alpha_composite(p, (cx + dx - 12, cy + dy - 12))
    r = word('R3', qvw, 22, BLUE); s = word('X4', qvw, 22, GOLD)
    L.alpha_composite(r, (cx - 130 - r.width, cy - 11)); L.alpha_composite(s, (cx + 130, cy - 11))

opts = [('A  ONE LINE', A, ['ROUND, HIT PIPS, STREAK, TIMER IN ONE ROW', 'LIKE SCORE ON THE WRIST']),
        ('B  STACKED', B, ['TIMER BIG ON TOP', 'PIPS UNDER IT, ROUND AND STREAK BELOW']),
        ('C  RING', C, ['FOUR PIPS ROUND THE TIMER', 'ROUND LEFT, STREAK RIGHT'])]
sheet = Image.new('RGBA', (560 * 3 + 40, 520 + 20), (8, 8, 12, 255))
for i, (t, f, sub) in enumerate(opts):
    im = scene(t, f, sub); im.convert('RGB').save(os.path.join(OUT, 'panel_%s.png' % 'ABC'[i]))
    sheet.alpha_composite(im, (10 + i * 570, 10))
sheet.convert('RGB').save(os.path.join(OUT, 'panel_options.png'))
print('ok')
