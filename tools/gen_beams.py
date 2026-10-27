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

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))

BEAM_S = 0.4          # cm per voxel: the rod's width
FADE_MAX = 600.0      # cm: the longest fade the menu offers; index 254 is here
TIP_SLAB = 1.5        # cm: the slice at the very end of the barrel whose middle is the bore
MAX_TILT = 15.0       # degrees: more than this off level is a blade held up, not a barrel
MAX_AXIS_DEV = 30.0   # degrees: a mesh whose long axis is this far off x is not a barrel along x
SPRITE_PREFIX = 'LZ'  # LZ00..LZzz, 26 frames each

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

def md3_points(data, frame):
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

def measure(snap, find):
    """-> (muzzle q0 from the turning point, barrel unit d, note) in the HUD frame, or None."""
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
    d = norm(to_hud(snap, (1.0, 0.0, 0.0)))
    # THE MUZZLE: the end of the mesh along the barrel; the bore is the middle of the last
    # TIP_SLAB cm of it, across the barrel.
    tmax = max(dot(p, d) for p in pts)
    tip = [p for p in pts if dot(p, d) >= tmax - TIP_SLAB]
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
    def find(path):
        for pk in reversed(paks):
            d = pk.get(path)
            if d is not None: return d
        return None
    table = read_modeldefs(paks)

    ready = []
    for line in open(a.ready, encoding='latin-1'):
        m = re.match(r'PR (\S+) (\S+) (\d+)(?: (\S+))?', line)
        if m and m.group(2)[:4].upper() != 'TNT1':
            ready.append((m.group(1), m.group(2)[:4].upper(), chr(65 + int(m.group(3))), m.group(4) == 'melee'))

    placements = []        # (off, q0, d) unique
    rows = []              # class rows
    skipped = []
    for cls, spr, fr, melee in ready:
        if melee:
            # +WEAPON.MELEEWEAPON (the engine's own flag, from the probe): a fist or a blade has
            # no bore, so no beam -- whatever its mesh's far end looks like.
            skipped.append((cls, 'a melee weapon (+WEAPON.MELEEWEAPON): no bore'))
            continue
        snap = table.get((cls.lower(), spr, fr))
        if not snap:
            skipped.append((cls, 'no model for its Ready frame %s %s (a sprite or a voxel)' % (spr, fr)))
            continue
        q0, d, note = measure(snap, find)
        if q0 is None:
            skipped.append((cls, note)); continue
        tilt = math.degrees(math.asin(max(-1.0, min(1.0, d[1]))))
        if abs(tilt) > MAX_TILT:
            skipped.append((cls, 'barrel %.1f deg off level in the hand: a blade, not a barrel' % tilt))
            continue
        off = offset_hud(snap)
        key = (tuple(round(x, 3) for x in off), tuple(round(x, 3) for x in q0), tuple(round(x, 5) for x in d))
        if key not in [p[0] for p in placements]:
            placements.append((key, off, q0, d))
        pi = [p[0] for p in placements].index(key)
        pk = pose_key(snap)
        same = sorted('%s%d' % (s, ord(f) - 65) for (c, s, f), sn in table.items() if c == cls.lower() and pose_key(sn) == pk)
        mirrored = snap['scale'][0] * snap['scale'][1] * snap['scale'][2] < 0 or snap['scale'][0] < 0
        rows.append((cls, pi, spr + fr, same, snap['scale'][0] < 0, note, q0, d, off))

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
         '\t// class, placement, mirrored, ready-pose frames (sprite name + frame number, space separated)',
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
