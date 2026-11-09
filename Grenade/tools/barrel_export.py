#!/usr/bin/env python3
"""barrel_export.py -- RSQ Grenade's barrel explosions: the approved Python sequences -> sprites + ZScript tables.
(Tool only; Grenade/tools/ never ships.)

    python3 Grenade/tools/barrel_export.py            export everything (sprites/rsqgn/barrel/, zscript/rsqgn/barrel_data.zs)
    python3 Grenade/tools/barrel_export.py collect A  (internal: run in a child process, one per design set)

THE SPECIFICATION IS THE PYTHON (owner, 2026-11-09: the six sequences were designed and approved as composited GIFs).
Nothing here re-draws them: this script IMPORTS the sequence code and reads every layer the sequences build --
its frames, tics, start, position, velocity, scale keys, roll, blend, ramp, fades -- then writes:
  - every layer frame as a PNG sprite at the ART'S NATIVE PIXEL SIZE (after the sequence's own recolouring / gradient
    ramp / silhouette / flip / re-centring), trimmed to its pixels, with a grAb offset at the art's centre (the point
    the sequence centres on the barrel line); floor rings centred for +FLATSPRITE use;
  - a per-tic track for each layer (sprite frame, x/y scale in map units per sprite pixel, alpha, x and z offset in
    map units from the barrel's foot), so the actor's Scale reproduces the design's size in map units (the designs
    use a known px-per-map-unit: set A 1.25 px a unit, fx.py PX; set B 1.6, fx.py U);
  - the embers', debris' and floor light's parameters, read from the same calls.
Sprites are deduped globally (a frame used by several layers is one lump) and packed 26 frames to a sprite name.

THE SIX (the owner's numbers):
  #5 Snap, #6 Heavy, #7 Pillar      set A: /tmp/fx_agentA/seqB_v3.py (+ seqB.py, fx.py, fx_v3.py, debris_v3.py, assets.py)
  #8 Groundbreaker, #10 Neon Cresc. set B: /tmp/fx_agentB/seqs_v3.py (+ fx_v3.py, fx_v2.py, fx.py, debris_v3.py)
  #9 Slag Column                    set B: /tmp/fx_agentB/seqs_v2.py (B2, unchanged in v3)
A copy of the spec scripts and their cut source frames is kept in Grenade/tools/barrel_spec/ (restore_spec() puts
them back under /tmp when /tmp was wiped, then the scripts run as they were written).

WHAT A GAME CANNOT DO THE WAY THE GIF DOES (each is the nearest faithful equivalent; listed in README/CREDITS too):
  - A colour that cools DURING a held frame (set B `cool`) is baked once per frame, at the middle tic of that frame.
  - The floor rings' squash is the GIF's perspective of a circle on the floor: in game they are +FLATSPRITE circles
    lying on the floor, at the width the GIF draws them.
  - The debris' and embers' paths are re-simulated by the engine (gravity, walls, real floor) with the design's
    numbers, in 3D: a mirrored pair flies out on opposite sides of a random direction instead of left/right.
  - The GIF's 1-px debris trails and its "drawn behind the fireball" ordering are not reproduced (the engine sorts).
"""
import os, sys, math, json, pickle, hashlib, shutil, struct, subprocess, inspect, random
import numpy as np
from PIL import Image, PngImagePlugin

HERE = os.path.dirname(os.path.abspath(__file__))
GREN = os.path.dirname(HERE)
SPEC_A = '/tmp/fx_agentA'
SPEC_B = '/tmp/fx_agentB'
SPR_OUT = os.path.join(GREN, 'sprites', 'rsqgn', 'barrel')
ZS_OUT = os.path.join(GREN, 'zscript', 'rsqgn', 'barrel_data.zs')
SPEC_COPY = os.path.join(HERE, 'barrel_spec')

# the sequences, in the owner's numbering; (number, menu name, set, function)
SEQS = [(5, 'Snap', 'A', '5_snap'), (6, 'Heavy', 'A', '6_heavy'), (7, 'Pillar', 'A', '7_pillar'),
        (8, 'Groundbreaker', 'B', 'B1_shockwave'), (9, 'Slag Column', 'B', 'B2_slagcolumn'),
        (10, 'Neon Crescent', 'B', 'B3_neoncrescent')]

ROLL_FIXED, ROLL_RANDOM, ROLL_POP, ROLL_RIGHT = 0, 1, 2, 3


def bound(fn, args, kw):
    """every parameter of a call, the defaults filled in (the spec's own defaults are part of the spec)"""
    b = inspect.signature(fn).bind(*args, **kw)
    b.apply_defaults()
    d = dict(b.arguments)
    d.pop('s', None); d.pop('self', None)
    if 'kw' in d: d.update(d.pop('kw'))
    return d


def lum(a):
    return (a[..., 0] * .3 + a[..., 1] * .59 + a[..., 2] * .11) / 255.


