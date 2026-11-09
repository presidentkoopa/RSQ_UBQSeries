#!/usr/bin/env python3
"""gen_beams.py -- RSQ VisualRewards' arrival beams, monster words and pops: the art and its data. Tool only; never ships.
Do not hand-edit what it writes.

    python3 VisualRewards/tools/gen_beams.py           write everything below
    python3 VisualRewards/tools/gen_beams.py preview   + tools/beam_preview/*.png: every exported frame on a contact sheet,
                                                       in three tier colours, through the same band mapping the game uses

THE SPEC is the approved Python mockups (owner 2026-11-09: V1 v2, V2 v2, V3 v3 indoor + outdoor, V4 v2), copied unchanged
but for their paths into tools/beam_spec/ (they lived in /tmp/fx_beam; renders in renders/arrival_beams/). This exporter
imports them and dumps their textures; the timing of every piece is ported by hand to zscript/rsqvr/beams.zs (each
variant's function there names the mockup function it follows).

WHAT IT WRITES
  pk3/sprites/rsqvr/beam/QV**<F>0.png   the beam pieces as sprite frames, each with a grAb offset (bottom centre for the
                                        beams, columns, bursts and skulls; the centre for rings, discs and sparks; the
                                        root for the licks and flames). Pixel art: 1 texel of the mockups (1 map unit)
                                        = 2x2 pixels, nearest neighbour (crisp under the engine's texture filtering; the
                                        game draws them at scale 0.5).
  pk3/graphics/rsqvrw/QVWnnn.png        RS Score's score-line font (RSSCFON: Blue Shadow, via Dakka) as textures, one
                                        per character 32..96, x4 nearest, grAb at the centre (VisualThinker glyphs).
  pk3/graphics/rsqvrw/QVPOPnn.png       the pop: a pixel ring and an eight-point star burst, drawn here in code, x3.
  pk3/zscript/rsqvr/beam_data.zs        the frame table (sprite, frame, texel size), the ring radii, the font metrics,
                                        and the actor that registers every sprite name.

COLOUR: the art is drawn in FOUR GREYS, the mockups' four flat bands (dark 67, mid 127, light 191, core 255: exact Doom
palette entries 106 / 97 / 87 / 4). The game builds one translation per colour asked for (beams.zs RSQVR_Tint), from the
loaded PLAYPAL by brightness: dark, mid, light and core of that colour. A TRNSLATE lump cannot do it (the caller passes
any 0xRRGGBB), and a white sprite tinted by one colour (Shaded / Stencil) would flatten the four bands and lose the white
core. One-colour pieces (rings, discs, sparks) are white and drawn AddShaded in the band's colour: one colour, dimmed
in the same call. The font is levelled grey and coloured by brightness the same way (dark outline, lit face), as RS
Score's own font colours do.

SOURCES: our own art (the beam, rings, discs, sparks, licks, flames, the pop, all drawn in code). V3's dome, splash,
burst and columns and V4's skull pillar are FRAMES CUT FROM THE Z-FIGHTER EFFECTS SHEET (a rip; it asks for credit),
posterized to our four bands: they need credit or a redraw before release (pk3/CREDITS.txt). The font is RS Score's.
"""
import os, sys, struct, zlib, math, random
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
VR = os.path.dirname(HERE)
REPO = os.path.dirname(VR)
SPEC = os.path.join(HERE, 'beam_spec')
PK3 = os.path.join(VR, 'pk3')
SPR_OUT = os.path.join(PK3, 'sprites', 'rsqvr', 'beam')
GFX_OUT = os.path.join(PK3, 'graphics', 'rsqvrw')
ZS_OUT = os.path.join(PK3, 'zscript', 'rsqvr', 'beam_data.zs')
FON = os.path.join(REPO, 'Score', 'RSSCFON.fon2')

sys.path.insert(0, SPEC)
import variants_v3 as V      # noqa: E402  (pulls in variants_v2, variants, beam)

E = 2                         # export pixels per texel (beams)
EW = 4                        # font
EP = 3                        # pop
GREY = {0: None, 1: 67, 2: 127, 3: 191, 4: 255}   # band -> grey (exact PLAYPAL entries)
RADII = [4, 6, 8, 10, 12, 14, 16, 18, 20, 23, 26, 29, 32, 36, 40, 44, 48, 53, 58, 64, 70]
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


