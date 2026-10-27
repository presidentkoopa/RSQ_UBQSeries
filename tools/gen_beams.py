#!/usr/bin/env python3
"""gen_beams.py -- each gun's muzzle, measured from its HELD model, and the beam that rides it.

    python3 tools/gen_beams.py --ready tools/ready_bd22q.txt \
        brutal22test6.pk3 BD_VoxelPack.pk3 BD22_VR-Reloaded_1.99x-lb-r7-saveload.pk3

pk3s in load order. --ready is the engine's own answer to "which sprite frame is each weapon's
Ready frame, and is it a melee weapon" (lines `PR <Class> <SPRITELUMP> <frame> <melee|gun>`, written by tools/readyprobe, the same
dump RSQ_TacticalRig's measure_pickups.py --held reads). Nothing here is typed in by hand: every
number comes from a mesh or a MODELDEF block in those files.

WHAT IT WRITES
  VOXELDEF.txt                     one entry per (gun placement, beam length): the beam rod
  models/rsqls/beam/pNNkMM.kvx     the rod itself (see below), pivot = that gun's muzzle
  zscript/rsqls/muzzles.zs         class -> placement, ready-pose frames, muzzle and barrel
  docs/MUZZLES.txt                 the per-gun table, for people

THE BEAM IS A HUD MODEL CALLED BY THE GUN. A psprite layer whose caller is the gun is drawn by
the renderer on that gun's controller every rendered frame (models.cpp RenderHUDModel: hand =
caller == OffhandWeapon), with the gun's own layer offset turn (hw_weapon.cpp, PSPF_ADDWEAPON).
Its model is found by (caller class, sprite, frame) -- or, for any caller at all, by a VOXEL
assigned to the sprite frame (models.cpp FindModelFrameRaw: the voxel branch looks at the sprite
only). A MODELDEF block for a gun class would be a fatal "Unknown actor type" with that gun's
mod absent, so the beam is a voxel: it loads over vanilla, Brutal Doom and BD22Q alike.

THE ENGINE'S CHAIN, models.cpp RenderHUDModel, in the controller's HUD frame (centimetres,
x / y up / z back; the hand transform, then scale 0.01 and translate (0, 5, 30)):
    p = Offset' + S * R * Ry(90) * Ry(-AngleOffset) * Rz(PitchOffset) * Rx(-RollOffset) * ws * m
    Offset' = (xoffset, zoffset, yoffset)      (models.cpp: translate(x/xs, z/zs, y/ys) after scale)
    S = diag(xscale, zscale, yscale)           m = md3 (x, z, y)  (models_md3.cpp BuildVertexBuffer)
    R = the layer's turn (gun layer offset / 4; identity at rest), ws = vr_weaponScale
    voxel: m = (x - px, -(z - pz), -(y - py))  (models_voxel.cpp AddFace), S = Scale, no pitch/roll
So the rod gets the gun's OWN Offset (same turning point when the gun layer turns) and the
muzzle goes in the KVX PIVOT, so vr_weaponScale stretches it exactly as it stretches the gun.

THE ROD: 1 x 1 x N voxels along +x, Scale BEAM_S cm. Its colours are palette INDICES that encode
the distance from the muzzle (index 1 at the muzzle .. 254 at FADE_MAX); the runtime builds a
translation that turns each index into colour x brightness for the fade length chosen in the
menu, so one rod serves every colour and every fade length. Drawn additive: black = clear.
Lengths: a rod per step in LENGTHS, so the beam can stop where the trace hits (a HUD model is
drawn over the world -- hw_models.cpp squeezes its depth range -- so it must not run on past a
wall).

Parsing (Pak, strip_comments, tokens, parse_modeldef, md3_points, obj_points) is copied from
RSQ_TacticalRig/tools/measure_pickups.py; the MODELDEF walk is redone to follow the engine
exactly (each FrameIndex pushes the block's state so far; later definitions win).
"""
import argparse, math, os, re, struct, sys, zipfile
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))

BEAM_S = 0.4          # cm per voxel: the rod's width
FADE_MAX = 600.0      # cm: the longest fade the menu offers; index 254 is here
TIP_SLAB = 1.5        # cm: the slice at the very end of the barrel whose middle is the bore
MAX_TILT = 15.0       # degrees: more than this off level is a blade held up, not a barrel
MAX_AXIS_DEV = 30.0   # degrees: a mesh whose long axis is this far off x is not a barrel along x
SPRITE_PREFIX = 'LZ'  # LZ00..LZzz, 26 frames each
# Another frame of the gun's model that the whole mesh moved RIGIDLY into (no vertex more than
# RIGID_RES from the best rigid motion of the rest pose's mesh) has its muzzle and barrel known
# exactly. If they are still on the rest pose's bore -- off it by at most PERP_TOL, along it by at
# most ALONG_TOL, turned by at most ANGLE_TOL -- the frame draws the rest pose's beam. If the gun
# kicked further but no more than KICK_CM / KICK_DEG (recoil: BD's Rifle fire frames RIFF B, C
# lift the muzzle 1.4 cm), the frame gets a beam placement of its own. Without both, a gun firing
# full-auto showed its beam one tic in four (rig, 2026-10-27). Bigger moves -- reloads,
# inspections -- hide the beam: a rod per pose per length costs VOXELDEF entries on the Quest.
RIGID_RES = 0.3       # cm
RIGID_SHARE = 0.95    # of the mesh's vertices that must follow the motion
PERP_TOL = 0.4        # cm: the rod's own width (BEAM_S)
ALONG_TOL = 3.0       # cm
ANGLE_TOL = 0.25      # degrees
KICK_CM = 6.0         # cm
KICK_DEG = 6.0        # degrees

