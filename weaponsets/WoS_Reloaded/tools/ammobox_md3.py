"""ammobox_md3.py -> assets/ammobox/{ammobox.md3, ammoa.png}

The Rotary Cannon's magazine as the owner asked for it: "a half sized voxel ammo box in my hand". BD22's voxel ammo box
(BD22 voxel pack Voxels/Ammo/AMMOA.kvx, 103 x 29 x 64 voxels) turned into an MD3 so that it is placed exactly as
every other reload part is (MODELDEF in the md3's own units, port_gun.chain): each solid voxel face that is open to the
air becomes a quad, its colour the box's own palette (BD22 VR's rsqvox/ammoa.png, the 16 x 16 palette as a skin). The
box is 18 units long (half of its pickup: Voxeldef ammoa Scale 0.35 x 103 voxels = 36), its middle at the origin;
MD3 X = voxel X (its length), Y = voxel Y, Z = up."""
import os, struct, zipfile, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(os.path.dirname(HERE), 'assets', 'ammobox')
BDVOX = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/pk3/02_BD22_VoxelPack.pk3'
SKIN = '/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src/rsqvox/ammoa.png'
b = zipfile.ZipFile(BDVOX).read('Voxels/Ammo/AMMOA.kvx')
nb, X, Y, Z = struct.unpack_from('<4i', b, 0)
o = 28
xoff = struct.unpack_from('<%di' % (X + 1), b, o); o += 4 * (X + 1)
xyoff = np.frombuffer(b, '<u2', X * (Y + 1), o).reshape(X, Y + 1); o += 2 * X * (Y + 1)
base = 4 + 24 + 4 * (X + 1) + 2 * X * (Y + 1)
col = -np.ones((X, Y, Z), int)
for x in range(X):
    for y in range(Y):
        p = base + xoff[x] - xoff[0] + xyoff[x][y]; e = base + xoff[x] - xoff[0] + xyoff[x][y + 1]
        while p < e:
            zt, zl = b[p], b[p + 1]; p += 3
            for k in range(zl): col[x, y, zt + k] = b[p + k]
            p += zl
# fill the inside (slabs store only the surface): a voxel between two solid ones along z in the same column is solid
for x in range(X):
    for y in range(Y):
        zs = np.nonzero(col[x, y] >= 0)[0]
        if len(zs) >= 2:
            for z in range(zs[0], zs[-1] + 1):
                if col[x, y, z] < 0: col[x, y, z] = -2	# solid inside, never seen
solid = col != -1
S = 18.0 / X
ctr = np.array([X / 2, Y / 2, Z / 2])
verts, uvs, tris = [], [], []
def quad(c, axis, sign, ci):
    # the face of voxel c on the side axis/sign; corners in MD3 space
    x, y, z = c
    lo = np.array([x, y, z], float); d = [np.zeros(3), np.zeros(3)]
    a1, a2 = [a for a in range(3) if a != axis]
    f = lo.copy(); f[axis] += 1 if sign > 0 else 0
    pts = []
    for u, v in ((0, 0), (1, 0), (1, 1), (0, 1)):
        q = f.copy(); q[a1] += u; q[a2] += v; pts.append(q)
    if (sign > 0) != ((axis == 1)):	# keep the outward winding
        pts = pts[::-1]
    uv = ((ci % 16 + 0.5) / 16, (ci // 16 + 0.5) / 16)
    i0 = len(verts)
    for q in pts:
        w = (q - ctr) * S
        verts.append((w[0], w[1], -w[2]))	# voxel z runs down
        uvs.append(uv)
    tris.extend([(i0, i0 + 1, i0 + 2), (i0, i0 + 2, i0 + 3)])
idx = np.argwhere(col >= 0)
for c in idx:
    for axis in range(3):
        for sign in (-1, 1):
            n = c.copy(); n[axis] += sign
            if 0 <= n[axis] < (X, Y, Z)[axis] and solid[tuple(n)]: continue
            quad(c, axis, sign, col[tuple(c)])
verts = np.array(verts); print('faces', len(tris) // 2, 'verts', len(verts), 'size', (verts.max(0) - verts.min(0)).round(2))
def s64(x, n=64): return x.encode()[:n - 1].ljust(n, b'\0')
def surface(name, v, uv, tri):
    nv, nt = len(v), len(tri); hdr = 108
    o_tri = hdr; o_sh = o_tri + nt * 12; o_st = o_sh + 68; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8
    s = b'IDP3' + s64(name) + struct.pack('<10i', 0, 1, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
    s += b''.join(struct.pack('<3i', *t) for t in tri) + s64('ammoa.png') + struct.pack('<i', 0)
    s += b''.join(struct.pack('<2f', *u) for u in uv)
    s += b''.join(struct.pack('<3hBB', *[int(round(c * 64)) for c in q], 0, 0) for q in v)
    return s
# MD3 surfaces stay under 4096 vertices each (the format's limit)
bodies = []; step = 4096 // 4 * 4
for k in range(0, len(verts), step):
    v = verts[k:k + step]; uv = uvs[k:k + step]
    tr = [(a - k, b_ - k, c - k) for a, b_, c in tris if k <= a < k + step]
    bodies.append(surface('box%d' % (k // step), v, uv, tr))
mn, mx = verts.min(0), verts.max(0)
frame = struct.pack('<3f3f3ff', *mn, *mx, 0, 0, 0, float(np.linalg.norm(mx - mn) / 2)) + s64('box', 16)
head = b'IDP3' + struct.pack('<i', 15) + s64('ammobox') + struct.pack('<9i', 0, 1, 0, len(bodies), 0, 108, 108 + len(frame), 108 + len(frame), 108 + len(frame) + sum(map(len, bodies)))
os.makedirs(OUT, exist_ok=True)
open(os.path.join(OUT, 'ammobox.md3'), 'wb').write(head + frame + b''.join(bodies))
import shutil; shutil.copyfile(SKIN, os.path.join(OUT, 'ammoa.png'))
# the dropped (spent) box (owner: "recolor it brown or grey so it looks empty compared to one that is full"): the same
# palette by luminance, warmed to a dull brown
from PIL import Image
a = np.array(Image.open(SKIN).convert('RGB')).astype(float); l = a @ [0.299, 0.587, 0.114]
Image.fromarray(np.stack([l * 0.95 + 18, l * 0.80 + 10, l * 0.62 + 4], -1).clip(0, 255).astype(np.uint8)).save(os.path.join(OUT, 'ammoa_empty.png'))
print('surfaces', len(bodies))
