#!/usr/bin/env python3
"""RSQ Wheel: the ShieldSaw card's icon, drawn from scratch (owner 2026-11-05: a pixelated shield saw in the style of
the other card icons). ORIGINAL: no render, sprite or game design was traced, pixelated or copied -- the owner's
reference render (id Software's Doom: The Dark Ages) was not used as a source, and none of its emblem, clamps,
skull or colours appear here. It is a generic round saw-shield.

Every pixel is decided here, on an 88x88 grid (the lightsaber icon's art grid is 98x98, the whip's 96):
  * a HEIGHT FIELD over the disc: a ring of 18 raked saw teeth round the rim, a raised steel rim band, a warm brass
    inner ring, a flat steel face with eight round rivets, and a plain domed boss in the centre;
  * each pixel is lit from the top left off that height field's slope and snapped to a few flat shades of its
    material (steel greys, brass), the chunky banding of the other icons;
  * a one-pixel dark outline goes round the whole shape and along each step between the parts (teeth / rim /
    brass / face / boss), so the parts read apart at card size.
Writes Wheel/sources/icons/shieldsaw_icon.png and Wheel/graphics/WRISSAW.png (the same image), and, with --preview,
shieldsaw_icon_4x.png (nearest-neighbour 4x) beside this script.
Run: python3 Wheel/sources/icons/gen_shieldsaw_icon.py [--preview]"""
import math, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
WHEEL = os.path.dirname(os.path.dirname(HERE))
N = 88
C = (N - 1) / 2.0

OUTLINE = (22, 22, 28)
# steel, darkest to lightest (cool greys), and brass (warm), darkest to lightest
STEEL = [(58, 62, 72), (88, 94, 106), (124, 130, 142), (162, 168, 178), (200, 205, 212), (236, 238, 242)]
EDGE = [(96, 100, 110), (140, 146, 156), (190, 194, 202), (228, 230, 236)]   # the teeth's ground cutting edge
BRASS = [(96, 62, 22), (140, 96, 36), (184, 136, 58), (222, 178, 92), (246, 214, 140)]

R_TOOTH_OUT = 43.0   # tooth tips
R_TOOTH_IN = 36.0    # gullet floor
R_RIM = 35.0         # rim band: R_RIM_IN .. R_RIM
R_RIM_IN = 30.0
R_BRASS = 29.0       # brass ring: R_BRASS_IN .. R_BRASS
R_BRASS_IN = 23.5
R_RIVET = 17.5       # rivet circle
RIVET_R = 2.2
N_RIVETS = 8
R_BOSS = 8.5
TEETH = 18

LIGHT = (-0.62, -0.62, 0.48)   # from the top left, a little toward the viewer
_l = math.sqrt(sum(v * v for v in LIGHT))
LIGHT = tuple(v / _l for v in LIGHT)


def tooth_radius(theta):
    """outer edge of the saw at this angle: each tooth rises slowly and drops sharply (raked, turning clockwise)"""
    p = (theta / (2 * math.pi) * TEETH) % 1.0
    if p < 0.78:
        return R_TOOTH_IN + (R_TOOTH_OUT - R_TOOTH_IN) * (p / 0.78) ** 0.9
    return R_TOOTH_IN + (R_TOOTH_OUT - R_TOOTH_IN) * (1.0 - (p - 0.78) / 0.22) ** 2.2


def part_at(x, y):
    """(part, height) at a point; part None outside the shape"""
    dx, dy = x - C, y - C
    r = math.hypot(dx, dy)
    th = math.atan2(dy, dx)
    if r <= R_BOSS:
        return 'boss', 3.0 + 4.0 * math.sqrt(max(0.0, 1 - (r / R_BOSS) ** 2))
    for k in range(N_RIVETS):
        a = 2 * math.pi * (k + 0.5) / N_RIVETS
        rx, ry = C + R_RIVET * math.cos(a), C + R_RIVET * math.sin(a)
        d = math.hypot(x - rx, y - ry)
        if d <= RIVET_R:
            return 'rivet', 1.0 + 2.2 * math.sqrt(max(0.0, 1 - (d / RIVET_R) ** 2))
    if r <= R_BRASS_IN:
        return 'face', 1.0 - 0.6 * (r / R_BRASS_IN)          # a faint dish toward the boss
    if r <= R_BRASS:
        t = (r - R_BRASS_IN) / (R_BRASS - R_BRASS_IN)
        return 'brass', 1.6 + 1.6 * math.sin(math.pi * t)       # a rounded ring
    if r <= R_RIM:
        t = (r - R_RIM_IN) / (R_RIM - R_RIM_IN)
        return 'rim', 2.0 + 2.4 * math.sin(math.pi * min(1.0, t * 1.1))
    if r <= tooth_radius(th):
        # the tooth: a bevel ground toward its tip, so the cutting edge catches the light
        t = (r - R_RIM) / (R_TOOTH_OUT - R_RIM)
        return 'tooth', 1.8 - 1.4 * t
    return None, 0.0