def lengths():
    """Beam lengths in cm: 10 cm, then 6% steps to FADE_MAX (the beam stops at most 6% short of what
    it hits: the longest step that does not pass it is drawn)."""
    out, L = [], 10.0
    while L < FADE_MAX:
        out.append(round(L, 1)); L *= 1.06
    out.append(FADE_MAX)
    return out
LENGTHS = lengths()

# ---- copied from RSQ_TacticalRig/tools/measure_pickups.py ------------------------------
def lumps(z):
    out = {}
    for n in z.namelist():
        if not n.endswith('/'):
            out[n.lower()] = n
    return out

class Pak:
    def __init__(self, path):
        self.z = zipfile.ZipFile(path)
        self.names = lumps(self.z)
    def get(self, name):
        n = self.names.get(name.lower().lstrip('/'))
        return self.z.read(n) if n else None

def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)

def tokens(t):
    return re.findall(r'"[^"]*"|\{|\}|[^\s{}]+', t)

def parse_modeldef(text):
    tk = tokens(strip_comments(text))
    i = 0
    while i < len(tk):
        if tk[i].lower() == 'model' and i + 2 < len(tk) and tk[i + 2] == '{':
            cls = tk[i + 1].strip('"')
            j = i + 3
            body = []
            while j < len(tk) and tk[j] != '}':
                body.append(tk[j]); j += 1
            yield cls, body
            i = j + 1
        else:
            i += 1

_md3_cache = {}
def md3_points(data, frame):
    k = (id(data), frame)
    if k not in _md3_cache: _md3_cache[k] = _md3_points(data, frame)
    return _md3_cache[k]

def _md3_points(data, frame):
    ident, ver, name, flags, nfr, ntags, nsurf, nskins, ofr, otag, osurf, oend = \
        struct.unpack_from('<4si64s9i', data, 0)
    frame = min(max(frame, 0), nfr - 1)
    pts = []
    o = osurf
    for _ in range(nsurf):
        sid, sname, sflags, snfr, nshad, nverts, ntris, otris, oshad, ost, oxyz, oend2 = \
            struct.unpack_from('<4s64s10i', data, o)
        base = o + oxyz + frame * nverts * 8
        for v in range(nverts):
            x, y, z, _n = struct.unpack_from('<hhhh', data, base + v * 8)
            pts.append((x / 64.0, y / 64.0, z / 64.0))
        o += oend2
    return pts

def obj_points(data):
    pts = []
    for line in data.decode('latin-1').splitlines():
        if line.startswith('v '):
            x, y, z = (float(t) for t in line.split()[1:4])
            pts.append((x, -z, y))
    return pts
# ---- end of the copy ----------------------------------------------------------------------

# The engine's MODELDEF walk (models.cpp ParseModelDefLump): settings accumulate through the
# block; every FrameIndex pushes a SNAPSHOT for (class, sprite, frame); the hash finds the
# LAST one pushed.
NARGS = {'path': 1, 'model': 2, 'skin': 2, 'surfaceskin': 3, 'scale': 3, 'offset': 3,
         'zoffset': 1, 'angleoffset': 1, 'pitchoffset': 1, 'rolloffset': 1,
         'frameindex': 4, 'frame': 4, 'rotation-speed': 1, 'rotation-vector': 3,
         'rotation-center': 3, 'animation': 2, 'baseframe': 0}

def walk_block(cls, body, sink):
    st = {'path': '', 'models': {}, 'frames': {}, 'scale': (1.0, 1.0, 1.0),
          'off': [0.0, 0.0, 0.0], 'ang': 0.0, 'pit': 0.0, 'rol': 0.0}
    i = 0
    while i < len(body):
        k = body[i].lower()
        n = NARGS.get(k)
        if n is None:
            i += 1; continue
        a = [x.strip('"') for x in body[i + 1:i + 1 + n]]
        if k == 'path': st['path'] = a[0]
        elif k == 'model': st['models'][int(a[0])] = a[1]
        elif k == 'scale': st['scale'] = tuple(float(x) for x in a)
        elif k == 'offset': st['off'] = [float(x) for x in a]
        elif k == 'zoffset': st['off'][2] = float(a[0])
        elif k == 'angleoffset': st['ang'] = float(a[0])
        elif k == 'pitchoffset': st['pit'] = float(a[0])
        elif k == 'rolloffset': st['rol'] = float(a[0])
        elif k == 'frameindex':
            st['frames'][int(a[2])] = int(a[3])
            for ch in a[1].upper():
                snap = {'path': st['path'], 'models': dict(st['models']), 'frames': dict(st['frames']),
                        'scale': st['scale'], 'off': tuple(st['off']), 'ang': st['ang'],
                        'pit': st['pit'], 'rol': st['rol']}
                sink[(cls.lower(), a[0].upper(), ch)] = snap
        i += 1 + n

