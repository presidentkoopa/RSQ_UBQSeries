#!/usr/bin/env python3
"""THE WHIP, COILED, FOR RSQ TACTICAL RIG'S WHIP HOLSTER (owner 2026-11-03 20:14: "draw the holstered whip on the body as
its model when stored"). Procedural, deterministic, no Blender.

    python3 tools/gen_whipcoil.py

Writes models/rsqwp/rsqwp_coil.md3: two surfaces, 0 "thong" (the whip's plaited skin rsqwhip.png) and 1 "handle" (its
wrapped handle rsqwhiph.png), one frame. In MAP UNITS at scale 1, drawn with CORRECTPIXELSTRETCH (as the whip's own
pieces), so it is the size of the whip in your hand:
  the handle   HANDLEN 8 map units long, radius 0.69 x 1.7 = 1.17 (whip.zs HANDLEN; Draw: the handle's width)
  the thong    radius 0.69 x 1.15 = 0.79 at the handle (Draw: rsqwp_rope_width 0.6 x 1.15), tapering to 0.18 of that at
               the tip, as Draw tapers it, coiled LOOPS times round a loop of LOOP_R map units (12 cm: a 24 cm coil; the
               lasso's loop is 15 cm, whip.zs COIL_R), the loops side by side across the coil, the fall and its tip
               hanging TAIL below the coil
Axes (an actor's model space: X forward, Y left, Z up): the coil lies in the X-Z plane, centred on the origin, so with
the actor turned to the body's heading it lies flat against the hip, facing out. The handle runs down the back of the
coil (-X), its butt at the bottom. Both windings are written (no culling convention can hide it).
"""
import os, math, struct

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
OUT = os.path.join(ROOT, 'models', 'rsqwp', 'rsqwp_coil.md3')

HANDLEN = 8.0
HANDLE_R = 0.69 * 1.7
THONG_R0 = 0.69 * 1.15
THONG_TIP = 0.18
LOOPS = 3
LOOP_R = 4.1
LOOP_SPREAD = 2.4          # map units the loops spread across the coil (Y), side by side
TAIL = 3.0
SIDES = 6
V_REPEAT = 4.0             # map units of thong per repeat of its skin


def sub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def add(a, b): return (a[0] + b[0], a[1] + b[1], a[2] + b[2])
def mul(a, s): return (a[0] * s, a[1] * s, a[2] * s)
def dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
def cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])
def norm(a):
    l = math.sqrt(dot(a, a)) or 1.0
    return (a[0] / l, a[1] / l, a[2] / l)


def tube(path, radii, v_per_unit=None, v_total=None):
    """A tube along `path` (points), radius per point; frames by parallel transport. UV: U round, V along."""
    verts, norms, uvs, tris = [], [], [], []
    n = len(path)
    t0 = norm(sub(path[1], path[0]))
    ref = (0, 1, 0) if abs(t0[1]) < 0.9 else (1, 0, 0)
    nrm = norm(cross(t0, ref))
    s = 0.0
    total = sum(math.dist(path[i], path[i + 1]) for i in range(n - 1))
    for i in range(n):
        t = norm(sub(path[min(i + 1, n - 1)], path[max(i - 1, 0)]))
        nrm = norm(sub(nrm, mul(t, dot(nrm, t))))          # parallel transport
        bi = cross(t, nrm)
        if i: s += math.dist(path[i - 1], path[i])
        v = s / v_per_unit if v_per_unit else s / total * (v_total or 1.0)
        for k in range(SIDES + 1):
            a = 2 * math.pi * k / SIDES
            d = add(mul(nrm, math.cos(a)), mul(bi, math.sin(a)))
            verts.append(add(path[i], mul(d, radii[i])))
            norms.append(d)
            uvs.append((k / SIDES, v))
    m = SIDES + 1
    for i in range(n - 1):
        for k in range(SIDES):
            a, b, c, d = i * m + k, i * m + k + 1, (i + 1) * m + k + 1, (i + 1) * m + k
            tris += [(a, c, b), (a, d, c), (a, b, c), (a, c, d)]
    # caps (flat fans), both windings
    for i, sgn in ((0, -1), (n - 1, 1)):
        c = len(verts)
        verts.append(path[i]); norms.append(mul(norm(sub(path[min(i + 1, n - 1)], path[max(i - 1, 0)])), sgn)); uvs.append((0.5, uvs[i * m][1]))
        for k in range(SIDES):
            a, b = i * m + k, i * m + k + 1
            tris += [(c, a, b), (c, b, a)]
    return verts, norms, uvs, tris


