import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants_v2 import *     # v2 pieces (V3b timing, crawl, licks, cap, CB ...)

# ---------------------------------------------------------------- V3 v3: context versions (indoor ceiling hit / outdoor sky run-off)
CEIL = 150                                   # map units: ceiling height the indoor beam finds above the monster

class CanvasCeil(Canvas):
    """v2 canvas + a ceiling in flat bands at CEIL units; effect draws are clipped at its underside"""
    def __init__(s, Wu=200, Hu=250, floor=212, ceil=CEIL):
        Canvas.__init__(s, Wu, Hu, floor)
        C = floor - ceil; s.C = C
        bg = np.zeros((C, Wu, 3), float)
        bg[:] = (22, 20, 26)                       # mirror of the floor bands
        for y in (C-1-4, C-1-10, C-1-19, C-1-31):
            if y >= 0: bg[y] = (27, 25, 31)
        bg[C-1] = (52, 48, 58)
        s.c[:C*U] = up(bg)
        s.clip = C*U
    def put(s, rgba, x0, y0, mode='add', alpha=1.0):
        x0 = int(round(x0)); y0 = int(round(y0))
        if s.clip and y0 < s.clip:
            cut = s.clip - y0
            if cut >= rgba.shape[0]: return
            rgba = rgba[cut:]; y0 = s.clip
        Canvas.put(s, rgba, x0, y0, mode, alpha)
    def noclip(s, fn, *a, **kw):
        c = s.clip; s.clip = 0
        try: fn(*a, **kw)
        finally: s.clip = c

class CanvasSky(Canvas):
    """taller v2 canvas with a night sky in 4 flat bands, a few stars, a far hill line on the horizon"""
    def __init__(s, Wu=200, Hu=290, floor=252):
        Canvas.__init__(s, Wu, Hu, floor)
        bg = np.zeros((floor, Wu, 3), float)
        bands = [(0, (9, 10, 26)), (int(floor*.30), (14, 15, 36)), (int(floor*.55), (20, 19, 46)), (int(floor*.78), (28, 24, 54))]
        for y0, c in bands: bg[y0:] = c
        r = random.Random(4)
        for _ in range(26):
            y = r.randrange(2, int(floor*.5)); x = r.randrange(Wu)
            bg[y, x] = (70, 72, 100) if r.random() < .7 else (120, 122, 150)
        # far hills: stepped silhouette, flat colour
        h = 6
        for x in range(Wu):
            if x % r.choice([3, 4, 5, 6]) == 0: h = max(2, min(12, h + r.choice([-2, -1, 0, 1, 2])))
            bg[floor-h:floor, x] = (16, 14, 22)
        s.c[:floor*U] = up(bg)

def taper_idx(body, L=150, seed=7):
    """own stepped taper put on top of an uncapped column: half width shrinks to a point over L texels,
    the outer bands thicken toward the tip so it goes blue like the v2 rounded top"""
    W = body.shape[1]; cx = (W - 1)/2
    nz = np.nonzero(body[0])[0]; hw0 = (nz.max() - nz.min() + 1)/2
    r = random.Random(seed)
    t = np.zeros((L, W), np.uint8)
    for y in range(L):                          # y=0 is the base of the taper (flipped at the end)
        u = y/L
        hw = hw0*(1 - u)**1.25
        sh = {1: 0, 2: 2.5*u, 3: 1 + 5*u, 4: 1 + 9*u}   # u=0 matches the body's top row
        for b in (1, 2, 3, 4):
            hb = hw - sh[b]
            if hb <= .5: continue
            for x in range(W):
                if abs(x - cx) < hb: t[y, x] = b
    return np.vstack([t[::-1], body])

