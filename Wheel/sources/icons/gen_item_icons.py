#!/usr/bin/env python3
"""RSQ: four item icons drawn from scratch (owner 2026-11-05: "Build them now") in the style of the Wheel's other drawn
card icons (gen_whip_icon.py, gen_shieldsaw_icon.py). ORIGINAL: no sprite, render or game art was traced, pixelated or
copied. Each one has its own silhouette, so it reads at a glance and not only by its colour:

  WRIFLARE  the road flare (RSQ FlashFlare's RSQFF_Held): a thin red stick, a grey striker cap at the butt, a white
            band, and a burning end with a tall flame and loose sparks
  WRITORCH  the flashlight (RSQ FlashFlare's RSQFF_Torch): a dark metal tube with a tail cap, a knurled grip and a
            button, a wide steel head with a lit lens, and a pale cone of light out of it
  WRIFORCE  the Force hand (RSQ QuestSaber's UBQS_ForceHand): an open hand held up palm out, fingers spread, with
            three blue push waves fanning out over the fingertips
  WRIGLOVE  the boxing glove (RSQ Melee's RSQ_Glove / RSQ_GloveOff): a big round red mitt with its thumb tucked in,
            a white cuff and laces

Every pixel is decided here, the ShieldSaw icon's way: each icon is a map of PARTS, each with a HEIGHT FIELD; a
pixel is lit from the top left off its part's slope and snapped to a few flat shades of that part's material; a
one-pixel dark outline goes round the whole shape and along each step where a nearer part covers a farther one. The
light cone and the sparks' glow are see-through and have no outline (they are light, not things).

Writes, per icon, Wheel/sources/icons/<name>_icon.png and Wheel/graphics/<LUMP>.png (the same image), and the same PNG
into the owning mod, for its weapon's Inventory.Icon: FlashFlare/graphics/rsqff/WRIFLARE.png and WRITORCH.png,
QuestSaber/graphics/WRIFORCE.png, Melee/sprites/rsqml/RMICA0.png (Melee packs no graphics/ folder, so its copy is a
sprite-named lump, as RSQ Grenade's Inventory.Icon QGN1A0 is). With --preview[=<dir>],
<name>_icon_4x.png (nearest-neighbour 4x) and items_sheet_4x.png beside this script (or in <dir>).
Run: python3 Wheel/sources/icons/gen_item_icons.py [--preview[=<dir>]]"""
import math, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
WHEEL = os.path.dirname(os.path.dirname(HERE))
REPO = os.path.dirname(WHEEL)

OUTLINE = (22, 20, 26)
LIGHT = (-0.62, -0.62, 0.48)
_l = math.sqrt(sum(v * v for v in LIGHT))
LIGHT = tuple(v / _l for v in LIGHT)

# palettes, darkest to lightest
STEEL = [(58, 62, 72), (88, 94, 106), (124, 130, 142), (162, 168, 178), (200, 205, 212), (236, 238, 242)]
GUNMETAL = [(30, 32, 38), (46, 50, 58), (66, 70, 80), (92, 98, 110), (128, 134, 146)]
RED = [(92, 16, 18), (138, 26, 26), (180, 40, 34), (214, 68, 52), (240, 116, 92)]
GLOVE_RED = [(96, 14, 16), (142, 22, 24), (186, 34, 32), (222, 62, 50), (246, 112, 94), (252, 168, 150)]
WHITE = [(150, 150, 158), (190, 190, 198), (222, 222, 228), (246, 246, 250)]
CAPGREY = [(48, 48, 54), (72, 72, 80), (100, 100, 110), (132, 132, 142)]
CHAR = [(40, 26, 20), (70, 44, 30), (104, 66, 40)]
FLAME = [(204, 60, 16), (240, 110, 24), (252, 168, 44), (255, 214, 92)]
FLAME_CORE = [(255, 226, 120), (255, 244, 186), (255, 255, 236)]
LENS = [(236, 214, 120), (250, 238, 170), (255, 252, 224)]
BEAM = [(255, 238, 150), (255, 246, 196), (255, 252, 232)]
SKIN = [(122, 72, 46), (162, 104, 70), (198, 138, 98), (226, 172, 132), (244, 206, 170)]
SLEEVE = [(34, 30, 40), (52, 46, 60), (74, 66, 86), (100, 92, 114)]
WAVE = [(30, 70, 168), (56, 116, 220), (110, 170, 246), (178, 214, 255)]
LACE = [(70, 60, 50), (110, 96, 80)]


