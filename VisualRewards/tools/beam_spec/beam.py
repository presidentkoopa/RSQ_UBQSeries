# Arrival-beam mockups. All art is drawn on a map-unit grid (1 texel = 1 map unit) and shown at U display px per unit.
import math, random, glob, os
SPEC = __import__('os').path.dirname(__import__('os').path.abspath(__file__))   # was /tmp/fx_beam
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as nd

U = 3
OUT = SPEC + '/out'

# tier ladder (RS_Retier.zs): band colours (core, light, mid, dark); mode 'add' unless noted
TIERS = [
 ('Common', [(255,250,235),(255,214,150),(214,134,60),(120,58,26)]),
 ('Green',  [(240,255,236),(160,250,130),(60,196,48),(18,104,28)]),
 ('Blue',   [(240,248,255),(150,204,255),(48,110,255),(18,38,160)]),
 ('Purple', [(255,240,255),(230,160,255),(170,60,240),(88,20,150)]),
 ('Yellow', [(255,255,226),(255,238,120),(236,188,28),(146,98,8)]),
 ('Red',    [(255,238,228),(255,148,116),(226,38,28),(126,10,10)]),
 ('FireBlu',[(240,250,255),(140,200,255),(236,72,30),(120,22,10)]),
 ('Gray',   [(250,250,250),(200,200,206),(140,140,146),(78,78,84)]),
 ('Abyss',  [(228,226,255),(128,108,230),(68,38,170),(28,10,80)]),
 ('Black',  [(216,210,228),(84,74,98),(38,32,48),(12,10,18)]),
 ('White',  [(255,255,255),(244,248,255),(206,216,238),(146,156,186)]),
 ('Cyan',   [(240,255,255),(150,255,248),(28,218,228),(8,108,128)]),
 ('Brown',  [(255,240,218),(230,178,118),(168,98,44),(92,48,18)]),
]
def tier(n): return TIERS[n-1]
def tmode(n): return 'alpha' if TIERS[n-1][0] == 'Black' else 'add'

def colorize(idx, n):
    """band-index map (0 empty,1 dark,2 mid,3 light,4 core) -> RGBA uint8 in tier n colours"""
    pal = np.zeros((5,4), np.uint8)
    for k,c in enumerate(tier(n)[1]): pal[4-k,:3] = c; pal[4-k,3] = 255
    return pal[idx]

# ---------------------------------------------------------------- our own beam texture
def beam_idx(seed, W=32, H=80):
    """hand-built pixel beam: white core + 3 flat bands each side, stepped taper at the top, edge shimmer"""
    r = random.Random(seed)
    idx = np.zeros((H, W), np.uint8)
    cx = (W-1)/2
    half = {4: 3, 3: 6, 2: 10, 1: 13}         # half widths in texels at the base
    top = {4: .60, 3: .76, 2: .90, 1: 1.0}     # how far up each band reaches
    for band in (1, 2, 3, 4):
        run = 0; j = 0
        for y in range(H):                     # y=0 is the floor row (flipped at the end)
            f = y / H
            if f >= top[band]: break
            hw = half[band]
            lim = top[band]
            if f > lim - .30:                  # stepped taper: lose 1 texel per step
                hw -= int((f - (lim - .30)) / .30 * (half[band] - (1 if band > 1 else 2)) + .5)
            if band <= 2:                       # shimmer: vertical runs of +-1
                if run <= 0: j = r.choice([-1, 0, 0, 1]); run = r.randint(2, 5)
                run -= 1; hw += j
            hw = max(hw, 1)
            for x in range(W):
                if abs(x - cx) < hw: idx[y, x] = max(idx[y, x], band)
    # sparse noise: a few dark specks just outside the dark band, a few holes in it
    for _ in range(10):
        y = r.randrange(4, int(H*.95)); row = np.nonzero(idx[y])[0]
        if len(row) == 0: continue
        side = r.choice([-1, 1]); x = (row.min()-1) if side < 0 else (row.max()+1)
        if 0 <= x < W and r.random() < .6: idx[y, x] = 1
        elif idx[y, row.min()] == 1: idx[y, row.min() if side < 0 else row.max()] = 0
    return idx[::-1].copy()

BEAM = [beam_idx(s) for s in (11, 23, 37)]       # 3 shimmer frames (DOWN A/B/C equivalent)

