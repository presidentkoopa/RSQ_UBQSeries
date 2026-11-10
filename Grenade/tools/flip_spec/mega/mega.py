"""MEGA blast: a 'huge explosion' rebuilt from our own / licensable material only (no Metal Slug pixels).
Beat structure (shape + pacing): barrel blink -> white punch -> pillar climbs -> fireball mushrooms into a cap ->
dome slams the floor -> cloud darkens to brown with fire veins -> cloud lifts and breaks up -> dust falls and settles.

Sources (read-only):
  Reactorcore minipack (CC0 per author's page comment): rc_ybrown = 'explosion (4)', rc_red, rc_grey, rc_ring, rc_x7
  Rufaswan rips / Magma MK-II sheet ('credits not necessary', credited anyway): rf_yring, rf_firering, ruf_dome, ruf_dust,
      ruf_yflash, yellow puff cells and light streak cut from fx_sheet_rufaswan_magma.png
  RS Combat FX (owner's): RSS0A0-D0 pixel embers; barrel voxel BAR1A.kvx
  Drawn in code (ours): mushroom backing silhouette, fire veins, dust fall, debris bits.
Library code is COPIED into /tmp/fx_mega/lib (unmodified copies of /tmp/fx_mslug/lib = set A fx/assets/kvx/debris_v3).
Pixel art only: every sprite nearest-neighbour at whole-number scales where it carries the mass; light in flat bands."""
import sys, glob, math, random
sys.path.insert(0, '/tmp/fx_mega/lib')
import numpy as np
from PIL import Image, ImageDraw
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
    from scipy import ndimage as ndi
    out = []
    for f in frames:
        a = np.array(f).copy(); m = ndi.binary_erosion(a[..., 3] > 0, iterations=2)
        dk = (a[..., :3] == np.array(pal[0])).all(-1) & m
        a[dk, :3] = pal[1]; out.append(Image.fromarray(a))
    return out
SMOKE = no_pupils(posterize(RCGREY, UMBER), UMBER)
RSMOKE = posterize(RCRED, REDUMB)
def solid(im, col=(255, 255, 255)):
    a = np.array(im).copy(); a[..., :3] = col; a[..., 3] = np.where(a[..., 3] > 0, 255, 0); return Image.fromarray(a)
def hard(im):
    a = np.array(im).copy(); a[..., 3] = np.where(a[..., 3] > 100, 255, 0); return Image.fromarray(a)
def strip(frames, tics):
    tl = tics if isinstance(tics, list) else [tics] * len(frames); return list(zip(frames, tl))
def ease(t, a, b, v0, v1, p=2.0):
    k = min(1, max(0, (t - a) / (b - a))); k = 1 - (1 - k) ** p; return v0 + (v1 - v0) * k

# ---------- the cloud: anchor (cap centre height above the floor) over time ----------
def cap_h(t):
    tt = t - T0
    if tt < 4: return 30
    if tt < 46: return ease(tt, 4, 16, 30, 196, 2.2) + ease(tt, 16, 46, 0, 26, 1.0)
    return 222 + ease(tt, 46, 76, 0, 58, 1.3)                      # LIFT
def expand(t):
    return ease(t - T0, 5, 19, 0.28, 1.0, 2.4) * (1 + ease(t - T0, 46, 76, 0, 0.12, 1.0))

class Puff:
    """one cloud puff. place: ('cap', dx, dy) relative to the cap centre, scaled by expand(t);
    ('stem', f, dx) at fraction f between the floor and the cap underside; ('base', dx, dy) on the floor.
    Life: fire strip -> rc_ybrown cooling frames (darkening) -> umber smoke held (slow boil) -> dissipating frames."""
    def __init__(s, place, start, fire, cool, die, scale=2, rot=0, flip=False, smoke=SMOKE, hold=(9, 10), z=0, gone=None):
        s.pl = place; s.start = start; s.fire = fire; s.cool = cool; s.die = die; s.sc = scale; s.rot = rot; s.flip = flip
        s.smoke = smoke; s.hold = hold; s.z = z; s.gone = gone
    def pos(s, t):
        kind = s.pl[0]; ch = cap_h(t); e = expand(t)
        if kind == 'cap': return BC + s.pl[1] * e, FY - ch + s.pl[2] * e
        if kind == 'stem':
            f, dx = s.pl[1], s.pl[2]; top = ch - 26 * e
            if t - T0 > 44: f = f * (1 + ease(t - T0, 44, 70, 0, 0.5, 1.0))    # stem stretches up as the cap lifts
            return BC + dx, FY - 8 - f * (top - 8)
        return BC + s.pl[1], FY + s.pl[2]
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
        if s.rot % 4: im = im.rotate(90 * (s.rot % 4), expand=True)
        x, y = s.pos(t)
        return im, int(round(x - im.width / 2)), int(round(y - im.height / 2)), ph

