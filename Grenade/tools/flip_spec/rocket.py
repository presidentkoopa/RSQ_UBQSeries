"""ROCKET (RPG / launcher) blast: three shots (WALL, FLOOR, AIR into a cacodemon). 640x420 canvas, 1.25 px per map unit,
shown 2x (same as the grenade). Builds on copies (unchanged) of the grenade compositor in /tmp/fx_rocket/lib (fxg, seqg)
and copies of the context-wall helpers (fold_x, make_scorch, bands) from /tmp/fx_ctx1/ctx_a.py, pasted below.

Beat (all shots; tic 0 = impact):
  pre      the owner's rocket (RSR0A3A7) flies in at 20 u/tic, two trail puffs a tic (RST0 hot bit -> blocky grey smoke)
  0-1      FLASH: 2-tic white silhouette of a blobby fuel ball (rc_x10 frame), 3 flat streak pops
  1-3      BACKBLAST: a tongue of fire and hard streaks thrown back up the incoming line
  2-~12    FLASHBACK (signature): a fire front runs back along the smoke trail, 34 px a tic; each puff it reaches flashes
           white, burns gold -> red -> brown and is left as dark soot that lingers and drifts
  1-7      child bursts one per tic that feed the BOIL: a churning block of fire puffs rolling in two vortices (up the
           middle, back down the sides), darkening gold -> red -> brown -> umber smoke with hot pockets flaring inside,
           then lifting and breaking up (no mushroom)
  0-14     sparks (hard pixel streaks), debris that bounces and settles, RSS0 embers, one hot pixel ring to 128 units
  1-40     the spent MOTOR STUB tumbles out, sputtering, and lands
"""
import sys, math, random, glob
sys.path.insert(0, '/tmp/fx_rocket/lib'); sys.path.insert(0, '/tmp/fx_rocket')
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
import fxg, seqg
from fxg import CW, CH, FLOOR, BX, U, Z, L, blit, px, line, background, env, strip, pick, banded_glow, save_gif
import lmp

CF = '/home/claude/rsq_ubqseries/Monsters/sprites/combatfx'
CACO = '/home/claude/rsq_ubqseries/Monsters/sprites/monsters/Cacodemon/T04'

# ------------------------------------------------------------------ assets
def rgba(p): return Image.open(p).convert('RGBA')
def hard(im):
    a = np.array(im.convert('RGBA')).copy(); a[..., 3] = np.where(a[..., 3] > 100, 255, 0); return Image.fromarray(a)
def cut(k):
    p = ('/tmp/eosfr/' if k.startswith(('rf_', 'rc_ring', 'rc_red', 'rc_grey')) else '/tmp/fx_agentB/cut/') + k
    return [hard(rgba(f)) for f in sorted(glob.glob(p + '/*.png'))]
