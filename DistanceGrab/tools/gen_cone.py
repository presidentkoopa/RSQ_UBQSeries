#!/usr/bin/env python3
"""Generate the grab-cone model. Procedural, deterministic, no Blender.

    python3 tools/gen_cone.py

Writes
  models/rsqdg/rsqcone.md3    one frame per degree of HALF-angle, 1..48
  models/rsqdg/rsqcone.png    the skin: left half bright (wire), right half dim (shell)
  MODELDEF.txt                the frame table (generated -- edit this script, not that)
  sprites/rsqdg/RSQC*.png ... 1x1 transparent placeholders so the sprite names exist
  tools/rsqcone_12deg.obj     one frame as OBJ, for looking at in any viewer

THE GEOMETRY IS DXR's. DXR drew its grab-reach cone in C++ every rendered frame
(src/rendering/hwrenderer/scene/hw_weapon.cpp, DrawDebugWireCone +
DrawDebugSolidCone): 4 lines apex -> rim, 2 rings (half way and at the rim) of 8
segments, every edge a thin tube; and a faint additive filled shell over it.
Stock QuestZDoom has no line or tube primitive a mod can reach, so the same shape
is baked into a mesh here and drawn as a model.

ONE FRAME PER DEGREE, because the cone's WIDTH and LENGTH must scale
independently and an actor's scale cannot: Scale.X drives both horizontal model
axes. So each frame is a cone of length L at one half-angle, the actor picks the
frame from rsqdg_spread, and scales UNIFORMLY by reach / L. Exact for every
integer spread; the menu slider steps by 1.

AUTHORED IN ROOM PROPORTIONS. MODELDEF sets CORRECTPIXELSTRETCH, which applies
Doom's 1.2 vertical stretch in WORLD space after the model is rotated (r_data/
models.cpp), so a round cone stays round at any pitch -- and that is exactly the
cone cone.zs tests, which scales Z by pixelstretch before measuring.

The bore is +X (MD3 forward), apex at the origin. MODELDEF uses USEACTORPITCH, so
the actor's angle and pitch aim it like a missile.
"""
import os, math, struct, zlib

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..'))

L = 256.0                 # authored length; the actor scales by reach / L
REF_REACH = 512.0         # the reach at which the tube radius below is true
TUBE_R = 0.55             # map units at REF_REACH (DXR used 0.4 -- a touch more
                          # here because a model has no anti-aliased line width)
TUBE_SIDES = 4
LON_LINES = 4             # DXR
RINGS = 2                 # DXR: half way and the rim
RING_SEGS = 8             # DXR
SHELL_SLICES = 20         # DXR's solid cone
MIN_DEG, MAX_DEG = 1, 48

SPRITES = ['RSQC', 'RSQE']   # 26 frames each: RSQC A..Z = 1..26 deg, RSQE A.. = 27..
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# UVs into the skin: the wire samples the left half, the shell the right; V runs
# ALONG THE CONE, apex (0) to rim (1), and the skin fades in along V. Found in the
# rig, 2026-10-26: the four edge tubes converge at the palm, so near the eye they
# read as thick bright stripes crowding the beam. Faded out at the hand and full
# by FADE_IN of the reach, the cone shows the VOLUME out in the room and stays out
# of your face.
U_WIRE, U_SHELL = 0.25, 0.75
FADE_IN = 0.30


def v_add(a, b): return (a[0] + b[0], a[1] + b[1], a[2] + b[2])
def v_sub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def v_mul(a, s): return (a[0] * s, a[1] * s, a[2] * s)
def v_len(a): return math.sqrt(a[0] ** 2 + a[1] ** 2 + a[2] ** 2)
def v_norm(a):
    l = v_len(a)
    return (a[0] / l, a[1] / l, a[2] / l) if l > 1e-9 else (0.0, 0.0, 1.0)
def v_cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def right_up(d):
    """Two unit vectors perpendicular to d (and to each other)."""
    ref = (0.0, 0.0, 1.0) if abs(d[2]) < 0.9 else (0.0, 1.0, 0.0)
    r = v_norm(v_cross(d, ref))
    u = v_cross(r, d)
    return r, u


