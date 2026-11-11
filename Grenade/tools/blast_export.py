#!/usr/bin/env python3
"""blast_export.py -- RSQ Grenade's NEW GRENADE BLAST and the EXPLOSION CONTEXTS: the approved Python mockups -> the
same data the barrels use. (Tool only; Grenade/tools/ never ships.) barrel_export.py runs it: its collectors run in
child processes (`barrel_export.py collect G|CA|CG|C2 out.pkl`, the mockups share module names), their sequences are
merged with the six barrels' and written into ONE data class (barrel_data.zs) that ONE player plays (barrel.zs
RSQGN_BarrelFX), so the grenade blast and every context get the barrels' cap, debris, embers and light for free.

THE SPECIFICATION IS THE PYTHON (as for the barrels):
  G   the grenade blast (owner: "very pleased with all four grenade tosses"): /tmp/fx_agentG seqg.py + fxg.py.
      seqg.frag(floor) -> sequence "Grenade Floor"; seqg.frag(air, air_bonus) -> "Grenade Air" and, split off, its last
      three items (the gold crosshair ring, the gold cluster ring, the gold ember rain) -> "Grenade Skeet" (an overlay
      played with Grenade Air when the grenade was shot out of the air).
  CA  /tmp/fx_ctx1/ctx_a.py (barrel contexts, approved: "i approve all barrel designs"): the layers each context ADDS --
      Low Ceiling (fire rolling along the ceiling, the smoke sheet; the soot is drawn here from its make_scorch), Open
      Sky (the column that keeps climbing, the smoke that stays), Water (the barrel's underwater swap: white flash, gas
      bubbles, the gas dome, the thump ring, silt and murk, the cold metal debris), Wall (the hot runs up and down the
      wall face) -- and the wall scorch decal's two pictures.
  CG  /tmp/fx_ctx1/ctx_g.py: the grenade underwater (white flash, the silt and pressure rings, gas pops, the dome, murk).
  C2  /tmp/fx_ctx2/liquid.py (nukage / lava / blood: the stain, the crest waves, the crown and spout drops, the blobs)
      and crowd.py (Meat Grinder's MGAB blood burst and MGAG chunks, blood bits).

WHAT IS DRAWN HERE AND WHAT IS NOT (each is the nearest faithful equivalent; README Explosions says so too):
  - The mockups' CODE-DRAWN shapes (seqg.PixRing's shock rings, seqg.Rays, liquid.Wave's crests, liquid.Stain, the ceiling
    soot) are drawn here once per tic into hard-pixel sprites at RING_PX map units a pixel (2: a mockup pixel is 0.8 units;
    a 1-px ring 200 units out would vanish in a headset), with the mockups' colours, widths in pixels and dash rules.
  - seqg.Shrapnel, ctx_g.WaterShrapnel and ctx_a.Bubbles are re-simulated in the game (explosions.zs) with the mockups'
    numbers, drawn as particles; they are not data.
  - liquid.Jet (the four fat jets) is not reproduced: its column shape has no sprite equivalent that holds at every
    angle; the late spout (liquid.Crown crown3) stands in for it.
  - Splash (the water-surface hump, ring and drops) is not reproduced: the game cannot find the surface of the water
    above a blast with stock calls (see explosions.zs Water).
"""
import os, sys, math, random, inspect, glob
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
GREN = os.path.dirname(HERE)
HUB = os.path.dirname(GREN)
RING_PX = 2.0          # map units a pixel, for everything DRAWN here (rings, rays, crests, stains, soot)
GREEN_G = '/tmp/fx_agentG'
CTX1 = '/tmp/fx_ctx1'
CTX2 = '/tmp/fx_ctx2'

# the new sequences, in the data's order after the six barrels (number, name, collector)
SEQS = [(11, 'Grenade Floor', 'G'), (12, 'Grenade Air', 'G'), (13, 'Grenade Skeet', 'G'),
        (21, 'Ceiling', 'CA'), (22, 'Sky', 'CA'), (23, 'Water Barrel', 'CA'), (25, 'Wall Run', 'CA'),
        (24, 'Water Grenade', 'CG'),
        (26, 'Nukage', 'C2'), (27, 'Lava', 'C2'), (28, 'Blood', 'C2'), (29, 'Crowd Gib', 'C2')]
# the ZScript constant each sequence's index is written under (barrel_data.zs)
CONST = {11: 'G_FLOOR', 12: 'G_AIR', 13: 'G_SKEET', 21: 'X_CEILING', 22: 'X_SKY', 23: 'X_WATER_B', 24: 'X_WATER_G',
         25: 'X_WALLRUN', 26: 'X_NUKAGE', 27: 'X_LAVA', 28: 'X_BLOOD', 29: 'X_GIB'}

# layer placement codes (barrel_data.zs L_FLAT): 0 billboard, 1 flat on the floor, 2 flat under the ceiling, 3 on the wall
BILL, FLOOR_FLAT, CEIL_FLAT, WALL = 0, 1, 2, 3
ROLL_FIXED, ROLL_RANDOM, ROLL_POP, ROLL_RIGHT = 0, 1, 2, 3


