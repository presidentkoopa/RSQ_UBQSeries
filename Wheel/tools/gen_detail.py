#!/usr/bin/env python3
"""RSQ Wheel: build the DETAILED gun card pieces (the watch-check card) as voxels.

    python3 tools/gen_detail.py --iwad <freedoom2.wad> [--art tools/card_art] [--font Name=<folder> ...]
                                [--anchor 16,-24,11] [--px 0.14]

Writes into the Wheel folder: voxels/wj*.kvx (glyphs), voxels/wq*.kvx (panel slices, rules, pips, bar,
icons, labels), the VOXELDEF block between the WRDETAIL markers, sprites/wd/*.png (1x1 placeholders so
the sprite names exist) and zscript/wheel/wr_q_detail_states.zs (class wr_DetailStates: the states, the
glyph advance tables, Piece(), Glyph() and Place()). Deterministic: run it again after changing art,
fonts or the anchor.

HOW THE DETAILED CARD IS LAID OUT. A weapon layer's x / y turn its HUD model about the model origin,
1/4 degree a unit (hw_weapon.cpp:108; models.cpp:259-260): x turns it about the model's up axis (Z),
then y about its sideways axis (X); the hand's mirror (hw_vrmodes.cpp:469) flips X outside both turns.
So one voxel per glyph, baked at the card's top-left (ANCHOR), can be put anywhere on the card, but
everything a turn moves stays on a SPHERE about the model origin. A flat panel would leave text 2-4 cm
behind it at the far side (the anchor is off the axes), so every piece here is baked ON that sphere:

    card point (x, y) = Rx(y*VUPP/4 deg) . Rz(-x*HUPP/4 deg) . ANCHOR      x, y in layout pixels

x = 0, y = 0 is the card's top-left; x grows to the player's right, y down. One layout pixel is PX cm.
- Every piece is baked on that surface with its pixels where the layout puts them, and laid with the
  layer x / y that Place() (glyph-like pieces) or PlaceWide() (TOP/MID/BOTTOM/RULE) solves: the turn that
  carries the piece's centre onto its card point. Plain wide pieces come out exact (pure pitch); a
  glyph-like piece is off by at most ~1 layout px at the far corner of a FULL card (it turns rigidly).
- Glyph-like pieces stand FRONT cm nearer the sphere centre so they never fight the panel for depth.
- Mirrored twins (physical left hand, drawn mirrored): x -> W - x (W the card's width; FULL for the
  glyph-like ones), so after the engine's mirror the left card is the right card's mirror image in place
  and reads left to right. The x Place() returns for a twin is already the mirrored hand's.
- Rolled families (the watch-check card, hand palm down): the layout turned ROLL_DEG about the top-left
  (-ROLL_DEG for the mirrored twin). A turned slice drifts with its length when laid by one rotation, so
  rolled wide pieces come in two halves, each placed on its own centre (drift <= ~2.5 px FULL, ~4 px WIDE
  at the bottom of a 48 px card).

Credits: Ermac's Force Unleashed holo art (CREDITS.txt); DoomFont glyphs taken from the IWAD you name
(use Freedoom, BSD licence: the glyphs are copied into the voxels, which a commercial IWAD's art may
not be).
"""
import argparse, math, os, re, struct, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
WHEEL = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from gen_cards import write_kvx  # noqa: E402  (the KVX writer the on-gun card already uses)

ANCHOR = (16.0, -24.0, 11.0)   # the side card's top-left, model cm: inboard of the gun, clear of the stock in the watch twist (rig, both hands)
WIDTHS = [('FULL', 80), ('COMPACT', 62), ('WIDE', 106)]      # layout px (~90 / 70 / 120 mm)
SLICE_H = {'TOP': 6, 'MID': 4, 'BOTTOM': 6}
SIZES = [('TEXT', 1.0), ('SMALL', 0.7)]                      # voxel = this many layout px
FRONT = 0.25                       # cm, glyph-like pieces stand this much in front of the panel
DARK = (24, 20, 18)                # the art's translucent fill is composited over this (the mock's look)
PIP_PX, BAR_W, BAR_H, BAR_ADV = 1, 3, 2, 4
LABELS = ['ammo', 'magazine', 'chamber']
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
ROLL_DEG = -70.0                   # the watch-check family: pictures turned this much in the card plane
FAMS = 'nmrl'                      # family: n plain, m mirrored, r rolled, l rolled + mirrored
CODES = list(range(33, 96))        # glyph voxels for 33..95; 32 (space) is an advance only
D = math.radians(0.25)