# ---------------------------------------------------------------- cut frames from the Z-Fighter sheet -> band maps
def posterize(rgba, sx, sy):
    a = np.asarray(rgba).astype(int); m = a[..., 3] > 0
    L = a[..., :3].mean(-1)
    idx = np.zeros(m.shape, np.uint8)
    idx[(L > 30) & m] = 1; idx[(L > 105) & m] = 2; idx[(L > 175) & m] = 3; idx[(L > 235) & m] = 4
    H, W = idx.shape; h = max(1, round(H*sy)); w = max(1, round(W*sx))
    ys = ((np.arange(h)+.5)/sy).astype(int).clip(0, H-1); xs = ((np.arange(w)+.5)/sx).astype(int).clip(0, W-1)
    out = idx[ys][:, xs]
    # stray-pixel cleanup: lone texels with no non-empty 4-neighbour go
    nz = out > 0
    nb = nd.convolve(nz.astype(int), np.array([[0,1,0],[1,0,1],[0,1,0]]), mode='constant')
    out[nz & (nb == 0)] = 0
    # lone core/light specks inside darker bands: drop one band
    for b in (4, 3):
        mb = out >= b
        nb = nd.convolve(mb.astype(int), np.ones((3,3), int), mode='constant') - mb
        out[mb & (nb == 0)] = b-1
    return out
def cut_idx(path, sx, sy=None):
    return posterize(Image.open(path).convert('RGBA'), sx, sy if sy else sx)

# ---------------------------------------------------------------- monsters
MON = SPEC + '/mon'
def monster(name):
    im = Image.open(f'{MON}/{name}.png').convert('RGBA')
    a = np.asarray(im); ys, xs = np.nonzero(a[..., 3] > 0)
    return a[ys.min():ys.max()+1, xs.min():xs.max()+1].copy()

# ---------------------------------------------------------------- canvas
class Canvas:
    def __init__(s, Wu=200, Hu=210, floor=170):
        s.Wu, s.Hu, s.F = Wu, Hu, floor
        s.cx = Wu/2
        s.c = np.zeros((Hu*U, Wu*U, 3), float)
        bg = np.zeros((Hu, Wu, 3), float)
        bg[:] = (13, 11, 17)
        bg[floor:] = (22, 20, 26)
        for k, y in enumerate((floor+4, floor+10, floor+19, floor+31)):
            if y < Hu: bg[y] = (27, 25, 31)
        bg[floor] = (52, 48, 58)
        s.c[:] = up(bg)
    def px(s, x, z): return (s.cx + x)*U, (s.F - z)*U
    def put(s, rgba, x0, y0, mode='add', alpha=1.0):
        """rgba: display-res uint8/float array; x0,y0 display px of top-left"""
        h, w = rgba.shape[:2]; x0 = int(round(x0)); y0 = int(round(y0))
        X0, Y0 = max(x0, 0), max(y0, 0); X1, Y1 = min(x0+w, s.c.shape[1]), min(y0+h, s.c.shape[0])
        if X1 <= X0 or Y1 <= Y0: return
        src = rgba[Y0-y0:Y1-y0, X0-x0:X1-x0].astype(float)
        a = src[..., 3:4]/255*alpha; rgb = src[..., :3]
        dst = s.c[Y0:Y1, X0:X1]
        if mode == 'add': dst += rgb*a
        else: dst[:] = dst*(1-a) + rgb*a
    def tex(s, rgba, x, z, wu, hu, mode='add', alpha=1.0, anchor='bottom'):
        """draw a texture scaled (nearest) to wu x hu map units, bottom-centre at (x, z)"""
        pw, ph = max(U, int(round(wu*U))) if wu >= .5 else 0, int(round(hu*U))
        if pw < 1 or ph < 1 or alpha <= 0: return
        H, W = rgba.shape[:2]
        ys = ((np.arange(ph)+.5)*H/ph).astype(int).clip(0, H-1); xs = ((np.arange(pw)+.5)*W/pw).astype(int).clip(0, W-1)
        img = rgba[ys][:, xs]
        X, Y = s.px(x, z)
        y0 = Y - ph if anchor == 'bottom' else Y - ph/2
        s.put(img, X - pw/2, y0, mode, alpha)
    def sprite(s, a, x, z, scale=1.0, alpha=1.0, sil=None):
        a = a.copy()
        if sil is not None: a[..., :3] = sil
        s.tex(a, x, z, a.shape[1]*scale, a.shape[0]*scale, 'alpha', alpha)
    def unit_layer(s, layer, mode='add', alpha=1.0):
        """layer: (Hu, Wu, 4) map-unit grid -> upscaled"""
        s.put(up(layer), 0, 0, mode, alpha)
    def frame(s):
        return Image.fromarray(np.clip(s.c, 0, 255).astype(np.uint8))

