#!/usr/bin/env python3
"""TUNING ONLY (never ships). The 11-02 rebuilt thong in Python (numpy): XPBD sub-steps, the MIT reference whip's
bend springs and dampers (whip-project-targeting, BSD-3) scaled to room units and tics, the critically damped hand
follower and the wind-up guide -- the prototype the ZScript (zscript/rsqwp/whip.zs Sim) was written from. No walls
(a flat floor at 0), no Collide/Mend. tools/whipsim.py is the OLD model (Verlet, taper, regime damping).

    python3 tools/whipsim_xpbd.py "{}" "{'mot':'k3','taper':0,'root':1}" ...   one case per argument
keys: S IT omega drag vmax gw gtip taper(1 = the old lighter-toward-the-tip mass; 0 default, as shipped) root(1 default, as shipped) bend damp
      mot (swing k3 k4 k5 sway idle) noise(1) delib(False) floor(None)
"""
import math, sys, ast
import numpy as np

M = 34.0; TIC = 35.0
L_REF, M_REF, K_REF, C_REF = 0.072, 0.012, 0.242, 0.092
EI = K_REF * L_REF; CL = C_REF * L_REF; LAM = M_REF / L_REF
EI_R = EI * M ** 3 / TIC ** 2; CL_R = CL * M ** 3 / TIC; LAM_R = LAM / M; G_R = 9.81 * M / TIC ** 2
NN = 20; HANDLEN = 8.0
SWING = [(0, 0.20, 1.30, -0.30, 20, 0), (14, 0.24, 1.78, 0.08, 150, 0), (20, 0.24, 1.80, 0.10, 155, 0),
         (23, 0.22, 1.60, -0.35, 60, 0), (25, 0.20, 1.40, -0.55, 0, 0), (34, 0.20, 1.35, -0.50, 10, 0), (60, 0.20, 1.30, -0.30, 20, 0)]
K3 = [(0, 0.20, 1.35, -0.35, 10, 0), (9, 0.22, 1.80, -0.05, 85, 0), (12, 0.22, 1.82, -0.02, 95, 0),
      (15, 0.20, 1.40, -0.50, -15, 0), (22, 0.20, 1.30, -0.45, -20, 0), (70, 0.20, 1.35, -0.35, 10, 0)]
K5 = [(0, 0.45, 1.30, -0.10, 0, -60), (8, 0.55, 1.35, 0.10, 5, -110), (11, 0.20, 1.35, -0.50, 0, 30), (16, 0.05, 1.30, -0.45, -5, 50), (70, 0.45, 1.30, -0.10, 0, -60)]
K4 = [(0, 0.20, 1.40, -0.40, 35, 0), (6, 0.20, 1.42, -0.40, 60, 0), (8, 0.20, 1.38, -0.42, -30, 0),
      (14, 0.20, 1.38, -0.42, -30, 0), (50, 0.20, 1.40, -0.40, 35, 0)]
SWAY = [(t, 0.20, 1.35, -0.40, 5, 40 * math.sin(t * 2 * math.pi / 140)) for t in range(0, 141, 5)]


def key(t, ks):
    if t <= ks[0][0]: return ks[0][1:]
    for a, b in zip(ks, ks[1:]):
        if a[0] <= t <= b[0]:
            u = (t - a[0]) / (b[0] - a[0]) if b[0] > a[0] else 0
            return tuple(a[i] + (b[i] - a[i]) * u for i in range(1, 6))
    return ks[-1][1:]


def pose(p):
    x, y, z, pi, yw = p
    pos = np.array([x * M, y * M, -z * M])
    pr, yr = math.radians(pi), math.radians(yw)
    d = np.array([-math.cos(pr) * math.sin(yr), math.sin(pr), math.cos(pr) * math.cos(yr)])
    return pos, d / np.linalg.norm(d)


