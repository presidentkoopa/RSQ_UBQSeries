import sys; sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
SPEC = __import__('os').path.dirname(__import__('os').path.abspath(__file__))   # was /tmp/fx_beam
from beam import *

PRE, POST = 8, 24

# ---------------------------------------------------------------- V1: EoS faithful
def eos_scales(fade=0.1, wmul=0.7):
    """per visible tic (scalex, scaley, alpha) exactly as EnemyDown: spawn 2.0x0.1, 4 growth tics, then x*0.7 / alpha-0.1"""
    sx, sy, a = 2.0, 0.1, 1.0; out = []
    for mx, my in ((.9, 3), (.8, 1.9), (.7, 1.8), (.7, 1.7)):
        sx *= mx; sy *= my; out.append((sx, sy, a))
    while True:
        sx *= wmul; a = round(a - fade, 3)
        if a <= 0: break
        out.append((sx, sy, a))
    return out

def draw_eos_beam(cv, k, x, n, scl, tw=32, th=80, hmul=1.0, z=0, alpha_mul=1.0, glow=True):
    sx, sy, a = scl
    idx = BEAM[k % 3]
    w, h = tw*sx, th*sy*hmul
    if glow:
        cols = tier(n)[1]
        r = w*.75 + 5
        floor_glow(cv, x, [r, r*.6], [scaled(cols[2], .55), scaled(cols[1], .6)], alpha=a*alpha_mul)
    cv.tex(colorize(idx, n), x, z, w, h, tmode(n), a*alpha_mul)

def V1(n=2, mon='imp01', hmul=1.0, appear=3):
    m = monster(mon); S = eos_scales(); frames = []
    for t in range(PRE + len(S) + POST):
        cv = Canvas(); k = t - PRE
        if k >= appear: cv.sprite(m, 0, 0)
        if 0 <= k < len(S): draw_eos_beam(cv, k, 0, n, S[k], hmul=hmul)
        frames.append(cv.frame())
    return frames, PRE

