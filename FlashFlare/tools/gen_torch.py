#!/usr/bin/env python3
"""gen_torch.py -- the flashlight's models, skins and sprites (RSQ FnF), generated: no outside art but BD22 VR's FBX hand.

    python3 -I FlashFlare/tools/gen_torch.py [--bd <03 BD22 VR pk3>]

--bd is only needed the first time: the pump hold (models/rsq/fbx/fbx_s192_L.md3) is copied into tools/src/ and read from
there after that.

THE HAND (FLASHLIGHT_PROPOSAL.md 4, the owner's plan 11-03 19:25): BD22 VR Reloaded's shotgun pump / forend support hand,
fbx_s192_L.md3 frame 1 (its RQWS B, the pump Shot_Gun's), one frame. Measured with tools/fit_grip.py (NEAR=x, frame 1):
the hand wraps a cylinder of radius 2.49 cm along (0.933 -0.250 0.259), centre (49.50 10.15 5.50) in its mesh space, the
hand along it -15.2..5.3 cm. That frame sits on the gun's forend, 48 cm ahead of the gun hand; here it is moved (no turn)
so that cylinder's centre lands on the magazine hold's grip centre (4.70 4.50 0.83; gen_flare.py GRIP_C, the hold the
flare uses in the same off-hand MODELDEF placement), so the hand holds the light where the off hand really is.
THE FLASHLIGHT (made here, cm, along the gripped cylinder; 0 = the grip's centre): tail cap -8.5, body radius 2.3 (the grip
is 2.49) to +6.0, a bezel widening to 3.1 by +8.0, the head to +11.0, the lens (radius 2.75) at +10.8 and a glow disc on
it at +10.9 (shown, full bright, only while it is on). 19.5 cm long, 6.2 cm across the head.
(UNTIL 11-05; now tools/gen_hudcone.py, drawn with the hand) THE CONE (cone_lo.md3, cone_hi.md3): the visible beam, apex at the origin, along model +Z (up), 64 units long, radius at
the end 64 x tan(20 deg). The actor turns it to the beam (pitch + 90) and scales it: Scale.X = tan(half-angle) / tan(20),
Scale.Y = the beam's length / 64. 26 frames (A-Z): in frame k the rings past (k + 1) / 26 of its length are folded onto
that point, so a beam cut short by a wall keeps its fade (the texture's v is fixed per ring) instead of squeezing it.
  lo (Quest): one cone, 12 sides, 8 rings.  hi (PCVR, High): an outer cone and a brighter inner one (half the width),
  16 sides, 13 rings. Skin cone.png: white, the fade in its alpha (drawn AddStencil: the actor's shade is the colour).
SPRITES: QFFSA0 the hotspot (white, soft, alpha; drawn AddStencil), transparent placeholders for the model-only frames.
"""
import argparse, math, os, random, sys, zipfile
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from gen_flare import read_md3, write_md3, unit, cross, M, S, SRC, GRIP_C
from PIL import Image
import struct

PUMP_FRAME = 1
PUMP_C = (49.50, 10.15, 5.50)        # fit_grip.py, NEAR=x, frame 1
PUMP_AX = (0.933, -0.250, 0.259)
PROFILE = [(-8.5, 0.0), (-8.5, 1.9), (-8.2, 2.3), (6.0, 2.3), (8.0, 3.1), (11.0, 3.1), (11.0, 2.75)]   # (along, radius)
LENS_X = 10.8
GLOW_X = 10.9
LENS_R = 2.75
L0 = 64.0
HALF0 = 20.0
FRAMES = 26


def lathe(profile, sides, xf, nf, name, shader, u0=0.0, u1=1.0):
    """a surface of revolution about torch-space x: profile [(x, r)], v along the profile"""
    verts, uvs, tris = [], [], []
    n = len(profile)
    for i, (x, r) in enumerate(profile):
        for s in range(sides + 1):
            a = 2 * math.pi * s / sides
            p = (x, r * math.cos(a), r * math.sin(a))
            # normal: from the profile's slope
            j0, j1 = max(0, i - 1), min(n - 1, i + 1)
            dx = profile[j1][0] - profile[j0][0]; dr = profile[j1][1] - profile[j0][1]
            nn = unit((-dr if (dx or dr) else -1, dx * math.cos(a), dx * math.sin(a))) if (dx or dr) else (-1, 0, 0)
            verts.append((xf(p), nf(nn)))
            uvs.append((u0 + (u1 - u0) * s / sides, i / (n - 1)))
    for i in range(n - 1):
        for s in range(sides):
            a = i * (sides + 1) + s; b = a + 1; c = a + sides + 1; d = c + 1
            tris += [(a, c, b), (b, c, d)]
    return dict(name=name, shader=shader, verts=verts, uvs=uvs, tris=tris)


