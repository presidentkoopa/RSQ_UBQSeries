#!/usr/bin/env python3
"""gen_hudcone.py -- the flashlight's visible beam, DRAWN WITH THE HAND (RSQ FnF; owner 11-05 00:43, headset, PCVR: "The
flashlight cone lags, fix the lag or disable cone").

    python3 -I FlashFlare/tools/gen_hudcone.py

WHY: the beam was an actor moved once a tic to the lens (torch.zs, until 11-05). The flashlight in the hand is the off-hand
weapon's model, drawn by the engine at the controller's pose EVERY FRAME (r_data/models.cpp RenderHUDModel); an actor is
drawn where the last tic put it, so a moving hand left the cone behind (rig 11-05: 3-4 cm off the lens at the apex on a
slow 105 deg/s sweep, and a tic behind in direction). Now the cone and its hotspot are overlay layers of the flashlight
itself (RSQFF_Torch), so the engine draws them with the hand, in the same transform, every frame.

WHAT IS WRITTEN (models/rsqff/):
  hudcone_lo_f.md3 / hudcone_lo_b.md3   Quest quality (one cone, 12 sides): front-facing and back-facing copies
  hudcone_hi_f.md3 / hudcone_hi_b.md3   PCVR / High (an outer cone and a brighter inner one, 16 sides)
  hudcone_cNN.png                        the skin in each beam colour (NN = torch.zs Shade index; 20 Warm White)
Each md3 holds, per (beam size, quality), FRAMES lengths (log-spaced from LMIN metres to the quality's range) -- frame
index = combo * FRAMES + k. The mesh is baked in the HAND MESH's space (the space torch_h.md3 and the pump hand are in),
apex at the lens, along the flashlight's axis, divided by K so the md3's 16-bit coordinates reach 26 m (MODELDEF draws it
at Scale -K K K with the hand block's Offset, which is the hand block's transform exactly). The front copy also carries the
hotspot: a soft disc at the cone's end, facing the hand (drawn twice: twice as bright, as the old hotspot sprite was).
TWO COPIES, TWO LAYERS: a HUD model is drawn with depth writes on, so one two-sided additive cone hides whichever of its
own faces happens to be drawn second. The back copy (winding reversed) is drawn first in its own layer, the front copy
after it, both FORCECULLBACKFACES: the far wall of the beam and the near one both add, as the old two-sided cone did.
SKIN: alpha 255 everywhere (the HUD model's alpha test, gl_mask_threshold, would drop a faint texel); the fade is in the
colour, drawn additive (STYLE_Add) at the quality's alpha (torch.zs). u 0-0.25 outer cone, 0.25-0.5 inner cone, 0.5-1 the
hotspot (its top square).
"""
import math, os, random, struct, sys
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from gen_flare import unit, cross, M, GRIP_C, enc_n
from PIL import Image

# the flashlight in the hand mesh's space (gen_torch.py: torch space x = PUMP_AX, origin GRIP_C; the lens disc at GLOW_X)
PUMP_AX = (0.933, -0.250, 0.259)
GLOW_X = 10.9
K = 8.0                       # mesh units = hand-mesh cm / K
WS = 1.02                     # vr_weaponScale (QZD's default): hand-mesh cm -> metres is WS * 0.01 (geo.zs HandPoint)
VU = 34.0                     # vr_vunits_per_meter (default): the quality's range in map units -> metres
FRAMES = 24
LMIN = 0.25                   # metres: the shortest frame
SIZES = [(6, 14), (10, 22), (16, 32)]       # torch.zs SizeAngles (inner, outer)
RANGES = [448, 640, 896]                    # torch.zs Range by quality
PAL = [0xFFFFFF, 0xB3BDD1, 0xFFEB38, 0xFFBD2E, 0xFF7A14, 0xFF291A, 0xDB0A42, 0xFF80C2, 0xFF2EF2,
       0xC299FF, 0x943DFF, 0x3D66FF, 0x70C2FF, 0x14F2FF, 0x14CCA3, 0x33FF4D, 0xB8FF24]   # torch.zs Shade
WARM = 0xFFDCA8                                                                          # 20: Warm White


def lengths(range_units):
    """the frames' lengths in metres (log-spaced, the last = the quality's range)"""
    full = range_units / VU
    return [LMIN * (full / LMIN) ** (k / (FRAMES - 1)) for k in range(FRAMES)]


def frames_of(range_units):
    """(length, hotspot shown): the FRAMES lengths with the hotspot, then frame Y: the full range, nothing hit, no hotspot"""
    return [(L, True) for L in lengths(range_units)] + [(range_units / VU, False)]