def read_modeldefs(paks):
    table = {}
    for pk in paks:
        def run(text):
            t = strip_comments(text)
            for m in re.finditer(r'#include\s+"([^"]+)"', t):
                inc = pk.get(m.group(1))
                if inc is not None: run(inc.decode('latin-1'))
            for cls, body in parse_modeldef(text):
                walk_block(cls, body, table)
        for low, real in sorted(pk.names.items()):
            base = low.rsplit('/', 1)[-1]
            if '/' in low or not base.startswith('modeldef'): continue
            run(pk.z.read(real).decode('latin-1'))
    return table

# ---- geometry: glRotate matrices (VSMatrix::rotate), degrees ------------------------------
def Ry(a, v):
    c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
    return (v[0] * c + v[2] * s, v[1], -v[0] * s + v[2] * c)
def Rx(a, v):
    c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
    return (v[0], v[1] * c - v[2] * s, v[1] * s + v[2] * c)
def Rz(a, v):
    c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
    return (v[0] * c - v[1] * s, v[0] * s + v[1] * c, v[2])
def add(a, b): return tuple(x + y for x, y in zip(a, b))
def sub(a, b): return tuple(x - y for x, y in zip(a, b))
def mul(a, k): return tuple(x * k for x in a)
def dot(a, b): return sum(x * y for x, y in zip(a, b))
def norm(a):
    l = math.sqrt(dot(a, a)) or 1.0
    return mul(a, 1.0 / l)

def to_hud(snap, m):
    """A point in the model's own axes (already md3 (x, z, y)) -> the controller HUD frame, at rest."""
    v = Rx(-snap['rol'], m)
    v = Rz(snap['pit'], v)
    v = Ry(-snap['ang'], v)
    v = Ry(90.0, v)
    xs, ys, zs = snap['scale']
    v = (v[0] * xs, v[1] * zs, v[2] * ys)
    return v            # without the Offset: the displacement from the gun's turning point

def offset_hud(snap):
    ox, oy, oz = snap['off']
    return (ox, oz, oy)

def principal(pts):
    n = len(pts)
    c = [sum(p[i] for p in pts) / n for i in range(3)]
    q = [[0.0] * 3 for _ in range(3)]
    for p in pts:
        d = [p[i] - c[i] for i in range(3)]
        for i in range(3):
            for j in range(3):
                q[i][j] += d[i] * d[j]
    v = [1.0, 0.3, 0.1]
    for _ in range(100):
        w = [sum(q[i][j] * v[j] for j in range(3)) for i in range(3)]
        mm = math.sqrt(sum(t * t for t in w)) or 1.0
        v = [t / mm for t in w]
    return v

TIP_CELL = 0.5        # cm: vertices closer than this across the barrel are one piece
TIP_DOMINANT = 0.5    # one piece holding more than this share of the slab is the barrel

def dominant_piece(tip, d):
    # connected pieces of the slab's vertices, seen down the barrel, on a TIP_CELL grid
    u = norm((1.0, 0.0, 0.0) if abs(d[0]) < 0.9 else (0.0, 1.0, 0.0))
    u = norm(sub(u, mul(d, dot(u, d))))
    v = (d[1] * u[2] - d[2] * u[1], d[2] * u[0] - d[0] * u[2], d[0] * u[1] - d[1] * u[0])
    cells = {}
    for i, p in enumerate(tip):
        cells.setdefault((math.floor(dot(p, u) / TIP_CELL), math.floor(dot(p, v) / TIP_CELL)), []).append(i)
    seen, best = set(), []
    for c0 in cells:
        if c0 in seen: continue
        seen.add(c0); stack, comp = [c0], []
        while stack:
            c = stack.pop(); comp += cells[c]
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    n = (c[0] + dx, c[1] + dy)
                    if n in cells and n not in seen:
                        seen.add(n); stack.append(n)
        if len(comp) > len(best): best = comp
    if len(best) < len(tip) and len(best) > TIP_DOMINANT * len(tip):
        return [tip[i] for i in best]
    return None

