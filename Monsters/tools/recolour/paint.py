#!/usr/bin/env python3
"""Per-part recolouring of a sprite: the art step of bake.py (2026-11-13, replaces the flat tint as the default).

A tint maps every recoloured pixel through one hue. This does what a sprite artist does by hand with a palette swap:
- the sprite is split into PARTS (skin, horn = spikes, claws and teeth, claw where a mask asks for it; everything else
  keeps its own pixels: eyes, mouth, blood, guts, fire, outlines, a marine, ice). Parts come from the pixel's nearest
  palette index (Doom sprites are drawn in the palette), then the family's group rules, then hand-written masks;
- every colour has its OWN small palette per part (ramps.py): a dark, a shadow, a base, a light and a highlight colour
  whose hues differ (warm/cool shift from shadow to highlight), and the horns get a palette that contrasts the skin;
- the source's shading is kept: the pixel's perceptual lightness (Oklab L) across the part's range in the whole family
  picks the place on the ramp, so every shade the artist drew stays a separate shade;
- the source's painted variation is kept: how much more or less saturated, and which way its hue leans, compared with
  the part's average at that lightness, is carried onto the new colour (a flush, a rim light, a dirty patch stays).
Nothing here is random and nothing depends on the palette row, so dithered pixels stay one colour family (no speckle)."""
import numpy as np

KEEP, SKIN, HORN, CLAW = 0, 1, 2, 3
PARTS = {'keep': KEEP, 'skin': SKIN, 'horn': HORN, 'claw': CLAW}

# ---- colour science: sRGB <-> Oklab (Bjorn Ottosson, 2020) ----
def _lin(c):
    c = c / 255.0
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)

def _gam(c):
    c = np.clip(c, 0.0, 1.0)
    return np.where(c <= 0.0031308, c * 12.92, 1.055 * np.power(c, 1 / 2.4) - 0.055) * 255.0

def to_oklab(rgb):
    r, g, b = [_lin(rgb[..., i].astype(np.float64)) for i in range(3)]
    l = np.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
    m = np.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
    s = np.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
    return np.stack([0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
                     1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
                     0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s], -1)

def from_oklab(lab):
    L, a, b = lab[..., 0], lab[..., 1], lab[..., 2]
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    bb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    return np.stack([_gam(r), _gam(g), _gam(bb)], -1)

def hexrgb(h):
    h = h.lstrip('#'); return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.float64)

# ---- parts ----
def parse_ranges(words):
    s = set()
    for r in (x for w in words for x in w.split(',')):
        a, _, b = r.partition(':'); s |= set(range(int(a), int(b or a) + 1))
    return s