class Whip:
    def __init__(s, S=16, IT=2, wlen=128.0, omega=2.5, drag=1 / 35., vmax=150., gw=1.5, gtip=0.75, taper=0, bend=1.0, damp=1.0, floor=None, zeta=1.0, root=1.0):
        s.S, s.IT, s.wlen, s.om, s.drag, s.vmax, s.gw, s.gtip = S, IT, wlen, omega, drag, vmax, gw, gtip
        s.seg = wlen / NN
        u = np.arange(NN + 1) / NN
        rel = 1.0 / (1.0 / ((1 - 0.85 * u) ** 2.5 + 0.02)) if taper else np.ones(NN + 1)
        rel = rel / rel[1:].mean()                       # the same total mass as the uniform thong
        s.m = LAM_R * s.seg * rel
        s.w = 1.0 / s.m; s.w[0] = 0.0
        s.kp = bend * EI_R / s.seg ** 3
        s.beta = damp * CL_R / s.seg ** 3
        s.stiff = 0.0; s.floor = floor; s.zeta = zeta; s.root = root

    def start(s, b, d):
        tip = b + d * HANDLEN
        s.p = np.array([tip + np.array([0, -s.seg * k, 0]) for k in range(NN + 1)])
        if s.floor is not None: s.p[:, 1] = np.maximum(s.p[:, 1], s.floor)
        s.q = s.p.copy()
        s.fb, s.fv, s.fd, s.fdv = b.copy(), np.zeros(3), d.copy(), np.zeros(3)
        s.rb, s.rd = b.copy(), d.copy()
        s.pa, s.pd = tip, d.copy()

    def tic(s, b, d):
        S = s.S; h = 1.0 / S; best = 0; seg = s.seg; w = s.w
        al = 1.0 / s.kp; alt = al / (h * h); gam = al * s.beta / h
        for st in range(1, S + 1):
            u = st / S
            tb = s.rb + (b - s.rb) * u; td = s.rd + (d - s.rd) * u
            if s.om > 0:
                a = s.om * s.om * (tb - s.fb) - 2 * s.om * s.fv; s.fv = s.fv + a * h; s.fb = s.fb + s.fv * h
                a = s.om * s.om * (td - s.fd) - 2 * s.om * s.fdv; s.fdv = s.fdv + a * h; s.fd = s.fd + s.fdv * h
            else:
                s.fb, s.fd = tb, td
            dn = s.fd / np.linalg.norm(s.fd)
            anchor = s.fb + dn * HANDLEN
            v = (s.p[1:] - s.q[1:]) * (1 - s.drag * h)
            vl = np.linalg.norm(v, axis=1); cap = s.vmax * h; over = vl > cap
            v[over] *= (cap / vl[over])[:, None]
            s.q = s.p.copy()
            s.p[1:] = s.p[1:] + v + np.array([0, -G_R * h * h, 0])
            s.p[0] = anchor
            # the wind-up's rod: each link drawn to the line out of the handle, XPBD with stiffness m * (gw * stiff)^2
            if s.stiff > 0.001:
                for k in range(1, NN + 1):
                    om = s.gw * s.stiff * (1 - s.gtip * k / NN)
                    want = anchor + dn * (seg * k)
                    wq_ = s.pa + s.pd * (seg * k)
                    C = s.p[k] - want
                    dC = (s.p[k] - s.q[k]) - (want - wq_)
                    oh = om * h
                    g = 2 * s.zeta / oh if oh > 0 else 0          # critical damping relative to the moving line
                    s.p[k] += (-C - g * dC) * (oh * oh) / (1 + (1 + g) * oh * oh)
            s.pa, s.pd = anchor, dn
            # bend at joints 1..NN-1 (the handle joint is free, as the reference's first joint)
            if s.root > 0:
                # the handle joint: the thong is set into the handle (a virtual node one link back up the handle, fixed)
                ar = al / s.root; art = ar / (h * h); gr = ar * s.beta / h
                pv = anchor - dn * seg; qv = s.pa - s.pd * seg
                C = s.p[1] - 2 * s.p[0] + pv
                dC = (s.p[1] - s.q[1]) - 2 * (s.p[0] - s.pa) + (pv - qv)
                dl = (-C - gr * dC) / ((1 + gr) * w[1] + art)
                s.p[1] += w[1] * dl
            for j in range(1, NN):
                C = s.p[j + 1] - 2 * s.p[j] + s.p[j - 1]
                dC = (s.p[j + 1] - s.q[j + 1]) - 2 * (s.p[j] - s.q[j]) + (s.p[j - 1] - s.q[j - 1])
                W = w[j - 1] + 4 * w[j] + w[j + 1]
                dl = (-C - gam * dC) / ((1 + gam) * W + alt)
                s.p[j - 1] += w[j - 1] * dl; s.p[j] -= 2 * w[j] * dl; s.p[j + 1] += w[j + 1] * dl
            for it in range(s.IT):
                for k in range(NN):
                    dd = s.p[k + 1] - s.p[k]; l = np.linalg.norm(dd)
                    if l < 1e-6: continue
                    corr = dd * ((l - seg) / l / (w[k] + w[k + 1]))
                    s.p[k] += corr * w[k]; s.p[k + 1] -= corr * w[k + 1]
            if s.floor is not None:
                low = s.p[:, 1] < s.floor
                low[0] = False
                if low.any():
                    s.p[low, 1] = s.floor
                    s.q[low, 0] = s.p[low, 0] - (s.p[low, 0] - s.q[low, 0]) * 0.6 ** (1.0 / S)
                    s.q[low, 2] = s.p[low, 2] - (s.p[low, 2] - s.q[low, 2]) * 0.6 ** (1.0 / S)
            sp = np.linalg.norm(s.p[NN] - s.q[NN]) * S
            best = max(best, sp)
        s.rb, s.rd = b.copy(), d.copy()
        lerr = max(abs(np.linalg.norm(s.p[k + 1] - s.p[k]) - seg) / seg for k in range(NN))
        return best, lerr


