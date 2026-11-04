#!/usr/bin/env python3
"""gen_flare.py -- every model, skin and graphic of RSQ FlashFlare, from the owner's flare (Flare.blend) and Brutal Doom 22
VR Reloaded's FBX hand. No Blender needed: tools/blendread.py reads the .blend itself.

    python3 -I tools/gen_flare.py --blend <Flare.blend> --tex <dir with FlareTexture.png, FlareTip.png> [--bd <03 BD22 VR pk3>]

--bd is only needed the first time: the hand (fbx_oh_hold_R.md3, and fbx_hand.png) is copied from it into
tools/src/ and read from there after that, so the pack builds without Brutal Doom.

MEASURED from Flare.blend (printed when run): two cylinders along Blender z. "Cylinder" is the body, r 0.922, z -8.664..8.664,
UV u along the length (the label, "HOLD BELOW THIS LINE", "REMOVE"), material FlareTexture. "Cylinder.001" is the striker cap,
r 0.980, z 6.396..8.842, over the +z end, material FlareTip. Object transforms are identity.

WRITES (models/rsqff/):
  flare.md3     the flare on its own, cm, the long axis along +x, the burning end +x, centred on the body. Surfaces: 0 body,
                1 cap (hidden by skin once struck), 2 ember (a glowing disc on the burning end, hidden until lit).
  flare_h.md3   the same flare held in that hand (hand mesh space): along the cylinder the hold grips (tools/fit_grip.py),
                standing up and a little forward like a torch (the owner, 11-03: hand poses hold tools as cylinders).
  rsqff_fbxhand.md3  BD22 VR's FBX off-hand rifle-magazine hold (fbx_oh_hold_R.md3 frame 0, RQHF A), one frame, skin
                fbx_hand.png (so BD22 VR's Hand Skin Tone finds it: MODELDEF slot 7, Skin 7 "fbx_hand.png").
  box.md3       a bundle of three flares (the pickup): surfaces 0 bodies, 1 caps.
  flare.png flaretip.png ember.png fbx_hand.png clear.png
graphics/rsqff/: RQFFLAM.png (flame puff), RQFSPRK.png (spark), RQFSMOK.png (smoke) -- particle textures, drawn here.
sprites/rsqff/: transparent placeholders for the model-only sprites.
"""
import argparse, math, os, struct, sys, zipfile
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from blendread import Blend
from PIL import Image, ImageDraw, ImageFilter

M = os.path.join(ROOT, 'models', 'rsqff')
G = os.path.join(ROOT, 'graphics', 'rsqff')
S = os.path.join(ROOT, 'sprites', 'rsqff')
SRC = os.path.join(HERE, 'src')

SCALE = 1.30            # blend units -> cm: 17.33 x 1.30 = 22.5 cm long, 2.4 cm across (a road flare)
HOLD_DIR = (0.235, -0.109, 0.966)   # the held flare's axis in hand space: the magazine hold's gripped cylinder (fit_grip.py)
HOLD_UP = 4.0           # cm: the flare's centre this far up its axis from the grip's centre (more of it above the hand)
GRIP_C = (4.70, 4.50, 0.83)   # cm: the gripped cylinder's centre (fit_grip.py: radius 3.15, the hand along it -6.2..4.9)


# ---------------------------------------------------------------- md3
def enc_n(v):
    x, y, z = v
    l = math.sqrt(x * x + y * y + z * z) or 1.0
    x, y, z = x / l, y / l, z / l
    if x == 0 and y == 0: return 0 if z > 0 else (128 << 8)
    lat = int(math.atan2(y, x) * 255 / (2 * math.pi)) & 255
    lng = int(math.acos(max(-1, min(1, z))) * 255 / (2 * math.pi)) & 255
    return (lng << 8) | lat


