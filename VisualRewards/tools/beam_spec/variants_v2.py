import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from variants import *     # beam.py helpers + v1 pieces (draw_eos_beam, cap, CB, CS)

PRE, POST = 8, 26

def growth(n, sx0=2.0, sy0=0.1, sx1=0.7056, sy1=1.744, ease=1.7):
    """EoS growth (2.0x0.1 -> 0.71x1.74) spread over n tics; fast start like EoS, eased in log space"""
    out = []
    for i in range(1, n+1):
        f = 1 - (1 - i/n)**ease
        out.append((sx0*(sx1/sx0)**f, sy0*(sy1/sy0)**f))
    return out

def reveal(m, hw, cols, scan=False):
    """monster revealed from inside the beam: a slit of half-width hw (texels) opens from the sprite's centre line.
    slit edge texels: core white, then tier light, then tier mid (flat), inside: real colours. scan: even rows only."""
    a = m.copy(); H, W = a.shape[:2]; cx = (W - 1)/2
    d = hw - np.abs(np.arange(W) - cx)            # distance inside the slit edge
    vis = a[..., 3] > 0
    out = np.zeros_like(a)
    for x in range(W):
        if d[x] <= 0: continue
        col = a[:, x].copy()
        if d[x] < 1.5: col[:, :3] = cols[0]
        elif d[x] < 2.5: col[:, :3] = cols[1]
        elif d[x] < 3.5: col[:, :3] = cols[2]
        out[:, x] = col
    out[~vis] = 0
    if scan: out[1::2] = 0
    return out

