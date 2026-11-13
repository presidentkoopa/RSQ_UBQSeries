from PIL import Image, ImageDraw, ImageFilter
import glob, os, math
G = '/home/claude/rsq_ubqseries/Wheel/graphics/'
SPR = '/tmp/bdspr/sprites/WEAPONS/'
OUT = '/mnt/user-data/outputs/datacard_kiosk/'
os.makedirs(OUT, exist_ok=True)

def load_font(prefix, block):
    f = {}
    for p in glob.glob(G + prefix + '*.png'):
        c = int(os.path.basename(p)[len(prefix):-4])
        im = Image.open(p).convert('RGBA')
        im = im.resize((max(1, im.width // block), max(1, im.height // block)), Image.NEAREST)
        f[chr(c)] = im
    return f

BIG = load_font('WRVS', 4)    # RSQ Score font (the Wheel's default)
SML = load_font('WRCS', 6)    # RSQ Score's combo font

def tint(im, col):
    o = im.copy(); px = o.load()
    for y in range(o.height):
        for x in range(o.width):
            r, g, b, a = px[x, y]
            if a == 0: continue
            if r < 60: px[x, y] = (8, 6, 12, a)          # keep the dark outline
            else:
                k = r / 255.0
                px[x, y] = (int(col[0] * k), int(col[1] * k), int(col[2] * k), a)
    return o

_cache = {}
def glyph(font, ch, col):
    key = (id(font), ch, col)
    if key not in _cache:
        g = font.get(ch.upper()) or font.get('?')
        _cache[key] = tint(g, col)
    return _cache[key]

def tw(font, s, sc=1):
    w = 0
    for ch in s:
        if ch == ' ': w += (4 if font is SML else 4) * sc
        else:
            g = font.get(ch.upper()) or font.get('?')
            w += (g.width - (0 if font is SML else 1)) * sc
    return w

def text(img, font, s, x, y, col, sc=1, align='l'):
    if align == 'c': x -= tw(font, s, sc) // 2
    if align == 'r': x -= tw(font, s, sc)
    for ch in s:
        if ch == ' ':
            x += 4 * sc; continue
        g = glyph(font, ch, col)
        if sc != 1: g = g.resize((g.width * sc, g.height * sc), Image.NEAREST)
        img.alpha_composite(g, (int(x), int(y)))
        x += g.width - (0 if font is SML else sc)
    return x

def spr(path):
    p = glob.glob(SPR + '**/' + path, recursive=True)[0]
    im = Image.open(p).convert('RGBA')
    return im.crop(im.getbbox())

def panel(d, x, y, w, h, edge, fill, r=4):
    d.rounded_rectangle((x, y, x + w, y + h), r, fill=fill, outline=edge, width=1)

def glow(img, box, col, rad=6, a=110):
    x0, y0, x1, y1 = box
    lay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(lay).rounded_rectangle((x0, y0, x1, y1), 5, fill=col + (a,))
    lay = lay.filter(ImageFilter.GaussianBlur(rad))
    img.alpha_composite(lay)

RAR = {   # LegenDoom's own colours (rsld/data.zs:40-41); the floor tier is new: silver-white
    'FLOOR':    ((236, 236, 240), (150, 156, 170)),
    'COMMON':   ((90, 230, 90), (30, 110, 40)),
    'UNCOMMON': ((90, 150, 255), (30, 50, 140)),
    'RARE':     ((200, 110, 255), (80, 30, 130)),
    'EPIC':     ((255, 160, 40), (140, 70, 10)),
}
WHITE = (240, 240, 245); GREY = (150, 150, 165); GOLD = (255, 205, 40); CYAN = (90, 230, 230)
STAT = [(255, 90, 90), (255, 205, 40), (110, 230, 90), (255, 150, 70), (60, 210, 210), (255, 90, 160),
        (90, 170, 255), (210, 100, 255), (46, 210, 140), (255, 180, 60), (180, 192, 204), (255, 215, 80)]