def cone_frame(half_deg):
    """Vertices and triangles for one half-angle. Same topology every frame (MD3
    requires it), so only positions change."""
    verts, uvs, tris = [], [], []
    tube_r = TUBE_R * L / REF_REACH          # in authored units
    rim_r = L * math.tan(math.radians(half_deg))

    def rim_point(t, ang):
        return (L * t, math.cos(ang) * rim_r * t, math.sin(ang) * rim_r * t)

    def tube(a, b):
        d = v_norm(v_sub(b, a))
        r, u = right_up(d)
        base = len(verts)
        for end in (a, b):
            for k in range(TUBE_SIDES):
                ang = 2 * math.pi * k / TUBE_SIDES
                off = v_add(v_mul(r, math.cos(ang) * tube_r), v_mul(u, math.sin(ang) * tube_r))
                verts.append(v_add(end, off))
                uvs.append((U_WIRE, max(0.0, min(1.0, end[0] / L))))
        for k in range(TUBE_SIDES):
            k2 = (k + 1) % TUBE_SIDES
            a0, a1 = base + k, base + k2
            b0, b1 = base + TUBE_SIDES + k, base + TUBE_SIDES + k2
            tris.append((a0, b0, a1)); tris.append((a1, b0, b1))

    apex = (0.0, 0.0, 0.0)
    for i in range(LON_LINES):
        tube(apex, rim_point(1.0, 2 * math.pi * i / LON_LINES))
    for rr in range(1, RINGS + 1):
        t = rr / RINGS
        for i in range(RING_SEGS):
            tube(rim_point(t, 2 * math.pi * i / RING_SEGS),
                 rim_point(t, 2 * math.pi * (i + 1) / RING_SEGS))

    # The shell: lateral surface apex -> rim, and the base cap -- BOTH WINDINGS,
    # so it shows from inside the cone (where your eye usually is: the apex is
    # in your hand) as well as from outside, whatever the renderer culls.
    base = len(verts)
    verts.append(apex); uvs.append((U_SHELL, 0.0))
    cap_c = len(verts)
    verts.append((L, 0.0, 0.0)); uvs.append((U_SHELL, 1.0))
    ring0 = len(verts)
    for j in range(SHELL_SLICES):
        verts.append(rim_point(1.0, 2 * math.pi * j / SHELL_SLICES)); uvs.append((U_SHELL, 1.0))
    for j in range(SHELL_SLICES):
        p, q = ring0 + j, ring0 + (j + 1) % SHELL_SLICES
        tris.append((base, p, q)); tris.append((base, q, p))
        tris.append((cap_c, q, p)); tris.append((cap_c, p, q))
    return verts, uvs, tris


def enc_normal(n):
    n = v_norm(n)
    lat = int(round(math.degrees(math.acos(max(-1, min(1, n[2])))) * 255 / 360)) & 255
    lng = int(round(math.degrees(math.atan2(n[1], n[0])) * 255 / 360)) & 255
    return (lat << 8) | lng


def pad(s, n):
    b = s.encode('ascii')[:n - 1]
    return b + b'\0' * (n - len(b))


def write_md3(path, frames, uvs, tris, skin_name):
    nf, nv, nt = len(frames), len(frames[0]), len(tris)
    # surface
    s_hdr = 4 + 64 + 4 * 10
    ofs_shaders = s_hdr
    ofs_tris = ofs_shaders + 68
    ofs_st = ofs_tris + nt * 12
    ofs_xyz = ofs_st + nv * 8
    ofs_send = ofs_xyz + nf * nv * 8
    surf = bytearray()
    surf += b'IDP3' + pad('cone', 64)
    surf += struct.pack('<10i', 0, nf, 1, nv, nt, ofs_tris, ofs_shaders, ofs_st, ofs_xyz, ofs_send)
    surf += pad(skin_name, 64) + struct.pack('<i', 0)
    for t in tris: surf += struct.pack('<3i', *t)
    for (s, t) in uvs: surf += struct.pack('<2f', s, t)
    for fv in frames:
        for p in fv:
            q = [int(round(c * 64)) for c in p]
            assert all(-32768 <= c <= 32767 for c in q), 'vertex out of MD3 range'
            # a radial normal is plenty for an additive fullbright mesh
            surf += struct.pack('<3hH', q[0], q[1], q[2], enc_normal(p if v_len(p) > 1e-6 else (1, 0, 0)))
    assert len(surf) == ofs_send
    # frames
    fr = bytearray()
    for i, fv in enumerate(frames):
        mn = [min(p[k] for p in fv) for k in range(3)]
        mx = [max(p[k] for p in fv) for k in range(3)]
        rad = max(v_len(p) for p in fv)
        fr += struct.pack('<3f3f3ff', *mn, *mx, 0, 0, 0, rad) + pad('deg%d' % (MIN_DEG + i), 16)
    hdr_len = 4 + 4 + 64 + 4 * 9
    ofs_frames = hdr_len
    ofs_tags = ofs_frames + len(fr)
    ofs_surf = ofs_tags
    ofs_end = ofs_surf + len(surf)
    out = bytearray()
    out += b'IDP3' + struct.pack('<i', 15) + pad('rsqcone', 64)
    out += struct.pack('<9i', 0, nf, 0, 1, 0, ofs_frames, ofs_tags, ofs_surf, ofs_end)
    out += fr + surf
    with open(path, 'wb') as f: f.write(out)
    return len(out)


