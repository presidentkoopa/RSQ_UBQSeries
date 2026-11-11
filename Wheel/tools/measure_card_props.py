#!/usr/bin/env python3
"""measure_card_props.py -- the Wheel's 3D model cards for the series' own hand weapons (owner 11-11: "the wheel shows
no 3d models for saber, shield, whip, or fist").

A card stands a prop in front of itself and turns it about the vertical (zscript.zs spawnCardModels / the draw loop).
A gun's pickup is a voxel the Wheel measures in game (wr_q_vox.zs). The saber, the shield, the whip and the fist are
MD3 meshes, which ZScript cannot read, so they are measured here, from each pack's own MODELDEF block and mesh, and the
numbers are copied into zscript.zs (wr_CardProp). Run from the repo root:  python3 Wheel/tools/measure_card_props.py

Per prop: the MODELDEF block the engine draws it with (class, sprite, frame), its Scale and Offset, and the MD3 frame.
Where a mesh point lands at actor scale 1, as the engine's world path puts it (src/r_data/models.cpp
RenderFrameModels: scale(actor * MODELDEF scale), then translate(Offset / MODELDEF scale), so the Offset is not scaled
by the MODELDEF scale): p * Scale + Offset, in the actor's axes (x forward, y left, z up; the same axes TacticalRig's
measure_pickups.py and RSQ Saber's hip saber use). THE PIXEL STRETCH: the same function squashes an MD3's own height by
1 / level.pixelstretch (an MD3's getAspectFactor is 1) but not the Offset, with or without CORRECTPIXELSTRETCH (with it,
the stretch is applied after the turn and the z Offset is divided by it first: at pitch 0 the same result). So the
height and the mesh's part of the centre's z are printed unstretched, and the Offset's z apart; the game divides the
first two by level.pixelstretch at run time.

Printed: width across (the longer of the x and y extents: the prop turns), height, and the middle of the bounds;
the zscript line is wr_CardProp's row: across, height, centre x, centre y, the mesh's centre z, the Offset's z.
"""
import os, re, struct, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

# name, pack dir, MODELDEF file, class, sprite, frame letter, why this block
PROPS = [
    ('saber', 'QuestSaber', 'MODELDEF.hip', 'UBQS_HipSaber', 'UBSP', 'N',
     "the saber at the hip: UBQS_Saber's own pickup block, frame N (the Rig's wear frame), blades in"),
    ('shield', 'ShieldSaw', 'MODELDEF.txt', 'SSQ_Prop', 'SSQP', 'A',
     'the shield as a world actor (back and others\' view), closed'),
    ('whip', 'Whip', 'MODELDEF.txt', 'RSQWP_Stowed', 'RSWP', 'A',
     'the coiled whip of the whip holster'),
    ('fbxfist', 'Melee', 'MODELDEF.txt', 'RSQ_Glove', 'RMHF', 'A',
     "RSQ Melee's FBX hand, its fist frame (BD22 VR's FBX free hand)"),
    ('glove', 'Melee', 'MODELDEF.txt', 'RSQ_Glove', 'RMHG', 'A',
     "RSQ Melee's boxing glove"),
]


def strip(t):
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    return re.sub(r'//[^\n]*', '', t)


def blocks(text):
    tk = re.findall(r'"[^"]*"|\{|\}|[^\s{}]+', strip(text))
    i = 0
    while i < len(tk):
        if tk[i].lower() == 'model' and i + 2 < len(tk) and tk[i + 2] == '{':
            cls = tk[i + 1].strip('"')
            j = i + 3
            body = []
            while j < len(tk) and tk[j] != '}':
                body.append(tk[j].strip('"')); j += 1
            yield cls, body
            i = j + 1
        else:
            i += 1


def settings(body):
    s = {'path': '', 'models': {}, 'scale': (1.0, 1.0, 1.0), 'offset': [0.0, 0.0, 0.0], 'frames': [], 'cps': False}
    i = 0
    while i < len(body):
        k = body[i].lower()
        if k == 'path': s['path'] = body[i + 1]; i += 2
        elif k == 'model': s['models'][int(body[i + 1])] = body[i + 2]; i += 3
        elif k == 'scale': s['scale'] = tuple(float(x) for x in body[i + 1:i + 4]); i += 4
        elif k == 'offset': s['offset'] = [float(x) for x in body[i + 1:i + 4]]; i += 4
        elif k == 'zoffset': s['offset'][2] = float(body[i + 1]); i += 2
        elif k in ('frameindex', 'frame'):
            s['frames'].append((body[i + 1].upper(), body[i + 2].upper(), int(body[i + 3]), int(body[i + 4]))); i += 5
        elif k == 'correctpixelstretch': s['cps'] = True; i += 1
        else: i += 1
    return s


def md3_points(data, frame):
    ident, ver, name, flags, nfr, ntags, nsurf, nskins, ofr, otag, osurf, oend = struct.unpack_from('<4si64s9i', data, 0)
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


def main():
    for name, pack, mdef, cls, spr, fr, why in PROPS:
        text = open(os.path.join(ROOT, pack, mdef), encoding='latin-1').read()
        found = None
        for c, body in blocks(text):
            if c.lower() != cls.lower(): continue
            s = settings(body)
            parts = {mi: mf for (sp, f, mi, mf) in s['frames'] if sp == spr and f == fr}
            if parts: found = (s, parts)          # the engine uses the last block naming it
        if not found:
            print('%s: no block for %s %s %s in %s/%s' % (name, cls, spr, fr, pack, mdef)); continue
        s, parts = found
        pts = []
        files = []
        for mi, mf in sorted(parts.items()):
            fname = s['models'][mi]
            path = os.path.join(ROOT, pack, s['path'], fname)
            raw = md3_points(open(path, 'rb').read(), mf)
            sx, sy, sz = s['scale']
            ox, oy, oz = s['offset']
            pts += [(p[0] * sx + ox, p[1] * sy + oy, p[2] * sz) for p in raw]   # z: the mesh's part only
            files.append('%s frame %d' % (fname, mf))
        lo = [min(p[i] for p in pts) for i in range(3)]
        hi = [max(p[i] for p in pts) for i in range(3)]
        ext = [hi[i] - lo[i] for i in range(3)]
        ctr = [(hi[i] + lo[i]) / 2 for i in range(3)]
        print('%-8s %s %s %s  (%s; %s)' % (name, cls, spr, fr, ', '.join(files), why))
        print('         scale %s offset %s%s' % (s['scale'], tuple(s['offset']), ' CORRECTPIXELSTRETCH' if s['cps'] else ''))
        print('         extents x %.2f y %.2f z %.2f  -> across %.2f, height %.2f' % (ext[0], ext[1], ext[2], max(ext[0], ext[1]), ext[2]))
        print('         centre x %.2f y %.2f, z: mesh %.2f + Offset %.2f' % (ctr[0], ctr[1], ctr[2], s['offset'][2]))
        print('         zscript: %.2f, %.2f, %.2f, %.2f, %.2f, %.2f' % (max(ext[0], ext[1]), ext[2], ctr[0], ctr[1], ctr[2], s['offset'][2]))


if __name__ == '__main__':
    main()
