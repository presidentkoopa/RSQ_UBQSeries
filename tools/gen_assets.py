#!/usr/bin/env python3
"""Generate RSQ_LaserSight's meshes and textures. Procedural, deterministic.

    python3 tools/gen_assets.py

  models/rsqls/rslscore.md3 / rslscorf.md3  the beam's core, 3 crossed planes along
                                            +Z, 5 taper frames; the f = fade variant
  models/rsqls/rslshalo.md3 / rslshalf.md3  the halo, same shapes, wider
  models/rsqls/rslscore.png / rslshalo.png  bell across the width, fade along it
  sprites/rsqls/RSLGA0.png                  the pointer glow (a wide soft bloom)
  sprites/rsqls/RSLSA0.png   the spot: hot white centre, soft falloff, faint ring
  sprites/rsqls/RSLBA0.png   placeholder so the beam's sprite name exists
  MODELDEF.txt               generated

WHY THE BEAM IS AUTHORED ALONG +Z: an actor's Scale.X scales BOTH horizontal model
axes, Scale.Y only the vertical one. Along +Z, Scale.Y is the beam's exact LENGTH
and Scale.X its WIDTH, independently; the actor is pitched 90 degrees past the aim
to lay its up axis along the beam. One object, any length, depth-correct. Proven
in RSQ_DistanceGrab (D19) before it came here.

Everything is WHITE: colour is the actor's translation at runtime, and additive
blending makes dark mean faint.
"""
import os, math, struct, zlib
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))

BEAM_L = 256.0     # authored length; Scale.Y = distance / BEAM_L
CORE_W = 0.5       # half-widths at Scale.X 1, map units. Thinner than the grab's
HALO_W = 2.4       # beam: a gun laser is a thread, a Force pull is a rope
PLANES = 3

def pad(s, n):
    b = s.encode('ascii')[:n - 1]; return b + b'\0' * (n - len(b))

def png(path, w, h, px, grab=None):
    """RGBA PNG. grab=(x, y) writes ZDoom's grAb offset chunk: a sprite with no
    offset is anchored at its BOTTOM CENTRE, so the spot would sit above the
    point it marks. (32, 32) on a 64x64 centres it."""
    raw = b''.join(b'\0' + b''.join(bytes(px(x, y)) for x in range(w)) for y in range(h))
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    extra = chunk(b'grAb', struct.pack('>ii', *grab)) if grab else b''
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
                           + extra + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

def write_md3(path, frames, uvs, tris, skin, name):
    """frames: a list of vertex lists (same count, same order). UVs and triangles
    are shared by every frame -- only positions animate in MD3."""
    nv, nt, nf = len(frames[0]), len(tris), len(frames)
    ofs_sh = 4 + 64 + 40; ofs_tr = ofs_sh + 68; ofs_st = ofs_tr + nt * 12; ofs_xyz = ofs_st + nv * 8; ofs_end = ofs_xyz + nv * 8 * nf
    s = bytearray(b'IDP3' + pad(name, 64) + struct.pack('<10i', 0, nf, 1, nv, nt, ofs_tr, ofs_sh, ofs_st, ofs_xyz, ofs_end))
    s += pad(skin, 64) + struct.pack('<i', 0)
    for t in tris: s += struct.pack('<3i', *t)
    for u in uvs: s += struct.pack('<2f', *u)
    for verts in frames:
        for p in verts: s += struct.pack('<3hH', *[int(round(c * 64)) for c in p], 0)
    fr = b''
    for verts in frames:
        mn = [min(p[k] for p in verts) for k in range(3)]; mx = [max(p[k] for p in verts) for k in range(3)]
        fr += struct.pack('<3f3f3ff', *mn, *mx, 0, 0, 0, BEAM_L) + pad('f', 16)
    hl = 4 + 4 + 64 + 36
    out = b'IDP3' + struct.pack('<i', 15) + pad(name, 64) + struct.pack('<9i', 0, nf, 0, 1, 0, hl, hl + len(fr), hl + len(fr), hl + len(fr) + len(s)) + fr + bytes(s)
    open(path, 'wb').write(out); return len(out)

# THE BEAM, v2: core and halo are SEPARATE models, so the halo ("beam glow") has
# its own brightness -- UZDXREMA's Beam Glow slider. Each comes in TAPER frames
# (the far end's width as a share of the near end's) and in a FADE variant whose
# texture runs out toward the far end (UZDXREMA's Beam Fade Distance: the beam is
# drawn only so far and dies away there). MD3 frames share their UVs, so the fade
# needs its own mesh; the taper does not.
TAPERS = [1.0, 0.7, 0.45, 0.25, 0.1]

def beam_mesh(w, fade):
    frames, UV, T = [], [], []
    for ti, tp in enumerate(TAPERS):
        V = []
        for k in range(PLANES):
            a = math.pi * k / PLANES; dx, dy = math.cos(a) * w, math.sin(a) * w
            V += [(-dx, -dy, 0.0), (dx, dy, 0.0), (dx * tp, dy * tp, BEAM_L), (-dx * tp, -dy * tp, BEAM_L)]
            if ti == 0:
                b = 4 * k
                v0, v1 = (0.02, 0.98) if fade else (0.02, 0.02)
                UV += [(0.0, v0), (1.0, v0), (1.0, v1), (0.0, v1)]
                T += [(b, b + 1, b + 2), (b, b + 2, b + 3), (b, b + 2, b + 1), (b, b + 3, b + 2)]
        frames.append(V)
    return frames, UV, T

