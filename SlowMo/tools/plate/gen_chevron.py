#!/usr/bin/env python3
"""RSQ SlowMo -- the turn arrows (owner 2026-11-07 05:56 / 05:58 / 07:12 / 07:15; design/NEAR_DEATH.md, the look and the
Triple Chevron's code in design/mockups/down_v3_full_view_mockup.html). Our own pixel art, nearest-neighbour (each cell
4x4 texels so the engine's filtering only softens cell edges). THE MOTION IS BAKED INTO THE FRAMES (owner 07:15: "motion
baked into animation frames on still panels"); the panel itself never moves or scales.

THE EDGE ARROWS (a target outside the view), one image a frame, 30 frames (0.857 s at 35 a second: the 0.85 s loop),
pointing RIGHT (the plate rolls the panel toward the way to turn). Four styles (Turn Marker):
  A Framed Triangle, B Framed Fat Arrow (the 24-cell shapes of 05:58: a 3-band bevel inside the shape), C Triple Chevron
  (the mockup's own: three 3-cell chevrons, each with its own momentum loop a beat 0.09 s behind the one in front... the
  mockup's motion() and stripes exactly), D Triangle With Afterimages (A, plus 4 fading ghosts during the push).
  A / B / D use the 05:58 momentum (wind-up back 2 px ~0.92 wide, a push of ~9 px ~1.22 wide with the fill flaring,
  overshoot / recoil, settle: the old plate.zs MarkerMotion), C the mockup's motion() at 0.6 (as its code).
  Three layers a frame, drawn over each other at run time:
    RSPM<s>Fff  the frame: the grey bevel (light #d4d8e0, mid #8d93a0, dark #3b404b) and black under the fill; as it is
    RSPM<s>Cff  the fill: white, alpha = brightness, drawn Shaded in the target's colour
    RSPM<s>Lff  the light: the light stripes and the flare, white, drawn AddShaded in a light tint of the target's colour
  The C stripes run diagonally and flow toward the point (the mockup: 14 cells a second; baked 10 a loop, 11.7 a second,
  so the loop closes).
THE WORLD TRAIL (owner 07:12: six chevrons fixed in the world at eye level, a brightness wave chasing toward the target):
  one chevron (the mockup's, 3 cells thick), 24 frames (0.69 s); the plate shows chevron i at frame (t - 3 i), so the wave
  runs from you to the target:  RSPTRF (the frame, static), RSPTCff (fill), RSPTLff (light).
Run: python3 SlowMo/tools/plate/gen_chevron.py"""
import os, math, glob
import numpy as np
from PIL import Image

MOD = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
G = os.path.join(MOD, 'graphics', 'rsqsmp'); os.makedirs(G, exist_ok=True)
LIGHT, MID, DARK = (0xd4, 0xd8, 0xe0), (0x8d, 0x93, 0xa0), (0x3b, 0x40, 0x4b)
CELL = 4
FR = 30

def save(arr, name):
    """arr: H x W x 4 floats (rgb 0..255, alpha 0..1), cells -> CELL x CELL texels"""
    a = np.clip(arr, 0, 255)
    img = np.zeros(arr.shape, dtype=np.uint8)
    img[..., :3] = np.clip(arr[..., :3], 0, 255).astype(np.uint8)
    img[..., 3] = np.clip(arr[..., 3] * 255 + 0.5, 0, 255).astype(np.uint8)
    im = Image.fromarray(img, 'RGBA').resize((arr.shape[1] * CELL, arr.shape[0] * CELL), Image.NEAREST)
    im.save(os.path.join(G, name + '.png'))

def put(layer, x, y, rgb, a):
    """composite one cell (over)"""
    H, W = layer.shape[:2]
    if not (0 <= x < W and 0 <= y < H) or a <= 0: return
    ba = layer[y, x, 3]
    na = a + ba * (1 - a)
    if na <= 0: return
    layer[y, x, :3] = (np.array(rgb, float) * a + layer[y, x, :3] * ba * (1 - a)) / na
    layer[y, x, 3] = na

# ---- C: the mockup's Triple Chevron --------------------------------------------------------------------------------
GW, GH = 30, 22
def mk(f): return [[1 if f(i, y - (GH - 1) / 2) else 0 for i in range(GW)] for y in range(GH)]
def dil(m):
    o = []
    for y in range(GH):
        row = []
        for i in range(GW):
            v = m[y][i]
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    yy, xx = y + dy, i + dx
                    if not v and 0 <= yy < GH and 0 <= xx < GW and m[yy][xx]: v = 1
            row.append(v)
        o.append(row)
    return o
