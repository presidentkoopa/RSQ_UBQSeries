#!/usr/bin/env python3
"""gen_handprops.py -- the cigarette and the Zippo baked IN Brutal Doom VR's hand (owner 2026-10-31: "why is it not on
sprite layer ... we put it in hand"). Like BD's own grenade ring (rsq_ring_oh.md3, "baked in place"), each prop is moved
into the hand mesh's own space, so one MODELDEF block draws the hand and the prop together on the hand's layer, with the
hand block's own Scale -1 1 1 / Offset 0 -24 -10.

    python3 tools/gen_handprops.py --bd <BD22_VR-Reloaded_2_0_3h.pk3>

MEASURED from the BD pk3 (printed when run):
  * THE PINCH (the cigarette): fbx_oh_free_R.md3 frame 2 is BD's ring pinch (index and thumb pads closed) and
    rsq_ring_oh.md3's clip is held there: the clip is the densest knot of the ring's vertices. The cigarette's filter
    end sits FILTER_IN cm behind it, the cigarette running forward and out from the hand.
  * THE FIST (the Zippo): fbx_oh_free_R.md3 frame 1. Its grip hole is found by slicing the fist at mid height and
    taking the empty cells walled by the fingers and palm; the Zippo stands upright in it, the lid over the fist.
Hand space: md3 +x forward (the knuckles), +z up (the back of the hand), +y the thumb side. Units ~cm.

Writes models/rsqtr/rtcig_h.md3 (Ermac's cigarette, 1 frame), rtzip_h.md3 (his Zippo, its 9 frames) and rtzipfl_h.md3
(its flame, 5 frames)."""
import argparse, math, os, struct, zipfile, io

HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
M = os.path.join(ROOT, 'models', 'rsqtr')

CIG_LEN = 8.4        # cm, a cigarette
FILTER_IN = 1.4      # cm of the filter end behind the pinch
CIG_DIR = (1.0, 0.45, 0.25)   # forward, out to the thumb side, a little up: away from the fingers
ZIP_H = 5.6          # cm, a Zippo's body
ZIP_FLOOR = 2.0      # its bottom, hand z: the lid and a third of the body stand over the fist (its top ~5.3)


def read_md3(data):
    ident, ver, name, flags, nfr, ntag, nsurf, nskin, ofr, otag, osurf, oend = struct.unpack_from('<4si64siiiiiiiii', data, 0)
    surfs = []; o = osurf
    for _ in range(nsurf):
        sid, sname, sflags, snfr, nsh, nv, ntri, otri, osh, ost, oxyz, send = struct.unpack_from('<4s64siiiiiiiiii', data, o)
        tris = [struct.unpack_from('<3i', data, o + otri + 12 * i) for i in range(ntri)]
        shaders = [struct.unpack_from('<64si', data, o + osh + 68 * i)[0] for i in range(nsh)]
        uvs = [struct.unpack_from('<2f', data, o + ost + 8 * i) for i in range(nv)]
        frames = []
        for f in range(snfr):
            vs = []
            for i in range(nv):
                x, y, z, n = struct.unpack_from('<3hH', data, o + oxyz + (f * nv + i) * 8)
                vs.append(((x / 64.0, y / 64.0, z / 64.0), n))
            frames.append(vs)
        surfs.append(dict(name=sname, shaders=shaders, tris=tris, uvs=uvs, frames=frames))
        o += send
    return surfs, nfr


def dec_n(n):
    lat = (n & 255) * 2 * math.pi / 255; lng = ((n >> 8) & 255) * 2 * math.pi / 255
    return (math.cos(lat) * math.sin(lng), math.sin(lat) * math.sin(lng), math.cos(lng))


def enc_n(v):
    x, y, z = v
    if x == 0 and y == 0: return 0 if z > 0 else (128 << 8)
    lat = int(math.atan2(y, x) * 255 / (2 * math.pi)) & 255
    lng = int(math.acos(max(-1, min(1, z))) * 255 / (2 * math.pi)) & 255
    return (lng << 8) | lat