# ---- geometry helpers --------------------------------------------------------------------------------------------
def seg_t(px, py, ax, ay, bx, by):
    """(t along a->b clamped 0..1, distance from the segment)"""
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy
    t = ((px - ax) * dx + (py - ay) * dy) / L2 if L2 else 0.0
    tc = max(0.0, min(1.0, t))
    return t, math.hypot(px - (ax + dx * tc), py - (ay + dy * tc))


def dome(d, r, top):
    return top * math.sqrt(max(0.0, 1.0 - (d / r) ** 2))


def ell(px, py, cx, cy, rx, ry, ang=0.0):
    """normalised radius of a point in a rotated ellipse (<= 1 inside)"""
    c, s = math.cos(ang), math.sin(ang)
    x, y = px - cx, py - cy
    u, v = x * c + y * s, -x * s + y * c
    return math.hypot(u / rx, v / ry)


# ---- the icons: each part_at(x, y) -> (part, height) or (None, 0) -----------------------------------------------
# A part is (name, z). Higher z is nearer; an outline is drawn on the farther side of a step between parts.

def flare_at(x, y):
    ax, ay, bx, by = 14.0, 78.0, 58.0, 34.0
    # loose sparks round the flame (small round bits)
    for sx, sy, sr in ((80, 12, 2.0), (74, 30, 1.7), (52, 14, 1.6), (84, 26, 1.4), (60, 4, 1.4)):
        if math.hypot(x - sx, y - sy) <= sr:
            return ('spark', 6), dome(math.hypot(x - sx, y - sy), sr, 2.0)
    # the flame: a teardrop leaning up and to the right off the burning end
    fx, fy = bx + 6.0, by - 6.0                    # flame base
    tx, ty = 72.0, 2.0                             # flame tip
    t, d = seg_t(x, y, fx, fy, tx, ty)
    if -0.25 <= t <= 1.0:
        rw = 12.5 * (1.0 - max(0.0, t)) ** 0.7 if t >= 0 else 12.5 * math.sqrt(max(0.0, 1 - (t / 0.25) ** 2))
        wob = 1.6 * math.sin(t * 9.0)
        if rw > 0.6 and d <= rw + wob * (t > 0.2):
            core = rw * 0.34
            if d <= core and t < 0.5:
                return ('core', 5), dome(d, core, 3.0) + 2.0
            return ('flame', 4), dome(d, rw + 1.0, 2.5)
    t, d = seg_t(x, y, ax, ay, bx, by)
    r = 6.2
    if t < 0.13:
        r = 7.0                                    # the striker cap is a little wider
    if 0.0 <= t <= 1.03 and d <= r:
        h = dome(d, r, 4.0)
        if t < 0.13:
            return ('cap', 2), h
        if t > 0.95:
            return ('char', 1), h * 0.8
        if 0.17 < t < 0.24 or 0.56 < t < 0.62:
            return ('band', 2), h
        return ('body', 1), h
    if t < 0 and math.hypot(x - ax, y - ay) <= 7.0:  # round butt of the cap
        return ('cap', 2), dome(math.hypot(x - ax, y - ay), 7.0, 4.0)
    return None, 0.0