FIRE_YB = strip(YB[4:10], [1, 1, 1, 2, 2, 3])          # white ball -> gold boil (rc_ybrown / explosion (4))
FIRE_RD = strip(RCRED[0:5], [1, 1, 2, 2, 3])           # red fire puff (rc_red)

def build_cloud(r):
    P = []
    # CAP: an own mushroom silhouette laid out as puffs: a domed top arc, an inner fill row, two curled-under lips
    cap = []
    for i in range(11):                                   # top arc (ellipse a=96, b=50), left to right
        a = math.pi * (1.06 - 1.12 * i / 10)
        cap.append((96 * math.cos(a), -50 * math.sin(a) + 4, 'arc'))
    for dx in (-60, -20, 20, 60): cap.append((dx, 2, 'fill'))
    for dx in (-36, 0, 36): cap.append((dx, -24, 'fill'))
    for sg in (-1, 1): cap += [(sg * 104, 20, 'lip'), (sg * 78, 26, 'lip'), (sg * 50, 24, 'under')]
    for j, (dx, dy, kind) in enumerate(cap):
        d = math.hypot(dx / 100, dy / 55)
        st = T0 + 6 + int(d * 7) + r.randint(0, 1)
        cool = T0 + 26 - int(d * 7) + r.randint(-1, 1) + (5 if kind in ('under', 'fill') else 0)
        die = T0 + 58 + int((1 - d) * 6) + r.randint(0, 3) if kind != 'under' else T0 + 52 + r.randint(0, 2)
        red = (j % 3 == 1) or kind == 'lip'
        P.append(Puff(('cap', dx + r.uniform(-3, 3), dy + r.uniform(-2, 2)), st, FIRE_RD if red else FIRE_YB, cool, die,
                      rot=r.randrange(4), flip=r.random() < .5, smoke=RSMOKE if (red and kind != 'arc') else SMOKE,
                      hold=(4, 5) if (red and kind != 'arc') else (9, 10), z=2 if kind in ('arc', 'fill') else 1))
    # STEM: stacked puffs floor -> cap underside, narrow waist, cooled and gone first (bottom up) in the lift
    for k in range(11):
        f = k / 10; w = (12 if k % 2 == 0 else 6) + 8 * (1 - f) ** 3
        for sg in (-1, 1):
            dx = sg * w + r.uniform(-2, 2)
            st = T0 + 3 + int(1.0 * k)
            cool = T0 + 22 + int(5 * f) + r.randint(0, 2)
            die = T0 + 42 + int(14 * f)
            P.append(Puff(('stem', f, dx), st, FIRE_YB if k % 2 == 0 else FIRE_RD, cool, die, rot=r.randrange(4),
                          flip=r.random() < .5, smoke=SMOKE if k % 2 == 0 else RSMOKE, hold=(8, 9) if k % 2 == 0 else (4, 5), z=0))
    # BASE skirt: thrown out by the dome slam, low brown rolls on the floor
    for sg in (-1, 1):
        for dx, dy, st, sm in ((26, -16, 11, SMOKE), (54, -8, 12, RSMOKE), (70, -20, 12, SMOKE), (100, -6, 13, SMOKE)):
            dx += r.randint(-4, 4)
            P.append(Puff(('base', sg * dx, dy), T0 + st, FIRE_YB[3:], T0 + st + 6, T0 + 36 + dx // 8 + r.randint(0, 4), rot=r.randrange(4),
                          flip=r.random() < .5, smoke=sm, hold=(8, 9) if sm is SMOKE else (4, 5), z=3))
    return sorted(P, key=lambda p: p.z)