# ---------------------------------------------------------------- V1 v2: EoS motion, monster delivered from inside the beam, falling rings
def V1b(n=2, mon='imp01'):
    m = monster(mon) if mon else None; cols = tier(n)[1]
    G = growth(6)
    S = [(sx, sy, 1.0) for sx, sy in G] + [(G[-1][0], G[-1][1], 1.0)]*2          # tics 0-7
    w = G[-1][0]
    for j in range(1, 16):                                                       # narrowing x0.84, alpha holds 4 tics then -0.1
        a = 1.0 if j <= 4 else round(1 - .1*(j-4), 2)
        if a <= 0: break
        S.append((w*.84**j, G[-1][1], a))
    H = 80*G[-1][1]
    drops = [6, 9, 12]
    frames = []
    for t in range(PRE + len(S) + 4 + POST):
        cv = Canvas(); k = t - PRE
        # floor light from the beam (2 flat bands)
        if 0 <= k < len(S):
            sx, sy, a = S[k]; r = 32*sx*.75 + 5
            floor_glow(cv, 0, [r, r*.6], [scaled(cols[2], .55), scaled(cols[1], .6)], alpha=a)
        # dropping rings land and spread as floor rings
        for d0 in drops:
            j = k - d0
            if j < 0: continue
            z = H - (5*j + 1.6*j*j)
            if z > 0:
                rw = 5 + j*1.6; c = cols[min(2, j//3)]
                cv.unit_layer(ellipse_layer(cv, 0, rw, c, ry=max(1.5, rw/4), z=z, ring=1), 'add')
            else:
                jj = j - int((-5 + math.sqrt(25 + 6.4*H))/3.2) - 1
                if 0 <= jj < 4:
                    cv.unit_layer(ellipse_layer(cv, 0, 16 + jj*6, cols[min(3, 1+jj)], ring=1), 'add')
        # monster: slit opens from the beam's core, 2 scanline tics first, 3 texels per tic
        if m is not None and k >= 5:
            hw = 1 + 2*(k - 5)
            if hw < m.shape[1]/2 + 4: cv.sprite(reveal(m, hw, cols, scan=k < 7), 0, 0)
            else: cv.sprite(m, 0, 0)
        if 0 <= k < len(S): draw_eos_beam(cv, k, 0, n, S[k], glow=False)
        frames.append(cv.frame())
    return frames, PRE

# ---------------------------------------------------------------- V2 v2: arcade, more in-betweens
def V2b(n=13, mon='imp08', H=170, seed=5):
    m = monster(mon); cols = tier(n)[1]
    sp = Sparks(5, 22, 0, seed, spread=10, life=(10, 18))
    rings = [5, 7, 9, 11]
    peakw = 26
    frames = []; T = 34
    for t in range(PRE + T + POST):
        cv = Canvas(Hu=240, floor=205); k = t - PRE
        if 0 <= k <= 5:
            r = [7, 14, 21, 28, 34, 39][k]; c = cols[[0, 0, 1, 1, 2, 3][k]]
            cv.unit_layer(ellipse_layer(cv, 0, r, c, ring=2), 'add')
            if k <= 1: cv.unit_layer(ellipse_layer(cv, 0, [5, 8][k], cols[0]), 'add')
        if 5 <= k <= 21:
            st = 0 if k <= 8 else (1 if k <= 13 else (2 if k <= 18 else 3))
            radii = [[32, 22, 12], [26, 16, 8], [18, 10, 0], [10, 0, 0]][st]
            floor_glow(cv, 0, radii, [scaled(cols[3], .9), scaled(cols[2], .7), scaled(cols[1], .7)])
        if 5 <= k <= 9: cv.sprite(m, 0, 0, sil=(255, 255, 255))
        elif k == 10: cv.sprite(m, 0, 0, sil=cols[1])
        elif k == 11: cv.sprite(m, 0, 0, sil=cols[2])
        elif k >= 12: cv.sprite(m, 0, 0)
        idx = colorize(BEAM[t % 3], n)
        if 2 <= k <= 4:                       # slam: the beam falls from the sky in 3 steps
            f = [(.66, 10), (.33, 13), (0, 16)][k-2]
            cut = BEAM[k % 3][:int(80*(1-f[0]))]
            cv.tex(colorize(cut, n), 0, H*f[0], f[1], H*(1-f[0]), tmode(n))
        elif 5 <= k <= 9:
            cv.tex(idx, 0, 0, peakw*[1.4, 1.25, 1.12, 1.0, 1.0][k-5], H, tmode(n))
        elif k >= 10:
            j = k - 9; w = peakw*(.82**j); a = 1.0 if j < 3 else 1 - .1*(j-2)
            if a > 0 and w >= .7: cv.tex(idx, 0, 0, w, H, tmode(n), a)
        if 5 <= k <= 7:
            cv.tex(colorize(BEAM[(k+2) % 3], n), 0, 0, [66, 54, 40][k-5], [9, 7, 4][k-5], tmode(n), [1, .8, .6][k-5])
        for r0 in rings:
            j = k - r0
            if 0 <= j < 12:
                c = cols[min(3, j//3)]
                cv.unit_layer(ellipse_layer(cv, 0, 18 - j*.7, c, ry=2.2, z=4 + j*13, ring=1), 'add')
        sp.draw(cv, k, n)
        frames.append(cv.frame())
    return frames, PRE

# ---------------------------------------------------------------- V3 v2: blue column with life
def crawl(idx, k, period=30, band=2, speed=6):
    """darker bands crawling up inside the column: core -> light in moving stripes"""
    out = idx.copy(); H = out.shape[0]
    rows = (np.arange(H) + speed*k) % period < band
    sub = out[rows]; sub[sub == 4] = 3; out[rows] = sub
    return out

def licks(cv, idx, sy, k, n, seed, count=5):
    """small flame tongues licking off the column sides (own pixel art, unit grid)"""
    r = random.Random(seed*1000 + k); cols = tier(n)[1]
    L = np.zeros((cv.Hu, cv.Wu, 4), float); H = idx.shape[0]
    for _ in range(count):
        row = r.randrange(int(H*.15), int(H*.9))
        nz = np.nonzero(idx[row])[0]
        if len(nz) == 0: continue
        z = (H - row)*sy; side = r.choice([-1, 1])
        ex = (nz.max() - (idx.shape[1]-1)/2 + .5) if side > 0 else (nz.min() - (idx.shape[1]-1)/2 - .5)
        ln = r.randint(3, 7)
        for i in range(ln):
            X = int(round(cv.cx + ex + side*i)); Y = int(round(cv.F - z - i*.8))
            c = cols[2] if i < ln//2 else cols[3]
            for dy in range(max(1, (ln - i)//2)):
                if 0 <= X < cv.Wu and 0 <= Y+dy < cv.Hu: L[Y+dy, X, :3] = c; L[Y+dy, X, 3] = 255
    cv.unit_layer(L, 'add')

def V3b(n=3, mon='imp02'):
    m = monster(mon); cols = tier(n)[1]
    dome = cut_idx(f'{CB}/b_dome.png', .42); spike = cut_idx(f'{CB}/b_spike.png', .42)
    burst = cut_idx(f'{CB}/b_burst.png', .42)
    c2 = cap(cut_idx(f'{CB}/b_col2.png', .34, .70)); c1 = cap(cut_idx(f'{CB}/b_col1.png', .34, .70))
    c0 = cap(cut_idx(f'{CB}/b_col0.png', .34, .70))
    capb = spike[::-1].copy()                     # the white splash flipped: a burst cap at the column top
    def T(i): return colorize(i, n)
    sp = None
    frames = []; T_ = 30; END = 15             # narrowing starts at END
    for t in range(PRE + T_ + POST):
        cv = Canvas(Hu=250, floor=212); k = t - PRE
        # floor: stepped glow + pulsing ring
        if 0 <= k <= END + 7:
            st = 0 if k < 6 else (1 if k < END + 2 else 2)
            floor_glow(cv, 0, [[34, 22, 12], [30, 18, 8], [18, 8, 0]][st],
                       [scaled(cols[3], .9), scaled(cols[2], .7), scaled(cols[1], .6)])
            if k < 6: rr, c = [20, 27, 33, 38, 41, 43][k], cols[[0, 1, 1, 2, 2, 3][k]]
            else: rr, c = 41 + [0, 2, 4, 2][k % 4], cols[[2, 1, 2, 3][k % 4]]
            if k < END + 4: cv.unit_layer(ellipse_layer(cv, 0, rr, c, ring=1), 'add')
        # monster: fully hidden by the column; silhouette as it narrows, then real
        j = k - END
        if 0 <= j <= 2: cv.sprite(m, 0, 0, sil=(255, 255, 255))
        elif j == 3: cv.sprite(m, 0, 0, sil=cols[1])
        elif j >= 4: cv.sprite(m, 0, 0)
        # column
        col = None
        if 3 <= k <= 6: col = (c2, [.25, .5, .75, 1.0][k-3])
        elif 7 <= k <= 8: col = (c2, 1.0)
        elif 9 <= k <= 11: col = (c1, 1.0)
        elif 12 <= k <= 14: col = (c0, 1.0)
        if col:
            i, sy = col; ii = crawl(i, k)
            cv.tex(T(ii), 0, 0, i.shape[1], i.shape[0]*sy, tmode(n))
            if k >= 5: licks(cv, i, sy, k, n, 3, count=8)
        if j >= 0:
            w = c0.shape[1]*(.74**(j+1)); a = 1.0 if j <= 3 else 1 - .15*(j-3)
            if a > 0 and w >= .7: cv.tex(T(crawl(c0, k)), 0, 0, w, c0.shape[0], tmode(n), a)
        # burst cap at the top as the column arrives at full height
        if 6 <= k <= 9:
            s = [.5, .9, .7, .45][k-6]; top = (c2.shape[0] if k < 9 else c1.shape[0]) - 4
            cv.tex(T(capb), 0, top - capb.shape[0]*s*.5, capb.shape[1]*s, capb.shape[0]*s, tmode(n))
        # impact sequence on the floor (in front)
        if k == 0: cv.tex(T(dome), 0, 0, dome.shape[1]*.75, dome.shape[0]*.75, tmode(n))
        if k == 1: cv.tex(T(dome), 0, 0, dome.shape[1], dome.shape[0], tmode(n))
        if k == 2: cv.tex(T(spike), 0, 0, spike.shape[1]*.85, spike.shape[0]*.85, tmode(n))
        if k == 3: cv.tex(T(spike), 0, 0, spike.shape[1], spike.shape[0], tmode(n))
        if 4 <= k <= 7:
            s = [1.0, 1.05, 1.1, 1.12][k-4]
            cv.tex(T(burst), 0, 0, burst.shape[1]*s, burst.shape[0]*s, tmode(n), [1, .8, .6, .35][k-4])
        # final pop as it narrows away
        if j == 5:
            sp = Sparks(k, 12, 0, 9, spread=4, vz=(2, 5), vx=2.2, life=(6, 11))
        if 5 <= j <= 7:
            s = [.45, .6, .7][j-5]
            cv.tex(T(spike), 0, 0, spike.shape[1]*s, spike.shape[0]*s, tmode(n), [1, .75, .45][j-5])
            cv.unit_layer(ellipse_layer(cv, 0, [14, 22, 28][j-5], cols[[0, 1, 2][j-5]], ring=1), 'add')
        if sp: sp.draw(cv, k, n)
        frames.append(cv.frame())
    return frames, PRE

# ---------------------------------------------------------------- V4 v2: spinning convergence, longer skull pillar
def V4b(n=5, mon='cac05', R=58, nb=6):
    m = monster(mon); cols = tier(n)[1]
    sk = [cut_idx(f'{CS}/s{i:02d}.png', .9) for i in range(19)]
    for i in (2, 3, 4): sk[i] = cap(sk[i], 30)
    for i in (16, 17, 18):
        lab, nl = nd.label(sk[i] > 0)
        if nl > 1:
            sizes = nd.sum(sk[i] > 0, lab, range(1, nl+1)); keep = 1 + int(np.argmax(sizes))
            sk[i][lab != keep] = 0
    # pillar plan: (frame, sx, sy, alpha) per tic -- scale tweens give in-betweens on the cut frames
    plan = []
    plan += [(0, .6, .6, 1), (0, .8, .8, 1), (0, 1, 1, 1)]
    plan += [(1, 1, .85, 1), (1, 1, .95, 1), (1, 1, 1, 1)]
    for i in (2, 3, 4): plan += [(i, 1, .9, 1), (i, 1, 1, 1)]
    plan += [(i, 1, 1, 1) for i in range(5, 16)] + [(i, 1, 1, 1) for i in range(5, 16)]
    for i in (16, 17, 18): plan += [(i, 1, 1, 1)]*3
    plan += [(18, .8, 1, .75), (18, .6, 1, .5), (18, .4, 1, .25)]
    G = growth(6)
    MERGE = 18
    frames = []
    T_ = MERGE + len(plan) + 4
    def ringr(k):
        if k < 10: return R
        f = min(1, (k - 10)/(MERGE - 10)); return R*(1 - f*f*(3 - 2*f))
    def spin(k):                                   # degrees, accelerating from tic 8
        j = max(0, k - 8); return 1.2*j*j
    for t in range(PRE + T_ + POST):
        cv = Canvas(Wu=240, Hu=240, floor=196); k = t - PRE
        sats = []
        for b in range(nb):
            jb = k - b
            if jb < 0 or k > MERGE: continue
            ang = math.radians(120 + b*360/nb + spin(k)); r = ringr(k)
            sx, sy = G[min(jb, 5)]
            sats.append((math.sin(ang), r*math.cos(ang), r*math.sin(ang)*.22, (sx, sy, 1.0), jb))
        sats.sort()
        back = [s for s in sats if s[0] > 0]; front = [s for s in sats if s[0] <= 0]
        def draw_sats(Ls):
            for _, x, zo, sc, jb in Ls: draw_eos_beam(cv, jb, x, n, sc, hmul=.75, z=zo, glow=False)
        if 0 <= k <= MERGE:
            rr = ringr(k)
            cv.unit_layer(ellipse_layer(cv, 0, rr + 8, scaled(cols[3], .8), ring=3), 'add')
            if k >= 10: cv.unit_layer(ellipse_layer(cv, 0, max(4, rr*.6), scaled(cols[2], .5)), 'add')
        draw_sats(back)
        p = k - MERGE
        if 0 <= p < len(plan):
            if p < 9: floor_glow(cv, 0, [44, 28], [scaled(cols[3], .9), scaled(cols[2], .6)])
            elif p < len(plan) - 6: floor_glow(cv, 0, [38, 22], [scaled(cols[3], .8), scaled(cols[2], .5)])
        if MERGE + 8 <= k <= MERGE + 11: cv.sprite(m, 0, 4, sil=(255, 255, 255))
        elif k == MERGE + 12: cv.sprite(m, 0, 4, sil=cols[1])
        elif k > MERGE + 12: cv.sprite(m, 0, 4)
        if 0 <= p < len(plan):
            i, sx, sy, a = plan[p]; tex = sk[i]
            cv.tex(colorize(tex, n), 0, -4, tex.shape[1]*sx, tex.shape[0]*sy, tmode(n), a)
        draw_sats(front)
        if k == MERGE: cv.tex(colorize(BEAM[0], n), 0, 0, 84, 10, tmode(n))
        if k == MERGE + 1: cv.tex(colorize(BEAM[1], n), 0, 0, 64, 6, tmode(n), .7)
        frames.append(cv.frame())
    return frames, PRE