def chev(c):
    M = mk(lambda i, y: abs(y) <= 6 and c - 2 <= i + abs(y) <= c)
    d1 = dil(M); d2 = dil(d1); d3 = dil(d2)
    return M, d1, d2, d3
CH = [chev(11), chev(18), chev(25)]
def motion_c(u):
    if u < .18: k = u / .18; return -2 * math.sin(k * math.pi / 2), 0
    if u < .34: k = (u - .18) / .16; return -2 + 9 * k * k, k * k
    if u < .5: k = (u - .34) / .16; return 7 - 2.5 * math.sin(k * math.pi / 2), 1 - k * .5
    if u < .75: k = (u - .5) / .25; return 4.5 - 5.5 * k, .5 - .5 * k
    return -1 + (u - .75) / .25, 0

def fill_cells(F, Cl, Ll, x, y, s, g, al):
    """one fill cell: the mockup's three stripe shades (s<2 light 85%, s<4 62+18g %, else 44+18g %), as brightness"""
    put(F, x, y, (0, 0, 0), al)
    if s < 2: put(Cl, x, y, (255, 255, 255), al); put(Ll, x, y, (255, 255, 255), al * 0.85)
    elif s < 4: put(Cl, x, y, (255, 255, 255), al); put(Ll, x, y, (255, 255, 255), al * 0.45 * g)
    else: put(Cl, x, y, (255, 255, 255), al * 0.72); put(Ll, x, y, (255, 255, 255), al * 0.45 * g)

def bake_c():
    PADX, PADY = 2, 1
    W, H = GW + 8, GH + 2 * PADY
    for f in range(FR):
        t = f / 35.0
        ph = (f * 10.0 / FR)
        F, Cl, Ll = (np.zeros((H, W, 4)) for _ in range(3))
        for j in range(3):
            u = ((t - j * .09) % (FR / 35.0)) / (FR / 35.0)
            dxm, g = motion_c(u)
            dx = int(round(dxm * .6))
            al = .35 + .65 * g
            M, d1, d2, d3 = CH[j]
            for y in range(GH):
                for i in range(GW):
                    x, yy = i + dx + PADX, y + PADY
                    if M[y][i]:
                        s = int(math.floor(i - y - ph)) % 10
                        fill_cells(F, Cl, Ll, x, yy, s, g, al)
                    elif d1[y][i]: put(F, x, yy, LIGHT, al)
                    elif d2[y][i]: put(F, x, yy, MID, al)
                    elif d3[y][i]: put(F, x, yy, DARK, al)
        save(F, 'RSPMCF%02d' % f); save(Cl, 'RSPMCC%02d' % f); save(Ll, 'RSPMCL%02d' % f)
    return W, H

# ---- A / B / D: the 05:58 shapes, 24 cells, bevel inside --------------------------------------------------------------
SW = SH = 24
def tri(x, y, inset):
    cx, cy = x + 0.5, y + 0.5
    if cx < 2 + inset: return False
    return abs(cy - 12) <= (21.5 - inset * 1.6 - cx) * (10.0 / 19.5)
def arrow(x, y, inset):
    cx, cy = x + 0.5, y + 0.5
    if cx >= 10 and abs(cy - 12) <= (22.0 - inset * 1.6 - cx) * (10.5 / 12.0): return True
    return 1 + inset <= cx < 11 and abs(cy - 12) <= 4.0 - inset    # the shaft
def bands(f):
    L = [{(x, y) for x in range(SW) for y in range(SH) if f(x, y, k)} for k in range(4)]
    L[1] &= L[0]; L[2] &= L[1]; L[3] &= L[2]
    return L
def motion_ab(t):
    """the 05:58 momentum (the old plate.zs MarkerMotion): offset (cells), width, flare; t in tics, 30 a loop"""
    p = (t % 30.0) / 30.0
    if p < 0.35: k = p / 0.35; k = k * k * (3 - 2 * k); return -2.0 * k, 1.0 - 0.08 * k, 1.0
    if p < 0.55: k = (p - 0.35) / 0.20; k = k * k; return -2.0 + 11.0 * k, 0.92 + 0.30 * k, 1.0 + 0.6 * k
    if p < 0.70: k = (p - 0.55) / 0.15; return 9.0 + 1.5 * math.sin(k * math.pi), 1.22 - 0.25 * k, 1.6 - 0.5 * k
    kk = (p - 0.70) / 0.30; kk = kk * kk * (3 - 2 * kk)
    return 9.0 * (1.0 - kk), 0.97 + 0.03 * kk, 1.1 - 0.1 * kk