# ---------- fire veins (drawn in code): hard 2px lines that flicker through the smoke ----------
VEIN_CORE, VEIN_HOT, VEIN_RED = (255, 214, 90), (255, 128, 24), (196, 40, 16)
def build_veins(r):
    V = []
    for i in range(40):
        if i < 28:   # in the cap
            x, y = r.uniform(-80, 80), r.uniform(-34, 18); base = 'cap'
        else:
            x, y = r.uniform(-8, 8), r.uniform(0.15, 0.85); base = 'stem'
        pts = []; ang = r.uniform(0, 2 * math.pi); px_, py_ = 0, 0
        for k in range(r.randint(8, 16)):
            pts.append((px_, py_))
            ang += r.choice([-0.8, -0.4, 0, 0, 0.4, 0.8])
            if base == 'stem': ang = math.pi / 2 + r.uniform(-0.6, 0.6)
            px_ += 2 * round(math.cos(ang)); py_ += 2 * round(math.sin(ang))
        on = r.randint(T0 + 20, T0 + 28); off = r.randint(T0 + 42, T0 + 56)
        V.append(dict(base=base, x=x, y=y, pts=pts, on=on, off=off, ph=r.randrange(5), per=r.choice([3, 4, 5])))
    return V
def draw_veins(c, mask, V, t):
    e = expand(t); ch = cap_h(t)
    for v in V:
        if not (v['on'] <= t < v['off']): continue
        if (t + v['ph']) % v['per'] == 0: continue                      # flicker off one tic in per
        late = t > v['off'] - 6
        if v['base'] == 'cap': ox, oy = BC + v['x'] * e, FY - ch + v['y'] * e
        else: ox, oy = BC + v['x'], FY - 8 - v['y'] * (ch - 34)
        ox, oy = int(ox) // 2 * 2, int(oy) // 2 * 2
        n = len(v['pts'])
        for k, (px_, py_) in enumerate(v['pts']):
            x, y = ox + px_, oy + py_
            if not (0 <= x < CW - 1 and 0 <= y < CH - 1) or not mask[y, x]: continue
            mid = abs(k - n / 2) < n / 4
            col = VEIN_RED if late else (VEIN_CORE if (mid and (t + k) % 2 == 0) else VEIN_HOT if mid else VEIN_RED)
            c[y:y + 2, x:x + 2, :3] = np.array(col) / 255

