#!/usr/bin/env python3
"""Writes models/rsqtr/rtarc01.obj .. rtarc12.obj: THE AMMO ARC (Report rec 7, "not colour alone"; rig.zs DrawMarkers,
RSQTR_AmmoArc), a thin wire arc round a full holster's ammo light whose length shows how full the gun is: step k of 12
is k/12 of a circle, step 12 the closed circle (step 0 draws nothing, so it has no file).

Same convention as the gun holsters' wire sphere models/rsqtr/rtwire.obj: radius 1.0 (the actor's scale is the arc's
radius in map units), the wire a square tube 0.09 across (rtwire's rings run 0.955..1.045 and -0.045..0.045), triangles
only (each written in both windings), no UVs or normals, one group "wire", so the same flat 8x8 skins (rtwireht.png,
rtwireye.png: the pip's own) colour it.

It stands in the model's side-up plane facing the model's forward, as models/rsqtr/rtquad.obj (tools/gen_rule_quad.py),
so the actor's angle, pitch and roll turn it to the eyes the way the rule picture is turned. OBJ as GZDoom draws it: x
forward (the face), y up, z sideways, -z to the right seen from the front (rtquad's UVs, rig frames 11-08). The arc
starts at the top (+y) and runs clockwise as seen from the front, as a clock's hand.

    python3 tools/gen_ammoarc.py             # from TacticalRig/
"""
import math
import os

HALF = 0.045          # half the wire's thickness, as rtwire.obj
STEPS = 12
SEG_PER_STEP = 4      # 48 segments make the full circle (rtwire's rings: 24 segments each)


def point(theta, r, x):
    # clockwise from the top, seen from the front (+x): top +y, right -z
    return (x, r * math.cos(theta), -r * math.sin(theta))


def arc(step):
    segs = step * SEG_PER_STEP
    full = step == STEPS
    end = 2 * math.pi * step / STEPS
    n = segs if full else segs + 1                      # cross-sections along the arc
    verts, faces = [], []
    for i in range(n):
        th = end * i / segs
        # the square tube's four corners: inner/outer radius by back/front
        verts += [point(th, 1 - HALF, -HALF), point(th, 1 + HALF, -HALF), point(th, 1 + HALF, HALF), point(th, 1 - HALF, HALF)]
    for i in range(segs):
        a = 4 * i + 1
        b = 4 * ((i + 1) % n) + 1
        for k in range(4):
            k2 = (k + 1) % 4
            faces.append((a + k, b + k, b + k2))
            faces.append((a + k, b + k2, a + k2))
    if not full:                                        # cap both ends
        faces.append((1, 2, 3)); faces.append((1, 3, 4))
        e = 4 * (n - 1) + 1
        faces.append((e, e + 2, e + 1)); faces.append((e, e + 3, e + 2))
    return verts, faces


def fmt(x):
    if abs(x) < 5e-6:
        return '0'
    return ('%.5f' % x).rstrip('0').rstrip('.')


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    for step in range(1, STEPS + 1):
        verts, faces = arc(step)
        path = os.path.normpath(os.path.join(here, '..', 'models', 'rsqtr', 'rtarc%02d.obj' % step))
        with open(path, 'w') as f:
            f.write('# ammo arc, step %d of %d (%d/%d of a circle), radius 1.0, from the top clockwise seen from +x (tools/gen_ammoarc.py)\n'
                    % (step, STEPS, step, STEPS))
            for v in verts:
                f.write('v %s\n' % ' '.join(fmt(c) for c in v))
            f.write('g wire\n')
            # both windings: the engine culls back faces, and a wire this thin is seen from every side
            for t in faces:
                f.write('f %d %d %d\nf %d %d %d\n' % (t + (t[0], t[2], t[1])))
        print('%s: %d vertices, %d triangles' % (path, len(verts), 2 * len(faces)))


if __name__ == '__main__':
    main()