def bake_ab(tag, f, ghosts):
    L0, L1, L2, L3 = bands(f)
    PADL, PADY = 12, 0
    W, H = PADL + int(SW * 1.25) + 14, SH
    cx0 = SW / 2.0
    def sample(o, wx):
        """cell (x, y) of the canvas -> shape cell, scaled about the shape's centre by wx, moved by o"""
        out = {}
        for X in range(W):
            sx = (X - PADL - o - cx0) / wx + cx0
            xi = int(math.floor(sx))
            if not (0 <= xi < SW): continue
            for y in range(SH): out[(X, y)] = (xi, y)
        return out
    for fr in range(FR):
        o, wx, fl = motion_ab(fr)
        g = min(1.0, max(0.0, (fl - 1.0) / 0.6))
        F, Cl, Ll = (np.zeros((H, W, 4)) for _ in range(3))
        if ghosts:
            phs = (fr % 30) / 30.0
            if 0.35 <= phs < 0.62:
                for gi, ga in ((4, .12), (3, .22), (2, .35), (1, .5)):
                    for (X, y), (xi, yi) in sample(o - gi * 2.2, wx).items():
                        if (xi, yi) in L0: put(Cl, X, y, (255, 255, 255), ga)
        band = -6 + 36.0 * fr / FR     # the light band sweeping across (the shimmer)
        for (X, y), (xi, yi) in sample(o, wx).items():
            c = (xi, yi)
            if c not in L0: continue
            if c not in L1: put(F, X, y, DARK, 1); continue
            if c not in L2: put(F, X, y, MID, 1); continue
            if c not in L3: put(F, X, y, LIGHT, 1); continue
            put(F, X, y, (0, 0, 0), 1)
            a = 0.85 if ((xi + yi) // 2) % 2 == 0 else 0.6
            put(Cl, X, y, (255, 255, 255), min(1.0, a + 0.25 * g))
            lb = 0.8 if abs((xi + (SH - yi)) * 0.5 - band) < 2.5 else 0.0
            put(Ll, X, y, (255, 255, 255), max(lb, 0.5 * g))
        save(F, 'RSPM%sF%02d' % (tag, fr)); save(Cl, 'RSPM%sC%02d' % (tag, fr)); save(Ll, 'RSPM%sL%02d' % (tag, fr))
    return W, H

# ---- the world trail's chevron ---------------------------------------------------------------------------------------
def bake_trail():
    c = 11
    M, d1, d2, d3 = chev(c)
    x0, x1 = 0, 15     # the columns it uses (c - 8 - 3 .. c + 3)
    W, H = 16, GH
    TF = 24
    F = np.zeros((H, W, 4))
    for y in range(GH):
        for i in range(x0, x1 + 1):
            X = i - x0 + 0
            if M[y][i]: put(F, X, y, (0, 0, 0), 1)
            elif d1[y][i]: put(F, X, y, LIGHT, 1)
            elif d2[y][i]: put(F, X, y, MID, 1)
            elif d3[y][i]: put(F, X, y, DARK, 1)
    save(F, 'RSPTRF')
    for f in range(TF):
        # the wave: one bright pulse a loop (a quick rise, a slower fall), at least 0.4 bright between
        p = f / TF
        g = math.exp(-((p - 0.25) / 0.12) ** 2) + math.exp(-((p - 1.25) / 0.12) ** 2)
        ph = f * 10.0 / TF
        Cl, Ll = np.zeros((H, W, 4)), np.zeros((H, W, 4))
        for y in range(GH):
            for i in range(x0, x1 + 1):
                if not M[y][i]: continue
                X = i - x0
                s = int(math.floor(i - y - ph)) % 10
                base = 1.0 if s < 4 else 0.72
                put(Cl, X, y, (255, 255, 255), (0.42 + 0.58 * g) * base)
                put(Ll, X, y, (255, 255, 255), 0.85 * (0.35 + 0.65 * g) if s < 2 else 0.5 * g)
        save(Cl, 'RSPTC%02d' % f); save(Ll, 'RSPTL%02d' % f)
    return W, H

for old in glob.glob(os.path.join(G, 'RSPM[ABC][F0-3].png')):
    os.remove(old)
print('C', bake_c())
print('A', bake_ab('A', tri, False))
print('B', bake_ab('B', arrow, False))
print('D', bake_ab('D', tri, True))
print('trail', bake_trail())
print('ok')