def torch_at(x, y):
    ax, ay = 10.0, 82.0          # tail
    bx, by = 44.0, 48.0          # body ends, head starts
    hx, hy = 56.0, 36.0          # head front (lens)
    ux, uy = (hx - ax), (hy - ay)
    L = math.hypot(ux, uy)
    ux, uy = ux / L, uy / L
    nx, ny = -uy, ux
    # lens: the head's open face, an ellipse seen at an angle
    if ell(x, y, hx + ux * 0.8, hy + uy * 0.8, 3.2, 11.0, math.atan2(uy, ux)) <= 1.0:
        e = ell(x, y, hx + ux * 0.8, hy + uy * 0.8, 3.2, 11.0, math.atan2(uy, ux))
        if e <= 0.72:
            return ('lens', 6), dome(e, 1.0, 3.0) + 2.0
        return ('bezel', 5), dome(e, 1.0, 3.0) + 3.0
    # the light: a cone from the lens up and to the right
    rel_x, rel_y = x - hx, y - hy
    along = rel_x * ux + rel_y * uy
    across = rel_x * nx + rel_y * ny
    if 2.0 < along < 30.0 and abs(across) < 10.0 + along * 0.55:
        return ('beam', 0), along
    t, d = seg_t(x, y, ax, ay, hx, hy)
    tb = math.hypot(bx - ax, by - ay) / L          # where the head starts along the axis
    if 0.0 <= t <= 1.0:
        if t < tb:
            r = 6.4
            if t < 0.07:
                r = 7.0
            if d <= r:
                h = dome(d, r, 4.0)
                if t < 0.07:
                    return ('tailcap', 2), h
                # the button, on the near side of the tube
                bpx, bpy = ax + (bx - ax) * 0.66 + nx * -2.5, ay + (by - ay) * 0.66 + ny * -2.5
                if math.hypot(x - bpx, y - bpy) <= 2.6:
                    return ('button', 3), h + dome(math.hypot(x - bpx, y - bpy), 2.6, 1.5)
                if 0.22 < t < 0.42:
                    # knurled grip: rings across the tube
                    ring = (t * L) % 3.0
                    return ('grip', 1), h - (0.8 if ring < 1.2 else 0.0)
                return ('tube', 1), h
        else:
            k = (t - tb) / (1.0 - tb)
            r = 7.2 + 4.0 * k ** 0.9                # the head flares out to the lens
            if d <= r:
                return ('head', 2), dome(d, r, 4.4)
    return None, 0.0


def force_at(x, y):
    y -= 14.0                                      # the hand sits 14 lower than drawn below, under the waves
    # three push waves fanning out over the fingertips (arcs round the palm)
    cx, cy = 44.0, 58.0
    r = math.hypot(x - cx, y - cy)
    ang = math.degrees(math.atan2(y - cy, x - cx))
    for rr, half in ((48.0, 34.0), (55.0, 29.0), (62.0, 24.0)):
        if abs(r - rr) <= 2.2 and -90.0 - half <= ang <= -90.0 + half:
            return ('wave', 7), dome(abs(r - rr), 2.2, 2.0)
    # the sleeve at the wrist
    t, d = seg_t(x, y, 44.0, 76.0, 44.0, 84.0)
    if d <= 11.5 and 0 <= t <= 1.0:
        return ('sleeve', 1), dome(d, 11.5, 4.0)
    # thumb (out to the left, nearer than the palm's edge)
    t, d = seg_t(x, y, 30.0, 66.0, 17.0, 50.0)
    if d <= 5.4:
        return ('thumb', 4), dome(d, 5.4, 3.6) + 1.2
    # fingers
    for (ax, ay, bx, by, rr) in ((33.0, 50.0, 28.0, 25.0, 4.6), (41.0, 48.0, 40.0, 19.0, 4.8),
                                 (49.0, 49.0, 52.0, 22.0, 4.6), (56.0, 54.0, 63.0, 34.0, 4.0)):
        t, d = seg_t(x, y, ax, ay, bx, by)
        if d <= rr:
            h = dome(d, rr, 3.4) + 1.0
            # a crease at each knuckle (a darker band part way down the finger)
            if 0.40 < t < 0.47:
                h -= 0.9
            return ('finger', 3), h
    # palm: a rounded square
    e = ((abs(x - 44.0) / 15.5) ** 3.2 + (abs(y - 62.0) / 15.0) ** 3.2) ** (1 / 3.2)
    if e <= 1.0:
        h = 2.4 * math.sqrt(max(0.0, 1 - e * e)) + 0.8
        # the palm's hollow
        h -= 0.9 * max(0.0, 1.0 - math.hypot(x - 45.0, y - 62.0) / 7.0)
        return ('palm', 2), h
    return None, 0.0


