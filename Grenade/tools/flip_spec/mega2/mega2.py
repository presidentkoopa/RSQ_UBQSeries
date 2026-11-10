"""MEGA2 blast: the NON-MUSHROOM 'huge explosion' rebuilt from our own / licensable material only (no Metal Slug pixels).
Beat structure: barrel blink -> white punch -> a wide fire mass swells off the floor -> it heaves up into a tall boiling
BLOCK (no stem, no cap) that keeps re-igniting inside -> the block darkens to brown smoke with red fire veins ->
its underside thins and the block lifts a little, raining grit and soot -> it breaks up and the dust settles.

Sources (read-only):
  Reactorcore minipack (CC0 per author's page comment): rc_ybrown = 'explosion (4)', rc_red, rc_grey, rc_ring, rc_x7
  Rufaswan rips / Magma MK-II sheet ('credits not necessary', credited anyway): rf_yring, rf_firering, ruf_dome, ruf_dust,
      ruf_yflash, yellow puff cells and light streak cut from fx_sheet_rufaswan_magma.png
  RS Combat FX (owner's): RSS0A0-D0 pixel embers; barrel voxel BAR1A.kvx
  Drawn in code (ours): block silhouette (backing lumps), boil rim bands, fire veins, dust fall, debris bits.
Library code COPIED from /tmp/fx_mega/lib. Metal Slug material was looked at for silhouette/timing only; nothing read in.
Pixel art only: every sprite nearest-neighbour at whole-number scales; light in flat bands; hard alpha in the mass."""
import sys, glob, math, random
sys.path.insert(0, '/tmp/fx_mega2/lib')
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
import fx, assets as A
from fx import Layer
from debris_v3 import Debris as _D, SHAPES

CW, CH, FY, BX = 440, 440, 382, 220
fx.CW, fx.CH, fx.FY, fx.BX = CW, CH, FY, BX
PX = fx.PX
U = lambda u: u * PX
BC = BX + 0.5
T0 = 20
END = T0 + 88                      # 108 frames

def cut(k):
    p = ('/tmp/eosfr/' if k.startswith(('rf_', 'rc_ring', 'rc_red', 'rc_grey')) else '/tmp/fx_agentB/cut/') + k
    return [A.rgba(f) for f in sorted(glob.glob(p + '/*.png'))]
YRING, FIRERING, RCRING, RCRED, RCGREY = cut('rf_yring'), cut('rf_firering'), cut('rc_ring'), cut('rc_red'), cut('rc_grey')
YB, X7, DOME, DUST, YFLASH = cut('rc_ybrown'), cut('rc_x7'), cut('ruf_dome'), cut('ruf_dust'), cut('ruf_yflash')
YPUFF = A.ruf_cells(369, 424, [0, 22, 52, 100, 152, 206, 257, 307, 365])
_r = A.ruf()
STREAK = A.clean(Image.fromarray(_r[280:297, 414:457].copy()), 3)

# ---------- recolour to flat bands (hard alpha) ----------
UMBER = [(36, 26, 24), (56, 40, 32), (78, 56, 42), (100, 74, 56)]          # our smoke: warm umber, 4 flat bands
REDUMB = [(48, 24, 22), (76, 36, 28), (104, 52, 34), (132, 74, 46)]          # red smoke browned down
ASH = [(40, 36, 34), (62, 56, 50), (86, 78, 68), (112, 102, 88)]             # grey-brown ash for the floor skirt
def posterize(frames, pal, lo=None, hi=None):
    arrs = [np.array(f).astype(float) for f in frames]
    lum = [0.3 * a[..., 0] + 0.59 * a[..., 1] + 0.11 * a[..., 2] for a in arrs]
    if lo is None:
        v = np.concatenate([l[a[..., 3] > 0] for l, a in zip(lum, arrs) if (a[..., 3] > 0).any()])
        lo, hi = np.percentile(v, 3), np.percentile(v, 97)
    out = []
    for l, a in zip(lum, arrs):
        k = np.clip(((l - lo) / max(1, hi - lo) * len(pal)).astype(int), 0, len(pal) - 1)
        o = np.zeros(a.shape, np.uint8); o[..., :3] = np.array(pal)[k]; o[..., 3] = np.where(a[..., 3] > 100, 255, 0)
        out.append(Image.fromarray(o))
    return out
def no_pupils(frames, pal):
    """interior pixels in the darkest band lifted one band (keeps the dark outline, drops the dot-holes)"""
    out = []
    for f in frames:
        a = np.array(f).copy(); m = ndi.binary_erosion(a[..., 3] > 0, iterations=2)
        dk = (a[..., :3] == np.array(pal[0])).all(-1) & m
        a[dk, :3] = pal[1]; out.append(Image.fromarray(a))
    return out
