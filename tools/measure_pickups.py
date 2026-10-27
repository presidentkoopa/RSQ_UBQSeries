#!/usr/bin/env python3
"""measure_pickups.py -- measure how each weapon's pickup looks, for the rig's stored guns.

The rig shows a stored weapon as its own pickup (A_ChangeModel borrows the weapon's MODELDEF).
Pickups are made to lie on a floor: each pack's author chose its size and which way it points,
so they come out every size and facing (measured: the Devastator's model points backward, the
AssaultShotgun's end-on). The game cannot measure a model while running, so this measures them
here, from the load order's own files, and writes a table the rig reads (lump RSQTRFIT):

    <Class> <length in map units> <yaw> <pitch>

length: the pickup's longest extent at actor scale 1; yaw / pitch: the turn (degrees, actor
sense: yaw to the left, pitch nose-down) that brings its MUZZLE onto the actor's forward axis.

Which end is the muzzle: the thinner end along the long axis (a barrel, against a stock, a grip
or a receiver). Only a first guess -- with BD22Q it was wrong for about half the guns -- so each
gun is checked by eye in a frame dump (tools/flips_*.txt records the ones turned round, and how
they were checked), and the rig has a menu list for any still wrong (rsqtr_icon_flip).

Usage:
    measure_pickups.py --dump pdump.log --out RSQTRFIT.txt [--flip Class ...] pk3 [pk3 ...]
pk3s in load order (a later file's MODELDEF entry for the same class and frame wins). The dump
is the engine's own answer to "which sprite frame does each weapon's pickup start on" (lines
`PD <Class> <SPRITELUMP> <frame>`, from the pickdump probe), so the tool reads no DECORATE.
"""
import argparse, math, re, struct, sys, zipfile

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
    """Yields (class, props) per Model block; props keeps the block's settings in order."""
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

KEYS_ARGS = {'path': 1, 'model': 2, 'skin': 2, 'surfaceskin': 3, 'scale': 3, 'offset': 3,
             'zoffset': 1, 'angleoffset': 1, 'pitchoffset': 1, 'rolloffset': 1,
             'frameindex': 4, 'frame': 4, 'rotation-speed': 1, 'rotation-vector': 3,
             'rotation-center': 3, 'animation': 2, 'baseframe': 0}

def block_settings(body):
    s = {'path': '', 'models': {}, 'scale': (1.0, 1.0, 1.0), 'angle': 0.0, 'pitch': 0.0,
         'roll': 0.0, 'frames': []}
    i = 0
    while i < len(body):
        k = body[i].lower()
        n = KEYS_ARGS.get(k)
        if n is None:
            i += 1; continue
        a = [x.strip('"') for x in body[i + 1:i + 1 + n]]
        if k == 'path': s['path'] = a[0]
        elif k == 'model': s['models'][int(a[0])] = a[1]
        elif k == 'scale': s['scale'] = tuple(float(x) for x in a)
        elif k == 'angleoffset': s['angle'] = float(a[0])
        elif k == 'pitchoffset': s['pitch'] = float(a[0])
        elif k == 'rolloffset': s['roll'] = float(a[0])
        elif k in ('frameindex', 'frame'):
            s['frames'].append((a[0].upper(), a[1].upper(), int(a[2]), a[3]))
        i += 1 + n
    return s

# ---- mesh readers: points in the model's own axes (x forward, y left, z up) ------------
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
            pts.append((x, -z, y))          # OBJ is y-up; turned to z-up (GZDoom's reading)
    return pts

def kvx_points(data):
    # Build engine KVX: numbytes, xsiz, ysiz, zsiz, pivots (8.8), offsets, then columns.
    numbytes, xs, ys, zs, xp, yp, zp = struct.unpack_from('<7i', data, 0)
    xoff = struct.unpack_from('<%di' % (xs + 1), data, 28)
    xyoff = struct.unpack_from('<%dH' % (xs * (ys + 1)), data, 28 + (xs + 1) * 4)
    pts = []
    for x in range(xs):
        for y in range(ys):
            # column data lives at 28 + xoff[x] + xyoff[...] counted from the start of xoff
            ca = 28 + xoff[x] + xyoff[x * (ys + 1) + y]
            cb = 28 + xoff[x] + xyoff[x * (ys + 1) + y + 1]
            while ca < cb:
                ztop, zleng, cull = data[ca], data[ca + 1], data[ca + 2]
                for k in range(zleng):
                    # voxel x right->forward axis is engine's business; keep raw: x, y, z-down
                    pts.append((x - xp / 256.0, y - yp / 256.0, -(ztop + k - zp / 256.0)))
                ca += 3 + zleng
    return pts

