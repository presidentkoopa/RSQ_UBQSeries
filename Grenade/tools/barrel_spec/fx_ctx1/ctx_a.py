"""CONTEXT MODIFIERS on the approved barrel blasts (set A: #5 Snap, #6 Heavy, #7 Pillar), side view 320x320.
The base sequences are built by the copied, untouched seqB_v3/seqB/fx/debris_v3 in /tmp/fx_ctx1/a; this file only
(1) bends their sprites, sparks and debris against the room geometry and (2) adds/swaps a few layers per context.

Generic op used by WALL and CEILING = FOLD AT A PLANE: any part of a blast sprite that would go into the wall/ceiling is
mirrored back out of it, pressed thin against it (k of its depth) and stretched along it (s, growing with age). A ball
that hits a wall therefore becomes a flat bright sheet on the wall instead of a ball cut off by it.
"""
import sys, math, random
sys.path.insert(0, '/tmp/fx_ctx1/a')
import numpy as np
from PIL import Image
import fx, fx_v3, seqB, seqB_v3 as SB, debris_v3, assets as A
from fx import BX, FY, PX, CW, CH, blit, Layer
from seqB import strip, T0, CEN, RC4, YRING, SMOKE, RCRED, YPUFF
U = lambda u: u * PX
CTX = {'wall': None, 'ceil': None}       # wall x (px) / ceiling y (px), read by the patched debris + sparks