YB, RED, GREY, X10 = cut('rc_ybrown'), cut('rc_red'), cut('rc_grey'), cut('rc_x10')
ROCKET = hard(rgba(f'{CF}/projectiles/RSR0A3A7.png')).transpose(Image.FLIP_LEFT_RIGHT)     # nose right
RST = [hard(rgba(f'{CF}/trails/RST0{c}0.png')) for c in 'AB']
def half(im): return im.resize((max(1, im.width // 2), max(1, im.height // 2)), Image.NEAREST)

# flat-band recolours (copied method from /tmp/fx_mega/mega.py posterize/no_pupils)
def posterize(frames, pal):
    arrs = [np.array(f).astype(float) for f in frames]
    lum = [0.3 * a[..., 0] + 0.59 * a[..., 1] + 0.11 * a[..., 2] for a in arrs]
    v = np.concatenate([l[a[..., 3] > 0] for l, a in zip(lum, arrs) if (a[..., 3] > 0).any()])
    lo, hi = np.percentile(v, 3), np.percentile(v, 97); out = []
    for l, a in zip(lum, arrs):
        k = np.clip(((l - lo) / max(1, hi - lo) * len(pal)).astype(int), 0, len(pal) - 1)
        o = np.zeros(a.shape, np.uint8); o[..., :3] = np.array(pal)[k]; o[..., 3] = np.where(a[..., 3] > 100, 255, 0)
        out.append(Image.fromarray(o))
    return out
def no_pupils(frames, pal):
    out = []
    for f in frames:
        a = np.array(f).copy(); m = ndi.binary_erosion(a[..., 3] > 0, iterations=2)
        dk = (a[..., :3] == np.array(pal[0])).all(-1) & m; a[dk, :3] = pal[1]
        m3 = ndi.binary_erosion(a[..., 3] > 0, iterations=4)            # no donut: the deep inside sits one band up
        for lo, hi in ((1, 2),):
            sel = (a[..., :3] == np.array(pal[lo])).all(-1) & m3; a[sel, :3] = pal[hi]
        out.append(Image.fromarray(a))
    return out
P_TRAIL = [(58, 58, 64), (84, 84, 90), (112, 110, 112), (146, 142, 138)]       # trail smoke: cool grey
P_SOOT = [(20, 16, 15), (34, 28, 26), (52, 43, 38), (74, 62, 54)]             # burnt trail: soot
P_UMBER = [(36, 26, 24), (56, 40, 32), (78, 56, 42), (100, 74, 56)]          # boil smoke (mega's umber)
P_REDUMB = [(48, 24, 22), (76, 36, 28), (104, 52, 34), (132, 74, 46)]
GT = no_pupils(posterize(GREY, P_TRAIL), P_TRAIL)
GS = no_pupils(posterize(GREY, P_SOOT), P_SOOT)
GU = no_pupils(posterize(GREY, P_UMBER), P_UMBER)
GR = posterize(RED, P_REDUMB)
YBh, REDh = [half(f) for f in YB], [half(f) for f in RED]
def white(im):
    a = np.array(im).copy(); a[..., :3] = 255; return Image.fromarray(a)

# caco: Doom-format lumps decoded with PLAYPAL; its magenta body indices (250-254) are shown through a red translation
def caco(name):
    im = np.array(lmp.load(f'{CACO}/{name}.lmp')).copy()
    P = lmp.PAL; red = {250: 173, 251: 176, 252: 180, 253: 184, 254: 188}
    for s, d in red.items():
        m = (im[..., :3] == P[s]).all(-1) & (im[..., 3] > 0); im[m, :3] = P[d]
    return Image.fromarray(im)

# ------------------------------------------------------------------ draw ops: (rgb, al, m, ox, oy, add, clip)
def op(im, x, y, sc=2, rot=0, flip=False, add=False, a=1.0, clip=False, sil=None):
    if sc != 1: im = im.resize((max(1, round(im.width * sc)), max(1, round(im.height * sc))), Image.NEAREST)
    if flip: im = im.transpose(Image.FLIP_LEFT_RIGHT)
    if rot % 4: im = im.rotate(90 * (rot % 4), expand=True)
    ar = np.asarray(im).astype(float); al = (ar[..., 3] > 127).astype(float); rgb = ar[..., :3].copy()
    if sil is not None: rgb[:] = sil
    ys, xs = np.nonzero(al)
    if len(xs) == 0: return None
    ox = int(round(x - xs.mean() - .5)); oy = int(round(y - ys.mean() - .5))
    if clip:
        cut_ = int(FLOOR + 1 - oy)
        if cut_ < al.shape[0]: al = al.copy(); al[max(0, cut_):] = 0
    return [rgb, al, a, ox, oy, add]

# ------------------------------------------------------------------ the rocket and its trail (with the FLASHBACK)
SPEED = 25.0   # px per tic (20 map units)
class Rocket:
    """the projectile: nose at P(t) = hit + dir*SPEED*t for t<0; sprite never pitched (Doom billboards it)"""
    def __init__(s, hit, d):
        s.hit = hit; s.d = d; s.start = -99; s.len = 99; s.z = 6
    def nose(s, t): return s.hit[0] + s.d[0] * SPEED * t, s.hit[1] + s.d[1] * SPEED * t
    def ops(s, t):
        if t >= 0: return []
        x, y = s.nose(t); im = ROCKET
        cx, cy = x - s.d[0] * 20, y - s.d[1] * 20
        out = [op(im, cx, cy, 1)]
        # flame flicker: a 2-4px hot tail tick that changes length each tic
        tx, ty = x - s.d[0] * 41, y - s.d[1] * 41
        n = (3, 6, 4)[(t + 99) % 3]
        rgb = np.zeros((2, n, 3)); rgb[:, :] = (255, 230, 120); rgb[:, n // 2:] = (255, 140, 30)
        out.append([rgb, np.ones((2, n)), 1.0, int(tx - n), int(ty), True])
        return [o for o in out if o]

class Trail:
    """two puffs a tic behind the tail. unlit: RST0 A (1) B (2) hot bits, then blocky grey smoke (rc_grey recoloured in
    four flat bands) growing a frame every 5 tics, drifting up and sideways, then breaking up.
    FLASHBACK: a fire front leaves the blast at tic 2 and runs back along the trail at FS px/tic up to REACH px; each
    puff it reaches: white 1 tic -> gold -> red -> brown -> soot, held longer, then breaks up."""
    def __init__(s, rocket, t_first, seed=3, FS=26.0, REACH=0, front0=2, d0=44):
        r = random.Random(seed); s.p = []; s.z = 3; s.start = -99; s.len = 99
        s.hit = rocket.hit; s.d = rocket.d; s.FS = FS; s.REACH = REACH; s.f0 = front0; s.d0 = d0
        for t in range(t_first, 0):
            for k in (0, 1):
                tt = t + k * .5
                nx, ny = rocket.nose(tt); x, y = nx - s.d[0] * 40, ny - s.d[1] * 40
                dist = math.hypot(x - s.hit[0], y - s.hit[1])
                ign = None
                if dist < d0: ign = 1
                elif dist < REACH: ign = front0 + int((dist - d0) / FS) + 1
                s.p.append(dict(t0=t + (1 if k else 0), x=x + r.uniform(-2, 2), y=y + r.uniform(-3, 3), dist=dist, ign=ign,
                                life=r.randint(52, 74), rot=r.randrange(4), flip=r.random() < .5, big=r.random() < .4,
                                vx=r.uniform(-.3, .3), vy=-r.uniform(.15, .4), ph=r.uniform(0, 6)))
    def grow(s, a): return min(5, 1 + a // 5)
    def pos(s, q, t):
        a = t - q['t0']; return q['x'] + q['vx'] * a + math.sin(q['ph'] + a * .15) * 1.5, q['y'] + q['vy'] * a
    def ops(s, t):
        out = []
        for q in s.p:
            a = t - q['t0']
            if a < 0: continue
            x, y = s.pos(q, t); fr = None; pal = GT
            if q['ign'] is not None and t >= q['ign']:
                if q['dist'] < s.d0: continue                       # swallowed by the blast
                b = t - q['ign']; k = s.grow(q['ign'] - q['t0'])
                big = q['big']
                if b == 0: out.append(op(GT[k], x, y, 2.6 if big else 2.2, q['rot'], q['flip'], sil=(255, 255, 240))); continue
                lift = b * (1.2 if big else .7)
                seq = [YBh[6], YBh[8], YBh[8], REDh[3], REDh[5], YBh[10], YBh[11]]
                if not big: seq = [REDh[2], REDh[4], REDh[5], YBh[11]]
                if b <= len(seq): out.append(op(seq[b - 1], x, y - lift, 4 if big else 2, q['rot'] + b // 3, q['flip'])); continue
                pal = GS; life = q['life'] + 16; y -= (8 if q['big'] else 3) + (b - 8) * .3
            else: life = q['life']
            if a == 0: fr = (RST[0], 2)
            elif a < 3: fr = (RST[1], 2)
            elif a < life: fr = (pal[min(7, s.grow(a) + (1 if pal is GS else 0))], 2)
            else:
                k = 12 + (a - life) // 3
                if k > 15: continue
                fr = (pal[k], 2)
            out.append(op(fr[0], x, y, fr[1], q['rot'], q['flip']))
        return [o for o in out if o]
    def draw(s, c, t):
        """the front itself: a hard 2px fuse line from the last front point to the new one (white head), + a spark"""
        if t < s.f0: return
        d1 = s.d0 + (t - s.f0) * s.FS
        if d1 > s.REACH + 10: return
        d0 = max(s.d0 - 10, d1 - s.FS * 1.6)
        hx, hy = s.hit[0] - s.d[0] * d1, s.hit[1] - s.d[1] * d1
        tx, ty = s.hit[0] - s.d[0] * d0, s.hit[1] - s.d[1] * d0
        line(c, hx, hy - 4, tx, ty - 4, [(255, 255, 240), (255, 230, 120), (255, 160, 40), (190, 60, 0)], 2)
        r = random.Random(t * 31)
        for k in range(4):
            px(c, hx + r.randint(-6, 6), hy - 4 + r.randint(-9, 5), (255, 220, 110), 2)

# ------------------------------------------------------------------ the BOIL: a churning block of fire, no mushroom
class Boil:
    """puffs orbit two counter-rolling vortices either side of the jet axis (fire rolls out along the jet in the middle,
    back along the sides), so the mass churns in place; each puff: white -> gold boil (frame cycling, quarter turns) ->
    red -> brown -> umber smoke; hot pockets flare inside the dark mass; then the whole block lifts and breaks up."""
    def __init__(s, cx, cy, jet=(0, -1), start=1, n=18, R=40, seed=5, clip=False, life=44, cool0=9, rise=(0, -.45), jo=.3):
        r = random.Random(seed); s.cx, s.cy = cx, cy; s.j = jet; s.pp = (-jet[1], jet[0]); s.clip = clip
        s.start = start; s.len = life + 24; s.z = 4; s.R = R * U; s.rise = rise; s.P = []; s.jo = jo
        for i in range(n):
            side = 1 if i % 2 == 0 else -1
            sp = start + i if i < 6 else start + 3 + (i - 6) // 2           # child bursts one per tic, then fill
            rho = s.R * r.uniform(.2, .62); ph = r.uniform(0, 2 * math.pi)
            outer = rho / s.R
            cool = start + cool0 + r.randint(0, 5) + int((1 - outer) * 6)
            red = r.random() < .35
            die = start + life + r.randint(-6, 6) - (4 if outer > .5 else 0)
            s.P.append(dict(side=side, sp=sp, rho=rho, ph=ph, cool=cool, red=red, die=die, rot=r.randrange(4),
                            flip=r.random() < .5, w=r.uniform(.09, .14), pocket=[r.randint(start + 12, start + 30) for _ in range(2)]))
    def centre(s, t):
        g = t - s.start; e = 1 + .3 * (1 - math.exp(-max(0, g) / 7))
        lift = max(0, g - 14); lx = s.rise[0] * lift; ly = s.rise[1] * lift - (.012 * lift * lift if s.rise[1] else 0)
        return s.cx + lx, s.cy + ly, e
    def pos(s, q, t):
        cx, cy, e = s.centre(t); a = t - q['sp']
        vx = cx + s.j[0] * s.R * s.jo * e + s.pp[0] * q['side'] * s.R * .5 * e
        vy = cy + s.j[1] * s.R * s.jo * e + s.pp[1] * q['side'] * s.R * .5 * e
        ang = q['ph'] + q['side'] * q['w'] * a
        # rotation sense: puffs on the inner side move along the jet (see design note in the report)
        ox = math.cos(ang) * q['rho'] * e; oy = math.sin(ang) * q['rho'] * e
        x, y = vx + ox, vy + oy
        if a < 3:                                              # child burst: thrown from the centre out to its orbit
            k = (a + 1) / 3; x = cx + (x - cx) * k; y = cy + (y - cy) * k
        return x, y
    def frame(s, q, t):
        a = t - q['sp']
        if a < 0: return None
        rot = q['rot'] + (a // 3); fl = q['flip']
        if a == 0: return YB[5], rot, 'fire'
        if t < q['cool']:
            seq = [RED[1], RED[2], RED[3], RED[2]] if q['red'] else [YB[6], YB[7], YB[8], YB[7]]
            return seq[(a // 2) % 4], rot, 'fire'
        b = t - q['cool']
        if b < 5: return (RED[4] if b < 3 else RED[5]), rot, 'red'
        if b < 9: return (YB[9] if b < 7 else YB[10]), rot, 'brown'
        if t < q['die']:
            if t in q['pocket'] or t - 1 in q['pocket']: return YB[7], rot, 'pocket'
            k = (4, 5)[((t - q['cool']) // 6) % 2] + (1 if t > q['die'] - 10 else 0)
            return (GR[min(11, k)] if q['red'] else GU[k + 1]), q['rot'] + (t - q['cool']) // 8, 'smoke'
        k = 12 + (t - q['die']) // 3
        if k > 15: return None
        return GU[k], q['rot'], 'smoke'
    def ops(s, t):
        layers = {'smoke': [], 'brown': [], 'red': [], 'fire': [], 'pocket': []}
        for q in s.P:
            f = s.frame(q, t)
            if f is None: continue
            im, rot, ph = f; x, y = s.pos(q, t)
            sc = 2 if ph != 'pocket' else 1
            o = op(im, x, y, sc, rot, q['flip'], clip=s.clip)
            if o: layers[ph].append(o)
            if ph == 'pocket':                                     # pocket shows through its smoke puff
                o2 = op(GU[5], x, y, 2, q['rot'], q['flip'], clip=s.clip)
                if o2: layers['smoke'].append(o2)
        return layers['smoke'] + layers['brown'] + layers['red'] + layers['fire'] + layers['pocket']

class Core:
    """the fuel ball under the boil: 2-tic white silhouette (the flash), then rc_x10 burning down to brown at 2x"""
    def __init__(s, cx, cy, clip=False, start=0):
        s.cx, s.cy, s.clip, s.start = cx, cy, clip, start; s.z = 2; s.len = 30
        s.seq = [(X10[4], 'w'), (X10[5], 'w'), (X10[6], ''), (X10[7], ''), (X10[8], ''), (X10[8], ''), (X10[9], ''), (X10[9], ''),
                 (X10[10], ''), (X10[10], ''), (X10[11], ''), (X10[11], ''), (X10[12], ''), (X10[12], ''), (X10[12], '')]
    def ops(s, t):
        a = t - s.start
        if a < 0 or a >= len(s.seq): return []
        im, w = s.seq[a]
        sc = 2.4 if a == 0 else 2.6 if a == 1 else 2
        o = op(im, s.cx, s.cy, sc, a // 4, clip=s.clip, sil=(255, 255, 255) if w else None)
        if a == 1 and o: o2 = op(im, s.cx, s.cy, 1.6, 1, clip=s.clip, sil=(255, 255, 255)); return [o]
        return [o] if o else []

class Backblast:
    """tic 1-3: a tongue of fire thrown back up the incoming line + hard streaks in a narrow cone (the flashback's match)"""
    def __init__(s, hit, d, clip=False, seed=9):
        s.h = hit; s.d = d; s.clip = clip; s.z = 5; s.start = 0; s.len = 12; s.r = random.Random(seed)
        s.st = [(s.r.uniform(-.28, .28), s.r.uniform(70, 130)) for _ in range(7)]
    def ops(s, t):
        out = []
        for k, (dd, t0) in enumerate([(22, 1), (42, 2), (60, 3)]):
            a = t - t0
            if a < 0 or a > 7: continue
            fr = [YB[5], YB[6], YB[7], YB[7], YB[8], RED[4], RED[5], YB[10]][a]
            x, y = s.h[0] - s.d[0] * dd, s.h[1] - s.d[1] * dd - a * .8
            o = op(fr, x, y, 2 if k == 0 else 1.5 if k == 1 else 1, k + a // 3, clip=s.clip)
            if o: out.append(o)
        return out
    def draw(s, c, t):
        if not (1 <= t <= 2): return
        for ang, ln in s.st:
            ca, sa = math.cos(ang), math.sin(ang)
            dx = -(s.d[0] * ca - s.d[1] * sa); dy = -(s.d[0] * sa + s.d[1] * ca)
            r0, r1 = (30, ln) if t == 1 else (ln * .6, ln * 1.35)
            cols = [(255, 255, 240), (255, 230, 120), (255, 160, 40)] if t == 1 else [(255, 170, 40), (170, 50, 0)]
            line(c, s.h[0] + dx * r1, s.h[1] + dy * r1, s.h[0] + dx * r0, s.h[1] + dy * r0, cols, 2 if t == 1 else 1)

# ------------------------------------------------------------------ sparks, debris, motor stub
HOT4, HOT3, HOT2 = seqg.HOT4, seqg.HOT3, seqg.HOT2
class Spray:
    """hard pixel spark streaks (structure copied from seqg.Shrapnel): angle range in degrees (math, y up), wall and
    floor bounces; fewer and slower than the frag's shrapnel"""
    def __init__(s, cx, cy, a0, a1, n=22, vmax=40, seed=1, WX=None, start=0):
        r = random.Random(seed); s.start = start; s.len = 40; s.z = 7; s.tr = []; s.spk = []
        for i in range(n):
            ang = math.radians(r.uniform(a0, a1)); v = r.uniform(.4, 1) * vmax; t0 = r.choice([0, 0, 1, 1, 2])
            x, y = cx, cy; vx, vy = math.cos(ang) * v * U, -math.sin(ang) * v * U; P = [(x, y, v)]; nb = 0
            for t in range(r.randint(8, 13)):
                for k in range(4):
                    x += vx / 4; y += vy / 4; vy += 1.4 * U / 4
                    if WX and x >= WX - 1 and vx > 0: x = WX - 1; vx = -abs(vx) * .4
                    if y >= FLOOR - 1 and vy > 0:
                        y = FLOOR - 1; vy = -abs(vy) * .3; vx *= .55
                        if nb == 0: s.spk.append((t0 + t + 1, x, y))
                        nb += 1
                vx *= .8; vy *= .8; P.append((x, y, math.hypot(vx, vy) / U))
            s.tr.append((t0, P, i % 4 == 0))
    def draw(s, c, t):
        for t0, P, big in s.tr:
            dt = t - t0
            if dt < 0 or dt + 1 >= len(P): continue
            x1, y1, v = P[dt + 1]; x0, y0, _ = P[dt]
            cols = HOT4 if v > 25 else HOT3 if v > 11 else HOT2 if v > 4 else None
            if cols is None: continue
            line(c, x1, y1, x0 + (x1 - x0) * .05, y0 + (y1 - y0) * .05, cols, 1)
            if big and v > 11: px(c, x1 - 1, y1 - 1, cols[0], 2)
        for tm, x, y in s.spk:
            dt = t - tm
            if 0 <= dt < 2:
                col = (255, 250, 200) if dt == 0 else (255, 170, 40); rr = 3 if dt == 0 else 2
                for k in range(-rr, rr + 1): px(c, x + k, y - 1, col); px(c, x, y - 1 + k, col)

class Chunks:
    """debris (copy of seqg.Debris without the mirrored pairs): hard blocks thrown in an angle range, hot for a few tics
    (if hot), bounce on the floor (each at its own depth), off a wall, slide, settle and stay"""
    def __init__(s, cx, cy, a0, a1, n=24, speed=(5, 14), seed=2, cols=((96, 84, 74), (110, 98, 86), (84, 76, 72)),
                 hot=True, WX=None, start=1, sizes=None, drops=None):
        r = random.Random(seed); s.start = start; s.b = []; s.len = 200; s.z = 8; s.hot = hot; s.drops = drops or []
        for i in range(n):
            ang = math.radians(r.uniform(a0, a1)); v = r.uniform(*speed) * U
            w, h = r.choice(sizes or [(3, 3), (4, 3), (3, 4), (4, 4), (5, 3), (3, 2), (2, 2), (5, 4)])
            dz = r.uniform(0, 16); x, y = cx + r.uniform(-3, 3) * U, cy + r.uniform(-3, 3) * U
            vx, vy = math.cos(ang) * v, -math.sin(ang) * v; P = []; rest = False; t0 = start + r.choice([0, 0, 1])
            for t in range(140):
                if not rest:
                    x += vx; y += vy; vy += 1.1 * U; vx *= .97
                    if WX and x > WX - w - 1 and vx > 0: x = WX - w - 1; vx = -vx * .45
                    fy = FLOOR + dz - h
                    if y >= fy:
                        y = fy
                        if abs(vy) < 2.2 * U: rest = True; vy = 0
                        else: vy = -abs(vy) * .42; vx *= .62
                P.append((x, y, rest))
            s.b.append((t0, P, w, h, r.choice(cols)))
    def draw(s, c, t):
        for t0, P, w, h, dark in s.b:
            dt = t - t0
            if dt < 0: continue
            x, y, rest = P[min(dt, len(P) - 1)]
            xi, yi = int(round(x)), int(round(y))
            if not (0 <= xi < CW - w and 0 <= yi < CH - h): continue
            if s.hot and dt < 4: c[yi:yi + h, xi:xi + w] += np.array((255, 200, 90))
            elif s.hot and dt < 8: c[yi:yi + h, xi:xi + w] += np.array((230, 100, 25))
            else:
                c[yi:yi + h, xi:xi + w] = dark; c[yi, xi] = np.minimum(np.array(dark) + 60, 255)
        for d in s.drops: d.draw(c, t)

class Drops:
    """caco blood: blue pixel drops that fall and leave a flat 2px stain on the floor"""
    def __init__(s, cx, cy, n=14, seed=4, start=1):
        r = random.Random(seed); s.d = []
        for i in range(n):
            ang = math.radians(r.uniform(20, 160)); v = r.uniform(2, 7) * U
            s.d.append((start + r.randint(0, 3), cx + r.uniform(-8, 8), cy + r.uniform(-8, 8), math.cos(ang) * v, -math.sin(ang) * v, r.uniform(0, 10)))
    def draw(s, c, t):
        for t0, x, y, vx, vy, dz in s.d:
            dt = t - t0
            if dt < 0: continue
            xx, yy = x, y; ux, uy = vx, vy
            for k in range(dt):
                xx += ux; yy += uy; uy += 1.1 * U; ux *= .95
                if yy >= FLOOR + dz: break
            if yy >= FLOOR + dz: px(c, xx - 1, FLOOR + 1 + dz * .5, (24, 40, 120), 2, False); px(c, xx + 1, FLOOR + 1 + dz * .5, (16, 28, 90), 2, False)
            else: px(c, xx, yy, (60, 90, 230), 2, False); px(c, xx, yy - 2, (30, 50, 160), 2, False)

class Stub:
    """the spent rocket motor: a hard grey 8x3 bar (quarter-turn tumble) thrown out of the blast, a flickering 1-3px
    flame at its end and a puff of grey every 3 tics, bounces once or twice and lies on the floor, smoking"""
    def __init__(s, x, y, vx, vy, WX=None, start=2, seed=8):
        r = random.Random(seed); s.start = start; s.len = 60; s.z = 9; s.P = []; s.puffs = []
        rest = False; spin = 0
        for t in range(90):
            if not rest:
                x += vx; y += vy; vy += .9 * U; vx *= .98; spin += 1
                if WX and x > WX - 6 and vx > 0: x = WX - 6; vx = -vx * .5
                if y >= FLOOR - 2:
                    y = FLOOR - 2
                    if abs(vy) < 2.4 * U: rest = True; vy = 0; vx = 0
                    else: vy = -abs(vy) * .4; vx *= .6
            s.P.append((x, y, spin, rest))
            if t % 4 == 0 and t < 54: s.puffs.append((start + t, x, y - 2, r.choice([-1, 1]) * r.uniform(.4, .8)))
    def draw(s, c, t):
        a = t - s.start
        if a < 0: return
        for t0, x, y, vx in s.puffs:                           # thin smoke: tiny grey squares rising
            b = t - t0
            if 0 <= b < 12:
                col = (120, 118, 116) if b < 5 else (86, 84, 84) if b < 9 else (58, 58, 60); w = 2 if b < 6 else 3
                px(c, x + vx * b, y - b * .9, col, w, False)
        x, y, spin, rest = s.P[min(a, len(s.P) - 1)]
        q = (spin // 2) % 4 if not rest else 0
        body = [(i, 0) for i in range(-5, 5)] if q in (0, 2) else [(0, i) for i in range(-5, 5)] if q == 1 else [(i, i) for i in range(-4, 4)]
        for (i, j) in body:
            for w in (-1, 0, 1):
                ex, ey = (i, j + w) if q in (0, 2) else (i + w, j) if q == 1 else (i + w, j)
                px(c, x + ex, y + ey, (84, 82, 90) if w else (168, 164, 166), 1, False)
        if a < 34 and (t % 3):                                 # sputtering flame at the open end
            fx_, fy_ = (x - 7, y - 1) if q in (0, 2) else (x - 1, y + 6) if q == 1 else (x - 6, y - 6)
            px(c, fx_, fy_, (255, 230, 120), 2, False); px(c, fx_ - 2 + (t % 2), fy_, (255, 140, 30), 1, False)

# ------------------------------------------------------------------ context helpers (copied from /tmp/fx_ctx1/ctx_a.py)
def fold_x(img, ox, oy, WX, k=.45, s=1.5):
    wx = WX - ox
    if wx >= img.width: return img, ox, oy
    a = np.array(img); h = a.shape[0]
    near = a[:, :max(0, wx)]; far = a[:, max(0, wx):][:, ::-1]
    fw = max(1, round(far.shape[1] * k)); fh = max(1, round(h * s))
    farim = Image.fromarray(np.ascontiguousarray(far)).resize((fw, fh), Image.NEAREST)
    W = max(max(0, wx), fw); H = max(h, fh)
    out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    if wx > 0: out.paste(Image.fromarray(np.ascontiguousarray(near)), (W - wx, (H - h) // 2))
    out.alpha_composite(farim, (W - fw, (H - fh) // 2))
    return out, WX - W, oy - (H - h) // 2
def make_scorch(cx, cy, rx, ry_up, ry_dn, seed, W=CW, H=CH, grid=2):
    r = random.Random(seed); m = np.zeros((H, W), np.int8)
    for y in range(0, H, grid):
        for x in range(0, W, grid):
            dx = (x - cx) / rx; dy = (y - cy) / (ry_up if y < cy else ry_dn)
            d = math.sqrt(dx * dx + dy * dy) + r.uniform(-.13, .13)
            m[y:y + grid, x:x + grid] = 3 if d < .42 else 2 if d < .7 else 1 if d < 1 else 0
    return m
def bands(d, levels=(.55, .32, .14)):
    n = len(levels); return np.select([d < (i + 1) / n for i in range(n)], list(levels), 0)
def to_img(rgb, al): return Image.fromarray(np.dstack([np.clip(rgb, 0, 255), al * 255]).astype(np.uint8))
def from_img(im): a = np.asarray(im).astype(float); return a[..., :3], (a[..., 3] > 127).astype(float)

class WallCtx:
    """wall face at x=WX (solid to the right), seen edge-on (copied from ctx_g.WallG): fire folds at the plane, scorch
    grows hot then cools to soot and stays, blast light in three flat bands, spark pocks"""
    def __init__(s, WX, cy):
        s.WX = WX; s.cy = cy
        yy, xx = np.mgrid[0:CH, 0:CW]
        b = np.zeros((CH, CW, 3)); b[:] = (52, 48, 50)
        b[(yy % 12) == 0] = (32, 30, 31); b[((xx - WX + (yy // 12 % 2) * 12) % 24 == 0)] = (32, 30, 31)
        b[:, WX:WX + 2] = (88, 84, 86); s.brick = b
        s.sc = make_scorch(WX, cy - 4, 30, 70, 34, 13)
        s.ld = np.sqrt(((xx - WX) / 48) ** 2 + ((yy - cy) / 86) ** 2); s.lenv = env(1.0, 1, 12)
    def xf(s, o, t, item):
        rgb, al, m, ox, oy, add = o
        if ox + al.shape[1] <= s.WX: return [o]
        f, nox, noy = fold_x(to_img(rgb, al), ox, oy, s.WX, .35, 1.5)
        r2, a2 = from_img(f); return [[r2, a2, m, nox, noy, add]]
    def fold_pixels(s, tmp):
        W = s.WX; over = tmp[:, W:]; n = min(over.shape[1], W)
        tmp[:, W - n:W] += over[:, :n][:, ::-1] * .7; tmp[:, W:] = 0
    def fg(s, c, t):
        W = s.WX; c[:, W:] = s.brick[:, W:]
        if t >= 1:
            dt = t - 1; m = s.sc
            if dt < 4: m = np.where(m >= 3 - int((dt + 1) / 4 * 3), m, 0)
            if dt < 3: cols = {3: (255, 190, 90), 2: (190, 80, 20)}
            elif dt < 8: cols = {3: (120, 40, 14), 2: (60, 26, 16), 1: (36, 28, 26)}
            else: cols = {3: (9, 8, 8), 2: (18, 16, 15), 1: (32, 29, 28)}
            for lv, col in cols.items():
                sel = (m == lv); sel[:, :W] = False; c[sel] = col
            c[:, W:W + 2] = np.where((m[:, W:W + 2] >= 2)[..., None], c[:, W:W + 2], (88, 84, 86))
        e = s.lenv(t) if t >= 0 else 0
        if e > 0: c[:, W:] += (bands(s.ld, (.5, .28, .12))[..., None] * np.array((255, 150, 60)) * e)[:, W:]
        c[FLOOR, W:] = (70, 68, 76)

class FloorScorch:
    """flat ragged scorch on the floor plane (2px grid, three bands): hot, then cools to soot and stays"""
    def __init__(s, cx, rx=70, seed=21):
        s.m = make_scorch(cx, FLOOR + 10, rx, 9, 9, seed); s.m[:FLOOR + 1] = 0; s.z = -5; s.start = 0; s.len = 1
    def draw(s, c, t):
        if t < 1: return
        dt = t - 1; m = s.m
        if dt < 3: m = np.where(m >= 3 - dt, m, 0)
        cols = {3: (255, 190, 90), 2: (190, 80, 20)} if dt < 3 else {3: (120, 40, 14), 2: (60, 26, 16), 1: (30, 24, 22)} if dt < 8 \
            else {3: (8, 7, 7), 2: (13, 12, 12), 1: (19, 18, 20)}
        for lv, col in cols.items(): c[m == lv] = col

# ------------------------------------------------------------------ renderer
POINT = (seqg.PixRing, seqg.Embers, Spray, Backblast)
def run(items, T0, end, ctx=None, floorlight=None, actor=None, guide=None):
    frames = []
    for t in range(-T0, end):
        c = background()
        if floorlight and t >= 0: floorlight(c, t)
        tmp = np.zeros_like(c)
        for it in sorted(items, key=lambda i: getattr(i, 'z', 0)):
            if actor and getattr(it, 'z', 0) >= 2 and not getattr(actor, 'done', False) and t >= -T0:
                pass
            if hasattr(it, 'ops'):
                for o in it.ops(t):
                    for o2 in (ctx.xf(o, t, it) if ctx else [o]): blit(c, *o2)
            if hasattr(it, 'draw'):
                if ctx and isinstance(it, POINT): it.draw(tmp, t)
                else: it.draw(c, t)
            elif not hasattr(it, 'ops'):
                r = it.render(t)
                if r:
                    o = [*r, it.add]
                    for o2 in (ctx.xf(o, t, it) if ctx else [o]): blit(c, *o2)
        if ctx: ctx.fold_pixels(tmp)
        c += tmp
        if ctx: ctx.fg(c, t)
        frames.append(Image.fromarray(np.clip(c, 0, 255).astype(np.uint8)))
    return frames

class Actor:
    """wraps a callable drawing something (the caco) into the item list at a given z"""
    def __init__(s, fn, z): s.fn = fn; s.z = z; s.start = -99; s.len = 99
    def draw(s, c, t): s.fn(c, t)

def unit(dx, dy): n = math.hypot(dx, dy); return dx / n, dy / n

# ================================================================== SHOT 1: WALL (head height)
def shot_wall(seed=1):
    rng = random.Random(seed); T0 = 26
    WX = 520; cy = int(Z(52)); hit = (WX - 2, cy); d = (1.0, 0.0)
    bx, by = WX - 14, cy                                      # A_Explode a rocket's radius off the wall
    rk = Rocket(hit, d)
    items = [rk, Trail(rk, -T0, seed=3, REACH=0)]
    items += [Core(bx, by), Boil(bx, by, jet=(-1, 0), start=1, n=20, R=46, seed=5, rise=(-.3, -.5), jo=.75, clip=True),
              Backblast((bx, by), d)]
    items += seqg.pops(rng, bx, by, size=64)
    items.append(seqg.PixRing(bx, by, 128, 1, 7, r0=22))
    items.append(Spray(bx, by, 100, 260, n=26, vmax=42, seed=11, WX=WX))
    items.append(Chunks(bx - 4, by, 110, 230, n=26, speed=(4, 12), seed=12, WX=WX,
                        cols=((70, 64, 66), (92, 86, 88), (58, 54, 56))))       # brick/plaster chips, back at the shooter
    items.append(seqg.Embers(3, bx - 10, by, seed=13))
    items.append(Stub(bx - 6, by - 4, -5.5, -6.5, WX=WX, start=2))
    ctx = WallCtx(WX, cy)
    fl = banded_glow(env(1.0, 1, 12), (255, 150, 60), w=round(330 * U), h=30, cx=bx)
    return run(items, T0, 76, ctx, fl), T0

# ================================================================== SHOT 2: FLOOR (a monster's feet)
def shot_floor(seed=2):
    rng = random.Random(seed); T0 = 24
    d = unit(1.0, .30); hit = (BX + 6, FLOOR - 3)
    bx, by = BX, FLOOR - 14
    rk = Rocket(hit, d)
    items = [FloorScorch(BX, 66), rk, Trail(rk, -T0, seed=4, REACH=0)]
    items += [Core(bx, by, clip=True), Boil(bx, by - 6, jet=(0, -1), start=1, n=20, R=42, seed=6, clip=True, rise=(0, -.55), jo=.75),
              Backblast(hit, d, clip=True)]
    items += seqg.pops(rng, bx, FLOOR - 4 * U, size=70)
    items.append(seqg.PixRing(bx, FLOOR + 2, 128, 1, 7, squash=.12, floor_cut=False, r0=24))
    for k, (dd, tt) in enumerate([(60, 2), (-60, 2), (110, 4), (-110, 4), (150, 6), (-150, 6)]):
        items.append(L(pick('ruf_dust', [1, 2, 2]), [2, 3, 4], start=tt, pos=(bx + dd * U, FLOOR - 5), size=24 + abs(dd) * .05,
                       grow=.6, ramp=fxg.R_DUST, add=False, alpha=.85, fade=.5, clip=True, nokind=True, flip=k % 2 == 1))
    items.append(Spray(bx, FLOOR - 4, 10, 170, n=24, vmax=40, seed=21))
    items.append(Chunks(bx, FLOOR - 6, 25, 155, n=30, speed=(5, 14), seed=22))
    items.append(seqg.Embers(3, bx, FLOOR, seed=23))
    items.append(Stub(bx + 4, FLOOR - 10, 4.0, -9.5, start=2))
    fl = banded_glow(env(1.0, 1, 12), (255, 150, 60), w=round(330 * U), h=34)
    return run(items, T0, 74, None, fl), T0

# ================================================================== SHOT 3: AIR (into a cacodemon)
CAC = {k: caco(n) for k, n in [('A', 'CCMNA2A8'), ('F', 'CCMNF3F7'), ('G', 'CCMNG0'), ('H', 'CCMNH0'), ('I', 'CCMNI0'),
                               ('J', 'CCMNJ0'), ('K', 'CCMNK0'), ('L', 'CCMNL0')]}
def shot_air(seed=3):
    rng = random.Random(seed); T0 = 26
    ccx, ccy = BX + 70, int(Z(150))
    d = unit(1.0, -.22); hit = (ccx - 34, ccy + 4)
    bx, by = hit
    rk = Rocket(hit, d)
    # the caco: hovers (bob), pain flash on the hit, death G-K pushed back by the blast, A_Fall at I, corpse L lands
    seq = [('G', 4), ('H', 4), ('I', 4), ('J', 4), ('K', 4)]
    st = {}
    x, y, vx, vy = float(ccx), float(ccy), 3.2, 0.0; landed = None
    for t in range(0, 120):
        k = 0; acc = 0; fr = 'L'
        for n, dd in seq:
            if t < acc + dd: fr = n; break
            acc += dd
        x += vx; vx *= .86
        if t >= 8: vy += .9 * U; y += vy
        if y >= FLOOR - 24: y = FLOOR - 24; vy = 0; landed = landed or t
        st[t] = (fr, x, y)
    def draw_caco(c, t):
        if t < 0: fr, x, y = 'A', ccx, ccy + round(math.sin((t + 40) * .2) * 2)
        else: fr, x, y = st[t]
        if fr == 'L': y = min(y, FLOOR - 15)
        im = CAC[fr]
        im = im.resize((round(im.width * U), round(im.height * U)), Image.NEAREST)
        a = np.asarray(im).astype(float); al = (a[..., 3] > 127).astype(float); rgb = a[..., :3]
        if t == 0: rgb = np.where(al[..., None] > 0, np.array((255., 255, 255)), rgb)
        h, w = al.shape
        if fr == 'L': blit(c, rgb, al, 1.0, int(x - w / 2), int(FLOOR + 3 - h), False)
        else: blit(c, rgb, al, 1.0, int(x - w / 2), int(y - h / 2), False)
    items = [Actor(draw_caco, 1), rk, Trail(rk, -T0, seed=5, REACH=0)]
    items += [Core(bx, by), Boil(bx + 6, by, jet=(0, -1), start=1, n=20, R=42, seed=7, rise=(0, -.5), jo=.45), Backblast(hit, d)]
    items += seqg.pops(rng, bx, by, size=64)
    items.append(seqg.PixRing(bx, by, 128, 1, 7, r0=22))
    items.append(Spray(bx, by, 0, 360, n=26, vmax=40, seed=31))
    items.append(Chunks(bx + 10, by, 0, 180, n=22, speed=(3, 10), seed=32, hot=False, sizes=[(4, 3), (5, 4), (3, 3), (6, 4), (4, 4)],
                        cols=((150, 22, 18), (110, 14, 12), (186, 52, 36), (84, 10, 10)), drops=[Drops(bx + 16, by, seed=34)]))
    items.append(Chunks(bx, by, 0, 360, n=10, speed=(4, 11), seed=33))                  # hot casing bits
    items.append(seqg.Embers(3, bx, by, seed=35))
    items.append(Stub(bx, by - 4, -3.0, -6.0, start=2))
    fl = banded_glow(env(.55, 1, 9), (255, 150, 60), w=round(330 * U), h=30, cx=bx)
    return run(items, T0, 76, None, fl), T0

# ------------------------------------------------------------------ contact sheet
def contact(shots, path):
    rows = []
    for name, fr, T0, tics, crop in shots:
        w, h = crop[2] - crop[0], crop[3] - crop[1]
        S = Image.new('RGB', (len(tics) * (w + 4), h + 16), (28, 28, 34)); dd = ImageDraw.Draw(S)
        for i, t in enumerate(tics):
            S.paste(fr[t + T0].crop(crop), (i * (w + 4), 16)); dd.text((i * (w + 4) + 3, 3), f'{name} tic {t:+d}', fill=(255, 220, 0))
        rows.append(S)
    W = max(r.width for r in rows); H = sum(r.height for r in rows)
    out = Image.new('RGB', (W, H), (28, 28, 34)); y = 0
    for r in rows: out.paste(r, (0, y)); y += r.height
    out.save(path)

if __name__ == '__main__':
    O = '/tmp/fx_rocket/out'; only = sys.argv[1:]
    res = {}
    for name, fn in [('wall', shot_wall), ('floor', shot_floor), ('air', shot_air)]:
        if only and name not in only: continue
        fr, T0 = fn(); res[name] = (fr, T0)
        for i, f in enumerate(fr): f.save(f'/tmp/fx_rocket/look/{name}_{i - T0:+04d}.png')
        save_gif(fr, f'{O}/R_{name}_full.gif', 1); save_gif(fr, f'{O}/R_{name}_half.gif', 2)
        print(name, len(fr), 'pre', T0)
    if len(res) == 3:
        contact([('WALL', *res['wall'], [-10, -3, 0, 1, 2, 3, 5, 8, 12, 18, 28, 45], (60, 120, 600, 420)),
                 ('FLOOR', *res['floor'], [-8, -2, 0, 1, 2, 4, 6, 9, 14, 22, 32, 48], (0, 120, 540, 420)),
                 ('AIR', *res['air'], [-8, -2, 0, 1, 2, 4, 6, 9, 14, 22, 32, 48], (40, 40, 580, 420))], f'{O}/R_contact.png')
