#!/usr/bin/env python3
"""Generate RSQ_LaserSight's meshes and textures. Procedural, deterministic.

    python3 tools/gen_assets.py

  (the beam is not made here: it rides the gun as voxel rods, tools/gen_beams.py)
  models/rsqls/rslsread.md3  the range readout's quad
  sprites/rsqls/RSLGA0.png                  the pointer glow (a wide soft bloom)
  sprites/rsqls/RSLSA0.png   the spot: hot white centre, soft falloff, faint ring
  MODELDEF.txt               generated

Everything is WHITE: colour is the actor's translation at runtime, and additive
blending makes dark mean faint.
"""
import os, math, struct, zlib
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))

MD3_RADIUS = 256.0 # the frame radius written into the readout's MD3

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
        fr += struct.pack('<3f3f3ff', *mn, *mx, 0, 0, 0, MD3_RADIUS) + pad('f', 16)
    hl = 4 + 4 + 64 + 36
    out = b'IDP3' + struct.pack('<i', 15) + pad(name, 64) + struct.pack('<9i', 0, nf, 0, 1, 0, hl, hl + len(fr), hl + len(fr), hl + len(fr) + len(s)) + fr + bytes(s)
    open(path, 'wb').write(out); return len(out)

def main():
    md = os.path.join(ROOT, 'models', 'rsqls'); sd = os.path.join(ROOT, 'sprites', 'rsqls')
    os.makedirs(md, exist_ok=True); os.makedirs(sd, exist_ok=True)
    # The world-actor beam of v1-v3 is gone (it trailed the gun: the playsim moves it 35
    # times a second, the headset draws 72-90). Its files go with it.
    for old in ('rslsbeam.md3', 'rslsbeam.png', 'rslscore.md3', 'rslscorf.md3', 'rslshalo.md3',
                'rslshalf.md3', 'rslscore.png', 'rslshalo.png'):
        if os.path.exists(os.path.join(md, old)): os.remove(os.path.join(md, old))
    for f in os.listdir(sd):
        if f[:4] in ('RSLB', 'RSLH', 'RSLE'): os.remove(os.path.join(sd, f))
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
    # PHASE 3. The spread ring: a thin soft circle, radius 0.9 of the sprite, so a
    # sprite scaled to 2r/64 per axis outlines where the pellets can land.
    def ring_px(x, y):
        r = math.hypot(x - 31.5, y - 31.5) / 32.0
        c = int(255 * math.exp(-((r - 0.90) / 0.035) ** 2))
        return (c, c, c, c)
    png(os.path.join(sd, 'RSLRA0.png'), 64, 64, ring_px, grab=(32, 32))
    # The range readout: one flat quad (8 x 2 units, facing +X, double-sided) whose
    # skin is the canvas texture RSLRANGE (ANIMDEFS), written each frame by the UI.
    q = [(0.0, -4.0, 2.0), (0.0, 4.0, 2.0), (0.0, 4.0, 0.0), (0.0, -4.0, 0.0)]
    n = write_md3(os.path.join(md, 'rslsread.md3'), [q], [(0, 0), (1, 0), (1, 1), (0, 1)],
                  [(0, 1, 2), (0, 2, 3), (0, 2, 1), (0, 3, 2)], 'RSLRANGE', 'rslsread')
    print('rslsread.md3 %d bytes' % n)
    png(os.path.join(sd, 'RSLQA0.png'), 1, 1, lambda x, y: (0, 0, 0, 0))
    out = ['// GENERATED by tools/gen_assets.py -- edit that, not this.', '']
    out += ['// The range readout: its skin is the canvas texture RSLRANGE (ANIMDEFS).',
            'Model RSQLS_Readout', '{', '\tPath "models/rsqls"', '\tModel 0 "rslsread.md3"',
            '\tSkin 0 "RSLRANGE"', '\tScale 1.0 1.0 1.0', '\tUSEACTORPITCH', '\tCORRECTPIXELSTRETCH',
            '\tFrameIndex RSLQ A 0 0', '}', '']
    open(os.path.join(ROOT, 'MODELDEF.txt'), 'w').write('\n'.join(out))
    print('assets written')

if __name__ == '__main__':
    main()