def grab_png(path, rgba, gx, gy):
    """save RGBA (uint8 HxWx4) with a grAb chunk (ZDoom's offset) after IHDR"""
    Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
    d = open(path, 'rb').read()
    body = b'grAb' + struct.pack('>ii', int(gx), int(gy))
    chunk = struct.pack('>I', 8) + body + struct.pack('>I', zlib.crc32(body) & 0xffffffff)
    i = 8 + 12 + struct.unpack('>I', d[8:12])[0]
    open(path, 'wb').write(d[:i] + chunk + d[i:])


def idx_rgba(idx, k):
    """band-index map -> grey RGBA, upscaled k x k nearest"""
    h, w = idx.shape
    out = np.zeros((h, w, 4), np.uint8)
    for b in (1, 2, 3, 4):
        m = idx == b
        out[m, :3] = GREY[b]; out[m, 3] = 255
    return out.repeat(k, 0).repeat(k, 1)


def white_rgba(mask, k, val=None):
    h, w = mask.shape
    out = np.zeros((h, w, 4), np.uint8)
    v = val if val is not None else np.where(mask, 255, 0)
    out[..., :3] = np.asarray(v, np.uint8)[..., None] if np.ndim(v) else v
    out[..., 3] = np.where(mask, 255, 0)
    return out.repeat(k, 0).repeat(k, 1)


# ===================================================================================================================
# THE FRAMES (logical list: (set, sprite, letter, texel w, texel h))
frames = []
sets = {}
sprites = []


def add_set(name, spr, images):
    """images: list of (rgba, gx, gy, tw, th): one sprite name, frames A.. in order"""
    assert len(images) <= 26, name
    if spr not in sprites: sprites.append(spr)
    sets[name] = (len(frames), len(images))
    for i, (rgba, gx, gy, tw, th) in enumerate(images):
        frames.append((name, spr, LETTERS[i], tw, th))
        grab_png(os.path.join(SPR_OUT, '%s%s0.png' % (spr, LETTERS[i])), rgba, gx, gy)


