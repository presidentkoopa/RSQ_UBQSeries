#!/usr/bin/env python3
"""RSQ Wheel: the whip card's icon, drawn from scratch (owner 2026-11-03: an ORIGINAL brown coiled whip in the same
chunky pixel-art style as the lightsaber card; no existing game sprite copied or traced).

Every pixel is decided here, on a 96x96 grid (the lightsaber icon's own art grid is 98x98):
  * the whip is a list of path samples (x, y, half-width, depth, part): a short wrapped handle with a knob, the
    thong running into three loops of coil, and a tail that tapers down to a thin cracker;
  * each pixel takes the TOPMOST sample within its half-width (depth: a loop's near half is in front of its far
    half, later loops over earlier ones), and is shaded by where it sits across the strap (lit from the top left);
  * a one-pixel dark outline goes round the whole shape, and wherever a nearer strand crosses over a farther one,
    so the coil reads as overlapping leather.
Writes Wheel/sources/icons/whip_icon.png and Wheel/graphics/WRIWHIP.png (the same image), and, with --preview,
whip_icon_4x.png (nearest-neighbour 4x) beside this script.
Run: python3 Wheel/sources/icons/gen_whip_icon.py [--preview]"""
import math, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
WHEEL = os.path.dirname(os.path.dirname(HERE))
N = 96

# brown leather, darkest to lightest, and the outline
OUTLINE = (34, 18, 8)
LEATHER = [(78, 42, 18), (112, 64, 28), (148, 90, 44), (186, 124, 66), (220, 168, 106)]
WRAP_DARK = (64, 34, 14)
CRACKER = [(150, 124, 86), (196, 172, 130), (230, 214, 178)]


def lerp(a, b, t):
    return a + (b - a) * t


def path():
    """(x, y, half-width, depth, part, u) samples along the whip, handle first; u = 0..1 along each part"""
    s = []
    # HANDLE: bottom left, up to the right, like the saber's hilt
    hx0, hy0, hx1, hy1 = 12.0, 86.0, 31.0, 64.0
    for i in range(41):
        t = i / 40
        s.append((lerp(hx0, hx1, t), lerp(hy0, hy1, t), 4.6, 10.0, 'handle', t))
    # KNOB on the butt end
    s.append((hx0 - 1.5, hy0 + 1.8, 5.6, 10.5, 'knob', 0))
    # THONG into the coil: from the handle's top to the first loop
    cx, cy = 48.0, 37.0
    loops = [(24.0, 17.0), (23.0, 16.0), (22.0, 15.0)]   # rx, ry per loop
    tilt = math.radians(-22)
    def coil_pt(k, th):
        rx, ry = loops[k]
        ox, oy = cx + k * 7.5, cy - k * 1.0           # each loop lies a strap's width further over

        x, y = rx * math.cos(th), ry * math.sin(th)
        return ox + x * math.cos(tilt) - y * math.sin(tilt), oy + x * math.sin(tilt) + y * math.cos(tilt)
    start = math.radians(155)
    sx, sy = coil_pt(0, start)
    for i in range(1, 25):
        t = i / 24
        # a gentle bend from the handle tip to the coil's start
        bx = lerp(hx1, sx, t) - 6 * math.sin(math.pi * t)
        by = lerp(hy1, sy, t) - 3 * math.sin(math.pi * t)
        s.append((bx, by, 3.4, 9.0, 'thong', t))
    # COIL: three loops; the near half (sin > 0, the bottom) is in front of the far half
    steps = 220
    for k in range(3):
        for i in range(steps + 1):
            th = start + 2 * math.pi * i / steps
            x, y = coil_pt(k, th)
            if k < 2 and i == steps:
                continue
            depth = k * 0.5 + math.sin(th) * 2.0
            s.append((x, y, 2.9, depth, 'coil', (k + i / steps) / 3))
    # TAIL: off the last loop, down to the bottom right, tapering, with one lazy S
    tx, ty = coil_pt(2, start + 2 * math.pi)
    ex, ey = 86.0, 90.0
    n = 90
    for i in range(1, n + 1):
        t = i / n
        x = lerp(tx, ex, t) + 7 * math.sin(math.pi * 1.6 * t) * (1 - t)
        y = lerp(ty, ey, t) + 2 * math.sin(math.pi * t)
        hw = lerp(2.9, 0.7, t ** 0.8)
        s.append((x, y, hw, 12.0 - t, 'tail', t))
    # CRACKER: a short pale tuft at the very end
    for i in range(1, 7):
        t = i / 6
        s.append((ex + 2.0 * t, ey + 2.5 * t, 0.9, 11.0, 'cracker', t))
    return s