def skin_px(peak, sigma):
    def px(x, y):
        u = (x + 0.5) / 32.0; v = (y + 0.5) / 64.0
        across = math.exp(-((u - 0.5) / sigma) ** 2)
        along = 1.0 if v < 0.5 else max(0.0, 1.0 - ((v - 0.5) / 0.5) ** 1.5)
        c = int(min(255, peak * across * along))
        return (c, c, c, 255)
    return px

def main():
    md = os.path.join(ROOT, 'models', 'rsqls'); sd = os.path.join(ROOT, 'sprites', 'rsqls')
    os.makedirs(md, exist_ok=True); os.makedirs(sd, exist_ok=True)
    for old in ('rslsbeam.md3', 'rslsbeam.png'):
        if os.path.exists(os.path.join(md, old)): os.remove(os.path.join(md, old))
    for nm, w, fade in (('rslscore', CORE_W, False), ('rslscorf', CORE_W, True),
                        ('rslshalo', HALO_W, False), ('rslshalf', HALO_W, True)):
        fr, UV, T = beam_mesh(w, fade)
        skin = 'rslscore.png' if nm.startswith('rslsc') else 'rslshalo.png'
        n = write_md3(os.path.join(md, nm + '.md3'), fr, UV, T, skin, nm)
        print('%s.md3 %d bytes, %d frames' % (nm, n, len(fr)))
    png(os.path.join(md, 'rslscore.png'), 32, 64, skin_px(300, 0.16))
    png(os.path.join(md, 'rslshalo.png'), 32, 64, skin_px(110, 0.30))
    # The spot: what a real laser dot looks like on a surface -- a small blown-out
    # centre, a soft bloom, and a faint ring (the speckle halo).
    def spot_px(x, y):
        r = math.hypot(x - 31.5, y - 31.5) / 32.0
        core = math.exp(-(r / 0.10) ** 2)
        bloom = 0.55 * math.exp(-(r / 0.32) ** 2)
        ring = 0.10 * math.exp(-((r - 0.62) / 0.06) ** 2)
        c = int(255 * min(1.0, core * 1.4 + bloom + ring))
        return (c, c, c, c)
    png(os.path.join(sd, 'RSLSA0.png'), 64, 64, spot_px, grab=(32, 32))
    # The pointer's GLOW: a wide soft bloom drawn round the spot (UZDXREMA's
    # "point" glow, beside the real dynamic light).
    def glow_px(x, y):
        r = math.hypot(x - 31.5, y - 31.5) / 32.0
        c = int(255 * max(0.0, math.exp(-(r / 0.45) ** 2) - 0.02))
        return (c, c, c, c)
    png(os.path.join(sd, 'RSLGA0.png'), 64, 64, glow_px, grab=(32, 32))
    # Placeholders: MODELDEF only draws a frame some state names, and a state can
    # only name a sprite whose lump exists.
    nfr = 2 * len(TAPERS)
    for spr in ('RSLB', 'RSLH', 'RSLE'):
        for f in range(nfr):
            png(os.path.join(sd, '%s%s0.png' % (spr, chr(65 + f))), 1, 1, lambda x, y: (0, 0, 0, 0))
    out = ['// GENERATED by tools/gen_assets.py -- edit that, not this.',
           '// The beam: core, halo and the emissive second core. Authored along +Z:',
           '// Scale.Y is its length, Scale.X its width. Frames A-E are the taper levels',
           '// (%s), F-J the same with the fade-out texture.' % ', '.join(str(t) for t in TAPERS),
           '// CORRECTPIXELSTRETCH: authored and aimed in ROOM space (see the handler).', '']
    for cls, spr, a, b, skin in (('RSQLS_Beam', 'RSLB', 'rslscore', 'rslscorf', 'rslscore.png'),
                                 ('RSQLS_Emissive', 'RSLE', 'rslscore', 'rslscorf', 'rslscore.png'),
                                 ('RSQLS_Halo', 'RSLH', 'rslshalo', 'rslshalf', 'rslshalo.png')):
        out += ['Model %s' % cls, '{', '\tPath "models/rsqls"',
                '\tModel 0 "%s.md3"' % a, '\tSkin 0 "%s"' % skin,
                '\tModel 1 "%s.md3"' % b, '\tSkin 1 "%s"' % skin,
                '\tScale 1.0 1.0 1.0', '\tUSEACTORPITCH', '\tCORRECTPIXELSTRETCH']
        for i in range(len(TAPERS)):
            out.append('\tFrameIndex %s %s 0 %d' % (spr, chr(65 + i), i))
        for i in range(len(TAPERS)):
            out.append('\tFrameIndex %s %s 1 %d' % (spr, chr(65 + len(TAPERS) + i), i))
        out += ['}', '']
    open(os.path.join(ROOT, 'MODELDEF.txt'), 'w').write('\n'.join(out))
    print('assets written')

if __name__ == '__main__':
    main()