def basis():
    x = unit(PUMP_AX); y = unit(cross((0, 0, 1), x)); z = cross(x, y)
    lens = tuple(GRIP_C[k] + x[k] * (GLOW_X + 0.3) for k in range(3))
    return lens, x, y, z


def cone_layer(sides, rings, half, rad_frac, length_m, u0, u1):
    """one cone (apex at the lens) cut at length_m metres: rings evenly along it, in hand-mesh units / K"""
    lens, ax, y, z = basis()
    L = length_m / (WS * 0.01) / K
    t = math.tan(math.radians(half)) * rad_frac
    lc = tuple(c / K for c in lens)
    pts, nrm, uvs = [], [], []
    for i in range(rings + 1):
        f = i / rings
        d = f * L; r = d * t
        for s in range(sides + 1):
            a = 2 * math.pi * s / sides
            ca, sa = math.cos(a), math.sin(a)
            pts.append(tuple(lc[k] + ax[k] * d + (y[k] * ca + z[k] * sa) * r for k in range(3)))
            nrm.append(unit(tuple(y[k] * ca + z[k] * sa - ax[k] * t for k in range(3))))
            uvs.append((u0 + (u1 - u0) * s / sides, f))
    tris = []
    for i in range(rings):
        for s in range(sides):
            a = i * (sides + 1) + s; b = a + 1; c = a + sides + 1; d = c + 1
            tris += [(a, b, c), (b, d, c)]
    return pts, nrm, uvs, tris


def disc_layer(half_outer, length_m, shown=True):
    lens, ax, y, z = basis()
    L = length_m / (WS * 0.01) / K
    r = L * math.tan(math.radians(half_outer)) * 0.75 if shown else 0.0
    lc = tuple(c / K for c in lens)
    c0 = tuple(lc[k] + ax[k] * L * 0.995 for k in range(3))
    sides = 16
    pts = [c0]; uvs = [(0.75, 0.25)]; back = tuple(-c for c in ax)
    for s in range(sides + 1):
        a = 2 * math.pi * s / sides
        pts.append(tuple(c0[k] + (y[k] * math.cos(a) + z[k] * math.sin(a)) * r for k in range(3)))
        uvs.append((0.75 + 0.25 * math.cos(a), 0.25 + 0.25 * math.sin(a)))
    tris = [(0, s + 2, s + 1) for s in range(sides)]
    return pts, [back] * len(pts), uvs, tris