def write_md3(path, surfs):
    """surfs: [dict(name, shader, verts=[(pos, normal)], uvs, tris)] one frame."""
    blobs = []
    for s in surfs:
        nv, nt = len(s['verts']), len(s['tris'])
        o_sh = 108; o_tri = o_sh + 68; o_st = o_tri + nt * 12; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8
        b = struct.pack('<4s64siiiiiiiiii', b'IDP3', s['name'].encode().ljust(64, b'\0'), 0, 1, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += s['shader'].encode().ljust(64, b'\0') + struct.pack('<i', 0)
        b += b''.join(struct.pack('<3i', *t) for t in s['tris'])
        b += b''.join(struct.pack('<2f', *uv) for uv in s['uvs'])
        for p, n in s['verts']:
            b += struct.pack('<3hH', *(max(-32768, min(32767, round(c * 64))) for c in p), enc_n(n))
        blobs.append(b)
    pts = [p for s in surfs for p, _ in s['verts']]
    lo = [min(p[k] for p in pts) for k in range(3)]; hi = [max(p[k] for p in pts) for k in range(3)]
    rad = max(math.sqrt(sum(c * c for c in p)) for p in pts)
    frames = struct.pack('<3f3f3ff16s', *lo, *hi, 0, 0, 0, rad, b'frame0'.ljust(16, b'\0'))
    o_fr = 108; o_surf = o_fr + len(frames); o_eof = o_surf + sum(len(b) for b in blobs)
    hdr = struct.pack('<4si64siiiiiiiii', b'IDP3', 15, os.path.basename(path).encode().ljust(64, b'\0'), 0, 1, 0, len(surfs), 0, o_fr, o_surf, o_surf, o_eof)
    open(path, 'wb').write(hdr + frames + b''.join(blobs))
    return lo, hi


def read_md3(data):
    ident, ver, name, flags, nfr, ntag, nsurf, nskin, ofr, otag, osurf, oend = struct.unpack_from('<4si64siiiiiiiii', data, 0)
    surfs = []; o = osurf
    for _ in range(nsurf):
        sid, sname, sflags, snfr, nsh, nv, ntri, otri, osh, ost, oxyz, send = struct.unpack_from('<4s64siiiiiiiiii', data, o)
        tris = [struct.unpack_from('<3i', data, o + otri + 12 * i) for i in range(ntri)]
        uvs = [struct.unpack_from('<2f', data, o + ost + 8 * i) for i in range(nv)]
        frames = []
        for f in range(snfr):
            vs = []
            for i in range(nv):
                x, y, z, n = struct.unpack_from('<3hH', data, o + oxyz + (f * nv + i) * 8)
                lat = (n & 255) * 2 * math.pi / 255; lng = ((n >> 8) & 255) * 2 * math.pi / 255
                vs.append(((x / 64.0, y / 64.0, z / 64.0), (math.cos(lat) * math.sin(lng), math.sin(lat) * math.sin(lng), math.cos(lng))))
            frames.append(vs)
        surfs.append(dict(name=sname.split(b'\0')[0].decode(), tris=tris, uvs=uvs, frames=frames))
        o += send
    return surfs, nfr


# ---------------------------------------------------------------- the blend
def blend_meshes(path):
    bl = Blend(path)
    out = {}
    for b in bl.blocks:
        if b['code'] != 'ME': continue
        o = b['off']
        name = bl.field('ID', bl.field('Mesh', o, 'id'), 'name')[2:]
        vs = [bl.field('MVert', a, 'co') for a in bl.items(bl.field('Mesh', o, 'mvert'), 'MVert')]
        loops = [bl.field('MLoop', a, 'v') for a in bl.items(bl.field('Mesh', o, 'mloop'), 'MLoop')]
        uvs = [bl.field('MLoopUV', a, 'uv') for a in bl.items(bl.field('Mesh', o, 'mloopuv'), 'MLoopUV')]
        polys = [(bl.field('MPoly', a, 'loopstart'), bl.field('MPoly', a, 'totloop')) for a in bl.items(bl.field('Mesh', o, 'mpoly'), 'MPoly')]
        out[name] = (vs, loops, uvs, polys)
        lo = [min(v[k] for v in vs) for k in range(3)]; hi = [max(v[k] for v in vs) for k in range(3)]
        print('blend mesh %-14s %3d verts %3d polys  bbox (%.3f %.3f %.3f) (%.3f %.3f %.3f)' % (name, len(vs), len(polys), *lo, *hi))
    return out


def to_surface(mesh, name, shader, xf):
    """A blend mesh as an md3 surface: one md3 vertex per (vertex, uv) corner; quads smooth round the axis, the end
    n-gons flat. xf maps a blend point to the surface's space (a point function and a normal function)."""
    vs, loops, uvs, polys = mesh
    pf, nf = xf
    verts, uvo, tris, key = [], [], [], {}
    for ls, tl in polys:
        cyc = list(range(ls, ls + tl))
        if tl > 4:   # an end cap: flat
            p0, p1, p2 = (vs[loops[cyc[i]]] for i in (0, 1, 2))
            u = [p1[k] - p0[k] for k in range(3)]; w = [p2[k] - p0[k] for k in range(3)]
            fn = (u[1] * w[2] - u[2] * w[1], u[2] * w[0] - u[0] * w[2], u[0] * w[1] - u[1] * w[0])
        idx = []
        for li in cyc:
            v = vs[loops[li]]
            n = fn if tl > 4 else (v[0], v[1], 0.0)
            k = (loops[li], round(uvs[li][0], 5), round(uvs[li][1], 5), tl > 4)
            if k not in key:
                key[k] = len(verts)
                verts.append((pf(v), nf(n)))
                uvo.append((uvs[li][0], 1.0 - uvs[li][1]))     # md3 v runs down the image
            idx.append(key[k])
        for i in range(1, len(idx) - 1):
            tris.append((idx[0], idx[i + 1], idx[i]))      # md3 winding (clockwise seen from outside)
    return dict(name=name, shader=shader, verts=verts, uvs=uvo, tris=tris)


def ember_surface(xf, x_end, r):
    """A disc capping the burning end (blend z = x_end), facing out, a little proud of the body."""
    pf, nf = xf
    seg = 16
    verts = [(pf((0.0, 0.0, x_end + 0.03)), nf((0, 0, 1)))]; uvs = [(0.5, 0.5)]
    for i in range(seg):
        a = 2 * math.pi * i / seg
        verts.append((pf((r * math.cos(a), r * math.sin(a), x_end + 0.03)), nf((0, 0, 1))))
        uvs.append((0.5 + 0.5 * math.cos(a), 0.5 + 0.5 * math.sin(a)))
    tris = [(0, 1 + (i + 1) % seg, 1 + i) for i in range(seg)]
    return dict(name='ember', shader='ember.png', verts=verts, uvs=uvs, tris=tris)


# ---------------------------------------------------------------- spaces
def unit(v): l = math.sqrt(sum(c * c for c in v)); return tuple(c / l for c in v)
def cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def canon_xf(zc, extra=None):
    """blend (x, y, z) -> flare space cm: blend z (the long axis, burning end +z) becomes +x, centred on zc."""
    def pf(v):
        p = ((v[2] - zc) * SCALE, v[1] * SCALE, -v[0] * SCALE)
        return extra[0](p) if extra else p
    def nf(n):
        q = (n[2], n[1], -n[0])
        return extra[1](q) if extra else q
    return pf, nf


def hand_xf(hole):
    """flare space -> hand mesh space: +x along HOLD_DIR, centre HOLD_UP above the grip hole."""
    x = unit(HOLD_DIR); y = unit(cross((0, 0, 1), x)) if abs(x[2]) < 0.99 else (0, 1, 0); z = cross(x, y)
    c = tuple(hole[k] + x[k] * HOLD_UP for k in range(3))
    def rot(p): return tuple(x[k] * p[0] + y[k] * p[1] + z[k] * p[2] for k in range(3))
    return (lambda p: tuple(c[k] + rot(p)[k] for k in range(3))), rot, x, c


def grip_hole(hand_pts):
    """gen_handprops.py's measure (TacticalRig): the fist sliced at z -1..3, 1 cm cells in front of the palm, the empty
    cells walled by hand within 3 cm in all four directions."""
    occ = set()
    for p in hand_pts:
        if -1 <= p[2] <= 3 and p[0] > 1: occ.add((math.floor(p[0]), math.floor(p[1])))
    hole = []
    for x in range(1, 12):
        for y in range(-5, 9):
            if (x, y) in occ: continue
            if all(any((x + dx * k, y + dy * k) in occ for k in (1, 2, 3)) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                hole.append((x + 0.5, y + 0.5))
    return (sum(c[0] for c in hole) / len(hole), sum(c[1] for c in hole) / len(hole), HOLE_Z), len(hole)


# ---------------------------------------------------------------- pictures
def radial(size, stops, alpha=False):
    """stops: [(r 0..1, (r, g, b, a))]; additive pictures use black for nothing."""
    im = Image.new('RGBA' if alpha else 'RGB', (size, size), (0, 0, 0, 0) if alpha else (0, 0, 0))
    px = im.load(); c = (size - 1) / 2.0
    for j in range(size):
        for i in range(size):
            r = math.hypot(i - c, j - c) / c
            col = stops[-1][1]
            for k in range(len(stops) - 1):
                r0, c0 = stops[k]; r1, c1 = stops[k + 1]
                if r0 <= r <= r1:
                    t = (r - r0) / (r1 - r0) if r1 > r0 else 0
                    col = tuple(int(c0[m] + (c1[m] - c0[m]) * t) for m in range(4)); break
            px[i, j] = col if alpha else col[:3]
    return im


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--blend', required=True); ap.add_argument('--tex', required=True); ap.add_argument('--bd')
    a = ap.parse_args()
    for d in (M, G, S, SRC): os.makedirs(d, exist_ok=True)

    hsrc = os.path.join(SRC, 'fbx_oh_hold_R.md3'); tsrc = os.path.join(SRC, 'fbx_hand.png')
    if a.bd:
        z = zipfile.ZipFile(a.bd)
        open(hsrc, 'wb').write(z.read('models/rsq/fbx/fbx_oh_hold_R.md3'))
        open(tsrc, 'wb').write(z.read('models/rsq/fbx/fbx_hand.png'))
    hand, nfr = read_md3(open(hsrc, 'rb').read())

    meshes = blend_meshes(a.blend)
    body, cap = meshes['Cylinder'], meshes['Cylinder.001']
    zlo = min(v[2] for v in body[0]); zhi = max(v[2] for v in body[0]); r = max(math.hypot(v[0], v[1]) for v in body[0])
    zc = (zlo + zhi) / 2
    print('flare: %.1f cm long, %.2f cm across (x%.2f)' % ((zhi - zlo) * SCALE, 2 * r * SCALE, SCALE))

    # the flare alone (world): flare space
    xf = canon_xf(zc)
    surfs = [to_surface(body, 'body', 'flare.png', xf), to_surface(cap, 'cap', 'flaretip.png', xf), ember_surface(xf, zhi, r * 0.97)]
    lo, hi = write_md3(os.path.join(M, 'flare.md3'), surfs)
    print('flare.md3: x %.2f..%.2f (burning end +x), y %.2f..%.2f, z %.2f..%.2f cm' % (lo[0], hi[0], lo[1], hi[1], lo[2], hi[2]))

    # the hand: BD22 VR's FBX off-hand rifle-magazine hold (fbx_oh_hold_R.md3 frame 0, RQHF A), one frame
    fist = dict(name='hand', shader='fbx_hand.png', verts=hand[0]['frames'][0], uvs=hand[0]['uvs'], tris=hand[0]['tris'])
    write_md3(os.path.join(M, 'rsqff_fbxhand.md3'), [fist])
    hole = GRIP_C
    print('grip (magazine hold, fit_grip.py): centre (%.2f %.2f %.2f) axis (%.3f %.3f %.3f)' % (*hole, *HOLD_DIR))

    # the flare in the fist
    hp, hr, ax, centre = hand_xf(hole)
    xfh = canon_xf(zc, (hp, hr))
    surfs_h = [to_surface(body, 'body', 'flare.png', xfh), to_surface(cap, 'cap', 'flaretip.png', xfh), ember_surface(xfh, zhi, r * 0.97)]
    write_md3(os.path.join(M, 'flare_h.md3'), surfs_h)
    half = (zhi - zlo) / 2 * SCALE
    tip = tuple(centre[k] + ax[k] * half for k in range(3)); butt = tuple(centre[k] - ax[k] * half for k in range(3))
    print('flare_h.md3: burning end md3 (%.2f %.2f %.2f), butt (%.2f %.2f %.2f), axis (%.3f %.3f %.3f)' % (*tip, *butt, *ax))
    print('  -> zscript TIP_X/Y/Z for HandPoint (md3 cm in the hand mesh space): %.2f %.2f %.2f' % tip)

    # the bundle of three (pickup), flare space shifted side by side
    bodies, caps = [], []
    for k, (dy, dz) in enumerate(((-1.25, 0), (1.25, 0), (0, 2.1))):
        shift = (lambda dy, dz: ((lambda p: (p[0], p[1] + dy * r * SCALE / 1.0, p[2] + dz * r * SCALE / 2.0)), (lambda n: n)))(dy, dz)
        x3 = canon_xf(zc, shift)
        bodies.append(to_surface(body, 'body', 'flare.png', x3)); caps.append(to_surface(cap, 'cap', 'flaretip.png', x3))
    def merge(lst, name, sh):
        v, u, t = [], [], []
        for s in lst:
            o = len(v); v += s['verts']; u += s['uvs']; t += [(a + o, b + o, c + o) for a, b, c in s['tris']]
        return dict(name=name, shader=sh, verts=v, uvs=u, tris=t)
    write_md3(os.path.join(M, 'box.md3'), [merge(bodies, 'body', 'flare.png'), merge(caps, 'cap', 'flaretip.png')])

    # skins
    Image.open(os.path.join(a.tex, 'FlareTexture.png')).convert('RGB').resize((512, 184), Image.LANCZOS).save(os.path.join(M, 'flare.png'), optimize=True)
    Image.open(os.path.join(a.tex, 'FlareTip.png')).convert('RGB').resize((128, 128), Image.LANCZOS).save(os.path.join(M, 'flaretip.png'), optimize=True)
    Image.open(tsrc).convert('RGB').resize((256, 256), Image.LANCZOS).save(os.path.join(M, 'fbx_hand.png'), optimize=True)
    radial(64, [(0, (255, 255, 235, 255)), (0.35, (255, 225, 150, 255)), (0.75, (255, 120, 60, 255)), (1.0, (200, 40, 20, 255))]).save(os.path.join(M, 'ember.png'))
    Image.new('RGBA', (8, 8), (0, 0, 0, 0)).save(os.path.join(M, 'clear.png'))
    # particles (additive: black is nothing; smoke translucent)
    radial(32, [(0, (255, 250, 220, 255)), (0.25, (255, 190, 120, 255)), (0.6, (230, 60, 30, 255)), (1.0, (0, 0, 0, 255))]).save(os.path.join(G, 'RQFFLAM.png'))
    radial(8, [(0, (255, 255, 230, 255)), (0.5, (255, 200, 90, 255)), (1.0, (0, 0, 0, 255))]).save(os.path.join(G, 'RQFSPRK.png'))
    radial(32, [(0, (120, 110, 105, 150)), (0.6, (100, 95, 92, 70)), (1.0, (90, 90, 90, 0))], alpha=True).save(os.path.join(G, 'RQFSMOK.png'))
    # placeholders for the model-only sprites
    for nm in ('QFFHA0', 'QFFHB0', 'QFFHC0', 'QFFHD0', 'QFFHE0', 'QFFHF0', 'QFFWA0', 'QFFWB0', 'QFFWC0', 'QFFBA0'):
        Image.new('RGBA', (4, 4), (0, 0, 0, 0)).save(os.path.join(S, nm + '.png'))
    print('wrote models/rsqff, graphics/rsqff, sprites/rsqff')


if __name__ == '__main__':
    main()