def png(path, w, h, pixel):
    """Minimal RGBA PNG writer. pixel(x, y) -> (r, g, b, a)."""
    raw = b''.join(b'\0' + b''.join(bytes(pixel(x, y)) for x in range(w)) for y in range(h))
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    data = (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))
    with open(path, 'wb') as f: f.write(data)


# ---------------------------------------------------------------------------
# THE BEAM. Three crossed planes around +Z, each a soft gradient across its
# width: from any angle but straight down the bore it reads as a solid shaft of
# light (the lightsaber-blade trick). Two widths in one mesh: a thin bright CORE
# and a wide dim HALO.
#
# WHY +Z AND NOT +X: an actor's Scale.X scales BOTH horizontal model axes but
# Scale.Y scales only the vertical one. Authored along +Z, Scale.Y is the beam's
# LENGTH and Scale.X its WIDTH, independently -- and the actor is pitched 90
# degrees past the hand so its up axis lies along the aim (laser.zs).
# ---------------------------------------------------------------------------
BEAM_L = 256.0            # authored length; Scale.Y = hit distance / BEAM_L
CORE_W = 0.8              # half-width at Scale.X 1, map units
HALO_W = 3.2
PLANES = 3

def beam_mesh():
    verts, uvs, tris = [], [], []
    for (w, vrow) in ((CORE_W, 0.25), (HALO_W, 0.75)):
        for k in range(PLANES):
            ang = math.pi * k / PLANES
            dx, dy = math.cos(ang) * w, math.sin(ang) * w
            b = len(verts)
            verts += [(-dx, -dy, 0.0), (dx, dy, 0.0), (dx, dy, BEAM_L), (-dx, -dy, BEAM_L)]
            uvs += [(0.0, vrow), (1.0, vrow), (1.0, vrow), (0.0, vrow)]
            tris += [(b, b + 1, b + 2), (b, b + 2, b + 3), (b, b + 2, b + 1), (b, b + 3, b + 2)]
    return verts, uvs, tris