SMOKE = no_pupils(posterize(RCGREY, UMBER), UMBER)
RSMOKE = posterize(RCRED, REDUMB)
ASHS = no_pupils(posterize(RCGREY, ASH), ASH)
def solid(im, col=(255, 255, 255)):
    a = np.array(im).copy(); a[..., :3] = col; a[..., 3] = np.where(a[..., 3] > 0, 255, 0); return Image.fromarray(a)
def hard(im):
    a = np.array(im).copy(); a[..., 3] = np.where(a[..., 3] > 100, 255, 0); return Image.fromarray(a)
def strip(frames, tics):
    tl = tics if isinstance(tics, list) else [tics] * len(frames); return list(zip(frames, tl))
def ease(t, a, b, v0, v1, p=2.0):
    k = min(1, max(0, (t - a) / (b - a))); k = 1 - (1 - k) ** p; return v0 + (v1 - v0) * k

# ---------- the block: height, half-width and lift over time (px) ----------
def blk_h(t):                       # height of the mass above its base
    tt = t - T0
    return ease(tt, 2, 8, 24, 100, 2.2) + ease(tt, 8, 20, 0, 108, 1.6) + ease(tt, 22, 46, 0, 14, 1.0)
def blk_w(t):                       # half-width of the mass at its base
    tt = t - T0
    return ease(tt, 2, 8, 34, 86, 2.4) + ease(tt, 8, 26, 0, 8, 1.2) - ease(tt, 50, 84, 0, 10, 1.0)
def lift(t):                        # the whole mass rises a little once it has burnt out underneath
    return ease(t - T0, 46, 86, 0, 40, 1.25)
def bpos(t, u, v):
    """block coords -> canvas: u in [-1,1] across, v in [0,1] up. Slightly narrower to the top, flat-ish shoulders."""
    hw = blk_w(t) * (1.0 + 0.10 * math.sin(math.pi * min(1, v * 1.3)) - 0.34 * v ** 3)   # bellied low, rounded shoulders
    return BC + u * hw, FY - 22 - lift(t) - v * blk_h(t)