class Delib:
    def __init__(s): s.wt = 0; s.we = -100; s.sw = False; s.rel = False; s.pk = 0; s.stiff = 0
    def step(s, t, b, d, hs, ramp=0.12):
        wound = d[1] >= 0.45 and d[2] <= 0.35 and b[1] >= 1.4 * M
        if wound:
            s.wt += 1; s.we = t; s.sw = False; s.rel = False; s.pk = 0
            if s.wt >= 2: s.stiff = min(1, s.stiff + ramp)
            return s.stiff
        was = s.wt >= 2; s.wt = 0
        if not s.sw and not s.rel and s.stiff > 0.01 and t - s.we <= 10 and hs >= 2.5:
            s.sw = True; s.pk = hs
        if s.sw:
            s.pk = max(s.pk, hs); s.stiff = min(1, s.stiff + 0.25)
            if hs < s.pk * 0.55: s.sw = False; s.rel = True; s.stiff = 0.3
            return s.stiff
        s.stiff = max(0, s.stiff - (0.08 if (was or t - s.we <= 10) else 0.3))
        return s.stiff


def run(motion, T=200, delib=True, noise=0, **kw):
    rnd = np.random.default_rng(7)
    w = Whip(**kw)
    b, d = pose(key(0, motion)); w.start(b, d)
    D = Delib(); out = []; pb, pd = b, d
    for t in range(T):
        p = list(key(t, motion))
        if noise: p = [p[c] + rnd.normal(0, [0.005, 0.005, 0.005, 1.5, 1.5][c]) for c in range(5)]
        b, d = pose(p)
        hs = np.linalg.norm((b + d * HANDLEN) - (pb + pd * HANDLEN)); pb, pd = b, d
        if delib: w.stiff = D.step(t, b, d, hs)
        out.append(w.tic(b, d) + (w.p[NN].copy(), w.stiff))
    return out


def summary(kw, r, lo=0, hi=None):
    r = r[lo:hi]
    tsp = [x[0] for x in r]
    pk = [(t + lo, round(tsp[t])) for t in range(1, len(tsp) - 1) if tsp[t] > 8 and tsp[t] >= tsp[t - 1] and tsp[t] > tsp[t + 1]]
    tip = [x[2] for x in r]
    v = [tip[k] - tip[k - 1] for k in range(1, len(tip))]
    fl = sum(1 for k in range(1, len(v)) if np.linalg.norm(v[k]) > 0.5 and np.linalg.norm(v[k - 1]) > 0.5 and v[k] @ v[k - 1] < 0)
    return '%s max %.1f lerr %.2f%% flips %d peaks %s' % (kw, max(tsp), 100 * max(x[1] for x in r), fl, pk[:6])


if __name__ == '__main__':
    cases = [ast.literal_eval(a) for a in sys.argv[1:]] or [dict()]
    ks = [(k[0] + 60,) + k[1:] for k in SWING]
    for kw in cases:
        mot = kw.pop('mot', 'swing')
        noise = kw.pop('noise', 0); dl = kw.pop('delib', True)
        motion = {'swing': ks, 'k3': [(k[0] + 60,) + k[1:] for k in K3], 'k4': [(k[0] + 60,) + k[1:] for k in K4], 'k5': [(k[0] + 60,) + k[1:] for k in K5], 'sway': SWAY, 'idle': [(0,) + SWING[0][1:]]}[mot]
        fl = kw.pop('floor', 0.0); r = run(motion, 140, noise=noise, floor=fl, delib=dl, **kw)
        print(mot, 'noise' if noise else '', summary(kw, r, 20))