def bound(fn, args, kw):
    b = inspect.signature(fn).bind(*args, **kw)
    b.apply_defaults()
    d = dict(b.arguments)
    d.pop('s', None); d.pop('self', None)
    if 'kw' in d: d.update(d.pop('kw'))
    return d


def lum(a):
    return (a[..., 0] * .3 + a[..., 1] * .59 + a[..., 2] * .11) / 255.


def frame_rec(rgba, ox, oy):
    return {'rgba': np.ascontiguousarray(np.clip(rgba, 0, 255).astype(np.uint8)), 'ox': float(ox), 'oy': float(oy)}


def centroid(al):
    ys, xs = np.nonzero(al > 0)
    if len(xs) == 0: return al.shape[1] / 2, al.shape[0] / 2
    return xs.mean() + .5, ys.mean() + .5


def layer(name, start, flat, add, frames, track, rollmode=ROLL_FIXED, roll=0.0, notint=False):
    return {'name': name, 'start': int(start), 'flat': flat, 'add': bool(add), 'gainbake': 1.0, 'roll': float(roll % 360),
            'rollmode': rollmode, 'frames': frames, 'track': track, 'notint': bool(notint)}


# =====================================================================================================================
# a B-style layer (fxg.L, the grenade sets' copy of fx_v2.L): native frames recoloured as L.render does, its track.
# zref: the canvas y the track's z counts from (the floor for floor blasts, the blast centre for air blasts).
# =====================================================================================================================
def g_layer(l, U, BX, zref, rollmode=ROLL_FIXED, flat=None):
    m0 = l.alpha * l.bright
    bake = m0 if (l.add and m0 > 1) else 1.0
    tstart = [0]
    for d in l.tl: tstart.append(tstart[-1] + d)
    frames = []
    for i, im in enumerate(l.fr):
        tt = (tstart[i] + tstart[i + 1] - 1) // 2
        a = np.asarray(im.convert('RGBA')).astype(float)
        if l.flip: a = a[:, ::-1]
        k = tt / max(1, l.len - 1)
        if l.sil and l.sil[0] <= tt < l.sil[1]:
            rgb = np.broadcast_to(l.silcol, a[..., :3].shape).copy()
        elif l.ramp is not None:
            p = np.clip(lum(a) * l.gain * (1 - l.cool * k), 0, 1); rgb = np.asarray(l.ramp)[(p * 255).astype(int)]
        else:
            rgb = a[..., :3].copy()
        rgb = np.clip(rgb * bake, 0, 255)
        al = np.where(a[..., 3] > 127, 255, 0)
        h, w = al.shape
        if getattr(l, 'anchor', 'c') == 'b': ox, oy = w / 2, h
        else: ox, oy = centroid(al)              # fxg RECENTRE: the art's alpha-weighted centre on the layer's position
        frames.append(frame_rec(np.dstack([rgb, al]), ox, oy))
    if flat is None: flat = FLOOR_FLAT if l.sq < 0.5 else BILL
    track = []
    for tt in range(l.len):
        i = next(j for j in range(len(l.tl)) if tt < tstart[j + 1])
        k = tt / max(1, l.len - 1)
        sc = l.k0 * (1 + l.grow * (1 - (1 - k) ** l.ease if l.ease != 1 else k))
        sx = sy = sc
        if l.presq:
            px_, py_ = l.presq[min(tt, len(l.presq) - 1)]; sx *= px_; sy *= py_
        m = l.alpha * l.bright / bake
        if l.alist: m *= l.alist[min(tt, len(l.alist) - 1)]
        if l.fade is not None and k > l.fade: m *= max(0, 1 - (k - l.fade) / (1 - l.fade + 1e-9))
        if l.fadein and tt < l.fadein: m *= (tt + 1) / (l.fadein + 1)
        m = min(1.0, m)
        x = l.pos[0] + l.vel[0] * tt + 0.5 * l.acc[0] * tt * tt
        y = l.pos[1] + l.vel[1] * tt + 0.5 * l.acc[1] * tt * tt
        if flat == FLOOR_FLAT:
            track.append((i, sx / U, sx / U, m, (x - BX) / U, 0.0))
        else:
            if l.sq != 1 or l.xs != 1: sx *= l.xs; sy *= l.sq
            track.append((i, sx / U, sy / U, m, (x - BX) / U, (zref - y) / U))
    notint = bool(getattr(l, 'nokind', False))
    return layer(getattr(l, 'kind', '') or 'layer', l.start, flat, l.add, frames, track, rollmode, l.rot, notint)