def bottom(idx):
    """an index map as a bottom-centre-anchored sprite"""
    h, w = idx.shape
    return (idx_rgba(idx, E), w * E // 2, h * E, w, h)


def trimmed(idx):
    ys, xs = np.nonzero(idx > 0)
    return idx[ys.min():ys.max() + 1, xs.min():xs.max() + 1] if len(xs) else idx


def ring_mask(r, th, disc=False):
    n = 2 * r + 1
    yy, xx = np.mgrid[0:n, 0:n] - r
    d = np.sqrt(xx * xx + yy * yy)
    if disc: return d <= r + 0.35
    return (d <= r + 0.35) & (d > r + 0.35 - th)


def build_beams():
    B = V.BEAM
    # QVBM: the beam's three shimmer frames (beam.py beam_idx), then V2's slam cuts (the top 27 rows of frame C, the top
    # 53 of frame A: variants_v2.V2b k=2, 3)
    imgs = [bottom(b) for b in B] + [bottom(B[2][:27]), bottom(B[0][:53])]
    add_set('BEAM', 'QVBM', imgs)
    # rings (outline 1, 2, 3 texels) and discs, white, centre-anchored, flat on the floor in game
    for name, spr, th in (('RING1', 'QVR1', 1), ('RING2', 'QVR2', 2), ('RING3', 'QVR3', 3), ('DISC', 'QVDS', 0)):
        imgs = []
        for r in RADII:
            m = ring_mask(r, th, disc=(th == 0))
            n = 2 * r + 1
            imgs.append((white_rgba(m, E), n * E // 2, n * E // 2, n, n))
        add_set(name, spr, imgs)
    # sparks: a head and a one-texel trail one band darker (beam.py Sparks.draw), trail below (rising) or above (falling)
    head = np.array([[255], [127]], np.uint8); m = np.ones((2, 1), bool)
    imgs = [(white_rgba(m, E, head), E // 2, E, 1, 2), (white_rgba(m, E, head[::-1].copy()), E // 2, E, 1, 2)]
    add_set('SPARK', 'QVSP', imgs)
    # licks (variants_v2.licks): a tongue of ln 3..7 off the column's side, rising 0.8 a step, mid then dark, thick at
    # the root. Side +1 (A-E) and -1 (F-J). Anchored at the root.
    imgs = []
    for side in (1, -1):
        for ln in range(3, 8):
            px = {}
            for i in range(ln):
                X = side * i; Y = -int(round(i * .8))
                b = 2 if i < ln // 2 else 1
                for dy in range(max(1, (ln - i) // 2)):
                    px[(X, Y + dy)] = b
            xs = [p[0] for p in px]; ys = [p[1] for p in px]
            x0, y0 = min(xs), min(ys)
            idx = np.zeros((max(ys) - y0 + 1, max(xs) - x0 + 1), np.uint8)
            for (x, y), b in px.items(): idx[y - y0, x - x0] = b
            imgs.append((idx_rgba(idx, E), (0 - x0) * E, (0 - y0 + 1) * E, idx.shape[1], idx.shape[0]))
    add_set('LICK', 'QVLK', imgs)
    # flames (variants_v3.flames_up): ln 5..9, a hot (mid) lower half for its first 3 tics, the tip bent out by `side`,
    # a dark inner edge. A-E side +1 hot, F-J side +1 cool, K-O side -1 hot, P-T side -1 cool. Anchored at the base.
    imgs = []
    for side in (1, -1):
        for hot in (True, False):
            for ln in range(5, 10):
                px = {}
                for i in range(ln):
                    c = 2 if (i < ln // 2 and hot) else 1
                    X = side if i > ln - 3 else 0; Y = -i
                    px[(X, Y)] = c
                    if i < ln // 2: px.setdefault((X - side, Y), 1)
                xs = [p[0] for p in px]; ys = [p[1] for p in px]
                x0, y0 = min(xs), min(ys)
                idx = np.zeros((max(ys) - y0 + 1, max(xs) - x0 + 1), np.uint8)
                for (x, y), b in px.items(): idx[y - y0, x - x0] = b
                imgs.append((idx_rgba(idx, E), (0 - x0) * E, (0 - y0 + 1) * E, idx.shape[1], idx.shape[0]))
    add_set('FLAME', 'QVFL', imgs)
    # V3's floor pieces, cut from the Z-Fighter sheet (variants_v3.V3c): dome, splash ("spike"), burst, and the splash
    # flipped to hang from the ceiling with 0, 1, 2 bands dropped (its fade)
    CB = V.CB
    dome = V.cut_idx(f'{CB}/b_dome.png', .42); spike = V.cut_idx(f'{CB}/b_spike.png', .42)
    burst = V.cut_idx(f'{CB}/b_burst.png', .42)
    capb = spike[::-1].copy()
    imgs = [bottom(dome), bottom(spike), bottom(burst)]
    for dn in (0, 1, 2):
        imgs.append(bottom(np.where(capb > 0, np.maximum(capb.astype(int) - dn, 1), 0).astype(np.uint8)))
    add_set('ZFX', 'QVZD', imgs)
    # V3's columns: col2 (fat), col1, col0 (thin) x raw (indoor: cut at the ceiling) / capped (indoor, below it) /
    # tapered (outdoor) x the 5 phases of the bands crawling up (variants_v2.crawl: period 30, 6 a tic -> 5 phases)
    raw = {k: V.cut_idx(f'{CB}/b_{k}.png', .34, .70) for k in ('col2', 'col1', 'col0')}
    for name, spr in (('col2', 'QVC2'), ('col1', 'QVC1'), ('col0', 'QVC0')):
        imgs = []
        for kind in ('raw', 'cap', 'taper'):
            base = raw[name] if kind == 'raw' else (V.cap(raw[name]) if kind == 'cap' else V.taper_idx(raw[name]))
            for ph in range(5):
                imgs.append(bottom(V.crawl(base, ph)))
        add_set(name.upper(), spr, imgs)
    # V4's skull pillar, cut from the Z-Fighter sheet (variants_v2.V4b: 19 frames at 0.9, our stepped top on 2-4, only
    # the main body on 16-18)
    from scipy import ndimage as nd
    sk = [V.cut_idx(f'{V.CS}/s{i:02d}.png', .9) for i in range(19)]
    for i in (2, 3, 4): sk[i] = V.cap(sk[i], 30)
    for i in (16, 17, 18):
        lab, nl = nd.label(sk[i] > 0)
        if nl > 1:
            sizes = nd.sum(sk[i] > 0, lab, range(1, nl + 1)); keep = 1 + int(np.argmax(sizes))
            sk[i][lab != keep] = 0
    add_set('SKULL', 'QVSK', [bottom(s) for s in sk])
    return dict(colh=raw['col0'].shape[0], beamh=B[0].shape[0], beamw=B[0].shape[1])


# ===================================================================================================================
# THE FONT (RS Score's RSSCFON, FON2: the engine's FSingleLumpFont::LoadFON2 layout, as SlowMo's gen_plate_font.py reads)
def load_fon2(path):
    d = open(path, 'rb').read()
    assert d[:4] == b'FON2'
    height = d[4] | (d[5] << 8)
    first, last = d[6], d[7]
    mono = d[8]
    active = d[10] + 1
    count = last - first + 1
    p = 12; kern = 0
    if d[11] & 1:
        kern = struct.unpack_from('<h', d, 12)[0]; p = 14
    if mono:
        w0 = struct.unpack_from('<H', d, p)[0]; widths = [w0] * count; p += 2
    else:
        widths = list(struct.unpack_from('<%dH' % count, d, p)); p += 2 * count
    pal = [tuple(d[p + 3 * i: p + 3 * i + 3]) for i in range(active)]; p += 3 * active
    glyphs = {}
    for i in range(count):
        w = widths[i]
        if w == 0: continue
        n = w * height; out = bytearray()
        while len(out) < n:
            code = d[p]; p += 1
            if code >= 128: code -= 256
            if code >= 0:
                out += d[p:p + code + 1]; p += code + 1
            elif code != -128:
                out += bytes([d[p]]) * (1 - code); p += 1
        glyphs[first + i] = (w, bytes(out[:n]))
    return height, first, last, widths, pal, glyphs, kern


def build_font():
    height, first, last, widths, pal, glyphs, kern = load_fon2(FON)
    lum = [0.299 * r + 0.587 * g + 0.114 * b for (r, g, b) in pal]
    top = max(lum[1:])
    met = {}
    for c in range(32, 97):
        w = widths[c - first] if first <= c <= last else 0
        met[c] = (max(0, w + kern) if w else 0, w)
        if c == 32 or c not in glyphs: continue
        gw, px = glyphs[c]
        a = np.zeros((height, gw, 4), np.uint8)
        for y in range(height):
            for x in range(gw):
                k = px[y * gw + x]
                if k == 0: continue
                v = int(round(255 * min(1.0, lum[k] / top)))     # levelled: the face's brightest grey is white
                a[y, x] = (v, v, v, 255)
        a = a.repeat(EW, 0).repeat(EW, 1)
        grab_png(os.path.join(GFX_OUT, 'QVW%03d.png' % c), a, gw * EW // 2, height * EW // 2)
    return height, met, kern


# ===================================================================================================================
# THE POP (drawn here: a pixel ring and an eight-point star, our own; RSQ Grenade's PixRing / Rays idea, not its art)
POP_N = 9
POP_S = 33


def build_pop():
    c = POP_S // 2
    out = []
    for f in range(POP_N):
        idx = np.zeros((POP_S, POP_S), np.uint8)
        def put(x, y, b):
            if 0 <= x < POP_S and 0 <= y < POP_S: idx[y, x] = max(idx[y, x], b)
        # the ring: radius grows, its band cools; from frame 6 it breaks up (every other texel)
        r = [0, 3, 5, 7, 9, 11, 13, 14, 15][f]
        rb = [4, 4, 3, 3, 2, 2, 1, 1, 1][f]
        if r:
            m = ring_mask(r, 1)
            ys, xs = np.nonzero(m)
            for k, (y, x) in enumerate(zip(ys, xs)):
                if f >= 6 and (x + y + f) % 2: continue
                if f >= 8 and (x * 3 + y) % 3: continue
                put(x - r + c, y - r + c, rb)
        # the star: four long rays and four short diagonals, white at the root, cooling out; then only the tips
        L = [2, 5, 8, 11, 13, 14, 0, 0, 0][f]
        D = [1, 3, 5, 6, 0, 0, 0, 0, 0][f]
        gap = [0, 0, 0, 3, 9, 12, 0, 0, 0][f]
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            for i in range(gap, L + 1):
                b = 4 if i <= 1 else (3 if i < L * .5 else (2 if i < L * .85 else 1))
                if f >= 4: b = min(b, 2)
                put(c + dx * i, c + dy * i, b)
        for dx, dy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
            for i in range(1, D + 1):
                put(c + dx * i, c + dy * i, 3 if i <= D // 2 else 2)
        if f == 0:
            for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): put(c + dx, c + dy, 4)
        a = idx_rgba(idx, EP)
        grab_png(os.path.join(GFX_OUT, 'QVPOP%02d.png' % f), a, POP_S * EP // 2, POP_S * EP // 2)
        out.append(idx)
    return out


# ===================================================================================================================
def zs_array(typ, name, vals, fmt='%d'):
    body = ', '.join(fmt % v for v in vals)
    return '\t\tstatic const %s %s[] = { %s };' % (typ, name, body)


def write_zs(info, fh, fmet, kern):
    L = []
    L.append('// RSQ VisualRewards -- the arrival beams\' frame table, the ring radii, the word font\'s metrics.')
    L.append('// GENERATED by tools/gen_beams.py: do not edit. (Tables are local to static functions: a class-level static const')
    L.append('// array is not resolved on this build.)')
    L.append('class RSQVR_BeamData play')
    L.append('{')
    for name, (start, n) in sets.items():
        L.append('\tconst F_%s = %d;%s// %d frames' % (name, start, ' ' * max(1, 8 - len(name)), n))
    L.append('\tconst NFRAMES = %d;' % len(frames))
    L.append('\tconst NSPR = %d;' % len(sprites))
    L.append('\tconst NRADII = %d;' % len(RADII))
    L.append('\tconst EXPORT_K = %d;          // pixels per texel: the game draws beam art at scale 1/%d' % (E, E))
    L.append('\tconst COL_H = %d;           // V3\'s columns, texels (the "~166 units" of their reach)' % info['colh'])
    L.append('\tconst BEAM_W = %d;' % info['beamw'])
    L.append('\tconst BEAM_H = %d;' % info['beamh'])
    L.append('\tconst POP_N = %d;' % POP_N)
    L.append('\tconst POP_S = %d;           // texels across a pop frame; textures QVPOP00.. at x%d' % (POP_S, EP))
    L.append('\tconst POP_K = %d;' % EP)
    L.append('\tconst FONT_H = %d;            // RSSCFON\'s cell height in its pixels; textures QVW032..QVW096 at x%d' % (fh, EW))
    L.append('\tconst FONT_K = %d;' % EW)
    L.append('')
    L.append('\tstatic String SPR(int i)')
    L.append('\t{')
    L.append('\t\tstatic const String T[] = { %s };' % ', '.join('"%s"' % s for s in sprites))
    L.append('\t\treturn (i >= 0 && i < NSPR) ? T[i] : "TNT1";')
    L.append('\t}')
    for fn, vals in (('FR_SPR', [sprites.index(f[1]) for f in frames]), ('FR_FRM', [LETTERS.index(f[2]) for f in frames]),
                     ('FR_W', [f[3] for f in frames]), ('FR_H', [f[4] for f in frames])):
        L.append('\tstatic int %s(int i)' % fn)
        L.append('\t{')
        L.append(zs_array('int', 'T', vals))
        L.append('\t\treturn (i >= 0 && i < NFRAMES) ? T[i] : 0;')
        L.append('\t}')
    L.append('\t// the rings\' and discs\' radii, texels (frame F_RING1 + i is a ring of radius RADIUS(i))')
    L.append('\tstatic int RADIUS(int i)')
    L.append('\t{')
    L.append(zs_array('int', 'T', RADII))
    L.append('\t\treturn T[clamp(i, 0, NRADII - 1)];')
    L.append('\t}')
    L.append('\t// RSSCFON, characters 32..96: the advance (its width less the font\'s kerning of %d) and the glyph\'s width, in font pixels' % -kern)
    for fn, k in (('FONT_ADV', 0), ('FONT_W', 1)):
        L.append('\tstatic int %s(int c)' % fn)
        L.append('\t{')
        L.append(zs_array('int', 'T', [fmet[c][k] for c in range(32, 97)]))
        L.append('\t\treturn (c >= 32 && c <= 96) ? T[c - 32] : 0;')
        L.append('\t}')
    L.append('}')
    L.append('')
    L.append('// Every sprite name above, in a state, so the engine registers it (sprites are only loaded for names a state uses;')
    L.append('// RSQ Grenade\'s RSQGN_BarrelSprites and bar.zs do the same). Never spawned.')
    L.append('class RSQVR_BeamSprites : Actor')
    L.append('{')
    L.append('\tStates')
    L.append('\t{')
    L.append('\tSpawn:')
    L.append('\t\t' + ' '.join('%s A 0;' % s for s in sprites))
    L.append('\t\tStop;')
    L.append('\t}')
    L.append('}')
    L.append('')
    open(ZS_OUT, 'w').write('\n'.join(L))


def preview():
    """every exported beam frame, coloured three ways through the game's band mapping, on one sheet per set"""
    out = os.path.join(HERE, 'beam_preview'); os.makedirs(out, exist_ok=True)
    cols = [(48, 110, 255), (226, 38, 28), (60, 196, 48)]
    def bands(rgb):
        r, g, b = rgb
        mix = lambda k: tuple(int(v + (255 - v) * k) for v in rgb)
        return {67: tuple(int(v * .5) for v in rgb), 127: rgb, 191: mix(.5), 255: mix(.88)}
    for name, (start, n) in sets.items():
        ims = []
        for i in range(start, start + n):
            _, spr, let, tw, th = frames[i]
            im = Image.open(os.path.join(SPR_OUT, '%s%s0.png' % (spr, let))).convert('RGBA')
            ims.append(np.asarray(im))
        H = max(a.shape[0] for a in ims) + 4; W = sum(a.shape[1] + 4 for a in ims)
        sheet = np.zeros((H * 3, W, 3), np.uint8); sheet[:] = (20, 18, 26)
        for row, rgb in enumerate(cols):
            bm = bands(rgb); x = 0
            for a in ims:
                g = a[..., 0]; m = a[..., 3] > 0
                for gv, c in bm.items():
                    sel = m & (np.abs(g.astype(int) - gv) < 30)
                    sub = sheet[row * H + H - a.shape[0]: row * H + H, x: x + a.shape[1]]
                    sub[sel] = c
                x += a.shape[1] + 4
        Image.fromarray(sheet).save(os.path.join(out, 'set_%s.png' % name))
    print('preview ->', out)


def main():
    os.makedirs(SPR_OUT, exist_ok=True); os.makedirs(GFX_OUT, exist_ok=True)
    for d in (SPR_OUT, GFX_OUT):
        for f in os.listdir(d):
            if f.startswith('QV') and f.endswith('.png'): os.remove(os.path.join(d, f))
    info = build_beams()
    fh, fmet, kern = build_font()
    build_pop()
    write_zs(info, fh, fmet, kern)
    n = sum(1 for f in os.listdir(SPR_OUT)); m = sum(1 for f in os.listdir(GFX_OUT))
    sz = sum(os.path.getsize(os.path.join(SPR_OUT, f)) for f in os.listdir(SPR_OUT))
    sg = sum(os.path.getsize(os.path.join(GFX_OUT, f)) for f in os.listdir(GFX_OUT))
    print('ok: %d beam frames (%d sprite names, %.1f KB), %d word/pop textures (%.1f KB), beam_data.zs' %
          (n, len(sprites), sz / 1024.0, m, sg / 1024.0))
    if 'preview' in sys.argv[1:]: preview()


if __name__ == '__main__':
    main()