class LCX(Layer):
    """Layer re-centred every tic on its drawn art so rolled/squashed art stays on the barrel line (as in the MS mockup)."""
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
    """drawn in code: grit and soot specks dropping out of the cloud underside, slow (terminal speed), swaying a pixel,
    landing on the floor plane and settling; blink out at the end. 2px hard blocks, flat palette steps."""
    def __init__(s, start, tics, per, seed, until):
        r = random.Random(seed); s.p = []; s.until = until
        for k in range(tics):
            for j in range(per):
                s.p.append(dict(t0=start + k, xo=r.uniform(-96, 96), vy=r.uniform(2.2, 3.2), dy0=r.uniform(0.1, 0.7), sw=r.randrange(6),
                                shp=r.choice(['dot', 'dot', 'dot', 'bar', 'sq', 'vbar']), d=r.uniform(0, 26),
                                col=r.choice([(150, 124, 96), (120, 96, 74), (98, 80, 64), (176, 150, 116), (84, 66, 54)]),
                                out=until - r.randint(0, 4)))
    def draw(s, c, t):
        for p in s.p:
            dt = t - p['t0']
            if dt < 0 or t >= p['out'] or ((p['out'] - t) <= 3 and (p['out'] - t) % 2 == 0): continue
            # spawn under the cloud at that tic's underside, then fall
            top = FY - cap_h(p['t0']) + 24 * expand(p['t0']) + abs(p['xo']) * 0.15
            y0 = top + p['dy0'] * (FY - top)
            land = FY + p['d']
            y = min(land, y0 + p['vy'] * dt + 0.1 * dt * dt)
            x = BC + p['xo'] * (1 + 0.004 * dt) + (1 if (dt // 4 + p['sw']) % 4 < 2 else -1) * (y < land)
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
        L += [LCX(strip(RCRING[4:], [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3]), T0 + 3, (BX, FY - U(14)), dx=sg * 70, scale=1, flip=sg > 0, fade=0.7, name='child rc_ring')]
        L += [LCX(strip(YB[5:14], [1, 1, 1, 2, 2, 2, 2, 2, 3]), T0 + 4, (BX, FY - U(56)), dx=sg * 50, scale=2, flip=sg > 0, add=False, name='child rc_ybrown')]
    L += [LCX(strip(X7[4:], [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3]), T0 + 5, (BX, FY - 70), scale=1, fade=0.7, name='child rc_x7')]
    # PILLAR (#7 technique): stacked pixel blasts climbing the stem from the barrel to the cap, one every 1.2 tics
    for k in range(9):
        y = FY - 26 - k * 20
        src = YB[3:] if k % 2 == 0 else YPUFF[2:]
        tl = [1] * 6 + [2] * 6 if k % 2 == 0 else [1, 2, 2, 2, 2, 3]
        L += [LCX(strip(src, tl), T0 + 3 + int(1.2 * k), (BX, y), dx=r.choice([-2, 0, 2]), scale=2 if k % 2 == 0 else 1,
                  rot=90 * r.randrange(4), fade=0.6, name=f'pillar {k}')]
    # DOME SLAM (t10): Rufaswan dome burst, flattened wide, drops 8px onto the floor, then floor ring 2 (ruf_dust ring) and a fire ring
    dome = [hard(f) for f in DOME[3:7]]
    L += [LCX(strip(dome, [2, 2, 2, 3]), T0 + 10, (BX, FY + 3), scale=2, add=False, anchor='b',
              keyframes=[(2.2, 1.25), (2.4, 0.95), (2.6, 0.7), (2.8, 0.6), (2.9, 0.55), (3.0, 0.5)], name='dome slam ruf_dome')]
    FL += [LCX(strip(posterize(DUST[3:], [(92, 78, 64), (128, 110, 88), (160, 140, 112)]), [3, 4, 5]), T0 + 11, (BX, FY + 2), size=200, squash=0.24, grow=1.1, fade=0.4, add=False, alpha=0.9, name='ring2 ruf_dust')]
    FL += [LCX(strip(YRING[3:], [1, 2, 2, 3, 3]), T0 + 11, (BX, FY + 1), size=170, squash=0.2, grow=1.3, fade=0.5, name='ring2b rf_yring')]
    FL += [LCX(strip(FIRERING[3:], [2, 2, 3, 3, 3, 4]), T0 + 28, (BX, FY + 1), size=200, squash=0.2, grow=0.5, fade=0.4, gain=0.8, name='ring3 rf_firering')]
    # CHAIN of pops crackling over the cap/stem while it darkens: alternating sides, gold flashes then red glows
    chain = [(15, -64, 'cap', -8), (17, 70, 'cap', -14), (19, -30, 'cap', -30), (21, 40, 'cap', 4), (23, -84, 'cap', 12),
             (25, 16, 'stem', 0.5), (27, 58, 'cap', -26), (29, -50, 'cap', 8), (31, 6, 'stem', 0.3), (33, -12, 'cap', -20),
             (36, 74, 'cap', 10), (39, -40, 'cap', -4)]
    for tt, dx, base, dy in chain:
        t = T0 + tt
        if base == 'cap': y = FY - cap_h(t) + dy * expand(t)
        else: y = FY - 8 - dy * (cap_h(t) - 34)
        if tt < 26:
            L += [LCX(strip(X7[5:13], [1, 1, 1, 2, 2, 2, 2, 2]), t, (BX, y), dx=dx * (expand(t) if base == 'cap' else 1), scale=1, fade=0.6, name=f'chain x7 t{tt}')]
        else:
            L += [LCX(strip(YB[6:12], [1, 1, 2, 2, 2, 2]), t, (BX, y), dx=dx * expand(t) if base == 'cap' else dx, scale=1, add=False, name=f'chain yb t{tt}'),
                  LCX(strip(RCRED[2:7], [1, 2, 2, 2, 2]), t + 2, (BX, y), dx=dx * expand(t) if base == 'cap' else dx, scale=1, gain=0.7, fade=0.4, name=f'chain red t{tt}')]
    S = [fx.PixSparks(T0 + 3, per=2, tics=7, seed=3, spread=40, vz=(10, 17), scale=2, vx=1.2),
         fx.PixSparks(T0 + 11, per=2, tics=6, seed=4, spread=70, vz=(6, 11), scale=2, vx=1.8),
         fx.PixSparks(T0 + 22, per=1, tics=10, seed=5, spread=24, vz=(14, 19), scale=2, vx=0.8)]
    B = [Debris(T0 + 2, n=26, seed=51, z0=(20, 60), x0=(40, 70), speed=(5, 9), spread=(35, 72), grav=1.0, bounce=(.32, .42), friction=.55,
                palettes=[(1, FIRE)], cool=(3, 4), shapes=('dot', 'bar', 'vbar', 'sq', 'sq', 'L'), hold=(14, 24), depth=(0, 22), spawn=.4, trail=1, exact=True, until=58),
         Debris(T0 + 3, n=12, seed=62, z0=(30, 70), x0=(50, 70), speed=(6, 9.5), spread=(40, 70), grav=1.05, bounce=(.22, .3), friction=.4,
                palettes=[(1, SHRAP)], cool=(3, 4), shapes=('slab', 'shard', 'tri', 'chunk'), hold=(24, 34), depth=(2, 24), spawn=.5, exact=True, until=66),
         Debris(T0 + 11, n=30, seed=801, z0=(1, 6), x0=(60, 90), speed=(2.5, 5.5), spread=(62, 84), grav=.8, bounce=(.15, .3), friction=.72,
                palettes=[(4, GRIT), (3, HOTGRIT)], cool=(4, 6), shapes=('dot', 'dot', 'bar', 'sq', 'vbar'), hold=(20, 34), depth=(0, 26), spawn=.34, exact=True, mirror_shape=True, until=50),
         Debris(T0 + 12, n=16, seed=71, z0=(170, 230), x0=(0, 10), speed=(4, 6.5), spread=(8, 30), grav=.9, bounce=(.3, .42), friction=.5,
                palettes=[(1, FIRE_HOLD)], cool=(5, 7), shapes=('bar', 'sq', 'vbar', 'L', 'sq'), hold=(12, 20), depth=(4, 26), spawn=1.0, trail=2, exact=True, until=56)]
    # DUST FALL: chunks drop out of the lifted cloud slowly (low gravity) and settle, plus the drawn grit rain
    BF = [Debris(T0 + 46, n=16, seed=91, z0=(100, 150), x0=(10, 70), speed=(0.6, 1.4), spread=(40, 85), grav=.22, bounce=(.15, .25), friction=.5,
                 palettes=[(2, SOOT)], cool=(8, 10), shapes=('sq', 'L', 'chunk', 'bar', 'dot'), hold=(30, 40), depth=(6, 28), spawn=1.2, exact=True, until=END - T0 - 46 - 1)]
    D = [DustFall(T0 + 34, 22, 7, 7, END)]
    blink = {T0 - 10 + 4 * i: 0.22 for i in range(3)}; blink.update({T0 - 10 + 4 * i + 1: 0.22 for i in range(3)})
    base = env([(T0 - 1, 0), (T0, 1.15), (T0 + 3, 0.9), (T0 + 9, 0.8), (T0 + 10, 1.12), (T0 + 13, 1.0), (T0 + 30, 0.6), (T0 + 46, 0.25), (T0 + 62, 0)])
    light = lambda t: max(base(t), blink.get(t, 0))
    lcol = lambda t: np.array([1.0, 0.62, 0.26]) if t < T0 + 30 else np.array([1.0, 0.42, 0.16])
    return L, LB, FL, S, B, BF, D, light, lcol

def blit(c, img, ox, oy, a, add, gain=1.0, clip_floor=False):
    fx.blit(c, img, ox, oy, a, add, gain, occ=clip_floor)

BACK = {'fire': (170, 66, 18), 'cool': (100, 44, 24), 'smoke': (40, 29, 26)}
def draw_cloud(c, P, V, t):
    """cloud into its own RGBA buffer: backing discs (drawn, flat, 2px grid), then the puffs (normal blend, hard alpha),
    then the fire veins inside the smoke (eroded mask). Composited opaque, clipped at the floor line."""
    buf = np.zeros((CH, CW, 4), np.float32)
    shots = [(p, p.at(t)) for p in P]
    yy, xx = np.mgrid[0:CH:2, 0:CW:2]
    for p, s in shots:
        if s is None: continue
        im, ox, oy, ph = s
        if ph == 'smoke' and t >= p.die: continue
        R = min(im.width, im.height) * 0.34; cx, cy = ox + im.width / 2, oy + im.height / 2
        m = ((xx + 1 - cx) ** 2 + (yy + 1 - cy) ** 2) < R * R
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
    from scipy import ndimage as ndi
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
        for l in LB:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain, clip_floor=True)
        draw_cloud(c, P, V, t)
        for l in L:
            rr = l.at(t)
            if rr: blit(c, *rr, l.add, l.gain, clip_floor=(l.name not in ('barrel',) and not l.name.startswith(('core', 'dome'))))
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

KEY = [-12, -2, 0, 1, 3, 6, 9, 11, 14, 18, 22, 26, 30, 36, 42, 48, 54, 60, 68, 76]
BEAT = {-12: 'idle', -2: 'blink', 0: 'core', 1: 'white punch', 3: 'pillar', 6: 'pillar+cap', 9: 'cap rolls', 11: 'DOME SLAM',
        14: 'mushroom', 18: 'mushroom', 22: 'darkens', 26: 'veins', 30: 'veins', 36: 'dark cloud', 42: 'dark cloud',
        48: 'LIFT', 54: 'lift + dust', 60: 'dust fall', 68: 'dust fall', 76: 'settled'}
def contact(frames, path):
    cols = 10; rows = (len(KEY) + cols - 1) // cols
    S = Image.new('RGB', (cols * CW, rows * (CH + 14)), (24, 22, 26)); d = ImageDraw.Draw(S)
    for i, k in enumerate(KEY):
        if T0 + k >= len(frames): continue
        x, y = (i % cols) * CW, (i // cols) * (CH + 14)
        S.paste(frames[T0 + k], (x, y + 14)); d.text((x + 4, y + 2), f'tic {k:+d}  {BEAT[k]}', fill=(255, 220, 90))
    S.save(path)

VS = [-2, 1, 6, 11, 16, 22, 30, 40, 50, 62]
def versus(frames, path):
    # MS frames rendered by ms_frames.py (its blast is also at frame 20); the GIF can't be used: identical frames are merged
    msf = [Image.open(f) for f in sorted(glob.glob('/tmp/fx_mega/look/ms/f*.png'))]
    S = Image.new('RGB', (len(VS) * CW, 2 * (CH + 16)), (24, 22, 26)); d = ImageDraw.Draw(S)
    for i, k in enumerate(VS):
        x = i * CW
        S.paste(frames[T0 + k], (x, 16)); d.text((x + 4, 3), f'OURS (MEGA)  tic {k:+d}', fill=(120, 230, 140))
        j = min(len(msf) - 1, 20 + k)
        S.paste(msf[j], (x, CH + 32)); d.text((x + 4, CH + 19), f'MS mockup (not shipping)  tic {k:+d}', fill=(240, 120, 110))
    S.save(path)

if __name__ == '__main__':
    fr = render(); O = '/tmp/fx_mega/out'
    if '--look' in sys.argv:
        for i, f in enumerate(fr): f.save(f'/tmp/fx_mega/look/f{i:03d}.png')
    if '--fast' not in sys.argv:
        save(fr, f'{O}/MEGA_full.gif'); save(fr, f'{O}/MEGA_half.gif', slow=2)
    contact(fr, f'{O}/MEGA_contact.png'); versus(fr, f'{O}/MEGA_vs_MS.png')
    print('frames', len(fr), 'blast at', T0)