# =====================================================================================================================
# an A-style layer (fx.Layer, the barrel set A copies the context scripts build on): as barrel_export.collect_A does
# =====================================================================================================================
def a_layer(l, PX, BX, FY, T0, zoff=0.0, flat=None, xref=None):
    frames = []
    for im, d in l.fr:
        a = np.asarray(im.convert('RGBA'))
        if l.flip: a = a[:, ::-1]
        frames.append(frame_rec(a, a.shape[1] / 2, a.shape[0] / 2))
    if flat is None: flat = FLOOR_FLAT if (l.floor or l.sq < 0.5) else BILL
    xr = BX if xref is None else xref
    track = []
    for t in range(l.len):
        acc = 0
        for fi, (im, d) in enumerate(l.fr):
            if t < acc + d: break
            acc += d
        k = t / max(1, l.len - 1)
        sq = l.sq; sx = l.sxg ** min(t, 5); sc = l.scale * (1 + l.grow * k)
        if l.kf: sx, sq = l.kf[min(t, len(l.kf) - 1)]
        a = l.alpha
        if l.fade is not None and k > l.fade: a *= max(0, 1 - (k - l.fade) / (1 - l.fade + 1e-9))
        if l.fadein and t < l.fadein: a *= (t + 1) / (l.fadein + 1)
        x = l.pos[0] + l.vel[0] * t + 0.5 * l.acc[0] * t * t
        y = l.pos[1] + l.vel[1] * t + 0.5 * l.acc[1] * t * t
        if flat == FLOOR_FLAT:
            track.append((fi, sc * sx / PX, sc * sx / PX, a, (x - xr) / PX, 0.0))
        else:
            track.append((fi, sc * sx / PX, sc * sq / PX, a, (x - xr) / PX, (FY - y) / PX - zoff))
    return layer(l.name, l.start - T0, flat, l.add, frames, track, ROLL_FIXED, l.rot)


# =====================================================================================================================
# DRAWN HERE: rings, rays, crests, discs (hard pixels, RING_PX map units a pixel)
# =====================================================================================================================
def canvas(radius_units, pad=3):
    n = int(math.ceil(radius_units / RING_PX)) + pad
    return np.zeros((2 * n + 1, 2 * n + 1, 4), np.uint8), n


def put(c, x, y, col, w=1):
    xi, yi = int(round(x)), int(round(y))
    if 0 <= xi and xi + w <= c.shape[1] and 0 <= yi and yi + w <= c.shape[0]:
        c[yi:yi + w, xi:xi + w, :3] = np.clip(col, 0, 255); c[yi:yi + w, xi:xi + w, 3] = 255