# ------------------------------------------------------------------ fold at a plane
def fold_x(img, ox, oy, WX, k=.45, s=1.5):
    """plane x=WX, solid to the right"""
    wx = WX - ox
    if wx >= img.width: return img, ox, oy
    a = np.array(img); h = a.shape[0]
    near = a[:, :max(0, wx)]
    far = a[:, max(0, wx):][:, ::-1]
    fw = max(1, round(far.shape[1] * k)); fh = max(1, round(h * s))
    farim = Image.fromarray(np.ascontiguousarray(far)).resize((fw, fh), Image.NEAREST)
    W = max(max(0, wx), fw); H = max(h, fh)
    out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    if wx > 0: out.paste(Image.fromarray(np.ascontiguousarray(near)), (W - wx, (H - h) // 2))
    out.alpha_composite(farim, (W - fw, (H - fh) // 2))
    return out, WX - W, oy - (H - h) // 2

def fold_y(img, ox, oy, CY, k=.45, s=1.5):
    """plane y=CY, solid above"""
    t = img.transpose(Image.Transpose.TRANSPOSE)            # x<->y : above-the-ceiling becomes left-of-plane
    t = t.transpose(Image.Transpose.FLIP_LEFT_RIGHT)          # now solid side is on the right
    # in flipped-transposed space: column j = original row (h-1-j); plane at original row CY-oy -> column h-(CY-oy)
    h = img.height; WXl = h - (CY - oy)
    r, nx, _ = fold_x(t, 0, 0, WXl, k, s)
    # nx = WXl - W ; the result's columns map back to original rows: row = h-1-(nx+j)
    r = r.transpose(Image.Transpose.FLIP_LEFT_RIGHT).transpose(Image.Transpose.TRANSPOSE)
    noy = oy + (h - (nx + (r.height)))
    nox = ox - (r.width - img.width) // 2
    return r, nox, noy

# ------------------------------------------------------------------ physics patches (copies with a wall/ceiling added)
def _sim(s, x, z, vx, vz, g, b, fr, depth, h):
    path = []; rest = 0; land = None; nb = 0
    WX = CTX['wall']; CZ = (FY - CTX['ceil']) if CTX['ceil'] else None
    for t in range(200):
        if land is None and t > 0 and z <= 0: land = t
        path.append((x, z, rest > 0))
        if rest:
            rest += 1
            if rest > 3: break
            continue
        if z <= 0 and vz == 0:
            x += vx; vx *= 0.45
            if WX and x > WX - 3: x = 2 * (WX - 3) - x; vx = -vx
            if abs(vx) < 0.5: rest = 1
            continue
        x += vx; z += vz; vz -= g; vx *= 0.985
        if WX and x > WX - 3: x = 2 * (WX - 3) - x; vx = -vx * .55            # bounce off the wall
        if CZ and z > CZ - 4: z = 2 * (CZ - 4) - z; vz = -abs(vz) * .45        # bounce off the ceiling
        if z <= 0:
            z = 0
            if abs(vz) * b > 1.3 * g and nb < 4: vz = -vz * b; vx *= fr; nb += 1
            else: vz = 0; vx *= fr
    land = land or len(path)
    return [(px, pz, st, depth * min(1, i / land)) for i, (px, pz, st) in enumerate(path)]
debris_v3.Debris._sim = _sim

def _spark_draw(s, c, t):
    WX = CTX['wall']; CY = CTX['ceil']
    for p in s.p:
        dt = t - p['t0']
        if dt < 0 or dt >= p['life']: continue
        a = 1.0 if dt < p['life'] - 3 else (p['life'] - dt) / 4
        x, y, vx, vy = p['x'], p['y'], p['vx'], p['vy']
        for _ in range(dt):                                   # step so they can bounce
            x += vx; y += vy; vy += s.grav
            if WX and x > WX - 2: x = 2 * (WX - 2) - x; vx = -vx * .6
            if CY and y < CY + 2: y = 2 * (CY + 2) - y; vy = abs(vy) * .4
        im = s.fr[min(3, (dt // 3) % 4 if dt < 12 else 3)]
        blit(c, im, int(x - im.width / 2), int(y - im.height / 2), a, True)
fx.PixSparks.draw = _spark_draw

# ------------------------------------------------------------------ flat-band helpers
def bands(d, levels=(.55, .32, .14)):
    n = len(levels); return np.select([d < (i + 1) / n for i in range(n)], list(levels), 0)
def env_light(lt, t): return min(1.0, lt(t)) if lt else 0
FIRE_COL = np.array([1.0, .55, .2])

# ------------------------------------------------------------------ renderer (fx_v3.render + context hooks)
def render(layers, sparks, back, lt, ctx, pause=14, T=None, lcol=FIRE_COL):
    T = T or max([l.end() for l in layers] + [s.end() for s in list(sparks) + list(back)]) + pause
    out = []
    for t in range(T):
        c = np.zeros((CH, CW, 3), np.float32); c[:] = (0.035, 0.03, 0.04)
        ctx.bg(c, t)
        c[FY:] = (0.07, 0.065, 0.07)
        L = env_light(lt, t)
        if L > 0:
            yy, xx = np.mgrid[FY:CH, 0:CW]; d = np.sqrt(((xx - BX) / 110) ** 2 + ((yy - FY) / 26) ** 2)
            c[FY:] += bands(d)[..., None] * lcol * L
        c[FY:FY + 1] = np.maximum(c[FY:FY + 1], (0.32, 0.30, 0.30))
        for b in back: b.draw(c, t)
        for l in sorted(layers, key=lambda l: l.z):
            if l.floor: continue
            r = l.at(t)
            if r:
                for im, ox, oy, a in ctx.xform(l, r, t): blit(c, im, ox, oy, a, l.add, l.gain, occ=True)
        for s in sparks: s.draw(c, t)
        for l in layers:
            if not l.floor: continue
            r = l.at(t)
            if r:
                for im, ox, oy, a in ctx.xform(l, r, t): blit(c, im, ox, oy, a, l.add, l.gain)
        ctx.fg(c, t, L)
        out.append(Image.fromarray((np.clip(c, 0, 1) * 255).astype(np.uint8)))
    return out

class Plain:
    def bg(s, c, t): pass
    def xform(s, l, r, t): return [r]
    def fg(s, c, t, L): pass

def age(l, t): return (t - l.start) / max(1, l.len - 1)

# ================================================================== 1. AGAINST A WALL  (base #5 Snap)
def make_scorch(cx, cy, rx, ry_up, ry_dn, seed, W=CW, H=CH, grid=2):
    """flat-band scorch mask on a slab: 0 none, 1 rim, 2 mid, 3 core; ragged edge on a 2px grid"""
    r = random.Random(seed); m = np.zeros((H, W), np.int8)
    for y in range(0, H, grid):
        for x in range(0, W, grid):
            dx = (x - cx) / rx; dy = (y - cy) / (ry_up if y < cy else ry_dn)
            d = math.sqrt(dx * dx + dy * dy) + r.uniform(-.13, .13)
            lv = 3 if d < .42 else 2 if d < .7 else 1 if d < 1 else 0
            m[y:y + grid, x:x + grid] = lv
    return m

class Wall(Plain):
    """wall face at x=WX on the right of the barrel; seen edge-on, its brick slab fills the right of the frame"""
    def __init__(s, WX, cy, t_scorch, scorch=(26, 66, 30)):
        s.WX = WX; s.cy = cy; s.ts = t_scorch
        s.sc = make_scorch(WX, cy, scorch[0], scorch[1], scorch[2], 5)
        yy, xx = np.mgrid[0:CH, 0:CW]
        s.ld = np.sqrt(((xx - WX) / 46) ** 2 + ((yy - cy) / 84) ** 2)
        brick = np.zeros((CH, CW, 3), np.float32); brick[:] = (0.2, 0.185, 0.19)
        brick[(yy % 12) == 0] = (0.12, 0.11, 0.115)
        brick[((xx - WX + (yy // 12 % 2) * 12) % 24 == 0)] = (0.12, 0.11, 0.115)
        brick[:, WX:WX + 2] = (0.34, 0.32, 0.33)
        s.brick = brick
    def xform(s, l, r, t):
        im, ox, oy, a = r
        if l.name == 'barrel': return [r]
        if not l.add: ox -= int(.5 * (t - l.start))           # smoke drifts away from the wall
        elif not l.floor: ox -= int(U(4))                      # fire pushed a little off the wall
        g = age(l, t)
        k, sv = (.35, 1.6 + 1.0 * g) if not l.floor else (.5, 1.0)
        out = [fold_x(im, ox, oy, s.WX, k, sv) + (a,)]
        if l.add and not l.floor and ox + im.width > s.WX + 2 and l.name != 'pop0' and not l.name.startswith('pop'):
            # the SHEET: the whole sprite pressed flat on the wall face and fanned out along it (up and down)
            # (left half of a squashed copy: a D shape whose flat side lies on the wall)
            hgt = max(1, round(im.height * (1.5 + .9 * g))); wid = max(3, round(im.width * .22))
            sh = im.resize((2 * wid, hgt), Image.NEAREST).crop((0, 0, wid, hgt))
            out.append((sh, s.WX - wid, oy + im.height // 2 - hgt // 2, a))
        return out
    def fg(s, c, t, L):
        W = s.WX; c[:, W:] = s.brick[:, W:]
        dt = t - s.ts
        if dt >= 0:   # scorch grows over 4 tics, glows (hot bands) then cools to soot; stays
            grow = min(1, (dt + 1) / 4)
            m = s.sc.copy()
            if grow < 1: m = np.where(m >= 3 - int(grow * 3), m, 0)
            if dt < 3: cols = {3: (1.0, .7, .3), 2: (.7, .28, .08)}
            elif dt < 7: cols = {3: (.45, .14, .05), 2: (.2, .09, .06), 1: (.12, .09, .08)}
            else: cols = {3: (.03, .027, .027), 2: (.06, .052, .05), 1: (.11, .1, .095)}
            for lv, col in cols.items():
                sel = (m == lv); sel[:, :W] = False; c[sel] = col
            c[:, W:W + 2] = np.where((m[:, W:W + 2] >= 2)[..., None], c[:, W:W + 2], (0.34, 0.32, 0.33))
        if L > 0:                                           # blast light on the wall: three flat bands
            lv = bands(s.ld, (.5, .28, .12))[..., None] * FIRE_COL * L
            c[:, W:] += lv[:, W:]
        c[FY:FY + 1, W:] = (0.32, 0.30, 0.30)

def wall_barrel():
    WX = int(BX + U(24))
    CTX['wall'] = WX; CTX['ceil'] = None
    Ls, Ss, lt, Bk = SB.snap()
    # extra: the blast's spray hitting the wall leaves a fan of hot specks running up and down the face (sheet edge)
    Ls += [Layer(strip(RC4[4:], [1] * 6 + [2] * 6), T0 + 2, (WX - 4, CEN[1] - U(16)), scale=1.6, rot=90, squash=1, sxg=1.0,
                 name='wall run up', vel=(0, -2.2)),
           Layer(strip(RC4[4:], [1] * 6 + [2] * 6), T0 + 3, (WX - 4, CEN[1] + U(4)), scale=1.4, rot=270,
                 name='wall run down', vel=(0, 1.0))]
    ctx = Wall(WX, int(CEN[1] - U(4)), T0 + 2)
    return Ls, Ss, Bk, lt, ctx

# ================================================================== 2. LOW CEILING  (base #6 Heavy)
class Ceiling(Plain):
    def __init__(s, CYL, t_soot):
        s.CY = CYL; s.ts = t_soot
        yy, xx = np.mgrid[0:CH, 0:CW]
        slab = np.zeros((CH, CW, 3), np.float32); slab[:] = (0.2, 0.185, 0.19)
        slab[(yy % 10) == 0] = (0.12, 0.11, 0.115)
        slab[((xx + (yy // 10 % 2) * 16) % 32 == 0)] = (0.12, 0.11, 0.115)
        slab[CYL - 2:CYL] = (0.34, 0.32, 0.33)
        s.slab = slab
        s.ld = np.sqrt(((xx - BX) / 120) ** 2 + ((yy - CYL) / 34) ** 2)
        s.soot = make_scorch(BX, CYL, 90, 16, 1, 9)
    def xform(s, l, r, t):
        im, ox, oy, a = r
        if l.name == 'barrel' or l.floor: return [r]
        g = age(l, t)
        if l.name.startswith('main cap rings'):   # the cap ring can't open upward: it lies flat, spreading under the ceiling
            im2 = im.resize((round(im.width * 1.25), max(1, round(im.height * .16))), Image.NEAREST)
            return [(im2, ox + (im.width - im2.width) // 2, s.CY + 2, a)]
        if not l.add:            # smoke can't rise past the ceiling: it stops under it and spreads flat
            oy = max(oy, s.CY - int(im.height * .35))
            return [fold_y(im, ox, oy, s.CY, .35, 1.6 + 1.6 * g) + (a,)]
        return [fold_y(im, ox, oy, s.CY, .4, 1.5 + 1.2 * g) + (a,)]
    def fg(s, c, t, L):
        C = s.CY; c[:C] = s.slab[:C]
        dt = t - s.ts
        if dt >= 0:
            grow = min(1, (dt + 1) / 6)
            m = np.where(s.soot >= 3 - int(grow * 3), s.soot, 0) if grow < 1 else s.soot
            cols = {3: (1, .7, .3), 2: (.9, .4, .1), 1: (.45, .16, .05)} if dt < 4 else \
                   {3: (.03, .028, .028), 2: (.055, .05, .045), 1: (.085, .075, .07)}
            for lv, col in cols.items():
                sel = (m == lv); sel[C:] = False; c[sel] = col
        if L > 0:
            lv = bands(s.ld, (.5, .28, .12))[..., None] * FIRE_COL * L; c[:C] += lv[:C]

def ceiling_barrel():
    CYL = int(FY - U(64))
    CTX['wall'] = None; CTX['ceil'] = CYL
    Ls, Ss, lt, Bk = SB.heavy()
    # extra: fire ROLLS along the ceiling: mirrored pairs of flattened pixel fireballs running outward under it
    r = random.Random(3)
    for i, (t0, v, sc) in enumerate([(5, 3.0, 2.6), (7, 2.2, 2.2), (10, 1.6, 2.0)]):
        rot = r.randrange(4) * 90
        for sg in (-1, 1):
            Ls += [Layer(strip(RC4[3:], [1] * 4 + [2] * 9), T0 + t0, (BX + sg * U(14), CYL + 9), scale=sc, rot=rot,
                         squash=.55, vel=(sg * v, 0), acc=(-sg * .05, 0), flip=sg > 0, name=f'ceiling roll {i}{sg}')]
    # smoke held under the ceiling a long time (it can't escape), spreading out both ways
    for sg in (-1, 1):
        Ls += [Layer(strip(SMOKE[5:12], [4] * 6 + [30]), T0 + 24, (BX + sg * U(20), CYL + 10), scale=3.0, add=False, alpha=.8,
                     vel=(sg * .8, 0), squash=.6, fadein=4, fade=.8, z=-3, name='smoke sheet')]
    ctx = Ceiling(CYL, T0 + 2)
    return Ls, Ss, Bk, lt, ctx

# ================================================================== 3. UNDER OPEN SKY  (base #7 Pillar)
SKY = [(0.01, 0.012, 0.045), (0.02, 0.027, 0.08), (0.035, 0.045, 0.115), (0.055, 0.06, 0.145), (0.085, 0.075, 0.16),
       (0.13, 0.09, 0.15)]
class Sky(Plain):
    def __init__(s):
        r = random.Random(4); s.stars = [(r.randrange(CW), r.randrange(0, 80)) for _ in range(22)]
        # far skyline: blocky dark hills/ruins on a 4px grid
        s.sil = []
        x = 0
        while x < CW:
            w = r.choice([8, 12, 16, 20]); h = r.choice([4, 8, 8, 12, 16]); s.sil.append((x, w, h)); x += w
    def bg(s, c, t):
        n = len(SKY); hgt = FY // n
        for i, col in enumerate(SKY): c[i * hgt:(i + 1) * hgt if i < n - 1 else FY] = col
        for x, y in s.stars: c[y, x] = (0.35, 0.35, 0.45)
        for x, w, h in s.sil: c[FY - h:FY, x:x + w] = (0.03, 0.03, 0.045)
        s._t = t
    def fg(s, c, t, L): pass

def sky_barrel():
    CTX['wall'] = None; CTX['ceil'] = None
    Ls, Ss, lt, Bk = SB.pillar()
    # drop the crown and the top fireball (the column now goes on past the top of the frame instead of capping)
    Ls = [l for l in Ls if l.name not in ('crown rf_firering', 'top rc_red to smoke', 'smoke rc_grey')]
    r = random.Random(41)
    # recompute where base column ended (same formula as seqB.pillar) and keep climbing out of the frame
    y = FY - U(42); sc = 2.6
    for k in range(9): y -= U(12) - k * 0.8; sc *= 0.92
    ys = []
    for k in range(9, 17):
        y -= U(13); x = BX + U(r.uniform(-4, 4)); ys.append(y)
        src = RC4[3:] if k % 2 == 0 else YPUFF[2:]
        tl = [1] * 6 + [2] * 7 if k % 2 == 0 else [1, 2, 2, 2, 2, 3]
        Ls += [Layer(strip(src, tl), T0 + 4 + int(1.5 * 9) + int(1.2 * (k - 9)), (x, y), scale=sc if k % 2 == 0 else sc * .62,
                     rot=r.randrange(360), name=f'sky column {k}')]
    # smoke: a tall column of dark puffs left along the whole height; they rise slowly, drift with the wind, and STAY
    for j, yy in enumerate(np.linspace(FY - U(30), -20, 11)):
        t0 = T0 + 12 + j * 2
        Ls += [Layer(strip(SMOKE[6:], [3, 3, 3, 3, 56, 3, 3, 3, 3, 3]), t0, (BX + U(r.uniform(-4, 4)), yy), scale=2.3 + .15 * (j % 3), add=False,
                     alpha=.78, vel=(.12, -.3), grow=.5, fadein=4, fade=None, z=-2, rot=r.choice([0, 90, 180, 270]),
                     name=f'stay smoke {j}')]
    def lt2(t, lt=lt): return lt(t)
    return Ls, Ss, Bk, lt2, Sky()

# ================================================================== 4. IN WATER  (base #6 Heavy)
WS = int(FY - U(104))                 # water surface line
WATER = [(0.03, 0.08, 0.13), (0.025, 0.07, 0.115), (0.02, 0.06, 0.10), (0.018, 0.05, 0.088)]
A.RAMPS['ice'] = [(0, (6, 26, 48)), (.45, (60, 140, 200)), (.8, (170, 225, 250)), (1, (245, 252, 255))]
BUBF = A.gmap(seqB_strip := [Image.open(p).convert('RGBA') for p in sorted(__import__('glob').glob('/tmp/fx_agentB/cut/ruf_bubble/*.png'))], 'ice', lo=0, hi=255)
PALE = lambda fr, a=(0.75, 0.95, 1.0): A.tint(A.gmap(fr, 'blue'), a)

class Bubbles:
    """hard-pixel bubbles: born on a growing dome around (cx,cy) (the gas pushing out), then they rise, wobble, speed
    up and pop at the surface with a 1-tic white pixel tick. cs: colour scale of the canvas (1 = 0..1 floats)."""
    def __init__(s, start, cx, cy, ws, n=40, R=46, seed=1, dome_t=6, cs=1.0, floor=None, rmax=4, spread=1.0):
        r = random.Random(seed); s.b = []; s.ws = ws; s.cs = cs; s.start = start
        for i in range(n // 2):
            a = r.uniform(0, math.pi / 2); rad = r.uniform(.55, 1.0) * R; size = r.choice([1, 1, 1, 2, 2, 2, 3, 3, 4][:rmax * 2 + 1])
            t0 = start + r.randint(0, 3); d = r.randint(dome_t - 2, dome_t + 2)
            for sg in (-1, 1):
                x0 = cx + sg * math.cos(a) * rad * spread; y0 = cy - math.sin(a) * rad
                if floor is not None: y0 = min(y0, floor - size - 1)
                s.b.append(dict(t0=t0, d=d, x=x0, y=y0, sz=size, ph=r.uniform(0, 6.28), v0=r.uniform(.6, 1.4), cx=cx, cy=cy))
        s.len = 140
    def pos(s, b, dt):
        if dt < b['d']:                      # pushed out with the dome (ease out)
            k = 1 - (1 - dt / b['d']) ** 2
            return b['cx'] + (b['x'] - b['cx']) * k, b['cy'] + (b['y'] - b['cy']) * k
        u = dt - b['d']
        y = b['y'] - (b['v0'] * u + .09 * (1 + b['sz'] * .35) * u * u)
        x = b['x'] + round(math.sin(b['ph'] + u * .7))
        return x, y
    def end(s): return s.start + s.len
    def draw(s, c, t):
        H, W = c.shape[:2]
        for b in s.b:
            dt = t - b['t0']
            if dt < 0: continue
            x, y = s.pos(b, dt); r_ = b['sz']
            if y - r_ <= s.ws:              # pop: tick on the surface, 2 tics, then gone
                yp = s.pos(b, dt - 1)[1] if dt else y
                if yp - r_ > s.ws or (dt > 0 and s.pos(b, dt - 2)[1] - r_ > s.ws):
                    xi = int(round(x))
                    for k in range(-1, 2):
                        if 0 <= xi + k < W: c[s.ws - 1, xi + k] = np.array((1, 1, 1)) * s.cs
                    if 0 <= xi < W: c[s.ws - 2, xi] = np.array((.8, .95, 1)) * s.cs
                continue
            put_bubble(c, x, y, r_, s.cs)

def put_bubble(c, x, y, r_, cs):
    H, W = c.shape[:2]; xi, yi = int(round(x)), int(round(y))
    rim = np.array((.62, .86, 1.0)) * cs; hi = np.array((1, 1, 1)) * cs
    if r_ <= 1:
        pts = [(0, 0)] if r_ == 0 else [(0, 0), (1, 0), (0, 1), (1, 1)]
        for dx, dy in pts:
            if 0 <= xi + dx < W and 0 <= yi + dy < H: c[yi + dy, xi + dx] = rim
        if 0 <= xi < W and 0 <= yi < H: c[yi, xi] = hi
        return
    for dy in range(-r_, r_ + 1):
        for dx in range(-r_, r_ + 1):
            d = math.hypot(dx, dy)
            if r_ - .7 <= d <= r_ + .3 and 0 <= xi + dx < W and 0 <= yi + dy < H: c[yi + dy, xi + dx] = rim
    for dx, dy in [(-r_ // 2, -r_ // 2)]:
        if 0 <= xi + dx < W and 0 <= yi + dy < H: c[yi + dy, xi + dx] = hi

class Splash:
    """the surface: a hump of water rises over the blast, a hard pixel splash ring runs out on the water line,
    droplets are thrown up and fall back. Everything flat colours, 1-2 px."""
    def __init__(s, start, cx, ws, R=110, seed=2, cs=1.0, hump=(46, 12), drops=26, sq=.14, unit=1.0):
        s.start = start; s.cx = cx; s.ws = ws; s.R = R; s.cs = cs; s.hump = hump; s.sq = sq
        r = random.Random(seed); s.d = []
        for i in range(drops // 2):
            dx = r.uniform(2, hump[0] * .7); vy = -r.uniform(2.2, 5.0) * unit; vx = r.uniform(.2, 1.4) * unit; t0 = r.randint(1, 4)
            for sg in (-1, 1): s.d.append((t0, cx + sg * dx, sg * vx, vy, r.choice([1, 1, 2])))
        s.g = .32 * unit; s.len = 40
    def end(s): return s.start + s.len
    def draw(s, c, t):
        dt = t - s.start
        if dt < 0: return
        H, W = c.shape[:2]; cs = s.cs
        hw, hh = s.hump
        # hump: up over 4 tics, down over 8 (flat water colour, light top edge)
        hk = (dt + 1) / 4 if dt < 4 else max(0, 1 - (dt - 3) / 8)
        if hk > 0:
            for x in range(int(s.cx - hw), int(s.cx + hw) + 1):
                if not 0 <= x < W: continue
                f = 1 - ((x - s.cx) / hw) ** 2
                h = int(round(hh * hk * f / 2)) * 2
                if h <= 0: continue
                c[s.ws - h:s.ws, x] = np.array((.08, .2, .27)) * cs
                c[s.ws - h, x] = np.array((.55, .78, .9)) * cs
                if h > 6: c[s.ws - h + 1, x] = np.array((.3, .5, .62)) * cs
        # ring on the water line, seen flat (ellipse squashed), 2px white -> 1px pale -> dashed blue
        if 1 <= dt < 15:
            k = (dt - 1) / 13; rr = 10 + (s.R - 10) * (1 - (1 - k) ** 2)
            cols = [(1, 1, 1), (.75, .93, 1), (.45, .7, .85), (.25, .45, .6)]; ci = min(3, int(k * 4)); w = 2 if ci < 2 else 1
            n = int(2 * math.pi * rr) + 8
            for i in range(n):
                a = 2 * math.pi * i / n
                if k > .5 and (i // 5) % 2: continue
                x = s.cx + math.cos(a) * rr; y = s.ws + math.sin(a) * rr * s.sq
                xi, yi = int(x), int(y)
                if 0 <= xi < W - w and 0 <= yi < H - w: c[yi:yi + w, xi:xi + w] = np.array(cols[ci]) * cs
        # droplets
        for t0, x0, vx, vy, sz in s.d:
            u = dt - t0
            if u < 0: continue
            x = x0 + vx * u; y = s.ws - 2 + vy * u + .5 * s.g * u * u
            if y > s.ws - 1: continue
            col = (1, 1, 1) if u < 3 else (.7, .9, 1) if u < 8 else (.45, .7, .85)
            xi, yi = int(x), int(y)
            if 0 <= xi < W - sz and 0 <= yi < H - sz: c[yi:yi + sz, xi:xi + sz] = np.array(col) * cs

class WaterCtx(Plain):
    def __init__(s, flash=(T0, T0 + 3)):
        s.fl = flash
    def bg(s, c, t): pass
    def xform(s, l, r, t):
        im, ox, oy, a = r
        if l.name != 'barrel' and oy < WS + 1:   # everything stays under the surface
            cut = WS + 1 - oy
            if cut >= im.height: return []
            a2 = np.array(im); a2[:cut, :, 3] = 0; im = Image.fromarray(a2)
        return [(im, ox, oy, a)]
    def fg(s, c, t, L):
        n = len(WATER); h = (FY - WS) // n
        sub = c[WS:]
        boost = 1 if s.fl[0] <= t < s.fl[1] else 0            # the flash lifts the water one flat step
        for i, col in enumerate(WATER):
            y0 = WS + i * h; y1 = WS + (i + 1) * h if i < n - 1 else CH
            col = np.array(WATER[max(0, i - boost)]) + (np.array((.05, .08, .1)) if boost else 0)
            c[y0:y1] = c[y0:y1] * np.array((.78, .9, 1.0)) + col
        c[WS] = (0.42, 0.58, 0.68); c[WS + 1] = np.maximum(c[WS + 1], (0.14, 0.24, 0.3))

def water_barrel():
    CTX['wall'] = None; CTX['ceil'] = None
    Ls, Ss, lt, Bk = SB.heavy()
    out = []
    for l in Ls:
        n = l.name
        if n == 'barrel': out.append(l)
        elif n == 'main domes':
            # keep only the opening flash: big frame 1 tic + silhouette 2 tics, both pure white (no fire after)
            w = seqB.solid(l.fr[0][0])
            out.append(Layer([(w, 3)], l.start, l.pos, scale=l.scale * .8, rot=l.rot, name='white flash'))
        elif n.startswith('child'):
            # each fire child becomes a gas bubble that pops: Rufaswan bubble -> star flash -> ring
            fr = [(BUBF[0], 2), (BUBF[0], 2), (BUBF[2], 1), (BUBF[3], 2), (BUBF[3], 2)]
            out.append(Layer(fr, l.start + 1, l.pos, size=34 + 8 * ('BMT'.index(n.split()[1])), add=False, grow=.25,
                             vel=(0, -2.2), name='bubble ' + n))
        elif n.startswith('floor'):
            # silt kicked off the floor: the floor ring in murky grey-blue, normal blend
            out.append(Layer(strip(A.tint(SMOKE[3:9], (0.55, 0.75, 0.85)), 2), l.start + 1, (BX, FY - 4), scale=2.6, squash=.4,
                             grow=.9, add=False, alpha=.6, fade=.5, name='silt ring', z=-2))
    # muffled thump: one pale pressure ring through the water, fast, dim, then gone
    ring = A.tint([A.white(f) for f in YRING[2:7]], (0.55, 0.8, 0.95))
    out.append(Layer(strip(ring, [1, 1, 2, 2, 2]), T0 + 1, CEN, size=140, grow=1.3, alpha=.32, fade=.3, name='thump ring'))
    # the gas dome: a big Rufaswan bubble grows over the barrel and lifts, then flashes and breaks into the swarm
    out.append(Layer([(BUBF[0], 1)] * 7 + [(BUBF[2], 1), (BUBF[3], 2)], T0 + 2, (BX, CEN[1] - 6), size=120, grow=.7,
                     vel=(0, -9.0), add=False, name='gas dome'))
    # murk: silt cloud that hangs near the floor (replaces the smoke)
    out.append(Layer(strip(A.tint(SMOKE[6:], (0.5, 0.68, 0.78)), [4] * 9 + [16]), T0 + 10, (BX, FY - 26), scale=3.4,
                     add=False, alpha=.5, vel=(0, -.25), grow=.4, fadein=6, fade=.75, z=-3, name='murk'))
    S = [Bubbles(T0 + 2, BX, CEN[1], WS, n=64, R=70, seed=7, floor=FY - 2),
         Bubbles(T0 + 11, BX, CEN[1] - 50, WS, n=22, R=30, seed=8, dome_t=3),
         Splash(T0 + 12, BX, WS, R=120, seed=3, hump=(56, 18))]
    # shrapnel underwater: cold dark metal slabs, no hot palette, thrown slowly, sinking (low gravity)
    METAL = [(150, 150, 140), (110, 112, 96), (84, 88, 70), (64, 68, 54)]
    B = [SB.Debris(T0 + 4, n=10, seed=63, z0=(14, 34), x0=(18, 26), speed=(1.6, 2.8), spread=(35, 80), grav=.18,
                   bounce=(.1, .2), friction=.3, palettes=[(1, METAL)], cool=(4, 6), shapes=('slab', 'shard', 'tri', 'sq'),
                   hold=(30, 40), depth=(2, 10), spawn=.5, exact=True, until=70)]
    cold = lambda t: lt(t) * (1 if t < T0 + 4 else 0)
    return out, S, B, cold, WaterCtx()
COLD = np.array([.55, .85, 1.0])

SHOTS = {'C_wall_barrel': (wall_barrel, FIRE_COL, 14), 'C_ceiling_barrel': (ceiling_barrel, FIRE_COL, 14),
         'C_sky_barrel': (sky_barrel, FIRE_COL, 40), 'C_water_barrel': (water_barrel, COLD, 10)}
def build(name):
    fn, lc, pause = SHOTS[name]
    Ls, Ss, Bk, lt, ctx = fn()
    T = None
    if name == 'C_water_barrel': T = T0 + 72
    return render(Ls, Ss, Bk, lt, ctx, pause=pause, T=T, lcol=lc)
if __name__ == '__main__':
    O = '/tmp/fx_ctx1/out'
    for name in (sys.argv[1:] or list(SHOTS)):
        fr = build(name)
        fx.save(fr, f'{O}/{name}_full.gif'); fx.save(fr, f'{O}/{name}_half.gif', slow=2)
        for i, f in enumerate(fr): f.save(f'/tmp/fx_ctx1/look/{name}_{i - T0:+04d}.png')
        print(name, len(fr))