def measure(snap, find, d=None):
    """-> (muzzle q0 from the turning point, barrel unit d, note) in the HUD frame, or None.
    d: the barrel, when it is known from elsewhere (a frame the gun was turned into)."""
    pts = []
    for mi, fname in sorted(snap['models'].items()):
        if not fname.strip(): continue
        mf = snap['frames'].get(mi, 0)
        path = (snap['path'].rstrip('/') + '/' + fname) if snap['path'] else fname
        data = find(path)
        if data is None: return None, None, 'missing ' + path
        ext = fname.lower().rsplit('.', 1)[-1]
        if ext == 'md3': raw = md3_points(data, mf)
        elif ext == 'obj': raw = obj_points(data)
        else: return None, None, 'format ' + fname
        pts += [to_hud(snap, (p[0], p[2], p[1])) for p in raw]
    if not pts: return None, None, 'no mesh'
    # THE BARREL: the held model's +x axis -- BD22Q builds every held gun along x, and the
    # engine's chain above turns model +x to the controller's forward (-z: hw_vrmodes.cpp
    # MapWeaponDir fires along the hand matrix's -z). (measure_pickups.py calls it the -x end in
    # its own axes, which turn the other way.) Taken through this block's scale and angle offsets.
    if d is None: d = norm(to_hud(snap, (1.0, 0.0, 0.0)))
    # THE MUZZLE: the end of the mesh along the barrel; the bore is the middle of the last
    # TIP_SLAB cm of it, across the barrel.
    tmax = max(dot(p, d) for p in pts)
    tip = [p for p in pts if dot(p, d) >= tmax - TIP_SLAB]
    # A barrel with something beside it at the same length (a pump gun's magazine tube under
    # its barrel) puts the slab's middle between the two. When one connected piece holds most
    # of the slab's vertices, that piece is the barrel; a ring of sparse vertices (a rocket
    # tube, a minigun's barrel cluster) has no such piece and keeps the slab's middle.
    big = dominant_piece(tip, d)
    if big: tip = big
    perp = [sub(p, mul(d, dot(p, d))) for p in tip]
    lo = [min(p[i] for p in perp) for i in range(3)]
    hi = [max(p[i] for p in perp) for i in range(3)]
    mid = tuple((lo[i] + hi[i]) / 2 for i in range(3))
    q0 = add(mid, mul(d, tmax))
    ax = principal(pts)
    if dot(ax, d) < 0: ax = [-t for t in ax]
    dev = math.degrees(math.acos(max(-1.0, min(1.0, dot(ax, d)))))
    if dev > MAX_AXIS_DEV:
        return None, None, 'its long axis is %.1f deg off the model x axis: not a gun built along x' % dev
    return q0, d, 'long axis %.1f deg off the barrel; tip %d verts' % (dev, len(tip))

def mesh_points(snap, find):
    """Every vertex of the pose's meshes in the HUD frame (md3 only: an OBJ has one frame)."""
    pts = []
    for mi, fname in sorted(snap['models'].items()):
        if not fname.strip(): continue
        if not fname.lower().endswith('.md3'): return None
        path = (snap['path'].rstrip('/') + '/' + fname) if snap['path'] else fname
        data = find(path)
        if data is None: return None
        pts += [to_hud(snap, (p[0], p[2], p[1])) for p in md3_points(data, snap['frames'].get(mi, 0))]
    return np.array(pts) if pts else None

def rigid(cache, pk0, snap0, pk1, snap1, find, d=None):
    """(R, t, residual cm) of the rigid motion carrying pose 0's gun onto pose 1's, or None.
    Robust to small parts that move on their own (BD's Rifle fire frames slide 56 of its 14498
    vertices -- the bolt -- 1.2 cm, measured): fitted (Kabsch, least squares) on every vertex,
    then again on those within RIGID_RES of the first fit. The residual reported is the worst
    over the vertices at the muzzle end (the last TIP_SLAB cm along d), the part the beam rides;
    a frame where under RIGID_SHARE of the gun follows the motion reports infinity."""
    for pk, sn in ((pk0, snap0), (pk1, snap1)):
        if pk not in cache: cache[pk] = mesh_points(sn, find)
    A, B = cache[pk0], cache[pk1]
    if A is None or B is None or len(A) != len(B): return None
    def fit(A, B):
        ca, cb = A.mean(0), B.mean(0)
        U, S, Vt = np.linalg.svd((A - ca).T @ (B - cb))
        D = np.diag([1.0, 1.0, float(np.sign(np.linalg.det(Vt.T @ U.T)))])
        R = Vt.T @ D @ U.T
        return R, cb - R @ ca
    R, tr = fit(A, B)
    r = np.sqrt(((A @ R.T + tr - B) ** 2).sum(1))
    keep = r <= RIGID_RES
    if keep.sum() < RIGID_SHARE * len(A): return R, tr, float('inf')
    R, tr = fit(A[keep], B[keep])
    r = np.sqrt(((A @ R.T + tr - B) ** 2).sum(1))
    if (r <= RIGID_RES).sum() < RIGID_SHARE * len(A): return R, tr, float('inf')
    if d is not None:
        sd = A @ np.array(d)
        tip = sd >= sd.max() - TIP_SLAB
        return R, tr, float(r[tip].max())
    return R, tr, float(r.max())