# ---- geometry -------------------------------------------------------------------------------------
def rz(p, t):
    c, s = math.cos(t), math.sin(t)
    return (p[0] * c - p[1] * s, p[0] * s + p[1] * c, p[2])


def rx(p, t):
    c, s = math.cos(t), math.sin(t)
    return (p[0], p[1] * c - p[2] * s, p[1] * s + p[2] * c)


class Geo:
    def __init__(self, anchor, px, roll):
        self.A = anchor
        self.roll = roll
        self.Rh = math.hypot(anchor[0], anchor[1])
        self.Rv = math.hypot(anchor[1], anchor[2])
        self.PX = self.Rh * D if px == 'auto' else float(px)   # auto: 1 layout px = 1 unit across
        self.HUPP = self.PX / (self.Rh * D)
        self.VUPP = self.PX / (self.Rv * D)
        self.R = math.sqrt(sum(c * c for c in anchor))

    def card(self, x, v):
        """card point: x layout px across, v units down"""
        return rx(rz(self.A, -x * self.HUPP * D), v * D)

    def pixel(self, x, y, front=0.0):
        """layout px (x across, y down) -> model cm"""
        p = self.card(x, y * self.VUPP)
        k = (self.R - front) / self.R
        return (p[0] * k, p[1] * k, p[2] * k)

    def solve(self, anchor_x, x, v):
        """layer offsets that put a piece baked with its top-left at card x = anchor_x onto card (x, v)."""
        P0 = self.card(anchor_x, 0)
        T = self.card(x, v)
        rho = math.hypot(P0[1], P0[2])
        phi = math.atan2(P0[2], P0[1])
        b = (math.pi - math.asin(max(-1, min(1, T[2] / rho)))) - phi
        b = (b + math.pi) % (2 * math.pi) - math.pi
        P1 = rx(P0, b)
        t = math.atan2(P1[0] * T[1] - P1[1] * T[0], P1[0] * T[0] + P1[1] * T[1])
        return (t / D, 32 + b / D)      # layer x (= -u, u = -t/D), layer y


def fam_xy(geo, x, y, fam, W):
    """card layout px (x across, y down, from the top-left) -> the baked layout px of family fam
    (rolled: turned ROLL about the top-left, -ROLL for the mirrored twin; mirrored: x -> W - x)"""
    if fam >= 2:
        # the left hand rolls the other way and the engine's mirror flips the turn: its twin turns by -ROLL
        r = math.radians(geo.roll if fam == 2 else -geo.roll)
        x, y = x * math.cos(r) - y * math.sin(r), x * math.sin(r) + y * math.cos(r)
    if fam % 2: x = W - x
    return x, y