def frame_sprite(deg):
    i = deg - MIN_DEG
    return SPRITES[i // 26], LETTERS[i % 26]


def main():
    mdir = os.path.join(ROOT, 'models', 'rsqdg'); os.makedirs(mdir, exist_ok=True)
    sdir = os.path.join(ROOT, 'sprites', 'rsqdg'); os.makedirs(sdir, exist_ok=True)

    frames, uvs, tris = [], None, None
    for deg in range(MIN_DEG, MAX_DEG + 1):
        v, uv, t = cone_frame(deg)
        if tris is None: uvs, tris = uv, t
        assert len(t) == len(tris)
        frames.append(v)
    n = write_md3(os.path.join(mdir, 'rsqcone.md3'), frames, uvs, tris, 'rsqcone.png')
    print('rsqcone.md3  %d frames  %d verts  %d tris  %d bytes' % (len(frames), len(frames[0]), len(tris), n))

    # Skin: neutral WHITE wire, dim grey shell. Colour comes from the actor's
    # translation at runtime (the same % tints the object flash uses), and the
    # additive style means dark = faint: the shell's grey IS its opacity.
    def cone_px(x, y):
        v = (y + 0.5) / 64.0                       # 0 at the apex, 1 at the rim
        k = min(1.0, max(0.0, v / FADE_IN)) ** 1.5  # eased fade-in from the hand
        c = int((255 if x < 8 else 22) * k)
        return (c, c, c, 255)
    png(os.path.join(mdir, 'rsqcone.png'), 16, 64, cone_px)

    # Placeholder sprite lumps: the sprite names must exist for the states that
    # use them. Never drawn -- the model replaces them.
    used = set()
    for deg in range(MIN_DEG, MAX_DEG + 1):
        s, l = frame_sprite(deg); used.add((s, l))
    for s, l in sorted(used):
        png(os.path.join(sdir, '%s%s0.png' % (s, l)), 1, 1, lambda x, y: (0, 0, 0, 0))

    # MODELDEF. One Model block per sprite name; FrameIndex maps each letter to
    # its frame of the one MD3.
    lines = ['// GENERATED by tools/gen_cone.py -- edit that, not this.',
             '//',
             '// The grab cone. One MD3 frame per degree of half-angle; the actor picks',
             '// the frame from rsqdg_spread and scales uniformly by reach / %d.' % int(L),
             '// CORRECTPIXELSTRETCH keeps it round at any pitch (see the generator).',
             '']
    for si, sname in enumerate(SPRITES):
        degs = [d for d in range(MIN_DEG, MAX_DEG + 1) if frame_sprite(d)[0] == sname]
        if not degs: continue
        lines += ['Model RSQDG_ConeViz', '{',
                  '\tPath "models/rsqdg"',
                  '\tModel 0 "rsqcone.md3"',
                  '\tSkin 0 "rsqcone.png"',
                  '\tScale 1.0 1.0 1.0',
                  '\tUSEACTORPITCH',
                  '\tCORRECTPIXELSTRETCH',
                  '\t// no IGNORETRANSLATION: the translation carries the state colour',
                  '']
        for d in degs:
            s, l = frame_sprite(d)
            lines.append('\tFrameIndex %s %s 0 %d' % (s, l, d - MIN_DEG))
        lines += ['}', '']
    with open(os.path.join(ROOT, 'MODELDEF.txt'), 'w') as f: f.write('\n'.join(lines))
    print('MODELDEF.txt written')

    # ---- the beam ----
    bv, buv, bt = beam_mesh()
    nb = write_md3(os.path.join(mdir, 'rsqbeam.md3'), [bv], buv, bt, 'rsqbeam.png')
    print('rsqbeam.md3  %d verts  %d tris  %d bytes' % (len(bv), len(bt), nb))
    # Skin: a soft bell across the width (u), core row bright, halo row dim.
    # White: the state colour is the actor's translation; additive, so dark = faint.
    def beam_px(x, y):
        u = (x + 0.5) / 32.0
        bell = math.exp(-((u - 0.5) / 0.18) ** 2)
        if y < 4: c = int(255 * min(1.0, bell * 1.15))          # core
        else:     c = int(110 * math.exp(-((u - 0.5) / 0.30) ** 2))  # halo
        return (c, c, c, 255)
    png(os.path.join(mdir, 'rsqbeam.png'), 32, 8, beam_px)
    png(os.path.join(sdir, 'RSQBA0.png'), 1, 1, lambda x, y: (0, 0, 0, 0))
    with open(os.path.join(ROOT, 'MODELDEF.txt'), 'a') as f:
        f.write('\n'.join(['',
            '// The beam. Authored along +Z: Scale.Y is its length, Scale.X its width.',
            'Model RSQDG_Beam', '{',
            '\tPath "models/rsqdg"',
            '\tModel 0 "rsqbeam.md3"',
            '\tSkin 0 "rsqbeam.png"',
            '\tScale 1.0 1.0 1.0',
            '\tUSEACTORPITCH',
            '\tUSEACTORROLL',
            '\tCORRECTPIXELSTRETCH',
            '\tFrameIndex RSQB A 0 0',
            '}', '']))

    # A reference OBJ of one frame (12 degrees, the default spread).
    v, uv, t = cone_frame(12)
    with open(os.path.join(HERE, 'rsqcone_12deg.obj'), 'w') as f:
        f.write('# RSQ_DistanceGrab grab cone, half-angle 12 deg, length %d (bore +X)\n' % int(L))
        f.write('o rsqcone\n')
        for p in v: f.write('v %.4f %.4f %.4f\n' % p)
        for q in uv: f.write('vt %.4f %.4f\n' % q)
        for a, b, c in t: f.write('f %d/%d %d/%d %d/%d\n' % (a + 1, a + 1, b + 1, b + 1, c + 1, c + 1))
    print('rsqcone_12deg.obj written')


if __name__ == '__main__':
    main()