def xlines(snap, find):
    """How many straight runs of the mesh lie exactly along its own x axis: vertices sharing (y, z)
    to md3 precision (1/64) more than 5 units apart in x. An animated md3 can hold the gun turned
    in some frames (BD's SSG.md3 frame 0 is pitched 5 deg from frame 1, measured); the frame the
    gun was BUILT in, along x, is the one where its barrel, rails and edges run along x."""
    runs = {}
    for mi, fname in sorted(snap['models'].items()):
        if not fname.strip() or not fname.lower().endswith('.md3'): continue
        path = (snap['path'].rstrip('/') + '/' + fname) if snap['path'] else fname
        data = find(path)
        if data is None: continue
        for p in md3_points(data, snap['frames'].get(mi, 0)):
            k = (mi, round(p[1] * 64), round(p[2] * 64))
            lo, hi = runs.get(k, (p[0], p[0]))
            runs[k] = (min(lo, p[0]), max(hi, p[0]))
    return sum(1 for lo, hi in runs.values() if hi - lo > 5)

def mesh_id(snap):
    return (snap['path'], tuple(sorted(snap['models'].items())), snap['scale'], snap['off'], snap['ang'], snap['pit'], snap['rol'])

def pose_key(snap):
    return (snap['path'], tuple(sorted(snap['models'].items())),
            tuple(sorted((k, v) for k, v in snap['frames'].items() if k in snap['models'])),
            snap['scale'], snap['off'], snap['ang'], snap['pit'], snap['rol'])

# ---- KVX ----------------------------------------------------------------------------------
def write_kvx(path, n, pivot):
    """A 1 x 1 x n rod along +x; voxel x carries palette index 1 + 253 * distance / FADE_MAX."""
    xs, ys, zs = n, 1, 1
    cols = []
    for x in range(n):
        d = (x + 0.5) * BEAM_S
        idx = 1 + min(253, int(d / FADE_MAX * 254))
        cull = 4 | 8 | 16 | 32 | (1 if x == 0 else 0) | (2 if x == n - 1 else 0)
        cols.append(bytes([0, 1, cull, idx]))
    offsetsize = (xs + 1) * 4 + xs * (ys + 1) * 2
    xoff, xy, data, pos = [], [], b'', offsetsize
    for c in cols:
        xoff.append(pos)
        xy += [0, len(c)]
        data += c
        pos += len(c)
    xoff.append(pos)
    body = struct.pack('<6i', xs, ys, zs, *[int(round(p * 256)) for p in pivot])
    body += struct.pack('<%di' % len(xoff), *xoff) + struct.pack('<%dh' % len(xy), *xy) + data
    pal = bytes(sum(([i >> 2] * 3 for i in range(256)), []))
    with open(path, 'wb') as f:
        f.write(struct.pack('<i', len(body)) + body + pal)

def rod_angles(d):
    """The rod lies along voxel +x. AngleOffset turns it about y BEFORE the layer's turn, the
    layer's turn (its own y offset: pitch (y - WEAPONTOP) / -4, hw_weapon.cpp) pitches it about x
    AFTER: dir = Rx(phi) Ry(theta) (1, 0, 0) = (cos t, sin t sin p, -sin t cos p). The pitch rides
    on the gun layer's own turn exactly, because Rx(gun + phi) = Rx(gun) Rx(phi)."""
    theta = math.degrees(math.atan2(math.hypot(d[1], d[2]), d[0]))
    phi = math.degrees(math.atan2(d[1], -d[2]))
    return theta, phi

