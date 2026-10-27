# mdl2md3.py <in.mdl> <out.md3> [skin_png_out]
# Quake 1 .mdl (IDPO v6) -> MD3, first frame, one surface. Stock QuestZDoom 17.3 reads MD3 but not
# Quake .mdl. Both are Z-up with X forward, in the same units, so vertices copy across unscaled.
# The embedded 8-bit skin can be written out as a PNG through Quake's palette (--palette palette.lmp),
# but the torso already has PNG skins, so by default no skin is written.
import struct, sys, math

def main(src, dst):
    d = open(src, 'rb').read()
    (ident, ver, sx, sy, sz, tx, ty, tz, brad, ex, ey, ez, nskins, sw, sh, nverts, ntris, nframes,
     sync, flags, size) = struct.unpack('<4si3f3ff3f8if', d[:84])
    assert ident == b'IDPO' and ver == 6, (ident, ver)
    o = 84
    for _ in range(nskins):
        group, = struct.unpack('<i', d[o:o+4]); o += 4
        assert group == 0, 'skin groups not handled'
        o += sw * sh
    st = []
    for _ in range(nverts):
        onseam, s, t = struct.unpack('<3i', d[o:o+12]); o += 12
        st.append((onseam, s, t))
    tris = []
    for _ in range(ntris):
        front, a, b, c = struct.unpack('<4i', d[o:o+16]); o += 16
        tris.append((front, a, b, c))
    ftype, = struct.unpack('<i', d[o:o+4]); o += 4
    assert ftype == 0, 'frame groups not handled'
    o += 8                     # bboxmin, bboxmax
    o += 16                    # name
    verts = []
    for _ in range(nverts):
        x, y, z, n = struct.unpack('<4B', d[o:o+4]); o += 4
        verts.append((sx * x + tx, sy * y + ty, sz * z + tz))
    # MD3 needs one texcoord per vertex: split seam vertices used by back-facing triangles.
    out_v, out_uv, remap, faces = [], [], {}, []
    for front, *idx in tris:
        f = []
        for i in idx:
            onseam, s, t = st[i]
            back = (not front) and onseam
            key = (i, back)
            if key not in remap:
                if back: s += sw // 2
                remap[key] = len(out_v)
                out_v.append(verts[i])
                out_uv.append(((s + 0.5) / sw, (t + 0.5) / sh))
            f.append(remap[key])
        faces.append(f)
    write_md3(dst, out_v, out_uv, faces)
    lo = [min(v[k] for v in out_v) for k in range(3)]; hi = [max(v[k] for v in out_v) for k in range(3)]
    print(f'{src}: {nverts} verts ({len(out_v)} after seam split), {ntris} tris, skin {sw}x{sh}, '
          f'bounds x {lo[0]:.1f}..{hi[0]:.1f} y {lo[1]:.1f}..{hi[1]:.1f} z {lo[2]:.1f}..{hi[2]:.1f}')

def write_md3(path, V, UV, F):
    name = b'torso'.ljust(64, b'\0')
    nv, nt = len(V), len(F)
    # surface
    s_hdr = 108; s_shader = 68; s_tris = nt * 12; s_st = nv * 8; s_xyz = nv * 8
    o_sh = s_hdr; o_tri = o_sh + s_shader; o_st = o_tri + s_tris; o_xyz = o_st + s_st; o_end = o_xyz + s_xyz
    surf = struct.pack('<4s64s10i', b'IDP3', name, 0, 1, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
    surf += b'skin'.ljust(64, b'\0') + struct.pack('<i', 0)
    surf += b''.join(struct.pack('<3i', *f[::-1]) for f in F)     # MD3 winds the other way
    surf += b''.join(struct.pack('<2f', u, v) for u, v in UV)
    for x, y, z in V:
        surf += struct.pack('<3hBB', round(x * 64), round(y * 64), round(z * 64), 0, 0)
    lo = [min(v[k] for v in V) for k in range(3)]; hi = [max(v[k] for v in V) for k in range(3)]
    rad = max(math.sqrt(x*x + y*y + z*z) for x, y, z in V)
    frame = struct.pack('<3f3f3ff16s', *lo, *hi, 0, 0, 0, rad, b'frame0'.ljust(16, b'\0'))
    o_fr = 108; o_tag = o_fr + len(frame); o_surf = o_tag; o_eof = o_surf + len(surf)
    hdr = struct.pack('<4si64s9i', b'IDP3', 15, b'torso'.ljust(64, b'\0'), 0, 1, 0, 1, 0, o_fr, o_tag, o_surf, o_eof)
    open(path, 'wb').write(hdr + frame + surf)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
