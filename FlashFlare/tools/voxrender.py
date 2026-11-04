#!/usr/bin/env python3
"""voxrender.py -- draw a Kvx (tools/kvx.py) as a picture: orthographic, any yaw and elevation, each visible voxel face a
flat polygon shaded by its direction (painter's order). Used to preview the flare box and to render its sprite fallback.

Axes: KVX x and y across the ground, z counted DOWN from the top. Here the voxel is drawn with z up; yaw turns it about the
vertical (0 = looking along +y, x to the right), elevation tilts the eye down onto it (degrees).
"""
import math
from PIL import Image, ImageDraw

# face: (normal in kvx axes, its 4 corners as offsets from the voxel's low corner, brightness)
FACES = [
    ((-1, 0, 0), [(0, 0, 0), (0, 1, 0), (0, 1, 1), (0, 0, 1)], 0.80),
    ((1, 0, 0), [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)], 0.80),
    ((0, -1, 0), [(0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)], 0.92),
    ((0, 1, 0), [(0, 1, 0), (1, 1, 0), (1, 1, 1), (0, 1, 1)], 0.92),
    ((0, 0, -1), [(0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0)], 1.00),   # top (z down: -z is up)
    ((0, 0, 1), [(0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)], 0.60),
]


def render(k, yaw=0.0, elev=20.0, scale=4.0, pad=4, flat=False):
    """Returns an RGBA image and the pixel position of the voxel's pivot (its bottom centre, where it stands)."""
    cy, sy = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
    ce, se = math.cos(math.radians(elev)), math.sin(math.radians(elev))
    px, py, pz = k.pivot

    def proj(x, y, z):
        # to a z-up frame centred on the pivot
        X, Y, Z = x - px, py - y, pz - z   # y flipped: KVX is left-handed once z points up (UAC reads right)
        # yaw about the vertical
        u = X * cy - Y * sy
        d = X * sy + Y * cy          # depth: away from the eye
        # elevation: eye above, looking down
        v = Z * ce + d * se
        dep = d * ce - Z * se
        return u, -v, dep

    # eye direction in kvx axes (to test which faces face it): the eye looks along +depth
    def facing(n):
        nx, ny, nz = n
        X, Y, Z = nx, -ny, -nz
        d = X * sy + Y * cy
        dep = d * ce - Z * se
        return dep < 0

    vis = [f for f in FACES if facing(f[0])]
    polys = []
    for (x, y, z), c in k.vox.items():
        for n, corners, br in vis:
            if (x + n[0], y + n[1], z + n[2]) in k.vox:
                continue
            pts = [proj(x + a, y + b, z + cc) for a, b, cc in corners]
            dep = sum(p[2] for p in pts) / 4
            r, g, b = k.pal[c]
            f = 1.0 if flat else br
            col = (min(255, int(r * 4.05 * f)), min(255, int(g * 4.05 * f)), min(255, int(b * 4.05 * f)), 255)
            polys.append((dep, [(p[0], p[1]) for p in pts], col))
    if not polys:
        return Image.new('RGBA', (1, 1)), (0, 0)
    xs = [p[0] for _, ps, _ in polys for p in ps]
    ys = [p[1] for _, ps, _ in polys for p in ps]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    W = int(math.ceil((x1 - x0) * scale)) + 2 * pad
    H = int(math.ceil((y1 - y0) * scale)) + 2 * pad
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    dr = ImageDraw.Draw(img)
    polys.sort(key=lambda t: -t[0])
    for _, ps, col in polys:
        dr.polygon([((u - x0) * scale + pad, (v - y0) * scale + pad) for u, v in ps], fill=col)
    pu, pv, _ = proj(px, py, pz)
    return img, ((pu - x0) * scale + pad, (pv - y0) * scale + pad)