def b36(i):
    s = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return s[i // 36] + s[i % 36]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--ready', required=True)
    ap.add_argument('--dry', action='store_true', help='measure and print only')
    ap.add_argument('pk3s', nargs='+')
    a = ap.parse_args()
    paks = [Pak(p) for p in a.pk3s]
    fcache = {}
    def find(path):
        if path.lower() in fcache: return fcache[path.lower()]
        for pk in reversed(paks):
            d = pk.get(path)
            if d is not None:
                fcache[path.lower()] = d
                return d
        return None
    table = read_modeldefs(paks)

    ready = []
    for line in open(a.ready, encoding='latin-1'):
        m = re.match(r'PR (\S+) (\S+) (\d+)(?: (\S+))?', line)
        if m and m.group(2)[:4].upper() != 'TNT1':
            ready.append((m.group(1), m.group(2)[:4].upper(), chr(65 + int(m.group(3))), m.group(4) == 'melee'))

    placements = []        # (off, q0, d) unique
    rows = []              # (class, pose) rows; a class may have several (one per pose it rests in)
    skipped = []
    order, cands = [], {}
    mesh_cache, kick_stats, built, xl_cache = {}, [], {}, {}
    for cls, spr, fr, melee in ready:
        if cls not in cands: order.append(cls); cands[cls] = []
        cands[cls].append((spr, fr, melee))
    for cls in order:
        notes, rests = [], []
        for spr, fr, melee in cands[cls]:
            if melee:
                # +WEAPON.MELEEWEAPON (the engine's own flag, from the probe): a fist or a blade has
                # no bore, so no beam -- whatever its mesh's far end looks like.
                notes = ['a melee weapon (+WEAPON.MELEEWEAPON): no bore']; rests = []
                break
            snap = table.get((cls.lower(), spr, fr))
            if not snap:
                notes.append('no model for its Ready frame %s %s (a sprite or a voxel)' % (spr, fr))
                continue
            if pose_key(snap) not in [pose_key(x[0]) for x in rests]:
                rests.append((snap, spr + fr))
        # THE FRAME EACH MESH WAS BUILT IN (most runs along x, xlines) is the one whose barrel is
        # the model's x axis; every other frame of that mesh -- rest poses too -- gets its barrel
        # from the motion carrying the built frame onto it (Kabsch, `rigid`), and, if the gun
        # moved rigidly (RIGID_RES), its muzzle the same way; otherwise its own tip.
        frames_of = {}
        for (c, s2, f2), sn in table.items():
            if c == cls.lower(): frames_of.setdefault(mesh_id(sn), []).append((s2, f2, sn))
        def basis(sn):
            mid = mesh_id(sn)
            if mid not in built:
                cands_b = {}
                for s2, f2, sx in frames_of.get(mid, [(None, None, sn)]):
                    cands_b.setdefault(pose_key(sx), sx)
                def xl(sx):
                    k = pose_key(sx)
                    if k not in xl_cache: xl_cache[k] = xlines(sx, find)
                    return xl_cache[k]
                ref = max(cands_b.values(), key=lambda sx: (xl(sx), -sx['frames'].get(0, 0)))
                built[mid] = (ref, measure(ref, find))
            return built[mid]
        def place(sn):
            """-> (q, d, residual cm or None, note) for any frame of this class, or None + why."""
            ref, (qr, dr, nr) = basis(sn)
            if qr is None: return None, None, None, nr
            if pose_key(ref) == pose_key(sn): return qr, dr, 0.0, nr
            m = rigid(mesh_cache, pose_key(ref), ref, pose_key(sn), sn, find, dr)
            if m is None:
                q, d, n = measure(sn, find)
                return q, d, None, n
            R, tr, res = m
            d = norm(tuple(float(x) for x in R @ np.array(dr)))
            if res <= RIGID_RES:
                return tuple(float(x) for x in R @ np.array(qr) + tr), d, res, nr
            q, d, n = measure(sn, find, d)
            return q, d, res, n + '; barrel from the frame the mesh was built in, turned with the gun (fit to %.2f cm)' % res
        poses = []
        for snap, rf in rests:
            q0, d, _r, note = place(snap)
            if q0 is None:
                notes.append('%s: %s' % (rf, note)); continue
            tilt = math.degrees(math.asin(max(-1.0, min(1.0, d[1]))))
            if abs(tilt) > MAX_TILT:
                notes.append('%s: barrel %.1f deg off level in the hand: a blade, not a barrel' % (rf, tilt))
                continue
            poses.append((pose_key(snap), snap, rf, q0, d, note))
        if not poses:
            skipped.append((cls, '; '.join(notes) if notes else 'no ready frame'))
            continue
        nrest = len(poses)
        # EVERY OTHER FRAME of the class's model whose gun moved rigidly (its muzzle and barrel
        # exact): still on a rest pose's bore (PERP_TOL / ALONG_TOL / ANGLE_TOL) -> draws that
        # pose's beam; a recoil kick (within KICK_CM / KICK_DEG of a rest pose) -> a pose of its
        # own; anything else (a reload, the gun coming apart) -> no beam.
        joined, kicks = {}, []
        for (c, s2, f2), sn in table.items():
            if c != cls.lower(): continue
            pk2 = pose_key(sn)
            if pk2 in [x[0] for x in poses]: continue
            fname = '%s%d' % (s2, ord(f2) - 65)
            best = None
            for j in range(nrest):
                pk, snap, rf, q0, d, note = poses[j]
                if mesh_id(sn) != mesh_id(snap): continue
                m = rigid(mesh_cache, pk, snap, pk2, sn, find, d)    # the gun's motion from this rest pose
                if m is None or m[2] > RIGID_RES: continue
                R, tr, res = m
                q2 = tuple(float(x) for x in R @ np.array(q0) + tr)
                d2 = norm(tuple(float(x) for x in R @ np.array(d)))
                ang = math.degrees(math.acos(max(-1.0, min(1.0, dot(d2, d)))))
                dq = sub(q2, q0)
                along = dot(dq, d)
                perp = math.sqrt(max(0.0, dot(dq, dq) - along * along))
                if ang <= ANGLE_TOL and perp <= PERP_TOL and abs(along) <= ALONG_TOL:
                    best = ('join', j, along); break
                dist = math.sqrt(dot(dq, dq))
                if ang <= KICK_DEG and dist <= KICK_CM and (best is None or dist < best[2]):
                    best = ('kick', j, dist, ang, q2, d2, res)
            if best is None: continue
            if best[0] == 'join':
                joined.setdefault(best[1], []).append(fname); kick_stats.append(abs(best[2]))
            else:
                kicks.append((pk2, sn, s2 + f2, best[4], best[5], 'kick %.2f cm %.2f deg off %s (rigid to %.2f cm)' % (best[2], best[3], poses[best[1]][2], best[6])))
        poses += kicks
        for j, (pk, snap, rf, q0, d, note) in enumerate(poses):
            off = offset_hud(snap)
            key = (tuple(round(x, 3) for x in off), tuple(round(x, 3) for x in q0), tuple(round(x, 5) for x in d))
            if key not in [p[0] for p in placements]:
                placements.append((key, off, q0, d))
            pi = [p[0] for p in placements].index(key)
            same = sorted(set('%s%d' % (s, ord(f) - 65) for (c, s, f), sn in table.items() if c == cls.lower() and pose_key(sn) == pk) | set(joined.get(j, [])))
            # Two poses with the same muzzle (another skin, say) are one row: their frames merge.
            prev = [i for i, r in enumerate(rows) if r[0] == cls and r[1] == pi]
            if prev:
                r = rows[prev[0]]
                rows[prev[0]] = r[:3] + (sorted(set(r[3]) | set(same)),) + r[4:]
                continue
            rows.append((cls, pi, rf, same, snap['scale'][0] < 0, note, q0, d, off))

    if kick_stats:
        print('%d kicked frames joined to a rest pose (largest kick along the bore %.2f cm)' % (len(kick_stats), max(kick_stats)))
    print('%d weapons measured, %d placements, %d skipped' % (len(rows), len(placements), len(skipped)))
    for cls, pi, rf, same, mir, note, q0, d, off in rows:
        print('%-26s p%02d %s  muzzle F %.2f L %.2f U %.2f cm from turn point  dir (%.4f %.4f %.4f)  %d ready frames  %s'
              % (cls, pi, rf, -q0[2], q0[0], q0[1], d[0], d[1], d[2], len(same), note))
    for cls, why in skipped:
        print('skip %-24s %s' % (cls, why))
    if a.dry: return

    # ---- the rods and VOXELDEF ----
    bdir = os.path.join(ROOT, 'models', 'rsqls', 'beam')
    os.makedirs(bdir, exist_ok=True)
    for f in os.listdir(bdir):
        if f.endswith('.kvx'): os.remove(os.path.join(bdir, f))
    K = len(LENGTHS)
    vd = ['// GENERATED by tools/gen_beams.py -- edit that, not this.',
          '// The laser beam: one voxel rod per (gun placement, length). A voxel is found by its',
          '// sprite frame alone (models.cpp FindModelFrameRaw), so it is drawn for ANY caller --',
          '// the beam layer is called by the gun itself and rides that gun\'s controller.',
          '// Offset = the gun\'s own MODELDEF Offset (its turning point); the muzzle is the KVX pivot.',
          '// Lengths (cm): ' + ' '.join('%g' % L for L in LENGTHS), '']
    sprites = []
    for pi, (key, off, q0, d) in enumerate(placements):
        theta, phi = rod_angles(d)
        t = mul(Ry(-theta, Rx(-phi, q0)), 1.0 / BEAM_S)
        pivot = (-t[0], t[2] + 0.5, t[1] + 0.5)     # (px, py, pz): see the module notes
        vd.append('// placement %d: muzzle %.2f %.2f %.2f cm (x y z, HUD frame) from Offset %.2f %.2f %.2f; yaw %.3f, pitch %.3f (layer y %.2f)'
                  % (pi, q0[0], q0[1], q0[2], off[0], off[1], off[2], theta, phi, -4 * phi))
        for k, L in enumerate(LENGTHS):
            g = pi * K + k
            spr = SPRITE_PREFIX + b36(g // 26)
            if spr not in sprites: sprites.append(spr)
            fr = chr(65 + g % 26)
            n = max(1, int(round(L / BEAM_S)))
            fn = 'p%02dk%02d.kvx' % (pi, k)
            write_kvx(os.path.join(bdir, fn), n, pivot)
            # VOXELDEF offsets are MODELDEF's: xoffset, yoffset (back), zoffset (up)
            vd.append('%s%s = "models/rsqls/beam/%s" { Scale = %.4f AngleOffset = %.4f XOffset = %.4f YOffset = %.4f ZOffset = %.4f OverridePalette }'
                      % (spr, fr, fn, BEAM_S, -theta, off[0], off[2], off[1]))
    open(os.path.join(ROOT, 'VOXELDEF.txt'), 'w').write('\n'.join(vd) + '\n')

    # ---- the ZScript table ----
    z = ['// GENERATED by tools/gen_beams.py from the held models of: ' + ' -> '.join(os.path.basename(p) for p in a.pk3s),
         '// Do not edit. Per gun class: its beam placement, the frames that draw it in its ready pose',
         '// (the beam shows only on those: on any other frame the mesh has moved off the measured muzzle),',
         '// whether its model is mirrored, and its muzzle and barrel in the HUD frame (cm, x / y up / z',
         '// back, from the hand pose, at vr_weaponScale 1) for the dot\'s trace.',
         'class RSQLS_Muzzles abstract', '{',
         '\tconst NLEN = %d;' % K,
         '\tconst BEAM_S = %.4f;' % BEAM_S,
         '\tconst FADE_MAX = %.1f;' % FADE_MAX,
         '\tstatic const double LENGTHS[] = { %s };' % ', '.join('%.1f' % L for L in LENGTHS),
         '\tstatic const String SPRITES[] = { %s };' % ', '.join('"%s"' % s for s in sprites),
         '\t// class, placement, mirrored, ready-pose frames (sprite name + frame number, space separated).',
         '\t// A class that rests in more than one pose (a pistol with and without a round chambered) has a',
         '\t// row per pose, adjacent; the first is the pose the dot is traced from while none is shown.',
         '\tstatic const String CLASSES[] = {']
    for cls, pi, rf, same, mir, note, q0, d, off in rows:
        z.append('\t\t"%s", "%d", "%d", "%s",' % (cls, pi, 1 if mir else 0, ' '.join(same)))
    z[-1] = z[-1].rstrip(',')
    z += ['\t};', '\t// per placement: turning point (Offset), muzzle from it, barrel direction, and the rod\'s',
          '\t// pitch as the beam layer\'s own y offset (-4 x degrees): 10 numbers',
          '\tstatic const double PLACE[] = {']
    for key, off, q0, d in placements:
        th, ph = rod_angles(d)
        z.append('\t\t%.4f, %.4f, %.4f,  %.4f, %.4f, %.4f,  %.6f, %.6f, %.6f,  %.4f,' % (off + q0 + d + (-4 * ph,)))
    z[-1] = z[-1].rstrip(',')
    z += ['\t};', '}', '',
          '// THE BEAM LAYER\'S STATES, on an item the player carries. The layer is MADE with this item as',
          '// its caller, so the first state\'s action passes the VM\'s invoker check (an action of class X',
          '// refuses an invoker that is not an X) and sets the layer additive -- A_Overlay* only work from',
          '// a psprite action. beam.zs then hands the layer to the GUN (PSprite.Caller), which the',
          '// renderer reads for the controller and the turn; the -1 state never runs an action again.',
          '// Its sprite and frame are written per tic to pick the rod. The Rods states exist so every',
          '// rod sprite name exists (VOXELDEF only takes a sprite some state names).',
          'class RSQLS_BeamLayer : Inventory', '{',
          '\tDefault { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.QUIET }',
          '\t// an ACTION function (self: the player, invoker: this item), called with no arguments so',
          '\t// the state calls it directly -- an anonymous block here would take the item as self.',
          '\taction void A_RSQLSAdditive() { A_OverlayFlags(0, PSPF_RENDERSTYLE | PSPF_FORCESTYLE, true); A_OverlayRenderStyle(0, STYLE_Add); }',
          '\tStates', '\t{', '\tSpawn: TNT1 A -1; Stop;',
          '\tBeam:',
          '\t\tTNT1 A 0 A_RSQLSAdditive;',
          '\t\t%s A -1 Bright;' % sprites[0], '\t\tStop;', '\tRods:']
    for spr in sprites:
        z.append('\t\t%s ABCDEFGHIJKLMNOPQRSTUVWXYZ -1;' % spr)
    z += ['\t\tStop;', '\t}', '}', '']
    open(os.path.join(ROOT, 'zscript', 'rsqls', 'muzzles.zs'), 'w').write('\n'.join(z))

    # ---- the table for people ----
    t = ['MUZZLES -- GENERATED by tools/gen_beams.py. Measured from each gun\'s held (Ready-frame) model:',
         '  ' + ' -> '.join(os.path.basename(p) for p in a.pk3s),
         'HUD frame of the controller, centimetres: F forward, L left/right (x), U up. "muzzle" is from the',
         'model\'s MODELDEF Offset (its turning point); the beam starts there and runs along "barrel".',
         '',
         '%-26s %-4s %-6s %8s %8s %8s   %-24s %s' % ('class', 'pl', 'ready', 'F', 'x', 'U', 'barrel (x y z)', 'frames / note')]
    for cls, pi, rf, same, mir, note, q0, d, off in rows:
        t.append('%-26s p%02d  %-6s %8.2f %8.2f %8.2f   (%.4f %.4f %.4f)  %d%s; %s'
                 % (cls, pi, rf, -q0[2], q0[0], q0[1], d[0], d[1], d[2], len(same), ' mirrored' if mir else '', note))
    t += ['', 'NO BEAM (no measurement, so no beam rather than a wrong one):']
    for cls, why in skipped:
        t.append('  %-26s %s' % (cls, why))
    open(os.path.join(ROOT, 'docs', 'MUZZLES.txt'), 'w').write('\n'.join(t) + '\n')
    print('wrote %d rods, VOXELDEF.txt, muzzles.zs, docs/MUZZLES.txt' % (len(placements) * K))

if __name__ == '__main__':
    main()
