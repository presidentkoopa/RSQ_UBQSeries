#!/usr/bin/env python3
"""md3_bounds.py <file.md3> <frame> <sx> <sy> <sz> <ox> <oy> <oz> [...more groups of 8] -- tool only; never ships.
The box a MODELDEF block draws: each vertex of that frame (MD3 units, /64) times the block's Scale, plus its Offset,
per axis as GZDoom applies them (Offset is in world units, after Scale). Prints min, max, size and centre.
Used for RSQ Melee's boxing glove (owner 11-10: "Shrink to hand size"): the glove's box against the hands' fist box."""
import struct, sys


def frame_verts(path, frame):
    d = open(path, 'rb').read()
    ident, ver, name, flags, nf, nt, ns, nsk, ofr, ota, osu, oend = struct.unpack('<4si64siiiiiiiii', d[:108])
    assert ident == b'IDP3', 'not an MD3'
    assert 0 <= frame < nf, f'{path} has {nf} frames'
    out = []
    o = osu
    for _ in range(ns):
        _, sname, sflags, snf, nsh, nv, ntri, otri, osh, ost, oxyz, oe = struct.unpack('<4s64siiiiiiiiii', d[o:o + 108])
        base = o + oxyz + frame * nv * 8
        for i in range(nv):
            x, y, z, _n = struct.unpack('<hhhH', d[base + i * 8: base + i * 8 + 8])
            out.append((x / 64.0, y / 64.0, z / 64.0))
        o += oe
    return out


def main(a):
    while a:
        path, frame = a[0], int(a[1])
        s = [float(v) for v in a[2:5]]
        off = [float(v) for v in a[5:8]]
        a = a[8:]
        vs = [tuple(v[k] * s[k] + off[k] for k in range(3)) for v in frame_verts(path, frame)]
        lo = [min(v[k] for v in vs) for k in range(3)]
        hi = [max(v[k] for v in vs) for k in range(3)]
        f = lambda t: ' '.join(f'{x:7.2f}' for x in t)
        print(f'{path} frame {frame} scale {f(s)} offset {f(off)}')
        print(f'  min  {f(lo)}\n  max  {f(hi)}\n  size {f([hi[k] - lo[k] for k in range(3)])}'
              f'\n  centre {f([(hi[k] + lo[k]) / 2 for k in range(3)])}')


if __name__ == '__main__':
    main(sys.argv[1:])