def disc(x, r, sides, xf, nf, name, shader):
    verts = [(xf((x, 0, 0)), nf((1, 0, 0)))]; uvs = [(0.5, 0.5)]; tris = []
    for s in range(sides + 1):
        a = 2 * math.pi * s / sides
        verts.append((xf((x, r * math.cos(a), r * math.sin(a))), nf((1, 0, 0))))
        uvs.append((0.5 + 0.5 * math.cos(a), 0.5 + 0.5 * math.sin(a)))
    for s in range(sides):
        tris.append((0, s + 1, s + 2))
    return dict(name=name, shader=shader, verts=verts, uvs=uvs, tris=tris)


def write_md3_frames(path, surfs, nframes):
    """surfs: [dict(name, shader, frames=[[(pos, normal)] per frame], uvs, tris)]"""
    from gen_flare import enc_n
    blobs = []
    for s in surfs:
        nv, nt = len(s['frames'][0]), len(s['tris'])
        o_sh = 108; o_tri = o_sh + 68; o_st = o_tri + nt * 12; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8 * nframes
        b = struct.pack('<4s64siiiiiiiiii', b'IDP3', s['name'].encode().ljust(64, b'\0'), 0, nframes, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += s['shader'].encode().ljust(64, b'\0') + struct.pack('<i', 0)
        b += b''.join(struct.pack('<3i', *t) for t in s['tris'])
        b += b''.join(struct.pack('<2f', *uv) for uv in s['uvs'])
        for fr in s['frames']:
            for p, n in fr:
                b += struct.pack('<3hH', *(max(-32768, min(32767, round(c * 64))) for c in p), enc_n(n))
        blobs.append(b)
    frames = b''
    for f in range(nframes):
        pts = [p for s in surfs for p, _ in s['frames'][f]]
        lo = [min(p[k] for p in pts) for k in range(3)]; hi = [max(p[k] for p in pts) for k in range(3)]
        rad = max(math.sqrt(sum(c * c for c in p)) for p in pts)
        frames += struct.pack('<3f3f3ff16s', *lo, *hi, 0, 0, 0, rad, ('frame%d' % f).encode().ljust(16, b'\0'))
    o_fr = 108; o_surf = o_fr + len(frames); o_eof = o_surf + sum(len(b) for b in blobs)
    hdr = struct.pack('<4si64siiiiiiiii', b'IDP3', 15, os.path.basename(path).encode().ljust(64, b'\0'), 0, nframes, 0, len(surfs), 0, o_fr, o_surf, o_surf, o_eof)
    open(path, 'wb').write(hdr + frames + b''.join(blobs))


def cone_surface(sides, rings, rad_frac, u0, u1, name):
    """one cone layer along +z, 26 frames (fold the rings past the cut)"""
    t0 = math.tan(math.radians(HALF0))
    uvs, tris = [], []
    for i in range(rings + 1):
        for s in range(sides + 1):
            uvs.append((u0 + (u1 - u0) * s / sides, i / rings))
    for i in range(rings):
        for s in range(sides):
            a = i * (sides + 1) + s; b = a + 1; c = a + sides + 1; d = c + 1
            tris += [(a, b, c), (b, d, c)]
    frames = []
    for k in range(FRAMES):
        cut = (k + 1) / FRAMES
        fr = []
        for i in range(rings + 1):
            f = min(i / rings, cut)
            z = f * L0; r = z * t0 * rad_frac
            for s in range(sides + 1):
                a = 2 * math.pi * s / sides
                fr.append(((r * math.cos(a), r * math.sin(a), z), (math.cos(a), math.sin(a), -t0 * rad_frac)))
        frames.append(fr)
    return dict(name=name, shader='cone.png', frames=frames, uvs=uvs, tris=tris)


def stowed():
    """torch.md3: the flashlight alone, ON ITS CLIP (RSQFF_TorchStowed, the owner 11-04: "always show ... flashlight"):
    the same profile and lens, cm, the long axis along +x (the lens +x), centred on its own length (-9.75 .. +9.75), the
    glow disc left clear (it is off on the clip)."""
    mid = (PROFILE[0][0] + PROFILE[-1][0]) / 2.0
    def xf(p): return (p[0] - mid, p[1], p[2])
    def nf(n): return n
    surfs = [lathe(PROFILE, 20, xf, nf, 'body', 'torch.png'),
             disc(LENS_X, LENS_R, 20, xf, nf, 'lens', 'torchlens.png')]
    lo, hi = write_md3(os.path.join(M, 'torch.md3'), surfs)
    print('torch.md3: x %.2f..%.2f (lens +x), y %.2f..%.2f, z %.2f..%.2f cm' % (lo[0], hi[0], lo[1], hi[1], lo[2], hi[2]))
    Image.new('RGBA', (4, 4), (0, 0, 0, 0)).save(os.path.join(S, 'QFFTE0.png'))   # its model-only sprite (RSQFF_TorchStowed)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--bd')
    ap.add_argument('--stowed', action='store_true', help='write only torch.md3 (the flashlight on its clip)')
    a = ap.parse_args()
    if a.stowed:
        stowed()
        return
    psrc = os.path.join(SRC, 'fbx_s192_L.md3')
    if a.bd:
        open(psrc, 'wb').write(zipfile.ZipFile(a.bd).read('models/rsq/fbx/fbx_s192_L.md3'))
    pump, nfr = read_md3(open(psrc, 'rb').read())
    d = tuple(GRIP_C[k] - PUMP_C[k] for k in range(3))
    hand = pump[0]
    verts = [((p[0] + d[0], p[1] + d[1], p[2] + d[2]), n) for p, n in hand['frames'][PUMP_FRAME]]
    write_md3(os.path.join(M, 'rsqff_pumphand.md3'), [dict(name='hand', shader='fbx_hand.png', verts=verts, uvs=hand['uvs'], tris=hand['tris'])])
    print('pump hand: fbx_s192_L.md3 frame %d of %d, %d verts, moved by (%.2f %.2f %.2f)' % (PUMP_FRAME, nfr, len(verts), *d))

    # torch space -> hand space: x along the gripped cylinder, origin at its (moved) centre
    x = unit(PUMP_AX); y = unit(cross((0, 0, 1), x)); z = cross(x, y)
    def rot(p): return tuple(x[k] * p[0] + y[k] * p[1] + z[k] * p[2] for k in range(3))
    def xf(p): r = rot(p); return tuple(GRIP_C[k] + r[k] for k in range(3))
    surfs = [lathe(PROFILE, 20, xf, rot, 'body', 'torch.png'),
             disc(LENS_X, LENS_R, 20, xf, rot, 'lens', 'torchlens.png'),
             disc(GLOW_X, LENS_R, 20, xf, rot, 'glow', 'clear.png')]
    write_md3(os.path.join(M, 'torch_h.md3'), surfs)
    lens = xf((GLOW_X + 0.3, 0, 0))
    print('torch_h.md3: the lens centre md3 (%.2f %.2f %.2f), axis (%.3f %.3f %.3f)' % (*lens, *x))
    print('  -> zscript LENS_X/Y/Z for HandPoint: %.2f %.2f %.2f; AX %.3f %.3f %.3f' % (*lens, *x))

    # the visible beam and its hotspot: tools/gen_hudcone.py (11-05: drawn with the hand; the actor cone and sprite are gone)
    tex = Image.new('RGB', (64, 64)); tp = tex.load()
    for j in range(64):
        for i in range(64):
            ridge = 1.0 if (j // 3) % 2 == 0 else 0.8      # knurled bands along the body
            g = int(46 * ridge + 6 * math.sin(i / 64 * 6.283))
            tp[i, j] = (g, g, int(g * 1.05))
    tex.save(os.path.join(M, 'torch.png'))
    lensim = Image.new('RGB', (32, 32)); lp = lensim.load()
    for j in range(32):
        for i in range(32):
            r = math.hypot(i - 15.5, j - 15.5) / 15.5
            c = int(150 - 70 * r) if r < 1 else 60
            lp[i, j] = (c, c + 6, c + 14)
    lensim.save(os.path.join(M, 'torchlens.png'))
    glow = Image.new('RGB', (32, 32)); gp = glow.load()
    for j in range(32):
        for i in range(32):
            r = math.hypot(i - 15.5, j - 15.5) / 15.5
            c = max(0.0, 1 - r * 0.45)
            gp[i, j] = (int(255 * c), int(250 * c), int(235 * c))
    glow.save(os.path.join(M, 'torchglow.png'))
    # placeholders for the model-only sprites: the flashlight in the hand (QFFT A-D) and the cones (QFFC, QFFK A-Z)
    names = ['QFFT%s0' % c for c in 'ABCDE']
    for nm in names:
        Image.new('RGBA', (4, 4), (0, 0, 0, 0)).save(os.path.join(S, nm + '.png'))
    print('wrote models/rsqff (rsqff_pumphand, torch_h, skins), sprites/rsqff (%d placeholders)' % len(names))


if __name__ == '__main__':
    main()