def pix_ring(R, r0, dur, cols, dash, start, flat, zc, name):
    """seqg.PixRing, one frame a tic: radius eases out to R (map units) over dur tics, its width (pixels) and colour stepping
    3 white-hot -> 2 yellow -> 1 orange, breaking into dashes past 55% and 80% of its life (the mockup's rules)"""
    frames, track = [], []
    for dt in range(dur):
        k = dt / max(1, dur - 1); r = r0 + (R - r0) * (1 - (1 - k) ** 2.4)
        ci = min(len(cols) - 1, int(k * len(cols))); col = cols[ci]; w = max(1, 3 - ci)
        c, n = canvas(r)
        rp = r / RING_PX
        npt = int(2 * math.pi * rp) + 8
        for i in range(npt):
            a = 2 * math.pi * i / npt
            if k > .55 and (i // dash) % 2: continue
            if k > .8 and (i // dash) % 4 == 2: continue
            put(c, n + math.cos(a) * rp - w / 2 + .5, n - math.sin(a) * rp - w / 2 + .5, col, w)
        frames.append(frame_rec(c, n + .5, n + .5))
        track.append((dt, RING_PX, RING_PX, 1.0, 0.0, zc))
    return layer(name, start, FLOOR_FLAT if flat else BILL, True, frames, track)


def hard_line(c, x0, y0, x1, y1, cols, w):
    """fxg.line: head (x0,y0) back to (x1,y1), colours stepped along it in flat bands"""
    n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
    for i in range(n):
        f = i / max(1, n - 1)
        put(c, x0 + (x1 - x0) * f, y0 + (y1 - y0) * f, cols[min(len(cols) - 1, int(f * len(cols)))], w)


def rays(start, floor, zc):
    """seqg.Rays: the 8 star points flung out as hard lines, 2 tics (on the floor only the upper five)"""
    frames, track = [], []
    for dt in range(2):
        c, n = canvas(190)
        for k in range(8):
            a = math.radians(k * 45 + 90)
            if floor and math.sin(a) < -.1: continue
            r0 = (46 if dt == 0 else 110) / RING_PX; r1 = (120 if dt == 0 else 190) / RING_PX
            cols = [(255, 255, 240), (255, 230, 120), (255, 160, 40)] if dt == 0 else [(255, 170, 40), (170, 50, 0)]
            hard_line(c, n + math.cos(a) * r1, n - math.sin(a) * r1, n + math.cos(a) * r0, n - math.sin(a) * r0, cols,
                      2 if dt == 0 else 1)
        frames.append(frame_rec(c, n + .5, n + .5))
        track.append((dt, RING_PX, RING_PX, 1.0, 0.0, zc))
    return layer('rays', start, BILL, True, frames, track)


def disc_mask(R_units, seed, wob=(.12, .07), lobes=(3, 7), bands=(.55, .85, 1.0)):
    """a ragged disc in flat bands (liquid.Stain's wobble, ctx_a.make_scorch's bands): 3 core, 2 mid, 1 rim, 0 none"""
    rr = random.Random(seed); n = int(math.ceil(R_units / RING_PX)) + 2
    yy, xx = np.mgrid[-n:n + 1, -n:n + 1].astype(float)
    ang = np.arctan2(yy, xx)
    w = 1 + wob[0] * np.sin(lobes[0] * ang + rr.random() * 6) + wob[1] * np.sin(lobes[1] * ang + rr.random() * 6)
    d = np.sqrt(xx * xx + yy * yy) * RING_PX / R_units / w
    m = np.zeros(d.shape, np.int8)
    m[d < bands[2]] = 1; m[d < bands[1]] = 2; m[d < bands[0]] = 3
    return m, n


def paint(m, cols):
    c = np.zeros(m.shape + (4,), np.uint8)
    for lv, col in cols.items():
        sel = m == lv; c[sel, :3] = col; c[sel, 3] = 255
    return c


# =====================================================================================================================
# debris groups for the barrels' runtime (RSQGN_BarrelDebris): the dict barrel_export.deb_params makes
# =====================================================================================================================
def deb(n, start, z0, x0, speed, spread, grav, bounce, friction, palettes, cool, shapes, cell, hold, spawn, until=0,
        drag=0.985, imgs=None):
    return {'n': n, 'start': start, 'z0': z0, 'x0': x0, 'speed': speed, 'spread': spread, 'grav': grav, 'bounce': bounce,
            'friction': friction, 'palettes': palettes, 'cool': cool, 'shapes': shapes, 'shape_w': None, 'px': 1,
            'hold': hold, 'spawn': spawn, 'twinkle': 0, 'until': until, 'mirror_shape': False, 'shade': 1.0,
            'cell': cell, 'drag': drag, 'imgs': imgs}


# extra shapes (barrel_export.SHAPES gets these): the grenade's debris rectangles (seqg.Debris w x h) and liquid.DROP
EXTRA_SHAPES = {
    'r33': [[1] * 3] * 3, 'r43': [[1] * 4] * 3, 'r34': [[1] * 3] * 4, 'r44': [[1] * 4] * 4, 'r53': [[1] * 5] * 3,
    'r32': [[1] * 3] * 2, 'r22': [[1] * 2] * 2,
    'd3': [[0, 1, 0], [1, 1, 1], [1, 1, 1], [0, 1, 0]], 'd4': [[0, 1, 1, 0], [1, 1, 1, 1], [1, 1, 1, 1], [0, 1, 1, 0]],
    'd5': [[0, 1, 1, 1, 0], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 1, 1, 1, 0]],
}


# =====================================================================================================================
# G: the grenade blast
# =====================================================================================================================
def collect_G():
    sys.path.insert(0, GREEN_G); os.chdir(GREEN_G)
    import fxg, seqg
    U, BX, FLOOR = fxg.U, fxg.BX, fxg.FLOOR

    def tag(fn, kind):
        def w(*a, **k):
            r = fn(*a, **k)
            for x in (r if isinstance(r, list) else [r]): x.kind = kind
            return r
        return w
    seqg.child = tag(seqg.child, 'child'); seqg.pops = tag(seqg.pops, 'pop')
    out = {}
    # the mockup's own shots: floor_shot (seed 7) and air_shot (seed 11) call frag with these
    rng = random.Random(7)
    fl_items = seqg.frag(BX, fxg.Z(18), True, rng)
    rng = random.Random(11)
    air_items = seqg.frag(BX, fxg.Z(120), False, rng, air_bonus=True)
    bonus = air_items[-3:]; air_items = air_items[:-3]          # frag appends the bonus beat last (seqg.frag air_bonus)

    def convert(items, floor, cy):
        zref = FLOOR if floor else cy
        zc = (FLOOR - cy) / U if floor else 0.0
        layers, embers, debris = [], [], []
        clatter = 10
        for it in items:
            if isinstance(it, fxg.L):
                kind = getattr(it, 'kind', '')
                rm = ROLL_RANDOM if kind == 'child' else ROLL_POP if kind == 'pop' else ROLL_FIXED
                layers.append(g_layer(it, U, BX, zref, rm))
            elif isinstance(it, seqg.PixRing):
                flat = it.sq < .5
                layers.append(pix_ring(it.R, it.r0, it.len, it.cols, it.dash, it.start, flat, 0.0 if flat else zc,
                                       'ring %d' % it.R))
            elif isinstance(it, seqg.Rays):
                layers.append(rays(it.start, it.floor, zc))
            elif isinstance(it, seqg.Embers):
                st, x, z, vz, l0 = it.items[0]
                fall = it in bonus                     # the skeet's gold rain (seqg.frag: Embers(..., fall=True))
                ntics = len({s for s, _, _, _, _ in it.items})
                if fall:
                    e = {'r': (4 * 2.6, 26 * 2.6), 'z': (16 - 24, 32 - 24), 'vz': (6 * .6, 12 * .6)}
                else:
                    e = {'r': (4, 26), 'z': (16, 32), 'vz': (6, 12)}
                e.update({'kind': 'B2', 'start': it.start, 'tics': ntics, 'grav': it.grav, 'scale': 1.25,
                          'ramp': l0.ramp, 'gain': l0.gain, 'xmin': 0.6,
                          'frames': [np.asarray(f) for f in fxg.strip('sparks/RSS0[A-D]0.png', None)]})
                embers.append(e)
            elif isinstance(it, seqg.Debris):
                # seqg.Debris: n 30 in mirrored pairs; cone 150 about straight up on the floor (spread 0..75 from
                # vertical), any direction in the air; gravity 1.1; bounce .42 while it comes down fast; friction .62;
                # x drag .97; hot 4 tics, mid 4, low 4, then its dark colour; it settles and stays
                full = not floor
                spd = (5, 14) if floor else (4, 12)
                z0 = ((FLOOR - cy) / U + 3 - 3, (FLOOR - cy) / U + 3 + 3) if floor else (-3, 3)
                pal = [(255, 200, 90), (230, 100, 25), (120, 45, 15), (100, 88, 78)]
                debris.append(deb(30, it.start, z0, (0, 3), spd, (0, 180 if full else 75), 1.1, (.42, .42), .62,
                                  [(1, pal)], (4, 4), ('r33', 'r43', 'r34', 'r44', 'r53', 'r32', 'r22'), 1 / U, (70, 105),
                                  0.07, 0, 0.97))
                # the clatter: the first piece down
                best = None
                for t0, P, w, h, dark in it.b:
                    for i in range(2, len(P)):          # the first turn from falling (y growing) to rising: a bounce
                        if P[i - 1][1] > P[i - 2][1] and P[i][1] < P[i - 1][1] or (P[i][2] and not P[i - 1][2]):
                            best = t0 + i if best is None else min(best, t0 + i); break
                if best is not None: clatter = best
            # Shrapnel: re-simulated in the game (explosions.zs RSQGN_Boom); Tracer: the mockup's own shot, not ours
        return layers, embers, debris, clatter

    for num, items, floor, cy in ((11, fl_items, True, fxg.Z(18)), (12, air_items, False, fxg.Z(120)),
                                  (13, bonus, False, fxg.Z(120))):
        L, E, D, cl = convert(items, floor, cy)
        if num == 11:     # floor_shot: banded_glow(env(1.0, 1, 10), (255,150,60), w=400U)
            env = fxg.env(1.0, 1, 10); light = {'col': (255, 150, 60), 'rad': 200.0, 'track': [env(t) for t in range(80)], 'stepped': True}
        elif num == 12:   # air_shot: banded_glow(env(.5, 1, 8), (255,150,60), w=380U)
            env = fxg.env(.5, 1, 8); light = {'col': (255, 150, 60), 'rad': 190.0, 'track': [env(t) for t in range(80)], 'stepped': True}
        else:
            light = {'col': (255, 200, 40), 'rad': 0.0, 'track': [], 'stepped': True}
        out[num] = {'layers': L, 'embers': E, 'debris': D, 'light': light, 'clatter': cl}
    return out


# =====================================================================================================================
# CA: the barrel contexts (ctx_a.py, on set A's copied library in /tmp/fx_ctx1/a)
# =====================================================================================================================
def collect_CA():
    sys.path.insert(0, CTX1 + '/a'); sys.path.insert(0, CTX1); os.chdir(CTX1)
    import ctx_a, fx, seqB, seqB_v3, debris_v3
    PX, BX, FY, T0 = fx.PX, fx.BX, fx.FY, seqB.T0
    rec = []
    _D = seqB_v3.Debris

    class DB(_D):
        def __init__(s, *a, **k):
            super().__init__(*a, **k)
            kk = dict(k); kk['cscale'] = 1 / 255
            rec.append(bound(debris_v3.Debris.__init__, (s, a[0], seqB_v3.BC, FY, PX), kk))
    seqB_v3.Debris = DB; ctx_a.SB.Debris = DB
    none_light = {'col': (255, 140, 51), 'rad': 0.0, 'track': [], 'stepped': True}
    out = {}

    # LOW CEILING: the rolls and the smoke sheet (z from the ceiling: negative), the soot drawn from make_scorch's rule
    Ls = ctx_a.ceiling_barrel()[0]
    CYL = int(FY - ctx_a.U(64))
    zc = (FY - CYL) / PX
    L = [a_layer(l, PX, BX, FY, T0, zoff=zc) for l in Ls if l.name.startswith('ceiling roll') or l.name == 'smoke sheet']
    m, n = disc_mask(90 / PX, 9)
    hot = paint(m, {3: (255, 179, 77), 2: (230, 102, 26), 1: (115, 41, 13)})            # Ceiling.fg dt < 4
    soot = paint(m, {3: (8, 7, 7), 2: (14, 13, 11), 1: (22, 19, 18)})                 # ... after
    L.append(layer('soot hot', 2, CEIL_FLAT, True, [frame_rec(hot, n + .5, n + .5)],
                   [(0, RING_PX, RING_PX, 1.0, 0.0, 0.0)] * 4, notint=False))
    tr = []
    for t in range(150):
        tr.append((0, RING_PX, RING_PX, 0.9 if t < 105 else 0.9 * (150 - t) / 45, 0.0, 0.0))
    L.append(layer('soot', 6, CEIL_FLAT, False, [frame_rec(soot, n + .5, n + .5)], tr, notint=True))
    out[21] = {'layers': L, 'embers': [], 'debris': [], 'light': none_light, 'clatter': 0}

    # OPEN SKY: the column that keeps on climbing and the dark smoke left standing along it
    Ls = ctx_a.sky_barrel()[0]
    L = [a_layer(l, PX, BX, FY, T0) for l in Ls if l.name.startswith('sky column') or l.name.startswith('stay smoke')]
    for x in L:
        if x['name'].startswith('stay smoke'): x['notint'] = True
    out[22] = {'layers': L, 'embers': [], 'debris': [], 'light': none_light, 'clatter': 0}

    # WATER (barrel): the whole underwater swap, and its cold metal debris
    rec.clear()
    out_l, S, B, cold, wctx = ctx_a.water_barrel()
    L = [a_layer(l, PX, BX, FY, T0) for l in out_l if l.name != 'barrel']
    for x in L: x['notint'] = True
    import barrel_export as BE
    D = [BE.deb_params(d, d['start'] - T0, PX) for d in rec]
    # the light: the base sequence's (#6 Heavy) light, cold, for its first 4 tics only (water_barrel's `cold`)
    out[23] = {'layers': L, 'embers': [], 'debris': D,
               'light': {'col': (140, 216, 255), 'rad': 110 * fx.BAND_R / PX, 'track': [1.0, 1.0, .75, .5], 'stepped': True},
               'clatter': 12}

    # WALL: the two hot runs up and down the wall face (on the wall: x from the wall plane)
    Ls = ctx_a.wall_barrel()[0]
    WX = int(BX + ctx_a.U(24))
    L = [a_layer(l, PX, BX, FY, T0, flat=WALL, xref=WX - 4) for l in Ls if l.name.startswith('wall run')]
    out[25] = {'layers': L, 'embers': [], 'debris': [], 'light': none_light, 'clatter': 0}
    return out


def scorch_pics():
    """the wall scorch decal's two pictures (ctx_g.WallG: make_scorch(WX, cy-6, 34, 74, 30); hot bands dt < 3, soot after),
    at the grenade mockup's 1.25 px a unit (DECALDEF scales them by 0.8)"""
    sys.path.insert(0, CTX1 + '/a'); sys.path.insert(0, CTX1)
    import ctx_a
    W, H = 80, 112
    m = ctx_a.make_scorch(40, 76, 34, 74, 30, 11, W=W, H=H)
    hot = paint(m, {3: (255, 190, 90), 2: (190, 80, 20)})
    soot = paint(m, {3: (9, 8, 8), 2: (18, 16, 15), 1: (32, 29, 28)})
    return hot, soot, (40, 76)


# =====================================================================================================================
# CG: the grenade underwater (ctx_g.water_grenade's items; its render is not run)
# =====================================================================================================================
def collect_CG():
    sys.path.insert(0, CTX1 + '/g'); sys.path.insert(0, CTX1); os.chdir(CTX1)
    import ctx_g, fxg, seqg
    U, BX, FLOOR = fxg.U, fxg.BX, fxg.FLOOR
    cap = {}

    def grab(items, T0, tail, fl, actor, ctx, pre_items=()):
        cap['items'] = items; return None, T0
    ctx_g.run_ctx = grab
    ctx_g.water_grenade()
    cy = fxg.Z(18)
    L = []
    for it in cap['items']:
        if isinstance(it, fxg.L):
            x = g_layer(it, U, BX, FLOOR, ROLL_FIXED); x['notint'] = True; L.append(x)
        elif isinstance(it, seqg.PixRing):
            flat = it.sq < .5
            x = pix_ring(it.R, it.r0, it.len, it.cols, it.dash, it.start, flat, 0.0 if flat else (FLOOR - cy) / U, 'water ring')
            x['notint'] = True; L.append(x)
        # WaterShrapnel, Bubbles: re-simulated in the game
    env = fxg.env(.8, 1, 5)       # water_grenade: banded_glow(env(.8, 1, 5), (120,200,240), w=300U)
    return {24: {'layers': L, 'embers': [], 'debris': [],
                 'light': {'col': (120, 200, 240), 'rad': 150.0, 'track': [env(t) for t in range(40)], 'stepped': True},
                 'clatter': 0}}


# =====================================================================================================================
# C2: liquid floors and the crowd gib (liquid.py, crowd.py on set A's library in /tmp/fx_ctx2/lib)
# =====================================================================================================================
def collect_C2():
    sys.path.insert(0, CTX2 + '/lib'); sys.path.insert(0, CTX2); os.chdir(CTX2)
    import liquid, debris_v3
    PX = 1.25                     # set A's px a map unit (fx.PX), the canvas liquid.py draws on
    out = {}
    for num, kind, sd in ((26, 'nukage', 3), (27, 'lava', 4), (28, 'blood', 5)):
        Lq = liquid.LIQ[kind]
        L = []
        # the STAIN (liquid.Stain, top view: its rx 72 px is the radius; grows over 3 tics, the rim steps darker and goes)
        m, n = disc_mask(72 / PX, 9)
        core, mid, rim = Lq['stain'][0], Lq['stain'][1], Lq['rim']
        imgs = []
        for g, rimk in ((1 / 3, 1.0), (2 / 3, 1.0), (1.0, 1.0), (1.0, .6), (1.0, .35), (1.0, 0.0)):
            mg, _ = disc_mask(72 / PX * g, 9)
            pad = (m.shape[0] - mg.shape[0]) // 2
            mm = np.zeros(m.shape, np.int8); mm[pad:pad + mg.shape[0], pad:pad + mg.shape[1]] = mg
            cols = {3: core, 2: mid}
            if rimk > 0: cols[1] = tuple(int(v * rimk) for v in rim)
            imgs.append(frame_rec(paint(mm, cols), n + .5, n + .5))
        rim_end = 70 if kind == 'lava' else 40
        tr = []
        for t in range(210):
            fi = 0 if t == 0 else 1 if t == 1 else 2 if t < 16 else 3 if t < 30 else 4 if t < rim_end else 5
            a = 1.0 if t < 175 else (210 - t) / 35
            tr.append((fi, RING_PX, RING_PX, a, 0.0, 0.0))
        L.append(layer('stain', 2, FLOOR_FLAT, False, imgs, tr, notint=True))
        # the CREST WAVES (liquid.Wave: a broken crest ring running out over the floor, stepping darker every 5 tics)
        for (ws, r0, r1, dur, seed) in ((2, 34, 150, 20, 1), (8, 24, 110, 18, 2)):
            ph = random.Random(seed).random() * 6
            fr, tr = [], []
            pal = Lq['drop']
            for dt in range(dur):
                k = dt / dur; r = (r0 + (r1 - r0) * (1 - (1 - k) ** 2)) / PX
                col = pal[min(len(pal) - 1, dt // 5)]; hi = pal[0] if dt < 5 else col
                c, nn = canvas(r)
                rp = r / RING_PX; npt = int(2 * math.pi * rp) + 8
                for i in range(npt):
                    a = 2 * math.pi * i / npt
                    if math.sin(a * 9 + ph + dt * 0.3) < -0.35: continue
                    put(c, nn + math.cos(a) * rp, nn - math.sin(a) * rp, hi if i % 3 == 0 else col, 1)
                fr.append(frame_rec(c, nn + .5, nn + .5)); tr.append((dt, RING_PX, RING_PX, 1.0, 0.0, 0.0))
            L.append(layer('wave', ws, FLOOR_FLAT, True, fr, tr, notint=True))
        # the CROWN drops and the SPOUTS (liquid.Crown): mirrored drops thrown up and out, no bounce, a plop and gone
        D = []
        def crown(start, n_, r0, vz, vr, sizes, g):
            shapes = tuple({2: 'sq', 3: 'd3', 4: 'd4', 5: 'd5'}[s] for s in sizes)
            sp = (math.hypot(vz[0], vr[0]) / PX, math.hypot(vz[1], vr[1]) / PX)
            an = (math.degrees(math.atan2(vr[0], vz[1])), math.degrees(math.atan2(vr[1], vz[0])))
            return deb(n_, start, (0, 2), (r0[0] / PX, r0[1] / PX), sp, an, g / PX, (0, 0), .2, [(1, Lq['drop'][1:])], (8, 8),
                       shapes, 1 / PX, (1, 2), 3 / max(1, n_ // 2), 0, 0.99)
        D.append(crown(3, 44, (26, 36), (5, 8), (1.6, 2.8), (3, 4, 4, 5), 0.5))       # the wide crown
        D.append(crown(6, 26, (8, 20), (9, 12), (0.4, 1.2), (2, 3, 4), 0.55))         # the tall spout
        D.append(crown(10, 18, (0, 10), (8, 10.5), (0.2, 0.9), (4, 5, 5), 0.5))       # the late spout (stands in for the jets)
        # the BLOBS (liquid.shot's Debris: no bounce, they plop and sink), its numbers as written there
        p = bound(debris_v3.Debris.__init__, (None, 3, 160.5, 262, PX),
                  dict(cscale=1 / 255, n=14, seed=21, z0=(10, 26), x0=(10, 22), speed=(4, 7.5), spread=(28, 70), grav=1.0,
                       bounce=(0.0, 0.05), friction=0.2, palettes=[(1, Lq['drop'][1:])], cool=(4, 6),
                       shapes=('sq', 'chunk', 'L', 'sq'), px=3, hold=(3, 6), depth=(0, 14), spawn=0.5, exact=True, until=34))
        import barrel_export as BE
        D.append(BE.deb_params(p, 3, PX))
        # the light pool: fire x .45 + the liquid's own x .55 (liquid.shot); colour only, the base sequence's track
        pool = np.array(Lq['pool']); fire = np.array((1.0, .55, .2))
        mix = tuple(int(round(v)) for v in np.clip((fire * .45 + pool * .55) * 255, 0, 255))
        out[num] = {'layers': L, 'embers': [], 'debris': D, 'light': {'col': mix, 'rad': 0.0, 'track': [], 'stepped': True},
                    'clatter': 0}

    # THE CROWD GIB (crowd.py): Meat Grinder's MGAB blood burst (1 tic a frame for 4, then 2), MGAG chunks thrown out
    # tumbling, landing and sitting, and blood-red hard-pixel bits. The monster's own colours (crowd.own_palette) need its
    # sprite's pixels, which a running game cannot read: the bits are blood only.
    MG = os.path.join(HUB, 'Monsters', 'sprites', 'meatgrinder')
    burst = [Image.open(os.path.join(MG, f'MGAB{c}0.png')).convert('RGBA') for c in 'ABCDEFGH']
    chunks = [Image.open(os.path.join(MG, f'MGAG{c}0.png')).convert('RGBA') for c in 'EFGH']
    frames = []
    for im in burst:
        a = np.asarray(im).copy(); a[..., 3] = np.where(a[..., 3] > 127, 255, 0)
        frames.append(frame_rec(a, a.shape[1] / 2, a.shape[0] / 2))
    tr = []
    for j in range(12):
        fi = j if j < 4 else 4 + (j - 4) // 2
        tr.append((fi, 1.5 / PX, 1.5 / PX, 1.0, 0.0, 0.0))
    L = [layer('gib burst', 0, BILL, False, frames, tr, notint=True)]
    BLOOD = [(236, 40, 30), (176, 14, 12), (118, 6, 6), (80, 4, 4), (56, 4, 4)]
    D = [deb(12, 0, (-10, 10), (2, 10), (3, 7), (15, 80), 1.0, (.15, .25), .4, [(1, BLOOD)], (6, 8),
             ('sq', 'chunk', 'L', 'slab'), 2 / PX, (14, 24), .3, 40),
         # crowd.Chunks: 6 a body, 15-75 deg off vertical, 4-8 px a tic, gravity .8, land and sit 14-24 tics, blink out
         deb(6, 0, (-4, 4), (0, 2), (4 / PX, 8 / PX), (15, 75), .8 / PX, (0, 0), .4, [(1, [(255, 255, 255)])], (99, 99),
             ('sq',), 1.5 / PX, (14, 24), 0.01, 0, 0.99, imgs=[np.asarray(c) for c in chunks])]
    out[29] = {'layers': L, 'embers': [], 'debris': D, 'light': {'col': (176, 14, 12), 'rad': 0.0, 'track': [], 'stepped': True},
               'clatter': 0}
    return out


# =====================================================================================================================
# THE TINTS (TRNSLATE.txt, generated block): one desaturated-gradient translation per colour, so a sprite keeps its
# brightness and takes the colour: black -> the colour (x1.5 + 0.35 a channel, so the bright end runs on to near white).
# The SAME rule colours the particles (explosions.zs RSQGN_Tint.Of) -- change it in both places.
# =====================================================================================================================
KIND_COL = [0xFF7814, 0xFFC828, 0x46BEFF, 0xAA50FF, 0x8C8C96, 0xFFFFFF, 0xFF6EBE, 0x3CDC5A]   # kinds.zs Colour() 1..8
# RSQ Monsters' ladder has no tint colours of its own; its representative colours (RS_MonsterMaster.zs RS_TierForColour,
# "they exist to be told apart") are the 13-entry table, kept in ONE place here and in explosions.zs RSQGN_Tint.TierRGB
# In RSQ Monsters' ladder order, numbered by STRENGTH since 11-11 (1 Common 2 Green 3 Blue 4 Purple 5 Cyan 6 Brown 7 Yellow
# 8 FireBlu 9 Gray 10 Red 11 Abyss 12 Black 13 White); each colour keeps its value.
TIER_COL = [0xC8C8C8, 0x3CDC46, 0x3C78FF, 0xAA46E6, 0x3CF0F0, 0x8C5A28, 0xFFC828, 0x28A0DC, 0x828282, 0xE62828,
            0x46146E, 0x191919, 0xFFFFFF]
HUES = 12      # Room Complement: the complement's hue in 12 steps, full colour


def hue_rgb(i):
    import colorsys
    r, g, b = colorsys.hsv_to_rgb(i / HUES, 0.85, 1.0)
    return (int(r * 255) << 16) | (int(g * 255) << 8) | int(b * 255)


def tint_end(rgb):
    c = [((rgb >> 16) & 255) / 255, ((rgb >> 8) & 255) / 255, (rgb & 255) / 255]
    return [round(v * 1.5 + 0.35, 2) for v in c]


def trnslate_block():
    lines = ['// ---- GENERATED by Grenade/tools/blast_export.py (trnslate_block): the explosion tints. Do not edit by hand. ----',
             '// Each: every colour kept as its brightness, black -> the colour x1.5 + 0.35 a channel (clamped: the bright end',
             '// runs on to near white). explosions.zs RSQGN_Tint names them; its Of() colours particles by the same rule.']
    for i, c in enumerate(KIND_COL, 1):
        e = tint_end(c); lines.append(f'RSQGN_K{i} = "0:255=%[0,0,0]:[{e[0]:.2f},{e[1]:.2f},{e[2]:.2f}]"   // kind {i} #{c:06X}')
    for i, c in enumerate(TIER_COL, 1):
        e = tint_end(c); lines.append(f'RSQGN_T{i:02d} = "0:255=%[0,0,0]:[{e[0]:.2f},{e[1]:.2f},{e[2]:.2f}]"   // tier {i} #{c:06X}')
    for i in range(HUES):
        c = hue_rgb(i); e = tint_end(c)
        lines.append(f'RSQGN_H{i:02d} = "0:255=%[0,0,0]:[{e[0]:.2f},{e[1]:.2f},{e[2]:.2f}]"   // hue {i * 360 // HUES} #{c:06X}')
    lines.append('// ---- end of the generated block ----')
    return '\n'.join(lines)


COLLECT = {'G': collect_G, 'CA': collect_CA, 'CG': collect_CG, 'C2': collect_C2}