# ---- geometry ------------------------------------------------------------------------
def rot(p, yaw, pitch, roll):
    x, y, z = p
    # roll about x, pitch about y (nose down for +), yaw about z (to the left for +)
    cr, sr = math.cos(math.radians(roll)), math.sin(math.radians(roll))
    y, z = y * cr - z * sr, y * sr + z * cr
    cp, sp = math.cos(math.radians(pitch)), math.sin(math.radians(pitch))
    x, z = x * cp + z * sp, -x * sp + z * cp
    cy, sy = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
    x, y = x * cy - y * sy, x * sy + y * cy
    return (x, y, z)

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
    for _ in range(100):                       # power iteration: the long axis
        w = [sum(q[i][j] * v[j] for j in range(3)) for i in range(3)]
        m = math.sqrt(sum(t * t for t in w)) or 1.0
        v = [t / m for t in w]
    return c, v

def measure(pts):
    c, ax = principal(pts)
    proj = [sum((p[i] - c[i]) * ax[i] for i in range(3)) for p in pts]
    lo, hi = min(proj), max(proj)
    length = hi - lo
    # THE THIN END: the spread across the axis in the end fifth of each side
    def spread(sel):
        if not sel: return 0.0
        ds = []
        for p, t in sel:
            d = [p[i] - c[i] - t * ax[i] for i in range(3)]
            ds.append(math.sqrt(sum(x * x for x in d)))
        ds.sort()
        return ds[int(len(ds) * 0.9)] if ds else 0.0
    cut = length * 0.2
    lo_end = [(p, t) for p, t in zip(pts, proj) if t < lo + cut]
    hi_end = [(p, t) for p, t in zip(pts, proj) if t > hi - cut]
    s_lo, s_hi = spread(lo_end), spread(hi_end)
    muzzle = ax if s_hi <= s_lo else [-a for a in ax]
    return length, muzzle, s_lo, s_hi

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dump', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--flip', nargs='*', default=[])
    ap.add_argument('--flips', help='a file of classes to flip end for end (one per line, # comments)')
    ap.add_argument('--only', nargs='*', default=[])
    ap.add_argument('--no-voxels', action='store_true')
    ap.add_argument('pk3s', nargs='+')
    a = ap.parse_args()

    if a.flips:
        for line in open(a.flips):
            line = line.split('#')[0].strip()
            if line: a.flip.append(line)
    flips = set(f.lower() for f in a.flip)
    paks = [Pak(p) for p in a.pk3s]
    def find(path):
        for pk in reversed(paks):
            d = pk.get(path)
            if d is not None: return d
        return None

    # (class, sprite, frame) -> (settings, model index, model frame); later files win
    table = {}
    voxel = {}
    for pk in paks:
        for low, real in sorted(pk.names.items()):
            base = low.rsplit('/', 1)[-1]
            if '/' in low or not base.startswith('modeldef'): continue
            text = pk.z.read(real).decode('latin-1')
            for cls, body in parse_modeldef(text):
                s = block_settings(body)
                # a frame can be drawn by several model parts (Model 0, Model 1, ...): kept
                # per part, a later definition of the same part replacing the earlier
                for spr, fr, mi, mf in s['frames']:
                    table.setdefault((cls.lower(), spr, fr), {})[int(mi)] = (s, mf)
                    # A VOXEL lent to pickups (BD22Q's RSV_* holders): a floor pickup is drawn
                    # by it, static and made to lie side-on, so the rig borrows it instead of
                    # the gun's own (first-person, animated, off-centre) model.
                    if s['models'].get(int(mi), '').lower().endswith('.kvx'):
                        voxel[(spr, fr)] = (cls, {int(mi): (s, mf)})

    pick = []
    for line in open(a.dump, encoding='latin-1'):
        m = re.match(r'PD (\S+) (\S+) (\d+)', line)
        if m and m.group(2) != 'TNT1A0':
            pick.append((m.group(1), m.group(2)[:4].upper(), chr(ord('A') + int(m.group(3)))))

    rows = []
    for cls, spr, fr in pick:
        if a.only and cls not in a.only: continue
        holder = cls
        parts = None
        if (spr, fr) in voxel and not a.no_voxels:
            holder, parts = voxel[(spr, fr)]
        if not parts: parts = table.get((cls.lower(), spr, fr))
        if not parts: continue                     # a sprite or a voxel by VOXELDEF: not measured
        allpts = []
        names = []
        for mi, (s, mf) in sorted(parts.items()):
            fname = s['models'].get(mi)
            if not fname or fname.strip() == '' : continue
            path = (s['path'].rstrip('/') + '/' + fname) if s['path'] else fname
            data = find(path)
            if data is None:
                print('missing', cls, path, file=sys.stderr); continue
            ext = fname.lower().rsplit('.', 1)[-1]
            try:
                if ext == 'md3': pts = md3_points(data, int(mf))
                elif ext == 'obj': pts = obj_points(data)
                elif ext == 'kvx': pts = kvx_points(data)
                else:
                    print('format', cls, fname, file=sys.stderr); continue
            except Exception as e:
                print('read', cls, fname, e, file=sys.stderr); continue
            sx, sy, sz = s['scale']
            pts = [(p[0] * sx, p[1] * sy, p[2] * sz) for p in pts]
            allpts += [rot(p, s['angle'], s['pitch'], s['roll']) for p in pts]
            names.append(path.rsplit('/', 1)[-1])
        if not allpts: continue
        pts = allpts
        path = '+'.join(names)
        ext = ''
        length, mz, s_lo, s_hi = measure(pts)
        # a flip covers the pack's copies of that gun too (Purist..., RSQ_Off_...)
        base = re.sub(r'^(Purist|RSQ_Off_)', '', cls)
        if cls.lower() in flips or base.lower() in flips: mz = [-t for t in mz]
        yaw = math.degrees(math.atan2(mz[1], mz[0]))
        pitch = -math.degrees(math.atan2(mz[2], math.hypot(mz[0], mz[1])))
        if all(n.lower().endswith('.kvx') for n in names):
            # A voxel made from a pickup sprite lies side-on along one of its own axes: the
            # long axis measured off a heavy grip or stock tilts (a revolver read 22 degrees),
            # so it is snapped to the axis and levelled.
            yaw = round(yaw / 90.0) * 90.0
            pitch = 0.0
        # the middle of its bounds, model axes: the rig moves the actor so this, not the
        # model's origin (a first-person model's origin is at the hand), sits on the region
        ctr = [(min(p[i] for p in pts) + max(p[i] for p in pts)) / 2 for i in range(3)]
        # sized by its largest extent, not only along the long axis: a squat pickup (the
        # Mancubus-arm missile pod measured 18 along its axis and stands taller) would else
        # be scaled up past everything else
        ext = sorted(max(p[i] for p in pts) - min(p[i] for p in pts) for i in range(3))
        length = max(length, ext[2])
        squat = ext[1] / ext[2] if ext[2] > 0 else 1.0     # 1 a cube, near 0 a long gun
        rows.append((cls, length, -yaw, -pitch, holder, path, s_lo, s_hi, ctr, squat))

    with open(a.out, 'w') as f:
        f.write('// RSQTRFIT -- GENERATED by tools/measure_pickups.py from the load order below. Do not edit.\n')
        f.write('// ' + ' -> '.join(p.rsplit('/', 1)[-1] for p in a.pk3s) + '\n')
        f.write('// <Class> <length, map units> <yaw> <pitch> <shown by> <centre x y z> <squat>: the turn\n')
        f.write('// putting the muzzle forward; the class whose MODELDEF draws it; the middle of its bounds;\n')
        f.write('// its second-largest extent over its largest (a long gun near 0, a box near 1)\n')
        for cls, length, yaw, pitch, holder, path, s_lo, s_hi, c, sq in rows:
            f.write('%s %.2f %.1f %.1f %s %.2f %.2f %.2f %.2f\n' % (cls, length, yaw, pitch, holder, c[0], c[1], c[2], sq))
    for r in rows:
        print('%-26s len %7.2f  yaw %7.1f  pitch %6.1f  %-12s %s  ends %.1f/%.1f' % (r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7]))

if __name__ == '__main__':
    main()