def up(a): return a.repeat(U, 0).repeat(U, 1)

def ellipse_layer(cv, x, rx, col, ry=None, z=0, ring=0):
    """flat floor ellipse on the unit grid (hard edge). ring>0: outline of that thickness."""
    L = np.zeros((cv.Hu, cv.Wu, 4), float)
    ry = ry if ry else max(1, rx/4)
    yy, xx = np.mgrid[0:cv.Hu, 0:cv.Wu]
    cx = cv.cx + x - .5; cy = cv.F - z + .0
    d = ((xx - cx)/max(rx, .5))**2 + ((yy - cy)/max(ry, .5))**2
    m = d <= 1
    if ring:
        rx2, ry2 = rx - ring, ry - 1
        if rx2 > 0 and ry2 > 0:
            m &= ((xx - cx)/rx2)**2 + ((yy - cy)/ry2)**2 > 1
    L[m, :3] = col; L[m, 3] = 255
    return L

def floor_glow(cv, x, radii, cols, alpha=1.0):
    """stepped floor light: a few flat bands, outermost first"""
    for r, c in zip(radii, cols):
        if r > 0: cv.unit_layer(ellipse_layer(cv, x, r, c), 'add', alpha)

def scaled(c, k): return tuple(int(v*k) for v in c)

# ---------------------------------------------------------------- sparks on the unit grid
class Sparks:
    def __init__(s, t0, n, x, seed, spread=12, vz=(2.5, 5.5), vx=1.6, grav=.45, life=(7, 13), z0=(0, 6)):
        r = random.Random(seed); s.p = []
        for i in range(n):
            s.p.append(dict(t0=t0 + i % 3, x=x + r.uniform(-spread, spread), z=r.uniform(*z0),
                            vx=r.uniform(-vx, vx), vz=r.uniform(*vz), life=r.randint(*life)))
        s.g = grav
    def draw(s, cv, t, n):
        cols = tier(n)[1]
        L = np.zeros((cv.Hu, cv.Wu, 4), float)
        for p in s.p:
            a = t - p['t0']
            if a < 0 or a >= p['life']: continue
            band = min(3, int(4*a/p['life']))
            for k, (dt, b) in enumerate(((0, band), (1, min(3, band+1)))):   # head + 1-texel trail one band darker
                aa = a - dt
                if aa < 0: continue
                x = p['x'] + p['vx']*aa; z = p['z'] + p['vz']*aa - s.g*aa*aa/2
                if z < 0: continue
                X = int(round(cv.cx + x)); Y = int(round(cv.F - z))
                if 0 <= X < cv.Wu and 0 <= Y < cv.Hu and L[Y, X, 3] == 0:
                    L[Y, X, :3] = cols[b]; L[Y, X, 3] = 255
        cv.unit_layer(L, 'add')

# ---------------------------------------------------------------- output
PAT_FULL = [30, 30, 30, 30, 30, 30, 20]   # GIF 10ms steps: averages 28.57ms = 35 tics/s
PAT_HALF = [60, 60, 60, 60, 60, 50, 50]   # 57.14ms = 17.5/s
def save_gif(frames, path, half=False):
    pat = PAT_HALF if half else PAT_FULL
    big = Image.new('RGB', (frames[0].width, frames[0].height*len(frames)))
    for i, f in enumerate(frames): big.paste(f, (0, i*f.height))
    pal = big.quantize(255, method=Image.MEDIANCUT, dither=Image.NONE)
    fr = [f.quantize(palette=pal, dither=Image.NONE) for f in frames]
    fr[0].save(path, save_all=True, append_images=fr[1:], duration=[pat[i % 7] for i in range(len(fr))],
               loop=0, optimize=False, disposal=1)

def label(img, text, xy=(4, 4), col=(200, 200, 200)):
    d = ImageDraw.Draw(img); d.text(xy, text, fill=col); return img