def write(path, surfs_frames, nframes):
    """surfs_frames: [dict(name, uvs, tris, frames=[(pts, nrm)])] -> md3"""
    blobs = []
    for s in surfs_frames:
        nv, nt = len(s['uvs']), len(s['tris'])
        o_sh = 108; o_tri = o_sh + 68; o_st = o_tri + nt * 12; o_xyz = o_st + nv * 8; o_end = o_xyz + nv * 8 * nframes
        b = struct.pack('<4s64siiiiiiiiii', b'IDP3', s['name'].encode().ljust(64, b'\0'), 0, nframes, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += b'hudcone_c20.png'.ljust(64, b'\0') + struct.pack('<i', 0)
        b += b''.join(struct.pack('<3i', *t) for t in s['tris'])
        b += b''.join(struct.pack('<2f', *uv) for uv in s['uvs'])
        for pts, nrm in s['frames']:
            for p, n in zip(pts, nrm):
                b += struct.pack('<3hH', *(max(-32768, min(32767, round(c * 64))) for c in p), enc_n(n))
        blobs.append(b)
    frames = b''
    for f in range(nframes):
        pts = [p for s in surfs_frames for p in s['frames'][f][0]]
        lo = [min(p[k] for p in pts) for k in range(3)]; hi = [max(p[k] for p in pts) for k in range(3)]
        rad = max(math.sqrt(sum(c * c for c in p)) for p in pts)
        frames += struct.pack('<3f3f3ff16s', *lo, *hi, 0, 0, 0, rad, ('frame%d' % f).encode().ljust(16, b'\0'))
    o_surf = 108 + len(frames); o_eof = o_surf + sum(len(b) for b in blobs)
    hdr = struct.pack('<4si64siiiiiiiii', b'IDP3', 15, os.path.basename(path).encode().ljust(64, b'\0'), 0, nframes, 0, len(surfs_frames), 0, 108, o_surf, o_surf, o_eof)
    open(path, 'wb').write(hdr + frames + b''.join(blobs))
    mx = max(abs(c) for s in surfs_frames for fr in s['frames'] for p in fr[0] for c in p)
    print('%s: %d frames, %d surfaces, largest coordinate %.1f (md3 limit 511)' % (os.path.basename(path), nframes, len(surfs_frames), mx))


def flip(tris): return [(a, c, b) for a, b, c in tris]


def build(hi, quals):
    combos = [(si, q) for q in quals for si in range(len(SIZES))]
    layers = [(16, 13, 1.0, 0.0, 0.25), (16, 13, 0.5, 0.25, 0.5)] if hi else [(12, 8, 0.85, 0.0, 0.25)]
    surfs = {'f': [], 'b': []}
    for li, (sides, rings, rf, u0, u1) in enumerate(layers):
        frs = []
        for si, q in combos:
            half = sum(SIZES[si]) / 2.0
            for L, _ in frames_of(RANGES[q]):
                pts, nrm, uvs, tris = cone_layer(sides, rings, half, rf, L, u0, u1)
                frs.append((pts, nrm))
        surfs['f'].append(dict(name='cone%d' % li, uvs=uvs, tris=tris, frames=frs))
        surfs['b'].append(dict(name='cone%d' % li, uvs=uvs, tris=flip(tris), frames=[(p, [tuple(-c for c in n) for n in nn]) for p, nn in frs]))
    for rep in range(2):
        frs = []
        for si, q in combos:
            for L, shown in frames_of(RANGES[q]):
                pts, nrm, uvs, tris = disc_layer(SIZES[si][1], L, shown)
                frs.append((pts, nrm))
        surfs['f'].append(dict(name='hot%d' % rep, uvs=uvs, tris=tris, frames=frs))
    n = len(combos) * (FRAMES + 1)
    tag = 'hi' if hi else 'lo'
    for side in 'fb':
        write(os.path.join(M, 'hudcone_%s_%s.md3' % (tag, side)), surfs[side], n)
    return combos


def skins():
    W = H = 128
    rnd = random.Random(7)
    grain = [[0.9 + 0.1 * rnd.random() for i in range(W)] for j in range(H)]
    for idx, rgb in list(enumerate(PAL)) + [(20, WARM)]:
        col = ((rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255)
        im = Image.new('RGBA', (W, H)); px = im.load()
        for j in range(H):
            v = j / (H - 1)
            for i in range(W):
                if i < W // 2:
                    inner = i >= W // 4
                    b = (1 - v) ** (1.3 if inner else 1.8) * (0.75 if inner else 0.30)
                    b *= min(1.0, v * 12 + 0.25) * grain[j][i]
                elif j < H // 2:
                    r = math.hypot(i - (W * 0.75 - 0.5), j - (H * 0.25 - 0.5)) / (W * 0.25 - 0.5)
                    b = max(0.0, math.exp(-r * r * 3.2) - 0.04) * 0.75
                else:
                    b = 0.0
                b = max(0.0, min(1.0, b))
                px[i, j] = (int(col[0] * b), int(col[1] * b), int(col[2] * b), 255)
        im.save(os.path.join(M, 'hudcone_c%02d.png' % idx))
    print('hudcone_cNN.png: %d colours' % (len(PAL) + 1))


def modeldef(lo_combos, hi_combos):
    """the MODELDEF blocks (printed; MODELDEF.torch holds them): sprite QFZn (back) / QFYn (front), n = combo, frames A-X"""
    out = []
    for side, spr in (('b', 'QFZ'), ('f', 'QFY')):
        for tag, combos, base in (('lo', lo_combos, 0), ('hi', hi_combos, 3)):
            for ci, (si, q) in enumerate(combos):
                n = base + ci
                out.append('Model RSQFF_Torch\n{\n\tPath "models/rsqff"\n\tModel 1 "hudcone_%s_%s.md3"\n\tSkin 1 "hudcone_c20.png"\n'
                           '\tScale %.1f %.1f %.1f\n\tOffset 0.0 -24.0 -10.0\n\tFORCECULLBACKFACES\n' % (tag, side, -K, K, K))
                for k in range(FRAMES + 1):
                    out.append('\tFrameIndex %s%d %s 1 %d\n' % (spr, n, chr(65 + k), ci * (FRAMES + 1) + k))
                out.append('}\n')
    return ''.join(out)


def main():
    lo = build(False, [0])
    hi = build(True, [1, 2])
    skins()
    md = modeldef(lo, hi)
    open(os.path.join(HERE, 'src', 'hudcone_modeldef.txt'), 'w').write(md)
    for q, R in enumerate(RANGES):
        print('quality %d lengths (m): %s' % (q, ' '.join('%.2f' % L for L in lengths(R))))
    print('combo n: 0-2 Quest sizes 0-2; 3-5 PCVR sizes 0-2; 6-8 High sizes 0-2')


if __name__ == '__main__':
    main()