def glove_at(x, y):
    ang = math.radians(-40.0)
    # thumb: tucked along the underside of the mitt, toward its front
    e = ell(x, y, 52.0, 52.0, 16.0, 7.5, math.radians(-40.0))
    if e <= 1.0:
        return ('thumb', 5), dome(e, 1.0, 3.5) + 3.0
    # the finger roll: the padded front of the fist, a seam behind it
    e2 = ell(x, y, 62.0, 26.0, 17.0, 19.0, ang)
    if e2 <= 1.0:
        return ('roll', 4), dome(e2, 1.0, 6.0) + 0.6
    # the mitt: the big rounded back of the glove
    e1 = ell(x, y, 48.0, 38.0, 28.0, 22.0, ang)
    if e1 <= 1.0:
        return ('mitt', 3), dome(e1, 1.0, 5.0)
    # the cuff: a wide band down to the bottom left, with laces up its middle
    t, d = seg_t(x, y, 32.0, 58.0, 16.0, 76.0)
    if d <= 13.0 and t <= 1.0:
        h = dome(d, 13.0, 4.0)
        if t > 0.92:
            return ('opening', 1), h * 0.5
        if t < 0.10:
            return ('trim', 2), h + 0.6
        # laces: a zigzag up the cuff's middle
        tt, dd = t, d
        dx, dy = 16.0 - 32.0, 76.0 - 58.0
        L = math.hypot(dx, dy)
        across = ((x - 32.0) * (-dy) + (y - 58.0) * dx) / L
        zig = 4.5 * abs(((tt * L / 6.0) % 2.0) - 1.0) * 2.0 - 4.5
        if abs(across - zig) <= 1.3 and 0.18 < tt < 0.86:
            return ('lace', 2), h + 0.4
        return ('cuff', 1), h
    return None, 0.0


ICONS = [
    # name, lump, the owning mod's copy, grid, part_at, palettes, see-through parts {part: alpha}
    ('flare', 'WRIFLARE', 'FlashFlare/graphics/rsqff/WRIFLARE.png', 88, flare_at,
     {'cap': CAPGREY, 'band': WHITE, 'body': RED, 'char': CHAR, 'flame': FLAME, 'core': FLAME_CORE,
      'spark': FLAME_CORE}, {}),
    ('torch', 'WRITORCH', 'FlashFlare/graphics/rsqff/WRITORCH.png', 88, torch_at,
     {'tailcap': GUNMETAL, 'tube': GUNMETAL, 'grip': GUNMETAL[:4], 'button': RED[:4], 'head': STEEL[:5],
      'bezel': STEEL[1:], 'lens': LENS, 'beam': BEAM}, {'beam': 120}),
    ('force', 'WRIFORCE', 'QuestSaber/graphics/WRIFORCE.png', 108, force_at,
     {'sleeve': SLEEVE, 'thumb': SKIN, 'finger': SKIN, 'palm': SKIN, 'wave': WAVE}, {}),
    ('glove', 'WRIGLOVE', 'Melee/sprites/rsqml/RMICA0.png', 88, glove_at,
     {'mitt': GLOVE_RED, 'roll': GLOVE_RED, 'thumb': GLOVE_RED, 'cuff': WHITE, 'trim': WHITE[1:], 'lace': LACE,
      'opening': CHAR}, {}),
]