def art_x(al, mode):
    """the x the sequence centres on the barrel line (fx_v3.xcentre): mass, outline, or both"""
    cols = (al > 0).sum(0).astype(float)
    if cols.sum() == 0: return al.shape[1] / 2
    xs = np.arange(al.shape[1]) + 0.5
    cen = (cols * xs).sum() / cols.sum()
    if mode == 'cent': return cen
    nz = np.nonzero(cols >= 2)[0]
    if len(nz) == 0: nz = np.nonzero(cols)[0]
    bb = (nz.min() + nz.max() + 1) / 2
    return bb if mode == 'bbox' else (bb + cen) / 2


# =====================================================================================================================
# COLLECT: run inside a child process per set (both sets have modules named fx, fx_v3, debris_v3 ...)
# =====================================================================================================================
def frame_rec(rgba, ox, oy):
    """a native frame: RGBA uint8 array + the offset (px from its left/top) the sequence centres on"""
    return {'rgba': np.ascontiguousarray(rgba.astype(np.uint8)), 'ox': float(ox), 'oy': float(oy)}


def collect_A():
    sys.path.insert(0, SPEC_A)
    os.chdir(SPEC_A)
    import fx, seqB, seqB_v3, assets
    PX, BX, FY, T0 = fx.PX, fx.BX, fx.FY, seqB.T0
    rec = {'emb': [], 'deb': []}

    class PS(fx.PixSparks):
        def __init__(s, *a, **k):
            super().__init__(*a, **k)
            rec['emb'].append(bound(fx.PixSparks.__init__, (s,) + a, k))
    seqB.PixSparks = PS
    _D = seqB_v3.Debris

    class DB(_D):
        def __init__(s, *a, **k):
            super().__init__(*a, **k)
            import debris_v3
            kk = dict(k); kk['cscale'] = 1 / 255
            d = bound(debris_v3.Debris.__init__, (s, a[0], seqB_v3.BC, FY, PX), kk)
            d['real'] = s
            rec['deb'].append(d)
    seqB_v3.Debris = DB

    out = {}
    for num, menu, st, key in SEQS:
        if st != 'A': continue
        rec['emb'].clear(); rec['deb'].clear()
        fn = dict(seqB_v3.SEQS)[key]
        Ls, Ss, lt, Bk = fn()
        layers = []
        for l in Ls:
            if l.name == 'barrel': continue
            nm = l.name
            if nm.startswith('main') or nm.startswith('child') or nm.startswith('column'): rm = ROLL_RANDOM
            elif nm.startswith('pop'): rm = ROLL_POP
            elif nm.startswith('body'): rm = ROLL_RIGHT
            else: rm = ROLL_FIXED
            frames = []
            for im, d in l.fr:
                a = np.asarray(im.convert('RGBA'))
                if l.flip: a = a[:, ::-1]
                frames.append(frame_rec(a, a.shape[1] / 2, a.shape[0] / 2))
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
                if l.floor:   # a flat circle on the floor: the GIF's squash is its perspective, not its shape
                    track.append((fi, sc * sx / PX, sc * sx / PX, a, (x - BX) / PX, 0.0))
                else:
                    track.append((fi, sc * sx / PX, sc * sq / PX, a, (x - BX) / PX, (FY - y) / PX))
            layers.append({'name': nm, 'start': l.start - T0, 'flat': bool(l.floor), 'add': bool(l.add),
                           'gainbake': 1.0, 'roll': float(l.rot), 'rollmode': rm, 'frames': frames, 'track': track})
        # embers: fx.PixSparks (EoS BarrelFire with RS Combat FX pixel embers)
        embers = []
        for e in rec['emb']:
            fr = e['frames'] or assets.cfx('sparks', 'RSS0', list('ABCD'))
            embers.append({'kind': 'A', 'start': e['start'] - T0, 'per': e['per'], 'tics': e['tics'],
                           'spread': e['spread'], 'vz': [v * 0.55 for v in e['vz']], 'grav': e['grav'] * 0.55,
                           'life': e['life'], 'vx': e['vx'], 'z': (16, 32), 'scale': e['scale'] / PX,
                           'frames': [np.asarray(f.convert('RGBA')) for f in fr], 'ramp': None, 'gain': 1.0})
        debris = []
        for d in rec['deb']:
            debris.append(deb_params(d, d['start'] - T0, PX))
        # floor light: fx.render's three flat bands, x radius 110*BAND_R px, its strength the sequence's light(t)
        ltrack = [lt(T0 + t) for t in range(80)]
        out[num] = {'layers': layers, 'embers': embers, 'debris': debris,
                    'light': {'col': (255, 140, 51), 'rad': 110 * fx.BAND_R / PX, 'track': ltrack, 'stepped': False},
                    'clatter': first_land(rec['deb'], T0)}
    return out


def first_land(decs, T0):
    """the tic (after the blast) the first piece of debris lands: the clatter's cue"""
    best = None
    for d in decs:
        for p in d['real'].pieces:
            for i, step in enumerate(p['path']):
                if i > 0 and step[1] <= 0:
                    t = p['t0'] - T0 + i
                    best = t if best is None else min(best, t)
                    break
    return best if best is not None else 10