class Family:
    """The family file's art rules (see families/imp.txt): part, group, tint, mask."""
    def __init__(self, path):
        import os
        self.sprites, self.part_of, self.groups, self.tint, self.masks = set(), {}, [], set(), []
        self.dir = os.path.dirname(os.path.abspath(path))
        for line in open(path):
            w = line.split('#')[0].split()
            if not w: continue
            if w[0] == 'sprites': self.sprites |= set(x.upper() for x in w[1:])
            elif w[0] == 'part':                       # part <name> <ranges...>: the palette indices of a part
                for i in parse_ranges(w[2:]): self.part_of[i] = PARTS[w[1]]
            elif w[0] == 'group':                      # group <prefixes,> <rule> ...: a rule for some lumps only
                self.groups.append((tuple(p.upper() for p in w[1].split(',')), w[2], w[3:]))
            elif w[0] == 'tint':                       # tint <prefixes,>: lumps that keep the old flat tint (not ours)
                self.tint |= set(p.upper() for p in w[1].split(','))
            elif w[0] == 'masks':                      # masks <file>: hand-written rectangles (see masks file)
                self.masks += self._masks(os.path.join(self.dir, w[1]))
        self.lut = np.zeros(256, np.int8)
        for i, p in self.part_of.items(): self.lut[i] = p

    def _masks(self, path):
        out = []
        for line in open(path):
            w = line.split('#')[0].split()
            if not w: continue
            # LUMP|PREFIX* <part> x0 y0 x1 y1 [from=<part>,<part>]
            frm = None
            if w[-1].startswith('from='): frm = [PARTS[p] for p in w[-1][5:].split(',')]; w = w[:-1]
            out.append((w[0].upper(), PARTS[w[1]], tuple(int(v) for v in w[2:6]), frm))
        return out

    def is_tint(self, name):
        return any(name.startswith(p) for p in self.tint)

    def classify(self, name, idx, opaque):
        part = self.lut[idx].astype(np.int8)
        part[~opaque] = KEEP
        for pref, rule, args in self.groups:
            if '*' not in pref and not name.startswith(pref): continue
            if rule == 'keep':                         # keep <ranges>: these indices keep their pixels here
                part[np.isin(idx, list(parse_ranges(args)))] = KEEP
            elif rule == 'set':                        # set <part> <ranges>
                part[np.isin(idx, list(parse_ranges(args[1:]))) & opaque] = PARTS[args[0]]
            elif rule == 'keepnear':                   # keepnear <ranges> <radius> <part>: that part, touching them
                src = np.isin(idx, list(parse_ranges([args[0]]))) & opaque
                near = _dilate(src, int(args[1]))
                part[near & (part == PARTS[args[2]])] = KEEP
            elif rule == 'absorb':                     # absorb <ranges> <part> <n>: these kept pixels join <part>
                cand = np.isin(idx, list(parse_ranges([args[0]]))) & opaque & (part == KEEP)   # where >= n of their
                tgt = PARTS[args[1]]; nb = np.zeros(part.shape, np.int8)                     # 8 neighbours are it
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        if dx or dy: nb += _shift(part == tgt, dy, dx)
                part[cand & (nb >= int(args[2]))] = tgt
        for nm, p, (x0, y0, x1, y1), frm in self.masks:
            if not (name == nm or (nm.endswith('*') and name.startswith(nm[:-1]))): continue
            sub = part[y0:y1 + 1, x0:x1 + 1]; op = opaque[y0:y1 + 1, x0:x1 + 1]
            sel = op if frm is None else (op & np.isin(sub, frm))
            sub[sel] = p
        return part

def _shift(m, dy, dx):
    s = np.roll(np.roll(m, dy, 0), dx, 1)
    if dy > 0: s[:dy] = False
    if dy < 0: s[dy:] = False
    if dx > 0: s[:, :dx] = False
    if dx < 0: s[:, dx:] = False
    return s

def _dilate(m, r):
    out = m.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > r * r: continue
            s = np.roll(np.roll(m, dy, 0), dx, 1)
            if dy > 0: s[:dy] = False
            if dy < 0: s[dy:] = False
            if dx > 0: s[:, :dx] = False
            if dx < 0: s[:, dx:] = False
            out |= s
    return out

# ---- statistics of the source parts across the whole family (pass 1 of the bake) ----
NB = 24
class Stats:
    def __init__(self):
        self.L = {SKIN: [], HORN: [], CLAW: []}; self.lab = {SKIN: [], HORN: [], CLAW: []}
    def add(self, lab, part):
        for p in self.L:
            m = part == p
            if m.any(): self.lab[p].append(lab[m])
    def finish(self):
        self.range, self.mean_a, self.mean_b, self.mean_c, self.edges = {}, {}, {}, {}, {}
        for p, chunks in self.lab.items():
            if not chunks:
                if p == CLAW and HORN in self.range:   # claws share the horn's statistics
                    for d in (self.range, self.mean_a, self.mean_b, self.mean_c, self.edges): d[p] = d[HORN]
                continue
            x = np.concatenate(chunks); L = x[:, 0]
            lo, hi = np.percentile(L, 1), np.percentile(L, 99.5)
            self.range[p] = (lo, hi)
            e = np.linspace(lo, hi, NB + 1); c = (e[:-1] + e[1:]) / 2
            bi = np.clip(np.digitize(L, e) - 1, 0, NB - 1)
            ma, mb, mc = np.zeros(NB), np.zeros(NB), np.zeros(NB)
            for k in range(NB):
                s = x[bi == k]
                if len(s) < 8: ma[k] = mb[k] = mc[k] = np.nan; continue
                ma[k], mb[k] = s[:, 1].mean(), s[:, 2].mean(); mc[k] = np.hypot(s[:, 1], s[:, 2]).mean()
            for arr in (ma, mb, mc):                   # fill thin bins from their neighbours
                ok = ~np.isnan(arr); arr[~ok] = np.interp(c[~ok], c[ok], arr[ok])
            self.mean_a[p], self.mean_b[p], self.mean_c[p], self.edges[p] = ma, mb, mc, c
        return self

