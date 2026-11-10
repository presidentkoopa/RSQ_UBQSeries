# SOTN-style words in the series' QVW font (owner 11-10): smeared in, snap upright, flash between two looks,
# each look two-toned top / bottom. Three styles side by side, three words each. Animated GIF.
import os
from PIL import Image, ImageDraw
V = '/home/claude/rsq_ubqseries/VisualRewards/pk3/graphics/rsqvrw/'
OUT = os.path.dirname(os.path.abspath(__file__))
def glyph(c):
    p = V + 'QVW%03d.png' % ord(c)
    return Image.open(p).convert('RGBA') if os.path.exists(p) else None
def mask(txt, h):
    gs = [glyph(c) for c in txt]
    sc = [g.resize((max(1, int(g.width * h / g.height)), h), Image.NEAREST) if g else None for g in gs]
    w = sum((g.width if g else h // 2) + 2 for g in sc)
    m = Image.new('L', (w, h), 0); x = 0
    for g in sc:
        if g:
            r, gg, b, a = g.split(); lum = Image.merge('RGB', (r, gg, b)).convert('L')
            m.paste(lum.point(lambda v: v if v > 75 else 0), (x, 0), a); x += g.width + 2
        else: x += h // 2 + 2
    return m
def paint(m, top, bot, bands=2):
    w, h = m.size; im = Image.new('RGBA', (w, h), (0, 0, 0, 0)); px = im.load(); mp = m.load()
    for y in range(h):
        t = y / max(1, h - 1)
        if bands == 2: c = top if t < 0.5 else bot
        else:  # three bands: top, mix, bottom
            c = top if t < 0.34 else (tuple((a + b) // 2 for a, b in zip(top, bot)) if t < 0.67 else bot)
        for x in range(w):
            if mp[x, y]:
                k = 0.55 + 0.45 * mp[x, y] / 255.0
                px[x, y] = tuple(min(255, int(v * k * 1.15)) for v in c) + (255,)
    return im
def boxed(im, pad=3, col=(8, 8, 10)):
    # SOTN's dark box: the word's own shape grown by pad, in near-black
    w, h = im.size; out = Image.new('RGBA', (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    a = im.split()[3]
    for dx in range(-pad, pad + 1):
        for dy in range(-pad, pad + 1):
            out.paste(Image.new('RGBA', im.size, col + (255,)), (pad + dx, pad + dy), a)
    out.alpha_composite(im, (pad, pad)); return out
def smear(im, k):
    # k 1 -> 0: stretched wide and slanted forward, then upright
    w, h = im.size; sx = 1 + 0.3 * k
    im2 = im.resize((int(w * sx), h), Image.NEAREST)
    sh = 0.45 * k
    return im2.transform((int(im2.width + h * sh), h), Image.AFFINE, (1, sh, -h * sh, 0, 1, 0), Image.NEAREST)
WORDS = [('GUARD!', [((96, 100, 112), (240, 242, 248)), ((150, 190, 255), (235, 245, 255))]),
         ('TARGET!', [((30, 140, 40), (160, 255, 90)), ((120, 255, 120), (230, 255, 160))]),
         ('102', [((255, 80, 90), (255, 140, 140)), ((240, 150, 20), (255, 236, 120))])]
STYLES = [('A  SOTN', dict(bands=2, box=3, smear=4, flash=4)),
          ('B  SOFTER', dict(bands=3, box=2, smear=6, flash=6)),
          ('C  PUNCHY', dict(bands=2, box=4, smear=3, flash=2))]
H = 48; CW, CH = 420, 120; N = 48
frames = []
for f in range(N):
    sheet = Image.new('RGBA', (CW * 3, CH * 3 + 26), (22, 20, 28, 255)); d = ImageDraw.Draw(sheet)
    for si, (sname, st) in enumerate(STYLES):
        lab = boxed(paint(mask(sname, 12), (200, 200, 210), (200, 200, 210)), 1)
        sheet.alpha_composite(lab, (si * CW + 10, 6))
        for wi, (word, pairs) in enumerate(WORDS):
            m = mask(word, H)
            age = f - wi * 3
            if age < 0: continue
            k = max(0.0, 1 - age / st['smear'])
            look = pairs[(age // st['flash']) % 2] if age >= st['smear'] else pairs[0]
            im = boxed(paint(m, look[0], look[1], st['bands']), st['box'])
            if k > 0: im = smear(im, k)
            rise = min(age, 40) * 0.6
            fade = 1.0 if age < 36 else max(0.0, 1 - (age - 36) / 10)
            if fade < 1: im.putalpha(im.split()[3].point(lambda v: int(v * fade)))
            x = si * CW + (CW - im.width) // 2; y = 26 + wi * CH + 40 - int(rise)
            sheet.alpha_composite(im, (x, y))
    frames.append(sheet.convert('RGB').resize((CW * 3 * 2 // 2, (CH * 3 + 26)), Image.NEAREST))
frames[0].save(os.path.join(OUT, 'sotn_words.gif'), save_all=True, append_images=frames[1:], duration=50, loop=0)
frames[20].save(os.path.join(OUT, 'sotn_words_frame.png'))
print('ok')