def draw():
    part = [[None] * N for _ in range(N)]
    hgt = [[0.0] * N for _ in range(N)]
    rad = [[0.0] * N for _ in range(N)]
    for py in range(N):
        for px in range(N):
            # 2x2 supersampled coverage: a pixel belongs to the part covering most of it
            votes = {}
            hs = 0.0
            for sx in (0.25, 0.75):
                for sy in (0.25, 0.75):
                    pt, h = part_at(px + sx - 0.5, py + sy - 0.5)
                    votes[pt] = votes.get(pt, 0) + 1
                    hs += h
            best = max(votes.items(), key=lambda kv: kv[1])[0]
            if votes.get(None, 0) >= 3:
                best = None
            part[py][px] = best
            hgt[py][px] = hs / 4.0
            rad[py][px] = math.hypot(px - C, py - C)

    def h_at(x, y, own):
        if 0 <= x < N and 0 <= y < N and part[y][x] == own:
            return hgt[y][x]
        return None

    im = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    pix = im.load()
    for py in range(N):
        for px in range(N):
            pt = part[py][px]
            if pt is None:
                continue
            h0 = hgt[py][px]
            # slope within the same part only (the steps between parts are drawn as outline instead)
            hx1, hx0 = h_at(px + 1, py, pt), h_at(px - 1, py, pt)
            hy1, hy0 = h_at(px, py + 1, pt), h_at(px, py - 1, pt)
            gx = ((hx1 if hx1 is not None else h0) - (hx0 if hx0 is not None else h0)) * 0.5
            gy = ((hy1 if hy1 is not None else h0) - (hy0 if hy0 is not None else h0)) * 0.5
            nx, ny, nz = -gx, -gy, 1.0
            nl = math.sqrt(nx * nx + ny * ny + nz * nz)
            lit = (nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]) / nl   # 0..1
            # a broad top-left to bottom-right sweep over the whole disc, so flat parts are not one flat grey
            sweep = -((px - C) * 0.70 + (py - C) * 0.70) / (R_TOOTH_OUT * 2.0)
            v = lit + sweep * 0.55
            if pt == 'brass':
                pal = BRASS
                v += 0.05
            elif pt == 'tooth':
                pal = EDGE if rad[py][px] > tooth_radius(math.atan2(py - C, px - C)) - 2.3 else STEEL[1:5]
            elif pt == 'face':
                pal = STEEL[1:5]
                v -= 0.06
            elif pt == 'boss':
                pal = STEEL[2:]
            elif pt == 'rivet':
                pal = STEEL[1:]
            else:   # rim
                pal = STEEL[:5]
            i = int(round((v - 0.30) / 0.62 * (len(pal) - 1)))
            pix[px, py] = pal[max(0, min(len(pal) - 1, i))] + (255,)

    # OUTLINE 1: along the steps between parts, on the lower (outer / farther) side of each step
    order = {'tooth': 0, 'face': 1, 'rim': 2, 'brass': 2, 'rivet': 3, 'boss': 4}
    out = im.copy()
    po = out.load()
    for py in range(N):
        for px in range(N):
            pt = part[py][px]
            if pt is None:
                continue
            for qx, qy in ((px + 1, py), (px - 1, py), (px, py + 1), (px, py - 1)):
                if not (0 <= qx < N and 0 <= qy < N):
                    continue
                q = part[qy][qx]
                if q is None or q == pt:
                    continue
                # the face pixel next to the brass ring, a rivet or the boss goes dark; the rim pixel next to a
                # tooth's root goes dark; between rim and brass, the brass side (it sits inside the rim's lip)
                if order[q] > order[pt] or (pt == 'brass' and q == 'rim') or (pt == 'tooth' and q == 'rim'):
                    po[px, py] = OUTLINE + (255,)
                    break
    # OUTLINE 2: round the whole shape (8-neighbour, so the tooth tips stay closed)
    final = out.copy()
    pf = final.load()
    for py in range(N):
        for px in range(N):
            if po[px, py][3]:
                continue
            hit = False
            for qx in (px - 1, px, px + 1):
                for qy in (py - 1, py, py + 1):
                    if 0 <= qx < N and 0 <= qy < N and po[qx, qy][3]:
                        hit = True
            if hit:
                pf[px, py] = OUTLINE + (255,)
    return final


def main():
    im = draw()
    im = im.crop(im.getbbox())
    im.save(os.path.join(HERE, 'shieldsaw_icon.png'))
    im.save(os.path.join(WHEEL, 'graphics', 'WRISSAW.png'))
    if '--preview' in sys.argv:
        im.resize((im.width * 4, im.height * 4), Image.NEAREST).save(os.path.join(HERE, 'shieldsaw_icon_4x.png'))
    print('shieldsaw icon', im.size)


if __name__ == '__main__':
    main()