def render(N, part_at, pals, glass):
    part = [[None] * N for _ in range(N)]
    z = [[0] * N for _ in range(N)]
    hgt = [[0.0] * N for _ in range(N)]
    for py in range(N):
        for px in range(N):
            votes, hs, zs = {}, 0.0, {}
            for sx in (0.25, 0.75):
                for sy in (0.25, 0.75):
                    pt, h = part_at(px + sx - 0.5, py + sy - 0.5)
                    name = pt[0] if pt else None
                    votes[name] = votes.get(name, 0) + 1
                    if pt:
                        zs[name] = pt[1]
                    hs += h
            best = max(votes.items(), key=lambda kv: kv[1])[0]
            if votes.get(None, 0) >= 3:
                best = None
            part[py][px] = best
            z[py][px] = zs.get(best, 0)
            hgt[py][px] = hs / 4.0

    def h_at(x, y, own):
        if 0 <= x < N and 0 <= y < N and part[y][x] == own:
            return hgt[y][x]
        return None

    im = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    pix = im.load()
    C = (N - 1) / 2.0
    for py in range(N):
        for px in range(N):
            pt = part[py][px]
            if pt is None:
                continue
            pal = pals[pt]
            if pt in glass:
                # light: brighter toward its source, a few flat bands, see-through
                v = 1.0 - min(1.0, hgt[py][px] / 30.0)
                i = int(v * (len(pal) - 0.01))
                a = int(glass[pt] * (0.45 + 0.55 * v))
                pix[px, py] = pal[max(0, min(len(pal) - 1, i))] + (a,)
                continue
            h0 = hgt[py][px]
            hx1, hx0 = h_at(px + 1, py, pt), h_at(px - 1, py, pt)
            hy1, hy0 = h_at(px, py + 1, pt), h_at(px, py - 1, pt)
            gx = ((hx1 if hx1 is not None else h0) - (hx0 if hx0 is not None else h0)) * 0.5
            gy = ((hy1 if hy1 is not None else h0) - (hy0 if hy0 is not None else h0)) * 0.5
            nx, ny, nz = -gx, -gy, 1.0
            nl = math.sqrt(nx * nx + ny * ny + nz * nz)
            lit = (nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]) / nl
            sweep = -((px - C) * 0.70 + (py - C) * 0.70) / (N * 1.0)
            v = lit + sweep * 0.55
            i = int(round((v - 0.30) / 0.62 * (len(pal) - 1)))
            pix[px, py] = pal[max(0, min(len(pal) - 1, i))] + (255,)

    # OUTLINE 1: the farther side of each step where a nearer part covers it
    out = im.copy()
    po = out.load()
    for py in range(N):
        for px in range(N):
            pt = part[py][px]
            if pt is None or pt in glass:
                continue
            for qx, qy in ((px + 1, py), (px - 1, py), (px, py + 1), (px, py - 1)):
                if not (0 <= qx < N and 0 <= qy < N):
                    continue
                q = part[qy][qx]
                if q is None or q == pt or q in glass:
                    continue
                if z[qy][qx] > z[py][px]:
                    po[px, py] = OUTLINE + (255,)
                    break
    # OUTLINE 2: round every solid part (8-neighbour); see-through light gets none and is covered by the outline
    final = out.copy()
    pf = final.load()
    for py in range(N):
        for px in range(N):
            pt = part[py][px]
            if pt is not None and pt not in glass:
                continue
            hit = False
            for qx in (px - 1, px, px + 1):
                for qy in (py - 1, py, py + 1):
                    if 0 <= qx < N and 0 <= qy < N:
                        q = part[qy][qx]
                        if q is not None and q not in glass:
                            hit = True
            if hit:
                pf[px, py] = OUTLINE + (255,)
    return final


def main():
    pdir = None
    for a in sys.argv[1:]:
        if a.startswith('--preview'):
            pdir = a.split('=', 1)[1] if '=' in a else HERE
    prev = pdir is not None
    sheet = []
    for name, lump, mod, N, fn, pals, glass in ICONS:
        im = render(N, fn, pals, glass)
        im = im.crop(im.getbbox())
        im.save(os.path.join(HERE, name + '_icon.png'))
        im.save(os.path.join(WHEEL, 'graphics', lump + '.png'))
        im.save(os.path.join(REPO, mod))
        if prev:
            big = im.resize((im.width * 4, im.height * 4), Image.NEAREST)
            big.save(os.path.join(pdir, name + '_icon_4x.png'))
            sheet.append(big)
        print(name, lump, im.size, '->', mod)
    if prev and sheet:
        W = sum(s.width for s in sheet) + 16 * (len(sheet) + 1)
        H = max(s.height for s in sheet) + 32
        sh = Image.new('RGBA', (W, H), (70, 74, 84, 255))
        x = 16
        for s in sheet:
            sh.alpha_composite(s, (x, 16))
            x += s.width + 16
        sh.save(os.path.join(pdir, 'items_sheet_4x.png'))


if __name__ == '__main__':
    main()
