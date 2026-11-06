#!/usr/bin/env python3
"""gen_pcvr_beam.py -- the textures of Beam Look: PCVR (owner 2026-11-06, BUGS_1.0 #42: "kickass lasers").

The look the owner asked for is Unreal 1's (1998) liquid: a small procedurally rippled texture, semi-transparent,
with a bright caustic sheet scrolling over it. Everything here is GREY: the laser's colour comes from a translation
(colors.zs: the texel's brightness times twice the chosen colour), so one texture serves every colour setting.

Texture layout (the arc segment's skin, rslsseg.md3): u (x) runs ACROSS the beam, v (y) ALONG it, one repeat per
segment. Every field below tiles in x, y and (for the flipbook) time, so segments join and the loop has no seam.

    python3 tools/gen_pcvr_beam.py <out dir> [a] [b] [c]

  a  rslspcva.png       the liquid sheet alone (64x64); the GLDEFS material shader (shaders/rsqls_beam.fp) ripples
                        it, scrolls a caustic copy over it and draws the bright core across the beam, in real time
  b  rslspcvb.png       core x (liquid + caustic) baked (64x64), for ANIMDEFS warp2
  c  rslspf00..15.png   16 looping frames of the same, rippling and flowing down the beam (64x64 each)
"""
import math, os, struct, sys, zlib

N = 64
FRAMES = 16
TAU = 2 * math.pi


def png(path, w, h, px):
    raw = b''.join(b'\0' + b''.join(bytes(px(x, y)) for x in range(w)) for y in range(h))
    def chunk(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
                           + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


# Integer wave vectors and integer time rates: every term tiles in x and y, and loops once over t in 0..1.
LIQ = [((1, 2), 1, 0.3), ((-2, 1), -1, 1.7), ((3, -1), 2, 4.1), ((1, 3), -2, 2.6), ((-3, -2), 1, 5.2)]
CAU = [((2, 3), 2), ((-3, 2), -1), ((1, -4), 1)]


def liquid(x, y, t):
    """The water: soft crossing swells, 0..1."""
    s = 0.0
    for (kx, ky), n, ph in LIQ:
        s += math.sin(TAU * (kx * x + ky * y + n * t) + ph)
    return 0.5 + 0.5 * s / len(LIQ)


def caustic(x, y, t):
    """The caustic sheet: thin bright ridges where three waves cancel, 0..1 (UE1's 'bright net')."""
    s = 0.0
    for (kx, ky), n in CAU:
        s += math.sin(TAU * (kx * x + ky * y + n * t))
    return (1.0 - min(1.0, abs(s) / 1.5)) ** 6


def core(x):
    """Across the beam: bright down the middle, soft edges (today's seg skin: exp(-(r/0.45)^2))."""
    r = abs(x - 0.5) / 0.5
    return math.exp(-(r / 0.45) ** 2)


def grey(v, a=None):
    """Brightness v; alpha a (default v). Drawn additive, the engine's alpha test throws away texels under its
    threshold, so a baked beam keeps its alpha on the core profile and carries the ripple in its brightness."""
    c = int(255 * max(0.0, min(1.0, v)))
    return (c, c, c, c if a is None else int(255 * max(0.0, min(1.0, a))))


def baked(x, y, t):
    """The whole living beam at time t: the sheet rippled (UE1 water: coordinates pushed by sines), flowing down the
    beam, with the caustic sheet over it flowing faster."""
    rx = x + 0.04 * math.sin(TAU * (2 * y + t)) + 0.03 * math.sin(TAU * (3 * y - 2 * t))
    ry = y + 0.05 * math.sin(TAU * (x + t))
    l = liquid(rx, ry - t, t)
    c = caustic(rx, ry - 2 * t, t)
    return core(x) * min(1.0, 0.25 + 0.55 * l + 0.9 * c)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'models', 'rsqls')
    which = set(sys.argv[2:]) or {'a', 'b', 'c'}
    os.makedirs(out, exist_ok=True)
    if 'a' in which:
        # The sheet the shader works on: liquid with the caustic net in it, never darker than 0.35 so the colour
        # always shows through (the shader multiplies, it cannot add colour where the sheet is black).
        png(os.path.join(out, 'rslspcva.png'), N, N,
            lambda x, y: grey(0.35 + 0.45 * liquid(x / N, y / N, 0) + 0.4 * caustic(x / N, y / N, 0)))
    if 'b' in which:
        png(os.path.join(out, 'rslspcvb.png'), N, N, lambda x, y: grey(baked(x / N, y / N, 0), core(x / N) ** 0.5))
    if 'c' in which:
        for f in range(FRAMES):
            png(os.path.join(out, 'rslspf%02d.png' % f), N, N, lambda x, y, f=f: grey(baked(x / N, y / N, f / FRAMES), core(x / N) ** 0.5))
    print('written to', out, sorted(which))


if __name__ == '__main__':
    main()
