#!/usr/bin/env python3
"""Writes models/rsqtr/rtwoct.obj: the ITEM SPOT marker (owner 2026-11-08, "not colour alone"), a wire DIAMOND -- the
twelve edges of an octahedron with its six corners at radius 1.0 on the model's axes -- drawn with the same convention
as the gun holsters' wire sphere models/rsqtr/rtwire.obj: radius 1.0 (the actor's scale is the spot's radius in map
units), each wire a square tube 0.09 across (rtwire's rings run 0.955..1.045 and -0.045..0.045), triangles only (each
written in both windings), no UVs or normals, one group "wire", so the same flat 8x8 skins (rtwire*.png, rtwcb*.png) colour it.

    python3 tools/gen_octawire.py            # from TacticalRig/
"""
import os

HALF = 0.045          # half the wire's thickness, as rtwire.obj
CORNERS = [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]


def sub(a, b): return tuple(x - y for x, y in zip(a, b))
def add(a, b): return tuple(x + y for x, y in zip(a, b))
def mul(a, k): return tuple(x * k for x in a)
def dot(a, b): return sum(x * y for x, y in zip(a, b))
def cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])
def unit(a):
    l = dot(a, a) ** 0.5
    return mul(a, 1.0 / l)


def edges():
    out = []
    for i in range(6):
        for j in range(i + 1, 6):
            if dot(CORNERS[i], CORNERS[j]) == 0:      # not opposite corners: an edge
                out.append((CORNERS[i], CORNERS[j]))
    assert len(out) == 12
    return out


def main():
    verts, faces = [], []
    for a, b in edges():
        d = unit(sub(b, a))
        # the tube's two side directions: one toward the octahedron's outside (the edge's midpoint direction), one across
        m = unit(add(a, b))
        s = unit(cross(d, m))
        # run the tube HALF past each corner so neighbouring wires close the corner
        a2, b2 = sub(a, mul(d, HALF)), add(b, mul(d, HALF))
        ring = [add(mul(m, HALF), mul(s, HALF)), add(mul(m, HALF), mul(s, -HALF)),
                add(mul(m, -HALF), mul(s, -HALF)), add(mul(m, -HALF), mul(s, HALF))]
        base = len(verts) + 1
        for c in ring: verts.append(add(a2, c))
        for c in ring: verts.append(add(b2, c))
        for k in range(4):
            k2 = (k + 1) % 4
            p0, p1, q0, q1 = base + k, base + k2, base + 4 + k, base + 4 + k2
            faces.append((p0, q0, q1)); faces.append((p0, q1, p1))
        faces.append((base, base + 1, base + 2)); faces.append((base, base + 2, base + 3))
        faces.append((base + 4, base + 6, base + 5)); faces.append((base + 4, base + 7, base + 6))
    here = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(here, '..', 'models', 'rsqtr', 'rtwoct.obj')
    with open(path, 'w') as f:
        f.write('# wire diamond: the 12 edges of an octahedron, corners at radius 1.0 (tools/gen_octawire.py)\n')
        for v in verts: f.write('v %s\n' % ' '.join(('%.5f' % x).rstrip('0').rstrip('.') if x else '0' for x in v))
        f.write('g wire\n')
        # both windings: the engine culls back faces, and a wire this thin is seen from every side
        for t in faces: f.write('f %d %d %d\nf %d %d %d\n' % (t + (t[0], t[2], t[1])))
    print('%s: %d vertices, %d triangles' % (os.path.normpath(path), len(verts), 2 * len(faces)))


if __name__ == '__main__':
    main()