def draw():
    S = path()
    # per pixel: the topmost covering sample
    top = [[None] * N for _ in range(N)]
    for (x, y, hw, z, part, u) in S:
        # across-the-strap direction from the neighbouring samples is approximated per pixel below
        r = int(math.ceil(hw)) + 1
        for py in range(max(0, int(y) - r), min(N, int(y) + r + 1)):
            for px in range(max(0, int(x) - r), min(N, int(x) + r + 1)):
                dx, dy = px + 0.5 - x, py + 0.5 - y
                d = math.hypot(dx, dy)
                if d > hw:
                    continue
                cur = top[py][px]
                if cur is None or z > cur[0] + 1e-6 or (abs(z - cur[0]) <= 1e-6 and d < cur[1]):
                    top[py][px] = (z, d, hw, dx, dy, part, u)
    im = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    px_ = im.load()
    lx, ly = -0.70, -0.71   # light from the top left
    for py in range(N):
        for px in range(N):
            c = top[py][px]
            if c is None:
                continue
            z, d, hw, dx, dy, part, u = c
            # where across the strap: -1 on the lit side, +1 on the shadow side
            across = 0.0 if d < 1e-6 else (dx * lx + dy * ly) / max(hw, 0.8) * -1.0
            if part == 'cracker':
                col = CRACKER[1 if across > 0 else 2]
            elif part == 'knob':
                col = LEATHER[1] if across > -0.2 else LEATHER[2]
                if d > hw - 1.6 and across > 0.2: col = LEATHER[0]
            elif part == 'handle':
                # the wrap: diagonal bands across the grip, every 4 pixels along it
                band = int(u * 40) % 5
                if band == 0:
                    col = WRAP_DARK
                else:
                    col = LEATHER[3] if across < -0.35 else (LEATHER[2] if across < 0.35 else LEATHER[1])
            else:
                if across < -0.55: col = LEATHER[4] if hw > 2.2 else LEATHER[3]
                elif across < -0.1: col = LEATHER[3]
                elif across < 0.45: col = LEATHER[2]
                else: col = LEATHER[1]
                if part == 'coil' and z < 0:   # the far half of a loop sits in shade
                    col = LEATHER[max(0, LEATHER.index(col) - 1)]
            px_[px, py] = col + (255,)
    # OUTLINE 1: where a nearer strand lies over a farther one, the farther one's edge pixel goes dark
    out = im.copy()
    po = out.load()
    for py in range(N):
        for px in range(N):
            c = top[py][px]
            if c is None or c[5] in ('cracker',):
                continue
            for qx, qy in ((px + 1, py), (px - 1, py), (px, py + 1), (px, py - 1)):
                if 0 <= qx < N and 0 <= qy < N and top[qy][qx] is not None:
                    o = top[qy][qx]
                    other = o[5] != c[5] or abs(o[6] - c[6]) > 0.08   # another stretch of the whip
                    if other and o[0] > c[0] and o[5] != 'cracker':
                        po[px, py] = OUTLINE + (255,)
                        break
    # OUTLINE 2: round the whole shape (8-neighbour, so diagonals stay closed)
    final = out.copy()
    pf = final.load()
    for py in range(N):
        for px in range(N):
            if po[px, py][3]:
                continue
            for qx in (px - 1, px, px + 1):
                for qy in (py - 1, py, py + 1):
                    if 0 <= qx < N and 0 <= qy < N and po[qx, qy][3]:
                        pf[px, py] = OUTLINE + (255,)
                        break
                else:
                    continue
                break
    return final


def main():
    im = draw()
    im = im.crop(im.getbbox())
    im.save(os.path.join(HERE, 'whip_icon.png'))
    im.save(os.path.join(WHEEL, 'graphics', 'WRIWHIP.png'))
    if '--preview' in sys.argv:
        im.resize((im.width * 4, im.height * 4), Image.NEAREST).save(os.path.join(HERE, 'whip_icon_4x.png'))
    print('whip icon', im.size)


if __name__ == '__main__':
    main()