def deb_params(d, start, unit):
    """debris_v3.Debris's call, kept whole (the runtime re-simulates it)"""
    keep = ['n', 'z0', 'x0', 'speed', 'spread', 'grav', 'bounce', 'friction', 'palettes', 'cool', 'shapes', 'shape_w',
            'px', 'hold', 'spawn', 'twinkle', 'until', 'mirror_shape', 'shade']
    r = {k: d.get(k) for k in keep}
    r['start'] = start
    r['cell'] = r['px'] / unit          # map units per shape cell
    return r


def collect_B():
    sys.path.insert(0, SPEC_B)
    os.chdir(SPEC_B)
    import fx, fx_v2, fx_v3, seqs_v2, seqs_v3, debris_v3
    U, BX, FLOOR = fx.U, fx.BX, fx.FLOOR
    rec = {'emb': [], 'deb': [], 'part': [], 'glow': None, 'items': None}

    def glow(env, col, w, h, **k):
        rec['glow'] = (env, col, w, h); return None
    seqs_v2.banded_glow = glow; seqs_v3.banded_glow = glow

    def cap(items, *a, **k):
        rec['items'] = items; return [], 0
    seqs_v2.render = cap; seqs_v3.render3 = cap

    def tag(fn, kind):
        def w(*a, **k):
            r = fn(*a, **k)
            for x in (r if isinstance(r, list) else [r]): x.kind = kind
            return r
        return w
    seqs_v2.child = tag(seqs_v2.child, 'child'); seqs_v2.main_blast = tag(seqs_v2.main_blast, 'main')
    seqs_v2.pops = tag(seqs_v2.pops, 'pop')
    seqs_v3.lc_child = tag(seqs_v3.lc_child, 'lcchild'); seqs_v3.lc_main = tag(seqs_v3.lc_main, 'lcmain')
    seqs_v3.lc_pops = tag(seqs_v3.lc_pops, 'pop')

    class EmbRec:
        def __init__(s, *a, **k):
            s.d = dict(a=a, k=k, v3=s.v3); s.start = a[0]; s.len = 0
            rec['emb'].append(s.d)
        def draw(s, c, t): pass
    class EmbV2(EmbRec): v3 = False
    class EmbV3(EmbRec): v3 = True
    seqs_v2.Embers = EmbV2; seqs_v3.EmbersC = EmbV3

    class PartRec:
        def __init__(s, *a, **k):
            rec['part'].append(bound(fx_v2.Particles.__init__, (s,) + a, k)); s.start = a[1]; s.len = 0
        def draw(s, c, t): pass
    seqs_v2.Particles = PartRec

    def debf(start, **kw):
        real = debris_v3.Debris(start, fx_v3.BC, FLOOR, U, **kw)
        d = bound(debris_v3.Debris.__init__, (real, start, fx_v3.BC, FLOOR, U), kw)
        d['real'] = real
        rec['deb'].append(d)
        return real
    seqs_v3.Debris = debf

    emb_fr = [np.asarray(f) for f in fx_v2.strip('sparks/RSS0[A-D]0.png', 'bbox')]
    out = {}
    for num, menu, st, key in SEQS:
        if st != 'B': continue
        for k in ('emb', 'deb', 'part'): rec[k].clear()
        seqs_v3.SEQ[key]()
        items = rec['items']
        layers = []
        for it in items:
            if not isinstance(it, fx_v2.L): continue
            layers.append(b_layer(it, U, BX, FLOOR, fx_v3))
        embers = []
        for e in rec['emb']:
            a, k = e['a'], e['k']
            fn = fx_v3.EmbersC.__init__ if e['v3'] else fx_v2.Embers.__init__
            p = bound(fn, (None,) + tuple(a), k)
            embers.append({'kind': 'B3' if e['v3'] else 'B2', 'start': p['start'], 'tics': p['n_tics'],
                           'grav': p['grav'], 'scale': p['scale'], 'ramp': p['ramp_'], 'gain': p['gain'],
                           'frames': emb_fr, 'z': (16, 32), 'vz': (6, 12), 'r': (4, 26),
                           'xmin': 0.15 if e['v3'] else 0.6})
        debris = [deb_params(d, d['start'], U) for d in rec['deb']]
        for p in rec['part']:   # #9's dust: fx_v2.Particles (hard 2-4 px squares that bounce), as a debris group
            c0, c1 = np.array(p['col'][0], float), np.array(p['col'][1], float)
            pal = [tuple(int(round(v)) for v in c0 + (c1 - c0) * i / 3) for i in range(4)]
            life = p['life']
            debris.append({'n': p['n'], 'z0': (p['z'] - 3, p['z'] + 3), 'x0': (0, 3), 'speed': p['speed'],
                           'spread': (0, p['spread'] / 2), 'grav': p['g'], 'bounce': (p['bounce'], p['bounce']),
                           'friction': 0.6, 'palettes': [(1, pal)], 'cool': (life[0] // 4, life[1] // 4),
                           'shapes': ('dot', 'dot', 'sq'), 'shape_w': None, 'px': p['sz'], 'hold': (12, 20),
                           'spawn': 0.34, 'twinkle': 0, 'until': life[1], 'mirror_shape': False, 'shade': 0.62,
                           'start': p['start'], 'cell': p['sz'] / U, 'drag': p['drag']})
        env, col, w, h = rec['glow']
        out[num] = {'layers': layers, 'embers': embers, 'debris': debris,
                    'light': {'col': tuple(col), 'rad': (w / 2) / U, 'track': [env(t) for t in range(80)], 'stepped': True},
                    'clatter': first_land(rec['deb'], 0) if rec['deb'] else 12}
    return out


def b_layer(l, U, BX, FLOOR, fx_v3):
    """a set-B layer (fx_v2.L / fx_v3.LC): native frames recoloured as L.render does, and its per-tic track"""
    kind = getattr(l, 'kind', '')
    flat = l.sq < 0.5                       # the floor rings (squash .22-.45 = a circle seen on the floor)
    xc = getattr(l, 'xc', None)             # LC: re-centred on the barrel line ('bbox' rings, 'cent' puffs, 'mix')
    if kind in ('main', 'child'): rm = ROLL_RANDOM        # v2 (#9): EoS random roll
    elif kind == 'pop': rm = ROLL_POP
    elif kind in ('lcmain', 'lcchild'): rm = ROLL_FIXED   # v3: the balanced roll LC.pick_roll chose (the EoS roll is random anyway)
    else: rm = ROLL_FIXED                                 # everything else at the roll the script drew it with
    m0 = l.alpha * l.bright
    bake = m0 if (l.add and m0 > 1) else 1.0              # an additive alpha over 1 (bright 1.3) goes into the colour
    frames = []
    tstart = [0]
    for d in l.tl: tstart.append(tstart[-1] + d)
    for i, im in enumerate(l.fr):
        tt = (tstart[i] + tstart[i + 1] - 1) // 2          # the frame's middle tic: when a cooling colour is baked
        a = np.asarray(im.convert('RGBA')).astype(float)
        if l.flip: a = a[:, ::-1]
        k = tt / max(1, l.len - 1)
        if l.sil and l.sil[0] <= tt < l.sil[1]:
            rgb = np.broadcast_to(l.silcol, a[..., :3].shape).copy()
        elif l.ramp is not None:
            p = np.clip(lum(a) * l.gain * (1 - l.cool * k), 0, 1); rgb = l.ramp[(p * 255).astype(int)]
        else:
            rgb = a[..., :3].copy()
        rgb = np.clip(rgb * bake, 0, 255)
        al = np.where(a[..., 3] > 127, 255, 0)            # hard 1-bit alpha: no soft edges (L.render)
        if xc == 'sym':                                    # floor rings: left half mirrored onto the right
            nz = np.nonzero(al.sum(0))[0]
            if len(nz):
                a0, a1 = nz.min(), nz.max() + 1; w = a1 - a0
                al = al.copy(); rgb = rgb.copy()
                al[:, a1 - w // 2:a1] = al[:, a0:a0 + w // 2][:, ::-1]
                rgb[:, a1 - w // 2:a1] = rgb[:, a0:a0 + w // 2][:, ::-1]
        h, w = al.shape
        ox = art_x(al, 'bbox' if xc == 'sym' else xc) if xc else w / 2
        oy = h if l.anchor == 'b' else h / 2
        frames.append(frame_rec(np.dstack([rgb, al]), ox, oy))
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
        if flat:
            track.append((i, sx / U, sx / U, m, (x - BX) / U, 0.0))
        else:
            if l.sq != 1 or l.xs != 1: sx *= l.xs; sy *= l.sq
            z = (FLOOR - y) / U
            track.append((i, sx / U, sy / U, m, (x - BX) / U, z))
    return {'name': kind or 'layer', 'start': l.start, 'flat': flat, 'add': bool(l.add), 'gainbake': bake,
            'roll': float(l.rot % 360), 'rollmode': rm, 'frames': frames, 'track': track}


# =====================================================================================================================
# EXPORT
# =====================================================================================================================
def restore_spec():
    """put the archived spec back under /tmp when it is missing (the scripts carry absolute /tmp paths)"""
    for name, dst in (('fx_agentA', SPEC_A), ('fx_agentB', SPEC_B), ('eosfr', '/tmp/eosfr')):
        src = os.path.join(SPEC_COPY, name)
        if not os.path.exists(dst) and os.path.exists(src):
            shutil.copytree(src, dst)


def archive_spec():
    """keep a copy of the spec scripts and their cut frames with the tool (small; tools/ never ships)"""
    import glob
    for name, src, pats in (('fx_agentA', SPEC_A, ['*.py']), ('fx_agentB', SPEC_B, ['*.py', 'cut']),
                            ('eosfr', '/tmp/eosfr', ['*'])):
        dst = os.path.join(SPEC_COPY, name)
        os.makedirs(dst, exist_ok=True)
        for pat in pats:
            for p in glob.glob(os.path.join(src, pat)):
                q = os.path.join(dst, os.path.basename(p))
                if os.path.isdir(p):
                    if os.path.exists(q): shutil.rmtree(q)
                    shutil.copytree(p, q)
                else:
                    shutil.copy2(p, q)


def save_png(path, rgba, gx, gy):
    info = PngImagePlugin.PngInfo()
    info.add(b'grAb', struct.pack('>ii', int(gx), int(gy)))
    Image.fromarray(rgba, 'RGBA').save(path, pnginfo=info, optimize=True)


def trim(fr):
    """crop to the frame's pixels; the offset moves with the crop. None if nothing is drawn."""
    a = fr['rgba']; al = a[..., 3]
    ys, xs = np.nonzero(al > 0)
    if len(xs) == 0: return None
    x0, y0, x1, y1 = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
    c = a[y0:y1, x0:x1].copy()
    c[c[..., 3] == 0, :3] = 0
    return c, int(round(fr['ox'] - x0)), int(round(fr['oy'] - y0))


SHAPES = {'dot': [[1]], 'bar': [[1, 1]], 'vbar': [[1], [1]], 'sq': [[1, 1], [1, 1]], 'L': [[1, 0], [1, 1]],
          'shard': [[1, 1, 1], [0, 1, 0]], 'chunk': [[0, 1, 1], [1, 1, 1], [1, 1, 0]], 'slab': [[1, 1, 1], [1, 1, 1]],
          'tri': [[1, 0, 0], [1, 1, 0], [1, 1, 1]]}
SHAPE_ORDER = ['dot', 'bar', 'vbar', 'sq', 'L', 'shard', 'chunk', 'slab', 'tri']
B36 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


def main():
    restore_spec()
    data = {}
    for st in 'AB':
        tmp = f'/tmp/rsqgn_barrel_collect_{st}.pkl'
        subprocess.run([sys.executable, os.path.abspath(__file__), 'collect', st, tmp], check=True)
        data.update(pickle.load(open(tmp, 'rb')))
    archive_spec()
    if os.path.isdir(SPR_OUT): shutil.rmtree(SPR_OUT)
    os.makedirs(SPR_OUT)

    # ---- layer frames: global dedupe, packed 26 to a QB name -----------------------------------------------
    uniq = {}        # hash -> global index
    ulist = []       # (rgba, gx, gy)
    for num in sorted(data):
        for L in data[num]['layers']:
            L['fmap'] = []
            for fr in L['frames']:
                t = trim(fr)
                if t is None: L['fmap'].append(-1); continue
                c, gx, gy = t
                h = hashlib.sha1(c.tobytes() + struct.pack('>iiii', gx, gy, *c.shape[:2])).hexdigest()
                if h not in uniq:
                    uniq[h] = len(ulist); ulist.append((c, gx, gy))
                L['fmap'].append(uniq[h])
    names = []
    n = 0
    while len(names) * 26 < len(ulist):
        nm = 'QB' + B36[n // 36] + B36[n % 36]; n += 1
        if nm.startswith('QBF'): continue      # QBFG* is RS Monsters' sound lump (QBFGFIRE, QBFGHIT): keep clear
        names.append(nm)
    spr_names = []        # every sprite name the data refers to, in order (index = the data's sprite number)
    for nm in names: spr_names.append(nm)
    for gi, (c, gx, gy) in enumerate(ulist):
        nm = names[gi // 26]; fl = LETTERS[gi % 26]
        save_png(os.path.join(SPR_OUT, f'{nm}{fl}0.png'), c, gx, gy)

    # ---- embers: RSS0 A-D, raw or through the sequence's ramp (QXE*) -------------------------------------------
    emb_variants = {}
    for num in sorted(data):
        for e in data[num]['embers']:
            key = 'raw' if e['ramp'] is None else hashlib.sha1(np.asarray(e['ramp']).tobytes() + struct.pack('>d', e['gain'])).hexdigest()
            if key not in emb_variants:
                nm = 'QXE' + LETTERS[len(emb_variants)]
                emb_variants[key] = nm
                spr_names.append(nm)
                for i, f in enumerate(e['frames'][:4]):
                    a = np.asarray(f).astype(float)
                    if e['ramp'] is not None:
                        p = np.clip(lum(a) * e['gain'], 0, 1); rgb = np.asarray(e['ramp'])[(p * 255).astype(int)]
                    else:
                        rgb = a[..., :3]
                    al = np.where(a[..., 3] > 127, 255, 0)
                    t = trim(frame_rec(np.dstack([rgb, al]), a.shape[1] / 2, a.shape[0] / 2))
                    save_png(os.path.join(SPR_OUT, f'{nm}{LETTERS[i]}0.png'), *t)
            e['spr'] = spr_names.index(emb_variants[key])

    # ---- debris: one QX name per (shape, palette), a frame per palette step ---------------------------------
    pal_names = {}
    deb_spr = {}
    for num in sorted(data):
        for d in data[num]['debris']:
            d['opts'] = []
            pw = sum(w for w, _ in d['palettes'])
            shapes = list(d['shapes'])
            sw = d.get('shape_w') or [1] * len(shapes)
            for w, pal in d['palettes']:
                pk = tuple(tuple(c) for c in pal)
                if pk not in pal_names: pal_names[pk] = LETTERS[len(pal_names)]
                for s, swt in zip(shapes, sw):
                    key = (s, pk, round(d['shade'], 3))
                    if key not in deb_spr:
                        nm = 'QX' + str(SHAPE_ORDER.index(s)) + pal_names[pk]
                        assert nm not in spr_names, nm
                        deb_spr[key] = nm; spr_names.append(nm)
                        shp = np.array(SHAPES[s], bool); hh, ww = shp.shape
                        for ci, col in enumerate(pal):
                            img = np.zeros((hh, ww, 4), np.uint8)
                            for yy in range(hh):
                                for xx in range(ww):
                                    if not shp[yy, xx]: continue
                                    cc = np.array(col, float) * (d['shade'] if (hh > 1 and yy == hh - 1 and ww > 1) else 1)
                                    img[yy, xx, :3] = np.clip(np.round(cc), 0, 255); img[yy, xx, 3] = 255
                            save_png(os.path.join(SPR_OUT, f'{nm}{LETTERS[ci]}0.png'), img, ww // 2, hh)
                    d['opts'].append((spr_names.index(deb_spr[key]), len(pal), (w / pw) * (swt / sum(sw)),
                                      1 if max(pal[0]) >= 200 else 0))   # bright: the hot palettes start near white/yellow

    write_zs(data, spr_names)
    total = sum(os.path.getsize(os.path.join(SPR_OUT, f)) for f in os.listdir(SPR_OUT))
    print(f'sprites: {len(os.listdir(SPR_OUT))} files, {total / 1024:.1f} KiB, {len(spr_names)} names; '
          f'layer frames {len(ulist)} unique')


def I(v, s=1000): return int(round(v * s))


def write_zs(data, spr_names):
    S = {k: [] for k in ('L_SEQ', 'L_START', 'L_FLAT', 'L_ADD', 'L_RMODE', 'L_ROLL', 'L_TOFS', 'L_TLEN',
                         'T_SPR', 'T_FRM', 'T_SX', 'T_SY', 'T_A', 'T_X', 'T_Z',
                         'E_SEQ', 'E_KIND', 'E_START', 'E_TICS', 'E_PER', 'E_SPR', 'E_SCALE', 'E_GRAV', 'E_VZ0', 'E_VZ1',
                         'E_Z0', 'E_Z1', 'E_R0', 'E_R1', 'E_XMIN', 'E_VX', 'E_LIFE0', 'E_LIFE1',
                         'D_SEQ', 'D_START', 'D_N', 'D_Z0', 'D_Z1', 'D_X0', 'D_X1', 'D_SP0', 'D_SP1', 'D_AN0', 'D_AN1',
                         'D_GRAV', 'D_B0', 'D_B1', 'D_FRIC', 'D_COOL0', 'D_COOL1', 'D_HOLD0', 'D_HOLD1', 'D_SPAWN',
                         'D_TWINK', 'D_UNTIL', 'D_MIRROR', 'D_CELL', 'D_DRAG', 'D_OFS', 'D_NOPT',
                         'O_SPR', 'O_LEN', 'O_W', 'O_BRIGHT',
                         'Q_L0', 'Q_LN', 'Q_E0', 'Q_EN', 'Q_D0', 'Q_DN', 'Q_LCOL', 'Q_LRAD', 'Q_LOFS', 'Q_LLEN', 'Q_LEN', 'Q_CLATTER', 'G_LIGHT')}
    seqs = sorted(data)
    for si, num in enumerate(seqs):
        D = data[num]
        end = 0
        S['Q_L0'].append(len(S['L_SEQ'])); S['Q_LN'].append(len(D['layers']))
        S['Q_E0'].append(len(S['E_SEQ'])); S['Q_EN'].append(len(D['embers']))
        S['Q_D0'].append(len(S['D_SEQ'])); S['Q_DN'].append(len(D['debris']))
        for L in D['layers']:
            S['L_SEQ'].append(si); S['L_START'].append(L['start']); S['L_FLAT'].append(int(L['flat']))
            S['L_ADD'].append(int(L['add'])); S['L_RMODE'].append(L['rollmode']); S['L_ROLL'].append(I(L['roll'], 1))
            S['L_TOFS'].append(len(S['T_SPR'])); S['L_TLEN'].append(len(L['track']))
            for (fi, sx, sy, a, x, z) in L['track']:
                g = L['fmap'][fi]
                S['T_SPR'].append(-1 if g < 0 else g // 26); S['T_FRM'].append(-1 if g < 0 else g % 26)
                S['T_SX'].append(I(sx)); S['T_SY'].append(I(sy)); S['T_A'].append(I(a) if g >= 0 else 0)
                S['T_X'].append(I(x, 100)); S['T_Z'].append(I(z, 100))
            end = max(end, L['start'] + len(L['track']))
        for e in D['embers']:
            S['E_SEQ'].append(si); S['E_START'].append(e['start']); S['E_TICS'].append(e['tics'])
            S['E_SPR'].append(e['spr']); S['E_SCALE'].append(I(e['scale'])); S['E_GRAV'].append(I(e['grav']))
            S['E_VZ0'].append(I(e['vz'][0])); S['E_VZ1'].append(I(e['vz'][1]))
            S['E_Z0'].append(I(e['z'][0])); S['E_Z1'].append(I(e['z'][1]))
            if e['kind'] == 'A':
                S['E_KIND'].append(0); S['E_PER'].append(e['per']); S['E_R0'].append(0); S['E_R1'].append(I(e['spread']))
                S['E_XMIN'].append(0); S['E_VX'].append(I(e['vx'])); S['E_LIFE0'].append(e['life'][0]); S['E_LIFE1'].append(e['life'][1])
            else:
                S['E_KIND'].append(1); S['E_PER'].append(2); S['E_R0'].append(I(e['r'][0])); S['E_R1'].append(I(e['r'][1]))
                S['E_XMIN'].append(I(e['xmin'])); S['E_VX'].append(0); S['E_LIFE0'].append(8); S['E_LIFE1'].append(12)
            end = max(end, e['start'] + e['tics'] + 16)
        for d in D['debris']:
            S['D_SEQ'].append(si); S['D_START'].append(d['start']); S['D_N'].append(d['n'])
            S['D_Z0'].append(I(d['z0'][0])); S['D_Z1'].append(I(d['z0'][1]))
            S['D_X0'].append(I(d['x0'][0])); S['D_X1'].append(I(d['x0'][1]))
            S['D_SP0'].append(I(d['speed'][0])); S['D_SP1'].append(I(d['speed'][1]))
            S['D_AN0'].append(I(d['spread'][0])); S['D_AN1'].append(I(d['spread'][1]))
            S['D_GRAV'].append(I(d['grav'])); S['D_B0'].append(I(d['bounce'][0])); S['D_B1'].append(I(d['bounce'][1]))
            S['D_FRIC'].append(I(d['friction'])); S['D_COOL0'].append(d['cool'][0]); S['D_COOL1'].append(d['cool'][1])
            S['D_HOLD0'].append(d['hold'][0]); S['D_HOLD1'].append(d['hold'][1]); S['D_SPAWN'].append(I(d['spawn']))
            S['D_TWINK'].append(d['twinkle'] or 0); S['D_UNTIL'].append(d['until'] or 0)
            S['D_MIRROR'].append(int(bool(d['mirror_shape']))); S['D_CELL'].append(I(d['cell']))
            S['D_DRAG'].append(I(d.get('drag', 0.985)))
            S['D_OFS'].append(len(S['O_SPR'])); S['D_NOPT'].append(len(d['opts']))
            for sp, ln, w, br in d['opts']:
                S['O_SPR'].append(sp); S['O_LEN'].append(ln); S['O_W'].append(I(w)); S['O_BRIGHT'].append(br)
            end = max(end, d['start'] + int(d['n'] // 2 * d['spawn']) + (d['until'] or 60))
        lg = D['light']
        tr = []
        for v in lg['track']:
            v = max(0.0, min(1.0, v))
            tr.append(int(round((math.ceil(v * 4) / 4 if not lg['stepped'] else v) * 100)))   # stepped, never a smooth fade
        while tr and tr[-1] == 0: tr.pop()
        S['Q_LCOL'].append((lg['col'][0] << 16) | (lg['col'][1] << 8) | lg['col'][2])
        S['Q_LRAD'].append(int(round(lg['rad'])))
        S['Q_LOFS'].append(len(S['G_LIGHT'])); S['Q_LLEN'].append(len(tr)); S['G_LIGHT'] += tr
        S['Q_LEN'].append(max(end, len(tr)) + 1)
        S['Q_CLATTER'].append(int(D['clatter']))

    # Each table is a static function holding a FUNCTION-LOCAL static const array (`RSQGN_BarrelData.L_ADD(i)`), as
    # SlowMo platefont.zs does: on this build a CLASS-LEVEL static const array is not found from a static function and
    # does not resolve reliably in a class body (SlowMo down.zs:875, Monsters RS_MonsterCatalog.zs:33, RS_Retier.zs:29).
    # The local array is named <table>_T (barrel_check.py reads it back by that name).
    def arr(name, typ, vals):
        body = ', '.join(str(v) for v in vals) if vals else ''
        lines = []
        cur = '\t\t\t'
        for tok in body.split(', ') if body else []:
            if len(cur) + len(tok) > 116: lines.append(cur.rstrip()); cur = '\t\t\t'
            cur += tok + ', '
        if cur.strip(): lines.append(cur.rstrip().rstrip(','))
        return (f'\tstatic clearscope {typ} {name}(int i)\n\t{{\n\t\tstatic const {typ} {name}_T[] =\n\t\t{{\n'
                + '\n'.join(lines) + f'\n\t\t}};\n\t\treturn {name}_T[i];\n\t}}\n')

    doc = {
        'L_': 'LAYERS (a billboard or floor flat each): its sequence (0 = #5 ... 5 = #10), first tic after the blast, '
              'flat (1 = +FLATSPRITE on the floor), Add (1) or Translucent (0), roll mode (0 fixed, 1 random, 2 the '
              'three pops 90-130 deg apart, 3 a random right angle), fixed roll (deg), and its track (offset, tics)',
        'T_': 'TRACKS, one entry a tic: sprite (index into SPR, -1 = nothing drawn), frame (0 = A), x and y scale '
              '(map units a sprite pixel, x1000), alpha (x1000), x and z offset from the barrel\'s foot (map units x100)',
        'E_': 'EMBERS (EoS BarrelFire, RS Combat FX RSS0 pixel embers): kind (0 set A: n a tic anywhere in a disc; 1 set '
              'B: mirrored pairs), first tic, tics, a tic, sprite, scale x1000, gravity x1000, up speed, height, radius '
              '(x1000), vx (x1000), life',
        'D_': 'DEBRIS (debris_v3.Debris and #9\'s dust): first tic, pieces, launch height, offset, speed, angle from '
              'straight up, gravity, floor bounce, friction (x1000), cool tics, hold tics, a pair every spawn/1000 '
              'tics, twinkle, gone by, mirrored shapes, map units a cell (x1000), air drag (x1000), its options',
        'O_': 'DEBRIS OPTIONS: sprite (a shape in a palette, one frame a colour step), steps, weight x1000, bright',
        'Q_': 'SEQUENCES: their first layer / ember group / debris group and how many, floor light colour (0xRRGGBB), radius, its stepped track in G_LIGHT (0-100 a tic), '
              'how long the sequence runs (tics), the tic the first debris lands (the clatter)',
    }
    out = ['// RSQ Grenade -- THE BARREL EXPLOSIONS\' DATA. GENERATED by Grenade/tools/barrel_export.py from the approved',
           '// Python sequences (/tmp/fx_agentA seqB_v3.py, /tmp/fx_agentB seqs_v3.py and seqs_v2.py; archived in',
           '// Grenade/tools/barrel_spec/). DO NOT EDIT BY HAND: change the sequence, run the exporter. barrel.zs plays it.',
           '// Sequences in order: ' + ', '.join(f'{i} = #{n} {m}' for i, (n, m, _, _) in enumerate(SEQS)) + '.',
           '', 'class RSQGN_BarrelData', '{',
           f'\tconst SEQS = {len(seqs)};',
           f'\tconst NSPR = {len(spr_names)};   // SPR\'s length (a constant: no .Size() asked across classes)',
           '\t// Every table is a function: TABLE(i) is its i-th entry (function-local arrays: see barrel_export.py arr).',
           arr('SPR', 'String', [f'"{n}"' for n in spr_names])]
    last = None
    for k in S:
        pre = k.split('_')[0] + '_'
        if pre != last and pre in doc:
            import textwrap
            out += ['\t// ' + ln for ln in textwrap.wrap(doc[pre], 112)]; last = pre
        out.append(arr(k, 'int', S[k]))
    out.append('}')
    out.append('')
    out.append('// Every sprite name above, in a state, so the engine registers it (sprites are only loaded for names a')
    out.append('// state uses; RSQ VisualRewards bar.zs does the same). Never spawned.')
    out.append('class RSQGN_BarrelSprites : Actor')
    out.append('{')
    out.append('\tStates')
    out.append('\t{')
    out.append('\tSpawn:')
    for i in range(0, len(spr_names), 8):
        out.append('\t\t' + ' '.join(f'{n} A 0;' for n in spr_names[i:i + 8]))
    out.append('\t\tStop;')
    out.append('\t}')
    out.append('}')
    open(ZS_OUT, 'w').write('\n'.join(out) + '\n')


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'collect':
        res = collect_A() if sys.argv[2] == 'A' else collect_B()
        # numpy ramps / PIL images to plain arrays for the pickle
        for num, D in res.items():
            for e in D['embers']:
                e['frames'] = [np.asarray(f) for f in e['frames']]
                if e['ramp'] is not None: e['ramp'] = np.asarray(e['ramp'])
            for d in D['debris']:
                d.pop('real', None)
        pickle.dump(res, open(sys.argv[3], 'wb'))
    else:
        main()
