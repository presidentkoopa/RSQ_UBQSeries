#!/usr/bin/env python3
"""md3_frames.py <in.md3> <out.md3> <frame> [frame ...] -- copy an MD3 keeping only the listed frames, in that order
(tool only; never ships). Used for RSQ Melee's hands: Ermac's hand.md3 has 211 frames (1.7 MB); Melee draws two,
frame 1 (the fist) and frame 0 (the relaxed open hand). Geometry, UVs, triangles and shaders are copied byte for byte;
only the per-frame blocks (frame headers, tags, vertex frames) are picked."""
import struct, sys

src, dst, keep = sys.argv[1], sys.argv[2], [int(x) for x in sys.argv[3:]]
d = open(src, 'rb').read()
HDR = '<4si64siiiiiiiii'
ident, ver, name, flags, nf, nt, ns, nsk, ofr, ota, osu, oend = struct.unpack(HDR, d[:108])
assert ident == b'IDP3', 'not an MD3'
frames = [d[ofr + i * 56: ofr + (i + 1) * 56] for i in range(nf)]
tags = [d[ota + i * nt * 112: ota + (i + 1) * nt * 112] for i in range(nf)]
surfs = []
o = osu
for s in range(ns):
    sh = struct.unpack('<4s64siiiiiiiiii', d[o:o + 108])
    _, sname, sflags, snf, nsh, nv, ntri, otri, osh, ost, oxyz, oe = sh
    body = d[o:o + oe]
    xyz = [body[oxyz + i * nv * 8: oxyz + (i + 1) * nv * 8] for i in range(snf)]
    surfs.append((sh, body, xyz))
    o += oe

out_frames = b''.join(frames[i] for i in keep)
out_tags = b''.join(tags[i] for i in keep)
out_surfs = b''
for sh, body, xyz in surfs:
    _, sname, sflags, snf, nsh, nv, ntri, otri, osh, ost, oxyz, oe = sh
    pre = body[108:oxyz]                       # triangles, shaders, UVs (offsets below oxyz are unchanged)
    newxyz = b''.join(xyz[i] for i in keep)
    noe = oxyz + len(newxyz)
    hdr = struct.pack('<4s64siiiiiiiiii', b'IDP3', sname, sflags, len(keep), nsh, nv, ntri, otri, osh, ost, oxyz, noe)
    assert otri >= 108 and osh >= 108 and ost >= 108 and max(otri, osh, ost) < oxyz, 'unexpected surface layout'
    out_surfs += hdr + pre + newxyz
nofr = 108
nota = nofr + len(out_frames)
nosu = nota + len(out_tags)
noend = nosu + len(out_surfs)
hdr = struct.pack(HDR, ident, ver, name, flags, len(keep), nt, ns, nsk, nofr, nota, nosu, noend)
open(dst, 'wb').write(hdr + out_frames + out_tags + out_surfs)
print(f'{dst}: frames {keep} of {nf}, {noend} bytes (was {len(d)})')