def half_span(kind, W, half):
    """columns [x0, x1) of a wide piece (half -1 whole, 0 left, 1 right); a RULE line runs 4 px in from each side"""
    a, b = (4, W - 4) if kind == 'RULE' else (0, W)
    return (a, b) if half < 0 else ((a, W // 2) if half == 0 else (W // 2, b))


def bake(geo, img, scale, ox, oy, fam, W, front, out, alpha_cut=60):
    """img RGBA; each source pixel is scale layout px; top-left at layout (ox, oy); family fam on a card W
    layout px wide (W matters for the mirrored twins). Returns voxel count."""
    w, h = img.size
    sv = geo.PX * scale
    pts = []
    for j in range(h):
        for i in range(w):
            c = img.getpixel((i, j))
            if c[3] < alpha_cut: continue
            x, y = fam_xy(geo, ox + (i + 0.5) * scale, oy + (j + 0.5) * scale, fam, W)
            p = geo.pixel(x, y, front)
            pts.append(((-p[0] / sv, -p[1] / sv, -p[2] / sv), c[:3]))
    if not pts:
        pts = [((0, 0, 0), (0, 0, 0))]
    # one grid phase: the first pixel's corner sits on the grid exactly
    ph = [f - math.floor(f) for f in pts[0][0]]
    cells = {}
    for f, col in pts:
        g = tuple(int(round(f[k] - ph[k])) for k in range(3))
        cells[g] = col
    mn = [min(g[k] for g in cells) for k in range(3)]
    size = [max(g[k] for g in cells) - mn[k] + 1 for k in range(3)]
    cols = sorted(set(cells.values()))
    if len(cols) > 255:
        q = Image.new('RGB', (len(cols), 1)); q.putdata(cols); q = q.quantize(255)
        qp = q.getpalette()[:765]; pal = [tuple(qp[i:i + 3]) for i in range(0, 765, 3)]
        idx = {c: q.getpixel((k, 0)) for k, c in enumerate(cols)}
    else:
        pal = cols; idx = {c: k for k, c in enumerate(cols)}
    pal = list(pal) + [(0, 0, 0)] * (256 - len(pal))
    vox = {(g[0] - mn[0], g[1] - mn[1], g[2] - mn[2]): idx[c] for g, c in cells.items()}
    # voxel k's centre is model (piv - k - 0.5) * sv; grid cell g holds model -(g + ph) * sv
    piv = tuple(0.5 - mn[k] - ph[k] for k in range(3))
    write_kvx(out, vox, tuple(size), piv, pal)
    return len(vox)


# ---- sources -------------------------------------------------------------------------------------
def wad_lumps(path):
    d = open(path, 'rb').read()
    n, o = struct.unpack('<ii', d[4:12])
    out = {}
    for i in range(n):
        pos, sz = struct.unpack('<ii', d[o + 16 * i:o + 16 * i + 8])
        out[d[o + 16 * i + 8:o + 16 * i + 16].rstrip(b'\0').decode('ascii', 'replace').upper()] = d[pos:pos + sz]
    return out


def doom_patch(data, pal):
    w, h, lo, to = struct.unpack('<hhhh', data[:8])
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for x in range(w):
        p = struct.unpack('<i', data[8 + 4 * x:12 + 4 * x])[0]
        while data[p] != 255:
            top, ln = data[p], data[p + 1]
            for k in range(ln):
                if 0 <= top + k < h: im.putpixel((x, top + k), pal[data[p + 3 + k]] + (255,))
            p += ln + 4
    return im, to


def whiten(im):
    """keep the shading as grey levels, brightest pixel white (a translation then colours it fully)"""
    lum = [0.299 * r + 0.587 * g + 0.114 * b for (r, g, b, a) in [im.getpixel((x, y)) for y in range(im.size[1]) for x in range(im.size[0])] if a]
    top = max(lum) if lum else 1
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            r, g, b, a = im.getpixel((x, y))
            if a:
                v = int(round(255 * (0.299 * r + 0.587 * g + 0.114 * b) / top))
                v = max(v, 96)
                out.putpixel((x, y), (v, v, v, 255))
    return out


def font_doom(iwad):
    L = wad_lumps(iwad)
    pal = [tuple(L['PLAYPAL'][3 * i:3 * i + 3]) for i in range(256)]
    glyphs, adv, H = {}, {32: 4}, 7     # space: (width of N + 1) / 2 as GZDoom's font code does
    for c in CODES:
        lump = 'STCFN%03d' % c
        if lump not in L: continue
        im, to = doom_patch(L[lump], pal)
        cell = Image.new('RGBA', (im.size[0], H), (0, 0, 0, 0))
        cell.paste(im, (0, -to if to < 0 else 0))
        glyphs[c] = whiten(cell)
        adv[c] = im.size[0]
    return glyphs, adv, H


def font_ermac(art):
    glyphs, adv = {}, {32: 12}
    for name in os.listdir(art):
        m = re.match(r'digit_(.)\.png$', name)
        if not m: continue
        c = ord(m.group(1).upper())
        glyphs[c] = Image.open(os.path.join(art, name)).convert('RGBA')
        adv[c] = 12                      # Ermac's cells are 12 wide; monospaced so numbers line up
    return glyphs, adv, 12


def code_of(fn, prefix=''):
    base = os.path.splitext(fn)[0]
    if prefix and base.upper().startswith(prefix.upper()): base = base[len(prefix):]
    last = re.split(r'[_\-\s]', base)[-1]
    if re.fullmatch(r'\d{3}', last): return int(last)
    if len(last) == 1: return ord(last.upper())
    return None


def font_folder(path, prefix=''):
    glyphs, adv = {}, {}
    for fn in sorted(os.listdir(path)):
        if not fn.lower().endswith('.png'): continue
        c = code_of(fn, prefix)
        if c is None or not 33 <= c <= 95: continue
        im = Image.open(os.path.join(path, fn)).convert('RGBA')
        glyphs[c] = im
    if not glyphs: return None
    H = max(i.size[1] for i in glyphs.values())
    for c, im in glyphs.items():
        bb = im.getbbox()
        adv[c] = (bb[2] + 1) if bb else im.size[0]
    adv[32] = max(2, max(i.size[0] for i in glyphs.values()) // 2)
    return glyphs, adv, H


def panel_art(path, W):
    """Ermac's 300x300 panel at 80x80 (corners ~5 px), nine-sliced to W wide; fill over DARK."""
    src = Image.open(path).convert('RGBA')
    big = src.resize((80, 80), Image.LANCZOS)
    out = Image.new('RGBA', (W, 80), (0, 0, 0, 0))
    out.paste(big.crop((0, 0, 8, 80)), (0, 0))
    out.paste(big.crop((72, 0, 80, 80)), (W - 8, 0))
    mid = big.crop((40, 0, 41, 80))
    for x in range(8, W - 8): out.paste(mid, (x, 0))
    res = Image.new('RGBA', out.size, (0, 0, 0, 0))
    for y in range(80):
        for x in range(W):
            r, g, b, a = out.getpixel((x, y))
            if a < 60: continue
            if a < 235:
                k = a / 255.0
                r, g, b = (int(r * k + DARK[0] * (1 - k)), int(g * k + DARK[1] * (1 - k)), int(b * k + DARK[2] * (1 - k)))
            res.putpixel((x, y), (r, g, b, 255))
    return res, big


def border_colour(big):
    from collections import Counter
    c = Counter(big.getpixel((x, 1))[:3] for x in range(20, 60) if big.getpixel((x, 1))[3] > 200)
    return c.most_common(1)[0][0] if c else (200, 200, 200)


def solid(w, h, col):
    return Image.new('RGBA', (w, h), col + (255,))


# ---- main ----------------------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--iwad', required=True, help='IWAD with STCFN033..095 (use Freedoom: see the header)')
    ap.add_argument('--art', default=os.path.join(HERE, 'card_art'))
    ap.add_argument('--font', action='append', default=[], help='Name=<folder of one-glyph PNGs>')
    ap.add_argument('--anchor', default=','.join('%g' % v for v in ANCHOR))
    ap.add_argument('--px', default='0.14', help='cm per layout pixel (0.14: an 80 px card is 11 cm wide); auto = one unit across')
    ap.add_argument('--roll', type=float, default=ROLL_DEG)
    ap.add_argument('--widths', default='FULL,COMPACT,WIDE')
    ap.add_argument('--wheel', default=WHEEL)
    a = ap.parse_args()
    wheel = a.wheel
    geo = Geo(tuple(float(v) for v in a.anchor.split(',')), a.px, a.roll)
    WF = WIDTHS[0][1]

    fonts = [('DoomFont',) + font_doom(a.iwad), ('ErmacDigits',) + font_ermac(a.art)]
    imp = os.path.join(wheel, 'graphics', 'wrimport')
    if os.path.isdir(imp):
        for pfx in sorted(os.listdir(imp)):
            f = font_folder(os.path.join(imp, pfx), pfx)
            if f: fonts.append(('Imported_' + pfx,) + f)
    for spec in a.font:
        name, path = spec.split('=', 1)
        f = font_folder(path)
        if not f: sys.exit('%s: no glyph PNGs' % path)
        fonts.append((name,) + f)
    if len(fonts) > 36: sys.exit('at most 36 fonts')

    vdir = os.path.join(wheel, 'voxels'); os.makedirs(vdir, exist_ok=True)
    sdir = os.path.join(wheel, 'sprites', 'wd'); os.makedirs(sdir, exist_ok=True)
    for f in os.listdir(vdir):
        if (f.startswith('wj') or f.startswith('wq')) and f.endswith('.kvx'): os.remove(os.path.join(vdir, f))
    for f in os.listdir(sdir): os.remove(os.path.join(sdir, f))

    vdef, runs, cells = [], [], 0
    def frame(sprite, fr, lump, scale):
        vdef.append('%s%s = "%s" { Scale = %.6f }' % (sprite, fr, lump, scale))
        Image.new('RGBA', (1, 1), (0, 0, 0, 0)).save(os.path.join(sdir, '%s%s0.png' % (sprite, fr)))

    # glyphs: sprite WJ<font><A..L>, lump wj<font><t|s><n|m><code>
    fid = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    adv_rows, h_rows, has_rows = [], [], []
    for fi, (fname, glyphs, adv, H) in enumerate(fonts):
        adv_rows.append([adv.get(c, adv.get(32, 4)) for c in range(32, 96)])
        has_rows.append([1 if c in glyphs else 0 for c in range(32, 96)])
        h_rows.append(H)
        for si, (sname, sc) in enumerate(SIZES):
            for m in range(4):
                frames, n = [], 0
                for c in CODES:
                    g = glyphs.get(c)
                    if g is None: g = Image.new('RGBA', (1, 1), (0, 0, 0, 0))
                    spr = 'WJ' + fid[fi] + LETTERS[(si * 4 + m) * 3 + n // 26]
                    fr = LETTERS[n % 26]
                    lump = 'wj%s%s%s%03d' % (fid[fi].lower(), 'ts'[si], FAMS[m], c)
                    cells += bake(geo, g, sc, 0, 0, m, WF, FRONT, os.path.join(vdir, lump + '.kvx'))
                    frame(spr, fr, lump, geo.PX * sc)
                    frames.append((spr, fr)); n += 1
                runs.append(('G%d%s%s' % (fi, 'TS'[si], FAMS[m].upper()), frames))

    # panel slices and rules: sprite WQ<T|M|B|R><A..F> (A..C = FULL/COMPACT/WIDE, D..F their twins)
    bgs = sorted(int(re.match(r'ammo_bg(\d+)\.png$', f).group(1)) for f in os.listdir(a.art) if re.match(r'ammo_bg\d+\.png$', f))
    panels = {}
    for wi, (wname, W) in enumerate(WIDTHS):
        for bg in bgs:
            panels[(wi, bg)] = panel_art(os.path.join(a.art, 'ammo_bg%d.png' % bg), W)
    for kind, kc in (('TOP', 'T'), ('MID', 'M'), ('BOTTOM', 'B'), ('RULE', 'R')):
        for wi, (wname, W) in enumerate(WIDTHS):
            for m in range(4):
                # the rolled families come in two halves (left, right): a turned slice laid by one rotation
                # drifts with its length, so each half is placed on its own centre
                for half in ((-1,) if m < 2 else (0, 1)):
                    spr = 'WQ' + kc + LETTERS[(wi + 3 * m) if half < 1 else (12 + wi + 3 * (m - 2))]
                    frames = []
                    for s_, bg in enumerate(bgs):
                        full, big = panels[(wi, bg)]
                        if kind == 'TOP': img = full.crop((0, 0, W, 6))
                        elif kind == 'MID': img = full.crop((0, 38, W, 42))
                        elif kind == 'BOTTOM': img = full.crop((0, 74, W, 80))
                        else:
                            bc = border_colour(big)
                            img = Image.new('RGBA', (W, 1), (0, 0, 0, 0))
                            img.paste(solid(W - 8, 1, tuple(int(c * 0.6 + d * 0.4) for c, d in zip(bc, DARK))), (4, 0))
                        x0, x1 = half_span(kind, W, half)
                        img = img.crop((x0, 0, x1, img.size[1]))
                        lump = 'wq%s%s%s%02d' % (kc.lower(), 'fcw'[wi], FAMS[m], bg) + ('' if half < 0 else str(half))
                        cells += bake(geo, img, 1.0, x0, 0, m, W, FRONT * 0.5 if kind == 'RULE' else 0.0,
                                      os.path.join(vdir, lump + '.kvx'))
                        frame(spr, LETTERS[s_], lump, geo.PX)
                        frames.append((spr, LETTERS[s_]))
                    runs.append(('%s%d%s%s' % (kind[0], wi, FAMS[m].upper(), 'H' if half == 1 else ''), frames))

    # small pieces: sprite WQX<N|M>
    icons = Image.open(os.path.join(a.art, 'ammo_icons.png')).convert('RGBA')
    small = [  # (name, image, voxel scale in layout px)
        ('PIP_ON', solid(PIP_PX, PIP_PX, (255, 255, 255)), 1.0),
        ('PIP_OFF', solid(PIP_PX, PIP_PX, (88, 88, 88)), 1.0),
        ('BAR_ON', solid(BAR_W, BAR_H, (255, 255, 255)), 1.0),
        ('BAR_OFF', solid(BAR_W, BAR_H, (80, 80, 80)), 1.0),
        ('ROUND', icons.crop(icons.getbbox()).crop((58, 0, 115, 59)), 0.125),
        ('STACK', icons.crop(icons.getbbox()).crop((0, 0, 57, 59)), 0.125),
    ]
    for ln in LABELS:
        im = Image.open(os.path.join(a.art, ln + '.png')).convert('RGBA')
        small.append(('LABEL_' + ln.upper(), im.crop((0, 0, im.getbbox()[2], 12)), 7.0 / 12))
    misc_sizes = []
    short = {'PIP_ON': 'pip1', 'PIP_OFF': 'pip0', 'BAR_ON': 'bar1', 'BAR_OFF': 'bar0', 'ROUND': 'rnd_',
             'STACK': 'stak', 'LABEL_AMMO': 'lamo', 'LABEL_MAGAZINE': 'lmag', 'LABEL_CHAMBER': 'lchm'}
    for m in range(4):
        spr = 'WQX' + FAMS[m].upper()
        frames = []
        for k, (name, img, sc) in enumerate(small):
            bb = img.getbbox()
            if name in ('ROUND', 'STACK'): img = img.crop(img.getbbox())
            lump = 'wqx%s%s' % (FAMS[m], short[name])
            cells += bake(geo, img, sc, 0, 0, m, WF, FRONT, os.path.join(vdir, lump + '.kvx'))
            frame(spr, LETTERS[k], lump, geo.PX * sc)
            frames.append((spr, LETTERS[k]))
            if m == 0: misc_sizes.append((name, img.size[0] * sc, img.size[1] * sc))
        runs.append(('X' + FAMS[m].upper(), frames))

    # VOXELDEF
    vpath = os.path.join(wheel, 'VOXELDEF.txt')
    old = open(vpath).read() if os.path.exists(vpath) else ''
    a0, a1 = '// >>> WRDETAIL (tools/gen_detail.py)', '// <<< WRDETAIL'
    if a0 in old:
        pre, rest = old.split(a0, 1); post = rest.split(a1, 1)[1]
    else:
        pre, post = old, ''
    with open(vpath, 'w') as f:
        f.write(pre.rstrip('\n') + '\n\n' + a0 + '\n' + '\n'.join(vdef) + '\n' + a1 + post.rstrip('\n') + '\n')

    # ZScript
    wfam = lambda m: FAMS[m].upper()
    z = ['// GENERATED by tools/gen_detail.py -- do not edit. The detailed gun card pieces (Project Wheel).',
         '// Layout is in layout pixels on the card: x across from its top-left, y down. Every piece goes where',
         '// Place() (glyph-like) or PlaceWide() (TOP/MID/BOTTOM/RULE) says. Families: mirrored = the',
         '// physical left hand drawn mirrored; rolled = the watch-check card, its pictures and layout turned',
         '// ROLL_DEG in the card plane about the top-left so it reads upright with the hand palm down.',
         'class wr_DetailStates : Weapon',
         '{',
         '\tDefault { +WEAPON.CHEATNOTWEAPON +WEAPON.NOAUTOSWITCHTO Weapon.SelectionOrder 99999; }',
         '\tconst PX_CM = %.6f;          // one layout pixel, cm' % geo.PX,
         '\tconst HUPP = %.6f;           // layer units per layout px across (at the top row, plain family)' % geo.HUPP,
         '\tconst VUPP = %.6f;           // layer units per layout px down' % geo.VUPP,
         '\tconst ROLL_DEG = %.4f;       // the rolled family: layout (x, y) -> (x cos - y sin, x sin + y cos)' % geo.roll,
         '\tconst AX = %.4f; const AY = %.4f; const AZ = %.4f;   // the anchor (card top-left), model cm' % geo.A,
         '\tconst STYLES = %d;   // Ermac ammo_bg %s, in that order' % (len(bgs), ' '.join(map(str, bgs))),
         '\tenum EWidth { W_FULL, W_COMPACT, W_WIDE };',
         '\tstatic const int WIDTH_PX[] = { %s };' % ', '.join(str(w) for _, w in WIDTHS),
         '\tenum EKind { K_TOP, K_MID, K_BOTTOM, K_RULE, K_MISC };',
         '\tstatic const int SLICE_PX[] = { %d, %d, %d, 1 };   // heights, layout px (the RULE line starts 4 px in)' % (
             SLICE_H['TOP'], SLICE_H['MID'], SLICE_H['BOTTOM']),
         '\tenum EMisc { %s };' % ', '.join('M_' + n for n, _, _ in small),
         '\t// misc piece sizes, layout px x 100 (w, h), in EMisc order; the bar segment advance is BAR_ADV px',
         '\tstatic const int MISC_SIZE[] = { %s };' % ', '.join('%d, %d' % (round(w * 100), round(h * 100)) for _, w, h in misc_sizes),
         '\tconst BAR_ADV = %d;' % BAR_ADV,
         '\tenum EFont { %s };' % ', '.join('F_' + re.sub(r'\W', '_', f[0]) for f in fonts),
         '\tconst FONTS = %d;' % len(fonts),
         '\tenum ESize { S_TEXT, S_SMALL };',
         '\tconst SMALL_SCALE = %g;' % SIZES[1][1],
         '\tstatic const int FONT_H[] = { %s };   // glyph height in source px (x the size scale = layout px)' % ', '.join(map(str, h_rows)),
         '\t// advance of codes 32..95 in source px, font after font (x the size scale = layout px)',
         '\tstatic const int GLYPH_ADV[] = {']
    for fi, row in enumerate(adv_rows):
        z.append('\t\t' + ', '.join(map(str, row)) + (',' if fi < len(adv_rows) - 1 else '') + '   // ' + fonts[fi][0])
    z += ['\t};', '\tstatic const int GLYPH_HAS[] = {']
    for fi, row in enumerate(has_rows):
        z.append('\t\t' + ', '.join(map(str, row)) + (',' if fi < len(has_rows) - 1 else ''))
    z += ['\t};', '\tStates', '\t{']
    for label, frames in runs:
        z.append('\t%s:' % label)
        for spr, fr in frames: z.append('\t\t%s %s -1 Bright;' % (spr, fr))
        z.append('\t\tStop;')
    z += ['\t}', '',
          '\tprivate static State Walk(State s, int n)',
          '\t{',
          '\t\tfor (int i = 0; i < n && s; i++) s = s.NextState;',
          '\t\treturn s;',
          '\t}', '',
          '\t// kind K_TOP/K_MID/K_BOTTOM/K_RULE: index = style 0..STYLES-1, width W_*; a ROLLED wide piece comes in',
          '\t// two halves (half 0 left, 1 right: draw both, each placed with PlaceWide). K_MISC: index = M_*.',
          '\tstatic State Piece(int kind, bool mirrored, bool rolled, int index, int width = W_FULL, int half = 0)',
          '\t{',
          '\t\tlet d = GetDefaultByType("wr_DetailStates");',
          '\t\tint fam = (rolled ? 2 : 0) + (mirrored ? 1 : 0);',
          '\t\tif (kind == K_MISC)', '\t\t{', '\t\t\tswitch (fam)', '\t\t\t{']
    for m in range(4):
        z.append('\t\t\tcase %d: return Walk(d.FindState("X%s"), index);' % (m, wfam(m)))
    z += ['\t\t\t}', '\t\t\treturn null;', '\t\t}',
          '\t\tif (index < 0 || index >= STYLES || width < 0 || width > 2) return null;',
          '\t\tint k = ((kind * 3 + width) * 4 + fam) * 2 + (rolled && half == 1 ? 1 : 0);',
          '\t\tswitch (k)', '\t\t{']
    for kind, kc in enumerate('TMBR'):
        for wi in range(3):
            for m in range(4):
                for h in ((0,) if m < 2 else (0, 1)):
                    z.append('\t\tcase %d: return Walk(d.FindState("%s%d%s%s"), index);' % (((kind * 3 + wi) * 4 + m) * 2 + h, kc, wi, wfam(m), 'H' if h else ''))
    z += ['\t\t}', '\t\treturn null;', '\t}', '',
          '\t// font F_*, size S_TEXT/S_SMALL, code 33..95 (lower case folds up). Null for a space or a missing glyph.',
          '\tstatic State Glyph(int font, int size, bool mirrored, bool rolled, int code)',
          '\t{',
          '\t\tif (code >= 97 && code <= 122) code -= 32;',
          '\t\tif (font < 0 || font >= FONTS || code < 33 || code > 95 || !wr_DetailStates.GLYPH_HAS[font * 64 + code - 32]) return null;',
          '\t\tlet d = GetDefaultByType("wr_DetailStates");',
          '\t\tint k = ((font * 2 + size) * 4) + (rolled ? 2 : 0) + (mirrored ? 1 : 0);',
          '\t\tswitch (k)', '\t\t{']
    for fi in range(len(fonts)):
        for si in range(2):
            for m in range(4):
                z.append('\t\tcase %d: return Walk(d.FindState("G%d%s%s"), code - 33);' % ((fi * 2 + si) * 4 + m, fi, 'TS'[si], wfam(m)))
    z += ['\t\t}', '\t\treturn null;', '\t}', '',
          '\t// layout px a glyph moves the pen (space included), at that size',
          '\tstatic double Advance(int font, int size, int code)',
          '\t{',
          '\t\tif (code >= 97 && code <= 122) code -= 32;',
          '\t\tif (font < 0 || font >= FONTS || code < 32 || code > 95) return 0;',
          '\t\treturn wr_DetailStates.GLYPH_ADV[font * 64 + code - 32] * (size == S_SMALL ? SMALL_SCALE : 1.0);',
          '\t}',
          '\tstatic double TextWidth(int font, int size, String s)',
          '\t{',
          '\t\tdouble w = 0;',
          '\t\tfor (int i = 0; i < s.Length(); i++) w += Advance(font, size, s.ByteAt(i));',
          '\t\treturn w;',
          '\t}', '',
          '\t// layout px on a card cardW wide, in a family -> model cm (the point the generator baked there)',
          '\tstatic Vector3 CardPoint(double x, double y, bool mirrored, bool rolled, double cardW)',
          '\t{',
          '\t\tif (rolled)', '\t\t{',
          '\t\t\tdouble r = mirrored ? -ROLL_DEG : ROLL_DEG;',
          '\t\t\tdouble c = cos(r), s = sin(r);',
          '\t\t\tdouble x2 = x * c - y * s; y = x * s + y * c; x = x2;',
          '\t\t}',
          '\t\tif (mirrored) x = cardW - x;',
          '\t\tdouble t = -x * HUPP * 0.25, b = y * VUPP * 0.25;',
          '\t\tdouble X = AX * cos(t) - AY * sin(t), Y = AX * sin(t) + AY * cos(t);',
          '\t\treturn (X, Y * cos(b) - AZ * sin(b), Y * sin(b) + AZ * cos(b));',
          '\t}', '',
          '\t// The layer (x, y) that puts a glyph-like piece pw x ph layout px with its top-left on card layout px',
          '\t// (x, y) of a card cardW wide (solved at the piece centre). For the mirrored family the layer x',
          '\t// returned is already the mirrored hand\'s. Add a side nudge to x afterwards if you use one.',
          '\tstatic Vector2 Place(double x, double y, bool mirrored, bool rolled, double cardW, double pw, double ph)',
          '\t{',
          '\t\treturn Solve(CardPoint(pw / 2, ph / 2, mirrored, rolled, wr_DetailStates.WIDTH_PX[W_FULL]),',
          '\t\t\tCardPoint(x + pw / 2, y + ph / 2, mirrored, rolled, cardW));',
          '\t}',
          '\t// The same for a wide piece (K_TOP/K_MID/K_BOTTOM/K_RULE of width W_*) with its top edge at card y.',
          '\tstatic Vector2 PlaceWide(int kind, double y, bool mirrored, bool rolled, int width, int half = 0)',
          '\t{',
          '\t\tint W = wr_DetailStates.WIDTH_PX[width];',
          '\t\tdouble a = kind == K_RULE ? 4 : 0, b = kind == K_RULE ? W - 4 : W;',
          '\t\tif (rolled) { if (half == 1) a = W / 2; else b = W / 2; }',
          '\t\tdouble cx = (a + b) / 2, cy = wr_DetailStates.SLICE_PX[min(kind, 3)] / 2.;',
          '\t\treturn Solve(CardPoint(cx, cy, mirrored, rolled, W), CardPoint(cx, y + cy, mirrored, rolled, W));',
          '\t}',
          '\t// the turn (yaw about Z after pitch about X) that carries baked point p0 onto card point tg',
          '\tstatic Vector2 Solve(Vector3 p0, Vector3 tg)',
          '\t{',
          '\t\tdouble rho = sqrt(p0.y * p0.y + p0.z * p0.z);',
          '\t\tdouble b = (180 - asin(clamp(tg.z / rho, -1, 1))) - atan2(p0.z, p0.y);',
          '\t\twhile (b > 180) b -= 360;',
          '\t\twhile (b < -180) b += 360;',
          '\t\tdouble y1 = p0.y * cos(b) - p0.z * sin(b);',
          '\t\tdouble t = atan2(p0.x * tg.y - y1 * tg.x, p0.x * tg.x + y1 * tg.y);',
          '\t\treturn (t * 4, 32 + b * 4);',
          '\t}',
          '}', '']
    with open(os.path.join(wheel, 'zscript', 'wheel', 'wr_q_detail_states.zs'), 'w') as f:
        f.write('\n'.join(z))
    # include it after the on-gun card's states
    zs = os.path.join(wheel, 'zscript.txt')
    t = open(zs).read()
    if 'wr_q_detail_states.zs' not in t:
        line = '#include "zscript/wheel/wr_q_detail_states.zs"   // generated by tools/gen_detail.py\n'
        k = t.find('\n', t.find('wr_q_card_states.zs')) + 1
        t = t[:k] + line + t[k:] if k > 0 else t + line
        open(zs, 'w').write(t)
    B = geo.card(WF, 0)
    print('fonts %s' % ', '.join(f[0] for f in fonts))
    print('PX %.5f cm  HUPP %.4f  VUPP %.4f  radius %.2f cm  twin anchor %s' % (geo.PX, geo.HUPP, geo.VUPP, geo.R,
          tuple(round(c, 3) for c in B)))
    print('voxels %d, voxel cells %d' % (len(vdef), cells))


if __name__ == '__main__':
    main()