# ---- the paint ----
def _ramp(stops, t):
    ts = np.array([s[0] for s in stops]); labs = to_oklab(np.array([hexrgb(s[1]) for s in stops]))
    return np.stack([np.interp(t, ts, labs[:, k]) for k in range(3)], -1)

def _curve(t, k):
    """contrast about the middle: k = 1 linear, k > 1 steeper mids (a smoothstep blend)."""
    if k == 1.0: return t
    s = t * t * (3 - 2 * t)
    return np.clip(t + (k - 1.0) * (s - t), 0, 1)

def _lch_mix(a, b, w):
    """mix two Oklab colours by w (0 = a) along the shorter hue path, keeping chroma (no gray band between hues)."""
    ca, cb = np.hypot(a[:, 1], a[:, 2]), np.hypot(b[:, 1], b[:, 2])
    ha, hb = np.arctan2(a[:, 2], a[:, 1]), np.arctan2(b[:, 2], b[:, 1])
    dh = (hb - ha + np.pi) % (2 * np.pi) - np.pi
    L = a[:, 0] + (b[:, 0] - a[:, 0]) * w; C = ca + (cb - ca) * w; h = ha + dh * w
    return np.stack([L, C * np.cos(h), C * np.sin(h)], -1)

def paint(rgba, part, look, st):
    """rgba: HxWx4 uint8, part: HxW from classify, look: ramps.LOOKS[colour], st: Stats. -> new rgba.
    A look's part may have 'split': a second palette ('stops2') on the top of the body, blended into the first down the
    sprite's own height ('at': where the blend is half way, 0 = the top of the painted pixels, 1 = the bottom; 'soft':
    how wide the blend is). It is smooth and by position, never by palette row: no speckle."""
    out = rgba.copy()
    lab = to_oklab(rgba[..., :3])
    ys = np.nonzero((part != KEEP).any(1))[0]          # the body's own height (not a blood spray above it)
    y_rel = None
    if len(ys):
        top, bot = ys[0], max(ys[-1], ys[0] + 1)
        y_rel = (np.arange(rgba.shape[0])[:, None] - top) / float(bot - top) * np.ones(rgba.shape[:2])
    for p, key in ((SKIN, 'skin'), (HORN, 'horn'), (CLAW, 'claw')):
        m = part == p
        if not m.any() or p not in st.range: continue
        spec = look.get(key) or look['horn']
        x = lab[m]; L = x[:, 0]
        lo, hi = st.range[p]
        t = _curve(np.clip((L - lo) / (hi - lo), 0, 1), spec.get('contrast', 1.0))
        new = _ramp(spec['stops'], t)
        if 'split' in spec and y_rel is not None:
            at, soft = spec['split']
            yr = y_rel[m]
            w = np.clip((yr - (at - soft)) / (2 * soft), 0, 1); w = w * w * (3 - 2 * w)     # 0 at the top, 1 below
            new = _lch_mix(_ramp(spec['stops2'], t), new, w)
        # carry the source's own painted variation (saturation and hue lean against the part's mean at that shade)
        ma = np.interp(L, st.edges[p], st.mean_a[p]); mb = np.interp(L, st.edges[p], st.mean_b[p])
        mc = np.interp(L, st.edges[p], st.mean_c[p])
        sc = np.hypot(x[:, 1], x[:, 2])
        f = np.clip((sc / np.maximum(mc, 1e-4)) ** spec.get('sat_detail', 0.7), 0.55, 1.6)
        dh = np.arctan2(x[:, 2], x[:, 1]) - np.arctan2(mb, ma)
        dh = (dh + np.pi) % (2 * np.pi) - np.pi
        dh = np.clip(dh * spec.get('hue_detail', 0.5), -0.45, 0.45) * np.clip(sc / 0.03, 0, 1)
        na, nb = new[:, 1] * f, new[:, 2] * f
        ca, sa = np.cos(dh), np.sin(dh)
        new[:, 1], new[:, 2] = na * ca - nb * sa, na * sa + nb * ca
        rgb = from_oklab(new)
        out[m, :3] = np.clip(np.rint(rgb), 0, 255).astype(np.uint8)
    return out
