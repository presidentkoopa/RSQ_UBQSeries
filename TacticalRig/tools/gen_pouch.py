#!/usr/bin/env python3
"""THE AMMO POUCH ON THE BELT (owner 2026-11-03 20:46, "Build now"): a small belt pouch for RSQ Tactical Rig's pouch place.
Procedural, deterministic, no Blender.

    python3 tools/gen_pouch.py

Writes models/rsqtr/rtpouch.md3 (one surface "pouch", one frame) and models/rsqtr/rtpouch.png (its skin, 64 x 64: olive
canvas, a darker flap, a stitched seam, a press-stud). MAP UNITS at scale 1, 34 a metre: a magazine pouch 7 cm wide (Y),
4 cm deep (X, out from the belt), 10 cm tall (Z), its flap folded over the top and 3 cm down the front; centred on the
origin. Model axes: X out from the belt (the actor faces the body's heading), Y left, Z up. Both windings are written.
"""
import os, math, struct, zlib, random

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
U = 34.0
W, D, H, FLAP = 0.07 * U, 0.04 * U, 0.10 * U, 0.03 * U


def box(x0, x1, y0, y1, z0, z1, uv):
    """six quads of an axis box; uv = (u0, v0, u1, v1) on the skin for every face"""
    P = [(x, y, z) for x in (x0, x1) for y in (y0, y1) for z in (z0, z1)]
    def idx(x, y, z): return P.index((x, y, z))
    faces = [  # (corners in order, normal)
        ([(x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)], (1, 0, 0)),
        ([(x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1)], (-1, 0, 0)),
        ([(x0, y1, z0), (x1, y1, z0), (x1, y1, z1), (x0, y1, z1)], (0, 1, 0)),
        ([(x1, y0, z0), (x0, y0, z0), (x0, y0, z1), (x1, y0, z1)], (0, -1, 0)),
        ([(x0, y0, z1), (x0, y1, z1), (x1, y1, z1), (x1, y0, z1)], (0, 0, 1)),
        ([(x0, y1, z0), (x0, y0, z0), (x1, y0, z0), (x1, y1, z0)], (0, 0, -1)),
    ]
    verts, norms, uvs, tris = [], [], [], []
    u0, v0, u1, v1 = uv
    for corners, n in faces:
        b = len(verts)
        for k, c in enumerate(corners):
            verts.append(c); norms.append(n)
            uvs.append(((u0, u1, u1, u0)[k], (v1, v1, v0, v0)[k]))
        tris += [(b, b + 1, b + 2), (b, b + 2, b + 3), (b, b + 2, b + 1), (b, b + 3, b + 2)]
    return verts, norms, uvs, tris


def merge(parts):
    V, N, T, R = [], [], [], []
    for v, n, t, r in parts:
        o = len(V); V += v; N += n; T += t; R += [(a + o, b + o, c + o) for a, b, c in r]
    return V, N, T, R


def enc_normal(n):
    l = math.sqrt(sum(c * c for c in n)) or 1.0
    n = [c / l for c in n]
    lat = int(round(math.degrees(math.acos(max(-1, min(1, n[2])))) * 255 / 360)) & 255
    lng = int(round(math.degrees(math.atan2(n[1], n[0])) * 255 / 360)) & 255
    return (lat << 8) | lng


def pad(s, n):
    b = s.encode('ascii')[:n - 1]
    return b + b'\0' * (n - len(b))


def write_md3(path, verts, norms, uvs, tris, skin):
    nv, nt = len(verts), len(tris)
    hdr = 108; o_sh = hdr; o_tr = o_sh + 68; o_st = o_tr + nt * 12; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8
    surf = bytearray(b'IDP3' + pad('pouch', 64))
    surf += struct.pack('<10i', 0, 1, 1, nv, nt, o_tr, o_sh, o_st, o_xyz, o_end)
    surf += pad(skin, 64) + struct.pack('<i', 0)
    for t in tris: surf += struct.pack('<3i', *t)
    for u, v in uvs: surf += struct.pack('<2f', u, v)
    for p, n in zip(verts, norms): surf += struct.pack('<3hH', *[int(round(c * 64)) for c in p], enc_normal(n))
    mn = [min(p[i] for p in verts) for i in range(3)]; mx = [max(p[i] for p in verts) for i in range(3)]
    rad = max(math.sqrt(sum(c * c for c in p)) for p in verts)
    o_fr = 108; o_su = o_fr + 56
    out = bytearray(b'IDP3' + struct.pack('<i', 15) + pad('rtpouch', 64))
    out += struct.pack('<9i', 0, 1, 0, 1, 0, o_fr, o_su, o_su, o_su + len(surf))
    out += struct.pack('<3f', *mn) + struct.pack('<3f', *mx) + struct.pack('<3f', 0, 0, 0) + struct.pack('<f', rad) + pad('pouch', 16)
    out += surf
    with open(path, 'wb') as f: f.write(out)
    return mn, mx


def png(path, w, h, px):
    raw = b''.join(b'\0' + bytes(c for p in px[y * w:(y + 1) * w] for c in p) for y in range(h))
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def skin():
    """left half the body (olive canvas, a weave, a seam 3 px in from the edge), right half the flap (darker, a stud)"""
    rnd = random.Random(1103)
    w = h = 64
    px = []
    for y in range(h):
        for x in range(w):
            flap = x >= 32
            base = (72, 78, 50) if not flap else (58, 63, 40)
            weave = 6 if (x + y) % 4 < 2 else -4
            n = rnd.randint(-5, 5)
            c = [max(0, min(255, b + weave + n)) for b in base]
            lx = x % 32
            if lx in (3, 28) or y in (3, 60):
                if (y if lx in (3, 28) else x) % 4 < 2: c = [min(255, b + 30) for b in c]     # stitches
            if flap and (lx - 16) ** 2 + (y - 50) ** 2 <= 9: c = [150, 140, 110] if (lx - 16) ** 2 + (y - 50) ** 2 <= 3 else [40, 40, 30]
            px.append(tuple(c))
    return w, h, px


if __name__ == '__main__':
    mdir = os.path.join(ROOT, 'models', 'rsqtr')
    body = box(-D / 2, D / 2, -W / 2, W / 2, -H / 2, H / 2 - 0.2, (0.0, 0.0, 0.5, 1.0))
    flap = merge([box(-D / 2 - 0.1, D / 2 + 0.15, -W / 2 - 0.1, W / 2 + 0.1, H / 2 - 0.2, H / 2 + 0.15, (0.5, 0.0, 1.0, 1.0)),
                  box(D / 2 + 0.05, D / 2 + 0.2, -W / 2 - 0.1, W / 2 + 0.1, H / 2 - FLAP, H / 2 + 0.15, (0.5, 0.0, 1.0, 1.0))])
    mn, mx = write_md3(os.path.join(mdir, 'rtpouch.md3'), *merge([body, flap]), 'rtpouch.png')
    png(os.path.join(mdir, 'rtpouch.png'), *skin())
    print('wrote rtpouch.md3 (%.1f x %.1f x %.1f cm) and rtpouch.png' % ((mx[0] - mn[0]) / 0.34, (mx[1] - mn[1]) / 0.34, (mx[2] - mn[2]) / 0.34))