def thong_path():
    # from the handle's top, round LOOPS loops, then the fall hanging down
    top = (-1.0, LOOP_SPREAD / 2 + 0.6, LOOP_R)
    pts = [top]
    steps = 36 * LOOPS
    for j in range(steps + 1):
        f = j / steps
        th = 2 * math.pi * LOOPS * f
        r = LOOP_R * (1.03 - 0.06 * f)
        y = LOOP_SPREAD / 2 - LOOP_SPREAD * f
        pts.append((r * math.sin(th), y, r * math.cos(th)))
    # the fall: off the last loop's top, down the front of the coil and past its bottom
    end = pts[-1]
    for j in range(1, 9):
        f = j / 8
        pts.append((end[0] + 1.6 * math.sin(f * math.pi / 2) + 0.3 * f, end[1] - 0.4 * f, end[2] - f * (2 * LOOP_R + TAIL)))
    n = len(pts)
    radii = [THONG_R0 * (1.0 - (1.0 - THONG_TIP) * (i / (n - 1)) ** 0.8) for i in range(n)]
    return pts, radii


def handle_path():
    a = (-1.0, LOOP_SPREAD / 2 + 0.6, LOOP_R)
    d = norm((-0.25, 0.0, -1.0))
    pts = [add(a, mul(d, HANDLEN * k / 6)) for k in range(7)]
    radii = [HANDLE_R * (1.15 if k == 6 else 1.0) for k in range(7)]     # a small knob at the butt
    return pts, radii


def enc_normal(n):
    l = math.sqrt(sum(c * c for c in n)) or 1.0
    n = [c / l for c in n]
    lat = int(round(math.degrees(math.acos(max(-1, min(1, n[2])))) * 255 / 360)) & 255
    lng = int(round(math.degrees(math.atan2(n[1], n[0])) * 255 / 360)) & 255
    return (lat << 8) | lng


def pad(s, n):
    b = s.encode('ascii')[:n - 1]
    return b + b'\0' * (n - len(b))


def surface(name, skin, verts, norms, uvs, tris):
    nv, nt = len(verts), len(tris)
    hdr = 4 + 64 + 4 * 10
    o_sh = hdr; o_tr = o_sh + 68; o_st = o_tr + nt * 12; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8
    b = bytearray(b'IDP3' + pad(name, 64))
    b += struct.pack('<10i', 0, 1, 1, nv, nt, o_tr, o_sh, o_st, o_xyz, o_end)
    b += pad(skin, 64) + struct.pack('<i', 0)
    for t in tris: b += struct.pack('<3i', *t)
    for u, v in uvs: b += struct.pack('<2f', u, v)
    for p, nn in zip(verts, norms):
        b += struct.pack('<3hH', *[int(round(c * 64)) for c in p], enc_normal(nn))
    return bytes(b)


def write_md3(path, surfs):
    allv = [p for s in surfs for p in s[2]]
    mn = [min(p[i] for p in allv) for i in range(3)]; mx = [max(p[i] for p in allv) for i in range(3)]
    rad = max(math.sqrt(dot(p, p)) for p in allv)
    blobs = [surface(*s) for s in surfs]
    hdr = 108; frame = 56
    o_fr = hdr; o_tag = o_fr + frame; o_su = o_tag; o_end = o_su + sum(len(b) for b in blobs)
    out = bytearray(b'IDP3' + struct.pack('<i', 15) + pad('rsqwp_coil', 64))
    out += struct.pack('<9i', 0, 1, 0, len(blobs), 0, o_fr, o_tag, o_su, o_end)
    out += struct.pack('<3f', *mn) + struct.pack('<3f', *mx) + struct.pack('<3f', 0, 0, 0) + struct.pack('<f', rad) + pad('coil', 16)
    for b in blobs: out += b
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f: f.write(out)
    return mn, mx


if __name__ == '__main__':
    tp, tr = thong_path()
    hp, hr = handle_path()
    thong = tube(tp, tr, v_per_unit=V_REPEAT)
    handle = tube(hp, hr, v_total=1.0)
    mn, mx = write_md3(OUT, [('thong', 'rsqwhip.png', *thong), ('handle', 'rsqwhiph.png', *handle)])
    print('wrote %s: bounds %s .. %s map units (%.1f x %.1f x %.1f cm at 34 a metre), thong %.0f units long'
          % (OUT, [round(c, 2) for c in mn], [round(c, 2) for c in mx], (mx[0] - mn[0]) / 0.34, (mx[1] - mn[1]) / 0.34, (mx[2] - mn[2]) / 0.34,
             sum(math.dist(tp[i], tp[i + 1]) for i in range(len(tp) - 1))))