def write_md3(path, surfs, nfr):
    blobs = []
    for s in surfs:
        nv, nt = len(s['uvs']), len(s['tris'])
        o_sh = 108; o_tri = o_sh + 68 * len(s['shaders']); o_st = o_tri + nt * 12; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8 * nfr
        b = struct.pack('<4s64siiiiiiiiii', b'IDP3', s['name'], 0, nfr, len(s['shaders']), nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += b''.join(sh + struct.pack('<i', 0) for sh in s['shaders'])
        b += b''.join(struct.pack('<3i', *t) for t in s['tris'])
        b += b''.join(struct.pack('<2f', *uv) for uv in s['uvs'])
        for f in range(nfr):
            for (x, y, z), n in s['frames'][f]:
                b += struct.pack('<3hH', *(max(-32768, min(32767, round(c * 64))) for c in (x, y, z)), n)
        blobs.append(b)
    frames = b''
    for f in range(nfr):
        pts = [p for s in surfs for p, _ in s['frames'][f]]
        lo = [min(p[k] for p in pts) for k in range(3)]; hi = [max(p[k] for p in pts) for k in range(3)]
        rad = max(math.sqrt(sum(c * c for c in p)) for p in pts)
        frames += struct.pack('<3f3f3ff16s', *lo, *hi, 0, 0, 0, rad, ('frame%d' % f).encode().ljust(16, b'\0'))
    o_fr = 108; o_surf = o_fr + len(frames); o_eof = o_surf + sum(len(b) for b in blobs)
    hdr = struct.pack('<4si64siiiiiiiii', b'IDP3', 15, os.path.basename(path).encode().ljust(64, b'\0'), 0, nfr, 0, len(surfs), 0, o_fr, o_surf, o_surf, o_eof)
    open(path, 'wb').write(hdr + frames + b''.join(blobs))


def mat_mul(a, b): return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def apply(m, v): return tuple(sum(m[i][k] * v[k] for k in range(3)) for i in range(3))
def rot_y(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg)); return [[c, 0, s], [0, 1, 0], [-s, 0, c]]
def unit(v): l = math.sqrt(sum(c * c for c in v)); return tuple(c / l for c in v)
def cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def basis_x_to(d):
    """A rotation taking +x to d, keeping +z as near up as it can."""
    x = unit(d); y = unit(cross((0, 0, 1), x)); z = cross(x, y)
    return [[x[0], y[0], z[0]], [x[1], y[1], z[1]], [x[2], y[2], z[2]]]