class Puff:
    """one lump of the mass at block coords (u, v), or on the floor ('base', dx, dy).
    Life: fire strip -> rc_ybrown cooling frames -> umber smoke held (slow boil: drifts round a small orbit and rolls a
    quarter turn now and then) -> dissipating frames."""
    def __init__(s, place, start, fire, cool, die, scale=2, rot=0, flip=False, smoke=SMOKE, hold=(9, 10), z=0, orb=3.0, ph=0.0, roll=11):
        s.pl = place; s.start = start; s.fire = fire; s.cool = cool; s.die = die; s.sc = scale; s.rot = rot; s.flip = flip
        s.smoke = smoke; s.hold = hold; s.z = z; s.orb = orb; s.ph = ph; s.roll = roll
    def pos(s, t):
        a = 2 * math.pi * (t / 22.0) + s.ph; w = s.orb * min(1, max(0, (t - s.start) / 8))
        ox, oy = w * math.cos(a), 0.7 * w * math.sin(a)
        if s.pl[0] == 'base': return BC + s.pl[1] * (1 + ease(t - T0, 20, 70, 0, 0.12, 1.0)) + ox, FY + s.pl[2] + oy * 0.4
        x, y = bpos(t, s.pl[1], s.pl[2])
        y -= 0.06 * max(0, t - s.start) * (1 - s.pl[2])      # churn: low lumps creep up into the mass
        return x + ox, y + oy
    def frame(s, t):
        if t < s.start: return None
        dt = t - s.start
        if t < s.cool:
            acc = 0
            for im, d in s.fire:
                acc += d
                if dt < acc: return im, 'fire'
            return s.fire[-1][0], 'fire'
        if t < s.cool + 4: return (YB[10] if t < s.cool + 2 else YB[11]), 'cool'
        if t < s.die:
            k = s.hold[((t - s.cool) // 7 + s.rot) % len(s.hold)]
            return s.smoke[k], 'smoke'
        n = len(s.smoke); k = n - 5 + (t - s.die) // 3
        if k > n - 1: return None
        return s.smoke[k], 'smoke'
    def at(s, t):
        r = s.frame(t)
        if r is None: return None
        im, ph = r
        im = im.resize((im.width * s.sc, im.height * s.sc), Image.NEAREST)
        if s.flip: im = im.transpose(Image.FLIP_LEFT_RIGHT)
        rot = s.rot + (max(0, t - s.cool) // s.roll if ph == 'smoke' else 0)      # rolls a quarter turn every `roll` tics
        if rot % 4: im = im.rotate(90 * (rot % 4), expand=True)
        x, y = s.pos(t)
        return im, int(round(x - im.width / 2)), int(round(y - im.height / 2)), ph

FIRE_YB = strip(YB[4:10], [1, 1, 1, 2, 2, 3])          # white ball -> gold boil (rc_ybrown / explosion (4))
FIRE_YB2 = strip(YB[5:10], [1, 1, 2, 3, 3])
FIRE_RD = strip(RCRED[0:5], [1, 1, 2, 2, 3])           # red fire puff (rc_red)

def build_cloud(r):
    P = []
    # the mass: staggered rows of lumps filling a wide block; top row a low rounded crown of lumps (no cap, no stem)
    rows = 8
    for k in range(rows):
        v = 0.02 + k / (rows - 1) * 0.94
        n = 6 if k % 2 == 0 else 5
        if k == rows - 1: n = 4
        for i in range(n):
            u = -1 + 2 * (i + 0.5) / n if k % 2 == 0 else -0.86 + 1.72 * i / (n - 1)
            if k == rows - 1: u *= 0.78
            u += r.uniform(-0.05, 0.05) + (r.uniform(-0.04, 0.14) * (1 if u > 0 else -1) if abs(u) > 0.7 else 0)
            vv = v + r.uniform(-0.04, 0.04)
            if k == rows - 1: vv += r.choice([0.0, 0.05, 0.09]) * (1 - abs(u))   # crown: uneven heads of billow
            edge = abs(u) > 0.75 or k == rows - 1
            st = T0 + 3 + int(vv * 9) + int(abs(u) * 2) + r.randint(0, 1)
            d = math.hypot(u, (vv - 0.42) * 1.7)
            cool = T0 + 29 - int(d * 8) + r.randint(-2, 2)
            die = T0 + 44 + int(vv * 18) + r.randint(0, 4)
            sc = 3 if (r.random() < 0.3 and 0.15 < vv < 0.8 and abs(u) < 0.7) else 2
            red = r.random() < 0.38
            P.append(Puff(('blk', u, vv), st, FIRE_RD if red else FIRE_YB, cool, die, scale=sc, rot=r.randrange(4), flip=r.random() < .5,
                          smoke=RSMOKE if red else SMOKE, hold=(4, 5) if red else (9, 10), z=1 + (edge and r.random() < .5) + r.random(),
                          orb=r.uniform(1.5, 4.0), ph=r.uniform(0, 6.3), roll=r.choice([9, 11, 13])))
    # re-ignitions: fresh fireballs blooming inside the mass while it boils, each leaving its own lump of smoke
    for j in range(22):
        st = T0 + 9 + int(j * 1.2) + r.randint(0, 2)
        u, v = r.uniform(-0.75, 0.75), r.uniform(0.15, 0.9)
        cool = st + r.randint(7, 11)
        red = j % 3 == 2
        P.append(Puff(('blk', u, v), st, FIRE_RD if red else FIRE_YB2, cool, T0 + 46 + int(v * 16) + r.randint(0, 4),
                      scale=2 if j % 4 else 1, rot=r.randrange(4), flip=r.random() < .5, smoke=RSMOKE if red else SMOKE,
                      hold=(4, 5) if red else (9, 10), z=3 + r.random(), orb=r.uniform(1, 3), ph=r.uniform(0, 6.3)))
    # floor skirt: low ash rolls pushed out round the base (greyer than the mass)
    for sg in (-1, 1):
        for dx, dy, st in ((40, -12, 9), (70, -8, 10), (96, -12, 11), (118, -4, 12)):
            dx += r.randint(-4, 4)
            P.append(Puff(('base', sg * dx, dy), T0 + st, FIRE_YB[3:], T0 + st + 7, T0 + 36 + dx // 8 + r.randint(0, 4), rot=r.randrange(4),
                          flip=r.random() < .5, smoke=ASHS, hold=(6, 7), z=4, orb=1.5, ph=r.uniform(0, 6.3), roll=15))
    return sorted(P, key=lambda p: p.z)

# ---------- fire veins (drawn in code): hard 2px lines that flicker through the smoke ----------
VEIN_CORE, VEIN_HOT, VEIN_RED = (255, 214, 90), (255, 128, 24), (196, 40, 16)
def build_veins(r):
    V = []
    for i in range(44):
        u, v = r.uniform(-0.85, 0.85), r.uniform(0.08, 0.92)
        pts = []; ang = r.uniform(0, 2 * math.pi); px_, py_ = 0, 0
        for k in range(r.randint(8, 16)):
            pts.append((px_, py_))
            ang += r.choice([-0.8, -0.4, 0, 0, 0.4, 0.8])
            px_ += 2 * round(math.cos(ang)); py_ += 2 * round(math.sin(ang))
        on = r.randint(T0 + 20, T0 + 30); off = r.randint(T0 + 44, T0 + 58) + int(v * 8)
        V.append(dict(u=u, v=v, pts=pts, on=on, off=off, ph=r.randrange(5), per=r.choice([3, 4, 5])))
    return V
def draw_veins(c, mask, V, t):
    for v in V:
        if not (v['on'] <= t < v['off']): continue
        if (t + v['ph']) % v['per'] == 0: continue                      # flicker off one tic in per
        late = t > v['off'] - 6
        ox, oy = bpos(t, v['u'], v['v'])
        ox, oy = int(ox) // 2 * 2, int(oy) // 2 * 2
        n = len(v['pts'])
        for k, (px_, py_) in enumerate(v['pts']):
            x, y = ox + px_, oy + py_
            if not (0 <= x < CW - 1 and 0 <= y < CH - 1) or not mask[y, x]: continue
            mid = abs(k - n / 2) < n / 4
            col = VEIN_RED if late else (VEIN_CORE if (mid and (t + k) % 2 == 0) else VEIN_HOT if mid else VEIN_RED)
            c[y:y + 2, x:x + 2, :3] = np.array(col) / 255

class LCX(Layer):
    """Layer re-centred every tic on its drawn art so rolled/squashed art stays on the barrel line."""
    def __init__(s, *a, dx=0.0, **kw): super().__init__(*a, **kw); s.dx = dx
    def at(s, t):
        r = super().at(t)
        if r is None: return r
        img, ox, oy, al = r
        cols = np.array(img)[..., 3].astype(float).sum(0)
        if cols.sum() == 0: return r
        nz = np.nonzero(cols)[0]; bb = (nz.min() + nz.max() + 1) / 2
        want = BC + s.dx + s.vel[0] * (t - s.start) + (s.pos[0] - BX)
        return img, int(round(want - bb)), oy, al

class Debris(_D):
    def __init__(s, start, **kw): super().__init__(start, BC, FY, PX, cscale=1 / 255, **kw)
    def end(s): return s.start + s.len

class DustFall:
    """drawn in code: grit and soot specks dropping out of the mass's underside, slow (terminal speed), swaying a pixel,
    landing on the floor plane and settling; blink out at the end. 2px hard blocks, flat palette steps."""
    def __init__(s, start, tics, per, seed, until):
        r = random.Random(seed); s.p = []; s.until = until
        for k in range(tics):
            for j in range(per):
                s.p.append(dict(t0=start + k, xo=r.uniform(-1, 1), vy=r.uniform(2.0, 3.0), dy0=r.uniform(0.0, 0.5), sw=r.randrange(6),
                                shp=r.choice(['dot', 'dot', 'dot', 'bar', 'sq', 'vbar']), d=r.uniform(0, 26),
                                col=r.choice([(150, 124, 96), (120, 96, 74), (98, 80, 64), (176, 150, 116), (84, 66, 54)]),
                                out=until - r.randint(0, 4)))
    def draw(s, c, t):
        for p in s.p:
            dt = t - p['t0']
            if dt < 0 or t >= p['out'] or ((p['out'] - t) <= 3 and (p['out'] - t) % 2 == 0): continue
            x0, top = bpos(p['t0'], p['xo'] * 0.92, 0.12 + 0.1 * ease(p['t0'] - T0, 46, 70, 0, 1))
            y0 = top + p['dy0'] * (FY - top)
            land = FY + p['d']
            y = min(land, y0 + p['vy'] * dt + 0.1 * dt * dt)
            x = x0 + (x0 - BC) * 0.004 * dt + (1 if (dt // 4 + p['sw']) % 4 < 2 else -1) * (y < land)
            shp = np.array(SHAPES[p['shp']], bool); h, w = shp.shape
            col = np.array(p['col']) / 255 * (0.8 if y >= land else 1.0)
            ox, oy = int(x) // 2 * 2, int(y) // 2 * 2 - h * 2
            for yy in range(h):
                for xx in range(w):
                    if shp[yy, xx] and 0 <= ox + xx * 2 < CW - 1 and 0 <= oy + yy * 2 < CH - 1:
                        c[oy + yy * 2:oy + yy * 2 + 2, ox + xx * 2:ox + xx * 2 + 2] = col

POPK = [(1.0, 0.4), (0.8, 0.55), (0.7, 0.8)]
def pops(t, r, scale, y):
    a = r.randrange(360); out = []
    for i in range(3):
        out.append(Layer([(STREAK, 3)], t, (BX, y), scale=scale, rot=a, keyframes=POPK, alpha=0.85, fade=0.3, name=f'pop{i}'))
        a += r.randint(90, 130)
    return out

FIRE = [(255, 250, 215), (255, 222, 110), (255, 160, 40), (225, 92, 16), (170, 54, 16), (118, 44, 24), (84, 52, 42), (70, 60, 54)]
FIRE_HOLD = [(255, 236, 150), (255, 176, 50), (236, 108, 20), (190, 66, 14), (140, 48, 18), (104, 50, 32), (80, 62, 52)]
SHRAP = [(255, 200, 120), (196, 132, 70), (118, 110, 76), (90, 94, 68), (72, 78, 58), (60, 64, 50)]
GRIT = [(214, 198, 168), (164, 144, 116), (128, 112, 92), (104, 92, 78), (86, 76, 66)]
HOTGRIT = [(255, 236, 170), (255, 170, 60), (200, 90, 30), (130, 70, 40), (100, 84, 70), (86, 76, 66)]
SOOT = [(146, 108, 74), (112, 80, 56), (82, 58, 44), (66, 50, 40)]
def env(pts):
    return lambda t: float(np.interp(t, [p[0] for p in pts], [p[1] for p in pts], left=0, right=0))

def build():
    r = random.Random(1107)
    L, LB, FL = [], [], []
    L += fx.barrel_layers_eos(T0, idle=8)
    # t0: core ball on the floor (Rufaswan yellow flash ball), t1-2 its white silhouette, wider (the punch)
    core = hard(YFLASH[1])
    L += [Layer([(core, 1), (solid(core), 2)], T0, (BX, FY + 4), scale=3, squash=0.8, sxg=1.0, add=False, anchor='b', name='core punch')]
    L += [Layer(strip([hard(f) for f in YFLASH[2:6]], [1, 1, 2, 2]), T0 + 3, (BX, FY + 4), scale=3, squash=0.7, add=False, anchor='b', fade=0.6, name='core ring')]
    L += pops(T0, r, scale=4.6, y=FY - U(16))
    # floor ring 1 (rf_yring), fast and flat
    FL += [LCX(strip(YRING[1:], [1, 1, 1, 2, 2, 2, 3]), T0 + 1, (BX, FY + 1), size=150, squash=0.22, grow=1.9, fade=0.5, name='ring1 rf_yring')]
    # child bursts: rc_ring flash pair at the base corners (t3), rc_ybrown pair on the flanks (t4), one rc_x7 on the line (t5)
    for sg in (-1, 1):
        L += [LCX(strip(RCRING[4:], [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3]), T0 + 3, (BX, FY - U(14)), dx=sg * 76, scale=1, flip=sg > 0, fade=0.7, name='child rc_ring')]
        L += [LCX(strip(YB[5:14], [1, 1, 1, 2, 2, 2, 2, 2, 3]), T0 + 4, (BX, FY - U(50)), dx=sg * 60, scale=2, flip=sg > 0, add=False, name='child rc_ybrown')]
    L += [LCX(strip(X7[4:], [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3]), T0 + 5, (BX, FY - 70), scale=1, fade=0.7, name='child rc_x7')]
    # GROUND SWELL (t3): Rufaswan dome bursts heaving along the floor, a big one on the barrel and two flank ones a tic
    # later (whole-number scales only, square pixels) -> one wide low fire mass for the block to climb out of
    dome = [hard(f) for f in DOME[2:7]]
    L += [LCX(strip(dome, [2, 2, 2, 1, 2]), T0 + 3, (BX, FY + 3), scale=3, add=False, anchor='b', name='swell ruf_dome')]
    for sg in (-1, 1):
        L += [LCX(strip(dome[1:], [2, 2, 1, 2]), T0 + 4, (BX, FY + 3), dx=sg * 62, scale=2, flip=sg > 0, add=False, anchor='b', name='swell ruf_dome flank')]
    FL += [LCX(strip(posterize(DUST[3:], [(92, 78, 64), (128, 110, 88), (160, 140, 112)]), [3, 4, 5]), T0 + 9, (BX, FY + 2), size=210, squash=0.24, grow=1.1, fade=0.4, add=False, alpha=0.9, name='ring2 ruf_dust')]
    FL += [LCX(strip(YRING[3:], [1, 2, 2, 3, 3]), T0 + 9, (BX, FY + 1), size=180, squash=0.2, grow=1.3, fade=0.5, name='ring2b rf_yring')]
    FL += [LCX(strip(FIRERING[3:], [2, 2, 3, 3, 3, 4]), T0 + 28, (BX, FY + 1), size=210, squash=0.2, grow=0.5, fade=0.4, gain=0.8, name='ring3 rf_firering')]
    # CHAIN of pops crackling over the mass while it darkens: alternating sides, gold flashes then red glows (block coords)
    chain = [(13, -0.6, 0.55), (15, 0.7, 0.75), (17, -0.2, 0.9), (19, 0.4, 0.35), (21, -0.8, 0.25), (23, 0.15, 0.6),
             (25, 0.75, 0.45), (27, -0.5, 0.8), (29, 0.05, 0.2), (31, -0.3, 0.45), (33, 0.55, 0.85), (36, -0.7, 0.6),
             (39, 0.3, 0.3), (42, -0.1, 0.7)]
    for tt, u, v in chain:
        t = T0 + tt; x, y = bpos(t, u, v)
        if tt < 26:
            L += [LCX(strip(X7[5:13], [1, 1, 1, 2, 2, 2, 2, 2]), t, (BX, y), dx=x - BC, scale=1, fade=0.6, name=f'chain x7 t{tt}')]
        else:
            L += [LCX(strip(YB[6:12], [1, 1, 2, 2, 2, 2]), t, (BX, y), dx=x - BC, scale=1, add=False, name=f'chain yb t{tt}'),
                  LCX(strip(RCRED[2:7], [1, 2, 2, 2, 2]), t + 2, (BX, y), dx=x - BC, scale=1, gain=0.7, fade=0.4, name=f'chain red t{tt}')]
    S = [fx.PixSparks(T0 + 3, per=2, tics=7, seed=3, spread=40, vz=(10, 17), scale=2, vx=1.2),
         fx.PixSparks(T0 + 11, per=2, tics=6, seed=4, spread=70, vz=(6, 11), scale=2, vx=1.8),
         fx.PixSparks(T0 + 22, per=1, tics=10, seed=5, spread=60, vz=(14, 19), scale=2, vx=0.8)]
    B = [Debris(T0 + 2, n=26, seed=51, z0=(20, 60), x0=(40, 70), speed=(5, 9), spread=(35, 72), grav=1.0, bounce=(.32, .42), friction=.55,
                palettes=[(1, FIRE)], cool=(3, 4), shapes=('dot', 'bar', 'vbar', 'sq', 'sq', 'L'), hold=(14, 24), depth=(0, 22), spawn=.4, trail=1, exact=True, until=58),
         Debris(T0 + 3, n=12, seed=62, z0=(30, 70), x0=(50, 70), speed=(6, 9.5), spread=(40, 70), grav=1.05, bounce=(.22, .3), friction=.4,
                palettes=[(1, SHRAP)], cool=(3, 4), shapes=('slab', 'shard', 'tri', 'chunk'), hold=(24, 34), depth=(2, 24), spawn=.5, exact=True, until=66),
         Debris(T0 + 9, n=30, seed=801, z0=(1, 6), x0=(70, 100), speed=(2.5, 5.5), spread=(62, 84), grav=.8, bounce=(.15, .3), friction=.72,
                palettes=[(4, GRIT), (3, HOTGRIT)], cool=(4, 6), shapes=('dot', 'dot', 'bar', 'sq', 'vbar'), hold=(20, 34), depth=(0, 26), spawn=.34, exact=True, mirror_shape=True, until=50),
         Debris(T0 + 16, n=16, seed=71, z0=(170, 200), x0=(0, 40), speed=(4, 6.5), spread=(8, 30), grav=.9, bounce=(.3, .42), friction=.5,
                palettes=[(1, FIRE_HOLD)], cool=(5, 7), shapes=('bar', 'sq', 'vbar', 'L', 'sq'), hold=(12, 20), depth=(4, 26), spawn=1.0, trail=2, exact=True, until=56)]
    # DUST FALL: chunks drop out of the lifted mass slowly (low gravity) and settle, plus the drawn grit rain
    BF = [Debris(T0 + 48, n=16, seed=91, z0=(70, 120), x0=(10, 70), speed=(0.6, 1.4), spread=(40, 85), grav=.22, bounce=(.15, .25), friction=.5,
                 palettes=[(2, SOOT)], cool=(8, 10), shapes=('sq', 'L', 'chunk', 'bar', 'dot'), hold=(30, 40), depth=(6, 28), spawn=1.2, exact=True, until=END - T0 - 48 - 1)]
    D = [DustFall(T0 + 40, 30, 7, 7, END)]
    base = env([(T0 - 1, 0), (T0, 1.15), (T0 + 3, 0.95), (T0 + 9, 0.9), (T0 + 10, 1.1), (T0 + 13, 1.0), (T0 + 30, 0.6), (T0 + 46, 0.25), (T0 + 62, 0)])
    blink = {T0 - 10 + 4 * i: 0.22 for i in range(3)}; blink.update({T0 - 10 + 4 * i + 1: 0.22 for i in range(3)})
    light = lambda t: max(base(t), blink.get(t, 0))
    lcol = lambda t: np.array([1.0, 0.62, 0.26]) if t < T0 + 30 else np.array([1.0, 0.42, 0.16])
    return L, LB, FL, S, B, BF, D, light, lcol

def blit(c, img, ox, oy, a, add, gain=1.0, clip_floor=False):
    fx.blit(c, img, ox, oy, a, add, gain, occ=clip_floor)

BACK = {'fire': (170, 66, 18), 'cool': (100, 44, 24), 'smoke': (40, 29, 26)}
RIM = {'fire': (255, 214, 110), 'cool': (196, 104, 40), 'smoke': (92, 70, 54)}
def draw_cloud(c, P, V, t):
    """mass into its own RGBA buffer: backing lumps (drawn, flat, 2px grid), then the puffs (normal blend, hard alpha),
    then a drawn boil rim (one flat lighter band on the upper edge of every lump of the outline), then the fire veins
    inside the smoke (eroded mask). Composited opaque, clipped at the floor line."""
    buf = np.zeros((CH, CW, 4), np.float32)
    phase = np.zeros((CH // 2, CW // 2), np.int8) - 1
    shots = [(p, p.at(t)) for p in P]
    yy, xx = np.mgrid[0:CH:2, 0:CW:2]
    for p, s in shots:
        if s is None: continue
        im, ox, oy, ph = s
        if ph == 'smoke' and t >= p.die: continue
        R = min(im.width, im.height) * 0.36; cx, cy = ox + im.width / 2, oy + im.height / 2
        m = ((xx + 1 - cx) ** 2 + (yy + 1 - cy) ** 2) < R * R
        phase[m] = ('smoke', 'cool', 'fire').index(ph)
        m2 = np.repeat(np.repeat(m, 2, 0), 2, 1)
        buf[m2, :3] = np.array(BACK[ph]) / 255; buf[m2, 3] = 1
    for p, s in shots:
        if s is None: continue
        im, ox, oy, ph = s
        a = np.asarray(im).astype(np.float32) / 255
        x0, y0 = max(0, ox), max(0, oy); x1, y1 = min(CW, ox + im.width), min(CH, oy + im.height)
        if x1 <= x0 or y1 <= y0: continue
        sub = a[y0 - oy:y1 - oy, x0 - ox:x1 - ox]; al = sub[..., 3:4]
        buf[y0:y1, x0:x1, :3] = buf[y0:y1, x0:x1, :3] * (1 - al) + sub[..., :3] * al
        buf[y0:y1, x0:x1, 3:] = np.maximum(buf[y0:y1, x0:x1, 3:], al)
    # boil rim: on the 2px grid, cells of the mass whose cell 2 above is empty (the top edge of each outer lump)
    m = buf[::2, ::2, 3] > 0.5
    up = np.zeros_like(m); up[2:] = m[:-2]
    rim = m & ~up
    rim &= ndi.binary_erosion(m, structure=np.ones((1, 3)))          # not on the very side pixels
    for k, nm in enumerate(('smoke', 'cool', 'fire')):
        sel = rim & (phase == k)
        if sel.any():
            s2 = np.repeat(np.repeat(sel, 2, 0), 2, 1)
            buf[s2, :3] = np.array(RIM[nm]) / 255
    mask = ndi.binary_erosion(buf[..., 3] > 0.5, iterations=4)
    draw_veins(buf, mask, V, t)
    buf[FY + 2:] = 0
    al = buf[..., 3:4]
    c[:] = c * (1 - al) + buf[..., :3] * al

def render(tail=0):
    L, LB, FL, S, B, BF, D, light, lcol = build()
    r = random.Random(7); P = build_cloud(r); V = build_veins(random.Random(11))
    out = []
    for t in range(END + tail):
        c = np.zeros((CH, CW, 3), np.float32); c[:] = (0.035, 0.03, 0.04)
        c[FY:] = (0.07, 0.065, 0.07)
        Lt = light(t)
        if Lt > 0:
            yy, xx = np.mgrid[FY:CH, 0:CW]
            d = np.sqrt(((xx - BX) / 200) ** 2 + ((yy - FY) / 48) ** 2)
            band = np.select([d < 0.35, d < 0.7, d < 1.0], [0.55, 0.32, 0.14], 0)
            c[FY:] += band[..., None] * lcol(t) * min(Lt, 1.0)
            if Lt > 1.0: c[FY:] += (band >= 0.55)[..., None] * (Lt - 1.0) * 2.0
        c[FY:FY + 1] = np.maximum(c[FY:FY + 1], (0.32, 0.30, 0.30))
        for b in B: b.draw(c, t)
        draw_cloud(c, P, V, t)
        for l in L:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain, clip_floor=(l.name not in ('barrel',) and not l.name.startswith(('core', 'swell'))))
        for s in S: s.draw(c, t)
        for b in BF: b.draw(c, t)
        for d in D: d.draw(c, t)
        for l in FL:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain)
        out.append(Image.fromarray((np.clip(c, 0, 1) * 255).astype(np.uint8)))
    return out

def save(frames, path, slow=1):
    fr = [f.resize((CW * 2, CH * 2), Image.NEAREST).quantize(255, method=Image.MEDIANCUT, dither=Image.NONE) for f in frames]
    pat = [30, 30, 30, 30, 30, 30, 20] if slow == 1 else [60, 60, 60, 60, 60, 50, 50]
    fr[0].save(path, save_all=True, append_images=fr[1:], duration=[pat[i % 7] for i in range(len(fr))], loop=0, optimize=False, disposal=1)

KEY = [-12, -2, 0, 1, 3, 6, 9, 12, 16, 20, 24, 28, 32, 38, 44, 50, 56, 62, 70, 80]
BEAT = {-12: 'idle', -2: 'blink', 0: 'core', 1: 'white punch', 3: 'ground swell', 6: 'swell spreads', 9: 'mass heaves',
        12: 'block climbs', 16: 'block boils', 20: 'full block', 24: 'boil / re-ignite', 28: 'darkens + veins', 32: 'veins',
        38: 'brown block', 44: 'brown block', 50: 'underside thins', 56: 'LIFT + dust', 62: 'dust fall', 70: 'breaks up', 80: 'settled'}
def contact(frames, path):
    cols = 10; rows = (len(KEY) + cols - 1) // cols
    S = Image.new('RGB', (cols * CW, rows * (CH + 14)), (24, 22, 26)); d = ImageDraw.Draw(S)
    for i, k in enumerate(KEY):
        if T0 + k >= len(frames): continue
        x, y = (i % cols) * CW, (i // cols) * (CH + 14)
        S.paste(frames[T0 + k], (x, y + 14)); d.text((x + 4, y + 2), f'tic {k:+d}  {BEAT[k]}', fill=(255, 220, 90))
    S.save(path)

VS = [-2, 1, 6, 11, 16, 22, 30, 40, 50, 62, 74]
def versus(frames, path):
    # MS mockup frames as rendered for /tmp/fx_mega (its blast is also at frame 20); comparison picture only
    msf = [Image.open(f) for f in sorted(glob.glob('/tmp/fx_mega/look/ms/f*.png'))]
    S = Image.new('RGB', (len(VS) * CW, 2 * (CH + 16)), (24, 22, 26)); d = ImageDraw.Draw(S)
    for i, k in enumerate(VS):
        x = i * CW
        S.paste(frames[T0 + k], (x, 16)); d.text((x + 4, 3), f'OURS (MEGA2, no mushroom)  tic {k:+d}', fill=(120, 230, 140))
        j = min(len(msf) - 1, 20 + k)
        S.paste(msf[j], (x, CH + 32)); d.text((x + 4, CH + 19), f'MS mockup (reference, not shipping)  tic {k:+d}', fill=(240, 120, 110))
    S.save(path)

if __name__ == '__main__':
    fr = render(); O = '/tmp/fx_mega2/out'
    if '--look' in sys.argv:
        for i, f in enumerate(fr): f.save(f'/tmp/fx_mega2/look/f{i:03d}.png')
    if '--fast' not in sys.argv:
        save(fr, f'{O}/MEGA2_full.gif'); save(fr, f'{O}/MEGA2_half.gif', slow=2)
    contact(fr, f'{O}/MEGA2_contact.png'); versus(fr, f'{O}/MEGA2_vs_MS.png')
    print('frames', len(fr), 'blast at', T0)
