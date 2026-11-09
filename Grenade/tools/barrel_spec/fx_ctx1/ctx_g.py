"""CONTEXT MODIFIERS on the approved GRENADE frag blast (floor version, /tmp/fx_agentG seqg.floor_shot), 640x420, colours 0..255.
Same throw-in, same blast items; this file bends them against a WALL, or swaps them for their underwater versions (WATER).
Copies of fxg/seqg live in /tmp/fx_ctx1/g (unchanged); physics classes that need a wall are copied here with the wall added."""
import sys, math, random
sys.path.insert(0, '/tmp/fx_ctx1/g'); sys.path.insert(0, '/tmp/fx_ctx1')
import numpy as np
from PIL import Image
import fxg, seqg
from fxg import CW, CH, FLOOR, BX, U, Z, L, blit, px, line, background, env, kcol, strip, pick
import ctx_a                                   # fold_x, make_scorch, Bubbles, Splash, BUBF (shared helpers)

WALL = {'x': None, 'pocks': []}

# ------------------------------------------------------------------ helpers: fold a G layer (rgb float, 1-bit alpha) at the wall
def to_img(rgb, al):
    a = np.dstack([np.clip(rgb, 0, 255), al * 255]).astype(np.uint8); return Image.fromarray(a)
def from_img(im):
    a = np.asarray(im).astype(float); return a[..., :3], (a[..., 3] > 127).astype(float)

# ------------------------------------------------------------------ shrapnel with a wall (copy of seqg.Shrapnel + wall hit)
class WallShrapnel(seqg.Shrapnel):
    def __init__(s, cx, cy, n=44, seed=1, floor=True, vmax=50, start=0):
        WX = WALL['x']
        r = random.Random(seed); s.f = []; s.marks = []; s.sparks = []; s.start = start
        for i in range(n):
            if floor: ang = r.uniform(-6, 186) if i % 5 else r.choice([r.uniform(-6, 10), r.uniform(170, 186)])
            else: ang = (i * 360 / n + r.uniform(-5, 5)) % 360
            big = i % 4 == 0
            v = r.uniform(.68, 1.0) * vmax if (big or r.random() < .6) else r.uniform(.3, .55) * vmax
            d = dict(t0=r.choice([0, 0, 0, 0, 1, 1, 2]), a=math.radians(ang), v=v, big=big, dz=r.uniform(0, 10), life=r.randint(9, 14))
            if floor and i % 2: p_ = s.f[-1]; d = dict(p_, a=math.pi - p_['a'], v=p_['v'] * r.uniform(.9, 1.1), dz=r.uniform(0, 10))
            s.f.append(d)
        s.path = []
        for f in s.f:
            x, y = cx + math.cos(f['a']) * 3 * U, cy - math.sin(f['a']) * 3 * U; vx = math.cos(f['a']) * f['v'] * U; vy = -math.sin(f['a']) * f['v'] * U
            P = [(x, y, math.hypot(vx, vy) / U, False)]; hit = False; whit = False
            for t in range(f['life']):
                bounced = False
                for k in range(4):
                    x += vx / 4; y += vy / 4; vy += 1.4 * U / 4
                    if WX and x >= WX - 1 and vx > 0:                     # WALL: ricochet back, pock + spark on the wall
                        x = WX - 1; bounced = True
                        if not whit and y < FLOOR: WALL['pocks'].append((f['t0'] + t + 1, WX, y, r.random())); whit = True
                        vx = -abs(vx) * .4; vy *= .7
                    if floor and y >= FLOOR + f['dz'] * .5 and vy > 0:
                        y = FLOOR + f['dz'] * .5; bounced = True
                        if not hit: s.marks.append((f['t0'] + t + 1, x, FLOOR + 1 + f['dz'], r.random()))
                        hit = True; vy = -abs(vy) * .3; vx *= .55
                vx *= .8; vy *= .8
                P.append((x, y, math.hypot(vx, vy) / U, bounced))
                if bounced and len([1 for q in P if q[3]]) <= 2: s.sparks.append((f['t0'] + t + 1, x, y))
            s.path.append(P)
        s.len = max(f['t0'] + len(P) for f, P in zip(s.f, s.path)) + 60

