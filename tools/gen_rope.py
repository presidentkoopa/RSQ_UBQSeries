#!/usr/bin/env python3
"""Generate the rope's model. Procedural, deterministic, no Blender.

    python3 tools/gen_rope.py

Writes
  models/rsqgr/rsqrope.md3   a hexagonal tube along +Z, ROPE_L long, radius 1
  models/rsqgr/rsqrope.png   its skin: a steel cable in jpalomo's tenda0 grey, a
                             slow twist along the length
  sprites/RSGMA0.png         1x1 transparent placeholder so the sprite name exists

WHY A MODEL AND NOT A CHAIN OF SPRITES. The series tried bead chains for the grab's
beam: 48 billboards re-placed 35 times a second against a hand rendered at headset
rate strobed, and the owner threw it out ("no way this will work"). The first cut of
this rope did the same with tenda0 sprites and drew fat white balls in the face
(rig frames, 10-27). A tube is real geometry: constant thickness at any distance,
depth-correct, and one actor covers any length.

WHY +Z. An actor's Scale.X scales both horizontal model axes but Scale.Y only the
vertical one (models.cpp RenderModel: scale(scaleFactorX, scaleFactorZ, ...)). So the
tube is authored along +Z: Scale.Y is its length, Scale.X its thickness, and the
actor is pitched 90 degrees past the rope's direction (as RSQ_DistanceGrab's beam).
MODELDEF sets CORRECTPIXELSTRETCH, so the tube is aimed along the ROOM vector
(map z x 1.2) and the engine squashes it back into map space after the rotation.

WHY A FAINT PATTERN. A taut rope is ONE segment however long, so its skin stretches
with it; a strong link pattern would smear. The twist is slow and low-contrast so it
reads as a cable near the hand and as a plain line far away.
"""
import os, math, struct, zlib

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))
ROPE_L = 32.0      # authored length; the actor's Scale.Y = segment room length / ROPE_L
SIDES = 6
RADIUS = 1.0       # Scale.X = thickness in map units


def enc_normal(n):
    l = math.sqrt(sum(c * c for c in n)) or 1.0
    n = [c / l for c in n]
    lat = int(round(math.degrees(math.acos(max(-1, min(1, n[2])))) * 255 / 360)) & 255
    lng = int(round(math.degrees(math.atan2(n[1], n[0])) * 255 / 360)) & 255
    return (lat << 8) | lng


def pad(s, n):
    b = s.encode('ascii')[:n - 1]
    return b + b'\0' * (n - len(b))


def mesh():
    verts, norms, uvs, tris = [], [], [], []
    for ring, z in ((0, 0.0), (1, ROPE_L)):
        for k in range(SIDES + 1):          # seam duplicated for a clean U wrap
            a = 2 * math.pi * k / SIDES
            verts.append((math.cos(a) * RADIUS, math.sin(a) * RADIUS, z))
            norms.append((math.cos(a), math.sin(a), 0.0))
            uvs.append((k / SIDES, float(ring)))
    n = SIDES + 1
    for k in range(SIDES):
        a, b, c, d = k, k + 1, n + k + 1, n + k
        # both windings: a 12-triangle tube costs nothing doubled, and no culling
        # convention can hide it
        tris += [(a, c, b), (a, d, c), (a, b, c), (a, c, d)]
    return verts, norms, uvs, tris


def write_md3(path, verts, norms, uvs, tris, skin):
    nv, nt = len(verts), len(tris)
    s_hdr = 4 + 64 + 4 * 10
    ofs_shaders = s_hdr
    ofs_tris = ofs_shaders + 68
    ofs_st = ofs_tris + nt * 12
    ofs_xyz = ofs_st + nv * 8
    ofs_send = ofs_xyz + nv * 8
    surf = bytearray()
    surf += b'IDP3' + pad('rope', 64)
    surf += struct.pack('<10i', 0, 1, 1, nv, nt, ofs_tris, ofs_shaders, ofs_st, ofs_xyz, ofs_send)
    surf += pad(skin, 64) + struct.pack('<i', 0)
    for t in tris: surf += struct.pack('<3i', *t)
    for (s, t) in uvs: surf += struct.pack('<2f', s, t)
    for p, nn in zip(verts, norms):
        q = [int(round(c * 64)) for c in p]
        surf += struct.pack('<3hH', q[0], q[1], q[2], enc_normal(nn))
    assert len(surf) == ofs_send
    mn = [min(p[k] for p in verts) for k in range(3)]
    mx = [max(p[k] for p in verts) for k in range(3)]
    rad = max(math.sqrt(sum(c * c for c in p)) for p in verts)
    fr = struct.pack('<3f3f3ff', *mn, *mx, 0, 0, 0, rad) + pad('rope', 16)
    hdr = 4 + 4 + 64 + 4 * 9
    ofs_frames = hdr
    ofs_surf = ofs_frames + len(fr)
    ofs_end = ofs_surf + len(surf)
    out = b'IDP3' + struct.pack('<i', 15) + pad('rsqrope', 64)
    out += struct.pack('<9i', 0, 1, 0, 1, 0, ofs_frames, ofs_surf, ofs_surf, ofs_end) + fr + surf
    open(path, 'wb').write(out)
    return len(out)


def png(path, w, h, pixel):
    raw = b''.join(b'\0' + b''.join(bytes(pixel(x, y)) for x in range(w)) for y in range(h))
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    data = (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))
    open(path, 'wb').write(data)


def main():
    v, n, uv, t = mesh()
    size = write_md3(os.path.join(ROOT, 'models/rsqgr/rsqrope.md3'), v, n, uv, t, 'rsqrope.png')
    # tenda0's grey (163, 159, 159), a slow helical twist: 3 strands, 2 turns per ROPE_L
    def px(x, y):
        u, vv = x / 32.0, y / 64.0
        s = 0.5 + 0.5 * math.cos(2 * math.pi * (3 * u + 2 * vv))
        k = 0.78 + 0.22 * s
        return (int(163 * k), int(159 * k), int(159 * k), 255)
    png(os.path.join(ROOT, 'models/rsqgr/rsqrope.png'), 32, 64, px)
    png(os.path.join(ROOT, 'sprites/RSGMA0.png'), 1, 1, lambda x, y: (0, 0, 0, 0))
    print('rsqrope.md3', size, 'bytes,', len(v), 'verts,', len(t), 'tris')


if __name__ == '__main__':
    main()
