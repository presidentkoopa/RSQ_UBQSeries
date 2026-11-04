#!/usr/bin/env python3
"""preview_md3.py -- a flat-shaded picture of md3 surfaces from three sides (MEASURE ONLY; checks a bake by eye).
    python3 -I tools/preview_md3.py out.png a.md3 [b.md3 ...]"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_flare import read_md3
from PIL import Image, ImageDraw
COL = {'hand': (200, 160, 130), 'body': (200, 30, 30), 'cap': (190, 170, 140), 'ember': (255, 210, 120)}
def view(tris, proj, size=300, pad=10):
    pts = [proj(p) for t in tris for p in t[0]]
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    s = (size - 2 * pad) / max(max(xs) - min(xs), max(ys) - min(ys))
    im = Image.new('RGB', (size, size), (30, 30, 40)); d = ImageDraw.Draw(im)
    L = (0.4, -0.5, 0.75)
    order = sorted(tris, key=lambda t: sum(proj(p)[2] for p in t[0]))
    for ps, col in order:
        a, b, c = ps
        n = [(b[(k+1)%3]-a[(k+1)%3])*(c[(k+2)%3]-a[(k+2)%3])-(b[(k+2)%3]-a[(k+2)%3])*(c[(k+1)%3]-a[(k+1)%3]) for k in range(3)]
        l = math.sqrt(sum(x*x for x in n)) or 1; sh = abs(sum(n[k]*L[k] for k in range(3))/l)*0.7+0.3
        q = [proj(p) for p in ps]
        d.polygon([(pad + (x - min(xs)) * s, size - pad - (y - min(ys)) * s) for x, y, _ in q], fill=tuple(int(v*sh) for v in col))
    return im
tris = []
for f in sys.argv[2:]:
    surfs, _ = read_md3(open(f, 'rb').read())
    for s in surfs:
        vs = s['frames'][0]
        for t in s['tris']: tris.append(([vs[i][0] for i in t], COL.get(s['name'], (150, 150, 150))))
views = [lambda p: (p[0], p[2], p[1]), lambda p: (-p[1], p[2], p[0]), lambda p: (p[0], -p[1], p[2])]
out = Image.new('RGB', (900, 300))
for i, v in enumerate(views): out.paste(view(tris, v), (300 * i, 0))
out.save(sys.argv[1])