# ---------------------------------------------------------------- V2: arcade
def V2(n=13, mon='imp08', H=170, seed=5):
    m = monster(mon); cols = tier(n)[1]
    sp = Sparks(3, 16, 0, seed, spread=10)
    rings = [3, 5, 7]
    peakw = 26
    frames = []
    T = 26
    for t in range(PRE + T + POST):
        cv = Canvas(Hu=240, floor=205); k = t - PRE
        # floor: ring flash first, then stepped glow
        if 0 <= k <= 3:
            r = [9, 20, 31, 38][k]; c = [cols[0], cols[1], cols[2], cols[3]][k]
            cv.unit_layer(ellipse_layer(cv, 0, r, c, ring=2), 'add')
            if k == 0: cv.unit_layer(ellipse_layer(cv, 0, 6, cols[0]), 'add')
        if 3 <= k <= 15:
            st = 0 if k <= 5 else (1 if k <= 9 else 2)
            radii = [[30, 21, 12], [24, 14, 0], [15, 0, 0]][st]
            floor_glow(cv, 0, radii, [scaled(cols[3], .9), scaled(cols[2], .7), scaled(cols[1], .7)])
        # monster: white silhouette, one tic of tier colour, then real
        if 3 <= k <= 6: cv.sprite(m, 0, 0, sil=(255, 255, 255))
        elif k == 7: cv.sprite(m, 0, 0, sil=cols[1])
        elif k >= 8: cv.sprite(m, 0, 0)
        # beam: slam from above (2 tics), impact at full+, hold, then EoS-style narrowing
        idx = colorize(BEAM[t % 3], n)
        if k == 1:
            cv.tex(colorize(BEAM[0][:40], n), 0, H*.55, 12, H*.45, tmode(n))
        elif k == 2:
            cv.tex(colorize(BEAM[1], n), 0, 0, 16, H, tmode(n))
        elif 3 <= k <= 5:
            cv.tex(idx, 0, 0, [peakw*1.3, peakw*1.1, peakw][k-3], H, tmode(n))
        elif k >= 6:
            j = k - 6; w = peakw*(.76**j); a = 1.0 if j < 2 else 1 - .12*(j-1)
            if a > 0 and w >= .7: cv.tex(idx, 0, 0, w, H, tmode(n), a)
        # impact flash bar on the floor
        if k == 3: cv.tex(colorize(BEAM[2], n), 0, 0, 64, 9, tmode(n))
        if k == 4: cv.tex(colorize(BEAM[0], n), 0, 0, 46, 5, tmode(n), .7)
        # rings riding up the beam
        for r0 in rings:
            j = k - r0
            if 0 <= j < 9:
                c = cols[min(3, j//2)]
                rw = 18 - j*.8
                cv.unit_layer(ellipse_layer(cv, 0, rw, c, ry=2.2, z=4 + j*17, ring=1), 'add')
        sp.draw(cv, k, n)
        frames.append(cv.frame())
    return frames, PRE

# ---------------------------------------------------------------- V3: Z-Fighter blue column + impact bursts (cut, posterized)
CB = SPEC + '/cut/blue'
def cap(idx, n=40):
    """our own stepped top for the cut columns (the sheet's columns run off its frame): bands step down toward the top"""
    idx = idx.copy()
    for r in range(n):
        row = idx[r]; nz = np.nonzero(row)[0]
        if len(nz) == 0: continue
        er = int(((n - r)/n)**2*10)               # rounded tip
        lo, hi = nz.min() + er, nz.max() - er
        row[:max(lo, 0)] = 0; row[hi+1:] = 0
        if hi - lo < 2: row[:] = 0; continue
        x = np.arange(len(row)); d = np.minimum(x - lo, hi - x)
        k = (n - r)/n*7
        allowed = 1 + np.floor(np.clip(d, 0, None)/max(k, .01)).astype(int)
        row[:] = np.where(row > 0, np.minimum(row, np.clip(allowed, 1, 4)), 0)
    return idx
def V3(n=3, mon='imp02'):
    m = monster(mon); cols = tier(n)[1]
    dome = cut_idx(f'{CB}/b_dome.png', .42)
    spike = cut_idx(f'{CB}/b_spike.png', .42)
    burst = cut_idx(f'{CB}/b_burst.png', .42)
    c2 = cap(cut_idx(f'{CB}/b_col2.png', .34, .70))
    c1 = cap(cut_idx(f'{CB}/b_col1.png', .34, .70))
    c0 = cap(cut_idx(f'{CB}/b_col0.png', .34, .70))
    global V3_TEX; V3_TEX = dict(dome=dome, spike=spike, burst=burst, c2=c2, c1=c1, c0=c0)
    def T(i): return colorize(i, n)
    frames = []; T_ = 24
    for t in range(PRE + T_ + POST):
        cv = Canvas(Hu=230, floor=192); k = t - PRE
        # floor ring (own, stepped)
        if 0 <= k <= 16:
            st = 0 if k < 4 else (1 if k < 10 else 2)
            floor_glow(cv, 0, [[34, 22, 12], [28, 16, 0], [18, 0, 0]][st],
                       [scaled(cols[3], .9), scaled(cols[2], .7), scaled(cols[1], .6)])
            if k < 12: cv.unit_layer(ellipse_layer(cv, 0, [22, 30, 36, 40, 42, 43][min(k, 5)] if k < 6 else 43, cols[[1, 1, 2, 2, 3, 3][min(k, 5)]] if k < 6 else cols[3], ring=1), 'add', 1.0 if k < 8 else .6)
        # monster
        if 3 <= k <= 5: cv.sprite(m, 0, 0, sil=(255, 255, 255))
        elif k == 6: cv.sprite(m, 0, 0, sil=cols[1])
        elif k >= 7: cv.sprite(m, 0, 0)
        # column: rises out of the burst (scale y), fat -> straight -> narrows away
        col = None
        if k == 2: col = (c2, .35, 1.0)
        elif k == 3: col = (c2, .7, 1.0)
        elif k == 4: col = (c2, 1.0, 1.0)
        elif 5 <= k <= 6: col = (c1, 1.0, 1.0)
        elif 7 <= k <= 8: col = (c0, 1.0, 1.0)
        if col:
            i, sy, a = col; cv.tex(T(i), 0, 0, i.shape[1], i.shape[0]*sy, tmode(n), a)
        if k >= 9:
            j = k - 8; w = c0.shape[1]*(.62**j); a = 1.0 if j <= 2 else 1 - .15*(j-2)
            if a > 0 and w >= .7: cv.tex(T(c0), 0, 0, w, c0.shape[0], tmode(n), a)
        # impact bursts in front, on the floor
        if k == 0: cv.tex(T(dome), 0, 0, dome.shape[1], dome.shape[0], tmode(n))
        if k == 1: cv.tex(T(spike), 0, 0, spike.shape[1], spike.shape[0], tmode(n))
        if 2 <= k <= 4:
            cv.tex(T(burst), 0, 0, burst.shape[1], burst.shape[0], tmode(n), [1, .7, .4][k-2])
        frames.append(cv.frame())
    return frames, PRE

# ---------------------------------------------------------------- V4: boss: ring of beams converging -> skull pillar (cut, posterized)
CS = SPEC + '/cut/skull'
def V4(n=5, mon='cac05', R=58, nb=6):
    m = monster(mon); cols = tier(n)[1]
    sk = [cut_idx(f'{CS}/s{i:02d}.png', .9) for i in range(19)]
    for i in (2, 3, 4): sk[i] = cap(sk[i], 30)       # sheet frames are cut flat at the top: give them our stepped top
    for i in (16, 17, 18):                             # keep only the main body (neighbour frames bleed into these boxes)
        lab, nl = nd.label(sk[i] > 0)
        if nl > 1:
            sizes = nd.sum(sk[i] > 0, lab, range(1, nl+1)); keep = 1 + int(np.argmax(sizes))
            sk[i][lab != keep] = 0
    global V4_TEX; V4_TEX = sk
    seq = []                                       # (frame idx, tics)
    seq += [(i, 2) for i in range(0, 5)] + [(i, 1) for i in range(5, 16)] + [(i, 2) for i in range(16, 19)] + [(18, 2)]
    plan = []
    for i, d in seq: plan += [i]*d
    MERGE = 12
    S = eos_scales()[:4]                   # growth tics only; satellites hold until the merge
    frames = []
    T_ = MERGE + len(plan) + 4
    for t in range(PRE + T_ + POST):
        cv = Canvas(Wu=240, Hu=240, floor=196); k = t - PRE
        sats = []
        for b in range(nb):
            k0 = b                                  # staggered spawn, 1 tic apart around the ring
            j = k - k0
            if j < 0 or k >= MERGE + 1: continue
            ang = math.radians(120 + b*360/nb)
            r = R if k < 7 else R*max(0, 1 - (k-6)/(MERGE-6))
            sc = S[min(j, 3)]
            sats.append((math.sin(ang), r*math.cos(ang), r*math.sin(ang)*.22, sc, j))
        sats.sort()
        back = [s for s in sats if s[0] > 0]; front = [s for s in sats if s[0] <= 0]
        def draw_sats(L):
            for _, x, zo, sc, j in L:
                draw_eos_beam(cv, j, x, n, sc, hmul=.75, z=zo, glow=False)
        # floor glow of the ring
        if 0 <= k <= MERGE:
            rr = R if k < 7 else R*max(0, 1 - (k-6)/(MERGE-6))
            cv.unit_layer(ellipse_layer(cv, 0, rr + 8, scaled(cols[3], .8), ring=3), 'add')
        draw_sats(back)
        # skull pillar sequence at centre
        p = k - MERGE
        if 0 <= p < len(plan):
            i = plan[p]
            if p < 6: floor_glow(cv, 0, [44, 28], [scaled(cols[3], .9), scaled(cols[2], .6)])
            elif p < 24: floor_glow(cv, 0, [38, 22], [scaled(cols[3], .8), scaled(cols[2], .5)])
        # caco: silhouette as the pillar forms, then real
        if MERGE + 5 <= k <= MERGE + 8: cv.sprite(m, 0, 4, sil=(255, 255, 255))
        elif k == MERGE + 9: cv.sprite(m, 0, 4, sil=cols[1])
        elif k > MERGE + 9: cv.sprite(m, 0, 4)
        if 0 <= p < len(plan):
            i = plan[p]; left = len(plan) - p; a = 1.0 if left > 3 else left/4
            tex = sk[i]; cv.tex(colorize(tex, n), 0, -4, tex.shape[1], tex.shape[0], tmode(n), a)
        draw_sats(front)
        if k == MERGE:                              # merge flash
            cv.tex(colorize(BEAM[0], n), 0, 0, 80, 10, tmode(n))
        frames.append(cv.frame())
    return frames, PRE
