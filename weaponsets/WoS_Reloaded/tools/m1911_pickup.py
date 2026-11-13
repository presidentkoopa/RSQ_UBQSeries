"""m1911_pickup.py <unpacked voxel-m1911 zip dir> -> assets/m1911_pickup/{m1911_pickup.md3, m1911.png}

The 1911's pickup (owner 2026-11-12: uploaded voxel-m1911-prototype-asset-rigged.zip). Its FBX (source/
M1911_Model_FinalPreview_Clip.fbx: six meshes, cm, Y up, a 256x1 palette texture the UVs index) as one MD3 frame: every
mesh at its bind pose (its Lcl Translation), triangulated, one surface per mesh, all on the palette. It stands side-on on
its base like BD22's voxel pistol pickup (pistG0: 29 x 3 x 14 voxels at Voxeldef scale 0.8 = 23.2 units long), so it is
scaled to that length. MD3 axes: X = the FBX X (its length), Y = -FBX Z, Z = FBX Y (up); its base at Z 0, centred."""
import os, sys, struct, numpy as np
sys.path.insert(0, '/home/claude/presidentkoopa/rs_modelswapper/tools/handfit/core/hands_tool')
import fbxbin
SRC = sys.argv[1]
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'm1911_pickup')
ver, root = fbxbin.load(os.path.join(SRC, 'source', 'M1911_Model_FinalPreview_Clip.fbx'))
obj = root.find('Objects')
geo = {g.props[0]: g for g in obj.findall('Geometry')}
mdl = {m.props[0]: m for m in obj.findall('Model') if m.props[2] == 'Mesh'}
link = {}	# geometry id -> model id
for c in root.find('Connections').children:
    if c.props[0] == 'OO' and c.props[1] in geo and c.props[2] in mdl: link[c.props[1]] = c.props[2]
surfs = []
for gid, g in geo.items():
    m = mdl[link[gid]]; name = m.props[1].split('\x00')[0]
    t = np.array(fbxbin.props70(m).get('Lcl Translation', ('', [0, 0, 0]))[1], float)
    V = g.find('Vertices').props[0].reshape(-1, 3) + t
    P = g.find('PolygonVertexIndex').props[0]
    uvl = g.find('LayerElementUV'); UV = uvl.find('UV').props[0].reshape(-1, 2)
    mode = uvl.find('MappingInformationType').props[0]; ref = uvl.find('ReferenceInformationType').props[0]
    UI = uvl.find('UVIndex').props[0] if ref == 'IndexToDirect' else None
    corners, polys, cur = [], [], []
    for k, i in enumerate(P):
        vi = i if i >= 0 else ~i
        if mode == 'ByPolygonVertex': u = UV[UI[k]] if UI is not None else UV[k]
        else: u = UV[UI[vi]] if UI is not None else UV[vi]
        cur.append((vi, float(u[0]), float(u[1])))
        if i < 0: polys.append(cur); cur = []
    key, verts, uvs, tris = {}, [], [], []
    def vid(c):
        kk = (c[0], round(c[1], 5), round(c[2], 5))
        if kk not in key: key[kk] = len(verts); verts.append(V[c[0]]); uvs.append((c[1], 1 - c[2]))
        return key[kk]
    for p in polys:
        ids = [vid(c) for c in p]
        for j in range(1, len(ids) - 1): tris.append((ids[0], ids[j], ids[j + 1]))
    surfs.append((name, np.array(verts), np.array(uvs), np.array(tris)))
allv = np.concatenate([s[1] for s in surfs])
lo, hi = allv.min(0), allv.max(0)
scale = 23.2 / (hi[0] - lo[0])
ctr = np.array([(lo[0] + hi[0]) / 2, lo[1], (lo[2] + hi[2]) / 2])
def md3pos(v): w = (v - ctr) * scale; return np.stack([w[:, 0], -w[:, 2], w[:, 1]], 1)
def write_md3(path):
    def s64(x, n=64): return x.encode()[:n - 1].ljust(n, b'\0')
    bodies = []
    for name, v, uv, tri in surfs:
        p = md3pos(v); nv, nt = len(p), len(tri)
        hdr = 4 + 64 + 4 * 10
        o_tri = hdr; o_sh = o_tri + nt * 12; o_st = o_sh + 68; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8
        b = b'IDP3' + s64(name) + struct.pack('<10i', 0, 1, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += b''.join(struct.pack('<3i', *[int(x) for x in t[::-1]]) for t in tri)	# MD3 winding
        b += s64('m1911.png') + struct.pack('<i', 0)
        b += b''.join(struct.pack('<2f', float(a), float(c)) for a, c in uv)
        b += b''.join(struct.pack('<3hBB', *[int(round(x * 64)) for x in q], 0, 0) for q in p)
        bodies.append(b)
    allp = md3pos(allv); mn, mx = allp.min(0), allp.max(0)
    frame = struct.pack('<3f3f3ff', *mn, *mx, 0, 0, 0, float(np.linalg.norm(mx - mn) / 2)) + s64('pickup', 16)
    o_fr = 108; o_tag = o_fr + len(frame); o_su = o_tag
    head = b'IDP3' + struct.pack('<i', 15) + s64('m1911_pickup') + struct.pack('<9i', 0, 1, 0, len(bodies), 0, o_fr, o_tag, o_su, o_su + sum(map(len, bodies)))
    open(path, 'wb').write(head + frame + b''.join(bodies))
os.makedirs(OUT, exist_ok=True)
write_md3(os.path.join(OUT, 'm1911_pickup.md3'))
import shutil; shutil.copyfile(os.path.join(SRC, 'textures', 'M1911-0.png'), os.path.join(OUT, 'm1911.png'))
print('surfaces', [(s[0], len(s[1]), len(s[3])) for s in surfs], 'size units', np.round((hi - lo) * scale, 1), 'scale', round(scale, 3))