class WallDebris(seqg.Debris):
    """copy of seqg.Debris with a wall bounce"""
    def __init__(s, cx, cy, n=30, seed=2, cone=150, up=90, speed=(5, 15), start=1, full=False):
        WX = WALL['x']; r = random.Random(seed); s.start = start; s.b = []
        for i in range(n):
            if i % 2 == 0: ang = math.radians(r.uniform(0, 360) if full else up + r.uniform(-cone / 2, cone / 2)); v = r.uniform(*speed) * U
            else: ang = math.pi - ang; v *= r.uniform(.92, 1.08)
            w, h = r.choice([(3, 3), (4, 3), (3, 4), (4, 4), (5, 3), (3, 2), (2, 2)])
            dz = r.uniform(0, 16); x, y = cx + r.uniform(-3, 3) * U, cy + r.uniform(-3, 3) * U; vx, vy = math.cos(ang) * v, -math.sin(ang) * v
            P = []; rest = False; t0 = start + r.choice([0, 0, 1])
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
            s.b.append((t0, P, w, h, r.choice([(96, 84, 74), (110, 98, 86), (84, 76, 72)])))
        s.len = 200

# ================================================================== WALL
class WallG:
    def __init__(s, WX, cy):
        s.WX = WX; s.cy = cy
        yy, xx = np.mgrid[0:CH, 0:CW]
        b = np.zeros((CH, CW, 3)); b[:] = (52, 48, 50)
        b[(yy % 12) == 0] = (32, 30, 31); b[((xx - WX + (yy // 12 % 2) * 12) % 24 == 0)] = (32, 30, 31)
        b[:, WX:WX + 2] = (88, 84, 86); s.brick = b
        s.sc = ctx_a.make_scorch(WX, cy - 6, 34, 74, 30, 11, W=CW, H=CH)
        s.ld = np.sqrt(((xx - WX) / 44) ** 2 + ((yy - cy) / 80) ** 2)
        s.lenv = env(1.0, 1, 10)
    def layer(s, it, r, t):
        rgb, al, m, ox, oy = r
        g = (t - it.start) / max(1, it.len - 1)
        if it.ramp is fxg.R_DUST and it.pos[0] > s.WX - 10: return []   # no floor-grit puffs inside/at the wall
        if not it.add: ox -= int(.6 * (t - it.start))         # soot drifts off the wall
        if ox + al.shape[1] <= s.WX: return [r]
        im = to_img(rgb, al)
        out = []
        f, nox, noy = ctx_a.fold_x(im, ox, oy, s.WX, .35, 1.6 + 1.0 * g)
        out.append((*from_img(f), m, nox, noy))
        if it.add:                                              # the sheet: a D of the blast pressed on the wall face
            hgt = max(1, round(im.height * (1.5 + .9 * g))); wid = max(3, round(im.width * .22))
            sh = im.resize((2 * wid, hgt), Image.NEAREST).crop((0, 0, wid, hgt))
            sr, sa = from_img(sh)
            if it.clip: cut = int(FLOOR + 1 - (oy + im.height // 2 - hgt // 2)); sa[max(0, cut):] = 0
            out.append((sr, sa, m, s.WX - wid, oy + im.height // 2 - hgt // 2))
        return out
    def fold_pixels(s, tmp):
        """point items (rings, rays, embers) drawn in tmp: whatever went past the wall is reflected back, dimmer"""
        W = s.WX; over = tmp[:, W:]
        n = min(over.shape[1], W)
        tmp[:, W - n:W] += over[:, :n][:, ::-1] * .7
        tmp[:, W:] = 0
    def fg(s, c, t):
        W = s.WX; c[:, W:] = s.brick[:, W:]
        if t >= 1:
            dt = t - 1; m = s.sc
            if dt < 4: m = np.where(m >= 3 - int((dt + 1) / 4 * 3), m, 0)
            if dt < 3: cols = {3: (255, 190, 90), 2: (190, 80, 20)}
            elif dt < 7: cols = {3: (120, 40, 14), 2: (60, 26, 16), 1: (36, 28, 26)}
            else: cols = {3: (9, 8, 8), 2: (18, 16, 15), 1: (32, 29, 28)}
            for lv, col in cols.items():
                sel = (m == lv); sel[:, :W] = False; c[sel] = col
            c[:, W:W + 2] = np.where((m[:, W:W + 2] >= 2)[..., None], c[:, W:W + 2], (88, 84, 86))
        e = s.lenv(t) if t >= 0 else 0
        if e > 0: c[:, W:] += (ctx_a.bands(s.ld, (.5, .28, .12))[..., None] * np.array((255, 150, 60)) * e)[:, W:]
        for tm, x, y, rv in WALL['pocks']:                     # shrapnel pocks on the wall: spark, hot, then dark, stay
            dt = t - tm
            if dt < 0: continue
            xi, yi = int(x) + 1, int(y)
            if dt < 2:
                for k in range(-3, 4): px(c, xi - 1 - abs(k) // 2, yi + k, (255, 240, 180), 1, False)
                for k in range(1, 5): px(c, xi - 1 - k, yi - k // 2, (255, 200, 90), 1, False); px(c, xi - 1 - k, yi + k // 2, (255, 200, 90), 1, False)
            col = (255, 210, 110) if dt < 2 else (230, 100, 20) if dt < 5 else (110, 40, 10) if dt < 9 else (16, 14, 13)
            px(c, xi, yi, col, 2, False)
        c[FLOOR, W:] = (70, 68, 76)

def run_ctx(items, T0, tail, floorlight, actor, ctx, pre_items=()):
    end = max(getattr(i, 'start', 0) + min(i.len, 40) for i in items) + tail
    frames = []
    for t in range(-T0, end):
        c = background()
        if hasattr(ctx, 'bg'): ctx.bg(c, t)
        if t >= 0 and floorlight: floorlight(c, t)
        if actor: actor(c, t)
        for p in pre_items: p.draw(c, t)
        if t >= 0:
            tmp = np.zeros_like(c)
            for i in sorted(items, key=lambda i: getattr(i, 'z', 0)):
                if hasattr(i, 'draw'):
                    if isinstance(i, (seqg.PixRing, seqg.Rays, seqg.Embers)) and hasattr(ctx, 'fold_pixels'): i.draw(tmp, t)
                    else: i.draw(c, t)
                    continue
                r = i.render(t)
                if r:
                    for rr in (ctx.layer(i, r, t) if hasattr(ctx, 'layer') else [r]): blit(c, *rr, i.add)
            if hasattr(ctx, 'fold_pixels'): ctx.fold_pixels(tmp)
            c += tmp
        ctx.fg(c, t)
        frames.append(Image.fromarray(np.clip(c, 0, 255).astype(np.uint8)))
    return frames, T0

def wall_grenade():
    WX = int(BX + 40 * U); WALL['x'] = WX; WALL['pocks'] = []
    ctx = WallG(WX, int(Z(18)))
    seqg.Shrapnel = WallShrapnel; seqg.Debris = WallDebris
    cap = {}
    def grab(items, pre, T0, tail, floorlight=None, actor=None, guide=False):
        cap.update(items=items, T0=T0, tail=tail, fl=floorlight, actor=actor); return None, T0
    seqg.run = grab; seqg.floor_shot()
    return run_ctx(cap['items'], cap['T0'], cap['tail'] + 6, cap['fl'], cap['actor'], ctx)

# ================================================================== WATER
WSG = int(FLOOR - 150 * U)          # water surface line
WATERG = [(8, 20, 33), (6, 18, 29), (5, 15, 26), (4, 13, 22), (4, 12, 20)]
class WaterG:
    def __init__(s): s.flash = (0, 3)
    def bg(s, c, t): s.c0 = c.copy()
    def fg(s, c, t):
        c[:WSG] = s.c0[:WSG] if hasattr(s, 'keep') is False else c[:WSG]
        n = len(WATERG); h = (CH - WSG) // n
        boost = 1 if s.flash[0] <= t < s.flash[1] else 0
        for i in range(n):
            y0 = WSG + i * h; y1 = WSG + (i + 1) * h if i < n - 1 else CH
            col = np.array(WATERG[max(0, i - boost)]) + (np.array((14, 22, 26)) if boost else 0)
            c[y0:y1] = c[y0:y1] * np.array((.78, .9, 1.0)) + col
        c[WSG] = (106, 148, 172); c[WSG + 1] = np.maximum(c[WSG + 1], (36, 60, 76))
        for it in s.top: it.draw(c, t)                          # above-water things: splashes, the falling grenade
        if s.top_actor: s.top_actor(c, t)

class WaterShrapnel:
    """frag fragments underwater: thrown hard but stopped within a short way by the water (drag .5 a tic), drawn as
    short pale 1px streaks, no heat; every fragment leaves a trail of 1px bubbles that rise and pop at the surface."""
    def __init__(s, cx, cy, n=34, seed=5, vmax=44):
        r = random.Random(seed); s.f = []; s.bub = []
        for i in range(n // 2):
            ang = math.radians(r.uniform(-4, 88)); v = r.uniform(.5, 1) * vmax * U; t0 = r.choice([0, 0, 1])
            for sg in (-1, 1):
                x, y = cx, cy; vx, vy = sg * math.cos(ang) * v, -math.sin(ang) * v; P = [(x, y)]
                for t in range(10):
                    x += vx; y += vy; vx *= .5; vy = vy * .5 + .4
                    y = min(y, FLOOR - 1); P.append((x, y))
                s.f.append((t0, P))
                for k in range(1, 5):
                    bx, by = P[k]; s.bub.append((t0 + k, bx + r.randint(-1, 1), by, r.uniform(.8, 1.6), r.uniform(0, 6)))
        s.len = 90; s.start = 0
    def draw(s, c, t):
        for t0, P in s.f:
            dt = t - t0
            if dt < 0 or dt + 1 >= len(P): continue
            (x0, y0), (x1, y1) = P[dt], P[dt + 1]
            if math.hypot(x1 - x0, y1 - y0) < 2: continue
            line(c, x1, y1, x0, y0, [(235, 245, 250), (150, 185, 205), (80, 110, 130)], 1, False)
        for t0, x, y, v, ph in s.bub:
            dt = t - t0
            if dt < 0: continue
            yy = y - v * dt - .05 * dt * dt
            if yy <= WSG + 1: continue
            xx = x + round(math.sin(ph + dt * .8))
            px(c, xx, yy, (160, 215, 245), 1, False)

def water_grenade():
    rng = random.Random(7); T0 = 80; cx, cy = BX, Z(18)
    on = seqg.fuse_schedule()
    # the throw: in from the upper left, through the surface (entry splash), slowed hard, sinks wobbling to rest on BX
    P = []; x, y, vx, vy = BX - 250.0, WSG - 110.0, 7.0, -2.0; entered = None
    for t in range(T0):
        if y < WSG: x += vx; y += vy; vy += .7
        else:
            if entered is None: entered = (t, x)
            vx *= .82; vy = vy * .7 + .5; x += vx; y += min(vy, 3.2) + 0 * t
        y = min(y, FLOOR - 4); P.append((x, y, y >= FLOOR - 4))
    sx = BX - P[-1][0]; P = [(a + sx, b, r) for a, b, r in P]
    et, ex = entered; ex += sx
    def actor(c, t):
        if t >= 0: return
        x, y, rest = P[t + T0]
        if y < WSG: return                                     # above water: drawn after the water overlay (top_actor)
        im = seqg.REST if rest else seqg.TUMBLE[((t + T0) // 3) % 6]
        seqg.nade_draw(c, im, x, y, 'white' if t == -1 else seqg.blink_mode(t, on))
        if not rest and (t + T0) % 7 == 0: trail.append((t, x, y - 4, len(trail) % 3 == 0))
    trail = []
    class Trail:                                               # bubbles off the sinking grenade
        def draw(s, c, t):
            for t0, x, y, big in trail:
                dt = t - t0
                if dt < 0: continue
                yy = y - 2.0 * dt - .06 * dt * dt
                if yy > WSG + 2: ctx_a.put_bubble(c, x + round(math.sin(dt * .9 + x)), yy, 2 if big else 1, 255)
    def top_actor(c, t):
        if t >= 0: return
        x, y, rest = P[t + T0]
        if y < WSG: seqg.nade_draw(c, seqg.TUMBLE[((t + T0) // 2) % 6], x, y, 'n')
    entry = ctx_a.Splash(et - T0, ex, WSG, R=34, seed=4, cs=1.0 * 255, hump=(14, 6), drops=12, unit=1.0)
    # ---- the blast, underwater
    items = []
    star = pick('ruf_star', [4])[0]
    items.append(L([star, star], [1, 2], start=0, pos=(cx, cy), size=84, sil=(0, 3), clip=True, keepwhite=True))     # white flash only
    items.append(seqg.PixRing(cx, FLOOR + 2, 150, 1, 9, squash=.12, floor_cut=False, r0=20,
                              cols=[(200, 235, 250), (120, 170, 200), (60, 95, 120)], dash=4))                       # silt thump ring on the floor
    items.append(seqg.PixRing(cx, cy, 230, 1, 7, r0=24, cols=[(150, 200, 225), (90, 130, 160), (50, 80, 100)], dash=5)) # muffled pressure ring
    B = ctx_a.BUBF
    for k, (dx, dz, sz) in enumerate([(-8, 8, 46), (8, 14, 46), (0, 26, 40)]):
        items.append(L([B[0], B[0], B[2], B[3], B[3]], [2, 2, 1, 2, 2], start=3 + k, pos=(cx + dx * U, FLOOR - dz * U), size=sz,
                       add=False, vel=(0, -2.2), clip=True, nokind=True, grow=.25))                               # children -> gas pops
    items.append(L([B[0]] * 8 + [B[2], B[3]], [2] * 8 + [1, 2], start=2, pos=(cx, cy - 6), size=120, grow=.8, add=False,
                   vel=(0, -11.5 / U), clip=False, nokind=True))                                               # the gas dome, lifting
    items.append(WaterShrapnel(cx, cy - 2 * U, seed=rng.randint(0, 999)))
    for t0, dx, dz, sz in [(8, -10, 8, 46), (10, 10, 12, 44), (13, 0, 20, 50)]:                                 # murk instead of soot
        items.append(L(pick('rc_grey', range(5, 12)), [4] * 6 + [16], start=t0, pos=(cx + dx * U, FLOOR - dz * U), size=sz, grow=.5,
                       ramp=fxg.ramp((0, (6, 16, 24)), (.5, (28, 52, 66)), (1, (60, 92, 110))), add=False, alpha=.6, fade=.7,
                       vel=(0, -.15), clip=True, nokind=True, z=-2))
    bub = [ctx_a.Bubbles(2, cx, cy, WSG, n=70, R=80, seed=9, cs=255, floor=FLOOR - 2),
           ctx_a.Bubbles(9, cx, cy - 60, WSG, n=30, R=40, seed=10, cs=255, dome_t=3)]
    for b in bub: b.z = 5
    items += bub
    splash = ctx_a.Splash(14, cx, WSG, R=170, seed=6, cs=255, hump=(70, 22), drops=34, unit=1.2)
    fl = fxg.banded_glow(env(.8, 1, 5), (120, 200, 240), w=round(300 * U), h=30)
    ctx = WaterG(); ctx.top = [entry, splash]; ctx.top_actor = top_actor
    # clip: things drawn under water must not show above the surface -> fg restores the air from the background copy
    return run_ctx(items, T0, 26, fl, actor, ctx, pre_items=[Trail()])

if __name__ == '__main__':
    O = '/tmp/fx_ctx1/out'
    for name, fn in [('C_wall_grenade', wall_grenade), ('C_water_grenade', water_grenade)]:
        if sys.argv[1:] and name not in sys.argv[1:]: continue
        fr, T0 = fn()
        fxg.save_gif(fr, f'{O}/{name}_full.gif', 1); fxg.save_gif(fr, f'{O}/{name}_half.gif', 2)
        for i, f in enumerate(fr): f.save(f'/tmp/fx_ctx1/look/{name}_{i - T0:+04d}.png')
        print(name, len(fr), 'pre', T0)