def flames_up(cv, k, n, zfrom, half_at, seed, k0=5, k1=19):
    """flame licks trailing upward off the taper sides and out of the top (unit grid, flat bands)"""
    cols = tier(n)[1]; L = np.zeros((cv.Hu, cv.Wu, 4), float)
    for s in range(k0, min(k, k1) + 1):
        r = random.Random(seed*100 + s)
        for _ in range(2):
            z0 = r.uniform(zfrom, zfrom + 70); side = r.choice([-1, 1]); ln = r.randint(5, 9)
            a = k - s
            if a > 7: continue
            z = z0 + 11*a
            x = side*(half_at(z0) + 1 + a*.6 + r.choice([0, 1]))
            for i in range(ln):
                c = cols[2] if (i < ln//2 and a < 3) else cols[3]
                X = int(round(cv.cx + x + (side if i > ln - 3 else 0))); Y = int(round(cv.F - z - i))
                if 0 <= X < cv.Wu and 0 <= Y < cv.Hu: L[Y, X, :3] = c; L[Y, X, 3] = 255
                if i < ln//2 and 0 <= X - side < cv.Wu and 0 <= Y < cv.Hu: L[Y, X - side, :3] = cols[3]; L[Y, X - side, 3] = 255
    cv.unit_layer(L, 'add')

def V3c(where='indoor', n=3, mon='imp02'):
    m = monster(mon); cols = tier(n)[1]
    dome = cut_idx(f'{CB}/b_dome.png', .42); spike = cut_idx(f'{CB}/b_spike.png', .42)
    burst = cut_idx(f'{CB}/b_burst.png', .42)
    raw = {k: cut_idx(f'{CB}/b_{k}.png', .34, .70) for k in ('col2', 'col1', 'col0')}
    capped = {k: cap(v) for k, v in raw.items()}
    if where == 'indoor':
        cols_tex = raw                           # full width right up to the ceiling cut
    else:
        cols_tex = {k: taper_idx(v) for k, v in raw.items()}
    c2, c1, c0 = cols_tex['col2'], cols_tex['col1'], cols_tex['col0']
    capb = spike[::-1].copy()                    # white splash flipped: spikes hang down from the ceiling
    def T(i): return colorize(i, n)
    sp = None; drops = []
    frames = []; T_ = 30; END = 15
    for t in range(PRE + T_ + POST):
        cv = CanvasCeil() if where == 'indoor' else CanvasSky()
        k = t - PRE
        # floor: stepped glow + pulsing ring (v2)
        if 0 <= k <= END + 7:
            st = 0 if k < 6 else (1 if k < END + 2 else 2)
            floor_glow(cv, 0, [[34, 22, 12], [30, 18, 8], [18, 8, 0]][st],
                       [scaled(cols[3], .9), scaled(cols[2], .7), scaled(cols[1], .6)])
            if k < 6: rr, c = [20, 27, 33, 38, 41, 43][k], cols[[0, 1, 1, 2, 2, 3][k]]
            else: rr, c = 41 + [0, 2, 4, 2][k % 4], cols[[2, 1, 2, 3][k % 4]]
            if k < END + 4: cv.unit_layer(ellipse_layer(cv, 0, rr, c, ring=1), 'add')
        # indoor: lit patch + spreading ring on the ceiling underside while the column touches it
        j = k - END
        if where == 'indoor' and 6 <= k <= END + 4:
            st = 0 if k < 10 else (1 if k < END + 1 else 2)
            radii = [[32, 20, 10], [26, 14, 6], [14, 6, 0]][st]
            for rr, c in zip(radii, [scaled(cols[3], .8), scaled(cols[2], .6), scaled(cols[1], .5)]):
                if rr > 0: cv.noclip(cv.unit_layer, ellipse_layer(cv, 0, rr, c, z=CEIL), 'add')
        # monster (v2)
        if 0 <= j <= 2: cv.sprite(m, 0, 0, sil=(255, 255, 255))
        elif j == 3: cv.sprite(m, 0, 0, sil=cols[1])
        elif j >= 4: cv.sprite(m, 0, 0)
        # column (v2 timing). indoor: capped tip while still below the ceiling, full width once it reaches it
        col = None
        if 3 <= k <= 6: col = ('col2', [.25, .5, .75, 1.0][k-3])
        elif 7 <= k <= 8: col = ('col2', 1.0)
        elif 9 <= k <= 11: col = ('col1', 1.0)
        elif 12 <= k <= 14: col = ('col0', 1.0)
        if col:
            name, sy = col; i = cols_tex[name]
            if where == 'indoor' and i.shape[0]*sy < CEIL: i = capped[name]
            cv.tex(T(crawl(i, k)), 0, 0, i.shape[1], i.shape[0]*sy, tmode(n))
            if k >= 5: licks(cv, raw[name] if where == 'outdoor' else i, sy if where == 'indoor' else 1.0, k, n, 3, count=8)
        if j >= 0:
            w = c0.shape[1]*(.74**(j+1)); a = 1.0 if j <= 3 else 1 - .15*(j-3)
            if a > 0 and w >= .7: cv.tex(T(crawl(c0, k)), 0, 0, w, c0.shape[0], tmode(n), a)
        # top of the column
        if where == 'indoor':
            if 6 <= k <= 10:                      # splash cap AT the ceiling, spreading along the underside
                sx, sy, dn = [(1.0, .6, 0), (1.3, .75, 0), (1.55, .6, 0), (1.75, .45, 1), (1.85, .3, 2)][k-6]
                h = capb.shape[0]*sy; ci = np.where(capb > 0, np.maximum(capb.astype(int) - dn, 1), 0).astype(np.uint8)
                cv.tex(T(ci), 0, CEIL - h, capb.shape[1]*sx, h, tmode(n))   # fades by dropping bands, no alpha
            if 6 <= k <= 11:
                rr = [24, 34, 42, 48, 52, 55][k-6]; c = cols[[0, 1, 1, 2, 2, 3][k-6]]
                cv.noclip(cv.unit_layer, ellipse_layer(cv, 0, rr, c, z=CEIL, ring=1), 'add')
            if k == 7: drops.append(Sparks(k, 16, 0, 21, spread=34, vz=(-1.2, 0), vx=.5, grav=.45, life=(10, 16), z0=(146, 149)))
            if k == 9: drops.append(Sparks(k, 10, 0, 33, spread=26, vz=(-1.0, 0), vx=.4, grav=.45, life=(9, 14), z0=(146, 149)))
            for d in drops: d.draw(cv, k, n)
        else:
            def half_at(z, i=c0): return 6
            if 5 <= k <= END + 4:
                name = 'col2' if k <= 8 else ('col1' if k <= 11 else 'col0')
                if j >= 0: name = 'col0'
                i = cols_tex[name]; Ht = i.shape[0]; Wc = (i.shape[1]-1)/2
                def half_at(z, i=i, Ht=Ht, Wc=Wc):
                    row = int(np.clip(Ht - z, 0, Ht-1)); nz = np.nonzero(i[row])[0]
                    return (nz.max() - Wc) if len(nz) else 1
                if j >= 0:
                    sc = .74**(j+1); hz = half_at
                    def half_at(z, hz=hz, sc=sc): return hz(z)*sc
                flames_up(cv, k, n, 150, half_at, 5, k0=5, k1=END + 1)
        # impact sequence on the floor (v2)
        if k == 0: cv.tex(T(dome), 0, 0, dome.shape[1]*.75, dome.shape[0]*.75, tmode(n))
        if k == 1: cv.tex(T(dome), 0, 0, dome.shape[1], dome.shape[0], tmode(n))
        if k == 2: cv.tex(T(spike), 0, 0, spike.shape[1]*.85, spike.shape[0]*.85, tmode(n))
        if k == 3: cv.tex(T(spike), 0, 0, spike.shape[1], spike.shape[0], tmode(n))
        if 4 <= k <= 7:
            s = [1.0, 1.05, 1.1, 1.12][k-4]
            cv.tex(T(burst), 0, 0, burst.shape[1]*s, burst.shape[0]*s, tmode(n), [1, .8, .6, .35][k-4])
        # final pop (v2)
        if j == 5:
            sp = Sparks(k, 12, 0, 9, spread=4, vz=(2, 5), vx=2.2, life=(6, 11))
        if 5 <= j <= 7:
            s = [.45, .6, .7][j-5]
            cv.tex(T(spike), 0, 0, spike.shape[1]*s, spike.shape[0]*s, tmode(n), [1, .75, .45][j-5])
            cv.unit_layer(ellipse_layer(cv, 0, [14, 22, 28][j-5], cols[[0, 1, 2][j-5]], ring=1), 'add')
        if sp: sp.draw(cv, k, n)
        frames.append(cv.frame())
    return frames, PRE