def transform(surfs, m, scale, t):
    for s in surfs:
        for f in s['frames']:
            for i, (p, n) in enumerate(f):
                q = apply(m, tuple(c * scale for c in p))
                f[i] = ((q[0] + t[0], q[1] + t[1], q[2] + t[2]), enc_n(apply(m, dec_n(n))))


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--bd', required=True); a = ap.parse_args()
    z = zipfile.ZipFile(a.bd)
    hand, _ = read_md3(z.read('models/rsq/fbx/fbx_oh_free_R.md3'))
    ring, _ = read_md3(z.read('models/rsq/fbx/rsq_ring_oh.md3'))

    # THE PINCH: the densest 1 cm cell of the ring's vertices (its clip, held between the pads)
    rv = [p for s in ring for p, _ in s['frames'][0]]
    cells = {}
    for p in rv: cells.setdefault(tuple(math.floor(c) for c in p), []).append(p)
    knot = max(cells.values(), key=len)
    pinch = tuple(sum(p[k] for p in knot) / len(knot) for k in range(3))

    # THE FIST'S HOLE: frame 1 sliced at -1..3 (mid height), 1 cm cells in front of the palm (x > 1); the empty cells
    # that have hand in all four directions within 3 cm are the hole
    hv = [p for s in hand for p, _ in s['frames'][1]]
    occ = set()
    for p in hv:
        if -1 <= p[2] <= 3 and p[0] > 1: occ.add((math.floor(p[0]), math.floor(p[1])))
    hole = []
    for x in range(1, 12):
        for y in range(-5, 9):
            if (x, y) in occ: continue
            if all(any((x + dx * k, y + dy * k) in occ for k in (1, 2, 3)) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                hole.append((x + 0.5, y + 0.5))
    hx = sum(c[0] for c in hole) / len(hole); hy = sum(c[1] for c in hole) / len(hole)
    print('pinch (ring clip, %d verts): %.2f %.2f %.2f' % (len(knot), *pinch))
    print('fist hole (%d cells): x %.2f y %.2f' % (len(hole), hx, hy))

    # THE CIGARETTE: Ermac's mesh lies tipped 22 degrees (filter end -3.83,+2.1 to the burning end +5.67,-1.8 in X,Z):
    # levelled, scaled to CIG_LEN, turned along CIG_DIR, its filter end FILTER_IN behind the pinch
    cig, n = read_md3(open(os.path.join(M, 'rtcig.md3'), 'rb').read())
    lev = rot_y(-math.degrees(math.atan2(2.1 + 1.8, 5.67 + 3.83)))   # +x the burning end
    pts = [apply(lev, p) for s in cig for p, _ in s['frames'][0]]
    x0, x1 = min(p[0] for p in pts), max(p[0] for p in pts)
    sc = CIG_LEN / (x1 - x0)
    d = unit(CIG_DIR)
    R = mat_mul(basis_x_to(d), lev)
    # the filter end at pinch - d * FILTER_IN: after R and scale the filter end is at R(x0 along the levelled axis)
    f_end = apply(basis_x_to(d), (x0 * sc, 0, 0))
    t = tuple(pinch[k] - d[k] * FILTER_IN - f_end[k] for k in range(3))
    transform(cig, R, sc, t)
    write_md3(os.path.join(M, 'rtcig_h.md3'), cig, n)
    tip = tuple(pinch[k] + d[k] * (CIG_LEN - FILTER_IN) for k in range(3))
    print('cigarette: filter %.2f %.2f %.2f -> tip %.2f %.2f %.2f (scale %.3f)' % (*[pinch[k] - d[k] * FILTER_IN for k in range(3)], *tip, sc))

    # THE ZIPPO: upright in the hole, its body ZIP_H tall from ZIP_FLOOR; the body's width (mesh y) along the knuckles
    # (hand x), its thin side across the hole; the flame (rtzipfl) moves with it
    zb, nz = read_md3(open(os.path.join(M, 'rtzippo.md3'), 'rb').read())
    zf, nzf = read_md3(open(os.path.join(M, 'rtzipfl.md3'), 'rb').read())
    body = [p for s in zb if s['name'].startswith(b'zippo_v\0') for p, _ in s['frames'][0]]
    bz0, bz1 = min(p[2] for p in body), max(p[2] for p in body)
    zsc = ZIP_H / (bz1 - bz0)
    Rz = [[0, 1, 0], [-1, 0, 0], [0, 0, 1]]      # mesh +y -> hand +x, mesh +x -> hand -y
    tz = (hx, hy, ZIP_FLOOR - bz0 * zsc)
    transform(zb, Rz, zsc, tz); transform(zf, Rz, zsc, tz)
    write_md3(os.path.join(M, 'rtzip_h.md3'), zb, nz)
    write_md3(os.path.join(M, 'rtzipfl_h.md3'), zf, nzf)
    fl = [p for s in zf for p, _ in s['frames'][1]]
    print('zippo: scale %.3f, body z %.2f..%.2f, flame z %.2f..%.2f' % (zsc, ZIP_FLOOR, ZIP_FLOOR + ZIP_H, min(p[2] for p in fl), max(p[2] for p in fl)))


if __name__ == '__main__':
    main()
