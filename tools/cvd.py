#!/usr/bin/env python3
"""cvd.py -- colour-vision-deficiency simulation and distinguishability for the series' cues.

Simulation: Machado, Oliveira & Fernandes 2009, severity 1.0 (protanopia, deuteranopia,
tritanopia), applied in linear sRGB; Vienot, Brettel & Mollon 1999 as a second opinion for
protan/deutan. Distance: CIEDE2000 between the simulated colours (>= 20 reads as a different
colour at a glance; < 10 is a lookalike) and the WCAG relative-luminance ratio (brightness cue).

  python3 tools/cvd.py pair FFB030 40FF70          # one pair, every vision
  python3 tools/cvd.py set FFB030 40FF70 6080FF    # minimum pairwise distance in a set
  python3 tools/cvd.py frame a.png x0 y0 x1 y1 b.png x0 y0 x1 y1   # mean cue colour of two
        rendered regions (pixels brighter than the region's median), then 'pair' on them
As a module: sim(rgb, kind), de2000(a, b), lum(rgb), report(a, b).
"""
import sys, math

MACHADO = {
    'protan': ((0.152286, 1.052583, -0.204868), (0.114503, 0.786281, 0.099216), (-0.003882, -0.048116, 1.051998)),
    'deutan': ((0.367322, 0.860646, -0.227968), (0.280085, 0.672501, 0.047413), (-0.011820, 0.042940, 0.968881)),
    'tritan': ((1.255528, -0.076749, -0.178779), (-0.078411, 0.930809, 0.147602), (0.004733, 0.691367, 0.303900)),
}
VIENOT = {
    'protan_v': ((0.11238, 0.88762, 0.0), (0.11238, 0.88762, 0.0), (0.00401, -0.00401, 1.0)),
    'deutan_v': ((0.29275, 0.70725, 0.0), (0.29275, 0.70725, 0.0), (-0.02234, 0.02234, 1.0)),
}
KINDS = ['normal', 'protan', 'deutan', 'tritan', 'protan_v', 'deutan_v']

def hexrgb(s):
    s = s.strip().lstrip('#').replace(' ', '')
    if s.lower().startswith('0x'): s = s[2:]
    v = int(s, 16)
    return ((v >> 16) & 255, (v >> 8) & 255, v & 255)

def lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def unlin(c):
    c = max(0.0, min(1.0, c))
    return 255.0 * (12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055)

def sim(rgb, kind):
    if kind == 'normal': return tuple(float(x) for x in rgb)
    m = MACHADO.get(kind) or VIENOT[kind]
    l = [lin(x) for x in rgb]
    return tuple(unlin(sum(m[i][j] * l[j] for j in range(3))) for i in range(3))

def lab(rgb):
    r, g, b = (lin(x) for x in rgb)
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = (0.2126 * r + 0.7152 * g + 0.0722 * b)
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x), f(y), f(z)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))

def de2000(a, b):
    L1, a1, b1 = lab(a); L2, a2, b2 = lab(b)
    C1 = math.hypot(a1, b1); C2 = math.hypot(a2, b2); Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt(Cb ** 7 / (Cb ** 7 + 25 ** 7)))
    a1p, a2p = (1 + G) * a1, (1 + G) * a2
    C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1p = math.degrees(math.atan2(b1, a1p)) % 360; h2p = math.degrees(math.atan2(b2, a2p)) % 360
    dLp = L2 - L1; dCp = C2p - C1p
    dh = h2p - h1p
    if C1p * C2p == 0: dh = 0
    elif dh > 180: dh -= 360
    elif dh < -180: dh += 360
    dHp = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dh / 2))
    Lbp = (L1 + L2) / 2; Cbp = (C1p + C2p) / 2
    if C1p * C2p == 0: hbp = h1p + h2p
    elif abs(h1p - h2p) > 180: hbp = (h1p + h2p + 360) / 2 if h1p + h2p < 360 else (h1p + h2p - 360) / 2
    else: hbp = (h1p + h2p) / 2
    T = 1 - 0.17 * math.cos(math.radians(hbp - 30)) + 0.24 * math.cos(math.radians(2 * hbp)) \
        + 0.32 * math.cos(math.radians(3 * hbp + 6)) - 0.20 * math.cos(math.radians(4 * hbp - 63))
    dth = 30 * math.exp(-((hbp - 275) / 25) ** 2)
    Rc = 2 * math.sqrt(Cbp ** 7 / (Cbp ** 7 + 25 ** 7))
    Sl = 1 + 0.015 * (Lbp - 50) ** 2 / math.sqrt(20 + (Lbp - 50) ** 2)
    Sc = 1 + 0.045 * Cbp; Sh = 1 + 0.015 * Cbp * T
    Rt = -math.sin(math.radians(2 * dth)) * Rc
    return math.sqrt((dLp / Sl) ** 2 + (dCp / Sc) ** 2 + (dHp / Sh) ** 2 + Rt * (dCp / Sc) * (dHp / Sh))

def lum(rgb):
    r, g, b = (lin(x) for x in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def ratio(a, b):
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)

def report(a, b, kinds=KINDS):
    out = {}
    for k in kinds:
        sa, sb = sim(a, k), sim(b, k)
        out[k] = (de2000(sa, sb), ratio(sa, sb))
    return out

def fmt(rgb): return '%02X%02X%02X' % tuple(int(round(x)) for x in rgb)

def region_mean(path, x0, y0, x1, y1):
    from PIL import Image
    im = Image.open(path).convert('RGB').crop((x0, y0, x1, y1))
    px = list(im.getdata())
    lv = sorted(sum(p) for p in px)
    med = lv[len(lv) // 2]
    hi = [p for p in px if sum(p) > med + 30] or px
    return tuple(sum(p[i] for p in hi) / len(hi) for i in range(3))

def main(a):
    if not a: print(__doc__); return
    if a[0] == 'pair':
        x, y = hexrgb(a[1]), hexrgb(a[2])
        for k, (d, r) in report(x, y).items():
            print('%-9s %s vs %s  dE00 %5.1f  lum %4.2f:1' % (k, fmt(sim(x, k)), fmt(sim(y, k)), d, r))
    elif a[0] == 'set':
        cols = [hexrgb(s) for s in a[1:]]
        for k in KINDS:
            worst = min(((de2000(sim(cols[i], k), sim(cols[j], k)), a[1 + i], a[1 + j])
                         for i in range(len(cols)) for j in range(i + 1, len(cols))))
            print('%-9s min dE00 %5.1f (%s vs %s)' % (k, worst[0], worst[1], worst[2]))
    elif a[0] == 'frame':
        p = region_mean(a[1], *map(int, a[2:6])); q = region_mean(a[6], *map(int, a[7:11]))
        print('cue A', fmt(p), ' cue B', fmt(q))
        main(['pair', fmt(p), fmt(q)])

if __name__ == '__main__':
    main(sys.argv[1:])
